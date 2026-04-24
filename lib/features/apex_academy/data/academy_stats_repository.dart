/// SharedPreferences-backed persistence for the cosmetic layer around
/// the Apex Academy: daily streak, total XP, and per-day drill counts
/// (used to gate the XP ring + "Daily quest complete" state).
///
/// Streak rule: consecutive calendar days with at least one correct
/// drill. A gap of more than 1 day resets to 0.
library;

import 'package:shared_preferences/shared_preferences.dart';

class AcademyStats {
  const AcademyStats({
    required this.streakDays,
    required this.totalXp,
    required this.drillsToday,
    required this.correctToday,
    this.lastDrillDate,
  });

  factory AcademyStats.empty() => const AcademyStats(
        streakDays: 0,
        totalXp: 0,
        drillsToday: 0,
        correctToday: 0,
      );

  final int streakDays;
  final int totalXp;
  final int drillsToday;
  final int correctToday;
  final DateTime? lastDrillDate;
}

class AcademyStatsRepository {
  AcademyStatsRepository({SharedPreferences? prefs}) : _prefs = prefs;
  SharedPreferences? _prefs;

  static const _streakKey = 'apex.academy.streak';
  static const _xpKey = 'apex.academy.xp';
  static const _drillsTodayKey = 'apex.academy.drills_today';
  static const _correctTodayKey = 'apex.academy.correct_today';
  static const _lastDateKey = 'apex.academy.last_date';

  /// Daily goal in drills. When [drillsToday] >= this, the ring is
  /// full and the "Daily quest complete" state fires.
  static const int dailyDrillGoal = 5;

  /// XP reward per drill attempt. Shown during the result-flash
  /// animation.
  static const int xpPerCorrect = 10;
  static const int xpPerAttempt = 3;

  Future<SharedPreferences> _ensure() async =>
      _prefs ??= await SharedPreferences.getInstance();

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Future<AcademyStats> read() async {
    final p = await _ensure();
    final streak = p.getInt(_streakKey) ?? 0;
    final xp = p.getInt(_xpKey) ?? 0;
    final todayKey = _today();
    final lastDateStr = p.getString(_lastDateKey);
    int drillsToday = 0;
    int correctToday = 0;
    if (lastDateStr == todayKey) {
      drillsToday = p.getInt(_drillsTodayKey) ?? 0;
      correctToday = p.getInt(_correctTodayKey) ?? 0;
    }
    return AcademyStats(
      streakDays: streak,
      totalXp: xp,
      drillsToday: drillsToday,
      correctToday: correctToday,
      lastDrillDate: lastDateStr == null ? null : DateTime.tryParse(lastDateStr),
    );
  }

  /// Record a drill result and return the refreshed stats.
  ///
  /// * Increments per-day counters (resets them if the stored date
  ///   isn't today).
  /// * Awards XP (more for correct).
  /// * Advances the streak the first time today we record a correct
  ///   drill, resetting it if the last qualifying day is >1 day away.
  Future<AcademyStats> recordResult({required bool correct}) async {
    final p = await _ensure();
    final todayKey = _today();
    final lastKey = p.getString(_lastDateKey);

    int drillsToday = (lastKey == todayKey)
        ? (p.getInt(_drillsTodayKey) ?? 0)
        : 0;
    int correctToday = (lastKey == todayKey)
        ? (p.getInt(_correctTodayKey) ?? 0)
        : 0;

    drillsToday += 1;
    if (correct) correctToday += 1;

    final priorStreak = p.getInt(_streakKey) ?? 0;
    final streak = nextStreak(
      previous: priorStreak,
      lastDrillKey: lastKey,
      todayKey: todayKey,
      correct: correct,
      now: DateTime.now(),
    );

    final xpGain = correct ? xpPerCorrect : xpPerAttempt;
    final totalXp = (p.getInt(_xpKey) ?? 0) + xpGain;

    await p.setInt(_streakKey, streak);
    await p.setInt(_xpKey, totalXp);
    await p.setInt(_drillsTodayKey, drillsToday);
    await p.setInt(_correctTodayKey, correctToday);
    await p.setString(_lastDateKey, todayKey);

    return AcademyStats(
      streakDays: streak,
      totalXp: totalXp,
      drillsToday: drillsToday,
      correctToday: correctToday,
      lastDrillDate: DateTime.now(),
    );
  }

  /// Pure streak-math helper extracted for unit testing.
  ///
  /// Applies the documented streak rule — *consecutive calendar days
  /// with at least one correct drill; a gap of more than 1 day resets
  /// to zero* — irrespective of whether this drill happens to be
  /// correct. The previous implementation only evaluated the gap when
  /// `correct == true`, which meant an incorrect drill on the return
  /// day could overwrite `_lastDateKey` and hide the gap from later
  /// correct drills, preserving a stale streak across an
  /// effectively-broken run.
  ///
  /// Parameters:
  ///   * [previous]: current stored streak.
  ///   * [lastDrillKey]: yyyy-mm-dd of the most recent drill, or null
  ///     if the user has never drilled.
  ///   * [todayKey]: yyyy-mm-dd of the drill being recorded (derived
  ///     from [now]).
  ///   * [correct]: whether this drill was answered correctly.
  ///   * [now]: the "wall-clock" moment used to derive "yesterday";
  ///     injected so tests can fast-forward the calendar.
  static int nextStreak({
    required int previous,
    required String? lastDrillKey,
    required String todayKey,
    required bool correct,
    required DateTime now,
  }) {
    var streak = previous;
    // Detect calendar gap regardless of correctness.
    if (lastDrillKey != null && lastDrillKey != todayKey) {
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayKey =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}'
          '-${yesterday.day.toString().padLeft(2, '0')}';
      if (lastDrillKey != yesterdayKey) {
        streak = 0;
      }
    }
    if (correct && lastDrillKey != todayKey) {
      // First correct drill of a new day — advance. Covers both
      // "continued from yesterday" (streak+1) and "returning after a
      // gap" (streak was reset to 0 → 1).
      streak = streak + 1;
    }
    return streak;
  }

  Future<void> clear() async {
    final p = await _ensure();
    await p.remove(_streakKey);
    await p.remove(_xpKey);
    await p.remove(_drillsTodayKey);
    await p.remove(_correctTodayKey);
    await p.remove(_lastDateKey);
  }
}

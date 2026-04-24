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

    int streak = p.getInt(_streakKey) ?? 0;
    if (correct) {
      // Streak advances only on the *first* correct drill of each
      // new day — otherwise a single session could rack up fake
      // streak days.
      if (lastKey != todayKey) {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final yesterdayKey =
            '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}'
            '-${yesterday.day.toString().padLeft(2, '0')}';
        streak = (lastKey == yesterdayKey) ? streak + 1 : 1;
      }
    }

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

  Future<void> clear() async {
    final p = await _ensure();
    await p.remove(_streakKey);
    await p.remove(_xpKey);
    await p.remove(_drillsTodayKey);
    await p.remove(_correctTodayKey);
    await p.remove(_lastDateKey);
  }
}

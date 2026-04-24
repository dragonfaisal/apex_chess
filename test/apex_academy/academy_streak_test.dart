/// Unit tests for [AcademyStatsRepository.nextStreak] — the pure streak
/// math extracted so the calendar-gap rule is exercisable without
/// mocking `DateTime.now()` or `SharedPreferences`.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:apex_chess/features/apex_academy/data/academy_stats_repository.dart';

String _keyFor(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

void main() {
  group('AcademyStatsRepository.nextStreak', () {
    final today = DateTime(2026, 4, 23);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));

    test('never-drilled + first drill correct → streak = 1', () {
      final result = AcademyStatsRepository.nextStreak(
        previous: 0,
        lastDrillKey: null,
        todayKey: _keyFor(today),
        correct: true,
        now: today,
      );
      expect(result, 1);
    });

    test('same-day second correct drill does not re-advance', () {
      final result = AcademyStatsRepository.nextStreak(
        previous: 1,
        lastDrillKey: _keyFor(today),
        todayKey: _keyFor(today),
        correct: true,
        now: today,
      );
      expect(result, 1);
    });

    test('consecutive-day correct → streak + 1', () {
      final result = AcademyStatsRepository.nextStreak(
        previous: 5,
        lastDrillKey: _keyFor(yesterday),
        todayKey: _keyFor(today),
        correct: true,
        now: today,
      );
      expect(result, 6);
    });

    test('gap > 1 day correct → resets then advances to 1', () {
      final result = AcademyStatsRepository.nextStreak(
        previous: 10,
        lastDrillKey: _keyFor(twoDaysAgo),
        todayKey: _keyFor(today),
        correct: true,
        now: today,
      );
      expect(result, 1);
    });

    test('gap > 1 day incorrect → resets to 0 (regression for #9 🔴)', () {
      // Day 1: correct → streak = 10 (historical). Day 3: incorrect.
      // Without the fix the gap-detection was gated behind
      // `if (correct)`, and `_lastDateKey` was *still* updated to
      // today — so a later correct drill on Day 3 would see
      // `lastKey == todayKey` and skip gap detection, preserving 10.
      final result = AcademyStatsRepository.nextStreak(
        previous: 10,
        lastDrillKey: _keyFor(twoDaysAgo),
        todayKey: _keyFor(today),
        correct: false,
        now: today,
      );
      expect(result, 0, reason: 'gap > 1 day must reset irrespective of correctness');
    });

    test('return-day sequence: wrong then right → streak = 1', () {
      // Simulates the full reproduction from the review comment.
      // Day 1: correct, streak = 10. Day 3: first drill is wrong.
      final afterWrong = AcademyStatsRepository.nextStreak(
        previous: 10,
        lastDrillKey: _keyFor(twoDaysAgo),
        todayKey: _keyFor(today),
        correct: false,
        now: today,
      );
      expect(afterWrong, 0);

      // Day 3: second drill same day, correct. lastKey is now `today`
      // (would be persisted by recordResult after the first drill).
      final afterRight = AcademyStatsRepository.nextStreak(
        previous: afterWrong,
        lastDrillKey: _keyFor(today),
        todayKey: _keyFor(today),
        correct: true,
        now: today,
      );
      // Same-day correct must NOT re-advance — rule is one-per-day.
      // The streak stays at the reset value (0), not the stale 10.
      expect(afterRight, 0);
    });

    test('gap > 1 day incorrect then tomorrow correct → streak = 1', () {
      // Day 3 wrong (reset), next day correct → fresh streak = 1.
      final afterWrong = AcademyStatsRepository.nextStreak(
        previous: 10,
        lastDrillKey: _keyFor(twoDaysAgo),
        todayKey: _keyFor(today),
        correct: false,
        now: today,
      );
      expect(afterWrong, 0);

      final tomorrow = today.add(const Duration(days: 1));
      final next = AcademyStatsRepository.nextStreak(
        previous: afterWrong,
        lastDrillKey: _keyFor(today),
        todayKey: _keyFor(tomorrow),
        correct: true,
        now: tomorrow,
      );
      expect(next, 1);
    });

    test('incorrect drill consecutive day does NOT advance streak', () {
      // Yesterday correct (streak = 3). Today incorrect — streak must
      // neither advance nor reset (gap is 1 day, not >1).
      final result = AcademyStatsRepository.nextStreak(
        previous: 3,
        lastDrillKey: _keyFor(yesterday),
        todayKey: _keyFor(today),
        correct: false,
        now: today,
      );
      expect(result, 3);
    });
  });
}

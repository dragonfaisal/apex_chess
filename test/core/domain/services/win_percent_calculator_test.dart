/// Phase A § 1: WinPercentCalculator — Lichess sigmoid.
///
/// Pinning every cp value the spec calls out (0, ±100, ±300, ±1000)
/// plus the mate cases. The numeric expectations come from evaluating
/// the published Lichess formula directly:
///
///   `Win% = 50 + 50 · (2 / (1 + exp(-0.00368208 · cp)) − 1)`
///
/// not from the implementation under test, so a regression in the
/// constants would be caught.
library;

import 'dart:math' as math;

import 'package:apex_chess/core/domain/services/win_percent_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

double referenceWin(int cp) {
  final clamped = cp.clamp(-1000, 1000);
  final w = 2.0 / (1.0 + math.exp(-0.00368208 * clamped)) - 1.0;
  return 50.0 + 50.0 * w;
}

void main() {
  const calc = WinPercentCalculator();

  group('WinPercentCalculator', () {
    test('cp == 0 returns exactly 50%', () {
      expect(calc.forCp(cp: 0), closeTo(50.0, 1e-9));
    });

    test('cp = +100 ≈ 59.2%, cp = -100 ≈ 40.8% (symmetric about 50)', () {
      final wPos = calc.forCp(cp: 100);
      final wNeg = calc.forCp(cp: -100);
      expect(wPos, closeTo(referenceWin(100), 1e-9));
      expect(wNeg, closeTo(referenceWin(-100), 1e-9));
      expect(wPos + wNeg, closeTo(100.0, 1e-9));
      expect(wPos, greaterThan(58.0));
      expect(wPos, lessThan(60.0));
    });

    test('cp = ±300 reproduces the reference formula', () {
      expect(calc.forCp(cp: 300), closeTo(referenceWin(300), 1e-9));
      expect(calc.forCp(cp: -300), closeTo(referenceWin(-300), 1e-9));
    });

    test('cp = +1000 / -1000 hits the clamp boundary symmetrically', () {
      final wMax = calc.forCp(cp: 1000);
      final wMin = calc.forCp(cp: -1000);
      expect(wMax, closeTo(referenceWin(1000), 1e-9));
      expect(wMin, closeTo(referenceWin(-1000), 1e-9));
      expect(wMax + wMin, closeTo(100.0, 1e-9));
    });

    test('cp beyond clamp window saturates (does not extrapolate)', () {
      // Spec § 3.1.2: clamp before exponentiation. Both 1000 and
      // 5000 must yield identical Win% because the input is clamped
      // to ±1000 first.
      expect(calc.forCp(cp: 5000), closeTo(calc.forCp(cp: 1000), 1e-12));
      expect(calc.forCp(cp: -5000), closeTo(calc.forCp(cp: -1000), 1e-12));
    });

    test('mate +N collapses to 100, mate -N to 0', () {
      expect(calc.forCp(mate: 1), 100.0);
      expect(calc.forCp(mate: 12), 100.0);
      expect(calc.forCp(mate: -1), 0.0);
      expect(calc.forCp(mate: -12), 0.0);
    });

    test('mate dominates cp when both are present', () {
      expect(calc.forCp(cp: -800, mate: 3), 100.0);
      expect(calc.forCp(cp: 800, mate: -3), 0.0);
    });

    test('null cp + null mate falls back to neutral 50', () {
      expect(calc.forCp(), WinPercentCalculator.neutral);
      expect(calc.forCp(), 50.0);
    });

    test('curve is monotonic non-decreasing in cp', () {
      var prev = -1.0;
      for (var cp = -1000; cp <= 1000; cp += 50) {
        final w = calc.forCp(cp: cp);
        expect(w, greaterThanOrEqualTo(prev));
        prev = w;
      }
    });
  });
}

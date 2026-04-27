/// Phase A § 2: canonical perspective normalisation.
///
/// Every conversion between white-POV (canonical engine view) and
/// mover-POV is named, public, and unit-tested here so a future
/// regression like "Black moves classified as White" cannot slip in
/// silently.
library;

import 'package:apex_chess/core/domain/services/win_percent_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const persp = MoverPerspective();

  group('MoverPerspective.sign', () {
    test('White ⇒ +1, Black ⇒ −1', () {
      expect(persp.sign(isWhiteMove: true), 1.0);
      expect(persp.sign(isWhiteMove: false), -1.0);
    });
  });

  group('MoverPerspective.moverWinPercent', () {
    test('White move: mover-POV equals white-POV', () {
      expect(
        persp.moverWinPercent(73.4, isWhiteMove: true),
        closeTo(73.4, 1e-9),
      );
    });
    test('Black move: mover-POV is the complement', () {
      expect(
        persp.moverWinPercent(73.4, isWhiteMove: false),
        closeTo(26.6, 1e-9),
      );
    });
  });

  group('MoverPerspective.moverCp', () {
    test('White move: cp passes through', () {
      expect(persp.moverCp(250, isWhiteMove: true), 250);
    });
    test('Black move: cp flips sign', () {
      expect(persp.moverCp(250, isWhiteMove: false), -250);
    });
  });

  group('MoverPerspective.deltaW', () {
    test('White losing 30 pp reads as ΔW = -30', () {
      expect(
        persp.deltaW(
          whiteWinBefore: 80,
          whiteWinAfter: 50,
          isWhiteMove: true,
        ),
        closeTo(-30, 1e-9),
      );
    });
    test(
        'Black move that drops white-POV from 50 to 20 (Black IMPROVED) '
        'reads as ΔW = +30 from mover-POV', () {
      expect(
        persp.deltaW(
          whiteWinBefore: 50,
          whiteWinAfter: 20,
          isWhiteMove: false,
        ),
        closeTo(30, 1e-9),
      );
    });
    test(
        'Black move that pushes white-POV from 50 to 80 (Black BLUNDERED) '
        'reads as ΔW = -30 from mover-POV', () {
      expect(
        persp.deltaW(
          whiteWinBefore: 50,
          whiteWinAfter: 80,
          isWhiteMove: false,
        ),
        closeTo(-30, 1e-9),
      );
    });
  });

  group('MoverPerspective.cpLoss', () {
    test('White loses 80 cp', () {
      expect(
        persp.cpLoss(
          whiteCpBefore: 120,
          whiteCpAfter: 40,
          isWhiteMove: true,
        ),
        80,
      );
    });
    test('Black loses 80 cp (white-POV moves from -120 to -40)', () {
      expect(
        persp.cpLoss(
          whiteCpBefore: -120,
          whiteCpAfter: -40,
          isWhiteMove: false,
        ),
        80,
      );
    });
    test('null when either side is a mate verdict', () {
      expect(
        persp.cpLoss(
          whiteCpBefore: 120,
          whiteCpAfter: null,
          mateBefore: null,
          mateAfter: 3,
          isWhiteMove: true,
        ),
        isNull,
      );
    });
  });

  group('MoverPerspective.moverForcesMate', () {
    test('White move + mate=+5 ⇒ mover delivers mate', () {
      expect(persp.moverForcesMate(5, isWhiteMove: true), isTrue);
    });
    test('White move + mate=−5 ⇒ mover is being mated', () {
      expect(persp.moverForcesMate(-5, isWhiteMove: true), isFalse);
    });
    test('Black move + mate=−5 ⇒ Black delivers mate', () {
      expect(persp.moverForcesMate(-5, isWhiteMove: false), isTrue);
    });
    test('Black move + mate=+5 ⇒ Black is being mated', () {
      expect(persp.moverForcesMate(5, isWhiteMove: false), isFalse);
    });
    test('null mate ⇒ false (no mate either way)', () {
      expect(persp.moverForcesMate(null, isWhiteMove: true), isFalse);
      expect(persp.moverForcesMate(null, isWhiteMove: false), isFalse);
    });
  });
}

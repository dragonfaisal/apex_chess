/// Phase A regression: every tier that USED to generate a Mistake
/// Vault drill under the old ΔW thresholds must still generate one
/// after the re-classification — including `missedWin`, which
/// silently absorbed plies that previously read as Mistake / Blunder.
library;

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/mistake_vault/data/mistake_vault_save_hook.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isDrillWorthy', () {
    test('Blunder, Mistake, Missed Win ⇒ drill', () {
      expect(isDrillWorthy(MoveQuality.blunder), isTrue);
      expect(isDrillWorthy(MoveQuality.mistake), isTrue);
      expect(isDrillWorthy(MoveQuality.missedWin), isTrue);
    });

    test('Best, Brilliant, Great, Excellent, Good, Inaccuracy, Forced, '
        'Book ⇒ NOT drill', () {
      for (final q in const [
        MoveQuality.best,
        MoveQuality.brilliant,
        MoveQuality.great,
        MoveQuality.excellent,
        MoveQuality.good,
        MoveQuality.inaccuracy,
        MoveQuality.forced,
        MoveQuality.book,
      ]) {
        expect(
          isDrillWorthy(q),
          isFalse,
          reason: '$q should not generate a Mistake Vault drill',
        );
      }
    });
  });
}

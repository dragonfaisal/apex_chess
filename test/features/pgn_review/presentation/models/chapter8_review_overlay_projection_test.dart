import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/entities/move_insight.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/presentation/models/review_board_display.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/chapter7_tactical_causality_corpus.dart';

void main() {
  test(
    'all activated causal families project only persisted board geometry',
    () {
      final corpus = runChapter7TacticalCorpus();
      expect(corpus.failed, 0);
      final visualMechanisms = <MoveInsightMechanismType>{
        MoveInsightMechanismType.fork,
        MoveInsightMechanismType.doubleAttack,
        MoveInsightMechanismType.absolutePin,
        MoveInsightMechanismType.skewer,
        MoveInsightMechanismType.discoveredAttack,
        MoveInsightMechanismType.opensLine,
        MoveInsightMechanismType.removesDefender,
        MoveInsightMechanismType.soundSacrifice,
        MoveInsightMechanismType.unsoundSacrifice,
      };
      var projected = 0;
      for (final result in corpus.results) {
        final mechanism =
            result.insight.primaryClaim?.mechanism ??
            MoveInsightMechanismType.none;
        if (!result.insight.isDisplayable ||
            !visualMechanisms.contains(mechanism)) {
          continue;
        }
        final input = result.input;
        final move = MoveAnalysis(
          ply: 0,
          san: input.playedMoveSan,
          uci: input.playedMoveUci,
          fenBefore: input.fenBefore,
          fenAfter: input.fenAfter,
          targetSquare: input.playedMoveUci.substring(2, 4),
          winPercentBefore: 50,
          winPercentAfter: 50,
          deltaW: 0,
          isWhiteMove: input.isWhiteMove,
          classification: input.classification,
          classificationEvidence: input.classificationEvidence,
          engineBestMoveUci: input.classificationEvidence.bestMoveUci,
          engineBestMoveSan: input.engineBestMoveSan,
          message: input.classification.name,
          insight: result.insight,
        );
        final timeline = AnalysisTimeline(
          moves: [move],
          startingFen: input.fenBefore,
          headers: const <String, String>{},
          winPercentages: const <double>[50],
          analysisSchemaVersion: kApexAnalysisSchemaVersion,
          explanationPolicyVersion: kApexExplanationPolicyVersion,
          explanationClaimSchemaVersion: kApexExplanationClaimSchemaVersion,
          explanationRendererVersion: kApexExplanationRendererVersion,
        );
        final display = ReviewBoardDisplayModel.fromTimeline(
          timeline,
          currentPly: 0,
          flipped: !input.isWhiteMove,
          mode: AnalysisMode.deep,
          userIsWhite: input.isWhiteMove,
        );

        expect(
          display.mechanism,
          isNotNull,
          reason: '${result.spec.id} must expose its persisted mechanism',
        );
        expect(
          display.boardOverlay,
          isNotNull,
          reason: '${result.spec.id} must project supported persisted squares',
        );
        expect(
          display.boardOverlay!.semanticLabel,
          contains(display.mechanism!.label),
        );
        expect(display.bestMoveArrow, isNull);
        projected++;
      }
      expect(projected, greaterThanOrEqualTo(9));
    },
  );
}

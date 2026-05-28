import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

const _startFen =
    'rn1qkbnr/ppp2ppp/3b4/3pp3/4P3/2NP1N2/PPP2PPP/R1BQKB1R w KQkq - 2 5';

void main() {
  group('LocalSmartAnalysisScheduler static planning', () {
    test('opening-known input returns skipOpening without engine work', () {
      const scheduler = LocalSmartAnalysisScheduler();

      final decision = scheduler.plan(
        const LocalAnalysisPositionInput(fen: _startFen, isOpeningKnown: true),
      );

      expect(decision.type, LocalSchedulerDecisionType.skipOpening);
      expect(decision.engineRequired, isFalse);
      expect(decision.steps, isEmpty);
      expect(decision.reasons, contains(LocalSchedulerReasonCode.openingKnown));
    });

    test('only-legal-move input returns skipForced without engine work', () {
      const scheduler = LocalSmartAnalysisScheduler();

      final decision = scheduler.plan(
        const LocalAnalysisPositionInput(fen: _startFen, isOnlyLegalMove: true),
      );

      expect(decision.type, LocalSchedulerDecisionType.skipForced);
      expect(decision.engineRequired, isFalse);
      expect(decision.steps, isEmpty);
      expect(
        decision.reasons,
        contains(LocalSchedulerReasonCode.onlyLegalMove),
      );
    });

    test('invalid FEN is rejected before any engine decision', () {
      const scheduler = LocalSmartAnalysisScheduler();

      final decision = scheduler.plan(
        const LocalAnalysisPositionInput(fen: '8/8/8 w'),
      );

      expect(decision.type, LocalSchedulerDecisionType.rejectInvalidFen);
      expect(decision.engineRequired, isFalse);
      expect(decision.steps, isEmpty);
      expect(decision.reasons, contains(LocalSchedulerReasonCode.invalidFen));
    });
  });

  group('LocalSmartAnalysisScheduler profiles and budgets', () {
    test('balanced quiet position returns a safe fast pass', () {
      const scheduler = LocalSmartAnalysisScheduler();

      final decision = scheduler.plan(
        const LocalAnalysisPositionInput(fen: _startFen, legalMoveCount: 24),
      );

      expect(decision.type, LocalSchedulerDecisionType.fastPassOnly);
      expect(decision.engineRequired, isTrue);
      expect(decision.requestedDepth, 12);
      expect(decision.requestedMovetime, const Duration(milliseconds: 100));
      expect(decision.requestedMultiPv, 1);
      expect(decision.withinSafetyBudget, isTrue);
    });

    test('eco profile reduces movetime, depth, and MultiPV', () {
      const scheduler = LocalSmartAnalysisScheduler(
        profile: LocalSchedulerProfile.eco,
      );

      final decision = scheduler.plan(
        const LocalAnalysisPositionInput(
          fen: _startFen,
          legalMoveCount: 40,
          candidateEvalSpreadCp: 250,
          givesCheck: true,
        ),
      );

      expect(decision.engineRequired, isTrue);
      expect(decision.type, LocalSchedulerDecisionType.fastPassOnly);
      expect(decision.requestedDepth, lessThan(12));
      expect(decision.requestedMovetime!.inMilliseconds, lessThanOrEqualTo(50));
      expect(decision.requestedMultiPv, 1);
      expect(decision.withinSafetyBudget, isTrue);
    });

    test('performance profile allows a stronger budget than balanced', () {
      final balanced = const LocalSmartAnalysisScheduler().plan(
        const LocalAnalysisPositionInput(fen: _startFen),
      );
      final performance = const LocalSmartAnalysisScheduler(
        profile: LocalSchedulerProfile.performance,
      ).plan(const LocalAnalysisPositionInput(fen: _startFen));

      expect(performance.requestedDepth, greaterThan(balanced.requestedDepth!));
      expect(
        performance.requestedMovetime!.inMilliseconds,
        greaterThan(balanced.requestedMovetime!.inMilliseconds),
      );
      expect(performance.withinSafetyBudget, isTrue);
    });

    test('owner profile has the strongest finite local caps', () {
      expect(
        LocalSchedulerProfile.owner.maxDepth,
        greaterThan(LocalSchedulerProfile.performance.maxDepth),
      );
      expect(
        LocalSchedulerProfile.owner.deepMovetime.inMilliseconds,
        greaterThan(
          LocalSchedulerProfile.performance.deepMovetime.inMilliseconds,
        ),
      );
      expect(LocalSchedulerProfile.owner.maxDepth, lessThanOrEqualTo(20));
      expect(
        LocalSchedulerProfile.owner.deepMovetime.inMilliseconds,
        lessThanOrEqualTo(1500),
      );
      expect(LocalSchedulerProfile.owner.maxMultiPv, 3);
    });

    test('low-power flag forces lowPowerFastOnly with reduced budget', () {
      const scheduler = LocalSmartAnalysisScheduler(
        profile: LocalSchedulerProfile.owner,
      );

      final decision = scheduler.plan(
        const LocalAnalysisPositionInput(
          fen: _startFen,
          legalMoveCount: 45,
          candidateEvalSpreadCp: 400,
          lowPowerMode: true,
        ),
      );

      expect(decision.type, LocalSchedulerDecisionType.lowPowerFastOnly);
      expect(decision.requestedDepth, lessThanOrEqualTo(8));
      expect(decision.requestedMovetime!.inMilliseconds, lessThanOrEqualTo(50));
      expect(decision.requestedMultiPv, 1);
      expect(decision.safetyBudget.thermalSafeMode, isTrue);
      expect(decision.withinSafetyBudget, isTrue);
    });

    test('no planned search exceeds its profile safety budget', () {
      const inputs = [
        LocalAnalysisPositionInput(fen: _startFen),
        LocalAnalysisPositionInput(
          fen: _startFen,
          legalMoveCount: 40,
          candidateEvalSpreadCp: 150,
        ),
        LocalAnalysisPositionInput(
          fen: _startFen,
          materialDeltaAfterMoveCp: -320,
          isCapture: true,
        ),
        LocalAnalysisPositionInput(
          fen: _startFen,
          lowPowerMode: true,
          candidateEvalSpreadCp: 300,
        ),
      ];

      for (final profile in LocalSchedulerProfile.values) {
        final scheduler = LocalSmartAnalysisScheduler(profile: profile);
        for (final input in inputs) {
          final decision = scheduler.plan(input);
          expect(
            decision.withinSafetyBudget,
            isTrue,
            reason: '${profile.id.wire}: ${decision.debugSummary}',
          );
        }
      }
    });
  });

  group('LocalSmartAnalysisScheduler complexity decisions', () {
    test('material sacrifice signal plans deep reanalysis', () {
      const scheduler = LocalSmartAnalysisScheduler();

      final decision = scheduler.plan(
        const LocalAnalysisPositionInput(
          fen: _startFen,
          isCapture: true,
          materialDeltaAfterMoveCp: -250,
        ),
      );

      expect(decision.type, LocalSchedulerDecisionType.deepReanalysis);
      expect(
        decision.primaryStep!.kind,
        LocalEngineSearchStepKind.deepReanalysis,
      );
      expect(decision.requestedMultiPv, 3);
      expect(
        decision.reasons,
        contains(LocalSchedulerReasonCode.materialSacrifice),
      );
    });

    test('large eval spread plans MultiPV probe before deep threshold', () {
      const scheduler = LocalSmartAnalysisScheduler();

      final decision = scheduler.plan(
        const LocalAnalysisPositionInput(
          fen: _startFen,
          legalMoveCount: 32,
          candidateEvalSpreadCp: 150,
        ),
      );

      expect(decision.type, LocalSchedulerDecisionType.multipvProbe);
      expect(
        decision.primaryStep!.kind,
        LocalEngineSearchStepKind.multipvProbe,
      );
      expect(decision.requestedMultiPv, 2);
      expect(
        decision.reasons,
        contains(LocalSchedulerReasonCode.largeEvalSpread),
      );
    });

    test('normal quiet position does not request MultiPV 3', () {
      const scheduler = LocalSmartAnalysisScheduler();

      final decision = scheduler.plan(
        const LocalAnalysisPositionInput(fen: _startFen, legalMoveCount: 18),
      );

      expect(decision.type, LocalSchedulerDecisionType.fastPassOnly);
      expect(decision.requestedMultiPv, 1);
      expect(decision.steps.any((step) => step.multiPv == 3), isFalse);
    });

    test('critical complex position may request MultiPV 3', () {
      const scheduler = LocalSmartAnalysisScheduler();

      final decision = scheduler.plan(
        const LocalAnalysisPositionInput(
          fen: _startFen,
          legalMoveCount: 38,
          candidateEvalSpreadCp: 260,
          givesCheck: true,
        ),
      );

      expect(decision.type, LocalSchedulerDecisionType.deepReanalysis);
      expect(decision.requestedMultiPv, 3);
      expect(decision.withinSafetyBudget, isTrue);
    });

    test('suspicious tactical signal can reserve gated deep budget', () {
      const scheduler = LocalSmartAnalysisScheduler();

      final decision = scheduler.plan(
        const LocalAnalysisPositionInput(
          fen: _startFen,
          givesCheck: true,
          legalMoveCount: 12,
        ),
      );

      expect(decision.type, LocalSchedulerDecisionType.fastPassThenMaybeDeep);
      expect(decision.steps, hasLength(2));
      expect(decision.steps.first.kind, LocalEngineSearchStepKind.fastPass);
      expect(decision.steps.last.gatedByPriorResult, isTrue);
      expect(decision.steps.last.multiPv, 1);
    });
  });

  group('LocalSmartAnalysisScheduler determinism and source guardrails', () {
    test('planning is pure and deterministic', () {
      const scheduler = LocalSmartAnalysisScheduler(
        profile: LocalSchedulerProfile.performance,
      );
      const input = LocalAnalysisPositionInput(
        fen: _startFen,
        legalMoveCount: 36,
        previousEvalCp: 40,
        provisionalEvalCp: -190,
      );

      final first = scheduler.plan(input);
      final second = scheduler.plan(input);

      expect(second.type, first.type);
      expect(second.debugSummary, first.debugSummary);
      expect(second.withinSafetyBudget, isTrue);
    });

    test('scheduler source stays local, pure, and boundary-safe', () {
      final source = File(
        'lib/features/pgn_review/application/local_smart_analysis_scheduler.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('package:flutter/')));
      expect(source, isNot(contains('Widget')));
      expect(source, isNot(contains('online_review_staging_preflight')));
      expect(source, isNot(contains('preflight')));
      expect(source, isNot(contains('server')));
      expect(source, isNot(contains('backend')));
      expect(source, isNot(contains('LocalEvalService')));
      expect(source, isNot(contains('ChessEngine')));
      expect(source, isNot(contains('MoveQuality')));
      expect(source, isNot(contains('Brilliant')));
      expect(source, isNot(contains('Great')));
      expect(source, isNot(contains('Miss')));
      expect(source, isNot(contains('ACPL')));
      expect(source, isNot(contains('accuracy')));
      expect(source, isNot(contains('Chesskit')));
      expect(source, isNot(contains('DroidFish')));
      expect(source, isNot(contains('StockfishForFlutter')));
      expect(source, isNot(contains('python-chess')));
    });
  });
}

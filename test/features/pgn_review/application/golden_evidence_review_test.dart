import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_review.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoldenEvidenceReview defaults and metadata', () {
    test('default review includes all v1 golden cases', () {
      final result = const GoldenEvidenceReviewRunner().review(
        const GoldenEvidenceReviewRequest(),
      );

      expect(result.totalCases, GoldenAnalysisCases.defaults.length);
      expect(
        result.caseReviews.map((review) => review.caseId),
        containsAll(GoldenAnalysisCases.defaults.map((item) => item.id)),
      );
    });

    test('safe metadata cases pass metadata review', () {
      final result = const GoldenEvidenceReviewRunner().review(
        const GoldenEvidenceReviewRequest(
          mode: GoldenEvidenceReviewMode.metadataOnly,
        ),
      );

      expect(result.status, GoldenEvidenceReviewStatus.passed);
      expect(
        result.caseReviews.every(
          (review) => review.status == GoldenEvidenceReviewStatus.passed,
        ),
        isTrue,
      );
    });

    test('duplicate cases fail review instead of passing silently', () {
      final item = _caseById('quiet-opening-skip');

      final result = const GoldenEvidenceReviewRunner().review(
        GoldenEvidenceReviewRequest(
          cases: [item, item],
          mode: GoldenEvidenceReviewMode.metadataOnly,
        ),
      );

      expect(result.status, isNot(GoldenEvidenceReviewStatus.passed));
      expect(result.failed, greaterThan(0));
    });

    test('unsafe and final-claim cases are blocked', () {
      final unsafe = _caseById('quiet-opening-skip').copyWith(
        id: 'unsafe-case',
        safety: const GoldenAnalysisSafetyFlags(licenseSafe: false),
      );
      final finalClaim = GoldenAnalysisCase(
        id: 'blocked-claim',
        title: 'Blocked Brilliant claim',
        category: GoldenAnalysisCategory.tacticalShot,
        sourceType: GoldenAnalysisSourceType.fenPosition,
        fen: _fen,
        inputs: const [LocalAnalysisPositionInput(fen: _fen, givesCheck: true)],
        motifTags: const [GoldenMotifTag.forcingLine],
        expected: const GoldenExpectedBehavior(
          behaviors: {GoldenExpectedBehaviorCode.shouldNotEmitFinalLabel},
        ),
      );

      final result = const GoldenEvidenceReviewRunner().review(
        GoldenEvidenceReviewRequest(
          cases: [unsafe, finalClaim],
          mode: GoldenEvidenceReviewMode.metadataOnly,
        ),
      );

      expect(result.status, GoldenEvidenceReviewStatus.blockedUnsafeClaim);
      expect(result.blockedUnsafeClaims, 2);
    });
  });

  group('GoldenEvidenceReview readiness', () {
    test('invalid FEN case passes reject expectation', () {
      final review = _reviewSingle('invalid-fen-safety');

      expect(review.status, GoldenEvidenceReviewStatus.passed);
      expect(
        review.expectedSuppressionsSatisfied,
        contains(DeepCandidateReasonCode.invalidFenSuppressed),
      );
    });

    test('opening skip case passes no-deep expectation', () {
      final review = _reviewSingle('quiet-opening-skip');

      expect(review.status, GoldenEvidenceReviewStatus.passed);
      expect(
        review.expectedSuppressionsSatisfied,
        contains(DeepCandidateReasonCode.openingSuppressed),
      );
    });

    test('forced skip case passes forced suppression expectation', () {
      final review = _reviewSingle('forced-move-skip');

      expect(review.status, GoldenEvidenceReviewStatus.passed);
      expect(
        review.expectedSuppressionsSatisfied,
        contains(DeepCandidateReasonCode.forcedSuppressed),
      );
    });

    test('tactical case passes when evidence has tactical reason', () {
      final review = _reviewSingle('simple-tactical-capture-check');

      expect(review.status, GoldenEvidenceReviewStatus.passed);
      expect(
        review.satisfiedReasonCodes,
        contains(DeepCandidateReasonCode.tacticalSignal),
      );
    });

    test('tactical case is incomplete when evidence is missing', () {
      final weakTactical = _caseById('simple-tactical-capture-check').copyWith(
        id: 'weak-tactical-evidence',
        inputs: const [LocalAnalysisPositionInput(fen: _fen)],
      );

      final result = const GoldenEvidenceReviewRunner().review(
        GoldenEvidenceReviewRequest(cases: [weakTactical]),
      );

      expect(
        result.caseReviews.single.status,
        GoldenEvidenceReviewStatus.incompleteEvidence,
      );
      expect(result.incomplete, 1);
    });

    test('material sacrifice case requires material evidence', () {
      final review = _reviewSingle('material-sacrifice-compensation');

      expect(review.status, GoldenEvidenceReviewStatus.passed);
      expect(
        review.satisfiedReasonCodes,
        contains(DeepCandidateReasonCode.materialSwing),
      );
    });

    test('mate-threat case requires mate and tactical evidence', () {
      final review = _reviewSingle('mate-threat-fast-evidence');

      expect(review.status, GoldenEvidenceReviewStatus.needsRealEngineEvidence);
      expect(
        review.satisfiedReasonCodes,
        contains(DeepCandidateReasonCode.mateScoreDetected),
      );
      expect(
        review.satisfiedReasonCodes,
        contains(DeepCandidateReasonCode.tacticalSignal),
      );
      expect(review.realEngineEvidenceNeeded, isTrue);
    });

    test('budget pressure case requires suppression visibility', () {
      final review = _reviewSingle('budget-pressure-candidates');

      expect(review.status, GoldenEvidenceReviewStatus.passed);
      expect(
        review.expectedSuppressionsSatisfied,
        contains(DeepCandidateReasonCode.budgetSuppressed),
      );
      expect(
        review.budgetExpectationStatus,
        GoldenEvidenceBudgetStatus.satisfied,
      );
    });

    test('quiet preparatory case does not fake certainty', () {
      final review = _reviewSingle('quiet-preparatory-uncertain');

      expect(review.status, GoldenEvidenceReviewStatus.passed);
      expect(review.satisfiedReasonCodes, isEmpty);
      expect(review.missingReasonCodes, isEmpty);
    });

    test('endgame case remains conservative without evidence', () {
      final review = _reviewSingle('technical-endgame-conservative');

      expect(review.status, GoldenEvidenceReviewStatus.passed);
      expect(review.satisfiedReasonCodes, isEmpty);
      expect(review.missingReasonCodes, isEmpty);
    });

    test('real-device reference mode marks cases needing future proof', () {
      final result = const GoldenEvidenceReviewRunner().review(
        GoldenEvidenceReviewRequest(
          cases: [_caseById('mate-threat-fast-evidence')],
          mode: GoldenEvidenceReviewMode.realDeviceEvidenceReferenceOnly,
          requireAllEvidence: true,
        ),
      );

      expect(result.status, GoldenEvidenceReviewStatus.needsRealEngineEvidence);
      expect(result.needsRealDeviceEvidenceCount, 1);
      expect(result.realDeviceEvidenceCommand, contains('flutter test'));
    });
  });

  group('GoldenEvidenceReview report and guardrails', () {
    test('report is deterministic and includes coverage', () {
      final result = const GoldenEvidenceReviewRunner().review(
        const GoldenEvidenceReviewRequest(),
      );

      expect(result.renderMarkdownReport(), result.renderMarkdownReport());
      expect(result.renderMarkdownReport(), contains('Motif Coverage'));
      expect(result.renderMarkdownReport(), contains('Category Coverage'));
    });

    test('report contains no raw UCI spam or PV dumps', () {
      final report = const GoldenEvidenceReviewRunner()
          .review(const GoldenEvidenceReviewRequest())
          .renderMarkdownReport();

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains(' pv ')));
    });

    test('report contains no product labels or official metric text', () {
      final report = const GoldenEvidenceReviewRunner()
          .review(const GoldenEvidenceReviewRequest())
          .renderMarkdownReport();

      expect(report, isNot(contains('Brilliant')));
      expect(report, isNot(contains('Great')));
      expect(report, isNot(contains('Miss')));
      expect(report, isNot(contains('ACPL')));
      expect(report, isNot(contains('official accuracy')));
    });

    test('source guardrails stay pure and local-only', () {
      expect(_reviewSource, isNot(contains('Stockfish')));
      expect(_reviewSource, isNot(contains('stockfish_bridge')));
      expect(_reviewSource, isNot(contains('dart:ffi')));
      expect(_reviewSource, isNot(contains('native')));
      expect(_reviewSource, isNot(contains('Widget')));
      expect(_reviewSource, isNot(contains('flutter/material')));
      expect(_reviewSource, isNot(contains('backend')));
      expect(_reviewSource, isNot(contains('preflight')));
      expect(_reviewSource, isNot(contains('server')));
      expect(_reviewSource, isNot(contains('database')));
      expect(_reviewSource, isNot(contains('cache')));
    });
  });
}

GoldenEvidenceCaseReview _reviewSingle(String id) {
  final result = const GoldenEvidenceReviewRunner().review(
    GoldenEvidenceReviewRequest(cases: [_caseById(id)]),
  );
  expect(result.caseReviews, hasLength(1));
  return result.caseReviews.single;
}

GoldenAnalysisCase _caseById(String id) {
  return GoldenAnalysisCases.defaults.singleWhere((item) => item.id == id);
}

String get _reviewSource => File(
  'lib/features/pgn_review/application/golden_evidence_review.dart',
).readAsStringSync();

const _fen =
    'rn1qkbnr/ppp2ppp/3b4/3pp3/4P3/2NP1N2/PPP2PPP/R1BQKB1R w KQkq - 2 5';

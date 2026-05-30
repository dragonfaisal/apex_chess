@TestOn('vm')
library;

import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/quiet_preparatory_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuietPreparatoryEvidence model', () {
    test('supports candidate spread plus future tactical threat', () {
      final evidence = const QuietPreparatoryEvidence(
        candidateSpreadPresent: true,
        futureTacticalThreatPrepared: true,
        noImmediateCaptureCheckPromotion: true,
      );

      expect(
        evidence.supportGroups,
        contains(
          QuietPreparatoryEvidenceSupportGroup.candidateSpreadFutureThreat,
        ),
      );
    });

    test('supports opponent threat reduction with positional signal', () {
      final evidence = const QuietPreparatoryEvidence(
        opponentThreatReduced: true,
        keySquareControlImproved: true,
        noImmediateCaptureCheckPromotion: true,
      );

      expect(
        evidence.supportGroups,
        contains(QuietPreparatoryEvidenceSupportGroup.threatReduction),
      );
      expect(
        evidence.supportGroups,
        contains(QuietPreparatoryEvidenceSupportGroup.kingSafetyOrPositional),
      );
    });

    test('supports king-safety and positional support', () {
      final evidence = const QuietPreparatoryEvidence(
        kingSafetyImproved: true,
        pieceActivityImproved: true,
        noImmediateCaptureCheckPromotion: true,
      );

      expect(
        evidence.supportGroups,
        contains(QuietPreparatoryEvidenceSupportGroup.kingSafetyOrPositional),
      );
    });

    test('supports forcing-line enabled next', () {
      final evidence = const QuietPreparatoryEvidence(
        forcingLineEnabledNext: true,
        noImmediateCaptureCheckPromotion: true,
      );

      expect(
        evidence.supportGroups,
        contains(QuietPreparatoryEvidenceSupportGroup.forcingLineEnabledNext),
      );
    });

    test('supports endgame plan and clear alternative weakness', () {
      final evidence = const QuietPreparatoryEvidence(
        passedPawnOrEndgamePlanImproved: true,
        alternativeMovesAreClearlyWorse: true,
        noImmediateCaptureCheckPromotion: true,
      );

      expect(
        evidence.supportGroups,
        contains(QuietPreparatoryEvidenceSupportGroup.endgamePlan),
      );
      expect(
        evidence.supportGroups,
        contains(QuietPreparatoryEvidenceSupportGroup.alternativeWeakness),
      );
    });
  });

  group('GoldenQuietPreparatoryEvidencePolicy', () {
    const policy = GoldenQuietPreparatoryEvidencePolicy();

    test('quiet tags alone do not protect a case', () {
      final assessment = policy.assess(
        isQuietPreparatory: true,
        evidence: const QuietPreparatoryEvidence(),
      );

      expect(
        assessment.status,
        QuietPreparatoryEvidenceStatus.unsupportedQuietMove,
      );
      expect(assessment.isProtectedForReview, isFalse);
    });

    test('unsupported quiet move remains incomplete evidence', () {
      final assessment = policy.assess(
        isQuietPreparatory: true,
        evidence: const QuietPreparatoryEvidence(
          uncertaintyReason: 'support intentionally absent',
        ),
      );

      expect(
        assessment.status,
        QuietPreparatoryEvidenceStatus.incompleteQuietEvidence,
      );
      expect(assessment.isIncomplete, isTrue);
      expect(assessment.blockers, contains('support intentionally absent'));
    });

    test('supported quiet hard case can become protected', () {
      final assessment = policy.assess(
        isQuietPreparatory: true,
        evidence: const QuietPreparatoryEvidence(
          candidateSpreadPresent: true,
          futureTacticalThreatPrepared: true,
          keySquareControlImproved: true,
          forcingLineEnabledNext: true,
          noImmediateCaptureCheckPromotion: true,
        ),
      );

      expect(
        assessment.status,
        QuietPreparatoryEvidenceStatus.quietEvidenceProtected,
      );
      expect(assessment.isProtectedForReview, isTrue);
      expect(assessment.supportGroups, hasLength(3));
    });

    test('single support group is internal evidence only', () {
      final assessment = policy.assess(
        isQuietPreparatory: true,
        evidence: const QuietPreparatoryEvidence(
          forcingLineEnabledNext: true,
          noImmediateCaptureCheckPromotion: true,
        ),
      );

      expect(
        assessment.status,
        QuietPreparatoryEvidenceStatus.fakeEvidenceSupported,
      );
      expect(assessment.isProtectedForReview, isTrue);
    });

    test('PV or MultiPV requirement becomes real engine evidence need', () {
      final assessment = policy.assess(
        isQuietPreparatory: true,
        evidence: const QuietPreparatoryEvidence(
          quietMoveHasPvSupport: true,
          quietMoveHasMultiPvSupport: true,
          requiresRealDeviceProof: true,
          noImmediateCaptureCheckPromotion: true,
        ),
      );

      expect(
        assessment.status,
        QuietPreparatoryEvidenceStatus.needsRealDeviceProof,
      );
      expect(assessment.requiresRealDeviceProof, isTrue);
      expect(assessment.isProtectedForReview, isFalse);
    });

    test('contradictory quiet evidence becomes mismatch', () {
      final assessment = policy.assess(
        isQuietPreparatory: true,
        evidence: const QuietPreparatoryEvidence(
          candidateSpreadPresent: true,
          futureTacticalThreatPrepared: true,
          contradictionReasons: ['contradictory quiet evidence'],
          noImmediateCaptureCheckPromotion: true,
        ),
      );

      expect(
        assessment.status,
        QuietPreparatoryEvidenceStatus.quietEvidenceMismatch,
      );
      expect(assessment.isMismatch, isTrue);
    });

    test('quiet evidence must confirm no immediate forcing move', () {
      final assessment = policy.assess(
        isQuietPreparatory: true,
        evidence: const QuietPreparatoryEvidence(
          candidateSpreadPresent: true,
          futureTacticalThreatPrepared: true,
        ),
      );

      expect(
        assessment.status,
        QuietPreparatoryEvidenceStatus.quietEvidenceMismatch,
      );
      expect(assessment.blockers.join('\n'), contains('no immediate capture'));
    });

    test('source stays pure and local-only', () {
      final source = File(
        'lib/features/pgn_review/application/quiet_preparatory_evidence.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('Stockfish')));
      expect(source, isNot(contains('stockfish_bridge')));
      expect(source, isNot(contains('dart:ffi')));
      expect(source, isNot(contains('LocalEvalService')));
      expect(source, isNot(contains('Widget')));
      expect(source, isNot(contains('flutter/material')));
      expect(source, isNot(contains('backend')));
      expect(source, isNot(contains('preflight')));
      expect(source, isNot(contains('server')));
      expect(source, isNot(contains('database')));
      expect(source, isNot(contains('cache')));
    });
  });
}

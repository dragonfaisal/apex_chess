@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_review.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/targeted_golden_coverage_impact_review.dart';
import 'package:flutter_test/flutter_test.dart';

TargetedGoldenCoverageImpactReviewResult? _cachedReview;
GoldenEvidenceReviewResult? _cachedEvidenceReview;

void main() {
  setUpAll(() {
    _cachedReview = _buildReview();
    _cachedEvidenceReview = _buildGoldenEvidenceReview();
  });

  group('TargetedGoldenCoverageImpactReview safe demo', () {
    test('consumes post-32E Golden suite and detects exact case counts', () {
      final result = _review();

      expect(result.totalGoldenCases, 20);
      expect(result.totalGoldenCases, GoldenAnalysisCases.defaults.length);
      expect(result.protectedCount, 19);
      expect(result.negativeGuardCount, 1);
      expect(result.newCaseCount, 5);
      expect(result.ownerProofQueueCount, 0);
      expect(result.unsafeCaseCount, 0);
      expect(result.safeForPhase32G, isTrue);
      expect(
        result.impactStatus,
        isIn(<TargetedGoldenCoverageImpactStatus>[
          TargetedGoldenCoverageImpactStatus.coverageImproved,
          TargetedGoldenCoverageImpactStatus.coverageImprovedWithWarnings,
        ]),
      );
    });

    test('existing 15 cases remain present and new 5 IDs are detected', () {
      final ids = GoldenAnalysisCases.defaults.map((item) => item.id).toSet();
      final result = _review();

      expect(ids, containsAll(_existingPhase32EInputIds));
      expect(result.newSupportCaseIds, orderedEquals(_phase32ECaseIdsSorted));
      expect(
        result.caseImpactRows.map((row) => row.caseId),
        orderedEquals(_phase32ECaseIdsSorted),
      );
    });

    test('quiet-preparatory-uncertain remains the only negative guard', () {
      final result = _review();
      final negativeGuardIds = _goldenEvidenceReview().caseReviews
          .where(
            (review) =>
                review.status == GoldenEvidenceReviewStatus.negativeGuard,
          )
          .map((review) => review.caseId)
          .toList();

      expect(negativeGuardIds, orderedEquals(['quiet-preparatory-uncertain']));
      expect(result.negativeGuardCount, 1);
      expect(
        result
            .targetImpact(
              InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
            )
            .stillBlocked,
        isTrue,
      );
    });

    test(
      'Android proof IDs remain the original three and no 32E case claims proof',
      () {
        final result = _review();

        expect(result.androidProofCaseIds, _provenAndroidIds);
        for (final row in result.caseImpactRows) {
          expect(row.androidProofClaimed, isFalse, reason: row.caseId);
          expect(result.androidProofCaseIds, isNot(contains(row.caseId)));
        }
      },
    );

    test('owner proof queue remains empty by default', () {
      final result = _review();

      expect(result.ownerProofQueueCount, 0);
      expect(
        result.caseImpactRows.any((row) => row.ownerProofRequired),
        isFalse,
      );
    });

    test(
      'aggregate impact behavior and Phase 32G recommendation are deterministic',
      () {
        final first = _review();
        final second = _review();

        expect(first.improvedTargetCount, second.improvedTargetCount);
        expect(first.improvedTargetCount, 8);
        expect(first.stillWarningLimitedCount, 4);
        expect(first.blockedScopeCount, 10);
        expect(first.newSupportCaseIds, second.newSupportCaseIds);
        expect(
          first.phase32GRecommendation,
          TargetedGoldenCoveragePhase32GRecommendation
              .refreshInternalPacketHardeningPlanFromCoverageImpact,
        );
      },
    );
  });

  group('TargetedGoldenCoverageImpactReview case impacts', () {
    test('king-safety 32E case improves king-safety impact', () {
      final row = _review().caseImpact('king-safety-mating-net-pressure-32e');

      expect(
        row.impactStatus,
        TargetedGoldenCoverageImpactStatus.coverageImproved,
      );
      expect(row.targetArea, contains('king-safety'));
      expect(row.targetArea, contains('mating-net'));
      expect(
        row.affectedPacketScopes,
        contains(
          InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
        ),
      );
      expect(
        row.affectedPacketScopes,
        contains(
          InternalNonLabelPrototypeScopeId
              .candidateSpreadInternalPrototypeScope,
        ),
      );
    });

    test('endgame 32E case improves endgame impact', () {
      final row = _review().caseImpact(
        'endgame-precision-candidate-spread-32e',
      );

      expect(
        row.impactStatus,
        TargetedGoldenCoverageImpactStatus.coverageImproved,
      );
      expect(row.targetArea, 'endgame precision coverage');
      expect(row.motifs, contains('endgamePrecision'));
      expect(
        row.affectedPacketScopes,
        contains(
          InternalNonLabelPrototypeScopeId.endgameInternalPrototypeScope,
        ),
      );
    });

    test('suppression 32E case improves forced suppression impact', () {
      final row = _review().caseImpact('suppression-forced-only-legal-32e');

      expect(row.targetArea, contains('suppression safety'));
      expect(row.supportContribution, contains('forced suppression'));
      expect(row.motifs, contains('onlyMove'));
      expect(
        row.affectedPacketScopes,
        contains(
          InternalNonLabelPrototypeScopeId
              .suppressionSafetyInternalPrototypeScope,
        ),
      );
    });

    test('budget 32E case improves budget pressure impact', () {
      final result = _review();
      final row = result.caseImpact('budget-pressure-wide-candidate-32e');
      final target = result.targetImpact(
        InternalNonLabelPrototypeScopeId.budgetRiskInternalPrototypeScope,
      );

      expect(row.targetArea, 'budget pressure coverage');
      expect(row.supportContribution, contains('budget pressure'));
      expect(target.improved, isTrue);
      expect(
        target.newSupportCaseIds,
        contains('budget-pressure-wide-candidate-32e'),
      );
    });

    test(
      'PV and MultiPV 32E case improves boundary impact without proof claim',
      () {
        final result = _review();
        final row = result.caseImpact('pv-multipv-support-boundary-32e');
        final target = result.targetImpact(
          InternalNonLabelPrototypeScopeId
              .pvMultiPvSupportInternalPrototypeScope,
        );

        expect(row.targetArea, contains('PV/MultiPV'));
        expect(row.androidProofClaimed, isFalse);
        expect(row.ownerProofRequired, isFalse);
        expect(target.improved, isTrue);
        expect(
          target.newSupportCaseIds,
          contains('pv-multipv-support-boundary-32e'),
        );
      },
    );
  });

  group('TargetedGoldenCoverageImpactReview target impacts', () {
    test(
      'stable packet targets remain preserved while support broadens where applicable',
      () {
        final result = _review();

        expect(
          result
              .targetImpact(
                InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
              )
              .currentActionAfter32E,
          'preserveStablePacket',
        );
        expect(
          result
              .targetImpact(
                InternalNonLabelPrototypeScopeId
                    .materialSwingInternalPrototypeScope,
              )
              .currentActionAfter32E,
          'preserveStablePacket',
        );
        expect(
          result
              .targetImpact(
                InternalNonLabelPrototypeScopeId
                    .forcingLineInternalPrototypeScope,
              )
              .newSupportCaseIds,
          containsAll(<String>[
            'king-safety-mating-net-pressure-32e',
            'suppression-forced-only-legal-32e',
            'budget-pressure-wide-candidate-32e',
          ]),
        );
        expect(
          result
              .targetImpact(
                InternalNonLabelPrototypeScopeId
                    .candidateSpreadInternalPrototypeScope,
              )
              .newSupportCaseIds,
          containsAll(<String>[
            'king-safety-mating-net-pressure-32e',
            'endgame-precision-candidate-spread-32e',
            'pv-multipv-support-boundary-32e',
          ]),
        );
      },
    );

    test('warning-limited scopes remain visible after improved support', () {
      final result = _review();

      for (final scope in const <InternalNonLabelPrototypeScopeId>[
        InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
        InternalNonLabelPrototypeScopeId.endgameInternalPrototypeScope,
        InternalNonLabelPrototypeScopeId
            .suppressionSafetyInternalPrototypeScope,
        InternalNonLabelPrototypeScopeId.budgetRiskInternalPrototypeScope,
      ]) {
        final target = result.targetImpact(scope);
        expect(target.improved, isTrue, reason: scope.wire);
        expect(target.stillWarningLimited, isTrue, reason: scope.wire);
        expect(
          target.recommendation,
          TargetedGoldenCoverageImpactRecommendation.keepWarningLimited,
          reason: scope.wire,
        );
      }
    });

    test('blocked and future-only scopes remain blocked', () {
      final result = _review();

      for (final scope in const <InternalNonLabelPrototypeScopeId>[
        InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
        InternalNonLabelPrototypeScopeId.productLabelPrototypeScope,
        InternalNonLabelPrototypeScopeId.advancedLabelPrototypeScope,
        InternalNonLabelPrototypeScopeId.officialMetricPrototypeScope,
        InternalNonLabelPrototypeScopeId.uiProductIntegrationScope,
        InternalNonLabelPrototypeScopeId.backendIntegrationScope,
        InternalNonLabelPrototypeScopeId.persistenceScope,
        InternalNonLabelPrototypeScopeId.directEngineAccessScope,
      ]) {
        final target = result.targetImpact(scope);
        expect(target.stillBlocked, isTrue, reason: scope.wire);
        expect(target.newSupportCaseIds, isEmpty, reason: scope.wire);
        expect(
          target.recommendation,
          TargetedGoldenCoverageImpactRecommendation.keepBlockedByPolicy,
          reason: scope.wire,
        );
      }
      for (final scope in const <InternalNonLabelPrototypeScopeId>[
        InternalNonLabelPrototypeScopeId.cpLossPrototypeScope,
        InternalNonLabelPrototypeScopeId.winProbabilityPrototypeScope,
      ]) {
        final target = result.targetImpact(scope);
        expect(target.stillBlocked, isTrue, reason: scope.wire);
        expect(
          target.recommendation,
          TargetedGoldenCoverageImpactRecommendation.keepFutureOnly,
          reason: scope.wire,
        );
      }
    });

    test('Android proof packet remains proof-limited', () {
      final target = _review().targetImpact(
        InternalNonLabelPrototypeScopeId
            .androidProofConfidenceInternalPrototypeScope,
      );

      expect(target.currentActionAfter32E, 'keepProofLimited');
      expect(target.improved, isFalse);
      expect(
        target.recommendation,
        TargetedGoldenCoverageImpactRecommendation.keepProofLimited,
      );
    });
  });

  group('TargetedGoldenCoverageImpactReview validator and report guards', () {
    test('validator rejects unproven Android proof claim', () {
      final safe = _review();
      final rows = safe.caseImpactRows.toList();
      final index = rows.indexWhere(
        (row) => row.caseId == 'pv-multipv-support-boundary-32e',
      );
      rows[index] = rows[index].copyWith(androidProofClaimed: true);
      final unsafe = safe.copyWith(caseImpactRows: rows);
      final findings = const TargetedGoldenCoverageImpactReviewValidator()
          .validate(unsafe);

      expect(
        findings.map((finding) => finding.id),
        contains('phase32ECaseClaimedAndroidProof'),
      );
    });

    test('validator rejects blocked output boundaries', () {
      final safe = _review();
      for (final mutated in <TargetedGoldenCoverageImpactReviewResult>[
        safe.copyWith(productLabelsEmitted: true),
        safe.copyWith(advancedLabelsEmitted: true),
        safe.copyWith(classifierLabelsEmitted: true),
        safe.copyWith(finalMoveLabelsEmitted: true),
        safe.copyWith(officialMetricsAllowed: true),
        safe.copyWith(cpLossComputationImplemented: true),
        safe.copyWith(winProbabilityComputationImplemented: true),
        safe.copyWith(numericMoveValuesComputed: true),
        safe.copyWith(moveOrderingComputed: true),
        safe.copyWith(quietPreparatoryScopeActivated: true),
      ]) {
        final findings = const TargetedGoldenCoverageImpactReviewValidator()
            .validate(mutated);
        expect(
          findings.map((finding) => finding.id),
          contains('impactReviewBoundaryPolicyViolation'),
        );
      }
    });

    test('validator rejects quiet/preparatory activation', () {
      final safe = _review();
      final rows = safe.hardeningTargetRows.toList();
      final index = rows.indexWhere(
        (row) =>
            row.scopeId ==
            InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
      );
      rows[index] = rows[index].copyWith(stillBlocked: false);
      final findings = const TargetedGoldenCoverageImpactReviewValidator()
          .validate(safe.copyWith(hardeningTargetRows: rows));

      expect(
        findings.map((finding) => finding.id),
        contains('quietPreparatoryScopeActivated'),
      );
    });

    test(
      'markdown report includes required sections and no unsafe output text',
      () {
        final report = _review().renderMarkdownReport();

        expect(report, contains('## Phase 32E New Case Impact Table'));
        expect(report, contains('## Hardening Target Impact Table'));
        expect(report, contains('## Owner Proof Queue Status'));
        expect(report, contains('## Phase 32G Recommendation'));
        expect(report, contains('king-safety-mating-net-pressure-32e'));
        expect(report, contains('pv-multipv-support-boundary-32e'));
        expect(report, contains('owner proof queue count: 0'));
        _expectCleanReport(report);
        expect(
          const TargetedGoldenCoverageImpactReviewValidator()
              .validateReportText(report),
          isEmpty,
        );
      },
    );

    test('JSON report is deterministic and valid', () {
      final first = _review().renderJsonReport();
      final second = _review().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        targetedGoldenCoverageImpactReviewReportVersion,
      );
      expect(decoded['totalGoldenCases'], 20);
      expect(decoded['protectedCount'], 19);
      expect(decoded['negativeGuardCount'], 1);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(
        decoded['newSupportCaseIds'],
        orderedEquals(_phase32ECaseIdsSorted),
      );
      expect(decoded['caseImpactRows'], isA<List<Object?>>());
      expect(decoded['hardeningTargetRows'], isA<List<Object?>>());
    });

    test(
      'report text validator rejects raw UCI, PV dumps, labels, metrics, scores, and rankings',
      () {
        final validator = const TargetedGoldenCoverageImpactReviewValidator();

        expect(validator.validateReportText('uciok'), isNotEmpty);
        expect(validator.validateReportText('line pv e2e4 e7e5'), isNotEmpty);
        expect(validator.validateReportText('Brilliant'), isNotEmpty);
        expect(validator.validateReportText('ACPL'), isNotEmpty);
        expect(
          validator.validateReportText('numeric move score: 1'),
          isNotEmpty,
        );
        expect(validator.validateReportText('moveRanking'), isNotEmpty);
      },
    );

    test(
      'new model and command avoid engine, UI, backend, and persistence imports',
      () {
        for (final path in const <String>[
          'lib/features/pgn_review/application/targeted_golden_coverage_impact_review.dart',
          'tool/targeted_golden_coverage_impact_review_report.dart',
        ]) {
          final source = File(path).readAsStringSync();
          expect(source, isNot(contains("dart:ffi")), reason: path);
          expect(source, isNot(contains("package:flutter/")), reason: path);
          expect(
            source,
            isNot(contains("package:flutter/widgets.dart")),
            reason: path,
          );
          expect(source, isNot(contains("stockfish")), reason: path);
          expect(source, isNot(contains("LocalEvalService")), reason: path);
          expect(source, isNot(contains("preflight")), reason: path);
          expect(source, isNot(contains("server")), reason: path);
          expect(source, isNot(contains("database")), reason: path);
          expect(source, isNot(contains("cache")), reason: path);
        }
      },
    );
  });
}

TargetedGoldenCoverageImpactReviewResult _review() {
  return _cachedReview ??= _buildReview();
}

TargetedGoldenCoverageImpactReviewResult _buildReview() {
  return const TargetedGoldenCoverageImpactReview().evaluate(
    const TargetedGoldenCoverageImpactReviewRequest.safeDemo(),
  );
}

GoldenEvidenceReviewResult _goldenEvidenceReview() {
  return _cachedEvidenceReview ??= _buildGoldenEvidenceReview();
}

GoldenEvidenceReviewResult _buildGoldenEvidenceReview() {
  return const GoldenEvidenceReviewRunner().review(
    const GoldenEvidenceReviewRequest(
      mode: GoldenEvidenceReviewMode.realDeviceEvidenceReferenceOnly,
      requireAllEvidence: true,
    ),
  );
}

void _expectCleanReport(String report) {
  for (final token in const <String>[
    'uciok',
    'readyok',
    'info depth',
    'bestmove e2e4',
    ' pv ',
    'pvMoves',
    'e2e4 e7e5',
    'Brilliant',
    'Great',
    'Miss',
    'Best',
    'Good',
    'Inaccuracy',
    'Mistake',
    'Blunder',
    'ACPL',
    'official accuracy',
    'numeric move score:',
    'scoreValue',
    'moveScore',
    'rankedMoves',
    'moveRanking',
  ]) {
    expect(report, isNot(contains(token)), reason: token);
  }
}

const _provenAndroidIds = <String>[
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
];

const _phase32ECaseIdsSorted = <String>[
  'budget-pressure-wide-candidate-32e',
  'endgame-precision-candidate-spread-32e',
  'king-safety-mating-net-pressure-32e',
  'pv-multipv-support-boundary-32e',
  'suppression-forced-only-legal-32e',
];

const _existingPhase32EInputIds = <String>[
  'quiet-opening-skip',
  'invalid-fen-safety',
  'forced-move-skip',
  'simple-tactical-capture-check',
  'material-sacrifice-compensation',
  'mate-threat-fast-evidence',
  'quiet-preparatory-uncertain',
  'technical-endgame-conservative',
  'budget-pressure-candidates',
  'queen-win-major-swing',
  'king-safety-mating-net-hard-case',
  'quiet-preparatory-hard-case',
  'sacrifice-compensation-hard-case',
  'endgame-precision-hard-case',
  'forcing-line-variation-hard-case',
];

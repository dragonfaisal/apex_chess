@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_evidence_summary_layer.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_refresh_review.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_internal_packet_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_evidence_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_hardening_validation.dart';
import 'package:flutter_test/flutter_test.dart';

InternalEvidenceSummaryLayerResult? _cachedSummary;
RefreshedPacketEvidenceReadinessGateResult? _cachedReadiness;

void main() {
  setUpAll(() {
    _cachedReadiness = const RefreshedPacketEvidenceReadinessGate().evaluate();
    _cachedSummary = const InternalEvidenceSummaryLayer().evaluate();
  });

  group('InternalEvidenceSummaryLayer safe demo', () {
    test('consumes safe Phase 32K readiness result', () {
      final readiness = _readiness();
      final result = const InternalEvidenceSummaryLayer().evaluate(
        InternalEvidenceSummaryLayerRequest(readinessResult: readiness),
      );

      expect(
        result.sourceReadinessStatus,
        RefreshedPacketEvidenceReadinessStatus.readyWithWarnings,
      );
      expect(readiness.safeForPhase32L, isTrue);
      expect(result.safeForPhase32M, isTrue);
      expect(result.validationFindings, isEmpty);
    });

    test('default status summarizes with warning honesty', () {
      final result = _summary();

      expect(
        result.summaryStatus,
        isIn(<InternalEvidenceSummaryLayerStatus>[
          InternalEvidenceSummaryLayerStatus.summarizedWithWarnings,
          InternalEvidenceSummaryLayerStatus.summarizedClean,
        ]),
      );
      expect(
        result.summaryStatus,
        InternalEvidenceSummaryLayerStatus.summarizedWithWarnings,
      );
      expect(result.unsafeCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.safeForPhase32M, isTrue);
    });

    test('unsafe readiness blocks summary', () {
      final unsafePlan = const RefreshedInternalPacketHardeningPlan()
          .evaluate()
          .copyWith(
            refreshedStatus:
                RefreshedInternalPacketHardeningStatus.blockedByUnsafeImpact,
            unsafeCount: 1,
            safeForPhase32H: false,
          );
      final unsafeValidation = const RefreshedPacketHardeningValidation()
          .evaluate(
            RefreshedPacketHardeningValidationRequest(
              refreshedPlanResult: unsafePlan,
            ),
          );
      final unsafeReview = const InternalPacketEvidenceRefreshReview().evaluate(
        InternalPacketEvidenceRefreshReviewRequest(
          validationResult: unsafeValidation,
          refreshedPlanResult: unsafePlan,
        ),
      );
      final unsafeReadiness = const RefreshedPacketEvidenceReadinessGate()
          .evaluate(
            RefreshedPacketEvidenceReadinessGateRequest(
              reviewResult: unsafeReview,
              validationResult: unsafeValidation,
              refreshedPlanResult: unsafePlan,
            ),
          );
      final result = const InternalEvidenceSummaryLayer().evaluate(
        InternalEvidenceSummaryLayerRequest(
          readinessResult: unsafeReadiness,
          reviewResult: unsafeReview,
          validationResult: unsafeValidation,
          refreshedPlanResult: unsafePlan,
        ),
      );

      expect(
        result.summaryStatus,
        InternalEvidenceSummaryLayerStatus.blockedByUnsafeReadiness,
      );
      expect(result.safeForPhase32M, isFalse);
      expect(result.totalGroups, 0);
      expect(
        result.phase32MRecommendation,
        InternalEvidenceSummaryPhase32MRecommendation.blockedByUnsafeSummary,
      );
    });

    test('aggregate summary counts are deterministic', () {
      final first = _summary();
      final second = const InternalEvidenceSummaryLayer().evaluate();

      expect(first.totalGroups, 7);
      expect(first.allowedGroupCount, 2);
      expect(first.constrainedGroupCount, 3);
      expect(first.blockedGroupCount, 1);
      expect(first.futureOnlyGroupCount, 1);
      expect(first.allowedRecordCount, 4);
      expect(first.constrainedRecordCount, 6);
      expect(first.blockedRecordCount, 8);
      expect(first.futureOnlyRecordCount, 2);
      expect(first.unsafeCount, 0);
      expect(first.criticalCount, 0);
      expect(first.toJson(), second.toJson());
    });

    test('Phase 32M recommendation and support IDs are deterministic', () {
      final result = _summary();

      expect(
        result.newlyAddedSupportCaseIds,
        orderedEquals(_phase32ECaseIdsSorted),
      );
      expect(result.androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(
        result.phase32MRecommendation,
        InternalEvidenceSummaryPhase32MRecommendation
            .proceedToInternalEvidenceAdapterDesign,
      );
      expect(result.safeForPhase32M, isTrue);
    });
  });

  group('Summary group behavior', () {
    test('allowed evidence summary contains preserved stable records', () {
      final group = _summary().group(
        InternalEvidenceSummaryGroupId.allowedEvidenceSummary,
      );

      expect(group.groupStatus, InternalEvidenceSummaryGroupStatus.allowed);
      expect(
        group.scopeIds,
        containsAll(<InternalNonLabelPrototypeScopeId>[
          InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
          InternalNonLabelPrototypeScopeId.materialSwingInternalPrototypeScope,
        ]),
      );
      expect(group.safeForNextInternalLayer, isTrue);
    });

    test('allowed and improved summaries contain improved support records', () {
      final allowed = _summary().group(
        InternalEvidenceSummaryGroupId.allowedEvidenceSummary,
      );
      final improved = _summary().group(
        InternalEvidenceSummaryGroupId.improvedSupportSummary,
      );

      for (final group in <InternalEvidenceSummaryGroup>[allowed, improved]) {
        expect(group.groupStatus, InternalEvidenceSummaryGroupStatus.allowed);
        expect(
          group.scopeIds,
          containsAll(<InternalNonLabelPrototypeScopeId>[
            InternalNonLabelPrototypeScopeId.forcingLineInternalPrototypeScope,
            InternalNonLabelPrototypeScopeId
                .candidateSpreadInternalPrototypeScope,
          ]),
        );
      }
      expect(improved.newlyAddedSupportCaseIds, isNotEmpty);
    });

    test('PV and MultiPV remains constrained watch-listed', () {
      final group = _summary().group(
        InternalEvidenceSummaryGroupId.constrainedWatchListSummary,
      );

      expect(group.groupStatus, InternalEvidenceSummaryGroupStatus.constrained);
      expect(
        group.scopeIds,
        contains(
          InternalNonLabelPrototypeScopeId
              .pvMultiPvSupportInternalPrototypeScope,
        ),
      );
      expect(group.proofLimitReasons.join(' '), contains('boundary-only'));
      expect(group.safeForNextInternalLayer, isTrue);
    });

    test('Android proof remains constrained proof-limited', () {
      final group = _summary().group(
        InternalEvidenceSummaryGroupId.proofLimitedSummary,
      );

      expect(group.groupStatus, InternalEvidenceSummaryGroupStatus.constrained);
      expect(
        group.scopeIds,
        contains(
          InternalNonLabelPrototypeScopeId
              .androidProofConfidenceInternalPrototypeScope,
        ),
      );
      expect(group.androidProofCaseIds, orderedEquals(_provenAndroidIds));
    });

    test(
      'warning-limited summary includes king-safety, endgame, suppression, and budget',
      () {
        final group = _summary().group(
          InternalEvidenceSummaryGroupId.warningLimitedSummary,
        );

        expect(
          group.groupStatus,
          InternalEvidenceSummaryGroupStatus.constrained,
        );
        expect(
          group.scopeIds,
          containsAll(<InternalNonLabelPrototypeScopeId>[
            InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
            InternalNonLabelPrototypeScopeId.endgameInternalPrototypeScope,
            InternalNonLabelPrototypeScopeId
                .suppressionSafetyInternalPrototypeScope,
            InternalNonLabelPrototypeScopeId.budgetRiskInternalPrototypeScope,
          ]),
        );
        expect(group.newlyAddedSupportCaseIds, isNotEmpty);
      },
    );

    test('blocked summary includes quiet and product-policy boundaries', () {
      final group = _summary().group(
        InternalEvidenceSummaryGroupId.blockedBoundarySummary,
      );

      expect(group.groupStatus, InternalEvidenceSummaryGroupStatus.blocked);
      expect(
        group.scopeIds,
        containsAll(<InternalNonLabelPrototypeScopeId>[
          InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
          InternalNonLabelPrototypeScopeId.productLabelPrototypeScope,
          InternalNonLabelPrototypeScopeId.advancedLabelPrototypeScope,
          InternalNonLabelPrototypeScopeId.officialMetricPrototypeScope,
          InternalNonLabelPrototypeScopeId.uiProductIntegrationScope,
          InternalNonLabelPrototypeScopeId.backendIntegrationScope,
          InternalNonLabelPrototypeScopeId.persistenceScope,
          InternalNonLabelPrototypeScopeId.directEngineAccessScope,
        ]),
      );
    });

    test('future-only summary includes CP-loss and win probability', () {
      final group = _summary().group(
        InternalEvidenceSummaryGroupId.futureOnlySummary,
      );

      expect(group.groupStatus, InternalEvidenceSummaryGroupStatus.futureOnly);
      expect(
        group.scopeIds,
        containsAll(<InternalNonLabelPrototypeScopeId>[
          InternalNonLabelPrototypeScopeId.cpLossPrototypeScope,
          InternalNonLabelPrototypeScopeId.winProbabilityPrototypeScope,
        ]),
      );
    });

    test('proof, owner, constrained, blocked, and future boundaries hold', () {
      expect(_summary().androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(_summary().ownerProofQueueCount, 0);

      for (final caseId in _phase32ECaseIdsSorted) {
        expect(_summary().androidProofCaseIds, isNot(contains(caseId)));
        for (final group in _summary().groups) {
          expect(group.androidProofCaseIds, isNot(contains(caseId)));
        }
      }
      for (final group in _summary().constrainedGroups) {
        expect(
          group.groupStatus,
          InternalEvidenceSummaryGroupStatus.constrained,
        );
      }
      expect(
        _summary()
            .group(InternalEvidenceSummaryGroupId.blockedBoundarySummary)
            .groupStatus,
        InternalEvidenceSummaryGroupStatus.blocked,
      );
      expect(
        _summary()
            .group(InternalEvidenceSummaryGroupId.futureOnlySummary)
            .groupStatus,
        InternalEvidenceSummaryGroupStatus.futureOnly,
      );
    });
  });

  group('InternalEvidenceSummaryLayerValidator', () {
    test(
      'rejects unproven Android proof and Phase 32E captured proof claims',
      () {
        final unproven = _summary().copyWith(
          androidProofCaseIds: <String>[
            ..._summary().androidProofCaseIds,
            'unproven-android-proof',
          ],
        );
        final phase32E = _withGroup(
          InternalEvidenceSummaryGroupId.proofLimitedSummary,
          (group) => group.copyWith(
            androidProofCaseIds: <String>[
              ...group.androidProofCaseIds,
              'pv-multipv-support-boundary-32e',
            ],
          ),
        );

        expect(
          _validator().validate(unproven).map((finding) => finding.id),
          contains('unprovenAndroidProofClaim'),
        );
        expect(
          _validator().validate(phase32E).map((finding) => finding.id),
          contains('phase32ECaseClaimedCapturedProof'),
        );
      },
    );

    test(
      'rejects label, value, ordering, metric, and quiet activation output',
      () {
        final validator = _validator();

        expect(
          validator
              .validate(_summary().copyWith(classifierLabelsEmitted: true))
              .map((finding) => finding.id),
          contains('summaryBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(_summary().copyWith(numericMoveValuesComputed: true))
              .map((finding) => finding.id),
          contains('summaryBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(_summary().copyWith(moveOrderingComputed: true))
              .map((finding) => finding.id),
          contains('summaryBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(_summary().copyWith(officialMetricsAllowed: true))
              .map((finding) => finding.id),
          contains('summaryBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(
                _summary().copyWith(quietPreparatoryScopeActivated: true),
              )
              .map((finding) => finding.id),
          contains('summaryBoundaryPolicyViolation'),
        );
      },
    );

    test('rejects constrained promotion and blocked or future activation', () {
      final constrained = _withGroup(
        InternalEvidenceSummaryGroupId.constrainedWatchListSummary,
        (group) => group.copyWith(
          groupStatus: InternalEvidenceSummaryGroupStatus.allowed,
        ),
      );
      final blocked = _withGroup(
        InternalEvidenceSummaryGroupId.blockedBoundarySummary,
        (group) => group.copyWith(
          groupStatus: InternalEvidenceSummaryGroupStatus.allowed,
        ),
      );
      final futureOnly = _withGroup(
        InternalEvidenceSummaryGroupId.futureOnlySummary,
        (group) => group.copyWith(
          groupStatus: InternalEvidenceSummaryGroupStatus.allowed,
        ),
      );

      expect(
        _validator().validate(constrained).map((finding) => finding.id),
        contains('constrainedGroupPromotedToAllowed'),
      );
      expect(
        _validator().validate(blocked).map((finding) => finding.id),
        contains('blockedSummaryBecameActive'),
      );
      expect(
        _validator().validate(futureOnly).map((finding) => finding.id),
        contains('futureOnlySummaryBecameActive'),
      );
    });

    test('rejects quiet activation and owner proof without PV reason', () {
      final quiet = _withGroup(
        InternalEvidenceSummaryGroupId.blockedBoundarySummary,
        (group) => group.copyWith(quietScopeActive: true),
      );
      final ownerProof = _summary().copyWith(
        ownerProofQueueCount: 1,
        groups: _summary().groups
            .map(
              (group) => group.copyWith(
                warningReasons: const <String>[],
                proofLimitReasons: const <String>[],
                futurePrerequisites: const <String>[],
              ),
            )
            .toList(),
      );

      expect(
        _validator().validate(quiet).map((finding) => finding.id),
        contains('quietPreparatoryScopeActivated'),
      );
      expect(
        _validator().validate(ownerProof).map((finding) => finding.id),
        contains('ownerProofRequiredWithoutPvReason'),
      );
    });

    test('normal report text is clean and unsafe report text is rejected', () {
      final validator = _validator();
      final report = _summary().renderMarkdownReport();

      expect(validator.validateReportText(report), isEmpty);
      expect(
        validator
            .validateReportText('uciok\ninfo depth 1\nbestmove e2e4')
            .map((finding) => finding.id),
        contains('rawUciReportText'),
      );
      expect(
        validator
            .validateReportText('rankedMoves: e2e4')
            .map((finding) => finding.id),
        contains('moveOrderingReportText'),
      );
    });
  });

  group('Summary report rendering and guardrails', () {
    test('markdown includes required sections', () {
      final report = _summary().renderMarkdownReport();

      expect(report, contains('# Internal Evidence Summary Layer'));
      expect(report, contains('## Summary Group Table'));
      expect(report, contains('## Allowed Evidence Summary'));
      expect(report, contains('## Constrained Groups'));
      expect(report, contains('## Owner Proof Status'));
      expect(report, contains('## Phase 32M Recommendation'));
    });

    test('JSON report is deterministic and valid', () {
      final first = _summary().renderJsonReport();
      final second = _summary().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(decoded['version'], internalEvidenceSummaryLayerReportVersion);
      expect(decoded['summaryStatus'], 'summarizedWithWarnings');
      expect(decoded['groups'], isA<List<Object?>>());
      expect(decoded['safeForPhase32M'], isTrue);
    });

    test(
      'reports contain no raw engine, final label, metric, value, or ordering text',
      () {
        final report = _summary().renderMarkdownReport();

        for (final token in const <String>[
          'uciok',
          'readyok',
          'info depth',
          'bestmove e2e4',
          ' pv ',
          'pvMoves',
          'Brilliant',
          'Great',
          'Miss',
          'Best',
          'Good',
          'Inaccuracy',
          'Mistake',
          'Blunder',
          'ACPL',
          'accuracy',
          'numeric move score:',
          'scoreValue',
          'moveScore',
          'rankedMoves',
          'moveRanking',
        ]) {
          expect(report, isNot(contains(token)), reason: token);
        }
      },
    );

    test('source does not import engine, UI, backend, or persistence seams', () {
      final source = File(
        'lib/features/pgn_review/application/internal_evidence_summary_layer.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      expect(imports, isNot(contains('dart:ffi')));
      expect(imports.toLowerCase(), isNot(contains('stockfish')));
      expect(imports, isNot(contains('LocalEvalService')));
      expect(imports, isNot(contains('package:flutter/')));
      expect(imports, isNot(contains('Widget')));
      expect(imports, isNot(contains('backend')));
      expect(imports, isNot(contains('preflight')));
      expect(imports, isNot(contains('server')));
      expect(imports, isNot(contains('persistence')));
      expect(imports, isNot(contains('cache')));
      expect(imports, isNot(contains('database')));
    });
  });
}

InternalEvidenceSummaryLayerResult _summary() => _cachedSummary!;

RefreshedPacketEvidenceReadinessGateResult _readiness() => _cachedReadiness!;

InternalEvidenceSummaryLayerValidator _validator() {
  return const InternalEvidenceSummaryLayerValidator();
}

InternalEvidenceSummaryLayerResult _withGroup(
  InternalEvidenceSummaryGroupId groupId,
  InternalEvidenceSummaryGroup Function(InternalEvidenceSummaryGroup group)
  update,
) {
  final groups = _summary().groups.map((group) {
    if (group.groupId == groupId) return update(group);
    return group;
  }).toList();
  return _summary().copyWith(groups: groups);
}

const _phase32ECaseIdsSorted = <String>[
  'budget-pressure-wide-candidate-32e',
  'endgame-precision-candidate-spread-32e',
  'king-safety-mating-net-pressure-32e',
  'pv-multipv-support-boundary-32e',
  'suppression-forced-only-legal-32e',
];

const _provenAndroidIds = <String>[
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
];

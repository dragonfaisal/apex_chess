@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_internal_packet_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/targeted_golden_coverage_impact_review.dart';
import 'package:flutter_test/flutter_test.dart';

RefreshedInternalPacketHardeningPlanResult? _cachedRefresh;
TargetedGoldenCoverageImpactReviewResult? _cachedImpact;

void main() {
  setUpAll(() {
    _cachedRefresh = const RefreshedInternalPacketHardeningPlan().evaluate();
    _cachedImpact = const TargetedGoldenCoverageImpactReview().evaluate();
  });

  group('RefreshedInternalPacketHardeningPlan safe demo', () {
    test('consumes safe Phase 32F impact review', () {
      final impact = _impact();
      final result = const RefreshedInternalPacketHardeningPlan().evaluate(
        RefreshedInternalPacketHardeningPlanRequest(impactReviewResult: impact),
      );

      expect(
        result.sourceImpactStatus,
        TargetedGoldenCoverageImpactStatus.coverageImprovedWithWarnings,
      );
      expect(
        result.sourceHardeningStatus,
        InternalPacketEvidenceHardeningStatus.readyForTargetedHardening,
      );
      expect(result.safeForPhase32H, isTrue);
      expect(result.validationFindings, isEmpty);
    });

    test('default status refreshes with warning honesty', () {
      final result = _refresh();

      expect(
        result.refreshedStatus,
        isIn(<RefreshedInternalPacketHardeningStatus>[
          RefreshedInternalPacketHardeningStatus.refreshedWithImprovedCoverage,
          RefreshedInternalPacketHardeningStatus.refreshedWithWarnings,
        ]),
      );
      expect(
        result.refreshedStatus,
        RefreshedInternalPacketHardeningStatus.refreshedWithWarnings,
      );
      expect(result.safeForPhase32H, isTrue);
      expect(result.unsafeCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
    });

    test('unsafe impact blocks refresh', () {
      final unsafeImpact = _impact().copyWith(
        impactStatus: TargetedGoldenCoverageImpactStatus.blockedByUnsafeCase,
        unsafeCaseCount: 1,
        safeForPhase32G: false,
      );
      final result = const RefreshedInternalPacketHardeningPlan().evaluate(
        RefreshedInternalPacketHardeningPlanRequest(
          impactReviewResult: unsafeImpact,
        ),
      );

      expect(
        result.refreshedStatus,
        RefreshedInternalPacketHardeningStatus.blockedByUnsafeImpact,
      );
      expect(result.safeForPhase32H, isFalse);
      expect(result.unsafeCount, greaterThan(0));
      expect(
        result.phase32HRecommendation,
        RefreshedInternalPacketPhase32HRecommendation.blockedByUnsafeRefresh,
      );
    });

    test('aggregate counts are deterministic', () {
      final first = _refresh();
      final second = const RefreshedInternalPacketHardeningPlan().evaluate();

      expect(first.totalTargets, 20);
      expect(first.improvedTargetCount, 8);
      expect(first.preservedTargetCount, 4);
      expect(first.warningLimitedImprovedCount, 4);
      expect(first.stillWarningLimitedCount, 4);
      expect(first.blockedCount, 8);
      expect(first.futureOnlyCount, 2);
      expect(first.proofLimitedCount, 1);
      expect(first.ownerProofQueueCount, 0);
      expect(first.unsafeCount, 0);
      expect(first.criticalCount, 0);
      expect(first.toJson(), second.toJson());
    });

    test('Phase 32H recommendation and support IDs are deterministic', () {
      final result = _refresh();

      expect(result.newSupportCaseIds, orderedEquals(_phase32ECaseIdsSorted));
      expect(result.androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(
        result.phase32HRecommendation,
        RefreshedInternalPacketPhase32HRecommendation
            .validateRefreshedHardeningPlan,
      );
      expect(result.safeForPhase32H, isTrue);
    });

    test('remaining coverage gaps are deterministic', () {
      final result = _refresh();

      expect(
        result.remainingCoverageGapIds,
        orderedEquals(<String>[
          'PV/MultiPV support coverage',
          'budget pressure coverage',
          'budgetRiskInternalPrototypeScope',
          'endgame precision coverage',
          'endgameInternalPrototypeScope',
          'king-safety / mating-net coverage',
          'kingSafetyInternalPrototypeScope',
          'suppression safety coverage',
          'suppressionSafetyInternalPrototypeScope',
        ]),
      );
    });
  });

  group('Refreshed target behavior', () {
    test('stable tactical and material targets are preserved', () {
      _expectAction(
        InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
        RefreshedInternalPacketHardeningActionType.preserveStablePacket,
      );
      _expectAction(
        InternalNonLabelPrototypeScopeId.materialSwingInternalPrototypeScope,
        RefreshedInternalPacketHardeningActionType.preserveStablePacket,
      );
    });

    test('forcing and candidate-spread targets are preserved or improved', () {
      final forcing = _refresh().target(
        InternalNonLabelPrototypeScopeId.forcingLineInternalPrototypeScope,
      );
      final candidate = _refresh().target(
        InternalNonLabelPrototypeScopeId.candidateSpreadInternalPrototypeScope,
      );

      expect(
        forcing.refreshedAction,
        isIn(<RefreshedInternalPacketHardeningActionType>[
          RefreshedInternalPacketHardeningActionType.preserveStablePacket,
          RefreshedInternalPacketHardeningActionType.preserveImprovedPacket,
        ]),
      );
      expect(
        forcing.improvedByCaseIds,
        containsAll(<String>[
          'budget-pressure-wide-candidate-32e',
          'suppression-forced-only-legal-32e',
        ]),
      );
      expect(
        candidate.refreshedAction,
        isIn(<RefreshedInternalPacketHardeningActionType>[
          RefreshedInternalPacketHardeningActionType.preserveStablePacket,
          RefreshedInternalPacketHardeningActionType.preserveImprovedPacket,
        ]),
      );
      expect(
        candidate.improvedByCaseIds,
        containsAll(<String>[
          'endgame-precision-candidate-spread-32e',
          'pv-multipv-support-boundary-32e',
        ]),
      );
    });

    test('PV and MultiPV target is warning-aware and watch-listed', () {
      final target = _refresh().target(
        InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope,
      );

      expect(
        target.refreshedAction,
        RefreshedInternalPacketHardeningActionType.downgradeCoverageNeedToWatch,
      );
      expect(
        target.refreshedPriority,
        InternalPacketEvidenceHardeningPriority.low,
      );
      expect(
        target.improvedByCaseIds,
        orderedEquals(<String>['pv-multipv-support-boundary-32e']),
      );
      expect(
        target.remainingCoverageGaps,
        orderedEquals(<String>['PV/MultiPV support coverage']),
      );
      expect(target.ownerProofAllowed, isTrue);
      expect(target.ownerProofRequired, isFalse);
    });

    test('Android proof target remains proof-limited', () {
      final target = _refresh().target(
        InternalNonLabelPrototypeScopeId
            .androidProofConfidenceInternalPrototypeScope,
      );

      expect(
        target.refreshedAction,
        RefreshedInternalPacketHardeningActionType.keepProofLimited,
      );
      expect(
        target.targetKind,
        InternalPacketEvidenceHardeningTargetKind.androidProofScope,
      );
      expect(target.androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(target.ownerProofAllowed, isTrue);
      expect(target.ownerProofRequired, isFalse);
    });

    test('warning-limited scopes are improved but not promoted', () {
      _expectWarningImproved(
        InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
        'king-safety-mating-net-pressure-32e',
      );
      _expectWarningImproved(
        InternalNonLabelPrototypeScopeId.endgameInternalPrototypeScope,
        'endgame-precision-candidate-spread-32e',
      );
      _expectWarningImproved(
        InternalNonLabelPrototypeScopeId
            .suppressionSafetyInternalPrototypeScope,
        'suppression-forced-only-legal-32e',
      );
      _expectWarningImproved(
        InternalNonLabelPrototypeScopeId.budgetRiskInternalPrototypeScope,
        'budget-pressure-wide-candidate-32e',
      );
    });

    test(
      'quiet, product, metric, future, and integration scopes stay blocked',
      () {
        final result = _refresh();

        expect(
          result
              .target(
                InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
              )
              .refreshedAction,
          RefreshedInternalPacketHardeningActionType
              .keepExcludedByNegativeGuard,
        );
        for (final scopeId in const <InternalNonLabelPrototypeScopeId>[
          InternalNonLabelPrototypeScopeId.productLabelPrototypeScope,
          InternalNonLabelPrototypeScopeId.advancedLabelPrototypeScope,
          InternalNonLabelPrototypeScopeId.officialMetricPrototypeScope,
          InternalNonLabelPrototypeScopeId.uiProductIntegrationScope,
          InternalNonLabelPrototypeScopeId.backendIntegrationScope,
          InternalNonLabelPrototypeScopeId.persistenceScope,
          InternalNonLabelPrototypeScopeId.directEngineAccessScope,
        ]) {
          final target = result.target(scopeId);
          expect(target.stillBlocked, isTrue, reason: scopeId.wire);
          expect(
            target.refreshedAction,
            RefreshedInternalPacketHardeningActionType.keepBlockedByPolicy,
            reason: scopeId.wire,
          );
        }
        for (final scopeId in const <InternalNonLabelPrototypeScopeId>[
          InternalNonLabelPrototypeScopeId.cpLossPrototypeScope,
          InternalNonLabelPrototypeScopeId.winProbabilityPrototypeScope,
        ]) {
          final target = result.target(scopeId);
          expect(target.stillBlocked, isTrue, reason: scopeId.wire);
          expect(
            target.refreshedAction,
            RefreshedInternalPacketHardeningActionType.keepFutureOnly,
            reason: scopeId.wire,
          );
        }
      },
    );
  });

  group('Refreshed hardening validator', () {
    test('rejects unproven Android proof claims', () {
      final result = _refresh().copyWith(
        androidProofCaseIds: <String>[
          ..._refresh().androidProofCaseIds,
          'unproven-android-proof',
        ],
      );

      expect(
        _validator().validate(result).map((finding) => finding.id),
        contains('unprovenAndroidProofClaim'),
      );
    });

    test('rejects Phase 32E case as captured Android proof', () {
      final result = _refresh().copyWith(
        androidProofCaseIds: <String>[
          ..._refresh().androidProofCaseIds,
          'pv-multipv-support-boundary-32e',
        ],
      );

      expect(
        _validator().validate(result).map((finding) => finding.id),
        contains('phase32ECaseClaimedCapturedAndroidProof'),
      );
    });

    test(
      'rejects label, value, ordering, metric, and quiet activation output',
      () {
        final validator = _validator();

        expect(
          validator
              .validate(_refresh().copyWith(classifierLabelsEmitted: true))
              .map((finding) => finding.id),
          contains('refreshBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(_refresh().copyWith(numericMoveValuesComputed: true))
              .map((finding) => finding.id),
          contains('refreshBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(_refresh().copyWith(moveOrderingComputed: true))
              .map((finding) => finding.id),
          contains('refreshBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(_refresh().copyWith(officialMetricsAllowed: true))
              .map((finding) => finding.id),
          contains('refreshBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(
                _refresh().copyWith(quietPreparatoryScopeActivated: true),
              )
              .map((finding) => finding.id),
          contains('refreshBoundaryPolicyViolation'),
        );
      },
    );

    test('rejects blocked scope receiving active allowed action', () {
      final result = _refresh();
      final targets = result.targets.map((target) {
        if (target.scopeId ==
            InternalNonLabelPrototypeScopeId.productLabelPrototypeScope) {
          return target.copyWith(
            refreshedAction: RefreshedInternalPacketHardeningActionType
                .addMoreGoldenCoverage,
          );
        }
        return target;
      }).toList();

      expect(
        _validator()
            .validate(result.copyWith(targets: targets))
            .map((finding) => finding.id),
        contains('blockedScopeReceivedActiveAction'),
      );
    });

    test('rejects owner proof without explicit PV or MultiPV reason', () {
      final result = _refresh();
      final targets = result.targets.map((target) {
        if (target.scopeId ==
            InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope) {
          return target.copyWith(ownerProofRequired: true);
        }
        return target;
      }).toList();

      expect(
        _validator()
            .validate(result.copyWith(targets: targets))
            .map((finding) => finding.id),
        contains('ownerProofRequiredWithoutPvReason'),
      );
    });

    test('normal report text is clean and unsafe report text is rejected', () {
      final validator = _validator();
      final report = _refresh().renderMarkdownReport();

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

  group('Refreshed hardening report rendering and guardrails', () {
    test('markdown includes required sections', () {
      final report = _refresh().renderMarkdownReport();

      expect(report, contains('# Refreshed Internal Packet Hardening Plan'));
      expect(report, contains('## Refreshed Target Table'));
      expect(report, contains('## Improved Targets'));
      expect(report, contains('## Owner Proof Status'));
      expect(report, contains('## Phase 32H Recommendation'));
    });

    test('JSON report is deterministic and valid', () {
      final first = _refresh().renderJsonReport();
      final second = _refresh().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        refreshedInternalPacketHardeningPlanReportVersion,
      );
      expect(decoded['refreshedStatus'], 'refreshedWithWarnings');
      expect(decoded['targets'], isA<List<Object?>>());
      expect(decoded['safeForPhase32H'], isTrue);
    });

    test(
      'reports contain no raw engine, label, metric, value, or ordering text',
      () {
        final report = _refresh().renderMarkdownReport();

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
        'lib/features/pgn_review/application/refreshed_internal_packet_hardening_plan.dart',
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

RefreshedInternalPacketHardeningPlanResult _refresh() => _cachedRefresh!;

TargetedGoldenCoverageImpactReviewResult _impact() => _cachedImpact!;

RefreshedInternalPacketHardeningPlanValidator _validator() {
  return const RefreshedInternalPacketHardeningPlanValidator();
}

void _expectAction(
  InternalNonLabelPrototypeScopeId scopeId,
  RefreshedInternalPacketHardeningActionType action,
) {
  final target = _refresh().target(scopeId);
  expect(target.refreshedAction, action, reason: scopeId.wire);
}

void _expectWarningImproved(
  InternalNonLabelPrototypeScopeId scopeId,
  String expectedCaseId,
) {
  final target = _refresh().target(scopeId);

  expect(
    target.refreshedAction,
    RefreshedInternalPacketHardeningActionType.keepWarningLimitedButImproved,
    reason: scopeId.wire,
  );
  expect(target.stillWarningLimited, isTrue, reason: scopeId.wire);
  expect(target.stillBlocked, isFalse, reason: scopeId.wire);
  expect(target.improvedByCaseIds, contains(expectedCaseId));
  expect(target.refreshedPriority, InternalPacketEvidenceHardeningPriority.low);
  expect(target.ownerProofRequired, isFalse);
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

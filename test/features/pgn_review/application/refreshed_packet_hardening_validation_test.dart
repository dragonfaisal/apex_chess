@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_internal_packet_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_hardening_validation.dart';
import 'package:apex_chess/features/pgn_review/application/targeted_golden_coverage_impact_review.dart';
import 'package:flutter_test/flutter_test.dart';

RefreshedPacketHardeningValidationResult? _cachedValidation;
RefreshedInternalPacketHardeningPlanResult? _cachedRefresh;

void main() {
  setUpAll(() {
    _cachedValidation = const RefreshedPacketHardeningValidation().evaluate();
    _cachedRefresh = const RefreshedInternalPacketHardeningPlan().evaluate();
  });

  group('RefreshedPacketHardeningValidation safe demo', () {
    test('consumes safe Phase 32G refreshed plan', () {
      final refresh = _refresh();
      final result = const RefreshedPacketHardeningValidation().evaluate(
        RefreshedPacketHardeningValidationRequest(refreshedPlanResult: refresh),
      );

      expect(
        result.sourceRefreshStatus,
        RefreshedInternalPacketHardeningStatus.refreshedWithWarnings,
      );
      expect(
        result.sourceImpactStatus,
        TargetedGoldenCoverageImpactStatus.coverageImprovedWithWarnings,
      );
      expect(result.safeForPhase32I, isTrue);
      expect(result.validationFindings, isEmpty);
    });

    test('default status validates with warning honesty', () {
      final result = _validation();

      expect(
        result.validationStatus,
        isIn(<RefreshedPacketHardeningValidationStatus>[
          RefreshedPacketHardeningValidationStatus.validatedWithWarnings,
          RefreshedPacketHardeningValidationStatus.validatedClean,
        ]),
      );
      expect(
        result.validationStatus,
        RefreshedPacketHardeningValidationStatus.validatedWithWarnings,
      );
      expect(result.unsafeCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.safeForPhase32I, isTrue);
    });

    test('unsafe refresh blocks validation', () {
      final unsafeRefresh = _refresh().copyWith(
        refreshedStatus:
            RefreshedInternalPacketHardeningStatus.blockedByUnsafeImpact,
        unsafeCount: 1,
        safeForPhase32H: false,
      );
      final result = const RefreshedPacketHardeningValidation().evaluate(
        RefreshedPacketHardeningValidationRequest(
          refreshedPlanResult: unsafeRefresh,
        ),
      );

      expect(
        result.validationStatus,
        RefreshedPacketHardeningValidationStatus.blockedByUnsafeRefresh,
      );
      expect(result.safeForPhase32I, isFalse);
      expect(result.unsafeCount, greaterThan(0));
      expect(
        result.phase32IRecommendation,
        RefreshedPacketHardeningPhase32IRecommendation
            .blockedByValidationFailure,
      );
    });

    test('aggregate counts are deterministic', () {
      final first = _validation();
      final second = const RefreshedPacketHardeningValidation().evaluate();

      expect(first.totalChecks, 15);
      expect(first.passedCount, 15);
      expect(first.warningCount, 2);
      expect(first.blockerCount, 0);
      expect(first.criticalCount, 0);
      expect(first.validatedTargetCount, 20);
      expect(first.warningLimitedTargetCount, 4);
      expect(first.blockedScopeCount, 8);
      expect(first.futureOnlyScopeCount, 2);
      expect(first.ownerProofQueueCount, 0);
      expect(first.unsafeCount, 0);
      expect(first.toJson(), second.toJson());
    });

    test('Phase 32I recommendation and support IDs are deterministic', () {
      final result = _validation();

      expect(result.phase32ECaseIds, orderedEquals(_phase32ECaseIdsSorted));
      expect(result.androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(
        result.phase32IRecommendation,
        RefreshedPacketHardeningPhase32IRecommendation
            .proceedToInternalPacketEvidenceRefresh,
      );
      expect(result.safeForPhase32I, isTrue);
    });

    test('validation check IDs are deterministic', () {
      final checkIds = _validation().checks.map((check) => check.checkId);

      expect(
        checkIds,
        orderedEquals(<RefreshedPacketHardeningValidationCheckId>[
          RefreshedPacketHardeningValidationCheckId
              .refreshedPlanConsumesImpactReview,
          RefreshedPacketHardeningValidationCheckId
              .improvedTargetsHaveNewSupportCases,
          RefreshedPacketHardeningValidationCheckId
              .preservedTargetsRemainStable,
          RefreshedPacketHardeningValidationCheckId
              .warningLimitedTargetsRemainWarningLimited,
          RefreshedPacketHardeningValidationCheckId
              .pvMultiPvWatchListIsBoundaryOnly,
          RefreshedPacketHardeningValidationCheckId
              .androidProofTargetRemainsProofLimited,
          RefreshedPacketHardeningValidationCheckId
              .noPhase32ECaseClaimsCapturedProof,
          RefreshedPacketHardeningValidationCheckId.ownerProofQueueRemainsEmpty,
          RefreshedPacketHardeningValidationCheckId.quietScopeRemainsExcluded,
          RefreshedPacketHardeningValidationCheckId.productLabelsRemainBlocked,
          RefreshedPacketHardeningValidationCheckId
              .officialMetricsRemainBlocked,
          RefreshedPacketHardeningValidationCheckId
              .futureOnlyInputsRemainFutureOnly,
          RefreshedPacketHardeningValidationCheckId
              .integrationScopesRemainBlocked,
          RefreshedPacketHardeningValidationCheckId
              .noLabelsScoresRankingsMetrics,
          RefreshedPacketHardeningValidationCheckId
              .noEngineOrAndroidRequirement,
        ]),
      );
    });
  });

  group('Validation check behavior', () {
    test('improved targets have Phase 32E and 32F support', () {
      final check = _validation().check(
        RefreshedPacketHardeningValidationCheckId
            .improvedTargetsHaveNewSupportCases,
      );

      expect(
        check.status,
        RefreshedPacketHardeningValidationCheckStatus.passed,
      );
      expect(check.relatedCaseIds, orderedEquals(_phase32ECaseIdsSorted));
      expect(
        check.relatedTargetIds,
        containsAll(<String>[
          'forcingLineInternalPrototypeScope-packet',
          'candidateSpreadInternalPrototypeScope-packet',
          'kingSafetyInternalPrototypeScope',
          'budgetRiskInternalPrototypeScope',
        ]),
      );
    });

    test('warning-limited and PV watch-list checks pass with warnings', () {
      final warningCheck = _validation().check(
        RefreshedPacketHardeningValidationCheckId
            .warningLimitedTargetsRemainWarningLimited,
      );
      final pvCheck = _validation().check(
        RefreshedPacketHardeningValidationCheckId
            .pvMultiPvWatchListIsBoundaryOnly,
      );

      expect(
        warningCheck.status,
        RefreshedPacketHardeningValidationCheckStatus.passedWithWarnings,
      );
      expect(
        warningCheck.severity,
        RefreshedPacketHardeningValidationSeverity.warning,
      );
      expect(
        pvCheck.status,
        RefreshedPacketHardeningValidationCheckStatus.passedWithWarnings,
      );
      expect(
        pvCheck.relatedCaseIds,
        contains('pv-multipv-support-boundary-32e'),
      );
    });

    test('policy checks pass without blockers or criticals', () {
      for (final checkId in const <RefreshedPacketHardeningValidationCheckId>[
        RefreshedPacketHardeningValidationCheckId
            .androidProofTargetRemainsProofLimited,
        RefreshedPacketHardeningValidationCheckId
            .noPhase32ECaseClaimsCapturedProof,
        RefreshedPacketHardeningValidationCheckId.ownerProofQueueRemainsEmpty,
        RefreshedPacketHardeningValidationCheckId.quietScopeRemainsExcluded,
        RefreshedPacketHardeningValidationCheckId.productLabelsRemainBlocked,
        RefreshedPacketHardeningValidationCheckId.officialMetricsRemainBlocked,
        RefreshedPacketHardeningValidationCheckId
            .futureOnlyInputsRemainFutureOnly,
        RefreshedPacketHardeningValidationCheckId
            .integrationScopesRemainBlocked,
        RefreshedPacketHardeningValidationCheckId.noLabelsScoresRankingsMetrics,
        RefreshedPacketHardeningValidationCheckId.noEngineOrAndroidRequirement,
      ]) {
        final check = _validation().check(checkId);
        expect(
          check.status,
          RefreshedPacketHardeningValidationCheckStatus.passed,
          reason: checkId.wire,
        );
        expect(check.blocksStrict, isFalse, reason: checkId.wire);
      }
    });
  });

  group('Target validation behavior', () {
    test('tactical and material targets remain preserved', () {
      _expectAction(
        InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
        RefreshedInternalPacketHardeningActionType.preserveStablePacket,
      );
      _expectAction(
        InternalNonLabelPrototypeScopeId.materialSwingInternalPrototypeScope,
        RefreshedInternalPacketHardeningActionType.preserveStablePacket,
      );
    });

    test(
      'forcing and candidate-spread record improved or preserved support',
      () {
        final forcing = _validation().target(
          InternalNonLabelPrototypeScopeId.forcingLineInternalPrototypeScope,
        );
        final candidate = _validation().target(
          InternalNonLabelPrototypeScopeId
              .candidateSpreadInternalPrototypeScope,
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
      },
    );

    test('PV and MultiPV target remains watch-listed', () {
      final target = _validation().target(
        InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope,
      );

      expect(
        target.refreshedAction,
        RefreshedInternalPacketHardeningActionType.downgradeCoverageNeedToWatch,
      );
      expect(
        target.validationStatus,
        RefreshedPacketHardeningValidationCheckStatus.passedWithWarnings,
      );
      expect(
        target.improvedByCaseIds,
        contains('pv-multipv-support-boundary-32e'),
      );
      expect(target.ownerProofRequired, isFalse);
    });

    test('Android proof target remains proof-limited', () {
      final target = _validation().target(
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
      expect(
        _validation().androidProofCaseIds,
        orderedEquals(_provenAndroidIds),
      );
    });

    test('no Phase 32E case claims captured Android proof', () {
      final capturedIds = _validation().androidProofCaseIds;

      for (final caseId in _phase32ECaseIdsSorted) {
        expect(capturedIds, isNot(contains(caseId)), reason: caseId);
      }
    });

    test('owner proof queue remains empty by default', () {
      final result = _validation();

      expect(result.ownerProofQueueCount, 0);
      expect(
        result.targetSummaries.any((target) => target.ownerProofRequired),
        isFalse,
      );
    });

    test('warning-limited targets remain improved but warning-limited', () {
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
      'quiet, product, metric, future, and integration scopes stay inactive',
      () {
        final result = _validation();

        expect(
          result
              .target(
                InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
              )
              .stillBlocked,
          isTrue,
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

  group('Refreshed validation validator', () {
    test('rejects improved target without impact support', () {
      final result = _validation();
      final summaries = result.targetSummaries.map((target) {
        if (target.scopeId ==
            InternalNonLabelPrototypeScopeId
                .forcingLineInternalPrototypeScope) {
          return target.copyWith(improvedByCaseIds: const <String>[]);
        }
        return target;
      }).toList();

      expect(
        _validator()
            .validate(result.copyWith(targetSummaries: summaries))
            .map((finding) => finding.id),
        contains('improvedTargetMissingImpactSupport'),
      );
    });

    test('rejects warning-limited target promoted to core packet', () {
      final result = _validation();
      final summaries = result.targetSummaries.map((target) {
        if (target.scopeId ==
            InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope) {
          return target.copyWith(
            targetKind: InternalPacketEvidenceHardeningTargetKind.packet,
            refreshedAction:
                RefreshedInternalPacketHardeningActionType.preserveStablePacket,
            stillWarningLimited: false,
          );
        }
        return target;
      }).toList();

      expect(
        _validator()
            .validate(result.copyWith(targetSummaries: summaries))
            .map((finding) => finding.id),
        contains('warningLimitedTargetPromotedToCorePacket'),
      );
    });

    test('rejects blocked scope becoming active', () {
      final result = _validation();
      final summaries = result.targetSummaries.map((target) {
        if (target.scopeId ==
            InternalNonLabelPrototypeScopeId.productLabelPrototypeScope) {
          return target.copyWith(
            refreshedAction:
                RefreshedInternalPacketHardeningActionType.preserveStablePacket,
            stillBlocked: false,
          );
        }
        return target;
      }).toList();

      expect(
        _validator()
            .validate(result.copyWith(targetSummaries: summaries))
            .map((finding) => finding.id),
        contains('blockedScopeBecameActive'),
      );
    });

    test('rejects unproven Android proof', () {
      final result = _validation().copyWith(
        androidProofCaseIds: <String>[
          ..._validation().androidProofCaseIds,
          'unproven-android-proof',
        ],
      );

      expect(
        _validator().validate(result).map((finding) => finding.id),
        contains('unprovenAndroidProofClaim'),
      );
    });

    test('rejects Phase 32E case as captured Android proof', () {
      final result = _validation().copyWith(
        androidProofCaseIds: <String>[
          ..._validation().androidProofCaseIds,
          'pv-multipv-support-boundary-32e',
        ],
      );

      expect(
        _validator().validate(result).map((finding) => finding.id),
        contains('phase32ECaseClaimedCapturedProof'),
      );
    });

    test('rejects owner proof without explicit PV or MultiPV reason', () {
      final result = _validation();
      final summaries = result.targetSummaries.map((target) {
        if (target.scopeId ==
            InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope) {
          return target.copyWith(ownerProofRequired: true);
        }
        return target;
      }).toList();

      expect(
        _validator()
            .validate(result.copyWith(targetSummaries: summaries))
            .map((finding) => finding.id),
        contains('ownerProofRequiredWithoutPvReason'),
      );
    });

    test(
      'rejects label, value, ordering, metric, and quiet activation output',
      () {
        final validator = _validator();

        expect(
          validator
              .validate(_validation().copyWith(classifierLabelsEmitted: true))
              .map((finding) => finding.id),
          contains('validationBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(_validation().copyWith(numericMoveValuesComputed: true))
              .map((finding) => finding.id),
          contains('validationBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(_validation().copyWith(moveOrderingComputed: true))
              .map((finding) => finding.id),
          contains('validationBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(_validation().copyWith(officialMetricsAllowed: true))
              .map((finding) => finding.id),
          contains('validationBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(
                _validation().copyWith(quietPreparatoryScopeActivated: true),
              )
              .map((finding) => finding.id),
          contains('validationBoundaryPolicyViolation'),
        );
      },
    );

    test('normal report text is clean and unsafe report text is rejected', () {
      final validator = _validator();
      final report = _validation().renderMarkdownReport();

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

  group('Refreshed validation report rendering and guardrails', () {
    test('markdown includes required sections', () {
      final report = _validation().renderMarkdownReport();

      expect(report, contains('# Refreshed Packet Hardening Validation'));
      expect(report, contains('## Validation Check Table'));
      expect(report, contains('## Target Validation Summary'));
      expect(report, contains('## Warning-Limited Targets'));
      expect(report, contains('## Owner Proof Queue Status'));
      expect(report, contains('## Phase 32I Recommendation'));
    });

    test('JSON report is deterministic and valid', () {
      final first = _validation().renderJsonReport();
      final second = _validation().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        refreshedPacketHardeningValidationReportVersion,
      );
      expect(decoded['validationStatus'], 'validatedWithWarnings');
      expect(decoded['targetSummaries'], isA<List<Object?>>());
      expect(decoded['safeForPhase32I'], isTrue);
    });

    test(
      'reports contain no raw engine, label, metric, value, or ordering text',
      () {
        final report = _validation().renderMarkdownReport();

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
        'lib/features/pgn_review/application/refreshed_packet_hardening_validation.dart',
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

RefreshedPacketHardeningValidationResult _validation() => _cachedValidation!;

RefreshedInternalPacketHardeningPlanResult _refresh() => _cachedRefresh!;

RefreshedPacketHardeningValidationValidator _validator() {
  return const RefreshedPacketHardeningValidationValidator();
}

void _expectAction(
  InternalNonLabelPrototypeScopeId scopeId,
  RefreshedInternalPacketHardeningActionType action,
) {
  final target = _validation().target(scopeId);
  expect(target.refreshedAction, action, reason: scopeId.wire);
  expect(
    target.validationStatus,
    RefreshedPacketHardeningValidationCheckStatus.passed,
  );
}

void _expectWarningImproved(
  InternalNonLabelPrototypeScopeId scopeId,
  String expectedCaseId,
) {
  final target = _validation().target(scopeId);

  expect(
    target.refreshedAction,
    RefreshedInternalPacketHardeningActionType.keepWarningLimitedButImproved,
    reason: scopeId.wire,
  );
  expect(target.stillWarningLimited, isTrue, reason: scopeId.wire);
  expect(target.stillBlocked, isFalse, reason: scopeId.wire);
  expect(target.improvedByCaseIds, contains(expectedCaseId));
  expect(
    target.validationStatus,
    RefreshedPacketHardeningValidationCheckStatus.passedWithWarnings,
  );
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

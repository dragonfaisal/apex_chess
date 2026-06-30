@TestOn('vm')
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelope', () {
    test(
      'safe default creates a disabled runtime input envelope with warnings',
      () {
        final result =
            const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelope()
                .evaluate();

        expect(
          result.status,
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeStatus
              .disabledAnalyzerAdapterRuntimeInputEnvelopeReadyWithWarnings,
        );
        expect(result.safeForPhase34R, isTrue);
        expect(
          result.nextRecommendation,
          'runDisabledAnalyzerAdapterRuntimeInputEnvelopeDiagnostic',
        );
        expect(result.unsafeCount, 0);
        expect(result.blockerCount, 0);
        expect(result.criticalCount, 0);
        expect(result.disabledEnvelopeCount, greaterThanOrEqualTo(1));
        expect(result.activeRuntimeInputEnvelopeCount, 0);
        expect(result.analyzerRuntimeInputApprovedCount, 0);
        expect(result.analyzerRuntimeInputProducedCount, 0);
        expect(result.runtimeExecutionApprovedCount, 0);
        expect(result.runtimeExecutionCount, 0);
        expect(result.analyzerWiringCount, 0);
        expect(result.executableRuntimeCount, 0);
        expect(result.engineCallCount, 0);
        expect(result.schedulerExecutionCount, 0);
        expect(result.persistenceWriteCount, 0);
        expect(result.productOutputCount, 0);
        expect(result.productAdapterCount, 0);
        expect(result.savedAnalysisIntegrationCount, 0);
        expect(result.activePayloadSlotCount, 0);
        expect(result.activeDeniedFieldCount, 0);
        expect(result.ownerProofQueueCount, 0);
        expect(result.phase32EProofClaimCount, 0);
        expect(result.unprovenAndroidProofCount, 0);
        expect(result.slotCount, 21);
        expect(result.boundaryCount, 17);
        expect(result.blockedReasonCount, 26);
      },
    );

    test('slots remain disabled, unset, blocked or redacted only', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelope()
              .evaluate();
      final slotIds = result.slots.map((slot) => slot.slotId).toSet();

      expect(
        slotIds,
        containsAll(const <String>[
          'sourceChainSlot',
          'selectedGoldenSupportSlot',
          'proofBoundarySlot',
          'deniedFieldSlot',
          'runtimeInputCandidateSlot',
          'fenPayloadSlotBlocked',
          'pgnPayloadSlotBlocked',
          'moveListSlotBlocked',
          'uciMoveSlotBlocked',
          'engineOptionSlotBlocked',
          'depthSlotBlocked',
          'multiPvSlotBlocked',
          'stockfishCommandSlotBlocked',
          'rawUciSlotBlocked',
          'pvDumpSlotBlocked',
          'productLabelSlotBlocked',
          'scoreMetricSlotBlocked',
          'persistenceSlotBlocked',
          'schedulerSlotBlocked',
          'productAdapterSlotBlocked',
          'savedAnalysisSlotBlocked',
        ]),
      );
      expect(result.slots.every((slot) => slot.disabled), isTrue);
      expect(result.slots.every((slot) => slot.unset), isTrue);
      expect(result.slots.every((slot) => slot.redacted), isTrue);
      expect(result.slots.every((slot) => !slot.activePayloadPresent), isTrue);
      expect(
        result.slots
            .where((slot) => slot.slotId.endsWith('SlotBlocked'))
            .every((slot) => slot.blocked),
        isTrue,
      );
    });

    test('boundaries and blocked reasons remain blocked', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelope()
              .evaluate();

      expect(
        result.boundaries.map((boundary) => boundary.boundaryId),
        containsAll(const <String>[
          'disabledRuntimeInputEnvelopeBoundary',
          'analyzerRuntimeInputBoundary',
          'analyzerRuntimeInputApprovalBoundary',
          'runtimeExecutionBoundary',
          'analyzerWiringBoundary',
          'engineCallBoundary',
          'stockfishBridgeBoundary',
          'androidCollectorBoundary',
          'schedulerExecutionBoundary',
          'persistenceWriteBoundary',
          'productOutputBoundary',
          'productAdapterBoundary',
          'savedAnalysisBoundary',
          'uiBoundary',
          'backendBoundary',
          'cacheBoundary',
          'databaseBoundary',
        ]),
      );
      expect(result.boundaries.every((boundary) => boundary.blocked), isTrue);
      expect(
        result.blockedReasons.map((reason) => reason.blockedReasonId),
        containsAll(const <String>[
          'runtimeInputEnvelopeDisabledByPolicy',
          'analyzerRuntimeInputNotApproved',
          'analyzerRuntimeInputProductionBlocked',
          'runtimeExecutionNotApproved',
          'executionAllowedFalse',
          'analyzerRuntimeInputBoundaryBlocked',
          'analyzerWiringBlocked',
          'engineCallsBlocked',
          'stockfishCommandBlocked',
          'rawUciBlocked',
          'pvDumpBlocked',
          'androidCollectorBlocked',
          'schedulerExecutionBlocked',
          'persistenceWriteBlocked',
          'productOutputBlocked',
          'productAdapterBlocked',
          'savedAnalysisBlocked',
          'uiBackendBlocked',
          'cacheDatabaseBlocked',
          'productLabelsBlocked',
          'numericScoresBlocked',
          'officialMetricsBlocked',
          'cpLossBlocked',
          'winProbabilityBlocked',
          'phase32EProofHonestyPreserved',
          'quietPreparatoryExclusionPreserved',
        ]),
      );
      expect(result.blockedReasons.every((reason) => reason.blocked), isTrue);
    });

    test('unsafe Phase 34P diagnostic blocks the envelope', () {
      final safe =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnostic()
              .evaluate();
      final unsafe =
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticResult(
            status:
                DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticStatus
                    .blockedByPolicyBoundary,
            mode: safe.mode,
            sourceRuntimeInputPreflightStatus:
                safe.sourceRuntimeInputPreflightStatus,
            sourceSeamProbeDiagnosticStatus:
                safe.sourceSeamProbeDiagnosticStatus,
            sourceSeamProbeStatus: safe.sourceSeamProbeStatus,
            sourceRuntimeExecutionPreflightDiagnosticStatus:
                safe.sourceRuntimeExecutionPreflightDiagnosticStatus,
            sourceRuntimeExecutionPreflightStatus:
                safe.sourceRuntimeExecutionPreflightStatus,
            rows: safe.rows,
            findings: const <String>['unsafeFixture'],
            safeForPhase34Q: false,
            nextRecommendation: 'blockedFixture',
          );

      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelope()
              .evaluate(runtimeInputPreflightDiagnosticResult: unsafe);

      expect(result.safeForPhase34R, isFalse);
      expect(
        result.findings,
        contains('unsafePhase34PRuntimeInputPreflightDiagnostic'),
      );
      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeStatus
            .blockedByPolicyBoundary,
      );
    });

    test('safe methods remain deterministic and metadata-only', () {
      const envelope =
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelope();
      final result = envelope.evaluate();
      final snapshot = envelope.renderDisabledRuntimeInputEnvelopeSnapshot(
        result,
      );
      final validation = envelope.validateDisabledRuntimeInputEnvelope(result);

      expect(
        snapshot,
        contains('# Disabled Analyzer Adapter Runtime Input Envelope'),
      );
      expect(snapshot, contains('## Slot Summary'));
      expect(validation, isEmpty);
      expect(
        jsonDecode(result.renderJson()) as Map<String, Object?>,
        containsPair('safeForPhase34R', true),
      );
    });

    test(
      'validator rejects active payload, runtime input, runtime, product, and leaks',
      () {
        final result =
            const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelope()
                .evaluate();
        const validator =
            DisabledAnalyzerAdapterRuntimeInputEnvelopeValidator();

        final inputFindings = validator.validateInput(
          result.input.copyWith(
            recommendation: 'wrongRecommendation',
            envelopeCreated: false,
            envelopeDisabled: false,
            activeRuntimeInputEnvelope: true,
            analyzerRuntimeInputApproved: true,
            analyzerRuntimeInputProduced: true,
            runtimeExecutionApproved: true,
            executionAllowed: true,
            executionPerformed: true,
            analyzerWiringAllowed: true,
            engineCallsAllowed: true,
            schedulerAllowed: true,
            persistenceAllowed: true,
            productOutputAllowed: true,
            productAdapterAllowed: true,
            savedAnalysisAllowed: true,
            sourceCaseIds: const <String>['pv-multipv-support-boundary-32e'],
            supportAreaIds: const <String>['quietPreparatoryMove'],
            proofLimitReasons: const <String>[],
            androidProofIds: const <String>[
              'king-safety-mating-net-pressure-32e',
            ],
            ownerProofRequired: true,
            boundaryIds: const <String>['active:runtimeInputBoundary'],
            blockedReasonIds: const <String>['active:runtimeInputReason'],
            deniedFieldIds: const <String>[
              'active:productLabel',
              'active:finalMoveLabel',
              'active:classifierLabels',
              'active:brilliantGreatMiss',
              'active:bestGoodInaccuracyMistakeBlunder',
              'active:numericMoveScore',
              'active:aggregateScore',
              'active:officialMetric',
              'active:accuracy',
              'active:acpl',
              'active:cpLoss',
              'active:winProbability',
              'active:moveRanking',
              'active:thresholds',
              'active:stockfishCommand',
              'active:rawUci',
              'active:pvDump',
              'active:androidCollectorRequirement',
              'active:playableFenPayload',
              'active:pgnPayload',
              'active:moveListPayload',
              'active:uciMovePayload',
              'active:engineOptionPayload',
              'active:depthAnalysisValue',
              'active:multiPvAnalysisValue',
              'active:analyzerRuntimeInput',
              'active:analyzerRuntimeInputApproval',
              'active:analyzerRuntimeInputProduction',
              'active:activeRuntimeInputEnvelope',
              'active:runtimeExecutionResult',
              'active:analyzerResult',
              'active:engineResult',
              'active:schedulerExecutionResult',
              'active:cacheDatabaseWrite',
              'active:productAdapterBehavior',
              'active:savedAnalysisIntegration',
              'active:readinessSummaryChain',
              'active:readinessGate',
            ],
          ),
        );
        final slotFindings = validator.validateSlot(
          result.slots.first.copyWith(
            slotId: 'unknownSlot',
            disabled: false,
            unset: false,
            blocked: false,
            redacted: false,
            activePayloadPresent: true,
            deniedFieldIds: const <String>['active:playableFenPayload'],
            recommendation: 'wrongRecommendation',
          ),
        );
        final policyFindings = validator.validatePolicy(
          result.policy.copyWith(
            envelopeDisabled: false,
            activeRuntimeInputEnvelopeAllowed: true,
            analyzerRuntimeInputApproved: true,
            analyzerRuntimeInputProduced: true,
            runtimeExecutionApproved: true,
            executionAllowed: true,
            executionPerformed: true,
            analyzerWiringAllowed: true,
            engineCallsAllowed: true,
            schedulerAllowed: true,
            persistenceAllowed: true,
            productOutputAllowed: true,
            productAdapterAllowed: true,
            savedAnalysisAllowed: true,
            uiAllowed: true,
            backendAllowed: true,
            cacheAllowed: true,
            databaseAllowed: true,
            deniedFieldIds: const <String>['active:cacheDatabaseWrite'],
            recommendation: 'wrongRecommendation',
          ),
        );
        final boundaryFindings = validator.validateBoundary(
          result.boundaries.first.copyWith(
            boundaryId: 'unknownBoundary',
            blocked: false,
            deniedFieldIds: const <String>['active:engineResult'],
            recommendation: 'wrongRecommendation',
          ),
        );
        final reasonFindings = validator.validateBlockedReason(
          result.blockedReasons.first.copyWith(
            blockedReasonId: 'unknownReason',
            blocked: false,
            deniedFieldIds: const <String>['active:schedulerExecutionResult'],
            recommendation: 'wrongRecommendation',
          ),
        );
        final reportFindings = validator.validateReportText(
          'position fen x go movetime 10 info depth 1 pv e2e4 playable fen payload pgn payload: uci move payload',
        );

        expect(
          inputFindings,
          containsAll(const <String>[
            'missingPhase34RDisabledRuntimeInputEnvelopeDiagnosticRecommendation',
            'disabledRuntimeInputEnvelopeMissing',
            'runtimeInputEnvelopeNotDisabled',
            'activeRuntimeInputEnvelopeEnabled',
            'analyzerRuntimeInputApproved',
            'analyzerRuntimeInputProduced',
            'runtimeExecutionApprovedEnabled',
            'executionAllowedEnabled',
            'executionPerformedEnabled',
            'analyzerWiringEnabled',
            'engineCallsEnabled',
            'schedulerExecutionEnabled',
            'persistenceWriteEnabled',
            'productOutputEnabled',
            'productAdapterEnabled',
            'savedAnalysisIntegrationEnabled',
            'boundaryActivated',
            'blockedReasonActivated',
            'activeDeniedFields',
            'productLabelsEnabled',
            'finalLabelsEnabled',
            'classifierLabelsEnabled',
            'scoresEnabled',
            'rankingsMetricsAccuracyAcplEnabled',
            'cpLossEnabled',
            'winProbabilityEnabled',
            'thresholdsEnabled',
            'stockfishCommandEnabled',
            'rawUciEnabled',
            'pvDumpEnabled',
            'androidCollectorRequirementEnabled',
            'playableFenPayloadEnabled',
            'pgnPayloadEnabled',
            'moveListPayloadEnabled',
            'uciMovePayloadEnabled',
            'engineOptionPayloadEnabled',
            'depthAnalysisValueEnabled',
            'multiPvAnalysisValueEnabled',
            'analyzerRuntimeInputEnabled',
            'runtimeExecutionResultEnabled',
            'analyzerResultEnabled',
            'engineResultEnabled',
            'schedulerExecutionResultEnabled',
            'cacheDatabaseWriteEnabled',
            'productAdapterBehaviorEnabled',
            'readinessSummaryChainEnabled',
            'readinessGateEnabled',
            'quietPreparatoryPromotion',
            'pvMultiPvPromotion',
            'phase32ECapturedProofClaim',
            'ownerProofWithoutPvMultiPvReason',
          ]),
        );
        expect(
          slotFindings,
          containsAll(const <String>[
            'unknownRuntimeInputEnvelopeSlot',
            'runtimeInputSlotNotDisabledUnsetBlockedOrRedacted',
            'runtimeInputSlotActivePayloadPresent',
            'activeDeniedFields',
            'playableFenPayloadEnabled',
            'missingPhase34RDisabledRuntimeInputEnvelopeDiagnosticRecommendation',
          ]),
        );
        expect(
          policyFindings,
          containsAll(const <String>[
            'runtimeInputEnvelopeNotDisabled',
            'activeRuntimeInputEnvelopeEnabled',
            'analyzerRuntimeInputApproved',
            'analyzerRuntimeInputProduced',
            'runtimeExecutionApprovedEnabled',
            'executionAllowedEnabled',
            'executionPerformedEnabled',
            'analyzerWiringEnabled',
            'engineCallsEnabled',
            'schedulerExecutionEnabled',
            'persistenceWriteEnabled',
            'productOutputEnabled',
            'productAdapterEnabled',
            'savedAnalysisIntegrationEnabled',
            'uiBackendActivation',
            'cacheDatabaseWriteEnabled',
            'activeDeniedFields',
            'missingPhase34RDisabledRuntimeInputEnvelopeDiagnosticRecommendation',
          ]),
        );
        expect(
          boundaryFindings,
          containsAll(const <String>[
            'unknownRuntimeInputEnvelopeBoundary',
            'runtimeInputEnvelopeBoundaryUnblocked',
            'activeDeniedFields',
            'engineResultEnabled',
            'missingPhase34RDisabledRuntimeInputEnvelopeDiagnosticRecommendation',
          ]),
        );
        expect(
          reasonFindings,
          containsAll(const <String>[
            'unknownRuntimeInputEnvelopeBlockedReason',
            'blockedReasonActivated',
            'activeDeniedFields',
            'schedulerExecutionResultEnabled',
            'missingPhase34RDisabledRuntimeInputEnvelopeDiagnosticRecommendation',
          ]),
        );
        expect(
          reportFindings,
          containsAll(const <String>[
            'reportTextLeak:stockfishPosition',
            'reportTextLeak:stockfishCommand',
            'reportTextLeak:pvDump',
            'reportTextLeak:playableFenPayload',
            'reportTextLeak:pgnPayload',
            'reportTextLeak:uciMovePayload',
          ]),
        );
      },
    );
  });
}

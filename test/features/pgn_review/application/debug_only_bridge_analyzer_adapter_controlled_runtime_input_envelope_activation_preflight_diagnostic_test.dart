@TestOn('vm')
library;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_envelope_activation_preflight.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_envelope_activation_preflight_diagnostic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnostic',
    () {
      test('safe default reports activation preflight diagnostic', () {
        final result =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnostic()
                .evaluate();

        expect(
          result.status,
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticStatus
              .controlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDiagnosticReadyWithWarnings,
        );
        expect(
          result.mode,
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
              .defaultMode,
        );
        expect(result.safeForPhase34U, isTrue);
        expect(
          result.nextRecommendation,
          'implementDisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidatePatch',
        );
        expect(result.unsafeCount, 0);
        expect(result.blockerCount, 0);
        expect(result.criticalCount, 0);
        expect(result.disabledEnvelopeCount, greaterThanOrEqualTo(1));
        expect(result.activationPreflightCount, greaterThanOrEqualTo(1));
        expect(result.activationApprovedCount, 0);
        expect(result.activationPerformedCount, 0);
        expect(result.activeRuntimeInputEnvelopeCount, 0);
        expect(result.playablePayloadCount, 0);
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
        expect(result.activeDeniedFieldCount, 0);
        expect(result.ownerProofQueueCount, 0);
        expect(result.totalDiagnosticRows, 71);
        expect(result.checkDiagnosticRowCount, 38);
        expect(result.decisionDiagnosticRowCount, 1);
        expect(result.blockedReasonDiagnosticRowCount, 29);
        expect(result.deniedDiagnosticRowCount, 1);
        expect(result.proofDiagnosticRowCount, 1);
        expect(result.recommendationDiagnosticRowCount, 1);
      });

      test('diagnostic modes are deterministic and keep activation disabled', () {
        for (final mode
            in DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
                .values) {
          final result =
              const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnostic()
                  .evaluate(mode: mode);

          expect(result.mode, mode);
          expect(result.safeForPhase34U, isTrue, reason: mode.wire);
          expect(result.unsafeCount, 0, reason: mode.wire);
          expect(
            result.rows.every((row) => row.diagnosticMode == mode.wire),
            isTrue,
            reason: mode.wire,
          );
          expect(
            result.rows.every((row) => row.envelopeDisabled),
            isTrue,
            reason: mode.wire,
          );
          expect(
            result.rows.every((row) => !row.activationApproved),
            isTrue,
            reason: mode.wire,
          );
          expect(
            result.rows.every((row) => !row.activationPerformed),
            isTrue,
            reason: mode.wire,
          );
          expect(
            result.rows.every((row) => !row.activeRuntimeInputEnvelope),
            isTrue,
            reason: mode.wire,
          );
          expect(
            result.rows.every((row) => row.playablePayloadCount == 0),
            isTrue,
            reason: mode.wire,
          );
          expect(
            result.rows.every((row) => !row.analyzerRuntimeInputProduced),
            isTrue,
            reason: mode.wire,
          );
        }
      });

      test('mode-specific row counts match activation preflight areas', () {
        final checks =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnostic()
                .evaluate(
                  mode:
                      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
                          .checks,
                );
        final decision =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnostic()
                .evaluate(
                  mode:
                      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
                          .decision,
                );
        final blocked =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnostic()
                .evaluate(
                  mode:
                      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
                          .blockedReasons,
                );
        final recommendation =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnostic()
                .evaluate(
                  mode:
                      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
                          .recommendation,
                );

        expect(checks.totalDiagnosticRows, checks.checkDiagnosticRowCount);
        expect(checks.totalDiagnosticRows, 38);
        expect(
          decision.totalDiagnosticRows,
          decision.decisionDiagnosticRowCount,
        );
        expect(decision.totalDiagnosticRows, 1);
        expect(
          blocked.totalDiagnosticRows,
          blocked.blockedReasonDiagnosticRowCount,
        );
        expect(blocked.totalDiagnosticRows, 29);
        expect(recommendation.totalDiagnosticRows, 1);
        expect(recommendation.recommendationDiagnosticRowCount, 1);
      });

      test('unsafe Phase 34S activation preflight blocks diagnostic', () {
        final safe =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflight()
                .evaluate();
        final unsafe =
            ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult(
              status:
                  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightStatus
                      .blockedByPolicyBoundary,
              sourceDisabledRuntimeInputEnvelopeDiagnosticStatus:
                  safe.sourceDisabledRuntimeInputEnvelopeDiagnosticStatus,
              sourceDisabledRuntimeInputEnvelopeStatus:
                  safe.sourceDisabledRuntimeInputEnvelopeStatus,
              sourceRuntimeInputPreflightDiagnosticStatus:
                  safe.sourceRuntimeInputPreflightDiagnosticStatus,
              sourceRuntimeInputPreflightStatus:
                  safe.sourceRuntimeInputPreflightStatus,
              sourceDisabledSeamProbeDiagnosticStatus:
                  safe.sourceDisabledSeamProbeDiagnosticStatus,
              input: safe.input.copyWith(activationApproved: true),
              checks: safe.checks,
              policy: safe.policy,
              decision: safe.decision,
              blockedReasons: safe.blockedReasons,
              findings: const <String>['unsafeFixture'],
              safeForPhase34T: false,
              nextRecommendation: 'blockedFixture',
            );

        final result =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnostic()
                .evaluate(activationPreflightResult: unsafe);

        expect(result.safeForPhase34U, isFalse);
        expect(
          result.findings,
          contains('unsafePhase34SRuntimeInputEnvelopeActivationPreflight'),
        );
      });

      test('validator rejects activation, payload, runtime, product, and leaks', () {
        final result =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnostic()
                .evaluate();
        final row = result.rows.first;
        const validator =
            DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticValidator();

        final findings = validator.validateRow(
          row.copyWith(
            diagnosticMode: 'missing',
            recommendation: 'wrongRecommendation',
            envelopeDisabled: false,
            activationPreflightCreated: false,
            activationApproved: true,
            activationPerformed: true,
            activeRuntimeInputEnvelope: true,
            playablePayloadCount: 1,
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
            checkIds: const <String>['active:activationCheck'],
            blockedReasonIds: const <String>['active:activationReason'],
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
            findings: const <String>['unsafeFixture'],
          ),
        );
        final reportFindings = validator.validateReportText(
          'activationApproved: true activationPerformed: true activeRuntimeInputEnvelope: true position fen x go movetime 10 info depth 1 pv e2e4 playable fen payload pgn payload: uci move payload',
        );

        expect(
          findings,
          containsAll(<String>[
            'unknownRuntimeInputEnvelopeActivationPreflightDiagnosticMode',
            'missingPhase34UDisabledActivationCandidateRecommendation',
            'runtimeInputEnvelopeNotDisabled',
            'activationPreflightMissing',
            'activationApproved',
            'activationPerformed',
            'activeRuntimeInputEnvelopeEnabled',
            'playablePayloadEnabled',
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
            'preflightCheckActivated',
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
            'analyzerRuntimeInputEnabled',
            'analyzerRuntimeInputApprovalEnabled',
            'analyzerRuntimeInputProductionEnabled',
            'activeRuntimeInputEnvelopeFieldEnabled',
            'playableFenPayloadEnabled',
            'pgnPayloadEnabled',
            'moveListPayloadEnabled',
            'uciMovePayloadEnabled',
            'engineOptionPayloadEnabled',
            'depthAnalysisValueEnabled',
            'multiPvAnalysisValueEnabled',
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
            'diagnosticRowFindingsPresent',
          ]),
        );
        expect(
          reportFindings,
          containsAll(<String>[
            'reportTextLeak:activationApproved',
            'reportTextLeak:activationPerformed',
            'reportTextLeak:activeRuntimeInputEnvelope',
            'reportTextLeak:stockfishCommand',
            'reportTextLeak:pvDump',
            'reportTextLeak:playableFenPayload',
            'reportTextLeak:pgnPayload',
            'reportTextLeak:uciMovePayload',
          ]),
        );
      });
    },
  );
}

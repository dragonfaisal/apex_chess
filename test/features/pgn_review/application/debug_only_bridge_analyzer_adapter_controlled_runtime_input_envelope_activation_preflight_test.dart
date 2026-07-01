@TestOn('vm')
library;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_envelope_activation_preflight.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope_diagnostic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflight',
    () {
      test('safe default reports controlled activation preflight only', () {
        final result =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflight()
                .evaluate();

        expect(
          result.status,
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightStatus
              .controlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightReadyWithWarnings,
        );
        expect(result.safeForPhase34T, isTrue);
        expect(
          result.nextRecommendation,
          'runControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDiagnostic',
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
        expect(result.totalChecks, 38);
        expect(result.passedCheckCount, 38);
        expect(result.blockedReasonCount, 29);
      });

      test('preflight checks and blocked reasons are deterministic', () {
        final result =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflight()
                .evaluate();
        final checkIds = result.checks.map((check) => check.checkId).toList();
        final blockedReasonIds = result.blockedReasons
            .map((reason) => reason.blockedReasonId)
            .toList();

        expect(checkIds, contains('disabledEnvelopeDiagnosticPresent'));
        expect(checkIds, contains('envelopeCreatedAsDisabledMetadata'));
        expect(checkIds, contains('activationApprovedFalse'));
        expect(checkIds, contains('activationPerformedFalse'));
        expect(checkIds, contains('playablePayloadCountZero'));
        expect(checkIds, contains('fenPayloadBlocked'));
        expect(checkIds, contains('multiPvPayloadBlocked'));
        expect(checkIds, contains('phase32EProofHonestyPreserved'));
        expect(result.checks.every((check) => check.passed), isTrue);
        expect(
          blockedReasonIds,
          contains('runtimeInputEnvelopeActivationNotApproved'),
        );
        expect(blockedReasonIds, contains('activeRuntimeInputEnvelopeBlocked'));
        expect(blockedReasonIds, contains('playablePayloadsBlocked'));
        expect(blockedReasonIds, contains('stockfishCommandBlocked'));
        expect(
          blockedReasonIds,
          contains('quietPreparatoryExclusionPreserved'),
        );
        expect(result.blockedReasons.every((reason) => reason.blocked), isTrue);
      });

      test('unsafe Phase 34R diagnostic blocks activation preflight', () {
        final safe =
            const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnostic()
                .evaluate();
        final unsafe =
            DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticResult(
              status:
                  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticStatus
                      .blockedByPolicyBoundary,
              mode: safe.mode,
              sourceDisabledRuntimeInputEnvelopeStatus:
                  safe.sourceDisabledRuntimeInputEnvelopeStatus,
              sourceRuntimeInputPreflightDiagnosticStatus:
                  safe.sourceRuntimeInputPreflightDiagnosticStatus,
              sourceRuntimeInputPreflightStatus:
                  safe.sourceRuntimeInputPreflightStatus,
              sourceSeamProbeDiagnosticStatus:
                  safe.sourceSeamProbeDiagnosticStatus,
              sourceSeamProbeStatus: safe.sourceSeamProbeStatus,
              rows:
                  <
                    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticRow
                  >[safe.rows.first.copyWith(activeRuntimeInputEnvelope: true)],
              findings: const <String>['unsafeFixture'],
              safeForPhase34S: false,
              nextRecommendation: 'blockedFixture',
            );

        final result =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflight()
                .evaluate(disabledRuntimeInputEnvelopeDiagnosticResult: unsafe);

        expect(result.safeForPhase34T, isFalse);
        expect(
          result.findings,
          contains('unsafePhase34RDisabledRuntimeInputEnvelopeDiagnostic'),
        );
      });

      test('validator rejects activation, payload, runtime, product, and leaks', () {
        final result =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflight()
                .evaluate();
        const validator =
            ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightValidator();

        final inputFindings = validator.validateInput(
          result.input.copyWith(
            sourceCaseIds: const <String>['pv-multipv-support-boundary-32e'],
            supportAreaIds: const <String>['quietPreparatoryMove'],
            proofLimitReasons: const <String>[],
            androidProofIds: const <String>[
              'king-safety-mating-net-pressure-32e',
            ],
            ownerProofRequired: true,
            envelopeDisabled: false,
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
            blockedReasonIds: const <String>['active:activation'],
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
            recommendation: 'wrongRecommendation',
          ),
        );
        final checkFindings = validator.validateCheck(
          result.checks.first.copyWith(
            checkId: 'unknown',
            passed: false,
            blockedReasonIds: const <String>['active:blockedReason'],
            deniedFieldIds: const <String>['active:productLabel'],
            recommendation: 'wrongRecommendation',
          ),
        );
        final policyFindings = validator.validatePolicy(
          result.policy.copyWith(
            envelopeDisabled: false,
            activationAllowed: true,
            activationPerformed: true,
            activeRuntimeInputEnvelopeAllowed: true,
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
            uiAllowed: true,
            backendAllowed: true,
            cacheAllowed: true,
            databaseAllowed: true,
            deniedFieldIds: const <String>['active:stockfishCommand'],
            recommendation: 'wrongRecommendation',
          ),
        );
        final decisionFindings = validator.validateDecision(
          result.decision.copyWith(
            envelopeDisabled: false,
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
            blockedReasonIds: const <String>['active:decision'],
            recommendation: 'wrongRecommendation',
          ),
        );
        final blockedReasonFindings = validator.validateBlockedReason(
          result.blockedReasons.first.copyWith(
            blockedReasonId: 'unknown',
            blocked: false,
            deniedFieldIds: const <String>['active:productLabel'],
            recommendation: 'wrongRecommendation',
          ),
        );
        final reportFindings = validator.validateReportText(
          'position fen x go movetime 10 info depth 1 pv e2e4 playable fen payload pgn payload: uci move payload activationApproved: true activationPerformed: true activeRuntimeInputEnvelope: true',
        );

        expect(
          inputFindings,
          containsAll(<String>[
            'missingPhase34TActivationPreflightDiagnosticRecommendation',
            'runtimeInputEnvelopeNotDisabled',
            'activationApprovedEnabled',
            'activationPerformedEnabled',
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
            'quietPreparatoryPromotion',
            'pvMultiPvPromotion',
            'phase32ECapturedProofClaim',
            'ownerProofWithoutPvMultiPvReason',
          ]),
        );
        expect(
          checkFindings,
          containsAll(<String>[
            'unknownActivationPreflightCheck',
            'activationPreflightCheckFailed',
            'blockedReasonActivated',
            'activeDeniedFields',
          ]),
        );
        expect(policyFindings, contains('uiBackendActivation'));
        expect(policyFindings, contains('cacheDatabaseWriteEnabled'));
        expect(decisionFindings, contains('activationApprovedEnabled'));
        expect(blockedReasonFindings, contains('blockedReasonActivated'));
        expect(
          reportFindings,
          containsAll(<String>[
            'reportTextLeak:stockfishPosition',
            'reportTextLeak:stockfishCommand',
            'reportTextLeak:pvDump',
            'reportTextLeak:playableFenPayload',
            'reportTextLeak:pgnPayload',
            'reportTextLeak:uciMovePayload',
            'reportTextLeak:activationApproval',
            'reportTextLeak:activationPerformed',
            'reportTextLeak:activeRuntimeInputEnvelope',
          ]),
        );
      });
    },
  );
}

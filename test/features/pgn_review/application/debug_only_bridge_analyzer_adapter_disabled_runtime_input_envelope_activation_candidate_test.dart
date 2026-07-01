@TestOn('vm')
library;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_envelope_activation_preflight_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope_activation_candidate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidate',
    () {
      test('safe default creates disabled activation candidate only', () {
        final result =
            const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidate()
                .evaluate();

        expect(
          result.status,
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateStatus
              .disabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateReadyWithWarnings,
        );
        expect(result.safeForPhase34V, isTrue);
        expect(
          result.nextRecommendation,
          'runDisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateDiagnostic',
        );
        expect(result.unsafeCount, 0);
        expect(result.blockerCount, 0);
        expect(result.criticalCount, 0);
        expect(result.disabledEnvelopeCount, greaterThanOrEqualTo(1));
        expect(result.activationPreflightCount, greaterThanOrEqualTo(1));
        expect(result.activationCandidateCount, greaterThanOrEqualTo(1));
        expect(result.activationCandidateApprovedCount, 0);
        expect(result.activationCandidatePromotedCount, 0);
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
        expect(result.candidateRecordCount, 16);
        expect(result.boundaryCount, 21);
        expect(result.blockedReasonCount, 31);
      });

      test('candidate records boundaries and reasons are deterministic', () {
        final result =
            const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidate()
                .evaluate();
        final recordIds = result.records.map((record) => record.recordId);
        final boundaryIds = result.boundaries.map(
          (boundary) => boundary.boundaryId,
        );
        final blockedReasonIds = result.blockedReasons.map(
          (reason) => reason.blockedReasonId,
        );

        expect(recordIds, contains('disabledActivationCandidateRecord'));
        expect(recordIds, contains('sourceEnvelopeReferenceRecord'));
        expect(recordIds, contains('activationPreflightReferenceRecord'));
        expect(
          recordIds,
          contains('activationPreflightDiagnosticReferenceRecord'),
        );
        expect(recordIds, contains('blockedPlayablePayloadRecord'));
        expect(recordIds, contains('blockedAnalyzerRuntimeInputRecord'));
        expect(recordIds, contains('proofBoundaryRecord'));
        expect(recordIds, contains('recommendationRecord'));
        expect(result.records.every((record) => record.metadataOnly), isTrue);
        expect(result.records.every((record) => record.disabled), isTrue);
        expect(result.records.every((record) => record.blocked), isTrue);
        expect(boundaryIds, contains('disabledActivationCandidateBoundary'));
        expect(boundaryIds, contains('activationApprovalBoundary'));
        expect(boundaryIds, contains('activationPromotionBoundary'));
        expect(boundaryIds, contains('activeRuntimeInputEnvelopeBoundary'));
        expect(boundaryIds, contains('playablePayloadBoundary'));
        expect(boundaryIds, contains('analyzerRuntimeInputBoundary'));
        expect(boundaryIds, contains('stockfishBridgeBoundary'));
        expect(boundaryIds, contains('databaseBoundary'));
        expect(result.boundaries.every((boundary) => boundary.blocked), isTrue);
        expect(
          blockedReasonIds,
          contains('activationCandidateDisabledByPolicy'),
        );
        expect(
          blockedReasonIds,
          contains('activationCandidateApprovalBlocked'),
        );
        expect(
          blockedReasonIds,
          contains('activationCandidatePromotionBlocked'),
        );
        expect(blockedReasonIds, contains('playablePayloadsBlocked'));
        expect(blockedReasonIds, contains('stockfishCommandBlocked'));
        expect(
          blockedReasonIds,
          contains('quietPreparatoryExclusionPreserved'),
        );
        expect(result.blockedReasons.every((reason) => reason.blocked), isTrue);
      });

      test('unsafe Phase 34T diagnostic blocks activation candidate', () {
        final safe =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnostic()
                .evaluate();
        final unsafe =
            DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticResult(
              status:
                  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticStatus
                      .blockedByPolicyBoundary,
              mode: safe.mode,
              sourceActivationPreflightStatus:
                  safe.sourceActivationPreflightStatus,
              sourceDisabledRuntimeInputEnvelopeDiagnosticStatus:
                  safe.sourceDisabledRuntimeInputEnvelopeDiagnosticStatus,
              sourceDisabledRuntimeInputEnvelopeStatus:
                  safe.sourceDisabledRuntimeInputEnvelopeStatus,
              sourceRuntimeInputPreflightDiagnosticStatus:
                  safe.sourceRuntimeInputPreflightDiagnosticStatus,
              sourceRuntimeInputPreflightStatus:
                  safe.sourceRuntimeInputPreflightStatus,
              rows:
                  <
                    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticRow
                  >[safe.rows.first.copyWith(activationApproved: true)],
              findings: const <String>['unsafeFixture'],
              safeForPhase34U: false,
              nextRecommendation: 'blockedFixture',
            );

        final result =
            const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidate()
                .evaluate(activationPreflightDiagnosticResult: unsafe);

        expect(result.safeForPhase34V, isFalse);
        expect(
          result.findings,
          contains('unsafePhase34TActivationPreflightDiagnostic'),
        );
      });

      test(
        'validator rejects approval, promotion, activation, payload, runtime, product, and leaks',
        () {
          final result =
              const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidate()
                  .evaluate();
          const validator =
              DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateValidator();

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
              activationCandidateDisabled: false,
              activationCandidateApproved: true,
              activationCandidatePromoted: true,
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
              candidateRecordIds: const <String>['active:candidate'],
              boundaryIds: const <String>['active:boundary'],
              blockedReasonIds: const <String>['active:blockedReason'],
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
                'active:activationCandidateApproval',
                'active:activationCandidatePromotion',
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
          final recordFindings = validator.validateRecord(
            result.records.first.copyWith(
              recordId: 'unknown',
              metadataOnly: false,
              disabled: false,
              blocked: false,
              deniedFieldIds: const <String>['active:productLabel'],
              recommendation: 'wrongRecommendation',
            ),
          );
          final policyFindings = validator.validatePolicy(
            result.policy.copyWith(
              envelopeDisabled: false,
              activationCandidateDisabled: false,
              activationCandidateApprovalAllowed: true,
              activationCandidatePromotionAllowed: true,
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
          final boundaryFindings = validator.validateBoundary(
            result.boundaries.first.copyWith(
              boundaryId: 'unknown',
              blocked: false,
              deniedFieldIds: const <String>['active:productLabel'],
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
            'position fen x go movetime 10 info depth 1 pv e2e4 playable fen payload pgn payload: uci move payload activationCandidateApproved: true activationCandidatePromoted: true activationApproved: true activationPerformed: true activeRuntimeInputEnvelope: true',
          );

          expect(
            inputFindings,
            containsAll(<String>[
              'missingPhase34VDisabledActivationCandidateDiagnosticRecommendation',
              'runtimeInputEnvelopeNotDisabled',
              'activationCandidateNotDisabled',
              'activationCandidateApproved',
              'activationCandidatePromoted',
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
              'activationCandidateRecordActivated',
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
              'activationCandidateApprovalEnabled',
              'activationCandidatePromotionEnabled',
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
            recordFindings,
            containsAll(<String>[
              'unknownActivationCandidateRecord',
              'activationCandidateRecordNotMetadataOnly',
              'activationCandidateRecordNotDisabled',
              'activationCandidateRecordUnblocked',
              'activeDeniedFields',
            ]),
          );
          expect(policyFindings, contains('uiBackendActivation'));
          expect(policyFindings, contains('cacheDatabaseWriteEnabled'));
          expect(
            boundaryFindings,
            containsAll(<String>[
              'unknownActivationCandidateBoundary',
              'activationCandidateBoundaryUnblocked',
              'activeDeniedFields',
            ]),
          );
          expect(
            blockedReasonFindings,
            containsAll(<String>[
              'unknownActivationCandidateBlockedReason',
              'blockedReasonActivated',
              'activeDeniedFields',
            ]),
          );
          expect(
            reportFindings,
            containsAll(<String>[
              'reportTextLeak:stockfishPosition',
              'reportTextLeak:stockfishCommand',
              'reportTextLeak:pvDump',
              'reportTextLeak:playableFenPayload',
              'reportTextLeak:pgnPayload',
              'reportTextLeak:uciMovePayload',
              'reportTextLeak:activationCandidateApproved',
              'reportTextLeak:activationCandidatePromoted',
              'reportTextLeak:activationApproved',
              'reportTextLeak:activationPerformed',
              'reportTextLeak:activeRuntimeInputEnvelope',
            ]),
          );
        },
      );
    },
  );
}

@TestOn('vm')
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope_diagnostic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnostic', () {
    test('safe default reports disabled runtime input envelope diagnostic', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnostic()
              .evaluate();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticStatus
            .disabledAnalyzerAdapterRuntimeInputEnvelopeDiagnosticReadyWithWarnings,
      );
      expect(
        result.mode,
        DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode
            .defaultMode,
      );
      expect(result.safeForPhase34S, isTrue);
      expect(
        result.nextRecommendation,
        'implementControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightPatch',
      );
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.disabledEnvelopeCount, greaterThanOrEqualTo(1));
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
      expect(result.totalDiagnosticRows, 67);
      expect(result.slotDiagnosticRowCount, 21);
      expect(result.boundaryDiagnosticRowCount, 17);
      expect(result.blockedReasonDiagnosticRowCount, 26);
      expect(result.deniedDiagnosticRowCount, 1);
      expect(result.proofDiagnosticRowCount, 1);
      expect(result.recommendationDiagnosticRowCount, 1);
    });

    test('diagnostic modes are deterministic and keep envelope disabled', () {
      for (final mode
          in DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode
              .values) {
        final result =
            const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnostic()
                .evaluate(mode: mode);

        expect(result.mode, mode);
        expect(result.safeForPhase34S, isTrue, reason: mode.wire);
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
          result.rows.every((row) => !row.activeRuntimeInputEnvelope),
          isTrue,
          reason: mode.wire,
        );
        expect(
          result.rows.every((row) => !row.analyzerRuntimeInputApproved),
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

    test('mode-specific row counts match disabled envelope areas', () {
      final slots =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode
                        .slots,
              );
      final boundaries =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode
                        .boundaries,
              );
      final blocked =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode
                        .blockedReasons,
              );
      final recommendation =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode
                        .recommendation,
              );

      expect(slots.totalDiagnosticRows, slots.slotDiagnosticRowCount);
      expect(slots.totalDiagnosticRows, 21);
      expect(
        boundaries.totalDiagnosticRows,
        boundaries.boundaryDiagnosticRowCount,
      );
      expect(boundaries.totalDiagnosticRows, 17);
      expect(
        blocked.totalDiagnosticRows,
        blocked.blockedReasonDiagnosticRowCount,
      );
      expect(blocked.totalDiagnosticRows, 26);
      expect(recommendation.totalDiagnosticRows, 1);
      expect(recommendation.recommendationDiagnosticRowCount, 1);
    });

    test('unsafe Phase 34Q envelope blocks diagnostic', () {
      final safe =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelope()
              .evaluate();
      final unsafe = DisabledAnalyzerAdapterRuntimeInputEnvelopeResult(
        status: DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeStatus
            .blockedByPolicyBoundary,
        sourceRuntimeInputPreflightDiagnosticStatus:
            safe.sourceRuntimeInputPreflightDiagnosticStatus,
        sourceRuntimeInputPreflightStatus:
            safe.sourceRuntimeInputPreflightStatus,
        sourceSeamProbeDiagnosticStatus: safe.sourceSeamProbeDiagnosticStatus,
        sourceSeamProbeStatus: safe.sourceSeamProbeStatus,
        sourceRuntimeExecutionPreflightDiagnosticStatus:
            safe.sourceRuntimeExecutionPreflightDiagnosticStatus,
        input: safe.input.copyWith(activeRuntimeInputEnvelope: true),
        slots: safe.slots,
        policy: safe.policy,
        boundaries: safe.boundaries,
        blockedReasons: safe.blockedReasons,
        findings: const <String>['unsafeFixture'],
        safeForPhase34R: false,
        nextRecommendation: 'blockedFixture',
      );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnostic()
              .evaluate(disabledRuntimeInputEnvelopeResult: unsafe);

      expect(result.safeForPhase34S, isFalse);
      expect(
        result.findings,
        contains('unsafePhase34QDisabledRuntimeInputEnvelope'),
      );
    });

    test('validator rejects active envelope, payload, runtime, product, and leaks', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnostic()
              .evaluate();
      final row = result.rows.first;
      const validator =
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticValidator();

      final findings = validator.validateRow(
        row.copyWith(
          diagnosticMode: 'missing',
          recommendation: 'wrongRecommendation',
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
        'position fen x go movetime 10 info depth 1 pv e2e4 playable fen payload pgn payload: uci move payload',
      );

      expect(
        findings,
        containsAll(const <String>[
          'unknownDisabledRuntimeInputEnvelopeDiagnosticMode',
          'missingPhase34SControlledRuntimeInputEnvelopeActivationPreflightRecommendation',
          'runtimeInputEnvelopeNotDisabled',
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
          'diagnosticRowFindingsPresent',
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
    });

    test('markdown and JSON render safe diagnostic shape', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnostic()
              .evaluate();
      final json = jsonDecode(result.renderJson()) as Map<String, Object?>;

      expect(
        result.renderMarkdown(),
        contains(
          '# Disabled Analyzer Adapter Runtime Input Envelope Diagnostic',
        ),
      );
      expect(json['safeForPhase34S'], isTrue);
      expect(json['rows'], isA<List<Object?>>());
    });
  });
}

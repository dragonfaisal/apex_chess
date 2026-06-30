import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope.dart';

const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticVersion =
    'debug-only-bridge-analyzer-adapter-disabled-runtime-input-envelope-diagnostic-v1';

enum DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticStatus {
  disabledAnalyzerAdapterRuntimeInputEnvelopeDiagnosticReadyWithWarnings(
    'disabledAnalyzerAdapterRuntimeInputEnvelopeDiagnosticReadyWithWarnings',
  ),
  disabledAnalyzerAdapterRuntimeInputEnvelopeDiagnosticReadyClean(
    'disabledAnalyzerAdapterRuntimeInputEnvelopeDiagnosticReadyClean',
  ),
  blockedByUnsafeDisabledRuntimeInputEnvelope(
    'blockedByUnsafeDisabledRuntimeInputEnvelope',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidDisabledRuntimeInputEnvelopeDiagnostic(
    'invalidDisabledRuntimeInputEnvelopeDiagnostic',
  );

  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticStatus(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode {
  defaultMode('default'),
  allSafe('all-safe'),
  slots('slots'),
  boundaries('boundaries'),
  blockedReasons('blocked-reasons'),
  denied('denied'),
  proof('proof'),
  recommendation('recommendation');

  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticRow {
  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticRow({
    required this.diagnosticRowId,
    required this.envelopeId,
    required this.sourcePhase,
    required this.sourceDiagnosticIds,
    required this.sourcePreflightIds,
    required this.sourceSeamProbeIds,
    required this.sourceSkeletonIds,
    required this.sourcePreparationIds,
    required this.sourceCaseIds,
    required this.sourceActionIds,
    required this.sourcePatchIds,
    required this.sourceRefinementIds,
    required this.diagnosticMode,
    required this.slotIds,
    required this.boundaryIds,
    required this.blockedReasonIds,
    required this.deniedFieldIds,
    required this.supportAreaIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.androidProofIds,
    required this.ownerProofRequired,
    required this.envelopeCreated,
    required this.envelopeDisabled,
    required this.activeRuntimeInputEnvelope,
    required this.analyzerRuntimeInputApproved,
    required this.analyzerRuntimeInputProduced,
    required this.runtimeExecutionApproved,
    required this.executionPerformed,
    required this.executionAllowed,
    required this.analyzerWiringAllowed,
    required this.engineCallsAllowed,
    required this.schedulerAllowed,
    required this.persistenceAllowed,
    required this.productOutputAllowed,
    required this.productAdapterAllowed,
    required this.savedAnalysisAllowed,
    required this.diagnosticStatus,
    required this.findings,
    required this.recommendation,
  });

  final String diagnosticRowId;
  final String envelopeId;
  final String sourcePhase;
  final List<String> sourceDiagnosticIds;
  final List<String> sourcePreflightIds;
  final List<String> sourceSeamProbeIds;
  final List<String> sourceSkeletonIds;
  final List<String> sourcePreparationIds;
  final List<String> sourceCaseIds;
  final List<String> sourceActionIds;
  final List<String> sourcePatchIds;
  final List<String> sourceRefinementIds;
  final String diagnosticMode;
  final List<String> slotIds;
  final List<String> boundaryIds;
  final List<String> blockedReasonIds;
  final List<String> deniedFieldIds;
  final List<String> supportAreaIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofIds;
  final bool ownerProofRequired;
  final bool envelopeCreated;
  final bool envelopeDisabled;
  final bool activeRuntimeInputEnvelope;
  final bool analyzerRuntimeInputApproved;
  final bool analyzerRuntimeInputProduced;
  final bool runtimeExecutionApproved;
  final bool executionPerformed;
  final bool executionAllowed;
  final bool analyzerWiringAllowed;
  final bool engineCallsAllowed;
  final bool schedulerAllowed;
  final bool persistenceAllowed;
  final bool productOutputAllowed;
  final bool productAdapterAllowed;
  final bool savedAnalysisAllowed;
  final String diagnosticStatus;
  final List<String> findings;
  final String recommendation;

  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticRow
  copyWith({
    String? diagnosticRowId,
    String? envelopeId,
    String? sourcePhase,
    List<String>? sourceDiagnosticIds,
    List<String>? sourcePreflightIds,
    List<String>? sourceSeamProbeIds,
    List<String>? sourceSkeletonIds,
    List<String>? sourcePreparationIds,
    List<String>? sourceCaseIds,
    List<String>? sourceActionIds,
    List<String>? sourcePatchIds,
    List<String>? sourceRefinementIds,
    String? diagnosticMode,
    List<String>? slotIds,
    List<String>? boundaryIds,
    List<String>? blockedReasonIds,
    List<String>? deniedFieldIds,
    List<String>? supportAreaIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? androidProofIds,
    bool? ownerProofRequired,
    bool? envelopeCreated,
    bool? envelopeDisabled,
    bool? activeRuntimeInputEnvelope,
    bool? analyzerRuntimeInputApproved,
    bool? analyzerRuntimeInputProduced,
    bool? runtimeExecutionApproved,
    bool? executionPerformed,
    bool? executionAllowed,
    bool? analyzerWiringAllowed,
    bool? engineCallsAllowed,
    bool? schedulerAllowed,
    bool? persistenceAllowed,
    bool? productOutputAllowed,
    bool? productAdapterAllowed,
    bool? savedAnalysisAllowed,
    String? diagnosticStatus,
    List<String>? findings,
    String? recommendation,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticRow(
      diagnosticRowId: diagnosticRowId ?? this.diagnosticRowId,
      envelopeId: envelopeId ?? this.envelopeId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      sourceDiagnosticIds: sourceDiagnosticIds ?? this.sourceDiagnosticIds,
      sourcePreflightIds: sourcePreflightIds ?? this.sourcePreflightIds,
      sourceSeamProbeIds: sourceSeamProbeIds ?? this.sourceSeamProbeIds,
      sourceSkeletonIds: sourceSkeletonIds ?? this.sourceSkeletonIds,
      sourcePreparationIds: sourcePreparationIds ?? this.sourcePreparationIds,
      sourceCaseIds: sourceCaseIds ?? this.sourceCaseIds,
      sourceActionIds: sourceActionIds ?? this.sourceActionIds,
      sourcePatchIds: sourcePatchIds ?? this.sourcePatchIds,
      sourceRefinementIds: sourceRefinementIds ?? this.sourceRefinementIds,
      diagnosticMode: diagnosticMode ?? this.diagnosticMode,
      slotIds: slotIds ?? this.slotIds,
      boundaryIds: boundaryIds ?? this.boundaryIds,
      blockedReasonIds: blockedReasonIds ?? this.blockedReasonIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      supportAreaIds: supportAreaIds ?? this.supportAreaIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      androidProofIds: androidProofIds ?? this.androidProofIds,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      envelopeCreated: envelopeCreated ?? this.envelopeCreated,
      envelopeDisabled: envelopeDisabled ?? this.envelopeDisabled,
      activeRuntimeInputEnvelope:
          activeRuntimeInputEnvelope ?? this.activeRuntimeInputEnvelope,
      analyzerRuntimeInputApproved:
          analyzerRuntimeInputApproved ?? this.analyzerRuntimeInputApproved,
      analyzerRuntimeInputProduced:
          analyzerRuntimeInputProduced ?? this.analyzerRuntimeInputProduced,
      runtimeExecutionApproved:
          runtimeExecutionApproved ?? this.runtimeExecutionApproved,
      executionPerformed: executionPerformed ?? this.executionPerformed,
      executionAllowed: executionAllowed ?? this.executionAllowed,
      analyzerWiringAllowed:
          analyzerWiringAllowed ?? this.analyzerWiringAllowed,
      engineCallsAllowed: engineCallsAllowed ?? this.engineCallsAllowed,
      schedulerAllowed: schedulerAllowed ?? this.schedulerAllowed,
      persistenceAllowed: persistenceAllowed ?? this.persistenceAllowed,
      productOutputAllowed: productOutputAllowed ?? this.productOutputAllowed,
      productAdapterAllowed:
          productAdapterAllowed ?? this.productAdapterAllowed,
      savedAnalysisAllowed: savedAnalysisAllowed ?? this.savedAnalysisAllowed,
      diagnosticStatus: diagnosticStatus ?? this.diagnosticStatus,
      findings: findings ?? this.findings,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'diagnosticRowId': diagnosticRowId,
      'envelopeId': envelopeId,
      'sourcePhase': sourcePhase,
      'sourceDiagnosticIds': sourceDiagnosticIds,
      'sourcePreflightIds': sourcePreflightIds,
      'sourceSeamProbeIds': sourceSeamProbeIds,
      'sourceSkeletonIds': sourceSkeletonIds,
      'sourcePreparationIds': sourcePreparationIds,
      'sourceCaseIds': sourceCaseIds,
      'sourceActionIds': sourceActionIds,
      'sourcePatchIds': sourcePatchIds,
      'sourceRefinementIds': sourceRefinementIds,
      'diagnosticMode': diagnosticMode,
      'slotIds': slotIds,
      'boundaryIds': boundaryIds,
      'blockedReasonIds': blockedReasonIds,
      'deniedFieldIds': deniedFieldIds,
      'supportAreaIds': supportAreaIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'androidProofIds': androidProofIds,
      'ownerProofRequired': ownerProofRequired,
      'envelopeCreated': envelopeCreated,
      'envelopeDisabled': envelopeDisabled,
      'activeRuntimeInputEnvelope': activeRuntimeInputEnvelope,
      'analyzerRuntimeInputApproved': analyzerRuntimeInputApproved,
      'analyzerRuntimeInputProduced': analyzerRuntimeInputProduced,
      'runtimeExecutionApproved': runtimeExecutionApproved,
      'executionPerformed': executionPerformed,
      'executionAllowed': executionAllowed,
      'analyzerWiringAllowed': analyzerWiringAllowed,
      'engineCallsAllowed': engineCallsAllowed,
      'schedulerAllowed': schedulerAllowed,
      'persistenceAllowed': persistenceAllowed,
      'productOutputAllowed': productOutputAllowed,
      'productAdapterAllowed': productAdapterAllowed,
      'savedAnalysisAllowed': savedAnalysisAllowed,
      'diagnosticStatus': diagnosticStatus,
      'findings': findings,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticResult {
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticResult({
    required this.status,
    required this.mode,
    required this.sourceDisabledRuntimeInputEnvelopeStatus,
    required this.sourceRuntimeInputPreflightDiagnosticStatus,
    required this.sourceRuntimeInputPreflightStatus,
    required this.sourceSeamProbeDiagnosticStatus,
    required this.sourceSeamProbeStatus,
    required this.rows,
    required this.findings,
    required this.safeForPhase34S,
    required this.nextRecommendation,
  }) : totalDiagnosticRows = rows.length,
       slotDiagnosticRowCount = _countRowPrefix(rows, _slotRowPrefix),
       boundaryDiagnosticRowCount = _countRowPrefix(rows, _boundaryRowPrefix),
       blockedReasonDiagnosticRowCount = _countRowPrefix(
         rows,
         _blockedReasonRowPrefix,
       ),
       deniedDiagnosticRowCount = _countRowPrefix(rows, _deniedRowPrefix),
       proofDiagnosticRowCount = _countRowPrefix(rows, _proofRowPrefix),
       recommendationDiagnosticRowCount = _countRowPrefix(
         rows,
         _recommendationRowPrefix,
       ),
       disabledEnvelopeCount = rows
           .where((row) => row.envelopeCreated && row.envelopeDisabled)
           .length,
       activeRuntimeInputEnvelopeCount = rows
           .where((row) => row.activeRuntimeInputEnvelope)
           .length,
       playablePayloadCount = _countActiveFields(rows, _payloadFields),
       analyzerRuntimeInputApprovedCount = rows
           .where((row) => row.analyzerRuntimeInputApproved)
           .length,
       analyzerRuntimeInputProducedCount = rows
           .where((row) => row.analyzerRuntimeInputProduced)
           .length,
       runtimeExecutionApprovedCount = rows
           .where((row) => row.runtimeExecutionApproved)
           .length,
       runtimeExecutionCount = rows
           .where((row) => row.executionAllowed || row.executionPerformed)
           .length,
       analyzerWiringCount = rows
           .where((row) => row.analyzerWiringAllowed)
           .length,
       executableRuntimeCount = _countActiveFields(rows, const {
         'executableRuntime',
         'runtimeExecutionResult',
       }),
       engineCallCount = rows.where((row) => row.engineCallsAllowed).length,
       schedulerExecutionCount = rows
           .where((row) => row.schedulerAllowed)
           .length,
       persistenceWriteCount = rows
           .where((row) => row.persistenceAllowed)
           .length,
       productOutputCount =
           rows.where((row) => row.productOutputAllowed).length +
           _countActiveFields(rows, _productFields),
       productAdapterCount = rows
           .where((row) => row.productAdapterAllowed)
           .length,
       savedAnalysisIntegrationCount = rows
           .where((row) => row.savedAnalysisAllowed)
           .length,
       activeDeniedFieldCount = rows
           .expand((row) => _activeDeniedFieldIds(row.deniedFieldIds))
           .length,
       phase32EProofClaimCount = rows
           .where((row) => row.androidProofIds.any(_phase32ECaseIds.contains))
           .length,
       unprovenAndroidProofCount = rows
           .where(
             (row) => row.androidProofIds.any(
               (id) => !_capturedAndroidProofIds.contains(id),
             ),
           )
           .length,
       ownerProofQueueCount = rows
           .where((row) => row.ownerProofRequired)
           .length {
    unsafeCount = hasUnsafePolicyViolation ? 1 : 0;
    blockerCount = hasUnsafePolicyViolation ? 1 : 0;
    criticalCount = 0;
  }

  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticStatus
  status;
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode
  mode;
  final String sourceDisabledRuntimeInputEnvelopeStatus;
  final String sourceRuntimeInputPreflightDiagnosticStatus;
  final String sourceRuntimeInputPreflightStatus;
  final String sourceSeamProbeDiagnosticStatus;
  final String sourceSeamProbeStatus;
  final List<
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticRow
  >
  rows;
  final List<String> findings;
  final bool safeForPhase34S;
  final String nextRecommendation;
  final int totalDiagnosticRows;
  final int slotDiagnosticRowCount;
  final int boundaryDiagnosticRowCount;
  final int blockedReasonDiagnosticRowCount;
  final int deniedDiagnosticRowCount;
  final int proofDiagnosticRowCount;
  final int recommendationDiagnosticRowCount;
  final int disabledEnvelopeCount;
  final int activeRuntimeInputEnvelopeCount;
  final int playablePayloadCount;
  final int analyzerRuntimeInputApprovedCount;
  final int analyzerRuntimeInputProducedCount;
  final int runtimeExecutionApprovedCount;
  final int runtimeExecutionCount;
  final int analyzerWiringCount;
  final int executableRuntimeCount;
  final int engineCallCount;
  final int schedulerExecutionCount;
  final int persistenceWriteCount;
  final int productOutputCount;
  final int productAdapterCount;
  final int savedAnalysisIntegrationCount;
  final int activeDeniedFieldCount;
  final int phase32EProofClaimCount;
  final int unprovenAndroidProofCount;
  final int ownerProofQueueCount;
  late final int unsafeCount;
  late final int blockerCount;
  late final int criticalCount;

  bool get hasUnsafePolicyViolation =>
      !safeForPhase34S ||
      findings.isNotEmpty ||
      totalDiagnosticRows == 0 ||
      disabledEnvelopeCount < 1 ||
      activeRuntimeInputEnvelopeCount > 0 ||
      playablePayloadCount > 0 ||
      analyzerRuntimeInputApprovedCount > 0 ||
      analyzerRuntimeInputProducedCount > 0 ||
      runtimeExecutionApprovedCount > 0 ||
      runtimeExecutionCount > 0 ||
      analyzerWiringCount > 0 ||
      executableRuntimeCount > 0 ||
      engineCallCount > 0 ||
      schedulerExecutionCount > 0 ||
      persistenceWriteCount > 0 ||
      productOutputCount > 0 ||
      productAdapterCount > 0 ||
      savedAnalysisIntegrationCount > 0 ||
      activeDeniedFieldCount > 0 ||
      phase32EProofClaimCount > 0 ||
      unprovenAndroidProofCount > 0 ||
      ownerProofQueueCount > 0;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Disabled Analyzer Adapter Runtime Input Envelope Diagnostic')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticVersion',
      )
      ..writeln('- diagnostic status: ${status.wire}')
      ..writeln('- diagnostic mode: ${mode.wire}')
      ..writeln(
        '- source disabled runtime input envelope status: $sourceDisabledRuntimeInputEnvelopeStatus',
      )
      ..writeln(
        '- source runtime input preflight diagnostic status: $sourceRuntimeInputPreflightDiagnosticStatus',
      )
      ..writeln(
        '- source runtime input preflight status: $sourceRuntimeInputPreflightStatus',
      )
      ..writeln(
        '- source seam probe diagnostic status: $sourceSeamProbeDiagnosticStatus',
      )
      ..writeln('- source seam probe status: $sourceSeamProbeStatus')
      ..writeln('- safe for Phase 34S: $safeForPhase34S')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln()
      ..writeln('## Diagnostic Mode Summary')
      ..writeln('| Mode | Rows |')
      ..writeln('| --- | --- |')
      ..writeln('| ${mode.wire} | $totalDiagnosticRows |')
      ..writeln()
      ..writeln('## Disabled Runtime Input Envelope Diagnostic Rows')
      ..writeln(
        '| Row | Mode | Slots | Boundaries | Blocked reasons | Envelope disabled | Active envelope | Analyzer input approved | Analyzer input produced | Runtime approved | Execution performed | Findings |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in rows) {
      buffer.writeln(
        '| ${row.diagnosticRowId} | ${row.diagnosticMode} | ${_ids(row.slotIds)} | ${_ids(row.boundaryIds)} | ${_ids(row.blockedReasonIds)} | ${row.envelopeDisabled} | ${row.activeRuntimeInputEnvelope} | ${row.analyzerRuntimeInputApproved} | ${row.analyzerRuntimeInputProduced} | ${row.runtimeExecutionApproved} | ${row.executionPerformed} | ${_ids(row.findings)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Diagnostic Row Summary')
      ..writeln('- slot diagnostic rows: $slotDiagnosticRowCount')
      ..writeln('- boundary diagnostic rows: $boundaryDiagnosticRowCount')
      ..writeln(
        '- blocked reason diagnostic rows: $blockedReasonDiagnosticRowCount',
      )
      ..writeln('- denied diagnostic rows: $deniedDiagnosticRowCount')
      ..writeln('- proof diagnostic rows: $proofDiagnosticRowCount')
      ..writeln(
        '- recommendation diagnostic rows: $recommendationDiagnosticRowCount',
      )
      ..writeln()
      ..writeln('## Safety Summary')
      ..writeln('- disabled envelope count: $disabledEnvelopeCount')
      ..writeln(
        '- active runtime input envelope count: $activeRuntimeInputEnvelopeCount',
      )
      ..writeln('- playable payload count: $playablePayloadCount')
      ..writeln(
        '- analyzer runtime input approved count: $analyzerRuntimeInputApprovedCount',
      )
      ..writeln(
        '- analyzer runtime input produced count: $analyzerRuntimeInputProducedCount',
      )
      ..writeln(
        '- runtime execution approved count: $runtimeExecutionApprovedCount',
      )
      ..writeln('- runtime execution count: $runtimeExecutionCount')
      ..writeln('- executable runtime count: $executableRuntimeCount')
      ..writeln('- analyzer wiring count: $analyzerWiringCount')
      ..writeln('- engine call count: $engineCallCount')
      ..writeln('- scheduler execution count: $schedulerExecutionCount')
      ..writeln('- persistence write count: $persistenceWriteCount')
      ..writeln('- product output count: $productOutputCount')
      ..writeln('- product adapter count: $productAdapterCount')
      ..writeln(
        '- saved analysis integration count: $savedAnalysisIntegrationCount',
      )
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Recommendation')
      ..writeln('- safe for Phase 34S: $safeForPhase34S')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- findings: ${_ids(findings)}')
      ..writeln();
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent(' ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticVersion,
      'status': status.wire,
      'mode': mode.wire,
      'sourceDisabledRuntimeInputEnvelopeStatus':
          sourceDisabledRuntimeInputEnvelopeStatus,
      'sourceRuntimeInputPreflightDiagnosticStatus':
          sourceRuntimeInputPreflightDiagnosticStatus,
      'sourceRuntimeInputPreflightStatus': sourceRuntimeInputPreflightStatus,
      'sourceSeamProbeDiagnosticStatus': sourceSeamProbeDiagnosticStatus,
      'sourceSeamProbeStatus': sourceSeamProbeStatus,
      'safeForPhase34S': safeForPhase34S,
      'nextRecommendation': nextRecommendation,
      'counts': <String, Object?>{
        'totalDiagnosticRows': totalDiagnosticRows,
        'slotDiagnosticRowCount': slotDiagnosticRowCount,
        'boundaryDiagnosticRowCount': boundaryDiagnosticRowCount,
        'blockedReasonDiagnosticRowCount': blockedReasonDiagnosticRowCount,
        'deniedDiagnosticRowCount': deniedDiagnosticRowCount,
        'proofDiagnosticRowCount': proofDiagnosticRowCount,
        'recommendationDiagnosticRowCount': recommendationDiagnosticRowCount,
        'unsafeCount': unsafeCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'disabledEnvelopeCount': disabledEnvelopeCount,
        'activeRuntimeInputEnvelopeCount': activeRuntimeInputEnvelopeCount,
        'playablePayloadCount': playablePayloadCount,
        'analyzerRuntimeInputApprovedCount': analyzerRuntimeInputApprovedCount,
        'analyzerRuntimeInputProducedCount': analyzerRuntimeInputProducedCount,
        'runtimeExecutionApprovedCount': runtimeExecutionApprovedCount,
        'runtimeExecutionCount': runtimeExecutionCount,
        'executableRuntimeCount': executableRuntimeCount,
        'analyzerWiringCount': analyzerWiringCount,
        'engineCallCount': engineCallCount,
        'schedulerExecutionCount': schedulerExecutionCount,
        'persistenceWriteCount': persistenceWriteCount,
        'productOutputCount': productOutputCount,
        'productAdapterCount': productAdapterCount,
        'savedAnalysisIntegrationCount': savedAnalysisIntegrationCount,
        'activeDeniedFieldCount': activeDeniedFieldCount,
        'phase32EProofClaimCount': phase32EProofClaimCount,
        'unprovenAndroidProofCount': unprovenAndroidProofCount,
        'ownerProofQueueCount': ownerProofQueueCount,
      },
      'rows': rows.map((row) => row.toJson()).toList(growable: false),
      'findings': findings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnostic {
  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnostic();

  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticResult
  evaluate({
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode
        mode =
        DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode
            .defaultMode,
    DisabledAnalyzerAdapterRuntimeInputEnvelopeResult?
    disabledRuntimeInputEnvelopeResult,
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticResult?
    runtimeInputPreflightDiagnosticResult,
    ControlledAnalyzerAdapterRuntimeInputPreflightResult?
    runtimeInputPreflightResult,
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticResult?
    disabledSeamProbeDiagnosticResult,
    DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult?
    disabledSeamProbeResult,
  }) {
    final envelope =
        disabledRuntimeInputEnvelopeResult ??
        const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelope()
            .evaluate(
              runtimeInputPreflightDiagnosticResult:
                  runtimeInputPreflightDiagnosticResult,
              runtimeInputPreflightResult: runtimeInputPreflightResult,
              disabledSeamProbeDiagnosticResult:
                  disabledSeamProbeDiagnosticResult,
              disabledSeamProbeResult: disabledSeamProbeResult,
            );
    final rows = _rowsFor(envelope, mode);
    final findings = _sorted(<String>[
      if (envelope.hasUnsafePolicyViolation || !envelope.safeForPhase34R)
        'unsafePhase34QDisabledRuntimeInputEnvelope',
      if (runtimeInputPreflightDiagnosticResult != null &&
          (runtimeInputPreflightDiagnosticResult.hasUnsafePolicyViolation ||
              !runtimeInputPreflightDiagnosticResult.safeForPhase34Q))
        'unsafePhase34PRuntimeInputPreflightDiagnostic',
      if (runtimeInputPreflightResult != null &&
          (runtimeInputPreflightResult.hasUnsafePolicyViolation ||
              !runtimeInputPreflightResult.safeForPhase34P))
        'unsafePhase34ORuntimeInputPreflight',
      if (disabledSeamProbeDiagnosticResult != null &&
          (disabledSeamProbeDiagnosticResult.hasUnsafePolicyViolation ||
              !disabledSeamProbeDiagnosticResult.safeForPhase34O))
        'unsafePhase34NDisabledRuntimeExecutionSeamProbeDiagnostic',
      if (disabledSeamProbeResult != null &&
          (disabledSeamProbeResult.hasUnsafePolicyViolation ||
              !disabledSeamProbeResult.safeForPhase34N))
        'unsafePhase34MDisabledRuntimeExecutionSeamProbe',
      ...const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticValidator()
          .validateRows(rows),
    ]);
    final safeForPhase34S = findings.isEmpty;
    return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticResult(
      status: !safeForPhase34S
          ? DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticStatus
                .blockedByPolicyBoundary
          : rows.any((row) => row.warningReasons.isNotEmpty)
          ? DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticStatus
                .disabledAnalyzerAdapterRuntimeInputEnvelopeDiagnosticReadyWithWarnings
          : DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticStatus
                .disabledAnalyzerAdapterRuntimeInputEnvelopeDiagnosticReadyClean,
      mode: mode,
      sourceDisabledRuntimeInputEnvelopeStatus: envelope.status.wire,
      sourceRuntimeInputPreflightDiagnosticStatus:
          envelope.sourceRuntimeInputPreflightDiagnosticStatus,
      sourceRuntimeInputPreflightStatus:
          envelope.sourceRuntimeInputPreflightStatus,
      sourceSeamProbeDiagnosticStatus: envelope.sourceSeamProbeDiagnosticStatus,
      sourceSeamProbeStatus: envelope.sourceSeamProbeStatus,
      rows: rows,
      findings: findings,
      safeForPhase34S: safeForPhase34S,
      nextRecommendation: safeForPhase34S
          ? _phase34SRecommendation
          : 'blockedByUnsafeDisabledRuntimeInputEnvelopeDiagnostic',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticValidator {
  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticValidator();

  List<String> validateResult(
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticResult
    result,
  ) {
    return validateRows(result.rows);
  }

  List<String> validateRows(
    Iterable<
      DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticRow
    >
    rows,
  ) {
    return _sorted(rows.expand(validateRow));
  }

  List<String> validateRow(
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticRow row,
  ) {
    final activeDenied = _activeDeniedFieldIds(row.deniedFieldIds);
    return _sorted(<String>[
      if (!_knownModes.contains(row.diagnosticMode))
        'unknownDisabledRuntimeInputEnvelopeDiagnosticMode',
      if (row.recommendation != _phase34SRecommendation)
        'missingPhase34SControlledRuntimeInputEnvelopeActivationPreflightRecommendation',
      if (!row.envelopeDisabled) 'runtimeInputEnvelopeNotDisabled',
      if (row.activeRuntimeInputEnvelope) 'activeRuntimeInputEnvelopeEnabled',
      if (_activePayloadIds(row).isNotEmpty) 'playablePayloadEnabled',
      if (row.analyzerRuntimeInputApproved) 'analyzerRuntimeInputApproved',
      if (row.analyzerRuntimeInputProduced) 'analyzerRuntimeInputProduced',
      if (row.runtimeExecutionApproved) 'runtimeExecutionApprovedEnabled',
      if (row.executionAllowed) 'executionAllowedEnabled',
      if (row.executionPerformed) 'executionPerformedEnabled',
      if (row.analyzerWiringAllowed) 'analyzerWiringEnabled',
      if (row.engineCallsAllowed) 'engineCallsEnabled',
      if (row.schedulerAllowed) 'schedulerExecutionEnabled',
      if (row.persistenceAllowed) 'persistenceWriteEnabled',
      if (row.productOutputAllowed) 'productOutputEnabled',
      if (row.productAdapterAllowed) 'productAdapterEnabled',
      if (row.savedAnalysisAllowed) 'savedAnalysisIntegrationEnabled',
      if (row.blockedReasonIds.any((id) => id.startsWith('active:')))
        'blockedReasonActivated',
      if (row.boundaryIds.any((id) => id.startsWith('active:')))
        'boundaryActivated',
      if (activeDenied.isNotEmpty) 'activeDeniedFields',
      if (activeDenied.any(_productFields.contains)) 'productLabelsEnabled',
      if (activeDenied.any(_finalLabelFields.contains)) 'finalLabelsEnabled',
      if (activeDenied.any(_classifierFields.contains))
        'classifierLabelsEnabled',
      if (activeDenied.any(_scoreFields.contains)) 'scoresEnabled',
      if (activeDenied.any(_rankingMetricFields.contains))
        'rankingsMetricsAccuracyAcplEnabled',
      if (activeDenied.contains('cpLoss')) 'cpLossEnabled',
      if (activeDenied.contains('winProbability')) 'winProbabilityEnabled',
      if (activeDenied.contains('thresholds')) 'thresholdsEnabled',
      if (activeDenied.contains('stockfishCommand')) 'stockfishCommandEnabled',
      if (activeDenied.contains('rawUci')) 'rawUciEnabled',
      if (activeDenied.contains('pvDump')) 'pvDumpEnabled',
      if (activeDenied.contains('androidCollectorRequirement'))
        'androidCollectorRequirementEnabled',
      if (activeDenied.contains('runtimeExecutionResult'))
        'runtimeExecutionResultEnabled',
      if (activeDenied.contains('analyzerRuntimeInput'))
        'analyzerRuntimeInputEnabled',
      if (activeDenied.contains('playableFenPayload'))
        'playableFenPayloadEnabled',
      if (activeDenied.contains('pgnPayload')) 'pgnPayloadEnabled',
      if (activeDenied.contains('moveListPayload')) 'moveListPayloadEnabled',
      if (activeDenied.contains('uciMovePayload')) 'uciMovePayloadEnabled',
      if (activeDenied.contains('engineOptionPayload'))
        'engineOptionPayloadEnabled',
      if (activeDenied.contains('depthAnalysisValue'))
        'depthAnalysisValueEnabled',
      if (activeDenied.contains('multiPvAnalysisValue'))
        'multiPvAnalysisValueEnabled',
      if (activeDenied.contains('analyzerResult')) 'analyzerResultEnabled',
      if (activeDenied.contains('engineResult')) 'engineResultEnabled',
      if (activeDenied.contains('schedulerExecutionResult'))
        'schedulerExecutionResultEnabled',
      if (activeDenied.contains('cacheDatabaseWrite'))
        'cacheDatabaseWriteEnabled',
      if (activeDenied.contains('productAdapterBehavior'))
        'productAdapterBehaviorEnabled',
      if (activeDenied.contains('savedAnalysisIntegration'))
        'savedAnalysisIntegrationEnabled',
      if (activeDenied.contains('readinessSummaryChain'))
        'readinessSummaryChainEnabled',
      if (activeDenied.contains('readinessGate')) 'readinessGateEnabled',
      if (_isQuietSupport(row.supportAreaIds)) 'quietPreparatoryPromotion',
      if (row.sourceCaseIds.contains(_pvMultiPvBoundaryCaseId) &&
          !row.proofLimitReasons.any(_mentionsPvMultiPv))
        'pvMultiPvPromotion',
      if (row.androidProofIds.any(_phase32ECaseIds.contains))
        'phase32ECapturedProofClaim',
      if (row.androidProofIds.any(
        (id) => !_capturedAndroidProofIds.contains(id),
      ))
        'unprovenAndroidProofClaim',
      if (row.ownerProofRequired &&
          !row.proofLimitReasons.any(_mentionsPvMultiPv))
        'ownerProofWithoutPvMultiPvReason',
      if (row.findings.isNotEmpty) 'diagnosticRowFindingsPresent',
    ]);
  }

  List<String> validateReportText(String text) {
    final lower = text.toLowerCase();
    return _sorted(<String>[
      if (lower.contains('bestmove ')) 'reportTextLeak:stockfishBestMove',
      if (lower.contains('position fen ')) 'reportTextLeak:stockfishPosition',
      if (lower.contains('go movetime ')) 'reportTextLeak:stockfishCommand',
      if (lower.contains('info depth') && lower.contains(' pv '))
        'reportTextLeak:pvDump',
      if (lower.contains('playable fen payload'))
        'reportTextLeak:playableFenPayload',
      if (lower.contains('pgn payload:')) 'reportTextLeak:pgnPayload',
      if (lower.contains('uci move payload')) 'reportTextLeak:uciMovePayload',
      if (lower.contains('backend://') ||
          lower.contains('http://secret') ||
          lower.contains('https://secret'))
        'reportTextLeak:backendSecret',
    ]);
  }
}

List<DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticRow>
_rowsFor(
  DisabledAnalyzerAdapterRuntimeInputEnvelopeResult envelope,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode mode,
) {
  final rows =
      <
        DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticRow
      >[];
  final includeAll =
      mode ==
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode
              .defaultMode ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode
              .allSafe;
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode
              .slots) {
    rows.addAll(
      envelope.slots.map(
        (slot) => _row(
          envelope,
          mode,
          diagnosticRowId: '$_slotRowPrefix-${slot.slotId.toLowerCase()}',
          slotIds: <String>[slot.slotId],
          deniedFieldIds: slot.deniedFieldIds,
          warningReasons: slot.warningReasons,
          diagnosticStatus: slot.blocked
              ? 'runtimeInputEnvelopeSlotBlocked'
              : 'runtimeInputEnvelopeSlotDisabledMetadataOnly',
        ),
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode
              .boundaries) {
    rows.addAll(
      envelope.boundaries.map(
        (boundary) => _row(
          envelope,
          mode,
          diagnosticRowId:
              '$_boundaryRowPrefix-${boundary.boundaryId.toLowerCase()}',
          boundaryIds: <String>[boundary.boundaryId],
          deniedFieldIds: boundary.deniedFieldIds,
          diagnosticStatus: boundary.blocked
              ? 'runtimeInputEnvelopeBoundaryBlocked'
              : 'runtimeInputEnvelopeBoundaryUnsafe',
        ),
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode
              .blockedReasons) {
    rows.addAll(
      envelope.blockedReasons.map(
        (reason) => _row(
          envelope,
          mode,
          diagnosticRowId:
              '$_blockedReasonRowPrefix-${reason.blockedReasonId.toLowerCase()}',
          blockedReasonIds: <String>[reason.blockedReasonId],
          deniedFieldIds: reason.deniedFieldIds,
          diagnosticStatus: reason.blocked
              ? 'runtimeInputEnvelopeBlockedReasonRemainsBlocked'
              : 'runtimeInputEnvelopeBlockedReasonUnsafe',
        ),
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode
              .denied) {
    rows.add(
      _row(
        envelope,
        mode,
        diagnosticRowId: _deniedRowPrefix,
        deniedFieldIds: envelope.policy.deniedFieldIds,
        diagnosticStatus: 'deniedFieldsRemainInactive',
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode
              .proof) {
    rows.add(
      _row(
        envelope,
        mode,
        diagnosticRowId: _proofRowPrefix,
        blockedReasonIds: const <String>['androidCollectorBlocked'],
        diagnosticStatus: 'capturedAndroidProofBoundaryOnly',
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode
              .recommendation) {
    rows.add(
      _row(
        envelope,
        mode,
        diagnosticRowId: _recommendationRowPrefix,
        slotIds: envelope.slots.map((slot) => slot.slotId).toList(),
        boundaryIds: envelope.boundaries
            .map((boundary) => boundary.boundaryId)
            .toList(),
        blockedReasonIds: envelope.blockedReasons
            .map((reason) => reason.blockedReasonId)
            .toList(),
        diagnosticStatus:
            'phase34SControlledRuntimeInputEnvelopeActivationPreflightRecommendation',
      ),
    );
  }
  return rows;
}

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticRow _row(
  DisabledAnalyzerAdapterRuntimeInputEnvelopeResult envelope,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticMode
  mode, {
  required String diagnosticRowId,
  List<String>? slotIds,
  List<String>? boundaryIds,
  List<String>? blockedReasonIds,
  List<String>? deniedFieldIds,
  List<String>? warningReasons,
  bool? envelopeCreated,
  bool? envelopeDisabled,
  bool? activeRuntimeInputEnvelope,
  bool? analyzerRuntimeInputApproved,
  bool? analyzerRuntimeInputProduced,
  bool? runtimeExecutionApproved,
  bool? executionPerformed,
  bool? executionAllowed,
  bool? analyzerWiringAllowed,
  bool? engineCallsAllowed,
  bool? schedulerAllowed,
  bool? persistenceAllowed,
  bool? productOutputAllowed,
  bool? productAdapterAllowed,
  bool? savedAnalysisAllowed,
  required String diagnosticStatus,
}) {
  return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticRow(
    diagnosticRowId: diagnosticRowId,
    envelopeId: envelope.input.envelopeId,
    sourcePhase: envelope.input.sourcePhase,
    sourceDiagnosticIds: envelope.input.sourceDiagnosticIds,
    sourcePreflightIds: envelope.input.sourcePreflightIds,
    sourceSeamProbeIds: envelope.input.sourceSeamProbeIds,
    sourceSkeletonIds: envelope.input.sourceSkeletonIds,
    sourcePreparationIds: envelope.input.sourcePreparationIds,
    sourceCaseIds: envelope.input.sourceCaseIds,
    sourceActionIds: envelope.input.sourceActionIds,
    sourcePatchIds: envelope.input.sourcePatchIds,
    sourceRefinementIds: envelope.input.sourceRefinementIds,
    diagnosticMode: mode.wire,
    slotIds: slotIds ?? envelope.input.slotIds,
    boundaryIds: boundaryIds ?? envelope.input.boundaryIds,
    blockedReasonIds: blockedReasonIds ?? envelope.input.blockedReasonIds,
    deniedFieldIds: deniedFieldIds ?? envelope.input.deniedFieldIds,
    supportAreaIds: envelope.input.supportAreaIds,
    warningReasons: warningReasons ?? envelope.input.warningReasons,
    proofLimitReasons: envelope.input.proofLimitReasons,
    androidProofIds: envelope.input.androidProofIds,
    ownerProofRequired: envelope.input.ownerProofRequired,
    envelopeCreated: envelopeCreated ?? envelope.input.envelopeCreated,
    envelopeDisabled: envelopeDisabled ?? envelope.input.envelopeDisabled,
    activeRuntimeInputEnvelope:
        activeRuntimeInputEnvelope ?? envelope.input.activeRuntimeInputEnvelope,
    analyzerRuntimeInputApproved:
        analyzerRuntimeInputApproved ??
        envelope.input.analyzerRuntimeInputApproved,
    analyzerRuntimeInputProduced:
        analyzerRuntimeInputProduced ??
        envelope.input.analyzerRuntimeInputProduced,
    runtimeExecutionApproved:
        runtimeExecutionApproved ?? envelope.input.runtimeExecutionApproved,
    executionPerformed: executionPerformed ?? envelope.input.executionPerformed,
    executionAllowed: executionAllowed ?? envelope.input.executionAllowed,
    analyzerWiringAllowed:
        analyzerWiringAllowed ?? envelope.input.analyzerWiringAllowed,
    engineCallsAllowed: engineCallsAllowed ?? envelope.input.engineCallsAllowed,
    schedulerAllowed: schedulerAllowed ?? envelope.input.schedulerAllowed,
    persistenceAllowed: persistenceAllowed ?? envelope.input.persistenceAllowed,
    productOutputAllowed:
        productOutputAllowed ?? envelope.input.productOutputAllowed,
    productAdapterAllowed:
        productAdapterAllowed ?? envelope.input.productAdapterAllowed,
    savedAnalysisAllowed:
        savedAnalysisAllowed ?? envelope.input.savedAnalysisAllowed,
    diagnosticStatus: diagnosticStatus,
    findings: const <String>[],
    recommendation: _phase34SRecommendation,
  );
}

int _countRowPrefix(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticRow
  >
  rows,
  String prefix,
) {
  return rows.where((row) => row.diagnosticRowId.startsWith(prefix)).length;
}

int _countActiveFields(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticRow
  >
  rows,
  Set<String> fieldIds,
) {
  return rows
      .expand((row) => _activeDeniedFieldIds(row.deniedFieldIds))
      .where(fieldIds.contains)
      .length;
}

Set<String> _activePayloadIds(
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticRow row,
) {
  return _activeDeniedFieldIds(
    row.deniedFieldIds,
  ).where(_payloadFields.contains).toSet();
}

List<String> _activeDeniedFieldIds(Iterable<String> deniedFieldIds) {
  return deniedFieldIds
      .where((id) => id.startsWith('active:'))
      .map((id) => id.substring('active:'.length))
      .toList();
}

bool _isQuietSupport(Iterable<String> supportAreaIds) {
  return supportAreaIds.any((id) {
    final lower = id.toLowerCase();
    return lower.contains('quiet') || lower.contains('preparatory');
  });
}

bool _mentionsPvMultiPv(String reason) {
  final lower = reason.toLowerCase();
  return lower.contains('pv') || lower.contains('multipv');
}

String _ids(Iterable<String> values) {
  final sorted = _sorted(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

List<String> _sorted(Iterable<String> values) {
  return values.where((value) => value.trim().isNotEmpty).toSet().toList()
    ..sort();
}

const _phase34SRecommendation =
    'implementControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightPatch';
const _slotRowPrefix = 'disabled-runtime-input-envelope-diagnostic-slot';
const _boundaryRowPrefix =
    'disabled-runtime-input-envelope-diagnostic-boundary';
const _blockedReasonRowPrefix =
    'disabled-runtime-input-envelope-diagnostic-blocked-reason';
const _deniedRowPrefix = 'disabled-runtime-input-envelope-diagnostic-denied';
const _proofRowPrefix = 'disabled-runtime-input-envelope-diagnostic-proof';
const _recommendationRowPrefix =
    'disabled-runtime-input-envelope-diagnostic-recommendation';
const _pvMultiPvBoundaryCaseId = 'pv-multipv-support-boundary-32e';

const _knownModes = <String>{
  'default',
  'all-safe',
  'slots',
  'boundaries',
  'blocked-reasons',
  'denied',
  'proof',
  'recommendation',
};

const _capturedAndroidProofIds = <String>{
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
};
const _phase32ECaseIds = <String>{
  'king-safety-mating-net-pressure-32e',
  'endgame-precision-candidate-spread-32e',
  'budget-pressure-wide-candidate-32e',
  'pv-multipv-support-boundary-32e',
};
const _payloadFields = <String>{
  'playableFenPayload',
  'pgnPayload',
  'moveListPayload',
  'uciMovePayload',
  'engineOptionPayload',
  'depthAnalysisValue',
  'multiPvAnalysisValue',
  'stockfishCommand',
  'rawUci',
  'pvDump',
};
const _productFields = <String>{
  'productLabel',
  'brilliantGreatMiss',
  'bestGoodInaccuracyMistakeBlunder',
};
const _finalLabelFields = <String>{'finalMoveLabel'};
const _classifierFields = <String>{
  'classifierLabels',
  'brilliantGreatMiss',
  'bestGoodInaccuracyMistakeBlunder',
};
const _scoreFields = <String>{'numericMoveScore', 'aggregateScore'};
const _rankingMetricFields = <String>{
  'moveRanking',
  'officialMetric',
  'accuracy',
  'acpl',
};

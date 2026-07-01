import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_envelope_activation_preflight.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope_diagnostic.dart';

const debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticVersion =
    'debug-only-bridge-analyzer-adapter-controlled-runtime-input-envelope-activation-preflight-diagnostic-v1';

enum DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticStatus {
  controlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDiagnosticReadyWithWarnings(
    'controlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDiagnosticReadyWithWarnings',
  ),
  controlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDiagnosticReadyClean(
    'controlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDiagnosticReadyClean',
  ),
  blockedByUnsafeControlledRuntimeInputEnvelopeActivationPreflight(
    'blockedByUnsafeControlledRuntimeInputEnvelopeActivationPreflight',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidControlledRuntimeInputEnvelopeActivationPreflightDiagnostic(
    'invalidControlledRuntimeInputEnvelopeActivationPreflightDiagnostic',
  );

  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticStatus(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode {
  defaultMode('default'),
  allSafe('all-safe'),
  checks('checks'),
  decision('decision'),
  blockedReasons('blocked-reasons'),
  denied('denied'),
  proof('proof'),
  recommendation('recommendation');

  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticRow {
  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticRow({
    required this.diagnosticRowId,
    required this.activationPreflightId,
    required this.sourcePhase,
    required this.sourceDiagnosticIds,
    required this.sourceEnvelopeIds,
    required this.sourcePreflightIds,
    required this.sourceSeamProbeIds,
    required this.sourceSkeletonIds,
    required this.sourcePreparationIds,
    required this.sourceCaseIds,
    required this.sourceActionIds,
    required this.sourcePatchIds,
    required this.sourceRefinementIds,
    required this.diagnosticMode,
    required this.checkIds,
    required this.decisionId,
    required this.blockedReasonIds,
    required this.deniedFieldIds,
    required this.supportAreaIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.androidProofIds,
    required this.ownerProofRequired,
    required this.envelopeCreated,
    required this.envelopeDisabled,
    required this.activationPreflightCreated,
    required this.activationApproved,
    required this.activationPerformed,
    required this.activeRuntimeInputEnvelope,
    required this.playablePayloadCount,
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
  final String activationPreflightId;
  final String sourcePhase;
  final List<String> sourceDiagnosticIds;
  final List<String> sourceEnvelopeIds;
  final List<String> sourcePreflightIds;
  final List<String> sourceSeamProbeIds;
  final List<String> sourceSkeletonIds;
  final List<String> sourcePreparationIds;
  final List<String> sourceCaseIds;
  final List<String> sourceActionIds;
  final List<String> sourcePatchIds;
  final List<String> sourceRefinementIds;
  final String diagnosticMode;
  final List<String> checkIds;
  final String decisionId;
  final List<String> blockedReasonIds;
  final List<String> deniedFieldIds;
  final List<String> supportAreaIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofIds;
  final bool ownerProofRequired;
  final bool envelopeCreated;
  final bool envelopeDisabled;
  final bool activationPreflightCreated;
  final bool activationApproved;
  final bool activationPerformed;
  final bool activeRuntimeInputEnvelope;
  final int playablePayloadCount;
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

  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticRow
  copyWith({
    String? diagnosticRowId,
    String? activationPreflightId,
    String? sourcePhase,
    List<String>? sourceDiagnosticIds,
    List<String>? sourceEnvelopeIds,
    List<String>? sourcePreflightIds,
    List<String>? sourceSeamProbeIds,
    List<String>? sourceSkeletonIds,
    List<String>? sourcePreparationIds,
    List<String>? sourceCaseIds,
    List<String>? sourceActionIds,
    List<String>? sourcePatchIds,
    List<String>? sourceRefinementIds,
    String? diagnosticMode,
    List<String>? checkIds,
    String? decisionId,
    List<String>? blockedReasonIds,
    List<String>? deniedFieldIds,
    List<String>? supportAreaIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? androidProofIds,
    bool? ownerProofRequired,
    bool? envelopeCreated,
    bool? envelopeDisabled,
    bool? activationPreflightCreated,
    bool? activationApproved,
    bool? activationPerformed,
    bool? activeRuntimeInputEnvelope,
    int? playablePayloadCount,
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
    return DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticRow(
      diagnosticRowId: diagnosticRowId ?? this.diagnosticRowId,
      activationPreflightId:
          activationPreflightId ?? this.activationPreflightId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      sourceDiagnosticIds: sourceDiagnosticIds ?? this.sourceDiagnosticIds,
      sourceEnvelopeIds: sourceEnvelopeIds ?? this.sourceEnvelopeIds,
      sourcePreflightIds: sourcePreflightIds ?? this.sourcePreflightIds,
      sourceSeamProbeIds: sourceSeamProbeIds ?? this.sourceSeamProbeIds,
      sourceSkeletonIds: sourceSkeletonIds ?? this.sourceSkeletonIds,
      sourcePreparationIds: sourcePreparationIds ?? this.sourcePreparationIds,
      sourceCaseIds: sourceCaseIds ?? this.sourceCaseIds,
      sourceActionIds: sourceActionIds ?? this.sourceActionIds,
      sourcePatchIds: sourcePatchIds ?? this.sourcePatchIds,
      sourceRefinementIds: sourceRefinementIds ?? this.sourceRefinementIds,
      diagnosticMode: diagnosticMode ?? this.diagnosticMode,
      checkIds: checkIds ?? this.checkIds,
      decisionId: decisionId ?? this.decisionId,
      blockedReasonIds: blockedReasonIds ?? this.blockedReasonIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      supportAreaIds: supportAreaIds ?? this.supportAreaIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      androidProofIds: androidProofIds ?? this.androidProofIds,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      envelopeCreated: envelopeCreated ?? this.envelopeCreated,
      envelopeDisabled: envelopeDisabled ?? this.envelopeDisabled,
      activationPreflightCreated:
          activationPreflightCreated ?? this.activationPreflightCreated,
      activationApproved: activationApproved ?? this.activationApproved,
      activationPerformed: activationPerformed ?? this.activationPerformed,
      activeRuntimeInputEnvelope:
          activeRuntimeInputEnvelope ?? this.activeRuntimeInputEnvelope,
      playablePayloadCount: playablePayloadCount ?? this.playablePayloadCount,
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
      'activationPreflightId': activationPreflightId,
      'sourcePhase': sourcePhase,
      'sourceDiagnosticIds': sourceDiagnosticIds,
      'sourceEnvelopeIds': sourceEnvelopeIds,
      'sourcePreflightIds': sourcePreflightIds,
      'sourceSeamProbeIds': sourceSeamProbeIds,
      'sourceSkeletonIds': sourceSkeletonIds,
      'sourcePreparationIds': sourcePreparationIds,
      'sourceCaseIds': sourceCaseIds,
      'sourceActionIds': sourceActionIds,
      'sourcePatchIds': sourcePatchIds,
      'sourceRefinementIds': sourceRefinementIds,
      'diagnosticMode': diagnosticMode,
      'checkIds': checkIds,
      'decisionId': decisionId,
      'blockedReasonIds': blockedReasonIds,
      'deniedFieldIds': deniedFieldIds,
      'supportAreaIds': supportAreaIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'androidProofIds': androidProofIds,
      'ownerProofRequired': ownerProofRequired,
      'envelopeCreated': envelopeCreated,
      'envelopeDisabled': envelopeDisabled,
      'activationPreflightCreated': activationPreflightCreated,
      'activationApproved': activationApproved,
      'activationPerformed': activationPerformed,
      'activeRuntimeInputEnvelope': activeRuntimeInputEnvelope,
      'playablePayloadCount': playablePayloadCount,
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

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticResult {
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticResult({
    required this.status,
    required this.mode,
    required this.sourceActivationPreflightStatus,
    required this.sourceDisabledRuntimeInputEnvelopeDiagnosticStatus,
    required this.sourceDisabledRuntimeInputEnvelopeStatus,
    required this.sourceRuntimeInputPreflightDiagnosticStatus,
    required this.sourceRuntimeInputPreflightStatus,
    required this.rows,
    required this.findings,
    required this.safeForPhase34U,
    required this.nextRecommendation,
  }) : totalDiagnosticRows = rows.length,
       checkDiagnosticRowCount = _countRowPrefix(rows, _checkRowPrefix),
       decisionDiagnosticRowCount = _countRowPrefix(rows, _decisionRowPrefix),
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
       activationPreflightCount = rows
           .where((row) => row.activationPreflightCreated)
           .length,
       activationApprovedCount = rows
           .where((row) => row.activationApproved)
           .length,
       activationPerformedCount = rows
           .where((row) => row.activationPerformed)
           .length,
       activeRuntimeInputEnvelopeCount = rows
           .where((row) => row.activeRuntimeInputEnvelope)
           .length,
       playablePayloadCount =
           rows.fold<int>(0, (total, row) => total + row.playablePayloadCount) +
           _countActiveFields(rows, _payloadFields),
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

  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticStatus
  status;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
  mode;
  final String sourceActivationPreflightStatus;
  final String sourceDisabledRuntimeInputEnvelopeDiagnosticStatus;
  final String sourceDisabledRuntimeInputEnvelopeStatus;
  final String sourceRuntimeInputPreflightDiagnosticStatus;
  final String sourceRuntimeInputPreflightStatus;
  final List<
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticRow
  >
  rows;
  final List<String> findings;
  final bool safeForPhase34U;
  final String nextRecommendation;
  final int totalDiagnosticRows;
  final int checkDiagnosticRowCount;
  final int decisionDiagnosticRowCount;
  final int blockedReasonDiagnosticRowCount;
  final int deniedDiagnosticRowCount;
  final int proofDiagnosticRowCount;
  final int recommendationDiagnosticRowCount;
  final int disabledEnvelopeCount;
  final int activationPreflightCount;
  final int activationApprovedCount;
  final int activationPerformedCount;
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
      !safeForPhase34U ||
      findings.isNotEmpty ||
      totalDiagnosticRows == 0 ||
      disabledEnvelopeCount < 1 ||
      activationPreflightCount < 1 ||
      activationApprovedCount > 0 ||
      activationPerformedCount > 0 ||
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
      ..writeln(
        '# Controlled Analyzer Adapter Runtime Input Envelope Activation Preflight Diagnostic',
      )
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticVersion',
      )
      ..writeln('- diagnostic status: ${status.wire}')
      ..writeln('- diagnostic mode: ${mode.wire}')
      ..writeln(
        '- source activation preflight status: $sourceActivationPreflightStatus',
      )
      ..writeln(
        '- source disabled runtime input envelope diagnostic status: $sourceDisabledRuntimeInputEnvelopeDiagnosticStatus',
      )
      ..writeln(
        '- source disabled runtime input envelope status: $sourceDisabledRuntimeInputEnvelopeStatus',
      )
      ..writeln(
        '- source runtime input preflight diagnostic status: $sourceRuntimeInputPreflightDiagnosticStatus',
      )
      ..writeln(
        '- source runtime input preflight status: $sourceRuntimeInputPreflightStatus',
      )
      ..writeln('- safe for Phase 34U: $safeForPhase34U')
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
      ..writeln('## Activation Preflight Diagnostic Rows')
      ..writeln(
        '| Row | Mode | Checks | Decision | Blocked reasons | Envelope disabled | Activation approved | Activation performed | Active envelope | Payloads | Analyzer input approved | Analyzer input produced | Runtime approved | Execution performed | Findings |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in rows) {
      buffer.writeln(
        '| ${row.diagnosticRowId} | ${row.diagnosticMode} | ${_ids(row.checkIds)} | ${row.decisionId} | ${_ids(row.blockedReasonIds)} | ${row.envelopeDisabled} | ${row.activationApproved} | ${row.activationPerformed} | ${row.activeRuntimeInputEnvelope} | ${row.playablePayloadCount} | ${row.analyzerRuntimeInputApproved} | ${row.analyzerRuntimeInputProduced} | ${row.runtimeExecutionApproved} | ${row.executionPerformed} | ${_ids(row.findings)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Diagnostic Row Summary')
      ..writeln('- check diagnostic rows: $checkDiagnosticRowCount')
      ..writeln('- decision diagnostic rows: $decisionDiagnosticRowCount')
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
      ..writeln('- activation preflight count: $activationPreflightCount')
      ..writeln('- activation approved count: $activationApprovedCount')
      ..writeln('- activation performed count: $activationPerformedCount')
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
      ..writeln('- safe for Phase 34U: $safeForPhase34U')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- findings: ${_ids(findings)}')
      ..writeln();
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent(' ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticVersion,
      'status': status.wire,
      'mode': mode.wire,
      'sourceActivationPreflightStatus': sourceActivationPreflightStatus,
      'sourceDisabledRuntimeInputEnvelopeDiagnosticStatus':
          sourceDisabledRuntimeInputEnvelopeDiagnosticStatus,
      'sourceDisabledRuntimeInputEnvelopeStatus':
          sourceDisabledRuntimeInputEnvelopeStatus,
      'sourceRuntimeInputPreflightDiagnosticStatus':
          sourceRuntimeInputPreflightDiagnosticStatus,
      'sourceRuntimeInputPreflightStatus': sourceRuntimeInputPreflightStatus,
      'safeForPhase34U': safeForPhase34U,
      'nextRecommendation': nextRecommendation,
      'counts': <String, Object?>{
        'totalDiagnosticRows': totalDiagnosticRows,
        'checkDiagnosticRowCount': checkDiagnosticRowCount,
        'decisionDiagnosticRowCount': decisionDiagnosticRowCount,
        'blockedReasonDiagnosticRowCount': blockedReasonDiagnosticRowCount,
        'deniedDiagnosticRowCount': deniedDiagnosticRowCount,
        'proofDiagnosticRowCount': proofDiagnosticRowCount,
        'recommendationDiagnosticRowCount': recommendationDiagnosticRowCount,
        'unsafeCount': unsafeCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'disabledEnvelopeCount': disabledEnvelopeCount,
        'activationPreflightCount': activationPreflightCount,
        'activationApprovedCount': activationApprovedCount,
        'activationPerformedCount': activationPerformedCount,
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

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnostic {
  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnostic();

  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticResult
  evaluate({
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
        mode =
        DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
            .defaultMode,
    ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult?
    activationPreflightResult,
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticResult?
    disabledRuntimeInputEnvelopeDiagnosticResult,
    DisabledAnalyzerAdapterRuntimeInputEnvelopeResult?
    disabledRuntimeInputEnvelopeResult,
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticResult?
    runtimeInputPreflightDiagnosticResult,
    ControlledAnalyzerAdapterRuntimeInputPreflightResult?
    runtimeInputPreflightResult,
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticResult?
    disabledSeamProbeDiagnosticResult,
  }) {
    final preflight =
        activationPreflightResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflight()
            .evaluate(
              disabledRuntimeInputEnvelopeDiagnosticResult:
                  disabledRuntimeInputEnvelopeDiagnosticResult,
              disabledRuntimeInputEnvelopeResult:
                  disabledRuntimeInputEnvelopeResult,
              runtimeInputPreflightDiagnosticResult:
                  runtimeInputPreflightDiagnosticResult,
              runtimeInputPreflightResult: runtimeInputPreflightResult,
              disabledSeamProbeDiagnosticResult:
                  disabledSeamProbeDiagnosticResult,
            );
    final rows = _rowsFor(preflight, mode);
    final findings = _sorted(<String>[
      if (preflight.hasUnsafePolicyViolation || !preflight.safeForPhase34T)
        'unsafePhase34SRuntimeInputEnvelopeActivationPreflight',
      if (disabledRuntimeInputEnvelopeDiagnosticResult != null &&
          (disabledRuntimeInputEnvelopeDiagnosticResult
                  .hasUnsafePolicyViolation ||
              !disabledRuntimeInputEnvelopeDiagnosticResult.safeForPhase34S))
        'unsafePhase34RDisabledRuntimeInputEnvelopeDiagnostic',
      if (disabledRuntimeInputEnvelopeResult != null &&
          (disabledRuntimeInputEnvelopeResult.hasUnsafePolicyViolation ||
              !disabledRuntimeInputEnvelopeResult.safeForPhase34R))
        'unsafePhase34QDisabledRuntimeInputEnvelope',
      if (runtimeInputPreflightDiagnosticResult != null &&
          (runtimeInputPreflightDiagnosticResult.hasUnsafePolicyViolation ||
              !runtimeInputPreflightDiagnosticResult.safeForPhase34Q))
        'unsafePhase34PRuntimeInputPreflightDiagnostic',
      if (runtimeInputPreflightResult != null &&
          (runtimeInputPreflightResult.hasUnsafePolicyViolation ||
              !runtimeInputPreflightResult.safeForPhase34P))
        'unsafePhase34ORuntimeInputPreflight',
      ...const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticValidator()
          .validateRows(rows),
    ]);
    final safeForPhase34U = findings.isEmpty;
    return DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticResult(
      status: !safeForPhase34U
          ? DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticStatus
                .blockedByPolicyBoundary
          : rows.any((row) => row.warningReasons.isNotEmpty)
          ? DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticStatus
                .controlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDiagnosticReadyWithWarnings
          : DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticStatus
                .controlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDiagnosticReadyClean,
      mode: mode,
      sourceActivationPreflightStatus: preflight.status.wire,
      sourceDisabledRuntimeInputEnvelopeDiagnosticStatus:
          preflight.sourceDisabledRuntimeInputEnvelopeDiagnosticStatus,
      sourceDisabledRuntimeInputEnvelopeStatus:
          preflight.sourceDisabledRuntimeInputEnvelopeStatus,
      sourceRuntimeInputPreflightDiagnosticStatus:
          preflight.sourceRuntimeInputPreflightDiagnosticStatus,
      sourceRuntimeInputPreflightStatus:
          preflight.sourceRuntimeInputPreflightStatus,
      rows: rows,
      findings: findings,
      safeForPhase34U: safeForPhase34U,
      nextRecommendation: safeForPhase34U
          ? _phase34URecommendation
          : 'blockedByUnsafeRuntimeInputEnvelopeActivationPreflightDiagnostic',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticValidator {
  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticValidator();

  List<String> validateResult(
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticResult
    result,
  ) {
    return validateRows(result.rows);
  }

  List<String> validateRows(
    Iterable<
      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticRow
    >
    rows,
  ) {
    return _sorted(rows.expand(validateRow));
  }

  List<String> validateRow(
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticRow
    row,
  ) {
    final activeDenied = _activeDeniedFieldIds(row.deniedFieldIds);
    return _sorted(<String>[
      if (!_knownModes.contains(row.diagnosticMode))
        'unknownRuntimeInputEnvelopeActivationPreflightDiagnosticMode',
      if (row.recommendation != _phase34URecommendation)
        'missingPhase34UDisabledActivationCandidateRecommendation',
      if (!row.envelopeDisabled) 'runtimeInputEnvelopeNotDisabled',
      if (!row.activationPreflightCreated) 'activationPreflightMissing',
      if (row.activationApproved) 'activationApproved',
      if (row.activationPerformed) 'activationPerformed',
      if (row.activeRuntimeInputEnvelope) 'activeRuntimeInputEnvelopeEnabled',
      if (row.playablePayloadCount > 0 || _activePayloadIds(row).isNotEmpty)
        'playablePayloadEnabled',
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
      if (row.checkIds.any((id) => id.startsWith('active:')))
        'preflightCheckActivated',
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
      if (activeDenied.contains('analyzerRuntimeInputApproval'))
        'analyzerRuntimeInputApprovalEnabled',
      if (activeDenied.contains('analyzerRuntimeInputProduction'))
        'analyzerRuntimeInputProductionEnabled',
      if (activeDenied.contains('activeRuntimeInputEnvelope'))
        'activeRuntimeInputEnvelopeFieldEnabled',
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
      if (lower.contains('activationapproved: true'))
        'reportTextLeak:activationApproved',
      if (lower.contains('activationperformed: true'))
        'reportTextLeak:activationPerformed',
      if (lower.contains('activeruntimeinputenvelope: true'))
        'reportTextLeak:activeRuntimeInputEnvelope',
      if (lower.contains('analyzerruntimeinputapproved: true'))
        'reportTextLeak:analyzerRuntimeInputApproved',
      if (lower.contains('analyzerruntimeinputproduced: true'))
        'reportTextLeak:analyzerRuntimeInputProduced',
      if (lower.contains('runtimeexecutionapproved: true'))
        'reportTextLeak:runtimeExecutionApproved',
      if (lower.contains('backend://') ||
          lower.contains('http://secret') ||
          lower.contains('https://secret'))
        'reportTextLeak:backendSecret',
    ]);
  }
}

List<
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticRow
>
_rowsFor(
  ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult
  preflight,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
  mode,
) {
  final rows =
      <
        DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticRow
      >[];
  final includeAll =
      mode ==
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
              .defaultMode ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
              .allSafe;
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
              .checks) {
    rows.addAll(
      preflight.checks.map(
        (check) => _row(
          preflight,
          mode,
          diagnosticRowId: '$_checkRowPrefix-${check.checkId.toLowerCase()}',
          checkIds: <String>[check.checkId],
          blockedReasonIds: check.blockedReasonIds,
          deniedFieldIds: check.deniedFieldIds,
          warningReasons: check.warningReasons,
          diagnosticStatus: check.passed
              ? 'activationPreflightCheckPassed'
              : 'activationPreflightCheckUnsafe',
        ),
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
              .decision) {
    rows.add(
      _row(
        preflight,
        mode,
        diagnosticRowId: _decisionRowPrefix,
        decisionId: preflight.decision.decisionId,
        blockedReasonIds: preflight.decision.blockedReasonIds,
        warningReasons: preflight.decision.warningReasons,
        envelopeDisabled: preflight.decision.envelopeDisabled,
        activationApproved: preflight.decision.activationApproved,
        activationPerformed: preflight.decision.activationPerformed,
        activeRuntimeInputEnvelope:
            preflight.decision.activeRuntimeInputEnvelope,
        playablePayloadCount: preflight.decision.playablePayloadCount,
        analyzerRuntimeInputApproved:
            preflight.decision.analyzerRuntimeInputApproved,
        analyzerRuntimeInputProduced:
            preflight.decision.analyzerRuntimeInputProduced,
        runtimeExecutionApproved: preflight.decision.runtimeExecutionApproved,
        executionPerformed: preflight.decision.executionPerformed,
        executionAllowed: preflight.decision.executionAllowed,
        analyzerWiringAllowed: preflight.decision.analyzerWiringAllowed,
        engineCallsAllowed: preflight.decision.engineCallsAllowed,
        schedulerAllowed: preflight.decision.schedulerAllowed,
        persistenceAllowed: preflight.decision.persistenceAllowed,
        productOutputAllowed: preflight.decision.productOutputAllowed,
        productAdapterAllowed: preflight.decision.productAdapterAllowed,
        savedAnalysisAllowed: preflight.decision.savedAnalysisAllowed,
        diagnosticStatus: preflight.decision.decisionStatus,
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
              .blockedReasons) {
    rows.addAll(
      preflight.blockedReasons.map(
        (reason) => _row(
          preflight,
          mode,
          diagnosticRowId:
              '$_blockedReasonRowPrefix-${reason.blockedReasonId.toLowerCase()}',
          blockedReasonIds: <String>[reason.blockedReasonId],
          deniedFieldIds: reason.deniedFieldIds,
          diagnosticStatus: reason.blocked
              ? 'activationPreflightBlockedReasonRemainsBlocked'
              : 'activationPreflightBlockedReasonUnsafe',
        ),
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
              .denied) {
    rows.add(
      _row(
        preflight,
        mode,
        diagnosticRowId: _deniedRowPrefix,
        deniedFieldIds: preflight.policy.deniedFieldIds,
        diagnosticStatus: 'deniedFieldsRemainInactive',
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
              .proof) {
    rows.add(
      _row(
        preflight,
        mode,
        diagnosticRowId: _proofRowPrefix,
        blockedReasonIds: const <String>['androidCollectorBlocked'],
        diagnosticStatus: 'capturedAndroidProofBoundaryOnly',
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
              .recommendation) {
    rows.add(
      _row(
        preflight,
        mode,
        diagnosticRowId: _recommendationRowPrefix,
        checkIds: preflight.checks.map((check) => check.checkId).toList(),
        blockedReasonIds: preflight.blockedReasons
            .map((reason) => reason.blockedReasonId)
            .toList(),
        diagnosticStatus:
            'phase34UDisabledRuntimeInputEnvelopeActivationCandidatePatchRecommendation',
      ),
    );
  }
  return rows;
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticRow
_row(
  ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult
  preflight,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
  mode, {
  required String diagnosticRowId,
  List<String>? checkIds,
  String? decisionId,
  List<String>? blockedReasonIds,
  List<String>? deniedFieldIds,
  List<String>? warningReasons,
  bool? envelopeCreated,
  bool? envelopeDisabled,
  bool? activationPreflightCreated,
  bool? activationApproved,
  bool? activationPerformed,
  bool? activeRuntimeInputEnvelope,
  int? playablePayloadCount,
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
  return DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticRow(
    diagnosticRowId: diagnosticRowId,
    activationPreflightId: preflight.input.activationPreflightId,
    sourcePhase: preflight.input.sourcePhase,
    sourceDiagnosticIds: preflight.input.sourceDiagnosticIds,
    sourceEnvelopeIds: preflight.input.sourceEnvelopeIds,
    sourcePreflightIds: preflight.input.sourcePreflightIds,
    sourceSeamProbeIds: preflight.input.sourceSeamProbeIds,
    sourceSkeletonIds: preflight.input.sourceSkeletonIds,
    sourcePreparationIds: preflight.input.sourcePreparationIds,
    sourceCaseIds: preflight.input.sourceCaseIds,
    sourceActionIds: preflight.input.sourceActionIds,
    sourcePatchIds: preflight.input.sourcePatchIds,
    sourceRefinementIds: preflight.input.sourceRefinementIds,
    diagnosticMode: mode.wire,
    checkIds: checkIds ?? preflight.input.checkIds,
    decisionId: decisionId ?? preflight.input.decisionId,
    blockedReasonIds: blockedReasonIds ?? preflight.input.blockedReasonIds,
    deniedFieldIds: deniedFieldIds ?? preflight.input.deniedFieldIds,
    supportAreaIds: preflight.input.supportAreaIds,
    warningReasons: warningReasons ?? preflight.input.warningReasons,
    proofLimitReasons: preflight.input.proofLimitReasons,
    androidProofIds: preflight.input.androidProofIds,
    ownerProofRequired: preflight.input.ownerProofRequired,
    envelopeCreated: envelopeCreated ?? preflight.input.envelopeCreated,
    envelopeDisabled: envelopeDisabled ?? preflight.input.envelopeDisabled,
    activationPreflightCreated:
        activationPreflightCreated ??
        preflight.input.activationPreflightCreated,
    activationApproved:
        activationApproved ?? preflight.input.activationApproved,
    activationPerformed:
        activationPerformed ?? preflight.input.activationPerformed,
    activeRuntimeInputEnvelope:
        activeRuntimeInputEnvelope ??
        preflight.input.activeRuntimeInputEnvelope,
    playablePayloadCount:
        playablePayloadCount ?? preflight.input.playablePayloadCount,
    analyzerRuntimeInputApproved:
        analyzerRuntimeInputApproved ??
        preflight.input.analyzerRuntimeInputApproved,
    analyzerRuntimeInputProduced:
        analyzerRuntimeInputProduced ??
        preflight.input.analyzerRuntimeInputProduced,
    runtimeExecutionApproved:
        runtimeExecutionApproved ?? preflight.input.runtimeExecutionApproved,
    executionPerformed:
        executionPerformed ?? preflight.input.executionPerformed,
    executionAllowed: executionAllowed ?? preflight.input.executionAllowed,
    analyzerWiringAllowed:
        analyzerWiringAllowed ?? preflight.input.analyzerWiringAllowed,
    engineCallsAllowed:
        engineCallsAllowed ?? preflight.input.engineCallsAllowed,
    schedulerAllowed: schedulerAllowed ?? preflight.input.schedulerAllowed,
    persistenceAllowed:
        persistenceAllowed ?? preflight.input.persistenceAllowed,
    productOutputAllowed:
        productOutputAllowed ?? preflight.input.productOutputAllowed,
    productAdapterAllowed:
        productAdapterAllowed ?? preflight.input.productAdapterAllowed,
    savedAnalysisAllowed:
        savedAnalysisAllowed ?? preflight.input.savedAnalysisAllowed,
    diagnosticStatus: diagnosticStatus,
    findings: const <String>[],
    recommendation: _phase34URecommendation,
  );
}

const _phase34URecommendation =
    'implementDisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidatePatch';

const _checkRowPrefix = 'activation-preflight-diagnostic-check';
const _decisionRowPrefix = 'activation-preflight-diagnostic-decision';
const _blockedReasonRowPrefix =
    'activation-preflight-diagnostic-blocked-reason';
const _deniedRowPrefix = 'activation-preflight-diagnostic-denied';
const _proofRowPrefix = 'activation-preflight-diagnostic-proof';
const _recommendationRowPrefix =
    'activation-preflight-diagnostic-recommendation';

const _pvMultiPvBoundaryCaseId = 'pv-multipv-support-boundary-32e';

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

final _knownModes =
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
        .values
        .map((mode) => mode.wire)
        .toSet();

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

const _classifierFields = <String>{'classifierLabels'};

const _scoreFields = <String>{
  'numericMoveScore',
  'aggregateScore',
  'brilliantGreatMiss',
  'bestGoodInaccuracyMistakeBlunder',
};

const _rankingMetricFields = <String>{
  'moveRanking',
  'officialMetric',
  'accuracy',
  'acpl',
};

int _countRowPrefix(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticRow
  >
  rows,
  String prefix,
) {
  return rows.where((row) => row.diagnosticRowId.startsWith(prefix)).length;
}

int _countActiveFields(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticRow
  >
  rows,
  Set<String> fieldIds,
) {
  return rows
      .expand((row) => _activeDeniedFieldIds(row.deniedFieldIds))
      .where(fieldIds.contains)
      .length;
}

List<String> _activePayloadIds(
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticRow
  row,
) {
  return _activeDeniedFieldIds(
    row.deniedFieldIds,
  ).where(_payloadFields.contains).toList(growable: false);
}

List<String> _activeDeniedFieldIds(Iterable<String> ids) {
  return ids
      .where((id) => id.startsWith('active:'))
      .map((id) => id.substring('active:'.length))
      .toList(growable: false);
}

bool _isQuietSupport(Iterable<String> supportAreaIds) {
  return supportAreaIds.contains('quietMove') ||
      supportAreaIds.contains('quietPreparatoryMove');
}

bool _mentionsPvMultiPv(String reason) {
  final lower = reason.toLowerCase();
  return lower.contains('pv') || lower.contains('multipv');
}

List<String> _sorted(Iterable<String> values) {
  final list = values.toSet().toList()..sort();
  return list;
}

String _ids(Iterable<String> values) {
  final sorted = _sorted(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

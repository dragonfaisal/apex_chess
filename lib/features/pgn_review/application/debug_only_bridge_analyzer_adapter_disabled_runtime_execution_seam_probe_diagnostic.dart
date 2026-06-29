import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton_diagnostic.dart';

const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticVersion =
    'debug-only-bridge-analyzer-adapter-disabled-runtime-execution-seam-probe-diagnostic-v1';

enum DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticStatus {
  disabledAnalyzerAdapterRuntimeExecutionSeamProbeDiagnosticReadyWithWarnings(
    'disabledAnalyzerAdapterRuntimeExecutionSeamProbeDiagnosticReadyWithWarnings',
  ),
  disabledAnalyzerAdapterRuntimeExecutionSeamProbeDiagnosticReadyClean(
    'disabledAnalyzerAdapterRuntimeExecutionSeamProbeDiagnosticReadyClean',
  ),
  blockedByUnsafeDisabledRuntimeExecutionSeamProbe(
    'blockedByUnsafeDisabledRuntimeExecutionSeamProbe',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidDisabledRuntimeExecutionSeamProbeDiagnostic(
    'invalidDisabledRuntimeExecutionSeamProbeDiagnostic',
  );

  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticStatus(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode {
  defaultMode('default'),
  allSafe('all-safe'),
  request('request'),
  response('response'),
  attempt('attempt'),
  boundaries('boundaries'),
  blockedReasons('blocked-reasons'),
  denied('denied'),
  proof('proof'),
  recommendation('recommendation');

  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticRow {
  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticRow({
    required this.diagnosticRowId,
    required this.seamProbeId,
    required this.sourcePhase,
    required this.sourceDiagnosticIds,
    required this.sourcePreflightIds,
    required this.sourceSkeletonIds,
    required this.sourcePreparationIds,
    required this.sourceCaseIds,
    required this.sourceActionIds,
    required this.sourcePatchIds,
    required this.sourceRefinementIds,
    required this.diagnosticMode,
    required this.requestId,
    required this.responseId,
    required this.attemptId,
    required this.boundaryIds,
    required this.blockedReasonIds,
    required this.deniedFieldIds,
    required this.supportAreaIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.androidProofIds,
    required this.ownerProofRequired,
    required this.seamProbeRequested,
    required this.seamProbePerformed,
    required this.executionPerformed,
    required this.executionAllowed,
    required this.runtimeExecutionApproved,
    required this.analyzerRuntimeInputProduced,
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
  final String seamProbeId;
  final String sourcePhase;
  final List<String> sourceDiagnosticIds;
  final List<String> sourcePreflightIds;
  final List<String> sourceSkeletonIds;
  final List<String> sourcePreparationIds;
  final List<String> sourceCaseIds;
  final List<String> sourceActionIds;
  final List<String> sourcePatchIds;
  final List<String> sourceRefinementIds;
  final String diagnosticMode;
  final String requestId;
  final String responseId;
  final String attemptId;
  final List<String> boundaryIds;
  final List<String> blockedReasonIds;
  final List<String> deniedFieldIds;
  final List<String> supportAreaIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofIds;
  final bool ownerProofRequired;
  final bool seamProbeRequested;
  final bool seamProbePerformed;
  final bool executionPerformed;
  final bool executionAllowed;
  final bool runtimeExecutionApproved;
  final bool analyzerRuntimeInputProduced;
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

  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticRow
  copyWith({
    String? diagnosticRowId,
    String? seamProbeId,
    String? sourcePhase,
    List<String>? sourceDiagnosticIds,
    List<String>? sourcePreflightIds,
    List<String>? sourceSkeletonIds,
    List<String>? sourcePreparationIds,
    List<String>? sourceCaseIds,
    List<String>? sourceActionIds,
    List<String>? sourcePatchIds,
    List<String>? sourceRefinementIds,
    String? diagnosticMode,
    String? requestId,
    String? responseId,
    String? attemptId,
    List<String>? boundaryIds,
    List<String>? blockedReasonIds,
    List<String>? deniedFieldIds,
    List<String>? supportAreaIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? androidProofIds,
    bool? ownerProofRequired,
    bool? seamProbeRequested,
    bool? seamProbePerformed,
    bool? executionPerformed,
    bool? executionAllowed,
    bool? runtimeExecutionApproved,
    bool? analyzerRuntimeInputProduced,
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
    return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticRow(
      diagnosticRowId: diagnosticRowId ?? this.diagnosticRowId,
      seamProbeId: seamProbeId ?? this.seamProbeId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      sourceDiagnosticIds: sourceDiagnosticIds ?? this.sourceDiagnosticIds,
      sourcePreflightIds: sourcePreflightIds ?? this.sourcePreflightIds,
      sourceSkeletonIds: sourceSkeletonIds ?? this.sourceSkeletonIds,
      sourcePreparationIds: sourcePreparationIds ?? this.sourcePreparationIds,
      sourceCaseIds: sourceCaseIds ?? this.sourceCaseIds,
      sourceActionIds: sourceActionIds ?? this.sourceActionIds,
      sourcePatchIds: sourcePatchIds ?? this.sourcePatchIds,
      sourceRefinementIds: sourceRefinementIds ?? this.sourceRefinementIds,
      diagnosticMode: diagnosticMode ?? this.diagnosticMode,
      requestId: requestId ?? this.requestId,
      responseId: responseId ?? this.responseId,
      attemptId: attemptId ?? this.attemptId,
      boundaryIds: boundaryIds ?? this.boundaryIds,
      blockedReasonIds: blockedReasonIds ?? this.blockedReasonIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      supportAreaIds: supportAreaIds ?? this.supportAreaIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      androidProofIds: androidProofIds ?? this.androidProofIds,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      seamProbeRequested: seamProbeRequested ?? this.seamProbeRequested,
      seamProbePerformed: seamProbePerformed ?? this.seamProbePerformed,
      executionPerformed: executionPerformed ?? this.executionPerformed,
      executionAllowed: executionAllowed ?? this.executionAllowed,
      runtimeExecutionApproved:
          runtimeExecutionApproved ?? this.runtimeExecutionApproved,
      analyzerRuntimeInputProduced:
          analyzerRuntimeInputProduced ?? this.analyzerRuntimeInputProduced,
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
      'seamProbeId': seamProbeId,
      'sourcePhase': sourcePhase,
      'sourceDiagnosticIds': sourceDiagnosticIds,
      'sourcePreflightIds': sourcePreflightIds,
      'sourceSkeletonIds': sourceSkeletonIds,
      'sourcePreparationIds': sourcePreparationIds,
      'sourceCaseIds': sourceCaseIds,
      'sourceActionIds': sourceActionIds,
      'sourcePatchIds': sourcePatchIds,
      'sourceRefinementIds': sourceRefinementIds,
      'diagnosticMode': diagnosticMode,
      'requestId': requestId,
      'responseId': responseId,
      'attemptId': attemptId,
      'boundaryIds': boundaryIds,
      'blockedReasonIds': blockedReasonIds,
      'deniedFieldIds': deniedFieldIds,
      'supportAreaIds': supportAreaIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'androidProofIds': androidProofIds,
      'ownerProofRequired': ownerProofRequired,
      'seamProbeRequested': seamProbeRequested,
      'seamProbePerformed': seamProbePerformed,
      'executionPerformed': executionPerformed,
      'executionAllowed': executionAllowed,
      'runtimeExecutionApproved': runtimeExecutionApproved,
      'analyzerRuntimeInputProduced': analyzerRuntimeInputProduced,
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

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticResult {
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticResult({
    required this.status,
    required this.mode,
    required this.sourceSeamProbeStatus,
    required this.sourcePreflightDiagnosticStatus,
    required this.sourcePreflightStatus,
    required this.sourceDisabledRuntimeSkeletonDiagnosticStatus,
    required this.sourceDisabledRuntimeSkeletonStatus,
    required this.rows,
    required this.findings,
    required this.safeForPhase34O,
    required this.nextRecommendation,
  }) : totalDiagnosticRows = rows.length,
       requestDiagnosticRowCount = _countRowPrefix(rows, _requestRowPrefix),
       responseDiagnosticRowCount = _countRowPrefix(rows, _responseRowPrefix),
       attemptDiagnosticRowCount = _countRowPrefix(rows, _attemptRowPrefix),
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
       seamProbeAttemptCount = rows.any((row) => row.seamProbeRequested)
           ? 1
           : 0,
       seamProbePerformedCount = rows
           .where((row) => row.seamProbePerformed)
           .length,
       runtimeExecutionCount = rows
           .where((row) => row.executionAllowed || row.executionPerformed)
           .length,
       runtimeExecutionApprovedCount = rows
           .where((row) => row.runtimeExecutionApproved)
           .length,
       analyzerRuntimeInputProducedCount = rows
           .where((row) => row.analyzerRuntimeInputProduced)
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

  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticStatus
  status;
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
  mode;
  final String sourceSeamProbeStatus;
  final String sourcePreflightDiagnosticStatus;
  final String sourcePreflightStatus;
  final String sourceDisabledRuntimeSkeletonDiagnosticStatus;
  final String sourceDisabledRuntimeSkeletonStatus;
  final List<
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticRow
  >
  rows;
  final List<String> findings;
  final bool safeForPhase34O;
  final String nextRecommendation;
  final int totalDiagnosticRows;
  final int requestDiagnosticRowCount;
  final int responseDiagnosticRowCount;
  final int attemptDiagnosticRowCount;
  final int boundaryDiagnosticRowCount;
  final int blockedReasonDiagnosticRowCount;
  final int deniedDiagnosticRowCount;
  final int proofDiagnosticRowCount;
  final int recommendationDiagnosticRowCount;
  final int seamProbeAttemptCount;
  final int seamProbePerformedCount;
  final int runtimeExecutionCount;
  final int runtimeExecutionApprovedCount;
  final int analyzerRuntimeInputProducedCount;
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
      !safeForPhase34O ||
      findings.isNotEmpty ||
      seamProbeAttemptCount < 1 ||
      seamProbePerformedCount > 0 ||
      runtimeExecutionCount > 0 ||
      runtimeExecutionApprovedCount > 0 ||
      analyzerRuntimeInputProducedCount > 0 ||
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
        '# Disabled Analyzer Adapter Runtime Execution Seam Probe Diagnostic',
      )
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticVersion',
      )
      ..writeln('- diagnostic status: ${status.wire}')
      ..writeln('- disabled seam probe diagnostic mode: ${mode.wire}')
      ..writeln('- source seam probe status: $sourceSeamProbeStatus')
      ..writeln(
        '- source preflight diagnostic status: $sourcePreflightDiagnosticStatus',
      )
      ..writeln('- source preflight status: $sourcePreflightStatus')
      ..writeln(
        '- source disabled runtime skeleton diagnostic status: $sourceDisabledRuntimeSkeletonDiagnosticStatus',
      )
      ..writeln(
        '- source disabled runtime skeleton status: $sourceDisabledRuntimeSkeletonStatus',
      )
      ..writeln('- safe for Phase 34O: $safeForPhase34O')
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
      ..writeln('## Disabled Seam Probe Diagnostic Rows')
      ..writeln(
        '| Row | Mode | Request | Response | Attempt | Boundaries | Blocked reasons | Seam performed | Execution performed | Runtime approved | Analyzer input produced | Findings |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in rows) {
      buffer.writeln(
        '| ${row.diagnosticRowId} | ${row.diagnosticMode} | ${row.requestId} | ${row.responseId} | ${row.attemptId} | ${_ids(row.boundaryIds)} | ${_ids(row.blockedReasonIds)} | ${row.seamProbePerformed} | ${row.executionPerformed} | ${row.runtimeExecutionApproved} | ${row.analyzerRuntimeInputProduced} | ${_ids(row.findings)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Diagnostic Row Summary')
      ..writeln('- request rows: $requestDiagnosticRowCount')
      ..writeln('- response rows: $responseDiagnosticRowCount')
      ..writeln('- attempt rows: $attemptDiagnosticRowCount')
      ..writeln('- boundary rows: $boundaryDiagnosticRowCount')
      ..writeln('- blocked reason rows: $blockedReasonDiagnosticRowCount')
      ..writeln('- denied rows: $deniedDiagnosticRowCount')
      ..writeln('- proof rows: $proofDiagnosticRowCount')
      ..writeln('- recommendation rows: $recommendationDiagnosticRowCount')
      ..writeln()
      ..writeln('## Safety Summary')
      ..writeln('- seam probe attempt count: $seamProbeAttemptCount')
      ..writeln('- seam probe performed count: $seamProbePerformedCount')
      ..writeln('- runtime execution count: $runtimeExecutionCount')
      ..writeln(
        '- runtime execution approved count: $runtimeExecutionApprovedCount',
      )
      ..writeln(
        '- analyzer runtime input produced count: $analyzerRuntimeInputProducedCount',
      )
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
      ..writeln('- safe for Phase 34O: $safeForPhase34O')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- findings: ${_ids(findings)}')
      ..writeln();
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent(' ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticVersion,
      'status': status.wire,
      'mode': mode.wire,
      'sourceSeamProbeStatus': sourceSeamProbeStatus,
      'sourcePreflightDiagnosticStatus': sourcePreflightDiagnosticStatus,
      'sourcePreflightStatus': sourcePreflightStatus,
      'sourceDisabledRuntimeSkeletonDiagnosticStatus':
          sourceDisabledRuntimeSkeletonDiagnosticStatus,
      'sourceDisabledRuntimeSkeletonStatus':
          sourceDisabledRuntimeSkeletonStatus,
      'safeForPhase34O': safeForPhase34O,
      'nextRecommendation': nextRecommendation,
      'counts': <String, Object?>{
        'totalDiagnosticRows': totalDiagnosticRows,
        'requestDiagnosticRowCount': requestDiagnosticRowCount,
        'responseDiagnosticRowCount': responseDiagnosticRowCount,
        'attemptDiagnosticRowCount': attemptDiagnosticRowCount,
        'boundaryDiagnosticRowCount': boundaryDiagnosticRowCount,
        'blockedReasonDiagnosticRowCount': blockedReasonDiagnosticRowCount,
        'deniedDiagnosticRowCount': deniedDiagnosticRowCount,
        'proofDiagnosticRowCount': proofDiagnosticRowCount,
        'recommendationDiagnosticRowCount': recommendationDiagnosticRowCount,
        'unsafeCount': unsafeCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'seamProbeAttemptCount': seamProbeAttemptCount,
        'seamProbePerformedCount': seamProbePerformedCount,
        'runtimeExecutionCount': runtimeExecutionCount,
        'runtimeExecutionApprovedCount': runtimeExecutionApprovedCount,
        'analyzerRuntimeInputProducedCount': analyzerRuntimeInputProducedCount,
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

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnostic {
  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnostic();

  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticResult
  evaluate({
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
        mode =
        DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
            .defaultMode,
    DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult? seamProbeResult,
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticResult?
    runtimeExecutionPreflightDiagnosticResult,
    ControlledAnalyzerAdapterRuntimeExecutionPreflightResult?
    runtimeExecutionPreflightResult,
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticResult?
    disabledRuntimeSkeletonDiagnosticResult,
    DisabledAnalyzerAdapterRuntimeSkeletonResult? disabledRuntimeSkeletonResult,
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticResult?
    runtimePreparationDiagnosticResult,
    ControlledAnalyzerAdapterRuntimePreparationResult? runtimePreparationResult,
  }) {
    final preparation =
        runtimePreparationResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation()
            .evaluate();
    final preparationDiagnostic =
        runtimePreparationDiagnosticResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic()
            .evaluate(runtimePreparationResult: preparation);
    final skeleton =
        disabledRuntimeSkeletonResult ??
        const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeleton().evaluate(
          runtimePreparationDiagnosticResult: preparationDiagnostic,
          runtimePreparationResult: preparation,
        );
    final skeletonDiagnostic =
        disabledRuntimeSkeletonDiagnosticResult ??
        const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnostic()
            .evaluate(
              skeletonResult: skeleton,
              runtimePreparationDiagnosticResult: preparationDiagnostic,
              runtimePreparationResult: preparation,
            );
    final preflight =
        runtimeExecutionPreflightResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflight()
            .evaluate(
              disabledRuntimeSkeletonDiagnosticResult: skeletonDiagnostic,
              disabledRuntimeSkeletonResult: skeleton,
              runtimePreparationDiagnosticResult: preparationDiagnostic,
              runtimePreparationResult: preparation,
            );
    final preflightDiagnostic =
        runtimeExecutionPreflightDiagnosticResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnostic()
            .evaluate(
              runtimeExecutionPreflightResult: preflight,
              disabledRuntimeSkeletonDiagnosticResult: skeletonDiagnostic,
              disabledRuntimeSkeletonResult: skeleton,
              runtimePreparationDiagnosticResult: preparationDiagnostic,
              runtimePreparationResult: preparation,
            );
    final seamProbe =
        seamProbeResult ??
        const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbe()
            .evaluate(
              runtimeExecutionPreflightDiagnosticResult: preflightDiagnostic,
              runtimeExecutionPreflightResult: preflight,
              disabledRuntimeSkeletonDiagnosticResult: skeletonDiagnostic,
              disabledRuntimeSkeletonResult: skeleton,
              runtimePreparationDiagnosticResult: preparationDiagnostic,
              runtimePreparationResult: preparation,
            );
    final rows = _rowsFor(seamProbe, mode);
    final findings = _sorted(<String>[
      if (seamProbe.hasUnsafePolicyViolation || !seamProbe.safeForPhase34N)
        'unsafePhase34MDisabledRuntimeExecutionSeamProbe',
      if (preflightDiagnostic.hasUnsafePolicyViolation ||
          !preflightDiagnostic.safeForPhase34M)
        'unsafePhase34LRuntimeExecutionPreflightDiagnostic',
      if (preflight.hasUnsafePolicyViolation || !preflight.safeForPhase34L)
        'unsafePhase34KControlledRuntimeExecutionPreflight',
      ...const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticValidator()
          .validateRows(rows),
    ]);
    final safeForPhase34O = findings.isEmpty;
    return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticResult(
      status: !safeForPhase34O
          ? DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticStatus
                .blockedByPolicyBoundary
          : rows.any((row) => row.warningReasons.isNotEmpty)
          ? DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticStatus
                .disabledAnalyzerAdapterRuntimeExecutionSeamProbeDiagnosticReadyWithWarnings
          : DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticStatus
                .disabledAnalyzerAdapterRuntimeExecutionSeamProbeDiagnosticReadyClean,
      mode: mode,
      sourceSeamProbeStatus: seamProbe.status.wire,
      sourcePreflightDiagnosticStatus:
          seamProbe.sourcePreflightDiagnosticStatus,
      sourcePreflightStatus: seamProbe.sourcePreflightStatus,
      sourceDisabledRuntimeSkeletonDiagnosticStatus:
          seamProbe.sourceDisabledRuntimeSkeletonDiagnosticStatus,
      sourceDisabledRuntimeSkeletonStatus:
          seamProbe.sourceDisabledRuntimeSkeletonStatus,
      rows: rows,
      findings: findings,
      safeForPhase34O: safeForPhase34O,
      nextRecommendation: safeForPhase34O
          ? _phase34ORecommendation
          : 'blockedByUnsafeDisabledRuntimeExecutionSeamProbeDiagnostic',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticValidator {
  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticValidator();

  List<String> validateResult(
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticResult
    result,
  ) {
    return validateRows(result.rows);
  }

  List<String> validateRows(
    Iterable<
      DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticRow
    >
    rows,
  ) {
    return _sorted(rows.expand(validateRow));
  }

  List<String> validateRow(
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticRow
    row,
  ) {
    final activeDenied = _activeDeniedFieldIds(row.deniedFieldIds);
    return _sorted(<String>[
      if (!_knownModes.contains(row.diagnosticMode))
        'unknownDisabledSeamProbeDiagnosticMode',
      if (row.recommendation != _phase34ORecommendation)
        'missingPhase34OControlledRuntimeInputPreflightRecommendation',
      if (row.seamProbePerformed) 'seamProbePerformedEnabled',
      if (row.executionPerformed) 'executionPerformedEnabled',
      if (row.executionAllowed) 'executionAllowedEnabled',
      if (row.runtimeExecutionApproved) 'runtimeExecutionApprovedEnabled',
      if (row.analyzerRuntimeInputProduced) 'analyzerRuntimeInputProduced',
      if (row.analyzerWiringAllowed) 'analyzerWiringEnabled',
      if (row.engineCallsAllowed) 'engineCallsEnabled',
      if (row.schedulerAllowed) 'schedulerExecutionEnabled',
      if (row.persistenceAllowed) 'persistenceWriteEnabled',
      if (row.productOutputAllowed) 'productOutputEnabled',
      if (row.productAdapterAllowed) 'productAdapterEnabled',
      if (row.savedAnalysisAllowed) 'savedAnalysisIntegrationEnabled',
      if (row.boundaryIds.any((id) => id.startsWith('active:')))
        'seamProbeBoundaryActivated',
      if (row.blockedReasonIds.any((id) => id.startsWith('active:')))
        'blockedReasonActivated',
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
      if (lower.contains('backend://') ||
          lower.contains('http://secret') ||
          lower.contains('https://secret'))
        'reportTextLeak:backendSecret',
    ]);
  }
}

List<
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticRow
>
_rowsFor(
  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult seamProbe,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
  mode,
) {
  final rows =
      <
        DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticRow
      >[];
  final includeAll =
      mode ==
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
              .defaultMode ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
              .allSafe;
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
              .request) {
    rows.add(
      _row(
        seamProbe,
        mode,
        diagnosticRowId: _requestRowPrefix,
        requestId: seamProbe.request.requestId,
        boundaryIds: seamProbe.request.boundaryIds,
        blockedReasonIds: seamProbe.request.blockedReasonIds,
        deniedFieldIds: seamProbe.request.deniedFieldIds,
        warningReasons: seamProbe.request.warningReasons,
        diagnosticStatus: 'disabledSeamProbeRequestMetadataOnly',
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
              .response) {
    rows.add(
      _row(
        seamProbe,
        mode,
        diagnosticRowId: _responseRowPrefix,
        responseId: seamProbe.response.responseId,
        blockedReasonIds: seamProbe.response.blockedReasonIds,
        deniedFieldIds: seamProbe.response.deniedFieldIds,
        warningReasons: seamProbe.response.warningReasons,
        proofLimitReasons: seamProbe.response.proofLimitReasons,
        seamProbePerformed: seamProbe.response.seamProbePerformed,
        executionPerformed: seamProbe.response.executionPerformed,
        executionAllowed: seamProbe.response.executionAllowed,
        runtimeExecutionApproved: seamProbe.response.runtimeExecutionApproved,
        analyzerRuntimeInputProduced:
            seamProbe.response.analyzerRuntimeInputProduced,
        analyzerWiringAllowed: seamProbe.response.analyzerWiringAllowed,
        engineCallsAllowed: seamProbe.response.engineCallsAllowed,
        schedulerAllowed: seamProbe.response.schedulerAllowed,
        persistenceAllowed: seamProbe.response.persistenceAllowed,
        productOutputAllowed: seamProbe.response.productOutputAllowed,
        productAdapterAllowed: seamProbe.response.productAdapterAllowed,
        savedAnalysisAllowed: seamProbe.response.savedAnalysisAllowed,
        diagnosticStatus: seamProbe.response.responseStatus,
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
              .attempt) {
    rows.add(
      _row(
        seamProbe,
        mode,
        diagnosticRowId: _attemptRowPrefix,
        attemptId: seamProbe.attempt.attemptId,
        blockedReasonIds: seamProbe.attempt.blockedReasonIds,
        deniedFieldIds: seamProbe.attempt.deniedFieldIds,
        seamProbeRequested: seamProbe.attempt.seamProbeRequested,
        seamProbePerformed: seamProbe.attempt.seamProbePerformed,
        executionPerformed: seamProbe.attempt.executionPerformed,
        executionAllowed: seamProbe.attempt.executionAllowed,
        runtimeExecutionApproved: seamProbe.attempt.runtimeExecutionApproved,
        analyzerRuntimeInputProduced:
            seamProbe.attempt.analyzerRuntimeInputProduced,
        diagnosticStatus: seamProbe.attempt.refused
            ? 'disabledSeamProbeAttemptRefused'
            : 'disabledSeamProbeAttemptUnsafe',
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
              .boundaries) {
    rows.addAll(
      seamProbe.boundaries.map(
        (boundary) => _row(
          seamProbe,
          mode,
          diagnosticRowId:
              '$_boundaryRowPrefix-${boundary.boundaryId.toLowerCase()}',
          boundaryIds: <String>[boundary.boundaryId],
          deniedFieldIds: boundary.deniedFieldIds,
          diagnosticStatus: boundary.blocked
              ? 'seamProbeBoundaryRemainsBlocked'
              : 'seamProbeBoundaryUnsafe',
        ),
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
              .blockedReasons) {
    rows.addAll(
      seamProbe.blockedReasons.map(
        (reason) => _row(
          seamProbe,
          mode,
          diagnosticRowId:
              '$_blockedReasonRowPrefix-${reason.blockedSurface.toLowerCase()}',
          blockedReasonIds: <String>[reason.blockedReasonId],
          deniedFieldIds: reason.deniedFieldIds,
          diagnosticStatus: reason.blocked
              ? 'blockedReasonRemainsBlocked'
              : 'blockedReasonUnsafe',
        ),
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
              .denied) {
    rows.add(
      _row(
        seamProbe,
        mode,
        diagnosticRowId: _deniedRowPrefix,
        deniedFieldIds: seamProbe.policy.deniedFieldIds,
        diagnosticStatus: 'deniedFieldsRemainInactive',
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
              .proof) {
    rows.add(
      _row(
        seamProbe,
        mode,
        diagnosticRowId: _proofRowPrefix,
        boundaryIds: const <String>['androidCollectorBoundary'],
        blockedReasonIds: const <String>[
          'androidCollectorBlocked',
          'phase32EProofHonestyPreserved',
        ],
        diagnosticStatus: 'capturedAndroidProofBoundaryOnly',
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
              .recommendation) {
    rows.add(
      _row(
        seamProbe,
        mode,
        diagnosticRowId: _recommendationRowPrefix,
        boundaryIds: seamProbe.boundaries
            .map((boundary) => boundary.boundaryId)
            .toList(),
        blockedReasonIds: seamProbe.blockedReasons
            .map((reason) => reason.blockedReasonId)
            .toList(),
        diagnosticStatus:
            'phase34OControlledRuntimeInputPreflightRecommendationOnly',
      ),
    );
  }
  return rows;
}

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticRow
_row(
  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult seamProbe,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
  mode, {
  required String diagnosticRowId,
  String? requestId,
  String? responseId,
  String? attemptId,
  List<String>? boundaryIds,
  List<String>? blockedReasonIds,
  List<String>? deniedFieldIds,
  List<String>? warningReasons,
  List<String>? proofLimitReasons,
  bool? seamProbeRequested,
  bool? seamProbePerformed,
  bool? executionPerformed,
  bool? executionAllowed,
  bool? runtimeExecutionApproved,
  bool? analyzerRuntimeInputProduced,
  bool? analyzerWiringAllowed,
  bool? engineCallsAllowed,
  bool? schedulerAllowed,
  bool? persistenceAllowed,
  bool? productOutputAllowed,
  bool? productAdapterAllowed,
  bool? savedAnalysisAllowed,
  required String diagnosticStatus,
}) {
  final input = seamProbe.input;
  return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticRow(
    diagnosticRowId: diagnosticRowId,
    seamProbeId: input.seamProbeId,
    sourcePhase: input.sourcePhase,
    sourceDiagnosticIds: input.sourceDiagnosticIds,
    sourcePreflightIds: input.sourcePreflightIds,
    sourceSkeletonIds: input.sourceSkeletonIds,
    sourcePreparationIds: input.sourcePreparationIds,
    sourceCaseIds: input.sourceCaseIds,
    sourceActionIds: input.sourceActionIds,
    sourcePatchIds: input.sourcePatchIds,
    sourceRefinementIds: input.sourceRefinementIds,
    diagnosticMode: mode.wire,
    requestId: requestId ?? input.requestId,
    responseId: responseId ?? input.responseId,
    attemptId: attemptId ?? input.attemptId,
    boundaryIds: boundaryIds ?? input.boundaryIds,
    blockedReasonIds: blockedReasonIds ?? input.blockedReasonIds,
    deniedFieldIds: deniedFieldIds ?? input.deniedFieldIds,
    supportAreaIds: input.supportAreaIds,
    warningReasons: warningReasons ?? input.warningReasons,
    proofLimitReasons: proofLimitReasons ?? input.proofLimitReasons,
    androidProofIds: input.androidProofIds,
    ownerProofRequired: input.ownerProofRequired,
    seamProbeRequested: seamProbeRequested ?? input.seamProbeRequested,
    seamProbePerformed: seamProbePerformed ?? false,
    executionPerformed: executionPerformed ?? false,
    executionAllowed: executionAllowed ?? false,
    runtimeExecutionApproved: runtimeExecutionApproved ?? false,
    analyzerRuntimeInputProduced: analyzerRuntimeInputProduced ?? false,
    analyzerWiringAllowed: analyzerWiringAllowed ?? false,
    engineCallsAllowed: engineCallsAllowed ?? false,
    schedulerAllowed: schedulerAllowed ?? false,
    persistenceAllowed: persistenceAllowed ?? false,
    productOutputAllowed: productOutputAllowed ?? false,
    productAdapterAllowed: productAdapterAllowed ?? false,
    savedAnalysisAllowed: savedAnalysisAllowed ?? false,
    diagnosticStatus: diagnosticStatus,
    findings: const <String>[],
    recommendation: _phase34ORecommendation,
  );
}

int _countRowPrefix(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticRow
  >
  rows,
  String prefix,
) {
  return rows.where((row) => row.diagnosticRowId.startsWith(prefix)).length;
}

int _countActiveFields(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticRow
  >
  rows,
  Set<String> fieldIds,
) {
  return rows
      .expand((row) => _activeDeniedFieldIds(row.deniedFieldIds))
      .where(fieldIds.contains)
      .length;
}

List<String> _activeDeniedFieldIds(Iterable<String> deniedFieldIds) {
  return deniedFieldIds
      .where((id) => id.startsWith('active:'))
      .map((id) => id.substring('active:'.length))
      .toList();
}

bool _isQuietSupport(Iterable<String> supportAreaIds) {
  return supportAreaIds.any(
    (id) =>
        id == 'quietMove' ||
        id == 'quietPreparatoryMove' ||
        id == 'quietPreparatory',
  );
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

const _phase34ORecommendation =
    'implementControlledAnalyzerAdapterRuntimeInputPreflightPatch';
const _requestRowPrefix = 'disabled-seam-probe-diagnostic-request';
const _responseRowPrefix = 'disabled-seam-probe-diagnostic-response';
const _attemptRowPrefix = 'disabled-seam-probe-diagnostic-attempt';
const _boundaryRowPrefix = 'disabled-seam-probe-diagnostic-boundary';
const _blockedReasonRowPrefix = 'disabled-seam-probe-diagnostic-blocked-reason';
const _deniedRowPrefix = 'disabled-seam-probe-diagnostic-denied';
const _proofRowPrefix = 'disabled-seam-probe-diagnostic-proof';
const _recommendationRowPrefix =
    'disabled-seam-probe-diagnostic-recommendation';
const _pvMultiPvBoundaryCaseId = 'pv-multipv-support-boundary-32e';

const _knownModes = <String>{
  'default',
  'all-safe',
  'request',
  'response',
  'attempt',
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
  'king-safety-mating-net-32e',
  'king-safety-mating-net-pressure-32e',
  'endgame-candidate-spread-32e',
  'endgame-precision-candidate-spread-32e',
  'budget-pressure-depth-limited-32e',
  'budget-pressure-wide-candidate-32e',
  'suppression-forced-only-legal-32e',
  _pvMultiPvBoundaryCaseId,
};

const _productFields = <String>{'productLabel', 'productOutput'};
const _finalLabelFields = <String>{'finalMoveLabel'};
const _classifierFields = <String>{
  'classifierLabels',
  'classifierLabel',
  'brilliantGreatMiss',
  'brilliantLabel',
  'greatLabel',
  'missLabel',
  'bestGoodInaccuracyMistakeBlunder',
};
const _scoreFields = <String>{
  'numericMoveScore',
  'aggregateScore',
  'moveScore',
};
const _rankingMetricFields = <String>{
  'moveRanking',
  'officialMetric',
  'officialAccuracy',
  'accuracy',
  'acpl',
};

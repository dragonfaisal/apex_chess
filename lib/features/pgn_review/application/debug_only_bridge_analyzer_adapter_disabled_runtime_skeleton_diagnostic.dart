import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton.dart';

const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticVersion =
    'debug-only-bridge-analyzer-adapter-disabled-runtime-skeleton-diagnostic-v1';

enum DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticStatus {
  disabledAnalyzerAdapterRuntimeSkeletonDiagnosticReadyWithWarnings(
    'disabledAnalyzerAdapterRuntimeSkeletonDiagnosticReadyWithWarnings',
  ),
  disabledAnalyzerAdapterRuntimeSkeletonDiagnosticReadyClean(
    'disabledAnalyzerAdapterRuntimeSkeletonDiagnosticReadyClean',
  ),
  blockedByUnsafeDisabledRuntimeSkeleton(
    'blockedByUnsafeDisabledRuntimeSkeleton',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidDisabledRuntimeSkeletonDiagnostic(
    'invalidDisabledRuntimeSkeletonDiagnostic',
  );

  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticStatus(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode {
  defaultMode('default'),
  allSafe('all-safe'),
  request('request'),
  response('response'),
  attempt('attempt'),
  policy('policy'),
  blockedSeams('blocked-seams'),
  denied('denied'),
  proof('proof'),
  recommendation('recommendation');

  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow {
  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow({
    required this.diagnosticRowId,
    required this.skeletonId,
    required this.sourcePhase,
    required this.sourceDiagnosticIds,
    required this.sourcePreparationIds,
    required this.sourceCaseIds,
    required this.sourceActionIds,
    required this.sourcePatchIds,
    required this.sourceRefinementIds,
    required this.diagnosticMode,
    required this.requestEnvelopeId,
    required this.responseEnvelopeId,
    required this.executionAttemptId,
    required this.executionAttempted,
    required this.executionPerformed,
    required this.executionRefusedReason,
    required this.policyId,
    required this.blockedSeamIds,
    required this.deniedFieldIds,
    required this.supportAreaIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.androidProofIds,
    required this.ownerProofRequired,
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
  final String skeletonId;
  final String sourcePhase;
  final List<String> sourceDiagnosticIds;
  final List<String> sourcePreparationIds;
  final List<String> sourceCaseIds;
  final List<String> sourceActionIds;
  final List<String> sourcePatchIds;
  final List<String> sourceRefinementIds;
  final String diagnosticMode;
  final String requestEnvelopeId;
  final String responseEnvelopeId;
  final String executionAttemptId;
  final bool executionAttempted;
  final bool executionPerformed;
  final String executionRefusedReason;
  final String policyId;
  final List<String> blockedSeamIds;
  final List<String> deniedFieldIds;
  final List<String> supportAreaIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofIds;
  final bool ownerProofRequired;
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

  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow copyWith({
    String? diagnosticRowId,
    String? skeletonId,
    String? sourcePhase,
    List<String>? sourceDiagnosticIds,
    List<String>? sourcePreparationIds,
    List<String>? sourceCaseIds,
    List<String>? sourceActionIds,
    List<String>? sourcePatchIds,
    List<String>? sourceRefinementIds,
    String? diagnosticMode,
    String? requestEnvelopeId,
    String? responseEnvelopeId,
    String? executionAttemptId,
    bool? executionAttempted,
    bool? executionPerformed,
    String? executionRefusedReason,
    String? policyId,
    List<String>? blockedSeamIds,
    List<String>? deniedFieldIds,
    List<String>? supportAreaIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? androidProofIds,
    bool? ownerProofRequired,
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
    return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow(
      diagnosticRowId: diagnosticRowId ?? this.diagnosticRowId,
      skeletonId: skeletonId ?? this.skeletonId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      sourceDiagnosticIds: sourceDiagnosticIds ?? this.sourceDiagnosticIds,
      sourcePreparationIds: sourcePreparationIds ?? this.sourcePreparationIds,
      sourceCaseIds: sourceCaseIds ?? this.sourceCaseIds,
      sourceActionIds: sourceActionIds ?? this.sourceActionIds,
      sourcePatchIds: sourcePatchIds ?? this.sourcePatchIds,
      sourceRefinementIds: sourceRefinementIds ?? this.sourceRefinementIds,
      diagnosticMode: diagnosticMode ?? this.diagnosticMode,
      requestEnvelopeId: requestEnvelopeId ?? this.requestEnvelopeId,
      responseEnvelopeId: responseEnvelopeId ?? this.responseEnvelopeId,
      executionAttemptId: executionAttemptId ?? this.executionAttemptId,
      executionAttempted: executionAttempted ?? this.executionAttempted,
      executionPerformed: executionPerformed ?? this.executionPerformed,
      executionRefusedReason:
          executionRefusedReason ?? this.executionRefusedReason,
      policyId: policyId ?? this.policyId,
      blockedSeamIds: blockedSeamIds ?? this.blockedSeamIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      supportAreaIds: supportAreaIds ?? this.supportAreaIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      androidProofIds: androidProofIds ?? this.androidProofIds,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
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
      'skeletonId': skeletonId,
      'sourcePhase': sourcePhase,
      'sourceDiagnosticIds': sourceDiagnosticIds,
      'sourcePreparationIds': sourcePreparationIds,
      'sourceCaseIds': sourceCaseIds,
      'sourceActionIds': sourceActionIds,
      'sourcePatchIds': sourcePatchIds,
      'sourceRefinementIds': sourceRefinementIds,
      'diagnosticMode': diagnosticMode,
      'requestEnvelopeId': requestEnvelopeId,
      'responseEnvelopeId': responseEnvelopeId,
      'executionAttemptId': executionAttemptId,
      'executionAttempted': executionAttempted,
      'executionPerformed': executionPerformed,
      'executionRefusedReason': executionRefusedReason,
      'policyId': policyId,
      'blockedSeamIds': blockedSeamIds,
      'deniedFieldIds': deniedFieldIds,
      'supportAreaIds': supportAreaIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'androidProofIds': androidProofIds,
      'ownerProofRequired': ownerProofRequired,
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

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticResult {
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticResult({
    required this.status,
    required this.mode,
    required this.sourceSkeletonStatus,
    required this.sourceRuntimePreparationDiagnosticStatus,
    required this.sourceRuntimePreparationStatus,
    required this.rows,
    required this.findings,
    required this.safeForPhase34K,
    required this.nextRecommendation,
  }) : totalDiagnosticRows = rows.length,
       requestDiagnosticRowCount = _countRowPrefix(rows, _requestRowPrefix),
       responseDiagnosticRowCount = _countRowPrefix(rows, _responseRowPrefix),
       attemptDiagnosticRowCount = _countRowPrefix(rows, _attemptRowPrefix),
       policyDiagnosticRowCount = _countRowPrefix(rows, _policyRowPrefix),
       blockedSeamDiagnosticRowCount = _countRowPrefix(
         rows,
         _blockedSeamRowPrefix,
       ),
       deniedDiagnosticRowCount = _countRowPrefix(rows, _deniedRowPrefix),
       proofDiagnosticRowCount = _countRowPrefix(rows, _proofRowPrefix),
       recommendationDiagnosticRowCount = _countRowPrefix(
         rows,
         _recommendationRowPrefix,
       ),
       activeDeniedFieldCount = rows
           .expand((row) => _activeDeniedFieldIds(row.deniedFieldIds))
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
       uiBackendCacheDatabaseActivationCount = rows
           .where((row) => row.blockedSeamIds.any(_activeBlockedSeams.contains))
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

  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticStatus
  status;
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
  mode;
  final String sourceSkeletonStatus;
  final String sourceRuntimePreparationDiagnosticStatus;
  final String sourceRuntimePreparationStatus;
  final List<DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow>
  rows;
  final List<String> findings;
  final bool safeForPhase34K;
  final String nextRecommendation;
  final int totalDiagnosticRows;
  final int requestDiagnosticRowCount;
  final int responseDiagnosticRowCount;
  final int attemptDiagnosticRowCount;
  final int policyDiagnosticRowCount;
  final int blockedSeamDiagnosticRowCount;
  final int deniedDiagnosticRowCount;
  final int proofDiagnosticRowCount;
  final int recommendationDiagnosticRowCount;
  final int activeDeniedFieldCount;
  final int runtimeExecutionCount;
  final int analyzerWiringCount;
  final int executableRuntimeCount;
  final int engineCallCount;
  final int schedulerExecutionCount;
  final int persistenceWriteCount;
  final int productOutputCount;
  final int productAdapterCount;
  final int savedAnalysisIntegrationCount;
  final int uiBackendCacheDatabaseActivationCount;
  final int phase32EProofClaimCount;
  final int unprovenAndroidProofCount;
  final int ownerProofQueueCount;
  late final int unsafeCount;
  late final int blockerCount;
  late final int criticalCount;

  bool get hasUnsafePolicyViolation =>
      !safeForPhase34K ||
      findings.isNotEmpty ||
      activeDeniedFieldCount > 0 ||
      runtimeExecutionCount > 0 ||
      analyzerWiringCount > 0 ||
      executableRuntimeCount > 0 ||
      engineCallCount > 0 ||
      schedulerExecutionCount > 0 ||
      persistenceWriteCount > 0 ||
      productOutputCount > 0 ||
      productAdapterCount > 0 ||
      savedAnalysisIntegrationCount > 0 ||
      uiBackendCacheDatabaseActivationCount > 0 ||
      phase32EProofClaimCount > 0 ||
      unprovenAndroidProofCount > 0 ||
      ownerProofQueueCount > 0;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Disabled Analyzer Adapter Runtime Skeleton Diagnostic')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticVersion',
      )
      ..writeln('- disabled runtime skeleton diagnostic status: ${status.wire}')
      ..writeln('- disabled runtime skeleton diagnostic mode: ${mode.wire}')
      ..writeln('- source skeleton status: $sourceSkeletonStatus')
      ..writeln(
        '- source runtime-preparation diagnostic status: $sourceRuntimePreparationDiagnosticStatus',
      )
      ..writeln(
        '- source runtime-preparation status: $sourceRuntimePreparationStatus',
      )
      ..writeln('- safe for Phase 34K: $safeForPhase34K')
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
      ..writeln('## Disabled Runtime Skeleton Diagnostic Rows')
      ..writeln(
        '| Row | Request | Response | Attempt | Attempted | Performed | Refused reason | Policy | Blocked seams | Execution | Analyzer wiring | Engine calls | Scheduler | Persistence | Product output | Findings |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in rows) {
      buffer.writeln(
        '| ${row.diagnosticRowId} | ${row.requestEnvelopeId} | ${row.responseEnvelopeId} | ${row.executionAttemptId} | ${row.executionAttempted} | ${row.executionPerformed} | ${row.executionRefusedReason} | ${row.policyId} | ${_ids(row.blockedSeamIds)} | ${row.executionAllowed} | ${row.analyzerWiringAllowed} | ${row.engineCallsAllowed} | ${row.schedulerAllowed} | ${row.persistenceAllowed} | ${row.productOutputAllowed} | ${_ids(row.findings)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Diagnostic Row Summary')
      ..writeln('- request diagnostic rows: $requestDiagnosticRowCount')
      ..writeln('- response diagnostic rows: $responseDiagnosticRowCount')
      ..writeln('- attempt diagnostic rows: $attemptDiagnosticRowCount')
      ..writeln('- policy diagnostic rows: $policyDiagnosticRowCount')
      ..writeln(
        '- blocked seam diagnostic rows: $blockedSeamDiagnosticRowCount',
      )
      ..writeln('- denied diagnostic rows: $deniedDiagnosticRowCount')
      ..writeln('- proof diagnostic rows: $proofDiagnosticRowCount')
      ..writeln(
        '- recommendation diagnostic rows: $recommendationDiagnosticRowCount',
      )
      ..writeln()
      ..writeln('## Safety Summary')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
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
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Recommendation')
      ..writeln('- safe for Phase 34K: $safeForPhase34K')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- findings: ${_ids(findings)}')
      ..writeln();
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent(' ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticVersion,
      'status': status.wire,
      'disabledRuntimeSkeletonDiagnosticMode': mode.wire,
      'sourceSkeletonStatus': sourceSkeletonStatus,
      'sourceRuntimePreparationDiagnosticStatus':
          sourceRuntimePreparationDiagnosticStatus,
      'sourceRuntimePreparationStatus': sourceRuntimePreparationStatus,
      'safeForPhase34K': safeForPhase34K,
      'nextRecommendation': nextRecommendation,
      'counts': <String, Object?>{
        'totalDiagnosticRows': totalDiagnosticRows,
        'requestDiagnosticRowCount': requestDiagnosticRowCount,
        'responseDiagnosticRowCount': responseDiagnosticRowCount,
        'attemptDiagnosticRowCount': attemptDiagnosticRowCount,
        'policyDiagnosticRowCount': policyDiagnosticRowCount,
        'blockedSeamDiagnosticRowCount': blockedSeamDiagnosticRowCount,
        'deniedDiagnosticRowCount': deniedDiagnosticRowCount,
        'proofDiagnosticRowCount': proofDiagnosticRowCount,
        'recommendationDiagnosticRowCount': recommendationDiagnosticRowCount,
        'unsafeCount': unsafeCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'activeDeniedFieldCount': activeDeniedFieldCount,
        'runtimeExecutionCount': runtimeExecutionCount,
        'executableRuntimeCount': executableRuntimeCount,
        'analyzerWiringCount': analyzerWiringCount,
        'engineCallCount': engineCallCount,
        'schedulerExecutionCount': schedulerExecutionCount,
        'persistenceWriteCount': persistenceWriteCount,
        'productOutputCount': productOutputCount,
        'productAdapterCount': productAdapterCount,
        'savedAnalysisIntegrationCount': savedAnalysisIntegrationCount,
        'phase32EProofClaimCount': phase32EProofClaimCount,
        'unprovenAndroidProofCount': unprovenAndroidProofCount,
        'ownerProofQueueCount': ownerProofQueueCount,
      },
      'rows': rows.map((row) => row.toJson()).toList(growable: false),
      'findings': findings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnostic {
  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnostic();

  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticResult
  evaluate({
    DisabledAnalyzerAdapterRuntimeSkeletonResult? skeletonResult,
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticResult?
    runtimePreparationDiagnosticResult,
    ControlledAnalyzerAdapterRuntimePreparationResult? runtimePreparationResult,
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode mode =
        DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
            .defaultMode,
  }) {
    final preparation =
        runtimePreparationResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation()
            .evaluate();
    final runtimeDiagnostic =
        runtimePreparationDiagnosticResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic()
            .evaluate(runtimePreparationResult: preparation);
    final skeleton =
        skeletonResult ??
        const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeleton().evaluate(
          runtimePreparationDiagnosticResult: runtimeDiagnostic,
          runtimePreparationResult: preparation,
        );
    final rows = _rowsForMode(skeleton, mode);
    final findings = _sorted(<String>[
      if (runtimeDiagnostic.hasUnsafePolicyViolation ||
          !runtimeDiagnostic.safeForPhase34I)
        'unsafePhase34HControlledRuntimePreparationDiagnostic',
      if (skeleton.hasUnsafePolicyViolation || !skeleton.safeForPhase34J)
        'unsafePhase34IDisabledRuntimeSkeleton',
      ...const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticValidator()
          .validateRows(rows, mode: mode),
    ]);
    final safeForPhase34K = findings.isEmpty;
    return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticResult(
      status: !safeForPhase34K
          ? DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticStatus
                .blockedByPolicyBoundary
          : rows.any(
              (row) =>
                  row.warningReasons.isNotEmpty ||
                  row.proofLimitReasons.isNotEmpty,
            )
          ? DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticStatus
                .disabledAnalyzerAdapterRuntimeSkeletonDiagnosticReadyWithWarnings
          : DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticStatus
                .disabledAnalyzerAdapterRuntimeSkeletonDiagnosticReadyClean,
      mode: mode,
      sourceSkeletonStatus: skeleton.status.wire,
      sourceRuntimePreparationDiagnosticStatus: runtimeDiagnostic.status.wire,
      sourceRuntimePreparationStatus: preparation.status.wire,
      rows: rows,
      findings: findings,
      safeForPhase34K: safeForPhase34K,
      nextRecommendation: safeForPhase34K
          ? _phase34KRecommendation
          : 'blockedByUnsafeDisabledRuntimeSkeletonDiagnostic',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticValidator {
  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticValidator();

  List<String> validateRows(
    Iterable<DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow>
    rows, {
    required DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
    mode,
  }) {
    final records = rows.toList();
    final findings = <String>[
      if (!_allowedModes.contains(mode.wire))
        'unknownDisabledRuntimeSkeletonDiagnosticMode',
      if (!records.any((row) => row.recommendation == _phase34KRecommendation))
        'missingPhase34KControlledRuntimeExecutionPreflightRecommendation',
    ];
    for (final row in records) {
      findings.addAll(validateRow(row));
    }
    return _sorted(findings);
  }

  List<String> validateRow(
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow row,
  ) {
    final activeDenied = _activeDeniedFieldIds(row.deniedFieldIds);
    final activeSeams = row.blockedSeamIds
        .where((id) => id.startsWith('active:'))
        .map((id) => id.substring('active:'.length))
        .toSet();
    return _sorted(<String>[
      if (!_allowedModes.contains(row.diagnosticMode))
        'unknownDisabledRuntimeSkeletonDiagnosticMode',
      if (row.recommendation != _phase34KRecommendation)
        'missingPhase34KControlledRuntimeExecutionPreflightRecommendation',
      if (row.executionAttempted &&
          !row.diagnosticRowId.startsWith(_attemptRowPrefix))
        'executionAttemptOutsideRefusedSkeletonSeam',
      if (row.executionAttempted && row.executionRefusedReason.trim().isEmpty)
        'missingExecutionRefusedReason',
      if (row.executionPerformed) 'runtimeExecutionResultEnabled',
      if (row.executionAllowed) 'executionAllowedEnabled',
      if (row.analyzerWiringAllowed) 'analyzerWiringEnabled',
      if (row.engineCallsAllowed) 'engineCallsEnabled',
      if (row.schedulerAllowed) 'schedulerExecutionEnabled',
      if (row.persistenceAllowed) 'persistenceWriteEnabled',
      if (row.productOutputAllowed) 'productOutputEnabled',
      if (row.productAdapterAllowed) 'productAdapterEnabled',
      if (row.savedAnalysisAllowed) 'savedAnalysisIntegrationEnabled',
      if (activeSeams.isNotEmpty) 'blockedSeamActivated',
      if (activeSeams.contains('analyzerRuntime')) 'analyzerRuntimeEnabled',
      if (activeSeams.contains('analyzerWiring')) 'analyzerWiringEnabled',
      if (activeSeams.contains('engineCall')) 'engineCallsEnabled',
      if (activeSeams.contains('StockfishBridge')) 'stockfishCommandEnabled',
      if (activeSeams.contains('AndroidCollector'))
        'androidCollectorRequirementEnabled',
      if (activeSeams.contains('schedulerExecution'))
        'schedulerExecutionEnabled',
      if (activeSeams.contains('persistenceWrite')) 'persistenceWriteEnabled',
      if (activeSeams.contains('productAdapter')) 'productAdapterEnabled',
      if (activeSeams.contains('savedAnalysisIntegration'))
        'savedAnalysisIntegrationEnabled',
      if (activeSeams.intersection(_uiBackendCacheDatabaseSeams).isNotEmpty)
        'uiBackendCacheDatabaseActivationEnabled',
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

List<DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow>
_rowsForMode(
  DisabledAnalyzerAdapterRuntimeSkeletonResult source,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode mode,
) {
  final allRows =
      <DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow>[
        _rowForRequest(source, mode),
        _rowForResponse(source, mode),
        _rowForAttempt(source, mode),
        _rowForPolicy(source, mode),
        ...source.blockedSeams.map(
          (seam) => _rowForBlockedSeam(source, seam, mode),
        ),
        _rowForDenied(source, mode),
        _rowForProof(source, mode),
        _rowForRecommendation(source, mode),
      ];
  final selected = switch (mode) {
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
        .defaultMode ||
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
        .allSafe => allRows,
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
        .request =>
      allRows.where((row) => row.diagnosticRowId.startsWith(_requestRowPrefix)),
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
        .response =>
      allRows.where(
        (row) => row.diagnosticRowId.startsWith(_responseRowPrefix),
      ),
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
        .attempt =>
      allRows.where((row) => row.diagnosticRowId.startsWith(_attemptRowPrefix)),
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
        .policy =>
      allRows.where((row) => row.diagnosticRowId.startsWith(_policyRowPrefix)),
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
        .blockedSeams =>
      allRows.where(
        (row) => row.diagnosticRowId.startsWith(_blockedSeamRowPrefix),
      ),
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
        .denied =>
      allRows.where((row) => row.diagnosticRowId.startsWith(_deniedRowPrefix)),
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode.proof =>
      allRows.where((row) => row.diagnosticRowId.startsWith(_proofRowPrefix)),
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
        .recommendation =>
      allRows.where(
        (row) => row.diagnosticRowId.startsWith(_recommendationRowPrefix),
      ),
  };
  return selected.toList(growable: false);
}

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow _baseRow(
  DisabledAnalyzerAdapterRuntimeSkeletonResult source,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode mode,
  String rowId,
) {
  return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow(
    diagnosticRowId: rowId,
    skeletonId: source.request.skeletonId,
    sourcePhase: source.request.sourcePhase,
    sourceDiagnosticIds: source.request.sourceDiagnosticIds,
    sourcePreparationIds: source.request.sourcePreparationIds,
    sourceCaseIds: source.request.sourceCaseIds,
    sourceActionIds: source.request.sourceActionIds,
    sourcePatchIds: source.request.sourcePatchIds,
    sourceRefinementIds: source.request.sourceRefinementIds,
    diagnosticMode: mode.wire,
    requestEnvelopeId: source.request.requestEnvelopeId,
    responseEnvelopeId: source.response.responseEnvelopeId,
    executionAttemptId: source.executionAttempt.executionAttemptId,
    executionAttempted: false,
    executionPerformed: false,
    executionRefusedReason: 'diagnosticOnlyNoExecutionAttempt',
    policyId: source.policy.policyId,
    blockedSeamIds: source.blockedSeams
        .map((seam) => seam.blockedSeamId)
        .toList(),
    deniedFieldIds: source.policy.deniedFieldIds,
    supportAreaIds: source.request.supportAreaIds,
    warningReasons: source.request.warningReasons,
    proofLimitReasons: source.request.proofLimitReasons,
    androidProofIds: source.request.androidProofIds,
    ownerProofRequired: source.request.ownerProofRequired,
    executionAllowed: false,
    analyzerWiringAllowed: false,
    engineCallsAllowed: false,
    schedulerAllowed: false,
    persistenceAllowed: false,
    productOutputAllowed: false,
    productAdapterAllowed: false,
    savedAnalysisAllowed: false,
    diagnosticStatus: 'disabledRuntimeSkeletonDiagnosticReady',
    findings: const <String>[],
    recommendation: _phase34KRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow
_rowForRequest(
  DisabledAnalyzerAdapterRuntimeSkeletonResult source,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode mode,
) {
  return _baseRow(source, mode, '${_requestRowPrefix}envelope').copyWith(
    requestEnvelopeId: source.request.requestEnvelopeId,
    responseEnvelopeId: '',
    executionAttemptId: '',
    policyId: source.request.policyId,
    blockedSeamIds: source.request.blockedSeamIds,
    deniedFieldIds: source.request.deniedFieldIds,
    executionAllowed: source.request.executionAllowed,
    analyzerWiringAllowed: source.request.analyzerWiringAllowed,
    engineCallsAllowed: source.request.engineCallsAllowed,
    schedulerAllowed: source.request.schedulerAllowed,
    persistenceAllowed: source.request.persistenceAllowed,
    productOutputAllowed: source.request.productOutputAllowed,
    productAdapterAllowed: source.request.productAdapterAllowed,
    savedAnalysisAllowed: source.request.savedAnalysisAllowed,
  );
}

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow
_rowForResponse(
  DisabledAnalyzerAdapterRuntimeSkeletonResult source,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode mode,
) {
  return _baseRow(source, mode, '${_responseRowPrefix}envelope').copyWith(
    requestEnvelopeId: source.response.requestEnvelopeId,
    responseEnvelopeId: source.response.responseEnvelopeId,
    executionAttemptId: source.response.executionAttemptId,
    executionRefusedReason: source.response.executionRefusedReason,
    blockedSeamIds: source.response.blockedSeamIds,
    deniedFieldIds: source.response.deniedFieldIds,
    warningReasons: source.response.warningReasons,
    proofLimitReasons: source.response.proofLimitReasons,
    executionAllowed: source.response.executionAllowed,
    analyzerWiringAllowed: source.response.analyzerWiringAllowed,
    engineCallsAllowed: source.response.engineCallsAllowed,
    schedulerAllowed: source.response.schedulerAllowed,
    persistenceAllowed: source.response.persistenceAllowed,
    productOutputAllowed: source.response.productOutputAllowed,
    productAdapterAllowed: source.response.productAdapterAllowed,
    savedAnalysisAllowed: source.response.savedAnalysisAllowed,
  );
}

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow
_rowForAttempt(
  DisabledAnalyzerAdapterRuntimeSkeletonResult source,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode mode,
) {
  return _baseRow(source, mode, '${_attemptRowPrefix}refused').copyWith(
    requestEnvelopeId: source.executionAttempt.requestEnvelopeId,
    responseEnvelopeId: source.executionAttempt.responseEnvelopeId,
    executionAttemptId: source.executionAttempt.executionAttemptId,
    executionAttempted: source.executionAttempt.executionAttempted,
    executionPerformed: source.executionAttempt.executionPerformed,
    executionRefusedReason: source.executionAttempt.executionRefusedReason,
    blockedSeamIds: source.executionAttempt.blockedSeamIds,
    deniedFieldIds: source.executionAttempt.deniedFieldIds,
    warningReasons: source.executionAttempt.warningReasons,
    proofLimitReasons: source.executionAttempt.proofLimitReasons,
  );
}

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow
_rowForPolicy(
  DisabledAnalyzerAdapterRuntimeSkeletonResult source,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode mode,
) {
  return _baseRow(source, mode, '${_policyRowPrefix}disabled').copyWith(
    policyId: source.policy.policyId,
    deniedFieldIds: source.policy.deniedFieldIds,
    executionAllowed: source.policy.executionAllowed,
    analyzerWiringAllowed: source.policy.analyzerWiringAllowed,
    engineCallsAllowed: source.policy.engineCallsAllowed,
    schedulerAllowed: source.policy.schedulerAllowed,
    persistenceAllowed: source.policy.persistenceAllowed,
    productOutputAllowed: source.policy.productOutputAllowed,
    productAdapterAllowed: source.policy.productAdapterAllowed,
    savedAnalysisAllowed: source.policy.savedAnalysisAllowed,
    blockedSeamIds: <String>[
      if (source.policy.uiAllowed) 'active:UI',
      if (source.policy.backendAllowed) 'active:backend',
      if (source.policy.cacheAllowed) 'active:cache',
      if (source.policy.databaseAllowed) 'active:database',
    ],
    executionRefusedReason: 'disabledPolicyForbidsExecution',
  );
}

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow
_rowForBlockedSeam(
  DisabledAnalyzerAdapterRuntimeSkeletonResult source,
  DisabledAnalyzerAdapterRuntimeSkeletonBlockedSeam seam,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode mode,
) {
  return _baseRow(
    source,
    mode,
    '$_blockedSeamRowPrefix${_idSuffix(seam.blockedSeamId)}',
  ).copyWith(
    blockedSeamIds: <String>[
      seam.blocked ? seam.blockedSeamId : 'active:${seam.blockedSeamId}',
    ],
    deniedFieldIds: seam.deniedFieldIds,
    executionRefusedReason: seam.blockReason,
  );
}

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow
_rowForDenied(
  DisabledAnalyzerAdapterRuntimeSkeletonResult source,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode mode,
) {
  return _baseRow(
    source,
    mode,
    '${_deniedRowPrefix}fields',
  ).copyWith(executionRefusedReason: 'deniedFieldsRemainInactive');
}

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow _rowForProof(
  DisabledAnalyzerAdapterRuntimeSkeletonResult source,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode mode,
) {
  return _baseRow(source, mode, '${_proofRowPrefix}boundary').copyWith(
    blockedSeamIds: const <String>['AndroidCollector'],
    deniedFieldIds: const <String>[],
    supportAreaIds: const <String>[],
    executionRefusedReason: 'capturedAndroidProofBoundaryOnly',
  );
}

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow
_rowForRecommendation(
  DisabledAnalyzerAdapterRuntimeSkeletonResult source,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode mode,
) {
  return _baseRow(source, mode, '${_recommendationRowPrefix}phase34k').copyWith(
    blockedSeamIds: const <String>[],
    deniedFieldIds: const <String>[],
    supportAreaIds: const <String>[],
    warningReasons: const <String>[
      'controlledRuntimeExecutionPreflightPatchNextStillNoExecution',
    ],
    executionRefusedReason: 'phase34KPreflightPatchRecommendationOnly',
  );
}

int _countRowPrefix(
  Iterable<DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow>
  rows,
  String prefix,
) {
  return rows.where((row) => row.diagnosticRowId.startsWith(prefix)).length;
}

int _countActiveFields(
  Iterable<DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticRow>
  rows,
  Set<String> ids,
) {
  return rows
      .where(
        (row) => _activeDeniedFieldIds(row.deniedFieldIds).any(ids.contains),
      )
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
    (id) => id == 'quietMove' || id == 'quietPreparatoryMove',
  );
}

bool _mentionsPvMultiPv(String reason) {
  final lower = reason.toLowerCase();
  return lower.contains('pv') || lower.contains('multipv');
}

String _idSuffix(String value) {
  return value
      .replaceAll(RegExp('[^a-zA-Z0-9]+'), '-')
      .replaceAll(RegExp('^-+|-+\$'), '')
      .toLowerCase();
}

String _ids(Iterable<String> values) {
  final sorted = _sorted(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

List<String> _sorted(Iterable<String> values) {
  return values.where((value) => value.trim().isNotEmpty).toSet().toList()
    ..sort();
}

const _phase34KRecommendation =
    'implementControlledAnalyzerAdapterRuntimeExecutionPreflightPatch';
const _pvMultiPvBoundaryCaseId = 'pv-multipv-support-boundary-32e';

const _requestRowPrefix = 'disabled-runtime-skeleton-diagnostic-request-';
const _responseRowPrefix = 'disabled-runtime-skeleton-diagnostic-response-';
const _attemptRowPrefix = 'disabled-runtime-skeleton-diagnostic-attempt-';
const _policyRowPrefix = 'disabled-runtime-skeleton-diagnostic-policy-';
const _blockedSeamRowPrefix =
    'disabled-runtime-skeleton-diagnostic-blocked-seam-';
const _deniedRowPrefix = 'disabled-runtime-skeleton-diagnostic-denied-';
const _proofRowPrefix = 'disabled-runtime-skeleton-diagnostic-proof-';
const _recommendationRowPrefix =
    'disabled-runtime-skeleton-diagnostic-recommendation-';

const _allowedModes = <String>{
  'default',
  'all-safe',
  'request',
  'response',
  'attempt',
  'policy',
  'blocked-seams',
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
  'endgame-candidate-spread-pressure-32e',
  'budget-pressure-depth-limited-32e',
  'pv-multipv-support-boundary-32e',
};

const _activeBlockedSeams = <String>{
  'active:analyzerRuntime',
  'active:analyzerWiring',
  'active:engineCall',
  'active:StockfishBridge',
  'active:AndroidCollector',
  'active:schedulerExecution',
  'active:persistenceWrite',
  'active:productAdapter',
  'active:savedAnalysisIntegration',
  'active:UI',
  'active:backend',
  'active:cache',
  'active:database',
};

const _uiBackendCacheDatabaseSeams = <String>{
  'UI',
  'backend',
  'cache',
  'database',
};

const _productFields = <String>{'productLabel', 'productOutput'};
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

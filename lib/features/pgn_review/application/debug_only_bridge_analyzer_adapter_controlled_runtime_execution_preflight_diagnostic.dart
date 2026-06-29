import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton_diagnostic.dart';

const debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticVersion =
    'debug-only-bridge-analyzer-adapter-controlled-runtime-execution-preflight-diagnostic-v1';

enum DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticStatus {
  controlledAnalyzerAdapterRuntimeExecutionPreflightDiagnosticReadyWithWarnings(
    'controlledAnalyzerAdapterRuntimeExecutionPreflightDiagnosticReadyWithWarnings',
  ),
  controlledAnalyzerAdapterRuntimeExecutionPreflightDiagnosticReadyClean(
    'controlledAnalyzerAdapterRuntimeExecutionPreflightDiagnosticReadyClean',
  ),
  blockedByUnsafeRuntimeExecutionPreflight(
    'blockedByUnsafeRuntimeExecutionPreflight',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidRuntimeExecutionPreflightDiagnostic(
    'invalidRuntimeExecutionPreflightDiagnostic',
  );

  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticStatus(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode {
  defaultMode('default'),
  allSafe('all-safe'),
  checks('checks'),
  decision('decision'),
  blockedReasons('blocked-reasons'),
  denied('denied'),
  proof('proof'),
  recommendation('recommendation');

  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticRow {
  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticRow({
    required this.diagnosticRowId,
    required this.preflightId,
    required this.sourcePhase,
    required this.sourceDiagnosticIds,
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
    required this.executionAllowed,
    required this.runtimeExecutionApproved,
    required this.executionPerformed,
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
  final String preflightId;
  final String sourcePhase;
  final List<String> sourceDiagnosticIds;
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
  final bool executionAllowed;
  final bool runtimeExecutionApproved;
  final bool executionPerformed;
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

  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticRow
  copyWith({
    String? diagnosticRowId,
    String? preflightId,
    String? sourcePhase,
    List<String>? sourceDiagnosticIds,
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
    bool? executionAllowed,
    bool? runtimeExecutionApproved,
    bool? executionPerformed,
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
    return DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticRow(
      diagnosticRowId: diagnosticRowId ?? this.diagnosticRowId,
      preflightId: preflightId ?? this.preflightId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      sourceDiagnosticIds: sourceDiagnosticIds ?? this.sourceDiagnosticIds,
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
      executionAllowed: executionAllowed ?? this.executionAllowed,
      runtimeExecutionApproved:
          runtimeExecutionApproved ?? this.runtimeExecutionApproved,
      executionPerformed: executionPerformed ?? this.executionPerformed,
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
      'preflightId': preflightId,
      'sourcePhase': sourcePhase,
      'sourceDiagnosticIds': sourceDiagnosticIds,
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
      'executionAllowed': executionAllowed,
      'runtimeExecutionApproved': runtimeExecutionApproved,
      'executionPerformed': executionPerformed,
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

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticResult {
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticResult({
    required this.status,
    required this.mode,
    required this.sourcePreflightStatus,
    required this.sourceDisabledRuntimeSkeletonDiagnosticStatus,
    required this.sourceDisabledRuntimeSkeletonStatus,
    required this.sourceRuntimePreparationDiagnosticStatus,
    required this.sourceRuntimePreparationStatus,
    required this.rows,
    required this.findings,
    required this.safeForPhase34M,
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
       activeDeniedFieldCount = rows
           .expand((row) => _activeDeniedFieldIds(row.deniedFieldIds))
           .length,
       runtimeExecutionCount = rows
           .where((row) => row.executionAllowed || row.executionPerformed)
           .length,
       runtimeExecutionApprovedCount = rows
           .where((row) => row.runtimeExecutionApproved)
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

  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticStatus
  status;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
  mode;
  final String sourcePreflightStatus;
  final String sourceDisabledRuntimeSkeletonDiagnosticStatus;
  final String sourceDisabledRuntimeSkeletonStatus;
  final String sourceRuntimePreparationDiagnosticStatus;
  final String sourceRuntimePreparationStatus;
  final List<
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticRow
  >
  rows;
  final List<String> findings;
  final bool safeForPhase34M;
  final String nextRecommendation;
  final int totalDiagnosticRows;
  final int checkDiagnosticRowCount;
  final int decisionDiagnosticRowCount;
  final int blockedReasonDiagnosticRowCount;
  final int deniedDiagnosticRowCount;
  final int proofDiagnosticRowCount;
  final int recommendationDiagnosticRowCount;
  final int activeDeniedFieldCount;
  final int runtimeExecutionCount;
  final int runtimeExecutionApprovedCount;
  final int analyzerWiringCount;
  final int executableRuntimeCount;
  final int engineCallCount;
  final int schedulerExecutionCount;
  final int persistenceWriteCount;
  final int productOutputCount;
  final int productAdapterCount;
  final int savedAnalysisIntegrationCount;
  final int phase32EProofClaimCount;
  final int unprovenAndroidProofCount;
  final int ownerProofQueueCount;
  late final int unsafeCount;
  late final int blockerCount;
  late final int criticalCount;

  bool get hasUnsafePolicyViolation =>
      !safeForPhase34M ||
      findings.isNotEmpty ||
      activeDeniedFieldCount > 0 ||
      runtimeExecutionCount > 0 ||
      runtimeExecutionApprovedCount > 0 ||
      analyzerWiringCount > 0 ||
      executableRuntimeCount > 0 ||
      engineCallCount > 0 ||
      schedulerExecutionCount > 0 ||
      persistenceWriteCount > 0 ||
      productOutputCount > 0 ||
      productAdapterCount > 0 ||
      savedAnalysisIntegrationCount > 0 ||
      phase32EProofClaimCount > 0 ||
      unprovenAndroidProofCount > 0 ||
      ownerProofQueueCount > 0;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln(
        '# Controlled Analyzer Adapter Runtime Execution Preflight Diagnostic',
      )
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticVersion',
      )
      ..writeln(
        '- runtime execution preflight diagnostic status: ${status.wire}',
      )
      ..writeln('- runtime execution preflight diagnostic mode: ${mode.wire}')
      ..writeln('- source preflight status: $sourcePreflightStatus')
      ..writeln(
        '- source disabled runtime skeleton diagnostic status: $sourceDisabledRuntimeSkeletonDiagnosticStatus',
      )
      ..writeln(
        '- source disabled runtime skeleton status: $sourceDisabledRuntimeSkeletonStatus',
      )
      ..writeln(
        '- source runtime-preparation diagnostic status: $sourceRuntimePreparationDiagnosticStatus',
      )
      ..writeln('- safe for Phase 34M: $safeForPhase34M')
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
      ..writeln('## Runtime Execution Preflight Diagnostic Rows')
      ..writeln(
        '| Row | Mode | Checks | Decision | Blocked reasons | Execution | Approved | Analyzer wiring | Engine calls | Scheduler | Persistence | Product output | Findings |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in rows) {
      buffer.writeln(
        '| ${row.diagnosticRowId} | ${row.diagnosticMode} | ${_ids(row.checkIds)} | ${row.decisionId} | ${_ids(row.blockedReasonIds)} | ${row.executionAllowed} | ${row.runtimeExecutionApproved} | ${row.analyzerWiringAllowed} | ${row.engineCallsAllowed} | ${row.schedulerAllowed} | ${row.persistenceAllowed} | ${row.productOutputAllowed} | ${_ids(row.findings)} |',
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
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- runtime execution count: $runtimeExecutionCount')
      ..writeln(
        '- runtime execution approved count: $runtimeExecutionApprovedCount',
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
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Recommendation')
      ..writeln('- safe for Phase 34M: $safeForPhase34M')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- findings: ${_ids(findings)}')
      ..writeln();
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent(' ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticVersion,
      'status': status.wire,
      'mode': mode.wire,
      'sourcePreflightStatus': sourcePreflightStatus,
      'sourceDisabledRuntimeSkeletonDiagnosticStatus':
          sourceDisabledRuntimeSkeletonDiagnosticStatus,
      'sourceDisabledRuntimeSkeletonStatus':
          sourceDisabledRuntimeSkeletonStatus,
      'sourceRuntimePreparationDiagnosticStatus':
          sourceRuntimePreparationDiagnosticStatus,
      'sourceRuntimePreparationStatus': sourceRuntimePreparationStatus,
      'safeForPhase34M': safeForPhase34M,
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
        'runtimeExecutionCount': runtimeExecutionCount,
        'runtimeExecutionApprovedCount': runtimeExecutionApprovedCount,
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

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnostic {
  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnostic();

  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticResult
  evaluate({
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
        mode =
        DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
            .defaultMode,
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
    final runtimePreparationDiagnostic =
        runtimePreparationDiagnosticResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic()
            .evaluate(runtimePreparationResult: preparation);
    final skeleton =
        disabledRuntimeSkeletonResult ??
        const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeleton().evaluate(
          runtimePreparationDiagnosticResult: runtimePreparationDiagnostic,
          runtimePreparationResult: preparation,
        );
    final skeletonDiagnostic =
        disabledRuntimeSkeletonDiagnosticResult ??
        const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnostic()
            .evaluate(
              skeletonResult: skeleton,
              runtimePreparationDiagnosticResult: runtimePreparationDiagnostic,
              runtimePreparationResult: preparation,
            );
    final preflight =
        runtimeExecutionPreflightResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflight()
            .evaluate(
              disabledRuntimeSkeletonDiagnosticResult: skeletonDiagnostic,
              disabledRuntimeSkeletonResult: skeleton,
              runtimePreparationDiagnosticResult: runtimePreparationDiagnostic,
              runtimePreparationResult: preparation,
            );
    final rows = _rowsFor(preflight, mode);
    final findings = _sorted(<String>[
      if (preflight.hasUnsafePolicyViolation || !preflight.safeForPhase34L)
        'unsafePhase34KControlledRuntimeExecutionPreflight',
      if (skeletonDiagnostic.hasUnsafePolicyViolation ||
          !skeletonDiagnostic.safeForPhase34K)
        'unsafePhase34JDisabledRuntimeSkeletonDiagnostic',
      ...const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticValidator()
          .validateRows(rows),
    ]);
    final safeForPhase34M = findings.isEmpty;
    return DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticResult(
      status: !safeForPhase34M
          ? DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticStatus
                .blockedByPolicyBoundary
          : rows.any((row) => row.warningReasons.isNotEmpty)
          ? DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticStatus
                .controlledAnalyzerAdapterRuntimeExecutionPreflightDiagnosticReadyWithWarnings
          : DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticStatus
                .controlledAnalyzerAdapterRuntimeExecutionPreflightDiagnosticReadyClean,
      mode: mode,
      sourcePreflightStatus: preflight.status.wire,
      sourceDisabledRuntimeSkeletonDiagnosticStatus:
          skeletonDiagnostic.status.wire,
      sourceDisabledRuntimeSkeletonStatus: skeleton.status.wire,
      sourceRuntimePreparationDiagnosticStatus:
          runtimePreparationDiagnostic.status.wire,
      sourceRuntimePreparationStatus: preparation.status.wire,
      rows: rows,
      findings: findings,
      safeForPhase34M: safeForPhase34M,
      nextRecommendation: safeForPhase34M
          ? _phase34MRecommendation
          : 'blockedByUnsafeRuntimeExecutionPreflightDiagnostic',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticValidator {
  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticValidator();

  List<String> validateResult(
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticResult
    result,
  ) {
    return validateRows(result.rows);
  }

  List<String> validateRows(
    Iterable<
      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticRow
    >
    rows,
  ) {
    return _sorted(rows.expand(validateRow));
  }

  List<String> validateRow(
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticRow
    row,
  ) {
    final activeDenied = _activeDeniedFieldIds(row.deniedFieldIds);
    return _sorted(<String>[
      if (!_knownModes.contains(row.diagnosticMode))
        'unknownRuntimeExecutionPreflightDiagnosticMode',
      if (row.recommendation != _phase34MRecommendation)
        'missingPhase34MDisabledRuntimeExecutionSeamProbeRecommendation',
      if (row.executionAllowed) 'executionAllowedEnabled',
      if (row.runtimeExecutionApproved) 'runtimeExecutionApprovedEnabled',
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
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticRow
>
_rowsFor(
  ControlledAnalyzerAdapterRuntimeExecutionPreflightResult preflight,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
  mode,
) {
  final rows =
      <
        DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticRow
      >[];
  final includeAll =
      mode ==
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
              .defaultMode ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
              .allSafe;
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
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
          diagnosticStatus: check.checkStatus,
        ),
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
              .decision) {
    rows.add(
      _row(
        preflight,
        mode,
        diagnosticRowId: _decisionRowPrefix,
        diagnosticStatus: preflight.decision.decisionStatus,
        warningReasons: preflight.decision.warningReasons,
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
              .blockedReasons) {
    rows.addAll(
      preflight.blockedReasons.map(
        (reason) => _row(
          preflight,
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
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
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
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
              .proof) {
    rows.add(
      _row(
        preflight,
        mode,
        diagnosticRowId: _proofRowPrefix,
        blockedReasonIds: const <String>['blocked-AndroidCollector'],
        diagnosticStatus: 'capturedAndroidProofBoundaryOnly',
      ),
    );
  }
  if (includeAll ||
      mode ==
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
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
        diagnosticStatus: 'phase34MSeamProbePatchRecommendationOnly',
      ),
    );
  }
  return rows;
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticRow
_row(
  ControlledAnalyzerAdapterRuntimeExecutionPreflightResult preflight,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
  mode, {
  required String diagnosticRowId,
  List<String>? checkIds,
  List<String>? blockedReasonIds,
  List<String>? deniedFieldIds,
  List<String>? warningReasons,
  required String diagnosticStatus,
}) {
  return DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticRow(
    diagnosticRowId: diagnosticRowId,
    preflightId: preflight.input.preflightId,
    sourcePhase: preflight.input.sourcePhase,
    sourceDiagnosticIds: preflight.input.sourceDiagnosticIds,
    sourceSkeletonIds: preflight.input.sourceSkeletonIds,
    sourcePreparationIds: preflight.input.sourcePreparationIds,
    sourceCaseIds: preflight.input.sourceCaseIds,
    sourceActionIds: preflight.input.sourceActionIds,
    sourcePatchIds: preflight.input.sourcePatchIds,
    sourceRefinementIds: preflight.input.sourceRefinementIds,
    diagnosticMode: mode.wire,
    checkIds: checkIds ?? preflight.input.checkIds,
    decisionId: preflight.decision.decisionId,
    blockedReasonIds: blockedReasonIds ?? preflight.input.blockedReasonIds,
    deniedFieldIds: deniedFieldIds ?? preflight.input.deniedFieldIds,
    supportAreaIds: preflight.input.supportAreaIds,
    warningReasons: warningReasons ?? preflight.input.warningReasons,
    proofLimitReasons: preflight.input.proofLimitReasons,
    androidProofIds: preflight.input.androidProofIds,
    ownerProofRequired: preflight.input.ownerProofRequired,
    executionAllowed: false,
    runtimeExecutionApproved: false,
    executionPerformed: false,
    analyzerWiringAllowed: false,
    engineCallsAllowed: false,
    schedulerAllowed: false,
    persistenceAllowed: false,
    productOutputAllowed: false,
    productAdapterAllowed: false,
    savedAnalysisAllowed: false,
    diagnosticStatus: diagnosticStatus,
    findings: const <String>[],
    recommendation: _phase34MRecommendation,
  );
}

int _countRowPrefix(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticRow
  >
  rows,
  String prefix,
) {
  return rows.where((row) => row.diagnosticRowId.startsWith(prefix)).length;
}

int _countActiveFields(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticRow
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
    (id) => id == 'quietMove' || id == 'quietPreparatoryMove',
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

const _phase34MRecommendation =
    'implementDisabledAnalyzerAdapterRuntimeExecutionSeamProbePatch';
const _checkRowPrefix = 'runtime-execution-preflight-diagnostic-check';
const _decisionRowPrefix = 'runtime-execution-preflight-diagnostic-decision';
const _blockedReasonRowPrefix =
    'runtime-execution-preflight-diagnostic-blocked-reason';
const _deniedRowPrefix = 'runtime-execution-preflight-diagnostic-denied';
const _proofRowPrefix = 'runtime-execution-preflight-diagnostic-proof';
const _recommendationRowPrefix =
    'runtime-execution-preflight-diagnostic-recommendation';
const _pvMultiPvBoundaryCaseId = 'pv-multipv-support-boundary-32e';

const _knownModes = <String>{
  'default',
  'all-safe',
  'checks',
  'decision',
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
  'endgame-candidate-spread-pressure-32e',
  'budget-pressure-depth-limited-32e',
  'pv-multipv-support-boundary-32e',
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
  'officialAccuracy',
  'accuracy',
  'acpl',
};

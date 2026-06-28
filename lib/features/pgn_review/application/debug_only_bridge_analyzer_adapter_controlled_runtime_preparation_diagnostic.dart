import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation.dart';

const debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticVersion =
    'debug-only-bridge-analyzer-adapter-controlled-runtime-preparation-diagnostic-v1';

enum DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticStatus {
  controlledAnalyzerAdapterRuntimePreparationDiagnosticReadyWithWarnings(
    'controlledAnalyzerAdapterRuntimePreparationDiagnosticReadyWithWarnings',
  ),
  controlledAnalyzerAdapterRuntimePreparationDiagnosticReadyClean(
    'controlledAnalyzerAdapterRuntimePreparationDiagnosticReadyClean',
  ),
  blockedByUnsafeControlledRuntimePreparation(
    'blockedByUnsafeControlledRuntimePreparation',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidControlledRuntimePreparationDiagnostic(
    'invalidControlledRuntimePreparationDiagnostic',
  );

  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticStatus(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode {
  defaultMode('default'),
  allSafe('all-safe'),
  envelopes('envelopes'),
  preconditions('preconditions'),
  policy('policy'),
  blockedSeams('blocked-seams'),
  denied('denied'),
  proof('proof'),
  recommendation('recommendation');

  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow {
  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow({
    required this.diagnosticRowId,
    required this.preparationId,
    required this.sourcePhase,
    required this.sourceDiagnosticIds,
    required this.sourceCaseIds,
    required this.sourceActionIds,
    required this.sourcePatchIds,
    required this.sourceRefinementIds,
    required this.preparationRole,
    required this.diagnosticMode,
    required this.envelopeIds,
    required this.preconditionIds,
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
  final String preparationId;
  final String sourcePhase;
  final List<String> sourceDiagnosticIds;
  final List<String> sourceCaseIds;
  final List<String> sourceActionIds;
  final List<String> sourcePatchIds;
  final List<String> sourceRefinementIds;
  final String preparationRole;
  final String diagnosticMode;
  final List<String> envelopeIds;
  final List<String> preconditionIds;
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

  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow
  copyWith({
    String? diagnosticRowId,
    String? preparationId,
    String? sourcePhase,
    List<String>? sourceDiagnosticIds,
    List<String>? sourceCaseIds,
    List<String>? sourceActionIds,
    List<String>? sourcePatchIds,
    List<String>? sourceRefinementIds,
    String? preparationRole,
    String? diagnosticMode,
    List<String>? envelopeIds,
    List<String>? preconditionIds,
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
    return DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow(
      diagnosticRowId: diagnosticRowId ?? this.diagnosticRowId,
      preparationId: preparationId ?? this.preparationId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      sourceDiagnosticIds: sourceDiagnosticIds ?? this.sourceDiagnosticIds,
      sourceCaseIds: sourceCaseIds ?? this.sourceCaseIds,
      sourceActionIds: sourceActionIds ?? this.sourceActionIds,
      sourcePatchIds: sourcePatchIds ?? this.sourcePatchIds,
      sourceRefinementIds: sourceRefinementIds ?? this.sourceRefinementIds,
      preparationRole: preparationRole ?? this.preparationRole,
      diagnosticMode: diagnosticMode ?? this.diagnosticMode,
      envelopeIds: envelopeIds ?? this.envelopeIds,
      preconditionIds: preconditionIds ?? this.preconditionIds,
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
      'preparationId': preparationId,
      'sourcePhase': sourcePhase,
      'sourceDiagnosticIds': sourceDiagnosticIds,
      'sourceCaseIds': sourceCaseIds,
      'sourceActionIds': sourceActionIds,
      'sourcePatchIds': sourcePatchIds,
      'sourceRefinementIds': sourceRefinementIds,
      'preparationRole': preparationRole,
      'diagnosticMode': diagnosticMode,
      'envelopeIds': envelopeIds,
      'preconditionIds': preconditionIds,
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

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticResult {
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticResult({
    required this.status,
    required this.mode,
    required this.sourcePreparationStatus,
    required this.sourceMetadataRefinementDiagnosticStatus,
    required this.sourceMetadataRefinementStatus,
    required this.rows,
    required this.findings,
    required this.safeForPhase34I,
    required this.nextRecommendation,
  }) : totalDiagnosticRows = rows.length,
       envelopeDiagnosticRowCount = _countRole(rows, _envelopeDiagnosticRole),
       preconditionDiagnosticRowCount = _countRole(
         rows,
         _preconditionDiagnosticRole,
       ),
       policyDiagnosticRowCount = _countRole(rows, _policyDiagnosticRole),
       blockedSeamDiagnosticRowCount = _countRole(
         rows,
         _blockedSeamDiagnosticRole,
       ),
       deniedDiagnosticRowCount = _countRole(rows, _deniedDiagnosticRole),
       proofDiagnosticRowCount = _countRole(rows, _proofDiagnosticRole),
       recommendationDiagnosticRowCount = _countRole(
         rows,
         _recommendationDiagnosticRole,
       ),
       activeDeniedFieldCount = rows
           .expand((row) => _activeDeniedFieldIds(row.deniedFieldIds))
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
       analyzerWiringCount = rows
           .where((row) => row.analyzerWiringAllowed)
           .length,
       runtimeExecutionCount = rows.where((row) => row.executionAllowed).length,
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

  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticStatus
  status;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
  mode;
  final String sourcePreparationStatus;
  final String sourceMetadataRefinementDiagnosticStatus;
  final String sourceMetadataRefinementStatus;
  final List<
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow
  >
  rows;
  final List<String> findings;
  final bool safeForPhase34I;
  final String nextRecommendation;
  final int totalDiagnosticRows;
  final int envelopeDiagnosticRowCount;
  final int preconditionDiagnosticRowCount;
  final int policyDiagnosticRowCount;
  final int blockedSeamDiagnosticRowCount;
  final int deniedDiagnosticRowCount;
  final int proofDiagnosticRowCount;
  final int recommendationDiagnosticRowCount;
  final int activeDeniedFieldCount;
  final int productOutputCount;
  final int productAdapterCount;
  final int savedAnalysisIntegrationCount;
  final int analyzerWiringCount;
  final int runtimeExecutionCount;
  final int executableRuntimeCount;
  final int engineCallCount;
  final int schedulerExecutionCount;
  final int persistenceWriteCount;
  final int uiBackendCacheDatabaseActivationCount;
  final int phase32EProofClaimCount;
  final int unprovenAndroidProofCount;
  final int ownerProofQueueCount;
  late final int unsafeCount;
  late final int blockerCount;
  late final int criticalCount;

  bool get hasUnsafePolicyViolation =>
      !safeForPhase34I ||
      findings.isNotEmpty ||
      activeDeniedFieldCount > 0 ||
      productOutputCount > 0 ||
      productAdapterCount > 0 ||
      savedAnalysisIntegrationCount > 0 ||
      analyzerWiringCount > 0 ||
      runtimeExecutionCount > 0 ||
      executableRuntimeCount > 0 ||
      engineCallCount > 0 ||
      schedulerExecutionCount > 0 ||
      persistenceWriteCount > 0 ||
      uiBackendCacheDatabaseActivationCount > 0 ||
      phase32EProofClaimCount > 0 ||
      unprovenAndroidProofCount > 0 ||
      ownerProofQueueCount > 0;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Controlled Analyzer Adapter Runtime Preparation Diagnostic')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticVersion',
      )
      ..writeln('- runtime preparation diagnostic status: ${status.wire}')
      ..writeln('- runtime preparation diagnostic mode: ${mode.wire}')
      ..writeln('- source preparation status: $sourcePreparationStatus')
      ..writeln(
        '- source metadata refinement diagnostic status: $sourceMetadataRefinementDiagnosticStatus',
      )
      ..writeln('- safe for Phase 34I: $safeForPhase34I')
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
      ..writeln('## Runtime Preparation Diagnostic Rows')
      ..writeln(
        '| Row | Role | Envelopes | Preconditions | Blocked seams | Execution | Analyzer wiring | Engine calls | Scheduler | Persistence | Product output | Findings |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in rows) {
      buffer.writeln(
        '| ${row.diagnosticRowId} | ${row.preparationRole} | ${_ids(row.envelopeIds)} | ${_ids(row.preconditionIds)} | ${_ids(row.blockedSeamIds)} | ${row.executionAllowed} | ${row.analyzerWiringAllowed} | ${row.engineCallsAllowed} | ${row.schedulerAllowed} | ${row.persistenceAllowed} | ${row.productOutputAllowed} | ${_ids(row.findings)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Runtime Preparation Summary')
      ..writeln('- envelope diagnostic rows: $envelopeDiagnosticRowCount')
      ..writeln(
        '- precondition diagnostic rows: $preconditionDiagnosticRowCount',
      )
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
      ..writeln('- safe for Phase 34I: $safeForPhase34I')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- findings: ${_ids(findings)}')
      ..writeln();
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent(' ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticVersion,
      'status': status.wire,
      'runtimePreparationDiagnosticMode': mode.wire,
      'sourcePreparationStatus': sourcePreparationStatus,
      'sourceMetadataRefinementDiagnosticStatus':
          sourceMetadataRefinementDiagnosticStatus,
      'sourceMetadataRefinementStatus': sourceMetadataRefinementStatus,
      'safeForPhase34I': safeForPhase34I,
      'nextRecommendation': nextRecommendation,
      'counts': <String, Object?>{
        'totalDiagnosticRows': totalDiagnosticRows,
        'envelopeDiagnosticRowCount': envelopeDiagnosticRowCount,
        'preconditionDiagnosticRowCount': preconditionDiagnosticRowCount,
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

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic {
  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic();

  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticResult
  evaluate({
    ControlledAnalyzerAdapterRuntimePreparationResult? runtimePreparationResult,
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
        mode =
        DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
            .defaultMode,
  }) {
    final source =
        runtimePreparationResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation()
            .evaluate();
    if (source.hasUnsafePolicyViolation || !source.safeForPhase34H) {
      return DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticResult(
        status:
            DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticStatus
                .blockedByUnsafeControlledRuntimePreparation,
        mode: mode,
        sourcePreparationStatus: source.status.wire,
        sourceMetadataRefinementDiagnosticStatus:
            source.sourceMetadataRefinementDiagnosticStatus,
        sourceMetadataRefinementStatus: source.sourceMetadataRefinementStatus,
        rows:
            const <
              DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow
            >[],
        findings: const <String>['unsafePhase34GControlledRuntimePreparation'],
        safeForPhase34I: false,
        nextRecommendation:
            'blockedByUnsafeControlledRuntimePreparationDiagnostic',
      );
    }

    final rows = _rowsForMode(source, mode);
    final findings =
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticValidator()
            .validateRows(rows, mode: mode);
    final safeForPhase34I = findings.isEmpty;
    return DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticResult(
      status: !safeForPhase34I
          ? DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticStatus
                .blockedByPolicyBoundary
          : rows.any(
              (row) =>
                  row.warningReasons.isNotEmpty ||
                  row.proofLimitReasons.isNotEmpty,
            )
          ? DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticStatus
                .controlledAnalyzerAdapterRuntimePreparationDiagnosticReadyWithWarnings
          : DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticStatus
                .controlledAnalyzerAdapterRuntimePreparationDiagnosticReadyClean,
      mode: mode,
      sourcePreparationStatus: source.status.wire,
      sourceMetadataRefinementDiagnosticStatus:
          source.sourceMetadataRefinementDiagnosticStatus,
      sourceMetadataRefinementStatus: source.sourceMetadataRefinementStatus,
      rows: rows,
      findings: findings,
      safeForPhase34I: safeForPhase34I,
      nextRecommendation: safeForPhase34I
          ? _phase34IRecommendation
          : 'blockedByUnsafeControlledRuntimePreparationDiagnostic',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticValidator {
  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticValidator();

  List<String> validateRows(
    Iterable<
      DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow
    >
    rows, {
    required DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
    mode,
  }) {
    final records = rows.toList();
    final findings = <String>[
      if (!_allowedModes.contains(mode.wire))
        'unknownRuntimePreparationDiagnosticMode',
      if (!records.any((row) => row.recommendation == _phase34IRecommendation))
        'missingPhase34IDisabledRuntimeSkeletonRecommendation',
    ];
    for (final row in records) {
      findings.addAll(validateRow(row));
    }
    return _sorted(findings);
  }

  List<String> validateRow(
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow row,
  ) {
    final activeDenied = _activeDeniedFieldIds(row.deniedFieldIds);
    return _sorted(<String>[
      if (!_allowedModes.contains(row.diagnosticMode))
        'unknownRuntimePreparationDiagnosticMode',
      if (!_allowedRoles.contains(row.preparationRole))
        'unknownRuntimePreparationDiagnosticRole',
      if (row.recommendation != _phase34IRecommendation)
        'missingPhase34IDisabledRuntimeSkeletonRecommendation',
      if (row.executionAllowed) 'executionAllowedEnabled',
      if (row.analyzerWiringAllowed) 'analyzerWiringEnabled',
      if (row.engineCallsAllowed) 'engineCallsEnabled',
      if (row.schedulerAllowed) 'schedulerExecutionEnabled',
      if (row.persistenceAllowed) 'persistenceWriteEnabled',
      if (row.productOutputAllowed) 'productOutputEnabled',
      if (row.productAdapterAllowed) 'productAdapterEnabled',
      if (row.savedAnalysisAllowed) 'savedAnalysisIntegrationEnabled',
      if (row.blockedSeamIds.any(_activeBlockedSeams.contains))
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

List<DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow>
_rowsForMode(
  ControlledAnalyzerAdapterRuntimePreparationResult source,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode mode,
) {
  final allRows =
      <DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow>[
        ...source.envelopes.map(
          (envelope) => _rowForEnvelope(source, envelope, mode),
        ),
        ...source.preconditions.map(
          (precondition) => _rowForPrecondition(source, precondition, mode),
        ),
        _rowForPolicy(source, mode),
        ...source.blockedSeams.map(
          (seam) => _rowForBlockedSeam(source, seam, mode),
        ),
        _rowForDenied(source, mode),
        _rowForProof(source, mode),
        _rowForRecommendation(source, mode),
      ];
  final selected = switch (mode) {
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
        .defaultMode ||
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
        .allSafe => allRows,
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
        .envelopes =>
      allRows.where((row) => row.preparationRole == _envelopeDiagnosticRole),
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
        .preconditions =>
      allRows.where(
        (row) => row.preparationRole == _preconditionDiagnosticRole,
      ),
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
        .policy =>
      allRows.where((row) => row.preparationRole == _policyDiagnosticRole),
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
        .blockedSeams =>
      allRows.where((row) => row.preparationRole == _blockedSeamDiagnosticRole),
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
        .denied =>
      allRows.where((row) => row.preparationRole == _deniedDiagnosticRole),
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
        .proof =>
      allRows.where((row) => row.preparationRole == _proofDiagnosticRole),
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
        .recommendation =>
      allRows.where(
        (row) => row.preparationRole == _recommendationDiagnosticRole,
      ),
  };
  return selected.toList(growable: false);
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow
_baseRow(
  ControlledAnalyzerAdapterRuntimePreparationResult source,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode mode,
  String rowId,
  String role,
) {
  return DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow(
    diagnosticRowId: rowId,
    preparationId: source.input.preparationId,
    sourcePhase: source.input.sourcePhase,
    sourceDiagnosticIds: source.input.sourceDiagnosticIds,
    sourceCaseIds: source.input.sourceCaseIds,
    sourceActionIds: source.input.sourceActionIds,
    sourcePatchIds: source.input.sourcePatchIds,
    sourceRefinementIds: source.input.sourceRefinementIds,
    preparationRole: role,
    diagnosticMode: mode.wire,
    envelopeIds: source.envelopes
        .map((envelope) => envelope.envelopeId)
        .toList(),
    preconditionIds: source.preconditions
        .map((precondition) => precondition.preconditionId)
        .toList(),
    blockedSeamIds: source.blockedSeams
        .map((seam) => seam.blockedSeamId)
        .toList(),
    deniedFieldIds: source.policy.deniedFieldIds,
    supportAreaIds: source.input.supportAreaIds,
    warningReasons: source.input.warningReasons,
    proofLimitReasons: source.input.proofLimitReasons,
    androidProofIds: source.input.androidProofIds,
    ownerProofRequired: source.input.ownerProofRequired,
    executionAllowed: false,
    analyzerWiringAllowed: false,
    engineCallsAllowed: false,
    schedulerAllowed: false,
    persistenceAllowed: false,
    productOutputAllowed: false,
    productAdapterAllowed: false,
    savedAnalysisAllowed: false,
    diagnosticStatus: 'runtimePreparationDiagnosticReady',
    findings: const <String>[],
    recommendation: _phase34IRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow
_rowForEnvelope(
  ControlledAnalyzerAdapterRuntimePreparationResult source,
  ControlledAnalyzerAdapterRuntimePreparationEnvelope envelope,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode mode,
) {
  return _baseRow(
    source,
    mode,
    'runtime-preparation-diagnostic-envelope-${_idSuffix(envelope.envelopeId)}',
    _envelopeDiagnosticRole,
  ).copyWith(
    envelopeIds: <String>[envelope.envelopeId],
    preconditionIds: envelope.preconditionIds,
    blockedSeamIds: envelope.blockedSeamIds,
    deniedFieldIds: envelope.deniedFieldIds,
    executionAllowed: envelope.executionAllowed,
    analyzerWiringAllowed: envelope.analyzerWiringAllowed,
    engineCallsAllowed: envelope.engineCallsAllowed,
    schedulerAllowed: envelope.schedulerAllowed,
    persistenceAllowed: envelope.persistenceAllowed,
    productOutputAllowed: envelope.productOutputAllowed,
    productAdapterAllowed: envelope.productAdapterAllowed,
    savedAnalysisAllowed: envelope.savedAnalysisAllowed,
  );
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow
_rowForPrecondition(
  ControlledAnalyzerAdapterRuntimePreparationResult source,
  ControlledAnalyzerAdapterRuntimePreparationPrecondition precondition,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode mode,
) {
  return _baseRow(
    source,
    mode,
    'runtime-preparation-diagnostic-precondition-${_idSuffix(precondition.preconditionId)}',
    _preconditionDiagnosticRole,
  ).copyWith(
    preconditionIds: <String>[precondition.preconditionId],
    blockedSeamIds: precondition.blockedSeamIds,
    warningReasons: precondition.warningReasons,
    executionAllowed: precondition.executableNow,
  );
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow
_rowForPolicy(
  ControlledAnalyzerAdapterRuntimePreparationResult source,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode mode,
) {
  return _baseRow(
    source,
    mode,
    'runtime-preparation-diagnostic-disabled-policy',
    _policyDiagnosticRole,
  ).copyWith(
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
  );
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow
_rowForBlockedSeam(
  ControlledAnalyzerAdapterRuntimePreparationResult source,
  ControlledAnalyzerAdapterRuntimePreparationBlockedSeam seam,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode mode,
) {
  return _baseRow(
    source,
    mode,
    'runtime-preparation-diagnostic-blocked-seam-${_idSuffix(seam.blockedSeamId)}',
    _blockedSeamDiagnosticRole,
  ).copyWith(
    blockedSeamIds: <String>[
      seam.blocked ? seam.blockedSeamId : 'active:${seam.blockedSeamId}',
    ],
    deniedFieldIds: seam.deniedFieldIds,
  );
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow
_rowForDenied(
  ControlledAnalyzerAdapterRuntimePreparationResult source,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode mode,
) {
  return _baseRow(
    source,
    mode,
    'runtime-preparation-diagnostic-denied-fields',
    _deniedDiagnosticRole,
  );
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow
_rowForProof(
  ControlledAnalyzerAdapterRuntimePreparationResult source,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode mode,
) {
  return _baseRow(
    source,
    mode,
    'runtime-preparation-diagnostic-proof-boundary',
    _proofDiagnosticRole,
  ).copyWith(
    envelopeIds: const <String>[],
    preconditionIds: const <String>[],
    deniedFieldIds: const <String>[],
    supportAreaIds: const <String>[],
    blockedSeamIds: const <String>['AndroidCollector'],
  );
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow
_rowForRecommendation(
  ControlledAnalyzerAdapterRuntimePreparationResult source,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode mode,
) {
  return _baseRow(
    source,
    mode,
    'runtime-preparation-diagnostic-phase34i-recommendation',
    _recommendationDiagnosticRole,
  ).copyWith(
    envelopeIds: const <String>[],
    preconditionIds: const <String>[],
    deniedFieldIds: const <String>[],
    supportAreaIds: const <String>[],
    blockedSeamIds: const <String>[],
    warningReasons: const <String>['disabledRuntimeSkeletonNextNoExecution'],
  );
}

int _countRole(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow
  >
  rows,
  String role,
) {
  return rows.where((row) => row.preparationRole == role).length;
}

int _countActiveFields(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow
  >
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

const _phase34IRecommendation =
    'implementDisabledAnalyzerAdapterRuntimeSkeleton';
const _pvMultiPvBoundaryCaseId = 'pv-multipv-support-boundary-32e';

const _envelopeDiagnosticRole = 'runtimePreparationEnvelopeDiagnostic';
const _preconditionDiagnosticRole = 'runtimePreparationPreconditionDiagnostic';
const _policyDiagnosticRole = 'disabledExecutionPolicyDiagnostic';
const _blockedSeamDiagnosticRole = 'blockedSeamDiagnostic';
const _deniedDiagnosticRole = 'deniedFieldDiagnostic';
const _proofDiagnosticRole = 'proofBoundaryDiagnostic';
const _recommendationDiagnosticRole = 'phase34IRecommendationDiagnostic';

const _allowedRoles = <String>{
  _envelopeDiagnosticRole,
  _preconditionDiagnosticRole,
  _policyDiagnosticRole,
  _blockedSeamDiagnosticRole,
  _deniedDiagnosticRole,
  _proofDiagnosticRole,
  _recommendationDiagnosticRole,
};

const _allowedModes = <String>{
  'default',
  'all-safe',
  'envelopes',
  'preconditions',
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

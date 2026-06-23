import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_patch.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticVersion =
    'debug-only-bridge-analyzer-adapter-prototype-metadata-refinement-diagnostic-v1';

enum DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticStatus {
  analyzerAdapterPrototypeMetadataRefinementDiagnosticReadyWithWarnings(
    'analyzerAdapterPrototypeMetadataRefinementDiagnosticReadyWithWarnings',
  ),
  analyzerAdapterPrototypeMetadataRefinementDiagnosticReadyClean(
    'analyzerAdapterPrototypeMetadataRefinementDiagnosticReadyClean',
  ),
  blockedByUnsafeMetadataRefinementPatch(
    'blockedByUnsafeMetadataRefinementPatch',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidMetadataRefinementDiagnostic('invalidMetadataRefinementDiagnostic');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticStatus(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode {
  defaultMode('default'),
  allSafe('all-safe'),
  support('support'),
  warning('warning'),
  proof('proof'),
  guards('guards'),
  denied('denied'),
  blocked('blocked'),
  surfaces('surfaces'),
  recommendation('recommendation');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow({
    required this.diagnosticRowId,
    required this.refinementId,
    required this.sourceDiagnosticRowId,
    required this.sourcePatchId,
    required this.sourceActionId,
    required this.sourceCaseId,
    required this.sourcePhase,
    required this.sourceDiagnosticRole,
    required this.sourcePatchGroup,
    required this.refinementGroup,
    required this.refinementType,
    required this.targetSurface,
    required this.refinedDisplayLabel,
    required this.refinedReasonSummary,
    required this.sourceChainSummary,
    required this.supportAreaIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.blockedBoundaryIds,
    required this.deniedFieldIds,
    required this.androidProofIds,
    required this.ownerProofRequired,
    required this.appliedAsMetadataOnly,
    required this.diagnosticStatus,
    required this.findings,
    required this.recommendation,
  });

  final String diagnosticRowId;
  final String refinementId;
  final String sourceDiagnosticRowId;
  final String sourcePatchId;
  final String sourceActionId;
  final String sourceCaseId;
  final String sourcePhase;
  final String sourceDiagnosticRole;
  final String sourcePatchGroup;
  final String refinementGroup;
  final String refinementType;
  final String targetSurface;
  final String refinedDisplayLabel;
  final String refinedReasonSummary;
  final String sourceChainSummary;
  final List<String> supportAreaIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> blockedBoundaryIds;
  final List<String> deniedFieldIds;
  final List<String> androidProofIds;
  final bool ownerProofRequired;
  final bool appliedAsMetadataOnly;
  final String diagnosticStatus;
  final List<String> findings;
  final String recommendation;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'diagnosticRowId': diagnosticRowId,
      'refinementId': refinementId,
      'sourceDiagnosticRowId': sourceDiagnosticRowId,
      'sourcePatchId': sourcePatchId,
      'sourceActionId': sourceActionId,
      'sourceCaseId': sourceCaseId,
      'sourcePhase': sourcePhase,
      'sourceDiagnosticRole': sourceDiagnosticRole,
      'sourcePatchGroup': sourcePatchGroup,
      'refinementGroup': refinementGroup,
      'refinementType': refinementType,
      'targetSurface': targetSurface,
      'refinedDisplayLabel': refinedDisplayLabel,
      'refinedReasonSummary': refinedReasonSummary,
      'sourceChainSummary': sourceChainSummary,
      'supportAreaIds': supportAreaIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'blockedBoundaryIds': blockedBoundaryIds,
      'deniedFieldIds': deniedFieldIds,
      'androidProofIds': androidProofIds,
      'ownerProofRequired': ownerProofRequired,
      'appliedAsMetadataOnly': appliedAsMetadataOnly,
      'diagnosticStatus': diagnosticStatus,
      'findings': findings,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticResult {
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticResult({
    required this.status,
    required this.mode,
    required this.sourceMetadataRefinementStatus,
    required this.sourceDiagnosticStatus,
    required this.sourcePatchSetStatus,
    required this.rows,
    required this.findings,
    required this.allowedTargetSurfaces,
    required this.forbiddenTargetSurfaces,
    required this.safeForPhase34G,
    required this.nextRecommendation,
  }) : totalDiagnosticRows = rows.length,
       supportDiagnosticRowCount = _countGroup(
         rows,
         _supportTraceabilityMetadataRefinements,
       ),
       warningDiagnosticRowCount = _countGroup(
         rows,
         _warningReasonMetadataRefinements,
       ),
       proofDiagnosticRowCount = _countGroup(
         rows,
         _proofBoundaryMetadataRefinements,
       ),
       guardDiagnosticRowCount = _countGroup(
         rows,
         _excludedGuardMetadataRefinements,
       ),
       deniedDiagnosticRowCount = _countGroup(
         rows,
         _deniedFieldMetadataRefinements,
       ),
       blockedDiagnosticRowCount = _countGroup(
         rows,
         _blockedIntegrationMetadataRefinements,
       ),
       surfaceDiagnosticRowCount = _countGroup(
         rows,
         _targetSurfaceMetadataRefinements,
       ),
       summaryDiagnosticRowCount = _countGroup(
         rows,
         _diagnosticSummaryMetadataRefinements,
       ),
       recommendationDiagnosticRowCount = _countGroup(
         rows,
         _phase34FDiagnosticRequirementRefinements,
       ),
       targetSurfaceCounts = _targetSurfaceCounts(rows),
       activeDeniedFieldCount = rows.expand(_activeDeniedFieldIds).length,
       productOutputCount =
           _countForbiddenSurface(rows, const {'productReviewOutput'}) +
           _countActiveFields(rows, _productFields),
       labelLeakCount = _countActiveFields(rows, _labelFields),
       finalLabelLeakCount = _countActiveFields(rows, _finalLabelFields),
       scoreLeakCount = _countActiveFields(rows, _scoreFields),
       metricLeakCount = _countActiveFields(rows, _metricFields),
       cpLossLeakCount = _countActiveFields(rows, const {'cpLoss'}),
       winProbabilityLeakCount = _countActiveFields(rows, const {
         'winProbability',
       }),
       moveRankingLeakCount = _countActiveFields(rows, const {'moveRanking'}),
       thresholdLeakCount = _countActiveFields(rows, const {'thresholds'}),
       uiTargetCount =
           _countForbiddenSurface(rows, const {'UI'}) +
           _countEnabledBoundary(rows, const {'uiTarget'}),
       backendTargetCount =
           _countForbiddenSurface(rows, const {'backend'}) +
           _countEnabledBoundary(rows, const {'backendTarget'}),
       persistenceWriteCount =
           _countForbiddenSurface(rows, const {
             'persistence',
             'cache',
             'database',
           }) +
           _countEnabledBoundary(rows, const {'persistenceWrite'}),
       engineCallCount =
           _countForbiddenSurface(rows, const {
             'engineCall',
             'StockfishBridge',
           }) +
           _countEnabledBoundary(rows, const {
             'directEngineCall',
             'engineResults',
           }),
       schedulerExecutionCount =
           _countForbiddenSurface(rows, const {'schedulerExecution'}) +
           _countEnabledBoundary(rows, const {'schedulerExecution'}),
       analyzerWiringCount =
           _countForbiddenSurface(rows, const {'analyzerWiring'}) +
           _countEnabledBoundary(rows, const {'analyzerWiring'}),
       runtimeImplementationCount = _countEnabledBoundary(rows, const {
         'runtimeImplementation',
       }),
       executablePrototypeCount = _countEnabledBoundary(rows, const {
         'executablePrototypeBehavior',
       }),
       productAdapterBehaviorCount =
           _countForbiddenSurface(rows, const {'productAdapter'}) +
           _countEnabledBoundary(rows, const {'productAdapterBehavior'}),
       savedAnalysisIntegrationCount =
           _countForbiddenSurface(rows, const {'savedAnalysis'}) +
           _countEnabledBoundary(rows, const {'savedAnalysisIntegration'}),
       stockfishCommandLeakCount = _countActiveFields(rows, const {
         'stockfishCommand',
       }),
       rawUciLeakCount = _countActiveFields(rows, const {'rawUci'}),
       pvDumpLeakCount = _countActiveFields(rows, const {'pvDump'}),
       androidCollectorRequirementCount =
           _countForbiddenSurface(rows, const {'AndroidCollector'}) +
           _countActiveFields(rows, const {
             'androidCollectorRequirement',
             'androidCollectorExecution',
           }),
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
           .length,
       blockerCount = findings
           .where((finding) => !finding.startsWith('reportTextLeak:'))
           .length,
       criticalCount = findings
           .where((finding) => finding.startsWith('reportTextLeak:'))
           .length;

  final DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticStatus
  status;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
  mode;
  final String sourceMetadataRefinementStatus;
  final String sourceDiagnosticStatus;
  final String sourcePatchSetStatus;
  final List<
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow
  >
  rows;
  final List<String> findings;
  final List<String> allowedTargetSurfaces;
  final List<String> forbiddenTargetSurfaces;
  final bool safeForPhase34G;
  final String nextRecommendation;
  final int totalDiagnosticRows;
  final int supportDiagnosticRowCount;
  final int warningDiagnosticRowCount;
  final int proofDiagnosticRowCount;
  final int guardDiagnosticRowCount;
  final int deniedDiagnosticRowCount;
  final int blockedDiagnosticRowCount;
  final int surfaceDiagnosticRowCount;
  final int summaryDiagnosticRowCount;
  final int recommendationDiagnosticRowCount;
  final Map<String, int> targetSurfaceCounts;
  final int activeDeniedFieldCount;
  final int productOutputCount;
  final int labelLeakCount;
  final int finalLabelLeakCount;
  final int scoreLeakCount;
  final int metricLeakCount;
  final int cpLossLeakCount;
  final int winProbabilityLeakCount;
  final int moveRankingLeakCount;
  final int thresholdLeakCount;
  final int uiTargetCount;
  final int backendTargetCount;
  final int persistenceWriteCount;
  final int engineCallCount;
  final int schedulerExecutionCount;
  final int analyzerWiringCount;
  final int runtimeImplementationCount;
  final int executablePrototypeCount;
  final int productAdapterBehaviorCount;
  final int savedAnalysisIntegrationCount;
  final int stockfishCommandLeakCount;
  final int rawUciLeakCount;
  final int pvDumpLeakCount;
  final int androidCollectorRequirementCount;
  final int phase32EProofClaimCount;
  final int unprovenAndroidProofCount;
  final int ownerProofQueueCount;
  final int blockerCount;
  final int criticalCount;

  int get unsafeCount => safeForPhase34G ? 0 : 1;

  bool get hasUnsafePolicyViolation =>
      !safeForPhase34G ||
      nextRecommendation != _phase34GRecommendation ||
      unsafeCount > 0 ||
      blockerCount > 0 ||
      criticalCount > 0 ||
      activeDeniedFieldCount > 0 ||
      productOutputCount > 0 ||
      labelLeakCount > 0 ||
      finalLabelLeakCount > 0 ||
      scoreLeakCount > 0 ||
      metricLeakCount > 0 ||
      cpLossLeakCount > 0 ||
      winProbabilityLeakCount > 0 ||
      moveRankingLeakCount > 0 ||
      thresholdLeakCount > 0 ||
      uiTargetCount > 0 ||
      backendTargetCount > 0 ||
      persistenceWriteCount > 0 ||
      engineCallCount > 0 ||
      schedulerExecutionCount > 0 ||
      analyzerWiringCount > 0 ||
      runtimeImplementationCount > 0 ||
      executablePrototypeCount > 0 ||
      productAdapterBehaviorCount > 0 ||
      savedAnalysisIntegrationCount > 0 ||
      stockfishCommandLeakCount > 0 ||
      rawUciLeakCount > 0 ||
      pvDumpLeakCount > 0 ||
      androidCollectorRequirementCount > 0 ||
      phase32EProofClaimCount > 0 ||
      unprovenAndroidProofCount > 0 ||
      ownerProofQueueCount > 0;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Analyzer Adapter Prototype Metadata Refinement Diagnostic')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticVersion',
      )
      ..writeln('- metadata refinement diagnostic status: ${status.wire}')
      ..writeln('- refinement diagnostic mode: ${mode.wire}')
      ..writeln(
        '- source metadata refinement status: $sourceMetadataRefinementStatus',
      )
      ..writeln('- source diagnostic status: $sourceDiagnosticStatus')
      ..writeln('- source patch set status: $sourcePatchSetStatus')
      ..writeln('- safe for Phase 34G: $safeForPhase34G')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln()
      ..writeln('## Source Phase Chain')
      ..writeln('- Phase 34B action plan: consumed through Phase 34C')
      ..writeln('- Phase 34C patch set: $sourcePatchSetStatus')
      ..writeln('- Phase 34D patch-set diagnostic: $sourceDiagnosticStatus')
      ..writeln(
        '- Phase 34E metadata refinement: $sourceMetadataRefinementStatus',
      )
      ..writeln()
      ..writeln('## Diagnostic Mode Summary')
      ..writeln('| Mode | Rows |')
      ..writeln('| --- | --- |')
      ..writeln('| ${mode.wire} | $totalDiagnosticRows |')
      ..writeln()
      ..writeln('## Refinement Diagnostic Rows')
      ..writeln(
        '| Row | Refinement | Source chain | Group | Type | Target surface | Label | Metadata-only | Findings |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- | --- |');
    for (final row in rows) {
      buffer.writeln(
        '| ${row.diagnosticRowId} | ${row.refinementId} | ${row.sourceChainSummary} | ${row.refinementGroup} | ${row.refinementType} | ${row.targetSurface} | ${row.refinedDisplayLabel} | ${row.appliedAsMetadataOnly} | ${_ids(row.findings)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Refinement Group Summary')
      ..writeln('- support refinements: $supportDiagnosticRowCount')
      ..writeln('- warning refinements: $warningDiagnosticRowCount')
      ..writeln('- proof-boundary refinements: $proofDiagnosticRowCount')
      ..writeln('- excluded guard refinements: $guardDiagnosticRowCount')
      ..writeln('- denied-field refinements: $deniedDiagnosticRowCount')
      ..writeln('- blocked integration refinements: $blockedDiagnosticRowCount')
      ..writeln('- target surface refinements: $surfaceDiagnosticRowCount')
      ..writeln('- diagnostic summary refinements: $summaryDiagnosticRowCount')
      ..writeln(
        '- recommendation refinements: $recommendationDiagnosticRowCount',
      )
      ..writeln()
      ..writeln('## Target Surface Summary')
      ..writeln('| Target surface | Count |')
      ..writeln('| --- | --- |');
    for (final entry in targetSurfaceCounts.entries) {
      buffer.writeln('| ${entry.key} | ${entry.value} |');
    }
    buffer
      ..writeln()
      ..writeln('## Safety Summary')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- product output count: $productOutputCount')
      ..writeln('- analyzer wiring count: $analyzerWiringCount')
      ..writeln('- runtime implementation count: $runtimeImplementationCount')
      ..writeln('- executable prototype count: $executablePrototypeCount')
      ..writeln('- engine call count: $engineCallCount')
      ..writeln('- scheduler execution count: $schedulerExecutionCount')
      ..writeln('- persistence write count: $persistenceWriteCount')
      ..writeln('- raw UCI leak count: $rawUciLeakCount')
      ..writeln('- PV dump leak count: $pvDumpLeakCount')
      ..writeln('- Stockfish command leak count: $stockfishCommandLeakCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Recommendation')
      ..writeln('- safe for Phase 34G: $safeForPhase34G')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- findings: ${_ids(findings)}')
      ..writeln();
    return buffer.toString();
  }

  String renderJson() {
    return const JsonEncoder.withIndent(' ').convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticVersion,
      'status': status.wire,
      'refinementDiagnosticMode': mode.wire,
      'sourceMetadataRefinementStatus': sourceMetadataRefinementStatus,
      'sourceDiagnosticStatus': sourceDiagnosticStatus,
      'sourcePatchSetStatus': sourcePatchSetStatus,
      'safeForPhase34G': safeForPhase34G,
      'safeForNextStep': safeForPhase34G,
      'nextRecommendation': nextRecommendation,
      'counts': <String, Object?>{
        'totalDiagnosticRows': totalDiagnosticRows,
        'supportDiagnosticRowCount': supportDiagnosticRowCount,
        'warningDiagnosticRowCount': warningDiagnosticRowCount,
        'proofDiagnosticRowCount': proofDiagnosticRowCount,
        'guardDiagnosticRowCount': guardDiagnosticRowCount,
        'deniedDiagnosticRowCount': deniedDiagnosticRowCount,
        'blockedDiagnosticRowCount': blockedDiagnosticRowCount,
        'surfaceDiagnosticRowCount': surfaceDiagnosticRowCount,
        'summaryDiagnosticRowCount': summaryDiagnosticRowCount,
        'recommendationDiagnosticRowCount': recommendationDiagnosticRowCount,
        'unsafeCount': unsafeCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'activeDeniedFieldCount': activeDeniedFieldCount,
        'productOutputCount': productOutputCount,
        'analyzerWiringCount': analyzerWiringCount,
        'runtimeImplementationCount': runtimeImplementationCount,
        'executablePrototypeCount': executablePrototypeCount,
        'engineCallCount': engineCallCount,
        'schedulerExecutionCount': schedulerExecutionCount,
        'persistenceWriteCount': persistenceWriteCount,
        'stockfishCommandLeakCount': stockfishCommandLeakCount,
        'rawUciLeakCount': rawUciLeakCount,
        'pvDumpLeakCount': pvDumpLeakCount,
        'ownerProofQueueCount': ownerProofQueueCount,
      },
      'targetSurfaceCounts': targetSurfaceCounts,
      'allowedTargetSurfaces': allowedTargetSurfaces,
      'forbiddenTargetSurfaces': forbiddenTargetSurfaces,
      'findings': findings,
      'rows': rows.map((row) => row.toJson()).toList(),
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnostic {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnostic();

  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticResult
  evaluate({
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchResult?
    refinementPatchResult,
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
        mode =
        DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
            .defaultMode,
  }) {
    final source =
        refinementPatchResult ??
        const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatch()
            .evaluate();
    if (source.hasUnsafePolicyViolation || !source.safeForPhase34F) {
      return DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticResult(
        status:
            DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticStatus
                .blockedByUnsafeMetadataRefinementPatch,
        mode: mode,
        sourceMetadataRefinementStatus: source.status.wire,
        sourceDiagnosticStatus: source.sourceDiagnosticStatus,
        sourcePatchSetStatus: source.sourcePatchSetStatus,
        rows:
            const <
              DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow
            >[],
        findings: const <String>['unsafePhase34EMetadataRefinementPatch'],
        allowedTargetSurfaces: source.allowedTargetSurfaces,
        forbiddenTargetSurfaces: source.forbiddenTargetSurfaces,
        safeForPhase34G: false,
        nextRecommendation:
            'blockedByUnsafeAnalyzerAdapterPrototypeMetadataRefinementDiagnostic',
      );
    }

    final rows = _refinementsForMode(
      source.refinements,
      mode,
    ).map(_rowForRefinement).toList(growable: false);
    final findings =
        const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticValidator()
            .validateRows(rows, mode: mode);
    final safeForPhase34G = findings.isEmpty;
    final status = !safeForPhase34G
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticStatus
              .blockedByPolicyBoundary
        : rows.any(
            (row) =>
                row.warningReasons.isNotEmpty ||
                row.proofLimitReasons.isNotEmpty,
          )
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticStatus
              .analyzerAdapterPrototypeMetadataRefinementDiagnosticReadyWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticStatus
              .analyzerAdapterPrototypeMetadataRefinementDiagnosticReadyClean;
    return DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticResult(
      status: status,
      mode: mode,
      sourceMetadataRefinementStatus: source.status.wire,
      sourceDiagnosticStatus: source.sourceDiagnosticStatus,
      sourcePatchSetStatus: source.sourcePatchSetStatus,
      rows: rows,
      findings: findings,
      allowedTargetSurfaces: source.allowedTargetSurfaces,
      forbiddenTargetSurfaces: source.forbiddenTargetSurfaces,
      safeForPhase34G: safeForPhase34G,
      nextRecommendation: safeForPhase34G
          ? _phase34GRecommendation
          : 'blockedByUnsafeAnalyzerAdapterPrototypeMetadataRefinementDiagnostic',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticValidator {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticValidator();

  List<String> validateRows(
    Iterable<
      DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow
    >
    rows, {
    required DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
    mode,
  }) {
    final records = rows.toList();
    final findings = <String>[
      if (!_allowedModes.contains(mode.wire)) 'unknownRefinementDiagnosticMode',
      if (!records.any((row) => row.recommendation == _phase34GRecommendation))
        'missingPhase34GControlledRuntimePreparationRecommendation',
    ];
    for (final record in records) {
      findings.addAll(validateRow(record));
    }
    return _sorted(findings);
  }

  List<String> validateRow(
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow row,
  ) {
    final activeDenied = _activeDeniedFieldIds(row).toSet();
    return _sorted(<String>[
      if (!_allowedRefinementGroups.contains(row.refinementGroup))
        'unknownRefinementGroup',
      if (!_allowedRefinementTypes.contains(row.refinementType))
        'unknownRefinementType',
      if (!_allowedTargetSurfaces.contains(row.targetSurface))
        'unknownTargetSurface',
      if (_forbiddenTargetSurfaces.contains(row.targetSurface))
        'forbiddenTargetSurface',
      if (!row.appliedAsMetadataOnly) 'nonMetadataDiagnosticRow',
      if (_isQuietRefinement(row) &&
          row.refinementGroup != _excludedGuardMetadataRefinements)
        'quietPreparatoryPromotion',
      if (row.sourceCaseId == _pvMultiPvBoundaryCaseId &&
          row.refinementGroup != _proofBoundaryMetadataRefinements)
        'pvMultiPvPromotion',
      if (row.androidProofIds.any(_phase32ECaseIds.contains))
        'phase32ECapturedProofClaim',
      if (row.androidProofIds.any(
        (id) => !_capturedAndroidProofIds.contains(id),
      ))
        'unprovenAndroidProofClaim',
      if (row.ownerProofRequired &&
          !row.proofLimitReasons.any((reason) => reason.contains('pvMultiPv')))
        'ownerProofWithoutPvMultiPvReason',
      if (_enablesBoundary(row, const {'runtimeImplementation'}))
        'runtimeImplementationEnabled',
      if (_enablesBoundary(row, const {'analyzerWiring'}))
        'analyzerWiringEnabled',
      if (_enablesBoundary(row, const {'executablePrototypeBehavior'}))
        'executablePrototypeEnabled',
      if (_enablesBoundary(row, const {'directEngineCall', 'engineResults'}))
        'engineCallEnabled',
      if (_enablesBoundary(row, const {'schedulerExecution'}))
        'schedulerExecutionEnabled',
      if (_enablesBoundary(row, const {'productAdapterBehavior'}))
        'productAdapterEnabled',
      if (_enablesBoundary(row, const {'savedAnalysisIntegration'}))
        'savedAnalysisIntegrationEnabled',
      if (_enablesBoundary(row, const {
        'uiTarget',
        'backendTarget',
        'persistenceWrite',
      }))
        'uiBackendPersistenceEnabled',
      if (activeDenied.isNotEmpty) 'activeDeniedFields',
      if (activeDenied.any(_productFields.contains)) 'productLabelsEnabled',
      if (activeDenied.any(_finalLabelFields.contains)) 'finalLabelsEnabled',
      if (activeDenied.any(_labelFields.contains)) 'classifierLabelsEnabled',
      if (activeDenied.any(_scoreFields.contains)) 'scoresEnabled',
      if (activeDenied.any(_metricFields.contains)) 'officialMetricsEnabled',
      if (activeDenied.contains('cpLoss')) 'cpLossEnabled',
      if (activeDenied.contains('winProbability')) 'winProbabilityEnabled',
      if (activeDenied.contains('moveRanking')) 'moveRankingEnabled',
      if (activeDenied.contains('thresholds')) 'thresholdsEnabled',
      if (activeDenied.contains('stockfishCommand')) 'stockfishCommandEnabled',
      if (activeDenied.contains('rawUci')) 'rawUciEnabled',
      if (activeDenied.contains('pvDump')) 'pvDumpEnabled',
      if (activeDenied.any(
        const {
          'androidCollectorRequirement',
          'androidCollectorExecution',
        }.contains,
      ))
        'androidCollectorRequirementEnabled',
      if (activeDenied.contains('readinessSummaryChain'))
        'readinessSummaryChainEnabled',
      if (activeDenied.contains('readinessGate')) 'readinessGateEnabled',
    ]);
  }

  List<String> validateReportText(String reportText) {
    final lower = reportText.toLowerCase();
    return _sorted(<String>[
      for (final token in _rawReportLeakTokens)
        if (lower.contains(token.toLowerCase())) 'reportTextLeak:$token',
    ]);
  }
}

DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow
_rowForRefinement(
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord record,
) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow(
    diagnosticRowId: 'diagnostic-${record.refinementId}',
    refinementId: record.refinementId,
    sourceDiagnosticRowId: record.sourceDiagnosticRowId,
    sourcePatchId: record.sourcePatchId,
    sourceActionId: record.sourceActionId,
    sourceCaseId: record.sourceCaseId,
    sourcePhase: record.sourcePhase,
    sourceDiagnosticRole: record.sourceDiagnosticRole,
    sourcePatchGroup: record.sourcePatchGroup,
    refinementGroup: record.refinementGroup,
    refinementType: record.refinementType,
    targetSurface: record.targetSurface,
    refinedDisplayLabel: record.refinedDisplayLabel,
    refinedReasonSummary: record.refinedReasonSummary,
    sourceChainSummary: record.sourceChainSummary,
    supportAreaIds: record.supportAreaIds,
    warningReasons: record.warningReasons,
    proofLimitReasons: record.proofLimitReasons,
    blockedBoundaryIds: record.blockedBoundaryIds,
    deniedFieldIds: record.deniedFieldIds,
    androidProofIds: record.androidProofIds,
    ownerProofRequired: false,
    appliedAsMetadataOnly: record.appliedAsMetadataOnly,
    diagnosticStatus: 'metadataRefinementDiagnosticReady',
    findings: const <String>[],
    recommendation: _phase34GRecommendation,
  );
}

Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord>
_refinementsForMode(
  List<DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord>
  refinements,
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode mode,
) {
  return switch (mode) {
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
        .defaultMode ||
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
        .allSafe => refinements,
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
        .support =>
      refinements.where(
        (record) =>
            record.refinementGroup == _supportTraceabilityMetadataRefinements,
      ),
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
        .warning =>
      refinements.where(
        (record) => record.refinementGroup == _warningReasonMetadataRefinements,
      ),
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
        .proof =>
      refinements.where(
        (record) => record.refinementGroup == _proofBoundaryMetadataRefinements,
      ),
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
        .guards =>
      refinements.where(
        (record) => record.refinementGroup == _excludedGuardMetadataRefinements,
      ),
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
        .denied =>
      refinements.where(
        (record) => record.refinementGroup == _deniedFieldMetadataRefinements,
      ),
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
        .blocked =>
      refinements.where(
        (record) =>
            record.refinementGroup == _blockedIntegrationMetadataRefinements,
      ),
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
        .surfaces =>
      refinements.where(
        (record) => record.refinementGroup == _targetSurfaceMetadataRefinements,
      ),
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
        .recommendation =>
      refinements.where(
        (record) =>
            record.refinementGroup == _phase34FDiagnosticRequirementRefinements,
      ),
  };
}

bool _isQuietRefinement(
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow row,
) {
  return row.supportAreaIds.contains('quietMove') ||
      row.supportAreaIds.contains('quietPreparatoryMove') ||
      row.sourceCaseId.contains('quiet-preparatory');
}

bool _enablesBoundary(
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow row,
  Set<String> boundaryIds,
) {
  return !row.appliedAsMetadataOnly &&
      row.blockedBoundaryIds.any(boundaryIds.contains);
}

Iterable<String> _activeDeniedFieldIds(
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow row,
) {
  if (row.appliedAsMetadataOnly &&
      !_forbiddenTargetSurfaces.contains(row.targetSurface)) {
    return const <String>[];
  }
  return row.deniedFieldIds;
}

int _countActiveFields(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow
  >
  rows,
  Set<String> fields,
) {
  var count = 0;
  for (final row in rows) {
    count += _activeDeniedFieldIds(row).where(fields.contains).length;
  }
  return count;
}

int _countEnabledBoundary(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow
  >
  rows,
  Set<String> fields,
) {
  return rows
      .where(
        (row) =>
            !row.appliedAsMetadataOnly &&
            row.blockedBoundaryIds.any(fields.contains),
      )
      .length;
}

int _countForbiddenSurface(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow
  >
  rows,
  Set<String> surfaces,
) {
  return rows.where((row) => surfaces.contains(row.targetSurface)).length;
}

int _countGroup(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow
  >
  rows,
  String group,
) {
  return rows.where((row) => row.refinementGroup == group).length;
}

Map<String, int> _targetSurfaceCounts(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow
  >
  rows,
) {
  final counts = <String, int>{};
  for (final row in rows) {
    counts[row.targetSurface] = (counts[row.targetSurface] ?? 0) + 1;
  }
  return Map<String, int>.fromEntries(
    counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}

String _ids(Iterable<String> values) {
  final sorted = _sorted(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

List<String> _sorted(Iterable<String> values) {
  return values.where((value) => value.trim().isNotEmpty).toSet().toList()
    ..sort();
}

const _phase34GRecommendation =
    'implementControlledAnalyzerAdapterRuntimePreparationPatch';

const _supportTraceabilityMetadataRefinements =
    'supportTraceabilityMetadataRefinements';
const _warningReasonMetadataRefinements = 'warningReasonMetadataRefinements';
const _proofBoundaryMetadataRefinements = 'proofBoundaryMetadataRefinements';
const _excludedGuardMetadataRefinements = 'excludedGuardMetadataRefinements';
const _deniedFieldMetadataRefinements = 'deniedFieldMetadataRefinements';
const _blockedIntegrationMetadataRefinements =
    'blockedIntegrationMetadataRefinements';
const _targetSurfaceMetadataRefinements = 'targetSurfaceMetadataRefinements';
const _diagnosticSummaryMetadataRefinements =
    'diagnosticSummaryMetadataRefinements';
const _phase34FDiagnosticRequirementRefinements =
    'phase34FDiagnosticRequirementRefinements';

const _allowedModes = <String>{
  'default',
  'all-safe',
  'support',
  'warning',
  'proof',
  'guards',
  'denied',
  'blocked',
  'surfaces',
  'recommendation',
};

const _allowedRefinementGroups = <String>{
  _supportTraceabilityMetadataRefinements,
  _warningReasonMetadataRefinements,
  _proofBoundaryMetadataRefinements,
  _excludedGuardMetadataRefinements,
  _deniedFieldMetadataRefinements,
  _blockedIntegrationMetadataRefinements,
  _targetSurfaceMetadataRefinements,
  _diagnosticSummaryMetadataRefinements,
  _phase34FDiagnosticRequirementRefinements,
};

const _allowedRefinementTypes = <String>{
  'supportTraceabilityMetadata',
  'warningReasonSummaryMetadata',
  'proofBoundarySummaryMetadata',
  'excludedGuardSummaryMetadata',
  'deniedFieldSummaryMetadata',
  'blockedIntegrationSummaryMetadata',
  'targetSurfaceSummaryMetadata',
  'diagnosticSummaryCountsMetadata',
  'phase34FDiagnosticRequirementMetadata',
};

const _allowedTargetSurfaces = <String>{
  'diagnosticCommandMetadata',
  'selectedGoldenDiagnosticRows',
  'actionPlanReportMetadata',
  'patchSetReportMetadata',
  'patchSetDiagnosticMetadata',
  'prototypeSkeletonMetadata',
  'guardrailSnapshotMetadata',
  'proofBoundaryMetadata',
  'deniedFieldBoundaryMetadata',
  'blockedIntegrationMetadata',
};

const _forbiddenTargetSurfaces = <String>{
  'productReviewOutput',
  'analyzerRuntimeInput',
  'analyzerWiring',
  'savedAnalysis',
  'UI',
  'backend',
  'persistence',
  'cache',
  'database',
  'schedulerExecution',
  'engineCall',
  'StockfishBridge',
  'AndroidCollector',
  'productAdapter',
};

const _pvMultiPvBoundaryCaseId = 'pv-multipv-support-boundary-32e';
const _phase32ECaseIds = <String>{
  'king-safety-mating-net-pressure-32e',
  'endgame-precision-candidate-spread-32e',
  'suppression-forced-only-legal-32e',
  'budget-pressure-wide-candidate-32e',
  _pvMultiPvBoundaryCaseId,
};
const _capturedAndroidProofIds = <String>{
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
};

const _productFields = <String>{'productLabel', 'productOutput'};
const _finalLabelFields = <String>{'finalMoveLabel', 'finalMoveLabels'};
const _labelFields = <String>{
  'productLabel',
  'finalMoveLabel',
  'finalMoveLabels',
  'brilliantGreatMissStyleLabels',
  'bestGoodInaccuracyMistakeBlunderStyleLabels',
  'classifierLabels',
};
const _scoreFields = <String>{
  'numericMoveScore',
  'numericMoveScores',
  'aggregateScore',
};
const _metricFields = <String>{'officialAccuracy', 'officialMetrics', 'acpl'};
const _rawReportLeakTokens = <String>{
  'uciok',
  'readyok',
  'info depth',
  'bestmove ',
  'pv e2e4',
  'position fen',
  'go depth',
  'go movetime',
  'active fields: productLabel',
  'numeric move score:',
  'ACPL active',
  'official accuracy active',
  'cpLoss active',
  'winProbability active',
  'readiness summary chain active',
  'readiness gate active',
  'backendUrl=',
  'apiKey',
  'secret=',
  'token=',
};

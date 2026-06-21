import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_action_plan_patch_set.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticVersion =
    'debug-only-bridge-analyzer-adapter-prototype-patch-set-diagnostic-v1';

enum DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticStatus {
  analyzerAdapterPrototypePatchSetDiagnosticReadyWithWarnings(
    'analyzerAdapterPrototypePatchSetDiagnosticReadyWithWarnings',
  ),
  analyzerAdapterPrototypePatchSetDiagnosticReadyClean(
    'analyzerAdapterPrototypePatchSetDiagnosticReadyClean',
  ),
  blockedByUnsafePatchSet('blockedByUnsafePatchSet'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidPatchSetDiagnostic('invalidPatchSetDiagnostic');

  const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticStatus(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode {
  defaultMode('default'),
  allSafe('all-safe'),
  support('support'),
  warning('warning'),
  proof('proof'),
  guards('guards'),
  denied('denied'),
  blocked('blocked'),
  recommendation('recommendation');

  const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow {
  const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow({
    required this.diagnosticRowId,
    required this.patchId,
    required this.sourceActionId,
    required this.sourceCaseId,
    required this.sourcePhase,
    required this.sourceDiagnosticRole,
    required this.sourceActionGroup,
    required this.patchGroup,
    required this.patchType,
    required this.patchPriority,
    required this.targetSurface,
    required this.appliedAsMetadataOnly,
    required this.supportAreaIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.blockedBoundaryIds,
    required this.deniedFieldIds,
    required this.androidProofIds,
    required this.ownerProofRequired,
    required this.diagnosticStatus,
    required this.findings,
    required this.recommendation,
  });

  final String diagnosticRowId;
  final String patchId;
  final String sourceActionId;
  final String sourceCaseId;
  final String sourcePhase;
  final String sourceDiagnosticRole;
  final String sourceActionGroup;
  final String patchGroup;
  final String patchType;
  final String patchPriority;
  final String targetSurface;
  final bool appliedAsMetadataOnly;
  final List<String> supportAreaIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> blockedBoundaryIds;
  final List<String> deniedFieldIds;
  final List<String> androidProofIds;
  final bool ownerProofRequired;
  final String diagnosticStatus;
  final List<String> findings;
  final String recommendation;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'diagnosticRowId': diagnosticRowId,
      'patchId': patchId,
      'sourceActionId': sourceActionId,
      'sourceCaseId': sourceCaseId,
      'sourcePhase': sourcePhase,
      'sourceDiagnosticRole': sourceDiagnosticRole,
      'sourceActionGroup': sourceActionGroup,
      'patchGroup': patchGroup,
      'patchType': patchType,
      'patchPriority': patchPriority,
      'targetSurface': targetSurface,
      'appliedAsMetadataOnly': appliedAsMetadataOnly,
      'supportAreaIds': supportAreaIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'blockedBoundaryIds': blockedBoundaryIds,
      'deniedFieldIds': deniedFieldIds,
      'androidProofIds': androidProofIds,
      'ownerProofRequired': ownerProofRequired,
      'diagnosticStatus': diagnosticStatus,
      'findings': findings,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticResult {
  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticResult({
    required this.status,
    required this.mode,
    required this.sourceActionPlanStatus,
    required this.sourcePatchSetStatus,
    required this.rows,
    required this.findings,
    required this.allowedTargetSurfaces,
    required this.forbiddenTargetSurfaces,
    required this.safeForPhase34E,
    required this.nextRecommendation,
  }) : totalDiagnosticRows = rows.length,
       supportTraceabilityRowCount = _countGroup(
         rows,
         _supportTraceabilityPatches,
       ),
       warningFollowupMarkerRowCount = _countGroup(
         rows,
         _warningFollowupMarkerPatches,
       ),
       proofBoundaryMarkerRowCount = _countGroup(
         rows,
         _proofBoundaryMarkerPatches,
       ),
       excludedGuardPreservationRowCount = _countGroup(
         rows,
         _excludedGuardPreservationPatches,
       ),
       deniedFieldProtectionRowCount = _countGroup(
         rows,
         _deniedFieldProtectionPatches,
       ),
       diagnosticCoverageRowCount = _countGroup(
         rows,
         _diagnosticCoveragePatches,
       ),
       prototypeSkeletonMetadataRowCount = _countGroup(
         rows,
         _prototypeSkeletonMetadataPatches,
       ),
       blockedIntegrationSentinelRowCount = _countGroup(
         rows,
         _blockedIntegrationSentinelPatches,
       ),
       futurePrerequisiteRowCount = _countGroup(
         rows,
         _futurePrerequisiteMarkerPatches,
       ),
       phase34DRequirementRowCount = _countGroup(
         rows,
         _phase34DPracticalDiagnosticRequirementPatches,
       ),
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

  final DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticStatus status;
  final DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode mode;
  final String sourceActionPlanStatus;
  final String sourcePatchSetStatus;
  final List<DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow> rows;
  final List<String> findings;
  final List<String> allowedTargetSurfaces;
  final List<String> forbiddenTargetSurfaces;
  final bool safeForPhase34E;
  final String nextRecommendation;
  final int totalDiagnosticRows;
  final int supportTraceabilityRowCount;
  final int warningFollowupMarkerRowCount;
  final int proofBoundaryMarkerRowCount;
  final int excludedGuardPreservationRowCount;
  final int deniedFieldProtectionRowCount;
  final int diagnosticCoverageRowCount;
  final int prototypeSkeletonMetadataRowCount;
  final int blockedIntegrationSentinelRowCount;
  final int futurePrerequisiteRowCount;
  final int phase34DRequirementRowCount;
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

  int get unsafeCount => safeForPhase34E ? 0 : 1;

  bool get hasUnsafePolicyViolation =>
      !safeForPhase34E ||
      nextRecommendation != _phase34ERecommendation ||
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
      ..writeln('# Analyzer Adapter Prototype Patch Set Diagnostic')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticVersion',
      )
      ..writeln('- diagnostic status: ${status.wire}')
      ..writeln('- patch diagnostic mode: ${mode.wire}')
      ..writeln('- Phase 34B action plan status: $sourceActionPlanStatus')
      ..writeln('- Phase 34C patch set status: $sourcePatchSetStatus')
      ..writeln('- safe for Phase 34E: $safeForPhase34E')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln()
      ..writeln('## Source Phase Chain')
      ..writeln('- Phase 34B action plan: $sourceActionPlanStatus')
      ..writeln('- Phase 34C patch set: $sourcePatchSetStatus')
      ..writeln()
      ..writeln('## Patch Group Summary')
      ..writeln('- total diagnostic rows: $totalDiagnosticRows')
      ..writeln('- support traceability rows: $supportTraceabilityRowCount')
      ..writeln('- warning marker rows: $warningFollowupMarkerRowCount')
      ..writeln('- proof-boundary marker rows: $proofBoundaryMarkerRowCount')
      ..writeln(
        '- excluded guard preservation rows: $excludedGuardPreservationRowCount',
      )
      ..writeln(
        '- denied-field protection rows: $deniedFieldProtectionRowCount',
      )
      ..writeln('- diagnostic coverage rows: $diagnosticCoverageRowCount')
      ..writeln(
        '- prototype skeleton metadata rows: $prototypeSkeletonMetadataRowCount',
      )
      ..writeln(
        '- blocked integration sentinel rows: $blockedIntegrationSentinelRowCount',
      )
      ..writeln('- future prerequisite rows: $futurePrerequisiteRowCount')
      ..writeln('- Phase 34D requirement rows: $phase34DRequirementRowCount')
      ..writeln()
      ..writeln('## Target Surface Boundary')
      ..writeln('- allowed target surfaces: ${_ids(allowedTargetSurfaces)}')
      ..writeln(
        '- forbidden target surfaces blocked: ${_ids(forbiddenTargetSurfaces)}',
      )
      ..writeln()
      ..writeln('## Patch Record Summary')
      ..writeln(
        '| Row | Patch | Group | Type | Target surface | Metadata-only | Findings | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- |');
    for (final row in rows) {
      buffer.writeln(
        '| ${row.diagnosticRowId} | ${row.patchId} | ${row.patchGroup} | ${row.patchType} | ${row.targetSurface} | ${row.appliedAsMetadataOnly} | ${_ids(row.findings)} | ${row.recommendation} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Support Traceability Summary')
      ..writeln('- rows: $supportTraceabilityRowCount')
      ..writeln(
        '- metadata-only: ${_allMetadataOnly(_supportTraceabilityPatches)}',
      )
      ..writeln()
      ..writeln('## Warning Marker Summary')
      ..writeln('- rows: $warningFollowupMarkerRowCount')
      ..writeln('- warning-only: ${warningFollowupMarkerRowCount > 0}')
      ..writeln()
      ..writeln('## Proof-Boundary Marker Summary')
      ..writeln('- rows: $proofBoundaryMarkerRowCount')
      ..writeln('- Phase 32E proof claim count: $phase32EProofClaimCount')
      ..writeln('- unproven Android proof count: $unprovenAndroidProofCount')
      ..writeln()
      ..writeln('## Excluded Guard Preservation Summary')
      ..writeln('- rows: $excludedGuardPreservationRowCount')
      ..writeln('- quiet/preparatory remains excluded guard: true')
      ..writeln()
      ..writeln('## Denied-Field Protection Summary')
      ..writeln('- rows: $deniedFieldProtectionRowCount')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- product output count: $productOutputCount')
      ..writeln('- label leak count: $labelLeakCount')
      ..writeln('- score leak count: $scoreLeakCount')
      ..writeln('- metric leak count: $metricLeakCount')
      ..writeln('- CP-loss leak count: $cpLossLeakCount')
      ..writeln('- win probability leak count: $winProbabilityLeakCount')
      ..writeln()
      ..writeln('## Blocked Integration Sentinel Summary')
      ..writeln('- analyzer wiring count: $analyzerWiringCount')
      ..writeln('- runtime implementation count: $runtimeImplementationCount')
      ..writeln('- executable prototype count: $executablePrototypeCount')
      ..writeln('- engine call count: $engineCallCount')
      ..writeln('- scheduler execution count: $schedulerExecutionCount')
      ..writeln('- persistence write count: $persistenceWriteCount')
      ..writeln(
        '- product adapter behavior count: $productAdapterBehaviorCount',
      )
      ..writeln(
        '- saved analysis integration count: $savedAnalysisIntegrationCount',
      )
      ..writeln()
      ..writeln('## Future Prerequisite Summary')
      ..writeln('- future prerequisite rows: $futurePrerequisiteRowCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Recommendation')
      ..writeln('- safe for Phase 34E: $safeForPhase34E')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln();
    return buffer.toString();
  }

  String renderJson() {
    return const JsonEncoder.withIndent(' ').convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticVersion,
      'status': status.wire,
      'patchDiagnosticMode': mode.wire,
      'sourcePhaseChain': <String, Object?>{
        'phase34BActionPlan': sourceActionPlanStatus,
        'phase34CPatchSet': sourcePatchSetStatus,
      },
      'safeForPhase34E': safeForPhase34E,
      'safeForNextStep': safeForPhase34E,
      'nextRecommendation': nextRecommendation,
      'allowedTargetSurfaces': allowedTargetSurfaces,
      'forbiddenTargetSurfaces': forbiddenTargetSurfaces,
      'counts': <String, Object?>{
        'totalDiagnosticRows': totalDiagnosticRows,
        'supportTraceabilityRowCount': supportTraceabilityRowCount,
        'warningFollowupMarkerRowCount': warningFollowupMarkerRowCount,
        'proofBoundaryMarkerRowCount': proofBoundaryMarkerRowCount,
        'excludedGuardPreservationRowCount': excludedGuardPreservationRowCount,
        'deniedFieldProtectionRowCount': deniedFieldProtectionRowCount,
        'diagnosticCoverageRowCount': diagnosticCoverageRowCount,
        'prototypeSkeletonMetadataRowCount': prototypeSkeletonMetadataRowCount,
        'blockedIntegrationSentinelRowCount':
            blockedIntegrationSentinelRowCount,
        'futurePrerequisiteRowCount': futurePrerequisiteRowCount,
        'phase34DRequirementRowCount': phase34DRequirementRowCount,
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
      'findings': findings,
      'rows': rows.map((row) => row.toJson()).toList(),
    };
  }

  bool _allMetadataOnly(String group) {
    final groupRows = rows.where((row) => row.patchGroup == group).toList();
    return groupRows.isNotEmpty &&
        groupRows.every((row) => row.appliedAsMetadataOnly);
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnostic {
  const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnostic();

  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticResult evaluate({
    DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetResult?
    patchSetResult,
    DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode mode =
        DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode
            .defaultMode,
  }) {
    final source =
        patchSetResult ??
        const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSet()
            .evaluate();
    if (source.hasUnsafePolicyViolation || !source.safeForPhase34D) {
      return DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticResult(
        status: DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticStatus
            .blockedByUnsafePatchSet,
        mode: mode,
        sourceActionPlanStatus: source.sourceActionPlanStatus,
        sourcePatchSetStatus: source.status.wire,
        rows:
            const <
              DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow
            >[],
        findings: const <String>['unsafePhase34CPatchSet'],
        allowedTargetSurfaces: _sorted(_allowedTargetSurfaces),
        forbiddenTargetSurfaces: _sorted(_forbiddenTargetSurfaces),
        safeForPhase34E: false,
        nextRecommendation:
            'blockedByUnsafeAnalyzerAdapterPrototypePatchSetDiagnostic',
      );
    }

    final rows = _patchesForMode(
      source.patches,
      mode,
    ).map(_rowForPatch).toList(growable: false);
    final findings =
        const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticValidator()
            .validateRows(rows, mode: mode);
    final safeForPhase34E = findings.isEmpty;
    final status = !safeForPhase34E
        ? DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticStatus
              .blockedByPolicyBoundary
        : rows.any(
            (row) =>
                row.warningReasons.isNotEmpty ||
                row.proofLimitReasons.isNotEmpty,
          )
        ? DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticStatus
              .analyzerAdapterPrototypePatchSetDiagnosticReadyWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticStatus
              .analyzerAdapterPrototypePatchSetDiagnosticReadyClean;
    return DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticResult(
      status: status,
      mode: mode,
      sourceActionPlanStatus: source.sourceActionPlanStatus,
      sourcePatchSetStatus: source.status.wire,
      rows: rows,
      findings: findings,
      allowedTargetSurfaces: _sorted(_allowedTargetSurfaces),
      forbiddenTargetSurfaces: _sorted(_forbiddenTargetSurfaces),
      safeForPhase34E: safeForPhase34E,
      nextRecommendation: safeForPhase34E
          ? _phase34ERecommendation
          : 'blockedByUnsafeAnalyzerAdapterPrototypePatchSetDiagnostic',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticValidator {
  const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticValidator();

  List<String> validateRows(
    Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow>
    rows, {
    required DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode mode,
  }) {
    final records = rows.toList();
    final findings = <String>[
      if (!_allowedModes.contains(mode.wire)) 'unknownPatchDiagnosticMode',
      if (!records.any((row) => row.recommendation == _phase34ERecommendation))
        'missingPhase34EMetadataRefinementRecommendation',
    ];
    for (final record in records) {
      findings.addAll(validateRow(record));
    }
    return _sorted(findings);
  }

  List<String> validateRow(
    DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow row,
  ) {
    final activeDenied = _activeDeniedFieldIds(row).toSet();
    return _sorted(<String>[
      if (!_allowedPatchGroups.contains(row.patchGroup)) 'unknownPatchGroup',
      if (!_allowedPatchTypes.contains(row.patchType)) 'unknownPatchType',
      if (!_allowedTargetSurfaces.contains(row.targetSurface))
        'unknownTargetSurface',
      if (_forbiddenTargetSurfaces.contains(row.targetSurface))
        'forbiddenTargetSurface',
      if (!row.appliedAsMetadataOnly) 'nonMetadataDiagnosticRow',
      if (_isQuietRow(row) &&
          row.patchGroup != _excludedGuardPreservationPatches)
        'quietPreparatoryPromotion',
      if (row.sourceCaseId == _pvMultiPvBoundaryCaseId &&
          row.patchGroup != _proofBoundaryMarkerPatches)
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

List<DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord>
_patchesForMode(
  List<DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord> patches,
  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode mode,
) {
  final selected = switch (mode) {
    DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode.defaultMode ||
    DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode.allSafe =>
      patches,
    DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode.support =>
      patches.where((patch) => patch.patchGroup == _supportTraceabilityPatches),
    DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode.warning =>
      patches.where(
        (patch) => patch.patchGroup == _warningFollowupMarkerPatches,
      ),
    DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode.proof =>
      patches.where((patch) => patch.patchGroup == _proofBoundaryMarkerPatches),
    DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode.guards =>
      patches.where(
        (patch) => patch.patchGroup == _excludedGuardPreservationPatches,
      ),
    DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode.denied =>
      patches.where(
        (patch) => patch.patchGroup == _deniedFieldProtectionPatches,
      ),
    DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode.blocked =>
      patches.where(
        (patch) =>
            patch.patchGroup == _blockedIntegrationSentinelPatches ||
            patch.patchGroup == _futurePrerequisiteMarkerPatches,
      ),
    DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode
        .recommendation =>
      patches.where(
        (patch) =>
            patch.patchGroup == _phase34DPracticalDiagnosticRequirementPatches,
      ),
  };
  return selected.toList(growable: false);
}

DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow _rowForPatch(
  DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord patch,
) {
  final provisional =
      DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow(
        diagnosticRowId: 'diagnostic-${patch.patchId}',
        patchId: patch.patchId,
        sourceActionId: patch.sourceActionId,
        sourceCaseId: patch.sourceCaseId,
        sourcePhase: patch.sourcePhase,
        sourceDiagnosticRole: patch.sourceDiagnosticRole,
        sourceActionGroup: patch.sourceActionGroup,
        patchGroup: patch.patchGroup,
        patchType: patch.patchType,
        patchPriority: patch.patchPriority,
        targetSurface: patch.targetSurface,
        appliedAsMetadataOnly: patch.appliedAsMetadataOnly,
        supportAreaIds: patch.supportAreaIds,
        warningReasons: patch.warningReasons,
        proofLimitReasons: patch.proofLimitReasons,
        blockedBoundaryIds: patch.blockedBoundaryIds,
        deniedFieldIds: patch.deniedFieldIds,
        androidProofIds: patch.androidProofIds,
        ownerProofRequired: patch.ownerProofRequired,
        diagnosticStatus: 'pendingPatchDiagnostic',
        findings: const <String>[],
        recommendation: _phase34ERecommendation,
      );
  final findings =
      const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticValidator()
          .validateRow(provisional);
  return DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow(
    diagnosticRowId: provisional.diagnosticRowId,
    patchId: provisional.patchId,
    sourceActionId: provisional.sourceActionId,
    sourceCaseId: provisional.sourceCaseId,
    sourcePhase: provisional.sourcePhase,
    sourceDiagnosticRole: provisional.sourceDiagnosticRole,
    sourceActionGroup: provisional.sourceActionGroup,
    patchGroup: provisional.patchGroup,
    patchType: provisional.patchType,
    patchPriority: provisional.patchPriority,
    targetSurface: provisional.targetSurface,
    appliedAsMetadataOnly: provisional.appliedAsMetadataOnly,
    supportAreaIds: provisional.supportAreaIds,
    warningReasons: provisional.warningReasons,
    proofLimitReasons: provisional.proofLimitReasons,
    blockedBoundaryIds: provisional.blockedBoundaryIds,
    deniedFieldIds: provisional.deniedFieldIds,
    androidProofIds: provisional.androidProofIds,
    ownerProofRequired: provisional.ownerProofRequired,
    diagnosticStatus: findings.isEmpty
        ? 'patchDiagnosticReadyWithWarnings'
        : 'patchDiagnosticBlockedByPolicyBoundary',
    findings: findings,
    recommendation: provisional.recommendation,
  );
}

bool _isQuietRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow row,
) {
  return row.supportAreaIds.contains('quietMove') ||
      row.supportAreaIds.contains('quietPreparatoryMove') ||
      row.sourceCaseId.contains('quiet-preparatory');
}

bool _enablesBoundary(
  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow row,
  Set<String> boundaryIds,
) {
  return !row.appliedAsMetadataOnly &&
      row.blockedBoundaryIds.any(boundaryIds.contains);
}

Iterable<String> _activeDeniedFieldIds(
  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow row,
) {
  if (row.appliedAsMetadataOnly &&
      !_forbiddenTargetSurfaces.contains(row.targetSurface)) {
    return const <String>[];
  }
  return row.deniedFieldIds;
}

int _countActiveFields(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow> rows,
  Set<String> fields,
) {
  var count = 0;
  for (final row in rows) {
    count += _activeDeniedFieldIds(row).where(fields.contains).length;
  }
  return count;
}

int _countEnabledBoundary(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow> rows,
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
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow> rows,
  Set<String> surfaces,
) {
  return rows.where((row) => surfaces.contains(row.targetSurface)).length;
}

int _countGroup(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow> rows,
  String group,
) {
  return rows.where((row) => row.patchGroup == group).length;
}

String _ids(Iterable<String> values) {
  final sorted = _sorted(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

List<String> _sorted(Iterable<String> values) {
  return values.where((value) => value.trim().isNotEmpty).toSet().toList()
    ..sort();
}

const _phase34ERecommendation =
    'implementAnalyzerAdapterPrototypeMetadataRefinementPatch';

const _supportTraceabilityPatches = 'supportTraceabilityPatches';
const _warningFollowupMarkerPatches = 'warningFollowupMarkerPatches';
const _proofBoundaryMarkerPatches = 'proofBoundaryMarkerPatches';
const _excludedGuardPreservationPatches = 'excludedGuardPreservationPatches';
const _deniedFieldProtectionPatches = 'deniedFieldProtectionPatches';
const _diagnosticCoveragePatches = 'diagnosticCoveragePatches';
const _prototypeSkeletonMetadataPatches = 'prototypeSkeletonMetadataPatches';
const _blockedIntegrationSentinelPatches = 'blockedIntegrationSentinelPatches';
const _futurePrerequisiteMarkerPatches = 'futurePrerequisiteMarkerPatches';
const _phase34DPracticalDiagnosticRequirementPatches =
    'phase34DPracticalDiagnosticRequirementPatches';

const _allowedModes = <String>{
  'default',
  'all-safe',
  'support',
  'warning',
  'proof',
  'guards',
  'denied',
  'blocked',
  'recommendation',
};

const _allowedPatchGroups = <String>{
  _supportTraceabilityPatches,
  _warningFollowupMarkerPatches,
  _proofBoundaryMarkerPatches,
  _excludedGuardPreservationPatches,
  _deniedFieldProtectionPatches,
  _diagnosticCoveragePatches,
  _prototypeSkeletonMetadataPatches,
  _blockedIntegrationSentinelPatches,
  _futurePrerequisiteMarkerPatches,
  _phase34DPracticalDiagnosticRequirementPatches,
};

const _allowedPatchTypes = <String>{
  'supportTraceabilityPatch',
  'warningFollowupMarkerPatch',
  'proofBoundaryMarkerPatch',
  'excludedGuardPreservationPatch',
  'deniedFieldProtectionPatch',
  'diagnosticCoveragePatch',
  'prototypeSkeletonMetadataPatch',
  'blockedIntegrationSentinelPatch',
  'futurePrerequisiteMarkerPatch',
  'phase34DPracticalDiagnosticRequirementPatch',
};

const _allowedTargetSurfaces = <String>{
  'diagnosticCommandMetadata',
  'selectedGoldenDiagnosticRows',
  'prototypeSkeletonMetadata',
  'actionPlanReportMetadata',
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

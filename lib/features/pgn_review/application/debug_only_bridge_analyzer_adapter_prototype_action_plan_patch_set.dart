import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_selected_diagnostic_action_plan.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetVersion =
    'debug-only-bridge-analyzer-adapter-prototype-action-plan-patch-set-v1';

enum DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetStatus {
  analyzerAdapterPrototypeActionPlanPatchSetAppliedWithWarnings(
    'analyzerAdapterPrototypeActionPlanPatchSetAppliedWithWarnings',
  ),
  analyzerAdapterPrototypeActionPlanPatchSetAppliedClean(
    'analyzerAdapterPrototypeActionPlanPatchSetAppliedClean',
  ),
  blockedByUnsafeSelectedDiagnosticActionPlan(
    'blockedByUnsafeSelectedDiagnosticActionPlan',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidActionPlanPatchSet('invalidActionPlanPatchSet');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetStatus(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord({
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
    required this.targetRecordId,
    required this.supportAreaIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.blockedBoundaryIds,
    required this.deniedFieldIds,
    required this.androidProofIds,
    required this.ownerProofRequired,
    required this.implementationAllowedNow,
    required this.appliedAsMetadataOnly,
    required this.requiresFutureValidation,
    required this.recommendation,
  });

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
  final String targetRecordId;
  final List<String> supportAreaIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> blockedBoundaryIds;
  final List<String> deniedFieldIds;
  final List<String> androidProofIds;
  final bool ownerProofRequired;
  final bool implementationAllowedNow;
  final bool appliedAsMetadataOnly;
  final bool requiresFutureValidation;
  final String recommendation;

  Map<String, Object?> toJson() {
    return <String, Object?>{
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
      'targetRecordId': targetRecordId,
      'supportAreaIds': supportAreaIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'blockedBoundaryIds': blockedBoundaryIds,
      'deniedFieldIds': deniedFieldIds,
      'androidProofIds': androidProofIds,
      'ownerProofRequired': ownerProofRequired,
      'implementationAllowedNow': implementationAllowedNow,
      'appliedAsMetadataOnly': appliedAsMetadataOnly,
      'requiresFutureValidation': requiresFutureValidation,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetResult {
  DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetResult({
    required this.status,
    required this.sourceActionPlanStatus,
    required this.sourceValidationStatus,
    required this.patches,
    required this.findings,
    required this.safeForPhase34D,
    required this.nextRecommendation,
  }) : totalPatchRecords = patches.length,
       supportTraceabilityPatchCount = _countGroup(
         patches,
         _supportTraceabilityPatches,
       ),
       warningFollowupMarkerPatchCount = _countGroup(
         patches,
         _warningFollowupMarkerPatches,
       ),
       proofBoundaryMarkerPatchCount = _countGroup(
         patches,
         _proofBoundaryMarkerPatches,
       ),
       excludedGuardPreservationPatchCount = _countGroup(
         patches,
         _excludedGuardPreservationPatches,
       ),
       deniedFieldProtectionPatchCount = _countGroup(
         patches,
         _deniedFieldProtectionPatches,
       ),
       diagnosticCoveragePatchCount = _countGroup(
         patches,
         _diagnosticCoveragePatches,
       ),
       prototypeSkeletonMetadataPatchCount = _countGroup(
         patches,
         _prototypeSkeletonMetadataPatches,
       ),
       blockedIntegrationSentinelPatchCount = _countGroup(
         patches,
         _blockedIntegrationSentinelPatches,
       ),
       futurePrerequisiteMarkerPatchCount = _countGroup(
         patches,
         _futurePrerequisiteMarkerPatches,
       ),
       phase34DPracticalDiagnosticRequirementPatchCount = _countGroup(
         patches,
         _phase34DPracticalDiagnosticRequirementPatches,
       ),
       activeDeniedFieldCount = patches.expand(_activeDeniedFieldIds).length,
       productOutputCount =
           _countForbiddenSurface(patches, const {'productReviewOutput'}) +
           _countActiveFields(patches, _productFields),
       labelLeakCount = _countActiveFields(patches, _labelFields),
       finalLabelLeakCount = _countActiveFields(patches, _finalLabelFields),
       scoreLeakCount = _countActiveFields(patches, _scoreFields),
       metricLeakCount = _countActiveFields(patches, _metricFields),
       cpLossLeakCount = _countActiveFields(patches, const {'cpLoss'}),
       winProbabilityLeakCount = _countActiveFields(patches, const {
         'winProbability',
       }),
       moveRankingLeakCount = _countActiveFields(patches, const {
         'moveRanking',
       }),
       thresholdLeakCount = _countActiveFields(patches, const {'thresholds'}),
       uiTargetCount =
           _countForbiddenSurface(patches, const {'UI'}) +
           _countEnabledBoundary(patches, const {'uiTarget'}),
       backendTargetCount =
           _countForbiddenSurface(patches, const {'backend'}) +
           _countEnabledBoundary(patches, const {'backendTarget'}),
       persistenceWriteCount =
           _countForbiddenSurface(patches, const {
             'persistence',
             'cache',
             'database',
           }) +
           _countEnabledBoundary(patches, const {'persistenceWrite'}),
       engineCallCount =
           _countForbiddenSurface(patches, const {
             'engineCall',
             'StockfishBridge',
           }) +
           _countEnabledBoundary(patches, const {
             'directEngineCall',
             'engineResults',
           }),
       schedulerExecutionCount =
           _countForbiddenSurface(patches, const {'schedulerExecution'}) +
           _countEnabledBoundary(patches, const {'schedulerExecution'}),
       analyzerWiringCount =
           _countForbiddenSurface(patches, const {'analyzerWiring'}) +
           _countEnabledBoundary(patches, const {'analyzerWiring'}),
       runtimeImplementationCount = _countEnabledBoundary(patches, const {
         'runtimeImplementation',
       }),
       executablePrototypeCount = _countEnabledBoundary(patches, const {
         'executablePrototypeBehavior',
       }),
       productAdapterBehaviorCount =
           _countForbiddenSurface(patches, const {'productAdapter'}) +
           _countEnabledBoundary(patches, const {'productAdapterBehavior'}),
       savedAnalysisIntegrationCount =
           _countForbiddenSurface(patches, const {'savedAnalysis'}) +
           _countEnabledBoundary(patches, const {'savedAnalysisIntegration'}),
       stockfishCommandLeakCount = _countActiveFields(patches, const {
         'stockfishCommand',
       }),
       rawUciLeakCount = _countActiveFields(patches, const {'rawUci'}),
       pvDumpLeakCount = _countActiveFields(patches, const {'pvDump'}),
       androidCollectorRequirementCount =
           _countForbiddenSurface(patches, const {'AndroidCollector'}) +
           _countActiveFields(patches, const {
             'androidCollectorRequirement',
             'androidCollectorExecution',
           }),
       phase32EProofClaimCount = patches
           .where(
             (patch) => patch.androidProofIds.any(_phase32ECaseIds.contains),
           )
           .length,
       unprovenAndroidProofCount = patches
           .where(
             (patch) => patch.androidProofIds.any(
               (id) => !_capturedAndroidProofIds.contains(id),
             ),
           )
           .length,
       ownerProofQueueCount = patches
           .where((patch) => patch.ownerProofRequired)
           .length,
       blockerCount = findings
           .where((finding) => !finding.startsWith('reportTextLeak:'))
           .length,
       criticalCount = findings
           .where((finding) => finding.startsWith('reportTextLeak:'))
           .length;

  final DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetStatus status;
  final String sourceActionPlanStatus;
  final String sourceValidationStatus;
  final List<DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord>
  patches;
  final List<String> findings;
  final bool safeForPhase34D;
  final String nextRecommendation;
  final int totalPatchRecords;
  final int supportTraceabilityPatchCount;
  final int warningFollowupMarkerPatchCount;
  final int proofBoundaryMarkerPatchCount;
  final int excludedGuardPreservationPatchCount;
  final int deniedFieldProtectionPatchCount;
  final int diagnosticCoveragePatchCount;
  final int prototypeSkeletonMetadataPatchCount;
  final int blockedIntegrationSentinelPatchCount;
  final int futurePrerequisiteMarkerPatchCount;
  final int phase34DPracticalDiagnosticRequirementPatchCount;
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

  int get unsafeCount => safeForPhase34D ? 0 : 1;

  bool get hasUnsafePolicyViolation =>
      !safeForPhase34D ||
      nextRecommendation != _phase34DRecommendation ||
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

  String renderMarkdown({
    DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection section =
        DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection.all,
  }) {
    final buffer = StringBuffer()
      ..writeln('# Analyzer Adapter Prototype Action Plan Patch Set')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetVersion',
      )
      ..writeln('- patch set status: ${status.wire}')
      ..writeln('- selected section: ${section.wire}')
      ..writeln('- source action plan status: $sourceActionPlanStatus')
      ..writeln('- source validation status: $sourceValidationStatus')
      ..writeln('- safe for Phase 34D: $safeForPhase34D')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln();
    if (_includeSection(section, _patchesSection)) {
      _writePatchTable(buffer, patches);
    }
    if (_includeSection(section, _supportSection)) {
      _writePatchGroup(
        buffer,
        'Support Traceability Patches',
        _byGroup(_supportTraceabilityPatches),
      );
    }
    if (_includeSection(section, _warningSection)) {
      _writePatchGroup(
        buffer,
        'Warning Follow-Up Marker Patches',
        _byGroup(_warningFollowupMarkerPatches),
      );
    }
    if (_includeSection(section, _proofSection)) {
      _writePatchGroup(
        buffer,
        'Proof Boundary Marker Patches',
        _byGroup(_proofBoundaryMarkerPatches),
      );
    }
    if (_includeSection(section, _guardsSection)) {
      _writePatchGroup(
        buffer,
        'Excluded Guard Preservation Patches',
        _byGroup(_excludedGuardPreservationPatches),
      );
    }
    if (_includeSection(section, _deniedSection)) {
      _writePatchGroup(
        buffer,
        'Denied Field Protection Patches',
        _byGroup(_deniedFieldProtectionPatches),
      );
    }
    if (_includeSection(section, _blockedSection)) {
      _writePatchGroup(
        buffer,
        'Blocked Integration Sentinel Patches',
        patches.where(
          (patch) =>
              patch.patchGroup == _blockedIntegrationSentinelPatches ||
              patch.patchGroup == _futurePrerequisiteMarkerPatches,
        ),
      );
    }
    if (_includeSection(section, _recommendationSection)) {
      buffer
        ..writeln('## Recommendation')
        ..writeln('- safe for Phase 34D: $safeForPhase34D')
        ..writeln('- next recommendation: $nextRecommendation')
        ..writeln(
          '- Phase 34D practical diagnostic requirement patches: $phase34DPracticalDiagnosticRequirementPatchCount',
        )
        ..writeln('- findings: ${_ids(findings)}')
        ..writeln();
    }
    return buffer.toString();
  }

  String renderJson({
    DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection section =
        DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection.all,
  }) {
    return const JsonEncoder.withIndent(' ').convert(toJson(section: section));
  }

  Map<String, Object?> toJson({
    DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection section =
        DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection.all,
  }) {
    final payload = <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetVersion,
      'status': status.wire,
      'section': section.wire,
      'sourceActionPlanStatus': sourceActionPlanStatus,
      'sourceValidationStatus': sourceValidationStatus,
      'safeForPhase34D': safeForPhase34D,
      'nextRecommendation': nextRecommendation,
      'counts': <String, Object?>{
        'totalPatchRecords': totalPatchRecords,
        'supportTraceabilityPatchCount': supportTraceabilityPatchCount,
        'warningFollowupMarkerPatchCount': warningFollowupMarkerPatchCount,
        'proofBoundaryMarkerPatchCount': proofBoundaryMarkerPatchCount,
        'excludedGuardPreservationPatchCount':
            excludedGuardPreservationPatchCount,
        'deniedFieldProtectionPatchCount': deniedFieldProtectionPatchCount,
        'diagnosticCoveragePatchCount': diagnosticCoveragePatchCount,
        'prototypeSkeletonMetadataPatchCount':
            prototypeSkeletonMetadataPatchCount,
        'blockedIntegrationSentinelPatchCount':
            blockedIntegrationSentinelPatchCount,
        'futurePrerequisiteMarkerPatchCount':
            futurePrerequisiteMarkerPatchCount,
        'phase34DPracticalDiagnosticRequirementPatchCount':
            phase34DPracticalDiagnosticRequirementPatchCount,
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
    };
    if (_includeSection(section, _patchesSection)) {
      payload['patches'] = patches.map((patch) => patch.toJson()).toList();
    }
    if (_includeSection(section, _supportSection)) {
      payload['support'] = _byGroup(
        _supportTraceabilityPatches,
      ).map((patch) => patch.toJson()).toList();
    }
    if (_includeSection(section, _warningSection)) {
      payload['warning'] = _byGroup(
        _warningFollowupMarkerPatches,
      ).map((patch) => patch.toJson()).toList();
    }
    if (_includeSection(section, _proofSection)) {
      payload['proof'] = _byGroup(
        _proofBoundaryMarkerPatches,
      ).map((patch) => patch.toJson()).toList();
    }
    if (_includeSection(section, _guardsSection)) {
      payload['guards'] = _byGroup(
        _excludedGuardPreservationPatches,
      ).map((patch) => patch.toJson()).toList();
    }
    if (_includeSection(section, _deniedSection)) {
      payload['denied'] = _byGroup(
        _deniedFieldProtectionPatches,
      ).map((patch) => patch.toJson()).toList();
    }
    if (_includeSection(section, _blockedSection)) {
      payload['blocked'] = patches
          .where(
            (patch) =>
                patch.patchGroup == _blockedIntegrationSentinelPatches ||
                patch.patchGroup == _futurePrerequisiteMarkerPatches,
          )
          .map((patch) => patch.toJson())
          .toList();
    }
    if (_includeSection(section, _recommendationSection)) {
      payload['recommendation'] = <String, Object?>{
        'safeForPhase34D': safeForPhase34D,
        'nextRecommendation': nextRecommendation,
        'phase34DPracticalDiagnosticRequirementPatchCount':
            phase34DPracticalDiagnosticRequirementPatchCount,
      };
    }
    return payload;
  }

  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord>
  _byGroup(String group) => patches.where((patch) => patch.patchGroup == group);
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection {
  all('all'),
  patches('patches'),
  support('support'),
  warning('warning'),
  proof('proof'),
  guards('guards'),
  denied('denied'),
  blocked('blocked'),
  recommendation('recommendation');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSet {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSet();

  DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetResult evaluate({
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanResult?
    actionPlanResult,
  }) {
    final source =
        actionPlanResult ??
        const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan()
            .evaluate();
    if (source.hasUnsafePolicyViolation || !source.safeForPhase34C) {
      return DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetResult(
        status: DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetStatus
            .blockedByUnsafeSelectedDiagnosticActionPlan,
        sourceActionPlanStatus: source.status.wire,
        sourceValidationStatus: source.sourceValidationStatus,
        patches:
            const <
              DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord
            >[],
        findings: const <String>['unsafePhase34BActionPlan'],
        safeForPhase34D: false,
        nextRecommendation:
            'blockedByUnsafeAnalyzerAdapterPrototypeActionPlanPatchSet',
      );
    }

    final patches = source.actions.map(_patchForAction).toList(growable: false);
    final findings =
        const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetValidator()
            .validatePatches(patches);
    final safeForPhase34D = findings.isEmpty;
    final status = !safeForPhase34D
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetStatus
              .blockedByPolicyBoundary
        : patches.any(
            (patch) =>
                patch.warningReasons.isNotEmpty ||
                patch.proofLimitReasons.isNotEmpty,
          )
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetStatus
              .analyzerAdapterPrototypeActionPlanPatchSetAppliedWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetStatus
              .analyzerAdapterPrototypeActionPlanPatchSetAppliedClean;
    return DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetResult(
      status: status,
      sourceActionPlanStatus: source.status.wire,
      sourceValidationStatus: source.sourceValidationStatus,
      patches: patches,
      findings: findings,
      safeForPhase34D: safeForPhase34D,
      nextRecommendation: safeForPhase34D
          ? _phase34DRecommendation
          : 'blockedByUnsafeAnalyzerAdapterPrototypeActionPlanPatchSet',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetValidator {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetValidator();

  List<String> validatePatches(
    Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord>
    patches,
  ) {
    final records = patches.toList();
    final findings = <String>[
      if (!records.any(
        (record) =>
            record.patchGroup == _phase34DPracticalDiagnosticRequirementPatches,
      ))
        'missingPhase34DPracticalDiagnosticRequirement',
    ];
    for (final record in records) {
      findings.addAll(validatePatch(record));
    }
    return _sorted(findings);
  }

  List<String> validatePatch(
    DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord patch,
  ) {
    final activeDenied = _activeDeniedFieldIds(patch).toSet();
    return _sorted(<String>[
      if (!_allowedPatchGroups.contains(patch.patchGroup)) 'unknownPatchGroup',
      if (!_allowedPatchTypes.contains(patch.patchType)) 'unknownPatchType',
      if (!_allowedTargetSurfaces.contains(patch.targetSurface))
        'unknownTargetSurface',
      if (_forbiddenTargetSurfaces.contains(patch.targetSurface))
        'forbiddenTargetSurface',
      if (!patch.appliedAsMetadataOnly) 'nonMetadataPatch',
      if (!patch.requiresFutureValidation) 'missingFutureValidation',
      if (_isQuietPatch(patch) &&
          patch.patchGroup != _excludedGuardPreservationPatches)
        'quietPreparatoryPromotion',
      if (patch.sourceCaseId == _pvMultiPvBoundaryCaseId &&
          patch.patchGroup != _proofBoundaryMarkerPatches)
        'pvMultiPvPromotion',
      if (patch.androidProofIds.any(_phase32ECaseIds.contains))
        'phase32ECapturedProofClaim',
      if (patch.androidProofIds.any(
        (id) => !_capturedAndroidProofIds.contains(id),
      ))
        'unprovenAndroidProofClaim',
      if (patch.ownerProofRequired &&
          !patch.proofLimitReasons.any(
            (reason) => reason.contains('pvMultiPv'),
          ))
        'ownerProofWithoutPvMultiPvReason',
      if (_enablesBoundary(patch, const {'runtimeImplementation'}))
        'runtimeImplementationEnabled',
      if (_enablesBoundary(patch, const {'analyzerWiring'}))
        'analyzerWiringEnabled',
      if (_enablesBoundary(patch, const {'executablePrototypeBehavior'}))
        'executablePrototypeEnabled',
      if (_enablesBoundary(patch, const {'directEngineCall', 'engineResults'}))
        'engineCallEnabled',
      if (_enablesBoundary(patch, const {'schedulerExecution'}))
        'schedulerExecutionEnabled',
      if (_enablesBoundary(patch, const {'productAdapterBehavior'}))
        'productAdapterEnabled',
      if (_enablesBoundary(patch, const {'savedAnalysisIntegration'}))
        'savedAnalysisIntegrationEnabled',
      if (_enablesBoundary(patch, const {
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

DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord _patchForAction(
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord action,
) {
  final group = _patchGroupForAction(action.actionGroup);
  return DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord(
    patchId: 'patch-${_idSuffix(action.actionId)}',
    sourceActionId: action.actionId,
    sourceCaseId: action.sourceCaseId,
    sourcePhase: action.sourcePhase,
    sourceDiagnosticRole: action.sourceDiagnosticRole,
    sourceActionGroup: action.actionGroup,
    patchGroup: group,
    patchType: _patchTypeForGroup(group),
    patchPriority: action.priority,
    targetSurface: _targetSurfaceForGroup(group),
    targetRecordId: 'metadata-${_idSuffix(action.actionId)}',
    supportAreaIds: action.supportAreaIds,
    warningReasons: _sorted(<String>[
      ...action.warningReasons,
      'metadataOnlyActionPlanPatchSetNoRuntimeExecution',
    ]),
    proofLimitReasons: action.proofLimitReasons,
    blockedBoundaryIds: action.blockedBoundaryIds,
    deniedFieldIds: action.deniedFieldIds,
    androidProofIds: action.androidProofIds,
    ownerProofRequired: false,
    implementationAllowedNow: _metadataPatchAllowedNow(group),
    appliedAsMetadataOnly: true,
    requiresFutureValidation: action.requiresFutureValidation,
    recommendation: _phase34DRecommendation,
  );
}

String _patchGroupForAction(String actionGroup) {
  return switch (actionGroup) {
    _safeInternalSupportActions => _supportTraceabilityPatches,
    _warningLimitedFollowupActions => _warningFollowupMarkerPatches,
    _proofBoundaryActions => _proofBoundaryMarkerPatches,
    _excludedGuardActions => _excludedGuardPreservationPatches,
    _deniedFieldProtectionActions => _deniedFieldProtectionPatches,
    _prototypeSkeletonImprovementActions => _prototypeSkeletonMetadataPatches,
    _diagnosticCoverageActions => _diagnosticCoveragePatches,
    _futureRuntimePrerequisiteActions => _futurePrerequisiteMarkerPatches,
    _blockedIntegrationActions => _blockedIntegrationSentinelPatches,
    _phase34CRequirementActions =>
      _phase34DPracticalDiagnosticRequirementPatches,
    _ => 'unknownPatchGroup',
  };
}

String _patchTypeForGroup(String group) {
  return switch (group) {
    _supportTraceabilityPatches => 'supportTraceabilityPatch',
    _warningFollowupMarkerPatches => 'warningFollowupMarkerPatch',
    _proofBoundaryMarkerPatches => 'proofBoundaryMarkerPatch',
    _excludedGuardPreservationPatches => 'excludedGuardPreservationPatch',
    _deniedFieldProtectionPatches => 'deniedFieldProtectionPatch',
    _diagnosticCoveragePatches => 'diagnosticCoveragePatch',
    _prototypeSkeletonMetadataPatches => 'prototypeSkeletonMetadataPatch',
    _blockedIntegrationSentinelPatches => 'blockedIntegrationSentinelPatch',
    _futurePrerequisiteMarkerPatches => 'futurePrerequisiteMarkerPatch',
    _phase34DPracticalDiagnosticRequirementPatches =>
      'phase34DPracticalDiagnosticRequirementPatch',
    _ => 'unknownPatchType',
  };
}

String _targetSurfaceForGroup(String group) {
  return switch (group) {
    _supportTraceabilityPatches => 'selectedGoldenDiagnosticRows',
    _warningFollowupMarkerPatches => 'diagnosticCommandMetadata',
    _proofBoundaryMarkerPatches => 'proofBoundaryMetadata',
    _excludedGuardPreservationPatches => 'guardrailSnapshotMetadata',
    _deniedFieldProtectionPatches => 'deniedFieldBoundaryMetadata',
    _diagnosticCoveragePatches => 'diagnosticCommandMetadata',
    _prototypeSkeletonMetadataPatches => 'prototypeSkeletonMetadata',
    _blockedIntegrationSentinelPatches => 'blockedIntegrationMetadata',
    _futurePrerequisiteMarkerPatches => 'actionPlanReportMetadata',
    _phase34DPracticalDiagnosticRequirementPatches =>
      'actionPlanReportMetadata',
    _ => 'unknownTargetSurface',
  };
}

bool _metadataPatchAllowedNow(String group) {
  return switch (group) {
    _deniedFieldProtectionPatches ||
    _blockedIntegrationSentinelPatches => false,
    _ => true,
  };
}

void _writePatchTable(
  StringBuffer buffer,
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord>
  patches,
) {
  buffer
    ..writeln('## Patch Record Table')
    ..writeln(
      '| Patch | Source action | Source case | Group | Type | Priority | Target surface | Metadata-only | Future validation | Recommendation |',
    )
    ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |');
  for (final patch in patches) {
    buffer.writeln(
      '| ${patch.patchId} | ${patch.sourceActionId} | ${patch.sourceCaseId} | ${patch.patchGroup} | ${patch.patchType} | ${patch.patchPriority} | ${patch.targetSurface} | ${patch.appliedAsMetadataOnly} | ${patch.requiresFutureValidation} | ${patch.recommendation} |',
    );
  }
  buffer.writeln();
}

void _writePatchGroup(
  StringBuffer buffer,
  String title,
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord>
  patches,
) {
  buffer
    ..writeln('## $title')
    ..writeln(
      '| Patch | Source case | Target surface | Allowed now | Proof limits | Blocked boundaries | Denied fields |',
    )
    ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
  for (final patch in patches) {
    buffer.writeln(
      '| ${patch.patchId} | ${patch.sourceCaseId} | ${patch.targetSurface} | ${patch.implementationAllowedNow} | ${_ids(patch.proofLimitReasons)} | ${_ids(patch.blockedBoundaryIds)} | ${_ids(patch.deniedFieldIds)} |',
    );
  }
  buffer.writeln();
}

bool _includeSection(
  DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection selected,
  DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection target,
) {
  return selected ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection
              .all ||
      selected == target;
}

bool _isQuietPatch(
  DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord patch,
) {
  return patch.supportAreaIds.contains('quietMove') ||
      patch.supportAreaIds.contains('quietPreparatoryMove') ||
      patch.sourceCaseId.contains('quiet-preparatory');
}

bool _enablesBoundary(
  DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord patch,
  Set<String> boundaryIds,
) {
  return !patch.appliedAsMetadataOnly &&
      patch.blockedBoundaryIds.any(boundaryIds.contains);
}

Iterable<String> _activeDeniedFieldIds(
  DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord patch,
) {
  if (patch.appliedAsMetadataOnly &&
      !_forbiddenTargetSurfaces.contains(patch.targetSurface)) {
    return const <String>[];
  }
  return patch.deniedFieldIds;
}

int _countActiveFields(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord>
  patches,
  Set<String> fields,
) {
  var count = 0;
  for (final patch in patches) {
    count += _activeDeniedFieldIds(patch).where(fields.contains).length;
  }
  return count;
}

int _countEnabledBoundary(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord>
  patches,
  Set<String> fields,
) {
  return patches
      .where(
        (patch) =>
            !patch.appliedAsMetadataOnly &&
            patch.blockedBoundaryIds.any(fields.contains),
      )
      .length;
}

int _countForbiddenSurface(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord>
  patches,
  Set<String> surfaces,
) {
  return patches
      .where((patch) => surfaces.contains(patch.targetSurface))
      .length;
}

int _countGroup(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord>
  patches,
  String group,
) {
  return patches.where((patch) => patch.patchGroup == group).length;
}

String _idSuffix(String value) {
  return value.startsWith('action-')
      ? value.substring('action-'.length)
      : value;
}

String _ids(Iterable<String> values) {
  final sorted = _sorted(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

List<String> _sorted(Iterable<String> values) {
  return values.where((value) => value.trim().isNotEmpty).toSet().toList()
    ..sort();
}

const _phase34DRecommendation =
    'runAnalyzerAdapterPrototypeActionPlanPatchSetDiagnostic';

const _safeInternalSupportActions = 'safeInternalSupportActions';
const _warningLimitedFollowupActions = 'warningLimitedFollowupActions';
const _proofBoundaryActions = 'proofBoundaryActions';
const _excludedGuardActions = 'excludedGuardActions';
const _deniedFieldProtectionActions = 'deniedFieldProtectionActions';
const _prototypeSkeletonImprovementActions =
    'prototypeSkeletonImprovementActions';
const _diagnosticCoverageActions = 'diagnosticCoverageActions';
const _futureRuntimePrerequisiteActions = 'futureRuntimePrerequisiteActions';
const _blockedIntegrationActions = 'blockedIntegrationActions';
const _phase34CRequirementActions = 'phase34CRequirementActions';

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

const _patchesSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection.patches;
const _supportSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection.support;
const _warningSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection.warning;
const _proofSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection.proof;
const _guardsSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection.guards;
const _deniedSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection.denied;
const _blockedSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection.blocked;
const _recommendationSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection
        .recommendation;

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

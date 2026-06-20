import 'dart:convert';

import 'debug_only_bridge_analyzer_adapter_prototype_skeleton.dart';
import 'debug_only_bridge_analyzer_adapter_prototype_skeleton_validation.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportVersion =
    'debug-only-bridge-analyzer-adapter-prototype-inspection-harness-v1';
const debugOnlyBridgeAnalyzerAdapterPrototypeInspectionSnapshotVersion =
    'phase33w-analyzer-adapter-prototype-inspection-snapshot-v1';

enum DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionStatus {
  prototypeInspectionReadyWithWarnings('prototypeInspectionReadyWithWarnings'),
  prototypeInspectionReadyClean('prototypeInspectionReadyClean'),
  blockedByUnsafeSkeletonValidation('blockedByUnsafeSkeletonValidation'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidPrototypeInspection('invalidPrototypeInspection');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionStatus(this.wire);

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole {
  inputPacketInspection('inputPacketInspection'),
  contextPacketInspection('contextPacketInspection'),
  policyInspection('policyInspection'),
  internalInputRecordInspection('internalInputRecordInspection'),
  contextOnlyRecordInspection('contextOnlyRecordInspection'),
  warningLimitedRecordInspection('warningLimitedRecordInspection'),
  proofBoundaryRecordInspection('proofBoundaryRecordInspection'),
  excludedGuardRecordInspection('excludedGuardRecordInspection'),
  allowedFieldBoundaryInspection('allowedFieldBoundaryInspection'),
  deniedFieldBoundaryInspection('deniedFieldBoundaryInspection'),
  mapperMetadataInspection('mapperMetadataInspection'),
  validatorMetadataInspection('validatorMetadataInspection'),
  debugSnapshotMetadataInspection('debugSnapshotMetadataInspection'),
  runtimeBlockedInspection('runtimeBlockedInspection'),
  analyzerWiringBlockedInspection('analyzerWiringBlockedInspection'),
  engineBlockedInspection('engineBlockedInspection'),
  schedulerBlockedInspection('schedulerBlockedInspection'),
  productAdapterBlockedInspection('productAdapterBlockedInspection'),
  savedAnalysisBlockedInspection('savedAnalysisBlockedInspection'),
  androidProofBoundaryInspection('androidProofBoundaryInspection'),
  ownerProofBoundaryInspection('ownerProofBoundaryInspection'),
  reportSafetyInspection('reportSafetyInspection'),
  futureRequirementInspection('futureRequirementInspection');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole(this.wire);

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowStatus {
  inspected('inspected'),
  inspectedWithWarnings('inspectedWithWarnings'),
  blockedByBoundary('blockedByBoundary'),
  invalid('invalid');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == blockedByBoundary || this == invalid;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionSnapshot {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionSnapshot({
    required this.snapshotId,
    required this.sourceValidationStatus,
    required this.sourceSkeletonStatus,
    required this.inputPacketId,
    required this.contextPacketId,
    required this.skeletonVersion,
    required this.packetSummary,
    required this.policySummary,
    required this.recordRoleSummary,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.androidProofCaseIds,
    required this.ownerProofQueueCount,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.blockedBoundaryIds,
    required this.safeForDeveloperInspection,
    required this.recommendation,
    this.developerOnly = true,
    this.inMemoryOnly = true,
    this.analyzerUnwired = true,
  });

  final String snapshotId;
  final String sourceValidationStatus;
  final String sourceSkeletonStatus;
  final String inputPacketId;
  final String contextPacketId;
  final String skeletonVersion;
  final Map<String, Object?> packetSummary;
  final Map<String, Object?> policySummary;
  final Map<String, int> recordRoleSummary;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final List<String> androidProofCaseIds;
  final int ownerProofQueueCount;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> blockedBoundaryIds;
  final bool safeForDeveloperInspection;
  final String recommendation;
  final bool developerOnly;
  final bool inMemoryOnly;
  final bool analyzerUnwired;

  bool get hasUnsafeSnapshot =>
      !developerOnly ||
      !inMemoryOnly ||
      !analyzerUnwired ||
      !safeForDeveloperInspection ||
      allowedFieldIds.any(_isDeniedFieldId);

  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionSnapshot copyWith({
    String? snapshotId,
    String? sourceValidationStatus,
    String? sourceSkeletonStatus,
    String? inputPacketId,
    String? contextPacketId,
    String? skeletonVersion,
    Map<String, Object?>? packetSummary,
    Map<String, Object?>? policySummary,
    Map<String, int>? recordRoleSummary,
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    List<String>? androidProofCaseIds,
    int? ownerProofQueueCount,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? blockedBoundaryIds,
    bool? safeForDeveloperInspection,
    String? recommendation,
    bool? developerOnly,
    bool? inMemoryOnly,
    bool? analyzerUnwired,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionSnapshot(
      snapshotId: snapshotId ?? this.snapshotId,
      sourceValidationStatus:
          sourceValidationStatus ?? this.sourceValidationStatus,
      sourceSkeletonStatus: sourceSkeletonStatus ?? this.sourceSkeletonStatus,
      inputPacketId: inputPacketId ?? this.inputPacketId,
      contextPacketId: contextPacketId ?? this.contextPacketId,
      skeletonVersion: skeletonVersion ?? this.skeletonVersion,
      packetSummary: packetSummary ?? this.packetSummary,
      policySummary: policySummary ?? this.policySummary,
      recordRoleSummary: recordRoleSummary ?? this.recordRoleSummary,
      allowedFieldIds: allowedFieldIds ?? this.allowedFieldIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      safeForDeveloperInspection:
          safeForDeveloperInspection ?? this.safeForDeveloperInspection,
      recommendation: recommendation ?? this.recommendation,
      developerOnly: developerOnly ?? this.developerOnly,
      inMemoryOnly: inMemoryOnly ?? this.inMemoryOnly,
      analyzerUnwired: analyzerUnwired ?? this.analyzerUnwired,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'snapshotId': snapshotId,
      'sourceValidationStatus': sourceValidationStatus,
      'sourceSkeletonStatus': sourceSkeletonStatus,
      'inputPacketId': inputPacketId,
      'contextPacketId': contextPacketId,
      'skeletonVersion': skeletonVersion,
      'packetSummary': packetSummary,
      'policySummary': policySummary,
      'recordRoleSummary': recordRoleSummary,
      'allowedFieldIds': allowedFieldIds,
      'deniedFieldIds': deniedFieldIds,
      'androidProofCaseIds': androidProofCaseIds,
      'ownerProofQueueCount': ownerProofQueueCount,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'blockedBoundaryIds': blockedBoundaryIds,
      'safeForDeveloperInspection': safeForDeveloperInspection,
      'recommendation': recommendation,
      'developerOnly': developerOnly,
      'inMemoryOnly': inMemoryOnly,
      'analyzerUnwired': analyzerUnwired,
      'hasUnsafeSnapshot': hasUnsafeSnapshot,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow({
    required this.inspectionRowId,
    required this.sourceRecordId,
    required this.sourceCaseId,
    required this.sourcePhase,
    required this.sourceRole,
    required this.role,
    required this.status,
    required this.developerOnly,
    required this.inMemoryOnly,
    required this.analyzerUnwired,
    required this.contextOnly,
    required this.warningLimited,
    required this.proofBoundaryOnly,
    required this.excludedGuard,
    required this.inactive,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.androidProofCaseIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.blockedBoundaryIds,
    required this.activeDeniedFieldIds,
    required this.findings,
    required this.recommendation,
  });

  final String inspectionRowId;
  final String sourceRecordId;
  final String sourceCaseId;
  final String sourcePhase;
  final String sourceRole;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole role;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowStatus status;
  final bool developerOnly;
  final bool inMemoryOnly;
  final bool analyzerUnwired;
  final bool contextOnly;
  final bool warningLimited;
  final bool proofBoundaryOnly;
  final bool excludedGuard;
  final bool inactive;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final List<String> androidProofCaseIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> blockedBoundaryIds;
  final List<String> activeDeniedFieldIds;
  final List<String> findings;
  final String recommendation;

  bool get hasUnsafeOutput =>
      status.isUnsafe ||
      !developerOnly ||
      !inMemoryOnly ||
      !analyzerUnwired ||
      activeDeniedFieldIds.isNotEmpty ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      findings.isNotEmpty;

  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow copyWith({
    String? inspectionRowId,
    String? sourceRecordId,
    String? sourceCaseId,
    String? sourcePhase,
    String? sourceRole,
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole? role,
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowStatus? status,
    bool? developerOnly,
    bool? inMemoryOnly,
    bool? analyzerUnwired,
    bool? contextOnly,
    bool? warningLimited,
    bool? proofBoundaryOnly,
    bool? excludedGuard,
    bool? inactive,
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    List<String>? androidProofCaseIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? blockedBoundaryIds,
    List<String>? activeDeniedFieldIds,
    List<String>? findings,
    String? recommendation,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow(
      inspectionRowId: inspectionRowId ?? this.inspectionRowId,
      sourceRecordId: sourceRecordId ?? this.sourceRecordId,
      sourceCaseId: sourceCaseId ?? this.sourceCaseId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      sourceRole: sourceRole ?? this.sourceRole,
      role: role ?? this.role,
      status: status ?? this.status,
      developerOnly: developerOnly ?? this.developerOnly,
      inMemoryOnly: inMemoryOnly ?? this.inMemoryOnly,
      analyzerUnwired: analyzerUnwired ?? this.analyzerUnwired,
      contextOnly: contextOnly ?? this.contextOnly,
      warningLimited: warningLimited ?? this.warningLimited,
      proofBoundaryOnly: proofBoundaryOnly ?? this.proofBoundaryOnly,
      excludedGuard: excludedGuard ?? this.excludedGuard,
      inactive: inactive ?? this.inactive,
      allowedFieldIds: allowedFieldIds ?? this.allowedFieldIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      activeDeniedFieldIds: activeDeniedFieldIds ?? this.activeDeniedFieldIds,
      findings: findings ?? this.findings,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'inspectionRowId': inspectionRowId,
      'sourceRecordId': sourceRecordId,
      'sourceCaseId': sourceCaseId,
      'sourcePhase': sourcePhase,
      'sourceRole': sourceRole,
      'role': role.wire,
      'status': status.wire,
      'developerOnly': developerOnly,
      'inMemoryOnly': inMemoryOnly,
      'analyzerUnwired': analyzerUnwired,
      'contextOnly': contextOnly,
      'warningLimited': warningLimited,
      'proofBoundaryOnly': proofBoundaryOnly,
      'excludedGuard': excludedGuard,
      'inactive': inactive,
      'allowedFieldIds': allowedFieldIds,
      'deniedFieldIds': deniedFieldIds,
      'androidProofCaseIds': androidProofCaseIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'blockedBoundaryIds': blockedBoundaryIds,
      'activeDeniedFieldIds': activeDeniedFieldIds,
      'findings': findings,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult {
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult({
    required this.status,
    required this.sourceValidationStatus,
    required this.sourceValidationSafeForPhase33W,
    required this.sourceValidationRecommendation,
    required this.sourceSkeletonStatus,
    required this.sourceSkeletonSafeForPhase33V,
    required this.sourceSkeletonRecommendation,
    required this.snapshot,
    required this.inspectionRows,
    required this.reportFindings,
    required this.safeForPhase33X,
    required this.phase33XRecommendation,
  }) : totalInspectionRows = inspectionRows.length,
       inputPacketInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .inputPacketInspection,
       ),
       contextPacketInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .contextPacketInspection,
       ),
       policyInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .policyInspection,
       ),
       internalInputRecordInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .internalInputRecordInspection,
       ),
       contextOnlyRecordInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .contextOnlyRecordInspection,
       ),
       warningLimitedRecordInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .warningLimitedRecordInspection,
       ),
       proofBoundaryRecordInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .proofBoundaryRecordInspection,
       ),
       excludedGuardRecordInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .excludedGuardRecordInspection,
       ),
       allowedFieldBoundaryInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .allowedFieldBoundaryInspection,
       ),
       deniedFieldBoundaryInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .deniedFieldBoundaryInspection,
       ),
       mapperMetadataInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .mapperMetadataInspection,
       ),
       validatorMetadataInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .validatorMetadataInspection,
       ),
       debugSnapshotMetadataInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .debugSnapshotMetadataInspection,
       ),
       runtimeBlockedInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .runtimeBlockedInspection,
       ),
       analyzerWiringBlockedInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .analyzerWiringBlockedInspection,
       ),
       engineBlockedInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .engineBlockedInspection,
       ),
       schedulerBlockedInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .schedulerBlockedInspection,
       ),
       productAdapterBlockedInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .productAdapterBlockedInspection,
       ),
       savedAnalysisBlockedInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .savedAnalysisBlockedInspection,
       ),
       androidProofBoundaryInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .androidProofBoundaryInspection,
       ),
       ownerProofBoundaryInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .ownerProofBoundaryInspection,
       ),
       reportSafetyInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .reportSafetyInspection,
       ),
       futureRequirementInspectionCount = _countRole(
         inspectionRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
             .futureRequirementInspection,
       ),
       blockerCount = inspectionRows
           .where((row) => row.status.isUnsafe || row.findings.isNotEmpty)
           .length,
       criticalCount = reportFindings.where(_isCriticalFinding).length,
       activeDeniedFieldCount = inspectionRows.fold<int>(
         0,
         (total, row) => total + row.activeDeniedFieldIds.length,
       ),
       productOutputCount = _countFinding(inspectionRows, 'productOutput'),
       labelLeakCount = _countFinding(inspectionRows, 'classifierLabelLeak'),
       finalLabelLeakCount = _countFinding(inspectionRows, 'finalLabelLeak'),
       scoreLeakCount =
           _countFinding(inspectionRows, 'numericScoreLeak') +
           _countFinding(inspectionRows, 'aggregateScoreLeak'),
       metricLeakCount = _countFinding(inspectionRows, 'officialMetricLeak'),
       cpLossLeakCount = _countFinding(inspectionRows, 'cpLossLeak'),
       winProbabilityLeakCount = _countFinding(
         inspectionRows,
         'winProbabilityLeak',
       ),
       moveRankingLeakCount = _countFinding(inspectionRows, 'moveRankingLeak'),
       thresholdLeakCount =
           _countFinding(inspectionRows, 'thresholdLeak') +
           _countActiveDeniedField(inspectionRows, 'thresholds'),
       uiTargetCount = _countFinding(inspectionRows, 'uiTarget'),
       backendTargetCount = _countFinding(inspectionRows, 'backendTarget'),
       persistenceWriteCount = _countFinding(
         inspectionRows,
         'persistenceWrite',
       ),
       engineCallCount = _countFinding(inspectionRows, 'engineCall'),
       schedulerExecutionCount = _countFinding(
         inspectionRows,
         'schedulerExecution',
       ),
       analyzerWiringCount =
           _countFinding(inspectionRows, 'analyzerWiring') +
           _countFinding(inspectionRows, 'analyzerWiringEnabled'),
       runtimeImplementationCount = _countFinding(
         inspectionRows,
         'runtimeImplementation',
       ),
       executablePrototypeCount = _countFinding(
         inspectionRows,
         'executablePrototypeImplementation',
       ),
       productAdapterBehaviorCount =
           _countFinding(inspectionRows, 'productAdapterBehavior') +
           _countActiveDeniedField(inspectionRows, 'productAdapterBehavior'),
       savedAnalysisIntegrationCount =
           _countFinding(inspectionRows, 'savedAnalysisIntegration') +
           _countActiveDeniedField(inspectionRows, 'savedAnalysisIntegration'),
       stockfishCommandLeakCount = _countFinding(
         inspectionRows,
         'stockfishCommandLeak',
       ),
       rawUciLeakCount = _countFinding(inspectionRows, 'rawUciLeak'),
       pvDumpLeakCount = _countFinding(inspectionRows, 'pvDumpLeak'),
       androidCollectorRequirementCount = _countFinding(
         inspectionRows,
         'androidCollectorRequired',
       ),
       unprovenAndroidProofCount = _countFinding(
         inspectionRows,
         'unprovenAndroidProofId',
       ),
       phase32EProofClaimCount = _countFinding(
         inspectionRows,
         'phase32ECapturedAndroidProofClaim',
       ),
       ownerProofQueueCount = inspectionRows
           .where(
             (row) =>
                 row.role ==
                     DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                         .ownerProofBoundaryInspection &&
                 row.activeDeniedFieldIds.isNotEmpty,
           )
           .length {
    unsafeCount =
        (snapshot.hasUnsafeSnapshot ? 1 : 0) +
        inspectionRows.where((row) => row.hasUnsafeOutput).length +
        activeDeniedFieldCount +
        productOutputCount +
        labelLeakCount +
        finalLabelLeakCount +
        scoreLeakCount +
        metricLeakCount +
        cpLossLeakCount +
        winProbabilityLeakCount +
        moveRankingLeakCount +
        thresholdLeakCount +
        uiTargetCount +
        backendTargetCount +
        persistenceWriteCount +
        engineCallCount +
        schedulerExecutionCount +
        analyzerWiringCount +
        runtimeImplementationCount +
        executablePrototypeCount +
        productAdapterBehaviorCount +
        savedAnalysisIntegrationCount +
        stockfishCommandLeakCount +
        rawUciLeakCount +
        pvDumpLeakCount +
        androidCollectorRequirementCount +
        unprovenAndroidProofCount +
        phase32EProofClaimCount +
        ownerProofQueueCount;
  }

  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionStatus status;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationStatus
  sourceValidationStatus;
  final bool sourceValidationSafeForPhase33W;
  final String sourceValidationRecommendation;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonStatus
  sourceSkeletonStatus;
  final bool sourceSkeletonSafeForPhase33V;
  final String sourceSkeletonRecommendation;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionSnapshot snapshot;
  final List<DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow>
  inspectionRows;
  final List<String> reportFindings;
  final bool safeForPhase33X;
  final String phase33XRecommendation;
  final int totalInspectionRows;
  final int inputPacketInspectionCount;
  final int contextPacketInspectionCount;
  final int policyInspectionCount;
  final int internalInputRecordInspectionCount;
  final int contextOnlyRecordInspectionCount;
  final int warningLimitedRecordInspectionCount;
  final int proofBoundaryRecordInspectionCount;
  final int excludedGuardRecordInspectionCount;
  final int allowedFieldBoundaryInspectionCount;
  final int deniedFieldBoundaryInspectionCount;
  final int mapperMetadataInspectionCount;
  final int validatorMetadataInspectionCount;
  final int debugSnapshotMetadataInspectionCount;
  final int runtimeBlockedInspectionCount;
  final int analyzerWiringBlockedInspectionCount;
  final int engineBlockedInspectionCount;
  final int schedulerBlockedInspectionCount;
  final int productAdapterBlockedInspectionCount;
  final int savedAnalysisBlockedInspectionCount;
  final int androidProofBoundaryInspectionCount;
  final int ownerProofBoundaryInspectionCount;
  final int reportSafetyInspectionCount;
  final int futureRequirementInspectionCount;
  late final int unsafeCount;
  final int blockerCount;
  final int criticalCount;
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
  final int unprovenAndroidProofCount;
  final int phase32EProofClaimCount;
  final int ownerProofQueueCount;

  bool get hasUnsafePolicyViolation =>
      blockerCount > 0 ||
      criticalCount > 0 ||
      unsafeCount > 0 ||
      !safeForPhase33X ||
      !sourceValidationSafeForPhase33W ||
      !sourceSkeletonSafeForPhase33V;

  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow rowForRole(
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole role,
  ) {
    return inspectionRows.firstWhere((row) => row.role == role);
  }

  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult copyWith({
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionStatus? status,
    DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationStatus?
    sourceValidationStatus,
    bool? sourceValidationSafeForPhase33W,
    String? sourceValidationRecommendation,
    DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonStatus? sourceSkeletonStatus,
    bool? sourceSkeletonSafeForPhase33V,
    String? sourceSkeletonRecommendation,
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionSnapshot? snapshot,
    List<DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow>? inspectionRows,
    List<String>? reportFindings,
    bool? safeForPhase33X,
    String? phase33XRecommendation,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult(
      status: status ?? this.status,
      sourceValidationStatus:
          sourceValidationStatus ?? this.sourceValidationStatus,
      sourceValidationSafeForPhase33W:
          sourceValidationSafeForPhase33W ??
          this.sourceValidationSafeForPhase33W,
      sourceValidationRecommendation:
          sourceValidationRecommendation ?? this.sourceValidationRecommendation,
      sourceSkeletonStatus: sourceSkeletonStatus ?? this.sourceSkeletonStatus,
      sourceSkeletonSafeForPhase33V:
          sourceSkeletonSafeForPhase33V ?? this.sourceSkeletonSafeForPhase33V,
      sourceSkeletonRecommendation:
          sourceSkeletonRecommendation ?? this.sourceSkeletonRecommendation,
      snapshot: snapshot ?? this.snapshot,
      inspectionRows: inspectionRows ?? this.inspectionRows,
      reportFindings: reportFindings ?? this.reportFindings,
      safeForPhase33X: safeForPhase33X ?? this.safeForPhase33X,
      phase33XRecommendation:
          phase33XRecommendation ?? this.phase33XRecommendation,
    );
  }

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln(
        '# Debug-Only Bridge Analyzer Adapter Prototype Inspection Harness',
      )
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportVersion',
      )
      ..writeln('- inspection status: ${status.wire}')
      ..writeln('- source validation status: ${sourceValidationStatus.wire}')
      ..writeln('- source skeleton status: ${sourceSkeletonStatus.wire}')
      ..writeln('- safe for Phase 33X: $safeForPhase33X')
      ..writeln('- Phase 33X recommendation: $phase33XRecommendation')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- analyzer wiring count: $analyzerWiringCount')
      ..writeln('- runtime implementation count: $runtimeImplementationCount')
      ..writeln('- executable prototype count: $executablePrototypeCount')
      ..writeln('- engine call count: $engineCallCount')
      ..writeln('- scheduler execution count: $schedulerExecutionCount')
      ..writeln('- persistence write count: $persistenceWriteCount')
      ..writeln('- product output count: $productOutputCount')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln()
      ..writeln('## Inspection Snapshot Summary')
      ..writeln('- snapshot ID: ${snapshot.snapshotId}')
      ..writeln('- skeleton version: ${snapshot.skeletonVersion}')
      ..writeln(
        '- safe for developer inspection: '
        '${snapshot.safeForDeveloperInspection}',
      )
      ..writeln('- developer only: ${snapshot.developerOnly}')
      ..writeln('- in memory only: ${snapshot.inMemoryOnly}')
      ..writeln('- analyzer unwired: ${snapshot.analyzerUnwired}')
      ..writeln()
      ..writeln('## Packet Inspection Summary')
      ..writeln('- input packet ID: ${snapshot.inputPacketId}')
      ..writeln('- context packet ID: ${snapshot.contextPacketId}')
      ..writeln('- input packet inspections: $inputPacketInspectionCount')
      ..writeln('- context packet inspections: $contextPacketInspectionCount')
      ..writeln()
      ..writeln('## Policy Inspection Summary')
      ..writeln('- policy inspections: $policyInspectionCount')
      ..writeln(
        '- unsafe policy allowance: '
        '${snapshot.policySummary['hasUnsafeAllowance']}',
      )
      ..writeln(
        '- product output allowed: ${snapshot.policySummary['allowsProductOutput']}',
      )
      ..writeln(
        '- analyzer wiring allowed: ${snapshot.policySummary['allowsAnalyzerWiring']}',
      )
      ..writeln(
        '- runtime allowed: ${snapshot.policySummary['allowsRuntimeImplementation']}',
      )
      ..writeln(
        '- engine calls allowed: ${snapshot.policySummary['allowsEngineCalls']}',
      )
      ..writeln(
        '- scheduler execution allowed: ${snapshot.policySummary['allowsSchedulerExecution']}',
      )
      ..writeln()
      ..writeln('## Record Role Inspection Summary')
      ..writeln('| Role | Count |')
      ..writeln('| --- | --- |');
    for (final entry in snapshot.recordRoleSummary.entries) {
      buffer.writeln('| ${entry.key} | ${entry.value} |');
    }
    buffer
      ..writeln()
      ..writeln('## Inspection Row Table')
      ..writeln(
        '| Row | Source | Case ID | Source role | Inspection role | Status | Developer only | In memory | Analyzer unwired | Inactive | Findings |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in inspectionRows) {
      buffer.writeln(
        '| ${row.inspectionRowId} | ${row.sourceRecordId} | '
        '${row.sourceCaseId} | ${row.sourceRole} | ${row.role.wire} | '
        '${row.status.wire} | ${row.developerOnly} | ${row.inMemoryOnly} | '
        '${row.analyzerUnwired} | ${row.inactive} | ${_ids(row.findings)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Allowed Denied Field Inspection')
      ..writeln('- allowed fields: ${_ids(snapshot.allowedFieldIds)}')
      ..writeln('- denied fields: ${_ids(snapshot.deniedFieldIds)}')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- Stockfish command leak count: $stockfishCommandLeakCount')
      ..writeln('- raw UCI leak count: $rawUciLeakCount')
      ..writeln('- PV dump leak count: $pvDumpLeakCount')
      ..writeln()
      ..writeln('## Proof Boundary Inspection')
      ..writeln(
        '- captured Android proof IDs: ${_ids(snapshot.androidProofCaseIds)}',
      )
      ..writeln('- unproven Android proof count: $unprovenAndroidProofCount')
      ..writeln('- Phase 32E proof claim count: $phase32EProofClaimCount')
      ..writeln()
      ..writeln('## Owner Proof Inspection')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln(
        '## Runtime Analyzer Engine Scheduler Product Saved-Analysis Inspection',
      )
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
      ..writeln('## Report Safety Inspection')
      ..writeln('- report safety inspections: $reportSafetyInspectionCount')
      ..writeln('- report findings: ${_ids(reportFindings)}')
      ..writeln()
      ..writeln('## Phase 33X Recommendation')
      ..writeln('- safe for Phase 33X: $safeForPhase33X')
      ..writeln('- recommendation: $phase33XRecommendation');
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportVersion,
      'snapshotVersion':
          debugOnlyBridgeAnalyzerAdapterPrototypeInspectionSnapshotVersion,
      'inspectionStatus': status.wire,
      'sourceValidationStatus': sourceValidationStatus.wire,
      'sourceValidationSafeForPhase33W': sourceValidationSafeForPhase33W,
      'sourceValidationRecommendation': sourceValidationRecommendation,
      'sourceSkeletonStatus': sourceSkeletonStatus.wire,
      'sourceSkeletonSafeForPhase33V': sourceSkeletonSafeForPhase33V,
      'sourceSkeletonRecommendation': sourceSkeletonRecommendation,
      'safeForPhase33X': safeForPhase33X,
      'phase33XRecommendation': phase33XRecommendation,
      'counts': <String, Object?>{
        'totalInspectionRows': totalInspectionRows,
        'inputPacketInspectionCount': inputPacketInspectionCount,
        'contextPacketInspectionCount': contextPacketInspectionCount,
        'policyInspectionCount': policyInspectionCount,
        'internalInputRecordInspectionCount':
            internalInputRecordInspectionCount,
        'contextOnlyRecordInspectionCount': contextOnlyRecordInspectionCount,
        'warningLimitedRecordInspectionCount':
            warningLimitedRecordInspectionCount,
        'proofBoundaryRecordInspectionCount':
            proofBoundaryRecordInspectionCount,
        'excludedGuardRecordInspectionCount':
            excludedGuardRecordInspectionCount,
        'allowedFieldBoundaryInspectionCount':
            allowedFieldBoundaryInspectionCount,
        'deniedFieldBoundaryInspectionCount':
            deniedFieldBoundaryInspectionCount,
        'mapperMetadataInspectionCount': mapperMetadataInspectionCount,
        'validatorMetadataInspectionCount': validatorMetadataInspectionCount,
        'debugSnapshotMetadataInspectionCount':
            debugSnapshotMetadataInspectionCount,
        'runtimeBlockedInspectionCount': runtimeBlockedInspectionCount,
        'analyzerWiringBlockedInspectionCount':
            analyzerWiringBlockedInspectionCount,
        'engineBlockedInspectionCount': engineBlockedInspectionCount,
        'schedulerBlockedInspectionCount': schedulerBlockedInspectionCount,
        'productAdapterBlockedInspectionCount':
            productAdapterBlockedInspectionCount,
        'savedAnalysisBlockedInspectionCount':
            savedAnalysisBlockedInspectionCount,
        'androidProofBoundaryInspectionCount':
            androidProofBoundaryInspectionCount,
        'ownerProofBoundaryInspectionCount': ownerProofBoundaryInspectionCount,
        'reportSafetyInspectionCount': reportSafetyInspectionCount,
        'futureRequirementInspectionCount': futureRequirementInspectionCount,
        'unsafeCount': unsafeCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'activeDeniedFieldCount': activeDeniedFieldCount,
        'productOutputCount': productOutputCount,
        'labelLeakCount': labelLeakCount,
        'finalLabelLeakCount': finalLabelLeakCount,
        'scoreLeakCount': scoreLeakCount,
        'metricLeakCount': metricLeakCount,
        'cpLossLeakCount': cpLossLeakCount,
        'winProbabilityLeakCount': winProbabilityLeakCount,
        'moveRankingLeakCount': moveRankingLeakCount,
        'thresholdLeakCount': thresholdLeakCount,
        'uiTargetCount': uiTargetCount,
        'backendTargetCount': backendTargetCount,
        'persistenceWriteCount': persistenceWriteCount,
        'engineCallCount': engineCallCount,
        'schedulerExecutionCount': schedulerExecutionCount,
        'analyzerWiringCount': analyzerWiringCount,
        'runtimeImplementationCount': runtimeImplementationCount,
        'executablePrototypeCount': executablePrototypeCount,
        'productAdapterBehaviorCount': productAdapterBehaviorCount,
        'savedAnalysisIntegrationCount': savedAnalysisIntegrationCount,
        'stockfishCommandLeakCount': stockfishCommandLeakCount,
        'rawUciLeakCount': rawUciLeakCount,
        'pvDumpLeakCount': pvDumpLeakCount,
        'androidCollectorRequirementCount': androidCollectorRequirementCount,
        'unprovenAndroidProofCount': unprovenAndroidProofCount,
        'phase32EProofClaimCount': phase32EProofClaimCount,
        'ownerProofQueueCount': ownerProofQueueCount,
      },
      'snapshot': snapshot.toJson(),
      'inspectionRows': inspectionRows.map((row) => row.toJson()).toList(),
      'reportFindings': reportFindings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness({
    this.skeletonMapper = const DebugOnlyBridgeAnalyzerAdapterPrototypeMapper(),
    this.validation =
        const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidation(),
    this.validator =
        const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionValidator(),
  });

  final DebugOnlyBridgeAnalyzerAdapterPrototypeMapper skeletonMapper;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidation validation;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionValidator validator;

  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult inspectSafeDemo() {
    return evaluate();
  }

  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult evaluate({
    DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationResult?
    validationResult,
    DebugOnlyBridgeAnalyzerAdapterPrototypeResult? skeletonResult,
  }) {
    final skeleton = skeletonResult ?? skeletonMapper.evaluate();
    final sourceValidation =
        validationResult ?? validation.evaluate(skeletonResult: skeleton);
    final sourceSafe =
        sourceValidation.safeForPhase33W &&
        sourceValidation.phase33WRecommendation == _phase33WRecommendation &&
        !sourceValidation.hasUnsafePolicyViolation &&
        skeleton.safeForPhase33V &&
        skeleton.phase33VRecommendation == _phase33VRequirement &&
        !skeleton.hasUnsafePolicyViolation;

    final initialRows = <DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow>[
      _rowFromInputPacket(skeleton),
      _rowFromContextPacket(skeleton),
      _rowFromPolicy(skeleton),
      ...skeleton.records.map(_rowFromRecord),
      _rowFromProofBoundary(skeleton),
      _rowFromOwnerProof(skeleton),
      _rowFromReport(skeleton, sourceValidation),
      _futureRequirementRow(),
    ];
    final rows = initialRows
        .map(
          (row) => _rowWithStatus(
            row.copyWith(findings: validator.validateRow(row)),
          ),
        )
        .toList(growable: false);

    final snapshot = _snapshotFrom(skeleton, sourceValidation);
    final reportFindings = validator.validateReportText(
      [
        skeleton.renderMarkdown(),
        sourceValidation.renderMarkdown(),
        _renderRowsForLeakCheck(rows),
      ].join('\n'),
    );
    final hasRowFindings = rows.any((row) => row.findings.isNotEmpty);
    final hasFutureRequirement = rows.any(
      (row) =>
          row.role ==
              DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                  .futureRequirementInspection &&
          row.recommendation == _phase33XRecommendation,
    );
    final safe =
        sourceSafe &&
        hasFutureRequirement &&
        !snapshot.hasUnsafeSnapshot &&
        !hasRowFindings &&
        reportFindings.isEmpty;
    final status = !sourceSafe
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionStatus
              .blockedByUnsafeSkeletonValidation
        : !hasFutureRequirement
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionStatus
              .invalidPrototypeInspection
        : hasRowFindings || reportFindings.isNotEmpty
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionStatus
              .blockedByPolicyBoundary
        : rows.any(
            (row) =>
                row.warningReasons.isNotEmpty ||
                row.proofLimitReasons.isNotEmpty,
          )
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionStatus
              .prototypeInspectionReadyWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionStatus
              .prototypeInspectionReadyClean;

    return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult(
      status: status,
      sourceValidationStatus: sourceValidation.status,
      sourceValidationSafeForPhase33W: sourceValidation.safeForPhase33W,
      sourceValidationRecommendation: sourceValidation.phase33WRecommendation,
      sourceSkeletonStatus: skeleton.status,
      sourceSkeletonSafeForPhase33V: skeleton.safeForPhase33V,
      sourceSkeletonRecommendation: skeleton.phase33VRecommendation,
      snapshot: snapshot.copyWith(safeForDeveloperInspection: safe),
      inspectionRows: rows,
      reportFindings: reportFindings,
      safeForPhase33X: safe,
      phase33XRecommendation: safe
          ? _phase33XRecommendation
          : 'blockedByUnsafeAnalyzerAdapterPrototypeInspectionHarness',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionValidator {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionValidator();

  List<String> validateResult(
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult result,
  ) {
    final findings = <String>[];
    if (!result.sourceValidationSafeForPhase33W && result.safeForPhase33X) {
      findings.add('unsafePhase33VValidationMarkedInspectionReady');
    }
    if (!result.sourceSkeletonSafeForPhase33V && result.safeForPhase33X) {
      findings.add('unsafePhase33USkeletonMarkedInspectionReady');
    }
    if (result.futureRequirementInspectionCount == 0) {
      findings.add('missingPhase33XRequirement');
    }
    if (result.snapshot.hasUnsafeSnapshot) {
      findings.add('unsafeInspectionSnapshot');
    }
    findings.addAll(validateReportText(result.renderMarkdown()));
    return findings..sort();
  }

  List<String> validateRow(
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow row,
  ) {
    final findings = <String>[];
    if (!_knownSourceRoles.contains(row.sourceRole)) {
      findings.add('unknownInspectionSourceRole');
    }
    if (!row.developerOnly || !row.inMemoryOnly) {
      findings.add('rowNotDeveloperOnlyInMemory');
    }
    if (!row.analyzerUnwired) findings.add('analyzerWiringEnabled');
    if (row.activeDeniedFieldIds.isNotEmpty) {
      findings.add('activeDeniedField');
      findings.addAll(_findingsForActiveDeniedFields(row.activeDeniedFieldIds));
    }
    if (row.allowedFieldIds.any(_isDeniedFieldId)) {
      findings.add('deniedFieldAllowedInternally');
    }
    if (!row.deniedFieldIds.toSet().containsAll(_deniedFieldIds)) {
      findings.add('missingRequiredDeniedField');
    }
    if (row.role ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                .contextOnlyRecordInspection &&
        !row.contextOnly) {
      findings.add('contextRecordNotContextOnly');
    }
    if (row.role ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                .warningLimitedRecordInspection &&
        !row.warningLimited) {
      findings.add('warningRecordNotWarningLimited');
    }
    if (row.role ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                .proofBoundaryRecordInspection &&
        !row.proofBoundaryOnly) {
      findings.add('proofBoundaryRecordPromoted');
    }
    if (row.role ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                .excludedGuardRecordInspection &&
        !row.excludedGuard) {
      findings.add('excludedGuardRecordPromoted');
    }
    if (_isInactiveInspection(row.role) && !row.inactive) {
      findings.add('inactiveBoundaryMadeActive');
    }
    if (_isQuietRow(row) &&
        row.role !=
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                .excludedGuardRecordInspection) {
      findings.add('quietPreparatoryPromoted');
    }
    if (row.sourceCaseId == _pvMultiPvBoundaryCaseId &&
        row.role !=
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                .proofBoundaryRecordInspection &&
        row.role !=
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                .contextOnlyRecordInspection) {
      findings.add('pvMultiPvPromotedBeyondBoundary');
    }
    if (_phase32ECaseIds.contains(row.sourceCaseId) &&
        row.androidProofCaseIds.isNotEmpty) {
      findings.add('phase32ECapturedAndroidProofClaim');
    }
    if (row.androidProofCaseIds.any(
      (caseId) => !_capturedAndroidProofIds.contains(caseId),
    )) {
      findings.add('unprovenAndroidProofId');
    }
    if (row.role ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                .ownerProofBoundaryInspection &&
        row.activeDeniedFieldIds.isNotEmpty) {
      findings.add('ownerProofQueueNotEmpty');
    }
    if (row.role ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                .ownerProofBoundaryInspection &&
        row.activeDeniedFieldIds.isNotEmpty &&
        !row.proofLimitReasons.any(
          (reason) => reason.toLowerCase().contains('pv'),
        )) {
      findings.add('ownerProofWithoutPvMultiPvReason');
    }
    if (row.role ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                .futureRequirementInspection &&
        row.recommendation != _phase33XRecommendation) {
      findings.add('missingPhase33XRequirement');
    }
    return _sorted(findings);
  }

  List<String> validateReportText(String reportText) {
    final lower = reportText.toLowerCase();
    return _rawReportLeakTokens
        .where((token) => lower.contains(token))
        .map((token) => 'reportTextLeak:$token')
        .toList(growable: false);
  }
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionSnapshot _snapshotFrom(
  DebugOnlyBridgeAnalyzerAdapterPrototypeResult skeleton,
  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationResult validation,
) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionSnapshot(
    snapshotId: 'phase33w-analyzer-adapter-prototype-inspection-snapshot',
    sourceValidationStatus: validation.status.wire,
    sourceSkeletonStatus: skeleton.status.wire,
    inputPacketId: skeleton.inputPacket.inputPacketId,
    contextPacketId: skeleton.contextPacket.contextPacketId,
    skeletonVersion: debugOnlyBridgeAnalyzerAdapterPrototypeSkeletonVersion,
    packetSummary: <String, Object?>{
      'inputPacketId': skeleton.inputPacket.inputPacketId,
      'contextPacketId': skeleton.contextPacket.contextPacketId,
      'internalInputRecordCount': skeleton.internalInputRecordCount,
      'contextOnlyRecordCount': skeleton.contextOnlyRecordCount,
      'warningLimitedRecordCount': skeleton.warningLimitedRecordCount,
      'proofBoundaryRecordCount': skeleton.proofBoundaryRecordCount,
      'excludedGuardRecordCount': skeleton.excludedGuardRecordCount,
    },
    policySummary: skeleton.policy.toJson(),
    recordRoleSummary: _roleCounts(skeleton.records),
    allowedFieldIds: _sorted(skeleton.policy.allowedFieldIds),
    deniedFieldIds: _sorted(skeleton.policy.deniedFieldIds),
    androidProofCaseIds: _sorted(skeleton.policy.capturedAndroidProofIds),
    ownerProofQueueCount: skeleton.ownerProofQueueCount,
    warningReasons: _sorted(
      skeleton.records.expand((record) => record.warningReasons),
    ),
    proofLimitReasons: _sorted(
      skeleton.records.expand((record) => record.proofLimitReasons),
    ),
    blockedBoundaryIds: _sorted(
      skeleton.records.expand((record) => record.blockedBoundaryIds),
    ),
    safeForDeveloperInspection: true,
    recommendation: _phase33XRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow _rowFromInputPacket(
  DebugOnlyBridgeAnalyzerAdapterPrototypeResult source,
) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow(
    inspectionRowId: 'phase33w-input-packet-inspection',
    sourceRecordId: source.inputPacket.inputPacketId,
    sourceCaseId: 'phase33u',
    sourcePhase: 'Phase 33U',
    sourceRole: 'inputPacket',
    role: DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
        .inputPacketInspection,
    status: DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowStatus
        .inspectedWithWarnings,
    developerOnly: source.inputPacket.developerOnly,
    inMemoryOnly: source.inputPacket.inMemoryOnly,
    analyzerUnwired: source.inputPacket.analyzerUnwired,
    contextOnly: false,
    warningLimited: false,
    proofBoundaryOnly: false,
    excludedGuard: false,
    inactive: false,
    allowedFieldIds: _sorted(source.inputPacket.allowedFieldIds),
    deniedFieldIds: _sorted(source.inputPacket.deniedFieldIds),
    androidProofCaseIds: _sorted(source.inputPacket.androidProofCaseIds),
    warningReasons: _sorted(source.inputPacket.warningReasons),
    proofLimitReasons: _sorted(source.inputPacket.proofLimitReasons),
    blockedBoundaryIds: _sorted(source.inputPacket.blockedBoundaryIds),
    activeDeniedFieldIds: source.inputPacket.hasUnsafeInput
        ? const <String>['unsafeInputPacket']
        : const <String>[],
    findings: const <String>[],
    recommendation: 'keepAnalyzerAdapterPrototypeInputPacketInternal',
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow _rowFromContextPacket(
  DebugOnlyBridgeAnalyzerAdapterPrototypeResult source,
) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow(
    inspectionRowId: 'phase33w-context-packet-inspection',
    sourceRecordId: source.contextPacket.contextPacketId,
    sourceCaseId: 'phase33u',
    sourcePhase: 'Phase 33U',
    sourceRole: 'contextPacket',
    role: DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
        .contextPacketInspection,
    status: DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowStatus
        .inspectedWithWarnings,
    developerOnly: source.contextPacket.developerOnly,
    inMemoryOnly: true,
    analyzerUnwired: source.contextPacket.analyzerUnwired,
    contextOnly: source.contextPacket.contextOnly,
    warningLimited: false,
    proofBoundaryOnly: false,
    excludedGuard: false,
    inactive: false,
    allowedFieldIds: const <String>[],
    deniedFieldIds: _deniedFieldIds,
    androidProofCaseIds: const <String>[],
    warningReasons: _sorted(source.contextPacket.warningReasons),
    proofLimitReasons: _sorted(source.contextPacket.proofLimitReasons),
    blockedBoundaryIds: _sorted(source.contextPacket.blockedBoundaryIds),
    activeDeniedFieldIds: const <String>[],
    findings: const <String>[],
    recommendation: 'keepAnalyzerAdapterPrototypeContextPacketContextOnly',
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow _rowFromPolicy(
  DebugOnlyBridgeAnalyzerAdapterPrototypeResult source,
) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow(
    inspectionRowId: 'phase33w-policy-inspection',
    sourceRecordId: 'phase33u-policy',
    sourceCaseId: 'phase33u',
    sourcePhase: 'Phase 33U',
    sourceRole: 'policy',
    role: DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
        .policyInspection,
    status:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowStatus.inspected,
    developerOnly: true,
    inMemoryOnly: true,
    analyzerUnwired: true,
    contextOnly: false,
    warningLimited: false,
    proofBoundaryOnly: false,
    excludedGuard: false,
    inactive: false,
    allowedFieldIds: _sorted(source.policy.allowedFieldIds),
    deniedFieldIds: _sorted(source.policy.deniedFieldIds),
    androidProofCaseIds: _sorted(source.policy.capturedAndroidProofIds),
    warningReasons: const <String>[],
    proofLimitReasons: const <String>[],
    blockedBoundaryIds: const <String>[
      'analyzerWiring',
      'engineCall',
      'productOutput',
      'runtimeImplementation',
      'schedulerExecution',
    ],
    activeDeniedFieldIds: source.policy.hasUnsafeAllowance
        ? const <String>['unsafePolicyAllowance']
        : const <String>[],
    findings: const <String>[],
    recommendation: 'keepAnalyzerAdapterPrototypePolicyDenied',
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow _rowFromRecord(
  DebugOnlyBridgeAnalyzerAdapterPrototypeRecord record,
) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow(
    inspectionRowId: 'phase33w-${record.recordId}',
    sourceRecordId: record.recordId,
    sourceCaseId: record.sourceCaseId,
    sourcePhase: record.sourcePhase,
    sourceRole: record.role.wire,
    role: _inspectionRoleForRecordRole(record.role),
    status: DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowStatus
        .inspectedWithWarnings,
    developerOnly: record.developerOnly,
    inMemoryOnly: record.inMemoryOnly,
    analyzerUnwired: record.analyzerUnwired,
    contextOnly: record.contextOnly,
    warningLimited: record.warningLimited,
    proofBoundaryOnly: record.proofBoundaryOnly,
    excludedGuard: record.excludedGuard,
    inactive: record.inactive,
    allowedFieldIds: _sorted(record.allowedFieldIds),
    deniedFieldIds: _sorted(record.deniedFieldIds),
    androidProofCaseIds: _sorted(record.androidProofCaseIds),
    warningReasons: _sorted(record.warningReasons),
    proofLimitReasons: _sorted(record.proofLimitReasons),
    blockedBoundaryIds: _sorted(record.blockedBoundaryIds),
    activeDeniedFieldIds: _sorted(record.activeDeniedFieldIds),
    findings: const <String>[],
    recommendation: _recommendationForRecordRole(record.role),
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow _rowFromProofBoundary(
  DebugOnlyBridgeAnalyzerAdapterPrototypeResult source,
) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow(
    inspectionRowId: 'phase33w-android-proof-boundary-inspection',
    sourceRecordId: 'phase33u-policy-captured-android-proof-boundary',
    sourceCaseId: 'phase33u',
    sourcePhase: 'Phase 33U',
    sourceRole: 'androidProofBoundary',
    role: DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
        .androidProofBoundaryInspection,
    status:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowStatus.inspected,
    developerOnly: true,
    inMemoryOnly: true,
    analyzerUnwired: true,
    contextOnly: false,
    warningLimited: false,
    proofBoundaryOnly: true,
    excludedGuard: false,
    inactive: false,
    allowedFieldIds: const <String>['androidProofBoundaryIds'],
    deniedFieldIds: _deniedFieldIds,
    androidProofCaseIds: _sorted(source.policy.capturedAndroidProofIds),
    warningReasons: const <String>[],
    proofLimitReasons: const <String>[],
    blockedBoundaryIds: const <String>[
      'androidCollectorExecution',
      'phase32ECapturedAndroidProofClaim',
    ],
    activeDeniedFieldIds: const <String>[],
    findings: const <String>[],
    recommendation: 'keepAndroidProofCapturedOnly',
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow _rowFromOwnerProof(
  DebugOnlyBridgeAnalyzerAdapterPrototypeResult source,
) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow(
    inspectionRowId: 'phase33w-owner-proof-boundary-inspection',
    sourceRecordId: 'phase33u-owner-proof-boundary',
    sourceCaseId: 'phase33u',
    sourcePhase: 'Phase 33U',
    sourceRole: 'ownerProofBoundary',
    role: DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
        .ownerProofBoundaryInspection,
    status:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowStatus.inspected,
    developerOnly: true,
    inMemoryOnly: true,
    analyzerUnwired: true,
    contextOnly: false,
    warningLimited: false,
    proofBoundaryOnly: false,
    excludedGuard: false,
    inactive: false,
    allowedFieldIds: const <String>[],
    deniedFieldIds: _deniedFieldIds,
    androidProofCaseIds: const <String>[],
    warningReasons: const <String>[],
    proofLimitReasons: _sorted(
      source.records.expand((record) => record.proofLimitReasons),
    ),
    blockedBoundaryIds: const <String>['ownerProofQueue'],
    activeDeniedFieldIds: source.ownerProofQueueCount > 0
        ? const <String>['ownerProofQueue']
        : const <String>[],
    findings: const <String>[],
    recommendation: 'keepOwnerProofQueueEmpty',
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow _rowFromReport(
  DebugOnlyBridgeAnalyzerAdapterPrototypeResult source,
  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationResult validation,
) {
  final findings =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionValidator()
          .validateReportText(
            [source.renderMarkdown(), validation.renderMarkdown()].join('\n'),
          );
  return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow(
    inspectionRowId: 'phase33w-report-safety-inspection',
    sourceRecordId: 'phase33w-report',
    sourceCaseId: 'phase33w',
    sourcePhase: 'Phase 33W',
    sourceRole: 'reportSafety',
    role: DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
        .reportSafetyInspection,
    status: findings.isEmpty
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowStatus.inspected
        : DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowStatus
              .blockedByBoundary,
    developerOnly: true,
    inMemoryOnly: true,
    analyzerUnwired: true,
    contextOnly: false,
    warningLimited: false,
    proofBoundaryOnly: false,
    excludedGuard: false,
    inactive: false,
    allowedFieldIds: const <String>[],
    deniedFieldIds: _deniedFieldIds,
    androidProofCaseIds: const <String>[],
    warningReasons: const <String>[],
    proofLimitReasons: const <String>[],
    blockedBoundaryIds: const <String>['rawUci', 'pvDump', 'stockfishCommand'],
    activeDeniedFieldIds: const <String>[],
    findings: findings,
    recommendation: 'keepInspectionReportSafe',
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow _futureRequirementRow() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow(
    inspectionRowId: 'phase33w-phase33x-requirement',
    sourceRecordId: 'phase33w-phase33x-requirement',
    sourceCaseId: 'phase33w',
    sourcePhase: 'Phase 33W',
    sourceRole: 'futureRequirement',
    role: DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
        .futureRequirementInspection,
    status:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowStatus.inspected,
    developerOnly: true,
    inMemoryOnly: true,
    analyzerUnwired: true,
    contextOnly: false,
    warningLimited: false,
    proofBoundaryOnly: false,
    excludedGuard: false,
    inactive: false,
    allowedFieldIds: <String>['futurePrerequisites'],
    deniedFieldIds: _deniedFieldIds,
    androidProofCaseIds: <String>[],
    warningReasons: <String>[],
    proofLimitReasons: <String>[],
    blockedBoundaryIds: <String>[
      'analyzerWiring',
      'productOutput',
      'runtimeImplementation',
    ],
    activeDeniedFieldIds: <String>[],
    findings: <String>[],
    recommendation: _phase33XRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow _rowWithStatus(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow row,
) {
  if (row.findings.isNotEmpty) {
    return row.copyWith(
      status: DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowStatus
          .blockedByBoundary,
    );
  }
  if (row.warningReasons.isNotEmpty || row.proofLimitReasons.isNotEmpty) {
    return row.copyWith(
      status: DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowStatus
          .inspectedWithWarnings,
    );
  }
  return row.copyWith(
    status:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowStatus.inspected,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
_inspectionRoleForRecordRole(
  DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole role,
) {
  return switch (role) {
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.internalInputRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
          .internalInputRecordInspection,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.contextOnlyRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
          .contextOnlyRecordInspection,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.warningLimitedRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
          .warningLimitedRecordInspection,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.proofBoundaryRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
          .proofBoundaryRecordInspection,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.excludedGuardRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
          .excludedGuardRecordInspection,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
        .allowedFieldBoundaryRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
          .allowedFieldBoundaryInspection,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
        .deniedFieldBoundaryRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
          .deniedFieldBoundaryInspection,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.mapperMetadataRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
          .mapperMetadataInspection,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.validatorMetadataRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
          .validatorMetadataInspection,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
        .debugSnapshotMetadataRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
          .debugSnapshotMetadataInspection,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.runtimeBlockedRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
          .runtimeBlockedInspection,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
        .analyzerWiringBlockedRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
          .analyzerWiringBlockedInspection,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.engineBlockedRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
          .engineBlockedInspection,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.schedulerBlockedRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
          .schedulerBlockedInspection,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
        .productAdapterBlockedRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
          .productAdapterBlockedInspection,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
        .savedAnalysisBlockedRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
          .savedAnalysisBlockedInspection,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.futureRequirementRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
          .futureRequirementInspection,
  };
}

String _recommendationForRecordRole(
  DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole role,
) {
  return switch (role) {
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.internalInputRecord =>
      'keepInternalInputInspectableOnly',
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.contextOnlyRecord =>
      'keepContextRecordContextOnly',
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.warningLimitedRecord =>
      'keepWarningLimitedRecordWarningLimited',
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.proofBoundaryRecord =>
      'keepProofBoundaryRecordBoundaryOnly',
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.excludedGuardRecord =>
      'keepExcludedGuardExcluded',
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
        .allowedFieldBoundaryRecord =>
      'keepAllowedFieldBoundaryInternal',
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
        .deniedFieldBoundaryRecord =>
      'keepDeniedFieldBoundaryInactive',
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.mapperMetadataRecord =>
      'keepMapperMetadataOnly',
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.validatorMetadataRecord =>
      'keepValidatorMetadataOnly',
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
        .debugSnapshotMetadataRecord =>
      'keepDebugSnapshotMetadataOnly',
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.runtimeBlockedRecord =>
      'keepRuntimeBlocked',
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
        .analyzerWiringBlockedRecord =>
      'keepAnalyzerWiringBlocked',
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.engineBlockedRecord =>
      'keepEngineBlocked',
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.schedulerBlockedRecord =>
      'keepSchedulerBlocked',
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
        .productAdapterBlockedRecord =>
      'keepProductAdapterBlocked',
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
        .savedAnalysisBlockedRecord =>
      'keepSavedAnalysisBlocked',
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.futureRequirementRecord =>
      _phase33XRecommendation,
  };
}

bool _isInactiveInspection(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole role,
) {
  return role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .deniedFieldBoundaryInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .runtimeBlockedInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .analyzerWiringBlockedInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .engineBlockedInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .schedulerBlockedInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .productAdapterBlockedInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .savedAnalysisBlockedInspection;
}

bool _isQuietRow(DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow row) {
  if (!_isSourceCaseRecordInspection(row.role)) {
    return false;
  }
  return row.sourceCaseId.contains('quiet-preparatory') ||
      row.blockedBoundaryIds.contains('quietPreparatoryCoreActivation') ||
      row.proofLimitReasons.contains(
        'quietPreparatoryExcludedFromActiveCoreOutput',
      );
}

bool _isSourceCaseRecordInspection(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole role,
) {
  return role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .internalInputRecordInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .contextOnlyRecordInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .warningLimitedRecordInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .proofBoundaryRecordInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .excludedGuardRecordInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .allowedFieldBoundaryInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .deniedFieldBoundaryInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .mapperMetadataInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .validatorMetadataInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .debugSnapshotMetadataInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .runtimeBlockedInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .analyzerWiringBlockedInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .engineBlockedInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .schedulerBlockedInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .productAdapterBlockedInspection ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
              .savedAnalysisBlockedInspection;
}

Map<String, int> _roleCounts(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeRecord> records,
) {
  return <String, int>{
    for (final role in DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.values)
      role.wire: records.where((record) => record.role == role).length,
  };
}

List<String> _findingsForActiveDeniedFields(Iterable<String> fieldIds) {
  final findings = <String>[];
  for (final fieldId in fieldIds) {
    switch (fieldId) {
      case 'productLabel':
        findings.addAll(<String>['productOutput', 'productLabelLeak']);
      case 'finalMoveLabel':
        findings.add('finalLabelLeak');
      case 'classifierLabel':
      case 'brilliantGreatMiss':
      case 'bestGoodInaccuracyMistakeBlunder':
        findings.add('classifierLabelLeak');
      case 'numericMoveScore':
        findings.add('numericScoreLeak');
      case 'aggregateScore':
        findings.add('aggregateScoreLeak');
      case 'officialMetric':
      case 'accuracy':
      case 'acpl':
        findings.add('officialMetricLeak');
      case 'cpLoss':
        findings.add('cpLossLeak');
      case 'winProbability':
        findings.add('winProbabilityLeak');
      case 'moveRanking':
        findings.add('moveRankingLeak');
      case 'thresholds':
        findings.add('thresholdLeak');
      case 'uiTarget':
        findings.add('uiTarget');
      case 'backendTarget':
        findings.add('backendTarget');
      case 'persistenceWrite':
        findings.add('persistenceWrite');
      case 'directEngineAccess':
        findings.add('engineCall');
      case 'schedulerExecution':
        findings.add('schedulerExecution');
      case 'analyzerWiring':
        findings.add('analyzerWiring');
      case 'runtimeImplementation':
        findings.add('runtimeImplementation');
      case 'executablePrototypeBehavior':
        findings.add('executablePrototypeImplementation');
      case 'productAdapterBehavior':
        findings.add('productAdapterBehavior');
      case 'savedAnalysisIntegration':
        findings.add('savedAnalysisIntegration');
      case 'stockfishCommand':
        findings.add('stockfishCommandLeak');
      case 'rawUci':
        findings.add('rawUciLeak');
      case 'pvDump':
        findings.add('pvDumpLeak');
      case 'androidCollectorRequirement':
        findings.add('androidCollectorRequired');
      case 'ownerProofQueue':
        findings.add('ownerProofQueueNotEmpty');
      case 'unsafePolicyAllowance':
      case 'unsafeInputPacket':
        findings.add('unsafeSourcePacket');
    }
  }
  return findings;
}

String _renderRowsForLeakCheck(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow> rows,
) {
  return rows
      .map(
        (row) => [
          row.inspectionRowId,
          row.sourceCaseId,
          row.sourceRole,
          row.role.wire,
          ...row.blockedBoundaryIds,
          ...row.warningReasons,
          ...row.proofLimitReasons,
          ...row.findings,
        ].join(' '),
      )
      .join('\n');
}

int _countRole(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow> rows,
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole role,
) {
  return rows.where((row) => row.role == role).length;
}

int _countFinding(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow> rows,
  String finding,
) {
  return rows.where((row) => row.findings.contains(finding)).length;
}

int _countActiveDeniedField(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow> rows,
  String fieldId,
) {
  return rows.where((row) => row.activeDeniedFieldIds.contains(fieldId)).length;
}

bool _isCriticalFinding(String finding) =>
    finding.startsWith('reportTextLeak:');

bool _isDeniedFieldId(String fieldId) => _deniedFieldIds.contains(fieldId);

List<String> _sorted(Iterable<String> values) {
  return values.where((value) => value.trim().isNotEmpty).toSet().toList()
    ..sort();
}

String _ids(Iterable<String> values) {
  final sorted = _sorted(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

const _phase33WRecommendation =
    'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness';
const _phase33VRequirement =
    'validateDebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonImplementation';
const _phase33XRecommendation =
    'validateDebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness';

const _pvMultiPvBoundaryCaseId = 'pv-multipv-support-boundary-32e';

const _phase32ECaseIds = <String>[
  'king-safety-mating-net-pressure-32e',
  'endgame-precision-candidate-spread-32e',
  'suppression-forced-only-legal-32e',
  'budget-pressure-wide-candidate-32e',
  _pvMultiPvBoundaryCaseId,
];

const _capturedAndroidProofIds = <String>[
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
];

const _deniedFieldIds = <String>[
  'productLabel',
  'finalMoveLabel',
  'classifierLabel',
  'brilliantGreatMiss',
  'bestGoodInaccuracyMistakeBlunder',
  'numericMoveScore',
  'aggregateScore',
  'officialMetric',
  'accuracy',
  'acpl',
  'cpLoss',
  'winProbability',
  'moveRanking',
  'thresholds',
  'uiTarget',
  'backendTarget',
  'persistenceWrite',
  'schedulerExecution',
  'directEngineAccess',
  'stockfishCommand',
  'rawUci',
  'pvDump',
  'androidCollectorRequirement',
  'analyzerWiring',
  'runtimeImplementation',
  'executablePrototypeBehavior',
  'productAdapterBehavior',
  'savedAnalysisIntegration',
];

const _knownSourceRoles = <String>{
  'inputPacket',
  'contextPacket',
  'policy',
  'androidProofBoundary',
  'ownerProofBoundary',
  'reportSafety',
  'futureRequirement',
  'internalInputRecord',
  'contextOnlyRecord',
  'warningLimitedRecord',
  'proofBoundaryRecord',
  'excludedGuardRecord',
  'allowedFieldBoundaryRecord',
  'deniedFieldBoundaryRecord',
  'mapperMetadataRecord',
  'validatorMetadataRecord',
  'debugSnapshotMetadataRecord',
  'runtimeBlockedRecord',
  'analyzerWiringBlockedRecord',
  'engineBlockedRecord',
  'schedulerBlockedRecord',
  'productAdapterBlockedRecord',
  'savedAnalysisBlockedRecord',
  'futureRequirementRecord',
};

const _rawReportLeakTokens = <String>{
  'uciok',
  'readyok',
  'info depth',
  'bestmove ',
  ' pv e2e4',
  'position fen',
  'go depth',
  'go movetime',
};

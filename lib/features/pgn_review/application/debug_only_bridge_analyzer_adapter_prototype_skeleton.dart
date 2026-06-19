import 'dart:convert';

import 'debug_only_bridge_analyzer_adapter_prototype_implementation_design_validation.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeSkeletonReportVersion =
    'debug-only-bridge-analyzer-adapter-prototype-skeleton-v1';
const debugOnlyBridgeAnalyzerAdapterPrototypeSkeletonVersion =
    'phase33u-debug-only-analyzer-adapter-prototype-skeleton-v1';

enum DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonStatus {
  prototypeSkeletonReadyWithWarnings('prototypeSkeletonReadyWithWarnings'),
  prototypeSkeletonReadyClean('prototypeSkeletonReadyClean'),
  blockedByUnsafeImplementationDesignValidation(
    'blockedByUnsafeImplementationDesignValidation',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidPrototypeSkeleton('invalidPrototypeSkeleton');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonStatus(this.wire);

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole {
  internalInputRecord('internalInputRecord'),
  contextOnlyRecord('contextOnlyRecord'),
  warningLimitedRecord('warningLimitedRecord'),
  proofBoundaryRecord('proofBoundaryRecord'),
  excludedGuardRecord('excludedGuardRecord'),
  allowedFieldBoundaryRecord('allowedFieldBoundaryRecord'),
  deniedFieldBoundaryRecord('deniedFieldBoundaryRecord'),
  mapperMetadataRecord('mapperMetadataRecord'),
  validatorMetadataRecord('validatorMetadataRecord'),
  debugSnapshotMetadataRecord('debugSnapshotMetadataRecord'),
  runtimeBlockedRecord('runtimeBlockedRecord'),
  analyzerWiringBlockedRecord('analyzerWiringBlockedRecord'),
  engineBlockedRecord('engineBlockedRecord'),
  schedulerBlockedRecord('schedulerBlockedRecord'),
  productAdapterBlockedRecord('productAdapterBlockedRecord'),
  savedAnalysisBlockedRecord('savedAnalysisBlockedRecord'),
  futureRequirementRecord('futureRequirementRecord');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole(this.wire);

  final String wire;

  bool get isInactiveBoundary =>
      this == deniedFieldBoundaryRecord ||
      this == runtimeBlockedRecord ||
      this == analyzerWiringBlockedRecord ||
      this == engineBlockedRecord ||
      this == schedulerBlockedRecord ||
      this == productAdapterBlockedRecord ||
      this == savedAnalysisBlockedRecord;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeInputPacket {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeInputPacket({
    required this.inputPacketId,
    required this.sourceValidationStatus,
    required this.sourceValidationRecommendation,
    required this.sourceValidationRowIds,
    required this.sourceImplementationDesignRecordIds,
    required this.internalInputRecordIds,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.supportCaseIds,
    required this.androidProofCaseIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.blockedBoundaryIds,
    required this.futurePrerequisites,
    this.developerOnly = true,
    this.inMemoryOnly = true,
    this.analyzerUnwired = true,
  });

  final String inputPacketId;
  final String sourceValidationStatus;
  final String sourceValidationRecommendation;
  final List<String> sourceValidationRowIds;
  final List<String> sourceImplementationDesignRecordIds;
  final List<String> internalInputRecordIds;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final List<String> supportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> blockedBoundaryIds;
  final List<String> futurePrerequisites;
  final bool developerOnly;
  final bool inMemoryOnly;
  final bool analyzerUnwired;

  bool get hasUnsafeInput =>
      !developerOnly ||
      !inMemoryOnly ||
      !analyzerUnwired ||
      allowedFieldIds.any(_isDeniedFieldId);

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'inputPacketId': inputPacketId,
      'sourceValidationStatus': sourceValidationStatus,
      'sourceValidationRecommendation': sourceValidationRecommendation,
      'sourceValidationRowIds': sourceValidationRowIds,
      'sourceImplementationDesignRecordIds':
          sourceImplementationDesignRecordIds,
      'internalInputRecordIds': internalInputRecordIds,
      'allowedFieldIds': allowedFieldIds,
      'deniedFieldIds': deniedFieldIds,
      'supportCaseIds': supportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'blockedBoundaryIds': blockedBoundaryIds,
      'futurePrerequisites': futurePrerequisites,
      'developerOnly': developerOnly,
      'inMemoryOnly': inMemoryOnly,
      'analyzerUnwired': analyzerUnwired,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeContextPacket {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeContextPacket({
    required this.contextPacketId,
    required this.contextOnlyRecordIds,
    required this.warningLimitedRecordIds,
    required this.proofBoundaryRecordIds,
    required this.excludedGuardRecordIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.blockedBoundaryIds,
    this.developerOnly = true,
    this.contextOnly = true,
    this.analyzerUnwired = true,
  });

  final String contextPacketId;
  final List<String> contextOnlyRecordIds;
  final List<String> warningLimitedRecordIds;
  final List<String> proofBoundaryRecordIds;
  final List<String> excludedGuardRecordIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> blockedBoundaryIds;
  final bool developerOnly;
  final bool contextOnly;
  final bool analyzerUnwired;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'contextPacketId': contextPacketId,
      'contextOnlyRecordIds': contextOnlyRecordIds,
      'warningLimitedRecordIds': warningLimitedRecordIds,
      'proofBoundaryRecordIds': proofBoundaryRecordIds,
      'excludedGuardRecordIds': excludedGuardRecordIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'blockedBoundaryIds': blockedBoundaryIds,
      'developerOnly': developerOnly,
      'contextOnly': contextOnly,
      'analyzerUnwired': analyzerUnwired,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeRecord {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeRecord({
    required this.recordId,
    required this.role,
    required this.sourceValidationRowId,
    required this.sourceImplementationDesignRecordId,
    required this.sourceCaseId,
    required this.sourcePhase,
    required this.implementationDesignRole,
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
    required this.blockedBoundaryIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.androidProofCaseIds,
    required this.ownerProofRequired,
    required this.activeDeniedFieldIds,
    required this.safetyFlags,
    required this.findings,
    required this.recommendation,
  });

  final String recordId;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole role;
  final String sourceValidationRowId;
  final String sourceImplementationDesignRecordId;
  final String sourceCaseId;
  final String sourcePhase;
  final String implementationDesignRole;
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
  final List<String> blockedBoundaryIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofCaseIds;
  final bool ownerProofRequired;
  final List<String> activeDeniedFieldIds;
  final Map<String, bool> safetyFlags;
  final List<String> findings;
  final String recommendation;

  bool get hasUnsafeOutput =>
      !developerOnly ||
      !inMemoryOnly ||
      !analyzerUnwired ||
      activeDeniedFieldIds.isNotEmpty ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      safetyFlags.values.any((value) => value);

  DebugOnlyBridgeAnalyzerAdapterPrototypeRecord copyWith({
    String? recordId,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole? role,
    String? sourceValidationRowId,
    String? sourceImplementationDesignRecordId,
    String? sourceCaseId,
    String? sourcePhase,
    String? implementationDesignRole,
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
    List<String>? blockedBoundaryIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? androidProofCaseIds,
    bool? ownerProofRequired,
    List<String>? activeDeniedFieldIds,
    Map<String, bool>? safetyFlags,
    List<String>? findings,
    String? recommendation,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeRecord(
      recordId: recordId ?? this.recordId,
      role: role ?? this.role,
      sourceValidationRowId:
          sourceValidationRowId ?? this.sourceValidationRowId,
      sourceImplementationDesignRecordId:
          sourceImplementationDesignRecordId ??
          this.sourceImplementationDesignRecordId,
      sourceCaseId: sourceCaseId ?? this.sourceCaseId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      implementationDesignRole:
          implementationDesignRole ?? this.implementationDesignRole,
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
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      activeDeniedFieldIds: activeDeniedFieldIds ?? this.activeDeniedFieldIds,
      safetyFlags: safetyFlags ?? this.safetyFlags,
      findings: findings ?? this.findings,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'recordId': recordId,
      'role': role.wire,
      'sourceValidationRowId': sourceValidationRowId,
      'sourceImplementationDesignRecordId': sourceImplementationDesignRecordId,
      'sourceCaseId': sourceCaseId,
      'sourcePhase': sourcePhase,
      'implementationDesignRole': implementationDesignRole,
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
      'blockedBoundaryIds': blockedBoundaryIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'androidProofCaseIds': androidProofCaseIds,
      'ownerProofRequired': ownerProofRequired,
      'activeDeniedFieldIds': activeDeniedFieldIds,
      'safetyFlags': safetyFlags,
      'findings': findings,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypePolicy {
  const DebugOnlyBridgeAnalyzerAdapterPrototypePolicy({
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.capturedAndroidProofIds,
    this.allowsProductOutput = false,
    this.allowsAnalyzerWiring = false,
    this.allowsRuntimeImplementation = false,
    this.allowsExecutablePrototype = false,
    this.allowsEngineCalls = false,
    this.allowsSchedulerExecution = false,
    this.allowsPersistenceWrites = false,
    this.allowsUiTargets = false,
    this.allowsBackendTargets = false,
    this.allowsProductAdapter = false,
    this.allowsSavedAnalysisIntegration = false,
    this.allowsClassifierLabels = false,
    this.allowsFinalLabels = false,
    this.allowsNumericScores = false,
    this.allowsAggregateScores = false,
    this.allowsOfficialMetrics = false,
    this.allowsCpLoss = false,
    this.allowsWinProbability = false,
    this.allowsMoveRanking = false,
    this.allowsStockfishCommand = false,
    this.allowsRawUci = false,
    this.allowsPvDump = false,
    this.allowsAndroidCollector = false,
  });

  factory DebugOnlyBridgeAnalyzerAdapterPrototypePolicy.safeDefault() {
    return const DebugOnlyBridgeAnalyzerAdapterPrototypePolicy(
      allowedFieldIds: _allowedInternalFieldIds,
      deniedFieldIds: _deniedFieldIds,
      capturedAndroidProofIds: _capturedAndroidProofIds,
    );
  }

  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final List<String> capturedAndroidProofIds;
  final bool allowsProductOutput;
  final bool allowsAnalyzerWiring;
  final bool allowsRuntimeImplementation;
  final bool allowsExecutablePrototype;
  final bool allowsEngineCalls;
  final bool allowsSchedulerExecution;
  final bool allowsPersistenceWrites;
  final bool allowsUiTargets;
  final bool allowsBackendTargets;
  final bool allowsProductAdapter;
  final bool allowsSavedAnalysisIntegration;
  final bool allowsClassifierLabels;
  final bool allowsFinalLabels;
  final bool allowsNumericScores;
  final bool allowsAggregateScores;
  final bool allowsOfficialMetrics;
  final bool allowsCpLoss;
  final bool allowsWinProbability;
  final bool allowsMoveRanking;
  final bool allowsStockfishCommand;
  final bool allowsRawUci;
  final bool allowsPvDump;
  final bool allowsAndroidCollector;

  bool get hasUnsafeAllowance =>
      allowsProductOutput ||
      allowsAnalyzerWiring ||
      allowsRuntimeImplementation ||
      allowsExecutablePrototype ||
      allowsEngineCalls ||
      allowsSchedulerExecution ||
      allowsPersistenceWrites ||
      allowsUiTargets ||
      allowsBackendTargets ||
      allowsProductAdapter ||
      allowsSavedAnalysisIntegration ||
      allowsClassifierLabels ||
      allowsFinalLabels ||
      allowsNumericScores ||
      allowsAggregateScores ||
      allowsOfficialMetrics ||
      allowsCpLoss ||
      allowsWinProbability ||
      allowsMoveRanking ||
      allowsStockfishCommand ||
      allowsRawUci ||
      allowsPvDump ||
      allowsAndroidCollector ||
      allowedFieldIds.any(_isDeniedFieldId);

  DebugOnlyBridgeAnalyzerAdapterPrototypePolicy copyWith({
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    List<String>? capturedAndroidProofIds,
    bool? allowsProductOutput,
    bool? allowsAnalyzerWiring,
    bool? allowsRuntimeImplementation,
    bool? allowsExecutablePrototype,
    bool? allowsEngineCalls,
    bool? allowsSchedulerExecution,
    bool? allowsPersistenceWrites,
    bool? allowsUiTargets,
    bool? allowsBackendTargets,
    bool? allowsProductAdapter,
    bool? allowsSavedAnalysisIntegration,
    bool? allowsClassifierLabels,
    bool? allowsFinalLabels,
    bool? allowsNumericScores,
    bool? allowsAggregateScores,
    bool? allowsOfficialMetrics,
    bool? allowsCpLoss,
    bool? allowsWinProbability,
    bool? allowsMoveRanking,
    bool? allowsStockfishCommand,
    bool? allowsRawUci,
    bool? allowsPvDump,
    bool? allowsAndroidCollector,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypePolicy(
      allowedFieldIds: allowedFieldIds ?? this.allowedFieldIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      capturedAndroidProofIds:
          capturedAndroidProofIds ?? this.capturedAndroidProofIds,
      allowsProductOutput: allowsProductOutput ?? this.allowsProductOutput,
      allowsAnalyzerWiring: allowsAnalyzerWiring ?? this.allowsAnalyzerWiring,
      allowsRuntimeImplementation:
          allowsRuntimeImplementation ?? this.allowsRuntimeImplementation,
      allowsExecutablePrototype:
          allowsExecutablePrototype ?? this.allowsExecutablePrototype,
      allowsEngineCalls: allowsEngineCalls ?? this.allowsEngineCalls,
      allowsSchedulerExecution:
          allowsSchedulerExecution ?? this.allowsSchedulerExecution,
      allowsPersistenceWrites:
          allowsPersistenceWrites ?? this.allowsPersistenceWrites,
      allowsUiTargets: allowsUiTargets ?? this.allowsUiTargets,
      allowsBackendTargets: allowsBackendTargets ?? this.allowsBackendTargets,
      allowsProductAdapter: allowsProductAdapter ?? this.allowsProductAdapter,
      allowsSavedAnalysisIntegration:
          allowsSavedAnalysisIntegration ?? this.allowsSavedAnalysisIntegration,
      allowsClassifierLabels:
          allowsClassifierLabels ?? this.allowsClassifierLabels,
      allowsFinalLabels: allowsFinalLabels ?? this.allowsFinalLabels,
      allowsNumericScores: allowsNumericScores ?? this.allowsNumericScores,
      allowsAggregateScores:
          allowsAggregateScores ?? this.allowsAggregateScores,
      allowsOfficialMetrics:
          allowsOfficialMetrics ?? this.allowsOfficialMetrics,
      allowsCpLoss: allowsCpLoss ?? this.allowsCpLoss,
      allowsWinProbability: allowsWinProbability ?? this.allowsWinProbability,
      allowsMoveRanking: allowsMoveRanking ?? this.allowsMoveRanking,
      allowsStockfishCommand:
          allowsStockfishCommand ?? this.allowsStockfishCommand,
      allowsRawUci: allowsRawUci ?? this.allowsRawUci,
      allowsPvDump: allowsPvDump ?? this.allowsPvDump,
      allowsAndroidCollector:
          allowsAndroidCollector ?? this.allowsAndroidCollector,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'allowedFieldIds': allowedFieldIds,
      'deniedFieldIds': deniedFieldIds,
      'capturedAndroidProofIds': capturedAndroidProofIds,
      'allowsProductOutput': allowsProductOutput,
      'allowsAnalyzerWiring': allowsAnalyzerWiring,
      'allowsRuntimeImplementation': allowsRuntimeImplementation,
      'allowsExecutablePrototype': allowsExecutablePrototype,
      'allowsEngineCalls': allowsEngineCalls,
      'allowsSchedulerExecution': allowsSchedulerExecution,
      'allowsPersistenceWrites': allowsPersistenceWrites,
      'allowsUiTargets': allowsUiTargets,
      'allowsBackendTargets': allowsBackendTargets,
      'allowsProductAdapter': allowsProductAdapter,
      'allowsSavedAnalysisIntegration': allowsSavedAnalysisIntegration,
      'allowsClassifierLabels': allowsClassifierLabels,
      'allowsFinalLabels': allowsFinalLabels,
      'allowsNumericScores': allowsNumericScores,
      'allowsAggregateScores': allowsAggregateScores,
      'allowsOfficialMetrics': allowsOfficialMetrics,
      'allowsCpLoss': allowsCpLoss,
      'allowsWinProbability': allowsWinProbability,
      'allowsMoveRanking': allowsMoveRanking,
      'allowsStockfishCommand': allowsStockfishCommand,
      'allowsRawUci': allowsRawUci,
      'allowsPvDump': allowsPvDump,
      'allowsAndroidCollector': allowsAndroidCollector,
      'hasUnsafeAllowance': hasUnsafeAllowance,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeDebugSnapshot {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeDebugSnapshot({
    required this.snapshotId,
    required this.skeletonVersion,
    required this.recordRoleCounts,
    required this.safeForDeveloperInspection,
    required this.warningReasons,
    required this.blockedBoundaryIds,
  });

  final String snapshotId;
  final String skeletonVersion;
  final Map<String, int> recordRoleCounts;
  final bool safeForDeveloperInspection;
  final List<String> warningReasons;
  final List<String> blockedBoundaryIds;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'snapshotId': snapshotId,
      'skeletonVersion': skeletonVersion,
      'recordRoleCounts': recordRoleCounts,
      'safeForDeveloperInspection': safeForDeveloperInspection,
      'warningReasons': warningReasons,
      'blockedBoundaryIds': blockedBoundaryIds,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeResult {
  DebugOnlyBridgeAnalyzerAdapterPrototypeResult({
    required this.status,
    required this.sourceValidationStatus,
    required this.sourceValidationSafeForPhase33U,
    required this.sourceValidationRecommendation,
    required this.inputPacket,
    required this.contextPacket,
    required this.records,
    required this.policy,
    required this.debugSnapshot,
    required this.reportFindings,
    required this.safeForPhase33V,
    required this.phase33VRecommendation,
  }) : totalRecords = records.length,
       internalInputRecordCount = _countRole(
         records,
         DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.internalInputRecord,
       ),
       contextOnlyRecordCount = _countRole(
         records,
         DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.contextOnlyRecord,
       ),
       warningLimitedRecordCount = _countRole(
         records,
         DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.warningLimitedRecord,
       ),
       proofBoundaryRecordCount = _countRole(
         records,
         DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.proofBoundaryRecord,
       ),
       excludedGuardRecordCount = _countRole(
         records,
         DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.excludedGuardRecord,
       ),
       allowedFieldBoundaryRecordCount = _countRole(
         records,
         DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
             .allowedFieldBoundaryRecord,
       ),
       deniedFieldBoundaryRecordCount = _countRole(
         records,
         DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
             .deniedFieldBoundaryRecord,
       ),
       mapperMetadataRecordCount = _countRole(
         records,
         DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.mapperMetadataRecord,
       ),
       validatorMetadataRecordCount = _countRole(
         records,
         DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
             .validatorMetadataRecord,
       ),
       debugSnapshotMetadataRecordCount = _countRole(
         records,
         DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
             .debugSnapshotMetadataRecord,
       ),
       runtimeBlockedRecordCount = _countRole(
         records,
         DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.runtimeBlockedRecord,
       ),
       analyzerWiringBlockedRecordCount = _countRole(
         records,
         DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
             .analyzerWiringBlockedRecord,
       ),
       engineBlockedRecordCount = _countRole(
         records,
         DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.engineBlockedRecord,
       ),
       schedulerBlockedRecordCount = _countRole(
         records,
         DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
             .schedulerBlockedRecord,
       ),
       productAdapterBlockedRecordCount = _countRole(
         records,
         DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
             .productAdapterBlockedRecord,
       ),
       savedAnalysisBlockedRecordCount = _countRole(
         records,
         DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
             .savedAnalysisBlockedRecord,
       ),
       futureRequirementRecordCount = _countRole(
         records,
         DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
             .futureRequirementRecord,
       ),
       activeDeniedFieldCount = records.fold<int>(
         0,
         (total, record) => total + record.activeDeniedFieldIds.length,
       ),
       productOutputCount = _countFinding(records, 'productOutput'),
       labelLeakCount = _countFinding(records, 'classifierLabelLeak'),
       finalLabelLeakCount = _countFinding(records, 'finalLabelLeak'),
       scoreLeakCount =
           _countFinding(records, 'numericScoreLeak') +
           _countFinding(records, 'aggregateScoreLeak'),
       metricLeakCount = _countFinding(records, 'officialMetricLeak'),
       cpLossLeakCount = _countFinding(records, 'cpLossLeak'),
       winProbabilityLeakCount = _countFinding(records, 'winProbabilityLeak'),
       moveRankingLeakCount = _countFinding(records, 'moveRankingLeak'),
       thresholdLeakCount =
           _countFinding(records, 'thresholdLeak') +
           _countActiveDeniedField(records, 'thresholds'),
       uiTargetCount = _countFinding(records, 'uiTarget'),
       backendTargetCount = _countFinding(records, 'backendTarget'),
       persistenceWriteCount = _countFinding(records, 'persistenceWrite'),
       engineCallCount = _countFinding(records, 'engineCall'),
       schedulerExecutionCount = _countFinding(records, 'schedulerExecution'),
       analyzerWiringCount =
           _countFinding(records, 'analyzerWiring') +
           _countFinding(records, 'analyzerWiringEnabled'),
       runtimeImplementationCount = _countFinding(
         records,
         'runtimeImplementation',
       ),
       executablePrototypeCount = _countFinding(
         records,
         'executablePrototypeImplementation',
       ),
       productAdapterBehaviorCount =
           _countFinding(records, 'productAdapterBehavior') +
           _countActiveDeniedField(records, 'productAdapterBehavior'),
       savedAnalysisIntegrationCount =
           _countFinding(records, 'savedAnalysisIntegration') +
           _countActiveDeniedField(records, 'savedAnalysisIntegration'),
       stockfishCommandLeakCount = _countFinding(
         records,
         'stockfishCommandLeak',
       ),
       rawUciLeakCount = _countFinding(records, 'rawUciLeak'),
       pvDumpLeakCount = _countFinding(records, 'pvDumpLeak'),
       androidCollectorRequirementCount = _countFinding(
         records,
         'androidCollectorRequired',
       ),
       unprovenAndroidProofCount = _countFinding(
         records,
         'unprovenAndroidProofId',
       ),
       phase32EProofClaimCount = _countFinding(
         records,
         'phase32ECapturedAndroidProofClaim',
       ),
       ownerProofQueueCount = records
           .where((record) => record.ownerProofRequired)
           .length,
       blockerCount = records
           .where((record) => record.findings.isNotEmpty)
           .length,
       criticalCount = reportFindings.where(_isCriticalFinding).length {
    unsafeCount =
        records.where((record) => record.hasUnsafeOutput).length +
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

  final DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonStatus status;
  final String sourceValidationStatus;
  final bool sourceValidationSafeForPhase33U;
  final String sourceValidationRecommendation;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeInputPacket inputPacket;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeContextPacket contextPacket;
  final List<DebugOnlyBridgeAnalyzerAdapterPrototypeRecord> records;
  final DebugOnlyBridgeAnalyzerAdapterPrototypePolicy policy;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeDebugSnapshot debugSnapshot;
  final List<String> reportFindings;
  final bool safeForPhase33V;
  final String phase33VRecommendation;
  final int totalRecords;
  final int internalInputRecordCount;
  final int contextOnlyRecordCount;
  final int warningLimitedRecordCount;
  final int proofBoundaryRecordCount;
  final int excludedGuardRecordCount;
  final int allowedFieldBoundaryRecordCount;
  final int deniedFieldBoundaryRecordCount;
  final int mapperMetadataRecordCount;
  final int validatorMetadataRecordCount;
  final int debugSnapshotMetadataRecordCount;
  final int runtimeBlockedRecordCount;
  final int analyzerWiringBlockedRecordCount;
  final int engineBlockedRecordCount;
  final int schedulerBlockedRecordCount;
  final int productAdapterBlockedRecordCount;
  final int savedAnalysisBlockedRecordCount;
  final int futureRequirementRecordCount;
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
      !safeForPhase33V ||
      !sourceValidationSafeForPhase33U ||
      inputPacket.hasUnsafeInput ||
      policy.hasUnsafeAllowance;

  DebugOnlyBridgeAnalyzerAdapterPrototypeRecord recordForRole(
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole role,
  ) {
    return records.firstWhere((record) => record.role == role);
  }

  String renderMarkdown() {
    final roleCounts = _roleCounts(records);
    final buffer = StringBuffer()
      ..writeln('# Debug-Only Bridge Analyzer Adapter Prototype Skeleton')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterPrototypeSkeletonReportVersion',
      )
      ..writeln('- skeleton status: ${status.wire}')
      ..writeln('- source Phase 33T validation status: $sourceValidationStatus')
      ..writeln('- safe for Phase 33V: $safeForPhase33V')
      ..writeln('- Phase 33V recommendation: $phase33VRecommendation')
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
      ..writeln('## Packet Summary')
      ..writeln('- input packet ID: ${inputPacket.inputPacketId}')
      ..writeln('- context packet ID: ${contextPacket.contextPacketId}')
      ..writeln('- internal input records: $internalInputRecordCount')
      ..writeln('- context-only records: $contextOnlyRecordCount')
      ..writeln('- warning-limited records: $warningLimitedRecordCount')
      ..writeln('- proof-boundary records: $proofBoundaryRecordCount')
      ..writeln('- excluded-guard records: $excludedGuardRecordCount')
      ..writeln()
      ..writeln('## Policy Summary')
      ..writeln('- unsafe allowance: ${policy.hasUnsafeAllowance}')
      ..writeln('- allows product output: ${policy.allowsProductOutput}')
      ..writeln('- allows analyzer wiring: ${policy.allowsAnalyzerWiring}')
      ..writeln('- allows runtime: ${policy.allowsRuntimeImplementation}')
      ..writeln('- allows engine calls: ${policy.allowsEngineCalls}')
      ..writeln(
        '- allows scheduler execution: ${policy.allowsSchedulerExecution}',
      )
      ..writeln(
        '- allows persistence writes: ${policy.allowsPersistenceWrites}',
      )
      ..writeln('- allows raw UCI: ${policy.allowsRawUci}')
      ..writeln('- allows PV dump: ${policy.allowsPvDump}')
      ..writeln()
      ..writeln('## Record Role Summary')
      ..writeln('| Role | Count |')
      ..writeln('| --- | --- |');
    for (final entry in roleCounts.entries) {
      buffer.writeln('| ${entry.key} | ${entry.value} |');
    }
    buffer
      ..writeln()
      ..writeln('## Prototype Record Table')
      ..writeln(
        '| Record | Source row | Case ID | Role | Context only | Warning limited | Proof boundary | Excluded guard | Inactive | Findings |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final record in records) {
      buffer.writeln(
        '| ${record.recordId} | ${record.sourceValidationRowId} | '
        '${record.sourceCaseId} | ${record.role.wire} | '
        '${record.contextOnly} | ${record.warningLimited} | '
        '${record.proofBoundaryOnly} | ${record.excludedGuard} | '
        '${record.inactive} | ${_ids(record.findings)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Proof Boundary Summary')
      ..writeln(
        '- captured Android proof IDs: ${_ids(_capturedAndroidProofIds)}',
      )
      ..writeln('- unproven Android proof count: $unprovenAndroidProofCount')
      ..writeln('- Phase 32E proof claim count: $phase32EProofClaimCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Denied Field Summary')
      ..writeln('- allowed internal fields: ${_ids(_allowedInternalFieldIds)}')
      ..writeln('- denied fields: ${_ids(_deniedFieldIds)}')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- Stockfish command leak count: $stockfishCommandLeakCount')
      ..writeln('- raw UCI leak count: $rawUciLeakCount')
      ..writeln('- PV dump leak count: $pvDumpLeakCount')
      ..writeln()
      ..writeln('## Runtime Analyzer Engine Scheduler Product Block Summary')
      ..writeln('- analyzer wiring count: $analyzerWiringCount')
      ..writeln('- runtime implementation count: $runtimeImplementationCount')
      ..writeln('- executable prototype count: $executablePrototypeCount')
      ..writeln('- engine call count: $engineCallCount')
      ..writeln('- scheduler execution count: $schedulerExecutionCount')
      ..writeln('- UI target count: $uiTargetCount')
      ..writeln('- backend target count: $backendTargetCount')
      ..writeln('- persistence write count: $persistenceWriteCount')
      ..writeln(
        '- product adapter behavior count: $productAdapterBehaviorCount',
      )
      ..writeln(
        '- saved analysis integration count: $savedAnalysisIntegrationCount',
      )
      ..writeln()
      ..writeln('## Debug Snapshot Summary')
      ..writeln('- snapshot ID: ${debugSnapshot.snapshotId}')
      ..writeln(
        '- safe for developer inspection: '
        '${debugSnapshot.safeForDeveloperInspection}',
      )
      ..writeln()
      ..writeln('## Report Findings')
      ..writeln('- findings: ${_ids(reportFindings)}');
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': debugOnlyBridgeAnalyzerAdapterPrototypeSkeletonReportVersion,
      'skeletonVersion': debugOnlyBridgeAnalyzerAdapterPrototypeSkeletonVersion,
      'skeletonStatus': status.wire,
      'sourceValidationStatus': sourceValidationStatus,
      'sourceValidationSafeForPhase33U': sourceValidationSafeForPhase33U,
      'sourceValidationRecommendation': sourceValidationRecommendation,
      'safeForPhase33V': safeForPhase33V,
      'phase33VRecommendation': phase33VRecommendation,
      'counts': <String, Object?>{
        'totalRecords': totalRecords,
        'internalInputRecordCount': internalInputRecordCount,
        'contextOnlyRecordCount': contextOnlyRecordCount,
        'warningLimitedRecordCount': warningLimitedRecordCount,
        'proofBoundaryRecordCount': proofBoundaryRecordCount,
        'excludedGuardRecordCount': excludedGuardRecordCount,
        'allowedFieldBoundaryRecordCount': allowedFieldBoundaryRecordCount,
        'deniedFieldBoundaryRecordCount': deniedFieldBoundaryRecordCount,
        'mapperMetadataRecordCount': mapperMetadataRecordCount,
        'validatorMetadataRecordCount': validatorMetadataRecordCount,
        'debugSnapshotMetadataRecordCount': debugSnapshotMetadataRecordCount,
        'runtimeBlockedRecordCount': runtimeBlockedRecordCount,
        'analyzerWiringBlockedRecordCount': analyzerWiringBlockedRecordCount,
        'engineBlockedRecordCount': engineBlockedRecordCount,
        'schedulerBlockedRecordCount': schedulerBlockedRecordCount,
        'productAdapterBlockedRecordCount': productAdapterBlockedRecordCount,
        'savedAnalysisBlockedRecordCount': savedAnalysisBlockedRecordCount,
        'futureRequirementRecordCount': futureRequirementRecordCount,
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
      'inputPacket': inputPacket.toJson(),
      'contextPacket': contextPacket.toJson(),
      'policy': policy.toJson(),
      'debugSnapshot': debugSnapshot.toJson(),
      'records': records.map((record) => record.toJson()).toList(),
      'reportFindings': reportFindings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeMapper {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeMapper({
    this.validator = const DebugOnlyBridgeAnalyzerAdapterPrototypeValidator(),
  });

  final DebugOnlyBridgeAnalyzerAdapterPrototypeValidator validator;

  DebugOnlyBridgeAnalyzerAdapterPrototypeResult evaluate({
    DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationResult?
    validationResult,
  }) {
    final source =
        validationResult ??
        const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidation()
            .evaluate();
    final sourceSafe =
        source.safeForPhase33U &&
        source.phase33URecommendation ==
            'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonImplementation' &&
        !source.hasUnsafePolicyViolation;
    final initialRecords = source.validationRows.map(_recordFromRow).toList();
    final records = initialRecords
        .map(
          (record) =>
              record.copyWith(findings: validator.validateRecord(record)),
        )
        .toList(growable: false);
    final policy = DebugOnlyBridgeAnalyzerAdapterPrototypePolicy.safeDefault();
    final inputPacket = DebugOnlyBridgeAnalyzerAdapterPrototypeInputPacket(
      inputPacketId: 'phase33u-analyzer-adapter-prototype-input-packet',
      sourceValidationStatus: source.status.wire,
      sourceValidationRecommendation: source.phase33URecommendation,
      sourceValidationRowIds: _sorted(
        records.map((record) => record.sourceValidationRowId),
      ),
      sourceImplementationDesignRecordIds: _sorted(
        records.map((record) => record.sourceImplementationDesignRecordId),
      ),
      internalInputRecordIds: _idsForRole(
        records,
        DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.internalInputRecord,
      ),
      allowedFieldIds: _allowedInternalFieldIds,
      deniedFieldIds: _deniedFieldIds,
      supportCaseIds: _supportCaseIds(records),
      androidProofCaseIds: _sorted(
        records.expand((record) => record.androidProofCaseIds),
      ),
      warningReasons: _sorted(
        records.expand((record) => record.warningReasons),
      ),
      proofLimitReasons: _sorted(
        records.expand((record) => record.proofLimitReasons),
      ),
      blockedBoundaryIds: _sorted(
        records.expand((record) => record.blockedBoundaryIds),
      ),
      futurePrerequisites: const <String>[
        'validateDebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonImplementation',
      ],
    );
    final contextPacket = DebugOnlyBridgeAnalyzerAdapterPrototypeContextPacket(
      contextPacketId: 'phase33u-analyzer-adapter-prototype-context-packet',
      contextOnlyRecordIds: _idsForRole(
        records,
        DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.contextOnlyRecord,
      ),
      warningLimitedRecordIds: _idsForRole(
        records,
        DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.warningLimitedRecord,
      ),
      proofBoundaryRecordIds: _idsForRole(
        records,
        DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.proofBoundaryRecord,
      ),
      excludedGuardRecordIds: _idsForRole(
        records,
        DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.excludedGuardRecord,
      ),
      warningReasons: inputPacket.warningReasons,
      proofLimitReasons: inputPacket.proofLimitReasons,
      blockedBoundaryIds: inputPacket.blockedBoundaryIds,
    );
    final reportFindings = validator.validateReportText(
      _renderRecordsForLeakCheck(records),
    );
    final roleCounts = _roleCounts(records);
    final hasFutureRequirement = records.any(
      (record) =>
          record.role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
              .futureRequirementRecord,
    );
    final hasRecordFindings = records.any(
      (record) => record.findings.isNotEmpty,
    );
    final safe =
        sourceSafe &&
        hasFutureRequirement &&
        !hasRecordFindings &&
        reportFindings.isEmpty &&
        !inputPacket.hasUnsafeInput &&
        !policy.hasUnsafeAllowance;
    final status = !sourceSafe
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonStatus
              .blockedByUnsafeImplementationDesignValidation
        : !hasFutureRequirement
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonStatus
              .invalidPrototypeSkeleton
        : hasRecordFindings || reportFindings.isNotEmpty
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonStatus
              .blockedByPolicyBoundary
        : records.any(
            (record) =>
                record.warningReasons.isNotEmpty ||
                record.proofLimitReasons.isNotEmpty,
          )
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonStatus
              .prototypeSkeletonReadyWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonStatus
              .prototypeSkeletonReadyClean;
    final debugSnapshot = DebugOnlyBridgeAnalyzerAdapterPrototypeDebugSnapshot(
      snapshotId: 'phase33u-analyzer-adapter-prototype-debug-snapshot',
      skeletonVersion: debugOnlyBridgeAnalyzerAdapterPrototypeSkeletonVersion,
      recordRoleCounts: roleCounts,
      safeForDeveloperInspection: safe,
      warningReasons: inputPacket.warningReasons,
      blockedBoundaryIds: inputPacket.blockedBoundaryIds,
    );

    return DebugOnlyBridgeAnalyzerAdapterPrototypeResult(
      status: status,
      sourceValidationStatus: source.status.wire,
      sourceValidationSafeForPhase33U: source.safeForPhase33U,
      sourceValidationRecommendation: source.phase33URecommendation,
      inputPacket: inputPacket,
      contextPacket: contextPacket,
      records: records,
      policy: policy,
      debugSnapshot: debugSnapshot,
      reportFindings: reportFindings,
      safeForPhase33V: safe,
      phase33VRecommendation: safe
          ? _phase33VRecommendation
          : 'blockedByUnsafeAnalyzerAdapterPrototypeSkeleton',
    );
  }

  DebugOnlyBridgeAnalyzerAdapterPrototypeRecord _recordFromRow(
    DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRow
    row,
  ) {
    final role = _roleForImplementationDesignRole(row.implementationDesignRole);
    return DebugOnlyBridgeAnalyzerAdapterPrototypeRecord(
      recordId: 'phase33u-${row.validationRowId}',
      role: role,
      sourceValidationRowId: row.validationRowId,
      sourceImplementationDesignRecordId:
          row.sourceImplementationDesignRecordId,
      sourceCaseId: row.sourceCaseId,
      sourcePhase: row.sourcePhase,
      implementationDesignRole: row.implementationDesignRole,
      developerOnly: true,
      inMemoryOnly: true,
      analyzerUnwired: true,
      contextOnly:
          role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.contextOnlyRecord,
      warningLimited:
          role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
              .warningLimitedRecord,
      proofBoundaryOnly:
          role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.proofBoundaryRecord,
      excludedGuard:
          role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.excludedGuardRecord,
      inactive: role.isInactiveBoundary,
      allowedFieldIds: role.isInactiveBoundary
          ? const <String>[]
          : _allowedInternalFieldIds,
      deniedFieldIds: _deniedFieldIds,
      blockedBoundaryIds: _sorted(row.blockedBoundaryIds),
      warningReasons: _sorted(row.warningReasons),
      proofLimitReasons: _sorted(row.proofLimitReasons),
      androidProofCaseIds: _sorted(row.androidProofCaseIds),
      ownerProofRequired: row.ownerProofRequired,
      activeDeniedFieldIds: _sorted(row.activeDeniedFieldIds),
      safetyFlags: _safeSafetyFlags,
      findings: const <String>[],
      recommendation: _phase33VRecommendation,
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeValidator {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeValidator();

  List<String> validateRecord(
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecord record,
  ) {
    final findings = <String>[];
    if (!DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.values.contains(
      record.role,
    )) {
      findings.add('unknownRecordRole');
    }
    if (!record.developerOnly || !record.inMemoryOnly) {
      findings.add('recordNotDeveloperOnlyInMemory');
    }
    if (!record.analyzerUnwired) findings.add('analyzerWiringEnabled');
    if (record.activeDeniedFieldIds.isNotEmpty) {
      findings.add('activeDeniedField');
    }
    if (record.allowedFieldIds.any(_isDeniedFieldId)) {
      findings.add('deniedFieldAllowedInternally');
    }
    if (record.deniedFieldIds.toSet().containsAll(_deniedFieldIds) == false) {
      findings.add('missingRequiredDeniedField');
    }
    for (final entry in _safetyFlagFindings.entries) {
      if (record.safetyFlags[entry.key] == true) findings.add(entry.value);
    }
    if (_isQuietRecord(record) &&
        record.role !=
            DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
                .excludedGuardRecord) {
      findings.add('quietPreparatoryPromoted');
    }
    if (record.sourceCaseId == _pvMultiPvBoundaryCaseId &&
        record.role !=
            DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
                .proofBoundaryRecord &&
        record.role !=
            DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
                .contextOnlyRecord) {
      findings.add('pvMultiPvPromotedBeyondBoundary');
    }
    if (_phase32ECaseIds.contains(record.sourceCaseId) &&
        record.androidProofCaseIds.isNotEmpty) {
      findings.add('phase32ECapturedAndroidProofClaim');
    }
    if (record.ownerProofRequired &&
        !record.proofLimitReasons.any(
          (reason) => reason.toLowerCase().contains('pv'),
        )) {
      findings.add('ownerProofWithoutPvMultiPvReason');
    }
    if (record.androidProofCaseIds.any(
      (caseId) => !_capturedAndroidProofIds.contains(caseId),
    )) {
      findings.add('unprovenAndroidProofId');
    }
    if (record.activeDeniedFieldIds.contains('thresholds')) {
      findings.add('thresholdLeak');
    }
    if (record.activeDeniedFieldIds.contains('productAdapterBehavior')) {
      findings.add('productAdapterBehavior');
    }
    if (record.activeDeniedFieldIds.contains('savedAnalysisIntegration')) {
      findings.add('savedAnalysisIntegration');
    }
    if (record.role ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
                .futureRequirementRecord &&
        record.recommendation != _phase33VRecommendation) {
      findings.add('missingPhase33VRequirement');
    }
    if (record.role.isInactiveBoundary && !record.inactive) {
      findings.add('inactiveBoundaryMadeActive');
    }
    return findings..sort();
  }

  List<String> validateResult(
    DebugOnlyBridgeAnalyzerAdapterPrototypeResult result,
  ) {
    final findings = <String>[];
    if (!result.sourceValidationSafeForPhase33U && result.safeForPhase33V) {
      findings.add('unsafePhase33TInputMarkedSkeletonReady');
    }
    if (result.futureRequirementRecordCount == 0) {
      findings.add('missingPhase33VRequirement');
    }
    if (result.policy.hasUnsafeAllowance) {
      findings.add('unsafePrototypePolicyAllowance');
    }
    if (result.inputPacket.hasUnsafeInput) {
      findings.add('unsafePrototypeInputPacket');
    }
    findings.addAll(validateReportText(result.renderMarkdown()));
    return findings..sort();
  }

  List<String> validateReportText(String reportText) {
    final lower = reportText.toLowerCase();
    return _rawReportLeakTokens
        .where((token) => lower.contains(token))
        .map((token) => 'reportTextLeak:$token')
        .toList(growable: false);
  }
}

DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
_roleForImplementationDesignRole(String role) {
  return switch (role) {
    'implementationInputPacketDesign' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.internalInputRecord,
    'implementationContextPacketDesign' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.contextOnlyRecord,
    'implementationWarningLimitedPacketDesign' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.warningLimitedRecord,
    'implementationProofBoundaryPacketDesign' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.proofBoundaryRecord,
    'implementationExcludedGuardPacketDesign' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.excludedGuardRecord,
    'implementationAllowedFieldDesign' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
          .allowedFieldBoundaryRecord,
    'implementationDeniedFieldDesign' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
          .deniedFieldBoundaryRecord,
    'implementationMapperDesign' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.mapperMetadataRecord,
    'implementationValidatorDesign' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.validatorMetadataRecord,
    'implementationDebugSnapshotDesign' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
          .debugSnapshotMetadataRecord,
    'implementationRuntimeBlocked' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.runtimeBlockedRecord,
    'implementationAnalyzerWiringBlocked' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
          .analyzerWiringBlockedRecord,
    'implementationEngineBlocked' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.engineBlockedRecord,
    'implementationSchedulerBlocked' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.schedulerBlockedRecord,
    'implementationProductAdapterBlocked' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
          .productAdapterBlockedRecord,
    'implementationSavedAnalysisBlocked' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
          .savedAnalysisBlockedRecord,
    'phase33TRequirement' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.futureRequirementRecord,
    _ =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
          .deniedFieldBoundaryRecord,
  };
}

bool _isQuietRecord(DebugOnlyBridgeAnalyzerAdapterPrototypeRecord record) {
  return record.sourceCaseId.contains('quiet-preparatory') ||
      record.blockedBoundaryIds.contains('quietPreparatoryCoreActivation') ||
      record.proofLimitReasons.contains(
        'quietPreparatoryExcludedFromActiveCoreOutput',
      );
}

Map<String, int> _roleCounts(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeRecord> records,
) {
  return <String, int>{
    for (final role in DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.values)
      role.wire: _countRole(records, role),
  };
}

List<String> _idsForRole(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeRecord> records,
  DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole role,
) {
  return _sorted(
    records
        .where((record) => record.role == role)
        .map((record) => record.recordId),
  );
}

List<String> _supportCaseIds(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeRecord> records,
) {
  return _sorted(
    records
        .map((record) => record.sourceCaseId)
        .where((caseId) => !caseId.startsWith('phase33')),
  );
}

String _renderRecordsForLeakCheck(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeRecord> records,
) {
  return records
      .map(
        (record) => [
          record.recordId,
          record.sourceCaseId,
          record.role.wire,
          ...record.blockedBoundaryIds,
          ...record.warningReasons,
          ...record.proofLimitReasons,
          ...record.findings,
        ].join(' '),
      )
      .join('\n');
}

int _countRole(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeRecord> records,
  DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole role,
) {
  return records.where((record) => record.role == role).length;
}

int _countFinding(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeRecord> records,
  String finding,
) {
  return records.where((record) => record.findings.contains(finding)).length;
}

int _countActiveDeniedField(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeRecord> records,
  String fieldId,
) {
  return records
      .where((record) => record.activeDeniedFieldIds.contains(fieldId))
      .length;
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

const _phase33VRecommendation =
    'validateDebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonImplementation';

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

const _allowedInternalFieldIds = <String>[
  'implementationDesignRecordId',
  'sourceValidationRowId',
  'sourceImplementationDesignRecordId',
  'sourceCaseId',
  'sourcePhase',
  'implementationDesignRole',
  'recordRole',
  'warningReasons',
  'proofLimitReasons',
  'androidProofBoundaryIds',
  'blockedBoundaryIds',
  'futurePrerequisites',
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

const _safeSafetyFlags = <String, bool>{
  'isProductOutput': false,
  'isClassifierLabel': false,
  'hasNumericScore': false,
  'hasAggregateScore': false,
  'ranksMoves': false,
  'isOfficialMetric': false,
  'exposesCpLoss': false,
  'exposesWinProbability': false,
  'exposesStockfishCommand': false,
  'exposesRawUci': false,
  'exposesPvDump': false,
  'callsEngine': false,
  'writesPersistence': false,
  'targetsUi': false,
  'targetsBackend': false,
  'executesScheduler': false,
  'wiresAnalyzer': false,
  'implementsRuntime': false,
  'implementsExecutablePrototype': false,
  'requiresAndroidCollector': false,
};

const _safetyFlagFindings = <String, String>{
  'isProductOutput': 'productOutput',
  'isClassifierLabel': 'classifierLabelLeak',
  'hasNumericScore': 'numericScoreLeak',
  'hasAggregateScore': 'aggregateScoreLeak',
  'ranksMoves': 'moveRankingLeak',
  'isOfficialMetric': 'officialMetricLeak',
  'exposesCpLoss': 'cpLossLeak',
  'exposesWinProbability': 'winProbabilityLeak',
  'exposesStockfishCommand': 'stockfishCommandLeak',
  'exposesRawUci': 'rawUciLeak',
  'exposesPvDump': 'pvDumpLeak',
  'callsEngine': 'engineCall',
  'writesPersistence': 'persistenceWrite',
  'targetsUi': 'uiTarget',
  'targetsBackend': 'backendTarget',
  'executesScheduler': 'schedulerExecution',
  'wiresAnalyzer': 'analyzerWiring',
  'implementsRuntime': 'runtimeImplementation',
  'implementsExecutablePrototype': 'executablePrototypeImplementation',
  'requiresAndroidCollector': 'androidCollectorRequired',
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

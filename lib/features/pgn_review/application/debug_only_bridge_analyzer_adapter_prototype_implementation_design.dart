import 'dart:convert';

import 'debug_only_bridge_analyzer_adapter_boundary_design.dart';
import 'debug_only_bridge_analyzer_adapter_prototype_contract_design_validation.dart';
import 'golden_analysis_suite.dart';
import 'golden_android_proof_evidence.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignReportVersion =
    'debug-only-bridge-analyzer-adapter-prototype-implementation-design-v1';

enum DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignStatus {
  prototypeImplementationDesignReadyWithWarnings(
    'prototypeImplementationDesignReadyWithWarnings',
  ),
  prototypeImplementationDesignReadyClean(
    'prototypeImplementationDesignReadyClean',
  ),
  blockedByUnsafeContractValidation('blockedByUnsafeContractValidation'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidPrototypeImplementationDesign('invalidPrototypeImplementationDesign');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignStatus(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId {
  implementationInputPacketDesignGroup('implementationInputPacketDesignGroup'),
  implementationContextPacketDesignGroup(
    'implementationContextPacketDesignGroup',
  ),
  implementationWarningLimitedPacketDesignGroup(
    'implementationWarningLimitedPacketDesignGroup',
  ),
  implementationProofBoundaryPacketDesignGroup(
    'implementationProofBoundaryPacketDesignGroup',
  ),
  implementationExcludedGuardPacketDesignGroup(
    'implementationExcludedGuardPacketDesignGroup',
  ),
  implementationAllowedFieldDesignGroup(
    'implementationAllowedFieldDesignGroup',
  ),
  implementationDeniedFieldDesignGroup('implementationDeniedFieldDesignGroup'),
  implementationMapperDesignGroup('implementationMapperDesignGroup'),
  implementationValidatorDesignGroup('implementationValidatorDesignGroup'),
  implementationDebugSnapshotDesignGroup(
    'implementationDebugSnapshotDesignGroup',
  ),
  implementationRuntimeBlockedGroup('implementationRuntimeBlockedGroup'),
  implementationAnalyzerWiringBlockedGroup(
    'implementationAnalyzerWiringBlockedGroup',
  ),
  implementationEngineBlockedGroup('implementationEngineBlockedGroup'),
  implementationSchedulerBlockedGroup('implementationSchedulerBlockedGroup'),
  implementationProductAdapterBlockedGroup(
    'implementationProductAdapterBlockedGroup',
  ),
  implementationSavedAnalysisBlockedGroup(
    'implementationSavedAnalysisBlockedGroup',
  ),
  phase33TRequirementGroup('phase33TRequirementGroup');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole {
  implementationInputPacketDesign('implementationInputPacketDesign'),
  implementationContextPacketDesign('implementationContextPacketDesign'),
  implementationWarningLimitedPacketDesign(
    'implementationWarningLimitedPacketDesign',
  ),
  implementationProofBoundaryPacketDesign(
    'implementationProofBoundaryPacketDesign',
  ),
  implementationExcludedGuardPacketDesign(
    'implementationExcludedGuardPacketDesign',
  ),
  implementationAllowedFieldDesign('implementationAllowedFieldDesign'),
  implementationDeniedFieldDesign('implementationDeniedFieldDesign'),
  implementationMapperDesign('implementationMapperDesign'),
  implementationValidatorDesign('implementationValidatorDesign'),
  implementationDebugSnapshotDesign('implementationDebugSnapshotDesign'),
  implementationRuntimeBlocked('implementationRuntimeBlocked'),
  implementationAnalyzerWiringBlocked('implementationAnalyzerWiringBlocked'),
  implementationEngineBlocked('implementationEngineBlocked'),
  implementationSchedulerBlocked('implementationSchedulerBlocked'),
  implementationProductAdapterBlocked('implementationProductAdapterBlocked'),
  implementationSavedAnalysisBlocked('implementationSavedAnalysisBlocked'),
  phase33TRequirement('phase33TRequirement');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroup {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroup({
    required this.groupId,
    required this.recordIds,
    required this.status,
  });

  final DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId
  groupId;
  final List<String> recordIds;
  final String status;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'groupId': groupId.wire,
      'recordCount': recordIds.length,
      'recordIds': recordIds,
      'status': status,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord({
    required this.implementationDesignRecordId,
    required this.sourceValidationRowId,
    required this.sourceContractRecordId,
    required this.sourcePrototypeRecordId,
    required this.sourceCaseId,
    required this.sourcePhase,
    required this.prototypePacketRole,
    required this.contractRole,
    required this.implementationDesignRole,
    required this.allowedInternalFieldIds,
    required this.deniedFieldIds,
    required this.blockedBoundaryIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.androidProofCaseIds,
    required this.ownerProofRequired,
    required this.developerOnly,
    required this.designOnly,
    required this.analyzerUnwired,
    required this.runtimeBlocked,
    required this.executablePrototypeBlocked,
    required this.futureClassNames,
    required this.futurePacketNames,
    required this.futureMapperNames,
    required this.futureValidatorNames,
    required this.futureDebugSnapshotNames,
    required this.activeDeniedFieldIds,
    required this.safetyFlags,
    required this.findings,
    required this.recommendation,
  });

  final String implementationDesignRecordId;
  final String sourceValidationRowId;
  final String sourceContractRecordId;
  final String sourcePrototypeRecordId;
  final String sourceCaseId;
  final String sourcePhase;
  final String prototypePacketRole;
  final String contractRole;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
  implementationDesignRole;
  final List<String> allowedInternalFieldIds;
  final List<String> deniedFieldIds;
  final List<String> blockedBoundaryIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofCaseIds;
  final bool ownerProofRequired;
  final bool developerOnly;
  final bool designOnly;
  final bool analyzerUnwired;
  final bool runtimeBlocked;
  final bool executablePrototypeBlocked;
  final List<String> futureClassNames;
  final List<String> futurePacketNames;
  final List<String> futureMapperNames;
  final List<String> futureValidatorNames;
  final List<String> futureDebugSnapshotNames;
  final List<String> activeDeniedFieldIds;
  final DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags safetyFlags;
  final List<String> findings;
  final String recommendation;

  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord copyWith({
    String? implementationDesignRecordId,
    String? sourceValidationRowId,
    String? sourceContractRecordId,
    String? sourcePrototypeRecordId,
    String? sourceCaseId,
    String? sourcePhase,
    String? prototypePacketRole,
    String? contractRole,
    DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole?
    implementationDesignRole,
    List<String>? allowedInternalFieldIds,
    List<String>? deniedFieldIds,
    List<String>? blockedBoundaryIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? androidProofCaseIds,
    bool? ownerProofRequired,
    bool? developerOnly,
    bool? designOnly,
    bool? analyzerUnwired,
    bool? runtimeBlocked,
    bool? executablePrototypeBlocked,
    List<String>? futureClassNames,
    List<String>? futurePacketNames,
    List<String>? futureMapperNames,
    List<String>? futureValidatorNames,
    List<String>? futureDebugSnapshotNames,
    List<String>? activeDeniedFieldIds,
    DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags? safetyFlags,
    List<String>? findings,
    String? recommendation,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord(
      implementationDesignRecordId:
          implementationDesignRecordId ?? this.implementationDesignRecordId,
      sourceValidationRowId:
          sourceValidationRowId ?? this.sourceValidationRowId,
      sourceContractRecordId:
          sourceContractRecordId ?? this.sourceContractRecordId,
      sourcePrototypeRecordId:
          sourcePrototypeRecordId ?? this.sourcePrototypeRecordId,
      sourceCaseId: sourceCaseId ?? this.sourceCaseId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      prototypePacketRole: prototypePacketRole ?? this.prototypePacketRole,
      contractRole: contractRole ?? this.contractRole,
      implementationDesignRole:
          implementationDesignRole ?? this.implementationDesignRole,
      allowedInternalFieldIds:
          allowedInternalFieldIds ?? this.allowedInternalFieldIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      developerOnly: developerOnly ?? this.developerOnly,
      designOnly: designOnly ?? this.designOnly,
      analyzerUnwired: analyzerUnwired ?? this.analyzerUnwired,
      runtimeBlocked: runtimeBlocked ?? this.runtimeBlocked,
      executablePrototypeBlocked:
          executablePrototypeBlocked ?? this.executablePrototypeBlocked,
      futureClassNames: futureClassNames ?? this.futureClassNames,
      futurePacketNames: futurePacketNames ?? this.futurePacketNames,
      futureMapperNames: futureMapperNames ?? this.futureMapperNames,
      futureValidatorNames: futureValidatorNames ?? this.futureValidatorNames,
      futureDebugSnapshotNames:
          futureDebugSnapshotNames ?? this.futureDebugSnapshotNames,
      activeDeniedFieldIds: activeDeniedFieldIds ?? this.activeDeniedFieldIds,
      safetyFlags: safetyFlags ?? this.safetyFlags,
      findings: findings ?? this.findings,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'implementationDesignRecordId': implementationDesignRecordId,
      'sourceValidationRowId': sourceValidationRowId,
      'sourceContractRecordId': sourceContractRecordId,
      'sourcePrototypeRecordId': sourcePrototypeRecordId,
      'sourceCaseId': sourceCaseId,
      'sourcePhase': sourcePhase,
      'prototypePacketRole': prototypePacketRole,
      'contractRole': contractRole,
      'implementationDesignRole': implementationDesignRole.wire,
      'allowedInternalFieldIds': allowedInternalFieldIds,
      'deniedFieldIds': deniedFieldIds,
      'blockedBoundaryIds': blockedBoundaryIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'androidProofCaseIds': androidProofCaseIds,
      'ownerProofRequired': ownerProofRequired,
      'developerOnly': developerOnly,
      'designOnly': designOnly,
      'analyzerUnwired': analyzerUnwired,
      'runtimeBlocked': runtimeBlocked,
      'executablePrototypeBlocked': executablePrototypeBlocked,
      'futureClassNames': futureClassNames,
      'futurePacketNames': futurePacketNames,
      'futureMapperNames': futureMapperNames,
      'futureValidatorNames': futureValidatorNames,
      'futureDebugSnapshotNames': futureDebugSnapshotNames,
      'activeDeniedFieldIds': activeDeniedFieldIds,
      'safetyFlags': safetyFlags.toJson(),
      'findings': findings,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignResult {
  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignResult({
    required this.status,
    required this.sourceContractValidationStatus,
    required this.sourceContractValidationSafeForPhase33S,
    required this.sourceContractValidationRecommendation,
    required this.implementationDesignGroups,
    required this.implementationDesignRecords,
    required this.reportFindings,
    required this.safeForPhase33T,
    required this.phase33TRecommendation,
  }) : totalImplementationDesignGroups = implementationDesignGroups.length,
       totalImplementationDesignRecords = implementationDesignRecords.length,
       inputPacketDesignCount = _countRole(
         implementationDesignRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationInputPacketDesign,
       ),
       contextPacketDesignCount = _countRole(
         implementationDesignRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationContextPacketDesign,
       ),
       warningLimitedPacketDesignCount = _countRole(
         implementationDesignRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationWarningLimitedPacketDesign,
       ),
       proofBoundaryPacketDesignCount = _countRole(
         implementationDesignRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationProofBoundaryPacketDesign,
       ),
       excludedGuardPacketDesignCount = _countRole(
         implementationDesignRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationExcludedGuardPacketDesign,
       ),
       allowedFieldDesignCount = _countRole(
         implementationDesignRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationAllowedFieldDesign,
       ),
       deniedFieldDesignCount = _countRole(
         implementationDesignRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationDeniedFieldDesign,
       ),
       mapperDesignCount = _countRole(
         implementationDesignRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationMapperDesign,
       ),
       validatorDesignCount = _countRole(
         implementationDesignRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationValidatorDesign,
       ),
       debugSnapshotDesignCount = _countRole(
         implementationDesignRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationDebugSnapshotDesign,
       ),
       runtimeBlockedCount = _countRole(
         implementationDesignRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationRuntimeBlocked,
       ),
       analyzerWiringBlockedCount = _countRole(
         implementationDesignRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationAnalyzerWiringBlocked,
       ),
       engineBlockedCount = _countRole(
         implementationDesignRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationEngineBlocked,
       ),
       schedulerBlockedCount = _countRole(
         implementationDesignRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationSchedulerBlocked,
       ),
       productAdapterBlockedCount = _countRole(
         implementationDesignRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationProductAdapterBlocked,
       ),
       savedAnalysisBlockedCount = _countRole(
         implementationDesignRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationSavedAnalysisBlocked,
       ),
       futureRequirementCount = _countRole(
         implementationDesignRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .phase33TRequirement,
       ),
       proposedClassNames = _sorted(
         implementationDesignRecords.expand(
           (record) => record.futureClassNames,
         ),
       ),
       proposedPacketNames = _sorted(
         implementationDesignRecords.expand(
           (record) => record.futurePacketNames,
         ),
       ),
       proposedMapperNames = _sorted(
         implementationDesignRecords.expand(
           (record) => record.futureMapperNames,
         ),
       ),
       proposedValidatorNames = _sorted(
         implementationDesignRecords.expand(
           (record) => record.futureValidatorNames,
         ),
       ),
       proposedDebugSnapshotNames = _sorted(
         implementationDesignRecords.expand(
           (record) => record.futureDebugSnapshotNames,
         ),
       ),
       blockerCount = implementationDesignRecords
           .where((record) => record.findings.isNotEmpty)
           .length,
       criticalCount = reportFindings.where(_isCriticalFinding).length,
       activeDeniedFieldCount = implementationDesignRecords.fold<int>(
         0,
         (total, record) => total + record.activeDeniedFieldIds.length,
       ),
       productOutputCount = implementationDesignRecords
           .where((record) => record.safetyFlags.isProductOutput)
           .length,
       labelLeakCount = implementationDesignRecords
           .where((record) => record.safetyFlags.emitsClassifierLabel)
           .length,
       finalLabelLeakCount = implementationDesignRecords
           .where((record) => record.safetyFlags.emitsFinalLabel)
           .length,
       scoreLeakCount = implementationDesignRecords
           .where(
             (record) =>
                 record.safetyFlags.hasNumericScore ||
                 record.safetyFlags.hasAggregateScore,
           )
           .length,
       metricLeakCount = implementationDesignRecords
           .where((record) => record.safetyFlags.emitsOfficialMetric)
           .length,
       cpLossLeakCount = implementationDesignRecords
           .where((record) => record.safetyFlags.exposesCpLoss)
           .length,
       winProbabilityLeakCount = implementationDesignRecords
           .where((record) => record.safetyFlags.exposesWinProbability)
           .length,
       moveRankingLeakCount = implementationDesignRecords
           .where((record) => record.safetyFlags.ranksMoves)
           .length,
       thresholdLeakCount = _countActiveDeniedField(
         implementationDesignRecords,
         'thresholds',
       ),
       uiTargetCount = implementationDesignRecords
           .where((record) => record.safetyFlags.targetsUi)
           .length,
       backendTargetCount = implementationDesignRecords
           .where((record) => record.safetyFlags.targetsBackend)
           .length,
       persistenceWriteCount = implementationDesignRecords
           .where((record) => record.safetyFlags.writesPersistence)
           .length,
       engineCallCount = implementationDesignRecords
           .where((record) => record.safetyFlags.callsEngine)
           .length,
       schedulerExecutionCount = implementationDesignRecords
           .where((record) => record.safetyFlags.executesScheduler)
           .length,
       analyzerWiringCount = implementationDesignRecords
           .where((record) => record.safetyFlags.wiresAnalyzer)
           .length,
       runtimeImplementationCount = implementationDesignRecords
           .where((record) => record.safetyFlags.implementsRuntime)
           .length,
       executablePrototypeCount = implementationDesignRecords
           .where((record) => record.safetyFlags.implementsExecutablePrototype)
           .length,
       productAdapterBehaviorCount = _countActiveDeniedField(
         implementationDesignRecords,
         'productAdapterBehavior',
       ),
       savedAnalysisIntegrationCount = _countActiveDeniedField(
         implementationDesignRecords,
         'savedAnalysisIntegration',
       ),
       stockfishCommandLeakCount = implementationDesignRecords
           .where((record) => record.safetyFlags.exposesStockfishCommand)
           .length,
       rawUciLeakCount = implementationDesignRecords
           .where((record) => record.safetyFlags.exposesRawUci)
           .length,
       pvDumpLeakCount = implementationDesignRecords
           .where((record) => record.safetyFlags.exposesPvDump)
           .length,
       androidCollectorRequirementCount = implementationDesignRecords
           .where((record) => record.safetyFlags.requiresAndroidCollector)
           .length,
       unprovenAndroidProofCount = implementationDesignRecords
           .where(
             (record) => record.androidProofCaseIds.any(
               (caseId) => !_capturedAndroidProofIds.contains(caseId),
             ),
           )
           .length,
       phase32EProofClaimCount = implementationDesignRecords
           .where(
             (record) =>
                 _phase32ECaseIds.contains(record.sourceCaseId) &&
                 record.androidProofCaseIds.isNotEmpty,
           )
           .length,
       ownerProofQueueCount = implementationDesignRecords
           .where((record) => record.ownerProofRequired)
           .length {
    unsafeCount =
        implementationDesignRecords
            .where((record) => record.safetyFlags.hasUnsafeFlag)
            .length +
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

  final DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignStatus
  status;
  final String sourceContractValidationStatus;
  final bool sourceContractValidationSafeForPhase33S;
  final String sourceContractValidationRecommendation;
  final List<DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroup>
  implementationDesignGroups;
  final List<DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord>
  implementationDesignRecords;
  final List<String> reportFindings;
  final bool safeForPhase33T;
  final String phase33TRecommendation;
  final int totalImplementationDesignGroups;
  final int totalImplementationDesignRecords;
  final int inputPacketDesignCount;
  final int contextPacketDesignCount;
  final int warningLimitedPacketDesignCount;
  final int proofBoundaryPacketDesignCount;
  final int excludedGuardPacketDesignCount;
  final int allowedFieldDesignCount;
  final int deniedFieldDesignCount;
  final int mapperDesignCount;
  final int validatorDesignCount;
  final int debugSnapshotDesignCount;
  final int runtimeBlockedCount;
  final int analyzerWiringBlockedCount;
  final int engineBlockedCount;
  final int schedulerBlockedCount;
  final int productAdapterBlockedCount;
  final int savedAnalysisBlockedCount;
  final int futureRequirementCount;
  final List<String> proposedClassNames;
  final List<String> proposedPacketNames;
  final List<String> proposedMapperNames;
  final List<String> proposedValidatorNames;
  final List<String> proposedDebugSnapshotNames;
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
      !safeForPhase33T ||
      !sourceContractValidationSafeForPhase33S;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln(
        '# Debug-Only Bridge Analyzer Adapter Prototype Implementation Design',
      )
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignReportVersion',
      )
      ..writeln('- implementation design status: ${status.wire}')
      ..writeln(
        '- source contract validation status: '
        '$sourceContractValidationStatus',
      )
      ..writeln('- safe for Phase 33T: $safeForPhase33T')
      ..writeln('- Phase 33T recommendation: $phase33TRecommendation')
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
      ..writeln('## Implementation Design Group Table')
      ..writeln('| Group | Record count | Status |')
      ..writeln('| --- | --- | --- |');
    for (final group in implementationDesignGroups) {
      buffer.writeln(
        '| ${group.groupId.wire} | ${group.recordIds.length} | '
        '${group.status} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Future Prototype Names')
      ..writeln('- class names: ${_ids(proposedClassNames)}')
      ..writeln('- packet names: ${_ids(proposedPacketNames)}')
      ..writeln('- mapper names: ${_ids(proposedMapperNames)}')
      ..writeln('- validator names: ${_ids(proposedValidatorNames)}')
      ..writeln('- debug snapshot names: ${_ids(proposedDebugSnapshotNames)}')
      ..writeln()
      ..writeln('## Implementation Design Record Table')
      ..writeln(
        '| Record | Source validation | Case ID | Source phase | '
        'Contract role | Implementation role | Analyzer unwired | '
        'Runtime blocked | Executable blocked | Active denied fields | '
        'Findings | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final record in implementationDesignRecords) {
      buffer.writeln(
        '| ${record.implementationDesignRecordId} | '
        '${record.sourceValidationRowId} | ${record.sourceCaseId} | '
        '${record.sourcePhase} | ${record.contractRole} | '
        '${record.implementationDesignRole.wire} | '
        '${record.analyzerUnwired} | ${record.runtimeBlocked} | '
        '${record.executablePrototypeBlocked} | '
        '${_ids(record.activeDeniedFieldIds)} | ${_ids(record.findings)} | '
        '${record.recommendation} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Allowed and Denied Field Design')
      ..writeln('- allowed internal fields: ${_ids(_allowedInternalFieldIds)}')
      ..writeln('- denied fields: ${_ids(_deniedFieldIds)}')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- threshold leak count: $thresholdLeakCount')
      ..writeln()
      ..writeln('## Mapper Validator Snapshot Design')
      ..writeln('- mapper design count: $mapperDesignCount')
      ..writeln('- validator design count: $validatorDesignCount')
      ..writeln('- debug snapshot design count: $debugSnapshotDesignCount')
      ..writeln()
      ..writeln('## Blocked Boundary Design')
      ..writeln('- analyzer wiring count: $analyzerWiringCount')
      ..writeln('- runtime implementation count: $runtimeImplementationCount')
      ..writeln('- executable prototype count: $executablePrototypeCount')
      ..writeln('- engine call count: $engineCallCount')
      ..writeln('- scheduler execution count: $schedulerExecutionCount')
      ..writeln('- persistence write count: $persistenceWriteCount')
      ..writeln('- UI target count: $uiTargetCount')
      ..writeln('- backend target count: $backendTargetCount')
      ..writeln(
        '- product adapter behavior count: $productAdapterBehaviorCount',
      )
      ..writeln(
        '- saved analysis integration count: $savedAnalysisIntegrationCount',
      )
      ..writeln('- Stockfish command leak count: $stockfishCommandLeakCount')
      ..writeln('- raw UCI leak count: $rawUciLeakCount')
      ..writeln('- PV dump leak count: $pvDumpLeakCount')
      ..writeln()
      ..writeln('## Android Proof Boundary')
      ..writeln(
        '- captured Android proof IDs: ${_ids(_capturedAndroidProofIds)}',
      )
      ..writeln('- unproven Android proof count: $unprovenAndroidProofCount')
      ..writeln('- Phase 32E proof claim count: $phase32EProofClaimCount')
      ..writeln()
      ..writeln('## Owner Proof Boundary')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Phase 33T Requirement')
      ..writeln('- future requirement count: $futureRequirementCount')
      ..writeln('- recommendation: $phase33TRecommendation')
      ..writeln()
      ..writeln('## Report Findings')
      ..writeln('- findings: ${_ids(reportFindings)}');
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignReportVersion,
      'implementationDesignStatus': status.wire,
      'sourceContractValidationStatus': sourceContractValidationStatus,
      'sourceContractValidationSafeForPhase33S':
          sourceContractValidationSafeForPhase33S,
      'sourceContractValidationRecommendation':
          sourceContractValidationRecommendation,
      'safeForPhase33T': safeForPhase33T,
      'phase33TRecommendation': phase33TRecommendation,
      'futureNames': <String, Object?>{
        'classNames': proposedClassNames,
        'packetNames': proposedPacketNames,
        'mapperNames': proposedMapperNames,
        'validatorNames': proposedValidatorNames,
        'debugSnapshotNames': proposedDebugSnapshotNames,
      },
      'counts': <String, Object?>{
        'totalImplementationDesignGroups': totalImplementationDesignGroups,
        'totalImplementationDesignRecords': totalImplementationDesignRecords,
        'inputPacketDesignCount': inputPacketDesignCount,
        'contextPacketDesignCount': contextPacketDesignCount,
        'warningLimitedPacketDesignCount': warningLimitedPacketDesignCount,
        'proofBoundaryPacketDesignCount': proofBoundaryPacketDesignCount,
        'excludedGuardPacketDesignCount': excludedGuardPacketDesignCount,
        'allowedFieldDesignCount': allowedFieldDesignCount,
        'deniedFieldDesignCount': deniedFieldDesignCount,
        'mapperDesignCount': mapperDesignCount,
        'validatorDesignCount': validatorDesignCount,
        'debugSnapshotDesignCount': debugSnapshotDesignCount,
        'runtimeBlockedCount': runtimeBlockedCount,
        'analyzerWiringBlockedCount': analyzerWiringBlockedCount,
        'engineBlockedCount': engineBlockedCount,
        'schedulerBlockedCount': schedulerBlockedCount,
        'productAdapterBlockedCount': productAdapterBlockedCount,
        'savedAnalysisBlockedCount': savedAnalysisBlockedCount,
        'futureRequirementCount': futureRequirementCount,
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
      'capturedAndroidProofIds': _capturedAndroidProofIds.toList()..sort(),
      'implementationDesignGroups': implementationDesignGroups
          .map((group) => group.toJson())
          .toList(growable: false),
      'implementationDesignRecords': implementationDesignRecords
          .map((record) => record.toJson())
          .toList(growable: false),
      'reportFindings': reportFindings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesign {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesign({
    this.validator =
        const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidator(),
  });

  final DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidator
  validator;

  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignResult evaluate({
    DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationResult?
    contractValidationResult,
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final source =
        contractValidationResult ??
        const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidation()
            .evaluate(cases: cases);
    final knownCaseIds = {
      ...cases.map((caseData) => caseData.id),
      ...androidProofEvidence.targetCaseIds,
    };
    final records =
        <DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord>[
          ...source.validationRows.map(_recordFromValidationRow),
          _syntheticRecord(
            recordId: 'phase33s-mapper-design',
            role:
                DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                    .implementationMapperDesign,
            blockedBoundaryIds: const <String>[
              'runtimeImplementation',
              'analyzerWiring',
              'engineCall',
            ],
            futureMapperNames: const <String>[
              'DebugOnlyBridgeAnalyzerAdapterPrototypeMapper',
            ],
          ),
          _syntheticRecord(
            recordId: 'phase33s-validator-design',
            role:
                DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                    .implementationValidatorDesign,
            blockedBoundaryIds: const <String>[
              'activeDeniedFields',
              'productOutput',
              'rawUci',
              'pvDump',
            ],
            futureValidatorNames: const <String>[
              'DebugOnlyBridgeAnalyzerAdapterPrototypeValidator',
            ],
          ),
          _syntheticRecord(
            recordId: 'phase33s-debug-snapshot-design',
            role:
                DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                    .implementationDebugSnapshotDesign,
            blockedBoundaryIds: const <String>[
              'productOutput',
              'numericMoveScores',
              'rawUci',
              'pvDump',
            ],
            futureDebugSnapshotNames: const <String>[
              'DebugOnlyBridgeAnalyzerAdapterPrototypeDebugSnapshot',
            ],
          ),
          _syntheticRecord(
            recordId: 'phase33s-product-adapter-blocked',
            role:
                DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                    .implementationProductAdapterBlocked,
            blockedBoundaryIds: const <String>[
              'productAdapterBehavior',
              'productOutput',
              'finalMoveLabels',
            ],
          ),
          _syntheticRecord(
            recordId: 'phase33s-saved-analysis-blocked',
            role:
                DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                    .implementationSavedAnalysisBlocked,
            blockedBoundaryIds: const <String>[
              'savedAnalysisIntegration',
              'persistenceWrite',
              'cacheWrite',
              'databaseWrite',
            ],
          ),
          _syntheticRecord(
            recordId: 'phase33s-phase33t-requirement',
            role:
                DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                    .phase33TRequirement,
            blockedBoundaryIds: const <String>[
              'runtimeImplementation',
              'analyzerWiring',
              'productOutput',
            ],
          ),
        ];
    final validatedRecords = records
        .map(
          (record) => record.copyWith(
            findings: validator.validateRecord(
              record,
              knownCaseIds: knownCaseIds,
            ),
          ),
        )
        .toList(growable: false);
    final groups = _groupsForRecords(validatedRecords);
    final reportFindings = validator.validateReportText(
      _renderRecordsForLeakCheck(validatedRecords),
    );
    final sourceSafe =
        source.safeForPhase33S &&
        source.phase33SRecommendation ==
            'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesign' &&
        !source.hasUnsafePolicyViolation;
    final hasFutureRequirement = validatedRecords.any(
      (record) =>
          record.implementationDesignRole ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
              .phase33TRequirement,
    );
    final hasRecordFindings = validatedRecords.any(
      (record) => record.findings.isNotEmpty,
    );
    final safe =
        sourceSafe &&
        hasFutureRequirement &&
        !hasRecordFindings &&
        reportFindings.isEmpty;
    final status = !sourceSafe
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignStatus
              .blockedByUnsafeContractValidation
        : !hasFutureRequirement
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignStatus
              .invalidPrototypeImplementationDesign
        : hasRecordFindings || reportFindings.isNotEmpty
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignStatus
              .blockedByPolicyBoundary
        : validatedRecords.any(
            (record) =>
                record.warningReasons.isNotEmpty ||
                record.proofLimitReasons.isNotEmpty,
          )
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignStatus
              .prototypeImplementationDesignReadyWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignStatus
              .prototypeImplementationDesignReadyClean;

    return DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignResult(
      status: status,
      sourceContractValidationStatus: source.status.wire,
      sourceContractValidationSafeForPhase33S: source.safeForPhase33S,
      sourceContractValidationRecommendation: source.phase33SRecommendation,
      implementationDesignGroups: groups,
      implementationDesignRecords: validatedRecords,
      reportFindings: reportFindings,
      safeForPhase33T: safe,
      phase33TRecommendation: safe
          ? _phase33TRecommendation
          : 'blockedByUnsafeAnalyzerAdapterPrototypeImplementationDesign',
    );
  }

  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord
  _recordFromValidationRow(
    DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationRow row,
  ) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord(
      implementationDesignRecordId: 'phase33s-${row.validationRowId}',
      sourceValidationRowId: row.validationRowId,
      sourceContractRecordId: row.sourceContractRecordId,
      sourcePrototypeRecordId: row.sourcePrototypeRecordId,
      sourceCaseId: row.sourceCaseId,
      sourcePhase: row.sourcePhase,
      prototypePacketRole: row.prototypePacketRole,
      contractRole: row.contractRole,
      implementationDesignRole: _roleForContractRole(row.contractRole),
      allowedInternalFieldIds: _allowedInternalFieldIds,
      deniedFieldIds: _deniedFieldIds,
      blockedBoundaryIds: _sorted(row.blockedBoundaryIds),
      warningReasons: _sorted(row.warningReasons),
      proofLimitReasons: _sorted(row.proofLimitReasons),
      androidProofCaseIds: _sorted(row.androidProofCaseIds),
      ownerProofRequired: row.ownerProofRequired,
      developerOnly: true,
      designOnly: true,
      analyzerUnwired: true,
      runtimeBlocked: true,
      executablePrototypeBlocked: true,
      futureClassNames: _futureClassNames,
      futurePacketNames: _futurePacketNamesForContractRole(row.contractRole),
      futureMapperNames: const <String>[],
      futureValidatorNames: const <String>[],
      futureDebugSnapshotNames: const <String>[],
      activeDeniedFieldIds: _sorted(row.activeDeniedFieldIds),
      safetyFlags: const DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(),
      findings: const <String>[],
      recommendation: _phase33TRecommendation,
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidator {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidator();

  List<String> validateRecord(
    DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord record, {
    required Set<String> knownCaseIds,
  }) {
    final findings = <String>[];
    final knownSyntheticRecord =
        record.sourceCaseId == 'phase33s' ||
        record.sourceCaseId == 'phase33q' ||
        record.sourceCaseId == 'phase33m' ||
        record.sourceCaseId.startsWith('phase33');
    if (!knownSyntheticRecord && !knownCaseIds.contains(record.sourceCaseId)) {
      findings.add('unknownImplementationDesignSourceCase');
    }
    if (!DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole.values
        .contains(record.implementationDesignRole)) {
      findings.add('unknownImplementationDesignRole');
    }
    if (!record.developerOnly) findings.add('developerOnlyDisabled');
    if (!record.designOnly) findings.add('designOnlyDisabled');
    if (!record.analyzerUnwired) findings.add('analyzerWiringEnabled');
    if (!record.runtimeBlocked) findings.add('runtimeImplementation');
    if (!record.executablePrototypeBlocked) {
      findings.add('executablePrototypeImplementation');
    }
    if (record.activeDeniedFieldIds.isNotEmpty) {
      findings.add('activeDeniedField');
    }
    if (record.safetyFlags.isProductOutput) findings.add('productOutput');
    if (record.safetyFlags.emitsClassifierLabel) {
      findings.add('classifierLabelLeak');
    }
    if (record.safetyFlags.emitsFinalLabel) findings.add('finalLabelLeak');
    if (record.safetyFlags.hasNumericScore) findings.add('numericScoreLeak');
    if (record.safetyFlags.hasAggregateScore) {
      findings.add('aggregateScoreLeak');
    }
    if (record.safetyFlags.ranksMoves) findings.add('moveRankingLeak');
    if (record.safetyFlags.emitsOfficialMetric) {
      findings.add('officialMetricLeak');
    }
    if (record.safetyFlags.exposesCpLoss) findings.add('cpLossLeak');
    if (record.safetyFlags.exposesWinProbability) {
      findings.add('winProbabilityLeak');
    }
    if (record.safetyFlags.targetsUi) findings.add('uiTarget');
    if (record.safetyFlags.targetsBackend) findings.add('backendTarget');
    if (record.safetyFlags.writesPersistence) findings.add('persistenceWrite');
    if (record.safetyFlags.callsEngine) findings.add('engineCall');
    if (record.safetyFlags.executesScheduler) {
      findings.add('schedulerExecution');
    }
    if (record.safetyFlags.wiresAnalyzer) findings.add('analyzerWiring');
    if (record.safetyFlags.implementsRuntime) {
      findings.add('runtimeImplementation');
    }
    if (record.safetyFlags.implementsExecutablePrototype) {
      findings.add('executablePrototypeImplementation');
    }
    if (record.safetyFlags.exposesStockfishCommand) {
      findings.add('stockfishCommandLeak');
    }
    if (record.safetyFlags.exposesRawUci) findings.add('rawUciLeak');
    if (record.safetyFlags.exposesPvDump) findings.add('pvDumpLeak');
    if (record.safetyFlags.requiresAndroidCollector) {
      findings.add('androidCollectorRequired');
    }
    if (_isQuietRecord(record) &&
        record.implementationDesignRole !=
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                .implementationExcludedGuardPacketDesign) {
      findings.add('quietPreparatoryPromoted');
    }
    if (record.sourceCaseId == _pvMultiPvBoundaryCaseId &&
        record.implementationDesignRole !=
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                .implementationProofBoundaryPacketDesign &&
        record.implementationDesignRole !=
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                .implementationContextPacketDesign) {
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
    if (record.allowedInternalFieldIds.any(
      (fieldId) => !_allowedInternalFieldIds.contains(fieldId),
    )) {
      findings.add('nonMetadataAllowedInternalField');
    }
    if (record.allowedInternalFieldIds.any(record.deniedFieldIds.contains)) {
      findings.add('deniedFieldAllowedInternally');
    }
    if (record.deniedFieldIds.contains('productAdapterBehavior') == false ||
        record.deniedFieldIds.contains('savedAnalysisIntegration') == false ||
        record.deniedFieldIds.contains('rawUci') == false ||
        record.deniedFieldIds.contains('pvDump') == false ||
        record.deniedFieldIds.contains('stockfishCommand') == false) {
      findings.add('missingRequiredDeniedField');
    }
    if (record.implementationDesignRole ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                .phase33TRequirement &&
        record.recommendation != _phase33TRecommendation) {
      findings.add('missingPhase33TRequirement');
    }
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

DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord
_syntheticRecord({
  required String recordId,
  required DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole role,
  required List<String> blockedBoundaryIds,
  List<String> futureMapperNames = const <String>[],
  List<String> futureValidatorNames = const <String>[],
  List<String> futureDebugSnapshotNames = const <String>[],
}) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord(
    implementationDesignRecordId: recordId,
    sourceValidationRowId: 'phase33s-synthetic',
    sourceContractRecordId: 'phase33s-implementation-design',
    sourcePrototypeRecordId: 'phase33s-implementation-design',
    sourceCaseId: 'phase33s',
    sourcePhase: 'Phase 33S',
    prototypePacketRole: 'phase33sSyntheticImplementationDesign',
    contractRole: 'phase33sSyntheticImplementationDesign',
    implementationDesignRole: role,
    allowedInternalFieldIds: _allowedInternalFieldIds,
    deniedFieldIds: _deniedFieldIds,
    blockedBoundaryIds: _sorted(blockedBoundaryIds),
    warningReasons: const <String>['implementationDesignOnlyNoRuntimeWiring'],
    proofLimitReasons: const <String>[],
    androidProofCaseIds: const <String>[],
    ownerProofRequired: false,
    developerOnly: true,
    designOnly: true,
    analyzerUnwired: true,
    runtimeBlocked: true,
    executablePrototypeBlocked: true,
    futureClassNames: _futureClassNames,
    futurePacketNames: const <String>[],
    futureMapperNames: futureMapperNames,
    futureValidatorNames: futureValidatorNames,
    futureDebugSnapshotNames: futureDebugSnapshotNames,
    activeDeniedFieldIds: const <String>[],
    safetyFlags: const DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(),
    findings: const <String>[],
    recommendation: _phase33TRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
_roleForContractRole(String contractRole) {
  return switch (contractRole) {
    'internalInputContract' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
          .implementationInputPacketDesign,
    'contextOnlyContract' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
          .implementationContextPacketDesign,
    'warningLimitedContract' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
          .implementationWarningLimitedPacketDesign,
    'proofBoundaryContract' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
          .implementationProofBoundaryPacketDesign,
    'excludedGuardContract' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
          .implementationExcludedGuardPacketDesign,
    'allowedInternalFieldContract' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
          .implementationAllowedFieldDesign,
    'runtimeBlockedContract' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
          .implementationRuntimeBlocked,
    'analyzerWiringBlockedContract' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
          .implementationAnalyzerWiringBlocked,
    'engineBlockedContract' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
          .implementationEngineBlocked,
    'schedulerBlockedContract' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
          .implementationSchedulerBlocked,
    'futureRequirementContract' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
          .phase33TRequirement,
    _ =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
          .implementationDeniedFieldDesign,
  };
}

List<String> _futurePacketNamesForContractRole(String contractRole) {
  return switch (contractRole) {
    'internalInputContract' => const <String>[
      'DebugOnlyBridgeAnalyzerAdapterPrototypeInputPacket',
    ],
    'contextOnlyContract' => const <String>[
      'DebugOnlyBridgeAnalyzerAdapterPrototypeContextPacket',
    ],
    'warningLimitedContract' => const <String>[
      'DebugOnlyBridgeAnalyzerAdapterPrototypeRecord',
    ],
    'proofBoundaryContract' => const <String>[
      'DebugOnlyBridgeAnalyzerAdapterPrototypeRecord',
    ],
    'excludedGuardContract' => const <String>[
      'DebugOnlyBridgeAnalyzerAdapterPrototypeRecord',
    ],
    'allowedInternalFieldContract' => const <String>[
      'DebugOnlyBridgeAnalyzerAdapterPrototypePolicy',
    ],
    'deniedFieldContract' => const <String>[
      'DebugOnlyBridgeAnalyzerAdapterPrototypePolicy',
    ],
    _ => const <String>[],
  };
}

List<DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroup>
_groupsForRecords(
  List<DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord>
  records,
) {
  List<String> idsFor(
    DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole role,
  ) {
    return records
        .where((record) => record.implementationDesignRole == role)
        .map((record) => record.implementationDesignRecordId)
        .toList(growable: false);
  }

  return <DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroup>[
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId
          .implementationInputPacketDesignGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationInputPacketDesign,
      ),
      'futureInternalOnly',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId
          .implementationContextPacketDesignGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationContextPacketDesign,
      ),
      'contextOnly',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId
          .implementationWarningLimitedPacketDesignGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationWarningLimitedPacketDesign,
      ),
      'warningLimited',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId
          .implementationProofBoundaryPacketDesignGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationProofBoundaryPacketDesign,
      ),
      'proofBoundaryOnly',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId
          .implementationExcludedGuardPacketDesignGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationExcludedGuardPacketDesign,
      ),
      'excludedGuard',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId
          .implementationAllowedFieldDesignGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationAllowedFieldDesign,
      ),
      'metadataOnly',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId
          .implementationDeniedFieldDesignGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationDeniedFieldDesign,
      ),
      'deniedInactive',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId
          .implementationMapperDesignGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationMapperDesign,
      ),
      'mapperMetadataOnly',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId
          .implementationValidatorDesignGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationValidatorDesign,
      ),
      'validatorMetadataOnly',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId
          .implementationDebugSnapshotDesignGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationDebugSnapshotDesign,
      ),
      'debugSnapshotMetadataOnly',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId
          .implementationRuntimeBlockedGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationRuntimeBlocked,
      ),
      'runtimeBlocked',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId
          .implementationAnalyzerWiringBlockedGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationAnalyzerWiringBlocked,
      ),
      'analyzerWiringBlocked',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId
          .implementationEngineBlockedGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationEngineBlocked,
      ),
      'engineBlocked',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId
          .implementationSchedulerBlockedGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationSchedulerBlocked,
      ),
      'schedulerBlocked',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId
          .implementationProductAdapterBlockedGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationProductAdapterBlocked,
      ),
      'productAdapterBlocked',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId
          .implementationSavedAnalysisBlockedGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationSavedAnalysisBlocked,
      ),
      'savedAnalysisBlocked',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId
          .phase33TRequirementGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .phase33TRequirement,
      ),
      'validateImplementationDesignNext',
    ),
  ];
}

DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroup _group(
  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroupId groupId,
  List<String> recordIds,
  String status,
) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignGroup(
    groupId: groupId,
    recordIds: recordIds,
    status: status,
  );
}

String _renderRecordsForLeakCheck(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord>
  records,
) {
  return records
      .map(
        (record) => [
          record.implementationDesignRecordId,
          record.sourceCaseId,
          record.prototypePacketRole,
          record.contractRole,
          record.implementationDesignRole.wire,
          ...record.blockedBoundaryIds,
          ...record.warningReasons,
          ...record.proofLimitReasons,
          ...record.findings,
        ].join(' '),
      )
      .join('\n');
}

int _countRole(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord>
  records,
  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole role,
) {
  return records
      .where((record) => record.implementationDesignRole == role)
      .length;
}

int _countActiveDeniedField(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord>
  records,
  String fieldId,
) {
  return records
      .where((record) => record.activeDeniedFieldIds.contains(fieldId))
      .length;
}

bool _isQuietRecord(
  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord record,
) {
  return record.sourceCaseId.contains('quiet-preparatory') ||
      record.blockedBoundaryIds.contains('quietPreparatoryCoreActivation') ||
      record.proofLimitReasons.contains(
        'quietPreparatoryExcludedFromActiveCoreOutput',
      );
}

List<String> _sorted(Iterable<String> values) {
  return values.toSet().toList(growable: false)..sort();
}

bool _isCriticalFinding(String finding) =>
    finding.startsWith('reportTextLeak:');

String _ids(Iterable<String> values) =>
    values.isEmpty ? '-' : values.join(', ');

const _phase33TRecommendation =
    'validateDebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesign';

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

const _futureClassNames = <String>[
  'DebugOnlyBridgeAnalyzerAdapterPrototypeInputPacket',
  'DebugOnlyBridgeAnalyzerAdapterPrototypeContextPacket',
  'DebugOnlyBridgeAnalyzerAdapterPrototypeRecord',
  'DebugOnlyBridgeAnalyzerAdapterPrototypePolicy',
  'DebugOnlyBridgeAnalyzerAdapterPrototypeMapper',
  'DebugOnlyBridgeAnalyzerAdapterPrototypeResult',
  'DebugOnlyBridgeAnalyzerAdapterPrototypeValidator',
  'DebugOnlyBridgeAnalyzerAdapterPrototypeDebugSnapshot',
];

const _allowedInternalFieldIds = <String>[
  'implementationDesignRecordId',
  'sourceValidationRowId',
  'sourceContractRecordId',
  'sourcePrototypeRecordId',
  'sourceCaseId',
  'sourcePhase',
  'prototypePacketRole',
  'contractRole',
  'implementationDesignRole',
  'supportAreaIds',
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

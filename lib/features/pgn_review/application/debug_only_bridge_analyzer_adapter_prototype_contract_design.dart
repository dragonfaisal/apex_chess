import 'dart:convert';

import 'debug_only_bridge_analyzer_adapter_boundary_design.dart';
import 'debug_only_bridge_analyzer_adapter_boundary_prototype_design.dart';
import 'debug_only_bridge_analyzer_adapter_boundary_prototype_design_validation.dart';
import 'golden_analysis_suite.dart';
import 'golden_android_proof_evidence.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportVersion =
    'debug-only-bridge-analyzer-adapter-prototype-contract-design-v1';

enum DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignStatus {
  prototypeContractDesignReadyWithWarnings(
    'prototypeContractDesignReadyWithWarnings',
  ),
  prototypeContractDesignReadyClean('prototypeContractDesignReadyClean'),
  blockedByUnsafePrototypeValidation('blockedByUnsafePrototypeValidation'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidPrototypeContractDesign('invalidPrototypeContractDesign');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignStatus(this.wire);

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroupId {
  prototypeContractInputGroup('prototypeContractInputGroup'),
  prototypeContractContextGroup('prototypeContractContextGroup'),
  prototypeContractWarningLimitedGroup('prototypeContractWarningLimitedGroup'),
  prototypeContractProofBoundaryGroup('prototypeContractProofBoundaryGroup'),
  prototypeContractExcludedGuardGroup('prototypeContractExcludedGuardGroup'),
  prototypeContractDeniedFieldGroup('prototypeContractDeniedFieldGroup'),
  prototypeContractAllowedInternalFieldGroup(
    'prototypeContractAllowedInternalFieldGroup',
  ),
  prototypeContractRuntimeBlockedGroup('prototypeContractRuntimeBlockedGroup'),
  prototypeContractAnalyzerWiringBlockedGroup(
    'prototypeContractAnalyzerWiringBlockedGroup',
  ),
  prototypeContractEngineBlockedGroup('prototypeContractEngineBlockedGroup'),
  prototypeContractSchedulerBlockedGroup(
    'prototypeContractSchedulerBlockedGroup',
  ),
  phase33RRequirementGroup('phase33RRequirementGroup');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroupId(this.wire);

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole {
  internalInputContract('internalInputContract'),
  contextOnlyContract('contextOnlyContract'),
  warningLimitedContract('warningLimitedContract'),
  proofBoundaryContract('proofBoundaryContract'),
  excludedGuardContract('excludedGuardContract'),
  deniedFieldContract('deniedFieldContract'),
  allowedInternalFieldContract('allowedInternalFieldContract'),
  runtimeBlockedContract('runtimeBlockedContract'),
  analyzerWiringBlockedContract('analyzerWiringBlockedContract'),
  engineBlockedContract('engineBlockedContract'),
  schedulerBlockedContract('schedulerBlockedContract'),
  futureRequirementContract('futureRequirementContract');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole(this.wire);

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroup {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroup({
    required this.groupId,
    required this.recordIds,
    required this.status,
  });

  final DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroupId groupId;
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

class DebugOnlyBridgeAnalyzerAdapterPrototypeContractRecord {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeContractRecord({
    required this.contractRecordId,
    required this.sourcePrototypeRecordId,
    required this.sourceCaseId,
    required this.sourcePhase,
    required this.prototypePacketRole,
    required this.contractRole,
    required this.allowedInternalFieldIds,
    required this.deniedFieldIds,
    required this.blockedBoundaryIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.androidProofCaseIds,
    required this.ownerProofRequired,
    required this.developerOnly,
    required this.contractOnly,
    required this.analyzerUnwired,
    required this.runtimeBlocked,
    required this.executablePrototypeBlocked,
    required this.activeDeniedFieldIds,
    required this.safetyFlags,
    required this.findings,
    required this.recommendation,
  });

  final String contractRecordId;
  final String sourcePrototypeRecordId;
  final String sourceCaseId;
  final String sourcePhase;
  final String prototypePacketRole;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole contractRole;
  final List<String> allowedInternalFieldIds;
  final List<String> deniedFieldIds;
  final List<String> blockedBoundaryIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofCaseIds;
  final bool ownerProofRequired;
  final bool developerOnly;
  final bool contractOnly;
  final bool analyzerUnwired;
  final bool runtimeBlocked;
  final bool executablePrototypeBlocked;
  final List<String> activeDeniedFieldIds;
  final DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags safetyFlags;
  final List<String> findings;
  final String recommendation;

  DebugOnlyBridgeAnalyzerAdapterPrototypeContractRecord copyWith({
    String? contractRecordId,
    String? sourcePrototypeRecordId,
    String? sourceCaseId,
    String? sourcePhase,
    String? prototypePacketRole,
    DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole? contractRole,
    List<String>? allowedInternalFieldIds,
    List<String>? deniedFieldIds,
    List<String>? blockedBoundaryIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? androidProofCaseIds,
    bool? ownerProofRequired,
    bool? developerOnly,
    bool? contractOnly,
    bool? analyzerUnwired,
    bool? runtimeBlocked,
    bool? executablePrototypeBlocked,
    List<String>? activeDeniedFieldIds,
    DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags? safetyFlags,
    List<String>? findings,
    String? recommendation,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeContractRecord(
      contractRecordId: contractRecordId ?? this.contractRecordId,
      sourcePrototypeRecordId:
          sourcePrototypeRecordId ?? this.sourcePrototypeRecordId,
      sourceCaseId: sourceCaseId ?? this.sourceCaseId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      prototypePacketRole: prototypePacketRole ?? this.prototypePacketRole,
      contractRole: contractRole ?? this.contractRole,
      allowedInternalFieldIds:
          allowedInternalFieldIds ?? this.allowedInternalFieldIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      developerOnly: developerOnly ?? this.developerOnly,
      contractOnly: contractOnly ?? this.contractOnly,
      analyzerUnwired: analyzerUnwired ?? this.analyzerUnwired,
      runtimeBlocked: runtimeBlocked ?? this.runtimeBlocked,
      executablePrototypeBlocked:
          executablePrototypeBlocked ?? this.executablePrototypeBlocked,
      activeDeniedFieldIds: activeDeniedFieldIds ?? this.activeDeniedFieldIds,
      safetyFlags: safetyFlags ?? this.safetyFlags,
      findings: findings ?? this.findings,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'contractRecordId': contractRecordId,
      'sourcePrototypeRecordId': sourcePrototypeRecordId,
      'sourceCaseId': sourceCaseId,
      'sourcePhase': sourcePhase,
      'prototypePacketRole': prototypePacketRole,
      'contractRole': contractRole.wire,
      'allowedInternalFieldIds': allowedInternalFieldIds,
      'deniedFieldIds': deniedFieldIds,
      'blockedBoundaryIds': blockedBoundaryIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'androidProofCaseIds': androidProofCaseIds,
      'ownerProofRequired': ownerProofRequired,
      'developerOnly': developerOnly,
      'contractOnly': contractOnly,
      'analyzerUnwired': analyzerUnwired,
      'runtimeBlocked': runtimeBlocked,
      'executablePrototypeBlocked': executablePrototypeBlocked,
      'activeDeniedFieldIds': activeDeniedFieldIds,
      'safetyFlags': safetyFlags.toJson(),
      'findings': findings,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignResult {
  DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignResult({
    required this.status,
    required this.sourcePrototypeValidationStatus,
    required this.sourcePrototypeValidationSafeForPhase33Q,
    required this.sourcePrototypeValidationRecommendation,
    required this.contractGroups,
    required this.contractRecords,
    required this.reportFindings,
    required this.safeForPhase33R,
    required this.phase33RRecommendation,
  }) : totalContractGroups = contractGroups.length,
       totalContractRecords = contractRecords.length,
       internalInputContractCount = _countRole(
         contractRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .internalInputContract,
       ),
       contextOnlyContractCount = _countRole(
         contractRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .contextOnlyContract,
       ),
       warningLimitedContractCount = _countRole(
         contractRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .warningLimitedContract,
       ),
       proofBoundaryContractCount = _countRole(
         contractRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .proofBoundaryContract,
       ),
       excludedGuardContractCount = _countRole(
         contractRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .excludedGuardContract,
       ),
       deniedFieldContractCount = _countRole(
         contractRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .deniedFieldContract,
       ),
       allowedInternalFieldContractCount = _countRole(
         contractRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .allowedInternalFieldContract,
       ),
       runtimeBlockedContractCount = _countRole(
         contractRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .runtimeBlockedContract,
       ),
       analyzerWiringBlockedContractCount = _countRole(
         contractRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .analyzerWiringBlockedContract,
       ),
       engineBlockedContractCount = _countRole(
         contractRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .engineBlockedContract,
       ),
       schedulerBlockedContractCount = _countRole(
         contractRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .schedulerBlockedContract,
       ),
       futureRequirementContractCount = _countRole(
         contractRecords,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .futureRequirementContract,
       ),
       blockerCount = contractRecords
           .where((record) => record.findings.isNotEmpty)
           .length,
       criticalCount = reportFindings.where(_isCriticalFinding).length,
       activeDeniedFieldCount = contractRecords.fold<int>(
         0,
         (total, record) => total + record.activeDeniedFieldIds.length,
       ),
       productOutputCount = contractRecords
           .where((record) => record.safetyFlags.isProductOutput)
           .length,
       labelLeakCount = contractRecords
           .where((record) => record.safetyFlags.emitsClassifierLabel)
           .length,
       finalLabelLeakCount = contractRecords
           .where((record) => record.safetyFlags.emitsFinalLabel)
           .length,
       scoreLeakCount = contractRecords
           .where(
             (record) =>
                 record.safetyFlags.hasNumericScore ||
                 record.safetyFlags.hasAggregateScore,
           )
           .length,
       metricLeakCount = contractRecords
           .where((record) => record.safetyFlags.emitsOfficialMetric)
           .length,
       cpLossLeakCount = contractRecords
           .where((record) => record.safetyFlags.exposesCpLoss)
           .length,
       winProbabilityLeakCount = contractRecords
           .where((record) => record.safetyFlags.exposesWinProbability)
           .length,
       moveRankingLeakCount = contractRecords
           .where((record) => record.safetyFlags.ranksMoves)
           .length,
       uiTargetCount = contractRecords
           .where((record) => record.safetyFlags.targetsUi)
           .length,
       backendTargetCount = contractRecords
           .where((record) => record.safetyFlags.targetsBackend)
           .length,
       persistenceWriteCount = contractRecords
           .where((record) => record.safetyFlags.writesPersistence)
           .length,
       engineCallCount = contractRecords
           .where((record) => record.safetyFlags.callsEngine)
           .length,
       schedulerExecutionCount = contractRecords
           .where((record) => record.safetyFlags.executesScheduler)
           .length,
       analyzerWiringCount = contractRecords
           .where((record) => record.safetyFlags.wiresAnalyzer)
           .length,
       runtimeImplementationCount = contractRecords
           .where((record) => record.safetyFlags.implementsRuntime)
           .length,
       executablePrototypeCount = contractRecords
           .where((record) => record.safetyFlags.implementsExecutablePrototype)
           .length,
       stockfishCommandLeakCount = contractRecords
           .where((record) => record.safetyFlags.exposesStockfishCommand)
           .length,
       rawUciLeakCount = contractRecords
           .where((record) => record.safetyFlags.exposesRawUci)
           .length,
       pvDumpLeakCount = contractRecords
           .where((record) => record.safetyFlags.exposesPvDump)
           .length,
       androidCollectorRequirementCount = contractRecords
           .where((record) => record.safetyFlags.requiresAndroidCollector)
           .length,
       unprovenAndroidProofCount = contractRecords
           .where(
             (record) => record.androidProofCaseIds.any(
               (caseId) => !_capturedAndroidProofIds.contains(caseId),
             ),
           )
           .length,
       phase32EProofClaimCount = contractRecords
           .where(
             (record) =>
                 _phase32ECaseIds.contains(record.sourceCaseId) &&
                 record.androidProofCaseIds.isNotEmpty,
           )
           .length,
       ownerProofQueueCount = contractRecords
           .where((record) => record.ownerProofRequired)
           .length {
    unsafeCount =
        contractRecords
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
        uiTargetCount +
        backendTargetCount +
        persistenceWriteCount +
        engineCallCount +
        schedulerExecutionCount +
        analyzerWiringCount +
        runtimeImplementationCount +
        executablePrototypeCount +
        stockfishCommandLeakCount +
        rawUciLeakCount +
        pvDumpLeakCount +
        androidCollectorRequirementCount +
        unprovenAndroidProofCount +
        phase32EProofClaimCount +
        ownerProofQueueCount;
  }

  final DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignStatus status;
  final String sourcePrototypeValidationStatus;
  final bool sourcePrototypeValidationSafeForPhase33Q;
  final String sourcePrototypeValidationRecommendation;
  final List<DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroup>
  contractGroups;
  final List<DebugOnlyBridgeAnalyzerAdapterPrototypeContractRecord>
  contractRecords;
  final List<String> reportFindings;
  final bool safeForPhase33R;
  final String phase33RRecommendation;
  final int totalContractGroups;
  final int totalContractRecords;
  final int internalInputContractCount;
  final int contextOnlyContractCount;
  final int warningLimitedContractCount;
  final int proofBoundaryContractCount;
  final int excludedGuardContractCount;
  final int deniedFieldContractCount;
  final int allowedInternalFieldContractCount;
  final int runtimeBlockedContractCount;
  final int analyzerWiringBlockedContractCount;
  final int engineBlockedContractCount;
  final int schedulerBlockedContractCount;
  final int futureRequirementContractCount;
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
  final int uiTargetCount;
  final int backendTargetCount;
  final int persistenceWriteCount;
  final int engineCallCount;
  final int schedulerExecutionCount;
  final int analyzerWiringCount;
  final int runtimeImplementationCount;
  final int executablePrototypeCount;
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
      !safeForPhase33R ||
      !sourcePrototypeValidationSafeForPhase33Q;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln(
        '# Debug-Only Bridge Analyzer Adapter Prototype Contract Design',
      )
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportVersion',
      )
      ..writeln('- contract design status: ${status.wire}')
      ..writeln(
        '- source prototype validation status: '
        '$sourcePrototypeValidationStatus',
      )
      ..writeln('- safe for Phase 33R: $safeForPhase33R')
      ..writeln('- Phase 33R recommendation: $phase33RRecommendation')
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
      ..writeln('## Contract Group Table')
      ..writeln('| Group | Record count | Status |')
      ..writeln('| --- | --- | --- |');
    for (final group in contractGroups) {
      buffer.writeln(
        '| ${group.groupId.wire} | ${group.recordIds.length} | '
        '${group.status} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Contract Record Table')
      ..writeln(
        '| Record | Source prototype | Case ID | Source phase | Prototype packet | '
        'Contract role | Analyzer unwired | Runtime blocked | '
        'Executable blocked | Android proof IDs | Active denied fields | '
        'Findings | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final record in contractRecords) {
      buffer.writeln(
        '| ${record.contractRecordId} | ${record.sourcePrototypeRecordId} | '
        '${record.sourceCaseId} | ${record.sourcePhase} | '
        '${record.prototypePacketRole} | ${record.contractRole.wire} | '
        '${record.analyzerUnwired} | ${record.runtimeBlocked} | '
        '${record.executablePrototypeBlocked} | '
        '${_ids(record.androidProofCaseIds)} | '
        '${_ids(record.activeDeniedFieldIds)} | ${_ids(record.findings)} | '
        '${record.recommendation} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Allowed Internal Field Contract')
      ..writeln('- allowed internal fields: ${_ids(_allowedInternalFieldIds)}')
      ..writeln()
      ..writeln('## Denied Field Contract')
      ..writeln('- denied fields: ${_ids(_deniedFieldIds)}')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln()
      ..writeln('## Blocked Boundary Contract')
      ..writeln('- analyzer wiring count: $analyzerWiringCount')
      ..writeln('- runtime implementation count: $runtimeImplementationCount')
      ..writeln('- executable prototype count: $executablePrototypeCount')
      ..writeln('- engine call count: $engineCallCount')
      ..writeln('- scheduler execution count: $schedulerExecutionCount')
      ..writeln('- persistence write count: $persistenceWriteCount')
      ..writeln('- UI target count: $uiTargetCount')
      ..writeln('- backend target count: $backendTargetCount')
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
      ..writeln('## Report Findings')
      ..writeln('- findings: ${_ids(reportFindings)}');
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportVersion,
      'contractDesignStatus': status.wire,
      'sourcePrototypeValidationStatus': sourcePrototypeValidationStatus,
      'sourcePrototypeValidationSafeForPhase33Q':
          sourcePrototypeValidationSafeForPhase33Q,
      'sourcePrototypeValidationRecommendation':
          sourcePrototypeValidationRecommendation,
      'safeForPhase33R': safeForPhase33R,
      'phase33RRecommendation': phase33RRecommendation,
      'counts': <String, Object?>{
        'totalContractGroups': totalContractGroups,
        'totalContractRecords': totalContractRecords,
        'internalInputContractCount': internalInputContractCount,
        'contextOnlyContractCount': contextOnlyContractCount,
        'warningLimitedContractCount': warningLimitedContractCount,
        'proofBoundaryContractCount': proofBoundaryContractCount,
        'excludedGuardContractCount': excludedGuardContractCount,
        'deniedFieldContractCount': deniedFieldContractCount,
        'allowedInternalFieldContractCount': allowedInternalFieldContractCount,
        'runtimeBlockedContractCount': runtimeBlockedContractCount,
        'analyzerWiringBlockedContractCount':
            analyzerWiringBlockedContractCount,
        'engineBlockedContractCount': engineBlockedContractCount,
        'schedulerBlockedContractCount': schedulerBlockedContractCount,
        'futureRequirementContractCount': futureRequirementContractCount,
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
        'uiTargetCount': uiTargetCount,
        'backendTargetCount': backendTargetCount,
        'persistenceWriteCount': persistenceWriteCount,
        'engineCallCount': engineCallCount,
        'schedulerExecutionCount': schedulerExecutionCount,
        'analyzerWiringCount': analyzerWiringCount,
        'runtimeImplementationCount': runtimeImplementationCount,
        'executablePrototypeCount': executablePrototypeCount,
        'stockfishCommandLeakCount': stockfishCommandLeakCount,
        'rawUciLeakCount': rawUciLeakCount,
        'pvDumpLeakCount': pvDumpLeakCount,
        'androidCollectorRequirementCount': androidCollectorRequirementCount,
        'unprovenAndroidProofCount': unprovenAndroidProofCount,
        'phase32EProofClaimCount': phase32EProofClaimCount,
        'ownerProofQueueCount': ownerProofQueueCount,
      },
      'capturedAndroidProofIds': _capturedAndroidProofIds.toList()..sort(),
      'contractGroups': contractGroups
          .map((group) => group.toJson())
          .toList(growable: false),
      'contractRecords': contractRecords
          .map((record) => record.toJson())
          .toList(growable: false),
      'reportFindings': reportFindings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign({
    this.validator =
        const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidator(),
  });

  final DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidator
  validator;

  DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignResult evaluate({
    DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationResult?
    prototypeValidationResult,
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final source =
        prototypeValidationResult ??
        const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidation()
            .evaluate(cases: cases);
    final records = <DebugOnlyBridgeAnalyzerAdapterPrototypeContractRecord>[
      for (final row in source.validationRows) _recordFromValidationRow(row),
      _syntheticRecord(
        recordId: 'phase33q-allowed-internal-field-contract',
        role: DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .allowedInternalFieldContract,
        sourceCaseId: 'phase33q',
        blockedBoundaryIds: const <String>[],
      ),
      _syntheticRecord(
        recordId: 'phase33q-runtime-blocked-contract',
        role: DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .runtimeBlockedContract,
        sourceCaseId: 'phase33q',
        blockedBoundaryIds: const <String>[
          'runtimeImplementation',
          'executablePrototypeBehavior',
        ],
      ),
      _syntheticRecord(
        recordId: 'phase33q-analyzer-wiring-blocked-contract',
        role: DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .analyzerWiringBlockedContract,
        sourceCaseId: 'phase33q',
        blockedBoundaryIds: const <String>['analyzerWiring'],
      ),
      _syntheticRecord(
        recordId: 'phase33q-engine-blocked-contract',
        role: DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .engineBlockedContract,
        sourceCaseId: 'phase33q',
        blockedBoundaryIds: const <String>[
          'directEngineAccess',
          'stockfishCommand',
          'rawUci',
          'pvDump',
        ],
      ),
      _syntheticRecord(
        recordId: 'phase33q-scheduler-blocked-contract',
        role: DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .schedulerBlockedContract,
        sourceCaseId: 'phase33q',
        blockedBoundaryIds: const <String>['schedulerExecution'],
      ),
      _syntheticRecord(
        recordId: 'phase33q-phase33r-requirement',
        role: DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .futureRequirementContract,
        sourceCaseId: 'phase33q',
        blockedBoundaryIds: const <String>[
          'runtimeImplementation',
          'analyzerWiring',
          'productOutput',
        ],
      ),
    ];
    final knownCaseIds = <String>{
      ...cases.map((caseData) => caseData.id),
      ...androidProofEvidence.targetCaseIds,
    };
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
        source.safeForPhase33Q &&
        source.phase33QRecommendation ==
            'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign' &&
        !source.hasUnsafePolicyViolation;
    final hasFutureRequirement = validatedRecords.any(
      (record) =>
          record.contractRole ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
              .futureRequirementContract,
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
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignStatus
              .blockedByUnsafePrototypeValidation
        : !hasFutureRequirement
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignStatus
              .invalidPrototypeContractDesign
        : hasRecordFindings || reportFindings.isNotEmpty
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignStatus
              .blockedByPolicyBoundary
        : validatedRecords.any(
            (record) =>
                record.warningReasons.isNotEmpty ||
                record.proofLimitReasons.isNotEmpty,
          )
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignStatus
              .prototypeContractDesignReadyWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignStatus
              .prototypeContractDesignReadyClean;

    return DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignResult(
      status: status,
      sourcePrototypeValidationStatus: source.status.wire,
      sourcePrototypeValidationSafeForPhase33Q: source.safeForPhase33Q,
      sourcePrototypeValidationRecommendation: source.phase33QRecommendation,
      contractGroups: groups,
      contractRecords: validatedRecords,
      reportFindings: reportFindings,
      safeForPhase33R: safe,
      phase33RRecommendation: safe
          ? _phase33RRecommendation
          : 'blockedByUnsafeAnalyzerAdapterPrototypeContractDesign',
    );
  }

  DebugOnlyBridgeAnalyzerAdapterPrototypeContractRecord
  _recordFromValidationRow(
    DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationRow row,
  ) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeContractRecord(
      contractRecordId: 'phase33q-${row.validationRowId}',
      sourcePrototypeRecordId: row.sourcePrototypeRecordId,
      sourceCaseId: row.sourceDiagnosticCaseId,
      sourcePhase: row.sourcePhase,
      prototypePacketRole: row.prototypePacketRole,
      contractRole: _contractRoleForPacket(row.prototypePacketRole),
      allowedInternalFieldIds: _allowedInternalFieldIds,
      deniedFieldIds: _deniedFieldIds,
      blockedBoundaryIds: _sorted(row.blockedBoundaryIds),
      warningReasons: _sorted(row.warningReasons),
      proofLimitReasons: _sorted(row.proofLimitReasons),
      androidProofCaseIds: _sorted(row.androidProofCaseIds),
      ownerProofRequired: row.ownerProofRequired,
      developerOnly: true,
      contractOnly: true,
      analyzerUnwired: true,
      runtimeBlocked: true,
      executablePrototypeBlocked: true,
      activeDeniedFieldIds: _sorted(row.activeDeniedFields),
      safetyFlags: const DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(),
      findings: const <String>[],
      recommendation: _phase33RRecommendation,
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidator {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidator();

  List<String> validateRecord(
    DebugOnlyBridgeAnalyzerAdapterPrototypeContractRecord record, {
    required Set<String> knownCaseIds,
  }) {
    final findings = <String>[];
    final knownSyntheticRecord =
        record.sourceCaseId == 'phase33q' ||
        record.sourceCaseId == 'phase33m' ||
        record.sourceCaseId.startsWith('phase33');
    if (!knownSyntheticRecord && !knownCaseIds.contains(record.sourceCaseId)) {
      findings.add('unknownContractSourceCase');
    }
    if (!_knownPrototypePacketRoles.contains(record.prototypePacketRole)) {
      findings.add('unknownPrototypePacketRole');
    }
    if (!DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole.values.contains(
      record.contractRole,
    )) {
      findings.add('unknownContractRole');
    }
    if (!record.developerOnly) findings.add('developerOnlyDisabled');
    if (!record.contractOnly) findings.add('contractOnlyDisabled');
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
        record.contractRole ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
                .internalInputContract) {
      findings.add('quietPreparatoryPromotedToInternalInput');
    }
    if (record.sourceCaseId == _pvMultiPvBoundaryCaseId &&
        record.contractRole !=
            DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
                .proofBoundaryContract &&
        record.contractRole !=
            DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
                .contextOnlyContract) {
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
    if (_deniedContractRoles.contains(record.contractRole) &&
        record.activeDeniedFieldIds.isNotEmpty) {
      findings.add('deniedContractActive');
    }
    if (record.contractRole ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
                .futureRequirementContract &&
        record.recommendation != _phase33RRecommendation) {
      findings.add('missingPhase33RRequirement');
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

DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole _contractRoleForPacket(
  String packetRole,
) {
  if (packetRole ==
      DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
          .analyzerAdapterPrototypeInputPacket
          .wire) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
        .internalInputContract;
  }
  if (packetRole ==
      DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
          .analyzerAdapterPrototypeContextPacket
          .wire) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
        .contextOnlyContract;
  }
  if (packetRole ==
      DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
          .analyzerAdapterPrototypeWarningLimitedPacket
          .wire) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
        .warningLimitedContract;
  }
  if (packetRole ==
      DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
          .analyzerAdapterPrototypeProofBoundaryPacket
          .wire) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
        .proofBoundaryContract;
  }
  if (packetRole ==
      DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
          .analyzerAdapterPrototypeExcludedGuardPacket
          .wire) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
        .excludedGuardContract;
  }
  if (packetRole ==
      DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
          .analyzerAdapterPrototypeFutureRequirementPacket
          .wire) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
        .futureRequirementContract;
  }
  return DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
      .deniedFieldContract;
}

DebugOnlyBridgeAnalyzerAdapterPrototypeContractRecord _syntheticRecord({
  required String recordId,
  required DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole role,
  required String sourceCaseId,
  required List<String> blockedBoundaryIds,
}) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeContractRecord(
    contractRecordId: recordId,
    sourcePrototypeRecordId: 'phase33q-contract-design',
    sourceCaseId: sourceCaseId,
    sourcePhase: 'Phase 33Q',
    prototypePacketRole: 'phase33qSyntheticContract',
    contractRole: role,
    allowedInternalFieldIds: _allowedInternalFieldIds,
    deniedFieldIds: _deniedFieldIds,
    blockedBoundaryIds: _sorted(blockedBoundaryIds),
    warningReasons: const <String>['contractDesignOnlyNoRuntimeWiring'],
    proofLimitReasons: const <String>[],
    androidProofCaseIds: const <String>[],
    ownerProofRequired: false,
    developerOnly: true,
    contractOnly: true,
    analyzerUnwired: true,
    runtimeBlocked: true,
    executablePrototypeBlocked: true,
    activeDeniedFieldIds: const <String>[],
    safetyFlags: const DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(),
    findings: const <String>[],
    recommendation: _phase33RRecommendation,
  );
}

List<DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroup> _groupsForRecords(
  List<DebugOnlyBridgeAnalyzerAdapterPrototypeContractRecord> records,
) {
  List<String> idsFor(
    DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole role,
  ) {
    return records
        .where((record) => record.contractRole == role)
        .map((record) => record.contractRecordId)
        .toList(growable: false);
  }

  return <DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroup>[
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroupId
          .prototypeContractInputGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .internalInputContract,
      ),
      'futureInternalOnly',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroupId
          .prototypeContractContextGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole.contextOnlyContract,
      ),
      'contextOnly',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroupId
          .prototypeContractWarningLimitedGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .warningLimitedContract,
      ),
      'warningLimited',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroupId
          .prototypeContractProofBoundaryGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .proofBoundaryContract,
      ),
      'proofBoundaryOnly',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroupId
          .prototypeContractExcludedGuardGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .excludedGuardContract,
      ),
      'excludedNegativeGuard',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroupId
          .prototypeContractDeniedFieldGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole.deniedFieldContract,
      ),
      'deniedInactive',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroupId
          .prototypeContractAllowedInternalFieldGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .allowedInternalFieldContract,
      ),
      'allowedInternalFieldsOnly',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroupId
          .prototypeContractRuntimeBlockedGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .runtimeBlockedContract,
      ),
      'runtimeBlocked',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroupId
          .prototypeContractAnalyzerWiringBlockedGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .analyzerWiringBlockedContract,
      ),
      'analyzerWiringBlocked',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroupId
          .prototypeContractEngineBlockedGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .engineBlockedContract,
      ),
      'engineBlocked',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroupId
          .prototypeContractSchedulerBlockedGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .schedulerBlockedContract,
      ),
      'schedulerBlocked',
    ),
    _group(
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroupId
          .phase33RRequirementGroup,
      idsFor(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .futureRequirementContract,
      ),
      'validateContractDesignNext',
    ),
  ];
}

DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroup _group(
  DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroupId groupId,
  List<String> recordIds,
  String status,
) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeContractGroup(
    groupId: groupId,
    recordIds: recordIds,
    status: status,
  );
}

String _renderRecordsForLeakCheck(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeContractRecord> records,
) {
  return records
      .map(
        (record) => [
          record.contractRecordId,
          record.sourceCaseId,
          record.prototypePacketRole,
          record.contractRole.wire,
          ...record.blockedBoundaryIds,
          ...record.warningReasons,
          ...record.proofLimitReasons,
          ...record.findings,
        ].join(' '),
      )
      .join('\n');
}

int _countRole(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeContractRecord> records,
  DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole role,
) {
  return records.where((record) => record.contractRole == role).length;
}

bool _isQuietRecord(
  DebugOnlyBridgeAnalyzerAdapterPrototypeContractRecord record,
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

const _phase33RRecommendation =
    'validateDebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign';

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

const _knownPrototypePacketRoles = <String>{
  'phase33qSyntheticContract',
  'analyzerAdapterPrototypeInputPacket',
  'analyzerAdapterPrototypeContextPacket',
  'analyzerAdapterPrototypeWarningLimitedPacket',
  'analyzerAdapterPrototypeProofBoundaryPacket',
  'analyzerAdapterPrototypeExcludedGuardPacket',
  'analyzerAdapterPrototypeDeniedFieldPacket',
  'analyzerAdapterPrototypeFutureRequirementPacket',
};

const _allowedInternalFieldIds = <String>[
  'contractRecordId',
  'sourcePrototypeRecordId',
  'sourceCaseId',
  'sourcePhase',
  'prototypePacketRole',
  'contractRole',
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
];

const _deniedContractRoles =
    <DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole>{
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole.deniedFieldContract,
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
          .runtimeBlockedContract,
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
          .analyzerWiringBlockedContract,
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole.engineBlockedContract,
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
          .schedulerBlockedContract,
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

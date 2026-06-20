import 'dart:convert';

import 'debug_only_bridge_analyzer_adapter_prototype_inspection_harness.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationReportVersion =
    'debug-only-bridge-analyzer-adapter-prototype-inspection-harness-validation-v1';

enum DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationStatus {
  prototypeInspectionHarnessValidatedWithWarnings(
    'prototypeInspectionHarnessValidatedWithWarnings',
  ),
  prototypeInspectionHarnessValidatedClean(
    'prototypeInspectionHarnessValidatedClean',
  ),
  blockedByUnsafeInspectionHarness('blockedByUnsafeInspectionHarness'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidInspectionHarnessValidation('invalidInspectionHarnessValidation');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationStatus(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId {
  consumesSafeInspectionHarness('consumesSafeInspectionHarness'),
  sourceSkeletonValidationRemainsSafe('sourceSkeletonValidationRemainsSafe'),
  sourceSkeletonResultRemainsSafe('sourceSkeletonResultRemainsSafe'),
  inspectionSnapshotDeterministic('inspectionSnapshotDeterministic'),
  inspectionRowsDeterministic('inspectionRowsDeterministic'),
  packetsRemainDeveloperOnlyInMemory('packetsRemainDeveloperOnlyInMemory'),
  policyBlocksDeniedCapabilities('policyBlocksDeniedCapabilities'),
  recordRoleCountsPreserved('recordRoleCountsPreserved'),
  androidProofBoundaryCapturedOnly('androidProofBoundaryCapturedOnly'),
  ownerProofQueueRemainsEmpty('ownerProofQueueRemainsEmpty'),
  deniedFieldsRemainInactive('deniedFieldsRemainInactive'),
  runtimeAnalyzerEngineSchedulerRemainBlocked(
    'runtimeAnalyzerEngineSchedulerRemainBlocked',
  ),
  noLabelsScoresRankingsMetrics('noLabelsScoresRankingsMetrics'),
  noCpLossOrWinProbability('noCpLossOrWinProbability'),
  noStockfishCommandRawUciPvDump('noStockfishCommandRawUciPvDump'),
  reportContainsNoRawUciOrPvDump('reportContainsNoRawUciOrPvDump'),
  phase33YRequirementPresent('phase33YRequirementPresent');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckStatus {
  passed('passed'),
  passedWithWarnings('passedWithWarnings'),
  blocked('blocked');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckStatus(
    this.wire,
  );

  final String wire;

  bool get isPassed => this == passed || this == passedWithWarnings;
  bool get isWarning => this == passedWithWarnings;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole {
  sourceHarnessInputValidation('sourceHarnessInputValidation'),
  sourceSkeletonValidationInputValidation(
    'sourceSkeletonValidationInputValidation',
  ),
  sourceSkeletonResultInputValidation('sourceSkeletonResultInputValidation'),
  inspectionSnapshotValidation('inspectionSnapshotValidation'),
  inputPacketSummaryValidation('inputPacketSummaryValidation'),
  contextPacketSummaryValidation('contextPacketSummaryValidation'),
  policySummaryValidation('policySummaryValidation'),
  recordRoleSummaryValidation('recordRoleSummaryValidation'),
  androidProofBoundaryValidation('androidProofBoundaryValidation'),
  ownerProofBoundaryValidation('ownerProofBoundaryValidation'),
  deniedFieldBoundaryValidation('deniedFieldBoundaryValidation'),
  reportSafetyValidation('reportSafetyValidation'),
  runtimeBlockedBoundaryValidation('runtimeBlockedBoundaryValidation'),
  analyzerWiringBlockedBoundaryValidation(
    'analyzerWiringBlockedBoundaryValidation',
  ),
  engineBlockedBoundaryValidation('engineBlockedBoundaryValidation'),
  schedulerBlockedBoundaryValidation('schedulerBlockedBoundaryValidation'),
  productAdapterBlockedBoundaryValidation(
    'productAdapterBlockedBoundaryValidation',
  ),
  savedAnalysisBlockedBoundaryValidation(
    'savedAnalysisBlockedBoundaryValidation',
  ),
  futureRequirementValidation('futureRequirementValidation');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowStatus {
  valid('valid'),
  validWithWarnings('validWithWarnings'),
  unsafeRow('unsafeRow'),
  invalid('invalid');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowStatus(
    this.wire,
  );

  final String wire;

  bool get isUnsafe => this == unsafeRow;
  bool get isInvalid => this == invalid;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheck {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheck({
    required this.checkId,
    required this.status,
    this.findings = const <String>[],
  });

  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
  checkId;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckStatus
  status;
  final List<String> findings;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'checkId': checkId.wire,
      'status': status.wire,
      'findings': findings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow({
    required this.validationRowId,
    required this.sourceInspectionRowId,
    required this.sourceRecordId,
    required this.sourceCaseId,
    required this.sourcePhase,
    required this.sourceRole,
    required this.validationRole,
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
    required this.ownerProofRequired,
    required this.findings,
    required this.recommendation,
  });

  final String validationRowId;
  final String sourceInspectionRowId;
  final String sourceRecordId;
  final String sourceCaseId;
  final String sourcePhase;
  final String sourceRole;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
  validationRole;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowStatus
  status;
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
  final bool ownerProofRequired;
  final List<String> findings;
  final String recommendation;

  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
  copyWith({
    String? validationRowId,
    String? sourceInspectionRowId,
    String? sourceRecordId,
    String? sourceCaseId,
    String? sourcePhase,
    String? sourceRole,
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole?
    validationRole,
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowStatus?
    status,
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
    bool? ownerProofRequired,
    List<String>? findings,
    String? recommendation,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow(
      validationRowId: validationRowId ?? this.validationRowId,
      sourceInspectionRowId:
          sourceInspectionRowId ?? this.sourceInspectionRowId,
      sourceRecordId: sourceRecordId ?? this.sourceRecordId,
      sourceCaseId: sourceCaseId ?? this.sourceCaseId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      sourceRole: sourceRole ?? this.sourceRole,
      validationRole: validationRole ?? this.validationRole,
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
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      findings: findings ?? this.findings,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'validationRowId': validationRowId,
      'sourceInspectionRowId': sourceInspectionRowId,
      'sourceRecordId': sourceRecordId,
      'sourceCaseId': sourceCaseId,
      'sourcePhase': sourcePhase,
      'sourceRole': sourceRole,
      'validationRole': validationRole.wire,
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
      'ownerProofRequired': ownerProofRequired,
      'findings': findings,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationResult {
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationResult({
    required this.status,
    required this.sourceHarnessStatus,
    required this.sourceHarnessSafeForPhase33X,
    required this.sourceHarnessRecommendation,
    required this.sourceValidationStatus,
    required this.sourceSkeletonStatus,
    required this.checks,
    required this.validationRows,
    required this.reportFindings,
    required this.safeForPhase33Y,
    required this.phase33YRecommendation,
  }) : totalChecks = checks.length,
       passedCheckCount = checks.where((check) => check.status.isPassed).length,
       warningCheckCount = checks
           .where((check) => check.status.isWarning)
           .length,
       blockerCount = checks
           .where(
             (check) =>
                 check.status ==
                 DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckStatus
                     .blocked,
           )
           .length,
       criticalCount = reportFindings.where(_isCriticalFinding).length,
       totalValidationRows = validationRows.length,
       sourceHarnessInputValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
             .sourceHarnessInputValidation,
       ),
       sourceSkeletonValidationInputValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
             .sourceSkeletonValidationInputValidation,
       ),
       sourceSkeletonResultInputValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
             .sourceSkeletonResultInputValidation,
       ),
       inspectionSnapshotValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
             .inspectionSnapshotValidation,
       ),
       inputPacketSummaryValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
             .inputPacketSummaryValidation,
       ),
       contextPacketSummaryValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
             .contextPacketSummaryValidation,
       ),
       policySummaryValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
             .policySummaryValidation,
       ),
       recordRoleSummaryValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
             .recordRoleSummaryValidation,
       ),
       androidProofBoundaryValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
             .androidProofBoundaryValidation,
       ),
       ownerProofBoundaryValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
             .ownerProofBoundaryValidation,
       ),
       deniedFieldBoundaryValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
             .deniedFieldBoundaryValidation,
       ),
       reportSafetyValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
             .reportSafetyValidation,
       ),
       runtimeBlockedBoundaryValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
             .runtimeBlockedBoundaryValidation,
       ),
       analyzerWiringBlockedBoundaryValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
             .analyzerWiringBlockedBoundaryValidation,
       ),
       engineBlockedBoundaryValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
             .engineBlockedBoundaryValidation,
       ),
       schedulerBlockedBoundaryValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
             .schedulerBlockedBoundaryValidation,
       ),
       productAdapterBlockedBoundaryValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
             .productAdapterBlockedBoundaryValidation,
       ),
       savedAnalysisBlockedBoundaryValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
             .savedAnalysisBlockedBoundaryValidation,
       ),
       futureRequirementValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
             .futureRequirementValidation,
       ),
       invalidRowCount = validationRows
           .where((row) => row.status.isInvalid)
           .length,
       unsafeRowCount = validationRows
           .where((row) => row.status.isUnsafe)
           .length,
       activeDeniedFieldCount = validationRows.fold<int>(
         0,
         (total, row) => total + row.activeDeniedFieldIds.length,
       ),
       productOutputCount = _countFinding(validationRows, 'productOutput'),
       labelLeakCount = _countFinding(validationRows, 'classifierLabelLeak'),
       finalLabelLeakCount = _countFinding(validationRows, 'finalLabelLeak'),
       scoreLeakCount =
           _countFinding(validationRows, 'numericScoreLeak') +
           _countFinding(validationRows, 'aggregateScoreLeak'),
       metricLeakCount = _countFinding(validationRows, 'officialMetricLeak'),
       cpLossLeakCount = _countFinding(validationRows, 'cpLossLeak'),
       winProbabilityLeakCount = _countFinding(
         validationRows,
         'winProbabilityLeak',
       ),
       moveRankingLeakCount = _countFinding(validationRows, 'moveRankingLeak'),
       thresholdLeakCount =
           _countFinding(validationRows, 'thresholdLeak') +
           _countActiveDeniedField(validationRows, 'thresholds'),
       uiTargetCount = _countFinding(validationRows, 'uiTarget'),
       backendTargetCount = _countFinding(validationRows, 'backendTarget'),
       persistenceWriteCount = _countFinding(
         validationRows,
         'persistenceWrite',
       ),
       engineCallCount = _countFinding(validationRows, 'engineCall'),
       schedulerExecutionCount = _countFinding(
         validationRows,
         'schedulerExecution',
       ),
       analyzerWiringCount =
           _countFinding(validationRows, 'analyzerWiring') +
           _countFinding(validationRows, 'analyzerWiringEnabled'),
       runtimeImplementationCount = _countFinding(
         validationRows,
         'runtimeImplementation',
       ),
       executablePrototypeCount = _countFinding(
         validationRows,
         'executablePrototypeImplementation',
       ),
       productAdapterBehaviorCount =
           _countFinding(validationRows, 'productAdapterBehavior') +
           _countActiveDeniedField(validationRows, 'productAdapterBehavior'),
       savedAnalysisIntegrationCount =
           _countFinding(validationRows, 'savedAnalysisIntegration') +
           _countActiveDeniedField(validationRows, 'savedAnalysisIntegration'),
       stockfishCommandLeakCount = _countFinding(
         validationRows,
         'stockfishCommandLeak',
       ),
       rawUciLeakCount = _countFinding(validationRows, 'rawUciLeak'),
       pvDumpLeakCount = _countFinding(validationRows, 'pvDumpLeak'),
       androidCollectorRequirementCount = _countFinding(
         validationRows,
         'androidCollectorRequired',
       ),
       unprovenAndroidProofCount = _countFinding(
         validationRows,
         'unprovenAndroidProofId',
       ),
       phase32EProofClaimCount = _countFinding(
         validationRows,
         'phase32ECapturedAndroidProofClaim',
       ),
       ownerProofQueueCount = validationRows
           .where((row) => row.ownerProofRequired)
           .length {
    unsafeCount =
        unsafeRowCount +
        invalidRowCount +
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

  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationStatus
  status;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionStatus
  sourceHarnessStatus;
  final bool sourceHarnessSafeForPhase33X;
  final String sourceHarnessRecommendation;
  final String sourceValidationStatus;
  final String sourceSkeletonStatus;
  final List<
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheck
  >
  checks;
  final List<
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
  >
  validationRows;
  final List<String> reportFindings;
  final bool safeForPhase33Y;
  final String phase33YRecommendation;
  final int totalChecks;
  final int passedCheckCount;
  final int warningCheckCount;
  final int blockerCount;
  final int criticalCount;
  late final int unsafeCount;
  final int totalValidationRows;
  final int sourceHarnessInputValidationCount;
  final int sourceSkeletonValidationInputValidationCount;
  final int sourceSkeletonResultInputValidationCount;
  final int inspectionSnapshotValidationCount;
  final int inputPacketSummaryValidationCount;
  final int contextPacketSummaryValidationCount;
  final int policySummaryValidationCount;
  final int recordRoleSummaryValidationCount;
  final int androidProofBoundaryValidationCount;
  final int ownerProofBoundaryValidationCount;
  final int deniedFieldBoundaryValidationCount;
  final int reportSafetyValidationCount;
  final int runtimeBlockedBoundaryValidationCount;
  final int analyzerWiringBlockedBoundaryValidationCount;
  final int engineBlockedBoundaryValidationCount;
  final int schedulerBlockedBoundaryValidationCount;
  final int productAdapterBlockedBoundaryValidationCount;
  final int savedAnalysisBlockedBoundaryValidationCount;
  final int futureRequirementValidationCount;
  final int invalidRowCount;
  final int unsafeRowCount;
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
      !safeForPhase33Y ||
      !sourceHarnessSafeForPhase33X;

  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
  rowForRole(
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
    role,
  ) {
    return validationRows.firstWhere((row) => row.validationRole == role);
  }

  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationResult
  copyWith({
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationStatus?
    status,
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionStatus?
    sourceHarnessStatus,
    bool? sourceHarnessSafeForPhase33X,
    String? sourceHarnessRecommendation,
    String? sourceValidationStatus,
    String? sourceSkeletonStatus,
    List<
      DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheck
    >?
    checks,
    List<DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow>?
    validationRows,
    List<String>? reportFindings,
    bool? safeForPhase33Y,
    String? phase33YRecommendation,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationResult(
      status: status ?? this.status,
      sourceHarnessStatus: sourceHarnessStatus ?? this.sourceHarnessStatus,
      sourceHarnessSafeForPhase33X:
          sourceHarnessSafeForPhase33X ?? this.sourceHarnessSafeForPhase33X,
      sourceHarnessRecommendation:
          sourceHarnessRecommendation ?? this.sourceHarnessRecommendation,
      sourceValidationStatus:
          sourceValidationStatus ?? this.sourceValidationStatus,
      sourceSkeletonStatus: sourceSkeletonStatus ?? this.sourceSkeletonStatus,
      checks: checks ?? this.checks,
      validationRows: validationRows ?? this.validationRows,
      reportFindings: reportFindings ?? this.reportFindings,
      safeForPhase33Y: safeForPhase33Y ?? this.safeForPhase33Y,
      phase33YRecommendation:
          phase33YRecommendation ?? this.phase33YRecommendation,
    );
  }

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln(
        '# Debug-Only Bridge Analyzer Adapter Prototype Inspection Harness Validation',
      )
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationReportVersion',
      )
      ..writeln('- validation status: ${status.wire}')
      ..writeln('- source harness status: ${sourceHarnessStatus.wire}')
      ..writeln('- source validation status: $sourceValidationStatus')
      ..writeln('- source skeleton status: $sourceSkeletonStatus')
      ..writeln('- safe for Phase 33Y: $safeForPhase33Y')
      ..writeln('- Phase 33Y recommendation: $phase33YRecommendation')
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
      ..writeln('## Validation Check Table')
      ..writeln('| Check | Status | Findings |')
      ..writeln('| --- | --- | --- |');
    for (final check in checks) {
      buffer.writeln(
        '| ${check.checkId.wire} | ${check.status.wire} | '
        '${_ids(check.findings)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Snapshot Validation Summary')
      ..writeln('- snapshot validations: $inspectionSnapshotValidationCount')
      ..writeln(
        '- source harness validations: $sourceHarnessInputValidationCount',
      )
      ..writeln(
        '- source skeleton validation inputs: '
        '$sourceSkeletonValidationInputValidationCount',
      )
      ..writeln(
        '- source skeleton result inputs: '
        '$sourceSkeletonResultInputValidationCount',
      )
      ..writeln()
      ..writeln('## Packet Validation Summary')
      ..writeln('- input packet summaries: $inputPacketSummaryValidationCount')
      ..writeln(
        '- context packet summaries: $contextPacketSummaryValidationCount',
      )
      ..writeln()
      ..writeln('## Policy Record Proof Validation Summary')
      ..writeln('- policy summaries: $policySummaryValidationCount')
      ..writeln('- record role summary rows: $recordRoleSummaryValidationCount')
      ..writeln(
        '- Android proof boundary rows: $androidProofBoundaryValidationCount',
      )
      ..writeln(
        '- owner proof boundary rows: $ownerProofBoundaryValidationCount',
      )
      ..writeln(
        '- denied field boundary rows: $deniedFieldBoundaryValidationCount',
      )
      ..writeln()
      ..writeln('## Validation Row Table')
      ..writeln(
        '| Row | Source | Source role | Validation role | Status | Developer only | In memory | Analyzer unwired | Inactive | Findings |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in validationRows) {
      buffer.writeln(
        '| ${row.validationRowId} | ${row.sourceRecordId} | '
        '${row.sourceRole} | ${row.validationRole.wire} | '
        '${row.status.wire} | ${row.developerOnly} | '
        '${row.inMemoryOnly} | ${row.analyzerUnwired} | '
        '${row.inactive} | ${_ids(row.findings)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Proof Boundary Validation')
      ..writeln(
        '- captured Android proof IDs: ${_ids(_capturedAndroidProofIds)}',
      )
      ..writeln('- unproven Android proof count: $unprovenAndroidProofCount')
      ..writeln('- Phase 32E proof claim count: $phase32EProofClaimCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Denied Field Validation')
      ..writeln('- required denied fields: ${_ids(_deniedFieldIds)}')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- label leak count: $labelLeakCount')
      ..writeln('- final label leak count: $finalLabelLeakCount')
      ..writeln('- score leak count: $scoreLeakCount')
      ..writeln('- metric leak count: $metricLeakCount')
      ..writeln('- threshold leak count: $thresholdLeakCount')
      ..writeln('- Stockfish command leak count: $stockfishCommandLeakCount')
      ..writeln('- raw UCI leak count: $rawUciLeakCount')
      ..writeln('- PV dump leak count: $pvDumpLeakCount')
      ..writeln()
      ..writeln(
        '## Runtime Analyzer Engine Scheduler Product Saved-Analysis Block Validation',
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
      ..writeln('## Report Safety Validation')
      ..writeln('- report safety rows: $reportSafetyValidationCount')
      ..writeln('- report findings: ${_ids(reportFindings)}')
      ..writeln()
      ..writeln('## Phase 33Y Recommendation')
      ..writeln('- safe for Phase 33Y: $safeForPhase33Y')
      ..writeln('- recommendation: $phase33YRecommendation');
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationReportVersion,
      'validationStatus': status.wire,
      'sourceHarnessStatus': sourceHarnessStatus.wire,
      'sourceHarnessSafeForPhase33X': sourceHarnessSafeForPhase33X,
      'sourceHarnessRecommendation': sourceHarnessRecommendation,
      'sourceValidationStatus': sourceValidationStatus,
      'sourceSkeletonStatus': sourceSkeletonStatus,
      'safeForPhase33Y': safeForPhase33Y,
      'phase33YRecommendation': phase33YRecommendation,
      'counts': <String, Object?>{
        'totalChecks': totalChecks,
        'passedCheckCount': passedCheckCount,
        'warningCheckCount': warningCheckCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'unsafeCount': unsafeCount,
        'totalValidationRows': totalValidationRows,
        'sourceHarnessInputValidationCount': sourceHarnessInputValidationCount,
        'sourceSkeletonValidationInputValidationCount':
            sourceSkeletonValidationInputValidationCount,
        'sourceSkeletonResultInputValidationCount':
            sourceSkeletonResultInputValidationCount,
        'inspectionSnapshotValidationCount': inspectionSnapshotValidationCount,
        'inputPacketSummaryValidationCount': inputPacketSummaryValidationCount,
        'contextPacketSummaryValidationCount':
            contextPacketSummaryValidationCount,
        'policySummaryValidationCount': policySummaryValidationCount,
        'recordRoleSummaryValidationCount': recordRoleSummaryValidationCount,
        'androidProofBoundaryValidationCount':
            androidProofBoundaryValidationCount,
        'ownerProofBoundaryValidationCount': ownerProofBoundaryValidationCount,
        'deniedFieldBoundaryValidationCount':
            deniedFieldBoundaryValidationCount,
        'reportSafetyValidationCount': reportSafetyValidationCount,
        'runtimeBlockedBoundaryValidationCount':
            runtimeBlockedBoundaryValidationCount,
        'analyzerWiringBlockedBoundaryValidationCount':
            analyzerWiringBlockedBoundaryValidationCount,
        'engineBlockedBoundaryValidationCount':
            engineBlockedBoundaryValidationCount,
        'schedulerBlockedBoundaryValidationCount':
            schedulerBlockedBoundaryValidationCount,
        'productAdapterBlockedBoundaryValidationCount':
            productAdapterBlockedBoundaryValidationCount,
        'savedAnalysisBlockedBoundaryValidationCount':
            savedAnalysisBlockedBoundaryValidationCount,
        'futureRequirementValidationCount': futureRequirementValidationCount,
        'invalidRowCount': invalidRowCount,
        'unsafeRowCount': unsafeRowCount,
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
      'checks': checks.map((check) => check.toJson()).toList(growable: false),
      'validationRows': validationRows
          .map((row) => row.toJson())
          .toList(growable: false),
      'reportFindings': reportFindings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidation {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidation({
    this.harness =
        const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness(),
    this.validator =
        const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationValidator(),
  });

  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness harness;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationValidator
  validator;

  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationResult
  evaluate({
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult? harnessResult,
  }) {
    final source = harnessResult ?? harness.inspectSafeDemo();
    final sourceSafe =
        source.safeForPhase33X &&
        source.phase33XRecommendation == _phase33XRequirement &&
        source.sourceValidationSafeForPhase33W &&
        source.sourceSkeletonSafeForPhase33V &&
        !source.hasUnsafePolicyViolation;
    final initialRows = <DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow>[
      _sourceHarnessInputRow(source),
      _sourceSkeletonValidationInputRow(source),
      _sourceSkeletonResultInputRow(source),
      _snapshotRow(source),
      _inputPacketSummaryRow(source),
      _contextPacketSummaryRow(source),
      _policySummaryRow(source),
      ...source.snapshot.recordRoleSummary.entries.map(
        (entry) => _recordRoleSummaryRow(source, entry),
      ),
      _androidProofBoundaryRow(source),
      _ownerProofBoundaryRow(source),
      _deniedFieldBoundaryRow(source),
      _reportSafetyRow(source),
      _blockedBoundaryRow(
        source,
        id: 'runtime',
        role:
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
                .runtimeBlockedBoundaryValidation,
        blockedBoundaryIds: const <String>[
          'runtimeImplementation',
          'executablePrototypeBehavior',
        ],
      ),
      _blockedBoundaryRow(
        source,
        id: 'analyzer-wiring',
        role:
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
                .analyzerWiringBlockedBoundaryValidation,
        blockedBoundaryIds: const <String>['analyzerWiring'],
      ),
      _blockedBoundaryRow(
        source,
        id: 'engine',
        role:
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
                .engineBlockedBoundaryValidation,
        blockedBoundaryIds: const <String>[
          'directEngineAccess',
          'engineCall',
          'stockfishCommand',
          'rawUci',
          'pvDump',
        ],
      ),
      _blockedBoundaryRow(
        source,
        id: 'scheduler',
        role:
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
                .schedulerBlockedBoundaryValidation,
        blockedBoundaryIds: const <String>['schedulerExecution'],
      ),
      _blockedBoundaryRow(
        source,
        id: 'product-adapter',
        role:
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
                .productAdapterBlockedBoundaryValidation,
        blockedBoundaryIds: const <String>[
          'productAdapterBehavior',
          'productOutput',
        ],
      ),
      _blockedBoundaryRow(
        source,
        id: 'saved-analysis',
        role:
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
                .savedAnalysisBlockedBoundaryValidation,
        blockedBoundaryIds: const <String>[
          'savedAnalysisIntegration',
          'persistenceWrite',
        ],
      ),
      _futureRequirementRow(),
    ];
    final rows = initialRows
        .map(
          (row) => _rowWithStatus(
            row.copyWith(findings: validator.validateRow(row)),
          ),
        )
        .toList(growable: false);
    final reportFindings = validator.validateReportText(
      [
        source.renderMarkdown(),
        source.renderJson(),
        _renderRowsForLeakCheck(rows),
      ].join('\n'),
    );
    final hasFutureRequirement = rows.any(
      (row) =>
          row.validationRole ==
              DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
                  .futureRequirementValidation &&
          row.recommendation == _phase33YRecommendation,
    );
    final checkFindings =
        <
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId,
          List<String>
        >{
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
              .consumesSafeInspectionHarness: sourceSafe
              ? const <String>[]
              : const <String>['unsafePhase33WInspectionHarnessInput'],
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
                  .sourceSkeletonValidationRemainsSafe:
              source.sourceValidationSafeForPhase33W
              ? const <String>[]
              : const <String>['unsafePhase33VValidationInput'],
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
                  .sourceSkeletonResultRemainsSafe:
              source.sourceSkeletonSafeForPhase33V
              ? const <String>[]
              : const <String>['unsafePhase33USkeletonInput'],
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
              .inspectionSnapshotDeterministic: _snapshotFindings(
            rows,
          ),
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
              .inspectionRowsDeterministic: _rowSummaryFindings(
            rows,
          ),
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
              .packetsRemainDeveloperOnlyInMemory: _packetFindings(
            rows,
          ),
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
              .policyBlocksDeniedCapabilities: _policyFindings(
            rows,
          ),
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
              .recordRoleCountsPreserved: _recordRoleFindings(
            rows,
          ),
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
                  .androidProofBoundaryCapturedOnly:
              _countFinding(rows, 'unprovenAndroidProofId') == 0
              ? const <String>[]
              : const <String>['unprovenAndroidProofId'],
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
                  .ownerProofQueueRemainsEmpty:
              rows.where((row) => row.ownerProofRequired).isEmpty
              ? const <String>[]
              : const <String>['ownerProofQueueNotEmpty'],
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
                  .deniedFieldsRemainInactive:
              _countFinding(rows, 'activeDeniedField') == 0
              ? const <String>[]
              : const <String>['activeDeniedField'],
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
                  .runtimeAnalyzerEngineSchedulerRemainBlocked:
              _blockedBoundaryFindings(rows),
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
              .noLabelsScoresRankingsMetrics: _labelScoreMetricFindings(
            rows,
          ),
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
              .noCpLossOrWinProbability: _cpWinFindings(
            rows,
          ),
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
              .noStockfishCommandRawUciPvDump: _rawBoundaryFindings(
            rows,
          ),
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
                  .reportContainsNoRawUciOrPvDump:
              reportFindings,
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
              .phase33YRequirementPresent: hasFutureRequirement
              ? const <String>[]
              : const <String>['missingPhase33YRequirement'],
        };
    final checks =
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
            .values
            .map(
              (checkId) =>
                  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheck(
                    checkId: checkId,
                    status: _checkStatus(
                      checkId,
                      checkFindings[checkId] ?? const <String>[],
                      source,
                    ),
                    findings: _sorted(
                      checkFindings[checkId] ?? const <String>[],
                    ),
                  ),
            )
            .toList(growable: false);
    final hasRowFindings = rows.any((row) => row.findings.isNotEmpty);
    final hasCheckBlockers = checks.any(
      (check) =>
          check.status ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckStatus
              .blocked,
    );
    final safe =
        sourceSafe &&
        hasFutureRequirement &&
        !hasRowFindings &&
        !hasCheckBlockers &&
        reportFindings.isEmpty;
    final status = !sourceSafe
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationStatus
              .blockedByUnsafeInspectionHarness
        : !hasFutureRequirement
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationStatus
              .invalidInspectionHarnessValidation
        : hasRowFindings || hasCheckBlockers || reportFindings.isNotEmpty
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationStatus
              .blockedByPolicyBoundary
        : source.status ==
                  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionStatus
                      .prototypeInspectionReadyWithWarnings ||
              rows.any(
                (row) =>
                    row.warningReasons.isNotEmpty ||
                    row.proofLimitReasons.isNotEmpty,
              )
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationStatus
              .prototypeInspectionHarnessValidatedWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationStatus
              .prototypeInspectionHarnessValidatedClean;
    return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationResult(
      status: status,
      sourceHarnessStatus: source.status,
      sourceHarnessSafeForPhase33X: source.safeForPhase33X,
      sourceHarnessRecommendation: source.phase33XRecommendation,
      sourceValidationStatus: source.sourceValidationStatus.wire,
      sourceSkeletonStatus: source.sourceSkeletonStatus.wire,
      checks: checks,
      validationRows: rows,
      reportFindings: reportFindings,
      safeForPhase33Y: safe,
      phase33YRecommendation: safe
          ? _phase33YRecommendation
          : 'blockedByUnsafeAnalyzerAdapterPrototypeInspectionHarnessValidation',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationValidator {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationValidator();

  List<String> validateResult(
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationResult
    result,
  ) {
    final findings = <String>[];
    if (!result.sourceHarnessSafeForPhase33X && result.safeForPhase33Y) {
      findings.add('unsafePhase33WInspectionHarnessMarkedValidated');
    }
    if (result.futureRequirementValidationCount == 0) {
      findings.add('missingPhase33YRequirement');
    }
    if (result.phase33YRecommendation != _phase33YRecommendation &&
        result.safeForPhase33Y) {
      findings.add('missingPhase33YRequirement');
    }
    findings.addAll(validateReportText(result.renderMarkdown()));
    return _sorted(findings);
  }

  List<String> validateRow(
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow row,
  ) {
    final findings = <String>[];
    if (!_knownSourceRoles.contains(row.sourceRole)) {
      findings.add('unknownInspectionRowRole');
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
    if (row.validationRole ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
                .contextPacketSummaryValidation &&
        !row.contextOnly) {
      findings.add('contextPacketNotContextOnly');
    }
    if (_isInactiveValidation(row.validationRole) && !row.inactive) {
      findings.add('inactiveBoundaryMadeActive');
    }
    if (_isQuietRow(row) &&
        row.validationRole !=
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
                .recordRoleSummaryValidation) {
      findings.add('quietPreparatoryPromoted');
    }
    if (row.sourceCaseId == _pvMultiPvBoundaryCaseId &&
        row.validationRole !=
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
                .androidProofBoundaryValidation &&
        row.validationRole !=
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
                .recordRoleSummaryValidation) {
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
    if (row.ownerProofRequired &&
        !row.proofLimitReasons.any(
          (reason) => reason.toLowerCase().contains('pv'),
        )) {
      findings.add('ownerProofWithoutPvMultiPvReason');
    }
    if (row.validationRole ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
                .futureRequirementValidation &&
        row.recommendation != _phase33YRecommendation) {
      findings.add('missingPhase33YRequirement');
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

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
_sourceHarnessInputRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult source,
) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow(
    validationRowId: 'phase33x-source-harness-input-validation',
    sourceInspectionRowId: 'phase33w-harness-result',
    sourceRecordId: source.snapshot.snapshotId,
    sourceCaseId: 'phase33w',
    sourcePhase: 'Phase 33W',
    sourceRole: 'inspectionHarnessResult',
    validationRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .sourceHarnessInputValidation,
    status:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowStatus
            .validWithWarnings,
    developerOnly: source.snapshot.developerOnly,
    inMemoryOnly: source.snapshot.inMemoryOnly,
    analyzerUnwired: source.snapshot.analyzerUnwired,
    contextOnly: false,
    warningLimited: false,
    proofBoundaryOnly: false,
    excludedGuard: false,
    inactive: false,
    allowedFieldIds: _sorted(source.snapshot.allowedFieldIds),
    deniedFieldIds: _sorted(source.snapshot.deniedFieldIds),
    androidProofCaseIds: _sorted(source.snapshot.androidProofCaseIds),
    warningReasons: _sorted(source.snapshot.warningReasons),
    proofLimitReasons: _sorted(source.snapshot.proofLimitReasons),
    blockedBoundaryIds: _sorted(source.snapshot.blockedBoundaryIds),
    activeDeniedFieldIds: source.hasUnsafePolicyViolation
        ? const <String>['unsafeInspectionHarnessResult']
        : const <String>[],
    ownerProofRequired: source.ownerProofQueueCount > 0,
    findings: const <String>[],
    recommendation: _phase33YRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
_sourceSkeletonValidationInputRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult source,
) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow(
    validationRowId: 'phase33x-source-skeleton-validation-input-validation',
    sourceInspectionRowId: 'phase33w-source-validation',
    sourceRecordId: 'phase33v-skeleton-validation-result',
    sourceCaseId: 'phase33v',
    sourcePhase: 'Phase 33V',
    sourceRole: 'sourceSkeletonValidation',
    validationRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .sourceSkeletonValidationInputValidation,
    status:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowStatus
            .validWithWarnings,
    developerOnly: true,
    inMemoryOnly: true,
    analyzerUnwired: true,
    contextOnly: false,
    warningLimited: false,
    proofBoundaryOnly: false,
    excludedGuard: false,
    inactive: false,
    allowedFieldIds: const <String>['sourceValidationStatus'],
    deniedFieldIds: _deniedFieldIds,
    androidProofCaseIds: const <String>[],
    warningReasons: source.sourceValidationStatus.wire.contains('Warnings')
        ? const <String>['sourceSkeletonValidationHasAcceptedWarnings']
        : const <String>[],
    proofLimitReasons: const <String>[],
    blockedBoundaryIds: const <String>[
      'analyzerWiring',
      'runtimeImplementation',
      'productOutput',
    ],
    activeDeniedFieldIds: source.sourceValidationSafeForPhase33W
        ? const <String>[]
        : const <String>['unsafeSourceSkeletonValidation'],
    ownerProofRequired: false,
    findings: const <String>[],
    recommendation: _phase33YRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
_sourceSkeletonResultInputRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult source,
) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow(
    validationRowId: 'phase33x-source-skeleton-result-input-validation',
    sourceInspectionRowId: 'phase33w-source-skeleton',
    sourceRecordId: 'phase33u-skeleton-result',
    sourceCaseId: 'phase33u',
    sourcePhase: 'Phase 33U',
    sourceRole: 'sourceSkeletonResult',
    validationRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .sourceSkeletonResultInputValidation,
    status:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowStatus
            .validWithWarnings,
    developerOnly: true,
    inMemoryOnly: true,
    analyzerUnwired: true,
    contextOnly: false,
    warningLimited: false,
    proofBoundaryOnly: false,
    excludedGuard: false,
    inactive: false,
    allowedFieldIds: const <String>['sourceSkeletonStatus'],
    deniedFieldIds: _deniedFieldIds,
    androidProofCaseIds: const <String>[],
    warningReasons: source.sourceSkeletonStatus.wire.contains('Warnings')
        ? const <String>['sourceSkeletonHasAcceptedWarnings']
        : const <String>[],
    proofLimitReasons: const <String>[],
    blockedBoundaryIds: const <String>[
      'analyzerWiring',
      'runtimeImplementation',
      'productOutput',
    ],
    activeDeniedFieldIds: source.sourceSkeletonSafeForPhase33V
        ? const <String>[]
        : const <String>['unsafeSourceSkeletonResult'],
    ownerProofRequired: false,
    findings: const <String>[],
    recommendation: _phase33YRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
_snapshotRow(DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult source) {
  final snapshot = source.snapshot;
  return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow(
    validationRowId: 'phase33x-inspection-snapshot-validation',
    sourceInspectionRowId: snapshot.snapshotId,
    sourceRecordId: snapshot.snapshotId,
    sourceCaseId: 'phase33w',
    sourcePhase: 'Phase 33W',
    sourceRole: 'inspectionSnapshot',
    validationRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .inspectionSnapshotValidation,
    status:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowStatus
            .validWithWarnings,
    developerOnly: snapshot.developerOnly,
    inMemoryOnly: snapshot.inMemoryOnly,
    analyzerUnwired: snapshot.analyzerUnwired,
    contextOnly: false,
    warningLimited: false,
    proofBoundaryOnly: false,
    excludedGuard: false,
    inactive: false,
    allowedFieldIds: _sorted(snapshot.allowedFieldIds),
    deniedFieldIds: _sorted(snapshot.deniedFieldIds),
    androidProofCaseIds: _sorted(snapshot.androidProofCaseIds),
    warningReasons: _sorted(snapshot.warningReasons),
    proofLimitReasons: _sorted(snapshot.proofLimitReasons),
    blockedBoundaryIds: _sorted(snapshot.blockedBoundaryIds),
    activeDeniedFieldIds: snapshot.hasUnsafeSnapshot
        ? const <String>['unsafeInspectionSnapshot']
        : const <String>[],
    ownerProofRequired: snapshot.ownerProofQueueCount > 0,
    findings: const <String>[],
    recommendation: _phase33YRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
_inputPacketSummaryRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult source,
) {
  return _summaryRow(
    validationRowId: 'phase33x-input-packet-summary-validation',
    sourceInspectionRowId: 'phase33w-input-packet-inspection',
    sourceRole: 'inputPacket',
    validationRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .inputPacketSummaryValidation,
    contextOnly: false,
    warningReasons: source.snapshot.warningReasons,
    proofLimitReasons: source.snapshot.proofLimitReasons,
    allowedFieldIds: source.snapshot.allowedFieldIds,
    androidProofCaseIds: source.snapshot.androidProofCaseIds,
    recommendation: 'keepInspectionInputPacketSummaryDeveloperOnly',
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
_contextPacketSummaryRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult source,
) {
  return _summaryRow(
    validationRowId: 'phase33x-context-packet-summary-validation',
    sourceInspectionRowId: 'phase33w-context-packet-inspection',
    sourceRole: 'contextPacket',
    validationRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .contextPacketSummaryValidation,
    contextOnly: true,
    warningReasons: source.snapshot.warningReasons,
    proofLimitReasons: source.snapshot.proofLimitReasons,
    allowedFieldIds: const <String>[],
    androidProofCaseIds: const <String>[],
    recommendation: 'keepInspectionContextPacketSummaryContextOnly',
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
_policySummaryRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult source,
) {
  final policySummary = source.snapshot.policySummary;
  return _summaryRow(
    validationRowId: 'phase33x-policy-summary-validation',
    sourceInspectionRowId: 'phase33w-policy-inspection',
    sourceRole: 'policy',
    validationRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .policySummaryValidation,
    contextOnly: false,
    warningReasons: const <String>[],
    proofLimitReasons: const <String>[],
    allowedFieldIds: _stringList(policySummary['allowedFieldIds']),
    androidProofCaseIds: _stringList(policySummary['capturedAndroidProofIds']),
    activeDeniedFieldIds: _policyAllowsBlockedCapability(policySummary)
        ? const <String>['unsafePolicyAllowance']
        : const <String>[],
    blockedBoundaryIds: const <String>[
      'analyzerWiring',
      'engineCall',
      'productOutput',
      'runtimeImplementation',
      'schedulerExecution',
    ],
    recommendation: 'keepInspectionPolicyFullyDenied',
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
_recordRoleSummaryRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult source,
  MapEntry<String, int> entry,
) {
  final inactive = _inactiveSourceRoles.contains(entry.key);
  return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow(
    validationRowId: 'phase33x-record-role-${entry.key}-summary-validation',
    sourceInspectionRowId: 'phase33w-record-role-${entry.key}-summary',
    sourceRecordId: 'phase33w-record-role-${entry.key}',
    sourceCaseId: 'phase33w',
    sourcePhase: 'Phase 33W',
    sourceRole: entry.key,
    validationRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .recordRoleSummaryValidation,
    status:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowStatus
            .validWithWarnings,
    developerOnly: true,
    inMemoryOnly: true,
    analyzerUnwired: true,
    contextOnly: entry.key == 'contextOnlyRecord',
    warningLimited: entry.key == 'warningLimitedRecord',
    proofBoundaryOnly: entry.key == 'proofBoundaryRecord',
    excludedGuard: entry.key == 'excludedGuardRecord',
    inactive: inactive,
    allowedFieldIds: inactive
        ? const <String>[]
        : source.snapshot.allowedFieldIds,
    deniedFieldIds: source.snapshot.deniedFieldIds,
    androidProofCaseIds: const <String>[],
    warningReasons: entry.value > 0
        ? const <String>['recordRoleCountPreservedFromInspectionHarness']
        : const <String>[],
    proofLimitReasons: entry.key == 'proofBoundaryRecord'
        ? const <String>['pvMultiPvBoundaryWatchListOnlyNoOwnerProof']
        : const <String>[],
    blockedBoundaryIds: inactive
        ? const <String>['inactiveBoundary']
        : const <String>['analyzerWiring', 'productOutput'],
    activeDeniedFieldIds: const <String>[],
    ownerProofRequired: false,
    findings: const <String>[],
    recommendation: 'preserveInspectionRecordRole:${entry.key}:${entry.value}',
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
_androidProofBoundaryRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult source,
) {
  return _summaryRow(
    validationRowId: 'phase33x-android-proof-boundary-validation',
    sourceInspectionRowId: 'phase33w-android-proof-boundary-inspection',
    sourceRole: 'androidProofBoundary',
    validationRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .androidProofBoundaryValidation,
    contextOnly: false,
    proofBoundaryOnly: true,
    allowedFieldIds: const <String>['androidProofBoundaryIds'],
    androidProofCaseIds: source.snapshot.androidProofCaseIds,
    blockedBoundaryIds: const <String>[
      'androidCollectorExecution',
      'phase32ECapturedAndroidProofClaim',
    ],
    recommendation: 'keepAndroidProofBoundaryCapturedOnly',
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
_ownerProofBoundaryRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult source,
) {
  return _summaryRow(
    validationRowId: 'phase33x-owner-proof-boundary-validation',
    sourceInspectionRowId: 'phase33w-owner-proof-boundary-inspection',
    sourceRole: 'ownerProofBoundary',
    validationRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .ownerProofBoundaryValidation,
    contextOnly: false,
    proofLimitReasons: source.snapshot.proofLimitReasons,
    blockedBoundaryIds: const <String>['ownerProofQueue'],
    ownerProofRequired: source.snapshot.ownerProofQueueCount > 0,
    activeDeniedFieldIds: source.snapshot.ownerProofQueueCount > 0
        ? const <String>['ownerProofQueue']
        : const <String>[],
    recommendation: 'keepOwnerProofQueueEmpty',
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
_deniedFieldBoundaryRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult source,
) {
  return _summaryRow(
    validationRowId: 'phase33x-denied-field-boundary-validation',
    sourceInspectionRowId: 'phase33w-denied-field-boundary-summary',
    sourceRole: 'deniedFieldBoundary',
    validationRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .deniedFieldBoundaryValidation,
    contextOnly: false,
    inactive: true,
    deniedFieldIds: source.snapshot.deniedFieldIds,
    blockedBoundaryIds: const <String>[
      'productOutput',
      'finalMoveLabel',
      'classifierLabels',
      'numericMoveScores',
      'officialMetrics',
      'cpLoss',
      'winProbability',
      'stockfishCommand',
      'rawUci',
      'pvDump',
    ],
    recommendation: 'keepDeniedFieldsInactive',
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
_reportSafetyRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult source,
) {
  final findings =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationValidator()
          .validateReportText(source.renderMarkdown());
  return _summaryRow(
    validationRowId: 'phase33x-report-safety-validation',
    sourceInspectionRowId: 'phase33w-report-safety-inspection',
    sourceRole: 'reportSafety',
    validationRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .reportSafetyValidation,
    contextOnly: false,
    blockedBoundaryIds: const <String>['rawUci', 'pvDump', 'stockfishCommand'],
    findings: findings,
    recommendation: 'keepInspectionHarnessReportsSafe',
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
_blockedBoundaryRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult source, {
  required String id,
  required DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
  role,
  required List<String> blockedBoundaryIds,
}) {
  return _summaryRow(
    validationRowId: 'phase33x-$id-blocked-boundary-validation',
    sourceInspectionRowId: 'phase33w-$id-blocked-boundary-summary',
    sourceRole: _blockedBoundarySourceRole(id),
    validationRole: role,
    contextOnly: false,
    inactive: true,
    blockedBoundaryIds: blockedBoundaryIds,
    deniedFieldIds: source.snapshot.deniedFieldIds,
    recommendation: 'keep${_pascal(id)}Blocked',
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
_futureRequirementRow() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow(
    validationRowId:
        'phase33x-phase33y-practical-diagnostic-command-requirement',
    sourceInspectionRowId: 'phase33x-phase33y-requirement',
    sourceRecordId: 'phase33x-phase33y-requirement',
    sourceCaseId: 'phase33x',
    sourcePhase: 'Phase 33X',
    sourceRole: 'futureRequirement',
    validationRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .futureRequirementValidation,
    status:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowStatus
            .valid,
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
    ownerProofRequired: false,
    findings: <String>[],
    recommendation: _phase33YRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
_summaryRow({
  required String validationRowId,
  required String sourceInspectionRowId,
  required String sourceRole,
  required DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
  validationRole,
  bool contextOnly = false,
  bool warningLimited = false,
  bool proofBoundaryOnly = false,
  bool excludedGuard = false,
  bool inactive = false,
  List<String> allowedFieldIds = const <String>[],
  List<String>? deniedFieldIds,
  List<String> androidProofCaseIds = const <String>[],
  List<String> warningReasons = const <String>[],
  List<String> proofLimitReasons = const <String>[],
  List<String> blockedBoundaryIds = const <String>[],
  List<String> activeDeniedFieldIds = const <String>[],
  bool ownerProofRequired = false,
  List<String> findings = const <String>[],
  required String recommendation,
}) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow(
    validationRowId: validationRowId,
    sourceInspectionRowId: sourceInspectionRowId,
    sourceRecordId: sourceInspectionRowId,
    sourceCaseId: 'phase33w',
    sourcePhase: 'Phase 33W',
    sourceRole: sourceRole,
    validationRole: validationRole,
    status:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowStatus
            .validWithWarnings,
    developerOnly: true,
    inMemoryOnly: true,
    analyzerUnwired: true,
    contextOnly: contextOnly,
    warningLimited: warningLimited,
    proofBoundaryOnly: proofBoundaryOnly,
    excludedGuard: excludedGuard,
    inactive: inactive,
    allowedFieldIds: _sorted(allowedFieldIds),
    deniedFieldIds: _sorted(deniedFieldIds ?? _deniedFieldIds),
    androidProofCaseIds: _sorted(androidProofCaseIds),
    warningReasons: _sorted(warningReasons),
    proofLimitReasons: _sorted(proofLimitReasons),
    blockedBoundaryIds: _sorted(blockedBoundaryIds),
    activeDeniedFieldIds: _sorted(activeDeniedFieldIds),
    ownerProofRequired: ownerProofRequired,
    findings: _sorted(findings),
    recommendation: recommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
_rowWithStatus(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow row,
) {
  if (row.findings.isNotEmpty) {
    return row.copyWith(
      status:
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowStatus
              .unsafeRow,
    );
  }
  if (row.warningReasons.isNotEmpty || row.proofLimitReasons.isNotEmpty) {
    return row.copyWith(
      status:
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowStatus
              .validWithWarnings,
    );
  }
  return row.copyWith(
    status:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowStatus
            .valid,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckStatus
_checkStatus(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
  checkId,
  List<String> findings,
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult source,
) {
  if (findings.isNotEmpty) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckStatus
        .blocked;
  }
  if (checkId ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckId
              .consumesSafeInspectionHarness &&
      source.status ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionStatus
              .prototypeInspectionReadyWithWarnings) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckStatus
        .passedWithWarnings;
  }
  return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationCheckStatus
      .passed;
}

List<String> _snapshotFindings(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
  >
  rows,
) {
  return _findingsForRoles(rows, const <String>{
    'inspectionSnapshotValidation',
  });
}

List<String> _rowSummaryFindings(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
  >
  rows,
) {
  return _sorted(
    rows
        .where((row) => row.validationRowId.trim().isEmpty)
        .map((_) => 'emptyValidationRowId'),
  );
}

List<String> _packetFindings(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
  >
  rows,
) {
  return _findingsForRoles(rows, const <String>{
    'inputPacketSummaryValidation',
    'contextPacketSummaryValidation',
  });
}

List<String> _policyFindings(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
  >
  rows,
) {
  return _findingsForRoles(rows, const <String>{'policySummaryValidation'});
}

List<String> _recordRoleFindings(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
  >
  rows,
) {
  return _findingsForRoles(rows, const <String>{'recordRoleSummaryValidation'});
}

List<String> _blockedBoundaryFindings(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
  >
  rows,
) {
  return _findingsByIds(rows, const <String>{
    'analyzerWiring',
    'analyzerWiringEnabled',
    'runtimeImplementation',
    'executablePrototypeImplementation',
    'engineCall',
    'schedulerExecution',
    'persistenceWrite',
    'uiTarget',
    'backendTarget',
    'productAdapterBehavior',
    'savedAnalysisIntegration',
  });
}

List<String> _labelScoreMetricFindings(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
  >
  rows,
) {
  return _findingsByIds(rows, const <String>{
    'productOutput',
    'productLabelLeak',
    'finalLabelLeak',
    'classifierLabelLeak',
    'numericScoreLeak',
    'aggregateScoreLeak',
    'moveRankingLeak',
    'officialMetricLeak',
    'thresholdLeak',
  });
}

List<String> _cpWinFindings(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
  >
  rows,
) {
  return _findingsByIds(rows, const <String>{
    'cpLossLeak',
    'winProbabilityLeak',
  });
}

List<String> _rawBoundaryFindings(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
  >
  rows,
) {
  return _findingsByIds(rows, const <String>{
    'stockfishCommandLeak',
    'rawUciLeak',
    'pvDumpLeak',
  });
}

List<String> _findingsForRoles(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
  >
  rows,
  Set<String> roleWires,
) {
  return _sorted(
    rows
        .where((row) => roleWires.contains(row.validationRole.wire))
        .expand((row) => row.findings),
  );
}

List<String> _findingsByIds(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
  >
  rows,
  Set<String> findingIds,
) {
  return _sorted(
    rows
        .expand((row) => row.findings)
        .where((finding) => findingIds.contains(finding)),
  );
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
      case 'unsafeInspectionSnapshot':
      case 'unsafeInspectionHarnessResult':
      case 'unsafeSourceSkeletonValidation':
      case 'unsafeSourceSkeletonResult':
        findings.add('unsafeSourceInput');
    }
  }
  return findings;
}

bool _isInactiveValidation(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
  role,
) {
  return role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
              .deniedFieldBoundaryValidation ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
              .runtimeBlockedBoundaryValidation ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
              .analyzerWiringBlockedBoundaryValidation ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
              .engineBlockedBoundaryValidation ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
              .schedulerBlockedBoundaryValidation ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
              .productAdapterBlockedBoundaryValidation ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
              .savedAnalysisBlockedBoundaryValidation;
}

bool _isQuietRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow row,
) {
  return row.sourceCaseId.contains('quiet-preparatory') ||
      row.blockedBoundaryIds.contains('quietPreparatoryCoreActivation');
}

bool _policyAllowsBlockedCapability(Map<String, Object?> policySummary) {
  return _policyBlockedAllowanceKeys.any((key) => policySummary[key] == true);
}

List<String> _stringList(Object? value) {
  if (value is Iterable) {
    return _sorted(value.whereType<String>());
  }
  return const <String>[];
}

String _renderRowsForLeakCheck(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
  >
  rows,
) {
  return rows
      .map(
        (row) => [
          row.validationRowId,
          row.sourceCaseId,
          row.sourceRole,
          row.validationRole.wire,
          ...row.blockedBoundaryIds,
          ...row.warningReasons,
          ...row.proofLimitReasons,
          ...row.findings,
        ].join(' '),
      )
      .join('\n');
}

int _countRole(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
  >
  rows,
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
  role,
) {
  return rows.where((row) => row.validationRole == role).length;
}

int _countFinding(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
  >
  rows,
  String finding,
) {
  return rows.where((row) => row.findings.contains(finding)).length;
}

int _countActiveDeniedField(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
  >
  rows,
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

String _pascal(String value) {
  return value
      .split('-')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join();
}

String _blockedBoundarySourceRole(String id) {
  return switch (id) {
    'runtime' => 'runtimeBlockedBoundary',
    'analyzer-wiring' => 'analyzerWiringBlockedBoundary',
    'engine' => 'engineBlockedBoundary',
    'scheduler' => 'schedulerBlockedBoundary',
    'product-adapter' => 'productAdapterBlockedBoundary',
    'saved-analysis' => 'savedAnalysisBlockedBoundary',
    _ => '${id.replaceAll('-', '')}BlockedBoundary',
  };
}

const _phase33XRequirement =
    'validateDebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness';
const _phase33YRecommendation =
    'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommand';

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
  'inspectionHarnessResult',
  'sourceSkeletonValidation',
  'sourceSkeletonResult',
  'inspectionSnapshot',
  'inputPacket',
  'contextPacket',
  'policy',
  'androidProofBoundary',
  'ownerProofBoundary',
  'deniedFieldBoundary',
  'reportSafety',
  'futureRequirement',
  'runtimeBlockedBoundary',
  'analyzerWiringBlockedBoundary',
  'engineBlockedBoundary',
  'schedulerBlockedBoundary',
  'productAdapterBlockedBoundary',
  'savedAnalysisBlockedBoundary',
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

const _inactiveSourceRoles = <String>{
  'deniedFieldBoundaryRecord',
  'runtimeBlockedRecord',
  'analyzerWiringBlockedRecord',
  'engineBlockedRecord',
  'schedulerBlockedRecord',
  'productAdapterBlockedRecord',
  'savedAnalysisBlockedRecord',
};

const _policyBlockedAllowanceKeys = <String>[
  'allowsProductOutput',
  'allowsAnalyzerWiring',
  'allowsRuntimeImplementation',
  'allowsExecutablePrototype',
  'allowsEngineCalls',
  'allowsSchedulerExecution',
  'allowsPersistenceWrites',
  'allowsUiTargets',
  'allowsBackendTargets',
  'allowsProductAdapter',
  'allowsSavedAnalysisIntegration',
  'allowsClassifierLabels',
  'allowsFinalLabels',
  'allowsNumericScores',
  'allowsAggregateScores',
  'allowsOfficialMetrics',
  'allowsCpLoss',
  'allowsWinProbability',
  'allowsMoveRanking',
  'allowsStockfishCommand',
  'allowsRawUci',
  'allowsPvDump',
  'allowsAndroidCollector',
  'hasUnsafeAllowance',
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

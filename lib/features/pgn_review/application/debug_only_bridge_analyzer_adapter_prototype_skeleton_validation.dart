import 'dart:convert';

import 'debug_only_bridge_analyzer_adapter_prototype_skeleton.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationReportVersion =
    'debug-only-bridge-analyzer-adapter-prototype-skeleton-validation-v1';

enum DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationStatus {
  prototypeSkeletonValidatedWithWarnings(
    'prototypeSkeletonValidatedWithWarnings',
  ),
  prototypeSkeletonValidatedClean('prototypeSkeletonValidatedClean'),
  blockedByUnsafePrototypeSkeleton('blockedByUnsafePrototypeSkeleton'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidPrototypeSkeletonValidation('invalidPrototypeSkeletonValidation');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationStatus(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId {
  consumesSafePrototypeSkeleton('consumesSafePrototypeSkeleton'),
  packetsAreDeveloperOnlyInMemory('packetsAreDeveloperOnlyInMemory'),
  recordsPreserveSkeletonRoles('recordsPreserveSkeletonRoles'),
  mapperConsumesSafeInputs('mapperConsumesSafeInputs'),
  policyDisablesBlockedCapabilities('policyDisablesBlockedCapabilities'),
  debugSnapshotSafeMetadataOnly('debugSnapshotSafeMetadataOnly'),
  validatorRejectsDeniedSeams('validatorRejectsDeniedSeams'),
  phase32EProofHonestyPreserved('phase32EProofHonestyPreserved'),
  androidProofIdsRemainCapturedOnly('androidProofIdsRemainCapturedOnly'),
  ownerProofQueueRemainsEmpty('ownerProofQueueRemainsEmpty'),
  deniedFieldsRemainInactive('deniedFieldsRemainInactive'),
  runtimeAnalyzerEngineSchedulerRemainBlocked(
    'runtimeAnalyzerEngineSchedulerRemainBlocked',
  ),
  noLabelsScoresRankingsMetrics('noLabelsScoresRankingsMetrics'),
  noCpLossOrWinProbability('noCpLossOrWinProbability'),
  noStockfishCommandRawUciPvDump('noStockfishCommandRawUciPvDump'),
  reportContainsNoRawUciOrPvDump('reportContainsNoRawUciOrPvDump'),
  phase33WRequirementPresent('phase33WRequirementPresent');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckStatus {
  passed('passed'),
  passedWithWarnings('passedWithWarnings'),
  blocked('blocked');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckStatus(
    this.wire,
  );

  final String wire;

  bool get isPassed => this == passed || this == passedWithWarnings;
  bool get isWarning => this == passedWithWarnings;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole {
  inputPacketValidation('inputPacketValidation'),
  contextPacketValidation('contextPacketValidation'),
  internalInputRecordValidation('internalInputRecordValidation'),
  contextOnlyRecordValidation('contextOnlyRecordValidation'),
  warningLimitedRecordValidation('warningLimitedRecordValidation'),
  proofBoundaryRecordValidation('proofBoundaryRecordValidation'),
  excludedGuardRecordValidation('excludedGuardRecordValidation'),
  allowedFieldBoundaryRecordValidation('allowedFieldBoundaryRecordValidation'),
  deniedFieldBoundaryRecordValidation('deniedFieldBoundaryRecordValidation'),
  mapperMetadataRecordValidation('mapperMetadataRecordValidation'),
  validatorMetadataRecordValidation('validatorMetadataRecordValidation'),
  debugSnapshotMetadataRecordValidation(
    'debugSnapshotMetadataRecordValidation',
  ),
  runtimeBlockedRecordValidation('runtimeBlockedRecordValidation'),
  analyzerWiringBlockedRecordValidation(
    'analyzerWiringBlockedRecordValidation',
  ),
  engineBlockedRecordValidation('engineBlockedRecordValidation'),
  schedulerBlockedRecordValidation('schedulerBlockedRecordValidation'),
  productAdapterBlockedRecordValidation(
    'productAdapterBlockedRecordValidation',
  ),
  savedAnalysisBlockedRecordValidation('savedAnalysisBlockedRecordValidation'),
  futureRequirementRecordValidation('futureRequirementRecordValidation'),
  policyValidation('policyValidation'),
  reportSafetyValidation('reportSafetyValidation');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowStatus {
  valid('valid'),
  validWithWarnings('validWithWarnings'),
  unsafeRow('unsafeRow'),
  invalid('invalid');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowStatus(
    this.wire,
  );

  final String wire;

  bool get isUnsafe => this == unsafeRow;
  bool get isInvalid => this == invalid;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheck {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheck({
    required this.checkId,
    required this.status,
    this.findings = const <String>[],
  });

  final DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId
  checkId;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckStatus
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

class DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow({
    required this.validationRowId,
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
    required this.blockedBoundaryIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.androidProofCaseIds,
    required this.ownerProofRequired,
    required this.activeDeniedFieldIds,
    required this.findings,
    required this.recommendation,
  });

  final String validationRowId;
  final String sourceRecordId;
  final String sourceCaseId;
  final String sourcePhase;
  final String sourceRole;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
  validationRole;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowStatus
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
  final List<String> blockedBoundaryIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofCaseIds;
  final bool ownerProofRequired;
  final List<String> activeDeniedFieldIds;
  final List<String> findings;
  final String recommendation;

  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow copyWith({
    String? validationRowId,
    String? sourceRecordId,
    String? sourceCaseId,
    String? sourcePhase,
    String? sourceRole,
    DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole?
    validationRole,
    DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowStatus? status,
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
    List<String>? findings,
    String? recommendation,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow(
      validationRowId: validationRowId ?? this.validationRowId,
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
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      activeDeniedFieldIds: activeDeniedFieldIds ?? this.activeDeniedFieldIds,
      findings: findings ?? this.findings,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'validationRowId': validationRowId,
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
      'blockedBoundaryIds': blockedBoundaryIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'androidProofCaseIds': androidProofCaseIds,
      'ownerProofRequired': ownerProofRequired,
      'activeDeniedFieldIds': activeDeniedFieldIds,
      'findings': findings,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationResult {
  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationResult({
    required this.status,
    required this.sourceSkeletonStatus,
    required this.sourceSkeletonSafeForPhase33V,
    required this.sourceSkeletonRecommendation,
    required this.checks,
    required this.validationRows,
    required this.reportFindings,
    required this.safeForPhase33W,
    required this.phase33WRecommendation,
  }) : totalChecks = checks.length,
       passedCheckCount = checks.where((check) => check.status.isPassed).length,
       warningCheckCount = checks
           .where((check) => check.status.isWarning)
           .length,
       blockerCount = checks
           .where(
             (check) =>
                 check.status ==
                 DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckStatus
                     .blocked,
           )
           .length,
       criticalCount = reportFindings.where(_isCriticalFinding).length,
       totalValidationRows = validationRows.length,
       inputPacketValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .inputPacketValidation,
       ),
       contextPacketValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .contextPacketValidation,
       ),
       internalInputRecordValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .internalInputRecordValidation,
       ),
       contextOnlyRecordValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .contextOnlyRecordValidation,
       ),
       warningLimitedRecordValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .warningLimitedRecordValidation,
       ),
       proofBoundaryRecordValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .proofBoundaryRecordValidation,
       ),
       excludedGuardRecordValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .excludedGuardRecordValidation,
       ),
       allowedFieldBoundaryRecordValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .allowedFieldBoundaryRecordValidation,
       ),
       deniedFieldBoundaryRecordValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .deniedFieldBoundaryRecordValidation,
       ),
       mapperMetadataRecordValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .mapperMetadataRecordValidation,
       ),
       validatorMetadataRecordValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .validatorMetadataRecordValidation,
       ),
       debugSnapshotMetadataRecordValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .debugSnapshotMetadataRecordValidation,
       ),
       runtimeBlockedRecordValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .runtimeBlockedRecordValidation,
       ),
       analyzerWiringBlockedRecordValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .analyzerWiringBlockedRecordValidation,
       ),
       engineBlockedRecordValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .engineBlockedRecordValidation,
       ),
       schedulerBlockedRecordValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .schedulerBlockedRecordValidation,
       ),
       productAdapterBlockedRecordValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .productAdapterBlockedRecordValidation,
       ),
       savedAnalysisBlockedRecordValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .savedAnalysisBlockedRecordValidation,
       ),
       futureRequirementRecordValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .futureRequirementRecordValidation,
       ),
       policyValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .policyValidation,
       ),
       reportSafetyValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
             .reportSafetyValidation,
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

  final DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationStatus status;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonStatus
  sourceSkeletonStatus;
  final bool sourceSkeletonSafeForPhase33V;
  final String sourceSkeletonRecommendation;
  final List<DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheck>
  checks;
  final List<DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow>
  validationRows;
  final List<String> reportFindings;
  final bool safeForPhase33W;
  final String phase33WRecommendation;
  final int totalChecks;
  final int passedCheckCount;
  final int warningCheckCount;
  final int blockerCount;
  final int criticalCount;
  late final int unsafeCount;
  final int totalValidationRows;
  final int inputPacketValidationCount;
  final int contextPacketValidationCount;
  final int internalInputRecordValidationCount;
  final int contextOnlyRecordValidationCount;
  final int warningLimitedRecordValidationCount;
  final int proofBoundaryRecordValidationCount;
  final int excludedGuardRecordValidationCount;
  final int allowedFieldBoundaryRecordValidationCount;
  final int deniedFieldBoundaryRecordValidationCount;
  final int mapperMetadataRecordValidationCount;
  final int validatorMetadataRecordValidationCount;
  final int debugSnapshotMetadataRecordValidationCount;
  final int runtimeBlockedRecordValidationCount;
  final int analyzerWiringBlockedRecordValidationCount;
  final int engineBlockedRecordValidationCount;
  final int schedulerBlockedRecordValidationCount;
  final int productAdapterBlockedRecordValidationCount;
  final int savedAnalysisBlockedRecordValidationCount;
  final int futureRequirementRecordValidationCount;
  final int policyValidationCount;
  final int reportSafetyValidationCount;
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
      !safeForPhase33W ||
      !sourceSkeletonSafeForPhase33V;

  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow rowForRole(
    DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole role,
  ) {
    return validationRows.firstWhere((row) => row.validationRole == role);
  }

  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationResult copyWith({
    DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationStatus? status,
    DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonStatus? sourceSkeletonStatus,
    bool? sourceSkeletonSafeForPhase33V,
    String? sourceSkeletonRecommendation,
    List<DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheck>?
    checks,
    List<DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow>?
    validationRows,
    List<String>? reportFindings,
    bool? safeForPhase33W,
    String? phase33WRecommendation,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationResult(
      status: status ?? this.status,
      sourceSkeletonStatus: sourceSkeletonStatus ?? this.sourceSkeletonStatus,
      sourceSkeletonSafeForPhase33V:
          sourceSkeletonSafeForPhase33V ?? this.sourceSkeletonSafeForPhase33V,
      sourceSkeletonRecommendation:
          sourceSkeletonRecommendation ?? this.sourceSkeletonRecommendation,
      checks: checks ?? this.checks,
      validationRows: validationRows ?? this.validationRows,
      reportFindings: reportFindings ?? this.reportFindings,
      safeForPhase33W: safeForPhase33W ?? this.safeForPhase33W,
      phase33WRecommendation:
          phase33WRecommendation ?? this.phase33WRecommendation,
    );
  }

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln(
        '# Debug-Only Bridge Analyzer Adapter Prototype Skeleton Validation',
      )
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationReportVersion',
      )
      ..writeln('- validation status: ${status.wire}')
      ..writeln('- source skeleton status: ${sourceSkeletonStatus.wire}')
      ..writeln('- safe for Phase 33W: $safeForPhase33W')
      ..writeln('- Phase 33W recommendation: $phase33WRecommendation')
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
      ..writeln('## Packet Validation Summary')
      ..writeln('- input packet validations: $inputPacketValidationCount')
      ..writeln('- context packet validations: $contextPacketValidationCount')
      ..writeln()
      ..writeln('## Record Role Validation Summary')
      ..writeln('- internal input records: $internalInputRecordValidationCount')
      ..writeln('- context-only records: $contextOnlyRecordValidationCount')
      ..writeln(
        '- warning-limited records: $warningLimitedRecordValidationCount',
      )
      ..writeln('- proof-boundary records: $proofBoundaryRecordValidationCount')
      ..writeln('- excluded-guard records: $excludedGuardRecordValidationCount')
      ..writeln(
        '- denied field records: $deniedFieldBoundaryRecordValidationCount',
      )
      ..writeln(
        '- future requirement records: $futureRequirementRecordValidationCount',
      )
      ..writeln()
      ..writeln('## Policy Validation Summary')
      ..writeln('- policy validations: $policyValidationCount')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- product output count: $productOutputCount')
      ..writeln()
      ..writeln('## Mapper Validator Debug Snapshot Validation Summary')
      ..writeln(
        '- mapper metadata validations: $mapperMetadataRecordValidationCount',
      )
      ..writeln(
        '- validator metadata validations: $validatorMetadataRecordValidationCount',
      )
      ..writeln(
        '- debug snapshot metadata validations: '
        '$debugSnapshotMetadataRecordValidationCount',
      )
      ..writeln()
      ..writeln('## Validation Row Table')
      ..writeln(
        '| Row | Source | Case ID | Source role | Validation role | Status | Developer only | In memory | Analyzer unwired | Inactive | Findings |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in validationRows) {
      buffer.writeln(
        '| ${row.validationRowId} | ${row.sourceRecordId} | '
        '${row.sourceCaseId} | ${row.sourceRole} | '
        '${row.validationRole.wire} | ${row.status.wire} | '
        '${row.developerOnly} | ${row.inMemoryOnly} | '
        '${row.analyzerUnwired} | ${row.inactive} | ${_ids(row.findings)} |',
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
      ..writeln('- required denied fields: ${_ids(_requiredDeniedFieldIds)}')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
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
      ..writeln('## Phase 33W Recommendation')
      ..writeln('- safe for Phase 33W: $safeForPhase33W')
      ..writeln('- recommendation: $phase33WRecommendation')
      ..writeln()
      ..writeln('## Report Findings')
      ..writeln('- findings: ${_ids(reportFindings)}');
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationReportVersion,
      'validationStatus': status.wire,
      'sourceSkeletonStatus': sourceSkeletonStatus.wire,
      'sourceSkeletonSafeForPhase33V': sourceSkeletonSafeForPhase33V,
      'sourceSkeletonRecommendation': sourceSkeletonRecommendation,
      'safeForPhase33W': safeForPhase33W,
      'phase33WRecommendation': phase33WRecommendation,
      'counts': <String, Object?>{
        'totalChecks': totalChecks,
        'passedCheckCount': passedCheckCount,
        'warningCheckCount': warningCheckCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'unsafeCount': unsafeCount,
        'totalValidationRows': totalValidationRows,
        'inputPacketValidationCount': inputPacketValidationCount,
        'contextPacketValidationCount': contextPacketValidationCount,
        'internalInputRecordValidationCount':
            internalInputRecordValidationCount,
        'contextOnlyRecordValidationCount': contextOnlyRecordValidationCount,
        'warningLimitedRecordValidationCount':
            warningLimitedRecordValidationCount,
        'proofBoundaryRecordValidationCount':
            proofBoundaryRecordValidationCount,
        'excludedGuardRecordValidationCount':
            excludedGuardRecordValidationCount,
        'allowedFieldBoundaryRecordValidationCount':
            allowedFieldBoundaryRecordValidationCount,
        'deniedFieldBoundaryRecordValidationCount':
            deniedFieldBoundaryRecordValidationCount,
        'mapperMetadataRecordValidationCount':
            mapperMetadataRecordValidationCount,
        'validatorMetadataRecordValidationCount':
            validatorMetadataRecordValidationCount,
        'debugSnapshotMetadataRecordValidationCount':
            debugSnapshotMetadataRecordValidationCount,
        'runtimeBlockedRecordValidationCount':
            runtimeBlockedRecordValidationCount,
        'analyzerWiringBlockedRecordValidationCount':
            analyzerWiringBlockedRecordValidationCount,
        'engineBlockedRecordValidationCount':
            engineBlockedRecordValidationCount,
        'schedulerBlockedRecordValidationCount':
            schedulerBlockedRecordValidationCount,
        'productAdapterBlockedRecordValidationCount':
            productAdapterBlockedRecordValidationCount,
        'savedAnalysisBlockedRecordValidationCount':
            savedAnalysisBlockedRecordValidationCount,
        'futureRequirementRecordValidationCount':
            futureRequirementRecordValidationCount,
        'policyValidationCount': policyValidationCount,
        'reportSafetyValidationCount': reportSafetyValidationCount,
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

class DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidation {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidation({
    this.validator =
        const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationValidator(),
  });

  final DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationValidator
  validator;

  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationResult evaluate({
    DebugOnlyBridgeAnalyzerAdapterPrototypeResult? skeletonResult,
  }) {
    final source =
        skeletonResult ??
        const DebugOnlyBridgeAnalyzerAdapterPrototypeMapper().evaluate();
    final sourceSafe =
        source.safeForPhase33V &&
        source.phase33VRecommendation ==
            'validateDebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonImplementation' &&
        !source.hasUnsafePolicyViolation;
    final initialRows =
        <DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow>[
          _rowFromInputPacket(source.inputPacket),
          _rowFromContextPacket(source.contextPacket),
          ...source.records.map(_rowFromRecord),
          _rowFromPolicy(source.policy),
          _rowFromReport(source),
        ];
    final rows = initialRows
        .map((row) => row.copyWith(findings: validator.validateRow(row)))
        .map(_rowWithStatus)
        .toList(growable: false);
    final reportFindings = validator.validateReportText(
      source.renderMarkdown(),
    );
    final hasFutureRequirement = rows.any(
      (row) =>
          row.validationRole ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
              .futureRequirementRecordValidation,
    );
    final checkFindings =
        <
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId,
          List<String>
        >{
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId
              .consumesSafePrototypeSkeleton: sourceSafe
              ? const <String>[]
              : const <String>['unsafePhase33USkeletonInput'],
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId
              .packetsAreDeveloperOnlyInMemory: _packetFindings(
            rows,
          ),
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId
              .recordsPreserveSkeletonRoles: _recordFindings(
            rows,
          ),
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId
              .mapperConsumesSafeInputs: source.sourceValidationSafeForPhase33U
              ? const <String>[]
              : const <String>['unsafePhase33TSourceInput'],
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId
                  .policyDisablesBlockedCapabilities:
              source.policy.hasUnsafeAllowance
              ? const <String>['unsafePrototypePolicyAllowance']
              : const <String>[],
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId
                  .debugSnapshotSafeMetadataOnly:
              source.debugSnapshot.safeForDeveloperInspection
              ? const <String>[]
              : const <String>['debugSnapshotUnsafeForDeveloperInspection'],
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId
                  .validatorRejectsDeniedSeams:
              const <String>[],
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId
                  .phase32EProofHonestyPreserved:
              _countFinding(rows, 'phase32ECapturedAndroidProofClaim') == 0
              ? const <String>[]
              : const <String>['phase32ECapturedAndroidProofClaim'],
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId
                  .androidProofIdsRemainCapturedOnly:
              _countFinding(rows, 'unprovenAndroidProofId') == 0
              ? const <String>[]
              : const <String>['unprovenAndroidProofId'],
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId
                  .ownerProofQueueRemainsEmpty:
              rows.where((row) => row.ownerProofRequired).isEmpty
              ? const <String>[]
              : const <String>['ownerProofRequired'],
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId
                  .deniedFieldsRemainInactive:
              _countFinding(rows, 'activeDeniedField') == 0
              ? const <String>[]
              : const <String>['activeDeniedField'],
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId
                  .runtimeAnalyzerEngineSchedulerRemainBlocked:
              _blockedBoundaryFindings(rows),
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId
              .noLabelsScoresRankingsMetrics: _labelScoreMetricFindings(
            rows,
          ),
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId
              .noCpLossOrWinProbability: _cpWinFindings(
            rows,
          ),
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId
              .noStockfishCommandRawUciPvDump: _rawBoundaryFindings(
            rows,
          ),
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId
                  .reportContainsNoRawUciOrPvDump:
              reportFindings,
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId
              .phase33WRequirementPresent: hasFutureRequirement
              ? const <String>[]
              : const <String>['missingPhase33WRequirement'],
        };
    final checks =
        DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId.values
            .map(
              (checkId) =>
                  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheck(
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
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckStatus
              .blocked,
    );
    final safe =
        sourceSafe &&
        hasFutureRequirement &&
        !hasRowFindings &&
        !hasCheckBlockers &&
        reportFindings.isEmpty;
    final status = !sourceSafe
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationStatus
              .blockedByUnsafePrototypeSkeleton
        : !hasFutureRequirement
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationStatus
              .invalidPrototypeSkeletonValidation
        : hasRowFindings || hasCheckBlockers || reportFindings.isNotEmpty
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationStatus
              .blockedByPolicyBoundary
        : source.status ==
                  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonStatus
                      .prototypeSkeletonReadyWithWarnings ||
              rows.any(
                (row) =>
                    row.warningReasons.isNotEmpty ||
                    row.proofLimitReasons.isNotEmpty,
              )
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationStatus
              .prototypeSkeletonValidatedWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationStatus
              .prototypeSkeletonValidatedClean;
    return DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationResult(
      status: status,
      sourceSkeletonStatus: source.status,
      sourceSkeletonSafeForPhase33V: source.safeForPhase33V,
      sourceSkeletonRecommendation: source.phase33VRecommendation,
      checks: checks,
      validationRows: rows,
      reportFindings: reportFindings,
      safeForPhase33W: safe,
      phase33WRecommendation: safe
          ? _phase33WRecommendation
          : 'blockedByUnsafeAnalyzerAdapterPrototypeSkeletonValidation',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationValidator {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationValidator();

  List<String> validateRow(
    DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow row,
  ) {
    final findings = <String>[];
    if (!_knownSourceRoles.contains(row.sourceRole)) {
      if (row.validationRole ==
              DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                  .inputPacketValidation ||
          row.validationRole ==
              DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                  .contextPacketValidation) {
        findings.add('unknownPacketRole');
      } else {
        findings.add('unknownRecordRole');
      }
    }
    if (!row.developerOnly || !row.inMemoryOnly) {
      findings.add('rowNotDeveloperOnlyInMemory');
    }
    if (!row.analyzerUnwired) findings.add('analyzerWiringEnabled');
    if (row.activeDeniedFieldIds.isNotEmpty) {
      findings.add('activeDeniedField');
    }
    if (row.allowedFieldIds.any(_isDeniedFieldId)) {
      findings.add('deniedFieldAllowedInternally');
    }
    if (row.deniedFieldIds.toSet().containsAll(_requiredDeniedFieldIds) ==
        false) {
      findings.add('missingRequiredDeniedField');
    }
    findings.addAll(_findingsForActiveDeniedFields(row.activeDeniedFieldIds));
    if (_isQuietRow(row) &&
        row.validationRole !=
            DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                .excludedGuardRecordValidation) {
      findings.add('quietPreparatoryPromoted');
    }
    if (row.sourceCaseId == _pvMultiPvBoundaryCaseId &&
        row.validationRole !=
            DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                .proofBoundaryRecordValidation &&
        row.validationRole !=
            DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                .contextOnlyRecordValidation) {
      findings.add('pvMultiPvPromotedBeyondBoundary');
    }
    if (_phase32ECaseIds.contains(row.sourceCaseId) &&
        row.androidProofCaseIds.isNotEmpty) {
      findings.add('phase32ECapturedAndroidProofClaim');
    }
    if (row.ownerProofRequired &&
        !row.proofLimitReasons.any(
          (reason) => reason.toLowerCase().contains('pv'),
        )) {
      findings.add('ownerProofWithoutPvMultiPvReason');
    }
    if (row.androidProofCaseIds.any(
      (caseId) => !_capturedAndroidProofIds.contains(caseId),
    )) {
      findings.add('unprovenAndroidProofId');
    }
    if (_isInactiveValidation(row.validationRole) && !row.inactive) {
      findings.add('inactiveBoundaryMadeActive');
    }
    if (row.validationRole ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                .futureRequirementRecordValidation &&
        row.recommendation != _phase33WRecommendation) {
      findings.add('missingPhase33WRequirement');
    }
    return findings.toSet().toList()..sort();
  }

  List<String> validateResult(
    DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationResult result,
  ) {
    final findings = <String>[];
    if (!result.sourceSkeletonSafeForPhase33V && result.safeForPhase33W) {
      findings.add('unsafePhase33USkeletonMarkedValidated');
    }
    if (result.futureRequirementRecordValidationCount == 0) {
      findings.add('missingPhase33WRequirement');
    }
    if (result.phase33WRecommendation != _phase33WRecommendation &&
        result.safeForPhase33W) {
      findings.add('missingPhase33WRequirement');
    }
    findings.addAll(validateReportText(result.renderMarkdown()));
    return findings.toSet().toList()..sort();
  }

  List<String> validateReportText(String reportText) {
    final lower = reportText.toLowerCase();
    return _rawReportLeakTokens
        .where((token) => lower.contains(token))
        .map((token) => 'reportTextLeak:$token')
        .toList(growable: false);
  }
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow
_rowFromInputPacket(DebugOnlyBridgeAnalyzerAdapterPrototypeInputPacket packet) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow(
    validationRowId: 'phase33v-${packet.inputPacketId}',
    sourceRecordId: packet.inputPacketId,
    sourceCaseId: 'phase33u',
    sourcePhase: 'Phase 33U',
    sourceRole: 'inputPacket',
    validationRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
            .inputPacketValidation,
    status: DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowStatus
        .validWithWarnings,
    developerOnly: packet.developerOnly,
    inMemoryOnly: packet.inMemoryOnly,
    analyzerUnwired: packet.analyzerUnwired,
    contextOnly: false,
    warningLimited: false,
    proofBoundaryOnly: false,
    excludedGuard: false,
    inactive: false,
    allowedFieldIds: _sorted(packet.allowedFieldIds),
    deniedFieldIds: _sorted(packet.deniedFieldIds),
    blockedBoundaryIds: _sorted(packet.blockedBoundaryIds),
    warningReasons: _sorted(packet.warningReasons),
    proofLimitReasons: _sorted(packet.proofLimitReasons),
    androidProofCaseIds: const <String>[],
    ownerProofRequired: false,
    activeDeniedFieldIds: const <String>[],
    findings: const <String>[],
    recommendation: _phase33WRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow
_rowFromContextPacket(
  DebugOnlyBridgeAnalyzerAdapterPrototypeContextPacket packet,
) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow(
    validationRowId: 'phase33v-${packet.contextPacketId}',
    sourceRecordId: packet.contextPacketId,
    sourceCaseId: 'phase33u',
    sourcePhase: 'Phase 33U',
    sourceRole: 'contextPacket',
    validationRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
            .contextPacketValidation,
    status: DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowStatus
        .validWithWarnings,
    developerOnly: packet.developerOnly,
    inMemoryOnly: true,
    analyzerUnwired: packet.analyzerUnwired,
    contextOnly: packet.contextOnly,
    warningLimited: false,
    proofBoundaryOnly: false,
    excludedGuard: false,
    inactive: false,
    allowedFieldIds: const <String>[],
    deniedFieldIds: _requiredDeniedFieldIds,
    blockedBoundaryIds: _sorted(packet.blockedBoundaryIds),
    warningReasons: _sorted(packet.warningReasons),
    proofLimitReasons: _sorted(packet.proofLimitReasons),
    androidProofCaseIds: const <String>[],
    ownerProofRequired: false,
    activeDeniedFieldIds: const <String>[],
    findings: const <String>[],
    recommendation: _phase33WRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow _rowFromRecord(
  DebugOnlyBridgeAnalyzerAdapterPrototypeRecord record,
) {
  final role = _validationRoleForRecordRole(record.role);
  return DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow(
    validationRowId: 'phase33v-${record.recordId}',
    sourceRecordId: record.recordId,
    sourceCaseId: record.sourceCaseId,
    sourcePhase: record.sourcePhase,
    sourceRole: record.role.wire,
    validationRole: role,
    status: DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowStatus
        .validWithWarnings,
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
    blockedBoundaryIds: _sorted(record.blockedBoundaryIds),
    warningReasons: _sorted(record.warningReasons),
    proofLimitReasons: _sorted(record.proofLimitReasons),
    androidProofCaseIds: _sorted(record.androidProofCaseIds),
    ownerProofRequired: record.ownerProofRequired,
    activeDeniedFieldIds: _sorted(record.activeDeniedFieldIds),
    findings: const <String>[],
    recommendation: _phase33WRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow _rowFromPolicy(
  DebugOnlyBridgeAnalyzerAdapterPrototypePolicy policy,
) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow(
    validationRowId: 'phase33v-policy-validation',
    sourceRecordId: 'phase33u-policy',
    sourceCaseId: 'phase33u',
    sourcePhase: 'Phase 33U',
    sourceRole: 'policy',
    validationRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
            .policyValidation,
    status: DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowStatus
        .valid,
    developerOnly: true,
    inMemoryOnly: true,
    analyzerUnwired: true,
    contextOnly: false,
    warningLimited: false,
    proofBoundaryOnly: false,
    excludedGuard: false,
    inactive: false,
    allowedFieldIds: _sorted(policy.allowedFieldIds),
    deniedFieldIds: _sorted(policy.deniedFieldIds),
    blockedBoundaryIds: const <String>[
      'analyzerWiring',
      'engineCall',
      'productOutput',
      'runtimeImplementation',
      'schedulerExecution',
    ],
    warningReasons: const <String>[],
    proofLimitReasons: const <String>[],
    androidProofCaseIds: _sorted(policy.capturedAndroidProofIds),
    ownerProofRequired: false,
    activeDeniedFieldIds: policy.hasUnsafeAllowance
        ? const <String>['unsafePolicyAllowance']
        : const <String>[],
    findings: const <String>[],
    recommendation: _phase33WRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow _rowFromReport(
  DebugOnlyBridgeAnalyzerAdapterPrototypeResult source,
) {
  final reportFindings =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationValidator()
          .validateReportText(source.renderMarkdown());
  return DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow(
    validationRowId: 'phase33v-report-safety-validation',
    sourceRecordId: 'phase33u-report',
    sourceCaseId: 'phase33u',
    sourcePhase: 'Phase 33U',
    sourceRole: 'reportSafety',
    validationRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
            .reportSafetyValidation,
    status: reportFindings.isEmpty
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowStatus
              .valid
        : DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowStatus
              .unsafeRow,
    developerOnly: true,
    inMemoryOnly: true,
    analyzerUnwired: true,
    contextOnly: false,
    warningLimited: false,
    proofBoundaryOnly: false,
    excludedGuard: false,
    inactive: false,
    allowedFieldIds: const <String>[],
    deniedFieldIds: _requiredDeniedFieldIds,
    blockedBoundaryIds: const <String>['rawUci', 'pvDump', 'stockfishCommand'],
    warningReasons: const <String>[],
    proofLimitReasons: const <String>[],
    androidProofCaseIds: const <String>[],
    ownerProofRequired: false,
    activeDeniedFieldIds: const <String>[],
    findings: reportFindings,
    recommendation: _phase33WRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow _rowWithStatus(
  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow row,
) {
  if (row.findings.isNotEmpty) {
    return row.copyWith(
      status: DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowStatus
          .unsafeRow,
    );
  }
  if (row.warningReasons.isNotEmpty || row.proofLimitReasons.isNotEmpty) {
    return row.copyWith(
      status: DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowStatus
          .validWithWarnings,
    );
  }
  return row.copyWith(
    status: DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowStatus
        .valid,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckStatus
_checkStatus(
  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId checkId,
  List<String> findings,
  DebugOnlyBridgeAnalyzerAdapterPrototypeResult source,
) {
  if (findings.isNotEmpty) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckStatus
        .blocked;
  }
  if (checkId ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckId
              .consumesSafePrototypeSkeleton &&
      source.status ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonStatus
              .prototypeSkeletonReadyWithWarnings) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckStatus
        .passedWithWarnings;
  }
  return DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationCheckStatus
      .passed;
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
_validationRoleForRecordRole(
  DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole role,
) {
  return switch (role) {
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.internalInputRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
          .internalInputRecordValidation,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.contextOnlyRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
          .contextOnlyRecordValidation,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.warningLimitedRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
          .warningLimitedRecordValidation,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.proofBoundaryRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
          .proofBoundaryRecordValidation,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.excludedGuardRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
          .excludedGuardRecordValidation,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
        .allowedFieldBoundaryRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
          .allowedFieldBoundaryRecordValidation,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
        .deniedFieldBoundaryRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
          .deniedFieldBoundaryRecordValidation,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.mapperMetadataRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
          .mapperMetadataRecordValidation,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.validatorMetadataRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
          .validatorMetadataRecordValidation,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
        .debugSnapshotMetadataRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
          .debugSnapshotMetadataRecordValidation,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.runtimeBlockedRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
          .runtimeBlockedRecordValidation,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
        .analyzerWiringBlockedRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
          .analyzerWiringBlockedRecordValidation,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.engineBlockedRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
          .engineBlockedRecordValidation,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.schedulerBlockedRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
          .schedulerBlockedRecordValidation,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
        .productAdapterBlockedRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
          .productAdapterBlockedRecordValidation,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
        .savedAnalysisBlockedRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
          .savedAnalysisBlockedRecordValidation,
    DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.futureRequirementRecord =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
          .futureRequirementRecordValidation,
  };
}

bool _isInactiveValidation(
  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole role,
) {
  return role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
              .deniedFieldBoundaryRecordValidation ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
              .runtimeBlockedRecordValidation ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
              .analyzerWiringBlockedRecordValidation ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
              .engineBlockedRecordValidation ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
              .schedulerBlockedRecordValidation ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
              .productAdapterBlockedRecordValidation ||
      role ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
              .savedAnalysisBlockedRecordValidation;
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
    }
  }
  return findings;
}

List<String> _packetFindings(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow> rows,
) {
  return _sorted(
    rows
        .where(
          (row) =>
              row.validationRole ==
                  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                      .inputPacketValidation ||
              row.validationRole ==
                  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                      .contextPacketValidation,
        )
        .expand((row) => row.findings),
  );
}

List<String> _recordFindings(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow> rows,
) {
  return _sorted(
    rows
        .where(
          (row) =>
              row.validationRole !=
                  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                      .inputPacketValidation &&
              row.validationRole !=
                  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                      .contextPacketValidation &&
              row.validationRole !=
                  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                      .policyValidation &&
              row.validationRole !=
                  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                      .reportSafetyValidation,
        )
        .expand((row) => row.findings),
  );
}

List<String> _blockedBoundaryFindings(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow> rows,
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
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow> rows,
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
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow> rows,
) {
  return _findingsByIds(rows, const <String>{
    'cpLossLeak',
    'winProbabilityLeak',
  });
}

List<String> _rawBoundaryFindings(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow> rows,
) {
  return _findingsByIds(rows, const <String>{
    'stockfishCommandLeak',
    'rawUciLeak',
    'pvDumpLeak',
  });
}

List<String> _findingsByIds(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow> rows,
  Set<String> findingIds,
) {
  return _sorted(
    rows
        .expand((row) => row.findings)
        .where((finding) => findingIds.contains(finding)),
  );
}

bool _isQuietRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow row,
) {
  if (row.validationRole ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
              .inputPacketValidation ||
      row.validationRole ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
              .contextPacketValidation ||
      row.validationRole ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
              .policyValidation ||
      row.validationRole ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
              .reportSafetyValidation) {
    return false;
  }
  return row.sourceCaseId.contains('quiet-preparatory') ||
      row.blockedBoundaryIds.contains('quietPreparatoryCoreActivation') ||
      row.proofLimitReasons.contains(
        'quietPreparatoryExcludedFromActiveCoreOutput',
      );
}

int _countRole(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow> rows,
  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole role,
) {
  return rows.where((row) => row.validationRole == role).length;
}

int _countFinding(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow> rows,
  String finding,
) {
  return rows.where((row) => row.findings.contains(finding)).length;
}

int _countActiveDeniedField(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow> rows,
  String fieldId,
) {
  return rows.where((row) => row.activeDeniedFieldIds.contains(fieldId)).length;
}

bool _isCriticalFinding(String finding) =>
    finding.startsWith('reportTextLeak:');

bool _isDeniedFieldId(String fieldId) =>
    _requiredDeniedFieldIds.contains(fieldId);

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

const _requiredDeniedFieldIds = <String>[
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
  'reportSafety',
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

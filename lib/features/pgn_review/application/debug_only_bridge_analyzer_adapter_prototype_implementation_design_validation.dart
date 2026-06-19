import 'dart:convert';

import 'debug_only_bridge_analyzer_adapter_prototype_implementation_design.dart';
import 'golden_analysis_suite.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationReportVersion =
    'debug-only-bridge-analyzer-adapter-prototype-implementation-design-validation-v1';

enum DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationStatus {
  prototypeImplementationDesignValidatedWithWarnings(
    'prototypeImplementationDesignValidatedWithWarnings',
  ),
  prototypeImplementationDesignValidatedClean(
    'prototypeImplementationDesignValidatedClean',
  ),
  blockedByUnsafeImplementationDesign('blockedByUnsafeImplementationDesign'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidImplementationDesignValidation(
    'invalidImplementationDesignValidation',
  );

  const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationStatus(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId {
  consumesSafePrototypeImplementationDesign(
    'consumesSafePrototypeImplementationDesign',
  ),
  implementationDesignGroupsAreDeterministic(
    'implementationDesignGroupsAreDeterministic',
  ),
  implementationDesignRecordsAreDeterministic(
    'implementationDesignRecordsAreDeterministic',
  ),
  futureClassPacketNamesArePresentAndSafe(
    'futureClassPacketNamesArePresentAndSafe',
  ),
  inputPacketDesignsRemainFutureInternalOnly(
    'inputPacketDesignsRemainFutureInternalOnly',
  ),
  contextPacketDesignsRemainContextOnly(
    'contextPacketDesignsRemainContextOnly',
  ),
  warningLimitedPacketDesignsRemainWarningLimited(
    'warningLimitedPacketDesignsRemainWarningLimited',
  ),
  proofBoundaryPacketDesignsRemainProofBoundaryOnly(
    'proofBoundaryPacketDesignsRemainProofBoundaryOnly',
  ),
  excludedGuardDesignsRemainExcluded('excludedGuardDesignsRemainExcluded'),
  mapperValidatorSnapshotRemainMetadataOnly(
    'mapperValidatorSnapshotRemainMetadataOnly',
  ),
  allowedFieldsRemainInternalMetadataOnly(
    'allowedFieldsRemainInternalMetadataOnly',
  ),
  deniedFieldsRemainInactive('deniedFieldsRemainInactive'),
  phase32ECasesDoNotClaimCapturedAndroidProof(
    'phase32ECasesDoNotClaimCapturedAndroidProof',
  ),
  androidProofIdsRemainCapturedOnly('androidProofIdsRemainCapturedOnly'),
  ownerProofQueueRemainsEmpty('ownerProofQueueRemainsEmpty'),
  analyzerWiringRemainsBlocked('analyzerWiringRemainsBlocked'),
  runtimeExecutablePrototypeRemainBlocked(
    'runtimeExecutablePrototypeRemainBlocked',
  ),
  engineSchedulerUiBackendPersistenceRemainBlocked(
    'engineSchedulerUiBackendPersistenceRemainBlocked',
  ),
  productAdapterSavedAnalysisRemainBlocked(
    'productAdapterSavedAnalysisRemainBlocked',
  ),
  noLabelsScoresRankingsMetrics('noLabelsScoresRankingsMetrics'),
  noCpLossOrWinProbability('noCpLossOrWinProbability'),
  thresholdsRemainDenied('thresholdsRemainDenied'),
  noStockfishCommandRawUciPvDump('noStockfishCommandRawUciPvDump'),
  reportContainsNoRawUciOrPvDump('reportContainsNoRawUciOrPvDump'),
  phase33URequirementPresent('phase33URequirementPresent');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckStatus {
  passed('passed'),
  passedWithWarnings('passedWithWarnings'),
  blocked('blocked');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckStatus(
    this.wire,
  );

  final String wire;

  bool get isPassed => this == passed || this == passedWithWarnings;
  bool get isWarning => this == passedWithWarnings;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRowStatus {
  valid('valid'),
  validWithWarnings('validWithWarnings'),
  unsafeRow('unsafeRow'),
  invalid('invalid');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRowStatus(
    this.wire,
  );

  final String wire;

  bool get isUnsafe => this == unsafeRow;
  bool get isInvalid => this == invalid;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheck {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheck({
    required this.checkId,
    required this.status,
    this.findings = const <String>[],
  });

  final DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
  checkId;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckStatus
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

class DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRow {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRow({
    required this.validationRowId,
    required this.sourceImplementationDesignRecordId,
    required this.sourceValidationRowId,
    required this.sourceContractRecordId,
    required this.sourcePrototypeRecordId,
    required this.sourceCaseId,
    required this.sourcePhase,
    required this.prototypePacketRole,
    required this.contractRole,
    required this.implementationDesignRole,
    required this.status,
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
    required this.allowedInternalFieldIds,
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
  final String sourceImplementationDesignRecordId;
  final String sourceValidationRowId;
  final String sourceContractRecordId;
  final String sourcePrototypeRecordId;
  final String sourceCaseId;
  final String sourcePhase;
  final String prototypePacketRole;
  final String contractRole;
  final String implementationDesignRole;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRowStatus
  status;
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
  final List<String> allowedInternalFieldIds;
  final List<String> deniedFieldIds;
  final List<String> blockedBoundaryIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofCaseIds;
  final bool ownerProofRequired;
  final List<String> activeDeniedFieldIds;
  final List<String> findings;
  final String recommendation;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'validationRowId': validationRowId,
      'sourceImplementationDesignRecordId': sourceImplementationDesignRecordId,
      'sourceValidationRowId': sourceValidationRowId,
      'sourceContractRecordId': sourceContractRecordId,
      'sourcePrototypeRecordId': sourcePrototypeRecordId,
      'sourceCaseId': sourceCaseId,
      'sourcePhase': sourcePhase,
      'prototypePacketRole': prototypePacketRole,
      'contractRole': contractRole,
      'implementationDesignRole': implementationDesignRole,
      'status': status.wire,
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
      'allowedInternalFieldIds': allowedInternalFieldIds,
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

class DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationResult {
  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationResult({
    required this.status,
    required this.sourceImplementationDesignStatus,
    required this.sourceImplementationDesignSafeForPhase33T,
    required this.sourceImplementationDesignRecommendation,
    required this.checks,
    required this.validationRows,
    required this.reportFindings,
    required this.safeForPhase33U,
    required this.phase33URecommendation,
  }) : totalChecks = checks.length,
       passedCheckCount = checks.where((check) => check.status.isPassed).length,
       warningCheckCount = checks
           .where((check) => check.status.isWarning)
           .length,
       blockerCount = checks
           .where(
             (check) =>
                 check.status ==
                 DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckStatus
                     .blocked,
           )
           .length,
       criticalCount = reportFindings.where(_isCriticalFinding).length,
       totalValidationRows = validationRows.length,
       inputPacketDesignValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationInputPacketDesign,
       ),
       contextPacketDesignValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationContextPacketDesign,
       ),
       warningLimitedPacketDesignValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationWarningLimitedPacketDesign,
       ),
       proofBoundaryPacketDesignValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationProofBoundaryPacketDesign,
       ),
       excludedGuardPacketDesignValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationExcludedGuardPacketDesign,
       ),
       allowedFieldDesignValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationAllowedFieldDesign,
       ),
       deniedFieldDesignValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationDeniedFieldDesign,
       ),
       mapperDesignValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationMapperDesign,
       ),
       validatorDesignValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationValidatorDesign,
       ),
       debugSnapshotDesignValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationDebugSnapshotDesign,
       ),
       runtimeBlockedValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationRuntimeBlocked,
       ),
       analyzerWiringBlockedValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationAnalyzerWiringBlocked,
       ),
       engineBlockedValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationEngineBlocked,
       ),
       schedulerBlockedValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationSchedulerBlocked,
       ),
       productAdapterBlockedValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationProductAdapterBlocked,
       ),
       savedAnalysisBlockedValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .implementationSavedAnalysisBlocked,
       ),
       futureRequirementValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
             .phase33TRequirement,
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

  final DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationStatus
  status;
  final String sourceImplementationDesignStatus;
  final bool sourceImplementationDesignSafeForPhase33T;
  final String sourceImplementationDesignRecommendation;
  final List<
    DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheck
  >
  checks;
  final List<
    DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRow
  >
  validationRows;
  final List<String> reportFindings;
  final bool safeForPhase33U;
  final String phase33URecommendation;
  final int totalChecks;
  final int passedCheckCount;
  final int warningCheckCount;
  final int blockerCount;
  final int criticalCount;
  late final int unsafeCount;
  final int totalValidationRows;
  final int inputPacketDesignValidationCount;
  final int contextPacketDesignValidationCount;
  final int warningLimitedPacketDesignValidationCount;
  final int proofBoundaryPacketDesignValidationCount;
  final int excludedGuardPacketDesignValidationCount;
  final int allowedFieldDesignValidationCount;
  final int deniedFieldDesignValidationCount;
  final int mapperDesignValidationCount;
  final int validatorDesignValidationCount;
  final int debugSnapshotDesignValidationCount;
  final int runtimeBlockedValidationCount;
  final int analyzerWiringBlockedValidationCount;
  final int engineBlockedValidationCount;
  final int schedulerBlockedValidationCount;
  final int productAdapterBlockedValidationCount;
  final int savedAnalysisBlockedValidationCount;
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
      !safeForPhase33U ||
      !sourceImplementationDesignSafeForPhase33T;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln(
        '# Debug-Only Bridge Analyzer Adapter Prototype Implementation Design Validation',
      )
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationReportVersion',
      )
      ..writeln('- validation status: ${status.wire}')
      ..writeln(
        '- source implementation design status: '
        '$sourceImplementationDesignStatus',
      )
      ..writeln('- safe for Phase 33U: $safeForPhase33U')
      ..writeln('- Phase 33U recommendation: $phase33URecommendation')
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
      ..writeln('## Implementation Design Group Validation')
      ..writeln('- input packet validations: $inputPacketDesignValidationCount')
      ..writeln(
        '- context packet validations: $contextPacketDesignValidationCount',
      )
      ..writeln(
        '- warning-limited packet validations: '
        '$warningLimitedPacketDesignValidationCount',
      )
      ..writeln(
        '- proof-boundary packet validations: '
        '$proofBoundaryPacketDesignValidationCount',
      )
      ..writeln(
        '- excluded-guard packet validations: '
        '$excludedGuardPacketDesignValidationCount',
      )
      ..writeln('- denied field validations: $deniedFieldDesignValidationCount')
      ..writeln()
      ..writeln('## Future Name Validation')
      ..writeln(
        '- required future class names: ${_ids(_requiredFutureClassNames)}',
      )
      ..writeln('- mapper validations: $mapperDesignValidationCount')
      ..writeln('- validator validations: $validatorDesignValidationCount')
      ..writeln(
        '- debug snapshot validations: $debugSnapshotDesignValidationCount',
      )
      ..writeln()
      ..writeln('## Implementation Design Row Validation Table')
      ..writeln(
        '| Row | Source record | Case ID | Source phase | Implementation role | Status | Analyzer unwired | Runtime blocked | Executable blocked | Findings | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in validationRows) {
      buffer.writeln(
        '| ${row.validationRowId} | ${row.sourceImplementationDesignRecordId} | '
        '${row.sourceCaseId} | ${row.sourcePhase} | '
        '${row.implementationDesignRole} | ${row.status.wire} | '
        '${row.analyzerUnwired} | ${row.runtimeBlocked} | '
        '${row.executablePrototypeBlocked} | ${_ids(row.findings)} | '
        '${row.recommendation} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Allowed and Denied Field Validation')
      ..writeln('- allowed metadata fields: ${_ids(_allowedInternalFieldIds)}')
      ..writeln('- required denied fields: ${_ids(_requiredDeniedFieldIds)}')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- threshold leak count: $thresholdLeakCount')
      ..writeln()
      ..writeln('## Blocked Boundary Validation')
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
      ..writeln('## Phase 33U Requirement')
      ..writeln('- future requirement count: $futureRequirementValidationCount')
      ..writeln('- recommendation: $phase33URecommendation')
      ..writeln()
      ..writeln('## Report Findings')
      ..writeln('- findings: ${_ids(reportFindings)}');
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationReportVersion,
      'validationStatus': status.wire,
      'sourceImplementationDesignStatus': sourceImplementationDesignStatus,
      'sourceImplementationDesignSafeForPhase33T':
          sourceImplementationDesignSafeForPhase33T,
      'sourceImplementationDesignRecommendation':
          sourceImplementationDesignRecommendation,
      'safeForPhase33U': safeForPhase33U,
      'phase33URecommendation': phase33URecommendation,
      'counts': <String, Object?>{
        'totalChecks': totalChecks,
        'passedCheckCount': passedCheckCount,
        'warningCheckCount': warningCheckCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'unsafeCount': unsafeCount,
        'totalValidationRows': totalValidationRows,
        'inputPacketDesignValidationCount': inputPacketDesignValidationCount,
        'contextPacketDesignValidationCount':
            contextPacketDesignValidationCount,
        'warningLimitedPacketDesignValidationCount':
            warningLimitedPacketDesignValidationCount,
        'proofBoundaryPacketDesignValidationCount':
            proofBoundaryPacketDesignValidationCount,
        'excludedGuardPacketDesignValidationCount':
            excludedGuardPacketDesignValidationCount,
        'allowedFieldDesignValidationCount': allowedFieldDesignValidationCount,
        'deniedFieldDesignValidationCount': deniedFieldDesignValidationCount,
        'mapperDesignValidationCount': mapperDesignValidationCount,
        'validatorDesignValidationCount': validatorDesignValidationCount,
        'debugSnapshotDesignValidationCount':
            debugSnapshotDesignValidationCount,
        'runtimeBlockedValidationCount': runtimeBlockedValidationCount,
        'analyzerWiringBlockedValidationCount':
            analyzerWiringBlockedValidationCount,
        'engineBlockedValidationCount': engineBlockedValidationCount,
        'schedulerBlockedValidationCount': schedulerBlockedValidationCount,
        'productAdapterBlockedValidationCount':
            productAdapterBlockedValidationCount,
        'savedAnalysisBlockedValidationCount':
            savedAnalysisBlockedValidationCount,
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
      'requiredFutureClassNames': _requiredFutureClassNames.toList()..sort(),
      'capturedAndroidProofIds': _capturedAndroidProofIds.toList()..sort(),
      'checks': checks.map((check) => check.toJson()).toList(growable: false),
      'validationRows': validationRows
          .map((row) => row.toJson())
          .toList(growable: false),
      'reportFindings': reportFindings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidation {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidation({
    this.validator =
        const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationValidator(),
  });

  final DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationValidator
  validator;

  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationResult
  evaluate({
    DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignResult?
    implementationDesignResult,
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  }) {
    final source =
        implementationDesignResult ??
        const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesign()
            .evaluate(cases: cases);
    final repeated =
        const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesign()
            .evaluate(cases: cases);
    final knownCaseIds = cases.map((caseData) => caseData.id).toSet();
    final rows = source.implementationDesignRecords
        .map(
          (record) =>
              validator.validateRecord(record, knownCaseIds: knownCaseIds),
        )
        .toList(growable: false);
    final reportFindings = validator.validateReportText(
      _renderRowsForLeakCheck(rows),
    );
    final hasFutureRequirement = source.implementationDesignRecords.any(
      (record) =>
          record.implementationDesignRole ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
              .phase33TRequirement,
    );
    final sourceSafe =
        source.safeForPhase33T &&
        source.phase33TRecommendation == _phase33TSourceRecommendation &&
        !source.hasUnsafePolicyViolation;

    final checks =
        <
          DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheck
        >[
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .consumesSafePrototypeImplementationDesign,
            sourceSafe,
            warning: source.status.wire.contains('WithWarnings'),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .implementationDesignGroupsAreDeterministic,
            _groupWire(source) == _groupWire(repeated),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .implementationDesignRecordsAreDeterministic,
            _recordWire(source) == _recordWire(repeated),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .futureClassPacketNamesArePresentAndSafe,
            source.proposedClassNames.toSet().containsAll(
                  _requiredFutureClassNames,
                ) &&
                source.proposedMapperNames.contains(
                  'DebugOnlyBridgeAnalyzerAdapterPrototypeMapper',
                ) &&
                source.proposedValidatorNames.contains(
                  'DebugOnlyBridgeAnalyzerAdapterPrototypeValidator',
                ) &&
                source.proposedDebugSnapshotNames.contains(
                  'DebugOnlyBridgeAnalyzerAdapterPrototypeDebugSnapshot',
                ) &&
                rows.every(
                  (row) => row.futureClassNames.every(
                    _requiredFutureClassNames.contains,
                  ),
                ),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .inputPacketDesignsRemainFutureInternalOnly,
            _rowsWithRole(
              rows,
              DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                  .implementationInputPacketDesign,
            ).every(
              (row) =>
                  row.developerOnly &&
                  row.designOnly &&
                  row.analyzerUnwired &&
                  row.runtimeBlocked &&
                  row.executablePrototypeBlocked &&
                  row.findings.isEmpty,
            ),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .contextPacketDesignsRemainContextOnly,
            _rowsWithRole(
              rows,
              DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                  .implementationContextPacketDesign,
            ).every((row) => row.findings.isEmpty),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .warningLimitedPacketDesignsRemainWarningLimited,
            _rowsWithRole(
              rows,
              DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                  .implementationWarningLimitedPacketDesign,
            ).every((row) => row.findings.isEmpty),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .proofBoundaryPacketDesignsRemainProofBoundaryOnly,
            _rowsWithRole(
              rows,
              DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                  .implementationProofBoundaryPacketDesign,
            ).every((row) => row.findings.isEmpty),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .excludedGuardDesignsRemainExcluded,
            rows
                .where(_isQuietRow)
                .every(
                  (row) =>
                      row.implementationDesignRole ==
                          DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                              .implementationExcludedGuardPacketDesign
                              .wire &&
                      row.findings.isEmpty,
                ),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .mapperValidatorSnapshotRemainMetadataOnly,
            _metadataOnlyRows(rows).every(
              (row) =>
                  row.developerOnly &&
                  row.designOnly &&
                  row.analyzerUnwired &&
                  row.runtimeBlocked &&
                  row.executablePrototypeBlocked &&
                  row.findings.isEmpty,
            ),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .allowedFieldsRemainInternalMetadataOnly,
            rows.every(
              (row) =>
                  row.allowedInternalFieldIds.every(
                    _allowedInternalFieldIds.contains,
                  ) &&
                  row.allowedInternalFieldIds.every(
                    (fieldId) => !row.deniedFieldIds.contains(fieldId),
                  ),
            ),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .deniedFieldsRemainInactive,
            rows.every(
              (row) => row.activeDeniedFieldIds.isEmpty && row.findings.isEmpty,
            ),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .phase32ECasesDoNotClaimCapturedAndroidProof,
            rows
                .where((row) => _phase32ECaseIds.contains(row.sourceCaseId))
                .every((row) => row.androidProofCaseIds.isEmpty),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .androidProofIdsRemainCapturedOnly,
            rows.every(
              (row) => row.androidProofCaseIds.every(
                _capturedAndroidProofIds.contains,
              ),
            ),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .ownerProofQueueRemainsEmpty,
            rows.every((row) => !row.ownerProofRequired),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .analyzerWiringRemainsBlocked,
            rows.every((row) => row.analyzerUnwired) &&
                source.analyzerWiringCount == 0,
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .runtimeExecutablePrototypeRemainBlocked,
            rows.every(
                  (row) => row.runtimeBlocked && row.executablePrototypeBlocked,
                ) &&
                source.runtimeImplementationCount == 0 &&
                source.executablePrototypeCount == 0,
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .engineSchedulerUiBackendPersistenceRemainBlocked,
            source.engineCallCount == 0 &&
                source.schedulerExecutionCount == 0 &&
                source.uiTargetCount == 0 &&
                source.backendTargetCount == 0 &&
                source.persistenceWriteCount == 0,
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .productAdapterSavedAnalysisRemainBlocked,
            rows.every(
                  (row) =>
                      !row.activeDeniedFieldIds.contains(
                        'productAdapterBehavior',
                      ) &&
                      !row.activeDeniedFieldIds.contains(
                        'savedAnalysisIntegration',
                      ),
                ) &&
                source.productAdapterBehaviorCount == 0 &&
                source.savedAnalysisIntegrationCount == 0,
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .noLabelsScoresRankingsMetrics,
            source.labelLeakCount == 0 &&
                source.finalLabelLeakCount == 0 &&
                source.scoreLeakCount == 0 &&
                source.metricLeakCount == 0 &&
                source.moveRankingLeakCount == 0,
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .noCpLossOrWinProbability,
            source.cpLossLeakCount == 0 && source.winProbabilityLeakCount == 0,
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .thresholdsRemainDenied,
            rows.every(
              (row) => !row.activeDeniedFieldIds.contains('thresholds'),
            ),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .noStockfishCommandRawUciPvDump,
            source.stockfishCommandLeakCount == 0 &&
                source.rawUciLeakCount == 0 &&
                source.pvDumpLeakCount == 0,
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .reportContainsNoRawUciOrPvDump,
            reportFindings.isEmpty,
            findings: reportFindings,
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
                .phase33URequirementPresent,
            hasFutureRequirement &&
                _phase33URecommendation ==
                    'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonImplementation',
          ),
        ];

    final anyBlocked = checks.any(
      (check) =>
          check.status ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckStatus
              .blocked,
    );
    final anyUnsafeRows = rows.any(
      (row) => row.status.isUnsafe || row.status.isInvalid,
    );
    final sourceUnsafe =
        source.hasUnsafePolicyViolation ||
        !source.safeForPhase33T ||
        source.phase33TRecommendation != _phase33TSourceRecommendation;
    final safe =
        !sourceUnsafe &&
        hasFutureRequirement &&
        !anyBlocked &&
        !anyUnsafeRows &&
        reportFindings.isEmpty;
    final status = sourceUnsafe
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationStatus
              .blockedByUnsafeImplementationDesign
        : !hasFutureRequirement
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationStatus
              .invalidImplementationDesignValidation
        : reportFindings.isNotEmpty || anyUnsafeRows || anyBlocked
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationStatus
              .blockedByPolicyBoundary
        : checks.any((check) => check.status.isWarning) ||
              rows.any(
                (row) =>
                    row.warningReasons.isNotEmpty ||
                    row.proofLimitReasons.isNotEmpty,
              )
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationStatus
              .prototypeImplementationDesignValidatedWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationStatus
              .prototypeImplementationDesignValidatedClean;

    return DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationResult(
      status: status,
      sourceImplementationDesignStatus: source.status.wire,
      sourceImplementationDesignSafeForPhase33T: source.safeForPhase33T,
      sourceImplementationDesignRecommendation: source.phase33TRecommendation,
      checks: checks,
      validationRows: rows,
      reportFindings: reportFindings,
      safeForPhase33U: safe,
      phase33URecommendation: safe
          ? _phase33URecommendation
          : 'blockedByUnsafeAnalyzerAdapterPrototypeImplementationDesignValidation',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationValidator {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationValidator();

  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRow
  validateRecord(
    DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord record, {
    required Set<String> knownCaseIds,
  }) {
    final findings = <String>{
      ...record.findings,
      ...const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidator()
          .validateRecord(record, knownCaseIds: knownCaseIds),
    };
    final expectedRole = _expectedRoleForContractRole(record.contractRole);
    if (expectedRole != null &&
        expectedRole != record.implementationDesignRole) {
      findings.add('implementationRoleDoesNotMatchContractRole');
    }
    if (record.futureClassNames.any(
      (name) => !_requiredFutureClassNames.contains(name),
    )) {
      findings.add('unknownFutureClassName');
    }
    if (record.futurePacketNames.any(
      (name) => !_allowedFuturePacketNames.contains(name),
    )) {
      findings.add('unknownFuturePacketName');
    }
    if (record.futureMapperNames.any(
      (name) => name != 'DebugOnlyBridgeAnalyzerAdapterPrototypeMapper',
    )) {
      findings.add('unknownFutureMapperName');
    }
    if (record.futureValidatorNames.any(
      (name) => name != 'DebugOnlyBridgeAnalyzerAdapterPrototypeValidator',
    )) {
      findings.add('unknownFutureValidatorName');
    }
    if (record.futureDebugSnapshotNames.any(
      (name) => name != 'DebugOnlyBridgeAnalyzerAdapterPrototypeDebugSnapshot',
    )) {
      findings.add('unknownFutureDebugSnapshotName');
    }
    if (record.implementationDesignRole ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                .implementationMapperDesign &&
        !record.futureMapperNames.contains(
          'DebugOnlyBridgeAnalyzerAdapterPrototypeMapper',
        )) {
      findings.add('missingFutureMapperName');
    }
    if (record.implementationDesignRole ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                .implementationValidatorDesign &&
        !record.futureValidatorNames.contains(
          'DebugOnlyBridgeAnalyzerAdapterPrototypeValidator',
        )) {
      findings.add('missingFutureValidatorName');
    }
    if (record.implementationDesignRole ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                .implementationDebugSnapshotDesign &&
        !record.futureDebugSnapshotNames.contains(
          'DebugOnlyBridgeAnalyzerAdapterPrototypeDebugSnapshot',
        )) {
      findings.add('missingFutureDebugSnapshotName');
    }
    if (record.implementationDesignRole ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                .phase33TRequirement &&
        record.recommendation != _phase33TSourceRecommendation) {
      findings.add('missingPhase33URequirement');
    }

    final sortedFindings = findings.toList(growable: false)..sort();
    final status = sortedFindings.isNotEmpty
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRowStatus
              .unsafeRow
        : record.warningReasons.isNotEmpty ||
              record.proofLimitReasons.isNotEmpty
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRowStatus
              .validWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRowStatus
              .valid;

    return DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRow(
      validationRowId: 'phase33t-${record.implementationDesignRecordId}',
      sourceImplementationDesignRecordId: record.implementationDesignRecordId,
      sourceValidationRowId: record.sourceValidationRowId,
      sourceContractRecordId: record.sourceContractRecordId,
      sourcePrototypeRecordId: record.sourcePrototypeRecordId,
      sourceCaseId: record.sourceCaseId,
      sourcePhase: record.sourcePhase,
      prototypePacketRole: record.prototypePacketRole,
      contractRole: record.contractRole,
      implementationDesignRole: record.implementationDesignRole.wire,
      status: status,
      developerOnly: record.developerOnly,
      designOnly: record.designOnly,
      analyzerUnwired: record.analyzerUnwired,
      runtimeBlocked: record.runtimeBlocked,
      executablePrototypeBlocked: record.executablePrototypeBlocked,
      futureClassNames: record.futureClassNames,
      futurePacketNames: record.futurePacketNames,
      futureMapperNames: record.futureMapperNames,
      futureValidatorNames: record.futureValidatorNames,
      futureDebugSnapshotNames: record.futureDebugSnapshotNames,
      allowedInternalFieldIds: record.allowedInternalFieldIds,
      deniedFieldIds: record.deniedFieldIds,
      blockedBoundaryIds: record.blockedBoundaryIds,
      warningReasons: record.warningReasons,
      proofLimitReasons: record.proofLimitReasons,
      androidProofCaseIds: record.androidProofCaseIds,
      ownerProofRequired: record.ownerProofRequired,
      activeDeniedFieldIds: record.activeDeniedFieldIds,
      findings: sortedFindings,
      recommendation: record.recommendation,
    );
  }

  List<String> validateReportText(String reportText) {
    final lower = reportText.toLowerCase();
    return _rawReportLeakTokens
        .where((token) => lower.contains(token))
        .map((token) => 'reportTextLeak:$token')
        .toList(growable: false);
  }
}

DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheck
_check(
  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckId
  checkId,
  bool passed, {
  bool warning = false,
  List<String> findings = const <String>[],
}) {
  if (!passed) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheck(
      checkId: checkId,
      status:
          DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckStatus
              .blocked,
      findings: findings.isEmpty ? <String>[checkId.wire] : findings,
    );
  }
  return DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheck(
    checkId: checkId,
    status: warning
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckStatus
              .passedWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationCheckStatus
              .passed,
    findings: findings,
  );
}

Iterable<
  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRow
>
_rowsWithRole(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRow
  >
  rows,
  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole role,
) {
  return rows.where((row) => row.implementationDesignRole == role.wire);
}

Iterable<
  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRow
>
_metadataOnlyRows(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRow
  >
  rows,
) {
  return rows.where(
    (row) =>
        row.implementationDesignRole ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                .implementationMapperDesign
                .wire ||
        row.implementationDesignRole ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                .implementationValidatorDesign
                .wire ||
        row.implementationDesignRole ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                .implementationDebugSnapshotDesign
                .wire,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole?
_expectedRoleForContractRole(String contractRole) {
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
    'deniedFieldContract' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
          .implementationDeniedFieldDesign,
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
    'phase33sSyntheticImplementationDesign' => null,
    _ =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
          .implementationDeniedFieldDesign,
  };
}

bool _isQuietRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRow row,
) {
  return row.sourceCaseId.contains('quiet-preparatory') ||
      row.blockedBoundaryIds.contains('quietPreparatoryCoreActivation') ||
      row.proofLimitReasons.contains(
        'quietPreparatoryExcludedFromActiveCoreOutput',
      );
}

String _groupWire(
  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignResult result,
) {
  return const JsonEncoder.withIndent('  ').convert(
    result.implementationDesignGroups.map((group) => group.toJson()).toList(),
  );
}

String _recordWire(
  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignResult result,
) {
  return const JsonEncoder.withIndent('  ').convert(
    result.implementationDesignRecords
        .map((record) => record.toJson())
        .toList(),
  );
}

String _renderRowsForLeakCheck(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRow
  >
  rows,
) {
  return rows
      .map(
        (row) => [
          row.validationRowId,
          row.sourceCaseId,
          row.prototypePacketRole,
          row.contractRole,
          row.implementationDesignRole,
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
    DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRow
  >
  rows,
  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole role,
) {
  return rows.where((row) => row.implementationDesignRole == role.wire).length;
}

int _countFinding(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRow
  >
  rows,
  String finding,
) {
  return rows.where((row) => row.findings.contains(finding)).length;
}

int _countActiveDeniedField(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationRow
  >
  rows,
  String fieldId,
) {
  return rows.where((row) => row.activeDeniedFieldIds.contains(fieldId)).length;
}

bool _isCriticalFinding(String finding) =>
    finding.startsWith('reportTextLeak:');

String _ids(Iterable<String> values) =>
    values.isEmpty ? '-' : values.join(', ');

const _phase33TSourceRecommendation =
    'validateDebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesign';

const _phase33URecommendation =
    'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonImplementation';

const _phase32ECaseIds = <String>{
  'king-safety-mating-net-pressure-32e',
  'endgame-precision-candidate-spread-32e',
  'suppression-forced-only-legal-32e',
  'budget-pressure-wide-candidate-32e',
  'pv-multipv-support-boundary-32e',
};

const _capturedAndroidProofIds = <String>{
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
};

const _requiredFutureClassNames = <String>{
  'DebugOnlyBridgeAnalyzerAdapterPrototypeInputPacket',
  'DebugOnlyBridgeAnalyzerAdapterPrototypeContextPacket',
  'DebugOnlyBridgeAnalyzerAdapterPrototypeRecord',
  'DebugOnlyBridgeAnalyzerAdapterPrototypePolicy',
  'DebugOnlyBridgeAnalyzerAdapterPrototypeMapper',
  'DebugOnlyBridgeAnalyzerAdapterPrototypeResult',
  'DebugOnlyBridgeAnalyzerAdapterPrototypeValidator',
  'DebugOnlyBridgeAnalyzerAdapterPrototypeDebugSnapshot',
};

const _allowedFuturePacketNames = <String>{
  'DebugOnlyBridgeAnalyzerAdapterPrototypeInputPacket',
  'DebugOnlyBridgeAnalyzerAdapterPrototypeContextPacket',
  'DebugOnlyBridgeAnalyzerAdapterPrototypeRecord',
  'DebugOnlyBridgeAnalyzerAdapterPrototypePolicy',
};

const _allowedInternalFieldIds = <String>{
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
};

const _requiredDeniedFieldIds = <String>{
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

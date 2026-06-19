import 'dart:convert';

import 'debug_only_bridge_analyzer_adapter_prototype_contract_design.dart';
import 'golden_analysis_suite.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportVersion =
    'debug-only-bridge-analyzer-adapter-prototype-contract-design-validation-v1';

enum DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationStatus {
  prototypeContractDesignValidatedWithWarnings(
    'prototypeContractDesignValidatedWithWarnings',
  ),
  prototypeContractDesignValidatedClean(
    'prototypeContractDesignValidatedClean',
  ),
  blockedByUnsafeContractDesign('blockedByUnsafeContractDesign'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidContractDesignValidation('invalidContractDesignValidation');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationStatus(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId {
  consumesSafePrototypeContractDesign('consumesSafePrototypeContractDesign'),
  contractGroupsAreDeterministic('contractGroupsAreDeterministic'),
  contractRecordsAreDeterministic('contractRecordsAreDeterministic'),
  internalInputContractsRemainFutureInternalOnly(
    'internalInputContractsRemainFutureInternalOnly',
  ),
  contextOnlyContractsRemainContextOnly(
    'contextOnlyContractsRemainContextOnly',
  ),
  warningLimitedContractsRemainWarningLimited(
    'warningLimitedContractsRemainWarningLimited',
  ),
  proofBoundaryContractsRemainProofBoundaryOnly(
    'proofBoundaryContractsRemainProofBoundaryOnly',
  ),
  quietPreparatoryRemainsExcludedGuard('quietPreparatoryRemainsExcludedGuard'),
  allowedInternalFieldsRemainMetadataOnly(
    'allowedInternalFieldsRemainMetadataOnly',
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
  phase33SRequirementPresent('phase33SRequirementPresent');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckStatus {
  passed('passed'),
  passedWithWarnings('passedWithWarnings'),
  blocked('blocked');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckStatus(
    this.wire,
  );

  final String wire;

  bool get isPassed => this == passed || this == passedWithWarnings;
  bool get isWarning => this == passedWithWarnings;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationRowStatus {
  valid('valid'),
  validWithWarnings('validWithWarnings'),
  unsafeRow('unsafeRow'),
  invalid('invalid');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationRowStatus(
    this.wire,
  );

  final String wire;

  bool get isUnsafe => this == unsafeRow;
  bool get isInvalid => this == invalid;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheck {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheck({
    required this.checkId,
    required this.status,
    this.findings = const <String>[],
  });

  final DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
  checkId;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckStatus
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

class DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationRow {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationRow({
    required this.validationRowId,
    required this.sourceContractRecordId,
    required this.sourcePrototypeRecordId,
    required this.sourceCaseId,
    required this.sourcePhase,
    required this.prototypePacketRole,
    required this.contractRole,
    required this.status,
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
    required this.findings,
    required this.recommendation,
  });

  final String validationRowId;
  final String sourceContractRecordId;
  final String sourcePrototypeRecordId;
  final String sourceCaseId;
  final String sourcePhase;
  final String prototypePacketRole;
  final String contractRole;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationRowStatus
  status;
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
  final List<String> findings;
  final String recommendation;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'validationRowId': validationRowId,
      'sourceContractRecordId': sourceContractRecordId,
      'sourcePrototypeRecordId': sourcePrototypeRecordId,
      'sourceCaseId': sourceCaseId,
      'sourcePhase': sourcePhase,
      'prototypePacketRole': prototypePacketRole,
      'contractRole': contractRole,
      'status': status.wire,
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
      'findings': findings,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationResult {
  DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationResult({
    required this.status,
    required this.sourceContractDesignStatus,
    required this.sourceContractDesignSafeForPhase33R,
    required this.sourceContractDesignRecommendation,
    required this.checks,
    required this.validationRows,
    required this.reportFindings,
    required this.safeForPhase33S,
    required this.phase33SRecommendation,
  }) : totalChecks = checks.length,
       passedCheckCount = checks.where((check) => check.status.isPassed).length,
       warningCheckCount = checks
           .where((check) => check.status.isWarning)
           .length,
       blockerCount = checks
           .where(
             (check) =>
                 check.status ==
                 DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckStatus
                     .blocked,
           )
           .length,
       criticalCount = reportFindings.where(_isCriticalFinding).length,
       totalValidationRows = validationRows.length,
       internalInputContractValidationCount = _countContractRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .internalInputContract,
       ),
       contextOnlyContractValidationCount = _countContractRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .contextOnlyContract,
       ),
       warningLimitedContractValidationCount = _countContractRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .warningLimitedContract,
       ),
       proofBoundaryContractValidationCount = _countContractRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .proofBoundaryContract,
       ),
       excludedGuardContractValidationCount = _countContractRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .excludedGuardContract,
       ),
       allowedInternalFieldContractValidationCount = _countContractRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .allowedInternalFieldContract,
       ),
       deniedFieldContractValidationCount = _countContractRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .deniedFieldContract,
       ),
       runtimeBlockedContractValidationCount = _countContractRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .runtimeBlockedContract,
       ),
       analyzerWiringBlockedContractValidationCount = _countContractRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .analyzerWiringBlockedContract,
       ),
       engineBlockedContractValidationCount = _countContractRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .engineBlockedContract,
       ),
       schedulerBlockedContractValidationCount = _countContractRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .schedulerBlockedContract,
       ),
       futureRequirementContractValidationCount = _countContractRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
             .futureRequirementContract,
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

  final DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationStatus
  status;
  final String sourceContractDesignStatus;
  final bool sourceContractDesignSafeForPhase33R;
  final String sourceContractDesignRecommendation;
  final List<
    DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheck
  >
  checks;
  final List<DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationRow>
  validationRows;
  final List<String> reportFindings;
  final bool safeForPhase33S;
  final String phase33SRecommendation;
  final int totalChecks;
  final int passedCheckCount;
  final int warningCheckCount;
  final int blockerCount;
  final int criticalCount;
  late final int unsafeCount;
  final int totalValidationRows;
  final int internalInputContractValidationCount;
  final int contextOnlyContractValidationCount;
  final int warningLimitedContractValidationCount;
  final int proofBoundaryContractValidationCount;
  final int excludedGuardContractValidationCount;
  final int allowedInternalFieldContractValidationCount;
  final int deniedFieldContractValidationCount;
  final int runtimeBlockedContractValidationCount;
  final int analyzerWiringBlockedContractValidationCount;
  final int engineBlockedContractValidationCount;
  final int schedulerBlockedContractValidationCount;
  final int futureRequirementContractValidationCount;
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
      !safeForPhase33S ||
      !sourceContractDesignSafeForPhase33R;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln(
        '# Debug-Only Bridge Analyzer Adapter Prototype Contract Design Validation',
      )
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportVersion',
      )
      ..writeln('- validation status: ${status.wire}')
      ..writeln('- source contract design status: $sourceContractDesignStatus')
      ..writeln('- safe for Phase 33S: $safeForPhase33S')
      ..writeln('- Phase 33S recommendation: $phase33SRecommendation')
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
      ..writeln('## Contract Group Validation')
      ..writeln(
        '- internal input contract validation count: '
        '$internalInputContractValidationCount',
      )
      ..writeln(
        '- context-only contract validation count: '
        '$contextOnlyContractValidationCount',
      )
      ..writeln(
        '- warning-limited contract validation count: '
        '$warningLimitedContractValidationCount',
      )
      ..writeln(
        '- proof-boundary contract validation count: '
        '$proofBoundaryContractValidationCount',
      )
      ..writeln(
        '- excluded guard contract validation count: '
        '$excludedGuardContractValidationCount',
      )
      ..writeln(
        '- allowed internal field contract validation count: '
        '$allowedInternalFieldContractValidationCount',
      )
      ..writeln(
        '- denied field contract validation count: '
        '$deniedFieldContractValidationCount',
      )
      ..writeln(
        '- runtime blocked contract validation count: '
        '$runtimeBlockedContractValidationCount',
      )
      ..writeln(
        '- analyzer wiring blocked contract validation count: '
        '$analyzerWiringBlockedContractValidationCount',
      )
      ..writeln(
        '- engine blocked contract validation count: '
        '$engineBlockedContractValidationCount',
      )
      ..writeln(
        '- scheduler blocked contract validation count: '
        '$schedulerBlockedContractValidationCount',
      )
      ..writeln(
        '- future requirement contract validation count: '
        '$futureRequirementContractValidationCount',
      )
      ..writeln()
      ..writeln('## Contract Record Validation Table')
      ..writeln(
        '| Row | Contract record | Prototype record | Case ID | Source phase | '
        'Prototype packet | Contract role | Status | Android proof IDs | '
        'Active denied fields | Findings | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in validationRows) {
      buffer.writeln(
        '| ${row.validationRowId} | ${row.sourceContractRecordId} | '
        '${row.sourcePrototypeRecordId} | ${row.sourceCaseId} | '
        '${row.sourcePhase} | ${row.prototypePacketRole} | '
        '${row.contractRole} | ${row.status.wire} | '
        '${_ids(row.androidProofCaseIds)} | '
        '${_ids(row.activeDeniedFieldIds)} | ${_ids(row.findings)} | '
        '${row.recommendation} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Allowed and Denied Field Validation')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- threshold leak count: $thresholdLeakCount')
      ..writeln('- label leak count: $labelLeakCount')
      ..writeln('- final label leak count: $finalLabelLeakCount')
      ..writeln('- score leak count: $scoreLeakCount')
      ..writeln('- metric leak count: $metricLeakCount')
      ..writeln('- CP-loss leak count: $cpLossLeakCount')
      ..writeln('- win-probability leak count: $winProbabilityLeakCount')
      ..writeln('- move ranking leak count: $moveRankingLeakCount')
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
      ..writeln('## Phase 33S Recommendation')
      ..writeln('- recommendation: $phase33SRecommendation')
      ..writeln()
      ..writeln('## Report Findings')
      ..writeln('- findings: ${_ids(reportFindings)}');
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportVersion,
      'validationStatus': status.wire,
      'sourceContractDesignStatus': sourceContractDesignStatus,
      'sourceContractDesignSafeForPhase33R':
          sourceContractDesignSafeForPhase33R,
      'sourceContractDesignRecommendation': sourceContractDesignRecommendation,
      'safeForPhase33S': safeForPhase33S,
      'phase33SRecommendation': phase33SRecommendation,
      'counts': <String, Object?>{
        'totalChecks': totalChecks,
        'passedCheckCount': passedCheckCount,
        'warningCheckCount': warningCheckCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'unsafeCount': unsafeCount,
        'totalValidationRows': totalValidationRows,
        'internalInputContractValidationCount':
            internalInputContractValidationCount,
        'contextOnlyContractValidationCount':
            contextOnlyContractValidationCount,
        'warningLimitedContractValidationCount':
            warningLimitedContractValidationCount,
        'proofBoundaryContractValidationCount':
            proofBoundaryContractValidationCount,
        'excludedGuardContractValidationCount':
            excludedGuardContractValidationCount,
        'allowedInternalFieldContractValidationCount':
            allowedInternalFieldContractValidationCount,
        'deniedFieldContractValidationCount':
            deniedFieldContractValidationCount,
        'runtimeBlockedContractValidationCount':
            runtimeBlockedContractValidationCount,
        'analyzerWiringBlockedContractValidationCount':
            analyzerWiringBlockedContractValidationCount,
        'engineBlockedContractValidationCount':
            engineBlockedContractValidationCount,
        'schedulerBlockedContractValidationCount':
            schedulerBlockedContractValidationCount,
        'futureRequirementContractValidationCount':
            futureRequirementContractValidationCount,
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

class DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidation {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidation({
    this.contractDesign =
        const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign(),
    this.validator =
        const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationValidator(),
  });

  final DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign contractDesign;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationValidator
  validator;

  DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationResult
  evaluate({
    DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignResult?
    contractDesignResult,
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  }) {
    final source =
        contractDesignResult ?? contractDesign.evaluate(cases: cases);
    final knownCaseIds = cases.map((caseData) => caseData.id).toSet();
    final rows = source.contractRecords
        .map(
          (record) =>
              validator.validateRecord(record, knownCaseIds: knownCaseIds),
        )
        .toList(growable: false);
    final repeated = contractDesignResult == null
        ? contractDesign.evaluate(cases: cases)
        : source;
    final reportFindings = <String>[
      ...validator.validateReportText(source.renderMarkdown()),
      ...validator.validateReportText(source.renderJson()),
    ]..sort();
    final hasFutureRequirement = rows.any(
      (row) =>
          row.contractRole ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
              .futureRequirementContract
              .wire,
    );
    final checks = <DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheck>[
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .consumesSafePrototypeContractDesign,
        source.safeForPhase33R &&
            source.phase33RRecommendation ==
                'validateDebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign' &&
            !source.hasUnsafePolicyViolation,
        warning: source.status.wire.contains('WithWarnings'),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .contractGroupsAreDeterministic,
        _groupWire(source) == _groupWire(repeated),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .contractRecordsAreDeterministic,
        _recordWire(source) == _recordWire(repeated),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .internalInputContractsRemainFutureInternalOnly,
        _rowsWithContractRole(
          rows,
          DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
              .internalInputContract,
        ).every(
          (row) =>
              row.developerOnly &&
              row.contractOnly &&
              row.analyzerUnwired &&
              row.runtimeBlocked &&
              row.executablePrototypeBlocked &&
              row.findings.isEmpty,
        ),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .contextOnlyContractsRemainContextOnly,
        _rowsWithContractRole(
          rows,
          DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
              .contextOnlyContract,
        ).every((row) => row.findings.isEmpty),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .warningLimitedContractsRemainWarningLimited,
        _rowsWithContractRole(
          rows,
          DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
              .warningLimitedContract,
        ).every((row) => row.findings.isEmpty),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .proofBoundaryContractsRemainProofBoundaryOnly,
        _rowsWithContractRole(
          rows,
          DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
              .proofBoundaryContract,
        ).every((row) => row.findings.isEmpty),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .quietPreparatoryRemainsExcludedGuard,
        rows
            .where(_isQuietRow)
            .every(
              (row) =>
                  row.contractRole ==
                      DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
                          .excludedGuardContract
                          .wire &&
                  row.findings.isEmpty,
            ),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .allowedInternalFieldsRemainMetadataOnly,
        rows.every(
          (row) =>
              row.allowedInternalFieldIds.every(
                _allowedInternalMetadataFieldIds.contains,
              ) &&
              row.allowedInternalFieldIds.every(
                (fieldId) => !row.deniedFieldIds.contains(fieldId),
              ),
        ),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .deniedFieldsRemainInactive,
        rows.every(
          (row) => row.activeDeniedFieldIds.isEmpty && row.findings.isEmpty,
        ),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .phase32ECasesDoNotClaimCapturedAndroidProof,
        rows
            .where((row) => _phase32ECaseIds.contains(row.sourceCaseId))
            .every((row) => row.androidProofCaseIds.isEmpty),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .androidProofIdsRemainCapturedOnly,
        rows.every(
          (row) =>
              row.androidProofCaseIds.every(_capturedAndroidProofIds.contains),
        ),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .ownerProofQueueRemainsEmpty,
        rows.every((row) => !row.ownerProofRequired),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .analyzerWiringRemainsBlocked,
        rows.every((row) => row.analyzerUnwired) &&
            source.analyzerWiringCount == 0,
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .runtimeExecutablePrototypeRemainBlocked,
        rows.every(
              (row) => row.runtimeBlocked && row.executablePrototypeBlocked,
            ) &&
            source.runtimeImplementationCount == 0 &&
            source.executablePrototypeCount == 0,
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .engineSchedulerUiBackendPersistenceRemainBlocked,
        source.engineCallCount == 0 &&
            source.schedulerExecutionCount == 0 &&
            source.uiTargetCount == 0 &&
            source.backendTargetCount == 0 &&
            source.persistenceWriteCount == 0,
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .productAdapterSavedAnalysisRemainBlocked,
        rows.every(
          (row) =>
              !row.activeDeniedFieldIds.contains('productAdapterBehavior') &&
              !row.activeDeniedFieldIds.contains('savedAnalysisIntegration'),
        ),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .noLabelsScoresRankingsMetrics,
        source.labelLeakCount == 0 &&
            source.finalLabelLeakCount == 0 &&
            source.scoreLeakCount == 0 &&
            source.metricLeakCount == 0 &&
            source.moveRankingLeakCount == 0,
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .noCpLossOrWinProbability,
        source.cpLossLeakCount == 0 && source.winProbabilityLeakCount == 0,
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .thresholdsRemainDenied,
        rows.every((row) => !row.activeDeniedFieldIds.contains('thresholds')),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .noStockfishCommandRawUciPvDump,
        source.stockfishCommandLeakCount == 0 &&
            source.rawUciLeakCount == 0 &&
            source.pvDumpLeakCount == 0,
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .reportContainsNoRawUciOrPvDump,
        reportFindings.isEmpty,
        findings: reportFindings,
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
            .phase33SRequirementPresent,
        hasFutureRequirement &&
            _phase33SRecommendation ==
                'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesign',
      ),
    ];

    final anyBlocked = checks.any(
      (check) =>
          check.status ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckStatus
              .blocked,
    );
    final anyUnsafeRows = rows.any(
      (row) => row.status.isUnsafe || row.status.isInvalid,
    );
    final sourceUnsafe =
        source.hasUnsafePolicyViolation ||
        !source.safeForPhase33R ||
        source.phase33RRecommendation !=
            'validateDebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign';
    final safe =
        !sourceUnsafe &&
        hasFutureRequirement &&
        !anyBlocked &&
        !anyUnsafeRows &&
        reportFindings.isEmpty;
    final status = sourceUnsafe
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationStatus
              .blockedByUnsafeContractDesign
        : !hasFutureRequirement
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationStatus
              .invalidContractDesignValidation
        : reportFindings.isNotEmpty || anyUnsafeRows || anyBlocked
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationStatus
              .blockedByPolicyBoundary
        : checks.any((check) => check.status.isWarning) ||
              rows.any(
                (row) =>
                    row.warningReasons.isNotEmpty ||
                    row.proofLimitReasons.isNotEmpty,
              )
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationStatus
              .prototypeContractDesignValidatedWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationStatus
              .prototypeContractDesignValidatedClean;

    return DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationResult(
      status: status,
      sourceContractDesignStatus: source.status.wire,
      sourceContractDesignSafeForPhase33R: source.safeForPhase33R,
      sourceContractDesignRecommendation: source.phase33RRecommendation,
      checks: checks,
      validationRows: rows,
      reportFindings: reportFindings,
      safeForPhase33S: safe,
      phase33SRecommendation: safe
          ? _phase33SRecommendation
          : 'blockedByUnsafeAnalyzerAdapterPrototypeContractDesignValidation',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationValidator {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationValidator();

  DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationRow
  validateRecord(
    DebugOnlyBridgeAnalyzerAdapterPrototypeContractRecord record, {
    required Set<String> knownCaseIds,
  }) {
    final findings = <String>{
      ...record.findings,
      ...const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidator()
          .validateRecord(record, knownCaseIds: knownCaseIds),
    };
    final expectedRole = _expectedRoleForPrototypePacket(
      record.prototypePacketRole,
    );
    if (expectedRole != null && expectedRole != record.contractRole) {
      findings.add('contractRoleDoesNotMatchPrototypePacketRole');
    }
    if (record.contractRole ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
                .internalInputContract &&
        _isQuietRecord(record)) {
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
    if (record.allowedInternalFieldIds.any(
      (fieldId) => !_allowedInternalMetadataFieldIds.contains(fieldId),
    )) {
      findings.add('nonMetadataAllowedInternalField');
    }
    if (record.allowedInternalFieldIds.any(record.deniedFieldIds.contains)) {
      findings.add('deniedFieldAllowedInternally');
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
    if (record.deniedFieldIds.contains('rawUci') == false ||
        record.deniedFieldIds.contains('pvDump') == false ||
        record.deniedFieldIds.contains('stockfishCommand') == false) {
      findings.add('missingEngineTextDeniedField');
    }
    final sortedFindings = findings.toList(growable: false)..sort();
    final status = sortedFindings.isNotEmpty
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationRowStatus
              .unsafeRow
        : record.warningReasons.isNotEmpty ||
              record.proofLimitReasons.isNotEmpty
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationRowStatus
              .validWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationRowStatus
              .valid;

    return DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationRow(
      validationRowId: 'phase33r-${record.contractRecordId}',
      sourceContractRecordId: record.contractRecordId,
      sourcePrototypeRecordId: record.sourcePrototypeRecordId,
      sourceCaseId: record.sourceCaseId,
      sourcePhase: record.sourcePhase,
      prototypePacketRole: record.prototypePacketRole,
      contractRole: record.contractRole.wire,
      status: status,
      allowedInternalFieldIds: record.allowedInternalFieldIds,
      deniedFieldIds: record.deniedFieldIds,
      blockedBoundaryIds: record.blockedBoundaryIds,
      warningReasons: record.warningReasons,
      proofLimitReasons: record.proofLimitReasons,
      androidProofCaseIds: record.androidProofCaseIds,
      ownerProofRequired: record.ownerProofRequired,
      developerOnly: record.developerOnly,
      contractOnly: record.contractOnly,
      analyzerUnwired: record.analyzerUnwired,
      runtimeBlocked: record.runtimeBlocked,
      executablePrototypeBlocked: record.executablePrototypeBlocked,
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

DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheck _check(
  DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckId
  checkId,
  bool passed, {
  bool warning = false,
  List<String> findings = const <String>[],
}) {
  if (!passed) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheck(
      checkId: checkId,
      status:
          DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckStatus
              .blocked,
      findings: findings.isEmpty ? <String>[checkId.wire] : findings,
    );
  }
  return DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheck(
    checkId: checkId,
    status: warning
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckStatus
              .passedWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationCheckStatus
              .passed,
    findings: findings,
  );
}

Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationRow>
_rowsWithContractRole(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationRow>
  rows,
  DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole role,
) {
  return rows.where((row) => row.contractRole == role.wire);
}

DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole?
_expectedRoleForPrototypePacket(String packetRole) {
  return switch (packetRole) {
    'analyzerAdapterPrototypeInputPacket' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole.internalInputContract,
    'analyzerAdapterPrototypeContextPacket' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole.contextOnlyContract,
    'analyzerAdapterPrototypeWarningLimitedPacket' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
          .warningLimitedContract,
    'analyzerAdapterPrototypeProofBoundaryPacket' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole.proofBoundaryContract,
    'analyzerAdapterPrototypeExcludedGuardPacket' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole.excludedGuardContract,
    'analyzerAdapterPrototypeDeniedFieldPacket' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole.deniedFieldContract,
    'analyzerAdapterPrototypeFutureRequirementPacket' =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
          .futureRequirementContract,
    'phase33qSyntheticContract' => null,
    _ =>
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole.deniedFieldContract,
  };
}

bool _isQuietRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationRow row,
) {
  return row.sourceCaseId.contains('quiet-preparatory') ||
      row.blockedBoundaryIds.contains('quietPreparatoryCoreActivation') ||
      row.proofLimitReasons.contains(
        'quietPreparatoryExcludedFromActiveCoreOutput',
      );
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

String _groupWire(
  DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignResult result,
) {
  return const JsonEncoder.withIndent(
    '  ',
  ).convert(result.contractGroups.map((group) => group.toJson()).toList());
}

String _recordWire(
  DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignResult result,
) {
  return const JsonEncoder.withIndent(
    '  ',
  ).convert(result.contractRecords.map((record) => record.toJson()).toList());
}

int _countContractRole(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationRow>
  rows,
  DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole role,
) {
  return rows.where((row) => row.contractRole == role.wire).length;
}

int _countFinding(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationRow>
  rows,
  String finding,
) {
  return rows.where((row) => row.findings.contains(finding)).length;
}

int _countActiveDeniedField(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationRow>
  rows,
  String fieldId,
) {
  return rows.where((row) => row.activeDeniedFieldIds.contains(fieldId)).length;
}

bool _isCriticalFinding(String finding) =>
    finding.startsWith('reportTextLeak:');

String _ids(Iterable<String> values) =>
    values.isEmpty ? '-' : values.join(', ');

const _phase33SRecommendation =
    'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesign';

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

const _allowedInternalMetadataFieldIds = <String>{
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

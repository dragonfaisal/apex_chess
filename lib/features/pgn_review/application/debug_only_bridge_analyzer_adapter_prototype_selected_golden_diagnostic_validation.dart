import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationVersion =
    'debug-only-bridge-analyzer-adapter-prototype-selected-golden-diagnostic-validation-v1';

enum DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationStatus {
  selectedGoldenAnalyzerAdapterPrototypeDiagnosticValidatedWithWarnings(
    'selectedGoldenAnalyzerAdapterPrototypeDiagnosticValidatedWithWarnings',
  ),
  selectedGoldenAnalyzerAdapterPrototypeDiagnosticValidatedClean(
    'selectedGoldenAnalyzerAdapterPrototypeDiagnosticValidatedClean',
  ),
  blockedByUnsafeSelectedGoldenDiagnostic(
    'blockedByUnsafeSelectedGoldenDiagnostic',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidSelectedGoldenDiagnosticValidation(
    'invalidSelectedGoldenDiagnosticValidation',
  );

  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationStatus(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId {
  phase33YDiagnosticPathIsSafe('phase33YDiagnosticPathIsSafe'),
  phase33ZSelectedDiagnosticPathIsSafe('phase33ZSelectedDiagnosticPathIsSafe'),
  defaultSelectedOutputDeterministic('defaultSelectedOutputDeterministic'),
  allSafeSelectedOutputDeterministic('allSafeSelectedOutputDeterministic'),
  singleSelectedCaseOutputDeterministic(
    'singleSelectedCaseOutputDeterministic',
  ),
  listGoldenCasesOutputDeterministic('listGoldenCasesOutputDeterministic'),
  goldenSectionOutputDeterministic('goldenSectionOutputDeterministic'),
  markdownJsonStrictModesAreSafe('markdownJsonStrictModesAreSafe'),
  selectedRowsPreserveRequiredShape('selectedRowsPreserveRequiredShape'),
  developerSupportRowsRemainDiagnosticOnly(
    'developerSupportRowsRemainDiagnosticOnly',
  ),
  phase32ERowsRemainWarningLimited('phase32ERowsRemainWarningLimited'),
  pvMultiPvRemainsProofBoundaryOnly('pvMultiPvRemainsProofBoundaryOnly'),
  quietPreparatoryRemainsExcludedGuardOnly(
    'quietPreparatoryRemainsExcludedGuardOnly',
  ),
  phase32ECasesDoNotClaimCapturedAndroidProof(
    'phase32ECasesDoNotClaimCapturedAndroidProof',
  ),
  androidProofIdsRemainCapturedOnly('androidProofIdsRemainCapturedOnly'),
  ownerProofQueueRemainsEmpty('ownerProofQueueRemainsEmpty'),
  deniedFieldsRemainInactive('deniedFieldsRemainInactive'),
  reportTextRemainsSafe('reportTextRemainsSafe'),
  phase34BRequirementPresent('phase34BRequirementPresent');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckStatus {
  passed('passed'),
  passedWithWarnings('passedWithWarnings'),
  blocked('blocked');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckStatus(
    this.wire,
  );

  final String wire;

  bool get isPassed => this == passed || this == passedWithWarnings;

  bool get isWarning => this == passedWithWarnings;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationRowStatus {
  valid('valid'),
  validWithWarnings('validWithWarnings'),
  unsafeRow('unsafeRow'),
  invalidRow('invalidRow');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationRowStatus(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow({
    required this.caseId,
    required this.title,
    required this.sourcePhase,
    required this.selectedReason,
    required this.diagnosticRole,
    required this.supportAreaIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.androidProofIds,
    required this.ownerProofRequired,
    required this.activeDeniedFieldIds,
    required this.blockedBoundaryIds,
    required this.recommendation,
  });

  final String caseId;
  final String title;
  final String sourcePhase;
  final String selectedReason;
  final String diagnosticRole;
  final List<String> supportAreaIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofIds;
  final bool ownerProofRequired;
  final List<String> activeDeniedFieldIds;
  final List<String> blockedBoundaryIds;
  final String recommendation;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSource {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSource({
    required this.phase33YDiagnosticPathSafe,
    required this.phase33ZSelectedDiagnosticPathSafe,
    required this.defaultSelectedOutputDeterministic,
    required this.allSafeSelectedOutputDeterministic,
    required this.singleSelectedCaseOutputDeterministic,
    required this.listGoldenCasesOutputDeterministic,
    required this.goldenSectionOutputDeterministic,
    required this.markdownJsonStrictModesSafe,
    required this.defaultSelectedRows,
    required this.allSafeSelectedRows,
    required this.singleSelectedRows,
    required this.listedGoldenCaseIds,
    required this.reportTexts,
    this.phase34BRecommendation =
        'proceedToAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan',
  });

  factory DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSource.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  }) {
    final byId = {for (final item in cases) item.id: item};
    List<
      DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
    >
    rowsFor(List<String> ids) {
      return ids.map((id) => _sourceRowForCase(byId[id]!)).toList();
    }

    final defaultRows = rowsFor(_defaultSelectedGoldenCaseIds);
    final allSafeRows = rowsFor(_allSafeSelectedGoldenCaseIds);
    final singleRows = rowsFor(const <String>['queen-win-major-swing']);
    return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSource(
      phase33YDiagnosticPathSafe: true,
      phase33ZSelectedDiagnosticPathSafe: true,
      defaultSelectedOutputDeterministic: true,
      allSafeSelectedOutputDeterministic: true,
      singleSelectedCaseOutputDeterministic: true,
      listGoldenCasesOutputDeterministic: true,
      goldenSectionOutputDeterministic: true,
      markdownJsonStrictModesSafe: true,
      defaultSelectedRows: defaultRows,
      allSafeSelectedRows: allSafeRows,
      singleSelectedRows: singleRows,
      listedGoldenCaseIds: cases.map((item) => item.id).toList()..sort(),
      reportTexts: const <String>['safe selected Golden validation text'],
    );
  }

  final bool phase33YDiagnosticPathSafe;
  final bool phase33ZSelectedDiagnosticPathSafe;
  final bool defaultSelectedOutputDeterministic;
  final bool allSafeSelectedOutputDeterministic;
  final bool singleSelectedCaseOutputDeterministic;
  final bool listGoldenCasesOutputDeterministic;
  final bool goldenSectionOutputDeterministic;
  final bool markdownJsonStrictModesSafe;
  final List<
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
  >
  defaultSelectedRows;
  final List<
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
  >
  allSafeSelectedRows;
  final List<
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
  >
  singleSelectedRows;
  final List<String> listedGoldenCaseIds;
  final List<String> reportTexts;
  final String phase34BRecommendation;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheck {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheck({
    required this.checkId,
    required this.status,
    this.findings = const <String>[],
  });

  final DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
  checkId;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckStatus
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

class DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationRow {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationRow({
    required this.validationRowId,
    required this.sourceCaseId,
    required this.title,
    required this.sourcePhase,
    required this.selectedReason,
    required this.diagnosticRole,
    required this.supportAreaIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.androidProofIds,
    required this.ownerProofRequired,
    required this.activeDeniedFieldIds,
    required this.blockedBoundaryIds,
    required this.validationStatus,
    required this.findings,
    required this.recommendation,
  });

  final String validationRowId;
  final String sourceCaseId;
  final String title;
  final String sourcePhase;
  final String selectedReason;
  final String diagnosticRole;
  final List<String> supportAreaIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofIds;
  final bool ownerProofRequired;
  final List<String> activeDeniedFieldIds;
  final List<String> blockedBoundaryIds;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationRowStatus
  validationStatus;
  final List<String> findings;
  final String recommendation;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'validationRowId': validationRowId,
      'sourceCaseId': sourceCaseId,
      'title': title,
      'sourcePhase': sourcePhase,
      'selectedReason': selectedReason,
      'diagnosticRole': diagnosticRole,
      'supportAreaIds': supportAreaIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'androidProofIds': androidProofIds,
      'ownerProofRequired': ownerProofRequired,
      'activeDeniedFieldIds': activeDeniedFieldIds,
      'blockedBoundaryIds': blockedBoundaryIds,
      'validationStatus': validationStatus.wire,
      'findings': findings,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationResult {
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationResult({
    required this.status,
    required this.checks,
    required this.validationRows,
    required this.reportFindings,
    required this.safeForPhase34B,
    required this.nextRecommendation,
  }) : totalChecks = checks.length,
       passedCheckCount = checks.where((check) => check.status.isPassed).length,
       warningCheckCount = checks
           .where((check) => check.status.isWarning)
           .length,
       blockerCount =
           checks
               .where(
                 (check) =>
                     check.status ==
                     DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckStatus
                         .blocked,
               )
               .length +
           reportFindings.length,
       criticalCount = reportFindings
           .where((finding) => finding.startsWith('reportTextLeak:'))
           .length,
       totalValidationRows = validationRows.length,
       invalidRowCount = validationRows
           .where(
             (row) =>
                 row.validationStatus ==
                 DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationRowStatus
                     .invalidRow,
           )
           .length,
       unsafeRowCount = validationRows
           .where(
             (row) =>
                 row.validationStatus ==
                 DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationRowStatus
                     .unsafeRow,
           )
           .length,
       activeDeniedFieldCount = validationRows.fold<int>(
         0,
         (total, row) => total + row.activeDeniedFieldIds.length,
       ),
       productOutputCount = _countActiveFields(validationRows, _productFields),
       labelLeakCount = _countActiveFields(validationRows, _labelFields),
       finalLabelLeakCount = _countActiveFields(
         validationRows,
         _finalLabelFields,
       ),
       scoreLeakCount = _countActiveFields(validationRows, _scoreFields),
       metricLeakCount = _countActiveFields(validationRows, _metricFields),
       cpLossLeakCount = _countActiveFields(validationRows, const {'cpLoss'}),
       winProbabilityLeakCount = _countActiveFields(validationRows, const {
         'winProbability',
       }),
       moveRankingLeakCount = _countActiveFields(validationRows, const {
         'moveRanking',
       }),
       thresholdLeakCount = _countActiveFields(validationRows, const {
         'thresholds',
       }),
       uiTargetCount = _countActiveFields(validationRows, const {'uiTarget'}),
       backendTargetCount = _countActiveFields(validationRows, const {
         'backendTarget',
       }),
       persistenceWriteCount = _countActiveFields(validationRows, const {
         'persistenceWrite',
       }),
       engineCallCount = _countActiveFields(validationRows, const {
         'directEngineCall',
         'engineResults',
       }),
       schedulerExecutionCount = _countActiveFields(validationRows, const {
         'schedulerExecution',
       }),
       analyzerWiringCount = _countActiveFields(validationRows, const {
         'analyzerWiring',
       }),
       runtimeImplementationCount = _countActiveFields(validationRows, const {
         'runtimeImplementation',
       }),
       executablePrototypeCount = _countActiveFields(validationRows, const {
         'executablePrototypeBehavior',
       }),
       productAdapterBehaviorCount = _countActiveFields(validationRows, const {
         'productAdapterBehavior',
       }),
       savedAnalysisIntegrationCount = _countActiveFields(
         validationRows,
         const {'savedAnalysisIntegration'},
       ),
       stockfishCommandLeakCount = _countActiveFields(validationRows, const {
         'stockfishCommand',
       }),
       rawUciLeakCount = _countActiveFields(validationRows, const {'rawUci'}),
       pvDumpLeakCount = _countActiveFields(validationRows, const {'pvDump'}),
       androidCollectorRequirementCount = _countActiveFields(
         validationRows,
         const {'androidCollectorRequirement', 'androidCollectorExecution'},
       ),
       phase32EProofClaimCount = validationRows
           .where((row) => row.androidProofIds.any(_phase32ECaseIds.contains))
           .length,
       unprovenAndroidProofCount = validationRows
           .where(
             (row) => row.androidProofIds.any(
               (caseId) => !_capturedAndroidProofIds.contains(caseId),
             ),
           )
           .length,
       ownerProofQueueCount = validationRows
           .where((row) => row.ownerProofRequired)
           .length,
       developerSupportRowCount = validationRows
           .where((row) => row.diagnosticRole == _developerSupportRole)
           .length,
       warningLimitedRowCount = validationRows
           .where((row) => row.diagnosticRole == _warningLimitedRole)
           .length,
       proofBoundaryOnlyRowCount = validationRows
           .where((row) => row.diagnosticRole == _proofBoundaryOnlyRole)
           .length,
       excludedNegativeGuardRowCount = validationRows
           .where((row) => row.diagnosticRole == _excludedNegativeGuardRole)
           .length;

  final DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationStatus
  status;
  final List<
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheck
  >
  checks;
  final List<
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationRow
  >
  validationRows;
  final List<String> reportFindings;
  final bool safeForPhase34B;
  final String nextRecommendation;
  final int totalChecks;
  final int passedCheckCount;
  final int warningCheckCount;
  final int blockerCount;
  final int criticalCount;
  final int totalValidationRows;
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
  final int phase32EProofClaimCount;
  final int unprovenAndroidProofCount;
  final int ownerProofQueueCount;
  final int developerSupportRowCount;
  final int warningLimitedRowCount;
  final int proofBoundaryOnlyRowCount;
  final int excludedNegativeGuardRowCount;
  int get unsafeCount => unsafeRowCount + (safeForPhase34B ? 0 : 1);

  bool get hasUnsafePolicyViolation =>
      !safeForPhase34B ||
      nextRecommendation != _phase34BRecommendation ||
      blockerCount > 0 ||
      criticalCount > 0 ||
      unsafeCount > 0 ||
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
      ..writeln(
        '# Selected Golden Analyzer Adapter Prototype Diagnostic Validation',
      )
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationVersion',
      )
      ..writeln('- validation status: ${status.wire}')
      ..writeln('- safe for Phase 34B: $safeForPhase34B')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- product output count: $productOutputCount')
      ..writeln('- analyzer wiring count: $analyzerWiringCount')
      ..writeln('- runtime implementation count: $runtimeImplementationCount')
      ..writeln('- executable prototype count: $executablePrototypeCount')
      ..writeln('- engine call count: $engineCallCount')
      ..writeln('- scheduler execution count: $schedulerExecutionCount')
      ..writeln()
      ..writeln('## Validation Check Table')
      ..writeln('| Check | Status | Findings |')
      ..writeln('| --- | --- | --- |');
    for (final check in checks) {
      buffer.writeln(
        '| ${check.checkId.wire} | ${check.status.wire} | ${_ids(check.findings)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Selected Row Validation Table')
      ..writeln(
        '| Row | Case ID | Source phase | Role | Status | Support areas | Warnings | Proof limits | Android proof IDs | Owner proof | Active denied fields | Blocked boundaries | Findings | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in validationRows) {
      buffer.writeln(
        '| ${row.validationRowId} | ${row.sourceCaseId} | ${row.sourcePhase} | ${row.diagnosticRole} | ${row.validationStatus.wire} | ${_ids(row.supportAreaIds)} | ${_ids(row.warningReasons)} | ${_ids(row.proofLimitReasons)} | ${_ids(row.androidProofIds)} | ${row.ownerProofRequired} | ${_ids(row.activeDeniedFieldIds)} | ${_ids(row.blockedBoundaryIds)} | ${_ids(row.findings)} | ${row.recommendation} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Selected Set Validation')
      ..writeln('- developer support row count: $developerSupportRowCount')
      ..writeln('- warning-limited row count: $warningLimitedRowCount')
      ..writeln('- proof-boundary-only row count: $proofBoundaryOnlyRowCount')
      ..writeln(
        '- excluded negative guard row count: $excludedNegativeGuardRowCount',
      )
      ..writeln()
      ..writeln('## Proof And Owner Boundary Validation')
      ..writeln('- Phase 32E proof claim count: $phase32EProofClaimCount')
      ..writeln('- unproven Android proof count: $unprovenAndroidProofCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Denied Field Validation')
      ..writeln('- label leak count: $labelLeakCount')
      ..writeln('- final label leak count: $finalLabelLeakCount')
      ..writeln('- score leak count: $scoreLeakCount')
      ..writeln('- metric leak count: $metricLeakCount')
      ..writeln('- CP-loss leak count: $cpLossLeakCount')
      ..writeln('- win probability leak count: $winProbabilityLeakCount')
      ..writeln('- move ranking leak count: $moveRankingLeakCount')
      ..writeln('- threshold leak count: $thresholdLeakCount')
      ..writeln('- Stockfish command leak count: $stockfishCommandLeakCount')
      ..writeln('- raw UCI leak count: $rawUciLeakCount')
      ..writeln('- PV dump leak count: $pvDumpLeakCount')
      ..writeln()
      ..writeln('## Runtime And Integration Boundary Validation')
      ..writeln('- UI target count: $uiTargetCount')
      ..writeln('- backend target count: $backendTargetCount')
      ..writeln('- persistence write count: $persistenceWriteCount')
      ..writeln('- engine call count: $engineCallCount')
      ..writeln('- scheduler execution count: $schedulerExecutionCount')
      ..writeln(
        '- product adapter behavior count: $productAdapterBehaviorCount',
      )
      ..writeln(
        '- saved analysis integration count: $savedAnalysisIntegrationCount',
      );
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent(' ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationVersion,
      'validationStatus': status.wire,
      'safeForPhase34B': safeForPhase34B,
      'nextRecommendation': nextRecommendation,
      'counts': <String, Object?>{
        'totalChecks': totalChecks,
        'passedCheckCount': passedCheckCount,
        'warningCheckCount': warningCheckCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'unsafeCount': unsafeCount,
        'totalValidationRows': totalValidationRows,
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
        'phase32EProofClaimCount': phase32EProofClaimCount,
        'unprovenAndroidProofCount': unprovenAndroidProofCount,
        'ownerProofQueueCount': ownerProofQueueCount,
        'developerSupportRowCount': developerSupportRowCount,
        'warningLimitedRowCount': warningLimitedRowCount,
        'proofBoundaryOnlyRowCount': proofBoundaryOnlyRowCount,
        'excludedNegativeGuardRowCount': excludedNegativeGuardRowCount,
      },
      'checks': checks.map((check) => check.toJson()).toList(growable: false),
      'validationRows': validationRows
          .map((row) => row.toJson())
          .toList(growable: false),
      'reportFindings': reportFindings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidation {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidation();

  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationResult
  evaluate({
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSource?
    source,
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  }) {
    final validationSource =
        source ??
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSource.safeDemo(
          cases: cases,
        );
    final knownCaseIds = cases.map((item) => item.id).toSet();
    final rows =
        <
          DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationRow
        >[
          ...validationSource.allSafeSelectedRows.asMap().entries.map(
            (entry) =>
                const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationValidator()
                    .validateRow(
                      entry.value,
                      rowPrefix: 'selected-golden-validation-row',
                      rowIndex: entry.key,
                      knownCaseIds: knownCaseIds,
                    ),
          ),
        ];
    final reportFindings =
        const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationValidator()
            .validateReportTexts(validationSource.reportTexts);

    final duplicateDefaultIds = _duplicates(
      validationSource.defaultSelectedRows.map((row) => row.caseId),
    );
    final defaultIds = validationSource.defaultSelectedRows
        .map((row) => row.caseId)
        .toSet();
    final missingDefaultIds = _defaultSelectedGoldenCaseIds
        .where((id) => !defaultIds.contains(id))
        .toList();

    final checks =
        <
          DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheck
        >[
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
                .phase33YDiagnosticPathIsSafe,
            validationSource.phase33YDiagnosticPathSafe,
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
                .phase33ZSelectedDiagnosticPathIsSafe,
            validationSource.phase33ZSelectedDiagnosticPathSafe,
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
                .defaultSelectedOutputDeterministic,
            validationSource.defaultSelectedOutputDeterministic,
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
                .allSafeSelectedOutputDeterministic,
            validationSource.allSafeSelectedOutputDeterministic,
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
                .singleSelectedCaseOutputDeterministic,
            validationSource.singleSelectedCaseOutputDeterministic,
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
                .listGoldenCasesOutputDeterministic,
            validationSource.listGoldenCasesOutputDeterministic,
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
                .goldenSectionOutputDeterministic,
            validationSource.goldenSectionOutputDeterministic,
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
                .markdownJsonStrictModesAreSafe,
            validationSource.markdownJsonStrictModesSafe,
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
                .selectedRowsPreserveRequiredShape,
            rows.every((row) => row.findings.isEmpty) &&
                duplicateDefaultIds.isEmpty &&
                missingDefaultIds.isEmpty,
            findings: <String>[
              ...duplicateDefaultIds.map((id) => 'duplicateDefaultCase:$id'),
              ...missingDefaultIds.map((id) => 'missingDefaultCase:$id'),
            ],
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
                .developerSupportRowsRemainDiagnosticOnly,
            rows
                .where((row) => row.diagnosticRole == _developerSupportRole)
                .every((row) => row.activeDeniedFieldIds.isEmpty),
            warning: true,
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
                .phase32ERowsRemainWarningLimited,
            rows
                .where((row) => _phase32ECaseIds.contains(row.sourceCaseId))
                .every(
                  (row) =>
                      row.diagnosticRole == _warningLimitedRole ||
                      row.diagnosticRole == _proofBoundaryOnlyRole,
                ),
            warning: true,
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
                .pvMultiPvRemainsProofBoundaryOnly,
            rows
                .where((row) => row.sourceCaseId == _pvMultiPvBoundaryCaseId)
                .every((row) => row.diagnosticRole == _proofBoundaryOnlyRole),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
                .quietPreparatoryRemainsExcludedGuardOnly,
            rows
                .where(
                  (row) =>
                      row.supportAreaIds.contains('quietMove') ||
                      row.supportAreaIds.contains('quietPreparatoryMove'),
                )
                .every(
                  (row) => row.diagnosticRole == _excludedNegativeGuardRole,
                ),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
                .phase32ECasesDoNotClaimCapturedAndroidProof,
            rows.every(
              (row) => !row.androidProofIds.any(_phase32ECaseIds.contains),
            ),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
                .androidProofIdsRemainCapturedOnly,
            rows.every(
              (row) =>
                  row.androidProofIds.every(_capturedAndroidProofIds.contains),
            ),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
                .ownerProofQueueRemainsEmpty,
            rows.every((row) => !row.ownerProofRequired),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
                .deniedFieldsRemainInactive,
            rows.every((row) => row.activeDeniedFieldIds.isEmpty),
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
                .reportTextRemainsSafe,
            reportFindings.isEmpty,
            findings: reportFindings,
          ),
          _check(
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
                .phase34BRequirementPresent,
            validationSource.phase34BRecommendation == _phase34BRecommendation,
          ),
        ];

    final rowUnsafe = rows.any(
      (row) =>
          row.validationStatus ==
              DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationRowStatus
                  .unsafeRow ||
          row.validationStatus ==
              DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationRowStatus
                  .invalidRow,
    );
    final blocked = checks.any(
      (check) =>
          check.status ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckStatus
              .blocked,
    );
    final safeForPhase34B =
        !blocked &&
        !rowUnsafe &&
        reportFindings.isEmpty &&
        validationSource.phase34BRecommendation == _phase34BRecommendation;
    final status = !safeForPhase34B
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationStatus
              .blockedByUnsafeSelectedGoldenDiagnostic
        : checks.any((check) => check.status.isWarning) ||
              rows.any(
                (row) =>
                    row.validationStatus ==
                    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationRowStatus
                        .validWithWarnings,
              )
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationStatus
              .selectedGoldenAnalyzerAdapterPrototypeDiagnosticValidatedWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationStatus
              .selectedGoldenAnalyzerAdapterPrototypeDiagnosticValidatedClean;

    return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationResult(
      status: status,
      checks: checks,
      validationRows: rows,
      reportFindings: reportFindings,
      safeForPhase34B: safeForPhase34B,
      nextRecommendation: safeForPhase34B
          ? _phase34BRecommendation
          : 'blockedByUnsafeSelectedGoldenAnalyzerAdapterPrototypeDiagnosticValidation',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationValidator {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationValidator();

  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationRow
  validateRow(
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
    row, {
    required String rowPrefix,
    required int rowIndex,
    required Set<String> knownCaseIds,
  }) {
    final findings = <String>[
      if (!knownCaseIds.contains(row.caseId)) 'unknownGoldenCaseId',
      if (!_allowedRoles.contains(row.diagnosticRole))
        'unknownSelectedDiagnosticRole',
      if (row.activeDeniedFieldIds.isNotEmpty) 'activeDeniedFields',
      if (_isQuietRow(row) && row.diagnosticRole != _excludedNegativeGuardRole)
        'quietPreparatoryPromotion',
      if (row.caseId == _pvMultiPvBoundaryCaseId &&
          row.diagnosticRole != _proofBoundaryOnlyRole)
        'pvMultiPvPromotion',
      if (row.androidProofIds.any(_phase32ECaseIds.contains))
        'phase32ECapturedProofClaim',
      if (row.androidProofIds.any(
        (id) => !_capturedAndroidProofIds.contains(id),
      ))
        'unprovenAndroidProofId',
      if (row.ownerProofRequired &&
          !row.proofLimitReasons.any((reason) => reason.contains('pvMultiPv')))
        'ownerProofWithoutPvMultiPvReason',
      if (_hasActiveField(row, _productFields)) 'productLabelOutput',
      if (_hasActiveField(row, _finalLabelFields)) 'finalLabelOutput',
      if (_hasActiveField(row, _labelFields)) 'classifierLabelOutput',
      if (_hasActiveField(row, _scoreFields)) 'scoreOutput',
      if (_hasActiveField(row, _metricFields)) 'metricOutput',
      if (_hasActiveField(row, const {'cpLoss'})) 'cpLossOutput',
      if (_hasActiveField(row, const {'winProbability'}))
        'winProbabilityOutput',
      if (_hasActiveField(row, const {'moveRanking'})) 'moveRankingOutput',
      if (_hasActiveField(row, const {'thresholds'})) 'thresholdOutput',
      if (_hasActiveField(row, const {'uiTarget'})) 'uiTargetOutput',
      if (_hasActiveField(row, const {'backendTarget'})) 'backendTargetOutput',
      if (_hasActiveField(row, const {'persistenceWrite'}))
        'persistenceWriteOutput',
      if (_hasActiveField(row, const {'directEngineCall', 'engineResults'}))
        'directEngineOutput',
      if (_hasActiveField(row, const {'schedulerExecution'}))
        'schedulerExecutionOutput',
      if (_hasActiveField(row, const {'analyzerWiring'}))
        'analyzerWiringOutput',
      if (_hasActiveField(row, const {'runtimeImplementation'}))
        'runtimeImplementationOutput',
      if (_hasActiveField(row, const {'executablePrototypeBehavior'}))
        'executablePrototypeOutput',
      if (_hasActiveField(row, const {'productAdapterBehavior'}))
        'productAdapterOutput',
      if (_hasActiveField(row, const {'savedAnalysisIntegration'}))
        'savedAnalysisOutput',
      if (_hasActiveField(row, const {'stockfishCommand'}))
        'stockfishCommandOutput',
      if (_hasActiveField(row, const {'rawUci'})) 'rawUciOutput',
      if (_hasActiveField(row, const {'pvDump'})) 'pvDumpOutput',
      if (_hasActiveField(row, const {
        'androidCollectorRequirement',
        'androidCollectorExecution',
      }))
        'androidCollectorRequirement',
      if (_hasActiveField(row, const {'readinessSummaryChain'}))
        'readinessSummaryChainOutput',
      if (_hasActiveField(row, const {'readinessGate'})) 'readinessGateOutput',
    ];
    final status = findings.isNotEmpty
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationRowStatus
              .unsafeRow
        : row.warningReasons.isNotEmpty || row.proofLimitReasons.isNotEmpty
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationRowStatus
              .validWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationRowStatus
              .valid;
    return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationRow(
      validationRowId: '$rowPrefix-${rowIndex + 1}',
      sourceCaseId: row.caseId,
      title: row.title,
      sourcePhase: row.sourcePhase,
      selectedReason: row.selectedReason,
      diagnosticRole: row.diagnosticRole,
      supportAreaIds: _sorted(row.supportAreaIds),
      warningReasons: _sorted(row.warningReasons),
      proofLimitReasons: _sorted(row.proofLimitReasons),
      androidProofIds: _sorted(row.androidProofIds),
      ownerProofRequired: row.ownerProofRequired,
      activeDeniedFieldIds: _sorted(row.activeDeniedFieldIds),
      blockedBoundaryIds: _sorted(row.blockedBoundaryIds),
      validationStatus: status,
      findings: _sorted(findings),
      recommendation: row.recommendation,
    );
  }

  List<String> validateReportTexts(Iterable<String> reportTexts) {
    final findings = <String>[];
    for (final text in reportTexts) {
      final lower = text.toLowerCase();
      for (final token in _rawReportLeakTokens) {
        if (lower.contains(token.toLowerCase())) {
          findings.add('reportTextLeak:$token');
        }
      }
    }
    return _sorted(findings);
  }
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheck
_check(
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckId
  checkId,
  bool condition, {
  bool warning = false,
  List<String> findings = const <String>[],
}) {
  if (!condition) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheck(
      checkId: checkId,
      status:
          DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckStatus
              .blocked,
      findings: findings.isEmpty ? const <String>['checkFailed'] : findings,
    );
  }
  return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheck(
    checkId: checkId,
    status: warning
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckStatus
              .passedWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationCheckStatus
              .passed,
    findings: warning ? const <String>['warningLimitedDiagnostic'] : findings,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
_sourceRowForCase(GoldenAnalysisCase item) {
  final role = _roleForCase(item);
  final androidProofIds =
      _capturedAndroidProofIds.contains(item.id) &&
          !_phase32ECaseIds.contains(item.id)
      ? <String>[item.id]
      : const <String>[];
  return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow(
    caseId: item.id,
    title: item.title,
    sourcePhase: _sourcePhaseForCase(item),
    selectedReason:
        _selectedReasonByCaseId[item.id] ??
        'developer-only selected Golden analyzer adapter prototype diagnostic coverage',
    diagnosticRole: role,
    supportAreaIds: <String>{
      item.category.wire,
      item.sourceType.wire,
      item.evidenceIntent.wire,
      ...item.motifTags.map((tag) => tag.wire),
      if (_phase32ECaseIds.contains(item.id)) 'phase32E',
      if (item.id == _pvMultiPvBoundaryCaseId) 'pvMultiPvBoundary',
      if (_capturedAndroidProofIds.contains(item.id)) 'capturedAndroidProof',
    }.toList()..sort(),
    warningReasons: <String>[
      'developerOnlySelectedGoldenAnalyzerAdapterPrototypeDiagnosticNoEngineExecution',
      if (role == _warningLimitedRole) 'diagnosticCoverageIsWarningLimited',
      if (role == _proofBoundaryOnlyRole)
        'proofBoundaryOnlyNoCapturedAndroidProofClaim',
      if (role == _excludedNegativeGuardRole)
        'negativeGuardOnlyNotDiagnosticInputSupport',
    ],
    proofLimitReasons: <String>[
      if (_phase32ECaseIds.contains(item.id)) 'phase32ECaseIsNotCapturedProof',
      if (item.id == _pvMultiPvBoundaryCaseId)
        'pvMultiPvBoundaryWatchListOnlyNoOwnerProof',
      if (role == _excludedNegativeGuardRole)
        'quietPreparatoryExcludedFromActiveDiagnosticInput',
    ],
    androidProofIds: androidProofIds,
    ownerProofRequired: false,
    activeDeniedFieldIds: const <String>[],
    blockedBoundaryIds: <String>{
      ..._alwaysBlockedBoundaryIds,
      if (_phase32ECaseIds.contains(item.id))
        'phase32ECapturedAndroidProofClaim',
      if (item.id == _pvMultiPvBoundaryCaseId) 'pvMultiPvOwnerProofEscalation',
      if (role == _excludedNegativeGuardRole)
        'quietPreparatoryDiagnosticInputPromotion',
    }.toList()..sort(),
    recommendation: _phase34BRecommendation,
  );
}

String _roleForCase(GoldenAnalysisCase item) {
  if (_isQuietCase(item)) return _excludedNegativeGuardRole;
  if (item.id == _pvMultiPvBoundaryCaseId) return _proofBoundaryOnlyRole;
  if (_phase32ECaseIds.contains(item.id) ||
      item.category == GoldenAnalysisCategory.budgetPressure) {
    return _warningLimitedRole;
  }
  if (item.category == GoldenAnalysisCategory.endgamePrecision ||
      item.category == GoldenAnalysisCategory.openingKnownSkip ||
      item.category == GoldenAnalysisCategory.forcedMoveSkip) {
    return _contextOnlyRole;
  }
  return _developerSupportRole;
}

String _sourcePhaseForCase(GoldenAnalysisCase item) {
  if (_phase32ECaseIds.contains(item.id) ||
      item.notes.any((note) => note.contains('Phase 32E'))) {
    return 'Phase 32E';
  }
  if (item.notes.any((note) => note.contains('Phase 30W'))) {
    return 'Phase 30W';
  }
  return 'existing';
}

bool _isQuietCase(GoldenAnalysisCase item) {
  return item.category == GoldenAnalysisCategory.quietPreparatoryMove ||
      item.motifTags.any(
        (tag) =>
            tag == GoldenMotifTag.quietMove ||
            tag == GoldenMotifTag.quietPreparatoryMove,
      );
}

bool _isQuietRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
  row,
) {
  return row.supportAreaIds.contains('quietMove') ||
      row.supportAreaIds.contains('quietPreparatoryMove');
}

bool _hasActiveField(
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
  row,
  Set<String> fields,
) {
  return row.activeDeniedFieldIds.any(fields.contains);
}

int _countActiveFields(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationRow
  >
  rows,
  Set<String> fields,
) {
  var count = 0;
  for (final row in rows) {
    count += row.activeDeniedFieldIds.where(fields.contains).length;
  }
  return count;
}

List<String> _duplicates(Iterable<String> values) {
  final seen = <String>{};
  final duplicate = <String>{};
  for (final value in values) {
    if (!seen.add(value)) duplicate.add(value);
  }
  return duplicate.toList()..sort();
}

String _ids(Iterable<String> values) {
  final sorted = _sorted(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

List<String> _sorted(Iterable<String> values) {
  return values.where((value) => value.trim().isNotEmpty).toSet().toList()
    ..sort();
}

const _phase34BRecommendation =
    'proceedToAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan';
const _developerSupportRole = 'developerDiagnosticInputSupport';
const _contextOnlyRole = 'contextOnly';
const _warningLimitedRole = 'warningLimited';
const _proofBoundaryOnlyRole = 'proofBoundaryOnly';
const _excludedNegativeGuardRole = 'excludedNegativeGuard';
const _pvMultiPvBoundaryCaseId = 'pv-multipv-support-boundary-32e';

const _allowedRoles = <String>{
  _developerSupportRole,
  _contextOnlyRole,
  _warningLimitedRole,
  _proofBoundaryOnlyRole,
  _excludedNegativeGuardRole,
};

const _defaultSelectedGoldenCaseIds = <String>[
  'queen-win-major-swing',
  'forcing-line-variation-hard-case',
  'sacrifice-compensation-hard-case',
  'king-safety-mating-net-pressure-32e',
  'endgame-precision-candidate-spread-32e',
  'budget-pressure-wide-candidate-32e',
  _pvMultiPvBoundaryCaseId,
  'quiet-preparatory-hard-case',
];

const _allSafeSelectedGoldenCaseIds = <String>[
  ..._defaultSelectedGoldenCaseIds,
  'simple-tactical-capture-check',
  'mate-threat-fast-evidence',
  'material-sacrifice-compensation',
  'king-safety-mating-net-hard-case',
  'technical-endgame-conservative',
  'budget-pressure-candidates',
  'quiet-preparatory-uncertain',
  'suppression-forced-only-legal-32e',
];

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

const _alwaysBlockedBoundaryIds = <String>{
  'androidCollectorExecution',
  'analyzerWiring',
  'backendTarget',
  'classifierLabels',
  'cpLoss',
  'directEngineCall',
  'engineResults',
  'executablePrototypeBehavior',
  'finalMoveLabels',
  'moveRanking',
  'numericMoveScores',
  'officialMetrics',
  'persistenceWrite',
  'productAdapterBehavior',
  'productOutput',
  'pvDump',
  'rawUci',
  'runtimeImplementation',
  'savedAnalysisIntegration',
  'schedulerExecution',
  'stockfishCommand',
  'thresholds',
  'uiTarget',
  'winProbability',
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

const _selectedReasonByCaseId = <String, String>{
  'queen-win-major-swing':
      'tactical/material swing case inspected as safe developer diagnostic support',
  'forcing-line-variation-hard-case':
      'forcing-line case inspected as safe developer diagnostic support',
  'sacrifice-compensation-hard-case':
      'candidate-spread material case inspected as safe developer diagnostic support',
  'king-safety-mating-net-pressure-32e':
      'Phase 32E king-safety and mating-net case kept warning-limited without captured proof claim',
  'endgame-precision-candidate-spread-32e':
      'Phase 32E endgame candidate-spread case kept warning-limited',
  'budget-pressure-wide-candidate-32e':
      'Phase 32E budget-pressure case kept warning-limited',
  _pvMultiPvBoundaryCaseId:
      'Phase 32E PV/MultiPV case kept proof-boundary and watch-list only',
  'quiet-preparatory-hard-case':
      'quiet/preparatory negative guard inspected only as excluded guard',
  'simple-tactical-capture-check':
      'tactical capture/check case inspected with captured Android proof boundary preserved',
  'mate-threat-fast-evidence':
      'mate-threat fast-evidence case inspected with captured Android proof boundary preserved',
  'material-sacrifice-compensation':
      'material compensation case inspected as safe developer diagnostic support',
  'king-safety-mating-net-hard-case':
      'king-safety hard case inspected as safe developer diagnostic support',
  'technical-endgame-conservative':
      'technical endgame case kept context-only for conservative inspection',
  'budget-pressure-candidates': 'budget-pressure case kept warning-limited',
  'quiet-preparatory-uncertain':
      'quiet/preparatory uncertain negative guard inspected only as excluded guard',
  'suppression-forced-only-legal-32e':
      'Phase 32E forced-only suppression case kept warning-limited',
};

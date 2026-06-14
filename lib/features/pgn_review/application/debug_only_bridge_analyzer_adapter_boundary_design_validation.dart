import 'dart:convert';

import 'debug_only_bridge_analyzer_adapter_boundary_design.dart';
import 'golden_analysis_suite.dart';
import 'golden_android_proof_evidence.dart';

const debugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationReportVersion =
    'debug-only-bridge-analyzer-adapter-boundary-design-validation-v1';

enum DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationStatus {
  boundaryDesignValidatedWithWarnings('boundaryDesignValidatedWithWarnings'),
  boundaryDesignValidatedClean('boundaryDesignValidatedClean'),
  blockedByUnsafeBoundaryDesign('blockedByUnsafeBoundaryDesign'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidBoundaryValidation('invalidBoundaryValidation');

  const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationStatus(this.wire);

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId {
  consumesSafeSelectedGoldenValidation('consumesSafeSelectedGoldenValidation'),
  boundaryComponentsAreDeterministic('boundaryComponentsAreDeterministic'),
  boundaryRecordsAreDeterministic('boundaryRecordsAreDeterministic'),
  analyzerInputCandidatesRemainFutureInternalOnly(
    'analyzerInputCandidatesRemainFutureInternalOnly',
  ),
  coreSupportCandidatesDoNotBecomeProductOutput(
    'coreSupportCandidatesDoNotBecomeProductOutput',
  ),
  contextOnlyCandidatesRemainContextOnly(
    'contextOnlyCandidatesRemainContextOnly',
  ),
  warningLimitedCandidatesRemainWarningLimited(
    'warningLimitedCandidatesRemainWarningLimited',
  ),
  proofBoundaryOnlyRowsRemainProofBoundaryOnly(
    'proofBoundaryOnlyRowsRemainProofBoundaryOnly',
  ),
  quietPreparatoryRemainsExcludedNegativeGuard(
    'quietPreparatoryRemainsExcludedNegativeGuard',
  ),
  phase32ECasesDoNotClaimCapturedAndroidProof(
    'phase32ECasesDoNotClaimCapturedAndroidProof',
  ),
  androidProofIdsRemainCapturedOnly('androidProofIdsRemainCapturedOnly'),
  ownerProofQueueRemainsEmpty('ownerProofQueueRemainsEmpty'),
  deniedFieldsRemainInactive('deniedFieldsRemainInactive'),
  analyzerWiringRemainsBlocked('analyzerWiringRemainsBlocked'),
  runtimePrototypeWiringRemainBlocked('runtimePrototypeWiringRemainBlocked'),
  schedulerPersistenceEngineRemainBlocked(
    'schedulerPersistenceEngineRemainBlocked',
  ),
  noLabelsScoresRankingsMetrics('noLabelsScoresRankingsMetrics'),
  noCpLossOrWinProbability('noCpLossOrWinProbability'),
  noStockfishCommandRawUciPvDump('noStockfishCommandRawUciPvDump'),
  reportContainsNoRawUciOrPvDump('reportContainsNoRawUciOrPvDump'),
  phase33ORequirementPresent('phase33ORequirementPresent');

  const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckStatus {
  passed('passed'),
  passedWithWarnings('passedWithWarnings'),
  blocked('blocked');

  const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckStatus(
    this.wire,
  );

  final String wire;

  bool get isPassed => this == passed || this == passedWithWarnings;
  bool get isWarning => this == passedWithWarnings;
}

enum DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationRowStatus {
  valid('valid'),
  validWithWarnings('validWithWarnings'),
  unsafeRow('unsafeRow'),
  invalid('invalid');

  const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationRowStatus(
    this.wire,
  );

  final String wire;

  bool get isUnsafe => this == unsafeRow;
  bool get isInvalid => this == invalid;
}

class DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheck {
  const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheck({
    required this.checkId,
    required this.status,
    this.findings = const <String>[],
  });

  final DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId checkId;
  final DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckStatus
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

class DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationRow {
  const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationRow({
    required this.validationRowId,
    required this.sourceBoundaryRecordId,
    required this.sourceDiagnosticCaseId,
    required this.sourcePhase,
    required this.diagnosticRole,
    required this.adapterBoundaryRole,
    required this.status,
    required this.designOnly,
    required this.developerOnly,
    required this.analyzerUnwired,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.blockedBoundaryIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.androidProofCaseIds,
    required this.ownerProofRequired,
    required this.activeDeniedFields,
    required this.findings,
    required this.recommendation,
  });

  final String validationRowId;
  final String sourceBoundaryRecordId;
  final String sourceDiagnosticCaseId;
  final String sourcePhase;
  final String diagnosticRole;
  final String adapterBoundaryRole;
  final DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationRowStatus status;
  final bool designOnly;
  final bool developerOnly;
  final bool analyzerUnwired;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final List<String> blockedBoundaryIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofCaseIds;
  final bool ownerProofRequired;
  final List<String> activeDeniedFields;
  final List<String> findings;
  final String recommendation;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'validationRowId': validationRowId,
      'sourceBoundaryRecordId': sourceBoundaryRecordId,
      'sourceDiagnosticCaseId': sourceDiagnosticCaseId,
      'sourcePhase': sourcePhase,
      'diagnosticRole': diagnosticRole,
      'adapterBoundaryRole': adapterBoundaryRole,
      'status': status.wire,
      'designOnly': designOnly,
      'developerOnly': developerOnly,
      'analyzerUnwired': analyzerUnwired,
      'allowedFieldIds': allowedFieldIds,
      'deniedFieldIds': deniedFieldIds,
      'blockedBoundaryIds': blockedBoundaryIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'androidProofCaseIds': androidProofCaseIds,
      'ownerProofRequired': ownerProofRequired,
      'activeDeniedFields': activeDeniedFields,
      'findings': findings,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationResult {
  DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationResult({
    required this.status,
    required this.sourceBoundaryDesignStatus,
    required this.sourceBoundaryDesignSafeForPhase33N,
    required this.sourceBoundaryDesignRecommendation,
    required this.sourceSelectedGoldenValidationStatus,
    required this.checks,
    required this.validationRows,
    required this.reportFindings,
    required this.safeForPhase33O,
    required this.phase33ORecommendation,
  }) : totalChecks = checks.length,
       passedCheckCount = checks.where((check) => check.status.isPassed).length,
       warningCheckCount = checks
           .where((check) => check.status.isWarning)
           .length,
       blockerCount = checks
           .where(
             (check) =>
                 check.status ==
                 DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckStatus
                     .blocked,
           )
           .length,
       criticalCount = reportFindings.where(_isCriticalFinding).length,
       totalValidationRows = validationRows.length,
       analyzerInputCandidateValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.analyzerInputCandidate.wire,
       ),
       coreSupportCandidateValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.coreSupportCandidate.wire,
       ),
       contextOnlyCandidateValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.contextOnlyCandidate.wire,
       ),
       warningLimitedCandidateValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole
             .warningLimitedCandidate
             .wire,
       ),
       proofBoundaryOnlyValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.proofBoundaryOnly.wire,
       ),
       excludedNegativeGuardValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.excludedNegativeGuard.wire,
       ),
       deniedFieldBoundaryValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.deniedFieldBoundary.wire,
       ),
       runtimeBlockedValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.runtimeBlocked.wire,
       ),
       schedulerBlockedValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.schedulerBlocked.wire,
       ),
       persistenceBlockedValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.persistenceBlocked.wire,
       ),
       engineBlockedValidationCount = _countRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.engineBlocked.wire,
       ),
       invalidRowCount = validationRows
           .where((row) => row.status.isInvalid)
           .length,
       unsafeRowCount = validationRows
           .where((row) => row.status.isUnsafe)
           .length,
       activeDeniedFieldCount = validationRows.fold<int>(
         0,
         (total, row) => total + row.activeDeniedFields.length,
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
       stockfishCommandLeakCount = _countFinding(
         validationRows,
         'stockfishCommandLeak',
       ),
       rawUciLeakCount = _countFinding(validationRows, 'rawUciLeak'),
       pvDumpLeakCount = _countFinding(validationRows, 'pvDumpLeak'),
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
        uiTargetCount +
        backendTargetCount +
        persistenceWriteCount +
        engineCallCount +
        schedulerExecutionCount +
        analyzerWiringCount +
        stockfishCommandLeakCount +
        rawUciLeakCount +
        pvDumpLeakCount +
        unprovenAndroidProofCount +
        phase32EProofClaimCount +
        ownerProofQueueCount;
  }

  final DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationStatus status;
  final String sourceBoundaryDesignStatus;
  final bool sourceBoundaryDesignSafeForPhase33N;
  final String sourceBoundaryDesignRecommendation;
  final String sourceSelectedGoldenValidationStatus;
  final List<DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheck>
  checks;
  final List<DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationRow>
  validationRows;
  final List<String> reportFindings;
  final bool safeForPhase33O;
  final String phase33ORecommendation;
  final int totalChecks;
  final int passedCheckCount;
  final int warningCheckCount;
  final int blockerCount;
  final int criticalCount;
  late final int unsafeCount;
  final int totalValidationRows;
  final int analyzerInputCandidateValidationCount;
  final int coreSupportCandidateValidationCount;
  final int contextOnlyCandidateValidationCount;
  final int warningLimitedCandidateValidationCount;
  final int proofBoundaryOnlyValidationCount;
  final int excludedNegativeGuardValidationCount;
  final int deniedFieldBoundaryValidationCount;
  final int runtimeBlockedValidationCount;
  final int schedulerBlockedValidationCount;
  final int persistenceBlockedValidationCount;
  final int engineBlockedValidationCount;
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
  final int uiTargetCount;
  final int backendTargetCount;
  final int persistenceWriteCount;
  final int engineCallCount;
  final int schedulerExecutionCount;
  final int analyzerWiringCount;
  final int stockfishCommandLeakCount;
  final int rawUciLeakCount;
  final int pvDumpLeakCount;
  final int unprovenAndroidProofCount;
  final int phase32EProofClaimCount;
  final int ownerProofQueueCount;

  bool get hasUnsafePolicyViolation =>
      blockerCount > 0 ||
      criticalCount > 0 ||
      unsafeCount > 0 ||
      !safeForPhase33O ||
      !sourceBoundaryDesignSafeForPhase33N;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln(
        '# Debug-Only Bridge Analyzer Adapter Boundary Design Validation',
      )
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationReportVersion',
      )
      ..writeln('- validation status: ${status.wire}')
      ..writeln('- source boundary design status: $sourceBoundaryDesignStatus')
      ..writeln(
        '- source selected Golden validation status: '
        '$sourceSelectedGoldenValidationStatus',
      )
      ..writeln('- safe for Phase 33O: $safeForPhase33O')
      ..writeln('- Phase 33O recommendation: $phase33ORecommendation')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- product output count: $productOutputCount')
      ..writeln('- analyzer wiring count: $analyzerWiringCount')
      ..writeln('- engine call count: $engineCallCount')
      ..writeln('- scheduler execution count: $schedulerExecutionCount')
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
      ..writeln('## Boundary Record Validation Table')
      ..writeln(
        '| Row | Source record | Case ID | Source phase | Diagnostic role | '
        'Boundary role | Status | Design-only | Developer-only | '
        'Analyzer unwired | Active denied fields | Android proof IDs | '
        'Findings | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in validationRows) {
      buffer.writeln(
        '| ${row.validationRowId} | ${row.sourceBoundaryRecordId} | '
        '${row.sourceDiagnosticCaseId} | ${row.sourcePhase} | '
        '${row.diagnosticRole} | ${row.adapterBoundaryRole} | '
        '${row.status.wire} | ${row.designOnly} | ${row.developerOnly} | '
        '${row.analyzerUnwired} | ${_ids(row.activeDeniedFields)} | '
        '${_ids(row.androidProofCaseIds)} | ${_ids(row.findings)} | '
        '${row.recommendation} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Analyzer Input Candidate Validation')
      ..writeln(
        '- analyzer input candidate validation count: '
        '$analyzerInputCandidateValidationCount',
      )
      ..writeln(
        '- core support candidate validation count: '
        '$coreSupportCandidateValidationCount',
      )
      ..writeln()
      ..writeln('## Context, Warning, Proof, And Excluded Validation')
      ..writeln(
        '- context-only validation count: $contextOnlyCandidateValidationCount',
      )
      ..writeln(
        '- warning-limited validation count: '
        '$warningLimitedCandidateValidationCount',
      )
      ..writeln(
        '- proof-boundary-only validation count: $proofBoundaryOnlyValidationCount',
      )
      ..writeln(
        '- excluded negative guard validation count: '
        '$excludedNegativeGuardValidationCount',
      )
      ..writeln()
      ..writeln('## Denied Field Validation')
      ..writeln(
        '- denied field boundary validation count: $deniedFieldBoundaryValidationCount',
      )
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln()
      ..writeln(
        '## Runtime, Scheduler, Persistence, And Engine Blocked Validation',
      )
      ..writeln(
        '- runtime blocked validation count: $runtimeBlockedValidationCount',
      )
      ..writeln(
        '- scheduler blocked validation count: $schedulerBlockedValidationCount',
      )
      ..writeln(
        '- persistence blocked validation count: $persistenceBlockedValidationCount',
      )
      ..writeln(
        '- engine blocked validation count: $engineBlockedValidationCount',
      )
      ..writeln('- analyzer wiring count: $analyzerWiringCount')
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
      ..writeln('## Phase 33O Recommendation')
      ..writeln('- $phase33ORecommendation');
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationReportVersion,
      'validationStatus': status.wire,
      'sourceBoundaryDesignStatus': sourceBoundaryDesignStatus,
      'sourceBoundaryDesignSafeForPhase33N':
          sourceBoundaryDesignSafeForPhase33N,
      'sourceBoundaryDesignRecommendation': sourceBoundaryDesignRecommendation,
      'sourceSelectedGoldenValidationStatus':
          sourceSelectedGoldenValidationStatus,
      'safeForPhase33O': safeForPhase33O,
      'phase33ORecommendation': phase33ORecommendation,
      'counts': <String, Object?>{
        'totalChecks': totalChecks,
        'passedCheckCount': passedCheckCount,
        'warningCheckCount': warningCheckCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'unsafeCount': unsafeCount,
        'totalValidationRows': totalValidationRows,
        'analyzerInputCandidateValidationCount':
            analyzerInputCandidateValidationCount,
        'coreSupportCandidateValidationCount':
            coreSupportCandidateValidationCount,
        'contextOnlyCandidateValidationCount':
            contextOnlyCandidateValidationCount,
        'warningLimitedCandidateValidationCount':
            warningLimitedCandidateValidationCount,
        'proofBoundaryOnlyValidationCount': proofBoundaryOnlyValidationCount,
        'excludedNegativeGuardValidationCount':
            excludedNegativeGuardValidationCount,
        'deniedFieldBoundaryValidationCount':
            deniedFieldBoundaryValidationCount,
        'runtimeBlockedValidationCount': runtimeBlockedValidationCount,
        'schedulerBlockedValidationCount': schedulerBlockedValidationCount,
        'persistenceBlockedValidationCount': persistenceBlockedValidationCount,
        'engineBlockedValidationCount': engineBlockedValidationCount,
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
        'uiTargetCount': uiTargetCount,
        'backendTargetCount': backendTargetCount,
        'persistenceWriteCount': persistenceWriteCount,
        'engineCallCount': engineCallCount,
        'schedulerExecutionCount': schedulerExecutionCount,
        'analyzerWiringCount': analyzerWiringCount,
        'stockfishCommandLeakCount': stockfishCommandLeakCount,
        'rawUciLeakCount': rawUciLeakCount,
        'pvDumpLeakCount': pvDumpLeakCount,
        'unprovenAndroidProofCount': unprovenAndroidProofCount,
        'phase32EProofClaimCount': phase32EProofClaimCount,
        'ownerProofQueueCount': ownerProofQueueCount,
      },
      'checks': checks.map((check) => check.toJson()).toList(growable: false),
      'validationRows': validationRows
          .map((row) => row.toJson())
          .toList(growable: false),
      'reportFindings': reportFindings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidation {
  const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidation({
    this.boundaryDesign = const DebugOnlyBridgeAnalyzerAdapterBoundaryDesign(),
    this.validator =
        const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationValidator(),
  });

  final DebugOnlyBridgeAnalyzerAdapterBoundaryDesign boundaryDesign;
  final DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationValidator
  validator;

  DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationResult evaluate({
    DebugOnlyBridgeAnalyzerAdapterBoundaryDesignResult? boundaryDesignResult,
    Object? selectedGoldenValidationResult,
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final result =
        boundaryDesignResult ??
        boundaryDesign.evaluate(
          selectedGoldenValidationResult: selectedGoldenValidationResult,
          cases: cases,
        );
    final knownCaseIds = cases.map((item) => item.id).toSet();
    final provenAndroidProofIds = androidProofEvidence.targetCaseIds
        .where(androidProofEvidence.isRealDeviceProofCapturedFor)
        .toSet();
    final selectedGoldenInputSafe =
        _selectedGoldenValidationInputIsSafe(selectedGoldenValidationResult) ??
        result.sourceSelectedGoldenValidationSafeForPhase33M;
    final rows = result.boundaryRecords
        .map(
          (record) => validator.validateRecord(
            record,
            knownCaseIds: knownCaseIds,
            provenAndroidProofIds: provenAndroidProofIds,
          ),
        )
        .toList(growable: false);
    final repeated = boundaryDesign.evaluate(
      selectedGoldenValidationResult: selectedGoldenValidationResult,
      cases: cases,
    );
    final designReportFindings = <String>[
      ...validator.validateReportText(result.renderMarkdown()),
      ...validator.validateReportText(result.renderJson()),
    ]..sort();

    final checks = <DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheck>[
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .consumesSafeSelectedGoldenValidation,
        selectedGoldenInputSafe &&
            result.sourceSelectedGoldenValidationSafeForPhase33M &&
            result.sourceSelectedGoldenValidationRecommendation ==
                'proceedToDebugOnlyBridgeAnalyzerAdapterBoundaryDesign',
        warning: result.sourceSelectedGoldenValidationStatus.contains(
          'WithWarnings',
        ),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .boundaryComponentsAreDeterministic,
        _componentWire(result) == _componentWire(repeated),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .boundaryRecordsAreDeterministic,
        _recordWire(result) == _recordWire(repeated),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .analyzerInputCandidatesRemainFutureInternalOnly,
        _rowsWithRole(
          rows,
          DebugOnlyBridgeAnalyzerAdapterBoundaryRole.analyzerInputCandidate,
        ).every(_futureInternalOnly),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .coreSupportCandidatesDoNotBecomeProductOutput,
        _rowsWithRole(
          rows,
          DebugOnlyBridgeAnalyzerAdapterBoundaryRole.coreSupportCandidate,
        ).every((row) => !row.findings.contains('productOutput')),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .contextOnlyCandidatesRemainContextOnly,
        rows
            .where((row) => row.diagnosticRole == 'contextOnly')
            .every(
              (row) =>
                  row.adapterBoundaryRole ==
                  DebugOnlyBridgeAnalyzerAdapterBoundaryRole
                      .contextOnlyCandidate
                      .wire,
            ),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .warningLimitedCandidatesRemainWarningLimited,
        rows
            .where((row) => row.diagnosticRole == 'warningLimited')
            .every(
              (row) =>
                  row.adapterBoundaryRole ==
                  DebugOnlyBridgeAnalyzerAdapterBoundaryRole
                      .warningLimitedCandidate
                      .wire,
            ),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .proofBoundaryOnlyRowsRemainProofBoundaryOnly,
        rows
            .where(
              (row) =>
                  row.diagnosticRole == 'proofBoundaryOnly' ||
                  row.sourceDiagnosticCaseId == _pvMultiPvBoundaryCaseId,
            )
            .every(
              (row) =>
                  row.adapterBoundaryRole ==
                  DebugOnlyBridgeAnalyzerAdapterBoundaryRole
                      .proofBoundaryOnly
                      .wire,
            ),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .quietPreparatoryRemainsExcludedNegativeGuard,
        rows
            .where(_isQuietValidationRow)
            .every(
              (row) =>
                  row.adapterBoundaryRole ==
                  DebugOnlyBridgeAnalyzerAdapterBoundaryRole
                      .excludedNegativeGuard
                      .wire,
            ),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .phase32ECasesDoNotClaimCapturedAndroidProof,
        rows
            .where(
              (row) => _phase32ECaseIds.contains(row.sourceDiagnosticCaseId),
            )
            .every((row) => row.androidProofCaseIds.isEmpty),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .androidProofIdsRemainCapturedOnly,
        rows.every(
          (row) => row.androidProofCaseIds.every(
            (caseId) =>
                _capturedAndroidProofIds.contains(caseId) &&
                provenAndroidProofIds.contains(caseId),
          ),
        ),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .ownerProofQueueRemainsEmpty,
        rows.every((row) => !row.ownerProofRequired),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .deniedFieldsRemainInactive,
        rows.every((row) => row.activeDeniedFields.isEmpty),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .analyzerWiringRemainsBlocked,
        rows.every((row) => row.analyzerUnwired) &&
            result.analyzerWiringCount == 0,
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .runtimePrototypeWiringRemainBlocked,
        result.runtimeBlockedCount > 0 &&
            rows.every(
              (row) =>
                  !row.findings.contains('runtimeImplementation') &&
                  !row.findings.contains('executablePrototypeImplementation'),
            ),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .schedulerPersistenceEngineRemainBlocked,
        result.schedulerBlockedCount > 0 &&
            result.persistenceBlockedCount > 0 &&
            result.engineBlockedCount > 0 &&
            result.schedulerExecutionCount == 0 &&
            result.persistenceWriteCount == 0 &&
            result.engineCallCount == 0,
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .noLabelsScoresRankingsMetrics,
        result.labelLeakCount == 0 &&
            result.finalLabelLeakCount == 0 &&
            result.scoreLeakCount == 0 &&
            result.metricLeakCount == 0 &&
            result.moveRankingLeakCount == 0,
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .noCpLossOrWinProbability,
        result.cpLossLeakCount == 0 && result.winProbabilityLeakCount == 0,
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .noStockfishCommandRawUciPvDump,
        result.stockfishCommandLeakCount == 0 &&
            result.rawUciLeakCount == 0 &&
            result.pvDumpLeakCount == 0,
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .reportContainsNoRawUciOrPvDump,
        designReportFindings.isEmpty,
        findings: designReportFindings,
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId
            .phase33ORequirementPresent,
        _phase33ORecommendation ==
            'proceedToDebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign',
      ),
    ];

    final anyBlocked = checks.any(
      (check) =>
          check.status ==
          DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckStatus
              .blocked,
    );
    final anyUnsafeRows = rows.any(
      (row) => row.status.isUnsafe || row.status.isInvalid,
    );
    final sourceUnsafe =
        result.hasUnsafePolicyViolation ||
        !result.safeForPhase33N ||
        !selectedGoldenInputSafe;
    final safe =
        !sourceUnsafe &&
        !anyBlocked &&
        !anyUnsafeRows &&
        designReportFindings.isEmpty;
    final status = sourceUnsafe
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationStatus
              .blockedByUnsafeBoundaryDesign
        : designReportFindings.isNotEmpty || anyUnsafeRows || anyBlocked
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationStatus
              .blockedByPolicyBoundary
        : checks.any((check) => check.status.isWarning) ||
              rows.any(
                (row) =>
                    row.warningReasons.isNotEmpty ||
                    row.proofLimitReasons.isNotEmpty,
              )
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationStatus
              .boundaryDesignValidatedWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationStatus
              .boundaryDesignValidatedClean;

    return DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationResult(
      status: status,
      sourceBoundaryDesignStatus: result.status.wire,
      sourceBoundaryDesignSafeForPhase33N: result.safeForPhase33N,
      sourceBoundaryDesignRecommendation: result.phase33NRecommendation,
      sourceSelectedGoldenValidationStatus:
          result.sourceSelectedGoldenValidationStatus,
      checks: checks,
      validationRows: rows,
      reportFindings: designReportFindings,
      safeForPhase33O: safe,
      phase33ORecommendation: safe
          ? _phase33ORecommendation
          : 'blockedByUnsafeAnalyzerAdapterBoundaryDesignValidation',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationValidator {
  const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationValidator();

  DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationRow validateRecord(
    DebugOnlyBridgeAnalyzerAdapterBoundaryRecord record, {
    required Set<String> knownCaseIds,
    required Set<String> provenAndroidProofIds,
  }) {
    final findings = <String>{
      ...record.findings,
      ...const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidator()
          .validateRecord(record, knownCaseIds: knownCaseIds),
    };
    final knownSyntheticRecord =
        record.sourceDiagnosticCaseId == 'phase33m' ||
        record.sourceDiagnosticCaseId.startsWith('phase33m-');
    if (!knownSyntheticRecord &&
        !knownCaseIds.contains(record.sourceDiagnosticCaseId)) {
      findings.add('unknownSelectedDiagnosticCase');
    }
    if (record.androidProofCaseIds.any(
      (caseId) =>
          !_capturedAndroidProofIds.contains(caseId) ||
          !provenAndroidProofIds.contains(caseId),
    )) {
      findings.add('unprovenAndroidProofId');
    }
    if (record.adapterBoundaryRole ==
            DebugOnlyBridgeAnalyzerAdapterBoundaryRole.contextOnlyCandidate &&
        record.diagnosticRole == 'coreSupport') {
      findings.add('coreSupportDemotedUnexpectedly');
    }
    if (record.diagnosticRole == 'contextOnly' &&
        record.adapterBoundaryRole !=
            DebugOnlyBridgeAnalyzerAdapterBoundaryRole.contextOnlyCandidate) {
      findings.add('contextOnlyPromoted');
    }
    if (record.diagnosticRole == 'warningLimited' &&
        record.adapterBoundaryRole !=
            DebugOnlyBridgeAnalyzerAdapterBoundaryRole
                .warningLimitedCandidate) {
      findings.add('warningLimitedPromoted');
    }
    if (record.sourceDiagnosticCaseId == _pvMultiPvBoundaryCaseId &&
        record.adapterBoundaryRole !=
            DebugOnlyBridgeAnalyzerAdapterBoundaryRole.proofBoundaryOnly) {
      findings.add('pvMultiPvPromotedBeyondBoundary');
    }
    if (_isQuietRecord(record) &&
        record.adapterBoundaryRole !=
            DebugOnlyBridgeAnalyzerAdapterBoundaryRole.excludedNegativeGuard) {
      findings.add('quietPreparatoryPromotedToCore');
    }
    if (record.adapterBoundaryRole ==
            DebugOnlyBridgeAnalyzerAdapterBoundaryRole.deniedFieldBoundary &&
        record.activeDeniedFields.isNotEmpty) {
      findings.add('deniedFieldBoundaryActive');
    }
    if (record.adapterBoundaryRole ==
            DebugOnlyBridgeAnalyzerAdapterBoundaryRole.runtimeBlocked &&
        (!record.blockedBoundaryIds.contains('runtimeBridge') ||
            !record.blockedBoundaryIds.contains('executablePrototype'))) {
      findings.add('runtimeBlockedBoundaryMissing');
    }
    if (record.adapterBoundaryRole ==
            DebugOnlyBridgeAnalyzerAdapterBoundaryRole.schedulerBlocked &&
        !record.blockedBoundaryIds.contains('schedulerExecution')) {
      findings.add('schedulerBlockedBoundaryMissing');
    }
    if (record.adapterBoundaryRole ==
            DebugOnlyBridgeAnalyzerAdapterBoundaryRole.persistenceBlocked &&
        !record.blockedBoundaryIds.contains('persistenceWrite')) {
      findings.add('persistenceBlockedBoundaryMissing');
    }
    if (record.adapterBoundaryRole ==
            DebugOnlyBridgeAnalyzerAdapterBoundaryRole.engineBlocked &&
        !record.blockedBoundaryIds.contains('directEngineCall')) {
      findings.add('engineBlockedBoundaryMissing');
    }
    final sortedFindings = findings.toList(growable: false)..sort();
    final status = sortedFindings.isNotEmpty
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationRowStatus
              .unsafeRow
        : record.warningReasons.isNotEmpty ||
              record.proofLimitReasons.isNotEmpty
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationRowStatus
              .validWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationRowStatus.valid;

    return DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationRow(
      validationRowId: 'phase33n-${record.boundaryRecordId}',
      sourceBoundaryRecordId: record.boundaryRecordId,
      sourceDiagnosticCaseId: record.sourceDiagnosticCaseId,
      sourcePhase: record.sourcePhase,
      diagnosticRole: record.diagnosticRole,
      adapterBoundaryRole: record.adapterBoundaryRole.wire,
      status: status,
      designOnly: record.designOnly,
      developerOnly: record.developerOnly,
      analyzerUnwired: record.analyzerUnwired,
      allowedFieldIds: record.allowedFieldIds,
      deniedFieldIds: record.deniedFieldIds,
      blockedBoundaryIds: record.blockedBoundaryIds,
      warningReasons: record.warningReasons,
      proofLimitReasons: record.proofLimitReasons,
      androidProofCaseIds: record.androidProofCaseIds,
      ownerProofRequired: record.ownerProofRequired,
      activeDeniedFields: record.activeDeniedFields,
      findings: sortedFindings,
      recommendation: sortedFindings.isEmpty
          ? _phase33ORecommendation
          : 'fixAnalyzerAdapterBoundaryDesignBeforePrototype',
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

DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheck _check(
  DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckId checkId,
  bool passed, {
  bool warning = false,
  List<String> findings = const <String>[],
}) {
  if (!passed) {
    return DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheck(
      checkId: checkId,
      status: DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckStatus
          .blocked,
      findings: findings.isEmpty ? <String>[checkId.wire] : findings,
    );
  }
  return DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheck(
    checkId: checkId,
    status: warning
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckStatus
              .passedWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationCheckStatus
              .passed,
    findings: findings,
  );
}

bool _futureInternalOnly(
  DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationRow row,
) {
  return row.designOnly &&
      row.developerOnly &&
      row.analyzerUnwired &&
      row.activeDeniedFields.isEmpty &&
      row.findings.isEmpty;
}

Iterable<DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationRow>
_rowsWithRole(
  Iterable<DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationRow> rows,
  DebugOnlyBridgeAnalyzerAdapterBoundaryRole role,
) {
  return rows.where((row) => row.adapterBoundaryRole == role.wire);
}

bool _isQuietValidationRow(
  DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationRow row,
) {
  return row.diagnosticRole == 'excludedNegativeGuard' ||
      row.proofLimitReasons.contains(
        'quietPreparatoryExcludedFromActiveCoreOutput',
      ) ||
      row.blockedBoundaryIds.contains('quietPreparatoryCoreActivation');
}

bool _isQuietRecord(DebugOnlyBridgeAnalyzerAdapterBoundaryRecord record) {
  return record.diagnosticRole == 'excludedNegativeGuard' ||
      record.supportAreaIds.contains('quietPreparatoryMove') ||
      record.proofLimitReasons.contains(
        'quietPreparatoryExcludedFromActiveCoreOutput',
      );
}

bool? _selectedGoldenValidationInputIsSafe(Object? value) {
  if (value == null) return null;
  final map = _objectToJsonMap(value);
  if (map == null) return null;
  final safe = map['safeForPhase33M'];
  if (safe is bool) return safe;
  return null;
}

Map<String, Object?>? _objectToJsonMap(Object value) {
  if (value is Map<String, Object?>) return value;
  try {
    final dynamic dynamicValue = value;
    final dynamic json = dynamicValue.toJson();
    if (json is Map<String, Object?>) return json;
    if (json is Map<Object?, Object?>) {
      return json.map((key, value) => MapEntry(key.toString(), value));
    }
  } on Object {
    return null;
  }
  return null;
}

String _componentWire(
  DebugOnlyBridgeAnalyzerAdapterBoundaryDesignResult result,
) {
  return const JsonEncoder.withIndent(
    '  ',
  ).convert(result.components.map((component) => component.toJson()).toList());
}

String _recordWire(DebugOnlyBridgeAnalyzerAdapterBoundaryDesignResult result) {
  return const JsonEncoder.withIndent(
    '  ',
  ).convert(result.boundaryRecords.map((record) => record.toJson()).toList());
}

int _countRole(
  Iterable<DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationRow> rows,
  String role,
) {
  return rows.where((row) => row.adapterBoundaryRole == role).length;
}

int _countFinding(
  Iterable<DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationRow> rows,
  String finding,
) {
  return rows.where((row) => row.findings.contains(finding)).length;
}

bool _isCriticalFinding(String finding) =>
    finding.startsWith('reportTextLeak:');

String _ids(Iterable<String> values) =>
    values.isEmpty ? '-' : values.join(', ');

const _phase33ORecommendation =
    'proceedToDebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign';

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

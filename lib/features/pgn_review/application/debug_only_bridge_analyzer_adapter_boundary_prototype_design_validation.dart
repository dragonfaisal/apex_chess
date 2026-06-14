import 'dart:convert';

import 'debug_only_bridge_analyzer_adapter_boundary_prototype_design.dart';
import 'golden_analysis_suite.dart';

const debugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportVersion =
    'debug-only-bridge-analyzer-adapter-boundary-prototype-design-validation-v1';

enum DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationStatus {
  prototypeDesignValidatedWithWarnings('prototypeDesignValidatedWithWarnings'),
  prototypeDesignValidatedClean('prototypeDesignValidatedClean'),
  blockedByUnsafePrototypeDesign('blockedByUnsafePrototypeDesign'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidPrototypeDesignValidation('invalidPrototypeDesignValidation');

  const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationStatus(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId {
  consumesSafePrototypeDesign('consumesSafePrototypeDesign'),
  prototypePacketRolesAreDeterministic('prototypePacketRolesAreDeterministic'),
  inputPacketsRemainFutureInternalOnly('inputPacketsRemainFutureInternalOnly'),
  contextPacketsRemainContextOnly('contextPacketsRemainContextOnly'),
  warningLimitedPacketsRemainWarningLimited(
    'warningLimitedPacketsRemainWarningLimited',
  ),
  proofBoundaryPacketsRemainProofBoundaryOnly(
    'proofBoundaryPacketsRemainProofBoundaryOnly',
  ),
  quietPreparatoryRemainsExcludedNegativeGuard(
    'quietPreparatoryRemainsExcludedNegativeGuard',
  ),
  phase32ECasesDoNotClaimCapturedAndroidProof(
    'phase32ECasesDoNotClaimCapturedAndroidProof',
  ),
  androidProofIdsRemainCapturedOnly('androidProofIdsRemainCapturedOnly'),
  deniedFieldsRemainInactive('deniedFieldsRemainInactive'),
  analyzerWiringRemainsBlocked('analyzerWiringRemainsBlocked'),
  runtimeExecutablePrototypeRemainBlocked(
    'runtimeExecutablePrototypeRemainBlocked',
  ),
  schedulerPersistenceBackendUiEngineRemainBlocked(
    'schedulerPersistenceBackendUiEngineRemainBlocked',
  ),
  noLabelsScoresRankingsMetrics('noLabelsScoresRankingsMetrics'),
  noCpLossOrWinProbability('noCpLossOrWinProbability'),
  noStockfishCommandRawUciPvDump('noStockfishCommandRawUciPvDump'),
  reportContainsNoRawUciOrPvDump('reportContainsNoRawUciOrPvDump'),
  phase33QRequirementPresent('phase33QRequirementPresent');

  const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckStatus {
  passed('passed'),
  passedWithWarnings('passedWithWarnings'),
  blocked('blocked');

  const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckStatus(
    this.wire,
  );

  final String wire;

  bool get isPassed => this == passed || this == passedWithWarnings;
  bool get isWarning => this == passedWithWarnings;
}

enum DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationRowStatus {
  valid('valid'),
  validWithWarnings('validWithWarnings'),
  unsafeRow('unsafeRow'),
  invalid('invalid');

  const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationRowStatus(
    this.wire,
  );

  final String wire;

  bool get isUnsafe => this == unsafeRow;
  bool get isInvalid => this == invalid;
}

class DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheck {
  const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheck({
    required this.checkId,
    required this.status,
    this.findings = const <String>[],
  });

  final DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
  checkId;
  final DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckStatus
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

class DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationRow {
  const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationRow({
    required this.validationRowId,
    required this.sourcePrototypeRecordId,
    required this.sourceBoundaryRecordId,
    required this.sourceDiagnosticCaseId,
    required this.sourcePhase,
    required this.diagnosticRole,
    required this.adapterBoundaryRole,
    required this.prototypePacketRole,
    required this.status,
    required this.designOnly,
    required this.developerOnly,
    required this.analyzerUnwired,
    required this.futureInternalOnly,
    required this.contextOnly,
    required this.warningLimited,
    required this.proofBoundaryOnly,
    required this.excludedNegativeGuard,
    required this.inactiveDeniedFieldPacket,
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
  final String sourcePrototypeRecordId;
  final String sourceBoundaryRecordId;
  final String sourceDiagnosticCaseId;
  final String sourcePhase;
  final String diagnosticRole;
  final String adapterBoundaryRole;
  final String prototypePacketRole;
  final DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationRowStatus
  status;
  final bool designOnly;
  final bool developerOnly;
  final bool analyzerUnwired;
  final bool futureInternalOnly;
  final bool contextOnly;
  final bool warningLimited;
  final bool proofBoundaryOnly;
  final bool excludedNegativeGuard;
  final bool inactiveDeniedFieldPacket;
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
      'sourcePrototypeRecordId': sourcePrototypeRecordId,
      'sourceBoundaryRecordId': sourceBoundaryRecordId,
      'sourceDiagnosticCaseId': sourceDiagnosticCaseId,
      'sourcePhase': sourcePhase,
      'diagnosticRole': diagnosticRole,
      'adapterBoundaryRole': adapterBoundaryRole,
      'prototypePacketRole': prototypePacketRole,
      'status': status.wire,
      'designOnly': designOnly,
      'developerOnly': developerOnly,
      'analyzerUnwired': analyzerUnwired,
      'futureInternalOnly': futureInternalOnly,
      'contextOnly': contextOnly,
      'warningLimited': warningLimited,
      'proofBoundaryOnly': proofBoundaryOnly,
      'excludedNegativeGuard': excludedNegativeGuard,
      'inactiveDeniedFieldPacket': inactiveDeniedFieldPacket,
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

class DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationResult {
  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationResult({
    required this.status,
    required this.sourcePrototypeDesignStatus,
    required this.sourcePrototypeDesignSafeForPhase33P,
    required this.sourcePrototypeDesignRecommendation,
    required this.sourceBoundaryValidationStatus,
    required this.checks,
    required this.validationRows,
    required this.reportFindings,
    required this.safeForPhase33Q,
    required this.phase33QRecommendation,
  }) : totalChecks = checks.length,
       passedCheckCount = checks.where((check) => check.status.isPassed).length,
       warningCheckCount = checks
           .where((check) => check.status.isWarning)
           .length,
       blockerCount = checks
           .where(
             (check) =>
                 check.status ==
                 DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckStatus
                     .blocked,
           )
           .length,
       criticalCount = reportFindings.where(_isCriticalFinding).length,
       totalValidationRows = validationRows.length,
       inputPacketValidationCount = _countPacketRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
             .analyzerAdapterPrototypeInputPacket
             .wire,
       ),
       contextPacketValidationCount = _countPacketRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
             .analyzerAdapterPrototypeContextPacket
             .wire,
       ),
       warningLimitedPacketValidationCount = _countPacketRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
             .analyzerAdapterPrototypeWarningLimitedPacket
             .wire,
       ),
       proofBoundaryPacketValidationCount = _countPacketRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
             .analyzerAdapterPrototypeProofBoundaryPacket
             .wire,
       ),
       excludedGuardPacketValidationCount = _countPacketRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
             .analyzerAdapterPrototypeExcludedGuardPacket
             .wire,
       ),
       deniedFieldPacketValidationCount = _countPacketRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
             .analyzerAdapterPrototypeDeniedFieldPacket
             .wire,
       ),
       futureRequirementPacketValidationCount = _countPacketRole(
         validationRows,
         DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
             .analyzerAdapterPrototypeFutureRequirementPacket
             .wire,
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

  final DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationStatus
  status;
  final String sourcePrototypeDesignStatus;
  final bool sourcePrototypeDesignSafeForPhase33P;
  final String sourcePrototypeDesignRecommendation;
  final String sourceBoundaryValidationStatus;
  final List<
    DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheck
  >
  checks;
  final List<DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationRow>
  validationRows;
  final List<String> reportFindings;
  final bool safeForPhase33Q;
  final String phase33QRecommendation;
  final int totalChecks;
  final int passedCheckCount;
  final int warningCheckCount;
  final int blockerCount;
  final int criticalCount;
  late final int unsafeCount;
  final int totalValidationRows;
  final int inputPacketValidationCount;
  final int contextPacketValidationCount;
  final int warningLimitedPacketValidationCount;
  final int proofBoundaryPacketValidationCount;
  final int excludedGuardPacketValidationCount;
  final int deniedFieldPacketValidationCount;
  final int futureRequirementPacketValidationCount;
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
      !safeForPhase33Q ||
      !sourcePrototypeDesignSafeForPhase33P;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln(
        '# Debug-Only Bridge Analyzer Adapter Boundary Prototype Design Validation',
      )
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportVersion',
      )
      ..writeln('- validation status: ${status.wire}')
      ..writeln(
        '- source prototype design status: $sourcePrototypeDesignStatus',
      )
      ..writeln(
        '- source boundary validation status: $sourceBoundaryValidationStatus',
      )
      ..writeln('- safe for Phase 33Q: $safeForPhase33Q')
      ..writeln('- Phase 33Q recommendation: $phase33QRecommendation')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- analyzer wiring count: $analyzerWiringCount')
      ..writeln('- engine call count: $engineCallCount')
      ..writeln('- scheduler execution count: $schedulerExecutionCount')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- product output count: $productOutputCount')
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
      ..writeln('## Prototype Packet Validation Table')
      ..writeln(
        '| Row | Source prototype | Case ID | Diagnostic role | Boundary role | '
        'Prototype packet | Status | Future internal | Context-only | '
        'Warning-limited | Proof-boundary | Excluded guard | '
        'Inactive denied | Active denied fields | Findings | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in validationRows) {
      buffer.writeln(
        '| ${row.validationRowId} | ${row.sourcePrototypeRecordId} | '
        '${row.sourceDiagnosticCaseId} | ${row.diagnosticRole} | '
        '${row.adapterBoundaryRole} | ${row.prototypePacketRole} | '
        '${row.status.wire} | ${row.futureInternalOnly} | '
        '${row.contextOnly} | ${row.warningLimited} | '
        '${row.proofBoundaryOnly} | ${row.excludedNegativeGuard} | '
        '${row.inactiveDeniedFieldPacket} | '
        '${_ids(row.activeDeniedFields)} | ${_ids(row.findings)} | '
        '${row.recommendation} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Prototype Packet Role Validation')
      ..writeln('- input packet validation count: $inputPacketValidationCount')
      ..writeln(
        '- context packet validation count: $contextPacketValidationCount',
      )
      ..writeln(
        '- warning-limited packet validation count: '
        '$warningLimitedPacketValidationCount',
      )
      ..writeln(
        '- proof-boundary packet validation count: '
        '$proofBoundaryPacketValidationCount',
      )
      ..writeln(
        '- excluded guard packet validation count: '
        '$excludedGuardPacketValidationCount',
      )
      ..writeln(
        '- denied field packet validation count: '
        '$deniedFieldPacketValidationCount',
      )
      ..writeln(
        '- future requirement packet validation count: '
        '$futureRequirementPacketValidationCount',
      )
      ..writeln()
      ..writeln('## Denied Field Validation')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- label leak count: $labelLeakCount')
      ..writeln('- score leak count: $scoreLeakCount')
      ..writeln('- metric leak count: $metricLeakCount')
      ..writeln('- CP-loss leak count: $cpLossLeakCount')
      ..writeln('- win-probability leak count: $winProbabilityLeakCount')
      ..writeln()
      ..writeln('## Blocked Integration Validation')
      ..writeln('- analyzer wiring count: $analyzerWiringCount')
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
      ..writeln('## Phase 33Q Recommendation')
      ..writeln('- recommendation: $phase33QRecommendation')
      ..writeln()
      ..writeln('## Report Findings')
      ..writeln('- findings: ${_ids(reportFindings)}');
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportVersion,
      'validationStatus': status.wire,
      'sourcePrototypeDesignStatus': sourcePrototypeDesignStatus,
      'sourcePrototypeDesignSafeForPhase33P':
          sourcePrototypeDesignSafeForPhase33P,
      'sourcePrototypeDesignRecommendation':
          sourcePrototypeDesignRecommendation,
      'sourceBoundaryValidationStatus': sourceBoundaryValidationStatus,
      'safeForPhase33Q': safeForPhase33Q,
      'phase33QRecommendation': phase33QRecommendation,
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
        'warningLimitedPacketValidationCount':
            warningLimitedPacketValidationCount,
        'proofBoundaryPacketValidationCount':
            proofBoundaryPacketValidationCount,
        'excludedGuardPacketValidationCount':
            excludedGuardPacketValidationCount,
        'deniedFieldPacketValidationCount': deniedFieldPacketValidationCount,
        'futureRequirementPacketValidationCount':
            futureRequirementPacketValidationCount,
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
      'capturedAndroidProofIds': _capturedAndroidProofIds.toList()..sort(),
      'checks': checks.map((check) => check.toJson()).toList(growable: false),
      'validationRows': validationRows
          .map((row) => row.toJson())
          .toList(growable: false),
      'reportFindings': reportFindings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidation {
  const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidation({
    this.prototypeDesign =
        const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign(),
    this.validator =
        const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationValidator(),
  });

  final DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign prototypeDesign;
  final DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationValidator
  validator;

  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationResult
  evaluate({
    DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignResult?
    prototypeDesignResult,
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  }) {
    final source =
        prototypeDesignResult ?? prototypeDesign.evaluate(cases: cases);
    final knownCaseIds = cases.map((caseData) => caseData.id).toSet();
    final rows = source.prototypeRecords
        .map(
          (record) =>
              validator.validateRecord(record, knownCaseIds: knownCaseIds),
        )
        .toList(growable: false);
    final repeated = prototypeDesignResult == null
        ? prototypeDesign.evaluate(cases: cases)
        : source;
    final reportFindings = <String>[
      ...validator.validateReportText(source.renderMarkdown()),
      ...validator.validateReportText(source.renderJson()),
    ]..sort();
    final checks = <DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheck>[
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
            .consumesSafePrototypeDesign,
        source.safeForPhase33P &&
            source.phase33PRecommendation ==
                'validateDebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign' &&
            !source.hasUnsafePolicyViolation,
        warning: source.status.wire.contains('WithWarnings'),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
            .prototypePacketRolesAreDeterministic,
        _recordWire(source) == _recordWire(repeated),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
            .inputPacketsRemainFutureInternalOnly,
        _rowsWithPacketRole(
          rows,
          DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
              .analyzerAdapterPrototypeInputPacket,
        ).every(
          (row) =>
              row.futureInternalOnly &&
              row.designOnly &&
              row.developerOnly &&
              row.analyzerUnwired &&
              row.findings.isEmpty,
        ),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
            .contextPacketsRemainContextOnly,
        _rowsWithPacketRole(
          rows,
          DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
              .analyzerAdapterPrototypeContextPacket,
        ).every((row) => row.contextOnly && row.findings.isEmpty),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
            .warningLimitedPacketsRemainWarningLimited,
        _rowsWithPacketRole(
          rows,
          DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
              .analyzerAdapterPrototypeWarningLimitedPacket,
        ).every((row) => row.warningLimited && row.findings.isEmpty),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
            .proofBoundaryPacketsRemainProofBoundaryOnly,
        _rowsWithPacketRole(
          rows,
          DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
              .analyzerAdapterPrototypeProofBoundaryPacket,
        ).every((row) => row.proofBoundaryOnly && row.findings.isEmpty),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
            .quietPreparatoryRemainsExcludedNegativeGuard,
        rows
            .where(_isQuietRow)
            .every((row) => row.excludedNegativeGuard && row.findings.isEmpty),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
            .phase32ECasesDoNotClaimCapturedAndroidProof,
        rows
            .where(
              (row) => _phase32ECaseIds.contains(row.sourceDiagnosticCaseId),
            )
            .every((row) => row.androidProofCaseIds.isEmpty),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
            .androidProofIdsRemainCapturedOnly,
        rows.every(
          (row) =>
              row.androidProofCaseIds.every(_capturedAndroidProofIds.contains),
        ),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
            .deniedFieldsRemainInactive,
        rows.every((row) => row.activeDeniedFields.isEmpty),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
            .analyzerWiringRemainsBlocked,
        rows.every((row) => row.analyzerUnwired) &&
            source.analyzerWiringCount == 0,
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
            .runtimeExecutablePrototypeRemainBlocked,
        rows.every(
          (row) =>
              !row.findings.contains('runtimeImplementation') &&
              !row.findings.contains('executablePrototypeImplementation'),
        ),
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
            .schedulerPersistenceBackendUiEngineRemainBlocked,
        source.schedulerExecutionCount == 0 &&
            source.persistenceWriteCount == 0 &&
            source.backendTargetCount == 0 &&
            source.uiTargetCount == 0 &&
            source.engineCallCount == 0,
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
            .noLabelsScoresRankingsMetrics,
        source.labelLeakCount == 0 &&
            source.finalLabelLeakCount == 0 &&
            source.scoreLeakCount == 0 &&
            source.metricLeakCount == 0 &&
            source.moveRankingLeakCount == 0,
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
            .noCpLossOrWinProbability,
        source.cpLossLeakCount == 0 && source.winProbabilityLeakCount == 0,
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
            .noStockfishCommandRawUciPvDump,
        source.stockfishCommandLeakCount == 0 &&
            source.rawUciLeakCount == 0 &&
            source.pvDumpLeakCount == 0,
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
            .reportContainsNoRawUciOrPvDump,
        reportFindings.isEmpty,
        findings: reportFindings,
      ),
      _check(
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
            .phase33QRequirementPresent,
        _phase33QRecommendation ==
            'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign',
      ),
    ];

    final anyBlocked = checks.any(
      (check) =>
          check.status ==
          DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckStatus
              .blocked,
    );
    final anyUnsafeRows = rows.any(
      (row) => row.status.isUnsafe || row.status.isInvalid,
    );
    final sourceUnsafe =
        source.hasUnsafePolicyViolation ||
        !source.safeForPhase33P ||
        source.phase33PRecommendation !=
            'validateDebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign';
    final safe =
        !sourceUnsafe &&
        !anyBlocked &&
        !anyUnsafeRows &&
        reportFindings.isEmpty;
    final status = sourceUnsafe
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationStatus
              .blockedByUnsafePrototypeDesign
        : reportFindings.isNotEmpty || anyUnsafeRows || anyBlocked
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationStatus
              .blockedByPolicyBoundary
        : checks.any((check) => check.status.isWarning) ||
              rows.any(
                (row) =>
                    row.warningReasons.isNotEmpty ||
                    row.proofLimitReasons.isNotEmpty,
              )
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationStatus
              .prototypeDesignValidatedWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationStatus
              .prototypeDesignValidatedClean;

    return DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationResult(
      status: status,
      sourcePrototypeDesignStatus: source.status.wire,
      sourcePrototypeDesignSafeForPhase33P: source.safeForPhase33P,
      sourcePrototypeDesignRecommendation: source.phase33PRecommendation,
      sourceBoundaryValidationStatus: source.sourceBoundaryValidationStatus,
      checks: checks,
      validationRows: rows,
      reportFindings: reportFindings,
      safeForPhase33Q: safe,
      phase33QRecommendation: safe
          ? _phase33QRecommendation
          : 'blockedByUnsafeAnalyzerAdapterBoundaryPrototypeDesignValidation',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationValidator {
  const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationValidator();

  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationRow
  validateRecord(
    DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignRecord record, {
    required Set<String> knownCaseIds,
  }) {
    final findings = <String>{
      ...record.findings,
      ...const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidator()
          .validateRecord(record, knownCaseIds: knownCaseIds),
    };
    if (record.prototypePacketRole ==
            DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
                .analyzerAdapterPrototypeInputPacket &&
        (!record.futureInternalOnly ||
            record.contextOnly ||
            record.warningLimited ||
            record.proofBoundaryOnly ||
            record.excludedNegativeGuard ||
            record.inactiveDeniedFieldPacket)) {
      findings.add('inputPacketRoleBoundaryViolation');
    }
    if (record.prototypePacketRole ==
            DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
                .analyzerAdapterPrototypeContextPacket &&
        !record.contextOnly) {
      findings.add('contextPacketPromoted');
    }
    if (record.prototypePacketRole ==
            DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
                .analyzerAdapterPrototypeWarningLimitedPacket &&
        !record.warningLimited) {
      findings.add('warningLimitedPacketPromoted');
    }
    if (record.prototypePacketRole ==
            DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
                .analyzerAdapterPrototypeProofBoundaryPacket &&
        !record.proofBoundaryOnly) {
      findings.add('proofBoundaryPacketPromoted');
    }
    if (record.prototypePacketRole ==
            DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
                .analyzerAdapterPrototypeExcludedGuardPacket &&
        !record.excludedNegativeGuard) {
      findings.add('excludedGuardPromoted');
    }
    if (record.prototypePacketRole ==
            DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
                .analyzerAdapterPrototypeDeniedFieldPacket &&
        !record.inactiveDeniedFieldPacket) {
      findings.add('deniedFieldPacketActive');
    }
    if (record.prototypePacketRole ==
            DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
                .analyzerAdapterPrototypeFutureRequirementPacket &&
        record.recommendation !=
            'validateDebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign') {
      findings.add('missingPhase33QContractDesignRequirement');
    }
    final sortedFindings = findings.toList(growable: false)..sort();
    final status = sortedFindings.isNotEmpty
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationRowStatus
              .unsafeRow
        : record.warningReasons.isNotEmpty ||
              record.proofLimitReasons.isNotEmpty
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationRowStatus
              .validWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationRowStatus
              .valid;

    return DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationRow(
      validationRowId: 'phase33p-${record.prototypeRecordId}',
      sourcePrototypeRecordId: record.prototypeRecordId,
      sourceBoundaryRecordId: record.sourceBoundaryRecordId,
      sourceDiagnosticCaseId: record.sourceDiagnosticCaseId,
      sourcePhase: record.sourcePhase,
      diagnosticRole: record.diagnosticRole,
      adapterBoundaryRole: record.adapterBoundaryRole,
      prototypePacketRole: record.prototypePacketRole.wire,
      status: status,
      designOnly: record.designOnly,
      developerOnly: record.developerOnly,
      analyzerUnwired: record.analyzerUnwired,
      futureInternalOnly: record.futureInternalOnly,
      contextOnly: record.contextOnly,
      warningLimited: record.warningLimited,
      proofBoundaryOnly: record.proofBoundaryOnly,
      excludedNegativeGuard: record.excludedNegativeGuard,
      inactiveDeniedFieldPacket: record.inactiveDeniedFieldPacket,
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
          ? _phase33QRecommendation
          : 'fixAnalyzerAdapterBoundaryPrototypeDesignBeforeContract',
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

DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheck _check(
  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckId
  checkId,
  bool passed, {
  bool warning = false,
  List<String> findings = const <String>[],
}) {
  if (!passed) {
    return DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheck(
      checkId: checkId,
      status:
          DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckStatus
              .blocked,
      findings: findings.isEmpty ? <String>[checkId.wire] : findings,
    );
  }
  return DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheck(
    checkId: checkId,
    status: warning
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckStatus
              .passedWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationCheckStatus
              .passed,
    findings: findings,
  );
}

Iterable<DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationRow>
_rowsWithPacketRole(
  Iterable<DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationRow>
  rows,
  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole role,
) {
  return rows.where((row) => row.prototypePacketRole == role.wire);
}

bool _isQuietRow(
  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationRow row,
) {
  return row.diagnosticRole == 'excludedNegativeGuard' ||
      row.blockedBoundaryIds.contains('quietPreparatoryCoreActivation') ||
      row.proofLimitReasons.contains(
        'quietPreparatoryExcludedFromActiveCoreOutput',
      );
}

String _recordWire(
  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignResult result,
) {
  return const JsonEncoder.withIndent(
    '  ',
  ).convert(result.prototypeRecords.map((record) => record.toJson()).toList());
}

int _countPacketRole(
  Iterable<DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationRow>
  rows,
  String role,
) {
  return rows.where((row) => row.prototypePacketRole == role).length;
}

int _countFinding(
  Iterable<DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationRow>
  rows,
  String finding,
) {
  return rows.where((row) => row.findings.contains(finding)).length;
}

bool _isCriticalFinding(String finding) =>
    finding.startsWith('reportTextLeak:');

String _ids(Iterable<String> values) =>
    values.isEmpty ? '-' : values.join(', ');

const _phase33QRecommendation =
    'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign';

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

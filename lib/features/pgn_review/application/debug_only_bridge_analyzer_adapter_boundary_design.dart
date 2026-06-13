import 'dart:convert';

import 'golden_analysis_suite.dart';

const debugOnlyBridgeAnalyzerAdapterBoundaryDesignReportVersion =
    'debug-only-bridge-analyzer-adapter-boundary-design-v1';

enum DebugOnlyBridgeAnalyzerAdapterBoundaryDesignStatus {
  boundaryDesignReadyWithWarnings('boundaryDesignReadyWithWarnings'),
  boundaryDesignReadyClean('boundaryDesignReadyClean'),
  blockedByUnsafeSelectedGoldenValidation(
    'blockedByUnsafeSelectedGoldenValidation',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidBoundaryDesign('invalidBoundaryDesign');

  const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignStatus(this.wire);

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterBoundaryComponentId {
  analyzerAdapterInputBoundary('analyzerAdapterInputBoundary'),
  analyzerAdapterCoreSupportBoundary('analyzerAdapterCoreSupportBoundary'),
  analyzerAdapterContextBoundary('analyzerAdapterContextBoundary'),
  analyzerAdapterWarningLimitedBoundary(
    'analyzerAdapterWarningLimitedBoundary',
  ),
  analyzerAdapterProofBoundary('analyzerAdapterProofBoundary'),
  analyzerAdapterExcludedNegativeGuardBoundary(
    'analyzerAdapterExcludedNegativeGuardBoundary',
  ),
  analyzerAdapterDeniedFieldBoundary('analyzerAdapterDeniedFieldBoundary'),
  analyzerAdapterRuntimeBlockedBoundary(
    'analyzerAdapterRuntimeBlockedBoundary',
  ),
  analyzerAdapterSchedulerBlockedBoundary(
    'analyzerAdapterSchedulerBlockedBoundary',
  ),
  analyzerAdapterPersistenceBlockedBoundary(
    'analyzerAdapterPersistenceBlockedBoundary',
  ),
  analyzerAdapterEngineBlockedBoundary('analyzerAdapterEngineBlockedBoundary'),
  phase33NRequirementBoundary('phase33NRequirementBoundary');

  const DebugOnlyBridgeAnalyzerAdapterBoundaryComponentId(this.wire);

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterBoundaryRole {
  analyzerInputCandidate('analyzerInputCandidate'),
  coreSupportCandidate('coreSupportCandidate'),
  contextOnlyCandidate('contextOnlyCandidate'),
  warningLimitedCandidate('warningLimitedCandidate'),
  proofBoundaryOnly('proofBoundaryOnly'),
  excludedNegativeGuard('excludedNegativeGuard'),
  deniedFieldBoundary('deniedFieldBoundary'),
  runtimeBlocked('runtimeBlocked'),
  schedulerBlocked('schedulerBlocked'),
  persistenceBlocked('persistenceBlocked'),
  engineBlocked('engineBlocked'),
  futureRequirement('futureRequirement');

  const DebugOnlyBridgeAnalyzerAdapterBoundaryRole(this.wire);

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags {
  const DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags({
    this.isProductOutput = false,
    this.emitsClassifierLabel = false,
    this.emitsFinalLabel = false,
    this.hasNumericScore = false,
    this.hasAggregateScore = false,
    this.ranksMoves = false,
    this.emitsOfficialMetric = false,
    this.exposesCpLoss = false,
    this.exposesWinProbability = false,
    this.exposesStockfishCommand = false,
    this.exposesRawUci = false,
    this.exposesPvDump = false,
    this.targetsUi = false,
    this.targetsBackend = false,
    this.writesPersistence = false,
    this.callsEngine = false,
    this.executesScheduler = false,
    this.wiresAnalyzer = false,
    this.implementsRuntime = false,
    this.implementsExecutablePrototype = false,
    this.requiresAndroidCollector = false,
  });

  final bool isProductOutput;
  final bool emitsClassifierLabel;
  final bool emitsFinalLabel;
  final bool hasNumericScore;
  final bool hasAggregateScore;
  final bool ranksMoves;
  final bool emitsOfficialMetric;
  final bool exposesCpLoss;
  final bool exposesWinProbability;
  final bool exposesStockfishCommand;
  final bool exposesRawUci;
  final bool exposesPvDump;
  final bool targetsUi;
  final bool targetsBackend;
  final bool writesPersistence;
  final bool callsEngine;
  final bool executesScheduler;
  final bool wiresAnalyzer;
  final bool implementsRuntime;
  final bool implementsExecutablePrototype;
  final bool requiresAndroidCollector;

  bool get hasUnsafeFlag =>
      isProductOutput ||
      emitsClassifierLabel ||
      emitsFinalLabel ||
      hasNumericScore ||
      hasAggregateScore ||
      ranksMoves ||
      emitsOfficialMetric ||
      exposesCpLoss ||
      exposesWinProbability ||
      exposesStockfishCommand ||
      exposesRawUci ||
      exposesPvDump ||
      targetsUi ||
      targetsBackend ||
      writesPersistence ||
      callsEngine ||
      executesScheduler ||
      wiresAnalyzer ||
      implementsRuntime ||
      implementsExecutablePrototype ||
      requiresAndroidCollector;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'isProductOutput': isProductOutput,
      'emitsClassifierLabel': emitsClassifierLabel,
      'emitsFinalLabel': emitsFinalLabel,
      'hasNumericScore': hasNumericScore,
      'hasAggregateScore': hasAggregateScore,
      'ranksMoves': ranksMoves,
      'emitsOfficialMetric': emitsOfficialMetric,
      'exposesCpLoss': exposesCpLoss,
      'exposesWinProbability': exposesWinProbability,
      'exposesStockfishCommand': exposesStockfishCommand,
      'exposesRawUci': exposesRawUci,
      'exposesPvDump': exposesPvDump,
      'targetsUi': targetsUi,
      'targetsBackend': targetsBackend,
      'writesPersistence': writesPersistence,
      'callsEngine': callsEngine,
      'executesScheduler': executesScheduler,
      'wiresAnalyzer': wiresAnalyzer,
      'implementsRuntime': implementsRuntime,
      'implementsExecutablePrototype': implementsExecutablePrototype,
      'requiresAndroidCollector': requiresAndroidCollector,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterBoundaryComponent {
  const DebugOnlyBridgeAnalyzerAdapterBoundaryComponent({
    required this.componentId,
    required this.recordIds,
    required this.status,
  });

  final DebugOnlyBridgeAnalyzerAdapterBoundaryComponentId componentId;
  final List<String> recordIds;
  final String status;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'componentId': componentId.wire,
      'recordCount': recordIds.length,
      'recordIds': recordIds,
      'status': status,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterBoundaryRecord {
  const DebugOnlyBridgeAnalyzerAdapterBoundaryRecord({
    required this.boundaryRecordId,
    required this.sourceDiagnosticCaseId,
    required this.sourceValidationRowId,
    required this.sourcePhase,
    required this.selectedReason,
    required this.diagnosticRole,
    required this.adapterBoundaryRole,
    required this.supportAreaIds,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.blockedBoundaryIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.androidProofCaseIds,
    required this.ownerProofRequired,
    required this.designOnly,
    required this.developerOnly,
    required this.analyzerUnwired,
    required this.activeDeniedFields,
    required this.safetyFlags,
    required this.findings,
    required this.recommendation,
  });

  final String boundaryRecordId;
  final String sourceDiagnosticCaseId;
  final String sourceValidationRowId;
  final String sourcePhase;
  final String selectedReason;
  final String diagnosticRole;
  final DebugOnlyBridgeAnalyzerAdapterBoundaryRole adapterBoundaryRole;
  final List<String> supportAreaIds;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final List<String> blockedBoundaryIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofCaseIds;
  final bool ownerProofRequired;
  final bool designOnly;
  final bool developerOnly;
  final bool analyzerUnwired;
  final List<String> activeDeniedFields;
  final DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags safetyFlags;
  final List<String> findings;
  final String recommendation;

  DebugOnlyBridgeAnalyzerAdapterBoundaryRecord copyWith({
    String? boundaryRecordId,
    String? sourceDiagnosticCaseId,
    String? sourceValidationRowId,
    String? sourcePhase,
    String? selectedReason,
    String? diagnosticRole,
    DebugOnlyBridgeAnalyzerAdapterBoundaryRole? adapterBoundaryRole,
    List<String>? supportAreaIds,
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    List<String>? blockedBoundaryIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? androidProofCaseIds,
    bool? ownerProofRequired,
    bool? designOnly,
    bool? developerOnly,
    bool? analyzerUnwired,
    List<String>? activeDeniedFields,
    DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags? safetyFlags,
    List<String>? findings,
    String? recommendation,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterBoundaryRecord(
      boundaryRecordId: boundaryRecordId ?? this.boundaryRecordId,
      sourceDiagnosticCaseId:
          sourceDiagnosticCaseId ?? this.sourceDiagnosticCaseId,
      sourceValidationRowId:
          sourceValidationRowId ?? this.sourceValidationRowId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      selectedReason: selectedReason ?? this.selectedReason,
      diagnosticRole: diagnosticRole ?? this.diagnosticRole,
      adapterBoundaryRole: adapterBoundaryRole ?? this.adapterBoundaryRole,
      supportAreaIds: supportAreaIds ?? this.supportAreaIds,
      allowedFieldIds: allowedFieldIds ?? this.allowedFieldIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      designOnly: designOnly ?? this.designOnly,
      developerOnly: developerOnly ?? this.developerOnly,
      analyzerUnwired: analyzerUnwired ?? this.analyzerUnwired,
      activeDeniedFields: activeDeniedFields ?? this.activeDeniedFields,
      safetyFlags: safetyFlags ?? this.safetyFlags,
      findings: findings ?? this.findings,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'boundaryRecordId': boundaryRecordId,
      'sourceDiagnosticCaseId': sourceDiagnosticCaseId,
      'sourceValidationRowId': sourceValidationRowId,
      'sourcePhase': sourcePhase,
      'selectedReason': selectedReason,
      'diagnosticRole': diagnosticRole,
      'adapterBoundaryRole': adapterBoundaryRole.wire,
      'supportAreaIds': supportAreaIds,
      'allowedFieldIds': allowedFieldIds,
      'deniedFieldIds': deniedFieldIds,
      'blockedBoundaryIds': blockedBoundaryIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'androidProofCaseIds': androidProofCaseIds,
      'ownerProofRequired': ownerProofRequired,
      'designOnly': designOnly,
      'developerOnly': developerOnly,
      'analyzerUnwired': analyzerUnwired,
      'activeDeniedFields': activeDeniedFields,
      'safetyFlags': safetyFlags.toJson(),
      'findings': findings,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterBoundaryDesignResult {
  DebugOnlyBridgeAnalyzerAdapterBoundaryDesignResult({
    required this.status,
    required this.sourceSelectedGoldenValidationStatus,
    required this.sourceSelectedGoldenValidationSafeForPhase33M,
    required this.sourceSelectedGoldenValidationRecommendation,
    required this.components,
    required this.boundaryRecords,
    required this.reportFindings,
    required this.safeForPhase33N,
    required this.phase33NRecommendation,
  }) : totalBoundaryRecords = boundaryRecords.length,
       analyzerInputCandidateCount = _countRole(
         boundaryRecords,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.analyzerInputCandidate,
       ),
       coreSupportCandidateCount = _countRole(
         boundaryRecords,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.coreSupportCandidate,
       ),
       contextOnlyCandidateCount = _countRole(
         boundaryRecords,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.contextOnlyCandidate,
       ),
       warningLimitedCandidateCount = _countRole(
         boundaryRecords,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.warningLimitedCandidate,
       ),
       proofBoundaryOnlyCount = _countRole(
         boundaryRecords,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.proofBoundaryOnly,
       ),
       excludedNegativeGuardCount = _countRole(
         boundaryRecords,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.excludedNegativeGuard,
       ),
       deniedFieldBoundaryCount = _countRole(
         boundaryRecords,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.deniedFieldBoundary,
       ),
       runtimeBlockedCount = _countRole(
         boundaryRecords,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.runtimeBlocked,
       ),
       schedulerBlockedCount = _countRole(
         boundaryRecords,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.schedulerBlocked,
       ),
       persistenceBlockedCount = _countRole(
         boundaryRecords,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.persistenceBlocked,
       ),
       engineBlockedCount = _countRole(
         boundaryRecords,
         DebugOnlyBridgeAnalyzerAdapterBoundaryRole.engineBlocked,
       ),
       blockerCount = boundaryRecords
           .where((record) => record.findings.any(_isBlockerFinding))
           .length,
       criticalCount = reportFindings.where(_isCriticalFinding).length,
       activeDeniedFieldCount = boundaryRecords.fold<int>(
         0,
         (total, record) => total + record.activeDeniedFields.length,
       ),
       productOutputCount = boundaryRecords
           .where((record) => record.safetyFlags.isProductOutput)
           .length,
       labelLeakCount = boundaryRecords
           .where((record) => record.safetyFlags.emitsClassifierLabel)
           .length,
       finalLabelLeakCount = boundaryRecords
           .where((record) => record.safetyFlags.emitsFinalLabel)
           .length,
       scoreLeakCount = boundaryRecords
           .where(
             (record) =>
                 record.safetyFlags.hasNumericScore ||
                 record.safetyFlags.hasAggregateScore,
           )
           .length,
       metricLeakCount = boundaryRecords
           .where((record) => record.safetyFlags.emitsOfficialMetric)
           .length,
       cpLossLeakCount = boundaryRecords
           .where((record) => record.safetyFlags.exposesCpLoss)
           .length,
       winProbabilityLeakCount = boundaryRecords
           .where((record) => record.safetyFlags.exposesWinProbability)
           .length,
       moveRankingLeakCount = boundaryRecords
           .where((record) => record.safetyFlags.ranksMoves)
           .length,
       uiTargetCount = boundaryRecords
           .where((record) => record.safetyFlags.targetsUi)
           .length,
       backendTargetCount = boundaryRecords
           .where((record) => record.safetyFlags.targetsBackend)
           .length,
       persistenceWriteCount = boundaryRecords
           .where((record) => record.safetyFlags.writesPersistence)
           .length,
       engineCallCount = boundaryRecords
           .where((record) => record.safetyFlags.callsEngine)
           .length,
       schedulerExecutionCount = boundaryRecords
           .where((record) => record.safetyFlags.executesScheduler)
           .length,
       analyzerWiringCount = boundaryRecords
           .where((record) => record.safetyFlags.wiresAnalyzer)
           .length,
       stockfishCommandLeakCount = boundaryRecords
           .where((record) => record.safetyFlags.exposesStockfishCommand)
           .length,
       rawUciLeakCount = boundaryRecords
           .where((record) => record.safetyFlags.exposesRawUci)
           .length,
       pvDumpLeakCount = boundaryRecords
           .where((record) => record.safetyFlags.exposesPvDump)
           .length,
       unprovenAndroidProofCount = boundaryRecords
           .where(
             (record) => record.androidProofCaseIds.any(
               (caseId) => !_capturedAndroidProofIds.contains(caseId),
             ),
           )
           .length,
       phase32EProofClaimCount = boundaryRecords
           .where(
             (record) =>
                 _phase32ECaseIds.contains(record.sourceDiagnosticCaseId) &&
                 record.androidProofCaseIds.isNotEmpty,
           )
           .length,
       ownerProofQueueCount = boundaryRecords
           .where((record) => record.ownerProofRequired)
           .length {
    unsafeCount =
        boundaryRecords
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
        stockfishCommandLeakCount +
        rawUciLeakCount +
        pvDumpLeakCount +
        unprovenAndroidProofCount +
        phase32EProofClaimCount +
        ownerProofQueueCount;
  }

  final DebugOnlyBridgeAnalyzerAdapterBoundaryDesignStatus status;
  final String sourceSelectedGoldenValidationStatus;
  final bool sourceSelectedGoldenValidationSafeForPhase33M;
  final String sourceSelectedGoldenValidationRecommendation;
  final List<DebugOnlyBridgeAnalyzerAdapterBoundaryComponent> components;
  final List<DebugOnlyBridgeAnalyzerAdapterBoundaryRecord> boundaryRecords;
  final List<String> reportFindings;
  final bool safeForPhase33N;
  final String phase33NRecommendation;
  final int totalBoundaryRecords;
  final int analyzerInputCandidateCount;
  final int coreSupportCandidateCount;
  final int contextOnlyCandidateCount;
  final int warningLimitedCandidateCount;
  final int proofBoundaryOnlyCount;
  final int excludedNegativeGuardCount;
  final int deniedFieldBoundaryCount;
  final int runtimeBlockedCount;
  final int schedulerBlockedCount;
  final int persistenceBlockedCount;
  final int engineBlockedCount;
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
      !safeForPhase33N ||
      !sourceSelectedGoldenValidationSafeForPhase33M;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Debug-Only Bridge Analyzer Adapter Boundary Design')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterBoundaryDesignReportVersion',
      )
      ..writeln('- design status: ${status.wire}')
      ..writeln(
        '- source selected Golden validation status: '
        '$sourceSelectedGoldenValidationStatus',
      )
      ..writeln(
        '- source selected Golden validation safe for Phase 33M: '
        '$sourceSelectedGoldenValidationSafeForPhase33M',
      )
      ..writeln('- safe for Phase 33N: $safeForPhase33N')
      ..writeln('- Phase 33N recommendation: $phase33NRecommendation')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- product output count: $productOutputCount')
      ..writeln('- engine call count: $engineCallCount')
      ..writeln('- scheduler execution count: $schedulerExecutionCount')
      ..writeln('- analyzer wiring count: $analyzerWiringCount')
      ..writeln()
      ..writeln('## Boundary Component Table')
      ..writeln('| Component | Record count | Status |')
      ..writeln('| --- | --- | --- |');
    for (final component in components) {
      buffer.writeln(
        '| ${component.componentId.wire} | ${component.recordIds.length} | '
        '${component.status} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Boundary Record Table')
      ..writeln(
        '| Record | Case ID | Source row | Source phase | Diagnostic role | '
        'Boundary role | Design-only | Developer-only | Analyzer unwired | '
        'Active denied fields | Android proof IDs | Findings | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final record in boundaryRecords) {
      buffer.writeln(
        '| ${record.boundaryRecordId} | ${record.sourceDiagnosticCaseId} | '
        '${record.sourceValidationRowId} | ${record.sourcePhase} | '
        '${record.diagnosticRole} | ${record.adapterBoundaryRole.wire} | '
        '${record.designOnly} | ${record.developerOnly} | '
        '${record.analyzerUnwired} | ${_ids(record.activeDeniedFields)} | '
        '${_ids(record.androidProofCaseIds)} | ${_ids(record.findings)} | '
        '${record.recommendation} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Analyzer Input Candidate Summary')
      ..writeln(
        '- analyzer input candidate count: $analyzerInputCandidateCount',
      )
      ..writeln('- core support candidate count: $coreSupportCandidateCount')
      ..writeln()
      ..writeln('## Context, Warning, Proof, And Excluded Summaries')
      ..writeln('- context-only candidate count: $contextOnlyCandidateCount')
      ..writeln(
        '- warning-limited candidate count: $warningLimitedCandidateCount',
      )
      ..writeln('- proof-boundary-only count: $proofBoundaryOnlyCount')
      ..writeln('- excluded negative guard count: $excludedNegativeGuardCount')
      ..writeln()
      ..writeln('## Denied Field Boundary')
      ..writeln('- denied field boundary count: $deniedFieldBoundaryCount')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- denied fields: ${_ids(_deniedFieldIds)}')
      ..writeln()
      ..writeln('## Runtime, Scheduler, Persistence, And Engine Boundaries')
      ..writeln('- runtime blocked count: $runtimeBlockedCount')
      ..writeln('- scheduler blocked count: $schedulerBlockedCount')
      ..writeln('- persistence blocked count: $persistenceBlockedCount')
      ..writeln('- engine blocked count: $engineBlockedCount')
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
      ..writeln('## Phase 33N Recommendation')
      ..writeln('- $phase33NRecommendation');
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': debugOnlyBridgeAnalyzerAdapterBoundaryDesignReportVersion,
      'designStatus': status.wire,
      'sourceSelectedGoldenValidationStatus':
          sourceSelectedGoldenValidationStatus,
      'sourceSelectedGoldenValidationSafeForPhase33M':
          sourceSelectedGoldenValidationSafeForPhase33M,
      'sourceSelectedGoldenValidationRecommendation':
          sourceSelectedGoldenValidationRecommendation,
      'safeForPhase33N': safeForPhase33N,
      'phase33NRecommendation': phase33NRecommendation,
      'counts': <String, Object?>{
        'totalBoundaryRecords': totalBoundaryRecords,
        'analyzerInputCandidateCount': analyzerInputCandidateCount,
        'coreSupportCandidateCount': coreSupportCandidateCount,
        'contextOnlyCandidateCount': contextOnlyCandidateCount,
        'warningLimitedCandidateCount': warningLimitedCandidateCount,
        'proofBoundaryOnlyCount': proofBoundaryOnlyCount,
        'excludedNegativeGuardCount': excludedNegativeGuardCount,
        'deniedFieldBoundaryCount': deniedFieldBoundaryCount,
        'runtimeBlockedCount': runtimeBlockedCount,
        'schedulerBlockedCount': schedulerBlockedCount,
        'persistenceBlockedCount': persistenceBlockedCount,
        'engineBlockedCount': engineBlockedCount,
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
        'stockfishCommandLeakCount': stockfishCommandLeakCount,
        'rawUciLeakCount': rawUciLeakCount,
        'pvDumpLeakCount': pvDumpLeakCount,
        'unprovenAndroidProofCount': unprovenAndroidProofCount,
        'phase32EProofClaimCount': phase32EProofClaimCount,
        'ownerProofQueueCount': ownerProofQueueCount,
      },
      'components': components
          .map((component) => component.toJson())
          .toList(growable: false),
      'boundaryRecords': boundaryRecords
          .map((record) => record.toJson())
          .toList(growable: false),
      'reportFindings': reportFindings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterBoundaryDesign {
  const DebugOnlyBridgeAnalyzerAdapterBoundaryDesign({
    this.validator =
        const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidator(),
  });

  final DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidator validator;

  DebugOnlyBridgeAnalyzerAdapterBoundaryDesignResult evaluate({
    Object? selectedGoldenValidationResult,
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  }) {
    final source = _sourceFromSelectedGoldenValidation(
      selectedGoldenValidationResult,
      cases,
    );
    final records = <DebugOnlyBridgeAnalyzerAdapterBoundaryRecord>[
      for (final row in source.rows) _recordFromSourceRow(row),
      _blockedRecord(
        recordId: 'phase33m-denied-field-boundary',
        role: DebugOnlyBridgeAnalyzerAdapterBoundaryRole.deniedFieldBoundary,
        selectedReason: 'denied fields stay inactive across adapter boundary',
        blockedBoundaryIds: _deniedFieldIds,
      ),
      _blockedRecord(
        recordId: 'phase33m-runtime-blocked-boundary',
        role: DebugOnlyBridgeAnalyzerAdapterBoundaryRole.runtimeBlocked,
        selectedReason: 'runtime bridge remains unimplemented',
        blockedBoundaryIds: const <String>[
          'runtimeBridge',
          'executablePrototype',
          'implementationWiring',
        ],
      ),
      _blockedRecord(
        recordId: 'phase33m-scheduler-blocked-boundary',
        role: DebugOnlyBridgeAnalyzerAdapterBoundaryRole.schedulerBlocked,
        selectedReason: 'scheduler execution remains outside adapter boundary',
        blockedBoundaryIds: const <String>['schedulerExecution'],
      ),
      _blockedRecord(
        recordId: 'phase33m-persistence-blocked-boundary',
        role: DebugOnlyBridgeAnalyzerAdapterBoundaryRole.persistenceBlocked,
        selectedReason: 'persistence writes remain outside adapter boundary',
        blockedBoundaryIds: const <String>[
          'persistenceWrite',
          'cacheWrite',
          'databaseWrite',
        ],
      ),
      _blockedRecord(
        recordId: 'phase33m-engine-blocked-boundary',
        role: DebugOnlyBridgeAnalyzerAdapterBoundaryRole.engineBlocked,
        selectedReason: 'engine execution remains outside adapter boundary',
        blockedBoundaryIds: const <String>[
          'directEngineCall',
          'stockfishCommand',
          'rawUci',
          'pvDump',
        ],
      ),
      _blockedRecord(
        recordId: 'phase33m-phase33n-requirement',
        role: DebugOnlyBridgeAnalyzerAdapterBoundaryRole.futureRequirement,
        selectedReason:
            'Phase 33N must validate this boundary before any adapter prototype',
        blockedBoundaryIds: const <String>[
          'runtimeBridge',
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
              knownCaseIds: source.knownCaseIds,
            ),
          ),
        )
        .toList(growable: false);
    final components = _componentsForRecords(validatedRecords);
    final reportFindings = validator.validateReportText(
      _renderRecordsForLeakCheck(validatedRecords),
    );
    final hasFutureRequirement = validatedRecords.any(
      (record) =>
          record.adapterBoundaryRole ==
          DebugOnlyBridgeAnalyzerAdapterBoundaryRole.futureRequirement,
    );
    final sourceSafe =
        source.safeForPhase33M &&
        source.phase33MRecommendation ==
            'proceedToDebugOnlyBridgeAnalyzerAdapterBoundaryDesign';
    final hasRecordFindings = validatedRecords.any(
      (record) => record.findings.isNotEmpty,
    );
    final safe =
        sourceSafe &&
        hasFutureRequirement &&
        !hasRecordFindings &&
        reportFindings.isEmpty;
    final status = !sourceSafe
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryDesignStatus
              .blockedByUnsafeSelectedGoldenValidation
        : !hasFutureRequirement
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryDesignStatus
              .invalidBoundaryDesign
        : hasRecordFindings || reportFindings.isNotEmpty
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryDesignStatus
              .blockedByPolicyBoundary
        : validatedRecords.any(
            (record) =>
                record.warningReasons.isNotEmpty ||
                record.proofLimitReasons.isNotEmpty,
          )
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryDesignStatus
              .boundaryDesignReadyWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterBoundaryDesignStatus
              .boundaryDesignReadyClean;

    return DebugOnlyBridgeAnalyzerAdapterBoundaryDesignResult(
      status: status,
      sourceSelectedGoldenValidationStatus: source.validationStatus,
      sourceSelectedGoldenValidationSafeForPhase33M: source.safeForPhase33M,
      sourceSelectedGoldenValidationRecommendation:
          source.phase33MRecommendation,
      components: components,
      boundaryRecords: validatedRecords,
      reportFindings: reportFindings,
      safeForPhase33N: safe,
      phase33NRecommendation: safe
          ? _phase33NRecommendation
          : 'blockedByUnsafeAnalyzerAdapterBoundaryDesign',
    );
  }

  DebugOnlyBridgeAnalyzerAdapterBoundaryRecord _recordFromSourceRow(
    _SelectedGoldenValidationSourceRow row,
  ) {
    final role = _adapterRoleForSourceRow(row);
    return DebugOnlyBridgeAnalyzerAdapterBoundaryRecord(
      boundaryRecordId: 'phase33m-${row.validationRowId}',
      sourceDiagnosticCaseId: row.caseId,
      sourceValidationRowId: row.validationRowId,
      sourcePhase: row.sourcePhase,
      selectedReason: row.selectedReason,
      diagnosticRole: row.diagnosticRole,
      adapterBoundaryRole: role,
      supportAreaIds: _sorted(row.supportAreaIds),
      allowedFieldIds: _allowedFieldIds,
      deniedFieldIds: _deniedFieldIds,
      blockedBoundaryIds: _sorted(row.blockedBoundaryIds),
      warningReasons: _sorted(row.warningReasons),
      proofLimitReasons: _sorted(row.proofLimitReasons),
      androidProofCaseIds: _sorted(row.androidProofCaseIds),
      ownerProofRequired: row.ownerProofRequired,
      designOnly: true,
      developerOnly: true,
      analyzerUnwired: true,
      activeDeniedFields: _sorted(row.activeDeniedFields),
      safetyFlags: const DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(),
      findings: const <String>[],
      recommendation: _phase33NRecommendation,
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidator {
  const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidator();

  List<String> validateRecord(
    DebugOnlyBridgeAnalyzerAdapterBoundaryRecord record, {
    required Set<String> knownCaseIds,
  }) {
    final findings = <String>[];
    final knownSyntheticRecord =
        record.sourceDiagnosticCaseId.startsWith('phase33m-') ||
        record.sourceDiagnosticCaseId == 'phase33m';
    if (!knownSyntheticRecord &&
        !knownCaseIds.contains(record.sourceDiagnosticCaseId)) {
      findings.add('unknownSelectedDiagnosticCase');
    }
    if (!record.designOnly) findings.add('designOnlyDisabled');
    if (!record.developerOnly) findings.add('developerOnlyDisabled');
    if (!record.analyzerUnwired) findings.add('analyzerWiringEnabled');
    if (record.activeDeniedFields.isNotEmpty) {
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
        (record.adapterBoundaryRole ==
                DebugOnlyBridgeAnalyzerAdapterBoundaryRole
                    .analyzerInputCandidate ||
            record.adapterBoundaryRole ==
                DebugOnlyBridgeAnalyzerAdapterBoundaryRole
                    .coreSupportCandidate)) {
      findings.add('quietPreparatoryPromotedToCore');
    }
    if (_phase32ECaseIds.contains(record.sourceDiagnosticCaseId) &&
        record.androidProofCaseIds.isNotEmpty) {
      findings.add('phase32ECapturedAndroidProofClaim');
    }
    if (record.sourceDiagnosticCaseId == _pvMultiPvBoundaryCaseId &&
        (record.adapterBoundaryRole !=
                DebugOnlyBridgeAnalyzerAdapterBoundaryRole.proofBoundaryOnly ||
            record.androidProofCaseIds.isNotEmpty)) {
      findings.add('pvMultiPvPromotedBeyondBoundary');
    }
    if (record.ownerProofRequired &&
        !record.proofLimitReasons.any(
          (reason) => reason.contains('pvMultiPv'),
        )) {
      findings.add('ownerProofWithoutPvMultiPvReason');
    }
    if (record.androidProofCaseIds.any(
      (caseId) => !_capturedAndroidProofIds.contains(caseId),
    )) {
      findings.add('unprovenAndroidProofId');
    }
    if (record.adapterBoundaryRole ==
            DebugOnlyBridgeAnalyzerAdapterBoundaryRole.futureRequirement &&
        record.sourceDiagnosticCaseId != 'phase33m') {
      findings.add('invalidFutureRequirementSource');
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

DebugOnlyBridgeAnalyzerAdapterBoundaryRole _adapterRoleForSourceRow(
  _SelectedGoldenValidationSourceRow row,
) {
  if (row.caseId == _pvMultiPvBoundaryCaseId ||
      row.diagnosticRole == 'proofBoundaryOnly') {
    return DebugOnlyBridgeAnalyzerAdapterBoundaryRole.proofBoundaryOnly;
  }
  if (row.diagnosticRole == 'excludedNegativeGuard' ||
      row.supportAreaIds.contains('quietPreparatoryMove')) {
    return DebugOnlyBridgeAnalyzerAdapterBoundaryRole.excludedNegativeGuard;
  }
  if (row.diagnosticRole == 'warningLimited') {
    return DebugOnlyBridgeAnalyzerAdapterBoundaryRole.warningLimitedCandidate;
  }
  if (row.diagnosticRole == 'contextOnly') {
    return DebugOnlyBridgeAnalyzerAdapterBoundaryRole.contextOnlyCandidate;
  }
  if (row.diagnosticRole == 'coreSupport' &&
      (row.supportAreaIds.contains('tacticalShot') ||
          row.supportAreaIds.contains('materialSacrifice') ||
          row.supportAreaIds.contains('forcedMateThreat') ||
          row.supportAreaIds.contains('queenTrap'))) {
    return DebugOnlyBridgeAnalyzerAdapterBoundaryRole.analyzerInputCandidate;
  }
  if (row.diagnosticRole == 'coreSupport') {
    return DebugOnlyBridgeAnalyzerAdapterBoundaryRole.coreSupportCandidate;
  }
  return DebugOnlyBridgeAnalyzerAdapterBoundaryRole.contextOnlyCandidate;
}

DebugOnlyBridgeAnalyzerAdapterBoundaryRecord _blockedRecord({
  required String recordId,
  required DebugOnlyBridgeAnalyzerAdapterBoundaryRole role,
  required String selectedReason,
  required List<String> blockedBoundaryIds,
}) {
  return DebugOnlyBridgeAnalyzerAdapterBoundaryRecord(
    boundaryRecordId: recordId,
    sourceDiagnosticCaseId: 'phase33m',
    sourceValidationRowId: 'phase33m-boundary-design',
    sourcePhase: 'Phase 33M',
    selectedReason: selectedReason,
    diagnosticRole: 'boundaryDesign',
    adapterBoundaryRole: role,
    supportAreaIds: const <String>['debugOnlyAnalyzerAdapterBoundaryDesign'],
    allowedFieldIds: _allowedFieldIds,
    deniedFieldIds: _deniedFieldIds,
    blockedBoundaryIds: _sorted(blockedBoundaryIds),
    warningReasons: const <String>['boundaryDesignOnlyNoRuntimeWiring'],
    proofLimitReasons: const <String>[],
    androidProofCaseIds: const <String>[],
    ownerProofRequired: false,
    designOnly: true,
    developerOnly: true,
    analyzerUnwired: true,
    activeDeniedFields: const <String>[],
    safetyFlags: const DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(),
    findings: const <String>[],
    recommendation: _phase33NRecommendation,
  );
}

List<DebugOnlyBridgeAnalyzerAdapterBoundaryComponent> _componentsForRecords(
  List<DebugOnlyBridgeAnalyzerAdapterBoundaryRecord> records,
) {
  List<String> idsFor(DebugOnlyBridgeAnalyzerAdapterBoundaryRole role) =>
      records
          .where((record) => record.adapterBoundaryRole == role)
          .map((record) => record.boundaryRecordId)
          .toList(growable: false);

  return <DebugOnlyBridgeAnalyzerAdapterBoundaryComponent>[
    DebugOnlyBridgeAnalyzerAdapterBoundaryComponent(
      componentId: DebugOnlyBridgeAnalyzerAdapterBoundaryComponentId
          .analyzerAdapterInputBoundary,
      recordIds: idsFor(
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.analyzerInputCandidate,
      ),
      status: 'futureInternalCandidateOnlyAnalyzerUnwired',
    ),
    DebugOnlyBridgeAnalyzerAdapterBoundaryComponent(
      componentId: DebugOnlyBridgeAnalyzerAdapterBoundaryComponentId
          .analyzerAdapterCoreSupportBoundary,
      recordIds: idsFor(
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.coreSupportCandidate,
      ),
      status: 'futureCoreSupportCandidateOnly',
    ),
    DebugOnlyBridgeAnalyzerAdapterBoundaryComponent(
      componentId: DebugOnlyBridgeAnalyzerAdapterBoundaryComponentId
          .analyzerAdapterContextBoundary,
      recordIds: idsFor(
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.contextOnlyCandidate,
      ),
      status: 'contextOnly',
    ),
    DebugOnlyBridgeAnalyzerAdapterBoundaryComponent(
      componentId: DebugOnlyBridgeAnalyzerAdapterBoundaryComponentId
          .analyzerAdapterWarningLimitedBoundary,
      recordIds: idsFor(
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.warningLimitedCandidate,
      ),
      status: 'warningLimited',
    ),
    DebugOnlyBridgeAnalyzerAdapterBoundaryComponent(
      componentId: DebugOnlyBridgeAnalyzerAdapterBoundaryComponentId
          .analyzerAdapterProofBoundary,
      recordIds: idsFor(
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.proofBoundaryOnly,
      ),
      status: 'proofBoundaryOnly',
    ),
    DebugOnlyBridgeAnalyzerAdapterBoundaryComponent(
      componentId: DebugOnlyBridgeAnalyzerAdapterBoundaryComponentId
          .analyzerAdapterExcludedNegativeGuardBoundary,
      recordIds: idsFor(
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.excludedNegativeGuard,
      ),
      status: 'excludedNegativeGuardOnly',
    ),
    DebugOnlyBridgeAnalyzerAdapterBoundaryComponent(
      componentId: DebugOnlyBridgeAnalyzerAdapterBoundaryComponentId
          .analyzerAdapterDeniedFieldBoundary,
      recordIds: idsFor(
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.deniedFieldBoundary,
      ),
      status: 'deniedFieldsInactive',
    ),
    DebugOnlyBridgeAnalyzerAdapterBoundaryComponent(
      componentId: DebugOnlyBridgeAnalyzerAdapterBoundaryComponentId
          .analyzerAdapterRuntimeBlockedBoundary,
      recordIds: idsFor(
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.runtimeBlocked,
      ),
      status: 'runtimeBlocked',
    ),
    DebugOnlyBridgeAnalyzerAdapterBoundaryComponent(
      componentId: DebugOnlyBridgeAnalyzerAdapterBoundaryComponentId
          .analyzerAdapterSchedulerBlockedBoundary,
      recordIds: idsFor(
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.schedulerBlocked,
      ),
      status: 'schedulerBlocked',
    ),
    DebugOnlyBridgeAnalyzerAdapterBoundaryComponent(
      componentId: DebugOnlyBridgeAnalyzerAdapterBoundaryComponentId
          .analyzerAdapterPersistenceBlockedBoundary,
      recordIds: idsFor(
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.persistenceBlocked,
      ),
      status: 'persistenceBlocked',
    ),
    DebugOnlyBridgeAnalyzerAdapterBoundaryComponent(
      componentId: DebugOnlyBridgeAnalyzerAdapterBoundaryComponentId
          .analyzerAdapterEngineBlockedBoundary,
      recordIds: idsFor(
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.engineBlocked,
      ),
      status: 'engineBlocked',
    ),
    DebugOnlyBridgeAnalyzerAdapterBoundaryComponent(
      componentId: DebugOnlyBridgeAnalyzerAdapterBoundaryComponentId
          .phase33NRequirementBoundary,
      recordIds: idsFor(
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.futureRequirement,
      ),
      status: _phase33NRecommendation,
    ),
  ];
}

_SelectedGoldenValidationSource _sourceFromSelectedGoldenValidation(
  Object? selectedGoldenValidationResult,
  List<GoldenAnalysisCase> cases,
) {
  if (selectedGoldenValidationResult != null) {
    final map = _objectToJsonMap(selectedGoldenValidationResult);
    if (map != null) {
      final rows =
          ((map['selectedRows'] as List<Object?>?) ?? const <Object?>[])
              .whereType<Map<Object?, Object?>>()
              .map((row) => _SelectedGoldenValidationSourceRow.fromMap(row))
              .toList(growable: false)
            ..sort((a, b) => a.validationRowId.compareTo(b.validationRowId));
      return _SelectedGoldenValidationSource(
        validationStatus: _readString(map, 'validationStatus', 'unknown'),
        safeForPhase33M: map['safeForPhase33M'] == true,
        phase33MRecommendation: _readString(
          map,
          'phase33MRecommendation',
          'unknown',
        ),
        rows: rows,
        knownCaseIds: cases.map((item) => item.id).toSet(),
      );
    }
  }

  final byId = {for (final item in cases) item.id: item};
  final rows = _allSafeSelectedGoldenCaseIds
      .where(byId.containsKey)
      .map(
        (caseId) => _SelectedGoldenValidationSourceRow.fromCase(byId[caseId]!),
      )
      .toList(growable: false);
  return _SelectedGoldenValidationSource(
    validationStatus: 'selectedGoldenDiagnosticValidatedWithWarnings',
    safeForPhase33M: true,
    phase33MRecommendation:
        'proceedToDebugOnlyBridgeAnalyzerAdapterBoundaryDesign',
    rows: rows,
    knownCaseIds: cases.map((item) => item.id).toSet(),
  );
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

class _SelectedGoldenValidationSource {
  const _SelectedGoldenValidationSource({
    required this.validationStatus,
    required this.safeForPhase33M,
    required this.phase33MRecommendation,
    required this.rows,
    required this.knownCaseIds,
  });

  final String validationStatus;
  final bool safeForPhase33M;
  final String phase33MRecommendation;
  final List<_SelectedGoldenValidationSourceRow> rows;
  final Set<String> knownCaseIds;
}

class _SelectedGoldenValidationSourceRow {
  const _SelectedGoldenValidationSourceRow({
    required this.validationRowId,
    required this.caseId,
    required this.sourcePhase,
    required this.selectedReason,
    required this.diagnosticRole,
    required this.supportAreaIds,
    required this.blockedBoundaryIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.androidProofCaseIds,
    required this.ownerProofRequired,
    required this.activeDeniedFields,
  });

  factory _SelectedGoldenValidationSourceRow.fromMap(
    Map<Object?, Object?> map,
  ) {
    return _SelectedGoldenValidationSourceRow(
      validationRowId: _readString(map, 'validationRowId', 'unknown-row'),
      caseId: _readString(map, 'caseId', 'unknown-case'),
      sourcePhase: _readString(map, 'sourcePhase', 'unknown'),
      selectedReason: _readString(map, 'selectedReason', 'not provided'),
      diagnosticRole: _readString(map, 'diagnosticRole', 'contextOnly'),
      supportAreaIds: _readStringList(map['supportAreaIds']),
      blockedBoundaryIds: _readStringList(map['blockedBoundaryIds']),
      warningReasons: _readStringList(map['warningReasons']),
      proofLimitReasons: _readStringList(map['proofLimitReasons']),
      androidProofCaseIds: _readStringList(map['androidProofCaseIds']),
      ownerProofRequired: map['ownerProofRequired'] == true,
      activeDeniedFields: _readStringList(map['activeDeniedFields']),
    );
  }

  factory _SelectedGoldenValidationSourceRow.fromCase(GoldenAnalysisCase item) {
    final role = _diagnosticRoleForCase(item);
    final proofLimitReasons = <String>[
      if (_phase32ECaseIds.contains(item.id)) 'phase32ECaseIsNotCapturedProof',
      if (item.id == _pvMultiPvBoundaryCaseId)
        'pvMultiPvBoundaryWatchListOnlyNoOwnerProof',
      if (role == 'excludedNegativeGuard')
        'quietPreparatoryExcludedFromActiveCoreOutput',
    ]..sort();
    return _SelectedGoldenValidationSourceRow(
      validationRowId: 'selected-golden-${item.id}',
      caseId: item.id,
      sourcePhase: _sourcePhaseForCase(item),
      selectedReason: 'fallback selected Golden validation source row',
      diagnosticRole: role,
      supportAreaIds: _supportAreaIdsForCase(item),
      blockedBoundaryIds: _selectedGoldenAlwaysBlockedBoundaryIds,
      warningReasons: const <String>[
        'developerOnlySelectedGoldenDiagnosticNoEngineExecution',
      ],
      proofLimitReasons: proofLimitReasons,
      androidProofCaseIds:
          _capturedAndroidProofIds.contains(item.id) &&
              !_phase32ECaseIds.contains(item.id)
          ? <String>[item.id]
          : const <String>[],
      ownerProofRequired: false,
      activeDeniedFields: const <String>[],
    );
  }

  final String validationRowId;
  final String caseId;
  final String sourcePhase;
  final String selectedReason;
  final String diagnosticRole;
  final List<String> supportAreaIds;
  final List<String> blockedBoundaryIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofCaseIds;
  final bool ownerProofRequired;
  final List<String> activeDeniedFields;
}

bool _isQuietRecord(DebugOnlyBridgeAnalyzerAdapterBoundaryRecord record) {
  return record.diagnosticRole == 'excludedNegativeGuard' ||
      record.supportAreaIds.contains('quietPreparatoryMove') ||
      record.proofLimitReasons.contains(
        'quietPreparatoryExcludedFromActiveCoreOutput',
      );
}

bool _isBlockerFinding(String finding) => !finding.startsWith('warning:');

bool _isCriticalFinding(String finding) =>
    finding.startsWith('reportTextLeak:');

int _countRole(
  List<DebugOnlyBridgeAnalyzerAdapterBoundaryRecord> records,
  DebugOnlyBridgeAnalyzerAdapterBoundaryRole role,
) {
  return records.where((record) => record.adapterBoundaryRole == role).length;
}

String _renderRecordsForLeakCheck(
  List<DebugOnlyBridgeAnalyzerAdapterBoundaryRecord> records,
) {
  return const JsonEncoder.withIndent(
    '  ',
  ).convert(records.map((record) => record.toJson()).toList(growable: false));
}

String _ids(Iterable<String> values) =>
    values.isEmpty ? '-' : values.join(', ');

List<String> _sorted(Iterable<String> values) =>
    values.toSet().toList(growable: false)..sort();

String _readString(Map<Object?, Object?> map, String key, String fallback) {
  final value = map[key];
  if (value is String && value.trim().isNotEmpty) return value;
  return fallback;
}

List<String> _readStringList(Object? value) {
  if (value is List<Object?>) {
    return _sorted(value.whereType<String>());
  }
  if (value is Iterable<Object?>) {
    return _sorted(value.whereType<String>());
  }
  return const <String>[];
}

String _diagnosticRoleForCase(GoldenAnalysisCase item) {
  if (_isQuietPreparatoryCase(item)) return 'excludedNegativeGuard';
  if (item.id == _pvMultiPvBoundaryCaseId) return 'proofBoundaryOnly';
  if (item.category == GoldenAnalysisCategory.budgetPressure) {
    return 'warningLimited';
  }
  if (item.category == GoldenAnalysisCategory.endgamePrecision ||
      item.category == GoldenAnalysisCategory.openingKnownSkip ||
      item.category == GoldenAnalysisCategory.forcedMoveSkip) {
    return 'contextOnly';
  }
  return 'coreSupport';
}

bool _isQuietPreparatoryCase(GoldenAnalysisCase item) {
  return item.category == GoldenAnalysisCategory.quietPreparatoryMove ||
      item.motifTags.any(
        (tag) =>
            tag == GoldenMotifTag.quietMove ||
            tag == GoldenMotifTag.quietPreparatoryMove,
      );
}

List<String> _supportAreaIdsForCase(GoldenAnalysisCase item) {
  return _sorted(
    <String>[
      item.category.wire,
      item.sourceType.wire,
      item.evidenceIntent.wire,
      ...item.motifTags.map((tag) => tag.wire),
      if (_phase32ECaseIds.contains(item.id)) 'phase32E',
      if (item.id == _pvMultiPvBoundaryCaseId) 'pvMultiPvBoundary',
      if (_capturedAndroidProofIds.contains(item.id)) 'capturedAndroidProof',
    ].where((value) => value.trim().isNotEmpty),
  );
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

const _phase33NRecommendation =
    'validateDebugOnlyBridgeAnalyzerAdapterBoundaryDesign';

const _pvMultiPvBoundaryCaseId = 'pv-multipv-support-boundary-32e';

const _allSafeSelectedGoldenCaseIds = <String>[
  'queen-win-major-swing',
  'forcing-line-variation-hard-case',
  'sacrifice-compensation-hard-case',
  'king-safety-mating-net-pressure-32e',
  'endgame-precision-candidate-spread-32e',
  'budget-pressure-wide-candidate-32e',
  _pvMultiPvBoundaryCaseId,
  'simple-tactical-capture-check',
  'mate-threat-fast-evidence',
  'material-sacrifice-compensation',
  'king-safety-mating-net-hard-case',
  'technical-endgame-conservative',
  'budget-pressure-candidates',
  'quiet-preparatory-uncertain',
  'quiet-preparatory-hard-case',
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

const _allowedFieldIds = <String>[
  'androidProofCaseIds',
  'blockedBoundaryIds',
  'caseId',
  'diagnosticRole',
  'proofLimitReasons',
  'selectedReason',
  'sourcePhase',
  'supportAreaIds',
  'warningReasons',
];

const _deniedFieldIds = <String>[
  'acpl',
  'aggregateScore',
  'backendOutput',
  'bestGoodInaccuracyMistakeBlunderStyleLabels',
  'brilliantGreatMissStyleLabels',
  'classifierLabels',
  'cpLoss',
  'directEngineCall',
  'engineResults',
  'finalMoveLabel',
  'moveRanking',
  'numericMoveScore',
  'officialAccuracy',
  'officialMetrics',
  'persistenceOutput',
  'productLabel',
  'productOutput',
  'pvDump',
  'rawUci',
  'schedulerExecution',
  'stockfishCommand',
  'uiOutput',
  'winProbability',
];

const _selectedGoldenAlwaysBlockedBoundaryIds = <String>[
  'androidCollectorExecution',
  'backendTarget',
  'classifierLabels',
  'cpLoss',
  'directEngineCall',
  'engineResults',
  'finalMoveLabels',
  'moveRanking',
  'numericMoveScores',
  'officialMetrics',
  'persistenceWrite',
  'productOutput',
  'pvDump',
  'rawUci',
  'schedulerExecution',
  'stockfishCommand',
  'uiTarget',
  'winProbability',
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

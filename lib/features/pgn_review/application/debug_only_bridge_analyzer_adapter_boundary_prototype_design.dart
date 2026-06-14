import 'dart:convert';

import 'debug_only_bridge_analyzer_adapter_boundary_design.dart';
import 'debug_only_bridge_analyzer_adapter_boundary_design_validation.dart';
import 'golden_analysis_suite.dart';

const debugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignReportVersion =
    'debug-only-bridge-analyzer-adapter-boundary-prototype-design-v1';

enum DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignStatus {
  prototypeDesignReadyWithWarnings('prototypeDesignReadyWithWarnings'),
  prototypeDesignReadyClean('prototypeDesignReadyClean'),
  blockedByUnsafeBoundaryValidation('blockedByUnsafeBoundaryValidation'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidPrototypeDesign('invalidPrototypeDesign');

  const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignStatus(this.wire);

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole {
  analyzerAdapterPrototypeInputPacket('analyzerAdapterPrototypeInputPacket'),
  analyzerAdapterPrototypeContextPacket(
    'analyzerAdapterPrototypeContextPacket',
  ),
  analyzerAdapterPrototypeWarningLimitedPacket(
    'analyzerAdapterPrototypeWarningLimitedPacket',
  ),
  analyzerAdapterPrototypeProofBoundaryPacket(
    'analyzerAdapterPrototypeProofBoundaryPacket',
  ),
  analyzerAdapterPrototypeExcludedGuardPacket(
    'analyzerAdapterPrototypeExcludedGuardPacket',
  ),
  analyzerAdapterPrototypeDeniedFieldPacket(
    'analyzerAdapterPrototypeDeniedFieldPacket',
  ),
  analyzerAdapterPrototypeFutureRequirementPacket(
    'analyzerAdapterPrototypeFutureRequirementPacket',
  );

  const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole(this.wire);

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignRecord {
  const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignRecord({
    required this.prototypeRecordId,
    required this.sourceValidationRowId,
    required this.sourceBoundaryRecordId,
    required this.sourceDiagnosticCaseId,
    required this.sourcePhase,
    required this.diagnosticRole,
    required this.adapterBoundaryRole,
    required this.prototypePacketRole,
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
    required this.safetyFlags,
    required this.findings,
    required this.recommendation,
  });

  final String prototypeRecordId;
  final String sourceValidationRowId;
  final String sourceBoundaryRecordId;
  final String sourceDiagnosticCaseId;
  final String sourcePhase;
  final String diagnosticRole;
  final String adapterBoundaryRole;
  final DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
  prototypePacketRole;
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
  final DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags safetyFlags;
  final List<String> findings;
  final String recommendation;

  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignRecord copyWith({
    String? prototypeRecordId,
    String? sourceValidationRowId,
    String? sourceBoundaryRecordId,
    String? sourceDiagnosticCaseId,
    String? sourcePhase,
    String? diagnosticRole,
    String? adapterBoundaryRole,
    DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole?
    prototypePacketRole,
    bool? designOnly,
    bool? developerOnly,
    bool? analyzerUnwired,
    bool? futureInternalOnly,
    bool? contextOnly,
    bool? warningLimited,
    bool? proofBoundaryOnly,
    bool? excludedNegativeGuard,
    bool? inactiveDeniedFieldPacket,
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    List<String>? blockedBoundaryIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? androidProofCaseIds,
    bool? ownerProofRequired,
    List<String>? activeDeniedFields,
    DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags? safetyFlags,
    List<String>? findings,
    String? recommendation,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignRecord(
      prototypeRecordId: prototypeRecordId ?? this.prototypeRecordId,
      sourceValidationRowId:
          sourceValidationRowId ?? this.sourceValidationRowId,
      sourceBoundaryRecordId:
          sourceBoundaryRecordId ?? this.sourceBoundaryRecordId,
      sourceDiagnosticCaseId:
          sourceDiagnosticCaseId ?? this.sourceDiagnosticCaseId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      diagnosticRole: diagnosticRole ?? this.diagnosticRole,
      adapterBoundaryRole: adapterBoundaryRole ?? this.adapterBoundaryRole,
      prototypePacketRole: prototypePacketRole ?? this.prototypePacketRole,
      designOnly: designOnly ?? this.designOnly,
      developerOnly: developerOnly ?? this.developerOnly,
      analyzerUnwired: analyzerUnwired ?? this.analyzerUnwired,
      futureInternalOnly: futureInternalOnly ?? this.futureInternalOnly,
      contextOnly: contextOnly ?? this.contextOnly,
      warningLimited: warningLimited ?? this.warningLimited,
      proofBoundaryOnly: proofBoundaryOnly ?? this.proofBoundaryOnly,
      excludedNegativeGuard:
          excludedNegativeGuard ?? this.excludedNegativeGuard,
      inactiveDeniedFieldPacket:
          inactiveDeniedFieldPacket ?? this.inactiveDeniedFieldPacket,
      allowedFieldIds: allowedFieldIds ?? this.allowedFieldIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      activeDeniedFields: activeDeniedFields ?? this.activeDeniedFields,
      safetyFlags: safetyFlags ?? this.safetyFlags,
      findings: findings ?? this.findings,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'prototypeRecordId': prototypeRecordId,
      'sourceValidationRowId': sourceValidationRowId,
      'sourceBoundaryRecordId': sourceBoundaryRecordId,
      'sourceDiagnosticCaseId': sourceDiagnosticCaseId,
      'sourcePhase': sourcePhase,
      'diagnosticRole': diagnosticRole,
      'adapterBoundaryRole': adapterBoundaryRole,
      'prototypePacketRole': prototypePacketRole.wire,
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
      'safetyFlags': safetyFlags.toJson(),
      'findings': findings,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignResult {
  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignResult({
    required this.status,
    required this.sourceBoundaryValidationStatus,
    required this.sourceBoundaryValidationSafeForPhase33O,
    required this.sourceBoundaryValidationRecommendation,
    required this.prototypeRecords,
    required this.reportFindings,
    required this.safeForPhase33P,
    required this.phase33PRecommendation,
  }) : totalPrototypeRecords = prototypeRecords.length,
       inputPacketDesignCount = _countPacketRole(
         prototypeRecords,
         DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
             .analyzerAdapterPrototypeInputPacket,
       ),
       contextPacketDesignCount = _countPacketRole(
         prototypeRecords,
         DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
             .analyzerAdapterPrototypeContextPacket,
       ),
       warningLimitedPacketDesignCount = _countPacketRole(
         prototypeRecords,
         DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
             .analyzerAdapterPrototypeWarningLimitedPacket,
       ),
       proofBoundaryPacketDesignCount = _countPacketRole(
         prototypeRecords,
         DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
             .analyzerAdapterPrototypeProofBoundaryPacket,
       ),
       excludedGuardPacketDesignCount = _countPacketRole(
         prototypeRecords,
         DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
             .analyzerAdapterPrototypeExcludedGuardPacket,
       ),
       deniedFieldPacketDesignCount = _countPacketRole(
         prototypeRecords,
         DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
             .analyzerAdapterPrototypeDeniedFieldPacket,
       ),
       futureRequirementPacketDesignCount = _countPacketRole(
         prototypeRecords,
         DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
             .analyzerAdapterPrototypeFutureRequirementPacket,
       ),
       blockerCount = prototypeRecords
           .where((record) => record.findings.any(_isBlockerFinding))
           .length,
       criticalCount = reportFindings.where(_isCriticalFinding).length,
       activeDeniedFieldCount = prototypeRecords.fold<int>(
         0,
         (total, record) => total + record.activeDeniedFields.length,
       ),
       productOutputCount = prototypeRecords
           .where((record) => record.safetyFlags.isProductOutput)
           .length,
       labelLeakCount = prototypeRecords
           .where((record) => record.safetyFlags.emitsClassifierLabel)
           .length,
       finalLabelLeakCount = prototypeRecords
           .where((record) => record.safetyFlags.emitsFinalLabel)
           .length,
       scoreLeakCount = prototypeRecords
           .where(
             (record) =>
                 record.safetyFlags.hasNumericScore ||
                 record.safetyFlags.hasAggregateScore,
           )
           .length,
       metricLeakCount = prototypeRecords
           .where((record) => record.safetyFlags.emitsOfficialMetric)
           .length,
       cpLossLeakCount = prototypeRecords
           .where((record) => record.safetyFlags.exposesCpLoss)
           .length,
       winProbabilityLeakCount = prototypeRecords
           .where((record) => record.safetyFlags.exposesWinProbability)
           .length,
       moveRankingLeakCount = prototypeRecords
           .where((record) => record.safetyFlags.ranksMoves)
           .length,
       uiTargetCount = prototypeRecords
           .where((record) => record.safetyFlags.targetsUi)
           .length,
       backendTargetCount = prototypeRecords
           .where((record) => record.safetyFlags.targetsBackend)
           .length,
       persistenceWriteCount = prototypeRecords
           .where((record) => record.safetyFlags.writesPersistence)
           .length,
       engineCallCount = prototypeRecords
           .where((record) => record.safetyFlags.callsEngine)
           .length,
       schedulerExecutionCount = prototypeRecords
           .where((record) => record.safetyFlags.executesScheduler)
           .length,
       analyzerWiringCount = prototypeRecords
           .where((record) => record.safetyFlags.wiresAnalyzer)
           .length,
       stockfishCommandLeakCount = prototypeRecords
           .where((record) => record.safetyFlags.exposesStockfishCommand)
           .length,
       rawUciLeakCount = prototypeRecords
           .where((record) => record.safetyFlags.exposesRawUci)
           .length,
       pvDumpLeakCount = prototypeRecords
           .where((record) => record.safetyFlags.exposesPvDump)
           .length,
       unprovenAndroidProofCount = prototypeRecords
           .where(
             (record) => record.androidProofCaseIds.any(
               (caseId) => !_capturedAndroidProofIds.contains(caseId),
             ),
           )
           .length,
       phase32EProofClaimCount = prototypeRecords
           .where(
             (record) =>
                 _phase32ECaseIds.contains(record.sourceDiagnosticCaseId) &&
                 record.androidProofCaseIds.isNotEmpty,
           )
           .length,
       ownerProofQueueCount = prototypeRecords
           .where((record) => record.ownerProofRequired)
           .length {
    unsafeCount =
        prototypeRecords
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

  final DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignStatus status;
  final String sourceBoundaryValidationStatus;
  final bool sourceBoundaryValidationSafeForPhase33O;
  final String sourceBoundaryValidationRecommendation;
  final List<DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignRecord>
  prototypeRecords;
  final List<String> reportFindings;
  final bool safeForPhase33P;
  final String phase33PRecommendation;
  final int totalPrototypeRecords;
  final int inputPacketDesignCount;
  final int contextPacketDesignCount;
  final int warningLimitedPacketDesignCount;
  final int proofBoundaryPacketDesignCount;
  final int excludedGuardPacketDesignCount;
  final int deniedFieldPacketDesignCount;
  final int futureRequirementPacketDesignCount;
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
      !safeForPhase33P ||
      !sourceBoundaryValidationSafeForPhase33O;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln(
        '# Debug-Only Bridge Analyzer Adapter Boundary Prototype Design',
      )
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignReportVersion',
      )
      ..writeln('- prototype design status: ${status.wire}')
      ..writeln(
        '- source boundary validation status: $sourceBoundaryValidationStatus',
      )
      ..writeln('- safe for Phase 33P: $safeForPhase33P')
      ..writeln('- Phase 33P recommendation: $phase33PRecommendation')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- analyzer wiring count: $analyzerWiringCount')
      ..writeln('- engine call count: $engineCallCount')
      ..writeln('- scheduler execution count: $schedulerExecutionCount')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- product output count: $productOutputCount')
      ..writeln()
      ..writeln('## Prototype Packet Summary')
      ..writeln(
        '- analyzerAdapterPrototypeInputPacket: $inputPacketDesignCount',
      )
      ..writeln(
        '- analyzerAdapterPrototypeContextPacket: $contextPacketDesignCount',
      )
      ..writeln(
        '- analyzerAdapterPrototypeWarningLimitedPacket: '
        '$warningLimitedPacketDesignCount',
      )
      ..writeln(
        '- analyzerAdapterPrototypeProofBoundaryPacket: '
        '$proofBoundaryPacketDesignCount',
      )
      ..writeln(
        '- analyzerAdapterPrototypeExcludedGuardPacket: '
        '$excludedGuardPacketDesignCount',
      )
      ..writeln(
        '- analyzerAdapterPrototypeDeniedFieldPacket: '
        '$deniedFieldPacketDesignCount',
      )
      ..writeln(
        '- analyzerAdapterPrototypeFutureRequirementPacket: '
        '$futureRequirementPacketDesignCount',
      )
      ..writeln()
      ..writeln('## Prototype Record Table')
      ..writeln(
        '| Record | Source row | Case ID | Diagnostic role | Boundary role | '
        'Prototype packet | Future internal | Context-only | '
        'Warning-limited | Proof-boundary | Excluded guard | '
        'Inactive denied | Active denied fields | Findings | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final record in prototypeRecords) {
      buffer.writeln(
        '| ${record.prototypeRecordId} | ${record.sourceValidationRowId} | '
        '${record.sourceDiagnosticCaseId} | ${record.diagnosticRole} | '
        '${record.adapterBoundaryRole} | ${record.prototypePacketRole.wire} | '
        '${record.futureInternalOnly} | ${record.contextOnly} | '
        '${record.warningLimited} | ${record.proofBoundaryOnly} | '
        '${record.excludedNegativeGuard} | '
        '${record.inactiveDeniedFieldPacket} | '
        '${_ids(record.activeDeniedFields)} | ${_ids(record.findings)} | '
        '${record.recommendation} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Role Mapping Behavior')
      ..writeln(
        '- tactical/material/forcing boundary rows map only to future '
        'internal prototype input packet designs.',
      )
      ..writeln('- context rows remain context-only packet designs.')
      ..writeln('- warning-limited rows remain warning-limited packet designs.')
      ..writeln(
        '- PV/MultiPV rows remain proof-boundary/watch-list packet designs.',
      )
      ..writeln(
        '- quiet/preparatory rows remain excluded negative guard packet designs.',
      )
      ..writeln()
      ..writeln('## Denied Field Packet Design')
      ..writeln(
        '- denied field packet design count: $deniedFieldPacketDesignCount',
      )
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln(
        '- denied fields remain blocked boundary identifiers only: '
        '${_ids(_deniedFieldIds)}',
      )
      ..writeln()
      ..writeln('## Runtime, Scheduler, Engine, And Analyzer Boundary')
      ..writeln('- analyzer wiring count: $analyzerWiringCount')
      ..writeln('- engine call count: $engineCallCount')
      ..writeln('- scheduler execution count: $schedulerExecutionCount')
      ..writeln('- persistence write count: $persistenceWriteCount')
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
      ..writeln('## Phase 33P Requirement')
      ..writeln(
        '- next checkpoint: '
        'validateDebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign',
      )
      ..writeln()
      ..writeln('## Report Findings')
      ..writeln('- findings: ${_ids(reportFindings)}');
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignReportVersion,
      'prototypeDesignStatus': status.wire,
      'sourceBoundaryValidationStatus': sourceBoundaryValidationStatus,
      'sourceBoundaryValidationSafeForPhase33O':
          sourceBoundaryValidationSafeForPhase33O,
      'sourceBoundaryValidationRecommendation':
          sourceBoundaryValidationRecommendation,
      'safeForPhase33P': safeForPhase33P,
      'phase33PRecommendation': phase33PRecommendation,
      'counts': <String, Object?>{
        'totalPrototypeRecords': totalPrototypeRecords,
        'inputPacketDesignCount': inputPacketDesignCount,
        'contextPacketDesignCount': contextPacketDesignCount,
        'warningLimitedPacketDesignCount': warningLimitedPacketDesignCount,
        'proofBoundaryPacketDesignCount': proofBoundaryPacketDesignCount,
        'excludedGuardPacketDesignCount': excludedGuardPacketDesignCount,
        'deniedFieldPacketDesignCount': deniedFieldPacketDesignCount,
        'futureRequirementPacketDesignCount':
            futureRequirementPacketDesignCount,
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
      'capturedAndroidProofIds': _capturedAndroidProofIds.toList()..sort(),
      'prototypeRecords': prototypeRecords
          .map((record) => record.toJson())
          .toList(growable: false),
      'reportFindings': reportFindings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign {
  const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign({
    this.validator =
        const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidator(),
  });

  final DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidator
  validator;

  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignResult evaluate({
    DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationResult?
    boundaryValidationResult,
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  }) {
    final source =
        boundaryValidationResult ??
        const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidation().evaluate(
          cases: cases,
        );
    final knownCaseIds = cases.map((caseData) => caseData.id).toSet();
    final records = source.validationRows
        .map(_recordFromValidationRow)
        .map(
          (record) => record.copyWith(
            findings: validator.validateRecord(
              record,
              knownCaseIds: knownCaseIds,
            ),
          ),
        )
        .toList(growable: false);
    final reportFindings = validator.validateReportText(
      _renderRecordsForLeakCheck(records),
    );
    final hasFutureRequirement = records.any(
      (record) =>
          record.prototypePacketRole ==
          DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
              .analyzerAdapterPrototypeFutureRequirementPacket,
    );
    final sourceSafe =
        source.safeForPhase33O &&
        source.phase33ORecommendation ==
            'proceedToDebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign' &&
        !source.hasUnsafePolicyViolation;
    final hasRecordFindings = records.any(
      (record) => record.findings.isNotEmpty,
    );
    final safe =
        sourceSafe &&
        hasFutureRequirement &&
        !hasRecordFindings &&
        reportFindings.isEmpty;
    final status = !sourceSafe
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignStatus
              .blockedByUnsafeBoundaryValidation
        : !hasFutureRequirement
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignStatus
              .invalidPrototypeDesign
        : hasRecordFindings || reportFindings.isNotEmpty
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignStatus
              .blockedByPolicyBoundary
        : records.any(
            (record) =>
                record.warningReasons.isNotEmpty ||
                record.proofLimitReasons.isNotEmpty,
          )
        ? DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignStatus
              .prototypeDesignReadyWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignStatus
              .prototypeDesignReadyClean;

    return DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignResult(
      status: status,
      sourceBoundaryValidationStatus: source.status.wire,
      sourceBoundaryValidationSafeForPhase33O: source.safeForPhase33O,
      sourceBoundaryValidationRecommendation: source.phase33ORecommendation,
      prototypeRecords: records,
      reportFindings: reportFindings,
      safeForPhase33P: safe,
      phase33PRecommendation: safe
          ? _phase33PRecommendation
          : 'blockedByUnsafeAnalyzerAdapterBoundaryPrototypeDesign',
    );
  }

  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignRecord
  _recordFromValidationRow(
    DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationRow row,
  ) {
    final role = _packetRoleForBoundaryRole(row.adapterBoundaryRole);
    return DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignRecord(
      prototypeRecordId: 'phase33o-${row.validationRowId}',
      sourceValidationRowId: row.validationRowId,
      sourceBoundaryRecordId: row.sourceBoundaryRecordId,
      sourceDiagnosticCaseId: row.sourceDiagnosticCaseId,
      sourcePhase: row.sourcePhase,
      diagnosticRole: row.diagnosticRole,
      adapterBoundaryRole: row.adapterBoundaryRole,
      prototypePacketRole: role,
      designOnly: true,
      developerOnly: true,
      analyzerUnwired: true,
      futureInternalOnly:
          role ==
          DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
              .analyzerAdapterPrototypeInputPacket,
      contextOnly:
          role ==
          DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
              .analyzerAdapterPrototypeContextPacket,
      warningLimited:
          role ==
          DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
              .analyzerAdapterPrototypeWarningLimitedPacket,
      proofBoundaryOnly:
          role ==
          DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
              .analyzerAdapterPrototypeProofBoundaryPacket,
      excludedNegativeGuard:
          role ==
          DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
              .analyzerAdapterPrototypeExcludedGuardPacket,
      inactiveDeniedFieldPacket:
          role ==
          DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
              .analyzerAdapterPrototypeDeniedFieldPacket,
      allowedFieldIds: _sorted(row.allowedFieldIds),
      deniedFieldIds: _sorted(row.deniedFieldIds),
      blockedBoundaryIds: _sorted(row.blockedBoundaryIds),
      warningReasons: _sorted(row.warningReasons),
      proofLimitReasons: _sorted(row.proofLimitReasons),
      androidProofCaseIds: _sorted(row.androidProofCaseIds),
      ownerProofRequired: row.ownerProofRequired,
      activeDeniedFields: _sorted(row.activeDeniedFields),
      safetyFlags: const DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(),
      findings: const <String>[],
      recommendation: _phase33PRecommendation,
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidator {
  const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidator();

  List<String> validateRecord(
    DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignRecord record, {
    required Set<String> knownCaseIds,
  }) {
    final findings = <String>[];
    final knownSyntheticRecord =
        record.sourceDiagnosticCaseId == 'phase33m' ||
        record.sourceDiagnosticCaseId.startsWith('phase33m-') ||
        record.sourceDiagnosticCaseId.startsWith('phase33o-');
    if (!knownSyntheticRecord &&
        !knownCaseIds.contains(record.sourceDiagnosticCaseId)) {
      findings.add('unknownBoundaryValidationCase');
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
    if (_isInputPacket(record) && !record.futureInternalOnly) {
      findings.add('inputPacketNotFutureInternalOnly');
    }
    if (record.adapterBoundaryRole ==
            DebugOnlyBridgeAnalyzerAdapterBoundaryRole
                .contextOnlyCandidate
                .wire &&
        !record.contextOnly) {
      findings.add('contextOnlyPromoted');
    }
    if (record.adapterBoundaryRole ==
            DebugOnlyBridgeAnalyzerAdapterBoundaryRole
                .warningLimitedCandidate
                .wire &&
        !record.warningLimited) {
      findings.add('warningLimitedPromoted');
    }
    if ((record.adapterBoundaryRole ==
                DebugOnlyBridgeAnalyzerAdapterBoundaryRole
                    .proofBoundaryOnly
                    .wire ||
            record.sourceDiagnosticCaseId == _pvMultiPvBoundaryCaseId) &&
        !record.proofBoundaryOnly) {
      findings.add('proofBoundaryPromoted');
    }
    if (_isQuietRecord(record) && !record.excludedNegativeGuard) {
      findings.add('quietPreparatoryPromotedToPrototypeInput');
    }
    if (_phase32ECaseIds.contains(record.sourceDiagnosticCaseId) &&
        record.androidProofCaseIds.isNotEmpty) {
      findings.add('phase32ECapturedAndroidProofClaim');
    }
    if (record.sourceDiagnosticCaseId == _pvMultiPvBoundaryCaseId &&
        record.androidProofCaseIds.isNotEmpty) {
      findings.add('pvMultiPvCapturedProofClaim');
    }
    if (record.ownerProofRequired &&
        !record.proofLimitReasons.any((reason) => reason.contains('pv'))) {
      findings.add('ownerProofWithoutPvMultiPvReason');
    }
    if (record.androidProofCaseIds.any(
      (caseId) => !_capturedAndroidProofIds.contains(caseId),
    )) {
      findings.add('unprovenAndroidProofId');
    }
    if (_isDeniedOrBlockedBoundary(record.adapterBoundaryRole) &&
        !record.inactiveDeniedFieldPacket) {
      findings.add('blockedBoundaryPromoted');
    }
    if (record.adapterBoundaryRole ==
            DebugOnlyBridgeAnalyzerAdapterBoundaryRole.futureRequirement.wire &&
        record.prototypePacketRole !=
            DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
                .analyzerAdapterPrototypeFutureRequirementPacket) {
      findings.add('missingPhase33PPrototypeValidationRequirement');
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

DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
_packetRoleForBoundaryRole(String adapterBoundaryRole) {
  if (adapterBoundaryRole ==
          DebugOnlyBridgeAnalyzerAdapterBoundaryRole
              .analyzerInputCandidate
              .wire ||
      adapterBoundaryRole ==
          DebugOnlyBridgeAnalyzerAdapterBoundaryRole
              .coreSupportCandidate
              .wire) {
    return DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
        .analyzerAdapterPrototypeInputPacket;
  }
  if (adapterBoundaryRole ==
      DebugOnlyBridgeAnalyzerAdapterBoundaryRole.contextOnlyCandidate.wire) {
    return DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
        .analyzerAdapterPrototypeContextPacket;
  }
  if (adapterBoundaryRole ==
      DebugOnlyBridgeAnalyzerAdapterBoundaryRole.warningLimitedCandidate.wire) {
    return DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
        .analyzerAdapterPrototypeWarningLimitedPacket;
  }
  if (adapterBoundaryRole ==
      DebugOnlyBridgeAnalyzerAdapterBoundaryRole.proofBoundaryOnly.wire) {
    return DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
        .analyzerAdapterPrototypeProofBoundaryPacket;
  }
  if (adapterBoundaryRole ==
      DebugOnlyBridgeAnalyzerAdapterBoundaryRole.excludedNegativeGuard.wire) {
    return DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
        .analyzerAdapterPrototypeExcludedGuardPacket;
  }
  if (adapterBoundaryRole ==
      DebugOnlyBridgeAnalyzerAdapterBoundaryRole.futureRequirement.wire) {
    return DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
        .analyzerAdapterPrototypeFutureRequirementPacket;
  }
  return DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
      .analyzerAdapterPrototypeDeniedFieldPacket;
}

int _countPacketRole(
  Iterable<DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignRecord> records,
  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole role,
) {
  return records.where((record) => record.prototypePacketRole == role).length;
}

bool _isInputPacket(
  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignRecord record,
) {
  return record.prototypePacketRole ==
      DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
          .analyzerAdapterPrototypeInputPacket;
}

bool _isQuietRecord(
  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignRecord record,
) {
  return record.diagnosticRole == 'excludedNegativeGuard' ||
      record.blockedBoundaryIds.contains('quietPreparatoryCoreActivation') ||
      record.proofLimitReasons.contains(
        'quietPreparatoryExcludedFromActiveCoreOutput',
      );
}

bool _isDeniedOrBlockedBoundary(String adapterBoundaryRole) {
  return adapterBoundaryRole ==
          DebugOnlyBridgeAnalyzerAdapterBoundaryRole.deniedFieldBoundary.wire ||
      adapterBoundaryRole ==
          DebugOnlyBridgeAnalyzerAdapterBoundaryRole.runtimeBlocked.wire ||
      adapterBoundaryRole ==
          DebugOnlyBridgeAnalyzerAdapterBoundaryRole.schedulerBlocked.wire ||
      adapterBoundaryRole ==
          DebugOnlyBridgeAnalyzerAdapterBoundaryRole.persistenceBlocked.wire ||
      adapterBoundaryRole ==
          DebugOnlyBridgeAnalyzerAdapterBoundaryRole.engineBlocked.wire;
}

String _renderRecordsForLeakCheck(
  Iterable<DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignRecord> records,
) {
  return records
      .map(
        (record) => [
          record.prototypeRecordId,
          record.sourceDiagnosticCaseId,
          record.diagnosticRole,
          record.adapterBoundaryRole,
          record.prototypePacketRole.wire,
          ...record.blockedBoundaryIds,
          ...record.warningReasons,
          ...record.proofLimitReasons,
          ...record.findings,
        ].join(' '),
      )
      .join('\n');
}

List<String> _sorted(Iterable<String> values) {
  return values.toSet().toList(growable: false)..sort();
}

bool _isBlockerFinding(String finding) =>
    !finding.startsWith('warning:') && !finding.startsWith('proofLimit:');

bool _isCriticalFinding(String finding) =>
    finding.startsWith('reportTextLeak:');

String _ids(Iterable<String> values) =>
    values.isEmpty ? '-' : values.join(', ');

const _phase33PRecommendation =
    'validateDebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign';

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

const _deniedFieldIds = <String>{
  'productLabel',
  'finalMoveLabel',
  'classifierLabelFamily',
  'brilliantGreatMissClassifier',
  'bestGoodInaccuracyMistakeBlunder',
  'numericMoveScore',
  'aggregateScore',
  'officialAccuracy',
  'officialAcpl',
  'cpLoss',
  'winProbability',
  'moveRanking',
  'uiTarget',
  'backendTarget',
  'persistenceWrite',
  'directEngineCall',
  'schedulerExecution',
  'analyzerWiring',
  'stockfishCommand',
  'rawUci',
  'pvDump',
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

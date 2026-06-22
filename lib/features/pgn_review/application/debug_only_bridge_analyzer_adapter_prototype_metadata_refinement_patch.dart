import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_patch_set_diagnostic.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchVersion =
    'debug-only-bridge-analyzer-adapter-prototype-metadata-refinement-patch-v1';

enum DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchStatus {
  analyzerAdapterPrototypeMetadataRefinementPatchAppliedWithWarnings(
    'analyzerAdapterPrototypeMetadataRefinementPatchAppliedWithWarnings',
  ),
  analyzerAdapterPrototypeMetadataRefinementPatchAppliedClean(
    'analyzerAdapterPrototypeMetadataRefinementPatchAppliedClean',
  ),
  blockedByUnsafePatchSetDiagnostic('blockedByUnsafePatchSetDiagnostic'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidMetadataRefinementPatch('invalidMetadataRefinementPatch');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchStatus(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord({
    required this.refinementId,
    required this.sourceDiagnosticRowId,
    required this.sourcePatchId,
    required this.sourceActionId,
    required this.sourceCaseId,
    required this.sourcePhase,
    required this.sourceDiagnosticRole,
    required this.sourcePatchGroup,
    required this.refinementGroup,
    required this.refinementType,
    required this.targetSurface,
    required this.refinedDisplayLabel,
    required this.refinedReasonSummary,
    required this.sourceChainSummary,
    required this.supportAreaIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.blockedBoundaryIds,
    required this.deniedFieldIds,
    required this.androidProofIds,
    required this.ownerProofRequired,
    required this.appliedAsMetadataOnly,
    required this.requiresFutureValidation,
    required this.recommendation,
  });

  final String refinementId;
  final String sourceDiagnosticRowId;
  final String sourcePatchId;
  final String sourceActionId;
  final String sourceCaseId;
  final String sourcePhase;
  final String sourceDiagnosticRole;
  final String sourcePatchGroup;
  final String refinementGroup;
  final String refinementType;
  final String targetSurface;
  final String refinedDisplayLabel;
  final String refinedReasonSummary;
  final String sourceChainSummary;
  final List<String> supportAreaIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> blockedBoundaryIds;
  final List<String> deniedFieldIds;
  final List<String> androidProofIds;
  final bool ownerProofRequired;
  final bool appliedAsMetadataOnly;
  final bool requiresFutureValidation;
  final String recommendation;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'refinementId': refinementId,
      'sourceDiagnosticRowId': sourceDiagnosticRowId,
      'sourcePatchId': sourcePatchId,
      'sourceActionId': sourceActionId,
      'sourceCaseId': sourceCaseId,
      'sourcePhase': sourcePhase,
      'sourceDiagnosticRole': sourceDiagnosticRole,
      'sourcePatchGroup': sourcePatchGroup,
      'refinementGroup': refinementGroup,
      'refinementType': refinementType,
      'targetSurface': targetSurface,
      'refinedDisplayLabel': refinedDisplayLabel,
      'refinedReasonSummary': refinedReasonSummary,
      'sourceChainSummary': sourceChainSummary,
      'supportAreaIds': supportAreaIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'blockedBoundaryIds': blockedBoundaryIds,
      'deniedFieldIds': deniedFieldIds,
      'androidProofIds': androidProofIds,
      'ownerProofRequired': ownerProofRequired,
      'appliedAsMetadataOnly': appliedAsMetadataOnly,
      'requiresFutureValidation': requiresFutureValidation,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchResult {
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchResult({
    required this.status,
    required this.sourceDiagnosticStatus,
    required this.sourcePatchSetStatus,
    required this.refinements,
    required this.findings,
    required this.allowedTargetSurfaces,
    required this.forbiddenTargetSurfaces,
    required this.safeForPhase34F,
    required this.nextRecommendation,
  }) : totalRefinementRecords = refinements.length,
       supportTraceabilityMetadataRefinementCount = _countGroup(
         refinements,
         _supportTraceabilityMetadataRefinements,
       ),
       warningReasonMetadataRefinementCount = _countGroup(
         refinements,
         _warningReasonMetadataRefinements,
       ),
       proofBoundaryMetadataRefinementCount = _countGroup(
         refinements,
         _proofBoundaryMetadataRefinements,
       ),
       excludedGuardMetadataRefinementCount = _countGroup(
         refinements,
         _excludedGuardMetadataRefinements,
       ),
       deniedFieldMetadataRefinementCount = _countGroup(
         refinements,
         _deniedFieldMetadataRefinements,
       ),
       blockedIntegrationMetadataRefinementCount = _countGroup(
         refinements,
         _blockedIntegrationMetadataRefinements,
       ),
       targetSurfaceMetadataRefinementCount = _countGroup(
         refinements,
         _targetSurfaceMetadataRefinements,
       ),
       diagnosticSummaryMetadataRefinementCount = _countGroup(
         refinements,
         _diagnosticSummaryMetadataRefinements,
       ),
       phase34FDiagnosticRequirementRefinementCount = _countGroup(
         refinements,
         _phase34FDiagnosticRequirementRefinements,
       ),
       targetSurfaceCounts = _targetSurfaceCounts(refinements),
       activeDeniedFieldCount = refinements
           .expand(_activeDeniedFieldIds)
           .length,
       productOutputCount =
           _countForbiddenSurface(refinements, const {'productReviewOutput'}) +
           _countActiveFields(refinements, _productFields),
       labelLeakCount = _countActiveFields(refinements, _labelFields),
       finalLabelLeakCount = _countActiveFields(refinements, _finalLabelFields),
       scoreLeakCount = _countActiveFields(refinements, _scoreFields),
       metricLeakCount = _countActiveFields(refinements, _metricFields),
       cpLossLeakCount = _countActiveFields(refinements, const {'cpLoss'}),
       winProbabilityLeakCount = _countActiveFields(refinements, const {
         'winProbability',
       }),
       moveRankingLeakCount = _countActiveFields(refinements, const {
         'moveRanking',
       }),
       thresholdLeakCount = _countActiveFields(refinements, const {
         'thresholds',
       }),
       uiTargetCount =
           _countForbiddenSurface(refinements, const {'UI'}) +
           _countEnabledBoundary(refinements, const {'uiTarget'}),
       backendTargetCount =
           _countForbiddenSurface(refinements, const {'backend'}) +
           _countEnabledBoundary(refinements, const {'backendTarget'}),
       persistenceWriteCount =
           _countForbiddenSurface(refinements, const {
             'persistence',
             'cache',
             'database',
           }) +
           _countEnabledBoundary(refinements, const {'persistenceWrite'}),
       engineCallCount =
           _countForbiddenSurface(refinements, const {
             'engineCall',
             'StockfishBridge',
           }) +
           _countEnabledBoundary(refinements, const {
             'directEngineCall',
             'engineResults',
           }),
       schedulerExecutionCount =
           _countForbiddenSurface(refinements, const {'schedulerExecution'}) +
           _countEnabledBoundary(refinements, const {'schedulerExecution'}),
       analyzerWiringCount =
           _countForbiddenSurface(refinements, const {'analyzerWiring'}) +
           _countEnabledBoundary(refinements, const {'analyzerWiring'}),
       runtimeImplementationCount = _countEnabledBoundary(refinements, const {
         'runtimeImplementation',
       }),
       executablePrototypeCount = _countEnabledBoundary(refinements, const {
         'executablePrototypeBehavior',
       }),
       productAdapterBehaviorCount =
           _countForbiddenSurface(refinements, const {'productAdapter'}) +
           _countEnabledBoundary(refinements, const {'productAdapterBehavior'}),
       savedAnalysisIntegrationCount =
           _countForbiddenSurface(refinements, const {'savedAnalysis'}) +
           _countEnabledBoundary(refinements, const {
             'savedAnalysisIntegration',
           }),
       stockfishCommandLeakCount = _countActiveFields(refinements, const {
         'stockfishCommand',
       }),
       rawUciLeakCount = _countActiveFields(refinements, const {'rawUci'}),
       pvDumpLeakCount = _countActiveFields(refinements, const {'pvDump'}),
       androidCollectorRequirementCount =
           _countForbiddenSurface(refinements, const {'AndroidCollector'}) +
           _countActiveFields(refinements, const {
             'androidCollectorRequirement',
             'androidCollectorExecution',
           }),
       phase32EProofClaimCount = refinements
           .where(
             (record) => record.androidProofIds.any(_phase32ECaseIds.contains),
           )
           .length,
       unprovenAndroidProofCount = refinements
           .where(
             (record) => record.androidProofIds.any(
               (id) => !_capturedAndroidProofIds.contains(id),
             ),
           )
           .length,
       ownerProofQueueCount = refinements
           .where((record) => record.ownerProofRequired)
           .length,
       blockerCount = findings
           .where((finding) => !finding.startsWith('reportTextLeak:'))
           .length,
       criticalCount = findings
           .where((finding) => finding.startsWith('reportTextLeak:'))
           .length;

  final DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchStatus
  status;
  final String sourceDiagnosticStatus;
  final String sourcePatchSetStatus;
  final List<DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord>
  refinements;
  final List<String> findings;
  final List<String> allowedTargetSurfaces;
  final List<String> forbiddenTargetSurfaces;
  final bool safeForPhase34F;
  final String nextRecommendation;
  final int totalRefinementRecords;
  final int supportTraceabilityMetadataRefinementCount;
  final int warningReasonMetadataRefinementCount;
  final int proofBoundaryMetadataRefinementCount;
  final int excludedGuardMetadataRefinementCount;
  final int deniedFieldMetadataRefinementCount;
  final int blockedIntegrationMetadataRefinementCount;
  final int targetSurfaceMetadataRefinementCount;
  final int diagnosticSummaryMetadataRefinementCount;
  final int phase34FDiagnosticRequirementRefinementCount;
  final Map<String, int> targetSurfaceCounts;
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
  final int blockerCount;
  final int criticalCount;

  int get unsafeCount => safeForPhase34F ? 0 : 1;

  bool get hasUnsafePolicyViolation =>
      !safeForPhase34F ||
      nextRecommendation != _phase34FRecommendation ||
      unsafeCount > 0 ||
      blockerCount > 0 ||
      criticalCount > 0 ||
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

  String renderMarkdown({
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection
        section =
        DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection
            .all,
  }) {
    final buffer = StringBuffer()
      ..writeln('# Analyzer Adapter Prototype Metadata Refinement Patch')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchVersion',
      )
      ..writeln('- metadata refinement status: ${status.wire}')
      ..writeln('- selected section: ${section.wire}')
      ..writeln('- source diagnostic status: $sourceDiagnosticStatus')
      ..writeln('- source patch set status: $sourcePatchSetStatus')
      ..writeln('- safe for Phase 34F: $safeForPhase34F')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln();
    if (_includeSection(section, _refinementsSection)) {
      _writeRefinementTable(buffer, refinements);
    }
    if (_includeSection(section, _supportSection)) {
      _writeGroup(
        buffer,
        'Support Reason Summary',
        _byGroup(_supportTraceabilityMetadataRefinements),
      );
    }
    if (_includeSection(section, _warningSection)) {
      _writeGroup(
        buffer,
        'Warning Reason Summary',
        _byGroup(_warningReasonMetadataRefinements),
      );
    }
    if (_includeSection(section, _proofSection)) {
      _writeGroup(
        buffer,
        'Proof Boundary Summary',
        _byGroup(_proofBoundaryMetadataRefinements),
      );
    }
    if (_includeSection(section, _guardsSection)) {
      _writeGroup(
        buffer,
        'Excluded Guard Summary',
        _byGroup(_excludedGuardMetadataRefinements),
      );
    }
    if (_includeSection(section, _deniedSection)) {
      _writeGroup(
        buffer,
        'Denied-Field Summary',
        _byGroup(_deniedFieldMetadataRefinements),
      );
    }
    if (_includeSection(section, _blockedSection)) {
      _writeGroup(
        buffer,
        'Blocked Integration Summary',
        _byGroup(_blockedIntegrationMetadataRefinements),
      );
    }
    if (_includeSection(section, _surfacesSection)) {
      _writeSurfaceSummary(buffer, targetSurfaceCounts);
    }
    if (_includeSection(section, _recommendationSection)) {
      buffer
        ..writeln('## Recommendation')
        ..writeln('- safe for Phase 34F: $safeForPhase34F')
        ..writeln('- next recommendation: $nextRecommendation')
        ..writeln(
          '- Phase 34F diagnostic requirement refinements: $phase34FDiagnosticRequirementRefinementCount',
        )
        ..writeln('- findings: ${_ids(findings)}')
        ..writeln();
    }
    return buffer.toString();
  }

  String renderJson({
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection
        section =
        DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection
            .all,
  }) {
    return const JsonEncoder.withIndent(' ').convert(toJson(section: section));
  }

  Map<String, Object?> toJson({
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection
        section =
        DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection
            .all,
  }) {
    final payload = <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchVersion,
      'status': status.wire,
      'section': section.wire,
      'sourceDiagnosticStatus': sourceDiagnosticStatus,
      'sourcePatchSetStatus': sourcePatchSetStatus,
      'safeForPhase34F': safeForPhase34F,
      'nextRecommendation': nextRecommendation,
      'counts': <String, Object?>{
        'totalRefinementRecords': totalRefinementRecords,
        'supportTraceabilityMetadataRefinementCount':
            supportTraceabilityMetadataRefinementCount,
        'warningReasonMetadataRefinementCount':
            warningReasonMetadataRefinementCount,
        'proofBoundaryMetadataRefinementCount':
            proofBoundaryMetadataRefinementCount,
        'excludedGuardMetadataRefinementCount':
            excludedGuardMetadataRefinementCount,
        'deniedFieldMetadataRefinementCount':
            deniedFieldMetadataRefinementCount,
        'blockedIntegrationMetadataRefinementCount':
            blockedIntegrationMetadataRefinementCount,
        'targetSurfaceMetadataRefinementCount':
            targetSurfaceMetadataRefinementCount,
        'diagnosticSummaryMetadataRefinementCount':
            diagnosticSummaryMetadataRefinementCount,
        'phase34FDiagnosticRequirementRefinementCount':
            phase34FDiagnosticRequirementRefinementCount,
        'unsafeCount': unsafeCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'activeDeniedFieldCount': activeDeniedFieldCount,
        'productOutputCount': productOutputCount,
        'analyzerWiringCount': analyzerWiringCount,
        'runtimeImplementationCount': runtimeImplementationCount,
        'executablePrototypeCount': executablePrototypeCount,
        'engineCallCount': engineCallCount,
        'schedulerExecutionCount': schedulerExecutionCount,
        'persistenceWriteCount': persistenceWriteCount,
        'stockfishCommandLeakCount': stockfishCommandLeakCount,
        'rawUciLeakCount': rawUciLeakCount,
        'pvDumpLeakCount': pvDumpLeakCount,
        'ownerProofQueueCount': ownerProofQueueCount,
      },
      'targetSurfaceCounts': targetSurfaceCounts,
      'allowedTargetSurfaces': allowedTargetSurfaces,
      'forbiddenTargetSurfaces': forbiddenTargetSurfaces,
      'findings': findings,
    };
    if (_includeSection(section, _refinementsSection)) {
      payload['refinements'] = refinements
          .map((record) => record.toJson())
          .toList();
    }
    if (_includeSection(section, _supportSection)) {
      payload['support'] = _byGroup(
        _supportTraceabilityMetadataRefinements,
      ).map((record) => record.toJson()).toList();
    }
    if (_includeSection(section, _warningSection)) {
      payload['warning'] = _byGroup(
        _warningReasonMetadataRefinements,
      ).map((record) => record.toJson()).toList();
    }
    if (_includeSection(section, _proofSection)) {
      payload['proof'] = _byGroup(
        _proofBoundaryMetadataRefinements,
      ).map((record) => record.toJson()).toList();
    }
    if (_includeSection(section, _guardsSection)) {
      payload['guards'] = _byGroup(
        _excludedGuardMetadataRefinements,
      ).map((record) => record.toJson()).toList();
    }
    if (_includeSection(section, _deniedSection)) {
      payload['denied'] = _byGroup(
        _deniedFieldMetadataRefinements,
      ).map((record) => record.toJson()).toList();
    }
    if (_includeSection(section, _blockedSection)) {
      payload['blocked'] = _byGroup(
        _blockedIntegrationMetadataRefinements,
      ).map((record) => record.toJson()).toList();
    }
    if (_includeSection(section, _surfacesSection)) {
      payload['surfaces'] = targetSurfaceCounts;
    }
    if (_includeSection(section, _recommendationSection)) {
      payload['recommendation'] = <String, Object?>{
        'safeForPhase34F': safeForPhase34F,
        'nextRecommendation': nextRecommendation,
        'phase34FDiagnosticRequirementRefinementCount':
            phase34FDiagnosticRequirementRefinementCount,
      };
    }
    return payload;
  }

  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord>
  _byGroup(String group) =>
      refinements.where((record) => record.refinementGroup == group);
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection {
  all('all'),
  refinements('refinements'),
  support('support'),
  warning('warning'),
  proof('proof'),
  guards('guards'),
  denied('denied'),
  blocked('blocked'),
  surfaces('surfaces'),
  recommendation('recommendation');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatch {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatch();

  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchResult
  evaluate({
    DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticResult?
    diagnosticResult,
  }) {
    final source =
        diagnosticResult ??
        const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnostic()
            .evaluate();
    if (source.hasUnsafePolicyViolation || !source.safeForPhase34E) {
      return DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchResult(
        status:
            DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchStatus
                .blockedByUnsafePatchSetDiagnostic,
        sourceDiagnosticStatus: source.status.wire,
        sourcePatchSetStatus: source.sourcePatchSetStatus,
        refinements:
            const <
              DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord
            >[],
        findings: const <String>['unsafePhase34DPatchSetDiagnostic'],
        allowedTargetSurfaces: _sorted(_allowedTargetSurfaces),
        forbiddenTargetSurfaces: _sorted(_forbiddenTargetSurfaces),
        safeForPhase34F: false,
        nextRecommendation:
            'blockedByUnsafeAnalyzerAdapterPrototypeMetadataRefinementPatch',
      );
    }

    final records =
        <DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord>[
          for (final row in source.rows) _refinementForRow(row),
          _targetSurfaceSummaryRefinement(source),
          _diagnosticSummaryRefinement(source),
          _phase34FRequirementRefinement(),
        ];
    final findings =
        const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchValidator()
            .validateRefinements(records);
    final safeForPhase34F = findings.isEmpty;
    final status = !safeForPhase34F
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchStatus
              .blockedByPolicyBoundary
        : records.any(
            (record) =>
                record.warningReasons.isNotEmpty ||
                record.proofLimitReasons.isNotEmpty,
          )
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchStatus
              .analyzerAdapterPrototypeMetadataRefinementPatchAppliedWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchStatus
              .analyzerAdapterPrototypeMetadataRefinementPatchAppliedClean;
    return DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchResult(
      status: status,
      sourceDiagnosticStatus: source.status.wire,
      sourcePatchSetStatus: source.sourcePatchSetStatus,
      refinements: records,
      findings: findings,
      allowedTargetSurfaces: _sorted(_allowedTargetSurfaces),
      forbiddenTargetSurfaces: _sorted(_forbiddenTargetSurfaces),
      safeForPhase34F: safeForPhase34F,
      nextRecommendation: safeForPhase34F
          ? _phase34FRecommendation
          : 'blockedByUnsafeAnalyzerAdapterPrototypeMetadataRefinementPatch',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchValidator {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchValidator();

  List<String> validateRefinements(
    Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord>
    records,
  ) {
    final refinements = records.toList();
    final findings = <String>[
      if (!refinements.any(
        (record) =>
            record.refinementGroup == _phase34FDiagnosticRequirementRefinements,
      ))
        'missingPhase34FPracticalDiagnosticRecommendation',
    ];
    for (final record in refinements) {
      findings.addAll(validateRefinement(record));
    }
    return _sorted(findings);
  }

  List<String> validateRefinement(
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord record,
  ) {
    final activeDenied = _activeDeniedFieldIds(record).toSet();
    return _sorted(<String>[
      if (!_allowedRefinementGroups.contains(record.refinementGroup))
        'unknownRefinementGroup',
      if (!_allowedRefinementTypes.contains(record.refinementType))
        'unknownRefinementType',
      if (!_allowedTargetSurfaces.contains(record.targetSurface))
        'unknownTargetSurface',
      if (_forbiddenTargetSurfaces.contains(record.targetSurface))
        'forbiddenTargetSurface',
      if (!record.appliedAsMetadataOnly) 'nonMetadataRefinement',
      if (!record.requiresFutureValidation) 'missingFutureValidation',
      if (_isQuietRefinement(record) &&
          record.refinementGroup != _excludedGuardMetadataRefinements)
        'quietPreparatoryPromotion',
      if (record.sourceCaseId == _pvMultiPvBoundaryCaseId &&
          record.refinementGroup != _proofBoundaryMetadataRefinements)
        'pvMultiPvPromotion',
      if (record.androidProofIds.any(_phase32ECaseIds.contains))
        'phase32ECapturedProofClaim',
      if (record.androidProofIds.any(
        (id) => !_capturedAndroidProofIds.contains(id),
      ))
        'unprovenAndroidProofClaim',
      if (record.ownerProofRequired &&
          !record.proofLimitReasons.any(
            (reason) => reason.contains('pvMultiPv'),
          ))
        'ownerProofWithoutPvMultiPvReason',
      if (_enablesBoundary(record, const {'runtimeImplementation'}))
        'runtimeImplementationEnabled',
      if (_enablesBoundary(record, const {'analyzerWiring'}))
        'analyzerWiringEnabled',
      if (_enablesBoundary(record, const {'executablePrototypeBehavior'}))
        'executablePrototypeEnabled',
      if (_enablesBoundary(record, const {'directEngineCall', 'engineResults'}))
        'engineCallEnabled',
      if (_enablesBoundary(record, const {'schedulerExecution'}))
        'schedulerExecutionEnabled',
      if (_enablesBoundary(record, const {'productAdapterBehavior'}))
        'productAdapterEnabled',
      if (_enablesBoundary(record, const {'savedAnalysisIntegration'}))
        'savedAnalysisIntegrationEnabled',
      if (_enablesBoundary(record, const {
        'uiTarget',
        'backendTarget',
        'persistenceWrite',
      }))
        'uiBackendPersistenceEnabled',
      if (activeDenied.isNotEmpty) 'activeDeniedFields',
      if (activeDenied.any(_productFields.contains)) 'productLabelsEnabled',
      if (activeDenied.any(_finalLabelFields.contains)) 'finalLabelsEnabled',
      if (activeDenied.any(_labelFields.contains)) 'classifierLabelsEnabled',
      if (activeDenied.any(_scoreFields.contains)) 'scoresEnabled',
      if (activeDenied.any(_metricFields.contains)) 'officialMetricsEnabled',
      if (activeDenied.contains('cpLoss')) 'cpLossEnabled',
      if (activeDenied.contains('winProbability')) 'winProbabilityEnabled',
      if (activeDenied.contains('moveRanking')) 'moveRankingEnabled',
      if (activeDenied.contains('thresholds')) 'thresholdsEnabled',
      if (activeDenied.contains('stockfishCommand')) 'stockfishCommandEnabled',
      if (activeDenied.contains('rawUci')) 'rawUciEnabled',
      if (activeDenied.contains('pvDump')) 'pvDumpEnabled',
      if (activeDenied.any(
        const {
          'androidCollectorRequirement',
          'androidCollectorExecution',
        }.contains,
      ))
        'androidCollectorRequirementEnabled',
      if (activeDenied.contains('readinessSummaryChain'))
        'readinessSummaryChainEnabled',
      if (activeDenied.contains('readinessGate')) 'readinessGateEnabled',
    ]);
  }

  List<String> validateReportText(String reportText) {
    final lower = reportText.toLowerCase();
    return _sorted(<String>[
      for (final token in _rawReportLeakTokens)
        if (lower.contains(token.toLowerCase())) 'reportTextLeak:$token',
    ]);
  }
}

DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord
_refinementForRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow row,
) {
  final group = _refinementGroupForPatchGroup(row.patchGroup);
  return DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord(
    refinementId: 'refinement-${_idSuffix(row.patchId)}',
    sourceDiagnosticRowId: row.diagnosticRowId,
    sourcePatchId: row.patchId,
    sourceActionId: row.sourceActionId,
    sourceCaseId: row.sourceCaseId,
    sourcePhase: row.sourcePhase,
    sourceDiagnosticRole: row.sourceDiagnosticRole,
    sourcePatchGroup: row.patchGroup,
    refinementGroup: group,
    refinementType: _refinementTypeForGroup(group),
    targetSurface: _targetSurfaceForGroup(group, row.targetSurface),
    refinedDisplayLabel: _displayLabelForGroup(group),
    refinedReasonSummary: _reasonSummaryForRow(row),
    sourceChainSummary:
        '${row.sourceCaseId} -> ${row.sourceActionId} -> ${row.patchId} -> ${row.diagnosticRowId}',
    supportAreaIds: row.supportAreaIds,
    warningReasons: row.warningReasons,
    proofLimitReasons: row.proofLimitReasons,
    blockedBoundaryIds: row.blockedBoundaryIds,
    deniedFieldIds: row.deniedFieldIds,
    androidProofIds: row.androidProofIds,
    ownerProofRequired: false,
    appliedAsMetadataOnly: true,
    requiresFutureValidation: true,
    recommendation: _phase34FRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord
_targetSurfaceSummaryRefinement(
  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticResult source,
) {
  return _systemRefinement(
    refinementId: 'refinement-target-surface-summary',
    group: _targetSurfaceMetadataRefinements,
    type: 'targetSurfaceSummaryMetadata',
    targetSurface: 'patchSetDiagnosticMetadata',
    displayLabel: 'Target surface summary',
    reasonSummary:
        'Allowed surfaces: ${_ids(source.allowedTargetSurfaces)}; blocked surfaces: ${_ids(source.forbiddenTargetSurfaces)}',
    supportAreaIds: const <String>['targetSurfaceMetadata'],
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord
_diagnosticSummaryRefinement(
  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticResult source,
) {
  return _systemRefinement(
    refinementId: 'refinement-diagnostic-summary-counts',
    group: _diagnosticSummaryMetadataRefinements,
    type: 'diagnosticSummaryCountsMetadata',
    targetSurface: 'patchSetDiagnosticMetadata',
    displayLabel: 'Diagnostic summary counts',
    reasonSummary:
        'rows=${source.totalDiagnosticRows}; support=${source.supportTraceabilityRowCount}; warning=${source.warningFollowupMarkerRowCount}; proof=${source.proofBoundaryMarkerRowCount}; blocked=${source.blockedIntegrationSentinelRowCount}',
    supportAreaIds: const <String>['diagnosticSummaryCounts'],
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord
_phase34FRequirementRefinement() {
  return _systemRefinement(
    refinementId: 'refinement-phase34f-diagnostic-requirement',
    group: _phase34FDiagnosticRequirementRefinements,
    type: 'phase34FDiagnosticRequirementMetadata',
    targetSurface: 'actionPlanReportMetadata',
    displayLabel: 'Phase 34F diagnostic requirement',
    reasonSummary: 'Run practical metadata refinement diagnostic next',
    supportAreaIds: const <String>[
      'runAnalyzerAdapterPrototypeMetadataRefinementDiagnostic',
    ],
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord
_systemRefinement({
  required String refinementId,
  required String group,
  required String type,
  required String targetSurface,
  required String displayLabel,
  required String reasonSummary,
  required List<String> supportAreaIds,
}) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord(
    refinementId: refinementId,
    sourceDiagnosticRowId: 'system',
    sourcePatchId: 'system',
    sourceActionId: 'system',
    sourceCaseId: 'system',
    sourcePhase: 'Phase 34E',
    sourceDiagnosticRole: 'systemMetadataRefinement',
    sourcePatchGroup: 'system',
    refinementGroup: group,
    refinementType: type,
    targetSurface: targetSurface,
    refinedDisplayLabel: displayLabel,
    refinedReasonSummary: reasonSummary,
    sourceChainSummary: 'system -> $refinementId',
    supportAreaIds: supportAreaIds,
    warningReasons: const <String>[
      'developerOnlyMetadataRefinementNoRuntimeExecution',
    ],
    proofLimitReasons: const <String>[],
    blockedBoundaryIds: const <String>[],
    deniedFieldIds: const <String>[],
    androidProofIds: const <String>[],
    ownerProofRequired: false,
    appliedAsMetadataOnly: true,
    requiresFutureValidation: true,
    recommendation: _phase34FRecommendation,
  );
}

String _refinementGroupForPatchGroup(String patchGroup) {
  return switch (patchGroup) {
    _supportTraceabilityPatches => _supportTraceabilityMetadataRefinements,
    _warningFollowupMarkerPatches => _warningReasonMetadataRefinements,
    _proofBoundaryMarkerPatches => _proofBoundaryMetadataRefinements,
    _excludedGuardPreservationPatches => _excludedGuardMetadataRefinements,
    _deniedFieldProtectionPatches => _deniedFieldMetadataRefinements,
    _blockedIntegrationSentinelPatches ||
    _futurePrerequisiteMarkerPatches => _blockedIntegrationMetadataRefinements,
    _phase34DPracticalDiagnosticRequirementPatches =>
      _phase34FDiagnosticRequirementRefinements,
    _diagnosticCoveragePatches ||
    _prototypeSkeletonMetadataPatches => _diagnosticSummaryMetadataRefinements,
    _ => 'unknownRefinementGroup',
  };
}

String _refinementTypeForGroup(String group) {
  return switch (group) {
    _supportTraceabilityMetadataRefinements => 'supportTraceabilityMetadata',
    _warningReasonMetadataRefinements => 'warningReasonSummaryMetadata',
    _proofBoundaryMetadataRefinements => 'proofBoundarySummaryMetadata',
    _excludedGuardMetadataRefinements => 'excludedGuardSummaryMetadata',
    _deniedFieldMetadataRefinements => 'deniedFieldSummaryMetadata',
    _blockedIntegrationMetadataRefinements =>
      'blockedIntegrationSummaryMetadata',
    _targetSurfaceMetadataRefinements => 'targetSurfaceSummaryMetadata',
    _diagnosticSummaryMetadataRefinements => 'diagnosticSummaryCountsMetadata',
    _phase34FDiagnosticRequirementRefinements =>
      'phase34FDiagnosticRequirementMetadata',
    _ => 'unknownRefinementType',
  };
}

String _targetSurfaceForGroup(String group, String sourceSurface) {
  return switch (group) {
    _targetSurfaceMetadataRefinements ||
    _diagnosticSummaryMetadataRefinements => 'patchSetDiagnosticMetadata',
    _phase34FDiagnosticRequirementRefinements => 'actionPlanReportMetadata',
    _ => sourceSurface,
  };
}

String _displayLabelForGroup(String group) {
  return switch (group) {
    _supportTraceabilityMetadataRefinements => 'Support traceability',
    _warningReasonMetadataRefinements => 'Warning follow-up',
    _proofBoundaryMetadataRefinements => 'Proof-boundary watch list',
    _excludedGuardMetadataRefinements => 'Excluded guard preservation',
    _deniedFieldMetadataRefinements => 'Denied-field protection',
    _blockedIntegrationMetadataRefinements => 'Blocked integration sentinel',
    _targetSurfaceMetadataRefinements => 'Target surface summary',
    _diagnosticSummaryMetadataRefinements => 'Diagnostic summary counts',
    _phase34FDiagnosticRequirementRefinements => 'Phase 34F diagnostic',
    _ => 'Unknown metadata refinement',
  };
}

String _reasonSummaryForRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow row,
) {
  if (row.patchGroup == _proofBoundaryMarkerPatches) {
    return 'Proof boundary only: ${_ids(row.proofLimitReasons)}';
  }
  if (row.patchGroup == _excludedGuardPreservationPatches) {
    return 'Excluded guard only: ${_ids(row.proofLimitReasons)}';
  }
  if (row.patchGroup == _deniedFieldProtectionPatches) {
    return 'Denied fields remain inactive: ${_ids(row.deniedFieldIds)}';
  }
  if (row.patchGroup == _blockedIntegrationSentinelPatches ||
      row.patchGroup == _futurePrerequisiteMarkerPatches) {
    return 'Blocked boundaries remain inactive: ${_ids(row.blockedBoundaryIds)}';
  }
  if (row.warningReasons.isNotEmpty) {
    return 'Warnings: ${_ids(row.warningReasons)}';
  }
  return 'Metadata-only traceability for ${row.sourceCaseId}';
}

void _writeRefinementTable(
  StringBuffer buffer,
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord>
  records,
) {
  buffer
    ..writeln('## Metadata Refinement Records')
    ..writeln(
      '| Refinement | Source chain | Group | Type | Target surface | Label | Reason summary |',
    )
    ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
  for (final record in records) {
    buffer.writeln(
      '| ${record.refinementId} | ${record.sourceChainSummary} | ${record.refinementGroup} | ${record.refinementType} | ${record.targetSurface} | ${record.refinedDisplayLabel} | ${record.refinedReasonSummary} |',
    );
  }
  buffer.writeln();
}

void _writeGroup(
  StringBuffer buffer,
  String title,
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord>
  records,
) {
  buffer
    ..writeln('## $title')
    ..writeln(
      '| Refinement | Source case | Label | Reason summary | Target surface |',
    )
    ..writeln('| --- | --- | --- | --- | --- |');
  for (final record in records) {
    buffer.writeln(
      '| ${record.refinementId} | ${record.sourceCaseId} | ${record.refinedDisplayLabel} | ${record.refinedReasonSummary} | ${record.targetSurface} |',
    );
  }
  buffer.writeln();
}

void _writeSurfaceSummary(StringBuffer buffer, Map<String, int> counts) {
  buffer
    ..writeln('## Target Surface Summary')
    ..writeln('| Target surface | Count |')
    ..writeln('| --- | --- |');
  for (final entry in counts.entries) {
    buffer.writeln('| ${entry.key} | ${entry.value} |');
  }
  buffer.writeln();
}

bool _includeSection(
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection
  selected,
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection target,
) {
  return selected ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection
              .all ||
      selected == target;
}

bool _isQuietRefinement(
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord record,
) {
  return record.supportAreaIds.contains('quietMove') ||
      record.supportAreaIds.contains('quietPreparatoryMove') ||
      record.sourceCaseId.contains('quiet-preparatory');
}

bool _enablesBoundary(
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord record,
  Set<String> boundaryIds,
) {
  return !record.appliedAsMetadataOnly &&
      record.blockedBoundaryIds.any(boundaryIds.contains);
}

Iterable<String> _activeDeniedFieldIds(
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord record,
) {
  if (record.appliedAsMetadataOnly &&
      !_forbiddenTargetSurfaces.contains(record.targetSurface)) {
    return const <String>[];
  }
  return record.deniedFieldIds;
}

int _countActiveFields(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord>
  records,
  Set<String> fields,
) {
  var count = 0;
  for (final record in records) {
    count += _activeDeniedFieldIds(record).where(fields.contains).length;
  }
  return count;
}

int _countEnabledBoundary(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord>
  records,
  Set<String> fields,
) {
  return records
      .where(
        (record) =>
            !record.appliedAsMetadataOnly &&
            record.blockedBoundaryIds.any(fields.contains),
      )
      .length;
}

int _countForbiddenSurface(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord>
  records,
  Set<String> surfaces,
) {
  return records
      .where((record) => surfaces.contains(record.targetSurface))
      .length;
}

int _countGroup(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord>
  records,
  String group,
) {
  return records.where((record) => record.refinementGroup == group).length;
}

Map<String, int> _targetSurfaceCounts(
  Iterable<DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord>
  records,
) {
  final counts = <String, int>{};
  for (final record in records) {
    counts[record.targetSurface] = (counts[record.targetSurface] ?? 0) + 1;
  }
  return Map<String, int>.fromEntries(
    counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}

String _idSuffix(String value) {
  if (value.startsWith('patch-')) return value.substring('patch-'.length);
  if (value.startsWith('diagnostic-patch-')) {
    return value.substring('diagnostic-patch-'.length);
  }
  return value;
}

String _ids(Iterable<String> values) {
  final sorted = _sorted(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

List<String> _sorted(Iterable<String> values) {
  return values.where((value) => value.trim().isNotEmpty).toSet().toList()
    ..sort();
}

const _phase34FRecommendation =
    'runAnalyzerAdapterPrototypeMetadataRefinementDiagnostic';

const _supportTraceabilityPatches = 'supportTraceabilityPatches';
const _warningFollowupMarkerPatches = 'warningFollowupMarkerPatches';
const _proofBoundaryMarkerPatches = 'proofBoundaryMarkerPatches';
const _excludedGuardPreservationPatches = 'excludedGuardPreservationPatches';
const _deniedFieldProtectionPatches = 'deniedFieldProtectionPatches';
const _diagnosticCoveragePatches = 'diagnosticCoveragePatches';
const _prototypeSkeletonMetadataPatches = 'prototypeSkeletonMetadataPatches';
const _blockedIntegrationSentinelPatches = 'blockedIntegrationSentinelPatches';
const _futurePrerequisiteMarkerPatches = 'futurePrerequisiteMarkerPatches';
const _phase34DPracticalDiagnosticRequirementPatches =
    'phase34DPracticalDiagnosticRequirementPatches';

const _supportTraceabilityMetadataRefinements =
    'supportTraceabilityMetadataRefinements';
const _warningReasonMetadataRefinements = 'warningReasonMetadataRefinements';
const _proofBoundaryMetadataRefinements = 'proofBoundaryMetadataRefinements';
const _excludedGuardMetadataRefinements = 'excludedGuardMetadataRefinements';
const _deniedFieldMetadataRefinements = 'deniedFieldMetadataRefinements';
const _blockedIntegrationMetadataRefinements =
    'blockedIntegrationMetadataRefinements';
const _targetSurfaceMetadataRefinements = 'targetSurfaceMetadataRefinements';
const _diagnosticSummaryMetadataRefinements =
    'diagnosticSummaryMetadataRefinements';
const _phase34FDiagnosticRequirementRefinements =
    'phase34FDiagnosticRequirementRefinements';

const _allowedRefinementGroups = <String>{
  _supportTraceabilityMetadataRefinements,
  _warningReasonMetadataRefinements,
  _proofBoundaryMetadataRefinements,
  _excludedGuardMetadataRefinements,
  _deniedFieldMetadataRefinements,
  _blockedIntegrationMetadataRefinements,
  _targetSurfaceMetadataRefinements,
  _diagnosticSummaryMetadataRefinements,
  _phase34FDiagnosticRequirementRefinements,
};

const _allowedRefinementTypes = <String>{
  'supportTraceabilityMetadata',
  'warningReasonSummaryMetadata',
  'proofBoundarySummaryMetadata',
  'excludedGuardSummaryMetadata',
  'deniedFieldSummaryMetadata',
  'blockedIntegrationSummaryMetadata',
  'targetSurfaceSummaryMetadata',
  'diagnosticSummaryCountsMetadata',
  'phase34FDiagnosticRequirementMetadata',
};

const _allowedTargetSurfaces = <String>{
  'diagnosticCommandMetadata',
  'selectedGoldenDiagnosticRows',
  'actionPlanReportMetadata',
  'patchSetReportMetadata',
  'patchSetDiagnosticMetadata',
  'prototypeSkeletonMetadata',
  'guardrailSnapshotMetadata',
  'proofBoundaryMetadata',
  'deniedFieldBoundaryMetadata',
  'blockedIntegrationMetadata',
};

const _forbiddenTargetSurfaces = <String>{
  'productReviewOutput',
  'analyzerRuntimeInput',
  'analyzerWiring',
  'savedAnalysis',
  'UI',
  'backend',
  'persistence',
  'cache',
  'database',
  'schedulerExecution',
  'engineCall',
  'StockfishBridge',
  'AndroidCollector',
  'productAdapter',
};

const _refinementsSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection
        .refinements;
const _supportSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection
        .support;
const _warningSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection
        .warning;
const _proofSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection.proof;
const _guardsSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection
        .guards;
const _deniedSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection
        .denied;
const _blockedSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection
        .blocked;
const _surfacesSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection
        .surfaces;
const _recommendationSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection
        .recommendation;

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

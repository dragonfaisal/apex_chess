import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_selected_golden_diagnostic_validation.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanVersion =
    'debug-only-bridge-analyzer-adapter-prototype-selected-diagnostic-action-plan-v1';

enum DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanStatus {
  selectedDiagnosticActionPlanReadyWithWarnings(
    'selectedDiagnosticActionPlanReadyWithWarnings',
  ),
  selectedDiagnosticActionPlanReadyClean(
    'selectedDiagnosticActionPlanReadyClean',
  ),
  blockedByUnsafeSelectedDiagnosticValidation(
    'blockedByUnsafeSelectedDiagnosticValidation',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidSelectedDiagnosticActionPlan('invalidSelectedDiagnosticActionPlan');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanStatus(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord({
    required this.actionId,
    required this.sourceCaseId,
    required this.sourcePhase,
    required this.sourceDiagnosticRole,
    required this.actionGroup,
    required this.actionType,
    required this.priority,
    required this.supportAreaIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.blockedBoundaryIds,
    required this.androidProofIds,
    required this.ownerProofRequired,
    required this.implementationAllowedNow,
    required this.requiresFutureValidation,
    required this.recommendedNextStep,
    required this.deniedFieldIds,
  });

  final String actionId;
  final String sourceCaseId;
  final String sourcePhase;
  final String sourceDiagnosticRole;
  final String actionGroup;
  final String actionType;
  final String priority;
  final List<String> supportAreaIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> blockedBoundaryIds;
  final List<String> androidProofIds;
  final bool ownerProofRequired;
  final bool implementationAllowedNow;
  final bool requiresFutureValidation;
  final String recommendedNextStep;
  final List<String> deniedFieldIds;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'actionId': actionId,
      'sourceCaseId': sourceCaseId,
      'sourcePhase': sourcePhase,
      'sourceDiagnosticRole': sourceDiagnosticRole,
      'actionGroup': actionGroup,
      'actionType': actionType,
      'priority': priority,
      'supportAreaIds': supportAreaIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'blockedBoundaryIds': blockedBoundaryIds,
      'androidProofIds': androidProofIds,
      'ownerProofRequired': ownerProofRequired,
      'implementationAllowedNow': implementationAllowedNow,
      'requiresFutureValidation': requiresFutureValidation,
      'recommendedNextStep': recommendedNextStep,
      'deniedFieldIds': deniedFieldIds,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanResult {
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanResult({
    required this.status,
    required this.sourceValidationStatus,
    required this.actions,
    required this.findings,
    required this.safeForPhase34C,
    required this.nextRecommendation,
  }) : totalActions = actions.length,
       safeInternalSupportActionCount = _countGroup(
         actions,
         _safeInternalSupportActions,
       ),
       warningLimitedFollowupActionCount = _countGroup(
         actions,
         _warningLimitedFollowupActions,
       ),
       proofBoundaryActionCount = _countGroup(actions, _proofBoundaryActions),
       excludedGuardActionCount = _countGroup(actions, _excludedGuardActions),
       deniedFieldProtectionActionCount = _countGroup(
         actions,
         _deniedFieldProtectionActions,
       ),
       prototypeSkeletonImprovementActionCount = _countGroup(
         actions,
         _prototypeSkeletonImprovementActions,
       ),
       diagnosticCoverageActionCount = _countGroup(
         actions,
         _diagnosticCoverageActions,
       ),
       futureRuntimePrerequisiteActionCount = _countGroup(
         actions,
         _futureRuntimePrerequisiteActions,
       ),
       blockedIntegrationActionCount = _countGroup(
         actions,
         _blockedIntegrationActions,
       ),
       phase34CRequirementActionCount = _countGroup(
         actions,
         _phase34CRequirementActions,
       ),
       activeDeniedFieldCount = actions.expand(_activeDeniedFieldIds).length,
       productOutputCount = _countActiveFields(actions, const {
         'productLabel',
         'productOutput',
       }),
       labelLeakCount = _countActiveFields(actions, _labelFields),
       finalLabelLeakCount = _countActiveFields(actions, const {
         'finalMoveLabel',
         'finalMoveLabels',
       }),
       scoreLeakCount = _countActiveFields(actions, const {
         'numericMoveScore',
         'numericMoveScores',
         'aggregateScore',
       }),
       metricLeakCount = _countActiveFields(actions, const {
         'officialAccuracy',
         'officialMetrics',
         'acpl',
       }),
       cpLossLeakCount = _countActiveFields(actions, const {'cpLoss'}),
       winProbabilityLeakCount = _countActiveFields(actions, const {
         'winProbability',
       }),
       moveRankingLeakCount = _countActiveFields(actions, const {
         'moveRanking',
       }),
       thresholdLeakCount = _countActiveFields(actions, const {'thresholds'}),
       uiTargetCount = _countBoundary(actions, const {'uiTarget'}),
       backendTargetCount = _countBoundary(actions, const {'backendTarget'}),
       persistenceWriteCount = _countBoundary(actions, const {
         'persistenceWrite',
       }),
       engineCallCount = _countBoundary(actions, const {
         'directEngineCall',
         'engineResults',
       }),
       schedulerExecutionCount = _countBoundary(actions, const {
         'schedulerExecution',
       }),
       analyzerWiringCount = _countBoundary(actions, const {'analyzerWiring'}),
       runtimeImplementationCount = _countBoundary(actions, const {
         'runtimeImplementation',
       }),
       executablePrototypeCount = _countBoundary(actions, const {
         'executablePrototypeBehavior',
       }),
       productAdapterBehaviorCount = _countBoundary(actions, const {
         'productAdapterBehavior',
       }),
       savedAnalysisIntegrationCount = _countBoundary(actions, const {
         'savedAnalysisIntegration',
       }),
       stockfishCommandLeakCount = _countActiveFields(actions, const {
         'stockfishCommand',
       }),
       rawUciLeakCount = _countActiveFields(actions, const {'rawUci'}),
       pvDumpLeakCount = _countActiveFields(actions, const {'pvDump'}),
       androidCollectorRequirementCount = _countBoundary(actions, const {
         'androidCollectorRequirement',
         'androidCollectorExecution',
       }),
       phase32EProofClaimCount = actions
           .where(
             (action) => action.androidProofIds.any(_phase32ECaseIds.contains),
           )
           .length,
       unprovenAndroidProofCount = actions
           .where(
             (action) => action.androidProofIds.any(
               (id) => !_capturedAndroidProofIds.contains(id),
             ),
           )
           .length,
       ownerProofQueueCount = actions
           .where((action) => action.ownerProofRequired)
           .length,
       blockerCount = findings
           .where((finding) => !finding.startsWith('reportTextLeak:'))
           .length,
       criticalCount = findings
           .where((finding) => finding.startsWith('reportTextLeak:'))
           .length;

  final DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanStatus
  status;
  final String sourceValidationStatus;
  final List<
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
  >
  actions;
  final List<String> findings;
  final bool safeForPhase34C;
  final String nextRecommendation;
  final int totalActions;
  final int safeInternalSupportActionCount;
  final int warningLimitedFollowupActionCount;
  final int proofBoundaryActionCount;
  final int excludedGuardActionCount;
  final int deniedFieldProtectionActionCount;
  final int prototypeSkeletonImprovementActionCount;
  final int diagnosticCoverageActionCount;
  final int futureRuntimePrerequisiteActionCount;
  final int blockedIntegrationActionCount;
  final int phase34CRequirementActionCount;
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
  int get unsafeCount => safeForPhase34C ? 0 : 1;

  bool get hasUnsafePolicyViolation =>
      !safeForPhase34C ||
      nextRecommendation != _phase34CRecommendation ||
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
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanSection
        section =
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanSection
            .all,
  }) {
    final buffer = StringBuffer()
      ..writeln('# Analyzer Adapter Prototype Selected Diagnostic Action Plan')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanVersion',
      )
      ..writeln('- action plan status: ${status.wire}')
      ..writeln('- selected section: ${section.wire}')
      ..writeln('- source validation status: $sourceValidationStatus')
      ..writeln('- safe for Phase 34C: $safeForPhase34C')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln();
    if (_includeSection(section, _actionsSection)) {
      _writeActionTable(buffer, actions);
    }
    if (_includeSection(section, _warningSection)) {
      _writeGroup(
        buffer,
        'Warning-Limited Follow-Up Actions',
        _byGroup(_warningLimitedFollowupActions),
      );
    }
    if (_includeSection(section, _proofSection)) {
      _writeGroup(
        buffer,
        'Proof Boundary Actions',
        _byGroup(_proofBoundaryActions),
      );
    }
    if (_includeSection(section, _guardsSection)) {
      _writeGroup(
        buffer,
        'Excluded Guard And Denied Field Protection Actions',
        actions.where(
          (action) =>
              action.actionGroup == _excludedGuardActions ||
              action.actionGroup == _deniedFieldProtectionActions,
        ),
      );
    }
    if (_includeSection(section, _blockedSection)) {
      _writeGroup(
        buffer,
        'Blocked Integration Actions',
        _byGroup(_blockedIntegrationActions),
      );
    }
    if (_includeSection(section, _recommendationSection)) {
      buffer
        ..writeln('## Recommendation')
        ..writeln('- safe for Phase 34C: $safeForPhase34C')
        ..writeln('- next recommendation: $nextRecommendation')
        ..writeln(
          '- phase34C requirement actions: $phase34CRequirementActionCount',
        )
        ..writeln('- findings: ${_ids(findings)}')
        ..writeln();
    }
    return buffer.toString();
  }

  String renderJson({
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanSection
        section =
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanSection
            .all,
  }) {
    return const JsonEncoder.withIndent(' ').convert(toJson(section: section));
  }

  Map<String, Object?> toJson({
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanSection
        section =
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanSection
            .all,
  }) {
    final payload = <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanVersion,
      'status': status.wire,
      'section': section.wire,
      'sourceValidationStatus': sourceValidationStatus,
      'safeForPhase34C': safeForPhase34C,
      'nextRecommendation': nextRecommendation,
      'counts': <String, Object?>{
        'totalActions': totalActions,
        'safeInternalSupportActionCount': safeInternalSupportActionCount,
        'warningLimitedFollowupActionCount': warningLimitedFollowupActionCount,
        'proofBoundaryActionCount': proofBoundaryActionCount,
        'excludedGuardActionCount': excludedGuardActionCount,
        'deniedFieldProtectionActionCount': deniedFieldProtectionActionCount,
        'prototypeSkeletonImprovementActionCount':
            prototypeSkeletonImprovementActionCount,
        'diagnosticCoverageActionCount': diagnosticCoverageActionCount,
        'futureRuntimePrerequisiteActionCount':
            futureRuntimePrerequisiteActionCount,
        'blockedIntegrationActionCount': blockedIntegrationActionCount,
        'phase34CRequirementActionCount': phase34CRequirementActionCount,
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
      'findings': findings,
    };
    if (_includeSection(section, _actionsSection)) {
      payload['actions'] = actions.map((action) => action.toJson()).toList();
    }
    if (_includeSection(section, _warningSection)) {
      payload['warning'] = _byGroup(
        _warningLimitedFollowupActions,
      ).map((action) => action.toJson()).toList();
    }
    if (_includeSection(section, _proofSection)) {
      payload['proof'] = _byGroup(
        _proofBoundaryActions,
      ).map((action) => action.toJson()).toList();
    }
    if (_includeSection(section, _guardsSection)) {
      payload['guards'] = actions
          .where(
            (action) =>
                action.actionGroup == _excludedGuardActions ||
                action.actionGroup == _deniedFieldProtectionActions,
          )
          .map((action) => action.toJson())
          .toList();
    }
    if (_includeSection(section, _blockedSection)) {
      payload['blocked'] = _byGroup(
        _blockedIntegrationActions,
      ).map((action) => action.toJson()).toList();
    }
    if (_includeSection(section, _recommendationSection)) {
      payload['recommendation'] = <String, Object?>{
        'safeForPhase34C': safeForPhase34C,
        'nextRecommendation': nextRecommendation,
        'phase34CRequirementActionCount': phase34CRequirementActionCount,
      };
    }
    return payload;
  }

  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
  >
  _byGroup(String group) =>
      actions.where((action) => action.actionGroup == group);
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanSection {
  all('all'),
  actions('actions'),
  warning('warning'),
  proof('proof'),
  guards('guards'),
  blocked('blocked'),
  recommendation('recommendation');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanSection(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan();

  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanResult
  evaluate({
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationResult?
    validationResult,
  }) {
    final source =
        validationResult ??
        const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidation()
            .evaluate();
    if (source.hasUnsafePolicyViolation || !source.safeForPhase34B) {
      return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanResult(
        status:
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanStatus
                .blockedByUnsafeSelectedDiagnosticValidation,
        sourceValidationStatus: source.status.wire,
        actions:
            const <
              DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
            >[],
        findings: const <String>['unsafePhase34AInput'],
        safeForPhase34C: false,
        nextRecommendation:
            'blockedByUnsafeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan',
      );
    }

    final records =
        <DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord>[
          for (final row in source.validationRows) _actionForRow(row),
          _deniedFieldProtectionAction(),
          _prototypeSkeletonImprovementAction(),
          _diagnosticCoverageAction(),
          _futureRuntimePrerequisiteAction(),
          _blockedIntegrationAction(),
          _phase34CRequirementAction(),
        ];
    final findings =
        const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanValidator()
            .validateActions(records);
    final safeForPhase34C = findings.isEmpty;
    final status = !safeForPhase34C
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanStatus
              .blockedByPolicyBoundary
        : records.any(
            (record) =>
                record.warningReasons.isNotEmpty ||
                record.proofLimitReasons.isNotEmpty,
          )
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanStatus
              .selectedDiagnosticActionPlanReadyWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanStatus
              .selectedDiagnosticActionPlanReadyClean;
    return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanResult(
      status: status,
      sourceValidationStatus: source.status.wire,
      actions: records,
      findings: findings,
      safeForPhase34C: safeForPhase34C,
      nextRecommendation: safeForPhase34C
          ? _phase34CRecommendation
          : 'blockedByUnsafeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanValidator {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanValidator();

  List<String> validateActions(
    Iterable<
      DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
    >
    actions,
  ) {
    final records = actions.toList();
    final findings = <String>[
      if (!records.any(
        (record) => record.actionGroup == _phase34CRequirementActions,
      ))
        'missingPhase34CRequirement',
    ];
    for (final record in records) {
      findings.addAll(validateAction(record));
    }
    return _sorted(findings);
  }

  List<String> validateAction(
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
    action,
  ) {
    final activeDenied = _activeDeniedFieldIds(action).toSet();
    return _sorted(<String>[
      if (!_allowedActionGroups.contains(action.actionGroup))
        'unknownActionGroup',
      if (!_allowedActionTypes.contains(action.actionType)) 'unknownActionType',
      if (action.implementationAllowedNow &&
          action.blockedBoundaryIds.contains('runtimeImplementation'))
        'runtimeImplementationEnabled',
      if (action.implementationAllowedNow &&
          action.blockedBoundaryIds.contains('analyzerWiring'))
        'analyzerWiringEnabled',
      if (action.implementationAllowedNow &&
          action.blockedBoundaryIds.contains('executablePrototypeBehavior'))
        'executablePrototypeEnabled',
      if (action.implementationAllowedNow &&
          action.blockedBoundaryIds.any(
            const {'directEngineCall', 'engineResults'}.contains,
          ))
        'engineCallEnabled',
      if (action.implementationAllowedNow &&
          action.blockedBoundaryIds.contains('schedulerExecution'))
        'schedulerExecutionEnabled',
      if (action.implementationAllowedNow &&
          action.blockedBoundaryIds.contains('productAdapterBehavior'))
        'productAdapterEnabled',
      if (action.implementationAllowedNow &&
          action.blockedBoundaryIds.contains('savedAnalysisIntegration'))
        'savedAnalysisIntegrationEnabled',
      if (action.implementationAllowedNow &&
          action.blockedBoundaryIds.any(
            const {'uiTarget', 'backendTarget', 'persistenceWrite'}.contains,
          ))
        'uiBackendPersistenceEnabled',
      if (_isQuietAction(action) && action.actionGroup != _excludedGuardActions)
        'quietPreparatoryPromotion',
      if (action.sourceCaseId == _pvMultiPvBoundaryCaseId &&
          action.actionGroup != _proofBoundaryActions)
        'pvMultiPvPromotion',
      if (action.androidProofIds.any(_phase32ECaseIds.contains))
        'phase32ECapturedProofClaim',
      if (action.ownerProofRequired &&
          !action.proofLimitReasons.any(
            (reason) => reason.contains('pvMultiPv'),
          ))
        'ownerProofWithoutPvMultiPvReason',
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

DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
_actionForRow(
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationRow
  row,
) {
  final group = switch (row.diagnosticRole) {
    'developerDiagnosticInputSupport' => _safeInternalSupportActions,
    'warningLimited' => _warningLimitedFollowupActions,
    'proofBoundaryOnly' => _proofBoundaryActions,
    'excludedNegativeGuard' => _excludedGuardActions,
    _ => _diagnosticCoverageActions,
  };
  final type = switch (group) {
    _safeInternalSupportActions => 'futureInternalPrototypeImprovement',
    _warningLimitedFollowupActions => 'guardedWarningLimitedFollowup',
    _proofBoundaryActions => 'proofBoundaryClarity',
    _excludedGuardActions => 'excludedGuardPreservation',
    _ => 'diagnosticCoverage',
  };
  final priority = switch (group) {
    _proofBoundaryActions || _excludedGuardActions => 'high',
    _warningLimitedFollowupActions || _safeInternalSupportActions => 'medium',
    _ => 'medium',
  };
  return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord(
    actionId: 'action-${row.sourceCaseId}',
    sourceCaseId: row.sourceCaseId,
    sourcePhase: row.sourcePhase,
    sourceDiagnosticRole: row.diagnosticRole,
    actionGroup: group,
    actionType: type,
    priority: priority,
    supportAreaIds: row.supportAreaIds,
    warningReasons: row.warningReasons,
    proofLimitReasons: row.proofLimitReasons,
    blockedBoundaryIds: row.blockedBoundaryIds,
    androidProofIds: row.androidProofIds,
    ownerProofRequired: false,
    implementationAllowedNow: false,
    requiresFutureValidation: true,
    recommendedNextStep: _phase34CRecommendation,
    deniedFieldIds: const <String>[],
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
_deniedFieldProtectionAction() {
  return _systemAction(
    actionId: 'action-denied-field-protection',
    group: _deniedFieldProtectionActions,
    type: 'deniedFieldProtection',
    priority: 'critical',
    deniedFieldIds: _deniedFieldIds,
    supportAreaIds: const <String>['deniedFieldBoundary'],
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
_prototypeSkeletonImprovementAction() {
  return _systemAction(
    actionId: 'action-prototype-skeleton-improvement',
    group: _prototypeSkeletonImprovementActions,
    type: 'prototypeSkeletonImprovement',
    priority: 'medium',
    supportAreaIds: const <String>['developerOnlySkeletonPatchSet'],
    implementationAllowedNow: true,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
_diagnosticCoverageAction() {
  return _systemAction(
    actionId: 'action-diagnostic-coverage',
    group: _diagnosticCoverageActions,
    type: 'diagnosticCoverage',
    priority: 'medium',
    supportAreaIds: const <String>['selectedGoldenDiagnosticCoverage'],
    implementationAllowedNow: true,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
_futureRuntimePrerequisiteAction() {
  return _systemAction(
    actionId: 'action-future-runtime-prerequisite',
    group: _futureRuntimePrerequisiteActions,
    type: 'futureRuntimePrerequisite',
    priority: 'blocked',
    supportAreaIds: const <String>['futureRuntimePrerequisiteOnly'],
    blockedBoundaryIds: const <String>[
      'runtimeImplementation',
      'analyzerWiring',
      'executablePrototypeBehavior',
    ],
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
_blockedIntegrationAction() {
  return _systemAction(
    actionId: 'action-blocked-integrations',
    group: _blockedIntegrationActions,
    type: 'blockedIntegration',
    priority: 'blocked',
    supportAreaIds: const <String>['blockedIntegrationBoundary'],
    blockedBoundaryIds: const <String>[
      'analyzerWiring',
      'backendTarget',
      'directEngineCall',
      'engineResults',
      'persistenceWrite',
      'productAdapterBehavior',
      'runtimeImplementation',
      'savedAnalysisIntegration',
      'schedulerExecution',
      'uiTarget',
    ],
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
_phase34CRequirementAction() {
  return _systemAction(
    actionId: 'action-phase34c-requirement',
    group: _phase34CRequirementActions,
    type: 'phase34CRequirement',
    priority: 'high',
    supportAreaIds: const <String>['implementDeveloperOnlyActionPlanPatchSet'],
    implementationAllowedNow: true,
    recommendedNextStep: _phase34CRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
_systemAction({
  required String actionId,
  required String group,
  required String type,
  required String priority,
  required List<String> supportAreaIds,
  List<String> deniedFieldIds = const <String>[],
  List<String> blockedBoundaryIds = const <String>[],
  bool implementationAllowedNow = false,
  String recommendedNextStep = _phase34CRecommendation,
}) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord(
    actionId: actionId,
    sourceCaseId: 'system',
    sourcePhase: 'Phase 34B',
    sourceDiagnosticRole: 'systemAction',
    actionGroup: group,
    actionType: type,
    priority: priority,
    supportAreaIds: supportAreaIds,
    warningReasons: const <String>['developerOnlyActionPlanNoRuntimeExecution'],
    proofLimitReasons: const <String>[],
    blockedBoundaryIds: blockedBoundaryIds,
    androidProofIds: const <String>[],
    ownerProofRequired: false,
    implementationAllowedNow: implementationAllowedNow,
    requiresFutureValidation: true,
    recommendedNextStep: recommendedNextStep,
    deniedFieldIds: deniedFieldIds,
  );
}

void _writeActionTable(
  StringBuffer buffer,
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
  >
  actions,
) {
  buffer
    ..writeln('## Action Record Table')
    ..writeln(
      '| Action | Source case | Group | Type | Priority | Allowed now | Future validation | Next step |',
    )
    ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- |');
  for (final action in actions) {
    buffer.writeln(
      '| ${action.actionId} | ${action.sourceCaseId} | ${action.actionGroup} | ${action.actionType} | ${action.priority} | ${action.implementationAllowedNow} | ${action.requiresFutureValidation} | ${action.recommendedNextStep} |',
    );
  }
  buffer.writeln();
}

void _writeGroup(
  StringBuffer buffer,
  String title,
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
  >
  actions,
) {
  buffer
    ..writeln('## $title')
    ..writeln(
      '| Action | Source case | Priority | Proof limits | Blocked boundaries | Denied fields |',
    )
    ..writeln('| --- | --- | --- | --- | --- | --- |');
  for (final action in actions) {
    buffer.writeln(
      '| ${action.actionId} | ${action.sourceCaseId} | ${action.priority} | ${_ids(action.proofLimitReasons)} | ${_ids(action.blockedBoundaryIds)} | ${_ids(action.deniedFieldIds)} |',
    );
  }
  buffer.writeln();
}

bool _includeSection(
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanSection
  selected,
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanSection
  target,
) {
  return selected ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanSection
              .all ||
      selected == target;
}

bool _isQuietAction(
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord action,
) {
  return action.supportAreaIds.contains('quietMove') ||
      action.supportAreaIds.contains('quietPreparatoryMove');
}

Iterable<String> _activeDeniedFieldIds(
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord action,
) {
  if (!action.implementationAllowedNow ||
      action.actionGroup == _deniedFieldProtectionActions) {
    return const <String>[];
  }
  return action.deniedFieldIds;
}

int _countActiveFields(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
  >
  actions,
  Set<String> fields,
) {
  var count = 0;
  for (final action in actions) {
    count += _activeDeniedFieldIds(action).where(fields.contains).length;
  }
  return count;
}

int _countBoundary(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
  >
  actions,
  Set<String> fields,
) {
  return actions
      .where(
        (action) =>
            action.implementationAllowedNow &&
            action.blockedBoundaryIds.any(fields.contains),
      )
      .length;
}

int _countGroup(
  Iterable<
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
  >
  actions,
  String group,
) {
  return actions.where((action) => action.actionGroup == group).length;
}

String _ids(Iterable<String> values) {
  final sorted = _sorted(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

List<String> _sorted(Iterable<String> values) {
  return values.where((value) => value.trim().isNotEmpty).toSet().toList()
    ..sort();
}

const _phase34CRecommendation =
    'implementAnalyzerAdapterPrototypeActionPlanPatchSet';

const _safeInternalSupportActions = 'safeInternalSupportActions';
const _warningLimitedFollowupActions = 'warningLimitedFollowupActions';
const _proofBoundaryActions = 'proofBoundaryActions';
const _excludedGuardActions = 'excludedGuardActions';
const _deniedFieldProtectionActions = 'deniedFieldProtectionActions';
const _prototypeSkeletonImprovementActions =
    'prototypeSkeletonImprovementActions';
const _diagnosticCoverageActions = 'diagnosticCoverageActions';
const _futureRuntimePrerequisiteActions = 'futureRuntimePrerequisiteActions';
const _blockedIntegrationActions = 'blockedIntegrationActions';
const _phase34CRequirementActions = 'phase34CRequirementActions';

const _allowedActionGroups = <String>{
  _safeInternalSupportActions,
  _warningLimitedFollowupActions,
  _proofBoundaryActions,
  _excludedGuardActions,
  _deniedFieldProtectionActions,
  _prototypeSkeletonImprovementActions,
  _diagnosticCoverageActions,
  _futureRuntimePrerequisiteActions,
  _blockedIntegrationActions,
  _phase34CRequirementActions,
};

const _allowedActionTypes = <String>{
  'futureInternalPrototypeImprovement',
  'guardedWarningLimitedFollowup',
  'proofBoundaryClarity',
  'excludedGuardPreservation',
  'deniedFieldProtection',
  'prototypeSkeletonImprovement',
  'diagnosticCoverage',
  'futureRuntimePrerequisite',
  'blockedIntegration',
  'phase34CRequirement',
};

const _actionsSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanSection
        .actions;
const _warningSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanSection
        .warning;
const _proofSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanSection
        .proof;
const _guardsSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanSection
        .guards;
const _blockedSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanSection
        .blocked;
const _recommendationSection =
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanSection
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

const _deniedFieldIds = <String>[
  'androidCollectorRequirement',
  'analyzerWiring',
  'brilliantGreatMissStyleLabels',
  'classifierLabels',
  'cpLoss',
  'directEngineCall',
  'executablePrototypeBehavior',
  'finalMoveLabel',
  'moveRanking',
  'numericMoveScore',
  'officialAccuracy',
  'persistenceWrite',
  'productAdapterBehavior',
  'productLabel',
  'pvDump',
  'rawUci',
  'runtimeImplementation',
  'savedAnalysisIntegration',
  'schedulerExecution',
  'stockfishCommand',
  'thresholds',
  'winProbability',
];

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

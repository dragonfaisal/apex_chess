/// Developer-only integration experiment for the local review stack.
library;

import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_orchestration_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';

enum LocalReviewIntegrationSourceType {
  schedulerInputs('schedulerInputs'),
  parsedPositions('parsedPositions');

  const LocalReviewIntegrationSourceType(this.wire);

  final String wire;
}

enum LocalReviewIntegrationMode {
  planOnly('planOnly'),
  fastThenPlanDeep('fastThenPlanDeep'),
  fastThenExecuteSelectedDeep('fastThenExecuteSelectedDeep');

  const LocalReviewIntegrationMode(this.wire);

  final String wire;
}

enum LocalReviewIntegrationStatus {
  completed('completed'),
  completedWithWarnings('completedWithWarnings'),
  partialFailure('partialFailure'),
  failed('failed'),
  rejected('rejected');

  const LocalReviewIntegrationStatus(this.wire);

  final String wire;
}

enum LocalReviewIntegrationBudgetPresetId {
  ecoSafe('ecoSafe'),
  balancedDefault('balancedDefault'),
  performanceMeasured('performanceMeasured'),
  ownerStrongLocal('ownerStrongLocal');

  const LocalReviewIntegrationBudgetPresetId(this.wire);

  final String wire;
}

class LocalReviewIntegrationBudgetPreset {
  const LocalReviewIntegrationBudgetPreset({
    required this.id,
    required this.label,
    required this.profile,
    required this.maxDeepCandidates,
    required this.maxDeepEngineCalls,
    required this.maxTotalEngineCalls,
    required this.maxTotalElapsedBudgetMs,
  }) : assert(maxDeepCandidates >= 0),
       assert(maxDeepEngineCalls >= 0),
       assert(maxTotalEngineCalls >= 0),
       assert(maxTotalElapsedBudgetMs >= 0);

  final LocalReviewIntegrationBudgetPresetId id;
  final String label;
  final LocalSchedulerProfile profile;
  final int maxDeepCandidates;
  final int maxDeepEngineCalls;
  final int maxTotalEngineCalls;
  final int maxTotalElapsedBudgetMs;

  static const ecoSafe = LocalReviewIntegrationBudgetPreset(
    id: LocalReviewIntegrationBudgetPresetId.ecoSafe,
    label: 'Eco Safe',
    profile: LocalSchedulerProfile.eco,
    maxDeepCandidates: 0,
    maxDeepEngineCalls: 0,
    maxTotalEngineCalls: 12,
    maxTotalElapsedBudgetMs: 5000,
  );

  static const balancedDefault = LocalReviewIntegrationBudgetPreset(
    id: LocalReviewIntegrationBudgetPresetId.balancedDefault,
    label: 'Balanced Default',
    profile: LocalSchedulerProfile.balanced,
    maxDeepCandidates: 3,
    maxDeepEngineCalls: 6,
    maxTotalEngineCalls: 24,
    maxTotalElapsedBudgetMs: 15000,
  );

  static const performanceMeasured = LocalReviewIntegrationBudgetPreset(
    id: LocalReviewIntegrationBudgetPresetId.performanceMeasured,
    label: 'Performance Measured',
    profile: LocalSchedulerProfile.performance,
    maxDeepCandidates: 5,
    maxDeepEngineCalls: 10,
    maxTotalEngineCalls: 40,
    maxTotalElapsedBudgetMs: 30000,
  );

  static const ownerStrongLocal = LocalReviewIntegrationBudgetPreset(
    id: LocalReviewIntegrationBudgetPresetId.ownerStrongLocal,
    label: 'Owner Strong Local',
    profile: LocalSchedulerProfile.owner,
    maxDeepCandidates: 8,
    maxDeepEngineCalls: 16,
    maxTotalEngineCalls: 64,
    maxTotalElapsedBudgetMs: 60000,
  );

  static const values = <LocalReviewIntegrationBudgetPreset>[
    ecoSafe,
    balancedDefault,
    performanceMeasured,
    ownerStrongLocal,
  ];
}

class LocalReviewIntegrationExperimentRequest {
  const LocalReviewIntegrationExperimentRequest._({
    required this.sourceType,
    required this.schedulerInputs,
    required this.parsedPositions,
    this.profile,
    this.budgetPreset = LocalReviewIntegrationBudgetPreset.balancedDefault,
    this.mode = LocalReviewIntegrationMode.planOnly,
    this.providedFastEvidence = const <GameLevelProvidedFastEvidence>[],
    this.maxPositions,
    this.maxFastEngineCalls,
    this.maxDeepCandidates,
    this.maxDeepEngineCalls,
    this.maxTotalEngineCalls,
    this.maxTotalElapsedBudgetMs,
    this.failFast = false,
    this.lowPower = false,
    this.requestId,
    this.timeoutBudgetOverride,
  }) : assert(maxPositions == null || maxPositions >= 0),
       assert(maxFastEngineCalls == null || maxFastEngineCalls >= 0),
       assert(maxDeepCandidates == null || maxDeepCandidates >= 0),
       assert(maxDeepEngineCalls == null || maxDeepEngineCalls >= 0),
       assert(maxTotalEngineCalls == null || maxTotalEngineCalls >= 0),
       assert(maxTotalElapsedBudgetMs == null || maxTotalElapsedBudgetMs >= 0);

  const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs({
    required List<LocalAnalysisPositionInput> positions,
    LocalSchedulerProfile? profile,
    LocalReviewIntegrationBudgetPreset budgetPreset =
        LocalReviewIntegrationBudgetPreset.balancedDefault,
    LocalReviewIntegrationMode mode = LocalReviewIntegrationMode.planOnly,
    List<GameLevelProvidedFastEvidence> providedFastEvidence =
        const <GameLevelProvidedFastEvidence>[],
    int? maxPositions,
    int? maxFastEngineCalls,
    int? maxDeepCandidates,
    int? maxDeepEngineCalls,
    int? maxTotalEngineCalls,
    int? maxTotalElapsedBudgetMs,
    bool failFast = false,
    bool lowPower = false,
    String? requestId,
    Duration? timeoutBudgetOverride,
  }) : this._(
         sourceType: LocalReviewIntegrationSourceType.schedulerInputs,
         schedulerInputs: positions,
         parsedPositions: const <LocalReviewOrchestrationPosition>[],
         profile: profile,
         budgetPreset: budgetPreset,
         mode: mode,
         providedFastEvidence: providedFastEvidence,
         maxPositions: maxPositions,
         maxFastEngineCalls: maxFastEngineCalls,
         maxDeepCandidates: maxDeepCandidates,
         maxDeepEngineCalls: maxDeepEngineCalls,
         maxTotalEngineCalls: maxTotalEngineCalls,
         maxTotalElapsedBudgetMs: maxTotalElapsedBudgetMs,
         failFast: failFast,
         lowPower: lowPower,
         requestId: requestId,
         timeoutBudgetOverride: timeoutBudgetOverride,
       );

  const LocalReviewIntegrationExperimentRequest.fromParsedPositions({
    required List<LocalReviewOrchestrationPosition> positions,
    LocalSchedulerProfile? profile,
    LocalReviewIntegrationBudgetPreset budgetPreset =
        LocalReviewIntegrationBudgetPreset.balancedDefault,
    LocalReviewIntegrationMode mode = LocalReviewIntegrationMode.planOnly,
    List<GameLevelProvidedFastEvidence> providedFastEvidence =
        const <GameLevelProvidedFastEvidence>[],
    int? maxPositions,
    int? maxFastEngineCalls,
    int? maxDeepCandidates,
    int? maxDeepEngineCalls,
    int? maxTotalEngineCalls,
    int? maxTotalElapsedBudgetMs,
    bool failFast = false,
    bool lowPower = false,
    String? requestId,
    Duration? timeoutBudgetOverride,
  }) : this._(
         sourceType: LocalReviewIntegrationSourceType.parsedPositions,
         schedulerInputs: const <LocalAnalysisPositionInput>[],
         parsedPositions: positions,
         profile: profile,
         budgetPreset: budgetPreset,
         mode: mode,
         providedFastEvidence: providedFastEvidence,
         maxPositions: maxPositions,
         maxFastEngineCalls: maxFastEngineCalls,
         maxDeepCandidates: maxDeepCandidates,
         maxDeepEngineCalls: maxDeepEngineCalls,
         maxTotalEngineCalls: maxTotalEngineCalls,
         maxTotalElapsedBudgetMs: maxTotalElapsedBudgetMs,
         failFast: failFast,
         lowPower: lowPower,
         requestId: requestId,
         timeoutBudgetOverride: timeoutBudgetOverride,
       );

  final LocalReviewIntegrationSourceType sourceType;
  final List<LocalAnalysisPositionInput> schedulerInputs;
  final List<LocalReviewOrchestrationPosition> parsedPositions;
  final LocalSchedulerProfile? profile;
  final LocalReviewIntegrationBudgetPreset budgetPreset;
  final LocalReviewIntegrationMode mode;
  final List<GameLevelProvidedFastEvidence> providedFastEvidence;
  final int? maxPositions;
  final int? maxFastEngineCalls;
  final int? maxDeepCandidates;
  final int? maxDeepEngineCalls;
  final int? maxTotalEngineCalls;
  final int? maxTotalElapsedBudgetMs;
  final bool failFast;
  final bool lowPower;
  final String? requestId;
  final Duration? timeoutBudgetOverride;

  LocalSchedulerProfile get effectiveProfile => profile ?? budgetPreset.profile;

  int get effectiveMaxDeepCandidates =>
      maxDeepCandidates ?? budgetPreset.maxDeepCandidates;

  int get effectiveMaxDeepEngineCalls =>
      maxDeepEngineCalls ?? budgetPreset.maxDeepEngineCalls;

  int get effectiveMaxTotalEngineCalls =>
      maxTotalEngineCalls ?? budgetPreset.maxTotalEngineCalls;

  int get effectiveMaxTotalElapsedBudgetMs =>
      maxTotalElapsedBudgetMs ?? budgetPreset.maxTotalElapsedBudgetMs;
}

class LocalReviewIntegrationBudgetPressureSummary {
  const LocalReviewIntegrationBudgetPressureSummary({
    required this.candidatesSuppressedByBudget,
    required this.budgetViolationCount,
    required this.warningCount,
    required this.timeoutCount,
    required this.maxCandidatePriority,
  }) : assert(candidatesSuppressedByBudget >= 0),
       assert(budgetViolationCount >= 0),
       assert(warningCount >= 0),
       assert(timeoutCount >= 0),
       assert(maxCandidatePriority >= 0);

  final int candidatesSuppressedByBudget;
  final int budgetViolationCount;
  final int warningCount;
  final int timeoutCount;
  final int maxCandidatePriority;

  bool get hasPressure =>
      candidatesSuppressedByBudget > 0 ||
      budgetViolationCount > 0 ||
      timeoutCount > 0;

  String get debugSummary =>
      'budgetSuppressed=$candidatesSuppressedByBudget '
      'violations=$budgetViolationCount warnings=$warningCount '
      'timeouts=$timeoutCount maxPriority=$maxCandidatePriority';

  static const empty = LocalReviewIntegrationBudgetPressureSummary(
    candidatesSuppressedByBudget: 0,
    budgetViolationCount: 0,
    warningCount: 0,
    timeoutCount: 0,
    maxCandidatePriority: 0,
  );
}

class LocalReviewIntegrationExperimentResult {
  const LocalReviewIntegrationExperimentResult({
    required this.requestId,
    required this.status,
    required this.sourcePositionCount,
    required this.mappedPositionCount,
    required this.mode,
    required this.profile,
    required this.budgetPreset,
    required this.purePlanCandidateCount,
    required this.selectedDeepCount,
    required this.executedDeepCount,
    required this.fastEngineCalls,
    required this.deepEngineCalls,
    required this.totalEngineCalls,
    required this.totalElapsedMs,
    required this.selectedDeepRatio,
    required this.warnings,
    required this.failures,
    required this.mappingWarnings,
    required this.budgetPressure,
    required this.telemetry,
    required this.purePlanResult,
    required this.executionResult,
    required this.developerReport,
  }) : assert(sourcePositionCount >= 0),
       assert(mappedPositionCount >= 0),
       assert(purePlanCandidateCount >= 0),
       assert(selectedDeepCount >= 0),
       assert(executedDeepCount >= 0),
       assert(fastEngineCalls >= 0),
       assert(deepEngineCalls >= 0),
       assert(totalEngineCalls >= 0),
       assert(totalElapsedMs >= 0),
       assert(selectedDeepRatio >= 0);

  final String? requestId;
  final LocalReviewIntegrationStatus status;
  final int sourcePositionCount;
  final int mappedPositionCount;
  final LocalReviewIntegrationMode mode;
  final LocalSchedulerProfile profile;
  final LocalReviewIntegrationBudgetPreset budgetPreset;
  final int purePlanCandidateCount;
  final int selectedDeepCount;
  final int executedDeepCount;
  final int fastEngineCalls;
  final int deepEngineCalls;
  final int totalEngineCalls;
  final int totalElapsedMs;
  final double selectedDeepRatio;
  final List<String> warnings;
  final List<String> failures;
  final List<String> mappingWarnings;
  final LocalReviewIntegrationBudgetPressureSummary budgetPressure;
  final GameLevelDeepGatingTelemetry telemetry;
  final GameLevelDeepGatingExperimentResult purePlanResult;
  final GameLevelDeepGatingExperimentResult? executionResult;
  final String developerReport;

  String get debugSummary =>
      'request=${requestId ?? "-"} status=${status.wire} '
      'source=$sourcePositionCount mapped=$mappedPositionCount '
      'mode=${mode.wire} profile=${profile.id.wire} '
      'preset=${budgetPreset.id.wire} pureCandidates=$purePlanCandidateCount '
      'selected=$selectedDeepCount deepExecuted=$executedDeepCount '
      'engineCalls=$totalEngineCalls elapsedMs=$totalElapsedMs';

  String renderDeveloperReport() => developerReport;
}

class LocalReviewIntegrationExperiment {
  const LocalReviewIntegrationExperiment({
    required GameLevelDeepGatingExperiment deepGating,
  }) : _deepGating = deepGating;

  final GameLevelDeepGatingExperiment _deepGating;

  Future<LocalReviewIntegrationExperimentResult> run(
    LocalReviewIntegrationExperimentRequest request,
  ) async {
    final stopwatch = Stopwatch()..start();
    final mapped = _mapPositions(request);
    final warnings = <String>[...mapped.mappingWarnings];

    final purePlan = await _deepGating.run(
      _deepGatingRequest(
        request: request,
        positions: mapped.positions,
        mode: GameLevelDeepGatingMode.planOnly,
        requestId: _phaseRequestId(request.requestId, 'plan'),
      ),
    );

    GameLevelDeepGatingExperimentResult? execution;
    if (request.mode != LocalReviewIntegrationMode.planOnly) {
      execution = await _deepGating.run(
        _deepGatingRequest(
          request: request,
          positions: mapped.positions,
          mode: _modeFor(request.mode),
          requestId: _phaseRequestId(request.requestId, 'execute'),
        ),
      );
    }

    stopwatch.stop();
    final primary = execution ?? purePlan;
    warnings
      ..addAll(purePlan.warnings.map((warning) => 'plan: $warning'))
      ..addAll(
        execution?.warnings.map((warning) => 'execution: $warning') ??
            const <String>[],
      );
    final failures = <String>[
      ...purePlan.failures.map((failure) => 'plan: $failure'),
      ...?execution?.failures.map((failure) => 'execution: $failure'),
    ];
    final status = _statusFor(
      mapped: mapped,
      primary: primary,
      warnings: warnings,
      failures: failures,
    );
    final budgetPressure = _budgetPressureFor(primary);
    final selectedRatio = _ratio(
      primary.selectedDeepCount,
      mapped.positions.length,
    );

    final result = LocalReviewIntegrationExperimentResult(
      requestId: request.requestId,
      status: status,
      sourcePositionCount: mapped.sourcePositionCount,
      mappedPositionCount: mapped.positions.length,
      mode: request.mode,
      profile: request.effectiveProfile,
      budgetPreset: request.budgetPreset,
      purePlanCandidateCount: purePlan.candidateCount,
      selectedDeepCount: primary.selectedDeepCount,
      executedDeepCount: primary.executedDeepCount,
      fastEngineCalls: primary.fastEngineCalls,
      deepEngineCalls: primary.deepEngineCalls,
      totalEngineCalls: primary.totalEngineCalls,
      totalElapsedMs: stopwatch.elapsedMilliseconds,
      selectedDeepRatio: selectedRatio,
      warnings: List<String>.unmodifiable(warnings),
      failures: List<String>.unmodifiable(failures),
      mappingWarnings: mapped.mappingWarnings,
      budgetPressure: budgetPressure,
      telemetry: primary.telemetry,
      purePlanResult: purePlan,
      executionResult: execution,
      developerReport: _renderDeveloperReport(
        request: request,
        mapped: mapped,
        status: status,
        purePlan: purePlan,
        primary: primary,
        budgetPressure: budgetPressure,
        selectedRatio: selectedRatio,
        warnings: warnings,
        failures: failures,
        elapsedMilliseconds: stopwatch.elapsedMilliseconds,
      ),
    );
    return result;
  }

  static GameLevelDeepGatingExperimentRequest _deepGatingRequest({
    required LocalReviewIntegrationExperimentRequest request,
    required List<LocalAnalysisPositionInput> positions,
    required GameLevelDeepGatingMode mode,
    required String? requestId,
  }) {
    return GameLevelDeepGatingExperimentRequest(
      positions: positions,
      profile: request.effectiveProfile,
      providedFastEvidence: request.providedFastEvidence,
      maxPositions: positions.length,
      maxFastEngineCalls: request.maxFastEngineCalls,
      maxDeepCandidates: request.effectiveMaxDeepCandidates,
      maxDeepEngineCalls: request.effectiveMaxDeepEngineCalls,
      maxTotalEngineCalls: request.effectiveMaxTotalEngineCalls,
      maxTotalElapsedBudgetMs: request.effectiveMaxTotalElapsedBudgetMs,
      failFast: request.failFast,
      lowPower: request.lowPower,
      requestId: requestId,
      mode: mode,
      timeoutBudgetOverride: request.timeoutBudgetOverride,
    );
  }

  static _MappedIntegrationPositions _mapPositions(
    LocalReviewIntegrationExperimentRequest request,
  ) {
    final sourcePositions = switch (request.sourceType) {
      LocalReviewIntegrationSourceType.schedulerInputs =>
        request.schedulerInputs.length,
      LocalReviewIntegrationSourceType.parsedPositions =>
        request.parsedPositions.length,
    };
    final positions = switch (request.sourceType) {
      LocalReviewIntegrationSourceType.schedulerInputs =>
        request.schedulerInputs,
      LocalReviewIntegrationSourceType.parsedPositions =>
        request.parsedPositions.map(_fromParsedPosition).toList(),
    };
    final limit = request.maxPositions == null
        ? positions.length
        : _minInt(request.maxPositions!, positions.length);
    final limited = List<LocalAnalysisPositionInput>.unmodifiable(
      positions.take(limit),
    );
    final mappingWarnings = <String>[
      if (request.sourceType ==
          LocalReviewIntegrationSourceType.parsedPositions)
        for (var index = 0; index < request.parsedPositions.length; index++)
          if (request.parsedPositions[index].fen.trim().isEmpty)
            'parsed position $index has empty FEN',
      if (limit < sourcePositions)
        'maxPositions limited source positions from $sourcePositions to $limit',
    ];

    return _MappedIntegrationPositions(
      sourcePositionCount: sourcePositions,
      positions: limited,
      mappingWarnings: List<String>.unmodifiable(mappingWarnings),
    );
  }

  static LocalAnalysisPositionInput _fromParsedPosition(
    LocalReviewOrchestrationPosition position,
  ) {
    return LocalAnalysisPositionInput(
      fen: position.fen.trim(),
      moveNumber: position.moveNumber,
      plyIndex: position.plyIndex,
      legalMoveCount: position.legalMoveCount,
      isOpeningKnown: position.isOpeningKnown,
      isOnlyLegalMove: position.isOnlyLegalMove,
      materialDeltaAfterMoveCp: position.materialDeltaAfterMoveCp,
      previousEvalCp: position.previousEvalCp,
      provisionalEvalCp: position.provisionalEvalCp,
      candidateEvalSpreadCp: position.candidateEvalSpreadCp,
      hasCheck: position.hasCheck,
      givesCheck: position.givesCheck,
      isCapture: position.isCapture,
      isPromotion: position.isPromotion,
      isCastle: position.isCastle,
      tags: [
        ...position.tags,
        'source:parsed',
        if (position.reference != null) 'ref:${position.reference}',
      ],
    );
  }

  static LocalReviewIntegrationStatus _statusFor({
    required _MappedIntegrationPositions mapped,
    required GameLevelDeepGatingExperimentResult primary,
    required List<String> warnings,
    required List<String> failures,
  }) {
    if (mapped.sourcePositionCount > 0 && mapped.positions.isEmpty) {
      return LocalReviewIntegrationStatus.rejected;
    }
    if (failures.isNotEmpty ||
        primary.status == GameLevelDeepGatingStatus.failed) {
      return LocalReviewIntegrationStatus.failed;
    }
    if (primary.status == GameLevelDeepGatingStatus.partialFailure) {
      return LocalReviewIntegrationStatus.partialFailure;
    }
    if (primary.status == GameLevelDeepGatingStatus.rejected) {
      return LocalReviewIntegrationStatus.rejected;
    }
    if (warnings.isNotEmpty ||
        primary.status == GameLevelDeepGatingStatus.completedWithWarnings) {
      return LocalReviewIntegrationStatus.completedWithWarnings;
    }
    return LocalReviewIntegrationStatus.completed;
  }

  static LocalReviewIntegrationBudgetPressureSummary _budgetPressureFor(
    GameLevelDeepGatingExperimentResult result,
  ) {
    return LocalReviewIntegrationBudgetPressureSummary(
      candidatesSuppressedByBudget:
          result.telemetry.candidatesSuppressedByBudget,
      budgetViolationCount: result.telemetry.budgetViolationCount,
      warningCount: result.telemetry.warningCount,
      timeoutCount: result.telemetry.timeoutCount,
      maxCandidatePriority: result.telemetry.maxCandidatePriority,
    );
  }

  static String _renderDeveloperReport({
    required LocalReviewIntegrationExperimentRequest request,
    required _MappedIntegrationPositions mapped,
    required LocalReviewIntegrationStatus status,
    required GameLevelDeepGatingExperimentResult purePlan,
    required GameLevelDeepGatingExperimentResult primary,
    required LocalReviewIntegrationBudgetPressureSummary budgetPressure,
    required double selectedRatio,
    required List<String> warnings,
    required List<String> failures,
    required int elapsedMilliseconds,
  }) {
    final buffer = StringBuffer()
      ..writeln('# Local Review Integration Experiment')
      ..writeln()
      ..writeln('- status: ${status.wire}')
      ..writeln('- request: ${request.requestId ?? "-"}')
      ..writeln('- source type: ${request.sourceType.wire}')
      ..writeln('- source positions: ${mapped.sourcePositionCount}')
      ..writeln('- mapped positions: ${mapped.positions.length}')
      ..writeln('- mode: ${request.mode.wire}')
      ..writeln('- profile: ${request.effectiveProfile.id.wire}')
      ..writeln('- budget preset: ${request.budgetPreset.id.wire}')
      ..writeln('- pure plan candidates: ${purePlan.candidateCount}')
      ..writeln('- selected deep: ${primary.selectedDeepCount}')
      ..writeln('- executed deep: ${primary.executedDeepCount}')
      ..writeln('- selected deep ratio: ${_formatRatio(selectedRatio)}')
      ..writeln('- fast engine calls: ${primary.fastEngineCalls}')
      ..writeln('- deep engine calls: ${primary.deepEngineCalls}')
      ..writeln('- total engine calls: ${primary.totalEngineCalls}')
      ..writeln('- elapsed ms: $elapsedMilliseconds')
      ..writeln('- budget pressure: ${budgetPressure.debugSummary}')
      ..writeln('- recommendation: ${_recommendationFor(primary)}');

    _writeCounts(
      buffer,
      'top reason codes',
      _reasonCounts(primary.selectedCandidates),
    );
    _writeCounts(
      buffer,
      'suppressions',
      _suppressionCounts(primary.suppressions),
    );
    _writeLines(buffer, 'warnings', warnings);
    _writeLines(buffer, 'failures', failures);

    return buffer.toString().trimRight();
  }

  static String _recommendationFor(GameLevelDeepGatingExperimentResult result) {
    if (result.status == GameLevelDeepGatingStatus.failed ||
        result.status == GameLevelDeepGatingStatus.partialFailure) {
      return 'fix local integration failures before wider review experiments';
    }
    if (result.telemetry.candidatesSuppressedByBudget > 0) {
      return 'review budget pressure before choosing default mobile preset';
    }
    if (result.selectedDeepCount == 0 && result.candidateCount > 0) {
      return 'keep candidate plan and increase explicit deep budget only if needed';
    }
    return 'compare measured cost on small games before product integration';
  }

  static GameLevelDeepGatingMode _modeFor(LocalReviewIntegrationMode mode) {
    return switch (mode) {
      LocalReviewIntegrationMode.planOnly => GameLevelDeepGatingMode.planOnly,
      LocalReviewIntegrationMode.fastThenPlanDeep =>
        GameLevelDeepGatingMode.fastThenPlanDeep,
      LocalReviewIntegrationMode.fastThenExecuteSelectedDeep =>
        GameLevelDeepGatingMode.fastThenExecuteSelectedDeep,
    };
  }
}

class _MappedIntegrationPositions {
  const _MappedIntegrationPositions({
    required this.sourcePositionCount,
    required this.positions,
    required this.mappingWarnings,
  });

  final int sourcePositionCount;
  final List<LocalAnalysisPositionInput> positions;
  final List<String> mappingWarnings;
}

Map<DeepCandidateReasonCode, int> _reasonCounts(
  List<DeepReanalysisCandidate> candidates,
) {
  final counts = <DeepCandidateReasonCode, int>{};
  for (final candidate in candidates) {
    for (final reason in candidate.reasonCodes) {
      if (reason == DeepCandidateReasonCode.budgetAllows) continue;
      counts[reason] = (counts[reason] ?? 0) + 1;
    }
  }
  return _sortedMap(counts);
}

Map<DeepCandidateReasonCode, int> _suppressionCounts(
  List<DeepCandidateSuppression> suppressions,
) {
  final counts = <DeepCandidateReasonCode, int>{};
  for (final suppression in suppressions) {
    counts[suppression.reasonCode] = (counts[suppression.reasonCode] ?? 0) + 1;
  }
  return _sortedMap(counts);
}

Map<DeepCandidateReasonCode, int> _sortedMap(
  Map<DeepCandidateReasonCode, int> counts,
) {
  final entries = counts.entries.toList();
  entries.sort((a, b) {
    final byCount = b.value.compareTo(a.value);
    if (byCount != 0) return byCount;
    return a.key.wire.compareTo(b.key.wire);
  });
  return Map<DeepCandidateReasonCode, int>.fromEntries(entries);
}

void _writeCounts(
  StringBuffer buffer,
  String title,
  Map<DeepCandidateReasonCode, int> counts,
) {
  if (counts.isEmpty) return;
  buffer
    ..writeln()
    ..writeln('$title:');
  for (final entry in counts.entries.take(20)) {
    buffer.writeln('- ${entry.key.wire}: ${entry.value}');
  }
}

void _writeLines(StringBuffer buffer, String title, List<String> lines) {
  if (lines.isEmpty) return;
  buffer
    ..writeln()
    ..writeln('$title:');
  for (final line in lines.take(20)) {
    buffer.writeln('- $line');
  }
}

String? _phaseRequestId(String? requestId, String phase) =>
    requestId == null ? null : '$requestId:$phase';

double _ratio(int selected, int positions) {
  if (positions == 0) return 0;
  return selected / positions;
}

String _formatRatio(double value) => value.toStringAsFixed(2);

int _minInt(int a, int b) => a < b ? a : b;

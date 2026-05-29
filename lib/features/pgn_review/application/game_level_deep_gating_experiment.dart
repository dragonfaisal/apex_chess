/// Developer-only game-level deep gating experiment.
library;

export 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_policy.dart';

import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_policy.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_orchestration_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_executor.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';

enum GameLevelDeepGatingMode {
  planOnly('planOnly'),
  fastPassOnly('fastPassOnly'),
  fastThenPlanDeep('fastThenPlanDeep'),
  fastThenExecuteSelectedDeep('fastThenExecuteSelectedDeep');

  const GameLevelDeepGatingMode(this.wire);

  final String wire;
}

enum GameLevelDeepGatingStatus {
  completed('completed'),
  completedWithWarnings('completedWithWarnings'),
  partialFailure('partialFailure'),
  failed('failed'),
  rejected('rejected');

  const GameLevelDeepGatingStatus(this.wire);

  final String wire;
}

class GameLevelDeepGatingExperimentRequest {
  const GameLevelDeepGatingExperimentRequest({
    required this.positions,
    this.profile = LocalSchedulerProfile.balanced,
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
    this.mode = GameLevelDeepGatingMode.planOnly,
    this.timeoutBudgetOverride,
  }) : assert(maxPositions == null || maxPositions >= 0),
       assert(maxFastEngineCalls == null || maxFastEngineCalls >= 0),
       assert(maxDeepCandidates == null || maxDeepCandidates >= 0),
       assert(maxDeepEngineCalls == null || maxDeepEngineCalls >= 0),
       assert(maxTotalEngineCalls == null || maxTotalEngineCalls >= 0),
       assert(maxTotalElapsedBudgetMs == null || maxTotalElapsedBudgetMs >= 0);

  final List<LocalAnalysisPositionInput> positions;
  final LocalSchedulerProfile profile;
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
  final GameLevelDeepGatingMode mode;
  final Duration? timeoutBudgetOverride;
}

class GameLevelDeepGatingTelemetry {
  const GameLevelDeepGatingTelemetry({
    required this.positionsConsidered,
    required this.fastPassCompleted,
    required this.fastFailures,
    required this.skippedOpening,
    required this.skippedForced,
    required this.skippedInvalid,
    required this.candidatesGenerated,
    required this.candidatesSelected,
    required this.candidatesSuppressedByBudget,
    required this.candidatesSuppressedByLowPower,
    required this.candidatesSuppressedByStaticSkip,
    required this.deepExecutions,
    required this.multiPvDeepExecutions,
    required this.timeoutCount,
    required this.warningCount,
    required this.budgetViolationCount,
    required this.elapsedMilliseconds,
    required this.maxCandidatePriority,
    this.slowestPositionIndex,
    this.slowestCandidateIndex,
  });

  final int positionsConsidered;
  final bool fastPassCompleted;
  final int fastFailures;
  final int skippedOpening;
  final int skippedForced;
  final int skippedInvalid;
  final int candidatesGenerated;
  final int candidatesSelected;
  final int candidatesSuppressedByBudget;
  final int candidatesSuppressedByLowPower;
  final int candidatesSuppressedByStaticSkip;
  final int deepExecutions;
  final int multiPvDeepExecutions;
  final int timeoutCount;
  final int warningCount;
  final int budgetViolationCount;
  final int elapsedMilliseconds;
  final int maxCandidatePriority;
  final int? slowestPositionIndex;
  final int? slowestCandidateIndex;

  static const empty = GameLevelDeepGatingTelemetry(
    positionsConsidered: 0,
    fastPassCompleted: false,
    fastFailures: 0,
    skippedOpening: 0,
    skippedForced: 0,
    skippedInvalid: 0,
    candidatesGenerated: 0,
    candidatesSelected: 0,
    candidatesSuppressedByBudget: 0,
    candidatesSuppressedByLowPower: 0,
    candidatesSuppressedByStaticSkip: 0,
    deepExecutions: 0,
    multiPvDeepExecutions: 0,
    timeoutCount: 0,
    warningCount: 0,
    budgetViolationCount: 0,
    elapsedMilliseconds: 0,
    maxCandidatePriority: 0,
  );
}

class GameLevelDeepGatingExperimentResult {
  const GameLevelDeepGatingExperimentResult({
    required this.requestId,
    required this.status,
    required this.fastPassStatus,
    required this.candidateCount,
    required this.selectedDeepCount,
    required this.suppressedCount,
    required this.executedDeepCount,
    required this.totalEngineCalls,
    required this.fastEngineCalls,
    required this.deepEngineCalls,
    required this.totalElapsedMs,
    required this.fastPassResults,
    required this.candidates,
    required this.selectedCandidates,
    required this.suppressions,
    required this.deepExecutionResults,
    required this.telemetry,
    required this.warnings,
    required this.failures,
    required this.recommendation,
  });

  final String? requestId;
  final GameLevelDeepGatingStatus status;
  final LocalReviewOrchestrationStatus? fastPassStatus;
  final int candidateCount;
  final int selectedDeepCount;
  final int suppressedCount;
  final int executedDeepCount;
  final int totalEngineCalls;
  final int fastEngineCalls;
  final int deepEngineCalls;
  final int totalElapsedMs;
  final List<GameLevelFastPassResult> fastPassResults;
  final List<DeepReanalysisCandidate> candidates;
  final List<DeepReanalysisCandidate> selectedCandidates;
  final List<DeepCandidateSuppression> suppressions;
  final LocalReviewOrchestrationExperimentResult? deepExecutionResults;
  final GameLevelDeepGatingTelemetry telemetry;
  final List<String> warnings;
  final List<String> failures;
  final String recommendation;

  String get debugSummary =>
      'request=${requestId ?? "-"} status=${status.wire} '
      'fastStatus=${fastPassStatus?.wire ?? "-"} '
      'positions=${telemetry.positionsConsidered} '
      'candidates=$candidateCount selected=$selectedDeepCount '
      'suppressed=$suppressedCount deepExecuted=$executedDeepCount '
      'engineCalls=$totalEngineCalls elapsedMs=$totalElapsedMs';

  String renderDeveloperReport() {
    final buffer = StringBuffer()
      ..writeln('# Game-Level Deep Gating Experiment')
      ..writeln()
      ..writeln('- status: ${status.wire}')
      ..writeln('- request: ${requestId ?? "-"}')
      ..writeln('- positions considered: ${telemetry.positionsConsidered}')
      ..writeln('- fast status: ${fastPassStatus?.wire ?? "-"}')
      ..writeln('- fast engine calls: $fastEngineCalls')
      ..writeln('- candidates generated: $candidateCount')
      ..writeln('- candidates selected: $selectedDeepCount')
      ..writeln('- suppressions: $suppressedCount')
      ..writeln('- deep executions: $executedDeepCount')
      ..writeln('- deep engine calls: $deepEngineCalls')
      ..writeln('- total engine calls: $totalEngineCalls')
      ..writeln('- elapsed ms: $totalElapsedMs')
      ..writeln('- recommendation: $recommendation');

    if (selectedCandidates.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('selected candidates:');
      for (final candidate in selectedCandidates.take(20)) {
        buffer.writeln('- ${candidate.debugSummary}');
      }
    }

    _writeSection(
      buffer,
      'suppressed',
      suppressions.map((item) => item.debugSummary).take(20),
    );
    _writeSection(buffer, 'warnings', warnings.take(20));
    _writeSection(buffer, 'failures', failures.take(20));

    return buffer.toString().trimRight();
  }

  static void _writeSection(
    StringBuffer buffer,
    String title,
    Iterable<String> lines,
  ) {
    final items = lines.toList(growable: false);
    if (items.isEmpty) return;
    buffer
      ..writeln()
      ..writeln('$title:');
    for (final item in items) {
      buffer.writeln('- $item');
    }
  }
}

class GameLevelDeepGatingExperiment {
  const GameLevelDeepGatingExperiment({
    required LocalReviewOrchestrationExperiment orchestration,
    DeepGatingPolicy policy = const DeepGatingPolicy(),
  }) : _orchestration = orchestration,
       _policy = policy;

  final LocalReviewOrchestrationExperiment _orchestration;
  final DeepGatingPolicy _policy;

  Future<GameLevelDeepGatingExperimentResult> run(
    GameLevelDeepGatingExperimentRequest request,
  ) async {
    final stopwatch = Stopwatch()..start();
    final positions = _limitedPositions(request);
    if (positions.isEmpty) {
      stopwatch.stop();
      return GameLevelDeepGatingExperimentResult(
        requestId: request.requestId,
        status: GameLevelDeepGatingStatus.completed,
        fastPassStatus: null,
        candidateCount: 0,
        selectedDeepCount: 0,
        suppressedCount: 0,
        executedDeepCount: 0,
        totalEngineCalls: 0,
        fastEngineCalls: 0,
        deepEngineCalls: 0,
        totalElapsedMs: stopwatch.elapsedMilliseconds,
        fastPassResults: const <GameLevelFastPassResult>[],
        candidates: const <DeepReanalysisCandidate>[],
        selectedCandidates: const <DeepReanalysisCandidate>[],
        suppressions: const <DeepCandidateSuppression>[],
        deepExecutionResults: null,
        telemetry: GameLevelDeepGatingTelemetry.empty,
        warnings: const <String>[],
        failures: const <String>[],
        recommendation: 'provide positions before deep gating',
      );
    }

    LocalReviewOrchestrationExperimentResult? fastRun;
    LocalReviewOrchestrationExperimentResult? deepRun;
    var fastResults = _providedFastResults(positions, request);

    if (request.mode != GameLevelDeepGatingMode.planOnly) {
      fastRun = await _runFastPass(request, positions);
      fastResults = _fastResultsFromRun(positions, fastRun);
      if (request.mode == GameLevelDeepGatingMode.fastPassOnly) {
        stopwatch.stop();
        return _resultFor(
          request: request,
          positions: positions,
          fastRun: fastRun,
          deepRun: null,
          fastResults: fastResults,
          plan: const DeepGatingPlan(
            candidates: <DeepReanalysisCandidate>[],
            selectedCandidates: <DeepReanalysisCandidate>[],
            suppressions: <DeepCandidateSuppression>[],
            warnings: <String>[],
          ),
          elapsedMilliseconds: stopwatch.elapsedMilliseconds,
        );
      }
    }

    final plan = _policy.plan(
      DeepGatingPolicyRequest(
        positions: positions,
        profile: request.profile,
        fastPassResults: fastResults,
        maxDeepCandidates: request.maxDeepCandidates,
        maxDeepEngineCalls: request.maxDeepEngineCalls,
        maxTotalEngineCalls: request.maxTotalEngineCalls,
        fastEngineCalls: fastRun?.telemetry.measuredEngineCalls ?? 0,
        maxTotalElapsedBudgetMs: request.maxTotalElapsedBudgetMs,
        elapsedMilliseconds: stopwatch.elapsedMilliseconds,
        lowPower: request.lowPower,
      ),
    );

    final fastPassHadFailure =
        fastRun != null &&
        (fastRun.failures.isNotEmpty ||
            fastRun.status == LocalReviewOrchestrationStatus.failed ||
            fastRun.status == LocalReviewOrchestrationStatus.partialFailure);
    if (request.mode == GameLevelDeepGatingMode.fastThenExecuteSelectedDeep &&
        plan.selectedCandidates.isNotEmpty &&
        !fastPassHadFailure) {
      deepRun = await _runDeepPass(
        request,
        positions,
        plan.selectedCandidates,
        fastRun?.telemetry.measuredEngineCalls ?? 0,
        stopwatch.elapsedMilliseconds,
      );
    }

    stopwatch.stop();
    return _resultFor(
      request: request,
      positions: positions,
      fastRun: fastRun,
      deepRun: deepRun,
      fastResults: fastResults,
      plan: plan,
      elapsedMilliseconds: stopwatch.elapsedMilliseconds,
    );
  }

  Future<LocalReviewOrchestrationExperimentResult> _runFastPass(
    GameLevelDeepGatingExperimentRequest request,
    List<LocalAnalysisPositionInput> positions,
  ) {
    return _orchestration.run(
      LocalReviewOrchestrationExperimentRequest.fromSchedulerInputs(
        positions: positions,
        profile: _fastOnlyProfile(request.profile, request.lowPower),
        maxPositions: positions.length,
        maxTotalEngineCalls: _minNullable(
          request.maxFastEngineCalls,
          request.maxTotalEngineCalls,
        ),
        maxTotalElapsedBudgetMs: request.maxTotalElapsedBudgetMs,
        failFast: request.failFast,
        lowPower: request.lowPower,
        requestId: _phaseRequestId(request.requestId, 'fast'),
        timeoutBudgetOverride: request.timeoutBudgetOverride,
      ),
    );
  }

  Future<LocalReviewOrchestrationExperimentResult> _runDeepPass(
    GameLevelDeepGatingExperimentRequest request,
    List<LocalAnalysisPositionInput> positions,
    List<DeepReanalysisCandidate> selectedCandidates,
    int fastEngineCalls,
    int elapsedBeforeDeepMs,
  ) {
    final deepPositions = [
      for (final candidate in selectedCandidates)
        positions[candidate.positionIndex],
    ];
    final remainingTotal = request.maxTotalEngineCalls == null
        ? null
        : request.maxTotalEngineCalls! - fastEngineCalls;
    final remainingElapsed = request.maxTotalElapsedBudgetMs == null
        ? null
        : request.maxTotalElapsedBudgetMs! - elapsedBeforeDeepMs;
    return _orchestration.run(
      LocalReviewOrchestrationExperimentRequest.fromSchedulerInputs(
        positions: deepPositions,
        profile: request.profile,
        maxPositions: deepPositions.length,
        maxTotalEngineCalls: _minNullable(
          request.maxDeepEngineCalls,
          remainingTotal == null || remainingTotal < 0 ? null : remainingTotal,
        ),
        maxTotalElapsedBudgetMs: remainingElapsed == null
            ? null
            : remainingElapsed < 0
            ? 0
            : remainingElapsed,
        failFast: request.failFast,
        lowPower: request.lowPower,
        requestId: _phaseRequestId(request.requestId, 'deep'),
        timeoutBudgetOverride: request.timeoutBudgetOverride,
      ),
    );
  }

  static GameLevelDeepGatingExperimentResult _resultFor({
    required GameLevelDeepGatingExperimentRequest request,
    required List<LocalAnalysisPositionInput> positions,
    required LocalReviewOrchestrationExperimentResult? fastRun,
    required LocalReviewOrchestrationExperimentResult? deepRun,
    required List<GameLevelFastPassResult> fastResults,
    required DeepGatingPlan plan,
    required int elapsedMilliseconds,
  }) {
    final warnings = <String>[
      ...plan.warnings,
      ...?fastRun?.mappingWarnings,
      ...?fastRun?.orchestrationWarnings,
      ...?deepRun?.mappingWarnings,
      ...?deepRun?.orchestrationWarnings,
    ];
    final failures = <String>[
      ...?fastRun?.failures.map((failure) => failure.debugSummary),
      ...?deepRun?.failures.map((failure) => failure.debugSummary),
    ];
    final fastEngineCalls = fastRun?.telemetry.measuredEngineCalls ?? 0;
    final deepEngineCalls = deepRun?.telemetry.measuredEngineCalls ?? 0;
    final telemetry = _telemetryFor(
      positions: positions,
      request: request,
      fastResults: fastResults,
      plan: plan,
      fastRun: fastRun,
      deepRun: deepRun,
      warnings: warnings,
      elapsedMilliseconds: elapsedMilliseconds,
    );
    final status = _statusFor(
      fastRun: fastRun,
      deepRun: deepRun,
      warnings: warnings,
      failures: failures,
      plan: plan,
    );

    return GameLevelDeepGatingExperimentResult(
      requestId: request.requestId,
      status: status,
      fastPassStatus: fastRun?.status,
      candidateCount: plan.candidates.length,
      selectedDeepCount: plan.selectedCandidates.length,
      suppressedCount: plan.suppressions.length,
      executedDeepCount: deepRun?.measuredResult.deepCount ?? 0,
      totalEngineCalls: fastEngineCalls + deepEngineCalls,
      fastEngineCalls: fastEngineCalls,
      deepEngineCalls: deepEngineCalls,
      totalElapsedMs: elapsedMilliseconds,
      fastPassResults: List<GameLevelFastPassResult>.unmodifiable(fastResults),
      candidates: plan.candidates,
      selectedCandidates: plan.selectedCandidates,
      suppressions: plan.suppressions,
      deepExecutionResults: deepRun,
      telemetry: telemetry,
      warnings: List<String>.unmodifiable(warnings),
      failures: List<String>.unmodifiable(failures),
      recommendation: _recommendationFor(status, plan, deepRun),
    );
  }

  static GameLevelDeepGatingStatus _statusFor({
    required LocalReviewOrchestrationExperimentResult? fastRun,
    required LocalReviewOrchestrationExperimentResult? deepRun,
    required List<String> warnings,
    required List<String> failures,
    required DeepGatingPlan plan,
  }) {
    if (failures.isNotEmpty) {
      return fastRun?.status == LocalReviewOrchestrationStatus.failed ||
              deepRun?.status == LocalReviewOrchestrationStatus.failed
          ? GameLevelDeepGatingStatus.failed
          : GameLevelDeepGatingStatus.partialFailure;
    }
    if (fastRun?.status == LocalReviewOrchestrationStatus.rejected ||
        deepRun?.status == LocalReviewOrchestrationStatus.rejected) {
      return GameLevelDeepGatingStatus.rejected;
    }
    if (warnings.isNotEmpty ||
        plan.suppressions.any(
          (item) => item.reasonCode == DeepCandidateReasonCode.budgetSuppressed,
        )) {
      return GameLevelDeepGatingStatus.completedWithWarnings;
    }
    return GameLevelDeepGatingStatus.completed;
  }

  static String _recommendationFor(
    GameLevelDeepGatingStatus status,
    DeepGatingPlan plan,
    LocalReviewOrchestrationExperimentResult? deepRun,
  ) {
    if (status == GameLevelDeepGatingStatus.failed ||
        status == GameLevelDeepGatingStatus.partialFailure) {
      return 'fix local execution failures before widening deep gating';
    }
    if (plan.selectedCandidates.isEmpty && plan.candidates.isNotEmpty) {
      return 'increase explicit deep budget or keep plan-only observation';
    }
    if (deepRun != null) {
      return 'review measured deep-pass cost before next gating revision';
    }
    return 'use selected candidates as the next measured deep-pass input';
  }

  static GameLevelDeepGatingTelemetry _telemetryFor({
    required List<LocalAnalysisPositionInput> positions,
    required GameLevelDeepGatingExperimentRequest request,
    required List<GameLevelFastPassResult> fastResults,
    required DeepGatingPlan plan,
    required LocalReviewOrchestrationExperimentResult? fastRun,
    required LocalReviewOrchestrationExperimentResult? deepRun,
    required List<String> warnings,
    required int elapsedMilliseconds,
  }) {
    final skippedOpening = plan.suppressions
        .where(
          (item) =>
              item.reasonCode == DeepCandidateReasonCode.openingSuppressed,
        )
        .length;
    final skippedForced = plan.suppressions
        .where(
          (item) => item.reasonCode == DeepCandidateReasonCode.forcedSuppressed,
        )
        .length;
    final skippedInvalid = plan.suppressions
        .where(
          (item) =>
              item.reasonCode == DeepCandidateReasonCode.invalidFenSuppressed,
        )
        .length;
    final budgetSuppressions = plan.suppressions
        .where(
          (item) => item.reasonCode == DeepCandidateReasonCode.budgetSuppressed,
        )
        .length;
    final lowPowerSuppressions = plan.suppressions
        .where(
          (item) =>
              item.reasonCode == DeepCandidateReasonCode.lowPowerSuppressed,
        )
        .length;
    final staticSuppressions = skippedOpening + skippedForced + skippedInvalid;
    final timeouts =
        (fastRun?.measuredResult.timeoutCount ?? 0) +
        (deepRun?.measuredResult.timeoutCount ?? 0);
    final budgetViolations =
        (fastRun?.measuredResult.telemetry.budgetViolations ?? 0) +
        (deepRun?.measuredResult.telemetry.budgetViolations ?? 0) +
        budgetSuppressions;
    final deepExecutions = deepRun?.measuredResult.deepCount ?? 0;
    final multipvDeepExecutions = deepRun?.measuredResult.multiPvCount ?? 0;
    final maxPriority = plan.candidates.isEmpty
        ? 0
        : plan.candidates.first.priorityScore;

    return GameLevelDeepGatingTelemetry(
      positionsConsidered: positions.length,
      fastPassCompleted: fastRun != null,
      fastFailures: fastResults.where((result) => result.failed).length,
      skippedOpening: skippedOpening,
      skippedForced: skippedForced,
      skippedInvalid: skippedInvalid,
      candidatesGenerated: plan.candidates.length,
      candidatesSelected: plan.selectedCandidates.length,
      candidatesSuppressedByBudget: budgetSuppressions,
      candidatesSuppressedByLowPower: lowPowerSuppressions,
      candidatesSuppressedByStaticSkip: staticSuppressions,
      deepExecutions: deepExecutions,
      multiPvDeepExecutions: multipvDeepExecutions,
      timeoutCount: timeouts,
      warningCount: warnings.length,
      budgetViolationCount: budgetViolations,
      elapsedMilliseconds: elapsedMilliseconds,
      maxCandidatePriority: maxPriority,
      slowestPositionIndex: fastRun?.telemetry.slowestPositionIndex,
      slowestCandidateIndex: deepRun?.telemetry.slowestPositionIndex,
    );
  }

  static List<LocalAnalysisPositionInput> _limitedPositions(
    GameLevelDeepGatingExperimentRequest request,
  ) {
    final limit = request.maxPositions == null
        ? request.positions.length
        : _minInt(request.maxPositions!, request.positions.length);
    return List<LocalAnalysisPositionInput>.unmodifiable(
      request.positions.take(limit),
    );
  }

  static List<GameLevelFastPassResult> _providedFastResults(
    List<LocalAnalysisPositionInput> positions,
    GameLevelDeepGatingExperimentRequest request,
  ) {
    final results = <GameLevelFastPassResult>[];
    for (final evidence in request.providedFastEvidence) {
      if (evidence.positionIndex >= positions.length) continue;
      results.add(
        GameLevelFastPassResult.fromProvided(
          input: positions[evidence.positionIndex],
          evidence: evidence,
        ),
      );
    }
    return List<GameLevelFastPassResult>.unmodifiable(results);
  }

  static List<GameLevelFastPassResult> _fastResultsFromRun(
    List<LocalAnalysisPositionInput> positions,
    LocalReviewOrchestrationExperimentResult run,
  ) {
    final results = <GameLevelFastPassResult>[];
    for (
      var index = 0;
      index < run.measuredResult.positionResults.length;
      index++
    ) {
      if (index >= positions.length) break;
      final execution = run.measuredResult.positionResults[index];
      final snapshot = execution.fastSnapshot ?? execution.deepSnapshot;
      results.add(
        GameLevelFastPassResult(
          positionIndex: index,
          input: positions[index],
          scoreCp: snapshot?.scoreCp,
          mateIn: snapshot?.mateIn,
          bestMoveUci: snapshot?.bestMoveUci,
          fastPvCount: _snapshotPvCount(snapshot),
          elapsedMilliseconds: execution.elapsedMilliseconds,
          warnings: execution.warnings,
          failureCode: _executionFailed(execution)
              ? execution.failureCode ?? execution.status.wire
              : null,
          alreadySkipped:
              execution.status == LocalSchedulerExecutionStatus.skipped,
        ),
      );
    }
    return List<GameLevelFastPassResult>.unmodifiable(results);
  }

  static LocalSchedulerProfile _fastOnlyProfile(
    LocalSchedulerProfile profile,
    bool lowPower,
  ) {
    final base = lowPower ? profile.lowPowerVariant() : profile;
    return LocalSchedulerProfile(
      id: base.id,
      label: '${base.label} Fast Gate',
      fastMovetime: base.fastMovetime,
      deepMovetime: base.fastMovetime,
      fastDepth: base.fastDepth,
      deepDepth: base.fastDepth,
      maxDepth: base.fastDepth,
      maxMultiPv: 1,
      allowDeepReanalysis: false,
      maxCriticalReanalysisCount: 0,
      thermalSafeMode: base.thermalSafeMode || lowPower,
    );
  }

  static String? _phaseRequestId(String? requestId, String phase) =>
      requestId == null ? null : '$requestId:$phase';
}

bool _executionFailed(LocalSchedulerExecutionResult result) {
  return result.status == LocalSchedulerExecutionStatus.failed ||
      result.status == LocalSchedulerExecutionStatus.partialFailure;
}

int _snapshotPvCount(dynamic snapshot) {
  if (snapshot == null) return 0;
  final directPv = snapshot.pvMoves as List<dynamic>;
  final linePvCount = (snapshot.engineLines as List<dynamic>)
      .where((line) => (line.pvMoves as List<dynamic>).isNotEmpty)
      .length;
  if (linePvCount > 0) return linePvCount;
  return directPv.isEmpty ? 0 : 1;
}

int? _minNullable(int? a, int? b) {
  if (a == null) return b;
  if (b == null) return a;
  return _minInt(a, b);
}

int _minInt(int a, int b) => a < b ? a : b;

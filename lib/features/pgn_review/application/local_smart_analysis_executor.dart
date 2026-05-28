/// Thin executor for Phase 30H local scheduler decisions.
library;

import 'dart:async';

import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';

class LocalSchedulerExecutionRequest {
  const LocalSchedulerExecutionRequest({
    required this.input,
    this.profile = LocalSchedulerProfile.balanced,
    this.requestId,
    this.timeoutBudgetOverride,
  });

  final LocalAnalysisPositionInput input;
  final LocalSchedulerProfile profile;
  final String? requestId;
  final Duration? timeoutBudgetOverride;
}

enum LocalSchedulerExecutionStatus {
  skipped('skipped'),
  rejected('rejected'),
  fastCompleted('fastCompleted'),
  deepCompleted('deepCompleted'),
  partialFailure('partialFailure'),
  failed('failed');

  const LocalSchedulerExecutionStatus(this.wire);

  final String wire;
}

class LocalSchedulerExecutionResult {
  const LocalSchedulerExecutionResult({
    required this.requestId,
    required this.decision,
    required this.status,
    required this.engineCallCount,
    required this.elapsedMilliseconds,
    required this.plannedMultiPv,
    required this.executedMultiPv,
    required this.warnings,
    required this.telemetry,
    this.fastSnapshot,
    this.deepSnapshot,
    this.fastError,
    this.deepError,
    this.failureCode,
    this.failureMessage,
  });

  final String? requestId;
  final LocalSchedulerDecision decision;
  final LocalSchedulerExecutionStatus status;
  final EvalSnapshot? fastSnapshot;
  final EvalSnapshot? deepSnapshot;
  final EvalError? fastError;
  final EvalError? deepError;
  final int engineCallCount;
  final int elapsedMilliseconds;
  final int plannedMultiPv;
  final int executedMultiPv;
  final List<String> warnings;
  final String? failureCode;
  final String? failureMessage;
  final LocalSchedulerExecutionTelemetry telemetry;

  bool get isSuccess =>
      status == LocalSchedulerExecutionStatus.skipped ||
      status == LocalSchedulerExecutionStatus.rejected ||
      status == LocalSchedulerExecutionStatus.fastCompleted ||
      status == LocalSchedulerExecutionStatus.deepCompleted;

  String get debugSummary {
    final warningText = warnings.isEmpty ? 'none' : warnings.join('; ');
    return 'request=${requestId ?? "-"} status=${status.wire} '
        'decision=${decision.type.wire} calls=$engineCallCount '
        'plannedMultiPv=$plannedMultiPv executedMultiPv=$executedMultiPv '
        'elapsedMs=$elapsedMilliseconds warnings=[$warningText]';
  }
}

class LocalSchedulerExecutionTelemetry {
  const LocalSchedulerExecutionTelemetry({
    required this.positionsPlanned,
    required this.positionsSkipped,
    required this.positionsRejected,
    required this.engineCalls,
    required this.fastCalls,
    required this.deepCalls,
    required this.multiPvCalls,
    required this.elapsedMilliseconds,
    required this.timeoutCount,
    required this.invalidFenCount,
    required this.budgetViolationCount,
    required this.warningCount,
  });

  final int positionsPlanned;
  final int positionsSkipped;
  final int positionsRejected;
  final int engineCalls;
  final int fastCalls;
  final int deepCalls;
  final int multiPvCalls;
  final int elapsedMilliseconds;
  final int timeoutCount;
  final int invalidFenCount;
  final int budgetViolationCount;
  final int warningCount;

  static const empty = LocalSchedulerExecutionTelemetry(
    positionsPlanned: 0,
    positionsSkipped: 0,
    positionsRejected: 0,
    engineCalls: 0,
    fastCalls: 0,
    deepCalls: 0,
    multiPvCalls: 0,
    elapsedMilliseconds: 0,
    timeoutCount: 0,
    invalidFenCount: 0,
    budgetViolationCount: 0,
    warningCount: 0,
  );

  LocalSchedulerExecutionTelemetry operator +(
    LocalSchedulerExecutionTelemetry other,
  ) {
    return LocalSchedulerExecutionTelemetry(
      positionsPlanned: positionsPlanned + other.positionsPlanned,
      positionsSkipped: positionsSkipped + other.positionsSkipped,
      positionsRejected: positionsRejected + other.positionsRejected,
      engineCalls: engineCalls + other.engineCalls,
      fastCalls: fastCalls + other.fastCalls,
      deepCalls: deepCalls + other.deepCalls,
      multiPvCalls: multiPvCalls + other.multiPvCalls,
      elapsedMilliseconds: elapsedMilliseconds + other.elapsedMilliseconds,
      timeoutCount: timeoutCount + other.timeoutCount,
      invalidFenCount: invalidFenCount + other.invalidFenCount,
      budgetViolationCount: budgetViolationCount + other.budgetViolationCount,
      warningCount: warningCount + other.warningCount,
    );
  }
}

class LocalSchedulerBatchExecutionResult {
  const LocalSchedulerBatchExecutionResult({
    required this.results,
    required this.telemetry,
    required this.warnings,
  });

  final List<LocalSchedulerExecutionResult> results;
  final LocalSchedulerExecutionTelemetry telemetry;
  final List<String> warnings;
}

class LocalSmartAnalysisExecutor {
  const LocalSmartAnalysisExecutor({required LocalEvalService eval})
    : _eval = eval;

  final LocalEvalService _eval;

  Future<LocalSchedulerExecutionResult> execute(
    LocalSchedulerExecutionRequest request,
  ) async {
    final stopwatch = Stopwatch()..start();
    final scheduler = LocalSmartAnalysisScheduler(profile: request.profile);
    final decision = scheduler.plan(request.input);
    final plannedMultiPv = _maxPlannedMultiPv(decision);

    if (!decision.engineRequired) {
      final status =
          decision.type == LocalSchedulerDecisionType.rejectInvalidFen
          ? LocalSchedulerExecutionStatus.rejected
          : LocalSchedulerExecutionStatus.skipped;
      stopwatch.stop();
      final telemetry = _telemetryForStaticDecision(
        decision: decision,
        status: status,
        elapsedMilliseconds: stopwatch.elapsedMilliseconds,
      );
      return LocalSchedulerExecutionResult(
        requestId: request.requestId,
        decision: decision,
        status: status,
        engineCallCount: 0,
        elapsedMilliseconds: stopwatch.elapsedMilliseconds,
        plannedMultiPv: plannedMultiPv,
        executedMultiPv: 0,
        warnings: const <String>[],
        telemetry: telemetry,
      );
    }

    final executionSteps = _executionSteps(decision, request.profile);
    final budgetViolations = executionSteps
        .where((step) => !decision.safetyBudget.allows(step))
        .length;
    if (budgetViolations > 0) {
      stopwatch.stop();
      final warnings = <String>[
        'planned search exceeded scheduler safety budget',
      ];
      final telemetry = LocalSchedulerExecutionTelemetry(
        positionsPlanned: 1,
        positionsSkipped: 0,
        positionsRejected: 0,
        engineCalls: 0,
        fastCalls: 0,
        deepCalls: 0,
        multiPvCalls: 0,
        elapsedMilliseconds: stopwatch.elapsedMilliseconds,
        timeoutCount: 0,
        invalidFenCount: 0,
        budgetViolationCount: budgetViolations,
        warningCount: warnings.length,
      );
      return LocalSchedulerExecutionResult(
        requestId: request.requestId,
        decision: decision,
        status: LocalSchedulerExecutionStatus.failed,
        engineCallCount: 0,
        elapsedMilliseconds: stopwatch.elapsedMilliseconds,
        plannedMultiPv: plannedMultiPv,
        executedMultiPv: 0,
        warnings: warnings,
        failureCode: 'budget_violation',
        failureMessage: warnings.first,
        telemetry: telemetry,
      );
    }

    final warnings = <String>[];
    EvalSnapshot? fastSnapshot;
    EvalSnapshot? deepSnapshot;
    EvalError? fastError;
    EvalError? deepError;
    var engineCalls = 0;
    var fastCalls = 0;
    var deepCalls = 0;
    var multiPvCalls = 0;
    var executedMultiPv = 0;
    var timeoutCount = 0;

    for (final step in executionSteps) {
      final outcome = await _runStep(request, step);
      engineCalls++;
      executedMultiPv = _maxInt(executedMultiPv, step.multiPv);
      if (step.multiPv > 1) multiPvCalls++;
      if (step.kind == LocalEngineSearchStepKind.deepReanalysis) {
        deepCalls++;
      } else {
        fastCalls++;
      }

      if (outcome.timedOut) timeoutCount++;

      if (outcome.error != null || outcome.snapshot == null) {
        stopwatch.stop();
        final failureCode = outcome.timedOut
            ? 'engine_timeout'
            : 'engine_${outcome.error?.name ?? "missing_snapshot"}';
        final failureMessage =
            outcome.message ??
            'Local engine search failed for ${step.kind.wire}.';
        if (step.kind == LocalEngineSearchStepKind.deepReanalysis &&
            fastSnapshot != null) {
          deepError = outcome.error;
          final allWarnings = [
            ...warnings,
            '${step.kind.wire}: $failureMessage',
          ];
          final telemetry = _telemetryForEngineDecision(
            status: LocalSchedulerExecutionStatus.partialFailure,
            decision: decision,
            engineCalls: engineCalls,
            fastCalls: fastCalls,
            deepCalls: deepCalls,
            multiPvCalls: multiPvCalls,
            elapsedMilliseconds: stopwatch.elapsedMilliseconds,
            timeoutCount: timeoutCount,
            budgetViolationCount: 0,
            warnings: allWarnings,
          );
          return LocalSchedulerExecutionResult(
            requestId: request.requestId,
            decision: decision,
            status: LocalSchedulerExecutionStatus.partialFailure,
            fastSnapshot: fastSnapshot,
            deepSnapshot: deepSnapshot,
            fastError: fastError,
            deepError: deepError,
            engineCallCount: engineCalls,
            elapsedMilliseconds: stopwatch.elapsedMilliseconds,
            plannedMultiPv: plannedMultiPv,
            executedMultiPv: executedMultiPv,
            warnings: allWarnings,
            failureCode: failureCode,
            failureMessage: failureMessage,
            telemetry: telemetry,
          );
        }

        fastError = outcome.error;
        final allWarnings = [...warnings, '${step.kind.wire}: $failureMessage'];
        final telemetry = _telemetryForEngineDecision(
          status: LocalSchedulerExecutionStatus.failed,
          decision: decision,
          engineCalls: engineCalls,
          fastCalls: fastCalls,
          deepCalls: deepCalls,
          multiPvCalls: multiPvCalls,
          elapsedMilliseconds: stopwatch.elapsedMilliseconds,
          timeoutCount: timeoutCount,
          budgetViolationCount: 0,
          warnings: allWarnings,
        );
        return LocalSchedulerExecutionResult(
          requestId: request.requestId,
          decision: decision,
          status: LocalSchedulerExecutionStatus.failed,
          fastSnapshot: fastSnapshot,
          deepSnapshot: deepSnapshot,
          fastError: fastError,
          deepError: deepError,
          engineCallCount: engineCalls,
          elapsedMilliseconds: stopwatch.elapsedMilliseconds,
          plannedMultiPv: plannedMultiPv,
          executedMultiPv: executedMultiPv,
          warnings: allWarnings,
          failureCode: failureCode,
          failureMessage: failureMessage,
          telemetry: telemetry,
        );
      }

      final stepWarnings = _warningsForSnapshot(step, outcome.snapshot!);
      warnings.addAll(stepWarnings);

      if (step.kind == LocalEngineSearchStepKind.deepReanalysis) {
        deepSnapshot = outcome.snapshot;
      } else {
        fastSnapshot = outcome.snapshot;
      }
    }

    stopwatch.stop();
    final completedDeep = deepSnapshot != null;
    final status = completedDeep
        ? LocalSchedulerExecutionStatus.deepCompleted
        : LocalSchedulerExecutionStatus.fastCompleted;
    final telemetry = _telemetryForEngineDecision(
      status: status,
      decision: decision,
      engineCalls: engineCalls,
      fastCalls: fastCalls,
      deepCalls: deepCalls,
      multiPvCalls: multiPvCalls,
      elapsedMilliseconds: stopwatch.elapsedMilliseconds,
      timeoutCount: timeoutCount,
      budgetViolationCount: 0,
      warnings: warnings,
    );

    return LocalSchedulerExecutionResult(
      requestId: request.requestId,
      decision: decision,
      status: status,
      fastSnapshot: fastSnapshot,
      deepSnapshot: deepSnapshot,
      fastError: fastError,
      deepError: deepError,
      engineCallCount: engineCalls,
      elapsedMilliseconds: stopwatch.elapsedMilliseconds,
      plannedMultiPv: plannedMultiPv,
      executedMultiPv: executedMultiPv,
      warnings: List<String>.unmodifiable(warnings),
      telemetry: telemetry,
    );
  }

  Future<LocalSchedulerBatchExecutionResult> executeBatch(
    List<LocalSchedulerExecutionRequest> requests, {
    bool failFast = false,
  }) async {
    final results = <LocalSchedulerExecutionResult>[];
    var telemetry = LocalSchedulerExecutionTelemetry.empty;
    final warnings = <String>[];

    for (final request in requests) {
      final result = await execute(request);
      results.add(result);
      telemetry += result.telemetry;
      warnings.addAll(result.warnings);
      if (failFast &&
          (result.status == LocalSchedulerExecutionStatus.failed ||
              result.status == LocalSchedulerExecutionStatus.partialFailure)) {
        break;
      }
    }

    return LocalSchedulerBatchExecutionResult(
      results: List<LocalSchedulerExecutionResult>.unmodifiable(results),
      telemetry: telemetry,
      warnings: List<String>.unmodifiable(warnings),
    );
  }

  Future<_StepOutcome> _runStep(
    LocalSchedulerExecutionRequest request,
    LocalEngineSearchStep step,
  ) async {
    try {
      final (snapshot, error) = await _eval.evaluate(
        request.input.fen,
        depth: step.depth,
        movetime: step.movetime,
        timeout: request.timeoutBudgetOverride ?? _timeoutFor(step),
        multiPv: step.multiPv,
      );
      return _StepOutcome(snapshot: snapshot, error: error);
    } on TimeoutException catch (error) {
      return _StepOutcome(
        error: EvalError.serverError,
        timedOut: true,
        message: error.message ?? 'Local engine search timed out.',
      );
    } on Object catch (error) {
      return _StepOutcome(
        error: EvalError.serverError,
        message: error.toString(),
      );
    }
  }

  static List<LocalEngineSearchStep> _executionSteps(
    LocalSchedulerDecision decision,
    LocalSchedulerProfile profile,
  ) {
    if (decision.steps.isEmpty) return const <LocalEngineSearchStep>[];
    final first = decision.steps.first;
    if (decision.type == LocalSchedulerDecisionType.deepReanalysis &&
        first.kind == LocalEngineSearchStepKind.deepReanalysis) {
      return <LocalEngineSearchStep>[
        _fastPrimer(profile, decision.safetyBudget),
        ...decision.steps,
      ];
    }
    return decision.steps;
  }

  static LocalEngineSearchStep _fastPrimer(
    LocalSchedulerProfile profile,
    LocalSchedulerSafetyBudget budget,
  ) {
    return LocalEngineSearchStep(
      kind: LocalEngineSearchStepKind.fastPass,
      depth: _minInt(profile.fastDepth, budget.maxDepth),
      movetime: _minDuration(profile.fastMovetime, budget.maxMovetime),
      multiPv: 1,
    );
  }

  static Duration _timeoutFor(LocalEngineSearchStep step) {
    return step.movetime + const Duration(seconds: 2);
  }

  static int _maxPlannedMultiPv(LocalSchedulerDecision decision) {
    var max = 0;
    for (final step in decision.steps) {
      max = _maxInt(max, step.multiPv);
    }
    return max;
  }

  static List<String> _warningsForSnapshot(
    LocalEngineSearchStep step,
    EvalSnapshot snapshot,
  ) {
    final warnings = <String>[];
    final prefix = step.kind.wire;
    final hasBestMove =
        snapshot.bestMoveUci != null && snapshot.bestMoveUci!.trim().isNotEmpty;
    final hasPv =
        snapshot.pvMoves.isNotEmpty ||
        snapshot.engineLines.any((line) => line.pvMoves.isNotEmpty);
    final hasScore = snapshot.scoreCp != null || snapshot.mateIn != null;

    if (!hasBestMove) warnings.add('$prefix: missing bestmove');
    if (!hasPv) warnings.add('$prefix: missing pv');
    if (!hasScore) warnings.add('$prefix: missing score');
    if (step.multiPv > 1 && snapshot.engineLines.length < step.multiPv) {
      warnings.add(
        '$prefix: requested MultiPV ${step.multiPv} but got '
        '${snapshot.engineLines.length} line(s)',
      );
    }
    return warnings;
  }

  static LocalSchedulerExecutionTelemetry _telemetryForStaticDecision({
    required LocalSchedulerDecision decision,
    required LocalSchedulerExecutionStatus status,
    required int elapsedMilliseconds,
  }) {
    final rejected = status == LocalSchedulerExecutionStatus.rejected;
    return LocalSchedulerExecutionTelemetry(
      positionsPlanned: 1,
      positionsSkipped: rejected ? 0 : 1,
      positionsRejected: rejected ? 1 : 0,
      engineCalls: 0,
      fastCalls: 0,
      deepCalls: 0,
      multiPvCalls: 0,
      elapsedMilliseconds: elapsedMilliseconds,
      timeoutCount: 0,
      invalidFenCount:
          decision.type == LocalSchedulerDecisionType.rejectInvalidFen ? 1 : 0,
      budgetViolationCount: 0,
      warningCount: 0,
    );
  }

  static LocalSchedulerExecutionTelemetry _telemetryForEngineDecision({
    required LocalSchedulerExecutionStatus status,
    required LocalSchedulerDecision decision,
    required int engineCalls,
    required int fastCalls,
    required int deepCalls,
    required int multiPvCalls,
    required int elapsedMilliseconds,
    required int timeoutCount,
    required int budgetViolationCount,
    required List<String> warnings,
  }) {
    return LocalSchedulerExecutionTelemetry(
      positionsPlanned: 1,
      positionsSkipped: 0,
      positionsRejected: 0,
      engineCalls: engineCalls,
      fastCalls: fastCalls,
      deepCalls: deepCalls,
      multiPvCalls: multiPvCalls,
      elapsedMilliseconds: elapsedMilliseconds,
      timeoutCount: timeoutCount,
      invalidFenCount:
          decision.type == LocalSchedulerDecisionType.rejectInvalidFen ? 1 : 0,
      budgetViolationCount: budgetViolationCount,
      warningCount: warnings.length,
    );
  }
}

class _StepOutcome {
  const _StepOutcome({
    this.snapshot,
    this.error,
    this.timedOut = false,
    this.message,
  });

  final EvalSnapshot? snapshot;
  final EvalError? error;
  final bool timedOut;
  final String? message;
}

int _minInt(int a, int b) => a < b ? a : b;

int _maxInt(int a, int b) => a > b ? a : b;

Duration _minDuration(Duration a, Duration b) =>
    a.inMilliseconds <= b.inMilliseconds ? a : b;

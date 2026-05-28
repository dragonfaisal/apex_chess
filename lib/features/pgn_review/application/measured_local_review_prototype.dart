/// Measured local review prototype over the Phase 30H scheduler executor.
library;

import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_executor.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';

class MeasuredLocalReviewRequest {
  const MeasuredLocalReviewRequest({
    required this.positions,
    this.profile = LocalSchedulerProfile.balanced,
    this.maxPositions,
    this.failFast = false,
    this.requestId,
    this.lowPowerOverride,
    this.maxTotalEngineCalls,
    this.maxTotalElapsedBudgetMs,
    this.timeoutBudgetOverride,
  }) : assert(maxPositions == null || maxPositions >= 0),
       assert(maxTotalEngineCalls == null || maxTotalEngineCalls >= 0),
       assert(maxTotalElapsedBudgetMs == null || maxTotalElapsedBudgetMs >= 0);

  final List<LocalAnalysisPositionInput> positions;
  final LocalSchedulerProfile profile;
  final int? maxPositions;
  final bool failFast;
  final String? requestId;
  final bool? lowPowerOverride;
  final int? maxTotalEngineCalls;
  final int? maxTotalElapsedBudgetMs;
  final Duration? timeoutBudgetOverride;
}

enum MeasuredLocalReviewStatus {
  completed('completed'),
  completedWithWarnings('completedWithWarnings'),
  partialFailure('partialFailure'),
  failed('failed'),
  rejected('rejected');

  const MeasuredLocalReviewStatus(this.wire);

  final String wire;
}

class MeasuredLocalReviewFailure {
  const MeasuredLocalReviewFailure({
    required this.positionIndex,
    required this.status,
    this.requestId,
    this.code,
    this.message,
  });

  final int positionIndex;
  final LocalSchedulerExecutionStatus status;
  final String? requestId;
  final String? code;
  final String? message;

  String get debugSummary =>
      'index=$positionIndex status=${status.wire} code=${code ?? "-"} '
      'message="${message ?? "-"}"';
}

class MeasuredLocalReviewTelemetry {
  const MeasuredLocalReviewTelemetry({
    required this.positionsPlanned,
    required this.positionsExecuted,
    required this.positionsSkipped,
    required this.positionsRejected,
    required this.engineCalls,
    required this.fastCalls,
    required this.deepCalls,
    required this.multiPvCalls,
    required this.elapsedMilliseconds,
    required this.timeouts,
    required this.invalidFens,
    required this.missingPvWarnings,
    required this.missingBestmoveWarnings,
    required this.budgetViolations,
    required this.maxSinglePositionElapsedMs,
    this.slowestPositionIndex,
    this.slowestPositionId,
  });

  final int positionsPlanned;
  final int positionsExecuted;
  final int positionsSkipped;
  final int positionsRejected;
  final int engineCalls;
  final int fastCalls;
  final int deepCalls;
  final int multiPvCalls;
  final int elapsedMilliseconds;
  final int timeouts;
  final int invalidFens;
  final int missingPvWarnings;
  final int missingBestmoveWarnings;
  final int budgetViolations;
  final int maxSinglePositionElapsedMs;
  final int? slowestPositionIndex;
  final String? slowestPositionId;

  static const empty = MeasuredLocalReviewTelemetry(
    positionsPlanned: 0,
    positionsExecuted: 0,
    positionsSkipped: 0,
    positionsRejected: 0,
    engineCalls: 0,
    fastCalls: 0,
    deepCalls: 0,
    multiPvCalls: 0,
    elapsedMilliseconds: 0,
    timeouts: 0,
    invalidFens: 0,
    missingPvWarnings: 0,
    missingBestmoveWarnings: 0,
    budgetViolations: 0,
    maxSinglePositionElapsedMs: 0,
  );
}

class MeasuredLocalReviewResult {
  const MeasuredLocalReviewResult({
    required this.requestId,
    required this.status,
    required this.positionResults,
    required this.telemetry,
    required this.warnings,
    required this.failures,
    required this.processedPositionCount,
    required this.skippedCount,
    required this.rejectedCount,
    required this.fastCount,
    required this.deepCount,
    required this.multiPvCount,
    required this.failureCount,
    required this.timeoutCount,
    required this.warningCount,
    required this.totalElapsedMs,
    required this.totalEngineCalls,
  });

  final String? requestId;
  final MeasuredLocalReviewStatus status;
  final List<LocalSchedulerExecutionResult> positionResults;
  final MeasuredLocalReviewTelemetry telemetry;
  final List<String> warnings;
  final List<MeasuredLocalReviewFailure> failures;
  final int processedPositionCount;
  final int skippedCount;
  final int rejectedCount;
  final int fastCount;
  final int deepCount;
  final int multiPvCount;
  final int failureCount;
  final int timeoutCount;
  final int warningCount;
  final int totalElapsedMs;
  final int totalEngineCalls;

  String get debugSummary =>
      'request=${requestId ?? "-"} status=${status.wire} '
      'positions=$processedPositionCount skipped=$skippedCount '
      'rejected=$rejectedCount fast=$fastCount deep=$deepCount '
      'multipv=$multiPvCount failures=$failureCount '
      'timeouts=$timeoutCount warnings=$warningCount '
      'engineCalls=$totalEngineCalls elapsedMs=$totalElapsedMs';

  String renderDeveloperReport() {
    final buffer = StringBuffer()
      ..writeln('# Measured Local Review Prototype')
      ..writeln()
      ..writeln('- status: ${status.wire}')
      ..writeln('- request: ${requestId ?? "-"}')
      ..writeln('- positions processed: $processedPositionCount')
      ..writeln('- skipped: $skippedCount')
      ..writeln('- rejected: $rejectedCount')
      ..writeln('- fast: $fastCount')
      ..writeln('- deep: $deepCount')
      ..writeln('- multipv: $multiPvCount')
      ..writeln('- failures: $failureCount')
      ..writeln('- timeouts: $timeoutCount')
      ..writeln('- warnings: $warningCount')
      ..writeln('- engine calls: $totalEngineCalls')
      ..writeln('- elapsed ms: $totalElapsedMs');

    if (telemetry.slowestPositionIndex != null) {
      buffer
        ..writeln('- slowest position: ${telemetry.slowestPositionIndex}')
        ..writeln(
          '- slowest elapsed ms: ${telemetry.maxSinglePositionElapsedMs}',
        );
    }

    if (warnings.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('warnings:');
      for (final warning in warnings.take(20)) {
        buffer.writeln('- $warning');
      }
    }

    if (failures.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('failures:');
      for (final failure in failures.take(20)) {
        buffer.writeln('- ${failure.debugSummary}');
      }
    }

    return buffer.toString().trimRight();
  }
}

class MeasuredLocalReviewPrototype {
  const MeasuredLocalReviewPrototype({
    required LocalSmartAnalysisExecutor executor,
  }) : _executor = executor;

  final LocalSmartAnalysisExecutor _executor;

  Future<MeasuredLocalReviewResult> run(
    MeasuredLocalReviewRequest request,
  ) async {
    final stopwatch = Stopwatch()..start();
    final positionLimit = request.maxPositions == null
        ? request.positions.length
        : _minInt(request.maxPositions!, request.positions.length);
    final results = <LocalSchedulerExecutionResult>[];
    final warnings = <String>[];
    final failures = <MeasuredLocalReviewFailure>[];

    var stoppedByBudget = false;

    for (var index = 0; index < positionLimit; index++) {
      if (_engineCallBudgetReached(request, results)) {
        stoppedByBudget = true;
        warnings.add('maxTotalEngineCalls reached before position $index');
        break;
      }
      if (_elapsedBudgetReached(request, stopwatch.elapsedMilliseconds)) {
        stoppedByBudget = true;
        warnings.add('maxTotalElapsedBudgetMs reached before position $index');
        break;
      }

      final input = _inputWithLowPowerOverride(
        request.positions[index],
        request.lowPowerOverride,
      );
      final plannedEngineCalls = _plannedEngineCallCount(
        input: input,
        profile: request.profile,
      );
      if (_plannedEngineCallsWouldExceed(
        request,
        results,
        plannedEngineCalls,
      )) {
        stoppedByBudget = true;
        final remaining = _remainingEngineCalls(request, results);
        warnings.add(
          'maxTotalEngineCalls would be exceeded before position $index '
          '(remaining=$remaining planned=$plannedEngineCalls)',
        );
        break;
      }
      final result = await _executor.execute(
        LocalSchedulerExecutionRequest(
          input: input,
          profile: request.profile,
          requestId: _positionRequestId(request.requestId, index),
          timeoutBudgetOverride: request.timeoutBudgetOverride,
        ),
      );
      results.add(result);
      warnings.addAll(
        result.warnings.map((warning) => 'position $index: $warning'),
      );

      if (_isFailure(result)) {
        failures.add(
          MeasuredLocalReviewFailure(
            positionIndex: index,
            status: result.status,
            requestId: result.requestId,
            code: result.failureCode,
            message: result.failureMessage,
          ),
        );
        if (request.failFast) break;
      }

      if (_engineCallBudgetExceeded(request, results)) {
        stoppedByBudget = true;
        warnings.add('maxTotalEngineCalls exceeded after position $index');
        break;
      }
      if (_elapsedBudgetReached(request, stopwatch.elapsedMilliseconds)) {
        stoppedByBudget = true;
        warnings.add('maxTotalElapsedBudgetMs reached after position $index');
        break;
      }
    }

    stopwatch.stop();
    final telemetry = _buildTelemetry(
      results: results,
      elapsedMilliseconds: stopwatch.elapsedMilliseconds,
    );
    final status = _statusFor(
      request: request,
      results: results,
      failures: failures,
      warnings: warnings,
      stoppedByBudget: stoppedByBudget,
      positionLimit: positionLimit,
    );

    return MeasuredLocalReviewResult(
      requestId: request.requestId,
      status: status,
      positionResults: List<LocalSchedulerExecutionResult>.unmodifiable(
        results,
      ),
      telemetry: telemetry,
      warnings: List<String>.unmodifiable(warnings),
      failures: List<MeasuredLocalReviewFailure>.unmodifiable(failures),
      processedPositionCount: results.length,
      skippedCount: telemetry.positionsSkipped,
      rejectedCount: telemetry.positionsRejected,
      fastCount: telemetry.fastCalls,
      deepCount: telemetry.deepCalls,
      multiPvCount: telemetry.multiPvCalls,
      failureCount: failures.length,
      timeoutCount: telemetry.timeouts,
      warningCount: warnings.length,
      totalElapsedMs: stopwatch.elapsedMilliseconds,
      totalEngineCalls: telemetry.engineCalls,
    );
  }

  static bool _engineCallBudgetReached(
    MeasuredLocalReviewRequest request,
    List<LocalSchedulerExecutionResult> results,
  ) {
    final max = request.maxTotalEngineCalls;
    if (max == null) return false;
    return _sumEngineCalls(results) >= max;
  }

  static bool _engineCallBudgetExceeded(
    MeasuredLocalReviewRequest request,
    List<LocalSchedulerExecutionResult> results,
  ) {
    final max = request.maxTotalEngineCalls;
    if (max == null) return false;
    return _sumEngineCalls(results) > max;
  }

  static bool _plannedEngineCallsWouldExceed(
    MeasuredLocalReviewRequest request,
    List<LocalSchedulerExecutionResult> results,
    int plannedEngineCalls,
  ) {
    final max = request.maxTotalEngineCalls;
    if (max == null || plannedEngineCalls <= 0) return false;
    return _sumEngineCalls(results) + plannedEngineCalls > max;
  }

  static int? _remainingEngineCalls(
    MeasuredLocalReviewRequest request,
    List<LocalSchedulerExecutionResult> results,
  ) {
    final max = request.maxTotalEngineCalls;
    if (max == null) return null;
    final remaining = max - _sumEngineCalls(results);
    return remaining < 0 ? 0 : remaining;
  }

  static int _plannedEngineCallCount({
    required LocalAnalysisPositionInput input,
    required LocalSchedulerProfile profile,
  }) {
    final decision = LocalSmartAnalysisScheduler(profile: profile).plan(input);
    if (!decision.engineRequired || decision.steps.isEmpty) return 0;
    final first = decision.steps.first;
    if (decision.type == LocalSchedulerDecisionType.deepReanalysis &&
        first.kind == LocalEngineSearchStepKind.deepReanalysis) {
      return decision.steps.length + 1;
    }
    return decision.steps.length;
  }

  static bool _elapsedBudgetReached(
    MeasuredLocalReviewRequest request,
    int elapsedMs,
  ) {
    final max = request.maxTotalElapsedBudgetMs;
    return max != null && elapsedMs >= max;
  }

  static int _sumEngineCalls(List<LocalSchedulerExecutionResult> results) =>
      results.fold<int>(0, (sum, result) => sum + result.engineCallCount);

  static bool _isFailure(LocalSchedulerExecutionResult result) {
    return result.status == LocalSchedulerExecutionStatus.failed ||
        result.status == LocalSchedulerExecutionStatus.partialFailure;
  }

  static String? _positionRequestId(String? requestId, int index) =>
      requestId == null ? null : '$requestId#$index';

  static LocalAnalysisPositionInput _inputWithLowPowerOverride(
    LocalAnalysisPositionInput input,
    bool? lowPowerOverride,
  ) {
    if (lowPowerOverride == null || lowPowerOverride == input.lowPowerMode) {
      return input;
    }
    return LocalAnalysisPositionInput(
      fen: input.fen,
      moveNumber: input.moveNumber,
      plyIndex: input.plyIndex,
      legalMoveCount: input.legalMoveCount,
      isOpeningKnown: input.isOpeningKnown,
      isOnlyLegalMove: input.isOnlyLegalMove,
      materialDeltaAfterMoveCp: input.materialDeltaAfterMoveCp,
      previousEvalCp: input.previousEvalCp,
      provisionalEvalCp: input.provisionalEvalCp,
      candidateEvalSpreadCp: input.candidateEvalSpreadCp,
      hasCheck: input.hasCheck,
      givesCheck: input.givesCheck,
      isCapture: input.isCapture,
      isPromotion: input.isPromotion,
      isCastle: input.isCastle,
      lowPowerMode: lowPowerOverride,
      tags: input.tags,
    );
  }

  static MeasuredLocalReviewTelemetry _buildTelemetry({
    required List<LocalSchedulerExecutionResult> results,
    required int elapsedMilliseconds,
  }) {
    if (results.isEmpty) {
      return MeasuredLocalReviewTelemetry.empty;
    }

    var positionsSkipped = 0;
    var positionsRejected = 0;
    var engineCalls = 0;
    var fastCalls = 0;
    var deepCalls = 0;
    var multiPvCalls = 0;
    var timeouts = 0;
    var invalidFens = 0;
    var missingPvWarnings = 0;
    var missingBestmoveWarnings = 0;
    var budgetViolations = 0;
    var maxSingleElapsed = 0;
    int? slowestIndex;
    String? slowestId;

    for (var index = 0; index < results.length; index++) {
      final result = results[index];
      final telemetry = result.telemetry;
      positionsSkipped += telemetry.positionsSkipped;
      positionsRejected += telemetry.positionsRejected;
      engineCalls += telemetry.engineCalls;
      fastCalls += telemetry.fastCalls;
      deepCalls += telemetry.deepCalls;
      multiPvCalls += telemetry.multiPvCalls;
      timeouts += telemetry.timeoutCount;
      invalidFens += telemetry.invalidFenCount;
      budgetViolations += telemetry.budgetViolationCount;
      missingPvWarnings += result.warnings
          .where((warning) => warning.contains('missing pv'))
          .length;
      missingBestmoveWarnings += result.warnings
          .where((warning) => warning.contains('missing bestmove'))
          .length;
      if (result.elapsedMilliseconds >= maxSingleElapsed) {
        maxSingleElapsed = result.elapsedMilliseconds;
        slowestIndex = index;
        slowestId = result.requestId;
      }
    }

    return MeasuredLocalReviewTelemetry(
      positionsPlanned: results.length,
      positionsExecuted: results
          .where((result) => result.engineCallCount > 0)
          .length,
      positionsSkipped: positionsSkipped,
      positionsRejected: positionsRejected,
      engineCalls: engineCalls,
      fastCalls: fastCalls,
      deepCalls: deepCalls,
      multiPvCalls: multiPvCalls,
      elapsedMilliseconds: elapsedMilliseconds,
      timeouts: timeouts,
      invalidFens: invalidFens,
      missingPvWarnings: missingPvWarnings,
      missingBestmoveWarnings: missingBestmoveWarnings,
      budgetViolations: budgetViolations,
      maxSinglePositionElapsedMs: maxSingleElapsed,
      slowestPositionIndex: slowestIndex,
      slowestPositionId: slowestId,
    );
  }

  static MeasuredLocalReviewStatus _statusFor({
    required MeasuredLocalReviewRequest request,
    required List<LocalSchedulerExecutionResult> results,
    required List<MeasuredLocalReviewFailure> failures,
    required List<String> warnings,
    required bool stoppedByBudget,
    required int positionLimit,
  }) {
    if (request.positions.isNotEmpty &&
        results.isEmpty &&
        (positionLimit == 0 || stoppedByBudget)) {
      return warnings.isEmpty
          ? MeasuredLocalReviewStatus.completed
          : MeasuredLocalReviewStatus.completedWithWarnings;
    }
    if (results.isNotEmpty &&
        results.every(
          (result) => result.status == LocalSchedulerExecutionStatus.rejected,
        )) {
      return MeasuredLocalReviewStatus.rejected;
    }
    if (failures.isNotEmpty) {
      return request.failFast || failures.length == results.length
          ? MeasuredLocalReviewStatus.failed
          : MeasuredLocalReviewStatus.partialFailure;
    }
    if (warnings.isNotEmpty || stoppedByBudget) {
      return MeasuredLocalReviewStatus.completedWithWarnings;
    }
    return MeasuredLocalReviewStatus.completed;
  }
}

int _minInt(int a, int b) => a < b ? a : b;

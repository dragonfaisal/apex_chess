/// Developer-only game-level deep gating experiment.
library;

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

enum DeepCandidateReasonCode {
  majorEvalSwing('majorEvalSwing'),
  candidateEvalSpread('candidateEvalSpread'),
  tacticalSignal('tacticalSignal'),
  materialSwing('materialSwing'),
  givesCheck('givesCheck'),
  captureOrPromotion('captureOrPromotion'),
  mateScoreDetected('mateScoreDetected'),
  missingFastPv('missingFastPv'),
  highLegalMoveCount('highLegalMoveCount'),
  previousEvalAvailable('previousEvalAvailable'),
  budgetAllows('budgetAllows'),
  lowPowerSuppressed('lowPowerSuppressed'),
  alreadySkipped('alreadySkipped'),
  invalidFenSuppressed('invalidFenSuppressed'),
  openingSuppressed('openingSuppressed'),
  forcedSuppressed('forcedSuppressed'),
  failedFastPassSuppressed('failedFastPassSuppressed'),
  profileSuppressed('profileSuppressed'),
  budgetSuppressed('budgetSuppressed');

  const DeepCandidateReasonCode(this.wire);

  final String wire;
}

class GameLevelProvidedFastEvidence {
  const GameLevelProvidedFastEvidence({
    required this.positionIndex,
    this.scoreCp,
    this.mateIn,
    this.bestMoveUci,
    this.pvCount = 0,
    this.elapsedMilliseconds = 0,
    this.warnings = const <String>[],
    this.failed = false,
  }) : assert(positionIndex >= 0),
       assert(pvCount >= 0),
       assert(elapsedMilliseconds >= 0);

  final int positionIndex;
  final int? scoreCp;
  final int? mateIn;
  final String? bestMoveUci;
  final int pvCount;
  final int elapsedMilliseconds;
  final List<String> warnings;
  final bool failed;
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

class GameLevelFastPassResult {
  const GameLevelFastPassResult({
    required this.positionIndex,
    required this.input,
    required this.fastPvCount,
    required this.elapsedMilliseconds,
    required this.warnings,
    this.executionResult,
    this.scoreCp,
    this.mateIn,
    this.bestMoveUci,
    this.failureCode,
  }) : assert(positionIndex >= 0),
       assert(fastPvCount >= 0),
       assert(elapsedMilliseconds >= 0);

  factory GameLevelFastPassResult.fromExecution({
    required int positionIndex,
    required LocalAnalysisPositionInput input,
    required LocalSchedulerExecutionResult executionResult,
  }) {
    final snapshot =
        executionResult.fastSnapshot ?? executionResult.deepSnapshot;
    return GameLevelFastPassResult(
      positionIndex: positionIndex,
      input: input,
      executionResult: executionResult,
      scoreCp: snapshot?.scoreCp,
      mateIn: snapshot?.mateIn,
      bestMoveUci: snapshot?.bestMoveUci,
      fastPvCount: _snapshotPvCount(snapshot),
      elapsedMilliseconds: executionResult.elapsedMilliseconds,
      warnings: executionResult.warnings,
      failureCode: _executionFailed(executionResult)
          ? executionResult.failureCode ?? executionResult.status.wire
          : null,
    );
  }

  factory GameLevelFastPassResult.fromProvided({
    required LocalAnalysisPositionInput input,
    required GameLevelProvidedFastEvidence evidence,
  }) {
    return GameLevelFastPassResult(
      positionIndex: evidence.positionIndex,
      input: input,
      scoreCp: evidence.scoreCp,
      mateIn: evidence.mateIn,
      bestMoveUci: evidence.bestMoveUci,
      fastPvCount: evidence.pvCount,
      elapsedMilliseconds: evidence.elapsedMilliseconds,
      warnings: evidence.warnings,
      failureCode: evidence.failed ? 'provided_fast_pass_failed' : null,
    );
  }

  final int positionIndex;
  final LocalAnalysisPositionInput input;
  final LocalSchedulerExecutionResult? executionResult;
  final int? scoreCp;
  final int? mateIn;
  final String? bestMoveUci;
  final int fastPvCount;
  final List<String> warnings;
  final String? failureCode;
  final int elapsedMilliseconds;

  bool get failed => failureCode != null;
}

class DeepReanalysisCandidate {
  const DeepReanalysisCandidate({
    required this.positionIndex,
    required this.fen,
    required this.priorityScore,
    required this.reasonCodes,
    required this.proposedMultiPv,
    required this.proposedMovetime,
    required this.proposedDepth,
    required this.fastPassEvidence,
    required this.contextEvidence,
    required this.budgetCostEstimate,
    this.ply,
  }) : assert(positionIndex >= 0),
       assert(priorityScore >= 0),
       assert(proposedMultiPv >= 1),
       assert(proposedDepth > 0),
       assert(proposedMovetime > Duration.zero),
       assert(budgetCostEstimate >= 0);

  final int positionIndex;
  final int? ply;
  final String fen;
  final int priorityScore;
  final List<DeepCandidateReasonCode> reasonCodes;
  final int proposedMultiPv;
  final Duration proposedMovetime;
  final int proposedDepth;
  final String fastPassEvidence;
  final List<String> contextEvidence;
  final int budgetCostEstimate;

  String get debugSummary =>
      'index=$positionIndex ply=${ply ?? "-"} priority=$priorityScore '
      'multipv=$proposedMultiPv depth=$proposedDepth '
      'movetimeMs=${proposedMovetime.inMilliseconds} '
      'reasons=${reasonCodes.map((reason) => reason.wire).join(",")}';
}

class DeepCandidateSuppression {
  const DeepCandidateSuppression({
    required this.positionIndex,
    required this.reasonCode,
    required this.message,
  }) : assert(positionIndex >= 0);

  final int positionIndex;
  final DeepCandidateReasonCode reasonCode;
  final String message;

  String get debugSummary =>
      'index=$positionIndex reason=${reasonCode.wire} message="$message"';
}

class DeepGatingPlan {
  const DeepGatingPlan({
    required this.candidates,
    required this.selectedCandidates,
    required this.suppressions,
    required this.warnings,
  });

  final List<DeepReanalysisCandidate> candidates;
  final List<DeepReanalysisCandidate> selectedCandidates;
  final List<DeepCandidateSuppression> suppressions;
  final List<String> warnings;
}

class DeepGatingPolicyRequest {
  const DeepGatingPolicyRequest({
    required this.positions,
    required this.profile,
    required this.fastPassResults,
    this.maxDeepCandidates,
    this.maxDeepEngineCalls,
    this.maxTotalEngineCalls,
    this.fastEngineCalls = 0,
    this.maxTotalElapsedBudgetMs,
    this.elapsedMilliseconds = 0,
    this.lowPower = false,
  }) : assert(maxDeepCandidates == null || maxDeepCandidates >= 0),
       assert(maxDeepEngineCalls == null || maxDeepEngineCalls >= 0),
       assert(maxTotalEngineCalls == null || maxTotalEngineCalls >= 0),
       assert(fastEngineCalls >= 0),
       assert(maxTotalElapsedBudgetMs == null || maxTotalElapsedBudgetMs >= 0),
       assert(elapsedMilliseconds >= 0);

  final List<LocalAnalysisPositionInput> positions;
  final LocalSchedulerProfile profile;
  final List<GameLevelFastPassResult> fastPassResults;
  final int? maxDeepCandidates;
  final int? maxDeepEngineCalls;
  final int? maxTotalEngineCalls;
  final int fastEngineCalls;
  final int? maxTotalElapsedBudgetMs;
  final int elapsedMilliseconds;
  final bool lowPower;
}

class DeepGatingPolicy {
  const DeepGatingPolicy();

  DeepGatingPlan plan(DeepGatingPolicyRequest request) {
    final fastByIndex = <int, GameLevelFastPassResult>{
      for (final result in request.fastPassResults)
        result.positionIndex: result,
    };
    final candidates = <DeepReanalysisCandidate>[];
    final suppressions = <DeepCandidateSuppression>[];
    final warnings = <String>[];

    for (var index = 0; index < request.positions.length; index++) {
      final input = request.positions[index];
      final fast = fastByIndex[index];
      final staticReason = _staticSuppressionReason(
        input,
        request.profile,
        request.lowPower,
        fast,
      );
      if (staticReason != null) {
        suppressions.add(
          DeepCandidateSuppression(
            positionIndex: index,
            reasonCode: staticReason,
            message: _suppressionMessage(staticReason),
          ),
        );
        continue;
      }

      final scored = _scoreCandidate(
        index: index,
        input: input,
        fast: fast,
        profile: request.profile,
      );
      if (scored == null) continue;
      if (fast != null && fast.fastPvCount == 0) {
        warnings.add('position $index has no fast-pass PV');
      }
      candidates.add(scored);
    }

    candidates.sort(_compareCandidates);
    final selected = <DeepReanalysisCandidate>[];
    var remainingCandidateSlots =
        request.maxDeepCandidates ?? request.profile.maxCriticalReanalysisCount;
    var remainingDeepCalls = request.maxDeepEngineCalls;
    var remainingTotalCalls = request.maxTotalEngineCalls == null
        ? null
        : request.maxTotalEngineCalls! - request.fastEngineCalls;
    if (remainingTotalCalls != null && remainingTotalCalls < 0) {
      remainingTotalCalls = 0;
    }
    final elapsedBudgetExhausted =
        request.maxTotalElapsedBudgetMs != null &&
        request.elapsedMilliseconds >= request.maxTotalElapsedBudgetMs!;

    if (elapsedBudgetExhausted) {
      warnings.add('elapsed budget exhausted before deep selection');
    }

    for (final candidate in candidates) {
      if (remainingCandidateSlots <= 0) {
        suppressions.add(
          DeepCandidateSuppression(
            positionIndex: candidate.positionIndex,
            reasonCode: DeepCandidateReasonCode.budgetSuppressed,
            message: 'maxDeepCandidates reached',
          ),
        );
        continue;
      }
      if (elapsedBudgetExhausted) {
        suppressions.add(
          DeepCandidateSuppression(
            positionIndex: candidate.positionIndex,
            reasonCode: DeepCandidateReasonCode.budgetSuppressed,
            message: 'elapsed budget exhausted',
          ),
        );
        continue;
      }
      if (remainingDeepCalls != null &&
          candidate.budgetCostEstimate > remainingDeepCalls) {
        suppressions.add(
          DeepCandidateSuppression(
            positionIndex: candidate.positionIndex,
            reasonCode: DeepCandidateReasonCode.budgetSuppressed,
            message: 'maxDeepEngineCalls reached',
          ),
        );
        continue;
      }
      if (remainingTotalCalls != null &&
          candidate.budgetCostEstimate > remainingTotalCalls) {
        suppressions.add(
          DeepCandidateSuppression(
            positionIndex: candidate.positionIndex,
            reasonCode: DeepCandidateReasonCode.budgetSuppressed,
            message: 'maxTotalEngineCalls reached',
          ),
        );
        continue;
      }

      selected.add(candidate);
      remainingCandidateSlots--;
      if (remainingDeepCalls != null) {
        remainingDeepCalls -= candidate.budgetCostEstimate;
      }
      if (remainingTotalCalls != null) {
        remainingTotalCalls -= candidate.budgetCostEstimate;
      }
    }

    return DeepGatingPlan(
      candidates: List<DeepReanalysisCandidate>.unmodifiable(candidates),
      selectedCandidates: List<DeepReanalysisCandidate>.unmodifiable(selected),
      suppressions: List<DeepCandidateSuppression>.unmodifiable(suppressions),
      warnings: List<String>.unmodifiable(warnings),
    );
  }

  static DeepCandidateReasonCode? _staticSuppressionReason(
    LocalAnalysisPositionInput input,
    LocalSchedulerProfile profile,
    bool lowPower,
    GameLevelFastPassResult? fast,
  ) {
    final decision = LocalSmartAnalysisScheduler(profile: profile).plan(input);
    if (decision.type == LocalSchedulerDecisionType.rejectInvalidFen) {
      return DeepCandidateReasonCode.invalidFenSuppressed;
    }
    if (decision.type == LocalSchedulerDecisionType.skipOpening) {
      return DeepCandidateReasonCode.openingSuppressed;
    }
    if (decision.type == LocalSchedulerDecisionType.skipForced) {
      return DeepCandidateReasonCode.forcedSuppressed;
    }
    if (lowPower || input.lowPowerMode) {
      return DeepCandidateReasonCode.lowPowerSuppressed;
    }
    if (!profile.allowDeepReanalysis) {
      return DeepCandidateReasonCode.profileSuppressed;
    }
    if (fast != null && fast.failed) {
      return DeepCandidateReasonCode.failedFastPassSuppressed;
    }
    if (fast?.executionResult?.status ==
        LocalSchedulerExecutionStatus.skipped) {
      return DeepCandidateReasonCode.alreadySkipped;
    }
    return null;
  }

  static DeepReanalysisCandidate? _scoreCandidate({
    required int index,
    required LocalAnalysisPositionInput input,
    required GameLevelFastPassResult? fast,
    required LocalSchedulerProfile profile,
  }) {
    final reasons = <DeepCandidateReasonCode>[];
    final context = <String>[];
    var score = 0;

    if (fast?.mateIn != null) {
      score += 1000;
      reasons.add(DeepCandidateReasonCode.mateScoreDetected);
      context.add('mate score seen in fast pass');
    }

    final material = input.materialDeltaAfterMoveCp?.abs() ?? 0;
    if (material >= 150) {
      score += material >= 300 ? 260 : 190;
      reasons.add(DeepCandidateReasonCode.materialSwing);
      context.add('material delta cp=$material');
    }

    final evalSwing = _evalSwing(input, fast);
    if (evalSwing >= 200) {
      score += evalSwing >= 300 ? 300 : 220;
      reasons.add(DeepCandidateReasonCode.majorEvalSwing);
      context.add('eval swing cp=$evalSwing');
    }

    final spread = input.candidateEvalSpreadCp?.abs() ?? 0;
    if (spread >= 120) {
      score += spread >= 220 ? 230 : 170;
      reasons.add(DeepCandidateReasonCode.candidateEvalSpread);
      context.add('candidate spread cp=$spread');
    }

    if (input.hasCheck || input.givesCheck) {
      score += 100;
      reasons.add(DeepCandidateReasonCode.tacticalSignal);
      context.add('check signal');
      if (input.givesCheck) {
        score += 60;
        reasons.add(DeepCandidateReasonCode.givesCheck);
      }
    }

    if (input.isCapture || input.isPromotion) {
      score += input.isPromotion ? 180 : 70;
      reasons.add(DeepCandidateReasonCode.captureOrPromotion);
      context.add(input.isPromotion ? 'promotion' : 'capture');
    }

    final legalMoveCount = input.legalMoveCount ?? 0;
    if (legalMoveCount >= 35) {
      score += 100;
      reasons.add(DeepCandidateReasonCode.highLegalMoveCount);
      context.add('legal moves=$legalMoveCount');
    }

    if (input.previousEvalCp != null) {
      score += 20;
      reasons.add(DeepCandidateReasonCode.previousEvalAvailable);
    }

    if (fast != null && fast.fastPvCount == 0) {
      score += 90;
      reasons.add(DeepCandidateReasonCode.missingFastPv);
      context.add('fast pass had no PV');
    }

    if (score <= 0) return null;

    final multiPv = _proposedMultiPv(
      priorityScore: score,
      reasons: reasons,
      profile: profile,
    );
    final depth = _minInt(profile.deepDepth, profile.maxDepth);
    final movetime = _minDuration(profile.deepMovetime, profile.deepMovetime);
    reasons.add(DeepCandidateReasonCode.budgetAllows);

    return DeepReanalysisCandidate(
      positionIndex: index,
      ply: input.plyIndex,
      fen: input.fen,
      priorityScore: score,
      reasonCodes: List<DeepCandidateReasonCode>.unmodifiable(reasons),
      proposedMultiPv: multiPv,
      proposedMovetime: movetime,
      proposedDepth: depth,
      fastPassEvidence: _fastEvidenceSummary(fast),
      contextEvidence: List<String>.unmodifiable(context),
      budgetCostEstimate: 2,
    );
  }

  static int _evalSwing(
    LocalAnalysisPositionInput input,
    GameLevelFastPassResult? fast,
  ) {
    final prior = input.previousEvalCp;
    final provisional = input.provisionalEvalCp;
    if (prior != null && provisional != null) {
      return (prior - provisional).abs();
    }
    if (prior != null && fast?.scoreCp != null) {
      return (prior - fast!.scoreCp!).abs();
    }
    return 0;
  }

  static int _proposedMultiPv({
    required int priorityScore,
    required List<DeepCandidateReasonCode> reasons,
    required LocalSchedulerProfile profile,
  }) {
    if (profile.maxMultiPv <= 1) return 1;
    if (reasons.contains(DeepCandidateReasonCode.mateScoreDetected) ||
        priorityScore >= 300) {
      return _minInt(3, profile.maxMultiPv);
    }
    if (priorityScore >= 170) return _minInt(2, profile.maxMultiPv);
    return 1;
  }

  static String _fastEvidenceSummary(GameLevelFastPassResult? fast) {
    if (fast == null) return 'provided=false';
    final score = fast.mateIn != null
        ? 'mate=${fast.mateIn}'
        : 'cp=${fast.scoreCp ?? "-"}';
    return 'provided=true $score pv=${fast.fastPvCount} '
        'failed=${fast.failed} elapsedMs=${fast.elapsedMilliseconds}';
  }

  static String _suppressionMessage(DeepCandidateReasonCode reason) {
    return switch (reason) {
      DeepCandidateReasonCode.invalidFenSuppressed =>
        'invalid position text rejected before deep gating',
      DeepCandidateReasonCode.openingSuppressed =>
        'opening-known position suppressed',
      DeepCandidateReasonCode.forcedSuppressed =>
        'only-legal position suppressed',
      DeepCandidateReasonCode.lowPowerSuppressed =>
        'low-power mode suppresses deep pass',
      DeepCandidateReasonCode.failedFastPassSuppressed =>
        'fast pass failed before deep gating',
      DeepCandidateReasonCode.alreadySkipped =>
        'position was already skipped by scheduler',
      DeepCandidateReasonCode.profileSuppressed =>
        'profile does not allow deep reanalysis',
      DeepCandidateReasonCode.budgetSuppressed => 'budget suppressed',
      _ => 'suppressed',
    };
  }

  static int _compareCandidates(
    DeepReanalysisCandidate a,
    DeepReanalysisCandidate b,
  ) {
    final priority = b.priorityScore.compareTo(a.priorityScore);
    if (priority != 0) return priority;
    final index = a.positionIndex.compareTo(b.positionIndex);
    if (index != 0) return index;
    return a.fen.compareTo(b.fen);
  }
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
      results.add(
        GameLevelFastPassResult.fromExecution(
          positionIndex: index,
          input: positions[index],
          executionResult: run.measuredResult.positionResults[index],
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

Duration _minDuration(Duration a, Duration b) =>
    a.inMilliseconds <= b.inMilliseconds ? a : b;

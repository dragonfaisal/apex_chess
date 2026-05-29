/// Pure game-level deep-gating policy and evidence value objects.
library;

import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';

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

class GameLevelFastPassResult {
  const GameLevelFastPassResult({
    required this.positionIndex,
    required this.input,
    required this.fastPvCount,
    required this.elapsedMilliseconds,
    required this.warnings,
    this.scoreCp,
    this.mateIn,
    this.bestMoveUci,
    this.failureCode,
    this.alreadySkipped = false,
  }) : assert(positionIndex >= 0),
       assert(fastPvCount >= 0),
       assert(elapsedMilliseconds >= 0);

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
  final int? scoreCp;
  final int? mateIn;
  final String? bestMoveUci;
  final int fastPvCount;
  final List<String> warnings;
  final String? failureCode;
  final int elapsedMilliseconds;
  final bool alreadySkipped;

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
    if (fast?.alreadySkipped ?? false) {
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

int _minInt(int a, int b) => a < b ? a : b;

Duration _minDuration(Duration a, Duration b) =>
    a.inMilliseconds <= b.inMilliseconds ? a : b;

/// Pure representative-game tuning for the game-level deep gating policy.
library;

import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';

enum DeepGatingRepresentativeSourceType {
  pgn('pgn'),
  parsedPositions('parsedPositions'),
  schedulerInputs('schedulerInputs');

  const DeepGatingRepresentativeSourceType(this.wire);

  final String wire;
}

enum DeepGatingRepresentativeCategory {
  quietOpeningHeavy('quietOpeningHeavy'),
  tacticalMiddlegame('tacticalMiddlegame'),
  endgameTechnical('endgameTechnical'),
  lowPowerSuppression('lowPowerSuppression'),
  forcingLine('forcingLine'),
  mixedInvalidSafety('mixedInvalidSafety'),
  budgetPressure('budgetPressure');

  const DeepGatingRepresentativeCategory(this.wire);

  final String wire;
}

enum DeepGatingTuningMode {
  planOnly('planOnly'),
  fastThenPlanDeep('fastThenPlanDeep'),
  fastThenExecuteSelectedDeep('fastThenExecuteSelectedDeep');

  const DeepGatingTuningMode(this.wire);

  final String wire;
}

enum DeepGatingBudgetTuningStatus {
  completed('completed'),
  completedWithWarnings('completedWithWarnings'),
  empty('empty');

  const DeepGatingBudgetTuningStatus(this.wire);

  final String wire;
}

enum DeepGatingScenarioBudgetStatus {
  ok('ok'),
  budgetPressure('budgetPressure'),
  guardrailWarning('guardrailWarning');

  const DeepGatingScenarioBudgetStatus(this.wire);

  final String wire;
}

enum DeepGatingScenarioTuningRecommendation {
  budgetLooksSafe('budgetLooksSafe'),
  tooManyDeepCandidates('tooManyDeepCandidates'),
  tooFewCandidates('tooFewCandidates'),
  needsEvidenceTuning('needsEvidenceTuning'),
  blockedByBudget('blockedByBudget'),
  lowPowerSuppressedAsExpected('lowPowerSuppressedAsExpected');

  const DeepGatingScenarioTuningRecommendation(this.wire);

  final String wire;
}

class DeepGatingExpectedBehavior {
  const DeepGatingExpectedBehavior({
    this.minimumSourcePositions = 0,
    this.maximumSelectedDeepRatio,
    this.minimumCandidateCount,
    this.maximumCandidateCount,
    this.expectedOpeningSuppressions = 0,
    this.expectedForcedSuppressions = 0,
    this.expectedInvalidSuppressions = 0,
    this.expectBudgetPressure = false,
    this.maxDeepCandidates,
    this.maxDeepEngineCalls,
    this.maxTotalEngineCalls,
  }) : assert(minimumSourcePositions >= 0),
       assert(
         maximumSelectedDeepRatio == null ||
             (maximumSelectedDeepRatio >= 0 && maximumSelectedDeepRatio <= 1),
       ),
       assert(minimumCandidateCount == null || minimumCandidateCount >= 0),
       assert(maximumCandidateCount == null || maximumCandidateCount >= 0),
       assert(expectedOpeningSuppressions >= 0),
       assert(expectedForcedSuppressions >= 0),
       assert(expectedInvalidSuppressions >= 0),
       assert(maxDeepCandidates == null || maxDeepCandidates >= 0),
       assert(maxDeepEngineCalls == null || maxDeepEngineCalls >= 0),
       assert(maxTotalEngineCalls == null || maxTotalEngineCalls >= 0);

  final int minimumSourcePositions;
  final double? maximumSelectedDeepRatio;
  final int? minimumCandidateCount;
  final int? maximumCandidateCount;
  final int expectedOpeningSuppressions;
  final int expectedForcedSuppressions;
  final int expectedInvalidSuppressions;
  final bool expectBudgetPressure;
  final int? maxDeepCandidates;
  final int? maxDeepEngineCalls;
  final int? maxTotalEngineCalls;
}

class DeepGatingRepresentativeGame {
  const DeepGatingRepresentativeGame({
    required this.id,
    required this.title,
    required this.sourceType,
    required this.category,
    required this.positions,
    this.fastEvidence = const <GameLevelProvidedFastEvidence>[],
    this.notes = const <String>[],
    this.expected = const DeepGatingExpectedBehavior(),
  });

  final String id;
  final String title;
  final DeepGatingRepresentativeSourceType sourceType;
  final DeepGatingRepresentativeCategory category;
  final List<LocalAnalysisPositionInput> positions;
  final List<GameLevelProvidedFastEvidence> fastEvidence;
  final List<String> notes;
  final DeepGatingExpectedBehavior expected;
}

class DeepGatingTuningProfileRun {
  const DeepGatingTuningProfileRun({
    required this.profile,
    this.mode = DeepGatingTuningMode.planOnly,
    this.lowPower = false,
    this.maxDeepCandidates,
    this.maxDeepEngineCalls,
    this.maxTotalEngineCalls,
    this.maxTotalElapsedBudgetMs,
  }) : assert(maxDeepCandidates == null || maxDeepCandidates >= 0),
       assert(maxDeepEngineCalls == null || maxDeepEngineCalls >= 0),
       assert(maxTotalEngineCalls == null || maxTotalEngineCalls >= 0),
       assert(maxTotalElapsedBudgetMs == null || maxTotalElapsedBudgetMs >= 0);

  final LocalSchedulerProfile profile;
  final DeepGatingTuningMode mode;
  final bool lowPower;
  final int? maxDeepCandidates;
  final int? maxDeepEngineCalls;
  final int? maxTotalEngineCalls;
  final int? maxTotalElapsedBudgetMs;

  String get id =>
      '${profile.id.wire}${lowPower ? "-lowPower" : ""}:${mode.wire}';
}

class DeepGatingBudgetTuningRequest {
  const DeepGatingBudgetTuningRequest({
    required this.scenarios,
    this.profileRuns = DeepGatingBudgetProfileMatrix.defaultRuns,
  });

  final List<DeepGatingRepresentativeGame> scenarios;
  final List<DeepGatingTuningProfileRun> profileRuns;
}

class DeepGatingScenarioTuningSummary {
  const DeepGatingScenarioTuningSummary({
    required this.scenarioId,
    required this.profileId,
    required this.mode,
    required this.positionsConsidered,
    required this.candidatesGenerated,
    required this.candidatesSelected,
    required this.selectedDeepRatio,
    required this.topReasonCounts,
    required this.suppressionCounts,
    required this.budgetStatus,
    required this.warnings,
    required this.recommendation,
    required this.estimatedEngineCalls,
    required this.multiPvDeepCount,
  }) : assert(positionsConsidered >= 0),
       assert(candidatesGenerated >= 0),
       assert(candidatesSelected >= 0),
       assert(selectedDeepRatio >= 0),
       assert(estimatedEngineCalls >= 0),
       assert(multiPvDeepCount >= 0);

  final String scenarioId;
  final String profileId;
  final DeepGatingTuningMode mode;
  final int positionsConsidered;
  final int candidatesGenerated;
  final int candidatesSelected;
  final double selectedDeepRatio;
  final Map<DeepCandidateReasonCode, int> topReasonCounts;
  final Map<DeepCandidateReasonCode, int> suppressionCounts;
  final DeepGatingScenarioBudgetStatus budgetStatus;
  final List<String> warnings;
  final DeepGatingScenarioTuningRecommendation recommendation;
  final int estimatedEngineCalls;
  final int multiPvDeepCount;

  bool get hasBudgetPressure =>
      budgetStatus == DeepGatingScenarioBudgetStatus.budgetPressure;

  String get debugSummary =>
      'scenario=$scenarioId profile=$profileId mode=${mode.wire} '
      'positions=$positionsConsidered candidates=$candidatesGenerated '
      'selected=$candidatesSelected ratio=${_formatRatio(selectedDeepRatio)} '
      'budget=${budgetStatus.wire} recommendation=${recommendation.wire}';
}

class DeepGatingBudgetTuningResult {
  const DeepGatingBudgetTuningResult({
    required this.status,
    required this.scenarioCount,
    required this.profileRunCount,
    required this.totalPositionsConsidered,
    required this.candidatesGenerated,
    required this.candidatesSelected,
    required this.selectedDeepRatio,
    required this.suppressionsByReason,
    required this.reasonCounts,
    required this.estimatedEngineCalls,
    required this.multiPvDeepCount,
    required this.budgetViolations,
    required this.warnings,
    required this.timeouts,
    required this.scenarioSummaries,
    required this.observations,
  }) : assert(scenarioCount >= 0),
       assert(profileRunCount >= 0),
       assert(totalPositionsConsidered >= 0),
       assert(candidatesGenerated >= 0),
       assert(candidatesSelected >= 0),
       assert(selectedDeepRatio >= 0),
       assert(estimatedEngineCalls >= 0),
       assert(multiPvDeepCount >= 0),
       assert(budgetViolations >= 0),
       assert(timeouts >= 0);

  final DeepGatingBudgetTuningStatus status;
  final int scenarioCount;
  final int profileRunCount;
  final int totalPositionsConsidered;
  final int candidatesGenerated;
  final int candidatesSelected;
  final double selectedDeepRatio;
  final Map<DeepCandidateReasonCode, int> suppressionsByReason;
  final Map<DeepCandidateReasonCode, int> reasonCounts;
  final int estimatedEngineCalls;
  final int multiPvDeepCount;
  final int budgetViolations;
  final List<String> warnings;
  final int timeouts;
  final List<DeepGatingScenarioTuningSummary> scenarioSummaries;
  final List<String> observations;

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Deep Gating Budget Tuning')
      ..writeln()
      ..writeln('- status: ${status.wire}')
      ..writeln('- scenarios: $scenarioCount')
      ..writeln('- profile runs: $profileRunCount')
      ..writeln('- positions considered: $totalPositionsConsidered')
      ..writeln('- candidates generated: $candidatesGenerated')
      ..writeln('- candidates selected: $candidatesSelected')
      ..writeln('- selected deep ratio: ${_formatRatio(selectedDeepRatio)}')
      ..writeln('- estimated engine calls: $estimatedEngineCalls')
      ..writeln('- multipv deep count: $multiPvDeepCount')
      ..writeln('- budget warnings: $budgetViolations')
      ..writeln('- timeouts: $timeouts');

    if (scenarioSummaries.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(
          '| Scenario | Profile | Mode | Positions | Candidates | Selected | Ratio | Budget | Recommendation |',
        )
        ..writeln(
          '| --- | --- | --- | ---: | ---: | ---: | ---: | --- | --- |',
        );
      for (final summary in scenarioSummaries) {
        buffer.writeln(
          '| ${summary.scenarioId} | ${summary.profileId} | '
          '${summary.mode.wire} | ${summary.positionsConsidered} | '
          '${summary.candidatesGenerated} | ${summary.candidatesSelected} | '
          '${_formatRatio(summary.selectedDeepRatio)} | '
          '${summary.budgetStatus.wire} | ${summary.recommendation.wire} |',
        );
      }
    }

    _writeCounts(buffer, 'top candidate reasons', reasonCounts);
    _writeCounts(buffer, 'suppressions', suppressionsByReason);
    _writeLines(buffer, 'warnings', warnings);
    _writeLines(buffer, 'observations', observations);

    return buffer.toString().trimRight();
  }

  static void _writeCounts(
    StringBuffer buffer,
    String title,
    Map<DeepCandidateReasonCode, int> counts,
  ) {
    if (counts.isEmpty) return;
    buffer
      ..writeln()
      ..writeln('$title:');
    for (final entry in _sortedCounts(counts)) {
      buffer.writeln('- ${entry.key.wire}: ${entry.value}');
    }
  }

  static void _writeLines(
    StringBuffer buffer,
    String title,
    List<String> lines,
  ) {
    if (lines.isEmpty) return;
    buffer
      ..writeln()
      ..writeln('$title:');
    for (final line in lines.take(30)) {
      buffer.writeln('- $line');
    }
  }
}

class DeepGatingBudgetProfileMatrix {
  const DeepGatingBudgetProfileMatrix._();

  static const defaultRuns = <DeepGatingTuningProfileRun>[
    DeepGatingTuningProfileRun(profile: LocalSchedulerProfile.eco),
    DeepGatingTuningProfileRun(profile: LocalSchedulerProfile.balanced),
    DeepGatingTuningProfileRun(profile: LocalSchedulerProfile.performance),
    DeepGatingTuningProfileRun(profile: LocalSchedulerProfile.owner),
    DeepGatingTuningProfileRun(
      profile: LocalSchedulerProfile.balanced,
      lowPower: true,
    ),
  ];
}

class DeepGatingRepresentativeGames {
  const DeepGatingRepresentativeGames._();

  static const defaults = <DeepGatingRepresentativeGame>[
    quietOpeningHeavy,
    tacticalMiddlegame,
    endgameTechnical,
    lowPowerSuppression,
    forcingLine,
    mixedInvalidSafety,
    budgetPressure,
  ];

  static const quietOpeningHeavy = DeepGatingRepresentativeGame(
    id: 'quiet-opening-heavy',
    title: 'Quiet Opening Heavy',
    sourceType: DeepGatingRepresentativeSourceType.schedulerInputs,
    category: DeepGatingRepresentativeCategory.quietOpeningHeavy,
    positions: [
      LocalAnalysisPositionInput(fen: _fenOpening, isOpeningKnown: true),
      LocalAnalysisPositionInput(fen: _fenOpening, isOpeningKnown: true),
      LocalAnalysisPositionInput(fen: _fenOpening, isOpeningKnown: true),
      LocalAnalysisPositionInput(fen: _fenQuiet, legalMoveCount: 22),
      LocalAnalysisPositionInput(fen: _fenQuiet, legalMoveCount: 18),
    ],
    expected: DeepGatingExpectedBehavior(
      minimumSourcePositions: 5,
      maximumSelectedDeepRatio: 0.25,
      expectedOpeningSuppressions: 3,
    ),
  );

  static const tacticalMiddlegame = DeepGatingRepresentativeGame(
    id: 'tactical-middlegame',
    title: 'Tactical Middlegame',
    sourceType: DeepGatingRepresentativeSourceType.schedulerInputs,
    category: DeepGatingRepresentativeCategory.tacticalMiddlegame,
    positions: [
      LocalAnalysisPositionInput(fen: _fenQuiet, legalMoveCount: 24),
      LocalAnalysisPositionInput(
        fen: _fenTactical,
        legalMoveCount: 34,
        materialDeltaAfterMoveCp: -260,
        isCapture: true,
      ),
      LocalAnalysisPositionInput(
        fen: _fenTactical,
        legalMoveCount: 38,
        candidateEvalSpreadCp: 260,
      ),
      LocalAnalysisPositionInput(
        fen: _fenTactical,
        previousEvalCp: 180,
        provisionalEvalCp: -170,
        givesCheck: true,
      ),
      LocalAnalysisPositionInput(fen: _fenQuiet, legalMoveCount: 20),
    ],
    fastEvidence: [
      GameLevelProvidedFastEvidence(
        positionIndex: 3,
        scoreCp: -160,
        pvCount: 1,
      ),
    ],
    expected: DeepGatingExpectedBehavior(
      minimumSourcePositions: 5,
      maximumSelectedDeepRatio: 0.8,
      minimumCandidateCount: 3,
    ),
  );

  static const endgameTechnical = DeepGatingRepresentativeGame(
    id: 'endgame-technical',
    title: 'Technical Endgame',
    sourceType: DeepGatingRepresentativeSourceType.schedulerInputs,
    category: DeepGatingRepresentativeCategory.endgameTechnical,
    positions: [
      LocalAnalysisPositionInput(fen: _fenEndgame, legalMoveCount: 8),
      LocalAnalysisPositionInput(fen: _fenEndgame, legalMoveCount: 10),
      LocalAnalysisPositionInput(fen: _fenEndgame, legalMoveCount: 12),
      LocalAnalysisPositionInput(
        fen: _fenEndgame,
        legalMoveCount: 14,
        candidateEvalSpreadCp: 90,
      ),
    ],
    expected: DeepGatingExpectedBehavior(
      minimumSourcePositions: 4,
      maximumSelectedDeepRatio: 0.25,
      maximumCandidateCount: 1,
    ),
  );

  static const lowPowerSuppression = DeepGatingRepresentativeGame(
    id: 'low-power-suppression',
    title: 'Low Power Suppression',
    sourceType: DeepGatingRepresentativeSourceType.schedulerInputs,
    category: DeepGatingRepresentativeCategory.lowPowerSuppression,
    positions: [
      LocalAnalysisPositionInput(
        fen: _fenTactical,
        materialDeltaAfterMoveCp: -300,
        isCapture: true,
      ),
      LocalAnalysisPositionInput(fen: _fenTactical, candidateEvalSpreadCp: 280),
      LocalAnalysisPositionInput(fen: _fenQuiet),
    ],
    expected: DeepGatingExpectedBehavior(
      minimumSourcePositions: 3,
      maximumSelectedDeepRatio: 0.75,
    ),
  );

  static const forcingLine = DeepGatingRepresentativeGame(
    id: 'forcing-line',
    title: 'Forcing Line',
    sourceType: DeepGatingRepresentativeSourceType.schedulerInputs,
    category: DeepGatingRepresentativeCategory.forcingLine,
    positions: [
      LocalAnalysisPositionInput(fen: _fenTactical, isOnlyLegalMove: true),
      LocalAnalysisPositionInput(fen: _fenTactical, isOnlyLegalMove: true),
      LocalAnalysisPositionInput(fen: _fenTactical, givesCheck: true),
      LocalAnalysisPositionInput(fen: _fenQuiet),
    ],
    expected: DeepGatingExpectedBehavior(
      minimumSourcePositions: 4,
      maximumSelectedDeepRatio: 0.5,
      expectedForcedSuppressions: 2,
    ),
  );

  static const mixedInvalidSafety = DeepGatingRepresentativeGame(
    id: 'mixed-invalid-safety',
    title: 'Mixed Invalid Safety',
    sourceType: DeepGatingRepresentativeSourceType.schedulerInputs,
    category: DeepGatingRepresentativeCategory.mixedInvalidSafety,
    positions: [
      LocalAnalysisPositionInput(fen: 'bad fen'),
      LocalAnalysisPositionInput(fen: _fenOpening, isOpeningKnown: true),
      LocalAnalysisPositionInput(fen: _fenTactical, isOnlyLegalMove: true),
      LocalAnalysisPositionInput(fen: _fenTactical, candidateEvalSpreadCp: 220),
    ],
    expected: DeepGatingExpectedBehavior(
      minimumSourcePositions: 4,
      maximumSelectedDeepRatio: 0.35,
      expectedOpeningSuppressions: 1,
      expectedForcedSuppressions: 1,
      expectedInvalidSuppressions: 1,
    ),
  );

  static const budgetPressure = DeepGatingRepresentativeGame(
    id: 'budget-pressure',
    title: 'Budget Pressure',
    sourceType: DeepGatingRepresentativeSourceType.schedulerInputs,
    category: DeepGatingRepresentativeCategory.budgetPressure,
    positions: [
      LocalAnalysisPositionInput(fen: _fenTactical, candidateEvalSpreadCp: 260),
      LocalAnalysisPositionInput(
        fen: _fenTactical,
        materialDeltaAfterMoveCp: -320,
        isCapture: true,
      ),
      LocalAnalysisPositionInput(
        fen: _fenTactical,
        previousEvalCp: 220,
        provisionalEvalCp: -140,
      ),
      LocalAnalysisPositionInput(fen: _fenTactical, givesCheck: true),
      LocalAnalysisPositionInput(
        fen: _fenTactical,
        legalMoveCount: 42,
        candidateEvalSpreadCp: 180,
      ),
    ],
    expected: DeepGatingExpectedBehavior(
      minimumSourcePositions: 5,
      expectBudgetPressure: true,
      maxDeepCandidates: 2,
      maxDeepEngineCalls: 4,
      maxTotalEngineCalls: 4,
    ),
  );
}

class DeepGatingBudgetTuningRunner {
  const DeepGatingBudgetTuningRunner({
    DeepGatingPolicy policy = const DeepGatingPolicy(),
  }) : _policy = policy;

  final DeepGatingPolicy _policy;

  DeepGatingBudgetTuningResult run(DeepGatingBudgetTuningRequest request) {
    if (request.scenarios.isEmpty) {
      return const DeepGatingBudgetTuningResult(
        status: DeepGatingBudgetTuningStatus.empty,
        scenarioCount: 0,
        profileRunCount: 0,
        totalPositionsConsidered: 0,
        candidatesGenerated: 0,
        candidatesSelected: 0,
        selectedDeepRatio: 0,
        suppressionsByReason: <DeepCandidateReasonCode, int>{},
        reasonCounts: <DeepCandidateReasonCode, int>{},
        estimatedEngineCalls: 0,
        multiPvDeepCount: 0,
        budgetViolations: 0,
        warnings: <String>[],
        timeouts: 0,
        scenarioSummaries: <DeepGatingScenarioTuningSummary>[],
        observations: <String>['no representative scenarios supplied'],
      );
    }

    final summaries = <DeepGatingScenarioTuningSummary>[];
    final warnings = <String>[];
    final observations = <String>[];

    for (final scenario in request.scenarios) {
      for (final run in request.profileRuns) {
        final summary = _runScenario(scenario, run);
        summaries.add(summary);
        warnings.addAll(
          summary.warnings.map(
            (warning) => '${summary.scenarioId}/${summary.profileId}: $warning',
          ),
        );
      }
    }

    final suppressions = <DeepCandidateReasonCode, int>{};
    final reasons = <DeepCandidateReasonCode, int>{};
    var positions = 0;
    var candidates = 0;
    var selected = 0;
    var estimatedCalls = 0;
    var multiPvDeep = 0;
    var budgetWarnings = 0;

    for (final summary in summaries) {
      positions += summary.positionsConsidered;
      candidates += summary.candidatesGenerated;
      selected += summary.candidatesSelected;
      estimatedCalls += summary.estimatedEngineCalls;
      multiPvDeep += summary.multiPvDeepCount;
      if (summary.hasBudgetPressure) budgetWarnings++;
      _mergeCounts(suppressions, summary.suppressionCounts);
      _mergeCounts(reasons, summary.topReasonCounts);
    }

    if (_balancedSummaryFor(summaries, 'tactical-middlegame')
        case final tactical?) {
      observations.add(
        'tactical-middlegame balanced selected '
        '${tactical.candidatesSelected}/${tactical.positionsConsidered}',
      );
    }
    if (_balancedSummaryFor(summaries, 'budget-pressure') case final budget?) {
      observations.add(
        'budget-pressure selected ${budget.candidatesSelected} with '
        '${budgetWarnings > 0 ? "visible pressure" : "no pressure"}',
      );
    }

    final status = warnings.isEmpty
        ? DeepGatingBudgetTuningStatus.completed
        : DeepGatingBudgetTuningStatus.completedWithWarnings;

    return DeepGatingBudgetTuningResult(
      status: status,
      scenarioCount: request.scenarios.length,
      profileRunCount: request.profileRuns.length,
      totalPositionsConsidered: positions,
      candidatesGenerated: candidates,
      candidatesSelected: selected,
      selectedDeepRatio: _ratio(selected, positions),
      suppressionsByReason: _sortedMap(suppressions),
      reasonCounts: _sortedMap(reasons),
      estimatedEngineCalls: estimatedCalls,
      multiPvDeepCount: multiPvDeep,
      budgetViolations: budgetWarnings,
      warnings: List<String>.unmodifiable(warnings),
      timeouts: 0,
      scenarioSummaries: List<DeepGatingScenarioTuningSummary>.unmodifiable(
        summaries,
      ),
      observations: List<String>.unmodifiable(observations),
    );
  }

  DeepGatingScenarioTuningSummary _runScenario(
    DeepGatingRepresentativeGame scenario,
    DeepGatingTuningProfileRun run,
  ) {
    final maxDeepCandidates =
        scenario.expected.maxDeepCandidates ?? run.maxDeepCandidates;
    final maxDeepEngineCalls =
        scenario.expected.maxDeepEngineCalls ?? run.maxDeepEngineCalls;
    final maxTotalEngineCalls =
        scenario.expected.maxTotalEngineCalls ?? run.maxTotalEngineCalls;
    final plan = _policy.plan(
      DeepGatingPolicyRequest(
        positions: scenario.positions,
        profile: run.profile,
        fastPassResults: _fastResultsFor(scenario),
        maxDeepCandidates: maxDeepCandidates,
        maxDeepEngineCalls: maxDeepEngineCalls,
        maxTotalEngineCalls: maxTotalEngineCalls,
        maxTotalElapsedBudgetMs: run.maxTotalElapsedBudgetMs,
        lowPower: run.lowPower,
      ),
    );

    final reasonCounts = _reasonCounts(plan.selectedCandidates);
    final suppressionCounts = _suppressionCounts(plan.suppressions);
    final ratio = _ratio(
      plan.selectedCandidates.length,
      scenario.positions.length,
    );
    final budgetSuppressed =
        suppressionCounts[DeepCandidateReasonCode.budgetSuppressed] ?? 0;
    final budgetStatus = budgetSuppressed > 0
        ? DeepGatingScenarioBudgetStatus.budgetPressure
        : DeepGatingScenarioBudgetStatus.ok;
    final warnings = _guardrailWarnings(
      scenario: scenario,
      run: run,
      plan: plan,
      ratio: ratio,
      budgetStatus: budgetStatus,
    );
    final recommendation = _recommendationFor(
      scenario: scenario,
      run: run,
      plan: plan,
      ratio: ratio,
      budgetStatus: budgetStatus,
      warnings: warnings,
    );

    return DeepGatingScenarioTuningSummary(
      scenarioId: scenario.id,
      profileId: run.id,
      mode: run.mode,
      positionsConsidered: scenario.positions.length,
      candidatesGenerated: plan.candidates.length,
      candidatesSelected: plan.selectedCandidates.length,
      selectedDeepRatio: ratio,
      topReasonCounts: _sortedMap(reasonCounts),
      suppressionCounts: _sortedMap(suppressionCounts),
      budgetStatus:
          warnings.isNotEmpty &&
              budgetStatus == DeepGatingScenarioBudgetStatus.ok
          ? DeepGatingScenarioBudgetStatus.guardrailWarning
          : budgetStatus,
      warnings: List<String>.unmodifiable(warnings),
      recommendation: recommendation,
      estimatedEngineCalls: plan.selectedCandidates.fold<int>(
        0,
        (sum, candidate) => sum + candidate.budgetCostEstimate,
      ),
      multiPvDeepCount: plan.selectedCandidates
          .where((candidate) => candidate.proposedMultiPv > 1)
          .length,
    );
  }

  static List<GameLevelFastPassResult> _fastResultsFor(
    DeepGatingRepresentativeGame scenario,
  ) {
    return [
      for (final evidence in scenario.fastEvidence)
        if (evidence.positionIndex < scenario.positions.length)
          GameLevelFastPassResult.fromProvided(
            input: scenario.positions[evidence.positionIndex],
            evidence: evidence,
          ),
    ];
  }

  static List<String> _guardrailWarnings({
    required DeepGatingRepresentativeGame scenario,
    required DeepGatingTuningProfileRun run,
    required DeepGatingPlan plan,
    required double ratio,
    required DeepGatingScenarioBudgetStatus budgetStatus,
  }) {
    final warnings = <String>[];
    final expected = scenario.expected;
    final maxRatio =
        expected.maximumSelectedDeepRatio ?? _defaultMaxRatioFor(run);

    if (scenario.positions.length < expected.minimumSourcePositions) {
      warnings.add('source position count below expected minimum');
    }
    if (run.profile.id == LocalSchedulerProfileId.eco &&
        plan.selectedCandidates.isNotEmpty) {
      warnings.add('eco selected deep candidates');
    }
    if (run.lowPower && plan.selectedCandidates.isNotEmpty) {
      warnings.add('low-power selected deep candidates');
    }
    if (scenario.positions.length > 1 &&
        plan.selectedCandidates.length == scenario.positions.length) {
      warnings.add('selected every position');
    }
    if (ratio > maxRatio) {
      warnings.add(
        'selected ratio ${_formatRatio(ratio)} exceeds '
        '${_formatRatio(maxRatio)}',
      );
    }
    final expectsCandidateCounts =
        run.profile.allowDeepReanalysis && !run.lowPower;
    if (expectsCandidateCounts &&
        expected.minimumCandidateCount != null &&
        plan.candidates.length < expected.minimumCandidateCount!) {
      warnings.add('candidate count below expected minimum');
    }
    if (expectsCandidateCounts &&
        expected.maximumCandidateCount != null &&
        plan.candidates.length > expected.maximumCandidateCount!) {
      warnings.add('candidate count above expected maximum');
    }
    if (_countSuppression(plan, DeepCandidateReasonCode.openingSuppressed) <
        expected.expectedOpeningSuppressions) {
      warnings.add('opening suppression count below expected');
    }
    if (_countSuppression(plan, DeepCandidateReasonCode.forcedSuppressed) <
        expected.expectedForcedSuppressions) {
      warnings.add('forced suppression count below expected');
    }
    if (_countSuppression(plan, DeepCandidateReasonCode.invalidFenSuppressed) <
        expected.expectedInvalidSuppressions) {
      warnings.add('invalid suppression count below expected');
    }
    final expectsBudgetPressure =
        expected.expectBudgetPressure &&
        run.profile.allowDeepReanalysis &&
        !run.lowPower;
    if (expectsBudgetPressure &&
        budgetStatus != DeepGatingScenarioBudgetStatus.budgetPressure) {
      warnings.add('expected budget pressure was not visible');
    }
    if (!expectsBudgetPressure &&
        budgetStatus == DeepGatingScenarioBudgetStatus.budgetPressure) {
      warnings.add('unexpected budget pressure');
    }
    return warnings;
  }

  static DeepGatingScenarioTuningRecommendation _recommendationFor({
    required DeepGatingRepresentativeGame scenario,
    required DeepGatingTuningProfileRun run,
    required DeepGatingPlan plan,
    required double ratio,
    required DeepGatingScenarioBudgetStatus budgetStatus,
    required List<String> warnings,
  }) {
    if (run.lowPower && plan.selectedCandidates.isEmpty) {
      return DeepGatingScenarioTuningRecommendation
          .lowPowerSuppressedAsExpected;
    }
    if (budgetStatus == DeepGatingScenarioBudgetStatus.budgetPressure) {
      return DeepGatingScenarioTuningRecommendation.blockedByBudget;
    }
    if (warnings.any((warning) => warning.contains('selected'))) {
      return DeepGatingScenarioTuningRecommendation.tooManyDeepCandidates;
    }
    if (scenario.expected.minimumCandidateCount != null &&
        plan.candidates.length < scenario.expected.minimumCandidateCount!) {
      return DeepGatingScenarioTuningRecommendation.tooFewCandidates;
    }
    if (scenario.fastEvidence.isEmpty &&
        scenario.category ==
            DeepGatingRepresentativeCategory.tacticalMiddlegame &&
        ratio == 0) {
      return DeepGatingScenarioTuningRecommendation.needsEvidenceTuning;
    }
    return DeepGatingScenarioTuningRecommendation.budgetLooksSafe;
  }

  static double _defaultMaxRatioFor(DeepGatingTuningProfileRun run) {
    if (run.lowPower) return 0;
    return switch (run.profile.id) {
      LocalSchedulerProfileId.eco => 0,
      LocalSchedulerProfileId.balanced => 0.45,
      LocalSchedulerProfileId.performance => 0.6,
      LocalSchedulerProfileId.owner => 0.8,
    };
  }

  static int _countSuppression(
    DeepGatingPlan plan,
    DeepCandidateReasonCode reason,
  ) {
    return plan.suppressions.where((item) => item.reasonCode == reason).length;
  }

  static Map<DeepCandidateReasonCode, int> _reasonCounts(
    List<DeepReanalysisCandidate> candidates,
  ) {
    final counts = <DeepCandidateReasonCode, int>{};
    for (final candidate in candidates) {
      for (final reason in candidate.reasonCodes) {
        if (reason == DeepCandidateReasonCode.budgetAllows) continue;
        counts[reason] = (counts[reason] ?? 0) + 1;
      }
    }
    return counts;
  }

  static Map<DeepCandidateReasonCode, int> _suppressionCounts(
    List<DeepCandidateSuppression> suppressions,
  ) {
    final counts = <DeepCandidateReasonCode, int>{};
    for (final suppression in suppressions) {
      counts[suppression.reasonCode] =
          (counts[suppression.reasonCode] ?? 0) + 1;
    }
    return counts;
  }

  static void _mergeCounts(
    Map<DeepCandidateReasonCode, int> target,
    Map<DeepCandidateReasonCode, int> source,
  ) {
    for (final entry in source.entries) {
      target[entry.key] = (target[entry.key] ?? 0) + entry.value;
    }
  }

  static DeepGatingScenarioTuningSummary? _balancedSummaryFor(
    List<DeepGatingScenarioTuningSummary> summaries,
    String scenarioId,
  ) {
    return summaries
        .where(
          (summary) =>
              summary.scenarioId == scenarioId &&
              summary.profileId.startsWith('balanced:'),
        )
        .firstOrNull;
  }
}

Map<DeepCandidateReasonCode, int> _sortedMap(
  Map<DeepCandidateReasonCode, int> input,
) {
  return Map<DeepCandidateReasonCode, int>.fromEntries(_sortedCounts(input));
}

List<MapEntry<DeepCandidateReasonCode, int>> _sortedCounts(
  Map<DeepCandidateReasonCode, int> input,
) {
  final entries = input.entries.toList();
  entries.sort((a, b) {
    final count = b.value.compareTo(a.value);
    if (count != 0) return count;
    return a.key.wire.compareTo(b.key.wire);
  });
  return entries;
}

double _ratio(int selected, int positions) {
  if (positions == 0) return 0;
  return selected / positions;
}

String _formatRatio(double value) => value.toStringAsFixed(2);

const _fenOpening =
    'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1';
const _fenQuiet =
    'rn1qkbnr/ppp2ppp/3b4/3pp3/4P3/2NP1N2/PPP2PPP/R1BQKB1R w KQkq - 2 5';
const _fenTactical =
    'r2q1rk1/pp2bppp/2n1pn2/2bp4/3P4/2PBPN2/PP1N1PPP/R1BQ1RK1 w - - 0 9';
const _fenEndgame = '8/8/4k3/8/4K3/8/4P3/8 w - - 0 1';

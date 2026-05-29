/// Developer-only PGN-derived fixture comparison for local review integration.
library;

import 'package:dartchess/dartchess.dart';

import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_integration_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_orchestration_experiment.dart';

enum LocalReviewPgnFixtureCategory {
  quietOpening('quietOpening'),
  tacticalMiddlegame('tacticalMiddlegame'),
  forcingLine('forcingLine'),
  endgameTechnical('endgameTechnical'),
  budgetPressure('budgetPressure'),
  invalidSafety('invalidSafety');

  const LocalReviewPgnFixtureCategory(this.wire);

  final String wire;
}

enum LocalReviewPgnFixtureComparisonStatus {
  completed('completed'),
  completedWithWarnings('completedWithWarnings'),
  failed('failed'),
  empty('empty');

  const LocalReviewPgnFixtureComparisonStatus(this.wire);

  final String wire;
}

class LocalReviewPgnFixtureExpectedBehavior {
  const LocalReviewPgnFixtureExpectedBehavior({
    this.minMappedPositions = 0,
    this.maxSelectedDeepRatioBalanced = 0.5,
    this.maxSelectedDeepRatioPerformance = 0.75,
    this.performanceMaySelectAtLeastBalanced = true,
    this.ecoShouldSelectNoDeep = true,
    this.lowPowerShouldSelectNoDeep = true,
    this.expectBudgetPressure = false,
    this.expectSafeFailure = false,
  }) : assert(minMappedPositions >= 0),
       assert(
         maxSelectedDeepRatioBalanced >= 0 && maxSelectedDeepRatioBalanced <= 1,
       ),
       assert(
         maxSelectedDeepRatioPerformance >= 0 &&
             maxSelectedDeepRatioPerformance <= 1,
       );

  final int minMappedPositions;
  final double maxSelectedDeepRatioBalanced;
  final double maxSelectedDeepRatioPerformance;
  final bool performanceMaySelectAtLeastBalanced;
  final bool ecoShouldSelectNoDeep;
  final bool lowPowerShouldSelectNoDeep;
  final bool expectBudgetPressure;
  final bool expectSafeFailure;
}

class LocalReviewPgnFixturePositionHint {
  const LocalReviewPgnFixturePositionHint({
    required this.plyIndex,
    this.legalMoveCount,
    this.isOpeningKnown,
    this.isOnlyLegalMove,
    this.materialDeltaAfterMoveCp,
    this.previousEvalCp,
    this.provisionalEvalCp,
    this.candidateEvalSpreadCp,
    this.hasCheck,
    this.givesCheck,
    this.isCapture,
    this.isPromotion,
    this.isCastle,
    this.tags = const <String>[],
  }) : assert(plyIndex >= 0),
       assert(legalMoveCount == null || legalMoveCount >= 0);

  final int plyIndex;
  final int? legalMoveCount;
  final bool? isOpeningKnown;
  final bool? isOnlyLegalMove;
  final int? materialDeltaAfterMoveCp;
  final int? previousEvalCp;
  final int? provisionalEvalCp;
  final int? candidateEvalSpreadCp;
  final bool? hasCheck;
  final bool? givesCheck;
  final bool? isCapture;
  final bool? isPromotion;
  final bool? isCastle;
  final List<String> tags;
}

class LocalReviewPgnIntegrationFixture {
  const LocalReviewPgnIntegrationFixture({
    required this.id,
    required this.title,
    required this.pgn,
    required this.category,
    required this.expected,
    this.positionHints = const <LocalReviewPgnFixturePositionHint>[],
    this.notes = const <String>[],
  });

  final String id;
  final String title;
  final String pgn;
  final LocalReviewPgnFixtureCategory category;
  final LocalReviewPgnFixtureExpectedBehavior expected;
  final List<LocalReviewPgnFixturePositionHint> positionHints;
  final List<String> notes;
}

class LocalReviewPgnFixtureProfileRun {
  const LocalReviewPgnFixtureProfileRun({
    required this.budgetPreset,
    this.mode = LocalReviewIntegrationMode.planOnly,
    this.lowPower = false,
    this.maxPositions,
    this.maxFastEngineCalls,
    this.maxDeepCandidates,
    this.maxDeepEngineCalls,
    this.maxTotalEngineCalls,
    this.maxTotalElapsedBudgetMs,
  }) : assert(maxPositions == null || maxPositions >= 0),
       assert(maxFastEngineCalls == null || maxFastEngineCalls >= 0),
       assert(maxDeepCandidates == null || maxDeepCandidates >= 0),
       assert(maxDeepEngineCalls == null || maxDeepEngineCalls >= 0),
       assert(maxTotalEngineCalls == null || maxTotalEngineCalls >= 0),
       assert(maxTotalElapsedBudgetMs == null || maxTotalElapsedBudgetMs >= 0);

  final LocalReviewIntegrationBudgetPreset budgetPreset;
  final LocalReviewIntegrationMode mode;
  final bool lowPower;
  final int? maxPositions;
  final int? maxFastEngineCalls;
  final int? maxDeepCandidates;
  final int? maxDeepEngineCalls;
  final int? maxTotalEngineCalls;
  final int? maxTotalElapsedBudgetMs;

  String get id =>
      '${budgetPreset.id.wire}${lowPower ? "-lowPower" : ""}:${mode.wire}';
}

class LocalReviewPgnFixtureProfileMatrix {
  const LocalReviewPgnFixtureProfileMatrix._();

  static const planOnlyRuns = <LocalReviewPgnFixtureProfileRun>[
    LocalReviewPgnFixtureProfileRun(
      budgetPreset: LocalReviewIntegrationBudgetPreset.ecoSafe,
    ),
    LocalReviewPgnFixtureProfileRun(
      budgetPreset: LocalReviewIntegrationBudgetPreset.balancedDefault,
    ),
    LocalReviewPgnFixtureProfileRun(
      budgetPreset: LocalReviewIntegrationBudgetPreset.performanceMeasured,
    ),
    LocalReviewPgnFixtureProfileRun(
      budgetPreset: LocalReviewIntegrationBudgetPreset.ownerStrongLocal,
    ),
    LocalReviewPgnFixtureProfileRun(
      budgetPreset: LocalReviewIntegrationBudgetPreset.balancedDefault,
      lowPower: true,
    ),
  ];

  static const defaultRuns = <LocalReviewPgnFixtureProfileRun>[
    ...planOnlyRuns,
    LocalReviewPgnFixtureProfileRun(
      budgetPreset: LocalReviewIntegrationBudgetPreset.balancedDefault,
      mode: LocalReviewIntegrationMode.fastThenPlanDeep,
    ),
    LocalReviewPgnFixtureProfileRun(
      budgetPreset: LocalReviewIntegrationBudgetPreset.performanceMeasured,
      mode: LocalReviewIntegrationMode.fastThenPlanDeep,
    ),
  ];
}

class LocalReviewPgnFixtureMappingResult {
  const LocalReviewPgnFixtureMappingResult({
    required this.fixtureId,
    required this.sourcePositionCount,
    required this.positions,
    required this.warnings,
    this.failure,
  }) : assert(sourcePositionCount >= 0);

  final String fixtureId;
  final int sourcePositionCount;
  final List<LocalReviewOrchestrationPosition> positions;
  final List<String> warnings;
  final String? failure;

  bool get isSafeFailure => failure != null;
  int get mappedPositionCount => positions.length;
}

class LocalReviewProfileComparisonResult {
  const LocalReviewProfileComparisonResult({
    required this.fixtureId,
    required this.fixtureCategory,
    required this.presetId,
    required this.mode,
    required this.lowPower,
    required this.status,
    required this.sourcePositions,
    required this.mappedPositions,
    required this.pureCandidateCount,
    required this.selectedDeepCount,
    required this.executedDeepCount,
    required this.selectedDeepRatio,
    required this.totalEngineCalls,
    required this.fastEngineCalls,
    required this.deepEngineCalls,
    required this.elapsedMs,
    required this.budgetPressure,
    required this.warnings,
    required this.failures,
    required this.topReasonCounts,
    required this.suppressionCounts,
  }) : assert(sourcePositions >= 0),
       assert(mappedPositions >= 0),
       assert(pureCandidateCount >= 0),
       assert(selectedDeepCount >= 0),
       assert(executedDeepCount >= 0),
       assert(selectedDeepRatio >= 0),
       assert(totalEngineCalls >= 0),
       assert(fastEngineCalls >= 0),
       assert(deepEngineCalls >= 0),
       assert(elapsedMs >= 0);

  final String fixtureId;
  final LocalReviewPgnFixtureCategory fixtureCategory;
  final LocalReviewIntegrationBudgetPresetId presetId;
  final LocalReviewIntegrationMode mode;
  final bool lowPower;
  final LocalReviewIntegrationStatus status;
  final int sourcePositions;
  final int mappedPositions;
  final int pureCandidateCount;
  final int selectedDeepCount;
  final int executedDeepCount;
  final double selectedDeepRatio;
  final int totalEngineCalls;
  final int fastEngineCalls;
  final int deepEngineCalls;
  final int elapsedMs;
  final LocalReviewIntegrationBudgetPressureSummary budgetPressure;
  final List<String> warnings;
  final List<String> failures;
  final Map<DeepCandidateReasonCode, int> topReasonCounts;
  final Map<DeepCandidateReasonCode, int> suppressionCounts;

  String get runId =>
      '${presetId.wire}${lowPower ? "-lowPower" : ""}:${mode.wire}';

  String get debugSummary =>
      'fixture=$fixtureId run=$runId status=${status.wire} '
      'mapped=$mappedPositions candidates=$pureCandidateCount '
      'selected=$selectedDeepCount ratio=${_formatRatio(selectedDeepRatio)} '
      'calls=$totalEngineCalls pressure=${budgetPressure.hasPressure}';
}

class LocalReviewPgnFixtureComparisonRequest {
  const LocalReviewPgnFixtureComparisonRequest({
    required this.fixtures,
    this.profileRuns = LocalReviewPgnFixtureProfileMatrix.defaultRuns,
    this.failFast = false,
    this.requestId,
  });

  final List<LocalReviewPgnIntegrationFixture> fixtures;
  final List<LocalReviewPgnFixtureProfileRun> profileRuns;
  final bool failFast;
  final String? requestId;
}

class LocalReviewPgnFixtureComparisonResult {
  const LocalReviewPgnFixtureComparisonResult({
    required this.status,
    required this.fixtureCount,
    required this.profileRunCount,
    required this.entries,
    required this.warnings,
    required this.failures,
    required this.guardrailMessages,
  }) : assert(fixtureCount >= 0),
       assert(profileRunCount >= 0);

  final LocalReviewPgnFixtureComparisonStatus status;
  final int fixtureCount;
  final int profileRunCount;
  final List<LocalReviewProfileComparisonResult> entries;
  final List<String> warnings;
  final List<String> failures;
  final List<String> guardrailMessages;

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Local Review PGN Fixture Profiles')
      ..writeln()
      ..writeln('- status: ${status.wire}')
      ..writeln('- fixtures: $fixtureCount')
      ..writeln('- profile runs: $profileRunCount')
      ..writeln('- entries: ${entries.length}')
      ..writeln('- warnings: ${warnings.length}')
      ..writeln('- failures: ${failures.length}')
      ..writeln('- guardrails: ${guardrailMessages.length}');

    if (entries.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(
          '| Fixture | Run | Mapped | Candidates | Selected | Ratio | Calls | Pressure | Status |',
        )
        ..writeln(
          '| --- | --- | ---: | ---: | ---: | ---: | ---: | --- | --- |',
        );
      for (final entry in entries) {
        buffer.writeln(
          '| ${entry.fixtureId} | ${entry.runId} | ${entry.mappedPositions} | '
          '${entry.pureCandidateCount} | ${entry.selectedDeepCount} | '
          '${_formatRatio(entry.selectedDeepRatio)} | '
          '${entry.totalEngineCalls} | ${entry.budgetPressure.hasPressure} | '
          '${entry.status.wire} |',
        );
      }
    }

    _writeLines(buffer, 'guardrails', guardrailMessages);
    _writeLines(buffer, 'warnings', warnings);
    _writeLines(buffer, 'failures', failures);
    return buffer.toString().trimRight();
  }
}

class LocalReviewPgnIntegrationFixtures {
  const LocalReviewPgnIntegrationFixtures._();

  static const defaults = <LocalReviewPgnIntegrationFixture>[
    quietOpening,
    tacticalMiddlegame,
    forcingLine,
    endgameTechnical,
    budgetPressure,
    invalidSafety,
  ];

  static const quietOpening = LocalReviewPgnIntegrationFixture(
    id: 'quiet-opening-pgn',
    title: 'Quiet Opening PGN',
    category: LocalReviewPgnFixtureCategory.quietOpening,
    pgn: '1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6',
    expected: LocalReviewPgnFixtureExpectedBehavior(
      minMappedPositions: 8,
      maxSelectedDeepRatioBalanced: 0.25,
      maxSelectedDeepRatioPerformance: 0.35,
    ),
  );

  static const tacticalMiddlegame = LocalReviewPgnIntegrationFixture(
    id: 'tactical-middlegame-pgn',
    title: 'Tactical Middlegame PGN',
    category: LocalReviewPgnFixtureCategory.tacticalMiddlegame,
    pgn:
        '1. e4 e5 2. Nf3 d6 3. Bc4 Bg4 4. Nc3 g6 '
        '5. Nxe5 Bxd1 6. Bxf7+ Ke7 7. Nd5#',
    positionHints: [
      LocalReviewPgnFixturePositionHint(
        plyIndex: 8,
        materialDeltaAfterMoveCp: -260,
        candidateEvalSpreadCp: 220,
        isCapture: true,
      ),
      LocalReviewPgnFixturePositionHint(
        plyIndex: 10,
        previousEvalCp: 160,
        provisionalEvalCp: -180,
        givesCheck: true,
      ),
      LocalReviewPgnFixturePositionHint(
        plyIndex: 12,
        candidateEvalSpreadCp: 260,
        givesCheck: true,
      ),
    ],
    expected: LocalReviewPgnFixtureExpectedBehavior(
      minMappedPositions: 12,
      maxSelectedDeepRatioBalanced: 0.45,
      maxSelectedDeepRatioPerformance: 0.65,
    ),
  );

  static const forcingLine = LocalReviewPgnIntegrationFixture(
    id: 'forcing-line-pgn',
    title: 'Forcing Line PGN',
    category: LocalReviewPgnFixtureCategory.forcingLine,
    pgn: '1. e4 e5 2. Bc4 Nc6 3. Qh5 Nf6 4. Qxf7#',
    positionHints: [
      LocalReviewPgnFixturePositionHint(
        plyIndex: 6,
        candidateEvalSpreadCp: 240,
        givesCheck: true,
        isCapture: true,
      ),
    ],
    expected: LocalReviewPgnFixtureExpectedBehavior(
      minMappedPositions: 7,
      maxSelectedDeepRatioBalanced: 0.5,
      maxSelectedDeepRatioPerformance: 0.65,
    ),
  );

  static const endgameTechnical = LocalReviewPgnIntegrationFixture(
    id: 'technical-endgame-pgn',
    title: 'Technical Endgame PGN',
    category: LocalReviewPgnFixtureCategory.endgameTechnical,
    pgn:
        '[SetUp "1"]\n'
        '[FEN "8/8/4k3/8/4K3/8/4P3/8 w - - 0 1"]\n\n'
        '1. Kd4 Kd6 2. e4 Ke6 3. e5',
    positionHints: [
      LocalReviewPgnFixturePositionHint(plyIndex: 3, legalMoveCount: 12),
    ],
    expected: LocalReviewPgnFixtureExpectedBehavior(
      minMappedPositions: 5,
      maxSelectedDeepRatioBalanced: 0.25,
      maxSelectedDeepRatioPerformance: 0.35,
    ),
  );

  static const budgetPressure = LocalReviewPgnIntegrationFixture(
    id: 'budget-pressure-pgn',
    title: 'Budget Pressure PGN',
    category: LocalReviewPgnFixtureCategory.budgetPressure,
    pgn:
        '1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 '
        '5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3 O-O '
        '9. h3 Nb8 10. d4 Nbd7',
    positionHints: [
      LocalReviewPgnFixturePositionHint(
        plyIndex: 4,
        candidateEvalSpreadCp: 260,
        legalMoveCount: 36,
      ),
      LocalReviewPgnFixturePositionHint(
        plyIndex: 6,
        materialDeltaAfterMoveCp: -320,
        isCapture: true,
      ),
      LocalReviewPgnFixturePositionHint(
        plyIndex: 8,
        previousEvalCp: 220,
        provisionalEvalCp: -140,
      ),
      LocalReviewPgnFixturePositionHint(
        plyIndex: 10,
        givesCheck: true,
        candidateEvalSpreadCp: 180,
      ),
      LocalReviewPgnFixturePositionHint(
        plyIndex: 12,
        candidateEvalSpreadCp: 240,
        legalMoveCount: 42,
      ),
      LocalReviewPgnFixturePositionHint(
        plyIndex: 14,
        materialDeltaAfterMoveCp: 240,
      ),
    ],
    expected: LocalReviewPgnFixtureExpectedBehavior(
      minMappedPositions: 18,
      maxSelectedDeepRatioBalanced: 0.35,
      maxSelectedDeepRatioPerformance: 0.55,
      expectBudgetPressure: true,
    ),
  );

  static const invalidSafety = LocalReviewPgnIntegrationFixture(
    id: 'invalid-safety-pgn',
    title: 'Invalid Safety PGN',
    category: LocalReviewPgnFixtureCategory.invalidSafety,
    pgn: '[SetUp "1"]\n[FEN "bad fen"]\n\n1. e4',
    expected: LocalReviewPgnFixtureExpectedBehavior(
      expectSafeFailure: true,
      maxSelectedDeepRatioBalanced: 0,
      maxSelectedDeepRatioPerformance: 0,
    ),
  );
}

class LocalReviewPgnFixtureProfileRunner {
  const LocalReviewPgnFixtureProfileRunner({
    required LocalReviewIntegrationExperiment integration,
  }) : _integration = integration;

  final LocalReviewIntegrationExperiment _integration;

  Future<LocalReviewPgnFixtureComparisonResult> run(
    LocalReviewPgnFixtureComparisonRequest request,
  ) async {
    if (request.fixtures.isEmpty) {
      return const LocalReviewPgnFixtureComparisonResult(
        status: LocalReviewPgnFixtureComparisonStatus.empty,
        fixtureCount: 0,
        profileRunCount: 0,
        entries: <LocalReviewProfileComparisonResult>[],
        warnings: <String>[],
        failures: <String>[],
        guardrailMessages: <String>[],
      );
    }

    final entries = <LocalReviewProfileComparisonResult>[];
    final warnings = <String>[];
    final failures = <String>[];
    final mappingByFixture = <String, LocalReviewPgnFixtureMappingResult>{};

    for (final fixture in request.fixtures) {
      final mapped = LocalReviewPgnFixtureMapper.map(fixture);
      mappingByFixture[fixture.id] = mapped;
      warnings.addAll(
        mapped.warnings.map((warning) => '${fixture.id}: $warning'),
      );
      if (mapped.failure != null) {
        failures.add('${fixture.id}: ${mapped.failure}');
      }

      for (final run in request.profileRuns) {
        if (mapped.failure != null) {
          entries.add(_safeFailureEntry(fixture, run, mapped));
          continue;
        }

        final integrationResult = await _integration.run(
          LocalReviewIntegrationExperimentRequest.fromParsedPositions(
            positions: mapped.positions,
            budgetPreset: run.budgetPreset,
            mode: run.mode,
            maxPositions: run.maxPositions,
            maxFastEngineCalls: run.maxFastEngineCalls,
            maxDeepCandidates: run.maxDeepCandidates,
            maxDeepEngineCalls: run.maxDeepEngineCalls,
            maxTotalEngineCalls: run.maxTotalEngineCalls,
            maxTotalElapsedBudgetMs: run.maxTotalElapsedBudgetMs,
            failFast: request.failFast,
            lowPower: run.lowPower,
            requestId: _runRequestId(request.requestId, fixture.id, run.id),
          ),
        );

        entries.add(
          _entryFromIntegration(
            fixture: fixture,
            run: run,
            mapped: mapped,
            result: integrationResult,
          ),
        );
      }
    }

    final guardrails = _guardrails(request.fixtures, entries, mappingByFixture);
    warnings.addAll(guardrails);
    final status = _statusFor(
      entries: entries,
      failures: failures,
      guardrails: guardrails,
    );

    return LocalReviewPgnFixtureComparisonResult(
      status: status,
      fixtureCount: request.fixtures.length,
      profileRunCount: request.profileRuns.length,
      entries: List<LocalReviewProfileComparisonResult>.unmodifiable(entries),
      warnings: List<String>.unmodifiable(warnings),
      failures: List<String>.unmodifiable(failures),
      guardrailMessages: List<String>.unmodifiable(guardrails),
    );
  }

  static LocalReviewProfileComparisonResult _entryFromIntegration({
    required LocalReviewPgnIntegrationFixture fixture,
    required LocalReviewPgnFixtureProfileRun run,
    required LocalReviewPgnFixtureMappingResult mapped,
    required LocalReviewIntegrationExperimentResult result,
  }) {
    final primary = result.executionResult ?? result.purePlanResult;
    return LocalReviewProfileComparisonResult(
      fixtureId: fixture.id,
      fixtureCategory: fixture.category,
      presetId: run.budgetPreset.id,
      mode: run.mode,
      lowPower: run.lowPower,
      status: result.status,
      sourcePositions: result.sourcePositionCount,
      mappedPositions: result.mappedPositionCount,
      pureCandidateCount: result.purePlanCandidateCount,
      selectedDeepCount: result.selectedDeepCount,
      executedDeepCount: result.executedDeepCount,
      selectedDeepRatio: result.selectedDeepRatio,
      totalEngineCalls: result.totalEngineCalls,
      fastEngineCalls: result.fastEngineCalls,
      deepEngineCalls: result.deepEngineCalls,
      elapsedMs: result.totalElapsedMs,
      budgetPressure: result.budgetPressure,
      warnings: List<String>.unmodifiable([
        ...mapped.warnings,
        ...result.warnings,
      ]),
      failures: result.failures,
      topReasonCounts: _reasonCounts(primary.selectedCandidates),
      suppressionCounts: _suppressionCounts(primary.suppressions),
    );
  }

  static LocalReviewProfileComparisonResult _safeFailureEntry(
    LocalReviewPgnIntegrationFixture fixture,
    LocalReviewPgnFixtureProfileRun run,
    LocalReviewPgnFixtureMappingResult mapped,
  ) {
    return LocalReviewProfileComparisonResult(
      fixtureId: fixture.id,
      fixtureCategory: fixture.category,
      presetId: run.budgetPreset.id,
      mode: run.mode,
      lowPower: run.lowPower,
      status: LocalReviewIntegrationStatus.rejected,
      sourcePositions: mapped.sourcePositionCount,
      mappedPositions: mapped.mappedPositionCount,
      pureCandidateCount: 0,
      selectedDeepCount: 0,
      executedDeepCount: 0,
      selectedDeepRatio: 0,
      totalEngineCalls: 0,
      fastEngineCalls: 0,
      deepEngineCalls: 0,
      elapsedMs: 0,
      budgetPressure: LocalReviewIntegrationBudgetPressureSummary.empty,
      warnings: mapped.warnings,
      failures: [if (mapped.failure != null) mapped.failure!],
      topReasonCounts: const <DeepCandidateReasonCode, int>{},
      suppressionCounts: const <DeepCandidateReasonCode, int>{},
    );
  }

  static List<String> _guardrails(
    List<LocalReviewPgnIntegrationFixture> fixtures,
    List<LocalReviewProfileComparisonResult> entries,
    Map<String, LocalReviewPgnFixtureMappingResult> mappingByFixture,
  ) {
    final messages = <String>[];
    for (final fixture in fixtures) {
      final mapped = mappingByFixture[fixture.id];
      if (mapped == null) continue;
      final expected = fixture.expected;

      if (expected.expectSafeFailure) {
        final safe = entries
            .where((entry) => entry.fixtureId == fixture.id)
            .every(
              (entry) => entry.status == LocalReviewIntegrationStatus.rejected,
            );
        if (!safe) {
          messages.add('${fixture.id}: invalid fixture did not fail safely');
        }
        continue;
      }

      if (mapped.mappedPositionCount < expected.minMappedPositions) {
        messages.add('${fixture.id}: mapped fewer positions than expected');
      }

      final eco = _entry(
        entries,
        fixture.id,
        LocalReviewIntegrationBudgetPresetId.ecoSafe,
        LocalReviewIntegrationMode.planOnly,
      );
      if (expected.ecoShouldSelectNoDeep &&
          eco != null &&
          eco.selectedDeepCount != 0) {
        messages.add('${fixture.id}: eco selected deep candidates');
      }

      final lowPower = _entry(
        entries,
        fixture.id,
        LocalReviewIntegrationBudgetPresetId.balancedDefault,
        LocalReviewIntegrationMode.planOnly,
        lowPower: true,
      );
      if (expected.lowPowerShouldSelectNoDeep &&
          lowPower != null &&
          lowPower.selectedDeepCount != 0) {
        messages.add('${fixture.id}: low-power selected deep candidates');
      }

      final balanced = _entry(
        entries,
        fixture.id,
        LocalReviewIntegrationBudgetPresetId.balancedDefault,
        LocalReviewIntegrationMode.planOnly,
      );
      if (balanced != null &&
          balanced.selectedDeepRatio > expected.maxSelectedDeepRatioBalanced) {
        messages.add('${fixture.id}: balanced selected ratio too high');
      }
      if (balanced != null &&
          balanced.mappedPositions > 1 &&
          balanced.selectedDeepCount >= balanced.mappedPositions) {
        messages.add('${fixture.id}: balanced selected every position');
      }

      final performance = _entry(
        entries,
        fixture.id,
        LocalReviewIntegrationBudgetPresetId.performanceMeasured,
        LocalReviewIntegrationMode.planOnly,
      );
      if (performance != null &&
          performance.selectedDeepRatio >
              expected.maxSelectedDeepRatioPerformance) {
        messages.add('${fixture.id}: performance selected ratio too high');
      }
      if (performance != null &&
          performance.mappedPositions > 1 &&
          performance.selectedDeepCount >= performance.mappedPositions) {
        messages.add('${fixture.id}: performance selected every position');
      }
      if (expected.performanceMaySelectAtLeastBalanced &&
          balanced != null &&
          performance != null &&
          performance.selectedDeepCount < balanced.selectedDeepCount) {
        messages.add(
          '${fixture.id}: performance selected fewer candidates than balanced',
        );
      }

      final owner = _entry(
        entries,
        fixture.id,
        LocalReviewIntegrationBudgetPresetId.ownerStrongLocal,
        LocalReviewIntegrationMode.planOnly,
      );
      if (owner != null &&
          owner.mappedPositions > 1 &&
          owner.selectedDeepCount >= owner.mappedPositions) {
        messages.add('${fixture.id}: owner selected every position');
      }

      if (expected.expectBudgetPressure &&
          balanced != null &&
          !balanced.budgetPressure.hasPressure) {
        messages.add('${fixture.id}: expected budget pressure was not visible');
      }
    }
    return messages;
  }

  static LocalReviewProfileComparisonResult? _entry(
    List<LocalReviewProfileComparisonResult> entries,
    String fixtureId,
    LocalReviewIntegrationBudgetPresetId presetId,
    LocalReviewIntegrationMode mode, {
    bool lowPower = false,
  }) {
    return entries
        .where(
          (entry) =>
              entry.fixtureId == fixtureId &&
              entry.presetId == presetId &&
              entry.mode == mode &&
              entry.lowPower == lowPower,
        )
        .firstOrNull;
  }

  static LocalReviewPgnFixtureComparisonStatus _statusFor({
    required List<LocalReviewProfileComparisonResult> entries,
    required List<String> failures,
    required List<String> guardrails,
  }) {
    if (entries.any(
      (entry) => entry.status == LocalReviewIntegrationStatus.failed,
    )) {
      return LocalReviewPgnFixtureComparisonStatus.failed;
    }
    if (failures.isNotEmpty || guardrails.isNotEmpty) {
      return LocalReviewPgnFixtureComparisonStatus.completedWithWarnings;
    }
    if (entries.any(
      (entry) =>
          entry.status == LocalReviewIntegrationStatus.completedWithWarnings ||
          entry.status == LocalReviewIntegrationStatus.partialFailure,
    )) {
      return LocalReviewPgnFixtureComparisonStatus.completedWithWarnings;
    }
    return LocalReviewPgnFixtureComparisonStatus.completed;
  }

  static String? _runRequestId(
    String? requestId,
    String fixtureId,
    String runId,
  ) {
    if (requestId == null) return null;
    return '$requestId:$fixtureId:$runId';
  }
}

class LocalReviewPgnFixtureMapper {
  const LocalReviewPgnFixtureMapper._();

  static LocalReviewPgnFixtureMappingResult map(
    LocalReviewPgnIntegrationFixture fixture,
  ) {
    try {
      final parsed = _positionsFromPgn(fixture.pgn);
      final hinted = _applyHints(parsed, fixture.positionHints);
      return LocalReviewPgnFixtureMappingResult(
        fixtureId: fixture.id,
        sourcePositionCount: parsed.length,
        positions: List<LocalReviewOrchestrationPosition>.unmodifiable(hinted),
        warnings: const <String>[],
      );
    } on Object catch (error) {
      return LocalReviewPgnFixtureMappingResult(
        fixtureId: fixture.id,
        sourcePositionCount: 0,
        positions: const <LocalReviewOrchestrationPosition>[],
        warnings: const <String>['PGN fixture could not be parsed'],
        failure: error.toString(),
      );
    }
  }

  static List<LocalReviewOrchestrationPosition> _applyHints(
    List<LocalReviewOrchestrationPosition> positions,
    List<LocalReviewPgnFixturePositionHint> hints,
  ) {
    final hintsByPly = <int, LocalReviewPgnFixturePositionHint>{
      for (final hint in hints) hint.plyIndex: hint,
    };
    return [
      for (final position in positions)
        if (position.plyIndex case final ply? when hintsByPly.containsKey(ply))
          _mergeHint(position, hintsByPly[ply]!)
        else
          position,
    ];
  }

  static LocalReviewOrchestrationPosition _mergeHint(
    LocalReviewOrchestrationPosition position,
    LocalReviewPgnFixturePositionHint hint,
  ) {
    return LocalReviewOrchestrationPosition(
      fen: position.fen,
      reference: position.reference,
      plyIndex: position.plyIndex,
      moveNumber: position.moveNumber,
      legalMoveCount: hint.legalMoveCount ?? position.legalMoveCount,
      isOpeningKnown: hint.isOpeningKnown ?? position.isOpeningKnown,
      isOnlyLegalMove: hint.isOnlyLegalMove ?? position.isOnlyLegalMove,
      materialDeltaAfterMoveCp:
          hint.materialDeltaAfterMoveCp ?? position.materialDeltaAfterMoveCp,
      previousEvalCp: hint.previousEvalCp ?? position.previousEvalCp,
      provisionalEvalCp: hint.provisionalEvalCp ?? position.provisionalEvalCp,
      candidateEvalSpreadCp:
          hint.candidateEvalSpreadCp ?? position.candidateEvalSpreadCp,
      hasCheck: hint.hasCheck ?? position.hasCheck,
      givesCheck: hint.givesCheck ?? position.givesCheck,
      isCapture: hint.isCapture ?? position.isCapture,
      isPromotion: hint.isPromotion ?? position.isPromotion,
      isCastle: hint.isCastle ?? position.isCastle,
      tags: [...position.tags, ...hint.tags],
    );
  }

  static List<LocalReviewOrchestrationPosition> _positionsFromPgn(String pgn) {
    final game = PgnGame.parsePgn(pgn);
    Position position = PgnGame.startingPosition(game.headers);
    final positions = <LocalReviewOrchestrationPosition>[];

    var ply = 0;
    for (final node in game.moves.mainline()) {
      final move = position.parseSan(node.san);
      if (move == null) {
        throw FormatException('Could not parse SAN at ply $ply.');
      }
      final fenBefore = position.fen;
      final next = position.play(move);
      final normal = move is NormalMove ? move : null;
      final isCastle = normal != null && _isCastle(position, normal);
      final uci = normal == null
          ? null
          : '${_sqAlg(normal.from)}${_sqAlg(normal.to)}'
                '${normal.promotion == null ? "" : _roleChar(normal.promotion!)}';

      positions.add(
        LocalReviewOrchestrationPosition(
          fen: fenBefore,
          reference: 'ply-$ply',
          plyIndex: ply,
          moveNumber: (ply ~/ 2) + 1,
          hasCheck: position.isCheck,
          givesCheck: next.isCheck,
          isCapture: normal != null && _isCapture(position, normal),
          isPromotion: normal?.promotion != null,
          isCastle: isCastle,
          tags: ['source:pgn', 'san:${node.san}', if (uci != null) 'uci:$uci'],
        ),
      );

      position = next;
      ply++;
    }

    return positions;
  }

  static bool _isCapture(Position position, NormalMove move) {
    final movingPiece = position.board.pieceAt(move.from);
    final targetPiece = position.board.pieceAt(move.to);
    if (targetPiece == null) return false;
    return !_isCastleForPiece(movingPiece, move);
  }

  static bool _isCastle(Position position, NormalMove move) {
    final movingPiece = position.board.pieceAt(move.from);
    return _isCastleForPiece(movingPiece, move);
  }

  static bool _isCastleForPiece(Piece? movingPiece, NormalMove move) {
    return movingPiece != null &&
        movingPiece.role == Role.king &&
        move.from.file == 4 &&
        (move.to.file == 0 || move.to.file == 7);
  }

  static String _sqAlg(Square sq) {
    final file = String.fromCharCode('a'.codeUnitAt(0) + sq.file);
    return '$file${sq.rank + 1}';
  }

  static String _roleChar(Role role) => switch (role) {
    Role.queen => 'q',
    Role.rook => 'r',
    Role.bishop => 'b',
    Role.knight => 'n',
    _ => '',
  };
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

void _writeLines(StringBuffer buffer, String title, List<String> lines) {
  if (lines.isEmpty) return;
  buffer
    ..writeln()
    ..writeln('$title:');
  for (final line in lines.take(30)) {
    buffer.writeln('- $line');
  }
}

String _formatRatio(double value) => value.toStringAsFixed(2);

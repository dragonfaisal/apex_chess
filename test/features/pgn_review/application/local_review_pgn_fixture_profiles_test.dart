import 'dart:async';
import 'dart:io';

import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/infrastructure/engine/chess_engine.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_command.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_event.dart';
import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_integration_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_orchestration_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_pgn_fixture_profiles.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_executor.dart';
import 'package:apex_chess/features/pgn_review/application/measured_local_review_prototype.dart';
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalReviewPgnIntegrationFixtures mapping', () {
    test('fixture IDs are unique', () {
      final ids = LocalReviewPgnIntegrationFixtures.defaults
          .map((fixture) => fixture.id)
          .toList();

      expect(ids.toSet(), hasLength(ids.length));
      expect(ids, contains('quiet-opening-pgn'));
      expect(ids, contains('budget-pressure-pgn'));
      expect(ids, contains('invalid-safety-pgn'));
    });

    test('PGN fixtures parse or fail safely according to category', () {
      for (final fixture in LocalReviewPgnIntegrationFixtures.defaults) {
        final mapped = LocalReviewPgnFixtureMapper.map(fixture);
        if (fixture.category == LocalReviewPgnFixtureCategory.invalidSafety) {
          expect(mapped.isSafeFailure, isTrue, reason: fixture.id);
          expect(mapped.positions, isEmpty, reason: fixture.id);
        } else {
          expect(mapped.failure, isNull, reason: fixture.id);
          expect(
            mapped.mappedPositionCount,
            greaterThanOrEqualTo(fixture.expected.minMappedPositions),
            reason: fixture.id,
          );
        }
      }
    });
  });

  group('LocalReviewPgnFixtureProfileRunner profile behavior', () {
    test(
      'quiet opening maps positions and balanced remains conservative',
      () async {
        final result = await _runner(_FakeLocalEvalService()).run(
          const LocalReviewPgnFixtureComparisonRequest(
            fixtures: [LocalReviewPgnIntegrationFixtures.quietOpening],
            profileRuns: LocalReviewPgnFixtureProfileMatrix.planOnlyRuns,
          ),
        );
        final balanced = _entry(
          result,
          'quiet-opening-pgn',
          LocalReviewIntegrationBudgetPresetId.balancedDefault,
        );

        expect(balanced.mappedPositions, greaterThanOrEqualTo(8));
        expect(balanced.selectedDeepRatio, lessThanOrEqualTo(0.25));
        expect(balanced.selectedDeepCount, 0);
        expect(result.guardrailMessages, isEmpty);
      },
    );

    test('tactical fixture maps positions and creates candidates', () async {
      final result = await _runner(_FakeLocalEvalService()).run(
        const LocalReviewPgnFixtureComparisonRequest(
          fixtures: [LocalReviewPgnIntegrationFixtures.tacticalMiddlegame],
          profileRuns: LocalReviewPgnFixtureProfileMatrix.planOnlyRuns,
        ),
      );
      final balanced = _entry(
        result,
        'tactical-middlegame-pgn',
        LocalReviewIntegrationBudgetPresetId.balancedDefault,
      );

      expect(balanced.mappedPositions, greaterThanOrEqualTo(12));
      expect(balanced.pureCandidateCount, greaterThan(0));
      expect(balanced.selectedDeepCount, greaterThan(0));
      expect(
        balanced.topReasonCounts[DeepCandidateReasonCode.candidateEvalSpread],
        greaterThanOrEqualTo(1),
      );
    });

    test('forcing line fixture does not select every move', () async {
      final result = await _runner(_FakeLocalEvalService()).run(
        const LocalReviewPgnFixtureComparisonRequest(
          fixtures: [LocalReviewPgnIntegrationFixtures.forcingLine],
          profileRuns: LocalReviewPgnFixtureProfileMatrix.planOnlyRuns,
        ),
      );
      final balanced = _entry(
        result,
        'forcing-line-pgn',
        LocalReviewIntegrationBudgetPresetId.balancedDefault,
      );

      expect(balanced.selectedDeepCount, greaterThan(0));
      expect(balanced.selectedDeepCount, lessThan(balanced.mappedPositions));
    });

    test('technical endgame fixture remains conservative', () async {
      final result = await _runner(_FakeLocalEvalService()).run(
        const LocalReviewPgnFixtureComparisonRequest(
          fixtures: [LocalReviewPgnIntegrationFixtures.endgameTechnical],
          profileRuns: LocalReviewPgnFixtureProfileMatrix.planOnlyRuns,
        ),
      );
      final balanced = _entry(
        result,
        'technical-endgame-pgn',
        LocalReviewIntegrationBudgetPresetId.balancedDefault,
      );

      expect(balanced.mappedPositions, greaterThanOrEqualTo(5));
      expect(balanced.selectedDeepRatio, lessThanOrEqualTo(0.25));
      expect(balanced.selectedDeepCount, 0);
    });

    test('budget pressure fixture reports cap suppressions', () async {
      final result = await _runner(_FakeLocalEvalService()).run(
        const LocalReviewPgnFixtureComparisonRequest(
          fixtures: [LocalReviewPgnIntegrationFixtures.budgetPressure],
          profileRuns: LocalReviewPgnFixtureProfileMatrix.planOnlyRuns,
        ),
      );
      final balanced = _entry(
        result,
        'budget-pressure-pgn',
        LocalReviewIntegrationBudgetPresetId.balancedDefault,
      );

      expect(
        balanced.pureCandidateCount,
        greaterThan(balanced.selectedDeepCount),
      );
      expect(balanced.budgetPressure.hasPressure, isTrue);
      expect(
        balanced.suppressionCounts[DeepCandidateReasonCode.budgetSuppressed],
        greaterThan(0),
      );
    });

    test(
      'invalid fixture does not crash and returns rejected entries',
      () async {
        final result = await _runner(_FakeLocalEvalService()).run(
          const LocalReviewPgnFixtureComparisonRequest(
            fixtures: [LocalReviewPgnIntegrationFixtures.invalidSafety],
            profileRuns: LocalReviewPgnFixtureProfileMatrix.planOnlyRuns,
          ),
        );

        expect(
          result.status,
          LocalReviewPgnFixtureComparisonStatus.completedWithWarnings,
        );
        expect(result.entries, isNotEmpty);
        expect(
          result.entries.every(
            (entry) => entry.status == LocalReviewIntegrationStatus.rejected,
          ),
          isTrue,
        );
        expect(
          result.entries.every((entry) => entry.totalEngineCalls == 0),
          isTrue,
        );
      },
    );

    test('ecoSafe and lowPower select zero deep candidates', () async {
      final result = await _runner(_FakeLocalEvalService()).run(
        const LocalReviewPgnFixtureComparisonRequest(
          fixtures: [LocalReviewPgnIntegrationFixtures.tacticalMiddlegame],
          profileRuns: LocalReviewPgnFixtureProfileMatrix.planOnlyRuns,
        ),
      );
      final eco = _entry(
        result,
        'tactical-middlegame-pgn',
        LocalReviewIntegrationBudgetPresetId.ecoSafe,
      );
      final lowPower = _entry(
        result,
        'tactical-middlegame-pgn',
        LocalReviewIntegrationBudgetPresetId.balancedDefault,
        lowPower: true,
      );

      expect(eco.selectedDeepCount, 0);
      expect(lowPower.selectedDeepCount, 0);
    });

    test('performance is finite and may select at least balanced', () async {
      final result = await _runner(_FakeLocalEvalService()).run(
        const LocalReviewPgnFixtureComparisonRequest(
          fixtures: [LocalReviewPgnIntegrationFixtures.budgetPressure],
          profileRuns: LocalReviewPgnFixtureProfileMatrix.planOnlyRuns,
        ),
      );
      final balanced = _entry(
        result,
        'budget-pressure-pgn',
        LocalReviewIntegrationBudgetPresetId.balancedDefault,
      );
      final performance = _entry(
        result,
        'budget-pressure-pgn',
        LocalReviewIntegrationBudgetPresetId.performanceMeasured,
      );
      final owner = _entry(
        result,
        'budget-pressure-pgn',
        LocalReviewIntegrationBudgetPresetId.ownerStrongLocal,
      );

      expect(
        performance.selectedDeepCount,
        greaterThanOrEqualTo(balanced.selectedDeepCount),
      );
      expect(
        performance.selectedDeepCount,
        lessThan(performance.mappedPositions),
      );
      expect(owner.selectedDeepCount, lessThan(owner.mappedPositions));
    });
  });

  group('LocalReviewPgnFixtureProfileRunner execution modes', () {
    test('plan-only comparison performs no engine calls', () async {
      final eval = _FakeLocalEvalService();

      final result = await _runner(eval).run(
        const LocalReviewPgnFixtureComparisonRequest(
          fixtures: [LocalReviewPgnIntegrationFixtures.tacticalMiddlegame],
          profileRuns: LocalReviewPgnFixtureProfileMatrix.planOnlyRuns,
        ),
      );

      expect(result.entries, isNotEmpty);
      expect(
        result.entries.every((entry) => entry.totalEngineCalls == 0),
        isTrue,
      );
      expect(eval.calls, isEmpty);
    });

    test('fast-then-plan comparison does not execute selected deep', () async {
      final eval = _FakeLocalEvalService();

      final result = await _runner(eval).run(
        const LocalReviewPgnFixtureComparisonRequest(
          fixtures: [LocalReviewPgnIntegrationFixtures.tacticalMiddlegame],
          profileRuns: [
            LocalReviewPgnFixtureProfileRun(
              budgetPreset: LocalReviewIntegrationBudgetPreset.balancedDefault,
              mode: LocalReviewIntegrationMode.fastThenPlanDeep,
            ),
          ],
        ),
      );
      final entry = result.entries.single;

      expect(entry.fastEngineCalls, greaterThan(0));
      expect(entry.deepEngineCalls, 0);
      expect(entry.executedDeepCount, 0);
      expect(eval.calls, hasLength(entry.fastEngineCalls));
    });

    test(
      'selected-deep fake execution executes only selected candidates',
      () async {
        final eval = _FakeLocalEvalService();

        final result = await _runner(eval).run(
          const LocalReviewPgnFixtureComparisonRequest(
            fixtures: [LocalReviewPgnIntegrationFixtures.tacticalMiddlegame],
            profileRuns: [
              LocalReviewPgnFixtureProfileRun(
                budgetPreset:
                    LocalReviewIntegrationBudgetPreset.balancedDefault,
                mode: LocalReviewIntegrationMode.fastThenExecuteSelectedDeep,
                maxDeepCandidates: 1,
              ),
            ],
          ),
        );
        final entry = result.entries.single;

        expect(entry.fastEngineCalls, greaterThan(0));
        expect(entry.deepEngineCalls, 2);
        expect(entry.executedDeepCount, 1);
        expect(eval.calls, hasLength(entry.totalEngineCalls));
        expect(eval.maxConcurrentCalls, 1);
      },
    );

    test('budget pressure and failure warnings propagate', () async {
      final eval = _FakeLocalEvalService(
        plans: [_FakeEvalPlan.error(EvalError.serverError)],
      );

      final result = await _runner(eval).run(
        const LocalReviewPgnFixtureComparisonRequest(
          failFast: true,
          fixtures: [LocalReviewPgnIntegrationFixtures.tacticalMiddlegame],
          profileRuns: [
            LocalReviewPgnFixtureProfileRun(
              budgetPreset: LocalReviewIntegrationBudgetPreset.balancedDefault,
              mode: LocalReviewIntegrationMode.fastThenPlanDeep,
            ),
          ],
        ),
      );
      final entry = result.entries.single;

      expect(entry.status, LocalReviewIntegrationStatus.failed);
      expect(entry.failures, isNotEmpty);
      expect(result.status, LocalReviewPgnFixtureComparisonStatus.failed);
    });
  });

  group('LocalReviewPgnFixtureProfileRunner reports and guardrails', () {
    test('default report renderer is deterministic', () async {
      final result = await _runner(_FakeLocalEvalService()).run(
        const LocalReviewPgnFixtureComparisonRequest(
          fixtures: [
            LocalReviewPgnIntegrationFixtures.quietOpening,
            LocalReviewPgnIntegrationFixtures.tacticalMiddlegame,
          ],
          profileRuns: LocalReviewPgnFixtureProfileMatrix.planOnlyRuns,
        ),
      );

      expect(result.renderMarkdownReport(), result.renderMarkdownReport());
      expect(
        result.renderMarkdownReport(),
        contains('Local Review PGN Fixture Profiles'),
      );
      expect(result.renderMarkdownReport(), contains('quiet-opening-pgn'));
    });

    test('report contains no raw engine spam or PV dumps', () async {
      final report = (await _runner(_FakeLocalEvalService()).run(
        const LocalReviewPgnFixtureComparisonRequest(
          fixtures: [LocalReviewPgnIntegrationFixtures.tacticalMiddlegame],
          profileRuns: LocalReviewPgnFixtureProfileMatrix.planOnlyRuns,
        ),
      )).renderMarkdownReport();

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains('e2e4 e7e5')));
      expect(report, isNot(contains('pvMoves')));
    });

    test('report contains no final labels or official metric text', () async {
      final report = (await _runner(_FakeLocalEvalService()).run(
        const LocalReviewPgnFixtureComparisonRequest(
          fixtures: [LocalReviewPgnIntegrationFixtures.tacticalMiddlegame],
          profileRuns: LocalReviewPgnFixtureProfileMatrix.planOnlyRuns,
        ),
      )).renderMarkdownReport();

      expect(report, isNot(contains('Brilliant')));
      expect(report, isNot(contains('Great')));
      expect(report, isNot(contains('Miss')));
      expect(report, isNot(contains('ACPL')));
      expect(report, isNot(contains('accuracy')));
    });

    test('source avoids forbidden layers and project markers', () {
      final source = File(
        'lib/features/pgn_review/application/local_review_pgn_fixture_profiles.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      expect(imports, contains('local_review_integration_experiment.dart'));
      expect(imports, isNot(contains('local_eval_service.dart')));
      expect(imports, isNot(contains('stockfish')));
      expect(imports, isNot(contains('ffi')));
      expect(imports, isNot(contains('native')));
      expect(imports, isNot(contains('package:flutter/')));
      expect(imports, isNot(contains('Widget')));
      expect(imports, isNot(contains('preflight')));
      expect(imports, isNot(contains('backend')));
      expect(imports, isNot(contains('server')));
      expect(imports, isNot(contains('database')));
      expect(source, isNot(contains('MoveQuality')));
      expect(source, isNot(contains('Brilliant')));
      expect(source, isNot(contains('Great')));
      expect(source, isNot(contains('Miss')));
      expect(source, isNot(contains('ACPL')));
      expect(source, isNot(contains('accuracy')));
      expect(source, isNot(contains('Chesskit')));
      expect(source, isNot(contains('DroidFish')));
      expect(source, isNot(contains('StockfishForFlutter')));
      expect(source, isNot(contains('python-chess')));
    });
  });
}

LocalReviewProfileComparisonResult _entry(
  LocalReviewPgnFixtureComparisonResult result,
  String fixtureId,
  LocalReviewIntegrationBudgetPresetId presetId, {
  bool lowPower = false,
}) {
  return result.entries.firstWhere(
    (entry) =>
        entry.fixtureId == fixtureId &&
        entry.presetId == presetId &&
        entry.mode == LocalReviewIntegrationMode.planOnly &&
        entry.lowPower == lowPower,
  );
}

LocalReviewPgnFixtureProfileRunner _runner(_FakeLocalEvalService eval) {
  return LocalReviewPgnFixtureProfileRunner(
    integration: LocalReviewIntegrationExperiment(
      deepGating: GameLevelDeepGatingExperiment(
        orchestration: LocalReviewOrchestrationExperiment(
          measuredReview: MeasuredLocalReviewPrototype(
            executor: LocalSmartAnalysisExecutor(eval: eval),
          ),
        ),
      ),
    ),
  );
}

class _FakeLocalEvalService extends LocalEvalService {
  _FakeLocalEvalService({List<_FakeEvalPlan> plans = const []})
    : _plans = List<_FakeEvalPlan>.from(plans),
      super(engine: _NoopChessEngine());

  final List<_FakeEvalPlan> _plans;
  final calls = <_EvalCall>[];
  var _activeCalls = 0;
  var _sequence = 0;
  var maxConcurrentCalls = 0;

  @override
  Future<(EvalSnapshot?, EvalError?)> evaluate(
    String fen, {
    int? depth,
    Duration? movetime,
    Duration? timeout,
    int multiPv = 1,
  }) async {
    _activeCalls++;
    if (_activeCalls > maxConcurrentCalls) {
      maxConcurrentCalls = _activeCalls;
    }
    final call = _EvalCall(
      sequence: ++_sequence,
      fen: fen,
      depth: depth ?? 0,
      movetime: movetime ?? Duration.zero,
      timeout: timeout,
      multiPv: multiPv,
    );
    calls.add(call);

    try {
      final plan = _plans.isNotEmpty
          ? _plans.removeAt(0)
          : _FakeEvalPlan.dynamicSuccess();
      if (plan.delay > Duration.zero) {
        await Future<void>.delayed(plan.delay);
      }
      if (plan.dynamicSuccess) {
        return (
          _snapshot(
            depth: call.depth,
            bestMove: 'e2e4',
            pv: const ['e2e4', 'e7e5'],
            multiPv: call.multiPv,
          ),
          null,
        );
      }
      return (null, plan.error);
    } finally {
      _activeCalls--;
    }
  }
}

class _FakeEvalPlan {
  const _FakeEvalPlan._({
    this.error,
    this.dynamicSuccess = false,
    this.delay = Duration.zero,
  });

  factory _FakeEvalPlan.dynamicSuccess({Duration delay = Duration.zero}) =>
      _FakeEvalPlan._(dynamicSuccess: true, delay: delay);

  factory _FakeEvalPlan.error(EvalError error) => _FakeEvalPlan._(error: error);

  final EvalError? error;
  final bool dynamicSuccess;
  final Duration delay;
}

class _EvalCall {
  const _EvalCall({
    required this.sequence,
    required this.fen,
    required this.depth,
    required this.movetime,
    required this.timeout,
    required this.multiPv,
  });

  final int sequence;
  final String fen;
  final int depth;
  final Duration movetime;
  final Duration? timeout;
  final int multiPv;
}

EvalSnapshot _snapshot({
  int depth = 12,
  String? bestMove = 'e2e4',
  List<String> pv = const ['e2e4', 'e7e5'],
  int multiPv = 1,
  int? scoreCp = 20,
  int? mateIn,
}) {
  return EvalSnapshot(
    scoreCp: scoreCp,
    mateIn: mateIn,
    depth: depth,
    bestMoveUci: bestMove,
    pvMoves: pv,
    engineLines: [
      for (var rank = 1; rank <= multiPv; rank++)
        EngineLine(
          rank: rank,
          moveUci: rank == 1 ? bestMove : 'd2d4',
          scoreCp: scoreCp == null ? null : scoreCp - (rank - 1) * 10,
          mateIn: mateIn,
          depth: depth,
          whiteWinPercent: 50,
          pvMoves: pv.isEmpty
              ? const <String>[]
              : rank == 1
              ? pv
              : const ['d2d4', 'd7d5'],
        ),
    ],
  );
}

class _NoopChessEngine implements ChessEngine {
  @override
  Stream<EngineEvent> get events => const Stream<EngineEvent>.empty();

  @override
  String get bridgeVersion => 'fake-local-eval';

  @override
  bool get isRunning => true;

  @override
  Future<void> start() async {}

  @override
  void send(UciCommand command) {}

  @override
  void sendRaw(String line) {}

  @override
  void stop() {}

  @override
  Future<void> dispose() async {}
}

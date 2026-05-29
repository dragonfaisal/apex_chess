import 'dart:async';
import 'dart:io';

import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/infrastructure/engine/chess_engine.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_command.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_event.dart';
import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_integration_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_orchestration_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_pgn_fixture_device_smoke.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_pgn_fixture_profiles.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_executor.dart';
import 'package:apex_chess/features/pgn_review/application/measured_local_review_prototype.dart';
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalReviewPgnFixtureDeviceSmoke request', () {
    test('default request is conservative', () {
      const request = LocalReviewPgnFixtureDeviceSmokeRequest();

      expect(request.fixtureIds, hasLength(2));
      expect(request.includePerformancePreset, isFalse);
      expect(request.maxFixtures, 2);
      expect(request.maxPositionsPerFixture, 14);
      expect(request.maxTotalEngineCalls, lessThanOrEqualTo(32));
      expect(
        request.mode,
        LocalReviewIntegrationMode.fastThenExecuteSelectedDeep,
      );
    });

    test('missing opt-in flag returns disabled skip path', () {
      expect(isLocalReviewPgnFixtureDeviceSmokeEnabled(), isFalse);

      final result = LocalReviewPgnFixtureDeviceSmokeResult.skipped(
        platform: 'windows',
      );

      expect(result.status, LocalReviewPgnFixtureDeviceSmokeStatus.skipped);
      expect(result.totalEngineCalls, 0);
      expect(result.renderMarkdownReport(), contains('skipped'));
    });

    test('balancedDefault-only request omits performanceMeasured', () {
      const request = LocalReviewPgnFixtureDeviceSmokeRequest();

      expect(request.profileRuns(), hasLength(1));
      expect(
        request.profileRuns().single.budgetPreset.id,
        LocalReviewIntegrationBudgetPresetId.balancedDefault,
      );
    });

    test('explicit performance flag includes performanceMeasured', () {
      const request = LocalReviewPgnFixtureDeviceSmokeRequest(
        includePerformancePreset: true,
      );

      expect(
        request.profileRuns().map((run) => run.budgetPreset.id),
        contains(LocalReviewIntegrationBudgetPresetId.performanceMeasured),
      );
    });
  });

  group('LocalReviewPgnFixtureDeviceSmoke aggregation', () {
    test('result computes selected-deep ratio', () {
      final result = _manualResult(
        summaries: [_summary(mapped: 4, selected: 1)],
      );

      expect(result.selectedDeepRatio, 0.25);
      expect(result.selectedDeepCount, 1);
    });

    test('result aggregates fast, deep, and total engine calls', () {
      final result = _manualResult(
        summaries: [
          _summary(fast: 2, deep: 1, total: 3),
          _summary(fast: 4, deep: 2, total: 6),
        ],
      );

      expect(result.fastEngineCalls, 6);
      expect(result.deepEngineCalls, 3);
      expect(result.totalEngineCalls, 9);
    });

    test('timeout and failure counts propagate', () {
      final result = _manualResult(
        summaries: [
          _summary(
            warnings: const ['timeout during fixture run'],
            failures: const ['engine failure'],
          ),
        ],
        warnings: const ['budget warning'],
        failures: const ['smoke failure'],
      );

      expect(result.timeoutCount, 1);
      expect(result.warningCount, 2);
      expect(result.failureCount, 2);
    });
  });

  group('LocalReviewPgnFixtureDeviceSmoke collector behavior', () {
    test('balanced default executes selected deep on fake stack', () async {
      final eval = _FakeLocalEvalService();
      final result = await _collector(eval).run(
        const LocalReviewPgnFixtureDeviceSmokeRequest(
          fixtureIds: ['tactical-middlegame-pgn'],
          maxFixtures: 1,
          maxTotalEngineCalls: 32,
        ),
        engineIdentityProvider: () => 'apex-local-engine',
      );

      expect(result.fixtureRunCount, 1);
      expect(result.presetRunCount, 1);
      expect(result.mappedPositions, greaterThan(0));
      expect(result.executedDeepCount, greaterThan(0));
      expect(result.fastEngineCalls, greaterThan(0));
      expect(result.deepEngineCalls, greaterThan(0));
      expect(eval.maxConcurrentCalls, 1);
    });

    test('budget cap violation is reported as failure', () async {
      final result = await _collector(_FakeLocalEvalService()).run(
        const LocalReviewPgnFixtureDeviceSmokeRequest(
          fixtureIds: ['quiet-opening-pgn', 'tactical-middlegame-pgn'],
          maxFixtures: 2,
          maxTotalEngineCalls: 4,
        ),
        engineIdentityProvider: () => 'apex-local-engine',
      );

      expect(result.status, LocalReviewPgnFixtureDeviceSmokeStatus.failed);
      expect(result.failures.join('\n'), contains('engine call cap'));
    });

    test('selected every mapped position is flagged unsafe', () async {
      final result =
          await _collector(
            _FakeLocalEvalService(),
            fixtures: const [_allCandidateFixture],
          ).run(
            const LocalReviewPgnFixtureDeviceSmokeRequest(
              fixtureIds: ['all-candidate-pgn'],
              maxFixtures: 1,
              maxPositionsPerFixture: 2,
              maxTotalEngineCalls: 16,
            ),
            engineIdentityProvider: () => 'apex-local-engine',
          );

      expect(result.status, LocalReviewPgnFixtureDeviceSmokeStatus.failed);
      expect(result.failures.join('\n'), contains('selected every'));
    });

    test('zero selected deep is a warning, not a crash', () async {
      final result = await _collector(_FakeLocalEvalService()).run(
        const LocalReviewPgnFixtureDeviceSmokeRequest(
          fixtureIds: ['quiet-opening-pgn'],
          maxFixtures: 1,
          maxTotalEngineCalls: 16,
        ),
        engineIdentityProvider: () => 'apex-local-engine',
      );

      expect(
        result.status,
        LocalReviewPgnFixtureDeviceSmokeStatus.completedWithWarnings,
      );
      expect(result.executedDeepCount, 0);
      expect(result.warnings.join('\n'), contains('no selected-deep'));
    });

    test('stub identity blocks smoke approval', () async {
      final result = await _collector(_FakeLocalEvalService()).run(
        const LocalReviewPgnFixtureDeviceSmokeRequest(
          fixtureIds: ['tactical-middlegame-pgn'],
          maxFixtures: 1,
          maxTotalEngineCalls: 32,
        ),
        engineIdentityProvider: () => 'ApexChess-Stub',
      );

      expect(result.stubIdentityDetected, isTrue);
      expect(result.status, LocalReviewPgnFixtureDeviceSmokeStatus.failed);
      expect(result.failures.join('\n'), contains('stub identity'));
    });
  });

  group('LocalReviewPgnFixtureDeviceSmoke reports and source guardrails', () {
    test('report renderer is deterministic', () {
      final result = _manualResult(
        summaries: [
          _summary(
            mapped: 8,
            candidates: 2,
            selected: 1,
            executed: 1,
            fast: 8,
            deep: 2,
            total: 10,
          ),
        ],
      );

      expect(result.renderMarkdownReport(), result.renderMarkdownReport());
      expect(
        result.renderMarkdownReport(),
        contains('Local Review PGN Fixture Device Smoke'),
      );
      expect(result.renderJson(), result.renderJson());
    });

    test('report contains no raw engine traffic or long line dumps', () {
      final report = _manualResult(
        summaries: [_summary(mapped: 4, candidates: 1, selected: 1)],
      ).renderMarkdownReport();

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains('e2e4 e7e5')));
      expect(report, isNot(contains('pvMoves')));
    });

    test('report contains no final labels or official metric text', () {
      final report = _manualResult(
        summaries: [_summary()],
      ).renderMarkdownReport();

      expect(report, isNot(contains('Brilliant')));
      expect(report, isNot(contains('Great')));
      expect(report, isNot(contains('Miss')));
      expect(report, isNot(contains('ACPL')));
      expect(report, isNot(contains('accuracy')));
    });

    test('integration test source is opt-in guarded', () {
      final source = File(
        'integration_test/local_review_pgn_fixture_device_smoke_test.dart',
      ).readAsStringSync();

      expect(source, contains(localReviewPgnFixtureDeviceSmokeFlag));
      expect(source, contains('markTestSkipped'));
      expect(source, contains('Platform.isAndroid'));
    });

    test('model source avoids forbidden layers and project markers', () {
      final source = File(
        'lib/features/pgn_review/application/local_review_pgn_fixture_device_smoke.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      expect(imports, contains('local_review_pgn_fixture_profiles.dart'));
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

    test('integration source avoids product UI and storage imports', () {
      final source = File(
        'integration_test/local_review_pgn_fixture_device_smoke_test.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      expect(imports, contains('integration_test'));
      expect(imports, contains('flutter_test'));
      expect(imports, isNot(contains('package:flutter/material')));
      expect(imports, isNot(contains('package:flutter/widgets')));
      expect(imports, isNot(contains('preflight')));
      expect(imports, isNot(contains('backend')));
      expect(imports, isNot(contains('server')));
      expect(imports, isNot(contains('database')));
      expect(imports, isNot(contains('shared_preferences')));
      expect(imports, isNot(contains('hive')));
    });
  });
}

const _allCandidateFixture = LocalReviewPgnIntegrationFixture(
  id: 'all-candidate-pgn',
  title: 'All Candidate PGN',
  category: LocalReviewPgnFixtureCategory.budgetPressure,
  pgn: '1. e4 e5',
  positionHints: [
    LocalReviewPgnFixturePositionHint(plyIndex: 0, candidateEvalSpreadCp: 300),
    LocalReviewPgnFixturePositionHint(plyIndex: 1, candidateEvalSpreadCp: 300),
  ],
  expected: LocalReviewPgnFixtureExpectedBehavior(
    minMappedPositions: 2,
    maxSelectedDeepRatioBalanced: 1,
  ),
);

LocalReviewPgnFixtureDeviceSmokeCollector _collector(
  _FakeLocalEvalService eval, {
  List<LocalReviewPgnIntegrationFixture> fixtures =
      LocalReviewPgnIntegrationFixtures.defaults,
}) {
  return LocalReviewPgnFixtureDeviceSmokeCollector(
    fixtures: fixtures,
    runner: LocalReviewPgnFixtureProfileRunner(
      integration: LocalReviewIntegrationExperiment(
        deepGating: GameLevelDeepGatingExperiment(
          orchestration: LocalReviewOrchestrationExperiment(
            measuredReview: MeasuredLocalReviewPrototype(
              executor: LocalSmartAnalysisExecutor(eval: eval),
            ),
          ),
        ),
      ),
    ),
  );
}

LocalReviewPgnFixtureDeviceSmokeResult _manualResult({
  required List<LocalReviewPgnFixtureDeviceSmokeSummary> summaries,
  List<String> warnings = const <String>[],
  List<String> failures = const <String>[],
}) {
  return LocalReviewPgnFixtureDeviceSmokeResult(
    status: failures.isEmpty
        ? LocalReviewPgnFixtureDeviceSmokeStatus.completed
        : LocalReviewPgnFixtureDeviceSmokeStatus.failed,
    platform: 'android',
    deviceLabel: 'test-device',
    abi: 'arm64-v8a',
    engineIdentity: 'apex-local-engine',
    stubIdentityDetected: false,
    fixtureRunCount: summaries.length,
    presetRunCount: 1,
    summaries: summaries,
    warnings: warnings,
    failures: failures,
    recommendation: 'test recommendation',
  );
}

LocalReviewPgnFixtureDeviceSmokeSummary _summary({
  int mapped = 2,
  int candidates = 1,
  int selected = 1,
  int executed = 1,
  int fast = 1,
  int deep = 1,
  int total = 2,
  int elapsed = 10,
  List<String> warnings = const <String>[],
  List<String> failures = const <String>[],
}) {
  return LocalReviewPgnFixtureDeviceSmokeSummary(
    fixtureId: 'fixture',
    category: LocalReviewPgnFixtureCategory.tacticalMiddlegame,
    presetId: LocalReviewIntegrationBudgetPresetId.balancedDefault,
    mode: LocalReviewIntegrationMode.fastThenExecuteSelectedDeep,
    mappedPositions: mapped,
    candidates: candidates,
    selectedDeep: selected,
    executedDeep: executed,
    selectedRatio: mapped == 0 ? 0 : selected / mapped,
    fastCalls: fast,
    deepCalls: deep,
    totalCalls: total,
    elapsedMs: elapsed,
    budgetPressure: LocalReviewIntegrationBudgetPressureSummary(
      candidatesSuppressedByBudget: 0,
      budgetViolationCount: 0,
      warningCount: warnings.length,
      timeoutCount: warnings.any((warning) => warning.contains('timeout'))
          ? 1
          : 0,
      maxCandidatePriority: 100,
    ),
    warnings: warnings,
    failures: failures,
    topReasonCounts: const <DeepCandidateReasonCode, int>{
      DeepCandidateReasonCode.candidateEvalSpread: 1,
    },
    suppressionCounts: const <DeepCandidateReasonCode, int>{},
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
      return (null, EvalError.serverError);
    } finally {
      _activeCalls--;
    }
  }
}

class _FakeEvalPlan {
  const _FakeEvalPlan._({
    this.dynamicSuccess = false,
    this.delay = Duration.zero,
  });

  factory _FakeEvalPlan.dynamicSuccess({Duration delay = Duration.zero}) =>
      _FakeEvalPlan._(dynamicSuccess: true, delay: delay);

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

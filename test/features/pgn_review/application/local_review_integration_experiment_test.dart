import 'dart:async';
import 'dart:io';

import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/infrastructure/engine/chess_engine.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_command.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_event.dart';
import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_integration_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_orchestration_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_executor.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';
import 'package:apex_chess/features/pgn_review/application/measured_local_review_prototype.dart';
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';
import 'package:flutter_test/flutter_test.dart';

const _fen =
    'rn1qkbnr/ppp2ppp/3b4/3pp3/4P3/2NP1N2/PPP2PPP/R1BQKB1R w KQkq - 2 5';

void main() {
  group('LocalReviewIntegrationExperiment model and mapping', () {
    test(
      'empty source returns safe completed result with zero calls',
      () async {
        final eval = _FakeLocalEvalService();
        final result = await _experiment(eval).run(
          const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
            positions: [],
          ),
        );

        expect(result.status, LocalReviewIntegrationStatus.completed);
        expect(result.sourcePositionCount, 0);
        expect(result.mappedPositionCount, 0);
        expect(result.totalEngineCalls, 0);
        expect(result.selectedDeepCount, 0);
        expect(eval.calls, isEmpty);
      },
    );

    test('scheduler-ready input runs through deep-gating plan', () async {
      final eval = _FakeLocalEvalService();
      final result = await _experiment(eval).run(
        const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
          requestId: 'ready-plan',
          positions: [
            LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 260),
          ],
        ),
      );

      expect(result.status, LocalReviewIntegrationStatus.completed);
      expect(result.purePlanCandidateCount, 1);
      expect(result.selectedDeepCount, 1);
      expect(result.totalEngineCalls, 0);
      expect(result.debugSummary, contains('ready-plan'));
      expect(eval.calls, isEmpty);
    });

    test('parsed position source maps safely when supplied', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const LocalReviewIntegrationExperimentRequest.fromParsedPositions(
          positions: [
            LocalReviewOrchestrationPosition(
              fen: ' $_fen ',
              reference: 'move-7',
              plyIndex: 12,
              moveNumber: 7,
              candidateEvalSpreadCp: 240,
              isCapture: true,
              tags: ['fixture'],
            ),
          ],
        ),
      );

      expect(result.sourcePositionCount, 1);
      expect(result.mappedPositionCount, 1);
      expect(result.purePlanCandidateCount, 1);
      expect(result.selectedDeepCount, 1);
      expect(result.mappingWarnings, isEmpty);
    });

    test('maxPositions limits mapped positions and reports warning', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
          maxPositions: 1,
          positions: [
            LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 220),
            LocalAnalysisPositionInput(
              fen: _fen,
              materialDeltaAfterMoveCp: -280,
            ),
          ],
        ),
      );

      expect(result.sourcePositionCount, 2);
      expect(result.mappedPositionCount, 1);
      expect(result.status, LocalReviewIntegrationStatus.completedWithWarnings);
      expect(result.mappingWarnings.single, contains('maxPositions'));
    });
  });

  group('LocalReviewIntegrationExperiment budget presets', () {
    test('ecoSafe preset selects no deep work', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
          budgetPreset: LocalReviewIntegrationBudgetPreset.ecoSafe,
          positions: [
            LocalAnalysisPositionInput(
              fen: _fen,
              materialDeltaAfterMoveCp: -500,
            ),
          ],
        ),
      );

      expect(result.profile.id, LocalSchedulerProfileId.eco);
      expect(result.selectedDeepCount, 0);
      expect(result.purePlanCandidateCount, 0);
    });

    test('balancedDefault selects a small finite subset', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
          budgetPreset: LocalReviewIntegrationBudgetPreset.balancedDefault,
          positions: _candidateHeavyPositions,
        ),
      );

      expect(result.purePlanCandidateCount, greaterThan(3));
      expect(result.selectedDeepCount, 3);
      expect(result.selectedDeepCount, lessThan(result.mappedPositionCount));
      expect(result.selectedDeepRatio, lessThan(1));
    });

    test(
      'ownerStrongLocal can select more than balanced but not every move',
      () async {
        final integration = _experiment(_FakeLocalEvalService());
        final balanced = await integration.run(
          const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
            budgetPreset: LocalReviewIntegrationBudgetPreset.balancedDefault,
            positions: _candidateHeavyPositions,
          ),
        );
        final owner = await integration.run(
          const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
            budgetPreset: LocalReviewIntegrationBudgetPreset.ownerStrongLocal,
            positions: _candidateHeavyPositions,
          ),
        );

        expect(
          owner.selectedDeepCount,
          greaterThan(balanced.selectedDeepCount),
        );
        expect(owner.selectedDeepCount, lessThan(owner.mappedPositionCount));
        expect(owner.profile.id, LocalSchedulerProfileId.owner);
      },
    );

    test('lowPower suppresses deep execution', () async {
      final eval = _FakeLocalEvalService();
      final result = await _experiment(eval).run(
        const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
          mode: LocalReviewIntegrationMode.fastThenExecuteSelectedDeep,
          lowPower: true,
          positions: [
            LocalAnalysisPositionInput(
              fen: _fen,
              materialDeltaAfterMoveCp: -500,
            ),
          ],
        ),
      );

      expect(result.fastEngineCalls, 1);
      expect(result.deepEngineCalls, 0);
      expect(result.selectedDeepCount, 0);
      expect(result.executedDeepCount, 0);
    });
  });

  group('LocalReviewIntegrationExperiment plan and execution modes', () {
    test('planOnly mode performs no engine calls', () async {
      final eval = _FakeLocalEvalService();

      await _experiment(eval).run(
        const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
          mode: LocalReviewIntegrationMode.planOnly,
          positions: [
            LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 300),
          ],
        ),
      );

      expect(eval.calls, isEmpty);
    });

    test(
      'fastThenPlanDeep plans deep without executing selected deep',
      () async {
        final eval = _FakeLocalEvalService();
        final result = await _experiment(eval).run(
          const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
            mode: LocalReviewIntegrationMode.fastThenPlanDeep,
            positions: [
              LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 300),
              LocalAnalysisPositionInput(fen: _fen),
            ],
          ),
        );

        expect(result.fastEngineCalls, 2);
        expect(result.deepEngineCalls, 0);
        expect(result.selectedDeepCount, 1);
        expect(result.executedDeepCount, 0);
        expect(eval.calls, hasLength(2));
      },
    );

    test(
      'fastThenExecuteSelectedDeep executes only selected candidates',
      () async {
        final eval = _FakeLocalEvalService();
        final result = await _experiment(eval).run(
          const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
            mode: LocalReviewIntegrationMode.fastThenExecuteSelectedDeep,
            maxDeepCandidates: 1,
            positions: [
              LocalAnalysisPositionInput(fen: _fen),
              LocalAnalysisPositionInput(
                fen: _fen,
                materialDeltaAfterMoveCp: -320,
                isCapture: true,
              ),
            ],
          ),
        );

        expect(result.fastEngineCalls, 2);
        expect(result.deepEngineCalls, 2);
        expect(result.executedDeepCount, 1);
        expect(result.totalEngineCalls, 4);
        expect(eval.maxConcurrentCalls, 1);
        expect(eval.calls.last.multiPv, 3);
      },
    );

    test('maxTotalEngineCalls is honored', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
          mode: LocalReviewIntegrationMode.fastThenExecuteSelectedDeep,
          maxTotalEngineCalls: 1,
          positions: [
            LocalAnalysisPositionInput(
              fen: _fen,
              materialDeltaAfterMoveCp: -320,
            ),
          ],
        ),
      );

      expect(result.totalEngineCalls, lessThanOrEqualTo(1));
      expect(result.selectedDeepCount, 0);
      expect(result.budgetPressure.hasPressure, isTrue);
    });

    test('maxDeepCandidates and maxDeepEngineCalls are honored', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
          maxDeepCandidates: 1,
          maxDeepEngineCalls: 2,
          positions: [
            LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 300),
            LocalAnalysisPositionInput(
              fen: _fen,
              materialDeltaAfterMoveCp: -320,
            ),
          ],
        ),
      );

      expect(result.purePlanCandidateCount, 2);
      expect(result.selectedDeepCount, 1);
      expect(result.budgetPressure.candidatesSuppressedByBudget, 1);
    });

    test('elapsed budget pressure is reported safely', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
          maxTotalElapsedBudgetMs: 0,
          positions: [
            LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 300),
          ],
        ),
      );

      expect(result.status, LocalReviewIntegrationStatus.completedWithWarnings);
      expect(result.selectedDeepCount, 0);
      expect(result.warnings.join('\n'), contains('elapsed budget exhausted'));
    });

    test('warning counts propagate from deep-gating result', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
          providedFastEvidence: [
            GameLevelProvidedFastEvidence(positionIndex: 0, scoreCp: 20),
          ],
          positions: [LocalAnalysisPositionInput(fen: _fen)],
        ),
      );

      expect(result.status, LocalReviewIntegrationStatus.completedWithWarnings);
      expect(result.warnings.join('\n'), contains('no fast-pass PV'));
      expect(result.budgetPressure.warningCount, greaterThan(0));
    });

    test('execution failure returns safe failure result', () async {
      final eval = _FakeLocalEvalService(
        plans: [_FakeEvalPlan.error(EvalError.serverError)],
      );
      final result = await _experiment(eval).run(
        const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
          mode: LocalReviewIntegrationMode.fastThenPlanDeep,
          failFast: true,
          positions: [
            LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 300),
          ],
        ),
      );

      expect(result.status, LocalReviewIntegrationStatus.failed);
      expect(result.failures, isNotEmpty);
      expect(result.deepEngineCalls, 0);
    });
  });

  group('LocalReviewIntegrationExperiment reports and guardrails', () {
    test('developer report is deterministic', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
          requestId: 'integration-report',
          positions: [
            LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 300),
          ],
        ),
      );

      expect(result.renderDeveloperReport(), result.renderDeveloperReport());
      expect(
        result.renderDeveloperReport(),
        contains('Local Review Integration'),
      );
      expect(
        result.renderDeveloperReport(),
        contains('pure plan candidates: 1'),
      );
      expect(result.debugSummary, contains('integration-report'));
    });

    test('report contains no raw engine spam or PV dumps', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
          positions: [
            LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 300),
          ],
        ),
      );
      final report = result.renderDeveloperReport();

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains('e2e4 e7e5')));
      expect(report, isNot(contains('pvMoves')));
    });

    test('report contains no final labels or official metric text', () async {
      final report = (await _experiment(_FakeLocalEvalService()).run(
        const LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
          positions: [
            LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 300),
          ],
        ),
      )).renderDeveloperReport();

      expect(report, isNot(contains('Brilliant')));
      expect(report, isNot(contains('Great')));
      expect(report, isNot(contains('Miss')));
      expect(report, isNot(contains('ACPL')));
      expect(report, isNot(contains('accuracy')));
    });

    test('source avoids forbidden layers and project markers', () {
      final source = File(
        'lib/features/pgn_review/application/local_review_integration_experiment.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      expect(imports, contains('game_level_deep_gating_experiment.dart'));
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

const _candidateHeavyPositions = [
  LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 280),
  LocalAnalysisPositionInput(fen: _fen, materialDeltaAfterMoveCp: -330),
  LocalAnalysisPositionInput(
    fen: _fen,
    previousEvalCp: 240,
    provisionalEvalCp: -140,
  ),
  LocalAnalysisPositionInput(fen: _fen, givesCheck: true),
  LocalAnalysisPositionInput(
    fen: _fen,
    legalMoveCount: 42,
    candidateEvalSpreadCp: 180,
  ),
  LocalAnalysisPositionInput(fen: _fen, isCapture: true),
  LocalAnalysisPositionInput(fen: _fen),
  LocalAnalysisPositionInput(fen: _fen),
  LocalAnalysisPositionInput(fen: _fen),
  LocalAnalysisPositionInput(fen: _fen),
];

LocalReviewIntegrationExperiment _experiment(_FakeLocalEvalService eval) {
  return LocalReviewIntegrationExperiment(
    deepGating: GameLevelDeepGatingExperiment(
      orchestration: LocalReviewOrchestrationExperiment(
        measuredReview: MeasuredLocalReviewPrototype(
          executor: LocalSmartAnalysisExecutor(eval: eval),
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

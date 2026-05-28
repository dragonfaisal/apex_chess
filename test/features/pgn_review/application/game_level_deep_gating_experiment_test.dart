import 'dart:async';
import 'dart:io';

import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/infrastructure/engine/chess_engine.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_command.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_event.dart';
import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_orchestration_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_executor.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';
import 'package:apex_chess/features/pgn_review/application/measured_local_review_prototype.dart';
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';
import 'package:flutter_test/flutter_test.dart';

const _fen =
    'rn1qkbnr/ppp2ppp/3b4/3pp3/4P3/2NP1N2/PPP2PPP/R1BQKB1R w KQkq - 2 5';

void main() {
  group('GameLevelDeepGatingExperiment plan mode', () {
    test('empty input returns safe result with zero engine calls', () async {
      final eval = _FakeLocalEvalService();
      final experiment = _experiment(eval);

      final result = await experiment.run(
        const GameLevelDeepGatingExperimentRequest(positions: []),
      );

      expect(result.status, GameLevelDeepGatingStatus.completed);
      expect(result.totalEngineCalls, 0);
      expect(result.candidateCount, 0);
      expect(result.telemetry, GameLevelDeepGatingTelemetry.empty);
      expect(eval.calls, isEmpty);
    });

    test(
      'opening-known positions are suppressed from deep candidates',
      () async {
        final eval = _FakeLocalEvalService();
        final experiment = _experiment(eval);

        final result = await experiment.run(
          const GameLevelDeepGatingExperimentRequest(
            positions: [
              LocalAnalysisPositionInput(
                fen: _fen,
                isOpeningKnown: true,
                materialDeltaAfterMoveCp: -500,
              ),
            ],
          ),
        );

        expect(result.candidateCount, 0);
        expect(
          result.suppressions.single.reasonCode,
          DeepCandidateReasonCode.openingSuppressed,
        );
        expect(result.telemetry.skippedOpening, 1);
        expect(eval.calls, isEmpty);
      },
    );

    test('only-legal positions are suppressed from deep candidates', () async {
      final eval = _FakeLocalEvalService();
      final experiment = _experiment(eval);

      final result = await experiment.run(
        const GameLevelDeepGatingExperimentRequest(
          positions: [
            LocalAnalysisPositionInput(
              fen: _fen,
              isOnlyLegalMove: true,
              candidateEvalSpreadCp: 400,
            ),
          ],
        ),
      );

      expect(result.candidateCount, 0);
      expect(
        result.suppressions.single.reasonCode,
        DeepCandidateReasonCode.forcedSuppressed,
      );
      expect(result.telemetry.skippedForced, 1);
    });

    test('invalid FEN is suppressed before deep planning', () async {
      final eval = _FakeLocalEvalService();
      final experiment = _experiment(eval);

      final result = await experiment.run(
        const GameLevelDeepGatingExperimentRequest(
          positions: [
            LocalAnalysisPositionInput(
              fen: 'bad fen',
              materialDeltaAfterMoveCp: -500,
            ),
          ],
        ),
      );

      expect(result.candidateCount, 0);
      expect(
        result.suppressions.single.reasonCode,
        DeepCandidateReasonCode.invalidFenSuppressed,
      );
      expect(result.telemetry.skippedInvalid, 1);
      expect(eval.calls, isEmpty);
    });

    test('quiet positions do not become deep candidates by default', () async {
      final eval = _FakeLocalEvalService();
      final experiment = _experiment(eval);

      final result = await experiment.run(
        const GameLevelDeepGatingExperimentRequest(
          positions: [LocalAnalysisPositionInput(fen: _fen)],
        ),
      );

      expect(result.candidateCount, 0);
      expect(result.selectedDeepCount, 0);
      expect(result.totalEngineCalls, 0);
    });

    test('tactical signal creates a candidate', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const GameLevelDeepGatingExperimentRequest(
          positions: [LocalAnalysisPositionInput(fen: _fen, givesCheck: true)],
        ),
      );

      expect(result.candidateCount, 1);
      expect(
        result.candidates.single.reasonCodes,
        contains(DeepCandidateReasonCode.tacticalSignal),
      );
    });

    test('material swing creates and boosts a candidate', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const GameLevelDeepGatingExperimentRequest(
          positions: [
            LocalAnalysisPositionInput(
              fen: _fen,
              materialDeltaAfterMoveCp: -320,
              isCapture: true,
            ),
          ],
        ),
      );

      expect(result.candidateCount, 1);
      expect(
        result.candidates.single.reasonCodes,
        contains(DeepCandidateReasonCode.materialSwing),
      );
      expect(result.candidates.single.priorityScore, greaterThanOrEqualTo(300));
    });

    test('major eval swing creates and boosts a candidate', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const GameLevelDeepGatingExperimentRequest(
          positions: [
            LocalAnalysisPositionInput(
              fen: _fen,
              previousEvalCp: 180,
              provisionalEvalCp: -170,
            ),
          ],
        ),
      );

      expect(result.candidateCount, 1);
      expect(
        result.candidates.single.reasonCodes,
        contains(DeepCandidateReasonCode.majorEvalSwing),
      );
      expect(result.candidates.single.priorityScore, greaterThanOrEqualTo(300));
    });

    test('candidate eval spread creates or boosts a candidate', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const GameLevelDeepGatingExperimentRequest(
          positions: [
            LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 240),
          ],
        ),
      );

      expect(
        result.candidates.single.reasonCodes,
        contains(DeepCandidateReasonCode.candidateEvalSpread),
      );
      expect(result.candidates.single.proposedMultiPv, greaterThanOrEqualTo(2));
    });

    test(
      'mate score in fast evidence creates high-priority candidate',
      () async {
        final result = await _experiment(_FakeLocalEvalService()).run(
          const GameLevelDeepGatingExperimentRequest(
            positions: [LocalAnalysisPositionInput(fen: _fen)],
            providedFastEvidence: [
              GameLevelProvidedFastEvidence(
                positionIndex: 0,
                mateIn: 3,
                pvCount: 1,
              ),
            ],
          ),
        );

        expect(
          result.candidates.single.reasonCodes,
          contains(DeepCandidateReasonCode.mateScoreDetected),
        );
        expect(
          result.candidates.single.priorityScore,
          greaterThanOrEqualTo(1000),
        );
        expect(result.candidates.single.proposedMultiPv, 3);
      },
    );

    test('missing fast PV creates warning and candidate', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const GameLevelDeepGatingExperimentRequest(
          positions: [LocalAnalysisPositionInput(fen: _fen)],
          providedFastEvidence: [
            GameLevelProvidedFastEvidence(positionIndex: 0, scoreCp: 20),
          ],
        ),
      );

      expect(result.candidateCount, 1);
      expect(result.warnings.single, contains('no fast-pass PV'));
      expect(
        result.candidates.single.reasonCodes,
        contains(DeepCandidateReasonCode.missingFastPv),
      );
    });
  });

  group('GameLevelDeepGatingExperiment budgets and ranking', () {
    test('candidate ranking is deterministic', () async {
      final experiment = _experiment(_FakeLocalEvalService());

      final first = await experiment.run(
        const GameLevelDeepGatingExperimentRequest(
          positions: [
            LocalAnalysisPositionInput(fen: _fen, givesCheck: true),
            LocalAnalysisPositionInput(
              fen: _fen,
              previousEvalCp: 300,
              provisionalEvalCp: -100,
            ),
            LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 240),
          ],
        ),
      );
      final second = await experiment.run(
        const GameLevelDeepGatingExperimentRequest(
          positions: [
            LocalAnalysisPositionInput(fen: _fen, givesCheck: true),
            LocalAnalysisPositionInput(
              fen: _fen,
              previousEvalCp: 300,
              provisionalEvalCp: -100,
            ),
            LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 240),
          ],
        ),
      );

      expect(
        first.candidates.map((candidate) => candidate.positionIndex),
        second.candidates.map((candidate) => candidate.positionIndex),
      );
      expect(first.candidates.first.positionIndex, 1);
    });

    test('maxDeepCandidates caps selected candidates', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const GameLevelDeepGatingExperimentRequest(
          maxDeepCandidates: 1,
          positions: [
            LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 240),
            LocalAnalysisPositionInput(
              fen: _fen,
              materialDeltaAfterMoveCp: -300,
            ),
          ],
        ),
      );

      expect(result.candidateCount, 2);
      expect(result.selectedDeepCount, 1);
      expect(result.telemetry.candidatesSuppressedByBudget, 1);
    });

    test('maxDeepEngineCalls caps selected candidates', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const GameLevelDeepGatingExperimentRequest(
          maxDeepEngineCalls: 2,
          positions: [
            LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 240),
            LocalAnalysisPositionInput(
              fen: _fen,
              materialDeltaAfterMoveCp: -300,
            ),
          ],
        ),
      );

      expect(result.selectedDeepCount, 1);
      expect(result.selectedCandidates.single.budgetCostEstimate, 2);
      expect(result.telemetry.candidatesSuppressedByBudget, 1);
    });

    test('maxTotalEngineCalls is honored after fast pass cost', () async {
      final eval = _FakeLocalEvalService();
      final result = await _experiment(eval).run(
        const GameLevelDeepGatingExperimentRequest(
          mode: GameLevelDeepGatingMode.fastThenPlanDeep,
          maxTotalEngineCalls: 2,
          positions: [
            LocalAnalysisPositionInput(
              fen: _fen,
              materialDeltaAfterMoveCp: -300,
            ),
            LocalAnalysisPositionInput(fen: _fen),
          ],
        ),
      );

      expect(result.fastEngineCalls, 2);
      expect(result.candidateCount, 1);
      expect(result.selectedDeepCount, 0);
      expect(result.telemetry.candidatesSuppressedByBudget, 1);
    });

    test('low power suppresses deep by default', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const GameLevelDeepGatingExperimentRequest(
          lowPower: true,
          positions: [
            LocalAnalysisPositionInput(
              fen: _fen,
              materialDeltaAfterMoveCp: -500,
            ),
          ],
        ),
      );

      expect(result.candidateCount, 0);
      expect(
        result.suppressions.single.reasonCode,
        DeepCandidateReasonCode.lowPowerSuppressed,
      );
      expect(result.telemetry.candidatesSuppressedByLowPower, 1);
    });

    test('MultiPV never exceeds profile cap', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const GameLevelDeepGatingExperimentRequest(
          profile: LocalSchedulerProfile.performance,
          positions: [
            LocalAnalysisPositionInput(
              fen: _fen,
              previousEvalCp: 500,
              provisionalEvalCp: -200,
              candidateEvalSpreadCp: 450,
            ),
          ],
        ),
      );

      expect(
        result.candidates.single.proposedMultiPv,
        lessThanOrEqualTo(LocalSchedulerProfile.performance.maxMultiPv),
      );
    });

    test('owner profile can propose stronger finite budget', () async {
      final performance = await _experiment(_FakeLocalEvalService()).run(
        const GameLevelDeepGatingExperimentRequest(
          profile: LocalSchedulerProfile.performance,
          positions: [
            LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 300),
          ],
        ),
      );
      final owner = await _experiment(_FakeLocalEvalService()).run(
        const GameLevelDeepGatingExperimentRequest(
          profile: LocalSchedulerProfile.owner,
          positions: [
            LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 300),
          ],
        ),
      );

      expect(
        owner.candidates.single.proposedDepth,
        greaterThan(performance.candidates.single.proposedDepth),
      );
      expect(
        owner.candidates.single.proposedDepth,
        lessThanOrEqualTo(LocalSchedulerProfile.owner.maxDepth),
      );
    });

    test('eco profile suppresses deep planning', () async {
      final result = await _experiment(_FakeLocalEvalService()).run(
        const GameLevelDeepGatingExperimentRequest(
          profile: LocalSchedulerProfile.eco,
          positions: [
            LocalAnalysisPositionInput(
              fen: _fen,
              materialDeltaAfterMoveCp: -500,
            ),
          ],
        ),
      );

      expect(result.candidateCount, 0);
      expect(
        result.suppressions.single.reasonCode,
        DeepCandidateReasonCode.profileSuppressed,
      );
    });
  });

  group('GameLevelDeepGatingExperiment execution modes', () {
    test('planOnly mode does not call engine', () async {
      final eval = _FakeLocalEvalService();

      await _experiment(eval).run(
        const GameLevelDeepGatingExperimentRequest(
          mode: GameLevelDeepGatingMode.planOnly,
          positions: [
            LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 300),
          ],
        ),
      );

      expect(eval.calls, isEmpty);
    });

    test('fastThenPlanDeep runs fast pass but not deep pass', () async {
      final eval = _FakeLocalEvalService();

      final result = await _experiment(eval).run(
        const GameLevelDeepGatingExperimentRequest(
          mode: GameLevelDeepGatingMode.fastThenPlanDeep,
          positions: [
            LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 300),
            LocalAnalysisPositionInput(fen: _fen),
          ],
        ),
      );

      expect(result.fastEngineCalls, 2);
      expect(result.deepEngineCalls, 0);
      expect(result.selectedDeepCount, 1);
      expect(eval.calls, hasLength(2));
      expect(eval.calls.every((call) => call.multiPv == 1), isTrue);
    });

    test(
      'fastThenExecuteSelectedDeep executes only selected candidates',
      () async {
        final eval = _FakeLocalEvalService();

        final result = await _experiment(eval).run(
          const GameLevelDeepGatingExperimentRequest(
            mode: GameLevelDeepGatingMode.fastThenExecuteSelectedDeep,
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
        expect(eval.calls, hasLength(4));
        expect(eval.maxConcurrentCalls, 1);
        expect(eval.calls.last.multiPv, 3);
      },
    );

    test('failFast behavior is safe and deterministic', () async {
      final eval = _FakeLocalEvalService(
        plans: [_FakeEvalPlan.error(EvalError.serverError)],
      );

      final result = await _experiment(eval).run(
        const GameLevelDeepGatingExperimentRequest(
          mode: GameLevelDeepGatingMode.fastThenExecuteSelectedDeep,
          failFast: true,
          positions: [
            LocalAnalysisPositionInput(
              fen: _fen,
              materialDeltaAfterMoveCp: -320,
            ),
            LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 300),
          ],
        ),
      );

      expect(result.status, GameLevelDeepGatingStatus.failed);
      expect(result.deepEngineCalls, 0);
      expect(eval.calls, hasLength(1));
    });

    test(
      'budget exhaustion returns warning status instead of crashing',
      () async {
        final result = await _experiment(_FakeLocalEvalService()).run(
          const GameLevelDeepGatingExperimentRequest(
            mode: GameLevelDeepGatingMode.fastThenExecuteSelectedDeep,
            maxTotalEngineCalls: 1,
            positions: [
              LocalAnalysisPositionInput(
                fen: _fen,
                materialDeltaAfterMoveCp: -320,
              ),
            ],
          ),
        );

        expect(result.status, GameLevelDeepGatingStatus.completedWithWarnings);
        expect(result.selectedDeepCount, 0);
        expect(result.telemetry.candidatesSuppressedByBudget, 1);
      },
    );
  });

  group('GameLevelDeepGatingExperiment report and guardrails', () {
    test(
      'report renderer is deterministic and omits raw engine spam',
      () async {
        final result = await _experiment(_FakeLocalEvalService()).run(
          const GameLevelDeepGatingExperimentRequest(
            requestId: 'gate-report',
            positions: [
              LocalAnalysisPositionInput(fen: _fen, candidateEvalSpreadCp: 300),
            ],
          ),
        );

        final report = result.renderDeveloperReport();
        expect(result.debugSummary, result.debugSummary);
        expect(report, contains('Game-Level Deep Gating Experiment'));
        expect(report, contains('candidates selected: 1'));
        expect(report, isNot(contains('uciok')));
        expect(report, isNot(contains('readyok')));
        expect(report, isNot(contains('info depth')));
        expect(report, isNot(contains('bestmove e2e4')));
      },
    );

    test('source avoids forbidden layers and product output changes', () {
      final source = File(
        'lib/features/pgn_review/application/game_level_deep_gating_experiment.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      expect(imports, contains('local_review_orchestration_experiment.dart'));
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

GameLevelDeepGatingExperiment _experiment(_FakeLocalEvalService eval) {
  return GameLevelDeepGatingExperiment(
    orchestration: LocalReviewOrchestrationExperiment(
      measuredReview: MeasuredLocalReviewPrototype(
        executor: LocalSmartAnalysisExecutor(eval: eval),
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

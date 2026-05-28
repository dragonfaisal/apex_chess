import 'dart:async';
import 'dart:io';

import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/infrastructure/engine/chess_engine.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_command.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_event.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_orchestration_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_executor.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';
import 'package:apex_chess/features/pgn_review/application/measured_local_review_prototype.dart';
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';
import 'package:flutter_test/flutter_test.dart';

const _fen =
    'rn1qkbnr/ppp2ppp/3b4/3pp3/4P3/2NP1N2/PPP2PPP/R1BQKB1R w KQkq - 2 5';

void main() {
  group('LocalReviewOrchestrationExperiment mapping', () {
    test('empty source completes safely with zero engine calls', () async {
      final eval = _FakeLocalEvalService();
      final experiment = _experiment(eval);

      final result = await experiment.run(
        const LocalReviewOrchestrationExperimentRequest.fromSchedulerInputs(
          positions: [],
        ),
      );

      expect(result.status, LocalReviewOrchestrationStatus.completed);
      expect(result.sourcePositionCount, 0);
      expect(result.mappedPositionCount, 0);
      expect(result.telemetry.measuredEngineCalls, 0);
      expect(
        result.recommendation,
        LocalReviewOrchestrationRecommendation.needsMappedPositions,
      );
      expect(eval.calls, isEmpty);
    });

    test(
      'scheduler input list passes through and runs measured review',
      () async {
        final eval = _FakeLocalEvalService();
        final experiment = _experiment(eval);

        final result = await experiment.run(
          const LocalReviewOrchestrationExperimentRequest.fromSchedulerInputs(
            positions: [
              LocalAnalysisPositionInput(fen: _fen),
              LocalAnalysisPositionInput(fen: _fen),
            ],
          ),
        );

        expect(result.status, LocalReviewOrchestrationStatus.completed);
        expect(result.sourcePositionCount, 2);
        expect(result.mappedPositionCount, 2);
        expect(result.measuredResult.fastCount, 2);
        expect(result.telemetry.measuredEngineCalls, 2);
      },
    );

    test(
      'PGN source maps review-shaped positions without product output',
      () async {
        final eval = _FakeLocalEvalService();
        final experiment = _experiment(eval);

        final result = await experiment.run(
          const LocalReviewOrchestrationExperimentRequest.fromPgn(
            pgn: '''
[Event "Apex 30J"]
[Site "?"]
[Result "*"]

1. e4 e5 2. Nf3 Nc6 *
''',
            maxPositions: 2,
          ),
        );

        expect(result.status, LocalReviewOrchestrationStatus.completed);
        expect(result.sourcePositionCount, 4);
        expect(result.mappedPositionCount, 4);
        expect(result.measuredResult.processedPositionCount, 2);
        expect(result.measuredResult.positionResults.first.requestId, isNull);
        expect(eval.calls, hasLength(2));
      },
    );

    test('parsed position mapping preserves result order', () async {
      final eval = _FakeLocalEvalService();
      final experiment = _experiment(eval);

      final result = await experiment.run(
        const LocalReviewOrchestrationExperimentRequest.fromParsedPositions(
          requestId: 'orch',
          positions: [
            LocalReviewOrchestrationPosition(
              fen: _fen,
              reference: 'a',
              isOpeningKnown: true,
            ),
            LocalReviewOrchestrationPosition(fen: _fen, reference: 'b'),
            LocalReviewOrchestrationPosition(fen: 'bad fen', reference: 'c'),
          ],
        ),
      );

      expect(result.measuredResult.positionResults.map((r) => r.requestId), [
        'orch#0',
        'orch#1',
        'orch#2',
      ]);
      expect(result.measuredResult.positionResults.map((r) => r.status), [
        LocalSchedulerExecutionStatus.skipped,
        LocalSchedulerExecutionStatus.fastCompleted,
        LocalSchedulerExecutionStatus.rejected,
      ]);
    });

    test(
      'invalid FEN from mapped source is rejected through measured review',
      () async {
        final eval = _FakeLocalEvalService();
        final experiment = _experiment(eval);

        final result = await experiment.run(
          const LocalReviewOrchestrationExperimentRequest.fromParsedPositions(
            positions: [LocalReviewOrchestrationPosition(fen: 'bad fen')],
          ),
        );

        expect(result.status, LocalReviewOrchestrationStatus.rejected);
        expect(result.telemetry.measuredRejected, 1);
        expect(result.telemetry.measuredEngineCalls, 0);
        expect(eval.calls, isEmpty);
      },
    );

    test(
      'opening-known and only-legal mapping lead to skipped counts',
      () async {
        final eval = _FakeLocalEvalService();
        final experiment = _experiment(eval);

        final result = await experiment.run(
          const LocalReviewOrchestrationExperimentRequest.fromParsedPositions(
            positions: [
              LocalReviewOrchestrationPosition(fen: _fen, isOpeningKnown: true),
              LocalReviewOrchestrationPosition(
                fen: _fen,
                isOnlyLegalMove: true,
              ),
            ],
          ),
        );

        expect(result.status, LocalReviewOrchestrationStatus.completed);
        expect(result.measuredResult.skippedCount, 2);
        expect(result.telemetry.measuredEngineCalls, 0);
      },
    );

    test('mapping warnings aggregate without dropping positions', () async {
      final eval = _FakeLocalEvalService();
      final experiment = _experiment(eval);

      final result = await experiment.run(
        const LocalReviewOrchestrationExperimentRequest.fromParsedPositions(
          positions: [LocalReviewOrchestrationPosition(fen: ' ', plyIndex: -1)],
        ),
      );

      expect(
        result.status,
        anyOf(
          LocalReviewOrchestrationStatus.rejected,
          LocalReviewOrchestrationStatus.completedWithWarnings,
        ),
      );
      expect(result.mappingWarnings, hasLength(2));
      expect(result.telemetry.mappingWarningCount, 2);
      expect(result.measuredResult.rejectedCount, 1);
    });
  });

  group('LocalReviewOrchestrationExperiment measured execution', () {
    test('normal positions produce fast execution counts', () async {
      final eval = _FakeLocalEvalService();
      final experiment = _experiment(eval);

      final result = await experiment.run(
        const LocalReviewOrchestrationExperimentRequest.fromParsedPositions(
          positions: [
            LocalReviewOrchestrationPosition(fen: _fen),
            LocalReviewOrchestrationPosition(fen: _fen),
            LocalReviewOrchestrationPosition(fen: _fen),
          ],
        ),
      );

      expect(result.status, LocalReviewOrchestrationStatus.completed);
      expect(result.telemetry.measuredFastCalls, 3);
      expect(result.telemetry.measuredDeepCalls, 0);
      expect(result.telemetry.measuredEngineCalls, 3);
    });

    test('tactical hints produce deep execution counts', () async {
      final eval = _FakeLocalEvalService();
      final experiment = _experiment(eval);

      final result = await experiment.run(
        const LocalReviewOrchestrationExperimentRequest.fromParsedPositions(
          positions: [
            LocalReviewOrchestrationPosition(
              fen: _fen,
              reference: 'sacrifice',
              materialDeltaAfterMoveCp: -260,
              isCapture: true,
            ),
          ],
        ),
      );

      expect(result.status, LocalReviewOrchestrationStatus.completed);
      expect(result.telemetry.measuredFastCalls, 1);
      expect(result.telemetry.measuredDeepCalls, 1);
      expect(result.deepGatingObservations.deepSearchPositionRefs, [
        'sacrifice',
      ]);
      expect(result.deepGatingObservations.futureGateCandidateRefs, [
        'sacrifice',
      ]);
    });

    test('maxPositions limits measured execution', () async {
      final eval = _FakeLocalEvalService();
      final experiment = _experiment(eval);

      final result = await experiment.run(
        const LocalReviewOrchestrationExperimentRequest.fromParsedPositions(
          maxPositions: 2,
          positions: [
            LocalReviewOrchestrationPosition(fen: _fen),
            LocalReviewOrchestrationPosition(fen: _fen),
            LocalReviewOrchestrationPosition(fen: _fen),
          ],
        ),
      );

      expect(result.sourcePositionCount, 3);
      expect(result.mappedPositionCount, 3);
      expect(result.measuredResult.processedPositionCount, 2);
      expect(result.telemetry.measuredEngineCalls, 2);
    });

    test('maxTotalEngineCalls is enforced through measured review', () async {
      final eval = _FakeLocalEvalService();
      final experiment = _experiment(eval);

      final result = await experiment.run(
        const LocalReviewOrchestrationExperimentRequest.fromParsedPositions(
          maxTotalEngineCalls: 1,
          positions: [
            LocalReviewOrchestrationPosition(fen: _fen),
            LocalReviewOrchestrationPosition(fen: _fen),
          ],
        ),
      );

      expect(
        result.status,
        LocalReviewOrchestrationStatus.completedWithWarnings,
      );
      expect(result.telemetry.measuredEngineCalls, 1);
      expect(
        result.telemetry.budgetStopReason,
        contains('maxTotalEngineCalls'),
      );
      expect(
        result.recommendation,
        LocalReviewOrchestrationRecommendation.tuneBudgetsBeforeDeepGate,
      );
    });

    test('maxTotalElapsedBudgetMs is reported safely', () async {
      final eval = _FakeLocalEvalService(
        plans: [
          _FakeEvalPlan.dynamicSuccess(delay: const Duration(milliseconds: 6)),
          _FakeEvalPlan.dynamicSuccess(delay: const Duration(milliseconds: 6)),
        ],
      );
      final experiment = _experiment(eval);

      final result = await experiment.run(
        const LocalReviewOrchestrationExperimentRequest.fromParsedPositions(
          maxTotalElapsedBudgetMs: 1,
          positions: [
            LocalReviewOrchestrationPosition(fen: _fen),
            LocalReviewOrchestrationPosition(fen: _fen),
          ],
        ),
      );

      expect(
        result.status,
        LocalReviewOrchestrationStatus.completedWithWarnings,
      );
      expect(result.telemetry.measuredEngineCalls, 1);
      expect(
        result.telemetry.budgetStopReason,
        contains('maxTotalElapsedBudgetMs'),
      );
    });

    test('failFast stops orchestration on first failure', () async {
      final eval = _FakeLocalEvalService(
        plans: [
          _FakeEvalPlan.error(EvalError.serverError),
          _FakeEvalPlan.dynamicSuccess(),
        ],
      );
      final experiment = _experiment(eval);

      final result = await experiment.run(
        const LocalReviewOrchestrationExperimentRequest.fromParsedPositions(
          failFast: true,
          positions: [
            LocalReviewOrchestrationPosition(fen: _fen),
            LocalReviewOrchestrationPosition(fen: _fen),
          ],
        ),
      );

      expect(result.status, LocalReviewOrchestrationStatus.failed);
      expect(result.failures, hasLength(1));
      expect(eval.calls, hasLength(1));
    });

    test('failFast false continues and returns partial failure', () async {
      final eval = _FakeLocalEvalService(
        plans: [
          _FakeEvalPlan.error(EvalError.serverError),
          _FakeEvalPlan.dynamicSuccess(),
        ],
      );
      final experiment = _experiment(eval);

      final result = await experiment.run(
        const LocalReviewOrchestrationExperimentRequest.fromParsedPositions(
          positions: [
            LocalReviewOrchestrationPosition(fen: _fen),
            LocalReviewOrchestrationPosition(fen: _fen),
          ],
        ),
      );

      expect(result.status, LocalReviewOrchestrationStatus.partialFailure);
      expect(result.failures, hasLength(1));
      expect(result.telemetry.measuredEngineCalls, 2);
      expect(eval.calls, hasLength(2));
    });

    test('execution remains serial', () async {
      final eval = _FakeLocalEvalService(
        plans: [
          _FakeEvalPlan.dynamicSuccess(delay: const Duration(milliseconds: 4)),
          _FakeEvalPlan.dynamicSuccess(delay: const Duration(milliseconds: 4)),
          _FakeEvalPlan.dynamicSuccess(delay: const Duration(milliseconds: 4)),
        ],
      );
      final experiment = _experiment(eval);

      await experiment.run(
        const LocalReviewOrchestrationExperimentRequest.fromParsedPositions(
          positions: [
            LocalReviewOrchestrationPosition(fen: _fen),
            LocalReviewOrchestrationPosition(fen: _fen),
            LocalReviewOrchestrationPosition(fen: _fen),
          ],
        ),
      );

      expect(eval.maxConcurrentCalls, 1);
    });
  });

  group('LocalReviewOrchestrationExperiment reporting and guardrails', () {
    test(
      'developer report is deterministic and omits raw engine spam',
      () async {
        final eval = _FakeLocalEvalService();
        final experiment = _experiment(eval);

        final result = await experiment.run(
          const LocalReviewOrchestrationExperimentRequest.fromParsedPositions(
            requestId: 'report',
            positions: [
              LocalReviewOrchestrationPosition(fen: _fen, reference: 'quiet'),
            ],
          ),
        );

        final report = result.renderDeveloperReport();
        expect(result.debugSummary, result.debugSummary);
        expect(report, contains('Local Review Orchestration Experiment'));
        expect(report, contains('engine calls: 1'));
        expect(report, isNot(contains('uciok')));
        expect(report, isNot(contains('readyok')));
        expect(report, isNot(contains('info depth')));
        expect(report, isNot(contains('bestmove e2e4')));
      },
    );

    test('source avoids forbidden layers and product output changes', () {
      final source = File(
        'lib/features/pgn_review/application/local_review_orchestration_experiment.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      expect(imports, contains('measured_local_review_prototype.dart'));
      expect(imports, isNot(contains('local_eval_service.dart')));
      expect(imports, isNot(contains('local_game_analyzer.dart')));
      expect(imports, isNot(contains('evaluation_analyzer.dart')));
      expect(imports, isNot(contains('analysis_timeline.dart')));
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

LocalReviewOrchestrationExperiment _experiment(_FakeLocalEvalService eval) {
  return LocalReviewOrchestrationExperiment(
    measuredReview: MeasuredLocalReviewPrototype(
      executor: LocalSmartAnalysisExecutor(eval: eval),
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
}) {
  return EvalSnapshot(
    scoreCp: scoreCp,
    depth: depth,
    bestMoveUci: bestMove,
    pvMoves: pv,
    engineLines: [
      for (var rank = 1; rank <= multiPv; rank++)
        EngineLine(
          rank: rank,
          moveUci: rank == 1 ? bestMove : 'd2d4',
          scoreCp: scoreCp == null ? null : scoreCp - (rank - 1) * 10,
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

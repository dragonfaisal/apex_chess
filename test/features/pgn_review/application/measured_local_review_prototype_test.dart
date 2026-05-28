import 'dart:async';
import 'dart:io';

import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/infrastructure/engine/chess_engine.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_command.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_event.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_executor.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';
import 'package:apex_chess/features/pgn_review/application/measured_local_review_prototype.dart';
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';
import 'package:flutter_test/flutter_test.dart';

const _fen =
    'rn1qkbnr/ppp2ppp/3b4/3pp3/4P3/2NP1N2/PPP2PPP/R1BQKB1R w KQkq - 2 5';

void main() {
  group('MeasuredLocalReviewPrototype basic execution', () {
    test('empty request completes with zero engine calls', () async {
      final eval = _FakeLocalEvalService();
      final prototype = _prototype(eval);

      final result = await prototype.run(
        const MeasuredLocalReviewRequest(positions: []),
      );

      expect(result.status, MeasuredLocalReviewStatus.completed);
      expect(result.processedPositionCount, 0);
      expect(result.totalEngineCalls, 0);
      expect(result.telemetry, MeasuredLocalReviewTelemetry.empty);
      expect(eval.calls, isEmpty);
    });

    test('opening-known positions are skipped and counted', () async {
      final eval = _FakeLocalEvalService();
      final prototype = _prototype(eval);

      final result = await prototype.run(
        const MeasuredLocalReviewRequest(
          positions: [
            LocalAnalysisPositionInput(fen: _fen, isOpeningKnown: true),
            LocalAnalysisPositionInput(fen: _fen, isOpeningKnown: true),
          ],
        ),
      );

      expect(result.status, MeasuredLocalReviewStatus.completed);
      expect(result.skippedCount, 2);
      expect(result.totalEngineCalls, 0);
      expect(eval.calls, isEmpty);
    });

    test('only-legal-move positions are skipped and counted', () async {
      final eval = _FakeLocalEvalService();
      final prototype = _prototype(eval);

      final result = await prototype.run(
        const MeasuredLocalReviewRequest(
          positions: [
            LocalAnalysisPositionInput(fen: _fen, isOnlyLegalMove: true),
          ],
        ),
      );

      expect(result.status, MeasuredLocalReviewStatus.completed);
      expect(result.skippedCount, 1);
      expect(result.totalEngineCalls, 0);
      expect(
        result.positionResults.single.decision.type,
        LocalSchedulerDecisionType.skipForced,
      );
    });

    test('invalid FEN positions are rejected and counted', () async {
      final eval = _FakeLocalEvalService();
      final prototype = _prototype(eval);

      final result = await prototype.run(
        const MeasuredLocalReviewRequest(
          positions: [LocalAnalysisPositionInput(fen: 'bad fen')],
        ),
      );

      expect(result.status, MeasuredLocalReviewStatus.rejected);
      expect(result.rejectedCount, 1);
      expect(result.telemetry.invalidFens, 1);
      expect(result.totalEngineCalls, 0);
    });
  });

  group('MeasuredLocalReviewPrototype measured engine behavior', () {
    test('normal positions execute fast calls serially', () async {
      final eval = _FakeLocalEvalService(
        plans: [
          _FakeEvalPlan.dynamicSuccess(delay: const Duration(milliseconds: 4)),
          _FakeEvalPlan.dynamicSuccess(delay: const Duration(milliseconds: 4)),
          _FakeEvalPlan.dynamicSuccess(delay: const Duration(milliseconds: 4)),
        ],
      );
      final prototype = _prototype(eval);

      final result = await prototype.run(
        const MeasuredLocalReviewRequest(
          requestId: 'review',
          positions: [
            LocalAnalysisPositionInput(fen: _fen),
            LocalAnalysisPositionInput(fen: _fen),
            LocalAnalysisPositionInput(fen: _fen),
          ],
        ),
      );

      expect(result.status, MeasuredLocalReviewStatus.completed);
      expect(result.fastCount, 3);
      expect(result.deepCount, 0);
      expect(result.totalEngineCalls, 3);
      expect(eval.maxConcurrentCalls, 1);
      expect(eval.calls.map((call) => call.sequence), [1, 2, 3]);
    });

    test('critical positions execute fast and deep where planned', () async {
      final eval = _FakeLocalEvalService();
      final prototype = _prototype(eval);

      final result = await prototype.run(
        const MeasuredLocalReviewRequest(
          positions: [
            LocalAnalysisPositionInput(
              fen: _fen,
              materialDeltaAfterMoveCp: -250,
              isCapture: true,
            ),
          ],
        ),
      );

      expect(result.status, MeasuredLocalReviewStatus.completed);
      expect(result.fastCount, 1);
      expect(result.deepCount, 1);
      expect(result.totalEngineCalls, 2);
      expect(eval.calls.first.multiPv, 1);
      expect(eval.calls.last.multiPv, 3);
    });

    test(
      'mixed batch aggregates skip, fast, deep, and reject counts',
      () async {
        final eval = _FakeLocalEvalService();
        final prototype = _prototype(eval);

        final result = await prototype.run(
          const MeasuredLocalReviewRequest(
            positions: [
              LocalAnalysisPositionInput(fen: _fen, isOpeningKnown: true),
              LocalAnalysisPositionInput(fen: _fen),
              LocalAnalysisPositionInput(
                fen: _fen,
                materialDeltaAfterMoveCp: -260,
                isCapture: true,
              ),
              LocalAnalysisPositionInput(fen: '8/8/8 w'),
            ],
          ),
        );

        expect(result.status, MeasuredLocalReviewStatus.completed);
        expect(result.skippedCount, 1);
        expect(result.rejectedCount, 1);
        expect(result.fastCount, 2);
        expect(result.deepCount, 1);
        expect(result.totalEngineCalls, 3);
        expect(result.telemetry.positionsExecuted, 2);
      },
    );

    test('per-position result order is preserved', () async {
      final eval = _FakeLocalEvalService();
      final prototype = _prototype(eval);

      final result = await prototype.run(
        const MeasuredLocalReviewRequest(
          requestId: 'ordered',
          positions: [
            LocalAnalysisPositionInput(fen: _fen, isOpeningKnown: true),
            LocalAnalysisPositionInput(fen: _fen),
            LocalAnalysisPositionInput(fen: 'bad fen'),
          ],
        ),
      );

      expect(result.positionResults.map((r) => r.requestId), [
        'ordered#0',
        'ordered#1',
        'ordered#2',
      ]);
      expect(result.positionResults.map((r) => r.status), [
        LocalSchedulerExecutionStatus.skipped,
        LocalSchedulerExecutionStatus.fastCompleted,
        LocalSchedulerExecutionStatus.rejected,
      ]);
    });
  });

  group('MeasuredLocalReviewPrototype failure and budget behavior', () {
    test('failFast stops after first failure', () async {
      final eval = _FakeLocalEvalService(
        plans: [
          _FakeEvalPlan.error(EvalError.serverError),
          _FakeEvalPlan.dynamicSuccess(),
        ],
      );
      final prototype = _prototype(eval);

      final result = await prototype.run(
        const MeasuredLocalReviewRequest(
          failFast: true,
          positions: [
            LocalAnalysisPositionInput(fen: _fen),
            LocalAnalysisPositionInput(fen: _fen),
          ],
        ),
      );

      expect(result.status, MeasuredLocalReviewStatus.failed);
      expect(result.processedPositionCount, 1);
      expect(result.failureCount, 1);
      expect(eval.calls, hasLength(1));
    });

    test('failFast false continues after a failure', () async {
      final eval = _FakeLocalEvalService(
        plans: [
          _FakeEvalPlan.error(EvalError.serverError),
          _FakeEvalPlan.dynamicSuccess(),
        ],
      );
      final prototype = _prototype(eval);

      final result = await prototype.run(
        const MeasuredLocalReviewRequest(
          positions: [
            LocalAnalysisPositionInput(fen: _fen),
            LocalAnalysisPositionInput(fen: _fen),
          ],
        ),
      );

      expect(result.status, MeasuredLocalReviewStatus.partialFailure);
      expect(result.processedPositionCount, 2);
      expect(result.failureCount, 1);
      expect(result.fastCount, 2);
      expect(eval.calls, hasLength(2));
    });

    test('maxPositions limits processed positions', () async {
      final eval = _FakeLocalEvalService();
      final prototype = _prototype(eval);

      final result = await prototype.run(
        const MeasuredLocalReviewRequest(
          maxPositions: 2,
          positions: [
            LocalAnalysisPositionInput(fen: _fen),
            LocalAnalysisPositionInput(fen: _fen),
            LocalAnalysisPositionInput(fen: _fen),
          ],
        ),
      );

      expect(result.status, MeasuredLocalReviewStatus.completed);
      expect(result.processedPositionCount, 2);
      expect(result.totalEngineCalls, 2);
      expect(eval.calls, hasLength(2));
    });

    test('maxTotalEngineCalls stops and warns safely when reached', () async {
      final eval = _FakeLocalEvalService();
      final prototype = _prototype(eval);

      final result = await prototype.run(
        const MeasuredLocalReviewRequest(
          maxTotalEngineCalls: 1,
          positions: [
            LocalAnalysisPositionInput(fen: _fen),
            LocalAnalysisPositionInput(fen: _fen),
          ],
        ),
      );

      expect(result.status, MeasuredLocalReviewStatus.completedWithWarnings);
      expect(result.processedPositionCount, 1);
      expect(result.totalEngineCalls, 1);
      expect(result.warnings.single, contains('maxTotalEngineCalls reached'));
    });

    test('maxTotalEngineCalls prevents planned deep budget overrun', () async {
      final eval = _FakeLocalEvalService();
      final prototype = _prototype(eval);

      final result = await prototype.run(
        const MeasuredLocalReviewRequest(
          maxTotalEngineCalls: 1,
          positions: [
            LocalAnalysisPositionInput(
              fen: _fen,
              materialDeltaAfterMoveCp: -260,
              isCapture: true,
            ),
          ],
        ),
      );

      expect(result.status, MeasuredLocalReviewStatus.completedWithWarnings);
      expect(result.processedPositionCount, 0);
      expect(result.totalEngineCalls, 0);
      expect(eval.calls, isEmpty);
      expect(
        result.warnings.single,
        contains('maxTotalEngineCalls would be exceeded'),
      );
    });

    test('timeout increments review telemetry', () async {
      final eval = _FakeLocalEvalService(plans: [_FakeEvalPlan.timeout()]);
      final prototype = _prototype(eval);

      final result = await prototype.run(
        const MeasuredLocalReviewRequest(
          positions: [LocalAnalysisPositionInput(fen: _fen)],
          timeoutBudgetOverride: Duration(milliseconds: 1),
        ),
      );

      expect(result.status, MeasuredLocalReviewStatus.failed);
      expect(result.failureCount, 1);
      expect(result.timeoutCount, 1);
      expect(result.telemetry.timeouts, 1);
    });

    test('missing PV and bestmove warnings aggregate', () async {
      final eval = _FakeLocalEvalService(
        plans: [
          _FakeEvalPlan.snapshot(_snapshot(bestMove: null, pv: const [])),
        ],
      );
      final prototype = _prototype(eval);

      final result = await prototype.run(
        const MeasuredLocalReviewRequest(
          positions: [LocalAnalysisPositionInput(fen: _fen)],
        ),
      );

      expect(result.status, MeasuredLocalReviewStatus.completedWithWarnings);
      expect(result.warningCount, 2);
      expect(result.telemetry.missingPvWarnings, 1);
      expect(result.telemetry.missingBestmoveWarnings, 1);
      expect(result.renderDeveloperReport(), contains('missing bestmove'));
    });
  });

  group('MeasuredLocalReviewPrototype reporting and guardrails', () {
    test('debug summary is deterministic for a completed result', () async {
      final eval = _FakeLocalEvalService();
      final prototype = _prototype(eval);

      final result = await prototype.run(
        const MeasuredLocalReviewRequest(
          requestId: 'stable',
          positions: [
            LocalAnalysisPositionInput(fen: _fen, isOpeningKnown: true),
          ],
        ),
      );

      expect(result.debugSummary, result.debugSummary);
      expect(result.debugSummary, contains('request=stable'));
      expect(result.debugSummary, contains('skipped=1'));
    });

    test('no parallel engine calls are made', () async {
      final eval = _FakeLocalEvalService(
        plans: [
          _FakeEvalPlan.dynamicSuccess(delay: const Duration(milliseconds: 5)),
          _FakeEvalPlan.dynamicSuccess(delay: const Duration(milliseconds: 5)),
          _FakeEvalPlan.dynamicSuccess(delay: const Duration(milliseconds: 5)),
        ],
      );
      final prototype = _prototype(eval);

      await prototype.run(
        const MeasuredLocalReviewRequest(
          positions: [
            LocalAnalysisPositionInput(fen: _fen),
            LocalAnalysisPositionInput(fen: _fen),
            LocalAnalysisPositionInput(fen: _fen),
          ],
        ),
      );

      expect(eval.maxConcurrentCalls, 1);
    });

    test('prototype source avoids forbidden layers and labels', () {
      final source = File(
        'lib/features/pgn_review/application/measured_local_review_prototype.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      expect(imports, contains('local_smart_analysis_executor.dart'));
      expect(imports, isNot(contains('local_eval_service.dart')));
      expect(imports, isNot(contains('stockfish')));
      expect(imports, isNot(contains('ffi')));
      expect(imports, isNot(contains('native')));
      expect(imports, isNot(contains('package:flutter/')));
      expect(imports, isNot(contains('Widget')));
      expect(imports, isNot(contains('preflight')));
      expect(imports, isNot(contains('backend')));
      expect(imports, isNot(contains('server')));
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

MeasuredLocalReviewPrototype _prototype(_FakeLocalEvalService eval) {
  return MeasuredLocalReviewPrototype(
    executor: LocalSmartAnalysisExecutor(eval: eval),
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
      if (plan.timeout) {
        throw TimeoutException('test timed out');
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
      return (plan.snapshot, plan.error);
    } finally {
      _activeCalls--;
    }
  }
}

class _FakeEvalPlan {
  const _FakeEvalPlan._({
    this.snapshot,
    this.error,
    this.timeout = false,
    this.dynamicSuccess = false,
    this.delay = Duration.zero,
  });

  factory _FakeEvalPlan.dynamicSuccess({Duration delay = Duration.zero}) =>
      _FakeEvalPlan._(dynamicSuccess: true, delay: delay);

  factory _FakeEvalPlan.snapshot(EvalSnapshot snapshot) =>
      _FakeEvalPlan._(snapshot: snapshot);

  factory _FakeEvalPlan.error(EvalError error) => _FakeEvalPlan._(error: error);

  factory _FakeEvalPlan.timeout() => const _FakeEvalPlan._(timeout: true);

  final EvalSnapshot? snapshot;
  final EvalError? error;
  final bool timeout;
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

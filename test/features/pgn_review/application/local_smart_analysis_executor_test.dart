import 'dart:async';
import 'dart:io';

import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/infrastructure/engine/chess_engine.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_command.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_event.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_executor.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';
import 'package:flutter_test/flutter_test.dart';

const _fen =
    'rn1qkbnr/ppp2ppp/3b4/3pp3/4P3/2NP1N2/PPP2PPP/R1BQKB1R w KQkq - 2 5';

void main() {
  group('LocalSmartAnalysisExecutor skip and reject behavior', () {
    test('opening-known decision skips engine call', () async {
      final eval = _FakeLocalEvalService();
      final executor = LocalSmartAnalysisExecutor(eval: eval);

      final result = await executor.execute(
        const LocalSchedulerExecutionRequest(
          input: LocalAnalysisPositionInput(fen: _fen, isOpeningKnown: true),
        ),
      );

      expect(result.status, LocalSchedulerExecutionStatus.skipped);
      expect(result.engineCallCount, 0);
      expect(eval.calls, isEmpty);
      expect(result.telemetry.positionsSkipped, 1);
    });

    test('only-legal-move decision skips engine call', () async {
      final eval = _FakeLocalEvalService();
      final executor = LocalSmartAnalysisExecutor(eval: eval);

      final result = await executor.execute(
        const LocalSchedulerExecutionRequest(
          input: LocalAnalysisPositionInput(fen: _fen, isOnlyLegalMove: true),
        ),
      );

      expect(result.status, LocalSchedulerExecutionStatus.skipped);
      expect(result.engineCallCount, 0);
      expect(eval.calls, isEmpty);
      expect(result.decision.type, LocalSchedulerDecisionType.skipForced);
    });

    test('invalid FEN rejects before engine call', () async {
      final eval = _FakeLocalEvalService();
      final executor = LocalSmartAnalysisExecutor(eval: eval);

      final result = await executor.execute(
        const LocalSchedulerExecutionRequest(
          input: LocalAnalysisPositionInput(fen: '8/8/8 w'),
        ),
      );

      expect(result.status, LocalSchedulerExecutionStatus.rejected);
      expect(result.engineCallCount, 0);
      expect(eval.calls, isEmpty);
      expect(result.telemetry.invalidFenCount, 1);
    });
  });

  group('LocalSmartAnalysisExecutor search execution', () {
    test('normal balanced position executes one fast call', () async {
      final eval = _FakeLocalEvalService();
      final executor = LocalSmartAnalysisExecutor(eval: eval);

      final result = await executor.execute(
        const LocalSchedulerExecutionRequest(
          input: LocalAnalysisPositionInput(fen: _fen, legalMoveCount: 20),
        ),
      );

      expect(result.status, LocalSchedulerExecutionStatus.fastCompleted);
      expect(result.fastSnapshot, isNotNull);
      expect(result.deepSnapshot, isNull);
      expect(result.engineCallCount, 1);
      expect(eval.calls.single.depth, LocalSchedulerProfile.balanced.fastDepth);
      expect(
        eval.calls.single.movetime,
        LocalSchedulerProfile.balanced.fastMovetime,
      );
      expect(eval.calls.single.multiPv, 1);
      expect(result.telemetry.fastCalls, 1);
    });

    test(
      'tactical critical input executes fast then deep when planned',
      () async {
        final eval = _FakeLocalEvalService();
        final executor = LocalSmartAnalysisExecutor(eval: eval);

        final result = await executor.execute(
          const LocalSchedulerExecutionRequest(
            input: LocalAnalysisPositionInput(
              fen: _fen,
              isCapture: true,
              materialDeltaAfterMoveCp: -260,
            ),
          ),
        );

        expect(result.decision.type, LocalSchedulerDecisionType.deepReanalysis);
        expect(result.status, LocalSchedulerExecutionStatus.deepCompleted);
        expect(result.fastSnapshot, isNotNull);
        expect(result.deepSnapshot, isNotNull);
        expect(eval.calls, hasLength(2));
        expect(
          eval.calls.first.depth,
          LocalSchedulerProfile.balanced.fastDepth,
        );
        expect(eval.calls.first.multiPv, 1);
        expect(eval.calls.last.depth, LocalSchedulerProfile.balanced.deepDepth);
        expect(eval.calls.last.multiPv, 3);
        expect(result.telemetry.fastCalls, 1);
        expect(result.telemetry.deepCalls, 1);
      },
    );

    test('MultiPV probe requests planned MultiPV', () async {
      final eval = _FakeLocalEvalService();
      final executor = LocalSmartAnalysisExecutor(eval: eval);

      final result = await executor.execute(
        const LocalSchedulerExecutionRequest(
          input: LocalAnalysisPositionInput(
            fen: _fen,
            legalMoveCount: 32,
            candidateEvalSpreadCp: 150,
          ),
        ),
      );

      expect(result.decision.type, LocalSchedulerDecisionType.multipvProbe);
      expect(result.status, LocalSchedulerExecutionStatus.fastCompleted);
      expect(eval.calls.single.multiPv, 2);
      expect(result.plannedMultiPv, 2);
      expect(result.executedMultiPv, 2);
      expect(result.telemetry.multiPvCalls, 1);
    });

    test('low-power input executes reduced budget only', () async {
      final eval = _FakeLocalEvalService();
      final executor = LocalSmartAnalysisExecutor(eval: eval);

      final result = await executor.execute(
        const LocalSchedulerExecutionRequest(
          profile: LocalSchedulerProfile.owner,
          input: LocalAnalysisPositionInput(
            fen: _fen,
            legalMoveCount: 42,
            candidateEvalSpreadCp: 300,
            lowPowerMode: true,
          ),
        ),
      );

      expect(result.decision.type, LocalSchedulerDecisionType.lowPowerFastOnly);
      expect(result.status, LocalSchedulerExecutionStatus.fastCompleted);
      expect(eval.calls.single.depth, lessThanOrEqualTo(8));
      expect(eval.calls.single.movetime.inMilliseconds, lessThanOrEqualTo(50));
      expect(eval.calls.single.multiPv, 1);
    });

    test('eco profile never executes deep search', () async {
      final eval = _FakeLocalEvalService();
      final executor = LocalSmartAnalysisExecutor(eval: eval);

      final result = await executor.execute(
        const LocalSchedulerExecutionRequest(
          profile: LocalSchedulerProfile.eco,
          input: LocalAnalysisPositionInput(
            fen: _fen,
            legalMoveCount: 40,
            materialDeltaAfterMoveCp: -400,
            givesCheck: true,
          ),
        ),
      );

      expect(result.status, LocalSchedulerExecutionStatus.fastCompleted);
      expect(eval.calls, hasLength(1));
      expect(eval.calls.single.depth, LocalSchedulerProfile.eco.fastDepth);
      expect(eval.calls.single.multiPv, 1);
      expect(result.telemetry.deepCalls, 0);
    });

    test('owner profile can execute stronger finite budget', () async {
      final eval = _FakeLocalEvalService();
      final executor = LocalSmartAnalysisExecutor(eval: eval);

      final result = await executor.execute(
        const LocalSchedulerExecutionRequest(
          profile: LocalSchedulerProfile.owner,
          input: LocalAnalysisPositionInput(fen: _fen),
        ),
      );

      expect(result.status, LocalSchedulerExecutionStatus.fastCompleted);
      expect(eval.calls.single.depth, LocalSchedulerProfile.owner.fastDepth);
      expect(
        eval.calls.single.movetime,
        LocalSchedulerProfile.owner.fastMovetime,
      );
      expect(
        eval.calls.single.depth,
        lessThanOrEqualTo(LocalSchedulerProfile.owner.maxDepth),
      );
      expect(
        eval.calls.single.movetime.inMilliseconds,
        lessThanOrEqualTo(
          LocalSchedulerProfile.owner.deepMovetime.inMilliseconds,
        ),
      );
    });
  });

  group('LocalSmartAnalysisExecutor failure and warning behavior', () {
    test('engine failure returns safe failed result', () async {
      final eval = _FakeLocalEvalService(
        plans: [_FakeEvalPlan.error(EvalError.offline)],
      );
      final executor = LocalSmartAnalysisExecutor(eval: eval);

      final result = await executor.execute(
        const LocalSchedulerExecutionRequest(
          input: LocalAnalysisPositionInput(fen: _fen),
        ),
      );

      expect(result.status, LocalSchedulerExecutionStatus.failed);
      expect(result.failureCode, 'engine_offline');
      expect(result.fastError, EvalError.offline);
      expect(result.engineCallCount, 1);
    });

    test('timeout returns safe failure and increments telemetry', () async {
      final eval = _FakeLocalEvalService(plans: [_FakeEvalPlan.timeout()]);
      final executor = LocalSmartAnalysisExecutor(eval: eval);

      final result = await executor.execute(
        const LocalSchedulerExecutionRequest(
          input: LocalAnalysisPositionInput(fen: _fen),
          timeoutBudgetOverride: Duration(milliseconds: 1),
        ),
      );

      expect(result.status, LocalSchedulerExecutionStatus.failed);
      expect(result.failureCode, 'engine_timeout');
      expect(result.telemetry.timeoutCount, 1);
      expect(result.warnings.single, contains('timed out'));
    });

    test('missing PV or bestmove produces warning without crash', () async {
      final eval = _FakeLocalEvalService(
        plans: [
          _FakeEvalPlan.snapshot(_snapshot(bestMove: null, pv: const [])),
        ],
      );
      final executor = LocalSmartAnalysisExecutor(eval: eval);

      final result = await executor.execute(
        const LocalSchedulerExecutionRequest(
          input: LocalAnalysisPositionInput(fen: _fen),
        ),
      );

      expect(result.status, LocalSchedulerExecutionStatus.fastCompleted);
      expect(result.warnings, contains('fastPass: missing bestmove'));
      expect(result.warnings, contains('fastPass: missing pv'));
      expect(result.telemetry.warningCount, 2);
    });

    test('execution never exceeds planned profile caps', () async {
      final eval = _FakeLocalEvalService();
      final executor = LocalSmartAnalysisExecutor(eval: eval);

      final result = await executor.execute(
        const LocalSchedulerExecutionRequest(
          profile: LocalSchedulerProfile.owner,
          input: LocalAnalysisPositionInput(
            fen: _fen,
            legalMoveCount: 45,
            candidateEvalSpreadCp: 320,
            givesCheck: true,
          ),
        ),
      );

      expect(result.status, LocalSchedulerExecutionStatus.deepCompleted);
      for (final call in eval.calls) {
        expect(
          call.depth,
          lessThanOrEqualTo(LocalSchedulerProfile.owner.maxDepth),
        );
        expect(
          call.multiPv,
          lessThanOrEqualTo(LocalSchedulerProfile.owner.maxMultiPv),
        );
        expect(
          call.movetime.inMilliseconds,
          lessThanOrEqualTo(
            LocalSchedulerProfile.owner.deepMovetime.inMilliseconds,
          ),
        );
      }
      expect(result.telemetry.budgetViolationCount, 0);
    });
  });

  group('LocalSmartAnalysisExecutor batch execution', () {
    test('batch execution is serial', () async {
      final eval = _FakeLocalEvalService(
        plans: [
          _FakeEvalPlan.dynamicSuccess(delay: const Duration(milliseconds: 5)),
          _FakeEvalPlan.dynamicSuccess(delay: const Duration(milliseconds: 5)),
          _FakeEvalPlan.dynamicSuccess(delay: const Duration(milliseconds: 5)),
        ],
      );
      final executor = LocalSmartAnalysisExecutor(eval: eval);

      final result = await executor.executeBatch([
        const LocalSchedulerExecutionRequest(
          input: LocalAnalysisPositionInput(fen: _fen),
        ),
        const LocalSchedulerExecutionRequest(
          input: LocalAnalysisPositionInput(fen: _fen),
        ),
        const LocalSchedulerExecutionRequest(
          input: LocalAnalysisPositionInput(fen: _fen),
        ),
      ]);

      expect(result.results, hasLength(3));
      expect(eval.maxConcurrentCalls, 1);
      expect(eval.calls.map((call) => call.sequence), [1, 2, 3]);
    });

    test('batch telemetry counts skipped, fast, deep, and failures', () async {
      final eval = _FakeLocalEvalService(
        plans: [
          _FakeEvalPlan.dynamicSuccess(),
          _FakeEvalPlan.dynamicSuccess(),
          _FakeEvalPlan.dynamicSuccess(),
          _FakeEvalPlan.error(EvalError.serverError),
        ],
      );
      final executor = LocalSmartAnalysisExecutor(eval: eval);

      final result = await executor.executeBatch([
        const LocalSchedulerExecutionRequest(
          input: LocalAnalysisPositionInput(fen: _fen, isOpeningKnown: true),
        ),
        const LocalSchedulerExecutionRequest(
          input: LocalAnalysisPositionInput(fen: _fen),
        ),
        const LocalSchedulerExecutionRequest(
          input: LocalAnalysisPositionInput(
            fen: _fen,
            materialDeltaAfterMoveCp: -300,
            isCapture: true,
          ),
        ),
        const LocalSchedulerExecutionRequest(
          input: LocalAnalysisPositionInput(fen: _fen),
        ),
      ]);

      expect(result.results.map((r) => r.status), [
        LocalSchedulerExecutionStatus.skipped,
        LocalSchedulerExecutionStatus.fastCompleted,
        LocalSchedulerExecutionStatus.deepCompleted,
        LocalSchedulerExecutionStatus.failed,
      ]);
      expect(result.telemetry.positionsPlanned, 4);
      expect(result.telemetry.positionsSkipped, 1);
      expect(result.telemetry.engineCalls, 4);
      expect(result.telemetry.fastCalls, 3);
      expect(result.telemetry.deepCalls, 1);
      expect(result.telemetry.warningCount, 1);
    });
  });

  group('LocalSmartAnalysisExecutor source guardrails', () {
    test(
      'executor source stays on local eval seam and avoids forbidden layers',
      () {
        final source = File(
          'lib/features/pgn_review/application/local_smart_analysis_executor.dart',
        ).readAsStringSync();
        final imports = source
            .split('\n')
            .where((line) => line.trimLeft().startsWith('import '))
            .join('\n');

        expect(imports, contains('local_eval_service.dart'));
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
      },
    );
  });
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

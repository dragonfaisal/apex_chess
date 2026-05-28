import 'dart:async';

import 'package:apex_chess/core/infrastructure/engine/engine.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/local_engine_audit.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/local_stockfish_benchmark.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalStockfishBenchmarkReport', () {
    test('renders deterministic safe report output', () {
      const report = LocalStockfishBenchmarkReport(
        engineMode: LocalEngineRuntimeMode.real,
        platform: 'test',
        targetPositionsCount: 1,
        multiPvSupported: true,
        warnings: ['sample warning'],
        nextRecommendation: 'sample recommendation',
        engineName: 'Stockfish test',
        bridgeVersion: 'bridge/test',
        results: [
          BenchmarkResult(
            positionLabel: 'startpos',
            targetLabel: 'depth 10',
            elapsedMs: 42,
            parsedDepth: 10,
            scoreType: BenchmarkScoreType.cp,
            scoreCp: 23,
            nodes: 1000,
            nps: 2000,
            multipvLineCount: 3,
            bestMove: 'e2e4',
            pv: ['e2e4', 'e7e5'],
          ),
        ],
      );

      final rendered = report.render();
      expect(rendered, startsWith('# Apex Local Stockfish Benchmark'));
      expect(rendered, contains('engine mode: real'));
      expect(rendered, contains('average elapsed ms: 42.0'));
      expect(rendered, contains('max elapsed ms: 42'));
      expect(rendered, contains('score=cp 23'));
      expect(rendered, contains('MultiPV support: yes'));
      expect(
        rendered,
        contains('Android benchmark status: unproven by host command'),
      );
      expect(rendered, contains('sample recommendation'));
    });

    test('renders Android benchmark rows from pasted device data safely', () {
      const rows = [
        AndroidStockfishBenchmarkRow(
          deviceLabel: 'Pixel test',
          abi: 'arm64-v8a',
          positionLabel: 'startpos',
          targetLabel: 'movetime 100ms',
          multiPv: 3,
          elapsedMs: 112,
          parsedDepth: 9,
          nodes: 12345,
          nps: 111000,
          scoreType: BenchmarkScoreType.cp,
          scoreCp: 25,
          pvCount: 3,
        ),
      ];

      final rendered = AndroidStockfishBenchmarkRow.renderMarkdownTable(rows);

      expect(rendered, contains('| Device | ABI | Position |'));
      expect(rendered, contains('| Pixel test | arm64-v8a | startpos |'));
      expect(rendered, contains('cp 25'));
      expect(rendered, contains('movetime 100ms'));
    });
  });

  group('LocalStockfishBenchmarkRunner', () {
    test(
      'runs a small fake real-engine benchmark and keeps MultiPV lines',
      () async {
        final engine = _FakeBenchmarkEngine(
          engineName: 'Stockfish 17 test',
          supportsMultiPv: true,
          infos: const [
            EngineInfo(
              depth: 10,
              multipv: 1,
              scoreCp: 31,
              nodes: 1000,
              nps: 2000,
              pv: ['e2e4', 'e7e5'],
            ),
            EngineInfo(
              depth: 10,
              multipv: 2,
              scoreCp: 20,
              nodes: 900,
              nps: 1800,
              pv: ['d2d4', 'd7d5'],
            ),
            EngineInfo(
              depth: 10,
              multipv: 3,
              scoreCp: 8,
              nodes: 850,
              nps: 1700,
              pv: ['g1f3', 'g8f6'],
            ),
          ],
          bestMove: 'e2e4',
        );
        final runner = LocalStockfishBenchmarkRunner(
          engine: engine,
          positions: const [BenchmarkPosition.start],
          targets: const [BenchmarkTarget.depth(10)],
        );

        final report = await runner.run();

        expect(report.engineMode, LocalEngineRuntimeMode.real);
        expect(report.multiPvSupported, isTrue);
        expect(report.results, hasLength(1));
        expect(report.results.single.parsedDepth, 10);
        expect(report.results.single.scoreType, BenchmarkScoreType.cp);
        expect(report.results.single.multipvLineCount, 3);
        expect(report.results.single.bestMove, 'e2e4');
        expect(engine.commands.map((c) => c.toUci()), contains('go depth 10'));
        expect(
          engine.commands.map((c) => c.toUci()),
          contains('setoption name MultiPV value 3'),
        );
      },
    );

    test('does not fake success when UCI id reports a stub', () async {
      final engine = _FakeBenchmarkEngine(
        engineName: 'ApexChess-Stub',
        supportsMultiPv: false,
        infos: const [
          EngineInfo(depth: 1, scoreCp: 0, nodes: 1, nps: 1, pv: ['e2e4']),
        ],
        bestMove: 'e2e4',
      );
      final runner = LocalStockfishBenchmarkRunner(
        engine: engine,
        positions: const [BenchmarkPosition.start],
        targets: const [BenchmarkTarget.movetime(50)],
      );

      final report = await runner.run();

      expect(report.engineMode, LocalEngineRuntimeMode.stubDetected);
      expect(report.results, isEmpty);
      expect(
        report.warnings,
        contains('UCI id reports a stub engine; full benchmark not run.'),
      );
    });
  });

  group(
    'optional real-engine smoke',
    skip: isStockfishBridgeLoadableForCurrentPlatform()
        ? null
        : 'stockfish_bridge is unavailable on this host loader path',
    () {
      test(
        'verifies uciok, readyok, and a legal-looking startpos bestmove',
        () async {
          final engine = StockfishEngine();
          await engine.start();
          addTearDown(engine.dispose);

          final uciOk = Completer<void>();
          final readyOk = Completer<void>();
          final bestMove = Completer<EngineBestMove>();
          final infos = <EngineInfo>[];
          final sub = engine.events.listen((event) {
            if (event is EngineUciOk && !uciOk.isCompleted) uciOk.complete();
            if (event is EngineReadyOk && !readyOk.isCompleted) {
              readyOk.complete();
            }
            if (event is EngineInfo) infos.add(event);
            if (event is EngineBestMove && !bestMove.isCompleted) {
              bestMove.complete(event);
            }
          });
          addTearDown(sub.cancel);

          engine
            ..send(const UciHandshake())
            ..send(const UciIsReady())
            ..send(const UciNewGame())
            ..send(const UciPosition.startpos())
            ..send(const UciGo.depth(4));

          await uciOk.future.timeout(const Duration(seconds: 8));
          await readyOk.future.timeout(const Duration(seconds: 8));
          final best = await bestMove.future.timeout(
            const Duration(seconds: 12),
          );

          expect(
            RegExp(r'^[a-h][1-8][a-h][1-8][qrbn]?$').hasMatch(best.move),
            isTrue,
          );
          expect(infos, isNotEmpty);
        },
      );

      test('verifies tactical FEN returns a non-empty PV', () async {
        final engine = StockfishEngine();
        await engine.start();
        addTearDown(engine.dispose);

        final bestMove = Completer<EngineBestMove>();
        final infos = <EngineInfo>[];
        final sub = engine.events.listen((event) {
          if (event is EngineInfo) infos.add(event);
          if (event is EngineBestMove && !bestMove.isCompleted) {
            bestMove.complete(event);
          }
        });
        addTearDown(sub.cancel);

        engine
          ..send(const UciHandshake())
          ..send(const UciIsReady())
          ..send(const UciNewGame())
          ..send(UciPosition.fen(BenchmarkPosition.tacticalMiddlegame.fen))
          ..send(const UciGo.depth(6));

        await bestMove.future.timeout(const Duration(seconds: 15));
        expect(infos.where((info) => info.pv.isNotEmpty), isNotEmpty);
      });

      test('verifies MultiPV smoke when supported', () async {
        final runner = LocalStockfishBenchmarkRunner(
          positions: const [BenchmarkPosition.start],
          targets: const [BenchmarkTarget.depth(6)],
        );
        final report = await runner.run();

        if (!report.multiPvSupported) {
          markTestSkipped('engine did not advertise MultiPV');
        }
        expect(report.results.single.multipvLineCount, greaterThanOrEqualTo(2));
      });
    },
  );
}

class _FakeBenchmarkEngine implements ChessEngine {
  _FakeBenchmarkEngine({
    required this.engineName,
    required this.supportsMultiPv,
    required this.infos,
    required this.bestMove,
  });

  final String engineName;
  final bool supportsMultiPv;
  final List<EngineInfo> infos;
  final String bestMove;
  final commands = <UciCommand>[];
  final _events = StreamController<EngineEvent>.broadcast();

  @override
  Stream<EngineEvent> get events => _events.stream;

  @override
  String get bridgeVersion => 'fake-bridge/benchmark';

  @override
  bool isRunning = false;

  @override
  Future<void> start() async {
    isRunning = true;
  }

  @override
  void send(UciCommand command) {
    commands.add(command);
    if (command is UciHandshake) {
      scheduleMicrotask(() {
        _events
          ..add(EngineId(name: engineName))
          ..add(const EngineOption(name: 'Hash', type: 'spin'));
        if (supportsMultiPv) {
          _events.add(
            const EngineOption(
              name: 'MultiPV',
              type: 'spin',
              defaultValue: '1',
              min: 1,
              max: 256,
            ),
          );
        }
        _events.add(const EngineUciOk());
      });
    } else if (command is UciIsReady) {
      scheduleMicrotask(() => _events.add(const EngineReadyOk()));
    } else if (command is UciGo) {
      scheduleMicrotask(() {
        for (final info in infos) {
          _events.add(info);
        }
        _events.add(EngineBestMove(move: bestMove));
      });
    }
  }

  @override
  void sendRaw(String line) => send(UciRaw(line));

  @override
  void stop() => send(const UciStop());

  @override
  Future<void> dispose() async {
    isRunning = false;
    await _events.close();
  }
}

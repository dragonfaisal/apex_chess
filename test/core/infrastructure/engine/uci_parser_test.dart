import 'package:apex_chess/core/infrastructure/engine/uci/uci_event.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseUciLine', () {
    test('parses uciok', () {
      expect(parseUciLine('uciok'), isA<EngineUciOk>());
    });

    test('parses readyok', () {
      expect(parseUciLine('readyok'), isA<EngineReadyOk>());
    });

    test('parses id name', () {
      final event = parseUciLine('id name Stockfish 17');
      expect(event, isA<EngineId>());
      expect((event as EngineId).name, 'Stockfish 17');
    });

    test('parses id author', () {
      final event = parseUciLine('id author T. Romstad');
      expect(event, isA<EngineId>());
      expect((event as EngineId).author, 'T. Romstad');
    });

    test('parses option with min/max/default', () {
      final event = parseUciLine(
        'option name Hash type spin default 16 min 1 max 33554432',
      );
      expect(event, isA<EngineOption>());
      final opt = event as EngineOption;
      expect(opt.name, 'Hash');
      expect(opt.type, 'spin');
      expect(opt.defaultValue, '16');
      expect(opt.min, 1);
      expect(opt.max, 33554432);
    });

    test('parses bestmove with ponder', () {
      final event = parseUciLine('bestmove e2e4 ponder e7e5');
      expect(event, isA<EngineBestMove>());
      final best = event as EngineBestMove;
      expect(best.move, 'e2e4');
      expect(best.ponder, 'e7e5');
    });

    test('parses bestmove without ponder', () {
      final event = parseUciLine('bestmove g1f3');
      expect((event as EngineBestMove).move, 'g1f3');
      expect(event.ponder, isNull);
    });

    test('parses info with depth, cp score, and pv', () {
      final event = parseUciLine(
        'info depth 14 seldepth 22 multipv 1 score cp 35 nodes 123456 '
        'nps 987654 time 250 pv e2e4 e7e5 g1f3 b8c6',
      );
      expect(event, isA<EngineInfo>());
      final info = event as EngineInfo;
      expect(info.depth, 14);
      expect(info.seldepth, 22);
      expect(info.multipv, 1);
      expect(info.scoreCp, 35);
      expect(info.scoreMate, isNull);
      expect(info.nodes, 123456);
      expect(info.nps, 987654);
      expect(info.time, const Duration(milliseconds: 250));
      expect(info.pv, ['e2e4', 'e7e5', 'g1f3', 'b8c6']);
    });

    test('parses info with mate score', () {
      final event =
          parseUciLine('info depth 5 score mate 3 nodes 42 pv e2e4 e7e5 d1h5');
      final info = event as EngineInfo;
      expect(info.scoreCp, isNull);
      expect(info.scoreMate, 3);
      expect(info.pv, ['e2e4', 'e7e5', 'd1h5']);
    });

    test('parses info with score bound', () {
      final event = parseUciLine(
        'info depth 10 score cp 120 upperbound nodes 1000',
      );
      final info = event as EngineInfo;
      expect(info.scoreCp, 120);
      expect(info.scoreBound, 'upperbound');
      expect(info.nodes, 1000);
    });

    test('parses info string (free-form tail)', () {
      final event = parseUciLine(
        'info string NNUE evaluation using nn-abc.nnue',
      );
      final info = event as EngineInfo;
      expect(info.string, 'NNUE evaluation using nn-abc.nnue');
    });

    test('unknown lines fall through to EngineRawLine', () {
      final event = parseUciLine('something unexpected');
      expect(event, isA<EngineRawLine>());
      expect((event as EngineRawLine).line, 'something unexpected');
    });
  });
}

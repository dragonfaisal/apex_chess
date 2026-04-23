import 'package:apex_chess/core/infrastructure/engine/uci/uci_command.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UciCommand.toUci', () {
    test('handshake', () {
      expect(const UciHandshake().toUci(), 'uci');
    });

    test('isready / ucinewgame / stop / quit', () {
      expect(const UciIsReady().toUci(), 'isready');
      expect(const UciNewGame().toUci(), 'ucinewgame');
      expect(const UciStop().toUci(), 'stop');
      expect(const UciQuit().toUci(), 'quit');
    });

    test('setoption with value', () {
      expect(
        const UciSetOption(name: 'Hash', value: '256').toUci(),
        'setoption name Hash value 256',
      );
    });

    test('setoption without value (button)', () {
      expect(
        const UciSetOption(name: 'Clear Hash').toUci(),
        'setoption name Clear Hash',
      );
    });

    test('position startpos', () {
      expect(const UciPosition.startpos().toUci(), 'position startpos');
    });

    test('position startpos with moves', () {
      expect(
        const UciPosition.startpos(moves: ['e2e4', 'e7e5']).toUci(),
        'position startpos moves e2e4 e7e5',
      );
    });

    test('position fen', () {
      const fen =
          'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
      expect(
        const UciPosition.fen(fen, moves: ['e2e4']).toUci(),
        'position fen $fen moves e2e4',
      );
    });

    test('go depth', () {
      expect(const UciGo.depth(14).toUci(), 'go depth 14');
    });

    test('go movetime', () {
      expect(
        const UciGo.movetime(Duration(milliseconds: 500)).toUci(),
        'go movetime 500',
      );
    });

    test('go infinite', () {
      expect(const UciGo.infinite().toUci(), 'go infinite');
    });

    test('go with clock and increments', () {
      const cmd = UciGo(
        wtime: Duration(seconds: 300),
        btime: Duration(seconds: 300),
        winc: Duration(seconds: 2),
        binc: Duration(seconds: 2),
      );
      expect(
        cmd.toUci(),
        'go wtime 300000 btime 300000 winc 2000 binc 2000',
      );
    });

    test('raw escape hatch', () {
      expect(const UciRaw('d').toUci(), 'd');
    });
  });
}

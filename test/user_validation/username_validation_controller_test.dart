import 'package:apex_chess/features/user_validation/data/username_validator.dart';
import 'package:apex_chess/features/user_validation/presentation/username_validation_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

UsernameValidator _makeValidator(
  Future<http.Response> Function(http.Request req) handler,
) =>
    UsernameValidator(client: MockClient((req) => handler(req)));

void main() {
  group('UsernameValidator', () {
    test('200 on chess.com → exists', () async {
      final v = _makeValidator(
          (_) async => http.Response('{"username":"hikaru"}', 200));
      expect(await v.check(source: 'chess.com', username: 'hikaru'),
          UsernameExistence.exists);
    });

    test('404 → missing', () async {
      final v = _makeValidator((_) async => http.Response('nope', 404));
      expect(await v.check(source: 'lichess', username: 'ghost'),
          UsernameExistence.missing);
    });

    test('lichess closed account → missing', () async {
      final v = _makeValidator(
          (_) async => http.Response('{"id":"x","closed":true}', 200));
      expect(await v.check(source: 'lichess', username: 'x'),
          UsernameExistence.missing);
    });

    test('500 → unknown (stays neutral, never false-accuses)', () async {
      final v = _makeValidator((_) async => http.Response('oops', 500));
      expect(await v.check(source: 'chess.com', username: 'a'),
          UsernameExistence.unknown);
    });

    test('empty username short-circuits to unknown', () async {
      final v = _makeValidator((_) async => http.Response('nope', 404));
      expect(await v.check(source: 'chess.com', username: '  '),
          UsernameExistence.unknown);
    });

    test('unknown source → unknown without network call', () async {
      var called = false;
      final v = _makeValidator((_) async {
        called = true;
        return http.Response('ok', 200);
      });
      expect(await v.check(source: 'yahoo', username: 'foo'),
          UsernameExistence.unknown);
      expect(called, isFalse);
    });
  });

  group('UsernameValidationController', () {
    test('< 2 chars keeps state idle (no network call)', () {
      var called = 0;
      final v = _makeValidator((_) async {
        called++;
        return http.Response('ok', 200);
      });
      final c = UsernameValidationController(v);
      c.updateInput(source: 'chess.com', username: 'a');
      expect(c.value.phase, ValidationPhase.idle);
      expect(called, 0);
    });

    test('rapid keystrokes only fire the last query (debounce + gen guard)',
        () async {
      final seen = <String>[];
      final v = _makeValidator((req) async {
        seen.add(req.url.path);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return http.Response('ok', 200);
      });
      final c = UsernameValidationController(v);
      c.updateInput(source: 'chess.com', username: 'hi');
      c.updateInput(source: 'chess.com', username: 'hik');
      c.updateInput(source: 'chess.com', username: 'hika');
      c.updateInput(source: 'chess.com', username: 'hikaru');
      // Wait for debounce (400ms) + the 20ms mock delay.
      await Future<void>.delayed(const Duration(milliseconds: 550));
      expect(seen, ['/pub/player/hikaru']);
      expect(c.value.existence, UsernameExistence.exists);
      expect(c.value.query, 'hikaru');
    });

    test('clearing field after a resolved result resets to idle', () async {
      final v = _makeValidator((_) async => http.Response('ok', 200));
      final c = UsernameValidationController(v);
      c.updateInput(source: 'chess.com', username: 'hikaru');
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(c.value.phase, ValidationPhase.result);
      c.updateInput(source: 'chess.com', username: '');
      expect(c.value.phase, ValidationPhase.idle);
    });
  });
}

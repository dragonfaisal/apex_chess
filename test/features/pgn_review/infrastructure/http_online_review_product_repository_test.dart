import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/core/network/apex_http_client.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_repository.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/http_online_review_product_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const pgn = '1. e4 *';

  group('HttpOnlineReviewProductRepository requests', () {
    test('serializes onlineFast requests to the product endpoint', () async {
      final client = _RecordingHttpClient(
        (_, _, _, _) async =>
            _fixtureResponse('success/success_fast_minimal.json'),
      );
      final repository = _repository(client);

      await repository.analyze(
        const ApexOnlineReviewRequest(
          pgn: pgn,
          mode: ApexOnlineReviewMode.onlineFast,
          maxPlies: 40,
          includeDebug: false,
          requestedDepth: 12,
          requestedMultiPv: 2,
        ),
      );

      expect(
        client.lastUri,
        Uri.parse('https://example.test/analysis/dev/online-review-product'),
      );
      expect(client.lastBody, {
        'pgn': pgn,
        'mode': 'onlineFast',
        'depth': 12,
        'multipv': 2,
        'maxPlies': 40,
        'includeDebug': false,
        'movetimeMs': null,
        'stopOnError': false,
      });
      expect(client.lastHeaders!['Accept'], 'application/json');
      expect(client.lastHeaders!['Content-Type'], 'application/json');
      expect(
        client.lastBody!.keys,
        isNot(contains('classifierExperimentLedger')),
      );
      expect(client.lastBody!.keys, isNot(contains('reanalysisEnvelope')));
    });

    test('preserves onlineDeep and dev mode serialization', () async {
      final client = _RecordingHttpClient((_, body, _, _) async {
        return body['mode'] == 'onlineDeep'
            ? _fixtureResponse('success/success_deep_with_criticality.json')
            : _fixtureResponse('debug/debug_enabled_compact.json');
      });
      final repository = _repository(client);

      final deep = await repository.analyze(
        const ApexOnlineReviewRequest(
          pgn: pgn,
          mode: ApexOnlineReviewMode.onlineDeep,
        ),
      );
      expect(client.lastBody!['mode'], 'onlineDeep');
      expect(deep.review!.mode, ApexOnlineReviewMode.onlineDeep);

      final dev = await repository.analyze(
        const ApexOnlineReviewRequest(
          pgn: pgn,
          mode: ApexOnlineReviewMode.dev,
          includeDebug: true,
        ),
      );
      expect(client.lastBody!['mode'], 'dev');
      expect(client.lastBody!['includeDebug'], isTrue);
      expect(dev.review!.mode, ApexOnlineReviewMode.dev);
      expect(dev.review!.hasDebug, isTrue);
    });
  });

  group('HttpOnlineReviewProductRepository responses', () {
    test('maps success payloads into domain review results', () async {
      final repository = _repository(
        _RecordingHttpClient(
          (_, _, _, _) async =>
              _fixtureResponse('success/success_fast_minimal.json'),
        ),
      );

      final result = await repository.analyze(
        const ApexOnlineReviewRequest(
          pgn: pgn,
          mode: ApexOnlineReviewMode.onlineFast,
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.review, isA<ApexOnlineReview>());
      expect(result.failure, isNull);
      expect(result.review!.mode, ApexOnlineReviewMode.onlineFast);
      expect(result.review!.summary.totalPlies, 1);
      expect(result.review!.moves, hasLength(1));
    });

    test('maps backend product failures safely', () async {
      final repository = _repository(
        _RecordingHttpClient(
          (_, _, _, _) async =>
              _fixtureResponse('failure/failure_invalid_pgn.json'),
        ),
      );

      final result = await repository.analyze(
        const ApexOnlineReviewRequest(
          pgn: 'not a pgn',
          mode: ApexOnlineReviewMode.onlineFast,
        ),
      );

      expect(result.isSuccess, isFalse);
      expect(result.failure!.code, 'invalidPgn');
      expect(result.failure!.message, 'Invalid PGN');
      expect(result.failure!.source, 'backend');
      expect(result.review, isNotNull);
      expect(result.review!.status, ApexReviewStatus.failed);
      expect(result.review!.moves, isEmpty);
    });

    test('maps non-2xx responses without exposing raw body text', () async {
      final repository = _repository(
        _RecordingHttpClient(
          (_, _, _, _) async => const ApexHttpResponse(
            statusCode: 500,
            body: 'stack trace: internal path and noisy body',
          ),
        ),
      );

      final result = await repository.analyze(
        const ApexOnlineReviewRequest(
          pgn: pgn,
          mode: ApexOnlineReviewMode.onlineFast,
        ),
      );

      expect(result.isSuccess, isFalse);
      expect(result.failure!.code, 'httpStatus');
      expect(result.failure!.source, 'http');
      expect(result.failure!.isRetryable, isTrue);
      expect(result.failure!.message, contains('HTTP 500'));
      expect(result.failure!.message, isNot(contains('stack trace')));
    });

    test('maps timeouts safely', () async {
      final repository = _repository(
        _RecordingHttpClient((_, _, _, _) async {
          throw TimeoutException('slow');
        }),
      );

      final result = await repository.analyze(
        const ApexOnlineReviewRequest(
          pgn: pgn,
          mode: ApexOnlineReviewMode.onlineFast,
        ),
      );

      expect(result.failure!.code, 'timeout');
      expect(result.failure!.source, 'network');
      expect(result.failure!.isRetryable, isTrue);
    });

    test('maps network exceptions safely', () async {
      final repository = _repository(
        _RecordingHttpClient((_, _, _, _) async {
          throw const SocketException('connection refused');
        }),
      );

      final result = await repository.analyze(
        const ApexOnlineReviewRequest(
          pgn: pgn,
          mode: ApexOnlineReviewMode.onlineFast,
        ),
      );

      expect(result.failure!.code, 'networkError');
      expect(result.failure!.source, 'network');
      expect(result.failure!.isRetryable, isTrue);
    });

    test('maps malformed JSON as invalidJson', () async {
      final repository = _repository(
        _RecordingHttpClient(
          (_, _, _, _) async =>
              const ApexHttpResponse(statusCode: 200, body: '{ invalid json'),
        ),
      );

      final result = await repository.analyze(
        const ApexOnlineReviewRequest(
          pgn: pgn,
          mode: ApexOnlineReviewMode.onlineFast,
        ),
      );

      expect(result.failure!.code, 'invalidJson');
      expect(result.failure!.source, 'parsing');
    });

    test(
      'maps structurally invalid product JSON as contractParseError',
      () async {
        final repository = _repository(
          _RecordingHttpClient(
            (_, _, _, _) async =>
                const ApexHttpResponse(statusCode: 200, body: '{"ok":true}'),
          ),
        );

        final result = await repository.analyze(
          const ApexOnlineReviewRequest(
            pgn: pgn,
            mode: ApexOnlineReviewMode.onlineFast,
          ),
        );

        expect(result.failure!.code, 'contractParseError');
        expect(result.failure!.source, 'parsing');
      },
    );

    test(
      'ignores extra internal backend fields in successful responses',
      () async {
        final json = _fixtureJson('success/success_fast_minimal.json');
        final move = (json['moves']! as List<Object?>).first as Map;
        json['classifierExperimentLedger'] = {'isPersistent': false};
        json['classifierLedgerSchemaReviewContract'] = {
          'migrationAllowed': false,
        };
        json['reanalysisEnvelope'] = {'requests': []};
        move['classifierV2DryRun'] = {'proposedQuality': 'Miss'};
        move['mergeProposal'] = {'wouldChangeQuality': false};
        final repository = _repository(
          _RecordingHttpClient(
            (_, _, _, _) async =>
                ApexHttpResponse(statusCode: 200, body: jsonEncode(json)),
          ),
        );

        final result = await repository.analyze(
          const ApexOnlineReviewRequest(
            pgn: pgn,
            mode: ApexOnlineReviewMode.onlineFast,
          ),
        );

        expect(result.isSuccess, isTrue);
        expect(result.review!.moves.single.quality, ApexMoveQuality.best);
        expect(result.review!.summary.accuracy, isNull);
        expect(result.review!.summary.acpl, isNull);
      },
    );
  });

  group('HttpOnlineReviewProductRepository boundaries', () {
    test('implementation stays UI-free and behind the repository seam', () {
      final implementation = File(
        'lib/features/pgn_review/infrastructure/'
        'http_online_review_product_repository.dart',
      ).readAsStringSync();
      final contract = File(
        'lib/features/pgn_review/domain/online_review_product_repository.dart',
      ).readAsStringSync();

      expect(
        implementation,
        contains('implements OnlineReviewProductRepository'),
      );
      expect(implementation, isNot(contains('package:flutter/material.dart')));
      expect(implementation, isNot(contains('package:flutter/widgets.dart')));
      expect(implementation, isNot(contains('flutter_riverpod')));
      expect(implementation, isNot(contains('C:\\apex_chess_backend')));
      expect(implementation, isNot(contains('package:http')));
      expect(contract, isNot(contains('OnlineReviewProductResponseDto')));
      expect(contract, contains('final ApexOnlineReview? review;'));
    });

    test('domain product labels remain conservative', () {
      final qualities = ApexMoveQuality.values.map((value) => value.wire);

      expect(qualities, isNot(contains('Brilliant')));
      expect(qualities, isNot(contains('Great')));
      expect(qualities, isNot(contains('Miss')));
      expect(qualities, isNot(contains('Book')));
      expect(qualities, isNot(contains('Forced')));
    });
  });
}

HttpOnlineReviewProductRepository _repository(ApexHttpClient client) {
  return HttpOnlineReviewProductRepository(
    baseUri: Uri.parse('https://example.test'),
    httpClient: client,
    timeout: const Duration(seconds: 3),
  );
}

class _RecordingHttpClient extends ApexHttpClient {
  _RecordingHttpClient(this._handler);

  final Future<ApexHttpResponse> Function(
    Uri uri,
    Map<String, Object?> body,
    Map<String, String>? headers,
    Duration? timeout,
  )
  _handler;

  Uri? lastUri;
  Map<String, Object?>? lastBody;
  Map<String, String>? lastHeaders;
  Duration? lastTimeout;

  @override
  Future<ApexHttpResponse> postJson(
    Uri uri, {
    required Map<String, Object?> body,
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    lastUri = uri;
    lastBody = Map.unmodifiable(body);
    lastHeaders = headers == null ? null : Map.unmodifiable(headers);
    lastTimeout = timeout;
    return _handler(uri, body, headers, timeout);
  }
}

const _fixtureRoot = 'test/fixtures/online_review_product';

ApexHttpResponse _fixtureResponse(String path) {
  return ApexHttpResponse(statusCode: 200, body: _fixtureRaw(path));
}

String _fixtureRaw(String path) {
  return File('$_fixtureRoot/$path').readAsStringSync();
}

Map<String, Object?> _fixtureJson(String path) {
  final decoded = jsonDecode(_fixtureRaw(path));
  return (decoded as Map).map((key, value) => MapEntry(key.toString(), value));
}

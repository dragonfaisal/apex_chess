import 'dart:convert';

import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/features/pgn_review/domain/analysis_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/http_online_review_provider.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_api_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_provider.dart';
import 'package:apex_chess/features/pgn_review/domain/review_analysis_provider.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/models/review_board_display.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('configured HTTP provider submits onlineFast', () async {
    late Map<String, dynamic> body;
    final provider = _provider(
      mode: AnalysisReviewMode.onlineFast,
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/review');
        expect(request.headers['X-Apex-Api-Key'], 'dev-key');
        body = jsonDecode(request.body) as Map<String, dynamic>;
        return _jsonResponse(_queued(mode: 'onlineFast'));
      }),
    );

    final response = await provider.submitReview(_submitRequest());

    expect(body['mode'], 'onlineFast');
    expect(body['source'], 'chessCom');
    expect(body['clientGameKey'], isNotEmpty);
    expect(response.status, OnlineReviewJobStatus.queued);
    expect(response.jobId, 'job-1');
  });

  test('configured HTTP provider submits onlineDeep', () async {
    late Map<String, dynamic> body;
    final provider = _provider(
      mode: AnalysisReviewMode.onlineDeep,
      client: MockClient((request) async {
        body = jsonDecode(request.body) as Map<String, dynamic>;
        return _jsonResponse(_queued(mode: 'onlineDeep'));
      }),
    );

    final response = await provider.submitReview(
      _submitRequest(mode: AnalysisReviewMode.onlineDeep),
    );

    expect(body['mode'], 'onlineDeep');
    expect(response.status, OnlineReviewJobStatus.queued);
    expect(response.requestedMode, AnalysisReviewMode.onlineDeep);
  });

  test('queued running completed maps to completed payload', () async {
    var polls = 0;
    final offline = _NoFallbackOfflineProvider();
    final provider = _provider(
      mode: AnalysisReviewMode.onlineFast,
      client: MockClient((request) async {
        if (request.url.path.startsWith('/review/cache/')) {
          return _jsonResponse({'hit': false, 'gameKey': 'game-v1-miss'});
        }
        if (request.method == 'POST') return _jsonResponse(_queued());
        polls++;
        return _jsonResponse(
          polls == 1
              ? _running()
              : _completed(mode: 'onlineFast', gameKey: 'game-v1-backend'),
        );
      }),
    );
    final pipeline = _pipeline(fastProvider: provider, offline: offline);

    final result = await pipeline.analyzeContract(
      const GameReviewRequest(pgn: _pgn, profile: AnalysisProfile.fastReview),
    );

    expect(result.status, AnalysisProviderStatus.completed);
    expect(result.mode, AnalysisReviewMode.onlineFast);
    _expectRicherPayload(result.payload!, mode: AnalysisReviewMode.onlineFast);
    expect(offline.calls, 0);
  });

  test('cached completed response maps to payload without polling', () async {
    var postCount = 0;
    final provider = _provider(
      mode: AnalysisReviewMode.onlineDeep,
      client: MockClient((request) async {
        if (request.url.path.startsWith('/review/cache/')) {
          return _jsonResponse({
            'hit': true,
            'gameKey': 'game-v1-backend',
            'status': 'completed',
            'mode': 'onlineDeep',
            'cached': true,
            'analysis': _analysis(
              mode: 'onlineDeep',
              gameKey: 'game-v1-backend',
            ),
          });
        }
        postCount++;
        return _jsonResponse(_queued(mode: 'onlineDeep'));
      }),
    );
    final pipeline = _pipeline(deepProvider: provider);

    final result = await pipeline.analyzeContract(
      const GameReviewRequest(pgn: _pgn, profile: AnalysisProfile.deepReview),
    );

    expect(result.status, AnalysisProviderStatus.cachedHit);
    expect(result.payload!.modeUsed, AnalysisReviewMode.onlineDeep);
    expect(result.payload!.timeline!.analysisProfileId, 'deep_review');
    _expectRicherPayload(result.payload!, mode: AnalysisReviewMode.onlineDeep);
    expect(postCount, 0);
  });

  test('POST cached completed response maps to payload', () async {
    final provider = _provider(
      mode: AnalysisReviewMode.onlineFast,
      client: MockClient((request) async {
        return _jsonResponse({
          ..._completed(mode: 'onlineFast', gameKey: 'game-v1-backend'),
          'cached': true,
        });
      }),
    );

    final response = await provider.submitReview(_submitRequest());

    expect(response.status, OnlineReviewJobStatus.completed);
    _expectRicherPayload(
      response.result!.payload,
      mode: AnalysisReviewMode.onlineFast,
    );
    expect(response.result!.payload.modeUsed, AnalysisReviewMode.onlineFast);
  });

  test('failed backend response maps to safe failure', () async {
    var polls = 0;
    final provider = _provider(
      mode: AnalysisReviewMode.onlineFast,
      client: MockClient((request) async {
        if (request.url.path.startsWith('/review/cache/')) {
          return _jsonResponse({'hit': false, 'gameKey': 'game-v1-miss'});
        }
        if (request.method == 'POST') return _jsonResponse(_queued());
        polls++;
        return _jsonResponse(
          polls == 1
              ? _running()
              : {
                  'jobId': 'job-1',
                  'status': 'failed',
                  'mode': 'onlineFast',
                  'gameKey': 'game-v1-backend',
                  'progress': {'totalMoves': 2, 'analyzedMoves': 1},
                  'error': {'code': 'timeout', 'message': 'Analysis timed out'},
                },
        );
      }),
    );
    final pipeline = _pipeline(fastProvider: provider);

    final result = await pipeline.analyzeContract(
      const GameReviewRequest(pgn: _pgn, profile: AnalysisProfile.fastReview),
    );

    expect(result.status, AnalysisProviderStatus.failed);
    expect(result.failureReason, AnalysisFailureReason.timeout);
    expect(result.safeFailureCopy, 'Try again');
  });

  test('timeout maps safely', () async {
    final provider = _provider(
      mode: AnalysisReviewMode.onlineFast,
      requestTimeout: const Duration(milliseconds: 1),
      client: MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return _jsonResponse(_queued());
      }),
    );

    final response = await provider.submitReview(_submitRequest());

    expect(response.accepted, isFalse);
    expect(response.failure!.reason, AnalysisFailureReason.timeout);
  });

  test(
    'connection error maps safely and does not fall back to Offline',
    () async {
      final offline = _NoFallbackOfflineProvider();
      final provider = _provider(
        mode: AnalysisReviewMode.onlineFast,
        client: MockClient((request) async {
          throw http.ClientException('Connection refused', request.url);
        }),
      );
      final pipeline = _pipeline(fastProvider: provider, offline: offline);

      final result = await pipeline.analyzeContract(
        const GameReviewRequest(pgn: _pgn, profile: AnalysisProfile.fastReview),
      );

      expect(result.status, AnalysisProviderStatus.failed);
      expect(result.failureReason, AnalysisFailureReason.serviceUnavailable);
      expect(offline.calls, 0);
    },
  );

  test('wrong API key response maps safely', () async {
    final provider = _provider(
      mode: AnalysisReviewMode.onlineFast,
      client: MockClient((request) async {
        return _jsonResponse({
          'error': {'code': 'unauthorized', 'message': 'Invalid API key'},
        }, statusCode: 401);
      }),
    );

    final response = await provider.submitReview(_submitRequest());

    expect(response.accepted, isFalse);
    expect(response.failure!.reason, AnalysisFailureReason.serviceUnavailable);
    expect(response.failure!.providerCode, 'unauthorized');
  });

  test('invalid PGN response maps safely', () async {
    final provider = _provider(
      mode: AnalysisReviewMode.onlineFast,
      client: MockClient((request) async {
        return _jsonResponse({
          'error': {'code': 'invalidPgn', 'message': 'Invalid PGN'},
        }, statusCode: 400);
      }),
    );

    final response = await provider.submitReview(_submitRequest());

    expect(response.accepted, isFalse);
    expect(response.failure!.reason, AnalysisFailureReason.invalidPgn);
  });

  test('cancel maps backend cancelled status', () async {
    final provider = _provider(
      mode: AnalysisReviewMode.onlineFast,
      client: MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/review') {
          return _jsonResponse(_queued());
        }
        expect(request.url.path, '/review/cancel');
        return _jsonResponse({'jobId': 'job-1', 'status': 'cancelled'});
      }),
    );

    await provider.submitReview(_submitRequest());
    final cancel = await provider.cancelJob('job-1');

    expect(cancel.status, OnlineReviewJobStatus.cancelled);
    expect(cancel.failure!.reason, AnalysisFailureReason.cancelled);
  });
}

HttpOnlineReviewProvider _provider({
  required AnalysisReviewMode mode,
  required http.Client client,
  Duration requestTimeout = const Duration(seconds: 2),
}) {
  return HttpOnlineReviewProvider(
    mode: mode,
    config: OnlineReviewProviderConfig(
      providerId: mode == AnalysisReviewMode.onlineFast
          ? 'apex_backend_online_fast'
          : 'apex_backend_online_deep',
      displayName: 'Apex Backend',
      isConfigured: true,
      engineVersion: 'apex-backend-http',
      maxPollAttempts: 4,
      baseUrl: 'http://127.0.0.1:8000',
      apiKey: 'dev-key',
      requestTimeout: requestTimeout,
      pollInterval: Duration.zero,
      overallTimeout: const Duration(seconds: 5),
    ),
    httpClient: client,
  );
}

OnlineReviewSubmitRequest _submitRequest({
  AnalysisReviewMode mode = AnalysisReviewMode.onlineFast,
}) {
  return OnlineReviewSubmitRequest.fromAnalysisRequest(
    AnalysisReviewRequest.fromPgn(
      pgn: _pgn,
      requestedMode: mode,
      requestedAt: DateTime.utc(2026, 5, 9),
    ),
    submittedAt: DateTime.utc(2026, 5, 9, 1),
  );
}

GameReviewPipeline _pipeline({
  OnlineReviewProvider? fastProvider,
  OnlineReviewProvider? deepProvider,
  _NoFallbackOfflineProvider? offline,
}) {
  return GameReviewPipeline(
    fastProvider: OnlineReviewAnalysisProvider(
      onlineProvider:
          fastProvider ??
          const DisabledOnlineReviewProvider(
            config: OnlineReviewProviderConfig.unavailable,
          ),
      profile: AnalysisProfile.fastReview,
    ),
    deepProvider: OnlineReviewAnalysisProvider(
      onlineProvider:
          deepProvider ??
          const DisabledOnlineReviewProvider(
            config: OnlineReviewProviderConfig.unavailable,
          ),
      profile: AnalysisProfile.deepReview,
    ),
    offlineProvider: offline ?? _NoFallbackOfflineProvider(),
  );
}

class _NoFallbackOfflineProvider extends ReviewAnalysisProvider {
  int calls = 0;

  @override
  String get providerId => 'offline_should_not_run';

  @override
  String get engineVersion => 'test';

  @override
  bool get isConfigured => true;

  @override
  Future<GameReviewResult> analyzeGame(GameReviewRequest request) async {
    calls++;
    throw StateError('Unexpected offline fallback');
  }
}

http.Response _jsonResponse(Map<String, Object?> body, {int statusCode = 200}) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: {'content-type': 'application/json'},
  );
}

void _expectRicherPayload(
  CanonicalAnalysisPayload payload, {
  required AnalysisReviewMode mode,
}) {
  final timeline = payload.timeline!;
  expect(payload.modeUsed, mode);
  expect(payload.white.name, 'Alpha');
  expect(payload.white.rating, '1500');
  expect(payload.black.name, 'Beta');
  expect(payload.black.rating, '1510');
  expect(payload.result, '1-0');
  expect(payload.openingName, 'Mock Opening');
  expect(payload.ecoCode, 'A00');
  expect(timeline.moves, hasLength(6));
  expect(timeline.totalPlies, 6);
  expect(timeline.headers['White'], 'Alpha');
  expect(timeline.headers['Black'], 'Beta');
  expect(timeline.headers['WhiteElo'], '1500');
  expect(timeline.headers['BlackElo'], '1510');
  expect(payload.averageCpLoss, greaterThan(0));
  expect(payload.providerMetadata.engineVersion, 'mock-v2');

  final board = ReviewBoardDisplayModel.fromTimeline(
    timeline,
    currentPly: 0,
    flipped: false,
    mode: payload.reviewBoardMode,
    userIsWhite: true,
  );
  expect(board.bottomPlayer.username, 'Alpha');
  expect(board.topPlayer.username, 'Beta');
  expect(board.timeline, hasLength(6));

  final container = ProviderContainer();
  addTearDown(container.dispose);
  container
      .read(reviewControllerProvider.notifier)
      .loadPayload(payload, userIsWhite: true);
  expect(container.read(reviewControllerProvider).totalPlies, 6);
}

Map<String, Object?> _queued({String mode = 'onlineFast'}) => {
  'jobId': 'job-1',
  'status': 'queued',
  'mode': mode,
  'gameKey': 'game-v1-backend',
  'cached': false,
  'progress': {'totalMoves': 6, 'analyzedMoves': 0},
};

Map<String, Object?> _running({String mode = 'onlineFast'}) => {
  'jobId': 'job-1',
  'status': 'running',
  'mode': mode,
  'gameKey': 'game-v1-backend',
  'cached': false,
  'progress': {'totalMoves': 6, 'analyzedMoves': 3},
};

Map<String, Object?> _completed({
  String mode = 'onlineFast',
  String gameKey = 'game-v1-backend',
}) => {
  'jobId': 'job-1',
  'status': 'completed',
  'mode': mode,
  'gameKey': gameKey,
  'cached': false,
  'progress': {'totalMoves': 6, 'analyzedMoves': 6},
  'analysis': _analysis(mode: mode, gameKey: gameKey),
};

Map<String, Object?> _analysis({
  required String mode,
  required String gameKey,
}) => {
  'contractVersion': 'v2',
  'gameKey': gameKey,
  'modeUsed': mode,
  'source': 'pgn',
  'players': [
    {'side': 'white', 'name': 'Alpha', 'rating': 1500},
    {'side': 'black', 'name': 'Beta', 'rating': 1510},
  ],
  'result': '1-0',
  'opening': 'Mock Opening',
  'eco': 'A00',
  'moveQualityCounts': {'book': 2, 'good': 2, 'excellent': 1, 'inaccuracy': 1},
  'timeline': [
    {
      'ply': 1,
      'moveNumber': 1,
      'side': 'white',
      'san': 'e4',
      'uci': 'e2e4',
      'playedMoveSan': 'e4',
      'playedMoveUci': 'e2e4',
      'quality': 'book',
      'evalBeforeCp': 20,
      'evalAfterCp': 25,
      'evalLossCp': 0,
      'bestMoveSan': 'e4',
      'bestMoveUci': 'e2e4',
      'isBookMove': true,
      'comment': 'Mock book move.',
    },
    {
      'ply': 2,
      'moveNumber': 1,
      'side': 'black',
      'san': 'c5',
      'uci': 'c7c5',
      'playedMoveSan': 'c5',
      'playedMoveUci': 'c7c5',
      'quality': 'good',
      'evalBeforeCp': 25,
      'evalAfterCp': 31,
      'evalLossCp': 6,
      'bestMoveSan': 'e5',
      'bestMoveUci': 'e7e5',
      'betterMoveSan': 'e5',
      'betterMoveUci': 'e7e5',
      'isBookMove': false,
      'comment': 'Mock better move field.',
    },
    {
      'ply': 3,
      'moveNumber': 2,
      'side': 'white',
      'san': 'Nf3',
      'uci': 'g1f3',
      'playedMoveSan': 'Nf3',
      'playedMoveUci': 'g1f3',
      'quality': 'good',
      'evalBeforeCp': 31,
      'evalAfterCp': 18,
      'evalLossCp': 13,
      'bestMoveSan': 'Nc3',
      'bestMoveUci': 'b1c3',
      'isBookMove': false,
      'comment': 'This move keeps the game playable.',
    },
    {
      'ply': 4,
      'moveNumber': 2,
      'side': 'black',
      'san': 'd6',
      'uci': 'd7d6',
      'playedMoveSan': 'd6',
      'playedMoveUci': 'd7d6',
      'quality': 'excellent',
      'evalBeforeCp': 18,
      'evalAfterCp': 22,
      'evalLossCp': 4,
      'bestMoveSan': 'd6',
      'bestMoveUci': 'd7d6',
      'isBookMove': false,
      'comment': 'Mock review entry.',
    },
    {
      'ply': 5,
      'moveNumber': 3,
      'side': 'white',
      'san': 'd4',
      'uci': 'd2d4',
      'playedMoveSan': 'd4',
      'playedMoveUci': 'd2d4',
      'quality': 'good',
      'evalBeforeCp': 22,
      'evalAfterCp': 12,
      'evalLossCp': 10,
      'bestMoveSan': 'Bb5+',
      'bestMoveUci': 'f1b5',
      'isBookMove': false,
      'comment': 'This move keeps the game playable.',
    },
    {
      'ply': 6,
      'moveNumber': 3,
      'side': 'black',
      'san': 'cxd4',
      'uci': 'c5d4',
      'playedMoveSan': 'cxd4',
      'playedMoveUci': 'c5d4',
      'quality': 'inaccuracy',
      'evalBeforeCp': 12,
      'evalAfterCp': 82,
      'evalLossCp': 70,
      'bestMoveSan': 'e5',
      'bestMoveUci': 'e7e5',
      'betterMoveSan': 'e5',
      'betterMoveUci': 'e7e5',
      'isBookMove': false,
      'comment': 'Better: e5 - improves the line.',
    },
  ],
  'createdAt': '2026-05-09T16:00:00Z',
  'updatedAt': '2026-05-09T16:00:01Z',
  'providerMetadata': {
    'provider': 'mock',
    'engine': 'none',
    'analysisVersion': 'mock-v2',
    'contractVersion': 'v2',
    'generatedByMock': true,
  },
};

const _pgn = '''
[Site "https://www.chess.com/game/live/999"]
[White "Alpha"]
[Black "Beta"]
[WhiteElo "1500"]
[BlackElo "1510"]
[Result "1-0"]

1. e4 c5 2. Nf3 d6 3. d4 cxd4 1-0
''';

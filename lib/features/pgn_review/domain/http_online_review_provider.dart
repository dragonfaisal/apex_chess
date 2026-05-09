/// HTTP implementation of the Apex online review provider contract.
///
/// This client targets the local/mock Apex FastAPI backend. It owns no chess
/// analysis logic: responses are translated into the existing Analysis
/// Contract v2 payload path and all transport/backend failures become safe
/// domain failures.
library;

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/network/api_headers.dart';
import 'package:apex_chess/features/pgn_review/domain/analysis_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_api_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_provider.dart';

class HttpOnlineReviewProvider extends OnlineReviewProvider {
  HttpOnlineReviewProvider({
    required this.mode,
    required this.config,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final AnalysisReviewMode mode;
  final http.Client _httpClient;

  @override
  final OnlineReviewProviderConfig config;

  final Map<String, OnlineReviewSubmitRequest> _submittedRequests = {};

  @override
  Future<OnlineReviewSubmitResponse> submitReview(
    OnlineReviewSubmitRequest request,
  ) async {
    if (!config.isConfigured) {
      return OnlineReviewSubmitResponse.rejected(
        gameKey: request.gameKey,
        requestedMode: request.requestedMode,
        failure: const OnlineReviewFailure(
          reason: AnalysisFailureReason.providerNotConfigured,
        ),
        submittedAt: request.submittedAt,
      );
    }

    final pgn = _pgnFor(request.analysisRequest);
    if (pgn == null) {
      return OnlineReviewSubmitResponse.rejected(
        gameKey: request.gameKey,
        requestedMode: request.requestedMode,
        failure: const OnlineReviewFailure(
          reason: AnalysisFailureReason.invalidPgn,
        ),
        submittedAt: request.submittedAt,
      );
    }

    try {
      final response = await _httpClient
          .post(
            _uri('/review'),
            headers: _headers(),
            body: jsonEncode({
              'mode': _backendMode(request.requestedMode),
              'pgn': pgn,
              'sourceGameId': request.analysisRequest.sourceId,
              'clientGameKey': request.gameKey,
              'source': _backendSource(request.analysisRequest.source),
              'options': const <String, Object?>{},
            }),
          )
          .timeout(config.requestTimeout);
      final json = _decodeObject(response.body);
      if (response.statusCode != 200) {
        return OnlineReviewSubmitResponse.rejected(
          gameKey: request.gameKey,
          requestedMode: request.requestedMode,
          failure: _failureFromResponse(response.statusCode, json),
          submittedAt: request.submittedAt,
        );
      }
      final submit = _submitFromJson(json, request: request, pgn: pgn);
      final jobId = submit.jobId;
      if (jobId != null) _submittedRequests[jobId] = request;
      return submit;
    } on TimeoutException {
      return _rejectedForTransport(request, AnalysisFailureReason.timeout);
    } on http.ClientException {
      return _rejectedForTransport(
        request,
        AnalysisFailureReason.serviceUnavailable,
      );
    } catch (_) {
      return _rejectedForTransport(
        request,
        AnalysisFailureReason.serviceUnavailable,
      );
    }
  }

  @override
  Future<OnlineReviewJobSnapshot> getJob(String jobId) async {
    final request = _submittedRequests[jobId];
    final now = DateTime.now().toUtc();
    try {
      final response = await _httpClient
          .get(_uri('/review/$jobId'), headers: _headers())
          .timeout(config.requestTimeout);
      final json = _decodeObject(response.body);
      if (response.statusCode != 200) {
        return _failedSnapshot(
          jobId: jobId,
          request: request,
          failure: _failureFromResponse(response.statusCode, json),
          updatedAt: now,
        );
      }
      return _jobFromJson(json, jobId: jobId, request: request);
    } on TimeoutException {
      return _failedSnapshot(
        jobId: jobId,
        request: request,
        failure: const OnlineReviewFailure(
          reason: AnalysisFailureReason.timeout,
        ),
        updatedAt: now,
      );
    } on http.ClientException {
      return _failedSnapshot(
        jobId: jobId,
        request: request,
        failure: const OnlineReviewFailure(
          reason: AnalysisFailureReason.serviceUnavailable,
        ),
        updatedAt: now,
      );
    } catch (_) {
      return _failedSnapshot(
        jobId: jobId,
        request: request,
        failure: const OnlineReviewFailure(
          reason: AnalysisFailureReason.serviceUnavailable,
        ),
        updatedAt: now,
      );
    }
  }

  @override
  Future<OnlineReviewCacheLookupResponse> getCachedReview(
    OnlineReviewCacheLookupRequest request,
  ) async {
    if (!config.isConfigured) {
      return OnlineReviewCacheLookupResponse.unavailable(
        gameKey: request.gameKey,
        requestedMode: request.requestedMode,
      );
    }

    try {
      final backendGameKey =
          _backendGameKeyFor(request.analysisRequest) ?? request.gameKey;
      final response = await _httpClient
          .get(_uri('/review/cache/$backendGameKey'), headers: _headers())
          .timeout(config.requestTimeout);
      final json = _decodeObject(response.body);
      if (response.statusCode != 200) {
        return OnlineReviewCacheLookupResponse.failed(
          gameKey: request.gameKey,
          requestedMode: request.requestedMode,
          failure: _failureFromResponse(response.statusCode, json),
        );
      }
      if (json['hit'] == true && json['analysis'] is Map<String, Object?>) {
        final analysis = json['analysis']! as Map<String, Object?>;
        return OnlineReviewCacheLookupResponse.hit(
          gameKey: request.gameKey,
          requestedMode: request.requestedMode,
          payload: _payloadFromJson(
            analysis,
            request: request.analysisRequest,
            clientGameKey: request.gameKey,
          ),
        );
      }
      return OnlineReviewCacheLookupResponse.miss(
        gameKey: request.gameKey,
        requestedMode: request.requestedMode,
      );
    } on TimeoutException {
      return OnlineReviewCacheLookupResponse.failed(
        gameKey: request.gameKey,
        requestedMode: request.requestedMode,
        failure: const OnlineReviewFailure(
          reason: AnalysisFailureReason.timeout,
        ),
      );
    } on http.ClientException {
      return OnlineReviewCacheLookupResponse.failed(
        gameKey: request.gameKey,
        requestedMode: request.requestedMode,
        failure: const OnlineReviewFailure(
          reason: AnalysisFailureReason.serviceUnavailable,
        ),
      );
    } catch (_) {
      return OnlineReviewCacheLookupResponse.failed(
        gameKey: request.gameKey,
        requestedMode: request.requestedMode,
        failure: const OnlineReviewFailure(
          reason: AnalysisFailureReason.serviceUnavailable,
        ),
      );
    }
  }

  @override
  Future<OnlineReviewJobSnapshot> cancelJob(String jobId) async {
    final request = _submittedRequests[jobId];
    final now = DateTime.now().toUtc();
    if (!config.isConfigured) {
      return _failedSnapshot(
        jobId: jobId,
        request: request,
        failure: const OnlineReviewFailure(
          reason: AnalysisFailureReason.providerNotConfigured,
        ),
        updatedAt: now,
      );
    }
    try {
      final response = await _httpClient
          .post(
            _uri('/review/cancel'),
            headers: _headers(),
            body: jsonEncode({'jobId': jobId}),
          )
          .timeout(config.requestTimeout);
      final json = _decodeObject(response.body);
      if (response.statusCode != 200) {
        return _failedSnapshot(
          jobId: jobId,
          request: request,
          failure: _failureFromResponse(response.statusCode, json),
          updatedAt: now,
        );
      }
      return OnlineReviewJobSnapshot(
        jobId: jobId,
        gameKey: request?.gameKey ?? json['jobId']?.toString() ?? '',
        requestedMode: request?.requestedMode ?? mode,
        status: _statusFromWire(json['status']?.toString()),
        submittedAt: request?.submittedAt ?? now,
        updatedAt: now,
        failure: const OnlineReviewFailure(
          reason: AnalysisFailureReason.cancelled,
          retryable: false,
        ),
      );
    } on TimeoutException {
      return _failedSnapshot(
        jobId: jobId,
        request: request,
        failure: const OnlineReviewFailure(
          reason: AnalysisFailureReason.timeout,
        ),
        updatedAt: now,
      );
    } catch (_) {
      return _failedSnapshot(
        jobId: jobId,
        request: request,
        failure: const OnlineReviewFailure(
          reason: AnalysisFailureReason.serviceUnavailable,
        ),
        updatedAt: now,
      );
    }
  }

  OnlineReviewSubmitResponse _submitFromJson(
    Map<String, Object?> json, {
    required OnlineReviewSubmitRequest request,
    required String pgn,
  }) {
    final status = _statusFromWire(json['status']?.toString());
    final jobId = json['jobId']?.toString();
    final analysis = json['analysis'];
    final result = analysis is Map<String, Object?>
        ? OnlineReviewJobResult(
            payload: _payloadFromJson(
              analysis,
              request: request.analysisRequest,
              clientGameKey: request.gameKey,
              pgnOverride: pgn,
            ),
          )
        : null;
    return OnlineReviewSubmitResponse(
      jobId: jobId,
      gameKey: request.gameKey,
      requestedMode: request.requestedMode,
      status: status,
      submittedAt: request.submittedAt,
      updatedAt: DateTime.now().toUtc(),
      result: result,
      failure: _failureFromJson(json),
      providerMetadata:
          result?.providerMetadata ?? const AnalysisProviderMetadata(),
    );
  }

  OnlineReviewJobSnapshot _jobFromJson(
    Map<String, Object?> json, {
    required String jobId,
    required OnlineReviewSubmitRequest? request,
  }) {
    final now = DateTime.now().toUtc();
    final status = _statusFromWire(json['status']?.toString());
    final analysis = json['analysis'];
    final pgn = request == null ? null : _pgnFor(request.analysisRequest);
    final result = analysis is Map<String, Object?>
        ? OnlineReviewJobResult(
            payload: _payloadFromJson(
              analysis,
              request: request?.analysisRequest,
              clientGameKey: request?.gameKey,
              pgnOverride: pgn,
            ),
          )
        : null;
    return OnlineReviewJobSnapshot(
      jobId: json['jobId']?.toString() ?? jobId,
      gameKey: request?.gameKey ?? json['gameKey']?.toString() ?? '',
      requestedMode:
          request?.requestedMode ?? _modeFromWire(json['mode']?.toString()),
      status: status,
      progress: _progressFromJson(json['progress']),
      submittedAt: request?.submittedAt ?? now,
      updatedAt: now,
      result: result,
      failure: _failureFromJson(json),
      providerMetadata:
          result?.providerMetadata ?? const AnalysisProviderMetadata(),
    );
  }

  CanonicalAnalysisPayload _payloadFromJson(
    Map<String, Object?> json, {
    AnalysisReviewRequest? request,
    String? clientGameKey,
    String? pgnOverride,
  }) {
    final mode = _modeFromWire(json['modeUsed']?.toString());
    final providerKind = mode.providerKind;
    final source =
        _sourceFromWire(json['source']?.toString()) ?? request?.source;
    final metadata = _metadataFromJson(
      json['providerMetadata'],
      mode: mode,
      request: request,
    );
    final players =
        (json['players'] as List?)?.whereType<Map>().toList() ??
        const <Map<dynamic, dynamic>>[];
    final white = _player(players, 'white', request?.white);
    final black = _player(players, 'black', request?.black);
    final createdAt = _date(json['createdAt']) ?? DateTime.now().toUtc();
    final updatedAt = _date(json['updatedAt']) ?? createdAt;
    final timeline = _timelineFromJson(
      json,
      request: request,
      metadata: metadata,
      mode: mode,
      white: white,
      black: black,
      pgnOverride: pgnOverride,
    );
    return CanonicalAnalysisPayload(
      canonicalGameKey:
          clientGameKey ??
          request?.canonicalGameKey ??
          json['gameKey'].toString(),
      modeUsed: mode,
      providerKind: providerKind,
      status: AnalysisProviderStatus.completed,
      source: source ?? AnalysisGameSource.unknown,
      inputHash: request?.inputHash ?? json['gameKey'].toString(),
      pgn: pgnOverride ?? request?.normalizedPgn,
      sourceId: request?.sourceId,
      white: white,
      black: black,
      userIsWhite: request?.userIsWhite,
      result: json['result']?.toString() ?? request?.result ?? '*',
      playedAt: request?.playedAt,
      openingName: _clean(json['opening']) ?? _clean(json['openingName']),
      ecoCode: _clean(json['eco']) ?? _clean(json['ecoCode']),
      averageCpLoss: timeline.averageCpLoss,
      averageCpLossWhite: timeline.averageCpLossWhite,
      averageCpLossBlack: timeline.averageCpLossBlack,
      qualityCounts: timeline.qualityCounts,
      totalPlies: timeline.totalPlies,
      timeline: timeline,
      createdAt: createdAt,
      updatedAt: updatedAt,
      providerMetadata: metadata,
    );
  }

  AnalysisTimeline _timelineFromJson(
    Map<String, Object?> json, {
    required AnalysisReviewRequest? request,
    required AnalysisProviderMetadata metadata,
    required AnalysisReviewMode mode,
    required AnalysisPlayerInfo white,
    required AnalysisPlayerInfo black,
    String? pgnOverride,
  }) {
    final rawMoves = (json['timeline'] as List?) ?? const [];
    final moves = <MoveAnalysis>[];
    for (final raw in rawMoves) {
      if (raw is! Map) continue;
      final move = raw.map((k, v) => MapEntry(k.toString(), v));
      final ply = ((move['ply'] as num?)?.toInt() ?? moves.length + 1) - 1;
      final isWhite =
          (move['side']?.toString().toLowerCase() == 'white') ||
          (move['side'] == null && ply.isEven);
      final beforeCp = (move['evalBeforeCp'] as num?)?.toInt();
      final afterCp = (move['evalAfterCp'] as num?)?.toInt();
      final winBefore = EvaluationAnalyzer.calculateWinPercentage(cp: beforeCp);
      final winAfter = EvaluationAnalyzer.calculateWinPercentage(cp: afterCp);
      final uci =
          _clean(move['playedMoveUci']) ??
          _clean(move['uci']) ??
          _uciFallback(move);
      moves.add(
        MoveAnalysis(
          ply: ply < 0 ? moves.length : ply,
          san: _clean(move['playedMoveSan']) ?? _clean(move['san']) ?? '...',
          uci: uci,
          fenBefore: _initialFen,
          fenAfter: _initialFen,
          targetSquare: uci.length >= 4 ? uci.substring(2, 4) : '',
          winPercentBefore: winBefore,
          winPercentAfter: winAfter,
          deltaW: winAfter - winBefore,
          isWhiteMove: isWhite,
          classification: _qualityFromWire(move['quality']?.toString()),
          playedEqualsPv1:
              _clean(move['bestMoveUci']) != null &&
              _clean(move['bestMoveUci']) == uci,
          moverCpLoss: (move['evalLossCp'] as num?)?.toInt(),
          engineBestMoveUci: _clean(move['bestMoveUci']),
          engineBestMoveSan:
              _clean(move['bestMoveSan']) ?? _clean(move['betterMoveSan']),
          scoreCpAfter: afterCp,
          inBook: move['isBookMove'] as bool? ?? false,
          openingStatus: (move['isBookMove'] as bool? ?? false)
              ? OpeningStatus.bookTheory
              : OpeningStatus.notOpening,
          openingName: _clean(json['opening']),
          ecoCode: _clean(json['eco']),
          message:
              _clean(move['comment']) ??
              _clean(move['reason']) ??
              'Mock online review move',
          analysisMode: mode == AnalysisReviewMode.onlineFast
              ? 'quick'
              : 'deep',
          engineVersion: metadata.engineVersion ?? config.engineVersion,
          debugMetadata: {
            'backendBetterMoveSan': _clean(move['betterMoveSan']),
            'backendProvider': _backendProviderName(json['providerMetadata']),
          },
        ),
      );
    }
    final opening = _clean(json['opening']);
    final eco = _clean(json['eco']);
    return AnalysisTimeline(
      startingFen: _initialFen,
      moves: moves,
      headers: {
        'White': white.name,
        if (white.rating != null) 'WhiteElo': white.rating!,
        'Black': black.name,
        if (black.rating != null) 'BlackElo': black.rating!,
        'Result': json['result']?.toString() ?? request?.result ?? '*',
        if (opening != null) 'Opening': opening,
        if (eco != null) 'ECO': eco,
      },
      winPercentages: [for (final move in moves) move.winPercentAfter],
      analysisMode: mode == AnalysisReviewMode.onlineFast ? 'quick' : 'deep',
      analysisProfileId: mode == AnalysisReviewMode.onlineFast
          ? 'fast_review'
          : 'deep_review',
      providerId: metadata.providerId ?? config.providerId,
      engineVersion: metadata.engineVersion ?? config.engineVersion,
      classifierVersion: kApexClassifierVersion,
      tacticalVerifierVersion: kApexTacticalVerifierVersion,
      openingBookVersion: kApexOpeningBookVersion,
      analysisSchemaVersion: kApexAnalysisSchemaVersion,
      depth: metadata.depth,
      movetimeMs: metadata.movetimeMs,
      multipv: metadata.multipv,
      candidateVerificationEnabled:
          metadata.candidateVerificationEnabled ?? false,
      completedAt: _date(json['updatedAt']),
      pgnHash: request?.inputHash,
      cacheKey: request?.canonicalGameKey,
      cacheHit: json['cached'] as bool? ?? false,
    );
  }

  AnalysisProviderMetadata _metadataFromJson(
    Object? raw, {
    required AnalysisReviewMode mode,
    required AnalysisReviewRequest? request,
  }) {
    final json = raw is Map ? raw.map((k, v) => MapEntry(k.toString(), v)) : {};
    final analysisVersion = _clean(json['analysisVersion']);
    return AnalysisProviderMetadata(
      analysisProfileId: mode == AnalysisReviewMode.onlineFast
          ? 'fast_review'
          : 'deep_review',
      providerId: config.providerId,
      engineVersion: analysisVersion ?? config.engineVersion,
      classifierVersion: kApexClassifierVersion,
      tacticalVerifierVersion: kApexTacticalVerifierVersion,
      openingBookVersion: kApexOpeningBookVersion,
      depth: (json['depth'] as num?)?.toInt(),
      movetimeMs: 0,
      multipv: mode == AnalysisReviewMode.onlineFast ? 1 : 3,
      candidateVerificationEnabled: mode == AnalysisReviewMode.onlineDeep,
      pgnHash: request?.inputHash,
      cacheKey: request?.canonicalGameKey,
      sourceId: request?.sourceId,
    );
  }

  OnlineReviewJobSnapshot _failedSnapshot({
    required String jobId,
    required OnlineReviewSubmitRequest? request,
    required OnlineReviewFailure failure,
    required DateTime updatedAt,
  }) {
    return OnlineReviewJobSnapshot(
      jobId: jobId,
      gameKey: request?.gameKey ?? '',
      requestedMode: request?.requestedMode ?? mode,
      status: failure.reason == AnalysisFailureReason.cancelled
          ? OnlineReviewJobStatus.cancelled
          : OnlineReviewJobStatus.failed,
      submittedAt: request?.submittedAt ?? updatedAt,
      updatedAt: updatedAt,
      failure: failure,
    );
  }

  OnlineReviewSubmitResponse _rejectedForTransport(
    OnlineReviewSubmitRequest request,
    AnalysisFailureReason reason,
  ) {
    return OnlineReviewSubmitResponse.rejected(
      gameKey: request.gameKey,
      requestedMode: request.requestedMode,
      failure: OnlineReviewFailure(reason: reason),
      submittedAt: request.submittedAt,
    );
  }

  OnlineReviewFailure _failureFromResponse(
    int statusCode,
    Map<String, Object?> json,
  ) {
    final error = json['error'];
    final code = error is Map ? error['code']?.toString() : null;
    return OnlineReviewFailure(
      reason: _failureReasonFromCode(code, statusCode: statusCode),
      providerCode: code,
      retryable: statusCode != 400 && statusCode != 401,
    );
  }

  OnlineReviewFailure? _failureFromJson(Map<String, Object?> json) {
    final error = json['error'];
    if (error is! Map) return null;
    final code = error['code']?.toString();
    return OnlineReviewFailure(
      reason: _failureReasonFromCode(code),
      providerCode: code,
      retryable: code != 'invalidPgn' && code != 'cancelled',
    );
  }

  AnalysisFailureReason _failureReasonFromCode(
    String? code, {
    int? statusCode,
  }) {
    return switch (code) {
      'invalidPgn' => AnalysisFailureReason.invalidPgn,
      'timeout' => AnalysisFailureReason.timeout,
      'cancelled' => AnalysisFailureReason.cancelled,
      'providerUnavailable' ||
      'internalError' ||
      'unauthorized' => AnalysisFailureReason.serviceUnavailable,
      'cacheMiss' => AnalysisFailureReason.savedReviewMissing,
      _ when statusCode == 408 || statusCode == 504 =>
        AnalysisFailureReason.timeout,
      _ => AnalysisFailureReason.serviceUnavailable,
    };
  }

  Map<String, Object?> _decodeObject(String body) {
    if (body.trim().isEmpty) return const <String, Object?>{};
    final decoded = jsonDecode(body);
    if (decoded is Map<String, Object?>) return decoded;
    if (decoded is Map) return decoded.map((k, v) => MapEntry(k.toString(), v));
    return const <String, Object?>{};
  }

  Uri _uri(String path) {
    final base = Uri.parse(config.baseUrl!.trim());
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return base.replace(
      pathSegments: [
        ...base.pathSegments.where((segment) => segment.isNotEmpty),
        ...cleanPath.split('/').where((segment) => segment.isNotEmpty),
      ],
    );
  }

  Map<String, String> _headers() {
    return {
      ...apexJsonHeaders,
      'Content-Type': 'application/json',
      if (config.hasApiKey) 'X-Apex-Api-Key': config.apiKey!.trim(),
    };
  }

  String? _pgnFor(AnalysisReviewRequest request) {
    final pgn = request.normalizedPgn?.trim();
    if (pgn != null && pgn.isNotEmpty) return pgn;
    final moves = request.normalizedMoveList;
    if (moves == null || moves.isEmpty) return null;
    return '${moves.join(' ')} ${request.result}';
  }

  String? _backendGameKeyFor(AnalysisReviewRequest? request) {
    if (request == null) return null;
    final pgn = _pgnFor(request);
    if (pgn == null) return null;
    final normalized = _normalizePgnForBackend(pgn);
    final sourceId = (request.sourceId ?? '')
        .replaceAll(RegExp(r'\s+'), '')
        .toLowerCase();
    final identity =
        'source:${_backendSource(request.source)}|'
        'sourceGameId:$sourceId|'
        'pgn:$normalized';
    return 'game-v1-${sha256.convert(utf8.encode(identity))}';
  }

  String _normalizePgnForBackend(String pgn) {
    final volatileTags = {'Date', 'EventDate', 'Time', 'UTCDate', 'UTCTime'};
    final tagRe = RegExp(r'^\[([A-Za-z0-9_]+)\s+".*"\]$');
    final lines = <String>[];
    for (final raw
        in pgn.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      final match = tagRe.firstMatch(line);
      if (match != null && volatileTags.contains(match.group(1))) continue;
      lines.add(line);
    }
    return lines.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  double? _progressFromJson(Object? raw) {
    if (raw is! Map) return null;
    final total = (raw['totalMoves'] as num?)?.toDouble();
    final done = (raw['analyzedMoves'] as num?)?.toDouble();
    if (total == null || total <= 0 || done == null) return null;
    return (done / total).clamp(0, 1).toDouble();
  }

  OnlineReviewJobStatus _statusFromWire(String? raw) {
    return switch (raw) {
      'queued' => OnlineReviewJobStatus.queued,
      'running' => OnlineReviewJobStatus.running,
      'completed' => OnlineReviewJobStatus.completed,
      'cancelled' => OnlineReviewJobStatus.cancelled,
      'expired' => OnlineReviewJobStatus.expired,
      _ => OnlineReviewJobStatus.failed,
    };
  }

  AnalysisReviewMode _modeFromWire(String? raw) {
    return switch (raw) {
      'onlineFast' || 'online_fast' => AnalysisReviewMode.onlineFast,
      'onlineDeep' || 'online_deep' => AnalysisReviewMode.onlineDeep,
      _ => mode,
    };
  }

  String _backendMode(AnalysisReviewMode mode) {
    return switch (mode) {
      AnalysisReviewMode.onlineFast => 'onlineFast',
      AnalysisReviewMode.onlineDeep => 'onlineDeep',
      AnalysisReviewMode.cached ||
      AnalysisReviewMode.offlineLocal => 'onlineFast',
    };
  }

  String _backendSource(AnalysisGameSource source) {
    return switch (source) {
      AnalysisGameSource.chessCom => 'chessCom',
      AnalysisGameSource.lichess => 'lichess',
      AnalysisGameSource.pgn => 'pgn',
      AnalysisGameSource.unknown => 'unknown',
    };
  }

  AnalysisGameSource? _sourceFromWire(String? raw) {
    return switch (raw) {
      'chessCom' || 'chess.com' => AnalysisGameSource.chessCom,
      'lichess' => AnalysisGameSource.lichess,
      'pgn' => AnalysisGameSource.pgn,
      'unknown' => AnalysisGameSource.unknown,
      _ => null,
    };
  }

  MoveQuality _qualityFromWire(String? raw) {
    return switch (raw) {
      'brilliant' => MoveQuality.brilliant,
      'great' || 'greatFind' => MoveQuality.great,
      'best' => MoveQuality.best,
      'excellent' => MoveQuality.excellent,
      'book' => MoveQuality.book,
      'inaccuracy' => MoveQuality.inaccuracy,
      'mistake' => MoveQuality.mistake,
      'blunder' => MoveQuality.blunder,
      'forced' => MoveQuality.forced,
      'missedWin' || 'missed_win' => MoveQuality.missedWin,
      _ => MoveQuality.good,
    };
  }

  AnalysisPlayerInfo _player(
    List<Map<dynamic, dynamic>> players,
    String side,
    AnalysisPlayerInfo? fallback,
  ) {
    Map<dynamic, dynamic>? raw;
    for (final player in players) {
      if (player['side']?.toString().toLowerCase() == side) {
        raw = player;
        break;
      }
    }
    return AnalysisPlayerInfo.fromName(
      raw?['name']?.toString() ?? fallback?.name,
      rating: raw?['rating']?.toString() ?? fallback?.rating,
    );
  }

  DateTime? _date(Object? raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString())?.toUtc();
  }

  String? _clean(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == '?') return null;
    return text;
  }

  String _uciFallback(Map<String, Object?> move) {
    final san = _clean(move['san']) ?? '';
    return san.length >= 4 ? san.substring(0, 4) : '';
  }

  String? _backendProviderName(Object? raw) {
    if (raw is! Map) return null;
    return _clean(raw['provider']);
  }
}

const _initialFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

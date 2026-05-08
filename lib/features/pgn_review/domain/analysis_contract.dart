/// Canonical review request/result contract shared by review providers,
/// saved reviews, archive, and stats.
library;

import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/services/analysis_cache_key.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/game_identity_service.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';

enum AnalysisGameSource {
  chessCom('chess.com'),
  lichess('lichess'),
  pgn('pgn'),
  unknown('unknown');

  const AnalysisGameSource(this.wire);

  final String wire;

  static AnalysisGameSource fromArchiveSource(ArchiveSource source) =>
      switch (source) {
        ArchiveSource.chessCom => AnalysisGameSource.chessCom,
        ArchiveSource.lichess => AnalysisGameSource.lichess,
        ArchiveSource.pgn => AnalysisGameSource.pgn,
      };

  static AnalysisGameSource fromPgnSite(String? site) {
    final value = site?.trim().toLowerCase();
    if (value == null || value.isEmpty || value == '?') {
      return AnalysisGameSource.pgn;
    }
    if (value.contains('chess.com')) return AnalysisGameSource.chessCom;
    if (value.contains('lichess')) return AnalysisGameSource.lichess;
    return AnalysisGameSource.pgn;
  }

  static AnalysisGameSource fromPgn(String pgn) {
    final tags = const GameIdentityService().parseTags(pgn);
    return fromPgnSite(tags['Site']);
  }

  ArchiveSource get archiveSource => switch (this) {
    AnalysisGameSource.chessCom => ArchiveSource.chessCom,
    AnalysisGameSource.lichess => ArchiveSource.lichess,
    AnalysisGameSource.pgn || AnalysisGameSource.unknown => ArchiveSource.pgn,
  };

  String get label => switch (this) {
    AnalysisGameSource.chessCom => 'Chess.com',
    AnalysisGameSource.lichess => 'Lichess',
    AnalysisGameSource.pgn => 'PGN',
    AnalysisGameSource.unknown => 'Unknown',
  };
}

enum AnalysisInputType {
  pgn('pgn'),
  moves('moves'),
  savedReview('saved_review');

  const AnalysisInputType(this.wire);

  final String wire;
}

enum AnalysisReviewMode {
  cached('cached'),
  offlineLocal('offline_local'),
  onlineFast('online_fast'),
  onlineDeep('online_deep');

  const AnalysisReviewMode(this.wire);

  final String wire;

  static AnalysisReviewMode fromProfile(AnalysisProfile profile) =>
      fromProfileId(profile.id);

  static AnalysisReviewMode fromProfileId(AnalysisProfileId id) => switch (id) {
    AnalysisProfileId.fastReview => AnalysisReviewMode.onlineFast,
    AnalysisProfileId.deepReview => AnalysisReviewMode.onlineDeep,
    AnalysisProfileId.offlineReview => AnalysisReviewMode.offlineLocal,
  };

  static AnalysisReviewMode fromAnalysisProfileWire(String? wire) =>
      fromProfileId(AnalysisProfileId.fromWire(wire));

  AnalysisProviderKind get providerKind => switch (this) {
    AnalysisReviewMode.cached => AnalysisProviderKind.cached,
    AnalysisReviewMode.offlineLocal => AnalysisProviderKind.offlineLocal,
    AnalysisReviewMode.onlineFast => AnalysisProviderKind.onlineFast,
    AnalysisReviewMode.onlineDeep => AnalysisProviderKind.onlineDeep,
  };

  bool get isOnline =>
      this == AnalysisReviewMode.onlineFast ||
      this == AnalysisReviewMode.onlineDeep;

  AnalysisMode get reviewBoardMode => switch (this) {
    AnalysisReviewMode.onlineFast => AnalysisMode.quick,
    AnalysisReviewMode.cached ||
    AnalysisReviewMode.offlineLocal ||
    AnalysisReviewMode.onlineDeep => AnalysisMode.deep,
  };
}

enum AnalysisProviderKind {
  cached,
  offlineLocal,
  onlineFast,
  onlineDeep,
  unavailable,
  serviceIssue,
  unsupported,
}

enum AnalysisProviderStatus {
  completed,
  cachedHit,
  unavailable,
  failed,
  partial,
  cancelled,
}

enum AnalysisFailureReason {
  none,
  providerNotConfigured,
  offlineLocalUnavailable,
  serviceUnavailable,
  invalidPgn,
  savedReviewMissing,
  timeout,
  partialData,
  unsupported,
  cancelled,
  unknown,
}

extension AnalysisFailureReasonCopy on AnalysisFailureReason {
  String get safeCopy => switch (this) {
    AnalysisFailureReason.none => '',
    AnalysisFailureReason.providerNotConfigured => 'Online review unavailable',
    AnalysisFailureReason.offlineLocalUnavailable =>
      'Offline review unavailable',
    AnalysisFailureReason.serviceUnavailable => 'Provider unavailable',
    AnalysisFailureReason.invalidPgn => 'Invalid PGN',
    AnalysisFailureReason.savedReviewMissing => 'Saved review unavailable',
    AnalysisFailureReason.timeout => 'Try again',
    AnalysisFailureReason.partialData => 'Showing saved data',
    AnalysisFailureReason.unsupported => 'Provider unavailable',
    AnalysisFailureReason.cancelled => 'Review cancelled',
    AnalysisFailureReason.unknown => 'Provider unavailable',
  };
}

class AnalysisPlayerInfo {
  const AnalysisPlayerInfo({required this.name, this.rating});

  final String name;
  final String? rating;

  static AnalysisPlayerInfo fromName(String? name, {String? rating}) {
    final clean = name?.trim();
    return AnalysisPlayerInfo(
      name: clean == null || clean.isEmpty ? 'Unknown' : clean,
      rating: _cleanOptional(rating),
    );
  }
}

class AnalysisReviewRequest {
  const AnalysisReviewRequest({
    required this.canonicalGameKey,
    required this.source,
    required this.inputType,
    required this.inputHash,
    required this.requestedMode,
    required this.allowReanalysis,
    required this.requestedAt,
    required this.white,
    required this.black,
    required this.result,
    this.normalizedPgn,
    this.normalizedMoveList,
    this.sourceId,
    this.playedAt,
    this.userIsWhite,
    this.userHandle,
  });

  final String canonicalGameKey;
  final AnalysisGameSource source;
  final AnalysisInputType inputType;
  final String inputHash;
  final String? normalizedPgn;
  final List<String>? normalizedMoveList;
  final String? sourceId;
  final AnalysisPlayerInfo white;
  final AnalysisPlayerInfo black;
  final String result;
  final DateTime? playedAt;
  final AnalysisReviewMode requestedMode;
  final bool allowReanalysis;
  final DateTime requestedAt;
  final bool? userIsWhite;
  final String? userHandle;

  factory AnalysisReviewRequest.fromPgn({
    required String pgn,
    required AnalysisReviewMode requestedMode,
    AnalysisGameSource? source,
    bool allowReanalysis = false,
    DateTime? requestedAt,
    DateTime? playedAt,
    bool? userIsWhite,
    String? userHandle,
  }) {
    final identity = const GameIdentityService().parsePgn(
      pgn,
      userHandle: userHandle,
      selectedUserIsWhite: userIsWhite,
    );
    final tags = const GameIdentityService().parseTags(pgn);
    final pgnHash = stablePgnHash(pgn);
    final resolvedSource =
        source ?? AnalysisGameSource.fromPgnSite(tags['Site']);
    return AnalysisReviewRequest(
      canonicalGameKey: ArchivedGame.canonicalKeyFor(
        pgn: pgn,
        pgnHash: pgnHash,
        white: identity.white,
        black: identity.black,
        result: identity.result,
        playedAt: playedAt,
      ),
      source: resolvedSource,
      inputType: AnalysisInputType.pgn,
      inputHash: pgnHash,
      normalizedPgn: normalizedPgnForHash(pgn),
      sourceId: _cleanOptional(tags['Site']),
      white: AnalysisPlayerInfo.fromName(
        identity.white,
        rating: identity.whiteRating,
      ),
      black: AnalysisPlayerInfo.fromName(
        identity.black,
        rating: identity.blackRating,
      ),
      result: identity.result,
      playedAt: playedAt,
      requestedMode: requestedMode,
      allowReanalysis: allowReanalysis,
      requestedAt: (requestedAt ?? DateTime.now()).toUtc(),
      userIsWhite: identity.userIsWhite,
      userHandle: _cleanOptional(userHandle),
    );
  }

  factory AnalysisReviewRequest.fromMoves({
    required List<String> moves,
    required AnalysisReviewMode requestedMode,
    AnalysisGameSource source = AnalysisGameSource.unknown,
    String white = 'White',
    String black = 'Black',
    String result = '*',
    bool allowReanalysis = false,
    DateTime? requestedAt,
    DateTime? playedAt,
    bool? userIsWhite,
    String? userHandle,
  }) {
    final normalizedMoves = [
      for (final move in moves)
        if (move.trim().isNotEmpty) move.trim(),
    ];
    final joined = normalizedMoves.join(' ');
    final hash = stablePgnHash(joined);
    return AnalysisReviewRequest(
      canonicalGameKey: ArchivedGame.canonicalKeyFor(
        pgn: joined,
        pgnHash: hash,
        white: white,
        black: black,
        result: result,
        playedAt: playedAt,
      ),
      source: source,
      inputType: AnalysisInputType.moves,
      inputHash: hash,
      normalizedMoveList: normalizedMoves,
      white: AnalysisPlayerInfo.fromName(white),
      black: AnalysisPlayerInfo.fromName(black),
      result: result,
      playedAt: playedAt,
      requestedMode: requestedMode,
      allowReanalysis: allowReanalysis,
      requestedAt: (requestedAt ?? DateTime.now()).toUtc(),
      userIsWhite: userIsWhite,
      userHandle: _cleanOptional(userHandle),
    );
  }

  factory AnalysisReviewRequest.fromSavedReview(
    ArchivedGame game, {
    bool allowReanalysis = false,
    DateTime? requestedAt,
    bool? userIsWhite,
    String? userHandle,
  }) {
    final pgnHash = game.pgnHash ?? stablePgnHash(game.pgn);
    return AnalysisReviewRequest(
      canonicalGameKey: game.canonicalGameKey,
      source: AnalysisGameSource.fromArchiveSource(game.source),
      inputType: AnalysisInputType.savedReview,
      inputHash: pgnHash,
      normalizedPgn: normalizedPgnForHash(game.pgn),
      sourceId: _cleanOptional(
        const GameIdentityService().parseTags(game.pgn)['Site'],
      ),
      white: AnalysisPlayerInfo.fromName(game.white, rating: game.whiteRating),
      black: AnalysisPlayerInfo.fromName(game.black, rating: game.blackRating),
      result: game.result,
      playedAt: game.playedAt,
      requestedMode: AnalysisReviewMode.cached,
      allowReanalysis: allowReanalysis,
      requestedAt: (requestedAt ?? DateTime.now()).toUtc(),
      userIsWhite: userIsWhite,
      userHandle: _cleanOptional(userHandle),
    );
  }
}

class AnalysisProviderMetadata {
  const AnalysisProviderMetadata({
    this.analysisProfileId,
    this.providerId,
    this.engineVersion,
    this.classifierVersion,
    this.tacticalVerifierVersion,
    this.openingBookVersion,
    this.depth,
    this.movetimeMs,
    this.multipv,
    this.candidateVerificationEnabled,
    this.pgnHash,
    this.cacheKey,
    this.sourceId,
  });

  final String? analysisProfileId;
  final String? providerId;
  final String? engineVersion;
  final int? classifierVersion;
  final int? tacticalVerifierVersion;
  final int? openingBookVersion;
  final int? depth;
  final int? movetimeMs;
  final int? multipv;
  final bool? candidateVerificationEnabled;
  final String? pgnHash;
  final String? cacheKey;
  final String? sourceId;

  factory AnalysisProviderMetadata.fromTimeline(
    AnalysisTimeline timeline, {
    String? sourceId,
  }) {
    return AnalysisProviderMetadata(
      analysisProfileId: timeline.analysisProfileId,
      providerId: timeline.providerId,
      engineVersion: timeline.engineVersion,
      classifierVersion: timeline.classifierVersion,
      tacticalVerifierVersion: timeline.tacticalVerifierVersion,
      openingBookVersion: timeline.openingBookVersion,
      depth: timeline.depth,
      movetimeMs: timeline.movetimeMs,
      multipv: timeline.multipv,
      candidateVerificationEnabled: timeline.candidateVerificationEnabled,
      pgnHash: timeline.pgnHash,
      cacheKey: timeline.cacheKey,
      sourceId: sourceId,
    );
  }
}

class CanonicalAnalysisPayload {
  const CanonicalAnalysisPayload({
    required this.canonicalGameKey,
    required this.modeUsed,
    required this.providerKind,
    required this.status,
    required this.source,
    required this.inputHash,
    required this.white,
    required this.black,
    required this.result,
    required this.qualityCounts,
    required this.averageCpLoss,
    required this.totalPlies,
    required this.createdAt,
    required this.updatedAt,
    this.pgn,
    this.sourceId,
    this.userIsWhite,
    this.playedAt,
    this.openingName,
    this.ecoCode,
    this.averageCpLossWhite,
    this.averageCpLossBlack,
    this.timeline,
    this.timeControl,
    this.providerMetadata = const AnalysisProviderMetadata(),
  });

  final String canonicalGameKey;
  final AnalysisReviewMode modeUsed;
  final AnalysisProviderKind providerKind;
  final AnalysisProviderStatus status;
  final AnalysisGameSource source;
  final String inputHash;
  final String? pgn;
  final String? sourceId;
  final AnalysisPlayerInfo white;
  final AnalysisPlayerInfo black;
  final bool? userIsWhite;
  final String result;
  final DateTime? playedAt;
  final String? openingName;
  final String? ecoCode;
  final double averageCpLoss;
  final double? averageCpLossWhite;
  final double? averageCpLossBlack;
  final Map<MoveQuality, int> qualityCounts;
  final int totalPlies;
  final AnalysisTimeline? timeline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? timeControl;
  final AnalysisProviderMetadata providerMetadata;

  bool get hasTimeline => timeline != null && timeline!.moves.isNotEmpty;

  int get moveCount => (totalPlies / 2).ceil();

  String get reviewModeLabel {
    final profile = providerMetadata.analysisProfileId;
    return switch (profile) {
      'fast_review' => 'Fast',
      'offline_review' => 'Offline',
      _ when modeUsed == AnalysisReviewMode.offlineLocal => 'Offline',
      _ when modeUsed == AnalysisReviewMode.onlineFast => 'Fast',
      _ => 'Deep',
    };
  }

  String get sourceLabel => source.label;

  String get accuracyLabel =>
      (100 - averageCpLoss).clamp(0, 100).toStringAsFixed(0);

  AnalysisMode get reviewBoardMode {
    final profile = providerMetadata.analysisProfileId;
    if (profile == AnalysisProfileId.fastReview.wire) {
      return AnalysisMode.quick;
    }
    return modeUsed.reviewBoardMode;
  }

  factory CanonicalAnalysisPayload.fromTimeline({
    required AnalysisTimeline timeline,
    required String pgn,
    required AnalysisGameSource source,
    required AnalysisReviewMode modeUsed,
    required AnalysisProviderKind providerKind,
    AnalysisProviderStatus status = AnalysisProviderStatus.completed,
    bool? userIsWhite,
    DateTime? playedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? timeControl,
    AnalysisProviderMetadata? providerMetadata,
  }) {
    final headers = timeline.headers;
    final pgnHash = timeline.pgnHash ?? stablePgnHash(pgn);
    final sourceId = _cleanOptional(headers['Site']);
    final metadata =
        providerMetadata ??
        AnalysisProviderMetadata.fromTimeline(timeline, sourceId: sourceId);
    return CanonicalAnalysisPayload(
      canonicalGameKey: ArchivedGame.canonicalKeyFor(
        pgn: pgn,
        pgnHash: pgnHash,
        white: headers['White'] ?? 'White',
        black: headers['Black'] ?? 'Black',
        result: headers['Result'] ?? '*',
        playedAt: playedAt,
      ),
      modeUsed: modeUsed,
      providerKind: providerKind,
      status: status,
      source: source,
      inputHash: pgnHash,
      pgn: pgn,
      sourceId: sourceId,
      white: AnalysisPlayerInfo.fromName(
        headers['White'],
        rating: headers['WhiteElo'],
      ),
      black: AnalysisPlayerInfo.fromName(
        headers['Black'],
        rating: headers['BlackElo'],
      ),
      userIsWhite: userIsWhite,
      result: headers['Result'] ?? '*',
      playedAt: playedAt,
      openingName: _cleanOptional(headers['Opening']),
      ecoCode: _cleanOptional(headers['ECO']),
      averageCpLoss: timeline.averageCpLoss,
      averageCpLossWhite: timeline.averageCpLossWhite,
      averageCpLossBlack: timeline.averageCpLossBlack,
      qualityCounts: timeline.qualityCounts,
      totalPlies: timeline.totalPlies,
      timeline: timeline,
      createdAt: (createdAt ?? timeline.completedAt ?? DateTime.now()).toUtc(),
      updatedAt: (updatedAt ?? timeline.completedAt ?? DateTime.now()).toUtc(),
      timeControl: _cleanOptional(timeControl ?? headers['TimeControl']),
      providerMetadata: metadata,
    );
  }

  factory CanonicalAnalysisPayload.fromArchivedGame(
    ArchivedGame game, {
    AnalysisProviderStatus status = AnalysisProviderStatus.cachedHit,
    AnalysisReviewMode modeUsed = AnalysisReviewMode.cached,
    AnalysisProviderKind providerKind = AnalysisProviderKind.cached,
    bool? userIsWhite,
  }) {
    final timeline = game.cachedTimeline;
    final sourceId = _cleanOptional(
      const GameIdentityService().parseTags(game.pgn)['Site'],
    );
    return CanonicalAnalysisPayload(
      canonicalGameKey: game.canonicalGameKey,
      modeUsed: modeUsed,
      providerKind: providerKind,
      status: status,
      source: AnalysisGameSource.fromArchiveSource(game.source),
      inputHash: game.pgnHash ?? stablePgnHash(game.pgn),
      pgn: game.pgn,
      sourceId: sourceId,
      white: AnalysisPlayerInfo.fromName(game.white, rating: game.whiteRating),
      black: AnalysisPlayerInfo.fromName(game.black, rating: game.blackRating),
      userIsWhite: userIsWhite,
      result: game.result,
      playedAt: game.playedAt,
      openingName: game.openingName,
      ecoCode: game.ecoCode,
      averageCpLoss: game.averageCpLoss,
      averageCpLossWhite: timeline?.averageCpLossWhite,
      averageCpLossBlack: timeline?.averageCpLossBlack,
      qualityCounts: game.qualityCountsLive,
      totalPlies: game.totalPlies,
      timeline: timeline,
      createdAt: game.analyzedAt.toUtc(),
      updatedAt: game.analyzedAt.toUtc(),
      timeControl: game.timeControl,
      providerMetadata: AnalysisProviderMetadata(
        analysisProfileId: game.analysisProfileId,
        providerId: game.providerId,
        engineVersion: timeline?.engineVersion,
        classifierVersion: game.classifierVersion,
        tacticalVerifierVersion: game.tacticalVerifierVersion,
        openingBookVersion: game.openingBookVersion,
        depth: game.depth,
        movetimeMs: timeline?.movetimeMs,
        multipv: timeline?.multipv,
        candidateVerificationEnabled: timeline?.candidateVerificationEnabled,
        pgnHash: game.pgnHash,
        cacheKey: game.cacheKey,
        sourceId: sourceId,
      ),
    );
  }
}

class AnalysisReviewResult {
  const AnalysisReviewResult({
    required this.status,
    required this.mode,
    required this.providerKind,
    required this.requestedAt,
    this.payload,
    this.failureReason = AnalysisFailureReason.none,
    this.completedAt,
  });

  final AnalysisProviderStatus status;
  final AnalysisReviewMode mode;
  final AnalysisProviderKind providerKind;
  final CanonicalAnalysisPayload? payload;
  final AnalysisFailureReason failureReason;
  final DateTime requestedAt;
  final DateTime? completedAt;

  bool get isSuccess =>
      status == AnalysisProviderStatus.completed ||
      status == AnalysisProviderStatus.cachedHit;

  bool get isUnavailable => status == AnalysisProviderStatus.unavailable;

  String? get safeFailureCopy {
    if (failureReason == AnalysisFailureReason.none) return null;
    return failureReason.safeCopy;
  }

  factory AnalysisReviewResult.completed(
    CanonicalAnalysisPayload payload, {
    DateTime? requestedAt,
  }) {
    return AnalysisReviewResult(
      status: AnalysisProviderStatus.completed,
      mode: payload.modeUsed,
      providerKind: payload.providerKind,
      payload: payload,
      requestedAt: (requestedAt ?? payload.createdAt).toUtc(),
      completedAt: payload.updatedAt,
    );
  }

  factory AnalysisReviewResult.cachedHit(
    CanonicalAnalysisPayload payload, {
    DateTime? requestedAt,
  }) {
    return AnalysisReviewResult(
      status: AnalysisProviderStatus.cachedHit,
      mode: AnalysisReviewMode.cached,
      providerKind: AnalysisProviderKind.cached,
      payload: payload,
      requestedAt: (requestedAt ?? DateTime.now()).toUtc(),
      completedAt: payload.updatedAt,
    );
  }

  factory AnalysisReviewResult.unavailable({
    required AnalysisReviewMode mode,
    required AnalysisProviderKind providerKind,
    required AnalysisFailureReason reason,
    DateTime? requestedAt,
  }) {
    return AnalysisReviewResult(
      status: AnalysisProviderStatus.unavailable,
      mode: mode,
      providerKind: providerKind,
      failureReason: reason,
      requestedAt: (requestedAt ?? DateTime.now()).toUtc(),
    );
  }

  factory AnalysisReviewResult.failed({
    required AnalysisReviewMode mode,
    required AnalysisProviderKind providerKind,
    required AnalysisFailureReason reason,
    CanonicalAnalysisPayload? payload,
    DateTime? requestedAt,
    DateTime? completedAt,
  }) {
    return AnalysisReviewResult(
      status: AnalysisProviderStatus.failed,
      mode: mode,
      providerKind: providerKind,
      payload: payload,
      failureReason: reason,
      requestedAt: (requestedAt ?? DateTime.now()).toUtc(),
      completedAt: completedAt?.toUtc(),
    );
  }

  factory AnalysisReviewResult.partial({
    required CanonicalAnalysisPayload payload,
    AnalysisFailureReason reason = AnalysisFailureReason.partialData,
    DateTime? requestedAt,
  }) {
    return AnalysisReviewResult(
      status: AnalysisProviderStatus.partial,
      mode: payload.modeUsed,
      providerKind: payload.providerKind,
      payload: payload,
      failureReason: reason,
      requestedAt: (requestedAt ?? payload.createdAt).toUtc(),
      completedAt: payload.updatedAt,
    );
  }

  factory AnalysisReviewResult.cancelled({
    required AnalysisReviewMode mode,
    required AnalysisProviderKind providerKind,
    DateTime? requestedAt,
  }) {
    return AnalysisReviewResult(
      status: AnalysisProviderStatus.cancelled,
      mode: mode,
      providerKind: providerKind,
      failureReason: AnalysisFailureReason.cancelled,
      requestedAt: (requestedAt ?? DateTime.now()).toUtc(),
    );
  }
}

String? _cleanOptional(String? value) {
  final clean = value?.trim();
  if (clean == null || clean.isEmpty || clean == '?') return null;
  return clean;
}

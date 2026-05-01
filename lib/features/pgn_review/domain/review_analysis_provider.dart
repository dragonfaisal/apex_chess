/// Shared game-review provider architecture.
///
/// Screens call [GameReviewPipeline]; providers return the same
/// [GameReviewResult] shape regardless of online/local implementation.
library;

import 'dart:async';

import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/services/analysis_cache_key.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/features/archives/data/archive_repository.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/domain/review_summary.dart';
import 'package:apex_chess/infrastructure/engine/composite_game_analyzer.dart';

typedef ReviewProgress = void Function(int completed, int total);

class GameReviewRequest {
  const GameReviewRequest({
    required this.pgn,
    required this.profile,
    this.userIsWhite,
    this.userHandle,
    this.onProgress,
  });

  final String pgn;
  final AnalysisProfile profile;
  final bool? userIsWhite;
  final String? userHandle;
  final ReviewProgress? onProgress;
}

class AnalysisRunMetadata {
  const AnalysisRunMetadata({
    required this.analysisProfileId,
    required this.providerId,
    required this.engineVersion,
    required this.classifierVersion,
    required this.tacticalVerifierVersion,
    required this.openingBookVersion,
    required this.depth,
    required this.movetimeMs,
    required this.multipv,
    required this.candidateVerificationEnabled,
    required this.completedAt,
    required this.pgnHash,
    required this.cacheKey,
  });

  final String analysisProfileId;
  final String providerId;
  final String engineVersion;
  final int classifierVersion;
  final int tacticalVerifierVersion;
  final int openingBookVersion;
  final int depth;
  final int movetimeMs;
  final int multipv;
  final bool candidateVerificationEnabled;
  final DateTime completedAt;
  final String pgnHash;
  final String cacheKey;
}

class AnalysisTelemetry {
  const AnalysisTelemetry({
    required this.totalAnalysisMs,
    required this.cacheHit,
    required this.providerId,
    required this.profileId,
    required this.positionsAnalyzed,
    required this.candidateVerificationsCount,
    required this.averageDepthReached,
    required this.engineCallsCount,
  });

  final int totalAnalysisMs;
  final bool cacheHit;
  final String providerId;
  final String profileId;
  final int positionsAnalyzed;
  final int candidateVerificationsCount;
  final double averageDepthReached;
  final int engineCallsCount;

  Map<String, Object> toDebugJson() => {
    'totalAnalysisMs': totalAnalysisMs,
    'cacheHit': cacheHit,
    'providerId': providerId,
    'profileId': profileId,
    'positionsAnalyzed': positionsAnalyzed,
    'candidateVerificationsCount': candidateVerificationsCount,
    'averageDepthReached': averageDepthReached,
    'engineCallsCount': engineCallsCount,
  };
}

class GameReviewResult {
  const GameReviewResult({
    required this.timeline,
    required this.summary,
    required this.metadata,
    required this.telemetry,
    required this.fromCache,
  });

  final AnalysisTimeline timeline;
  final ReviewSummary summary;
  final AnalysisRunMetadata metadata;
  final AnalysisTelemetry telemetry;
  final bool fromCache;
}

abstract class ReviewAnalysisProvider {
  const ReviewAnalysisProvider();

  String get providerId;
  String get engineVersion;
  bool get isConfigured;

  Future<GameReviewResult> analyzeGame(GameReviewRequest request);

  AnalysisRunMetadata metadataFor(GameReviewRequest request) {
    final pgnHash = stablePgnHash(request.pgn);
    final profile = request.profile;
    final cacheKey = buildAnalysisCacheKey(
      pgnHash: pgnHash,
      analysisProfileId: profile.id,
      providerId: providerId,
      engineVersion: engineVersion,
    );
    return AnalysisRunMetadata(
      analysisProfileId: profile.id.wire,
      providerId: providerId,
      engineVersion: engineVersion,
      classifierVersion: kApexClassifierVersion,
      tacticalVerifierVersion: kApexTacticalVerifierVersion,
      openingBookVersion: kApexOpeningBookVersion,
      depth: profile.localDepth,
      movetimeMs: profile.localMovetimeMs,
      multipv: profile.localMultiPv,
      candidateVerificationEnabled: profile.candidateVerificationEnabled,
      completedAt: DateTime.now().toUtc(),
      pgnHash: pgnHash,
      cacheKey: cacheKey,
    );
  }
}

class ReviewProviderUnavailableException implements Exception {
  const ReviewProviderUnavailableException(this.message);
  final String message;

  @override
  String toString() => message;
}

class OnlineFastReviewProvider extends _UnconfiguredOnlineProvider {
  const OnlineFastReviewProvider() : super('online_fast_stub');
}

class OnlineDeepReviewProvider extends _UnconfiguredOnlineProvider {
  const OnlineDeepReviewProvider() : super('online_deep_stub');
}

abstract class _UnconfiguredOnlineProvider extends ReviewAnalysisProvider {
  const _UnconfiguredOnlineProvider(this.providerId);

  @override
  final String providerId;

  @override
  String get engineVersion => 'online-unconfigured';

  @override
  bool get isConfigured => false;

  @override
  Future<GameReviewResult> analyzeGame(GameReviewRequest request) {
    throw const ReviewProviderUnavailableException(
      'Online review provider is not configured.',
    );
  }
}

class LocalOfflineReviewProvider extends ReviewAnalysisProvider {
  const LocalOfflineReviewProvider(this._analyzer);

  final CompositeGameAnalyzer _analyzer;

  @override
  String get providerId => 'local_offline';

  @override
  String get engineVersion => 'local-${_analyzer.localEngineVersion}';

  @override
  bool get isConfigured => true;

  @override
  Future<GameReviewResult> analyzeGame(GameReviewRequest request) async {
    final sw = Stopwatch()..start();
    final metadata = metadataFor(request);
    final mode = _modeForProfile(request.profile);
    final timeline = await _analyzer.analyzeFromPgn(
      request.pgn,
      depth: request.profile.localDepth,
      movetime: Duration(milliseconds: request.profile.localMovetimeMs),
      mode: mode,
      onProgress: request.onProgress,
    );
    sw.stop();
    final enriched = timeline.copyWith(
      analysisProfileId: metadata.analysisProfileId,
      providerId: metadata.providerId,
      engineVersion: metadata.engineVersion,
      classifierVersion: metadata.classifierVersion,
      tacticalVerifierVersion: metadata.tacticalVerifierVersion,
      openingBookVersion: metadata.openingBookVersion,
      analysisSchemaVersion: kApexAnalysisSchemaVersion,
      depth: metadata.depth,
      movetimeMs: metadata.movetimeMs,
      multipv: metadata.multipv,
      candidateVerificationEnabled: metadata.candidateVerificationEnabled,
      completedAt: metadata.completedAt,
      pgnHash: metadata.pgnHash,
      cacheKey: metadata.cacheKey,
      cacheHit: false,
    );
    final summary = const ReviewSummaryService().compute(
      timeline: enriched,
      userIsWhite: request.userIsWhite,
    );
    final verified = enriched.moves
        .where((m) => m.tacticalVerdict.candidateVerified)
        .length;
    final telemetry = AnalysisTelemetry(
      totalAnalysisMs: sw.elapsedMilliseconds,
      cacheHit: false,
      providerId: providerId,
      profileId: request.profile.id.wire,
      positionsAnalyzed: enriched.totalPlies + 1,
      candidateVerificationsCount: verified,
      averageDepthReached: request.profile.localDepth.toDouble(),
      engineCallsCount: enriched.totalPlies + 1 + (verified * 2),
    );
    return GameReviewResult(
      timeline: enriched,
      summary: summary,
      metadata: metadata,
      telemetry: telemetry,
      fromCache: false,
    );
  }

  static AnalysisMode _modeForProfile(AnalysisProfile profile) {
    return profile.id == AnalysisProfileId.fastReview
        ? AnalysisMode.quick
        : AnalysisMode.deep;
  }
}

class GameReviewPipeline {
  const GameReviewPipeline({
    required ReviewAnalysisProvider fastProvider,
    required ReviewAnalysisProvider deepProvider,
    required ReviewAnalysisProvider offlineProvider,
    ArchiveRepository? cacheRepository,
  }) : _fastProvider = fastProvider,
       _deepProvider = deepProvider,
       _offlineProvider = offlineProvider,
       _cacheRepository = cacheRepository;

  final ReviewAnalysisProvider _fastProvider;
  final ReviewAnalysisProvider _deepProvider;
  final ReviewAnalysisProvider _offlineProvider;
  final ArchiveRepository? _cacheRepository;

  ReviewAnalysisProvider providerFor(AnalysisProfile profile) {
    if (profile.id == AnalysisProfileId.offlineReview) {
      return _offlineProvider;
    }
    final online = profile.id == AnalysisProfileId.fastReview
        ? _fastProvider
        : _deepProvider;
    return online.isConfigured ? online : _offlineProvider;
  }

  Future<GameReviewResult> analyzeGame(GameReviewRequest request) async {
    final provider = providerFor(request.profile);
    final metadata = provider.metadataFor(request);
    final cached = _cacheRepository?.find(metadata.cacheKey);
    if (_isCurrentCachedResult(cached, metadata)) {
      final timeline = cached!.cachedTimeline!.copyWith(cacheHit: true);
      final result = GameReviewResult(
        timeline: timeline,
        summary: const ReviewSummaryService().compute(
          timeline: timeline,
          userIsWhite: request.userIsWhite,
        ),
        metadata: metadata,
        telemetry: AnalysisTelemetry(
          totalAnalysisMs: 0,
          cacheHit: true,
          providerId: metadata.providerId,
          profileId: metadata.analysisProfileId,
          positionsAnalyzed: timeline.totalPlies + 1,
          candidateVerificationsCount: timeline.moves
              .where((m) => m.tacticalVerdict.candidateVerified)
              .length,
          averageDepthReached: (metadata.depth).toDouble(),
          engineCallsCount: 0,
        ),
        fromCache: true,
      );
      _logTelemetry(result.telemetry);
      return result;
    }
    final result = await provider.analyzeGame(request);
    _logTelemetry(result.telemetry);
    return result;
  }

  bool _isCurrentCachedResult(
    ArchivedGame? cached,
    AnalysisRunMetadata metadata,
  ) {
    final timeline = cached?.cachedTimeline;
    if (cached == null || timeline == null || timeline.moves.isEmpty) {
      return false;
    }
    return cached.isCacheCurrent &&
        cached.id == metadata.cacheKey &&
        timeline.cacheKey == metadata.cacheKey &&
        timeline.analysisProfileId == metadata.analysisProfileId &&
        timeline.providerId == metadata.providerId &&
        timeline.engineVersion == metadata.engineVersion &&
        timeline.tacticalVerifierVersion == metadata.tacticalVerifierVersion &&
        timeline.openingBookVersion == metadata.openingBookVersion;
  }

  void _logTelemetry(AnalysisTelemetry telemetry) {
    assert(() {
      // Debug-only telemetry. Do not surface in normal product UI.
      // ignore: avoid_print
      print('ApexReviewTelemetry ${telemetry.toDebugJson()}');
      return true;
    }());
  }
}

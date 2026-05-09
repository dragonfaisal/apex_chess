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
import 'package:apex_chess/features/pgn_review/domain/analysis_contract.dart';
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

  AnalysisReviewMode get requestedMode =>
      AnalysisReviewMode.fromProfile(profile);

  AnalysisReviewRequest toContract({
    bool allowReanalysis = false,
    DateTime? requestedAt,
  }) {
    return AnalysisReviewRequest.fromPgn(
      pgn: pgn,
      requestedMode: requestedMode,
      allowReanalysis: allowReanalysis,
      requestedAt: requestedAt,
      userIsWhite: userIsWhite,
      userHandle: userHandle,
    );
  }
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
    this.analysisResult,
  });

  final AnalysisTimeline timeline;
  final ReviewSummary summary;
  final AnalysisRunMetadata metadata;
  final AnalysisTelemetry telemetry;
  final bool fromCache;
  final AnalysisReviewResult? analysisResult;
}

abstract class ReviewAnalysisProvider {
  const ReviewAnalysisProvider();

  String get providerId;
  String get engineVersion;
  bool get isConfigured;

  Future<GameReviewResult> analyzeGame(GameReviewRequest request);

  Future<AnalysisReviewResult?> analyzeContractRequest(
    GameReviewRequest request,
  ) async {
    return null;
  }

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

extension AnalysisRunMetadataContract on AnalysisRunMetadata {
  AnalysisProviderMetadata toContractMetadata({String? sourceId}) {
    return AnalysisProviderMetadata(
      analysisProfileId: analysisProfileId,
      providerId: providerId,
      engineVersion: engineVersion,
      classifierVersion: classifierVersion,
      tacticalVerifierVersion: tacticalVerifierVersion,
      openingBookVersion: openingBookVersion,
      depth: depth,
      movetimeMs: movetimeMs,
      multipv: multipv,
      candidateVerificationEnabled: candidateVerificationEnabled,
      pgnHash: pgnHash,
      cacheKey: cacheKey,
      sourceId: sourceId,
    );
  }
}

class ReviewProviderUnavailableException implements Exception {
  const ReviewProviderUnavailableException(this.message);
  final String message;

  @override
  String toString() => message;
}

typedef ReviewProviderKind = AnalysisProviderKind;

enum ReviewModeUnavailableReason {
  none,
  offline,
  onlineProviderUnavailable,
  localUnavailable,
  serviceIssue,
  unsupported,
}

String reviewProviderModeLabelFor(AnalysisProfileId id) => switch (id) {
  AnalysisProfileId.fastReview => 'Online Fast',
  AnalysisProfileId.deepReview => 'Online Deep',
  AnalysisProfileId.offlineReview => 'Offline Review',
};

class ReviewModeAvailability {
  const ReviewModeAvailability({
    required this.kind,
    required this.profile,
    required this.label,
    required this.available,
    this.unavailableReason = ReviewModeUnavailableReason.none,
    this.savedReview,
  });

  final ReviewProviderKind kind;
  final AnalysisProfile? profile;
  final String label;
  final bool available;
  final ReviewModeUnavailableReason unavailableReason;
  final ArchivedGame? savedReview;

  bool get isAlreadySaved => savedReview != null;

  bool get canPreviewExistingReview {
    final timeline = savedReview?.cachedTimeline;
    return savedReview != null &&
        savedReview!.isCacheCurrent &&
        timeline != null &&
        timeline.moves.isNotEmpty;
  }

  bool get canAnalyzeOffline =>
      available && kind == ReviewProviderKind.offlineLocal;

  bool get canAnalyzeOnlineFast =>
      available && kind == ReviewProviderKind.onlineFast;

  bool get canAnalyzeOnlineDeep =>
      available && kind == ReviewProviderKind.onlineDeep;

  String? get unavailableMessage => switch (unavailableReason) {
    ReviewModeUnavailableReason.none => null,
    _ => failureReason.safeCopy,
  };

  AnalysisFailureReason get failureReason => switch (unavailableReason) {
    ReviewModeUnavailableReason.none => AnalysisFailureReason.none,
    ReviewModeUnavailableReason.offline =>
      AnalysisFailureReason.providerNotConfigured,
    ReviewModeUnavailableReason.onlineProviderUnavailable =>
      AnalysisFailureReason.providerNotConfigured,
    ReviewModeUnavailableReason.localUnavailable =>
      AnalysisFailureReason.offlineLocalUnavailable,
    ReviewModeUnavailableReason.serviceIssue =>
      AnalysisFailureReason.serviceUnavailable,
    ReviewModeUnavailableReason.unsupported =>
      AnalysisFailureReason.unsupported,
  };
}

class ReviewModeRoutingPlan {
  const ReviewModeRoutingPlan({
    required this.isOnline,
    required this.saved,
    required this.onlineFast,
    required this.onlineDeep,
    required this.offline,
  });

  factory ReviewModeRoutingPlan.build({
    required bool isOnline,
    required bool onlineFastConfigured,
    required bool onlineDeepConfigured,
    bool offlineSupported = true,
    ArchivedGame? savedReview,
    bool onlineServiceIssue = false,
  }) {
    final saved = ReviewModeAvailability(
      kind: savedReview == null
          ? ReviewProviderKind.unavailable
          : ReviewProviderKind.cached,
      profile: savedReview?.analysisProfile,
      label: 'Saved Review',
      available: savedReview != null,
      savedReview: savedReview,
    );
    final onlineIssueReason = onlineServiceIssue
        ? ReviewModeUnavailableReason.serviceIssue
        : (isOnline
              ? ReviewModeUnavailableReason.onlineProviderUnavailable
              : ReviewModeUnavailableReason.offline);
    final onlineIssueKind = onlineServiceIssue
        ? ReviewProviderKind.serviceIssue
        : ReviewProviderKind.unavailable;
    final fastAvailable =
        isOnline && onlineFastConfigured && !onlineServiceIssue;
    final deepAvailable =
        isOnline && onlineDeepConfigured && !onlineServiceIssue;
    return ReviewModeRoutingPlan(
      isOnline: isOnline,
      saved: saved,
      onlineFast: ReviewModeAvailability(
        kind: fastAvailable ? ReviewProviderKind.onlineFast : onlineIssueKind,
        profile: AnalysisProfile.fastReview,
        label: reviewProviderModeLabelFor(AnalysisProfileId.fastReview),
        available: fastAvailable,
        unavailableReason: fastAvailable
            ? ReviewModeUnavailableReason.none
            : onlineIssueReason,
      ),
      onlineDeep: ReviewModeAvailability(
        kind: deepAvailable ? ReviewProviderKind.onlineDeep : onlineIssueKind,
        profile: AnalysisProfile.deepReview,
        label: reviewProviderModeLabelFor(AnalysisProfileId.deepReview),
        available: deepAvailable,
        unavailableReason: deepAvailable
            ? ReviewModeUnavailableReason.none
            : onlineIssueReason,
      ),
      offline: ReviewModeAvailability(
        kind: offlineSupported
            ? ReviewProviderKind.offlineLocal
            : ReviewProviderKind.unsupported,
        profile: AnalysisProfile.offlineReview,
        label: reviewProviderModeLabelFor(AnalysisProfileId.offlineReview),
        available: offlineSupported,
        unavailableReason: offlineSupported
            ? ReviewModeUnavailableReason.none
            : ReviewModeUnavailableReason.localUnavailable,
      ),
    );
  }

  final bool isOnline;
  final ReviewModeAvailability saved;
  final ReviewModeAvailability onlineFast;
  final ReviewModeAvailability onlineDeep;
  final ReviewModeAvailability offline;

  bool get isAlreadySaved => saved.isAlreadySaved;

  bool get canPreviewExistingReview => saved.canPreviewExistingReview;

  bool get canAnalyzeOffline => offline.canAnalyzeOffline;

  bool get canAnalyzeOnlineFast => onlineFast.canAnalyzeOnlineFast;

  bool get canAnalyzeOnlineDeep => onlineDeep.canAnalyzeOnlineDeep;

  ReviewModeAvailability optionFor(AnalysisProfile profile) =>
      switch (profile.id) {
        AnalysisProfileId.fastReview => onlineFast,
        AnalysisProfileId.deepReview => onlineDeep,
        AnalysisProfileId.offlineReview => offline,
      };

  bool canAnalyze(AnalysisProfile profile) => optionFor(profile).available;

  List<ReviewModeAvailability> get pickerOptions {
    if (!isOnline) return [offline];
    return [onlineFast, onlineDeep, offline];
  }
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
    throw const ReviewProviderUnavailableException('Online review unavailable');
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
    final payload = CanonicalAnalysisPayload.fromTimeline(
      timeline: enriched,
      pgn: request.pgn,
      source: AnalysisGameSource.fromPgn(request.pgn),
      modeUsed: AnalysisReviewMode.offlineLocal,
      providerKind: AnalysisProviderKind.offlineLocal,
      userIsWhite: request.userIsWhite,
      providerMetadata: metadata.toContractMetadata(),
    );
    return GameReviewResult(
      timeline: enriched,
      summary: summary,
      metadata: metadata,
      telemetry: telemetry,
      fromCache: false,
      analysisResult: AnalysisReviewResult.completed(payload),
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
    return profile.id == AnalysisProfileId.fastReview
        ? _fastProvider
        : _deepProvider;
  }

  ReviewModeRoutingPlan modePlan({
    required bool isOnline,
    ArchivedGame? savedReview,
  }) {
    return ReviewModeRoutingPlan.build(
      isOnline: isOnline,
      onlineFastConfigured: _fastProvider.isConfigured,
      onlineDeepConfigured: _deepProvider.isConfigured,
      offlineSupported: _offlineProvider.isConfigured,
      savedReview: savedReview,
    );
  }

  Future<AnalysisReviewResult> analyzeContract(
    GameReviewRequest request,
  ) async {
    final provider = providerFor(request.profile);
    if (!provider.isConfigured) {
      return AnalysisReviewResult.unavailable(
        mode: request.requestedMode,
        providerKind: request.requestedMode.providerKind,
        reason: _unconfiguredReasonFor(request.requestedMode),
      );
    }
    final providerContract = await provider.analyzeContractRequest(request);
    if (providerContract != null) return providerContract;
    try {
      final result = await analyzeGame(request);
      return result.analysisResult ??
          _contractResultFromGameReview(request: request, result: result);
    } on TimeoutException {
      return AnalysisReviewResult.failed(
        mode: request.requestedMode,
        providerKind: request.requestedMode.providerKind,
        reason: AnalysisFailureReason.timeout,
      );
    } on ReviewProviderUnavailableException {
      return AnalysisReviewResult.unavailable(
        mode: request.requestedMode,
        providerKind: request.requestedMode.providerKind,
        reason: _unconfiguredReasonFor(request.requestedMode),
      );
    }
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
        analysisResult: AnalysisReviewResult.cachedHit(
          CanonicalAnalysisPayload.fromTimeline(
            timeline: timeline,
            pgn: cached.pgn,
            source: AnalysisGameSource.fromArchiveSource(cached.source),
            modeUsed: AnalysisReviewMode.cached,
            providerKind: AnalysisProviderKind.cached,
            status: AnalysisProviderStatus.cachedHit,
            userIsWhite: request.userIsWhite,
            playedAt: cached.playedAt,
            createdAt: cached.analyzedAt,
            updatedAt: cached.analyzedAt,
            timeControl: cached.timeControl,
            providerMetadata: metadata.toContractMetadata(),
          ),
        ),
      );
      _logTelemetry(result.telemetry);
      return result;
    }
    final result = await provider.analyzeGame(request);
    _logTelemetry(result.telemetry);
    return result;
  }

  AnalysisReviewResult _contractResultFromGameReview({
    required GameReviewRequest request,
    required GameReviewResult result,
  }) {
    final status = result.fromCache
        ? AnalysisProviderStatus.cachedHit
        : AnalysisProviderStatus.completed;
    final mode = result.fromCache
        ? AnalysisReviewMode.cached
        : request.requestedMode;
    final kind = result.fromCache
        ? AnalysisProviderKind.cached
        : request.requestedMode.providerKind;
    final payload = CanonicalAnalysisPayload.fromTimeline(
      timeline: result.timeline,
      pgn: request.pgn,
      source: AnalysisGameSource.fromPgn(request.pgn),
      modeUsed: mode,
      providerKind: kind,
      status: status,
      userIsWhite: request.userIsWhite,
      providerMetadata: result.metadata.toContractMetadata(),
    );
    return result.fromCache
        ? AnalysisReviewResult.cachedHit(payload)
        : AnalysisReviewResult.completed(payload);
  }

  AnalysisFailureReason _unconfiguredReasonFor(AnalysisReviewMode mode) {
    return mode == AnalysisReviewMode.offlineLocal
        ? AnalysisFailureReason.offlineLocalUnavailable
        : AnalysisFailureReason.providerNotConfigured;
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

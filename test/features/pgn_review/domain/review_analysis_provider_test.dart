import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/domain/analysis_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/review_analysis_provider.dart';
import 'package:apex_chess/features/pgn_review/domain/review_summary.dart';

void main() {
  test('online provider stubs are safely unconfigured', () {
    const fast = OnlineFastReviewProvider();
    const deep = OnlineDeepReviewProvider();

    expect(fast.providerId, 'online_fast_stub');
    expect(deep.providerId, 'online_deep_stub');
    expect(fast.isConfigured, isFalse);
    expect(deep.isConfigured, isFalse);
  });

  test(
    'pipeline does not fake online Fast or Deep with local fallback',
    () async {
      final local = _FakeProvider('local_offline');
      final pipeline = GameReviewPipeline(
        fastProvider: const OnlineFastReviewProvider(),
        deepProvider: const OnlineDeepReviewProvider(),
        offlineProvider: local,
      );

      expect(
        pipeline.providerFor(AnalysisProfile.fastReview).providerId,
        'online_fast_stub',
      );
      expect(
        pipeline.providerFor(AnalysisProfile.deepReview).providerId,
        'online_deep_stub',
      );
      expect(
        pipeline.providerFor(AnalysisProfile.offlineReview).providerId,
        'local_offline',
      );
      await expectLater(
        pipeline.analyzeGame(
          const GameReviewRequest(
            pgn: '1. e4 *',
            profile: AnalysisProfile.fastReview,
          ),
        ),
        throwsA(isA<ReviewProviderUnavailableException>()),
      );
    },
  );

  test('provider mode plan maps online availability honestly', () {
    final plan = ReviewModeRoutingPlan.build(
      isOnline: true,
      onlineFastConfigured: true,
      onlineDeepConfigured: false,
    );

    expect(plan.canAnalyzeOnlineFast, isTrue);
    expect(plan.canAnalyzeOnlineDeep, isFalse);
    expect(plan.canAnalyzeOffline, isTrue);
    expect(plan.onlineFast.kind, ReviewProviderKind.onlineFast);
    expect(plan.onlineDeep.kind, ReviewProviderKind.unavailable);
    expect(
      plan.onlineDeep.unavailableReason,
      ReviewModeUnavailableReason.onlineProviderUnavailable,
    );
    expect(plan.onlineFast.label, 'Fast');
    expect(plan.onlineDeep.label, 'Deep');
  });

  test('offline mode plan exposes a single local analysis option', () {
    final plan = ReviewModeRoutingPlan.build(
      isOnline: false,
      onlineFastConfigured: true,
      onlineDeepConfigured: true,
    );

    expect(plan.pickerOptions, hasLength(1));
    expect(plan.pickerOptions.single.profile, AnalysisProfile.offlineReview);
    expect(plan.canAnalyzeOnlineFast, isFalse);
    expect(plan.canAnalyzeOnlineDeep, isFalse);
    expect(plan.canAnalyzeOffline, isTrue);
  });

  test('offline review path still uses the local provider', () async {
    final offline = _CompletingOfflineProvider();
    final pipeline = GameReviewPipeline(
      fastProvider: const OnlineFastReviewProvider(),
      deepProvider: const OnlineDeepReviewProvider(),
      offlineProvider: offline,
    );

    final result = await pipeline.analyzeContract(
      const GameReviewRequest(
        pgn: '1. e4 *',
        profile: AnalysisProfile.offlineReview,
        userIsWhite: true,
      ),
    );

    expect(result.status, AnalysisProviderStatus.completed);
    expect(result.mode, AnalysisReviewMode.offlineLocal);
    expect(result.payload!.timeline!.totalPlies, 1);
    expect(offline.calls, 1);
  });

  test('saved review plan prefers preview when cached timeline exists', () {
    final saved = _savedReview();
    final plan = ReviewModeRoutingPlan.build(
      isOnline: true,
      onlineFastConfigured: false,
      onlineDeepConfigured: false,
      savedReview: saved,
    );

    expect(plan.isAlreadySaved, isTrue);
    expect(plan.canPreviewExistingReview, isTrue);
    expect(plan.saved.kind, ReviewProviderKind.cached);
    expect(plan.saved.label, 'Saved Review');
  });
}

class _CompletingOfflineProvider extends ReviewAnalysisProvider {
  int calls = 0;

  @override
  String get providerId => 'local_offline';

  @override
  String get engineVersion => 'test-local';

  @override
  bool get isConfigured => true;

  @override
  Future<GameReviewResult> analyzeGame(GameReviewRequest request) async {
    calls++;
    final metadata = metadataFor(request);
    final timeline = _singleMoveTimeline.copyWith(
      analysisProfileId: metadata.analysisProfileId,
      providerId: metadata.providerId,
      engineVersion: metadata.engineVersion,
      classifierVersion: metadata.classifierVersion,
      tacticalVerifierVersion: metadata.tacticalVerifierVersion,
      openingBookVersion: metadata.openingBookVersion,
      depth: metadata.depth,
      movetimeMs: metadata.movetimeMs,
      multipv: metadata.multipv,
      candidateVerificationEnabled: metadata.candidateVerificationEnabled,
      completedAt: metadata.completedAt,
      pgnHash: metadata.pgnHash,
      cacheKey: metadata.cacheKey,
    );
    final payload = CanonicalAnalysisPayload.fromTimeline(
      timeline: timeline,
      pgn: request.pgn,
      source: AnalysisGameSource.pgn,
      modeUsed: AnalysisReviewMode.offlineLocal,
      providerKind: AnalysisProviderKind.offlineLocal,
      userIsWhite: request.userIsWhite,
      providerMetadata: metadata.toContractMetadata(),
    );
    return GameReviewResult(
      timeline: timeline,
      summary: const ReviewSummaryService().compute(
        timeline: timeline,
        userIsWhite: true,
      ),
      metadata: metadata,
      telemetry: AnalysisTelemetry(
        totalAnalysisMs: 0,
        cacheHit: false,
        providerId: providerId,
        profileId: metadata.analysisProfileId,
        positionsAnalyzed: timeline.totalPlies + 1,
        candidateVerificationsCount: 0,
        averageDepthReached: metadata.depth.toDouble(),
        engineCallsCount: 0,
      ),
      fromCache: false,
      analysisResult: AnalysisReviewResult.completed(payload),
    );
  }
}

class _FakeProvider extends ReviewAnalysisProvider {
  _FakeProvider(this.providerId);

  @override
  final String providerId;

  @override
  String get engineVersion => 'fake';

  @override
  bool get isConfigured => true;

  @override
  Future<GameReviewResult> analyzeGame(GameReviewRequest request) {
    throw UnimplementedError();
  }
}

const _singleMoveTimeline = AnalysisTimeline(
  startingFen: '8/8/8/8/8/8/8/8 w - - 0 1',
  moves: [
    MoveAnalysis(
      ply: 0,
      san: 'e4',
      uci: 'e2e4',
      fenBefore: '8/8/8/8/8/8/8/8 w - - 0 1',
      fenAfter: '8/8/8/8/8/8/8/8 w - - 0 1',
      targetSquare: 'e4',
      winPercentBefore: 50,
      winPercentAfter: 51,
      deltaW: 1,
      isWhiteMove: true,
      classification: MoveQuality.best,
      message: 'Best',
    ),
  ],
  headers: {'White': 'Alpha', 'Black': 'Beta', 'Result': '*'},
  winPercentages: [51],
  classifierVersion: kApexClassifierVersion,
  tacticalVerifierVersion: kApexTacticalVerifierVersion,
  openingBookVersion: kApexOpeningBookVersion,
  analysisSchemaVersion: kApexAnalysisSchemaVersion,
);

ArchivedGame _savedReview() {
  return ArchivedGame(
    id: 'saved',
    source: ArchiveSource.pgn,
    white: 'Alpha',
    black: 'Beta',
    result: '1-0',
    analyzedAt: DateTime(2026, 5, 1),
    depth: 22,
    pgn: '1. e4 *',
    qualityCounts: const {},
    averageCpLoss: 12,
    totalPlies: 1,
    cachedTimeline: _singleMoveTimeline,
  );
}

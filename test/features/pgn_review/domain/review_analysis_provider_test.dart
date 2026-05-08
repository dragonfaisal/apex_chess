import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/domain/review_analysis_provider.dart';

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
    expect(plan.onlineFast.label, 'Online Fast');
    expect(plan.onlineDeep.label, 'Online Deep');
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
    cachedTimeline: const AnalysisTimeline(
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
      headers: {},
      winPercentages: [51],
      classifierVersion: kApexClassifierVersion,
      tacticalVerifierVersion: kApexTacticalVerifierVersion,
      openingBookVersion: kApexOpeningBookVersion,
      analysisSchemaVersion: kApexAnalysisSchemaVersion,
    ),
  );
}

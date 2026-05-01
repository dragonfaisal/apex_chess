import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
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
    'pipeline resolves Fast and Deep to local fallback until online exists',
    () {
      final local = _FakeProvider('local_offline');
      final pipeline = GameReviewPipeline(
        fastProvider: const OnlineFastReviewProvider(),
        deepProvider: const OnlineDeepReviewProvider(),
        offlineProvider: local,
      );

      expect(
        pipeline.providerFor(AnalysisProfile.fastReview).providerId,
        'local_offline',
      );
      expect(
        pipeline.providerFor(AnalysisProfile.deepReview).providerId,
        'local_offline',
      );
      expect(
        pipeline.providerFor(AnalysisProfile.offlineReview).providerId,
        'local_offline',
      );
    },
  );
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

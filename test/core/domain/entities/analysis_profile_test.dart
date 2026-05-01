import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/domain/services/analysis_cache_key.dart';

void main() {
  test(
    'Fast, Deep, and Offline profiles exist with expected local budgets',
    () {
      expect(AnalysisProfile.fastReview.label, 'Fast Review');
      expect(
        AnalysisProfile.fastReview.providerIntent,
        AnalysisProviderIntent.onlineFirst,
      );
      expect(AnalysisProfile.fastReview.localMultiPv, 1);

      expect(AnalysisProfile.deepReview.label, 'Deep Review');
      expect(
        AnalysisProfile.deepReview.providerIntent,
        AnalysisProviderIntent.onlineFirst,
      );
      expect(AnalysisProfile.deepReview.localMultiPv, 3);
      expect(AnalysisProfile.deepReview.candidateVerificationEnabled, isTrue);

      expect(AnalysisProfile.offlineReview.label, 'Offline Review');
      expect(
        AnalysisProfile.offlineReview.providerIntent,
        AnalysisProviderIntent.localOnly,
      );
      expect(AnalysisProfile.offlineReview.warning, isNotNull);
    },
  );

  test(
    'stable PGN hash and cache key are deterministic by profile/provider',
    () {
      const pgn = '[White "A"]\n[Black "B"]\n\n1. e4 e5 *';
      final hashA = stablePgnHash(pgn);
      final hashB = stablePgnHash(
        '  [White "A"]  \n[Black "B"]\n\n1. e4 e5 *  ',
      );
      expect(hashA, hashB);

      final fastKey = buildAnalysisCacheKey(
        pgnHash: hashA,
        analysisProfileId: AnalysisProfileId.fastReview,
        providerId: 'local_offline',
        engineVersion: 'local-test',
      );
      final deepKey = buildAnalysisCacheKey(
        pgnHash: hashA,
        analysisProfileId: AnalysisProfileId.deepReview,
        providerId: 'local_offline',
        engineVersion: 'local-test',
      );
      expect(fastKey, isNot(deepKey));
      expect(fastKey, contains('fast_review'));
      expect(deepKey, contains('deep_review'));
    },
  );
}

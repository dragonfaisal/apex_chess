import 'package:flutter_test/flutter_test.dart';

import '../../../support/chapter6_explanation_corpus.dart';

void main() {
  test('Chapter 6 corpus is deterministic and fails closed', () {
    final run = runChapter6ExplanationCorpus();

    expect(run.results, hasLength(kChapter6CorpusCases.length));
    expect(run.results.length, greaterThanOrEqualTo(20));
    expect(
      run.failed,
      0,
      reason: run.results
          .where((result) => !result.passed)
          .map((result) => '${result.spec.id}: ${result.failureReasons}')
          .join('\n'),
    );
    expect(run.falsePositiveClaims, 0);
    expect(run.forbiddenClaimViolations, 0);
    expect(run.copyInvariantFailures, 0);
    expect(run.duplicateFingerprints, isEmpty);
    expect(run.humanReviewCases, 11);
    expect(run.unresolvedHumanReviewCases, 0);
    expect(run.results.every((result) => result.deterministic), isTrue);
    expect(run.performance['ordinaryExplanationSpecificEngineSearches'], 0);
    expect(run.performance['legal100PlyGeneratedInsights'], 100);
  });
}

import 'package:flutter_test/flutter_test.dart';

import '../../../support/chapter7_tactical_causality_corpus.dart';

void main() {
  test('Chapter 7 tactical corpus is deterministic and fail-closed', () {
    final run = runChapter7TacticalCorpus();

    expect(run.results, hasLength(26));
    expect(run.failed, 0);
    expect(run.falsePositiveClaims, 0);
    expect(run.forbiddenViolations, 0);
    expect(run.copyFailures, 0);
    expect(run.duplicateFingerprints, isEmpty);
    expect(run.unresolvedHumanReview, 0);
    expect(run.results.every((result) => result.deterministic), isTrue);
    expect(run.performance['ordinaryExplanationSpecificEngineSearches'], 0);
  });
}

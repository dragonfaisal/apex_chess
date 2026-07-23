import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../test/support/chapter6_explanation_corpus.dart';

void main() {
  test('exports the audited Chapter 6 corpus artifacts', () async {
    final run = runChapter6ExplanationCorpus();
    final output = Directory(r'C:\apex_chess_reports\chapter6');
    await output.create(recursive: true);
    final jsonFile = File(
      '${output.path}\\Apex_Explanation_Corpus_Results.json',
    );
    final csvFile = File('${output.path}\\Apex_Explanation_Claim_Matrix.csv');
    const encoder = JsonEncoder.withIndent('  ');
    await jsonFile.writeAsString('${encoder.convert(run.toJson())}\n');
    await csvFile.writeAsString('${run.claimMatrixCsv()}\r\n');
    stdout.writeln(
      'CHAPTER6_CORPUS total=${run.results.length} passed=${run.passed} '
      'failed=${run.failed} forbidden=${run.forbiddenClaimViolations} '
      'duplicates=${run.duplicateFingerprints.length} '
      'humanReview=${run.humanReviewCases} '
      'unresolvedHumanReview=${run.unresolvedHumanReviewCases}',
    );
    stdout.writeln('CHAPTER6_PERFORMANCE ${jsonEncode(run.performance)}');
    expect(run.failed, 0);
    expect(run.forbiddenClaimViolations, 0);
    expect(run.duplicateFingerprints, isEmpty);
  });
}

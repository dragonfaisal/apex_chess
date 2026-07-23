import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../test/support/chapter7_tactical_causality_corpus.dart';

void main() {
  test('exports the audited Chapter 7 tactical corpus artifacts', () async {
    final run = runChapter7TacticalCorpus();
    final output = Directory(r'C:\apex_chess_reports\chapter7');
    await output.create(recursive: true);
    final jsonFile = File(
      '${output.path}\\Apex_Tactical_Causality_Corpus_Results.json',
    );
    final csvFile = File('${output.path}\\Apex_Tactical_Claim_Matrix.csv');
    const encoder = JsonEncoder.withIndent('  ');
    await jsonFile.writeAsString('${encoder.convert(run.toJson())}\n');
    await csvFile.writeAsString('${run.claimMatrixCsv()}\r\n');
    stdout.writeln(
      'CHAPTER7_CORPUS total=${run.results.length} '
      'positive=${run.positiveCases} negative=${run.negativeCases} '
      'passed=${run.passed} failed=${run.failed} '
      'falsePositive=${run.falsePositiveClaims} '
      'forbidden=${run.forbiddenViolations} '
      'copyFailures=${run.copyFailures} '
      'duplicates=${run.duplicateFingerprints.length} '
      'unresolvedHumanReview=${run.unresolvedHumanReview}',
    );
    stdout.writeln(
      'CHAPTER7_PERFORMANCE ${jsonEncode(run.runtimePerformance)}',
    );
    expect(run.failed, 0);
    expect(run.falsePositiveClaims, 0);
    expect(run.forbiddenViolations, 0);
    expect(run.copyFailures, 0);
    expect(run.duplicateFingerprints, isEmpty);
    expect(run.unresolvedHumanReview, 0);
  });
}

/// Deterministic developer-only report/export helpers for golden evidence.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_policy.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_review.dart';

const goldenEvidenceReviewReportVersion = 'golden-evidence-review-report-v1';

enum GoldenEvidenceReviewReportFormat {
  markdown('markdown'),
  json('json');

  const GoldenEvidenceReviewReportFormat(this.wire);

  final String wire;
}

String renderGoldenEvidenceReviewReportMarkdown(
  GoldenEvidenceReviewResult result, {
  required GoldenEvidenceReviewMode mode,
}) {
  final buffer = StringBuffer()
    ..writeln('# Golden Evidence Review Report')
    ..writeln()
    ..writeln('- version: $goldenEvidenceReviewReportVersion')
    ..writeln('- mode: ${mode.wire}')
    ..writeln('- status: ${result.status.wire}')
    ..writeln()
    ..writeln('## Summary')
    ..writeln('- total cases: ${result.totalCases}')
    ..writeln('- passed count: ${result.passed}')
    ..writeln('- warnings count: ${result.warnings}')
    ..writeln('- incomplete count: ${result.incomplete}')
    ..writeln(
      '- needs real-device evidence count: '
      '${result.needsRealDeviceEvidenceCount}',
    )
    ..writeln('- behavior mismatches: ${result.behaviorMismatches}')
    ..writeln('- budget mismatches: ${result.budgetMismatches}')
    ..writeln('- blocked unsafe claims: ${result.blockedUnsafeClaims}')
    ..writeln('- failed count: ${result.failed}')
    ..writeln(
      '- cases missing motif evidence: ${result.casesMissingMotifEvidence}',
    )
    ..writeln()
    ..writeln('## Category Coverage');

  for (final entry in _sortedEnumCounts(result.categoryCoverage)) {
    buffer.writeln('- ${entry.key.wire}: ${entry.value}');
  }

  buffer
    ..writeln()
    ..writeln('## Motif Coverage');
  for (final entry in _sortedEnumCounts(result.motifCoverage)) {
    buffer.writeln('- ${entry.key.wire}: ${entry.value}');
  }

  buffer
    ..writeln()
    ..writeln('## Motif Group Coverage');
  for (final entry in _sortedEnumCounts(result.motifGroupCoverage)) {
    buffer.writeln('- ${entry.key.wire}: ${entry.value}');
  }

  buffer
    ..writeln()
    ..writeln('## Motif Evidence Group Coverage');
  for (final entry in _sortedEnumCounts(result.motifEvidenceGroupCoverage)) {
    buffer.writeln('- ${entry.key.wire}: ${entry.value}');
  }

  buffer
    ..writeln()
    ..writeln('## Per-Case Summary')
    ..writeln(
      '| Case | Category | Status | Evidence Gaps | Budget | Real Device | Next Action |',
    )
    ..writeln('| --- | --- | --- | --- | --- | --- | --- |');

  for (final review in result.caseReviews) {
    buffer.writeln(
      '| ${_cell(review.caseId)} | ${review.category.wire} | '
      '${review.status.wire} | ${_cell(_evidenceGaps(review))} | '
      '${review.budgetExpectationStatus.wire} | '
      '${review.realEngineEvidenceNeeded ? "yes" : "no"} | '
      '${_cell(review.nextAction)} |',
    );
  }

  final realNeeded = result.caseReviews
      .where((review) => review.realEngineEvidenceNeeded)
      .toList(growable: false);
  if (realNeeded.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('## Real-Device Evidence Needed');
    for (final review in realNeeded) {
      buffer.writeln('- ${review.caseId}');
    }
    buffer
      ..writeln()
      ..writeln('Reference command:')
      ..writeln()
      ..writeln('```powershell')
      ..writeln(result.realDeviceEvidenceCommand)
      ..writeln('```');
  }

  final mismatches = result.caseReviews
      .where(
        (review) =>
            review.status == GoldenEvidenceReviewStatus.behaviorMismatch ||
            review.status == GoldenEvidenceReviewStatus.budgetMismatch ||
            review.status == GoldenEvidenceReviewStatus.blockedUnsafeClaim ||
            review.status == GoldenEvidenceReviewStatus.failed,
      )
      .toList(growable: false);
  if (mismatches.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('## Mismatch And Unsafe Cases');
    for (final review in mismatches) {
      buffer.writeln('- ${review.caseId}: ${_safeMessages(review.failures)}');
    }
  }

  final incomplete = result.caseReviews
      .where(
        (review) =>
            review.status == GoldenEvidenceReviewStatus.incompleteEvidence,
      )
      .toList(growable: false);
  if (incomplete.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('## Incomplete Evidence');
    for (final review in incomplete) {
      buffer.writeln('- ${review.caseId}: ${_evidenceGaps(review)}');
    }
  }

  final missingMotif = result.caseReviews
      .where((review) => review.missingMotifEvidence.isNotEmpty)
      .toList(growable: false);
  if (missingMotif.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('## Motif Evidence Gaps');
    for (final review in missingMotif) {
      buffer.writeln(
        '- ${review.caseId}: ${review.missingMotifEvidence.join(", ")}',
      );
    }
  }

  buffer
    ..writeln()
    ..writeln('## Next Recommended Action')
    ..writeln(result.developerRecommendation)
    ..writeln()
    ..writeln(
      'This report is developer-only evidence review output. Golden cases '
      'remain regression inputs, not product claims.',
    );

  return buffer.toString();
}

String renderGoldenEvidenceReviewReportJson(
  GoldenEvidenceReviewResult result, {
  required GoldenEvidenceReviewMode mode,
}) {
  return const JsonEncoder.withIndent(
    '  ',
  ).convert(goldenEvidenceReviewReportToJson(result, mode: mode));
}

Map<String, Object?> goldenEvidenceReviewReportToJson(
  GoldenEvidenceReviewResult result, {
  required GoldenEvidenceReviewMode mode,
}) {
  final realNeeded =
      result.caseReviews
          .where((review) => review.realEngineEvidenceNeeded)
          .map((review) => review.caseId)
          .toList()
        ..sort();

  return <String, Object?>{
    'version': goldenEvidenceReviewReportVersion,
    'mode': mode.wire,
    'status': result.status.wire,
    'summary': <String, Object?>{
      'totalCases': result.totalCases,
      'passedCount': result.passed,
      'warningsCount': result.warnings,
      'incompleteCount': result.incomplete,
      'needsRealDeviceEvidenceCount': result.needsRealDeviceEvidenceCount,
      'behaviorMismatches': result.behaviorMismatches,
      'budgetMismatches': result.budgetMismatches,
      'blockedUnsafeClaims': result.blockedUnsafeClaims,
      'failedCount': result.failed,
      'casesMissingMotifEvidence': result.casesMissingMotifEvidence,
    },
    'categoryCoverage': [
      for (final entry in _sortedEnumCounts(result.categoryCoverage))
        <String, Object?>{'category': entry.key.wire, 'count': entry.value},
    ],
    'motifCoverage': [
      for (final entry in _sortedEnumCounts(result.motifCoverage))
        <String, Object?>{'motif': entry.key.wire, 'count': entry.value},
    ],
    'motifGroupCoverage': [
      for (final entry in _sortedEnumCounts(result.motifGroupCoverage))
        <String, Object?>{'group': entry.key.wire, 'count': entry.value},
    ],
    'motifEvidenceGroupCoverage': [
      for (final entry in _sortedEnumCounts(result.motifEvidenceGroupCoverage))
        <String, Object?>{'group': entry.key.wire, 'count': entry.value},
    ],
    'casesMissingMotifEvidence': [
      for (final review in result.caseReviews.where(
        (review) => review.missingMotifEvidence.isNotEmpty,
      ))
        <String, Object?>{
          'caseId': review.caseId,
          'missingMotifEvidence': review.missingMotifEvidence,
          'missingMotifEvidenceGroups': review.missingMotifEvidenceGroups
              .map((group) => group.wire)
              .toList(),
        },
    ],
    'caseSummaries': [
      for (final review in result.caseReviews) _caseReviewToJson(review),
    ],
    'realDeviceEvidence': <String, Object?>{
      'neededCount': result.needsRealDeviceEvidenceCount,
      'caseIds': realNeeded,
      'referenceCommand': result.realDeviceEvidenceCommand,
    },
    'developerRecommendation': result.developerRecommendation,
    'developerOnly': true,
    'productClaims': false,
  };
}

Map<String, Object?> _caseReviewToJson(GoldenEvidenceCaseReview review) {
  return <String, Object?>{
    'caseId': review.caseId,
    'category': review.category.wire,
    'motifs': review.motifs.map((motif) => motif.wire).toList()..sort(),
    'status': review.status.wire,
    'expectedBehaviors': review.expectedBehaviorsChecked
        .map((behavior) => behavior.wire)
        .toList(),
    'evidenceExpectations': review.evidenceExpectationsChecked,
    'motifGroups': review.motifGroups.map((group) => group.wire).toList(),
    'motifEvidenceGroups': review.motifEvidenceGroups
        .map((group) => group.wire)
        .toList(),
    'satisfiedMotifEvidenceGroups': review.satisfiedMotifEvidenceGroups
        .map((group) => group.wire)
        .toList(),
    'missingMotifEvidenceGroups': review.missingMotifEvidenceGroups
        .map((group) => group.wire)
        .toList(),
    'missingMotifEvidence': review.missingMotifEvidence,
    'satisfiedReasonCodes': _reasonWires(review.satisfiedReasonCodes),
    'missingReasonCodes': _reasonWires(review.missingReasonCodes),
    'expectedSuppressionsSatisfied': _reasonWires(
      review.expectedSuppressionsSatisfied,
    ),
    'expectedSuppressionsMissing': _reasonWires(
      review.expectedSuppressionsMissing,
    ),
    'budgetExpectationStatus': review.budgetExpectationStatus.wire,
    'realDeviceEvidenceNeeded': review.realEngineEvidenceNeeded,
    'warningCount': review.warnings.length,
    'failureCount': review.failures.length,
    'warnings': review.warnings,
    'failures': review.failures,
    'nextAction': review.nextAction,
  };
}

List<String> _reasonWires(List<DeepCandidateReasonCode> reasons) {
  return reasons.map((reason) => reason.wire).toList()..sort();
}

String _evidenceGaps(GoldenEvidenceCaseReview review) {
  final gaps = <String>[
    ...review.missingReasonCodes.map((reason) => reason.wire),
    ...review.expectedSuppressionsMissing.map((reason) => reason.wire),
    ...review.missingMotifEvidence,
    if (review.realEngineEvidenceNeeded) 'real-device-proof',
  ]..sort();
  return gaps.isEmpty ? '-' : gaps.join(', ');
}

String _safeMessages(List<String> messages) {
  if (messages.isEmpty) return 'see status';
  return messages.join('; ');
}

String _cell(String value) => value.replaceAll('|', '/');

List<MapEntry<T, int>> _sortedEnumCounts<T extends Enum>(Map<T, int> counts) {
  return counts.entries.toList()
    ..sort((a, b) => a.key.name.compareTo(b.key.name));
}

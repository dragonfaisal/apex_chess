/// Developer-only evidence readiness review for golden analysis cases.
library;

import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_policy.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';

enum GoldenEvidenceReviewStatus {
  passed('passed'),
  passedWithWarnings('passedWithWarnings'),
  incompleteEvidence('incompleteEvidence'),
  needsRealEngineEvidence('needsRealEngineEvidence'),
  behaviorMismatch('behaviorMismatch'),
  budgetMismatch('budgetMismatch'),
  blockedUnsafeClaim('blockedUnsafeClaim'),
  failed('failed');

  const GoldenEvidenceReviewStatus(this.wire);

  final String wire;
}

enum GoldenEvidenceReviewMode {
  metadataOnly('metadataOnly'),
  planOnly('planOnly'),
  fakeEvidence('fakeEvidence'),
  realDeviceEvidenceReferenceOnly('realDeviceEvidenceReferenceOnly');

  const GoldenEvidenceReviewMode(this.wire);

  final String wire;
}

enum GoldenEvidenceBudgetStatus {
  notApplicable('notApplicable'),
  satisfied('satisfied'),
  mismatch('mismatch');

  const GoldenEvidenceBudgetStatus(this.wire);

  final String wire;
}

class GoldenEvidenceReviewRequest {
  const GoldenEvidenceReviewRequest({
    this.cases = GoldenAnalysisCases.defaults,
    this.mode = GoldenEvidenceReviewMode.fakeEvidence,
    this.profile = LocalSchedulerProfile.balanced,
    this.requireAllEvidence = false,
    this.includeFutureRealEngineNeeds = true,
    this.requestId,
  });

  final List<GoldenAnalysisCase> cases;
  final GoldenEvidenceReviewMode mode;
  final LocalSchedulerProfile profile;
  final bool requireAllEvidence;
  final bool includeFutureRealEngineNeeds;
  final String? requestId;
}

class GoldenEvidenceCaseReview {
  const GoldenEvidenceCaseReview({
    required this.caseId,
    required this.category,
    required this.motifs,
    required this.status,
    required this.expectedBehaviorsChecked,
    required this.evidenceExpectationsChecked,
    required this.satisfiedReasonCodes,
    required this.missingReasonCodes,
    required this.expectedSuppressionsSatisfied,
    required this.expectedSuppressionsMissing,
    required this.motifGroups,
    required this.motifEvidenceGroups,
    required this.satisfiedMotifEvidenceGroups,
    required this.missingMotifEvidenceGroups,
    required this.missingMotifEvidence,
    required this.budgetExpectationStatus,
    required this.realEngineEvidenceNeeded,
    required this.warnings,
    required this.failures,
    required this.nextAction,
  });

  final String caseId;
  final GoldenAnalysisCategory category;
  final List<GoldenMotifTag> motifs;
  final GoldenEvidenceReviewStatus status;
  final List<GoldenExpectedBehaviorCode> expectedBehaviorsChecked;
  final List<String> evidenceExpectationsChecked;
  final List<DeepCandidateReasonCode> satisfiedReasonCodes;
  final List<DeepCandidateReasonCode> missingReasonCodes;
  final List<DeepCandidateReasonCode> expectedSuppressionsSatisfied;
  final List<DeepCandidateReasonCode> expectedSuppressionsMissing;
  final List<GoldenMotifGroup> motifGroups;
  final List<GoldenMotifEvidenceGroup> motifEvidenceGroups;
  final List<GoldenMotifEvidenceGroup> satisfiedMotifEvidenceGroups;
  final List<GoldenMotifEvidenceGroup> missingMotifEvidenceGroups;
  final List<String> missingMotifEvidence;
  final GoldenEvidenceBudgetStatus budgetExpectationStatus;
  final bool realEngineEvidenceNeeded;
  final List<String> warnings;
  final List<String> failures;
  final String nextAction;

  bool get passedLike =>
      status == GoldenEvidenceReviewStatus.passed ||
      status == GoldenEvidenceReviewStatus.passedWithWarnings;
}

class GoldenEvidenceReviewResult {
  const GoldenEvidenceReviewResult({
    required this.status,
    required this.totalCases,
    required this.passed,
    required this.warnings,
    required this.incomplete,
    required this.failed,
    required this.needsRealDeviceEvidenceCount,
    required this.behaviorMismatches,
    required this.budgetMismatches,
    required this.blockedUnsafeClaims,
    required this.caseReviews,
    required this.motifCoverage,
    required this.motifGroupCoverage,
    required this.motifEvidenceGroupCoverage,
    required this.casesMissingMotifEvidence,
    required this.categoryCoverage,
    required this.developerRecommendation,
    required this.realDeviceEvidenceCommand,
  }) : assert(totalCases >= 0),
       assert(passed >= 0),
       assert(warnings >= 0),
       assert(incomplete >= 0),
       assert(failed >= 0),
       assert(needsRealDeviceEvidenceCount >= 0),
       assert(behaviorMismatches >= 0),
       assert(budgetMismatches >= 0),
       assert(blockedUnsafeClaims >= 0),
       assert(casesMissingMotifEvidence >= 0);

  final GoldenEvidenceReviewStatus status;
  final int totalCases;
  final int passed;
  final int warnings;
  final int incomplete;
  final int failed;
  final int needsRealDeviceEvidenceCount;
  final int behaviorMismatches;
  final int budgetMismatches;
  final int blockedUnsafeClaims;
  final List<GoldenEvidenceCaseReview> caseReviews;
  final Map<GoldenMotifTag, int> motifCoverage;
  final Map<GoldenMotifGroup, int> motifGroupCoverage;
  final Map<GoldenMotifEvidenceGroup, int> motifEvidenceGroupCoverage;
  final int casesMissingMotifEvidence;
  final Map<GoldenAnalysisCategory, int> categoryCoverage;
  final String developerRecommendation;
  final String realDeviceEvidenceCommand;

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Golden Evidence Review')
      ..writeln()
      ..writeln('- status: ${status.wire}')
      ..writeln('- total cases: $totalCases')
      ..writeln('- passed: $passed')
      ..writeln('- warnings: $warnings')
      ..writeln('- incomplete: $incomplete')
      ..writeln('- failed: $failed')
      ..writeln('- needs real-device evidence: $needsRealDeviceEvidenceCount')
      ..writeln('- behavior mismatches: $behaviorMismatches')
      ..writeln('- budget mismatches: $budgetMismatches')
      ..writeln('- blocked unsafe claims: $blockedUnsafeClaims')
      ..writeln('- cases missing motif evidence: $casesMissingMotifEvidence')
      ..writeln()
      ..writeln('## Case Summary')
      ..writeln('| Case | Category | Status | Evidence Gaps | Next Action |')
      ..writeln('| --- | --- | --- | --- | --- |');
    for (final review in caseReviews) {
      final missing = [
        ...review.missingReasonCodes.map((reason) => reason.wire),
        ...review.expectedSuppressionsMissing.map((reason) => reason.wire),
        ...review.missingMotifEvidence,
      ].join(',');
      buffer.writeln(
        '| ${review.caseId} | ${review.category.wire} | '
        '${review.status.wire} | ${missing.isEmpty ? '-' : missing} | '
        '${review.nextAction} |',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Motif Coverage');
    for (final entry in _sortedEnumCounts(motifCoverage)) {
      buffer.writeln('- ${entry.key.wire}: ${entry.value}');
    }

    buffer
      ..writeln()
      ..writeln('## Motif Group Coverage');
    for (final entry in _sortedEnumCounts(motifGroupCoverage)) {
      buffer.writeln('- ${entry.key.wire}: ${entry.value}');
    }

    buffer
      ..writeln()
      ..writeln('## Motif Evidence Group Coverage');
    for (final entry in _sortedEnumCounts(motifEvidenceGroupCoverage)) {
      buffer.writeln('- ${entry.key.wire}: ${entry.value}');
    }

    buffer
      ..writeln()
      ..writeln('## Category Coverage');
    for (final entry in _sortedEnumCounts(categoryCoverage)) {
      buffer.writeln('- ${entry.key.wire}: ${entry.value}');
    }

    final missingMotif = caseReviews
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

    final realNeeded = caseReviews
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
        ..writeln(realDeviceEvidenceCommand)
        ..writeln('```');
    }

    final mismatches = caseReviews
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
        ..writeln('## Mismatches');
      for (final review in mismatches) {
        buffer.writeln('- ${review.caseId}: ${review.failures.join("; ")}');
      }
    }

    buffer
      ..writeln()
      ..writeln('## Recommendation')
      ..writeln(developerRecommendation);
    return buffer.toString();
  }
}

class GoldenEvidenceReviewRunner {
  const GoldenEvidenceReviewRunner({
    this.suiteRunner = const GoldenAnalysisSuiteRunner(),
    this.motifEvidencePolicy = const GoldenMotifEvidencePolicy(),
  });

  final GoldenAnalysisSuiteRunner suiteRunner;
  final GoldenMotifEvidencePolicy motifEvidencePolicy;

  GoldenEvidenceReviewResult review(GoldenEvidenceReviewRequest request) {
    final suiteResult = suiteRunner.run(
      GoldenAnalysisSuiteRequest(
        cases: request.cases,
        mode: _suiteModeFor(request.mode),
        profile: request.profile,
      ),
    );
    final resultById = <String, GoldenAnalysisCaseResult>{
      for (final result in suiteResult.caseResults) result.caseId: result,
    };
    final reviews = <GoldenEvidenceCaseReview>[
      for (final item in request.cases)
        _reviewCase(
          item,
          resultById[item.id],
          mode: request.mode,
          includeFutureRealEngineNeeds: request.includeFutureRealEngineNeeds,
          motifEvidencePolicy: motifEvidencePolicy,
        ),
    ];
    final status = _aggregateStatus(
      reviews,
      requireAllEvidence: request.requireAllEvidence,
      referenceOnly:
          request.mode ==
          GoldenEvidenceReviewMode.realDeviceEvidenceReferenceOnly,
    );
    return GoldenEvidenceReviewResult(
      status: status,
      totalCases: request.cases.length,
      passed: reviews.where((review) => review.passedLike).length,
      warnings: reviews.where((review) => review.warnings.isNotEmpty).length,
      incomplete: reviews
          .where(
            (review) =>
                review.status == GoldenEvidenceReviewStatus.incompleteEvidence,
          )
          .length,
      failed: reviews
          .where(
            (review) =>
                review.status == GoldenEvidenceReviewStatus.failed ||
                review.status == GoldenEvidenceReviewStatus.behaviorMismatch ||
                review.status == GoldenEvidenceReviewStatus.budgetMismatch ||
                review.status == GoldenEvidenceReviewStatus.blockedUnsafeClaim,
          )
          .length,
      needsRealDeviceEvidenceCount: reviews
          .where((review) => review.realEngineEvidenceNeeded)
          .length,
      behaviorMismatches: reviews
          .where(
            (review) =>
                review.status == GoldenEvidenceReviewStatus.behaviorMismatch,
          )
          .length,
      budgetMismatches: reviews
          .where(
            (review) =>
                review.status == GoldenEvidenceReviewStatus.budgetMismatch,
          )
          .length,
      blockedUnsafeClaims: reviews
          .where(
            (review) =>
                review.status == GoldenEvidenceReviewStatus.blockedUnsafeClaim,
          )
          .length,
      caseReviews: List<GoldenEvidenceCaseReview>.unmodifiable(reviews),
      motifCoverage: _motifCoverage(request.cases),
      motifGroupCoverage: _motifGroupCoverage(
        request.cases,
        motifEvidencePolicy,
      ),
      motifEvidenceGroupCoverage: _motifEvidenceGroupCoverage(
        request.cases,
        motifEvidencePolicy,
      ),
      casesMissingMotifEvidence: reviews
          .where((review) => review.missingMotifEvidence.isNotEmpty)
          .length,
      categoryCoverage: _categoryCoverage(request.cases),
      developerRecommendation: _recommendationFor(status),
      realDeviceEvidenceCommand: _realDeviceEvidenceCommand,
    );
  }

  GoldenEvidenceCaseReview _reviewCase(
    GoldenAnalysisCase item,
    GoldenAnalysisCaseResult? suiteCase, {
    required GoldenEvidenceReviewMode mode,
    required bool includeFutureRealEngineNeeds,
    required GoldenMotifEvidencePolicy motifEvidencePolicy,
  }) {
    final warnings = <String>[...?suiteCase?.warnings];
    final failures = <String>[...?suiteCase?.failures];
    final motifRequirement = motifEvidencePolicy.requirementsFor(
      item.motifTags,
    );
    final motifEvidence = motifRequirement.evidence.merge(
      item.expected.evidence.tactical,
    );
    final expectedReasons = item.expected.evidence.expectedReasonCodes;
    final satisfiedReasons = _sortedReasons(
      expectedReasons
          .where(
            (reason) => suiteCase?.reasonCounts.containsKey(reason) ?? false,
          )
          .toList(),
    );
    final missingReasons = _sortedReasons(
      expectedReasons
          .where(
            (reason) => !(suiteCase?.reasonCounts.containsKey(reason) ?? false),
          )
          .toList(),
    );
    final expectedSuppressions =
        item.expected.evidence.expectedSuppressionReasons;
    final satisfiedSuppressions = _sortedReasons(
      expectedSuppressions
          .where(
            (reason) =>
                suiteCase?.suppressionCounts.containsKey(reason) ?? false,
          )
          .toList(),
    );
    final missingSuppressions = _sortedReasons(
      expectedSuppressions
          .where(
            (reason) =>
                !(suiteCase?.suppressionCounts.containsKey(reason) ?? false),
          )
          .toList(),
    );
    final budgetStatus = _budgetStatusFor(failures);
    final missingMotifEvidence = _missingMotifEvidence(
      item: item,
      suiteCase: suiteCase,
      mode: mode,
      expectation: motifEvidence,
    );
    final missingMotifGroups = _motifEvidenceGroupsFromGaps(
      missingMotifEvidence,
    );
    final motifEvidenceGroups = _sortedEvidenceGroups(
      motifEvidence.evidenceGroups,
    );
    final needsReal =
        mode != GoldenEvidenceReviewMode.metadataOnly &&
        includeFutureRealEngineNeeds &&
        (item.expected.evidence.pvShouldBeNonEmpty ||
            item.expected.evidence.tactical.requiresRealDeviceProof ||
            motifRequirement.requiresFutureRealDeviceProof ||
            mode == GoldenEvidenceReviewMode.realDeviceEvidenceReferenceOnly &&
                _needsRealDeviceReference(item));
    final pendingRealGroups = needsReal
        ? const {GoldenMotifEvidenceGroup.realDeviceProof}
        : const <GoldenMotifEvidenceGroup>{};
    final satisfiedMotifGroups = _sortedEvidenceGroups(
      motifEvidence.evidenceGroups
          .difference(missingMotifGroups.toSet())
          .difference(pendingRealGroups),
    );

    if (mode == GoldenEvidenceReviewMode.planOnly &&
        (_needsFakeEvidence(item, missingReasons) ||
            motifRequirement.requiresFakeEvidence &&
                item.fakeEvidence.isEmpty)) {
      warnings.add('fake evidence needed for full reason-code review');
    }
    if (needsReal) {
      warnings.add('future real-device selected-deep evidence needed');
    }

    final status = _caseStatusFor(
      item: item,
      suiteCase: suiteCase,
      mode: mode,
      missingReasons: missingReasons,
      missingSuppressions: missingSuppressions,
      missingMotifEvidence: missingMotifEvidence,
      budgetStatus: budgetStatus,
      needsReal: needsReal,
      warnings: warnings,
      failures: failures,
    );

    return GoldenEvidenceCaseReview(
      caseId: item.id,
      category: item.category,
      motifs: List<GoldenMotifTag>.unmodifiable(item.motifTags),
      status: status,
      expectedBehaviorsChecked: _sortedBehaviors(item.expected.behaviors),
      evidenceExpectationsChecked: _evidenceExpectationLabels(item.expected),
      satisfiedReasonCodes: satisfiedReasons,
      missingReasonCodes: missingReasons,
      expectedSuppressionsSatisfied: satisfiedSuppressions,
      expectedSuppressionsMissing: missingSuppressions,
      motifGroups: _sortedMotifGroups(motifRequirement.motifGroups),
      motifEvidenceGroups: motifEvidenceGroups,
      satisfiedMotifEvidenceGroups: satisfiedMotifGroups,
      missingMotifEvidenceGroups: missingMotifGroups,
      missingMotifEvidence: List<String>.unmodifiable(missingMotifEvidence),
      budgetExpectationStatus: budgetStatus,
      realEngineEvidenceNeeded: needsReal,
      warnings: List<String>.unmodifiable(warnings),
      failures: List<String>.unmodifiable(failures),
      nextAction: _nextActionFor(status),
    );
  }
}

GoldenAnalysisSuiteMode _suiteModeFor(GoldenEvidenceReviewMode mode) {
  return switch (mode) {
    GoldenEvidenceReviewMode.metadataOnly =>
      GoldenAnalysisSuiteMode.metadataOnly,
    GoldenEvidenceReviewMode.planOnly => GoldenAnalysisSuiteMode.planOnly,
    GoldenEvidenceReviewMode.fakeEvidence ||
    GoldenEvidenceReviewMode.realDeviceEvidenceReferenceOnly =>
      GoldenAnalysisSuiteMode.fakeEvidence,
  };
}

GoldenEvidenceReviewStatus _caseStatusFor({
  required GoldenAnalysisCase item,
  required GoldenAnalysisCaseResult? suiteCase,
  required GoldenEvidenceReviewMode mode,
  required List<DeepCandidateReasonCode> missingReasons,
  required List<DeepCandidateReasonCode> missingSuppressions,
  required List<String> missingMotifEvidence,
  required GoldenEvidenceBudgetStatus budgetStatus,
  required bool needsReal,
  required List<String> warnings,
  required List<String> failures,
}) {
  if (!item.safety.explicitlySafe ||
      !item.safety.noFinalLabel ||
      item.containsBlockedClaim) {
    return GoldenEvidenceReviewStatus.blockedUnsafeClaim;
  }
  if (suiteCase == null) return GoldenEvidenceReviewStatus.failed;
  if (mode == GoldenEvidenceReviewMode.metadataOnly) {
    if (failures.isNotEmpty) return GoldenEvidenceReviewStatus.failed;
    if (warnings.isNotEmpty) {
      return GoldenEvidenceReviewStatus.passedWithWarnings;
    }
    return GoldenEvidenceReviewStatus.passed;
  }
  if (_needsFakeEvidence(item, missingReasons)) {
    return GoldenEvidenceReviewStatus.incompleteEvidence;
  }
  if (budgetStatus == GoldenEvidenceBudgetStatus.mismatch) {
    return GoldenEvidenceReviewStatus.budgetMismatch;
  }
  if (missingSuppressions.isNotEmpty) {
    return GoldenEvidenceReviewStatus.behaviorMismatch;
  }
  if (missingMotifEvidence.isNotEmpty) {
    return GoldenEvidenceReviewStatus.incompleteEvidence;
  }
  if (failures.isNotEmpty) {
    return GoldenEvidenceReviewStatus.behaviorMismatch;
  }
  if (needsReal) return GoldenEvidenceReviewStatus.needsRealEngineEvidence;
  if (warnings.isNotEmpty) {
    return GoldenEvidenceReviewStatus.passedWithWarnings;
  }
  return GoldenEvidenceReviewStatus.passed;
}

GoldenEvidenceReviewStatus _aggregateStatus(
  List<GoldenEvidenceCaseReview> reviews, {
  required bool requireAllEvidence,
  required bool referenceOnly,
}) {
  if (reviews.any(
    (review) => review.status == GoldenEvidenceReviewStatus.blockedUnsafeClaim,
  )) {
    return GoldenEvidenceReviewStatus.blockedUnsafeClaim;
  }
  if (reviews.any(
    (review) => review.status == GoldenEvidenceReviewStatus.budgetMismatch,
  )) {
    return GoldenEvidenceReviewStatus.budgetMismatch;
  }
  if (reviews.any(
    (review) => review.status == GoldenEvidenceReviewStatus.behaviorMismatch,
  )) {
    return GoldenEvidenceReviewStatus.behaviorMismatch;
  }
  if (reviews.any(
    (review) => review.status == GoldenEvidenceReviewStatus.failed,
  )) {
    return GoldenEvidenceReviewStatus.failed;
  }
  if (reviews.any(
    (review) => review.status == GoldenEvidenceReviewStatus.incompleteEvidence,
  )) {
    return GoldenEvidenceReviewStatus.incompleteEvidence;
  }
  if ((requireAllEvidence || referenceOnly) &&
      reviews.any(
        (review) =>
            review.status == GoldenEvidenceReviewStatus.needsRealEngineEvidence,
      )) {
    return GoldenEvidenceReviewStatus.needsRealEngineEvidence;
  }
  if (reviews.any(
    (review) =>
        review.status == GoldenEvidenceReviewStatus.needsRealEngineEvidence ||
        review.status == GoldenEvidenceReviewStatus.passedWithWarnings,
  )) {
    return GoldenEvidenceReviewStatus.passedWithWarnings;
  }
  return GoldenEvidenceReviewStatus.passed;
}

GoldenEvidenceBudgetStatus _budgetStatusFor(List<String> failures) {
  if (failures.any(_isBudgetFailure)) {
    return GoldenEvidenceBudgetStatus.mismatch;
  }
  return failures.isEmpty
      ? GoldenEvidenceBudgetStatus.satisfied
      : GoldenEvidenceBudgetStatus.notApplicable;
}

bool _isBudgetFailure(String value) {
  final lower = value.toLowerCase();
  return lower.contains('budget') ||
      lower.contains('cap') ||
      lower.contains('selected-deep ratio');
}

bool _needsFakeEvidence(
  GoldenAnalysisCase item,
  List<DeepCandidateReasonCode> missingReasons,
) {
  final evidence = item.expected.evidence;
  if (evidence.mateScoreExpected && missingReasons.isNotEmpty) return true;
  if (evidence.mateScoreExpected &&
      !item.fakeEvidence.any((entry) => entry.mateIn != null)) {
    return true;
  }
  return missingReasons.isNotEmpty && item.fakeEvidence.isEmpty;
}

bool _needsRealDeviceReference(GoldenAnalysisCase item) {
  final evidence = item.expected.evidence;
  return evidence.pvShouldBeNonEmpty ||
      evidence.tactical.requiresRealDeviceProof ||
      const GoldenMotifEvidencePolicy().requiresFutureRealDeviceProof(
        item.motifTags,
      ) ||
      evidence.minMultiPvIfSelected != null ||
      item.expected.expects(
        GoldenExpectedBehaviorCode.shouldUseMultiPvAtLeast2,
      );
}

List<String> _missingMotifEvidence({
  required GoldenAnalysisCase item,
  required GoldenAnalysisCaseResult? suiteCase,
  required GoldenEvidenceReviewMode mode,
  required GoldenTacticalEvidenceExpectation expectation,
}) {
  if (mode == GoldenEvidenceReviewMode.metadataOnly || suiteCase == null) {
    return const <String>[];
  }

  final reasons = suiteCase.reasonCounts.keys.toSet();
  final suppressions = suiteCase.suppressionCounts.keys.toSet();
  final missing = <String>{};

  bool hasReason(Iterable<DeepCandidateReasonCode> values) {
    return values.any(reasons.contains);
  }

  bool hasSuppression(Iterable<DeepCandidateReasonCode> values) {
    return values.any(suppressions.contains);
  }

  bool hasReasonOrSuppression(Iterable<DeepCandidateReasonCode> values) {
    return hasReason(values) || hasSuppression(values);
  }

  if (expectation.requiresMaterialSwing &&
      !hasReason(const {
        DeepCandidateReasonCode.materialSwing,
        DeepCandidateReasonCode.majorEvalSwing,
      })) {
    missing.add('material:materialSwing');
  }
  if (expectation.requiresMaterialCompensation &&
      !hasReason(
        expectation.materialReasons.isEmpty
            ? _materialFallbackReasons
            : expectation.materialReasons,
      )) {
    missing.add('material:materialCompensation');
  }
  if (expectation.materialReasons.isNotEmpty &&
      !hasReason(expectation.materialReasons)) {
    missing.add('material:materialReasons');
  }
  if (expectation.tacticalReasons.isNotEmpty &&
      !hasReason(expectation.tacticalReasons)) {
    missing.add('tactical:tacticalReasons');
  }
  if (expectation.requiresMateSignal &&
      !hasReason(
        expectation.kingSafetyReasons.isEmpty
            ? _mateFallbackReasons
            : expectation.kingSafetyReasons,
      )) {
    missing.add('kingSafety:mateSignal');
  }
  if (expectation.requiresKingSafetySignal &&
      !hasReason(
        expectation.kingSafetyReasons.isEmpty
            ? _mateFallbackReasons
            : expectation.kingSafetyReasons,
      )) {
    missing.add('kingSafety:kingSafetySignal');
  }
  if (expectation.kingSafetyReasons.isNotEmpty &&
      !hasReason(expectation.kingSafetyReasons)) {
    missing.add('kingSafety:kingSafetyReasons');
  }
  if (expectation.requiresForcingLineSignal &&
      !hasReasonOrSuppression({
        ..._forcingFallbackReasons,
        DeepCandidateReasonCode.forcedSuppressed,
        ...expectation.forcingReasons,
      })) {
    missing.add('forcing:forcingLineSignal');
  }
  if (expectation.forcingReasons.isNotEmpty &&
      !hasReasonOrSuppression({
        ...expectation.forcingReasons,
        DeepCandidateReasonCode.forcedSuppressed,
      })) {
    missing.add('forcing:forcingReasons');
  }
  if (expectation.requiresOnlyMoveSignal &&
      !hasSuppression(const {DeepCandidateReasonCode.forcedSuppressed})) {
    missing.add('suppression:onlyMoveSignal');
  }
  if (expectation.requiresQuietMoveEvidence &&
      !hasReason(expectation.uncertaintyReasons) &&
      item.fakeEvidence.isEmpty) {
    missing.add('uncertainty:quietMoveEvidence');
  }
  if (expectation.requiresCandidateSpread &&
      !hasReason(const {DeepCandidateReasonCode.candidateEvalSpread})) {
    missing.add('forcing:candidateSpread');
  }
  if (expectation.requiresMultiPvEvidence &&
      item.expected.evidence.minMultiPvIfSelected == null &&
      !item.expected.expects(
        GoldenExpectedBehaviorCode.shouldUseMultiPvAtLeast2,
      )) {
    missing.add('tactical:multiPvEvidence');
  }
  if (expectation.requiresBudgetPressure &&
      !hasSuppression(const {DeepCandidateReasonCode.budgetSuppressed})) {
    missing.add('budget:budgetPressure');
  }
  final expectedSuppressions = expectation.suppressionReasons.isEmpty
      ? item.expected.evidence.expectedSuppressionReasons
      : expectation.suppressionReasons;
  if (expectation.requiresSuppressionReason &&
      !hasSuppression(expectedSuppressions)) {
    missing.add('suppression:suppressionReason');
  }
  if (expectation.suppressionReasons.isNotEmpty &&
      !hasSuppression(expectation.suppressionReasons)) {
    missing.add('suppression:suppressionReasons');
  }
  if (expectation.uncertaintyReasons.isNotEmpty &&
      item.motifTags.contains(GoldenMotifTag.evidenceIncomplete) &&
      !hasReason(expectation.uncertaintyReasons) &&
      item.fakeEvidence.isEmpty) {
    missing.add('uncertainty:evidenceIncomplete');
  }

  return missing.toList()..sort();
}

const _materialFallbackReasons = <DeepCandidateReasonCode>{
  DeepCandidateReasonCode.materialSwing,
  DeepCandidateReasonCode.captureOrPromotion,
};

const _mateFallbackReasons = <DeepCandidateReasonCode>{
  DeepCandidateReasonCode.mateScoreDetected,
  DeepCandidateReasonCode.tacticalSignal,
  DeepCandidateReasonCode.givesCheck,
};

const _forcingFallbackReasons = <DeepCandidateReasonCode>{
  DeepCandidateReasonCode.tacticalSignal,
  DeepCandidateReasonCode.givesCheck,
  DeepCandidateReasonCode.candidateEvalSpread,
  DeepCandidateReasonCode.mateScoreDetected,
};

List<String> _evidenceExpectationLabels(GoldenExpectedBehavior expected) {
  final labels = <String>[];
  final evidence = expected.evidence;
  if (evidence.evalSwingMinCp != null) {
    labels.add('evalSwingMinCp=${evidence.evalSwingMinCp}');
  }
  if (evidence.candidateSpreadMinCp != null) {
    labels.add('candidateSpreadMinCp=${evidence.candidateSpreadMinCp}');
  }
  if (evidence.materialSwingMinCp != null) {
    labels.add('materialSwingMinCp=${evidence.materialSwingMinCp}');
  }
  if (evidence.mateScoreExpected) labels.add('mateScoreExpected');
  if (evidence.pvShouldBeNonEmpty) labels.add('pvNonEmptyFutureProof');
  if (evidence.minMultiPvIfSelected != null) {
    labels.add('minMultiPv=${evidence.minMultiPvIfSelected}');
  }
  labels.addAll(
    evidence.tactical.evidenceGroups.map(
      (group) => 'motifEvidenceGroup=${group.wire}',
    ),
  );
  if (evidence.tactical.requiresMaterialSwing) {
    labels.add('requiresMaterialSwing');
  }
  if (evidence.tactical.requiresMaterialCompensation) {
    labels.add('requiresMaterialCompensation');
  }
  if (evidence.tactical.requiresMateSignal) labels.add('requiresMateSignal');
  if (evidence.tactical.requiresForcingLineSignal) {
    labels.add('requiresForcingLineSignal');
  }
  if (evidence.tactical.requiresKingSafetySignal) {
    labels.add('requiresKingSafetySignal');
  }
  if (evidence.tactical.requiresOnlyMoveSignal) {
    labels.add('requiresOnlyMoveSignal');
  }
  if (evidence.tactical.requiresQuietMoveEvidence) {
    labels.add('requiresQuietMoveEvidence');
  }
  if (evidence.tactical.requiresCandidateSpread) {
    labels.add('requiresCandidateSpread');
  }
  if (evidence.tactical.requiresMultiPvEvidence) {
    labels.add('requiresMultiPvEvidence');
  }
  if (evidence.tactical.requiresBudgetPressure) {
    labels.add('requiresBudgetPressure');
  }
  if (evidence.tactical.requiresSuppressionReason) {
    labels.add('requiresSuppressionReason');
  }
  if (evidence.tactical.requiresRealDeviceProof) {
    labels.add('requiresRealDeviceProof');
  }
  labels.addAll(evidence.expectedReasonCodes.map((reason) => reason.wire));
  labels.addAll(
    evidence.expectedSuppressionReasons.map((reason) => reason.wire),
  );
  labels.sort();
  return List<String>.unmodifiable(labels);
}

Map<GoldenMotifTag, int> _motifCoverage(List<GoldenAnalysisCase> cases) {
  final counts = <GoldenMotifTag, int>{};
  for (final item in cases) {
    for (final motif in item.motifTags) {
      counts[motif] = (counts[motif] ?? 0) + 1;
    }
  }
  return Map<GoldenMotifTag, int>.unmodifiable(counts);
}

Map<GoldenMotifGroup, int> _motifGroupCoverage(
  List<GoldenAnalysisCase> cases,
  GoldenMotifEvidencePolicy policy,
) {
  final counts = <GoldenMotifGroup, int>{};
  for (final item in cases) {
    final groups = policy.requirementsFor(item.motifTags).motifGroups;
    for (final group in groups) {
      counts[group] = (counts[group] ?? 0) + 1;
    }
  }
  return Map<GoldenMotifGroup, int>.unmodifiable(counts);
}

Map<GoldenMotifEvidenceGroup, int> _motifEvidenceGroupCoverage(
  List<GoldenAnalysisCase> cases,
  GoldenMotifEvidencePolicy policy,
) {
  final counts = <GoldenMotifEvidenceGroup, int>{};
  for (final item in cases) {
    final requirement = policy.requirementsFor(item.motifTags);
    final evidence = requirement.evidence.merge(
      item.expected.evidence.tactical,
    );
    for (final group in evidence.evidenceGroups) {
      counts[group] = (counts[group] ?? 0) + 1;
    }
  }
  return Map<GoldenMotifEvidenceGroup, int>.unmodifiable(counts);
}

Map<GoldenAnalysisCategory, int> _categoryCoverage(
  List<GoldenAnalysisCase> cases,
) {
  final counts = <GoldenAnalysisCategory, int>{};
  for (final item in cases) {
    counts[item.category] = (counts[item.category] ?? 0) + 1;
  }
  return Map<GoldenAnalysisCategory, int>.unmodifiable(counts);
}

List<GoldenExpectedBehaviorCode> _sortedBehaviors(
  Set<GoldenExpectedBehaviorCode> values,
) {
  return values.toList()..sort((a, b) => a.wire.compareTo(b.wire));
}

List<GoldenMotifGroup> _sortedMotifGroups(Iterable<GoldenMotifGroup> values) {
  return values.toList()..sort((a, b) => a.wire.compareTo(b.wire));
}

List<GoldenMotifEvidenceGroup> _sortedEvidenceGroups(
  Iterable<GoldenMotifEvidenceGroup> values,
) {
  return values.toList()..sort((a, b) => a.wire.compareTo(b.wire));
}

List<GoldenMotifEvidenceGroup> _motifEvidenceGroupsFromGaps(
  Iterable<String> gaps,
) {
  final groups = <GoldenMotifEvidenceGroup>{};
  for (final gap in gaps) {
    final prefix = gap.split(':').first;
    for (final group in GoldenMotifEvidenceGroup.values) {
      if (group.wire == prefix) {
        groups.add(group);
        break;
      }
    }
  }
  return _sortedEvidenceGroups(groups);
}

List<DeepCandidateReasonCode> _sortedReasons(
  Iterable<DeepCandidateReasonCode> values,
) {
  return values.toList()..sort((a, b) => a.wire.compareTo(b.wire));
}

List<MapEntry<T, int>> _sortedEnumCounts<T extends Enum>(Map<T, int> counts) {
  return counts.entries.toList()
    ..sort((a, b) => a.key.name.compareTo(b.key.name));
}

String _recommendationFor(GoldenEvidenceReviewStatus status) {
  return switch (status) {
    GoldenEvidenceReviewStatus.passed =>
      'Golden evidence is ready for the next developer-only review step.',
    GoldenEvidenceReviewStatus.passedWithWarnings =>
      'Golden evidence is usable, but incomplete evidence rows should be '
          'tracked before classifier work.',
    GoldenEvidenceReviewStatus.incompleteEvidence =>
      'Add fake evidence or clarify expectations before relying on these cases.',
    GoldenEvidenceReviewStatus.needsRealEngineEvidence =>
      'Run opt-in real-device selected-deep proof for listed cases.',
    GoldenEvidenceReviewStatus.behaviorMismatch =>
      'Fix deep-gating behavior or correct the golden expectation.',
    GoldenEvidenceReviewStatus.budgetMismatch =>
      'Fix budget caps or selected-deep guardrails before widening review.',
    GoldenEvidenceReviewStatus.blockedUnsafeClaim =>
      'Remove unsafe claims from golden cases before proceeding.',
    GoldenEvidenceReviewStatus.failed =>
      'Fix golden review failures before further analysis work.',
  };
}

String _nextActionFor(GoldenEvidenceReviewStatus status) {
  return switch (status) {
    GoldenEvidenceReviewStatus.passed => 'protected',
    GoldenEvidenceReviewStatus.passedWithWarnings => 'review warnings',
    GoldenEvidenceReviewStatus.incompleteEvidence => 'add fake evidence',
    GoldenEvidenceReviewStatus.needsRealEngineEvidence =>
      'run real-device proof later',
    GoldenEvidenceReviewStatus.behaviorMismatch => 'fix expectation or policy',
    GoldenEvidenceReviewStatus.budgetMismatch => 'fix budget guardrail',
    GoldenEvidenceReviewStatus.blockedUnsafeClaim => 'remove unsafe claim',
    GoldenEvidenceReviewStatus.failed => 'fix metadata or expectation',
  };
}

const _realDeviceEvidenceCommand =
    'flutter test integration_test/local_review_pgn_fixture_device_smoke_test.dart '
    '-d <android-device-id> '
    '--dart-define=APEX_RUN_LOCAL_REVIEW_PGN_FIXTURE_DEVICE_SMOKE=true';

/// Deterministic evidence-to-classifier readiness gate for golden cases.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_review.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_triage.dart';

const goldenClassifierReadinessReportVersion =
    'golden-classifier-readiness-gate-v1';

enum GoldenClassifierReadinessStatus {
  notReady('notReady'),
  blockedByUnsafeClaim('blockedByUnsafeClaim'),
  blockedByMismatch('blockedByMismatch'),
  blockedByRealDeviceProof('blockedByRealDeviceProof'),
  blockedByIncompleteEvidence('blockedByIncompleteEvidence'),
  readyForEvidenceOnly('readyForEvidenceOnly'),
  readyForBasicClassifierFoundation('readyForBasicClassifierFoundation'),
  readyForLimitedClassifierFoundation('readyForLimitedClassifierFoundation'),
  notReadyForAdvancedLabels('notReadyForAdvancedLabels');

  const GoldenClassifierReadinessStatus(this.wire);

  final String wire;
}

enum GoldenClassifierScope {
  basicMoveQualityFoundation('basicMoveQualityFoundation'),
  tacticalCandidateFoundation('tacticalCandidateFoundation'),
  materialSwingFoundation('materialSwingFoundation'),
  kingSafetyFoundation('kingSafetyFoundation'),
  forcingLineFoundation('forcingLineFoundation'),
  quietPreparatoryFoundation('quietPreparatoryFoundation'),
  endgamePrecisionFoundation('endgamePrecisionFoundation'),
  brilliantCandidateGate('brilliantCandidateGate'),
  greatMoveCandidateGate('greatMoveCandidateGate'),
  missedWinCandidateGate('missedWinCandidateGate'),
  productFacingLabels('productFacingLabels');

  const GoldenClassifierScope(this.wire);

  final String wire;
}

enum GoldenClassifierScopeStatus {
  allowedForDesignOnly('allowedForDesignOnly'),
  allowedForDeveloperPrototype('allowedForDeveloperPrototype'),
  blockedByEvidence('blockedByEvidence'),
  blockedByIncompleteCases('blockedByIncompleteCases'),
  blockedByMissingProof('blockedByMissingProof'),
  blockedByPolicy('blockedByPolicy');

  const GoldenClassifierScopeStatus(this.wire);

  final String wire;
}

enum GoldenClassifierNextPhase {
  quietPreparatoryEvidenceResolution(
    'Phase 30Y -- Quiet Preparatory Evidence Resolution',
  ),
  basicClassifierFoundationDesignOnly(
    'Phase 30Y -- Basic Classifier Foundation Design Only',
  ),
  ownerAndroidProofQueue('Phase 30Y -- Owner Android Proof Queue'),
  mismatchInvestigation('Phase 30Y -- Mismatch Investigation');

  const GoldenClassifierNextPhase(this.wire);

  final String wire;
}

enum GoldenClassifierReadinessReportFormat {
  markdown('markdown'),
  json('json');

  const GoldenClassifierReadinessReportFormat(this.wire);

  final String wire;
}

class GoldenClassifierReadinessRequest {
  const GoldenClassifierReadinessRequest({
    this.cases = GoldenAnalysisCases.defaults,
    this.review,
    this.triage,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.minimumProtectedCasesForBasicFoundation = 10,
    this.minimumProtectedCasesForMotifFoundation = 1,
  }) : assert(minimumProtectedCasesForBasicFoundation >= 0),
       assert(minimumProtectedCasesForMotifFoundation >= 0);

  final List<GoldenAnalysisCase> cases;
  final GoldenEvidenceReviewResult? review;
  final GoldenEvidenceTriageResult? triage;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final int minimumProtectedCasesForBasicFoundation;
  final int minimumProtectedCasesForMotifFoundation;
}

class GoldenClassifierScopeReadiness {
  const GoldenClassifierScopeReadiness({
    required this.scope,
    required this.status,
    required this.blockers,
    required this.supportingCaseIds,
    required this.missingCaseIds,
    required this.recommendation,
  });

  final GoldenClassifierScope scope;
  final GoldenClassifierScopeStatus status;
  final List<String> blockers;
  final List<String> supportingCaseIds;
  final List<String> missingCaseIds;
  final String recommendation;

  bool get isAllowed =>
      status == GoldenClassifierScopeStatus.allowedForDesignOnly ||
      status == GoldenClassifierScopeStatus.allowedForDeveloperPrototype;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'scope': scope.wire,
      'status': status.wire,
      'blockers': blockers,
      'supportingCaseIds': supportingCaseIds,
      'missingCaseIds': missingCaseIds,
      'recommendation': recommendation,
    };
  }
}

class GoldenClassifierReadinessResult {
  const GoldenClassifierReadinessResult({
    required this.status,
    required this.advancedLabelStatus,
    required this.totalCaseCount,
    required this.protectedCount,
    required this.incompleteCount,
    required this.realDeviceNeededCount,
    required this.mismatchCount,
    required this.behaviorMismatchCount,
    required this.budgetMismatchCount,
    required this.unsafeCount,
    required this.ownerProofQueueCount,
    required this.capturedAndroidProofCount,
    required this.capturedAndroidProofCaseIds,
    required this.incompleteCaseIds,
    required this.realDeviceNeededCaseIds,
    required this.ownerProofQueueCaseIds,
    required this.unsafeCaseIds,
    required this.mismatchCaseIds,
    required this.scopes,
    required this.blockers,
    required this.nextRecommendedPhase,
  });

  final GoldenClassifierReadinessStatus status;
  final GoldenClassifierReadinessStatus advancedLabelStatus;
  final int totalCaseCount;
  final int protectedCount;
  final int incompleteCount;
  final int realDeviceNeededCount;
  final int mismatchCount;
  final int behaviorMismatchCount;
  final int budgetMismatchCount;
  final int unsafeCount;
  final int ownerProofQueueCount;
  final int capturedAndroidProofCount;
  final List<String> capturedAndroidProofCaseIds;
  final List<String> incompleteCaseIds;
  final List<String> realDeviceNeededCaseIds;
  final List<String> ownerProofQueueCaseIds;
  final List<String> unsafeCaseIds;
  final List<String> mismatchCaseIds;
  final List<GoldenClassifierScopeReadiness> scopes;
  final List<String> blockers;
  final GoldenClassifierNextPhase nextRecommendedPhase;

  bool get hasUnsafeReadinessClaim {
    final byScope = {for (final scope in scopes) scope.scope: scope};
    final product = byScope[GoldenClassifierScope.productFacingLabels];
    if (product?.status != GoldenClassifierScopeStatus.blockedByPolicy) {
      return true;
    }
    for (final scope in _advancedScopes) {
      if (byScope[scope]?.status !=
          GoldenClassifierScopeStatus.blockedByPolicy) {
        return true;
      }
    }
    return false;
  }

  bool get isStrictlyBlocked =>
      hasUnsafeReadinessClaim ||
      unsafeCount > 0 ||
      mismatchCount > 0 ||
      realDeviceNeededCount > 0 ||
      ownerProofQueueCount > 0 ||
      incompleteCount > 0 ||
      status !=
          GoldenClassifierReadinessStatus.readyForBasicClassifierFoundation;

  GoldenClassifierScopeReadiness scope(GoldenClassifierScope scope) {
    return scopes.singleWhere((entry) => entry.scope == scope);
  }

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Golden Classifier Readiness Gate')
      ..writeln()
      ..writeln('- version: $goldenClassifierReadinessReportVersion')
      ..writeln('- status: ${status.wire}')
      ..writeln('- advanced label status: ${advancedLabelStatus.wire}')
      ..writeln('- this is not classifier work: true')
      ..writeln()
      ..writeln('## Summary')
      ..writeln('- total cases: $totalCaseCount')
      ..writeln('- protected count: $protectedCount')
      ..writeln('- incomplete count: $incompleteCount')
      ..writeln('- real-device-needed count: $realDeviceNeededCount')
      ..writeln('- mismatch count: $mismatchCount')
      ..writeln('- behavior mismatch count: $behaviorMismatchCount')
      ..writeln('- budget mismatch count: $budgetMismatchCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- captured Android proof count: $capturedAndroidProofCount')
      ..writeln()
      ..writeln('## Scope Readiness')
      ..writeln(
        '| Scope | Status | Supporting Cases | Open Cases | Blockers | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- |');

    for (final scope in scopes) {
      buffer.writeln(
        '| ${scope.scope.wire} | ${scope.status.wire} | '
        '${_cell(_ids(scope.supportingCaseIds))} | '
        '${_cell(_ids(scope.missingCaseIds))} | '
        '${_cell(scope.blockers.isEmpty ? "-" : scope.blockers.join("; "))} | '
        '${_cell(scope.recommendation)} |',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Blockers');
    if (blockers.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final blocker in blockers) {
        buffer.writeln('- $blocker');
      }
    }

    buffer
      ..writeln()
      ..writeln('## Evidence Lists')
      ..writeln('- incomplete case IDs: ${_ids(incompleteCaseIds)}')
      ..writeln(
        '- real-device-needed case IDs: ${_ids(realDeviceNeededCaseIds)}',
      )
      ..writeln('- owner proof queue case IDs: ${_ids(ownerProofQueueCaseIds)}')
      ..writeln(
        '- captured Android proof case IDs: '
        '${_ids(capturedAndroidProofCaseIds)}',
      )
      ..writeln()
      ..writeln('## Next Recommended Phase')
      ..writeln(nextRecommendedPhase.wire)
      ..writeln()
      ..writeln(
        'This report is a developer-only readiness gate. It decides whether '
        'evidence is sufficient for future design work, but it does not score '
        'or classify moves, does not change product review output, and does '
        'not emit product-facing labels.',
      );

    return buffer.toString();
  }

  String renderJsonReport() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': goldenClassifierReadinessReportVersion,
      'status': status.wire,
      'advancedLabelStatus': advancedLabelStatus.wire,
      'summary': <String, Object?>{
        'totalCases': totalCaseCount,
        'protectedCount': protectedCount,
        'incompleteCount': incompleteCount,
        'realDeviceNeededCount': realDeviceNeededCount,
        'mismatchCount': mismatchCount,
        'behaviorMismatchCount': behaviorMismatchCount,
        'budgetMismatchCount': budgetMismatchCount,
        'unsafeCount': unsafeCount,
        'ownerProofQueueCount': ownerProofQueueCount,
        'capturedAndroidProofCount': capturedAndroidProofCount,
      },
      'scopes': [for (final scope in scopes) scope.toJson()],
      'blockers': blockers,
      'incompleteCaseIds': incompleteCaseIds,
      'realDeviceNeededCaseIds': realDeviceNeededCaseIds,
      'ownerProofQueueCaseIds': ownerProofQueueCaseIds,
      'capturedAndroidProofCaseIds': capturedAndroidProofCaseIds,
      'unsafeCaseIds': unsafeCaseIds,
      'mismatchCaseIds': mismatchCaseIds,
      'nextRecommendedPhase': nextRecommendedPhase.wire,
      'developerOnly': true,
      'classifierWork': false,
      'productFacingLabelsReady': false,
    };
  }
}

class GoldenClassifierReadinessGate {
  const GoldenClassifierReadinessGate({
    this.reviewRunner = const GoldenEvidenceReviewRunner(),
    this.triageRunner = const GoldenEvidenceTriageRunner(),
    this.motifEvidencePolicy = const GoldenMotifEvidencePolicy(),
  });

  final GoldenEvidenceReviewRunner reviewRunner;
  final GoldenEvidenceTriageRunner triageRunner;
  final GoldenMotifEvidencePolicy motifEvidencePolicy;

  GoldenClassifierReadinessResult evaluate(
    GoldenClassifierReadinessRequest request,
  ) {
    final review =
        request.review ??
        reviewRunner.review(
          GoldenEvidenceReviewRequest(
            cases: request.cases,
            mode: GoldenEvidenceReviewMode.realDeviceEvidenceReferenceOnly,
            requireAllEvidence: true,
            androidProofEvidence: request.androidProofEvidence,
          ),
        );
    final triage =
        request.triage ??
        triageRunner.run(GoldenEvidenceTriageRequest(cases: request.cases));
    final caseById = <String, GoldenAnalysisCase>{
      for (final item in request.cases) item.id: item,
    };
    final reviewById = <String, GoldenEvidenceCaseReview>{
      for (final item in review.caseReviews) item.caseId: item,
    };

    final incompleteCaseIds = _caseIdsWithStatus(
      review,
      GoldenEvidenceReviewStatus.incompleteEvidence,
    );
    final realDeviceNeededCaseIds =
        review.caseReviews
            .where((item) => item.realEngineEvidenceNeeded)
            .map((item) => item.caseId)
            .toList()
          ..sort();
    final unsafeCaseIds = _caseIdsWithStatus(
      review,
      GoldenEvidenceReviewStatus.blockedUnsafeClaim,
    );
    final mismatchCaseIds =
        review.caseReviews
            .where(
              (item) =>
                  item.status == GoldenEvidenceReviewStatus.behaviorMismatch ||
                  item.status == GoldenEvidenceReviewStatus.budgetMismatch ||
                  item.status == GoldenEvidenceReviewStatus.failed,
            )
            .map((item) => item.caseId)
            .toList()
          ..sort();
    final ownerProofQueueCaseIds =
        triage.recommendedOwnerRunProofQueue.targetCaseIds.toList()..sort();
    final capturedProofCaseIds = _capturedAndroidProofCaseIds(
      request.androidProofEvidence,
    );
    final structuralFailureCount =
        review.failed -
        review.behaviorMismatches -
        review.budgetMismatches -
        review.blockedUnsafeClaims;
    final mismatchCount =
        review.behaviorMismatches +
        review.budgetMismatches +
        (structuralFailureCount < 0 ? 0 : structuralFailureCount);

    final globalBlockers = _globalBlockers(
      unsafeCaseIds: unsafeCaseIds,
      mismatchCaseIds: mismatchCaseIds,
      realDeviceNeededCaseIds: realDeviceNeededCaseIds,
      ownerProofQueueCaseIds: ownerProofQueueCaseIds,
    );
    final protectedCaseIds = review.caseReviews
        .where((item) => item.passedLike)
        .map((item) => item.caseId)
        .toSet();
    final protectedCount = protectedCaseIds.length;

    final scopes = <GoldenClassifierScopeReadiness>[
      _basicScope(
        caseById: caseById,
        reviewById: reviewById,
        protectedCaseIds: protectedCaseIds,
        globalBlockers: globalBlockers,
        minimumProtectedCases: request.minimumProtectedCasesForBasicFoundation,
      ),
      _motifScope(
        scope: GoldenClassifierScope.tacticalCandidateFoundation,
        caseById: caseById,
        reviewById: reviewById,
        protectedCaseIds: protectedCaseIds,
        globalBlockers: globalBlockers,
        minimumProtectedCases: request.minimumProtectedCasesForMotifFoundation,
        relevant: _isTacticalCase,
        allowedStatus: GoldenClassifierScopeStatus.allowedForDeveloperPrototype,
        allowedRecommendation:
            'Developer prototype only; use as candidate evidence, not labels.',
      ),
      _motifScope(
        scope: GoldenClassifierScope.materialSwingFoundation,
        caseById: caseById,
        reviewById: reviewById,
        protectedCaseIds: protectedCaseIds,
        globalBlockers: globalBlockers,
        minimumProtectedCases: request.minimumProtectedCasesForMotifFoundation,
        relevant: _isMaterialCase,
        allowedStatus: GoldenClassifierScopeStatus.allowedForDeveloperPrototype,
        allowedRecommendation:
            'Developer prototype only for material-swing evidence.',
      ),
      _motifScope(
        scope: GoldenClassifierScope.kingSafetyFoundation,
        caseById: caseById,
        reviewById: reviewById,
        protectedCaseIds: protectedCaseIds,
        globalBlockers: globalBlockers,
        minimumProtectedCases: request.minimumProtectedCasesForMotifFoundation,
        relevant: _isKingSafetyCase,
        allowedStatus: GoldenClassifierScopeStatus.allowedForDeveloperPrototype,
        allowedRecommendation:
            'Developer prototype only for king-safety evidence.',
      ),
      _motifScope(
        scope: GoldenClassifierScope.forcingLineFoundation,
        caseById: caseById,
        reviewById: reviewById,
        protectedCaseIds: protectedCaseIds,
        globalBlockers: globalBlockers,
        minimumProtectedCases: request.minimumProtectedCasesForMotifFoundation,
        relevant: _isForcingCase,
        allowedStatus: GoldenClassifierScopeStatus.allowedForDeveloperPrototype,
        allowedRecommendation:
            'Developer prototype only for forcing-line evidence.',
      ),
      _motifScope(
        scope: GoldenClassifierScope.quietPreparatoryFoundation,
        caseById: caseById,
        reviewById: reviewById,
        protectedCaseIds: protectedCaseIds,
        globalBlockers: globalBlockers,
        minimumProtectedCases: request.minimumProtectedCasesForMotifFoundation,
        relevant: _isQuietPreparatoryCase,
        allowedStatus: GoldenClassifierScopeStatus.allowedForDesignOnly,
        allowedRecommendation:
            'Design only after quiet-preparatory uncertainty is resolved.',
      ),
      _motifScope(
        scope: GoldenClassifierScope.endgamePrecisionFoundation,
        caseById: caseById,
        reviewById: reviewById,
        protectedCaseIds: protectedCaseIds,
        globalBlockers: globalBlockers,
        minimumProtectedCases: request.minimumProtectedCasesForMotifFoundation,
        relevant: _isEndgamePrecisionCase,
        allowedStatus: GoldenClassifierScopeStatus.allowedForDesignOnly,
        allowedRecommendation:
            'Design only; current evidence is conservative, not label-ready.',
      ),
      _policyBlockedScope(
        GoldenClassifierScope.brilliantCandidateGate,
        'Advanced candidate gates remain blocked by policy and evidence.',
      ),
      _policyBlockedScope(
        GoldenClassifierScope.greatMoveCandidateGate,
        'Advanced candidate gates remain blocked by policy and evidence.',
      ),
      _policyBlockedScope(
        GoldenClassifierScope.missedWinCandidateGate,
        'Advanced candidate gates remain blocked by policy and evidence.',
      ),
      _policyBlockedScope(
        GoldenClassifierScope.productFacingLabels,
        'Product-facing labels remain blocked until a later explicit gate.',
      ),
    ];

    final allBlockers = <String>{
      ...globalBlockers,
      if (incompleteCaseIds.isNotEmpty)
        'incomplete evidence remains visible: ${incompleteCaseIds.join(", ")}',
      'product-facing labels are blocked by policy',
      'advanced candidate gates are blocked by policy',
    }.toList()..sort();

    final result = GoldenClassifierReadinessResult(
      status: _overallStatus(
        unsafeCount: review.blockedUnsafeClaims,
        mismatchCount: mismatchCount,
        realDeviceNeededCount: realDeviceNeededCaseIds.length,
        ownerProofQueueCount: ownerProofQueueCaseIds.length,
        incompleteCount: incompleteCaseIds.length,
        scopes: scopes,
      ),
      advancedLabelStatus:
          GoldenClassifierReadinessStatus.notReadyForAdvancedLabels,
      totalCaseCount: review.totalCases,
      protectedCount: protectedCount,
      incompleteCount: incompleteCaseIds.length,
      realDeviceNeededCount: realDeviceNeededCaseIds.length,
      mismatchCount: mismatchCount,
      behaviorMismatchCount: review.behaviorMismatches,
      budgetMismatchCount: review.budgetMismatches,
      unsafeCount: review.blockedUnsafeClaims,
      ownerProofQueueCount: ownerProofQueueCaseIds.length,
      capturedAndroidProofCount: capturedProofCaseIds.length,
      capturedAndroidProofCaseIds: List<String>.unmodifiable(
        capturedProofCaseIds,
      ),
      incompleteCaseIds: List<String>.unmodifiable(incompleteCaseIds),
      realDeviceNeededCaseIds: List<String>.unmodifiable(
        realDeviceNeededCaseIds,
      ),
      ownerProofQueueCaseIds: List<String>.unmodifiable(ownerProofQueueCaseIds),
      unsafeCaseIds: List<String>.unmodifiable(unsafeCaseIds),
      mismatchCaseIds: List<String>.unmodifiable(mismatchCaseIds),
      scopes: List<GoldenClassifierScopeReadiness>.unmodifiable(scopes),
      blockers: List<String>.unmodifiable(allBlockers),
      nextRecommendedPhase: _nextPhase(
        unsafeCaseIds: unsafeCaseIds,
        mismatchCaseIds: mismatchCaseIds,
        realDeviceNeededCaseIds: realDeviceNeededCaseIds,
        ownerProofQueueCaseIds: ownerProofQueueCaseIds,
        incompleteCaseIds: incompleteCaseIds,
        caseById: caseById,
      ),
    );

    return result;
  }
}

GoldenClassifierScopeReadiness _basicScope({
  required Map<String, GoldenAnalysisCase> caseById,
  required Map<String, GoldenEvidenceCaseReview> reviewById,
  required Set<String> protectedCaseIds,
  required List<String> globalBlockers,
  required int minimumProtectedCases,
}) {
  final supporting =
      caseById.values
          .where((item) => protectedCaseIds.contains(item.id))
          .where((item) => !_isQuietPreparatoryCase(item))
          .map((item) => item.id)
          .toList()
        ..sort();
  if (globalBlockers.isNotEmpty) {
    return _blockedScope(
      scope: GoldenClassifierScope.basicMoveQualityFoundation,
      status: _globalBlockedStatus(globalBlockers),
      blockers: globalBlockers,
      supportingCaseIds: supporting,
      missingCaseIds: const <String>[],
      recommendation:
          'Do not start foundation work until global evidence blockers clear.',
    );
  }
  if (supporting.length < minimumProtectedCases) {
    return _blockedScope(
      scope: GoldenClassifierScope.basicMoveQualityFoundation,
      status: GoldenClassifierScopeStatus.blockedByEvidence,
      blockers: [
        'protected supporting cases below minimum: '
            '${supporting.length}/$minimumProtectedCases',
      ],
      supportingCaseIds: supporting,
      missingCaseIds: const <String>[],
      recommendation: 'Add protected golden evidence before classifier design.',
    );
  }
  final missing =
      reviewById.values
          .where(
            (item) =>
                item.status == GoldenEvidenceReviewStatus.incompleteEvidence &&
                !_isQuietPreparatoryCase(caseById[item.caseId]!),
          )
          .map((item) => item.caseId)
          .toList()
        ..sort();
  if (missing.isNotEmpty) {
    return _blockedScope(
      scope: GoldenClassifierScope.basicMoveQualityFoundation,
      status: GoldenClassifierScopeStatus.blockedByIncompleteCases,
      blockers: ['incomplete cases affect basic foundation'],
      supportingCaseIds: supporting,
      missingCaseIds: missing,
      recommendation: 'Resolve incomplete non-quiet evidence first.',
    );
  }
  return GoldenClassifierScopeReadiness(
    scope: GoldenClassifierScope.basicMoveQualityFoundation,
    status: GoldenClassifierScopeStatus.allowedForDeveloperPrototype,
    blockers: const <String>[],
    supportingCaseIds: List<String>.unmodifiable(supporting),
    missingCaseIds: const <String>[],
    recommendation:
        'Allowed only as developer-only prototype design; emit no labels and '
        'exclude incomplete quiet-preparatory motifs.',
  );
}

GoldenClassifierScopeReadiness _motifScope({
  required GoldenClassifierScope scope,
  required Map<String, GoldenAnalysisCase> caseById,
  required Map<String, GoldenEvidenceCaseReview> reviewById,
  required Set<String> protectedCaseIds,
  required List<String> globalBlockers,
  required int minimumProtectedCases,
  required bool Function(GoldenAnalysisCase) relevant,
  required GoldenClassifierScopeStatus allowedStatus,
  required String allowedRecommendation,
}) {
  final relevantCaseIds =
      caseById.values.where(relevant).map((item) => item.id).toList()..sort();
  final supporting = relevantCaseIds
      .where(protectedCaseIds.contains)
      .toList(growable: false);
  final missing = relevantCaseIds
      .where((id) {
        final review = reviewById[id];
        return review == null || !review.passedLike;
      })
      .toList(growable: false);

  if (globalBlockers.isNotEmpty) {
    return _blockedScope(
      scope: scope,
      status: _globalBlockedStatus(globalBlockers),
      blockers: globalBlockers,
      supportingCaseIds: supporting,
      missingCaseIds: missing,
      recommendation:
          'Do not widen this scope until global evidence blockers clear.',
    );
  }
  final missingProof = missing
      .where((id) {
        final review = reviewById[id];
        return review?.realEngineEvidenceNeeded ?? false;
      })
      .toList(growable: false);
  if (missingProof.isNotEmpty) {
    return _blockedScope(
      scope: scope,
      status: GoldenClassifierScopeStatus.blockedByMissingProof,
      blockers: ['real-device proof missing for relevant cases'],
      supportingCaseIds: supporting,
      missingCaseIds: missingProof,
      recommendation: 'Queue owner Android proof before this scope advances.',
    );
  }
  if (missing.isNotEmpty) {
    return _blockedScope(
      scope: scope,
      status: GoldenClassifierScopeStatus.blockedByIncompleteCases,
      blockers: ['incomplete evidence for relevant cases'],
      supportingCaseIds: supporting,
      missingCaseIds: missing,
      recommendation: 'Resolve relevant incomplete golden evidence first.',
    );
  }
  if (supporting.length < minimumProtectedCases) {
    return _blockedScope(
      scope: scope,
      status: GoldenClassifierScopeStatus.blockedByEvidence,
      blockers: [
        'protected supporting cases below minimum: '
            '${supporting.length}/$minimumProtectedCases',
      ],
      supportingCaseIds: supporting,
      missingCaseIds: const <String>[],
      recommendation: 'Add more protected cases before this scope advances.',
    );
  }
  return GoldenClassifierScopeReadiness(
    scope: scope,
    status: allowedStatus,
    blockers: const <String>[],
    supportingCaseIds: List<String>.unmodifiable(supporting),
    missingCaseIds: const <String>[],
    recommendation: allowedRecommendation,
  );
}

GoldenClassifierScopeReadiness _blockedScope({
  required GoldenClassifierScope scope,
  required GoldenClassifierScopeStatus status,
  required List<String> blockers,
  required List<String> supportingCaseIds,
  required List<String> missingCaseIds,
  required String recommendation,
}) {
  return GoldenClassifierScopeReadiness(
    scope: scope,
    status: status,
    blockers: List<String>.unmodifiable(blockers.toList()..sort()),
    supportingCaseIds: List<String>.unmodifiable(
      supportingCaseIds.toList()..sort(),
    ),
    missingCaseIds: List<String>.unmodifiable(missingCaseIds.toList()..sort()),
    recommendation: recommendation,
  );
}

GoldenClassifierScopeReadiness _policyBlockedScope(
  GoldenClassifierScope scope,
  String recommendation,
) {
  return GoldenClassifierScopeReadiness(
    scope: scope,
    status: GoldenClassifierScopeStatus.blockedByPolicy,
    blockers: const <String>['policy blocks product or advanced labels'],
    supportingCaseIds: const <String>[],
    missingCaseIds: const <String>[],
    recommendation: recommendation,
  );
}

GoldenClassifierScopeStatus _globalBlockedStatus(List<String> blockers) {
  if (blockers.any((item) => item.contains('real-device'))) {
    return GoldenClassifierScopeStatus.blockedByMissingProof;
  }
  return GoldenClassifierScopeStatus.blockedByEvidence;
}

GoldenClassifierReadinessStatus _overallStatus({
  required int unsafeCount,
  required int mismatchCount,
  required int realDeviceNeededCount,
  required int ownerProofQueueCount,
  required int incompleteCount,
  required List<GoldenClassifierScopeReadiness> scopes,
}) {
  if (unsafeCount > 0) {
    return GoldenClassifierReadinessStatus.blockedByUnsafeClaim;
  }
  if (mismatchCount > 0) {
    return GoldenClassifierReadinessStatus.blockedByMismatch;
  }
  if (realDeviceNeededCount > 0 || ownerProofQueueCount > 0) {
    return GoldenClassifierReadinessStatus.blockedByRealDeviceProof;
  }
  final basic = scopes.firstWhere(
    (scope) => scope.scope == GoldenClassifierScope.basicMoveQualityFoundation,
  );
  if (basic.status ==
      GoldenClassifierScopeStatus.allowedForDeveloperPrototype) {
    return incompleteCount > 0
        ? GoldenClassifierReadinessStatus.readyForLimitedClassifierFoundation
        : GoldenClassifierReadinessStatus.readyForBasicClassifierFoundation;
  }
  if (incompleteCount > 0) {
    return GoldenClassifierReadinessStatus.blockedByIncompleteEvidence;
  }
  return GoldenClassifierReadinessStatus.readyForEvidenceOnly;
}

GoldenClassifierNextPhase _nextPhase({
  required List<String> unsafeCaseIds,
  required List<String> mismatchCaseIds,
  required List<String> realDeviceNeededCaseIds,
  required List<String> ownerProofQueueCaseIds,
  required List<String> incompleteCaseIds,
  required Map<String, GoldenAnalysisCase> caseById,
}) {
  if (unsafeCaseIds.isNotEmpty || mismatchCaseIds.isNotEmpty) {
    return GoldenClassifierNextPhase.mismatchInvestigation;
  }
  if (realDeviceNeededCaseIds.isNotEmpty || ownerProofQueueCaseIds.isNotEmpty) {
    return GoldenClassifierNextPhase.ownerAndroidProofQueue;
  }
  if (incompleteCaseIds.any((id) => _isQuietPreparatoryCase(caseById[id]!))) {
    return GoldenClassifierNextPhase.quietPreparatoryEvidenceResolution;
  }
  return GoldenClassifierNextPhase.basicClassifierFoundationDesignOnly;
}

List<String> _caseIdsWithStatus(
  GoldenEvidenceReviewResult review,
  GoldenEvidenceReviewStatus status,
) {
  return review.caseReviews
      .where((item) => item.status == status)
      .map((item) => item.caseId)
      .toList()
    ..sort();
}

List<String> _capturedAndroidProofCaseIds(
  GoldenAndroidProofEvidence? evidence,
) {
  if (evidence == null) return const <String>[];
  return evidence.targetCaseIds
      .where(
        (id) => evidence.isRealDeviceProofCapturedFor(
          id,
          minMultiPvLineCount: 1,
          requirePv: true,
        ),
      )
      .toList()
    ..sort();
}

List<String> _globalBlockers({
  required List<String> unsafeCaseIds,
  required List<String> mismatchCaseIds,
  required List<String> realDeviceNeededCaseIds,
  required List<String> ownerProofQueueCaseIds,
}) {
  final blockers = <String>[];
  if (unsafeCaseIds.isNotEmpty) {
    blockers.add('unsafe claim rows: ${unsafeCaseIds.join(", ")}');
  }
  if (mismatchCaseIds.isNotEmpty) {
    blockers.add('mismatch rows: ${mismatchCaseIds.join(", ")}');
  }
  if (realDeviceNeededCaseIds.isNotEmpty) {
    blockers.add(
      'real-device proof missing: ${realDeviceNeededCaseIds.join(", ")}',
    );
  }
  if (ownerProofQueueCaseIds.isNotEmpty) {
    blockers.add(
      'owner proof queue is non-empty: ${ownerProofQueueCaseIds.join(", ")}',
    );
  }
  return blockers..sort();
}

bool _isTacticalCase(GoldenAnalysisCase item) {
  return item.category == GoldenAnalysisCategory.tacticalShot ||
      item.motifTags.any(
        (motif) => {
          GoldenMotifTag.zwischenzug,
          GoldenMotifTag.fork,
          GoldenMotifTag.pin,
          GoldenMotifTag.skewer,
          GoldenMotifTag.discoveredAttack,
          GoldenMotifTag.deflection,
          GoldenMotifTag.decoy,
          GoldenMotifTag.overload,
          GoldenMotifTag.trappedPiece,
          GoldenMotifTag.clearance,
          GoldenMotifTag.interference,
          GoldenMotifTag.removeDefender,
          GoldenMotifTag.promotion,
          GoldenMotifTag.forcingLine,
          GoldenMotifTag.checkSequence,
        }.contains(motif),
      );
}

bool _isMaterialCase(GoldenAnalysisCase item) {
  return item.category == GoldenAnalysisCategory.materialSacrifice ||
      item.category == GoldenAnalysisCategory.queenTrap ||
      item.motifTags.any(
        (motif) => {
          GoldenMotifTag.sacrifice,
          GoldenMotifTag.temporarySacrifice,
          GoldenMotifTag.exchangeSacrifice,
          GoldenMotifTag.pieceSacrifice,
          GoldenMotifTag.materialCompensation,
          GoldenMotifTag.queenWin,
          GoldenMotifTag.rookWin,
          GoldenMotifTag.pieceWin,
          GoldenMotifTag.pawnBreakthrough,
        }.contains(motif),
      );
}

bool _isKingSafetyCase(GoldenAnalysisCase item) {
  return item.category == GoldenAnalysisCategory.forcedMateThreat ||
      item.motifTags.any(
        (motif) => {
          GoldenMotifTag.mateThreat,
          GoldenMotifTag.forcedMate,
          GoldenMotifTag.backRankWeakness,
          GoldenMotifTag.exposedKing,
          GoldenMotifTag.kingHunt,
          GoldenMotifTag.matingNet,
        }.contains(motif),
      );
}

bool _isForcingCase(GoldenAnalysisCase item) {
  return item.motifTags.any(
    (motif) => {
      GoldenMotifTag.forcingLine,
      GoldenMotifTag.checkSequence,
      GoldenMotifTag.onlyMove,
    }.contains(motif),
  );
}

bool _isQuietPreparatoryCase(GoldenAnalysisCase item) {
  return item.category == GoldenAnalysisCategory.quietPreparatoryMove ||
      item.motifTags.contains(GoldenMotifTag.quietPreparatoryMove);
}

bool _isEndgamePrecisionCase(GoldenAnalysisCase item) {
  return item.category == GoldenAnalysisCategory.endgamePrecision ||
      item.motifTags.contains(GoldenMotifTag.endgamePrecision);
}

String _ids(List<String> ids) => ids.isEmpty ? '-' : ids.join(', ');

String _cell(String value) => value.replaceAll('|', '/');

const _advancedScopes = <GoldenClassifierScope>{
  GoldenClassifierScope.brilliantCandidateGate,
  GoldenClassifierScope.greatMoveCandidateGate,
  GoldenClassifierScope.missedWinCandidateGate,
};

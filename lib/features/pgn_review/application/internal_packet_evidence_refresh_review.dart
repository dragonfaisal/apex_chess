/// Developer-only review of refreshed internal packet evidence after Phase 32I.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_refresh.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_review_aggregation_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_stability_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/narrow_internal_non_label_analysis_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_internal_packet_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_hardening_validation.dart';
import 'package:apex_chess/features/pgn_review/application/targeted_golden_coverage_impact_review.dart';

const internalPacketEvidenceRefreshReviewReportVersion =
    'internal-packet-evidence-refresh-review-v1';

enum InternalPacketEvidenceRefreshReviewStatus {
  reviewedWithWarnings('reviewedWithWarnings'),
  reviewedClean('reviewedClean'),
  blockedByUnsafeRefresh('blockedByUnsafeRefresh'),
  blockedByInvalidRecord('blockedByInvalidRecord'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const InternalPacketEvidenceRefreshReviewStatus(this.wire);

  final String wire;
}

enum InternalPacketEvidenceRefreshReviewRowStatus {
  validPreservedStable('validPreservedStable'),
  validImprovedSupport('validImprovedSupport'),
  validWatchListed('validWatchListed'),
  validProofLimited('validProofLimited'),
  validWarningLimited('validWarningLimited'),
  validBlocked('validBlocked'),
  validFutureOnly('validFutureOnly'),
  invalid('invalid'),
  unsafe('unsafe');

  const InternalPacketEvidenceRefreshReviewRowStatus(this.wire);

  final String wire;

  bool get isUnsafe =>
      this == InternalPacketEvidenceRefreshReviewRowStatus.unsafe ||
      this == InternalPacketEvidenceRefreshReviewRowStatus.invalid;
}

enum InternalPacketEvidenceRefreshReviewRecommendation {
  keepPreservedStable('keepPreservedStable'),
  keepImprovedSupport('keepImprovedSupport'),
  keepWatchListed('keepWatchListed'),
  keepProofLimited('keepProofLimited'),
  keepWarningLimited('keepWarningLimited'),
  keepBlocked('keepBlocked'),
  keepFutureOnly('keepFutureOnly'),
  investigateInvalidRecord('investigateInvalidRecord'),
  blockUnsafeRecord('blockUnsafeRecord');

  const InternalPacketEvidenceRefreshReviewRecommendation(this.wire);

  final String wire;
}

enum InternalPacketEvidenceRefreshReviewPhase32KRecommendation {
  proceedToRefreshedEvidenceReadinessGate(
    'proceedToRefreshedEvidenceReadinessGate',
  ),
  proceedToInternalEvidenceRefreshSummary(
    'proceedToInternalEvidenceRefreshSummary',
  ),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeReview('blockedByUnsafeReview');

  const InternalPacketEvidenceRefreshReviewPhase32KRecommendation(this.wire);

  final String wire;
}

enum InternalPacketEvidenceRefreshReviewValidationSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const InternalPacketEvidenceRefreshReviewValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == InternalPacketEvidenceRefreshReviewValidationSeverity.blocker ||
      this == InternalPacketEvidenceRefreshReviewValidationSeverity.critical;
}

enum InternalPacketEvidenceRefreshReviewReportFormat {
  markdown('markdown'),
  json('json');

  const InternalPacketEvidenceRefreshReviewReportFormat(this.wire);

  final String wire;
}

class InternalPacketEvidenceRefreshReviewRequest {
  const InternalPacketEvidenceRefreshReviewRequest({
    this.refreshResult,
    this.validationResult,
    this.refreshedPlanResult,
    this.impactReviewResult,
    this.hardeningPlanResult,
    this.stabilityResult,
    this.matrixResult,
    this.prototypeResult,
    this.refresh = const InternalPacketEvidenceRefresh(),
    this.validation = const RefreshedPacketHardeningValidation(),
    this.refreshedPlan = const RefreshedInternalPacketHardeningPlan(),
    this.impactReview = const TargetedGoldenCoverageImpactReview(),
    this.hardeningPlan = const InternalPacketEvidenceHardeningPlan(),
    this.stabilityPrototype = const InternalPacketStabilityPrototype(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const InternalPacketEvidenceRefreshReviewRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final InternalPacketEvidenceRefreshResult? refreshResult;
  final RefreshedPacketHardeningValidationResult? validationResult;
  final RefreshedInternalPacketHardeningPlanResult? refreshedPlanResult;
  final TargetedGoldenCoverageImpactReviewResult? impactReviewResult;
  final InternalPacketEvidenceHardeningPlanResult? hardeningPlanResult;
  final InternalPacketStabilityPrototypeResult? stabilityResult;
  final InternalPacketReviewAggregationMatrixResult? matrixResult;
  final NarrowInternalNonLabelAnalysisPrototypeResult? prototypeResult;
  final InternalPacketEvidenceRefresh refresh;
  final RefreshedPacketHardeningValidation validation;
  final RefreshedInternalPacketHardeningPlan refreshedPlan;
  final TargetedGoldenCoverageImpactReview impactReview;
  final InternalPacketEvidenceHardeningPlan hardeningPlan;
  final InternalPacketStabilityPrototype stabilityPrototype;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class InternalPacketEvidenceRefreshReviewRow {
  const InternalPacketEvidenceRefreshReviewRow({
    required this.recordId,
    required this.packetId,
    required this.scopeId,
    required this.packetKind,
    required this.sourceRefreshStatus,
    required this.reviewStatus,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.activeSignalIds,
    required this.evidenceAreaIds,
    required this.bucketIds,
    required this.qualitativeConfidence,
    required this.reviewReason,
    required this.warningReason,
    required this.proofLimitReason,
    required this.futurePrerequisite,
    required this.blockedBoundaryIds,
    required this.coverageGapIds,
    required this.safeForNextInternalGate,
    required this.recommendation,
    this.isProductOutput = false,
    this.isClassifierLabel = false,
    this.isOfficialMetric = false,
    this.hasNumericValue = false,
    this.ordersMoves = false,
    this.quietScopeActive = false,
    this.cpLossComputationImplemented = false,
    this.winProbabilityComputationImplemented = false,
    this.emittedOutputNames = const <String>[],
  });

  final String recordId;
  final String packetId;
  final InternalNonLabelPrototypeScopeId scopeId;
  final InternalPacketEvidenceHardeningTargetKind packetKind;
  final InternalPacketEvidenceRefreshRecordStatus sourceRefreshStatus;
  final InternalPacketEvidenceRefreshReviewRowStatus reviewStatus;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<InternalNonLabelSignalId> activeSignalIds;
  final List<InternalEvidenceAreaId> evidenceAreaIds;
  final List<InternalEvidenceBucketId> bucketIds;
  final InternalNonLabelSignalConfidence qualitativeConfidence;
  final String reviewReason;
  final String warningReason;
  final String proofLimitReason;
  final String futurePrerequisite;
  final List<String> blockedBoundaryIds;
  final List<String> coverageGapIds;
  final bool safeForNextInternalGate;
  final InternalPacketEvidenceRefreshReviewRecommendation recommendation;
  final bool isProductOutput;
  final bool isClassifierLabel;
  final bool isOfficialMetric;
  final bool hasNumericValue;
  final bool ordersMoves;
  final bool quietScopeActive;
  final bool cpLossComputationImplemented;
  final bool winProbabilityComputationImplemented;
  final List<String> emittedOutputNames;

  bool get isCorePacketReview => _allowedPacketScopes.contains(scopeId);

  bool get hasUnsafeOutput {
    return isProductOutput ||
        isClassifierLabel ||
        isOfficialMetric ||
        hasNumericValue ||
        ordersMoves ||
        quietScopeActive ||
        cpLossComputationImplemented ||
        winProbabilityComputationImplemented ||
        emittedOutputNames.any(_isForbiddenOutputName);
  }

  InternalPacketEvidenceRefreshReviewRow copyWith({
    String? recordId,
    String? packetId,
    InternalNonLabelPrototypeScopeId? scopeId,
    InternalPacketEvidenceHardeningTargetKind? packetKind,
    InternalPacketEvidenceRefreshRecordStatus? sourceRefreshStatus,
    InternalPacketEvidenceRefreshReviewRowStatus? reviewStatus,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<InternalNonLabelSignalId>? activeSignalIds,
    List<InternalEvidenceAreaId>? evidenceAreaIds,
    List<InternalEvidenceBucketId>? bucketIds,
    InternalNonLabelSignalConfidence? qualitativeConfidence,
    String? reviewReason,
    String? warningReason,
    String? proofLimitReason,
    String? futurePrerequisite,
    List<String>? blockedBoundaryIds,
    List<String>? coverageGapIds,
    bool? safeForNextInternalGate,
    InternalPacketEvidenceRefreshReviewRecommendation? recommendation,
    bool? isProductOutput,
    bool? isClassifierLabel,
    bool? isOfficialMetric,
    bool? hasNumericValue,
    bool? ordersMoves,
    bool? quietScopeActive,
    bool? cpLossComputationImplemented,
    bool? winProbabilityComputationImplemented,
    List<String>? emittedOutputNames,
  }) {
    return InternalPacketEvidenceRefreshReviewRow(
      recordId: recordId ?? this.recordId,
      packetId: packetId ?? this.packetId,
      scopeId: scopeId ?? this.scopeId,
      packetKind: packetKind ?? this.packetKind,
      sourceRefreshStatus: sourceRefreshStatus ?? this.sourceRefreshStatus,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      activeSignalIds: activeSignalIds ?? this.activeSignalIds,
      evidenceAreaIds: evidenceAreaIds ?? this.evidenceAreaIds,
      bucketIds: bucketIds ?? this.bucketIds,
      qualitativeConfidence:
          qualitativeConfidence ?? this.qualitativeConfidence,
      reviewReason: reviewReason ?? this.reviewReason,
      warningReason: warningReason ?? this.warningReason,
      proofLimitReason: proofLimitReason ?? this.proofLimitReason,
      futurePrerequisite: futurePrerequisite ?? this.futurePrerequisite,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      coverageGapIds: coverageGapIds ?? this.coverageGapIds,
      safeForNextInternalGate:
          safeForNextInternalGate ?? this.safeForNextInternalGate,
      recommendation: recommendation ?? this.recommendation,
      isProductOutput: isProductOutput ?? this.isProductOutput,
      isClassifierLabel: isClassifierLabel ?? this.isClassifierLabel,
      isOfficialMetric: isOfficialMetric ?? this.isOfficialMetric,
      hasNumericValue: hasNumericValue ?? this.hasNumericValue,
      ordersMoves: ordersMoves ?? this.ordersMoves,
      quietScopeActive: quietScopeActive ?? this.quietScopeActive,
      cpLossComputationImplemented:
          cpLossComputationImplemented ?? this.cpLossComputationImplemented,
      winProbabilityComputationImplemented:
          winProbabilityComputationImplemented ??
          this.winProbabilityComputationImplemented,
      emittedOutputNames: emittedOutputNames ?? this.emittedOutputNames,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'recordId': recordId,
      'packetId': packetId,
      'scopeId': scopeId.wire,
      'packetKind': packetKind.wire,
      'sourceRefreshStatus': sourceRefreshStatus.wire,
      'reviewStatus': reviewStatus.wire,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'activeSignalIds': activeSignalIds.map((id) => id.wire).toList(),
      'evidenceAreaIds': evidenceAreaIds.map((id) => id.wire).toList(),
      'bucketIds': bucketIds.map((id) => id.wire).toList(),
      'qualitativeConfidence': qualitativeConfidence.wire,
      'reviewReason': reviewReason,
      'warningReason': warningReason,
      'proofLimitReason': proofLimitReason,
      'futurePrerequisite': futurePrerequisite,
      'blockedBoundaryIds': blockedBoundaryIds,
      'coverageGapIds': coverageGapIds,
      'safeForNextInternalGate': safeForNextInternalGate,
      'recommendation': recommendation.wire,
      'isProductOutput': isProductOutput,
      'isClassifierLabel': isClassifierLabel,
      'isOfficialMetric': isOfficialMetric,
      'hasNumericValue': hasNumericValue,
      'ordersMoves': ordersMoves,
      'quietScopeActive': quietScopeActive,
      'cpLossComputationImplemented': cpLossComputationImplemented,
      'winProbabilityComputationImplemented':
          winProbabilityComputationImplemented,
      'emittedOutputNames': emittedOutputNames,
    };
  }
}

class InternalPacketEvidenceRefreshReviewFinding {
  const InternalPacketEvidenceRefreshReviewFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.recordId,
    this.packetId,
    this.scopeId,
    this.caseId,
  });

  final String id;
  final InternalPacketEvidenceRefreshReviewValidationSeverity severity;
  final String message;
  final String? recordId;
  final String? packetId;
  final InternalNonLabelPrototypeScopeId? scopeId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical =>
      severity ==
      InternalPacketEvidenceRefreshReviewValidationSeverity.critical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (recordId != null) 'recordId': recordId,
      if (packetId != null) 'packetId': packetId,
      if (scopeId != null) 'scopeId': scopeId!.wire,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class InternalPacketEvidenceRefreshReviewResult {
  const InternalPacketEvidenceRefreshReviewResult({
    required this.reviewStatus,
    required this.sourceRefreshStatus,
    required this.sourceValidationStatus,
    required this.sourcePlanStatus,
    required this.sourceImpactStatus,
    required this.rows,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalRows,
    required this.validPreservedStableCount,
    required this.validImprovedSupportCount,
    required this.validWatchListedCount,
    required this.validProofLimitedCount,
    required this.validWarningLimitedCount,
    required this.validBlockedCount,
    required this.validFutureOnlyCount,
    required this.invalidCount,
    required this.unsafeCount,
    required this.criticalCount,
    required this.ownerProofQueueCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.coverageGapIds,
    required this.safeForPhase32K,
    required this.phase32KRecommendation,
    this.developerOnly = true,
    this.productLabelsEmitted = false,
    this.advancedLabelsEmitted = false,
    this.classifierLabelsEmitted = false,
    this.finalMoveLabelsEmitted = false,
    this.officialMetricsAllowed = false,
    this.cpLossComputationImplemented = false,
    this.winProbabilityComputationImplemented = false,
    this.numericMoveValuesComputed = false,
    this.moveOrderingComputed = false,
    this.quietPreparatoryScopeActivated = false,
    this.directEngineAccessUsed = false,
    this.uiOutputUsed = false,
    this.backendOutputUsed = false,
    this.persistenceUsed = false,
    this.emittedOutputFamilies = const <String>[],
  });

  final InternalPacketEvidenceRefreshReviewStatus reviewStatus;
  final InternalPacketEvidenceRefreshStatus sourceRefreshStatus;
  final RefreshedPacketHardeningValidationStatus sourceValidationStatus;
  final RefreshedInternalPacketHardeningStatus sourcePlanStatus;
  final TargetedGoldenCoverageImpactStatus sourceImpactStatus;
  final List<InternalPacketEvidenceRefreshReviewRow> rows;
  final List<InternalPacketEvidenceRefreshReviewFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalRows;
  final int validPreservedStableCount;
  final int validImprovedSupportCount;
  final int validWatchListedCount;
  final int validProofLimitedCount;
  final int validWarningLimitedCount;
  final int validBlockedCount;
  final int validFutureOnlyCount;
  final int invalidCount;
  final int unsafeCount;
  final int criticalCount;
  final int ownerProofQueueCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> coverageGapIds;
  final bool safeForPhase32K;
  final InternalPacketEvidenceRefreshReviewPhase32KRecommendation
  phase32KRecommendation;
  final bool developerOnly;
  final bool productLabelsEmitted;
  final bool advancedLabelsEmitted;
  final bool classifierLabelsEmitted;
  final bool finalMoveLabelsEmitted;
  final bool officialMetricsAllowed;
  final bool cpLossComputationImplemented;
  final bool winProbabilityComputationImplemented;
  final bool numericMoveValuesComputed;
  final bool moveOrderingComputed;
  final bool quietPreparatoryScopeActivated;
  final bool directEngineAccessUsed;
  final bool uiOutputUsed;
  final bool backendOutputUsed;
  final bool persistenceUsed;
  final List<String> emittedOutputFamilies;

  bool get isStrictlyBlocked =>
      reviewStatus ==
          InternalPacketEvidenceRefreshReviewStatus.blockedByUnsafeRefresh ||
      reviewStatus ==
          InternalPacketEvidenceRefreshReviewStatus.blockedByPolicyBoundary ||
      reviewStatus ==
          InternalPacketEvidenceRefreshReviewStatus.blockedByInvalidRecord ||
      reviewStatus == InternalPacketEvidenceRefreshReviewStatus.invalid ||
      !safeForPhase32K ||
      unsafeCount > 0 ||
      criticalCount > 0 ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeReviewPolicyViolation {
    return unsafeCount > 0 ||
        criticalCount > 0 ||
        validationFindings.any((finding) => finding.isCritical) ||
        rows.any((row) => row.reviewStatus.isUnsafe || row.hasUnsafeOutput) ||
        productLabelsEmitted ||
        advancedLabelsEmitted ||
        classifierLabelsEmitted ||
        finalMoveLabelsEmitted ||
        officialMetricsAllowed ||
        cpLossComputationImplemented ||
        winProbabilityComputationImplemented ||
        numericMoveValuesComputed ||
        moveOrderingComputed ||
        quietPreparatoryScopeActivated ||
        directEngineAccessUsed ||
        uiOutputUsed ||
        backendOutputUsed ||
        persistenceUsed ||
        emittedOutputFamilies.any(_isForbiddenOutputName);
  }

  InternalPacketEvidenceRefreshReviewRow row(
    InternalNonLabelPrototypeScopeId scopeId,
  ) {
    return rows.singleWhere((row) => row.scopeId == scopeId);
  }

  List<InternalPacketEvidenceRefreshReviewRow> get preservedStableRows => rows
      .where(
        (row) =>
            row.reviewStatus ==
            InternalPacketEvidenceRefreshReviewRowStatus.validPreservedStable,
      )
      .toList(growable: false);

  List<InternalPacketEvidenceRefreshReviewRow> get improvedSupportRows => rows
      .where(
        (row) =>
            row.reviewStatus ==
            InternalPacketEvidenceRefreshReviewRowStatus.validImprovedSupport,
      )
      .toList(growable: false);

  List<InternalPacketEvidenceRefreshReviewRow> get watchListedRows => rows
      .where(
        (row) =>
            row.reviewStatus ==
            InternalPacketEvidenceRefreshReviewRowStatus.validWatchListed,
      )
      .toList(growable: false);

  List<InternalPacketEvidenceRefreshReviewRow> get proofLimitedRows => rows
      .where(
        (row) =>
            row.reviewStatus ==
            InternalPacketEvidenceRefreshReviewRowStatus.validProofLimited,
      )
      .toList(growable: false);

  List<InternalPacketEvidenceRefreshReviewRow> get warningLimitedRows => rows
      .where(
        (row) =>
            row.reviewStatus ==
            InternalPacketEvidenceRefreshReviewRowStatus.validWarningLimited,
      )
      .toList(growable: false);

  List<InternalPacketEvidenceRefreshReviewRow> get blockedOrFutureRows => rows
      .where(
        (row) =>
            row.reviewStatus ==
                InternalPacketEvidenceRefreshReviewRowStatus.validBlocked ||
            row.reviewStatus ==
                InternalPacketEvidenceRefreshReviewRowStatus.validFutureOnly,
      )
      .toList(growable: false);

  InternalPacketEvidenceRefreshReviewResult copyWith({
    InternalPacketEvidenceRefreshReviewStatus? reviewStatus,
    InternalPacketEvidenceRefreshStatus? sourceRefreshStatus,
    RefreshedPacketHardeningValidationStatus? sourceValidationStatus,
    RefreshedInternalPacketHardeningStatus? sourcePlanStatus,
    TargetedGoldenCoverageImpactStatus? sourceImpactStatus,
    List<InternalPacketEvidenceRefreshReviewRow>? rows,
    List<InternalPacketEvidenceRefreshReviewFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalRows,
    int? validPreservedStableCount,
    int? validImprovedSupportCount,
    int? validWatchListedCount,
    int? validProofLimitedCount,
    int? validWarningLimitedCount,
    int? validBlockedCount,
    int? validFutureOnlyCount,
    int? invalidCount,
    int? unsafeCount,
    int? criticalCount,
    int? ownerProofQueueCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? coverageGapIds,
    bool? safeForPhase32K,
    InternalPacketEvidenceRefreshReviewPhase32KRecommendation?
    phase32KRecommendation,
    bool? developerOnly,
    bool? productLabelsEmitted,
    bool? advancedLabelsEmitted,
    bool? classifierLabelsEmitted,
    bool? finalMoveLabelsEmitted,
    bool? officialMetricsAllowed,
    bool? cpLossComputationImplemented,
    bool? winProbabilityComputationImplemented,
    bool? numericMoveValuesComputed,
    bool? moveOrderingComputed,
    bool? quietPreparatoryScopeActivated,
    bool? directEngineAccessUsed,
    bool? uiOutputUsed,
    bool? backendOutputUsed,
    bool? persistenceUsed,
    List<String>? emittedOutputFamilies,
  }) {
    return InternalPacketEvidenceRefreshReviewResult(
      reviewStatus: reviewStatus ?? this.reviewStatus,
      sourceRefreshStatus: sourceRefreshStatus ?? this.sourceRefreshStatus,
      sourceValidationStatus:
          sourceValidationStatus ?? this.sourceValidationStatus,
      sourcePlanStatus: sourcePlanStatus ?? this.sourcePlanStatus,
      sourceImpactStatus: sourceImpactStatus ?? this.sourceImpactStatus,
      rows: rows ?? this.rows,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalRows: totalRows ?? this.totalRows,
      validPreservedStableCount:
          validPreservedStableCount ?? this.validPreservedStableCount,
      validImprovedSupportCount:
          validImprovedSupportCount ?? this.validImprovedSupportCount,
      validWatchListedCount:
          validWatchListedCount ?? this.validWatchListedCount,
      validProofLimitedCount:
          validProofLimitedCount ?? this.validProofLimitedCount,
      validWarningLimitedCount:
          validWarningLimitedCount ?? this.validWarningLimitedCount,
      validBlockedCount: validBlockedCount ?? this.validBlockedCount,
      validFutureOnlyCount: validFutureOnlyCount ?? this.validFutureOnlyCount,
      invalidCount: invalidCount ?? this.invalidCount,
      unsafeCount: unsafeCount ?? this.unsafeCount,
      criticalCount: criticalCount ?? this.criticalCount,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      coverageGapIds: coverageGapIds ?? this.coverageGapIds,
      safeForPhase32K: safeForPhase32K ?? this.safeForPhase32K,
      phase32KRecommendation:
          phase32KRecommendation ?? this.phase32KRecommendation,
      developerOnly: developerOnly ?? this.developerOnly,
      productLabelsEmitted: productLabelsEmitted ?? this.productLabelsEmitted,
      advancedLabelsEmitted:
          advancedLabelsEmitted ?? this.advancedLabelsEmitted,
      classifierLabelsEmitted:
          classifierLabelsEmitted ?? this.classifierLabelsEmitted,
      finalMoveLabelsEmitted:
          finalMoveLabelsEmitted ?? this.finalMoveLabelsEmitted,
      officialMetricsAllowed:
          officialMetricsAllowed ?? this.officialMetricsAllowed,
      cpLossComputationImplemented:
          cpLossComputationImplemented ?? this.cpLossComputationImplemented,
      winProbabilityComputationImplemented:
          winProbabilityComputationImplemented ??
          this.winProbabilityComputationImplemented,
      numericMoveValuesComputed:
          numericMoveValuesComputed ?? this.numericMoveValuesComputed,
      moveOrderingComputed: moveOrderingComputed ?? this.moveOrderingComputed,
      quietPreparatoryScopeActivated:
          quietPreparatoryScopeActivated ?? this.quietPreparatoryScopeActivated,
      directEngineAccessUsed:
          directEngineAccessUsed ?? this.directEngineAccessUsed,
      uiOutputUsed: uiOutputUsed ?? this.uiOutputUsed,
      backendOutputUsed: backendOutputUsed ?? this.backendOutputUsed,
      persistenceUsed: persistenceUsed ?? this.persistenceUsed,
      emittedOutputFamilies:
          emittedOutputFamilies ?? this.emittedOutputFamilies,
    );
  }

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Internal Packet Evidence Refresh Review')
      ..writeln()
      ..writeln('- version: $internalPacketEvidenceRefreshReviewReportVersion')
      ..writeln('- review status: ${reviewStatus.wire}')
      ..writeln('- source refresh status: ${sourceRefreshStatus.wire}')
      ..writeln('- source validation status: ${sourceValidationStatus.wire}')
      ..writeln('- source plan status: ${sourcePlanStatus.wire}')
      ..writeln('- source impact status: ${sourceImpactStatus.wire}')
      ..writeln('- total rows: $totalRows')
      ..writeln('- valid preserved stable count: $validPreservedStableCount')
      ..writeln('- valid improved support count: $validImprovedSupportCount')
      ..writeln('- valid watch-listed count: $validWatchListedCount')
      ..writeln('- valid proof-limited count: $validProofLimitedCount')
      ..writeln('- valid warning-limited count: $validWarningLimitedCount')
      ..writeln('- valid blocked count: $validBlockedCount')
      ..writeln('- valid future-only count: $validFutureOnlyCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- invalid count: $invalidCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- safe for Phase 32K: $safeForPhase32K')
      ..writeln('- Phase 32K recommendation: ${phase32KRecommendation.wire}')
      ..writeln('- classifier output emitted: $classifierLabelsEmitted')
      ..writeln('- numeric value output emitted: $numericMoveValuesComputed')
      ..writeln('- move ordering output emitted: $moveOrderingComputed')
      ..writeln()
      ..writeln('## Review Policy')
      ..writeln(
        '- this review consumes the Phase 32I refreshed internal evidence result only',
      )
      ..writeln(
        '- it reviews internal evidence coherence and does not classify, value, order, integrate, call an engine, run Android, or write files',
      )
      ..writeln()
      ..writeln('## Review Table')
      ..writeln(
        '| Record | Packet | Scope | Source Status | Review Status | Support Cases | New Phase 32E Support | Android Proof | Signals | Areas | Buckets | Confidence | Safe | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in rows) {
      buffer.writeln(
        '| ${_cell(row.recordId)} | ${_cell(row.packetId)} | '
        '${row.scopeId.wire} | ${row.sourceRefreshStatus.wire} | '
        '${row.reviewStatus.wire} | ${_ids(row.supportCaseIds)} | '
        '${_ids(row.newlyAddedSupportCaseIds)} | '
        '${_ids(row.androidProofCaseIds)} | '
        '${_signalIds(row.activeSignalIds)} | '
        '${_areaIds(row.evidenceAreaIds)} | ${_bucketIds(row.bucketIds)} | '
        '${row.qualitativeConfidence.wire} | '
        '${row.safeForNextInternalGate} | ${row.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Preserved Stable Records')
      ..writeln('- ${_packetIds(preservedStableRows)}')
      ..writeln()
      ..writeln('## Improved Support Records')
      ..writeln('- ${_packetIds(improvedSupportRows)}')
      ..writeln()
      ..writeln('## Watch-Listed Records')
      ..writeln('- ${_packetIds(watchListedRows)}')
      ..writeln()
      ..writeln('## Proof-Limited Records')
      ..writeln('- ${_packetIds(proofLimitedRows)}')
      ..writeln()
      ..writeln('## Warning-Limited Records')
      ..writeln('- ${_packetIds(warningLimitedRows)}')
      ..writeln()
      ..writeln('## Blocked And Future-Only Records')
      ..writeln('- ${_packetIds(blockedOrFutureRows)}')
      ..writeln()
      ..writeln('## Newly Added Phase 32E Support IDs')
      ..writeln('- ${_ids(newlyAddedSupportCaseIds)}')
      ..writeln()
      ..writeln('## Android Proof IDs')
      ..writeln('- ${_ids(androidProofCaseIds)}')
      ..writeln()
      ..writeln('## Owner Proof Status')
      ..writeln(
        ownerProofQueueCount == 0
            ? '- empty'
            : '- opt-in proof requires explicit PV/MultiPV reason',
      )
      ..writeln()
      ..writeln('## Coverage Gaps')
      ..writeln('- ${_ids(coverageGapIds)}')
      ..writeln()
      ..writeln('## Validation Findings');
    if (validationFindings.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final finding in validationFindings) {
        buffer.writeln(
          '- ${finding.severity.wire}: ${finding.id} -- ${finding.message}',
        );
      }
    }
    buffer
      ..writeln()
      ..writeln('## Warnings');
    if (warnings.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final warning in warnings) {
        buffer.writeln('- ${_cell(warning)}');
      }
    }
    buffer
      ..writeln()
      ..writeln('## Failures');
    if (failures.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final failure in failures) {
        buffer.writeln('- ${_cell(failure)}');
      }
    }
    buffer
      ..writeln()
      ..writeln('## Phase 32K Recommendation')
      ..writeln(phase32KRecommendation.wire)
      ..writeln()
      ..writeln(
        'This review stays internal-only. It does not emit user-facing output, compute product metrics, call the engine, run Android, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': internalPacketEvidenceRefreshReviewReportVersion,
      'reviewStatus': reviewStatus.wire,
      'sourceRefreshStatus': sourceRefreshStatus.wire,
      'sourceValidationStatus': sourceValidationStatus.wire,
      'sourcePlanStatus': sourcePlanStatus.wire,
      'sourceImpactStatus': sourceImpactStatus.wire,
      'totalRows': totalRows,
      'validPreservedStableCount': validPreservedStableCount,
      'validImprovedSupportCount': validImprovedSupportCount,
      'validWatchListedCount': validWatchListedCount,
      'validProofLimitedCount': validProofLimitedCount,
      'validWarningLimitedCount': validWarningLimitedCount,
      'validBlockedCount': validBlockedCount,
      'validFutureOnlyCount': validFutureOnlyCount,
      'invalidCount': invalidCount,
      'unsafeCount': unsafeCount,
      'criticalCount': criticalCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'coverageGapIds': coverageGapIds,
      'safeForPhase32K': safeForPhase32K,
      'phase32KRecommendation': phase32KRecommendation.wire,
      'rows': rows.map((row) => row.toJson()).toList(),
      'validationFindings': validationFindings
          .map((finding) => finding.toJson())
          .toList(),
      'warnings': warnings,
      'failures': failures,
      'developerOnly': developerOnly,
      'productLabelsEmitted': productLabelsEmitted,
      'advancedLabelsEmitted': advancedLabelsEmitted,
      'classifierLabelsEmitted': classifierLabelsEmitted,
      'finalMoveLabelsEmitted': finalMoveLabelsEmitted,
      'officialMetricsAllowed': officialMetricsAllowed,
      'cpLossComputationImplemented': cpLossComputationImplemented,
      'winProbabilityComputationImplemented':
          winProbabilityComputationImplemented,
      'numericMoveValuesComputed': numericMoveValuesComputed,
      'moveOrderingComputed': moveOrderingComputed,
      'quietPreparatoryScopeActivated': quietPreparatoryScopeActivated,
      'directEngineAccessUsed': directEngineAccessUsed,
      'uiOutputUsed': uiOutputUsed,
      'backendOutputUsed': backendOutputUsed,
      'persistenceUsed': persistenceUsed,
      'emittedOutputFamilies': emittedOutputFamilies,
    };
  }
}

class InternalPacketEvidenceRefreshReview {
  const InternalPacketEvidenceRefreshReview({
    this.validator = const InternalPacketEvidenceRefreshReviewValidator(),
  });

  final InternalPacketEvidenceRefreshReviewValidator validator;

  InternalPacketEvidenceRefreshReviewResult evaluate([
    InternalPacketEvidenceRefreshReviewRequest request =
        const InternalPacketEvidenceRefreshReviewRequest(),
  ]) {
    final stabilityResult =
        request.stabilityResult ??
        request.stabilityPrototype.evaluate(
          InternalPacketStabilityPrototypeRequest(
            matrixResult: request.matrixResult,
            prototypeResult: request.prototypeResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarningLimitedScopes: request.includeWarnings,
          ),
        );
    final hardeningResult =
        request.hardeningPlanResult ??
        request.hardeningPlan.evaluate(
          InternalPacketEvidenceHardeningPlanRequest(
            stabilityResult: stabilityResult,
            matrixResult: request.matrixResult,
            prototypeResult: request.prototypeResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarningLimitedScopes: request.includeWarnings,
          ),
        );
    final impactResult =
        request.impactReviewResult ??
        request.impactReview.evaluate(
          TargetedGoldenCoverageImpactReviewRequest(
            cases: request.cases,
            hardeningPlanResult: hardeningResult,
            stabilityResult: stabilityResult,
            matrixResult: request.matrixResult,
            prototypeResult: request.prototypeResult,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final planResult =
        request.refreshedPlanResult ??
        request.refreshedPlan.evaluate(
          RefreshedInternalPacketHardeningPlanRequest(
            impactReviewResult: impactResult,
            hardeningPlanResult: hardeningResult,
            stabilityResult: stabilityResult,
            matrixResult: request.matrixResult,
            prototypeResult: request.prototypeResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final validationResult =
        request.validationResult ??
        request.validation.evaluate(
          RefreshedPacketHardeningValidationRequest(
            refreshedPlanResult: planResult,
            impactReviewResult: impactResult,
            hardeningPlanResult: hardeningResult,
            stabilityResult: stabilityResult,
            matrixResult: request.matrixResult,
            prototypeResult: request.prototypeResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final refreshResult =
        request.refreshResult ??
        request.refresh.evaluate(
          InternalPacketEvidenceRefreshRequest(
            validationResult: validationResult,
            refreshedPlanResult: planResult,
            impactReviewResult: impactResult,
            hardeningPlanResult: hardeningResult,
            stabilityResult: stabilityResult,
            matrixResult: request.matrixResult,
            prototypeResult: request.prototypeResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final canReviewRows =
        refreshResult.safeForPhase32J &&
        !refreshResult.isStrictlyBlocked &&
        !refreshResult.hasUnsafeRefreshPolicyViolation;
    final rows = canReviewRows
        ? _rowsFrom(refreshResult.records)
        : const <InternalPacketEvidenceRefreshReviewRow>[];
    final base = _resultFromRows(
      refreshResult: refreshResult,
      validationResult: validationResult,
      planResult: planResult,
      impactResult: impactResult,
      rows: rows,
      validationFindings: const <InternalPacketEvidenceRefreshReviewFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromRows(
      refreshResult: refreshResult,
      validationResult: validationResult,
      planResult: planResult,
      impactResult: impactResult,
      rows: rows,
      validationFindings: findings,
    );
  }
}

class InternalPacketEvidenceRefreshReviewValidator {
  const InternalPacketEvidenceRefreshReviewValidator();

  List<InternalPacketEvidenceRefreshReviewFinding> validate(
    InternalPacketEvidenceRefreshReviewResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <InternalPacketEvidenceRefreshReviewFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required InternalPacketEvidenceRefreshReviewValidationSeverity severity,
      required String message,
      String? recordId,
      String? packetId,
      InternalNonLabelPrototypeScopeId? scopeId,
      String? caseId,
    }) {
      findings.add(
        InternalPacketEvidenceRefreshReviewFinding(
          id: id,
          severity: severity,
          message: message,
          recordId: recordId,
          packetId: packetId,
          scopeId: scopeId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase32K &&
        (result.sourceRefreshStatus ==
                InternalPacketEvidenceRefreshStatus.blockedByUnsafeValidation ||
            result.unsafeCount > 0 ||
            result.rows.any((row) => row.reviewStatus.isUnsafe))) {
      add(
        id: 'unsafeRefreshMarkedReviewed',
        severity:
            InternalPacketEvidenceRefreshReviewValidationSeverity.critical,
        message: 'unsafe refresh cannot be marked reviewed for next gate',
      );
    }

    for (final row in result.rows) {
      if (row.isCorePacketReview &&
          (row.supportCaseIds.isEmpty ||
              row.activeSignalIds.isEmpty ||
              row.evidenceAreaIds.isEmpty ||
              row.bucketIds.isEmpty)) {
        add(
          id: 'corePacketReviewMissingEvidenceMapping',
          severity:
              InternalPacketEvidenceRefreshReviewValidationSeverity.blocker,
          message: '${row.packetId} lacks support or source mapping',
          recordId: row.recordId,
          packetId: row.packetId,
          scopeId: row.scopeId,
        );
      }
      if (!_allowedPacketScopes.contains(row.scopeId) &&
          row.packetKind == InternalPacketEvidenceHardeningTargetKind.packet) {
        add(
          id: 'nonAllowedScopeBecameCorePacket',
          severity:
              InternalPacketEvidenceRefreshReviewValidationSeverity.critical,
          message: '${row.scopeId.wire} cannot become a core packet',
          recordId: row.recordId,
          packetId: row.packetId,
          scopeId: row.scopeId,
        );
      }
      if (_warningLimitedScopes.contains(row.scopeId) &&
          (row.reviewStatus !=
                  InternalPacketEvidenceRefreshReviewRowStatus
                      .validWarningLimited ||
              row.sourceRefreshStatus !=
                  InternalPacketEvidenceRefreshRecordStatus
                      .warningLimitedOnly ||
              row.packetKind !=
                  InternalPacketEvidenceHardeningTargetKind.warningScope)) {
        add(
          id: 'warningLimitedScopePromotedToCorePacket',
          severity:
              InternalPacketEvidenceRefreshReviewValidationSeverity.critical,
          message: '${row.scopeId.wire} must remain warning-limited only',
          recordId: row.recordId,
          packetId: row.packetId,
          scopeId: row.scopeId,
        );
      }
      if (row.scopeId ==
              InternalNonLabelPrototypeScopeId
                  .pvMultiPvSupportInternalPrototypeScope &&
          (row.reviewStatus !=
                  InternalPacketEvidenceRefreshReviewRowStatus
                      .validWatchListed ||
              row.sourceRefreshStatus !=
                  InternalPacketEvidenceRefreshRecordStatus.watchListed)) {
        add(
          id: 'watchListedPvMultiPvPromotedWithoutProof',
          severity:
              InternalPacketEvidenceRefreshReviewValidationSeverity.blocker,
          message: 'PV/MultiPV must stay watch-listed without new proof',
          recordId: row.recordId,
          packetId: row.packetId,
          scopeId: row.scopeId,
        );
      }
      if (_blockedScopes.contains(row.scopeId) &&
          (row.reviewStatus !=
                  InternalPacketEvidenceRefreshReviewRowStatus.validBlocked ||
              row.sourceRefreshStatus !=
                  InternalPacketEvidenceRefreshRecordStatus.blockedCorrectly)) {
        add(
          id: 'blockedRecordBecameActive',
          severity:
              InternalPacketEvidenceRefreshReviewValidationSeverity.critical,
          message: '${row.scopeId.wire} must remain blocked',
          recordId: row.recordId,
          packetId: row.packetId,
          scopeId: row.scopeId,
        );
      }
      if (_futureOnlyScopes.contains(row.scopeId) &&
          (row.reviewStatus !=
                  InternalPacketEvidenceRefreshReviewRowStatus
                      .validFutureOnly ||
              row.sourceRefreshStatus !=
                  InternalPacketEvidenceRefreshRecordStatus
                      .futureOnlyCorrectly)) {
        add(
          id: 'futureOnlyRecordBecameActive',
          severity:
              InternalPacketEvidenceRefreshReviewValidationSeverity.critical,
          message: '${row.scopeId.wire} must remain future-only',
          recordId: row.recordId,
          packetId: row.packetId,
          scopeId: row.scopeId,
        );
      }
      if (row.scopeId ==
              InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope &&
          (row.quietScopeActive ||
              row.reviewStatus !=
                  InternalPacketEvidenceRefreshReviewRowStatus.validBlocked ||
              row.sourceRefreshStatus !=
                  InternalPacketEvidenceRefreshRecordStatus.blockedCorrectly)) {
        add(
          id: 'quietPreparatoryScopeActivated',
          severity:
              InternalPacketEvidenceRefreshReviewValidationSeverity.critical,
          message: 'quiet/preparatory scope must remain excluded',
          recordId: row.recordId,
          packetId: row.packetId,
          scopeId: row.scopeId,
        );
      }
      if (row.hasUnsafeOutput) {
        add(
          id: 'reviewRowBoundaryPolicyViolation',
          severity:
              InternalPacketEvidenceRefreshReviewValidationSeverity.critical,
          message: '${row.packetId} crossed a blocked output boundary',
          recordId: row.recordId,
          packetId: row.packetId,
          scopeId: row.scopeId,
        );
      }
      for (final caseId in row.androidProofCaseIds) {
        if (!_capturedAndroidProofIds.contains(caseId) ||
            !provenAndroidIds.contains(caseId)) {
          add(
            id: 'unprovenAndroidProofClaim',
            severity:
                InternalPacketEvidenceRefreshReviewValidationSeverity.critical,
            message: '${row.packetId} cited unproven Android proof',
            recordId: row.recordId,
            packetId: row.packetId,
            scopeId: row.scopeId,
            caseId: caseId,
          );
        }
        if (_phase32ECaseIds.contains(caseId)) {
          add(
            id: 'phase32ECaseClaimedCapturedProof',
            severity:
                InternalPacketEvidenceRefreshReviewValidationSeverity.critical,
            message: 'Phase 32E case cannot be captured Android proof',
            recordId: row.recordId,
            packetId: row.packetId,
            scopeId: row.scopeId,
            caseId: caseId,
          );
        }
      }
    }

    for (final caseId in result.androidProofCaseIds) {
      if (!_capturedAndroidProofIds.contains(caseId) ||
          !provenAndroidIds.contains(caseId)) {
        add(
          id: 'unprovenAndroidProofClaim',
          severity:
              InternalPacketEvidenceRefreshReviewValidationSeverity.critical,
          message: 'review cited unproven Android proof',
          caseId: caseId,
        );
      }
      if (_phase32ECaseIds.contains(caseId)) {
        add(
          id: 'phase32ECaseClaimedCapturedProof',
          severity:
              InternalPacketEvidenceRefreshReviewValidationSeverity.critical,
          message: 'Phase 32E case cannot be captured Android proof',
          caseId: caseId,
        );
      }
    }

    if (result.productLabelsEmitted ||
        result.advancedLabelsEmitted ||
        result.classifierLabelsEmitted ||
        result.finalMoveLabelsEmitted ||
        result.officialMetricsAllowed ||
        result.cpLossComputationImplemented ||
        result.winProbabilityComputationImplemented ||
        result.numericMoveValuesComputed ||
        result.moveOrderingComputed ||
        result.quietPreparatoryScopeActivated ||
        result.directEngineAccessUsed ||
        result.uiOutputUsed ||
        result.backendOutputUsed ||
        result.persistenceUsed ||
        result.emittedOutputFamilies.any(_isForbiddenOutputName)) {
      add(
        id: 'reviewBoundaryPolicyViolation',
        severity:
            InternalPacketEvidenceRefreshReviewValidationSeverity.critical,
        message: 'review crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<InternalPacketEvidenceRefreshReviewFinding> validateReportText(
    String reportText,
  ) {
    final findings = <InternalPacketEvidenceRefreshReviewFinding>[];
    void reportError(String id, String message) {
      findings.add(
        InternalPacketEvidenceRefreshReviewFinding(
          id: id,
          severity:
              InternalPacketEvidenceRefreshReviewValidationSeverity.critical,
          message: message,
        ),
      );
    }

    final lower = reportText.toLowerCase();
    if (lower.contains('uciok') ||
        lower.contains('readyok') ||
        lower.contains('info depth') ||
        lower.contains('bestmove e2e4')) {
      reportError('rawUciReportText', 'report contains raw UCI text');
    }
    if (reportText.contains(' pv ') ||
        reportText.contains('pvMoves') ||
        reportText.contains('e2e4 e7e5')) {
      reportError('pvDumpReportText', 'report contains PV dump text');
    }
    for (final token in const <String>[
      'Brilliant',
      'Great',
      'Miss',
      'Best',
      'Good',
      'Inaccuracy',
      'Mistake',
      'Blunder',
      'ACPL',
      'accuracy',
    ]) {
      if (reportText.contains(token)) {
        reportError('forbiddenReportOutputName', 'report contains $token');
      }
    }
    if (reportText.contains('numeric move score:') ||
        reportText.contains('scoreValue') ||
        reportText.contains('moveScore')) {
      reportError(
        'numericMoveValueReportText',
        'report contains numeric move value text',
      );
    }
    if (reportText.contains('rankedMoves') ||
        reportText.contains('moveRanking')) {
      reportError(
        'moveOrderingReportText',
        'report contains move ordering text',
      );
    }
    return findings..sort(_compareFindings);
  }
}

List<InternalPacketEvidenceRefreshReviewRow> _rowsFrom(
  List<InternalPacketEvidenceRefreshRecord> records,
) {
  final rows = records.map(_rowFromRecord).toList()
    ..sort((a, b) => a.scopeId.index.compareTo(b.scopeId.index));
  return List<InternalPacketEvidenceRefreshReviewRow>.unmodifiable(rows);
}

InternalPacketEvidenceRefreshReviewRow _rowFromRecord(
  InternalPacketEvidenceRefreshRecord record,
) {
  final status = _rowStatusFor(record.refreshStatus);
  final safeForNextInternalGate =
      !status.isUnsafe &&
      record.safeForInternalUse &&
      !record.hasUnsafeOutput &&
      !_coreMappingMissing(
        record.scopeId,
        record.refreshedSupportCaseIds,
        record.activeSignalIds,
        record.evidenceAreaIds,
        record.bucketIds,
      );
  return InternalPacketEvidenceRefreshReviewRow(
    recordId: '${record.scopeId.wire}-review',
    packetId: record.packetId,
    scopeId: record.scopeId,
    packetKind: record.packetKind,
    sourceRefreshStatus: record.refreshStatus,
    reviewStatus: status,
    supportCaseIds: _sortedStrings(record.refreshedSupportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(record.newlyAddedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(record.androidProofCaseIds),
    activeSignalIds: record.activeSignalIds,
    evidenceAreaIds: record.evidenceAreaIds,
    bucketIds: record.bucketIds,
    qualitativeConfidence: record.qualitativeConfidence,
    reviewReason: _reviewReasonFor(status, record),
    warningReason: record.warningReason,
    proofLimitReason: record.proofLimitReason,
    futurePrerequisite: _ids(record.futurePrerequisites),
    blockedBoundaryIds: _sortedStrings(record.blockedBoundaryIds),
    coverageGapIds: _sortedStrings(record.coverageGapIds),
    safeForNextInternalGate: safeForNextInternalGate,
    recommendation: _rowRecommendationFor(status),
    isProductOutput: record.isProductOutput,
    isClassifierLabel: record.isClassifierLabel,
    isOfficialMetric: record.isOfficialMetric,
    hasNumericValue: record.hasNumericValue,
    ordersMoves: record.ordersMoves,
    quietScopeActive: record.quietScopeActive,
    cpLossComputationImplemented: record.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        record.winProbabilityComputationImplemented,
    emittedOutputNames: record.emittedOutputNames,
  );
}

InternalPacketEvidenceRefreshReviewResult _resultFromRows({
  required InternalPacketEvidenceRefreshResult refreshResult,
  required RefreshedPacketHardeningValidationResult validationResult,
  required RefreshedInternalPacketHardeningPlanResult planResult,
  required TargetedGoldenCoverageImpactReviewResult impactResult,
  required List<InternalPacketEvidenceRefreshReviewRow> rows,
  required List<InternalPacketEvidenceRefreshReviewFinding> validationFindings,
}) {
  final rowUnsafeCount = rows
      .where((row) => row.reviewStatus.isUnsafe || row.hasUnsafeOutput)
      .length;
  final unsafeCount = refreshResult.unsafeCount + rowUnsafeCount;
  final criticalCount =
      refreshResult.criticalCount +
      validationFindings.where((finding) => finding.isCritical).length;
  final invalidCount =
      rows
          .where(
            (row) =>
                row.reviewStatus ==
                InternalPacketEvidenceRefreshReviewRowStatus.invalid,
          )
          .length +
      validationFindings.where((finding) => finding.blocksStrict).length;
  final base = InternalPacketEvidenceRefreshReviewResult(
    reviewStatus: InternalPacketEvidenceRefreshReviewStatus.invalid,
    sourceRefreshStatus: refreshResult.refreshStatus,
    sourceValidationStatus: validationResult.validationStatus,
    sourcePlanStatus: planResult.refreshedStatus,
    sourceImpactStatus: impactResult.impactStatus,
    rows: rows,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...refreshResult.warnings,
      ...validationResult.warnings,
      ...planResult.warnings,
      if (rows.any(
        (row) =>
            row.reviewStatus ==
            InternalPacketEvidenceRefreshReviewRowStatus.validWarningLimited,
      ))
        'warning-limited review rows remain outside core packets',
      if (rows.any(
        (row) =>
            row.reviewStatus ==
            InternalPacketEvidenceRefreshReviewRowStatus.validWatchListed,
      ))
        'PV/MultiPV review remains watch-listed',
      if (rows.any(
        (row) =>
            row.reviewStatus ==
            InternalPacketEvidenceRefreshReviewRowStatus.validProofLimited,
      ))
        'Android proof review remains proof-limited',
    ]),
    failures: _sortedStrings(<String>[
      ...refreshResult.failures,
      ...validationResult.failures,
      ...planResult.failures,
      ...validationFindings.map((finding) => finding.message),
    ]),
    totalRows: rows.length,
    validPreservedStableCount: rows
        .where(
          (row) =>
              row.reviewStatus ==
              InternalPacketEvidenceRefreshReviewRowStatus.validPreservedStable,
        )
        .length,
    validImprovedSupportCount: rows
        .where(
          (row) =>
              row.reviewStatus ==
              InternalPacketEvidenceRefreshReviewRowStatus.validImprovedSupport,
        )
        .length,
    validWatchListedCount: rows
        .where(
          (row) =>
              row.reviewStatus ==
              InternalPacketEvidenceRefreshReviewRowStatus.validWatchListed,
        )
        .length,
    validProofLimitedCount: rows
        .where(
          (row) =>
              row.reviewStatus ==
              InternalPacketEvidenceRefreshReviewRowStatus.validProofLimited,
        )
        .length,
    validWarningLimitedCount: rows
        .where(
          (row) =>
              row.reviewStatus ==
              InternalPacketEvidenceRefreshReviewRowStatus.validWarningLimited,
        )
        .length,
    validBlockedCount: rows
        .where(
          (row) =>
              row.reviewStatus ==
              InternalPacketEvidenceRefreshReviewRowStatus.validBlocked,
        )
        .length,
    validFutureOnlyCount: rows
        .where(
          (row) =>
              row.reviewStatus ==
              InternalPacketEvidenceRefreshReviewRowStatus.validFutureOnly,
        )
        .length,
    invalidCount: invalidCount,
    unsafeCount: unsafeCount,
    criticalCount: criticalCount,
    ownerProofQueueCount: refreshResult.ownerProofQueueCount,
    supportCaseIds: _sortedStrings(rows.expand((row) => row.supportCaseIds)),
    newlyAddedSupportCaseIds: _sortedStrings(
      rows.expand((row) => row.newlyAddedSupportCaseIds),
    ),
    androidProofCaseIds: _sortedStrings(refreshResult.androidProofCaseIds),
    coverageGapIds: _sortedStrings(rows.expand((row) => row.coverageGapIds)),
    safeForPhase32K: false,
    phase32KRecommendation:
        InternalPacketEvidenceRefreshReviewPhase32KRecommendation
            .addMoreGoldenCoverageFirst,
    productLabelsEmitted:
        refreshResult.productLabelsEmitted ||
        validationResult.productLabelsEmitted ||
        planResult.productLabelsEmitted,
    advancedLabelsEmitted:
        refreshResult.advancedLabelsEmitted ||
        validationResult.advancedLabelsEmitted ||
        planResult.advancedLabelsEmitted,
    classifierLabelsEmitted:
        refreshResult.classifierLabelsEmitted ||
        validationResult.classifierLabelsEmitted ||
        planResult.classifierLabelsEmitted,
    finalMoveLabelsEmitted:
        refreshResult.finalMoveLabelsEmitted ||
        validationResult.finalMoveLabelsEmitted ||
        planResult.finalMoveLabelsEmitted,
    officialMetricsAllowed:
        refreshResult.officialMetricsAllowed ||
        validationResult.officialMetricsAllowed ||
        planResult.officialMetricsAllowed,
    cpLossComputationImplemented:
        refreshResult.cpLossComputationImplemented ||
        validationResult.cpLossComputationImplemented ||
        planResult.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        refreshResult.winProbabilityComputationImplemented ||
        validationResult.winProbabilityComputationImplemented ||
        planResult.winProbabilityComputationImplemented,
    numericMoveValuesComputed:
        refreshResult.numericMoveValuesComputed ||
        validationResult.numericMoveValuesComputed ||
        planResult.numericMoveValuesComputed,
    moveOrderingComputed:
        refreshResult.moveOrderingComputed ||
        validationResult.moveOrderingComputed ||
        planResult.moveOrderingComputed,
    quietPreparatoryScopeActivated:
        refreshResult.quietPreparatoryScopeActivated ||
        validationResult.quietPreparatoryScopeActivated ||
        planResult.quietPreparatoryScopeActivated,
    directEngineAccessUsed:
        refreshResult.directEngineAccessUsed ||
        validationResult.directEngineAccessUsed ||
        planResult.directEngineAccessUsed,
    uiOutputUsed:
        refreshResult.uiOutputUsed ||
        validationResult.uiOutputUsed ||
        planResult.uiOutputUsed,
    backendOutputUsed:
        refreshResult.backendOutputUsed ||
        validationResult.backendOutputUsed ||
        planResult.backendOutputUsed,
    persistenceUsed:
        refreshResult.persistenceUsed ||
        validationResult.persistenceUsed ||
        planResult.persistenceUsed,
    emittedOutputFamilies: _sortedStrings(<String>[
      ...refreshResult.emittedOutputFamilies,
      ...validationResult.emittedOutputFamilies,
      ...planResult.emittedOutputFamilies,
    ]),
  );
  final status = _reviewStatusFor(base, refreshResult: refreshResult);
  final safeForPhase32K =
      (status ==
              InternalPacketEvidenceRefreshReviewStatus.reviewedWithWarnings ||
          status == InternalPacketEvidenceRefreshReviewStatus.reviewedClean) &&
      refreshResult.safeForPhase32J &&
      !refreshResult.isStrictlyBlocked &&
      !refreshResult.hasUnsafeRefreshPolicyViolation &&
      unsafeCount == 0 &&
      criticalCount == 0 &&
      invalidCount == 0 &&
      !validationFindings.any((finding) => finding.blocksStrict) &&
      rows.every((row) => row.safeForNextInternalGate);
  return base.copyWith(
    reviewStatus: status,
    safeForPhase32K: safeForPhase32K,
    phase32KRecommendation: _phase32KRecommendationFor(
      status: status,
      safeForPhase32K: safeForPhase32K,
      ownerProofQueueCount: refreshResult.ownerProofQueueCount,
      warningCount:
          base.validWarningLimitedCount +
          base.validWatchListedCount +
          base.validProofLimitedCount,
    ),
  );
}

InternalPacketEvidenceRefreshReviewStatus _reviewStatusFor(
  InternalPacketEvidenceRefreshReviewResult result, {
  required InternalPacketEvidenceRefreshResult refreshResult,
}) {
  if (refreshResult.hasUnsafeRefreshPolicyViolation ||
      refreshResult.refreshStatus ==
          InternalPacketEvidenceRefreshStatus.blockedByUnsafeValidation ||
      result.unsafeCount > 0 ||
      result.criticalCount > 0 ||
      result.validationFindings.any((finding) => finding.isCritical)) {
    return InternalPacketEvidenceRefreshReviewStatus.blockedByUnsafeRefresh;
  }
  if (result.productLabelsEmitted ||
      result.advancedLabelsEmitted ||
      result.classifierLabelsEmitted ||
      result.finalMoveLabelsEmitted ||
      result.officialMetricsAllowed ||
      result.cpLossComputationImplemented ||
      result.winProbabilityComputationImplemented ||
      result.numericMoveValuesComputed ||
      result.moveOrderingComputed ||
      result.quietPreparatoryScopeActivated ||
      result.directEngineAccessUsed ||
      result.uiOutputUsed ||
      result.backendOutputUsed ||
      result.persistenceUsed ||
      result.emittedOutputFamilies.any(_isForbiddenOutputName)) {
    return InternalPacketEvidenceRefreshReviewStatus.blockedByPolicyBoundary;
  }
  if (!refreshResult.safeForPhase32J ||
      refreshResult.isStrictlyBlocked ||
      result.validationFindings.any((finding) => finding.blocksStrict) ||
      result.invalidCount > 0) {
    return InternalPacketEvidenceRefreshReviewStatus.blockedByInvalidRecord;
  }
  if (result.rows.isEmpty) {
    return InternalPacketEvidenceRefreshReviewStatus.invalid;
  }
  if (result.validWarningLimitedCount > 0 ||
      result.validWatchListedCount > 0 ||
      result.validProofLimitedCount > 0 ||
      result.coverageGapIds.isNotEmpty) {
    return InternalPacketEvidenceRefreshReviewStatus.reviewedWithWarnings;
  }
  return InternalPacketEvidenceRefreshReviewStatus.reviewedClean;
}

InternalPacketEvidenceRefreshReviewPhase32KRecommendation
_phase32KRecommendationFor({
  required InternalPacketEvidenceRefreshReviewStatus status,
  required bool safeForPhase32K,
  required int ownerProofQueueCount,
  required int warningCount,
}) {
  if (status ==
          InternalPacketEvidenceRefreshReviewStatus.blockedByUnsafeRefresh ||
      status ==
          InternalPacketEvidenceRefreshReviewStatus.blockedByPolicyBoundary) {
    return InternalPacketEvidenceRefreshReviewPhase32KRecommendation
        .blockedByUnsafeReview;
  }
  if (ownerProofQueueCount > 0) {
    return InternalPacketEvidenceRefreshReviewPhase32KRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase32K) {
    return InternalPacketEvidenceRefreshReviewPhase32KRecommendation
        .addMoreGoldenCoverageFirst;
  }
  if (warningCount > 0) {
    return InternalPacketEvidenceRefreshReviewPhase32KRecommendation
        .proceedToRefreshedEvidenceReadinessGate;
  }
  return InternalPacketEvidenceRefreshReviewPhase32KRecommendation
      .proceedToInternalEvidenceRefreshSummary;
}

InternalPacketEvidenceRefreshReviewRowStatus _rowStatusFor(
  InternalPacketEvidenceRefreshRecordStatus status,
) {
  return switch (status) {
    InternalPacketEvidenceRefreshRecordStatus.preservedStable =>
      InternalPacketEvidenceRefreshReviewRowStatus.validPreservedStable,
    InternalPacketEvidenceRefreshRecordStatus.improvedSupport =>
      InternalPacketEvidenceRefreshReviewRowStatus.validImprovedSupport,
    InternalPacketEvidenceRefreshRecordStatus.watchListed =>
      InternalPacketEvidenceRefreshReviewRowStatus.validWatchListed,
    InternalPacketEvidenceRefreshRecordStatus.proofLimited =>
      InternalPacketEvidenceRefreshReviewRowStatus.validProofLimited,
    InternalPacketEvidenceRefreshRecordStatus.warningLimitedOnly =>
      InternalPacketEvidenceRefreshReviewRowStatus.validWarningLimited,
    InternalPacketEvidenceRefreshRecordStatus.blockedCorrectly =>
      InternalPacketEvidenceRefreshReviewRowStatus.validBlocked,
    InternalPacketEvidenceRefreshRecordStatus.futureOnlyCorrectly =>
      InternalPacketEvidenceRefreshReviewRowStatus.validFutureOnly,
    InternalPacketEvidenceRefreshRecordStatus.invalid =>
      InternalPacketEvidenceRefreshReviewRowStatus.invalid,
    InternalPacketEvidenceRefreshRecordStatus.unsafe =>
      InternalPacketEvidenceRefreshReviewRowStatus.unsafe,
  };
}

InternalPacketEvidenceRefreshReviewRecommendation _rowRecommendationFor(
  InternalPacketEvidenceRefreshReviewRowStatus status,
) {
  return switch (status) {
    InternalPacketEvidenceRefreshReviewRowStatus.validPreservedStable =>
      InternalPacketEvidenceRefreshReviewRecommendation.keepPreservedStable,
    InternalPacketEvidenceRefreshReviewRowStatus.validImprovedSupport =>
      InternalPacketEvidenceRefreshReviewRecommendation.keepImprovedSupport,
    InternalPacketEvidenceRefreshReviewRowStatus.validWatchListed =>
      InternalPacketEvidenceRefreshReviewRecommendation.keepWatchListed,
    InternalPacketEvidenceRefreshReviewRowStatus.validProofLimited =>
      InternalPacketEvidenceRefreshReviewRecommendation.keepProofLimited,
    InternalPacketEvidenceRefreshReviewRowStatus.validWarningLimited =>
      InternalPacketEvidenceRefreshReviewRecommendation.keepWarningLimited,
    InternalPacketEvidenceRefreshReviewRowStatus.validBlocked =>
      InternalPacketEvidenceRefreshReviewRecommendation.keepBlocked,
    InternalPacketEvidenceRefreshReviewRowStatus.validFutureOnly =>
      InternalPacketEvidenceRefreshReviewRecommendation.keepFutureOnly,
    InternalPacketEvidenceRefreshReviewRowStatus.invalid =>
      InternalPacketEvidenceRefreshReviewRecommendation
          .investigateInvalidRecord,
    InternalPacketEvidenceRefreshReviewRowStatus.unsafe =>
      InternalPacketEvidenceRefreshReviewRecommendation.blockUnsafeRecord,
  };
}

String _reviewReasonFor(
  InternalPacketEvidenceRefreshReviewRowStatus status,
  InternalPacketEvidenceRefreshRecord record,
) {
  return switch (status) {
    InternalPacketEvidenceRefreshReviewRowStatus.validPreservedStable =>
      'preserved stable evidence remains support-backed',
    InternalPacketEvidenceRefreshReviewRowStatus.validImprovedSupport =>
      'Phase 32E support is present and remains internal-only',
    InternalPacketEvidenceRefreshReviewRowStatus.validWatchListed =>
      'watch-listed boundary remains visible without new proof',
    InternalPacketEvidenceRefreshReviewRowStatus.validProofLimited =>
      'proof-limited record cites captured Android proof IDs only',
    InternalPacketEvidenceRefreshReviewRowStatus.validWarningLimited =>
      'warning-limited record remains outside core packet generation',
    InternalPacketEvidenceRefreshReviewRowStatus.validBlocked =>
      'blocked scope remains inactive',
    InternalPacketEvidenceRefreshReviewRowStatus.validFutureOnly =>
      'future-only scope remains inactive',
    InternalPacketEvidenceRefreshReviewRowStatus.invalid =>
      'refreshed record is invalid for review',
    InternalPacketEvidenceRefreshReviewRowStatus.unsafe =>
      'refreshed record is unsafe for review',
  };
}

bool _coreMappingMissing(
  InternalNonLabelPrototypeScopeId scopeId,
  List<String> supportCaseIds,
  List<InternalNonLabelSignalId> activeSignalIds,
  List<InternalEvidenceAreaId> evidenceAreaIds,
  List<InternalEvidenceBucketId> bucketIds,
) {
  return _allowedPacketScopes.contains(scopeId) &&
      (supportCaseIds.isEmpty ||
          activeSignalIds.isEmpty ||
          evidenceAreaIds.isEmpty ||
          bucketIds.isEmpty);
}

Set<String> _provenAndroidProofIds(
  GoldenAndroidProofEvidence? androidProofEvidence,
) {
  final proofIds = androidProofEvidence?.targetCaseIds ?? const <String>[];
  return proofIds
      .where(
        (caseId) =>
            _capturedAndroidProofIds.contains(caseId) &&
            (androidProofEvidence?.isRealDeviceProofCapturedFor(
                  caseId,
                  minMultiPvLineCount: 1,
                  requirePv: true,
                ) ??
                false),
      )
      .toSet();
}

String _cell(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? '-' : normalized.replaceAll('|', '/');
}

String _ids(Iterable<String> values) {
  final ids = _sortedStrings(values);
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _packetIds(Iterable<InternalPacketEvidenceRefreshReviewRow> rows) {
  final ids = rows.map((row) => row.packetId).toSet().toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _signalIds(Iterable<InternalNonLabelSignalId> values) {
  final ids = values.map((id) => id.wire).toSet().toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _areaIds(Iterable<InternalEvidenceAreaId> values) {
  final ids = values.map((id) => id.wire).toSet().toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _bucketIds(Iterable<InternalEvidenceBucketId> values) {
  final ids = values.map((id) => id.wire).toSet().toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.where((value) => value.isNotEmpty).toSet().toList()..sort();
}

int _compareFindings(
  InternalPacketEvidenceRefreshReviewFinding a,
  InternalPacketEvidenceRefreshReviewFinding b,
) {
  final severityCompare = b.severity.index.compareTo(a.severity.index);
  if (severityCompare != 0) return severityCompare;
  final idCompare = a.id.compareTo(b.id);
  if (idCompare != 0) return idCompare;
  final recordCompare = (a.recordId ?? '').compareTo(b.recordId ?? '');
  if (recordCompare != 0) return recordCompare;
  final packetCompare = (a.packetId ?? '').compareTo(b.packetId ?? '');
  if (packetCompare != 0) return packetCompare;
  final scopeCompare = (a.scopeId?.wire ?? '').compareTo(b.scopeId?.wire ?? '');
  if (scopeCompare != 0) return scopeCompare;
  return (a.caseId ?? '').compareTo(b.caseId ?? '');
}

bool _isForbiddenOutputName(String value) {
  final normalized = value.trim().toLowerCase();
  return _forbiddenOutputNames.contains(normalized) ||
      normalized.contains('productlabel') ||
      normalized.contains('movequality') ||
      normalized.contains('finalmove') ||
      normalized.contains('advancedcandidate') ||
      normalized.contains('numericmovescore') ||
      normalized.contains('rankedmoves');
}

const _phase32ECaseIds = <String>{
  'king-safety-mating-net-pressure-32e',
  'endgame-precision-candidate-spread-32e',
  'suppression-forced-only-legal-32e',
  'budget-pressure-wide-candidate-32e',
  'pv-multipv-support-boundary-32e',
};

const _capturedAndroidProofIds = <String>{
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
};

const _allowedPacketScopes = <InternalNonLabelPrototypeScopeId>{
  InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.materialSwingInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.forcingLineInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.candidateSpreadInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.androidProofConfidenceInternalPrototypeScope,
};

const _warningLimitedScopes = <InternalNonLabelPrototypeScopeId>{
  InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.endgameInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.suppressionSafetyInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.budgetRiskInternalPrototypeScope,
};

const _futureOnlyScopes = <InternalNonLabelPrototypeScopeId>{
  InternalNonLabelPrototypeScopeId.cpLossPrototypeScope,
  InternalNonLabelPrototypeScopeId.winProbabilityPrototypeScope,
};

const _blockedScopes = <InternalNonLabelPrototypeScopeId>{
  InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
  InternalNonLabelPrototypeScopeId.productLabelPrototypeScope,
  InternalNonLabelPrototypeScopeId.advancedLabelPrototypeScope,
  InternalNonLabelPrototypeScopeId.officialMetricPrototypeScope,
  InternalNonLabelPrototypeScopeId.uiProductIntegrationScope,
  InternalNonLabelPrototypeScopeId.backendIntegrationScope,
  InternalNonLabelPrototypeScopeId.persistenceScope,
  InternalNonLabelPrototypeScopeId.directEngineAccessScope,
};

const _forbiddenOutputNames = <String>{
  'brilliant',
  'great',
  'miss',
  'best',
  'good',
  'inaccuracy',
  'mistake',
  'blunder',
  'accuracy',
  'acpl',
  'cp-loss',
  'win probability',
  'score',
  'ranking',
};

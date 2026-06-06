/// Developer-only refreshed internal packet evidence after Phase 32H.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_review_aggregation_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_stability_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/narrow_internal_non_label_analysis_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_internal_packet_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_hardening_validation.dart';
import 'package:apex_chess/features/pgn_review/application/targeted_golden_coverage_impact_review.dart';

const internalPacketEvidenceRefreshReportVersion =
    'internal-packet-evidence-refresh-v1';

enum InternalPacketEvidenceRefreshStatus {
  refreshedWithWarnings('refreshedWithWarnings'),
  refreshedClean('refreshedClean'),
  skippedByValidationFailure('skippedByValidationFailure'),
  blockedByUnsafeValidation('blockedByUnsafeValidation'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const InternalPacketEvidenceRefreshStatus(this.wire);

  final String wire;
}

enum InternalPacketEvidenceRefreshRecordStatus {
  preservedStable('preservedStable'),
  improvedSupport('improvedSupport'),
  watchListed('watchListed'),
  proofLimited('proofLimited'),
  warningLimitedOnly('warningLimitedOnly'),
  blockedCorrectly('blockedCorrectly'),
  futureOnlyCorrectly('futureOnlyCorrectly'),
  unsafe('unsafe'),
  invalid('invalid');

  const InternalPacketEvidenceRefreshRecordStatus(this.wire);

  final String wire;

  bool get isUnsafe =>
      this == InternalPacketEvidenceRefreshRecordStatus.unsafe ||
      this == InternalPacketEvidenceRefreshRecordStatus.invalid;
}

enum InternalPacketEvidenceRefreshRecommendation {
  preserveStableEvidence('preserveStableEvidence'),
  reviewImprovedSupport('reviewImprovedSupport'),
  keepWatchListed('keepWatchListed'),
  keepProofLimited('keepProofLimited'),
  keepWarningLimitedOutsideCore('keepWarningLimitedOutsideCore'),
  keepBlockedByPolicy('keepBlockedByPolicy'),
  keepFutureOnly('keepFutureOnly'),
  investigateUnsafeRefresh('investigateUnsafeRefresh');

  const InternalPacketEvidenceRefreshRecommendation(this.wire);

  final String wire;
}

enum InternalPacketEvidenceRefreshPhase32JRecommendation {
  reviewRefreshedPacketEvidence('reviewRefreshedPacketEvidence'),
  proceedToInternalEvidenceRefreshReview(
    'proceedToInternalEvidenceRefreshReview',
  ),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeRefresh('blockedByUnsafeRefresh');

  const InternalPacketEvidenceRefreshPhase32JRecommendation(this.wire);

  final String wire;
}

enum InternalPacketEvidenceRefreshValidationSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const InternalPacketEvidenceRefreshValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == InternalPacketEvidenceRefreshValidationSeverity.blocker ||
      this == InternalPacketEvidenceRefreshValidationSeverity.critical;
}

enum InternalPacketEvidenceRefreshReportFormat {
  markdown('markdown'),
  json('json');

  const InternalPacketEvidenceRefreshReportFormat(this.wire);

  final String wire;
}

class InternalPacketEvidenceRefreshRequest {
  const InternalPacketEvidenceRefreshRequest({
    this.validationResult,
    this.refreshedPlanResult,
    this.impactReviewResult,
    this.hardeningPlanResult,
    this.stabilityResult,
    this.matrixResult,
    this.prototypeResult,
    this.validation = const RefreshedPacketHardeningValidation(),
    this.refreshedPlan = const RefreshedInternalPacketHardeningPlan(),
    this.impactReview = const TargetedGoldenCoverageImpactReview(),
    this.hardeningPlan = const InternalPacketEvidenceHardeningPlan(),
    this.stabilityPrototype = const InternalPacketStabilityPrototype(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const InternalPacketEvidenceRefreshRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final RefreshedPacketHardeningValidationResult? validationResult;
  final RefreshedInternalPacketHardeningPlanResult? refreshedPlanResult;
  final TargetedGoldenCoverageImpactReviewResult? impactReviewResult;
  final InternalPacketEvidenceHardeningPlanResult? hardeningPlanResult;
  final InternalPacketStabilityPrototypeResult? stabilityResult;
  final InternalPacketReviewAggregationMatrixResult? matrixResult;
  final NarrowInternalNonLabelAnalysisPrototypeResult? prototypeResult;
  final RefreshedPacketHardeningValidation validation;
  final RefreshedInternalPacketHardeningPlan refreshedPlan;
  final TargetedGoldenCoverageImpactReview impactReview;
  final InternalPacketEvidenceHardeningPlan hardeningPlan;
  final InternalPacketStabilityPrototype stabilityPrototype;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class InternalPacketEvidenceRefreshRecord {
  const InternalPacketEvidenceRefreshRecord({
    required this.packetId,
    required this.scopeId,
    required this.packetKind,
    required this.refreshStatus,
    required this.previousStabilityStatus,
    required this.refreshedSupportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.activeSignalIds,
    required this.evidenceAreaIds,
    required this.bucketIds,
    required this.qualitativeConfidence,
    required this.refreshedEvidenceReason,
    required this.proofLimitReason,
    required this.warningReason,
    required this.coverageGapIds,
    required this.futurePrerequisites,
    required this.blockedBoundaryIds,
    required this.safeForInternalUse,
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

  final String packetId;
  final InternalNonLabelPrototypeScopeId scopeId;
  final InternalPacketEvidenceHardeningTargetKind packetKind;
  final InternalPacketEvidenceRefreshRecordStatus refreshStatus;
  final InternalPacketStabilityStatus previousStabilityStatus;
  final List<String> refreshedSupportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<InternalNonLabelSignalId> activeSignalIds;
  final List<InternalEvidenceAreaId> evidenceAreaIds;
  final List<InternalEvidenceBucketId> bucketIds;
  final InternalNonLabelSignalConfidence qualitativeConfidence;
  final String refreshedEvidenceReason;
  final String proofLimitReason;
  final String warningReason;
  final List<String> coverageGapIds;
  final List<String> futurePrerequisites;
  final List<String> blockedBoundaryIds;
  final bool safeForInternalUse;
  final InternalPacketEvidenceRefreshRecommendation recommendation;
  final bool isProductOutput;
  final bool isClassifierLabel;
  final bool isOfficialMetric;
  final bool hasNumericValue;
  final bool ordersMoves;
  final bool quietScopeActive;
  final bool cpLossComputationImplemented;
  final bool winProbabilityComputationImplemented;
  final List<String> emittedOutputNames;

  bool get isCorePacketRecord => _allowedPacketScopes.contains(scopeId);

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

  InternalPacketEvidenceRefreshRecord copyWith({
    String? packetId,
    InternalNonLabelPrototypeScopeId? scopeId,
    InternalPacketEvidenceHardeningTargetKind? packetKind,
    InternalPacketEvidenceRefreshRecordStatus? refreshStatus,
    InternalPacketStabilityStatus? previousStabilityStatus,
    List<String>? refreshedSupportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<InternalNonLabelSignalId>? activeSignalIds,
    List<InternalEvidenceAreaId>? evidenceAreaIds,
    List<InternalEvidenceBucketId>? bucketIds,
    InternalNonLabelSignalConfidence? qualitativeConfidence,
    String? refreshedEvidenceReason,
    String? proofLimitReason,
    String? warningReason,
    List<String>? coverageGapIds,
    List<String>? futurePrerequisites,
    List<String>? blockedBoundaryIds,
    bool? safeForInternalUse,
    InternalPacketEvidenceRefreshRecommendation? recommendation,
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
    return InternalPacketEvidenceRefreshRecord(
      packetId: packetId ?? this.packetId,
      scopeId: scopeId ?? this.scopeId,
      packetKind: packetKind ?? this.packetKind,
      refreshStatus: refreshStatus ?? this.refreshStatus,
      previousStabilityStatus:
          previousStabilityStatus ?? this.previousStabilityStatus,
      refreshedSupportCaseIds:
          refreshedSupportCaseIds ?? this.refreshedSupportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      activeSignalIds: activeSignalIds ?? this.activeSignalIds,
      evidenceAreaIds: evidenceAreaIds ?? this.evidenceAreaIds,
      bucketIds: bucketIds ?? this.bucketIds,
      qualitativeConfidence:
          qualitativeConfidence ?? this.qualitativeConfidence,
      refreshedEvidenceReason:
          refreshedEvidenceReason ?? this.refreshedEvidenceReason,
      proofLimitReason: proofLimitReason ?? this.proofLimitReason,
      warningReason: warningReason ?? this.warningReason,
      coverageGapIds: coverageGapIds ?? this.coverageGapIds,
      futurePrerequisites: futurePrerequisites ?? this.futurePrerequisites,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      safeForInternalUse: safeForInternalUse ?? this.safeForInternalUse,
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
      'packetId': packetId,
      'scopeId': scopeId.wire,
      'packetKind': packetKind.wire,
      'refreshStatus': refreshStatus.wire,
      'previousStabilityStatus': previousStabilityStatus.wire,
      'refreshedSupportCaseIds': refreshedSupportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'activeSignalIds': activeSignalIds.map((id) => id.wire).toList(),
      'evidenceAreaIds': evidenceAreaIds.map((id) => id.wire).toList(),
      'bucketIds': bucketIds.map((id) => id.wire).toList(),
      'qualitativeConfidence': qualitativeConfidence.wire,
      'refreshedEvidenceReason': refreshedEvidenceReason,
      'proofLimitReason': proofLimitReason,
      'warningReason': warningReason,
      'coverageGapIds': coverageGapIds,
      'futurePrerequisites': futurePrerequisites,
      'blockedBoundaryIds': blockedBoundaryIds,
      'safeForInternalUse': safeForInternalUse,
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

class InternalPacketEvidenceRefreshFinding {
  const InternalPacketEvidenceRefreshFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.packetId,
    this.scopeId,
    this.caseId,
  });

  final String id;
  final InternalPacketEvidenceRefreshValidationSeverity severity;
  final String message;
  final String? packetId;
  final InternalNonLabelPrototypeScopeId? scopeId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical =>
      severity == InternalPacketEvidenceRefreshValidationSeverity.critical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (packetId != null) 'packetId': packetId,
      if (scopeId != null) 'scopeId': scopeId!.wire,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class InternalPacketEvidenceRefreshResult {
  const InternalPacketEvidenceRefreshResult({
    required this.refreshStatus,
    required this.sourceValidationStatus,
    required this.sourceRefreshStatus,
    required this.sourceImpactStatus,
    required this.sourceStabilityStatus,
    required this.records,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalRecords,
    required this.refreshedPacketCount,
    required this.improvedSupportCount,
    required this.preservedStableCount,
    required this.watchListedCount,
    required this.proofLimitedCount,
    required this.warningLimitedCount,
    required this.blockedCount,
    required this.futureOnlyCount,
    required this.unsafeCount,
    required this.criticalCount,
    required this.ownerProofQueueCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.coverageGapIds,
    required this.safeForPhase32J,
    required this.phase32JRecommendation,
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

  final InternalPacketEvidenceRefreshStatus refreshStatus;
  final RefreshedPacketHardeningValidationStatus sourceValidationStatus;
  final RefreshedInternalPacketHardeningStatus sourceRefreshStatus;
  final TargetedGoldenCoverageImpactStatus sourceImpactStatus;
  final InternalPacketStabilityPrototypeStatus sourceStabilityStatus;
  final List<InternalPacketEvidenceRefreshRecord> records;
  final List<InternalPacketEvidenceRefreshFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalRecords;
  final int refreshedPacketCount;
  final int improvedSupportCount;
  final int preservedStableCount;
  final int watchListedCount;
  final int proofLimitedCount;
  final int warningLimitedCount;
  final int blockedCount;
  final int futureOnlyCount;
  final int unsafeCount;
  final int criticalCount;
  final int ownerProofQueueCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> coverageGapIds;
  final bool safeForPhase32J;
  final InternalPacketEvidenceRefreshPhase32JRecommendation
  phase32JRecommendation;
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
      refreshStatus ==
          InternalPacketEvidenceRefreshStatus.blockedByUnsafeValidation ||
      refreshStatus ==
          InternalPacketEvidenceRefreshStatus.blockedByPolicyBoundary ||
      refreshStatus ==
          InternalPacketEvidenceRefreshStatus.skippedByValidationFailure ||
      refreshStatus == InternalPacketEvidenceRefreshStatus.invalid ||
      !safeForPhase32J ||
      unsafeCount > 0 ||
      criticalCount > 0 ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeRefreshPolicyViolation {
    return unsafeCount > 0 ||
        criticalCount > 0 ||
        validationFindings.any((finding) => finding.isCritical) ||
        records.any(
          (record) => record.refreshStatus.isUnsafe || record.hasUnsafeOutput,
        ) ||
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

  InternalPacketEvidenceRefreshRecord record(
    InternalNonLabelPrototypeScopeId scopeId,
  ) {
    return records.singleWhere((record) => record.scopeId == scopeId);
  }

  List<InternalPacketEvidenceRefreshRecord> get improvedSupportRecords =>
      records
          .where(
            (record) =>
                record.refreshStatus ==
                InternalPacketEvidenceRefreshRecordStatus.improvedSupport,
          )
          .toList(growable: false);

  List<InternalPacketEvidenceRefreshRecord> get preservedStableRecords =>
      records
          .where(
            (record) =>
                record.refreshStatus ==
                InternalPacketEvidenceRefreshRecordStatus.preservedStable,
          )
          .toList(growable: false);

  List<InternalPacketEvidenceRefreshRecord> get watchListedRecords => records
      .where(
        (record) =>
            record.refreshStatus ==
            InternalPacketEvidenceRefreshRecordStatus.watchListed,
      )
      .toList(growable: false);

  List<InternalPacketEvidenceRefreshRecord> get proofLimitedRecords => records
      .where(
        (record) =>
            record.refreshStatus ==
            InternalPacketEvidenceRefreshRecordStatus.proofLimited,
      )
      .toList(growable: false);

  List<InternalPacketEvidenceRefreshRecord> get warningLimitedRecords => records
      .where(
        (record) =>
            record.refreshStatus ==
            InternalPacketEvidenceRefreshRecordStatus.warningLimitedOnly,
      )
      .toList(growable: false);

  List<InternalPacketEvidenceRefreshRecord>
  get blockedOrFutureRecords => records
      .where(
        (record) =>
            record.refreshStatus ==
                InternalPacketEvidenceRefreshRecordStatus.blockedCorrectly ||
            record.refreshStatus ==
                InternalPacketEvidenceRefreshRecordStatus.futureOnlyCorrectly,
      )
      .toList(growable: false);

  InternalPacketEvidenceRefreshResult copyWith({
    InternalPacketEvidenceRefreshStatus? refreshStatus,
    RefreshedPacketHardeningValidationStatus? sourceValidationStatus,
    RefreshedInternalPacketHardeningStatus? sourceRefreshStatus,
    TargetedGoldenCoverageImpactStatus? sourceImpactStatus,
    InternalPacketStabilityPrototypeStatus? sourceStabilityStatus,
    List<InternalPacketEvidenceRefreshRecord>? records,
    List<InternalPacketEvidenceRefreshFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalRecords,
    int? refreshedPacketCount,
    int? improvedSupportCount,
    int? preservedStableCount,
    int? watchListedCount,
    int? proofLimitedCount,
    int? warningLimitedCount,
    int? blockedCount,
    int? futureOnlyCount,
    int? unsafeCount,
    int? criticalCount,
    int? ownerProofQueueCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? coverageGapIds,
    bool? safeForPhase32J,
    InternalPacketEvidenceRefreshPhase32JRecommendation? phase32JRecommendation,
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
    return InternalPacketEvidenceRefreshResult(
      refreshStatus: refreshStatus ?? this.refreshStatus,
      sourceValidationStatus:
          sourceValidationStatus ?? this.sourceValidationStatus,
      sourceRefreshStatus: sourceRefreshStatus ?? this.sourceRefreshStatus,
      sourceImpactStatus: sourceImpactStatus ?? this.sourceImpactStatus,
      sourceStabilityStatus:
          sourceStabilityStatus ?? this.sourceStabilityStatus,
      records: records ?? this.records,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalRecords: totalRecords ?? this.totalRecords,
      refreshedPacketCount: refreshedPacketCount ?? this.refreshedPacketCount,
      improvedSupportCount: improvedSupportCount ?? this.improvedSupportCount,
      preservedStableCount: preservedStableCount ?? this.preservedStableCount,
      watchListedCount: watchListedCount ?? this.watchListedCount,
      proofLimitedCount: proofLimitedCount ?? this.proofLimitedCount,
      warningLimitedCount: warningLimitedCount ?? this.warningLimitedCount,
      blockedCount: blockedCount ?? this.blockedCount,
      futureOnlyCount: futureOnlyCount ?? this.futureOnlyCount,
      unsafeCount: unsafeCount ?? this.unsafeCount,
      criticalCount: criticalCount ?? this.criticalCount,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      coverageGapIds: coverageGapIds ?? this.coverageGapIds,
      safeForPhase32J: safeForPhase32J ?? this.safeForPhase32J,
      phase32JRecommendation:
          phase32JRecommendation ?? this.phase32JRecommendation,
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
      ..writeln('# Internal Packet Evidence Refresh')
      ..writeln()
      ..writeln('- version: $internalPacketEvidenceRefreshReportVersion')
      ..writeln('- refresh status: ${refreshStatus.wire}')
      ..writeln('- source validation status: ${sourceValidationStatus.wire}')
      ..writeln('- source refresh status: ${sourceRefreshStatus.wire}')
      ..writeln('- source impact status: ${sourceImpactStatus.wire}')
      ..writeln('- source stability status: ${sourceStabilityStatus.wire}')
      ..writeln('- total records: $totalRecords')
      ..writeln('- refreshed packet count: $refreshedPacketCount')
      ..writeln('- improved support count: $improvedSupportCount')
      ..writeln('- preserved stable count: $preservedStableCount')
      ..writeln('- watch-listed count: $watchListedCount')
      ..writeln('- proof-limited count: $proofLimitedCount')
      ..writeln('- warning-limited count: $warningLimitedCount')
      ..writeln('- blocked count: $blockedCount')
      ..writeln('- future-only count: $futureOnlyCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- safe for Phase 32J: $safeForPhase32J')
      ..writeln('- Phase 32J recommendation: ${phase32JRecommendation.wire}')
      ..writeln('- classifier output emitted: $classifierLabelsEmitted')
      ..writeln('- numeric value output emitted: $numericMoveValuesComputed')
      ..writeln('- move ordering output emitted: $moveOrderingComputed')
      ..writeln()
      ..writeln('## Refresh Policy')
      ..writeln(
        '- this refresh consumes the validated Phase 32H internal result only',
      )
      ..writeln(
        '- it refreshes internal packet evidence and does not classify, value, order, integrate, call an engine, run Android, or write files',
      )
      ..writeln()
      ..writeln('## Refreshed Evidence Table')
      ..writeln(
        '| Packet | Scope | Kind | Status | Previous Stability | Support Cases | New Phase 32E Support | Android Proof | Signals | Areas | Buckets | Confidence | Safe | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final record in records) {
      buffer.writeln(
        '| ${_cell(record.packetId)} | ${record.scopeId.wire} | '
        '${record.packetKind.wire} | ${record.refreshStatus.wire} | '
        '${record.previousStabilityStatus.wire} | '
        '${_ids(record.refreshedSupportCaseIds)} | '
        '${_ids(record.newlyAddedSupportCaseIds)} | '
        '${_ids(record.androidProofCaseIds)} | '
        '${_signalIds(record.activeSignalIds)} | '
        '${_areaIds(record.evidenceAreaIds)} | '
        '${_bucketIds(record.bucketIds)} | '
        '${record.qualitativeConfidence.wire} | '
        '${record.safeForInternalUse} | ${record.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Improved Support Records')
      ..writeln('- ${_packetIds(improvedSupportRecords)}')
      ..writeln()
      ..writeln('## Preserved Records')
      ..writeln('- ${_packetIds(preservedStableRecords)}')
      ..writeln()
      ..writeln('## Watch-Listed Records')
      ..writeln('- ${_packetIds(watchListedRecords)}')
      ..writeln()
      ..writeln('## Proof-Limited Records')
      ..writeln('- ${_packetIds(proofLimitedRecords)}')
      ..writeln()
      ..writeln('## Warning-Limited Records')
      ..writeln('- ${_packetIds(warningLimitedRecords)}')
      ..writeln()
      ..writeln('## Blocked And Future-Only Records')
      ..writeln('- ${_packetIds(blockedOrFutureRecords)}')
      ..writeln()
      ..writeln('## Newly Added Phase 32E Support Case IDs')
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
      ..writeln('## Phase 32J Recommendation')
      ..writeln(phase32JRecommendation.wire)
      ..writeln()
      ..writeln(
        'This refresh stays internal-only. It does not emit user-facing output, compute product metrics, call the engine, run Android, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': internalPacketEvidenceRefreshReportVersion,
      'refreshStatus': refreshStatus.wire,
      'sourceValidationStatus': sourceValidationStatus.wire,
      'sourceRefreshStatus': sourceRefreshStatus.wire,
      'sourceImpactStatus': sourceImpactStatus.wire,
      'sourceStabilityStatus': sourceStabilityStatus.wire,
      'totalRecords': totalRecords,
      'refreshedPacketCount': refreshedPacketCount,
      'improvedSupportCount': improvedSupportCount,
      'preservedStableCount': preservedStableCount,
      'watchListedCount': watchListedCount,
      'proofLimitedCount': proofLimitedCount,
      'warningLimitedCount': warningLimitedCount,
      'blockedCount': blockedCount,
      'futureOnlyCount': futureOnlyCount,
      'unsafeCount': unsafeCount,
      'criticalCount': criticalCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'coverageGapIds': coverageGapIds,
      'safeForPhase32J': safeForPhase32J,
      'phase32JRecommendation': phase32JRecommendation.wire,
      'records': records.map((record) => record.toJson()).toList(),
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

class InternalPacketEvidenceRefresh {
  const InternalPacketEvidenceRefresh({
    this.validator = const InternalPacketEvidenceRefreshValidator(),
  });

  final InternalPacketEvidenceRefreshValidator validator;

  InternalPacketEvidenceRefreshResult evaluate([
    InternalPacketEvidenceRefreshRequest request =
        const InternalPacketEvidenceRefreshRequest(),
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
    final refreshResult =
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
            refreshedPlanResult: refreshResult,
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
    final canBuildRecords =
        validationResult.safeForPhase32I &&
        !validationResult.isStrictlyBlocked &&
        !validationResult.hasUnsafeValidationPolicyViolation;
    final records = canBuildRecords
        ? _recordsFrom(
            refreshResult: refreshResult,
            validationResult: validationResult,
            stabilityResult: stabilityResult,
          )
        : const <InternalPacketEvidenceRefreshRecord>[];
    final base = _resultFromRecords(
      validationResult: validationResult,
      refreshResult: refreshResult,
      impactResult: impactResult,
      stabilityResult: stabilityResult,
      records: records,
      validationFindings: const <InternalPacketEvidenceRefreshFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromRecords(
      validationResult: validationResult,
      refreshResult: refreshResult,
      impactResult: impactResult,
      stabilityResult: stabilityResult,
      records: records,
      validationFindings: findings,
    );
  }
}

class InternalPacketEvidenceRefreshValidator {
  const InternalPacketEvidenceRefreshValidator();

  List<InternalPacketEvidenceRefreshFinding> validate(
    InternalPacketEvidenceRefreshResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <InternalPacketEvidenceRefreshFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required InternalPacketEvidenceRefreshValidationSeverity severity,
      required String message,
      String? packetId,
      InternalNonLabelPrototypeScopeId? scopeId,
      String? caseId,
    }) {
      findings.add(
        InternalPacketEvidenceRefreshFinding(
          id: id,
          severity: severity,
          message: message,
          packetId: packetId,
          scopeId: scopeId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase32J &&
        (result.sourceValidationStatus ==
                RefreshedPacketHardeningValidationStatus
                    .blockedByUnsafeRefresh ||
            result.unsafeCount > 0 ||
            result.records.any((record) => record.refreshStatus.isUnsafe))) {
      add(
        id: 'unsafeValidationMarkedSafeForRefresh',
        severity: InternalPacketEvidenceRefreshValidationSeverity.critical,
        message: 'unsafe validation cannot be used as safe refreshed evidence',
      );
    }

    for (final record in result.records) {
      if (record.isCorePacketRecord &&
          (record.refreshedSupportCaseIds.isEmpty ||
              record.activeSignalIds.isEmpty ||
              record.evidenceAreaIds.isEmpty ||
              record.bucketIds.isEmpty)) {
        add(
          id: 'corePacketMissingEvidenceMapping',
          severity: InternalPacketEvidenceRefreshValidationSeverity.blocker,
          message: '${record.packetId} lacks support or source mapping',
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      if (!_allowedPacketScopes.contains(record.scopeId) &&
          record.packetKind ==
              InternalPacketEvidenceHardeningTargetKind.packet) {
        add(
          id: 'nonAllowedScopeBecameCorePacket',
          severity: InternalPacketEvidenceRefreshValidationSeverity.critical,
          message: '${record.scopeId.wire} cannot become a core packet',
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      if (_warningLimitedScopes.contains(record.scopeId) &&
          (record.refreshStatus !=
                  InternalPacketEvidenceRefreshRecordStatus
                      .warningLimitedOnly ||
              record.packetKind !=
                  InternalPacketEvidenceHardeningTargetKind.warningScope)) {
        add(
          id: 'warningLimitedScopePromotedToCorePacket',
          severity: InternalPacketEvidenceRefreshValidationSeverity.critical,
          message: '${record.scopeId.wire} must remain warning-limited only',
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      if (record.scopeId ==
              InternalNonLabelPrototypeScopeId
                  .pvMultiPvSupportInternalPrototypeScope &&
          record.refreshStatus !=
              InternalPacketEvidenceRefreshRecordStatus.watchListed) {
        add(
          id: 'watchListedPvMultiPvPromotedWithoutProof',
          severity: InternalPacketEvidenceRefreshValidationSeverity.blocker,
          message: 'PV/MultiPV must stay watch-listed without new proof',
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      if (_blockedScopes.contains(record.scopeId) &&
          record.refreshStatus !=
              InternalPacketEvidenceRefreshRecordStatus.blockedCorrectly) {
        add(
          id: 'blockedScopeBecameActive',
          severity: InternalPacketEvidenceRefreshValidationSeverity.critical,
          message: '${record.scopeId.wire} must remain blocked',
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      if (_futureOnlyScopes.contains(record.scopeId) &&
          record.refreshStatus !=
              InternalPacketEvidenceRefreshRecordStatus.futureOnlyCorrectly) {
        add(
          id: 'futureOnlyScopeBecameActive',
          severity: InternalPacketEvidenceRefreshValidationSeverity.critical,
          message: '${record.scopeId.wire} must remain future-only',
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      if (record.scopeId ==
              InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope &&
          (record.quietScopeActive ||
              record.refreshStatus !=
                  InternalPacketEvidenceRefreshRecordStatus.blockedCorrectly)) {
        add(
          id: 'quietPreparatoryScopeActivated',
          severity: InternalPacketEvidenceRefreshValidationSeverity.critical,
          message: 'quiet/preparatory scope must remain excluded',
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      if (record.hasUnsafeOutput) {
        add(
          id: 'recordBoundaryPolicyViolation',
          severity: InternalPacketEvidenceRefreshValidationSeverity.critical,
          message: '${record.packetId} crossed a blocked output boundary',
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      for (final caseId in record.androidProofCaseIds) {
        if (!_capturedAndroidProofIds.contains(caseId) ||
            !provenAndroidIds.contains(caseId)) {
          add(
            id: 'unprovenAndroidProofClaim',
            severity: InternalPacketEvidenceRefreshValidationSeverity.critical,
            message: '${record.packetId} cited unproven Android proof',
            packetId: record.packetId,
            scopeId: record.scopeId,
            caseId: caseId,
          );
        }
        if (_phase32ECaseIds.contains(caseId)) {
          add(
            id: 'phase32ECaseClaimedCapturedProof',
            severity: InternalPacketEvidenceRefreshValidationSeverity.critical,
            message: 'Phase 32E case cannot be captured Android proof',
            packetId: record.packetId,
            scopeId: record.scopeId,
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
          severity: InternalPacketEvidenceRefreshValidationSeverity.critical,
          message: 'refresh cited unproven Android proof',
          caseId: caseId,
        );
      }
      if (_phase32ECaseIds.contains(caseId)) {
        add(
          id: 'phase32ECaseClaimedCapturedProof',
          severity: InternalPacketEvidenceRefreshValidationSeverity.critical,
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
        id: 'refreshBoundaryPolicyViolation',
        severity: InternalPacketEvidenceRefreshValidationSeverity.critical,
        message: 'refresh crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<InternalPacketEvidenceRefreshFinding> validateReportText(
    String reportText,
  ) {
    final findings = <InternalPacketEvidenceRefreshFinding>[];
    void reportError(String id, String message) {
      findings.add(
        InternalPacketEvidenceRefreshFinding(
          id: id,
          severity: InternalPacketEvidenceRefreshValidationSeverity.critical,
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

List<InternalPacketEvidenceRefreshRecord> _recordsFrom({
  required RefreshedInternalPacketHardeningPlanResult refreshResult,
  required RefreshedPacketHardeningValidationResult validationResult,
  required InternalPacketStabilityPrototypeResult stabilityResult,
}) {
  final stabilityByScope =
      <InternalNonLabelPrototypeScopeId, InternalPacketStabilityRecord>{
        for (final record in stabilityResult.records) record.scopeId: record,
      };
  final validationByScope =
      <
        InternalNonLabelPrototypeScopeId,
        RefreshedPacketHardeningTargetValidationSummary
      >{
        for (final target in validationResult.targetSummaries)
          target.scopeId: target,
      };
  final records = <InternalPacketEvidenceRefreshRecord>[];
  for (final target in refreshResult.targets) {
    final stability = stabilityByScope[target.scopeId];
    final validationTarget = validationByScope[target.scopeId];
    final status = _recordStatusFor(target);
    final supportCaseIds = _sortedStrings(
      target.supportCaseIds.isEmpty
          ? stability?.supportCaseIds ?? const <String>[]
          : target.supportCaseIds,
    );
    final activeSignalIds = stability?.activeSignalIds ?? const [];
    final evidenceAreaIds = stability?.evidenceAreaIds ?? const [];
    final bucketIds = stability?.bucketIds ?? const [];
    final safeForInternalUse =
        !status.isUnsafe &&
        !target.hasUnsafeOutput &&
        !_coreMappingMissing(
          target.scopeId,
          supportCaseIds,
          activeSignalIds,
          evidenceAreaIds,
          bucketIds,
        );
    records.add(
      InternalPacketEvidenceRefreshRecord(
        packetId:
            target.packetId ??
            stability?.packetId ??
            (target.targetId.isEmpty
                ? '${target.scopeId.wire}-evidence-refresh'
                : target.targetId),
        scopeId: target.scopeId,
        packetKind: target.targetKind,
        refreshStatus: status,
        previousStabilityStatus:
            stability?.stabilityStatus ?? InternalPacketStabilityStatus.invalid,
        refreshedSupportCaseIds: supportCaseIds,
        newlyAddedSupportCaseIds: _sortedStrings(target.improvedByCaseIds),
        androidProofCaseIds: _sortedStrings(target.androidProofCaseIds),
        activeSignalIds: activeSignalIds,
        evidenceAreaIds: evidenceAreaIds,
        bucketIds: bucketIds,
        qualitativeConfidence:
            stability?.qualitativeConfidence ?? _confidenceFor(status),
        refreshedEvidenceReason: target.reason,
        proofLimitReason: _proofLimitReasonFor(target, stability, status),
        warningReason: _warningReasonFor(target, validationTarget, stability),
        coverageGapIds: _sortedStrings(<String>[
          ...target.remainingCoverageGaps,
          ...?stability?.coverageGapIds,
        ]),
        futurePrerequisites: _futurePrerequisitesFor(target, stability, status),
        blockedBoundaryIds: _blockedBoundaryIdsFor(target, stability, status),
        safeForInternalUse: safeForInternalUse,
        recommendation: _recordRecommendationFor(status),
        isProductOutput: target.isProductOutput,
        isClassifierLabel: target.isClassifierLabel,
        isOfficialMetric: target.isOfficialMetric,
        hasNumericValue: target.hasNumericValue,
        ordersMoves: target.ordersMoves,
        quietScopeActive: target.quietScopeActive,
        cpLossComputationImplemented: target.cpLossComputationImplemented,
        winProbabilityComputationImplemented:
            target.winProbabilityComputationImplemented,
        emittedOutputNames: target.emittedOutputNames,
      ),
    );
  }
  return List<InternalPacketEvidenceRefreshRecord>.unmodifiable(
    records..sort((a, b) => a.scopeId.index.compareTo(b.scopeId.index)),
  );
}

InternalPacketEvidenceRefreshResult _resultFromRecords({
  required RefreshedPacketHardeningValidationResult validationResult,
  required RefreshedInternalPacketHardeningPlanResult refreshResult,
  required TargetedGoldenCoverageImpactReviewResult impactResult,
  required InternalPacketStabilityPrototypeResult stabilityResult,
  required List<InternalPacketEvidenceRefreshRecord> records,
  required List<InternalPacketEvidenceRefreshFinding> validationFindings,
}) {
  final recordUnsafeCount = records
      .where(
        (record) => record.refreshStatus.isUnsafe || record.hasUnsafeOutput,
      )
      .length;
  final unsafeCount = validationResult.unsafeCount + recordUnsafeCount;
  final criticalCount =
      validationResult.criticalCount +
      validationFindings.where((finding) => finding.isCritical).length;
  final base = InternalPacketEvidenceRefreshResult(
    refreshStatus: InternalPacketEvidenceRefreshStatus.invalid,
    sourceValidationStatus: validationResult.validationStatus,
    sourceRefreshStatus: refreshResult.refreshedStatus,
    sourceImpactStatus: impactResult.impactStatus,
    sourceStabilityStatus: stabilityResult.prototypeStatus,
    records: records,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...validationResult.warnings,
      ...refreshResult.warnings,
      if (records.any(
        (record) =>
            record.refreshStatus ==
            InternalPacketEvidenceRefreshRecordStatus.warningLimitedOnly,
      ))
        'warning-limited refresh records remain outside core packets',
      if (records.any(
        (record) =>
            record.refreshStatus ==
            InternalPacketEvidenceRefreshRecordStatus.watchListed,
      ))
        'PV/MultiPV refresh remains watch-listed',
    ]),
    failures: _sortedStrings(<String>[
      ...validationResult.failures,
      ...refreshResult.failures,
      ...validationFindings.map((finding) => finding.message),
    ]),
    totalRecords: records.length,
    refreshedPacketCount: records
        .where((record) => record.isCorePacketRecord)
        .length,
    improvedSupportCount: records
        .where(
          (record) =>
              record.refreshStatus ==
              InternalPacketEvidenceRefreshRecordStatus.improvedSupport,
        )
        .length,
    preservedStableCount: records
        .where(
          (record) =>
              record.refreshStatus ==
              InternalPacketEvidenceRefreshRecordStatus.preservedStable,
        )
        .length,
    watchListedCount: records
        .where(
          (record) =>
              record.refreshStatus ==
              InternalPacketEvidenceRefreshRecordStatus.watchListed,
        )
        .length,
    proofLimitedCount: records
        .where(
          (record) =>
              record.refreshStatus ==
              InternalPacketEvidenceRefreshRecordStatus.proofLimited,
        )
        .length,
    warningLimitedCount: records
        .where(
          (record) =>
              record.refreshStatus ==
              InternalPacketEvidenceRefreshRecordStatus.warningLimitedOnly,
        )
        .length,
    blockedCount: records
        .where(
          (record) =>
              record.refreshStatus ==
              InternalPacketEvidenceRefreshRecordStatus.blockedCorrectly,
        )
        .length,
    futureOnlyCount: records
        .where(
          (record) =>
              record.refreshStatus ==
              InternalPacketEvidenceRefreshRecordStatus.futureOnlyCorrectly,
        )
        .length,
    unsafeCount: unsafeCount,
    criticalCount: criticalCount,
    ownerProofQueueCount: validationResult.ownerProofQueueCount,
    supportCaseIds: _sortedStrings(
      records.expand((record) => record.refreshedSupportCaseIds),
    ),
    newlyAddedSupportCaseIds: _sortedStrings(
      records.expand((record) => record.newlyAddedSupportCaseIds),
    ),
    androidProofCaseIds: _sortedStrings(validationResult.androidProofCaseIds),
    coverageGapIds: _sortedStrings(
      records.expand((record) => record.coverageGapIds),
    ),
    safeForPhase32J: false,
    phase32JRecommendation: InternalPacketEvidenceRefreshPhase32JRecommendation
        .addMoreGoldenCoverageFirst,
    productLabelsEmitted:
        validationResult.productLabelsEmitted ||
        refreshResult.productLabelsEmitted,
    advancedLabelsEmitted:
        validationResult.advancedLabelsEmitted ||
        refreshResult.advancedLabelsEmitted,
    classifierLabelsEmitted:
        validationResult.classifierLabelsEmitted ||
        refreshResult.classifierLabelsEmitted,
    finalMoveLabelsEmitted:
        validationResult.finalMoveLabelsEmitted ||
        refreshResult.finalMoveLabelsEmitted,
    officialMetricsAllowed:
        validationResult.officialMetricsAllowed ||
        refreshResult.officialMetricsAllowed,
    cpLossComputationImplemented:
        validationResult.cpLossComputationImplemented ||
        refreshResult.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        validationResult.winProbabilityComputationImplemented ||
        refreshResult.winProbabilityComputationImplemented,
    numericMoveValuesComputed:
        validationResult.numericMoveValuesComputed ||
        refreshResult.numericMoveValuesComputed,
    moveOrderingComputed:
        validationResult.moveOrderingComputed ||
        refreshResult.moveOrderingComputed,
    quietPreparatoryScopeActivated:
        validationResult.quietPreparatoryScopeActivated ||
        refreshResult.quietPreparatoryScopeActivated,
    directEngineAccessUsed:
        validationResult.directEngineAccessUsed ||
        refreshResult.directEngineAccessUsed,
    uiOutputUsed: validationResult.uiOutputUsed || refreshResult.uiOutputUsed,
    backendOutputUsed:
        validationResult.backendOutputUsed || refreshResult.backendOutputUsed,
    persistenceUsed:
        validationResult.persistenceUsed || refreshResult.persistenceUsed,
    emittedOutputFamilies: _sortedStrings(<String>[
      ...validationResult.emittedOutputFamilies,
      ...refreshResult.emittedOutputFamilies,
    ]),
  );
  final status = _refreshStatusFor(base, validationResult: validationResult);
  final safeForPhase32J =
      (status == InternalPacketEvidenceRefreshStatus.refreshedWithWarnings ||
          status == InternalPacketEvidenceRefreshStatus.refreshedClean) &&
      validationResult.safeForPhase32I &&
      !validationResult.isStrictlyBlocked &&
      !validationResult.hasUnsafeValidationPolicyViolation &&
      unsafeCount == 0 &&
      criticalCount == 0 &&
      !validationFindings.any((finding) => finding.blocksStrict) &&
      records.every((record) => record.safeForInternalUse);
  return base.copyWith(
    refreshStatus: status,
    safeForPhase32J: safeForPhase32J,
    phase32JRecommendation: _phase32JRecommendationFor(
      status: status,
      safeForPhase32J: safeForPhase32J,
      ownerProofQueueCount: validationResult.ownerProofQueueCount,
      warningCount:
          base.warningLimitedCount +
          base.watchListedCount +
          base.proofLimitedCount,
    ),
  );
}

InternalPacketEvidenceRefreshStatus _refreshStatusFor(
  InternalPacketEvidenceRefreshResult result, {
  required RefreshedPacketHardeningValidationResult validationResult,
}) {
  if (validationResult.hasUnsafeValidationPolicyViolation ||
      validationResult.validationStatus ==
          RefreshedPacketHardeningValidationStatus.blockedByUnsafeRefresh ||
      result.unsafeCount > 0 ||
      result.criticalCount > 0 ||
      result.validationFindings.any((finding) => finding.isCritical)) {
    return InternalPacketEvidenceRefreshStatus.blockedByUnsafeValidation;
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
    return InternalPacketEvidenceRefreshStatus.blockedByPolicyBoundary;
  }
  if (!validationResult.safeForPhase32I ||
      validationResult.isStrictlyBlocked ||
      result.validationFindings.any((finding) => finding.blocksStrict)) {
    return InternalPacketEvidenceRefreshStatus.skippedByValidationFailure;
  }
  if (result.records.isEmpty) {
    return InternalPacketEvidenceRefreshStatus.invalid;
  }
  if (result.warningLimitedCount > 0 ||
      result.watchListedCount > 0 ||
      result.proofLimitedCount > 0 ||
      result.coverageGapIds.isNotEmpty) {
    return InternalPacketEvidenceRefreshStatus.refreshedWithWarnings;
  }
  return InternalPacketEvidenceRefreshStatus.refreshedClean;
}

InternalPacketEvidenceRefreshPhase32JRecommendation _phase32JRecommendationFor({
  required InternalPacketEvidenceRefreshStatus status,
  required bool safeForPhase32J,
  required int ownerProofQueueCount,
  required int warningCount,
}) {
  if (status == InternalPacketEvidenceRefreshStatus.blockedByUnsafeValidation ||
      status == InternalPacketEvidenceRefreshStatus.blockedByPolicyBoundary) {
    return InternalPacketEvidenceRefreshPhase32JRecommendation
        .blockedByUnsafeRefresh;
  }
  if (ownerProofQueueCount > 0) {
    return InternalPacketEvidenceRefreshPhase32JRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase32J) {
    return InternalPacketEvidenceRefreshPhase32JRecommendation
        .addMoreGoldenCoverageFirst;
  }
  if (warningCount > 0) {
    return InternalPacketEvidenceRefreshPhase32JRecommendation
        .reviewRefreshedPacketEvidence;
  }
  return InternalPacketEvidenceRefreshPhase32JRecommendation
      .proceedToInternalEvidenceRefreshReview;
}

InternalPacketEvidenceRefreshRecordStatus _recordStatusFor(
  RefreshedInternalPacketHardeningTarget target,
) {
  if (target.hasUnsafeOutput ||
      target.refreshedAction ==
          RefreshedInternalPacketHardeningActionType.blockUnsafeScope ||
      target.refreshedAction ==
          RefreshedInternalPacketHardeningActionType.investigateUnsafeImpact) {
    return InternalPacketEvidenceRefreshRecordStatus.unsafe;
  }
  if (target.scopeId ==
      InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope) {
    return InternalPacketEvidenceRefreshRecordStatus.watchListed;
  }
  return switch (target.targetKind) {
    InternalPacketEvidenceHardeningTargetKind.androidProofScope =>
      InternalPacketEvidenceRefreshRecordStatus.proofLimited,
    InternalPacketEvidenceHardeningTargetKind.warningScope =>
      InternalPacketEvidenceRefreshRecordStatus.warningLimitedOnly,
    InternalPacketEvidenceHardeningTargetKind.blockedScope =>
      InternalPacketEvidenceRefreshRecordStatus.blockedCorrectly,
    InternalPacketEvidenceHardeningTargetKind.futureOnlyScope =>
      InternalPacketEvidenceRefreshRecordStatus.futureOnlyCorrectly,
    InternalPacketEvidenceHardeningTargetKind.packet =>
      target.improvedByCaseIds.isNotEmpty &&
              target.refreshedAction ==
                  RefreshedInternalPacketHardeningActionType
                      .preserveImprovedPacket
          ? InternalPacketEvidenceRefreshRecordStatus.improvedSupport
          : InternalPacketEvidenceRefreshRecordStatus.preservedStable,
  };
}

InternalPacketEvidenceRefreshRecommendation _recordRecommendationFor(
  InternalPacketEvidenceRefreshRecordStatus status,
) {
  return switch (status) {
    InternalPacketEvidenceRefreshRecordStatus.preservedStable =>
      InternalPacketEvidenceRefreshRecommendation.preserveStableEvidence,
    InternalPacketEvidenceRefreshRecordStatus.improvedSupport =>
      InternalPacketEvidenceRefreshRecommendation.reviewImprovedSupport,
    InternalPacketEvidenceRefreshRecordStatus.watchListed =>
      InternalPacketEvidenceRefreshRecommendation.keepWatchListed,
    InternalPacketEvidenceRefreshRecordStatus.proofLimited =>
      InternalPacketEvidenceRefreshRecommendation.keepProofLimited,
    InternalPacketEvidenceRefreshRecordStatus.warningLimitedOnly =>
      InternalPacketEvidenceRefreshRecommendation.keepWarningLimitedOutsideCore,
    InternalPacketEvidenceRefreshRecordStatus.blockedCorrectly =>
      InternalPacketEvidenceRefreshRecommendation.keepBlockedByPolicy,
    InternalPacketEvidenceRefreshRecordStatus.futureOnlyCorrectly =>
      InternalPacketEvidenceRefreshRecommendation.keepFutureOnly,
    InternalPacketEvidenceRefreshRecordStatus.unsafe ||
    InternalPacketEvidenceRefreshRecordStatus.invalid =>
      InternalPacketEvidenceRefreshRecommendation.investigateUnsafeRefresh,
  };
}

InternalNonLabelSignalConfidence _confidenceFor(
  InternalPacketEvidenceRefreshRecordStatus status,
) {
  return switch (status) {
    InternalPacketEvidenceRefreshRecordStatus.blockedCorrectly =>
      InternalNonLabelSignalConfidence.blocked,
    InternalPacketEvidenceRefreshRecordStatus.futureOnlyCorrectly =>
      InternalNonLabelSignalConfidence.futureOnly,
    InternalPacketEvidenceRefreshRecordStatus.warningLimitedOnly =>
      InternalNonLabelSignalConfidence.warningOnly,
    _ => InternalNonLabelSignalConfidence.lowConfidence,
  };
}

String _proofLimitReasonFor(
  RefreshedInternalPacketHardeningTarget target,
  InternalPacketStabilityRecord? stability,
  InternalPacketEvidenceRefreshRecordStatus status,
) {
  if (status == InternalPacketEvidenceRefreshRecordStatus.proofLimited) {
    return 'limited to captured Android proof IDs only';
  }
  if (status == InternalPacketEvidenceRefreshRecordStatus.watchListed) {
    return 'PV/MultiPV remains boundary-only without new captured proof';
  }
  return stability?.proofLimitReason ?? '';
}

String _warningReasonFor(
  RefreshedInternalPacketHardeningTarget target,
  RefreshedPacketHardeningTargetValidationSummary? validationTarget,
  InternalPacketStabilityRecord? stability,
) {
  if (validationTarget?.failureReason.isNotEmpty ?? false) {
    return validationTarget!.failureReason;
  }
  if (target.stillWarningLimited) {
    return 'warning-limited target remains outside core packets';
  }
  return stability?.warningReason ?? '';
}

List<String> _futurePrerequisitesFor(
  RefreshedInternalPacketHardeningTarget target,
  InternalPacketStabilityRecord? stability,
  InternalPacketEvidenceRefreshRecordStatus status,
) {
  return _sortedStrings(<String>[
    ...?stability?.futurePrerequisites,
    if (status == InternalPacketEvidenceRefreshRecordStatus.futureOnlyCorrectly)
      target.nextStep,
  ]);
}

List<String> _blockedBoundaryIdsFor(
  RefreshedInternalPacketHardeningTarget target,
  InternalPacketStabilityRecord? stability,
  InternalPacketEvidenceRefreshRecordStatus status,
) {
  return _sortedStrings(<String>[
    ...?stability?.blockedBoundaryIds,
    if (status == InternalPacketEvidenceRefreshRecordStatus.blockedCorrectly)
      target.scopeId.wire,
    if (target.stillBlocked) target.reason,
  ]);
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

String _packetIds(Iterable<InternalPacketEvidenceRefreshRecord> records) {
  final ids = records.map((record) => record.packetId).toSet().toList()..sort();
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
  InternalPacketEvidenceRefreshFinding a,
  InternalPacketEvidenceRefreshFinding b,
) {
  final severityCompare = b.severity.index.compareTo(a.severity.index);
  if (severityCompare != 0) return severityCompare;
  final idCompare = a.id.compareTo(b.id);
  if (idCompare != 0) return idCompare;
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

/// Developer-only readiness gate for reviewed refreshed packet evidence.
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
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_refresh_review.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_review_aggregation_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_stability_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/narrow_internal_non_label_analysis_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_internal_packet_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_hardening_validation.dart';
import 'package:apex_chess/features/pgn_review/application/targeted_golden_coverage_impact_review.dart';

const refreshedPacketEvidenceReadinessGateReportVersion =
    'refreshed-packet-evidence-readiness-gate-v1';

enum RefreshedPacketEvidenceReadinessStatus {
  readyForNarrowInternalEvidenceSummary(
    'readyForNarrowInternalEvidenceSummary',
  ),
  readyWithWarnings('readyWithWarnings'),
  blockedByUnsafeReview('blockedByUnsafeReview'),
  blockedByInvalidRecord('blockedByInvalidRecord'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  blockedByUnprovenAndroidProof('blockedByUnprovenAndroidProof'),
  invalid('invalid');

  const RefreshedPacketEvidenceReadinessStatus(this.wire);

  final String wire;
}

enum RefreshedPacketEvidenceReadinessGroup {
  preservedStableEvidenceGroup('preservedStableEvidenceGroup'),
  improvedSupportEvidenceGroup('improvedSupportEvidenceGroup'),
  watchListedEvidenceGroup('watchListedEvidenceGroup'),
  proofLimitedEvidenceGroup('proofLimitedEvidenceGroup'),
  warningLimitedEvidenceGroup('warningLimitedEvidenceGroup'),
  quietPreparatoryBlockedGroup('quietPreparatoryBlockedGroup'),
  productLabelBlockedGroup('productLabelBlockedGroup'),
  advancedLabelBlockedGroup('advancedLabelBlockedGroup'),
  officialMetricBlockedGroup('officialMetricBlockedGroup'),
  cpLossFutureOnlyGroup('cpLossFutureOnlyGroup'),
  winProbabilityFutureOnlyGroup('winProbabilityFutureOnlyGroup'),
  uiBackendPersistenceBlockedGroup('uiBackendPersistenceBlockedGroup'),
  directEngineAccessBlockedGroup('directEngineAccessBlockedGroup');

  const RefreshedPacketEvidenceReadinessGroup(this.wire);

  final String wire;

  bool get isAllowed =>
      this ==
          RefreshedPacketEvidenceReadinessGroup.preservedStableEvidenceGroup ||
      this ==
          RefreshedPacketEvidenceReadinessGroup.improvedSupportEvidenceGroup;

  bool get isConstrained =>
      this == RefreshedPacketEvidenceReadinessGroup.watchListedEvidenceGroup ||
      this == RefreshedPacketEvidenceReadinessGroup.proofLimitedEvidenceGroup ||
      this == RefreshedPacketEvidenceReadinessGroup.warningLimitedEvidenceGroup;

  bool get isFutureOnly =>
      this == RefreshedPacketEvidenceReadinessGroup.cpLossFutureOnlyGroup ||
      this ==
          RefreshedPacketEvidenceReadinessGroup.winProbabilityFutureOnlyGroup;

  bool get isBlocked => !isAllowed && !isConstrained && !isFutureOnly;
}

enum RefreshedPacketEvidenceReadinessRecordStatus {
  allowed('allowed'),
  constrained('constrained'),
  blocked('blocked'),
  futureOnly('futureOnly'),
  unsafe('unsafe'),
  invalid('invalid');

  const RefreshedPacketEvidenceReadinessRecordStatus(this.wire);

  final String wire;

  bool get isUnsafe =>
      this == RefreshedPacketEvidenceReadinessRecordStatus.unsafe ||
      this == RefreshedPacketEvidenceReadinessRecordStatus.invalid;
}

enum RefreshedPacketEvidenceReadinessRecommendation {
  allowInNarrowInternalSummary('allowInNarrowInternalSummary'),
  allowAsImprovedSupport('allowAsImprovedSupport'),
  keepWatchListed('keepWatchListed'),
  keepProofLimited('keepProofLimited'),
  keepWarningLimitedOnly('keepWarningLimitedOnly'),
  keepBlocked('keepBlocked'),
  keepFutureOnly('keepFutureOnly'),
  blockUnsafeRecord('blockUnsafeRecord');

  const RefreshedPacketEvidenceReadinessRecommendation(this.wire);

  final String wire;
}

enum RefreshedPacketEvidenceReadinessPhase32LRecommendation {
  proceedToInternalEvidenceSummaryLayer(
    'proceedToInternalEvidenceSummaryLayer',
  ),
  proceedToInternalEvidenceAdapterDesign(
    'proceedToInternalEvidenceAdapterDesign',
  ),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeReadiness('blockedByUnsafeReadiness');

  const RefreshedPacketEvidenceReadinessPhase32LRecommendation(this.wire);

  final String wire;
}

enum RefreshedPacketEvidenceReadinessValidationSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const RefreshedPacketEvidenceReadinessValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == RefreshedPacketEvidenceReadinessValidationSeverity.blocker ||
      this == RefreshedPacketEvidenceReadinessValidationSeverity.critical;
}

enum RefreshedPacketEvidenceReadinessGateReportFormat {
  markdown('markdown'),
  json('json');

  const RefreshedPacketEvidenceReadinessGateReportFormat(this.wire);

  final String wire;
}

class RefreshedPacketEvidenceReadinessGateRequest {
  const RefreshedPacketEvidenceReadinessGateRequest({
    this.reviewResult,
    this.refreshResult,
    this.validationResult,
    this.refreshedPlanResult,
    this.impactReviewResult,
    this.hardeningPlanResult,
    this.stabilityResult,
    this.matrixResult,
    this.prototypeResult,
    this.review = const InternalPacketEvidenceRefreshReview(),
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

  const RefreshedPacketEvidenceReadinessGateRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final InternalPacketEvidenceRefreshReviewResult? reviewResult;
  final InternalPacketEvidenceRefreshResult? refreshResult;
  final RefreshedPacketHardeningValidationResult? validationResult;
  final RefreshedInternalPacketHardeningPlanResult? refreshedPlanResult;
  final TargetedGoldenCoverageImpactReviewResult? impactReviewResult;
  final InternalPacketEvidenceHardeningPlanResult? hardeningPlanResult;
  final InternalPacketStabilityPrototypeResult? stabilityResult;
  final InternalPacketReviewAggregationMatrixResult? matrixResult;
  final NarrowInternalNonLabelAnalysisPrototypeResult? prototypeResult;
  final InternalPacketEvidenceRefreshReview review;
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

class RefreshedPacketEvidenceReadinessRecord {
  const RefreshedPacketEvidenceReadinessRecord({
    required this.readinessRecordId,
    required this.sourceReviewRecordId,
    required this.packetId,
    required this.scopeId,
    required this.readinessGroup,
    required this.readinessStatus,
    required this.sourceReviewStatus,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.activeSignalIds,
    required this.evidenceAreaIds,
    required this.bucketIds,
    required this.warningReason,
    required this.proofLimitReason,
    required this.futurePrerequisite,
    required this.blockedBoundaryIds,
    required this.coverageGapIds,
    required this.allowedForNextInternalLayer,
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

  final String readinessRecordId;
  final String sourceReviewRecordId;
  final String packetId;
  final InternalNonLabelPrototypeScopeId scopeId;
  final RefreshedPacketEvidenceReadinessGroup readinessGroup;
  final RefreshedPacketEvidenceReadinessRecordStatus readinessStatus;
  final InternalPacketEvidenceRefreshReviewRowStatus sourceReviewStatus;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<InternalNonLabelSignalId> activeSignalIds;
  final List<InternalEvidenceAreaId> evidenceAreaIds;
  final List<InternalEvidenceBucketId> bucketIds;
  final String warningReason;
  final String proofLimitReason;
  final String futurePrerequisite;
  final List<String> blockedBoundaryIds;
  final List<String> coverageGapIds;
  final bool allowedForNextInternalLayer;
  final RefreshedPacketEvidenceReadinessRecommendation recommendation;
  final bool isProductOutput;
  final bool isClassifierLabel;
  final bool isOfficialMetric;
  final bool hasNumericValue;
  final bool ordersMoves;
  final bool quietScopeActive;
  final bool cpLossComputationImplemented;
  final bool winProbabilityComputationImplemented;
  final List<String> emittedOutputNames;

  bool get isAllowedRecord =>
      readinessStatus == RefreshedPacketEvidenceReadinessRecordStatus.allowed &&
      allowedForNextInternalLayer;

  bool get isConstrainedRecord =>
      readinessGroup.isConstrained ||
      readinessStatus ==
          RefreshedPacketEvidenceReadinessRecordStatus.constrained;

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

  RefreshedPacketEvidenceReadinessRecord copyWith({
    String? readinessRecordId,
    String? sourceReviewRecordId,
    String? packetId,
    InternalNonLabelPrototypeScopeId? scopeId,
    RefreshedPacketEvidenceReadinessGroup? readinessGroup,
    RefreshedPacketEvidenceReadinessRecordStatus? readinessStatus,
    InternalPacketEvidenceRefreshReviewRowStatus? sourceReviewStatus,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<InternalNonLabelSignalId>? activeSignalIds,
    List<InternalEvidenceAreaId>? evidenceAreaIds,
    List<InternalEvidenceBucketId>? bucketIds,
    String? warningReason,
    String? proofLimitReason,
    String? futurePrerequisite,
    List<String>? blockedBoundaryIds,
    List<String>? coverageGapIds,
    bool? allowedForNextInternalLayer,
    RefreshedPacketEvidenceReadinessRecommendation? recommendation,
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
    return RefreshedPacketEvidenceReadinessRecord(
      readinessRecordId: readinessRecordId ?? this.readinessRecordId,
      sourceReviewRecordId: sourceReviewRecordId ?? this.sourceReviewRecordId,
      packetId: packetId ?? this.packetId,
      scopeId: scopeId ?? this.scopeId,
      readinessGroup: readinessGroup ?? this.readinessGroup,
      readinessStatus: readinessStatus ?? this.readinessStatus,
      sourceReviewStatus: sourceReviewStatus ?? this.sourceReviewStatus,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      activeSignalIds: activeSignalIds ?? this.activeSignalIds,
      evidenceAreaIds: evidenceAreaIds ?? this.evidenceAreaIds,
      bucketIds: bucketIds ?? this.bucketIds,
      warningReason: warningReason ?? this.warningReason,
      proofLimitReason: proofLimitReason ?? this.proofLimitReason,
      futurePrerequisite: futurePrerequisite ?? this.futurePrerequisite,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      coverageGapIds: coverageGapIds ?? this.coverageGapIds,
      allowedForNextInternalLayer:
          allowedForNextInternalLayer ?? this.allowedForNextInternalLayer,
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
      'readinessRecordId': readinessRecordId,
      'sourceReviewRecordId': sourceReviewRecordId,
      'packetId': packetId,
      'scopeId': scopeId.wire,
      'readinessGroup': readinessGroup.wire,
      'readinessStatus': readinessStatus.wire,
      'sourceReviewStatus': sourceReviewStatus.wire,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'activeSignalIds': activeSignalIds.map((id) => id.wire).toList(),
      'evidenceAreaIds': evidenceAreaIds.map((id) => id.wire).toList(),
      'bucketIds': bucketIds.map((id) => id.wire).toList(),
      'warningReason': warningReason,
      'proofLimitReason': proofLimitReason,
      'futurePrerequisite': futurePrerequisite,
      'blockedBoundaryIds': blockedBoundaryIds,
      'coverageGapIds': coverageGapIds,
      'allowedForNextInternalLayer': allowedForNextInternalLayer,
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

class RefreshedPacketEvidenceReadinessFinding {
  const RefreshedPacketEvidenceReadinessFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.recordId,
    this.packetId,
    this.scopeId,
    this.caseId,
  });

  final String id;
  final RefreshedPacketEvidenceReadinessValidationSeverity severity;
  final String message;
  final String? recordId;
  final String? packetId;
  final InternalNonLabelPrototypeScopeId? scopeId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical =>
      severity == RefreshedPacketEvidenceReadinessValidationSeverity.critical;

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

class RefreshedPacketEvidenceReadinessGateResult {
  const RefreshedPacketEvidenceReadinessGateResult({
    required this.readinessStatus,
    required this.sourceReviewStatus,
    required this.sourceRefreshStatus,
    required this.sourceValidationStatus,
    required this.sourcePlanStatus,
    required this.records,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalRecords,
    required this.allowedRecordCount,
    required this.constrainedRecordCount,
    required this.blockedRecordCount,
    required this.futureOnlyRecordCount,
    required this.unsafeCount,
    required this.criticalCount,
    required this.ownerProofQueueCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.coverageGapIds,
    required this.safeForPhase32L,
    required this.phase32LRecommendation,
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

  final RefreshedPacketEvidenceReadinessStatus readinessStatus;
  final InternalPacketEvidenceRefreshReviewStatus sourceReviewStatus;
  final InternalPacketEvidenceRefreshStatus sourceRefreshStatus;
  final RefreshedPacketHardeningValidationStatus sourceValidationStatus;
  final RefreshedInternalPacketHardeningStatus sourcePlanStatus;
  final List<RefreshedPacketEvidenceReadinessRecord> records;
  final List<RefreshedPacketEvidenceReadinessFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalRecords;
  final int allowedRecordCount;
  final int constrainedRecordCount;
  final int blockedRecordCount;
  final int futureOnlyRecordCount;
  final int unsafeCount;
  final int criticalCount;
  final int ownerProofQueueCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> coverageGapIds;
  final bool safeForPhase32L;
  final RefreshedPacketEvidenceReadinessPhase32LRecommendation
  phase32LRecommendation;
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
      readinessStatus ==
          RefreshedPacketEvidenceReadinessStatus.blockedByUnsafeReview ||
      readinessStatus ==
          RefreshedPacketEvidenceReadinessStatus.blockedByInvalidRecord ||
      readinessStatus ==
          RefreshedPacketEvidenceReadinessStatus.blockedByPolicyBoundary ||
      readinessStatus ==
          RefreshedPacketEvidenceReadinessStatus
              .blockedByUnprovenAndroidProof ||
      readinessStatus == RefreshedPacketEvidenceReadinessStatus.invalid ||
      !safeForPhase32L ||
      unsafeCount > 0 ||
      criticalCount > 0 ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeReadinessPolicyViolation {
    return unsafeCount > 0 ||
        criticalCount > 0 ||
        validationFindings.any((finding) => finding.isCritical) ||
        records.any(
          (record) => record.readinessStatus.isUnsafe || record.hasUnsafeOutput,
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

  RefreshedPacketEvidenceReadinessRecord record(
    InternalNonLabelPrototypeScopeId scopeId,
  ) {
    return records.singleWhere((record) => record.scopeId == scopeId);
  }

  List<RefreshedPacketEvidenceReadinessRecord> get allowedRecords => records
      .where((record) => record.readinessGroup.isAllowed)
      .toList(growable: false);

  List<RefreshedPacketEvidenceReadinessRecord> get constrainedRecords => records
      .where((record) => record.readinessGroup.isConstrained)
      .toList(growable: false);

  List<RefreshedPacketEvidenceReadinessRecord> get blockedOrFutureRecords =>
      records
          .where(
            (record) =>
                record.readinessGroup.isBlocked ||
                record.readinessGroup.isFutureOnly,
          )
          .toList(growable: false);

  RefreshedPacketEvidenceReadinessGateResult copyWith({
    RefreshedPacketEvidenceReadinessStatus? readinessStatus,
    InternalPacketEvidenceRefreshReviewStatus? sourceReviewStatus,
    InternalPacketEvidenceRefreshStatus? sourceRefreshStatus,
    RefreshedPacketHardeningValidationStatus? sourceValidationStatus,
    RefreshedInternalPacketHardeningStatus? sourcePlanStatus,
    List<RefreshedPacketEvidenceReadinessRecord>? records,
    List<RefreshedPacketEvidenceReadinessFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalRecords,
    int? allowedRecordCount,
    int? constrainedRecordCount,
    int? blockedRecordCount,
    int? futureOnlyRecordCount,
    int? unsafeCount,
    int? criticalCount,
    int? ownerProofQueueCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? coverageGapIds,
    bool? safeForPhase32L,
    RefreshedPacketEvidenceReadinessPhase32LRecommendation?
    phase32LRecommendation,
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
    return RefreshedPacketEvidenceReadinessGateResult(
      readinessStatus: readinessStatus ?? this.readinessStatus,
      sourceReviewStatus: sourceReviewStatus ?? this.sourceReviewStatus,
      sourceRefreshStatus: sourceRefreshStatus ?? this.sourceRefreshStatus,
      sourceValidationStatus:
          sourceValidationStatus ?? this.sourceValidationStatus,
      sourcePlanStatus: sourcePlanStatus ?? this.sourcePlanStatus,
      records: records ?? this.records,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalRecords: totalRecords ?? this.totalRecords,
      allowedRecordCount: allowedRecordCount ?? this.allowedRecordCount,
      constrainedRecordCount:
          constrainedRecordCount ?? this.constrainedRecordCount,
      blockedRecordCount: blockedRecordCount ?? this.blockedRecordCount,
      futureOnlyRecordCount:
          futureOnlyRecordCount ?? this.futureOnlyRecordCount,
      unsafeCount: unsafeCount ?? this.unsafeCount,
      criticalCount: criticalCount ?? this.criticalCount,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      coverageGapIds: coverageGapIds ?? this.coverageGapIds,
      safeForPhase32L: safeForPhase32L ?? this.safeForPhase32L,
      phase32LRecommendation:
          phase32LRecommendation ?? this.phase32LRecommendation,
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
      ..writeln('# Refreshed Packet Evidence Readiness Gate')
      ..writeln()
      ..writeln('- version: $refreshedPacketEvidenceReadinessGateReportVersion')
      ..writeln('- readiness status: ${readinessStatus.wire}')
      ..writeln('- source review status: ${sourceReviewStatus.wire}')
      ..writeln('- source refresh status: ${sourceRefreshStatus.wire}')
      ..writeln('- source validation status: ${sourceValidationStatus.wire}')
      ..writeln('- source plan status: ${sourcePlanStatus.wire}')
      ..writeln('- total records: $totalRecords')
      ..writeln('- allowed record count: $allowedRecordCount')
      ..writeln('- constrained record count: $constrainedRecordCount')
      ..writeln('- blocked record count: $blockedRecordCount')
      ..writeln('- future-only record count: $futureOnlyRecordCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- safe for Phase 32L: $safeForPhase32L')
      ..writeln('- Phase 32L recommendation: ${phase32LRecommendation.wire}')
      ..writeln('- classifier output emitted: $classifierLabelsEmitted')
      ..writeln('- numeric value output emitted: $numericMoveValuesComputed')
      ..writeln('- move ordering output emitted: $moveOrderingComputed')
      ..writeln()
      ..writeln('## Readiness Policy')
      ..writeln(
        '- this gate consumes the Phase 32J refreshed evidence review result only',
      )
      ..writeln(
        '- preserved stable and improved support records may proceed to a narrow internal summary; constrained, blocked, and future-only records stay inactive for core output',
      )
      ..writeln(
        '- it does not classify, value, order, integrate, call an engine, run Android, or write files',
      )
      ..writeln()
      ..writeln('## Readiness Table')
      ..writeln(
        '| Record | Source Review | Packet | Scope | Group | Status | Support Cases | New Phase 32E Support | Android Proof | Signals | Areas | Buckets | Allowed | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final record in records) {
      buffer.writeln(
        '| ${_cell(record.readinessRecordId)} | '
        '${_cell(record.sourceReviewRecordId)} | ${_cell(record.packetId)} | '
        '${record.scopeId.wire} | ${record.readinessGroup.wire} | '
        '${record.readinessStatus.wire} | ${_ids(record.supportCaseIds)} | '
        '${_ids(record.newlyAddedSupportCaseIds)} | '
        '${_ids(record.androidProofCaseIds)} | '
        '${_signalIds(record.activeSignalIds)} | '
        '${_areaIds(record.evidenceAreaIds)} | '
        '${_bucketIds(record.bucketIds)} | '
        '${record.allowedForNextInternalLayer} | '
        '${record.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Allowed Records')
      ..writeln('- ${_packetIds(allowedRecords)}')
      ..writeln()
      ..writeln('## Constrained Records')
      ..writeln('- ${_packetIds(constrainedRecords)}')
      ..writeln()
      ..writeln('## Blocked And Future-Only Records')
      ..writeln('- ${_packetIds(blockedOrFutureRecords)}')
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
      ..writeln('## Phase 32L Recommendation')
      ..writeln(phase32LRecommendation.wire)
      ..writeln()
      ..writeln(
        'This readiness gate stays internal-only. It does not emit user-facing output, compute product metrics, call the engine, run Android, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': refreshedPacketEvidenceReadinessGateReportVersion,
      'readinessStatus': readinessStatus.wire,
      'sourceReviewStatus': sourceReviewStatus.wire,
      'sourceRefreshStatus': sourceRefreshStatus.wire,
      'sourceValidationStatus': sourceValidationStatus.wire,
      'sourcePlanStatus': sourcePlanStatus.wire,
      'totalRecords': totalRecords,
      'allowedRecordCount': allowedRecordCount,
      'constrainedRecordCount': constrainedRecordCount,
      'blockedRecordCount': blockedRecordCount,
      'futureOnlyRecordCount': futureOnlyRecordCount,
      'unsafeCount': unsafeCount,
      'criticalCount': criticalCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'coverageGapIds': coverageGapIds,
      'safeForPhase32L': safeForPhase32L,
      'phase32LRecommendation': phase32LRecommendation.wire,
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

class RefreshedPacketEvidenceReadinessGate {
  const RefreshedPacketEvidenceReadinessGate({
    this.validator = const RefreshedPacketEvidenceReadinessGateValidator(),
  });

  final RefreshedPacketEvidenceReadinessGateValidator validator;

  RefreshedPacketEvidenceReadinessGateResult evaluate([
    RefreshedPacketEvidenceReadinessGateRequest request =
        const RefreshedPacketEvidenceReadinessGateRequest(),
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
    final reviewResult =
        request.reviewResult ??
        request.review.evaluate(
          InternalPacketEvidenceRefreshReviewRequest(
            refreshResult: refreshResult,
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
    final canGateRecords =
        reviewResult.safeForPhase32K && !reviewResult.isStrictlyBlocked;
    final records = canGateRecords
        ? _recordsFrom(reviewResult.rows)
        : const <RefreshedPacketEvidenceReadinessRecord>[];
    final base = _resultFromRecords(
      reviewResult: reviewResult,
      refreshResult: refreshResult,
      validationResult: validationResult,
      planResult: planResult,
      records: records,
      validationFindings: const <RefreshedPacketEvidenceReadinessFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromRecords(
      reviewResult: reviewResult,
      refreshResult: refreshResult,
      validationResult: validationResult,
      planResult: planResult,
      records: records,
      validationFindings: findings,
    );
  }
}

class RefreshedPacketEvidenceReadinessGateValidator {
  const RefreshedPacketEvidenceReadinessGateValidator();

  List<RefreshedPacketEvidenceReadinessFinding> validate(
    RefreshedPacketEvidenceReadinessGateResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <RefreshedPacketEvidenceReadinessFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required RefreshedPacketEvidenceReadinessValidationSeverity severity,
      required String message,
      String? recordId,
      String? packetId,
      InternalNonLabelPrototypeScopeId? scopeId,
      String? caseId,
    }) {
      findings.add(
        RefreshedPacketEvidenceReadinessFinding(
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

    if (result.safeForPhase32L &&
        (result.sourceReviewStatus ==
                InternalPacketEvidenceRefreshReviewStatus
                    .blockedByUnsafeRefresh ||
            result.unsafeCount > 0 ||
            result.records.any((record) => record.readinessStatus.isUnsafe))) {
      add(
        id: 'unsafeReviewMarkedReady',
        severity: RefreshedPacketEvidenceReadinessValidationSeverity.critical,
        message: 'unsafe review cannot be marked ready for Phase 32L',
      );
    }

    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: RefreshedPacketEvidenceReadinessValidationSeverity.blocker,
        message: 'owner proof requires explicit PV/MultiPV reason',
      );
    }

    for (final record in result.records) {
      if (record.readinessStatus.isUnsafe &&
          record.allowedForNextInternalLayer) {
        add(
          id: 'invalidRecordMarkedReady',
          severity: RefreshedPacketEvidenceReadinessValidationSeverity.critical,
          message: '${record.packetId} is invalid or unsafe but marked ready',
          recordId: record.readinessRecordId,
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      if (record.readinessGroup.isAllowed &&
          (record.supportCaseIds.isEmpty ||
              record.activeSignalIds.isEmpty ||
              record.evidenceAreaIds.isEmpty ||
              record.bucketIds.isEmpty)) {
        add(
          id: 'allowedRecordMissingEvidenceMapping',
          severity: RefreshedPacketEvidenceReadinessValidationSeverity.blocker,
          message: '${record.packetId} lacks support or source mapping',
          recordId: record.readinessRecordId,
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      if (record.readinessGroup.isConstrained &&
          !record.readinessStatus.isUnsafe &&
          (record.allowedForNextInternalLayer ||
              record.readinessStatus ==
                  RefreshedPacketEvidenceReadinessRecordStatus.allowed)) {
        add(
          id: 'constrainedRecordPromotedToAllowed',
          severity: RefreshedPacketEvidenceReadinessValidationSeverity.critical,
          message: '${record.scopeId.wire} must remain constrained',
          recordId: record.readinessRecordId,
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      if (record.readinessGroup.isBlocked &&
          !record.readinessStatus.isUnsafe &&
          (record.allowedForNextInternalLayer ||
              record.readinessStatus !=
                  RefreshedPacketEvidenceReadinessRecordStatus.blocked)) {
        add(
          id: 'blockedRecordBecameActive',
          severity: RefreshedPacketEvidenceReadinessValidationSeverity.critical,
          message: '${record.scopeId.wire} must remain blocked',
          recordId: record.readinessRecordId,
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      if (record.readinessGroup.isFutureOnly &&
          !record.readinessStatus.isUnsafe &&
          (record.allowedForNextInternalLayer ||
              record.readinessStatus !=
                  RefreshedPacketEvidenceReadinessRecordStatus.futureOnly)) {
        add(
          id: 'futureOnlyRecordBecameActive',
          severity: RefreshedPacketEvidenceReadinessValidationSeverity.critical,
          message: '${record.scopeId.wire} must remain future-only',
          recordId: record.readinessRecordId,
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      if (record.scopeId ==
              InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope &&
          (record.quietScopeActive ||
              record.allowedForNextInternalLayer ||
              !record.readinessStatus.isUnsafe &&
                  record.readinessStatus !=
                      RefreshedPacketEvidenceReadinessRecordStatus.blocked)) {
        add(
          id: 'quietPreparatoryScopeActivated',
          severity: RefreshedPacketEvidenceReadinessValidationSeverity.critical,
          message: 'quiet/preparatory scope must remain excluded',
          recordId: record.readinessRecordId,
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      if (record.hasUnsafeOutput) {
        add(
          id: 'readinessRecordBoundaryPolicyViolation',
          severity: RefreshedPacketEvidenceReadinessValidationSeverity.critical,
          message: '${record.packetId} crossed a blocked output boundary',
          recordId: record.readinessRecordId,
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      for (final caseId in record.androidProofCaseIds) {
        if (!_capturedAndroidProofIds.contains(caseId) ||
            !provenAndroidIds.contains(caseId)) {
          add(
            id: 'unprovenAndroidProofClaim',
            severity:
                RefreshedPacketEvidenceReadinessValidationSeverity.critical,
            message: '${record.packetId} cited unproven Android proof',
            recordId: record.readinessRecordId,
            packetId: record.packetId,
            scopeId: record.scopeId,
            caseId: caseId,
          );
        }
        if (_phase32ECaseIds.contains(caseId)) {
          add(
            id: 'phase32ECaseClaimedCapturedProof',
            severity:
                RefreshedPacketEvidenceReadinessValidationSeverity.critical,
            message: 'Phase 32E case cannot be captured Android proof',
            recordId: record.readinessRecordId,
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
          severity: RefreshedPacketEvidenceReadinessValidationSeverity.critical,
          message: 'readiness gate cited unproven Android proof',
          caseId: caseId,
        );
      }
      if (_phase32ECaseIds.contains(caseId)) {
        add(
          id: 'phase32ECaseClaimedCapturedProof',
          severity: RefreshedPacketEvidenceReadinessValidationSeverity.critical,
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
        id: 'readinessBoundaryPolicyViolation',
        severity: RefreshedPacketEvidenceReadinessValidationSeverity.critical,
        message: 'readiness gate crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<RefreshedPacketEvidenceReadinessFinding> validateReportText(
    String reportText,
  ) {
    final findings = <RefreshedPacketEvidenceReadinessFinding>[];
    void reportError(String id, String message) {
      findings.add(
        RefreshedPacketEvidenceReadinessFinding(
          id: id,
          severity: RefreshedPacketEvidenceReadinessValidationSeverity.critical,
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

List<RefreshedPacketEvidenceReadinessRecord> _recordsFrom(
  List<InternalPacketEvidenceRefreshReviewRow> rows,
) {
  final records = rows.map(_recordFromRow).toList()
    ..sort((a, b) => a.scopeId.index.compareTo(b.scopeId.index));
  return List<RefreshedPacketEvidenceReadinessRecord>.unmodifiable(records);
}

RefreshedPacketEvidenceReadinessRecord _recordFromRow(
  InternalPacketEvidenceRefreshReviewRow row,
) {
  final group = _groupFor(row);
  final status = _readinessStatusFor(row.reviewStatus, group);
  final allowedForNextInternalLayer =
      group.isAllowed &&
      status == RefreshedPacketEvidenceReadinessRecordStatus.allowed &&
      row.safeForNextInternalGate &&
      !row.hasUnsafeOutput &&
      !_coreMappingMissing(
        row.scopeId,
        row.supportCaseIds,
        row.activeSignalIds,
        row.evidenceAreaIds,
        row.bucketIds,
      );
  return RefreshedPacketEvidenceReadinessRecord(
    readinessRecordId: '${row.scopeId.wire}-readiness',
    sourceReviewRecordId: row.recordId,
    packetId: row.packetId,
    scopeId: row.scopeId,
    readinessGroup: group,
    readinessStatus: status,
    sourceReviewStatus: row.reviewStatus,
    supportCaseIds: _sortedStrings(row.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(row.newlyAddedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(row.androidProofCaseIds),
    activeSignalIds: row.activeSignalIds,
    evidenceAreaIds: row.evidenceAreaIds,
    bucketIds: row.bucketIds,
    warningReason: row.warningReason,
    proofLimitReason: row.proofLimitReason,
    futurePrerequisite: row.futurePrerequisite,
    blockedBoundaryIds: _sortedStrings(row.blockedBoundaryIds),
    coverageGapIds: _sortedStrings(row.coverageGapIds),
    allowedForNextInternalLayer: allowedForNextInternalLayer,
    recommendation: _recommendationFor(group, status),
    isProductOutput: row.isProductOutput,
    isClassifierLabel: row.isClassifierLabel,
    isOfficialMetric: row.isOfficialMetric,
    hasNumericValue: row.hasNumericValue,
    ordersMoves: row.ordersMoves,
    quietScopeActive: row.quietScopeActive,
    cpLossComputationImplemented: row.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        row.winProbabilityComputationImplemented,
    emittedOutputNames: row.emittedOutputNames,
  );
}

RefreshedPacketEvidenceReadinessGateResult _resultFromRecords({
  required InternalPacketEvidenceRefreshReviewResult reviewResult,
  required InternalPacketEvidenceRefreshResult refreshResult,
  required RefreshedPacketHardeningValidationResult validationResult,
  required RefreshedInternalPacketHardeningPlanResult planResult,
  required List<RefreshedPacketEvidenceReadinessRecord> records,
  required List<RefreshedPacketEvidenceReadinessFinding> validationFindings,
}) {
  final recordUnsafeCount = records
      .where(
        (record) =>
            record.readinessStatus ==
                RefreshedPacketEvidenceReadinessRecordStatus.unsafe ||
            record.hasUnsafeOutput,
      )
      .length;
  final unsafeCount = reviewResult.unsafeCount + recordUnsafeCount;
  final criticalCount =
      reviewResult.criticalCount +
      validationFindings.where((finding) => finding.isCritical).length;
  final invalidCount = records
      .where(
        (record) =>
            record.readinessStatus ==
            RefreshedPacketEvidenceReadinessRecordStatus.invalid,
      )
      .length;
  final base = RefreshedPacketEvidenceReadinessGateResult(
    readinessStatus: RefreshedPacketEvidenceReadinessStatus.invalid,
    sourceReviewStatus: reviewResult.reviewStatus,
    sourceRefreshStatus: refreshResult.refreshStatus,
    sourceValidationStatus: validationResult.validationStatus,
    sourcePlanStatus: planResult.refreshedStatus,
    records: records,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...reviewResult.warnings,
      ...refreshResult.warnings,
      ...validationResult.warnings,
      ...planResult.warnings,
      if (records.any((record) => record.readinessGroup.isConstrained))
        'constrained readiness records remain outside allowed core output',
      if (records.any(
        (record) =>
            record.readinessGroup ==
            RefreshedPacketEvidenceReadinessGroup.watchListedEvidenceGroup,
      ))
        'PV/MultiPV readiness remains watch-listed',
      if (records.any(
        (record) =>
            record.readinessGroup ==
            RefreshedPacketEvidenceReadinessGroup.proofLimitedEvidenceGroup,
      ))
        'Android proof readiness remains proof-limited',
    ]),
    failures: _sortedStrings(<String>[
      ...reviewResult.failures,
      ...refreshResult.failures,
      ...validationResult.failures,
      ...planResult.failures,
      ...validationFindings.map((finding) => finding.message),
    ]),
    totalRecords: records.length,
    allowedRecordCount: records
        .where((record) => record.readinessGroup.isAllowed)
        .length,
    constrainedRecordCount: records
        .where((record) => record.readinessGroup.isConstrained)
        .length,
    blockedRecordCount: records
        .where((record) => record.readinessGroup.isBlocked)
        .length,
    futureOnlyRecordCount: records
        .where((record) => record.readinessGroup.isFutureOnly)
        .length,
    unsafeCount: unsafeCount,
    criticalCount: criticalCount,
    ownerProofQueueCount: reviewResult.ownerProofQueueCount,
    supportCaseIds: _sortedStrings(
      records.expand((record) => record.supportCaseIds),
    ),
    newlyAddedSupportCaseIds: _sortedStrings(
      records.expand((record) => record.newlyAddedSupportCaseIds),
    ),
    androidProofCaseIds: _sortedStrings(reviewResult.androidProofCaseIds),
    coverageGapIds: _sortedStrings(
      records.expand((record) => record.coverageGapIds),
    ),
    safeForPhase32L: false,
    phase32LRecommendation:
        RefreshedPacketEvidenceReadinessPhase32LRecommendation
            .addMoreGoldenCoverageFirst,
    productLabelsEmitted:
        reviewResult.productLabelsEmitted ||
        refreshResult.productLabelsEmitted ||
        validationResult.productLabelsEmitted ||
        planResult.productLabelsEmitted,
    advancedLabelsEmitted:
        reviewResult.advancedLabelsEmitted ||
        refreshResult.advancedLabelsEmitted ||
        validationResult.advancedLabelsEmitted ||
        planResult.advancedLabelsEmitted,
    classifierLabelsEmitted:
        reviewResult.classifierLabelsEmitted ||
        refreshResult.classifierLabelsEmitted ||
        validationResult.classifierLabelsEmitted ||
        planResult.classifierLabelsEmitted,
    finalMoveLabelsEmitted:
        reviewResult.finalMoveLabelsEmitted ||
        refreshResult.finalMoveLabelsEmitted ||
        validationResult.finalMoveLabelsEmitted ||
        planResult.finalMoveLabelsEmitted,
    officialMetricsAllowed:
        reviewResult.officialMetricsAllowed ||
        refreshResult.officialMetricsAllowed ||
        validationResult.officialMetricsAllowed ||
        planResult.officialMetricsAllowed,
    cpLossComputationImplemented:
        reviewResult.cpLossComputationImplemented ||
        refreshResult.cpLossComputationImplemented ||
        validationResult.cpLossComputationImplemented ||
        planResult.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        reviewResult.winProbabilityComputationImplemented ||
        refreshResult.winProbabilityComputationImplemented ||
        validationResult.winProbabilityComputationImplemented ||
        planResult.winProbabilityComputationImplemented,
    numericMoveValuesComputed:
        reviewResult.numericMoveValuesComputed ||
        refreshResult.numericMoveValuesComputed ||
        validationResult.numericMoveValuesComputed ||
        planResult.numericMoveValuesComputed,
    moveOrderingComputed:
        reviewResult.moveOrderingComputed ||
        refreshResult.moveOrderingComputed ||
        validationResult.moveOrderingComputed ||
        planResult.moveOrderingComputed,
    quietPreparatoryScopeActivated:
        reviewResult.quietPreparatoryScopeActivated ||
        refreshResult.quietPreparatoryScopeActivated ||
        validationResult.quietPreparatoryScopeActivated ||
        planResult.quietPreparatoryScopeActivated,
    directEngineAccessUsed:
        reviewResult.directEngineAccessUsed ||
        refreshResult.directEngineAccessUsed ||
        validationResult.directEngineAccessUsed ||
        planResult.directEngineAccessUsed,
    uiOutputUsed:
        reviewResult.uiOutputUsed ||
        refreshResult.uiOutputUsed ||
        validationResult.uiOutputUsed ||
        planResult.uiOutputUsed,
    backendOutputUsed:
        reviewResult.backendOutputUsed ||
        refreshResult.backendOutputUsed ||
        validationResult.backendOutputUsed ||
        planResult.backendOutputUsed,
    persistenceUsed:
        reviewResult.persistenceUsed ||
        refreshResult.persistenceUsed ||
        validationResult.persistenceUsed ||
        planResult.persistenceUsed,
    emittedOutputFamilies: _sortedStrings(<String>[
      ...reviewResult.emittedOutputFamilies,
      ...refreshResult.emittedOutputFamilies,
      ...validationResult.emittedOutputFamilies,
      ...planResult.emittedOutputFamilies,
    ]),
  );
  final status = _readinessGateStatusFor(
    base,
    reviewResult: reviewResult,
    invalidCount: invalidCount,
  );
  final safeForPhase32L =
      (status == RefreshedPacketEvidenceReadinessStatus.readyWithWarnings ||
          status ==
              RefreshedPacketEvidenceReadinessStatus
                  .readyForNarrowInternalEvidenceSummary) &&
      reviewResult.safeForPhase32K &&
      !reviewResult.isStrictlyBlocked &&
      !reviewResult.hasUnsafeReviewPolicyViolation &&
      unsafeCount == 0 &&
      criticalCount == 0 &&
      invalidCount == 0 &&
      !validationFindings.any((finding) => finding.blocksStrict) &&
      records
          .where((record) => record.readinessGroup.isAllowed)
          .every((record) => record.allowedForNextInternalLayer) &&
      records
          .where((record) => !record.readinessGroup.isAllowed)
          .every((record) => !record.allowedForNextInternalLayer);
  return base.copyWith(
    readinessStatus: status,
    safeForPhase32L: safeForPhase32L,
    phase32LRecommendation: _phase32LRecommendationFor(
      status: status,
      safeForPhase32L: safeForPhase32L,
      ownerProofQueueCount: reviewResult.ownerProofQueueCount,
      constrainedRecordCount: base.constrainedRecordCount,
    ),
  );
}

RefreshedPacketEvidenceReadinessStatus _readinessGateStatusFor(
  RefreshedPacketEvidenceReadinessGateResult result, {
  required InternalPacketEvidenceRefreshReviewResult reviewResult,
  required int invalidCount,
}) {
  if (result.validationFindings.any(
    (finding) => finding.id == 'unprovenAndroidProofClaim',
  )) {
    return RefreshedPacketEvidenceReadinessStatus.blockedByUnprovenAndroidProof;
  }
  if (reviewResult.reviewStatus ==
          InternalPacketEvidenceRefreshReviewStatus.blockedByUnsafeRefresh ||
      reviewResult.unsafeCount > 0 ||
      result.unsafeCount > 0 ||
      result.criticalCount > 0 ||
      result.validationFindings.any((finding) => finding.isCritical)) {
    return RefreshedPacketEvidenceReadinessStatus.blockedByUnsafeReview;
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
    return RefreshedPacketEvidenceReadinessStatus.blockedByPolicyBoundary;
  }
  if (!reviewResult.safeForPhase32K ||
      reviewResult.isStrictlyBlocked ||
      invalidCount > 0 ||
      result.validationFindings.any((finding) => finding.blocksStrict)) {
    return RefreshedPacketEvidenceReadinessStatus.blockedByInvalidRecord;
  }
  if (result.records.isEmpty) {
    return RefreshedPacketEvidenceReadinessStatus.invalid;
  }
  if (result.constrainedRecordCount > 0 || result.coverageGapIds.isNotEmpty) {
    return RefreshedPacketEvidenceReadinessStatus.readyWithWarnings;
  }
  return RefreshedPacketEvidenceReadinessStatus
      .readyForNarrowInternalEvidenceSummary;
}

RefreshedPacketEvidenceReadinessPhase32LRecommendation
_phase32LRecommendationFor({
  required RefreshedPacketEvidenceReadinessStatus status,
  required bool safeForPhase32L,
  required int ownerProofQueueCount,
  required int constrainedRecordCount,
}) {
  if (status == RefreshedPacketEvidenceReadinessStatus.blockedByUnsafeReview ||
      status ==
          RefreshedPacketEvidenceReadinessStatus.blockedByPolicyBoundary ||
      status ==
          RefreshedPacketEvidenceReadinessStatus
              .blockedByUnprovenAndroidProof) {
    return RefreshedPacketEvidenceReadinessPhase32LRecommendation
        .blockedByUnsafeReadiness;
  }
  if (ownerProofQueueCount > 0) {
    return RefreshedPacketEvidenceReadinessPhase32LRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase32L) {
    return RefreshedPacketEvidenceReadinessPhase32LRecommendation
        .addMoreGoldenCoverageFirst;
  }
  if (constrainedRecordCount > 0) {
    return RefreshedPacketEvidenceReadinessPhase32LRecommendation
        .proceedToInternalEvidenceSummaryLayer;
  }
  return RefreshedPacketEvidenceReadinessPhase32LRecommendation
      .proceedToInternalEvidenceAdapterDesign;
}

RefreshedPacketEvidenceReadinessGroup _groupFor(
  InternalPacketEvidenceRefreshReviewRow row,
) {
  return switch (row.reviewStatus) {
    InternalPacketEvidenceRefreshReviewRowStatus.validPreservedStable =>
      RefreshedPacketEvidenceReadinessGroup.preservedStableEvidenceGroup,
    InternalPacketEvidenceRefreshReviewRowStatus.validImprovedSupport =>
      RefreshedPacketEvidenceReadinessGroup.improvedSupportEvidenceGroup,
    InternalPacketEvidenceRefreshReviewRowStatus.validWatchListed =>
      RefreshedPacketEvidenceReadinessGroup.watchListedEvidenceGroup,
    InternalPacketEvidenceRefreshReviewRowStatus.validProofLimited =>
      RefreshedPacketEvidenceReadinessGroup.proofLimitedEvidenceGroup,
    InternalPacketEvidenceRefreshReviewRowStatus.validWarningLimited =>
      RefreshedPacketEvidenceReadinessGroup.warningLimitedEvidenceGroup,
    InternalPacketEvidenceRefreshReviewRowStatus.validFutureOnly =>
      _futureGroupFor(row.scopeId),
    InternalPacketEvidenceRefreshReviewRowStatus.validBlocked =>
      _blockedGroupFor(row.scopeId),
    InternalPacketEvidenceRefreshReviewRowStatus.invalid => _blockedGroupFor(
      row.scopeId,
    ),
    InternalPacketEvidenceRefreshReviewRowStatus.unsafe => _blockedGroupFor(
      row.scopeId,
    ),
  };
}

RefreshedPacketEvidenceReadinessRecordStatus _readinessStatusFor(
  InternalPacketEvidenceRefreshReviewRowStatus sourceStatus,
  RefreshedPacketEvidenceReadinessGroup group,
) {
  return switch (sourceStatus) {
    InternalPacketEvidenceRefreshReviewRowStatus.invalid =>
      RefreshedPacketEvidenceReadinessRecordStatus.invalid,
    InternalPacketEvidenceRefreshReviewRowStatus.unsafe =>
      RefreshedPacketEvidenceReadinessRecordStatus.unsafe,
    _ when group.isAllowed =>
      RefreshedPacketEvidenceReadinessRecordStatus.allowed,
    _ when group.isConstrained =>
      RefreshedPacketEvidenceReadinessRecordStatus.constrained,
    _ when group.isFutureOnly =>
      RefreshedPacketEvidenceReadinessRecordStatus.futureOnly,
    _ => RefreshedPacketEvidenceReadinessRecordStatus.blocked,
  };
}

RefreshedPacketEvidenceReadinessRecommendation _recommendationFor(
  RefreshedPacketEvidenceReadinessGroup group,
  RefreshedPacketEvidenceReadinessRecordStatus status,
) {
  if (status.isUnsafe) {
    return RefreshedPacketEvidenceReadinessRecommendation.blockUnsafeRecord;
  }
  return switch (group) {
    RefreshedPacketEvidenceReadinessGroup.preservedStableEvidenceGroup =>
      RefreshedPacketEvidenceReadinessRecommendation
          .allowInNarrowInternalSummary,
    RefreshedPacketEvidenceReadinessGroup.improvedSupportEvidenceGroup =>
      RefreshedPacketEvidenceReadinessRecommendation.allowAsImprovedSupport,
    RefreshedPacketEvidenceReadinessGroup.watchListedEvidenceGroup =>
      RefreshedPacketEvidenceReadinessRecommendation.keepWatchListed,
    RefreshedPacketEvidenceReadinessGroup.proofLimitedEvidenceGroup =>
      RefreshedPacketEvidenceReadinessRecommendation.keepProofLimited,
    RefreshedPacketEvidenceReadinessGroup.warningLimitedEvidenceGroup =>
      RefreshedPacketEvidenceReadinessRecommendation.keepWarningLimitedOnly,
    RefreshedPacketEvidenceReadinessGroup.cpLossFutureOnlyGroup ||
    RefreshedPacketEvidenceReadinessGroup.winProbabilityFutureOnlyGroup =>
      RefreshedPacketEvidenceReadinessRecommendation.keepFutureOnly,
    _ => RefreshedPacketEvidenceReadinessRecommendation.keepBlocked,
  };
}

RefreshedPacketEvidenceReadinessGroup _blockedGroupFor(
  InternalNonLabelPrototypeScopeId scopeId,
) {
  return switch (scopeId) {
    InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope =>
      RefreshedPacketEvidenceReadinessGroup.quietPreparatoryBlockedGroup,
    InternalNonLabelPrototypeScopeId.productLabelPrototypeScope =>
      RefreshedPacketEvidenceReadinessGroup.productLabelBlockedGroup,
    InternalNonLabelPrototypeScopeId.advancedLabelPrototypeScope =>
      RefreshedPacketEvidenceReadinessGroup.advancedLabelBlockedGroup,
    InternalNonLabelPrototypeScopeId.officialMetricPrototypeScope =>
      RefreshedPacketEvidenceReadinessGroup.officialMetricBlockedGroup,
    InternalNonLabelPrototypeScopeId.uiProductIntegrationScope ||
    InternalNonLabelPrototypeScopeId.backendIntegrationScope ||
    InternalNonLabelPrototypeScopeId.persistenceScope =>
      RefreshedPacketEvidenceReadinessGroup.uiBackendPersistenceBlockedGroup,
    InternalNonLabelPrototypeScopeId.directEngineAccessScope =>
      RefreshedPacketEvidenceReadinessGroup.directEngineAccessBlockedGroup,
    _ => RefreshedPacketEvidenceReadinessGroup.productLabelBlockedGroup,
  };
}

RefreshedPacketEvidenceReadinessGroup _futureGroupFor(
  InternalNonLabelPrototypeScopeId scopeId,
) {
  return switch (scopeId) {
    InternalNonLabelPrototypeScopeId.cpLossPrototypeScope =>
      RefreshedPacketEvidenceReadinessGroup.cpLossFutureOnlyGroup,
    InternalNonLabelPrototypeScopeId.winProbabilityPrototypeScope =>
      RefreshedPacketEvidenceReadinessGroup.winProbabilityFutureOnlyGroup,
    _ => _blockedGroupFor(scopeId),
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

bool _hasExplicitPvProofReason(
  RefreshedPacketEvidenceReadinessGateResult result,
) {
  final reasons = <String>[
    ...result.records.map((record) => record.proofLimitReason),
    ...result.records.map((record) => record.warningReason),
    ...result.records.map((record) => record.futurePrerequisite),
  ].join(' ').toLowerCase();
  return reasons.contains('pv') || reasons.contains('multipv');
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

String _packetIds(Iterable<RefreshedPacketEvidenceReadinessRecord> records) {
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
  RefreshedPacketEvidenceReadinessFinding a,
  RefreshedPacketEvidenceReadinessFinding b,
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

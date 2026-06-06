/// Developer-only compact summary of refreshed internal evidence readiness.
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
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_evidence_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_hardening_validation.dart';
import 'package:apex_chess/features/pgn_review/application/targeted_golden_coverage_impact_review.dart';

const internalEvidenceSummaryLayerReportVersion =
    'internal-evidence-summary-layer-v1';

enum InternalEvidenceSummaryLayerStatus {
  summarizedWithWarnings('summarizedWithWarnings'),
  summarizedClean('summarizedClean'),
  blockedByUnsafeReadiness('blockedByUnsafeReadiness'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const InternalEvidenceSummaryLayerStatus(this.wire);

  final String wire;
}

enum InternalEvidenceSummaryGroupId {
  allowedEvidenceSummary('allowedEvidenceSummary'),
  improvedSupportSummary('improvedSupportSummary'),
  constrainedWatchListSummary('constrainedWatchListSummary'),
  proofLimitedSummary('proofLimitedSummary'),
  warningLimitedSummary('warningLimitedSummary'),
  blockedBoundarySummary('blockedBoundarySummary'),
  futureOnlySummary('futureOnlySummary');

  const InternalEvidenceSummaryGroupId(this.wire);

  final String wire;
}

enum InternalEvidenceSummaryGroupStatus {
  allowed('allowed'),
  constrained('constrained'),
  blocked('blocked'),
  futureOnly('futureOnly'),
  unsafe('unsafe'),
  invalid('invalid');

  const InternalEvidenceSummaryGroupStatus(this.wire);

  final String wire;

  bool get isUnsafe =>
      this == InternalEvidenceSummaryGroupStatus.unsafe ||
      this == InternalEvidenceSummaryGroupStatus.invalid;
}

enum InternalEvidenceSummaryRecommendation {
  keepAllowedEvidence('keepAllowedEvidence'),
  keepImprovedSupport('keepImprovedSupport'),
  keepWatchListed('keepWatchListed'),
  keepProofLimited('keepProofLimited'),
  keepWarningLimitedOnly('keepWarningLimitedOnly'),
  keepBlocked('keepBlocked'),
  keepFutureOnly('keepFutureOnly'),
  blockUnsafeSummary('blockUnsafeSummary');

  const InternalEvidenceSummaryRecommendation(this.wire);

  final String wire;
}

enum InternalEvidenceSummaryPhase32MRecommendation {
  proceedToInternalEvidenceAdapterDesign(
    'proceedToInternalEvidenceAdapterDesign',
  ),
  proceedToSummaryValidation('proceedToSummaryValidation'),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeSummary('blockedByUnsafeSummary');

  const InternalEvidenceSummaryPhase32MRecommendation(this.wire);

  final String wire;
}

enum InternalEvidenceSummaryValidationSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const InternalEvidenceSummaryValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == InternalEvidenceSummaryValidationSeverity.blocker ||
      this == InternalEvidenceSummaryValidationSeverity.critical;
}

enum InternalEvidenceSummaryLayerReportFormat {
  markdown('markdown'),
  json('json');

  const InternalEvidenceSummaryLayerReportFormat(this.wire);

  final String wire;
}

class InternalEvidenceSummaryLayerRequest {
  const InternalEvidenceSummaryLayerRequest({
    this.readinessResult,
    this.reviewResult,
    this.refreshResult,
    this.validationResult,
    this.refreshedPlanResult,
    this.impactReviewResult,
    this.hardeningPlanResult,
    this.stabilityResult,
    this.matrixResult,
    this.prototypeResult,
    this.readinessGate = const RefreshedPacketEvidenceReadinessGate(),
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

  const InternalEvidenceSummaryLayerRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final RefreshedPacketEvidenceReadinessGateResult? readinessResult;
  final InternalPacketEvidenceRefreshReviewResult? reviewResult;
  final InternalPacketEvidenceRefreshResult? refreshResult;
  final RefreshedPacketHardeningValidationResult? validationResult;
  final RefreshedInternalPacketHardeningPlanResult? refreshedPlanResult;
  final TargetedGoldenCoverageImpactReviewResult? impactReviewResult;
  final InternalPacketEvidenceHardeningPlanResult? hardeningPlanResult;
  final InternalPacketStabilityPrototypeResult? stabilityResult;
  final InternalPacketReviewAggregationMatrixResult? matrixResult;
  final NarrowInternalNonLabelAnalysisPrototypeResult? prototypeResult;
  final RefreshedPacketEvidenceReadinessGate readinessGate;
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

class InternalEvidenceSummaryGroup {
  const InternalEvidenceSummaryGroup({
    required this.groupId,
    required this.groupStatus,
    required this.recordIds,
    required this.packetIds,
    required this.scopeIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.activeSignalIds,
    required this.evidenceAreaIds,
    required this.bucketIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.futurePrerequisites,
    required this.blockedBoundaryIds,
    required this.safeForNextInternalLayer,
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

  final InternalEvidenceSummaryGroupId groupId;
  final InternalEvidenceSummaryGroupStatus groupStatus;
  final List<String> recordIds;
  final List<String> packetIds;
  final List<InternalNonLabelPrototypeScopeId> scopeIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<InternalNonLabelSignalId> activeSignalIds;
  final List<InternalEvidenceAreaId> evidenceAreaIds;
  final List<InternalEvidenceBucketId> bucketIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> futurePrerequisites;
  final List<String> blockedBoundaryIds;
  final bool safeForNextInternalLayer;
  final InternalEvidenceSummaryRecommendation recommendation;
  final bool isProductOutput;
  final bool isClassifierLabel;
  final bool isOfficialMetric;
  final bool hasNumericValue;
  final bool ordersMoves;
  final bool quietScopeActive;
  final bool cpLossComputationImplemented;
  final bool winProbabilityComputationImplemented;
  final List<String> emittedOutputNames;

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

  InternalEvidenceSummaryGroup copyWith({
    InternalEvidenceSummaryGroupId? groupId,
    InternalEvidenceSummaryGroupStatus? groupStatus,
    List<String>? recordIds,
    List<String>? packetIds,
    List<InternalNonLabelPrototypeScopeId>? scopeIds,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<InternalNonLabelSignalId>? activeSignalIds,
    List<InternalEvidenceAreaId>? evidenceAreaIds,
    List<InternalEvidenceBucketId>? bucketIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? futurePrerequisites,
    List<String>? blockedBoundaryIds,
    bool? safeForNextInternalLayer,
    InternalEvidenceSummaryRecommendation? recommendation,
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
    return InternalEvidenceSummaryGroup(
      groupId: groupId ?? this.groupId,
      groupStatus: groupStatus ?? this.groupStatus,
      recordIds: recordIds ?? this.recordIds,
      packetIds: packetIds ?? this.packetIds,
      scopeIds: scopeIds ?? this.scopeIds,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      activeSignalIds: activeSignalIds ?? this.activeSignalIds,
      evidenceAreaIds: evidenceAreaIds ?? this.evidenceAreaIds,
      bucketIds: bucketIds ?? this.bucketIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      futurePrerequisites: futurePrerequisites ?? this.futurePrerequisites,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      safeForNextInternalLayer:
          safeForNextInternalLayer ?? this.safeForNextInternalLayer,
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
      'groupId': groupId.wire,
      'groupStatus': groupStatus.wire,
      'recordIds': recordIds,
      'packetIds': packetIds,
      'scopeIds': scopeIds.map((id) => id.wire).toList(),
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'activeSignalIds': activeSignalIds.map((id) => id.wire).toList(),
      'evidenceAreaIds': evidenceAreaIds.map((id) => id.wire).toList(),
      'bucketIds': bucketIds.map((id) => id.wire).toList(),
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'futurePrerequisites': futurePrerequisites,
      'blockedBoundaryIds': blockedBoundaryIds,
      'safeForNextInternalLayer': safeForNextInternalLayer,
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

class InternalEvidenceSummaryFinding {
  const InternalEvidenceSummaryFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.groupId,
    this.caseId,
  });

  final String id;
  final InternalEvidenceSummaryValidationSeverity severity;
  final String message;
  final InternalEvidenceSummaryGroupId? groupId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical =>
      severity == InternalEvidenceSummaryValidationSeverity.critical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (groupId != null) 'groupId': groupId!.wire,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class InternalEvidenceSummaryLayerResult {
  const InternalEvidenceSummaryLayerResult({
    required this.summaryStatus,
    required this.sourceReadinessStatus,
    required this.sourceReviewStatus,
    required this.sourceRefreshStatus,
    required this.sourceValidationStatus,
    required this.groups,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalGroups,
    required this.allowedGroupCount,
    required this.constrainedGroupCount,
    required this.blockedGroupCount,
    required this.futureOnlyGroupCount,
    required this.allowedRecordCount,
    required this.constrainedRecordCount,
    required this.blockedRecordCount,
    required this.futureOnlyRecordCount,
    required this.unsafeCount,
    required this.criticalCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.ownerProofQueueCount,
    required this.safeForPhase32M,
    required this.phase32MRecommendation,
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

  final InternalEvidenceSummaryLayerStatus summaryStatus;
  final RefreshedPacketEvidenceReadinessStatus sourceReadinessStatus;
  final InternalPacketEvidenceRefreshReviewStatus sourceReviewStatus;
  final InternalPacketEvidenceRefreshStatus sourceRefreshStatus;
  final RefreshedPacketHardeningValidationStatus sourceValidationStatus;
  final List<InternalEvidenceSummaryGroup> groups;
  final List<InternalEvidenceSummaryFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalGroups;
  final int allowedGroupCount;
  final int constrainedGroupCount;
  final int blockedGroupCount;
  final int futureOnlyGroupCount;
  final int allowedRecordCount;
  final int constrainedRecordCount;
  final int blockedRecordCount;
  final int futureOnlyRecordCount;
  final int unsafeCount;
  final int criticalCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final int ownerProofQueueCount;
  final bool safeForPhase32M;
  final InternalEvidenceSummaryPhase32MRecommendation phase32MRecommendation;
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
      summaryStatus ==
          InternalEvidenceSummaryLayerStatus.blockedByUnsafeReadiness ||
      summaryStatus ==
          InternalEvidenceSummaryLayerStatus.blockedByPolicyBoundary ||
      summaryStatus == InternalEvidenceSummaryLayerStatus.invalid ||
      !safeForPhase32M ||
      unsafeCount > 0 ||
      criticalCount > 0 ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeSummaryPolicyViolation {
    return unsafeCount > 0 ||
        criticalCount > 0 ||
        validationFindings.any((finding) => finding.isCritical) ||
        groups.any(
          (group) => group.groupStatus.isUnsafe || group.hasUnsafeOutput,
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

  InternalEvidenceSummaryGroup group(InternalEvidenceSummaryGroupId groupId) {
    return groups.singleWhere((group) => group.groupId == groupId);
  }

  List<InternalEvidenceSummaryGroup> get allowedGroups => groups
      .where(
        (group) =>
            group.groupStatus == InternalEvidenceSummaryGroupStatus.allowed,
      )
      .toList(growable: false);

  List<InternalEvidenceSummaryGroup> get constrainedGroups => groups
      .where(
        (group) =>
            group.groupStatus == InternalEvidenceSummaryGroupStatus.constrained,
      )
      .toList(growable: false);

  List<InternalEvidenceSummaryGroup> get blockedOrFutureGroups => groups
      .where(
        (group) =>
            group.groupStatus == InternalEvidenceSummaryGroupStatus.blocked ||
            group.groupStatus == InternalEvidenceSummaryGroupStatus.futureOnly,
      )
      .toList(growable: false);

  InternalEvidenceSummaryLayerResult copyWith({
    InternalEvidenceSummaryLayerStatus? summaryStatus,
    RefreshedPacketEvidenceReadinessStatus? sourceReadinessStatus,
    InternalPacketEvidenceRefreshReviewStatus? sourceReviewStatus,
    InternalPacketEvidenceRefreshStatus? sourceRefreshStatus,
    RefreshedPacketHardeningValidationStatus? sourceValidationStatus,
    List<InternalEvidenceSummaryGroup>? groups,
    List<InternalEvidenceSummaryFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalGroups,
    int? allowedGroupCount,
    int? constrainedGroupCount,
    int? blockedGroupCount,
    int? futureOnlyGroupCount,
    int? allowedRecordCount,
    int? constrainedRecordCount,
    int? blockedRecordCount,
    int? futureOnlyRecordCount,
    int? unsafeCount,
    int? criticalCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    int? ownerProofQueueCount,
    bool? safeForPhase32M,
    InternalEvidenceSummaryPhase32MRecommendation? phase32MRecommendation,
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
    return InternalEvidenceSummaryLayerResult(
      summaryStatus: summaryStatus ?? this.summaryStatus,
      sourceReadinessStatus:
          sourceReadinessStatus ?? this.sourceReadinessStatus,
      sourceReviewStatus: sourceReviewStatus ?? this.sourceReviewStatus,
      sourceRefreshStatus: sourceRefreshStatus ?? this.sourceRefreshStatus,
      sourceValidationStatus:
          sourceValidationStatus ?? this.sourceValidationStatus,
      groups: groups ?? this.groups,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalGroups: totalGroups ?? this.totalGroups,
      allowedGroupCount: allowedGroupCount ?? this.allowedGroupCount,
      constrainedGroupCount:
          constrainedGroupCount ?? this.constrainedGroupCount,
      blockedGroupCount: blockedGroupCount ?? this.blockedGroupCount,
      futureOnlyGroupCount: futureOnlyGroupCount ?? this.futureOnlyGroupCount,
      allowedRecordCount: allowedRecordCount ?? this.allowedRecordCount,
      constrainedRecordCount:
          constrainedRecordCount ?? this.constrainedRecordCount,
      blockedRecordCount: blockedRecordCount ?? this.blockedRecordCount,
      futureOnlyRecordCount:
          futureOnlyRecordCount ?? this.futureOnlyRecordCount,
      unsafeCount: unsafeCount ?? this.unsafeCount,
      criticalCount: criticalCount ?? this.criticalCount,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      safeForPhase32M: safeForPhase32M ?? this.safeForPhase32M,
      phase32MRecommendation:
          phase32MRecommendation ?? this.phase32MRecommendation,
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
      ..writeln('# Internal Evidence Summary Layer')
      ..writeln()
      ..writeln('- version: $internalEvidenceSummaryLayerReportVersion')
      ..writeln('- summary status: ${summaryStatus.wire}')
      ..writeln('- source readiness status: ${sourceReadinessStatus.wire}')
      ..writeln('- source review status: ${sourceReviewStatus.wire}')
      ..writeln('- source refresh status: ${sourceRefreshStatus.wire}')
      ..writeln('- source validation status: ${sourceValidationStatus.wire}')
      ..writeln('- total groups: $totalGroups')
      ..writeln('- allowed group count: $allowedGroupCount')
      ..writeln('- constrained group count: $constrainedGroupCount')
      ..writeln('- blocked group count: $blockedGroupCount')
      ..writeln('- future-only group count: $futureOnlyGroupCount')
      ..writeln('- allowed record count: $allowedRecordCount')
      ..writeln('- constrained record count: $constrainedRecordCount')
      ..writeln('- blocked record count: $blockedRecordCount')
      ..writeln('- future-only record count: $futureOnlyRecordCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- safe for Phase 32M: $safeForPhase32M')
      ..writeln('- Phase 32M recommendation: ${phase32MRecommendation.wire}')
      ..writeln('- classifier output emitted: $classifierLabelsEmitted')
      ..writeln('- numeric value output emitted: $numericMoveValuesComputed')
      ..writeln('- move ordering output emitted: $moveOrderingComputed')
      ..writeln()
      ..writeln('## Summary Policy')
      ..writeln(
        '- this layer summarizes the Phase 32K refreshed evidence readiness result only',
      )
      ..writeln(
        '- allowed summaries stay internal, constrained summaries stay constrained, and blocked/future-only summaries stay inactive',
      )
      ..writeln(
        '- it does not classify, value, order, integrate, call an engine, run Android, or write files',
      )
      ..writeln()
      ..writeln('## Summary Group Table')
      ..writeln(
        '| Group | Status | Records | Packets | Scopes | Support Cases | New Phase 32E Support | Android Proof | Signals | Areas | Buckets | Safe | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final group in groups) {
      buffer.writeln(
        '| ${group.groupId.wire} | ${group.groupStatus.wire} | '
        '${_ids(group.recordIds)} | ${_ids(group.packetIds)} | '
        '${_scopeIds(group.scopeIds)} | ${_ids(group.supportCaseIds)} | '
        '${_ids(group.newlyAddedSupportCaseIds)} | '
        '${_ids(group.androidProofCaseIds)} | '
        '${_signalIds(group.activeSignalIds)} | '
        '${_areaIds(group.evidenceAreaIds)} | '
        '${_bucketIds(group.bucketIds)} | '
        '${group.safeForNextInternalLayer} | ${group.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Allowed Evidence Summary')
      ..writeln(
        '- ${_packetIdsForGroup(groups, InternalEvidenceSummaryGroupId.allowedEvidenceSummary)}',
      )
      ..writeln()
      ..writeln('## Constrained Groups')
      ..writeln('- ${_groupIds(constrainedGroups)}')
      ..writeln()
      ..writeln('## Blocked And Future-Only Groups')
      ..writeln('- ${_groupIds(blockedOrFutureGroups)}')
      ..writeln()
      ..writeln('## Support Case IDs')
      ..writeln('- ${_ids(supportCaseIds)}')
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
      ..writeln('## Phase 32M Recommendation')
      ..writeln(phase32MRecommendation.wire)
      ..writeln()
      ..writeln(
        'This summary stays internal-only. It does not emit user-facing output, compute product metrics, call the engine, run Android, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': internalEvidenceSummaryLayerReportVersion,
      'summaryStatus': summaryStatus.wire,
      'sourceReadinessStatus': sourceReadinessStatus.wire,
      'sourceReviewStatus': sourceReviewStatus.wire,
      'sourceRefreshStatus': sourceRefreshStatus.wire,
      'sourceValidationStatus': sourceValidationStatus.wire,
      'totalGroups': totalGroups,
      'allowedGroupCount': allowedGroupCount,
      'constrainedGroupCount': constrainedGroupCount,
      'blockedGroupCount': blockedGroupCount,
      'futureOnlyGroupCount': futureOnlyGroupCount,
      'allowedRecordCount': allowedRecordCount,
      'constrainedRecordCount': constrainedRecordCount,
      'blockedRecordCount': blockedRecordCount,
      'futureOnlyRecordCount': futureOnlyRecordCount,
      'unsafeCount': unsafeCount,
      'criticalCount': criticalCount,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'ownerProofQueueCount': ownerProofQueueCount,
      'safeForPhase32M': safeForPhase32M,
      'phase32MRecommendation': phase32MRecommendation.wire,
      'groups': groups.map((group) => group.toJson()).toList(),
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

class InternalEvidenceSummaryLayer {
  const InternalEvidenceSummaryLayer({
    this.validator = const InternalEvidenceSummaryLayerValidator(),
  });

  final InternalEvidenceSummaryLayerValidator validator;

  InternalEvidenceSummaryLayerResult evaluate([
    InternalEvidenceSummaryLayerRequest request =
        const InternalEvidenceSummaryLayerRequest(),
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
    final readinessResult =
        request.readinessResult ??
        request.readinessGate.evaluate(
          RefreshedPacketEvidenceReadinessGateRequest(
            reviewResult: reviewResult,
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
    final canSummarize =
        readinessResult.safeForPhase32L &&
        !readinessResult.isStrictlyBlocked &&
        !readinessResult.hasUnsafeReadinessPolicyViolation;
    final groups = canSummarize
        ? _groupsFrom(readinessResult.records)
        : const <InternalEvidenceSummaryGroup>[];
    final base = _resultFromGroups(
      readinessResult: readinessResult,
      reviewResult: reviewResult,
      refreshResult: refreshResult,
      validationResult: validationResult,
      groups: groups,
      validationFindings: const <InternalEvidenceSummaryFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromGroups(
      readinessResult: readinessResult,
      reviewResult: reviewResult,
      refreshResult: refreshResult,
      validationResult: validationResult,
      groups: groups,
      validationFindings: findings,
    );
  }
}

class InternalEvidenceSummaryLayerValidator {
  const InternalEvidenceSummaryLayerValidator();

  List<InternalEvidenceSummaryFinding> validate(
    InternalEvidenceSummaryLayerResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <InternalEvidenceSummaryFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required InternalEvidenceSummaryValidationSeverity severity,
      required String message,
      InternalEvidenceSummaryGroupId? groupId,
      String? caseId,
    }) {
      findings.add(
        InternalEvidenceSummaryFinding(
          id: id,
          severity: severity,
          message: message,
          groupId: groupId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase32M &&
        (result.sourceReadinessStatus ==
                RefreshedPacketEvidenceReadinessStatus.blockedByUnsafeReview ||
            result.unsafeCount > 0 ||
            result.groups.any((group) => group.groupStatus.isUnsafe))) {
      add(
        id: 'unsafeReadinessMarkedSummarized',
        severity: InternalEvidenceSummaryValidationSeverity.critical,
        message: 'unsafe readiness cannot be marked summarized',
      );
    }

    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: InternalEvidenceSummaryValidationSeverity.blocker,
        message: 'owner proof requires explicit PV/MultiPV reason',
      );
    }

    for (final group in result.groups) {
      if (_constrainedGroupIds.contains(group.groupId) &&
          group.groupStatus == InternalEvidenceSummaryGroupStatus.allowed) {
        add(
          id: 'constrainedGroupPromotedToAllowed',
          severity: InternalEvidenceSummaryValidationSeverity.critical,
          message: '${group.groupId.wire} must remain constrained',
          groupId: group.groupId,
        );
      }
      if (group.groupId ==
              InternalEvidenceSummaryGroupId.blockedBoundarySummary &&
          group.groupStatus != InternalEvidenceSummaryGroupStatus.blocked) {
        add(
          id: 'blockedSummaryBecameActive',
          severity: InternalEvidenceSummaryValidationSeverity.critical,
          message: 'blocked boundary summary must remain blocked',
          groupId: group.groupId,
        );
      }
      if (group.groupId == InternalEvidenceSummaryGroupId.futureOnlySummary &&
          group.groupStatus != InternalEvidenceSummaryGroupStatus.futureOnly) {
        add(
          id: 'futureOnlySummaryBecameActive',
          severity: InternalEvidenceSummaryValidationSeverity.critical,
          message: 'future-only summary must remain future-only',
          groupId: group.groupId,
        );
      }
      if (group.scopeIds.contains(
            InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
          ) &&
          (group.quietScopeActive ||
              group.groupStatus !=
                  InternalEvidenceSummaryGroupStatus.blocked)) {
        add(
          id: 'quietPreparatoryScopeActivated',
          severity: InternalEvidenceSummaryValidationSeverity.critical,
          message: 'quiet/preparatory scope must remain excluded',
          groupId: group.groupId,
        );
      }
      if (group.hasUnsafeOutput) {
        add(
          id: 'summaryGroupBoundaryPolicyViolation',
          severity: InternalEvidenceSummaryValidationSeverity.critical,
          message: '${group.groupId.wire} crossed a blocked output boundary',
          groupId: group.groupId,
        );
      }
      for (final caseId in group.androidProofCaseIds) {
        if (!_capturedAndroidProofIds.contains(caseId) ||
            !provenAndroidIds.contains(caseId)) {
          add(
            id: 'unprovenAndroidProofClaim',
            severity: InternalEvidenceSummaryValidationSeverity.critical,
            message: '${group.groupId.wire} cited unproven Android proof',
            groupId: group.groupId,
            caseId: caseId,
          );
        }
        if (_phase32ECaseIds.contains(caseId)) {
          add(
            id: 'phase32ECaseClaimedCapturedProof',
            severity: InternalEvidenceSummaryValidationSeverity.critical,
            message: 'Phase 32E case cannot be captured Android proof',
            groupId: group.groupId,
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
          severity: InternalEvidenceSummaryValidationSeverity.critical,
          message: 'summary cited unproven Android proof',
          caseId: caseId,
        );
      }
      if (_phase32ECaseIds.contains(caseId)) {
        add(
          id: 'phase32ECaseClaimedCapturedProof',
          severity: InternalEvidenceSummaryValidationSeverity.critical,
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
        id: 'summaryBoundaryPolicyViolation',
        severity: InternalEvidenceSummaryValidationSeverity.critical,
        message: 'summary crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<InternalEvidenceSummaryFinding> validateReportText(String reportText) {
    final findings = <InternalEvidenceSummaryFinding>[];
    void reportError(String id, String message) {
      findings.add(
        InternalEvidenceSummaryFinding(
          id: id,
          severity: InternalEvidenceSummaryValidationSeverity.critical,
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

List<InternalEvidenceSummaryGroup> _groupsFrom(
  List<RefreshedPacketEvidenceReadinessRecord> records,
) {
  final allowed = records
      .where((record) => record.readinessGroup.isAllowed)
      .toList(growable: false);
  final improved = records
      .where(
        (record) =>
            record.readinessGroup ==
            RefreshedPacketEvidenceReadinessGroup.improvedSupportEvidenceGroup,
      )
      .toList(growable: false);
  final watch = records
      .where(
        (record) =>
            record.readinessGroup ==
            RefreshedPacketEvidenceReadinessGroup.watchListedEvidenceGroup,
      )
      .toList(growable: false);
  final proof = records
      .where(
        (record) =>
            record.readinessGroup ==
            RefreshedPacketEvidenceReadinessGroup.proofLimitedEvidenceGroup,
      )
      .toList(growable: false);
  final warning = records
      .where(
        (record) =>
            record.readinessGroup ==
            RefreshedPacketEvidenceReadinessGroup.warningLimitedEvidenceGroup,
      )
      .toList(growable: false);
  final blocked = records
      .where((record) => record.readinessGroup.isBlocked)
      .toList(growable: false);
  final futureOnly = records
      .where((record) => record.readinessGroup.isFutureOnly)
      .toList(growable: false);
  return <InternalEvidenceSummaryGroup>[
    _groupFromRecords(
      groupId: InternalEvidenceSummaryGroupId.allowedEvidenceSummary,
      groupStatus: InternalEvidenceSummaryGroupStatus.allowed,
      records: allowed,
      recommendation: InternalEvidenceSummaryRecommendation.keepAllowedEvidence,
    ),
    _groupFromRecords(
      groupId: InternalEvidenceSummaryGroupId.improvedSupportSummary,
      groupStatus: InternalEvidenceSummaryGroupStatus.allowed,
      records: improved,
      recommendation: InternalEvidenceSummaryRecommendation.keepImprovedSupport,
    ),
    _groupFromRecords(
      groupId: InternalEvidenceSummaryGroupId.constrainedWatchListSummary,
      groupStatus: InternalEvidenceSummaryGroupStatus.constrained,
      records: watch,
      recommendation: InternalEvidenceSummaryRecommendation.keepWatchListed,
    ),
    _groupFromRecords(
      groupId: InternalEvidenceSummaryGroupId.proofLimitedSummary,
      groupStatus: InternalEvidenceSummaryGroupStatus.constrained,
      records: proof,
      recommendation: InternalEvidenceSummaryRecommendation.keepProofLimited,
    ),
    _groupFromRecords(
      groupId: InternalEvidenceSummaryGroupId.warningLimitedSummary,
      groupStatus: InternalEvidenceSummaryGroupStatus.constrained,
      records: warning,
      recommendation:
          InternalEvidenceSummaryRecommendation.keepWarningLimitedOnly,
    ),
    _groupFromRecords(
      groupId: InternalEvidenceSummaryGroupId.blockedBoundarySummary,
      groupStatus: InternalEvidenceSummaryGroupStatus.blocked,
      records: blocked,
      recommendation: InternalEvidenceSummaryRecommendation.keepBlocked,
    ),
    _groupFromRecords(
      groupId: InternalEvidenceSummaryGroupId.futureOnlySummary,
      groupStatus: InternalEvidenceSummaryGroupStatus.futureOnly,
      records: futureOnly,
      recommendation: InternalEvidenceSummaryRecommendation.keepFutureOnly,
    ),
  ];
}

InternalEvidenceSummaryGroup _groupFromRecords({
  required InternalEvidenceSummaryGroupId groupId,
  required InternalEvidenceSummaryGroupStatus groupStatus,
  required List<RefreshedPacketEvidenceReadinessRecord> records,
  required InternalEvidenceSummaryRecommendation recommendation,
}) {
  return InternalEvidenceSummaryGroup(
    groupId: groupId,
    groupStatus: groupStatus,
    recordIds: _sortedStrings(
      records.map((record) => record.readinessRecordId),
    ),
    packetIds: _sortedStrings(records.map((record) => record.packetId)),
    scopeIds: _sortedScopeIds(records.map((record) => record.scopeId)),
    supportCaseIds: _sortedStrings(
      records.expand((record) => record.supportCaseIds),
    ),
    newlyAddedSupportCaseIds: _sortedStrings(
      records.expand((record) => record.newlyAddedSupportCaseIds),
    ),
    androidProofCaseIds: _sortedStrings(
      records.expand((record) => record.androidProofCaseIds),
    ),
    activeSignalIds: _sortedSignalIds(
      records.expand((record) => record.activeSignalIds),
    ),
    evidenceAreaIds: _sortedAreaIds(
      records.expand((record) => record.evidenceAreaIds),
    ),
    bucketIds: _sortedBucketIds(records.expand((record) => record.bucketIds)),
    warningReasons: _sortedStrings(
      records.map((record) => record.warningReason),
    ),
    proofLimitReasons: _sortedStrings(
      records.map((record) => record.proofLimitReason),
    ),
    futurePrerequisites: _sortedStrings(
      records.map((record) => record.futurePrerequisite),
    ),
    blockedBoundaryIds: _sortedStrings(
      records.expand((record) => record.blockedBoundaryIds),
    ),
    safeForNextInternalLayer: records.every(
      (record) =>
          !record.readinessStatus.isUnsafe &&
          !record.hasUnsafeOutput &&
          (groupStatus == InternalEvidenceSummaryGroupStatus.allowed
              ? record.allowedForNextInternalLayer
              : !record.allowedForNextInternalLayer),
    ),
    recommendation: recommendation,
    isProductOutput: records.any((record) => record.isProductOutput),
    isClassifierLabel: records.any((record) => record.isClassifierLabel),
    isOfficialMetric: records.any((record) => record.isOfficialMetric),
    hasNumericValue: records.any((record) => record.hasNumericValue),
    ordersMoves: records.any((record) => record.ordersMoves),
    quietScopeActive: records.any((record) => record.quietScopeActive),
    cpLossComputationImplemented: records.any(
      (record) => record.cpLossComputationImplemented,
    ),
    winProbabilityComputationImplemented: records.any(
      (record) => record.winProbabilityComputationImplemented,
    ),
    emittedOutputNames: _sortedStrings(
      records.expand((record) => record.emittedOutputNames),
    ),
  );
}

InternalEvidenceSummaryLayerResult _resultFromGroups({
  required RefreshedPacketEvidenceReadinessGateResult readinessResult,
  required InternalPacketEvidenceRefreshReviewResult reviewResult,
  required InternalPacketEvidenceRefreshResult refreshResult,
  required RefreshedPacketHardeningValidationResult validationResult,
  required List<InternalEvidenceSummaryGroup> groups,
  required List<InternalEvidenceSummaryFinding> validationFindings,
}) {
  final groupUnsafeCount = groups
      .where(
        (group) =>
            group.groupStatus == InternalEvidenceSummaryGroupStatus.unsafe ||
            group.hasUnsafeOutput,
      )
      .length;
  final unsafeCount = readinessResult.unsafeCount + groupUnsafeCount;
  final criticalCount =
      readinessResult.criticalCount +
      validationFindings.where((finding) => finding.isCritical).length;
  final base = InternalEvidenceSummaryLayerResult(
    summaryStatus: InternalEvidenceSummaryLayerStatus.invalid,
    sourceReadinessStatus: readinessResult.readinessStatus,
    sourceReviewStatus: reviewResult.reviewStatus,
    sourceRefreshStatus: refreshResult.refreshStatus,
    sourceValidationStatus: validationResult.validationStatus,
    groups: groups,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...readinessResult.warnings,
      ...reviewResult.warnings,
      ...refreshResult.warnings,
      ...validationResult.warnings,
      if (groups.any(
        (group) =>
            group.groupStatus == InternalEvidenceSummaryGroupStatus.constrained,
      ))
        'constrained summaries remain visible but not allowed core output',
      if (groups.any(
        (group) =>
            group.groupId ==
            InternalEvidenceSummaryGroupId.constrainedWatchListSummary,
      ))
        'PV/MultiPV summary remains watch-listed',
      if (groups.any(
        (group) =>
            group.groupId == InternalEvidenceSummaryGroupId.proofLimitedSummary,
      ))
        'Android proof summary remains proof-limited',
    ]),
    failures: _sortedStrings(<String>[
      ...readinessResult.failures,
      ...reviewResult.failures,
      ...refreshResult.failures,
      ...validationResult.failures,
      ...validationFindings.map((finding) => finding.message),
    ]),
    totalGroups: groups.length,
    allowedGroupCount: groups
        .where(
          (group) =>
              group.groupStatus == InternalEvidenceSummaryGroupStatus.allowed,
        )
        .length,
    constrainedGroupCount: groups
        .where(
          (group) =>
              group.groupStatus ==
              InternalEvidenceSummaryGroupStatus.constrained,
        )
        .length,
    blockedGroupCount: groups
        .where(
          (group) =>
              group.groupStatus == InternalEvidenceSummaryGroupStatus.blocked,
        )
        .length,
    futureOnlyGroupCount: groups
        .where(
          (group) =>
              group.groupStatus ==
              InternalEvidenceSummaryGroupStatus.futureOnly,
        )
        .length,
    allowedRecordCount: readinessResult.allowedRecordCount,
    constrainedRecordCount: readinessResult.constrainedRecordCount,
    blockedRecordCount: readinessResult.blockedRecordCount,
    futureOnlyRecordCount: readinessResult.futureOnlyRecordCount,
    unsafeCount: unsafeCount,
    criticalCount: criticalCount,
    supportCaseIds: _sortedStrings(readinessResult.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(
      readinessResult.newlyAddedSupportCaseIds,
    ),
    androidProofCaseIds: _sortedStrings(readinessResult.androidProofCaseIds),
    ownerProofQueueCount: readinessResult.ownerProofQueueCount,
    safeForPhase32M: false,
    phase32MRecommendation: InternalEvidenceSummaryPhase32MRecommendation
        .addMoreGoldenCoverageFirst,
    productLabelsEmitted:
        readinessResult.productLabelsEmitted ||
        reviewResult.productLabelsEmitted ||
        refreshResult.productLabelsEmitted ||
        validationResult.productLabelsEmitted,
    advancedLabelsEmitted:
        readinessResult.advancedLabelsEmitted ||
        reviewResult.advancedLabelsEmitted ||
        refreshResult.advancedLabelsEmitted ||
        validationResult.advancedLabelsEmitted,
    classifierLabelsEmitted:
        readinessResult.classifierLabelsEmitted ||
        reviewResult.classifierLabelsEmitted ||
        refreshResult.classifierLabelsEmitted ||
        validationResult.classifierLabelsEmitted,
    finalMoveLabelsEmitted:
        readinessResult.finalMoveLabelsEmitted ||
        reviewResult.finalMoveLabelsEmitted ||
        refreshResult.finalMoveLabelsEmitted ||
        validationResult.finalMoveLabelsEmitted,
    officialMetricsAllowed:
        readinessResult.officialMetricsAllowed ||
        reviewResult.officialMetricsAllowed ||
        refreshResult.officialMetricsAllowed ||
        validationResult.officialMetricsAllowed,
    cpLossComputationImplemented:
        readinessResult.cpLossComputationImplemented ||
        reviewResult.cpLossComputationImplemented ||
        refreshResult.cpLossComputationImplemented ||
        validationResult.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        readinessResult.winProbabilityComputationImplemented ||
        reviewResult.winProbabilityComputationImplemented ||
        refreshResult.winProbabilityComputationImplemented ||
        validationResult.winProbabilityComputationImplemented,
    numericMoveValuesComputed:
        readinessResult.numericMoveValuesComputed ||
        reviewResult.numericMoveValuesComputed ||
        refreshResult.numericMoveValuesComputed ||
        validationResult.numericMoveValuesComputed,
    moveOrderingComputed:
        readinessResult.moveOrderingComputed ||
        reviewResult.moveOrderingComputed ||
        refreshResult.moveOrderingComputed ||
        validationResult.moveOrderingComputed,
    quietPreparatoryScopeActivated:
        readinessResult.quietPreparatoryScopeActivated ||
        reviewResult.quietPreparatoryScopeActivated ||
        refreshResult.quietPreparatoryScopeActivated ||
        validationResult.quietPreparatoryScopeActivated,
    directEngineAccessUsed:
        readinessResult.directEngineAccessUsed ||
        reviewResult.directEngineAccessUsed ||
        refreshResult.directEngineAccessUsed ||
        validationResult.directEngineAccessUsed,
    uiOutputUsed:
        readinessResult.uiOutputUsed ||
        reviewResult.uiOutputUsed ||
        refreshResult.uiOutputUsed ||
        validationResult.uiOutputUsed,
    backendOutputUsed:
        readinessResult.backendOutputUsed ||
        reviewResult.backendOutputUsed ||
        refreshResult.backendOutputUsed ||
        validationResult.backendOutputUsed,
    persistenceUsed:
        readinessResult.persistenceUsed ||
        reviewResult.persistenceUsed ||
        refreshResult.persistenceUsed ||
        validationResult.persistenceUsed,
    emittedOutputFamilies: _sortedStrings(<String>[
      ...readinessResult.emittedOutputFamilies,
      ...reviewResult.emittedOutputFamilies,
      ...refreshResult.emittedOutputFamilies,
      ...validationResult.emittedOutputFamilies,
    ]),
  );
  final status = _summaryStatusFor(base, readinessResult: readinessResult);
  final safeForPhase32M =
      (status == InternalEvidenceSummaryLayerStatus.summarizedWithWarnings ||
          status == InternalEvidenceSummaryLayerStatus.summarizedClean) &&
      readinessResult.safeForPhase32L &&
      !readinessResult.isStrictlyBlocked &&
      !readinessResult.hasUnsafeReadinessPolicyViolation &&
      unsafeCount == 0 &&
      criticalCount == 0 &&
      !validationFindings.any((finding) => finding.blocksStrict) &&
      groups.every((group) => group.safeForNextInternalLayer);
  return base.copyWith(
    summaryStatus: status,
    safeForPhase32M: safeForPhase32M,
    phase32MRecommendation: _phase32MRecommendationFor(
      status: status,
      safeForPhase32M: safeForPhase32M,
      ownerProofQueueCount: readinessResult.ownerProofQueueCount,
      constrainedGroupCount: base.constrainedGroupCount,
    ),
  );
}

InternalEvidenceSummaryLayerStatus _summaryStatusFor(
  InternalEvidenceSummaryLayerResult result, {
  required RefreshedPacketEvidenceReadinessGateResult readinessResult,
}) {
  if (readinessResult.readinessStatus ==
          RefreshedPacketEvidenceReadinessStatus.blockedByUnsafeReview ||
      readinessResult.unsafeCount > 0 ||
      result.unsafeCount > 0 ||
      result.criticalCount > 0 ||
      result.validationFindings.any((finding) => finding.isCritical)) {
    return InternalEvidenceSummaryLayerStatus.blockedByUnsafeReadiness;
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
    return InternalEvidenceSummaryLayerStatus.blockedByPolicyBoundary;
  }
  if (!readinessResult.safeForPhase32L ||
      readinessResult.isStrictlyBlocked ||
      result.validationFindings.any((finding) => finding.blocksStrict)) {
    return InternalEvidenceSummaryLayerStatus.invalid;
  }
  if (result.groups.isEmpty) {
    return InternalEvidenceSummaryLayerStatus.invalid;
  }
  if (result.constrainedGroupCount > 0) {
    return InternalEvidenceSummaryLayerStatus.summarizedWithWarnings;
  }
  return InternalEvidenceSummaryLayerStatus.summarizedClean;
}

InternalEvidenceSummaryPhase32MRecommendation _phase32MRecommendationFor({
  required InternalEvidenceSummaryLayerStatus status,
  required bool safeForPhase32M,
  required int ownerProofQueueCount,
  required int constrainedGroupCount,
}) {
  if (status == InternalEvidenceSummaryLayerStatus.blockedByUnsafeReadiness ||
      status == InternalEvidenceSummaryLayerStatus.blockedByPolicyBoundary) {
    return InternalEvidenceSummaryPhase32MRecommendation.blockedByUnsafeSummary;
  }
  if (ownerProofQueueCount > 0) {
    return InternalEvidenceSummaryPhase32MRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase32M) {
    return InternalEvidenceSummaryPhase32MRecommendation
        .addMoreGoldenCoverageFirst;
  }
  if (constrainedGroupCount > 0) {
    return InternalEvidenceSummaryPhase32MRecommendation
        .proceedToInternalEvidenceAdapterDesign;
  }
  return InternalEvidenceSummaryPhase32MRecommendation
      .proceedToSummaryValidation;
}

bool _hasExplicitPvProofReason(InternalEvidenceSummaryLayerResult result) {
  final reasons = <String>[
    ...result.groups.expand((group) => group.proofLimitReasons),
    ...result.groups.expand((group) => group.warningReasons),
    ...result.groups.expand((group) => group.futurePrerequisites),
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

String _groupIds(Iterable<InternalEvidenceSummaryGroup> groups) {
  final ids = groups.map((group) => group.groupId.wire).toSet().toList()
    ..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _packetIdsForGroup(
  Iterable<InternalEvidenceSummaryGroup> groups,
  InternalEvidenceSummaryGroupId groupId,
) {
  for (final group in groups) {
    if (group.groupId == groupId) return _ids(group.packetIds);
  }
  return '-';
}

String _scopeIds(Iterable<InternalNonLabelPrototypeScopeId> values) {
  final ids = values.map((id) => id.wire).toSet().toList()..sort();
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

List<InternalNonLabelPrototypeScopeId> _sortedScopeIds(
  Iterable<InternalNonLabelPrototypeScopeId> values,
) {
  return values.toSet().toList()..sort((a, b) => a.index.compareTo(b.index));
}

List<InternalNonLabelSignalId> _sortedSignalIds(
  Iterable<InternalNonLabelSignalId> values,
) {
  return values.toSet().toList()..sort((a, b) => a.index.compareTo(b.index));
}

List<InternalEvidenceAreaId> _sortedAreaIds(
  Iterable<InternalEvidenceAreaId> values,
) {
  return values.toSet().toList()..sort((a, b) => a.index.compareTo(b.index));
}

List<InternalEvidenceBucketId> _sortedBucketIds(
  Iterable<InternalEvidenceBucketId> values,
) {
  return values.toSet().toList()..sort((a, b) => a.index.compareTo(b.index));
}

int _compareFindings(
  InternalEvidenceSummaryFinding a,
  InternalEvidenceSummaryFinding b,
) {
  final severityCompare = b.severity.index.compareTo(a.severity.index);
  if (severityCompare != 0) return severityCompare;
  final idCompare = a.id.compareTo(b.id);
  if (idCompare != 0) return idCompare;
  final groupCompare = (a.groupId?.wire ?? '').compareTo(b.groupId?.wire ?? '');
  if (groupCompare != 0) return groupCompare;
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

const _constrainedGroupIds = <InternalEvidenceSummaryGroupId>{
  InternalEvidenceSummaryGroupId.constrainedWatchListSummary,
  InternalEvidenceSummaryGroupId.proofLimitedSummary,
  InternalEvidenceSummaryGroupId.warningLimitedSummary,
};

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

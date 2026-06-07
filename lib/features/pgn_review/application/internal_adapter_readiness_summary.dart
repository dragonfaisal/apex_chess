/// Developer-only summary for internal adapter readiness gate output.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_design.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_review.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_validation.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_summary_layer.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_evidence_readiness_gate.dart';

const internalAdapterReadinessSummaryReportVersion =
    'internal-adapter-readiness-summary-v1';

enum InternalAdapterReadinessSummaryStatus {
  summarizedWithWarnings('summarizedWithWarnings'),
  summarizedClean('summarizedClean'),
  blockedByUnsafeReadiness('blockedByUnsafeReadiness'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const InternalAdapterReadinessSummaryStatus(this.wire);

  final String wire;
}

enum InternalAdapterReadinessSummaryGroupId {
  allowedCorePacketSummary('allowedCorePacketSummary'),
  constrainedContextPacketSummary('constrainedContextPacketSummary'),
  inactiveBlockedPacketSummary('inactiveBlockedPacketSummary'),
  inactiveFutureOnlyPacketSummary('inactiveFutureOnlyPacketSummary'),
  allowedActiveOutputFieldSummary('allowedActiveOutputFieldSummary'),
  blockedOutputFieldSummary('blockedOutputFieldSummary'),
  androidProofBoundarySummary('androidProofBoundarySummary'),
  ownerProofStatusSummary('ownerProofStatusSummary');

  const InternalAdapterReadinessSummaryGroupId(this.wire);

  final String wire;
}

enum InternalAdapterReadinessSummaryItemStatus {
  allowedCorePacketSummary('allowedCorePacketSummary'),
  constrainedContextPacketSummary('constrainedContextPacketSummary'),
  inactiveBlockedPacketSummary('inactiveBlockedPacketSummary'),
  inactiveFutureOnlyPacketSummary('inactiveFutureOnlyPacketSummary'),
  allowedActiveOutputFieldSummary('allowedActiveOutputFieldSummary'),
  blockedOutputFieldSummary('blockedOutputFieldSummary'),
  androidProofBoundarySummary('androidProofBoundarySummary'),
  ownerProofStatusSummary('ownerProofStatusSummary'),
  invalid('invalid'),
  unsafe('unsafe');

  const InternalAdapterReadinessSummaryItemStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == InternalAdapterReadinessSummaryItemStatus.unsafe;
}

enum InternalAdapterReadinessSummaryRecommendation {
  keepAllowedForInternalStep('keepAllowedForInternalStep'),
  keepContextOnlyConstrained('keepContextOnlyConstrained'),
  keepBlockedInactive('keepBlockedInactive'),
  keepFutureOnlyInactive('keepFutureOnlyInactive'),
  keepOutputFieldAllowed('keepOutputFieldAllowed'),
  keepOutputFieldBlocked('keepOutputFieldBlocked'),
  summarizeOwnerProofEmpty('summarizeOwnerProofEmpty'),
  investigateSummaryFailure('investigateSummaryFailure'),
  blockUnsafeSummary('blockUnsafeSummary');

  const InternalAdapterReadinessSummaryRecommendation(this.wire);

  final String wire;
}

enum InternalAdapterReadinessSummaryPhase32SRecommendation {
  proceedToAdapterReadinessSummaryValidation(
    'proceedToAdapterReadinessSummaryValidation',
  ),
  proceedToDebugOnlyAdapterBridgeDesign(
    'proceedToDebugOnlyAdapterBridgeDesign',
  ),
  proceedToInternalAdapterReadinessSummaryReportOnly(
    'proceedToInternalAdapterReadinessSummaryReportOnly',
  ),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeAdapterSummary('blockedByUnsafeAdapterSummary');

  const InternalAdapterReadinessSummaryPhase32SRecommendation(this.wire);

  final String wire;
}

enum InternalAdapterReadinessSummarySeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const InternalAdapterReadinessSummarySeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == InternalAdapterReadinessSummarySeverity.blocker ||
      this == InternalAdapterReadinessSummarySeverity.critical;

  bool get isCritical =>
      this == InternalAdapterReadinessSummarySeverity.critical;
}

enum InternalAdapterReadinessSummaryReportFormat {
  markdown('markdown'),
  json('json');

  const InternalAdapterReadinessSummaryReportFormat(this.wire);

  final String wire;
}

class InternalAdapterReadinessSummaryRequest {
  const InternalAdapterReadinessSummaryRequest({
    this.readinessGateResult,
    this.validationResult,
    this.reviewResult,
    this.prototypeResult,
    this.designResult,
    this.summaryResult,
    this.readinessResult,
    this.readinessGate = const InternalEvidenceAdapterPrototypeReadinessGate(),
    this.validation = const InternalEvidenceAdapterPrototypeValidation(),
    this.review = const InternalEvidenceAdapterPrototypeReview(),
    this.adapterPrototype = const InternalEvidenceAdapterPrototype(),
    this.adapterDesign = const InternalEvidenceAdapterDesign(),
    this.summaryLayer = const InternalEvidenceSummaryLayer(),
    this.refreshedReadinessGate = const RefreshedPacketEvidenceReadinessGate(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const InternalAdapterReadinessSummaryRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final InternalEvidenceAdapterPrototypeReadinessGateResult?
  readinessGateResult;
  final InternalEvidenceAdapterPrototypeValidationResult? validationResult;
  final InternalEvidenceAdapterPrototypeReviewResult? reviewResult;
  final InternalEvidenceAdapterPrototypeResult? prototypeResult;
  final InternalEvidenceAdapterDesignResult? designResult;
  final InternalEvidenceSummaryLayerResult? summaryResult;
  final RefreshedPacketEvidenceReadinessGateResult? readinessResult;
  final InternalEvidenceAdapterPrototypeReadinessGate readinessGate;
  final InternalEvidenceAdapterPrototypeValidation validation;
  final InternalEvidenceAdapterPrototypeReview review;
  final InternalEvidenceAdapterPrototype adapterPrototype;
  final InternalEvidenceAdapterDesign adapterDesign;
  final InternalEvidenceSummaryLayer summaryLayer;
  final RefreshedPacketEvidenceReadinessGate refreshedReadinessGate;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class InternalAdapterReadinessSummaryGroup {
  const InternalAdapterReadinessSummaryGroup({
    required this.groupId,
    required this.summaryStatus,
    required this.packetIds,
    required this.sourceSummaryGroupIds,
    required this.activeOutputFieldIds,
    required this.blockedOutputFieldIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.futurePrerequisites,
    required this.blockedBoundaryIds,
    required this.safeForNextInternalStep,
    required this.recommendation,
  });

  final InternalAdapterReadinessSummaryGroupId groupId;
  final InternalAdapterReadinessSummaryItemStatus summaryStatus;
  final List<String> packetIds;
  final List<InternalEvidenceSummaryGroupId> sourceSummaryGroupIds;
  final List<String> activeOutputFieldIds;
  final List<String> blockedOutputFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> futurePrerequisites;
  final List<String> blockedBoundaryIds;
  final bool safeForNextInternalStep;
  final InternalAdapterReadinessSummaryRecommendation recommendation;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'groupId': groupId.wire,
      'summaryStatus': summaryStatus.wire,
      'packetIds': packetIds,
      'sourceSummaryGroupIds': sourceSummaryGroupIds
          .map((id) => id.wire)
          .toList(),
      'activeOutputFieldIds': activeOutputFieldIds,
      'blockedOutputFieldIds': blockedOutputFieldIds,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'futurePrerequisites': futurePrerequisites,
      'blockedBoundaryIds': blockedBoundaryIds,
      'safeForNextInternalStep': safeForNextInternalStep,
      'recommendation': recommendation.wire,
    };
  }
}

class InternalAdapterReadinessSummaryRecord {
  const InternalAdapterReadinessSummaryRecord({
    required this.summaryRecordId,
    required this.sourceReadinessRecordId,
    required this.adapterPacketId,
    required this.adapterRole,
    required this.readinessStatus,
    required this.summaryStatus,
    required this.allowedForNextInternalStep,
    required this.constrainedForContextOnly,
    required this.inactiveBoundary,
    required this.sourceSummaryGroupIds,
    required this.activeOutputFieldIds,
    required this.blockedOutputFieldIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.warningReason,
    required this.proofLimitReason,
    required this.futurePrerequisite,
    required this.recommendation,
    this.isProductOutput = false,
    this.isClassifierLabel = false,
    this.isOfficialMetric = false,
    this.hasNumericScore = false,
    this.ranksMoves = false,
    this.callsEngine = false,
    this.writesPersistence = false,
    this.targetsUi = false,
    this.cpLossOutputActive = false,
    this.winProbabilityOutputActive = false,
    this.quietPreparatoryScopeActive = false,
    this.backendOutputActive = false,
  });

  final String summaryRecordId;
  final String sourceReadinessRecordId;
  final String adapterPacketId;
  final InternalEvidenceAdapterPacketRole adapterRole;
  final InternalEvidenceAdapterPrototypeReadinessItemStatus readinessStatus;
  final InternalAdapterReadinessSummaryItemStatus summaryStatus;
  final bool allowedForNextInternalStep;
  final bool constrainedForContextOnly;
  final bool inactiveBoundary;
  final List<InternalEvidenceSummaryGroupId> sourceSummaryGroupIds;
  final List<String> activeOutputFieldIds;
  final List<String> blockedOutputFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final String warningReason;
  final String proofLimitReason;
  final String futurePrerequisite;
  final InternalAdapterReadinessSummaryRecommendation recommendation;
  final bool isProductOutput;
  final bool isClassifierLabel;
  final bool isOfficialMetric;
  final bool hasNumericScore;
  final bool ranksMoves;
  final bool callsEngine;
  final bool writesPersistence;
  final bool targetsUi;
  final bool cpLossOutputActive;
  final bool winProbabilityOutputActive;
  final bool quietPreparatoryScopeActive;
  final bool backendOutputActive;

  bool get hasBlockedActiveField =>
      activeOutputFieldIds.any(_isBlockedOutputFieldId);

  bool get hasUnsafeOutput {
    return isProductOutput ||
        isClassifierLabel ||
        isOfficialMetric ||
        hasNumericScore ||
        ranksMoves ||
        callsEngine ||
        writesPersistence ||
        targetsUi ||
        cpLossOutputActive ||
        winProbabilityOutputActive ||
        quietPreparatoryScopeActive ||
        backendOutputActive ||
        hasBlockedActiveField;
  }

  InternalAdapterReadinessSummaryRecord copyWith({
    String? summaryRecordId,
    String? sourceReadinessRecordId,
    String? adapterPacketId,
    InternalEvidenceAdapterPacketRole? adapterRole,
    InternalEvidenceAdapterPrototypeReadinessItemStatus? readinessStatus,
    InternalAdapterReadinessSummaryItemStatus? summaryStatus,
    bool? allowedForNextInternalStep,
    bool? constrainedForContextOnly,
    bool? inactiveBoundary,
    List<InternalEvidenceSummaryGroupId>? sourceSummaryGroupIds,
    List<String>? activeOutputFieldIds,
    List<String>? blockedOutputFieldIds,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    String? warningReason,
    String? proofLimitReason,
    String? futurePrerequisite,
    InternalAdapterReadinessSummaryRecommendation? recommendation,
    bool? isProductOutput,
    bool? isClassifierLabel,
    bool? isOfficialMetric,
    bool? hasNumericScore,
    bool? ranksMoves,
    bool? callsEngine,
    bool? writesPersistence,
    bool? targetsUi,
    bool? cpLossOutputActive,
    bool? winProbabilityOutputActive,
    bool? quietPreparatoryScopeActive,
    bool? backendOutputActive,
  }) {
    return InternalAdapterReadinessSummaryRecord(
      summaryRecordId: summaryRecordId ?? this.summaryRecordId,
      sourceReadinessRecordId:
          sourceReadinessRecordId ?? this.sourceReadinessRecordId,
      adapterPacketId: adapterPacketId ?? this.adapterPacketId,
      adapterRole: adapterRole ?? this.adapterRole,
      readinessStatus: readinessStatus ?? this.readinessStatus,
      summaryStatus: summaryStatus ?? this.summaryStatus,
      allowedForNextInternalStep:
          allowedForNextInternalStep ?? this.allowedForNextInternalStep,
      constrainedForContextOnly:
          constrainedForContextOnly ?? this.constrainedForContextOnly,
      inactiveBoundary: inactiveBoundary ?? this.inactiveBoundary,
      sourceSummaryGroupIds:
          sourceSummaryGroupIds ?? this.sourceSummaryGroupIds,
      activeOutputFieldIds: activeOutputFieldIds ?? this.activeOutputFieldIds,
      blockedOutputFieldIds:
          blockedOutputFieldIds ?? this.blockedOutputFieldIds,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      warningReason: warningReason ?? this.warningReason,
      proofLimitReason: proofLimitReason ?? this.proofLimitReason,
      futurePrerequisite: futurePrerequisite ?? this.futurePrerequisite,
      recommendation: recommendation ?? this.recommendation,
      isProductOutput: isProductOutput ?? this.isProductOutput,
      isClassifierLabel: isClassifierLabel ?? this.isClassifierLabel,
      isOfficialMetric: isOfficialMetric ?? this.isOfficialMetric,
      hasNumericScore: hasNumericScore ?? this.hasNumericScore,
      ranksMoves: ranksMoves ?? this.ranksMoves,
      callsEngine: callsEngine ?? this.callsEngine,
      writesPersistence: writesPersistence ?? this.writesPersistence,
      targetsUi: targetsUi ?? this.targetsUi,
      cpLossOutputActive: cpLossOutputActive ?? this.cpLossOutputActive,
      winProbabilityOutputActive:
          winProbabilityOutputActive ?? this.winProbabilityOutputActive,
      quietPreparatoryScopeActive:
          quietPreparatoryScopeActive ?? this.quietPreparatoryScopeActive,
      backendOutputActive: backendOutputActive ?? this.backendOutputActive,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'summaryRecordId': summaryRecordId,
      'sourceReadinessRecordId': sourceReadinessRecordId,
      'adapterPacketId': adapterPacketId,
      'adapterRole': adapterRole.wire,
      'readinessStatus': readinessStatus.wire,
      'summaryStatus': summaryStatus.wire,
      'allowedForNextInternalStep': allowedForNextInternalStep,
      'constrainedForContextOnly': constrainedForContextOnly,
      'inactiveBoundary': inactiveBoundary,
      'sourceSummaryGroupIds': sourceSummaryGroupIds
          .map((id) => id.wire)
          .toList(),
      'activeOutputFieldIds': activeOutputFieldIds,
      'blockedOutputFieldIds': blockedOutputFieldIds,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'warningReason': warningReason,
      'proofLimitReason': proofLimitReason,
      'futurePrerequisite': futurePrerequisite,
      'recommendation': recommendation.wire,
      'isProductOutput': isProductOutput,
      'isClassifierLabel': isClassifierLabel,
      'isOfficialMetric': isOfficialMetric,
      'hasNumericScore': hasNumericScore,
      'ranksMoves': ranksMoves,
      'callsEngine': callsEngine,
      'writesPersistence': writesPersistence,
      'targetsUi': targetsUi,
      'cpLossOutputActive': cpLossOutputActive,
      'winProbabilityOutputActive': winProbabilityOutputActive,
      'quietPreparatoryScopeActive': quietPreparatoryScopeActive,
      'backendOutputActive': backendOutputActive,
    };
  }
}

class InternalAdapterReadinessSummaryFinding {
  const InternalAdapterReadinessSummaryFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.summaryRecordId,
    this.adapterPacketId,
    this.groupId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final InternalAdapterReadinessSummarySeverity severity;
  final String message;
  final String? summaryRecordId;
  final String? adapterPacketId;
  final InternalEvidenceSummaryGroupId? groupId;
  final String? fieldId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical => severity.isCritical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (summaryRecordId != null) 'summaryRecordId': summaryRecordId,
      if (adapterPacketId != null) 'adapterPacketId': adapterPacketId,
      if (groupId != null) 'groupId': groupId!.wire,
      if (fieldId != null) 'fieldId': fieldId,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class InternalAdapterReadinessSummaryResult {
  const InternalAdapterReadinessSummaryResult({
    required this.summaryStatus,
    required this.sourceReadinessGateStatus,
    required this.sourceValidationStatus,
    required this.sourceReviewStatus,
    required this.sourcePrototypeStatus,
    required this.sourceDesignStatus,
    required this.groups,
    required this.records,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalGroups,
    required this.totalRecords,
    required this.allowedCorePacketCount,
    required this.constrainedContextPacketCount,
    required this.inactiveBlockedPacketCount,
    required this.inactiveFutureOnlyPacketCount,
    required this.allowedActiveOutputFieldCount,
    required this.blockedOutputFieldCount,
    required this.unsafeCount,
    required this.blockerCount,
    required this.criticalCount,
    required this.ownerProofQueueCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.activeOutputFieldIds,
    required this.blockedOutputFieldIds,
    required this.safeForPhase32S,
    required this.phase32SRecommendation,
    this.developerOnly = true,
    this.productOutputActive = false,
    this.classifierOutputActive = false,
    this.finalMoveLabelOutputActive = false,
    this.officialMetricOutputActive = false,
    this.cpLossOutputActive = false,
    this.winProbabilityOutputActive = false,
    this.numericOutputActive = false,
    this.moveRankingOutputActive = false,
    this.quietPreparatoryScopeActivated = false,
    this.engineCallsActive = false,
    this.persistenceWritesActive = false,
    this.uiTargetsActive = false,
    this.backendOutputActive = false,
  });

  final InternalAdapterReadinessSummaryStatus summaryStatus;
  final InternalEvidenceAdapterPrototypeReadinessGateStatus
  sourceReadinessGateStatus;
  final InternalEvidenceAdapterPrototypeValidationStatus sourceValidationStatus;
  final InternalEvidenceAdapterPrototypeReviewStatus sourceReviewStatus;
  final InternalEvidenceAdapterPrototypeStatus sourcePrototypeStatus;
  final InternalEvidenceAdapterDesignStatus sourceDesignStatus;
  final List<InternalAdapterReadinessSummaryGroup> groups;
  final List<InternalAdapterReadinessSummaryRecord> records;
  final List<InternalAdapterReadinessSummaryFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalGroups;
  final int totalRecords;
  final int allowedCorePacketCount;
  final int constrainedContextPacketCount;
  final int inactiveBlockedPacketCount;
  final int inactiveFutureOnlyPacketCount;
  final int allowedActiveOutputFieldCount;
  final int blockedOutputFieldCount;
  final int unsafeCount;
  final int blockerCount;
  final int criticalCount;
  final int ownerProofQueueCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> activeOutputFieldIds;
  final List<String> blockedOutputFieldIds;
  final bool safeForPhase32S;
  final InternalAdapterReadinessSummaryPhase32SRecommendation
  phase32SRecommendation;
  final bool developerOnly;
  final bool productOutputActive;
  final bool classifierOutputActive;
  final bool finalMoveLabelOutputActive;
  final bool officialMetricOutputActive;
  final bool cpLossOutputActive;
  final bool winProbabilityOutputActive;
  final bool numericOutputActive;
  final bool moveRankingOutputActive;
  final bool quietPreparatoryScopeActivated;
  final bool engineCallsActive;
  final bool persistenceWritesActive;
  final bool uiTargetsActive;
  final bool backendOutputActive;

  bool get isStrictlyBlocked =>
      summaryStatus ==
          InternalAdapterReadinessSummaryStatus.blockedByUnsafeReadiness ||
      summaryStatus ==
          InternalAdapterReadinessSummaryStatus.blockedByPolicyBoundary ||
      summaryStatus == InternalAdapterReadinessSummaryStatus.invalid ||
      !safeForPhase32S ||
      unsafeCount > 0 ||
      blockerCount > 0 ||
      criticalCount > 0 ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeAdapterSummaryPolicyViolation {
    return summaryStatus ==
            InternalAdapterReadinessSummaryStatus.blockedByUnsafeReadiness ||
        sourceReadinessGateStatus ==
            InternalEvidenceAdapterPrototypeReadinessGateStatus
                .blockedByValidationFailure ||
        unsafeCount > 0 ||
        criticalCount > 0 ||
        validationFindings.any((finding) => finding.isCritical) ||
        records.any(
          (record) => record.hasUnsafeOutput || record.summaryStatus.isUnsafe,
        ) ||
        activeOutputFieldIds.any(_isBlockedOutputFieldId) ||
        productOutputActive ||
        classifierOutputActive ||
        finalMoveLabelOutputActive ||
        officialMetricOutputActive ||
        cpLossOutputActive ||
        winProbabilityOutputActive ||
        numericOutputActive ||
        moveRankingOutputActive ||
        quietPreparatoryScopeActivated ||
        engineCallsActive ||
        persistenceWritesActive ||
        uiTargetsActive ||
        backendOutputActive;
  }

  InternalAdapterReadinessSummaryRecord record(String summaryRecordId) {
    return records.singleWhere(
      (record) => record.summaryRecordId == summaryRecordId,
    );
  }

  InternalAdapterReadinessSummaryRecord recordForPacket(
    String adapterPacketId,
  ) {
    return records.singleWhere(
      (record) => record.adapterPacketId == adapterPacketId,
    );
  }

  InternalAdapterReadinessSummaryRecord recordForGroup(
    InternalEvidenceSummaryGroupId groupId,
  ) {
    return records.singleWhere(
      (record) => record.sourceSummaryGroupIds.contains(groupId),
    );
  }

  InternalAdapterReadinessSummaryGroup summaryGroup(
    InternalAdapterReadinessSummaryGroupId groupId,
  ) {
    return groups.singleWhere((group) => group.groupId == groupId);
  }

  List<InternalAdapterReadinessSummaryRecord> get allowedCoreRecords => records
      .where((record) => record.allowedForNextInternalStep)
      .toList(growable: false);

  List<InternalAdapterReadinessSummaryRecord> get constrainedContextRecords =>
      records
          .where((record) => record.constrainedForContextOnly)
          .toList(growable: false);

  List<InternalAdapterReadinessSummaryRecord> get inactiveBoundaryRecords =>
      records
          .where((record) => record.inactiveBoundary)
          .toList(growable: false);

  InternalAdapterReadinessSummaryResult copyWith({
    InternalAdapterReadinessSummaryStatus? summaryStatus,
    InternalEvidenceAdapterPrototypeReadinessGateStatus?
    sourceReadinessGateStatus,
    InternalEvidenceAdapterPrototypeValidationStatus? sourceValidationStatus,
    InternalEvidenceAdapterPrototypeReviewStatus? sourceReviewStatus,
    InternalEvidenceAdapterPrototypeStatus? sourcePrototypeStatus,
    InternalEvidenceAdapterDesignStatus? sourceDesignStatus,
    List<InternalAdapterReadinessSummaryGroup>? groups,
    List<InternalAdapterReadinessSummaryRecord>? records,
    List<InternalAdapterReadinessSummaryFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalGroups,
    int? totalRecords,
    int? allowedCorePacketCount,
    int? constrainedContextPacketCount,
    int? inactiveBlockedPacketCount,
    int? inactiveFutureOnlyPacketCount,
    int? allowedActiveOutputFieldCount,
    int? blockedOutputFieldCount,
    int? unsafeCount,
    int? blockerCount,
    int? criticalCount,
    int? ownerProofQueueCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? activeOutputFieldIds,
    List<String>? blockedOutputFieldIds,
    bool? safeForPhase32S,
    InternalAdapterReadinessSummaryPhase32SRecommendation?
    phase32SRecommendation,
    bool? developerOnly,
    bool? productOutputActive,
    bool? classifierOutputActive,
    bool? finalMoveLabelOutputActive,
    bool? officialMetricOutputActive,
    bool? cpLossOutputActive,
    bool? winProbabilityOutputActive,
    bool? numericOutputActive,
    bool? moveRankingOutputActive,
    bool? quietPreparatoryScopeActivated,
    bool? engineCallsActive,
    bool? persistenceWritesActive,
    bool? uiTargetsActive,
    bool? backendOutputActive,
  }) {
    return InternalAdapterReadinessSummaryResult(
      summaryStatus: summaryStatus ?? this.summaryStatus,
      sourceReadinessGateStatus:
          sourceReadinessGateStatus ?? this.sourceReadinessGateStatus,
      sourceValidationStatus:
          sourceValidationStatus ?? this.sourceValidationStatus,
      sourceReviewStatus: sourceReviewStatus ?? this.sourceReviewStatus,
      sourcePrototypeStatus:
          sourcePrototypeStatus ?? this.sourcePrototypeStatus,
      sourceDesignStatus: sourceDesignStatus ?? this.sourceDesignStatus,
      groups: groups ?? this.groups,
      records: records ?? this.records,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalGroups: totalGroups ?? this.totalGroups,
      totalRecords: totalRecords ?? this.totalRecords,
      allowedCorePacketCount:
          allowedCorePacketCount ?? this.allowedCorePacketCount,
      constrainedContextPacketCount:
          constrainedContextPacketCount ?? this.constrainedContextPacketCount,
      inactiveBlockedPacketCount:
          inactiveBlockedPacketCount ?? this.inactiveBlockedPacketCount,
      inactiveFutureOnlyPacketCount:
          inactiveFutureOnlyPacketCount ?? this.inactiveFutureOnlyPacketCount,
      allowedActiveOutputFieldCount:
          allowedActiveOutputFieldCount ?? this.allowedActiveOutputFieldCount,
      blockedOutputFieldCount:
          blockedOutputFieldCount ?? this.blockedOutputFieldCount,
      unsafeCount: unsafeCount ?? this.unsafeCount,
      blockerCount: blockerCount ?? this.blockerCount,
      criticalCount: criticalCount ?? this.criticalCount,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      activeOutputFieldIds: activeOutputFieldIds ?? this.activeOutputFieldIds,
      blockedOutputFieldIds:
          blockedOutputFieldIds ?? this.blockedOutputFieldIds,
      safeForPhase32S: safeForPhase32S ?? this.safeForPhase32S,
      phase32SRecommendation:
          phase32SRecommendation ?? this.phase32SRecommendation,
      developerOnly: developerOnly ?? this.developerOnly,
      productOutputActive: productOutputActive ?? this.productOutputActive,
      classifierOutputActive:
          classifierOutputActive ?? this.classifierOutputActive,
      finalMoveLabelOutputActive:
          finalMoveLabelOutputActive ?? this.finalMoveLabelOutputActive,
      officialMetricOutputActive:
          officialMetricOutputActive ?? this.officialMetricOutputActive,
      cpLossOutputActive: cpLossOutputActive ?? this.cpLossOutputActive,
      winProbabilityOutputActive:
          winProbabilityOutputActive ?? this.winProbabilityOutputActive,
      numericOutputActive: numericOutputActive ?? this.numericOutputActive,
      moveRankingOutputActive:
          moveRankingOutputActive ?? this.moveRankingOutputActive,
      quietPreparatoryScopeActivated:
          quietPreparatoryScopeActivated ?? this.quietPreparatoryScopeActivated,
      engineCallsActive: engineCallsActive ?? this.engineCallsActive,
      persistenceWritesActive:
          persistenceWritesActive ?? this.persistenceWritesActive,
      uiTargetsActive: uiTargetsActive ?? this.uiTargetsActive,
      backendOutputActive: backendOutputActive ?? this.backendOutputActive,
    );
  }

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Internal Adapter Readiness Summary')
      ..writeln()
      ..writeln('- version: $internalAdapterReadinessSummaryReportVersion')
      ..writeln('- summary status: ${summaryStatus.wire}')
      ..writeln(
        '- source readiness gate status: ${sourceReadinessGateStatus.wire}',
      )
      ..writeln('- source validation status: ${sourceValidationStatus.wire}')
      ..writeln('- source review status: ${sourceReviewStatus.wire}')
      ..writeln('- source prototype status: ${sourcePrototypeStatus.wire}')
      ..writeln('- source design status: ${sourceDesignStatus.wire}')
      ..writeln('- total groups: $totalGroups')
      ..writeln('- total records: $totalRecords')
      ..writeln('- allowed core packet count: $allowedCorePacketCount')
      ..writeln(
        '- constrained context packet count: $constrainedContextPacketCount',
      )
      ..writeln('- inactive blocked packet count: $inactiveBlockedPacketCount')
      ..writeln(
        '- inactive future-only packet count: $inactiveFutureOnlyPacketCount',
      )
      ..writeln(
        '- allowed active output field count: $allowedActiveOutputFieldCount',
      )
      ..writeln('- blocked output field count: $blockedOutputFieldCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- safe for Phase 32S: $safeForPhase32S')
      ..writeln('- Phase 32S recommendation: ${phase32SRecommendation.wire}')
      ..writeln()
      ..writeln('## Summary Policy')
      ..writeln(
        '- this layer summarizes Phase 32Q internal adapter readiness only',
      )
      ..writeln('- allowed core packets remain internal-only')
      ..writeln(
        '- context-only packets stay constrained; blocked and future-only packets stay inactive',
      )
      ..writeln()
      ..writeln('## Summary Group Table')
      ..writeln(
        '| Group | Status | Packets | Source Groups | Active Fields | Blocked Fields | Support Cases | Android Proof | Blocked Boundaries | Safe | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final group in groups) {
      buffer.writeln(
        '| ${group.groupId.wire} | '
        '${group.summaryStatus.wire} | '
        '${_ids(group.packetIds)} | '
        '${_groupIds(group.sourceSummaryGroupIds)} | '
        '${_ids(group.activeOutputFieldIds)} | '
        '${_ids(group.blockedOutputFieldIds)} | '
        '${_ids(group.supportCaseIds)} | '
        '${_ids(group.androidProofCaseIds)} | '
        '${_ids(group.blockedBoundaryIds)} | '
        '${group.safeForNextInternalStep} | '
        '${group.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Summary Record Table')
      ..writeln(
        '| Summary Record | Readiness Record | Packet | Groups | Role | Readiness Status | Summary Status | Allowed | Constrained | Inactive | Active Fields | Blocked Fields | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final record in records) {
      buffer.writeln(
        '| ${_cell(record.summaryRecordId)} | '
        '${_cell(record.sourceReadinessRecordId)} | '
        '${_cell(record.adapterPacketId)} | '
        '${_groupIds(record.sourceSummaryGroupIds)} | '
        '${record.adapterRole.wire} | '
        '${record.readinessStatus.wire} | '
        '${record.summaryStatus.wire} | '
        '${record.allowedForNextInternalStep} | '
        '${record.constrainedForContextOnly} | '
        '${record.inactiveBoundary} | '
        '${_ids(record.activeOutputFieldIds)} | '
        '${_ids(record.blockedOutputFieldIds)} | '
        '${record.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Allowed Core Packet Summary')
      ..writeln('- ${_recordIds(allowedCoreRecords)}')
      ..writeln()
      ..writeln('## Constrained Context Packet Summary')
      ..writeln('- ${_recordIds(constrainedContextRecords)}')
      ..writeln()
      ..writeln('## Inactive Blocked And Future-Only Summaries')
      ..writeln('- ${_recordIds(inactiveBoundaryRecords)}')
      ..writeln()
      ..writeln('## Active Output Field Summary')
      ..writeln('- ${_ids(activeOutputFieldIds)}')
      ..writeln()
      ..writeln('## Blocked Output Field Summary')
      ..writeln('- ${_ids(blockedOutputFieldIds)}')
      ..writeln()
      ..writeln('## Android Proof Boundary Summary')
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
      ..writeln('## Phase 32S Recommendation')
      ..writeln(phase32SRecommendation.wire)
      ..writeln()
      ..writeln(
        'This internal adapter readiness summary is developer-only. It does not emit active product labels, compute values, order moves, call the engine, run Android, target UI, integrate with backend or persistence, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': internalAdapterReadinessSummaryReportVersion,
      'summaryStatus': summaryStatus.wire,
      'sourceReadinessGateStatus': sourceReadinessGateStatus.wire,
      'sourceValidationStatus': sourceValidationStatus.wire,
      'sourceReviewStatus': sourceReviewStatus.wire,
      'sourcePrototypeStatus': sourcePrototypeStatus.wire,
      'sourceDesignStatus': sourceDesignStatus.wire,
      'totalGroups': totalGroups,
      'totalRecords': totalRecords,
      'allowedCorePacketCount': allowedCorePacketCount,
      'constrainedContextPacketCount': constrainedContextPacketCount,
      'inactiveBlockedPacketCount': inactiveBlockedPacketCount,
      'inactiveFutureOnlyPacketCount': inactiveFutureOnlyPacketCount,
      'allowedActiveOutputFieldCount': allowedActiveOutputFieldCount,
      'blockedOutputFieldCount': blockedOutputFieldCount,
      'unsafeCount': unsafeCount,
      'blockerCount': blockerCount,
      'criticalCount': criticalCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'activeOutputFieldIds': activeOutputFieldIds,
      'blockedOutputFieldIds': blockedOutputFieldIds,
      'safeForPhase32S': safeForPhase32S,
      'phase32SRecommendation': phase32SRecommendation.wire,
      'groups': groups.map((group) => group.toJson()).toList(),
      'records': records.map((record) => record.toJson()).toList(),
      'validationFindings': validationFindings
          .map((finding) => finding.toJson())
          .toList(),
      'warnings': warnings,
      'failures': failures,
      'developerOnly': developerOnly,
      'productOutputActive': productOutputActive,
      'classifierOutputActive': classifierOutputActive,
      'finalMoveLabelOutputActive': finalMoveLabelOutputActive,
      'officialMetricOutputActive': officialMetricOutputActive,
      'cpLossOutputActive': cpLossOutputActive,
      'winProbabilityOutputActive': winProbabilityOutputActive,
      'numericOutputActive': numericOutputActive,
      'moveRankingOutputActive': moveRankingOutputActive,
      'quietPreparatoryScopeActivated': quietPreparatoryScopeActivated,
      'engineCallsActive': engineCallsActive,
      'persistenceWritesActive': persistenceWritesActive,
      'uiTargetsActive': uiTargetsActive,
      'backendOutputActive': backendOutputActive,
    };
  }
}

class InternalAdapterReadinessSummary {
  const InternalAdapterReadinessSummary({
    this.validator = const InternalAdapterReadinessSummaryValidator(),
  });

  final InternalAdapterReadinessSummaryValidator validator;

  InternalAdapterReadinessSummaryResult evaluate([
    InternalAdapterReadinessSummaryRequest request =
        const InternalAdapterReadinessSummaryRequest(),
  ]) {
    final refreshedReadiness =
        request.readinessResult ?? request.refreshedReadinessGate.evaluate();
    final summaryLayerResult =
        request.summaryResult ??
        request.summaryLayer.evaluate(
          InternalEvidenceSummaryLayerRequest(
            readinessResult: refreshedReadiness,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final designResult =
        request.designResult ??
        request.adapterDesign.evaluate(
          InternalEvidenceAdapterDesignRequest(
            summaryResult: summaryLayerResult,
            readinessResult: refreshedReadiness,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final prototypeResult =
        request.prototypeResult ??
        request.adapterPrototype.evaluate(
          InternalEvidenceAdapterPrototypeRequest(
            designResult: designResult,
            summaryResult: summaryLayerResult,
            readinessResult: refreshedReadiness,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final reviewResult =
        request.reviewResult ??
        request.review.evaluate(
          InternalEvidenceAdapterPrototypeReviewRequest(
            prototypeResult: prototypeResult,
            designResult: designResult,
            summaryResult: summaryLayerResult,
            readinessResult: refreshedReadiness,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final validationResult =
        request.validationResult ??
        request.validation.evaluate(
          InternalEvidenceAdapterPrototypeValidationRequest(
            reviewResult: reviewResult,
            prototypeResult: prototypeResult,
            designResult: designResult,
            summaryResult: summaryLayerResult,
            readinessResult: refreshedReadiness,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final readinessGateResult =
        request.readinessGateResult ??
        request.readinessGate.evaluate(
          InternalEvidenceAdapterPrototypeReadinessGateRequest(
            validationResult: validationResult,
            reviewResult: reviewResult,
            prototypeResult: prototypeResult,
            designResult: designResult,
            summaryResult: summaryLayerResult,
            readinessResult: refreshedReadiness,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final records = _recordsFromReadiness(readinessGateResult);
    final groups = _groupsFromRecords(readinessGateResult, records);
    final base = _resultFromRecordsAndGroups(
      readinessGateResult: readinessGateResult,
      validationResult: validationResult,
      reviewResult: reviewResult,
      prototypeResult: prototypeResult,
      designResult: designResult,
      records: records,
      groups: groups,
      validationFindings: const <InternalAdapterReadinessSummaryFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromRecordsAndGroups(
      readinessGateResult: readinessGateResult,
      validationResult: validationResult,
      reviewResult: reviewResult,
      prototypeResult: prototypeResult,
      designResult: designResult,
      records: records,
      groups: groups,
      validationFindings: findings,
    );
  }
}

class InternalAdapterReadinessSummaryValidator {
  const InternalAdapterReadinessSummaryValidator();

  List<InternalAdapterReadinessSummaryFinding> validate(
    InternalAdapterReadinessSummaryResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <InternalAdapterReadinessSummaryFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required InternalAdapterReadinessSummarySeverity severity,
      required String message,
      String? summaryRecordId,
      String? adapterPacketId,
      InternalEvidenceSummaryGroupId? groupId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        InternalAdapterReadinessSummaryFinding(
          id: id,
          severity: severity,
          message: message,
          summaryRecordId: summaryRecordId,
          adapterPacketId: adapterPacketId,
          groupId: groupId,
          fieldId: fieldId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase32S &&
        (result.sourceReadinessGateStatus ==
                InternalEvidenceAdapterPrototypeReadinessGateStatus
                    .blockedByValidationFailure ||
            result.sourceReadinessGateStatus ==
                InternalEvidenceAdapterPrototypeReadinessGateStatus
                    .blockedByPolicyBoundary ||
            result.unsafeCount > 0)) {
      add(
        id: 'unsafeReadinessMarkedSummarized',
        severity: InternalAdapterReadinessSummarySeverity.critical,
        message: 'unsafe adapter readiness cannot be summarized as safe',
      );
    }

    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: InternalAdapterReadinessSummarySeverity.blocker,
        message: 'owner proof requires explicit PV/MultiPV reason',
      );
    }

    for (final fieldId in _blockedOutputFieldIds) {
      if (!result.blockedOutputFieldIds.contains(fieldId)) {
        add(
          id: 'blockedOutputFieldMissing',
          severity: InternalAdapterReadinessSummarySeverity.blocker,
          message: '$fieldId must remain a blocked output field',
          fieldId: fieldId,
        );
      }
    }

    for (final record in result.records) {
      for (final fieldId in record.activeOutputFieldIds) {
        _checkActiveField(
          add,
          fieldId,
          summaryRecordId: record.summaryRecordId,
          adapterPacketId: record.adapterPacketId,
          groupId: _firstGroupId(record),
        );
      }
      if (record.allowedForNextInternalStep &&
          !record.sourceSummaryGroupIds.every(_coreGroupIds.contains)) {
        add(
          id: 'corePacketFromNonCoreSource',
          severity: InternalAdapterReadinessSummarySeverity.critical,
          message: '${record.adapterPacketId} has a non-core source',
          summaryRecordId: record.summaryRecordId,
          adapterPacketId: record.adapterPacketId,
          groupId: _firstGroupId(record),
        );
      }
      if (_contextOnlyGroupIds.any(record.sourceSummaryGroupIds.contains) &&
          record.allowedForNextInternalStep) {
        add(
          id: 'contextOnlyPacketPromotedToAllowedCore',
          severity: InternalAdapterReadinessSummarySeverity.critical,
          message: '${record.adapterPacketId} promoted context-only evidence',
          summaryRecordId: record.summaryRecordId,
          adapterPacketId: record.adapterPacketId,
          groupId: _firstGroupId(record),
        );
      }
      if (_blockedGroupIds.any(record.sourceSummaryGroupIds.contains) &&
          !_recordIsInactiveSafe(record)) {
        add(
          id: 'blockedPacketMadeActive',
          severity: InternalAdapterReadinessSummarySeverity.critical,
          message: '${record.adapterPacketId} must remain inactive',
          summaryRecordId: record.summaryRecordId,
          adapterPacketId: record.adapterPacketId,
          groupId: _firstGroupId(record),
        );
      }
      if (record.sourceSummaryGroupIds.contains(
            InternalEvidenceSummaryGroupId.futureOnlySummary,
          ) &&
          !_recordIsInactiveSafe(record)) {
        add(
          id: 'futureOnlyPacketMadeActive',
          severity: InternalAdapterReadinessSummarySeverity.critical,
          message: '${record.adapterPacketId} must remain future-only',
          summaryRecordId: record.summaryRecordId,
          adapterPacketId: record.adapterPacketId,
          groupId: _firstGroupId(record),
        );
      }
      if (record.isProductOutput) {
        add(
          id: 'productOutputActive',
          severity: InternalAdapterReadinessSummarySeverity.critical,
          message: 'summary packet cannot be product output',
          summaryRecordId: record.summaryRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.isClassifierLabel) {
        add(
          id: 'classifierLabelOutputActive',
          severity: InternalAdapterReadinessSummarySeverity.critical,
          message: 'summary packet cannot emit classifier labels',
          summaryRecordId: record.summaryRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.isOfficialMetric) {
        add(
          id: 'officialMetricOutputActive',
          severity: InternalAdapterReadinessSummarySeverity.critical,
          message: 'summary packet cannot emit official metrics',
          summaryRecordId: record.summaryRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.hasNumericScore) {
        add(
          id: 'numericScoreOutputActive',
          severity: InternalAdapterReadinessSummarySeverity.critical,
          message: 'summary packet cannot emit numeric move values',
          summaryRecordId: record.summaryRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.ranksMoves) {
        add(
          id: 'moveRankingOutputActive',
          severity: InternalAdapterReadinessSummarySeverity.critical,
          message: 'summary packet cannot order moves',
          summaryRecordId: record.summaryRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.cpLossOutputActive || record.winProbabilityOutputActive) {
        add(
          id: 'futureMetricOutputActive',
          severity: InternalAdapterReadinessSummarySeverity.critical,
          message: 'summary packet cannot activate CP-loss or win probability',
          summaryRecordId: record.summaryRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.quietPreparatoryScopeActive) {
        add(
          id: 'quietPreparatoryScopeActivated',
          severity: InternalAdapterReadinessSummarySeverity.critical,
          message: 'quiet/preparatory scope must remain excluded',
          summaryRecordId: record.summaryRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.callsEngine) {
        add(
          id: 'engineCallFlagActive',
          severity: InternalAdapterReadinessSummarySeverity.critical,
          message: 'summary packet cannot call an engine',
          summaryRecordId: record.summaryRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.writesPersistence) {
        add(
          id: 'persistenceWriteFlagActive',
          severity: InternalAdapterReadinessSummarySeverity.critical,
          message: 'summary packet cannot write persistence',
          summaryRecordId: record.summaryRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.targetsUi) {
        add(
          id: 'uiTargetFlagActive',
          severity: InternalAdapterReadinessSummarySeverity.critical,
          message: 'summary packet cannot target UI',
          summaryRecordId: record.summaryRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.backendOutputActive) {
        add(
          id: 'backendOutputActive',
          severity: InternalAdapterReadinessSummarySeverity.critical,
          message: 'summary packet cannot target backend output',
          summaryRecordId: record.summaryRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      for (final caseId in record.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          summaryRecordId: record.summaryRecordId,
          adapterPacketId: record.adapterPacketId,
          groupId: _firstGroupId(record),
        );
      }
    }

    for (final fieldId in result.activeOutputFieldIds) {
      _checkActiveField(add, fieldId);
    }
    for (final caseId in result.androidProofCaseIds) {
      _checkAndroidProofCase(add, caseId, provenAndroidIds);
    }

    if (result.productOutputActive ||
        result.classifierOutputActive ||
        result.finalMoveLabelOutputActive ||
        result.officialMetricOutputActive ||
        result.cpLossOutputActive ||
        result.winProbabilityOutputActive ||
        result.numericOutputActive ||
        result.moveRankingOutputActive ||
        result.quietPreparatoryScopeActivated ||
        result.engineCallsActive ||
        result.persistenceWritesActive ||
        result.uiTargetsActive ||
        result.backendOutputActive) {
      add(
        id: 'boundaryFlagActive',
        severity: InternalAdapterReadinessSummarySeverity.critical,
        message: 'summary result has an active product or integration flag',
      );
    }

    findings.sort(_compareFindings);
    return findings;
  }

  List<InternalAdapterReadinessSummaryFinding> validateReportText(
    String reportText,
  ) {
    final findings = <InternalAdapterReadinessSummaryFinding>[];
    final text = reportText.toLowerCase();
    void add(String id, String message) {
      findings.add(
        InternalAdapterReadinessSummaryFinding(
          id: id,
          severity: InternalAdapterReadinessSummarySeverity.critical,
          message: message,
        ),
      );
    }

    if (text.contains('uciok') ||
        text.contains('readyok') ||
        text.contains('bestmove ') ||
        text.contains('info depth')) {
      add('rawUciReportText', 'report must not contain raw UCI logs');
    }
    if (RegExp(r'\bpv\s+[a-h][1-8][a-h][1-8]').hasMatch(text) ||
        text.contains('pvmoves')) {
      add('rawPvReportText', 'report must not contain PV dumps');
    }
    for (final fieldId in _blockedOutputFieldIds) {
      if (text.contains('active $fieldId'.toLowerCase()) ||
          text.contains('active fields: $fieldId'.toLowerCase()) ||
          text.contains('$fieldId active'.toLowerCase())) {
        add(
          'activeBlockedFieldReportText',
          '$fieldId cannot appear as active output',
        );
      }
    }
    return findings;
  }

  void _checkActiveField(
    void Function({
      required String id,
      required InternalAdapterReadinessSummarySeverity severity,
      required String message,
      String? summaryRecordId,
      String? adapterPacketId,
      InternalEvidenceSummaryGroupId? groupId,
      String? fieldId,
      String? caseId,
    })
    add,
    String fieldId, {
    String? summaryRecordId,
    String? adapterPacketId,
    InternalEvidenceSummaryGroupId? groupId,
  }) {
    if (!_isBlockedOutputFieldId(fieldId)) return;
    add(
      id: 'activeBlockedOutputField',
      severity: InternalAdapterReadinessSummarySeverity.critical,
      message: '$fieldId cannot be an active summary output field',
      summaryRecordId: summaryRecordId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
    if (fieldId == 'productLabel') {
      add(
        id: 'productOutputActive',
        severity: InternalAdapterReadinessSummarySeverity.critical,
        message: 'product label field cannot be active',
        summaryRecordId: summaryRecordId,
        adapterPacketId: adapterPacketId,
        groupId: groupId,
        fieldId: fieldId,
      );
    }
    if (fieldId == 'finalMoveLabel' ||
        fieldId == 'brilliantGreatMissStyleLabels' ||
        fieldId == 'bestGoodInaccuracyMistakeBlunderStyleLabels') {
      add(
        id: 'classifierLabelOutputActive',
        severity: InternalAdapterReadinessSummarySeverity.critical,
        message: 'classifier or final label field cannot be active',
        summaryRecordId: summaryRecordId,
        adapterPacketId: adapterPacketId,
        groupId: groupId,
        fieldId: fieldId,
      );
    }
    if (fieldId == 'numericMoveScore') {
      add(
        id: 'numericScoreOutputActive',
        severity: InternalAdapterReadinessSummarySeverity.critical,
        message: 'numeric move value field cannot be active',
        summaryRecordId: summaryRecordId,
        adapterPacketId: adapterPacketId,
        groupId: groupId,
        fieldId: fieldId,
      );
    }
    if (fieldId == 'moveRanking') {
      add(
        id: 'moveRankingOutputActive',
        severity: InternalAdapterReadinessSummarySeverity.critical,
        message: 'move ordering field cannot be active',
        summaryRecordId: summaryRecordId,
        adapterPacketId: adapterPacketId,
        groupId: groupId,
        fieldId: fieldId,
      );
    }
    if (fieldId == 'officialAccuracy' || fieldId == 'acpl') {
      add(
        id: 'officialMetricOutputActive',
        severity: InternalAdapterReadinessSummarySeverity.critical,
        message: 'official metric field cannot be active',
        summaryRecordId: summaryRecordId,
        adapterPacketId: adapterPacketId,
        groupId: groupId,
        fieldId: fieldId,
      );
    }
    if (fieldId == 'cpLoss' || fieldId == 'winProbability') {
      add(
        id: 'futureMetricOutputActive',
        severity: InternalAdapterReadinessSummarySeverity.critical,
        message: 'future metric field cannot be active',
        summaryRecordId: summaryRecordId,
        adapterPacketId: adapterPacketId,
        groupId: groupId,
        fieldId: fieldId,
      );
    }
    if (fieldId == 'uiOutputFields') {
      add(
        id: 'uiTargetFlagActive',
        severity: InternalAdapterReadinessSummarySeverity.critical,
        message: 'UI field cannot be active',
        summaryRecordId: summaryRecordId,
        adapterPacketId: adapterPacketId,
        groupId: groupId,
        fieldId: fieldId,
      );
    }
    if (fieldId == 'backendPersistenceFields') {
      add(
        id: 'persistenceWriteFlagActive',
        severity: InternalAdapterReadinessSummarySeverity.critical,
        message: 'backend or persistence field cannot be active',
        summaryRecordId: summaryRecordId,
        adapterPacketId: adapterPacketId,
        groupId: groupId,
        fieldId: fieldId,
      );
    }
    if (fieldId == 'directEngineCallFields') {
      add(
        id: 'engineCallFlagActive',
        severity: InternalAdapterReadinessSummarySeverity.critical,
        message: 'direct engine call field cannot be active',
        summaryRecordId: summaryRecordId,
        adapterPacketId: adapterPacketId,
        groupId: groupId,
        fieldId: fieldId,
      );
    }
  }

  void _checkAndroidProofCase(
    void Function({
      required String id,
      required InternalAdapterReadinessSummarySeverity severity,
      required String message,
      String? summaryRecordId,
      String? adapterPacketId,
      InternalEvidenceSummaryGroupId? groupId,
      String? fieldId,
      String? caseId,
    })
    add,
    String caseId,
    List<String> provenAndroidIds, {
    String? summaryRecordId,
    String? adapterPacketId,
    InternalEvidenceSummaryGroupId? groupId,
  }) {
    if (_phase32ECaseIds.contains(caseId)) {
      add(
        id: 'phase32ECaseClaimedCapturedProof',
        severity: InternalAdapterReadinessSummarySeverity.critical,
        message: '$caseId cannot be treated as captured Android proof',
        summaryRecordId: summaryRecordId,
        adapterPacketId: adapterPacketId,
        groupId: groupId,
        caseId: caseId,
      );
    }
    if (!_capturedAndroidProofIds.contains(caseId) ||
        !provenAndroidIds.contains(caseId)) {
      add(
        id: 'unprovenAndroidProofClaim',
        severity: InternalAdapterReadinessSummarySeverity.critical,
        message: '$caseId is not captured Android proof for summary',
        summaryRecordId: summaryRecordId,
        adapterPacketId: adapterPacketId,
        groupId: groupId,
        caseId: caseId,
      );
    }
  }
}

List<InternalAdapterReadinessSummaryRecord> _recordsFromReadiness(
  InternalEvidenceAdapterPrototypeReadinessGateResult readinessGateResult,
) {
  return readinessGateResult.records
      .map(_recordFromReadinessRecord)
      .toList(growable: false);
}

InternalAdapterReadinessSummaryRecord _recordFromReadinessRecord(
  InternalEvidenceAdapterPrototypeReadinessRecord record,
) {
  final status = _recordStatusFor(record);
  final allowed =
      status ==
          InternalAdapterReadinessSummaryItemStatus.allowedCorePacketSummary &&
      record.allowedForNextInternalLayer &&
      !record.hasUnsafeOutput;
  final constrained =
      status ==
          InternalAdapterReadinessSummaryItemStatus
              .constrainedContextPacketSummary &&
      record.constrainedForContextOnly &&
      !record.hasUnsafeOutput;
  final inactive =
      (status ==
              InternalAdapterReadinessSummaryItemStatus
                  .inactiveBlockedPacketSummary ||
          status ==
              InternalAdapterReadinessSummaryItemStatus
                  .inactiveFutureOnlyPacketSummary) &&
      record.inactiveBoundary &&
      !record.hasUnsafeOutput;
  return InternalAdapterReadinessSummaryRecord(
    summaryRecordId: 'summary-${record.adapterPacketId}',
    sourceReadinessRecordId: record.readinessRecordId,
    adapterPacketId: record.adapterPacketId,
    adapterRole: record.adapterRole,
    readinessStatus: record.readinessStatus,
    summaryStatus: status,
    allowedForNextInternalStep: allowed,
    constrainedForContextOnly: constrained,
    inactiveBoundary: inactive,
    sourceSummaryGroupIds: _sortedGroupIds(record.sourceSummaryGroupIds),
    activeOutputFieldIds: _sortedStrings(record.activeOutputFieldIds),
    blockedOutputFieldIds: _sortedStrings(record.blockedOutputFieldIds),
    supportCaseIds: _sortedStrings(record.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(record.newlyAddedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(record.androidProofCaseIds),
    warningReason: record.warningReason,
    proofLimitReason: record.proofLimitReason,
    futurePrerequisite: _sortedStrings(record.futurePrerequisites).join('; '),
    recommendation: _recommendationFor(status),
    isProductOutput: record.isProductOutput,
    isClassifierLabel: record.isClassifierLabel,
    isOfficialMetric: record.isOfficialMetric,
    hasNumericScore: record.hasNumericScore,
    ranksMoves: record.ranksMoves,
    callsEngine: record.callsEngine,
    writesPersistence: record.writesPersistence,
    targetsUi: record.targetsUi,
    cpLossOutputActive: record.cpLossOutputActive,
    winProbabilityOutputActive: record.winProbabilityOutputActive,
    quietPreparatoryScopeActive: record.quietPreparatoryScopeActive,
    backendOutputActive: record.backendOutputActive,
  );
}

InternalAdapterReadinessSummaryItemStatus _recordStatusFor(
  InternalEvidenceAdapterPrototypeReadinessRecord record,
) {
  if (record.hasUnsafeOutput || record.readinessStatus.isUnsafe) {
    return InternalAdapterReadinessSummaryItemStatus.unsafe;
  }
  if (record.readinessStatus ==
      InternalEvidenceAdapterPrototypeReadinessItemStatus.invalid) {
    return InternalAdapterReadinessSummaryItemStatus.invalid;
  }
  if (record.allowedForNextInternalLayer &&
      record.readinessStatus ==
          InternalEvidenceAdapterPrototypeReadinessItemStatus
              .allowedCorePacket) {
    return InternalAdapterReadinessSummaryItemStatus.allowedCorePacketSummary;
  }
  if (record.constrainedForContextOnly &&
      record.readinessStatus ==
          InternalEvidenceAdapterPrototypeReadinessItemStatus
              .constrainedContextOnlyPacket) {
    return InternalAdapterReadinessSummaryItemStatus
        .constrainedContextPacketSummary;
  }
  if (record.inactiveBoundary &&
      record.readinessStatus ==
          InternalEvidenceAdapterPrototypeReadinessItemStatus
              .inactiveBlockedPacket) {
    return InternalAdapterReadinessSummaryItemStatus
        .inactiveBlockedPacketSummary;
  }
  if (record.inactiveBoundary &&
      record.readinessStatus ==
          InternalEvidenceAdapterPrototypeReadinessItemStatus
              .inactiveFutureOnlyPacket) {
    return InternalAdapterReadinessSummaryItemStatus
        .inactiveFutureOnlyPacketSummary;
  }
  return InternalAdapterReadinessSummaryItemStatus.invalid;
}

InternalAdapterReadinessSummaryRecommendation _recommendationFor(
  InternalAdapterReadinessSummaryItemStatus status,
) {
  return switch (status) {
    InternalAdapterReadinessSummaryItemStatus.allowedCorePacketSummary =>
      InternalAdapterReadinessSummaryRecommendation.keepAllowedForInternalStep,
    InternalAdapterReadinessSummaryItemStatus.constrainedContextPacketSummary =>
      InternalAdapterReadinessSummaryRecommendation.keepContextOnlyConstrained,
    InternalAdapterReadinessSummaryItemStatus.inactiveBlockedPacketSummary =>
      InternalAdapterReadinessSummaryRecommendation.keepBlockedInactive,
    InternalAdapterReadinessSummaryItemStatus.inactiveFutureOnlyPacketSummary =>
      InternalAdapterReadinessSummaryRecommendation.keepFutureOnlyInactive,
    InternalAdapterReadinessSummaryItemStatus.allowedActiveOutputFieldSummary =>
      InternalAdapterReadinessSummaryRecommendation.keepOutputFieldAllowed,
    InternalAdapterReadinessSummaryItemStatus.blockedOutputFieldSummary =>
      InternalAdapterReadinessSummaryRecommendation.keepOutputFieldBlocked,
    InternalAdapterReadinessSummaryItemStatus.androidProofBoundarySummary ||
    InternalAdapterReadinessSummaryItemStatus.ownerProofStatusSummary =>
      InternalAdapterReadinessSummaryRecommendation.summarizeOwnerProofEmpty,
    InternalAdapterReadinessSummaryItemStatus.invalid =>
      InternalAdapterReadinessSummaryRecommendation.investigateSummaryFailure,
    InternalAdapterReadinessSummaryItemStatus.unsafe =>
      InternalAdapterReadinessSummaryRecommendation.blockUnsafeSummary,
  };
}

List<InternalAdapterReadinessSummaryGroup> _groupsFromRecords(
  InternalEvidenceAdapterPrototypeReadinessGateResult readinessGateResult,
  List<InternalAdapterReadinessSummaryRecord> records,
) {
  final allowed = records
      .where(
        (record) =>
            record.summaryStatus ==
            InternalAdapterReadinessSummaryItemStatus.allowedCorePacketSummary,
      )
      .toList(growable: false);
  final constrained = records
      .where(
        (record) =>
            record.summaryStatus ==
            InternalAdapterReadinessSummaryItemStatus
                .constrainedContextPacketSummary,
      )
      .toList(growable: false);
  final blocked = records
      .where(
        (record) =>
            record.summaryStatus ==
            InternalAdapterReadinessSummaryItemStatus
                .inactiveBlockedPacketSummary,
      )
      .toList(growable: false);
  final future = records
      .where(
        (record) =>
            record.summaryStatus ==
            InternalAdapterReadinessSummaryItemStatus
                .inactiveFutureOnlyPacketSummary,
      )
      .toList(growable: false);
  final activeBlockedFields = _sortedStrings(
    readinessGateResult.activeOutputFieldIds.where(_isBlockedOutputFieldId),
  );
  return <InternalAdapterReadinessSummaryGroup>[
    _group(
      groupId: InternalAdapterReadinessSummaryGroupId.allowedCorePacketSummary,
      summaryStatus:
          InternalAdapterReadinessSummaryItemStatus.allowedCorePacketSummary,
      records: allowed,
      safeForNextInternalStep:
          allowed.length == 2 &&
          allowed.every((record) => record.allowedForNextInternalStep),
      recommendation: InternalAdapterReadinessSummaryRecommendation
          .keepAllowedForInternalStep,
    ),
    _group(
      groupId: InternalAdapterReadinessSummaryGroupId
          .constrainedContextPacketSummary,
      summaryStatus: InternalAdapterReadinessSummaryItemStatus
          .constrainedContextPacketSummary,
      records: constrained,
      safeForNextInternalStep:
          constrained.length == 3 &&
          constrained.every((record) => record.constrainedForContextOnly),
      recommendation: InternalAdapterReadinessSummaryRecommendation
          .keepContextOnlyConstrained,
    ),
    _group(
      groupId:
          InternalAdapterReadinessSummaryGroupId.inactiveBlockedPacketSummary,
      summaryStatus: InternalAdapterReadinessSummaryItemStatus
          .inactiveBlockedPacketSummary,
      records: blocked,
      safeForNextInternalStep:
          blocked.length == 1 &&
          blocked.every((record) => record.inactiveBoundary),
      recommendation:
          InternalAdapterReadinessSummaryRecommendation.keepBlockedInactive,
    ),
    _group(
      groupId: InternalAdapterReadinessSummaryGroupId
          .inactiveFutureOnlyPacketSummary,
      summaryStatus: InternalAdapterReadinessSummaryItemStatus
          .inactiveFutureOnlyPacketSummary,
      records: future,
      safeForNextInternalStep:
          future.length == 1 &&
          future.every((record) => record.inactiveBoundary),
      recommendation:
          InternalAdapterReadinessSummaryRecommendation.keepFutureOnlyInactive,
    ),
    InternalAdapterReadinessSummaryGroup(
      groupId: InternalAdapterReadinessSummaryGroupId
          .allowedActiveOutputFieldSummary,
      summaryStatus: InternalAdapterReadinessSummaryItemStatus
          .allowedActiveOutputFieldSummary,
      packetIds: const <String>[],
      sourceSummaryGroupIds: _sortedGroupIds(
        records.expand((record) => record.sourceSummaryGroupIds),
      ),
      activeOutputFieldIds: _sortedStrings(
        readinessGateResult.activeOutputFieldIds,
      ),
      blockedOutputFieldIds: const <String>[],
      supportCaseIds: _sortedStrings(readinessGateResult.supportCaseIds),
      newlyAddedSupportCaseIds: _sortedStrings(
        readinessGateResult.newlyAddedSupportCaseIds,
      ),
      androidProofCaseIds: _sortedStrings(
        readinessGateResult.androidProofCaseIds,
      ),
      warningReasons: _sortedStrings(readinessGateResult.warnings),
      proofLimitReasons: _sortedStrings(
        records.map((record) => record.proofLimitReason),
      ),
      futurePrerequisites: _sortedStrings(
        records.map((record) => record.futurePrerequisite),
      ),
      blockedBoundaryIds: const <String>[],
      safeForNextInternalStep:
          activeBlockedFields.isEmpty &&
          !readinessGateResult.hasUnsafeAdapterReadinessPolicyViolation,
      recommendation:
          InternalAdapterReadinessSummaryRecommendation.keepOutputFieldAllowed,
    ),
    InternalAdapterReadinessSummaryGroup(
      groupId: InternalAdapterReadinessSummaryGroupId.blockedOutputFieldSummary,
      summaryStatus:
          InternalAdapterReadinessSummaryItemStatus.blockedOutputFieldSummary,
      packetIds: const <String>[],
      sourceSummaryGroupIds: const <InternalEvidenceSummaryGroupId>[],
      activeOutputFieldIds: const <String>[],
      blockedOutputFieldIds: _sortedStrings(
        readinessGateResult.blockedOutputFieldIds,
      ),
      supportCaseIds: const <String>[],
      newlyAddedSupportCaseIds: const <String>[],
      androidProofCaseIds: const <String>[],
      warningReasons: const <String>[
        'blocked output fields remain explicit denials',
      ],
      proofLimitReasons: const <String>[],
      futurePrerequisites: const <String>[],
      blockedBoundaryIds: _sortedStrings(
        readinessGateResult.blockedOutputFieldIds,
      ),
      safeForNextInternalStep:
          activeBlockedFields.isEmpty &&
          _blockedOutputFieldIds.every(
            readinessGateResult.blockedOutputFieldIds.contains,
          ),
      recommendation:
          InternalAdapterReadinessSummaryRecommendation.keepOutputFieldBlocked,
    ),
    InternalAdapterReadinessSummaryGroup(
      groupId:
          InternalAdapterReadinessSummaryGroupId.androidProofBoundarySummary,
      summaryStatus:
          InternalAdapterReadinessSummaryItemStatus.androidProofBoundarySummary,
      packetIds: const <String>[],
      sourceSummaryGroupIds: const <InternalEvidenceSummaryGroupId>[],
      activeOutputFieldIds: const <String>[],
      blockedOutputFieldIds: const <String>[],
      supportCaseIds: const <String>[],
      newlyAddedSupportCaseIds: const <String>[],
      androidProofCaseIds: _sortedStrings(
        readinessGateResult.androidProofCaseIds,
      ),
      warningReasons: const <String>[
        'Android proof boundary remains limited to captured proof IDs',
      ],
      proofLimitReasons: const <String>['captured Android proof only'],
      futurePrerequisites: const <String>[],
      blockedBoundaryIds: const <String>[],
      safeForNextInternalStep:
          readinessGateResult.androidProofCaseIds.length == 3 &&
          _capturedAndroidProofIds.every(
            readinessGateResult.androidProofCaseIds.contains,
          ) &&
          !readinessGateResult.androidProofCaseIds.any(
            _phase32ECaseIds.contains,
          ),
      recommendation: InternalAdapterReadinessSummaryRecommendation
          .summarizeOwnerProofEmpty,
    ),
    InternalAdapterReadinessSummaryGroup(
      groupId: InternalAdapterReadinessSummaryGroupId.ownerProofStatusSummary,
      summaryStatus:
          InternalAdapterReadinessSummaryItemStatus.ownerProofStatusSummary,
      packetIds: const <String>[],
      sourceSummaryGroupIds: const <InternalEvidenceSummaryGroupId>[],
      activeOutputFieldIds: const <String>[],
      blockedOutputFieldIds: const <String>[],
      supportCaseIds: const <String>[],
      newlyAddedSupportCaseIds: const <String>[],
      androidProofCaseIds: const <String>[],
      warningReasons: readinessGateResult.ownerProofQueueCount == 0
          ? const <String>['owner proof queue remains empty']
          : const <String>['owner proof requires explicit PV/MultiPV reason'],
      proofLimitReasons: const <String>[],
      futurePrerequisites: const <String>[],
      blockedBoundaryIds: const <String>[],
      safeForNextInternalStep: readinessGateResult.ownerProofQueueCount == 0,
      recommendation: InternalAdapterReadinessSummaryRecommendation
          .summarizeOwnerProofEmpty,
    ),
  ];
}

InternalAdapterReadinessSummaryGroup _group({
  required InternalAdapterReadinessSummaryGroupId groupId,
  required InternalAdapterReadinessSummaryItemStatus summaryStatus,
  required List<InternalAdapterReadinessSummaryRecord> records,
  required bool safeForNextInternalStep,
  required InternalAdapterReadinessSummaryRecommendation recommendation,
}) {
  return InternalAdapterReadinessSummaryGroup(
    groupId: groupId,
    summaryStatus: summaryStatus,
    packetIds: _sortedStrings(records.map((record) => record.adapterPacketId)),
    sourceSummaryGroupIds: _sortedGroupIds(
      records.expand((record) => record.sourceSummaryGroupIds),
    ),
    activeOutputFieldIds: _sortedStrings(
      records.expand((record) => record.activeOutputFieldIds),
    ),
    blockedOutputFieldIds: _sortedStrings(
      records.expand((record) => record.blockedOutputFieldIds),
    ),
    supportCaseIds: _sortedStrings(
      records.expand((record) => record.supportCaseIds),
    ),
    newlyAddedSupportCaseIds: _sortedStrings(
      records.expand((record) => record.newlyAddedSupportCaseIds),
    ),
    androidProofCaseIds: _sortedStrings(
      records.expand((record) => record.androidProofCaseIds),
    ),
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
      records
          .where((record) => record.inactiveBoundary)
          .map((record) => record.adapterPacketId),
    ),
    safeForNextInternalStep: safeForNextInternalStep,
    recommendation: recommendation,
  );
}

InternalAdapterReadinessSummaryResult _resultFromRecordsAndGroups({
  required InternalEvidenceAdapterPrototypeReadinessGateResult
  readinessGateResult,
  required InternalEvidenceAdapterPrototypeValidationResult validationResult,
  required InternalEvidenceAdapterPrototypeReviewResult reviewResult,
  required InternalEvidenceAdapterPrototypeResult prototypeResult,
  required InternalEvidenceAdapterDesignResult designResult,
  required List<InternalAdapterReadinessSummaryRecord> records,
  required List<InternalAdapterReadinessSummaryGroup> groups,
  required List<InternalAdapterReadinessSummaryFinding> validationFindings,
}) {
  final unsafeCount =
      readinessGateResult.unsafeCount +
      records
          .where(
            (record) =>
                record.hasUnsafeOutput ||
                record.summaryStatus ==
                    InternalAdapterReadinessSummaryItemStatus.unsafe,
          )
          .length;
  final blockerCount =
      readinessGateResult.blockerCount +
      validationFindings
          .where(
            (finding) =>
                finding.severity ==
                InternalAdapterReadinessSummarySeverity.blocker,
          )
          .length;
  final criticalCount =
      readinessGateResult.criticalCount +
      validationFindings.where((finding) => finding.isCritical).length;
  final activeOutputFieldIds = _sortedStrings(
    records.expand((record) => record.activeOutputFieldIds),
  );
  final base = InternalAdapterReadinessSummaryResult(
    summaryStatus: InternalAdapterReadinessSummaryStatus.invalid,
    sourceReadinessGateStatus: readinessGateResult.readinessStatus,
    sourceValidationStatus: validationResult.validationStatus,
    sourceReviewStatus: reviewResult.reviewStatus,
    sourcePrototypeStatus: prototypeResult.prototypeStatus,
    sourceDesignStatus: designResult.designStatus,
    groups: groups,
    records: records,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...readinessGateResult.warnings,
      if (records.any((record) => record.constrainedForContextOnly))
        'constrained context summaries remain outside allowed core output',
      if (records.any((record) => record.inactiveBoundary))
        'blocked and future-only summaries remain inactive',
      if (readinessGateResult.ownerProofQueueCount == 0)
        'owner proof summary remains empty',
    ]),
    failures: _sortedStrings(<String>[
      ...readinessGateResult.failures,
      ...validationFindings.map((finding) => finding.message),
    ]),
    totalGroups: groups.length,
    totalRecords: records.length,
    allowedCorePacketCount: records
        .where((record) => record.allowedForNextInternalStep)
        .length,
    constrainedContextPacketCount: records
        .where((record) => record.constrainedForContextOnly)
        .length,
    inactiveBlockedPacketCount: records
        .where(
          (record) =>
              record.summaryStatus ==
              InternalAdapterReadinessSummaryItemStatus
                  .inactiveBlockedPacketSummary,
        )
        .length,
    inactiveFutureOnlyPacketCount: records
        .where(
          (record) =>
              record.summaryStatus ==
              InternalAdapterReadinessSummaryItemStatus
                  .inactiveFutureOnlyPacketSummary,
        )
        .length,
    allowedActiveOutputFieldCount:
        readinessGateResult.activeOutputFieldIds.length,
    blockedOutputFieldCount: readinessGateResult.blockedOutputFieldIds.length,
    unsafeCount: unsafeCount,
    blockerCount: blockerCount,
    criticalCount: criticalCount,
    ownerProofQueueCount: readinessGateResult.ownerProofQueueCount,
    supportCaseIds: _sortedStrings(readinessGateResult.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(
      readinessGateResult.newlyAddedSupportCaseIds,
    ),
    androidProofCaseIds: _sortedStrings(
      readinessGateResult.androidProofCaseIds,
    ),
    activeOutputFieldIds: activeOutputFieldIds,
    blockedOutputFieldIds: _sortedStrings(
      readinessGateResult.blockedOutputFieldIds,
    ),
    safeForPhase32S: false,
    phase32SRecommendation:
        InternalAdapterReadinessSummaryPhase32SRecommendation
            .blockedByUnsafeAdapterSummary,
    developerOnly: readinessGateResult.developerOnly,
    productOutputActive: readinessGateResult.productOutputActive,
    classifierOutputActive: readinessGateResult.classifierOutputActive,
    finalMoveLabelOutputActive: readinessGateResult.finalMoveLabelOutputActive,
    officialMetricOutputActive: readinessGateResult.officialMetricOutputActive,
    cpLossOutputActive: readinessGateResult.cpLossOutputActive,
    winProbabilityOutputActive: readinessGateResult.winProbabilityOutputActive,
    numericOutputActive: readinessGateResult.numericOutputActive,
    moveRankingOutputActive: readinessGateResult.moveRankingOutputActive,
    quietPreparatoryScopeActivated:
        readinessGateResult.quietPreparatoryScopeActivated,
    engineCallsActive: readinessGateResult.engineCallsActive,
    persistenceWritesActive: readinessGateResult.persistenceWritesActive,
    uiTargetsActive: readinessGateResult.uiTargetsActive,
    backendOutputActive: readinessGateResult.backendOutputActive,
  );
  final status = _summaryStatusFor(base, readinessGateResult);
  final safeForPhase32S =
      status == InternalAdapterReadinessSummaryStatus.summarizedWithWarnings ||
      status == InternalAdapterReadinessSummaryStatus.summarizedClean;
  return base.copyWith(
    summaryStatus: status,
    safeForPhase32S: safeForPhase32S,
    phase32SRecommendation: _phase32SRecommendationFor(
      status: status,
      safeForPhase32S: safeForPhase32S,
      ownerProofQueueCount: readinessGateResult.ownerProofQueueCount,
    ),
  );
}

InternalAdapterReadinessSummaryStatus _summaryStatusFor(
  InternalAdapterReadinessSummaryResult result,
  InternalEvidenceAdapterPrototypeReadinessGateResult readinessGateResult,
) {
  if (result.productOutputActive ||
      result.classifierOutputActive ||
      result.finalMoveLabelOutputActive ||
      result.officialMetricOutputActive ||
      result.cpLossOutputActive ||
      result.winProbabilityOutputActive ||
      result.numericOutputActive ||
      result.moveRankingOutputActive ||
      result.quietPreparatoryScopeActivated ||
      result.engineCallsActive ||
      result.persistenceWritesActive ||
      result.uiTargetsActive ||
      result.backendOutputActive ||
      result.activeOutputFieldIds.any(_isBlockedOutputFieldId)) {
    return InternalAdapterReadinessSummaryStatus.blockedByPolicyBoundary;
  }
  if (readinessGateResult.readinessStatus ==
          InternalEvidenceAdapterPrototypeReadinessGateStatus
              .blockedByValidationFailure ||
      readinessGateResult.unsafeCount > 0 ||
      result.unsafeCount > 0 ||
      readinessGateResult.hasUnsafeAdapterReadinessPolicyViolation) {
    return InternalAdapterReadinessSummaryStatus.blockedByUnsafeReadiness;
  }
  if (!readinessGateResult.safeForPhase32R ||
      readinessGateResult.isStrictlyBlocked ||
      result.records.any(
        (record) =>
            record.summaryStatus ==
            InternalAdapterReadinessSummaryItemStatus.invalid,
      ) ||
      result.groups.any((group) => !group.safeForNextInternalStep) ||
      result.blockerCount > 0 ||
      result.criticalCount > 0 ||
      result.validationFindings.any((finding) => finding.blocksStrict)) {
    return InternalAdapterReadinessSummaryStatus.invalid;
  }
  if (result.records.isEmpty || result.groups.isEmpty) {
    return InternalAdapterReadinessSummaryStatus.invalid;
  }
  if (result.constrainedContextPacketCount > 0 || result.warnings.isNotEmpty) {
    return InternalAdapterReadinessSummaryStatus.summarizedWithWarnings;
  }
  return InternalAdapterReadinessSummaryStatus.summarizedClean;
}

InternalAdapterReadinessSummaryPhase32SRecommendation
_phase32SRecommendationFor({
  required InternalAdapterReadinessSummaryStatus status,
  required bool safeForPhase32S,
  required int ownerProofQueueCount,
}) {
  if (status ==
          InternalAdapterReadinessSummaryStatus.blockedByUnsafeReadiness ||
      status == InternalAdapterReadinessSummaryStatus.blockedByPolicyBoundary) {
    return InternalAdapterReadinessSummaryPhase32SRecommendation
        .blockedByUnsafeAdapterSummary;
  }
  if (ownerProofQueueCount > 0) {
    return InternalAdapterReadinessSummaryPhase32SRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase32S) {
    return InternalAdapterReadinessSummaryPhase32SRecommendation
        .addMoreGoldenCoverageFirst;
  }
  return InternalAdapterReadinessSummaryPhase32SRecommendation
      .proceedToAdapterReadinessSummaryValidation;
}

bool _hasExplicitPvProofReason(InternalAdapterReadinessSummaryResult result) {
  final reasons = <String>[
    ...result.warnings,
    ...result.failures,
    ...result.records.map((record) => record.warningReason),
    ...result.records.map((record) => record.proofLimitReason),
    ...result.records.map((record) => record.futurePrerequisite),
  ].join(' ').toLowerCase();
  return reasons.contains('pv') || reasons.contains('multipv');
}

bool _recordIsInactiveSafe(InternalAdapterReadinessSummaryRecord record) {
  return record.inactiveBoundary &&
      record.adapterRole.isInactive &&
      record.activeOutputFieldIds.isEmpty &&
      !record.hasUnsafeOutput;
}

InternalEvidenceSummaryGroupId? _firstGroupId(
  InternalAdapterReadinessSummaryRecord record,
) {
  return record.sourceSummaryGroupIds.isEmpty
      ? null
      : record.sourceSummaryGroupIds.first;
}

List<String> _provenAndroidProofIds(GoldenAndroidProofEvidence? evidence) {
  return _sortedStrings(evidence?.targetCaseIds ?? const <String>[]);
}

int _compareFindings(
  InternalAdapterReadinessSummaryFinding a,
  InternalAdapterReadinessSummaryFinding b,
) {
  final severity = _severityRank(
    b.severity,
  ).compareTo(_severityRank(a.severity));
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.adapterPacketId ?? '').compareTo(b.adapterPacketId ?? '');
}

int _severityRank(InternalAdapterReadinessSummarySeverity severity) {
  return switch (severity) {
    InternalAdapterReadinessSummarySeverity.warning => 1,
    InternalAdapterReadinessSummarySeverity.blocker => 2,
    InternalAdapterReadinessSummarySeverity.critical => 3,
  };
}

List<InternalEvidenceSummaryGroupId> _sortedGroupIds(
  Iterable<InternalEvidenceSummaryGroupId> ids,
) {
  return ids.toSet().toList()..sort((a, b) => a.wire.compareTo(b.wire));
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.where((value) => value.trim().isNotEmpty).toSet().toList()
    ..sort();
}

String _ids(Iterable<String> values) {
  final sorted = _sortedStrings(values);
  return sorted.isEmpty ? 'none' : sorted.map(_cell).join(', ');
}

String _groupIds(Iterable<InternalEvidenceSummaryGroupId> ids) {
  final sorted = _sortedGroupIds(ids);
  return sorted.isEmpty ? 'none' : sorted.map((id) => id.wire).join(', ');
}

String _recordIds(Iterable<InternalAdapterReadinessSummaryRecord> rows) {
  return _ids(rows.map((record) => record.summaryRecordId));
}

String _cell(String value) {
  if (value.isEmpty) return 'none';
  return value.replaceAll('|', '/').replaceAll('\n', ' ');
}

bool _isBlockedOutputFieldId(String value) {
  return _blockedOutputFieldIds.contains(value);
}

const _coreGroupIds = <InternalEvidenceSummaryGroupId>{
  InternalEvidenceSummaryGroupId.allowedEvidenceSummary,
  InternalEvidenceSummaryGroupId.improvedSupportSummary,
};

const _contextOnlyGroupIds = <InternalEvidenceSummaryGroupId>{
  InternalEvidenceSummaryGroupId.constrainedWatchListSummary,
  InternalEvidenceSummaryGroupId.proofLimitedSummary,
  InternalEvidenceSummaryGroupId.warningLimitedSummary,
};

const _blockedGroupIds = <InternalEvidenceSummaryGroupId>{
  InternalEvidenceSummaryGroupId.blockedBoundarySummary,
};

const _phase32ECaseIds = <String>{
  'budget-pressure-wide-candidate-32e',
  'endgame-precision-candidate-spread-32e',
  'king-safety-mating-net-pressure-32e',
  'pv-multipv-support-boundary-32e',
  'suppression-forced-only-legal-32e',
};

const _capturedAndroidProofIds = <String>[
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
];

const _blockedOutputFieldIds = <String>[
  'productLabel',
  'finalMoveLabel',
  'brilliantGreatMissStyleLabels',
  'bestGoodInaccuracyMistakeBlunderStyleLabels',
  'numericMoveScore',
  'officialAccuracy',
  'acpl',
  'cpLoss',
  'winProbability',
  'moveRanking',
  'uiOutputFields',
  'backendPersistenceFields',
  'directEngineCallFields',
];

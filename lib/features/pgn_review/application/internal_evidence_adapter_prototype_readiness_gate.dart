/// Developer-only readiness gate for validated internal adapter prototype rows.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_design.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_review.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_validation.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_summary_layer.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_evidence_readiness_gate.dart';

const internalEvidenceAdapterPrototypeReadinessGateReportVersion =
    'internal-evidence-adapter-prototype-readiness-gate-v1';

enum InternalEvidenceAdapterPrototypeReadinessGateStatus {
  readyWithWarnings('readyWithWarnings'),
  readyClean('readyClean'),
  blockedByValidationFailure('blockedByValidationFailure'),
  blockedByContractViolation('blockedByContractViolation'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const InternalEvidenceAdapterPrototypeReadinessGateStatus(this.wire);

  final String wire;
}

enum InternalEvidenceAdapterPrototypeReadinessGroupId {
  allowedCoreAdapterPackets('allowedCoreAdapterPackets'),
  constrainedContextAdapterPackets('constrainedContextAdapterPackets'),
  inactiveBlockedAdapterPackets('inactiveBlockedAdapterPackets'),
  inactiveFutureOnlyAdapterPackets('inactiveFutureOnlyAdapterPackets'),
  allowedActiveOutputFields('allowedActiveOutputFields'),
  blockedOutputFields('blockedOutputFields');

  const InternalEvidenceAdapterPrototypeReadinessGroupId(this.wire);

  final String wire;
}

enum InternalEvidenceAdapterPrototypeReadinessItemStatus {
  allowedCorePacket('allowedCorePacket'),
  constrainedContextOnlyPacket('constrainedContextOnlyPacket'),
  inactiveBlockedPacket('inactiveBlockedPacket'),
  inactiveFutureOnlyPacket('inactiveFutureOnlyPacket'),
  allowedActiveOutputFields('allowedActiveOutputFields'),
  blockedOutputFields('blockedOutputFields'),
  invalid('invalid'),
  unsafe('unsafe');

  const InternalEvidenceAdapterPrototypeReadinessItemStatus(this.wire);

  final String wire;

  bool get isUnsafe =>
      this == InternalEvidenceAdapterPrototypeReadinessItemStatus.unsafe;
}

enum InternalEvidenceAdapterPrototypeReadinessRecommendation {
  allowCorePacketForInternalLayer('allowCorePacketForInternalLayer'),
  keepContextOnlyPacketConstrained('keepContextOnlyPacketConstrained'),
  keepBlockedPacketInactive('keepBlockedPacketInactive'),
  keepFutureOnlyPacketInactive('keepFutureOnlyPacketInactive'),
  blockUnsafePacket('blockUnsafePacket'),
  investigateReadinessFailure('investigateReadinessFailure');

  const InternalEvidenceAdapterPrototypeReadinessRecommendation(this.wire);

  final String wire;
}

enum InternalEvidenceAdapterPrototypeReadinessPhase32RRecommendation {
  proceedToInternalAdapterReadinessSummary(
    'proceedToInternalAdapterReadinessSummary',
  ),
  proceedToDebugOnlyAdapterBridgeDesign(
    'proceedToDebugOnlyAdapterBridgeDesign',
  ),
  proceedToAdapterReadinessValidation('proceedToAdapterReadinessValidation'),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeAdapterReadiness('blockedByUnsafeAdapterReadiness');

  const InternalEvidenceAdapterPrototypeReadinessPhase32RRecommendation(
    this.wire,
  );

  final String wire;
}

enum InternalEvidenceAdapterPrototypeReadinessSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const InternalEvidenceAdapterPrototypeReadinessSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == InternalEvidenceAdapterPrototypeReadinessSeverity.blocker ||
      this == InternalEvidenceAdapterPrototypeReadinessSeverity.critical;

  bool get isCritical =>
      this == InternalEvidenceAdapterPrototypeReadinessSeverity.critical;
}

enum InternalEvidenceAdapterPrototypeReadinessGateReportFormat {
  markdown('markdown'),
  json('json');

  const InternalEvidenceAdapterPrototypeReadinessGateReportFormat(this.wire);

  final String wire;
}

class InternalEvidenceAdapterPrototypeReadinessGateRequest {
  const InternalEvidenceAdapterPrototypeReadinessGateRequest({
    this.validationResult,
    this.reviewResult,
    this.prototypeResult,
    this.designResult,
    this.summaryResult,
    this.readinessResult,
    this.validation = const InternalEvidenceAdapterPrototypeValidation(),
    this.review = const InternalEvidenceAdapterPrototypeReview(),
    this.adapterPrototype = const InternalEvidenceAdapterPrototype(),
    this.adapterDesign = const InternalEvidenceAdapterDesign(),
    this.summaryLayer = const InternalEvidenceSummaryLayer(),
    this.readinessGate = const RefreshedPacketEvidenceReadinessGate(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const InternalEvidenceAdapterPrototypeReadinessGateRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final InternalEvidenceAdapterPrototypeValidationResult? validationResult;
  final InternalEvidenceAdapterPrototypeReviewResult? reviewResult;
  final InternalEvidenceAdapterPrototypeResult? prototypeResult;
  final InternalEvidenceAdapterDesignResult? designResult;
  final InternalEvidenceSummaryLayerResult? summaryResult;
  final RefreshedPacketEvidenceReadinessGateResult? readinessResult;
  final InternalEvidenceAdapterPrototypeValidation validation;
  final InternalEvidenceAdapterPrototypeReview review;
  final InternalEvidenceAdapterPrototype adapterPrototype;
  final InternalEvidenceAdapterDesign adapterDesign;
  final InternalEvidenceSummaryLayer summaryLayer;
  final RefreshedPacketEvidenceReadinessGate readinessGate;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class InternalEvidenceAdapterPrototypeReadinessGroup {
  const InternalEvidenceAdapterPrototypeReadinessGroup({
    required this.groupId,
    required this.readinessStatus,
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
    required this.safeForNextInternalLayer,
    required this.recommendation,
  });

  final InternalEvidenceAdapterPrototypeReadinessGroupId groupId;
  final InternalEvidenceAdapterPrototypeReadinessItemStatus readinessStatus;
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
  final bool safeForNextInternalLayer;
  final InternalEvidenceAdapterPrototypeReadinessRecommendation recommendation;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'groupId': groupId.wire,
      'readinessStatus': readinessStatus.wire,
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
      'safeForNextInternalLayer': safeForNextInternalLayer,
      'recommendation': recommendation.wire,
    };
  }
}

class InternalEvidenceAdapterPrototypeReadinessRecord {
  const InternalEvidenceAdapterPrototypeReadinessRecord({
    required this.readinessRecordId,
    required this.sourceValidationRowId,
    required this.adapterPacketId,
    required this.adapterRole,
    required this.validationStatus,
    required this.readinessStatus,
    required this.allowedForNextInternalLayer,
    required this.constrainedForContextOnly,
    required this.inactiveBoundary,
    required this.sourceSummaryGroupIds,
    required this.activeOutputFieldIds,
    required this.blockedOutputFieldIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.violationReasons,
    required this.warningReason,
    required this.proofLimitReason,
    required this.futurePrerequisites,
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

  final String readinessRecordId;
  final String sourceValidationRowId;
  final String adapterPacketId;
  final InternalEvidenceAdapterPacketRole adapterRole;
  final InternalEvidenceAdapterPrototypePacketValidationStatus validationStatus;
  final InternalEvidenceAdapterPrototypeReadinessItemStatus readinessStatus;
  final bool allowedForNextInternalLayer;
  final bool constrainedForContextOnly;
  final bool inactiveBoundary;
  final List<InternalEvidenceSummaryGroupId> sourceSummaryGroupIds;
  final List<String> activeOutputFieldIds;
  final List<String> blockedOutputFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> violationReasons;
  final String warningReason;
  final String proofLimitReason;
  final List<String> futurePrerequisites;
  final InternalEvidenceAdapterPrototypeReadinessRecommendation recommendation;
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

  InternalEvidenceAdapterPrototypeReadinessRecord copyWith({
    String? readinessRecordId,
    String? sourceValidationRowId,
    String? adapterPacketId,
    InternalEvidenceAdapterPacketRole? adapterRole,
    InternalEvidenceAdapterPrototypePacketValidationStatus? validationStatus,
    InternalEvidenceAdapterPrototypeReadinessItemStatus? readinessStatus,
    bool? allowedForNextInternalLayer,
    bool? constrainedForContextOnly,
    bool? inactiveBoundary,
    List<InternalEvidenceSummaryGroupId>? sourceSummaryGroupIds,
    List<String>? activeOutputFieldIds,
    List<String>? blockedOutputFieldIds,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? violationReasons,
    String? warningReason,
    String? proofLimitReason,
    List<String>? futurePrerequisites,
    InternalEvidenceAdapterPrototypeReadinessRecommendation? recommendation,
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
    return InternalEvidenceAdapterPrototypeReadinessRecord(
      readinessRecordId: readinessRecordId ?? this.readinessRecordId,
      sourceValidationRowId:
          sourceValidationRowId ?? this.sourceValidationRowId,
      adapterPacketId: adapterPacketId ?? this.adapterPacketId,
      adapterRole: adapterRole ?? this.adapterRole,
      validationStatus: validationStatus ?? this.validationStatus,
      readinessStatus: readinessStatus ?? this.readinessStatus,
      allowedForNextInternalLayer:
          allowedForNextInternalLayer ?? this.allowedForNextInternalLayer,
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
      violationReasons: violationReasons ?? this.violationReasons,
      warningReason: warningReason ?? this.warningReason,
      proofLimitReason: proofLimitReason ?? this.proofLimitReason,
      futurePrerequisites: futurePrerequisites ?? this.futurePrerequisites,
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
      'readinessRecordId': readinessRecordId,
      'sourceValidationRowId': sourceValidationRowId,
      'adapterPacketId': adapterPacketId,
      'adapterRole': adapterRole.wire,
      'validationStatus': validationStatus.wire,
      'readinessStatus': readinessStatus.wire,
      'allowedForNextInternalLayer': allowedForNextInternalLayer,
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
      'violationReasons': violationReasons,
      'warningReason': warningReason,
      'proofLimitReason': proofLimitReason,
      'futurePrerequisites': futurePrerequisites,
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

class InternalEvidenceAdapterPrototypeReadinessFinding {
  const InternalEvidenceAdapterPrototypeReadinessFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.readinessRecordId,
    this.adapterPacketId,
    this.groupId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final InternalEvidenceAdapterPrototypeReadinessSeverity severity;
  final String message;
  final String? readinessRecordId;
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
      if (readinessRecordId != null) 'readinessRecordId': readinessRecordId,
      if (adapterPacketId != null) 'adapterPacketId': adapterPacketId,
      if (groupId != null) 'groupId': groupId!.wire,
      if (fieldId != null) 'fieldId': fieldId,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class InternalEvidenceAdapterPrototypeReadinessGateResult {
  const InternalEvidenceAdapterPrototypeReadinessGateResult({
    required this.readinessStatus,
    required this.sourceValidationStatus,
    required this.sourceReviewStatus,
    required this.sourcePrototypeStatus,
    required this.sourceDesignStatus,
    required this.sourceSummaryStatus,
    required this.sourceReadinessStatus,
    required this.groups,
    required this.records,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalRecords,
    required this.allowedCorePacketCount,
    required this.constrainedContextPacketCount,
    required this.inactiveBlockedPacketCount,
    required this.inactiveFutureOnlyPacketCount,
    required this.unsafeCount,
    required this.blockerCount,
    required this.criticalCount,
    required this.ownerProofQueueCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.activeOutputFieldIds,
    required this.blockedOutputFieldIds,
    required this.safeForPhase32R,
    required this.phase32RRecommendation,
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

  final InternalEvidenceAdapterPrototypeReadinessGateStatus readinessStatus;
  final InternalEvidenceAdapterPrototypeValidationStatus sourceValidationStatus;
  final InternalEvidenceAdapterPrototypeReviewStatus sourceReviewStatus;
  final InternalEvidenceAdapterPrototypeStatus sourcePrototypeStatus;
  final InternalEvidenceAdapterDesignStatus sourceDesignStatus;
  final InternalEvidenceSummaryLayerStatus sourceSummaryStatus;
  final RefreshedPacketEvidenceReadinessStatus sourceReadinessStatus;
  final List<InternalEvidenceAdapterPrototypeReadinessGroup> groups;
  final List<InternalEvidenceAdapterPrototypeReadinessRecord> records;
  final List<InternalEvidenceAdapterPrototypeReadinessFinding>
  validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalRecords;
  final int allowedCorePacketCount;
  final int constrainedContextPacketCount;
  final int inactiveBlockedPacketCount;
  final int inactiveFutureOnlyPacketCount;
  final int unsafeCount;
  final int blockerCount;
  final int criticalCount;
  final int ownerProofQueueCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> activeOutputFieldIds;
  final List<String> blockedOutputFieldIds;
  final bool safeForPhase32R;
  final InternalEvidenceAdapterPrototypeReadinessPhase32RRecommendation
  phase32RRecommendation;
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
      readinessStatus ==
          InternalEvidenceAdapterPrototypeReadinessGateStatus
              .blockedByValidationFailure ||
      readinessStatus ==
          InternalEvidenceAdapterPrototypeReadinessGateStatus
              .blockedByContractViolation ||
      readinessStatus ==
          InternalEvidenceAdapterPrototypeReadinessGateStatus
              .blockedByPolicyBoundary ||
      readinessStatus ==
          InternalEvidenceAdapterPrototypeReadinessGateStatus.invalid ||
      !safeForPhase32R ||
      unsafeCount > 0 ||
      blockerCount > 0 ||
      criticalCount > 0 ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeAdapterReadinessPolicyViolation {
    return readinessStatus ==
            InternalEvidenceAdapterPrototypeReadinessGateStatus
                .blockedByValidationFailure ||
        sourceValidationStatus ==
            InternalEvidenceAdapterPrototypeValidationStatus
                .blockedByUnsafeReview ||
        unsafeCount > 0 ||
        criticalCount > 0 ||
        validationFindings.any((finding) => finding.isCritical) ||
        records.any(
          (record) => record.hasUnsafeOutput || record.readinessStatus.isUnsafe,
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

  InternalEvidenceAdapterPrototypeReadinessRecord record(
    String readinessRecordId,
  ) {
    return records.singleWhere(
      (record) => record.readinessRecordId == readinessRecordId,
    );
  }

  InternalEvidenceAdapterPrototypeReadinessRecord recordForPacket(
    String adapterPacketId,
  ) {
    return records.singleWhere(
      (record) => record.adapterPacketId == adapterPacketId,
    );
  }

  InternalEvidenceAdapterPrototypeReadinessRecord recordForGroup(
    InternalEvidenceSummaryGroupId groupId,
  ) {
    return records.singleWhere(
      (record) => record.sourceSummaryGroupIds.contains(groupId),
    );
  }

  InternalEvidenceAdapterPrototypeReadinessGroup readinessGroup(
    InternalEvidenceAdapterPrototypeReadinessGroupId groupId,
  ) {
    return groups.singleWhere((group) => group.groupId == groupId);
  }

  List<InternalEvidenceAdapterPrototypeReadinessRecord>
  get allowedCoreRecords => records
      .where((record) => record.allowedForNextInternalLayer)
      .toList(growable: false);

  List<InternalEvidenceAdapterPrototypeReadinessRecord>
  get constrainedContextRecords => records
      .where((record) => record.constrainedForContextOnly)
      .toList(growable: false);

  List<InternalEvidenceAdapterPrototypeReadinessRecord>
  get inactiveBoundaryRecords => records
      .where((record) => record.inactiveBoundary)
      .toList(growable: false);

  InternalEvidenceAdapterPrototypeReadinessGateResult copyWith({
    InternalEvidenceAdapterPrototypeReadinessGateStatus? readinessStatus,
    InternalEvidenceAdapterPrototypeValidationStatus? sourceValidationStatus,
    InternalEvidenceAdapterPrototypeReviewStatus? sourceReviewStatus,
    InternalEvidenceAdapterPrototypeStatus? sourcePrototypeStatus,
    InternalEvidenceAdapterDesignStatus? sourceDesignStatus,
    InternalEvidenceSummaryLayerStatus? sourceSummaryStatus,
    RefreshedPacketEvidenceReadinessStatus? sourceReadinessStatus,
    List<InternalEvidenceAdapterPrototypeReadinessGroup>? groups,
    List<InternalEvidenceAdapterPrototypeReadinessRecord>? records,
    List<InternalEvidenceAdapterPrototypeReadinessFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalRecords,
    int? allowedCorePacketCount,
    int? constrainedContextPacketCount,
    int? inactiveBlockedPacketCount,
    int? inactiveFutureOnlyPacketCount,
    int? unsafeCount,
    int? blockerCount,
    int? criticalCount,
    int? ownerProofQueueCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? activeOutputFieldIds,
    List<String>? blockedOutputFieldIds,
    bool? safeForPhase32R,
    InternalEvidenceAdapterPrototypeReadinessPhase32RRecommendation?
    phase32RRecommendation,
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
    return InternalEvidenceAdapterPrototypeReadinessGateResult(
      readinessStatus: readinessStatus ?? this.readinessStatus,
      sourceValidationStatus:
          sourceValidationStatus ?? this.sourceValidationStatus,
      sourceReviewStatus: sourceReviewStatus ?? this.sourceReviewStatus,
      sourcePrototypeStatus:
          sourcePrototypeStatus ?? this.sourcePrototypeStatus,
      sourceDesignStatus: sourceDesignStatus ?? this.sourceDesignStatus,
      sourceSummaryStatus: sourceSummaryStatus ?? this.sourceSummaryStatus,
      sourceReadinessStatus:
          sourceReadinessStatus ?? this.sourceReadinessStatus,
      groups: groups ?? this.groups,
      records: records ?? this.records,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalRecords: totalRecords ?? this.totalRecords,
      allowedCorePacketCount:
          allowedCorePacketCount ?? this.allowedCorePacketCount,
      constrainedContextPacketCount:
          constrainedContextPacketCount ?? this.constrainedContextPacketCount,
      inactiveBlockedPacketCount:
          inactiveBlockedPacketCount ?? this.inactiveBlockedPacketCount,
      inactiveFutureOnlyPacketCount:
          inactiveFutureOnlyPacketCount ?? this.inactiveFutureOnlyPacketCount,
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
      safeForPhase32R: safeForPhase32R ?? this.safeForPhase32R,
      phase32RRecommendation:
          phase32RRecommendation ?? this.phase32RRecommendation,
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
      ..writeln('# Internal Evidence Adapter Prototype Readiness Gate')
      ..writeln()
      ..writeln(
        '- version: $internalEvidenceAdapterPrototypeReadinessGateReportVersion',
      )
      ..writeln('- readiness status: ${readinessStatus.wire}')
      ..writeln('- source validation status: ${sourceValidationStatus.wire}')
      ..writeln('- source review status: ${sourceReviewStatus.wire}')
      ..writeln('- source prototype status: ${sourcePrototypeStatus.wire}')
      ..writeln('- source design status: ${sourceDesignStatus.wire}')
      ..writeln('- source summary status: ${sourceSummaryStatus.wire}')
      ..writeln('- source readiness status: ${sourceReadinessStatus.wire}')
      ..writeln('- total records: $totalRecords')
      ..writeln('- allowed core packet count: $allowedCorePacketCount')
      ..writeln(
        '- constrained context packet count: $constrainedContextPacketCount',
      )
      ..writeln('- inactive blocked packet count: $inactiveBlockedPacketCount')
      ..writeln(
        '- inactive future-only packet count: $inactiveFutureOnlyPacketCount',
      )
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- safe for Phase 32R: $safeForPhase32R')
      ..writeln('- Phase 32R recommendation: ${phase32RRecommendation.wire}')
      ..writeln()
      ..writeln('## Readiness Policy')
      ..writeln(
        '- this layer gates Phase 32P validated adapter prototype packets only',
      )
      ..writeln('- valid core packets may pass to a future internal-only layer')
      ..writeln(
        '- context-only packets remain constrained; blocked and future-only packets remain inactive',
      )
      ..writeln()
      ..writeln('## Readiness Group Table')
      ..writeln(
        '| Group | Status | Packets | Source Groups | Active Fields | Blocked Fields | Support Cases | Android Proof | Safe | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final group in groups) {
      buffer.writeln(
        '| ${group.groupId.wire} | '
        '${group.readinessStatus.wire} | '
        '${_ids(group.packetIds)} | '
        '${_groupIds(group.sourceSummaryGroupIds)} | '
        '${_ids(group.activeOutputFieldIds)} | '
        '${_ids(group.blockedOutputFieldIds)} | '
        '${_ids(group.supportCaseIds)} | '
        '${_ids(group.androidProofCaseIds)} | '
        '${group.safeForNextInternalLayer} | '
        '${group.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Readiness Record Table')
      ..writeln(
        '| Readiness Record | Validation Row | Packet | Groups | Role | Validation Status | Readiness Status | Allowed | Constrained | Inactive | Active Fields | Blocked Fields | Violations | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final record in records) {
      buffer.writeln(
        '| ${_cell(record.readinessRecordId)} | '
        '${_cell(record.sourceValidationRowId)} | '
        '${_cell(record.adapterPacketId)} | '
        '${_groupIds(record.sourceSummaryGroupIds)} | '
        '${record.adapterRole.wire} | '
        '${record.validationStatus.wire} | '
        '${record.readinessStatus.wire} | '
        '${record.allowedForNextInternalLayer} | '
        '${record.constrainedForContextOnly} | '
        '${record.inactiveBoundary} | '
        '${_ids(record.activeOutputFieldIds)} | '
        '${_ids(record.blockedOutputFieldIds)} | '
        '${_ids(record.violationReasons)} | '
        '${record.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Allowed Core Packets')
      ..writeln('- ${_recordIds(allowedCoreRecords)}')
      ..writeln()
      ..writeln('## Constrained Context-Only Packets')
      ..writeln('- ${_recordIds(constrainedContextRecords)}')
      ..writeln()
      ..writeln('## Inactive Blocked And Future-Only Packets')
      ..writeln('- ${_recordIds(inactiveBoundaryRecords)}')
      ..writeln()
      ..writeln('## Active Output Field Summary')
      ..writeln('- ${_ids(activeOutputFieldIds)}')
      ..writeln()
      ..writeln('## Blocked Output Field Summary')
      ..writeln('- ${_ids(blockedOutputFieldIds)}')
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
      ..writeln('## Phase 32R Recommendation')
      ..writeln(phase32RRecommendation.wire)
      ..writeln()
      ..writeln(
        'This adapter prototype readiness gate is internal-only. It does not emit active product labels, compute values, order moves, call the engine, run Android, target UI, integrate with backend or persistence, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': internalEvidenceAdapterPrototypeReadinessGateReportVersion,
      'readinessStatus': readinessStatus.wire,
      'sourceValidationStatus': sourceValidationStatus.wire,
      'sourceReviewStatus': sourceReviewStatus.wire,
      'sourcePrototypeStatus': sourcePrototypeStatus.wire,
      'sourceDesignStatus': sourceDesignStatus.wire,
      'sourceSummaryStatus': sourceSummaryStatus.wire,
      'sourceReadinessStatus': sourceReadinessStatus.wire,
      'totalRecords': totalRecords,
      'allowedCorePacketCount': allowedCorePacketCount,
      'constrainedContextPacketCount': constrainedContextPacketCount,
      'inactiveBlockedPacketCount': inactiveBlockedPacketCount,
      'inactiveFutureOnlyPacketCount': inactiveFutureOnlyPacketCount,
      'unsafeCount': unsafeCount,
      'blockerCount': blockerCount,
      'criticalCount': criticalCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'activeOutputFieldIds': activeOutputFieldIds,
      'blockedOutputFieldIds': blockedOutputFieldIds,
      'safeForPhase32R': safeForPhase32R,
      'phase32RRecommendation': phase32RRecommendation.wire,
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

class InternalEvidenceAdapterPrototypeReadinessGate {
  const InternalEvidenceAdapterPrototypeReadinessGate({
    this.validator =
        const InternalEvidenceAdapterPrototypeReadinessGateValidator(),
  });

  final InternalEvidenceAdapterPrototypeReadinessGateValidator validator;

  InternalEvidenceAdapterPrototypeReadinessGateResult evaluate([
    InternalEvidenceAdapterPrototypeReadinessGateRequest request =
        const InternalEvidenceAdapterPrototypeReadinessGateRequest(),
  ]) {
    final readinessResult =
        request.readinessResult ?? request.readinessGate.evaluate();
    final summaryResult =
        request.summaryResult ??
        request.summaryLayer.evaluate(
          InternalEvidenceSummaryLayerRequest(
            readinessResult: readinessResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final designResult =
        request.designResult ??
        request.adapterDesign.evaluate(
          InternalEvidenceAdapterDesignRequest(
            summaryResult: summaryResult,
            readinessResult: readinessResult,
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
            summaryResult: summaryResult,
            readinessResult: readinessResult,
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
            summaryResult: summaryResult,
            readinessResult: readinessResult,
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
            summaryResult: summaryResult,
            readinessResult: readinessResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final records = _recordsFromValidation(validationResult, reviewResult);
    final groups = _groupsFromRecords(
      validationResult: validationResult,
      reviewResult: reviewResult,
      records: records,
    );
    final base = _resultFromRecordsAndGroups(
      validationResult: validationResult,
      reviewResult: reviewResult,
      prototypeResult: prototypeResult,
      designResult: designResult,
      summaryResult: summaryResult,
      readinessResult: readinessResult,
      records: records,
      groups: groups,
      validationFindings:
          const <InternalEvidenceAdapterPrototypeReadinessFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromRecordsAndGroups(
      validationResult: validationResult,
      reviewResult: reviewResult,
      prototypeResult: prototypeResult,
      designResult: designResult,
      summaryResult: summaryResult,
      readinessResult: readinessResult,
      records: records,
      groups: groups,
      validationFindings: findings,
    );
  }
}

class InternalEvidenceAdapterPrototypeReadinessGateValidator {
  const InternalEvidenceAdapterPrototypeReadinessGateValidator();

  List<InternalEvidenceAdapterPrototypeReadinessFinding> validate(
    InternalEvidenceAdapterPrototypeReadinessGateResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <InternalEvidenceAdapterPrototypeReadinessFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required InternalEvidenceAdapterPrototypeReadinessSeverity severity,
      required String message,
      String? readinessRecordId,
      String? adapterPacketId,
      InternalEvidenceSummaryGroupId? groupId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        InternalEvidenceAdapterPrototypeReadinessFinding(
          id: id,
          severity: severity,
          message: message,
          readinessRecordId: readinessRecordId,
          adapterPacketId: adapterPacketId,
          groupId: groupId,
          fieldId: fieldId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase32R &&
        (result.sourceValidationStatus ==
                InternalEvidenceAdapterPrototypeValidationStatus
                    .blockedByUnsafeReview ||
            result.unsafeCount > 0)) {
      add(
        id: 'unsafeValidationMarkedReady',
        severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
        message: 'unsafe adapter prototype validation cannot be marked ready',
      );
    }

    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: InternalEvidenceAdapterPrototypeReadinessSeverity.blocker,
        message: 'owner proof requires explicit PV/MultiPV reason',
      );
    }

    for (final fieldId in _blockedOutputFieldIds) {
      if (!result.blockedOutputFieldIds.contains(fieldId)) {
        add(
          id: 'blockedOutputFieldMissing',
          severity: InternalEvidenceAdapterPrototypeReadinessSeverity.blocker,
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
          readinessRecordId: record.readinessRecordId,
          adapterPacketId: record.adapterPacketId,
          groupId: _firstGroupId(record),
        );
      }
      if (record.violationReasons.contains(
            'core packet source is not allowed',
          ) ||
          (record.adapterRole.isCore &&
              !record.sourceSummaryGroupIds.every(_coreGroupIds.contains))) {
        add(
          id: 'corePacketFromNonCoreSource',
          severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
          message:
              '${record.adapterPacketId} allowed core packet has non-core source',
          readinessRecordId: record.readinessRecordId,
          adapterPacketId: record.adapterPacketId,
          groupId: _firstGroupId(record),
        );
      }
      if (record.violationReasons.contains(
            'context-only packet promoted to core',
          ) ||
          (_contextOnlyGroupIds.any(record.sourceSummaryGroupIds.contains) &&
              record.allowedForNextInternalLayer)) {
        add(
          id: 'contextOnlyPacketPromotedToAllowedCore',
          severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
          message: '${record.adapterPacketId} promoted context-only evidence',
          readinessRecordId: record.readinessRecordId,
          adapterPacketId: record.adapterPacketId,
          groupId: _firstGroupId(record),
        );
      }
      if (_blockedGroupIds.any(record.sourceSummaryGroupIds.contains) &&
          !_recordIsInactiveSafe(record)) {
        add(
          id: 'blockedPacketMadeActive',
          severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
          message: '${record.adapterPacketId} must remain inactive',
          readinessRecordId: record.readinessRecordId,
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
          severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
          message: '${record.adapterPacketId} must remain future-only',
          readinessRecordId: record.readinessRecordId,
          adapterPacketId: record.adapterPacketId,
          groupId: _firstGroupId(record),
        );
      }
      if (record.allowedForNextInternalLayer &&
          (record.supportCaseIds.isEmpty ||
              !record.sourceSummaryGroupIds.every(_coreGroupIds.contains))) {
        add(
          id: 'coreReadinessMissingSupportMapping',
          severity: InternalEvidenceAdapterPrototypeReadinessSeverity.blocker,
          message: 'allowed core readiness requires support and core source',
          readinessRecordId: record.readinessRecordId,
          adapterPacketId: record.adapterPacketId,
          groupId: _firstGroupId(record),
        );
      }
      if (record.isProductOutput) {
        add(
          id: 'productOutputActive',
          severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
          message: 'ready packet cannot be product output',
          readinessRecordId: record.readinessRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.isClassifierLabel) {
        add(
          id: 'classifierLabelOutputActive',
          severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
          message: 'ready packet cannot emit classifier labels',
          readinessRecordId: record.readinessRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.isOfficialMetric) {
        add(
          id: 'officialMetricOutputActive',
          severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
          message: 'ready packet cannot emit official metrics',
          readinessRecordId: record.readinessRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.hasNumericScore) {
        add(
          id: 'numericScoreOutputActive',
          severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
          message: 'ready packet cannot emit numeric move values',
          readinessRecordId: record.readinessRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.ranksMoves) {
        add(
          id: 'moveRankingOutputActive',
          severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
          message: 'ready packet cannot order moves',
          readinessRecordId: record.readinessRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.cpLossOutputActive || record.winProbabilityOutputActive) {
        add(
          id: 'futureMetricOutputActive',
          severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
          message: 'ready packet cannot activate CP-loss or win probability',
          readinessRecordId: record.readinessRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.quietPreparatoryScopeActive) {
        add(
          id: 'quietPreparatoryScopeActivated',
          severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
          message: 'quiet/preparatory scope must remain excluded',
          readinessRecordId: record.readinessRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.callsEngine) {
        add(
          id: 'engineCallFlagActive',
          severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
          message: 'ready packet cannot call an engine',
          readinessRecordId: record.readinessRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.writesPersistence) {
        add(
          id: 'persistenceWriteFlagActive',
          severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
          message: 'ready packet cannot write persistence',
          readinessRecordId: record.readinessRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.targetsUi) {
        add(
          id: 'uiTargetFlagActive',
          severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
          message: 'ready packet cannot target UI',
          readinessRecordId: record.readinessRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      if (record.backendOutputActive) {
        add(
          id: 'backendOutputActive',
          severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
          message: 'ready packet cannot target backend output',
          readinessRecordId: record.readinessRecordId,
          adapterPacketId: record.adapterPacketId,
        );
      }
      for (final caseId in record.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          readinessRecordId: record.readinessRecordId,
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
        id: 'readinessBoundaryPolicyViolation',
        severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
        message:
            'adapter prototype readiness crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<InternalEvidenceAdapterPrototypeReadinessFinding> validateReportText(
    String reportText,
  ) {
    final findings = <InternalEvidenceAdapterPrototypeReadinessFinding>[];
    void reportError(String id, String message) {
      findings.add(
        InternalEvidenceAdapterPrototypeReadinessFinding(
          id: id,
          severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
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
    if (lower.contains('active fields: productlabel') ||
        lower.contains('active fields: finalmovelabel') ||
        lower.contains('active fields: numericmovescore')) {
      reportError(
        'activeBlockedFieldReportText',
        'report contains blocked active output text',
      );
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
        reportText.contains('moveRanking active')) {
      reportError(
        'moveOrderingReportText',
        'report contains active move ordering text',
      );
    }
    return findings..sort(_compareFindings);
  }
}

List<InternalEvidenceAdapterPrototypeReadinessRecord> _recordsFromValidation(
  InternalEvidenceAdapterPrototypeValidationResult validationResult,
  InternalEvidenceAdapterPrototypeReviewResult reviewResult,
) {
  return validationResult.packetRows
      .map((row) => _recordFromValidationRow(row, reviewResult))
      .toList(growable: false);
}

InternalEvidenceAdapterPrototypeReadinessRecord _recordFromValidationRow(
  InternalEvidenceAdapterPrototypeValidationRow row,
  InternalEvidenceAdapterPrototypeReviewResult reviewResult,
) {
  final reviewRow = reviewResult.rowForPacket(row.adapterPacketId);
  final violationReasons = _violationReasonsFor(row, reviewRow);
  final status = _recordStatusFor(row, violationReasons);
  final allowed =
      status ==
          InternalEvidenceAdapterPrototypeReadinessItemStatus
              .allowedCorePacket &&
      violationReasons.isEmpty &&
      !row.hasUnsafeOutput;
  final constrained =
      status ==
          InternalEvidenceAdapterPrototypeReadinessItemStatus
              .constrainedContextOnlyPacket &&
      violationReasons.isEmpty &&
      !row.hasUnsafeOutput;
  final inactive =
      (status ==
              InternalEvidenceAdapterPrototypeReadinessItemStatus
                  .inactiveBlockedPacket ||
          status ==
              InternalEvidenceAdapterPrototypeReadinessItemStatus
                  .inactiveFutureOnlyPacket) &&
      violationReasons.isEmpty &&
      !row.hasUnsafeOutput;
  return InternalEvidenceAdapterPrototypeReadinessRecord(
    readinessRecordId: 'readiness-${row.adapterPacketId}',
    sourceValidationRowId: row.validationRowId,
    adapterPacketId: row.adapterPacketId,
    adapterRole: row.adapterRole,
    validationStatus: row.validationStatus,
    readinessStatus: status,
    allowedForNextInternalLayer: allowed,
    constrainedForContextOnly: constrained,
    inactiveBoundary: inactive,
    sourceSummaryGroupIds: _sortedGroupIds(row.sourceSummaryGroupIds),
    activeOutputFieldIds: _sortedStrings(row.activeOutputFieldIds),
    blockedOutputFieldIds: _sortedStrings(row.blockedOutputFieldIds),
    supportCaseIds: _sortedStrings(row.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(row.newlyAddedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(row.androidProofCaseIds),
    violationReasons: violationReasons,
    warningReason: _warningReasonFor(reviewRow),
    proofLimitReason: reviewRow.proofLimitReason,
    futurePrerequisites: _sortedStrings(reviewRow.futurePrerequisites),
    recommendation: _recommendationFor(status),
    isProductOutput: row.isProductOutput,
    isClassifierLabel: row.isClassifierLabel,
    isOfficialMetric: row.isOfficialMetric,
    hasNumericScore: row.hasNumericScore,
    ranksMoves: row.ranksMoves,
    callsEngine: row.callsEngine,
    writesPersistence: row.writesPersistence,
    targetsUi: row.targetsUi,
    cpLossOutputActive: row.cpLossOutputActive,
    winProbabilityOutputActive: row.winProbabilityOutputActive,
    quietPreparatoryScopeActive: row.quietPreparatoryScopeActive,
    backendOutputActive: row.backendOutputActive,
  );
}

List<String> _violationReasonsFor(
  InternalEvidenceAdapterPrototypeValidationRow row,
  InternalEvidenceAdapterPrototypeReviewRow reviewRow,
) {
  final reasons = <String>[...row.violationReasons];
  if (row.hasUnsafeOutput) {
    reasons.add('unsafe output boundary active');
  }
  if (!row.safetySatisfied) {
    reasons.add('validation safety not satisfied');
  }
  if (!row.contractSatisfied) {
    reasons.add('validation contract not satisfied');
  }
  if (row.validationStatus ==
      InternalEvidenceAdapterPrototypePacketValidationStatus.invalidPacket) {
    reasons.add('source validation row is invalid');
  }
  if (row.validationStatus ==
      InternalEvidenceAdapterPrototypePacketValidationStatus.unsafePacket) {
    reasons.add('source validation row is unsafe');
  }
  if (row.adapterRole.isCore &&
      !row.sourceSummaryGroupIds.every(_coreGroupIds.contains)) {
    reasons.add('core packet source is not allowed');
  }
  if (row.adapterRole.isCore && row.supportCaseIds.isEmpty) {
    reasons.add('core packet missing support mapping');
  }
  if (_contextOnlyGroupIds.any(row.sourceSummaryGroupIds.contains) &&
      row.adapterRole == InternalEvidenceAdapterPacketRole.coreEvidencePacket) {
    reasons.add('context-only packet promoted to core');
  }
  if (_blockedGroupIds.any(row.sourceSummaryGroupIds.contains) &&
      !_validationRowIsInactiveSafe(row)) {
    reasons.add('blocked packet became active');
  }
  if (row.sourceSummaryGroupIds.contains(
        InternalEvidenceSummaryGroupId.futureOnlySummary,
      ) &&
      !_validationRowIsInactiveSafe(row)) {
    reasons.add('future-only packet became active');
  }
  if (row.sourceSummaryGroupIds.contains(
        InternalEvidenceSummaryGroupId.constrainedWatchListSummary,
      ) &&
      reviewRow.watchListReason.trim().isEmpty) {
    reasons.add('watch-listed context reason missing');
  }
  if (row.sourceSummaryGroupIds.contains(
        InternalEvidenceSummaryGroupId.proofLimitedSummary,
      ) &&
      reviewRow.proofLimitReason.trim().isEmpty) {
    reasons.add('proof-limited context reason missing');
  }
  if (row.sourceSummaryGroupIds.contains(
        InternalEvidenceSummaryGroupId.warningLimitedSummary,
      ) &&
      reviewRow.warningLimitedReason.trim().isEmpty) {
    reasons.add('warning-limited context reason missing');
  }
  return _sortedStrings(reasons);
}

InternalEvidenceAdapterPrototypeReadinessItemStatus _recordStatusFor(
  InternalEvidenceAdapterPrototypeValidationRow row,
  List<String> violationReasons,
) {
  if (row.hasUnsafeOutput ||
      row.validationStatus ==
          InternalEvidenceAdapterPrototypePacketValidationStatus.unsafePacket) {
    return InternalEvidenceAdapterPrototypeReadinessItemStatus.unsafe;
  }
  if (violationReasons.isNotEmpty ||
      row.validationStatus ==
          InternalEvidenceAdapterPrototypePacketValidationStatus
              .invalidPacket) {
    return InternalEvidenceAdapterPrototypeReadinessItemStatus.invalid;
  }
  return switch (row.validationStatus) {
    InternalEvidenceAdapterPrototypePacketValidationStatus.validCorePacket =>
      InternalEvidenceAdapterPrototypeReadinessItemStatus.allowedCorePacket,
    InternalEvidenceAdapterPrototypePacketValidationStatus
        .validContextOnlyPacket =>
      InternalEvidenceAdapterPrototypeReadinessItemStatus
          .constrainedContextOnlyPacket,
    InternalEvidenceAdapterPrototypePacketValidationStatus.validBlockedPacket =>
      InternalEvidenceAdapterPrototypeReadinessItemStatus.inactiveBlockedPacket,
    InternalEvidenceAdapterPrototypePacketValidationStatus
        .validFutureOnlyPacket =>
      InternalEvidenceAdapterPrototypeReadinessItemStatus
          .inactiveFutureOnlyPacket,
    InternalEvidenceAdapterPrototypePacketValidationStatus.invalidPacket =>
      InternalEvidenceAdapterPrototypeReadinessItemStatus.invalid,
    InternalEvidenceAdapterPrototypePacketValidationStatus.unsafePacket =>
      InternalEvidenceAdapterPrototypeReadinessItemStatus.unsafe,
  };
}

InternalEvidenceAdapterPrototypeReadinessRecommendation _recommendationFor(
  InternalEvidenceAdapterPrototypeReadinessItemStatus status,
) {
  return switch (status) {
    InternalEvidenceAdapterPrototypeReadinessItemStatus.allowedCorePacket =>
      InternalEvidenceAdapterPrototypeReadinessRecommendation
          .allowCorePacketForInternalLayer,
    InternalEvidenceAdapterPrototypeReadinessItemStatus
        .constrainedContextOnlyPacket =>
      InternalEvidenceAdapterPrototypeReadinessRecommendation
          .keepContextOnlyPacketConstrained,
    InternalEvidenceAdapterPrototypeReadinessItemStatus.inactiveBlockedPacket =>
      InternalEvidenceAdapterPrototypeReadinessRecommendation
          .keepBlockedPacketInactive,
    InternalEvidenceAdapterPrototypeReadinessItemStatus
        .inactiveFutureOnlyPacket =>
      InternalEvidenceAdapterPrototypeReadinessRecommendation
          .keepFutureOnlyPacketInactive,
    InternalEvidenceAdapterPrototypeReadinessItemStatus
        .allowedActiveOutputFields ||
    InternalEvidenceAdapterPrototypeReadinessItemStatus.blockedOutputFields ||
    InternalEvidenceAdapterPrototypeReadinessItemStatus.invalid =>
      InternalEvidenceAdapterPrototypeReadinessRecommendation
          .investigateReadinessFailure,
    InternalEvidenceAdapterPrototypeReadinessItemStatus.unsafe =>
      InternalEvidenceAdapterPrototypeReadinessRecommendation.blockUnsafePacket,
  };
}

List<InternalEvidenceAdapterPrototypeReadinessGroup> _groupsFromRecords({
  required InternalEvidenceAdapterPrototypeValidationResult validationResult,
  required InternalEvidenceAdapterPrototypeReviewResult reviewResult,
  required List<InternalEvidenceAdapterPrototypeReadinessRecord> records,
}) {
  final allowed = records
      .where(
        (record) =>
            record.readinessStatus ==
            InternalEvidenceAdapterPrototypeReadinessItemStatus
                .allowedCorePacket,
      )
      .toList(growable: false);
  final constrained = records
      .where(
        (record) =>
            record.readinessStatus ==
            InternalEvidenceAdapterPrototypeReadinessItemStatus
                .constrainedContextOnlyPacket,
      )
      .toList(growable: false);
  final blocked = records
      .where(
        (record) =>
            record.readinessStatus ==
            InternalEvidenceAdapterPrototypeReadinessItemStatus
                .inactiveBlockedPacket,
      )
      .toList(growable: false);
  final future = records
      .where(
        (record) =>
            record.readinessStatus ==
            InternalEvidenceAdapterPrototypeReadinessItemStatus
                .inactiveFutureOnlyPacket,
      )
      .toList(growable: false);
  final activeBlockedFields = _sortedStrings(
    validationResult.activeOutputFieldIds.where(_isBlockedOutputFieldId),
  );
  return <InternalEvidenceAdapterPrototypeReadinessGroup>[
    _group(
      groupId: InternalEvidenceAdapterPrototypeReadinessGroupId
          .allowedCoreAdapterPackets,
      readinessStatus:
          InternalEvidenceAdapterPrototypeReadinessItemStatus.allowedCorePacket,
      records: allowed,
      safeForNextInternalLayer:
          allowed.length == 2 &&
          allowed.every((record) => record.allowedForNextInternalLayer),
      recommendation: InternalEvidenceAdapterPrototypeReadinessRecommendation
          .allowCorePacketForInternalLayer,
    ),
    _group(
      groupId: InternalEvidenceAdapterPrototypeReadinessGroupId
          .constrainedContextAdapterPackets,
      readinessStatus: InternalEvidenceAdapterPrototypeReadinessItemStatus
          .constrainedContextOnlyPacket,
      records: constrained,
      safeForNextInternalLayer:
          constrained.length == 3 &&
          constrained.every((record) => record.constrainedForContextOnly),
      recommendation: InternalEvidenceAdapterPrototypeReadinessRecommendation
          .keepContextOnlyPacketConstrained,
    ),
    _group(
      groupId: InternalEvidenceAdapterPrototypeReadinessGroupId
          .inactiveBlockedAdapterPackets,
      readinessStatus: InternalEvidenceAdapterPrototypeReadinessItemStatus
          .inactiveBlockedPacket,
      records: blocked,
      safeForNextInternalLayer:
          blocked.length == 1 &&
          blocked.every((record) => record.inactiveBoundary),
      recommendation: InternalEvidenceAdapterPrototypeReadinessRecommendation
          .keepBlockedPacketInactive,
    ),
    _group(
      groupId: InternalEvidenceAdapterPrototypeReadinessGroupId
          .inactiveFutureOnlyAdapterPackets,
      readinessStatus: InternalEvidenceAdapterPrototypeReadinessItemStatus
          .inactiveFutureOnlyPacket,
      records: future,
      safeForNextInternalLayer:
          future.length == 1 &&
          future.every((record) => record.inactiveBoundary),
      recommendation: InternalEvidenceAdapterPrototypeReadinessRecommendation
          .keepFutureOnlyPacketInactive,
    ),
    InternalEvidenceAdapterPrototypeReadinessGroup(
      groupId: InternalEvidenceAdapterPrototypeReadinessGroupId
          .allowedActiveOutputFields,
      readinessStatus: InternalEvidenceAdapterPrototypeReadinessItemStatus
          .allowedActiveOutputFields,
      packetIds: const <String>[],
      sourceSummaryGroupIds: _sortedGroupIds(
        records.expand((record) => record.sourceSummaryGroupIds),
      ),
      activeOutputFieldIds: _sortedStrings(
        validationResult.activeOutputFieldIds,
      ),
      blockedOutputFieldIds: const <String>[],
      supportCaseIds: _sortedStrings(validationResult.supportCaseIds),
      newlyAddedSupportCaseIds: _sortedStrings(
        validationResult.newlyAddedSupportCaseIds,
      ),
      androidProofCaseIds: _sortedStrings(validationResult.androidProofCaseIds),
      warningReasons: _sortedStrings(validationResult.warnings),
      proofLimitReasons: _sortedStrings(
        records.map((record) => record.proofLimitReason),
      ),
      futurePrerequisites: _sortedStrings(
        records.expand((record) => record.futurePrerequisites),
      ),
      safeForNextInternalLayer:
          activeBlockedFields.isEmpty &&
          !validationResult.hasUnsafeAdapterValidationPolicyViolation,
      recommendation: InternalEvidenceAdapterPrototypeReadinessRecommendation
          .allowCorePacketForInternalLayer,
    ),
    InternalEvidenceAdapterPrototypeReadinessGroup(
      groupId:
          InternalEvidenceAdapterPrototypeReadinessGroupId.blockedOutputFields,
      readinessStatus: InternalEvidenceAdapterPrototypeReadinessItemStatus
          .blockedOutputFields,
      packetIds: const <String>[],
      sourceSummaryGroupIds: const <InternalEvidenceSummaryGroupId>[],
      activeOutputFieldIds: const <String>[],
      blockedOutputFieldIds: _sortedStrings(reviewResult.blockedOutputFieldIds),
      supportCaseIds: const <String>[],
      newlyAddedSupportCaseIds: const <String>[],
      androidProofCaseIds: const <String>[],
      warningReasons: const <String>[
        'blocked output fields remain explicit denials',
      ],
      proofLimitReasons: const <String>[],
      futurePrerequisites: const <String>[],
      safeForNextInternalLayer:
          activeBlockedFields.isEmpty &&
          _blockedOutputFieldIds.every(
            reviewResult.blockedOutputFieldIds.contains,
          ),
      recommendation: InternalEvidenceAdapterPrototypeReadinessRecommendation
          .keepBlockedPacketInactive,
    ),
  ];
}

InternalEvidenceAdapterPrototypeReadinessGroup _group({
  required InternalEvidenceAdapterPrototypeReadinessGroupId groupId,
  required InternalEvidenceAdapterPrototypeReadinessItemStatus readinessStatus,
  required List<InternalEvidenceAdapterPrototypeReadinessRecord> records,
  required bool safeForNextInternalLayer,
  required InternalEvidenceAdapterPrototypeReadinessRecommendation
  recommendation,
}) {
  return InternalEvidenceAdapterPrototypeReadinessGroup(
    groupId: groupId,
    readinessStatus: readinessStatus,
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
      records.expand((record) => record.futurePrerequisites),
    ),
    safeForNextInternalLayer: safeForNextInternalLayer,
    recommendation: recommendation,
  );
}

InternalEvidenceAdapterPrototypeReadinessGateResult
_resultFromRecordsAndGroups({
  required InternalEvidenceAdapterPrototypeValidationResult validationResult,
  required InternalEvidenceAdapterPrototypeReviewResult reviewResult,
  required InternalEvidenceAdapterPrototypeResult prototypeResult,
  required InternalEvidenceAdapterDesignResult designResult,
  required InternalEvidenceSummaryLayerResult summaryResult,
  required RefreshedPacketEvidenceReadinessGateResult readinessResult,
  required List<InternalEvidenceAdapterPrototypeReadinessRecord> records,
  required List<InternalEvidenceAdapterPrototypeReadinessGroup> groups,
  required List<InternalEvidenceAdapterPrototypeReadinessFinding>
  validationFindings,
}) {
  final unsafeCount =
      validationResult.unsafeCount +
      records
          .where(
            (record) =>
                record.hasUnsafeOutput ||
                record.readinessStatus ==
                    InternalEvidenceAdapterPrototypeReadinessItemStatus.unsafe,
          )
          .length;
  final blockerCount =
      validationResult.blockerCount +
      validationFindings
          .where(
            (finding) =>
                finding.severity ==
                InternalEvidenceAdapterPrototypeReadinessSeverity.blocker,
          )
          .length;
  final criticalCount =
      validationResult.criticalCount +
      validationFindings.where((finding) => finding.isCritical).length;
  final activeOutputFieldIds = _sortedStrings(
    records.expand((record) => record.activeOutputFieldIds),
  );
  final base = InternalEvidenceAdapterPrototypeReadinessGateResult(
    readinessStatus:
        InternalEvidenceAdapterPrototypeReadinessGateStatus.invalid,
    sourceValidationStatus: validationResult.validationStatus,
    sourceReviewStatus: reviewResult.reviewStatus,
    sourcePrototypeStatus: prototypeResult.prototypeStatus,
    sourceDesignStatus: designResult.designStatus,
    sourceSummaryStatus: summaryResult.summaryStatus,
    sourceReadinessStatus: readinessResult.readinessStatus,
    groups: groups,
    records: records,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...validationResult.warnings,
      if (records.any((record) => record.constrainedForContextOnly))
        'context-only adapter packets remain constrained',
      if (records.any((record) => record.inactiveBoundary))
        'blocked and future-only adapter packets remain inactive',
    ]),
    failures: _sortedStrings(<String>[
      ...validationResult.failures,
      ...records.expand((record) => record.violationReasons),
      ...validationFindings.map((finding) => finding.message),
    ]),
    totalRecords: records.length,
    allowedCorePacketCount: records
        .where((record) => record.allowedForNextInternalLayer)
        .length,
    constrainedContextPacketCount: records
        .where((record) => record.constrainedForContextOnly)
        .length,
    inactiveBlockedPacketCount: records
        .where(
          (record) =>
              record.readinessStatus ==
              InternalEvidenceAdapterPrototypeReadinessItemStatus
                  .inactiveBlockedPacket,
        )
        .length,
    inactiveFutureOnlyPacketCount: records
        .where(
          (record) =>
              record.readinessStatus ==
              InternalEvidenceAdapterPrototypeReadinessItemStatus
                  .inactiveFutureOnlyPacket,
        )
        .length,
    unsafeCount: unsafeCount,
    blockerCount: blockerCount,
    criticalCount: criticalCount,
    ownerProofQueueCount: validationResult.ownerProofQueueCount,
    supportCaseIds: _sortedStrings(
      records.expand((record) => record.supportCaseIds),
    ),
    newlyAddedSupportCaseIds: _sortedStrings(
      records.expand((record) => record.newlyAddedSupportCaseIds),
    ),
    androidProofCaseIds: _sortedStrings(validationResult.androidProofCaseIds),
    activeOutputFieldIds: activeOutputFieldIds,
    blockedOutputFieldIds: _sortedStrings(
      validationResult.blockedOutputFieldIds,
    ),
    safeForPhase32R: false,
    phase32RRecommendation:
        InternalEvidenceAdapterPrototypeReadinessPhase32RRecommendation
            .addMoreGoldenCoverageFirst,
    productOutputActive:
        validationResult.productOutputActive ||
        records.any((record) => record.isProductOutput),
    classifierOutputActive:
        validationResult.classifierOutputActive ||
        records.any((record) => record.isClassifierLabel),
    finalMoveLabelOutputActive: validationResult.finalMoveLabelOutputActive,
    officialMetricOutputActive:
        validationResult.officialMetricOutputActive ||
        records.any((record) => record.isOfficialMetric),
    cpLossOutputActive:
        validationResult.cpLossOutputActive ||
        records.any((record) => record.cpLossOutputActive),
    winProbabilityOutputActive:
        validationResult.winProbabilityOutputActive ||
        records.any((record) => record.winProbabilityOutputActive),
    numericOutputActive:
        validationResult.numericOutputActive ||
        records.any((record) => record.hasNumericScore),
    moveRankingOutputActive:
        validationResult.moveRankingOutputActive ||
        records.any((record) => record.ranksMoves),
    quietPreparatoryScopeActivated:
        validationResult.quietPreparatoryScopeActivated ||
        records.any((record) => record.quietPreparatoryScopeActive),
    engineCallsActive:
        validationResult.engineCallsActive ||
        records.any((record) => record.callsEngine),
    persistenceWritesActive:
        validationResult.persistenceWritesActive ||
        records.any((record) => record.writesPersistence),
    uiTargetsActive:
        validationResult.uiTargetsActive ||
        records.any((record) => record.targetsUi),
    backendOutputActive:
        validationResult.backendOutputActive ||
        records.any((record) => record.backendOutputActive),
  );
  final status = _readinessStatusFor(base, validationResult: validationResult);
  final safeForPhase32R =
      (status ==
              InternalEvidenceAdapterPrototypeReadinessGateStatus
                  .readyWithWarnings ||
          status ==
              InternalEvidenceAdapterPrototypeReadinessGateStatus.readyClean) &&
      validationResult.safeForPhase32Q &&
      !validationResult.isStrictlyBlocked &&
      !validationResult.hasUnsafeAdapterValidationPolicyViolation &&
      readinessResult.safeForPhase32L &&
      unsafeCount == 0 &&
      blockerCount == 0 &&
      criticalCount == 0 &&
      activeOutputFieldIds.every(
        (fieldId) => !_isBlockedOutputFieldId(fieldId),
      ) &&
      records.every(
        (record) =>
            record.allowedForNextInternalLayer ||
            record.constrainedForContextOnly ||
            record.inactiveBoundary,
      ) &&
      groups.every((group) => group.safeForNextInternalLayer) &&
      !validationFindings.any((finding) => finding.blocksStrict);
  return base.copyWith(
    readinessStatus: status,
    safeForPhase32R: safeForPhase32R,
    phase32RRecommendation: _phase32RRecommendationFor(
      status: status,
      safeForPhase32R: safeForPhase32R,
      ownerProofQueueCount: validationResult.ownerProofQueueCount,
    ),
  );
}

InternalEvidenceAdapterPrototypeReadinessGateStatus _readinessStatusFor(
  InternalEvidenceAdapterPrototypeReadinessGateResult result, {
  required InternalEvidenceAdapterPrototypeValidationResult validationResult,
}) {
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
    return InternalEvidenceAdapterPrototypeReadinessGateStatus
        .blockedByPolicyBoundary;
  }
  if (validationResult.validationStatus ==
          InternalEvidenceAdapterPrototypeValidationStatus
              .blockedByUnsafeReview ||
      validationResult.unsafeCount > 0 ||
      result.unsafeCount > 0 ||
      validationResult.hasUnsafeAdapterValidationPolicyViolation) {
    return InternalEvidenceAdapterPrototypeReadinessGateStatus
        .blockedByValidationFailure;
  }
  if (!validationResult.safeForPhase32Q ||
      validationResult.isStrictlyBlocked ||
      result.records.any(
        (record) =>
            record.readinessStatus ==
            InternalEvidenceAdapterPrototypeReadinessItemStatus.invalid,
      ) ||
      result.groups.any((group) => !group.safeForNextInternalLayer) ||
      _hasContractViolationFinding(result.validationFindings)) {
    return InternalEvidenceAdapterPrototypeReadinessGateStatus
        .blockedByContractViolation;
  }
  if (result.criticalCount > 0 ||
      result.validationFindings.any((finding) => finding.isCritical)) {
    return InternalEvidenceAdapterPrototypeReadinessGateStatus
        .blockedByValidationFailure;
  }
  if (result.blockerCount > 0 ||
      result.validationFindings.any((finding) => finding.blocksStrict)) {
    return InternalEvidenceAdapterPrototypeReadinessGateStatus
        .blockedByContractViolation;
  }
  if (result.records.isEmpty || result.groups.isEmpty) {
    return InternalEvidenceAdapterPrototypeReadinessGateStatus.invalid;
  }
  if (result.constrainedContextPacketCount > 0 || result.warnings.isNotEmpty) {
    return InternalEvidenceAdapterPrototypeReadinessGateStatus
        .readyWithWarnings;
  }
  return InternalEvidenceAdapterPrototypeReadinessGateStatus.readyClean;
}

InternalEvidenceAdapterPrototypeReadinessPhase32RRecommendation
_phase32RRecommendationFor({
  required InternalEvidenceAdapterPrototypeReadinessGateStatus status,
  required bool safeForPhase32R,
  required int ownerProofQueueCount,
}) {
  if (status ==
          InternalEvidenceAdapterPrototypeReadinessGateStatus
              .blockedByValidationFailure ||
      status ==
          InternalEvidenceAdapterPrototypeReadinessGateStatus
              .blockedByPolicyBoundary) {
    return InternalEvidenceAdapterPrototypeReadinessPhase32RRecommendation
        .blockedByUnsafeAdapterReadiness;
  }
  if (ownerProofQueueCount > 0) {
    return InternalEvidenceAdapterPrototypeReadinessPhase32RRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase32R) {
    return InternalEvidenceAdapterPrototypeReadinessPhase32RRecommendation
        .addMoreGoldenCoverageFirst;
  }
  return InternalEvidenceAdapterPrototypeReadinessPhase32RRecommendation
      .proceedToInternalAdapterReadinessSummary;
}

void _checkActiveField(
  void Function({
    required String id,
    required InternalEvidenceAdapterPrototypeReadinessSeverity severity,
    required String message,
    String? readinessRecordId,
    String? adapterPacketId,
    InternalEvidenceSummaryGroupId? groupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String fieldId, {
  String? readinessRecordId,
  String? adapterPacketId,
  InternalEvidenceSummaryGroupId? groupId,
}) {
  if (!_isBlockedOutputFieldId(fieldId)) return;
  add(
    id: 'activeBlockedOutputField',
    severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
    message: '$fieldId cannot be an active readiness output field',
    readinessRecordId: readinessRecordId,
    adapterPacketId: adapterPacketId,
    groupId: groupId,
    fieldId: fieldId,
  );
  if (fieldId == 'productLabel') {
    add(
      id: 'productOutputActive',
      severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
      message: 'product label field cannot be active',
      readinessRecordId: readinessRecordId,
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
      severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
      message: 'classifier or final label field cannot be active',
      readinessRecordId: readinessRecordId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'numericMoveScore') {
    add(
      id: 'numericScoreOutputActive',
      severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
      message: 'numeric move value field cannot be active',
      readinessRecordId: readinessRecordId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'moveRanking') {
    add(
      id: 'moveRankingOutputActive',
      severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
      message: 'move ordering field cannot be active',
      readinessRecordId: readinessRecordId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'officialAccuracy' || fieldId == 'acpl') {
    add(
      id: 'officialMetricOutputActive',
      severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
      message: 'official metric field cannot be active',
      readinessRecordId: readinessRecordId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'cpLoss' || fieldId == 'winProbability') {
    add(
      id: 'futureMetricOutputActive',
      severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
      message: 'future metric field cannot be active',
      readinessRecordId: readinessRecordId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'uiOutputFields') {
    add(
      id: 'uiTargetFlagActive',
      severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
      message: 'UI field cannot be active',
      readinessRecordId: readinessRecordId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'backendPersistenceFields') {
    add(
      id: 'persistenceWriteFlagActive',
      severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
      message: 'backend or persistence field cannot be active',
      readinessRecordId: readinessRecordId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'directEngineCallFields') {
    add(
      id: 'engineCallFlagActive',
      severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
      message: 'direct engine call field cannot be active',
      readinessRecordId: readinessRecordId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
}

void _checkAndroidProofCase(
  void Function({
    required String id,
    required InternalEvidenceAdapterPrototypeReadinessSeverity severity,
    required String message,
    String? readinessRecordId,
    String? adapterPacketId,
    InternalEvidenceSummaryGroupId? groupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String caseId,
  List<String> provenAndroidIds, {
  String? readinessRecordId,
  String? adapterPacketId,
  InternalEvidenceSummaryGroupId? groupId,
}) {
  if (_phase32ECaseIds.contains(caseId)) {
    add(
      id: 'phase32ECaseClaimedCapturedProof',
      severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
      message: '$caseId cannot be treated as captured Android proof',
      readinessRecordId: readinessRecordId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      caseId: caseId,
    );
  }
  if (!_capturedAndroidProofIds.contains(caseId) ||
      !provenAndroidIds.contains(caseId)) {
    add(
      id: 'unprovenAndroidProofClaim',
      severity: InternalEvidenceAdapterPrototypeReadinessSeverity.critical,
      message: '$caseId is not captured Android proof for readiness',
      readinessRecordId: readinessRecordId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      caseId: caseId,
    );
  }
}

bool _hasExplicitPvProofReason(
  InternalEvidenceAdapterPrototypeReadinessGateResult result,
) {
  final reasons = <String>[
    ...result.warnings,
    ...result.failures,
    ...result.records.map((record) => record.warningReason),
    ...result.records.map((record) => record.proofLimitReason),
    ...result.records.expand((record) => record.futurePrerequisites),
  ].join(' ').toLowerCase();
  return reasons.contains('pv') || reasons.contains('multipv');
}

bool _hasContractViolationFinding(
  List<InternalEvidenceAdapterPrototypeReadinessFinding> findings,
) {
  return findings.any(
    (finding) => _contractViolationFindingIds.contains(finding.id),
  );
}

bool _recordIsInactiveSafe(
  InternalEvidenceAdapterPrototypeReadinessRecord record,
) {
  return record.inactiveBoundary &&
      record.adapterRole.isInactive &&
      record.activeOutputFieldIds.isEmpty &&
      !record.hasUnsafeOutput;
}

bool _validationRowIsInactiveSafe(
  InternalEvidenceAdapterPrototypeValidationRow row,
) {
  return row.adapterRole.isInactive &&
      row.activeOutputFieldIds.isEmpty &&
      row.allowedEvidenceRecordIds.isEmpty &&
      !row.hasUnsafeOutput;
}

String _warningReasonFor(InternalEvidenceAdapterPrototypeReviewRow row) {
  final reasons = <String>[
    row.watchListReason,
    row.warningLimitedReason,
    ...row.internalWarnings,
    ...row.internalConstraints,
  ];
  return _sortedStrings(reasons).join('; ');
}

InternalEvidenceSummaryGroupId? _firstGroupId(
  InternalEvidenceAdapterPrototypeReadinessRecord record,
) {
  return record.sourceSummaryGroupIds.isEmpty
      ? null
      : record.sourceSummaryGroupIds.first;
}

List<String> _provenAndroidProofIds(GoldenAndroidProofEvidence? evidence) {
  return _sortedStrings(evidence?.targetCaseIds ?? const <String>[]);
}

int _compareFindings(
  InternalEvidenceAdapterPrototypeReadinessFinding a,
  InternalEvidenceAdapterPrototypeReadinessFinding b,
) {
  final severity = _severityRank(
    b.severity,
  ).compareTo(_severityRank(a.severity));
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.adapterPacketId ?? '').compareTo(b.adapterPacketId ?? '');
}

int _severityRank(InternalEvidenceAdapterPrototypeReadinessSeverity severity) {
  return switch (severity) {
    InternalEvidenceAdapterPrototypeReadinessSeverity.warning => 1,
    InternalEvidenceAdapterPrototypeReadinessSeverity.blocker => 2,
    InternalEvidenceAdapterPrototypeReadinessSeverity.critical => 3,
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

String _recordIds(
  Iterable<InternalEvidenceAdapterPrototypeReadinessRecord> rows,
) {
  return _ids(rows.map((record) => record.readinessRecordId));
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

const _contractViolationFindingIds = <String>{
  'blockedOutputFieldMissing',
  'corePacketFromNonCoreSource',
  'contextOnlyPacketPromotedToAllowedCore',
  'blockedPacketMadeActive',
  'futureOnlyPacketMadeActive',
  'coreReadinessMissingSupportMapping',
  'ownerProofRequiredWithoutPvReason',
};

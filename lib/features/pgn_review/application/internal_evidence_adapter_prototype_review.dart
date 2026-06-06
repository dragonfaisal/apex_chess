/// Developer-only review of internal evidence adapter prototype packets.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_design.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_summary_layer.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_evidence_readiness_gate.dart';

const internalEvidenceAdapterPrototypeReviewReportVersion =
    'internal-evidence-adapter-prototype-review-v1';

enum InternalEvidenceAdapterPrototypeReviewStatus {
  reviewedWithWarnings('reviewedWithWarnings'),
  reviewedClean('reviewedClean'),
  blockedByUnsafePrototype('blockedByUnsafePrototype'),
  blockedByContractViolation('blockedByContractViolation'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const InternalEvidenceAdapterPrototypeReviewStatus(this.wire);

  final String wire;
}

enum InternalEvidenceAdapterPrototypeReviewRowStatus {
  validCorePacket('validCorePacket'),
  validContextOnlyPacket('validContextOnlyPacket'),
  validBlockedPacket('validBlockedPacket'),
  validFutureOnlyPacket('validFutureOnlyPacket'),
  invalidPacket('invalidPacket'),
  unsafePacket('unsafePacket');

  const InternalEvidenceAdapterPrototypeReviewRowStatus(this.wire);

  final String wire;

  bool get isUnsafe =>
      this == InternalEvidenceAdapterPrototypeReviewRowStatus.unsafePacket;
}

enum InternalEvidenceAdapterPrototypeReviewRecommendation {
  keepCorePacket('keepCorePacket'),
  keepContextOnlyPacket('keepContextOnlyPacket'),
  keepBlockedPacket('keepBlockedPacket'),
  keepFutureOnlyPacket('keepFutureOnlyPacket'),
  investigateInvalidPacket('investigateInvalidPacket'),
  blockUnsafePacket('blockUnsafePacket');

  const InternalEvidenceAdapterPrototypeReviewRecommendation(this.wire);

  final String wire;
}

enum InternalEvidenceAdapterPrototypeReviewPhase32PRecommendation {
  proceedToAdapterPrototypeValidation('proceedToAdapterPrototypeValidation'),
  proceedToAdapterPrototypeReadinessGate(
    'proceedToAdapterPrototypeReadinessGate',
  ),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeAdapterReview('blockedByUnsafeAdapterReview');

  const InternalEvidenceAdapterPrototypeReviewPhase32PRecommendation(this.wire);

  final String wire;
}

enum InternalEvidenceAdapterPrototypeReviewValidationSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const InternalEvidenceAdapterPrototypeReviewValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this ==
          InternalEvidenceAdapterPrototypeReviewValidationSeverity.blocker ||
      this == InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical;
}

enum InternalEvidenceAdapterPrototypeReviewReportFormat {
  markdown('markdown'),
  json('json');

  const InternalEvidenceAdapterPrototypeReviewReportFormat(this.wire);

  final String wire;
}

class InternalEvidenceAdapterPrototypeReviewRequest {
  const InternalEvidenceAdapterPrototypeReviewRequest({
    this.prototypeResult,
    this.designResult,
    this.summaryResult,
    this.readinessResult,
    this.adapterPrototype = const InternalEvidenceAdapterPrototype(),
    this.adapterDesign = const InternalEvidenceAdapterDesign(),
    this.summaryLayer = const InternalEvidenceSummaryLayer(),
    this.readinessGate = const RefreshedPacketEvidenceReadinessGate(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const InternalEvidenceAdapterPrototypeReviewRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final InternalEvidenceAdapterPrototypeResult? prototypeResult;
  final InternalEvidenceAdapterDesignResult? designResult;
  final InternalEvidenceSummaryLayerResult? summaryResult;
  final RefreshedPacketEvidenceReadinessGateResult? readinessResult;
  final InternalEvidenceAdapterPrototype adapterPrototype;
  final InternalEvidenceAdapterDesign adapterDesign;
  final InternalEvidenceSummaryLayer summaryLayer;
  final RefreshedPacketEvidenceReadinessGate readinessGate;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class InternalEvidenceAdapterPrototypeReviewRow {
  const InternalEvidenceAdapterPrototypeReviewRow({
    required this.reviewRowId,
    required this.adapterPacketId,
    required this.sourceAdapterRecordId,
    required this.sourceSummaryGroupIds,
    required this.adapterRole,
    required this.reviewStatus,
    required this.allowedEvidenceRecordIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.evidenceAreaIds,
    required this.bucketIds,
    required this.androidProofCaseIds,
    required this.activeOutputFieldIds,
    required this.blockedOutputFieldIds,
    required this.internalWarnings,
    required this.internalConstraints,
    required this.futurePrerequisites,
    required this.proofLimitReason,
    required this.watchListReason,
    required this.warningLimitedReason,
    required this.violationReasons,
    required this.safeForNextAdapterGate,
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

  final String reviewRowId;
  final String adapterPacketId;
  final String sourceAdapterRecordId;
  final List<InternalEvidenceSummaryGroupId> sourceSummaryGroupIds;
  final InternalEvidenceAdapterPacketRole adapterRole;
  final InternalEvidenceAdapterPrototypeReviewRowStatus reviewStatus;
  final List<String> allowedEvidenceRecordIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<InternalEvidenceAreaId> evidenceAreaIds;
  final List<InternalEvidenceBucketId> bucketIds;
  final List<String> androidProofCaseIds;
  final List<String> activeOutputFieldIds;
  final List<String> blockedOutputFieldIds;
  final List<String> internalWarnings;
  final List<String> internalConstraints;
  final List<String> futurePrerequisites;
  final String proofLimitReason;
  final String watchListReason;
  final String warningLimitedReason;
  final List<String> violationReasons;
  final bool safeForNextAdapterGate;
  final InternalEvidenceAdapterPrototypeReviewRecommendation recommendation;
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

  InternalEvidenceAdapterPrototypeReviewRow copyWith({
    String? reviewRowId,
    String? adapterPacketId,
    String? sourceAdapterRecordId,
    List<InternalEvidenceSummaryGroupId>? sourceSummaryGroupIds,
    InternalEvidenceAdapterPacketRole? adapterRole,
    InternalEvidenceAdapterPrototypeReviewRowStatus? reviewStatus,
    List<String>? allowedEvidenceRecordIds,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<InternalEvidenceAreaId>? evidenceAreaIds,
    List<InternalEvidenceBucketId>? bucketIds,
    List<String>? androidProofCaseIds,
    List<String>? activeOutputFieldIds,
    List<String>? blockedOutputFieldIds,
    List<String>? internalWarnings,
    List<String>? internalConstraints,
    List<String>? futurePrerequisites,
    String? proofLimitReason,
    String? watchListReason,
    String? warningLimitedReason,
    List<String>? violationReasons,
    bool? safeForNextAdapterGate,
    InternalEvidenceAdapterPrototypeReviewRecommendation? recommendation,
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
    return InternalEvidenceAdapterPrototypeReviewRow(
      reviewRowId: reviewRowId ?? this.reviewRowId,
      adapterPacketId: adapterPacketId ?? this.adapterPacketId,
      sourceAdapterRecordId:
          sourceAdapterRecordId ?? this.sourceAdapterRecordId,
      sourceSummaryGroupIds:
          sourceSummaryGroupIds ?? this.sourceSummaryGroupIds,
      adapterRole: adapterRole ?? this.adapterRole,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      allowedEvidenceRecordIds:
          allowedEvidenceRecordIds ?? this.allowedEvidenceRecordIds,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      evidenceAreaIds: evidenceAreaIds ?? this.evidenceAreaIds,
      bucketIds: bucketIds ?? this.bucketIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      activeOutputFieldIds: activeOutputFieldIds ?? this.activeOutputFieldIds,
      blockedOutputFieldIds:
          blockedOutputFieldIds ?? this.blockedOutputFieldIds,
      internalWarnings: internalWarnings ?? this.internalWarnings,
      internalConstraints: internalConstraints ?? this.internalConstraints,
      futurePrerequisites: futurePrerequisites ?? this.futurePrerequisites,
      proofLimitReason: proofLimitReason ?? this.proofLimitReason,
      watchListReason: watchListReason ?? this.watchListReason,
      warningLimitedReason: warningLimitedReason ?? this.warningLimitedReason,
      violationReasons: violationReasons ?? this.violationReasons,
      safeForNextAdapterGate:
          safeForNextAdapterGate ?? this.safeForNextAdapterGate,
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
      'reviewRowId': reviewRowId,
      'adapterPacketId': adapterPacketId,
      'sourceAdapterRecordId': sourceAdapterRecordId,
      'sourceSummaryGroupIds': sourceSummaryGroupIds
          .map((id) => id.wire)
          .toList(),
      'adapterRole': adapterRole.wire,
      'reviewStatus': reviewStatus.wire,
      'allowedEvidenceRecordIds': allowedEvidenceRecordIds,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'evidenceAreaIds': evidenceAreaIds.map((id) => id.wire).toList(),
      'bucketIds': bucketIds.map((id) => id.wire).toList(),
      'androidProofCaseIds': androidProofCaseIds,
      'activeOutputFieldIds': activeOutputFieldIds,
      'blockedOutputFieldIds': blockedOutputFieldIds,
      'internalWarnings': internalWarnings,
      'internalConstraints': internalConstraints,
      'futurePrerequisites': futurePrerequisites,
      'proofLimitReason': proofLimitReason,
      'watchListReason': watchListReason,
      'warningLimitedReason': warningLimitedReason,
      'violationReasons': violationReasons,
      'safeForNextAdapterGate': safeForNextAdapterGate,
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

class InternalEvidenceAdapterPrototypeReviewFinding {
  const InternalEvidenceAdapterPrototypeReviewFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.reviewRowId,
    this.adapterPacketId,
    this.groupId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final InternalEvidenceAdapterPrototypeReviewValidationSeverity severity;
  final String message;
  final String? reviewRowId;
  final String? adapterPacketId;
  final InternalEvidenceSummaryGroupId? groupId;
  final String? fieldId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical =>
      severity ==
      InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (reviewRowId != null) 'reviewRowId': reviewRowId,
      if (adapterPacketId != null) 'adapterPacketId': adapterPacketId,
      if (groupId != null) 'groupId': groupId!.wire,
      if (fieldId != null) 'fieldId': fieldId,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class InternalEvidenceAdapterPrototypeReviewResult {
  const InternalEvidenceAdapterPrototypeReviewResult({
    required this.reviewStatus,
    required this.sourcePrototypeStatus,
    required this.sourceDesignStatus,
    required this.sourceSummaryStatus,
    required this.sourceReadinessStatus,
    required this.rows,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalRows,
    required this.validCorePacketCount,
    required this.validContextOnlyPacketCount,
    required this.validBlockedPacketCount,
    required this.validFutureOnlyPacketCount,
    required this.invalidCount,
    required this.unsafeCount,
    required this.criticalCount,
    required this.ownerProofQueueCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.activeOutputFieldIds,
    required this.blockedOutputFieldIds,
    required this.safeForPhase32P,
    required this.phase32PRecommendation,
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

  final InternalEvidenceAdapterPrototypeReviewStatus reviewStatus;
  final InternalEvidenceAdapterPrototypeStatus sourcePrototypeStatus;
  final InternalEvidenceAdapterDesignStatus sourceDesignStatus;
  final InternalEvidenceSummaryLayerStatus sourceSummaryStatus;
  final RefreshedPacketEvidenceReadinessStatus sourceReadinessStatus;
  final List<InternalEvidenceAdapterPrototypeReviewRow> rows;
  final List<InternalEvidenceAdapterPrototypeReviewFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalRows;
  final int validCorePacketCount;
  final int validContextOnlyPacketCount;
  final int validBlockedPacketCount;
  final int validFutureOnlyPacketCount;
  final int invalidCount;
  final int unsafeCount;
  final int criticalCount;
  final int ownerProofQueueCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> activeOutputFieldIds;
  final List<String> blockedOutputFieldIds;
  final bool safeForPhase32P;
  final InternalEvidenceAdapterPrototypeReviewPhase32PRecommendation
  phase32PRecommendation;
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
      reviewStatus ==
          InternalEvidenceAdapterPrototypeReviewStatus
              .blockedByUnsafePrototype ||
      reviewStatus ==
          InternalEvidenceAdapterPrototypeReviewStatus
              .blockedByContractViolation ||
      reviewStatus ==
          InternalEvidenceAdapterPrototypeReviewStatus
              .blockedByPolicyBoundary ||
      reviewStatus == InternalEvidenceAdapterPrototypeReviewStatus.invalid ||
      !safeForPhase32P ||
      unsafeCount > 0 ||
      criticalCount > 0 ||
      invalidCount > 0 ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeAdapterReviewPolicyViolation {
    return unsafeCount > 0 ||
        criticalCount > 0 ||
        validationFindings.any((finding) => finding.isCritical) ||
        rows.any((row) => row.hasUnsafeOutput || row.reviewStatus.isUnsafe) ||
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

  InternalEvidenceAdapterPrototypeReviewRow row(String reviewRowId) {
    return rows.singleWhere((row) => row.reviewRowId == reviewRowId);
  }

  InternalEvidenceAdapterPrototypeReviewRow rowForPacket(
    String adapterPacketId,
  ) {
    return rows.singleWhere((row) => row.adapterPacketId == adapterPacketId);
  }

  InternalEvidenceAdapterPrototypeReviewRow rowForGroup(
    InternalEvidenceSummaryGroupId groupId,
  ) {
    return rows.singleWhere(
      (row) => row.sourceSummaryGroupIds.contains(groupId),
    );
  }

  List<InternalEvidenceAdapterPrototypeReviewRow> get coreRows => rows
      .where(
        (row) =>
            row.reviewStatus ==
            InternalEvidenceAdapterPrototypeReviewRowStatus.validCorePacket,
      )
      .toList(growable: false);

  List<InternalEvidenceAdapterPrototypeReviewRow> get contextOnlyRows => rows
      .where(
        (row) =>
            row.reviewStatus ==
            InternalEvidenceAdapterPrototypeReviewRowStatus
                .validContextOnlyPacket,
      )
      .toList(growable: false);

  List<InternalEvidenceAdapterPrototypeReviewRow> get blockedOrFutureRows =>
      rows
          .where(
            (row) =>
                row.reviewStatus ==
                    InternalEvidenceAdapterPrototypeReviewRowStatus
                        .validBlockedPacket ||
                row.reviewStatus ==
                    InternalEvidenceAdapterPrototypeReviewRowStatus
                        .validFutureOnlyPacket,
          )
          .toList(growable: false);

  InternalEvidenceAdapterPrototypeReviewResult copyWith({
    InternalEvidenceAdapterPrototypeReviewStatus? reviewStatus,
    InternalEvidenceAdapterPrototypeStatus? sourcePrototypeStatus,
    InternalEvidenceAdapterDesignStatus? sourceDesignStatus,
    InternalEvidenceSummaryLayerStatus? sourceSummaryStatus,
    RefreshedPacketEvidenceReadinessStatus? sourceReadinessStatus,
    List<InternalEvidenceAdapterPrototypeReviewRow>? rows,
    List<InternalEvidenceAdapterPrototypeReviewFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalRows,
    int? validCorePacketCount,
    int? validContextOnlyPacketCount,
    int? validBlockedPacketCount,
    int? validFutureOnlyPacketCount,
    int? invalidCount,
    int? unsafeCount,
    int? criticalCount,
    int? ownerProofQueueCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? activeOutputFieldIds,
    List<String>? blockedOutputFieldIds,
    bool? safeForPhase32P,
    InternalEvidenceAdapterPrototypeReviewPhase32PRecommendation?
    phase32PRecommendation,
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
    return InternalEvidenceAdapterPrototypeReviewResult(
      reviewStatus: reviewStatus ?? this.reviewStatus,
      sourcePrototypeStatus:
          sourcePrototypeStatus ?? this.sourcePrototypeStatus,
      sourceDesignStatus: sourceDesignStatus ?? this.sourceDesignStatus,
      sourceSummaryStatus: sourceSummaryStatus ?? this.sourceSummaryStatus,
      sourceReadinessStatus:
          sourceReadinessStatus ?? this.sourceReadinessStatus,
      rows: rows ?? this.rows,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalRows: totalRows ?? this.totalRows,
      validCorePacketCount: validCorePacketCount ?? this.validCorePacketCount,
      validContextOnlyPacketCount:
          validContextOnlyPacketCount ?? this.validContextOnlyPacketCount,
      validBlockedPacketCount:
          validBlockedPacketCount ?? this.validBlockedPacketCount,
      validFutureOnlyPacketCount:
          validFutureOnlyPacketCount ?? this.validFutureOnlyPacketCount,
      invalidCount: invalidCount ?? this.invalidCount,
      unsafeCount: unsafeCount ?? this.unsafeCount,
      criticalCount: criticalCount ?? this.criticalCount,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      activeOutputFieldIds: activeOutputFieldIds ?? this.activeOutputFieldIds,
      blockedOutputFieldIds:
          blockedOutputFieldIds ?? this.blockedOutputFieldIds,
      safeForPhase32P: safeForPhase32P ?? this.safeForPhase32P,
      phase32PRecommendation:
          phase32PRecommendation ?? this.phase32PRecommendation,
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
      ..writeln('# Internal Evidence Adapter Prototype Review')
      ..writeln()
      ..writeln(
        '- version: $internalEvidenceAdapterPrototypeReviewReportVersion',
      )
      ..writeln('- review status: ${reviewStatus.wire}')
      ..writeln('- source prototype status: ${sourcePrototypeStatus.wire}')
      ..writeln('- source design status: ${sourceDesignStatus.wire}')
      ..writeln('- source summary status: ${sourceSummaryStatus.wire}')
      ..writeln('- source readiness status: ${sourceReadinessStatus.wire}')
      ..writeln('- total rows: $totalRows')
      ..writeln('- valid core packet count: $validCorePacketCount')
      ..writeln(
        '- valid context-only packet count: $validContextOnlyPacketCount',
      )
      ..writeln('- valid blocked packet count: $validBlockedPacketCount')
      ..writeln('- valid future-only packet count: $validFutureOnlyPacketCount')
      ..writeln('- invalid count: $invalidCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- safe for Phase 32P: $safeForPhase32P')
      ..writeln('- Phase 32P recommendation: ${phase32PRecommendation.wire}')
      ..writeln()
      ..writeln('## Review Policy')
      ..writeln(
        '- this layer reviews Phase 32N internal adapter prototype packets only',
      )
      ..writeln(
        '- core packet rows must come from allowed or improved support summaries',
      )
      ..writeln(
        '- context-only packet rows remain context-only; blocked and future-only rows remain inactive',
      )
      ..writeln()
      ..writeln('## Packet Review Table')
      ..writeln(
        '| Review Row | Packet | Source Record | Groups | Role | Review Status | Active Fields | Blocked Fields | Violations | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in rows) {
      buffer.writeln(
        '| ${_cell(row.reviewRowId)} | '
        '${_cell(row.adapterPacketId)} | '
        '${_cell(row.sourceAdapterRecordId)} | '
        '${_groupIds(row.sourceSummaryGroupIds)} | '
        '${row.adapterRole.wire} | '
        '${row.reviewStatus.wire} | '
        '${_ids(row.activeOutputFieldIds)} | '
        '${_ids(row.blockedOutputFieldIds)} | '
        '${_ids(row.violationReasons)} | '
        '${row.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Core Packet Review Rows')
      ..writeln('- ${_reviewRowIds(coreRows)}')
      ..writeln()
      ..writeln('## Context-Only Packet Review Rows')
      ..writeln('- ${_reviewRowIds(contextOnlyRows)}')
      ..writeln()
      ..writeln('## Blocked And Future-Only Packet Review Rows')
      ..writeln('- ${_reviewRowIds(blockedOrFutureRows)}')
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
      ..writeln('## Phase 32P Recommendation')
      ..writeln(phase32PRecommendation.wire)
      ..writeln()
      ..writeln(
        'This adapter prototype review is internal-only. It does not emit active product labels, compute values, order moves, call the engine, run Android, target UI, integrate with backend or persistence, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': internalEvidenceAdapterPrototypeReviewReportVersion,
      'reviewStatus': reviewStatus.wire,
      'sourcePrototypeStatus': sourcePrototypeStatus.wire,
      'sourceDesignStatus': sourceDesignStatus.wire,
      'sourceSummaryStatus': sourceSummaryStatus.wire,
      'sourceReadinessStatus': sourceReadinessStatus.wire,
      'totalRows': totalRows,
      'validCorePacketCount': validCorePacketCount,
      'validContextOnlyPacketCount': validContextOnlyPacketCount,
      'validBlockedPacketCount': validBlockedPacketCount,
      'validFutureOnlyPacketCount': validFutureOnlyPacketCount,
      'invalidCount': invalidCount,
      'unsafeCount': unsafeCount,
      'criticalCount': criticalCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'activeOutputFieldIds': activeOutputFieldIds,
      'blockedOutputFieldIds': blockedOutputFieldIds,
      'safeForPhase32P': safeForPhase32P,
      'phase32PRecommendation': phase32PRecommendation.wire,
      'rows': rows.map((row) => row.toJson()).toList(),
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

class InternalEvidenceAdapterPrototypeReview {
  const InternalEvidenceAdapterPrototypeReview({
    this.validator = const InternalEvidenceAdapterPrototypeReviewValidator(),
  });

  final InternalEvidenceAdapterPrototypeReviewValidator validator;

  InternalEvidenceAdapterPrototypeReviewResult evaluate([
    InternalEvidenceAdapterPrototypeReviewRequest request =
        const InternalEvidenceAdapterPrototypeReviewRequest(),
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
    final rows = _rowsFromPrototype(prototypeResult.packets);
    final base = _resultFromRows(
      prototypeResult: prototypeResult,
      designResult: designResult,
      summaryResult: summaryResult,
      readinessResult: readinessResult,
      rows: rows,
      validationFindings:
          const <InternalEvidenceAdapterPrototypeReviewFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromRows(
      prototypeResult: prototypeResult,
      designResult: designResult,
      summaryResult: summaryResult,
      readinessResult: readinessResult,
      rows: rows,
      validationFindings: findings,
    );
  }
}

class InternalEvidenceAdapterPrototypeReviewValidator {
  const InternalEvidenceAdapterPrototypeReviewValidator();

  List<InternalEvidenceAdapterPrototypeReviewFinding> validate(
    InternalEvidenceAdapterPrototypeReviewResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <InternalEvidenceAdapterPrototypeReviewFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required InternalEvidenceAdapterPrototypeReviewValidationSeverity
      severity,
      required String message,
      String? reviewRowId,
      String? adapterPacketId,
      InternalEvidenceSummaryGroupId? groupId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        InternalEvidenceAdapterPrototypeReviewFinding(
          id: id,
          severity: severity,
          message: message,
          reviewRowId: reviewRowId,
          adapterPacketId: adapterPacketId,
          groupId: groupId,
          fieldId: fieldId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase32P &&
        (result.sourcePrototypeStatus ==
                InternalEvidenceAdapterPrototypeStatus.skippedByUnsafeDesign ||
            result.unsafeCount > 0)) {
      add(
        id: 'unsafePrototypeMarkedReviewed',
        severity:
            InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
        message: 'unsafe adapter prototype cannot be marked reviewed',
      );
    }

    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity:
            InternalEvidenceAdapterPrototypeReviewValidationSeverity.blocker,
        message: 'owner proof requires explicit PV/MultiPV reason',
      );
    }

    for (final fieldId in _blockedOutputFieldIds) {
      if (!result.blockedOutputFieldIds.contains(fieldId)) {
        add(
          id: 'blockedOutputFieldMissing',
          severity:
              InternalEvidenceAdapterPrototypeReviewValidationSeverity.blocker,
          message: '$fieldId must remain a blocked output field',
          fieldId: fieldId,
        );
      }
    }

    for (final row in result.rows) {
      for (final fieldId in row.activeOutputFieldIds) {
        _checkActiveField(
          add,
          fieldId,
          reviewRowId: row.reviewRowId,
          adapterPacketId: row.adapterPacketId,
          groupId: _firstGroupId(row),
        );
      }
      if (row.adapterRole ==
              InternalEvidenceAdapterPacketRole.coreEvidencePacket &&
          !row.sourceSummaryGroupIds.every(_coreGroupIds.contains)) {
        add(
          id: 'corePacketFromNonCoreSource',
          severity:
              InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
          message: '${row.adapterPacketId} core packet has non-core source',
          reviewRowId: row.reviewRowId,
          adapterPacketId: row.adapterPacketId,
          groupId: _firstGroupId(row),
        );
      }
      if (_contextOnlyGroupIds.any(row.sourceSummaryGroupIds.contains) &&
          row.adapterRole ==
              InternalEvidenceAdapterPacketRole.coreEvidencePacket) {
        add(
          id: 'contextOnlyPacketPromotedToCore',
          severity:
              InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
          message: '${row.adapterPacketId} promoted context-only evidence',
          reviewRowId: row.reviewRowId,
          adapterPacketId: row.adapterPacketId,
          groupId: _firstGroupId(row),
        );
      }
      if (_blockedGroupIds.any(row.sourceSummaryGroupIds.contains) &&
          (row.adapterRole !=
                  InternalEvidenceAdapterPacketRole.blockedBoundaryPacket ||
              row.activeOutputFieldIds.isNotEmpty ||
              row.allowedEvidenceRecordIds.isNotEmpty)) {
        add(
          id: 'blockedPacketMadeActive',
          severity:
              InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
          message: '${row.adapterPacketId} must remain inactive',
          reviewRowId: row.reviewRowId,
          adapterPacketId: row.adapterPacketId,
          groupId: _firstGroupId(row),
        );
      }
      if (row.sourceSummaryGroupIds.contains(
            InternalEvidenceSummaryGroupId.futureOnlySummary,
          ) &&
          (row.adapterRole !=
                  InternalEvidenceAdapterPacketRole.futureOnlyPacket ||
              row.activeOutputFieldIds.isNotEmpty ||
              row.allowedEvidenceRecordIds.isNotEmpty)) {
        add(
          id: 'futureOnlyPacketMadeActive',
          severity:
              InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
          message: '${row.adapterPacketId} must remain future-only',
          reviewRowId: row.reviewRowId,
          adapterPacketId: row.adapterPacketId,
          groupId: _firstGroupId(row),
        );
      }
      if (row.adapterRole ==
              InternalEvidenceAdapterPacketRole.coreEvidencePacket &&
          (row.supportCaseIds.isEmpty ||
              row.allowedEvidenceRecordIds.isEmpty)) {
        add(
          id: 'corePacketMissingSupportMapping',
          severity:
              InternalEvidenceAdapterPrototypeReviewValidationSeverity.blocker,
          message: 'core review row requires support and evidence IDs',
          reviewRowId: row.reviewRowId,
          adapterPacketId: row.adapterPacketId,
          groupId: _firstGroupId(row),
        );
      }
      if (row.isProductOutput) {
        add(
          id: 'productOutputActive',
          severity:
              InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
          message: 'reviewed packet cannot be product output',
          reviewRowId: row.reviewRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.isClassifierLabel) {
        add(
          id: 'classifierLabelOutputActive',
          severity:
              InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
          message: 'reviewed packet cannot emit classifier labels',
          reviewRowId: row.reviewRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.isOfficialMetric) {
        add(
          id: 'officialMetricOutputActive',
          severity:
              InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
          message: 'reviewed packet cannot emit official metrics',
          reviewRowId: row.reviewRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.hasNumericScore) {
        add(
          id: 'numericScoreOutputActive',
          severity:
              InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
          message: 'reviewed packet cannot emit numeric move values',
          reviewRowId: row.reviewRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.ranksMoves) {
        add(
          id: 'moveRankingOutputActive',
          severity:
              InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
          message: 'reviewed packet cannot order moves',
          reviewRowId: row.reviewRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.cpLossOutputActive || row.winProbabilityOutputActive) {
        add(
          id: 'futureMetricOutputActive',
          severity:
              InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
          message: 'reviewed packet cannot activate CP-loss or win probability',
          reviewRowId: row.reviewRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.quietPreparatoryScopeActive) {
        add(
          id: 'quietPreparatoryScopeActivated',
          severity:
              InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
          message: 'quiet/preparatory scope must remain excluded',
          reviewRowId: row.reviewRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.callsEngine) {
        add(
          id: 'engineCallFlagActive',
          severity:
              InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
          message: 'reviewed packet cannot call an engine',
          reviewRowId: row.reviewRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.writesPersistence) {
        add(
          id: 'persistenceWriteFlagActive',
          severity:
              InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
          message: 'reviewed packet cannot write persistence',
          reviewRowId: row.reviewRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.targetsUi) {
        add(
          id: 'uiTargetFlagActive',
          severity:
              InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
          message: 'reviewed packet cannot target UI',
          reviewRowId: row.reviewRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.backendOutputActive) {
        add(
          id: 'backendOutputActive',
          severity:
              InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
          message: 'reviewed packet cannot target backend output',
          reviewRowId: row.reviewRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      for (final caseId in row.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          reviewRowId: row.reviewRowId,
          adapterPacketId: row.adapterPacketId,
          groupId: _firstGroupId(row),
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
        id: 'reviewBoundaryPolicyViolation',
        severity:
            InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
        message: 'adapter prototype review crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<InternalEvidenceAdapterPrototypeReviewFinding> validateReportText(
    String reportText,
  ) {
    final findings = <InternalEvidenceAdapterPrototypeReviewFinding>[];
    void reportError(String id, String message) {
      findings.add(
        InternalEvidenceAdapterPrototypeReviewFinding(
          id: id,
          severity:
              InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
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

List<InternalEvidenceAdapterPrototypeReviewRow> _rowsFromPrototype(
  List<InternalEvidenceAdapterPacket> packets,
) {
  return packets.map(_rowFromPacket).toList(growable: false);
}

InternalEvidenceAdapterPrototypeReviewRow _rowFromPacket(
  InternalEvidenceAdapterPacket packet,
) {
  final violationReasons = _violationReasonsFor(packet);
  final status = _rowStatusFor(packet, violationReasons);
  return InternalEvidenceAdapterPrototypeReviewRow(
    reviewRowId: 'review-${packet.adapterPacketId}',
    adapterPacketId: packet.adapterPacketId,
    sourceAdapterRecordId: packet.sourceAdapterRecordId,
    sourceSummaryGroupIds: packet.sourceSummaryGroupIds,
    adapterRole: packet.adapterRole,
    reviewStatus: status,
    allowedEvidenceRecordIds: _sortedStrings(packet.allowedEvidenceRecordIds),
    supportCaseIds: _sortedStrings(packet.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(packet.newlyAddedSupportCaseIds),
    evidenceAreaIds: _sortedAreaIds(packet.evidenceAreaIds),
    bucketIds: _sortedBucketIds(packet.bucketIds),
    androidProofCaseIds: _sortedStrings(packet.androidProofCaseIds),
    activeOutputFieldIds: _sortedStrings(packet.activeOutputFieldIds),
    blockedOutputFieldIds: _sortedStrings(packet.blockedOutputFieldIds),
    internalWarnings: _sortedStrings(packet.internalWarnings),
    internalConstraints: _sortedStrings(packet.internalConstraints),
    futurePrerequisites: _sortedStrings(packet.futurePrerequisites),
    proofLimitReason: packet.proofLimitReason,
    watchListReason: packet.watchListReason,
    warningLimitedReason: packet.warningLimitedReason,
    violationReasons: violationReasons,
    safeForNextAdapterGate:
        !status.isUnsafe && violationReasons.isEmpty && !packet.hasUnsafeOutput,
    recommendation: _recommendationFor(status),
    isProductOutput: packet.isProductOutput,
    isClassifierLabel: packet.isClassifierLabel,
    isOfficialMetric: packet.isOfficialMetric,
    hasNumericScore: packet.hasNumericScore,
    ranksMoves: packet.ranksMoves,
    callsEngine: packet.callsEngine,
    writesPersistence: packet.writesPersistence,
    targetsUi: packet.targetsUi,
    cpLossOutputActive: packet.cpLossOutputActive,
    winProbabilityOutputActive: packet.winProbabilityOutputActive,
    quietPreparatoryScopeActive: packet.quietPreparatoryScopeActive,
    backendOutputActive: packet.backendOutputActive,
  );
}

List<String> _violationReasonsFor(InternalEvidenceAdapterPacket packet) {
  final reasons = <String>[];
  if (packet.hasUnsafeOutput) {
    reasons.add('unsafe output boundary active');
  }
  if (packet.adapterRole.isCore &&
      !packet.sourceSummaryGroupIds.every(_coreGroupIds.contains)) {
    reasons.add('core packet source is not allowed');
  }
  if (packet.adapterRole.isCore &&
      (packet.supportCaseIds.isEmpty ||
          packet.allowedEvidenceRecordIds.isEmpty)) {
    reasons.add('core packet missing support mapping');
  }
  if (packet.adapterRole.isContextOnly &&
      !packet.sourceSummaryGroupIds.every(_contextOnlyGroupIds.contains)) {
    reasons.add('context-only packet source is not constrained context');
  }
  if (packet.adapterRole.isContextOnly &&
      packet.activeOutputFieldIds.any(_isBlockedOutputFieldId)) {
    reasons.add('context-only packet activated blocked field');
  }
  if (_contextOnlyGroupIds.any(packet.sourceSummaryGroupIds.contains) &&
      packet.adapterRole ==
          InternalEvidenceAdapterPacketRole.coreEvidencePacket) {
    reasons.add('context-only packet promoted to core');
  }
  if (_blockedGroupIds.any(packet.sourceSummaryGroupIds.contains) &&
      !packet.isInactiveSafe) {
    reasons.add('blocked packet became active');
  }
  if (packet.sourceSummaryGroupIds.contains(
        InternalEvidenceSummaryGroupId.futureOnlySummary,
      ) &&
      !packet.isInactiveSafe) {
    reasons.add('future-only packet became active');
  }
  return _sortedStrings(reasons);
}

InternalEvidenceAdapterPrototypeReviewRowStatus _rowStatusFor(
  InternalEvidenceAdapterPacket packet,
  List<String> violationReasons,
) {
  if (packet.hasUnsafeOutput) {
    return InternalEvidenceAdapterPrototypeReviewRowStatus.unsafePacket;
  }
  if (violationReasons.isNotEmpty) {
    return InternalEvidenceAdapterPrototypeReviewRowStatus.invalidPacket;
  }
  return switch (packet.adapterRole) {
    InternalEvidenceAdapterPacketRole.coreEvidencePacket =>
      InternalEvidenceAdapterPrototypeReviewRowStatus.validCorePacket,
    InternalEvidenceAdapterPacketRole.contextOnlyPacket =>
      InternalEvidenceAdapterPrototypeReviewRowStatus.validContextOnlyPacket,
    InternalEvidenceAdapterPacketRole.blockedBoundaryPacket =>
      InternalEvidenceAdapterPrototypeReviewRowStatus.validBlockedPacket,
    InternalEvidenceAdapterPacketRole.futureOnlyPacket =>
      InternalEvidenceAdapterPrototypeReviewRowStatus.validFutureOnlyPacket,
  };
}

InternalEvidenceAdapterPrototypeReviewRecommendation _recommendationFor(
  InternalEvidenceAdapterPrototypeReviewRowStatus status,
) {
  return switch (status) {
    InternalEvidenceAdapterPrototypeReviewRowStatus.validCorePacket =>
      InternalEvidenceAdapterPrototypeReviewRecommendation.keepCorePacket,
    InternalEvidenceAdapterPrototypeReviewRowStatus.validContextOnlyPacket =>
      InternalEvidenceAdapterPrototypeReviewRecommendation
          .keepContextOnlyPacket,
    InternalEvidenceAdapterPrototypeReviewRowStatus.validBlockedPacket =>
      InternalEvidenceAdapterPrototypeReviewRecommendation.keepBlockedPacket,
    InternalEvidenceAdapterPrototypeReviewRowStatus.validFutureOnlyPacket =>
      InternalEvidenceAdapterPrototypeReviewRecommendation.keepFutureOnlyPacket,
    InternalEvidenceAdapterPrototypeReviewRowStatus.invalidPacket =>
      InternalEvidenceAdapterPrototypeReviewRecommendation
          .investigateInvalidPacket,
    InternalEvidenceAdapterPrototypeReviewRowStatus.unsafePacket =>
      InternalEvidenceAdapterPrototypeReviewRecommendation.blockUnsafePacket,
  };
}

InternalEvidenceAdapterPrototypeReviewResult _resultFromRows({
  required InternalEvidenceAdapterPrototypeResult prototypeResult,
  required InternalEvidenceAdapterDesignResult designResult,
  required InternalEvidenceSummaryLayerResult summaryResult,
  required RefreshedPacketEvidenceReadinessGateResult readinessResult,
  required List<InternalEvidenceAdapterPrototypeReviewRow> rows,
  required List<InternalEvidenceAdapterPrototypeReviewFinding>
  validationFindings,
}) {
  final rowUnsafeCount = rows
      .where(
        (row) =>
            row.hasUnsafeOutput ||
            row.reviewStatus ==
                InternalEvidenceAdapterPrototypeReviewRowStatus.unsafePacket,
      )
      .length;
  final unsafeCount = _maxInt(prototypeResult.unsafeCount, rowUnsafeCount);
  final criticalCount =
      prototypeResult.criticalCount +
      validationFindings.where((finding) => finding.isCritical).length;
  final invalidCount = rows
      .where(
        (row) =>
            row.reviewStatus ==
            InternalEvidenceAdapterPrototypeReviewRowStatus.invalidPacket,
      )
      .length;
  final base = InternalEvidenceAdapterPrototypeReviewResult(
    reviewStatus: InternalEvidenceAdapterPrototypeReviewStatus.invalid,
    sourcePrototypeStatus: prototypeResult.prototypeStatus,
    sourceDesignStatus: prototypeResult.sourceDesignStatus,
    sourceSummaryStatus: prototypeResult.sourceSummaryStatus,
    sourceReadinessStatus: prototypeResult.sourceReadinessStatus,
    rows: rows,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...prototypeResult.warnings,
      if (rows.any(
        (row) =>
            row.reviewStatus ==
            InternalEvidenceAdapterPrototypeReviewRowStatus
                .validContextOnlyPacket,
      ))
        'context-only adapter packet reviews remain outside core output',
      if (rows.any(
        (row) =>
            row.reviewStatus ==
                InternalEvidenceAdapterPrototypeReviewRowStatus
                    .validBlockedPacket ||
            row.reviewStatus ==
                InternalEvidenceAdapterPrototypeReviewRowStatus
                    .validFutureOnlyPacket,
      ))
        'blocked and future-only adapter packet reviews remain inactive',
    ]),
    failures: _sortedStrings(<String>[
      ...prototypeResult.failures,
      ...rows.expand((row) => row.violationReasons),
      ...validationFindings.map((finding) => finding.message),
    ]),
    totalRows: rows.length,
    validCorePacketCount: rows
        .where(
          (row) =>
              row.reviewStatus ==
              InternalEvidenceAdapterPrototypeReviewRowStatus.validCorePacket,
        )
        .length,
    validContextOnlyPacketCount: rows
        .where(
          (row) =>
              row.reviewStatus ==
              InternalEvidenceAdapterPrototypeReviewRowStatus
                  .validContextOnlyPacket,
        )
        .length,
    validBlockedPacketCount: rows
        .where(
          (row) =>
              row.reviewStatus ==
              InternalEvidenceAdapterPrototypeReviewRowStatus
                  .validBlockedPacket,
        )
        .length,
    validFutureOnlyPacketCount: rows
        .where(
          (row) =>
              row.reviewStatus ==
              InternalEvidenceAdapterPrototypeReviewRowStatus
                  .validFutureOnlyPacket,
        )
        .length,
    invalidCount: invalidCount,
    unsafeCount: unsafeCount,
    criticalCount: criticalCount,
    ownerProofQueueCount: prototypeResult.ownerProofQueueCount,
    supportCaseIds: _sortedStrings(rows.expand((row) => row.supportCaseIds)),
    newlyAddedSupportCaseIds: _sortedStrings(
      rows.expand((row) => row.newlyAddedSupportCaseIds),
    ),
    androidProofCaseIds: _sortedStrings(prototypeResult.androidProofCaseIds),
    activeOutputFieldIds: _sortedStrings(
      rows.expand((row) => row.activeOutputFieldIds),
    ),
    blockedOutputFieldIds: _sortedStrings(
      prototypeResult.blockedOutputFieldIds,
    ),
    safeForPhase32P: false,
    phase32PRecommendation:
        InternalEvidenceAdapterPrototypeReviewPhase32PRecommendation
            .addMoreGoldenCoverageFirst,
    productOutputActive:
        prototypeResult.productOutputActive ||
        rows.any((row) => row.isProductOutput),
    classifierOutputActive:
        prototypeResult.classifierOutputActive ||
        rows.any((row) => row.isClassifierLabel),
    finalMoveLabelOutputActive: prototypeResult.finalMoveLabelOutputActive,
    officialMetricOutputActive:
        prototypeResult.officialMetricOutputActive ||
        rows.any((row) => row.isOfficialMetric),
    cpLossOutputActive:
        prototypeResult.cpLossOutputActive ||
        rows.any((row) => row.cpLossOutputActive),
    winProbabilityOutputActive:
        prototypeResult.winProbabilityOutputActive ||
        rows.any((row) => row.winProbabilityOutputActive),
    numericOutputActive:
        prototypeResult.numericOutputActive ||
        rows.any((row) => row.hasNumericScore),
    moveRankingOutputActive:
        prototypeResult.moveRankingOutputActive ||
        rows.any((row) => row.ranksMoves),
    quietPreparatoryScopeActivated:
        prototypeResult.quietPreparatoryScopeActivated ||
        rows.any((row) => row.quietPreparatoryScopeActive),
    engineCallsActive:
        prototypeResult.engineCallsActive || rows.any((row) => row.callsEngine),
    persistenceWritesActive:
        prototypeResult.persistenceWritesActive ||
        rows.any((row) => row.writesPersistence),
    uiTargetsActive:
        prototypeResult.uiTargetsActive || rows.any((row) => row.targetsUi),
    backendOutputActive:
        prototypeResult.backendOutputActive ||
        rows.any((row) => row.backendOutputActive),
  );
  final status = _reviewStatusFor(
    base,
    prototypeResult: prototypeResult,
    invalidCount: invalidCount,
  );
  final safeForPhase32P =
      (status ==
              InternalEvidenceAdapterPrototypeReviewStatus
                  .reviewedWithWarnings ||
          status ==
              InternalEvidenceAdapterPrototypeReviewStatus.reviewedClean) &&
      prototypeResult.safeForPhase32O &&
      !prototypeResult.isStrictlyBlocked &&
      !prototypeResult.hasUnsafeAdapterPrototypePolicyViolation &&
      designResult.safeForPhase32N &&
      summaryResult.safeForPhase32M &&
      readinessResult.safeForPhase32L &&
      unsafeCount == 0 &&
      criticalCount == 0 &&
      invalidCount == 0 &&
      !validationFindings.any((finding) => finding.blocksStrict) &&
      rows.every((row) => row.safeForNextAdapterGate);
  return base.copyWith(
    reviewStatus: status,
    safeForPhase32P: safeForPhase32P,
    phase32PRecommendation: _phase32PRecommendationFor(
      status: status,
      safeForPhase32P: safeForPhase32P,
      ownerProofQueueCount: prototypeResult.ownerProofQueueCount,
    ),
  );
}

InternalEvidenceAdapterPrototypeReviewStatus _reviewStatusFor(
  InternalEvidenceAdapterPrototypeReviewResult result, {
  required InternalEvidenceAdapterPrototypeResult prototypeResult,
  required int invalidCount,
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
    return InternalEvidenceAdapterPrototypeReviewStatus.blockedByPolicyBoundary;
  }
  if (prototypeResult.prototypeStatus ==
          InternalEvidenceAdapterPrototypeStatus.skippedByUnsafeDesign ||
      prototypeResult.unsafeCount > 0 ||
      result.unsafeCount > 0) {
    return InternalEvidenceAdapterPrototypeReviewStatus
        .blockedByUnsafePrototype;
  }
  if (!prototypeResult.safeForPhase32O ||
      prototypeResult.isStrictlyBlocked ||
      invalidCount > 0 ||
      _hasContractViolationFinding(result.validationFindings)) {
    return InternalEvidenceAdapterPrototypeReviewStatus
        .blockedByContractViolation;
  }
  if (result.criticalCount > 0 ||
      result.validationFindings.any((finding) => finding.isCritical)) {
    return InternalEvidenceAdapterPrototypeReviewStatus
        .blockedByUnsafePrototype;
  }
  if (result.validationFindings.any((finding) => finding.blocksStrict)) {
    return InternalEvidenceAdapterPrototypeReviewStatus
        .blockedByContractViolation;
  }
  if (result.rows.isEmpty) {
    return InternalEvidenceAdapterPrototypeReviewStatus.invalid;
  }
  if (result.validContextOnlyPacketCount > 0 || result.warnings.isNotEmpty) {
    return InternalEvidenceAdapterPrototypeReviewStatus.reviewedWithWarnings;
  }
  return InternalEvidenceAdapterPrototypeReviewStatus.reviewedClean;
}

InternalEvidenceAdapterPrototypeReviewPhase32PRecommendation
_phase32PRecommendationFor({
  required InternalEvidenceAdapterPrototypeReviewStatus status,
  required bool safeForPhase32P,
  required int ownerProofQueueCount,
}) {
  if (status ==
          InternalEvidenceAdapterPrototypeReviewStatus
              .blockedByUnsafePrototype ||
      status ==
          InternalEvidenceAdapterPrototypeReviewStatus
              .blockedByPolicyBoundary) {
    return InternalEvidenceAdapterPrototypeReviewPhase32PRecommendation
        .blockedByUnsafeAdapterReview;
  }
  if (ownerProofQueueCount > 0) {
    return InternalEvidenceAdapterPrototypeReviewPhase32PRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase32P) {
    return InternalEvidenceAdapterPrototypeReviewPhase32PRecommendation
        .addMoreGoldenCoverageFirst;
  }
  return InternalEvidenceAdapterPrototypeReviewPhase32PRecommendation
      .proceedToAdapterPrototypeValidation;
}

void _checkActiveField(
  void Function({
    required String id,
    required InternalEvidenceAdapterPrototypeReviewValidationSeverity severity,
    required String message,
    String? reviewRowId,
    String? adapterPacketId,
    InternalEvidenceSummaryGroupId? groupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String fieldId, {
  String? reviewRowId,
  String? adapterPacketId,
  InternalEvidenceSummaryGroupId? groupId,
}) {
  if (!_isBlockedOutputFieldId(fieldId)) return;
  add(
    id: 'blockedOutputFieldActive',
    severity: InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
    message: '$fieldId cannot be an active review output field',
    reviewRowId: reviewRowId,
    adapterPacketId: adapterPacketId,
    groupId: groupId,
    fieldId: fieldId,
  );
  if (fieldId == 'productLabel') {
    add(
      id: 'productOutputActive',
      severity:
          InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
      message: 'product label field cannot be active',
      reviewRowId: reviewRowId,
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
      severity:
          InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
      message: 'classifier or final label field cannot be active',
      reviewRowId: reviewRowId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'numericMoveScore') {
    add(
      id: 'numericScoreOutputActive',
      severity:
          InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
      message: 'numeric move value field cannot be active',
      reviewRowId: reviewRowId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'moveRanking') {
    add(
      id: 'moveRankingOutputActive',
      severity:
          InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
      message: 'move ordering field cannot be active',
      reviewRowId: reviewRowId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'officialAccuracy' || fieldId == 'acpl') {
    add(
      id: 'officialMetricOutputActive',
      severity:
          InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
      message: 'official metric field cannot be active',
      reviewRowId: reviewRowId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'cpLoss' || fieldId == 'winProbability') {
    add(
      id: 'futureMetricOutputActive',
      severity:
          InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
      message: 'future metric field cannot be active',
      reviewRowId: reviewRowId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'uiOutputFields' ||
      fieldId == 'backendPersistenceFields' ||
      fieldId == 'directEngineCallFields') {
    add(
      id: 'integrationOutputActive',
      severity:
          InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
      message: 'integration output field cannot be active',
      reviewRowId: reviewRowId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
}

void _checkAndroidProofCase(
  void Function({
    required String id,
    required InternalEvidenceAdapterPrototypeReviewValidationSeverity severity,
    required String message,
    String? reviewRowId,
    String? adapterPacketId,
    InternalEvidenceSummaryGroupId? groupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String caseId,
  Set<String> provenAndroidIds, {
  String? reviewRowId,
  String? adapterPacketId,
  InternalEvidenceSummaryGroupId? groupId,
}) {
  if (!_capturedAndroidProofIds.contains(caseId) ||
      !provenAndroidIds.contains(caseId)) {
    add(
      id: 'unprovenAndroidProofClaim',
      severity:
          InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
      message: 'adapter prototype review cited unproven Android proof',
      reviewRowId: reviewRowId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      caseId: caseId,
    );
  }
  if (_phase32ECaseIds.contains(caseId)) {
    add(
      id: 'phase32ECaseClaimedCapturedProof',
      severity:
          InternalEvidenceAdapterPrototypeReviewValidationSeverity.critical,
      message: 'Phase 32E case cannot be captured Android proof',
      reviewRowId: reviewRowId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      caseId: caseId,
    );
  }
}

bool _hasExplicitPvProofReason(
  InternalEvidenceAdapterPrototypeReviewResult result,
) {
  final reasons = <String>[
    ...result.rows.expand((row) => row.internalWarnings),
    ...result.rows.expand((row) => row.internalConstraints),
    ...result.rows.expand((row) => row.futurePrerequisites),
    ...result.rows.map((row) => row.proofLimitReason),
    ...result.rows.map((row) => row.watchListReason),
  ].join(' ').toLowerCase();
  return reasons.contains('pv') || reasons.contains('multipv');
}

bool _hasContractViolationFinding(
  Iterable<InternalEvidenceAdapterPrototypeReviewFinding> findings,
) {
  return findings.any(
    (finding) => _contractViolationFindingIds.contains(finding.id),
  );
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

String _reviewRowIds(Iterable<InternalEvidenceAdapterPrototypeReviewRow> rows) {
  return _ids(rows.map((row) => row.reviewRowId));
}

InternalEvidenceSummaryGroupId? _firstGroupId(
  InternalEvidenceAdapterPrototypeReviewRow row,
) {
  return row.sourceSummaryGroupIds.isEmpty
      ? null
      : row.sourceSummaryGroupIds.first;
}

String _cell(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? '-' : normalized.replaceAll('|', '/');
}

String _ids(Iterable<String> values) {
  final ids = _sortedStrings(values);
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _groupIds(Iterable<InternalEvidenceSummaryGroupId> values) {
  final ids = values.map((id) => id.wire).toSet().toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.where((value) => value.isNotEmpty).toSet().toList()..sort();
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
  InternalEvidenceAdapterPrototypeReviewFinding a,
  InternalEvidenceAdapterPrototypeReviewFinding b,
) {
  final severityCompare = b.severity.index.compareTo(a.severity.index);
  if (severityCompare != 0) return severityCompare;
  final idCompare = a.id.compareTo(b.id);
  if (idCompare != 0) return idCompare;
  final rowCompare = (a.reviewRowId ?? '').compareTo(b.reviewRowId ?? '');
  if (rowCompare != 0) return rowCompare;
  final packetCompare = (a.adapterPacketId ?? '').compareTo(
    b.adapterPacketId ?? '',
  );
  if (packetCompare != 0) return packetCompare;
  final groupCompare = (a.groupId?.wire ?? '').compareTo(b.groupId?.wire ?? '');
  if (groupCompare != 0) return groupCompare;
  final fieldCompare = (a.fieldId ?? '').compareTo(b.fieldId ?? '');
  if (fieldCompare != 0) return fieldCompare;
  return (a.caseId ?? '').compareTo(b.caseId ?? '');
}

int _maxInt(int a, int b) => a > b ? a : b;

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

const _blockedOutputFieldIds = <String>{
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
};

const _contractViolationFindingIds = <String>{
  'blockedOutputFieldMissing',
  'corePacketFromNonCoreSource',
  'contextOnlyPacketPromotedToCore',
  'blockedPacketMadeActive',
  'futureOnlyPacketMadeActive',
  'corePacketMissingSupportMapping',
  'ownerProofRequiredWithoutPvReason',
};

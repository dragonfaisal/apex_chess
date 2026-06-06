/// Developer-only validation of internal evidence adapter prototype review.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_design.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_review.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_summary_layer.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_evidence_readiness_gate.dart';

const internalEvidenceAdapterPrototypeValidationReportVersion =
    'internal-evidence-adapter-prototype-validation-v1';

enum InternalEvidenceAdapterPrototypeValidationStatus {
  validatedWithWarnings('validatedWithWarnings'),
  validatedClean('validatedClean'),
  blockedByUnsafeReview('blockedByUnsafeReview'),
  blockedByPrototypeContractViolation('blockedByPrototypeContractViolation'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const InternalEvidenceAdapterPrototypeValidationStatus(this.wire);

  final String wire;
}

enum InternalEvidenceAdapterPrototypeValidationCheckStatus {
  passed('passed'),
  passedWithWarnings('passedWithWarnings'),
  failed('failed'),
  blocked('blocked'),
  notApplicable('notApplicable');

  const InternalEvidenceAdapterPrototypeValidationCheckStatus(this.wire);

  final String wire;

  bool get isBlocked =>
      this == InternalEvidenceAdapterPrototypeValidationCheckStatus.failed ||
      this == InternalEvidenceAdapterPrototypeValidationCheckStatus.blocked;
}

enum InternalEvidenceAdapterPrototypeValidationSeverity {
  none('none'),
  info('info'),
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const InternalEvidenceAdapterPrototypeValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == InternalEvidenceAdapterPrototypeValidationSeverity.blocker ||
      this == InternalEvidenceAdapterPrototypeValidationSeverity.critical;

  bool get isCritical =>
      this == InternalEvidenceAdapterPrototypeValidationSeverity.critical;
}

enum InternalEvidenceAdapterPrototypePacketValidationStatus {
  validCorePacket('validCorePacket'),
  validContextOnlyPacket('validContextOnlyPacket'),
  validBlockedPacket('validBlockedPacket'),
  validFutureOnlyPacket('validFutureOnlyPacket'),
  invalidPacket('invalidPacket'),
  unsafePacket('unsafePacket');

  const InternalEvidenceAdapterPrototypePacketValidationStatus(this.wire);

  final String wire;

  bool get isUnsafe =>
      this ==
      InternalEvidenceAdapterPrototypePacketValidationStatus.unsafePacket;
}

enum InternalEvidenceAdapterPrototypeValidationRecommendation {
  keepCorePacket('keepCorePacket'),
  keepContextOnlyPacket('keepContextOnlyPacket'),
  keepBlockedPacket('keepBlockedPacket'),
  keepFutureOnlyPacket('keepFutureOnlyPacket'),
  investigateInvalidPacket('investigateInvalidPacket'),
  blockUnsafePacket('blockUnsafePacket');

  const InternalEvidenceAdapterPrototypeValidationRecommendation(this.wire);

  final String wire;
}

enum InternalEvidenceAdapterPrototypeValidationPhase32QRecommendation {
  proceedToAdapterPrototypeReadinessGate(
    'proceedToAdapterPrototypeReadinessGate',
  ),
  proceedToAdapterValidationSummary('proceedToAdapterValidationSummary'),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeAdapterValidation('blockedByUnsafeAdapterValidation');

  const InternalEvidenceAdapterPrototypeValidationPhase32QRecommendation(
    this.wire,
  );

  final String wire;
}

enum InternalEvidenceAdapterPrototypeValidationReportFormat {
  markdown('markdown'),
  json('json');

  const InternalEvidenceAdapterPrototypeValidationReportFormat(this.wire);

  final String wire;
}

class InternalEvidenceAdapterPrototypeValidationRequest {
  const InternalEvidenceAdapterPrototypeValidationRequest({
    this.reviewResult,
    this.prototypeResult,
    this.designResult,
    this.summaryResult,
    this.readinessResult,
    this.review = const InternalEvidenceAdapterPrototypeReview(),
    this.adapterPrototype = const InternalEvidenceAdapterPrototype(),
    this.adapterDesign = const InternalEvidenceAdapterDesign(),
    this.summaryLayer = const InternalEvidenceSummaryLayer(),
    this.readinessGate = const RefreshedPacketEvidenceReadinessGate(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const InternalEvidenceAdapterPrototypeValidationRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final InternalEvidenceAdapterPrototypeReviewResult? reviewResult;
  final InternalEvidenceAdapterPrototypeResult? prototypeResult;
  final InternalEvidenceAdapterDesignResult? designResult;
  final InternalEvidenceSummaryLayerResult? summaryResult;
  final RefreshedPacketEvidenceReadinessGateResult? readinessResult;
  final InternalEvidenceAdapterPrototypeReview review;
  final InternalEvidenceAdapterPrototype adapterPrototype;
  final InternalEvidenceAdapterDesign adapterDesign;
  final InternalEvidenceSummaryLayer summaryLayer;
  final RefreshedPacketEvidenceReadinessGate readinessGate;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class InternalEvidenceAdapterPrototypeValidationCheck {
  const InternalEvidenceAdapterPrototypeValidationCheck({
    required this.checkId,
    required this.checkStatus,
    required this.severity,
    required this.relatedPacketIds,
    required this.relatedFieldIds,
    required this.relatedProofIds,
    required this.warningReason,
    required this.failureReason,
    required this.recommendation,
  });

  final String checkId;
  final InternalEvidenceAdapterPrototypeValidationCheckStatus checkStatus;
  final InternalEvidenceAdapterPrototypeValidationSeverity severity;
  final List<String> relatedPacketIds;
  final List<String> relatedFieldIds;
  final List<String> relatedProofIds;
  final String warningReason;
  final String failureReason;
  final String recommendation;

  bool get blocksStrict => checkStatus.isBlocked || severity.blocksStrict;

  bool get isCritical => severity.isCritical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'checkId': checkId,
      'checkStatus': checkStatus.wire,
      'severity': severity.wire,
      'relatedPacketIds': relatedPacketIds,
      'relatedFieldIds': relatedFieldIds,
      'relatedProofIds': relatedProofIds,
      'warningReason': warningReason,
      'failureReason': failureReason,
      'recommendation': recommendation,
    };
  }
}

class InternalEvidenceAdapterPrototypeValidationRow {
  const InternalEvidenceAdapterPrototypeValidationRow({
    required this.validationRowId,
    required this.adapterPacketId,
    required this.sourceReviewRowId,
    required this.adapterRole,
    required this.reviewStatus,
    required this.validationStatus,
    required this.sourceSummaryGroupIds,
    required this.allowedEvidenceRecordIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.activeOutputFieldIds,
    required this.blockedOutputFieldIds,
    required this.androidProofCaseIds,
    required this.contractSatisfied,
    required this.safetySatisfied,
    required this.violationReasons,
    required this.safeForNextGate,
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

  final String validationRowId;
  final String adapterPacketId;
  final String sourceReviewRowId;
  final InternalEvidenceAdapterPacketRole adapterRole;
  final InternalEvidenceAdapterPrototypeReviewRowStatus reviewStatus;
  final InternalEvidenceAdapterPrototypePacketValidationStatus validationStatus;
  final List<InternalEvidenceSummaryGroupId> sourceSummaryGroupIds;
  final List<String> allowedEvidenceRecordIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> activeOutputFieldIds;
  final List<String> blockedOutputFieldIds;
  final List<String> androidProofCaseIds;
  final bool contractSatisfied;
  final bool safetySatisfied;
  final List<String> violationReasons;
  final bool safeForNextGate;
  final InternalEvidenceAdapterPrototypeValidationRecommendation recommendation;
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

  InternalEvidenceAdapterPrototypeValidationRow copyWith({
    String? validationRowId,
    String? adapterPacketId,
    String? sourceReviewRowId,
    InternalEvidenceAdapterPacketRole? adapterRole,
    InternalEvidenceAdapterPrototypeReviewRowStatus? reviewStatus,
    InternalEvidenceAdapterPrototypePacketValidationStatus? validationStatus,
    List<InternalEvidenceSummaryGroupId>? sourceSummaryGroupIds,
    List<String>? allowedEvidenceRecordIds,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? activeOutputFieldIds,
    List<String>? blockedOutputFieldIds,
    List<String>? androidProofCaseIds,
    bool? contractSatisfied,
    bool? safetySatisfied,
    List<String>? violationReasons,
    bool? safeForNextGate,
    InternalEvidenceAdapterPrototypeValidationRecommendation? recommendation,
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
    return InternalEvidenceAdapterPrototypeValidationRow(
      validationRowId: validationRowId ?? this.validationRowId,
      adapterPacketId: adapterPacketId ?? this.adapterPacketId,
      sourceReviewRowId: sourceReviewRowId ?? this.sourceReviewRowId,
      adapterRole: adapterRole ?? this.adapterRole,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      validationStatus: validationStatus ?? this.validationStatus,
      sourceSummaryGroupIds:
          sourceSummaryGroupIds ?? this.sourceSummaryGroupIds,
      allowedEvidenceRecordIds:
          allowedEvidenceRecordIds ?? this.allowedEvidenceRecordIds,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      activeOutputFieldIds: activeOutputFieldIds ?? this.activeOutputFieldIds,
      blockedOutputFieldIds:
          blockedOutputFieldIds ?? this.blockedOutputFieldIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      contractSatisfied: contractSatisfied ?? this.contractSatisfied,
      safetySatisfied: safetySatisfied ?? this.safetySatisfied,
      violationReasons: violationReasons ?? this.violationReasons,
      safeForNextGate: safeForNextGate ?? this.safeForNextGate,
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
      'validationRowId': validationRowId,
      'adapterPacketId': adapterPacketId,
      'sourceReviewRowId': sourceReviewRowId,
      'adapterRole': adapterRole.wire,
      'reviewStatus': reviewStatus.wire,
      'validationStatus': validationStatus.wire,
      'sourceSummaryGroupIds': sourceSummaryGroupIds
          .map((id) => id.wire)
          .toList(),
      'allowedEvidenceRecordIds': allowedEvidenceRecordIds,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'activeOutputFieldIds': activeOutputFieldIds,
      'blockedOutputFieldIds': blockedOutputFieldIds,
      'androidProofCaseIds': androidProofCaseIds,
      'contractSatisfied': contractSatisfied,
      'safetySatisfied': safetySatisfied,
      'violationReasons': violationReasons,
      'safeForNextGate': safeForNextGate,
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

class InternalEvidenceAdapterPrototypeValidationFinding {
  const InternalEvidenceAdapterPrototypeValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.validationRowId,
    this.adapterPacketId,
    this.groupId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final InternalEvidenceAdapterPrototypeValidationSeverity severity;
  final String message;
  final String? validationRowId;
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
      if (validationRowId != null) 'validationRowId': validationRowId,
      if (adapterPacketId != null) 'adapterPacketId': adapterPacketId,
      if (groupId != null) 'groupId': groupId!.wire,
      if (fieldId != null) 'fieldId': fieldId,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class InternalEvidenceAdapterPrototypeValidationResult {
  const InternalEvidenceAdapterPrototypeValidationResult({
    required this.validationStatus,
    required this.sourceReviewStatus,
    required this.sourcePrototypeStatus,
    required this.sourceDesignStatus,
    required this.sourceSummaryStatus,
    required this.sourceReadinessStatus,
    required this.checks,
    required this.packetRows,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalChecks,
    required this.passedCheckCount,
    required this.warningCheckCount,
    required this.blockerCount,
    required this.criticalCount,
    required this.totalPacketRows,
    required this.validCorePacketCount,
    required this.validContextOnlyPacketCount,
    required this.validBlockedPacketCount,
    required this.validFutureOnlyPacketCount,
    required this.invalidPacketCount,
    required this.invalidCount,
    required this.unsafePacketCount,
    required this.unsafeCount,
    required this.ownerProofQueueCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.activeOutputFieldIds,
    required this.blockedOutputFieldIds,
    required this.safeForPhase32Q,
    required this.phase32QRecommendation,
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

  final InternalEvidenceAdapterPrototypeValidationStatus validationStatus;
  final InternalEvidenceAdapterPrototypeReviewStatus sourceReviewStatus;
  final InternalEvidenceAdapterPrototypeStatus sourcePrototypeStatus;
  final InternalEvidenceAdapterDesignStatus sourceDesignStatus;
  final InternalEvidenceSummaryLayerStatus sourceSummaryStatus;
  final RefreshedPacketEvidenceReadinessStatus sourceReadinessStatus;
  final List<InternalEvidenceAdapterPrototypeValidationCheck> checks;
  final List<InternalEvidenceAdapterPrototypeValidationRow> packetRows;
  final List<InternalEvidenceAdapterPrototypeValidationFinding>
  validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalChecks;
  final int passedCheckCount;
  final int warningCheckCount;
  final int blockerCount;
  final int criticalCount;
  final int totalPacketRows;
  final int validCorePacketCount;
  final int validContextOnlyPacketCount;
  final int validBlockedPacketCount;
  final int validFutureOnlyPacketCount;
  final int invalidPacketCount;
  final int invalidCount;
  final int unsafePacketCount;
  final int unsafeCount;
  final int ownerProofQueueCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> activeOutputFieldIds;
  final List<String> blockedOutputFieldIds;
  final bool safeForPhase32Q;
  final InternalEvidenceAdapterPrototypeValidationPhase32QRecommendation
  phase32QRecommendation;
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
      validationStatus ==
          InternalEvidenceAdapterPrototypeValidationStatus
              .blockedByUnsafeReview ||
      validationStatus ==
          InternalEvidenceAdapterPrototypeValidationStatus
              .blockedByPrototypeContractViolation ||
      validationStatus ==
          InternalEvidenceAdapterPrototypeValidationStatus
              .blockedByPolicyBoundary ||
      validationStatus ==
          InternalEvidenceAdapterPrototypeValidationStatus.invalid ||
      !safeForPhase32Q ||
      unsafePacketCount > 0 ||
      criticalCount > 0 ||
      blockerCount > 0 ||
      invalidPacketCount > 0 ||
      checks.any((check) => check.blocksStrict) ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeAdapterValidationPolicyViolation {
    return validationStatus ==
            InternalEvidenceAdapterPrototypeValidationStatus
                .blockedByUnsafeReview ||
        sourceReviewStatus ==
            InternalEvidenceAdapterPrototypeReviewStatus
                .blockedByUnsafePrototype ||
        unsafePacketCount > 0 ||
        criticalCount > 0 ||
        validationFindings.any((finding) => finding.isCritical) ||
        checks.any((check) => check.isCritical) ||
        packetRows.any(
          (row) => row.hasUnsafeOutput || row.validationStatus.isUnsafe,
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

  InternalEvidenceAdapterPrototypeValidationRow row(String validationRowId) {
    return packetRows.singleWhere(
      (row) => row.validationRowId == validationRowId,
    );
  }

  InternalEvidenceAdapterPrototypeValidationRow rowForPacket(
    String adapterPacketId,
  ) {
    return packetRows.singleWhere(
      (row) => row.adapterPacketId == adapterPacketId,
    );
  }

  InternalEvidenceAdapterPrototypeValidationRow rowForGroup(
    InternalEvidenceSummaryGroupId groupId,
  ) {
    return packetRows.singleWhere(
      (row) => row.sourceSummaryGroupIds.contains(groupId),
    );
  }

  InternalEvidenceAdapterPrototypeValidationCheck check(String checkId) {
    return checks.singleWhere((check) => check.checkId == checkId);
  }

  List<InternalEvidenceAdapterPrototypeValidationRow> get coreRows => packetRows
      .where(
        (row) =>
            row.validationStatus ==
            InternalEvidenceAdapterPrototypePacketValidationStatus
                .validCorePacket,
      )
      .toList(growable: false);

  List<InternalEvidenceAdapterPrototypeValidationRow> get contextOnlyRows =>
      packetRows
          .where(
            (row) =>
                row.validationStatus ==
                InternalEvidenceAdapterPrototypePacketValidationStatus
                    .validContextOnlyPacket,
          )
          .toList(growable: false);

  List<InternalEvidenceAdapterPrototypeValidationRow> get blockedOrFutureRows =>
      packetRows
          .where(
            (row) =>
                row.validationStatus ==
                    InternalEvidenceAdapterPrototypePacketValidationStatus
                        .validBlockedPacket ||
                row.validationStatus ==
                    InternalEvidenceAdapterPrototypePacketValidationStatus
                        .validFutureOnlyPacket,
          )
          .toList(growable: false);

  InternalEvidenceAdapterPrototypeValidationResult copyWith({
    InternalEvidenceAdapterPrototypeValidationStatus? validationStatus,
    InternalEvidenceAdapterPrototypeReviewStatus? sourceReviewStatus,
    InternalEvidenceAdapterPrototypeStatus? sourcePrototypeStatus,
    InternalEvidenceAdapterDesignStatus? sourceDesignStatus,
    InternalEvidenceSummaryLayerStatus? sourceSummaryStatus,
    RefreshedPacketEvidenceReadinessStatus? sourceReadinessStatus,
    List<InternalEvidenceAdapterPrototypeValidationCheck>? checks,
    List<InternalEvidenceAdapterPrototypeValidationRow>? packetRows,
    List<InternalEvidenceAdapterPrototypeValidationFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalChecks,
    int? passedCheckCount,
    int? warningCheckCount,
    int? blockerCount,
    int? criticalCount,
    int? totalPacketRows,
    int? validCorePacketCount,
    int? validContextOnlyPacketCount,
    int? validBlockedPacketCount,
    int? validFutureOnlyPacketCount,
    int? invalidPacketCount,
    int? invalidCount,
    int? unsafePacketCount,
    int? unsafeCount,
    int? ownerProofQueueCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? activeOutputFieldIds,
    List<String>? blockedOutputFieldIds,
    bool? safeForPhase32Q,
    InternalEvidenceAdapterPrototypeValidationPhase32QRecommendation?
    phase32QRecommendation,
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
    return InternalEvidenceAdapterPrototypeValidationResult(
      validationStatus: validationStatus ?? this.validationStatus,
      sourceReviewStatus: sourceReviewStatus ?? this.sourceReviewStatus,
      sourcePrototypeStatus:
          sourcePrototypeStatus ?? this.sourcePrototypeStatus,
      sourceDesignStatus: sourceDesignStatus ?? this.sourceDesignStatus,
      sourceSummaryStatus: sourceSummaryStatus ?? this.sourceSummaryStatus,
      sourceReadinessStatus:
          sourceReadinessStatus ?? this.sourceReadinessStatus,
      checks: checks ?? this.checks,
      packetRows: packetRows ?? this.packetRows,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalChecks: totalChecks ?? this.totalChecks,
      passedCheckCount: passedCheckCount ?? this.passedCheckCount,
      warningCheckCount: warningCheckCount ?? this.warningCheckCount,
      blockerCount: blockerCount ?? this.blockerCount,
      criticalCount: criticalCount ?? this.criticalCount,
      totalPacketRows: totalPacketRows ?? this.totalPacketRows,
      validCorePacketCount: validCorePacketCount ?? this.validCorePacketCount,
      validContextOnlyPacketCount:
          validContextOnlyPacketCount ?? this.validContextOnlyPacketCount,
      validBlockedPacketCount:
          validBlockedPacketCount ?? this.validBlockedPacketCount,
      validFutureOnlyPacketCount:
          validFutureOnlyPacketCount ?? this.validFutureOnlyPacketCount,
      invalidPacketCount: invalidPacketCount ?? this.invalidPacketCount,
      invalidCount: invalidCount ?? this.invalidCount,
      unsafePacketCount: unsafePacketCount ?? this.unsafePacketCount,
      unsafeCount: unsafeCount ?? this.unsafeCount,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      activeOutputFieldIds: activeOutputFieldIds ?? this.activeOutputFieldIds,
      blockedOutputFieldIds:
          blockedOutputFieldIds ?? this.blockedOutputFieldIds,
      safeForPhase32Q: safeForPhase32Q ?? this.safeForPhase32Q,
      phase32QRecommendation:
          phase32QRecommendation ?? this.phase32QRecommendation,
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
      ..writeln('# Internal Evidence Adapter Prototype Validation')
      ..writeln()
      ..writeln(
        '- version: $internalEvidenceAdapterPrototypeValidationReportVersion',
      )
      ..writeln('- validation status: ${validationStatus.wire}')
      ..writeln('- source review status: ${sourceReviewStatus.wire}')
      ..writeln('- source prototype status: ${sourcePrototypeStatus.wire}')
      ..writeln('- source design status: ${sourceDesignStatus.wire}')
      ..writeln('- source summary status: ${sourceSummaryStatus.wire}')
      ..writeln('- source readiness status: ${sourceReadinessStatus.wire}')
      ..writeln('- total checks: $totalChecks')
      ..writeln('- passed check count: $passedCheckCount')
      ..writeln('- warning check count: $warningCheckCount')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- total packet rows: $totalPacketRows')
      ..writeln('- valid core packet count: $validCorePacketCount')
      ..writeln(
        '- valid context-only packet count: $validContextOnlyPacketCount',
      )
      ..writeln('- valid blocked packet count: $validBlockedPacketCount')
      ..writeln('- valid future-only packet count: $validFutureOnlyPacketCount')
      ..writeln('- invalid packet count: $invalidPacketCount')
      ..writeln('- unsafe packet count: $unsafePacketCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- safe for Phase 32Q: $safeForPhase32Q')
      ..writeln('- Phase 32Q recommendation: ${phase32QRecommendation.wire}')
      ..writeln()
      ..writeln('## Validation Policy')
      ..writeln(
        '- this layer validates Phase 32N prototype packets through the Phase 32O review only',
      )
      ..writeln('- core packet rows must satisfy the Phase 32M source contract')
      ..writeln(
        '- context-only rows stay context-only; blocked and future-only rows stay inactive',
      )
      ..writeln()
      ..writeln('## Validation Check Table')
      ..writeln(
        '| Check | Status | Severity | Packets | Fields | Proof IDs | Warning | Failure | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- | --- |');
    for (final check in checks) {
      buffer.writeln(
        '| ${_cell(check.checkId)} | '
        '${check.checkStatus.wire} | '
        '${check.severity.wire} | '
        '${_ids(check.relatedPacketIds)} | '
        '${_ids(check.relatedFieldIds)} | '
        '${_ids(check.relatedProofIds)} | '
        '${_cell(check.warningReason)} | '
        '${_cell(check.failureReason)} | '
        '${_cell(check.recommendation)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Packet Validation Table')
      ..writeln(
        '| Validation Row | Packet | Source Review Row | Groups | Role | Review Status | Validation Status | Active Fields | Blocked Fields | Contract | Safety | Violations | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in packetRows) {
      buffer.writeln(
        '| ${_cell(row.validationRowId)} | '
        '${_cell(row.adapterPacketId)} | '
        '${_cell(row.sourceReviewRowId)} | '
        '${_groupIds(row.sourceSummaryGroupIds)} | '
        '${row.adapterRole.wire} | '
        '${row.reviewStatus.wire} | '
        '${row.validationStatus.wire} | '
        '${_ids(row.activeOutputFieldIds)} | '
        '${_ids(row.blockedOutputFieldIds)} | '
        '${row.contractSatisfied} | '
        '${row.safetySatisfied} | '
        '${_ids(row.violationReasons)} | '
        '${row.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Core Packet Validation Rows')
      ..writeln('- ${_validationRowIds(coreRows)}')
      ..writeln()
      ..writeln('## Context-Only Validation Rows')
      ..writeln('- ${_validationRowIds(contextOnlyRows)}')
      ..writeln()
      ..writeln('## Blocked And Future-Only Validation Rows')
      ..writeln('- ${_validationRowIds(blockedOrFutureRows)}')
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
      ..writeln('## Phase 32Q Recommendation')
      ..writeln(phase32QRecommendation.wire)
      ..writeln()
      ..writeln(
        'This adapter prototype validation is internal-only. It does not emit active product labels, compute values, order moves, call the engine, run Android, target UI, integrate with backend or persistence, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': internalEvidenceAdapterPrototypeValidationReportVersion,
      'validationStatus': validationStatus.wire,
      'sourceReviewStatus': sourceReviewStatus.wire,
      'sourcePrototypeStatus': sourcePrototypeStatus.wire,
      'sourceDesignStatus': sourceDesignStatus.wire,
      'sourceSummaryStatus': sourceSummaryStatus.wire,
      'sourceReadinessStatus': sourceReadinessStatus.wire,
      'totalChecks': totalChecks,
      'passedCheckCount': passedCheckCount,
      'warningCheckCount': warningCheckCount,
      'blockerCount': blockerCount,
      'criticalCount': criticalCount,
      'totalPacketRows': totalPacketRows,
      'validCorePacketCount': validCorePacketCount,
      'validContextOnlyPacketCount': validContextOnlyPacketCount,
      'validBlockedPacketCount': validBlockedPacketCount,
      'validFutureOnlyPacketCount': validFutureOnlyPacketCount,
      'invalidPacketCount': invalidPacketCount,
      'invalidCount': invalidCount,
      'unsafePacketCount': unsafePacketCount,
      'unsafeCount': unsafeCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'activeOutputFieldIds': activeOutputFieldIds,
      'blockedOutputFieldIds': blockedOutputFieldIds,
      'safeForPhase32Q': safeForPhase32Q,
      'phase32QRecommendation': phase32QRecommendation.wire,
      'checks': checks.map((check) => check.toJson()).toList(),
      'packetRows': packetRows.map((row) => row.toJson()).toList(),
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

class InternalEvidenceAdapterPrototypeValidation {
  const InternalEvidenceAdapterPrototypeValidation({
    this.validator =
        const InternalEvidenceAdapterPrototypeValidationValidator(),
  });

  final InternalEvidenceAdapterPrototypeValidationValidator validator;

  InternalEvidenceAdapterPrototypeValidationResult evaluate([
    InternalEvidenceAdapterPrototypeValidationRequest request =
        const InternalEvidenceAdapterPrototypeValidationRequest(),
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
    final packetRows = _rowsFromReview(reviewResult.rows);
    final checks = _checksFor(
      reviewResult: reviewResult,
      prototypeResult: prototypeResult,
      designResult: designResult,
      summaryResult: summaryResult,
      packetRows: packetRows,
      androidProofEvidence: request.androidProofEvidence,
    );
    final base = _resultFromRowsAndChecks(
      reviewResult: reviewResult,
      prototypeResult: prototypeResult,
      designResult: designResult,
      summaryResult: summaryResult,
      readinessResult: readinessResult,
      packetRows: packetRows,
      checks: checks,
      validationFindings:
          const <InternalEvidenceAdapterPrototypeValidationFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromRowsAndChecks(
      reviewResult: reviewResult,
      prototypeResult: prototypeResult,
      designResult: designResult,
      summaryResult: summaryResult,
      readinessResult: readinessResult,
      packetRows: packetRows,
      checks: checks,
      validationFindings: findings,
    );
  }
}

class InternalEvidenceAdapterPrototypeValidationValidator {
  const InternalEvidenceAdapterPrototypeValidationValidator();

  List<InternalEvidenceAdapterPrototypeValidationFinding> validate(
    InternalEvidenceAdapterPrototypeValidationResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <InternalEvidenceAdapterPrototypeValidationFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required InternalEvidenceAdapterPrototypeValidationSeverity severity,
      required String message,
      String? validationRowId,
      String? adapterPacketId,
      InternalEvidenceSummaryGroupId? groupId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        InternalEvidenceAdapterPrototypeValidationFinding(
          id: id,
          severity: severity,
          message: message,
          validationRowId: validationRowId,
          adapterPacketId: adapterPacketId,
          groupId: groupId,
          fieldId: fieldId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase32Q &&
        (result.sourceReviewStatus ==
                InternalEvidenceAdapterPrototypeReviewStatus
                    .blockedByUnsafePrototype ||
            result.unsafePacketCount > 0)) {
      add(
        id: 'unsafeReviewMarkedValidated',
        severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
        message: 'unsafe adapter prototype review cannot be marked validated',
      );
    }

    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: InternalEvidenceAdapterPrototypeValidationSeverity.blocker,
        message: 'owner proof requires explicit PV/MultiPV reason',
      );
    }

    for (final fieldId in _blockedOutputFieldIds) {
      if (!result.blockedOutputFieldIds.contains(fieldId)) {
        add(
          id: 'blockedOutputFieldMissing',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.blocker,
          message: '$fieldId must remain a blocked output field',
          fieldId: fieldId,
        );
      }
    }

    for (final row in result.packetRows) {
      for (final fieldId in row.activeOutputFieldIds) {
        _checkActiveField(
          add,
          fieldId,
          validationRowId: row.validationRowId,
          adapterPacketId: row.adapterPacketId,
          groupId: _firstGroupId(row),
        );
      }
      if (row.adapterRole ==
              InternalEvidenceAdapterPacketRole.coreEvidencePacket &&
          !row.sourceSummaryGroupIds.every(_coreGroupIds.contains)) {
        add(
          id: 'corePacketFromNonCoreSource',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: '${row.adapterPacketId} core packet has non-core source',
          validationRowId: row.validationRowId,
          adapterPacketId: row.adapterPacketId,
          groupId: _firstGroupId(row),
        );
      }
      if (_contextOnlyGroupIds.any(row.sourceSummaryGroupIds.contains) &&
          row.adapterRole ==
              InternalEvidenceAdapterPacketRole.coreEvidencePacket) {
        add(
          id: 'contextOnlyPacketPromotedToCore',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: '${row.adapterPacketId} promoted context-only evidence',
          validationRowId: row.validationRowId,
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
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: '${row.adapterPacketId} must remain inactive',
          validationRowId: row.validationRowId,
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
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: '${row.adapterPacketId} must remain future-only',
          validationRowId: row.validationRowId,
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
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.blocker,
          message: 'core validation row requires support and evidence IDs',
          validationRowId: row.validationRowId,
          adapterPacketId: row.adapterPacketId,
          groupId: _firstGroupId(row),
        );
      }
      if (row.isProductOutput) {
        add(
          id: 'productOutputActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'validated packet cannot be product output',
          validationRowId: row.validationRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.isClassifierLabel) {
        add(
          id: 'classifierLabelOutputActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'validated packet cannot emit classifier labels',
          validationRowId: row.validationRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.isOfficialMetric) {
        add(
          id: 'officialMetricOutputActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'validated packet cannot emit official metrics',
          validationRowId: row.validationRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.hasNumericScore) {
        add(
          id: 'numericScoreOutputActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'validated packet cannot emit numeric move values',
          validationRowId: row.validationRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.ranksMoves) {
        add(
          id: 'moveRankingOutputActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'validated packet cannot order moves',
          validationRowId: row.validationRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.cpLossOutputActive || row.winProbabilityOutputActive) {
        add(
          id: 'futureMetricOutputActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message:
              'validated packet cannot activate CP-loss or win probability',
          validationRowId: row.validationRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.quietPreparatoryScopeActive) {
        add(
          id: 'quietPreparatoryScopeActivated',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'quiet/preparatory scope must remain excluded',
          validationRowId: row.validationRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.callsEngine) {
        add(
          id: 'engineCallFlagActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'validated packet cannot call an engine',
          validationRowId: row.validationRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.writesPersistence) {
        add(
          id: 'persistenceWriteFlagActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'validated packet cannot write persistence',
          validationRowId: row.validationRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.targetsUi) {
        add(
          id: 'uiTargetFlagActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'validated packet cannot target UI',
          validationRowId: row.validationRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      if (row.backendOutputActive) {
        add(
          id: 'backendOutputActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'validated packet cannot target backend output',
          validationRowId: row.validationRowId,
          adapterPacketId: row.adapterPacketId,
        );
      }
      for (final caseId in row.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          validationRowId: row.validationRowId,
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
        id: 'validationBoundaryPolicyViolation',
        severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
        message:
            'adapter prototype validation crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<InternalEvidenceAdapterPrototypeValidationFinding> validateReportText(
    String reportText,
  ) {
    final findings = <InternalEvidenceAdapterPrototypeValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        InternalEvidenceAdapterPrototypeValidationFinding(
          id: id,
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
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

List<InternalEvidenceAdapterPrototypeValidationRow> _rowsFromReview(
  List<InternalEvidenceAdapterPrototypeReviewRow> reviewRows,
) {
  return reviewRows.map(_rowFromReviewRow).toList(growable: false);
}

InternalEvidenceAdapterPrototypeValidationRow _rowFromReviewRow(
  InternalEvidenceAdapterPrototypeReviewRow reviewRow,
) {
  final violationReasons = _violationReasonsFor(reviewRow);
  final status = _rowStatusFor(reviewRow, violationReasons);
  final contractSatisfied =
      violationReasons.isEmpty &&
      reviewRow.reviewStatus !=
          InternalEvidenceAdapterPrototypeReviewRowStatus.invalidPacket &&
      reviewRow.reviewStatus !=
          InternalEvidenceAdapterPrototypeReviewRowStatus.unsafePacket;
  final safetySatisfied = !reviewRow.hasUnsafeOutput;
  return InternalEvidenceAdapterPrototypeValidationRow(
    validationRowId: 'validation-${reviewRow.adapterPacketId}',
    adapterPacketId: reviewRow.adapterPacketId,
    sourceReviewRowId: reviewRow.reviewRowId,
    adapterRole: reviewRow.adapterRole,
    reviewStatus: reviewRow.reviewStatus,
    validationStatus: status,
    sourceSummaryGroupIds: _sortedGroupIds(reviewRow.sourceSummaryGroupIds),
    allowedEvidenceRecordIds: _sortedStrings(
      reviewRow.allowedEvidenceRecordIds,
    ),
    supportCaseIds: _sortedStrings(reviewRow.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(
      reviewRow.newlyAddedSupportCaseIds,
    ),
    activeOutputFieldIds: _sortedStrings(reviewRow.activeOutputFieldIds),
    blockedOutputFieldIds: _sortedStrings(reviewRow.blockedOutputFieldIds),
    androidProofCaseIds: _sortedStrings(reviewRow.androidProofCaseIds),
    contractSatisfied: contractSatisfied,
    safetySatisfied: safetySatisfied,
    violationReasons: violationReasons,
    safeForNextGate:
        contractSatisfied &&
        safetySatisfied &&
        status !=
            InternalEvidenceAdapterPrototypePacketValidationStatus
                .invalidPacket &&
        !status.isUnsafe,
    recommendation: _recommendationFor(status),
    isProductOutput: reviewRow.isProductOutput,
    isClassifierLabel: reviewRow.isClassifierLabel,
    isOfficialMetric: reviewRow.isOfficialMetric,
    hasNumericScore: reviewRow.hasNumericScore,
    ranksMoves: reviewRow.ranksMoves,
    callsEngine: reviewRow.callsEngine,
    writesPersistence: reviewRow.writesPersistence,
    targetsUi: reviewRow.targetsUi,
    cpLossOutputActive: reviewRow.cpLossOutputActive,
    winProbabilityOutputActive: reviewRow.winProbabilityOutputActive,
    quietPreparatoryScopeActive: reviewRow.quietPreparatoryScopeActive,
    backendOutputActive: reviewRow.backendOutputActive,
  );
}

List<String> _violationReasonsFor(
  InternalEvidenceAdapterPrototypeReviewRow row,
) {
  final reasons = <String>[];
  if (row.hasUnsafeOutput) {
    reasons.add('unsafe output boundary active');
  }
  if (row.reviewStatus ==
      InternalEvidenceAdapterPrototypeReviewRowStatus.invalidPacket) {
    reasons.add('source review row is invalid');
  }
  if (row.reviewStatus ==
      InternalEvidenceAdapterPrototypeReviewRowStatus.unsafePacket) {
    reasons.add('source review row is unsafe');
  }
  if (row.adapterRole.isCore &&
      !row.sourceSummaryGroupIds.every(_coreGroupIds.contains)) {
    reasons.add('core packet source is not allowed');
  }
  if (row.adapterRole.isCore &&
      (row.supportCaseIds.isEmpty || row.allowedEvidenceRecordIds.isEmpty)) {
    reasons.add('core packet missing support mapping');
  }
  if (row.adapterRole.isContextOnly &&
      !row.sourceSummaryGroupIds.every(_contextOnlyGroupIds.contains)) {
    reasons.add('context-only packet source is not constrained context');
  }
  if (row.adapterRole.isContextOnly &&
      row.activeOutputFieldIds.any(_isBlockedOutputFieldId)) {
    reasons.add('context-only packet activated blocked field');
  }
  if (_contextOnlyGroupIds.any(row.sourceSummaryGroupIds.contains) &&
      row.adapterRole == InternalEvidenceAdapterPacketRole.coreEvidencePacket) {
    reasons.add('context-only packet promoted to core');
  }
  if (_blockedGroupIds.any(row.sourceSummaryGroupIds.contains) &&
      !_reviewRowIsInactiveSafe(row)) {
    reasons.add('blocked packet became active');
  }
  if (row.sourceSummaryGroupIds.contains(
        InternalEvidenceSummaryGroupId.futureOnlySummary,
      ) &&
      !_reviewRowIsInactiveSafe(row)) {
    reasons.add('future-only packet became active');
  }
  if (row.sourceSummaryGroupIds.contains(
        InternalEvidenceSummaryGroupId.constrainedWatchListSummary,
      ) &&
      row.watchListReason.trim().isEmpty) {
    reasons.add('watch-listed context reason missing');
  }
  if (row.sourceSummaryGroupIds.contains(
        InternalEvidenceSummaryGroupId.proofLimitedSummary,
      ) &&
      row.proofLimitReason.trim().isEmpty) {
    reasons.add('proof-limited context reason missing');
  }
  if (row.sourceSummaryGroupIds.contains(
        InternalEvidenceSummaryGroupId.warningLimitedSummary,
      ) &&
      row.warningLimitedReason.trim().isEmpty) {
    reasons.add('warning-limited context reason missing');
  }
  return _sortedStrings(reasons);
}

InternalEvidenceAdapterPrototypePacketValidationStatus _rowStatusFor(
  InternalEvidenceAdapterPrototypeReviewRow row,
  List<String> violationReasons,
) {
  if (row.hasUnsafeOutput ||
      row.reviewStatus ==
          InternalEvidenceAdapterPrototypeReviewRowStatus.unsafePacket) {
    return InternalEvidenceAdapterPrototypePacketValidationStatus.unsafePacket;
  }
  if (violationReasons.isNotEmpty) {
    return InternalEvidenceAdapterPrototypePacketValidationStatus.invalidPacket;
  }
  return switch (row.adapterRole) {
    InternalEvidenceAdapterPacketRole.coreEvidencePacket =>
      InternalEvidenceAdapterPrototypePacketValidationStatus.validCorePacket,
    InternalEvidenceAdapterPacketRole.contextOnlyPacket =>
      InternalEvidenceAdapterPrototypePacketValidationStatus
          .validContextOnlyPacket,
    InternalEvidenceAdapterPacketRole.blockedBoundaryPacket =>
      InternalEvidenceAdapterPrototypePacketValidationStatus.validBlockedPacket,
    InternalEvidenceAdapterPacketRole.futureOnlyPacket =>
      InternalEvidenceAdapterPrototypePacketValidationStatus
          .validFutureOnlyPacket,
  };
}

InternalEvidenceAdapterPrototypeValidationRecommendation _recommendationFor(
  InternalEvidenceAdapterPrototypePacketValidationStatus status,
) {
  return switch (status) {
    InternalEvidenceAdapterPrototypePacketValidationStatus.validCorePacket =>
      InternalEvidenceAdapterPrototypeValidationRecommendation.keepCorePacket,
    InternalEvidenceAdapterPrototypePacketValidationStatus
        .validContextOnlyPacket =>
      InternalEvidenceAdapterPrototypeValidationRecommendation
          .keepContextOnlyPacket,
    InternalEvidenceAdapterPrototypePacketValidationStatus.validBlockedPacket =>
      InternalEvidenceAdapterPrototypeValidationRecommendation
          .keepBlockedPacket,
    InternalEvidenceAdapterPrototypePacketValidationStatus
        .validFutureOnlyPacket =>
      InternalEvidenceAdapterPrototypeValidationRecommendation
          .keepFutureOnlyPacket,
    InternalEvidenceAdapterPrototypePacketValidationStatus.invalidPacket =>
      InternalEvidenceAdapterPrototypeValidationRecommendation
          .investigateInvalidPacket,
    InternalEvidenceAdapterPrototypePacketValidationStatus.unsafePacket =>
      InternalEvidenceAdapterPrototypeValidationRecommendation
          .blockUnsafePacket,
  };
}

List<InternalEvidenceAdapterPrototypeValidationCheck> _checksFor({
  required InternalEvidenceAdapterPrototypeReviewResult reviewResult,
  required InternalEvidenceAdapterPrototypeResult prototypeResult,
  required InternalEvidenceAdapterDesignResult designResult,
  required InternalEvidenceSummaryLayerResult summaryResult,
  required List<InternalEvidenceAdapterPrototypeValidationRow> packetRows,
  required GoldenAndroidProofEvidence? androidProofEvidence,
}) {
  final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
  final allProofIds = _sortedStrings(<String>[
    ...reviewResult.androidProofCaseIds,
    ...packetRows.expand((row) => row.androidProofCaseIds),
  ]);
  final activeBlockedFields = _sortedStrings(
    packetRows
        .expand((row) => row.activeOutputFieldIds)
        .where(_isBlockedOutputFieldId),
  );
  final missingBlockedFields = _sortedStrings(
    _blockedOutputFieldIds.where(
      (fieldId) => !reviewResult.blockedOutputFieldIds.contains(fieldId),
    ),
  );
  final policyFieldIds = _sortedStrings(<String>[
    ...activeBlockedFields,
    if (packetRows.any((row) => row.isProductOutput)) 'productLabel',
    if (packetRows.any((row) => row.isClassifierLabel)) 'classifierLabelOutput',
    if (packetRows.any((row) => row.hasNumericScore)) 'numericMoveScore',
    if (packetRows.any((row) => row.ranksMoves)) 'moveRanking',
    if (packetRows.any((row) => row.isOfficialMetric)) 'officialMetric',
    if (packetRows.any((row) => row.cpLossOutputActive)) 'cpLoss',
    if (packetRows.any((row) => row.winProbabilityOutputActive))
      'winProbability',
  ]);
  final integrationFieldIds = _sortedStrings(<String>[
    if (packetRows.any((row) => row.callsEngine)) 'directEngineCallFields',
    if (packetRows.any((row) => row.writesPersistence))
      'backendPersistenceFields',
    if (packetRows.any((row) => row.targetsUi)) 'uiOutputFields',
    if (packetRows.any((row) => row.backendOutputActive))
      'backendPersistenceFields',
  ]);
  final unprovenProofIds = _sortedStrings(
    allProofIds.where(
      (id) =>
          !_capturedAndroidProofIds.contains(id) ||
          !provenAndroidIds.contains(id),
    ),
  );
  final phase32EProofIds = _sortedStrings(
    allProofIds.where(_phase32ECaseIds.contains),
  );

  return <InternalEvidenceAdapterPrototypeValidationCheck>[
    _check(
      checkId: 'prototypeConsumesApprovedDesign',
      ok:
          reviewResult.safeForPhase32P &&
          prototypeResult.safeForPhase32O &&
          designResult.safeForPhase32N &&
          summaryResult.safeForPhase32M,
      failedStatus:
          InternalEvidenceAdapterPrototypeValidationCheckStatus.blocked,
      failedSeverity:
          InternalEvidenceAdapterPrototypeValidationSeverity.blocker,
      failureReason:
          'Phase 32O review or upstream adapter contract is not safe',
      recommendation:
          'repair upstream adapter prototype contract before validation',
    ),
    _check(
      checkId: 'corePacketsUseOnlyCoreSources',
      ok: packetRows
          .where((row) => row.adapterRole.isCore)
          .every(
            (row) => row.sourceSummaryGroupIds.every(_coreGroupIds.contains),
          ),
      relatedPacketIds: packetRows
          .where(
            (row) =>
                row.adapterRole.isCore &&
                !row.sourceSummaryGroupIds.every(_coreGroupIds.contains),
          )
          .map((row) => row.adapterPacketId),
      failureReason: 'core packet uses non-core source summary',
      recommendation: 'keep core packets limited to approved core summaries',
    ),
    _check(
      checkId: 'contextOnlyPacketsStayContextOnly',
      ok: packetRows
          .where(
            (row) =>
                _contextOnlyGroupIds.any(row.sourceSummaryGroupIds.contains),
          )
          .every((row) => row.adapterRole.isContextOnly),
      warning: packetRows.any((row) => row.adapterRole.isContextOnly),
      relatedPacketIds: packetRows
          .where((row) => row.adapterRole.isContextOnly)
          .map((row) => row.adapterPacketId),
      warningReason:
          'context-only validation rows remain outside core packet output',
      failureReason: 'context-only source was promoted to core packet output',
      recommendation: 'preserve context-only packet role',
    ),
    _check(
      checkId: 'blockedFuturePacketsStayInactive',
      ok: packetRows
          .where(
            (row) =>
                _blockedGroupIds.any(row.sourceSummaryGroupIds.contains) ||
                row.sourceSummaryGroupIds.contains(
                  InternalEvidenceSummaryGroupId.futureOnlySummary,
                ),
          )
          .every(_rowIsInactiveSafe),
      warning: packetRows.any(
        (row) =>
            row.adapterRole ==
                InternalEvidenceAdapterPacketRole.blockedBoundaryPacket ||
            row.adapterRole ==
                InternalEvidenceAdapterPacketRole.futureOnlyPacket,
      ),
      relatedPacketIds: packetRows
          .where(
            (row) =>
                row.adapterRole ==
                    InternalEvidenceAdapterPacketRole.blockedBoundaryPacket ||
                row.adapterRole ==
                    InternalEvidenceAdapterPacketRole.futureOnlyPacket,
          )
          .map((row) => row.adapterPacketId),
      warningReason: 'blocked and future-only validation rows remain inactive',
      failureReason: 'blocked or future-only packet became active',
      recommendation: 'keep blocked and future-only packets inactive',
    ),
    _check(
      checkId: 'activeOutputFieldsAreInternalOnly',
      ok:
          activeBlockedFields.isEmpty &&
          !packetRows.any((row) => row.hasUnsafeOutput),
      relatedPacketIds: packetRows
          .where((row) => row.hasUnsafeOutput)
          .map((row) => row.adapterPacketId),
      relatedFieldIds: activeBlockedFields,
      failureReason: 'active output field crossed a blocked boundary',
      recommendation: 'remove blocked fields from active validation output',
    ),
    _check(
      checkId: 'blockedOutputFieldsRemainBlocked',
      ok: missingBlockedFields.isEmpty && activeBlockedFields.isEmpty,
      failedSeverity:
          InternalEvidenceAdapterPrototypeValidationSeverity.blocker,
      relatedFieldIds: <String>[
        ...missingBlockedFields,
        ...activeBlockedFields,
      ],
      failureReason: 'blocked output field missing or active',
      recommendation: 'restore blocked output field denials',
    ),
    _check(
      checkId: 'androidProofIdsAreCapturedOnly',
      ok:
          unprovenProofIds.isEmpty &&
          _setEquals(
            reviewResult.androidProofCaseIds,
            _capturedAndroidProofIds,
          ),
      failedSeverity:
          InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      relatedProofIds: unprovenProofIds.isEmpty
          ? allProofIds
          : unprovenProofIds,
      failureReason: 'Android proof IDs are not limited to captured proof',
      recommendation: 'remove unproven Android proof IDs from validation',
    ),
    _check(
      checkId: 'phase32ECasesAreNotCapturedProof',
      ok: phase32EProofIds.isEmpty,
      failedSeverity:
          InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      relatedProofIds: phase32EProofIds,
      failureReason: 'Phase 32E case was treated as captured Android proof',
      recommendation: 'keep Phase 32E cases as support only',
    ),
    _check(
      checkId: 'ownerProofQueueRemainsEmpty',
      ok: reviewResult.ownerProofQueueCount == 0,
      failedSeverity:
          InternalEvidenceAdapterPrototypeValidationSeverity.blocker,
      failureReason: 'owner proof queue is not empty by default',
      recommendation: 'require explicit PV/MultiPV owner proof reason',
    ),
    _check(
      checkId: 'noLabelsScoresRankingsMetrics',
      ok:
          policyFieldIds.isEmpty &&
          !reviewResult.productOutputActive &&
          !reviewResult.classifierOutputActive &&
          !reviewResult.finalMoveLabelOutputActive &&
          !reviewResult.officialMetricOutputActive &&
          !reviewResult.numericOutputActive &&
          !reviewResult.moveRankingOutputActive &&
          !reviewResult.cpLossOutputActive &&
          !reviewResult.winProbabilityOutputActive,
      failedSeverity:
          InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      relatedFieldIds: policyFieldIds,
      failureReason: 'labels, scores, rankings, or metrics became active',
      recommendation: 'keep product and scoring families blocked',
    ),
    _check(
      checkId: 'noUiBackendPersistenceEngineFlags',
      ok:
          integrationFieldIds.isEmpty &&
          !reviewResult.engineCallsActive &&
          !reviewResult.persistenceWritesActive &&
          !reviewResult.uiTargetsActive &&
          !reviewResult.backendOutputActive,
      failedSeverity:
          InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      relatedFieldIds: integrationFieldIds,
      failureReason: 'UI, backend, persistence, or engine flag became active',
      recommendation: 'remove integration flags from validation',
    ),
    _check(
      checkId: 'quietScopeRemainsExcluded',
      ok:
          !reviewResult.quietPreparatoryScopeActivated &&
          !packetRows.any((row) => row.quietPreparatoryScopeActive),
      failedSeverity:
          InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      relatedPacketIds: packetRows
          .where((row) => row.quietPreparatoryScopeActive)
          .map((row) => row.adapterPacketId),
      failureReason: 'quiet/preparatory scope became active',
      recommendation: 'keep quiet/preparatory scope excluded',
    ),
    _check(
      checkId: 'productBoundariesRemainBlocked',
      ok:
          missingBlockedFields.isEmpty &&
          activeBlockedFields.isEmpty &&
          !reviewResult.productOutputActive &&
          !reviewResult.classifierOutputActive &&
          !reviewResult.backendOutputActive,
      failedSeverity:
          InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      relatedFieldIds: <String>[
        ...missingBlockedFields,
        ...activeBlockedFields,
      ],
      failureReason: 'product or integration boundary became available',
      recommendation: 'keep adapter validation developer-only',
    ),
  ]..sort((a, b) => a.checkId.compareTo(b.checkId));
}

InternalEvidenceAdapterPrototypeValidationCheck _check({
  required String checkId,
  required bool ok,
  bool warning = false,
  Iterable<String> relatedPacketIds = const <String>[],
  Iterable<String> relatedFieldIds = const <String>[],
  Iterable<String> relatedProofIds = const <String>[],
  InternalEvidenceAdapterPrototypeValidationCheckStatus failedStatus =
      InternalEvidenceAdapterPrototypeValidationCheckStatus.failed,
  InternalEvidenceAdapterPrototypeValidationSeverity failedSeverity =
      InternalEvidenceAdapterPrototypeValidationSeverity.critical,
  String warningReason = '',
  String failureReason = '',
  required String recommendation,
}) {
  if (!ok) {
    return InternalEvidenceAdapterPrototypeValidationCheck(
      checkId: checkId,
      checkStatus: failedStatus,
      severity: failedSeverity,
      relatedPacketIds: _sortedStrings(relatedPacketIds),
      relatedFieldIds: _sortedStrings(relatedFieldIds),
      relatedProofIds: _sortedStrings(relatedProofIds),
      warningReason: '',
      failureReason: failureReason,
      recommendation: recommendation,
    );
  }
  if (warning) {
    return InternalEvidenceAdapterPrototypeValidationCheck(
      checkId: checkId,
      checkStatus: InternalEvidenceAdapterPrototypeValidationCheckStatus
          .passedWithWarnings,
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.warning,
      relatedPacketIds: _sortedStrings(relatedPacketIds),
      relatedFieldIds: _sortedStrings(relatedFieldIds),
      relatedProofIds: _sortedStrings(relatedProofIds),
      warningReason: warningReason,
      failureReason: '',
      recommendation: recommendation,
    );
  }
  return InternalEvidenceAdapterPrototypeValidationCheck(
    checkId: checkId,
    checkStatus: InternalEvidenceAdapterPrototypeValidationCheckStatus.passed,
    severity: InternalEvidenceAdapterPrototypeValidationSeverity.none,
    relatedPacketIds: _sortedStrings(relatedPacketIds),
    relatedFieldIds: _sortedStrings(relatedFieldIds),
    relatedProofIds: _sortedStrings(relatedProofIds),
    warningReason: '',
    failureReason: '',
    recommendation: recommendation,
  );
}

InternalEvidenceAdapterPrototypeValidationResult _resultFromRowsAndChecks({
  required InternalEvidenceAdapterPrototypeReviewResult reviewResult,
  required InternalEvidenceAdapterPrototypeResult prototypeResult,
  required InternalEvidenceAdapterDesignResult designResult,
  required InternalEvidenceSummaryLayerResult summaryResult,
  required RefreshedPacketEvidenceReadinessGateResult readinessResult,
  required List<InternalEvidenceAdapterPrototypeValidationRow> packetRows,
  required List<InternalEvidenceAdapterPrototypeValidationCheck> checks,
  required List<InternalEvidenceAdapterPrototypeValidationFinding>
  validationFindings,
}) {
  final unsafePacketCount = packetRows
      .where(
        (row) =>
            row.hasUnsafeOutput ||
            row.validationStatus ==
                InternalEvidenceAdapterPrototypePacketValidationStatus
                    .unsafePacket,
      )
      .length;
  final invalidPacketCount = packetRows
      .where(
        (row) =>
            row.validationStatus ==
            InternalEvidenceAdapterPrototypePacketValidationStatus
                .invalidPacket,
      )
      .length;
  final blockerCount =
      checks
          .where(
            (check) =>
                check.severity ==
                    InternalEvidenceAdapterPrototypeValidationSeverity
                        .blocker ||
                check.checkStatus ==
                    InternalEvidenceAdapterPrototypeValidationCheckStatus
                        .blocked,
          )
          .length +
      validationFindings
          .where(
            (finding) =>
                finding.severity ==
                InternalEvidenceAdapterPrototypeValidationSeverity.blocker,
          )
          .length;
  final criticalCount =
      checks.where((check) => check.isCritical).length +
      validationFindings.where((finding) => finding.isCritical).length;
  final base = InternalEvidenceAdapterPrototypeValidationResult(
    validationStatus: InternalEvidenceAdapterPrototypeValidationStatus.invalid,
    sourceReviewStatus: reviewResult.reviewStatus,
    sourcePrototypeStatus: prototypeResult.prototypeStatus,
    sourceDesignStatus: designResult.designStatus,
    sourceSummaryStatus: summaryResult.summaryStatus,
    sourceReadinessStatus: readinessResult.readinessStatus,
    checks: checks,
    packetRows: packetRows,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...reviewResult.warnings,
      ...checks
          .where(
            (check) =>
                check.checkStatus ==
                    InternalEvidenceAdapterPrototypeValidationCheckStatus
                        .passedWithWarnings &&
                check.warningReason.isNotEmpty,
          )
          .map((check) => check.warningReason),
    ]),
    failures: _sortedStrings(<String>[
      ...reviewResult.failures,
      ...packetRows.expand((row) => row.violationReasons),
      ...checks
          .where((check) => check.failureReason.isNotEmpty)
          .map((check) => check.failureReason),
      ...validationFindings.map((finding) => finding.message),
    ]),
    totalChecks: checks.length,
    passedCheckCount: checks
        .where(
          (check) =>
              check.checkStatus ==
              InternalEvidenceAdapterPrototypeValidationCheckStatus.passed,
        )
        .length,
    warningCheckCount: checks
        .where(
          (check) =>
              check.checkStatus ==
              InternalEvidenceAdapterPrototypeValidationCheckStatus
                  .passedWithWarnings,
        )
        .length,
    blockerCount: blockerCount,
    criticalCount: criticalCount,
    totalPacketRows: packetRows.length,
    validCorePacketCount: packetRows
        .where(
          (row) =>
              row.validationStatus ==
              InternalEvidenceAdapterPrototypePacketValidationStatus
                  .validCorePacket,
        )
        .length,
    validContextOnlyPacketCount: packetRows
        .where(
          (row) =>
              row.validationStatus ==
              InternalEvidenceAdapterPrototypePacketValidationStatus
                  .validContextOnlyPacket,
        )
        .length,
    validBlockedPacketCount: packetRows
        .where(
          (row) =>
              row.validationStatus ==
              InternalEvidenceAdapterPrototypePacketValidationStatus
                  .validBlockedPacket,
        )
        .length,
    validFutureOnlyPacketCount: packetRows
        .where(
          (row) =>
              row.validationStatus ==
              InternalEvidenceAdapterPrototypePacketValidationStatus
                  .validFutureOnlyPacket,
        )
        .length,
    invalidPacketCount: invalidPacketCount,
    invalidCount: invalidPacketCount,
    unsafePacketCount: unsafePacketCount,
    unsafeCount: unsafePacketCount,
    ownerProofQueueCount: reviewResult.ownerProofQueueCount,
    supportCaseIds: _sortedStrings(
      packetRows.expand((row) => row.supportCaseIds),
    ),
    newlyAddedSupportCaseIds: _sortedStrings(
      packetRows.expand((row) => row.newlyAddedSupportCaseIds),
    ),
    androidProofCaseIds: _sortedStrings(reviewResult.androidProofCaseIds),
    activeOutputFieldIds: _sortedStrings(
      packetRows.expand((row) => row.activeOutputFieldIds),
    ),
    blockedOutputFieldIds: _sortedStrings(reviewResult.blockedOutputFieldIds),
    safeForPhase32Q: false,
    phase32QRecommendation:
        InternalEvidenceAdapterPrototypeValidationPhase32QRecommendation
            .addMoreGoldenCoverageFirst,
    productOutputActive:
        reviewResult.productOutputActive ||
        packetRows.any((row) => row.isProductOutput),
    classifierOutputActive:
        reviewResult.classifierOutputActive ||
        packetRows.any((row) => row.isClassifierLabel),
    finalMoveLabelOutputActive: reviewResult.finalMoveLabelOutputActive,
    officialMetricOutputActive:
        reviewResult.officialMetricOutputActive ||
        packetRows.any((row) => row.isOfficialMetric),
    cpLossOutputActive:
        reviewResult.cpLossOutputActive ||
        packetRows.any((row) => row.cpLossOutputActive),
    winProbabilityOutputActive:
        reviewResult.winProbabilityOutputActive ||
        packetRows.any((row) => row.winProbabilityOutputActive),
    numericOutputActive:
        reviewResult.numericOutputActive ||
        packetRows.any((row) => row.hasNumericScore),
    moveRankingOutputActive:
        reviewResult.moveRankingOutputActive ||
        packetRows.any((row) => row.ranksMoves),
    quietPreparatoryScopeActivated:
        reviewResult.quietPreparatoryScopeActivated ||
        packetRows.any((row) => row.quietPreparatoryScopeActive),
    engineCallsActive:
        reviewResult.engineCallsActive ||
        packetRows.any((row) => row.callsEngine),
    persistenceWritesActive:
        reviewResult.persistenceWritesActive ||
        packetRows.any((row) => row.writesPersistence),
    uiTargetsActive:
        reviewResult.uiTargetsActive || packetRows.any((row) => row.targetsUi),
    backendOutputActive:
        reviewResult.backendOutputActive ||
        packetRows.any((row) => row.backendOutputActive),
  );
  final status = _validationStatusFor(
    base,
    reviewResult: reviewResult,
    prototypeResult: prototypeResult,
    designResult: designResult,
    summaryResult: summaryResult,
    invalidPacketCount: invalidPacketCount,
  );
  final safeForPhase32Q =
      (status ==
              InternalEvidenceAdapterPrototypeValidationStatus
                  .validatedWithWarnings ||
          status ==
              InternalEvidenceAdapterPrototypeValidationStatus
                  .validatedClean) &&
      reviewResult.safeForPhase32P &&
      !reviewResult.isStrictlyBlocked &&
      !reviewResult.hasUnsafeAdapterReviewPolicyViolation &&
      prototypeResult.safeForPhase32O &&
      designResult.safeForPhase32N &&
      summaryResult.safeForPhase32M &&
      readinessResult.safeForPhase32L &&
      unsafePacketCount == 0 &&
      invalidPacketCount == 0 &&
      blockerCount == 0 &&
      criticalCount == 0 &&
      !checks.any((check) => check.blocksStrict) &&
      !validationFindings.any((finding) => finding.blocksStrict) &&
      packetRows.every((row) => row.safeForNextGate);
  return base.copyWith(
    validationStatus: status,
    safeForPhase32Q: safeForPhase32Q,
    phase32QRecommendation: _phase32QRecommendationFor(
      status: status,
      safeForPhase32Q: safeForPhase32Q,
      ownerProofQueueCount: reviewResult.ownerProofQueueCount,
    ),
  );
}

InternalEvidenceAdapterPrototypeValidationStatus _validationStatusFor(
  InternalEvidenceAdapterPrototypeValidationResult result, {
  required InternalEvidenceAdapterPrototypeReviewResult reviewResult,
  required InternalEvidenceAdapterPrototypeResult prototypeResult,
  required InternalEvidenceAdapterDesignResult designResult,
  required InternalEvidenceSummaryLayerResult summaryResult,
  required int invalidPacketCount,
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
    return InternalEvidenceAdapterPrototypeValidationStatus
        .blockedByPolicyBoundary;
  }
  if (reviewResult.reviewStatus ==
          InternalEvidenceAdapterPrototypeReviewStatus
              .blockedByUnsafePrototype ||
      reviewResult.unsafeCount > 0 ||
      result.unsafePacketCount > 0) {
    return InternalEvidenceAdapterPrototypeValidationStatus
        .blockedByUnsafeReview;
  }
  if (!reviewResult.safeForPhase32P ||
      reviewResult.isStrictlyBlocked ||
      !prototypeResult.safeForPhase32O ||
      prototypeResult.isStrictlyBlocked ||
      !designResult.safeForPhase32N ||
      designResult.isStrictlyBlocked ||
      !summaryResult.safeForPhase32M ||
      summaryResult.isStrictlyBlocked ||
      invalidPacketCount > 0 ||
      result.checks.any((check) => check.checkStatus.isBlocked) ||
      _hasContractViolationFinding(result.validationFindings)) {
    return InternalEvidenceAdapterPrototypeValidationStatus
        .blockedByPrototypeContractViolation;
  }
  if (result.criticalCount > 0 ||
      result.validationFindings.any((finding) => finding.isCritical)) {
    return InternalEvidenceAdapterPrototypeValidationStatus
        .blockedByUnsafeReview;
  }
  if (result.blockerCount > 0 ||
      result.validationFindings.any((finding) => finding.blocksStrict)) {
    return InternalEvidenceAdapterPrototypeValidationStatus
        .blockedByPrototypeContractViolation;
  }
  if (result.packetRows.isEmpty || result.checks.isEmpty) {
    return InternalEvidenceAdapterPrototypeValidationStatus.invalid;
  }
  if (result.warningCheckCount > 0 || result.warnings.isNotEmpty) {
    return InternalEvidenceAdapterPrototypeValidationStatus
        .validatedWithWarnings;
  }
  return InternalEvidenceAdapterPrototypeValidationStatus.validatedClean;
}

InternalEvidenceAdapterPrototypeValidationPhase32QRecommendation
_phase32QRecommendationFor({
  required InternalEvidenceAdapterPrototypeValidationStatus status,
  required bool safeForPhase32Q,
  required int ownerProofQueueCount,
}) {
  if (status ==
          InternalEvidenceAdapterPrototypeValidationStatus
              .blockedByUnsafeReview ||
      status ==
          InternalEvidenceAdapterPrototypeValidationStatus
              .blockedByPolicyBoundary) {
    return InternalEvidenceAdapterPrototypeValidationPhase32QRecommendation
        .blockedByUnsafeAdapterValidation;
  }
  if (ownerProofQueueCount > 0) {
    return InternalEvidenceAdapterPrototypeValidationPhase32QRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase32Q) {
    return InternalEvidenceAdapterPrototypeValidationPhase32QRecommendation
        .addMoreGoldenCoverageFirst;
  }
  return InternalEvidenceAdapterPrototypeValidationPhase32QRecommendation
      .proceedToAdapterPrototypeReadinessGate;
}

void _checkActiveField(
  void Function({
    required String id,
    required InternalEvidenceAdapterPrototypeValidationSeverity severity,
    required String message,
    String? validationRowId,
    String? adapterPacketId,
    InternalEvidenceSummaryGroupId? groupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String fieldId, {
  String? validationRowId,
  String? adapterPacketId,
  InternalEvidenceSummaryGroupId? groupId,
}) {
  if (!_isBlockedOutputFieldId(fieldId)) return;
  add(
    id: 'activeBlockedOutputField',
    severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
    message: '$fieldId cannot be an active validation output field',
    validationRowId: validationRowId,
    adapterPacketId: adapterPacketId,
    groupId: groupId,
    fieldId: fieldId,
  );
  if (fieldId == 'productLabel') {
    add(
      id: 'productOutputActive',
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: 'product label field cannot be active',
      validationRowId: validationRowId,
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
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: 'classifier or final label field cannot be active',
      validationRowId: validationRowId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'numericMoveScore') {
    add(
      id: 'numericScoreOutputActive',
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: 'numeric move value field cannot be active',
      validationRowId: validationRowId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'moveRanking') {
    add(
      id: 'moveRankingOutputActive',
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: 'move ordering field cannot be active',
      validationRowId: validationRowId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'officialAccuracy' || fieldId == 'acpl') {
    add(
      id: 'officialMetricOutputActive',
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: 'official metric field cannot be active',
      validationRowId: validationRowId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'cpLoss' || fieldId == 'winProbability') {
    add(
      id: 'futureMetricOutputActive',
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: 'future metric field cannot be active',
      validationRowId: validationRowId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'uiOutputFields') {
    add(
      id: 'uiTargetFlagActive',
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: 'UI field cannot be active',
      validationRowId: validationRowId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'backendPersistenceFields') {
    add(
      id: 'persistenceWriteFlagActive',
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: 'backend or persistence field cannot be active',
      validationRowId: validationRowId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'directEngineCallFields') {
    add(
      id: 'engineCallFlagActive',
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: 'direct engine call field cannot be active',
      validationRowId: validationRowId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
}

void _checkAndroidProofCase(
  void Function({
    required String id,
    required InternalEvidenceAdapterPrototypeValidationSeverity severity,
    required String message,
    String? validationRowId,
    String? adapterPacketId,
    InternalEvidenceSummaryGroupId? groupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String caseId,
  List<String> provenAndroidIds, {
  String? validationRowId,
  String? adapterPacketId,
  InternalEvidenceSummaryGroupId? groupId,
}) {
  if (_phase32ECaseIds.contains(caseId)) {
    add(
      id: 'phase32ECaseClaimedCapturedProof',
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: '$caseId cannot be treated as captured Android proof',
      validationRowId: validationRowId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      caseId: caseId,
    );
  }
  if (!_capturedAndroidProofIds.contains(caseId) ||
      !provenAndroidIds.contains(caseId)) {
    add(
      id: 'unprovenAndroidProofClaim',
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: '$caseId is not captured Android proof for validation',
      validationRowId: validationRowId,
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      caseId: caseId,
    );
  }
}

bool _hasExplicitPvProofReason(
  InternalEvidenceAdapterPrototypeValidationResult result,
) {
  final reasons = <String>[
    ...result.warnings,
    ...result.failures,
    ...result.packetRows.expand((row) => row.violationReasons),
    ...result.packetRows.expand((row) => row.blockedOutputFieldIds),
  ].join(' ').toLowerCase();
  return reasons.contains('pv') || reasons.contains('multipv');
}

bool _hasContractViolationFinding(
  List<InternalEvidenceAdapterPrototypeValidationFinding> findings,
) {
  return findings.any(
    (finding) => _contractViolationFindingIds.contains(finding.id),
  );
}

bool _rowIsInactiveSafe(InternalEvidenceAdapterPrototypeValidationRow row) {
  return row.adapterRole.isInactive &&
      row.activeOutputFieldIds.isEmpty &&
      row.allowedEvidenceRecordIds.isEmpty &&
      !row.hasUnsafeOutput;
}

bool _reviewRowIsInactiveSafe(InternalEvidenceAdapterPrototypeReviewRow row) {
  return row.adapterRole.isInactive &&
      row.activeOutputFieldIds.isEmpty &&
      row.allowedEvidenceRecordIds.isEmpty &&
      !row.hasUnsafeOutput;
}

InternalEvidenceSummaryGroupId? _firstGroupId(
  InternalEvidenceAdapterPrototypeValidationRow row,
) {
  return row.sourceSummaryGroupIds.isEmpty
      ? null
      : row.sourceSummaryGroupIds.first;
}

List<String> _provenAndroidProofIds(GoldenAndroidProofEvidence? evidence) {
  return _sortedStrings(evidence?.targetCaseIds ?? const <String>[]);
}

bool _setEquals(List<String> actual, List<String> expected) {
  final sortedActual = _sortedStrings(actual);
  final sortedExpected = _sortedStrings(expected);
  if (sortedActual.length != sortedExpected.length) return false;
  for (var index = 0; index < sortedActual.length; index += 1) {
    if (sortedActual[index] != sortedExpected[index]) return false;
  }
  return true;
}

int _compareFindings(
  InternalEvidenceAdapterPrototypeValidationFinding a,
  InternalEvidenceAdapterPrototypeValidationFinding b,
) {
  final severity = _severityRank(
    b.severity,
  ).compareTo(_severityRank(a.severity));
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.adapterPacketId ?? '').compareTo(b.adapterPacketId ?? '');
}

int _severityRank(InternalEvidenceAdapterPrototypeValidationSeverity severity) {
  return switch (severity) {
    InternalEvidenceAdapterPrototypeValidationSeverity.none => 0,
    InternalEvidenceAdapterPrototypeValidationSeverity.info => 1,
    InternalEvidenceAdapterPrototypeValidationSeverity.warning => 2,
    InternalEvidenceAdapterPrototypeValidationSeverity.blocker => 3,
    InternalEvidenceAdapterPrototypeValidationSeverity.critical => 4,
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

String _validationRowIds(
  Iterable<InternalEvidenceAdapterPrototypeValidationRow> rows,
) {
  return _ids(rows.map((row) => row.validationRowId));
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
  'contextOnlyPacketPromotedToCore',
  'blockedPacketMadeActive',
  'futureOnlyPacketMadeActive',
  'corePacketMissingSupportMapping',
  'ownerProofRequiredWithoutPvReason',
};

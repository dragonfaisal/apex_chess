/// Developer-only validation of internal adapter readiness summary output.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_adapter_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_review.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_validation.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_summary_layer.dart';

const internalAdapterReadinessSummaryValidationReportVersion =
    'internal-adapter-readiness-summary-validation-v1';

enum InternalAdapterReadinessSummaryValidationStatus {
  validatedWithWarnings('validatedWithWarnings'),
  validatedClean('validatedClean'),
  blockedByUnsafeSummary('blockedByUnsafeSummary'),
  blockedBySummaryMismatch('blockedBySummaryMismatch'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const InternalAdapterReadinessSummaryValidationStatus(this.wire);

  final String wire;
}

enum InternalAdapterReadinessSummaryValidationCheckStatus {
  passed('passed'),
  passedWithWarnings('passedWithWarnings'),
  failed('failed'),
  blocked('blocked'),
  notApplicable('notApplicable');

  const InternalAdapterReadinessSummaryValidationCheckStatus(this.wire);

  final String wire;

  bool get isBlocked =>
      this == InternalAdapterReadinessSummaryValidationCheckStatus.failed ||
      this == InternalAdapterReadinessSummaryValidationCheckStatus.blocked;
}

enum InternalAdapterReadinessSummaryValidationSeverity {
  none('none'),
  info('info'),
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const InternalAdapterReadinessSummaryValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == InternalAdapterReadinessSummaryValidationSeverity.blocker ||
      this == InternalAdapterReadinessSummaryValidationSeverity.critical;

  bool get isCritical =>
      this == InternalAdapterReadinessSummaryValidationSeverity.critical;
}

enum InternalAdapterReadinessSummaryValidationGroupKind {
  allowedCoreSummary('allowedCoreSummary'),
  constrainedContextSummary('constrainedContextSummary'),
  inactiveBlockedSummary('inactiveBlockedSummary'),
  inactiveFutureOnlySummary('inactiveFutureOnlySummary'),
  activeOutputFieldSummary('activeOutputFieldSummary'),
  blockedOutputFieldSummary('blockedOutputFieldSummary'),
  androidProofBoundarySummary('androidProofBoundarySummary'),
  ownerProofStatusSummary('ownerProofStatusSummary');

  const InternalAdapterReadinessSummaryValidationGroupKind(this.wire);

  final String wire;
}

enum InternalAdapterReadinessSummaryGroupValidationStatus {
  validAllowedCoreSummary('validAllowedCoreSummary'),
  validConstrainedContextSummary('validConstrainedContextSummary'),
  validInactiveBlockedSummary('validInactiveBlockedSummary'),
  validInactiveFutureOnlySummary('validInactiveFutureOnlySummary'),
  validActiveOutputFieldSummary('validActiveOutputFieldSummary'),
  validBlockedOutputFieldSummary('validBlockedOutputFieldSummary'),
  validAndroidProofBoundarySummary('validAndroidProofBoundarySummary'),
  validOwnerProofStatusSummary('validOwnerProofStatusSummary'),
  invalidSummary('invalidSummary'),
  unsafeSummary('unsafeSummary');

  const InternalAdapterReadinessSummaryGroupValidationStatus(this.wire);

  final String wire;

  bool get isUnsafe =>
      this ==
      InternalAdapterReadinessSummaryGroupValidationStatus.unsafeSummary;
}

enum InternalAdapterReadinessSummaryValidationRecommendation {
  keepAllowedCoreSummary('keepAllowedCoreSummary'),
  keepContextSummaryConstrained('keepContextSummaryConstrained'),
  keepBlockedSummaryInactive('keepBlockedSummaryInactive'),
  keepFutureOnlySummaryInactive('keepFutureOnlySummaryInactive'),
  keepActiveOutputFieldsInternal('keepActiveOutputFieldsInternal'),
  keepBlockedOutputFieldsDenied('keepBlockedOutputFieldsDenied'),
  keepAndroidProofBoundaryCaptured('keepAndroidProofBoundaryCaptured'),
  keepOwnerProofEmpty('keepOwnerProofEmpty'),
  investigateSummaryValidationFailure('investigateSummaryValidationFailure'),
  blockUnsafeSummaryValidation('blockUnsafeSummaryValidation');

  const InternalAdapterReadinessSummaryValidationRecommendation(this.wire);

  final String wire;
}

enum InternalAdapterReadinessSummaryValidationPhase32TRecommendation {
  proceedToDebugOnlyAdapterBridgeDesign(
    'proceedToDebugOnlyAdapterBridgeDesign',
  ),
  proceedToAdapterReadinessValidationSummary(
    'proceedToAdapterReadinessValidationSummary',
  ),
  proceedToInternalAdapterReadinessReportOnly(
    'proceedToInternalAdapterReadinessReportOnly',
  ),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeSummaryValidation('blockedByUnsafeSummaryValidation');

  const InternalAdapterReadinessSummaryValidationPhase32TRecommendation(
    this.wire,
  );

  final String wire;
}

enum InternalAdapterReadinessSummaryValidationReportFormat {
  markdown('markdown'),
  json('json');

  const InternalAdapterReadinessSummaryValidationReportFormat(this.wire);

  final String wire;
}

class InternalAdapterReadinessSummaryValidationRequest {
  const InternalAdapterReadinessSummaryValidationRequest({
    this.summaryResult,
    this.readinessGateResult,
    this.validationResult,
    this.reviewResult,
    this.prototypeResult,
    this.summary = const InternalAdapterReadinessSummary(),
    this.readinessGate = const InternalEvidenceAdapterPrototypeReadinessGate(),
    this.validation = const InternalEvidenceAdapterPrototypeValidation(),
    this.review = const InternalEvidenceAdapterPrototypeReview(),
    this.adapterPrototype = const InternalEvidenceAdapterPrototype(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const InternalAdapterReadinessSummaryValidationRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final InternalAdapterReadinessSummaryResult? summaryResult;
  final InternalEvidenceAdapterPrototypeReadinessGateResult?
  readinessGateResult;
  final InternalEvidenceAdapterPrototypeValidationResult? validationResult;
  final InternalEvidenceAdapterPrototypeReviewResult? reviewResult;
  final InternalEvidenceAdapterPrototypeResult? prototypeResult;
  final InternalAdapterReadinessSummary summary;
  final InternalEvidenceAdapterPrototypeReadinessGate readinessGate;
  final InternalEvidenceAdapterPrototypeValidation validation;
  final InternalEvidenceAdapterPrototypeReview review;
  final InternalEvidenceAdapterPrototype adapterPrototype;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class InternalAdapterReadinessSummaryValidationCheck {
  const InternalAdapterReadinessSummaryValidationCheck({
    required this.checkId,
    required this.checkStatus,
    required this.severity,
    required this.relatedGroupIds,
    required this.relatedRecordIds,
    required this.relatedPacketIds,
    required this.relatedFieldIds,
    required this.relatedProofIds,
    required this.warningReason,
    required this.failureReason,
    required this.recommendation,
  });

  final String checkId;
  final InternalAdapterReadinessSummaryValidationCheckStatus checkStatus;
  final InternalAdapterReadinessSummaryValidationSeverity severity;
  final List<String> relatedGroupIds;
  final List<String> relatedRecordIds;
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
      'relatedGroupIds': relatedGroupIds,
      'relatedRecordIds': relatedRecordIds,
      'relatedPacketIds': relatedPacketIds,
      'relatedFieldIds': relatedFieldIds,
      'relatedProofIds': relatedProofIds,
      'warningReason': warningReason,
      'failureReason': failureReason,
      'recommendation': recommendation,
    };
  }
}

class InternalAdapterReadinessSummaryValidationRow {
  const InternalAdapterReadinessSummaryValidationRow({
    required this.validationRowId,
    required this.sourceSummaryGroupId,
    required this.validationStatus,
    required this.groupKind,
    required this.groupRecordIds,
    required this.packetIds,
    required this.activeOutputFieldIds,
    required this.blockedOutputFieldIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.ownerProofQueueCount,
    required this.validationReason,
    required this.warningReason,
    required this.violationReasons,
    required this.safeForNextPhase,
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
  final InternalAdapterReadinessSummaryGroupId sourceSummaryGroupId;
  final InternalAdapterReadinessSummaryGroupValidationStatus validationStatus;
  final InternalAdapterReadinessSummaryValidationGroupKind groupKind;
  final List<String> groupRecordIds;
  final List<String> packetIds;
  final List<String> activeOutputFieldIds;
  final List<String> blockedOutputFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final int ownerProofQueueCount;
  final String validationReason;
  final String warningReason;
  final List<String> violationReasons;
  final bool safeForNextPhase;
  final InternalAdapterReadinessSummaryValidationRecommendation recommendation;
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

  InternalAdapterReadinessSummaryValidationRow copyWith({
    String? validationRowId,
    InternalAdapterReadinessSummaryGroupId? sourceSummaryGroupId,
    InternalAdapterReadinessSummaryGroupValidationStatus? validationStatus,
    InternalAdapterReadinessSummaryValidationGroupKind? groupKind,
    List<String>? groupRecordIds,
    List<String>? packetIds,
    List<String>? activeOutputFieldIds,
    List<String>? blockedOutputFieldIds,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    int? ownerProofQueueCount,
    String? validationReason,
    String? warningReason,
    List<String>? violationReasons,
    bool? safeForNextPhase,
    InternalAdapterReadinessSummaryValidationRecommendation? recommendation,
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
    return InternalAdapterReadinessSummaryValidationRow(
      validationRowId: validationRowId ?? this.validationRowId,
      sourceSummaryGroupId: sourceSummaryGroupId ?? this.sourceSummaryGroupId,
      validationStatus: validationStatus ?? this.validationStatus,
      groupKind: groupKind ?? this.groupKind,
      groupRecordIds: groupRecordIds ?? this.groupRecordIds,
      packetIds: packetIds ?? this.packetIds,
      activeOutputFieldIds: activeOutputFieldIds ?? this.activeOutputFieldIds,
      blockedOutputFieldIds:
          blockedOutputFieldIds ?? this.blockedOutputFieldIds,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      validationReason: validationReason ?? this.validationReason,
      warningReason: warningReason ?? this.warningReason,
      violationReasons: violationReasons ?? this.violationReasons,
      safeForNextPhase: safeForNextPhase ?? this.safeForNextPhase,
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
      'sourceSummaryGroupId': sourceSummaryGroupId.wire,
      'validationStatus': validationStatus.wire,
      'groupKind': groupKind.wire,
      'groupRecordIds': groupRecordIds,
      'packetIds': packetIds,
      'activeOutputFieldIds': activeOutputFieldIds,
      'blockedOutputFieldIds': blockedOutputFieldIds,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'ownerProofQueueCount': ownerProofQueueCount,
      'validationReason': validationReason,
      'warningReason': warningReason,
      'violationReasons': violationReasons,
      'safeForNextPhase': safeForNextPhase,
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

class InternalAdapterReadinessSummaryValidationFinding {
  const InternalAdapterReadinessSummaryValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.validationRowId,
    this.sourceSummaryGroupId,
    this.summaryRecordId,
    this.adapterPacketId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final InternalAdapterReadinessSummaryValidationSeverity severity;
  final String message;
  final String? validationRowId;
  final InternalAdapterReadinessSummaryGroupId? sourceSummaryGroupId;
  final String? summaryRecordId;
  final String? adapterPacketId;
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
      if (sourceSummaryGroupId != null)
        'sourceSummaryGroupId': sourceSummaryGroupId!.wire,
      if (summaryRecordId != null) 'summaryRecordId': summaryRecordId,
      if (adapterPacketId != null) 'adapterPacketId': adapterPacketId,
      if (fieldId != null) 'fieldId': fieldId,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class InternalAdapterReadinessSummaryValidationResult {
  const InternalAdapterReadinessSummaryValidationResult({
    required this.validationStatus,
    required this.sourceSummaryStatus,
    required this.sourceReadinessGateStatus,
    required this.sourcePrototypeValidationStatus,
    required this.sourcePrototypeReviewStatus,
    required this.sourcePrototypeStatus,
    required this.checks,
    required this.groupRows,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalChecks,
    required this.passedCheckCount,
    required this.warningCheckCount,
    required this.blockerCount,
    required this.criticalCount,
    required this.totalGroupRows,
    required this.validAllowedCoreSummaryCount,
    required this.validConstrainedContextSummaryCount,
    required this.validInactiveBlockedSummaryCount,
    required this.validInactiveFutureOnlySummaryCount,
    required this.validActiveOutputFieldSummaryCount,
    required this.validBlockedOutputFieldSummaryCount,
    required this.validAndroidProofBoundarySummaryCount,
    required this.validOwnerProofStatusSummaryCount,
    required this.invalidSummaryCount,
    required this.unsafeSummaryCount,
    required this.ownerProofQueueCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.activeOutputFieldIds,
    required this.blockedOutputFieldIds,
    required this.safeForPhase32T,
    required this.phase32TRecommendation,
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

  final InternalAdapterReadinessSummaryValidationStatus validationStatus;
  final InternalAdapterReadinessSummaryStatus sourceSummaryStatus;
  final InternalEvidenceAdapterPrototypeReadinessGateStatus
  sourceReadinessGateStatus;
  final InternalEvidenceAdapterPrototypeValidationStatus
  sourcePrototypeValidationStatus;
  final InternalEvidenceAdapterPrototypeReviewStatus
  sourcePrototypeReviewStatus;
  final InternalEvidenceAdapterPrototypeStatus sourcePrototypeStatus;
  final List<InternalAdapterReadinessSummaryValidationCheck> checks;
  final List<InternalAdapterReadinessSummaryValidationRow> groupRows;
  final List<InternalAdapterReadinessSummaryValidationFinding>
  validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalChecks;
  final int passedCheckCount;
  final int warningCheckCount;
  final int blockerCount;
  final int criticalCount;
  final int totalGroupRows;
  final int validAllowedCoreSummaryCount;
  final int validConstrainedContextSummaryCount;
  final int validInactiveBlockedSummaryCount;
  final int validInactiveFutureOnlySummaryCount;
  final int validActiveOutputFieldSummaryCount;
  final int validBlockedOutputFieldSummaryCount;
  final int validAndroidProofBoundarySummaryCount;
  final int validOwnerProofStatusSummaryCount;
  final int invalidSummaryCount;
  final int unsafeSummaryCount;
  final int ownerProofQueueCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> activeOutputFieldIds;
  final List<String> blockedOutputFieldIds;
  final bool safeForPhase32T;
  final InternalAdapterReadinessSummaryValidationPhase32TRecommendation
  phase32TRecommendation;
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
          InternalAdapterReadinessSummaryValidationStatus
              .blockedByUnsafeSummary ||
      validationStatus ==
          InternalAdapterReadinessSummaryValidationStatus
              .blockedBySummaryMismatch ||
      validationStatus ==
          InternalAdapterReadinessSummaryValidationStatus
              .blockedByPolicyBoundary ||
      validationStatus ==
          InternalAdapterReadinessSummaryValidationStatus.invalid ||
      !safeForPhase32T ||
      unsafeSummaryCount > 0 ||
      criticalCount > 0 ||
      blockerCount > 0 ||
      invalidSummaryCount > 0 ||
      checks.any((check) => check.blocksStrict) ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeAdapterSummaryValidationPolicyViolation {
    return validationStatus ==
            InternalAdapterReadinessSummaryValidationStatus
                .blockedByUnsafeSummary ||
        validationStatus ==
            InternalAdapterReadinessSummaryValidationStatus
                .blockedByPolicyBoundary ||
        sourceSummaryStatus ==
            InternalAdapterReadinessSummaryStatus.blockedByUnsafeReadiness ||
        unsafeSummaryCount > 0 ||
        criticalCount > 0 ||
        groupRows.any(
          (row) => row.hasUnsafeOutput || row.validationStatus.isUnsafe,
        ) ||
        checks.any((check) => check.isCritical) ||
        validationFindings.any((finding) => finding.isCritical) ||
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

  InternalAdapterReadinessSummaryValidationCheck check(String checkId) {
    return checks.singleWhere((check) => check.checkId == checkId);
  }

  InternalAdapterReadinessSummaryValidationRow row(String validationRowId) {
    return groupRows.singleWhere(
      (row) => row.validationRowId == validationRowId,
    );
  }

  InternalAdapterReadinessSummaryValidationRow rowForGroup(
    InternalAdapterReadinessSummaryGroupId groupId,
  ) {
    return groupRows.singleWhere((row) => row.sourceSummaryGroupId == groupId);
  }

  List<InternalAdapterReadinessSummaryValidationRow>
  get allowedCoreSummaryRows => groupRows
      .where(
        (row) =>
            row.validationStatus ==
            InternalAdapterReadinessSummaryGroupValidationStatus
                .validAllowedCoreSummary,
      )
      .toList(growable: false);

  List<InternalAdapterReadinessSummaryValidationRow>
  get constrainedContextSummaryRows => groupRows
      .where(
        (row) =>
            row.validationStatus ==
            InternalAdapterReadinessSummaryGroupValidationStatus
                .validConstrainedContextSummary,
      )
      .toList(growable: false);

  List<InternalAdapterReadinessSummaryValidationRow>
  get inactiveBoundarySummaryRows => groupRows
      .where(
        (row) =>
            row.validationStatus ==
                InternalAdapterReadinessSummaryGroupValidationStatus
                    .validInactiveBlockedSummary ||
            row.validationStatus ==
                InternalAdapterReadinessSummaryGroupValidationStatus
                    .validInactiveFutureOnlySummary,
      )
      .toList(growable: false);

  InternalAdapterReadinessSummaryValidationResult copyWith({
    InternalAdapterReadinessSummaryValidationStatus? validationStatus,
    InternalAdapterReadinessSummaryStatus? sourceSummaryStatus,
    InternalEvidenceAdapterPrototypeReadinessGateStatus?
    sourceReadinessGateStatus,
    InternalEvidenceAdapterPrototypeValidationStatus?
    sourcePrototypeValidationStatus,
    InternalEvidenceAdapterPrototypeReviewStatus? sourcePrototypeReviewStatus,
    InternalEvidenceAdapterPrototypeStatus? sourcePrototypeStatus,
    List<InternalAdapterReadinessSummaryValidationCheck>? checks,
    List<InternalAdapterReadinessSummaryValidationRow>? groupRows,
    List<InternalAdapterReadinessSummaryValidationFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalChecks,
    int? passedCheckCount,
    int? warningCheckCount,
    int? blockerCount,
    int? criticalCount,
    int? totalGroupRows,
    int? validAllowedCoreSummaryCount,
    int? validConstrainedContextSummaryCount,
    int? validInactiveBlockedSummaryCount,
    int? validInactiveFutureOnlySummaryCount,
    int? validActiveOutputFieldSummaryCount,
    int? validBlockedOutputFieldSummaryCount,
    int? validAndroidProofBoundarySummaryCount,
    int? validOwnerProofStatusSummaryCount,
    int? invalidSummaryCount,
    int? unsafeSummaryCount,
    int? ownerProofQueueCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? activeOutputFieldIds,
    List<String>? blockedOutputFieldIds,
    bool? safeForPhase32T,
    InternalAdapterReadinessSummaryValidationPhase32TRecommendation?
    phase32TRecommendation,
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
    return InternalAdapterReadinessSummaryValidationResult(
      validationStatus: validationStatus ?? this.validationStatus,
      sourceSummaryStatus: sourceSummaryStatus ?? this.sourceSummaryStatus,
      sourceReadinessGateStatus:
          sourceReadinessGateStatus ?? this.sourceReadinessGateStatus,
      sourcePrototypeValidationStatus:
          sourcePrototypeValidationStatus ??
          this.sourcePrototypeValidationStatus,
      sourcePrototypeReviewStatus:
          sourcePrototypeReviewStatus ?? this.sourcePrototypeReviewStatus,
      sourcePrototypeStatus:
          sourcePrototypeStatus ?? this.sourcePrototypeStatus,
      checks: checks ?? this.checks,
      groupRows: groupRows ?? this.groupRows,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalChecks: totalChecks ?? this.totalChecks,
      passedCheckCount: passedCheckCount ?? this.passedCheckCount,
      warningCheckCount: warningCheckCount ?? this.warningCheckCount,
      blockerCount: blockerCount ?? this.blockerCount,
      criticalCount: criticalCount ?? this.criticalCount,
      totalGroupRows: totalGroupRows ?? this.totalGroupRows,
      validAllowedCoreSummaryCount:
          validAllowedCoreSummaryCount ?? this.validAllowedCoreSummaryCount,
      validConstrainedContextSummaryCount:
          validConstrainedContextSummaryCount ??
          this.validConstrainedContextSummaryCount,
      validInactiveBlockedSummaryCount:
          validInactiveBlockedSummaryCount ??
          this.validInactiveBlockedSummaryCount,
      validInactiveFutureOnlySummaryCount:
          validInactiveFutureOnlySummaryCount ??
          this.validInactiveFutureOnlySummaryCount,
      validActiveOutputFieldSummaryCount:
          validActiveOutputFieldSummaryCount ??
          this.validActiveOutputFieldSummaryCount,
      validBlockedOutputFieldSummaryCount:
          validBlockedOutputFieldSummaryCount ??
          this.validBlockedOutputFieldSummaryCount,
      validAndroidProofBoundarySummaryCount:
          validAndroidProofBoundarySummaryCount ??
          this.validAndroidProofBoundarySummaryCount,
      validOwnerProofStatusSummaryCount:
          validOwnerProofStatusSummaryCount ??
          this.validOwnerProofStatusSummaryCount,
      invalidSummaryCount: invalidSummaryCount ?? this.invalidSummaryCount,
      unsafeSummaryCount: unsafeSummaryCount ?? this.unsafeSummaryCount,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      activeOutputFieldIds: activeOutputFieldIds ?? this.activeOutputFieldIds,
      blockedOutputFieldIds:
          blockedOutputFieldIds ?? this.blockedOutputFieldIds,
      safeForPhase32T: safeForPhase32T ?? this.safeForPhase32T,
      phase32TRecommendation:
          phase32TRecommendation ?? this.phase32TRecommendation,
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
      ..writeln('# Internal Adapter Readiness Summary Validation')
      ..writeln()
      ..writeln(
        '- version: $internalAdapterReadinessSummaryValidationReportVersion',
      )
      ..writeln('- validation status: ${validationStatus.wire}')
      ..writeln('- source summary status: ${sourceSummaryStatus.wire}')
      ..writeln(
        '- source readiness gate status: ${sourceReadinessGateStatus.wire}',
      )
      ..writeln(
        '- source prototype validation status: ${sourcePrototypeValidationStatus.wire}',
      )
      ..writeln(
        '- source prototype review status: ${sourcePrototypeReviewStatus.wire}',
      )
      ..writeln('- source prototype status: ${sourcePrototypeStatus.wire}')
      ..writeln('- total checks: $totalChecks')
      ..writeln('- passed check count: $passedCheckCount')
      ..writeln('- warning check count: $warningCheckCount')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- total group rows: $totalGroupRows')
      ..writeln(
        '- valid allowed core summary count: $validAllowedCoreSummaryCount',
      )
      ..writeln(
        '- valid constrained context summary count: $validConstrainedContextSummaryCount',
      )
      ..writeln(
        '- valid inactive blocked summary count: $validInactiveBlockedSummaryCount',
      )
      ..writeln(
        '- valid inactive future-only summary count: $validInactiveFutureOnlySummaryCount',
      )
      ..writeln(
        '- valid active output field summary count: $validActiveOutputFieldSummaryCount',
      )
      ..writeln(
        '- valid blocked output field summary count: $validBlockedOutputFieldSummaryCount',
      )
      ..writeln(
        '- valid Android proof boundary summary count: $validAndroidProofBoundarySummaryCount',
      )
      ..writeln(
        '- valid owner proof status summary count: $validOwnerProofStatusSummaryCount',
      )
      ..writeln('- invalid summary count: $invalidSummaryCount')
      ..writeln('- unsafe summary count: $unsafeSummaryCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- safe for Phase 32T: $safeForPhase32T')
      ..writeln('- Phase 32T recommendation: ${phase32TRecommendation.wire}')
      ..writeln()
      ..writeln('## Validation Policy')
      ..writeln(
        '- this layer validates the Phase 32R readiness summary against the Phase 32Q readiness gate only',
      )
      ..writeln(
        '- allowed core, constrained context, inactive boundary, output field, Android proof, and owner-proof summaries remain developer-only',
      )
      ..writeln()
      ..writeln('## Validation Check Table')
      ..writeln(
        '| Check | Status | Severity | Groups | Records | Packets | Fields | Proof IDs | Warning | Failure | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final check in checks) {
      buffer.writeln(
        '| ${_cell(check.checkId)} | '
        '${check.checkStatus.wire} | '
        '${check.severity.wire} | '
        '${_ids(check.relatedGroupIds)} | '
        '${_ids(check.relatedRecordIds)} | '
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
      ..writeln('## Summary Group Validation Table')
      ..writeln(
        '| Validation Row | Source Group | Group Kind | Status | Records | Packets | Active Fields | Blocked Fields | Android Proof | Owner Queue | Safe | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in groupRows) {
      buffer.writeln(
        '| ${_cell(row.validationRowId)} | '
        '${row.sourceSummaryGroupId.wire} | '
        '${row.groupKind.wire} | '
        '${row.validationStatus.wire} | '
        '${_ids(row.groupRecordIds)} | '
        '${_ids(row.packetIds)} | '
        '${_ids(row.activeOutputFieldIds)} | '
        '${_ids(row.blockedOutputFieldIds)} | '
        '${_ids(row.androidProofCaseIds)} | '
        '${row.ownerProofQueueCount} | '
        '${row.safeForNextPhase} | '
        '${row.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Allowed Core Summary Validation')
      ..writeln('- ${_validationRowIds(allowedCoreSummaryRows)}')
      ..writeln()
      ..writeln('## Constrained Context Summary Validation')
      ..writeln('- ${_validationRowIds(constrainedContextSummaryRows)}')
      ..writeln()
      ..writeln('## Inactive Blocked/Future Summary Validation')
      ..writeln('- ${_validationRowIds(inactiveBoundarySummaryRows)}')
      ..writeln()
      ..writeln('## Active Output Field Validation')
      ..writeln('- ${_ids(activeOutputFieldIds)}')
      ..writeln()
      ..writeln('## Blocked Output Field Validation')
      ..writeln('- ${_ids(blockedOutputFieldIds)}')
      ..writeln()
      ..writeln('## Android Proof Boundary Validation')
      ..writeln('- ${_ids(androidProofCaseIds)}')
      ..writeln()
      ..writeln('## Owner Proof Status Validation')
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
      ..writeln('## Phase 32T Recommendation')
      ..writeln(phase32TRecommendation.wire)
      ..writeln()
      ..writeln(
        'This adapter readiness summary validation is internal-only. It does not emit active product labels, compute values, order moves, call the engine, run Android, target UI, integrate with backend or persistence, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': internalAdapterReadinessSummaryValidationReportVersion,
      'validationStatus': validationStatus.wire,
      'sourceSummaryStatus': sourceSummaryStatus.wire,
      'sourceReadinessGateStatus': sourceReadinessGateStatus.wire,
      'sourcePrototypeValidationStatus': sourcePrototypeValidationStatus.wire,
      'sourcePrototypeReviewStatus': sourcePrototypeReviewStatus.wire,
      'sourcePrototypeStatus': sourcePrototypeStatus.wire,
      'totalChecks': totalChecks,
      'passedCheckCount': passedCheckCount,
      'warningCheckCount': warningCheckCount,
      'blockerCount': blockerCount,
      'criticalCount': criticalCount,
      'totalGroupRows': totalGroupRows,
      'validAllowedCoreSummaryCount': validAllowedCoreSummaryCount,
      'validConstrainedContextSummaryCount':
          validConstrainedContextSummaryCount,
      'validInactiveBlockedSummaryCount': validInactiveBlockedSummaryCount,
      'validInactiveFutureOnlySummaryCount':
          validInactiveFutureOnlySummaryCount,
      'validActiveOutputFieldSummaryCount': validActiveOutputFieldSummaryCount,
      'validBlockedOutputFieldSummaryCount':
          validBlockedOutputFieldSummaryCount,
      'validAndroidProofBoundarySummaryCount':
          validAndroidProofBoundarySummaryCount,
      'validOwnerProofStatusSummaryCount': validOwnerProofStatusSummaryCount,
      'invalidSummaryCount': invalidSummaryCount,
      'unsafeSummaryCount': unsafeSummaryCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'activeOutputFieldIds': activeOutputFieldIds,
      'blockedOutputFieldIds': blockedOutputFieldIds,
      'safeForPhase32T': safeForPhase32T,
      'phase32TRecommendation': phase32TRecommendation.wire,
      'checks': checks.map((check) => check.toJson()).toList(),
      'groupRows': groupRows.map((row) => row.toJson()).toList(),
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

class InternalAdapterReadinessSummaryValidation {
  const InternalAdapterReadinessSummaryValidation({
    this.validator = const InternalAdapterReadinessSummaryValidationValidator(),
  });

  final InternalAdapterReadinessSummaryValidationValidator validator;

  InternalAdapterReadinessSummaryValidationResult evaluate([
    InternalAdapterReadinessSummaryValidationRequest request =
        const InternalAdapterReadinessSummaryValidationRequest(),
  ]) {
    final prototypeResult =
        request.prototypeResult ??
        request.adapterPrototype.evaluate(
          InternalEvidenceAdapterPrototypeRequest(
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
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final summaryResult =
        request.summaryResult ??
        request.summary.evaluate(
          InternalAdapterReadinessSummaryRequest(
            readinessGateResult: readinessGateResult,
            validationResult: validationResult,
            reviewResult: reviewResult,
            prototypeResult: prototypeResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final groupRows = _rowsFromSummary(summaryResult);
    final checks = _checksFor(
      summaryResult: summaryResult,
      readinessGateResult: readinessGateResult,
      groupRows: groupRows,
      androidProofEvidence: request.androidProofEvidence,
    );
    final base = _resultFromRowsAndChecks(
      summaryResult: summaryResult,
      readinessGateResult: readinessGateResult,
      validationResult: validationResult,
      reviewResult: reviewResult,
      prototypeResult: prototypeResult,
      groupRows: groupRows,
      checks: checks,
      validationFindings:
          const <InternalAdapterReadinessSummaryValidationFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromRowsAndChecks(
      summaryResult: summaryResult,
      readinessGateResult: readinessGateResult,
      validationResult: validationResult,
      reviewResult: reviewResult,
      prototypeResult: prototypeResult,
      groupRows: groupRows,
      checks: checks,
      validationFindings: findings,
    );
  }
}

class InternalAdapterReadinessSummaryValidationValidator {
  const InternalAdapterReadinessSummaryValidationValidator();

  List<InternalAdapterReadinessSummaryValidationFinding> validate(
    InternalAdapterReadinessSummaryValidationResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <InternalAdapterReadinessSummaryValidationFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required InternalAdapterReadinessSummaryValidationSeverity severity,
      required String message,
      String? validationRowId,
      InternalAdapterReadinessSummaryGroupId? sourceSummaryGroupId,
      String? summaryRecordId,
      String? adapterPacketId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        InternalAdapterReadinessSummaryValidationFinding(
          id: id,
          severity: severity,
          message: message,
          validationRowId: validationRowId,
          sourceSummaryGroupId: sourceSummaryGroupId,
          summaryRecordId: summaryRecordId,
          adapterPacketId: adapterPacketId,
          fieldId: fieldId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase32T &&
        (result.sourceSummaryStatus ==
                InternalAdapterReadinessSummaryStatus
                    .blockedByUnsafeReadiness ||
            result.unsafeSummaryCount > 0)) {
      add(
        id: 'unsafeSummaryMarkedValidated',
        severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
        message: 'unsafe readiness summary cannot be marked validated',
      );
    }

    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: InternalAdapterReadinessSummaryValidationSeverity.blocker,
        message: 'owner proof requires explicit PV/MultiPV reason',
      );
    }

    for (final fieldId in _blockedOutputFieldIds) {
      if (!result.blockedOutputFieldIds.contains(fieldId)) {
        add(
          id: 'blockedOutputFieldMissing',
          severity: InternalAdapterReadinessSummaryValidationSeverity.blocker,
          message: '$fieldId must remain a blocked output field',
          fieldId: fieldId,
        );
      }
    }

    for (final row in result.groupRows) {
      for (final fieldId in row.activeOutputFieldIds) {
        _checkActiveField(
          add,
          fieldId,
          validationRowId: row.validationRowId,
          sourceSummaryGroupId: row.sourceSummaryGroupId,
        );
      }
      if (row.groupKind ==
              InternalAdapterReadinessSummaryValidationGroupKind
                  .allowedCoreSummary &&
          !row.packetIds.every(_isCorePacketId)) {
        add(
          id: 'allowedCoreSummaryContainsNonCorePacket',
          severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
          message: 'allowed core summary contains non-core packet',
          validationRowId: row.validationRowId,
          sourceSummaryGroupId: row.sourceSummaryGroupId,
        );
      }
      if (row.sourceSummaryGroupId ==
              InternalAdapterReadinessSummaryGroupId
                  .constrainedContextPacketSummary &&
          row.groupKind ==
              InternalAdapterReadinessSummaryValidationGroupKind
                  .allowedCoreSummary) {
        add(
          id: 'contextOnlySummaryPromotedToAllowedCore',
          severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
          message: 'context-only summary cannot become allowed core',
          validationRowId: row.validationRowId,
          sourceSummaryGroupId: row.sourceSummaryGroupId,
        );
      }
      if ((row.sourceSummaryGroupId ==
                  InternalAdapterReadinessSummaryGroupId
                      .inactiveBlockedPacketSummary ||
              row.sourceSummaryGroupId ==
                  InternalAdapterReadinessSummaryGroupId
                      .inactiveFutureOnlyPacketSummary) &&
          !_rowIsInactiveSafe(row)) {
        add(
          id: 'blockedFutureSummaryMadeActive',
          severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
          message: 'blocked/future-only summary must remain inactive',
          validationRowId: row.validationRowId,
          sourceSummaryGroupId: row.sourceSummaryGroupId,
        );
      }
      if (row.isProductOutput) {
        add(
          id: 'productOutputActive',
          severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
          message: 'summary validation cannot be product output',
          validationRowId: row.validationRowId,
          sourceSummaryGroupId: row.sourceSummaryGroupId,
        );
      }
      if (row.isClassifierLabel) {
        add(
          id: 'classifierLabelOutputActive',
          severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
          message: 'summary validation cannot emit classifier labels',
          validationRowId: row.validationRowId,
          sourceSummaryGroupId: row.sourceSummaryGroupId,
        );
      }
      if (row.isOfficialMetric) {
        add(
          id: 'officialMetricOutputActive',
          severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
          message: 'summary validation cannot emit official metrics',
          validationRowId: row.validationRowId,
          sourceSummaryGroupId: row.sourceSummaryGroupId,
        );
      }
      if (row.hasNumericScore) {
        add(
          id: 'numericScoreOutputActive',
          severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
          message: 'summary validation cannot emit numeric move values',
          validationRowId: row.validationRowId,
          sourceSummaryGroupId: row.sourceSummaryGroupId,
        );
      }
      if (row.ranksMoves) {
        add(
          id: 'moveRankingOutputActive',
          severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
          message: 'summary validation cannot order moves',
          validationRowId: row.validationRowId,
          sourceSummaryGroupId: row.sourceSummaryGroupId,
        );
      }
      if (row.cpLossOutputActive || row.winProbabilityOutputActive) {
        add(
          id: 'futureMetricOutputActive',
          severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
          message:
              'summary validation cannot activate CP-loss or win probability',
          validationRowId: row.validationRowId,
          sourceSummaryGroupId: row.sourceSummaryGroupId,
        );
      }
      if (row.quietPreparatoryScopeActive) {
        add(
          id: 'quietPreparatoryScopeActivated',
          severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
          message: 'quiet/preparatory scope must remain excluded',
          validationRowId: row.validationRowId,
          sourceSummaryGroupId: row.sourceSummaryGroupId,
        );
      }
      if (row.callsEngine) {
        add(
          id: 'engineCallFlagActive',
          severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
          message: 'summary validation cannot call an engine',
          validationRowId: row.validationRowId,
          sourceSummaryGroupId: row.sourceSummaryGroupId,
        );
      }
      if (row.writesPersistence) {
        add(
          id: 'persistenceWriteFlagActive',
          severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
          message: 'summary validation cannot write persistence',
          validationRowId: row.validationRowId,
          sourceSummaryGroupId: row.sourceSummaryGroupId,
        );
      }
      if (row.targetsUi) {
        add(
          id: 'uiTargetFlagActive',
          severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
          message: 'summary validation cannot target UI',
          validationRowId: row.validationRowId,
          sourceSummaryGroupId: row.sourceSummaryGroupId,
        );
      }
      if (row.backendOutputActive) {
        add(
          id: 'backendOutputActive',
          severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
          message: 'summary validation cannot target backend output',
          validationRowId: row.validationRowId,
          sourceSummaryGroupId: row.sourceSummaryGroupId,
        );
      }
      for (final caseId in row.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          validationRowId: row.validationRowId,
          sourceSummaryGroupId: row.sourceSummaryGroupId,
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
        id: 'summaryValidationBoundaryPolicyViolation',
        severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
        message:
            'adapter readiness summary validation crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<InternalAdapterReadinessSummaryValidationFinding> validateReportText(
    String reportText,
  ) {
    final findings = <InternalAdapterReadinessSummaryValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        InternalAdapterReadinessSummaryValidationFinding(
          id: id,
          severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
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
    if (RegExp(r'\bpv\s+[a-h][1-8][a-h][1-8]').hasMatch(lower) ||
        lower.contains('pvmoves') ||
        lower.contains('e2e4 e7e5')) {
      reportError('pvDumpReportText', 'report contains PV dump text');
    }
    for (final fieldId in _blockedOutputFieldIds) {
      if (lower.contains('active fields: ${fieldId.toLowerCase()}')) {
        reportError(
          'activeBlockedFieldReportText',
          'report contains blocked active output text',
        );
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
        reportText.contains('moveRanking active')) {
      reportError(
        'moveOrderingReportText',
        'report contains active move ordering text',
      );
    }
    return findings..sort(_compareFindings);
  }
}

List<InternalAdapterReadinessSummaryValidationRow> _rowsFromSummary(
  InternalAdapterReadinessSummaryResult summaryResult,
) {
  return <InternalAdapterReadinessSummaryValidationRow>[
    _rowForSummaryGroup(
      summaryResult,
      InternalAdapterReadinessSummaryGroupId.allowedCorePacketSummary,
      InternalAdapterReadinessSummaryValidationGroupKind.allowedCoreSummary,
      InternalAdapterReadinessSummaryGroupValidationStatus
          .validAllowedCoreSummary,
      summaryResult.allowedCoreRecords,
      'allowed core summary matches readiness-allowed core packets',
      'allowed core summary remains internal-only',
      InternalAdapterReadinessSummaryValidationRecommendation
          .keepAllowedCoreSummary,
    ),
    _rowForSummaryGroup(
      summaryResult,
      InternalAdapterReadinessSummaryGroupId.constrainedContextPacketSummary,
      InternalAdapterReadinessSummaryValidationGroupKind
          .constrainedContextSummary,
      InternalAdapterReadinessSummaryGroupValidationStatus
          .validConstrainedContextSummary,
      summaryResult.constrainedContextRecords,
      'constrained context summary matches context-only readiness records',
      'context summary remains constrained outside allowed core output',
      InternalAdapterReadinessSummaryValidationRecommendation
          .keepContextSummaryConstrained,
    ),
    _rowForSummaryGroup(
      summaryResult,
      InternalAdapterReadinessSummaryGroupId.inactiveBlockedPacketSummary,
      InternalAdapterReadinessSummaryValidationGroupKind.inactiveBlockedSummary,
      InternalAdapterReadinessSummaryGroupValidationStatus
          .validInactiveBlockedSummary,
      summaryResult.records.where(
        (record) =>
            record.summaryStatus ==
            InternalAdapterReadinessSummaryItemStatus
                .inactiveBlockedPacketSummary,
      ),
      'blocked summary remains inactive',
      'blocked summary remains inactive',
      InternalAdapterReadinessSummaryValidationRecommendation
          .keepBlockedSummaryInactive,
    ),
    _rowForSummaryGroup(
      summaryResult,
      InternalAdapterReadinessSummaryGroupId.inactiveFutureOnlyPacketSummary,
      InternalAdapterReadinessSummaryValidationGroupKind
          .inactiveFutureOnlySummary,
      InternalAdapterReadinessSummaryGroupValidationStatus
          .validInactiveFutureOnlySummary,
      summaryResult.records.where(
        (record) =>
            record.summaryStatus ==
            InternalAdapterReadinessSummaryItemStatus
                .inactiveFutureOnlyPacketSummary,
      ),
      'future-only summary remains inactive',
      'future-only summary remains inactive',
      InternalAdapterReadinessSummaryValidationRecommendation
          .keepFutureOnlySummaryInactive,
    ),
    _rowForSummaryGroup(
      summaryResult,
      InternalAdapterReadinessSummaryGroupId.allowedActiveOutputFieldSummary,
      InternalAdapterReadinessSummaryValidationGroupKind
          .activeOutputFieldSummary,
      InternalAdapterReadinessSummaryGroupValidationStatus
          .validActiveOutputFieldSummary,
      const <InternalAdapterReadinessSummaryRecord>[],
      'active output field summary contains internal evidence-safe fields',
      'active output fields remain developer-only',
      InternalAdapterReadinessSummaryValidationRecommendation
          .keepActiveOutputFieldsInternal,
    ),
    _rowForSummaryGroup(
      summaryResult,
      InternalAdapterReadinessSummaryGroupId.blockedOutputFieldSummary,
      InternalAdapterReadinessSummaryValidationGroupKind
          .blockedOutputFieldSummary,
      InternalAdapterReadinessSummaryGroupValidationStatus
          .validBlockedOutputFieldSummary,
      const <InternalAdapterReadinessSummaryRecord>[],
      'blocked output field summary keeps explicit denials',
      'blocked output fields remain explicit denials',
      InternalAdapterReadinessSummaryValidationRecommendation
          .keepBlockedOutputFieldsDenied,
    ),
    _rowForSummaryGroup(
      summaryResult,
      InternalAdapterReadinessSummaryGroupId.androidProofBoundarySummary,
      InternalAdapterReadinessSummaryValidationGroupKind
          .androidProofBoundarySummary,
      InternalAdapterReadinessSummaryGroupValidationStatus
          .validAndroidProofBoundarySummary,
      const <InternalAdapterReadinessSummaryRecord>[],
      'Android proof boundary is limited to captured proof IDs',
      'Android proof remains captured-proof only',
      InternalAdapterReadinessSummaryValidationRecommendation
          .keepAndroidProofBoundaryCaptured,
    ),
    _rowForSummaryGroup(
      summaryResult,
      InternalAdapterReadinessSummaryGroupId.ownerProofStatusSummary,
      InternalAdapterReadinessSummaryValidationGroupKind
          .ownerProofStatusSummary,
      InternalAdapterReadinessSummaryGroupValidationStatus
          .validOwnerProofStatusSummary,
      const <InternalAdapterReadinessSummaryRecord>[],
      'owner proof queue is empty by default',
      'owner proof status remains empty',
      InternalAdapterReadinessSummaryValidationRecommendation
          .keepOwnerProofEmpty,
    ),
  ];
}

InternalAdapterReadinessSummaryValidationRow _rowForSummaryGroup(
  InternalAdapterReadinessSummaryResult summaryResult,
  InternalAdapterReadinessSummaryGroupId groupId,
  InternalAdapterReadinessSummaryValidationGroupKind groupKind,
  InternalAdapterReadinessSummaryGroupValidationStatus validStatus,
  Iterable<InternalAdapterReadinessSummaryRecord> sourceRecords,
  String validationReason,
  String warningReason,
  InternalAdapterReadinessSummaryValidationRecommendation recommendation,
) {
  final group = summaryResult.summaryGroup(groupId);
  final records = sourceRecords.toList(growable: false);
  final activeOutputFieldIds = _sortedStrings(<String>[
    ...group.activeOutputFieldIds,
    ...records.expand((record) => record.activeOutputFieldIds),
  ]);
  final blockedOutputFieldIds = _sortedStrings(<String>[
    ...group.blockedOutputFieldIds,
    ...records.expand((record) => record.blockedOutputFieldIds),
  ]);
  final violationReasons = _violationReasonsForGroup(group, records, groupKind);
  final hasUnsafe =
      activeOutputFieldIds.any(_isBlockedOutputFieldId) ||
      records.any((record) => record.hasUnsafeOutput);
  final status = hasUnsafe
      ? InternalAdapterReadinessSummaryGroupValidationStatus.unsafeSummary
      : violationReasons.isNotEmpty || !group.safeForNextInternalStep
      ? InternalAdapterReadinessSummaryGroupValidationStatus.invalidSummary
      : validStatus;
  return InternalAdapterReadinessSummaryValidationRow(
    validationRowId: 'summary-validation-${groupId.wire}',
    sourceSummaryGroupId: groupId,
    validationStatus: status,
    groupKind: groupKind,
    groupRecordIds: _sortedStrings(
      records.map((record) => record.summaryRecordId),
    ),
    packetIds: _sortedStrings(<String>[
      ...group.packetIds,
      ...records.map((record) => record.adapterPacketId),
    ]),
    activeOutputFieldIds: activeOutputFieldIds,
    blockedOutputFieldIds: blockedOutputFieldIds,
    supportCaseIds: _sortedStrings(<String>[
      ...group.supportCaseIds,
      ...records.expand((record) => record.supportCaseIds),
    ]),
    newlyAddedSupportCaseIds: _sortedStrings(<String>[
      ...group.newlyAddedSupportCaseIds,
      ...records.expand((record) => record.newlyAddedSupportCaseIds),
    ]),
    androidProofCaseIds: _sortedStrings(<String>[
      ...group.androidProofCaseIds,
      ...records.expand((record) => record.androidProofCaseIds),
    ]),
    ownerProofQueueCount:
        groupId ==
            InternalAdapterReadinessSummaryGroupId.ownerProofStatusSummary
        ? summaryResult.ownerProofQueueCount
        : 0,
    validationReason: validationReason,
    warningReason: warningReason,
    violationReasons: violationReasons,
    safeForNextPhase:
        group.safeForNextInternalStep && violationReasons.isEmpty && !hasUnsafe,
    recommendation: hasUnsafe
        ? InternalAdapterReadinessSummaryValidationRecommendation
              .blockUnsafeSummaryValidation
        : violationReasons.isNotEmpty || !group.safeForNextInternalStep
        ? InternalAdapterReadinessSummaryValidationRecommendation
              .investigateSummaryValidationFailure
        : recommendation,
  );
}

List<String> _violationReasonsForGroup(
  InternalAdapterReadinessSummaryGroup group,
  List<InternalAdapterReadinessSummaryRecord> records,
  InternalAdapterReadinessSummaryValidationGroupKind groupKind,
) {
  final reasons = <String>[];
  if (!group.safeForNextInternalStep) {
    reasons.add('summary group is not safe for the next internal step');
  }
  switch (groupKind) {
    case InternalAdapterReadinessSummaryValidationGroupKind.allowedCoreSummary:
      if (!group.packetIds.every(_isCorePacketId) ||
          !records.every((record) => record.allowedForNextInternalStep)) {
        reasons.add('allowed core summary includes non-core readiness output');
      }
      break;
    case InternalAdapterReadinessSummaryValidationGroupKind
        .constrainedContextSummary:
      if (!records.every((record) => record.constrainedForContextOnly) ||
          records.any((record) => record.allowedForNextInternalStep)) {
        reasons.add('constrained context summary was promoted');
      }
      break;
    case InternalAdapterReadinessSummaryValidationGroupKind
        .inactiveBlockedSummary:
    case InternalAdapterReadinessSummaryValidationGroupKind
        .inactiveFutureOnlySummary:
      if (group.activeOutputFieldIds.isNotEmpty ||
          !records.every((record) => record.inactiveBoundary)) {
        reasons.add('blocked/future-only summary became active');
      }
      break;
    case InternalAdapterReadinessSummaryValidationGroupKind
        .activeOutputFieldSummary:
      if (group.activeOutputFieldIds.any(_isBlockedOutputFieldId)) {
        reasons.add('active output field summary includes blocked field');
      }
      break;
    case InternalAdapterReadinessSummaryValidationGroupKind
        .blockedOutputFieldSummary:
      if (!_blockedOutputFieldIds.every(group.blockedOutputFieldIds.contains)) {
        reasons.add('blocked output field summary is incomplete');
      }
      break;
    case InternalAdapterReadinessSummaryValidationGroupKind
        .androidProofBoundarySummary:
      if (!_setEquals(group.androidProofCaseIds, _capturedAndroidProofIds) ||
          group.androidProofCaseIds.any(_phase32ECaseIds.contains)) {
        reasons.add('Android proof boundary is not captured-proof only');
      }
      break;
    case InternalAdapterReadinessSummaryValidationGroupKind
        .ownerProofStatusSummary:
      break;
  }
  return _sortedStrings(reasons);
}

List<InternalAdapterReadinessSummaryValidationCheck> _checksFor({
  required InternalAdapterReadinessSummaryResult summaryResult,
  required InternalEvidenceAdapterPrototypeReadinessGateResult
  readinessGateResult,
  required List<InternalAdapterReadinessSummaryValidationRow> groupRows,
  required GoldenAndroidProofEvidence? androidProofEvidence,
}) {
  final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
  final activeBlockedFields = _sortedStrings(
    summaryResult.activeOutputFieldIds.where(_isBlockedOutputFieldId),
  );
  final missingBlockedFields = _sortedStrings(
    _blockedOutputFieldIds.where(
      (fieldId) => !summaryResult.blockedOutputFieldIds.contains(fieldId),
    ),
  );
  final allProofIds = _sortedStrings(<String>[
    ...summaryResult.androidProofCaseIds,
    ...groupRows.expand((row) => row.androidProofCaseIds),
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
  final policyFieldIds = _sortedStrings(<String>[
    ...activeBlockedFields,
    if (summaryResult.productOutputActive) 'productLabel',
    if (summaryResult.classifierOutputActive) 'classifierLabelOutput',
    if (summaryResult.finalMoveLabelOutputActive) 'finalMoveLabel',
    if (summaryResult.numericOutputActive) 'numericMoveScore',
    if (summaryResult.moveRankingOutputActive) 'moveRanking',
    if (summaryResult.officialMetricOutputActive) 'officialMetric',
    if (summaryResult.cpLossOutputActive) 'cpLoss',
    if (summaryResult.winProbabilityOutputActive) 'winProbability',
  ]);
  final integrationFieldIds = _sortedStrings(<String>[
    if (summaryResult.engineCallsActive) 'directEngineCallFields',
    if (summaryResult.persistenceWritesActive) 'backendPersistenceFields',
    if (summaryResult.uiTargetsActive) 'uiOutputFields',
    if (summaryResult.backendOutputActive) 'backendPersistenceFields',
  ]);

  final allowedCorePackets = summaryResult
      .summaryGroup(
        InternalAdapterReadinessSummaryGroupId.allowedCorePacketSummary,
      )
      .packetIds;
  final constrainedPackets = summaryResult
      .summaryGroup(
        InternalAdapterReadinessSummaryGroupId.constrainedContextPacketSummary,
      )
      .packetIds;
  final blockedPackets = summaryResult
      .summaryGroup(
        InternalAdapterReadinessSummaryGroupId.inactiveBlockedPacketSummary,
      )
      .packetIds;
  final futurePackets = summaryResult
      .summaryGroup(
        InternalAdapterReadinessSummaryGroupId.inactiveFutureOnlyPacketSummary,
      )
      .packetIds;

  return <InternalAdapterReadinessSummaryValidationCheck>[
    _check(
      checkId: 'summaryConsumesReadinessGate',
      ok: summaryResult.safeForPhase32S && readinessGateResult.safeForPhase32R,
      failedStatus:
          InternalAdapterReadinessSummaryValidationCheckStatus.blocked,
      failedSeverity: InternalAdapterReadinessSummaryValidationSeverity.blocker,
      relatedGroupIds: summaryResult.groups.map((group) => group.groupId.wire),
      failureReason: 'Phase 32R summary or Phase 32Q readiness gate is unsafe',
      recommendation: 'repair readiness summary before validating it',
    ),
    _check(
      checkId: 'allowedCoreSummaryMatchesReadinessGate',
      ok: _setEquals(
        allowedCorePackets,
        readinessGateResult.allowedCoreRecords.map(
          (record) => record.adapterPacketId,
        ),
      ),
      relatedGroupIds: const <String>['allowedCorePacketSummary'],
      relatedPacketIds: allowedCorePackets,
      failureReason: 'allowed core summary does not match readiness gate',
      recommendation: 'align allowed core summary to readiness gate',
    ),
    _check(
      checkId: 'constrainedContextSummaryMatchesReadinessGate',
      ok: _setEquals(
        constrainedPackets,
        readinessGateResult.constrainedContextRecords.map(
          (record) => record.adapterPacketId,
        ),
      ),
      warning: constrainedPackets.isNotEmpty,
      relatedGroupIds: const <String>['constrainedContextPacketSummary'],
      relatedPacketIds: constrainedPackets,
      warningReason:
          'constrained context summary remains outside allowed core output',
      failureReason: 'constrained summary does not match readiness gate',
      recommendation: 'keep context-only summary constrained',
    ),
    _check(
      checkId: 'inactiveBlockedSummaryMatchesReadinessGate',
      ok: _setEquals(
        blockedPackets,
        readinessGateResult.records
            .where(
              (record) => record.sourceSummaryGroupIds.contains(
                InternalEvidenceSummaryGroupId.blockedBoundarySummary,
              ),
            )
            .map((record) => record.adapterPacketId),
      ),
      warning: blockedPackets.isNotEmpty,
      relatedGroupIds: const <String>['inactiveBlockedPacketSummary'],
      relatedPacketIds: blockedPackets,
      warningReason: 'blocked summary remains inactive',
      failureReason: 'blocked summary does not match readiness gate',
      recommendation: 'keep blocked summary inactive',
    ),
    _check(
      checkId: 'inactiveFutureOnlySummaryMatchesReadinessGate',
      ok: _setEquals(
        futurePackets,
        readinessGateResult.records
            .where(
              (record) => record.sourceSummaryGroupIds.contains(
                InternalEvidenceSummaryGroupId.futureOnlySummary,
              ),
            )
            .map((record) => record.adapterPacketId),
      ),
      warning: futurePackets.isNotEmpty,
      relatedGroupIds: const <String>['inactiveFutureOnlyPacketSummary'],
      relatedPacketIds: futurePackets,
      warningReason: 'future-only summary remains inactive',
      failureReason: 'future-only summary does not match readiness gate',
      recommendation: 'keep future-only summary inactive',
    ),
    _check(
      checkId: 'activeOutputFieldsRemainInternalOnly',
      ok:
          activeBlockedFields.isEmpty &&
          !groupRows.any((row) => row.hasUnsafeOutput),
      relatedGroupIds: groupRows
          .where((row) => row.hasUnsafeOutput)
          .map((row) => row.sourceSummaryGroupId.wire),
      relatedFieldIds: activeBlockedFields,
      failureReason: 'active output field crossed a blocked boundary',
      recommendation: 'remove blocked fields from active summary validation',
    ),
    _check(
      checkId: 'blockedOutputFieldsRemainDenied',
      ok: missingBlockedFields.isEmpty && activeBlockedFields.isEmpty,
      failedSeverity: InternalAdapterReadinessSummaryValidationSeverity.blocker,
      relatedGroupIds: const <String>['blockedOutputFieldSummary'],
      relatedFieldIds: <String>[
        ...missingBlockedFields,
        ...activeBlockedFields,
      ],
      failureReason: 'blocked output field missing or active',
      recommendation: 'restore blocked output field denials',
    ),
    _check(
      checkId: 'androidProofBoundaryIsCapturedOnly',
      ok:
          unprovenProofIds.isEmpty &&
          _setEquals(
            summaryResult.androidProofCaseIds,
            _capturedAndroidProofIds,
          ),
      failedSeverity:
          InternalAdapterReadinessSummaryValidationSeverity.critical,
      relatedGroupIds: const <String>['androidProofBoundarySummary'],
      relatedProofIds: unprovenProofIds.isEmpty
          ? allProofIds
          : unprovenProofIds,
      failureReason: 'Android proof IDs are not limited to captured proof',
      recommendation: 'remove unproven Android proof IDs from summary',
    ),
    _check(
      checkId: 'phase32ECasesAreNotCapturedProof',
      ok: phase32EProofIds.isEmpty,
      failedSeverity:
          InternalAdapterReadinessSummaryValidationSeverity.critical,
      relatedGroupIds: const <String>['androidProofBoundarySummary'],
      relatedProofIds: phase32EProofIds,
      failureReason: 'Phase 32E case was treated as captured Android proof',
      recommendation: 'keep Phase 32E cases as support only',
    ),
    _check(
      checkId: 'ownerProofQueueRemainsEmpty',
      ok: summaryResult.ownerProofQueueCount == 0,
      failedSeverity: InternalAdapterReadinessSummaryValidationSeverity.blocker,
      relatedGroupIds: const <String>['ownerProofStatusSummary'],
      failureReason: 'owner proof queue is not empty by default',
      recommendation: 'require explicit PV/MultiPV owner proof reason',
    ),
    _check(
      checkId: 'noLabelsScoresRankingsMetrics',
      ok:
          policyFieldIds.isEmpty &&
          !summaryResult.productOutputActive &&
          !summaryResult.classifierOutputActive &&
          !summaryResult.finalMoveLabelOutputActive &&
          !summaryResult.officialMetricOutputActive &&
          !summaryResult.numericOutputActive &&
          !summaryResult.moveRankingOutputActive &&
          !summaryResult.cpLossOutputActive &&
          !summaryResult.winProbabilityOutputActive,
      failedSeverity:
          InternalAdapterReadinessSummaryValidationSeverity.critical,
      relatedFieldIds: policyFieldIds,
      failureReason: 'labels, scores, rankings, or metrics became active',
      recommendation: 'keep product and scoring families blocked',
    ),
    _check(
      checkId: 'noUiBackendPersistenceEngineFields',
      ok:
          integrationFieldIds.isEmpty &&
          !summaryResult.engineCallsActive &&
          !summaryResult.persistenceWritesActive &&
          !summaryResult.uiTargetsActive &&
          !summaryResult.backendOutputActive,
      failedSeverity:
          InternalAdapterReadinessSummaryValidationSeverity.critical,
      relatedFieldIds: integrationFieldIds,
      failureReason: 'UI, backend, persistence, or engine flag became active',
      recommendation: 'remove integration fields from summary validation',
    ),
    _check(
      checkId: 'quietScopeRemainsExcluded',
      ok:
          !summaryResult.quietPreparatoryScopeActivated &&
          !groupRows.any((row) => row.quietPreparatoryScopeActive),
      failedSeverity:
          InternalAdapterReadinessSummaryValidationSeverity.critical,
      relatedGroupIds: groupRows
          .where((row) => row.quietPreparatoryScopeActive)
          .map((row) => row.sourceSummaryGroupId.wire),
      failureReason: 'quiet/preparatory scope became active',
      recommendation: 'keep quiet/preparatory scope excluded',
    ),
    _check(
      checkId: 'productBoundariesRemainBlocked',
      ok:
          missingBlockedFields.isEmpty &&
          activeBlockedFields.isEmpty &&
          !summaryResult.productOutputActive &&
          !summaryResult.classifierOutputActive &&
          !summaryResult.backendOutputActive,
      failedSeverity:
          InternalAdapterReadinessSummaryValidationSeverity.critical,
      relatedFieldIds: <String>[
        ...missingBlockedFields,
        ...activeBlockedFields,
      ],
      failureReason: 'product or integration boundary became available',
      recommendation: 'keep summary validation developer-only',
    ),
  ]..sort((a, b) => a.checkId.compareTo(b.checkId));
}

InternalAdapterReadinessSummaryValidationCheck _check({
  required String checkId,
  required bool ok,
  bool warning = false,
  Iterable<String> relatedGroupIds = const <String>[],
  Iterable<String> relatedRecordIds = const <String>[],
  Iterable<String> relatedPacketIds = const <String>[],
  Iterable<String> relatedFieldIds = const <String>[],
  Iterable<String> relatedProofIds = const <String>[],
  InternalAdapterReadinessSummaryValidationCheckStatus failedStatus =
      InternalAdapterReadinessSummaryValidationCheckStatus.failed,
  InternalAdapterReadinessSummaryValidationSeverity failedSeverity =
      InternalAdapterReadinessSummaryValidationSeverity.critical,
  String warningReason = '',
  String failureReason = '',
  required String recommendation,
}) {
  if (!ok) {
    return InternalAdapterReadinessSummaryValidationCheck(
      checkId: checkId,
      checkStatus: failedStatus,
      severity: failedSeverity,
      relatedGroupIds: _sortedStrings(relatedGroupIds),
      relatedRecordIds: _sortedStrings(relatedRecordIds),
      relatedPacketIds: _sortedStrings(relatedPacketIds),
      relatedFieldIds: _sortedStrings(relatedFieldIds),
      relatedProofIds: _sortedStrings(relatedProofIds),
      warningReason: '',
      failureReason: failureReason,
      recommendation: recommendation,
    );
  }
  if (warning) {
    return InternalAdapterReadinessSummaryValidationCheck(
      checkId: checkId,
      checkStatus: InternalAdapterReadinessSummaryValidationCheckStatus
          .passedWithWarnings,
      severity: InternalAdapterReadinessSummaryValidationSeverity.warning,
      relatedGroupIds: _sortedStrings(relatedGroupIds),
      relatedRecordIds: _sortedStrings(relatedRecordIds),
      relatedPacketIds: _sortedStrings(relatedPacketIds),
      relatedFieldIds: _sortedStrings(relatedFieldIds),
      relatedProofIds: _sortedStrings(relatedProofIds),
      warningReason: warningReason,
      failureReason: '',
      recommendation: recommendation,
    );
  }
  return InternalAdapterReadinessSummaryValidationCheck(
    checkId: checkId,
    checkStatus: InternalAdapterReadinessSummaryValidationCheckStatus.passed,
    severity: InternalAdapterReadinessSummaryValidationSeverity.none,
    relatedGroupIds: _sortedStrings(relatedGroupIds),
    relatedRecordIds: _sortedStrings(relatedRecordIds),
    relatedPacketIds: _sortedStrings(relatedPacketIds),
    relatedFieldIds: _sortedStrings(relatedFieldIds),
    relatedProofIds: _sortedStrings(relatedProofIds),
    warningReason: '',
    failureReason: '',
    recommendation: recommendation,
  );
}

InternalAdapterReadinessSummaryValidationResult _resultFromRowsAndChecks({
  required InternalAdapterReadinessSummaryResult summaryResult,
  required InternalEvidenceAdapterPrototypeReadinessGateResult
  readinessGateResult,
  required InternalEvidenceAdapterPrototypeValidationResult validationResult,
  required InternalEvidenceAdapterPrototypeReviewResult reviewResult,
  required InternalEvidenceAdapterPrototypeResult prototypeResult,
  required List<InternalAdapterReadinessSummaryValidationRow> groupRows,
  required List<InternalAdapterReadinessSummaryValidationCheck> checks,
  required List<InternalAdapterReadinessSummaryValidationFinding>
  validationFindings,
}) {
  final unsafeSummaryCount = groupRows
      .where(
        (row) =>
            row.hasUnsafeOutput ||
            row.validationStatus ==
                InternalAdapterReadinessSummaryGroupValidationStatus
                    .unsafeSummary,
      )
      .length;
  final invalidSummaryCount = groupRows
      .where(
        (row) =>
            row.validationStatus ==
            InternalAdapterReadinessSummaryGroupValidationStatus.invalidSummary,
      )
      .length;
  final blockerCount =
      checks
          .where(
            (check) =>
                check.severity ==
                    InternalAdapterReadinessSummaryValidationSeverity.blocker ||
                check.checkStatus ==
                    InternalAdapterReadinessSummaryValidationCheckStatus
                        .blocked,
          )
          .length +
      validationFindings
          .where(
            (finding) =>
                finding.severity ==
                InternalAdapterReadinessSummaryValidationSeverity.blocker,
          )
          .length;
  final criticalCount =
      checks.where((check) => check.isCritical).length +
      validationFindings.where((finding) => finding.isCritical).length;
  final base = InternalAdapterReadinessSummaryValidationResult(
    validationStatus: InternalAdapterReadinessSummaryValidationStatus.invalid,
    sourceSummaryStatus: summaryResult.summaryStatus,
    sourceReadinessGateStatus: readinessGateResult.readinessStatus,
    sourcePrototypeValidationStatus: validationResult.validationStatus,
    sourcePrototypeReviewStatus: reviewResult.reviewStatus,
    sourcePrototypeStatus: prototypeResult.prototypeStatus,
    checks: checks,
    groupRows: groupRows,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...summaryResult.warnings,
      ...checks
          .where(
            (check) =>
                check.checkStatus ==
                    InternalAdapterReadinessSummaryValidationCheckStatus
                        .passedWithWarnings &&
                check.warningReason.isNotEmpty,
          )
          .map((check) => check.warningReason),
    ]),
    failures: _sortedStrings(<String>[
      ...summaryResult.failures,
      ...groupRows.expand((row) => row.violationReasons),
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
              InternalAdapterReadinessSummaryValidationCheckStatus.passed,
        )
        .length,
    warningCheckCount: checks
        .where(
          (check) =>
              check.checkStatus ==
              InternalAdapterReadinessSummaryValidationCheckStatus
                  .passedWithWarnings,
        )
        .length,
    blockerCount: blockerCount,
    criticalCount: criticalCount,
    totalGroupRows: groupRows.length,
    validAllowedCoreSummaryCount: _countRows(
      groupRows,
      InternalAdapterReadinessSummaryGroupValidationStatus
          .validAllowedCoreSummary,
    ),
    validConstrainedContextSummaryCount: _countRows(
      groupRows,
      InternalAdapterReadinessSummaryGroupValidationStatus
          .validConstrainedContextSummary,
    ),
    validInactiveBlockedSummaryCount: _countRows(
      groupRows,
      InternalAdapterReadinessSummaryGroupValidationStatus
          .validInactiveBlockedSummary,
    ),
    validInactiveFutureOnlySummaryCount: _countRows(
      groupRows,
      InternalAdapterReadinessSummaryGroupValidationStatus
          .validInactiveFutureOnlySummary,
    ),
    validActiveOutputFieldSummaryCount: _countRows(
      groupRows,
      InternalAdapterReadinessSummaryGroupValidationStatus
          .validActiveOutputFieldSummary,
    ),
    validBlockedOutputFieldSummaryCount: _countRows(
      groupRows,
      InternalAdapterReadinessSummaryGroupValidationStatus
          .validBlockedOutputFieldSummary,
    ),
    validAndroidProofBoundarySummaryCount: _countRows(
      groupRows,
      InternalAdapterReadinessSummaryGroupValidationStatus
          .validAndroidProofBoundarySummary,
    ),
    validOwnerProofStatusSummaryCount: _countRows(
      groupRows,
      InternalAdapterReadinessSummaryGroupValidationStatus
          .validOwnerProofStatusSummary,
    ),
    invalidSummaryCount: invalidSummaryCount,
    unsafeSummaryCount: unsafeSummaryCount,
    ownerProofQueueCount: summaryResult.ownerProofQueueCount,
    supportCaseIds: _sortedStrings(summaryResult.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(
      summaryResult.newlyAddedSupportCaseIds,
    ),
    androidProofCaseIds: _sortedStrings(summaryResult.androidProofCaseIds),
    activeOutputFieldIds: _sortedStrings(summaryResult.activeOutputFieldIds),
    blockedOutputFieldIds: _sortedStrings(summaryResult.blockedOutputFieldIds),
    safeForPhase32T: false,
    phase32TRecommendation:
        InternalAdapterReadinessSummaryValidationPhase32TRecommendation
            .addMoreGoldenCoverageFirst,
    developerOnly: summaryResult.developerOnly,
    productOutputActive:
        summaryResult.productOutputActive ||
        groupRows.any((row) => row.isProductOutput),
    classifierOutputActive:
        summaryResult.classifierOutputActive ||
        groupRows.any((row) => row.isClassifierLabel),
    finalMoveLabelOutputActive: summaryResult.finalMoveLabelOutputActive,
    officialMetricOutputActive:
        summaryResult.officialMetricOutputActive ||
        groupRows.any((row) => row.isOfficialMetric),
    cpLossOutputActive:
        summaryResult.cpLossOutputActive ||
        groupRows.any((row) => row.cpLossOutputActive),
    winProbabilityOutputActive:
        summaryResult.winProbabilityOutputActive ||
        groupRows.any((row) => row.winProbabilityOutputActive),
    numericOutputActive:
        summaryResult.numericOutputActive ||
        groupRows.any((row) => row.hasNumericScore),
    moveRankingOutputActive:
        summaryResult.moveRankingOutputActive ||
        groupRows.any((row) => row.ranksMoves),
    quietPreparatoryScopeActivated:
        summaryResult.quietPreparatoryScopeActivated ||
        groupRows.any((row) => row.quietPreparatoryScopeActive),
    engineCallsActive:
        summaryResult.engineCallsActive ||
        groupRows.any((row) => row.callsEngine),
    persistenceWritesActive:
        summaryResult.persistenceWritesActive ||
        groupRows.any((row) => row.writesPersistence),
    uiTargetsActive:
        summaryResult.uiTargetsActive || groupRows.any((row) => row.targetsUi),
    backendOutputActive:
        summaryResult.backendOutputActive ||
        groupRows.any((row) => row.backendOutputActive),
  );
  final status = _validationStatusFor(
    base,
    summaryResult: summaryResult,
    readinessGateResult: readinessGateResult,
    invalidSummaryCount: invalidSummaryCount,
  );
  final safeForPhase32T =
      (status ==
              InternalAdapterReadinessSummaryValidationStatus
                  .validatedWithWarnings ||
          status ==
              InternalAdapterReadinessSummaryValidationStatus.validatedClean) &&
      summaryResult.safeForPhase32S &&
      !summaryResult.isStrictlyBlocked &&
      !summaryResult.hasUnsafeAdapterSummaryPolicyViolation &&
      readinessGateResult.safeForPhase32R &&
      !readinessGateResult.isStrictlyBlocked &&
      !readinessGateResult.hasUnsafeAdapterReadinessPolicyViolation &&
      unsafeSummaryCount == 0 &&
      invalidSummaryCount == 0 &&
      blockerCount == 0 &&
      criticalCount == 0 &&
      !checks.any((check) => check.blocksStrict) &&
      !validationFindings.any((finding) => finding.blocksStrict) &&
      groupRows.every((row) => row.safeForNextPhase);
  return base.copyWith(
    validationStatus: status,
    safeForPhase32T: safeForPhase32T,
    phase32TRecommendation: _phase32TRecommendationFor(
      status: status,
      safeForPhase32T: safeForPhase32T,
      ownerProofQueueCount: summaryResult.ownerProofQueueCount,
    ),
  );
}

InternalAdapterReadinessSummaryValidationStatus _validationStatusFor(
  InternalAdapterReadinessSummaryValidationResult result, {
  required InternalAdapterReadinessSummaryResult summaryResult,
  required InternalEvidenceAdapterPrototypeReadinessGateResult
  readinessGateResult,
  required int invalidSummaryCount,
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
    return InternalAdapterReadinessSummaryValidationStatus
        .blockedByPolicyBoundary;
  }
  if (summaryResult.summaryStatus ==
          InternalAdapterReadinessSummaryStatus.blockedByUnsafeReadiness ||
      summaryResult.unsafeCount > 0 ||
      result.unsafeSummaryCount > 0 ||
      result.criticalCount > 0) {
    return InternalAdapterReadinessSummaryValidationStatus
        .blockedByUnsafeSummary;
  }
  if (!summaryResult.safeForPhase32S ||
      summaryResult.isStrictlyBlocked ||
      !readinessGateResult.safeForPhase32R ||
      readinessGateResult.isStrictlyBlocked ||
      invalidSummaryCount > 0 ||
      result.checks.any((check) => check.checkStatus.isBlocked) ||
      _hasSummaryMismatchFinding(result.validationFindings)) {
    return InternalAdapterReadinessSummaryValidationStatus
        .blockedBySummaryMismatch;
  }
  if (result.blockerCount > 0 ||
      result.validationFindings.any((finding) => finding.blocksStrict)) {
    return InternalAdapterReadinessSummaryValidationStatus.invalid;
  }
  if (result.groupRows.isEmpty || result.checks.isEmpty) {
    return InternalAdapterReadinessSummaryValidationStatus.invalid;
  }
  if (result.warningCheckCount > 0 || result.warnings.isNotEmpty) {
    return InternalAdapterReadinessSummaryValidationStatus
        .validatedWithWarnings;
  }
  return InternalAdapterReadinessSummaryValidationStatus.validatedClean;
}

InternalAdapterReadinessSummaryValidationPhase32TRecommendation
_phase32TRecommendationFor({
  required InternalAdapterReadinessSummaryValidationStatus status,
  required bool safeForPhase32T,
  required int ownerProofQueueCount,
}) {
  if (status ==
          InternalAdapterReadinessSummaryValidationStatus
              .blockedByUnsafeSummary ||
      status ==
          InternalAdapterReadinessSummaryValidationStatus
              .blockedByPolicyBoundary) {
    return InternalAdapterReadinessSummaryValidationPhase32TRecommendation
        .blockedByUnsafeSummaryValidation;
  }
  if (ownerProofQueueCount > 0) {
    return InternalAdapterReadinessSummaryValidationPhase32TRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase32T) {
    return InternalAdapterReadinessSummaryValidationPhase32TRecommendation
        .addMoreGoldenCoverageFirst;
  }
  return InternalAdapterReadinessSummaryValidationPhase32TRecommendation
      .proceedToDebugOnlyAdapterBridgeDesign;
}

bool _hasSummaryMismatchFinding(
  List<InternalAdapterReadinessSummaryValidationFinding> findings,
) {
  return findings.any(
    (finding) =>
        finding.id.contains('Mismatch') ||
        finding.id.contains('NonCore') ||
        finding.id.contains('Promoted') ||
        finding.id.contains('MadeActive'),
  );
}

bool _hasExplicitPvProofReason(
  InternalAdapterReadinessSummaryValidationResult result,
) {
  final reasons = <String>[
    ...result.warnings,
    ...result.failures,
    ...result.groupRows.map((row) => row.warningReason),
    ...result.groupRows.map((row) => row.validationReason),
  ].join(' ').toLowerCase();
  return reasons.contains('pv') || reasons.contains('multipv');
}

bool _rowIsInactiveSafe(InternalAdapterReadinessSummaryValidationRow row) {
  return row.packetIds.isNotEmpty &&
      row.activeOutputFieldIds.isEmpty &&
      !row.hasUnsafeOutput &&
      (row.groupKind ==
              InternalAdapterReadinessSummaryValidationGroupKind
                  .inactiveBlockedSummary ||
          row.groupKind ==
              InternalAdapterReadinessSummaryValidationGroupKind
                  .inactiveFutureOnlySummary);
}

int _countRows(
  List<InternalAdapterReadinessSummaryValidationRow> rows,
  InternalAdapterReadinessSummaryGroupValidationStatus status,
) {
  return rows.where((row) => row.validationStatus == status).length;
}

bool _isCorePacketId(String packetId) {
  return packetId == 'packet-allowedEvidenceSummary' ||
      packetId == 'packet-improvedSupportSummary';
}

void _checkActiveField(
  void Function({
    required String id,
    required InternalAdapterReadinessSummaryValidationSeverity severity,
    required String message,
    String? validationRowId,
    InternalAdapterReadinessSummaryGroupId? sourceSummaryGroupId,
    String? summaryRecordId,
    String? adapterPacketId,
    String? fieldId,
    String? caseId,
  })
  add,
  String fieldId, {
  String? validationRowId,
  InternalAdapterReadinessSummaryGroupId? sourceSummaryGroupId,
}) {
  if (_blockedOutputFieldIds.contains(fieldId)) {
    add(
      id: 'activeBlockedOutputField',
      severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
      message: '$fieldId cannot be active output',
      validationRowId: validationRowId,
      sourceSummaryGroupId: sourceSummaryGroupId,
      fieldId: fieldId,
    );
  }
}

void _checkAndroidProofCase(
  void Function({
    required String id,
    required InternalAdapterReadinessSummaryValidationSeverity severity,
    required String message,
    String? validationRowId,
    InternalAdapterReadinessSummaryGroupId? sourceSummaryGroupId,
    String? summaryRecordId,
    String? adapterPacketId,
    String? fieldId,
    String? caseId,
  })
  add,
  String caseId,
  List<String> provenAndroidIds, {
  String? validationRowId,
  InternalAdapterReadinessSummaryGroupId? sourceSummaryGroupId,
}) {
  if (_phase32ECaseIds.contains(caseId)) {
    add(
      id: 'phase32ECaseTreatedAsCapturedProof',
      severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
      message: '$caseId cannot be captured Android proof',
      validationRowId: validationRowId,
      sourceSummaryGroupId: sourceSummaryGroupId,
      caseId: caseId,
    );
    return;
  }
  if (!_capturedAndroidProofIds.contains(caseId) ||
      !provenAndroidIds.contains(caseId)) {
    add(
      id: 'unprovenAndroidProofId',
      severity: InternalAdapterReadinessSummaryValidationSeverity.critical,
      message: '$caseId is not captured Android proof',
      validationRowId: validationRowId,
      sourceSummaryGroupId: sourceSummaryGroupId,
      caseId: caseId,
    );
  }
}

List<String> _provenAndroidProofIds(GoldenAndroidProofEvidence? evidence) {
  return _sortedStrings(evidence?.targetCaseIds ?? const <String>[]);
}

int _compareFindings(
  InternalAdapterReadinessSummaryValidationFinding a,
  InternalAdapterReadinessSummaryValidationFinding b,
) {
  final severity = _severityRank(
    b.severity,
  ).compareTo(_severityRank(a.severity));
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.validationRowId ?? '').compareTo(b.validationRowId ?? '');
}

int _severityRank(InternalAdapterReadinessSummaryValidationSeverity severity) {
  return switch (severity) {
    InternalAdapterReadinessSummaryValidationSeverity.none => 0,
    InternalAdapterReadinessSummaryValidationSeverity.info => 0,
    InternalAdapterReadinessSummaryValidationSeverity.warning => 1,
    InternalAdapterReadinessSummaryValidationSeverity.blocker => 2,
    InternalAdapterReadinessSummaryValidationSeverity.critical => 3,
  };
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.where((value) => value.trim().isNotEmpty).toSet().toList()
    ..sort();
}

String _ids(Iterable<String> values) {
  final sorted = _sortedStrings(values);
  return sorted.isEmpty ? 'none' : sorted.map(_cell).join(', ');
}

String _validationRowIds(
  Iterable<InternalAdapterReadinessSummaryValidationRow> rows,
) {
  return _ids(rows.map((row) => row.validationRowId));
}

String _cell(String value) {
  if (value.isEmpty) return 'none';
  return value.replaceAll('|', '/').replaceAll('\n', ' ');
}

bool _setEquals(Iterable<String> left, Iterable<String> right) {
  final leftSet = left.toSet();
  final rightSet = right.toSet();
  return leftSet.length == rightSet.length && leftSet.containsAll(rightSet);
}

bool _isBlockedOutputFieldId(String value) {
  return _blockedOutputFieldIds.contains(value);
}

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

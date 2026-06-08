/// Developer-only validation for the debug bridge readiness summary.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_adapter_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/internal_adapter_readiness_summary_validation.dart';

const debugBridgeReadinessSummaryValidationReportVersion =
    'debug-bridge-readiness-summary-validation-v1';

enum DebugBridgeReadinessSummaryValidationStatus {
  validatedWithWarnings('validatedWithWarnings'),
  validatedClean('validatedClean'),
  blockedByUnsafeSummary('blockedByUnsafeSummary'),
  blockedBySummaryMismatch('blockedBySummaryMismatch'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const DebugBridgeReadinessSummaryValidationStatus(this.wire);

  final String wire;
}

enum DebugBridgeReadinessSummaryValidationCheckStatus {
  passed('passed'),
  passedWithWarnings('passedWithWarnings'),
  failed('failed'),
  blocked('blocked'),
  notApplicable('notApplicable');

  const DebugBridgeReadinessSummaryValidationCheckStatus(this.wire);

  final String wire;

  bool get isPassed => this == passed || this == passedWithWarnings;

  bool get isWarning => this == passedWithWarnings;

  bool get isBlocked => this == failed || this == blocked;
}

enum DebugBridgeReadinessSummaryValidationSeverity {
  none('none'),
  info('info'),
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const DebugBridgeReadinessSummaryValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict => this == blocker || this == critical;

  bool get isCritical => this == critical;
}

enum DebugBridgeReadinessSummaryGroupKind {
  validReadyDebugCoreInputSummary('validReadyDebugCoreInputSummary'),
  validConstrainedDebugContextInputSummary(
    'validConstrainedDebugContextInputSummary',
  ),
  validInactiveDebugBlockedInputSummary(
    'validInactiveDebugBlockedInputSummary',
  ),
  validInactiveDebugFutureOnlyInputSummary(
    'validInactiveDebugFutureOnlyInputSummary',
  ),
  validReadyAllowedDebugFieldSummary('validReadyAllowedDebugFieldSummary'),
  validDeniedBlockedDebugFieldSummary('validDeniedBlockedDebugFieldSummary'),
  validStockfishRawUciPvDumpBlockedSummary(
    'validStockfishRawUciPvDumpBlockedSummary',
  ),
  validAndroidProofBoundarySummary('validAndroidProofBoundarySummary'),
  validOwnerProofStatusSummary('validOwnerProofStatusSummary');

  const DebugBridgeReadinessSummaryGroupKind(this.wire);

  final String wire;
}

enum DebugBridgeReadinessSummaryGroupValidationStatus {
  validReadyDebugCoreInputSummary('validReadyDebugCoreInputSummary'),
  validConstrainedDebugContextInputSummary(
    'validConstrainedDebugContextInputSummary',
  ),
  validInactiveDebugBlockedInputSummary(
    'validInactiveDebugBlockedInputSummary',
  ),
  validInactiveDebugFutureOnlyInputSummary(
    'validInactiveDebugFutureOnlyInputSummary',
  ),
  validReadyAllowedDebugFieldSummary('validReadyAllowedDebugFieldSummary'),
  validDeniedBlockedDebugFieldSummary('validDeniedBlockedDebugFieldSummary'),
  validStockfishRawUciPvDumpBlockedSummary(
    'validStockfishRawUciPvDumpBlockedSummary',
  ),
  validAndroidProofBoundarySummary('validAndroidProofBoundarySummary'),
  validOwnerProofStatusSummary('validOwnerProofStatusSummary'),
  invalidSummaryGroup('invalidSummaryGroup'),
  unsafeSummaryGroup('unsafeSummaryGroup');

  const DebugBridgeReadinessSummaryGroupValidationStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == unsafeSummaryGroup;

  bool get isInvalid => this == invalidSummaryGroup;
}

enum DebugBridgeReadinessSummaryRecordValidationStatus {
  validReadyDebugCoreSummaryRecord('validReadyDebugCoreSummaryRecord'),
  validConstrainedDebugContextSummaryRecord(
    'validConstrainedDebugContextSummaryRecord',
  ),
  validInactiveBlockedSummaryRecord('validInactiveBlockedSummaryRecord'),
  validInactiveFutureOnlySummaryRecord('validInactiveFutureOnlySummaryRecord'),
  validAllowedFieldSummaryRecord('validAllowedFieldSummaryRecord'),
  validDeniedFieldSummaryRecord('validDeniedFieldSummaryRecord'),
  validStockfishRawUciPvDumpBlockedRecord(
    'validStockfishRawUciPvDumpBlockedRecord',
  ),
  validAndroidProofBoundaryRecord('validAndroidProofBoundaryRecord'),
  validOwnerProofStatusRecord('validOwnerProofStatusRecord'),
  invalidSummaryRecord('invalidSummaryRecord'),
  unsafeSummaryRecord('unsafeSummaryRecord');

  const DebugBridgeReadinessSummaryRecordValidationStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == unsafeSummaryRecord;

  bool get isInvalid => this == invalidSummaryRecord;

  bool get isInactiveBoundary =>
      this == validInactiveBlockedSummaryRecord ||
      this == validInactiveFutureOnlySummaryRecord ||
      this == validDeniedFieldSummaryRecord ||
      this == validStockfishRawUciPvDumpBlockedRecord;
}

enum DebugBridgeReadinessSummaryValidationRecommendation {
  keepReadyCoreSummaryValid('keepReadyCoreSummaryValid'),
  keepContextSummaryConstrained('keepContextSummaryConstrained'),
  keepBlockedSummaryInactive('keepBlockedSummaryInactive'),
  keepFutureSummaryInactive('keepFutureSummaryInactive'),
  keepAllowedFieldsSafe('keepAllowedFieldsSafe'),
  keepDeniedFieldsBlocked('keepDeniedFieldsBlocked'),
  keepStockfishRawUciPvDumpBlocked('keepStockfishRawUciPvDumpBlocked'),
  keepAndroidProofBoundaryCapturedOnly('keepAndroidProofBoundaryCapturedOnly'),
  keepOwnerProofEmpty('keepOwnerProofEmpty'),
  keepPolicyBoundariesBlocked('keepPolicyBoundariesBlocked'),
  investigateSummaryMismatch('investigateSummaryMismatch'),
  blockUnsafeSummaryValidation('blockUnsafeSummaryValidation');

  const DebugBridgeReadinessSummaryValidationRecommendation(this.wire);

  final String wire;
}

enum DebugBridgeReadinessSummaryValidationPhase32YRecommendation {
  proceedToDebugOnlyBridgePrototypeDesign(
    'proceedToDebugOnlyBridgePrototypeDesign',
  ),
  proceedToDebugBridgeReadinessValidationGate(
    'proceedToDebugBridgeReadinessValidationGate',
  ),
  proceedToDebugBridgeReadinessReportOnly(
    'proceedToDebugBridgeReadinessReportOnly',
  ),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeBridgeSummaryValidation(
    'blockedByUnsafeBridgeSummaryValidation',
  );

  const DebugBridgeReadinessSummaryValidationPhase32YRecommendation(this.wire);

  final String wire;
}

enum DebugBridgeReadinessSummaryValidationReportFormat {
  markdown('markdown'),
  json('json');

  const DebugBridgeReadinessSummaryValidationReportFormat(this.wire);

  final String wire;
}

class DebugBridgeReadinessSummaryValidationRequest {
  const DebugBridgeReadinessSummaryValidationRequest({
    this.summaryResult,
    this.readinessGateResult,
    this.bridgeValidationResult,
    this.designResult,
    this.internalSummaryValidationResult,
    this.internalSummaryResult,
    this.summary = const DebugBridgeReadinessSummary(),
    this.readinessGate = const DebugBridgeDesignReadinessGate(),
    this.bridgeValidation = const DebugOnlyAdapterBridgeDesignValidation(),
    this.design = const DebugOnlyAdapterBridgeDesign(),
    this.internalSummaryValidation =
        const InternalAdapterReadinessSummaryValidation(),
    this.internalSummary = const InternalAdapterReadinessSummary(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const DebugBridgeReadinessSummaryValidationRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final DebugBridgeReadinessSummaryResult? summaryResult;
  final DebugBridgeDesignReadinessGateResult? readinessGateResult;
  final DebugOnlyAdapterBridgeDesignValidationResult? bridgeValidationResult;
  final DebugOnlyAdapterBridgeDesignResult? designResult;
  final InternalAdapterReadinessSummaryValidationResult?
  internalSummaryValidationResult;
  final InternalAdapterReadinessSummaryResult? internalSummaryResult;
  final DebugBridgeReadinessSummary summary;
  final DebugBridgeDesignReadinessGate readinessGate;
  final DebugOnlyAdapterBridgeDesignValidation bridgeValidation;
  final DebugOnlyAdapterBridgeDesign design;
  final InternalAdapterReadinessSummaryValidation internalSummaryValidation;
  final InternalAdapterReadinessSummary internalSummary;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class DebugBridgeReadinessSummaryValidationCheck {
  const DebugBridgeReadinessSummaryValidationCheck({
    required this.checkId,
    required this.checkStatus,
    required this.severity,
    required this.relatedSummaryGroupIds,
    required this.relatedSummaryRecordIds,
    required this.relatedFieldIds,
    required this.relatedProofIds,
    required this.warningReason,
    required this.failureReason,
    required this.recommendation,
  });

  final String checkId;
  final DebugBridgeReadinessSummaryValidationCheckStatus checkStatus;
  final DebugBridgeReadinessSummaryValidationSeverity severity;
  final List<DebugBridgeReadinessSummaryGroupId> relatedSummaryGroupIds;
  final List<String> relatedSummaryRecordIds;
  final List<String> relatedFieldIds;
  final List<String> relatedProofIds;
  final String warningReason;
  final String failureReason;
  final DebugBridgeReadinessSummaryValidationRecommendation recommendation;

  bool get isBlocking =>
      checkStatus.isBlocked || severity.blocksStrict || severity.isCritical;

  bool get isCritical => severity.isCritical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'checkId': checkId,
      'checkStatus': checkStatus.wire,
      'severity': severity.wire,
      'relatedSummaryGroupIds': relatedSummaryGroupIds
          .map((id) => id.wire)
          .toList(),
      'relatedSummaryRecordIds': relatedSummaryRecordIds,
      'relatedFieldIds': relatedFieldIds,
      'relatedProofIds': relatedProofIds,
      'warningReason': warningReason,
      'failureReason': failureReason,
      'recommendation': recommendation.wire,
    };
  }
}

class DebugBridgeReadinessSummaryGroupValidationRow {
  const DebugBridgeReadinessSummaryGroupValidationRow({
    required this.validationRowId,
    required this.sourceSummaryGroupId,
    required this.groupKind,
    required this.validationStatus,
    required this.summaryRecordIds,
    required this.activeFieldIds,
    required this.deniedFieldIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.ownerProofQueueCount,
    required this.validationReason,
    required this.warningReason,
    required this.violationReasons,
    required this.safeForNextPhase,
    required this.recommendation,
  });

  final String validationRowId;
  final DebugBridgeReadinessSummaryGroupId sourceSummaryGroupId;
  final DebugBridgeReadinessSummaryGroupKind groupKind;
  final DebugBridgeReadinessSummaryGroupValidationStatus validationStatus;
  final List<String> summaryRecordIds;
  final List<String> activeFieldIds;
  final List<String> deniedFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final int ownerProofQueueCount;
  final String validationReason;
  final String warningReason;
  final List<String> violationReasons;
  final bool safeForNextPhase;
  final DebugBridgeReadinessSummaryValidationRecommendation recommendation;

  bool get hasUnsafeOutput =>
      validationStatus.isUnsafe ||
      activeFieldIds.any(_isBlockedBridgeFieldId) ||
      activeFieldIds.any(_isLegacyBlockedOutputFieldId);

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'validationRowId': validationRowId,
      'sourceSummaryGroupId': sourceSummaryGroupId.wire,
      'groupKind': groupKind.wire,
      'validationStatus': validationStatus.wire,
      'summaryRecordIds': summaryRecordIds,
      'activeFieldIds': activeFieldIds,
      'deniedFieldIds': deniedFieldIds,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'ownerProofQueueCount': ownerProofQueueCount,
      'validationReason': validationReason,
      'warningReason': warningReason,
      'violationReasons': violationReasons,
      'safeForNextPhase': safeForNextPhase,
      'recommendation': recommendation.wire,
    };
  }
}

class DebugBridgeReadinessSummaryRecordValidationRow {
  const DebugBridgeReadinessSummaryRecordValidationRow({
    required this.validationRowId,
    required this.sourceSummaryRecordId,
    required this.summaryRole,
    required this.summaryStatus,
    required this.validationStatus,
    required this.allowedForFutureDebugPrototypePlanning,
    required this.contextOnly,
    required this.inactive,
    required this.activeFieldIds,
    required this.deniedFieldIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.safetyFlags,
    required this.violationReasons,
    required this.safeForNextPhase,
    required this.recommendation,
  });

  final String validationRowId;
  final String sourceSummaryRecordId;
  final DebugBridgeReadinessSummaryRole summaryRole;
  final DebugBridgeReadinessSummaryItemStatus summaryStatus;
  final DebugBridgeReadinessSummaryRecordValidationStatus validationStatus;
  final bool allowedForFutureDebugPrototypePlanning;
  final bool contextOnly;
  final bool inactive;
  final List<String> activeFieldIds;
  final List<String> deniedFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final Map<String, bool> safetyFlags;
  final List<String> violationReasons;
  final bool safeForNextPhase;
  final DebugBridgeReadinessSummaryValidationRecommendation recommendation;

  bool get hasUnsafeOutput =>
      validationStatus.isUnsafe ||
      activeFieldIds.any(_isBlockedBridgeFieldId) ||
      activeFieldIds.any(_isLegacyBlockedOutputFieldId) ||
      safetyFlags.values.any((value) => value);

  DebugBridgeReadinessSummaryRecordValidationRow copyWith({
    String? validationRowId,
    String? sourceSummaryRecordId,
    DebugBridgeReadinessSummaryRole? summaryRole,
    DebugBridgeReadinessSummaryItemStatus? summaryStatus,
    DebugBridgeReadinessSummaryRecordValidationStatus? validationStatus,
    bool? allowedForFutureDebugPrototypePlanning,
    bool? contextOnly,
    bool? inactive,
    List<String>? activeFieldIds,
    List<String>? deniedFieldIds,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    Map<String, bool>? safetyFlags,
    List<String>? violationReasons,
    bool? safeForNextPhase,
    DebugBridgeReadinessSummaryValidationRecommendation? recommendation,
  }) {
    return DebugBridgeReadinessSummaryRecordValidationRow(
      validationRowId: validationRowId ?? this.validationRowId,
      sourceSummaryRecordId:
          sourceSummaryRecordId ?? this.sourceSummaryRecordId,
      summaryRole: summaryRole ?? this.summaryRole,
      summaryStatus: summaryStatus ?? this.summaryStatus,
      validationStatus: validationStatus ?? this.validationStatus,
      allowedForFutureDebugPrototypePlanning:
          allowedForFutureDebugPrototypePlanning ??
          this.allowedForFutureDebugPrototypePlanning,
      contextOnly: contextOnly ?? this.contextOnly,
      inactive: inactive ?? this.inactive,
      activeFieldIds: activeFieldIds ?? this.activeFieldIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      safetyFlags: safetyFlags ?? this.safetyFlags,
      violationReasons: violationReasons ?? this.violationReasons,
      safeForNextPhase: safeForNextPhase ?? this.safeForNextPhase,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'validationRowId': validationRowId,
      'sourceSummaryRecordId': sourceSummaryRecordId,
      'summaryRole': summaryRole.wire,
      'summaryStatus': summaryStatus.wire,
      'validationStatus': validationStatus.wire,
      'allowedForFutureDebugPrototypePlanning':
          allowedForFutureDebugPrototypePlanning,
      'contextOnly': contextOnly,
      'inactive': inactive,
      'activeFieldIds': activeFieldIds,
      'deniedFieldIds': deniedFieldIds,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'safetyFlags': safetyFlags,
      'violationReasons': violationReasons,
      'safeForNextPhase': safeForNextPhase,
      'recommendation': recommendation.wire,
    };
  }
}

class DebugBridgeReadinessSummaryValidationFinding {
  const DebugBridgeReadinessSummaryValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.validationRowId,
    this.summaryRecordId,
    this.summaryGroupId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final DebugBridgeReadinessSummaryValidationSeverity severity;
  final String message;
  final String? validationRowId;
  final String? summaryRecordId;
  final DebugBridgeReadinessSummaryGroupId? summaryGroupId;
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
      if (summaryRecordId != null) 'summaryRecordId': summaryRecordId,
      if (summaryGroupId != null) 'summaryGroupId': summaryGroupId!.wire,
      if (fieldId != null) 'fieldId': fieldId,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class DebugBridgeReadinessSummaryValidationResult {
  const DebugBridgeReadinessSummaryValidationResult({
    required this.validationStatus,
    required this.sourceSummaryStatus,
    required this.sourceReadinessStatus,
    required this.sourceBridgeValidationStatus,
    required this.validationChecks,
    required this.groupRows,
    required this.recordRows,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalChecks,
    required this.passedCheckCount,
    required this.warningCheckCount,
    required this.blockerCount,
    required this.criticalCount,
    required this.totalGroupRows,
    required this.totalRecordRows,
    required this.validReadyCoreSummaryCount,
    required this.validConstrainedContextSummaryCount,
    required this.validInactiveBlockedSummaryCount,
    required this.validInactiveFutureOnlySummaryCount,
    required this.validAllowedFieldSummaryCount,
    required this.validDeniedFieldSummaryCount,
    required this.validStockfishRawUciPvDumpBlockedCount,
    required this.validAndroidProofBoundaryCount,
    required this.validOwnerProofStatusCount,
    required this.invalidRecordCount,
    required this.unsafeRecordCount,
    required this.ownerProofQueueCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.safeForPhase32Y,
    required this.phase32YRecommendation,
    this.developerOnly = true,
    this.debugBridgeRuntimeImplemented = false,
    this.debugBridgePrototypeImplemented = false,
    this.productOutputActive = false,
    this.classifierOutputActive = false,
    this.finalMoveLabelOutputActive = false,
    this.officialMetricOutputActive = false,
    this.cpLossOutputActive = false,
    this.winProbabilityOutputActive = false,
    this.numericOutputActive = false,
    this.aggregateScoreOutputActive = false,
    this.moveRankingOutputActive = false,
    this.quietPreparatoryScopeActivated = false,
    this.engineCallsActive = false,
    this.persistenceWritesActive = false,
    this.uiTargetsActive = false,
    this.backendOutputActive = false,
    this.stockfishCommandFieldActive = false,
    this.rawUciFieldActive = false,
    this.pvDumpFieldActive = false,
  });

  final DebugBridgeReadinessSummaryValidationStatus validationStatus;
  final DebugBridgeReadinessSummaryStatus sourceSummaryStatus;
  final DebugBridgeDesignReadinessGateStatus sourceReadinessStatus;
  final DebugOnlyAdapterBridgeDesignValidationStatus
  sourceBridgeValidationStatus;
  final List<DebugBridgeReadinessSummaryValidationCheck> validationChecks;
  final List<DebugBridgeReadinessSummaryGroupValidationRow> groupRows;
  final List<DebugBridgeReadinessSummaryRecordValidationRow> recordRows;
  final List<DebugBridgeReadinessSummaryValidationFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalChecks;
  final int passedCheckCount;
  final int warningCheckCount;
  final int blockerCount;
  final int criticalCount;
  final int totalGroupRows;
  final int totalRecordRows;
  final int validReadyCoreSummaryCount;
  final int validConstrainedContextSummaryCount;
  final int validInactiveBlockedSummaryCount;
  final int validInactiveFutureOnlySummaryCount;
  final int validAllowedFieldSummaryCount;
  final int validDeniedFieldSummaryCount;
  final int validStockfishRawUciPvDumpBlockedCount;
  final int validAndroidProofBoundaryCount;
  final int validOwnerProofStatusCount;
  final int invalidRecordCount;
  final int unsafeRecordCount;
  final int ownerProofQueueCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final bool safeForPhase32Y;
  final DebugBridgeReadinessSummaryValidationPhase32YRecommendation
  phase32YRecommendation;
  final bool developerOnly;
  final bool debugBridgeRuntimeImplemented;
  final bool debugBridgePrototypeImplemented;
  final bool productOutputActive;
  final bool classifierOutputActive;
  final bool finalMoveLabelOutputActive;
  final bool officialMetricOutputActive;
  final bool cpLossOutputActive;
  final bool winProbabilityOutputActive;
  final bool numericOutputActive;
  final bool aggregateScoreOutputActive;
  final bool moveRankingOutputActive;
  final bool quietPreparatoryScopeActivated;
  final bool engineCallsActive;
  final bool persistenceWritesActive;
  final bool uiTargetsActive;
  final bool backendOutputActive;
  final bool stockfishCommandFieldActive;
  final bool rawUciFieldActive;
  final bool pvDumpFieldActive;

  bool get isStrictlyBlocked =>
      validationStatus ==
          DebugBridgeReadinessSummaryValidationStatus.blockedByUnsafeSummary ||
      validationStatus ==
          DebugBridgeReadinessSummaryValidationStatus.blockedByPolicyBoundary ||
      validationStatus ==
          DebugBridgeReadinessSummaryValidationStatus
              .blockedBySummaryMismatch ||
      validationStatus == DebugBridgeReadinessSummaryValidationStatus.invalid ||
      !safeForPhase32Y ||
      unsafeRecordCount > 0 ||
      criticalCount > 0 ||
      blockerCount > 0 ||
      validationChecks.any((check) => check.isBlocking) ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeDebugBridgeReadinessSummaryValidationPolicyViolation {
    return validationStatus ==
            DebugBridgeReadinessSummaryValidationStatus
                .blockedByUnsafeSummary ||
        validationStatus ==
            DebugBridgeReadinessSummaryValidationStatus
                .blockedByPolicyBoundary ||
        unsafeRecordCount > 0 ||
        criticalCount > 0 ||
        groupRows.any((row) => row.hasUnsafeOutput) ||
        recordRows.any((row) => row.hasUnsafeOutput) ||
        validationFindings.any((finding) => finding.isCritical) ||
        validationChecks.any((check) => check.severity.isCritical) ||
        allowedFieldIds.any(_isBlockedBridgeFieldId) ||
        allowedFieldIds.any(_isLegacyBlockedOutputFieldId) ||
        debugBridgeRuntimeImplemented ||
        debugBridgePrototypeImplemented ||
        productOutputActive ||
        classifierOutputActive ||
        finalMoveLabelOutputActive ||
        officialMetricOutputActive ||
        cpLossOutputActive ||
        winProbabilityOutputActive ||
        numericOutputActive ||
        aggregateScoreOutputActive ||
        moveRankingOutputActive ||
        quietPreparatoryScopeActivated ||
        engineCallsActive ||
        persistenceWritesActive ||
        uiTargetsActive ||
        backendOutputActive ||
        stockfishCommandFieldActive ||
        rawUciFieldActive ||
        pvDumpFieldActive;
  }

  DebugBridgeReadinessSummaryGroupValidationRow groupRowForGroup(
    DebugBridgeReadinessSummaryGroupId groupId,
  ) {
    return groupRows.singleWhere((row) => row.sourceSummaryGroupId == groupId);
  }

  DebugBridgeReadinessSummaryRecordValidationRow recordRowForRole(
    DebugBridgeReadinessSummaryRole role,
  ) {
    return recordRows.singleWhere((row) => row.summaryRole == role);
  }

  DebugBridgeReadinessSummaryValidationResult copyWith({
    DebugBridgeReadinessSummaryValidationStatus? validationStatus,
    DebugBridgeReadinessSummaryStatus? sourceSummaryStatus,
    DebugBridgeDesignReadinessGateStatus? sourceReadinessStatus,
    DebugOnlyAdapterBridgeDesignValidationStatus? sourceBridgeValidationStatus,
    List<DebugBridgeReadinessSummaryValidationCheck>? validationChecks,
    List<DebugBridgeReadinessSummaryGroupValidationRow>? groupRows,
    List<DebugBridgeReadinessSummaryRecordValidationRow>? recordRows,
    List<DebugBridgeReadinessSummaryValidationFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalChecks,
    int? passedCheckCount,
    int? warningCheckCount,
    int? blockerCount,
    int? criticalCount,
    int? totalGroupRows,
    int? totalRecordRows,
    int? validReadyCoreSummaryCount,
    int? validConstrainedContextSummaryCount,
    int? validInactiveBlockedSummaryCount,
    int? validInactiveFutureOnlySummaryCount,
    int? validAllowedFieldSummaryCount,
    int? validDeniedFieldSummaryCount,
    int? validStockfishRawUciPvDumpBlockedCount,
    int? validAndroidProofBoundaryCount,
    int? validOwnerProofStatusCount,
    int? invalidRecordCount,
    int? unsafeRecordCount,
    int? ownerProofQueueCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    bool? safeForPhase32Y,
    DebugBridgeReadinessSummaryValidationPhase32YRecommendation?
    phase32YRecommendation,
    bool? developerOnly,
    bool? debugBridgeRuntimeImplemented,
    bool? debugBridgePrototypeImplemented,
    bool? productOutputActive,
    bool? classifierOutputActive,
    bool? finalMoveLabelOutputActive,
    bool? officialMetricOutputActive,
    bool? cpLossOutputActive,
    bool? winProbabilityOutputActive,
    bool? numericOutputActive,
    bool? aggregateScoreOutputActive,
    bool? moveRankingOutputActive,
    bool? quietPreparatoryScopeActivated,
    bool? engineCallsActive,
    bool? persistenceWritesActive,
    bool? uiTargetsActive,
    bool? backendOutputActive,
    bool? stockfishCommandFieldActive,
    bool? rawUciFieldActive,
    bool? pvDumpFieldActive,
  }) {
    return DebugBridgeReadinessSummaryValidationResult(
      validationStatus: validationStatus ?? this.validationStatus,
      sourceSummaryStatus: sourceSummaryStatus ?? this.sourceSummaryStatus,
      sourceReadinessStatus:
          sourceReadinessStatus ?? this.sourceReadinessStatus,
      sourceBridgeValidationStatus:
          sourceBridgeValidationStatus ?? this.sourceBridgeValidationStatus,
      validationChecks: validationChecks ?? this.validationChecks,
      groupRows: groupRows ?? this.groupRows,
      recordRows: recordRows ?? this.recordRows,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalChecks: totalChecks ?? this.totalChecks,
      passedCheckCount: passedCheckCount ?? this.passedCheckCount,
      warningCheckCount: warningCheckCount ?? this.warningCheckCount,
      blockerCount: blockerCount ?? this.blockerCount,
      criticalCount: criticalCount ?? this.criticalCount,
      totalGroupRows: totalGroupRows ?? this.totalGroupRows,
      totalRecordRows: totalRecordRows ?? this.totalRecordRows,
      validReadyCoreSummaryCount:
          validReadyCoreSummaryCount ?? this.validReadyCoreSummaryCount,
      validConstrainedContextSummaryCount:
          validConstrainedContextSummaryCount ??
          this.validConstrainedContextSummaryCount,
      validInactiveBlockedSummaryCount:
          validInactiveBlockedSummaryCount ??
          this.validInactiveBlockedSummaryCount,
      validInactiveFutureOnlySummaryCount:
          validInactiveFutureOnlySummaryCount ??
          this.validInactiveFutureOnlySummaryCount,
      validAllowedFieldSummaryCount:
          validAllowedFieldSummaryCount ?? this.validAllowedFieldSummaryCount,
      validDeniedFieldSummaryCount:
          validDeniedFieldSummaryCount ?? this.validDeniedFieldSummaryCount,
      validStockfishRawUciPvDumpBlockedCount:
          validStockfishRawUciPvDumpBlockedCount ??
          this.validStockfishRawUciPvDumpBlockedCount,
      validAndroidProofBoundaryCount:
          validAndroidProofBoundaryCount ?? this.validAndroidProofBoundaryCount,
      validOwnerProofStatusCount:
          validOwnerProofStatusCount ?? this.validOwnerProofStatusCount,
      invalidRecordCount: invalidRecordCount ?? this.invalidRecordCount,
      unsafeRecordCount: unsafeRecordCount ?? this.unsafeRecordCount,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      allowedFieldIds: allowedFieldIds ?? this.allowedFieldIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      safeForPhase32Y: safeForPhase32Y ?? this.safeForPhase32Y,
      phase32YRecommendation:
          phase32YRecommendation ?? this.phase32YRecommendation,
      developerOnly: developerOnly ?? this.developerOnly,
      debugBridgeRuntimeImplemented:
          debugBridgeRuntimeImplemented ?? this.debugBridgeRuntimeImplemented,
      debugBridgePrototypeImplemented:
          debugBridgePrototypeImplemented ??
          this.debugBridgePrototypeImplemented,
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
      aggregateScoreOutputActive:
          aggregateScoreOutputActive ?? this.aggregateScoreOutputActive,
      moveRankingOutputActive:
          moveRankingOutputActive ?? this.moveRankingOutputActive,
      quietPreparatoryScopeActivated:
          quietPreparatoryScopeActivated ?? this.quietPreparatoryScopeActivated,
      engineCallsActive: engineCallsActive ?? this.engineCallsActive,
      persistenceWritesActive:
          persistenceWritesActive ?? this.persistenceWritesActive,
      uiTargetsActive: uiTargetsActive ?? this.uiTargetsActive,
      backendOutputActive: backendOutputActive ?? this.backendOutputActive,
      stockfishCommandFieldActive:
          stockfishCommandFieldActive ?? this.stockfishCommandFieldActive,
      rawUciFieldActive: rawUciFieldActive ?? this.rawUciFieldActive,
      pvDumpFieldActive: pvDumpFieldActive ?? this.pvDumpFieldActive,
    );
  }

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Debug Bridge Readiness Summary Validation')
      ..writeln()
      ..writeln(
        '- version: $debugBridgeReadinessSummaryValidationReportVersion',
      )
      ..writeln('- validation status: ${validationStatus.wire}')
      ..writeln('- source summary status: ${sourceSummaryStatus.wire}')
      ..writeln('- source readiness status: ${sourceReadinessStatus.wire}')
      ..writeln('- total checks: $totalChecks')
      ..writeln('- passed check count: $passedCheckCount')
      ..writeln('- warning check count: $warningCheckCount')
      ..writeln('- total group rows: $totalGroupRows')
      ..writeln('- total record rows: $totalRecordRows')
      ..writeln('- unsafe record count: $unsafeRecordCount')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- safeForPhase32Y: $safeForPhase32Y')
      ..writeln('- Phase 32Y recommendation: ${phase32YRecommendation.wire}')
      ..writeln()
      ..writeln('## Validation Check Table')
      ..writeln(
        '| Check | Status | Severity | Fields | Proof IDs | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- |');
    for (final check in validationChecks) {
      buffer.writeln(
        '| ${check.checkId} | ${check.checkStatus.wire} | ${check.severity.wire} | ${_ids(check.relatedFieldIds)} | ${_ids(check.relatedProofIds)} | ${check.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Summary Group Validation Table')
      ..writeln(
        '| Group | Kind | Status | Active fields | Denied fields | Safe | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
    for (final row in groupRows) {
      buffer.writeln(
        '| ${row.sourceSummaryGroupId.wire} | ${row.groupKind.wire} | ${row.validationStatus.wire} | ${_ids(row.activeFieldIds)} | ${_ids(row.deniedFieldIds)} | ${row.safeForNextPhase} | ${row.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Summary Record Validation Table')
      ..writeln(
        '| Record | Role | Status | Active fields | Denied fields | Safe | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
    for (final row in recordRows) {
      buffer.writeln(
        '| ${_cell(row.sourceSummaryRecordId)} | ${row.summaryRole.wire} | ${row.validationStatus.wire} | ${_ids(row.activeFieldIds)} | ${_ids(row.deniedFieldIds)} | ${row.safeForNextPhase} | ${row.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Ready Debug Core Validation')
      ..writeln('- valid ready core rows: $validReadyCoreSummaryCount')
      ..writeln()
      ..writeln('## Constrained Debug Context Validation')
      ..writeln(
        '- valid constrained context rows: $validConstrainedContextSummaryCount',
      )
      ..writeln()
      ..writeln('## Inactive Blocked/Future Validation')
      ..writeln(
        '- valid inactive blocked rows: $validInactiveBlockedSummaryCount',
      )
      ..writeln(
        '- valid inactive future-only rows: $validInactiveFutureOnlySummaryCount',
      )
      ..writeln()
      ..writeln('## Allowed And Denied Field Validation')
      ..writeln('- allowed bridge fields: ${_ids(allowedFieldIds)}')
      ..writeln('- denied bridge fields: ${_ids(deniedFieldIds)}')
      ..writeln()
      ..writeln('## Stockfish Raw UCI PV Dump Blocked Validation')
      ..writeln(
        '- stockfishCommand blocked: ${deniedFieldIds.contains('stockfishCommand')}',
      )
      ..writeln('- rawUci blocked: ${deniedFieldIds.contains('rawUci')}')
      ..writeln('- pvDump blocked: ${deniedFieldIds.contains('pvDump')}')
      ..writeln()
      ..writeln('## Android Proof Boundary Validation')
      ..writeln('- android proof IDs: ${_ids(androidProofCaseIds)}')
      ..writeln()
      ..writeln('## Owner Proof Validation')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Findings');
    if (validationFindings.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final finding in validationFindings) {
        buffer.writeln(
          '- ${finding.severity.wire}: ${finding.id} - ${finding.message}',
        );
      }
    }
    buffer
      ..writeln()
      ..writeln('## Phase 32Y Recommendation')
      ..writeln('- ${phase32YRecommendation.wire}');
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': debugBridgeReadinessSummaryValidationReportVersion,
      'validationStatus': validationStatus.wire,
      'sourceSummaryStatus': sourceSummaryStatus.wire,
      'sourceReadinessStatus': sourceReadinessStatus.wire,
      'sourceBridgeValidationStatus': sourceBridgeValidationStatus.wire,
      'totalChecks': totalChecks,
      'passedCheckCount': passedCheckCount,
      'warningCheckCount': warningCheckCount,
      'blockerCount': blockerCount,
      'criticalCount': criticalCount,
      'totalGroupRows': totalGroupRows,
      'totalRecordRows': totalRecordRows,
      'validReadyCoreSummaryCount': validReadyCoreSummaryCount,
      'validConstrainedContextSummaryCount':
          validConstrainedContextSummaryCount,
      'validInactiveBlockedSummaryCount': validInactiveBlockedSummaryCount,
      'validInactiveFutureOnlySummaryCount':
          validInactiveFutureOnlySummaryCount,
      'validAllowedFieldSummaryCount': validAllowedFieldSummaryCount,
      'validDeniedFieldSummaryCount': validDeniedFieldSummaryCount,
      'validStockfishRawUciPvDumpBlockedCount':
          validStockfishRawUciPvDumpBlockedCount,
      'validAndroidProofBoundaryCount': validAndroidProofBoundaryCount,
      'validOwnerProofStatusCount': validOwnerProofStatusCount,
      'invalidRecordCount': invalidRecordCount,
      'unsafeRecordCount': unsafeRecordCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'allowedFieldIds': allowedFieldIds,
      'deniedFieldIds': deniedFieldIds,
      'safeForPhase32Y': safeForPhase32Y,
      'phase32YRecommendation': phase32YRecommendation.wire,
      'validationChecks': validationChecks
          .map((check) => check.toJson())
          .toList(),
      'groupRows': groupRows.map((row) => row.toJson()).toList(),
      'recordRows': recordRows.map((row) => row.toJson()).toList(),
      'findings': validationFindings
          .map((finding) => finding.toJson())
          .toList(),
      'warnings': warnings,
      'failures': failures,
      'developerOnly': developerOnly,
      'debugBridgeRuntimeImplemented': debugBridgeRuntimeImplemented,
      'debugBridgePrototypeImplemented': debugBridgePrototypeImplemented,
      'policyFlags': <String, Object?>{
        'productOutputActive': productOutputActive,
        'classifierOutputActive': classifierOutputActive,
        'finalMoveLabelOutputActive': finalMoveLabelOutputActive,
        'officialMetricOutputActive': officialMetricOutputActive,
        'cpLossOutputActive': cpLossOutputActive,
        'winProbabilityOutputActive': winProbabilityOutputActive,
        'numericOutputActive': numericOutputActive,
        'aggregateScoreOutputActive': aggregateScoreOutputActive,
        'moveRankingOutputActive': moveRankingOutputActive,
        'quietPreparatoryScopeActivated': quietPreparatoryScopeActivated,
        'engineCallsActive': engineCallsActive,
        'persistenceWritesActive': persistenceWritesActive,
        'uiTargetsActive': uiTargetsActive,
        'backendOutputActive': backendOutputActive,
        'stockfishCommandFieldActive': stockfishCommandFieldActive,
        'rawUciFieldActive': rawUciFieldActive,
        'pvDumpFieldActive': pvDumpFieldActive,
      },
    };
  }
}

class DebugBridgeReadinessSummaryValidation {
  const DebugBridgeReadinessSummaryValidation({
    this.validator = const DebugBridgeReadinessSummaryValidationValidator(),
  });

  final DebugBridgeReadinessSummaryValidationValidator validator;

  DebugBridgeReadinessSummaryValidationResult evaluate([
    DebugBridgeReadinessSummaryValidationRequest request =
        const DebugBridgeReadinessSummaryValidationRequest(),
  ]) {
    final internalSummaryResult =
        request.internalSummaryResult ??
        request.internalSummary.evaluate(
          InternalAdapterReadinessSummaryRequest(
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final internalSummaryValidationResult =
        request.internalSummaryValidationResult ??
        request.internalSummaryValidation.evaluate(
          InternalAdapterReadinessSummaryValidationRequest(
            summaryResult: internalSummaryResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final designResult =
        request.designResult ??
        request.design.evaluate(
          DebugOnlyAdapterBridgeDesignRequest(
            summaryValidationResult: internalSummaryValidationResult,
            summaryResult: internalSummaryResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final bridgeValidationResult =
        request.bridgeValidationResult ??
        request.bridgeValidation.evaluate(
          DebugOnlyAdapterBridgeDesignValidationRequest(
            designResult: designResult,
            summaryValidationResult: internalSummaryValidationResult,
            summaryResult: internalSummaryResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final readinessGateResult =
        request.readinessGateResult ??
        request.readinessGate.evaluate(
          DebugBridgeDesignReadinessGateRequest(
            validationResult: bridgeValidationResult,
            designResult: designResult,
            summaryValidationResult: internalSummaryValidationResult,
            summaryResult: internalSummaryResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final summaryResult =
        request.summaryResult ??
        request.summary.evaluate(
          DebugBridgeReadinessSummaryRequest(
            readinessGateResult: readinessGateResult,
            validationResult: bridgeValidationResult,
            designResult: designResult,
            summaryValidationResult: internalSummaryValidationResult,
            summaryResult: internalSummaryResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final checks = _checksFromSummary(
      summaryResult: summaryResult,
      readinessGateResult: readinessGateResult,
    );
    final groupRows = _groupRowsFromSummary(summaryResult);
    final recordRows = _recordRowsFromSummary(summaryResult);
    final base = _resultFromRows(
      summaryResult: summaryResult,
      readinessGateResult: readinessGateResult,
      bridgeValidationResult: bridgeValidationResult,
      checks: checks,
      groupRows: groupRows,
      recordRows: recordRows,
      validationFindings:
          const <DebugBridgeReadinessSummaryValidationFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromRows(
      summaryResult: summaryResult,
      readinessGateResult: readinessGateResult,
      bridgeValidationResult: bridgeValidationResult,
      checks: checks,
      groupRows: groupRows,
      recordRows: recordRows,
      validationFindings: findings,
    );
  }
}

class DebugBridgeReadinessSummaryValidationValidator {
  const DebugBridgeReadinessSummaryValidationValidator();

  List<DebugBridgeReadinessSummaryValidationFinding> validate(
    DebugBridgeReadinessSummaryValidationResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <DebugBridgeReadinessSummaryValidationFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required DebugBridgeReadinessSummaryValidationSeverity severity,
      required String message,
      String? validationRowId,
      String? summaryRecordId,
      DebugBridgeReadinessSummaryGroupId? summaryGroupId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        DebugBridgeReadinessSummaryValidationFinding(
          id: id,
          severity: severity,
          message: message,
          validationRowId: validationRowId,
          summaryRecordId: summaryRecordId,
          summaryGroupId: summaryGroupId,
          fieldId: fieldId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase32Y &&
        (result.sourceSummaryStatus ==
                DebugBridgeReadinessSummaryStatus.blockedByUnsafeReadiness ||
            result.sourceSummaryStatus ==
                DebugBridgeReadinessSummaryStatus.blockedByPolicyBoundary ||
            result.unsafeRecordCount > 0)) {
      add(
        id: 'unsafeBridgeSummaryMarkedValidated',
        severity: DebugBridgeReadinessSummaryValidationSeverity.critical,
        message: 'unsafe bridge summary cannot be marked validated',
      );
    }
    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: DebugBridgeReadinessSummaryValidationSeverity.blocker,
        message: 'owner proof requires explicit PV/MultiPV reason',
      );
    }
    for (final fieldId in _blockedBridgeFieldIds) {
      if (!result.deniedFieldIds.contains(fieldId)) {
        add(
          id: 'deniedBridgeFieldMissing',
          severity: DebugBridgeReadinessSummaryValidationSeverity.blocker,
          message: '$fieldId must remain denied in bridge summary validation',
          fieldId: fieldId,
        );
      }
    }
    for (final fieldId in result.allowedFieldIds) {
      _checkActiveBridgeField(add, fieldId);
    }
    for (final caseId in result.androidProofCaseIds) {
      _checkAndroidProofCase(add, caseId, provenAndroidIds);
    }
    for (final row in result.groupRows) {
      for (final fieldId in row.activeFieldIds) {
        _checkActiveBridgeField(
          add,
          fieldId,
          validationRowId: row.validationRowId,
          summaryGroupId: row.sourceSummaryGroupId,
        );
      }
      for (final caseId in row.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          validationRowId: row.validationRowId,
          summaryGroupId: row.sourceSummaryGroupId,
        );
      }
    }
    for (final row in result.recordRows) {
      for (final fieldId in row.activeFieldIds) {
        _checkActiveBridgeField(
          add,
          fieldId,
          validationRowId: row.validationRowId,
          summaryRecordId: row.sourceSummaryRecordId,
        );
      }
      for (final caseId in row.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          validationRowId: row.validationRowId,
          summaryRecordId: row.sourceSummaryRecordId,
        );
      }
      if (row.validationStatus ==
              DebugBridgeReadinessSummaryRecordValidationStatus
                  .validReadyDebugCoreSummaryRecord &&
          row.violationReasons.contains('debugCoreConsumesNonCoreInput')) {
        add(
          id: 'readyCoreSummaryConsumesNonCoreInput',
          severity: DebugBridgeReadinessSummaryValidationSeverity.critical,
          message: 'ready core summary cannot consume non-core input',
          validationRowId: row.validationRowId,
          summaryRecordId: row.sourceSummaryRecordId,
        );
      }
      if (row.contextOnly &&
          row.validationStatus ==
              DebugBridgeReadinessSummaryRecordValidationStatus
                  .validReadyDebugCoreSummaryRecord) {
        add(
          id: 'contextOnlySummaryPromotedToDebugCore',
          severity: DebugBridgeReadinessSummaryValidationSeverity.critical,
          message: 'context-only summary cannot become debug core validation',
          validationRowId: row.validationRowId,
          summaryRecordId: row.sourceSummaryRecordId,
        );
      }
      if (row.validationStatus.isInactiveBoundary &&
          !_recordIsInactiveSafe(row)) {
        add(
          id: 'blockedFutureSummaryMadeActive',
          severity: DebugBridgeReadinessSummaryValidationSeverity.critical,
          message: 'blocked/future/denied validation rows must remain inactive',
          validationRowId: row.validationRowId,
          summaryRecordId: row.sourceSummaryRecordId,
        );
      }
      _checkSafetyFlags(add, row);
    }
    if (result.debugBridgeRuntimeImplemented ||
        result.debugBridgePrototypeImplemented ||
        result.productOutputActive ||
        result.classifierOutputActive ||
        result.finalMoveLabelOutputActive ||
        result.officialMetricOutputActive ||
        result.cpLossOutputActive ||
        result.winProbabilityOutputActive ||
        result.numericOutputActive ||
        result.aggregateScoreOutputActive ||
        result.moveRankingOutputActive ||
        result.quietPreparatoryScopeActivated ||
        result.engineCallsActive ||
        result.persistenceWritesActive ||
        result.uiTargetsActive ||
        result.backendOutputActive ||
        result.stockfishCommandFieldActive ||
        result.rawUciFieldActive ||
        result.pvDumpFieldActive) {
      add(
        id: 'debugBridgeReadinessSummaryValidationBoundaryPolicyViolation',
        severity: DebugBridgeReadinessSummaryValidationSeverity.critical,
        message: 'debug bridge summary validation crossed a blocked boundary',
      );
    }
    return findings..sort(_compareFindings);
  }

  List<DebugBridgeReadinessSummaryValidationFinding> validateReportText(
    String reportText,
  ) {
    final findings = <DebugBridgeReadinessSummaryValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        DebugBridgeReadinessSummaryValidationFinding(
          id: id,
          severity: DebugBridgeReadinessSummaryValidationSeverity.critical,
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
    for (final fieldId in _blockedBridgeFieldIds) {
      if (lower.contains('active fields: ${fieldId.toLowerCase()}')) {
        reportError(
          'activeDeniedFieldReportText',
          'report contains denied active output text',
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
    if (lower.contains('stockfish command active') ||
        lower.contains('raw uci active') ||
        lower.contains('pv dump active')) {
      reportError(
        'engineDumpFieldReportText',
        'report contains active engine dump field text',
      );
    }
    return findings..sort(_compareFindings);
  }
}

List<DebugBridgeReadinessSummaryValidationCheck> _checksFromSummary({
  required DebugBridgeReadinessSummaryResult summaryResult,
  required DebugBridgeDesignReadinessGateResult readinessGateResult,
}) {
  DebugBridgeReadinessSummaryValidationCheck check(
    String id,
    bool passed, {
    bool warning = false,
    Iterable<DebugBridgeReadinessSummaryGroupId> groups = const [],
    Iterable<String> records = const [],
    Iterable<String> fields = const [],
    Iterable<String> proofs = const [],
    String warningReason = '',
    String failureReason = '',
    DebugBridgeReadinessSummaryValidationRecommendation recommendation =
        DebugBridgeReadinessSummaryValidationRecommendation
            .keepPolicyBoundariesBlocked,
  }) {
    return DebugBridgeReadinessSummaryValidationCheck(
      checkId: id,
      checkStatus: passed
          ? warning
                ? DebugBridgeReadinessSummaryValidationCheckStatus
                      .passedWithWarnings
                : DebugBridgeReadinessSummaryValidationCheckStatus.passed
          : DebugBridgeReadinessSummaryValidationCheckStatus.failed,
      severity: passed
          ? warning
                ? DebugBridgeReadinessSummaryValidationSeverity.warning
                : DebugBridgeReadinessSummaryValidationSeverity.none
          : DebugBridgeReadinessSummaryValidationSeverity.blocker,
      relatedSummaryGroupIds: groups.toList(growable: false),
      relatedSummaryRecordIds: _sortedStrings(records),
      relatedFieldIds: _sortedStrings(fields),
      relatedProofIds: _sortedStrings(proofs),
      warningReason: warningReason,
      failureReason: passed ? '' : failureReason,
      recommendation: recommendation,
    );
  }

  final summaryGroupIds = summaryResult.summaryGroups
      .map((group) => group.groupId)
      .toSet();
  final summaryRecordIds = summaryResult.summaryRecords
      .map((record) => record.summaryRecordId)
      .toList(growable: false);
  return <DebugBridgeReadinessSummaryValidationCheck>[
    check(
      'summaryConsumesReadinessGate',
      summaryResult.sourceReadinessStatus ==
              readinessGateResult.readinessStatus &&
          summaryResult.safeForPhase32X == readinessGateResult.safeForPhase32W,
      records: summaryRecordIds,
      failureReason: 'summary does not reflect readiness gate status',
      recommendation: DebugBridgeReadinessSummaryValidationRecommendation
          .investigateSummaryMismatch,
    ),
    check(
      'readyCoreSummaryMatchesReadinessGate',
      summaryGroupIds.contains(
            DebugBridgeReadinessSummaryGroupId.readyDebugCoreInputSummary,
          ) &&
          summaryResult.readyDebugCoreInputCount == 1,
      groups: const <DebugBridgeReadinessSummaryGroupId>[
        DebugBridgeReadinessSummaryGroupId.readyDebugCoreInputSummary,
      ],
      recommendation: DebugBridgeReadinessSummaryValidationRecommendation
          .keepReadyCoreSummaryValid,
    ),
    check(
      'constrainedContextSummaryMatchesReadinessGate',
      summaryGroupIds.contains(
            DebugBridgeReadinessSummaryGroupId
                .constrainedDebugContextInputSummary,
          ) &&
          summaryResult.constrainedDebugContextInputCount == 1,
      warning: true,
      groups: const <DebugBridgeReadinessSummaryGroupId>[
        DebugBridgeReadinessSummaryGroupId.constrainedDebugContextInputSummary,
      ],
      warningReason: 'context summary remains constrained by design',
      recommendation: DebugBridgeReadinessSummaryValidationRecommendation
          .keepContextSummaryConstrained,
    ),
    check(
      'inactiveBlockedSummaryMatchesReadinessGate',
      summaryGroupIds.contains(
            DebugBridgeReadinessSummaryGroupId.inactiveDebugBlockedInputSummary,
          ) &&
          summaryResult.inactiveBlockedInputCount == 1,
      warning: true,
      groups: const <DebugBridgeReadinessSummaryGroupId>[
        DebugBridgeReadinessSummaryGroupId.inactiveDebugBlockedInputSummary,
      ],
      warningReason: 'blocked summary remains inactive by design',
      recommendation: DebugBridgeReadinessSummaryValidationRecommendation
          .keepBlockedSummaryInactive,
    ),
    check(
      'inactiveFutureOnlySummaryMatchesReadinessGate',
      summaryGroupIds.contains(
            DebugBridgeReadinessSummaryGroupId
                .inactiveDebugFutureOnlyInputSummary,
          ) &&
          summaryResult.inactiveFutureOnlyInputCount == 1,
      warning: true,
      groups: const <DebugBridgeReadinessSummaryGroupId>[
        DebugBridgeReadinessSummaryGroupId.inactiveDebugFutureOnlyInputSummary,
      ],
      warningReason: 'future-only summary remains inactive by design',
      recommendation: DebugBridgeReadinessSummaryValidationRecommendation
          .keepFutureSummaryInactive,
    ),
    check(
      'allowedDebugFieldsRemainSafe',
      summaryResult.allowedFieldIds.every(
        (field) =>
            !_isBlockedBridgeFieldId(field) &&
            !_isLegacyBlockedOutputFieldId(field),
      ),
      fields: summaryResult.allowedFieldIds,
      recommendation: DebugBridgeReadinessSummaryValidationRecommendation
          .keepAllowedFieldsSafe,
    ),
    check(
      'deniedDebugFieldsRemainDenied',
      _blockedBridgeFieldIds.every(summaryResult.deniedFieldIds.contains),
      fields: summaryResult.deniedFieldIds,
      recommendation: DebugBridgeReadinessSummaryValidationRecommendation
          .keepDeniedFieldsBlocked,
    ),
    check(
      'stockfishCommandRawUciPvDumpRemainBlocked',
      _engineDumpFieldIds.every(summaryResult.deniedFieldIds.contains) &&
          !summaryResult.stockfishCommandFieldActive &&
          !summaryResult.rawUciFieldActive &&
          !summaryResult.pvDumpFieldActive,
      fields: _engineDumpFieldIds,
      recommendation: DebugBridgeReadinessSummaryValidationRecommendation
          .keepStockfishRawUciPvDumpBlocked,
    ),
    check(
      'androidProofIdsAreCapturedOnly',
      _sameStringSet(
        summaryResult.androidProofCaseIds,
        _capturedAndroidProofIds,
      ),
      proofs: summaryResult.androidProofCaseIds,
      recommendation: DebugBridgeReadinessSummaryValidationRecommendation
          .keepAndroidProofBoundaryCapturedOnly,
    ),
    check(
      'phase32ECasesAreNotCapturedProof',
      summaryResult.androidProofCaseIds.every(
        (caseId) => !_phase32ECaseIds.contains(caseId),
      ),
      proofs: summaryResult.androidProofCaseIds,
      recommendation: DebugBridgeReadinessSummaryValidationRecommendation
          .keepAndroidProofBoundaryCapturedOnly,
    ),
    check(
      'ownerProofQueueRemainsEmpty',
      summaryResult.ownerProofQueueCount == 0,
      recommendation: DebugBridgeReadinessSummaryValidationRecommendation
          .keepOwnerProofEmpty,
    ),
    check(
      'noLabelsScoresRankingsMetrics',
      !summaryResult.classifierOutputActive &&
          !summaryResult.finalMoveLabelOutputActive &&
          !summaryResult.numericOutputActive &&
          !summaryResult.aggregateScoreOutputActive &&
          !summaryResult.moveRankingOutputActive &&
          !summaryResult.officialMetricOutputActive &&
          !summaryResult.cpLossOutputActive &&
          !summaryResult.winProbabilityOutputActive,
      recommendation: DebugBridgeReadinessSummaryValidationRecommendation
          .keepPolicyBoundariesBlocked,
    ),
    check(
      'noUiBackendPersistenceEngineFields',
      !summaryResult.uiTargetsActive &&
          !summaryResult.backendOutputActive &&
          !summaryResult.persistenceWritesActive &&
          !summaryResult.engineCallsActive &&
          !summaryResult.stockfishCommandFieldActive &&
          !summaryResult.rawUciFieldActive &&
          !summaryResult.pvDumpFieldActive,
      recommendation: DebugBridgeReadinessSummaryValidationRecommendation
          .keepPolicyBoundariesBlocked,
    ),
    check(
      'quietScopeRemainsExcluded',
      !summaryResult.quietPreparatoryScopeActivated,
      recommendation: DebugBridgeReadinessSummaryValidationRecommendation
          .keepPolicyBoundariesBlocked,
    ),
    check(
      'productBoundariesRemainBlocked',
      !summaryResult.productOutputActive &&
          !summaryResult.debugBridgeRuntimeImplemented &&
          !summaryResult.debugBridgePrototypeImplemented,
      recommendation: DebugBridgeReadinessSummaryValidationRecommendation
          .keepPolicyBoundariesBlocked,
    ),
  ];
}

List<DebugBridgeReadinessSummaryGroupValidationRow> _groupRowsFromSummary(
  DebugBridgeReadinessSummaryResult summaryResult,
) {
  return <DebugBridgeReadinessSummaryGroupValidationRow>[
    _groupRow(
      summaryResult,
      DebugBridgeReadinessSummaryGroupId.readyDebugCoreInputSummary,
      DebugBridgeReadinessSummaryGroupKind.validReadyDebugCoreInputSummary,
      DebugBridgeReadinessSummaryGroupValidationStatus
          .validReadyDebugCoreInputSummary,
      DebugBridgeReadinessSummaryValidationRecommendation
          .keepReadyCoreSummaryValid,
      'ready debug core summary matches readiness gate',
    ),
    _groupRow(
      summaryResult,
      DebugBridgeReadinessSummaryGroupId.constrainedDebugContextInputSummary,
      DebugBridgeReadinessSummaryGroupKind
          .validConstrainedDebugContextInputSummary,
      DebugBridgeReadinessSummaryGroupValidationStatus
          .validConstrainedDebugContextInputSummary,
      DebugBridgeReadinessSummaryValidationRecommendation
          .keepContextSummaryConstrained,
      'constrained context summary remains context-only',
      warningReason: 'context summary remains constrained',
    ),
    _groupRow(
      summaryResult,
      DebugBridgeReadinessSummaryGroupId.inactiveDebugBlockedInputSummary,
      DebugBridgeReadinessSummaryGroupKind
          .validInactiveDebugBlockedInputSummary,
      DebugBridgeReadinessSummaryGroupValidationStatus
          .validInactiveDebugBlockedInputSummary,
      DebugBridgeReadinessSummaryValidationRecommendation
          .keepBlockedSummaryInactive,
      'blocked summary remains inactive',
      warningReason: 'blocked summary remains inactive',
    ),
    _groupRow(
      summaryResult,
      DebugBridgeReadinessSummaryGroupId.inactiveDebugFutureOnlyInputSummary,
      DebugBridgeReadinessSummaryGroupKind
          .validInactiveDebugFutureOnlyInputSummary,
      DebugBridgeReadinessSummaryGroupValidationStatus
          .validInactiveDebugFutureOnlyInputSummary,
      DebugBridgeReadinessSummaryValidationRecommendation
          .keepFutureSummaryInactive,
      'future-only summary remains inactive',
      warningReason: 'future-only summary remains inactive',
    ),
    _groupRow(
      summaryResult,
      DebugBridgeReadinessSummaryGroupId.readyAllowedDebugFieldSummary,
      DebugBridgeReadinessSummaryGroupKind.validReadyAllowedDebugFieldSummary,
      DebugBridgeReadinessSummaryGroupValidationStatus
          .validReadyAllowedDebugFieldSummary,
      DebugBridgeReadinessSummaryValidationRecommendation.keepAllowedFieldsSafe,
      'allowed debug fields remain internal evidence-safe',
    ),
    _groupRow(
      summaryResult,
      DebugBridgeReadinessSummaryGroupId.deniedBlockedDebugFieldSummary,
      DebugBridgeReadinessSummaryGroupKind.validDeniedBlockedDebugFieldSummary,
      DebugBridgeReadinessSummaryGroupValidationStatus
          .validDeniedBlockedDebugFieldSummary,
      DebugBridgeReadinessSummaryValidationRecommendation
          .keepDeniedFieldsBlocked,
      'denied fields remain blocked',
    ),
    _groupRow(
      summaryResult,
      DebugBridgeReadinessSummaryGroupId.stockfishRawUciPvDumpBlockedSummary,
      DebugBridgeReadinessSummaryGroupKind
          .validStockfishRawUciPvDumpBlockedSummary,
      DebugBridgeReadinessSummaryGroupValidationStatus
          .validStockfishRawUciPvDumpBlockedSummary,
      DebugBridgeReadinessSummaryValidationRecommendation
          .keepStockfishRawUciPvDumpBlocked,
      'Stockfish command, raw UCI, and PV dump remain blocked',
    ),
    _groupRow(
      summaryResult,
      DebugBridgeReadinessSummaryGroupId.androidProofBoundarySummary,
      DebugBridgeReadinessSummaryGroupKind.validAndroidProofBoundarySummary,
      DebugBridgeReadinessSummaryGroupValidationStatus
          .validAndroidProofBoundarySummary,
      DebugBridgeReadinessSummaryValidationRecommendation
          .keepAndroidProofBoundaryCapturedOnly,
      'Android proof boundary remains captured-only',
    ),
    _groupRow(
      summaryResult,
      DebugBridgeReadinessSummaryGroupId.ownerProofStatusSummary,
      DebugBridgeReadinessSummaryGroupKind.validOwnerProofStatusSummary,
      DebugBridgeReadinessSummaryGroupValidationStatus
          .validOwnerProofStatusSummary,
      DebugBridgeReadinessSummaryValidationRecommendation.keepOwnerProofEmpty,
      'owner proof status remains empty',
    ),
  ];
}

DebugBridgeReadinessSummaryGroupValidationRow _groupRow(
  DebugBridgeReadinessSummaryResult summaryResult,
  DebugBridgeReadinessSummaryGroupId groupId,
  DebugBridgeReadinessSummaryGroupKind groupKind,
  DebugBridgeReadinessSummaryGroupValidationStatus validStatus,
  DebugBridgeReadinessSummaryValidationRecommendation recommendation,
  String validationReason, {
  String warningReason = '',
}) {
  final group = summaryResult.group(groupId);
  final unsafe = group.hasUnsafeOutput;
  final invalid =
      !unsafe && (!group.safeForNextPhase || group.summaryStatus.isInvalid);
  final status = unsafe
      ? DebugBridgeReadinessSummaryGroupValidationStatus.unsafeSummaryGroup
      : invalid
      ? DebugBridgeReadinessSummaryGroupValidationStatus.invalidSummaryGroup
      : validStatus;
  return DebugBridgeReadinessSummaryGroupValidationRow(
    validationRowId: 'summary-group-validation-${group.groupId.wire}',
    sourceSummaryGroupId: group.groupId,
    groupKind: groupKind,
    validationStatus: status,
    summaryRecordIds: _sortedStrings(group.sourceReadinessRecordIds),
    activeFieldIds: _sortedStrings(group.activeFieldIds),
    deniedFieldIds: _sortedStrings(group.deniedFieldIds),
    supportCaseIds: _sortedStrings(group.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(group.newlyAddedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(group.androidProofCaseIds),
    ownerProofQueueCount:
        group.groupId ==
            DebugBridgeReadinessSummaryGroupId.ownerProofStatusSummary
        ? summaryResult.ownerProofQueueCount
        : 0,
    validationReason: validationReason,
    warningReason: warningReason,
    violationReasons: unsafe
        ? const <String>['unsafeSummaryGroup']
        : invalid
        ? const <String>['invalidSummaryGroup']
        : const <String>[],
    safeForNextPhase: !unsafe && !invalid,
    recommendation: unsafe
        ? DebugBridgeReadinessSummaryValidationRecommendation
              .blockUnsafeSummaryValidation
        : invalid
        ? DebugBridgeReadinessSummaryValidationRecommendation
              .investigateSummaryMismatch
        : recommendation,
  );
}

List<DebugBridgeReadinessSummaryRecordValidationRow> _recordRowsFromSummary(
  DebugBridgeReadinessSummaryResult summaryResult,
) {
  return <DebugBridgeReadinessSummaryRecordValidationRow>[
    _recordRow(
      summaryResult.recordForRole(
        DebugBridgeReadinessSummaryRole.readyDebugCoreInputSummaryRecord,
      ),
      DebugBridgeReadinessSummaryRecordValidationStatus
          .validReadyDebugCoreSummaryRecord,
      DebugBridgeReadinessSummaryValidationRecommendation
          .keepReadyCoreSummaryValid,
    ),
    _recordRow(
      summaryResult.recordForRole(
        DebugBridgeReadinessSummaryRole
            .constrainedDebugContextInputSummaryRecord,
      ),
      DebugBridgeReadinessSummaryRecordValidationStatus
          .validConstrainedDebugContextSummaryRecord,
      DebugBridgeReadinessSummaryValidationRecommendation
          .keepContextSummaryConstrained,
    ),
    _recordRow(
      summaryResult.recordForRole(
        DebugBridgeReadinessSummaryRole.inactiveDebugBlockedInputSummaryRecord,
      ),
      DebugBridgeReadinessSummaryRecordValidationStatus
          .validInactiveBlockedSummaryRecord,
      DebugBridgeReadinessSummaryValidationRecommendation
          .keepBlockedSummaryInactive,
    ),
    _recordRow(
      summaryResult.recordForRole(
        DebugBridgeReadinessSummaryRole
            .inactiveDebugFutureOnlyInputSummaryRecord,
      ),
      DebugBridgeReadinessSummaryRecordValidationStatus
          .validInactiveFutureOnlySummaryRecord,
      DebugBridgeReadinessSummaryValidationRecommendation
          .keepFutureSummaryInactive,
    ),
    _recordRow(
      summaryResult.recordForRole(
        DebugBridgeReadinessSummaryRole.readyAllowedDebugFieldSummaryRecord,
      ),
      DebugBridgeReadinessSummaryRecordValidationStatus
          .validAllowedFieldSummaryRecord,
      DebugBridgeReadinessSummaryValidationRecommendation.keepAllowedFieldsSafe,
    ),
    _recordRow(
      summaryResult.recordForRole(
        DebugBridgeReadinessSummaryRole.deniedBlockedDebugFieldSummaryRecord,
      ),
      DebugBridgeReadinessSummaryRecordValidationStatus
          .validDeniedFieldSummaryRecord,
      DebugBridgeReadinessSummaryValidationRecommendation
          .keepDeniedFieldsBlocked,
    ),
    _recordRow(
      summaryResult.recordForRole(
        DebugBridgeReadinessSummaryRole
            .stockfishRawUciPvDumpBlockedSummaryRecord,
      ),
      DebugBridgeReadinessSummaryRecordValidationStatus
          .validStockfishRawUciPvDumpBlockedRecord,
      DebugBridgeReadinessSummaryValidationRecommendation
          .keepStockfishRawUciPvDumpBlocked,
    ),
    _recordRow(
      summaryResult.recordForRole(
        DebugBridgeReadinessSummaryRole.androidProofBoundarySummaryRecord,
      ),
      DebugBridgeReadinessSummaryRecordValidationStatus
          .validAndroidProofBoundaryRecord,
      DebugBridgeReadinessSummaryValidationRecommendation
          .keepAndroidProofBoundaryCapturedOnly,
    ),
    _recordRow(
      summaryResult.recordForRole(
        DebugBridgeReadinessSummaryRole.ownerProofStatusSummaryRecord,
      ),
      DebugBridgeReadinessSummaryRecordValidationStatus
          .validOwnerProofStatusRecord,
      DebugBridgeReadinessSummaryValidationRecommendation.keepOwnerProofEmpty,
    ),
  ];
}

DebugBridgeReadinessSummaryRecordValidationRow _recordRow(
  DebugBridgeReadinessSummaryRecord record,
  DebugBridgeReadinessSummaryRecordValidationStatus validStatus,
  DebugBridgeReadinessSummaryValidationRecommendation recommendation,
) {
  final unsafe = record.hasUnsafeOutput;
  final invalid =
      !unsafe &&
      (record.summaryStatus.isInvalid || record.violationReasons.isNotEmpty);
  final status = unsafe
      ? DebugBridgeReadinessSummaryRecordValidationStatus.unsafeSummaryRecord
      : invalid
      ? DebugBridgeReadinessSummaryRecordValidationStatus.invalidSummaryRecord
      : validStatus;
  return DebugBridgeReadinessSummaryRecordValidationRow(
    validationRowId: 'summary-record-validation-${record.summaryRecordId}',
    sourceSummaryRecordId: record.summaryRecordId,
    summaryRole: record.summaryRole,
    summaryStatus: record.summaryStatus,
    validationStatus: status,
    allowedForFutureDebugPrototypePlanning:
        record.allowedForFutureDebugPrototypePlanning,
    contextOnly: record.contextOnly,
    inactive: record.inactive,
    activeFieldIds: _sortedStrings(record.activeFieldIds),
    deniedFieldIds: _sortedStrings(record.deniedFieldIds),
    supportCaseIds: _sortedStrings(record.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(record.newlyAddedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(record.androidProofCaseIds),
    safetyFlags: _safeFlagsFrom(record.safetyFlags),
    violationReasons: _sortedStrings(record.violationReasons),
    safeForNextPhase: !unsafe && !invalid,
    recommendation: unsafe
        ? DebugBridgeReadinessSummaryValidationRecommendation
              .blockUnsafeSummaryValidation
        : invalid
        ? DebugBridgeReadinessSummaryValidationRecommendation
              .investigateSummaryMismatch
        : recommendation,
  );
}

DebugBridgeReadinessSummaryValidationResult _resultFromRows({
  required DebugBridgeReadinessSummaryResult summaryResult,
  required DebugBridgeDesignReadinessGateResult readinessGateResult,
  required DebugOnlyAdapterBridgeDesignValidationResult bridgeValidationResult,
  required List<DebugBridgeReadinessSummaryValidationCheck> checks,
  required List<DebugBridgeReadinessSummaryGroupValidationRow> groupRows,
  required List<DebugBridgeReadinessSummaryRecordValidationRow> recordRows,
  required List<DebugBridgeReadinessSummaryValidationFinding>
  validationFindings,
}) {
  final unsafeRecordCount =
      recordRows.where((row) => row.hasUnsafeOutput).length +
      groupRows.where((row) => row.hasUnsafeOutput).length +
      summaryResult.unsafeCount;
  final blockerCount =
      checks.where((check) => check.isBlocking).length +
      validationFindings.where((finding) => finding.blocksStrict).length;
  final criticalCount =
      checks.where((check) => check.isCritical).length +
      validationFindings.where((finding) => finding.isCritical).length;
  final base = DebugBridgeReadinessSummaryValidationResult(
    validationStatus: DebugBridgeReadinessSummaryValidationStatus.invalid,
    sourceSummaryStatus: summaryResult.summaryStatus,
    sourceReadinessStatus: readinessGateResult.readinessStatus,
    sourceBridgeValidationStatus: bridgeValidationResult.validationStatus,
    validationChecks: checks,
    groupRows: groupRows,
    recordRows: recordRows,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...summaryResult.warnings,
      ...checks
          .where((check) => check.checkStatus.isWarning)
          .map((check) => check.warningReason),
      'debug bridge runtime remains unimplemented',
      'debug bridge prototype remains unimplemented',
    ]),
    failures: _sortedStrings(<String>[
      ...summaryResult.failures,
      ...checks
          .where((check) => check.isBlocking)
          .map((check) => check.failureReason),
      ...validationFindings.map((finding) => finding.message),
      ...groupRows.expand((row) => row.violationReasons),
      ...recordRows.expand((row) => row.violationReasons),
    ]),
    totalChecks: checks.length,
    passedCheckCount: checks
        .where(
          (check) =>
              check.checkStatus ==
              DebugBridgeReadinessSummaryValidationCheckStatus.passed,
        )
        .length,
    warningCheckCount: checks
        .where(
          (check) =>
              check.checkStatus ==
              DebugBridgeReadinessSummaryValidationCheckStatus
                  .passedWithWarnings,
        )
        .length,
    blockerCount: blockerCount,
    criticalCount: criticalCount,
    totalGroupRows: groupRows.length,
    totalRecordRows: recordRows.length,
    validReadyCoreSummaryCount: _countRecordRows(
      recordRows,
      DebugBridgeReadinessSummaryRecordValidationStatus
          .validReadyDebugCoreSummaryRecord,
    ),
    validConstrainedContextSummaryCount: _countRecordRows(
      recordRows,
      DebugBridgeReadinessSummaryRecordValidationStatus
          .validConstrainedDebugContextSummaryRecord,
    ),
    validInactiveBlockedSummaryCount: _countRecordRows(
      recordRows,
      DebugBridgeReadinessSummaryRecordValidationStatus
          .validInactiveBlockedSummaryRecord,
    ),
    validInactiveFutureOnlySummaryCount: _countRecordRows(
      recordRows,
      DebugBridgeReadinessSummaryRecordValidationStatus
          .validInactiveFutureOnlySummaryRecord,
    ),
    validAllowedFieldSummaryCount: _countRecordRows(
      recordRows,
      DebugBridgeReadinessSummaryRecordValidationStatus
          .validAllowedFieldSummaryRecord,
    ),
    validDeniedFieldSummaryCount: _countRecordRows(
      recordRows,
      DebugBridgeReadinessSummaryRecordValidationStatus
          .validDeniedFieldSummaryRecord,
    ),
    validStockfishRawUciPvDumpBlockedCount: _countRecordRows(
      recordRows,
      DebugBridgeReadinessSummaryRecordValidationStatus
          .validStockfishRawUciPvDumpBlockedRecord,
    ),
    validAndroidProofBoundaryCount: _countRecordRows(
      recordRows,
      DebugBridgeReadinessSummaryRecordValidationStatus
          .validAndroidProofBoundaryRecord,
    ),
    validOwnerProofStatusCount: _countRecordRows(
      recordRows,
      DebugBridgeReadinessSummaryRecordValidationStatus
          .validOwnerProofStatusRecord,
    ),
    invalidRecordCount: recordRows
        .where((row) => row.validationStatus.isInvalid)
        .length,
    unsafeRecordCount: unsafeRecordCount,
    ownerProofQueueCount: summaryResult.ownerProofQueueCount,
    supportCaseIds: _sortedStrings(summaryResult.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(
      summaryResult.newlyAddedSupportCaseIds,
    ),
    androidProofCaseIds: _sortedStrings(summaryResult.androidProofCaseIds),
    allowedFieldIds: _sortedStrings(summaryResult.allowedFieldIds),
    deniedFieldIds: _sortedStrings(summaryResult.deniedFieldIds),
    safeForPhase32Y: false,
    phase32YRecommendation:
        DebugBridgeReadinessSummaryValidationPhase32YRecommendation
            .addMoreGoldenCoverageFirst,
    developerOnly:
        summaryResult.developerOnly &&
        readinessGateResult.developerOnly &&
        bridgeValidationResult.developerOnly,
    debugBridgeRuntimeImplemented: summaryResult.debugBridgeRuntimeImplemented,
    debugBridgePrototypeImplemented:
        summaryResult.debugBridgePrototypeImplemented,
    productOutputActive: summaryResult.productOutputActive,
    classifierOutputActive: summaryResult.classifierOutputActive,
    finalMoveLabelOutputActive: summaryResult.finalMoveLabelOutputActive,
    officialMetricOutputActive: summaryResult.officialMetricOutputActive,
    cpLossOutputActive: summaryResult.cpLossOutputActive,
    winProbabilityOutputActive: summaryResult.winProbabilityOutputActive,
    numericOutputActive: summaryResult.numericOutputActive,
    aggregateScoreOutputActive: summaryResult.aggregateScoreOutputActive,
    moveRankingOutputActive: summaryResult.moveRankingOutputActive,
    quietPreparatoryScopeActivated:
        summaryResult.quietPreparatoryScopeActivated,
    engineCallsActive: summaryResult.engineCallsActive,
    persistenceWritesActive: summaryResult.persistenceWritesActive,
    uiTargetsActive: summaryResult.uiTargetsActive,
    backendOutputActive: summaryResult.backendOutputActive,
    stockfishCommandFieldActive: summaryResult.stockfishCommandFieldActive,
    rawUciFieldActive: summaryResult.rawUciFieldActive,
    pvDumpFieldActive: summaryResult.pvDumpFieldActive,
  );
  final status = _validationStatusFor(base, summaryResult: summaryResult);
  final safeForPhase32Y =
      (status ==
              DebugBridgeReadinessSummaryValidationStatus
                  .validatedWithWarnings ||
          status ==
              DebugBridgeReadinessSummaryValidationStatus.validatedClean) &&
      summaryResult.safeForPhase32X &&
      !summaryResult.isStrictlyBlocked &&
      !summaryResult.hasUnsafeDebugBridgeReadinessSummaryPolicyViolation &&
      unsafeRecordCount == 0 &&
      blockerCount == 0 &&
      criticalCount == 0 &&
      checks.every((check) => !check.isBlocking) &&
      validationFindings.every((finding) => !finding.blocksStrict) &&
      groupRows.every((row) => row.safeForNextPhase) &&
      recordRows.every(
        (row) =>
            !row.hasUnsafeOutput &&
            row.validationStatus !=
                DebugBridgeReadinessSummaryRecordValidationStatus
                    .invalidSummaryRecord,
      );
  return base.copyWith(
    validationStatus: status,
    safeForPhase32Y: safeForPhase32Y,
    phase32YRecommendation: _phase32YRecommendationFor(
      status: status,
      safeForPhase32Y: safeForPhase32Y,
      ownerProofQueueCount: summaryResult.ownerProofQueueCount,
    ),
  );
}

DebugBridgeReadinessSummaryValidationStatus _validationStatusFor(
  DebugBridgeReadinessSummaryValidationResult result, {
  required DebugBridgeReadinessSummaryResult summaryResult,
}) {
  if (result.debugBridgeRuntimeImplemented ||
      result.debugBridgePrototypeImplemented ||
      result.productOutputActive ||
      result.classifierOutputActive ||
      result.finalMoveLabelOutputActive ||
      result.officialMetricOutputActive ||
      result.cpLossOutputActive ||
      result.winProbabilityOutputActive ||
      result.numericOutputActive ||
      result.aggregateScoreOutputActive ||
      result.moveRankingOutputActive ||
      result.quietPreparatoryScopeActivated ||
      result.engineCallsActive ||
      result.persistenceWritesActive ||
      result.uiTargetsActive ||
      result.backendOutputActive ||
      result.stockfishCommandFieldActive ||
      result.rawUciFieldActive ||
      result.pvDumpFieldActive ||
      result.allowedFieldIds.any(_isBlockedBridgeFieldId) ||
      result.allowedFieldIds.any(_isLegacyBlockedOutputFieldId)) {
    return DebugBridgeReadinessSummaryValidationStatus.blockedByPolicyBoundary;
  }
  if (summaryResult.summaryStatus ==
          DebugBridgeReadinessSummaryStatus.blockedByUnsafeReadiness ||
      summaryResult.summaryStatus ==
          DebugBridgeReadinessSummaryStatus.blockedByPolicyBoundary ||
      summaryResult.unsafeCount > 0 ||
      summaryResult.criticalCount > 0 ||
      summaryResult.hasUnsafeDebugBridgeReadinessSummaryPolicyViolation ||
      result.unsafeRecordCount > 0 ||
      result.criticalCount > 0) {
    return DebugBridgeReadinessSummaryValidationStatus.blockedByUnsafeSummary;
  }
  if (result.validationChecks.any(
        (check) =>
            check.checkStatus ==
            DebugBridgeReadinessSummaryValidationCheckStatus.failed,
      ) ||
      result.invalidRecordCount > 0) {
    return DebugBridgeReadinessSummaryValidationStatus.blockedBySummaryMismatch;
  }
  if (!summaryResult.safeForPhase32X ||
      summaryResult.isStrictlyBlocked ||
      result.blockerCount > 0 ||
      result.validationFindings.any((finding) => finding.blocksStrict) ||
      result.groupRows.any((row) => !row.safeForNextPhase) ||
      result.recordRows.any((row) => !row.safeForNextPhase)) {
    return DebugBridgeReadinessSummaryValidationStatus.invalid;
  }
  if (result.validationChecks.isEmpty ||
      result.groupRows.isEmpty ||
      result.recordRows.isEmpty) {
    return DebugBridgeReadinessSummaryValidationStatus.invalid;
  }
  if (result.warningCheckCount > 0 || result.warnings.isNotEmpty) {
    return DebugBridgeReadinessSummaryValidationStatus.validatedWithWarnings;
  }
  return DebugBridgeReadinessSummaryValidationStatus.validatedClean;
}

DebugBridgeReadinessSummaryValidationPhase32YRecommendation
_phase32YRecommendationFor({
  required DebugBridgeReadinessSummaryValidationStatus status,
  required bool safeForPhase32Y,
  required int ownerProofQueueCount,
}) {
  if (status ==
          DebugBridgeReadinessSummaryValidationStatus.blockedByUnsafeSummary ||
      status ==
          DebugBridgeReadinessSummaryValidationStatus.blockedByPolicyBoundary) {
    return DebugBridgeReadinessSummaryValidationPhase32YRecommendation
        .blockedByUnsafeBridgeSummaryValidation;
  }
  if (ownerProofQueueCount > 0) {
    return DebugBridgeReadinessSummaryValidationPhase32YRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase32Y) {
    return DebugBridgeReadinessSummaryValidationPhase32YRecommendation
        .addMoreGoldenCoverageFirst;
  }
  return DebugBridgeReadinessSummaryValidationPhase32YRecommendation
      .proceedToDebugBridgeReadinessValidationGate;
}

void _checkSafetyFlags(
  void Function({
    required String id,
    required DebugBridgeReadinessSummaryValidationSeverity severity,
    required String message,
    String? validationRowId,
    String? summaryRecordId,
    DebugBridgeReadinessSummaryGroupId? summaryGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugBridgeReadinessSummaryRecordValidationRow row,
) {
  void critical(String id, String message) {
    add(
      id: id,
      severity: DebugBridgeReadinessSummaryValidationSeverity.critical,
      message: message,
      validationRowId: row.validationRowId,
      summaryRecordId: row.sourceSummaryRecordId,
    );
  }

  if (row.safetyFlags['isProductOutput'] == true) {
    critical(
      'productOutputActive',
      'summary validation cannot be product output',
    );
  }
  if (row.safetyFlags['isClassifierLabel'] == true) {
    critical(
      'classifierLabelOutputActive',
      'summary validation cannot emit classifier labels',
    );
  }
  if (row.safetyFlags['hasNumericScore'] == true) {
    critical(
      'numericScoreOutputActive',
      'summary validation cannot emit numeric scores',
    );
  }
  if (row.safetyFlags['hasAggregateScore'] == true) {
    critical(
      'aggregateScoreOutputActive',
      'summary validation cannot emit aggregate scores',
    );
  }
  if (row.safetyFlags['ranksMoves'] == true) {
    critical('moveRankingOutputActive', 'summary validation cannot rank moves');
  }
  if (row.safetyFlags['isOfficialMetric'] == true) {
    critical(
      'officialMetricOutputActive',
      'summary validation cannot emit official metrics',
    );
  }
  if (row.safetyFlags['exposesCpLoss'] == true ||
      row.safetyFlags['exposesWinProbability'] == true) {
    critical(
      'futureMetricOutputActive',
      'summary validation cannot expose CP-loss or win probability',
    );
  }
  if (row.safetyFlags['quietPreparatoryScopeActive'] == true) {
    critical(
      'quietPreparatoryScopeActivated',
      'quiet/preparatory scope must remain excluded',
    );
  }
  if (row.safetyFlags['callsEngine'] == true) {
    critical(
      'engineCallFlagActive',
      'summary validation cannot call an engine',
    );
  }
  if (row.safetyFlags['writesPersistence'] == true) {
    critical(
      'persistenceWriteFlagActive',
      'summary validation cannot write persistence',
    );
  }
  if (row.safetyFlags['targetsUi'] == true) {
    critical('uiTargetFlagActive', 'summary validation cannot target UI');
  }
  if (row.safetyFlags['backendOutputActive'] == true) {
    critical('backendOutputActive', 'summary validation cannot target backend');
  }
  if (row.safetyFlags['exposesStockfishCommand'] == true ||
      row.safetyFlags['exposesRawUci'] == true ||
      row.safetyFlags['exposesPvDump'] == true) {
    critical(
      'stockfishRawUciPvDumpFieldActive',
      'Stockfish command, raw UCI, and PV dump fields must remain blocked',
    );
  }
}

void _checkActiveBridgeField(
  void Function({
    required String id,
    required DebugBridgeReadinessSummaryValidationSeverity severity,
    required String message,
    String? validationRowId,
    String? summaryRecordId,
    DebugBridgeReadinessSummaryGroupId? summaryGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String fieldId, {
  String? validationRowId,
  String? summaryRecordId,
  DebugBridgeReadinessSummaryGroupId? summaryGroupId,
}) {
  if (_isBlockedBridgeFieldId(fieldId) ||
      _isLegacyBlockedOutputFieldId(fieldId)) {
    add(
      id: 'activeDeniedBridgeField',
      severity: DebugBridgeReadinessSummaryValidationSeverity.critical,
      message: '$fieldId cannot be active bridge summary validation output',
      validationRowId: validationRowId,
      summaryRecordId: summaryRecordId,
      summaryGroupId: summaryGroupId,
      fieldId: fieldId,
    );
  }
}

void _checkAndroidProofCase(
  void Function({
    required String id,
    required DebugBridgeReadinessSummaryValidationSeverity severity,
    required String message,
    String? validationRowId,
    String? summaryRecordId,
    DebugBridgeReadinessSummaryGroupId? summaryGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String caseId,
  List<String> provenAndroidIds, {
  String? validationRowId,
  String? summaryRecordId,
  DebugBridgeReadinessSummaryGroupId? summaryGroupId,
}) {
  if (_phase32ECaseIds.contains(caseId)) {
    add(
      id: 'phase32ECaseTreatedAsCapturedProof',
      severity: DebugBridgeReadinessSummaryValidationSeverity.critical,
      message: '$caseId cannot be treated as captured Android proof',
      validationRowId: validationRowId,
      summaryRecordId: summaryRecordId,
      summaryGroupId: summaryGroupId,
      caseId: caseId,
    );
    return;
  }
  if (!_capturedAndroidProofIds.contains(caseId) ||
      !provenAndroidIds.contains(caseId)) {
    add(
      id: 'unprovenAndroidProofId',
      severity: DebugBridgeReadinessSummaryValidationSeverity.critical,
      message: '$caseId is not captured Android proof',
      validationRowId: validationRowId,
      summaryRecordId: summaryRecordId,
      summaryGroupId: summaryGroupId,
      caseId: caseId,
    );
  }
}

bool _recordIsInactiveSafe(DebugBridgeReadinessSummaryRecordValidationRow row) {
  return row.inactive &&
      row.validationStatus.isInactiveBoundary &&
      row.activeFieldIds.isEmpty &&
      !row.hasUnsafeOutput;
}

bool _hasExplicitPvProofReason(
  DebugBridgeReadinessSummaryValidationResult result,
) {
  final reasons = <String>[
    ...result.warnings,
    ...result.failures,
    ...result.validationChecks.map((check) => check.warningReason),
  ].join(' ').toLowerCase();
  return reasons.contains('pv') || reasons.contains('multipv');
}

Map<String, bool> _safeFlagsFrom(Map<String, bool> source) {
  return <String, bool>{
    'isProductOutput': source['isProductOutput'] ?? false,
    'isClassifierLabel': source['isClassifierLabel'] ?? false,
    'hasNumericScore': source['hasNumericScore'] ?? false,
    'hasAggregateScore': source['hasAggregateScore'] ?? false,
    'ranksMoves': source['ranksMoves'] ?? false,
    'isOfficialMetric': source['isOfficialMetric'] ?? false,
    'exposesCpLoss': source['exposesCpLoss'] ?? false,
    'exposesWinProbability': source['exposesWinProbability'] ?? false,
    'exposesStockfishCommand': source['exposesStockfishCommand'] ?? false,
    'exposesRawUci': source['exposesRawUci'] ?? false,
    'exposesPvDump': source['exposesPvDump'] ?? false,
    'callsEngine': source['callsEngine'] ?? false,
    'writesPersistence': source['writesPersistence'] ?? false,
    'targetsUi': source['targetsUi'] ?? false,
    'backendOutputActive': source['backendOutputActive'] ?? false,
    'quietPreparatoryScopeActive':
        source['quietPreparatoryScopeActive'] ?? false,
  };
}

int _countRecordRows(
  List<DebugBridgeReadinessSummaryRecordValidationRow> rows,
  DebugBridgeReadinessSummaryRecordValidationStatus status,
) {
  return rows.where((row) => row.validationStatus == status).length;
}

List<String> _provenAndroidProofIds(GoldenAndroidProofEvidence? evidence) {
  return _sortedStrings(evidence?.targetCaseIds ?? const <String>[]);
}

int _compareFindings(
  DebugBridgeReadinessSummaryValidationFinding a,
  DebugBridgeReadinessSummaryValidationFinding b,
) {
  final severity = _severityRank(
    b.severity,
  ).compareTo(_severityRank(a.severity));
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.summaryRecordId ?? '').compareTo(b.summaryRecordId ?? '');
}

int _severityRank(DebugBridgeReadinessSummaryValidationSeverity severity) {
  return switch (severity) {
    DebugBridgeReadinessSummaryValidationSeverity.none => 0,
    DebugBridgeReadinessSummaryValidationSeverity.info => 1,
    DebugBridgeReadinessSummaryValidationSeverity.warning => 2,
    DebugBridgeReadinessSummaryValidationSeverity.blocker => 3,
    DebugBridgeReadinessSummaryValidationSeverity.critical => 4,
  };
}

bool _isBlockedBridgeFieldId(String value) {
  return _blockedBridgeFieldIds.contains(value);
}

bool _isLegacyBlockedOutputFieldId(String value) {
  return _legacyBlockedOutputFieldIds.contains(value);
}

bool _sameStringSet(Iterable<String> left, Iterable<String> right) {
  final leftSet = left.toSet();
  final rightSet = right.toSet();
  return leftSet.length == rightSet.length && leftSet.every(rightSet.contains);
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.where((value) => value.trim().isNotEmpty).toSet().toList()
    ..sort();
}

String _ids(Iterable<String> values) {
  final sorted = _sortedStrings(values);
  return sorted.isEmpty ? 'none' : sorted.map(_cell).join(', ');
}

String _cell(String value) {
  if (value.isEmpty) return 'none';
  return value.replaceAll('|', '/').replaceAll('\n', ' ');
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

const _blockedBridgeFieldIds = <String>[
  'productLabel',
  'finalMoveLabel',
  'brilliantGreatMissStyleLabels',
  'bestGoodInaccuracyMistakeBlunderStyleLabels',
  'numericMoveScore',
  'aggregateScore',
  'officialAccuracy',
  'acpl',
  'cpLoss',
  'winProbability',
  'moveRanking',
  'uiOutput',
  'backendOutput',
  'persistenceOutput',
  'directEngineCall',
  'stockfishCommand',
  'rawUci',
  'pvDump',
];

const _engineDumpFieldIds = <String>['stockfishCommand', 'rawUci', 'pvDump'];

const _legacyBlockedOutputFieldIds = <String>[
  'uiOutputFields',
  'backendPersistenceFields',
  'directEngineCallFields',
];

/// Developer-only validation for the debug-only adapter bridge design.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_adapter_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/internal_adapter_readiness_summary_validation.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_readiness_gate.dart';

const debugOnlyAdapterBridgeDesignValidationReportVersion =
    'debug-only-adapter-bridge-design-validation-v1';

enum DebugOnlyAdapterBridgeDesignValidationStatus {
  validatedWithWarnings('validatedWithWarnings'),
  validatedClean('validatedClean'),
  blockedByUnsafeBridgeDesign('blockedByUnsafeBridgeDesign'),
  blockedByBridgeContractViolation('blockedByBridgeContractViolation'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const DebugOnlyAdapterBridgeDesignValidationStatus(this.wire);

  final String wire;
}

enum DebugOnlyAdapterBridgeDesignValidationCheckStatus {
  passed('passed'),
  passedWithWarnings('passedWithWarnings'),
  failed('failed'),
  blocked('blocked'),
  notApplicable('notApplicable');

  const DebugOnlyAdapterBridgeDesignValidationCheckStatus(this.wire);

  final String wire;

  bool get isBlocked =>
      this == DebugOnlyAdapterBridgeDesignValidationCheckStatus.failed ||
      this == DebugOnlyAdapterBridgeDesignValidationCheckStatus.blocked;
}

enum DebugOnlyAdapterBridgeDesignValidationSeverity {
  none('none'),
  info('info'),
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const DebugOnlyAdapterBridgeDesignValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == DebugOnlyAdapterBridgeDesignValidationSeverity.blocker ||
      this == DebugOnlyAdapterBridgeDesignValidationSeverity.critical;

  bool get isCritical =>
      this == DebugOnlyAdapterBridgeDesignValidationSeverity.critical;
}

enum DebugOnlyAdapterBridgeGroupValidationStatus {
  validDebugCoreInputGroup('validDebugCoreInputGroup'),
  validDebugContextInputGroup('validDebugContextInputGroup'),
  validDebugBlockedInputGroup('validDebugBlockedInputGroup'),
  validDebugFutureOnlyInputGroup('validDebugFutureOnlyInputGroup'),
  validDebugAllowedFieldGroup('validDebugAllowedFieldGroup'),
  validDebugBlockedFieldGroup('validDebugBlockedFieldGroup'),
  validDebugProofBoundaryGroup('validDebugProofBoundaryGroup'),
  validDebugOwnerProofStatusGroup('validDebugOwnerProofStatusGroup'),
  invalidBridgeGroup('invalidBridgeGroup'),
  unsafeBridgeGroup('unsafeBridgeGroup');

  const DebugOnlyAdapterBridgeGroupValidationStatus(this.wire);

  final String wire;

  bool get isUnsafe =>
      this == DebugOnlyAdapterBridgeGroupValidationStatus.unsafeBridgeGroup;

  bool get isInvalid =>
      this == DebugOnlyAdapterBridgeGroupValidationStatus.invalidBridgeGroup;
}

enum DebugOnlyAdapterBridgeRecordValidationStatus {
  validDebugCoreInput('validDebugCoreInput'),
  validDebugContextOnlyInput('validDebugContextOnlyInput'),
  validDebugBlockedInput('validDebugBlockedInput'),
  validDebugFutureOnlyInput('validDebugFutureOnlyInput'),
  validDebugAllowedField('validDebugAllowedField'),
  validDebugBlockedField('validDebugBlockedField'),
  validDebugProofBoundary('validDebugProofBoundary'),
  validDebugOwnerProofStatus('validDebugOwnerProofStatus'),
  invalidBridgeRecord('invalidBridgeRecord'),
  unsafeBridgeRecord('unsafeBridgeRecord');

  const DebugOnlyAdapterBridgeRecordValidationStatus(this.wire);

  final String wire;

  bool get isUnsafe =>
      this == DebugOnlyAdapterBridgeRecordValidationStatus.unsafeBridgeRecord;

  bool get isInvalid =>
      this == DebugOnlyAdapterBridgeRecordValidationStatus.invalidBridgeRecord;
}

enum DebugOnlyAdapterBridgeDesignValidationRecommendation {
  keepDebugCoreInputsValidated('keepDebugCoreInputsValidated'),
  keepDebugContextInputsContextOnly('keepDebugContextInputsContextOnly'),
  keepDebugBlockedInputsInactive('keepDebugBlockedInputsInactive'),
  keepDebugFutureOnlyInputsInactive('keepDebugFutureOnlyInputsInactive'),
  keepAllowedBridgeFieldsSafe('keepAllowedBridgeFieldsSafe'),
  keepBlockedBridgeFieldsDenied('keepBlockedBridgeFieldsDenied'),
  keepProofBoundaryCaptured('keepProofBoundaryCaptured'),
  keepOwnerProofEmpty('keepOwnerProofEmpty'),
  investigateBridgeValidationFailure('investigateBridgeValidationFailure'),
  blockUnsafeBridgeValidation('blockUnsafeBridgeValidation');

  const DebugOnlyAdapterBridgeDesignValidationRecommendation(this.wire);

  final String wire;
}

enum DebugOnlyAdapterBridgeDesignValidationPhase32VRecommendation {
  proceedToDebugOnlyAdapterBridgePrototype(
    'proceedToDebugOnlyAdapterBridgePrototype',
  ),
  proceedToDebugBridgeDesignReadinessGate(
    'proceedToDebugBridgeDesignReadinessGate',
  ),
  proceedToDebugBridgeValidationSummary(
    'proceedToDebugBridgeValidationSummary',
  ),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeBridgeValidation('blockedByUnsafeBridgeValidation');

  const DebugOnlyAdapterBridgeDesignValidationPhase32VRecommendation(this.wire);

  final String wire;
}

enum DebugOnlyAdapterBridgeDesignValidationReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyAdapterBridgeDesignValidationReportFormat(this.wire);

  final String wire;
}

class DebugOnlyAdapterBridgeDesignValidationRequest {
  const DebugOnlyAdapterBridgeDesignValidationRequest({
    this.designResult,
    this.summaryValidationResult,
    this.summaryResult,
    this.readinessGateResult,
    this.design = const DebugOnlyAdapterBridgeDesign(),
    this.summaryValidation = const InternalAdapterReadinessSummaryValidation(),
    this.summary = const InternalAdapterReadinessSummary(),
    this.readinessGate = const InternalEvidenceAdapterPrototypeReadinessGate(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const DebugOnlyAdapterBridgeDesignValidationRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final DebugOnlyAdapterBridgeDesignResult? designResult;
  final InternalAdapterReadinessSummaryValidationResult?
  summaryValidationResult;
  final InternalAdapterReadinessSummaryResult? summaryResult;
  final InternalEvidenceAdapterPrototypeReadinessGateResult?
  readinessGateResult;
  final DebugOnlyAdapterBridgeDesign design;
  final InternalAdapterReadinessSummaryValidation summaryValidation;
  final InternalAdapterReadinessSummary summary;
  final InternalEvidenceAdapterPrototypeReadinessGate readinessGate;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class DebugOnlyAdapterBridgeDesignValidationCheck {
  const DebugOnlyAdapterBridgeDesignValidationCheck({
    required this.checkId,
    required this.checkStatus,
    required this.severity,
    required this.relatedBridgeRecordIds,
    required this.relatedGroupIds,
    required this.relatedFieldIds,
    required this.relatedProofIds,
    required this.warningReason,
    required this.failureReason,
    required this.recommendation,
  });

  final String checkId;
  final DebugOnlyAdapterBridgeDesignValidationCheckStatus checkStatus;
  final DebugOnlyAdapterBridgeDesignValidationSeverity severity;
  final List<String> relatedBridgeRecordIds;
  final List<String> relatedGroupIds;
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
      'relatedBridgeRecordIds': relatedBridgeRecordIds,
      'relatedGroupIds': relatedGroupIds,
      'relatedFieldIds': relatedFieldIds,
      'relatedProofIds': relatedProofIds,
      'warningReason': warningReason,
      'failureReason': failureReason,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyAdapterBridgeGroupValidationRow {
  const DebugOnlyAdapterBridgeGroupValidationRow({
    required this.validationRowId,
    required this.sourceBridgeGroupId,
    required this.groupKind,
    required this.validationStatus,
    required this.bridgeRecordIds,
    required this.activeFieldIds,
    required this.blockedFieldIds,
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
  final DebugOnlyAdapterBridgeInputGroupId sourceBridgeGroupId;
  final DebugOnlyAdapterBridgeGroupValidationStatus groupKind;
  final DebugOnlyAdapterBridgeGroupValidationStatus validationStatus;
  final List<String> bridgeRecordIds;
  final List<String> activeFieldIds;
  final List<String> blockedFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final int ownerProofQueueCount;
  final String validationReason;
  final String warningReason;
  final List<String> violationReasons;
  final bool safeForNextPhase;
  final DebugOnlyAdapterBridgeDesignValidationRecommendation recommendation;

  bool get hasUnsafeOutput =>
      validationStatus.isUnsafe ||
      activeFieldIds.any(_isBlockedBridgeFieldId) ||
      activeFieldIds.any(_isLegacyBlockedOutputFieldId);

  DebugOnlyAdapterBridgeGroupValidationRow copyWith({
    String? validationRowId,
    DebugOnlyAdapterBridgeInputGroupId? sourceBridgeGroupId,
    DebugOnlyAdapterBridgeGroupValidationStatus? groupKind,
    DebugOnlyAdapterBridgeGroupValidationStatus? validationStatus,
    List<String>? bridgeRecordIds,
    List<String>? activeFieldIds,
    List<String>? blockedFieldIds,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    int? ownerProofQueueCount,
    String? validationReason,
    String? warningReason,
    List<String>? violationReasons,
    bool? safeForNextPhase,
    DebugOnlyAdapterBridgeDesignValidationRecommendation? recommendation,
  }) {
    return DebugOnlyAdapterBridgeGroupValidationRow(
      validationRowId: validationRowId ?? this.validationRowId,
      sourceBridgeGroupId: sourceBridgeGroupId ?? this.sourceBridgeGroupId,
      groupKind: groupKind ?? this.groupKind,
      validationStatus: validationStatus ?? this.validationStatus,
      bridgeRecordIds: bridgeRecordIds ?? this.bridgeRecordIds,
      activeFieldIds: activeFieldIds ?? this.activeFieldIds,
      blockedFieldIds: blockedFieldIds ?? this.blockedFieldIds,
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
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'validationRowId': validationRowId,
      'sourceBridgeGroupId': sourceBridgeGroupId.wire,
      'groupKind': groupKind.wire,
      'validationStatus': validationStatus.wire,
      'bridgeRecordIds': bridgeRecordIds,
      'activeFieldIds': activeFieldIds,
      'blockedFieldIds': blockedFieldIds,
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

class DebugOnlyAdapterBridgeRecordValidationRow {
  const DebugOnlyAdapterBridgeRecordValidationRow({
    required this.validationRowId,
    required this.sourceBridgeRecordId,
    required this.bridgeRole,
    required this.designStatus,
    required this.validationStatus,
    required this.allowedForFutureDebugBridge,
    required this.contextOnly,
    required this.inactive,
    required this.activeFieldIds,
    required this.blockedFieldIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.safetyFlags,
    required this.violationReasons,
    required this.safeForNextPhase,
    required this.recommendation,
  });

  final String validationRowId;
  final String sourceBridgeRecordId;
  final DebugOnlyAdapterBridgeRole bridgeRole;
  final DebugOnlyAdapterBridgeRecordDesignStatus designStatus;
  final DebugOnlyAdapterBridgeRecordValidationStatus validationStatus;
  final bool allowedForFutureDebugBridge;
  final bool contextOnly;
  final bool inactive;
  final List<String> activeFieldIds;
  final List<String> blockedFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final Map<String, bool> safetyFlags;
  final List<String> violationReasons;
  final bool safeForNextPhase;
  final DebugOnlyAdapterBridgeDesignValidationRecommendation recommendation;

  bool get hasUnsafeOutput =>
      validationStatus.isUnsafe ||
      activeFieldIds.any(_isBlockedBridgeFieldId) ||
      activeFieldIds.any(_isLegacyBlockedOutputFieldId) ||
      safetyFlags.values.any((value) => value);

  DebugOnlyAdapterBridgeRecordValidationRow copyWith({
    String? validationRowId,
    String? sourceBridgeRecordId,
    DebugOnlyAdapterBridgeRole? bridgeRole,
    DebugOnlyAdapterBridgeRecordDesignStatus? designStatus,
    DebugOnlyAdapterBridgeRecordValidationStatus? validationStatus,
    bool? allowedForFutureDebugBridge,
    bool? contextOnly,
    bool? inactive,
    List<String>? activeFieldIds,
    List<String>? blockedFieldIds,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    Map<String, bool>? safetyFlags,
    List<String>? violationReasons,
    bool? safeForNextPhase,
    DebugOnlyAdapterBridgeDesignValidationRecommendation? recommendation,
  }) {
    return DebugOnlyAdapterBridgeRecordValidationRow(
      validationRowId: validationRowId ?? this.validationRowId,
      sourceBridgeRecordId: sourceBridgeRecordId ?? this.sourceBridgeRecordId,
      bridgeRole: bridgeRole ?? this.bridgeRole,
      designStatus: designStatus ?? this.designStatus,
      validationStatus: validationStatus ?? this.validationStatus,
      allowedForFutureDebugBridge:
          allowedForFutureDebugBridge ?? this.allowedForFutureDebugBridge,
      contextOnly: contextOnly ?? this.contextOnly,
      inactive: inactive ?? this.inactive,
      activeFieldIds: activeFieldIds ?? this.activeFieldIds,
      blockedFieldIds: blockedFieldIds ?? this.blockedFieldIds,
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
      'sourceBridgeRecordId': sourceBridgeRecordId,
      'bridgeRole': bridgeRole.wire,
      'designStatus': designStatus.wire,
      'validationStatus': validationStatus.wire,
      'allowedForFutureDebugBridge': allowedForFutureDebugBridge,
      'contextOnly': contextOnly,
      'inactive': inactive,
      'activeFieldIds': activeFieldIds,
      'blockedFieldIds': blockedFieldIds,
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

class DebugOnlyAdapterBridgeDesignValidationFinding {
  const DebugOnlyAdapterBridgeDesignValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.validationRowId,
    this.bridgeRecordId,
    this.bridgeGroupId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final DebugOnlyAdapterBridgeDesignValidationSeverity severity;
  final String message;
  final String? validationRowId;
  final String? bridgeRecordId;
  final DebugOnlyAdapterBridgeInputGroupId? bridgeGroupId;
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
      if (bridgeRecordId != null) 'bridgeRecordId': bridgeRecordId,
      if (bridgeGroupId != null) 'bridgeGroupId': bridgeGroupId!.wire,
      if (fieldId != null) 'fieldId': fieldId,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class DebugOnlyAdapterBridgeDesignValidationResult {
  const DebugOnlyAdapterBridgeDesignValidationResult({
    required this.validationStatus,
    required this.sourceBridgeDesignStatus,
    required this.sourceSummaryValidationStatus,
    required this.sourceSummaryStatus,
    required this.sourceReadinessGateStatus,
    required this.checks,
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
    required this.validDebugCoreInputCount,
    required this.validDebugContextInputCount,
    required this.validInactiveBlockedInputCount,
    required this.validInactiveFutureOnlyInputCount,
    required this.validAllowedFieldGroupCount,
    required this.validBlockedFieldGroupCount,
    required this.validProofBoundaryCount,
    required this.validOwnerProofStatusCount,
    required this.invalidRecordCount,
    required this.unsafeRecordCount,
    required this.ownerProofQueueCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.allowedFieldIds,
    required this.blockedFieldIds,
    required this.safeForPhase32V,
    required this.phase32VRecommendation,
    this.developerOnly = true,
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

  final DebugOnlyAdapterBridgeDesignValidationStatus validationStatus;
  final DebugOnlyAdapterBridgeDesignStatus sourceBridgeDesignStatus;
  final InternalAdapterReadinessSummaryValidationStatus
  sourceSummaryValidationStatus;
  final InternalAdapterReadinessSummaryStatus sourceSummaryStatus;
  final InternalEvidenceAdapterPrototypeReadinessGateStatus
  sourceReadinessGateStatus;
  final List<DebugOnlyAdapterBridgeDesignValidationCheck> checks;
  final List<DebugOnlyAdapterBridgeGroupValidationRow> groupRows;
  final List<DebugOnlyAdapterBridgeRecordValidationRow> recordRows;
  final List<DebugOnlyAdapterBridgeDesignValidationFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalChecks;
  final int passedCheckCount;
  final int warningCheckCount;
  final int blockerCount;
  final int criticalCount;
  final int totalGroupRows;
  final int totalRecordRows;
  final int validDebugCoreInputCount;
  final int validDebugContextInputCount;
  final int validInactiveBlockedInputCount;
  final int validInactiveFutureOnlyInputCount;
  final int validAllowedFieldGroupCount;
  final int validBlockedFieldGroupCount;
  final int validProofBoundaryCount;
  final int validOwnerProofStatusCount;
  final int invalidRecordCount;
  final int unsafeRecordCount;
  final int ownerProofQueueCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> allowedFieldIds;
  final List<String> blockedFieldIds;
  final bool safeForPhase32V;
  final DebugOnlyAdapterBridgeDesignValidationPhase32VRecommendation
  phase32VRecommendation;
  final bool developerOnly;
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
          DebugOnlyAdapterBridgeDesignValidationStatus
              .blockedByUnsafeBridgeDesign ||
      validationStatus ==
          DebugOnlyAdapterBridgeDesignValidationStatus
              .blockedByBridgeContractViolation ||
      validationStatus ==
          DebugOnlyAdapterBridgeDesignValidationStatus
              .blockedByPolicyBoundary ||
      validationStatus ==
          DebugOnlyAdapterBridgeDesignValidationStatus.invalid ||
      !safeForPhase32V ||
      unsafeRecordCount > 0 ||
      criticalCount > 0 ||
      blockerCount > 0 ||
      checks.any((check) => check.blocksStrict) ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeDebugBridgeDesignValidationPolicyViolation {
    return validationStatus ==
            DebugOnlyAdapterBridgeDesignValidationStatus
                .blockedByUnsafeBridgeDesign ||
        validationStatus ==
            DebugOnlyAdapterBridgeDesignValidationStatus
                .blockedByPolicyBoundary ||
        unsafeRecordCount > 0 ||
        criticalCount > 0 ||
        groupRows.any((row) => row.hasUnsafeOutput) ||
        recordRows.any((row) => row.hasUnsafeOutput) ||
        validationFindings.any((finding) => finding.isCritical) ||
        allowedFieldIds.any(_isBlockedBridgeFieldId) ||
        allowedFieldIds.any(_isLegacyBlockedOutputFieldId) ||
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

  DebugOnlyAdapterBridgeDesignValidationCheck check(String checkId) {
    return checks.singleWhere((check) => check.checkId == checkId);
  }

  DebugOnlyAdapterBridgeGroupValidationRow groupRowForGroup(
    DebugOnlyAdapterBridgeInputGroupId groupId,
  ) {
    return groupRows.singleWhere((row) => row.sourceBridgeGroupId == groupId);
  }

  DebugOnlyAdapterBridgeRecordValidationRow recordRowForRole(
    DebugOnlyAdapterBridgeRole bridgeRole,
  ) {
    return recordRows.singleWhere((row) => row.bridgeRole == bridgeRole);
  }

  List<DebugOnlyAdapterBridgeRecordValidationRow> get debugCoreValidationRows =>
      recordRows
          .where(
            (row) =>
                row.bridgeRole == DebugOnlyAdapterBridgeRole.debugCoreInput,
          )
          .toList(growable: false);

  List<DebugOnlyAdapterBridgeRecordValidationRow>
  get debugContextValidationRows => recordRows
      .where(
        (row) =>
            row.bridgeRole == DebugOnlyAdapterBridgeRole.debugContextOnlyInput,
      )
      .toList(growable: false);

  List<DebugOnlyAdapterBridgeRecordValidationRow>
  get inactiveBoundaryValidationRows => recordRows
      .where((row) => row.bridgeRole.isInactiveBoundary)
      .toList(growable: false);

  DebugOnlyAdapterBridgeDesignValidationResult copyWith({
    DebugOnlyAdapterBridgeDesignValidationStatus? validationStatus,
    DebugOnlyAdapterBridgeDesignStatus? sourceBridgeDesignStatus,
    InternalAdapterReadinessSummaryValidationStatus?
    sourceSummaryValidationStatus,
    InternalAdapterReadinessSummaryStatus? sourceSummaryStatus,
    InternalEvidenceAdapterPrototypeReadinessGateStatus?
    sourceReadinessGateStatus,
    List<DebugOnlyAdapterBridgeDesignValidationCheck>? checks,
    List<DebugOnlyAdapterBridgeGroupValidationRow>? groupRows,
    List<DebugOnlyAdapterBridgeRecordValidationRow>? recordRows,
    List<DebugOnlyAdapterBridgeDesignValidationFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalChecks,
    int? passedCheckCount,
    int? warningCheckCount,
    int? blockerCount,
    int? criticalCount,
    int? totalGroupRows,
    int? totalRecordRows,
    int? validDebugCoreInputCount,
    int? validDebugContextInputCount,
    int? validInactiveBlockedInputCount,
    int? validInactiveFutureOnlyInputCount,
    int? validAllowedFieldGroupCount,
    int? validBlockedFieldGroupCount,
    int? validProofBoundaryCount,
    int? validOwnerProofStatusCount,
    int? invalidRecordCount,
    int? unsafeRecordCount,
    int? ownerProofQueueCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? allowedFieldIds,
    List<String>? blockedFieldIds,
    bool? safeForPhase32V,
    DebugOnlyAdapterBridgeDesignValidationPhase32VRecommendation?
    phase32VRecommendation,
    bool? developerOnly,
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
    return DebugOnlyAdapterBridgeDesignValidationResult(
      validationStatus: validationStatus ?? this.validationStatus,
      sourceBridgeDesignStatus:
          sourceBridgeDesignStatus ?? this.sourceBridgeDesignStatus,
      sourceSummaryValidationStatus:
          sourceSummaryValidationStatus ?? this.sourceSummaryValidationStatus,
      sourceSummaryStatus: sourceSummaryStatus ?? this.sourceSummaryStatus,
      sourceReadinessGateStatus:
          sourceReadinessGateStatus ?? this.sourceReadinessGateStatus,
      checks: checks ?? this.checks,
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
      validDebugCoreInputCount:
          validDebugCoreInputCount ?? this.validDebugCoreInputCount,
      validDebugContextInputCount:
          validDebugContextInputCount ?? this.validDebugContextInputCount,
      validInactiveBlockedInputCount:
          validInactiveBlockedInputCount ?? this.validInactiveBlockedInputCount,
      validInactiveFutureOnlyInputCount:
          validInactiveFutureOnlyInputCount ??
          this.validInactiveFutureOnlyInputCount,
      validAllowedFieldGroupCount:
          validAllowedFieldGroupCount ?? this.validAllowedFieldGroupCount,
      validBlockedFieldGroupCount:
          validBlockedFieldGroupCount ?? this.validBlockedFieldGroupCount,
      validProofBoundaryCount:
          validProofBoundaryCount ?? this.validProofBoundaryCount,
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
      blockedFieldIds: blockedFieldIds ?? this.blockedFieldIds,
      safeForPhase32V: safeForPhase32V ?? this.safeForPhase32V,
      phase32VRecommendation:
          phase32VRecommendation ?? this.phase32VRecommendation,
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
      ..writeln('# Debug-Only Adapter Bridge Design Validation')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyAdapterBridgeDesignValidationReportVersion',
      )
      ..writeln('- validation status: ${validationStatus.wire}')
      ..writeln(
        '- source bridge design status: ${sourceBridgeDesignStatus.wire}',
      )
      ..writeln(
        '- source summary validation status: ${sourceSummaryValidationStatus.wire}',
      )
      ..writeln('- source summary status: ${sourceSummaryStatus.wire}')
      ..writeln(
        '- source readiness gate status: ${sourceReadinessGateStatus.wire}',
      )
      ..writeln('- total checks: $totalChecks')
      ..writeln('- passed check count: $passedCheckCount')
      ..writeln('- warning check count: $warningCheckCount')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- total group rows: $totalGroupRows')
      ..writeln('- total record rows: $totalRecordRows')
      ..writeln('- unsafe record count: $unsafeRecordCount')
      ..writeln('- invalid record count: $invalidRecordCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- safeForPhase32V: $safeForPhase32V')
      ..writeln('- Phase 32V recommendation: ${phase32VRecommendation.wire}')
      ..writeln()
      ..writeln('## Validation Check Table')
      ..writeln(
        '| Check | Status | Severity | Related records | Related fields | Related proof |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- |');
    for (final check in checks) {
      buffer.writeln(
        '| ${_cell(check.checkId)} | ${check.checkStatus.wire} | ${check.severity.wire} | ${_ids(check.relatedBridgeRecordIds)} | ${_ids(check.relatedFieldIds)} | ${_ids(check.relatedProofIds)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Bridge Group Validation Table')
      ..writeln(
        '| Group | Status | Records | Active fields | Blocked fields | Safe | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
    for (final row in groupRows) {
      buffer.writeln(
        '| ${row.sourceBridgeGroupId.wire} | ${row.validationStatus.wire} | ${_ids(row.bridgeRecordIds)} | ${_ids(row.activeFieldIds)} | ${_ids(row.blockedFieldIds)} | ${row.safeForNextPhase} | ${row.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Bridge Record Validation Table')
      ..writeln(
        '| Record | Role | Status | Active fields | Blocked fields | Safe | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
    for (final row in recordRows) {
      buffer.writeln(
        '| ${_cell(row.sourceBridgeRecordId)} | ${row.bridgeRole.wire} | ${row.validationStatus.wire} | ${_ids(row.activeFieldIds)} | ${_ids(row.blockedFieldIds)} | ${row.safeForNextPhase} | ${row.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Debug Core Validation');
    for (final row in debugCoreValidationRows) {
      buffer.writeln(
        '- ${row.sourceBridgeRecordId}: ${row.validationStatus.wire}; active fields: ${_ids(row.activeFieldIds)}',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Debug Context-Only Validation');
    for (final row in debugContextValidationRows) {
      buffer.writeln(
        '- ${row.sourceBridgeRecordId}: ${row.validationStatus.wire}; contextOnly: ${row.contextOnly}',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Inactive Blocked/Future Validation');
    for (final row in inactiveBoundaryValidationRows) {
      buffer.writeln(
        '- ${row.sourceBridgeRecordId}: ${row.validationStatus.wire}; inactive: ${row.inactive}',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Allowed Bridge Field Validation')
      ..writeln('- allowed bridge fields: ${_ids(allowedFieldIds)}')
      ..writeln()
      ..writeln('## Blocked Bridge Field Validation')
      ..writeln('- blocked bridge fields: ${_ids(blockedFieldIds)}')
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
      ..writeln('## Phase 32V Recommendation')
      ..writeln('- ${phase32VRecommendation.wire}');
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': debugOnlyAdapterBridgeDesignValidationReportVersion,
      'validationStatus': validationStatus.wire,
      'sourceBridgeDesignStatus': sourceBridgeDesignStatus.wire,
      'sourceSummaryValidationStatus': sourceSummaryValidationStatus.wire,
      'sourceSummaryStatus': sourceSummaryStatus.wire,
      'sourceReadinessGateStatus': sourceReadinessGateStatus.wire,
      'totalChecks': totalChecks,
      'passedCheckCount': passedCheckCount,
      'warningCheckCount': warningCheckCount,
      'blockerCount': blockerCount,
      'criticalCount': criticalCount,
      'totalGroupRows': totalGroupRows,
      'totalRecordRows': totalRecordRows,
      'validDebugCoreInputCount': validDebugCoreInputCount,
      'validDebugContextInputCount': validDebugContextInputCount,
      'validInactiveBlockedInputCount': validInactiveBlockedInputCount,
      'validInactiveFutureOnlyInputCount': validInactiveFutureOnlyInputCount,
      'validAllowedFieldGroupCount': validAllowedFieldGroupCount,
      'validBlockedFieldGroupCount': validBlockedFieldGroupCount,
      'validProofBoundaryCount': validProofBoundaryCount,
      'validOwnerProofStatusCount': validOwnerProofStatusCount,
      'invalidRecordCount': invalidRecordCount,
      'unsafeRecordCount': unsafeRecordCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'allowedFieldIds': allowedFieldIds,
      'blockedFieldIds': blockedFieldIds,
      'safeForPhase32V': safeForPhase32V,
      'phase32VRecommendation': phase32VRecommendation.wire,
      'checks': checks.map((check) => check.toJson()).toList(),
      'groupRows': groupRows.map((row) => row.toJson()).toList(),
      'recordRows': recordRows.map((row) => row.toJson()).toList(),
      'findings': validationFindings
          .map((finding) => finding.toJson())
          .toList(),
      'warnings': warnings,
      'failures': failures,
      'developerOnly': developerOnly,
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

class DebugOnlyAdapterBridgeDesignValidation {
  const DebugOnlyAdapterBridgeDesignValidation({
    this.validator = const DebugOnlyAdapterBridgeDesignValidationValidator(),
  });

  final DebugOnlyAdapterBridgeDesignValidationValidator validator;

  DebugOnlyAdapterBridgeDesignValidationResult evaluate([
    DebugOnlyAdapterBridgeDesignValidationRequest request =
        const DebugOnlyAdapterBridgeDesignValidationRequest(),
  ]) {
    final readinessGateResult =
        request.readinessGateResult ??
        request.readinessGate.evaluate(
          InternalEvidenceAdapterPrototypeReadinessGateRequest(
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
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final summaryValidationResult =
        request.summaryValidationResult ??
        request.summaryValidation.evaluate(
          InternalAdapterReadinessSummaryValidationRequest(
            summaryResult: summaryResult,
            readinessGateResult: readinessGateResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final designResult =
        request.designResult ??
        request.design.evaluate(
          DebugOnlyAdapterBridgeDesignRequest(
            summaryValidationResult: summaryValidationResult,
            summaryResult: summaryResult,
            readinessGateResult: readinessGateResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final groupRows = _groupRowsFromDesign(designResult);
    final recordRows = _recordRowsFromDesign(designResult);
    final checks = _checksFor(
      designResult: designResult,
      groupRows: groupRows,
      recordRows: recordRows,
      androidProofEvidence: request.androidProofEvidence,
    );
    final base = _resultFromRowsAndChecks(
      designResult: designResult,
      summaryValidationResult: summaryValidationResult,
      summaryResult: summaryResult,
      readinessGateResult: readinessGateResult,
      groupRows: groupRows,
      recordRows: recordRows,
      checks: checks,
      validationFindings:
          const <DebugOnlyAdapterBridgeDesignValidationFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromRowsAndChecks(
      designResult: designResult,
      summaryValidationResult: summaryValidationResult,
      summaryResult: summaryResult,
      readinessGateResult: readinessGateResult,
      groupRows: groupRows,
      recordRows: recordRows,
      checks: checks,
      validationFindings: findings,
    );
  }
}

class DebugOnlyAdapterBridgeDesignValidationValidator {
  const DebugOnlyAdapterBridgeDesignValidationValidator();

  List<DebugOnlyAdapterBridgeDesignValidationFinding> validate(
    DebugOnlyAdapterBridgeDesignValidationResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <DebugOnlyAdapterBridgeDesignValidationFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required DebugOnlyAdapterBridgeDesignValidationSeverity severity,
      required String message,
      String? validationRowId,
      String? bridgeRecordId,
      DebugOnlyAdapterBridgeInputGroupId? bridgeGroupId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        DebugOnlyAdapterBridgeDesignValidationFinding(
          id: id,
          severity: severity,
          message: message,
          validationRowId: validationRowId,
          bridgeRecordId: bridgeRecordId,
          bridgeGroupId: bridgeGroupId,
          fieldId: fieldId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase32V &&
        (result.sourceBridgeDesignStatus ==
                DebugOnlyAdapterBridgeDesignStatus
                    .blockedBySummaryValidationFailure ||
            result.sourceBridgeDesignStatus ==
                DebugOnlyAdapterBridgeDesignStatus.blockedByPolicyBoundary ||
            result.unsafeRecordCount > 0)) {
      add(
        id: 'unsafeBridgeDesignMarkedValidated',
        severity: DebugOnlyAdapterBridgeDesignValidationSeverity.critical,
        message: 'unsafe bridge design cannot be marked validated',
      );
    }

    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: DebugOnlyAdapterBridgeDesignValidationSeverity.blocker,
        message: 'owner proof requires explicit PV/MultiPV reason',
      );
    }

    for (final fieldId in _blockedBridgeFieldIds) {
      if (!result.blockedFieldIds.contains(fieldId)) {
        add(
          id: 'blockedBridgeFieldMissing',
          severity: DebugOnlyAdapterBridgeDesignValidationSeverity.blocker,
          message: '$fieldId must remain blocked from bridge validation',
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
          bridgeGroupId: row.sourceBridgeGroupId,
        );
      }
      for (final caseId in row.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          validationRowId: row.validationRowId,
          bridgeGroupId: row.sourceBridgeGroupId,
        );
      }
    }

    for (final row in result.recordRows) {
      for (final fieldId in row.activeFieldIds) {
        _checkActiveBridgeField(
          add,
          fieldId,
          validationRowId: row.validationRowId,
          bridgeRecordId: row.sourceBridgeRecordId,
        );
      }
      for (final caseId in row.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          validationRowId: row.validationRowId,
          bridgeRecordId: row.sourceBridgeRecordId,
        );
      }
      if (row.bridgeRole == DebugOnlyAdapterBridgeRole.debugCoreInput &&
          row.violationReasons.contains('debugCoreConsumesNonCoreInput')) {
        add(
          id: 'debugCoreConsumesNonCoreInput',
          severity: DebugOnlyAdapterBridgeDesignValidationSeverity.critical,
          message: 'debug core input cannot consume non-core input',
          validationRowId: row.validationRowId,
          bridgeRecordId: row.sourceBridgeRecordId,
        );
      }
      if (row.contextOnly &&
          row.bridgeRole == DebugOnlyAdapterBridgeRole.debugCoreInput) {
        add(
          id: 'contextOnlyInputPromotedToDebugCore',
          severity: DebugOnlyAdapterBridgeDesignValidationSeverity.critical,
          message: 'context-only input cannot become debug core',
          validationRowId: row.validationRowId,
          bridgeRecordId: row.sourceBridgeRecordId,
        );
      }
      if (row.bridgeRole.isInactiveBoundary &&
          (!_recordRowIsInactiveSafe(row))) {
        add(
          id: 'blockedFutureInputMadeActive',
          severity: DebugOnlyAdapterBridgeDesignValidationSeverity.critical,
          message: 'blocked/future-only input must remain inactive',
          validationRowId: row.validationRowId,
          bridgeRecordId: row.sourceBridgeRecordId,
        );
      }
      _checkSafetyFlags(add, row);
    }

    if (result.productOutputActive ||
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
        id: 'debugBridgeValidationBoundaryPolicyViolation',
        severity: DebugOnlyAdapterBridgeDesignValidationSeverity.critical,
        message:
            'debug bridge design validation crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<DebugOnlyAdapterBridgeDesignValidationFinding> validateReportText(
    String reportText,
  ) {
    final findings = <DebugOnlyAdapterBridgeDesignValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        DebugOnlyAdapterBridgeDesignValidationFinding(
          id: id,
          severity: DebugOnlyAdapterBridgeDesignValidationSeverity.critical,
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

List<DebugOnlyAdapterBridgeGroupValidationRow> _groupRowsFromDesign(
  DebugOnlyAdapterBridgeDesignResult designResult,
) {
  return designResult.inputGroups
      .map((group) => _groupRowFromGroup(group, designResult.bridgeRecords))
      .toList(growable: false);
}

DebugOnlyAdapterBridgeGroupValidationRow _groupRowFromGroup(
  DebugOnlyAdapterBridgeInputGroup group,
  List<DebugOnlyAdapterBridgeRecord> records,
) {
  final relatedRecords = records
      .where((record) => _groupForRole(record.bridgeRole) == group.groupId)
      .toList(growable: false);
  final expectedStatus = _validGroupStatusFor(group.groupId);
  final violations = <String>[
    if (group.designStatus.isUnsafe) 'unsafeBridgeGroup',
    if (!group.safeForFutureDebugBridge) 'bridgeGroupNotSafeForFutureDebug',
    if (group.activeFieldIds.any(_isBlockedBridgeFieldId))
      'activeBlockedBridgeField',
    if (group.groupId ==
            DebugOnlyAdapterBridgeInputGroupId.debugCoreInputGroup &&
        !group.packetIds.every(_isCorePacketId))
      'debugCoreConsumesNonCoreInput',
    if ((group.groupId ==
                DebugOnlyAdapterBridgeInputGroupId.debugBlockedInputGroup ||
            group.groupId ==
                DebugOnlyAdapterBridgeInputGroupId.debugFutureOnlyInputGroup) &&
        group.activeFieldIds.isNotEmpty)
      'blockedFutureInputMadeActive',
    if (group.groupId ==
            DebugOnlyAdapterBridgeInputGroupId.debugProofBoundaryGroup &&
        !_setEquals(group.androidProofCaseIds, _capturedAndroidProofIds))
      'unprovenAndroidProofId',
    if (group.androidProofCaseIds.any(_phase32ECaseIds.contains))
      'phase32ECaseTreatedAsCapturedProof',
  ];
  final unsafe =
      group.designStatus.isUnsafe ||
      group.activeFieldIds.any(_isBlockedBridgeFieldId) ||
      group.activeFieldIds.any(_isLegacyBlockedOutputFieldId);
  final invalid = violations.isNotEmpty && !unsafe;
  final status = unsafe
      ? DebugOnlyAdapterBridgeGroupValidationStatus.unsafeBridgeGroup
      : invalid
      ? DebugOnlyAdapterBridgeGroupValidationStatus.invalidBridgeGroup
      : expectedStatus;
  return DebugOnlyAdapterBridgeGroupValidationRow(
    validationRowId: 'bridge-group-validation-${group.groupId.wire}',
    sourceBridgeGroupId: group.groupId,
    groupKind: expectedStatus,
    validationStatus: status,
    bridgeRecordIds: _sortedStrings(
      relatedRecords.map((record) => record.bridgeRecordId),
    ),
    activeFieldIds: _sortedStrings(group.activeFieldIds),
    blockedFieldIds: _sortedStrings(group.blockedFieldIds),
    supportCaseIds: _sortedStrings(group.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(group.newlyAddedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(group.androidProofCaseIds),
    ownerProofQueueCount: 0,
    validationReason: _validationReasonForGroup(group.groupId),
    warningReason: _warningReasonForGroup(group.groupId),
    violationReasons: _sortedStrings(violations),
    safeForNextPhase: !unsafe && !invalid,
    recommendation: unsafe
        ? DebugOnlyAdapterBridgeDesignValidationRecommendation
              .blockUnsafeBridgeValidation
        : invalid
        ? DebugOnlyAdapterBridgeDesignValidationRecommendation
              .investigateBridgeValidationFailure
        : _recommendationForGroup(group.groupId),
  );
}

List<DebugOnlyAdapterBridgeRecordValidationRow> _recordRowsFromDesign(
  DebugOnlyAdapterBridgeDesignResult designResult,
) {
  return designResult.bridgeRecords
      .map(_recordRowFromRecord)
      .toList(growable: false);
}

DebugOnlyAdapterBridgeRecordValidationRow _recordRowFromRecord(
  DebugOnlyAdapterBridgeRecord record,
) {
  final flags = _safetyFlagsFor(record);
  final violations = <String>[
    if (record.designStatus.isUnsafe) 'unsafeBridgeRecord',
    if (record.hasBlockedActiveField) 'activeBlockedBridgeField',
    if (record.bridgeRole == DebugOnlyAdapterBridgeRole.debugCoreInput &&
        !record.adapterPacketIds.every(_isCorePacketId))
      'debugCoreConsumesNonCoreInput',
    if (record.contextOnly &&
        record.bridgeRole == DebugOnlyAdapterBridgeRole.debugCoreInput)
      'contextOnlyInputPromotedToDebugCore',
    if (record.bridgeRole == DebugOnlyAdapterBridgeRole.debugContextOnlyInput &&
        !record.contextOnly)
      'contextOnlyInputLostContextConstraint',
    if (record.bridgeRole.isInactiveBoundary &&
        !_sourceRecordIsInactiveSafe(record))
      'blockedFutureInputMadeActive',
    if (record.androidProofCaseIds.any(_phase32ECaseIds.contains))
      'phase32ECaseTreatedAsCapturedProof',
    if (record.androidProofCaseIds.any(
      (caseId) => !_capturedAndroidProofIds.contains(caseId),
    ))
      'unprovenAndroidProofId',
    ...flags.entries
        .where((entry) => entry.value)
        .map((entry) => '${entry.key}Active'),
  ];
  final unsafe =
      record.hasUnsafeOutput ||
      record.designStatus ==
          DebugOnlyAdapterBridgeRecordDesignStatus.unsafeRecord;
  final invalid =
      !unsafe &&
      (record.designStatus ==
              DebugOnlyAdapterBridgeRecordDesignStatus.invalidRecord ||
          violations.isNotEmpty);
  final status = unsafe
      ? DebugOnlyAdapterBridgeRecordValidationStatus.unsafeBridgeRecord
      : invalid
      ? DebugOnlyAdapterBridgeRecordValidationStatus.invalidBridgeRecord
      : _validRecordStatusFor(record.bridgeRole);
  return DebugOnlyAdapterBridgeRecordValidationRow(
    validationRowId: 'bridge-record-validation-${record.bridgeRecordId}',
    sourceBridgeRecordId: record.bridgeRecordId,
    bridgeRole: record.bridgeRole,
    designStatus: record.designStatus,
    validationStatus: status,
    allowedForFutureDebugBridge: record.allowedForFutureDebugBridge,
    contextOnly: record.contextOnly,
    inactive: record.inactive,
    activeFieldIds: _sortedStrings(record.activeFieldIds),
    blockedFieldIds: _sortedStrings(record.blockedFieldIds),
    supportCaseIds: _sortedStrings(record.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(record.newlyAddedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(record.androidProofCaseIds),
    safetyFlags: flags,
    violationReasons: _sortedStrings(violations),
    safeForNextPhase: !unsafe && !invalid,
    recommendation: unsafe
        ? DebugOnlyAdapterBridgeDesignValidationRecommendation
              .blockUnsafeBridgeValidation
        : invalid
        ? DebugOnlyAdapterBridgeDesignValidationRecommendation
              .investigateBridgeValidationFailure
        : _recommendationForRole(record.bridgeRole),
  );
}

List<DebugOnlyAdapterBridgeDesignValidationCheck> _checksFor({
  required DebugOnlyAdapterBridgeDesignResult designResult,
  required List<DebugOnlyAdapterBridgeGroupValidationRow> groupRows,
  required List<DebugOnlyAdapterBridgeRecordValidationRow> recordRows,
  required GoldenAndroidProofEvidence? androidProofEvidence,
}) {
  final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
  final coreRecordIds = _recordIdsForRole(
    recordRows,
    DebugOnlyAdapterBridgeRole.debugCoreInput,
  );
  final contextRecordIds = _recordIdsForRole(
    recordRows,
    DebugOnlyAdapterBridgeRole.debugContextOnlyInput,
  );
  final blockedRecordIds = _recordIdsForRole(
    recordRows,
    DebugOnlyAdapterBridgeRole.debugBlockedInput,
  );
  final futureRecordIds = _recordIdsForRole(
    recordRows,
    DebugOnlyAdapterBridgeRole.debugFutureOnlyInput,
  );

  final checks = <DebugOnlyAdapterBridgeDesignValidationCheck>[
    _check(
      checkId: 'allowedFieldsAreInternalEvidenceSafe',
      passed:
          designResult.allowedFieldIds.every(_isAllowedBridgeFieldId) &&
          !designResult.allowedFieldIds.any(_isBlockedBridgeFieldId),
      relatedFieldIds: designResult.allowedFieldIds,
      recommendation: 'keep allowed bridge fields internal evidence-safe',
    ),
    _check(
      checkId: 'androidProofIdsAreCapturedOnly',
      passed:
          _setEquals(
            designResult.androidProofCaseIds,
            _capturedAndroidProofIds,
          ) &&
          designResult.androidProofCaseIds.every(provenAndroidIds.contains),
      relatedProofIds: designResult.androidProofCaseIds,
      recommendation: 'keep Android proof IDs captured-only',
    ),
    _check(
      checkId: 'blockedFieldsRemainDenied',
      passed:
          _blockedBridgeFieldIds.every(designResult.blockedFieldIds.contains) &&
          !designResult.allowedFieldIds.any(_isBlockedBridgeFieldId),
      relatedFieldIds: designResult.blockedFieldIds,
      recommendation: 'keep blocked bridge fields denied',
    ),
    _check(
      checkId: 'bridgeConsumesValidatedSummary',
      passed:
          designResult.sourceSummaryValidationStatus ==
              InternalAdapterReadinessSummaryValidationStatus
                  .validatedWithWarnings ||
          designResult.sourceSummaryValidationStatus ==
              InternalAdapterReadinessSummaryValidationStatus.validatedClean,
      recommendation: 'consume only validated readiness summary output',
    ),
    _check(
      checkId: 'debugBlockedInputsStayInactive',
      passedWithWarnings: _rowsAreInactive(
        recordRows,
        DebugOnlyAdapterBridgeRole.debugBlockedInput,
      ),
      relatedBridgeRecordIds: blockedRecordIds,
      recommendation: 'keep blocked debug inputs inactive',
    ),
    _check(
      checkId: 'debugContextInputsStayContextOnly',
      passedWithWarnings: recordRows
          .where(
            (row) =>
                row.bridgeRole ==
                DebugOnlyAdapterBridgeRole.debugContextOnlyInput,
          )
          .every((row) => row.contextOnly && row.safeForNextPhase),
      relatedBridgeRecordIds: contextRecordIds,
      recommendation: 'keep debug context inputs context-only',
    ),
    _check(
      checkId: 'debugCoreInputsUseOnlyAllowedCore',
      passed: recordRows
          .where(
            (row) =>
                row.bridgeRole == DebugOnlyAdapterBridgeRole.debugCoreInput,
          )
          .every(
            (row) =>
                row.validationStatus ==
                DebugOnlyAdapterBridgeRecordValidationStatus
                    .validDebugCoreInput,
          ),
      relatedBridgeRecordIds: coreRecordIds,
      recommendation:
          'keep debug core inputs limited to allowed core summaries',
    ),
    _check(
      checkId: 'debugFutureOnlyInputsStayInactive',
      passedWithWarnings: _rowsAreInactive(
        recordRows,
        DebugOnlyAdapterBridgeRole.debugFutureOnlyInput,
      ),
      relatedBridgeRecordIds: futureRecordIds,
      recommendation: 'keep future-only debug inputs inactive',
    ),
    _check(
      checkId: 'noLabelsScoresRankingsMetrics',
      passed:
          !designResult.productOutputActive &&
          !designResult.classifierOutputActive &&
          !designResult.finalMoveLabelOutputActive &&
          !designResult.numericOutputActive &&
          !designResult.aggregateScoreOutputActive &&
          !designResult.moveRankingOutputActive &&
          !designResult.officialMetricOutputActive &&
          !designResult.cpLossOutputActive &&
          !designResult.winProbabilityOutputActive &&
          !recordRows.any(
            (row) => row.safetyFlags.values.any((value) => value),
          ),
      recommendation: 'keep labels, scores, rankings, and metrics blocked',
    ),
    _check(
      checkId: 'noUiBackendPersistenceEngineFields',
      passed:
          !designResult.uiTargetsActive &&
          !designResult.backendOutputActive &&
          !designResult.persistenceWritesActive &&
          !designResult.engineCallsActive &&
          !designResult.stockfishCommandFieldActive &&
          !designResult.rawUciFieldActive &&
          !designResult.pvDumpFieldActive,
      recommendation: 'keep UI/backend/persistence/engine fields inactive',
    ),
    _check(
      checkId: 'ownerProofQueueRemainsEmpty',
      passed: designResult.ownerProofQueueCount == 0,
      recommendation: 'keep owner proof queue empty by default',
    ),
    _check(
      checkId: 'phase32ECasesAreNotCapturedProof',
      passed: !designResult.androidProofCaseIds.any(_phase32ECaseIds.contains),
      relatedProofIds: designResult.androidProofCaseIds,
      recommendation: 'do not treat Phase 32E cases as captured proof',
    ),
    _check(
      checkId: 'productBoundariesRemainBlocked',
      passed:
          !designResult.productOutputActive &&
          designResult.blockedFieldIds.contains('productLabel') &&
          designResult.blockedFieldIds.contains('finalMoveLabel'),
      relatedFieldIds: const <String>['productLabel', 'finalMoveLabel'],
      recommendation: 'keep product-facing boundaries blocked',
    ),
    _check(
      checkId: 'quietScopeRemainsExcluded',
      passed: !designResult.quietPreparatoryScopeActivated,
      recommendation: 'keep quiet/preparatory scope excluded',
    ),
    _check(
      checkId: 'stockfishCommandRawUciPvDumpStayBlocked',
      passed:
          designResult.blockedFieldIds.contains('stockfishCommand') &&
          designResult.blockedFieldIds.contains('rawUci') &&
          designResult.blockedFieldIds.contains('pvDump') &&
          !designResult.allowedFieldIds.contains('stockfishCommand') &&
          !designResult.allowedFieldIds.contains('rawUci') &&
          !designResult.allowedFieldIds.contains('pvDump') &&
          !designResult.stockfishCommandFieldActive &&
          !designResult.rawUciFieldActive &&
          !designResult.pvDumpFieldActive,
      relatedFieldIds: const <String>['stockfishCommand', 'rawUci', 'pvDump'],
      recommendation: 'keep engine command and dump fields blocked',
    ),
  ]..sort((a, b) => a.checkId.compareTo(b.checkId));
  return checks;
}

DebugOnlyAdapterBridgeDesignValidationCheck _check({
  required String checkId,
  bool? passed,
  bool? passedWithWarnings,
  List<String> relatedBridgeRecordIds = const <String>[],
  List<String> relatedGroupIds = const <String>[],
  List<String> relatedFieldIds = const <String>[],
  List<String> relatedProofIds = const <String>[],
  required String recommendation,
}) {
  final warning = passedWithWarnings == true;
  final ok = passed == true || warning;
  return DebugOnlyAdapterBridgeDesignValidationCheck(
    checkId: checkId,
    checkStatus: ok
        ? warning
              ? DebugOnlyAdapterBridgeDesignValidationCheckStatus
                    .passedWithWarnings
              : DebugOnlyAdapterBridgeDesignValidationCheckStatus.passed
        : DebugOnlyAdapterBridgeDesignValidationCheckStatus.failed,
    severity: ok
        ? warning
              ? DebugOnlyAdapterBridgeDesignValidationSeverity.warning
              : DebugOnlyAdapterBridgeDesignValidationSeverity.none
        : DebugOnlyAdapterBridgeDesignValidationSeverity.blocker,
    relatedBridgeRecordIds: _sortedStrings(relatedBridgeRecordIds),
    relatedGroupIds: _sortedStrings(relatedGroupIds),
    relatedFieldIds: _sortedStrings(relatedFieldIds),
    relatedProofIds: _sortedStrings(relatedProofIds),
    warningReason: warning ? '$checkId remains constrained by design' : '',
    failureReason: ok ? '' : '$checkId failed',
    recommendation: recommendation,
  );
}

DebugOnlyAdapterBridgeDesignValidationResult _resultFromRowsAndChecks({
  required DebugOnlyAdapterBridgeDesignResult designResult,
  required InternalAdapterReadinessSummaryValidationResult
  summaryValidationResult,
  required InternalAdapterReadinessSummaryResult summaryResult,
  required InternalEvidenceAdapterPrototypeReadinessGateResult
  readinessGateResult,
  required List<DebugOnlyAdapterBridgeGroupValidationRow> groupRows,
  required List<DebugOnlyAdapterBridgeRecordValidationRow> recordRows,
  required List<DebugOnlyAdapterBridgeDesignValidationCheck> checks,
  required List<DebugOnlyAdapterBridgeDesignValidationFinding>
  validationFindings,
}) {
  final unsafeRecordCount = recordRows
      .where((row) => row.validationStatus.isUnsafe || row.hasUnsafeOutput)
      .length;
  final invalidRecordCount = recordRows
      .where((row) => row.validationStatus.isInvalid)
      .length;
  final blockerCount =
      checks.where((check) => check.severity.blocksStrict).length +
      validationFindings
          .where((finding) => finding.severity.blocksStrict)
          .length;
  final criticalCount =
      checks.where((check) => check.isCritical).length +
      validationFindings.where((finding) => finding.isCritical).length;
  final base = DebugOnlyAdapterBridgeDesignValidationResult(
    validationStatus: DebugOnlyAdapterBridgeDesignValidationStatus.invalid,
    sourceBridgeDesignStatus: designResult.designStatus,
    sourceSummaryValidationStatus: designResult.sourceSummaryValidationStatus,
    sourceSummaryStatus: designResult.sourceSummaryStatus,
    sourceReadinessGateStatus: designResult.sourceReadinessGateStatus,
    checks: checks,
    groupRows: groupRows,
    recordRows: recordRows,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...designResult.warnings,
      ...checks
          .where(
            (check) =>
                check.checkStatus ==
                DebugOnlyAdapterBridgeDesignValidationCheckStatus
                    .passedWithWarnings,
          )
          .map((check) => check.warningReason),
    ]),
    failures: _sortedStrings(<String>[
      ...designResult.failures,
      ...checks.map((check) => check.failureReason),
      ...validationFindings.map((finding) => finding.message),
      ...groupRows.expand((row) => row.violationReasons),
      ...recordRows.expand((row) => row.violationReasons),
    ]),
    totalChecks: checks.length,
    passedCheckCount: checks
        .where(
          (check) =>
              check.checkStatus ==
              DebugOnlyAdapterBridgeDesignValidationCheckStatus.passed,
        )
        .length,
    warningCheckCount: checks
        .where(
          (check) =>
              check.checkStatus ==
              DebugOnlyAdapterBridgeDesignValidationCheckStatus
                  .passedWithWarnings,
        )
        .length,
    blockerCount: blockerCount,
    criticalCount: criticalCount,
    totalGroupRows: groupRows.length,
    totalRecordRows: recordRows.length,
    validDebugCoreInputCount: _countRecordRows(
      recordRows,
      DebugOnlyAdapterBridgeRecordValidationStatus.validDebugCoreInput,
    ),
    validDebugContextInputCount: _countRecordRows(
      recordRows,
      DebugOnlyAdapterBridgeRecordValidationStatus.validDebugContextOnlyInput,
    ),
    validInactiveBlockedInputCount: _countRecordRows(
      recordRows,
      DebugOnlyAdapterBridgeRecordValidationStatus.validDebugBlockedInput,
    ),
    validInactiveFutureOnlyInputCount: _countRecordRows(
      recordRows,
      DebugOnlyAdapterBridgeRecordValidationStatus.validDebugFutureOnlyInput,
    ),
    validAllowedFieldGroupCount: _countGroupRows(
      groupRows,
      DebugOnlyAdapterBridgeGroupValidationStatus.validDebugAllowedFieldGroup,
    ),
    validBlockedFieldGroupCount: _countGroupRows(
      groupRows,
      DebugOnlyAdapterBridgeGroupValidationStatus.validDebugBlockedFieldGroup,
    ),
    validProofBoundaryCount: _countGroupRows(
      groupRows,
      DebugOnlyAdapterBridgeGroupValidationStatus.validDebugProofBoundaryGroup,
    ),
    validOwnerProofStatusCount: _countGroupRows(
      groupRows,
      DebugOnlyAdapterBridgeGroupValidationStatus
          .validDebugOwnerProofStatusGroup,
    ),
    invalidRecordCount: invalidRecordCount,
    unsafeRecordCount: unsafeRecordCount,
    ownerProofQueueCount: designResult.ownerProofQueueCount,
    supportCaseIds: _sortedStrings(designResult.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(
      designResult.newlyAddedSupportCaseIds,
    ),
    androidProofCaseIds: _sortedStrings(designResult.androidProofCaseIds),
    allowedFieldIds: _sortedStrings(designResult.allowedFieldIds),
    blockedFieldIds: _sortedStrings(designResult.blockedFieldIds),
    safeForPhase32V: false,
    phase32VRecommendation:
        DebugOnlyAdapterBridgeDesignValidationPhase32VRecommendation
            .addMoreGoldenCoverageFirst,
    developerOnly:
        designResult.developerOnly &&
        summaryValidationResult.developerOnly &&
        summaryResult.developerOnly,
    productOutputActive: designResult.productOutputActive,
    classifierOutputActive: designResult.classifierOutputActive,
    finalMoveLabelOutputActive: designResult.finalMoveLabelOutputActive,
    officialMetricOutputActive: designResult.officialMetricOutputActive,
    cpLossOutputActive: designResult.cpLossOutputActive,
    winProbabilityOutputActive: designResult.winProbabilityOutputActive,
    numericOutputActive: designResult.numericOutputActive,
    aggregateScoreOutputActive: designResult.aggregateScoreOutputActive,
    moveRankingOutputActive: designResult.moveRankingOutputActive,
    quietPreparatoryScopeActivated: designResult.quietPreparatoryScopeActivated,
    engineCallsActive: designResult.engineCallsActive,
    persistenceWritesActive: designResult.persistenceWritesActive,
    uiTargetsActive: designResult.uiTargetsActive,
    backendOutputActive: designResult.backendOutputActive,
    stockfishCommandFieldActive: designResult.stockfishCommandFieldActive,
    rawUciFieldActive: designResult.rawUciFieldActive,
    pvDumpFieldActive: designResult.pvDumpFieldActive,
  );
  final status = _validationStatusFor(
    base,
    designResult: designResult,
    readinessGateResult: readinessGateResult,
  );
  final safeForPhase32V =
      (status ==
              DebugOnlyAdapterBridgeDesignValidationStatus
                  .validatedWithWarnings ||
          status ==
              DebugOnlyAdapterBridgeDesignValidationStatus.validatedClean) &&
      designResult.safeForPhase32U &&
      !designResult.isStrictlyBlocked &&
      !designResult.hasUnsafeDebugBridgeDesignPolicyViolation &&
      readinessGateResult.safeForPhase32R &&
      !readinessGateResult.isStrictlyBlocked &&
      unsafeRecordCount == 0 &&
      invalidRecordCount == 0 &&
      groupRows.every((row) => row.safeForNextPhase) &&
      recordRows.every((row) => row.safeForNextPhase) &&
      !checks.any((check) => check.blocksStrict) &&
      !validationFindings.any((finding) => finding.blocksStrict);
  return base.copyWith(
    validationStatus: status,
    safeForPhase32V: safeForPhase32V,
    phase32VRecommendation: _phase32VRecommendationFor(
      status: status,
      safeForPhase32V: safeForPhase32V,
      ownerProofQueueCount: designResult.ownerProofQueueCount,
    ),
  );
}

DebugOnlyAdapterBridgeDesignValidationStatus _validationStatusFor(
  DebugOnlyAdapterBridgeDesignValidationResult result, {
  required DebugOnlyAdapterBridgeDesignResult designResult,
  required InternalEvidenceAdapterPrototypeReadinessGateResult
  readinessGateResult,
}) {
  if (result.productOutputActive ||
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
    return DebugOnlyAdapterBridgeDesignValidationStatus.blockedByPolicyBoundary;
  }
  if (designResult.designStatus ==
          DebugOnlyAdapterBridgeDesignStatus
              .blockedBySummaryValidationFailure ||
      designResult.designStatus ==
          DebugOnlyAdapterBridgeDesignStatus.blockedByPolicyBoundary ||
      designResult.unsafeCount > 0 ||
      designResult.criticalCount > 0 ||
      result.unsafeRecordCount > 0 ||
      result.criticalCount > 0 ||
      designResult.hasUnsafeDebugBridgeDesignPolicyViolation) {
    return DebugOnlyAdapterBridgeDesignValidationStatus
        .blockedByUnsafeBridgeDesign;
  }
  if (!designResult.safeForPhase32U ||
      designResult.isStrictlyBlocked ||
      !readinessGateResult.safeForPhase32R ||
      readinessGateResult.isStrictlyBlocked ||
      result.invalidRecordCount > 0 ||
      result.groupRows.any((row) => row.validationStatus.isInvalid) ||
      result.checks.any((check) => check.checkStatus.isBlocked) ||
      _hasBridgeContractFinding(result.validationFindings)) {
    return DebugOnlyAdapterBridgeDesignValidationStatus
        .blockedByBridgeContractViolation;
  }
  if (result.blockerCount > 0 ||
      result.validationFindings.any((finding) => finding.blocksStrict)) {
    return DebugOnlyAdapterBridgeDesignValidationStatus.invalid;
  }
  if (result.groupRows.isEmpty ||
      result.recordRows.isEmpty ||
      result.checks.isEmpty) {
    return DebugOnlyAdapterBridgeDesignValidationStatus.invalid;
  }
  if (result.warningCheckCount > 0 || result.warnings.isNotEmpty) {
    return DebugOnlyAdapterBridgeDesignValidationStatus.validatedWithWarnings;
  }
  return DebugOnlyAdapterBridgeDesignValidationStatus.validatedClean;
}

DebugOnlyAdapterBridgeDesignValidationPhase32VRecommendation
_phase32VRecommendationFor({
  required DebugOnlyAdapterBridgeDesignValidationStatus status,
  required bool safeForPhase32V,
  required int ownerProofQueueCount,
}) {
  if (status ==
          DebugOnlyAdapterBridgeDesignValidationStatus
              .blockedByUnsafeBridgeDesign ||
      status ==
          DebugOnlyAdapterBridgeDesignValidationStatus
              .blockedByPolicyBoundary) {
    return DebugOnlyAdapterBridgeDesignValidationPhase32VRecommendation
        .blockedByUnsafeBridgeValidation;
  }
  if (ownerProofQueueCount > 0) {
    return DebugOnlyAdapterBridgeDesignValidationPhase32VRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase32V) {
    return DebugOnlyAdapterBridgeDesignValidationPhase32VRecommendation
        .addMoreGoldenCoverageFirst;
  }
  return DebugOnlyAdapterBridgeDesignValidationPhase32VRecommendation
      .proceedToDebugBridgeDesignReadinessGate;
}

bool _hasBridgeContractFinding(
  List<DebugOnlyAdapterBridgeDesignValidationFinding> findings,
) {
  return findings.any(
    (finding) =>
        finding.id.contains('NonCore') ||
        finding.id.contains('Promoted') ||
        finding.id.contains('MadeActive') ||
        finding.id.contains('Missing'),
  );
}

DebugOnlyAdapterBridgeInputGroupId _groupForRole(
  DebugOnlyAdapterBridgeRole role,
) {
  return switch (role) {
    DebugOnlyAdapterBridgeRole.debugCoreInput =>
      DebugOnlyAdapterBridgeInputGroupId.debugCoreInputGroup,
    DebugOnlyAdapterBridgeRole.debugContextOnlyInput =>
      DebugOnlyAdapterBridgeInputGroupId.debugContextInputGroup,
    DebugOnlyAdapterBridgeRole.debugBlockedInput =>
      DebugOnlyAdapterBridgeInputGroupId.debugBlockedInputGroup,
    DebugOnlyAdapterBridgeRole.debugFutureOnlyInput =>
      DebugOnlyAdapterBridgeInputGroupId.debugFutureOnlyInputGroup,
    DebugOnlyAdapterBridgeRole.debugAllowedField =>
      DebugOnlyAdapterBridgeInputGroupId.debugAllowedFieldGroup,
    DebugOnlyAdapterBridgeRole.debugBlockedField =>
      DebugOnlyAdapterBridgeInputGroupId.debugBlockedFieldGroup,
    DebugOnlyAdapterBridgeRole.debugProofBoundary =>
      DebugOnlyAdapterBridgeInputGroupId.debugProofBoundaryGroup,
    DebugOnlyAdapterBridgeRole.debugOwnerProofStatus =>
      DebugOnlyAdapterBridgeInputGroupId.debugOwnerProofStatusGroup,
  };
}

DebugOnlyAdapterBridgeGroupValidationStatus _validGroupStatusFor(
  DebugOnlyAdapterBridgeInputGroupId groupId,
) {
  return switch (groupId) {
    DebugOnlyAdapterBridgeInputGroupId.debugCoreInputGroup =>
      DebugOnlyAdapterBridgeGroupValidationStatus.validDebugCoreInputGroup,
    DebugOnlyAdapterBridgeInputGroupId.debugContextInputGroup =>
      DebugOnlyAdapterBridgeGroupValidationStatus.validDebugContextInputGroup,
    DebugOnlyAdapterBridgeInputGroupId.debugBlockedInputGroup =>
      DebugOnlyAdapterBridgeGroupValidationStatus.validDebugBlockedInputGroup,
    DebugOnlyAdapterBridgeInputGroupId.debugFutureOnlyInputGroup =>
      DebugOnlyAdapterBridgeGroupValidationStatus
          .validDebugFutureOnlyInputGroup,
    DebugOnlyAdapterBridgeInputGroupId.debugAllowedFieldGroup =>
      DebugOnlyAdapterBridgeGroupValidationStatus.validDebugAllowedFieldGroup,
    DebugOnlyAdapterBridgeInputGroupId.debugBlockedFieldGroup =>
      DebugOnlyAdapterBridgeGroupValidationStatus.validDebugBlockedFieldGroup,
    DebugOnlyAdapterBridgeInputGroupId.debugProofBoundaryGroup =>
      DebugOnlyAdapterBridgeGroupValidationStatus.validDebugProofBoundaryGroup,
    DebugOnlyAdapterBridgeInputGroupId.debugOwnerProofStatusGroup =>
      DebugOnlyAdapterBridgeGroupValidationStatus
          .validDebugOwnerProofStatusGroup,
  };
}

DebugOnlyAdapterBridgeRecordValidationStatus _validRecordStatusFor(
  DebugOnlyAdapterBridgeRole role,
) {
  return switch (role) {
    DebugOnlyAdapterBridgeRole.debugCoreInput =>
      DebugOnlyAdapterBridgeRecordValidationStatus.validDebugCoreInput,
    DebugOnlyAdapterBridgeRole.debugContextOnlyInput =>
      DebugOnlyAdapterBridgeRecordValidationStatus.validDebugContextOnlyInput,
    DebugOnlyAdapterBridgeRole.debugBlockedInput =>
      DebugOnlyAdapterBridgeRecordValidationStatus.validDebugBlockedInput,
    DebugOnlyAdapterBridgeRole.debugFutureOnlyInput =>
      DebugOnlyAdapterBridgeRecordValidationStatus.validDebugFutureOnlyInput,
    DebugOnlyAdapterBridgeRole.debugAllowedField =>
      DebugOnlyAdapterBridgeRecordValidationStatus.validDebugAllowedField,
    DebugOnlyAdapterBridgeRole.debugBlockedField =>
      DebugOnlyAdapterBridgeRecordValidationStatus.validDebugBlockedField,
    DebugOnlyAdapterBridgeRole.debugProofBoundary =>
      DebugOnlyAdapterBridgeRecordValidationStatus.validDebugProofBoundary,
    DebugOnlyAdapterBridgeRole.debugOwnerProofStatus =>
      DebugOnlyAdapterBridgeRecordValidationStatus.validDebugOwnerProofStatus,
  };
}

DebugOnlyAdapterBridgeDesignValidationRecommendation _recommendationForGroup(
  DebugOnlyAdapterBridgeInputGroupId groupId,
) {
  return switch (groupId) {
    DebugOnlyAdapterBridgeInputGroupId.debugCoreInputGroup =>
      DebugOnlyAdapterBridgeDesignValidationRecommendation
          .keepDebugCoreInputsValidated,
    DebugOnlyAdapterBridgeInputGroupId.debugContextInputGroup =>
      DebugOnlyAdapterBridgeDesignValidationRecommendation
          .keepDebugContextInputsContextOnly,
    DebugOnlyAdapterBridgeInputGroupId.debugBlockedInputGroup =>
      DebugOnlyAdapterBridgeDesignValidationRecommendation
          .keepDebugBlockedInputsInactive,
    DebugOnlyAdapterBridgeInputGroupId.debugFutureOnlyInputGroup =>
      DebugOnlyAdapterBridgeDesignValidationRecommendation
          .keepDebugFutureOnlyInputsInactive,
    DebugOnlyAdapterBridgeInputGroupId.debugAllowedFieldGroup =>
      DebugOnlyAdapterBridgeDesignValidationRecommendation
          .keepAllowedBridgeFieldsSafe,
    DebugOnlyAdapterBridgeInputGroupId.debugBlockedFieldGroup =>
      DebugOnlyAdapterBridgeDesignValidationRecommendation
          .keepBlockedBridgeFieldsDenied,
    DebugOnlyAdapterBridgeInputGroupId.debugProofBoundaryGroup =>
      DebugOnlyAdapterBridgeDesignValidationRecommendation
          .keepProofBoundaryCaptured,
    DebugOnlyAdapterBridgeInputGroupId.debugOwnerProofStatusGroup =>
      DebugOnlyAdapterBridgeDesignValidationRecommendation.keepOwnerProofEmpty,
  };
}

DebugOnlyAdapterBridgeDesignValidationRecommendation _recommendationForRole(
  DebugOnlyAdapterBridgeRole role,
) {
  return switch (role) {
    DebugOnlyAdapterBridgeRole.debugCoreInput =>
      DebugOnlyAdapterBridgeDesignValidationRecommendation
          .keepDebugCoreInputsValidated,
    DebugOnlyAdapterBridgeRole.debugContextOnlyInput =>
      DebugOnlyAdapterBridgeDesignValidationRecommendation
          .keepDebugContextInputsContextOnly,
    DebugOnlyAdapterBridgeRole.debugBlockedInput =>
      DebugOnlyAdapterBridgeDesignValidationRecommendation
          .keepDebugBlockedInputsInactive,
    DebugOnlyAdapterBridgeRole.debugFutureOnlyInput =>
      DebugOnlyAdapterBridgeDesignValidationRecommendation
          .keepDebugFutureOnlyInputsInactive,
    DebugOnlyAdapterBridgeRole.debugAllowedField =>
      DebugOnlyAdapterBridgeDesignValidationRecommendation
          .keepAllowedBridgeFieldsSafe,
    DebugOnlyAdapterBridgeRole.debugBlockedField =>
      DebugOnlyAdapterBridgeDesignValidationRecommendation
          .keepBlockedBridgeFieldsDenied,
    DebugOnlyAdapterBridgeRole.debugProofBoundary =>
      DebugOnlyAdapterBridgeDesignValidationRecommendation
          .keepProofBoundaryCaptured,
    DebugOnlyAdapterBridgeRole.debugOwnerProofStatus =>
      DebugOnlyAdapterBridgeDesignValidationRecommendation.keepOwnerProofEmpty,
  };
}

String _validationReasonForGroup(DebugOnlyAdapterBridgeInputGroupId groupId) {
  return switch (groupId) {
    DebugOnlyAdapterBridgeInputGroupId.debugCoreInputGroup =>
      'debug core group consumes only validated allowed core summary output',
    DebugOnlyAdapterBridgeInputGroupId.debugContextInputGroup =>
      'debug context group consumes constrained context-only summary output',
    DebugOnlyAdapterBridgeInputGroupId.debugBlockedInputGroup =>
      'debug blocked group remains inactive',
    DebugOnlyAdapterBridgeInputGroupId.debugFutureOnlyInputGroup =>
      'debug future-only group remains inactive',
    DebugOnlyAdapterBridgeInputGroupId.debugAllowedFieldGroup =>
      'allowed bridge fields are internal evidence-safe',
    DebugOnlyAdapterBridgeInputGroupId.debugBlockedFieldGroup =>
      'blocked bridge fields remain denied',
    DebugOnlyAdapterBridgeInputGroupId.debugProofBoundaryGroup =>
      'Android proof boundary remains captured-only',
    DebugOnlyAdapterBridgeInputGroupId.debugOwnerProofStatusGroup =>
      'owner proof status remains empty',
  };
}

String _warningReasonForGroup(DebugOnlyAdapterBridgeInputGroupId groupId) {
  return switch (groupId) {
    DebugOnlyAdapterBridgeInputGroupId.debugContextInputGroup =>
      'context input remains context-only',
    DebugOnlyAdapterBridgeInputGroupId.debugBlockedInputGroup =>
      'blocked input remains inactive',
    DebugOnlyAdapterBridgeInputGroupId.debugFutureOnlyInputGroup =>
      'future-only input remains inactive',
    _ => '',
  };
}

Map<String, bool> _safetyFlagsFor(DebugOnlyAdapterBridgeRecord record) {
  return <String, bool>{
    'isProductOutput': record.isProductOutput,
    'isClassifierLabel': record.isClassifierLabel,
    'hasNumericScore': record.hasNumericScore,
    'hasAggregateScore': record.hasAggregateScore,
    'ranksMoves': record.ranksMoves,
    'isOfficialMetric': record.isOfficialMetric,
    'callsEngine': record.callsEngine,
    'writesPersistence': record.writesPersistence,
    'targetsUi': record.targetsUi,
    'backendOutputActive': record.backendOutputActive,
    'cpLossOutputActive': record.cpLossOutputActive,
    'winProbabilityOutputActive': record.winProbabilityOutputActive,
    'quietPreparatoryScopeActive': record.quietPreparatoryScopeActive,
    'stockfishCommandFieldActive': record.stockfishCommandFieldActive,
    'rawUciFieldActive': record.rawUciFieldActive,
    'pvDumpFieldActive': record.pvDumpFieldActive,
  };
}

void _checkSafetyFlags(
  void Function({
    required String id,
    required DebugOnlyAdapterBridgeDesignValidationSeverity severity,
    required String message,
    String? validationRowId,
    String? bridgeRecordId,
    DebugOnlyAdapterBridgeInputGroupId? bridgeGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugOnlyAdapterBridgeRecordValidationRow row,
) {
  void critical(String id, String message) {
    add(
      id: id,
      severity: DebugOnlyAdapterBridgeDesignValidationSeverity.critical,
      message: message,
      validationRowId: row.validationRowId,
      bridgeRecordId: row.sourceBridgeRecordId,
    );
  }

  if (row.safetyFlags['isProductOutput'] == true) {
    critical(
      'productOutputActive',
      'bridge validation cannot be product output',
    );
  }
  if (row.safetyFlags['isClassifierLabel'] == true) {
    critical(
      'classifierLabelOutputActive',
      'bridge validation cannot emit classifier labels',
    );
  }
  if (row.safetyFlags['hasNumericScore'] == true) {
    critical(
      'numericScoreOutputActive',
      'bridge validation cannot emit numeric scores',
    );
  }
  if (row.safetyFlags['hasAggregateScore'] == true) {
    critical(
      'aggregateScoreOutputActive',
      'bridge validation cannot emit aggregate scores',
    );
  }
  if (row.safetyFlags['ranksMoves'] == true) {
    critical('moveRankingOutputActive', 'bridge validation cannot rank moves');
  }
  if (row.safetyFlags['isOfficialMetric'] == true) {
    critical(
      'officialMetricOutputActive',
      'bridge validation cannot emit official metrics',
    );
  }
  if (row.safetyFlags['cpLossOutputActive'] == true ||
      row.safetyFlags['winProbabilityOutputActive'] == true) {
    critical(
      'futureMetricOutputActive',
      'bridge validation cannot emit CP-loss or win probability',
    );
  }
  if (row.safetyFlags['quietPreparatoryScopeActive'] == true) {
    critical(
      'quietPreparatoryScopeActivated',
      'quiet/preparatory scope must remain excluded',
    );
  }
  if (row.safetyFlags['callsEngine'] == true) {
    critical('engineCallFlagActive', 'bridge validation cannot call an engine');
  }
  if (row.safetyFlags['writesPersistence'] == true) {
    critical(
      'persistenceWriteFlagActive',
      'bridge validation cannot write persistence',
    );
  }
  if (row.safetyFlags['targetsUi'] == true) {
    critical('uiTargetFlagActive', 'bridge validation cannot target UI');
  }
  if (row.safetyFlags['backendOutputActive'] == true) {
    critical('backendOutputActive', 'bridge validation cannot target backend');
  }
  if (row.safetyFlags['stockfishCommandFieldActive'] == true ||
      row.safetyFlags['rawUciFieldActive'] == true ||
      row.safetyFlags['pvDumpFieldActive'] == true) {
    critical(
      'stockfishRawUciPvDumpFieldActive',
      'engine command and dump fields must remain blocked',
    );
  }
}

void _checkActiveBridgeField(
  void Function({
    required String id,
    required DebugOnlyAdapterBridgeDesignValidationSeverity severity,
    required String message,
    String? validationRowId,
    String? bridgeRecordId,
    DebugOnlyAdapterBridgeInputGroupId? bridgeGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String fieldId, {
  String? validationRowId,
  String? bridgeRecordId,
  DebugOnlyAdapterBridgeInputGroupId? bridgeGroupId,
}) {
  if (_isBlockedBridgeFieldId(fieldId) ||
      _isLegacyBlockedOutputFieldId(fieldId)) {
    add(
      id: 'activeBlockedBridgeField',
      severity: DebugOnlyAdapterBridgeDesignValidationSeverity.critical,
      message: '$fieldId cannot be active bridge output',
      validationRowId: validationRowId,
      bridgeRecordId: bridgeRecordId,
      bridgeGroupId: bridgeGroupId,
      fieldId: fieldId,
    );
  }
}

void _checkAndroidProofCase(
  void Function({
    required String id,
    required DebugOnlyAdapterBridgeDesignValidationSeverity severity,
    required String message,
    String? validationRowId,
    String? bridgeRecordId,
    DebugOnlyAdapterBridgeInputGroupId? bridgeGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String caseId,
  List<String> provenAndroidIds, {
  String? validationRowId,
  String? bridgeRecordId,
  DebugOnlyAdapterBridgeInputGroupId? bridgeGroupId,
}) {
  if (_phase32ECaseIds.contains(caseId)) {
    add(
      id: 'phase32ECaseTreatedAsCapturedProof',
      severity: DebugOnlyAdapterBridgeDesignValidationSeverity.critical,
      message: '$caseId cannot be treated as captured Android proof',
      validationRowId: validationRowId,
      bridgeRecordId: bridgeRecordId,
      bridgeGroupId: bridgeGroupId,
      caseId: caseId,
    );
    return;
  }
  if (!_capturedAndroidProofIds.contains(caseId) ||
      !provenAndroidIds.contains(caseId)) {
    add(
      id: 'unprovenAndroidProofId',
      severity: DebugOnlyAdapterBridgeDesignValidationSeverity.critical,
      message: '$caseId is not captured Android proof',
      validationRowId: validationRowId,
      bridgeRecordId: bridgeRecordId,
      bridgeGroupId: bridgeGroupId,
      caseId: caseId,
    );
  }
}

bool _rowsAreInactive(
  List<DebugOnlyAdapterBridgeRecordValidationRow> rows,
  DebugOnlyAdapterBridgeRole role,
) {
  final matching = rows.where((row) => row.bridgeRole == role).toList();
  return matching.isNotEmpty && matching.every(_recordRowIsInactiveSafe);
}

bool _recordRowIsInactiveSafe(DebugOnlyAdapterBridgeRecordValidationRow row) {
  return row.inactive &&
      row.bridgeRole.isInactiveBoundary &&
      row.activeFieldIds.isEmpty &&
      !row.hasUnsafeOutput;
}

bool _sourceRecordIsInactiveSafe(DebugOnlyAdapterBridgeRecord record) {
  return record.inactive &&
      record.bridgeRole.isInactiveBoundary &&
      record.activeFieldIds.isEmpty &&
      !record.hasUnsafeOutput;
}

List<String> _recordIdsForRole(
  List<DebugOnlyAdapterBridgeRecordValidationRow> rows,
  DebugOnlyAdapterBridgeRole role,
) {
  return _sortedStrings(
    rows
        .where((row) => row.bridgeRole == role)
        .map((row) => row.sourceBridgeRecordId),
  );
}

int _countRecordRows(
  List<DebugOnlyAdapterBridgeRecordValidationRow> rows,
  DebugOnlyAdapterBridgeRecordValidationStatus status,
) {
  return rows.where((row) => row.validationStatus == status).length;
}

int _countGroupRows(
  List<DebugOnlyAdapterBridgeGroupValidationRow> rows,
  DebugOnlyAdapterBridgeGroupValidationStatus status,
) {
  return rows.where((row) => row.validationStatus == status).length;
}

bool _hasExplicitPvProofReason(
  DebugOnlyAdapterBridgeDesignValidationResult result,
) {
  final reasons = <String>[
    ...result.warnings,
    ...result.failures,
    ...result.checks.map((check) => check.warningReason),
    ...result.checks.map((check) => check.failureReason),
  ].join(' ').toLowerCase();
  return reasons.contains('pv') || reasons.contains('multipv');
}

List<String> _provenAndroidProofIds(GoldenAndroidProofEvidence? evidence) {
  return _sortedStrings(evidence?.targetCaseIds ?? const <String>[]);
}

int _compareFindings(
  DebugOnlyAdapterBridgeDesignValidationFinding a,
  DebugOnlyAdapterBridgeDesignValidationFinding b,
) {
  final severity = _severityRank(
    b.severity,
  ).compareTo(_severityRank(a.severity));
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.bridgeRecordId ?? '').compareTo(b.bridgeRecordId ?? '');
}

int _severityRank(DebugOnlyAdapterBridgeDesignValidationSeverity severity) {
  return switch (severity) {
    DebugOnlyAdapterBridgeDesignValidationSeverity.none => 0,
    DebugOnlyAdapterBridgeDesignValidationSeverity.info => 1,
    DebugOnlyAdapterBridgeDesignValidationSeverity.warning => 2,
    DebugOnlyAdapterBridgeDesignValidationSeverity.blocker => 3,
    DebugOnlyAdapterBridgeDesignValidationSeverity.critical => 4,
  };
}

bool _isCorePacketId(String packetId) {
  return packetId == 'packet-allowedEvidenceSummary' ||
      packetId == 'packet-improvedSupportSummary';
}

bool _isAllowedBridgeFieldId(String value) {
  return _allowedBridgeFieldIds.contains(value);
}

bool _isBlockedBridgeFieldId(String value) {
  return _blockedBridgeFieldIds.contains(value);
}

bool _isLegacyBlockedOutputFieldId(String value) {
  return _legacyBlockedOutputFieldIds.contains(value);
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

bool _setEquals(Iterable<String> left, Iterable<String> right) {
  final leftSet = left.toSet();
  final rightSet = right.toSet();
  return leftSet.length == rightSet.length && leftSet.containsAll(rightSet);
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

const _allowedBridgeFieldIds = <String>[
  'debugBridgeRecordId',
  'sourceAdapterPacketIds',
  'sourceSummaryGroupIds',
  'supportCaseIds',
  'newlyAddedSupportCaseIds',
  'evidenceAreaIds',
  'bucketIds',
  'qualitativeConfidence',
  'internalWarnings',
  'internalConstraints',
  'futurePrerequisites',
  'proofLimitReason',
  'watchListReason',
  'warningLimitedReason',
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

const _legacyBlockedOutputFieldIds = <String>[
  'uiOutputFields',
  'backendPersistenceFields',
  'directEngineCallFields',
];

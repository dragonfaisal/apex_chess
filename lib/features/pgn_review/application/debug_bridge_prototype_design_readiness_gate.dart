/// Developer-only readiness gate for the validated debug bridge prototype
/// design.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_summary_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugBridgePrototypeDesignReadinessGateReportVersion =
    'debug-bridge-prototype-design-readiness-gate-v1';

enum DebugBridgePrototypeDesignReadinessGateStatus {
  readyForNextInternalStepWithWarnings('readyForNextInternalStepWithWarnings'),
  readyForNextInternalStepClean('readyForNextInternalStepClean'),
  blockedByPrototypeDesignValidationFailure(
    'blockedByPrototypeDesignValidationFailure',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const DebugBridgePrototypeDesignReadinessGateStatus(this.wire);

  final String wire;
}

enum DebugBridgePrototypeDesignReadinessGateGroupId {
  readinessApprovedPrototypeCoreDesignGroup(
    'readinessApprovedPrototypeCoreDesignGroup',
  ),
  constrainedPrototypeContextDesignGroup(
    'constrainedPrototypeContextDesignGroup',
  ),
  inactivePrototypeBlockedDesignGroup('inactivePrototypeBlockedDesignGroup'),
  inactivePrototypeFutureOnlyDesignGroup(
    'inactivePrototypeFutureOnlyDesignGroup',
  ),
  readinessApprovedAllowedFieldGroup('readinessApprovedAllowedFieldGroup'),
  deniedFieldBoundaryGroup('deniedFieldBoundaryGroup'),
  stockfishRawUciPvDumpDeniedGroup('stockfishRawUciPvDumpDeniedGroup'),
  androidProofBoundaryGroup('androidProofBoundaryGroup'),
  emptyOwnerProofBoundaryGroup('emptyOwnerProofBoundaryGroup'),
  runtimeExecutionBlockedGroup('runtimeExecutionBlockedGroup'),
  futurePhase33CRequirementGroup('futurePhase33CRequirementGroup');

  const DebugBridgePrototypeDesignReadinessGateGroupId(this.wire);

  final String wire;
}

enum DebugBridgePrototypeDesignReadinessGateGroupStatus {
  readinessApprovedPrototypeCoreDesign('readinessApprovedPrototypeCoreDesign'),
  constrainedPrototypeContextDesign('constrainedPrototypeContextDesign'),
  inactivePrototypeBlockedDesign('inactivePrototypeBlockedDesign'),
  inactivePrototypeFutureOnlyDesign('inactivePrototypeFutureOnlyDesign'),
  readinessApprovedAllowedField('readinessApprovedAllowedField'),
  deniedFieldBoundary('deniedFieldBoundary'),
  stockfishRawUciPvDumpDenied('stockfishRawUciPvDumpDenied'),
  androidProofBoundary('androidProofBoundary'),
  emptyOwnerProofBoundary('emptyOwnerProofBoundary'),
  runtimeExecutionBlocked('runtimeExecutionBlocked'),
  futurePhase33CRequirement('futurePhase33CRequirement'),
  invalidGateGroup('invalidGateGroup'),
  unsafeGateGroup('unsafeGateGroup');

  const DebugBridgePrototypeDesignReadinessGateGroupStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == unsafeGateGroup;

  bool get isInvalid => this == invalidGateGroup;
}

enum DebugBridgePrototypeDesignReadinessGateRole {
  readinessApprovedPrototypeCoreDesign('readinessApprovedPrototypeCoreDesign'),
  constrainedPrototypeContextDesign('constrainedPrototypeContextDesign'),
  inactivePrototypeBlockedDesign('inactivePrototypeBlockedDesign'),
  inactivePrototypeFutureOnlyDesign('inactivePrototypeFutureOnlyDesign'),
  readinessApprovedAllowedField('readinessApprovedAllowedField'),
  deniedFieldBoundary('deniedFieldBoundary'),
  stockfishRawUciPvDumpDenied('stockfishRawUciPvDumpDenied'),
  androidProofBoundary('androidProofBoundary'),
  emptyOwnerProofBoundary('emptyOwnerProofBoundary'),
  runtimeExecutionBlocked('runtimeExecutionBlocked'),
  futurePhase33CRequirement('futurePhase33CRequirement');

  const DebugBridgePrototypeDesignReadinessGateRole(this.wire);

  final String wire;

  bool get isInactiveBoundary =>
      this == inactivePrototypeBlockedDesign ||
      this == inactivePrototypeFutureOnlyDesign ||
      this == deniedFieldBoundary ||
      this == stockfishRawUciPvDumpDenied ||
      this == runtimeExecutionBlocked;
}

enum DebugBridgePrototypeDesignReadinessGateRecordStatus {
  readinessApprovedPrototypeCoreDesign('readinessApprovedPrototypeCoreDesign'),
  constrainedPrototypeContextDesign('constrainedPrototypeContextDesign'),
  inactivePrototypeBlockedDesign('inactivePrototypeBlockedDesign'),
  inactivePrototypeFutureOnlyDesign('inactivePrototypeFutureOnlyDesign'),
  readinessApprovedAllowedField('readinessApprovedAllowedField'),
  deniedFieldBoundary('deniedFieldBoundary'),
  stockfishRawUciPvDumpDenied('stockfishRawUciPvDumpDenied'),
  androidProofBoundary('androidProofBoundary'),
  emptyOwnerProofBoundary('emptyOwnerProofBoundary'),
  runtimeExecutionBlocked('runtimeExecutionBlocked'),
  futurePhase33CRequirement('futurePhase33CRequirement'),
  invalidGateRecord('invalidGateRecord'),
  unsafeGateRecord('unsafeGateRecord');

  const DebugBridgePrototypeDesignReadinessGateRecordStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == unsafeGateRecord;

  bool get isInvalid => this == invalidGateRecord;
}

enum DebugBridgePrototypeDesignReadinessGateRecommendation {
  approvePrototypeCoreDesignForPlanning(
    'approvePrototypeCoreDesignForPlanning',
  ),
  keepPrototypeContextConstrained('keepPrototypeContextConstrained'),
  keepPrototypeBlockedInactive('keepPrototypeBlockedInactive'),
  keepPrototypeFutureOnlyInactive('keepPrototypeFutureOnlyInactive'),
  approveAllowedFieldsForPlanning('approveAllowedFieldsForPlanning'),
  keepDeniedFieldsDenied('keepDeniedFieldsDenied'),
  keepStockfishRawUciPvDumpDenied('keepStockfishRawUciPvDumpDenied'),
  keepAndroidProofBoundaryCapturedOnly('keepAndroidProofBoundaryCapturedOnly'),
  keepOwnerProofEmpty('keepOwnerProofEmpty'),
  keepRuntimeExecutionBlocked('keepRuntimeExecutionBlocked'),
  requirePhase33CCheckpoint('requirePhase33CCheckpoint'),
  investigatePrototypeDesignReadinessGateFailure(
    'investigatePrototypeDesignReadinessGateFailure',
  ),
  blockUnsafePrototypeDesignReadinessGate(
    'blockUnsafePrototypeDesignReadinessGate',
  );

  const DebugBridgePrototypeDesignReadinessGateRecommendation(this.wire);

  final String wire;
}

enum DebugBridgePrototypeDesignReadinessGatePhase33CRecommendation {
  proceedToDebugBridgePrototypeDesignReadinessSummary(
    'proceedToDebugBridgePrototypeDesignReadinessSummary',
  ),
  proceedToDebugOnlyBridgePrototypeImplementationDesign(
    'proceedToDebugOnlyBridgePrototypeImplementationDesign',
  ),
  proceedToPrototypeDesignReportOnly('proceedToPrototypeDesignReportOnly'),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafePrototypeDesignReadinessGate(
    'blockedByUnsafePrototypeDesignReadinessGate',
  );

  const DebugBridgePrototypeDesignReadinessGatePhase33CRecommendation(
    this.wire,
  );

  final String wire;
}

enum DebugBridgePrototypeDesignReadinessGateSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const DebugBridgePrototypeDesignReadinessGateSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == DebugBridgePrototypeDesignReadinessGateSeverity.blocker ||
      this == DebugBridgePrototypeDesignReadinessGateSeverity.critical;

  bool get isCritical =>
      this == DebugBridgePrototypeDesignReadinessGateSeverity.critical;
}

enum DebugBridgePrototypeDesignReadinessGateReportFormat {
  markdown('markdown'),
  json('json');

  const DebugBridgePrototypeDesignReadinessGateReportFormat(this.wire);

  final String wire;
}

class DebugBridgePrototypeDesignReadinessGateRequest {
  const DebugBridgePrototypeDesignReadinessGateRequest({
    this.validationResult,
    this.designResult,
    this.gateResult,
    this.summaryValidationResult,
    this.validation = const DebugOnlyBridgePrototypeDesignValidation(),
    this.prototypeDesign = const DebugOnlyBridgePrototypeDesign(),
    this.gate = const DebugBridgeReadinessValidationGate(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const DebugBridgePrototypeDesignReadinessGateRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final DebugOnlyBridgePrototypeDesignValidationResult? validationResult;
  final DebugOnlyBridgePrototypeDesignResult? designResult;
  final DebugBridgeReadinessValidationGateResult? gateResult;
  final DebugBridgeReadinessSummaryValidationResult? summaryValidationResult;
  final DebugOnlyBridgePrototypeDesignValidation validation;
  final DebugOnlyBridgePrototypeDesign prototypeDesign;
  final DebugBridgeReadinessValidationGate gate;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class DebugBridgePrototypeDesignReadinessGateGroup {
  const DebugBridgePrototypeDesignReadinessGateGroup({
    required this.groupId,
    required this.gateStatus,
    required this.sourceValidationRowIds,
    required this.sourceDesignRecordIds,
    required this.sourceDesignSectionIds,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.futurePrerequisites,
    required this.blockedBoundaryIds,
    required this.designOnly,
    required this.safeForPhase33C,
    required this.recommendation,
  });

  final DebugBridgePrototypeDesignReadinessGateGroupId groupId;
  final DebugBridgePrototypeDesignReadinessGateGroupStatus gateStatus;
  final List<String> sourceValidationRowIds;
  final List<String> sourceDesignRecordIds;
  final List<String> sourceDesignSectionIds;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> futurePrerequisites;
  final List<String> blockedBoundaryIds;
  final bool designOnly;
  final bool safeForPhase33C;
  final DebugBridgePrototypeDesignReadinessGateRecommendation recommendation;

  bool get hasUnsafeOutput =>
      gateStatus.isUnsafe ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId);

  Map<String, Object?> toJson() => <String, Object?>{
    'groupId': groupId.wire,
    'gateStatus': gateStatus.wire,
    'sourceValidationRowIds': sourceValidationRowIds,
    'sourceDesignRecordIds': sourceDesignRecordIds,
    'sourceDesignSectionIds': sourceDesignSectionIds,
    'allowedFieldIds': allowedFieldIds,
    'deniedFieldIds': deniedFieldIds,
    'supportCaseIds': supportCaseIds,
    'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
    'androidProofCaseIds': androidProofCaseIds,
    'warningReasons': warningReasons,
    'proofLimitReasons': proofLimitReasons,
    'futurePrerequisites': futurePrerequisites,
    'blockedBoundaryIds': blockedBoundaryIds,
    'designOnly': designOnly,
    'safeForPhase33C': safeForPhase33C,
    'recommendation': recommendation.wire,
  };
}

class DebugBridgePrototypeDesignReadinessGateRecord {
  const DebugBridgePrototypeDesignReadinessGateRecord({
    required this.gateRecordId,
    required this.sourceValidationRowId,
    required this.sourceDesignRecordId,
    required this.sourceDesignSectionId,
    required this.gateRole,
    required this.gateStatus,
    required this.allowedForFutureInternalPrototypePlanning,
    required this.designOnly,
    required this.contextOnly,
    required this.inactive,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.futurePrerequisites,
    required this.blockedBoundaryIds,
    required this.safetyFlags,
    required this.violationReasons,
    required this.recommendation,
  });

  final String gateRecordId;
  final String sourceValidationRowId;
  final String sourceDesignRecordId;
  final String sourceDesignSectionId;
  final DebugBridgePrototypeDesignReadinessGateRole gateRole;
  final DebugBridgePrototypeDesignReadinessGateRecordStatus gateStatus;
  final bool allowedForFutureInternalPrototypePlanning;
  final bool designOnly;
  final bool contextOnly;
  final bool inactive;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> futurePrerequisites;
  final List<String> blockedBoundaryIds;
  final Map<String, bool> safetyFlags;
  final List<String> violationReasons;
  final DebugBridgePrototypeDesignReadinessGateRecommendation recommendation;

  bool get hasUnsafeOutput =>
      gateStatus.isUnsafe ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId) ||
      safetyFlags.values.any((value) => value);

  DebugBridgePrototypeDesignReadinessGateRecord copyWith({
    String? gateRecordId,
    String? sourceValidationRowId,
    String? sourceDesignRecordId,
    String? sourceDesignSectionId,
    DebugBridgePrototypeDesignReadinessGateRole? gateRole,
    DebugBridgePrototypeDesignReadinessGateRecordStatus? gateStatus,
    bool? allowedForFutureInternalPrototypePlanning,
    bool? designOnly,
    bool? contextOnly,
    bool? inactive,
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? futurePrerequisites,
    List<String>? blockedBoundaryIds,
    Map<String, bool>? safetyFlags,
    List<String>? violationReasons,
    DebugBridgePrototypeDesignReadinessGateRecommendation? recommendation,
  }) {
    return DebugBridgePrototypeDesignReadinessGateRecord(
      gateRecordId: gateRecordId ?? this.gateRecordId,
      sourceValidationRowId:
          sourceValidationRowId ?? this.sourceValidationRowId,
      sourceDesignRecordId: sourceDesignRecordId ?? this.sourceDesignRecordId,
      sourceDesignSectionId:
          sourceDesignSectionId ?? this.sourceDesignSectionId,
      gateRole: gateRole ?? this.gateRole,
      gateStatus: gateStatus ?? this.gateStatus,
      allowedForFutureInternalPrototypePlanning:
          allowedForFutureInternalPrototypePlanning ??
          this.allowedForFutureInternalPrototypePlanning,
      designOnly: designOnly ?? this.designOnly,
      contextOnly: contextOnly ?? this.contextOnly,
      inactive: inactive ?? this.inactive,
      allowedFieldIds: allowedFieldIds ?? this.allowedFieldIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      futurePrerequisites: futurePrerequisites ?? this.futurePrerequisites,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      safetyFlags: safetyFlags ?? this.safetyFlags,
      violationReasons: violationReasons ?? this.violationReasons,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'gateRecordId': gateRecordId,
    'sourceValidationRowId': sourceValidationRowId,
    'sourceDesignRecordId': sourceDesignRecordId,
    'sourceDesignSectionId': sourceDesignSectionId,
    'gateRole': gateRole.wire,
    'gateStatus': gateStatus.wire,
    'allowedForFutureInternalPrototypePlanning':
        allowedForFutureInternalPrototypePlanning,
    'designOnly': designOnly,
    'contextOnly': contextOnly,
    'inactive': inactive,
    'allowedFieldIds': allowedFieldIds,
    'deniedFieldIds': deniedFieldIds,
    'supportCaseIds': supportCaseIds,
    'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
    'androidProofCaseIds': androidProofCaseIds,
    'warningReasons': warningReasons,
    'proofLimitReasons': proofLimitReasons,
    'futurePrerequisites': futurePrerequisites,
    'blockedBoundaryIds': blockedBoundaryIds,
    'safetyFlags': safetyFlags,
    'violationReasons': violationReasons,
    'recommendation': recommendation.wire,
  };
}

class DebugBridgePrototypeDesignReadinessGateFinding {
  const DebugBridgePrototypeDesignReadinessGateFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.gateRecordId,
    this.sourceValidationRowId,
    this.groupId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final DebugBridgePrototypeDesignReadinessGateSeverity severity;
  final String message;
  final String? gateRecordId;
  final String? sourceValidationRowId;
  final DebugBridgePrototypeDesignReadinessGateGroupId? groupId;
  final String? fieldId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical => severity.isCritical;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'severity': severity.wire,
    'message': message,
    if (gateRecordId != null) 'gateRecordId': gateRecordId,
    if (sourceValidationRowId != null)
      'sourceValidationRowId': sourceValidationRowId,
    if (groupId != null) 'groupId': groupId!.wire,
    if (fieldId != null) 'fieldId': fieldId,
    if (caseId != null) 'caseId': caseId,
  };
}

class DebugBridgePrototypeDesignReadinessGateResult {
  const DebugBridgePrototypeDesignReadinessGateResult({
    required this.gateStatus,
    required this.sourceValidationStatus,
    required this.sourceDesignStatus,
    required this.sourceReadinessGateStatus,
    required this.readinessGroups,
    required this.readinessRecords,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalGateGroups,
    required this.totalGateRecords,
    required this.readinessApprovedCoreDesignCount,
    required this.constrainedContextDesignCount,
    required this.inactiveBlockedDesignCount,
    required this.inactiveFutureOnlyDesignCount,
    required this.approvedAllowedFieldCount,
    required this.deniedFieldCount,
    required this.stockfishRawUciPvDumpDeniedCount,
    required this.runtimeExecutionBlockedCount,
    required this.futureRequirementCount,
    required this.unsafeCount,
    required this.blockerCount,
    required this.criticalCount,
    required this.ownerProofQueueCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.safeForPhase33C,
    required this.phase33CRecommendation,
    this.developerOnly = true,
    this.debugBridgeRuntimeImplemented = false,
    this.executableDebugBridgePrototypeImplemented = false,
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

  final DebugBridgePrototypeDesignReadinessGateStatus gateStatus;
  final DebugOnlyBridgePrototypeDesignValidationStatus sourceValidationStatus;
  final DebugOnlyBridgePrototypeDesignStatus sourceDesignStatus;
  final DebugBridgeReadinessValidationGateStatus sourceReadinessGateStatus;
  final List<DebugBridgePrototypeDesignReadinessGateGroup> readinessGroups;
  final List<DebugBridgePrototypeDesignReadinessGateRecord> readinessRecords;
  final List<DebugBridgePrototypeDesignReadinessGateFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalGateGroups;
  final int totalGateRecords;
  final int readinessApprovedCoreDesignCount;
  final int constrainedContextDesignCount;
  final int inactiveBlockedDesignCount;
  final int inactiveFutureOnlyDesignCount;
  final int approvedAllowedFieldCount;
  final int deniedFieldCount;
  final int stockfishRawUciPvDumpDeniedCount;
  final int runtimeExecutionBlockedCount;
  final int futureRequirementCount;
  final int unsafeCount;
  final int blockerCount;
  final int criticalCount;
  final int ownerProofQueueCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final bool safeForPhase33C;
  final DebugBridgePrototypeDesignReadinessGatePhase33CRecommendation
  phase33CRecommendation;
  final bool developerOnly;
  final bool debugBridgeRuntimeImplemented;
  final bool executableDebugBridgePrototypeImplemented;
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
      gateStatus ==
          DebugBridgePrototypeDesignReadinessGateStatus
              .blockedByPrototypeDesignValidationFailure ||
      gateStatus ==
          DebugBridgePrototypeDesignReadinessGateStatus
              .blockedByPolicyBoundary ||
      gateStatus == DebugBridgePrototypeDesignReadinessGateStatus.invalid ||
      !safeForPhase33C ||
      unsafeCount > 0 ||
      criticalCount > 0 ||
      blockerCount > 0 ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafePrototypeDesignReadinessGatePolicyViolation =>
      gateStatus ==
          DebugBridgePrototypeDesignReadinessGateStatus
              .blockedByPolicyBoundary ||
      unsafeCount > 0 ||
      criticalCount > 0 ||
      readinessGroups.any((group) => group.hasUnsafeOutput) ||
      readinessRecords.any((record) => record.hasUnsafeOutput) ||
      validationFindings.any((finding) => finding.isCritical) ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId) ||
      debugBridgeRuntimeImplemented ||
      executableDebugBridgePrototypeImplemented ||
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

  DebugBridgePrototypeDesignReadinessGateGroup group(
    DebugBridgePrototypeDesignReadinessGateGroupId groupId,
  ) {
    return readinessGroups.singleWhere((group) => group.groupId == groupId);
  }

  DebugBridgePrototypeDesignReadinessGateRecord recordForRole(
    DebugBridgePrototypeDesignReadinessGateRole role,
  ) {
    return readinessRecords.singleWhere((record) => record.gateRole == role);
  }

  DebugBridgePrototypeDesignReadinessGateResult copyWith({
    DebugBridgePrototypeDesignReadinessGateStatus? gateStatus,
    DebugOnlyBridgePrototypeDesignValidationStatus? sourceValidationStatus,
    DebugOnlyBridgePrototypeDesignStatus? sourceDesignStatus,
    DebugBridgeReadinessValidationGateStatus? sourceReadinessGateStatus,
    List<DebugBridgePrototypeDesignReadinessGateGroup>? readinessGroups,
    List<DebugBridgePrototypeDesignReadinessGateRecord>? readinessRecords,
    List<DebugBridgePrototypeDesignReadinessGateFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalGateGroups,
    int? totalGateRecords,
    int? readinessApprovedCoreDesignCount,
    int? constrainedContextDesignCount,
    int? inactiveBlockedDesignCount,
    int? inactiveFutureOnlyDesignCount,
    int? approvedAllowedFieldCount,
    int? deniedFieldCount,
    int? stockfishRawUciPvDumpDeniedCount,
    int? runtimeExecutionBlockedCount,
    int? futureRequirementCount,
    int? unsafeCount,
    int? blockerCount,
    int? criticalCount,
    int? ownerProofQueueCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    bool? safeForPhase33C,
    DebugBridgePrototypeDesignReadinessGatePhase33CRecommendation?
    phase33CRecommendation,
    bool? developerOnly,
    bool? debugBridgeRuntimeImplemented,
    bool? executableDebugBridgePrototypeImplemented,
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
    return DebugBridgePrototypeDesignReadinessGateResult(
      gateStatus: gateStatus ?? this.gateStatus,
      sourceValidationStatus:
          sourceValidationStatus ?? this.sourceValidationStatus,
      sourceDesignStatus: sourceDesignStatus ?? this.sourceDesignStatus,
      sourceReadinessGateStatus:
          sourceReadinessGateStatus ?? this.sourceReadinessGateStatus,
      readinessGroups: readinessGroups ?? this.readinessGroups,
      readinessRecords: readinessRecords ?? this.readinessRecords,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalGateGroups: totalGateGroups ?? this.totalGateGroups,
      totalGateRecords: totalGateRecords ?? this.totalGateRecords,
      readinessApprovedCoreDesignCount:
          readinessApprovedCoreDesignCount ??
          this.readinessApprovedCoreDesignCount,
      constrainedContextDesignCount:
          constrainedContextDesignCount ?? this.constrainedContextDesignCount,
      inactiveBlockedDesignCount:
          inactiveBlockedDesignCount ?? this.inactiveBlockedDesignCount,
      inactiveFutureOnlyDesignCount:
          inactiveFutureOnlyDesignCount ?? this.inactiveFutureOnlyDesignCount,
      approvedAllowedFieldCount:
          approvedAllowedFieldCount ?? this.approvedAllowedFieldCount,
      deniedFieldCount: deniedFieldCount ?? this.deniedFieldCount,
      stockfishRawUciPvDumpDeniedCount:
          stockfishRawUciPvDumpDeniedCount ??
          this.stockfishRawUciPvDumpDeniedCount,
      runtimeExecutionBlockedCount:
          runtimeExecutionBlockedCount ?? this.runtimeExecutionBlockedCount,
      futureRequirementCount:
          futureRequirementCount ?? this.futureRequirementCount,
      unsafeCount: unsafeCount ?? this.unsafeCount,
      blockerCount: blockerCount ?? this.blockerCount,
      criticalCount: criticalCount ?? this.criticalCount,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      allowedFieldIds: allowedFieldIds ?? this.allowedFieldIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      safeForPhase33C: safeForPhase33C ?? this.safeForPhase33C,
      phase33CRecommendation:
          phase33CRecommendation ?? this.phase33CRecommendation,
      developerOnly: developerOnly ?? this.developerOnly,
      debugBridgeRuntimeImplemented:
          debugBridgeRuntimeImplemented ?? this.debugBridgeRuntimeImplemented,
      executableDebugBridgePrototypeImplemented:
          executableDebugBridgePrototypeImplemented ??
          this.executableDebugBridgePrototypeImplemented,
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
      ..writeln('# Debug Bridge Prototype Design Readiness Gate')
      ..writeln()
      ..writeln(
        '- version: $debugBridgePrototypeDesignReadinessGateReportVersion',
      )
      ..writeln('- gate status: ${gateStatus.wire}')
      ..writeln('- source validation status: ${sourceValidationStatus.wire}')
      ..writeln('- source design status: ${sourceDesignStatus.wire}')
      ..writeln('- total gate groups: $totalGateGroups')
      ..writeln('- total gate records: $totalGateRecords')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln(
        '- debug bridge runtime implemented: $debugBridgeRuntimeImplemented',
      )
      ..writeln(
        '- executable debug bridge prototype implemented: '
        '$executableDebugBridgePrototypeImplemented',
      )
      ..writeln('- safeForPhase33C: $safeForPhase33C')
      ..writeln('- Phase 33C recommendation: ${phase33CRecommendation.wire}')
      ..writeln()
      ..writeln('## Readiness Group Table')
      ..writeln(
        '| Group | Status | Allowed fields | Denied fields | Design-only | Safe | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
    for (final group in readinessGroups) {
      buffer.writeln(
        '| ${group.groupId.wire} | ${group.gateStatus.wire} | '
        '${_ids(group.allowedFieldIds)} | ${_ids(group.deniedFieldIds)} | '
        '${group.designOnly} | ${group.safeForPhase33C} | '
        '${group.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Readiness Record Table')
      ..writeln(
        '| Record | Role | Status | Allowed fields | Denied fields | Design-only | Context-only | Inactive | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- | --- |');
    for (final record in readinessRecords) {
      buffer.writeln(
        '| ${_cell(record.gateRecordId)} | ${record.gateRole.wire} | '
        '${record.gateStatus.wire} | ${_ids(record.allowedFieldIds)} | '
        '${_ids(record.deniedFieldIds)} | ${record.designOnly} | '
        '${record.contextOnly} | ${record.inactive} | '
        '${record.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Prototype Core Design Readiness')
      ..writeln(
        '- readiness-approved core design records: '
        '$readinessApprovedCoreDesignCount',
      )
      ..writeln()
      ..writeln('## Context-Only Design Readiness')
      ..writeln(
        '- constrained context design records: $constrainedContextDesignCount',
      )
      ..writeln()
      ..writeln('## Inactive Blocked/Future Readiness')
      ..writeln(
        '- inactive blocked design records: $inactiveBlockedDesignCount',
      )
      ..writeln(
        '- inactive future-only design records: $inactiveFutureOnlyDesignCount',
      )
      ..writeln()
      ..writeln('## Allowed And Denied Field Readiness')
      ..writeln('- allowed fields: ${_ids(allowedFieldIds)}')
      ..writeln('- denied fields: ${_ids(deniedFieldIds)}')
      ..writeln()
      ..writeln('## Stockfish Raw UCI PV Dump Denied Status')
      ..writeln(
        '- stockfishCommand denied: ${deniedFieldIds.contains('stockfishCommand')}',
      )
      ..writeln('- rawUci denied: ${deniedFieldIds.contains('rawUci')}')
      ..writeln('- pvDump denied: ${deniedFieldIds.contains('pvDump')}')
      ..writeln()
      ..writeln('## Runtime/Executable Prototype Blocked Status')
      ..writeln(
        '- runtime execution blocked records: $runtimeExecutionBlockedCount',
      )
      ..writeln(
        '- executable prototype implemented: '
        '$executableDebugBridgePrototypeImplemented',
      )
      ..writeln()
      ..writeln('## Android Proof Boundary')
      ..writeln('- android proof IDs: ${_ids(androidProofCaseIds)}')
      ..writeln()
      ..writeln('## Owner Proof Boundary')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Phase 33C Requirement')
      ..writeln('- future checkpoint records: $futureRequirementCount')
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
      ..writeln('## Phase 33C Recommendation')
      ..writeln('- ${phase33CRecommendation.wire}');
    return buffer.toString();
  }

  String renderJsonReport() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'version': debugBridgePrototypeDesignReadinessGateReportVersion,
    'gateStatus': gateStatus.wire,
    'sourceValidationStatus': sourceValidationStatus.wire,
    'sourceDesignStatus': sourceDesignStatus.wire,
    'sourceReadinessGateStatus': sourceReadinessGateStatus.wire,
    'totalGateGroups': totalGateGroups,
    'totalGateRecords': totalGateRecords,
    'readinessApprovedCoreDesignCount': readinessApprovedCoreDesignCount,
    'constrainedContextDesignCount': constrainedContextDesignCount,
    'inactiveBlockedDesignCount': inactiveBlockedDesignCount,
    'inactiveFutureOnlyDesignCount': inactiveFutureOnlyDesignCount,
    'approvedAllowedFieldCount': approvedAllowedFieldCount,
    'deniedFieldCount': deniedFieldCount,
    'stockfishRawUciPvDumpDeniedCount': stockfishRawUciPvDumpDeniedCount,
    'runtimeExecutionBlockedCount': runtimeExecutionBlockedCount,
    'futureRequirementCount': futureRequirementCount,
    'unsafeCount': unsafeCount,
    'blockerCount': blockerCount,
    'criticalCount': criticalCount,
    'ownerProofQueueCount': ownerProofQueueCount,
    'supportCaseIds': supportCaseIds,
    'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
    'androidProofCaseIds': androidProofCaseIds,
    'allowedFieldIds': allowedFieldIds,
    'deniedFieldIds': deniedFieldIds,
    'safeForPhase33C': safeForPhase33C,
    'phase33CRecommendation': phase33CRecommendation.wire,
    'readinessGroups': readinessGroups.map((group) => group.toJson()).toList(),
    'readinessRecords': readinessRecords
        .map((record) => record.toJson())
        .toList(),
    'findings': validationFindings.map((finding) => finding.toJson()).toList(),
    'warnings': warnings,
    'failures': failures,
    'developerOnly': developerOnly,
    'debugBridgeRuntimeImplemented': debugBridgeRuntimeImplemented,
    'executableDebugBridgePrototypeImplemented':
        executableDebugBridgePrototypeImplemented,
    'futurePhase33CRequirementPresent': futureRequirementCount == 1,
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

class DebugBridgePrototypeDesignReadinessGate {
  const DebugBridgePrototypeDesignReadinessGate({
    this.validator = const DebugBridgePrototypeDesignReadinessGateValidator(),
  });

  final DebugBridgePrototypeDesignReadinessGateValidator validator;

  DebugBridgePrototypeDesignReadinessGateResult evaluate([
    DebugBridgePrototypeDesignReadinessGateRequest request =
        const DebugBridgePrototypeDesignReadinessGateRequest(),
  ]) {
    final gateResult =
        request.gateResult ??
        request.gate.evaluate(
          const DebugBridgeReadinessValidationGateRequest.safeDemo(),
        );
    final designResult =
        request.designResult ??
        request.prototypeDesign.evaluate(
          DebugOnlyBridgePrototypeDesignRequest(gateResult: gateResult),
        );
    final validationResult =
        request.validationResult ??
        request.validation.evaluate(
          DebugOnlyBridgePrototypeDesignValidationRequest(
            designResult: designResult,
            gateResult: gateResult,
            validationResult: request.summaryValidationResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final records = _recordsFromValidation(validationResult);
    final groups = _groupsFromRecords(records);
    final unsafeCount =
        validationResult.unsafeRecordCount +
        records.where((record) => record.hasUnsafeOutput).length;
    final base = DebugBridgePrototypeDesignReadinessGateResult(
      gateStatus: _initialGateStatusFor(validationResult),
      sourceValidationStatus: validationResult.validationStatus,
      sourceDesignStatus: validationResult.sourceDesignStatus,
      sourceReadinessGateStatus: validationResult.sourceGateStatus,
      readinessGroups: groups,
      readinessRecords: records,
      validationFindings:
          const <DebugBridgePrototypeDesignReadinessGateFinding>[],
      warnings: _sortedStrings(validationResult.warnings),
      failures: _sortedStrings(validationResult.failures),
      totalGateGroups: groups.length,
      totalGateRecords: records.length,
      readinessApprovedCoreDesignCount: _countRole(
        records,
        DebugBridgePrototypeDesignReadinessGateRole
            .readinessApprovedPrototypeCoreDesign,
      ),
      constrainedContextDesignCount: _countRole(
        records,
        DebugBridgePrototypeDesignReadinessGateRole
            .constrainedPrototypeContextDesign,
      ),
      inactiveBlockedDesignCount: _countRole(
        records,
        DebugBridgePrototypeDesignReadinessGateRole
            .inactivePrototypeBlockedDesign,
      ),
      inactiveFutureOnlyDesignCount: _countRole(
        records,
        DebugBridgePrototypeDesignReadinessGateRole
            .inactivePrototypeFutureOnlyDesign,
      ),
      approvedAllowedFieldCount: validationResult.allowedFieldIds.length,
      deniedFieldCount: validationResult.deniedFieldIds.length,
      stockfishRawUciPvDumpDeniedCount: _engineDumpFieldIds
          .where(validationResult.deniedFieldIds.contains)
          .length,
      runtimeExecutionBlockedCount: _countRole(
        records,
        DebugBridgePrototypeDesignReadinessGateRole.runtimeExecutionBlocked,
      ),
      futureRequirementCount: _countRole(
        records,
        DebugBridgePrototypeDesignReadinessGateRole.futurePhase33CRequirement,
      ),
      unsafeCount: unsafeCount,
      blockerCount: validationResult.blockerCount,
      criticalCount: validationResult.criticalCount,
      ownerProofQueueCount: validationResult.ownerProofQueueCount,
      supportCaseIds: validationResult.supportCaseIds,
      newlyAddedSupportCaseIds: validationResult.newlyAddedSupportCaseIds,
      androidProofCaseIds: validationResult.androidProofCaseIds,
      allowedFieldIds: validationResult.allowedFieldIds,
      deniedFieldIds: validationResult.deniedFieldIds,
      safeForPhase33C: validationResult.safeForPhase33B,
      phase33CRecommendation:
          DebugBridgePrototypeDesignReadinessGatePhase33CRecommendation
              .proceedToDebugBridgePrototypeDesignReadinessSummary,
      developerOnly: true,
      debugBridgeRuntimeImplemented:
          validationResult.debugBridgeRuntimeImplemented,
      executableDebugBridgePrototypeImplemented:
          validationResult.executableDebugBridgePrototypeImplemented,
      productOutputActive: validationResult.productOutputActive,
      classifierOutputActive: validationResult.classifierOutputActive,
      finalMoveLabelOutputActive: validationResult.finalMoveLabelOutputActive,
      officialMetricOutputActive: validationResult.officialMetricOutputActive,
      cpLossOutputActive: validationResult.cpLossOutputActive,
      winProbabilityOutputActive: validationResult.winProbabilityOutputActive,
      numericOutputActive: validationResult.numericOutputActive,
      aggregateScoreOutputActive: validationResult.aggregateScoreOutputActive,
      moveRankingOutputActive: validationResult.moveRankingOutputActive,
      quietPreparatoryScopeActivated:
          validationResult.quietPreparatoryScopeActivated,
      engineCallsActive: validationResult.engineCallsActive,
      persistenceWritesActive: validationResult.persistenceWritesActive,
      uiTargetsActive: validationResult.uiTargetsActive,
      backendOutputActive: validationResult.backendOutputActive,
      stockfishCommandFieldActive: validationResult.stockfishCommandFieldActive,
      rawUciFieldActive: validationResult.rawUciFieldActive,
      pvDumpFieldActive: validationResult.pvDumpFieldActive,
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    final blockerCount =
        validationResult.blockerCount +
        findings
            .where(
              (finding) =>
                  finding.severity ==
                  DebugBridgePrototypeDesignReadinessGateSeverity.blocker,
            )
            .length;
    final criticalCount =
        validationResult.criticalCount +
        findings
            .where(
              (finding) =>
                  finding.severity ==
                  DebugBridgePrototypeDesignReadinessGateSeverity.critical,
            )
            .length;
    final status = _gateStatusFor(
      base.copyWith(
        validationFindings: findings,
        blockerCount: blockerCount,
        criticalCount: criticalCount,
      ),
      validationResult,
    );
    final safeForPhase33C =
        (status ==
                DebugBridgePrototypeDesignReadinessGateStatus
                    .readyForNextInternalStepWithWarnings ||
            status ==
                DebugBridgePrototypeDesignReadinessGateStatus
                    .readyForNextInternalStepClean) &&
        validationResult.safeForPhase33B &&
        !validationResult.isStrictlyBlocked &&
        !validationResult
            .hasUnsafeDebugOnlyBridgePrototypeDesignValidationPolicyViolation &&
        unsafeCount == 0 &&
        blockerCount == 0 &&
        criticalCount == 0 &&
        findings.every((finding) => !finding.blocksStrict) &&
        groups.every((group) => group.safeForPhase33C) &&
        records.every((record) => !record.hasUnsafeOutput);
    return base.copyWith(
      gateStatus: status,
      validationFindings: findings,
      blockerCount: blockerCount,
      criticalCount: criticalCount,
      safeForPhase33C: safeForPhase33C,
      phase33CRecommendation: _phase33CRecommendationFor(
        status: status,
        safeForPhase33C: safeForPhase33C,
        ownerProofQueueCount: validationResult.ownerProofQueueCount,
      ),
    );
  }
}

class DebugBridgePrototypeDesignReadinessGateValidator {
  const DebugBridgePrototypeDesignReadinessGateValidator();

  List<DebugBridgePrototypeDesignReadinessGateFinding> validate(
    DebugBridgePrototypeDesignReadinessGateResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <DebugBridgePrototypeDesignReadinessGateFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required DebugBridgePrototypeDesignReadinessGateSeverity severity,
      required String message,
      String? gateRecordId,
      String? sourceValidationRowId,
      DebugBridgePrototypeDesignReadinessGateGroupId? groupId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        DebugBridgePrototypeDesignReadinessGateFinding(
          id: id,
          severity: severity,
          message: message,
          gateRecordId: gateRecordId,
          sourceValidationRowId: sourceValidationRowId,
          groupId: groupId,
          fieldId: fieldId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase33C &&
        (result.sourceValidationStatus ==
                DebugOnlyBridgePrototypeDesignValidationStatus
                    .blockedByUnsafePrototypeDesign ||
            result.sourceValidationStatus ==
                DebugOnlyBridgePrototypeDesignValidationStatus
                    .blockedByPolicyBoundary ||
            result.unsafeCount > 0)) {
      add(
        id: 'unsafePhase33AValidationMarkedReadinessApproved',
        severity: DebugBridgePrototypeDesignReadinessGateSeverity.critical,
        message: 'unsafe Phase 33A validation cannot be readiness-approved',
      );
    }
    if (result.futureRequirementCount != 1) {
      add(
        id: 'missingFuturePhase33CRequirement',
        severity: DebugBridgePrototypeDesignReadinessGateSeverity.critical,
        message: 'Phase 33C checkpoint requirement must be present',
      );
    }
    for (final fieldId in _deniedFieldIds) {
      if (!result.deniedFieldIds.contains(fieldId)) {
        add(
          id: 'deniedFieldMissing',
          severity: DebugBridgePrototypeDesignReadinessGateSeverity.blocker,
          message: '$fieldId must remain denied in prototype design readiness',
          fieldId: fieldId,
        );
      }
    }
    for (final fieldId in result.allowedFieldIds) {
      _checkActiveAllowedField(add, fieldId);
    }
    for (final proofId in result.androidProofCaseIds) {
      _checkAndroidProofCase(add, proofId, provenAndroidIds);
    }
    for (final group in result.readinessGroups) {
      for (final fieldId in group.allowedFieldIds) {
        _checkActiveAllowedField(add, fieldId, groupId: group.groupId);
      }
      for (final proofId in group.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          proofId,
          provenAndroidIds,
          groupId: group.groupId,
        );
      }
    }
    for (final record in result.readinessRecords) {
      for (final fieldId in record.allowedFieldIds) {
        _checkActiveAllowedField(
          add,
          fieldId,
          gateRecordId: record.gateRecordId,
          sourceValidationRowId: record.sourceValidationRowId,
        );
      }
      for (final proofId in record.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          proofId,
          provenAndroidIds,
          gateRecordId: record.gateRecordId,
          sourceValidationRowId: record.sourceValidationRowId,
        );
      }
      _checkRecordBoundary(add, record);
      _checkSafetyFlags(add, record);
    }
    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: DebugBridgePrototypeDesignReadinessGateSeverity.blocker,
        message: 'owner proof requires explicit PV/MultiPV reason',
      );
    }
    if (result.debugBridgeRuntimeImplemented ||
        result.executableDebugBridgePrototypeImplemented ||
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
        id: 'debugBridgePrototypeDesignReadinessGateBoundaryPolicyViolation',
        severity: DebugBridgePrototypeDesignReadinessGateSeverity.critical,
        message: 'debug bridge prototype design readiness crossed a boundary',
      );
    }
    return findings..sort(_compareFindings);
  }

  List<DebugBridgePrototypeDesignReadinessGateFinding> validateReportText(
    String reportText,
  ) {
    final findings = <DebugBridgePrototypeDesignReadinessGateFinding>[];
    void reportError(String id, String message) {
      findings.add(
        DebugBridgePrototypeDesignReadinessGateFinding(
          id: id,
          severity: DebugBridgePrototypeDesignReadinessGateSeverity.critical,
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
    for (final fieldId in _deniedFieldIds) {
      if (lower.contains('active fields: ${fieldId.toLowerCase()}') ||
          lower.contains('allowed fields: ${fieldId.toLowerCase()}')) {
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
    if (reportText.contains('runtime implemented: true') ||
        reportText.contains(
          'executable debug bridge prototype implemented: true',
        )) {
      reportError(
        'runtimeImplementationReportText',
        'report contains active runtime or executable prototype text',
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

List<DebugBridgePrototypeDesignReadinessGateRecord> _recordsFromValidation(
  DebugOnlyBridgePrototypeDesignValidationResult validationResult,
) {
  final records = <DebugBridgePrototypeDesignReadinessGateRecord>[
    _recordFromValidation(
      validationResult,
      DebugOnlyBridgePrototypeDesignRole.prototypeCoreInputDesignRecord,
      gateRole: DebugBridgePrototypeDesignReadinessGateRole
          .readinessApprovedPrototypeCoreDesign,
    ),
    _recordFromValidation(
      validationResult,
      DebugOnlyBridgePrototypeDesignRole.prototypeContextInputDesignRecord,
      gateRole: DebugBridgePrototypeDesignReadinessGateRole
          .constrainedPrototypeContextDesign,
    ),
    _recordFromValidation(
      validationResult,
      DebugOnlyBridgePrototypeDesignRole
          .prototypeInactiveBlockedInputDesignRecord,
      gateRole: DebugBridgePrototypeDesignReadinessGateRole
          .inactivePrototypeBlockedDesign,
    ),
    _recordFromValidation(
      validationResult,
      DebugOnlyBridgePrototypeDesignRole
          .prototypeInactiveFutureOnlyInputDesignRecord,
      gateRole: DebugBridgePrototypeDesignReadinessGateRole
          .inactivePrototypeFutureOnlyDesign,
    ),
    _recordFromValidation(
      validationResult,
      DebugOnlyBridgePrototypeDesignRole.prototypeAllowedFieldDesignRecord,
      gateRole: DebugBridgePrototypeDesignReadinessGateRole
          .readinessApprovedAllowedField,
    ),
    _recordFromValidation(
      validationResult,
      DebugOnlyBridgePrototypeDesignRole.prototypeDeniedFieldDesignRecord,
      gateRole: DebugBridgePrototypeDesignReadinessGateRole.deniedFieldBoundary,
    ),
    _recordFromValidation(
      validationResult,
      DebugOnlyBridgePrototypeDesignRole
          .stockfishRawUciPvDumpDeniedDesignRecord,
      gateRole: DebugBridgePrototypeDesignReadinessGateRole
          .stockfishRawUciPvDumpDenied,
    ),
    _recordFromValidation(
      validationResult,
      DebugOnlyBridgePrototypeDesignRole.androidProofBoundaryDesignRecord,
      gateRole:
          DebugBridgePrototypeDesignReadinessGateRole.androidProofBoundary,
    ),
    _recordFromValidation(
      validationResult,
      DebugOnlyBridgePrototypeDesignRole.ownerProofBoundaryDesignRecord,
      gateRole:
          DebugBridgePrototypeDesignReadinessGateRole.emptyOwnerProofBoundary,
    ),
    _runtimeBlockedRecord(),
    _futurePhase33CRequirementRecord(),
  ];
  return records;
}

DebugBridgePrototypeDesignReadinessGateRecord _recordFromValidation(
  DebugOnlyBridgePrototypeDesignValidationResult validationResult,
  DebugOnlyBridgePrototypeDesignRole role, {
  required DebugBridgePrototypeDesignReadinessGateRole gateRole,
}) {
  final row = validationResult.recordRowForRole(role);
  final sectionId = _sectionIdForDesignRole(role);
  final allowedForPlanning =
      gateRole ==
          DebugBridgePrototypeDesignReadinessGateRole
              .readinessApprovedPrototypeCoreDesign ||
      gateRole ==
          DebugBridgePrototypeDesignReadinessGateRole
              .readinessApprovedAllowedField;
  final inactive =
      row.inactive ||
      gateRole ==
          DebugBridgePrototypeDesignReadinessGateRole.deniedFieldBoundary ||
      gateRole ==
          DebugBridgePrototypeDesignReadinessGateRole
              .stockfishRawUciPvDumpDenied;
  return DebugBridgePrototypeDesignReadinessGateRecord(
    gateRecordId: 'phase33b-${gateRole.wire}',
    sourceValidationRowId: row.validationRowId,
    sourceDesignRecordId: row.sourceDesignRecordId,
    sourceDesignSectionId: sectionId.wire,
    gateRole: gateRole,
    gateStatus: _recordStatusForRole(gateRole),
    allowedForFutureInternalPrototypePlanning: allowedForPlanning,
    designOnly: row.designOnly,
    contextOnly: row.contextOnly,
    inactive: inactive,
    allowedFieldIds: _sortedStrings(row.allowedFieldIds),
    deniedFieldIds: _sortedStrings(row.deniedFieldIds),
    supportCaseIds: _sortedStrings(row.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(row.newlyAddedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(row.androidProofCaseIds),
    warningReasons: const <String>[],
    proofLimitReasons: const <String>[],
    futurePrerequisites: _futurePrerequisitesFor(gateRole),
    blockedBoundaryIds: _blockedBoundaryIdsFor(gateRole),
    safetyFlags: _safeFlagsFrom(row.safetyFlags),
    violationReasons: row.violationReasons,
    recommendation: _recommendationForRole(gateRole),
  );
}

DebugBridgePrototypeDesignReadinessGateRecord _runtimeBlockedRecord() {
  return DebugBridgePrototypeDesignReadinessGateRecord(
    gateRecordId: 'phase33b-runtimeExecutionBlocked',
    sourceValidationRowId: 'phase33b-runtimeExecutionBlocked',
    sourceDesignRecordId: 'phase33b-runtimeExecutionBlocked',
    sourceDesignSectionId: DebugBridgePrototypeDesignReadinessGateGroupId
        .runtimeExecutionBlockedGroup
        .wire,
    gateRole:
        DebugBridgePrototypeDesignReadinessGateRole.runtimeExecutionBlocked,
    gateStatus: DebugBridgePrototypeDesignReadinessGateRecordStatus
        .runtimeExecutionBlocked,
    allowedForFutureInternalPrototypePlanning: false,
    designOnly: true,
    contextOnly: false,
    inactive: true,
    allowedFieldIds: const <String>[],
    deniedFieldIds: const <String>[],
    supportCaseIds: const <String>[],
    newlyAddedSupportCaseIds: const <String>[],
    androidProofCaseIds: const <String>[],
    warningReasons: const <String>[
      'runtime bridge and executable prototype behavior remain blocked',
    ],
    proofLimitReasons: const <String>[],
    futurePrerequisites: const <String>[
      'explicit future runtime validation before implementation',
    ],
    blockedBoundaryIds: const <String>[
      'debugBridgeRuntime',
      'executableDebugBridgePrototype',
    ],
    safetyFlags: _safeRecordFlags,
    violationReasons: const <String>[],
    recommendation: DebugBridgePrototypeDesignReadinessGateRecommendation
        .keepRuntimeExecutionBlocked,
  );
}

DebugBridgePrototypeDesignReadinessGateRecord
_futurePhase33CRequirementRecord() {
  return DebugBridgePrototypeDesignReadinessGateRecord(
    gateRecordId: 'phase33b-futurePhase33CRequirement',
    sourceValidationRowId: 'phase33b-futurePhase33CRequirement',
    sourceDesignRecordId: 'phase33b-futurePhase33CRequirement',
    sourceDesignSectionId: DebugBridgePrototypeDesignReadinessGateGroupId
        .futurePhase33CRequirementGroup
        .wire,
    gateRole:
        DebugBridgePrototypeDesignReadinessGateRole.futurePhase33CRequirement,
    gateStatus: DebugBridgePrototypeDesignReadinessGateRecordStatus
        .futurePhase33CRequirement,
    allowedForFutureInternalPrototypePlanning: false,
    designOnly: true,
    contextOnly: false,
    inactive: false,
    allowedFieldIds: const <String>[],
    deniedFieldIds: const <String>[],
    supportCaseIds: const <String>[],
    newlyAddedSupportCaseIds: const <String>[],
    androidProofCaseIds: const <String>[],
    warningReasons: const <String>[
      'Phase 33C must checkpoint prototype design readiness before implementation design',
    ],
    proofLimitReasons: const <String>[],
    futurePrerequisites: const <String>[
      'phase33CPrototypeDesignReadinessSummaryOrImplementationDesignCheckpoint',
    ],
    blockedBoundaryIds: const <String>[],
    safetyFlags: _safeRecordFlags,
    violationReasons: const <String>[],
    recommendation: DebugBridgePrototypeDesignReadinessGateRecommendation
        .requirePhase33CCheckpoint,
  );
}

List<DebugBridgePrototypeDesignReadinessGateGroup> _groupsFromRecords(
  List<DebugBridgePrototypeDesignReadinessGateRecord> records,
) {
  return <DebugBridgePrototypeDesignReadinessGateGroup>[
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessGateRole
          .readinessApprovedPrototypeCoreDesign,
      groupId: DebugBridgePrototypeDesignReadinessGateGroupId
          .readinessApprovedPrototypeCoreDesignGroup,
      status: DebugBridgePrototypeDesignReadinessGateGroupStatus
          .readinessApprovedPrototypeCoreDesign,
      recommendation: DebugBridgePrototypeDesignReadinessGateRecommendation
          .approvePrototypeCoreDesignForPlanning,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessGateRole
          .constrainedPrototypeContextDesign,
      groupId: DebugBridgePrototypeDesignReadinessGateGroupId
          .constrainedPrototypeContextDesignGroup,
      status: DebugBridgePrototypeDesignReadinessGateGroupStatus
          .constrainedPrototypeContextDesign,
      recommendation: DebugBridgePrototypeDesignReadinessGateRecommendation
          .keepPrototypeContextConstrained,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessGateRole
          .inactivePrototypeBlockedDesign,
      groupId: DebugBridgePrototypeDesignReadinessGateGroupId
          .inactivePrototypeBlockedDesignGroup,
      status: DebugBridgePrototypeDesignReadinessGateGroupStatus
          .inactivePrototypeBlockedDesign,
      recommendation: DebugBridgePrototypeDesignReadinessGateRecommendation
          .keepPrototypeBlockedInactive,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessGateRole
          .inactivePrototypeFutureOnlyDesign,
      groupId: DebugBridgePrototypeDesignReadinessGateGroupId
          .inactivePrototypeFutureOnlyDesignGroup,
      status: DebugBridgePrototypeDesignReadinessGateGroupStatus
          .inactivePrototypeFutureOnlyDesign,
      recommendation: DebugBridgePrototypeDesignReadinessGateRecommendation
          .keepPrototypeFutureOnlyInactive,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessGateRole.readinessApprovedAllowedField,
      groupId: DebugBridgePrototypeDesignReadinessGateGroupId
          .readinessApprovedAllowedFieldGroup,
      status: DebugBridgePrototypeDesignReadinessGateGroupStatus
          .readinessApprovedAllowedField,
      recommendation: DebugBridgePrototypeDesignReadinessGateRecommendation
          .approveAllowedFieldsForPlanning,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessGateRole.deniedFieldBoundary,
      groupId: DebugBridgePrototypeDesignReadinessGateGroupId
          .deniedFieldBoundaryGroup,
      status: DebugBridgePrototypeDesignReadinessGateGroupStatus
          .deniedFieldBoundary,
      recommendation: DebugBridgePrototypeDesignReadinessGateRecommendation
          .keepDeniedFieldsDenied,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessGateRole.stockfishRawUciPvDumpDenied,
      groupId: DebugBridgePrototypeDesignReadinessGateGroupId
          .stockfishRawUciPvDumpDeniedGroup,
      status: DebugBridgePrototypeDesignReadinessGateGroupStatus
          .stockfishRawUciPvDumpDenied,
      recommendation: DebugBridgePrototypeDesignReadinessGateRecommendation
          .keepStockfishRawUciPvDumpDenied,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessGateRole.androidProofBoundary,
      groupId: DebugBridgePrototypeDesignReadinessGateGroupId
          .androidProofBoundaryGroup,
      status: DebugBridgePrototypeDesignReadinessGateGroupStatus
          .androidProofBoundary,
      recommendation: DebugBridgePrototypeDesignReadinessGateRecommendation
          .keepAndroidProofBoundaryCapturedOnly,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessGateRole.emptyOwnerProofBoundary,
      groupId: DebugBridgePrototypeDesignReadinessGateGroupId
          .emptyOwnerProofBoundaryGroup,
      status: DebugBridgePrototypeDesignReadinessGateGroupStatus
          .emptyOwnerProofBoundary,
      recommendation: DebugBridgePrototypeDesignReadinessGateRecommendation
          .keepOwnerProofEmpty,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessGateRole.runtimeExecutionBlocked,
      groupId: DebugBridgePrototypeDesignReadinessGateGroupId
          .runtimeExecutionBlockedGroup,
      status: DebugBridgePrototypeDesignReadinessGateGroupStatus
          .runtimeExecutionBlocked,
      recommendation: DebugBridgePrototypeDesignReadinessGateRecommendation
          .keepRuntimeExecutionBlocked,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessGateRole.futurePhase33CRequirement,
      groupId: DebugBridgePrototypeDesignReadinessGateGroupId
          .futurePhase33CRequirementGroup,
      status: DebugBridgePrototypeDesignReadinessGateGroupStatus
          .futurePhase33CRequirement,
      recommendation: DebugBridgePrototypeDesignReadinessGateRecommendation
          .requirePhase33CCheckpoint,
    ),
  ];
}

DebugBridgePrototypeDesignReadinessGateGroup _groupFromRole(
  List<DebugBridgePrototypeDesignReadinessGateRecord> records,
  DebugBridgePrototypeDesignReadinessGateRole role, {
  required DebugBridgePrototypeDesignReadinessGateGroupId groupId,
  required DebugBridgePrototypeDesignReadinessGateGroupStatus status,
  required DebugBridgePrototypeDesignReadinessGateRecommendation recommendation,
}) {
  final matching = records.where((record) => record.gateRole == role).toList();
  return DebugBridgePrototypeDesignReadinessGateGroup(
    groupId: groupId,
    gateStatus: status,
    sourceValidationRowIds: _sortedStrings(
      matching.map((record) => record.sourceValidationRowId),
    ),
    sourceDesignRecordIds: _sortedStrings(
      matching.map((record) => record.sourceDesignRecordId),
    ),
    sourceDesignSectionIds: _sortedStrings(
      matching.map((record) => record.sourceDesignSectionId),
    ),
    allowedFieldIds: _sortedStrings(
      matching.expand((record) => record.allowedFieldIds),
    ),
    deniedFieldIds: _sortedStrings(
      matching.expand((record) => record.deniedFieldIds),
    ),
    supportCaseIds: _sortedStrings(
      matching.expand((record) => record.supportCaseIds),
    ),
    newlyAddedSupportCaseIds: _sortedStrings(
      matching.expand((record) => record.newlyAddedSupportCaseIds),
    ),
    androidProofCaseIds: _sortedStrings(
      matching.expand((record) => record.androidProofCaseIds),
    ),
    warningReasons: _sortedStrings(
      matching.expand((record) => record.warningReasons),
    ),
    proofLimitReasons: _sortedStrings(
      matching.expand((record) => record.proofLimitReasons),
    ),
    futurePrerequisites: _sortedStrings(
      matching.expand((record) => record.futurePrerequisites),
    ),
    blockedBoundaryIds: _sortedStrings(
      matching.expand((record) => record.blockedBoundaryIds),
    ),
    designOnly: matching.every((record) => record.designOnly),
    safeForPhase33C: matching.every((record) => !record.hasUnsafeOutput),
    recommendation: recommendation,
  );
}

void _checkRecordBoundary(
  void Function({
    required String id,
    required DebugBridgePrototypeDesignReadinessGateSeverity severity,
    required String message,
    String? gateRecordId,
    String? sourceValidationRowId,
    DebugBridgePrototypeDesignReadinessGateGroupId? groupId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugBridgePrototypeDesignReadinessGateRecord record,
) {
  if (!record.designOnly) {
    add(
      id: 'prototypeDesignRecordNotDesignOnly',
      severity: DebugBridgePrototypeDesignReadinessGateSeverity.critical,
      message: 'prototype design readiness records must remain design-only',
      gateRecordId: record.gateRecordId,
      sourceValidationRowId: record.sourceValidationRowId,
    );
  }
  if (record.gateRole ==
      DebugBridgePrototypeDesignReadinessGateRole
          .readinessApprovedPrototypeCoreDesign) {
    if (record.contextOnly ||
        record.inactive ||
        record.sourceDesignSectionId !=
            DebugOnlyBridgePrototypeDesignSectionId
                .prototypeCoreInputDesign
                .wire ||
        record.violationReasons.contains('prototypeCoreConsumesNonCoreInput')) {
      add(
        id: 'prototypeCoreConsumesNonCoreInput',
        severity: DebugBridgePrototypeDesignReadinessGateSeverity.critical,
        message:
            'prototype core design readiness cannot consume non-core input',
        gateRecordId: record.gateRecordId,
        sourceValidationRowId: record.sourceValidationRowId,
      );
    }
  }
  if (record.gateRole ==
      DebugBridgePrototypeDesignReadinessGateRole
          .constrainedPrototypeContextDesign) {
    if (!record.contextOnly ||
        record.allowedForFutureInternalPrototypePlanning) {
      add(
        id: 'contextOnlyInputPromotedToCore',
        severity: DebugBridgePrototypeDesignReadinessGateSeverity.critical,
        message: 'context design readiness must remain context-only',
        gateRecordId: record.gateRecordId,
        sourceValidationRowId: record.sourceValidationRowId,
      );
    }
  }
  if (record.gateRole.isInactiveBoundary &&
      (!record.inactive || record.allowedFieldIds.isNotEmpty)) {
    add(
      id: 'blockedFutureDesignMadeActive',
      severity: DebugBridgePrototypeDesignReadinessGateSeverity.critical,
      message:
          'blocked, future-only, denied, and runtime-boundary records must stay inactive',
      gateRecordId: record.gateRecordId,
      sourceValidationRowId: record.sourceValidationRowId,
    );
  }
}

void _checkSafetyFlags(
  void Function({
    required String id,
    required DebugBridgePrototypeDesignReadinessGateSeverity severity,
    required String message,
    String? gateRecordId,
    String? sourceValidationRowId,
    DebugBridgePrototypeDesignReadinessGateGroupId? groupId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugBridgePrototypeDesignReadinessGateRecord record,
) {
  void critical(String id, String message) {
    add(
      id: id,
      severity: DebugBridgePrototypeDesignReadinessGateSeverity.critical,
      message: message,
      gateRecordId: record.gateRecordId,
      sourceValidationRowId: record.sourceValidationRowId,
    );
  }

  if (record.safetyFlags['isProductOutput'] == true) {
    critical('productOutputActive', 'readiness gate cannot be product output');
  }
  if (record.safetyFlags['isClassifierLabel'] == true) {
    critical(
      'classifierLabelOutputActive',
      'readiness gate cannot emit classifier labels',
    );
  }
  if (record.safetyFlags['hasNumericScore'] == true) {
    critical(
      'numericScoreOutputActive',
      'readiness gate cannot emit numeric scores',
    );
  }
  if (record.safetyFlags['hasAggregateScore'] == true) {
    critical(
      'aggregateScoreOutputActive',
      'readiness gate cannot emit aggregate scores',
    );
  }
  if (record.safetyFlags['ranksMoves'] == true) {
    critical('moveRankingOutputActive', 'readiness gate cannot rank moves');
  }
  if (record.safetyFlags['isOfficialMetric'] == true) {
    critical(
      'officialMetricOutputActive',
      'readiness gate cannot emit official metrics',
    );
  }
  if (record.safetyFlags['exposesCpLoss'] == true ||
      record.safetyFlags['exposesWinProbability'] == true) {
    critical(
      'futureMetricOutputActive',
      'readiness gate cannot expose CP-loss or win probability',
    );
  }
  if (record.safetyFlags['quietPreparatoryScopeActive'] == true) {
    critical(
      'quietPreparatoryScopeActivated',
      'quiet/preparatory scope must remain excluded',
    );
  }
  if (record.safetyFlags['callsEngine'] == true) {
    critical('engineCallFlagActive', 'readiness gate cannot call an engine');
  }
  if (record.safetyFlags['writesPersistence'] == true) {
    critical(
      'persistenceWriteFlagActive',
      'readiness gate cannot write persistence',
    );
  }
  if (record.safetyFlags['targetsUi'] == true) {
    critical('uiTargetFlagActive', 'readiness gate cannot target UI');
  }
  if (record.safetyFlags['backendOutputActive'] == true) {
    critical('backendOutputActive', 'readiness gate cannot target backend');
  }
  if (record.safetyFlags['exposesStockfishCommand'] == true ||
      record.safetyFlags['exposesRawUci'] == true ||
      record.safetyFlags['exposesPvDump'] == true) {
    critical(
      'stockfishRawUciPvDumpFieldActive',
      'Stockfish command, raw UCI, and PV dump fields must remain denied',
    );
  }
  if (record.safetyFlags['implementsRuntime'] == true) {
    critical(
      'runtimeImplementationFlagActive',
      'readiness gate cannot implement runtime behavior',
    );
  }
  if (record.safetyFlags['implementsPrototypeExecution'] == true) {
    critical(
      'executablePrototypeImplementationFlagActive',
      'readiness gate cannot implement executable prototype behavior',
    );
  }
}

void _checkActiveAllowedField(
  void Function({
    required String id,
    required DebugBridgePrototypeDesignReadinessGateSeverity severity,
    required String message,
    String? gateRecordId,
    String? sourceValidationRowId,
    DebugBridgePrototypeDesignReadinessGateGroupId? groupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String fieldId, {
  String? gateRecordId,
  String? sourceValidationRowId,
  DebugBridgePrototypeDesignReadinessGateGroupId? groupId,
}) {
  if (_isDeniedFieldId(fieldId) || _isLegacyDeniedFieldId(fieldId)) {
    add(
      id: 'activeDeniedField',
      severity: DebugBridgePrototypeDesignReadinessGateSeverity.critical,
      message: '$fieldId cannot be active readiness gate output',
      gateRecordId: gateRecordId,
      sourceValidationRowId: sourceValidationRowId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
}

void _checkAndroidProofCase(
  void Function({
    required String id,
    required DebugBridgePrototypeDesignReadinessGateSeverity severity,
    required String message,
    String? gateRecordId,
    String? sourceValidationRowId,
    DebugBridgePrototypeDesignReadinessGateGroupId? groupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String caseId,
  List<String> provenAndroidIds, {
  String? gateRecordId,
  String? sourceValidationRowId,
  DebugBridgePrototypeDesignReadinessGateGroupId? groupId,
}) {
  if (_phase32ECaseIds.contains(caseId)) {
    add(
      id: 'phase32ECaseTreatedAsCapturedProof',
      severity: DebugBridgePrototypeDesignReadinessGateSeverity.critical,
      message: '$caseId cannot be treated as captured Android proof',
      gateRecordId: gateRecordId,
      sourceValidationRowId: sourceValidationRowId,
      groupId: groupId,
      caseId: caseId,
    );
    return;
  }
  if (!_capturedAndroidProofIds.contains(caseId) ||
      !provenAndroidIds.contains(caseId)) {
    add(
      id: 'unprovenAndroidProofId',
      severity: DebugBridgePrototypeDesignReadinessGateSeverity.critical,
      message: '$caseId is not captured Android proof',
      gateRecordId: gateRecordId,
      sourceValidationRowId: sourceValidationRowId,
      groupId: groupId,
      caseId: caseId,
    );
  }
}

DebugBridgePrototypeDesignReadinessGateStatus _initialGateStatusFor(
  DebugOnlyBridgePrototypeDesignValidationResult validationResult,
) {
  if (validationResult.validationStatus ==
          DebugOnlyBridgePrototypeDesignValidationStatus
              .blockedByUnsafePrototypeDesign ||
      validationResult.validationStatus ==
          DebugOnlyBridgePrototypeDesignValidationStatus
              .blockedByPrototypeDesignMismatch ||
      !validationResult.safeForPhase33B) {
    return DebugBridgePrototypeDesignReadinessGateStatus
        .blockedByPrototypeDesignValidationFailure;
  }
  if (validationResult.validationStatus ==
      DebugOnlyBridgePrototypeDesignValidationStatus.blockedByPolicyBoundary) {
    return DebugBridgePrototypeDesignReadinessGateStatus
        .blockedByPolicyBoundary;
  }
  if (validationResult.validationStatus ==
      DebugOnlyBridgePrototypeDesignValidationStatus.validatedClean) {
    return DebugBridgePrototypeDesignReadinessGateStatus
        .readyForNextInternalStepClean;
  }
  return DebugBridgePrototypeDesignReadinessGateStatus
      .readyForNextInternalStepWithWarnings;
}

DebugBridgePrototypeDesignReadinessGateStatus _gateStatusFor(
  DebugBridgePrototypeDesignReadinessGateResult result,
  DebugOnlyBridgePrototypeDesignValidationResult validationResult,
) {
  if (result.debugBridgeRuntimeImplemented ||
      result.executableDebugBridgePrototypeImplemented ||
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
      result.allowedFieldIds.any(_isDeniedFieldId) ||
      result.allowedFieldIds.any(_isLegacyDeniedFieldId)) {
    return DebugBridgePrototypeDesignReadinessGateStatus
        .blockedByPolicyBoundary;
  }
  if (validationResult.validationStatus ==
          DebugOnlyBridgePrototypeDesignValidationStatus
              .blockedByUnsafePrototypeDesign ||
      validationResult.validationStatus ==
          DebugOnlyBridgePrototypeDesignValidationStatus
              .blockedByPrototypeDesignMismatch ||
      validationResult.validationStatus ==
          DebugOnlyBridgePrototypeDesignValidationStatus
              .blockedByPolicyBoundary ||
      validationResult.unsafeRecordCount > 0 ||
      validationResult.criticalCount > 0 ||
      validationResult
          .hasUnsafeDebugOnlyBridgePrototypeDesignValidationPolicyViolation ||
      result.unsafeCount > 0 ||
      result.criticalCount > 0) {
    return DebugBridgePrototypeDesignReadinessGateStatus
        .blockedByPrototypeDesignValidationFailure;
  }
  if (!validationResult.safeForPhase33B ||
      validationResult.isStrictlyBlocked ||
      result.blockerCount > 0 ||
      result.validationFindings.any((finding) => finding.blocksStrict) ||
      result.readinessGroups.any((group) => !group.safeForPhase33C) ||
      result.readinessRecords.any((record) => record.gateStatus.isInvalid)) {
    return DebugBridgePrototypeDesignReadinessGateStatus.invalid;
  }
  if (result.warnings.isNotEmpty) {
    return DebugBridgePrototypeDesignReadinessGateStatus
        .readyForNextInternalStepWithWarnings;
  }
  return DebugBridgePrototypeDesignReadinessGateStatus
      .readyForNextInternalStepClean;
}

DebugBridgePrototypeDesignReadinessGatePhase33CRecommendation
_phase33CRecommendationFor({
  required DebugBridgePrototypeDesignReadinessGateStatus status,
  required bool safeForPhase33C,
  required int ownerProofQueueCount,
}) {
  if (status ==
          DebugBridgePrototypeDesignReadinessGateStatus
              .blockedByPrototypeDesignValidationFailure ||
      status ==
          DebugBridgePrototypeDesignReadinessGateStatus
              .blockedByPolicyBoundary) {
    return DebugBridgePrototypeDesignReadinessGatePhase33CRecommendation
        .blockedByUnsafePrototypeDesignReadinessGate;
  }
  if (ownerProofQueueCount > 0) {
    return DebugBridgePrototypeDesignReadinessGatePhase33CRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase33C) {
    return DebugBridgePrototypeDesignReadinessGatePhase33CRecommendation
        .addMoreGoldenCoverageFirst;
  }
  return DebugBridgePrototypeDesignReadinessGatePhase33CRecommendation
      .proceedToDebugBridgePrototypeDesignReadinessSummary;
}

DebugOnlyBridgePrototypeDesignSectionId _sectionIdForDesignRole(
  DebugOnlyBridgePrototypeDesignRole role,
) {
  return switch (role) {
    DebugOnlyBridgePrototypeDesignRole.prototypeCoreInputDesignRecord =>
      DebugOnlyBridgePrototypeDesignSectionId.prototypeCoreInputDesign,
    DebugOnlyBridgePrototypeDesignRole.prototypeContextInputDesignRecord =>
      DebugOnlyBridgePrototypeDesignSectionId.prototypeContextInputDesign,
    DebugOnlyBridgePrototypeDesignRole
        .prototypeInactiveBlockedInputDesignRecord =>
      DebugOnlyBridgePrototypeDesignSectionId
          .prototypeInactiveBlockedInputDesign,
    DebugOnlyBridgePrototypeDesignRole
        .prototypeInactiveFutureOnlyInputDesignRecord =>
      DebugOnlyBridgePrototypeDesignSectionId
          .prototypeInactiveFutureOnlyInputDesign,
    DebugOnlyBridgePrototypeDesignRole.prototypeAllowedFieldDesignRecord =>
      DebugOnlyBridgePrototypeDesignSectionId.prototypeAllowedFieldDesign,
    DebugOnlyBridgePrototypeDesignRole.prototypeDeniedFieldDesignRecord =>
      DebugOnlyBridgePrototypeDesignSectionId.prototypeDeniedFieldDesign,
    DebugOnlyBridgePrototypeDesignRole
        .stockfishRawUciPvDumpDeniedDesignRecord =>
      DebugOnlyBridgePrototypeDesignSectionId.stockfishRawUciPvDumpDeniedDesign,
    DebugOnlyBridgePrototypeDesignRole.androidProofBoundaryDesignRecord =>
      DebugOnlyBridgePrototypeDesignSectionId.androidProofBoundaryDesign,
    DebugOnlyBridgePrototypeDesignRole.ownerProofBoundaryDesignRecord =>
      DebugOnlyBridgePrototypeDesignSectionId.ownerProofBoundaryDesign,
    DebugOnlyBridgePrototypeDesignRole.futureValidationRequirementRecord =>
      DebugOnlyBridgePrototypeDesignSectionId
          .futurePrototypeValidationRequirements,
  };
}

DebugBridgePrototypeDesignReadinessGateRecordStatus _recordStatusForRole(
  DebugBridgePrototypeDesignReadinessGateRole role,
) {
  return switch (role) {
    DebugBridgePrototypeDesignReadinessGateRole
        .readinessApprovedPrototypeCoreDesign =>
      DebugBridgePrototypeDesignReadinessGateRecordStatus
          .readinessApprovedPrototypeCoreDesign,
    DebugBridgePrototypeDesignReadinessGateRole
        .constrainedPrototypeContextDesign =>
      DebugBridgePrototypeDesignReadinessGateRecordStatus
          .constrainedPrototypeContextDesign,
    DebugBridgePrototypeDesignReadinessGateRole
        .inactivePrototypeBlockedDesign =>
      DebugBridgePrototypeDesignReadinessGateRecordStatus
          .inactivePrototypeBlockedDesign,
    DebugBridgePrototypeDesignReadinessGateRole
        .inactivePrototypeFutureOnlyDesign =>
      DebugBridgePrototypeDesignReadinessGateRecordStatus
          .inactivePrototypeFutureOnlyDesign,
    DebugBridgePrototypeDesignReadinessGateRole.readinessApprovedAllowedField =>
      DebugBridgePrototypeDesignReadinessGateRecordStatus
          .readinessApprovedAllowedField,
    DebugBridgePrototypeDesignReadinessGateRole.deniedFieldBoundary =>
      DebugBridgePrototypeDesignReadinessGateRecordStatus.deniedFieldBoundary,
    DebugBridgePrototypeDesignReadinessGateRole.stockfishRawUciPvDumpDenied =>
      DebugBridgePrototypeDesignReadinessGateRecordStatus
          .stockfishRawUciPvDumpDenied,
    DebugBridgePrototypeDesignReadinessGateRole.androidProofBoundary =>
      DebugBridgePrototypeDesignReadinessGateRecordStatus.androidProofBoundary,
    DebugBridgePrototypeDesignReadinessGateRole.emptyOwnerProofBoundary =>
      DebugBridgePrototypeDesignReadinessGateRecordStatus
          .emptyOwnerProofBoundary,
    DebugBridgePrototypeDesignReadinessGateRole.runtimeExecutionBlocked =>
      DebugBridgePrototypeDesignReadinessGateRecordStatus
          .runtimeExecutionBlocked,
    DebugBridgePrototypeDesignReadinessGateRole.futurePhase33CRequirement =>
      DebugBridgePrototypeDesignReadinessGateRecordStatus
          .futurePhase33CRequirement,
  };
}

DebugBridgePrototypeDesignReadinessGateRecommendation _recommendationForRole(
  DebugBridgePrototypeDesignReadinessGateRole role,
) {
  return switch (role) {
    DebugBridgePrototypeDesignReadinessGateRole
        .readinessApprovedPrototypeCoreDesign =>
      DebugBridgePrototypeDesignReadinessGateRecommendation
          .approvePrototypeCoreDesignForPlanning,
    DebugBridgePrototypeDesignReadinessGateRole
        .constrainedPrototypeContextDesign =>
      DebugBridgePrototypeDesignReadinessGateRecommendation
          .keepPrototypeContextConstrained,
    DebugBridgePrototypeDesignReadinessGateRole
        .inactivePrototypeBlockedDesign =>
      DebugBridgePrototypeDesignReadinessGateRecommendation
          .keepPrototypeBlockedInactive,
    DebugBridgePrototypeDesignReadinessGateRole
        .inactivePrototypeFutureOnlyDesign =>
      DebugBridgePrototypeDesignReadinessGateRecommendation
          .keepPrototypeFutureOnlyInactive,
    DebugBridgePrototypeDesignReadinessGateRole.readinessApprovedAllowedField =>
      DebugBridgePrototypeDesignReadinessGateRecommendation
          .approveAllowedFieldsForPlanning,
    DebugBridgePrototypeDesignReadinessGateRole.deniedFieldBoundary =>
      DebugBridgePrototypeDesignReadinessGateRecommendation
          .keepDeniedFieldsDenied,
    DebugBridgePrototypeDesignReadinessGateRole.stockfishRawUciPvDumpDenied =>
      DebugBridgePrototypeDesignReadinessGateRecommendation
          .keepStockfishRawUciPvDumpDenied,
    DebugBridgePrototypeDesignReadinessGateRole.androidProofBoundary =>
      DebugBridgePrototypeDesignReadinessGateRecommendation
          .keepAndroidProofBoundaryCapturedOnly,
    DebugBridgePrototypeDesignReadinessGateRole.emptyOwnerProofBoundary =>
      DebugBridgePrototypeDesignReadinessGateRecommendation.keepOwnerProofEmpty,
    DebugBridgePrototypeDesignReadinessGateRole.runtimeExecutionBlocked =>
      DebugBridgePrototypeDesignReadinessGateRecommendation
          .keepRuntimeExecutionBlocked,
    DebugBridgePrototypeDesignReadinessGateRole.futurePhase33CRequirement =>
      DebugBridgePrototypeDesignReadinessGateRecommendation
          .requirePhase33CCheckpoint,
  };
}

List<String> _futurePrerequisitesFor(
  DebugBridgePrototypeDesignReadinessGateRole role,
) {
  return switch (role) {
    DebugBridgePrototypeDesignReadinessGateRole.futurePhase33CRequirement =>
      const <String>[
        'phase33CPrototypeDesignReadinessSummaryOrImplementationDesignCheckpoint',
      ],
    DebugBridgePrototypeDesignReadinessGateRole.runtimeExecutionBlocked =>
      const <String>['explicit future validation before runtime work'],
    _ => const <String>[],
  };
}

List<String> _blockedBoundaryIdsFor(
  DebugBridgePrototypeDesignReadinessGateRole role,
) {
  return switch (role) {
    DebugBridgePrototypeDesignReadinessGateRole.deniedFieldBoundary =>
      _deniedFieldIds,
    DebugBridgePrototypeDesignReadinessGateRole.stockfishRawUciPvDumpDenied =>
      _engineDumpFieldIds,
    DebugBridgePrototypeDesignReadinessGateRole.runtimeExecutionBlocked =>
      const <String>['debugBridgeRuntime', 'executableDebugBridgePrototype'],
    _ => const <String>[],
  };
}

int _countRole(
  Iterable<DebugBridgePrototypeDesignReadinessGateRecord> records,
  DebugBridgePrototypeDesignReadinessGateRole role,
) {
  return records.where((record) => record.gateRole == role).length;
}

bool _hasExplicitPvProofReason(
  DebugBridgePrototypeDesignReadinessGateResult result,
) {
  final reasons = <String>[
    ...result.warnings,
    ...result.failures,
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
    'implementsRuntime': source['implementsRuntime'] ?? false,
    'implementsPrototypeExecution':
        source['implementsPrototypeExecution'] ?? false,
  };
}

List<String> _provenAndroidProofIds(GoldenAndroidProofEvidence? evidence) {
  return _sortedStrings(evidence?.targetCaseIds ?? const <String>[]);
}

int _compareFindings(
  DebugBridgePrototypeDesignReadinessGateFinding a,
  DebugBridgePrototypeDesignReadinessGateFinding b,
) {
  final severity = _severityRank(
    b.severity,
  ).compareTo(_severityRank(a.severity));
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.gateRecordId ?? '').compareTo(b.gateRecordId ?? '');
}

int _severityRank(DebugBridgePrototypeDesignReadinessGateSeverity severity) {
  return switch (severity) {
    DebugBridgePrototypeDesignReadinessGateSeverity.warning => 1,
    DebugBridgePrototypeDesignReadinessGateSeverity.blocker => 2,
    DebugBridgePrototypeDesignReadinessGateSeverity.critical => 3,
  };
}

bool _isDeniedFieldId(String value) {
  return _deniedFieldIds.contains(value);
}

bool _isLegacyDeniedFieldId(String value) {
  return _legacyDeniedFieldIds.contains(value);
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

const _safeRecordFlags = <String, bool>{
  'isProductOutput': false,
  'isClassifierLabel': false,
  'hasNumericScore': false,
  'hasAggregateScore': false,
  'ranksMoves': false,
  'isOfficialMetric': false,
  'exposesCpLoss': false,
  'exposesWinProbability': false,
  'exposesStockfishCommand': false,
  'exposesRawUci': false,
  'exposesPvDump': false,
  'callsEngine': false,
  'writesPersistence': false,
  'targetsUi': false,
  'backendOutputActive': false,
  'quietPreparatoryScopeActive': false,
  'implementsRuntime': false,
  'implementsPrototypeExecution': false,
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

const _deniedFieldIds = <String>[
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

const _legacyDeniedFieldIds = <String>[
  'uiOutputFields',
  'backendPersistenceFields',
  'directEngineCallFields',
];

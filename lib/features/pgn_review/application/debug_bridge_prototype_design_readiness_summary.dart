/// Developer-only summary for debug bridge prototype design readiness.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugBridgePrototypeDesignReadinessSummaryReportVersion =
    'debug-bridge-prototype-design-readiness-summary-v1';

enum DebugBridgePrototypeDesignReadinessSummaryStatus {
  summarizedWithWarnings('summarizedWithWarnings'),
  summarizedClean('summarizedClean'),
  blockedByUnsafeReadinessGate('blockedByUnsafeReadinessGate'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const DebugBridgePrototypeDesignReadinessSummaryStatus(this.wire);

  final String wire;
}

enum DebugBridgePrototypeDesignReadinessSummaryGroupId {
  readinessApprovedPrototypeCoreSummary(
    'readinessApprovedPrototypeCoreSummary',
  ),
  constrainedPrototypeContextSummary('constrainedPrototypeContextSummary'),
  inactivePrototypeBlockedSummary('inactivePrototypeBlockedSummary'),
  inactivePrototypeFutureOnlySummary('inactivePrototypeFutureOnlySummary'),
  approvedAllowedFieldSummary('approvedAllowedFieldSummary'),
  deniedFieldBoundarySummary('deniedFieldBoundarySummary'),
  stockfishRawUciPvDumpDeniedSummary('stockfishRawUciPvDumpDeniedSummary'),
  runtimeExecutionBlockedSummary('runtimeExecutionBlockedSummary'),
  androidProofBoundarySummary('androidProofBoundarySummary'),
  ownerProofBoundarySummary('ownerProofBoundarySummary'),
  futurePhase33DRequirementSummary('futurePhase33DRequirementSummary');

  const DebugBridgePrototypeDesignReadinessSummaryGroupId(this.wire);

  final String wire;
}

enum DebugBridgePrototypeDesignReadinessSummaryItemStatus {
  readinessApprovedPrototypeCoreSummary(
    'readinessApprovedPrototypeCoreSummary',
  ),
  constrainedPrototypeContextSummary('constrainedPrototypeContextSummary'),
  inactivePrototypeBlockedSummary('inactivePrototypeBlockedSummary'),
  inactivePrototypeFutureOnlySummary('inactivePrototypeFutureOnlySummary'),
  approvedAllowedFieldSummary('approvedAllowedFieldSummary'),
  deniedFieldBoundarySummary('deniedFieldBoundarySummary'),
  stockfishRawUciPvDumpDeniedSummary('stockfishRawUciPvDumpDeniedSummary'),
  runtimeExecutionBlockedSummary('runtimeExecutionBlockedSummary'),
  androidProofBoundarySummary('androidProofBoundarySummary'),
  ownerProofBoundarySummary('ownerProofBoundarySummary'),
  futurePhase33DRequirementSummary('futurePhase33DRequirementSummary'),
  invalidSummary('invalidSummary'),
  unsafeSummary('unsafeSummary');

  const DebugBridgePrototypeDesignReadinessSummaryItemStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == unsafeSummary;

  bool get isInvalid => this == invalidSummary;
}

enum DebugBridgePrototypeDesignReadinessSummaryRole {
  readinessApprovedPrototypeCoreSummaryRecord(
    'readinessApprovedPrototypeCoreSummaryRecord',
  ),
  constrainedPrototypeContextSummaryRecord(
    'constrainedPrototypeContextSummaryRecord',
  ),
  inactivePrototypeBlockedSummaryRecord(
    'inactivePrototypeBlockedSummaryRecord',
  ),
  inactivePrototypeFutureOnlySummaryRecord(
    'inactivePrototypeFutureOnlySummaryRecord',
  ),
  approvedAllowedFieldSummaryRecord('approvedAllowedFieldSummaryRecord'),
  deniedFieldBoundarySummaryRecord('deniedFieldBoundarySummaryRecord'),
  stockfishRawUciPvDumpDeniedSummaryRecord(
    'stockfishRawUciPvDumpDeniedSummaryRecord',
  ),
  runtimeExecutionBlockedSummaryRecord('runtimeExecutionBlockedSummaryRecord'),
  androidProofBoundarySummaryRecord('androidProofBoundarySummaryRecord'),
  ownerProofBoundarySummaryRecord('ownerProofBoundarySummaryRecord'),
  futurePhase33DRequirementSummaryRecord(
    'futurePhase33DRequirementSummaryRecord',
  );

  const DebugBridgePrototypeDesignReadinessSummaryRole(this.wire);

  final String wire;

  bool get isInactiveBoundary =>
      this == inactivePrototypeBlockedSummaryRecord ||
      this == inactivePrototypeFutureOnlySummaryRecord ||
      this == deniedFieldBoundarySummaryRecord ||
      this == stockfishRawUciPvDumpDeniedSummaryRecord ||
      this == runtimeExecutionBlockedSummaryRecord;
}

enum DebugBridgePrototypeDesignReadinessSummaryRecommendation {
  keepPrototypeCoreSummaryForPlanning('keepPrototypeCoreSummaryForPlanning'),
  keepPrototypeContextSummaryConstrained(
    'keepPrototypeContextSummaryConstrained',
  ),
  keepPrototypeBlockedSummaryInactive('keepPrototypeBlockedSummaryInactive'),
  keepPrototypeFutureOnlySummaryInactive(
    'keepPrototypeFutureOnlySummaryInactive',
  ),
  keepAllowedFieldSummarySafe('keepAllowedFieldSummarySafe'),
  keepDeniedFieldBoundaryDenied('keepDeniedFieldBoundaryDenied'),
  keepStockfishRawUciPvDumpDenied('keepStockfishRawUciPvDumpDenied'),
  keepRuntimeExecutionBlocked('keepRuntimeExecutionBlocked'),
  keepAndroidProofBoundaryCapturedOnly('keepAndroidProofBoundaryCapturedOnly'),
  keepOwnerProofBoundaryEmpty('keepOwnerProofBoundaryEmpty'),
  requirePhase33DCheckpoint('requirePhase33DCheckpoint'),
  investigatePrototypeDesignReadinessSummaryFailure(
    'investigatePrototypeDesignReadinessSummaryFailure',
  ),
  blockUnsafePrototypeDesignReadinessSummary(
    'blockUnsafePrototypeDesignReadinessSummary',
  );

  const DebugBridgePrototypeDesignReadinessSummaryRecommendation(this.wire);

  final String wire;
}

enum DebugBridgePrototypeDesignReadinessSummaryPhase33DRecommendation {
  proceedToDebugBridgePrototypeDesignReadinessSummaryValidation(
    'proceedToDebugBridgePrototypeDesignReadinessSummaryValidation',
  ),
  proceedToDebugOnlyBridgePrototypeImplementationDesignReadinessGate(
    'proceedToDebugOnlyBridgePrototypeImplementationDesignReadinessGate',
  ),
  proceedToPrototypeDesignSummaryReportOnly(
    'proceedToPrototypeDesignSummaryReportOnly',
  ),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafePrototypeDesignReadinessSummary(
    'blockedByUnsafePrototypeDesignReadinessSummary',
  );

  const DebugBridgePrototypeDesignReadinessSummaryPhase33DRecommendation(
    this.wire,
  );

  final String wire;
}

enum DebugBridgePrototypeDesignReadinessSummarySeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const DebugBridgePrototypeDesignReadinessSummarySeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == DebugBridgePrototypeDesignReadinessSummarySeverity.blocker ||
      this == DebugBridgePrototypeDesignReadinessSummarySeverity.critical;

  bool get isCritical =>
      this == DebugBridgePrototypeDesignReadinessSummarySeverity.critical;
}

enum DebugBridgePrototypeDesignReadinessSummaryReportFormat {
  markdown('markdown'),
  json('json');

  const DebugBridgePrototypeDesignReadinessSummaryReportFormat(this.wire);

  final String wire;
}

class DebugBridgePrototypeDesignReadinessSummaryRequest {
  const DebugBridgePrototypeDesignReadinessSummaryRequest({
    this.readinessGateResult,
    this.validationResult,
    this.designResult,
    this.bridgeReadinessGateResult,
    this.readinessGate = const DebugBridgePrototypeDesignReadinessGate(),
    this.validation = const DebugOnlyBridgePrototypeDesignValidation(),
    this.prototypeDesign = const DebugOnlyBridgePrototypeDesign(),
    this.bridgeReadinessGate = const DebugBridgeReadinessValidationGate(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const DebugBridgePrototypeDesignReadinessSummaryRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final DebugBridgePrototypeDesignReadinessGateResult? readinessGateResult;
  final DebugOnlyBridgePrototypeDesignValidationResult? validationResult;
  final DebugOnlyBridgePrototypeDesignResult? designResult;
  final DebugBridgeReadinessValidationGateResult? bridgeReadinessGateResult;
  final DebugBridgePrototypeDesignReadinessGate readinessGate;
  final DebugOnlyBridgePrototypeDesignValidation validation;
  final DebugOnlyBridgePrototypeDesign prototypeDesign;
  final DebugBridgeReadinessValidationGate bridgeReadinessGate;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class DebugBridgePrototypeDesignReadinessSummaryGroup {
  const DebugBridgePrototypeDesignReadinessSummaryGroup({
    required this.groupId,
    required this.summaryStatus,
    required this.sourceGateGroupIds,
    required this.sourceGateRecordIds,
    required this.sourceValidationRowIds,
    required this.sourceDesignRecordIds,
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
    required this.contextOnly,
    required this.inactive,
    required this.safeForPhase33D,
    required this.recommendation,
  });

  final DebugBridgePrototypeDesignReadinessSummaryGroupId groupId;
  final DebugBridgePrototypeDesignReadinessSummaryItemStatus summaryStatus;
  final List<DebugBridgePrototypeDesignReadinessGateGroupId> sourceGateGroupIds;
  final List<String> sourceGateRecordIds;
  final List<String> sourceValidationRowIds;
  final List<String> sourceDesignRecordIds;
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
  final bool contextOnly;
  final bool inactive;
  final bool safeForPhase33D;
  final DebugBridgePrototypeDesignReadinessSummaryRecommendation recommendation;

  bool get hasUnsafeOutput =>
      summaryStatus.isUnsafe ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId);

  Map<String, Object?> toJson() => <String, Object?>{
    'groupId': groupId.wire,
    'summaryStatus': summaryStatus.wire,
    'sourceGateGroupIds': sourceGateGroupIds.map((id) => id.wire).toList(),
    'sourceGateRecordIds': sourceGateRecordIds,
    'sourceValidationRowIds': sourceValidationRowIds,
    'sourceDesignRecordIds': sourceDesignRecordIds,
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
    'contextOnly': contextOnly,
    'inactive': inactive,
    'safeForPhase33D': safeForPhase33D,
    'recommendation': recommendation.wire,
  };
}

class DebugBridgePrototypeDesignReadinessSummaryRecord {
  const DebugBridgePrototypeDesignReadinessSummaryRecord({
    required this.summaryRecordId,
    required this.sourceGateRecordId,
    required this.sourceGateGroupId,
    required this.sourceValidationRowId,
    required this.sourceDesignRecordId,
    required this.summaryRole,
    required this.summaryStatus,
    required this.allowedForFutureInternalPlanning,
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

  final String summaryRecordId;
  final String sourceGateRecordId;
  final DebugBridgePrototypeDesignReadinessGateGroupId sourceGateGroupId;
  final String sourceValidationRowId;
  final String sourceDesignRecordId;
  final DebugBridgePrototypeDesignReadinessSummaryRole summaryRole;
  final DebugBridgePrototypeDesignReadinessSummaryItemStatus summaryStatus;
  final bool allowedForFutureInternalPlanning;
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
  final DebugBridgePrototypeDesignReadinessSummaryRecommendation recommendation;

  bool get hasUnsafeOutput =>
      summaryStatus.isUnsafe ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId) ||
      safetyFlags.values.any((value) => value);

  DebugBridgePrototypeDesignReadinessSummaryRecord copyWith({
    String? summaryRecordId,
    String? sourceGateRecordId,
    DebugBridgePrototypeDesignReadinessGateGroupId? sourceGateGroupId,
    String? sourceValidationRowId,
    String? sourceDesignRecordId,
    DebugBridgePrototypeDesignReadinessSummaryRole? summaryRole,
    DebugBridgePrototypeDesignReadinessSummaryItemStatus? summaryStatus,
    bool? allowedForFutureInternalPlanning,
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
    DebugBridgePrototypeDesignReadinessSummaryRecommendation? recommendation,
  }) {
    return DebugBridgePrototypeDesignReadinessSummaryRecord(
      summaryRecordId: summaryRecordId ?? this.summaryRecordId,
      sourceGateRecordId: sourceGateRecordId ?? this.sourceGateRecordId,
      sourceGateGroupId: sourceGateGroupId ?? this.sourceGateGroupId,
      sourceValidationRowId:
          sourceValidationRowId ?? this.sourceValidationRowId,
      sourceDesignRecordId: sourceDesignRecordId ?? this.sourceDesignRecordId,
      summaryRole: summaryRole ?? this.summaryRole,
      summaryStatus: summaryStatus ?? this.summaryStatus,
      allowedForFutureInternalPlanning:
          allowedForFutureInternalPlanning ??
          this.allowedForFutureInternalPlanning,
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
    'summaryRecordId': summaryRecordId,
    'sourceGateRecordId': sourceGateRecordId,
    'sourceGateGroupId': sourceGateGroupId.wire,
    'sourceValidationRowId': sourceValidationRowId,
    'sourceDesignRecordId': sourceDesignRecordId,
    'summaryRole': summaryRole.wire,
    'summaryStatus': summaryStatus.wire,
    'allowedForFutureInternalPlanning': allowedForFutureInternalPlanning,
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

class DebugBridgePrototypeDesignReadinessSummaryFinding {
  const DebugBridgePrototypeDesignReadinessSummaryFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.summaryRecordId,
    this.summaryGroupId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final DebugBridgePrototypeDesignReadinessSummarySeverity severity;
  final String message;
  final String? summaryRecordId;
  final DebugBridgePrototypeDesignReadinessSummaryGroupId? summaryGroupId;
  final String? fieldId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical => severity.isCritical;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'severity': severity.wire,
    'message': message,
    if (summaryRecordId != null) 'summaryRecordId': summaryRecordId,
    if (summaryGroupId != null) 'summaryGroupId': summaryGroupId!.wire,
    if (fieldId != null) 'fieldId': fieldId,
    if (caseId != null) 'caseId': caseId,
  };
}

class DebugBridgePrototypeDesignReadinessSummaryResult {
  const DebugBridgePrototypeDesignReadinessSummaryResult({
    required this.summaryStatus,
    required this.sourceReadinessGateStatus,
    required this.sourceValidationStatus,
    required this.sourceDesignStatus,
    required this.sourceBridgeReadinessValidationGateStatus,
    required this.summaryGroups,
    required this.summaryRecords,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalSummaryGroups,
    required this.totalSummaryRecords,
    required this.approvedCoreSummaryCount,
    required this.constrainedContextSummaryCount,
    required this.inactiveBlockedSummaryCount,
    required this.inactiveFutureOnlySummaryCount,
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
    required this.safeForPhase33D,
    required this.phase33DRecommendation,
    this.developerOnly = true,
    this.debugBridgeRuntimeImplemented = false,
    this.executableDebugBridgePrototypeImplemented = false,
    this.implementationWiringImplemented = false,
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

  final DebugBridgePrototypeDesignReadinessSummaryStatus summaryStatus;
  final DebugBridgePrototypeDesignReadinessGateStatus sourceReadinessGateStatus;
  final DebugOnlyBridgePrototypeDesignValidationStatus sourceValidationStatus;
  final DebugOnlyBridgePrototypeDesignStatus sourceDesignStatus;
  final DebugBridgeReadinessValidationGateStatus
  sourceBridgeReadinessValidationGateStatus;
  final List<DebugBridgePrototypeDesignReadinessSummaryGroup> summaryGroups;
  final List<DebugBridgePrototypeDesignReadinessSummaryRecord> summaryRecords;
  final List<DebugBridgePrototypeDesignReadinessSummaryFinding>
  validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalSummaryGroups;
  final int totalSummaryRecords;
  final int approvedCoreSummaryCount;
  final int constrainedContextSummaryCount;
  final int inactiveBlockedSummaryCount;
  final int inactiveFutureOnlySummaryCount;
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
  final bool safeForPhase33D;
  final DebugBridgePrototypeDesignReadinessSummaryPhase33DRecommendation
  phase33DRecommendation;
  final bool developerOnly;
  final bool debugBridgeRuntimeImplemented;
  final bool executableDebugBridgePrototypeImplemented;
  final bool implementationWiringImplemented;
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
      summaryStatus ==
          DebugBridgePrototypeDesignReadinessSummaryStatus
              .blockedByUnsafeReadinessGate ||
      summaryStatus ==
          DebugBridgePrototypeDesignReadinessSummaryStatus
              .blockedByPolicyBoundary ||
      summaryStatus ==
          DebugBridgePrototypeDesignReadinessSummaryStatus.invalid ||
      !safeForPhase33D ||
      unsafeCount > 0 ||
      criticalCount > 0 ||
      blockerCount > 0 ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeDebugBridgePrototypeDesignReadinessSummaryPolicyViolation =>
      summaryStatus ==
          DebugBridgePrototypeDesignReadinessSummaryStatus
              .blockedByUnsafeReadinessGate ||
      summaryStatus ==
          DebugBridgePrototypeDesignReadinessSummaryStatus
              .blockedByPolicyBoundary ||
      unsafeCount > 0 ||
      criticalCount > 0 ||
      summaryGroups.any((group) => group.hasUnsafeOutput) ||
      summaryRecords.any((record) => record.hasUnsafeOutput) ||
      validationFindings.any((finding) => finding.isCritical) ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId) ||
      debugBridgeRuntimeImplemented ||
      executableDebugBridgePrototypeImplemented ||
      implementationWiringImplemented ||
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

  DebugBridgePrototypeDesignReadinessSummaryGroup group(
    DebugBridgePrototypeDesignReadinessSummaryGroupId groupId,
  ) {
    return summaryGroups.singleWhere((group) => group.groupId == groupId);
  }

  DebugBridgePrototypeDesignReadinessSummaryRecord recordForRole(
    DebugBridgePrototypeDesignReadinessSummaryRole role,
  ) {
    return summaryRecords.singleWhere((record) => record.summaryRole == role);
  }

  List<DebugBridgePrototypeDesignReadinessSummaryRecord>
  get approvedCoreSummaryRecords => summaryRecords
      .where(
        (record) =>
            record.summaryRole ==
            DebugBridgePrototypeDesignReadinessSummaryRole
                .readinessApprovedPrototypeCoreSummaryRecord,
      )
      .toList(growable: false);

  List<DebugBridgePrototypeDesignReadinessSummaryRecord>
  get constrainedContextSummaryRecords => summaryRecords
      .where(
        (record) =>
            record.summaryRole ==
            DebugBridgePrototypeDesignReadinessSummaryRole
                .constrainedPrototypeContextSummaryRecord,
      )
      .toList(growable: false);

  List<DebugBridgePrototypeDesignReadinessSummaryRecord>
  get inactiveBoundaryRecords => summaryRecords
      .where((record) => record.summaryRole.isInactiveBoundary)
      .toList(growable: false);

  DebugBridgePrototypeDesignReadinessSummaryResult copyWith({
    DebugBridgePrototypeDesignReadinessSummaryStatus? summaryStatus,
    DebugBridgePrototypeDesignReadinessGateStatus? sourceReadinessGateStatus,
    DebugOnlyBridgePrototypeDesignValidationStatus? sourceValidationStatus,
    DebugOnlyBridgePrototypeDesignStatus? sourceDesignStatus,
    DebugBridgeReadinessValidationGateStatus?
    sourceBridgeReadinessValidationGateStatus,
    List<DebugBridgePrototypeDesignReadinessSummaryGroup>? summaryGroups,
    List<DebugBridgePrototypeDesignReadinessSummaryRecord>? summaryRecords,
    List<DebugBridgePrototypeDesignReadinessSummaryFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalSummaryGroups,
    int? totalSummaryRecords,
    int? approvedCoreSummaryCount,
    int? constrainedContextSummaryCount,
    int? inactiveBlockedSummaryCount,
    int? inactiveFutureOnlySummaryCount,
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
    bool? safeForPhase33D,
    DebugBridgePrototypeDesignReadinessSummaryPhase33DRecommendation?
    phase33DRecommendation,
    bool? developerOnly,
    bool? debugBridgeRuntimeImplemented,
    bool? executableDebugBridgePrototypeImplemented,
    bool? implementationWiringImplemented,
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
    return DebugBridgePrototypeDesignReadinessSummaryResult(
      summaryStatus: summaryStatus ?? this.summaryStatus,
      sourceReadinessGateStatus:
          sourceReadinessGateStatus ?? this.sourceReadinessGateStatus,
      sourceValidationStatus:
          sourceValidationStatus ?? this.sourceValidationStatus,
      sourceDesignStatus: sourceDesignStatus ?? this.sourceDesignStatus,
      sourceBridgeReadinessValidationGateStatus:
          sourceBridgeReadinessValidationGateStatus ??
          this.sourceBridgeReadinessValidationGateStatus,
      summaryGroups: summaryGroups ?? this.summaryGroups,
      summaryRecords: summaryRecords ?? this.summaryRecords,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalSummaryGroups: totalSummaryGroups ?? this.totalSummaryGroups,
      totalSummaryRecords: totalSummaryRecords ?? this.totalSummaryRecords,
      approvedCoreSummaryCount:
          approvedCoreSummaryCount ?? this.approvedCoreSummaryCount,
      constrainedContextSummaryCount:
          constrainedContextSummaryCount ?? this.constrainedContextSummaryCount,
      inactiveBlockedSummaryCount:
          inactiveBlockedSummaryCount ?? this.inactiveBlockedSummaryCount,
      inactiveFutureOnlySummaryCount:
          inactiveFutureOnlySummaryCount ?? this.inactiveFutureOnlySummaryCount,
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
      safeForPhase33D: safeForPhase33D ?? this.safeForPhase33D,
      phase33DRecommendation:
          phase33DRecommendation ?? this.phase33DRecommendation,
      developerOnly: developerOnly ?? this.developerOnly,
      debugBridgeRuntimeImplemented:
          debugBridgeRuntimeImplemented ?? this.debugBridgeRuntimeImplemented,
      executableDebugBridgePrototypeImplemented:
          executableDebugBridgePrototypeImplemented ??
          this.executableDebugBridgePrototypeImplemented,
      implementationWiringImplemented:
          implementationWiringImplemented ??
          this.implementationWiringImplemented,
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
      ..writeln('# Debug Bridge Prototype Design Readiness Summary')
      ..writeln()
      ..writeln(
        '- version: $debugBridgePrototypeDesignReadinessSummaryReportVersion',
      )
      ..writeln('- summary status: ${summaryStatus.wire}')
      ..writeln(
        '- source readiness gate status: ${sourceReadinessGateStatus.wire}',
      )
      ..writeln('- source validation status: ${sourceValidationStatus.wire}')
      ..writeln('- source design status: ${sourceDesignStatus.wire}')
      ..writeln('- total summary groups: $totalSummaryGroups')
      ..writeln('- total summary records: $totalSummaryRecords')
      ..writeln('- approved core summary count: $approvedCoreSummaryCount')
      ..writeln(
        '- constrained context summary count: $constrainedContextSummaryCount',
      )
      ..writeln(
        '- inactive blocked summary count: $inactiveBlockedSummaryCount',
      )
      ..writeln(
        '- inactive future-only summary count: $inactiveFutureOnlySummaryCount',
      )
      ..writeln('- approved allowed field count: $approvedAllowedFieldCount')
      ..writeln('- denied field count: $deniedFieldCount')
      ..writeln(
        '- Stockfish/raw UCI/PV dump denied count: $stockfishRawUciPvDumpDeniedCount',
      )
      ..writeln(
        '- runtime execution blocked count: $runtimeExecutionBlockedCount',
      )
      ..writeln('- future requirement count: $futureRequirementCount')
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
      ..writeln(
        '- implementation wiring implemented: $implementationWiringImplemented',
      )
      ..writeln('- safeForPhase33D: $safeForPhase33D')
      ..writeln('- Phase 33D recommendation: ${phase33DRecommendation.wire}')
      ..writeln()
      ..writeln('## Summary Group Table')
      ..writeln(
        '| Group | Status | Source gate records | Allowed fields | Denied fields | Design-only | Context-only | Inactive | Safe | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final group in summaryGroups) {
      buffer.writeln(
        '| ${group.groupId.wire} | ${group.summaryStatus.wire} | '
        '${_ids(group.sourceGateRecordIds)} | ${_ids(group.allowedFieldIds)} | '
        '${_ids(group.deniedFieldIds)} | ${group.designOnly} | '
        '${group.contextOnly} | ${group.inactive} | '
        '${group.safeForPhase33D} | ${group.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Summary Record Table')
      ..writeln(
        '| Record | Role | Status | Source gate group | Allowed fields | Denied fields | Design-only | Context-only | Inactive | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final record in summaryRecords) {
      buffer.writeln(
        '| ${_cell(record.summaryRecordId)} | ${record.summaryRole.wire} | '
        '${record.summaryStatus.wire} | ${record.sourceGateGroupId.wire} | '
        '${_ids(record.allowedFieldIds)} | ${_ids(record.deniedFieldIds)} | '
        '${record.designOnly} | ${record.contextOnly} | '
        '${record.inactive} | ${record.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Prototype Core Readiness Summary');
    for (final record in approvedCoreSummaryRecords) {
      buffer.writeln(
        '- ${record.summaryRecordId}: ${record.summaryStatus.wire}; '
        'future internal planning: ${record.allowedForFutureInternalPlanning}; '
        'designOnly: ${record.designOnly}',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Context-Only Readiness Summary');
    for (final record in constrainedContextSummaryRecords) {
      buffer.writeln(
        '- ${record.summaryRecordId}: ${record.summaryStatus.wire}; '
        'contextOnly: ${record.contextOnly}',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Inactive Blocked/Future Summary');
    for (final record in inactiveBoundaryRecords.where(
      (record) =>
          record.summaryRole ==
              DebugBridgePrototypeDesignReadinessSummaryRole
                  .inactivePrototypeBlockedSummaryRecord ||
          record.summaryRole ==
              DebugBridgePrototypeDesignReadinessSummaryRole
                  .inactivePrototypeFutureOnlySummaryRecord,
    )) {
      buffer.writeln(
        '- ${record.summaryRecordId}: ${record.summaryStatus.wire}; '
        'inactive: ${record.inactive}',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Allowed And Denied Field Summary')
      ..writeln('- allowed internal fields: ${_ids(allowedFieldIds)}')
      ..writeln('- denied fields: ${_ids(deniedFieldIds)}')
      ..writeln()
      ..writeln('## Stockfish Raw UCI PV Dump Denied Summary')
      ..writeln(
        '- stockfishCommand denied: ${deniedFieldIds.contains('stockfishCommand')}',
      )
      ..writeln('- rawUci denied: ${deniedFieldIds.contains('rawUci')}')
      ..writeln('- pvDump denied: ${deniedFieldIds.contains('pvDump')}')
      ..writeln()
      ..writeln('## Runtime/Executable Prototype/Wiring Blocked Status')
      ..writeln(
        '- debug bridge runtime implemented: $debugBridgeRuntimeImplemented',
      )
      ..writeln(
        '- executable debug bridge prototype implemented: '
        '$executableDebugBridgePrototypeImplemented',
      )
      ..writeln(
        '- implementation wiring implemented: $implementationWiringImplemented',
      )
      ..writeln()
      ..writeln('## Android Proof Boundary')
      ..writeln('- android proof IDs: ${_ids(androidProofCaseIds)}')
      ..writeln()
      ..writeln('## Owner Proof Boundary')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Phase 33D Requirement')
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
      ..writeln('## Phase 33D Recommendation')
      ..writeln('- ${phase33DRecommendation.wire}');
    return buffer.toString();
  }

  String renderJsonReport() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'version': debugBridgePrototypeDesignReadinessSummaryReportVersion,
    'summaryStatus': summaryStatus.wire,
    'sourceReadinessGateStatus': sourceReadinessGateStatus.wire,
    'sourceValidationStatus': sourceValidationStatus.wire,
    'sourceDesignStatus': sourceDesignStatus.wire,
    'sourceBridgeReadinessValidationGateStatus':
        sourceBridgeReadinessValidationGateStatus.wire,
    'totalSummaryGroups': totalSummaryGroups,
    'totalSummaryRecords': totalSummaryRecords,
    'approvedCoreSummaryCount': approvedCoreSummaryCount,
    'constrainedContextSummaryCount': constrainedContextSummaryCount,
    'inactiveBlockedSummaryCount': inactiveBlockedSummaryCount,
    'inactiveFutureOnlySummaryCount': inactiveFutureOnlySummaryCount,
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
    'safeForPhase33D': safeForPhase33D,
    'phase33DRecommendation': phase33DRecommendation.wire,
    'summaryGroups': summaryGroups.map((group) => group.toJson()).toList(),
    'summaryRecords': summaryRecords.map((record) => record.toJson()).toList(),
    'findings': validationFindings.map((finding) => finding.toJson()).toList(),
    'warnings': warnings,
    'failures': failures,
    'developerOnly': developerOnly,
    'debugBridgeRuntimeImplemented': debugBridgeRuntimeImplemented,
    'executableDebugBridgePrototypeImplemented':
        executableDebugBridgePrototypeImplemented,
    'implementationWiringImplemented': implementationWiringImplemented,
    'futurePhase33DRequirementPresent': futureRequirementCount == 1,
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

class DebugBridgePrototypeDesignReadinessSummary {
  const DebugBridgePrototypeDesignReadinessSummary({
    this.validator =
        const DebugBridgePrototypeDesignReadinessSummaryValidator(),
  });

  final DebugBridgePrototypeDesignReadinessSummaryValidator validator;

  DebugBridgePrototypeDesignReadinessSummaryResult evaluate([
    DebugBridgePrototypeDesignReadinessSummaryRequest request =
        const DebugBridgePrototypeDesignReadinessSummaryRequest(),
  ]) {
    final bridgeGateResult =
        request.bridgeReadinessGateResult ??
        request.bridgeReadinessGate.evaluate(
          DebugBridgeReadinessValidationGateRequest(
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final designResult =
        request.designResult ??
        request.prototypeDesign.evaluate(
          DebugOnlyBridgePrototypeDesignRequest(
            gateResult: bridgeGateResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final validationResult =
        request.validationResult ??
        request.validation.evaluate(
          DebugOnlyBridgePrototypeDesignValidationRequest(
            designResult: designResult,
            gateResult: bridgeGateResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final readinessGateResult =
        request.readinessGateResult ??
        request.readinessGate.evaluate(
          DebugBridgePrototypeDesignReadinessGateRequest(
            validationResult: validationResult,
            designResult: designResult,
            gateResult: bridgeGateResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final summaryRecords = _recordsFromReadinessGate(readinessGateResult);
    final summaryGroups = _groupsFromRecords(summaryRecords);
    final base = _resultFromRecords(
      readinessGateResult: readinessGateResult,
      validationResult: validationResult,
      designResult: designResult,
      bridgeReadinessGateResult: bridgeGateResult,
      summaryGroups: summaryGroups,
      summaryRecords: summaryRecords,
      validationFindings:
          const <DebugBridgePrototypeDesignReadinessSummaryFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromRecords(
      readinessGateResult: readinessGateResult,
      validationResult: validationResult,
      designResult: designResult,
      bridgeReadinessGateResult: bridgeGateResult,
      summaryGroups: summaryGroups,
      summaryRecords: summaryRecords,
      validationFindings: findings,
    );
  }
}

class DebugBridgePrototypeDesignReadinessSummaryValidator {
  const DebugBridgePrototypeDesignReadinessSummaryValidator();

  List<DebugBridgePrototypeDesignReadinessSummaryFinding> validate(
    DebugBridgePrototypeDesignReadinessSummaryResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <DebugBridgePrototypeDesignReadinessSummaryFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required DebugBridgePrototypeDesignReadinessSummarySeverity severity,
      required String message,
      String? summaryRecordId,
      DebugBridgePrototypeDesignReadinessSummaryGroupId? summaryGroupId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        DebugBridgePrototypeDesignReadinessSummaryFinding(
          id: id,
          severity: severity,
          message: message,
          summaryRecordId: summaryRecordId,
          summaryGroupId: summaryGroupId,
          fieldId: fieldId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase33D &&
        (result.sourceReadinessGateStatus ==
                DebugBridgePrototypeDesignReadinessGateStatus
                    .blockedByPrototypeDesignValidationFailure ||
            result.sourceReadinessGateStatus ==
                DebugBridgePrototypeDesignReadinessGateStatus
                    .blockedByPolicyBoundary ||
            result.unsafeCount > 0)) {
      add(
        id: 'unsafePhase33BReadinessGateMarkedSummarized',
        severity: DebugBridgePrototypeDesignReadinessSummarySeverity.critical,
        message: 'unsafe Phase 33B readiness gate cannot be summarized',
      );
    }
    if (result.futureRequirementCount != 1) {
      add(
        id: 'missingFuturePhase33DRequirement',
        severity: DebugBridgePrototypeDesignReadinessSummarySeverity.critical,
        message: 'Phase 33D checkpoint requirement must be present',
      );
    }

    for (final fieldId in _deniedFieldIds) {
      if (!result.deniedFieldIds.contains(fieldId)) {
        add(
          id: 'deniedFieldMissing',
          severity: DebugBridgePrototypeDesignReadinessSummarySeverity.blocker,
          message: '$fieldId must remain denied in prototype readiness summary',
          fieldId: fieldId,
        );
      }
    }
    for (final fieldId in result.allowedFieldIds) {
      _checkAllowedField(add, fieldId);
    }
    for (final caseId in result.androidProofCaseIds) {
      _checkAndroidProofCase(add, caseId, provenAndroidIds);
    }
    for (final group in result.summaryGroups) {
      for (final fieldId in group.allowedFieldIds) {
        _checkAllowedField(add, fieldId, summaryGroupId: group.groupId);
      }
      for (final caseId in group.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          summaryGroupId: group.groupId,
        );
      }
    }
    for (final record in result.summaryRecords) {
      for (final fieldId in record.allowedFieldIds) {
        _checkAllowedField(
          add,
          fieldId,
          summaryRecordId: record.summaryRecordId,
        );
      }
      for (final caseId in record.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          summaryRecordId: record.summaryRecordId,
        );
      }
      _checkRecordBoundary(add, record);
      _checkSafetyFlags(add, record);
    }
    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: DebugBridgePrototypeDesignReadinessSummarySeverity.blocker,
        message: 'owner proof requires explicit PV/MultiPV reason',
      );
    }
    if (result.debugBridgeRuntimeImplemented ||
        result.executableDebugBridgePrototypeImplemented ||
        result.implementationWiringImplemented ||
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
        id: 'debugBridgePrototypeDesignReadinessSummaryBoundaryPolicyViolation',
        severity: DebugBridgePrototypeDesignReadinessSummarySeverity.critical,
        message:
            'debug bridge prototype design readiness summary crossed a boundary',
      );
    }
    return findings..sort(_compareFindings);
  }

  List<DebugBridgePrototypeDesignReadinessSummaryFinding> validateReportText(
    String reportText,
  ) {
    final findings = <DebugBridgePrototypeDesignReadinessSummaryFinding>[];
    void reportError(String id, String message) {
      findings.add(
        DebugBridgePrototypeDesignReadinessSummaryFinding(
          id: id,
          severity: DebugBridgePrototypeDesignReadinessSummarySeverity.critical,
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
        ) ||
        reportText.contains('implementation wiring implemented: true')) {
      reportError(
        'runtimeImplementationReportText',
        'report contains active runtime, executable prototype, or wiring text',
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

List<DebugBridgePrototypeDesignReadinessSummaryRecord>
_recordsFromReadinessGate(
  DebugBridgePrototypeDesignReadinessGateResult readinessGateResult,
) {
  return <DebugBridgePrototypeDesignReadinessSummaryRecord>[
    _recordFromGate(
      readinessGateResult,
      DebugBridgePrototypeDesignReadinessGateRole
          .readinessApprovedPrototypeCoreDesign,
    ),
    _recordFromGate(
      readinessGateResult,
      DebugBridgePrototypeDesignReadinessGateRole
          .constrainedPrototypeContextDesign,
    ),
    _recordFromGate(
      readinessGateResult,
      DebugBridgePrototypeDesignReadinessGateRole
          .inactivePrototypeBlockedDesign,
    ),
    _recordFromGate(
      readinessGateResult,
      DebugBridgePrototypeDesignReadinessGateRole
          .inactivePrototypeFutureOnlyDesign,
    ),
    _recordFromGate(
      readinessGateResult,
      DebugBridgePrototypeDesignReadinessGateRole.readinessApprovedAllowedField,
    ),
    _recordFromGate(
      readinessGateResult,
      DebugBridgePrototypeDesignReadinessGateRole.deniedFieldBoundary,
    ),
    _recordFromGate(
      readinessGateResult,
      DebugBridgePrototypeDesignReadinessGateRole.stockfishRawUciPvDumpDenied,
    ),
    _recordFromGate(
      readinessGateResult,
      DebugBridgePrototypeDesignReadinessGateRole.runtimeExecutionBlocked,
    ),
    _recordFromGate(
      readinessGateResult,
      DebugBridgePrototypeDesignReadinessGateRole.androidProofBoundary,
    ),
    _recordFromGate(
      readinessGateResult,
      DebugBridgePrototypeDesignReadinessGateRole.emptyOwnerProofBoundary,
    ),
    _recordFromGate(
      readinessGateResult,
      DebugBridgePrototypeDesignReadinessGateRole.futurePhase33CRequirement,
    ),
  ];
}

DebugBridgePrototypeDesignReadinessSummaryRecord _recordFromGate(
  DebugBridgePrototypeDesignReadinessGateResult readinessGateResult,
  DebugBridgePrototypeDesignReadinessGateRole gateRole,
) {
  final source = readinessGateResult.recordForRole(gateRole);
  final summaryRole = _summaryRoleForGateRole(gateRole);
  final summaryStatus = _summaryStatusForGateRecord(source, summaryRole);
  final allowedForPlanning =
      summaryRole ==
          DebugBridgePrototypeDesignReadinessSummaryRole
              .readinessApprovedPrototypeCoreSummaryRecord ||
      summaryRole ==
          DebugBridgePrototypeDesignReadinessSummaryRole
              .approvedAllowedFieldSummaryRecord;
  final inactive = source.inactive || summaryRole.isInactiveBoundary;
  return DebugBridgePrototypeDesignReadinessSummaryRecord(
    summaryRecordId: 'phase33c-${summaryRole.wire}',
    sourceGateRecordId: source.gateRecordId,
    sourceGateGroupId: _sourceGroupIdForGateRole(gateRole),
    sourceValidationRowId: source.sourceValidationRowId,
    sourceDesignRecordId: source.sourceDesignRecordId,
    summaryRole: summaryRole,
    summaryStatus: summaryStatus,
    allowedForFutureInternalPlanning: allowedForPlanning,
    designOnly: source.designOnly,
    contextOnly: source.contextOnly,
    inactive: inactive,
    allowedFieldIds: _sortedStrings(source.allowedFieldIds),
    deniedFieldIds: _sortedStrings(source.deniedFieldIds),
    supportCaseIds: _sortedStrings(source.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(source.newlyAddedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(source.androidProofCaseIds),
    warningReasons: _warningReasonsForSummary(source, summaryRole),
    proofLimitReasons: _sortedStrings(source.proofLimitReasons),
    futurePrerequisites: _futurePrerequisitesForSummary(source, summaryRole),
    blockedBoundaryIds: _blockedBoundaryIdsForSummary(source, summaryRole),
    safetyFlags: _safeFlagsFrom(source.safetyFlags),
    violationReasons: source.violationReasons,
    recommendation: _recommendationForSummaryRole(summaryRole),
  );
}

List<DebugBridgePrototypeDesignReadinessSummaryGroup> _groupsFromRecords(
  List<DebugBridgePrototypeDesignReadinessSummaryRecord> records,
) {
  return <DebugBridgePrototypeDesignReadinessSummaryGroup>[
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessSummaryRole
          .readinessApprovedPrototypeCoreSummaryRecord,
      DebugBridgePrototypeDesignReadinessSummaryGroupId
          .readinessApprovedPrototypeCoreSummary,
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .readinessApprovedPrototypeCoreSummary,
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepPrototypeCoreSummaryForPlanning,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessSummaryRole
          .constrainedPrototypeContextSummaryRecord,
      DebugBridgePrototypeDesignReadinessSummaryGroupId
          .constrainedPrototypeContextSummary,
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .constrainedPrototypeContextSummary,
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepPrototypeContextSummaryConstrained,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessSummaryRole
          .inactivePrototypeBlockedSummaryRecord,
      DebugBridgePrototypeDesignReadinessSummaryGroupId
          .inactivePrototypeBlockedSummary,
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .inactivePrototypeBlockedSummary,
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepPrototypeBlockedSummaryInactive,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessSummaryRole
          .inactivePrototypeFutureOnlySummaryRecord,
      DebugBridgePrototypeDesignReadinessSummaryGroupId
          .inactivePrototypeFutureOnlySummary,
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .inactivePrototypeFutureOnlySummary,
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepPrototypeFutureOnlySummaryInactive,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessSummaryRole
          .approvedAllowedFieldSummaryRecord,
      DebugBridgePrototypeDesignReadinessSummaryGroupId
          .approvedAllowedFieldSummary,
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .approvedAllowedFieldSummary,
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepAllowedFieldSummarySafe,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessSummaryRole
          .deniedFieldBoundarySummaryRecord,
      DebugBridgePrototypeDesignReadinessSummaryGroupId
          .deniedFieldBoundarySummary,
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .deniedFieldBoundarySummary,
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepDeniedFieldBoundaryDenied,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessSummaryRole
          .stockfishRawUciPvDumpDeniedSummaryRecord,
      DebugBridgePrototypeDesignReadinessSummaryGroupId
          .stockfishRawUciPvDumpDeniedSummary,
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .stockfishRawUciPvDumpDeniedSummary,
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepStockfishRawUciPvDumpDenied,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessSummaryRole
          .runtimeExecutionBlockedSummaryRecord,
      DebugBridgePrototypeDesignReadinessSummaryGroupId
          .runtimeExecutionBlockedSummary,
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .runtimeExecutionBlockedSummary,
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepRuntimeExecutionBlocked,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessSummaryRole
          .androidProofBoundarySummaryRecord,
      DebugBridgePrototypeDesignReadinessSummaryGroupId
          .androidProofBoundarySummary,
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .androidProofBoundarySummary,
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepAndroidProofBoundaryCapturedOnly,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessSummaryRole
          .ownerProofBoundarySummaryRecord,
      DebugBridgePrototypeDesignReadinessSummaryGroupId
          .ownerProofBoundarySummary,
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .ownerProofBoundarySummary,
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepOwnerProofBoundaryEmpty,
    ),
    _groupFromRole(
      records,
      DebugBridgePrototypeDesignReadinessSummaryRole
          .futurePhase33DRequirementSummaryRecord,
      DebugBridgePrototypeDesignReadinessSummaryGroupId
          .futurePhase33DRequirementSummary,
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .futurePhase33DRequirementSummary,
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .requirePhase33DCheckpoint,
    ),
  ];
}

DebugBridgePrototypeDesignReadinessSummaryGroup _groupFromRole(
  List<DebugBridgePrototypeDesignReadinessSummaryRecord> records,
  DebugBridgePrototypeDesignReadinessSummaryRole role,
  DebugBridgePrototypeDesignReadinessSummaryGroupId groupId,
  DebugBridgePrototypeDesignReadinessSummaryItemStatus validStatus,
  DebugBridgePrototypeDesignReadinessSummaryRecommendation recommendation,
) {
  final matching = records.where((record) => record.summaryRole == role);
  final unsafe = matching.any((record) => record.hasUnsafeOutput);
  final invalid =
      !unsafe && matching.any((record) => record.summaryStatus.isInvalid);
  final status = unsafe
      ? DebugBridgePrototypeDesignReadinessSummaryItemStatus.unsafeSummary
      : invalid
      ? DebugBridgePrototypeDesignReadinessSummaryItemStatus.invalidSummary
      : validStatus;
  return DebugBridgePrototypeDesignReadinessSummaryGroup(
    groupId: groupId,
    summaryStatus: status,
    sourceGateGroupIds: _sortedGateGroupIds(
      matching.map((record) => record.sourceGateGroupId),
    ),
    sourceGateRecordIds: _sortedStrings(
      matching.map((record) => record.sourceGateRecordId),
    ),
    sourceValidationRowIds: _sortedStrings(
      matching.map((record) => record.sourceValidationRowId),
    ),
    sourceDesignRecordIds: _sortedStrings(
      matching.map((record) => record.sourceDesignRecordId),
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
    contextOnly:
        matching.isNotEmpty && matching.every((record) => record.contextOnly),
    inactive:
        matching.isNotEmpty && matching.every((record) => record.inactive),
    safeForPhase33D: !unsafe && !invalid,
    recommendation: unsafe
        ? DebugBridgePrototypeDesignReadinessSummaryRecommendation
              .blockUnsafePrototypeDesignReadinessSummary
        : invalid
        ? DebugBridgePrototypeDesignReadinessSummaryRecommendation
              .investigatePrototypeDesignReadinessSummaryFailure
        : recommendation,
  );
}

DebugBridgePrototypeDesignReadinessSummaryResult _resultFromRecords({
  required DebugBridgePrototypeDesignReadinessGateResult readinessGateResult,
  required DebugOnlyBridgePrototypeDesignValidationResult validationResult,
  required DebugOnlyBridgePrototypeDesignResult designResult,
  required DebugBridgeReadinessValidationGateResult bridgeReadinessGateResult,
  required List<DebugBridgePrototypeDesignReadinessSummaryGroup> summaryGroups,
  required List<DebugBridgePrototypeDesignReadinessSummaryRecord>
  summaryRecords,
  required List<DebugBridgePrototypeDesignReadinessSummaryFinding>
  validationFindings,
}) {
  final blockerCount =
      readinessGateResult.blockerCount +
      validationFindings.where((finding) => finding.blocksStrict).length;
  final criticalCount =
      readinessGateResult.criticalCount +
      validationFindings.where((finding) => finding.isCritical).length;
  final unsafeCount =
      readinessGateResult.unsafeCount +
      summaryRecords.where((record) => record.hasUnsafeOutput).length;
  final base = DebugBridgePrototypeDesignReadinessSummaryResult(
    summaryStatus: DebugBridgePrototypeDesignReadinessSummaryStatus.invalid,
    sourceReadinessGateStatus: readinessGateResult.gateStatus,
    sourceValidationStatus: validationResult.validationStatus,
    sourceDesignStatus: designResult.designStatus,
    sourceBridgeReadinessValidationGateStatus:
        bridgeReadinessGateResult.gateStatus,
    summaryGroups: summaryGroups,
    summaryRecords: summaryRecords,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...readinessGateResult.warnings,
      if (summaryRecords.any((record) => record.contextOnly))
        'prototype context summary remains context-only',
      if (summaryRecords.any((record) => record.inactive))
        'prototype blocked, future, denied, and runtime summaries remain inactive',
      if (readinessGateResult.ownerProofQueueCount == 0)
        'owner proof summary remains empty',
      'debug bridge runtime remains unimplemented',
      'executable debug bridge prototype remains unimplemented',
      'implementation wiring remains unimplemented',
    ]),
    failures: _sortedStrings(<String>[
      ...readinessGateResult.failures,
      ...validationFindings.map((finding) => finding.message),
      ...summaryRecords.expand((record) => record.violationReasons),
    ]),
    totalSummaryGroups: summaryGroups.length,
    totalSummaryRecords: summaryRecords.length,
    approvedCoreSummaryCount: _countRole(
      summaryRecords,
      DebugBridgePrototypeDesignReadinessSummaryRole
          .readinessApprovedPrototypeCoreSummaryRecord,
    ),
    constrainedContextSummaryCount: _countRole(
      summaryRecords,
      DebugBridgePrototypeDesignReadinessSummaryRole
          .constrainedPrototypeContextSummaryRecord,
    ),
    inactiveBlockedSummaryCount: _countRole(
      summaryRecords,
      DebugBridgePrototypeDesignReadinessSummaryRole
          .inactivePrototypeBlockedSummaryRecord,
    ),
    inactiveFutureOnlySummaryCount: _countRole(
      summaryRecords,
      DebugBridgePrototypeDesignReadinessSummaryRole
          .inactivePrototypeFutureOnlySummaryRecord,
    ),
    approvedAllowedFieldCount: readinessGateResult.allowedFieldIds.length,
    deniedFieldCount: readinessGateResult.deniedFieldIds.length,
    stockfishRawUciPvDumpDeniedCount: _engineDumpFieldIds
        .where(readinessGateResult.deniedFieldIds.contains)
        .length,
    runtimeExecutionBlockedCount: _countRole(
      summaryRecords,
      DebugBridgePrototypeDesignReadinessSummaryRole
          .runtimeExecutionBlockedSummaryRecord,
    ),
    futureRequirementCount: _countRole(
      summaryRecords,
      DebugBridgePrototypeDesignReadinessSummaryRole
          .futurePhase33DRequirementSummaryRecord,
    ),
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
    allowedFieldIds: _sortedStrings(readinessGateResult.allowedFieldIds),
    deniedFieldIds: _sortedStrings(readinessGateResult.deniedFieldIds),
    safeForPhase33D: false,
    phase33DRecommendation:
        DebugBridgePrototypeDesignReadinessSummaryPhase33DRecommendation
            .addMoreGoldenCoverageFirst,
    developerOnly:
        readinessGateResult.developerOnly &&
        validationResult.developerOnly &&
        designResult.developerOnly &&
        bridgeReadinessGateResult.developerOnly,
    debugBridgeRuntimeImplemented:
        readinessGateResult.debugBridgeRuntimeImplemented,
    executableDebugBridgePrototypeImplemented:
        readinessGateResult.executableDebugBridgePrototypeImplemented,
    implementationWiringImplemented: false,
    productOutputActive: readinessGateResult.productOutputActive,
    classifierOutputActive: readinessGateResult.classifierOutputActive,
    finalMoveLabelOutputActive: readinessGateResult.finalMoveLabelOutputActive,
    officialMetricOutputActive: readinessGateResult.officialMetricOutputActive,
    cpLossOutputActive: readinessGateResult.cpLossOutputActive,
    winProbabilityOutputActive: readinessGateResult.winProbabilityOutputActive,
    numericOutputActive: readinessGateResult.numericOutputActive,
    aggregateScoreOutputActive: readinessGateResult.aggregateScoreOutputActive,
    moveRankingOutputActive: readinessGateResult.moveRankingOutputActive,
    quietPreparatoryScopeActivated:
        readinessGateResult.quietPreparatoryScopeActivated,
    engineCallsActive: readinessGateResult.engineCallsActive,
    persistenceWritesActive: readinessGateResult.persistenceWritesActive,
    uiTargetsActive: readinessGateResult.uiTargetsActive,
    backendOutputActive: readinessGateResult.backendOutputActive,
    stockfishCommandFieldActive:
        readinessGateResult.stockfishCommandFieldActive,
    rawUciFieldActive: readinessGateResult.rawUciFieldActive,
    pvDumpFieldActive: readinessGateResult.pvDumpFieldActive,
  );
  final status = _summaryStatusFor(
    base,
    readinessGateResult: readinessGateResult,
  );
  final safeForPhase33D =
      (status ==
              DebugBridgePrototypeDesignReadinessSummaryStatus
                  .summarizedWithWarnings ||
          status ==
              DebugBridgePrototypeDesignReadinessSummaryStatus
                  .summarizedClean) &&
      readinessGateResult.safeForPhase33C &&
      !readinessGateResult.isStrictlyBlocked &&
      !readinessGateResult
          .hasUnsafePrototypeDesignReadinessGatePolicyViolation &&
      unsafeCount == 0 &&
      blockerCount == 0 &&
      criticalCount == 0 &&
      validationFindings.every((finding) => !finding.blocksStrict) &&
      summaryGroups.every((group) => group.safeForPhase33D) &&
      summaryRecords.every(
        (record) =>
            !record.hasUnsafeOutput &&
            record.summaryStatus !=
                DebugBridgePrototypeDesignReadinessSummaryItemStatus
                    .invalidSummary,
      );
  return base.copyWith(
    summaryStatus: status,
    safeForPhase33D: safeForPhase33D,
    phase33DRecommendation: _phase33DRecommendationFor(
      status: status,
      safeForPhase33D: safeForPhase33D,
      ownerProofQueueCount: readinessGateResult.ownerProofQueueCount,
    ),
  );
}

DebugBridgePrototypeDesignReadinessSummaryStatus _summaryStatusFor(
  DebugBridgePrototypeDesignReadinessSummaryResult result, {
  required DebugBridgePrototypeDesignReadinessGateResult readinessGateResult,
}) {
  if (result.debugBridgeRuntimeImplemented ||
      result.executableDebugBridgePrototypeImplemented ||
      result.implementationWiringImplemented ||
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
    return DebugBridgePrototypeDesignReadinessSummaryStatus
        .blockedByPolicyBoundary;
  }
  if (readinessGateResult.gateStatus ==
          DebugBridgePrototypeDesignReadinessGateStatus
              .blockedByPrototypeDesignValidationFailure ||
      readinessGateResult.gateStatus ==
          DebugBridgePrototypeDesignReadinessGateStatus
              .blockedByPolicyBoundary ||
      readinessGateResult.unsafeCount > 0 ||
      readinessGateResult.criticalCount > 0 ||
      readinessGateResult
          .hasUnsafePrototypeDesignReadinessGatePolicyViolation ||
      result.unsafeCount > 0 ||
      result.criticalCount > 0) {
    return DebugBridgePrototypeDesignReadinessSummaryStatus
        .blockedByUnsafeReadinessGate;
  }
  if (!readinessGateResult.safeForPhase33C ||
      readinessGateResult.isStrictlyBlocked ||
      result.blockerCount > 0 ||
      result.validationFindings.any((finding) => finding.blocksStrict) ||
      result.summaryGroups.any((group) => !group.safeForPhase33D) ||
      result.summaryRecords.any((record) => record.summaryStatus.isInvalid)) {
    return DebugBridgePrototypeDesignReadinessSummaryStatus.invalid;
  }
  if (result.summaryGroups.isEmpty || result.summaryRecords.isEmpty) {
    return DebugBridgePrototypeDesignReadinessSummaryStatus.invalid;
  }
  if (result.constrainedContextSummaryCount > 0 ||
      result.inactiveBlockedSummaryCount > 0 ||
      result.inactiveFutureOnlySummaryCount > 0 ||
      result.warnings.isNotEmpty) {
    return DebugBridgePrototypeDesignReadinessSummaryStatus
        .summarizedWithWarnings;
  }
  return DebugBridgePrototypeDesignReadinessSummaryStatus.summarizedClean;
}

DebugBridgePrototypeDesignReadinessSummaryPhase33DRecommendation
_phase33DRecommendationFor({
  required DebugBridgePrototypeDesignReadinessSummaryStatus status,
  required bool safeForPhase33D,
  required int ownerProofQueueCount,
}) {
  if (status ==
          DebugBridgePrototypeDesignReadinessSummaryStatus
              .blockedByUnsafeReadinessGate ||
      status ==
          DebugBridgePrototypeDesignReadinessSummaryStatus
              .blockedByPolicyBoundary) {
    return DebugBridgePrototypeDesignReadinessSummaryPhase33DRecommendation
        .blockedByUnsafePrototypeDesignReadinessSummary;
  }
  if (ownerProofQueueCount > 0) {
    return DebugBridgePrototypeDesignReadinessSummaryPhase33DRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase33D) {
    return DebugBridgePrototypeDesignReadinessSummaryPhase33DRecommendation
        .addMoreGoldenCoverageFirst;
  }
  return DebugBridgePrototypeDesignReadinessSummaryPhase33DRecommendation
      .proceedToDebugBridgePrototypeDesignReadinessSummaryValidation;
}

DebugBridgePrototypeDesignReadinessSummaryRole _summaryRoleForGateRole(
  DebugBridgePrototypeDesignReadinessGateRole role,
) {
  return switch (role) {
    DebugBridgePrototypeDesignReadinessGateRole
        .readinessApprovedPrototypeCoreDesign =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .readinessApprovedPrototypeCoreSummaryRecord,
    DebugBridgePrototypeDesignReadinessGateRole
        .constrainedPrototypeContextDesign =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .constrainedPrototypeContextSummaryRecord,
    DebugBridgePrototypeDesignReadinessGateRole
        .inactivePrototypeBlockedDesign =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .inactivePrototypeBlockedSummaryRecord,
    DebugBridgePrototypeDesignReadinessGateRole
        .inactivePrototypeFutureOnlyDesign =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .inactivePrototypeFutureOnlySummaryRecord,
    DebugBridgePrototypeDesignReadinessGateRole.readinessApprovedAllowedField =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .approvedAllowedFieldSummaryRecord,
    DebugBridgePrototypeDesignReadinessGateRole.deniedFieldBoundary =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .deniedFieldBoundarySummaryRecord,
    DebugBridgePrototypeDesignReadinessGateRole.stockfishRawUciPvDumpDenied =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .stockfishRawUciPvDumpDeniedSummaryRecord,
    DebugBridgePrototypeDesignReadinessGateRole.runtimeExecutionBlocked =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .runtimeExecutionBlockedSummaryRecord,
    DebugBridgePrototypeDesignReadinessGateRole.androidProofBoundary =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .androidProofBoundarySummaryRecord,
    DebugBridgePrototypeDesignReadinessGateRole.emptyOwnerProofBoundary =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .ownerProofBoundarySummaryRecord,
    DebugBridgePrototypeDesignReadinessGateRole.futurePhase33CRequirement =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .futurePhase33DRequirementSummaryRecord,
  };
}

DebugBridgePrototypeDesignReadinessGateGroupId _sourceGroupIdForGateRole(
  DebugBridgePrototypeDesignReadinessGateRole role,
) {
  return switch (role) {
    DebugBridgePrototypeDesignReadinessGateRole
        .readinessApprovedPrototypeCoreDesign =>
      DebugBridgePrototypeDesignReadinessGateGroupId
          .readinessApprovedPrototypeCoreDesignGroup,
    DebugBridgePrototypeDesignReadinessGateRole
        .constrainedPrototypeContextDesign =>
      DebugBridgePrototypeDesignReadinessGateGroupId
          .constrainedPrototypeContextDesignGroup,
    DebugBridgePrototypeDesignReadinessGateRole
        .inactivePrototypeBlockedDesign =>
      DebugBridgePrototypeDesignReadinessGateGroupId
          .inactivePrototypeBlockedDesignGroup,
    DebugBridgePrototypeDesignReadinessGateRole
        .inactivePrototypeFutureOnlyDesign =>
      DebugBridgePrototypeDesignReadinessGateGroupId
          .inactivePrototypeFutureOnlyDesignGroup,
    DebugBridgePrototypeDesignReadinessGateRole.readinessApprovedAllowedField =>
      DebugBridgePrototypeDesignReadinessGateGroupId
          .readinessApprovedAllowedFieldGroup,
    DebugBridgePrototypeDesignReadinessGateRole.deniedFieldBoundary =>
      DebugBridgePrototypeDesignReadinessGateGroupId.deniedFieldBoundaryGroup,
    DebugBridgePrototypeDesignReadinessGateRole.stockfishRawUciPvDumpDenied =>
      DebugBridgePrototypeDesignReadinessGateGroupId
          .stockfishRawUciPvDumpDeniedGroup,
    DebugBridgePrototypeDesignReadinessGateRole.runtimeExecutionBlocked =>
      DebugBridgePrototypeDesignReadinessGateGroupId
          .runtimeExecutionBlockedGroup,
    DebugBridgePrototypeDesignReadinessGateRole.androidProofBoundary =>
      DebugBridgePrototypeDesignReadinessGateGroupId.androidProofBoundaryGroup,
    DebugBridgePrototypeDesignReadinessGateRole.emptyOwnerProofBoundary =>
      DebugBridgePrototypeDesignReadinessGateGroupId
          .emptyOwnerProofBoundaryGroup,
    DebugBridgePrototypeDesignReadinessGateRole.futurePhase33CRequirement =>
      DebugBridgePrototypeDesignReadinessGateGroupId
          .futurePhase33CRequirementGroup,
  };
}

DebugBridgePrototypeDesignReadinessSummaryItemStatus
_summaryStatusForGateRecord(
  DebugBridgePrototypeDesignReadinessGateRecord source,
  DebugBridgePrototypeDesignReadinessSummaryRole role,
) {
  if (source.hasUnsafeOutput) {
    return DebugBridgePrototypeDesignReadinessSummaryItemStatus.unsafeSummary;
  }
  if (source.gateStatus.isInvalid) {
    return DebugBridgePrototypeDesignReadinessSummaryItemStatus.invalidSummary;
  }
  return switch (role) {
    DebugBridgePrototypeDesignReadinessSummaryRole
        .readinessApprovedPrototypeCoreSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .readinessApprovedPrototypeCoreSummary,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .constrainedPrototypeContextSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .constrainedPrototypeContextSummary,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .inactivePrototypeBlockedSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .inactivePrototypeBlockedSummary,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .inactivePrototypeFutureOnlySummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .inactivePrototypeFutureOnlySummary,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .approvedAllowedFieldSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .approvedAllowedFieldSummary,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .deniedFieldBoundarySummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .deniedFieldBoundarySummary,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .stockfishRawUciPvDumpDeniedSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .stockfishRawUciPvDumpDeniedSummary,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .runtimeExecutionBlockedSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .runtimeExecutionBlockedSummary,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .androidProofBoundarySummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .androidProofBoundarySummary,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .ownerProofBoundarySummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .ownerProofBoundarySummary,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .futurePhase33DRequirementSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryItemStatus
          .futurePhase33DRequirementSummary,
  };
}

DebugBridgePrototypeDesignReadinessSummaryRecommendation
_recommendationForSummaryRole(
  DebugBridgePrototypeDesignReadinessSummaryRole role,
) {
  return switch (role) {
    DebugBridgePrototypeDesignReadinessSummaryRole
        .readinessApprovedPrototypeCoreSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepPrototypeCoreSummaryForPlanning,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .constrainedPrototypeContextSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepPrototypeContextSummaryConstrained,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .inactivePrototypeBlockedSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepPrototypeBlockedSummaryInactive,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .inactivePrototypeFutureOnlySummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepPrototypeFutureOnlySummaryInactive,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .approvedAllowedFieldSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepAllowedFieldSummarySafe,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .deniedFieldBoundarySummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepDeniedFieldBoundaryDenied,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .stockfishRawUciPvDumpDeniedSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepStockfishRawUciPvDumpDenied,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .runtimeExecutionBlockedSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepRuntimeExecutionBlocked,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .androidProofBoundarySummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepAndroidProofBoundaryCapturedOnly,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .ownerProofBoundarySummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .keepOwnerProofBoundaryEmpty,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .futurePhase33DRequirementSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecommendation
          .requirePhase33DCheckpoint,
  };
}

List<String> _warningReasonsForSummary(
  DebugBridgePrototypeDesignReadinessGateRecord source,
  DebugBridgePrototypeDesignReadinessSummaryRole role,
) {
  if (role ==
      DebugBridgePrototypeDesignReadinessSummaryRole
          .futurePhase33DRequirementSummaryRecord) {
    return const <String>[
      'Phase 33D must validate this summary or run an implementation-design readiness checkpoint before implementation',
    ];
  }
  if (role ==
      DebugBridgePrototypeDesignReadinessSummaryRole
          .runtimeExecutionBlockedSummaryRecord) {
    return _sortedStrings(<String>[
      ...source.warningReasons,
      'runtime bridge, executable prototype behavior, and implementation wiring remain blocked',
    ]);
  }
  return _sortedStrings(source.warningReasons);
}

List<String> _futurePrerequisitesForSummary(
  DebugBridgePrototypeDesignReadinessGateRecord source,
  DebugBridgePrototypeDesignReadinessSummaryRole role,
) {
  if (role ==
      DebugBridgePrototypeDesignReadinessSummaryRole
          .futurePhase33DRequirementSummaryRecord) {
    return const <String>[
      'phase33DPrototypeDesignReadinessSummaryValidationOrImplementationDesignReadinessGateOrReportOnlyCheckpoint',
    ];
  }
  return _sortedStrings(source.futurePrerequisites);
}

List<String> _blockedBoundaryIdsForSummary(
  DebugBridgePrototypeDesignReadinessGateRecord source,
  DebugBridgePrototypeDesignReadinessSummaryRole role,
) {
  if (role ==
      DebugBridgePrototypeDesignReadinessSummaryRole
          .runtimeExecutionBlockedSummaryRecord) {
    return _sortedStrings(<String>[
      ...source.blockedBoundaryIds,
      'implementationWiring',
    ]);
  }
  return _sortedStrings(source.blockedBoundaryIds);
}

void _checkRecordBoundary(
  void Function({
    required String id,
    required DebugBridgePrototypeDesignReadinessSummarySeverity severity,
    required String message,
    String? summaryRecordId,
    DebugBridgePrototypeDesignReadinessSummaryGroupId? summaryGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugBridgePrototypeDesignReadinessSummaryRecord record,
) {
  if (!record.designOnly) {
    add(
      id: 'prototypeSummaryRecordNotDesignOnly',
      severity: DebugBridgePrototypeDesignReadinessSummarySeverity.critical,
      message:
          'prototype design readiness summary records must stay design-only',
      summaryRecordId: record.summaryRecordId,
    );
  }
  if (record.summaryRole ==
      DebugBridgePrototypeDesignReadinessSummaryRole
          .readinessApprovedPrototypeCoreSummaryRecord) {
    if (record.contextOnly ||
        record.inactive ||
        record.sourceGateGroupId !=
            DebugBridgePrototypeDesignReadinessGateGroupId
                .readinessApprovedPrototypeCoreDesignGroup ||
        record.violationReasons.contains('prototypeCoreConsumesNonCoreInput')) {
      add(
        id: 'prototypeCoreSummaryConsumesNonCoreInput',
        severity: DebugBridgePrototypeDesignReadinessSummarySeverity.critical,
        message:
            'prototype core readiness summary cannot consume non-core input',
        summaryRecordId: record.summaryRecordId,
      );
    }
  }
  if (record.summaryRole ==
      DebugBridgePrototypeDesignReadinessSummaryRole
          .constrainedPrototypeContextSummaryRecord) {
    if (!record.contextOnly || record.allowedForFutureInternalPlanning) {
      add(
        id: 'contextOnlySummaryPromotedToCore',
        severity: DebugBridgePrototypeDesignReadinessSummarySeverity.critical,
        message: 'context-only prototype summary cannot become core',
        summaryRecordId: record.summaryRecordId,
      );
    }
  }
  if (record.contextOnly &&
      record.summaryRole ==
          DebugBridgePrototypeDesignReadinessSummaryRole
              .readinessApprovedPrototypeCoreSummaryRecord) {
    add(
      id: 'contextOnlySummaryPromotedToCore',
      severity: DebugBridgePrototypeDesignReadinessSummarySeverity.critical,
      message: 'context-only prototype summary cannot become core',
      summaryRecordId: record.summaryRecordId,
    );
  }
  if (record.summaryRole.isInactiveBoundary &&
      (!record.inactive || record.allowedFieldIds.isNotEmpty)) {
    add(
      id: 'blockedFutureSummaryMadeActive',
      severity: DebugBridgePrototypeDesignReadinessSummarySeverity.critical,
      message:
          'blocked, future-only, denied, Stockfish, and runtime summaries must stay inactive',
      summaryRecordId: record.summaryRecordId,
    );
  }
}

void _checkSafetyFlags(
  void Function({
    required String id,
    required DebugBridgePrototypeDesignReadinessSummarySeverity severity,
    required String message,
    String? summaryRecordId,
    DebugBridgePrototypeDesignReadinessSummaryGroupId? summaryGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugBridgePrototypeDesignReadinessSummaryRecord record,
) {
  void critical(String id, String message) {
    add(
      id: id,
      severity: DebugBridgePrototypeDesignReadinessSummarySeverity.critical,
      message: message,
      summaryRecordId: record.summaryRecordId,
    );
  }

  if (record.safetyFlags['isProductOutput'] == true) {
    critical('productOutputActive', 'summary cannot be product output');
  }
  if (record.safetyFlags['isClassifierLabel'] == true) {
    critical('classifierLabelOutputActive', 'summary cannot emit labels');
  }
  if (record.safetyFlags['hasNumericScore'] == true) {
    critical('numericScoreOutputActive', 'summary cannot emit numeric scores');
  }
  if (record.safetyFlags['hasAggregateScore'] == true) {
    critical(
      'aggregateScoreOutputActive',
      'summary cannot emit aggregate scores',
    );
  }
  if (record.safetyFlags['ranksMoves'] == true) {
    critical('moveRankingOutputActive', 'summary cannot rank moves');
  }
  if (record.safetyFlags['isOfficialMetric'] == true) {
    critical(
      'officialMetricOutputActive',
      'summary cannot emit official metrics',
    );
  }
  if (record.safetyFlags['exposesCpLoss'] == true ||
      record.safetyFlags['exposesWinProbability'] == true) {
    critical(
      'futureMetricOutputActive',
      'summary cannot expose CP-loss or win probability',
    );
  }
  if (record.safetyFlags['quietPreparatoryScopeActive'] == true) {
    critical(
      'quietPreparatoryScopeActivated',
      'quiet/preparatory scope must remain excluded',
    );
  }
  if (record.safetyFlags['callsEngine'] == true) {
    critical('engineCallFlagActive', 'summary cannot call an engine');
  }
  if (record.safetyFlags['writesPersistence'] == true) {
    critical('persistenceWriteFlagActive', 'summary cannot write persistence');
  }
  if (record.safetyFlags['targetsUi'] == true) {
    critical('uiTargetFlagActive', 'summary cannot target UI');
  }
  if (record.safetyFlags['backendOutputActive'] == true ||
      record.safetyFlags['targetsBackend'] == true) {
    critical('backendOutputActive', 'summary cannot target backend');
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
      'summary cannot implement runtime behavior',
    );
  }
  if (record.safetyFlags['implementsPrototypeExecution'] == true) {
    critical(
      'executablePrototypeImplementationFlagActive',
      'summary cannot implement executable prototype behavior',
    );
  }
  if (record.safetyFlags['implementsWiring'] == true) {
    critical(
      'implementationWiringFlagActive',
      'summary cannot implement wiring',
    );
  }
}

void _checkAllowedField(
  void Function({
    required String id,
    required DebugBridgePrototypeDesignReadinessSummarySeverity severity,
    required String message,
    String? summaryRecordId,
    DebugBridgePrototypeDesignReadinessSummaryGroupId? summaryGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String fieldId, {
  String? summaryRecordId,
  DebugBridgePrototypeDesignReadinessSummaryGroupId? summaryGroupId,
}) {
  if (_isDeniedFieldId(fieldId) || _isLegacyDeniedFieldId(fieldId)) {
    add(
      id: 'activeDeniedField',
      severity: DebugBridgePrototypeDesignReadinessSummarySeverity.critical,
      message: '$fieldId cannot be active prototype readiness summary output',
      summaryRecordId: summaryRecordId,
      summaryGroupId: summaryGroupId,
      fieldId: fieldId,
    );
  }
}

void _checkAndroidProofCase(
  void Function({
    required String id,
    required DebugBridgePrototypeDesignReadinessSummarySeverity severity,
    required String message,
    String? summaryRecordId,
    DebugBridgePrototypeDesignReadinessSummaryGroupId? summaryGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String caseId,
  List<String> provenAndroidIds, {
  String? summaryRecordId,
  DebugBridgePrototypeDesignReadinessSummaryGroupId? summaryGroupId,
}) {
  if (_phase32ECaseIds.contains(caseId)) {
    add(
      id: 'phase32ECaseTreatedAsCapturedProof',
      severity: DebugBridgePrototypeDesignReadinessSummarySeverity.critical,
      message: '$caseId cannot be treated as captured Android proof',
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
      severity: DebugBridgePrototypeDesignReadinessSummarySeverity.critical,
      message: '$caseId is not captured Android proof',
      summaryRecordId: summaryRecordId,
      summaryGroupId: summaryGroupId,
      caseId: caseId,
    );
  }
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
    'implementsRuntime': source['implementsRuntime'] ?? false,
    'implementsPrototypeExecution':
        source['implementsPrototypeExecution'] ?? false,
    'implementsWiring': source['implementsWiring'] ?? false,
    'backendOutputActive': source['backendOutputActive'] ?? false,
    'targetsBackend': source['targetsBackend'] ?? false,
    'quietPreparatoryScopeActive':
        source['quietPreparatoryScopeActive'] ?? false,
  };
}

bool _hasExplicitPvProofReason(
  DebugBridgePrototypeDesignReadinessSummaryResult result,
) {
  final reasons = <String>[
    ...result.warnings,
    ...result.failures,
    ...result.summaryGroups.expand((group) => group.warningReasons),
    ...result.summaryGroups.expand((group) => group.proofLimitReasons),
  ].join(' ').toLowerCase();
  return reasons.contains('pv') || reasons.contains('multipv');
}

int _countRole(
  Iterable<DebugBridgePrototypeDesignReadinessSummaryRecord> records,
  DebugBridgePrototypeDesignReadinessSummaryRole role,
) {
  return records.where((record) => record.summaryRole == role).length;
}

List<String> _provenAndroidProofIds(GoldenAndroidProofEvidence? evidence) {
  return _sortedStrings(evidence?.targetCaseIds ?? const <String>[]);
}

int _compareFindings(
  DebugBridgePrototypeDesignReadinessSummaryFinding a,
  DebugBridgePrototypeDesignReadinessSummaryFinding b,
) {
  final severity = _severityRank(
    b.severity,
  ).compareTo(_severityRank(a.severity));
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.summaryRecordId ?? '').compareTo(b.summaryRecordId ?? '');
}

int _severityRank(DebugBridgePrototypeDesignReadinessSummarySeverity severity) {
  return switch (severity) {
    DebugBridgePrototypeDesignReadinessSummarySeverity.warning => 1,
    DebugBridgePrototypeDesignReadinessSummarySeverity.blocker => 2,
    DebugBridgePrototypeDesignReadinessSummarySeverity.critical => 3,
  };
}

List<DebugBridgePrototypeDesignReadinessGateGroupId> _sortedGateGroupIds(
  Iterable<DebugBridgePrototypeDesignReadinessGateGroupId> values,
) {
  final sorted = values.toSet().toList()
    ..sort((a, b) => a.wire.compareTo(b.wire));
  return sorted;
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

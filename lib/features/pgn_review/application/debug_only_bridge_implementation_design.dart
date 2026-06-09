/// Developer-only implementation design for a future debug-only bridge
/// skeleton.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_summary_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugOnlyBridgeImplementationDesignReportVersion =
    'debug-only-bridge-implementation-design-v1';

enum DebugOnlyBridgeImplementationDesignStatus {
  implementationDesignReadyWithWarnings(
    'implementationDesignReadyWithWarnings',
  ),
  implementationDesignReadyClean('implementationDesignReadyClean'),
  blockedByUnsafeReadinessValidation('blockedByUnsafeReadinessValidation'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const DebugOnlyBridgeImplementationDesignStatus(this.wire);

  final String wire;
}

enum DebugOnlyBridgeImplementationDesignComponentId {
  bridgeInputContractDesign('bridgeInputContractDesign'),
  bridgeCoreRecordDesign('bridgeCoreRecordDesign'),
  bridgeContextRecordDesign('bridgeContextRecordDesign'),
  bridgeInactiveBlockedRecordDesign('bridgeInactiveBlockedRecordDesign'),
  bridgeInactiveFutureRecordDesign('bridgeInactiveFutureRecordDesign'),
  bridgeAllowedFieldContractDesign('bridgeAllowedFieldContractDesign'),
  bridgeDeniedFieldContractDesign('bridgeDeniedFieldContractDesign'),
  bridgeRuntimeBlockDesign('bridgeRuntimeBlockDesign'),
  bridgeProofBoundaryDesign('bridgeProofBoundaryDesign'),
  bridgeOwnerProofBoundaryDesign('bridgeOwnerProofBoundaryDesign'),
  bridgeSkeletonPlanDesign('bridgeSkeletonPlanDesign'),
  phase33FImplementationSkeletonRequirement(
    'phase33FImplementationSkeletonRequirement',
  );

  const DebugOnlyBridgeImplementationDesignComponentId(this.wire);

  final String wire;
}

enum DebugOnlyBridgeImplementationDesignComponentRole {
  bridgeInputContract('bridgeInputContract'),
  bridgeCoreRecord('bridgeCoreRecord'),
  bridgeContextRecord('bridgeContextRecord'),
  bridgeInactiveBlockedRecord('bridgeInactiveBlockedRecord'),
  bridgeInactiveFutureRecord('bridgeInactiveFutureRecord'),
  bridgeAllowedFieldContract('bridgeAllowedFieldContract'),
  bridgeDeniedFieldContract('bridgeDeniedFieldContract'),
  bridgeRuntimeBlock('bridgeRuntimeBlock'),
  bridgeProofBoundary('bridgeProofBoundary'),
  bridgeOwnerProofBoundary('bridgeOwnerProofBoundary'),
  bridgeSkeletonPlan('bridgeSkeletonPlan'),
  phase33FImplementationSkeletonRequirement(
    'phase33FImplementationSkeletonRequirement',
  );

  const DebugOnlyBridgeImplementationDesignComponentRole(this.wire);

  final String wire;

  bool get isInactiveBoundary =>
      this == bridgeInactiveBlockedRecord ||
      this == bridgeInactiveFutureRecord ||
      this == bridgeDeniedFieldContract ||
      this == bridgeRuntimeBlock;
}

enum DebugOnlyBridgeImplementationDesignItemStatus {
  bridgeInputContractDesign('bridgeInputContractDesign'),
  bridgeCoreRecordDesign('bridgeCoreRecordDesign'),
  bridgeContextRecordDesign('bridgeContextRecordDesign'),
  bridgeInactiveBlockedRecordDesign('bridgeInactiveBlockedRecordDesign'),
  bridgeInactiveFutureRecordDesign('bridgeInactiveFutureRecordDesign'),
  bridgeAllowedFieldContractDesign('bridgeAllowedFieldContractDesign'),
  bridgeDeniedFieldContractDesign('bridgeDeniedFieldContractDesign'),
  bridgeRuntimeBlockDesign('bridgeRuntimeBlockDesign'),
  bridgeProofBoundaryDesign('bridgeProofBoundaryDesign'),
  bridgeOwnerProofBoundaryDesign('bridgeOwnerProofBoundaryDesign'),
  bridgeSkeletonPlanDesign('bridgeSkeletonPlanDesign'),
  phase33FImplementationSkeletonRequirement(
    'phase33FImplementationSkeletonRequirement',
  ),
  invalidDesign('invalidDesign'),
  unsafeDesign('unsafeDesign');

  const DebugOnlyBridgeImplementationDesignItemStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == unsafeDesign;

  bool get isInvalid => this == invalidDesign;
}

enum DebugOnlyBridgeImplementationDesignSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const DebugOnlyBridgeImplementationDesignSeverity(this.wire);

  final String wire;

  bool get blocksStrict => this == blocker || this == critical;

  bool get isCritical => this == critical;
}

enum DebugOnlyBridgeImplementationDesignRecommendation {
  keepInputContractDesignOnly('keepInputContractDesignOnly'),
  mapCoreRecordsToSkeletonContract('mapCoreRecordsToSkeletonContract'),
  keepContextRecordsContextOnly('keepContextRecordsContextOnly'),
  keepBlockedRecordsInactive('keepBlockedRecordsInactive'),
  keepFutureRecordsInactive('keepFutureRecordsInactive'),
  keepAllowedFieldsDebugSafe('keepAllowedFieldsDebugSafe'),
  keepDeniedFieldsImpossible('keepDeniedFieldsImpossible'),
  keepRuntimePrototypeWiringBlocked('keepRuntimePrototypeWiringBlocked'),
  keepProofBoundaryCapturedOnly('keepProofBoundaryCapturedOnly'),
  keepOwnerProofEmpty('keepOwnerProofEmpty'),
  preparePhase33FDeveloperSkeleton('preparePhase33FDeveloperSkeleton'),
  requirePhase33FSkeletonCheckpoint('requirePhase33FSkeletonCheckpoint'),
  investigateImplementationDesignFailure(
    'investigateImplementationDesignFailure',
  ),
  blockUnsafeImplementationDesign('blockUnsafeImplementationDesign');

  const DebugOnlyBridgeImplementationDesignRecommendation(this.wire);

  final String wire;
}

enum DebugOnlyBridgeImplementationDesignPhase33FRecommendation {
  proceedToDebugOnlyBridgeSkeletonDesignValidation(
    'proceedToDebugOnlyBridgeSkeletonDesignValidation',
  ),
  proceedToDebugOnlyBridgeDeveloperSkeleton(
    'proceedToDebugOnlyBridgeDeveloperSkeleton',
  ),
  proceedToImplementationDesignReviewOnly(
    'proceedToImplementationDesignReviewOnly',
  ),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeImplementationDesign('blockedByUnsafeImplementationDesign');

  const DebugOnlyBridgeImplementationDesignPhase33FRecommendation(this.wire);

  final String wire;
}

enum DebugOnlyBridgeImplementationDesignReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeImplementationDesignReportFormat(this.wire);

  final String wire;
}

class DebugOnlyBridgeImplementationDesignRequest {
  const DebugOnlyBridgeImplementationDesignRequest({
    this.readinessSummaryValidationResult,
    this.readinessSummaryResult,
    this.readinessGateResult,
    this.prototypeValidationResult,
    this.prototypeDesignResult,
    this.bridgeReadinessGateResult,
    this.readinessSummaryValidation =
        const DebugBridgePrototypeDesignReadinessSummaryValidation(),
    this.readinessSummary = const DebugBridgePrototypeDesignReadinessSummary(),
    this.readinessGate = const DebugBridgePrototypeDesignReadinessGate(),
    this.prototypeValidation = const DebugOnlyBridgePrototypeDesignValidation(),
    this.prototypeDesign = const DebugOnlyBridgePrototypeDesign(),
    this.bridgeReadinessGate = const DebugBridgeReadinessValidationGate(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const DebugOnlyBridgeImplementationDesignRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final DebugBridgePrototypeDesignReadinessSummaryValidationResult?
  readinessSummaryValidationResult;
  final DebugBridgePrototypeDesignReadinessSummaryResult?
  readinessSummaryResult;
  final DebugBridgePrototypeDesignReadinessGateResult? readinessGateResult;
  final DebugOnlyBridgePrototypeDesignValidationResult?
  prototypeValidationResult;
  final DebugOnlyBridgePrototypeDesignResult? prototypeDesignResult;
  final DebugBridgeReadinessValidationGateResult? bridgeReadinessGateResult;
  final DebugBridgePrototypeDesignReadinessSummaryValidation
  readinessSummaryValidation;
  final DebugBridgePrototypeDesignReadinessSummary readinessSummary;
  final DebugBridgePrototypeDesignReadinessGate readinessGate;
  final DebugOnlyBridgePrototypeDesignValidation prototypeValidation;
  final DebugOnlyBridgePrototypeDesign prototypeDesign;
  final DebugBridgeReadinessValidationGate bridgeReadinessGate;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class DebugOnlyBridgeImplementationDesignComponent {
  const DebugOnlyBridgeImplementationDesignComponent({
    required this.componentId,
    required this.designStatus,
    required this.sourceValidationRowIds,
    required this.sourceSummaryRecordIds,
    required this.sourceGateRecordIds,
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
    required this.proposedClassNames,
    required this.proposedMethodNames,
    required this.proposedFileNames,
    required this.designOnly,
    required this.allowedForFutureSkeleton,
    required this.contextOnly,
    required this.inactive,
    required this.safeForPhase33F,
    required this.recommendation,
  });

  final DebugOnlyBridgeImplementationDesignComponentId componentId;
  final DebugOnlyBridgeImplementationDesignItemStatus designStatus;
  final List<String> sourceValidationRowIds;
  final List<String> sourceSummaryRecordIds;
  final List<String> sourceGateRecordIds;
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
  final List<String> proposedClassNames;
  final List<String> proposedMethodNames;
  final List<String> proposedFileNames;
  final bool designOnly;
  final bool allowedForFutureSkeleton;
  final bool contextOnly;
  final bool inactive;
  final bool safeForPhase33F;
  final DebugOnlyBridgeImplementationDesignRecommendation recommendation;

  bool get hasUnsafeOutput =>
      designStatus.isUnsafe ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId) ||
      proposedMethodNames.any(_methodImpliesForbiddenBehavior);

  Map<String, Object?> toJson() => <String, Object?>{
    'componentId': componentId.wire,
    'designStatus': designStatus.wire,
    'sourceValidationRowIds': sourceValidationRowIds,
    'sourceSummaryRecordIds': sourceSummaryRecordIds,
    'sourceGateRecordIds': sourceGateRecordIds,
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
    'proposedClassNames': proposedClassNames,
    'proposedMethodNames': proposedMethodNames,
    'proposedFileNames': proposedFileNames,
    'designOnly': designOnly,
    'allowedForFutureSkeleton': allowedForFutureSkeleton,
    'contextOnly': contextOnly,
    'inactive': inactive,
    'safeForPhase33F': safeForPhase33F,
    'recommendation': recommendation.wire,
  };
}

class DebugOnlyBridgeImplementationDesignRecord {
  const DebugOnlyBridgeImplementationDesignRecord({
    required this.implementationDesignRecordId,
    required this.sourceValidationRowId,
    required this.sourceSummaryRecordId,
    required this.sourceSummaryRole,
    required this.sourceGateRecordId,
    required this.sourceGateGroupId,
    required this.sourceDesignRecordId,
    required this.componentRole,
    required this.designStatus,
    required this.designOnly,
    required this.allowedForFutureSkeleton,
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
    required this.proposedClassNames,
    required this.proposedMethodNames,
    required this.proposedFileNames,
    required this.safetyFlags,
    required this.violationReasons,
    required this.recommendation,
  });

  final String implementationDesignRecordId;
  final String sourceValidationRowId;
  final String sourceSummaryRecordId;
  final DebugBridgePrototypeDesignReadinessSummaryRole sourceSummaryRole;
  final String sourceGateRecordId;
  final DebugBridgePrototypeDesignReadinessGateGroupId sourceGateGroupId;
  final String sourceDesignRecordId;
  final DebugOnlyBridgeImplementationDesignComponentRole componentRole;
  final DebugOnlyBridgeImplementationDesignItemStatus designStatus;
  final bool designOnly;
  final bool allowedForFutureSkeleton;
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
  final List<String> proposedClassNames;
  final List<String> proposedMethodNames;
  final List<String> proposedFileNames;
  final Map<String, bool> safetyFlags;
  final List<String> violationReasons;
  final DebugOnlyBridgeImplementationDesignRecommendation recommendation;

  bool get hasUnsafeOutput =>
      designStatus.isUnsafe ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId) ||
      safetyFlags.values.any((value) => value) ||
      proposedMethodNames.any(_methodImpliesForbiddenBehavior);

  DebugOnlyBridgeImplementationDesignRecord copyWith({
    String? implementationDesignRecordId,
    String? sourceValidationRowId,
    String? sourceSummaryRecordId,
    DebugBridgePrototypeDesignReadinessSummaryRole? sourceSummaryRole,
    String? sourceGateRecordId,
    DebugBridgePrototypeDesignReadinessGateGroupId? sourceGateGroupId,
    String? sourceDesignRecordId,
    DebugOnlyBridgeImplementationDesignComponentRole? componentRole,
    DebugOnlyBridgeImplementationDesignItemStatus? designStatus,
    bool? designOnly,
    bool? allowedForFutureSkeleton,
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
    List<String>? proposedClassNames,
    List<String>? proposedMethodNames,
    List<String>? proposedFileNames,
    Map<String, bool>? safetyFlags,
    List<String>? violationReasons,
    DebugOnlyBridgeImplementationDesignRecommendation? recommendation,
  }) {
    return DebugOnlyBridgeImplementationDesignRecord(
      implementationDesignRecordId:
          implementationDesignRecordId ?? this.implementationDesignRecordId,
      sourceValidationRowId:
          sourceValidationRowId ?? this.sourceValidationRowId,
      sourceSummaryRecordId:
          sourceSummaryRecordId ?? this.sourceSummaryRecordId,
      sourceSummaryRole: sourceSummaryRole ?? this.sourceSummaryRole,
      sourceGateRecordId: sourceGateRecordId ?? this.sourceGateRecordId,
      sourceGateGroupId: sourceGateGroupId ?? this.sourceGateGroupId,
      sourceDesignRecordId: sourceDesignRecordId ?? this.sourceDesignRecordId,
      componentRole: componentRole ?? this.componentRole,
      designStatus: designStatus ?? this.designStatus,
      designOnly: designOnly ?? this.designOnly,
      allowedForFutureSkeleton:
          allowedForFutureSkeleton ?? this.allowedForFutureSkeleton,
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
      proposedClassNames: proposedClassNames ?? this.proposedClassNames,
      proposedMethodNames: proposedMethodNames ?? this.proposedMethodNames,
      proposedFileNames: proposedFileNames ?? this.proposedFileNames,
      safetyFlags: safetyFlags ?? this.safetyFlags,
      violationReasons: violationReasons ?? this.violationReasons,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'implementationDesignRecordId': implementationDesignRecordId,
    'sourceValidationRowId': sourceValidationRowId,
    'sourceSummaryRecordId': sourceSummaryRecordId,
    'sourceSummaryRole': sourceSummaryRole.wire,
    'sourceGateRecordId': sourceGateRecordId,
    'sourceGateGroupId': sourceGateGroupId.wire,
    'sourceDesignRecordId': sourceDesignRecordId,
    'componentRole': componentRole.wire,
    'designStatus': designStatus.wire,
    'designOnly': designOnly,
    'allowedForFutureSkeleton': allowedForFutureSkeleton,
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
    'proposedClassNames': proposedClassNames,
    'proposedMethodNames': proposedMethodNames,
    'proposedFileNames': proposedFileNames,
    'safetyFlags': safetyFlags,
    'violationReasons': violationReasons,
    'recommendation': recommendation.wire,
  };
}

class DebugOnlyBridgeImplementationDesignFinding {
  const DebugOnlyBridgeImplementationDesignFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.implementationDesignRecordId,
    this.componentId,
    this.fieldId,
    this.caseId,
    this.methodName,
  });

  final String id;
  final DebugOnlyBridgeImplementationDesignSeverity severity;
  final String message;
  final String? implementationDesignRecordId;
  final DebugOnlyBridgeImplementationDesignComponentId? componentId;
  final String? fieldId;
  final String? caseId;
  final String? methodName;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical => severity.isCritical;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'severity': severity.wire,
    'message': message,
    if (implementationDesignRecordId != null)
      'implementationDesignRecordId': implementationDesignRecordId,
    if (componentId != null) 'componentId': componentId!.wire,
    if (fieldId != null) 'fieldId': fieldId,
    if (caseId != null) 'caseId': caseId,
    if (methodName != null) 'methodName': methodName,
  };
}

class DebugOnlyBridgeImplementationDesignResult {
  const DebugOnlyBridgeImplementationDesignResult({
    required this.implementationDesignStatus,
    required this.sourceReadinessSummaryValidationStatus,
    required this.sourceReadinessSummaryStatus,
    required this.sourceReadinessGateStatus,
    required this.sourcePrototypeValidationStatus,
    required this.sourcePrototypeDesignStatus,
    required this.components,
    required this.implementationDesignRecords,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalComponents,
    required this.totalImplementationDesignRecords,
    required this.inputContractDesignCount,
    required this.coreRecordDesignCount,
    required this.contextRecordDesignCount,
    required this.inactiveBlockedRecordDesignCount,
    required this.inactiveFutureRecordDesignCount,
    required this.allowedFieldContractCount,
    required this.deniedFieldContractCount,
    required this.runtimeBlockDesignCount,
    required this.proofBoundaryDesignCount,
    required this.ownerProofBoundaryDesignCount,
    required this.skeletonPlanDesignCount,
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
    required this.proposedClassNames,
    required this.proposedMethodNames,
    required this.proposedFileNames,
    required this.safeForPhase33F,
    required this.phase33FRecommendation,
    this.developerOnly = true,
    this.debugBridgeRuntimeImplemented = false,
    this.executableBridgeSkeletonImplemented = false,
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

  final DebugOnlyBridgeImplementationDesignStatus implementationDesignStatus;
  final DebugBridgePrototypeDesignReadinessSummaryValidationStatus
  sourceReadinessSummaryValidationStatus;
  final DebugBridgePrototypeDesignReadinessSummaryStatus
  sourceReadinessSummaryStatus;
  final DebugBridgePrototypeDesignReadinessGateStatus sourceReadinessGateStatus;
  final DebugOnlyBridgePrototypeDesignValidationStatus
  sourcePrototypeValidationStatus;
  final DebugOnlyBridgePrototypeDesignStatus sourcePrototypeDesignStatus;
  final List<DebugOnlyBridgeImplementationDesignComponent> components;
  final List<DebugOnlyBridgeImplementationDesignRecord>
  implementationDesignRecords;
  final List<DebugOnlyBridgeImplementationDesignFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalComponents;
  final int totalImplementationDesignRecords;
  final int inputContractDesignCount;
  final int coreRecordDesignCount;
  final int contextRecordDesignCount;
  final int inactiveBlockedRecordDesignCount;
  final int inactiveFutureRecordDesignCount;
  final int allowedFieldContractCount;
  final int deniedFieldContractCount;
  final int runtimeBlockDesignCount;
  final int proofBoundaryDesignCount;
  final int ownerProofBoundaryDesignCount;
  final int skeletonPlanDesignCount;
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
  final List<String> proposedClassNames;
  final List<String> proposedMethodNames;
  final List<String> proposedFileNames;
  final bool safeForPhase33F;
  final DebugOnlyBridgeImplementationDesignPhase33FRecommendation
  phase33FRecommendation;
  final bool developerOnly;
  final bool debugBridgeRuntimeImplemented;
  final bool executableBridgeSkeletonImplemented;
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
      implementationDesignStatus ==
          DebugOnlyBridgeImplementationDesignStatus
              .blockedByUnsafeReadinessValidation ||
      implementationDesignStatus ==
          DebugOnlyBridgeImplementationDesignStatus.blockedByPolicyBoundary ||
      implementationDesignStatus ==
          DebugOnlyBridgeImplementationDesignStatus.invalid ||
      unsafeCount > 0 ||
      blockerCount > 0 ||
      criticalCount > 0;

  bool get hasUnsafeDebugOnlyBridgeImplementationDesignPolicyViolation =>
      implementationDesignStatus ==
          DebugOnlyBridgeImplementationDesignStatus
              .blockedByUnsafeReadinessValidation ||
      implementationDesignStatus ==
          DebugOnlyBridgeImplementationDesignStatus.blockedByPolicyBoundary ||
      unsafeCount > 0 ||
      criticalCount > 0 ||
      debugBridgeRuntimeImplemented ||
      executableBridgeSkeletonImplemented ||
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
      pvDumpFieldActive ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId) ||
      proposedMethodNames.any(_methodImpliesForbiddenBehavior);

  DebugOnlyBridgeImplementationDesignComponent component(
    DebugOnlyBridgeImplementationDesignComponentId componentId,
  ) {
    return components.singleWhere(
      (component) => component.componentId == componentId,
    );
  }

  DebugOnlyBridgeImplementationDesignRecord recordForRole(
    DebugOnlyBridgeImplementationDesignComponentRole role,
  ) {
    return implementationDesignRecords.singleWhere(
      (record) => record.componentRole == role,
    );
  }

  DebugOnlyBridgeImplementationDesignResult copyWith({
    DebugOnlyBridgeImplementationDesignStatus? implementationDesignStatus,
    DebugBridgePrototypeDesignReadinessSummaryValidationStatus?
    sourceReadinessSummaryValidationStatus,
    DebugBridgePrototypeDesignReadinessSummaryStatus?
    sourceReadinessSummaryStatus,
    DebugBridgePrototypeDesignReadinessGateStatus? sourceReadinessGateStatus,
    DebugOnlyBridgePrototypeDesignValidationStatus?
    sourcePrototypeValidationStatus,
    DebugOnlyBridgePrototypeDesignStatus? sourcePrototypeDesignStatus,
    List<DebugOnlyBridgeImplementationDesignComponent>? components,
    List<DebugOnlyBridgeImplementationDesignRecord>?
    implementationDesignRecords,
    List<DebugOnlyBridgeImplementationDesignFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalComponents,
    int? totalImplementationDesignRecords,
    int? inputContractDesignCount,
    int? coreRecordDesignCount,
    int? contextRecordDesignCount,
    int? inactiveBlockedRecordDesignCount,
    int? inactiveFutureRecordDesignCount,
    int? allowedFieldContractCount,
    int? deniedFieldContractCount,
    int? runtimeBlockDesignCount,
    int? proofBoundaryDesignCount,
    int? ownerProofBoundaryDesignCount,
    int? skeletonPlanDesignCount,
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
    List<String>? proposedClassNames,
    List<String>? proposedMethodNames,
    List<String>? proposedFileNames,
    bool? safeForPhase33F,
    DebugOnlyBridgeImplementationDesignPhase33FRecommendation?
    phase33FRecommendation,
    bool? developerOnly,
    bool? debugBridgeRuntimeImplemented,
    bool? executableBridgeSkeletonImplemented,
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
    return DebugOnlyBridgeImplementationDesignResult(
      implementationDesignStatus:
          implementationDesignStatus ?? this.implementationDesignStatus,
      sourceReadinessSummaryValidationStatus:
          sourceReadinessSummaryValidationStatus ??
          this.sourceReadinessSummaryValidationStatus,
      sourceReadinessSummaryStatus:
          sourceReadinessSummaryStatus ?? this.sourceReadinessSummaryStatus,
      sourceReadinessGateStatus:
          sourceReadinessGateStatus ?? this.sourceReadinessGateStatus,
      sourcePrototypeValidationStatus:
          sourcePrototypeValidationStatus ??
          this.sourcePrototypeValidationStatus,
      sourcePrototypeDesignStatus:
          sourcePrototypeDesignStatus ?? this.sourcePrototypeDesignStatus,
      components: components ?? this.components,
      implementationDesignRecords:
          implementationDesignRecords ?? this.implementationDesignRecords,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalComponents: totalComponents ?? this.totalComponents,
      totalImplementationDesignRecords:
          totalImplementationDesignRecords ??
          this.totalImplementationDesignRecords,
      inputContractDesignCount:
          inputContractDesignCount ?? this.inputContractDesignCount,
      coreRecordDesignCount:
          coreRecordDesignCount ?? this.coreRecordDesignCount,
      contextRecordDesignCount:
          contextRecordDesignCount ?? this.contextRecordDesignCount,
      inactiveBlockedRecordDesignCount:
          inactiveBlockedRecordDesignCount ??
          this.inactiveBlockedRecordDesignCount,
      inactiveFutureRecordDesignCount:
          inactiveFutureRecordDesignCount ??
          this.inactiveFutureRecordDesignCount,
      allowedFieldContractCount:
          allowedFieldContractCount ?? this.allowedFieldContractCount,
      deniedFieldContractCount:
          deniedFieldContractCount ?? this.deniedFieldContractCount,
      runtimeBlockDesignCount:
          runtimeBlockDesignCount ?? this.runtimeBlockDesignCount,
      proofBoundaryDesignCount:
          proofBoundaryDesignCount ?? this.proofBoundaryDesignCount,
      ownerProofBoundaryDesignCount:
          ownerProofBoundaryDesignCount ?? this.ownerProofBoundaryDesignCount,
      skeletonPlanDesignCount:
          skeletonPlanDesignCount ?? this.skeletonPlanDesignCount,
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
      proposedClassNames: proposedClassNames ?? this.proposedClassNames,
      proposedMethodNames: proposedMethodNames ?? this.proposedMethodNames,
      proposedFileNames: proposedFileNames ?? this.proposedFileNames,
      safeForPhase33F: safeForPhase33F ?? this.safeForPhase33F,
      phase33FRecommendation:
          phase33FRecommendation ?? this.phase33FRecommendation,
      developerOnly: developerOnly ?? this.developerOnly,
      debugBridgeRuntimeImplemented:
          debugBridgeRuntimeImplemented ?? this.debugBridgeRuntimeImplemented,
      executableBridgeSkeletonImplemented:
          executableBridgeSkeletonImplemented ??
          this.executableBridgeSkeletonImplemented,
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
      ..writeln('# Debug-Only Bridge Implementation Design')
      ..writeln()
      ..writeln('- version: $debugOnlyBridgeImplementationDesignReportVersion')
      ..writeln(
        '- implementation design status: ${implementationDesignStatus.wire}',
      )
      ..writeln(
        '- source readiness summary validation status: '
        '${sourceReadinessSummaryValidationStatus.wire}',
      )
      ..writeln('- total components: $totalComponents')
      ..writeln(
        '- total implementation design records: '
        '$totalImplementationDesignRecords',
      )
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln(
        '- debug bridge runtime implemented: $debugBridgeRuntimeImplemented',
      )
      ..writeln(
        '- executable bridge skeleton implemented: '
        '$executableBridgeSkeletonImplemented',
      )
      ..writeln(
        '- executable debug bridge prototype implemented: '
        '$executableDebugBridgePrototypeImplemented',
      )
      ..writeln(
        '- implementation wiring implemented: $implementationWiringImplemented',
      )
      ..writeln('- safeForPhase33F: $safeForPhase33F')
      ..writeln('- Phase 33F recommendation: ${phase33FRecommendation.wire}')
      ..writeln()
      ..writeln('## Component Table')
      ..writeln(
        '| Component | Status | Classes | Methods | Files | Safe | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
    for (final component in components) {
      buffer.writeln(
        '| ${component.componentId.wire} | ${component.designStatus.wire} | '
        '${_ids(component.proposedClassNames)} | '
        '${_ids(component.proposedMethodNames)} | '
        '${_ids(component.proposedFileNames)} | '
        '${component.safeForPhase33F} | ${component.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Implementation Design Record Table')
      ..writeln(
        '| Record | Role | Status | Source summary | Allowed fields | Denied fields | Classes | Methods | Design-only | Context-only | Inactive | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final record in implementationDesignRecords) {
      buffer.writeln(
        '| ${record.implementationDesignRecordId} | '
        '${record.componentRole.wire} | ${record.designStatus.wire} | '
        '${record.sourceSummaryRole.wire} | ${_ids(record.allowedFieldIds)} | '
        '${_ids(record.deniedFieldIds)} | '
        '${_ids(record.proposedClassNames)} | '
        '${_ids(record.proposedMethodNames)} | ${record.designOnly} | '
        '${record.contextOnly} | ${record.inactive} | '
        '${record.recommendation.wire} |',
      );
    }
    final core = recordForRole(
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeCoreRecord,
    );
    final context = recordForRole(
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeContextRecord,
    );
    final blocked = recordForRole(
      DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeInactiveBlockedRecord,
    );
    final future = recordForRole(
      DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeInactiveFutureRecord,
    );
    final allowed = recordForRole(
      DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeAllowedFieldContract,
    );
    final denied = recordForRole(
      DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeDeniedFieldContract,
    );
    final runtime = recordForRole(
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeRuntimeBlock,
    );
    final proof = recordForRole(
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeProofBoundary,
    );
    final owner = recordForRole(
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeOwnerProofBoundary,
    );
    final requirement = recordForRole(
      DebugOnlyBridgeImplementationDesignComponentRole
          .phase33FImplementationSkeletonRequirement,
    );
    buffer
      ..writeln()
      ..writeln('## Proposed Future Skeleton Classes')
      ..writeln(_bulletList(proposedClassNames))
      ..writeln()
      ..writeln('## Proposed Future Skeleton Files')
      ..writeln(_bulletList(proposedFileNames))
      ..writeln()
      ..writeln('## Input Contract Design')
      ..writeln(
        '- input object: DebugOnlyBridgeInputPacket; proposed safe methods: '
        '${_ids(recordForRole(DebugOnlyBridgeImplementationDesignComponentRole.bridgeInputContract).proposedMethodNames)}',
      )
      ..writeln()
      ..writeln('## Core/Context/Inactive Record Design')
      ..writeln(
        '- core source: ${core.sourceSummaryRole.wire}; context-only: '
        '${core.contextOnly}; inactive: ${core.inactive}',
      )
      ..writeln(
        '- context source: ${context.sourceSummaryRole.wire}; context-only: '
        '${context.contextOnly}; inactive: ${context.inactive}',
      )
      ..writeln(
        '- blocked inactive: ${blocked.inactive}; future inactive: '
        '${future.inactive}',
      )
      ..writeln()
      ..writeln('## Allowed And Denied Field Contract Design')
      ..writeln('- allowed field IDs: ${_ids(allowed.allowedFieldIds)}')
      ..writeln('- denied field IDs: ${_ids(denied.deniedFieldIds)}')
      ..writeln()
      ..writeln('## Runtime/Prototype/Wiring Blocked Design')
      ..writeln('- blocked boundary IDs: ${_ids(runtime.blockedBoundaryIds)}')
      ..writeln(
        '- executable bridge skeleton implemented: '
        '$executableBridgeSkeletonImplemented',
      )
      ..writeln()
      ..writeln('## Android Proof Boundary')
      ..writeln('- captured proof IDs: ${_ids(proof.androidProofCaseIds)}')
      ..writeln()
      ..writeln('## Owner Proof Boundary')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- owner proof record inactive: ${owner.inactive}')
      ..writeln()
      ..writeln('## Phase 33F Skeleton Requirement')
      ..writeln(
        '- future prerequisites: ${_ids(requirement.futurePrerequisites)}',
      )
      ..writeln()
      ..writeln('## Findings');
    if (validationFindings.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final finding in validationFindings) {
        buffer.writeln(
          '- ${finding.severity.wire}: ${finding.id}: '
          '${_cell(finding.message)}',
        );
      }
    }
    buffer
      ..writeln()
      ..writeln('## Phase 33F Recommendation')
      ..writeln('- ${phase33FRecommendation.wire}');
    return buffer.toString();
  }

  String renderJsonReport() {
    return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'version': debugOnlyBridgeImplementationDesignReportVersion,
      'implementationDesignStatus': implementationDesignStatus.wire,
      'sourceReadinessSummaryValidationStatus':
          sourceReadinessSummaryValidationStatus.wire,
      'sourceReadinessSummaryStatus': sourceReadinessSummaryStatus.wire,
      'sourceReadinessGateStatus': sourceReadinessGateStatus.wire,
      'sourcePrototypeValidationStatus': sourcePrototypeValidationStatus.wire,
      'sourcePrototypeDesignStatus': sourcePrototypeDesignStatus.wire,
      'components': components.map((component) => component.toJson()).toList(),
      'implementationDesignRecords': implementationDesignRecords
          .map((record) => record.toJson())
          .toList(),
      'validationFindings': validationFindings
          .map((finding) => finding.toJson())
          .toList(),
      'warnings': warnings,
      'failures': failures,
      'totalComponents': totalComponents,
      'totalImplementationDesignRecords': totalImplementationDesignRecords,
      'inputContractDesignCount': inputContractDesignCount,
      'coreRecordDesignCount': coreRecordDesignCount,
      'contextRecordDesignCount': contextRecordDesignCount,
      'inactiveBlockedRecordDesignCount': inactiveBlockedRecordDesignCount,
      'inactiveFutureRecordDesignCount': inactiveFutureRecordDesignCount,
      'allowedFieldContractCount': allowedFieldContractCount,
      'deniedFieldContractCount': deniedFieldContractCount,
      'runtimeBlockDesignCount': runtimeBlockDesignCount,
      'proofBoundaryDesignCount': proofBoundaryDesignCount,
      'ownerProofBoundaryDesignCount': ownerProofBoundaryDesignCount,
      'skeletonPlanDesignCount': skeletonPlanDesignCount,
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
      'proposedClassNames': proposedClassNames,
      'proposedMethodNames': proposedMethodNames,
      'proposedFileNames': proposedFileNames,
      'safeForPhase33F': safeForPhase33F,
      'phase33FRecommendation': phase33FRecommendation.wire,
      'guardrails': <String, Object?>{
        'developerOnly': developerOnly,
        'debugBridgeRuntimeImplemented': debugBridgeRuntimeImplemented,
        'executableBridgeSkeletonImplemented':
            executableBridgeSkeletonImplemented,
        'executableDebugBridgePrototypeImplemented':
            executableDebugBridgePrototypeImplemented,
        'implementationWiringImplemented': implementationWiringImplemented,
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
    });
  }
}

class DebugOnlyBridgeImplementationDesign {
  const DebugOnlyBridgeImplementationDesign({
    this.validator = const DebugOnlyBridgeImplementationDesignValidator(),
  });

  final DebugOnlyBridgeImplementationDesignValidator validator;

  DebugOnlyBridgeImplementationDesignResult evaluate([
    DebugOnlyBridgeImplementationDesignRequest request =
        const DebugOnlyBridgeImplementationDesignRequest(),
  ]) {
    final bridgeReadinessGateResult =
        request.bridgeReadinessGateResult ??
        request.bridgeReadinessGate.evaluate(
          DebugBridgeReadinessValidationGateRequest(
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final prototypeDesignResult =
        request.prototypeDesignResult ??
        request.prototypeDesign.evaluate(
          DebugOnlyBridgePrototypeDesignRequest(
            gateResult: bridgeReadinessGateResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final prototypeValidationResult =
        request.prototypeValidationResult ??
        request.prototypeValidation.evaluate(
          DebugOnlyBridgePrototypeDesignValidationRequest(
            designResult: prototypeDesignResult,
            gateResult: bridgeReadinessGateResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final readinessGateResult =
        request.readinessGateResult ??
        request.readinessGate.evaluate(
          DebugBridgePrototypeDesignReadinessGateRequest(
            validationResult: prototypeValidationResult,
            designResult: prototypeDesignResult,
            gateResult: bridgeReadinessGateResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final readinessSummaryResult =
        request.readinessSummaryResult ??
        request.readinessSummary.evaluate(
          DebugBridgePrototypeDesignReadinessSummaryRequest(
            readinessGateResult: readinessGateResult,
            validationResult: prototypeValidationResult,
            designResult: prototypeDesignResult,
            bridgeReadinessGateResult: bridgeReadinessGateResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final readinessSummaryValidationResult =
        request.readinessSummaryValidationResult ??
        request.readinessSummaryValidation.evaluate(
          DebugBridgePrototypeDesignReadinessSummaryValidationRequest(
            summaryResult: readinessSummaryResult,
            readinessGateResult: readinessGateResult,
            validationResult: prototypeValidationResult,
            designResult: prototypeDesignResult,
            bridgeReadinessGateResult: bridgeReadinessGateResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );

    final records = _recordsFromValidation(
      readinessSummaryValidationResult,
      readinessSummaryResult,
    );
    final components = _componentsFromRecords(records);
    final base = _resultFromDesign(
      readinessSummaryValidationResult: readinessSummaryValidationResult,
      readinessSummaryResult: readinessSummaryResult,
      readinessGateResult: readinessGateResult,
      prototypeValidationResult: prototypeValidationResult,
      prototypeDesignResult: prototypeDesignResult,
      records: records,
      components: components,
      validationFindings: const <DebugOnlyBridgeImplementationDesignFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromDesign(
      readinessSummaryValidationResult: readinessSummaryValidationResult,
      readinessSummaryResult: readinessSummaryResult,
      readinessGateResult: readinessGateResult,
      prototypeValidationResult: prototypeValidationResult,
      prototypeDesignResult: prototypeDesignResult,
      records: records,
      components: components,
      validationFindings: findings,
    );
  }
}

class DebugOnlyBridgeImplementationDesignValidator {
  const DebugOnlyBridgeImplementationDesignValidator();

  List<DebugOnlyBridgeImplementationDesignFinding> validate(
    DebugOnlyBridgeImplementationDesignResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <DebugOnlyBridgeImplementationDesignFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);

    void add({
      required String id,
      required DebugOnlyBridgeImplementationDesignSeverity severity,
      required String message,
      String? implementationDesignRecordId,
      DebugOnlyBridgeImplementationDesignComponentId? componentId,
      String? fieldId,
      String? caseId,
      String? methodName,
    }) {
      findings.add(
        DebugOnlyBridgeImplementationDesignFinding(
          id: id,
          severity: severity,
          message: message,
          implementationDesignRecordId: implementationDesignRecordId,
          componentId: componentId,
          fieldId: fieldId,
          caseId: caseId,
          methodName: methodName,
        ),
      );
    }

    if (result.safeForPhase33F &&
        (result.sourceReadinessSummaryValidationStatus ==
                DebugBridgePrototypeDesignReadinessSummaryValidationStatus
                    .blockedByUnsafeSummary ||
            result.sourceReadinessSummaryValidationStatus ==
                DebugBridgePrototypeDesignReadinessSummaryValidationStatus
                    .blockedByPolicyBoundary ||
            result.unsafeCount > 0)) {
      add(
        id: 'unsafePhase33DValidationMarkedImplementationDesignReady',
        severity: DebugOnlyBridgeImplementationDesignSeverity.critical,
        message: 'unsafe Phase 33D validation cannot be implementation-ready',
      );
    }
    if (result.futureRequirementCount != 1) {
      add(
        id: 'missingPhase33FImplementationSkeletonRequirement',
        severity: DebugOnlyBridgeImplementationDesignSeverity.critical,
        message: 'Phase 33F developer skeleton requirement must be present',
      );
    }
    for (final fieldId in _deniedFieldIds) {
      if (!result.deniedFieldIds.contains(fieldId)) {
        add(
          id: 'deniedFieldMissing',
          severity: DebugOnlyBridgeImplementationDesignSeverity.blocker,
          message: '$fieldId must remain denied',
          fieldId: fieldId,
        );
      }
    }
    for (final fieldId in result.allowedFieldIds) {
      _checkActiveAllowedField(add, fieldId);
    }
    if (!_sameStringSet(result.androidProofCaseIds, _capturedAndroidProofIds)) {
      add(
        id: 'androidProofBoundaryMismatch',
        severity: DebugOnlyBridgeImplementationDesignSeverity.critical,
        message: 'Android proof IDs must remain exactly captured proof only',
      );
    }
    for (final caseId in result.androidProofCaseIds) {
      _checkAndroidProofCase(add, caseId, provenAndroidIds);
    }
    for (final component in result.components) {
      for (final fieldId in component.allowedFieldIds) {
        _checkActiveAllowedField(
          add,
          fieldId,
          componentId: component.componentId,
        );
      }
      for (final caseId in component.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          componentId: component.componentId,
        );
      }
      for (final methodName in component.proposedMethodNames) {
        _checkProposedMethodName(
          add,
          methodName,
          componentId: component.componentId,
        );
      }
    }
    for (final record in result.implementationDesignRecords) {
      for (final fieldId in record.allowedFieldIds) {
        _checkActiveAllowedField(
          add,
          fieldId,
          implementationDesignRecordId: record.implementationDesignRecordId,
        );
      }
      for (final caseId in record.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          implementationDesignRecordId: record.implementationDesignRecordId,
        );
      }
      for (final methodName in record.proposedMethodNames) {
        _checkProposedMethodName(
          add,
          methodName,
          implementationDesignRecordId: record.implementationDesignRecordId,
        );
      }
      _checkRecordBoundary(add, record);
      _checkSafetyFlags(add, record);
    }
    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: DebugOnlyBridgeImplementationDesignSeverity.blocker,
        message: 'owner proof requires explicit PV/MultiPV reason',
      );
    }
    if (result.debugBridgeRuntimeImplemented ||
        result.executableBridgeSkeletonImplemented ||
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
        id: 'debugOnlyBridgeImplementationDesignBoundaryPolicyViolation',
        severity: DebugOnlyBridgeImplementationDesignSeverity.critical,
        message: 'debug-only bridge implementation design crossed a boundary',
      );
    }
    return findings..sort(_compareFindings);
  }

  List<DebugOnlyBridgeImplementationDesignFinding> validateReportText(
    String reportText,
  ) {
    final findings = <DebugOnlyBridgeImplementationDesignFinding>[];
    void reportError(String id, String message) {
      findings.add(
        DebugOnlyBridgeImplementationDesignFinding(
          id: id,
          severity: DebugOnlyBridgeImplementationDesignSeverity.critical,
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
        reportText.contains('executable bridge skeleton implemented: true') ||
        reportText.contains(
          'executable debug bridge prototype implemented: true',
        ) ||
        reportText.contains('implementation wiring implemented: true')) {
      reportError(
        'runtimeImplementationReportText',
        'report contains active runtime, executable skeleton, or wiring text',
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

List<DebugOnlyBridgeImplementationDesignRecord> _recordsFromValidation(
  DebugBridgePrototypeDesignReadinessSummaryValidationResult validationResult,
  DebugBridgePrototypeDesignReadinessSummaryResult summaryResult,
) {
  return DebugOnlyBridgeImplementationDesignComponentRole.values
      .map((role) => _recordFromRole(validationResult, summaryResult, role))
      .toList(growable: false);
}

DebugOnlyBridgeImplementationDesignRecord _recordFromRole(
  DebugBridgePrototypeDesignReadinessSummaryValidationResult validationResult,
  DebugBridgePrototypeDesignReadinessSummaryResult summaryResult,
  DebugOnlyBridgeImplementationDesignComponentRole role,
) {
  final sourceRole = _summaryRoleForImplementationRole(role);
  final summaryRecord = summaryResult.recordForRole(sourceRole);
  final validationRow = validationResult.recordRowForRole(sourceRole);
  final unsafe = summaryRecord.hasUnsafeOutput || validationRow.hasUnsafeOutput;
  final invalid =
      !unsafe &&
      (summaryRecord.summaryStatus.isInvalid ||
          validationRow.validationStatus.isInvalid);
  return DebugOnlyBridgeImplementationDesignRecord(
    implementationDesignRecordId: 'phase33e-${role.wire}',
    sourceValidationRowId: validationRow.validationRowId,
    sourceSummaryRecordId: summaryRecord.summaryRecordId,
    sourceSummaryRole: sourceRole,
    sourceGateRecordId: summaryRecord.sourceGateRecordId,
    sourceGateGroupId: summaryRecord.sourceGateGroupId,
    sourceDesignRecordId: summaryRecord.sourceDesignRecordId,
    componentRole: role,
    designStatus: unsafe
        ? DebugOnlyBridgeImplementationDesignItemStatus.unsafeDesign
        : invalid
        ? DebugOnlyBridgeImplementationDesignItemStatus.invalidDesign
        : _designStatusForRole(role),
    designOnly: true,
    allowedForFutureSkeleton: _allowedForFutureSkeleton(role),
    contextOnly:
        role ==
        DebugOnlyBridgeImplementationDesignComponentRole.bridgeContextRecord,
    inactive: _inactiveByDefault(role),
    allowedFieldIds: _allowedFieldsForRole(validationResult, role),
    deniedFieldIds: _deniedFieldsForRole(validationResult, role),
    supportCaseIds: _sortedStrings(summaryRecord.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(
      summaryRecord.newlyAddedSupportCaseIds,
    ),
    androidProofCaseIds:
        role ==
            DebugOnlyBridgeImplementationDesignComponentRole.bridgeProofBoundary
        ? _sortedStrings(validationResult.androidProofCaseIds)
        : const <String>[],
    warningReasons: _warningReasonsForRole(summaryRecord, role),
    proofLimitReasons: _sortedStrings(summaryRecord.proofLimitReasons),
    futurePrerequisites: _futurePrerequisitesForRole(summaryRecord, role),
    blockedBoundaryIds: _blockedBoundaryIdsForRole(summaryRecord, role),
    proposedClassNames: _proposedClassesForRole(role),
    proposedMethodNames: _proposedMethodsForRole(role),
    proposedFileNames: _proposedFilesForRole(role),
    safetyFlags: _safeFlags(),
    violationReasons: _sortedStrings(<String>[
      ...summaryRecord.violationReasons,
      ...validationRow.violationReasons,
    ]),
    recommendation: _recommendationForRole(role),
  );
}

List<DebugOnlyBridgeImplementationDesignComponent> _componentsFromRecords(
  List<DebugOnlyBridgeImplementationDesignRecord> records,
) {
  return DebugOnlyBridgeImplementationDesignComponentId.values
      .map((componentId) {
        final role = _roleForComponent(componentId);
        final record = records.singleWhere(
          (record) => record.componentRole == role,
        );
        return DebugOnlyBridgeImplementationDesignComponent(
          componentId: componentId,
          designStatus: record.designStatus,
          sourceValidationRowIds: <String>[record.sourceValidationRowId],
          sourceSummaryRecordIds: <String>[record.sourceSummaryRecordId],
          sourceGateRecordIds: <String>[record.sourceGateRecordId],
          sourceDesignRecordIds: <String>[record.sourceDesignRecordId],
          allowedFieldIds: record.allowedFieldIds,
          deniedFieldIds: record.deniedFieldIds,
          supportCaseIds: record.supportCaseIds,
          newlyAddedSupportCaseIds: record.newlyAddedSupportCaseIds,
          androidProofCaseIds: record.androidProofCaseIds,
          warningReasons: record.warningReasons,
          proofLimitReasons: record.proofLimitReasons,
          futurePrerequisites: record.futurePrerequisites,
          blockedBoundaryIds: record.blockedBoundaryIds,
          proposedClassNames: record.proposedClassNames,
          proposedMethodNames: record.proposedMethodNames,
          proposedFileNames: record.proposedFileNames,
          designOnly: record.designOnly,
          allowedForFutureSkeleton: record.allowedForFutureSkeleton,
          contextOnly: record.contextOnly,
          inactive: record.inactive,
          safeForPhase33F:
              !record.hasUnsafeOutput && !record.designStatus.isInvalid,
          recommendation: record.recommendation,
        );
      })
      .toList(growable: false);
}

DebugOnlyBridgeImplementationDesignResult _resultFromDesign({
  required DebugBridgePrototypeDesignReadinessSummaryValidationResult
  readinessSummaryValidationResult,
  required DebugBridgePrototypeDesignReadinessSummaryResult
  readinessSummaryResult,
  required DebugBridgePrototypeDesignReadinessGateResult readinessGateResult,
  required DebugOnlyBridgePrototypeDesignValidationResult
  prototypeValidationResult,
  required DebugOnlyBridgePrototypeDesignResult prototypeDesignResult,
  required List<DebugOnlyBridgeImplementationDesignRecord> records,
  required List<DebugOnlyBridgeImplementationDesignComponent> components,
  required List<DebugOnlyBridgeImplementationDesignFinding> validationFindings,
}) {
  final unsafeCount =
      readinessSummaryValidationResult.unsafeRecordCount +
      records.where((record) => record.hasUnsafeOutput).length +
      components.where((component) => component.hasUnsafeOutput).length;
  final blockerCount = validationFindings
      .where((finding) => finding.blocksStrict)
      .length;
  final criticalCount = validationFindings
      .where((finding) => finding.isCritical)
      .length;
  final proposedClassNames = _sortedStrings(
    records.expand((record) => record.proposedClassNames),
  );
  final proposedMethodNames = _sortedStrings(
    records.expand((record) => record.proposedMethodNames),
  );
  final proposedFileNames = _sortedStrings(
    records.expand((record) => record.proposedFileNames),
  );
  final base = DebugOnlyBridgeImplementationDesignResult(
    implementationDesignStatus:
        DebugOnlyBridgeImplementationDesignStatus.invalid,
    sourceReadinessSummaryValidationStatus:
        readinessSummaryValidationResult.validationStatus,
    sourceReadinessSummaryStatus: readinessSummaryResult.summaryStatus,
    sourceReadinessGateStatus: readinessGateResult.gateStatus,
    sourcePrototypeValidationStatus: prototypeValidationResult.validationStatus,
    sourcePrototypeDesignStatus: prototypeDesignResult.designStatus,
    components: components,
    implementationDesignRecords: records,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...readinessSummaryValidationResult.warnings,
      ...records.expand((record) => record.warningReasons),
      'Phase 33E is implementation-design only; Phase 33F may create a non-executable developer skeleton',
    ]),
    failures: _sortedStrings(<String>[
      ...readinessSummaryValidationResult.failures,
      ...records.expand((record) => record.violationReasons),
      ...validationFindings.map((finding) => finding.message),
    ]),
    totalComponents: components.length,
    totalImplementationDesignRecords: records.length,
    inputContractDesignCount: _countRole(
      records,
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeInputContract,
    ),
    coreRecordDesignCount: _countRole(
      records,
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeCoreRecord,
    ),
    contextRecordDesignCount: _countRole(
      records,
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeContextRecord,
    ),
    inactiveBlockedRecordDesignCount: _countRole(
      records,
      DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeInactiveBlockedRecord,
    ),
    inactiveFutureRecordDesignCount: _countRole(
      records,
      DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeInactiveFutureRecord,
    ),
    allowedFieldContractCount: _countRole(
      records,
      DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeAllowedFieldContract,
    ),
    deniedFieldContractCount: _countRole(
      records,
      DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeDeniedFieldContract,
    ),
    runtimeBlockDesignCount: _countRole(
      records,
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeRuntimeBlock,
    ),
    proofBoundaryDesignCount: _countRole(
      records,
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeProofBoundary,
    ),
    ownerProofBoundaryDesignCount: _countRole(
      records,
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeOwnerProofBoundary,
    ),
    skeletonPlanDesignCount: _countRole(
      records,
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeSkeletonPlan,
    ),
    futureRequirementCount: _countRole(
      records,
      DebugOnlyBridgeImplementationDesignComponentRole
          .phase33FImplementationSkeletonRequirement,
    ),
    unsafeCount: unsafeCount,
    blockerCount: blockerCount,
    criticalCount: criticalCount,
    ownerProofQueueCount: readinessSummaryValidationResult.ownerProofQueueCount,
    supportCaseIds: _sortedStrings(
      readinessSummaryValidationResult.supportCaseIds,
    ),
    newlyAddedSupportCaseIds: _sortedStrings(
      readinessSummaryValidationResult.newlyAddedSupportCaseIds,
    ),
    androidProofCaseIds: _sortedStrings(
      readinessSummaryValidationResult.androidProofCaseIds,
    ),
    allowedFieldIds: _sortedStrings(
      readinessSummaryValidationResult.allowedFieldIds,
    ),
    deniedFieldIds: _sortedStrings(
      readinessSummaryValidationResult.deniedFieldIds,
    ),
    proposedClassNames: proposedClassNames,
    proposedMethodNames: proposedMethodNames,
    proposedFileNames: proposedFileNames,
    safeForPhase33F: false,
    phase33FRecommendation:
        DebugOnlyBridgeImplementationDesignPhase33FRecommendation
            .addMoreGoldenCoverageFirst,
    developerOnly:
        readinessSummaryValidationResult.developerOnly &&
        readinessSummaryResult.developerOnly &&
        readinessGateResult.developerOnly &&
        prototypeValidationResult.developerOnly &&
        prototypeDesignResult.developerOnly,
    debugBridgeRuntimeImplemented:
        readinessSummaryValidationResult.debugBridgeRuntimeImplemented,
    executableBridgeSkeletonImplemented: false,
    executableDebugBridgePrototypeImplemented: readinessSummaryValidationResult
        .executableDebugBridgePrototypeImplemented,
    implementationWiringImplemented:
        readinessSummaryValidationResult.implementationWiringImplemented,
    productOutputActive: readinessSummaryValidationResult.productOutputActive,
    classifierOutputActive:
        readinessSummaryValidationResult.classifierOutputActive,
    finalMoveLabelOutputActive:
        readinessSummaryValidationResult.finalMoveLabelOutputActive,
    officialMetricOutputActive:
        readinessSummaryValidationResult.officialMetricOutputActive,
    cpLossOutputActive: readinessSummaryValidationResult.cpLossOutputActive,
    winProbabilityOutputActive:
        readinessSummaryValidationResult.winProbabilityOutputActive,
    numericOutputActive: readinessSummaryValidationResult.numericOutputActive,
    aggregateScoreOutputActive:
        readinessSummaryValidationResult.aggregateScoreOutputActive,
    moveRankingOutputActive:
        readinessSummaryValidationResult.moveRankingOutputActive,
    quietPreparatoryScopeActivated:
        readinessSummaryValidationResult.quietPreparatoryScopeActivated,
    engineCallsActive: readinessSummaryValidationResult.engineCallsActive,
    persistenceWritesActive:
        readinessSummaryValidationResult.persistenceWritesActive,
    uiTargetsActive: readinessSummaryValidationResult.uiTargetsActive,
    backendOutputActive: readinessSummaryValidationResult.backendOutputActive,
    stockfishCommandFieldActive:
        readinessSummaryValidationResult.stockfishCommandFieldActive,
    rawUciFieldActive: readinessSummaryValidationResult.rawUciFieldActive,
    pvDumpFieldActive: readinessSummaryValidationResult.pvDumpFieldActive,
  );
  final status = _implementationDesignStatusFor(base);
  final safeForPhase33F =
      (status ==
              DebugOnlyBridgeImplementationDesignStatus
                  .implementationDesignReadyWithWarnings ||
          status ==
              DebugOnlyBridgeImplementationDesignStatus
                  .implementationDesignReadyClean) &&
      readinessSummaryValidationResult.safeForPhase33E &&
      !readinessSummaryValidationResult.isStrictlyBlocked &&
      !readinessSummaryValidationResult
          .hasUnsafeDebugBridgePrototypeDesignReadinessSummaryValidationPolicyViolation &&
      unsafeCount == 0 &&
      blockerCount == 0 &&
      criticalCount == 0 &&
      components.every((component) => component.safeForPhase33F) &&
      records.every((record) => !record.hasUnsafeOutput);
  return base.copyWith(
    implementationDesignStatus: status,
    safeForPhase33F: safeForPhase33F,
    phase33FRecommendation: _phase33FRecommendationFor(
      status: status,
      safeForPhase33F: safeForPhase33F,
      ownerProofQueueCount:
          readinessSummaryValidationResult.ownerProofQueueCount,
    ),
  );
}

DebugOnlyBridgeImplementationDesignStatus _implementationDesignStatusFor(
  DebugOnlyBridgeImplementationDesignResult result,
) {
  if (result.debugBridgeRuntimeImplemented ||
      result.executableBridgeSkeletonImplemented ||
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
      result.allowedFieldIds.any(_isLegacyDeniedFieldId) ||
      result.proposedMethodNames.any(_methodImpliesForbiddenBehavior)) {
    return DebugOnlyBridgeImplementationDesignStatus.blockedByPolicyBoundary;
  }
  if (result.sourceReadinessSummaryValidationStatus ==
          DebugBridgePrototypeDesignReadinessSummaryValidationStatus
              .blockedByUnsafeSummary ||
      result.sourceReadinessSummaryValidationStatus ==
          DebugBridgePrototypeDesignReadinessSummaryValidationStatus
              .blockedByPolicyBoundary ||
      result.unsafeCount > 0 ||
      result.criticalCount > 0) {
    return DebugOnlyBridgeImplementationDesignStatus
        .blockedByUnsafeReadinessValidation;
  }
  if (result.blockerCount > 0 ||
      result.futureRequirementCount != 1 ||
      result.components.any((component) => !component.safeForPhase33F) ||
      result.implementationDesignRecords.any(
        (record) => record.designStatus.isInvalid,
      )) {
    return DebugOnlyBridgeImplementationDesignStatus.invalid;
  }
  if (result.warnings.isNotEmpty) {
    return DebugOnlyBridgeImplementationDesignStatus
        .implementationDesignReadyWithWarnings;
  }
  return DebugOnlyBridgeImplementationDesignStatus
      .implementationDesignReadyClean;
}

DebugOnlyBridgeImplementationDesignPhase33FRecommendation
_phase33FRecommendationFor({
  required DebugOnlyBridgeImplementationDesignStatus status,
  required bool safeForPhase33F,
  required int ownerProofQueueCount,
}) {
  if (status ==
          DebugOnlyBridgeImplementationDesignStatus
              .blockedByUnsafeReadinessValidation ||
      status ==
          DebugOnlyBridgeImplementationDesignStatus.blockedByPolicyBoundary) {
    return DebugOnlyBridgeImplementationDesignPhase33FRecommendation
        .blockedByUnsafeImplementationDesign;
  }
  if (ownerProofQueueCount > 0) {
    return DebugOnlyBridgeImplementationDesignPhase33FRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase33F) {
    return DebugOnlyBridgeImplementationDesignPhase33FRecommendation
        .addMoreGoldenCoverageFirst;
  }
  return DebugOnlyBridgeImplementationDesignPhase33FRecommendation
      .proceedToDebugOnlyBridgeDeveloperSkeleton;
}

void _checkRecordBoundary(
  void Function({
    required String id,
    required DebugOnlyBridgeImplementationDesignSeverity severity,
    required String message,
    String? implementationDesignRecordId,
    DebugOnlyBridgeImplementationDesignComponentId? componentId,
    String? fieldId,
    String? caseId,
    String? methodName,
  })
  add,
  DebugOnlyBridgeImplementationDesignRecord record,
) {
  if (!record.designOnly) {
    add(
      id: 'implementationDesignRecordNotDesignOnly',
      severity: DebugOnlyBridgeImplementationDesignSeverity.critical,
      message: 'implementation design records must stay design-only',
      implementationDesignRecordId: record.implementationDesignRecordId,
    );
  }
  if (record.componentRole ==
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeCoreRecord) {
    if (record.contextOnly ||
        record.inactive ||
        record.sourceSummaryRole !=
            DebugBridgePrototypeDesignReadinessSummaryRole
                .readinessApprovedPrototypeCoreSummaryRecord ||
        record.sourceGateGroupId !=
            DebugBridgePrototypeDesignReadinessGateGroupId
                .readinessApprovedPrototypeCoreDesignGroup) {
      add(
        id: 'bridgeCoreDesignConsumesNonCoreInput',
        severity: DebugOnlyBridgeImplementationDesignSeverity.critical,
        message: 'bridge core design can consume only approved core summary',
        implementationDesignRecordId: record.implementationDesignRecordId,
      );
    }
  }
  if (record.componentRole ==
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeContextRecord) {
    if (!record.contextOnly ||
        record.sourceSummaryRole !=
            DebugBridgePrototypeDesignReadinessSummaryRole
                .constrainedPrototypeContextSummaryRecord) {
      add(
        id: 'contextOnlyDesignPromotedToCore',
        severity: DebugOnlyBridgeImplementationDesignSeverity.critical,
        message: 'context-only design cannot become core',
        implementationDesignRecordId: record.implementationDesignRecordId,
      );
    }
  }
  if (record.contextOnly &&
      record.componentRole ==
          DebugOnlyBridgeImplementationDesignComponentRole.bridgeCoreRecord) {
    add(
      id: 'contextOnlyDesignPromotedToCore',
      severity: DebugOnlyBridgeImplementationDesignSeverity.critical,
      message: 'context-only design cannot become core',
      implementationDesignRecordId: record.implementationDesignRecordId,
    );
  }
  if (record.componentRole.isInactiveBoundary &&
      (!record.inactive || record.allowedFieldIds.isNotEmpty)) {
    add(
      id: 'blockedFutureDesignMadeActive',
      severity: DebugOnlyBridgeImplementationDesignSeverity.critical,
      message:
          'blocked, future, denied, and runtime designs must stay inactive',
      implementationDesignRecordId: record.implementationDesignRecordId,
    );
  }
}

void _checkSafetyFlags(
  void Function({
    required String id,
    required DebugOnlyBridgeImplementationDesignSeverity severity,
    required String message,
    String? implementationDesignRecordId,
    DebugOnlyBridgeImplementationDesignComponentId? componentId,
    String? fieldId,
    String? caseId,
    String? methodName,
  })
  add,
  DebugOnlyBridgeImplementationDesignRecord record,
) {
  void critical(String id, String message) {
    add(
      id: id,
      severity: DebugOnlyBridgeImplementationDesignSeverity.critical,
      message: message,
      implementationDesignRecordId: record.implementationDesignRecordId,
    );
  }

  if (record.safetyFlags['isProductOutput'] == true) {
    critical(
      'productOutputActive',
      'implementation design cannot be product output',
    );
  }
  if (record.safetyFlags['isClassifierLabel'] == true) {
    critical(
      'classifierLabelOutputActive',
      'implementation design cannot emit classifier labels',
    );
  }
  if (record.safetyFlags['hasNumericScore'] == true) {
    critical(
      'numericScoreOutputActive',
      'implementation design cannot emit numeric scores',
    );
  }
  if (record.safetyFlags['hasAggregateScore'] == true) {
    critical(
      'aggregateScoreOutputActive',
      'implementation design cannot emit aggregate scores',
    );
  }
  if (record.safetyFlags['ranksMoves'] == true) {
    critical(
      'moveRankingOutputActive',
      'implementation design cannot rank moves',
    );
  }
  if (record.safetyFlags['isOfficialMetric'] == true) {
    critical(
      'officialMetricOutputActive',
      'implementation design cannot emit official metrics',
    );
  }
  if (record.safetyFlags['exposesCpLoss'] == true ||
      record.safetyFlags['exposesWinProbability'] == true) {
    critical(
      'futureMetricOutputActive',
      'implementation design cannot expose CP-loss or win probability',
    );
  }
  if (record.safetyFlags['quietPreparatoryScopeActive'] == true) {
    critical(
      'quietPreparatoryScopeActivated',
      'quiet/preparatory scope must remain excluded',
    );
  }
  if (record.safetyFlags['callsEngine'] == true) {
    critical(
      'engineCallFlagActive',
      'implementation design cannot call an engine',
    );
  }
  if (record.safetyFlags['writesPersistence'] == true) {
    critical(
      'persistenceWriteFlagActive',
      'implementation design cannot write persistence',
    );
  }
  if (record.safetyFlags['targetsUi'] == true) {
    critical('uiTargetFlagActive', 'implementation design cannot target UI');
  }
  if (record.safetyFlags['targetsBackend'] == true) {
    critical(
      'backendOutputActive',
      'implementation design cannot target backend',
    );
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
      'implementation design cannot implement runtime behavior',
    );
  }
  if (record.safetyFlags['implementsExecutablePrototype'] == true) {
    critical(
      'executablePrototypeImplementationFlagActive',
      'implementation design cannot implement executable prototype behavior',
    );
  }
  if (record.safetyFlags['implementsWiring'] == true) {
    critical(
      'implementationWiringFlagActive',
      'implementation design cannot implement wiring',
    );
  }
}

void _checkActiveAllowedField(
  void Function({
    required String id,
    required DebugOnlyBridgeImplementationDesignSeverity severity,
    required String message,
    String? implementationDesignRecordId,
    DebugOnlyBridgeImplementationDesignComponentId? componentId,
    String? fieldId,
    String? caseId,
    String? methodName,
  })
  add,
  String fieldId, {
  String? implementationDesignRecordId,
  DebugOnlyBridgeImplementationDesignComponentId? componentId,
}) {
  if (_isDeniedFieldId(fieldId) || _isLegacyDeniedFieldId(fieldId)) {
    add(
      id: 'activeDeniedField',
      severity: DebugOnlyBridgeImplementationDesignSeverity.critical,
      message: '$fieldId cannot be active implementation design output',
      implementationDesignRecordId: implementationDesignRecordId,
      componentId: componentId,
      fieldId: fieldId,
    );
  }
}

void _checkAndroidProofCase(
  void Function({
    required String id,
    required DebugOnlyBridgeImplementationDesignSeverity severity,
    required String message,
    String? implementationDesignRecordId,
    DebugOnlyBridgeImplementationDesignComponentId? componentId,
    String? fieldId,
    String? caseId,
    String? methodName,
  })
  add,
  String caseId,
  List<String> provenAndroidIds, {
  String? implementationDesignRecordId,
  DebugOnlyBridgeImplementationDesignComponentId? componentId,
}) {
  if (_phase32ECaseIds.contains(caseId)) {
    add(
      id: 'phase32ECaseTreatedAsCapturedProof',
      severity: DebugOnlyBridgeImplementationDesignSeverity.critical,
      message: '$caseId cannot be treated as captured Android proof',
      implementationDesignRecordId: implementationDesignRecordId,
      componentId: componentId,
      caseId: caseId,
    );
    return;
  }
  if (!_capturedAndroidProofIds.contains(caseId) ||
      !provenAndroidIds.contains(caseId)) {
    add(
      id: 'unprovenAndroidProofId',
      severity: DebugOnlyBridgeImplementationDesignSeverity.critical,
      message: '$caseId is not captured Android proof',
      implementationDesignRecordId: implementationDesignRecordId,
      componentId: componentId,
      caseId: caseId,
    );
  }
}

void _checkProposedMethodName(
  void Function({
    required String id,
    required DebugOnlyBridgeImplementationDesignSeverity severity,
    required String message,
    String? implementationDesignRecordId,
    DebugOnlyBridgeImplementationDesignComponentId? componentId,
    String? fieldId,
    String? caseId,
    String? methodName,
  })
  add,
  String methodName, {
  String? implementationDesignRecordId,
  DebugOnlyBridgeImplementationDesignComponentId? componentId,
}) {
  if (_methodImpliesForbiddenBehavior(methodName)) {
    add(
      id: 'proposedMethodImpliesForbiddenBehavior',
      severity: DebugOnlyBridgeImplementationDesignSeverity.critical,
      message: '$methodName implies execution or boundary activation',
      implementationDesignRecordId: implementationDesignRecordId,
      componentId: componentId,
      methodName: methodName,
    );
  }
}

DebugBridgePrototypeDesignReadinessSummaryRole
_summaryRoleForImplementationRole(
  DebugOnlyBridgeImplementationDesignComponentRole role,
) {
  return switch (role) {
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeInputContract =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .futurePhase33DRequirementSummaryRecord,
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeCoreRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .readinessApprovedPrototypeCoreSummaryRecord,
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeContextRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .constrainedPrototypeContextSummaryRecord,
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeInactiveBlockedRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .inactivePrototypeBlockedSummaryRecord,
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeInactiveFutureRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .inactivePrototypeFutureOnlySummaryRecord,
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeAllowedFieldContract =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .approvedAllowedFieldSummaryRecord,
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeDeniedFieldContract =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .deniedFieldBoundarySummaryRecord,
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeRuntimeBlock =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .runtimeExecutionBlockedSummaryRecord,
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeProofBoundary =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .androidProofBoundarySummaryRecord,
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeOwnerProofBoundary =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .ownerProofBoundarySummaryRecord,
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeSkeletonPlan =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .futurePhase33DRequirementSummaryRecord,
    DebugOnlyBridgeImplementationDesignComponentRole
        .phase33FImplementationSkeletonRequirement =>
      DebugBridgePrototypeDesignReadinessSummaryRole
          .futurePhase33DRequirementSummaryRecord,
  };
}

DebugOnlyBridgeImplementationDesignComponentRole _roleForComponent(
  DebugOnlyBridgeImplementationDesignComponentId componentId,
) {
  return switch (componentId) {
    DebugOnlyBridgeImplementationDesignComponentId.bridgeInputContractDesign =>
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeInputContract,
    DebugOnlyBridgeImplementationDesignComponentId.bridgeCoreRecordDesign =>
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeCoreRecord,
    DebugOnlyBridgeImplementationDesignComponentId.bridgeContextRecordDesign =>
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeContextRecord,
    DebugOnlyBridgeImplementationDesignComponentId
        .bridgeInactiveBlockedRecordDesign =>
      DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeInactiveBlockedRecord,
    DebugOnlyBridgeImplementationDesignComponentId
        .bridgeInactiveFutureRecordDesign =>
      DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeInactiveFutureRecord,
    DebugOnlyBridgeImplementationDesignComponentId
        .bridgeAllowedFieldContractDesign =>
      DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeAllowedFieldContract,
    DebugOnlyBridgeImplementationDesignComponentId
        .bridgeDeniedFieldContractDesign =>
      DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeDeniedFieldContract,
    DebugOnlyBridgeImplementationDesignComponentId.bridgeRuntimeBlockDesign =>
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeRuntimeBlock,
    DebugOnlyBridgeImplementationDesignComponentId.bridgeProofBoundaryDesign =>
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeProofBoundary,
    DebugOnlyBridgeImplementationDesignComponentId
        .bridgeOwnerProofBoundaryDesign =>
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeOwnerProofBoundary,
    DebugOnlyBridgeImplementationDesignComponentId.bridgeSkeletonPlanDesign =>
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeSkeletonPlan,
    DebugOnlyBridgeImplementationDesignComponentId
        .phase33FImplementationSkeletonRequirement =>
      DebugOnlyBridgeImplementationDesignComponentRole
          .phase33FImplementationSkeletonRequirement,
  };
}

DebugOnlyBridgeImplementationDesignItemStatus _designStatusForRole(
  DebugOnlyBridgeImplementationDesignComponentRole role,
) {
  return switch (role) {
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeInputContract =>
      DebugOnlyBridgeImplementationDesignItemStatus.bridgeInputContractDesign,
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeCoreRecord =>
      DebugOnlyBridgeImplementationDesignItemStatus.bridgeCoreRecordDesign,
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeContextRecord =>
      DebugOnlyBridgeImplementationDesignItemStatus.bridgeContextRecordDesign,
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeInactiveBlockedRecord =>
      DebugOnlyBridgeImplementationDesignItemStatus
          .bridgeInactiveBlockedRecordDesign,
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeInactiveFutureRecord =>
      DebugOnlyBridgeImplementationDesignItemStatus
          .bridgeInactiveFutureRecordDesign,
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeAllowedFieldContract =>
      DebugOnlyBridgeImplementationDesignItemStatus
          .bridgeAllowedFieldContractDesign,
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeDeniedFieldContract =>
      DebugOnlyBridgeImplementationDesignItemStatus
          .bridgeDeniedFieldContractDesign,
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeRuntimeBlock =>
      DebugOnlyBridgeImplementationDesignItemStatus.bridgeRuntimeBlockDesign,
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeProofBoundary =>
      DebugOnlyBridgeImplementationDesignItemStatus.bridgeProofBoundaryDesign,
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeOwnerProofBoundary =>
      DebugOnlyBridgeImplementationDesignItemStatus
          .bridgeOwnerProofBoundaryDesign,
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeSkeletonPlan =>
      DebugOnlyBridgeImplementationDesignItemStatus.bridgeSkeletonPlanDesign,
    DebugOnlyBridgeImplementationDesignComponentRole
        .phase33FImplementationSkeletonRequirement =>
      DebugOnlyBridgeImplementationDesignItemStatus
          .phase33FImplementationSkeletonRequirement,
  };
}

DebugOnlyBridgeImplementationDesignRecommendation _recommendationForRole(
  DebugOnlyBridgeImplementationDesignComponentRole role,
) {
  return switch (role) {
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeInputContract =>
      DebugOnlyBridgeImplementationDesignRecommendation
          .keepInputContractDesignOnly,
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeCoreRecord =>
      DebugOnlyBridgeImplementationDesignRecommendation
          .mapCoreRecordsToSkeletonContract,
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeContextRecord =>
      DebugOnlyBridgeImplementationDesignRecommendation
          .keepContextRecordsContextOnly,
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeInactiveBlockedRecord =>
      DebugOnlyBridgeImplementationDesignRecommendation
          .keepBlockedRecordsInactive,
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeInactiveFutureRecord =>
      DebugOnlyBridgeImplementationDesignRecommendation
          .keepFutureRecordsInactive,
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeAllowedFieldContract =>
      DebugOnlyBridgeImplementationDesignRecommendation
          .keepAllowedFieldsDebugSafe,
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeDeniedFieldContract =>
      DebugOnlyBridgeImplementationDesignRecommendation
          .keepDeniedFieldsImpossible,
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeRuntimeBlock =>
      DebugOnlyBridgeImplementationDesignRecommendation
          .keepRuntimePrototypeWiringBlocked,
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeProofBoundary =>
      DebugOnlyBridgeImplementationDesignRecommendation
          .keepProofBoundaryCapturedOnly,
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeOwnerProofBoundary =>
      DebugOnlyBridgeImplementationDesignRecommendation.keepOwnerProofEmpty,
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeSkeletonPlan =>
      DebugOnlyBridgeImplementationDesignRecommendation
          .preparePhase33FDeveloperSkeleton,
    DebugOnlyBridgeImplementationDesignComponentRole
        .phase33FImplementationSkeletonRequirement =>
      DebugOnlyBridgeImplementationDesignRecommendation
          .requirePhase33FSkeletonCheckpoint,
  };
}

bool _allowedForFutureSkeleton(
  DebugOnlyBridgeImplementationDesignComponentRole role,
) {
  return switch (role) {
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeInactiveBlockedRecord ||
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeInactiveFutureRecord => false,
    _ => true,
  };
}

bool _inactiveByDefault(DebugOnlyBridgeImplementationDesignComponentRole role) {
  return role.isInactiveBoundary;
}

List<String> _allowedFieldsForRole(
  DebugBridgePrototypeDesignReadinessSummaryValidationResult validationResult,
  DebugOnlyBridgeImplementationDesignComponentRole role,
) {
  if (role ==
      DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeAllowedFieldContract) {
    return _sortedStrings(validationResult.allowedFieldIds);
  }
  if (role ==
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeInputContract) {
    return const <String>[
      'debugBridgeRecordId',
      'sourceSummaryGroupIds',
      'supportCaseIds',
      'internalWarnings',
      'futurePrerequisites',
    ];
  }
  return const <String>[];
}

List<String> _deniedFieldsForRole(
  DebugBridgePrototypeDesignReadinessSummaryValidationResult validationResult,
  DebugOnlyBridgeImplementationDesignComponentRole role,
) {
  if (role ==
      DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeDeniedFieldContract) {
    return _sortedStrings(validationResult.deniedFieldIds);
  }
  if (role ==
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeRuntimeBlock) {
    return _sortedStrings(_engineDumpFieldIds);
  }
  return const <String>[];
}

List<String> _warningReasonsForRole(
  DebugBridgePrototypeDesignReadinessSummaryRecord source,
  DebugOnlyBridgeImplementationDesignComponentRole role,
) {
  return _sortedStrings(<String>[
    ...source.warningReasons,
    if (role ==
        DebugOnlyBridgeImplementationDesignComponentRole.bridgeContextRecord)
      'context records remain context-only in the future skeleton',
    if (role.isInactiveBoundary)
      'inactive or denied boundaries remain inactive in the future skeleton',
    if (role ==
        DebugOnlyBridgeImplementationDesignComponentRole.bridgeSkeletonPlan)
      'Phase 33E defines skeleton metadata only; Phase 33F may create non-executable classes',
  ]);
}

List<String> _futurePrerequisitesForRole(
  DebugBridgePrototypeDesignReadinessSummaryRecord source,
  DebugOnlyBridgeImplementationDesignComponentRole role,
) {
  if (role ==
      DebugOnlyBridgeImplementationDesignComponentRole
          .phase33FImplementationSkeletonRequirement) {
    return const <String>[
      'phase33FDeveloperOnlyNonExecutableBridgeSkeleton',
      'phase33FMustNotWireUiAnalyzerProductBackendPersistenceSchedulerOrEngine',
      'phase33FMustKeepDeniedFieldsImpossibleToActivate',
    ];
  }
  if (role ==
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeSkeletonPlan) {
    return const <String>[
      'phase33FMayAddSkeletonClassesOnly',
      'phase33FMayAddDeveloperOnlySnapshotMetadataOnly',
    ];
  }
  return _sortedStrings(source.futurePrerequisites);
}

List<String> _blockedBoundaryIdsForRole(
  DebugBridgePrototypeDesignReadinessSummaryRecord source,
  DebugOnlyBridgeImplementationDesignComponentRole role,
) {
  if (role ==
      DebugOnlyBridgeImplementationDesignComponentRole.bridgeRuntimeBlock) {
    return _sortedStrings(<String>[
      ...source.blockedBoundaryIds,
      'debugBridgeRuntime',
      'executableBridgeSkeleton',
      'executableDebugBridgePrototype',
      'implementationWiring',
      'uiIntegration',
      'backendIntegration',
      'persistenceIntegration',
      'schedulerExecution',
      'directEngineCall',
      'stockfishCommand',
      'rawUci',
      'pvDump',
    ]);
  }
  return _sortedStrings(source.blockedBoundaryIds);
}

List<String> _proposedClassesForRole(
  DebugOnlyBridgeImplementationDesignComponentRole role,
) {
  return switch (role) {
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeInputContract =>
      const <String>['DebugOnlyBridgeInputPacket'],
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeCoreRecord =>
      const <String>['DebugOnlyBridgeRecord'],
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeContextRecord =>
      const <String>['DebugOnlyBridgeRecord'],
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeInactiveBlockedRecord =>
      const <String>['DebugOnlyBridgeRecord'],
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeInactiveFutureRecord =>
      const <String>['DebugOnlyBridgeRecord'],
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeAllowedFieldContract =>
      const <String>['DebugOnlyBridgePolicy'],
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeDeniedFieldContract =>
      const <String>['DebugOnlyBridgePolicy'],
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeRuntimeBlock =>
      const <String>['DebugOnlyBridgePolicy'],
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeProofBoundary =>
      const <String>['DebugOnlyBridgePolicy'],
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeOwnerProofBoundary =>
      const <String>['DebugOnlyBridgePolicy'],
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeSkeletonPlan =>
      const <String>[
        'DebugOnlyBridgeOutputPacket',
        'DebugOnlyBridgeSkeleton',
        'DebugOnlyBridgeSkeletonResult',
        'DebugOnlyBridgeSkeletonValidator',
      ],
    DebugOnlyBridgeImplementationDesignComponentRole
        .phase33FImplementationSkeletonRequirement =>
      const <String>[
        'DebugOnlyBridgeInputPacket',
        'DebugOnlyBridgeOutputPacket',
        'DebugOnlyBridgeRecord',
        'DebugOnlyBridgePolicy',
        'DebugOnlyBridgeSkeleton',
        'DebugOnlyBridgeSkeletonResult',
        'DebugOnlyBridgeSkeletonValidator',
      ],
  };
}

List<String> _proposedMethodsForRole(
  DebugOnlyBridgeImplementationDesignComponentRole role,
) {
  return switch (role) {
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeInputContract =>
      const <String>['buildInputFromValidatedSummary'],
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeCoreRecord =>
      const <String>['createCoreRecord'],
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeContextRecord =>
      const <String>['createContextRecord'],
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeInactiveBlockedRecord =>
      const <String>['preserveInactiveRecord'],
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeInactiveFutureRecord =>
      const <String>['preserveInactiveRecord'],
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeAllowedFieldContract =>
      const <String>['validateNoDeniedFields'],
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeDeniedFieldContract =>
      const <String>['validateNoDeniedFields'],
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeRuntimeBlock =>
      const <String>['validateRuntimeRemainsBlocked'],
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeProofBoundary =>
      const <String>['validateCapturedProofIdsOnly'],
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeOwnerProofBoundary =>
      const <String>['validateOwnerProofQueueEmpty'],
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeSkeletonPlan =>
      const <String>['renderDeveloperOnlyDebugSnapshot'],
    DebugOnlyBridgeImplementationDesignComponentRole
        .phase33FImplementationSkeletonRequirement =>
      const <String>['validateDeveloperOnlySkeletonBoundary'],
  };
}

List<String> _proposedFilesForRole(
  DebugOnlyBridgeImplementationDesignComponentRole role,
) {
  return switch (role) {
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeInputContract ||
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeCoreRecord ||
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeContextRecord ||
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeInactiveBlockedRecord ||
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeInactiveFutureRecord => const <String>[
      'lib/features/pgn_review/application/debug_only_bridge_skeleton.dart',
    ],
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeAllowedFieldContract ||
    DebugOnlyBridgeImplementationDesignComponentRole
        .bridgeDeniedFieldContract ||
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeRuntimeBlock ||
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeProofBoundary ||
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeOwnerProofBoundary =>
      const <String>[
        'lib/features/pgn_review/application/debug_only_bridge_policy.dart',
      ],
    DebugOnlyBridgeImplementationDesignComponentRole.bridgeSkeletonPlan =>
      const <String>[
        'lib/features/pgn_review/application/debug_only_bridge_skeleton.dart',
        'lib/features/pgn_review/application/debug_only_bridge_skeleton_validator.dart',
        'tool/debug_only_bridge_skeleton_snapshot_report.dart',
      ],
    DebugOnlyBridgeImplementationDesignComponentRole
        .phase33FImplementationSkeletonRequirement =>
      const <String>[
        'lib/features/pgn_review/application/debug_only_bridge_skeleton.dart',
        'test/features/pgn_review/application/debug_only_bridge_skeleton_test.dart',
      ],
  };
}

Map<String, bool> _safeFlags() {
  return const <String, bool>{
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
    'implementsRuntime': false,
    'implementsExecutablePrototype': false,
    'implementsWiring': false,
  };
}

bool _hasExplicitPvProofReason(
  DebugOnlyBridgeImplementationDesignResult result,
) {
  final reasons = <String>[
    ...result.warnings,
    ...result.failures,
    ...result.components.expand((component) => component.proofLimitReasons),
  ].join(' ').toLowerCase();
  return reasons.contains('pv') || reasons.contains('multipv');
}

int _countRole(
  Iterable<DebugOnlyBridgeImplementationDesignRecord> records,
  DebugOnlyBridgeImplementationDesignComponentRole role,
) {
  return records.where((record) => record.componentRole == role).length;
}

List<String> _provenAndroidProofIds(GoldenAndroidProofEvidence? evidence) {
  return _sortedStrings(evidence?.targetCaseIds ?? const <String>[]);
}

int _compareFindings(
  DebugOnlyBridgeImplementationDesignFinding a,
  DebugOnlyBridgeImplementationDesignFinding b,
) {
  final severity = _severityRank(
    b.severity,
  ).compareTo(_severityRank(a.severity));
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.implementationDesignRecordId ?? '').compareTo(
    b.implementationDesignRecordId ?? '',
  );
}

int _severityRank(DebugOnlyBridgeImplementationDesignSeverity severity) {
  return switch (severity) {
    DebugOnlyBridgeImplementationDesignSeverity.warning => 1,
    DebugOnlyBridgeImplementationDesignSeverity.blocker => 2,
    DebugOnlyBridgeImplementationDesignSeverity.critical => 3,
  };
}

bool _sameStringSet(Iterable<String> left, Iterable<String> right) {
  final leftSet = left.toSet();
  final rightSet = right.toSet();
  return leftSet.length == rightSet.length && leftSet.every(rightSet.contains);
}

bool _methodImpliesForbiddenBehavior(String methodName) {
  final value = methodName.toLowerCase();
  if (value.contains('execute') ||
      value.contains('runengine') ||
      value.contains('callengine') ||
      value.contains('enginecall') ||
      value.contains('stockfish') ||
      value.contains('rawuci') ||
      value.contains('pvdump') ||
      value.contains('localeval') ||
      value.contains('scheduler') ||
      value.contains('persist') ||
      value.contains('cache') ||
      value.contains('database') ||
      value.contains('renderui') ||
      value.contains('widget') ||
      value.contains('productlabel') ||
      value.contains('emitlabel') ||
      value.contains('classifier') ||
      value.contains('scoremove') ||
      value.contains('rankmove') ||
      value.contains('accuracy') ||
      value.contains('acpl') ||
      value.contains('cploss') ||
      value.contains('winprobability')) {
    return true;
  }
  return false;
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

String _bulletList(Iterable<String> values) {
  final sorted = _sortedStrings(values);
  if (sorted.isEmpty) return '- none';
  return sorted.map((value) => '- ${_cell(value)}').join('\n');
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

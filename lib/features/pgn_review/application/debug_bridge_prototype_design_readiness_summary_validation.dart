/// Developer-only validation for debug bridge prototype design readiness
/// summary output.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugBridgePrototypeDesignReadinessSummaryValidationReportVersion =
    'debug-bridge-prototype-design-readiness-summary-validation-v1';

enum DebugBridgePrototypeDesignReadinessSummaryValidationStatus {
  validatedWithWarnings('validatedWithWarnings'),
  validatedClean('validatedClean'),
  blockedByUnsafeSummary('blockedByUnsafeSummary'),
  blockedBySummaryMismatch('blockedBySummaryMismatch'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const DebugBridgePrototypeDesignReadinessSummaryValidationStatus(this.wire);

  final String wire;
}

enum DebugBridgePrototypeDesignReadinessSummaryValidationCheckStatus {
  passed('passed'),
  passedWithWarnings('passedWithWarnings'),
  failed('failed'),
  blocked('blocked'),
  notApplicable('notApplicable');

  const DebugBridgePrototypeDesignReadinessSummaryValidationCheckStatus(
    this.wire,
  );

  final String wire;

  bool get isPassed => this == passed || this == passedWithWarnings;

  bool get isWarning => this == passedWithWarnings;

  bool get isBlocked => this == failed || this == blocked;
}

enum DebugBridgePrototypeDesignReadinessSummaryValidationSeverity {
  none('none'),
  info('info'),
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const DebugBridgePrototypeDesignReadinessSummaryValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict => this == blocker || this == critical;

  bool get isCritical => this == critical;
}

enum DebugBridgePrototypeDesignReadinessSummaryValidationGroupKind {
  validApprovedCoreSummary('validApprovedCoreSummary'),
  validConstrainedContextSummary('validConstrainedContextSummary'),
  validInactiveBlockedSummary('validInactiveBlockedSummary'),
  validInactiveFutureOnlySummary('validInactiveFutureOnlySummary'),
  validAllowedFieldSummary('validAllowedFieldSummary'),
  validDeniedFieldSummary('validDeniedFieldSummary'),
  validStockfishRawUciPvDumpDeniedSummary(
    'validStockfishRawUciPvDumpDeniedSummary',
  ),
  validRuntimePrototypeWiringBlockedSummary(
    'validRuntimePrototypeWiringBlockedSummary',
  ),
  validAndroidProofBoundarySummary('validAndroidProofBoundarySummary'),
  validOwnerProofBoundarySummary('validOwnerProofBoundarySummary'),
  validFutureRequirementSummary('validFutureRequirementSummary');

  const DebugBridgePrototypeDesignReadinessSummaryValidationGroupKind(
    this.wire,
  );

  final String wire;
}

enum DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus {
  validApprovedCoreSummary('validApprovedCoreSummary'),
  validConstrainedContextSummary('validConstrainedContextSummary'),
  validInactiveBlockedSummary('validInactiveBlockedSummary'),
  validInactiveFutureOnlySummary('validInactiveFutureOnlySummary'),
  validAllowedFieldSummary('validAllowedFieldSummary'),
  validDeniedFieldSummary('validDeniedFieldSummary'),
  validStockfishRawUciPvDumpDeniedSummary(
    'validStockfishRawUciPvDumpDeniedSummary',
  ),
  validRuntimePrototypeWiringBlockedSummary(
    'validRuntimePrototypeWiringBlockedSummary',
  ),
  validAndroidProofBoundarySummary('validAndroidProofBoundarySummary'),
  validOwnerProofBoundarySummary('validOwnerProofBoundarySummary'),
  validFutureRequirementSummary('validFutureRequirementSummary'),
  invalidSummaryGroup('invalidSummaryGroup'),
  unsafeSummaryGroup('unsafeSummaryGroup');

  const DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus(
    this.wire,
  );

  final String wire;

  bool get isUnsafe => this == unsafeSummaryGroup;

  bool get isInvalid => this == invalidSummaryGroup;
}

enum DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus {
  validApprovedCoreSummaryRecord('validApprovedCoreSummaryRecord'),
  validConstrainedContextSummaryRecord('validConstrainedContextSummaryRecord'),
  validInactiveBlockedSummaryRecord('validInactiveBlockedSummaryRecord'),
  validInactiveFutureOnlySummaryRecord('validInactiveFutureOnlySummaryRecord'),
  validAllowedFieldSummaryRecord('validAllowedFieldSummaryRecord'),
  validDeniedFieldSummaryRecord('validDeniedFieldSummaryRecord'),
  validStockfishRawUciPvDumpDeniedRecord(
    'validStockfishRawUciPvDumpDeniedRecord',
  ),
  validRuntimePrototypeWiringBlockedRecord(
    'validRuntimePrototypeWiringBlockedRecord',
  ),
  validAndroidProofBoundaryRecord('validAndroidProofBoundaryRecord'),
  validOwnerProofBoundaryRecord('validOwnerProofBoundaryRecord'),
  validFutureRequirementRecord('validFutureRequirementRecord'),
  invalidSummaryRecord('invalidSummaryRecord'),
  unsafeSummaryRecord('unsafeSummaryRecord');

  const DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus(
    this.wire,
  );

  final String wire;

  bool get isUnsafe => this == unsafeSummaryRecord;

  bool get isInvalid => this == invalidSummaryRecord;

  bool get isInactiveBoundary =>
      this == validInactiveBlockedSummaryRecord ||
      this == validInactiveFutureOnlySummaryRecord ||
      this == validDeniedFieldSummaryRecord ||
      this == validStockfishRawUciPvDumpDeniedRecord ||
      this == validRuntimePrototypeWiringBlockedRecord;
}

enum DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation {
  keepApprovedCoreSummaryValid('keepApprovedCoreSummaryValid'),
  keepContextSummaryConstrained('keepContextSummaryConstrained'),
  keepBlockedSummaryInactive('keepBlockedSummaryInactive'),
  keepFutureSummaryInactive('keepFutureSummaryInactive'),
  keepAllowedFieldsSafe('keepAllowedFieldsSafe'),
  keepDeniedFieldsDenied('keepDeniedFieldsDenied'),
  keepStockfishRawUciPvDumpDenied('keepStockfishRawUciPvDumpDenied'),
  keepRuntimePrototypeWiringBlocked('keepRuntimePrototypeWiringBlocked'),
  keepAndroidProofBoundaryCapturedOnly('keepAndroidProofBoundaryCapturedOnly'),
  keepOwnerProofEmpty('keepOwnerProofEmpty'),
  keepFutureImplementationDesignCheckpoint(
    'keepFutureImplementationDesignCheckpoint',
  ),
  keepPolicyBoundariesBlocked('keepPolicyBoundariesBlocked'),
  investigateSummaryMismatch('investigateSummaryMismatch'),
  blockUnsafeSummaryValidation('blockUnsafeSummaryValidation');

  const DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation(
    this.wire,
  );

  final String wire;
}

enum DebugBridgePrototypeDesignReadinessSummaryValidationPhase33ERecommendation {
  proceedToDebugOnlyBridgeImplementationDesign(
    'proceedToDebugOnlyBridgeImplementationDesign',
  ),
  proceedToPrototypeDesignValidationReportOnly(
    'proceedToPrototypeDesignValidationReportOnly',
  ),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafePrototypeDesignReadinessSummaryValidation(
    'blockedByUnsafePrototypeDesignReadinessSummaryValidation',
  );

  const DebugBridgePrototypeDesignReadinessSummaryValidationPhase33ERecommendation(
    this.wire,
  );

  final String wire;
}

enum DebugBridgePrototypeDesignReadinessSummaryValidationReportFormat {
  markdown('markdown'),
  json('json');

  const DebugBridgePrototypeDesignReadinessSummaryValidationReportFormat(
    this.wire,
  );

  final String wire;
}

class DebugBridgePrototypeDesignReadinessSummaryValidationRequest {
  const DebugBridgePrototypeDesignReadinessSummaryValidationRequest({
    this.summaryResult,
    this.readinessGateResult,
    this.validationResult,
    this.designResult,
    this.bridgeReadinessGateResult,
    this.summary = const DebugBridgePrototypeDesignReadinessSummary(),
    this.readinessGate = const DebugBridgePrototypeDesignReadinessGate(),
    this.validation = const DebugOnlyBridgePrototypeDesignValidation(),
    this.prototypeDesign = const DebugOnlyBridgePrototypeDesign(),
    this.bridgeReadinessGate = const DebugBridgeReadinessValidationGate(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const DebugBridgePrototypeDesignReadinessSummaryValidationRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final DebugBridgePrototypeDesignReadinessSummaryResult? summaryResult;
  final DebugBridgePrototypeDesignReadinessGateResult? readinessGateResult;
  final DebugOnlyBridgePrototypeDesignValidationResult? validationResult;
  final DebugOnlyBridgePrototypeDesignResult? designResult;
  final DebugBridgeReadinessValidationGateResult? bridgeReadinessGateResult;
  final DebugBridgePrototypeDesignReadinessSummary summary;
  final DebugBridgePrototypeDesignReadinessGate readinessGate;
  final DebugOnlyBridgePrototypeDesignValidation validation;
  final DebugOnlyBridgePrototypeDesign prototypeDesign;
  final DebugBridgeReadinessValidationGate bridgeReadinessGate;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class DebugBridgePrototypeDesignReadinessSummaryValidationCheck {
  const DebugBridgePrototypeDesignReadinessSummaryValidationCheck({
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
  final DebugBridgePrototypeDesignReadinessSummaryValidationCheckStatus
  checkStatus;
  final DebugBridgePrototypeDesignReadinessSummaryValidationSeverity severity;
  final List<DebugBridgePrototypeDesignReadinessSummaryGroupId>
  relatedSummaryGroupIds;
  final List<String> relatedSummaryRecordIds;
  final List<String> relatedFieldIds;
  final List<String> relatedProofIds;
  final String warningReason;
  final String failureReason;
  final DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
  recommendation;

  bool get isBlocking =>
      checkStatus.isBlocked || severity.blocksStrict || severity.isCritical;

  bool get isCritical => severity.isCritical;

  Map<String, Object?> toJson() => <String, Object?>{
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

class DebugBridgePrototypeDesignReadinessSummaryGroupValidationRow {
  const DebugBridgePrototypeDesignReadinessSummaryGroupValidationRow({
    required this.validationRowId,
    required this.sourceSummaryGroupId,
    required this.groupKind,
    required this.validationStatus,
    required this.summaryRecordIds,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.ownerProofQueueCount,
    required this.designOnly,
    required this.contextOnly,
    required this.inactive,
    required this.validationReason,
    required this.warningReason,
    required this.violationReasons,
    required this.safeForPhase33E,
    required this.recommendation,
  });

  final String validationRowId;
  final DebugBridgePrototypeDesignReadinessSummaryGroupId sourceSummaryGroupId;
  final DebugBridgePrototypeDesignReadinessSummaryValidationGroupKind groupKind;
  final DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
  validationStatus;
  final List<String> summaryRecordIds;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final int ownerProofQueueCount;
  final bool designOnly;
  final bool contextOnly;
  final bool inactive;
  final String validationReason;
  final String warningReason;
  final List<String> violationReasons;
  final bool safeForPhase33E;
  final DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
  recommendation;

  bool get hasUnsafeOutput =>
      validationStatus.isUnsafe ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId);

  Map<String, Object?> toJson() => <String, Object?>{
    'validationRowId': validationRowId,
    'sourceSummaryGroupId': sourceSummaryGroupId.wire,
    'groupKind': groupKind.wire,
    'validationStatus': validationStatus.wire,
    'summaryRecordIds': summaryRecordIds,
    'allowedFieldIds': allowedFieldIds,
    'deniedFieldIds': deniedFieldIds,
    'supportCaseIds': supportCaseIds,
    'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
    'androidProofCaseIds': androidProofCaseIds,
    'ownerProofQueueCount': ownerProofQueueCount,
    'designOnly': designOnly,
    'contextOnly': contextOnly,
    'inactive': inactive,
    'validationReason': validationReason,
    'warningReason': warningReason,
    'violationReasons': violationReasons,
    'safeForPhase33E': safeForPhase33E,
    'recommendation': recommendation.wire,
  };
}

class DebugBridgePrototypeDesignReadinessSummaryRecordValidationRow {
  const DebugBridgePrototypeDesignReadinessSummaryRecordValidationRow({
    required this.validationRowId,
    required this.sourceSummaryRecordId,
    required this.sourceGateRecordId,
    required this.sourceGateGroupId,
    required this.summaryRole,
    required this.summaryStatus,
    required this.validationStatus,
    required this.allowedForFutureInternalPlanning,
    required this.designOnly,
    required this.contextOnly,
    required this.inactive,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.safetyFlags,
    required this.violationReasons,
    required this.safeForPhase33E,
    required this.recommendation,
  });

  final String validationRowId;
  final String sourceSummaryRecordId;
  final String sourceGateRecordId;
  final DebugBridgePrototypeDesignReadinessGateGroupId sourceGateGroupId;
  final DebugBridgePrototypeDesignReadinessSummaryRole summaryRole;
  final DebugBridgePrototypeDesignReadinessSummaryItemStatus summaryStatus;
  final DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
  validationStatus;
  final bool allowedForFutureInternalPlanning;
  final bool designOnly;
  final bool contextOnly;
  final bool inactive;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final Map<String, bool> safetyFlags;
  final List<String> violationReasons;
  final bool safeForPhase33E;
  final DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
  recommendation;

  bool get hasUnsafeOutput =>
      validationStatus.isUnsafe ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId) ||
      safetyFlags.values.any((value) => value);

  DebugBridgePrototypeDesignReadinessSummaryRecordValidationRow copyWith({
    String? validationRowId,
    String? sourceSummaryRecordId,
    String? sourceGateRecordId,
    DebugBridgePrototypeDesignReadinessGateGroupId? sourceGateGroupId,
    DebugBridgePrototypeDesignReadinessSummaryRole? summaryRole,
    DebugBridgePrototypeDesignReadinessSummaryItemStatus? summaryStatus,
    DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus?
    validationStatus,
    bool? allowedForFutureInternalPlanning,
    bool? designOnly,
    bool? contextOnly,
    bool? inactive,
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    Map<String, bool>? safetyFlags,
    List<String>? violationReasons,
    bool? safeForPhase33E,
    DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation?
    recommendation,
  }) {
    return DebugBridgePrototypeDesignReadinessSummaryRecordValidationRow(
      validationRowId: validationRowId ?? this.validationRowId,
      sourceSummaryRecordId:
          sourceSummaryRecordId ?? this.sourceSummaryRecordId,
      sourceGateRecordId: sourceGateRecordId ?? this.sourceGateRecordId,
      sourceGateGroupId: sourceGateGroupId ?? this.sourceGateGroupId,
      summaryRole: summaryRole ?? this.summaryRole,
      summaryStatus: summaryStatus ?? this.summaryStatus,
      validationStatus: validationStatus ?? this.validationStatus,
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
      safetyFlags: safetyFlags ?? this.safetyFlags,
      violationReasons: violationReasons ?? this.violationReasons,
      safeForPhase33E: safeForPhase33E ?? this.safeForPhase33E,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'validationRowId': validationRowId,
    'sourceSummaryRecordId': sourceSummaryRecordId,
    'sourceGateRecordId': sourceGateRecordId,
    'sourceGateGroupId': sourceGateGroupId.wire,
    'summaryRole': summaryRole.wire,
    'summaryStatus': summaryStatus.wire,
    'validationStatus': validationStatus.wire,
    'allowedForFutureInternalPlanning': allowedForFutureInternalPlanning,
    'designOnly': designOnly,
    'contextOnly': contextOnly,
    'inactive': inactive,
    'allowedFieldIds': allowedFieldIds,
    'deniedFieldIds': deniedFieldIds,
    'supportCaseIds': supportCaseIds,
    'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
    'androidProofCaseIds': androidProofCaseIds,
    'safetyFlags': safetyFlags,
    'violationReasons': violationReasons,
    'safeForPhase33E': safeForPhase33E,
    'recommendation': recommendation.wire,
  };
}

class DebugBridgePrototypeDesignReadinessSummaryValidationFinding {
  const DebugBridgePrototypeDesignReadinessSummaryValidationFinding({
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
  final DebugBridgePrototypeDesignReadinessSummaryValidationSeverity severity;
  final String message;
  final String? validationRowId;
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
    if (validationRowId != null) 'validationRowId': validationRowId,
    if (summaryRecordId != null) 'summaryRecordId': summaryRecordId,
    if (summaryGroupId != null) 'summaryGroupId': summaryGroupId!.wire,
    if (fieldId != null) 'fieldId': fieldId,
    if (caseId != null) 'caseId': caseId,
  };
}

class DebugBridgePrototypeDesignReadinessSummaryValidationResult {
  const DebugBridgePrototypeDesignReadinessSummaryValidationResult({
    required this.validationStatus,
    required this.sourceSummaryStatus,
    required this.sourceReadinessGateStatus,
    required this.sourceValidationStatus,
    required this.sourceDesignStatus,
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
    required this.validApprovedCoreSummaryCount,
    required this.validConstrainedContextSummaryCount,
    required this.validInactiveBlockedSummaryCount,
    required this.validInactiveFutureOnlySummaryCount,
    required this.validAllowedFieldSummaryCount,
    required this.validDeniedFieldSummaryCount,
    required this.validStockfishRawUciPvDumpDeniedCount,
    required this.validRuntimePrototypeWiringBlockedCount,
    required this.validAndroidProofBoundaryCount,
    required this.validOwnerProofBoundaryCount,
    required this.validFutureRequirementCount,
    required this.invalidRecordCount,
    required this.unsafeRecordCount,
    required this.ownerProofQueueCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.safeForPhase33E,
    required this.phase33ERecommendation,
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

  final DebugBridgePrototypeDesignReadinessSummaryValidationStatus
  validationStatus;
  final DebugBridgePrototypeDesignReadinessSummaryStatus sourceSummaryStatus;
  final DebugBridgePrototypeDesignReadinessGateStatus sourceReadinessGateStatus;
  final DebugOnlyBridgePrototypeDesignValidationStatus sourceValidationStatus;
  final DebugOnlyBridgePrototypeDesignStatus sourceDesignStatus;
  final List<DebugBridgePrototypeDesignReadinessSummaryValidationCheck>
  validationChecks;
  final List<DebugBridgePrototypeDesignReadinessSummaryGroupValidationRow>
  groupRows;
  final List<DebugBridgePrototypeDesignReadinessSummaryRecordValidationRow>
  recordRows;
  final List<DebugBridgePrototypeDesignReadinessSummaryValidationFinding>
  validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalChecks;
  final int passedCheckCount;
  final int warningCheckCount;
  final int blockerCount;
  final int criticalCount;
  final int totalGroupRows;
  final int totalRecordRows;
  final int validApprovedCoreSummaryCount;
  final int validConstrainedContextSummaryCount;
  final int validInactiveBlockedSummaryCount;
  final int validInactiveFutureOnlySummaryCount;
  final int validAllowedFieldSummaryCount;
  final int validDeniedFieldSummaryCount;
  final int validStockfishRawUciPvDumpDeniedCount;
  final int validRuntimePrototypeWiringBlockedCount;
  final int validAndroidProofBoundaryCount;
  final int validOwnerProofBoundaryCount;
  final int validFutureRequirementCount;
  final int invalidRecordCount;
  final int unsafeRecordCount;
  final int ownerProofQueueCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final bool safeForPhase33E;
  final DebugBridgePrototypeDesignReadinessSummaryValidationPhase33ERecommendation
  phase33ERecommendation;
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
      validationStatus ==
          DebugBridgePrototypeDesignReadinessSummaryValidationStatus
              .blockedByUnsafeSummary ||
      validationStatus ==
          DebugBridgePrototypeDesignReadinessSummaryValidationStatus
              .blockedByPolicyBoundary ||
      validationStatus ==
          DebugBridgePrototypeDesignReadinessSummaryValidationStatus
              .blockedBySummaryMismatch ||
      validationStatus ==
          DebugBridgePrototypeDesignReadinessSummaryValidationStatus.invalid ||
      !safeForPhase33E ||
      unsafeRecordCount > 0 ||
      criticalCount > 0 ||
      blockerCount > 0 ||
      validationChecks.any((check) => check.isBlocking) ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool
  get hasUnsafeDebugBridgePrototypeDesignReadinessSummaryValidationPolicyViolation =>
      validationStatus ==
          DebugBridgePrototypeDesignReadinessSummaryValidationStatus
              .blockedByUnsafeSummary ||
      validationStatus ==
          DebugBridgePrototypeDesignReadinessSummaryValidationStatus
              .blockedByPolicyBoundary ||
      unsafeRecordCount > 0 ||
      criticalCount > 0 ||
      groupRows.any((row) => row.hasUnsafeOutput) ||
      recordRows.any((row) => row.hasUnsafeOutput) ||
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

  DebugBridgePrototypeDesignReadinessSummaryValidationCheck check(
    String checkId,
  ) {
    return validationChecks.singleWhere((check) => check.checkId == checkId);
  }

  DebugBridgePrototypeDesignReadinessSummaryGroupValidationRow groupRowForGroup(
    DebugBridgePrototypeDesignReadinessSummaryGroupId groupId,
  ) {
    return groupRows.singleWhere((row) => row.sourceSummaryGroupId == groupId);
  }

  DebugBridgePrototypeDesignReadinessSummaryRecordValidationRow
  recordRowForRole(DebugBridgePrototypeDesignReadinessSummaryRole role) {
    return recordRows.singleWhere((row) => row.summaryRole == role);
  }

  DebugBridgePrototypeDesignReadinessSummaryValidationResult copyWith({
    DebugBridgePrototypeDesignReadinessSummaryValidationStatus?
    validationStatus,
    DebugBridgePrototypeDesignReadinessSummaryStatus? sourceSummaryStatus,
    DebugBridgePrototypeDesignReadinessGateStatus? sourceReadinessGateStatus,
    DebugOnlyBridgePrototypeDesignValidationStatus? sourceValidationStatus,
    DebugOnlyBridgePrototypeDesignStatus? sourceDesignStatus,
    List<DebugBridgePrototypeDesignReadinessSummaryValidationCheck>?
    validationChecks,
    List<DebugBridgePrototypeDesignReadinessSummaryGroupValidationRow>?
    groupRows,
    List<DebugBridgePrototypeDesignReadinessSummaryRecordValidationRow>?
    recordRows,
    List<DebugBridgePrototypeDesignReadinessSummaryValidationFinding>?
    validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalChecks,
    int? passedCheckCount,
    int? warningCheckCount,
    int? blockerCount,
    int? criticalCount,
    int? totalGroupRows,
    int? totalRecordRows,
    int? validApprovedCoreSummaryCount,
    int? validConstrainedContextSummaryCount,
    int? validInactiveBlockedSummaryCount,
    int? validInactiveFutureOnlySummaryCount,
    int? validAllowedFieldSummaryCount,
    int? validDeniedFieldSummaryCount,
    int? validStockfishRawUciPvDumpDeniedCount,
    int? validRuntimePrototypeWiringBlockedCount,
    int? validAndroidProofBoundaryCount,
    int? validOwnerProofBoundaryCount,
    int? validFutureRequirementCount,
    int? invalidRecordCount,
    int? unsafeRecordCount,
    int? ownerProofQueueCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    bool? safeForPhase33E,
    DebugBridgePrototypeDesignReadinessSummaryValidationPhase33ERecommendation?
    phase33ERecommendation,
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
    return DebugBridgePrototypeDesignReadinessSummaryValidationResult(
      validationStatus: validationStatus ?? this.validationStatus,
      sourceSummaryStatus: sourceSummaryStatus ?? this.sourceSummaryStatus,
      sourceReadinessGateStatus:
          sourceReadinessGateStatus ?? this.sourceReadinessGateStatus,
      sourceValidationStatus:
          sourceValidationStatus ?? this.sourceValidationStatus,
      sourceDesignStatus: sourceDesignStatus ?? this.sourceDesignStatus,
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
      validApprovedCoreSummaryCount:
          validApprovedCoreSummaryCount ?? this.validApprovedCoreSummaryCount,
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
      validStockfishRawUciPvDumpDeniedCount:
          validStockfishRawUciPvDumpDeniedCount ??
          this.validStockfishRawUciPvDumpDeniedCount,
      validRuntimePrototypeWiringBlockedCount:
          validRuntimePrototypeWiringBlockedCount ??
          this.validRuntimePrototypeWiringBlockedCount,
      validAndroidProofBoundaryCount:
          validAndroidProofBoundaryCount ?? this.validAndroidProofBoundaryCount,
      validOwnerProofBoundaryCount:
          validOwnerProofBoundaryCount ?? this.validOwnerProofBoundaryCount,
      validFutureRequirementCount:
          validFutureRequirementCount ?? this.validFutureRequirementCount,
      invalidRecordCount: invalidRecordCount ?? this.invalidRecordCount,
      unsafeRecordCount: unsafeRecordCount ?? this.unsafeRecordCount,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      allowedFieldIds: allowedFieldIds ?? this.allowedFieldIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      safeForPhase33E: safeForPhase33E ?? this.safeForPhase33E,
      phase33ERecommendation:
          phase33ERecommendation ?? this.phase33ERecommendation,
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
      ..writeln('# Debug Bridge Prototype Design Readiness Summary Validation')
      ..writeln()
      ..writeln(
        '- version: $debugBridgePrototypeDesignReadinessSummaryValidationReportVersion',
      )
      ..writeln('- validation status: ${validationStatus.wire}')
      ..writeln('- source summary status: ${sourceSummaryStatus.wire}')
      ..writeln(
        '- source readiness gate status: ${sourceReadinessGateStatus.wire}',
      )
      ..writeln('- total checks: $totalChecks')
      ..writeln('- passed checks: $passedCheckCount')
      ..writeln('- warning checks: $warningCheckCount')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe record count: $unsafeRecordCount')
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
      ..writeln('- safeForPhase33E: $safeForPhase33E')
      ..writeln('- Phase 33E recommendation: ${phase33ERecommendation.wire}')
      ..writeln()
      ..writeln('## Validation Check Table')
      ..writeln(
        '| Check | Status | Severity | Warning | Failure | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- |');
    for (final check in validationChecks) {
      buffer.writeln(
        '| ${check.checkId} | ${check.checkStatus.wire} | '
        '${check.severity.wire} | ${_cell(check.warningReason)} | '
        '${_cell(check.failureReason)} | ${check.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Summary Group Validation Table')
      ..writeln(
        '| Row | Group | Status | Allowed fields | Denied fields | Design-only | Context-only | Inactive | Safe | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in groupRows) {
      buffer.writeln(
        '| ${row.validationRowId} | ${row.sourceSummaryGroupId.wire} | '
        '${row.validationStatus.wire} | ${_ids(row.allowedFieldIds)} | '
        '${_ids(row.deniedFieldIds)} | ${row.designOnly} | '
        '${row.contextOnly} | ${row.inactive} | ${row.safeForPhase33E} | '
        '${row.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Summary Record Validation Table')
      ..writeln(
        '| Row | Summary record | Role | Status | Allowed fields | Denied fields | Design-only | Context-only | Inactive | Safe | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in recordRows) {
      buffer.writeln(
        '| ${row.validationRowId} | ${row.sourceSummaryRecordId} | '
        '${row.summaryRole.wire} | ${row.validationStatus.wire} | '
        '${_ids(row.allowedFieldIds)} | ${_ids(row.deniedFieldIds)} | '
        '${row.designOnly} | ${row.contextOnly} | ${row.inactive} | '
        '${row.safeForPhase33E} | ${row.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Approved Core Validation')
      ..writeln(
        '- valid approved core summaries: $validApprovedCoreSummaryCount',
      )
      ..writeln()
      ..writeln('## Context-Only Validation')
      ..writeln(
        '- valid constrained context summaries: $validConstrainedContextSummaryCount',
      )
      ..writeln()
      ..writeln('## Inactive Blocked/Future Validation')
      ..writeln(
        '- valid inactive blocked summaries: $validInactiveBlockedSummaryCount',
      )
      ..writeln(
        '- valid inactive future-only summaries: $validInactiveFutureOnlySummaryCount',
      )
      ..writeln()
      ..writeln('## Allowed And Denied Field Validation')
      ..writeln('- allowed internal fields: ${_ids(allowedFieldIds)}')
      ..writeln('- denied fields: ${_ids(deniedFieldIds)}')
      ..writeln()
      ..writeln('## Stockfish Raw UCI PV Dump Denial Validation')
      ..writeln(
        '- stockfishCommand denied: ${deniedFieldIds.contains('stockfishCommand')}',
      )
      ..writeln('- rawUci denied: ${deniedFieldIds.contains('rawUci')}')
      ..writeln('- pvDump denied: ${deniedFieldIds.contains('pvDump')}')
      ..writeln()
      ..writeln('## Runtime/Prototype/Wiring Blocked Validation')
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
      ..writeln('## Phase 33E Recommendation')
      ..writeln('- ${phase33ERecommendation.wire}');
    return buffer.toString();
  }

  String renderJsonReport() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'version':
        debugBridgePrototypeDesignReadinessSummaryValidationReportVersion,
    'validationStatus': validationStatus.wire,
    'sourceSummaryStatus': sourceSummaryStatus.wire,
    'sourceReadinessGateStatus': sourceReadinessGateStatus.wire,
    'sourceValidationStatus': sourceValidationStatus.wire,
    'sourceDesignStatus': sourceDesignStatus.wire,
    'totalChecks': totalChecks,
    'passedCheckCount': passedCheckCount,
    'warningCheckCount': warningCheckCount,
    'blockerCount': blockerCount,
    'criticalCount': criticalCount,
    'totalGroupRows': totalGroupRows,
    'totalRecordRows': totalRecordRows,
    'validApprovedCoreSummaryCount': validApprovedCoreSummaryCount,
    'validConstrainedContextSummaryCount': validConstrainedContextSummaryCount,
    'validInactiveBlockedSummaryCount': validInactiveBlockedSummaryCount,
    'validInactiveFutureOnlySummaryCount': validInactiveFutureOnlySummaryCount,
    'validAllowedFieldSummaryCount': validAllowedFieldSummaryCount,
    'validDeniedFieldSummaryCount': validDeniedFieldSummaryCount,
    'validStockfishRawUciPvDumpDeniedCount':
        validStockfishRawUciPvDumpDeniedCount,
    'validRuntimePrototypeWiringBlockedCount':
        validRuntimePrototypeWiringBlockedCount,
    'validAndroidProofBoundaryCount': validAndroidProofBoundaryCount,
    'validOwnerProofBoundaryCount': validOwnerProofBoundaryCount,
    'validFutureRequirementCount': validFutureRequirementCount,
    'invalidRecordCount': invalidRecordCount,
    'unsafeRecordCount': unsafeRecordCount,
    'ownerProofQueueCount': ownerProofQueueCount,
    'supportCaseIds': supportCaseIds,
    'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
    'androidProofCaseIds': androidProofCaseIds,
    'allowedFieldIds': allowedFieldIds,
    'deniedFieldIds': deniedFieldIds,
    'safeForPhase33E': safeForPhase33E,
    'phase33ERecommendation': phase33ERecommendation.wire,
    'validationChecks': validationChecks
        .map((check) => check.toJson())
        .toList(),
    'groupRows': groupRows.map((row) => row.toJson()).toList(),
    'recordRows': recordRows.map((row) => row.toJson()).toList(),
    'findings': validationFindings.map((finding) => finding.toJson()).toList(),
    'warnings': warnings,
    'failures': failures,
    'developerOnly': developerOnly,
    'debugBridgeRuntimeImplemented': debugBridgeRuntimeImplemented,
    'executableDebugBridgePrototypeImplemented':
        executableDebugBridgePrototypeImplemented,
    'implementationWiringImplemented': implementationWiringImplemented,
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

class DebugBridgePrototypeDesignReadinessSummaryValidation {
  const DebugBridgePrototypeDesignReadinessSummaryValidation({
    this.validator =
        const DebugBridgePrototypeDesignReadinessSummaryValidationValidator(),
  });

  final DebugBridgePrototypeDesignReadinessSummaryValidationValidator validator;

  DebugBridgePrototypeDesignReadinessSummaryValidationResult evaluate([
    DebugBridgePrototypeDesignReadinessSummaryValidationRequest request =
        const DebugBridgePrototypeDesignReadinessSummaryValidationRequest(),
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
    final summaryResult =
        request.summaryResult ??
        request.summary.evaluate(
          DebugBridgePrototypeDesignReadinessSummaryRequest(
            readinessGateResult: readinessGateResult,
            validationResult: validationResult,
            designResult: designResult,
            bridgeReadinessGateResult: bridgeGateResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final groupRows = _groupRowsFromSummary(summaryResult);
    final recordRows = _recordRowsFromSummary(summaryResult);
    final checks = _validationChecks(
      summaryResult: summaryResult,
      readinessGateResult: readinessGateResult,
      groupRows: groupRows,
      recordRows: recordRows,
      androidProofEvidence: request.androidProofEvidence,
    );
    final base = _resultFromRows(
      summaryResult: summaryResult,
      readinessGateResult: readinessGateResult,
      validationResult: validationResult,
      designResult: designResult,
      checks: checks,
      groupRows: groupRows,
      recordRows: recordRows,
      validationFindings:
          const <DebugBridgePrototypeDesignReadinessSummaryValidationFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromRows(
      summaryResult: summaryResult,
      readinessGateResult: readinessGateResult,
      validationResult: validationResult,
      designResult: designResult,
      checks: checks,
      groupRows: groupRows,
      recordRows: recordRows,
      validationFindings: findings,
    );
  }
}

class DebugBridgePrototypeDesignReadinessSummaryValidationValidator {
  const DebugBridgePrototypeDesignReadinessSummaryValidationValidator();

  List<DebugBridgePrototypeDesignReadinessSummaryValidationFinding> validate(
    DebugBridgePrototypeDesignReadinessSummaryValidationResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings =
        <DebugBridgePrototypeDesignReadinessSummaryValidationFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required DebugBridgePrototypeDesignReadinessSummaryValidationSeverity
      severity,
      required String message,
      String? validationRowId,
      String? summaryRecordId,
      DebugBridgePrototypeDesignReadinessSummaryGroupId? summaryGroupId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        DebugBridgePrototypeDesignReadinessSummaryValidationFinding(
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

    if (result.safeForPhase33E &&
        (result.sourceSummaryStatus ==
                DebugBridgePrototypeDesignReadinessSummaryStatus
                    .blockedByUnsafeReadinessGate ||
            result.sourceSummaryStatus ==
                DebugBridgePrototypeDesignReadinessSummaryStatus
                    .blockedByPolicyBoundary ||
            result.unsafeRecordCount > 0)) {
      add(
        id: 'unsafePhase33CSummaryMarkedValidated',
        severity: DebugBridgePrototypeDesignReadinessSummaryValidationSeverity
            .critical,
        message: 'unsafe Phase 33C summary cannot be marked validated',
      );
    }
    if (result.validFutureRequirementCount != 1) {
      add(
        id: 'missingFuturePhase33ERequirement',
        severity: DebugBridgePrototypeDesignReadinessSummaryValidationSeverity
            .critical,
        message: 'Phase 33E implementation-design checkpoint must be present',
      );
    }
    for (final fieldId in _deniedFieldIds) {
      if (!result.deniedFieldIds.contains(fieldId)) {
        add(
          id: 'deniedFieldMissing',
          severity: DebugBridgePrototypeDesignReadinessSummaryValidationSeverity
              .blocker,
          message: '$fieldId must remain denied in summary validation',
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
    for (final row in result.groupRows) {
      for (final fieldId in row.allowedFieldIds) {
        _checkActiveAllowedField(
          add,
          fieldId,
          validationRowId: row.validationRowId,
          summaryGroupId: row.sourceSummaryGroupId,
        );
      }
      for (final proofId in row.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          proofId,
          provenAndroidIds,
          validationRowId: row.validationRowId,
          summaryGroupId: row.sourceSummaryGroupId,
        );
      }
    }
    for (final row in result.recordRows) {
      for (final fieldId in row.allowedFieldIds) {
        _checkActiveAllowedField(
          add,
          fieldId,
          validationRowId: row.validationRowId,
          summaryRecordId: row.sourceSummaryRecordId,
        );
      }
      for (final proofId in row.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          proofId,
          provenAndroidIds,
          validationRowId: row.validationRowId,
          summaryRecordId: row.sourceSummaryRecordId,
        );
      }
      _checkRecordBoundary(add, row);
      _checkSafetyFlags(add, row);
    }
    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: DebugBridgePrototypeDesignReadinessSummaryValidationSeverity
            .blocker,
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
        id: 'debugBridgePrototypeDesignReadinessSummaryValidationBoundaryPolicyViolation',
        severity: DebugBridgePrototypeDesignReadinessSummaryValidationSeverity
            .critical,
        message:
            'debug bridge prototype design readiness summary validation crossed a boundary',
      );
    }
    return findings..sort(_compareFindings);
  }

  List<DebugBridgePrototypeDesignReadinessSummaryValidationFinding>
  validateReportText(String reportText) {
    final findings =
        <DebugBridgePrototypeDesignReadinessSummaryValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        DebugBridgePrototypeDesignReadinessSummaryValidationFinding(
          id: id,
          severity: DebugBridgePrototypeDesignReadinessSummaryValidationSeverity
              .critical,
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

List<DebugBridgePrototypeDesignReadinessSummaryGroupValidationRow>
_groupRowsFromSummary(DebugBridgePrototypeDesignReadinessSummaryResult result) {
  return DebugBridgePrototypeDesignReadinessSummaryGroupId.values
      .map((groupId) => _groupRowFromSummary(result, groupId))
      .toList(growable: false);
}

DebugBridgePrototypeDesignReadinessSummaryGroupValidationRow
_groupRowFromSummary(
  DebugBridgePrototypeDesignReadinessSummaryResult result,
  DebugBridgePrototypeDesignReadinessSummaryGroupId groupId,
) {
  final group = result.group(groupId);
  final unsafe = group.hasUnsafeOutput;
  final invalid = !unsafe && group.summaryStatus.isInvalid;
  final status = unsafe
      ? DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
            .unsafeSummaryGroup
      : invalid
      ? DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
            .invalidSummaryGroup
      : _validGroupStatus(groupId);
  return DebugBridgePrototypeDesignReadinessSummaryGroupValidationRow(
    validationRowId: 'phase33d-${groupId.wire}',
    sourceSummaryGroupId: groupId,
    groupKind: _groupKind(groupId),
    validationStatus: status,
    summaryRecordIds: _sortedStrings(group.sourceGateRecordIds),
    allowedFieldIds: _sortedStrings(group.allowedFieldIds),
    deniedFieldIds: _sortedStrings(group.deniedFieldIds),
    supportCaseIds: _sortedStrings(group.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(group.newlyAddedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(group.androidProofCaseIds),
    ownerProofQueueCount:
        groupId ==
            DebugBridgePrototypeDesignReadinessSummaryGroupId
                .ownerProofBoundarySummary
        ? result.ownerProofQueueCount
        : 0,
    designOnly: group.designOnly,
    contextOnly: group.contextOnly,
    inactive: group.inactive,
    validationReason: invalid
        ? 'summary group does not match Phase 33C expectations'
        : 'summary group validates against Phase 33C and Phase 33B boundaries',
    warningReason: _groupWarningReason(groupId),
    violationReasons: unsafe
        ? const <String>['unsafe summary group output']
        : const <String>[],
    safeForPhase33E: !unsafe && !invalid,
    recommendation: unsafe
        ? DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
              .blockUnsafeSummaryValidation
        : invalid
        ? DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
              .investigateSummaryMismatch
        : _recommendationForGroup(groupId),
  );
}

List<DebugBridgePrototypeDesignReadinessSummaryRecordValidationRow>
_recordRowsFromSummary(
  DebugBridgePrototypeDesignReadinessSummaryResult result,
) {
  return DebugBridgePrototypeDesignReadinessSummaryRole.values
      .map((role) => _recordRowFromSummary(result, role))
      .toList(growable: false);
}

DebugBridgePrototypeDesignReadinessSummaryRecordValidationRow
_recordRowFromSummary(
  DebugBridgePrototypeDesignReadinessSummaryResult result,
  DebugBridgePrototypeDesignReadinessSummaryRole role,
) {
  final record = result.recordForRole(role);
  final unsafe = record.hasUnsafeOutput;
  final invalid = !unsafe && record.summaryStatus.isInvalid;
  final status = unsafe
      ? DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
            .unsafeSummaryRecord
      : invalid
      ? DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
            .invalidSummaryRecord
      : _validRecordStatus(role);
  return DebugBridgePrototypeDesignReadinessSummaryRecordValidationRow(
    validationRowId: 'phase33d-${role.wire}',
    sourceSummaryRecordId: record.summaryRecordId,
    sourceGateRecordId: record.sourceGateRecordId,
    sourceGateGroupId: record.sourceGateGroupId,
    summaryRole: role,
    summaryStatus: record.summaryStatus,
    validationStatus: status,
    allowedForFutureInternalPlanning: record.allowedForFutureInternalPlanning,
    designOnly: record.designOnly,
    contextOnly: record.contextOnly,
    inactive: record.inactive,
    allowedFieldIds: _sortedStrings(record.allowedFieldIds),
    deniedFieldIds: _sortedStrings(record.deniedFieldIds),
    supportCaseIds: _sortedStrings(record.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(record.newlyAddedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(record.androidProofCaseIds),
    safetyFlags: _safeFlagsFrom(record.safetyFlags),
    violationReasons: record.violationReasons,
    safeForPhase33E: !unsafe && !invalid,
    recommendation: unsafe
        ? DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
              .blockUnsafeSummaryValidation
        : invalid
        ? DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
              .investigateSummaryMismatch
        : _recommendationForRecord(role),
  );
}

List<DebugBridgePrototypeDesignReadinessSummaryValidationCheck>
_validationChecks({
  required DebugBridgePrototypeDesignReadinessSummaryResult summaryResult,
  required DebugBridgePrototypeDesignReadinessGateResult readinessGateResult,
  required List<DebugBridgePrototypeDesignReadinessSummaryGroupValidationRow>
  groupRows,
  required List<DebugBridgePrototypeDesignReadinessSummaryRecordValidationRow>
  recordRows,
  required GoldenAndroidProofEvidence? androidProofEvidence,
}) {
  final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
  final core = summaryResult.recordForRole(
    DebugBridgePrototypeDesignReadinessSummaryRole
        .readinessApprovedPrototypeCoreSummaryRecord,
  );
  final context = summaryResult.recordForRole(
    DebugBridgePrototypeDesignReadinessSummaryRole
        .constrainedPrototypeContextSummaryRecord,
  );
  final blocked = summaryResult.recordForRole(
    DebugBridgePrototypeDesignReadinessSummaryRole
        .inactivePrototypeBlockedSummaryRecord,
  );
  final future = summaryResult.recordForRole(
    DebugBridgePrototypeDesignReadinessSummaryRole
        .inactivePrototypeFutureOnlySummaryRecord,
  );
  final runtime = summaryResult.recordForRole(
    DebugBridgePrototypeDesignReadinessSummaryRole
        .runtimeExecutionBlockedSummaryRecord,
  );

  final checks = <DebugBridgePrototypeDesignReadinessSummaryValidationCheck>[];
  void add(
    String id,
    bool passed, {
    bool warning = false,
    DebugBridgePrototypeDesignReadinessSummaryValidationSeverity
        failureSeverity =
        DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.blocker,
    String warningReason = '',
    String failureReason = '',
    List<DebugBridgePrototypeDesignReadinessSummaryGroupId> groups =
        const <DebugBridgePrototypeDesignReadinessSummaryGroupId>[],
    List<String> records = const <String>[],
    List<String> fields = const <String>[],
    List<String> proofs = const <String>[],
    DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
        recommendation =
        DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
            .keepPolicyBoundariesBlocked,
  }) {
    checks.add(
      DebugBridgePrototypeDesignReadinessSummaryValidationCheck(
        checkId: id,
        checkStatus: passed
            ? warning
                  ? DebugBridgePrototypeDesignReadinessSummaryValidationCheckStatus
                        .passedWithWarnings
                  : DebugBridgePrototypeDesignReadinessSummaryValidationCheckStatus
                        .passed
            : failureSeverity.isCritical
            ? DebugBridgePrototypeDesignReadinessSummaryValidationCheckStatus
                  .blocked
            : DebugBridgePrototypeDesignReadinessSummaryValidationCheckStatus
                  .failed,
        severity: passed
            ? warning
                  ? DebugBridgePrototypeDesignReadinessSummaryValidationSeverity
                        .warning
                  : DebugBridgePrototypeDesignReadinessSummaryValidationSeverity
                        .none
            : failureSeverity,
        relatedSummaryGroupIds: groups,
        relatedSummaryRecordIds: records,
        relatedFieldIds: fields,
        relatedProofIds: proofs,
        warningReason: passed && warning ? warningReason : '',
        failureReason: passed ? '' : failureReason,
        recommendation: recommendation,
      ),
    );
  }

  add(
    'summaryConsumesReadinessGate',
    summaryResult.sourceReadinessGateStatus == readinessGateResult.gateStatus &&
        summaryResult.sourceValidationStatus ==
            readinessGateResult.sourceValidationStatus &&
        summaryResult.sourceDesignStatus ==
            readinessGateResult.sourceDesignStatus,
    failureReason: 'Phase 33C summary source statuses do not match Phase 33B',
    recommendation:
        DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
            .investigateSummaryMismatch,
  );
  add(
    'approvedCoreSummaryMatchesGate',
    summaryResult.approvedCoreSummaryCount ==
            readinessGateResult.readinessApprovedCoreDesignCount &&
        core.sourceGateGroupId ==
            DebugBridgePrototypeDesignReadinessGateGroupId
                .readinessApprovedPrototypeCoreDesignGroup &&
        core.designOnly &&
        !core.contextOnly &&
        !core.inactive,
    failureReason: 'approved core summary must match Phase 33B core gate rows',
    groups: const <DebugBridgePrototypeDesignReadinessSummaryGroupId>[
      DebugBridgePrototypeDesignReadinessSummaryGroupId
          .readinessApprovedPrototypeCoreSummary,
    ],
    records: <String>[core.summaryRecordId],
    recommendation:
        DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
            .keepApprovedCoreSummaryValid,
  );
  add(
    'constrainedContextSummaryMatchesGate',
    summaryResult.constrainedContextSummaryCount ==
            readinessGateResult.constrainedContextDesignCount &&
        context.sourceGateGroupId ==
            DebugBridgePrototypeDesignReadinessGateGroupId
                .constrainedPrototypeContextDesignGroup &&
        context.designOnly &&
        context.contextOnly &&
        !context.allowedForFutureInternalPlanning,
    warning: true,
    warningReason: 'context summary remains context-only by design',
    failureReason: 'context summary must stay constrained and context-only',
    groups: const <DebugBridgePrototypeDesignReadinessSummaryGroupId>[
      DebugBridgePrototypeDesignReadinessSummaryGroupId
          .constrainedPrototypeContextSummary,
    ],
    records: <String>[context.summaryRecordId],
    recommendation:
        DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
            .keepContextSummaryConstrained,
  );
  add(
    'inactiveBlockedSummaryMatchesGate',
    summaryResult.inactiveBlockedSummaryCount ==
            readinessGateResult.inactiveBlockedDesignCount &&
        blocked.inactive &&
        blocked.allowedFieldIds.isEmpty,
    warning: true,
    warningReason: 'blocked summary remains inactive by design',
    failureReason: 'blocked summary must remain inactive',
    groups: const <DebugBridgePrototypeDesignReadinessSummaryGroupId>[
      DebugBridgePrototypeDesignReadinessSummaryGroupId
          .inactivePrototypeBlockedSummary,
    ],
    records: <String>[blocked.summaryRecordId],
    recommendation:
        DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
            .keepBlockedSummaryInactive,
  );
  add(
    'inactiveFutureOnlySummaryMatchesGate',
    summaryResult.inactiveFutureOnlySummaryCount ==
            readinessGateResult.inactiveFutureOnlyDesignCount &&
        future.inactive &&
        future.allowedFieldIds.isEmpty,
    warning: true,
    warningReason: 'future-only summary remains inactive by design',
    failureReason: 'future-only summary must remain inactive',
    groups: const <DebugBridgePrototypeDesignReadinessSummaryGroupId>[
      DebugBridgePrototypeDesignReadinessSummaryGroupId
          .inactivePrototypeFutureOnlySummary,
    ],
    records: <String>[future.summaryRecordId],
    recommendation:
        DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
            .keepFutureSummaryInactive,
  );
  add(
    'allowedFieldsRemainDebugSafe',
    _sameStringSet(
          summaryResult.allowedFieldIds,
          readinessGateResult.allowedFieldIds,
        ) &&
        summaryResult.allowedFieldIds.every(
          (fieldId) =>
              !_isDeniedFieldId(fieldId) && !_isLegacyDeniedFieldId(fieldId),
        ),
    failureReason: 'allowed fields must remain internal debug-safe fields',
    fields: summaryResult.allowedFieldIds,
    recommendation:
        DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
            .keepAllowedFieldsSafe,
  );
  add(
    'deniedFieldsRemainDenied',
    _deniedFieldIds.every(summaryResult.deniedFieldIds.contains) &&
        _sameStringSet(
          summaryResult.deniedFieldIds,
          readinessGateResult.deniedFieldIds,
        ),
    failureReason: 'denied fields must remain denied',
    fields: _deniedFieldIds,
    recommendation:
        DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
            .keepDeniedFieldsDenied,
  );
  add(
    'stockfishRawUciPvDumpRemainDenied',
    _engineDumpFieldIds.every(summaryResult.deniedFieldIds.contains) &&
        !summaryResult.stockfishCommandFieldActive &&
        !summaryResult.rawUciFieldActive &&
        !summaryResult.pvDumpFieldActive,
    failureReason: 'Stockfish command, raw UCI, and PV dump must remain denied',
    fields: _engineDumpFieldIds,
    recommendation:
        DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
            .keepStockfishRawUciPvDumpDenied,
  );
  add(
    'runtimePrototypeWiringRemainBlocked',
    !summaryResult.debugBridgeRuntimeImplemented &&
        !summaryResult.executableDebugBridgePrototypeImplemented &&
        !summaryResult.implementationWiringImplemented &&
        runtime.inactive &&
        runtime.blockedBoundaryIds.contains('implementationWiring'),
    failureSeverity:
        DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.critical,
    failureReason:
        'runtime, executable prototype, and implementation wiring must remain blocked',
    records: <String>[runtime.summaryRecordId],
    recommendation:
        DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
            .keepRuntimePrototypeWiringBlocked,
  );
  add(
    'androidProofIdsAreCapturedOnly',
    _sameStringSet(
          summaryResult.androidProofCaseIds,
          _capturedAndroidProofIds,
        ) &&
        summaryResult.androidProofCaseIds.every(provenAndroidIds.contains),
    failureSeverity:
        DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.critical,
    failureReason: 'Android proof IDs must be captured proof only',
    proofs: summaryResult.androidProofCaseIds,
    recommendation:
        DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
            .keepAndroidProofBoundaryCapturedOnly,
  );
  add(
    'phase32ECasesAreNotCapturedProof',
    summaryResult.androidProofCaseIds.every(
      (caseId) => !_phase32ECaseIds.contains(caseId),
    ),
    failureSeverity:
        DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.critical,
    failureReason: 'Phase 32E cases cannot be captured Android proof',
    proofs: _phase32ECaseIds.toList(growable: false),
    recommendation:
        DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
            .keepAndroidProofBoundaryCapturedOnly,
  );
  add(
    'ownerProofQueueRemainsEmpty',
    summaryResult.ownerProofQueueCount == 0,
    failureReason: 'owner proof queue must remain empty by default',
    recommendation:
        DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
            .keepOwnerProofEmpty,
  );
  add(
    'noLabelsScoresRankingsMetrics',
    !summaryResult.classifierOutputActive &&
        !summaryResult.finalMoveLabelOutputActive &&
        !summaryResult.numericOutputActive &&
        !summaryResult.aggregateScoreOutputActive &&
        !summaryResult.moveRankingOutputActive &&
        !summaryResult.officialMetricOutputActive &&
        !summaryResult.cpLossOutputActive &&
        !summaryResult.winProbabilityOutputActive,
    failureSeverity:
        DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.critical,
    failureReason:
        'labels, scores, rankings, metrics, CP-loss, and win probability must remain inactive',
    recommendation:
        DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
            .keepPolicyBoundariesBlocked,
  );
  add(
    'noUiBackendPersistenceEngineFields',
    !summaryResult.uiTargetsActive &&
        !summaryResult.backendOutputActive &&
        !summaryResult.persistenceWritesActive &&
        !summaryResult.engineCallsActive &&
        !summaryResult.stockfishCommandFieldActive &&
        !summaryResult.rawUciFieldActive &&
        !summaryResult.pvDumpFieldActive,
    failureSeverity:
        DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.critical,
    failureReason:
        'UI, backend, persistence, direct engine, Stockfish, raw UCI, and PV dump fields must remain inactive',
    recommendation:
        DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
            .keepPolicyBoundariesBlocked,
  );
  add(
    'quietScopeRemainsExcluded',
    !summaryResult.quietPreparatoryScopeActivated,
    failureSeverity:
        DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.critical,
    failureReason: 'quiet/preparatory scope must remain excluded',
    recommendation:
        DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
            .keepPolicyBoundariesBlocked,
  );
  add(
    'productBoundariesRemainBlocked',
    !summaryResult.productOutputActive &&
        !summaryResult.classifierOutputActive &&
        !summaryResult.finalMoveLabelOutputActive,
    failureSeverity:
        DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.critical,
    failureReason: 'product-facing boundaries must remain blocked',
    recommendation:
        DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
            .keepPolicyBoundariesBlocked,
  );
  return checks;
}

DebugBridgePrototypeDesignReadinessSummaryValidationResult _resultFromRows({
  required DebugBridgePrototypeDesignReadinessSummaryResult summaryResult,
  required DebugBridgePrototypeDesignReadinessGateResult readinessGateResult,
  required DebugOnlyBridgePrototypeDesignValidationResult validationResult,
  required DebugOnlyBridgePrototypeDesignResult designResult,
  required List<DebugBridgePrototypeDesignReadinessSummaryValidationCheck>
  checks,
  required List<DebugBridgePrototypeDesignReadinessSummaryGroupValidationRow>
  groupRows,
  required List<DebugBridgePrototypeDesignReadinessSummaryRecordValidationRow>
  recordRows,
  required List<DebugBridgePrototypeDesignReadinessSummaryValidationFinding>
  validationFindings,
}) {
  final invalidRecordCount = recordRows
      .where((row) => row.validationStatus.isInvalid)
      .length;
  final unsafeRecordCount =
      summaryResult.unsafeCount +
      recordRows.where((row) => row.hasUnsafeOutput).length;
  final blockerCount =
      checks.where((check) => check.severity.blocksStrict).length +
      validationFindings.where((finding) => finding.blocksStrict).length;
  final criticalCount =
      checks.where((check) => check.isCritical).length +
      validationFindings.where((finding) => finding.isCritical).length;
  final base = DebugBridgePrototypeDesignReadinessSummaryValidationResult(
    validationStatus:
        DebugBridgePrototypeDesignReadinessSummaryValidationStatus.invalid,
    sourceSummaryStatus: summaryResult.summaryStatus,
    sourceReadinessGateStatus: readinessGateResult.gateStatus,
    sourceValidationStatus: validationResult.validationStatus,
    sourceDesignStatus: designResult.designStatus,
    validationChecks: checks,
    groupRows: groupRows,
    recordRows: recordRows,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...summaryResult.warnings,
      ...checks
          .where((check) => check.checkStatus.isWarning)
          .map((check) => check.warningReason),
      'Phase 33D is validation-only before implementation design',
    ]),
    failures: _sortedStrings(<String>[
      ...summaryResult.failures,
      ...checks
          .where((check) => check.checkStatus.isBlocked)
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
              DebugBridgePrototypeDesignReadinessSummaryValidationCheckStatus
                  .passed,
        )
        .length,
    warningCheckCount: checks
        .where(
          (check) =>
              check.checkStatus ==
              DebugBridgePrototypeDesignReadinessSummaryValidationCheckStatus
                  .passedWithWarnings,
        )
        .length,
    blockerCount: blockerCount,
    criticalCount: criticalCount,
    totalGroupRows: groupRows.length,
    totalRecordRows: recordRows.length,
    validApprovedCoreSummaryCount: _countRecordRows(
      recordRows,
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validApprovedCoreSummaryRecord,
    ),
    validConstrainedContextSummaryCount: _countRecordRows(
      recordRows,
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validConstrainedContextSummaryRecord,
    ),
    validInactiveBlockedSummaryCount: _countRecordRows(
      recordRows,
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validInactiveBlockedSummaryRecord,
    ),
    validInactiveFutureOnlySummaryCount: _countRecordRows(
      recordRows,
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validInactiveFutureOnlySummaryRecord,
    ),
    validAllowedFieldSummaryCount: _countRecordRows(
      recordRows,
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validAllowedFieldSummaryRecord,
    ),
    validDeniedFieldSummaryCount: _countRecordRows(
      recordRows,
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validDeniedFieldSummaryRecord,
    ),
    validStockfishRawUciPvDumpDeniedCount: _countRecordRows(
      recordRows,
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validStockfishRawUciPvDumpDeniedRecord,
    ),
    validRuntimePrototypeWiringBlockedCount: _countRecordRows(
      recordRows,
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validRuntimePrototypeWiringBlockedRecord,
    ),
    validAndroidProofBoundaryCount: _countRecordRows(
      recordRows,
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validAndroidProofBoundaryRecord,
    ),
    validOwnerProofBoundaryCount: _countRecordRows(
      recordRows,
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validOwnerProofBoundaryRecord,
    ),
    validFutureRequirementCount: _countRecordRows(
      recordRows,
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validFutureRequirementRecord,
    ),
    invalidRecordCount: invalidRecordCount,
    unsafeRecordCount: unsafeRecordCount,
    ownerProofQueueCount: summaryResult.ownerProofQueueCount,
    supportCaseIds: _sortedStrings(summaryResult.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(
      summaryResult.newlyAddedSupportCaseIds,
    ),
    androidProofCaseIds: _sortedStrings(summaryResult.androidProofCaseIds),
    allowedFieldIds: _sortedStrings(summaryResult.allowedFieldIds),
    deniedFieldIds: _sortedStrings(summaryResult.deniedFieldIds),
    safeForPhase33E: false,
    phase33ERecommendation:
        DebugBridgePrototypeDesignReadinessSummaryValidationPhase33ERecommendation
            .addMoreGoldenCoverageFirst,
    developerOnly:
        summaryResult.developerOnly &&
        readinessGateResult.developerOnly &&
        validationResult.developerOnly &&
        designResult.developerOnly,
    debugBridgeRuntimeImplemented: summaryResult.debugBridgeRuntimeImplemented,
    executableDebugBridgePrototypeImplemented:
        summaryResult.executableDebugBridgePrototypeImplemented,
    implementationWiringImplemented:
        summaryResult.implementationWiringImplemented,
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
  final safeForPhase33E =
      (status ==
              DebugBridgePrototypeDesignReadinessSummaryValidationStatus
                  .validatedWithWarnings ||
          status ==
              DebugBridgePrototypeDesignReadinessSummaryValidationStatus
                  .validatedClean) &&
      summaryResult.safeForPhase33D &&
      !summaryResult.isStrictlyBlocked &&
      !summaryResult
          .hasUnsafeDebugBridgePrototypeDesignReadinessSummaryPolicyViolation &&
      unsafeRecordCount == 0 &&
      blockerCount == 0 &&
      criticalCount == 0 &&
      checks.every((check) => !check.isBlocking) &&
      validationFindings.every((finding) => !finding.blocksStrict) &&
      groupRows.every((row) => row.safeForPhase33E) &&
      recordRows.every((row) => row.safeForPhase33E && !row.hasUnsafeOutput);
  return base.copyWith(
    validationStatus: status,
    safeForPhase33E: safeForPhase33E,
    phase33ERecommendation: _phase33ERecommendationFor(
      status: status,
      safeForPhase33E: safeForPhase33E,
      ownerProofQueueCount: summaryResult.ownerProofQueueCount,
    ),
  );
}

DebugBridgePrototypeDesignReadinessSummaryValidationStatus _validationStatusFor(
  DebugBridgePrototypeDesignReadinessSummaryValidationResult result, {
  required DebugBridgePrototypeDesignReadinessSummaryResult summaryResult,
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
    return DebugBridgePrototypeDesignReadinessSummaryValidationStatus
        .blockedByPolicyBoundary;
  }
  if (summaryResult.summaryStatus ==
          DebugBridgePrototypeDesignReadinessSummaryStatus
              .blockedByUnsafeReadinessGate ||
      summaryResult.summaryStatus ==
          DebugBridgePrototypeDesignReadinessSummaryStatus
              .blockedByPolicyBoundary ||
      summaryResult.unsafeCount > 0 ||
      summaryResult.criticalCount > 0 ||
      summaryResult
          .hasUnsafeDebugBridgePrototypeDesignReadinessSummaryPolicyViolation ||
      result.unsafeRecordCount > 0 ||
      result.criticalCount > 0) {
    return DebugBridgePrototypeDesignReadinessSummaryValidationStatus
        .blockedByUnsafeSummary;
  }
  if (result.validationChecks.any(
        (check) =>
            check.checkStatus ==
            DebugBridgePrototypeDesignReadinessSummaryValidationCheckStatus
                .failed,
      ) ||
      result.invalidRecordCount > 0) {
    return DebugBridgePrototypeDesignReadinessSummaryValidationStatus
        .blockedBySummaryMismatch;
  }
  if (!summaryResult.safeForPhase33D ||
      summaryResult.isStrictlyBlocked ||
      result.blockerCount > 0 ||
      result.validationFindings.any((finding) => finding.blocksStrict) ||
      result.groupRows.any((row) => !row.safeForPhase33E) ||
      result.recordRows.any((row) => !row.safeForPhase33E)) {
    return DebugBridgePrototypeDesignReadinessSummaryValidationStatus.invalid;
  }
  if (result.validationChecks.isEmpty ||
      result.groupRows.isEmpty ||
      result.recordRows.isEmpty) {
    return DebugBridgePrototypeDesignReadinessSummaryValidationStatus.invalid;
  }
  if (result.warningCheckCount > 0 || result.warnings.isNotEmpty) {
    return DebugBridgePrototypeDesignReadinessSummaryValidationStatus
        .validatedWithWarnings;
  }
  return DebugBridgePrototypeDesignReadinessSummaryValidationStatus
      .validatedClean;
}

DebugBridgePrototypeDesignReadinessSummaryValidationPhase33ERecommendation
_phase33ERecommendationFor({
  required DebugBridgePrototypeDesignReadinessSummaryValidationStatus status,
  required bool safeForPhase33E,
  required int ownerProofQueueCount,
}) {
  if (status ==
          DebugBridgePrototypeDesignReadinessSummaryValidationStatus
              .blockedByUnsafeSummary ||
      status ==
          DebugBridgePrototypeDesignReadinessSummaryValidationStatus
              .blockedByPolicyBoundary) {
    return DebugBridgePrototypeDesignReadinessSummaryValidationPhase33ERecommendation
        .blockedByUnsafePrototypeDesignReadinessSummaryValidation;
  }
  if (ownerProofQueueCount > 0) {
    return DebugBridgePrototypeDesignReadinessSummaryValidationPhase33ERecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase33E) {
    return DebugBridgePrototypeDesignReadinessSummaryValidationPhase33ERecommendation
        .addMoreGoldenCoverageFirst;
  }
  return DebugBridgePrototypeDesignReadinessSummaryValidationPhase33ERecommendation
      .proceedToDebugOnlyBridgeImplementationDesign;
}

void _checkRecordBoundary(
  void Function({
    required String id,
    required DebugBridgePrototypeDesignReadinessSummaryValidationSeverity
    severity,
    required String message,
    String? validationRowId,
    String? summaryRecordId,
    DebugBridgePrototypeDesignReadinessSummaryGroupId? summaryGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugBridgePrototypeDesignReadinessSummaryRecordValidationRow row,
) {
  if (!row.designOnly) {
    add(
      id: 'prototypeSummaryValidationRecordNotDesignOnly',
      severity:
          DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.critical,
      message: 'summary validation records must stay design-only',
      validationRowId: row.validationRowId,
      summaryRecordId: row.sourceSummaryRecordId,
    );
  }
  if (row.validationStatus ==
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validApprovedCoreSummaryRecord) {
    if (row.contextOnly ||
        row.inactive ||
        row.sourceGateGroupId !=
            DebugBridgePrototypeDesignReadinessGateGroupId
                .readinessApprovedPrototypeCoreDesignGroup ||
        row.violationReasons.contains('prototypeCoreConsumesNonCoreInput') ||
        row.violationReasons.contains(
          'prototypeCoreSummaryConsumesNonCoreInput',
        )) {
      add(
        id: 'approvedCoreSummaryConsumesNonCoreInput',
        severity: DebugBridgePrototypeDesignReadinessSummaryValidationSeverity
            .critical,
        message: 'approved core summary cannot consume non-core input',
        validationRowId: row.validationRowId,
        summaryRecordId: row.sourceSummaryRecordId,
      );
    }
  }
  if (row.validationStatus ==
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validConstrainedContextSummaryRecord) {
    if (!row.contextOnly || row.allowedForFutureInternalPlanning) {
      add(
        id: 'contextOnlySummaryPromotedToCore',
        severity: DebugBridgePrototypeDesignReadinessSummaryValidationSeverity
            .critical,
        message: 'context-only summary cannot become core',
        validationRowId: row.validationRowId,
        summaryRecordId: row.sourceSummaryRecordId,
      );
    }
  }
  if (row.contextOnly &&
      row.validationStatus ==
          DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
              .validApprovedCoreSummaryRecord) {
    add(
      id: 'contextOnlySummaryPromotedToCore',
      severity:
          DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.critical,
      message: 'context-only summary cannot become core',
      validationRowId: row.validationRowId,
      summaryRecordId: row.sourceSummaryRecordId,
    );
  }
  if (row.validationStatus.isInactiveBoundary &&
      (!row.inactive || row.allowedFieldIds.isNotEmpty)) {
    add(
      id: 'blockedFutureSummaryMadeActive',
      severity:
          DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.critical,
      message:
          'blocked, future-only, denied, Stockfish, and runtime rows must stay inactive',
      validationRowId: row.validationRowId,
      summaryRecordId: row.sourceSummaryRecordId,
    );
  }
}

void _checkSafetyFlags(
  void Function({
    required String id,
    required DebugBridgePrototypeDesignReadinessSummaryValidationSeverity
    severity,
    required String message,
    String? validationRowId,
    String? summaryRecordId,
    DebugBridgePrototypeDesignReadinessSummaryGroupId? summaryGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugBridgePrototypeDesignReadinessSummaryRecordValidationRow row,
) {
  void critical(String id, String message) {
    add(
      id: id,
      severity:
          DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.critical,
      message: message,
      validationRowId: row.validationRowId,
      summaryRecordId: row.sourceSummaryRecordId,
    );
  }

  if (row.safetyFlags['isProductOutput'] == true) {
    critical('productOutputActive', 'validation cannot be product output');
  }
  if (row.safetyFlags['isClassifierLabel'] == true) {
    critical(
      'classifierLabelOutputActive',
      'validation cannot emit classifier labels',
    );
  }
  if (row.safetyFlags['hasNumericScore'] == true) {
    critical(
      'numericScoreOutputActive',
      'validation cannot emit numeric scores',
    );
  }
  if (row.safetyFlags['hasAggregateScore'] == true) {
    critical(
      'aggregateScoreOutputActive',
      'validation cannot emit aggregate scores',
    );
  }
  if (row.safetyFlags['ranksMoves'] == true) {
    critical('moveRankingOutputActive', 'validation cannot rank moves');
  }
  if (row.safetyFlags['isOfficialMetric'] == true) {
    critical(
      'officialMetricOutputActive',
      'validation cannot emit official metrics',
    );
  }
  if (row.safetyFlags['exposesCpLoss'] == true ||
      row.safetyFlags['exposesWinProbability'] == true) {
    critical(
      'futureMetricOutputActive',
      'validation cannot expose CP-loss or win probability',
    );
  }
  if (row.safetyFlags['quietPreparatoryScopeActive'] == true) {
    critical(
      'quietPreparatoryScopeActivated',
      'quiet/preparatory scope must remain excluded',
    );
  }
  if (row.safetyFlags['callsEngine'] == true) {
    critical('engineCallFlagActive', 'validation cannot call an engine');
  }
  if (row.safetyFlags['writesPersistence'] == true) {
    critical(
      'persistenceWriteFlagActive',
      'validation cannot write persistence',
    );
  }
  if (row.safetyFlags['targetsUi'] == true) {
    critical('uiTargetFlagActive', 'validation cannot target UI');
  }
  if (row.safetyFlags['backendOutputActive'] == true ||
      row.safetyFlags['targetsBackend'] == true) {
    critical('backendOutputActive', 'validation cannot target backend');
  }
  if (row.safetyFlags['exposesStockfishCommand'] == true ||
      row.safetyFlags['exposesRawUci'] == true ||
      row.safetyFlags['exposesPvDump'] == true) {
    critical(
      'stockfishRawUciPvDumpFieldActive',
      'Stockfish command, raw UCI, and PV dump fields must remain denied',
    );
  }
  if (row.safetyFlags['implementsRuntime'] == true) {
    critical(
      'runtimeImplementationFlagActive',
      'validation cannot implement runtime behavior',
    );
  }
  if (row.safetyFlags['implementsPrototypeExecution'] == true) {
    critical(
      'executablePrototypeImplementationFlagActive',
      'validation cannot implement executable prototype behavior',
    );
  }
  if (row.safetyFlags['implementsWiring'] == true) {
    critical(
      'implementationWiringFlagActive',
      'validation cannot implement wiring',
    );
  }
}

void _checkActiveAllowedField(
  void Function({
    required String id,
    required DebugBridgePrototypeDesignReadinessSummaryValidationSeverity
    severity,
    required String message,
    String? validationRowId,
    String? summaryRecordId,
    DebugBridgePrototypeDesignReadinessSummaryGroupId? summaryGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String fieldId, {
  String? validationRowId,
  String? summaryRecordId,
  DebugBridgePrototypeDesignReadinessSummaryGroupId? summaryGroupId,
}) {
  if (_isDeniedFieldId(fieldId) || _isLegacyDeniedFieldId(fieldId)) {
    add(
      id: 'activeDeniedField',
      severity:
          DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.critical,
      message: '$fieldId cannot be active summary validation output',
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
    required DebugBridgePrototypeDesignReadinessSummaryValidationSeverity
    severity,
    required String message,
    String? validationRowId,
    String? summaryRecordId,
    DebugBridgePrototypeDesignReadinessSummaryGroupId? summaryGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String caseId,
  List<String> provenAndroidIds, {
  String? validationRowId,
  String? summaryRecordId,
  DebugBridgePrototypeDesignReadinessSummaryGroupId? summaryGroupId,
}) {
  if (_phase32ECaseIds.contains(caseId)) {
    add(
      id: 'phase32ECaseTreatedAsCapturedProof',
      severity:
          DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.critical,
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
      severity:
          DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.critical,
      message: '$caseId is not captured Android proof',
      validationRowId: validationRowId,
      summaryRecordId: summaryRecordId,
      summaryGroupId: summaryGroupId,
      caseId: caseId,
    );
  }
}

DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
_validGroupStatus(DebugBridgePrototypeDesignReadinessSummaryGroupId groupId) {
  return switch (groupId) {
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .readinessApprovedPrototypeCoreSummary =>
      DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
          .validApprovedCoreSummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .constrainedPrototypeContextSummary =>
      DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
          .validConstrainedContextSummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .inactivePrototypeBlockedSummary =>
      DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
          .validInactiveBlockedSummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .inactivePrototypeFutureOnlySummary =>
      DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
          .validInactiveFutureOnlySummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .approvedAllowedFieldSummary =>
      DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
          .validAllowedFieldSummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .deniedFieldBoundarySummary =>
      DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
          .validDeniedFieldSummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .stockfishRawUciPvDumpDeniedSummary =>
      DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
          .validStockfishRawUciPvDumpDeniedSummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .runtimeExecutionBlockedSummary =>
      DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
          .validRuntimePrototypeWiringBlockedSummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .androidProofBoundarySummary =>
      DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
          .validAndroidProofBoundarySummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .ownerProofBoundarySummary =>
      DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
          .validOwnerProofBoundarySummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .futurePhase33DRequirementSummary =>
      DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
          .validFutureRequirementSummary,
  };
}

DebugBridgePrototypeDesignReadinessSummaryValidationGroupKind _groupKind(
  DebugBridgePrototypeDesignReadinessSummaryGroupId groupId,
) {
  return switch (groupId) {
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .readinessApprovedPrototypeCoreSummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationGroupKind
          .validApprovedCoreSummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .constrainedPrototypeContextSummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationGroupKind
          .validConstrainedContextSummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .inactivePrototypeBlockedSummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationGroupKind
          .validInactiveBlockedSummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .inactivePrototypeFutureOnlySummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationGroupKind
          .validInactiveFutureOnlySummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .approvedAllowedFieldSummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationGroupKind
          .validAllowedFieldSummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .deniedFieldBoundarySummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationGroupKind
          .validDeniedFieldSummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .stockfishRawUciPvDumpDeniedSummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationGroupKind
          .validStockfishRawUciPvDumpDeniedSummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .runtimeExecutionBlockedSummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationGroupKind
          .validRuntimePrototypeWiringBlockedSummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .androidProofBoundarySummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationGroupKind
          .validAndroidProofBoundarySummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .ownerProofBoundarySummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationGroupKind
          .validOwnerProofBoundarySummary,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .futurePhase33DRequirementSummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationGroupKind
          .validFutureRequirementSummary,
  };
}

DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
_validRecordStatus(DebugBridgePrototypeDesignReadinessSummaryRole role) {
  return switch (role) {
    DebugBridgePrototypeDesignReadinessSummaryRole
        .readinessApprovedPrototypeCoreSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validApprovedCoreSummaryRecord,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .constrainedPrototypeContextSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validConstrainedContextSummaryRecord,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .inactivePrototypeBlockedSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validInactiveBlockedSummaryRecord,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .inactivePrototypeFutureOnlySummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validInactiveFutureOnlySummaryRecord,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .approvedAllowedFieldSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validAllowedFieldSummaryRecord,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .deniedFieldBoundarySummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validDeniedFieldSummaryRecord,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .stockfishRawUciPvDumpDeniedSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validStockfishRawUciPvDumpDeniedRecord,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .runtimeExecutionBlockedSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validRuntimePrototypeWiringBlockedRecord,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .androidProofBoundarySummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validAndroidProofBoundaryRecord,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .ownerProofBoundarySummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validOwnerProofBoundaryRecord,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .futurePhase33DRequirementSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
          .validFutureRequirementRecord,
  };
}

DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
_recommendationForGroup(
  DebugBridgePrototypeDesignReadinessSummaryGroupId groupId,
) {
  return switch (groupId) {
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .readinessApprovedPrototypeCoreSummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepApprovedCoreSummaryValid,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .constrainedPrototypeContextSummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepContextSummaryConstrained,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .inactivePrototypeBlockedSummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepBlockedSummaryInactive,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .inactivePrototypeFutureOnlySummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepFutureSummaryInactive,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .approvedAllowedFieldSummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepAllowedFieldsSafe,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .deniedFieldBoundarySummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepDeniedFieldsDenied,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .stockfishRawUciPvDumpDeniedSummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepStockfishRawUciPvDumpDenied,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .runtimeExecutionBlockedSummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepRuntimePrototypeWiringBlocked,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .androidProofBoundarySummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepAndroidProofBoundaryCapturedOnly,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .ownerProofBoundarySummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepOwnerProofEmpty,
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .futurePhase33DRequirementSummary =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepFutureImplementationDesignCheckpoint,
  };
}

DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
_recommendationForRecord(DebugBridgePrototypeDesignReadinessSummaryRole role) {
  return switch (role) {
    DebugBridgePrototypeDesignReadinessSummaryRole
        .readinessApprovedPrototypeCoreSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepApprovedCoreSummaryValid,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .constrainedPrototypeContextSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepContextSummaryConstrained,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .inactivePrototypeBlockedSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepBlockedSummaryInactive,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .inactivePrototypeFutureOnlySummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepFutureSummaryInactive,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .approvedAllowedFieldSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepAllowedFieldsSafe,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .deniedFieldBoundarySummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepDeniedFieldsDenied,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .stockfishRawUciPvDumpDeniedSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepStockfishRawUciPvDumpDenied,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .runtimeExecutionBlockedSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepRuntimePrototypeWiringBlocked,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .androidProofBoundarySummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepAndroidProofBoundaryCapturedOnly,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .ownerProofBoundarySummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepOwnerProofEmpty,
    DebugBridgePrototypeDesignReadinessSummaryRole
        .futurePhase33DRequirementSummaryRecord =>
      DebugBridgePrototypeDesignReadinessSummaryValidationRecommendation
          .keepFutureImplementationDesignCheckpoint,
  };
}

String _groupWarningReason(
  DebugBridgePrototypeDesignReadinessSummaryGroupId groupId,
) {
  return switch (groupId) {
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .constrainedPrototypeContextSummary =>
      'context summary remains context-only',
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .inactivePrototypeBlockedSummary =>
      'blocked summary remains inactive',
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .inactivePrototypeFutureOnlySummary =>
      'future-only summary remains inactive',
    DebugBridgePrototypeDesignReadinessSummaryGroupId
        .runtimeExecutionBlockedSummary =>
      'runtime, executable prototype, and wiring remain blocked',
    _ => '',
  };
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
  DebugBridgePrototypeDesignReadinessSummaryValidationResult result,
) {
  final reasons = <String>[
    ...result.warnings,
    ...result.failures,
    ...result.validationChecks.map((check) => check.warningReason),
  ].join(' ').toLowerCase();
  return reasons.contains('pv') || reasons.contains('multipv');
}

int _countRecordRows(
  Iterable<DebugBridgePrototypeDesignReadinessSummaryRecordValidationRow> rows,
  DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus status,
) {
  return rows.where((row) => row.validationStatus == status).length;
}

List<String> _provenAndroidProofIds(GoldenAndroidProofEvidence? evidence) {
  return _sortedStrings(evidence?.targetCaseIds ?? const <String>[]);
}

int _compareFindings(
  DebugBridgePrototypeDesignReadinessSummaryValidationFinding a,
  DebugBridgePrototypeDesignReadinessSummaryValidationFinding b,
) {
  final severity = _severityRank(
    b.severity,
  ).compareTo(_severityRank(a.severity));
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.summaryRecordId ?? '').compareTo(b.summaryRecordId ?? '');
}

int _severityRank(
  DebugBridgePrototypeDesignReadinessSummaryValidationSeverity severity,
) {
  return switch (severity) {
    DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.none => 0,
    DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.info => 1,
    DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.warning => 2,
    DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.blocker => 3,
    DebugBridgePrototypeDesignReadinessSummaryValidationSeverity.critical => 4,
  };
}

bool _sameStringSet(Iterable<String> left, Iterable<String> right) {
  final leftSet = left.toSet();
  final rightSet = right.toSet();
  return leftSet.length == rightSet.length && leftSet.every(rightSet.contains);
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

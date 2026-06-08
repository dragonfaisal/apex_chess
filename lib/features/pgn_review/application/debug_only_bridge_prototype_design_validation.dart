/// Developer-only validation for the debug-only bridge prototype design.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_summary_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugOnlyBridgePrototypeDesignValidationReportVersion =
    'debug-only-bridge-prototype-design-validation-v1';

enum DebugOnlyBridgePrototypeDesignValidationStatus {
  validatedWithWarnings('validatedWithWarnings'),
  validatedClean('validatedClean'),
  blockedByUnsafePrototypeDesign('blockedByUnsafePrototypeDesign'),
  blockedByPrototypeDesignMismatch('blockedByPrototypeDesignMismatch'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const DebugOnlyBridgePrototypeDesignValidationStatus(this.wire);

  final String wire;
}

enum DebugOnlyBridgePrototypeDesignValidationCheckStatus {
  passed('passed'),
  passedWithWarnings('passedWithWarnings'),
  failed('failed'),
  blocked('blocked'),
  notApplicable('notApplicable');

  const DebugOnlyBridgePrototypeDesignValidationCheckStatus(this.wire);

  final String wire;

  bool get isPassed => this == passed || this == passedWithWarnings;

  bool get isWarning => this == passedWithWarnings;

  bool get isBlocked => this == failed || this == blocked;
}

enum DebugOnlyBridgePrototypeDesignValidationSeverity {
  none('none'),
  info('info'),
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const DebugOnlyBridgePrototypeDesignValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict => this == blocker || this == critical;

  bool get isCritical => this == critical;
}

enum DebugOnlyBridgePrototypeDesignSectionValidationKind {
  validPrototypeCoreInputDesign('validPrototypeCoreInputDesign'),
  validPrototypeContextInputDesign('validPrototypeContextInputDesign'),
  validInactiveBlockedInputDesign('validInactiveBlockedInputDesign'),
  validInactiveFutureOnlyInputDesign('validInactiveFutureOnlyInputDesign'),
  validAllowedFieldDesign('validAllowedFieldDesign'),
  validDeniedFieldDesign('validDeniedFieldDesign'),
  validStockfishRawUciPvDumpDeniedDesign(
    'validStockfishRawUciPvDumpDeniedDesign',
  ),
  validAndroidProofBoundaryDesign('validAndroidProofBoundaryDesign'),
  validOwnerProofBoundaryDesign('validOwnerProofBoundaryDesign'),
  validFuturePrototypeValidationRequirements(
    'validFuturePrototypeValidationRequirements',
  );

  const DebugOnlyBridgePrototypeDesignSectionValidationKind(this.wire);

  final String wire;
}

enum DebugOnlyBridgePrototypeDesignSectionValidationStatus {
  validPrototypeCoreInputDesign('validPrototypeCoreInputDesign'),
  validPrototypeContextInputDesign('validPrototypeContextInputDesign'),
  validInactiveBlockedInputDesign('validInactiveBlockedInputDesign'),
  validInactiveFutureOnlyInputDesign('validInactiveFutureOnlyInputDesign'),
  validAllowedFieldDesign('validAllowedFieldDesign'),
  validDeniedFieldDesign('validDeniedFieldDesign'),
  validStockfishRawUciPvDumpDeniedDesign(
    'validStockfishRawUciPvDumpDeniedDesign',
  ),
  validAndroidProofBoundaryDesign('validAndroidProofBoundaryDesign'),
  validOwnerProofBoundaryDesign('validOwnerProofBoundaryDesign'),
  validFuturePrototypeValidationRequirements(
    'validFuturePrototypeValidationRequirements',
  ),
  invalidDesignSection('invalidDesignSection'),
  unsafeDesignSection('unsafeDesignSection');

  const DebugOnlyBridgePrototypeDesignSectionValidationStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == unsafeDesignSection;

  bool get isInvalid => this == invalidDesignSection;
}

enum DebugOnlyBridgePrototypeDesignRecordValidationStatus {
  validPrototypeCoreDesignRecord('validPrototypeCoreDesignRecord'),
  validPrototypeContextDesignRecord('validPrototypeContextDesignRecord'),
  validInactiveBlockedDesignRecord('validInactiveBlockedDesignRecord'),
  validInactiveFutureOnlyDesignRecord('validInactiveFutureOnlyDesignRecord'),
  validAllowedFieldDesignRecord('validAllowedFieldDesignRecord'),
  validDeniedFieldDesignRecord('validDeniedFieldDesignRecord'),
  validStockfishRawUciPvDumpDeniedRecord(
    'validStockfishRawUciPvDumpDeniedRecord',
  ),
  validAndroidProofBoundaryRecord('validAndroidProofBoundaryRecord'),
  validOwnerProofBoundaryRecord('validOwnerProofBoundaryRecord'),
  validFutureValidationRequirementRecord(
    'validFutureValidationRequirementRecord',
  ),
  invalidPrototypeDesignRecord('invalidPrototypeDesignRecord'),
  unsafePrototypeDesignRecord('unsafePrototypeDesignRecord');

  const DebugOnlyBridgePrototypeDesignRecordValidationStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == unsafePrototypeDesignRecord;

  bool get isInvalid => this == invalidPrototypeDesignRecord;

  bool get isInactiveBoundary =>
      this == validInactiveBlockedDesignRecord ||
      this == validInactiveFutureOnlyDesignRecord ||
      this == validDeniedFieldDesignRecord ||
      this == validStockfishRawUciPvDumpDeniedRecord;
}

enum DebugOnlyBridgePrototypeDesignValidationRecommendation {
  keepPrototypeCoreDesignValidated('keepPrototypeCoreDesignValidated'),
  keepPrototypeContextDesignValidated('keepPrototypeContextDesignValidated'),
  keepBlockedDesignInactive('keepBlockedDesignInactive'),
  keepFutureDesignInactive('keepFutureDesignInactive'),
  keepAllowedFieldsValidated('keepAllowedFieldsValidated'),
  keepDeniedFieldsDenied('keepDeniedFieldsDenied'),
  keepStockfishRawUciPvDumpDenied('keepStockfishRawUciPvDumpDenied'),
  keepAndroidProofBoundaryCapturedOnly('keepAndroidProofBoundaryCapturedOnly'),
  keepOwnerProofEmpty('keepOwnerProofEmpty'),
  keepPhase33AValidationRequirementSatisfied(
    'keepPhase33AValidationRequirementSatisfied',
  ),
  keepPolicyBoundariesBlocked('keepPolicyBoundariesBlocked'),
  investigatePrototypeDesignMismatch('investigatePrototypeDesignMismatch'),
  blockUnsafePrototypeDesignValidation('blockUnsafePrototypeDesignValidation');

  const DebugOnlyBridgePrototypeDesignValidationRecommendation(this.wire);

  final String wire;
}

enum DebugOnlyBridgePrototypeDesignValidationPhase33BRecommendation {
  proceedToDebugBridgePrototypeDesignReadinessGate(
    'proceedToDebugBridgePrototypeDesignReadinessGate',
  ),
  proceedToDebugBridgePrototypeDesignSummary(
    'proceedToDebugBridgePrototypeDesignSummary',
  ),
  proceedToDebugOnlyBridgePrototypeImplementationDesign(
    'proceedToDebugOnlyBridgePrototypeImplementationDesign',
  ),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafePrototypeDesignValidation(
    'blockedByUnsafePrototypeDesignValidation',
  );

  const DebugOnlyBridgePrototypeDesignValidationPhase33BRecommendation(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgePrototypeDesignValidationReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgePrototypeDesignValidationReportFormat(this.wire);

  final String wire;
}

class DebugOnlyBridgePrototypeDesignValidationRequest {
  const DebugOnlyBridgePrototypeDesignValidationRequest({
    this.designResult,
    this.gateResult,
    this.validationResult,
    this.summaryResult,
    this.readinessGateResult,
    this.bridgeValidationResult,
    this.prototypeDesign = const DebugOnlyBridgePrototypeDesign(),
    this.gate = const DebugBridgeReadinessValidationGate(),
    this.validation = const DebugBridgeReadinessSummaryValidation(),
    this.summary = const DebugBridgeReadinessSummary(),
    this.readinessGate = const DebugBridgeDesignReadinessGate(),
    this.bridgeValidation = const DebugOnlyAdapterBridgeDesignValidation(),
    this.adapterBridgeDesign = const DebugOnlyAdapterBridgeDesign(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const DebugOnlyBridgePrototypeDesignValidationRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final DebugOnlyBridgePrototypeDesignResult? designResult;
  final DebugBridgeReadinessValidationGateResult? gateResult;
  final DebugBridgeReadinessSummaryValidationResult? validationResult;
  final DebugBridgeReadinessSummaryResult? summaryResult;
  final DebugBridgeDesignReadinessGateResult? readinessGateResult;
  final DebugOnlyAdapterBridgeDesignValidationResult? bridgeValidationResult;
  final DebugOnlyBridgePrototypeDesign prototypeDesign;
  final DebugBridgeReadinessValidationGate gate;
  final DebugBridgeReadinessSummaryValidation validation;
  final DebugBridgeReadinessSummary summary;
  final DebugBridgeDesignReadinessGate readinessGate;
  final DebugOnlyAdapterBridgeDesignValidation bridgeValidation;
  final DebugOnlyAdapterBridgeDesign adapterBridgeDesign;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class DebugOnlyBridgePrototypeDesignValidationCheck {
  const DebugOnlyBridgePrototypeDesignValidationCheck({
    required this.checkId,
    required this.checkStatus,
    required this.severity,
    required this.relatedDesignSectionIds,
    required this.relatedDesignRecordIds,
    required this.relatedFieldIds,
    required this.relatedProofIds,
    required this.warningReason,
    required this.failureReason,
    required this.recommendation,
  });

  final String checkId;
  final DebugOnlyBridgePrototypeDesignValidationCheckStatus checkStatus;
  final DebugOnlyBridgePrototypeDesignValidationSeverity severity;
  final List<DebugOnlyBridgePrototypeDesignSectionId> relatedDesignSectionIds;
  final List<String> relatedDesignRecordIds;
  final List<String> relatedFieldIds;
  final List<String> relatedProofIds;
  final String warningReason;
  final String failureReason;
  final DebugOnlyBridgePrototypeDesignValidationRecommendation recommendation;

  bool get isBlocking =>
      checkStatus.isBlocked || severity.blocksStrict || severity.isCritical;

  bool get isCritical => severity.isCritical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'checkId': checkId,
      'checkStatus': checkStatus.wire,
      'severity': severity.wire,
      'relatedDesignSectionIds': relatedDesignSectionIds
          .map((id) => id.wire)
          .toList(),
      'relatedDesignRecordIds': relatedDesignRecordIds,
      'relatedFieldIds': relatedFieldIds,
      'relatedProofIds': relatedProofIds,
      'warningReason': warningReason,
      'failureReason': failureReason,
      'recommendation': recommendation.wire,
    };
  }
}

class DebugOnlyBridgePrototypeDesignSectionValidationRow {
  const DebugOnlyBridgePrototypeDesignSectionValidationRow({
    required this.validationRowId,
    required this.sourceDesignSectionId,
    required this.sectionKind,
    required this.validationStatus,
    required this.designRecordIds,
    required this.allowedFieldIds,
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
  final DebugOnlyBridgePrototypeDesignSectionId sourceDesignSectionId;
  final DebugOnlyBridgePrototypeDesignSectionValidationKind sectionKind;
  final DebugOnlyBridgePrototypeDesignSectionValidationStatus validationStatus;
  final List<String> designRecordIds;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final int ownerProofQueueCount;
  final String validationReason;
  final String warningReason;
  final List<String> violationReasons;
  final bool safeForNextPhase;
  final DebugOnlyBridgePrototypeDesignValidationRecommendation recommendation;

  bool get hasUnsafeOutput =>
      validationStatus.isUnsafe ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId);

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'validationRowId': validationRowId,
      'sourceDesignSectionId': sourceDesignSectionId.wire,
      'sectionKind': sectionKind.wire,
      'validationStatus': validationStatus.wire,
      'designRecordIds': designRecordIds,
      'allowedFieldIds': allowedFieldIds,
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

class DebugOnlyBridgePrototypeDesignRecordValidationRow {
  const DebugOnlyBridgePrototypeDesignRecordValidationRow({
    required this.validationRowId,
    required this.sourceDesignRecordId,
    required this.designRole,
    required this.designStatus,
    required this.validationStatus,
    required this.designOnly,
    required this.allowedForFuturePrototypeImplementation,
    required this.contextOnly,
    required this.inactive,
    required this.allowedFieldIds,
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
  final String sourceDesignRecordId;
  final DebugOnlyBridgePrototypeDesignRole designRole;
  final DebugOnlyBridgePrototypeDesignRecordStatus designStatus;
  final DebugOnlyBridgePrototypeDesignRecordValidationStatus validationStatus;
  final bool designOnly;
  final bool allowedForFuturePrototypeImplementation;
  final bool contextOnly;
  final bool inactive;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final Map<String, bool> safetyFlags;
  final List<String> violationReasons;
  final bool safeForNextPhase;
  final DebugOnlyBridgePrototypeDesignValidationRecommendation recommendation;

  bool get hasUnsafeOutput =>
      validationStatus.isUnsafe ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId) ||
      safetyFlags.values.any((value) => value);

  DebugOnlyBridgePrototypeDesignRecordValidationRow copyWith({
    String? validationRowId,
    String? sourceDesignRecordId,
    DebugOnlyBridgePrototypeDesignRole? designRole,
    DebugOnlyBridgePrototypeDesignRecordStatus? designStatus,
    DebugOnlyBridgePrototypeDesignRecordValidationStatus? validationStatus,
    bool? designOnly,
    bool? allowedForFuturePrototypeImplementation,
    bool? contextOnly,
    bool? inactive,
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    Map<String, bool>? safetyFlags,
    List<String>? violationReasons,
    bool? safeForNextPhase,
    DebugOnlyBridgePrototypeDesignValidationRecommendation? recommendation,
  }) {
    return DebugOnlyBridgePrototypeDesignRecordValidationRow(
      validationRowId: validationRowId ?? this.validationRowId,
      sourceDesignRecordId: sourceDesignRecordId ?? this.sourceDesignRecordId,
      designRole: designRole ?? this.designRole,
      designStatus: designStatus ?? this.designStatus,
      validationStatus: validationStatus ?? this.validationStatus,
      designOnly: designOnly ?? this.designOnly,
      allowedForFuturePrototypeImplementation:
          allowedForFuturePrototypeImplementation ??
          this.allowedForFuturePrototypeImplementation,
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
      safeForNextPhase: safeForNextPhase ?? this.safeForNextPhase,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'validationRowId': validationRowId,
      'sourceDesignRecordId': sourceDesignRecordId,
      'designRole': designRole.wire,
      'designStatus': designStatus.wire,
      'validationStatus': validationStatus.wire,
      'designOnly': designOnly,
      'allowedForFuturePrototypeImplementation':
          allowedForFuturePrototypeImplementation,
      'contextOnly': contextOnly,
      'inactive': inactive,
      'allowedFieldIds': allowedFieldIds,
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

class DebugOnlyBridgePrototypeDesignValidationFinding {
  const DebugOnlyBridgePrototypeDesignValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.validationRowId,
    this.designRecordId,
    this.designSectionId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final DebugOnlyBridgePrototypeDesignValidationSeverity severity;
  final String message;
  final String? validationRowId;
  final String? designRecordId;
  final DebugOnlyBridgePrototypeDesignSectionId? designSectionId;
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
      if (designRecordId != null) 'designRecordId': designRecordId,
      if (designSectionId != null) 'designSectionId': designSectionId!.wire,
      if (fieldId != null) 'fieldId': fieldId,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class DebugOnlyBridgePrototypeDesignValidationResult {
  const DebugOnlyBridgePrototypeDesignValidationResult({
    required this.validationStatus,
    required this.sourceDesignStatus,
    required this.sourceGateStatus,
    required this.sourceSummaryValidationStatus,
    required this.validationChecks,
    required this.sectionRows,
    required this.recordRows,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalChecks,
    required this.passedCheckCount,
    required this.warningCheckCount,
    required this.blockerCount,
    required this.criticalCount,
    required this.totalSectionRows,
    required this.totalRecordRows,
    required this.validPrototypeCoreDesignCount,
    required this.validPrototypeContextDesignCount,
    required this.validInactiveBlockedDesignCount,
    required this.validInactiveFutureOnlyDesignCount,
    required this.validAllowedFieldDesignCount,
    required this.validDeniedFieldDesignCount,
    required this.validStockfishRawUciPvDumpDeniedCount,
    required this.validAndroidProofBoundaryCount,
    required this.validOwnerProofBoundaryCount,
    required this.validFutureValidationRequirementCount,
    required this.invalidRecordCount,
    required this.unsafeRecordCount,
    required this.ownerProofQueueCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.safeForPhase33B,
    required this.phase33BRecommendation,
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

  final DebugOnlyBridgePrototypeDesignValidationStatus validationStatus;
  final DebugOnlyBridgePrototypeDesignStatus sourceDesignStatus;
  final DebugBridgeReadinessValidationGateStatus sourceGateStatus;
  final DebugBridgeReadinessSummaryValidationStatus
  sourceSummaryValidationStatus;
  final List<DebugOnlyBridgePrototypeDesignValidationCheck> validationChecks;
  final List<DebugOnlyBridgePrototypeDesignSectionValidationRow> sectionRows;
  final List<DebugOnlyBridgePrototypeDesignRecordValidationRow> recordRows;
  final List<DebugOnlyBridgePrototypeDesignValidationFinding>
  validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalChecks;
  final int passedCheckCount;
  final int warningCheckCount;
  final int blockerCount;
  final int criticalCount;
  final int totalSectionRows;
  final int totalRecordRows;
  final int validPrototypeCoreDesignCount;
  final int validPrototypeContextDesignCount;
  final int validInactiveBlockedDesignCount;
  final int validInactiveFutureOnlyDesignCount;
  final int validAllowedFieldDesignCount;
  final int validDeniedFieldDesignCount;
  final int validStockfishRawUciPvDumpDeniedCount;
  final int validAndroidProofBoundaryCount;
  final int validOwnerProofBoundaryCount;
  final int validFutureValidationRequirementCount;
  final int invalidRecordCount;
  final int unsafeRecordCount;
  final int ownerProofQueueCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final bool safeForPhase33B;
  final DebugOnlyBridgePrototypeDesignValidationPhase33BRecommendation
  phase33BRecommendation;
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
      validationStatus ==
          DebugOnlyBridgePrototypeDesignValidationStatus
              .blockedByUnsafePrototypeDesign ||
      validationStatus ==
          DebugOnlyBridgePrototypeDesignValidationStatus
              .blockedByPrototypeDesignMismatch ||
      validationStatus ==
          DebugOnlyBridgePrototypeDesignValidationStatus
              .blockedByPolicyBoundary ||
      validationStatus ==
          DebugOnlyBridgePrototypeDesignValidationStatus.invalid ||
      !safeForPhase33B ||
      unsafeRecordCount > 0 ||
      criticalCount > 0 ||
      blockerCount > 0 ||
      validationChecks.any((check) => check.isBlocking) ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeDebugOnlyBridgePrototypeDesignValidationPolicyViolation =>
      validationStatus ==
          DebugOnlyBridgePrototypeDesignValidationStatus
              .blockedByUnsafePrototypeDesign ||
      validationStatus ==
          DebugOnlyBridgePrototypeDesignValidationStatus
              .blockedByPolicyBoundary ||
      unsafeRecordCount > 0 ||
      criticalCount > 0 ||
      sectionRows.any((row) => row.hasUnsafeOutput) ||
      recordRows.any((row) => row.hasUnsafeOutput) ||
      validationChecks.any((check) => check.isCritical) ||
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

  DebugOnlyBridgePrototypeDesignValidationCheck check(String checkId) {
    return validationChecks.singleWhere((check) => check.checkId == checkId);
  }

  DebugOnlyBridgePrototypeDesignSectionValidationRow sectionRowForSection(
    DebugOnlyBridgePrototypeDesignSectionId sectionId,
  ) {
    return sectionRows.singleWhere(
      (row) => row.sourceDesignSectionId == sectionId,
    );
  }

  DebugOnlyBridgePrototypeDesignRecordValidationRow recordRowForRole(
    DebugOnlyBridgePrototypeDesignRole role,
  ) {
    return recordRows.singleWhere((row) => row.designRole == role);
  }

  DebugOnlyBridgePrototypeDesignValidationResult copyWith({
    DebugOnlyBridgePrototypeDesignValidationStatus? validationStatus,
    DebugOnlyBridgePrototypeDesignStatus? sourceDesignStatus,
    DebugBridgeReadinessValidationGateStatus? sourceGateStatus,
    DebugBridgeReadinessSummaryValidationStatus? sourceSummaryValidationStatus,
    List<DebugOnlyBridgePrototypeDesignValidationCheck>? validationChecks,
    List<DebugOnlyBridgePrototypeDesignSectionValidationRow>? sectionRows,
    List<DebugOnlyBridgePrototypeDesignRecordValidationRow>? recordRows,
    List<DebugOnlyBridgePrototypeDesignValidationFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalChecks,
    int? passedCheckCount,
    int? warningCheckCount,
    int? blockerCount,
    int? criticalCount,
    int? totalSectionRows,
    int? totalRecordRows,
    int? validPrototypeCoreDesignCount,
    int? validPrototypeContextDesignCount,
    int? validInactiveBlockedDesignCount,
    int? validInactiveFutureOnlyDesignCount,
    int? validAllowedFieldDesignCount,
    int? validDeniedFieldDesignCount,
    int? validStockfishRawUciPvDumpDeniedCount,
    int? validAndroidProofBoundaryCount,
    int? validOwnerProofBoundaryCount,
    int? validFutureValidationRequirementCount,
    int? invalidRecordCount,
    int? unsafeRecordCount,
    int? ownerProofQueueCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    bool? safeForPhase33B,
    DebugOnlyBridgePrototypeDesignValidationPhase33BRecommendation?
    phase33BRecommendation,
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
    return DebugOnlyBridgePrototypeDesignValidationResult(
      validationStatus: validationStatus ?? this.validationStatus,
      sourceDesignStatus: sourceDesignStatus ?? this.sourceDesignStatus,
      sourceGateStatus: sourceGateStatus ?? this.sourceGateStatus,
      sourceSummaryValidationStatus:
          sourceSummaryValidationStatus ?? this.sourceSummaryValidationStatus,
      validationChecks: validationChecks ?? this.validationChecks,
      sectionRows: sectionRows ?? this.sectionRows,
      recordRows: recordRows ?? this.recordRows,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalChecks: totalChecks ?? this.totalChecks,
      passedCheckCount: passedCheckCount ?? this.passedCheckCount,
      warningCheckCount: warningCheckCount ?? this.warningCheckCount,
      blockerCount: blockerCount ?? this.blockerCount,
      criticalCount: criticalCount ?? this.criticalCount,
      totalSectionRows: totalSectionRows ?? this.totalSectionRows,
      totalRecordRows: totalRecordRows ?? this.totalRecordRows,
      validPrototypeCoreDesignCount:
          validPrototypeCoreDesignCount ?? this.validPrototypeCoreDesignCount,
      validPrototypeContextDesignCount:
          validPrototypeContextDesignCount ??
          this.validPrototypeContextDesignCount,
      validInactiveBlockedDesignCount:
          validInactiveBlockedDesignCount ??
          this.validInactiveBlockedDesignCount,
      validInactiveFutureOnlyDesignCount:
          validInactiveFutureOnlyDesignCount ??
          this.validInactiveFutureOnlyDesignCount,
      validAllowedFieldDesignCount:
          validAllowedFieldDesignCount ?? this.validAllowedFieldDesignCount,
      validDeniedFieldDesignCount:
          validDeniedFieldDesignCount ?? this.validDeniedFieldDesignCount,
      validStockfishRawUciPvDumpDeniedCount:
          validStockfishRawUciPvDumpDeniedCount ??
          this.validStockfishRawUciPvDumpDeniedCount,
      validAndroidProofBoundaryCount:
          validAndroidProofBoundaryCount ?? this.validAndroidProofBoundaryCount,
      validOwnerProofBoundaryCount:
          validOwnerProofBoundaryCount ?? this.validOwnerProofBoundaryCount,
      validFutureValidationRequirementCount:
          validFutureValidationRequirementCount ??
          this.validFutureValidationRequirementCount,
      invalidRecordCount: invalidRecordCount ?? this.invalidRecordCount,
      unsafeRecordCount: unsafeRecordCount ?? this.unsafeRecordCount,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      allowedFieldIds: allowedFieldIds ?? this.allowedFieldIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      safeForPhase33B: safeForPhase33B ?? this.safeForPhase33B,
      phase33BRecommendation:
          phase33BRecommendation ?? this.phase33BRecommendation,
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
      ..writeln('# Debug-Only Bridge Prototype Design Validation')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgePrototypeDesignValidationReportVersion',
      )
      ..writeln('- validation status: ${validationStatus.wire}')
      ..writeln('- source design status: ${sourceDesignStatus.wire}')
      ..writeln('- source gate status: ${sourceGateStatus.wire}')
      ..writeln('- total checks: $totalChecks')
      ..writeln('- passed check count: $passedCheckCount')
      ..writeln('- warning check count: $warningCheckCount')
      ..writeln('- total section rows: $totalSectionRows')
      ..writeln('- total record rows: $totalRecordRows')
      ..writeln('- unsafe record count: $unsafeRecordCount')
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
      ..writeln('- safeForPhase33B: $safeForPhase33B')
      ..writeln('- Phase 33B recommendation: ${phase33BRecommendation.wire}')
      ..writeln()
      ..writeln('## Validation Check Table')
      ..writeln(
        '| Check | Status | Severity | Fields | Proof IDs | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- |');
    for (final check in validationChecks) {
      buffer.writeln(
        '| ${check.checkId} | ${check.checkStatus.wire} | '
        '${check.severity.wire} | ${_ids(check.relatedFieldIds)} | '
        '${_ids(check.relatedProofIds)} | ${check.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Design Section Validation Table')
      ..writeln(
        '| Section | Kind | Status | Allowed fields | Denied fields | Safe | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
    for (final row in sectionRows) {
      buffer.writeln(
        '| ${row.sourceDesignSectionId.wire} | ${row.sectionKind.wire} | '
        '${row.validationStatus.wire} | ${_ids(row.allowedFieldIds)} | '
        '${_ids(row.deniedFieldIds)} | ${row.safeForNextPhase} | '
        '${row.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Design Record Validation Table')
      ..writeln(
        '| Record | Role | Status | Allowed fields | Denied fields | Design-only | Safe | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- |');
    for (final row in recordRows) {
      buffer.writeln(
        '| ${_cell(row.sourceDesignRecordId)} | ${row.designRole.wire} | '
        '${row.validationStatus.wire} | ${_ids(row.allowedFieldIds)} | '
        '${_ids(row.deniedFieldIds)} | ${row.designOnly} | '
        '${row.safeForNextPhase} | ${row.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Prototype Core Design Validation')
      ..writeln(
        '- valid prototype core design rows: $validPrototypeCoreDesignCount',
      )
      ..writeln()
      ..writeln('## Prototype Context Design Validation')
      ..writeln(
        '- valid prototype context design rows: $validPrototypeContextDesignCount',
      )
      ..writeln()
      ..writeln('## Inactive Blocked/Future Validation')
      ..writeln(
        '- valid inactive blocked design rows: $validInactiveBlockedDesignCount',
      )
      ..writeln(
        '- valid inactive future-only design rows: $validInactiveFutureOnlyDesignCount',
      )
      ..writeln()
      ..writeln('## Allowed And Denied Field Validation')
      ..writeln('- allowed fields: ${_ids(allowedFieldIds)}')
      ..writeln('- denied fields: ${_ids(deniedFieldIds)}')
      ..writeln()
      ..writeln('## Stockfish Raw UCI PV Dump Denied Validation')
      ..writeln(
        '- stockfishCommand denied: ${deniedFieldIds.contains('stockfishCommand')}',
      )
      ..writeln('- rawUci denied: ${deniedFieldIds.contains('rawUci')}')
      ..writeln('- pvDump denied: ${deniedFieldIds.contains('pvDump')}')
      ..writeln()
      ..writeln('## Android Proof Boundary Validation')
      ..writeln('- android proof IDs: ${_ids(androidProofCaseIds)}')
      ..writeln()
      ..writeln('## Owner Proof Boundary Validation')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Phase 33A Validation Requirement')
      ..writeln(
        '- Phase 33A validation requirement satisfied: ${validFutureValidationRequirementCount == 1}',
      )
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
      ..writeln('## Phase 33B Recommendation')
      ..writeln('- ${phase33BRecommendation.wire}');
    return buffer.toString();
  }

  String renderJsonReport() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': debugOnlyBridgePrototypeDesignValidationReportVersion,
      'validationStatus': validationStatus.wire,
      'sourceDesignStatus': sourceDesignStatus.wire,
      'sourceGateStatus': sourceGateStatus.wire,
      'sourceSummaryValidationStatus': sourceSummaryValidationStatus.wire,
      'totalChecks': totalChecks,
      'passedCheckCount': passedCheckCount,
      'warningCheckCount': warningCheckCount,
      'blockerCount': blockerCount,
      'criticalCount': criticalCount,
      'totalSectionRows': totalSectionRows,
      'totalRecordRows': totalRecordRows,
      'validPrototypeCoreDesignCount': validPrototypeCoreDesignCount,
      'validPrototypeContextDesignCount': validPrototypeContextDesignCount,
      'validInactiveBlockedDesignCount': validInactiveBlockedDesignCount,
      'validInactiveFutureOnlyDesignCount': validInactiveFutureOnlyDesignCount,
      'validAllowedFieldDesignCount': validAllowedFieldDesignCount,
      'validDeniedFieldDesignCount': validDeniedFieldDesignCount,
      'validStockfishRawUciPvDumpDeniedCount':
          validStockfishRawUciPvDumpDeniedCount,
      'validAndroidProofBoundaryCount': validAndroidProofBoundaryCount,
      'validOwnerProofBoundaryCount': validOwnerProofBoundaryCount,
      'validFutureValidationRequirementCount':
          validFutureValidationRequirementCount,
      'invalidRecordCount': invalidRecordCount,
      'unsafeRecordCount': unsafeRecordCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'allowedFieldIds': allowedFieldIds,
      'deniedFieldIds': deniedFieldIds,
      'safeForPhase33B': safeForPhase33B,
      'phase33BRecommendation': phase33BRecommendation.wire,
      'validationChecks': validationChecks
          .map((check) => check.toJson())
          .toList(),
      'sectionRows': sectionRows.map((row) => row.toJson()).toList(),
      'recordRows': recordRows.map((row) => row.toJson()).toList(),
      'findings': validationFindings
          .map((finding) => finding.toJson())
          .toList(),
      'warnings': warnings,
      'failures': failures,
      'developerOnly': developerOnly,
      'debugBridgeRuntimeImplemented': debugBridgeRuntimeImplemented,
      'executableDebugBridgePrototypeImplemented':
          executableDebugBridgePrototypeImplemented,
      'phase33AValidationRequirementSatisfied':
          validFutureValidationRequirementCount == 1,
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

class DebugOnlyBridgePrototypeDesignValidation {
  const DebugOnlyBridgePrototypeDesignValidation({
    this.validator = const DebugOnlyBridgePrototypeDesignValidationValidator(),
  });

  final DebugOnlyBridgePrototypeDesignValidationValidator validator;

  DebugOnlyBridgePrototypeDesignValidationResult evaluate([
    DebugOnlyBridgePrototypeDesignValidationRequest request =
        const DebugOnlyBridgePrototypeDesignValidationRequest(),
  ]) {
    final gateResult =
        request.gateResult ??
        request.gate.evaluate(
          DebugBridgeReadinessValidationGateRequest(
            validationResult: request.validationResult,
            summaryResult: request.summaryResult,
            readinessGateResult: request.readinessGateResult,
            bridgeValidationResult: request.bridgeValidationResult,
            validation: request.validation,
            summary: request.summary,
            readinessGate: request.readinessGate,
            bridgeValidation: request.bridgeValidation,
            design: request.adapterBridgeDesign,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final designResult =
        request.designResult ??
        request.prototypeDesign.evaluate(
          DebugOnlyBridgePrototypeDesignRequest(
            gateResult: gateResult,
            validationResult: request.validationResult,
            summaryResult: request.summaryResult,
            readinessGateResult: request.readinessGateResult,
            bridgeValidationResult: request.bridgeValidationResult,
            gate: request.gate,
            validation: request.validation,
            summary: request.summary,
            readinessGate: request.readinessGate,
            bridgeValidation: request.bridgeValidation,
            design: request.adapterBridgeDesign,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final checks = _checksFromDesign(
      designResult: designResult,
      gateResult: gateResult,
    );
    final sectionRows = _sectionRowsFromDesign(designResult);
    final recordRows = _recordRowsFromDesign(designResult);
    final base = _resultFromRows(
      designResult: designResult,
      gateResult: gateResult,
      checks: checks,
      sectionRows: sectionRows,
      recordRows: recordRows,
      validationFindings:
          const <DebugOnlyBridgePrototypeDesignValidationFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromRows(
      designResult: designResult,
      gateResult: gateResult,
      checks: checks,
      sectionRows: sectionRows,
      recordRows: recordRows,
      validationFindings: findings,
    );
  }
}

class DebugOnlyBridgePrototypeDesignValidationValidator {
  const DebugOnlyBridgePrototypeDesignValidationValidator();

  List<DebugOnlyBridgePrototypeDesignValidationFinding> validate(
    DebugOnlyBridgePrototypeDesignValidationResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <DebugOnlyBridgePrototypeDesignValidationFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required DebugOnlyBridgePrototypeDesignValidationSeverity severity,
      required String message,
      String? validationRowId,
      String? designRecordId,
      DebugOnlyBridgePrototypeDesignSectionId? designSectionId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        DebugOnlyBridgePrototypeDesignValidationFinding(
          id: id,
          severity: severity,
          message: message,
          validationRowId: validationRowId,
          designRecordId: designRecordId,
          designSectionId: designSectionId,
          fieldId: fieldId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase33B &&
        (result.sourceDesignStatus ==
                DebugOnlyBridgePrototypeDesignStatus.blockedByReadinessGate ||
            result.sourceDesignStatus ==
                DebugOnlyBridgePrototypeDesignStatus.blockedByPolicyBoundary ||
            result.unsafeRecordCount > 0)) {
      add(
        id: 'unsafePrototypeDesignMarkedValidated',
        severity: DebugOnlyBridgePrototypeDesignValidationSeverity.critical,
        message: 'unsafe prototype design cannot be marked validated',
      );
    }
    if (result.validFutureValidationRequirementCount != 1) {
      add(
        id: 'missingPhase33AValidationRequirement',
        severity: DebugOnlyBridgePrototypeDesignValidationSeverity.critical,
        message:
            'Phase 33A validation requirement must be present in design validation',
      );
    }
    for (final fieldId in _deniedFieldIds) {
      if (!result.deniedFieldIds.contains(fieldId)) {
        add(
          id: 'deniedFieldMissing',
          severity: DebugOnlyBridgePrototypeDesignValidationSeverity.blocker,
          message: '$fieldId must remain denied in prototype design validation',
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
    for (final section in result.sectionRows) {
      for (final fieldId in section.allowedFieldIds) {
        _checkActiveAllowedField(
          add,
          fieldId,
          validationRowId: section.validationRowId,
          designSectionId: section.sourceDesignSectionId,
        );
      }
      for (final proofId in section.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          proofId,
          provenAndroidIds,
          validationRowId: section.validationRowId,
          designSectionId: section.sourceDesignSectionId,
        );
      }
    }
    for (final row in result.recordRows) {
      for (final fieldId in row.allowedFieldIds) {
        _checkActiveAllowedField(
          add,
          fieldId,
          validationRowId: row.validationRowId,
          designRecordId: row.sourceDesignRecordId,
        );
      }
      for (final proofId in row.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          proofId,
          provenAndroidIds,
          validationRowId: row.validationRowId,
          designRecordId: row.sourceDesignRecordId,
        );
      }
      _checkRecordBoundary(add, row);
      _checkSafetyFlags(add, row);
    }
    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: DebugOnlyBridgePrototypeDesignValidationSeverity.blocker,
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
        id: 'debugOnlyBridgePrototypeDesignValidationBoundaryPolicyViolation',
        severity: DebugOnlyBridgePrototypeDesignValidationSeverity.critical,
        message:
            'debug-only bridge prototype design validation crossed a blocked boundary',
      );
    }
    return findings..sort(_compareFindings);
  }

  List<DebugOnlyBridgePrototypeDesignValidationFinding> validateReportText(
    String reportText,
  ) {
    final findings = <DebugOnlyBridgePrototypeDesignValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        DebugOnlyBridgePrototypeDesignValidationFinding(
          id: id,
          severity: DebugOnlyBridgePrototypeDesignValidationSeverity.critical,
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

List<DebugOnlyBridgePrototypeDesignValidationCheck> _checksFromDesign({
  required DebugOnlyBridgePrototypeDesignResult designResult,
  required DebugBridgeReadinessValidationGateResult gateResult,
}) {
  DebugOnlyBridgePrototypeDesignValidationCheck check(
    String id,
    bool passed, {
    bool warning = false,
    Iterable<DebugOnlyBridgePrototypeDesignSectionId> sections = const [],
    Iterable<String> records = const [],
    Iterable<String> fields = const [],
    Iterable<String> proofs = const [],
    String warningReason = '',
    String failureReason = '',
    DebugOnlyBridgePrototypeDesignValidationRecommendation recommendation =
        DebugOnlyBridgePrototypeDesignValidationRecommendation
            .keepPolicyBoundariesBlocked,
  }) {
    return DebugOnlyBridgePrototypeDesignValidationCheck(
      checkId: id,
      checkStatus: passed
          ? warning
                ? DebugOnlyBridgePrototypeDesignValidationCheckStatus
                      .passedWithWarnings
                : DebugOnlyBridgePrototypeDesignValidationCheckStatus.passed
          : DebugOnlyBridgePrototypeDesignValidationCheckStatus.failed,
      severity: passed
          ? warning
                ? DebugOnlyBridgePrototypeDesignValidationSeverity.warning
                : DebugOnlyBridgePrototypeDesignValidationSeverity.none
          : DebugOnlyBridgePrototypeDesignValidationSeverity.blocker,
      relatedDesignSectionIds: sections.toList(growable: false),
      relatedDesignRecordIds: _sortedStrings(records),
      relatedFieldIds: _sortedStrings(fields),
      relatedProofIds: _sortedStrings(proofs),
      warningReason: warningReason,
      failureReason: passed ? '' : failureReason,
      recommendation: recommendation,
    );
  }

  final sectionIds = designResult.designSections
      .map((section) => section.sectionId)
      .toSet();
  final recordIds = designResult.designRecords
      .map((record) => record.prototypeDesignRecordId)
      .toList(growable: false);
  return <DebugOnlyBridgePrototypeDesignValidationCheck>[
    check(
      'prototypeDesignConsumesReadinessGate',
      designResult.sourceGateStatus == gateResult.gateStatus &&
          designResult.safeForPhase33A == gateResult.safeForPhase32Z,
      records: recordIds,
      failureReason: 'prototype design does not reflect Phase 32Y gate',
      recommendation: DebugOnlyBridgePrototypeDesignValidationRecommendation
          .investigatePrototypeDesignMismatch,
    ),
    check(
      'prototypeCoreDesignUsesOnlyPrototypeReadyCore',
      sectionIds.contains(
            DebugOnlyBridgePrototypeDesignSectionId.prototypeCoreInputDesign,
          ) &&
          designResult.prototypeCoreDesignCount == 1,
      sections: const <DebugOnlyBridgePrototypeDesignSectionId>[
        DebugOnlyBridgePrototypeDesignSectionId.prototypeCoreInputDesign,
      ],
      recommendation: DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepPrototypeCoreDesignValidated,
    ),
    check(
      'prototypeContextDesignStaysContextOnly',
      sectionIds.contains(
            DebugOnlyBridgePrototypeDesignSectionId.prototypeContextInputDesign,
          ) &&
          designResult.prototypeContextDesignCount == 1 &&
          designResult
              .recordForRole(
                DebugOnlyBridgePrototypeDesignRole
                    .prototypeContextInputDesignRecord,
              )
              .contextOnly,
      warning: true,
      sections: const <DebugOnlyBridgePrototypeDesignSectionId>[
        DebugOnlyBridgePrototypeDesignSectionId.prototypeContextInputDesign,
      ],
      warningReason: 'prototype context design remains context-only',
      recommendation: DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepPrototypeContextDesignValidated,
    ),
    check(
      'inactiveBlockedDesignStaysInactive',
      sectionIds.contains(
            DebugOnlyBridgePrototypeDesignSectionId
                .prototypeInactiveBlockedInputDesign,
          ) &&
          designResult.inactiveBlockedDesignCount == 1,
      warning: true,
      sections: const <DebugOnlyBridgePrototypeDesignSectionId>[
        DebugOnlyBridgePrototypeDesignSectionId
            .prototypeInactiveBlockedInputDesign,
      ],
      warningReason: 'blocked prototype input design remains inactive',
      recommendation: DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepBlockedDesignInactive,
    ),
    check(
      'inactiveFutureOnlyDesignStaysInactive',
      sectionIds.contains(
            DebugOnlyBridgePrototypeDesignSectionId
                .prototypeInactiveFutureOnlyInputDesign,
          ) &&
          designResult.inactiveFutureOnlyDesignCount == 1,
      warning: true,
      sections: const <DebugOnlyBridgePrototypeDesignSectionId>[
        DebugOnlyBridgePrototypeDesignSectionId
            .prototypeInactiveFutureOnlyInputDesign,
      ],
      warningReason: 'future-only prototype input design remains inactive',
      recommendation: DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepFutureDesignInactive,
    ),
    check(
      'allowedFieldsAreInternalDebugSafe',
      designResult.allowedFieldIds.every(
        (field) => !_isDeniedFieldId(field) && !_isLegacyDeniedFieldId(field),
      ),
      fields: designResult.allowedFieldIds,
      recommendation: DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepAllowedFieldsValidated,
    ),
    check(
      'deniedFieldsRemainDenied',
      _deniedFieldIds.every(designResult.deniedFieldIds.contains),
      fields: designResult.deniedFieldIds,
      recommendation: DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepDeniedFieldsDenied,
    ),
    check(
      'stockfishCommandRawUciPvDumpRemainDenied',
      _engineDumpFieldIds.every(designResult.deniedFieldIds.contains),
      fields: _engineDumpFieldIds,
      recommendation: DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepStockfishRawUciPvDumpDenied,
    ),
    check(
      'androidProofIdsAreCapturedOnly',
      _sameStringSet(
        designResult.androidProofCaseIds,
        _capturedAndroidProofIds,
      ),
      warning: true,
      proofs: designResult.androidProofCaseIds,
      warningReason: 'Android proof remains limited to captured device proof',
      recommendation: DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepAndroidProofBoundaryCapturedOnly,
    ),
    check(
      'phase32ECasesAreNotCapturedProof',
      designResult.androidProofCaseIds.every(
        (caseId) => !_phase32ECaseIds.contains(caseId),
      ),
      proofs: designResult.androidProofCaseIds,
      recommendation: DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepAndroidProofBoundaryCapturedOnly,
    ),
    check(
      'ownerProofQueueRemainsEmpty',
      designResult.ownerProofQueueCount == 0,
      recommendation: DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepOwnerProofEmpty,
    ),
    check(
      'futurePhase33AValidationRequirementPresent',
      designResult.futureValidationRequirementCount == 1 &&
          designResult
              .recordForRole(
                DebugOnlyBridgePrototypeDesignRole
                    .futureValidationRequirementRecord,
              )
              .futurePrerequisites
              .contains('validateDebugOnlyBridgePrototypeDesign'),
      recommendation: DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepPhase33AValidationRequirementSatisfied,
    ),
    check(
      'noRuntimeOrExecutablePrototypeImplemented',
      !designResult.debugBridgeRuntimeImplemented &&
          !designResult.executableDebugBridgePrototypeImplemented &&
          designResult.designRecords.every(
            (record) =>
                record.safetyFlags['implementsRuntime'] != true &&
                record.safetyFlags['implementsPrototypeExecution'] != true,
          ),
      recommendation: DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepPolicyBoundariesBlocked,
    ),
    check(
      'noLabelsScoresRankingsMetrics',
      _noPolicyFlagActive(designResult, const <String>[
        'classifierOutputActive',
        'finalMoveLabelOutputActive',
        'numericOutputActive',
        'aggregateScoreOutputActive',
        'moveRankingOutputActive',
        'officialMetricOutputActive',
        'cpLossOutputActive',
        'winProbabilityOutputActive',
      ]),
      recommendation: DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepPolicyBoundariesBlocked,
    ),
    check(
      'noUiBackendPersistenceEngineFields',
      _noPolicyFlagActive(designResult, const <String>[
        'uiTargetsActive',
        'backendOutputActive',
        'persistenceWritesActive',
        'engineCallsActive',
        'stockfishCommandFieldActive',
        'rawUciFieldActive',
        'pvDumpFieldActive',
      ]),
      recommendation: DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepPolicyBoundariesBlocked,
    ),
    check(
      'quietScopeRemainsExcluded',
      _noPolicyFlagActive(designResult, const <String>[
        'quietPreparatoryScopeActivated',
      ]),
      recommendation: DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepPolicyBoundariesBlocked,
    ),
    check(
      'productBoundariesRemainBlocked',
      _noPolicyFlagActive(designResult, const <String>[
        'productOutputActive',
        'runtimeImplementationActive',
        'executablePrototypeImplementationActive',
      ]),
      recommendation: DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepPolicyBoundariesBlocked,
    ),
  ];
}

List<DebugOnlyBridgePrototypeDesignSectionValidationRow> _sectionRowsFromDesign(
  DebugOnlyBridgePrototypeDesignResult designResult,
) {
  DebugOnlyBridgePrototypeDesignSectionValidationRow row(
    DebugOnlyBridgePrototypeDesignSectionId sectionId,
    DebugOnlyBridgePrototypeDesignSectionValidationKind kind,
    DebugOnlyBridgePrototypeDesignSectionValidationStatus validStatus,
    DebugOnlyBridgePrototypeDesignValidationRecommendation recommendation,
    String validationReason, {
    String warningReason = '',
  }) {
    final section = designResult.section(sectionId);
    final records = _recordsForSection(designResult.designRecords, sectionId);
    final unsafe =
        section.designStatus.isUnsafe ||
        section.allowedFieldIds.any(_isDeniedFieldId) ||
        section.allowedFieldIds.any(_isLegacyDeniedFieldId) ||
        !section.designOnly;
    final invalid =
        !unsafe && (!section.safeForPhase33A || section.designStatus.isInvalid);
    final status = unsafe
        ? DebugOnlyBridgePrototypeDesignSectionValidationStatus
              .unsafeDesignSection
        : invalid
        ? DebugOnlyBridgePrototypeDesignSectionValidationStatus
              .invalidDesignSection
        : validStatus;
    return DebugOnlyBridgePrototypeDesignSectionValidationRow(
      validationRowId: 'prototype-design-section-validation-${sectionId.wire}',
      sourceDesignSectionId: sectionId,
      sectionKind: kind,
      validationStatus: status,
      designRecordIds: _sortedStrings(
        records.map((record) => record.prototypeDesignRecordId),
      ),
      allowedFieldIds: _sortedStrings(section.allowedFieldIds),
      deniedFieldIds: _sortedStrings(section.deniedFieldIds),
      supportCaseIds: _sortedStrings(section.supportCaseIds),
      newlyAddedSupportCaseIds: _sortedStrings(
        section.newlyAddedSupportCaseIds,
      ),
      androidProofCaseIds: _sortedStrings(section.androidProofCaseIds),
      ownerProofQueueCount:
          sectionId ==
              DebugOnlyBridgePrototypeDesignSectionId.ownerProofBoundaryDesign
          ? designResult.ownerProofQueueCount
          : 0,
      validationReason: validationReason,
      warningReason: warningReason,
      violationReasons: unsafe
          ? const <String>['unsafeDesignSection']
          : invalid
          ? const <String>['invalidDesignSection']
          : const <String>[],
      safeForNextPhase: !unsafe && !invalid,
      recommendation: unsafe
          ? DebugOnlyBridgePrototypeDesignValidationRecommendation
                .blockUnsafePrototypeDesignValidation
          : invalid
          ? DebugOnlyBridgePrototypeDesignValidationRecommendation
                .investigatePrototypeDesignMismatch
          : recommendation,
    );
  }

  return <DebugOnlyBridgePrototypeDesignSectionValidationRow>[
    row(
      DebugOnlyBridgePrototypeDesignSectionId.prototypeCoreInputDesign,
      DebugOnlyBridgePrototypeDesignSectionValidationKind
          .validPrototypeCoreInputDesign,
      DebugOnlyBridgePrototypeDesignSectionValidationStatus
          .validPrototypeCoreInputDesign,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepPrototypeCoreDesignValidated,
      'prototype core design consumes only Phase 32Y core readiness records',
    ),
    row(
      DebugOnlyBridgePrototypeDesignSectionId.prototypeContextInputDesign,
      DebugOnlyBridgePrototypeDesignSectionValidationKind
          .validPrototypeContextInputDesign,
      DebugOnlyBridgePrototypeDesignSectionValidationStatus
          .validPrototypeContextInputDesign,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepPrototypeContextDesignValidated,
      'prototype context design remains context-only',
      warningReason: 'context design remains constrained',
    ),
    row(
      DebugOnlyBridgePrototypeDesignSectionId
          .prototypeInactiveBlockedInputDesign,
      DebugOnlyBridgePrototypeDesignSectionValidationKind
          .validInactiveBlockedInputDesign,
      DebugOnlyBridgePrototypeDesignSectionValidationStatus
          .validInactiveBlockedInputDesign,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepBlockedDesignInactive,
      'blocked prototype input design remains inactive',
      warningReason: 'blocked design remains inactive',
    ),
    row(
      DebugOnlyBridgePrototypeDesignSectionId
          .prototypeInactiveFutureOnlyInputDesign,
      DebugOnlyBridgePrototypeDesignSectionValidationKind
          .validInactiveFutureOnlyInputDesign,
      DebugOnlyBridgePrototypeDesignSectionValidationStatus
          .validInactiveFutureOnlyInputDesign,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepFutureDesignInactive,
      'future-only prototype input design remains inactive',
      warningReason: 'future-only design remains inactive',
    ),
    row(
      DebugOnlyBridgePrototypeDesignSectionId.prototypeAllowedFieldDesign,
      DebugOnlyBridgePrototypeDesignSectionValidationKind
          .validAllowedFieldDesign,
      DebugOnlyBridgePrototypeDesignSectionValidationStatus
          .validAllowedFieldDesign,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepAllowedFieldsValidated,
      'allowed fields remain internal debug-safe',
    ),
    row(
      DebugOnlyBridgePrototypeDesignSectionId.prototypeDeniedFieldDesign,
      DebugOnlyBridgePrototypeDesignSectionValidationKind
          .validDeniedFieldDesign,
      DebugOnlyBridgePrototypeDesignSectionValidationStatus
          .validDeniedFieldDesign,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepDeniedFieldsDenied,
      'denied fields remain denied',
    ),
    row(
      DebugOnlyBridgePrototypeDesignSectionId.stockfishRawUciPvDumpDeniedDesign,
      DebugOnlyBridgePrototypeDesignSectionValidationKind
          .validStockfishRawUciPvDumpDeniedDesign,
      DebugOnlyBridgePrototypeDesignSectionValidationStatus
          .validStockfishRawUciPvDumpDeniedDesign,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepStockfishRawUciPvDumpDenied,
      'Stockfish command, raw UCI, and PV dump remain denied',
    ),
    row(
      DebugOnlyBridgePrototypeDesignSectionId.androidProofBoundaryDesign,
      DebugOnlyBridgePrototypeDesignSectionValidationKind
          .validAndroidProofBoundaryDesign,
      DebugOnlyBridgePrototypeDesignSectionValidationStatus
          .validAndroidProofBoundaryDesign,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepAndroidProofBoundaryCapturedOnly,
      'Android proof boundary remains captured-only',
    ),
    row(
      DebugOnlyBridgePrototypeDesignSectionId.ownerProofBoundaryDesign,
      DebugOnlyBridgePrototypeDesignSectionValidationKind
          .validOwnerProofBoundaryDesign,
      DebugOnlyBridgePrototypeDesignSectionValidationStatus
          .validOwnerProofBoundaryDesign,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepOwnerProofEmpty,
      'owner proof boundary remains empty',
    ),
    row(
      DebugOnlyBridgePrototypeDesignSectionId
          .futurePrototypeValidationRequirements,
      DebugOnlyBridgePrototypeDesignSectionValidationKind
          .validFuturePrototypeValidationRequirements,
      DebugOnlyBridgePrototypeDesignSectionValidationStatus
          .validFuturePrototypeValidationRequirements,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepPhase33AValidationRequirementSatisfied,
      'Phase 33A validation requirement is present and satisfied',
    ),
  ];
}

List<DebugOnlyBridgePrototypeDesignRecordValidationRow> _recordRowsFromDesign(
  DebugOnlyBridgePrototypeDesignResult designResult,
) {
  DebugOnlyBridgePrototypeDesignRecordValidationRow row(
    DebugOnlyBridgePrototypeDesignRole role,
    DebugOnlyBridgePrototypeDesignRecordValidationStatus validStatus,
    DebugOnlyBridgePrototypeDesignValidationRecommendation recommendation,
  ) {
    final record = designResult.recordForRole(role);
    final unsafe = record.hasUnsafeOutput || !record.designOnly;
    final invalid =
        !unsafe &&
        (record.designStatus.isInvalid || record.violationReasons.isNotEmpty);
    final status = unsafe
        ? DebugOnlyBridgePrototypeDesignRecordValidationStatus
              .unsafePrototypeDesignRecord
        : invalid
        ? DebugOnlyBridgePrototypeDesignRecordValidationStatus
              .invalidPrototypeDesignRecord
        : validStatus;
    return DebugOnlyBridgePrototypeDesignRecordValidationRow(
      validationRowId:
          'prototype-design-record-validation-${record.prototypeDesignRecordId}',
      sourceDesignRecordId: record.prototypeDesignRecordId,
      designRole: record.designRole,
      designStatus: record.designStatus,
      validationStatus: status,
      designOnly: record.designOnly,
      allowedForFuturePrototypeImplementation:
          record.allowedForFuturePrototypeImplementation,
      contextOnly: record.contextOnly,
      inactive: record.inactive,
      allowedFieldIds: _sortedStrings(record.allowedFieldIds),
      deniedFieldIds: _sortedStrings(record.deniedFieldIds),
      supportCaseIds: _sortedStrings(record.supportCaseIds),
      newlyAddedSupportCaseIds: _sortedStrings(record.newlyAddedSupportCaseIds),
      androidProofCaseIds: _sortedStrings(record.androidProofCaseIds),
      safetyFlags: _safeFlagsFrom(record.safetyFlags),
      violationReasons: _sortedStrings(record.violationReasons),
      safeForNextPhase: !unsafe && !invalid,
      recommendation: unsafe
          ? DebugOnlyBridgePrototypeDesignValidationRecommendation
                .blockUnsafePrototypeDesignValidation
          : invalid
          ? DebugOnlyBridgePrototypeDesignValidationRecommendation
                .investigatePrototypeDesignMismatch
          : recommendation,
    );
  }

  return <DebugOnlyBridgePrototypeDesignRecordValidationRow>[
    row(
      DebugOnlyBridgePrototypeDesignRole.prototypeCoreInputDesignRecord,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validPrototypeCoreDesignRecord,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepPrototypeCoreDesignValidated,
    ),
    row(
      DebugOnlyBridgePrototypeDesignRole.prototypeContextInputDesignRecord,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validPrototypeContextDesignRecord,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepPrototypeContextDesignValidated,
    ),
    row(
      DebugOnlyBridgePrototypeDesignRole
          .prototypeInactiveBlockedInputDesignRecord,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validInactiveBlockedDesignRecord,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepBlockedDesignInactive,
    ),
    row(
      DebugOnlyBridgePrototypeDesignRole
          .prototypeInactiveFutureOnlyInputDesignRecord,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validInactiveFutureOnlyDesignRecord,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepFutureDesignInactive,
    ),
    row(
      DebugOnlyBridgePrototypeDesignRole.prototypeAllowedFieldDesignRecord,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validAllowedFieldDesignRecord,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepAllowedFieldsValidated,
    ),
    row(
      DebugOnlyBridgePrototypeDesignRole.prototypeDeniedFieldDesignRecord,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validDeniedFieldDesignRecord,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepDeniedFieldsDenied,
    ),
    row(
      DebugOnlyBridgePrototypeDesignRole
          .stockfishRawUciPvDumpDeniedDesignRecord,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validStockfishRawUciPvDumpDeniedRecord,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepStockfishRawUciPvDumpDenied,
    ),
    row(
      DebugOnlyBridgePrototypeDesignRole.androidProofBoundaryDesignRecord,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validAndroidProofBoundaryRecord,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepAndroidProofBoundaryCapturedOnly,
    ),
    row(
      DebugOnlyBridgePrototypeDesignRole.ownerProofBoundaryDesignRecord,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validOwnerProofBoundaryRecord,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepOwnerProofEmpty,
    ),
    row(
      DebugOnlyBridgePrototypeDesignRole.futureValidationRequirementRecord,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validFutureValidationRequirementRecord,
      DebugOnlyBridgePrototypeDesignValidationRecommendation
          .keepPhase33AValidationRequirementSatisfied,
    ),
  ];
}

DebugOnlyBridgePrototypeDesignValidationResult _resultFromRows({
  required DebugOnlyBridgePrototypeDesignResult designResult,
  required DebugBridgeReadinessValidationGateResult gateResult,
  required List<DebugOnlyBridgePrototypeDesignValidationCheck> checks,
  required List<DebugOnlyBridgePrototypeDesignSectionValidationRow> sectionRows,
  required List<DebugOnlyBridgePrototypeDesignRecordValidationRow> recordRows,
  required List<DebugOnlyBridgePrototypeDesignValidationFinding>
  validationFindings,
}) {
  final blockerCount =
      checks.where((check) => check.severity.blocksStrict).length +
      validationFindings.where((finding) => finding.blocksStrict).length;
  final criticalCount =
      checks.where((check) => check.severity.isCritical).length +
      validationFindings.where((finding) => finding.isCritical).length;
  final unsafeRecordCount = recordRows
      .where((row) => row.validationStatus.isUnsafe || row.hasUnsafeOutput)
      .length;
  final invalidRecordCount = recordRows
      .where((row) => row.validationStatus.isInvalid)
      .length;
  final status = _statusFor(
    designResult: designResult,
    blockerCount: blockerCount,
    criticalCount: criticalCount,
    unsafeRecordCount: unsafeRecordCount,
  );
  final safeForPhase33B =
      status ==
          DebugOnlyBridgePrototypeDesignValidationStatus
              .validatedWithWarnings ||
      status == DebugOnlyBridgePrototypeDesignValidationStatus.validatedClean;
  final warnings = _sortedStrings(<String>[
    ...designResult.warnings,
    'debug bridge runtime remains unimplemented',
    'executable debug bridge prototype remains unimplemented',
    'Phase 33A validates design only',
  ]);
  return DebugOnlyBridgePrototypeDesignValidationResult(
    validationStatus: status,
    sourceDesignStatus: designResult.designStatus,
    sourceGateStatus: designResult.sourceGateStatus,
    sourceSummaryValidationStatus: designResult.sourceValidationStatus,
    validationChecks: checks,
    sectionRows: sectionRows,
    recordRows: recordRows,
    validationFindings: validationFindings,
    warnings: warnings,
    failures: validationFindings
        .where((finding) => finding.blocksStrict)
        .map((finding) => finding.message)
        .toList(),
    totalChecks: checks.length,
    passedCheckCount: checks
        .where(
          (check) =>
              check.checkStatus ==
              DebugOnlyBridgePrototypeDesignValidationCheckStatus.passed,
        )
        .length,
    warningCheckCount: checks
        .where(
          (check) =>
              check.checkStatus ==
              DebugOnlyBridgePrototypeDesignValidationCheckStatus
                  .passedWithWarnings,
        )
        .length,
    blockerCount: blockerCount,
    criticalCount: criticalCount,
    totalSectionRows: sectionRows.length,
    totalRecordRows: recordRows.length,
    validPrototypeCoreDesignCount: _countRecordStatus(
      recordRows,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validPrototypeCoreDesignRecord,
    ),
    validPrototypeContextDesignCount: _countRecordStatus(
      recordRows,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validPrototypeContextDesignRecord,
    ),
    validInactiveBlockedDesignCount: _countRecordStatus(
      recordRows,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validInactiveBlockedDesignRecord,
    ),
    validInactiveFutureOnlyDesignCount: _countRecordStatus(
      recordRows,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validInactiveFutureOnlyDesignRecord,
    ),
    validAllowedFieldDesignCount: _countRecordStatus(
      recordRows,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validAllowedFieldDesignRecord,
    ),
    validDeniedFieldDesignCount: _countRecordStatus(
      recordRows,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validDeniedFieldDesignRecord,
    ),
    validStockfishRawUciPvDumpDeniedCount: _countRecordStatus(
      recordRows,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validStockfishRawUciPvDumpDeniedRecord,
    ),
    validAndroidProofBoundaryCount: _countRecordStatus(
      recordRows,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validAndroidProofBoundaryRecord,
    ),
    validOwnerProofBoundaryCount: _countRecordStatus(
      recordRows,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validOwnerProofBoundaryRecord,
    ),
    validFutureValidationRequirementCount: _countRecordStatus(
      recordRows,
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validFutureValidationRequirementRecord,
    ),
    invalidRecordCount: invalidRecordCount,
    unsafeRecordCount: unsafeRecordCount,
    ownerProofQueueCount: designResult.ownerProofQueueCount,
    supportCaseIds: designResult.supportCaseIds,
    newlyAddedSupportCaseIds: designResult.newlyAddedSupportCaseIds,
    androidProofCaseIds: designResult.androidProofCaseIds,
    allowedFieldIds: designResult.allowedFieldIds,
    deniedFieldIds: designResult.deniedFieldIds,
    safeForPhase33B: safeForPhase33B,
    phase33BRecommendation: _phase33BRecommendationFor(
      status: status,
      safeForPhase33B: safeForPhase33B,
      ownerProofQueueCount: gateResult.ownerProofQueueCount,
    ),
    developerOnly: true,
    debugBridgeRuntimeImplemented: designResult.debugBridgeRuntimeImplemented,
    executableDebugBridgePrototypeImplemented:
        designResult.executableDebugBridgePrototypeImplemented,
    productOutputActive:
        designResult.policyFlags['productOutputActive'] ?? false,
    classifierOutputActive:
        designResult.policyFlags['classifierOutputActive'] ?? false,
    finalMoveLabelOutputActive:
        designResult.policyFlags['finalMoveLabelOutputActive'] ?? false,
    officialMetricOutputActive:
        designResult.policyFlags['officialMetricOutputActive'] ?? false,
    cpLossOutputActive: designResult.policyFlags['cpLossOutputActive'] ?? false,
    winProbabilityOutputActive:
        designResult.policyFlags['winProbabilityOutputActive'] ?? false,
    numericOutputActive:
        designResult.policyFlags['numericOutputActive'] ?? false,
    aggregateScoreOutputActive:
        designResult.policyFlags['aggregateScoreOutputActive'] ?? false,
    moveRankingOutputActive:
        designResult.policyFlags['moveRankingOutputActive'] ?? false,
    quietPreparatoryScopeActivated:
        designResult.policyFlags['quietPreparatoryScopeActivated'] ?? false,
    engineCallsActive: designResult.policyFlags['engineCallsActive'] ?? false,
    persistenceWritesActive:
        designResult.policyFlags['persistenceWritesActive'] ?? false,
    uiTargetsActive: designResult.policyFlags['uiTargetsActive'] ?? false,
    backendOutputActive:
        designResult.policyFlags['backendOutputActive'] ?? false,
    stockfishCommandFieldActive:
        designResult.policyFlags['stockfishCommandFieldActive'] ?? false,
    rawUciFieldActive: designResult.policyFlags['rawUciFieldActive'] ?? false,
    pvDumpFieldActive: designResult.policyFlags['pvDumpFieldActive'] ?? false,
  );
}

void _checkRecordBoundary(
  void Function({
    required String id,
    required DebugOnlyBridgePrototypeDesignValidationSeverity severity,
    required String message,
    String? validationRowId,
    String? designRecordId,
    DebugOnlyBridgePrototypeDesignSectionId? designSectionId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugOnlyBridgePrototypeDesignRecordValidationRow row,
) {
  if (!row.designOnly) {
    add(
      id: 'prototypeDesignRecordNotDesignOnly',
      severity: DebugOnlyBridgePrototypeDesignValidationSeverity.critical,
      message: 'prototype design validation rows must remain design-only',
      validationRowId: row.validationRowId,
      designRecordId: row.sourceDesignRecordId,
    );
  }
  if (row.validationStatus ==
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validPrototypeCoreDesignRecord) {
    if (row.contextOnly ||
        row.inactive ||
        row.violationReasons.contains('prototypeCoreConsumesNonCoreInput')) {
      add(
        id: 'prototypeCoreConsumesNonCoreInput',
        severity: DebugOnlyBridgePrototypeDesignValidationSeverity.critical,
        message:
            'prototype core design validation cannot consume non-core input',
        validationRowId: row.validationRowId,
        designRecordId: row.sourceDesignRecordId,
      );
    }
  }
  if (row.validationStatus ==
      DebugOnlyBridgePrototypeDesignRecordValidationStatus
          .validPrototypeContextDesignRecord) {
    if (!row.contextOnly || row.allowedForFuturePrototypeImplementation) {
      add(
        id: 'contextOnlyInputPromotedToPrototypeCore',
        severity: DebugOnlyBridgePrototypeDesignValidationSeverity.critical,
        message: 'prototype context design validation must remain context-only',
        validationRowId: row.validationRowId,
        designRecordId: row.sourceDesignRecordId,
      );
    }
  }
  if (row.validationStatus.isInactiveBoundary &&
      (!row.inactive || row.allowedFieldIds.isNotEmpty)) {
    add(
      id: 'blockedFutureDesignMadeActive',
      severity: DebugOnlyBridgePrototypeDesignValidationSeverity.critical,
      message:
          'blocked, future-only, and denied design rows must stay inactive',
      validationRowId: row.validationRowId,
      designRecordId: row.sourceDesignRecordId,
    );
  }
}

void _checkSafetyFlags(
  void Function({
    required String id,
    required DebugOnlyBridgePrototypeDesignValidationSeverity severity,
    required String message,
    String? validationRowId,
    String? designRecordId,
    DebugOnlyBridgePrototypeDesignSectionId? designSectionId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugOnlyBridgePrototypeDesignRecordValidationRow row,
) {
  void critical(String id, String message) {
    add(
      id: id,
      severity: DebugOnlyBridgePrototypeDesignValidationSeverity.critical,
      message: message,
      validationRowId: row.validationRowId,
      designRecordId: row.sourceDesignRecordId,
    );
  }

  if (row.safetyFlags['isProductOutput'] == true) {
    critical(
      'productOutputActive',
      'prototype design cannot be product output',
    );
  }
  if (row.safetyFlags['isClassifierLabel'] == true) {
    critical(
      'classifierLabelOutputActive',
      'prototype design cannot emit classifier labels',
    );
  }
  if (row.safetyFlags['hasNumericScore'] == true) {
    critical('numericScoreOutputActive', 'prototype design cannot emit scores');
  }
  if (row.safetyFlags['hasAggregateScore'] == true) {
    critical(
      'aggregateScoreOutputActive',
      'prototype design cannot emit aggregate scores',
    );
  }
  if (row.safetyFlags['ranksMoves'] == true) {
    critical('moveRankingOutputActive', 'prototype design cannot rank moves');
  }
  if (row.safetyFlags['isOfficialMetric'] == true) {
    critical(
      'officialMetricOutputActive',
      'prototype design cannot emit official metrics',
    );
  }
  if (row.safetyFlags['exposesCpLoss'] == true ||
      row.safetyFlags['exposesWinProbability'] == true) {
    critical(
      'futureMetricOutputActive',
      'prototype design cannot expose CP-loss or win probability',
    );
  }
  if (row.safetyFlags['quietPreparatoryScopeActive'] == true) {
    critical(
      'quietPreparatoryScopeActivated',
      'quiet/preparatory scope must remain excluded',
    );
  }
  if (row.safetyFlags['callsEngine'] == true) {
    critical('engineCallFlagActive', 'prototype design cannot call an engine');
  }
  if (row.safetyFlags['writesPersistence'] == true) {
    critical(
      'persistenceWriteFlagActive',
      'prototype design cannot write persistence',
    );
  }
  if (row.safetyFlags['targetsUi'] == true) {
    critical('uiTargetFlagActive', 'prototype design cannot target UI');
  }
  if (row.safetyFlags['backendOutputActive'] == true) {
    critical('backendOutputActive', 'prototype design cannot target backend');
  }
  if (row.safetyFlags['exposesStockfishCommand'] == true ||
      row.safetyFlags['exposesRawUci'] == true ||
      row.safetyFlags['exposesPvDump'] == true) {
    critical(
      'stockfishRawUciPvDumpFieldActive',
      'Stockfish command, raw UCI, and PV dump fields must stay denied',
    );
  }
  if (row.safetyFlags['implementsRuntime'] == true) {
    critical(
      'runtimeImplementationFlagActive',
      'prototype design validation cannot implement runtime behavior',
    );
  }
  if (row.safetyFlags['implementsPrototypeExecution'] == true) {
    critical(
      'executablePrototypeImplementationFlagActive',
      'prototype design validation cannot implement executable prototype behavior',
    );
  }
}

void _checkActiveAllowedField(
  void Function({
    required String id,
    required DebugOnlyBridgePrototypeDesignValidationSeverity severity,
    required String message,
    String? validationRowId,
    String? designRecordId,
    DebugOnlyBridgePrototypeDesignSectionId? designSectionId,
    String? fieldId,
    String? caseId,
  })
  add,
  String fieldId, {
  String? validationRowId,
  String? designRecordId,
  DebugOnlyBridgePrototypeDesignSectionId? designSectionId,
}) {
  if (_isDeniedFieldId(fieldId) || _isLegacyDeniedFieldId(fieldId)) {
    add(
      id: 'activeDeniedField',
      severity: DebugOnlyBridgePrototypeDesignValidationSeverity.critical,
      message: '$fieldId cannot be active prototype design validation output',
      validationRowId: validationRowId,
      designRecordId: designRecordId,
      designSectionId: designSectionId,
      fieldId: fieldId,
    );
  }
}

void _checkAndroidProofCase(
  void Function({
    required String id,
    required DebugOnlyBridgePrototypeDesignValidationSeverity severity,
    required String message,
    String? validationRowId,
    String? designRecordId,
    DebugOnlyBridgePrototypeDesignSectionId? designSectionId,
    String? fieldId,
    String? caseId,
  })
  add,
  String caseId,
  List<String> provenAndroidIds, {
  String? validationRowId,
  String? designRecordId,
  DebugOnlyBridgePrototypeDesignSectionId? designSectionId,
}) {
  if (_phase32ECaseIds.contains(caseId)) {
    add(
      id: 'phase32ECaseTreatedAsCapturedProof',
      severity: DebugOnlyBridgePrototypeDesignValidationSeverity.critical,
      message: '$caseId cannot be treated as captured Android proof',
      validationRowId: validationRowId,
      designRecordId: designRecordId,
      designSectionId: designSectionId,
      caseId: caseId,
    );
    return;
  }
  if (!_capturedAndroidProofIds.contains(caseId) ||
      !provenAndroidIds.contains(caseId)) {
    add(
      id: 'unprovenAndroidProofId',
      severity: DebugOnlyBridgePrototypeDesignValidationSeverity.critical,
      message: '$caseId is not captured Android proof',
      validationRowId: validationRowId,
      designRecordId: designRecordId,
      designSectionId: designSectionId,
      caseId: caseId,
    );
  }
}

DebugOnlyBridgePrototypeDesignValidationStatus _statusFor({
  required DebugOnlyBridgePrototypeDesignResult designResult,
  required int blockerCount,
  required int criticalCount,
  required int unsafeRecordCount,
}) {
  if (designResult.designStatus ==
          DebugOnlyBridgePrototypeDesignStatus.blockedByReadinessGate ||
      !designResult.safeForPhase33A) {
    return DebugOnlyBridgePrototypeDesignValidationStatus
        .blockedByUnsafePrototypeDesign;
  }
  if (designResult.designStatus ==
          DebugOnlyBridgePrototypeDesignStatus.blockedByPolicyBoundary ||
      criticalCount > 0 ||
      unsafeRecordCount > 0) {
    return DebugOnlyBridgePrototypeDesignValidationStatus
        .blockedByPolicyBoundary;
  }
  if (blockerCount > 0) {
    return DebugOnlyBridgePrototypeDesignValidationStatus
        .blockedByPrototypeDesignMismatch;
  }
  if (designResult.designStatus ==
      DebugOnlyBridgePrototypeDesignStatus.designReadyClean) {
    return DebugOnlyBridgePrototypeDesignValidationStatus.validatedClean;
  }
  return DebugOnlyBridgePrototypeDesignValidationStatus.validatedWithWarnings;
}

DebugOnlyBridgePrototypeDesignValidationPhase33BRecommendation
_phase33BRecommendationFor({
  required DebugOnlyBridgePrototypeDesignValidationStatus status,
  required bool safeForPhase33B,
  required int ownerProofQueueCount,
}) {
  if (!safeForPhase33B) {
    return DebugOnlyBridgePrototypeDesignValidationPhase33BRecommendation
        .blockedByUnsafePrototypeDesignValidation;
  }
  if (ownerProofQueueCount > 0) {
    return DebugOnlyBridgePrototypeDesignValidationPhase33BRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (status ==
          DebugOnlyBridgePrototypeDesignValidationStatus
              .validatedWithWarnings ||
      status == DebugOnlyBridgePrototypeDesignValidationStatus.validatedClean) {
    return DebugOnlyBridgePrototypeDesignValidationPhase33BRecommendation
        .proceedToDebugBridgePrototypeDesignReadinessGate;
  }
  return DebugOnlyBridgePrototypeDesignValidationPhase33BRecommendation
      .proceedToDebugBridgePrototypeDesignSummary;
}

int _countRecordStatus(
  List<DebugOnlyBridgePrototypeDesignRecordValidationRow> rows,
  DebugOnlyBridgePrototypeDesignRecordValidationStatus status,
) {
  return rows.where((row) => row.validationStatus == status).length;
}

bool _hasExplicitPvProofReason(
  DebugOnlyBridgePrototypeDesignValidationResult result,
) {
  final text = <String>[
    ...result.warnings,
    ...result.failures,
  ].join(' ').toLowerCase();
  return text.contains('pv') || text.contains('multipv');
}

bool _noPolicyFlagActive(
  DebugOnlyBridgePrototypeDesignResult result,
  Iterable<String> flagIds,
) {
  return flagIds.every((flagId) => result.policyFlags[flagId] != true);
}

List<DebugOnlyBridgePrototypeDesignRecord> _recordsForSection(
  List<DebugOnlyBridgePrototypeDesignRecord> records,
  DebugOnlyBridgePrototypeDesignSectionId sectionId,
) {
  final role = switch (sectionId) {
    DebugOnlyBridgePrototypeDesignSectionId.prototypeCoreInputDesign =>
      DebugOnlyBridgePrototypeDesignRole.prototypeCoreInputDesignRecord,
    DebugOnlyBridgePrototypeDesignSectionId.prototypeContextInputDesign =>
      DebugOnlyBridgePrototypeDesignRole.prototypeContextInputDesignRecord,
    DebugOnlyBridgePrototypeDesignSectionId
        .prototypeInactiveBlockedInputDesign =>
      DebugOnlyBridgePrototypeDesignRole
          .prototypeInactiveBlockedInputDesignRecord,
    DebugOnlyBridgePrototypeDesignSectionId
        .prototypeInactiveFutureOnlyInputDesign =>
      DebugOnlyBridgePrototypeDesignRole
          .prototypeInactiveFutureOnlyInputDesignRecord,
    DebugOnlyBridgePrototypeDesignSectionId.prototypeAllowedFieldDesign =>
      DebugOnlyBridgePrototypeDesignRole.prototypeAllowedFieldDesignRecord,
    DebugOnlyBridgePrototypeDesignSectionId.prototypeDeniedFieldDesign =>
      DebugOnlyBridgePrototypeDesignRole.prototypeDeniedFieldDesignRecord,
    DebugOnlyBridgePrototypeDesignSectionId.stockfishRawUciPvDumpDeniedDesign =>
      DebugOnlyBridgePrototypeDesignRole
          .stockfishRawUciPvDumpDeniedDesignRecord,
    DebugOnlyBridgePrototypeDesignSectionId.androidProofBoundaryDesign =>
      DebugOnlyBridgePrototypeDesignRole.androidProofBoundaryDesignRecord,
    DebugOnlyBridgePrototypeDesignSectionId.ownerProofBoundaryDesign =>
      DebugOnlyBridgePrototypeDesignRole.ownerProofBoundaryDesignRecord,
    DebugOnlyBridgePrototypeDesignSectionId
        .futurePrototypeValidationRequirements =>
      DebugOnlyBridgePrototypeDesignRole.futureValidationRequirementRecord,
  };
  return records.where((record) => record.designRole == role).toList();
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
  DebugOnlyBridgePrototypeDesignValidationFinding a,
  DebugOnlyBridgePrototypeDesignValidationFinding b,
) {
  final severity = _severityRank(
    b.severity,
  ).compareTo(_severityRank(a.severity));
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.designRecordId ?? '').compareTo(b.designRecordId ?? '');
}

int _severityRank(DebugOnlyBridgePrototypeDesignValidationSeverity severity) {
  return switch (severity) {
    DebugOnlyBridgePrototypeDesignValidationSeverity.none => 0,
    DebugOnlyBridgePrototypeDesignValidationSeverity.info => 1,
    DebugOnlyBridgePrototypeDesignValidationSeverity.warning => 2,
    DebugOnlyBridgePrototypeDesignValidationSeverity.blocker => 3,
    DebugOnlyBridgePrototypeDesignValidationSeverity.critical => 4,
  };
}

bool _sameStringSet(Iterable<String> left, Iterable<String> right) {
  return _sortedStrings(left).join('|') == _sortedStrings(right).join('|');
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

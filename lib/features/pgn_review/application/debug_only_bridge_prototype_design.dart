/// Developer-only design contract for a future debug-only bridge prototype.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_summary_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugOnlyBridgePrototypeDesignReportVersion =
    'debug-only-bridge-prototype-design-v1';

enum DebugOnlyBridgePrototypeDesignStatus {
  designReadyWithWarnings('designReadyWithWarnings'),
  designReadyClean('designReadyClean'),
  blockedByReadinessGate('blockedByReadinessGate'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const DebugOnlyBridgePrototypeDesignStatus(this.wire);

  final String wire;
}

enum DebugOnlyBridgePrototypeDesignSectionId {
  prototypeCoreInputDesign('prototypeCoreInputDesign'),
  prototypeContextInputDesign('prototypeContextInputDesign'),
  prototypeInactiveBlockedInputDesign('prototypeInactiveBlockedInputDesign'),
  prototypeInactiveFutureOnlyInputDesign(
    'prototypeInactiveFutureOnlyInputDesign',
  ),
  prototypeAllowedFieldDesign('prototypeAllowedFieldDesign'),
  prototypeDeniedFieldDesign('prototypeDeniedFieldDesign'),
  stockfishRawUciPvDumpDeniedDesign('stockfishRawUciPvDumpDeniedDesign'),
  androidProofBoundaryDesign('androidProofBoundaryDesign'),
  ownerProofBoundaryDesign('ownerProofBoundaryDesign'),
  futurePrototypeValidationRequirements(
    'futurePrototypeValidationRequirements',
  );

  const DebugOnlyBridgePrototypeDesignSectionId(this.wire);

  final String wire;
}

enum DebugOnlyBridgePrototypeDesignSectionStatus {
  prototypeCoreInputDesign('prototypeCoreInputDesign'),
  prototypeContextInputDesign('prototypeContextInputDesign'),
  prototypeInactiveBlockedInputDesign('prototypeInactiveBlockedInputDesign'),
  prototypeInactiveFutureOnlyInputDesign(
    'prototypeInactiveFutureOnlyInputDesign',
  ),
  prototypeAllowedFieldDesign('prototypeAllowedFieldDesign'),
  prototypeDeniedFieldDesign('prototypeDeniedFieldDesign'),
  stockfishRawUciPvDumpDeniedDesign('stockfishRawUciPvDumpDeniedDesign'),
  androidProofBoundaryDesign('androidProofBoundaryDesign'),
  ownerProofBoundaryDesign('ownerProofBoundaryDesign'),
  futurePrototypeValidationRequirements(
    'futurePrototypeValidationRequirements',
  ),
  invalidDesignSection('invalidDesignSection'),
  unsafeDesignSection('unsafeDesignSection');

  const DebugOnlyBridgePrototypeDesignSectionStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == unsafeDesignSection;

  bool get isInvalid => this == invalidDesignSection;
}

enum DebugOnlyBridgePrototypeDesignRole {
  prototypeCoreInputDesignRecord('prototypeCoreInputDesignRecord'),
  prototypeContextInputDesignRecord('prototypeContextInputDesignRecord'),
  prototypeInactiveBlockedInputDesignRecord(
    'prototypeInactiveBlockedInputDesignRecord',
  ),
  prototypeInactiveFutureOnlyInputDesignRecord(
    'prototypeInactiveFutureOnlyInputDesignRecord',
  ),
  prototypeAllowedFieldDesignRecord('prototypeAllowedFieldDesignRecord'),
  prototypeDeniedFieldDesignRecord('prototypeDeniedFieldDesignRecord'),
  stockfishRawUciPvDumpDeniedDesignRecord(
    'stockfishRawUciPvDumpDeniedDesignRecord',
  ),
  androidProofBoundaryDesignRecord('androidProofBoundaryDesignRecord'),
  ownerProofBoundaryDesignRecord('ownerProofBoundaryDesignRecord'),
  futureValidationRequirementRecord('futureValidationRequirementRecord');

  const DebugOnlyBridgePrototypeDesignRole(this.wire);

  final String wire;

  bool get isInactiveBoundary =>
      this == prototypeInactiveBlockedInputDesignRecord ||
      this == prototypeInactiveFutureOnlyInputDesignRecord ||
      this == prototypeDeniedFieldDesignRecord ||
      this == stockfishRawUciPvDumpDeniedDesignRecord;
}

enum DebugOnlyBridgePrototypeDesignRecordStatus {
  prototypeCoreInputDesignRecord('prototypeCoreInputDesignRecord'),
  prototypeContextInputDesignRecord('prototypeContextInputDesignRecord'),
  prototypeInactiveBlockedInputDesignRecord(
    'prototypeInactiveBlockedInputDesignRecord',
  ),
  prototypeInactiveFutureOnlyInputDesignRecord(
    'prototypeInactiveFutureOnlyInputDesignRecord',
  ),
  prototypeAllowedFieldDesignRecord('prototypeAllowedFieldDesignRecord'),
  prototypeDeniedFieldDesignRecord('prototypeDeniedFieldDesignRecord'),
  stockfishRawUciPvDumpDeniedDesignRecord(
    'stockfishRawUciPvDumpDeniedDesignRecord',
  ),
  androidProofBoundaryDesignRecord('androidProofBoundaryDesignRecord'),
  ownerProofBoundaryDesignRecord('ownerProofBoundaryDesignRecord'),
  futureValidationRequirementRecord('futureValidationRequirementRecord'),
  invalidDesignRecord('invalidDesignRecord'),
  unsafeDesignRecord('unsafeDesignRecord');

  const DebugOnlyBridgePrototypeDesignRecordStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == unsafeDesignRecord;

  bool get isInvalid => this == invalidDesignRecord;
}

enum DebugOnlyBridgePrototypeDesignRecommendation {
  keepPrototypeCoreDesignOnly('keepPrototypeCoreDesignOnly'),
  keepPrototypeContextDesignOnly('keepPrototypeContextDesignOnly'),
  keepPrototypeBlockedInactive('keepPrototypeBlockedInactive'),
  keepPrototypeFutureOnlyInactive('keepPrototypeFutureOnlyInactive'),
  keepAllowedFieldsDesignOnly('keepAllowedFieldsDesignOnly'),
  keepDeniedFieldsDenied('keepDeniedFieldsDenied'),
  keepStockfishRawUciPvDumpDenied('keepStockfishRawUciPvDumpDenied'),
  keepAndroidProofBoundaryCapturedOnly('keepAndroidProofBoundaryCapturedOnly'),
  keepOwnerProofEmpty('keepOwnerProofEmpty'),
  requirePhase33AValidation('requirePhase33AValidation'),
  investigatePrototypeDesignFailure('investigatePrototypeDesignFailure'),
  blockUnsafePrototypeDesign('blockUnsafePrototypeDesign');

  const DebugOnlyBridgePrototypeDesignRecommendation(this.wire);

  final String wire;
}

enum DebugOnlyBridgePrototypeDesignPhase33ARecommendation {
  validateDebugOnlyBridgePrototypeDesign(
    'validateDebugOnlyBridgePrototypeDesign',
  ),
  proceedToDebugBridgePrototypeDesignReadinessGate(
    'proceedToDebugBridgePrototypeDesignReadinessGate',
  ),
  proceedToDebugBridgePrototypeDesignReportOnly(
    'proceedToDebugBridgePrototypeDesignReportOnly',
  ),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafePrototypeDesign('blockedByUnsafePrototypeDesign');

  const DebugOnlyBridgePrototypeDesignPhase33ARecommendation(this.wire);

  final String wire;
}

enum DebugOnlyBridgePrototypeDesignSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const DebugOnlyBridgePrototypeDesignSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == DebugOnlyBridgePrototypeDesignSeverity.blocker ||
      this == DebugOnlyBridgePrototypeDesignSeverity.critical;

  bool get isCritical =>
      this == DebugOnlyBridgePrototypeDesignSeverity.critical;
}

enum DebugOnlyBridgePrototypeDesignReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgePrototypeDesignReportFormat(this.wire);

  final String wire;
}

class DebugOnlyBridgePrototypeDesignRequest {
  const DebugOnlyBridgePrototypeDesignRequest({
    this.gateResult,
    this.validationResult,
    this.summaryResult,
    this.readinessGateResult,
    this.bridgeValidationResult,
    this.gate = const DebugBridgeReadinessValidationGate(),
    this.validation = const DebugBridgeReadinessSummaryValidation(),
    this.summary = const DebugBridgeReadinessSummary(),
    this.readinessGate = const DebugBridgeDesignReadinessGate(),
    this.bridgeValidation = const DebugOnlyAdapterBridgeDesignValidation(),
    this.design = const DebugOnlyAdapterBridgeDesign(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const DebugOnlyBridgePrototypeDesignRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final DebugBridgeReadinessValidationGateResult? gateResult;
  final DebugBridgeReadinessSummaryValidationResult? validationResult;
  final DebugBridgeReadinessSummaryResult? summaryResult;
  final DebugBridgeDesignReadinessGateResult? readinessGateResult;
  final DebugOnlyAdapterBridgeDesignValidationResult? bridgeValidationResult;
  final DebugBridgeReadinessValidationGate gate;
  final DebugBridgeReadinessSummaryValidation validation;
  final DebugBridgeReadinessSummary summary;
  final DebugBridgeDesignReadinessGate readinessGate;
  final DebugOnlyAdapterBridgeDesignValidation bridgeValidation;
  final DebugOnlyAdapterBridgeDesign design;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class DebugOnlyBridgePrototypeDesignSection {
  const DebugOnlyBridgePrototypeDesignSection({
    required this.sectionId,
    required this.designStatus,
    required this.sourceGateRecordIds,
    required this.sourceGateGroupIds,
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
    required this.safeForPhase33A,
    required this.recommendation,
  });

  final DebugOnlyBridgePrototypeDesignSectionId sectionId;
  final DebugOnlyBridgePrototypeDesignSectionStatus designStatus;
  final List<String> sourceGateRecordIds;
  final List<String> sourceGateGroupIds;
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
  final bool safeForPhase33A;
  final DebugOnlyBridgePrototypeDesignRecommendation recommendation;

  Map<String, Object?> toJson() => <String, Object?>{
    'sectionId': sectionId.wire,
    'designStatus': designStatus.wire,
    'sourceGateRecordIds': sourceGateRecordIds,
    'sourceGateGroupIds': sourceGateGroupIds,
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
    'safeForPhase33A': safeForPhase33A,
    'recommendation': recommendation.wire,
  };
}

class DebugOnlyBridgePrototypeDesignRecord {
  const DebugOnlyBridgePrototypeDesignRecord({
    required this.prototypeDesignRecordId,
    required this.sourceGateRecordId,
    required this.sourceGateGroupId,
    required this.designRole,
    required this.designStatus,
    required this.allowedForFuturePrototypeImplementation,
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

  final String prototypeDesignRecordId;
  final String sourceGateRecordId;
  final String sourceGateGroupId;
  final DebugOnlyBridgePrototypeDesignRole designRole;
  final DebugOnlyBridgePrototypeDesignRecordStatus designStatus;
  final bool allowedForFuturePrototypeImplementation;
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
  final DebugOnlyBridgePrototypeDesignRecommendation recommendation;

  bool get hasUnsafeOutput => safetyFlags.values.any((value) => value);

  DebugOnlyBridgePrototypeDesignRecord copyWith({
    String? prototypeDesignRecordId,
    String? sourceGateRecordId,
    String? sourceGateGroupId,
    DebugOnlyBridgePrototypeDesignRole? designRole,
    DebugOnlyBridgePrototypeDesignRecordStatus? designStatus,
    bool? allowedForFuturePrototypeImplementation,
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
    DebugOnlyBridgePrototypeDesignRecommendation? recommendation,
  }) {
    return DebugOnlyBridgePrototypeDesignRecord(
      prototypeDesignRecordId:
          prototypeDesignRecordId ?? this.prototypeDesignRecordId,
      sourceGateRecordId: sourceGateRecordId ?? this.sourceGateRecordId,
      sourceGateGroupId: sourceGateGroupId ?? this.sourceGateGroupId,
      designRole: designRole ?? this.designRole,
      designStatus: designStatus ?? this.designStatus,
      allowedForFuturePrototypeImplementation:
          allowedForFuturePrototypeImplementation ??
          this.allowedForFuturePrototypeImplementation,
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
    'prototypeDesignRecordId': prototypeDesignRecordId,
    'sourceGateRecordId': sourceGateRecordId,
    'sourceGateGroupId': sourceGateGroupId,
    'designRole': designRole.wire,
    'designStatus': designStatus.wire,
    'allowedForFuturePrototypeImplementation':
        allowedForFuturePrototypeImplementation,
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

class DebugOnlyBridgePrototypeDesignFinding {
  const DebugOnlyBridgePrototypeDesignFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.prototypeDesignRecordId,
    this.sourceGateRecordId,
    this.sectionId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final DebugOnlyBridgePrototypeDesignSeverity severity;
  final String message;
  final String? prototypeDesignRecordId;
  final String? sourceGateRecordId;
  final DebugOnlyBridgePrototypeDesignSectionId? sectionId;
  final String? fieldId;
  final String? caseId;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'severity': severity.wire,
    'message': message,
    if (prototypeDesignRecordId != null)
      'prototypeDesignRecordId': prototypeDesignRecordId,
    if (sourceGateRecordId != null) 'sourceGateRecordId': sourceGateRecordId,
    if (sectionId != null) 'sectionId': sectionId!.wire,
    if (fieldId != null) 'fieldId': fieldId,
    if (caseId != null) 'caseId': caseId,
  };
}

class DebugOnlyBridgePrototypeDesignResult {
  const DebugOnlyBridgePrototypeDesignResult({
    required this.designStatus,
    required this.sourceGateStatus,
    required this.sourceValidationStatus,
    required this.sourceSummaryStatus,
    required this.designSections,
    required this.designRecords,
    required this.totalDesignSections,
    required this.totalDesignRecords,
    required this.prototypeCoreDesignCount,
    required this.prototypeContextDesignCount,
    required this.inactiveBlockedDesignCount,
    required this.inactiveFutureOnlyDesignCount,
    required this.allowedFieldDesignCount,
    required this.deniedFieldDesignCount,
    required this.stockfishRawUciPvDumpDeniedCount,
    required this.futureValidationRequirementCount,
    required this.unsafeCount,
    required this.blockerCount,
    required this.criticalCount,
    required this.ownerProofQueueCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.safeForPhase33A,
    required this.phase33ARecommendation,
    required this.findings,
    required this.warnings,
    required this.failures,
    required this.developerOnly,
    required this.debugBridgeRuntimeImplemented,
    required this.executableDebugBridgePrototypeImplemented,
    required this.policyFlags,
  });

  final DebugOnlyBridgePrototypeDesignStatus designStatus;
  final DebugBridgeReadinessValidationGateStatus sourceGateStatus;
  final DebugBridgeReadinessSummaryValidationStatus sourceValidationStatus;
  final DebugBridgeReadinessSummaryStatus sourceSummaryStatus;
  final List<DebugOnlyBridgePrototypeDesignSection> designSections;
  final List<DebugOnlyBridgePrototypeDesignRecord> designRecords;
  final int totalDesignSections;
  final int totalDesignRecords;
  final int prototypeCoreDesignCount;
  final int prototypeContextDesignCount;
  final int inactiveBlockedDesignCount;
  final int inactiveFutureOnlyDesignCount;
  final int allowedFieldDesignCount;
  final int deniedFieldDesignCount;
  final int stockfishRawUciPvDumpDeniedCount;
  final int futureValidationRequirementCount;
  final int unsafeCount;
  final int blockerCount;
  final int criticalCount;
  final int ownerProofQueueCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final bool safeForPhase33A;
  final DebugOnlyBridgePrototypeDesignPhase33ARecommendation
  phase33ARecommendation;
  final List<DebugOnlyBridgePrototypeDesignFinding> findings;
  final List<String> warnings;
  final List<String> failures;
  final bool developerOnly;
  final bool debugBridgeRuntimeImplemented;
  final bool executableDebugBridgePrototypeImplemented;
  final Map<String, bool> policyFlags;

  bool get isStrictlyBlocked =>
      blockerCount > 0 ||
      criticalCount > 0 ||
      unsafeCount > 0 ||
      !safeForPhase33A;

  bool get hasUnsafeDebugOnlyBridgePrototypeDesignPolicyViolation =>
      criticalCount > 0 ||
      unsafeCount > 0 ||
      debugBridgeRuntimeImplemented ||
      executableDebugBridgePrototypeImplemented ||
      policyFlags.values.any((value) => value);

  DebugOnlyBridgePrototypeDesignSection section(
    DebugOnlyBridgePrototypeDesignSectionId sectionId,
  ) {
    return designSections.firstWhere(
      (section) => section.sectionId == sectionId,
    );
  }

  DebugOnlyBridgePrototypeDesignRecord recordForRole(
    DebugOnlyBridgePrototypeDesignRole role,
  ) {
    return designRecords.firstWhere((record) => record.designRole == role);
  }

  DebugOnlyBridgePrototypeDesignResult copyWith({
    DebugOnlyBridgePrototypeDesignStatus? designStatus,
    DebugBridgeReadinessValidationGateStatus? sourceGateStatus,
    DebugBridgeReadinessSummaryValidationStatus? sourceValidationStatus,
    DebugBridgeReadinessSummaryStatus? sourceSummaryStatus,
    List<DebugOnlyBridgePrototypeDesignSection>? designSections,
    List<DebugOnlyBridgePrototypeDesignRecord>? designRecords,
    int? totalDesignSections,
    int? totalDesignRecords,
    int? prototypeCoreDesignCount,
    int? prototypeContextDesignCount,
    int? inactiveBlockedDesignCount,
    int? inactiveFutureOnlyDesignCount,
    int? allowedFieldDesignCount,
    int? deniedFieldDesignCount,
    int? stockfishRawUciPvDumpDeniedCount,
    int? futureValidationRequirementCount,
    int? unsafeCount,
    int? blockerCount,
    int? criticalCount,
    int? ownerProofQueueCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    bool? safeForPhase33A,
    DebugOnlyBridgePrototypeDesignPhase33ARecommendation?
    phase33ARecommendation,
    List<DebugOnlyBridgePrototypeDesignFinding>? findings,
    List<String>? warnings,
    List<String>? failures,
    bool? developerOnly,
    bool? debugBridgeRuntimeImplemented,
    bool? executableDebugBridgePrototypeImplemented,
    Map<String, bool>? policyFlags,
  }) {
    return DebugOnlyBridgePrototypeDesignResult(
      designStatus: designStatus ?? this.designStatus,
      sourceGateStatus: sourceGateStatus ?? this.sourceGateStatus,
      sourceValidationStatus:
          sourceValidationStatus ?? this.sourceValidationStatus,
      sourceSummaryStatus: sourceSummaryStatus ?? this.sourceSummaryStatus,
      designSections: designSections ?? this.designSections,
      designRecords: designRecords ?? this.designRecords,
      totalDesignSections: totalDesignSections ?? this.totalDesignSections,
      totalDesignRecords: totalDesignRecords ?? this.totalDesignRecords,
      prototypeCoreDesignCount:
          prototypeCoreDesignCount ?? this.prototypeCoreDesignCount,
      prototypeContextDesignCount:
          prototypeContextDesignCount ?? this.prototypeContextDesignCount,
      inactiveBlockedDesignCount:
          inactiveBlockedDesignCount ?? this.inactiveBlockedDesignCount,
      inactiveFutureOnlyDesignCount:
          inactiveFutureOnlyDesignCount ?? this.inactiveFutureOnlyDesignCount,
      allowedFieldDesignCount:
          allowedFieldDesignCount ?? this.allowedFieldDesignCount,
      deniedFieldDesignCount:
          deniedFieldDesignCount ?? this.deniedFieldDesignCount,
      stockfishRawUciPvDumpDeniedCount:
          stockfishRawUciPvDumpDeniedCount ??
          this.stockfishRawUciPvDumpDeniedCount,
      futureValidationRequirementCount:
          futureValidationRequirementCount ??
          this.futureValidationRequirementCount,
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
      safeForPhase33A: safeForPhase33A ?? this.safeForPhase33A,
      phase33ARecommendation:
          phase33ARecommendation ?? this.phase33ARecommendation,
      findings: findings ?? this.findings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      developerOnly: developerOnly ?? this.developerOnly,
      debugBridgeRuntimeImplemented:
          debugBridgeRuntimeImplemented ?? this.debugBridgeRuntimeImplemented,
      executableDebugBridgePrototypeImplemented:
          executableDebugBridgePrototypeImplemented ??
          this.executableDebugBridgePrototypeImplemented,
      policyFlags: policyFlags ?? this.policyFlags,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'version': debugOnlyBridgePrototypeDesignReportVersion,
    'designStatus': designStatus.wire,
    'sourceGateStatus': sourceGateStatus.wire,
    'sourceValidationStatus': sourceValidationStatus.wire,
    'sourceSummaryStatus': sourceSummaryStatus.wire,
    'totalDesignSections': totalDesignSections,
    'totalDesignRecords': totalDesignRecords,
    'prototypeCoreDesignCount': prototypeCoreDesignCount,
    'prototypeContextDesignCount': prototypeContextDesignCount,
    'inactiveBlockedDesignCount': inactiveBlockedDesignCount,
    'inactiveFutureOnlyDesignCount': inactiveFutureOnlyDesignCount,
    'allowedFieldDesignCount': allowedFieldDesignCount,
    'deniedFieldDesignCount': deniedFieldDesignCount,
    'stockfishRawUciPvDumpDeniedCount': stockfishRawUciPvDumpDeniedCount,
    'futureValidationRequirementCount': futureValidationRequirementCount,
    'unsafeCount': unsafeCount,
    'blockerCount': blockerCount,
    'criticalCount': criticalCount,
    'ownerProofQueueCount': ownerProofQueueCount,
    'supportCaseIds': supportCaseIds,
    'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
    'androidProofCaseIds': androidProofCaseIds,
    'allowedFieldIds': allowedFieldIds,
    'deniedFieldIds': deniedFieldIds,
    'safeForPhase33A': safeForPhase33A,
    'phase33ARecommendation': phase33ARecommendation.wire,
    'designSections': designSections
        .map((section) => section.toJson())
        .toList(),
    'designRecords': designRecords.map((record) => record.toJson()).toList(),
    'findings': findings.map((finding) => finding.toJson()).toList(),
    'warnings': warnings,
    'failures': failures,
    'developerOnly': developerOnly,
    'debugBridgeRuntimeImplemented': debugBridgeRuntimeImplemented,
    'executableDebugBridgePrototypeImplemented':
        executableDebugBridgePrototypeImplemented,
    'futurePhase33AValidationRequired': true,
    'policyFlags': policyFlags,
  };

  String renderJsonReport() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Debug-Only Bridge Prototype Design')
      ..writeln()
      ..writeln('- version: $debugOnlyBridgePrototypeDesignReportVersion')
      ..writeln('- prototype design status: ${designStatus.wire}')
      ..writeln('- source gate status: ${sourceGateStatus.wire}')
      ..writeln('- total design sections: $totalDesignSections')
      ..writeln('- total design records: $totalDesignRecords')
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
      ..writeln('- safeForPhase33A: $safeForPhase33A')
      ..writeln('- Phase 33A recommendation: ${phase33ARecommendation.wire}')
      ..writeln()
      ..writeln('## Design Section Table')
      ..writeln(
        '| Section | Status | Allowed fields | Denied fields | Design-only | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- |');
    for (final section in designSections) {
      buffer.writeln(
        '| ${section.sectionId.wire} | ${section.designStatus.wire} | '
        '${_ids(section.allowedFieldIds)} | ${_ids(section.deniedFieldIds)} | '
        '${section.designOnly} | ${section.recommendation.wire} |',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Design Record Table')
      ..writeln(
        '| Record | Role | Status | Allowed fields | Denied fields | Design-only | Runtime flags | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- |');
    for (final record in designRecords) {
      buffer.writeln(
        '| ${_cell(record.prototypeDesignRecordId)} | '
        '${record.designRole.wire} | ${record.designStatus.wire} | '
        '${_ids(record.allowedFieldIds)} | ${_ids(record.deniedFieldIds)} | '
        '${record.designOnly} | ${record.hasUnsafeOutput} | '
        '${record.recommendation.wire} |',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Prototype Core Input Design')
      ..writeln('- count: $prototypeCoreDesignCount')
      ..writeln('- design-only: true')
      ..writeln()
      ..writeln('## Prototype Context Input Design')
      ..writeln('- count: $prototypeContextDesignCount')
      ..writeln('- context-only: true')
      ..writeln()
      ..writeln('## Inactive Blocked/Future Design')
      ..writeln('- inactive blocked count: $inactiveBlockedDesignCount')
      ..writeln('- inactive future-only count: $inactiveFutureOnlyDesignCount')
      ..writeln()
      ..writeln('## Allowed And Denied Field Design')
      ..writeln('- allowed fields: ${_ids(allowedFieldIds)}')
      ..writeln('- denied fields: ${_ids(deniedFieldIds)}')
      ..writeln()
      ..writeln('## Stockfish Raw UCI PV Dump Denied Design')
      ..writeln(
        '- stockfishCommand denied: ${deniedFieldIds.contains('stockfishCommand')}',
      )
      ..writeln('- rawUci denied: ${deniedFieldIds.contains('rawUci')}')
      ..writeln('- pvDump denied: ${deniedFieldIds.contains('pvDump')}')
      ..writeln()
      ..writeln('## Android Proof Boundary')
      ..writeln('- android proof IDs: ${_ids(androidProofCaseIds)}')
      ..writeln()
      ..writeln('## Owner Proof Boundary')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Future Phase 33A Validation Requirement')
      ..writeln(
        '- Phase 33A must validate this design before any runtime or executable prototype implementation.',
      )
      ..writeln()
      ..writeln('## Findings');
    if (findings.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final finding in findings) {
        buffer.writeln(
          '- ${finding.severity.wire}: ${finding.id}: ${finding.message}',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('## Phase 33A Recommendation')
      ..writeln('- ${phase33ARecommendation.wire}');

    return buffer.toString();
  }
}

class DebugOnlyBridgePrototypeDesign {
  const DebugOnlyBridgePrototypeDesign({
    this.validator = const DebugOnlyBridgePrototypeDesignValidator(),
  });

  final DebugOnlyBridgePrototypeDesignValidator validator;

  DebugOnlyBridgePrototypeDesignResult evaluate(
    DebugOnlyBridgePrototypeDesignRequest request,
  ) {
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
            design: request.design,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );

    final records = _recordsFromGate(gateResult);
    final sections = _sectionsFromRecords(records);
    final allowedFieldIds = _sortedStrings(
      records.expand((record) => record.allowedFieldIds),
    );
    final deniedFieldIds = _sortedStrings(
      records.expand((record) => record.deniedFieldIds),
    );
    final supportCaseIds = _sortedStrings(
      records.expand((record) => record.supportCaseIds),
    );
    final newlyAddedSupportCaseIds = _sortedStrings(
      records.expand((record) => record.newlyAddedSupportCaseIds),
    );
    final androidProofCaseIds = _sortedStrings(
      records.expand((record) => record.androidProofCaseIds),
    );

    final base = DebugOnlyBridgePrototypeDesignResult(
      designStatus:
          DebugOnlyBridgePrototypeDesignStatus.designReadyWithWarnings,
      sourceGateStatus: gateResult.gateStatus,
      sourceValidationStatus: gateResult.sourceValidationStatus,
      sourceSummaryStatus: gateResult.sourceSummaryStatus,
      designSections: sections,
      designRecords: records,
      totalDesignSections: sections.length,
      totalDesignRecords: records.length,
      prototypeCoreDesignCount: _countRole(
        records,
        DebugOnlyBridgePrototypeDesignRole.prototypeCoreInputDesignRecord,
      ),
      prototypeContextDesignCount: _countRole(
        records,
        DebugOnlyBridgePrototypeDesignRole.prototypeContextInputDesignRecord,
      ),
      inactiveBlockedDesignCount: _countRole(
        records,
        DebugOnlyBridgePrototypeDesignRole
            .prototypeInactiveBlockedInputDesignRecord,
      ),
      inactiveFutureOnlyDesignCount: _countRole(
        records,
        DebugOnlyBridgePrototypeDesignRole
            .prototypeInactiveFutureOnlyInputDesignRecord,
      ),
      allowedFieldDesignCount: allowedFieldIds.length,
      deniedFieldDesignCount: deniedFieldIds.length,
      stockfishRawUciPvDumpDeniedCount: deniedFieldIds
          .where(_engineDumpFieldIds.contains)
          .length,
      futureValidationRequirementCount: _countRole(
        records,
        DebugOnlyBridgePrototypeDesignRole.futureValidationRequirementRecord,
      ),
      unsafeCount: records.where((record) => record.hasUnsafeOutput).length,
      blockerCount: 0,
      criticalCount: 0,
      ownerProofQueueCount: gateResult.ownerProofQueueCount,
      supportCaseIds: supportCaseIds,
      newlyAddedSupportCaseIds: newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds,
      allowedFieldIds: allowedFieldIds,
      deniedFieldIds: deniedFieldIds,
      safeForPhase33A: true,
      phase33ARecommendation:
          DebugOnlyBridgePrototypeDesignPhase33ARecommendation
              .validateDebugOnlyBridgePrototypeDesign,
      findings: const <DebugOnlyBridgePrototypeDesignFinding>[],
      warnings: _sortedStrings(<String>[
        ...gateResult.warnings,
        'debug bridge runtime remains unimplemented',
        'executable debug bridge prototype remains unimplemented',
        'Phase 33A validation required before implementation',
      ]),
      failures: const <String>[],
      developerOnly: true,
      debugBridgeRuntimeImplemented: false,
      executableDebugBridgePrototypeImplemented: false,
      policyFlags: _safePolicyFlagsFromGate(gateResult),
    );

    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    )..sort(_compareFindings);
    final blockerCount = findings
        .where((finding) => finding.severity.blocksStrict)
        .length;
    final criticalCount = findings
        .where((finding) => finding.severity.isCritical)
        .length;
    final unsafeCount =
        base.unsafeCount +
        findings
            .where(
              (finding) =>
                  finding.severity ==
                  DebugOnlyBridgePrototypeDesignSeverity.critical,
            )
            .length;
    final status = _statusFor(
      gateResult: gateResult,
      blockerCount: blockerCount,
      criticalCount: criticalCount,
      unsafeCount: unsafeCount,
    );
    final safeForPhase33A =
        status ==
            DebugOnlyBridgePrototypeDesignStatus.designReadyWithWarnings ||
        status == DebugOnlyBridgePrototypeDesignStatus.designReadyClean;

    return base.copyWith(
      designStatus: status,
      safeForPhase33A: safeForPhase33A,
      phase33ARecommendation: _phase33ARecommendationFor(
        status: status,
        safeForPhase33A: safeForPhase33A,
        ownerProofQueueCount: gateResult.ownerProofQueueCount,
      ),
      findings: findings,
      blockerCount: blockerCount,
      criticalCount: criticalCount,
      unsafeCount: unsafeCount,
      failures: findings
          .where((finding) => finding.severity.blocksStrict)
          .map((finding) => finding.message)
          .toList(),
    );
  }
}

class DebugOnlyBridgePrototypeDesignValidator {
  const DebugOnlyBridgePrototypeDesignValidator();

  List<DebugOnlyBridgePrototypeDesignFinding> validate(
    DebugOnlyBridgePrototypeDesignResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <DebugOnlyBridgePrototypeDesignFinding>[];
    void add({
      required String id,
      required DebugOnlyBridgePrototypeDesignSeverity severity,
      required String message,
      String? prototypeDesignRecordId,
      String? sourceGateRecordId,
      DebugOnlyBridgePrototypeDesignSectionId? sectionId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        DebugOnlyBridgePrototypeDesignFinding(
          id: id,
          severity: severity,
          message: message,
          prototypeDesignRecordId: prototypeDesignRecordId,
          sourceGateRecordId: sourceGateRecordId,
          sectionId: sectionId,
          fieldId: fieldId,
          caseId: caseId,
        ),
      );
    }

    if (result.sourceGateStatus !=
            DebugBridgeReadinessValidationGateStatus
                .readyForPrototypeDesignWithWarnings &&
        result.sourceGateStatus !=
            DebugBridgeReadinessValidationGateStatus
                .readyForPrototypeDesignClean) {
      add(
        id: 'unsafeReadinessGateMarkedDesignReady',
        severity: DebugOnlyBridgePrototypeDesignSeverity.critical,
        message: 'unsafe readiness gate cannot be marked design-ready',
      );
    }

    if (result.debugBridgeRuntimeImplemented) {
      add(
        id: 'runtimeImplementationFlagActive',
        severity: DebugOnlyBridgePrototypeDesignSeverity.critical,
        message: 'prototype design cannot implement a runtime bridge',
      );
    }
    if (result.executableDebugBridgePrototypeImplemented) {
      add(
        id: 'executablePrototypeImplementationFlagActive',
        severity: DebugOnlyBridgePrototypeDesignSeverity.critical,
        message: 'prototype design cannot implement executable prototype code',
      );
    }

    for (final section in result.designSections) {
      for (final fieldId in section.allowedFieldIds) {
        _checkActiveAllowedField(add, fieldId, sectionId: section.sectionId);
      }
      for (final caseId in section.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          _provenAndroidProofIds(androidProofEvidence),
          sectionId: section.sectionId,
        );
      }
      if (!section.designOnly) {
        add(
          id: 'sectionNotDesignOnly',
          severity: DebugOnlyBridgePrototypeDesignSeverity.critical,
          message: '${section.sectionId.wire} must remain design-only',
          sectionId: section.sectionId,
        );
      }
    }

    for (final record in result.designRecords) {
      for (final fieldId in record.allowedFieldIds) {
        _checkActiveAllowedField(
          add,
          fieldId,
          prototypeDesignRecordId: record.prototypeDesignRecordId,
          sourceGateRecordId: record.sourceGateRecordId,
        );
      }
      for (final caseId in record.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          _provenAndroidProofIds(androidProofEvidence),
          prototypeDesignRecordId: record.prototypeDesignRecordId,
          sourceGateRecordId: record.sourceGateRecordId,
        );
      }
      _validateRecordBoundaries(add, record);
      _validateRecordSafetyFlags(add, record);
    }

    for (final fieldId in result.allowedFieldIds) {
      _checkActiveAllowedField(add, fieldId);
    }
    for (final proofId in result.androidProofCaseIds) {
      _checkAndroidProofCase(
        add,
        proofId,
        _provenAndroidProofIds(androidProofEvidence),
      );
    }

    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: DebugOnlyBridgePrototypeDesignSeverity.critical,
        message:
            'owner proof cannot be required without an explicit PV/MultiPV reason',
      );
    }

    for (final entry in result.policyFlags.entries) {
      if (!entry.value) continue;
      add(
        id: '${entry.key}Active',
        severity: DebugOnlyBridgePrototypeDesignSeverity.critical,
        message: '${entry.key} must remain inactive in prototype design',
      );
    }

    return findings;
  }

  List<DebugOnlyBridgePrototypeDesignFinding> validateReportText(
    String report,
  ) {
    final findings = <DebugOnlyBridgePrototypeDesignFinding>[];
    void critical(String id, String message) {
      findings.add(
        DebugOnlyBridgePrototypeDesignFinding(
          id: id,
          severity: DebugOnlyBridgePrototypeDesignSeverity.critical,
          message: message,
        ),
      );
    }

    for (final token in const <String>[
      'uciok',
      'readyok',
      'info depth',
      'bestmove ',
      'pv e2e4',
      'pvMoves',
      'scoreValue',
      'moveScore',
      'rankedMoves',
      'backendUrl',
      'secret',
      'allowed fields: productLabel',
      'allowed fields: finalMoveLabel',
      'allowed fields: numericMoveScore',
      'allowed fields: stockfishCommand',
      'allowed fields: rawUci',
      'allowed fields: pvDump',
      'runtime implemented: true',
      'executable debug bridge prototype implemented: true',
    ]) {
      if (report.contains(token)) {
        critical('unsafeReportToken', 'report contains forbidden token $token');
      }
    }
    return findings;
  }
}

List<DebugOnlyBridgePrototypeDesignRecord> _recordsFromGate(
  DebugBridgeReadinessValidationGateResult gateResult,
) {
  final core = gateResult.recordForRole(
    DebugBridgeReadinessValidationGateRole.prototypeReadyDebugCore,
  );
  final context = gateResult.recordForRole(
    DebugBridgeReadinessValidationGateRole.constrainedDebugContext,
  );
  final blocked = gateResult.recordForRole(
    DebugBridgeReadinessValidationGateRole.inactiveDebugBlocked,
  );
  final future = gateResult.recordForRole(
    DebugBridgeReadinessValidationGateRole.inactiveDebugFutureOnly,
  );
  final allowedFields = gateResult.recordForRole(
    DebugBridgeReadinessValidationGateRole.prototypeReadyAllowedField,
  );
  final deniedFields = gateResult.recordForRole(
    DebugBridgeReadinessValidationGateRole.deniedFieldBoundary,
  );
  final stockfishBoundary = gateResult.recordForRole(
    DebugBridgeReadinessValidationGateRole.stockfishRawUciPvDumpDenied,
  );
  final androidProof = gateResult.recordForRole(
    DebugBridgeReadinessValidationGateRole.validatedAndroidProofBoundary,
  );
  final ownerProof = gateResult.recordForRole(
    DebugBridgeReadinessValidationGateRole.emptyOwnerProofGate,
  );

  return <DebugOnlyBridgePrototypeDesignRecord>[
    _recordFromGate(
      core,
      role: DebugOnlyBridgePrototypeDesignRole.prototypeCoreInputDesignRecord,
      status: DebugOnlyBridgePrototypeDesignRecordStatus
          .prototypeCoreInputDesignRecord,
      allowedForFuturePrototypeImplementation: true,
      contextOnly: false,
      inactive: false,
      recommendation: DebugOnlyBridgePrototypeDesignRecommendation
          .keepPrototypeCoreDesignOnly,
    ),
    _recordFromGate(
      context,
      role:
          DebugOnlyBridgePrototypeDesignRole.prototypeContextInputDesignRecord,
      status: DebugOnlyBridgePrototypeDesignRecordStatus
          .prototypeContextInputDesignRecord,
      allowedForFuturePrototypeImplementation: false,
      contextOnly: true,
      inactive: false,
      recommendation: DebugOnlyBridgePrototypeDesignRecommendation
          .keepPrototypeContextDesignOnly,
    ),
    _recordFromGate(
      blocked,
      role: DebugOnlyBridgePrototypeDesignRole
          .prototypeInactiveBlockedInputDesignRecord,
      status: DebugOnlyBridgePrototypeDesignRecordStatus
          .prototypeInactiveBlockedInputDesignRecord,
      allowedForFuturePrototypeImplementation: false,
      contextOnly: false,
      inactive: true,
      recommendation: DebugOnlyBridgePrototypeDesignRecommendation
          .keepPrototypeBlockedInactive,
    ),
    _recordFromGate(
      future,
      role: DebugOnlyBridgePrototypeDesignRole
          .prototypeInactiveFutureOnlyInputDesignRecord,
      status: DebugOnlyBridgePrototypeDesignRecordStatus
          .prototypeInactiveFutureOnlyInputDesignRecord,
      allowedForFuturePrototypeImplementation: false,
      contextOnly: false,
      inactive: true,
      recommendation: DebugOnlyBridgePrototypeDesignRecommendation
          .keepPrototypeFutureOnlyInactive,
    ),
    _recordFromGate(
      allowedFields,
      role:
          DebugOnlyBridgePrototypeDesignRole.prototypeAllowedFieldDesignRecord,
      status: DebugOnlyBridgePrototypeDesignRecordStatus
          .prototypeAllowedFieldDesignRecord,
      allowedForFuturePrototypeImplementation: true,
      contextOnly: false,
      inactive: false,
      recommendation: DebugOnlyBridgePrototypeDesignRecommendation
          .keepAllowedFieldsDesignOnly,
    ),
    _recordFromGate(
      deniedFields,
      role: DebugOnlyBridgePrototypeDesignRole.prototypeDeniedFieldDesignRecord,
      status: DebugOnlyBridgePrototypeDesignRecordStatus
          .prototypeDeniedFieldDesignRecord,
      allowedForFuturePrototypeImplementation: false,
      contextOnly: false,
      inactive: true,
      recommendation:
          DebugOnlyBridgePrototypeDesignRecommendation.keepDeniedFieldsDenied,
    ),
    _recordFromGate(
      stockfishBoundary,
      role: DebugOnlyBridgePrototypeDesignRole
          .stockfishRawUciPvDumpDeniedDesignRecord,
      status: DebugOnlyBridgePrototypeDesignRecordStatus
          .stockfishRawUciPvDumpDeniedDesignRecord,
      allowedForFuturePrototypeImplementation: false,
      contextOnly: false,
      inactive: true,
      recommendation: DebugOnlyBridgePrototypeDesignRecommendation
          .keepStockfishRawUciPvDumpDenied,
    ),
    _recordFromGate(
      androidProof,
      role: DebugOnlyBridgePrototypeDesignRole.androidProofBoundaryDesignRecord,
      status: DebugOnlyBridgePrototypeDesignRecordStatus
          .androidProofBoundaryDesignRecord,
      allowedForFuturePrototypeImplementation: true,
      contextOnly: false,
      inactive: false,
      recommendation: DebugOnlyBridgePrototypeDesignRecommendation
          .keepAndroidProofBoundaryCapturedOnly,
    ),
    _recordFromGate(
      ownerProof,
      role: DebugOnlyBridgePrototypeDesignRole.ownerProofBoundaryDesignRecord,
      status: DebugOnlyBridgePrototypeDesignRecordStatus
          .ownerProofBoundaryDesignRecord,
      allowedForFuturePrototypeImplementation: true,
      contextOnly: false,
      inactive: false,
      recommendation:
          DebugOnlyBridgePrototypeDesignRecommendation.keepOwnerProofEmpty,
    ),
    DebugOnlyBridgePrototypeDesignRecord(
      prototypeDesignRecordId:
          'debug-only-bridge-prototype-phase-33a-validation',
      sourceGateRecordId: 'phase-32z-design-only-future-validation',
      sourceGateGroupId: DebugOnlyBridgePrototypeDesignSectionId
          .futurePrototypeValidationRequirements
          .wire,
      designRole:
          DebugOnlyBridgePrototypeDesignRole.futureValidationRequirementRecord,
      designStatus: DebugOnlyBridgePrototypeDesignRecordStatus
          .futureValidationRequirementRecord,
      allowedForFuturePrototypeImplementation: false,
      designOnly: true,
      contextOnly: false,
      inactive: false,
      allowedFieldIds: const <String>[],
      deniedFieldIds: const <String>[],
      supportCaseIds: const <String>[],
      newlyAddedSupportCaseIds: const <String>[],
      androidProofCaseIds: const <String>[],
      warningReasons: const <String>[
        'Phase 33A must validate this design before runtime or executable prototype implementation',
      ],
      proofLimitReasons: const <String>[],
      futurePrerequisites: const <String>[
        'validateDebugOnlyBridgePrototypeDesign',
      ],
      blockedBoundaryIds: const <String>[],
      safetyFlags: _safeRecordFlags,
      violationReasons: const <String>[],
      recommendation: DebugOnlyBridgePrototypeDesignRecommendation
          .requirePhase33AValidation,
    ),
  ];
}

DebugOnlyBridgePrototypeDesignRecord _recordFromGate(
  DebugBridgeReadinessValidationGateRecord source, {
  required DebugOnlyBridgePrototypeDesignRole role,
  required DebugOnlyBridgePrototypeDesignRecordStatus status,
  required bool allowedForFuturePrototypeImplementation,
  required bool contextOnly,
  required bool inactive,
  required DebugOnlyBridgePrototypeDesignRecommendation recommendation,
}) {
  return DebugOnlyBridgePrototypeDesignRecord(
    prototypeDesignRecordId: 'debug-prototype-design-${source.gateRecordId}',
    sourceGateRecordId: source.gateRecordId,
    sourceGateGroupId: source.sourceSummaryGroupId,
    designRole: role,
    designStatus: status,
    allowedForFuturePrototypeImplementation:
        allowedForFuturePrototypeImplementation,
    designOnly: true,
    contextOnly: contextOnly,
    inactive: inactive,
    allowedFieldIds: _sortedStrings(source.allowedFieldIds),
    deniedFieldIds: _sortedStrings(source.deniedFieldIds),
    supportCaseIds: _sortedStrings(source.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(source.newlyAddedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(source.androidProofCaseIds),
    warningReasons: _sortedStrings(source.warningReasons),
    proofLimitReasons: _sortedStrings(source.proofLimitReasons),
    futurePrerequisites: _sortedStrings(source.futurePrerequisites),
    blockedBoundaryIds: _sortedStrings(source.blockedBoundaryIds),
    safetyFlags: _safeFlagsFrom(source.safetyFlags),
    violationReasons: _sortedStrings(source.violationReasons),
    recommendation: recommendation,
  );
}

List<DebugOnlyBridgePrototypeDesignSection> _sectionsFromRecords(
  List<DebugOnlyBridgePrototypeDesignRecord> records,
) {
  return <DebugOnlyBridgePrototypeDesignSection>[
    _sectionFromRole(
      records,
      DebugOnlyBridgePrototypeDesignRole.prototypeCoreInputDesignRecord,
      sectionId:
          DebugOnlyBridgePrototypeDesignSectionId.prototypeCoreInputDesign,
      status:
          DebugOnlyBridgePrototypeDesignSectionStatus.prototypeCoreInputDesign,
      recommendation: DebugOnlyBridgePrototypeDesignRecommendation
          .keepPrototypeCoreDesignOnly,
    ),
    _sectionFromRole(
      records,
      DebugOnlyBridgePrototypeDesignRole.prototypeContextInputDesignRecord,
      sectionId:
          DebugOnlyBridgePrototypeDesignSectionId.prototypeContextInputDesign,
      status: DebugOnlyBridgePrototypeDesignSectionStatus
          .prototypeContextInputDesign,
      recommendation: DebugOnlyBridgePrototypeDesignRecommendation
          .keepPrototypeContextDesignOnly,
    ),
    _sectionFromRole(
      records,
      DebugOnlyBridgePrototypeDesignRole
          .prototypeInactiveBlockedInputDesignRecord,
      sectionId: DebugOnlyBridgePrototypeDesignSectionId
          .prototypeInactiveBlockedInputDesign,
      status: DebugOnlyBridgePrototypeDesignSectionStatus
          .prototypeInactiveBlockedInputDesign,
      recommendation: DebugOnlyBridgePrototypeDesignRecommendation
          .keepPrototypeBlockedInactive,
    ),
    _sectionFromRole(
      records,
      DebugOnlyBridgePrototypeDesignRole
          .prototypeInactiveFutureOnlyInputDesignRecord,
      sectionId: DebugOnlyBridgePrototypeDesignSectionId
          .prototypeInactiveFutureOnlyInputDesign,
      status: DebugOnlyBridgePrototypeDesignSectionStatus
          .prototypeInactiveFutureOnlyInputDesign,
      recommendation: DebugOnlyBridgePrototypeDesignRecommendation
          .keepPrototypeFutureOnlyInactive,
    ),
    _sectionFromRole(
      records,
      DebugOnlyBridgePrototypeDesignRole.prototypeAllowedFieldDesignRecord,
      sectionId:
          DebugOnlyBridgePrototypeDesignSectionId.prototypeAllowedFieldDesign,
      status: DebugOnlyBridgePrototypeDesignSectionStatus
          .prototypeAllowedFieldDesign,
      recommendation: DebugOnlyBridgePrototypeDesignRecommendation
          .keepAllowedFieldsDesignOnly,
    ),
    _sectionFromRole(
      records,
      DebugOnlyBridgePrototypeDesignRole.prototypeDeniedFieldDesignRecord,
      sectionId:
          DebugOnlyBridgePrototypeDesignSectionId.prototypeDeniedFieldDesign,
      status: DebugOnlyBridgePrototypeDesignSectionStatus
          .prototypeDeniedFieldDesign,
      recommendation:
          DebugOnlyBridgePrototypeDesignRecommendation.keepDeniedFieldsDenied,
    ),
    _sectionFromRole(
      records,
      DebugOnlyBridgePrototypeDesignRole
          .stockfishRawUciPvDumpDeniedDesignRecord,
      sectionId: DebugOnlyBridgePrototypeDesignSectionId
          .stockfishRawUciPvDumpDeniedDesign,
      status: DebugOnlyBridgePrototypeDesignSectionStatus
          .stockfishRawUciPvDumpDeniedDesign,
      recommendation: DebugOnlyBridgePrototypeDesignRecommendation
          .keepStockfishRawUciPvDumpDenied,
    ),
    _sectionFromRole(
      records,
      DebugOnlyBridgePrototypeDesignRole.androidProofBoundaryDesignRecord,
      sectionId:
          DebugOnlyBridgePrototypeDesignSectionId.androidProofBoundaryDesign,
      status: DebugOnlyBridgePrototypeDesignSectionStatus
          .androidProofBoundaryDesign,
      recommendation: DebugOnlyBridgePrototypeDesignRecommendation
          .keepAndroidProofBoundaryCapturedOnly,
    ),
    _sectionFromRole(
      records,
      DebugOnlyBridgePrototypeDesignRole.ownerProofBoundaryDesignRecord,
      sectionId:
          DebugOnlyBridgePrototypeDesignSectionId.ownerProofBoundaryDesign,
      status:
          DebugOnlyBridgePrototypeDesignSectionStatus.ownerProofBoundaryDesign,
      recommendation:
          DebugOnlyBridgePrototypeDesignRecommendation.keepOwnerProofEmpty,
    ),
    _sectionFromRole(
      records,
      DebugOnlyBridgePrototypeDesignRole.futureValidationRequirementRecord,
      sectionId: DebugOnlyBridgePrototypeDesignSectionId
          .futurePrototypeValidationRequirements,
      status: DebugOnlyBridgePrototypeDesignSectionStatus
          .futurePrototypeValidationRequirements,
      recommendation: DebugOnlyBridgePrototypeDesignRecommendation
          .requirePhase33AValidation,
    ),
  ];
}

DebugOnlyBridgePrototypeDesignSection _sectionFromRole(
  List<DebugOnlyBridgePrototypeDesignRecord> records,
  DebugOnlyBridgePrototypeDesignRole role, {
  required DebugOnlyBridgePrototypeDesignSectionId sectionId,
  required DebugOnlyBridgePrototypeDesignSectionStatus status,
  required DebugOnlyBridgePrototypeDesignRecommendation recommendation,
}) {
  final matching = records
      .where((record) => record.designRole == role)
      .toList();
  return DebugOnlyBridgePrototypeDesignSection(
    sectionId: sectionId,
    designStatus: status,
    sourceGateRecordIds: _sortedStrings(
      matching.map((record) => record.sourceGateRecordId),
    ),
    sourceGateGroupIds: _sortedStrings(
      matching.map((record) => record.sourceGateGroupId),
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
    safeForPhase33A: matching.every((record) => !record.hasUnsafeOutput),
    recommendation: recommendation,
  );
}

void _validateRecordBoundaries(
  void Function({
    required String id,
    required DebugOnlyBridgePrototypeDesignSeverity severity,
    required String message,
    String? prototypeDesignRecordId,
    String? sourceGateRecordId,
    DebugOnlyBridgePrototypeDesignSectionId? sectionId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugOnlyBridgePrototypeDesignRecord record,
) {
  if (!record.designOnly) {
    add(
      id: 'recordNotDesignOnly',
      severity: DebugOnlyBridgePrototypeDesignSeverity.critical,
      message: 'prototype design record must remain design-only',
      prototypeDesignRecordId: record.prototypeDesignRecordId,
      sourceGateRecordId: record.sourceGateRecordId,
    );
  }
  if (record.designRole ==
      DebugOnlyBridgePrototypeDesignRole.prototypeCoreInputDesignRecord) {
    if (record.sourceGateGroupId != 'readyDebugCoreInputSummary' &&
        record.sourceGateGroupId != 'prototypeReadyDebugCoreGroup') {
      add(
        id: 'prototypeCoreConsumesNonCoreInput',
        severity: DebugOnlyBridgePrototypeDesignSeverity.critical,
        message:
            'prototype core design can consume only Phase 32Y core records',
        prototypeDesignRecordId: record.prototypeDesignRecordId,
        sourceGateRecordId: record.sourceGateRecordId,
      );
    }
    if (record.contextOnly || record.inactive) {
      add(
        id: 'contextOnlyInputPromotedToPrototypeCore',
        severity: DebugOnlyBridgePrototypeDesignSeverity.critical,
        message: 'context-only or inactive input cannot become prototype core',
        prototypeDesignRecordId: record.prototypeDesignRecordId,
        sourceGateRecordId: record.sourceGateRecordId,
      );
    }
  }
  if (record.designRole ==
      DebugOnlyBridgePrototypeDesignRole.prototypeContextInputDesignRecord) {
    if (!record.contextOnly ||
        record.allowedForFuturePrototypeImplementation ||
        record.sourceGateGroupId == 'readyDebugCoreInputSummary') {
      add(
        id: 'contextOnlyInputPromotedToPrototypeCore',
        severity: DebugOnlyBridgePrototypeDesignSeverity.critical,
        message: 'prototype context design must remain context-only',
        prototypeDesignRecordId: record.prototypeDesignRecordId,
        sourceGateRecordId: record.sourceGateRecordId,
      );
    }
  }
  if (record.designRole.isInactiveBoundary) {
    if (!record.inactive || record.allowedFieldIds.isNotEmpty) {
      add(
        id: 'blockedFutureInputMadeActive',
        severity: DebugOnlyBridgePrototypeDesignSeverity.critical,
        message:
            'blocked, future-only, and denied boundary records must stay inactive',
        prototypeDesignRecordId: record.prototypeDesignRecordId,
        sourceGateRecordId: record.sourceGateRecordId,
      );
    }
  }
}

void _validateRecordSafetyFlags(
  void Function({
    required String id,
    required DebugOnlyBridgePrototypeDesignSeverity severity,
    required String message,
    String? prototypeDesignRecordId,
    String? sourceGateRecordId,
    DebugOnlyBridgePrototypeDesignSectionId? sectionId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugOnlyBridgePrototypeDesignRecord record,
) {
  void critical(String id, String message) {
    add(
      id: id,
      severity: DebugOnlyBridgePrototypeDesignSeverity.critical,
      message: message,
      prototypeDesignRecordId: record.prototypeDesignRecordId,
      sourceGateRecordId: record.sourceGateRecordId,
    );
  }

  if (record.safetyFlags['isProductOutput'] == true) {
    critical(
      'productOutputActive',
      'prototype design cannot be product output',
    );
  }
  if (record.safetyFlags['isClassifierLabel'] == true) {
    critical(
      'classifierLabelOutputActive',
      'prototype design cannot emit classifier labels',
    );
  }
  if (record.safetyFlags['hasNumericScore'] == true) {
    critical('numericScoreOutputActive', 'prototype design cannot emit scores');
  }
  if (record.safetyFlags['hasAggregateScore'] == true) {
    critical(
      'aggregateScoreOutputActive',
      'prototype design cannot emit aggregate scores',
    );
  }
  if (record.safetyFlags['ranksMoves'] == true) {
    critical('moveRankingOutputActive', 'prototype design cannot rank moves');
  }
  if (record.safetyFlags['isOfficialMetric'] == true) {
    critical(
      'officialMetricOutputActive',
      'prototype design cannot emit official metrics',
    );
  }
  if (record.safetyFlags['exposesCpLoss'] == true ||
      record.safetyFlags['exposesWinProbability'] == true) {
    critical(
      'futureMetricOutputActive',
      'prototype design cannot expose CP-loss or win probability',
    );
  }
  if (record.safetyFlags['quietPreparatoryScopeActive'] == true) {
    critical(
      'quietPreparatoryScopeActivated',
      'quiet/preparatory scope must remain excluded',
    );
  }
  if (record.safetyFlags['callsEngine'] == true) {
    critical('engineCallFlagActive', 'prototype design cannot call an engine');
  }
  if (record.safetyFlags['writesPersistence'] == true) {
    critical(
      'persistenceWriteFlagActive',
      'prototype design cannot write persistence',
    );
  }
  if (record.safetyFlags['targetsUi'] == true) {
    critical('uiTargetFlagActive', 'prototype design cannot target UI');
  }
  if (record.safetyFlags['backendOutputActive'] == true) {
    critical(
      'backendOutputActive',
      'prototype design cannot target backend output',
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
      'prototype design cannot implement runtime behavior',
    );
  }
  if (record.safetyFlags['implementsPrototypeExecution'] == true) {
    critical(
      'executablePrototypeImplementationFlagActive',
      'prototype design cannot implement executable prototype behavior',
    );
  }
}

void _checkActiveAllowedField(
  void Function({
    required String id,
    required DebugOnlyBridgePrototypeDesignSeverity severity,
    required String message,
    String? prototypeDesignRecordId,
    String? sourceGateRecordId,
    DebugOnlyBridgePrototypeDesignSectionId? sectionId,
    String? fieldId,
    String? caseId,
  })
  add,
  String fieldId, {
  String? prototypeDesignRecordId,
  String? sourceGateRecordId,
  DebugOnlyBridgePrototypeDesignSectionId? sectionId,
}) {
  if (_isDeniedFieldId(fieldId) || _isLegacyDeniedFieldId(fieldId)) {
    add(
      id: 'activeDeniedField',
      severity: DebugOnlyBridgePrototypeDesignSeverity.critical,
      message: '$fieldId cannot be active prototype design output',
      prototypeDesignRecordId: prototypeDesignRecordId,
      sourceGateRecordId: sourceGateRecordId,
      sectionId: sectionId,
      fieldId: fieldId,
    );
  }
}

void _checkAndroidProofCase(
  void Function({
    required String id,
    required DebugOnlyBridgePrototypeDesignSeverity severity,
    required String message,
    String? prototypeDesignRecordId,
    String? sourceGateRecordId,
    DebugOnlyBridgePrototypeDesignSectionId? sectionId,
    String? fieldId,
    String? caseId,
  })
  add,
  String caseId,
  List<String> provenAndroidIds, {
  String? prototypeDesignRecordId,
  String? sourceGateRecordId,
  DebugOnlyBridgePrototypeDesignSectionId? sectionId,
}) {
  if (_phase32ECaseIds.contains(caseId)) {
    add(
      id: 'phase32ECaseTreatedAsCapturedProof',
      severity: DebugOnlyBridgePrototypeDesignSeverity.critical,
      message: '$caseId cannot be treated as captured Android proof',
      prototypeDesignRecordId: prototypeDesignRecordId,
      sourceGateRecordId: sourceGateRecordId,
      sectionId: sectionId,
      caseId: caseId,
    );
    return;
  }
  if (!_capturedAndroidProofIds.contains(caseId) ||
      !provenAndroidIds.contains(caseId)) {
    add(
      id: 'unprovenAndroidProofId',
      severity: DebugOnlyBridgePrototypeDesignSeverity.critical,
      message: '$caseId is not captured Android proof',
      prototypeDesignRecordId: prototypeDesignRecordId,
      sourceGateRecordId: sourceGateRecordId,
      sectionId: sectionId,
      caseId: caseId,
    );
  }
}

DebugOnlyBridgePrototypeDesignStatus _statusFor({
  required DebugBridgeReadinessValidationGateResult gateResult,
  required int blockerCount,
  required int criticalCount,
  required int unsafeCount,
}) {
  if (gateResult.gateStatus !=
          DebugBridgeReadinessValidationGateStatus
              .readyForPrototypeDesignWithWarnings &&
      gateResult.gateStatus !=
          DebugBridgeReadinessValidationGateStatus
              .readyForPrototypeDesignClean) {
    return DebugOnlyBridgePrototypeDesignStatus.blockedByReadinessGate;
  }
  if (!gateResult.safeForPhase32Z ||
      gateResult.unsafeCount > 0 ||
      unsafeCount > 0 ||
      criticalCount > 0) {
    return DebugOnlyBridgePrototypeDesignStatus.blockedByPolicyBoundary;
  }
  if (blockerCount > 0) {
    return DebugOnlyBridgePrototypeDesignStatus.blockedByReadinessGate;
  }
  if (gateResult.gateStatus ==
      DebugBridgeReadinessValidationGateStatus.readyForPrototypeDesignClean) {
    return DebugOnlyBridgePrototypeDesignStatus.designReadyClean;
  }
  return DebugOnlyBridgePrototypeDesignStatus.designReadyWithWarnings;
}

DebugOnlyBridgePrototypeDesignPhase33ARecommendation
_phase33ARecommendationFor({
  required DebugOnlyBridgePrototypeDesignStatus status,
  required bool safeForPhase33A,
  required int ownerProofQueueCount,
}) {
  if (!safeForPhase33A) {
    return DebugOnlyBridgePrototypeDesignPhase33ARecommendation
        .blockedByUnsafePrototypeDesign;
  }
  if (ownerProofQueueCount > 0) {
    return DebugOnlyBridgePrototypeDesignPhase33ARecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (status == DebugOnlyBridgePrototypeDesignStatus.designReadyClean ||
      status == DebugOnlyBridgePrototypeDesignStatus.designReadyWithWarnings) {
    return DebugOnlyBridgePrototypeDesignPhase33ARecommendation
        .validateDebugOnlyBridgePrototypeDesign;
  }
  return DebugOnlyBridgePrototypeDesignPhase33ARecommendation
      .proceedToDebugBridgePrototypeDesignReportOnly;
}

int _countRole(
  Iterable<DebugOnlyBridgePrototypeDesignRecord> records,
  DebugOnlyBridgePrototypeDesignRole role,
) {
  return records.where((record) => record.designRole == role).length;
}

bool _hasExplicitPvProofReason(DebugOnlyBridgePrototypeDesignResult result) {
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
    'implementsRuntime': false,
    'implementsPrototypeExecution': false,
  };
}

Map<String, bool> _safePolicyFlagsFromGate(
  DebugBridgeReadinessValidationGateResult source,
) {
  return <String, bool>{
    'productOutputActive': source.productOutputActive,
    'classifierOutputActive': source.classifierOutputActive,
    'finalMoveLabelOutputActive': source.finalMoveLabelOutputActive,
    'officialMetricOutputActive': source.officialMetricOutputActive,
    'cpLossOutputActive': source.cpLossOutputActive,
    'winProbabilityOutputActive': source.winProbabilityOutputActive,
    'numericOutputActive': source.numericOutputActive,
    'aggregateScoreOutputActive': source.aggregateScoreOutputActive,
    'moveRankingOutputActive': source.moveRankingOutputActive,
    'quietPreparatoryScopeActivated': source.quietPreparatoryScopeActivated,
    'engineCallsActive': source.engineCallsActive,
    'persistenceWritesActive': source.persistenceWritesActive,
    'uiTargetsActive': source.uiTargetsActive,
    'backendOutputActive': source.backendOutputActive,
    'stockfishCommandFieldActive': source.stockfishCommandFieldActive,
    'rawUciFieldActive': source.rawUciFieldActive,
    'pvDumpFieldActive': source.pvDumpFieldActive,
    'runtimeImplementationActive': false,
    'executablePrototypeImplementationActive': false,
  };
}

List<String> _provenAndroidProofIds(GoldenAndroidProofEvidence? evidence) {
  return _sortedStrings(evidence?.targetCaseIds ?? const <String>[]);
}

int _compareFindings(
  DebugOnlyBridgePrototypeDesignFinding a,
  DebugOnlyBridgePrototypeDesignFinding b,
) {
  final severity = _severityRank(
    b.severity,
  ).compareTo(_severityRank(a.severity));
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.prototypeDesignRecordId ?? '').compareTo(
    b.prototypeDesignRecordId ?? '',
  );
}

int _severityRank(DebugOnlyBridgePrototypeDesignSeverity severity) {
  return switch (severity) {
    DebugOnlyBridgePrototypeDesignSeverity.warning => 1,
    DebugOnlyBridgePrototypeDesignSeverity.blocker => 2,
    DebugOnlyBridgePrototypeDesignSeverity.critical => 3,
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

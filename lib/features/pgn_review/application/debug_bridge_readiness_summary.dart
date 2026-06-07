/// Developer-only summary for debug bridge design readiness output.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_adapter_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/internal_adapter_readiness_summary_validation.dart';

const debugBridgeReadinessSummaryReportVersion =
    'debug-bridge-readiness-summary-v1';

enum DebugBridgeReadinessSummaryStatus {
  summarizedWithWarnings('summarizedWithWarnings'),
  summarizedClean('summarizedClean'),
  blockedByUnsafeReadiness('blockedByUnsafeReadiness'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const DebugBridgeReadinessSummaryStatus(this.wire);

  final String wire;
}

enum DebugBridgeReadinessSummaryGroupId {
  readyDebugCoreInputSummary('readyDebugCoreInputSummary'),
  constrainedDebugContextInputSummary('constrainedDebugContextInputSummary'),
  inactiveDebugBlockedInputSummary('inactiveDebugBlockedInputSummary'),
  inactiveDebugFutureOnlyInputSummary('inactiveDebugFutureOnlyInputSummary'),
  readyAllowedDebugFieldSummary('readyAllowedDebugFieldSummary'),
  deniedBlockedDebugFieldSummary('deniedBlockedDebugFieldSummary'),
  stockfishRawUciPvDumpBlockedSummary('stockfishRawUciPvDumpBlockedSummary'),
  androidProofBoundarySummary('androidProofBoundarySummary'),
  ownerProofStatusSummary('ownerProofStatusSummary');

  const DebugBridgeReadinessSummaryGroupId(this.wire);

  final String wire;
}

enum DebugBridgeReadinessSummaryItemStatus {
  readyDebugCoreInputSummary('readyDebugCoreInputSummary'),
  constrainedDebugContextInputSummary('constrainedDebugContextInputSummary'),
  inactiveDebugBlockedInputSummary('inactiveDebugBlockedInputSummary'),
  inactiveDebugFutureOnlyInputSummary('inactiveDebugFutureOnlyInputSummary'),
  readyAllowedDebugFieldSummary('readyAllowedDebugFieldSummary'),
  deniedBlockedDebugFieldSummary('deniedBlockedDebugFieldSummary'),
  stockfishRawUciPvDumpBlockedSummary('stockfishRawUciPvDumpBlockedSummary'),
  androidProofBoundarySummary('androidProofBoundarySummary'),
  ownerProofStatusSummary('ownerProofStatusSummary'),
  invalidSummary('invalidSummary'),
  unsafeSummary('unsafeSummary');

  const DebugBridgeReadinessSummaryItemStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == unsafeSummary;

  bool get isInvalid => this == invalidSummary;
}

enum DebugBridgeReadinessSummaryRole {
  readyDebugCoreInputSummaryRecord('readyDebugCoreInputSummaryRecord'),
  constrainedDebugContextInputSummaryRecord(
    'constrainedDebugContextInputSummaryRecord',
  ),
  inactiveDebugBlockedInputSummaryRecord(
    'inactiveDebugBlockedInputSummaryRecord',
  ),
  inactiveDebugFutureOnlyInputSummaryRecord(
    'inactiveDebugFutureOnlyInputSummaryRecord',
  ),
  readyAllowedDebugFieldSummaryRecord('readyAllowedDebugFieldSummaryRecord'),
  deniedBlockedDebugFieldSummaryRecord('deniedBlockedDebugFieldSummaryRecord'),
  stockfishRawUciPvDumpBlockedSummaryRecord(
    'stockfishRawUciPvDumpBlockedSummaryRecord',
  ),
  androidProofBoundarySummaryRecord('androidProofBoundarySummaryRecord'),
  ownerProofStatusSummaryRecord('ownerProofStatusSummaryRecord');

  const DebugBridgeReadinessSummaryRole(this.wire);

  final String wire;

  bool get isInactiveBoundary =>
      this == inactiveDebugBlockedInputSummaryRecord ||
      this == inactiveDebugFutureOnlyInputSummaryRecord ||
      this == deniedBlockedDebugFieldSummaryRecord ||
      this == stockfishRawUciPvDumpBlockedSummaryRecord;
}

enum DebugBridgeReadinessSummaryRecommendation {
  keepReadyDebugCoreForPrototypePlanning(
    'keepReadyDebugCoreForPrototypePlanning',
  ),
  keepDebugContextConstrained('keepDebugContextConstrained'),
  keepDebugBlockedInactive('keepDebugBlockedInactive'),
  keepDebugFutureOnlyInactive('keepDebugFutureOnlyInactive'),
  keepDebugFieldAllowed('keepDebugFieldAllowed'),
  keepDebugFieldDenied('keepDebugFieldDenied'),
  keepStockfishRawUciPvDumpBlocked('keepStockfishRawUciPvDumpBlocked'),
  summarizeAndroidProofBoundary('summarizeAndroidProofBoundary'),
  summarizeOwnerProofEmpty('summarizeOwnerProofEmpty'),
  investigateSummaryFailure('investigateSummaryFailure'),
  blockUnsafeBridgeSummary('blockUnsafeBridgeSummary');

  const DebugBridgeReadinessSummaryRecommendation(this.wire);

  final String wire;
}

enum DebugBridgeReadinessSummaryPhase32XRecommendation {
  proceedToDebugBridgeReadinessSummaryValidation(
    'proceedToDebugBridgeReadinessSummaryValidation',
  ),
  proceedToDebugOnlyBridgePrototypeDesign(
    'proceedToDebugOnlyBridgePrototypeDesign',
  ),
  proceedToDebugBridgeReadinessReportOnly(
    'proceedToDebugBridgeReadinessReportOnly',
  ),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeBridgeSummary('blockedByUnsafeBridgeSummary');

  const DebugBridgeReadinessSummaryPhase32XRecommendation(this.wire);

  final String wire;
}

enum DebugBridgeReadinessSummarySeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const DebugBridgeReadinessSummarySeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == DebugBridgeReadinessSummarySeverity.blocker ||
      this == DebugBridgeReadinessSummarySeverity.critical;

  bool get isCritical => this == DebugBridgeReadinessSummarySeverity.critical;
}

enum DebugBridgeReadinessSummaryReportFormat {
  markdown('markdown'),
  json('json');

  const DebugBridgeReadinessSummaryReportFormat(this.wire);

  final String wire;
}

class DebugBridgeReadinessSummaryRequest {
  const DebugBridgeReadinessSummaryRequest({
    this.readinessGateResult,
    this.validationResult,
    this.designResult,
    this.summaryValidationResult,
    this.summaryResult,
    this.readinessGate = const DebugBridgeDesignReadinessGate(),
    this.validation = const DebugOnlyAdapterBridgeDesignValidation(),
    this.design = const DebugOnlyAdapterBridgeDesign(),
    this.summaryValidation = const InternalAdapterReadinessSummaryValidation(),
    this.summary = const InternalAdapterReadinessSummary(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const DebugBridgeReadinessSummaryRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final DebugBridgeDesignReadinessGateResult? readinessGateResult;
  final DebugOnlyAdapterBridgeDesignValidationResult? validationResult;
  final DebugOnlyAdapterBridgeDesignResult? designResult;
  final InternalAdapterReadinessSummaryValidationResult?
  summaryValidationResult;
  final InternalAdapterReadinessSummaryResult? summaryResult;
  final DebugBridgeDesignReadinessGate readinessGate;
  final DebugOnlyAdapterBridgeDesignValidation validation;
  final DebugOnlyAdapterBridgeDesign design;
  final InternalAdapterReadinessSummaryValidation summaryValidation;
  final InternalAdapterReadinessSummary summary;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class DebugBridgeReadinessSummaryGroup {
  const DebugBridgeReadinessSummaryGroup({
    required this.groupId,
    required this.summaryStatus,
    required this.sourceReadinessGroupIds,
    required this.sourceReadinessRecordIds,
    required this.sourceBridgeRecordIds,
    required this.sourceBridgeGroupIds,
    required this.activeFieldIds,
    required this.deniedFieldIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.futurePrerequisites,
    required this.blockedBoundaryIds,
    required this.safeForNextPhase,
    required this.recommendation,
  });

  final DebugBridgeReadinessSummaryGroupId groupId;
  final DebugBridgeReadinessSummaryItemStatus summaryStatus;
  final List<DebugBridgeDesignReadinessGroupId> sourceReadinessGroupIds;
  final List<String> sourceReadinessRecordIds;
  final List<String> sourceBridgeRecordIds;
  final List<DebugOnlyAdapterBridgeInputGroupId> sourceBridgeGroupIds;
  final List<String> activeFieldIds;
  final List<String> deniedFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> futurePrerequisites;
  final List<String> blockedBoundaryIds;
  final bool safeForNextPhase;
  final DebugBridgeReadinessSummaryRecommendation recommendation;

  bool get hasUnsafeOutput =>
      summaryStatus.isUnsafe ||
      activeFieldIds.any(_isBlockedBridgeFieldId) ||
      activeFieldIds.any(_isLegacyBlockedOutputFieldId);

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'groupId': groupId.wire,
      'summaryStatus': summaryStatus.wire,
      'sourceReadinessGroupIds': sourceReadinessGroupIds
          .map((id) => id.wire)
          .toList(),
      'sourceReadinessRecordIds': sourceReadinessRecordIds,
      'sourceBridgeRecordIds': sourceBridgeRecordIds,
      'sourceBridgeGroupIds': sourceBridgeGroupIds
          .map((id) => id.wire)
          .toList(),
      'activeFieldIds': activeFieldIds,
      'deniedFieldIds': deniedFieldIds,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'futurePrerequisites': futurePrerequisites,
      'blockedBoundaryIds': blockedBoundaryIds,
      'safeForNextPhase': safeForNextPhase,
      'recommendation': recommendation.wire,
    };
  }
}

class DebugBridgeReadinessSummaryRecord {
  const DebugBridgeReadinessSummaryRecord({
    required this.summaryRecordId,
    required this.sourceReadinessRecordId,
    required this.sourceBridgeRecordId,
    required this.sourceBridgeGroupId,
    required this.summaryRole,
    required this.summaryStatus,
    required this.allowedForFutureDebugPrototypePlanning,
    required this.contextOnly,
    required this.inactive,
    required this.activeFieldIds,
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
  final String sourceReadinessRecordId;
  final String sourceBridgeRecordId;
  final DebugOnlyAdapterBridgeInputGroupId sourceBridgeGroupId;
  final DebugBridgeReadinessSummaryRole summaryRole;
  final DebugBridgeReadinessSummaryItemStatus summaryStatus;
  final bool allowedForFutureDebugPrototypePlanning;
  final bool contextOnly;
  final bool inactive;
  final List<String> activeFieldIds;
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
  final DebugBridgeReadinessSummaryRecommendation recommendation;

  bool get hasUnsafeOutput =>
      summaryStatus.isUnsafe ||
      activeFieldIds.any(_isBlockedBridgeFieldId) ||
      activeFieldIds.any(_isLegacyBlockedOutputFieldId) ||
      safetyFlags.values.any((value) => value);

  DebugBridgeReadinessSummaryRecord copyWith({
    String? summaryRecordId,
    String? sourceReadinessRecordId,
    String? sourceBridgeRecordId,
    DebugOnlyAdapterBridgeInputGroupId? sourceBridgeGroupId,
    DebugBridgeReadinessSummaryRole? summaryRole,
    DebugBridgeReadinessSummaryItemStatus? summaryStatus,
    bool? allowedForFutureDebugPrototypePlanning,
    bool? contextOnly,
    bool? inactive,
    List<String>? activeFieldIds,
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
    DebugBridgeReadinessSummaryRecommendation? recommendation,
  }) {
    return DebugBridgeReadinessSummaryRecord(
      summaryRecordId: summaryRecordId ?? this.summaryRecordId,
      sourceReadinessRecordId:
          sourceReadinessRecordId ?? this.sourceReadinessRecordId,
      sourceBridgeRecordId: sourceBridgeRecordId ?? this.sourceBridgeRecordId,
      sourceBridgeGroupId: sourceBridgeGroupId ?? this.sourceBridgeGroupId,
      summaryRole: summaryRole ?? this.summaryRole,
      summaryStatus: summaryStatus ?? this.summaryStatus,
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
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      futurePrerequisites: futurePrerequisites ?? this.futurePrerequisites,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      safetyFlags: safetyFlags ?? this.safetyFlags,
      violationReasons: violationReasons ?? this.violationReasons,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'summaryRecordId': summaryRecordId,
      'sourceReadinessRecordId': sourceReadinessRecordId,
      'sourceBridgeRecordId': sourceBridgeRecordId,
      'sourceBridgeGroupId': sourceBridgeGroupId.wire,
      'summaryRole': summaryRole.wire,
      'summaryStatus': summaryStatus.wire,
      'allowedForFutureDebugPrototypePlanning':
          allowedForFutureDebugPrototypePlanning,
      'contextOnly': contextOnly,
      'inactive': inactive,
      'activeFieldIds': activeFieldIds,
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
}

class DebugBridgeReadinessSummaryFinding {
  const DebugBridgeReadinessSummaryFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.summaryRecordId,
    this.summaryGroupId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final DebugBridgeReadinessSummarySeverity severity;
  final String message;
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
      if (summaryRecordId != null) 'summaryRecordId': summaryRecordId,
      if (summaryGroupId != null) 'summaryGroupId': summaryGroupId!.wire,
      if (fieldId != null) 'fieldId': fieldId,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class DebugBridgeReadinessSummaryResult {
  const DebugBridgeReadinessSummaryResult({
    required this.summaryStatus,
    required this.sourceReadinessStatus,
    required this.sourceValidationStatus,
    required this.sourceBridgeDesignStatus,
    required this.sourceSummaryValidationStatus,
    required this.sourceSummaryStatus,
    required this.summaryGroups,
    required this.summaryRecords,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalSummaryGroups,
    required this.totalSummaryRecords,
    required this.readyDebugCoreInputCount,
    required this.constrainedDebugContextInputCount,
    required this.inactiveBlockedInputCount,
    required this.inactiveFutureOnlyInputCount,
    required this.readyAllowedFieldCount,
    required this.deniedBlockedFieldCount,
    required this.unsafeCount,
    required this.blockerCount,
    required this.criticalCount,
    required this.ownerProofQueueCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.safeForPhase32X,
    required this.phase32XRecommendation,
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

  final DebugBridgeReadinessSummaryStatus summaryStatus;
  final DebugBridgeDesignReadinessGateStatus sourceReadinessStatus;
  final DebugOnlyAdapterBridgeDesignValidationStatus sourceValidationStatus;
  final DebugOnlyAdapterBridgeDesignStatus sourceBridgeDesignStatus;
  final InternalAdapterReadinessSummaryValidationStatus
  sourceSummaryValidationStatus;
  final InternalAdapterReadinessSummaryStatus sourceSummaryStatus;
  final List<DebugBridgeReadinessSummaryGroup> summaryGroups;
  final List<DebugBridgeReadinessSummaryRecord> summaryRecords;
  final List<DebugBridgeReadinessSummaryFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalSummaryGroups;
  final int totalSummaryRecords;
  final int readyDebugCoreInputCount;
  final int constrainedDebugContextInputCount;
  final int inactiveBlockedInputCount;
  final int inactiveFutureOnlyInputCount;
  final int readyAllowedFieldCount;
  final int deniedBlockedFieldCount;
  final int unsafeCount;
  final int blockerCount;
  final int criticalCount;
  final int ownerProofQueueCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final bool safeForPhase32X;
  final DebugBridgeReadinessSummaryPhase32XRecommendation
  phase32XRecommendation;
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
      summaryStatus ==
          DebugBridgeReadinessSummaryStatus.blockedByUnsafeReadiness ||
      summaryStatus ==
          DebugBridgeReadinessSummaryStatus.blockedByPolicyBoundary ||
      summaryStatus == DebugBridgeReadinessSummaryStatus.invalid ||
      !safeForPhase32X ||
      unsafeCount > 0 ||
      criticalCount > 0 ||
      blockerCount > 0 ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeDebugBridgeReadinessSummaryPolicyViolation {
    return summaryStatus ==
            DebugBridgeReadinessSummaryStatus.blockedByUnsafeReadiness ||
        summaryStatus ==
            DebugBridgeReadinessSummaryStatus.blockedByPolicyBoundary ||
        unsafeCount > 0 ||
        criticalCount > 0 ||
        summaryGroups.any((group) => group.hasUnsafeOutput) ||
        summaryRecords.any((record) => record.hasUnsafeOutput) ||
        validationFindings.any((finding) => finding.isCritical) ||
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

  DebugBridgeReadinessSummaryGroup group(
    DebugBridgeReadinessSummaryGroupId groupId,
  ) {
    return summaryGroups.singleWhere((group) => group.groupId == groupId);
  }

  DebugBridgeReadinessSummaryRecord recordForRole(
    DebugBridgeReadinessSummaryRole role,
  ) {
    return summaryRecords.singleWhere((record) => record.summaryRole == role);
  }

  List<DebugBridgeReadinessSummaryRecord> get readyDebugCoreRecords =>
      summaryRecords
          .where(
            (record) =>
                record.summaryRole ==
                DebugBridgeReadinessSummaryRole
                    .readyDebugCoreInputSummaryRecord,
          )
          .toList(growable: false);

  List<DebugBridgeReadinessSummaryRecord> get constrainedDebugContextRecords =>
      summaryRecords
          .where(
            (record) =>
                record.summaryRole ==
                DebugBridgeReadinessSummaryRole
                    .constrainedDebugContextInputSummaryRecord,
          )
          .toList(growable: false);

  List<DebugBridgeReadinessSummaryRecord> get inactiveBoundaryRecords =>
      summaryRecords
          .where((record) => record.summaryRole.isInactiveBoundary)
          .toList(growable: false);

  DebugBridgeReadinessSummaryResult copyWith({
    DebugBridgeReadinessSummaryStatus? summaryStatus,
    DebugBridgeDesignReadinessGateStatus? sourceReadinessStatus,
    DebugOnlyAdapterBridgeDesignValidationStatus? sourceValidationStatus,
    DebugOnlyAdapterBridgeDesignStatus? sourceBridgeDesignStatus,
    InternalAdapterReadinessSummaryValidationStatus?
    sourceSummaryValidationStatus,
    InternalAdapterReadinessSummaryStatus? sourceSummaryStatus,
    List<DebugBridgeReadinessSummaryGroup>? summaryGroups,
    List<DebugBridgeReadinessSummaryRecord>? summaryRecords,
    List<DebugBridgeReadinessSummaryFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalSummaryGroups,
    int? totalSummaryRecords,
    int? readyDebugCoreInputCount,
    int? constrainedDebugContextInputCount,
    int? inactiveBlockedInputCount,
    int? inactiveFutureOnlyInputCount,
    int? readyAllowedFieldCount,
    int? deniedBlockedFieldCount,
    int? unsafeCount,
    int? blockerCount,
    int? criticalCount,
    int? ownerProofQueueCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    bool? safeForPhase32X,
    DebugBridgeReadinessSummaryPhase32XRecommendation? phase32XRecommendation,
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
    return DebugBridgeReadinessSummaryResult(
      summaryStatus: summaryStatus ?? this.summaryStatus,
      sourceReadinessStatus:
          sourceReadinessStatus ?? this.sourceReadinessStatus,
      sourceValidationStatus:
          sourceValidationStatus ?? this.sourceValidationStatus,
      sourceBridgeDesignStatus:
          sourceBridgeDesignStatus ?? this.sourceBridgeDesignStatus,
      sourceSummaryValidationStatus:
          sourceSummaryValidationStatus ?? this.sourceSummaryValidationStatus,
      sourceSummaryStatus: sourceSummaryStatus ?? this.sourceSummaryStatus,
      summaryGroups: summaryGroups ?? this.summaryGroups,
      summaryRecords: summaryRecords ?? this.summaryRecords,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalSummaryGroups: totalSummaryGroups ?? this.totalSummaryGroups,
      totalSummaryRecords: totalSummaryRecords ?? this.totalSummaryRecords,
      readyDebugCoreInputCount:
          readyDebugCoreInputCount ?? this.readyDebugCoreInputCount,
      constrainedDebugContextInputCount:
          constrainedDebugContextInputCount ??
          this.constrainedDebugContextInputCount,
      inactiveBlockedInputCount:
          inactiveBlockedInputCount ?? this.inactiveBlockedInputCount,
      inactiveFutureOnlyInputCount:
          inactiveFutureOnlyInputCount ?? this.inactiveFutureOnlyInputCount,
      readyAllowedFieldCount:
          readyAllowedFieldCount ?? this.readyAllowedFieldCount,
      deniedBlockedFieldCount:
          deniedBlockedFieldCount ?? this.deniedBlockedFieldCount,
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
      safeForPhase32X: safeForPhase32X ?? this.safeForPhase32X,
      phase32XRecommendation:
          phase32XRecommendation ?? this.phase32XRecommendation,
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
      ..writeln('# Debug Bridge Readiness Summary')
      ..writeln()
      ..writeln('- version: $debugBridgeReadinessSummaryReportVersion')
      ..writeln('- summary status: ${summaryStatus.wire}')
      ..writeln('- source readiness status: ${sourceReadinessStatus.wire}')
      ..writeln('- total summary groups: $totalSummaryGroups')
      ..writeln('- total summary records: $totalSummaryRecords')
      ..writeln('- ready debug core input count: $readyDebugCoreInputCount')
      ..writeln(
        '- constrained debug context input count: $constrainedDebugContextInputCount',
      )
      ..writeln('- inactive blocked input count: $inactiveBlockedInputCount')
      ..writeln(
        '- inactive future-only input count: $inactiveFutureOnlyInputCount',
      )
      ..writeln('- ready allowed field count: $readyAllowedFieldCount')
      ..writeln('- denied blocked field count: $deniedBlockedFieldCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- safeForPhase32X: $safeForPhase32X')
      ..writeln('- Phase 32X recommendation: ${phase32XRecommendation.wire}')
      ..writeln()
      ..writeln('## Summary Group Table')
      ..writeln(
        '| Group | Status | Source records | Active fields | Denied fields | Safe | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
    for (final group in summaryGroups) {
      buffer.writeln(
        '| ${group.groupId.wire} | ${group.summaryStatus.wire} | ${_ids(group.sourceReadinessRecordIds)} | ${_ids(group.activeFieldIds)} | ${_ids(group.deniedFieldIds)} | ${group.safeForNextPhase} | ${group.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Summary Record Table')
      ..writeln(
        '| Record | Role | Status | Active fields | Denied fields | Prototype planning | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
    for (final record in summaryRecords) {
      buffer.writeln(
        '| ${_cell(record.summaryRecordId)} | ${record.summaryRole.wire} | ${record.summaryStatus.wire} | ${_ids(record.activeFieldIds)} | ${_ids(record.deniedFieldIds)} | ${record.allowedForFutureDebugPrototypePlanning} | ${record.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Ready Debug Core Summary');
    for (final record in readyDebugCoreRecords) {
      buffer.writeln(
        '- ${record.summaryRecordId}: ${record.summaryStatus.wire}; active fields: ${_ids(record.activeFieldIds)}',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Constrained Debug Context Summary');
    for (final record in constrainedDebugContextRecords) {
      buffer.writeln(
        '- ${record.summaryRecordId}: ${record.summaryStatus.wire}; contextOnly: ${record.contextOnly}',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Inactive Blocked/Future Summaries');
    for (final record in inactiveBoundaryRecords.where(
      (record) =>
          record.summaryRole ==
              DebugBridgeReadinessSummaryRole
                  .inactiveDebugBlockedInputSummaryRecord ||
          record.summaryRole ==
              DebugBridgeReadinessSummaryRole
                  .inactiveDebugFutureOnlyInputSummaryRecord,
    )) {
      buffer.writeln(
        '- ${record.summaryRecordId}: ${record.summaryStatus.wire}; inactive: ${record.inactive}',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Ready Allowed Field Summary')
      ..writeln('- allowed bridge fields: ${_ids(allowedFieldIds)}')
      ..writeln()
      ..writeln('## Denied Blocked Field Summary')
      ..writeln('- denied bridge fields: ${_ids(deniedFieldIds)}')
      ..writeln()
      ..writeln('## Stockfish Raw UCI PV Dump Blocked Summary')
      ..writeln(
        '- stockfishCommand blocked: ${deniedFieldIds.contains('stockfishCommand')}',
      )
      ..writeln('- rawUci blocked: ${deniedFieldIds.contains('rawUci')}')
      ..writeln('- pvDump blocked: ${deniedFieldIds.contains('pvDump')}')
      ..writeln()
      ..writeln('## Android Proof Boundary')
      ..writeln('- android proof IDs: ${_ids(androidProofCaseIds)}')
      ..writeln()
      ..writeln('## Owner Proof Status')
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
      ..writeln('## Phase 32X Recommendation')
      ..writeln('- ${phase32XRecommendation.wire}');
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': debugBridgeReadinessSummaryReportVersion,
      'summaryStatus': summaryStatus.wire,
      'sourceReadinessStatus': sourceReadinessStatus.wire,
      'sourceValidationStatus': sourceValidationStatus.wire,
      'sourceBridgeDesignStatus': sourceBridgeDesignStatus.wire,
      'sourceSummaryValidationStatus': sourceSummaryValidationStatus.wire,
      'sourceSummaryStatus': sourceSummaryStatus.wire,
      'totalSummaryGroups': totalSummaryGroups,
      'totalSummaryRecords': totalSummaryRecords,
      'readyDebugCoreInputCount': readyDebugCoreInputCount,
      'constrainedDebugContextInputCount': constrainedDebugContextInputCount,
      'inactiveBlockedInputCount': inactiveBlockedInputCount,
      'inactiveFutureOnlyInputCount': inactiveFutureOnlyInputCount,
      'readyAllowedFieldCount': readyAllowedFieldCount,
      'deniedBlockedFieldCount': deniedBlockedFieldCount,
      'unsafeCount': unsafeCount,
      'blockerCount': blockerCount,
      'criticalCount': criticalCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'allowedFieldIds': allowedFieldIds,
      'deniedFieldIds': deniedFieldIds,
      'safeForPhase32X': safeForPhase32X,
      'phase32XRecommendation': phase32XRecommendation.wire,
      'summaryGroups': summaryGroups.map((group) => group.toJson()).toList(),
      'summaryRecords': summaryRecords
          .map((record) => record.toJson())
          .toList(),
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

class DebugBridgeReadinessSummary {
  const DebugBridgeReadinessSummary({
    this.validator = const DebugBridgeReadinessSummaryValidator(),
  });

  final DebugBridgeReadinessSummaryValidator validator;

  DebugBridgeReadinessSummaryResult evaluate([
    DebugBridgeReadinessSummaryRequest request =
        const DebugBridgeReadinessSummaryRequest(),
  ]) {
    final summaryResult =
        request.summaryResult ??
        request.summary.evaluate(
          InternalAdapterReadinessSummaryRequest(
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
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final validationResult =
        request.validationResult ??
        request.validation.evaluate(
          DebugOnlyAdapterBridgeDesignValidationRequest(
            designResult: designResult,
            summaryValidationResult: summaryValidationResult,
            summaryResult: summaryResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final readinessGateResult =
        request.readinessGateResult ??
        request.readinessGate.evaluate(
          DebugBridgeDesignReadinessGateRequest(
            validationResult: validationResult,
            designResult: designResult,
            summaryValidationResult: summaryValidationResult,
            summaryResult: summaryResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final summaryGroups = _groupsFromReadiness(readinessGateResult);
    final summaryRecords = _recordsFromReadiness(readinessGateResult);
    final base = _resultFromGroupsAndRecords(
      readinessGateResult: readinessGateResult,
      validationResult: validationResult,
      designResult: designResult,
      summaryValidationResult: summaryValidationResult,
      summaryResult: summaryResult,
      summaryGroups: summaryGroups,
      summaryRecords: summaryRecords,
      validationFindings: const <DebugBridgeReadinessSummaryFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromGroupsAndRecords(
      readinessGateResult: readinessGateResult,
      validationResult: validationResult,
      designResult: designResult,
      summaryValidationResult: summaryValidationResult,
      summaryResult: summaryResult,
      summaryGroups: summaryGroups,
      summaryRecords: summaryRecords,
      validationFindings: findings,
    );
  }
}

class DebugBridgeReadinessSummaryValidator {
  const DebugBridgeReadinessSummaryValidator();

  List<DebugBridgeReadinessSummaryFinding> validate(
    DebugBridgeReadinessSummaryResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <DebugBridgeReadinessSummaryFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required DebugBridgeReadinessSummarySeverity severity,
      required String message,
      String? summaryRecordId,
      DebugBridgeReadinessSummaryGroupId? summaryGroupId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        DebugBridgeReadinessSummaryFinding(
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

    if (result.safeForPhase32X &&
        (result.sourceReadinessStatus ==
                DebugBridgeDesignReadinessGateStatus
                    .blockedByBridgeValidationFailure ||
            result.sourceReadinessStatus ==
                DebugBridgeDesignReadinessGateStatus.blockedByPolicyBoundary ||
            result.unsafeCount > 0)) {
      add(
        id: 'unsafeBridgeReadinessMarkedSummarized',
        severity: DebugBridgeReadinessSummarySeverity.critical,
        message: 'unsafe bridge readiness cannot be marked summarized',
      );
    }

    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: DebugBridgeReadinessSummarySeverity.blocker,
        message: 'owner proof requires explicit PV/MultiPV reason',
      );
    }

    for (final fieldId in _blockedBridgeFieldIds) {
      if (!result.deniedFieldIds.contains(fieldId)) {
        add(
          id: 'deniedBridgeFieldMissing',
          severity: DebugBridgeReadinessSummarySeverity.blocker,
          message: '$fieldId must remain denied in bridge summary',
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

    for (final group in result.summaryGroups) {
      for (final fieldId in group.activeFieldIds) {
        _checkActiveBridgeField(add, fieldId, summaryGroupId: group.groupId);
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
      for (final fieldId in record.activeFieldIds) {
        _checkActiveBridgeField(
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
      if (record.summaryRole ==
              DebugBridgeReadinessSummaryRole
                  .readyDebugCoreInputSummaryRecord &&
          record.violationReasons.contains('debugCoreConsumesNonCoreInput')) {
        add(
          id: 'debugCoreSummaryConsumesNonCoreInput',
          severity: DebugBridgeReadinessSummarySeverity.critical,
          message: 'debug core summary cannot consume non-core input',
          summaryRecordId: record.summaryRecordId,
        );
      }
      if (record.contextOnly &&
          record.summaryRole ==
              DebugBridgeReadinessSummaryRole
                  .readyDebugCoreInputSummaryRecord) {
        add(
          id: 'contextOnlySummaryPromotedToDebugCore',
          severity: DebugBridgeReadinessSummarySeverity.critical,
          message: 'context-only summary cannot become debug core summary',
          summaryRecordId: record.summaryRecordId,
        );
      }
      if (record.summaryRole.isInactiveBoundary &&
          !_recordIsInactiveSafe(record)) {
        add(
          id: 'blockedFutureSummaryMadeActive',
          severity: DebugBridgeReadinessSummarySeverity.critical,
          message: 'blocked/future/denied summary records must remain inactive',
          summaryRecordId: record.summaryRecordId,
        );
      }
      _checkSafetyFlags(add, record);
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
        id: 'debugBridgeReadinessSummaryBoundaryPolicyViolation',
        severity: DebugBridgeReadinessSummarySeverity.critical,
        message: 'debug bridge readiness summary crossed a blocked boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<DebugBridgeReadinessSummaryFinding> validateReportText(
    String reportText,
  ) {
    final findings = <DebugBridgeReadinessSummaryFinding>[];
    void reportError(String id, String message) {
      findings.add(
        DebugBridgeReadinessSummaryFinding(
          id: id,
          severity: DebugBridgeReadinessSummarySeverity.critical,
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

List<DebugBridgeReadinessSummaryGroup> _groupsFromReadiness(
  DebugBridgeDesignReadinessGateResult readinessResult,
) {
  final deniedFields = _sortedStrings(readinessResult.blockedFieldIds);
  return <DebugBridgeReadinessSummaryGroup>[
    _groupFromReadinessGroup(
      readinessResult,
      DebugBridgeDesignReadinessGroupId.readyDebugCoreInputGroup,
      DebugBridgeReadinessSummaryGroupId.readyDebugCoreInputSummary,
      DebugBridgeReadinessSummaryItemStatus.readyDebugCoreInputSummary,
      DebugBridgeReadinessSummaryRecommendation
          .keepReadyDebugCoreForPrototypePlanning,
    ),
    _groupFromReadinessGroup(
      readinessResult,
      DebugBridgeDesignReadinessGroupId.constrainedDebugContextInputGroup,
      DebugBridgeReadinessSummaryGroupId.constrainedDebugContextInputSummary,
      DebugBridgeReadinessSummaryItemStatus.constrainedDebugContextInputSummary,
      DebugBridgeReadinessSummaryRecommendation.keepDebugContextConstrained,
    ),
    _groupFromReadinessGroup(
      readinessResult,
      DebugBridgeDesignReadinessGroupId.inactiveDebugBlockedInputGroup,
      DebugBridgeReadinessSummaryGroupId.inactiveDebugBlockedInputSummary,
      DebugBridgeReadinessSummaryItemStatus.inactiveDebugBlockedInputSummary,
      DebugBridgeReadinessSummaryRecommendation.keepDebugBlockedInactive,
    ),
    _groupFromReadinessGroup(
      readinessResult,
      DebugBridgeDesignReadinessGroupId.inactiveDebugFutureOnlyInputGroup,
      DebugBridgeReadinessSummaryGroupId.inactiveDebugFutureOnlyInputSummary,
      DebugBridgeReadinessSummaryItemStatus.inactiveDebugFutureOnlyInputSummary,
      DebugBridgeReadinessSummaryRecommendation.keepDebugFutureOnlyInactive,
    ),
    _groupFromReadinessGroup(
      readinessResult,
      DebugBridgeDesignReadinessGroupId.readyAllowedDebugFieldGroup,
      DebugBridgeReadinessSummaryGroupId.readyAllowedDebugFieldSummary,
      DebugBridgeReadinessSummaryItemStatus.readyAllowedDebugFieldSummary,
      DebugBridgeReadinessSummaryRecommendation.keepDebugFieldAllowed,
    ),
    _groupFromReadinessGroup(
      readinessResult,
      DebugBridgeDesignReadinessGroupId.deniedBlockedDebugFieldGroup,
      DebugBridgeReadinessSummaryGroupId.deniedBlockedDebugFieldSummary,
      DebugBridgeReadinessSummaryItemStatus.deniedBlockedDebugFieldSummary,
      DebugBridgeReadinessSummaryRecommendation.keepDebugFieldDenied,
    ),
    _stockfishBlockedGroup(readinessResult, deniedFields),
    _groupFromReadinessGroup(
      readinessResult,
      DebugBridgeDesignReadinessGroupId.validatedProofBoundaryGroup,
      DebugBridgeReadinessSummaryGroupId.androidProofBoundarySummary,
      DebugBridgeReadinessSummaryItemStatus.androidProofBoundarySummary,
      DebugBridgeReadinessSummaryRecommendation.summarizeAndroidProofBoundary,
    ),
    _groupFromReadinessGroup(
      readinessResult,
      DebugBridgeDesignReadinessGroupId.emptyOwnerProofStatusGroup,
      DebugBridgeReadinessSummaryGroupId.ownerProofStatusSummary,
      DebugBridgeReadinessSummaryItemStatus.ownerProofStatusSummary,
      DebugBridgeReadinessSummaryRecommendation.summarizeOwnerProofEmpty,
    ),
  ];
}

DebugBridgeReadinessSummaryGroup _groupFromReadinessGroup(
  DebugBridgeDesignReadinessGateResult readinessResult,
  DebugBridgeDesignReadinessGroupId sourceGroupId,
  DebugBridgeReadinessSummaryGroupId summaryGroupId,
  DebugBridgeReadinessSummaryItemStatus validStatus,
  DebugBridgeReadinessSummaryRecommendation recommendation,
) {
  final sourceGroup = readinessResult.group(sourceGroupId);
  final records = readinessResult.readinessRecords
      .where(
        (record) => sourceGroup.sourceBridgeRecordIds.contains(
          record.sourceBridgeRecordId,
        ),
      )
      .toList(growable: false);
  final unsafe = sourceGroup.hasUnsafeOutput;
  final invalid =
      !unsafe &&
      (!sourceGroup.safeForFutureDebugPrototype ||
          sourceGroup.readinessStatus.isInvalid);
  final status = unsafe
      ? DebugBridgeReadinessSummaryItemStatus.unsafeSummary
      : invalid
      ? DebugBridgeReadinessSummaryItemStatus.invalidSummary
      : validStatus;
  return DebugBridgeReadinessSummaryGroup(
    groupId: summaryGroupId,
    summaryStatus: status,
    sourceReadinessGroupIds: <DebugBridgeDesignReadinessGroupId>[
      sourceGroup.groupId,
    ],
    sourceReadinessRecordIds: _sortedStrings(
      records.map((record) => record.readinessRecordId),
    ),
    sourceBridgeRecordIds: _sortedStrings(sourceGroup.sourceBridgeRecordIds),
    sourceBridgeGroupIds: _sortedBridgeGroupIds(
      records.map((record) => record.sourceBridgeGroupId),
    ),
    activeFieldIds: _sortedStrings(sourceGroup.activeFieldIds),
    deniedFieldIds: _sortedStrings(sourceGroup.blockedFieldIds),
    supportCaseIds: _sortedStrings(sourceGroup.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(
      sourceGroup.newlyAddedSupportCaseIds,
    ),
    androidProofCaseIds: _sortedStrings(sourceGroup.androidProofCaseIds),
    warningReasons: _sortedStrings(sourceGroup.warningReasons),
    proofLimitReasons: _sortedStrings(sourceGroup.proofLimitReasons),
    futurePrerequisites: _sortedStrings(sourceGroup.futurePrerequisites),
    blockedBoundaryIds: _sortedStrings(sourceGroup.blockedBoundaryIds),
    safeForNextPhase: !unsafe && !invalid,
    recommendation: unsafe
        ? DebugBridgeReadinessSummaryRecommendation.blockUnsafeBridgeSummary
        : invalid
        ? DebugBridgeReadinessSummaryRecommendation.investigateSummaryFailure
        : recommendation,
  );
}

DebugBridgeReadinessSummaryGroup _stockfishBlockedGroup(
  DebugBridgeDesignReadinessGateResult readinessResult,
  List<String> deniedFields,
) {
  final source = readinessResult.group(
    DebugBridgeDesignReadinessGroupId.deniedBlockedDebugFieldGroup,
  );
  final record = readinessResult.recordForRole(
    DebugBridgeDesignReadinessRole.deniedBlockedDebugField,
  );
  final stockfishDenied = _sortedStrings(
    _engineDumpFieldIds.where(deniedFields.contains),
  );
  final unsafe = source.hasUnsafeOutput || stockfishDenied.length != 3;
  return DebugBridgeReadinessSummaryGroup(
    groupId:
        DebugBridgeReadinessSummaryGroupId.stockfishRawUciPvDumpBlockedSummary,
    summaryStatus: unsafe
        ? DebugBridgeReadinessSummaryItemStatus.unsafeSummary
        : DebugBridgeReadinessSummaryItemStatus
              .stockfishRawUciPvDumpBlockedSummary,
    sourceReadinessGroupIds: <DebugBridgeDesignReadinessGroupId>[
      source.groupId,
    ],
    sourceReadinessRecordIds: <String>[record.readinessRecordId],
    sourceBridgeRecordIds: <String>[record.sourceBridgeRecordId],
    sourceBridgeGroupIds: <DebugOnlyAdapterBridgeInputGroupId>[
      record.sourceBridgeGroupId,
    ],
    activeFieldIds: const <String>[],
    deniedFieldIds: stockfishDenied,
    supportCaseIds: const <String>[],
    newlyAddedSupportCaseIds: const <String>[],
    androidProofCaseIds: const <String>[],
    warningReasons: const <String>[
      'Stockfish command, raw UCI, and PV dump fields remain denied',
    ],
    proofLimitReasons: const <String>[],
    futurePrerequisites: const <String>[],
    blockedBoundaryIds: stockfishDenied,
    safeForNextPhase: !unsafe,
    recommendation: unsafe
        ? DebugBridgeReadinessSummaryRecommendation.blockUnsafeBridgeSummary
        : DebugBridgeReadinessSummaryRecommendation
              .keepStockfishRawUciPvDumpBlocked,
  );
}

List<DebugBridgeReadinessSummaryRecord> _recordsFromReadiness(
  DebugBridgeDesignReadinessGateResult readinessResult,
) {
  final deniedFields = _sortedStrings(readinessResult.blockedFieldIds);
  return <DebugBridgeReadinessSummaryRecord>[
    _recordFromReadinessRecord(
      readinessResult.recordForRole(
        DebugBridgeDesignReadinessRole.readyDebugCoreInput,
      ),
      DebugBridgeReadinessSummaryRole.readyDebugCoreInputSummaryRecord,
      DebugBridgeReadinessSummaryItemStatus.readyDebugCoreInputSummary,
      DebugBridgeReadinessSummaryRecommendation
          .keepReadyDebugCoreForPrototypePlanning,
      allowedForFutureDebugPrototypePlanning: true,
      contextOnly: false,
      inactive: false,
    ),
    _recordFromReadinessRecord(
      readinessResult.recordForRole(
        DebugBridgeDesignReadinessRole.constrainedDebugContextInput,
      ),
      DebugBridgeReadinessSummaryRole.constrainedDebugContextInputSummaryRecord,
      DebugBridgeReadinessSummaryItemStatus.constrainedDebugContextInputSummary,
      DebugBridgeReadinessSummaryRecommendation.keepDebugContextConstrained,
      allowedForFutureDebugPrototypePlanning: false,
      contextOnly: true,
      inactive: false,
    ),
    _recordFromReadinessRecord(
      readinessResult.recordForRole(
        DebugBridgeDesignReadinessRole.inactiveDebugBlockedInput,
      ),
      DebugBridgeReadinessSummaryRole.inactiveDebugBlockedInputSummaryRecord,
      DebugBridgeReadinessSummaryItemStatus.inactiveDebugBlockedInputSummary,
      DebugBridgeReadinessSummaryRecommendation.keepDebugBlockedInactive,
      allowedForFutureDebugPrototypePlanning: false,
      contextOnly: false,
      inactive: true,
    ),
    _recordFromReadinessRecord(
      readinessResult.recordForRole(
        DebugBridgeDesignReadinessRole.inactiveDebugFutureOnlyInput,
      ),
      DebugBridgeReadinessSummaryRole.inactiveDebugFutureOnlyInputSummaryRecord,
      DebugBridgeReadinessSummaryItemStatus.inactiveDebugFutureOnlyInputSummary,
      DebugBridgeReadinessSummaryRecommendation.keepDebugFutureOnlyInactive,
      allowedForFutureDebugPrototypePlanning: false,
      contextOnly: false,
      inactive: true,
    ),
    _recordFromReadinessRecord(
      readinessResult.recordForRole(
        DebugBridgeDesignReadinessRole.readyAllowedDebugField,
      ),
      DebugBridgeReadinessSummaryRole.readyAllowedDebugFieldSummaryRecord,
      DebugBridgeReadinessSummaryItemStatus.readyAllowedDebugFieldSummary,
      DebugBridgeReadinessSummaryRecommendation.keepDebugFieldAllowed,
      allowedForFutureDebugPrototypePlanning: true,
      contextOnly: false,
      inactive: false,
    ),
    _recordFromReadinessRecord(
      readinessResult.recordForRole(
        DebugBridgeDesignReadinessRole.deniedBlockedDebugField,
      ),
      DebugBridgeReadinessSummaryRole.deniedBlockedDebugFieldSummaryRecord,
      DebugBridgeReadinessSummaryItemStatus.deniedBlockedDebugFieldSummary,
      DebugBridgeReadinessSummaryRecommendation.keepDebugFieldDenied,
      allowedForFutureDebugPrototypePlanning: false,
      contextOnly: false,
      inactive: true,
    ),
    _stockfishBlockedRecord(readinessResult, deniedFields),
    _recordFromReadinessRecord(
      readinessResult.recordForRole(
        DebugBridgeDesignReadinessRole.validatedProofBoundary,
      ),
      DebugBridgeReadinessSummaryRole.androidProofBoundarySummaryRecord,
      DebugBridgeReadinessSummaryItemStatus.androidProofBoundarySummary,
      DebugBridgeReadinessSummaryRecommendation.summarizeAndroidProofBoundary,
      allowedForFutureDebugPrototypePlanning: true,
      contextOnly: false,
      inactive: false,
    ),
    _recordFromReadinessRecord(
      readinessResult.recordForRole(
        DebugBridgeDesignReadinessRole.emptyOwnerProofStatus,
      ),
      DebugBridgeReadinessSummaryRole.ownerProofStatusSummaryRecord,
      DebugBridgeReadinessSummaryItemStatus.ownerProofStatusSummary,
      DebugBridgeReadinessSummaryRecommendation.summarizeOwnerProofEmpty,
      allowedForFutureDebugPrototypePlanning: true,
      contextOnly: false,
      inactive: false,
    ),
  ];
}

DebugBridgeReadinessSummaryRecord _recordFromReadinessRecord(
  DebugBridgeDesignReadinessRecord source,
  DebugBridgeReadinessSummaryRole summaryRole,
  DebugBridgeReadinessSummaryItemStatus validStatus,
  DebugBridgeReadinessSummaryRecommendation recommendation, {
  required bool allowedForFutureDebugPrototypePlanning,
  required bool contextOnly,
  required bool inactive,
}) {
  final unsafe = source.hasUnsafeOutput;
  final invalid =
      !unsafe &&
      (source.readinessStatus.isInvalid || source.violationReasons.isNotEmpty);
  final status = unsafe
      ? DebugBridgeReadinessSummaryItemStatus.unsafeSummary
      : invalid
      ? DebugBridgeReadinessSummaryItemStatus.invalidSummary
      : validStatus;
  return DebugBridgeReadinessSummaryRecord(
    summaryRecordId: 'debug-summary-${source.readinessRecordId}',
    sourceReadinessRecordId: source.readinessRecordId,
    sourceBridgeRecordId: source.sourceBridgeRecordId,
    sourceBridgeGroupId: source.sourceBridgeGroupId,
    summaryRole: summaryRole,
    summaryStatus: status,
    allowedForFutureDebugPrototypePlanning:
        allowedForFutureDebugPrototypePlanning,
    contextOnly: contextOnly,
    inactive: inactive,
    activeFieldIds: _sortedStrings(source.activeFieldIds),
    deniedFieldIds: _sortedStrings(source.blockedFieldIds),
    supportCaseIds: _sortedStrings(source.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(source.newlyAddedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(source.androidProofCaseIds),
    warningReasons: _sortedStrings(source.warningReasons),
    proofLimitReasons: _sortedStrings(source.proofLimitReasons),
    futurePrerequisites: _sortedStrings(source.futurePrerequisites),
    blockedBoundaryIds: _sortedStrings(source.blockedBoundaryIds),
    safetyFlags: _safetyFlagsFrom(source),
    violationReasons: _sortedStrings(source.violationReasons),
    recommendation: unsafe
        ? DebugBridgeReadinessSummaryRecommendation.blockUnsafeBridgeSummary
        : invalid
        ? DebugBridgeReadinessSummaryRecommendation.investigateSummaryFailure
        : recommendation,
  );
}

DebugBridgeReadinessSummaryRecord _stockfishBlockedRecord(
  DebugBridgeDesignReadinessGateResult readinessResult,
  List<String> deniedFields,
) {
  final source = readinessResult.recordForRole(
    DebugBridgeDesignReadinessRole.deniedBlockedDebugField,
  );
  final stockfishDenied = _sortedStrings(
    _engineDumpFieldIds.where(deniedFields.contains),
  );
  final unsafe = source.hasUnsafeOutput || stockfishDenied.length != 3;
  return DebugBridgeReadinessSummaryRecord(
    summaryRecordId: 'debug-summary-stockfish-raw-uci-pv-dump-blocked',
    sourceReadinessRecordId: source.readinessRecordId,
    sourceBridgeRecordId: source.sourceBridgeRecordId,
    sourceBridgeGroupId: source.sourceBridgeGroupId,
    summaryRole: DebugBridgeReadinessSummaryRole
        .stockfishRawUciPvDumpBlockedSummaryRecord,
    summaryStatus: unsafe
        ? DebugBridgeReadinessSummaryItemStatus.unsafeSummary
        : DebugBridgeReadinessSummaryItemStatus
              .stockfishRawUciPvDumpBlockedSummary,
    allowedForFutureDebugPrototypePlanning: false,
    contextOnly: false,
    inactive: true,
    activeFieldIds: const <String>[],
    deniedFieldIds: stockfishDenied,
    supportCaseIds: const <String>[],
    newlyAddedSupportCaseIds: const <String>[],
    androidProofCaseIds: const <String>[],
    warningReasons: const <String>[
      'Stockfish command, raw UCI, and PV dump fields remain denied',
    ],
    proofLimitReasons: const <String>[],
    futurePrerequisites: const <String>[],
    blockedBoundaryIds: stockfishDenied,
    safetyFlags: _safeFlags(),
    violationReasons: unsafe
        ? const <String>['stockfishRawUciPvDumpNotDenied']
        : const <String>[],
    recommendation: unsafe
        ? DebugBridgeReadinessSummaryRecommendation.blockUnsafeBridgeSummary
        : DebugBridgeReadinessSummaryRecommendation
              .keepStockfishRawUciPvDumpBlocked,
  );
}

DebugBridgeReadinessSummaryResult _resultFromGroupsAndRecords({
  required DebugBridgeDesignReadinessGateResult readinessGateResult,
  required DebugOnlyAdapterBridgeDesignValidationResult validationResult,
  required DebugOnlyAdapterBridgeDesignResult designResult,
  required InternalAdapterReadinessSummaryValidationResult
  summaryValidationResult,
  required InternalAdapterReadinessSummaryResult summaryResult,
  required List<DebugBridgeReadinessSummaryGroup> summaryGroups,
  required List<DebugBridgeReadinessSummaryRecord> summaryRecords,
  required List<DebugBridgeReadinessSummaryFinding> validationFindings,
}) {
  final unsafeCount =
      summaryGroups.where((group) => group.hasUnsafeOutput).length +
      summaryRecords.where((record) => record.hasUnsafeOutput).length +
      readinessGateResult.unsafeCount;
  final blockerCount = validationFindings
      .where((finding) => finding.severity.blocksStrict)
      .length;
  final criticalCount = validationFindings
      .where((finding) => finding.isCritical)
      .length;
  final base = DebugBridgeReadinessSummaryResult(
    summaryStatus: DebugBridgeReadinessSummaryStatus.invalid,
    sourceReadinessStatus: readinessGateResult.readinessStatus,
    sourceValidationStatus: validationResult.validationStatus,
    sourceBridgeDesignStatus: designResult.designStatus,
    sourceSummaryValidationStatus: summaryValidationResult.validationStatus,
    sourceSummaryStatus: summaryResult.summaryStatus,
    summaryGroups: summaryGroups,
    summaryRecords: summaryRecords,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...readinessGateResult.warnings,
      if (summaryRecords.any((record) => record.contextOnly))
        'debug context summary remains context-only',
      if (summaryRecords.any((record) => record.inactive))
        'debug blocked/future summaries remain inactive',
      if (readinessGateResult.ownerProofQueueCount == 0)
        'owner proof summary remains empty',
      'debug bridge runtime remains unimplemented',
      'debug bridge prototype remains unimplemented',
    ]),
    failures: _sortedStrings(<String>[
      ...readinessGateResult.failures,
      ...validationFindings.map((finding) => finding.message),
      ...summaryGroups.expand(
        (group) => group.hasUnsafeOutput
            ? <String>['unsafe summary group']
            : const <String>[],
      ),
      ...summaryRecords.expand((record) => record.violationReasons),
    ]),
    totalSummaryGroups: summaryGroups.length,
    totalSummaryRecords: summaryRecords.length,
    readyDebugCoreInputCount: _countRecords(
      summaryRecords,
      DebugBridgeReadinessSummaryItemStatus.readyDebugCoreInputSummary,
    ),
    constrainedDebugContextInputCount: _countRecords(
      summaryRecords,
      DebugBridgeReadinessSummaryItemStatus.constrainedDebugContextInputSummary,
    ),
    inactiveBlockedInputCount: _countRecords(
      summaryRecords,
      DebugBridgeReadinessSummaryItemStatus.inactiveDebugBlockedInputSummary,
    ),
    inactiveFutureOnlyInputCount: _countRecords(
      summaryRecords,
      DebugBridgeReadinessSummaryItemStatus.inactiveDebugFutureOnlyInputSummary,
    ),
    readyAllowedFieldCount: readinessGateResult.allowedFieldIds.length,
    deniedBlockedFieldCount: readinessGateResult.blockedFieldIds.length,
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
    deniedFieldIds: _sortedStrings(readinessGateResult.blockedFieldIds),
    safeForPhase32X: false,
    phase32XRecommendation: DebugBridgeReadinessSummaryPhase32XRecommendation
        .addMoreGoldenCoverageFirst,
    developerOnly:
        readinessGateResult.developerOnly &&
        validationResult.developerOnly &&
        designResult.developerOnly &&
        summaryValidationResult.developerOnly &&
        summaryResult.developerOnly,
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
  final safeForPhase32X =
      (status == DebugBridgeReadinessSummaryStatus.summarizedWithWarnings ||
          status == DebugBridgeReadinessSummaryStatus.summarizedClean) &&
      readinessGateResult.safeForPhase32W &&
      !readinessGateResult.isStrictlyBlocked &&
      !readinessGateResult.hasUnsafeDebugBridgeReadinessPolicyViolation &&
      unsafeCount == 0 &&
      blockerCount == 0 &&
      criticalCount == 0 &&
      validationFindings.every((finding) => !finding.blocksStrict) &&
      summaryGroups.every((group) => group.safeForNextPhase) &&
      summaryRecords.every(
        (record) =>
            !record.hasUnsafeOutput &&
            record.summaryStatus !=
                DebugBridgeReadinessSummaryItemStatus.invalidSummary,
      );
  return base.copyWith(
    summaryStatus: status,
    safeForPhase32X: safeForPhase32X,
    phase32XRecommendation: _phase32XRecommendationFor(
      status: status,
      safeForPhase32X: safeForPhase32X,
      ownerProofQueueCount: readinessGateResult.ownerProofQueueCount,
    ),
  );
}

DebugBridgeReadinessSummaryStatus _summaryStatusFor(
  DebugBridgeReadinessSummaryResult result, {
  required DebugBridgeDesignReadinessGateResult readinessGateResult,
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
    return DebugBridgeReadinessSummaryStatus.blockedByPolicyBoundary;
  }
  if (readinessGateResult.readinessStatus ==
          DebugBridgeDesignReadinessGateStatus
              .blockedByBridgeValidationFailure ||
      readinessGateResult.readinessStatus ==
          DebugBridgeDesignReadinessGateStatus.blockedByPolicyBoundary ||
      readinessGateResult.unsafeCount > 0 ||
      readinessGateResult.criticalCount > 0 ||
      readinessGateResult.hasUnsafeDebugBridgeReadinessPolicyViolation ||
      result.unsafeCount > 0 ||
      result.criticalCount > 0) {
    return DebugBridgeReadinessSummaryStatus.blockedByUnsafeReadiness;
  }
  if (!readinessGateResult.safeForPhase32W ||
      readinessGateResult.isStrictlyBlocked ||
      result.blockerCount > 0 ||
      result.validationFindings.any((finding) => finding.blocksStrict) ||
      result.summaryRecords.any(
        (record) =>
            record.summaryStatus ==
            DebugBridgeReadinessSummaryItemStatus.invalidSummary,
      ) ||
      result.summaryGroups.any((group) => !group.safeForNextPhase)) {
    return DebugBridgeReadinessSummaryStatus.invalid;
  }
  if (result.summaryGroups.isEmpty || result.summaryRecords.isEmpty) {
    return DebugBridgeReadinessSummaryStatus.invalid;
  }
  if (result.constrainedDebugContextInputCount > 0 ||
      result.inactiveBlockedInputCount > 0 ||
      result.inactiveFutureOnlyInputCount > 0 ||
      result.warnings.isNotEmpty) {
    return DebugBridgeReadinessSummaryStatus.summarizedWithWarnings;
  }
  return DebugBridgeReadinessSummaryStatus.summarizedClean;
}

DebugBridgeReadinessSummaryPhase32XRecommendation _phase32XRecommendationFor({
  required DebugBridgeReadinessSummaryStatus status,
  required bool safeForPhase32X,
  required int ownerProofQueueCount,
}) {
  if (status == DebugBridgeReadinessSummaryStatus.blockedByUnsafeReadiness ||
      status == DebugBridgeReadinessSummaryStatus.blockedByPolicyBoundary) {
    return DebugBridgeReadinessSummaryPhase32XRecommendation
        .blockedByUnsafeBridgeSummary;
  }
  if (ownerProofQueueCount > 0) {
    return DebugBridgeReadinessSummaryPhase32XRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase32X) {
    return DebugBridgeReadinessSummaryPhase32XRecommendation
        .addMoreGoldenCoverageFirst;
  }
  return DebugBridgeReadinessSummaryPhase32XRecommendation
      .proceedToDebugBridgeReadinessSummaryValidation;
}

Map<String, bool> _safetyFlagsFrom(DebugBridgeDesignReadinessRecord record) {
  return <String, bool>{
    'isProductOutput': record.safetyFlags['isProductOutput'] ?? false,
    'isClassifierLabel': record.safetyFlags['isClassifierLabel'] ?? false,
    'hasNumericScore': record.safetyFlags['hasNumericScore'] ?? false,
    'hasAggregateScore': record.safetyFlags['hasAggregateScore'] ?? false,
    'ranksMoves': record.safetyFlags['ranksMoves'] ?? false,
    'isOfficialMetric': record.safetyFlags['isOfficialMetric'] ?? false,
    'exposesCpLoss': record.safetyFlags['exposesCpLoss'] ?? false,
    'exposesWinProbability':
        record.safetyFlags['exposesWinProbability'] ?? false,
    'exposesStockfishCommand':
        record.safetyFlags['exposesStockfishCommand'] ?? false,
    'exposesRawUci': record.safetyFlags['exposesRawUci'] ?? false,
    'exposesPvDump': record.safetyFlags['exposesPvDump'] ?? false,
    'callsEngine': record.safetyFlags['callsEngine'] ?? false,
    'writesPersistence': record.safetyFlags['writesPersistence'] ?? false,
    'targetsUi': record.safetyFlags['targetsUi'] ?? false,
    'backendOutputActive': record.safetyFlags['backendOutputActive'] ?? false,
    'quietPreparatoryScopeActive':
        record.safetyFlags['quietPreparatoryScopeActive'] ?? false,
  };
}

Map<String, bool> _safeFlags() {
  return <String, bool>{
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
  };
}

void _checkSafetyFlags(
  void Function({
    required String id,
    required DebugBridgeReadinessSummarySeverity severity,
    required String message,
    String? summaryRecordId,
    DebugBridgeReadinessSummaryGroupId? summaryGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugBridgeReadinessSummaryRecord record,
) {
  void critical(String id, String message) {
    add(
      id: id,
      severity: DebugBridgeReadinessSummarySeverity.critical,
      message: message,
      summaryRecordId: record.summaryRecordId,
    );
  }

  if (record.safetyFlags['isProductOutput'] == true) {
    critical('productOutputActive', 'bridge summary cannot be product output');
  }
  if (record.safetyFlags['isClassifierLabel'] == true) {
    critical(
      'classifierLabelOutputActive',
      'bridge summary cannot emit classifier labels',
    );
  }
  if (record.safetyFlags['hasNumericScore'] == true) {
    critical(
      'numericScoreOutputActive',
      'bridge summary cannot emit numeric scores',
    );
  }
  if (record.safetyFlags['hasAggregateScore'] == true) {
    critical(
      'aggregateScoreOutputActive',
      'bridge summary cannot emit aggregate scores',
    );
  }
  if (record.safetyFlags['ranksMoves'] == true) {
    critical('moveRankingOutputActive', 'bridge summary cannot rank moves');
  }
  if (record.safetyFlags['isOfficialMetric'] == true) {
    critical(
      'officialMetricOutputActive',
      'bridge summary cannot emit official metrics',
    );
  }
  if (record.safetyFlags['exposesCpLoss'] == true ||
      record.safetyFlags['exposesWinProbability'] == true) {
    critical(
      'futureMetricOutputActive',
      'bridge summary cannot expose CP-loss or win probability',
    );
  }
  if (record.safetyFlags['quietPreparatoryScopeActive'] == true) {
    critical(
      'quietPreparatoryScopeActivated',
      'quiet/preparatory scope must remain excluded',
    );
  }
  if (record.safetyFlags['callsEngine'] == true) {
    critical('engineCallFlagActive', 'bridge summary cannot call an engine');
  }
  if (record.safetyFlags['writesPersistence'] == true) {
    critical(
      'persistenceWriteFlagActive',
      'bridge summary cannot write persistence',
    );
  }
  if (record.safetyFlags['targetsUi'] == true) {
    critical('uiTargetFlagActive', 'bridge summary cannot target UI');
  }
  if (record.safetyFlags['backendOutputActive'] == true) {
    critical('backendOutputActive', 'bridge summary cannot target backend');
  }
  if (record.safetyFlags['exposesStockfishCommand'] == true ||
      record.safetyFlags['exposesRawUci'] == true ||
      record.safetyFlags['exposesPvDump'] == true) {
    critical(
      'stockfishRawUciPvDumpFieldActive',
      'Stockfish command, raw UCI, and PV dump fields must remain blocked',
    );
  }
}

void _checkActiveBridgeField(
  void Function({
    required String id,
    required DebugBridgeReadinessSummarySeverity severity,
    required String message,
    String? summaryRecordId,
    DebugBridgeReadinessSummaryGroupId? summaryGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String fieldId, {
  String? summaryRecordId,
  DebugBridgeReadinessSummaryGroupId? summaryGroupId,
}) {
  if (_isBlockedBridgeFieldId(fieldId) ||
      _isLegacyBlockedOutputFieldId(fieldId)) {
    add(
      id: 'activeDeniedBridgeField',
      severity: DebugBridgeReadinessSummarySeverity.critical,
      message: '$fieldId cannot be active bridge summary output',
      summaryRecordId: summaryRecordId,
      summaryGroupId: summaryGroupId,
      fieldId: fieldId,
    );
  }
}

void _checkAndroidProofCase(
  void Function({
    required String id,
    required DebugBridgeReadinessSummarySeverity severity,
    required String message,
    String? summaryRecordId,
    DebugBridgeReadinessSummaryGroupId? summaryGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String caseId,
  List<String> provenAndroidIds, {
  String? summaryRecordId,
  DebugBridgeReadinessSummaryGroupId? summaryGroupId,
}) {
  if (_phase32ECaseIds.contains(caseId)) {
    add(
      id: 'phase32ECaseTreatedAsCapturedProof',
      severity: DebugBridgeReadinessSummarySeverity.critical,
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
      severity: DebugBridgeReadinessSummarySeverity.critical,
      message: '$caseId is not captured Android proof',
      summaryRecordId: summaryRecordId,
      summaryGroupId: summaryGroupId,
      caseId: caseId,
    );
  }
}

bool _recordIsInactiveSafe(DebugBridgeReadinessSummaryRecord record) {
  return record.inactive &&
      record.summaryRole.isInactiveBoundary &&
      record.activeFieldIds.isEmpty &&
      !record.hasUnsafeOutput;
}

bool _hasExplicitPvProofReason(DebugBridgeReadinessSummaryResult result) {
  final reasons = <String>[
    ...result.warnings,
    ...result.failures,
    ...result.summaryGroups.expand((group) => group.warningReasons),
    ...result.summaryGroups.expand((group) => group.proofLimitReasons),
  ].join(' ').toLowerCase();
  return reasons.contains('pv') || reasons.contains('multipv');
}

int _countRecords(
  List<DebugBridgeReadinessSummaryRecord> records,
  DebugBridgeReadinessSummaryItemStatus status,
) {
  return records.where((record) => record.summaryStatus == status).length;
}

List<String> _provenAndroidProofIds(GoldenAndroidProofEvidence? evidence) {
  return _sortedStrings(evidence?.targetCaseIds ?? const <String>[]);
}

int _compareFindings(
  DebugBridgeReadinessSummaryFinding a,
  DebugBridgeReadinessSummaryFinding b,
) {
  final severity = _severityRank(
    b.severity,
  ).compareTo(_severityRank(a.severity));
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.summaryRecordId ?? '').compareTo(b.summaryRecordId ?? '');
}

int _severityRank(DebugBridgeReadinessSummarySeverity severity) {
  return switch (severity) {
    DebugBridgeReadinessSummarySeverity.warning => 1,
    DebugBridgeReadinessSummarySeverity.blocker => 2,
    DebugBridgeReadinessSummarySeverity.critical => 3,
  };
}

List<DebugOnlyAdapterBridgeInputGroupId> _sortedBridgeGroupIds(
  Iterable<DebugOnlyAdapterBridgeInputGroupId> values,
) {
  final sorted = values.toSet().toList()
    ..sort((a, b) => a.wire.compareTo(b.wire));
  return sorted;
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

/// Developer-only readiness gate for the validated debug bridge design.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_adapter_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/internal_adapter_readiness_summary_validation.dart';

const debugBridgeDesignReadinessGateReportVersion =
    'debug-bridge-design-readiness-gate-v1';

enum DebugBridgeDesignReadinessGateStatus {
  readyWithWarnings('readyWithWarnings'),
  readyClean('readyClean'),
  blockedByBridgeValidationFailure('blockedByBridgeValidationFailure'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const DebugBridgeDesignReadinessGateStatus(this.wire);

  final String wire;
}

enum DebugBridgeDesignReadinessGroupId {
  readyDebugCoreInputGroup('readyDebugCoreInputGroup'),
  constrainedDebugContextInputGroup('constrainedDebugContextInputGroup'),
  inactiveDebugBlockedInputGroup('inactiveDebugBlockedInputGroup'),
  inactiveDebugFutureOnlyInputGroup('inactiveDebugFutureOnlyInputGroup'),
  readyAllowedDebugFieldGroup('readyAllowedDebugFieldGroup'),
  deniedBlockedDebugFieldGroup('deniedBlockedDebugFieldGroup'),
  validatedProofBoundaryGroup('validatedProofBoundaryGroup'),
  emptyOwnerProofStatusGroup('emptyOwnerProofStatusGroup');

  const DebugBridgeDesignReadinessGroupId(this.wire);

  final String wire;
}

enum DebugBridgeDesignReadinessGroupStatus {
  readyDebugCoreInputGroup('readyDebugCoreInputGroup'),
  constrainedDebugContextInputGroup('constrainedDebugContextInputGroup'),
  inactiveDebugBlockedInputGroup('inactiveDebugBlockedInputGroup'),
  inactiveDebugFutureOnlyInputGroup('inactiveDebugFutureOnlyInputGroup'),
  readyAllowedDebugFieldGroup('readyAllowedDebugFieldGroup'),
  deniedBlockedDebugFieldGroup('deniedBlockedDebugFieldGroup'),
  validatedProofBoundaryGroup('validatedProofBoundaryGroup'),
  emptyOwnerProofStatusGroup('emptyOwnerProofStatusGroup'),
  invalidGroup('invalidGroup'),
  unsafeGroup('unsafeGroup');

  const DebugBridgeDesignReadinessGroupStatus(this.wire);

  final String wire;

  bool get isUnsafe =>
      this == DebugBridgeDesignReadinessGroupStatus.unsafeGroup;

  bool get isInvalid =>
      this == DebugBridgeDesignReadinessGroupStatus.invalidGroup;
}

enum DebugBridgeDesignReadinessRole {
  readyDebugCoreInput('readyDebugCoreInput'),
  constrainedDebugContextInput('constrainedDebugContextInput'),
  inactiveDebugBlockedInput('inactiveDebugBlockedInput'),
  inactiveDebugFutureOnlyInput('inactiveDebugFutureOnlyInput'),
  readyAllowedDebugField('readyAllowedDebugField'),
  deniedBlockedDebugField('deniedBlockedDebugField'),
  validatedProofBoundary('validatedProofBoundary'),
  emptyOwnerProofStatus('emptyOwnerProofStatus');

  const DebugBridgeDesignReadinessRole(this.wire);

  final String wire;

  bool get isInactiveBoundary =>
      this == inactiveDebugBlockedInput || this == inactiveDebugFutureOnlyInput;
}

enum DebugBridgeDesignReadinessRecordStatus {
  readyDebugCoreInput('readyDebugCoreInput'),
  constrainedDebugContextInput('constrainedDebugContextInput'),
  inactiveDebugBlockedInput('inactiveDebugBlockedInput'),
  inactiveDebugFutureOnlyInput('inactiveDebugFutureOnlyInput'),
  readyAllowedDebugField('readyAllowedDebugField'),
  deniedBlockedDebugField('deniedBlockedDebugField'),
  validatedProofBoundary('validatedProofBoundary'),
  emptyOwnerProofStatus('emptyOwnerProofStatus'),
  invalidRecord('invalidRecord'),
  unsafeRecord('unsafeRecord');

  const DebugBridgeDesignReadinessRecordStatus(this.wire);

  final String wire;

  bool get isUnsafe =>
      this == DebugBridgeDesignReadinessRecordStatus.unsafeRecord;

  bool get isInvalid =>
      this == DebugBridgeDesignReadinessRecordStatus.invalidRecord;
}

enum DebugBridgeDesignReadinessRecommendation {
  allowDebugCoreForPrototypePlanning('allowDebugCoreForPrototypePlanning'),
  keepDebugContextConstrained('keepDebugContextConstrained'),
  keepDebugBlockedInactive('keepDebugBlockedInactive'),
  keepDebugFutureOnlyInactive('keepDebugFutureOnlyInactive'),
  allowDebugFieldsForReadiness('allowDebugFieldsForReadiness'),
  denyBlockedDebugFields('denyBlockedDebugFields'),
  keepProofBoundaryValidated('keepProofBoundaryValidated'),
  keepOwnerProofEmpty('keepOwnerProofEmpty'),
  investigateReadinessFailure('investigateReadinessFailure'),
  blockUnsafeBridgeReadiness('blockUnsafeBridgeReadiness');

  const DebugBridgeDesignReadinessRecommendation(this.wire);

  final String wire;
}

enum DebugBridgeDesignReadinessSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const DebugBridgeDesignReadinessSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == DebugBridgeDesignReadinessSeverity.blocker ||
      this == DebugBridgeDesignReadinessSeverity.critical;

  bool get isCritical => this == DebugBridgeDesignReadinessSeverity.critical;
}

enum DebugBridgeDesignReadinessPhase32WRecommendation {
  proceedToDebugBridgeReadinessSummary('proceedToDebugBridgeReadinessSummary'),
  proceedToDebugOnlyAdapterBridgePrototypeDesign(
    'proceedToDebugOnlyAdapterBridgePrototypeDesign',
  ),
  proceedToDebugBridgeReadinessValidation(
    'proceedToDebugBridgeReadinessValidation',
  ),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeBridgeReadiness('blockedByUnsafeBridgeReadiness');

  const DebugBridgeDesignReadinessPhase32WRecommendation(this.wire);

  final String wire;
}

enum DebugBridgeDesignReadinessReportFormat {
  markdown('markdown'),
  json('json');

  const DebugBridgeDesignReadinessReportFormat(this.wire);

  final String wire;
}

class DebugBridgeDesignReadinessGateRequest {
  const DebugBridgeDesignReadinessGateRequest({
    this.validationResult,
    this.designResult,
    this.summaryValidationResult,
    this.summaryResult,
    this.validation = const DebugOnlyAdapterBridgeDesignValidation(),
    this.design = const DebugOnlyAdapterBridgeDesign(),
    this.summaryValidation = const InternalAdapterReadinessSummaryValidation(),
    this.summary = const InternalAdapterReadinessSummary(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const DebugBridgeDesignReadinessGateRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final DebugOnlyAdapterBridgeDesignValidationResult? validationResult;
  final DebugOnlyAdapterBridgeDesignResult? designResult;
  final InternalAdapterReadinessSummaryValidationResult?
  summaryValidationResult;
  final InternalAdapterReadinessSummaryResult? summaryResult;
  final DebugOnlyAdapterBridgeDesignValidation validation;
  final DebugOnlyAdapterBridgeDesign design;
  final InternalAdapterReadinessSummaryValidation summaryValidation;
  final InternalAdapterReadinessSummary summary;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class DebugBridgeDesignReadinessGroup {
  const DebugBridgeDesignReadinessGroup({
    required this.groupId,
    required this.readinessStatus,
    required this.sourceValidationRowIds,
    required this.sourceBridgeRecordIds,
    required this.activeFieldIds,
    required this.blockedFieldIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.futurePrerequisites,
    required this.blockedBoundaryIds,
    required this.safeForFutureDebugPrototype,
    required this.recommendation,
  });

  final DebugBridgeDesignReadinessGroupId groupId;
  final DebugBridgeDesignReadinessGroupStatus readinessStatus;
  final List<String> sourceValidationRowIds;
  final List<String> sourceBridgeRecordIds;
  final List<String> activeFieldIds;
  final List<String> blockedFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> futurePrerequisites;
  final List<String> blockedBoundaryIds;
  final bool safeForFutureDebugPrototype;
  final DebugBridgeDesignReadinessRecommendation recommendation;

  bool get hasUnsafeOutput =>
      readinessStatus.isUnsafe ||
      activeFieldIds.any(_isBlockedBridgeFieldId) ||
      activeFieldIds.any(_isLegacyBlockedOutputFieldId);

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'groupId': groupId.wire,
      'readinessStatus': readinessStatus.wire,
      'sourceValidationRowIds': sourceValidationRowIds,
      'sourceBridgeRecordIds': sourceBridgeRecordIds,
      'activeFieldIds': activeFieldIds,
      'blockedFieldIds': blockedFieldIds,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'futurePrerequisites': futurePrerequisites,
      'blockedBoundaryIds': blockedBoundaryIds,
      'safeForFutureDebugPrototype': safeForFutureDebugPrototype,
      'recommendation': recommendation.wire,
    };
  }
}

class DebugBridgeDesignReadinessRecord {
  const DebugBridgeDesignReadinessRecord({
    required this.readinessRecordId,
    required this.sourceValidationRowId,
    required this.sourceBridgeRecordId,
    required this.sourceBridgeGroupId,
    required this.readinessRole,
    required this.readinessStatus,
    required this.allowedForFutureDebugPrototype,
    required this.contextOnly,
    required this.inactive,
    required this.activeFieldIds,
    required this.blockedFieldIds,
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

  final String readinessRecordId;
  final String sourceValidationRowId;
  final String sourceBridgeRecordId;
  final DebugOnlyAdapterBridgeInputGroupId sourceBridgeGroupId;
  final DebugBridgeDesignReadinessRole readinessRole;
  final DebugBridgeDesignReadinessRecordStatus readinessStatus;
  final bool allowedForFutureDebugPrototype;
  final bool contextOnly;
  final bool inactive;
  final List<String> activeFieldIds;
  final List<String> blockedFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> futurePrerequisites;
  final List<String> blockedBoundaryIds;
  final Map<String, bool> safetyFlags;
  final List<String> violationReasons;
  final DebugBridgeDesignReadinessRecommendation recommendation;

  bool get hasUnsafeOutput =>
      readinessStatus.isUnsafe ||
      activeFieldIds.any(_isBlockedBridgeFieldId) ||
      activeFieldIds.any(_isLegacyBlockedOutputFieldId) ||
      safetyFlags.values.any((value) => value);

  DebugBridgeDesignReadinessRecord copyWith({
    String? readinessRecordId,
    String? sourceValidationRowId,
    String? sourceBridgeRecordId,
    DebugOnlyAdapterBridgeInputGroupId? sourceBridgeGroupId,
    DebugBridgeDesignReadinessRole? readinessRole,
    DebugBridgeDesignReadinessRecordStatus? readinessStatus,
    bool? allowedForFutureDebugPrototype,
    bool? contextOnly,
    bool? inactive,
    List<String>? activeFieldIds,
    List<String>? blockedFieldIds,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? futurePrerequisites,
    List<String>? blockedBoundaryIds,
    Map<String, bool>? safetyFlags,
    List<String>? violationReasons,
    DebugBridgeDesignReadinessRecommendation? recommendation,
  }) {
    return DebugBridgeDesignReadinessRecord(
      readinessRecordId: readinessRecordId ?? this.readinessRecordId,
      sourceValidationRowId:
          sourceValidationRowId ?? this.sourceValidationRowId,
      sourceBridgeRecordId: sourceBridgeRecordId ?? this.sourceBridgeRecordId,
      sourceBridgeGroupId: sourceBridgeGroupId ?? this.sourceBridgeGroupId,
      readinessRole: readinessRole ?? this.readinessRole,
      readinessStatus: readinessStatus ?? this.readinessStatus,
      allowedForFutureDebugPrototype:
          allowedForFutureDebugPrototype ?? this.allowedForFutureDebugPrototype,
      contextOnly: contextOnly ?? this.contextOnly,
      inactive: inactive ?? this.inactive,
      activeFieldIds: activeFieldIds ?? this.activeFieldIds,
      blockedFieldIds: blockedFieldIds ?? this.blockedFieldIds,
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
      'readinessRecordId': readinessRecordId,
      'sourceValidationRowId': sourceValidationRowId,
      'sourceBridgeRecordId': sourceBridgeRecordId,
      'sourceBridgeGroupId': sourceBridgeGroupId.wire,
      'readinessRole': readinessRole.wire,
      'readinessStatus': readinessStatus.wire,
      'allowedForFutureDebugPrototype': allowedForFutureDebugPrototype,
      'contextOnly': contextOnly,
      'inactive': inactive,
      'activeFieldIds': activeFieldIds,
      'blockedFieldIds': blockedFieldIds,
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

class DebugBridgeDesignReadinessFinding {
  const DebugBridgeDesignReadinessFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.readinessRecordId,
    this.readinessGroupId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final DebugBridgeDesignReadinessSeverity severity;
  final String message;
  final String? readinessRecordId;
  final DebugBridgeDesignReadinessGroupId? readinessGroupId;
  final String? fieldId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical => severity.isCritical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (readinessRecordId != null) 'readinessRecordId': readinessRecordId,
      if (readinessGroupId != null) 'readinessGroupId': readinessGroupId!.wire,
      if (fieldId != null) 'fieldId': fieldId,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class DebugBridgeDesignReadinessGateResult {
  const DebugBridgeDesignReadinessGateResult({
    required this.readinessStatus,
    required this.sourceValidationStatus,
    required this.sourceBridgeDesignStatus,
    required this.sourceSummaryValidationStatus,
    required this.sourceSummaryStatus,
    required this.readinessGroups,
    required this.readinessRecords,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalReadinessGroups,
    required this.totalReadinessRecords,
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
    required this.blockedFieldIds,
    required this.safeForPhase32W,
    required this.phase32WRecommendation,
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

  final DebugBridgeDesignReadinessGateStatus readinessStatus;
  final DebugOnlyAdapterBridgeDesignValidationStatus sourceValidationStatus;
  final DebugOnlyAdapterBridgeDesignStatus sourceBridgeDesignStatus;
  final InternalAdapterReadinessSummaryValidationStatus
  sourceSummaryValidationStatus;
  final InternalAdapterReadinessSummaryStatus sourceSummaryStatus;
  final List<DebugBridgeDesignReadinessGroup> readinessGroups;
  final List<DebugBridgeDesignReadinessRecord> readinessRecords;
  final List<DebugBridgeDesignReadinessFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalReadinessGroups;
  final int totalReadinessRecords;
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
  final List<String> blockedFieldIds;
  final bool safeForPhase32W;
  final DebugBridgeDesignReadinessPhase32WRecommendation phase32WRecommendation;
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
      readinessStatus ==
          DebugBridgeDesignReadinessGateStatus
              .blockedByBridgeValidationFailure ||
      readinessStatus ==
          DebugBridgeDesignReadinessGateStatus.blockedByPolicyBoundary ||
      readinessStatus == DebugBridgeDesignReadinessGateStatus.invalid ||
      !safeForPhase32W ||
      unsafeCount > 0 ||
      criticalCount > 0 ||
      blockerCount > 0 ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeDebugBridgeReadinessPolicyViolation {
    return readinessStatus ==
            DebugBridgeDesignReadinessGateStatus
                .blockedByBridgeValidationFailure ||
        readinessStatus ==
            DebugBridgeDesignReadinessGateStatus.blockedByPolicyBoundary ||
        unsafeCount > 0 ||
        criticalCount > 0 ||
        readinessGroups.any((group) => group.hasUnsafeOutput) ||
        readinessRecords.any((record) => record.hasUnsafeOutput) ||
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

  DebugBridgeDesignReadinessGroup group(
    DebugBridgeDesignReadinessGroupId groupId,
  ) {
    return readinessGroups.singleWhere((group) => group.groupId == groupId);
  }

  DebugBridgeDesignReadinessRecord recordForRole(
    DebugBridgeDesignReadinessRole role,
  ) {
    return readinessRecords.singleWhere(
      (record) => record.readinessRole == role,
    );
  }

  List<DebugBridgeDesignReadinessRecord> get readyDebugCoreRecords =>
      readinessRecords
          .where(
            (record) =>
                record.readinessRole ==
                DebugBridgeDesignReadinessRole.readyDebugCoreInput,
          )
          .toList(growable: false);

  List<DebugBridgeDesignReadinessRecord> get constrainedDebugContextRecords =>
      readinessRecords
          .where(
            (record) =>
                record.readinessRole ==
                DebugBridgeDesignReadinessRole.constrainedDebugContextInput,
          )
          .toList(growable: false);

  List<DebugBridgeDesignReadinessRecord> get inactiveBoundaryRecords =>
      readinessRecords
          .where((record) => record.readinessRole.isInactiveBoundary)
          .toList(growable: false);

  DebugBridgeDesignReadinessGateResult copyWith({
    DebugBridgeDesignReadinessGateStatus? readinessStatus,
    DebugOnlyAdapterBridgeDesignValidationStatus? sourceValidationStatus,
    DebugOnlyAdapterBridgeDesignStatus? sourceBridgeDesignStatus,
    InternalAdapterReadinessSummaryValidationStatus?
    sourceSummaryValidationStatus,
    InternalAdapterReadinessSummaryStatus? sourceSummaryStatus,
    List<DebugBridgeDesignReadinessGroup>? readinessGroups,
    List<DebugBridgeDesignReadinessRecord>? readinessRecords,
    List<DebugBridgeDesignReadinessFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalReadinessGroups,
    int? totalReadinessRecords,
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
    List<String>? blockedFieldIds,
    bool? safeForPhase32W,
    DebugBridgeDesignReadinessPhase32WRecommendation? phase32WRecommendation,
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
    return DebugBridgeDesignReadinessGateResult(
      readinessStatus: readinessStatus ?? this.readinessStatus,
      sourceValidationStatus:
          sourceValidationStatus ?? this.sourceValidationStatus,
      sourceBridgeDesignStatus:
          sourceBridgeDesignStatus ?? this.sourceBridgeDesignStatus,
      sourceSummaryValidationStatus:
          sourceSummaryValidationStatus ?? this.sourceSummaryValidationStatus,
      sourceSummaryStatus: sourceSummaryStatus ?? this.sourceSummaryStatus,
      readinessGroups: readinessGroups ?? this.readinessGroups,
      readinessRecords: readinessRecords ?? this.readinessRecords,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalReadinessGroups: totalReadinessGroups ?? this.totalReadinessGroups,
      totalReadinessRecords:
          totalReadinessRecords ?? this.totalReadinessRecords,
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
      blockedFieldIds: blockedFieldIds ?? this.blockedFieldIds,
      safeForPhase32W: safeForPhase32W ?? this.safeForPhase32W,
      phase32WRecommendation:
          phase32WRecommendation ?? this.phase32WRecommendation,
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
      ..writeln('# Debug Bridge Design Readiness Gate')
      ..writeln()
      ..writeln('- version: $debugBridgeDesignReadinessGateReportVersion')
      ..writeln('- readiness status: ${readinessStatus.wire}')
      ..writeln('- source validation status: ${sourceValidationStatus.wire}')
      ..writeln(
        '- source bridge design status: ${sourceBridgeDesignStatus.wire}',
      )
      ..writeln('- total readiness groups: $totalReadinessGroups')
      ..writeln('- total readiness records: $totalReadinessRecords')
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
      ..writeln('- safeForPhase32W: $safeForPhase32W')
      ..writeln('- Phase 32W recommendation: ${phase32WRecommendation.wire}')
      ..writeln()
      ..writeln('## Readiness Group Table')
      ..writeln(
        '| Group | Status | Records | Active fields | Blocked fields | Safe | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
    for (final group in readinessGroups) {
      buffer.writeln(
        '| ${group.groupId.wire} | ${group.readinessStatus.wire} | ${_ids(group.sourceBridgeRecordIds)} | ${_ids(group.activeFieldIds)} | ${_ids(group.blockedFieldIds)} | ${group.safeForFutureDebugPrototype} | ${group.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Readiness Record Table')
      ..writeln(
        '| Record | Role | Status | Active fields | Blocked fields | Prototype | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
    for (final record in readinessRecords) {
      buffer.writeln(
        '| ${_cell(record.readinessRecordId)} | ${record.readinessRole.wire} | ${record.readinessStatus.wire} | ${_ids(record.activeFieldIds)} | ${_ids(record.blockedFieldIds)} | ${record.allowedForFutureDebugPrototype} | ${record.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Ready Debug Core Inputs');
    for (final record in readyDebugCoreRecords) {
      buffer.writeln(
        '- ${record.readinessRecordId}: ${record.readinessStatus.wire}; active fields: ${_ids(record.activeFieldIds)}',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Constrained Debug Context Inputs');
    for (final record in constrainedDebugContextRecords) {
      buffer.writeln(
        '- ${record.readinessRecordId}: ${record.readinessStatus.wire}; contextOnly: ${record.contextOnly}',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Inactive Blocked/Future Inputs');
    for (final record in inactiveBoundaryRecords) {
      buffer.writeln(
        '- ${record.readinessRecordId}: ${record.readinessStatus.wire}; inactive: ${record.inactive}',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Ready Allowed Fields')
      ..writeln('- allowed bridge fields: ${_ids(allowedFieldIds)}')
      ..writeln()
      ..writeln('## Denied Blocked Fields')
      ..writeln('- denied blocked bridge fields: ${_ids(blockedFieldIds)}')
      ..writeln()
      ..writeln('## Stockfish Raw UCI PV Dump Blocked Status')
      ..writeln(
        '- stockfishCommand blocked: ${blockedFieldIds.contains('stockfishCommand')}',
      )
      ..writeln('- rawUci blocked: ${blockedFieldIds.contains('rawUci')}')
      ..writeln('- pvDump blocked: ${blockedFieldIds.contains('pvDump')}')
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
      ..writeln('## Phase 32W Recommendation')
      ..writeln('- ${phase32WRecommendation.wire}');
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': debugBridgeDesignReadinessGateReportVersion,
      'readinessStatus': readinessStatus.wire,
      'sourceValidationStatus': sourceValidationStatus.wire,
      'sourceBridgeDesignStatus': sourceBridgeDesignStatus.wire,
      'sourceSummaryValidationStatus': sourceSummaryValidationStatus.wire,
      'sourceSummaryStatus': sourceSummaryStatus.wire,
      'totalReadinessGroups': totalReadinessGroups,
      'totalReadinessRecords': totalReadinessRecords,
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
      'blockedFieldIds': blockedFieldIds,
      'safeForPhase32W': safeForPhase32W,
      'phase32WRecommendation': phase32WRecommendation.wire,
      'readinessGroups': readinessGroups
          .map((group) => group.toJson())
          .toList(),
      'readinessRecords': readinessRecords
          .map((record) => record.toJson())
          .toList(),
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

class DebugBridgeDesignReadinessGate {
  const DebugBridgeDesignReadinessGate({
    this.validator = const DebugBridgeDesignReadinessGateValidator(),
  });

  final DebugBridgeDesignReadinessGateValidator validator;

  DebugBridgeDesignReadinessGateResult evaluate([
    DebugBridgeDesignReadinessGateRequest request =
        const DebugBridgeDesignReadinessGateRequest(),
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
    final readinessGroups = _groupsFromValidation(
      validationResult: validationResult,
      designResult: designResult,
    );
    final readinessRecords = _recordsFromValidation(
      validationResult: validationResult,
      designResult: designResult,
    );
    final base = _resultFromGroupsAndRecords(
      validationResult: validationResult,
      designResult: designResult,
      summaryValidationResult: summaryValidationResult,
      summaryResult: summaryResult,
      readinessGroups: readinessGroups,
      readinessRecords: readinessRecords,
      validationFindings: const <DebugBridgeDesignReadinessFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromGroupsAndRecords(
      validationResult: validationResult,
      designResult: designResult,
      summaryValidationResult: summaryValidationResult,
      summaryResult: summaryResult,
      readinessGroups: readinessGroups,
      readinessRecords: readinessRecords,
      validationFindings: findings,
    );
  }
}

class DebugBridgeDesignReadinessGateValidator {
  const DebugBridgeDesignReadinessGateValidator();

  List<DebugBridgeDesignReadinessFinding> validate(
    DebugBridgeDesignReadinessGateResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <DebugBridgeDesignReadinessFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required DebugBridgeDesignReadinessSeverity severity,
      required String message,
      String? readinessRecordId,
      DebugBridgeDesignReadinessGroupId? readinessGroupId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        DebugBridgeDesignReadinessFinding(
          id: id,
          severity: severity,
          message: message,
          readinessRecordId: readinessRecordId,
          readinessGroupId: readinessGroupId,
          fieldId: fieldId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase32W &&
        (result.sourceValidationStatus ==
                DebugOnlyAdapterBridgeDesignValidationStatus
                    .blockedByUnsafeBridgeDesign ||
            result.sourceValidationStatus ==
                DebugOnlyAdapterBridgeDesignValidationStatus
                    .blockedByPolicyBoundary ||
            result.unsafeCount > 0)) {
      add(
        id: 'unsafeBridgeValidationMarkedReady',
        severity: DebugBridgeDesignReadinessSeverity.critical,
        message: 'unsafe bridge validation cannot be marked ready',
      );
    }

    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: DebugBridgeDesignReadinessSeverity.blocker,
        message: 'owner proof requires explicit PV/MultiPV reason',
      );
    }

    for (final fieldId in _blockedBridgeFieldIds) {
      if (!result.blockedFieldIds.contains(fieldId)) {
        add(
          id: 'blockedBridgeFieldMissing',
          severity: DebugBridgeDesignReadinessSeverity.blocker,
          message: '$fieldId must remain denied at readiness',
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

    for (final group in result.readinessGroups) {
      for (final fieldId in group.activeFieldIds) {
        _checkActiveBridgeField(add, fieldId, readinessGroupId: group.groupId);
      }
      for (final caseId in group.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          readinessGroupId: group.groupId,
        );
      }
    }

    for (final record in result.readinessRecords) {
      for (final fieldId in record.activeFieldIds) {
        _checkActiveBridgeField(
          add,
          fieldId,
          readinessRecordId: record.readinessRecordId,
        );
      }
      for (final caseId in record.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          readinessRecordId: record.readinessRecordId,
        );
      }
      if (record.readinessRole ==
              DebugBridgeDesignReadinessRole.readyDebugCoreInput &&
          record.violationReasons.contains('debugCoreConsumesNonCoreInput')) {
        add(
          id: 'debugCoreConsumesNonCoreInput',
          severity: DebugBridgeDesignReadinessSeverity.critical,
          message: 'debug core readiness cannot consume non-core input',
          readinessRecordId: record.readinessRecordId,
        );
      }
      if (record.contextOnly &&
          record.readinessRole ==
              DebugBridgeDesignReadinessRole.readyDebugCoreInput) {
        add(
          id: 'contextOnlyInputPromotedToDebugCore',
          severity: DebugBridgeDesignReadinessSeverity.critical,
          message: 'context-only input cannot become debug core readiness',
          readinessRecordId: record.readinessRecordId,
        );
      }
      if (record.readinessRole.isInactiveBoundary &&
          !_recordIsInactiveSafe(record)) {
        add(
          id: 'blockedFutureInputMadeActive',
          severity: DebugBridgeDesignReadinessSeverity.critical,
          message: 'blocked/future-only readiness must remain inactive',
          readinessRecordId: record.readinessRecordId,
        );
      }
      _checkSafetyFlags(add, record);
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
        id: 'debugBridgeReadinessBoundaryPolicyViolation',
        severity: DebugBridgeDesignReadinessSeverity.critical,
        message: 'debug bridge readiness crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<DebugBridgeDesignReadinessFinding> validateReportText(
    String reportText,
  ) {
    final findings = <DebugBridgeDesignReadinessFinding>[];
    void reportError(String id, String message) {
      findings.add(
        DebugBridgeDesignReadinessFinding(
          id: id,
          severity: DebugBridgeDesignReadinessSeverity.critical,
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

List<DebugBridgeDesignReadinessGroup> _groupsFromValidation({
  required DebugOnlyAdapterBridgeDesignValidationResult validationResult,
  required DebugOnlyAdapterBridgeDesignResult designResult,
}) {
  return <DebugBridgeDesignReadinessGroup>[
    _groupFromValidationRow(
      validationResult,
      designResult,
      DebugOnlyAdapterBridgeInputGroupId.debugCoreInputGroup,
      DebugBridgeDesignReadinessGroupId.readyDebugCoreInputGroup,
      DebugBridgeDesignReadinessGroupStatus.readyDebugCoreInputGroup,
      DebugBridgeDesignReadinessRecommendation
          .allowDebugCoreForPrototypePlanning,
    ),
    _groupFromValidationRow(
      validationResult,
      designResult,
      DebugOnlyAdapterBridgeInputGroupId.debugContextInputGroup,
      DebugBridgeDesignReadinessGroupId.constrainedDebugContextInputGroup,
      DebugBridgeDesignReadinessGroupStatus.constrainedDebugContextInputGroup,
      DebugBridgeDesignReadinessRecommendation.keepDebugContextConstrained,
    ),
    _groupFromValidationRow(
      validationResult,
      designResult,
      DebugOnlyAdapterBridgeInputGroupId.debugBlockedInputGroup,
      DebugBridgeDesignReadinessGroupId.inactiveDebugBlockedInputGroup,
      DebugBridgeDesignReadinessGroupStatus.inactiveDebugBlockedInputGroup,
      DebugBridgeDesignReadinessRecommendation.keepDebugBlockedInactive,
    ),
    _groupFromValidationRow(
      validationResult,
      designResult,
      DebugOnlyAdapterBridgeInputGroupId.debugFutureOnlyInputGroup,
      DebugBridgeDesignReadinessGroupId.inactiveDebugFutureOnlyInputGroup,
      DebugBridgeDesignReadinessGroupStatus.inactiveDebugFutureOnlyInputGroup,
      DebugBridgeDesignReadinessRecommendation.keepDebugFutureOnlyInactive,
    ),
    _groupFromValidationRow(
      validationResult,
      designResult,
      DebugOnlyAdapterBridgeInputGroupId.debugAllowedFieldGroup,
      DebugBridgeDesignReadinessGroupId.readyAllowedDebugFieldGroup,
      DebugBridgeDesignReadinessGroupStatus.readyAllowedDebugFieldGroup,
      DebugBridgeDesignReadinessRecommendation.allowDebugFieldsForReadiness,
    ),
    _groupFromValidationRow(
      validationResult,
      designResult,
      DebugOnlyAdapterBridgeInputGroupId.debugBlockedFieldGroup,
      DebugBridgeDesignReadinessGroupId.deniedBlockedDebugFieldGroup,
      DebugBridgeDesignReadinessGroupStatus.deniedBlockedDebugFieldGroup,
      DebugBridgeDesignReadinessRecommendation.denyBlockedDebugFields,
    ),
    _groupFromValidationRow(
      validationResult,
      designResult,
      DebugOnlyAdapterBridgeInputGroupId.debugProofBoundaryGroup,
      DebugBridgeDesignReadinessGroupId.validatedProofBoundaryGroup,
      DebugBridgeDesignReadinessGroupStatus.validatedProofBoundaryGroup,
      DebugBridgeDesignReadinessRecommendation.keepProofBoundaryValidated,
    ),
    _groupFromValidationRow(
      validationResult,
      designResult,
      DebugOnlyAdapterBridgeInputGroupId.debugOwnerProofStatusGroup,
      DebugBridgeDesignReadinessGroupId.emptyOwnerProofStatusGroup,
      DebugBridgeDesignReadinessGroupStatus.emptyOwnerProofStatusGroup,
      DebugBridgeDesignReadinessRecommendation.keepOwnerProofEmpty,
    ),
  ];
}

DebugBridgeDesignReadinessGroup _groupFromValidationRow(
  DebugOnlyAdapterBridgeDesignValidationResult validationResult,
  DebugOnlyAdapterBridgeDesignResult designResult,
  DebugOnlyAdapterBridgeInputGroupId sourceGroupId,
  DebugBridgeDesignReadinessGroupId readinessGroupId,
  DebugBridgeDesignReadinessGroupStatus validStatus,
  DebugBridgeDesignReadinessRecommendation recommendation,
) {
  final validationRow = validationResult.groupRowForGroup(sourceGroupId);
  final designGroup = designResult.group(sourceGroupId);
  final unsafe =
      validationRow.hasUnsafeOutput ||
      designGroup.designStatus.isUnsafe ||
      designGroup.activeFieldIds.any(_isBlockedBridgeFieldId) ||
      designGroup.activeFieldIds.any(_isLegacyBlockedOutputFieldId);
  final invalid =
      !unsafe &&
      (!validationRow.safeForNextPhase ||
          validationRow.validationStatus.isInvalid ||
          validationRow.violationReasons.isNotEmpty);
  final status = unsafe
      ? DebugBridgeDesignReadinessGroupStatus.unsafeGroup
      : invalid
      ? DebugBridgeDesignReadinessGroupStatus.invalidGroup
      : validStatus;
  return DebugBridgeDesignReadinessGroup(
    groupId: readinessGroupId,
    readinessStatus: status,
    sourceValidationRowIds: <String>[validationRow.validationRowId],
    sourceBridgeRecordIds: _sortedStrings(validationRow.bridgeRecordIds),
    activeFieldIds: _sortedStrings(validationRow.activeFieldIds),
    blockedFieldIds: _sortedStrings(validationRow.blockedFieldIds),
    supportCaseIds: _sortedStrings(validationRow.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(
      validationRow.newlyAddedSupportCaseIds,
    ),
    androidProofCaseIds: _sortedStrings(validationRow.androidProofCaseIds),
    warningReasons: _sortedStrings(<String>[
      validationRow.warningReason,
      ...designGroup.warningReasons,
    ]),
    proofLimitReasons: _sortedStrings(designGroup.proofLimitReasons),
    futurePrerequisites: _sortedStrings(designGroup.futurePrerequisites),
    blockedBoundaryIds: _sortedStrings(designGroup.blockedBoundaryIds),
    safeForFutureDebugPrototype: !unsafe && !invalid,
    recommendation: unsafe
        ? DebugBridgeDesignReadinessRecommendation.blockUnsafeBridgeReadiness
        : invalid
        ? DebugBridgeDesignReadinessRecommendation.investigateReadinessFailure
        : recommendation,
  );
}

List<DebugBridgeDesignReadinessRecord> _recordsFromValidation({
  required DebugOnlyAdapterBridgeDesignValidationResult validationResult,
  required DebugOnlyAdapterBridgeDesignResult designResult,
}) {
  return <DebugBridgeDesignReadinessRecord>[
    _recordFromValidationRow(
      validationResult,
      designResult,
      DebugOnlyAdapterBridgeRole.debugCoreInput,
      DebugBridgeDesignReadinessRole.readyDebugCoreInput,
      DebugBridgeDesignReadinessRecordStatus.readyDebugCoreInput,
      DebugBridgeDesignReadinessRecommendation
          .allowDebugCoreForPrototypePlanning,
      allowedForFutureDebugPrototype: true,
      contextOnly: false,
      inactive: false,
    ),
    _recordFromValidationRow(
      validationResult,
      designResult,
      DebugOnlyAdapterBridgeRole.debugContextOnlyInput,
      DebugBridgeDesignReadinessRole.constrainedDebugContextInput,
      DebugBridgeDesignReadinessRecordStatus.constrainedDebugContextInput,
      DebugBridgeDesignReadinessRecommendation.keepDebugContextConstrained,
      allowedForFutureDebugPrototype: false,
      contextOnly: true,
      inactive: false,
    ),
    _recordFromValidationRow(
      validationResult,
      designResult,
      DebugOnlyAdapterBridgeRole.debugBlockedInput,
      DebugBridgeDesignReadinessRole.inactiveDebugBlockedInput,
      DebugBridgeDesignReadinessRecordStatus.inactiveDebugBlockedInput,
      DebugBridgeDesignReadinessRecommendation.keepDebugBlockedInactive,
      allowedForFutureDebugPrototype: false,
      contextOnly: false,
      inactive: true,
    ),
    _recordFromValidationRow(
      validationResult,
      designResult,
      DebugOnlyAdapterBridgeRole.debugFutureOnlyInput,
      DebugBridgeDesignReadinessRole.inactiveDebugFutureOnlyInput,
      DebugBridgeDesignReadinessRecordStatus.inactiveDebugFutureOnlyInput,
      DebugBridgeDesignReadinessRecommendation.keepDebugFutureOnlyInactive,
      allowedForFutureDebugPrototype: false,
      contextOnly: false,
      inactive: true,
    ),
    _recordFromValidationRow(
      validationResult,
      designResult,
      DebugOnlyAdapterBridgeRole.debugAllowedField,
      DebugBridgeDesignReadinessRole.readyAllowedDebugField,
      DebugBridgeDesignReadinessRecordStatus.readyAllowedDebugField,
      DebugBridgeDesignReadinessRecommendation.allowDebugFieldsForReadiness,
      allowedForFutureDebugPrototype: true,
      contextOnly: false,
      inactive: false,
    ),
    _recordFromValidationRow(
      validationResult,
      designResult,
      DebugOnlyAdapterBridgeRole.debugBlockedField,
      DebugBridgeDesignReadinessRole.deniedBlockedDebugField,
      DebugBridgeDesignReadinessRecordStatus.deniedBlockedDebugField,
      DebugBridgeDesignReadinessRecommendation.denyBlockedDebugFields,
      allowedForFutureDebugPrototype: false,
      contextOnly: false,
      inactive: true,
    ),
    _recordFromValidationRow(
      validationResult,
      designResult,
      DebugOnlyAdapterBridgeRole.debugProofBoundary,
      DebugBridgeDesignReadinessRole.validatedProofBoundary,
      DebugBridgeDesignReadinessRecordStatus.validatedProofBoundary,
      DebugBridgeDesignReadinessRecommendation.keepProofBoundaryValidated,
      allowedForFutureDebugPrototype: true,
      contextOnly: false,
      inactive: false,
    ),
    _recordFromValidationRow(
      validationResult,
      designResult,
      DebugOnlyAdapterBridgeRole.debugOwnerProofStatus,
      DebugBridgeDesignReadinessRole.emptyOwnerProofStatus,
      DebugBridgeDesignReadinessRecordStatus.emptyOwnerProofStatus,
      DebugBridgeDesignReadinessRecommendation.keepOwnerProofEmpty,
      allowedForFutureDebugPrototype: true,
      contextOnly: false,
      inactive: false,
    ),
  ];
}

DebugBridgeDesignReadinessRecord _recordFromValidationRow(
  DebugOnlyAdapterBridgeDesignValidationResult validationResult,
  DebugOnlyAdapterBridgeDesignResult designResult,
  DebugOnlyAdapterBridgeRole sourceRole,
  DebugBridgeDesignReadinessRole readinessRole,
  DebugBridgeDesignReadinessRecordStatus validStatus,
  DebugBridgeDesignReadinessRecommendation recommendation, {
  required bool allowedForFutureDebugPrototype,
  required bool contextOnly,
  required bool inactive,
}) {
  final validationRow = validationResult.recordRowForRole(sourceRole);
  final designRecord = designResult.record(validationRow.sourceBridgeRecordId);
  final flags = _safetyFlagsFrom(validationRow);
  final violations = <String>[
    ...validationRow.violationReasons,
    if (readinessRole == DebugBridgeDesignReadinessRole.readyDebugCoreInput &&
        !designRecord.adapterPacketIds.every(_isCorePacketId))
      'debugCoreConsumesNonCoreInput',
    if (contextOnly &&
        readinessRole == DebugBridgeDesignReadinessRole.readyDebugCoreInput)
      'contextOnlyInputPromotedToDebugCore',
    if (readinessRole.isInactiveBoundary &&
        validationRow.activeFieldIds.isNotEmpty)
      'blockedFutureInputMadeActive',
    ...flags.entries
        .where((entry) => entry.value)
        .map((entry) => '${entry.key}Active'),
  ];
  final unsafe =
      validationRow.hasUnsafeOutput ||
      validationRow.validationStatus.isUnsafe ||
      flags.values.any((value) => value);
  final invalid =
      !unsafe &&
      (!validationRow.safeForNextPhase ||
          validationRow.validationStatus.isInvalid ||
          violations.isNotEmpty);
  final status = unsafe
      ? DebugBridgeDesignReadinessRecordStatus.unsafeRecord
      : invalid
      ? DebugBridgeDesignReadinessRecordStatus.invalidRecord
      : validStatus;
  return DebugBridgeDesignReadinessRecord(
    readinessRecordId: 'debug-readiness-${validationRow.sourceBridgeRecordId}',
    sourceValidationRowId: validationRow.validationRowId,
    sourceBridgeRecordId: validationRow.sourceBridgeRecordId,
    sourceBridgeGroupId: _sourceGroupForBridgeRole(validationRow.bridgeRole),
    readinessRole: readinessRole,
    readinessStatus: status,
    allowedForFutureDebugPrototype:
        allowedForFutureDebugPrototype && !unsafe && !invalid,
    contextOnly: contextOnly,
    inactive: inactive,
    activeFieldIds: inactive
        ? const <String>[]
        : _sortedStrings(validationRow.activeFieldIds),
    blockedFieldIds: _sortedStrings(validationRow.blockedFieldIds),
    supportCaseIds: _sortedStrings(validationRow.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(
      validationRow.newlyAddedSupportCaseIds,
    ),
    androidProofCaseIds: _sortedStrings(validationRow.androidProofCaseIds),
    warningReasons: _sortedStrings(designRecord.warningReasons),
    proofLimitReasons: _sortedStrings(designRecord.proofLimitReasons),
    futurePrerequisites: _sortedStrings(designRecord.futurePrerequisites),
    blockedBoundaryIds: _sortedStrings(designRecord.blockedBoundaryIds),
    safetyFlags: flags,
    violationReasons: _sortedStrings(violations),
    recommendation: unsafe
        ? DebugBridgeDesignReadinessRecommendation.blockUnsafeBridgeReadiness
        : invalid
        ? DebugBridgeDesignReadinessRecommendation.investigateReadinessFailure
        : recommendation,
  );
}

DebugBridgeDesignReadinessGateResult _resultFromGroupsAndRecords({
  required DebugOnlyAdapterBridgeDesignValidationResult validationResult,
  required DebugOnlyAdapterBridgeDesignResult designResult,
  required InternalAdapterReadinessSummaryValidationResult
  summaryValidationResult,
  required InternalAdapterReadinessSummaryResult summaryResult,
  required List<DebugBridgeDesignReadinessGroup> readinessGroups,
  required List<DebugBridgeDesignReadinessRecord> readinessRecords,
  required List<DebugBridgeDesignReadinessFinding> validationFindings,
}) {
  final unsafeCount = readinessRecords
      .where(
        (record) =>
            record.hasUnsafeOutput ||
            record.readinessStatus ==
                DebugBridgeDesignReadinessRecordStatus.unsafeRecord,
      )
      .length;
  final blockerCount = validationFindings
      .where(
        (finding) =>
            finding.severity == DebugBridgeDesignReadinessSeverity.blocker,
      )
      .length;
  final criticalCount = validationFindings
      .where((finding) => finding.isCritical)
      .length;
  final base = DebugBridgeDesignReadinessGateResult(
    readinessStatus: DebugBridgeDesignReadinessGateStatus.invalid,
    sourceValidationStatus: validationResult.validationStatus,
    sourceBridgeDesignStatus: designResult.designStatus,
    sourceSummaryValidationStatus: summaryValidationResult.validationStatus,
    sourceSummaryStatus: summaryResult.summaryStatus,
    readinessGroups: readinessGroups,
    readinessRecords: readinessRecords,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...validationResult.warnings,
      if (readinessRecords.any((record) => record.contextOnly))
        'debug context readiness remains context-only',
      if (readinessRecords.any((record) => record.inactive))
        'debug blocked/future readiness remains inactive',
      if (validationResult.ownerProofQueueCount == 0)
        'owner proof readiness remains empty',
    ]),
    failures: _sortedStrings(<String>[
      ...validationResult.failures,
      ...validationFindings.map((finding) => finding.message),
      ...readinessGroups.expand(
        (group) => group.hasUnsafeOutput
            ? <String>['unsafe readiness group']
            : const <String>[],
      ),
      ...readinessRecords.expand((record) => record.violationReasons),
    ]),
    totalReadinessGroups: readinessGroups.length,
    totalReadinessRecords: readinessRecords.length,
    readyDebugCoreInputCount: _countRecords(
      readinessRecords,
      DebugBridgeDesignReadinessRecordStatus.readyDebugCoreInput,
    ),
    constrainedDebugContextInputCount: _countRecords(
      readinessRecords,
      DebugBridgeDesignReadinessRecordStatus.constrainedDebugContextInput,
    ),
    inactiveBlockedInputCount: _countRecords(
      readinessRecords,
      DebugBridgeDesignReadinessRecordStatus.inactiveDebugBlockedInput,
    ),
    inactiveFutureOnlyInputCount: _countRecords(
      readinessRecords,
      DebugBridgeDesignReadinessRecordStatus.inactiveDebugFutureOnlyInput,
    ),
    readyAllowedFieldCount: validationResult.allowedFieldIds.length,
    deniedBlockedFieldCount: validationResult.blockedFieldIds.length,
    unsafeCount: unsafeCount,
    blockerCount: blockerCount,
    criticalCount: criticalCount,
    ownerProofQueueCount: validationResult.ownerProofQueueCount,
    supportCaseIds: _sortedStrings(validationResult.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(
      validationResult.newlyAddedSupportCaseIds,
    ),
    androidProofCaseIds: _sortedStrings(validationResult.androidProofCaseIds),
    allowedFieldIds: _sortedStrings(validationResult.allowedFieldIds),
    blockedFieldIds: _sortedStrings(validationResult.blockedFieldIds),
    safeForPhase32W: false,
    phase32WRecommendation: DebugBridgeDesignReadinessPhase32WRecommendation
        .addMoreGoldenCoverageFirst,
    developerOnly:
        validationResult.developerOnly &&
        designResult.developerOnly &&
        summaryValidationResult.developerOnly &&
        summaryResult.developerOnly,
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
  final status = _readinessStatusFor(base, validationResult: validationResult);
  final safeForPhase32W =
      (status == DebugBridgeDesignReadinessGateStatus.readyWithWarnings ||
          status == DebugBridgeDesignReadinessGateStatus.readyClean) &&
      validationResult.safeForPhase32V &&
      !validationResult.isStrictlyBlocked &&
      !validationResult.hasUnsafeDebugBridgeDesignValidationPolicyViolation &&
      unsafeCount == 0 &&
      blockerCount == 0 &&
      criticalCount == 0 &&
      validationFindings.every((finding) => !finding.blocksStrict) &&
      readinessGroups.every((group) => group.safeForFutureDebugPrototype) &&
      readinessRecords.every(
        (record) =>
            !record.hasUnsafeOutput &&
            record.readinessStatus !=
                DebugBridgeDesignReadinessRecordStatus.invalidRecord,
      );
  return base.copyWith(
    readinessStatus: status,
    safeForPhase32W: safeForPhase32W,
    phase32WRecommendation: _phase32WRecommendationFor(
      status: status,
      safeForPhase32W: safeForPhase32W,
      ownerProofQueueCount: validationResult.ownerProofQueueCount,
    ),
  );
}

DebugBridgeDesignReadinessGateStatus _readinessStatusFor(
  DebugBridgeDesignReadinessGateResult result, {
  required DebugOnlyAdapterBridgeDesignValidationResult validationResult,
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
    return DebugBridgeDesignReadinessGateStatus.blockedByPolicyBoundary;
  }
  if (validationResult.validationStatus ==
          DebugOnlyAdapterBridgeDesignValidationStatus
              .blockedByUnsafeBridgeDesign ||
      validationResult.validationStatus ==
          DebugOnlyAdapterBridgeDesignValidationStatus
              .blockedByPolicyBoundary ||
      validationResult.unsafeRecordCount > 0 ||
      validationResult.criticalCount > 0 ||
      validationResult.hasUnsafeDebugBridgeDesignValidationPolicyViolation ||
      result.unsafeCount > 0 ||
      result.criticalCount > 0) {
    return DebugBridgeDesignReadinessGateStatus
        .blockedByBridgeValidationFailure;
  }
  if (!validationResult.safeForPhase32V ||
      validationResult.isStrictlyBlocked ||
      result.blockerCount > 0 ||
      result.validationFindings.any((finding) => finding.blocksStrict) ||
      result.readinessRecords.any(
        (record) =>
            record.readinessStatus ==
            DebugBridgeDesignReadinessRecordStatus.invalidRecord,
      ) ||
      result.readinessGroups.any(
        (group) => !group.safeForFutureDebugPrototype,
      )) {
    return DebugBridgeDesignReadinessGateStatus.invalid;
  }
  if (result.readinessGroups.isEmpty || result.readinessRecords.isEmpty) {
    return DebugBridgeDesignReadinessGateStatus.invalid;
  }
  if (result.constrainedDebugContextInputCount > 0 ||
      result.inactiveBlockedInputCount > 0 ||
      result.inactiveFutureOnlyInputCount > 0 ||
      result.warnings.isNotEmpty) {
    return DebugBridgeDesignReadinessGateStatus.readyWithWarnings;
  }
  return DebugBridgeDesignReadinessGateStatus.readyClean;
}

DebugBridgeDesignReadinessPhase32WRecommendation _phase32WRecommendationFor({
  required DebugBridgeDesignReadinessGateStatus status,
  required bool safeForPhase32W,
  required int ownerProofQueueCount,
}) {
  if (status ==
          DebugBridgeDesignReadinessGateStatus
              .blockedByBridgeValidationFailure ||
      status == DebugBridgeDesignReadinessGateStatus.blockedByPolicyBoundary) {
    return DebugBridgeDesignReadinessPhase32WRecommendation
        .blockedByUnsafeBridgeReadiness;
  }
  if (ownerProofQueueCount > 0) {
    return DebugBridgeDesignReadinessPhase32WRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase32W) {
    return DebugBridgeDesignReadinessPhase32WRecommendation
        .addMoreGoldenCoverageFirst;
  }
  return DebugBridgeDesignReadinessPhase32WRecommendation
      .proceedToDebugBridgeReadinessSummary;
}

DebugOnlyAdapterBridgeInputGroupId _sourceGroupForBridgeRole(
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

Map<String, bool> _safetyFlagsFrom(
  DebugOnlyAdapterBridgeRecordValidationRow row,
) {
  return <String, bool>{
    'isProductOutput': row.safetyFlags['isProductOutput'] ?? false,
    'isClassifierLabel': row.safetyFlags['isClassifierLabel'] ?? false,
    'hasNumericScore': row.safetyFlags['hasNumericScore'] ?? false,
    'hasAggregateScore': row.safetyFlags['hasAggregateScore'] ?? false,
    'ranksMoves': row.safetyFlags['ranksMoves'] ?? false,
    'isOfficialMetric': row.safetyFlags['isOfficialMetric'] ?? false,
    'exposesCpLoss': row.safetyFlags['cpLossOutputActive'] ?? false,
    'exposesWinProbability':
        row.safetyFlags['winProbabilityOutputActive'] ?? false,
    'exposesStockfishCommand':
        row.safetyFlags['stockfishCommandFieldActive'] ?? false,
    'exposesRawUci': row.safetyFlags['rawUciFieldActive'] ?? false,
    'exposesPvDump': row.safetyFlags['pvDumpFieldActive'] ?? false,
    'callsEngine': row.safetyFlags['callsEngine'] ?? false,
    'writesPersistence': row.safetyFlags['writesPersistence'] ?? false,
    'targetsUi': row.safetyFlags['targetsUi'] ?? false,
    'backendOutputActive': row.safetyFlags['backendOutputActive'] ?? false,
    'quietPreparatoryScopeActive':
        row.safetyFlags['quietPreparatoryScopeActive'] ?? false,
  };
}

void _checkSafetyFlags(
  void Function({
    required String id,
    required DebugBridgeDesignReadinessSeverity severity,
    required String message,
    String? readinessRecordId,
    DebugBridgeDesignReadinessGroupId? readinessGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugBridgeDesignReadinessRecord record,
) {
  void critical(String id, String message) {
    add(
      id: id,
      severity: DebugBridgeDesignReadinessSeverity.critical,
      message: message,
      readinessRecordId: record.readinessRecordId,
    );
  }

  if (record.safetyFlags['isProductOutput'] == true) {
    critical(
      'productOutputActive',
      'bridge readiness cannot be product output',
    );
  }
  if (record.safetyFlags['isClassifierLabel'] == true) {
    critical(
      'classifierLabelOutputActive',
      'bridge readiness cannot emit classifier labels',
    );
  }
  if (record.safetyFlags['hasNumericScore'] == true) {
    critical(
      'numericScoreOutputActive',
      'bridge readiness cannot emit numeric scores',
    );
  }
  if (record.safetyFlags['hasAggregateScore'] == true) {
    critical(
      'aggregateScoreOutputActive',
      'bridge readiness cannot emit aggregate scores',
    );
  }
  if (record.safetyFlags['ranksMoves'] == true) {
    critical('moveRankingOutputActive', 'bridge readiness cannot rank moves');
  }
  if (record.safetyFlags['isOfficialMetric'] == true) {
    critical(
      'officialMetricOutputActive',
      'bridge readiness cannot emit official metrics',
    );
  }
  if (record.safetyFlags['exposesCpLoss'] == true ||
      record.safetyFlags['exposesWinProbability'] == true) {
    critical(
      'futureMetricOutputActive',
      'bridge readiness cannot expose CP-loss or win probability',
    );
  }
  if (record.safetyFlags['quietPreparatoryScopeActive'] == true) {
    critical(
      'quietPreparatoryScopeActivated',
      'quiet/preparatory scope must remain excluded',
    );
  }
  if (record.safetyFlags['callsEngine'] == true) {
    critical('engineCallFlagActive', 'bridge readiness cannot call an engine');
  }
  if (record.safetyFlags['writesPersistence'] == true) {
    critical(
      'persistenceWriteFlagActive',
      'bridge readiness cannot write persistence',
    );
  }
  if (record.safetyFlags['targetsUi'] == true) {
    critical('uiTargetFlagActive', 'bridge readiness cannot target UI');
  }
  if (record.safetyFlags['backendOutputActive'] == true) {
    critical('backendOutputActive', 'bridge readiness cannot target backend');
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
    required DebugBridgeDesignReadinessSeverity severity,
    required String message,
    String? readinessRecordId,
    DebugBridgeDesignReadinessGroupId? readinessGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String fieldId, {
  String? readinessRecordId,
  DebugBridgeDesignReadinessGroupId? readinessGroupId,
}) {
  if (_isBlockedBridgeFieldId(fieldId) ||
      _isLegacyBlockedOutputFieldId(fieldId)) {
    add(
      id: 'activeBlockedBridgeField',
      severity: DebugBridgeDesignReadinessSeverity.critical,
      message: '$fieldId cannot be active bridge readiness output',
      readinessRecordId: readinessRecordId,
      readinessGroupId: readinessGroupId,
      fieldId: fieldId,
    );
  }
}

void _checkAndroidProofCase(
  void Function({
    required String id,
    required DebugBridgeDesignReadinessSeverity severity,
    required String message,
    String? readinessRecordId,
    DebugBridgeDesignReadinessGroupId? readinessGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String caseId,
  List<String> provenAndroidIds, {
  String? readinessRecordId,
  DebugBridgeDesignReadinessGroupId? readinessGroupId,
}) {
  if (_phase32ECaseIds.contains(caseId)) {
    add(
      id: 'phase32ECaseTreatedAsCapturedProof',
      severity: DebugBridgeDesignReadinessSeverity.critical,
      message: '$caseId cannot be treated as captured Android proof',
      readinessRecordId: readinessRecordId,
      readinessGroupId: readinessGroupId,
      caseId: caseId,
    );
    return;
  }
  if (!_capturedAndroidProofIds.contains(caseId) ||
      !provenAndroidIds.contains(caseId)) {
    add(
      id: 'unprovenAndroidProofId',
      severity: DebugBridgeDesignReadinessSeverity.critical,
      message: '$caseId is not captured Android proof',
      readinessRecordId: readinessRecordId,
      readinessGroupId: readinessGroupId,
      caseId: caseId,
    );
  }
}

bool _recordIsInactiveSafe(DebugBridgeDesignReadinessRecord record) {
  return record.inactive &&
      record.readinessRole.isInactiveBoundary &&
      record.activeFieldIds.isEmpty &&
      !record.hasUnsafeOutput;
}

bool _hasExplicitPvProofReason(DebugBridgeDesignReadinessGateResult result) {
  final reasons = <String>[
    ...result.warnings,
    ...result.failures,
    ...result.readinessGroups.expand((group) => group.warningReasons),
    ...result.readinessGroups.expand((group) => group.proofLimitReasons),
  ].join(' ').toLowerCase();
  return reasons.contains('pv') || reasons.contains('multipv');
}

int _countRecords(
  List<DebugBridgeDesignReadinessRecord> records,
  DebugBridgeDesignReadinessRecordStatus status,
) {
  return records.where((record) => record.readinessStatus == status).length;
}

bool _isCorePacketId(String packetId) {
  return packetId == 'packet-allowedEvidenceSummary' ||
      packetId == 'packet-improvedSupportSummary';
}

List<String> _provenAndroidProofIds(GoldenAndroidProofEvidence? evidence) {
  return _sortedStrings(evidence?.targetCaseIds ?? const <String>[]);
}

int _compareFindings(
  DebugBridgeDesignReadinessFinding a,
  DebugBridgeDesignReadinessFinding b,
) {
  final severity = _severityRank(
    b.severity,
  ).compareTo(_severityRank(a.severity));
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.readinessRecordId ?? '').compareTo(b.readinessRecordId ?? '');
}

int _severityRank(DebugBridgeDesignReadinessSeverity severity) {
  return switch (severity) {
    DebugBridgeDesignReadinessSeverity.warning => 1,
    DebugBridgeDesignReadinessSeverity.blocker => 2,
    DebugBridgeDesignReadinessSeverity.critical => 3,
  };
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

const _legacyBlockedOutputFieldIds = <String>[
  'uiOutputFields',
  'backendPersistenceFields',
  'directEngineCallFields',
];

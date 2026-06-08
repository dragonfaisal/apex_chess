/// Developer-only readiness validation gate for debug bridge summary output.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_summary_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugBridgeReadinessValidationGateReportVersion =
    'debug-bridge-readiness-validation-gate-v1';

enum DebugBridgeReadinessValidationGateStatus {
  readyForPrototypeDesignWithWarnings('readyForPrototypeDesignWithWarnings'),
  readyForPrototypeDesignClean('readyForPrototypeDesignClean'),
  blockedBySummaryValidationFailure('blockedBySummaryValidationFailure'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const DebugBridgeReadinessValidationGateStatus(this.wire);

  final String wire;
}

enum DebugBridgeReadinessValidationGateGroupId {
  prototypeReadyDebugCoreGroup('prototypeReadyDebugCoreGroup'),
  constrainedDebugContextGroup('constrainedDebugContextGroup'),
  inactiveDebugBlockedGroup('inactiveDebugBlockedGroup'),
  inactiveDebugFutureOnlyGroup('inactiveDebugFutureOnlyGroup'),
  prototypeReadyAllowedFieldGroup('prototypeReadyAllowedFieldGroup'),
  deniedFieldBoundaryGroup('deniedFieldBoundaryGroup'),
  stockfishRawUciPvDumpDeniedGroup('stockfishRawUciPvDumpDeniedGroup'),
  validatedAndroidProofBoundaryGroup('validatedAndroidProofBoundaryGroup'),
  emptyOwnerProofGateGroup('emptyOwnerProofGateGroup');

  const DebugBridgeReadinessValidationGateGroupId(this.wire);

  final String wire;
}

enum DebugBridgeReadinessValidationGateGroupStatus {
  prototypeReadyDebugCoreGroup('prototypeReadyDebugCoreGroup'),
  constrainedDebugContextGroup('constrainedDebugContextGroup'),
  inactiveDebugBlockedGroup('inactiveDebugBlockedGroup'),
  inactiveDebugFutureOnlyGroup('inactiveDebugFutureOnlyGroup'),
  prototypeReadyAllowedFieldGroup('prototypeReadyAllowedFieldGroup'),
  deniedFieldBoundaryGroup('deniedFieldBoundaryGroup'),
  stockfishRawUciPvDumpDeniedGroup('stockfishRawUciPvDumpDeniedGroup'),
  validatedAndroidProofBoundaryGroup('validatedAndroidProofBoundaryGroup'),
  emptyOwnerProofGateGroup('emptyOwnerProofGateGroup'),
  invalidGroup('invalidGroup'),
  unsafeGroup('unsafeGroup');

  const DebugBridgeReadinessValidationGateGroupStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == unsafeGroup;

  bool get isInvalid => this == invalidGroup;
}

enum DebugBridgeReadinessValidationGateRole {
  prototypeReadyDebugCore('prototypeReadyDebugCore'),
  constrainedDebugContext('constrainedDebugContext'),
  inactiveDebugBlocked('inactiveDebugBlocked'),
  inactiveDebugFutureOnly('inactiveDebugFutureOnly'),
  prototypeReadyAllowedField('prototypeReadyAllowedField'),
  deniedFieldBoundary('deniedFieldBoundary'),
  stockfishRawUciPvDumpDenied('stockfishRawUciPvDumpDenied'),
  validatedAndroidProofBoundary('validatedAndroidProofBoundary'),
  emptyOwnerProofGate('emptyOwnerProofGate');

  const DebugBridgeReadinessValidationGateRole(this.wire);

  final String wire;

  bool get isInactiveBoundary =>
      this == inactiveDebugBlocked ||
      this == inactiveDebugFutureOnly ||
      this == deniedFieldBoundary ||
      this == stockfishRawUciPvDumpDenied;
}

enum DebugBridgeReadinessValidationGateRecordStatus {
  prototypeReadyDebugCore('prototypeReadyDebugCore'),
  constrainedDebugContext('constrainedDebugContext'),
  inactiveDebugBlocked('inactiveDebugBlocked'),
  inactiveDebugFutureOnly('inactiveDebugFutureOnly'),
  prototypeReadyAllowedField('prototypeReadyAllowedField'),
  deniedFieldBoundary('deniedFieldBoundary'),
  stockfishRawUciPvDumpDenied('stockfishRawUciPvDumpDenied'),
  validatedAndroidProofBoundary('validatedAndroidProofBoundary'),
  emptyOwnerProofGate('emptyOwnerProofGate'),
  invalidGateRecord('invalidGateRecord'),
  unsafeGateRecord('unsafeGateRecord');

  const DebugBridgeReadinessValidationGateRecordStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == unsafeGateRecord;

  bool get isInvalid => this == invalidGateRecord;
}

enum DebugBridgeReadinessValidationGateRecommendation {
  allowPrototypeReadyDebugCoreForDesign(
    'allowPrototypeReadyDebugCoreForDesign',
  ),
  keepDebugContextConstrained('keepDebugContextConstrained'),
  keepDebugBlockedInactive('keepDebugBlockedInactive'),
  keepDebugFutureOnlyInactive('keepDebugFutureOnlyInactive'),
  allowInternalDebugFieldsForPrototypeDesign(
    'allowInternalDebugFieldsForPrototypeDesign',
  ),
  keepDeniedFieldsDenied('keepDeniedFieldsDenied'),
  keepStockfishRawUciPvDumpDenied('keepStockfishRawUciPvDumpDenied'),
  keepAndroidProofBoundaryCapturedOnly('keepAndroidProofBoundaryCapturedOnly'),
  keepOwnerProofEmpty('keepOwnerProofEmpty'),
  investigateGateFailure('investigateGateFailure'),
  blockUnsafeBridgeReadinessGate('blockUnsafeBridgeReadinessGate');

  const DebugBridgeReadinessValidationGateRecommendation(this.wire);

  final String wire;
}

enum DebugBridgeReadinessValidationGatePhase32ZRecommendation {
  proceedToDebugOnlyBridgePrototypeDesign(
    'proceedToDebugOnlyBridgePrototypeDesign',
  ),
  proceedToDebugBridgePrototypeDesignReadinessSummary(
    'proceedToDebugBridgePrototypeDesignReadinessSummary',
  ),
  proceedToDebugBridgeReadinessReportOnly(
    'proceedToDebugBridgeReadinessReportOnly',
  ),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeBridgeReadinessGate('blockedByUnsafeBridgeReadinessGate');

  const DebugBridgeReadinessValidationGatePhase32ZRecommendation(this.wire);

  final String wire;
}

enum DebugBridgeReadinessValidationGateSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const DebugBridgeReadinessValidationGateSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == DebugBridgeReadinessValidationGateSeverity.blocker ||
      this == DebugBridgeReadinessValidationGateSeverity.critical;

  bool get isCritical =>
      this == DebugBridgeReadinessValidationGateSeverity.critical;
}

enum DebugBridgeReadinessValidationGateReportFormat {
  markdown('markdown'),
  json('json');

  const DebugBridgeReadinessValidationGateReportFormat(this.wire);

  final String wire;
}

class DebugBridgeReadinessValidationGateRequest {
  const DebugBridgeReadinessValidationGateRequest({
    this.validationResult,
    this.summaryResult,
    this.readinessGateResult,
    this.bridgeValidationResult,
    this.validation = const DebugBridgeReadinessSummaryValidation(),
    this.summary = const DebugBridgeReadinessSummary(),
    this.readinessGate = const DebugBridgeDesignReadinessGate(),
    this.bridgeValidation = const DebugOnlyAdapterBridgeDesignValidation(),
    this.design = const DebugOnlyAdapterBridgeDesign(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const DebugBridgeReadinessValidationGateRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final DebugBridgeReadinessSummaryValidationResult? validationResult;
  final DebugBridgeReadinessSummaryResult? summaryResult;
  final DebugBridgeDesignReadinessGateResult? readinessGateResult;
  final DebugOnlyAdapterBridgeDesignValidationResult? bridgeValidationResult;
  final DebugBridgeReadinessSummaryValidation validation;
  final DebugBridgeReadinessSummary summary;
  final DebugBridgeDesignReadinessGate readinessGate;
  final DebugOnlyAdapterBridgeDesignValidation bridgeValidation;
  final DebugOnlyAdapterBridgeDesign design;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class DebugBridgeReadinessValidationGateGroup {
  const DebugBridgeReadinessValidationGateGroup({
    required this.groupId,
    required this.gateStatus,
    required this.sourceValidationRowIds,
    required this.sourceSummaryRecordIds,
    required this.sourceSummaryGroupIds,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.futurePrerequisites,
    required this.blockedBoundaryIds,
    required this.safeForFuturePrototypeDesign,
    required this.recommendation,
  });

  final DebugBridgeReadinessValidationGateGroupId groupId;
  final DebugBridgeReadinessValidationGateGroupStatus gateStatus;
  final List<String> sourceValidationRowIds;
  final List<String> sourceSummaryRecordIds;
  final List<String> sourceSummaryGroupIds;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> futurePrerequisites;
  final List<String> blockedBoundaryIds;
  final bool safeForFuturePrototypeDesign;
  final DebugBridgeReadinessValidationGateRecommendation recommendation;

  bool get hasUnsafeOutput =>
      gateStatus.isUnsafe ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId);

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'groupId': groupId.wire,
      'gateStatus': gateStatus.wire,
      'sourceValidationRowIds': sourceValidationRowIds,
      'sourceSummaryRecordIds': sourceSummaryRecordIds,
      'sourceSummaryGroupIds': sourceSummaryGroupIds,
      'allowedFieldIds': allowedFieldIds,
      'deniedFieldIds': deniedFieldIds,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'futurePrerequisites': futurePrerequisites,
      'blockedBoundaryIds': blockedBoundaryIds,
      'safeForFuturePrototypeDesign': safeForFuturePrototypeDesign,
      'recommendation': recommendation.wire,
    };
  }
}

class DebugBridgeReadinessValidationGateRecord {
  const DebugBridgeReadinessValidationGateRecord({
    required this.gateRecordId,
    required this.sourceValidationRowId,
    required this.sourceSummaryRecordId,
    required this.sourceSummaryGroupId,
    required this.gateRole,
    required this.gateStatus,
    required this.allowedForFuturePrototypeDesign,
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
  final String sourceSummaryRecordId;
  final String sourceSummaryGroupId;
  final DebugBridgeReadinessValidationGateRole gateRole;
  final DebugBridgeReadinessValidationGateRecordStatus gateStatus;
  final bool allowedForFuturePrototypeDesign;
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
  final DebugBridgeReadinessValidationGateRecommendation recommendation;

  bool get hasUnsafeOutput =>
      gateStatus.isUnsafe ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId) ||
      safetyFlags.values.any((value) => value);

  DebugBridgeReadinessValidationGateRecord copyWith({
    String? gateRecordId,
    String? sourceValidationRowId,
    String? sourceSummaryRecordId,
    String? sourceSummaryGroupId,
    DebugBridgeReadinessValidationGateRole? gateRole,
    DebugBridgeReadinessValidationGateRecordStatus? gateStatus,
    bool? allowedForFuturePrototypeDesign,
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
    DebugBridgeReadinessValidationGateRecommendation? recommendation,
  }) {
    return DebugBridgeReadinessValidationGateRecord(
      gateRecordId: gateRecordId ?? this.gateRecordId,
      sourceValidationRowId:
          sourceValidationRowId ?? this.sourceValidationRowId,
      sourceSummaryRecordId:
          sourceSummaryRecordId ?? this.sourceSummaryRecordId,
      sourceSummaryGroupId: sourceSummaryGroupId ?? this.sourceSummaryGroupId,
      gateRole: gateRole ?? this.gateRole,
      gateStatus: gateStatus ?? this.gateStatus,
      allowedForFuturePrototypeDesign:
          allowedForFuturePrototypeDesign ??
          this.allowedForFuturePrototypeDesign,
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

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'gateRecordId': gateRecordId,
      'sourceValidationRowId': sourceValidationRowId,
      'sourceSummaryRecordId': sourceSummaryRecordId,
      'sourceSummaryGroupId': sourceSummaryGroupId,
      'gateRole': gateRole.wire,
      'gateStatus': gateStatus.wire,
      'allowedForFuturePrototypeDesign': allowedForFuturePrototypeDesign,
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
}

class DebugBridgeReadinessValidationGateFinding {
  const DebugBridgeReadinessValidationGateFinding({
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
  final DebugBridgeReadinessValidationGateSeverity severity;
  final String message;
  final String? gateRecordId;
  final String? sourceValidationRowId;
  final DebugBridgeReadinessValidationGateGroupId? groupId;
  final String? fieldId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical => severity.isCritical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
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
}

class DebugBridgeReadinessValidationGateResult {
  const DebugBridgeReadinessValidationGateResult({
    required this.gateStatus,
    required this.sourceValidationStatus,
    required this.sourceSummaryStatus,
    required this.sourceReadinessStatus,
    required this.gateGroups,
    required this.gateRecords,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalGateGroups,
    required this.totalGateRecords,
    required this.prototypeReadyDebugCoreCount,
    required this.constrainedDebugContextCount,
    required this.inactiveBlockedCount,
    required this.inactiveFutureOnlyCount,
    required this.prototypeReadyAllowedFieldCount,
    required this.deniedFieldCount,
    required this.stockfishRawUciPvDumpDeniedCount,
    required this.unsafeCount,
    required this.blockerCount,
    required this.criticalCount,
    required this.ownerProofQueueCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.safeForPhase32Z,
    required this.phase32ZRecommendation,
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

  final DebugBridgeReadinessValidationGateStatus gateStatus;
  final DebugBridgeReadinessSummaryValidationStatus sourceValidationStatus;
  final DebugBridgeReadinessSummaryStatus sourceSummaryStatus;
  final DebugBridgeDesignReadinessGateStatus sourceReadinessStatus;
  final List<DebugBridgeReadinessValidationGateGroup> gateGroups;
  final List<DebugBridgeReadinessValidationGateRecord> gateRecords;
  final List<DebugBridgeReadinessValidationGateFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalGateGroups;
  final int totalGateRecords;
  final int prototypeReadyDebugCoreCount;
  final int constrainedDebugContextCount;
  final int inactiveBlockedCount;
  final int inactiveFutureOnlyCount;
  final int prototypeReadyAllowedFieldCount;
  final int deniedFieldCount;
  final int stockfishRawUciPvDumpDeniedCount;
  final int unsafeCount;
  final int blockerCount;
  final int criticalCount;
  final int ownerProofQueueCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final bool safeForPhase32Z;
  final DebugBridgeReadinessValidationGatePhase32ZRecommendation
  phase32ZRecommendation;
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
      gateStatus ==
          DebugBridgeReadinessValidationGateStatus
              .blockedBySummaryValidationFailure ||
      gateStatus ==
          DebugBridgeReadinessValidationGateStatus.blockedByPolicyBoundary ||
      gateStatus == DebugBridgeReadinessValidationGateStatus.invalid ||
      !safeForPhase32Z ||
      unsafeCount > 0 ||
      blockerCount > 0 ||
      criticalCount > 0 ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeDebugBridgeReadinessValidationGatePolicyViolation {
    return gateStatus ==
            DebugBridgeReadinessValidationGateStatus
                .blockedBySummaryValidationFailure ||
        gateStatus ==
            DebugBridgeReadinessValidationGateStatus.blockedByPolicyBoundary ||
        unsafeCount > 0 ||
        criticalCount > 0 ||
        validationFindings.any((finding) => finding.isCritical) ||
        allowedFieldIds.any(_isDeniedFieldId) ||
        allowedFieldIds.any(_isLegacyDeniedFieldId) ||
        gateGroups.any((group) => group.hasUnsafeOutput) ||
        gateRecords.any((record) => record.hasUnsafeOutput) ||
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

  DebugBridgeReadinessValidationGateGroup group(
    DebugBridgeReadinessValidationGateGroupId groupId,
  ) {
    return gateGroups.singleWhere((group) => group.groupId == groupId);
  }

  DebugBridgeReadinessValidationGateRecord recordForRole(
    DebugBridgeReadinessValidationGateRole role,
  ) {
    return gateRecords.singleWhere((record) => record.gateRole == role);
  }

  List<DebugBridgeReadinessValidationGateRecord>
  get prototypeReadyDebugCoreRecords => gateRecords
      .where(
        (record) =>
            record.gateRole ==
            DebugBridgeReadinessValidationGateRole.prototypeReadyDebugCore,
      )
      .toList(growable: false);

  List<DebugBridgeReadinessValidationGateRecord>
  get constrainedDebugContextRecords => gateRecords
      .where(
        (record) =>
            record.gateRole ==
            DebugBridgeReadinessValidationGateRole.constrainedDebugContext,
      )
      .toList(growable: false);

  List<DebugBridgeReadinessValidationGateRecord> get inactiveBoundaryRecords =>
      gateRecords
          .where((record) => record.gateRole.isInactiveBoundary)
          .toList(growable: false);

  DebugBridgeReadinessValidationGateResult copyWith({
    DebugBridgeReadinessValidationGateStatus? gateStatus,
    DebugBridgeReadinessSummaryValidationStatus? sourceValidationStatus,
    DebugBridgeReadinessSummaryStatus? sourceSummaryStatus,
    DebugBridgeDesignReadinessGateStatus? sourceReadinessStatus,
    List<DebugBridgeReadinessValidationGateGroup>? gateGroups,
    List<DebugBridgeReadinessValidationGateRecord>? gateRecords,
    List<DebugBridgeReadinessValidationGateFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalGateGroups,
    int? totalGateRecords,
    int? prototypeReadyDebugCoreCount,
    int? constrainedDebugContextCount,
    int? inactiveBlockedCount,
    int? inactiveFutureOnlyCount,
    int? prototypeReadyAllowedFieldCount,
    int? deniedFieldCount,
    int? stockfishRawUciPvDumpDeniedCount,
    int? unsafeCount,
    int? blockerCount,
    int? criticalCount,
    int? ownerProofQueueCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    bool? safeForPhase32Z,
    DebugBridgeReadinessValidationGatePhase32ZRecommendation?
    phase32ZRecommendation,
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
    return DebugBridgeReadinessValidationGateResult(
      gateStatus: gateStatus ?? this.gateStatus,
      sourceValidationStatus:
          sourceValidationStatus ?? this.sourceValidationStatus,
      sourceSummaryStatus: sourceSummaryStatus ?? this.sourceSummaryStatus,
      sourceReadinessStatus:
          sourceReadinessStatus ?? this.sourceReadinessStatus,
      gateGroups: gateGroups ?? this.gateGroups,
      gateRecords: gateRecords ?? this.gateRecords,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalGateGroups: totalGateGroups ?? this.totalGateGroups,
      totalGateRecords: totalGateRecords ?? this.totalGateRecords,
      prototypeReadyDebugCoreCount:
          prototypeReadyDebugCoreCount ?? this.prototypeReadyDebugCoreCount,
      constrainedDebugContextCount:
          constrainedDebugContextCount ?? this.constrainedDebugContextCount,
      inactiveBlockedCount: inactiveBlockedCount ?? this.inactiveBlockedCount,
      inactiveFutureOnlyCount:
          inactiveFutureOnlyCount ?? this.inactiveFutureOnlyCount,
      prototypeReadyAllowedFieldCount:
          prototypeReadyAllowedFieldCount ??
          this.prototypeReadyAllowedFieldCount,
      deniedFieldCount: deniedFieldCount ?? this.deniedFieldCount,
      stockfishRawUciPvDumpDeniedCount:
          stockfishRawUciPvDumpDeniedCount ??
          this.stockfishRawUciPvDumpDeniedCount,
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
      safeForPhase32Z: safeForPhase32Z ?? this.safeForPhase32Z,
      phase32ZRecommendation:
          phase32ZRecommendation ?? this.phase32ZRecommendation,
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
      ..writeln('# Debug Bridge Readiness Validation Gate')
      ..writeln()
      ..writeln('- version: $debugBridgeReadinessValidationGateReportVersion')
      ..writeln('- gate status: ${gateStatus.wire}')
      ..writeln('- source validation status: ${sourceValidationStatus.wire}')
      ..writeln('- source summary status: ${sourceSummaryStatus.wire}')
      ..writeln('- total gate groups: $totalGateGroups')
      ..writeln('- total gate records: $totalGateRecords')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- safeForPhase32Z: $safeForPhase32Z')
      ..writeln('- Phase 32Z recommendation: ${phase32ZRecommendation.wire}')
      ..writeln()
      ..writeln('## Gate Group Table')
      ..writeln(
        '| Group | Status | Allowed fields | Denied fields | Safe | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- |');
    for (final group in gateGroups) {
      buffer.writeln(
        '| ${group.groupId.wire} | ${group.gateStatus.wire} | ${_ids(group.allowedFieldIds)} | ${_ids(group.deniedFieldIds)} | ${group.safeForFuturePrototypeDesign} | ${group.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Gate Record Table')
      ..writeln(
        '| Record | Role | Status | Allowed fields | Denied fields | Safe flags | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
    for (final record in gateRecords) {
      buffer.writeln(
        '| ${_cell(record.gateRecordId)} | ${record.gateRole.wire} | ${record.gateStatus.wire} | ${_ids(record.allowedFieldIds)} | ${_ids(record.deniedFieldIds)} | ${record.safetyFlags.values.any((value) => value)} | ${record.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Prototype-Ready Debug Core Records')
      ..writeln('- count: $prototypeReadyDebugCoreCount')
      ..writeln()
      ..writeln('## Constrained Debug Context Records')
      ..writeln('- count: $constrainedDebugContextCount')
      ..writeln()
      ..writeln('## Inactive Blocked/Future Records')
      ..writeln('- inactive blocked count: $inactiveBlockedCount')
      ..writeln('- inactive future-only count: $inactiveFutureOnlyCount')
      ..writeln()
      ..writeln('## Allowed And Denied Field Boundaries')
      ..writeln('- allowed fields: ${_ids(allowedFieldIds)}')
      ..writeln('- denied fields: ${_ids(deniedFieldIds)}')
      ..writeln()
      ..writeln('## Stockfish Raw UCI PV Dump Denied Boundary')
      ..writeln(
        '- stockfishCommand denied: ${deniedFieldIds.contains('stockfishCommand')}',
      )
      ..writeln('- rawUci denied: ${deniedFieldIds.contains('rawUci')}')
      ..writeln('- pvDump denied: ${deniedFieldIds.contains('pvDump')}')
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
      ..writeln('## Phase 32Z Recommendation')
      ..writeln('- ${phase32ZRecommendation.wire}');
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': debugBridgeReadinessValidationGateReportVersion,
      'gateStatus': gateStatus.wire,
      'sourceValidationStatus': sourceValidationStatus.wire,
      'sourceSummaryStatus': sourceSummaryStatus.wire,
      'sourceReadinessStatus': sourceReadinessStatus.wire,
      'totalGateGroups': totalGateGroups,
      'totalGateRecords': totalGateRecords,
      'prototypeReadyDebugCoreCount': prototypeReadyDebugCoreCount,
      'constrainedDebugContextCount': constrainedDebugContextCount,
      'inactiveBlockedCount': inactiveBlockedCount,
      'inactiveFutureOnlyCount': inactiveFutureOnlyCount,
      'prototypeReadyAllowedFieldCount': prototypeReadyAllowedFieldCount,
      'deniedFieldCount': deniedFieldCount,
      'stockfishRawUciPvDumpDeniedCount': stockfishRawUciPvDumpDeniedCount,
      'unsafeCount': unsafeCount,
      'blockerCount': blockerCount,
      'criticalCount': criticalCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'allowedFieldIds': allowedFieldIds,
      'deniedFieldIds': deniedFieldIds,
      'safeForPhase32Z': safeForPhase32Z,
      'phase32ZRecommendation': phase32ZRecommendation.wire,
      'gateGroups': gateGroups.map((group) => group.toJson()).toList(),
      'gateRecords': gateRecords.map((record) => record.toJson()).toList(),
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

class DebugBridgeReadinessValidationGate {
  const DebugBridgeReadinessValidationGate({
    this.validator = const DebugBridgeReadinessValidationGateValidator(),
  });

  final DebugBridgeReadinessValidationGateValidator validator;

  DebugBridgeReadinessValidationGateResult evaluate([
    DebugBridgeReadinessValidationGateRequest request =
        const DebugBridgeReadinessValidationGateRequest(),
  ]) {
    final bridgeValidationResult =
        request.bridgeValidationResult ?? request.bridgeValidation.evaluate();
    final readinessGateResult =
        request.readinessGateResult ??
        request.readinessGate.evaluate(
          DebugBridgeDesignReadinessGateRequest(
            validationResult: bridgeValidationResult,
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
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final validationResult =
        request.validationResult ??
        request.validation.evaluate(
          DebugBridgeReadinessSummaryValidationRequest(
            summaryResult: summaryResult,
            readinessGateResult: readinessGateResult,
            bridgeValidationResult: bridgeValidationResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final groups = _groupsFromValidation(validationResult, summaryResult);
    final records = _recordsFromValidation(validationResult, summaryResult);
    final base = _resultFromGateRows(
      validationResult: validationResult,
      summaryResult: summaryResult,
      readinessGateResult: readinessGateResult,
      groups: groups,
      records: records,
      validationFindings: const <DebugBridgeReadinessValidationGateFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromGateRows(
      validationResult: validationResult,
      summaryResult: summaryResult,
      readinessGateResult: readinessGateResult,
      groups: groups,
      records: records,
      validationFindings: findings,
    );
  }
}

class DebugBridgeReadinessValidationGateValidator {
  const DebugBridgeReadinessValidationGateValidator();

  List<DebugBridgeReadinessValidationGateFinding> validate(
    DebugBridgeReadinessValidationGateResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <DebugBridgeReadinessValidationGateFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required DebugBridgeReadinessValidationGateSeverity severity,
      required String message,
      String? gateRecordId,
      String? sourceValidationRowId,
      DebugBridgeReadinessValidationGateGroupId? groupId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        DebugBridgeReadinessValidationGateFinding(
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

    if (result.safeForPhase32Z &&
        (result.sourceValidationStatus ==
                DebugBridgeReadinessSummaryValidationStatus
                    .blockedByUnsafeSummary ||
            result.sourceValidationStatus ==
                DebugBridgeReadinessSummaryValidationStatus
                    .blockedByPolicyBoundary ||
            result.unsafeCount > 0)) {
      add(
        id: 'unsafeSummaryValidationMarkedGateReady',
        severity: DebugBridgeReadinessValidationGateSeverity.critical,
        message: 'unsafe summary validation cannot be marked gate-ready',
      );
    }
    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: DebugBridgeReadinessValidationGateSeverity.blocker,
        message: 'owner proof requires explicit PV/MultiPV reason',
      );
    }
    for (final fieldId in _deniedFieldIds) {
      if (!result.deniedFieldIds.contains(fieldId)) {
        add(
          id: 'deniedFieldMissing',
          severity: DebugBridgeReadinessValidationGateSeverity.blocker,
          message: '$fieldId must remain denied',
          fieldId: fieldId,
        );
      }
    }
    for (final fieldId in result.allowedFieldIds) {
      _checkActiveAllowedField(add, fieldId);
    }
    for (final caseId in result.androidProofCaseIds) {
      _checkAndroidProofCase(add, caseId, provenAndroidIds);
    }
    for (final group in result.gateGroups) {
      for (final fieldId in group.allowedFieldIds) {
        _checkActiveAllowedField(add, fieldId, groupId: group.groupId);
      }
      for (final caseId in group.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          groupId: group.groupId,
        );
      }
    }
    for (final record in result.gateRecords) {
      for (final fieldId in record.allowedFieldIds) {
        _checkActiveAllowedField(
          add,
          fieldId,
          gateRecordId: record.gateRecordId,
          sourceValidationRowId: record.sourceValidationRowId,
        );
      }
      for (final caseId in record.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          gateRecordId: record.gateRecordId,
          sourceValidationRowId: record.sourceValidationRowId,
        );
      }
      if (record.gateStatus ==
              DebugBridgeReadinessValidationGateRecordStatus
                  .prototypeReadyDebugCore &&
          record.violationReasons.contains(
            'prototypeCoreConsumesNonCoreInput',
          )) {
        add(
          id: 'prototypeReadyCoreConsumesNonCoreInput',
          severity: DebugBridgeReadinessValidationGateSeverity.critical,
          message: 'prototype-ready core cannot consume non-core input',
          gateRecordId: record.gateRecordId,
          sourceValidationRowId: record.sourceValidationRowId,
        );
      }
      if (record.contextOnly &&
          record.gateStatus ==
              DebugBridgeReadinessValidationGateRecordStatus
                  .prototypeReadyDebugCore) {
        add(
          id: 'contextOnlyInputPromotedToPrototypeReadyCore',
          severity: DebugBridgeReadinessValidationGateSeverity.critical,
          message: 'context-only input cannot become prototype-ready core',
          gateRecordId: record.gateRecordId,
          sourceValidationRowId: record.sourceValidationRowId,
        );
      }
      if (record.gateRole.isInactiveBoundary &&
          !_recordIsInactiveSafe(record)) {
        add(
          id: 'blockedFutureInputMadeActive',
          severity: DebugBridgeReadinessValidationGateSeverity.critical,
          message: 'blocked/future/denied inputs must remain inactive',
          gateRecordId: record.gateRecordId,
          sourceValidationRowId: record.sourceValidationRowId,
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
        id: 'debugBridgeReadinessValidationGateBoundaryPolicyViolation',
        severity: DebugBridgeReadinessValidationGateSeverity.critical,
        message: 'debug bridge readiness validation gate crossed a boundary',
      );
    }
    return findings..sort(_compareFindings);
  }

  List<DebugBridgeReadinessValidationGateFinding> validateReportText(
    String reportText,
  ) {
    final findings = <DebugBridgeReadinessValidationGateFinding>[];
    void reportError(String id, String message) {
      findings.add(
        DebugBridgeReadinessValidationGateFinding(
          id: id,
          severity: DebugBridgeReadinessValidationGateSeverity.critical,
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
      if (lower.contains('allowed fields: ${fieldId.toLowerCase()}')) {
        reportError(
          'activeDeniedFieldReportText',
          'report contains denied active field text',
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

List<DebugBridgeReadinessValidationGateGroup> _groupsFromValidation(
  DebugBridgeReadinessSummaryValidationResult validationResult,
  DebugBridgeReadinessSummaryResult summaryResult,
) {
  return <DebugBridgeReadinessValidationGateGroup>[
    _group(
      validationResult,
      summaryResult,
      DebugBridgeReadinessSummaryGroupId.readyDebugCoreInputSummary,
      DebugBridgeReadinessValidationGateGroupId.prototypeReadyDebugCoreGroup,
      DebugBridgeReadinessValidationGateGroupStatus
          .prototypeReadyDebugCoreGroup,
      DebugBridgeReadinessValidationGateRecommendation
          .allowPrototypeReadyDebugCoreForDesign,
    ),
    _group(
      validationResult,
      summaryResult,
      DebugBridgeReadinessSummaryGroupId.constrainedDebugContextInputSummary,
      DebugBridgeReadinessValidationGateGroupId.constrainedDebugContextGroup,
      DebugBridgeReadinessValidationGateGroupStatus
          .constrainedDebugContextGroup,
      DebugBridgeReadinessValidationGateRecommendation
          .keepDebugContextConstrained,
    ),
    _group(
      validationResult,
      summaryResult,
      DebugBridgeReadinessSummaryGroupId.inactiveDebugBlockedInputSummary,
      DebugBridgeReadinessValidationGateGroupId.inactiveDebugBlockedGroup,
      DebugBridgeReadinessValidationGateGroupStatus.inactiveDebugBlockedGroup,
      DebugBridgeReadinessValidationGateRecommendation.keepDebugBlockedInactive,
    ),
    _group(
      validationResult,
      summaryResult,
      DebugBridgeReadinessSummaryGroupId.inactiveDebugFutureOnlyInputSummary,
      DebugBridgeReadinessValidationGateGroupId.inactiveDebugFutureOnlyGroup,
      DebugBridgeReadinessValidationGateGroupStatus
          .inactiveDebugFutureOnlyGroup,
      DebugBridgeReadinessValidationGateRecommendation
          .keepDebugFutureOnlyInactive,
    ),
    _group(
      validationResult,
      summaryResult,
      DebugBridgeReadinessSummaryGroupId.readyAllowedDebugFieldSummary,
      DebugBridgeReadinessValidationGateGroupId.prototypeReadyAllowedFieldGroup,
      DebugBridgeReadinessValidationGateGroupStatus
          .prototypeReadyAllowedFieldGroup,
      DebugBridgeReadinessValidationGateRecommendation
          .allowInternalDebugFieldsForPrototypeDesign,
    ),
    _group(
      validationResult,
      summaryResult,
      DebugBridgeReadinessSummaryGroupId.deniedBlockedDebugFieldSummary,
      DebugBridgeReadinessValidationGateGroupId.deniedFieldBoundaryGroup,
      DebugBridgeReadinessValidationGateGroupStatus.deniedFieldBoundaryGroup,
      DebugBridgeReadinessValidationGateRecommendation.keepDeniedFieldsDenied,
    ),
    _group(
      validationResult,
      summaryResult,
      DebugBridgeReadinessSummaryGroupId.stockfishRawUciPvDumpBlockedSummary,
      DebugBridgeReadinessValidationGateGroupId
          .stockfishRawUciPvDumpDeniedGroup,
      DebugBridgeReadinessValidationGateGroupStatus
          .stockfishRawUciPvDumpDeniedGroup,
      DebugBridgeReadinessValidationGateRecommendation
          .keepStockfishRawUciPvDumpDenied,
    ),
    _group(
      validationResult,
      summaryResult,
      DebugBridgeReadinessSummaryGroupId.androidProofBoundarySummary,
      DebugBridgeReadinessValidationGateGroupId
          .validatedAndroidProofBoundaryGroup,
      DebugBridgeReadinessValidationGateGroupStatus
          .validatedAndroidProofBoundaryGroup,
      DebugBridgeReadinessValidationGateRecommendation
          .keepAndroidProofBoundaryCapturedOnly,
    ),
    _group(
      validationResult,
      summaryResult,
      DebugBridgeReadinessSummaryGroupId.ownerProofStatusSummary,
      DebugBridgeReadinessValidationGateGroupId.emptyOwnerProofGateGroup,
      DebugBridgeReadinessValidationGateGroupStatus.emptyOwnerProofGateGroup,
      DebugBridgeReadinessValidationGateRecommendation.keepOwnerProofEmpty,
    ),
  ];
}

DebugBridgeReadinessValidationGateGroup _group(
  DebugBridgeReadinessSummaryValidationResult validationResult,
  DebugBridgeReadinessSummaryResult summaryResult,
  DebugBridgeReadinessSummaryGroupId sourceGroupId,
  DebugBridgeReadinessValidationGateGroupId groupId,
  DebugBridgeReadinessValidationGateGroupStatus validStatus,
  DebugBridgeReadinessValidationGateRecommendation recommendation,
) {
  final validationRow = validationResult.groupRowForGroup(sourceGroupId);
  final summaryGroup = summaryResult.group(sourceGroupId);
  final unsafe = validationRow.hasUnsafeOutput;
  final invalid = !unsafe && !validationRow.safeForNextPhase;
  return DebugBridgeReadinessValidationGateGroup(
    groupId: groupId,
    gateStatus: unsafe
        ? DebugBridgeReadinessValidationGateGroupStatus.unsafeGroup
        : invalid
        ? DebugBridgeReadinessValidationGateGroupStatus.invalidGroup
        : validStatus,
    sourceValidationRowIds: <String>[validationRow.validationRowId],
    sourceSummaryRecordIds: _sortedStrings(validationRow.summaryRecordIds),
    sourceSummaryGroupIds: <String>[sourceGroupId.wire],
    allowedFieldIds: _sortedStrings(validationRow.activeFieldIds),
    deniedFieldIds: _sortedStrings(validationRow.deniedFieldIds),
    supportCaseIds: _sortedStrings(validationRow.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(
      validationRow.newlyAddedSupportCaseIds,
    ),
    androidProofCaseIds: _sortedStrings(validationRow.androidProofCaseIds),
    warningReasons: _sortedStrings(<String>[
      validationRow.warningReason,
      ...summaryGroup.warningReasons,
    ]),
    proofLimitReasons: _sortedStrings(summaryGroup.proofLimitReasons),
    futurePrerequisites: _sortedStrings(summaryGroup.futurePrerequisites),
    blockedBoundaryIds: _sortedStrings(summaryGroup.blockedBoundaryIds),
    safeForFuturePrototypeDesign: !unsafe && !invalid,
    recommendation: unsafe
        ? DebugBridgeReadinessValidationGateRecommendation
              .blockUnsafeBridgeReadinessGate
        : invalid
        ? DebugBridgeReadinessValidationGateRecommendation
              .investigateGateFailure
        : recommendation,
  );
}

List<DebugBridgeReadinessValidationGateRecord> _recordsFromValidation(
  DebugBridgeReadinessSummaryValidationResult validationResult,
  DebugBridgeReadinessSummaryResult summaryResult,
) {
  return validationResult.recordRows
      .map((row) => _record(row, summaryResult.recordForRole(row.summaryRole)))
      .toList(growable: false);
}

DebugBridgeReadinessValidationGateRecord _record(
  DebugBridgeReadinessSummaryRecordValidationRow row,
  DebugBridgeReadinessSummaryRecord summaryRecord,
) {
  final role = _roleForSummaryRole(row.summaryRole);
  final unsafe = row.hasUnsafeOutput;
  final invalid =
      !unsafe && (!row.safeForNextPhase || row.violationReasons.isNotEmpty);
  final status = unsafe
      ? DebugBridgeReadinessValidationGateRecordStatus.unsafeGateRecord
      : invalid
      ? DebugBridgeReadinessValidationGateRecordStatus.invalidGateRecord
      : _recordStatusForRole(role);
  return DebugBridgeReadinessValidationGateRecord(
    gateRecordId: 'debug-readiness-gate-${row.sourceSummaryRecordId}',
    sourceValidationRowId: row.validationRowId,
    sourceSummaryRecordId: row.sourceSummaryRecordId,
    sourceSummaryGroupId: _sourceGroupForRole(row.summaryRole).wire,
    gateRole: role,
    gateStatus: status,
    allowedForFuturePrototypeDesign:
        role ==
            DebugBridgeReadinessValidationGateRole.prototypeReadyDebugCore ||
        role ==
            DebugBridgeReadinessValidationGateRole.prototypeReadyAllowedField ||
        role ==
            DebugBridgeReadinessValidationGateRole
                .validatedAndroidProofBoundary ||
        role == DebugBridgeReadinessValidationGateRole.emptyOwnerProofGate,
    contextOnly:
        role == DebugBridgeReadinessValidationGateRole.constrainedDebugContext,
    inactive: role.isInactiveBoundary,
    allowedFieldIds: _sortedStrings(row.activeFieldIds),
    deniedFieldIds: _sortedStrings(row.deniedFieldIds),
    supportCaseIds: _sortedStrings(row.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(row.newlyAddedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(row.androidProofCaseIds),
    warningReasons: _sortedStrings(summaryRecord.warningReasons),
    proofLimitReasons: _sortedStrings(summaryRecord.proofLimitReasons),
    futurePrerequisites: _sortedStrings(summaryRecord.futurePrerequisites),
    blockedBoundaryIds: _sortedStrings(summaryRecord.blockedBoundaryIds),
    safetyFlags: _safeFlagsFrom(row.safetyFlags),
    violationReasons: _sortedStrings(row.violationReasons),
    recommendation: unsafe
        ? DebugBridgeReadinessValidationGateRecommendation
              .blockUnsafeBridgeReadinessGate
        : invalid
        ? DebugBridgeReadinessValidationGateRecommendation
              .investigateGateFailure
        : _recommendationForRole(role),
  );
}

DebugBridgeReadinessValidationGateResult _resultFromGateRows({
  required DebugBridgeReadinessSummaryValidationResult validationResult,
  required DebugBridgeReadinessSummaryResult summaryResult,
  required DebugBridgeDesignReadinessGateResult readinessGateResult,
  required List<DebugBridgeReadinessValidationGateGroup> groups,
  required List<DebugBridgeReadinessValidationGateRecord> records,
  required List<DebugBridgeReadinessValidationGateFinding> validationFindings,
}) {
  final unsafeCount =
      validationResult.unsafeRecordCount +
      groups.where((group) => group.hasUnsafeOutput).length +
      records.where((record) => record.hasUnsafeOutput).length;
  final blockerCount =
      validationResult.blockerCount +
      validationFindings.where((finding) => finding.blocksStrict).length;
  final criticalCount =
      validationResult.criticalCount +
      validationFindings.where((finding) => finding.isCritical).length;
  final base = DebugBridgeReadinessValidationGateResult(
    gateStatus: DebugBridgeReadinessValidationGateStatus.invalid,
    sourceValidationStatus: validationResult.validationStatus,
    sourceSummaryStatus: summaryResult.summaryStatus,
    sourceReadinessStatus: readinessGateResult.readinessStatus,
    gateGroups: groups,
    gateRecords: records,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...validationResult.warnings,
      'debug bridge runtime remains unimplemented',
      'debug bridge prototype remains unimplemented',
    ]),
    failures: _sortedStrings(<String>[
      ...validationResult.failures,
      ...validationFindings.map((finding) => finding.message),
      ...records.expand((record) => record.violationReasons),
    ]),
    totalGateGroups: groups.length,
    totalGateRecords: records.length,
    prototypeReadyDebugCoreCount: records
        .where(
          (record) =>
              record.gateStatus ==
              DebugBridgeReadinessValidationGateRecordStatus
                  .prototypeReadyDebugCore,
        )
        .length,
    constrainedDebugContextCount: records
        .where(
          (record) =>
              record.gateStatus ==
              DebugBridgeReadinessValidationGateRecordStatus
                  .constrainedDebugContext,
        )
        .length,
    inactiveBlockedCount: records
        .where(
          (record) =>
              record.gateStatus ==
              DebugBridgeReadinessValidationGateRecordStatus
                  .inactiveDebugBlocked,
        )
        .length,
    inactiveFutureOnlyCount: records
        .where(
          (record) =>
              record.gateStatus ==
              DebugBridgeReadinessValidationGateRecordStatus
                  .inactiveDebugFutureOnly,
        )
        .length,
    prototypeReadyAllowedFieldCount: validationResult.allowedFieldIds.length,
    deniedFieldCount: validationResult.deniedFieldIds.length,
    stockfishRawUciPvDumpDeniedCount: _engineDumpFieldIds
        .where(validationResult.deniedFieldIds.contains)
        .length,
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
    deniedFieldIds: _sortedStrings(validationResult.deniedFieldIds),
    safeForPhase32Z: false,
    phase32ZRecommendation:
        DebugBridgeReadinessValidationGatePhase32ZRecommendation
            .addMoreGoldenCoverageFirst,
    developerOnly:
        validationResult.developerOnly &&
        summaryResult.developerOnly &&
        readinessGateResult.developerOnly,
    debugBridgeRuntimeImplemented:
        validationResult.debugBridgeRuntimeImplemented,
    debugBridgePrototypeImplemented:
        validationResult.debugBridgePrototypeImplemented,
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
  final status = _gateStatusFor(base, validationResult);
  final safeForPhase32Z =
      (status ==
              DebugBridgeReadinessValidationGateStatus
                  .readyForPrototypeDesignWithWarnings ||
          status ==
              DebugBridgeReadinessValidationGateStatus
                  .readyForPrototypeDesignClean) &&
      validationResult.safeForPhase32Y &&
      !validationResult.isStrictlyBlocked &&
      !validationResult
          .hasUnsafeDebugBridgeReadinessSummaryValidationPolicyViolation &&
      unsafeCount == 0 &&
      blockerCount == 0 &&
      criticalCount == 0 &&
      validationFindings.every((finding) => !finding.blocksStrict) &&
      groups.every((group) => group.safeForFuturePrototypeDesign) &&
      records.every((record) => !record.hasUnsafeOutput);
  return base.copyWith(
    gateStatus: status,
    safeForPhase32Z: safeForPhase32Z,
    phase32ZRecommendation: _phase32ZRecommendationFor(
      status: status,
      safeForPhase32Z: safeForPhase32Z,
      ownerProofQueueCount: validationResult.ownerProofQueueCount,
    ),
  );
}

DebugBridgeReadinessValidationGateStatus _gateStatusFor(
  DebugBridgeReadinessValidationGateResult result,
  DebugBridgeReadinessSummaryValidationResult validationResult,
) {
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
      result.allowedFieldIds.any(_isDeniedFieldId) ||
      result.allowedFieldIds.any(_isLegacyDeniedFieldId)) {
    return DebugBridgeReadinessValidationGateStatus.blockedByPolicyBoundary;
  }
  if (validationResult.validationStatus ==
          DebugBridgeReadinessSummaryValidationStatus.blockedByUnsafeSummary ||
      validationResult.validationStatus ==
          DebugBridgeReadinessSummaryValidationStatus.blockedByPolicyBoundary ||
      validationResult.unsafeRecordCount > 0 ||
      validationResult.criticalCount > 0 ||
      validationResult
          .hasUnsafeDebugBridgeReadinessSummaryValidationPolicyViolation ||
      result.unsafeCount > 0 ||
      result.criticalCount > 0) {
    return DebugBridgeReadinessValidationGateStatus
        .blockedBySummaryValidationFailure;
  }
  if (!validationResult.safeForPhase32Y ||
      validationResult.isStrictlyBlocked ||
      result.blockerCount > 0 ||
      result.validationFindings.any((finding) => finding.blocksStrict) ||
      result.gateGroups.any((group) => !group.safeForFuturePrototypeDesign) ||
      result.gateRecords.any((record) => record.gateStatus.isInvalid)) {
    return DebugBridgeReadinessValidationGateStatus.invalid;
  }
  if (result.warnings.isNotEmpty) {
    return DebugBridgeReadinessValidationGateStatus
        .readyForPrototypeDesignWithWarnings;
  }
  return DebugBridgeReadinessValidationGateStatus.readyForPrototypeDesignClean;
}

DebugBridgeReadinessValidationGatePhase32ZRecommendation
_phase32ZRecommendationFor({
  required DebugBridgeReadinessValidationGateStatus status,
  required bool safeForPhase32Z,
  required int ownerProofQueueCount,
}) {
  if (status ==
          DebugBridgeReadinessValidationGateStatus
              .blockedBySummaryValidationFailure ||
      status ==
          DebugBridgeReadinessValidationGateStatus.blockedByPolicyBoundary) {
    return DebugBridgeReadinessValidationGatePhase32ZRecommendation
        .blockedByUnsafeBridgeReadinessGate;
  }
  if (ownerProofQueueCount > 0) {
    return DebugBridgeReadinessValidationGatePhase32ZRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase32Z) {
    return DebugBridgeReadinessValidationGatePhase32ZRecommendation
        .addMoreGoldenCoverageFirst;
  }
  return DebugBridgeReadinessValidationGatePhase32ZRecommendation
      .proceedToDebugOnlyBridgePrototypeDesign;
}

DebugBridgeReadinessValidationGateRole _roleForSummaryRole(
  DebugBridgeReadinessSummaryRole role,
) {
  return switch (role) {
    DebugBridgeReadinessSummaryRole.readyDebugCoreInputSummaryRecord =>
      DebugBridgeReadinessValidationGateRole.prototypeReadyDebugCore,
    DebugBridgeReadinessSummaryRole.constrainedDebugContextInputSummaryRecord =>
      DebugBridgeReadinessValidationGateRole.constrainedDebugContext,
    DebugBridgeReadinessSummaryRole.inactiveDebugBlockedInputSummaryRecord =>
      DebugBridgeReadinessValidationGateRole.inactiveDebugBlocked,
    DebugBridgeReadinessSummaryRole.inactiveDebugFutureOnlyInputSummaryRecord =>
      DebugBridgeReadinessValidationGateRole.inactiveDebugFutureOnly,
    DebugBridgeReadinessSummaryRole.readyAllowedDebugFieldSummaryRecord =>
      DebugBridgeReadinessValidationGateRole.prototypeReadyAllowedField,
    DebugBridgeReadinessSummaryRole.deniedBlockedDebugFieldSummaryRecord =>
      DebugBridgeReadinessValidationGateRole.deniedFieldBoundary,
    DebugBridgeReadinessSummaryRole.stockfishRawUciPvDumpBlockedSummaryRecord =>
      DebugBridgeReadinessValidationGateRole.stockfishRawUciPvDumpDenied,
    DebugBridgeReadinessSummaryRole.androidProofBoundarySummaryRecord =>
      DebugBridgeReadinessValidationGateRole.validatedAndroidProofBoundary,
    DebugBridgeReadinessSummaryRole.ownerProofStatusSummaryRecord =>
      DebugBridgeReadinessValidationGateRole.emptyOwnerProofGate,
  };
}

DebugBridgeReadinessSummaryGroupId _sourceGroupForRole(
  DebugBridgeReadinessSummaryRole role,
) {
  return switch (role) {
    DebugBridgeReadinessSummaryRole.readyDebugCoreInputSummaryRecord =>
      DebugBridgeReadinessSummaryGroupId.readyDebugCoreInputSummary,
    DebugBridgeReadinessSummaryRole.constrainedDebugContextInputSummaryRecord =>
      DebugBridgeReadinessSummaryGroupId.constrainedDebugContextInputSummary,
    DebugBridgeReadinessSummaryRole.inactiveDebugBlockedInputSummaryRecord =>
      DebugBridgeReadinessSummaryGroupId.inactiveDebugBlockedInputSummary,
    DebugBridgeReadinessSummaryRole.inactiveDebugFutureOnlyInputSummaryRecord =>
      DebugBridgeReadinessSummaryGroupId.inactiveDebugFutureOnlyInputSummary,
    DebugBridgeReadinessSummaryRole.readyAllowedDebugFieldSummaryRecord =>
      DebugBridgeReadinessSummaryGroupId.readyAllowedDebugFieldSummary,
    DebugBridgeReadinessSummaryRole.deniedBlockedDebugFieldSummaryRecord =>
      DebugBridgeReadinessSummaryGroupId.deniedBlockedDebugFieldSummary,
    DebugBridgeReadinessSummaryRole.stockfishRawUciPvDumpBlockedSummaryRecord =>
      DebugBridgeReadinessSummaryGroupId.stockfishRawUciPvDumpBlockedSummary,
    DebugBridgeReadinessSummaryRole.androidProofBoundarySummaryRecord =>
      DebugBridgeReadinessSummaryGroupId.androidProofBoundarySummary,
    DebugBridgeReadinessSummaryRole.ownerProofStatusSummaryRecord =>
      DebugBridgeReadinessSummaryGroupId.ownerProofStatusSummary,
  };
}

DebugBridgeReadinessValidationGateRecordStatus _recordStatusForRole(
  DebugBridgeReadinessValidationGateRole role,
) {
  return switch (role) {
    DebugBridgeReadinessValidationGateRole.prototypeReadyDebugCore =>
      DebugBridgeReadinessValidationGateRecordStatus.prototypeReadyDebugCore,
    DebugBridgeReadinessValidationGateRole.constrainedDebugContext =>
      DebugBridgeReadinessValidationGateRecordStatus.constrainedDebugContext,
    DebugBridgeReadinessValidationGateRole.inactiveDebugBlocked =>
      DebugBridgeReadinessValidationGateRecordStatus.inactiveDebugBlocked,
    DebugBridgeReadinessValidationGateRole.inactiveDebugFutureOnly =>
      DebugBridgeReadinessValidationGateRecordStatus.inactiveDebugFutureOnly,
    DebugBridgeReadinessValidationGateRole.prototypeReadyAllowedField =>
      DebugBridgeReadinessValidationGateRecordStatus.prototypeReadyAllowedField,
    DebugBridgeReadinessValidationGateRole.deniedFieldBoundary =>
      DebugBridgeReadinessValidationGateRecordStatus.deniedFieldBoundary,
    DebugBridgeReadinessValidationGateRole.stockfishRawUciPvDumpDenied =>
      DebugBridgeReadinessValidationGateRecordStatus
          .stockfishRawUciPvDumpDenied,
    DebugBridgeReadinessValidationGateRole.validatedAndroidProofBoundary =>
      DebugBridgeReadinessValidationGateRecordStatus
          .validatedAndroidProofBoundary,
    DebugBridgeReadinessValidationGateRole.emptyOwnerProofGate =>
      DebugBridgeReadinessValidationGateRecordStatus.emptyOwnerProofGate,
  };
}

DebugBridgeReadinessValidationGateRecommendation _recommendationForRole(
  DebugBridgeReadinessValidationGateRole role,
) {
  return switch (role) {
    DebugBridgeReadinessValidationGateRole.prototypeReadyDebugCore =>
      DebugBridgeReadinessValidationGateRecommendation
          .allowPrototypeReadyDebugCoreForDesign,
    DebugBridgeReadinessValidationGateRole.constrainedDebugContext =>
      DebugBridgeReadinessValidationGateRecommendation
          .keepDebugContextConstrained,
    DebugBridgeReadinessValidationGateRole.inactiveDebugBlocked =>
      DebugBridgeReadinessValidationGateRecommendation.keepDebugBlockedInactive,
    DebugBridgeReadinessValidationGateRole.inactiveDebugFutureOnly =>
      DebugBridgeReadinessValidationGateRecommendation
          .keepDebugFutureOnlyInactive,
    DebugBridgeReadinessValidationGateRole.prototypeReadyAllowedField =>
      DebugBridgeReadinessValidationGateRecommendation
          .allowInternalDebugFieldsForPrototypeDesign,
    DebugBridgeReadinessValidationGateRole.deniedFieldBoundary =>
      DebugBridgeReadinessValidationGateRecommendation.keepDeniedFieldsDenied,
    DebugBridgeReadinessValidationGateRole.stockfishRawUciPvDumpDenied =>
      DebugBridgeReadinessValidationGateRecommendation
          .keepStockfishRawUciPvDumpDenied,
    DebugBridgeReadinessValidationGateRole.validatedAndroidProofBoundary =>
      DebugBridgeReadinessValidationGateRecommendation
          .keepAndroidProofBoundaryCapturedOnly,
    DebugBridgeReadinessValidationGateRole.emptyOwnerProofGate =>
      DebugBridgeReadinessValidationGateRecommendation.keepOwnerProofEmpty,
  };
}

void _checkSafetyFlags(
  void Function({
    required String id,
    required DebugBridgeReadinessValidationGateSeverity severity,
    required String message,
    String? gateRecordId,
    String? sourceValidationRowId,
    DebugBridgeReadinessValidationGateGroupId? groupId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugBridgeReadinessValidationGateRecord record,
) {
  void critical(String id, String message) {
    add(
      id: id,
      severity: DebugBridgeReadinessValidationGateSeverity.critical,
      message: message,
      gateRecordId: record.gateRecordId,
      sourceValidationRowId: record.sourceValidationRowId,
    );
  }

  if (record.safetyFlags['isProductOutput'] == true) {
    critical('productOutputActive', 'gate cannot be product output');
  }
  if (record.safetyFlags['isClassifierLabel'] == true) {
    critical(
      'classifierLabelOutputActive',
      'gate cannot emit classifier labels',
    );
  }
  if (record.safetyFlags['hasNumericScore'] == true) {
    critical('numericScoreOutputActive', 'gate cannot emit numeric scores');
  }
  if (record.safetyFlags['hasAggregateScore'] == true) {
    critical('aggregateScoreOutputActive', 'gate cannot emit aggregate scores');
  }
  if (record.safetyFlags['ranksMoves'] == true) {
    critical('moveRankingOutputActive', 'gate cannot rank moves');
  }
  if (record.safetyFlags['isOfficialMetric'] == true) {
    critical('officialMetricOutputActive', 'gate cannot emit official metrics');
  }
  if (record.safetyFlags['exposesCpLoss'] == true ||
      record.safetyFlags['exposesWinProbability'] == true) {
    critical(
      'futureMetricOutputActive',
      'gate cannot expose CP-loss or win probability',
    );
  }
  if (record.safetyFlags['quietPreparatoryScopeActive'] == true) {
    critical(
      'quietPreparatoryScopeActivated',
      'quiet/preparatory scope must remain excluded',
    );
  }
  if (record.safetyFlags['callsEngine'] == true) {
    critical('engineCallFlagActive', 'gate cannot call an engine');
  }
  if (record.safetyFlags['writesPersistence'] == true) {
    critical('persistenceWriteFlagActive', 'gate cannot write persistence');
  }
  if (record.safetyFlags['targetsUi'] == true) {
    critical('uiTargetFlagActive', 'gate cannot target UI');
  }
  if (record.safetyFlags['backendOutputActive'] == true) {
    critical('backendOutputActive', 'gate cannot target backend');
  }
  if (record.safetyFlags['exposesStockfishCommand'] == true ||
      record.safetyFlags['exposesRawUci'] == true ||
      record.safetyFlags['exposesPvDump'] == true) {
    critical(
      'stockfishRawUciPvDumpFieldActive',
      'Stockfish command, raw UCI, and PV dump fields must remain denied',
    );
  }
}

void _checkActiveAllowedField(
  void Function({
    required String id,
    required DebugBridgeReadinessValidationGateSeverity severity,
    required String message,
    String? gateRecordId,
    String? sourceValidationRowId,
    DebugBridgeReadinessValidationGateGroupId? groupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String fieldId, {
  String? gateRecordId,
  String? sourceValidationRowId,
  DebugBridgeReadinessValidationGateGroupId? groupId,
}) {
  if (_isDeniedFieldId(fieldId) || _isLegacyDeniedFieldId(fieldId)) {
    add(
      id: 'activeDeniedField',
      severity: DebugBridgeReadinessValidationGateSeverity.critical,
      message: '$fieldId cannot be active gate output',
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
    required DebugBridgeReadinessValidationGateSeverity severity,
    required String message,
    String? gateRecordId,
    String? sourceValidationRowId,
    DebugBridgeReadinessValidationGateGroupId? groupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String caseId,
  List<String> provenAndroidIds, {
  String? gateRecordId,
  String? sourceValidationRowId,
  DebugBridgeReadinessValidationGateGroupId? groupId,
}) {
  if (_phase32ECaseIds.contains(caseId)) {
    add(
      id: 'phase32ECaseTreatedAsCapturedProof',
      severity: DebugBridgeReadinessValidationGateSeverity.critical,
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
      severity: DebugBridgeReadinessValidationGateSeverity.critical,
      message: '$caseId is not captured Android proof',
      gateRecordId: gateRecordId,
      sourceValidationRowId: sourceValidationRowId,
      groupId: groupId,
      caseId: caseId,
    );
  }
}

bool _recordIsInactiveSafe(DebugBridgeReadinessValidationGateRecord record) {
  return record.inactive &&
      record.gateRole.isInactiveBoundary &&
      record.allowedFieldIds.isEmpty &&
      !record.hasUnsafeOutput;
}

bool _hasExplicitPvProofReason(
  DebugBridgeReadinessValidationGateResult result,
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
  };
}

List<String> _provenAndroidProofIds(GoldenAndroidProofEvidence? evidence) {
  return _sortedStrings(evidence?.targetCaseIds ?? const <String>[]);
}

int _compareFindings(
  DebugBridgeReadinessValidationGateFinding a,
  DebugBridgeReadinessValidationGateFinding b,
) {
  final severity = _severityRank(
    b.severity,
  ).compareTo(_severityRank(a.severity));
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.gateRecordId ?? '').compareTo(b.gateRecordId ?? '');
}

int _severityRank(DebugBridgeReadinessValidationGateSeverity severity) {
  return switch (severity) {
    DebugBridgeReadinessValidationGateSeverity.warning => 1,
    DebugBridgeReadinessValidationGateSeverity.blocker => 2,
    DebugBridgeReadinessValidationGateSeverity.critical => 3,
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

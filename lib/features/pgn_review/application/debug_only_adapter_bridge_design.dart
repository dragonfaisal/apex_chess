/// Developer-only design contract for a future debug-only adapter bridge.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_adapter_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/internal_adapter_readiness_summary_validation.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_validation.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_summary_layer.dart';

const debugOnlyAdapterBridgeDesignReportVersion =
    'debug-only-adapter-bridge-design-v1';

enum DebugOnlyAdapterBridgeDesignStatus {
  designReadyWithWarnings('designReadyWithWarnings'),
  designReadyClean('designReadyClean'),
  blockedBySummaryValidationFailure('blockedBySummaryValidationFailure'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const DebugOnlyAdapterBridgeDesignStatus(this.wire);

  final String wire;
}

enum DebugOnlyAdapterBridgeInputGroupId {
  debugCoreInputGroup('debugCoreInputGroup'),
  debugContextInputGroup('debugContextInputGroup'),
  debugBlockedInputGroup('debugBlockedInputGroup'),
  debugFutureOnlyInputGroup('debugFutureOnlyInputGroup'),
  debugAllowedFieldGroup('debugAllowedFieldGroup'),
  debugBlockedFieldGroup('debugBlockedFieldGroup'),
  debugProofBoundaryGroup('debugProofBoundaryGroup'),
  debugOwnerProofStatusGroup('debugOwnerProofStatusGroup');

  const DebugOnlyAdapterBridgeInputGroupId(this.wire);

  final String wire;
}

enum DebugOnlyAdapterBridgeInputGroupStatus {
  debugCoreInputReady('debugCoreInputReady'),
  debugContextInputReady('debugContextInputReady'),
  debugBlockedInputInactive('debugBlockedInputInactive'),
  debugFutureOnlyInputInactive('debugFutureOnlyInputInactive'),
  debugAllowedFieldsReady('debugAllowedFieldsReady'),
  debugBlockedFieldsReady('debugBlockedFieldsReady'),
  debugProofBoundaryReady('debugProofBoundaryReady'),
  debugOwnerProofStatusReady('debugOwnerProofStatusReady'),
  invalidGroup('invalidGroup'),
  unsafeGroup('unsafeGroup');

  const DebugOnlyAdapterBridgeInputGroupStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == unsafeGroup;
}

enum DebugOnlyAdapterBridgeRole {
  debugCoreInput('debugCoreInput'),
  debugContextOnlyInput('debugContextOnlyInput'),
  debugBlockedInput('debugBlockedInput'),
  debugFutureOnlyInput('debugFutureOnlyInput'),
  debugAllowedField('debugAllowedField'),
  debugBlockedField('debugBlockedField'),
  debugProofBoundary('debugProofBoundary'),
  debugOwnerProofStatus('debugOwnerProofStatus');

  const DebugOnlyAdapterBridgeRole(this.wire);

  final String wire;

  bool get isInactiveBoundary =>
      this == debugBlockedInput || this == debugFutureOnlyInput;
}

enum DebugOnlyAdapterBridgeRecordDesignStatus {
  debugCoreInputDesigned('debugCoreInputDesigned'),
  debugContextOnlyInputDesigned('debugContextOnlyInputDesigned'),
  debugBlockedInputInactive('debugBlockedInputInactive'),
  debugFutureOnlyInputInactive('debugFutureOnlyInputInactive'),
  debugAllowedFieldDesigned('debugAllowedFieldDesigned'),
  debugBlockedFieldDesigned('debugBlockedFieldDesigned'),
  debugProofBoundaryDesigned('debugProofBoundaryDesigned'),
  debugOwnerProofStatusDesigned('debugOwnerProofStatusDesigned'),
  invalidRecord('invalidRecord'),
  unsafeRecord('unsafeRecord');

  const DebugOnlyAdapterBridgeRecordDesignStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == unsafeRecord;
}

enum DebugOnlyAdapterBridgeDesignRecommendation {
  allowDebugCoreInputForFutureBridge('allowDebugCoreInputForFutureBridge'),
  keepDebugContextInputContextOnly('keepDebugContextInputContextOnly'),
  keepDebugBlockedInputInactive('keepDebugBlockedInputInactive'),
  keepDebugFutureOnlyInputInactive('keepDebugFutureOnlyInputInactive'),
  keepDebugAllowedFieldsInternal('keepDebugAllowedFieldsInternal'),
  keepDebugBlockedFieldsDenied('keepDebugBlockedFieldsDenied'),
  keepDebugProofBoundaryCaptured('keepDebugProofBoundaryCaptured'),
  keepDebugOwnerProofEmpty('keepDebugOwnerProofEmpty'),
  investigateBridgeDesignFailure('investigateBridgeDesignFailure'),
  blockUnsafeBridgeDesign('blockUnsafeBridgeDesign');

  const DebugOnlyAdapterBridgeDesignRecommendation(this.wire);

  final String wire;
}

enum DebugOnlyAdapterBridgeDesignSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const DebugOnlyAdapterBridgeDesignSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == DebugOnlyAdapterBridgeDesignSeverity.blocker ||
      this == DebugOnlyAdapterBridgeDesignSeverity.critical;

  bool get isCritical => this == DebugOnlyAdapterBridgeDesignSeverity.critical;
}

enum DebugOnlyAdapterBridgeDesignPhase32URecommendation {
  validateDebugOnlyAdapterBridgeDesign('validateDebugOnlyAdapterBridgeDesign'),
  proceedToDebugOnlyAdapterBridgePrototype(
    'proceedToDebugOnlyAdapterBridgePrototype',
  ),
  proceedToDebugBridgeDesignSummaryOnly(
    'proceedToDebugBridgeDesignSummaryOnly',
  ),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeBridgeDesign('blockedByUnsafeBridgeDesign');

  const DebugOnlyAdapterBridgeDesignPhase32URecommendation(this.wire);

  final String wire;
}

enum DebugOnlyAdapterBridgeDesignReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyAdapterBridgeDesignReportFormat(this.wire);

  final String wire;
}

class DebugOnlyAdapterBridgeDesignRequest {
  const DebugOnlyAdapterBridgeDesignRequest({
    this.summaryValidationResult,
    this.summaryResult,
    this.readinessGateResult,
    this.validationResult,
    this.summaryValidation = const InternalAdapterReadinessSummaryValidation(),
    this.summary = const InternalAdapterReadinessSummary(),
    this.readinessGate = const InternalEvidenceAdapterPrototypeReadinessGate(),
    this.prototypeValidation =
        const InternalEvidenceAdapterPrototypeValidation(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const DebugOnlyAdapterBridgeDesignRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final InternalAdapterReadinessSummaryValidationResult?
  summaryValidationResult;
  final InternalAdapterReadinessSummaryResult? summaryResult;
  final InternalEvidenceAdapterPrototypeReadinessGateResult?
  readinessGateResult;
  final InternalEvidenceAdapterPrototypeValidationResult? validationResult;
  final InternalAdapterReadinessSummaryValidation summaryValidation;
  final InternalAdapterReadinessSummary summary;
  final InternalEvidenceAdapterPrototypeReadinessGate readinessGate;
  final InternalEvidenceAdapterPrototypeValidation prototypeValidation;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class DebugOnlyAdapterBridgeInputGroup {
  const DebugOnlyAdapterBridgeInputGroup({
    required this.groupId,
    required this.designStatus,
    required this.packetIds,
    required this.sourceSummaryGroupIds,
    required this.activeFieldIds,
    required this.blockedFieldIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.futurePrerequisites,
    required this.blockedBoundaryIds,
    required this.safeForFutureDebugBridge,
    required this.recommendation,
  });

  final DebugOnlyAdapterBridgeInputGroupId groupId;
  final DebugOnlyAdapterBridgeInputGroupStatus designStatus;
  final List<String> packetIds;
  final List<InternalEvidenceSummaryGroupId> sourceSummaryGroupIds;
  final List<String> activeFieldIds;
  final List<String> blockedFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> futurePrerequisites;
  final List<String> blockedBoundaryIds;
  final bool safeForFutureDebugBridge;
  final DebugOnlyAdapterBridgeDesignRecommendation recommendation;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'groupId': groupId.wire,
      'designStatus': designStatus.wire,
      'packetIds': packetIds,
      'sourceSummaryGroupIds': sourceSummaryGroupIds
          .map((id) => id.wire)
          .toList(),
      'activeFieldIds': activeFieldIds,
      'blockedFieldIds': blockedFieldIds,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'futurePrerequisites': futurePrerequisites,
      'blockedBoundaryIds': blockedBoundaryIds,
      'safeForFutureDebugBridge': safeForFutureDebugBridge,
      'recommendation': recommendation.wire,
    };
  }
}

class DebugOnlyAdapterBridgeRecord {
  const DebugOnlyAdapterBridgeRecord({
    required this.bridgeRecordId,
    required this.sourceValidationRowId,
    required this.sourceSummaryGroupId,
    required this.bridgeRole,
    required this.designStatus,
    required this.allowedForFutureDebugBridge,
    required this.contextOnly,
    required this.inactive,
    required this.adapterPacketIds,
    required this.sourceSummaryGroupIds,
    required this.activeFieldIds,
    required this.blockedFieldIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.futurePrerequisites,
    required this.blockedBoundaryIds,
    required this.recommendation,
    this.isProductOutput = false,
    this.isClassifierLabel = false,
    this.hasNumericScore = false,
    this.hasAggregateScore = false,
    this.ranksMoves = false,
    this.isOfficialMetric = false,
    this.callsEngine = false,
    this.writesPersistence = false,
    this.targetsUi = false,
    this.backendOutputActive = false,
    this.cpLossOutputActive = false,
    this.winProbabilityOutputActive = false,
    this.quietPreparatoryScopeActive = false,
    this.stockfishCommandFieldActive = false,
    this.rawUciFieldActive = false,
    this.pvDumpFieldActive = false,
  });

  final String bridgeRecordId;
  final String sourceValidationRowId;
  final InternalAdapterReadinessSummaryGroupId sourceSummaryGroupId;
  final DebugOnlyAdapterBridgeRole bridgeRole;
  final DebugOnlyAdapterBridgeRecordDesignStatus designStatus;
  final bool allowedForFutureDebugBridge;
  final bool contextOnly;
  final bool inactive;
  final List<String> adapterPacketIds;
  final List<InternalEvidenceSummaryGroupId> sourceSummaryGroupIds;
  final List<String> activeFieldIds;
  final List<String> blockedFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> futurePrerequisites;
  final List<String> blockedBoundaryIds;
  final DebugOnlyAdapterBridgeDesignRecommendation recommendation;
  final bool isProductOutput;
  final bool isClassifierLabel;
  final bool hasNumericScore;
  final bool hasAggregateScore;
  final bool ranksMoves;
  final bool isOfficialMetric;
  final bool callsEngine;
  final bool writesPersistence;
  final bool targetsUi;
  final bool backendOutputActive;
  final bool cpLossOutputActive;
  final bool winProbabilityOutputActive;
  final bool quietPreparatoryScopeActive;
  final bool stockfishCommandFieldActive;
  final bool rawUciFieldActive;
  final bool pvDumpFieldActive;

  bool get hasBlockedActiveField =>
      activeFieldIds.any(_isBlockedBridgeFieldId) ||
      activeFieldIds.any(_isLegacyBlockedOutputFieldId);

  bool get hasUnsafeOutput {
    return isProductOutput ||
        isClassifierLabel ||
        hasNumericScore ||
        hasAggregateScore ||
        ranksMoves ||
        isOfficialMetric ||
        callsEngine ||
        writesPersistence ||
        targetsUi ||
        backendOutputActive ||
        cpLossOutputActive ||
        winProbabilityOutputActive ||
        quietPreparatoryScopeActive ||
        stockfishCommandFieldActive ||
        rawUciFieldActive ||
        pvDumpFieldActive ||
        hasBlockedActiveField;
  }

  DebugOnlyAdapterBridgeRecord copyWith({
    String? bridgeRecordId,
    String? sourceValidationRowId,
    InternalAdapterReadinessSummaryGroupId? sourceSummaryGroupId,
    DebugOnlyAdapterBridgeRole? bridgeRole,
    DebugOnlyAdapterBridgeRecordDesignStatus? designStatus,
    bool? allowedForFutureDebugBridge,
    bool? contextOnly,
    bool? inactive,
    List<String>? adapterPacketIds,
    List<InternalEvidenceSummaryGroupId>? sourceSummaryGroupIds,
    List<String>? activeFieldIds,
    List<String>? blockedFieldIds,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? futurePrerequisites,
    List<String>? blockedBoundaryIds,
    DebugOnlyAdapterBridgeDesignRecommendation? recommendation,
    bool? isProductOutput,
    bool? isClassifierLabel,
    bool? hasNumericScore,
    bool? hasAggregateScore,
    bool? ranksMoves,
    bool? isOfficialMetric,
    bool? callsEngine,
    bool? writesPersistence,
    bool? targetsUi,
    bool? backendOutputActive,
    bool? cpLossOutputActive,
    bool? winProbabilityOutputActive,
    bool? quietPreparatoryScopeActive,
    bool? stockfishCommandFieldActive,
    bool? rawUciFieldActive,
    bool? pvDumpFieldActive,
  }) {
    return DebugOnlyAdapterBridgeRecord(
      bridgeRecordId: bridgeRecordId ?? this.bridgeRecordId,
      sourceValidationRowId:
          sourceValidationRowId ?? this.sourceValidationRowId,
      sourceSummaryGroupId: sourceSummaryGroupId ?? this.sourceSummaryGroupId,
      bridgeRole: bridgeRole ?? this.bridgeRole,
      designStatus: designStatus ?? this.designStatus,
      allowedForFutureDebugBridge:
          allowedForFutureDebugBridge ?? this.allowedForFutureDebugBridge,
      contextOnly: contextOnly ?? this.contextOnly,
      inactive: inactive ?? this.inactive,
      adapterPacketIds: adapterPacketIds ?? this.adapterPacketIds,
      sourceSummaryGroupIds:
          sourceSummaryGroupIds ?? this.sourceSummaryGroupIds,
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
      recommendation: recommendation ?? this.recommendation,
      isProductOutput: isProductOutput ?? this.isProductOutput,
      isClassifierLabel: isClassifierLabel ?? this.isClassifierLabel,
      hasNumericScore: hasNumericScore ?? this.hasNumericScore,
      hasAggregateScore: hasAggregateScore ?? this.hasAggregateScore,
      ranksMoves: ranksMoves ?? this.ranksMoves,
      isOfficialMetric: isOfficialMetric ?? this.isOfficialMetric,
      callsEngine: callsEngine ?? this.callsEngine,
      writesPersistence: writesPersistence ?? this.writesPersistence,
      targetsUi: targetsUi ?? this.targetsUi,
      backendOutputActive: backendOutputActive ?? this.backendOutputActive,
      cpLossOutputActive: cpLossOutputActive ?? this.cpLossOutputActive,
      winProbabilityOutputActive:
          winProbabilityOutputActive ?? this.winProbabilityOutputActive,
      quietPreparatoryScopeActive:
          quietPreparatoryScopeActive ?? this.quietPreparatoryScopeActive,
      stockfishCommandFieldActive:
          stockfishCommandFieldActive ?? this.stockfishCommandFieldActive,
      rawUciFieldActive: rawUciFieldActive ?? this.rawUciFieldActive,
      pvDumpFieldActive: pvDumpFieldActive ?? this.pvDumpFieldActive,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'bridgeRecordId': bridgeRecordId,
      'sourceValidationRowId': sourceValidationRowId,
      'sourceSummaryGroupId': sourceSummaryGroupId.wire,
      'bridgeRole': bridgeRole.wire,
      'designStatus': designStatus.wire,
      'allowedForFutureDebugBridge': allowedForFutureDebugBridge,
      'contextOnly': contextOnly,
      'inactive': inactive,
      'adapterPacketIds': adapterPacketIds,
      'sourceSummaryGroupIds': sourceSummaryGroupIds
          .map((id) => id.wire)
          .toList(),
      'activeFieldIds': activeFieldIds,
      'blockedFieldIds': blockedFieldIds,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'futurePrerequisites': futurePrerequisites,
      'blockedBoundaryIds': blockedBoundaryIds,
      'safetyFlags': <String, Object?>{
        'isProductOutput': isProductOutput,
        'isClassifierLabel': isClassifierLabel,
        'hasNumericScore': hasNumericScore,
        'hasAggregateScore': hasAggregateScore,
        'ranksMoves': ranksMoves,
        'isOfficialMetric': isOfficialMetric,
        'callsEngine': callsEngine,
        'writesPersistence': writesPersistence,
        'targetsUi': targetsUi,
      },
      'backendOutputActive': backendOutputActive,
      'cpLossOutputActive': cpLossOutputActive,
      'winProbabilityOutputActive': winProbabilityOutputActive,
      'quietPreparatoryScopeActive': quietPreparatoryScopeActive,
      'stockfishCommandFieldActive': stockfishCommandFieldActive,
      'rawUciFieldActive': rawUciFieldActive,
      'pvDumpFieldActive': pvDumpFieldActive,
      'recommendation': recommendation.wire,
    };
  }
}

class DebugOnlyAdapterBridgeDesignFinding {
  const DebugOnlyAdapterBridgeDesignFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.bridgeRecordId,
    this.bridgeGroupId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final DebugOnlyAdapterBridgeDesignSeverity severity;
  final String message;
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
      if (bridgeRecordId != null) 'bridgeRecordId': bridgeRecordId,
      if (bridgeGroupId != null) 'bridgeGroupId': bridgeGroupId!.wire,
      if (fieldId != null) 'fieldId': fieldId,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class DebugOnlyAdapterBridgeDesignResult {
  const DebugOnlyAdapterBridgeDesignResult({
    required this.designStatus,
    required this.sourceSummaryValidationStatus,
    required this.sourceSummaryStatus,
    required this.sourceReadinessGateStatus,
    required this.sourcePrototypeValidationStatus,
    required this.inputGroups,
    required this.bridgeRecords,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalBridgeRecords,
    required this.debugCoreInputCount,
    required this.debugContextInputCount,
    required this.debugBlockedInputCount,
    required this.debugFutureOnlyInputCount,
    required this.allowedFieldCount,
    required this.blockedFieldCount,
    required this.unsafeCount,
    required this.blockerCount,
    required this.criticalCount,
    required this.ownerProofQueueCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.allowedFieldIds,
    required this.blockedFieldIds,
    required this.safeForPhase32U,
    required this.phase32URecommendation,
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

  final DebugOnlyAdapterBridgeDesignStatus designStatus;
  final InternalAdapterReadinessSummaryValidationStatus
  sourceSummaryValidationStatus;
  final InternalAdapterReadinessSummaryStatus sourceSummaryStatus;
  final InternalEvidenceAdapterPrototypeReadinessGateStatus
  sourceReadinessGateStatus;
  final InternalEvidenceAdapterPrototypeValidationStatus
  sourcePrototypeValidationStatus;
  final List<DebugOnlyAdapterBridgeInputGroup> inputGroups;
  final List<DebugOnlyAdapterBridgeRecord> bridgeRecords;
  final List<DebugOnlyAdapterBridgeDesignFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalBridgeRecords;
  final int debugCoreInputCount;
  final int debugContextInputCount;
  final int debugBlockedInputCount;
  final int debugFutureOnlyInputCount;
  final int allowedFieldCount;
  final int blockedFieldCount;
  final int unsafeCount;
  final int blockerCount;
  final int criticalCount;
  final int ownerProofQueueCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> allowedFieldIds;
  final List<String> blockedFieldIds;
  final bool safeForPhase32U;
  final DebugOnlyAdapterBridgeDesignPhase32URecommendation
  phase32URecommendation;
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
      designStatus ==
          DebugOnlyAdapterBridgeDesignStatus
              .blockedBySummaryValidationFailure ||
      designStatus ==
          DebugOnlyAdapterBridgeDesignStatus.blockedByPolicyBoundary ||
      designStatus == DebugOnlyAdapterBridgeDesignStatus.invalid ||
      !safeForPhase32U ||
      unsafeCount > 0 ||
      criticalCount > 0 ||
      blockerCount > 0 ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeDebugBridgeDesignPolicyViolation {
    return designStatus ==
            DebugOnlyAdapterBridgeDesignStatus
                .blockedBySummaryValidationFailure ||
        designStatus ==
            DebugOnlyAdapterBridgeDesignStatus.blockedByPolicyBoundary ||
        unsafeCount > 0 ||
        criticalCount > 0 ||
        inputGroups.any((group) => group.designStatus.isUnsafe) ||
        bridgeRecords.any(
          (record) => record.hasUnsafeOutput || record.designStatus.isUnsafe,
        ) ||
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

  DebugOnlyAdapterBridgeInputGroup group(
    DebugOnlyAdapterBridgeInputGroupId groupId,
  ) {
    return inputGroups.singleWhere((group) => group.groupId == groupId);
  }

  DebugOnlyAdapterBridgeRecord record(String bridgeRecordId) {
    return bridgeRecords.singleWhere(
      (record) => record.bridgeRecordId == bridgeRecordId,
    );
  }

  DebugOnlyAdapterBridgeRecord recordForRole(
    DebugOnlyAdapterBridgeRole bridgeRole,
  ) {
    return bridgeRecords.singleWhere(
      (record) => record.bridgeRole == bridgeRole,
    );
  }

  List<DebugOnlyAdapterBridgeRecord> get debugCoreRecords => bridgeRecords
      .where(
        (record) =>
            record.bridgeRole == DebugOnlyAdapterBridgeRole.debugCoreInput,
      )
      .toList(growable: false);

  List<DebugOnlyAdapterBridgeRecord> get debugContextRecords => bridgeRecords
      .where(
        (record) =>
            record.bridgeRole ==
            DebugOnlyAdapterBridgeRole.debugContextOnlyInput,
      )
      .toList(growable: false);

  List<DebugOnlyAdapterBridgeRecord> get inactiveBoundaryRecords =>
      bridgeRecords
          .where((record) => record.bridgeRole.isInactiveBoundary)
          .toList(growable: false);

  DebugOnlyAdapterBridgeDesignResult copyWith({
    DebugOnlyAdapterBridgeDesignStatus? designStatus,
    InternalAdapterReadinessSummaryValidationStatus?
    sourceSummaryValidationStatus,
    InternalAdapterReadinessSummaryStatus? sourceSummaryStatus,
    InternalEvidenceAdapterPrototypeReadinessGateStatus?
    sourceReadinessGateStatus,
    InternalEvidenceAdapterPrototypeValidationStatus?
    sourcePrototypeValidationStatus,
    List<DebugOnlyAdapterBridgeInputGroup>? inputGroups,
    List<DebugOnlyAdapterBridgeRecord>? bridgeRecords,
    List<DebugOnlyAdapterBridgeDesignFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalBridgeRecords,
    int? debugCoreInputCount,
    int? debugContextInputCount,
    int? debugBlockedInputCount,
    int? debugFutureOnlyInputCount,
    int? allowedFieldCount,
    int? blockedFieldCount,
    int? unsafeCount,
    int? blockerCount,
    int? criticalCount,
    int? ownerProofQueueCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? allowedFieldIds,
    List<String>? blockedFieldIds,
    bool? safeForPhase32U,
    DebugOnlyAdapterBridgeDesignPhase32URecommendation? phase32URecommendation,
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
    return DebugOnlyAdapterBridgeDesignResult(
      designStatus: designStatus ?? this.designStatus,
      sourceSummaryValidationStatus:
          sourceSummaryValidationStatus ?? this.sourceSummaryValidationStatus,
      sourceSummaryStatus: sourceSummaryStatus ?? this.sourceSummaryStatus,
      sourceReadinessGateStatus:
          sourceReadinessGateStatus ?? this.sourceReadinessGateStatus,
      sourcePrototypeValidationStatus:
          sourcePrototypeValidationStatus ??
          this.sourcePrototypeValidationStatus,
      inputGroups: inputGroups ?? this.inputGroups,
      bridgeRecords: bridgeRecords ?? this.bridgeRecords,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalBridgeRecords: totalBridgeRecords ?? this.totalBridgeRecords,
      debugCoreInputCount: debugCoreInputCount ?? this.debugCoreInputCount,
      debugContextInputCount:
          debugContextInputCount ?? this.debugContextInputCount,
      debugBlockedInputCount:
          debugBlockedInputCount ?? this.debugBlockedInputCount,
      debugFutureOnlyInputCount:
          debugFutureOnlyInputCount ?? this.debugFutureOnlyInputCount,
      allowedFieldCount: allowedFieldCount ?? this.allowedFieldCount,
      blockedFieldCount: blockedFieldCount ?? this.blockedFieldCount,
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
      safeForPhase32U: safeForPhase32U ?? this.safeForPhase32U,
      phase32URecommendation:
          phase32URecommendation ?? this.phase32URecommendation,
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
      ..writeln('# Debug-Only Adapter Bridge Design')
      ..writeln()
      ..writeln('- version: $debugOnlyAdapterBridgeDesignReportVersion')
      ..writeln('- bridge design status: ${designStatus.wire}')
      ..writeln(
        '- source summary validation status: ${sourceSummaryValidationStatus.wire}',
      )
      ..writeln('- source summary status: ${sourceSummaryStatus.wire}')
      ..writeln(
        '- source readiness gate status: ${sourceReadinessGateStatus.wire}',
      )
      ..writeln(
        '- source prototype validation status: ${sourcePrototypeValidationStatus.wire}',
      )
      ..writeln('- total bridge records: $totalBridgeRecords')
      ..writeln('- debug core input count: $debugCoreInputCount')
      ..writeln('- debug context input count: $debugContextInputCount')
      ..writeln('- debug blocked input count: $debugBlockedInputCount')
      ..writeln('- debug future-only input count: $debugFutureOnlyInputCount')
      ..writeln('- allowed field count: $allowedFieldCount')
      ..writeln('- blocked field count: $blockedFieldCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- safe for Phase 32U: $safeForPhase32U')
      ..writeln('- Phase 32U recommendation: ${phase32URecommendation.wire}')
      ..writeln()
      ..writeln('## Bridge Design Policy')
      ..writeln('- this layer designs a developer-debug bridge contract only')
      ..writeln(
        '- core inputs, context inputs, inactive boundary inputs, allowed fields, blocked fields, Android proof, and owner-proof status remain internal-only',
      )
      ..writeln()
      ..writeln('## Bridge Input Group Table')
      ..writeln(
        '| Group | Status | Packets | Source Summary Groups | Active Fields | Blocked Fields | Android Proof | Safe | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- | --- |');
    for (final group in inputGroups) {
      buffer.writeln(
        '| ${group.groupId.wire} | '
        '${group.designStatus.wire} | '
        '${_ids(group.packetIds)} | '
        '${_summaryGroupIds(group.sourceSummaryGroupIds)} | '
        '${_ids(group.activeFieldIds)} | '
        '${_ids(group.blockedFieldIds)} | '
        '${_ids(group.androidProofCaseIds)} | '
        '${group.safeForFutureDebugBridge} | '
        '${group.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Bridge Contract Record Table')
      ..writeln(
        '| Bridge Record | Source Validation Row | Role | Status | Allowed | Context Only | Inactive | Packets | Active Fields | Blocked Fields | Android Proof | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final record in bridgeRecords) {
      buffer.writeln(
        '| ${_cell(record.bridgeRecordId)} | '
        '${_cell(record.sourceValidationRowId)} | '
        '${record.bridgeRole.wire} | '
        '${record.designStatus.wire} | '
        '${record.allowedForFutureDebugBridge} | '
        '${record.contextOnly} | '
        '${record.inactive} | '
        '${_ids(record.adapterPacketIds)} | '
        '${_ids(record.activeFieldIds)} | '
        '${_ids(record.blockedFieldIds)} | '
        '${_ids(record.androidProofCaseIds)} | '
        '${record.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Debug Core Inputs')
      ..writeln('- ${_recordIds(debugCoreRecords)}')
      ..writeln()
      ..writeln('## Debug Context-Only Inputs')
      ..writeln('- ${_recordIds(debugContextRecords)}')
      ..writeln()
      ..writeln('## Inactive Blocked/Future-Only Inputs')
      ..writeln('- ${_recordIds(inactiveBoundaryRecords)}')
      ..writeln()
      ..writeln('## Allowed Bridge Fields')
      ..writeln('- ${_ids(allowedFieldIds)}')
      ..writeln()
      ..writeln('## Blocked Bridge Fields')
      ..writeln('- ${_ids(blockedFieldIds)}')
      ..writeln()
      ..writeln('## Android Proof Boundary')
      ..writeln('- ${_ids(androidProofCaseIds)}')
      ..writeln()
      ..writeln('## Owner Proof Status')
      ..writeln(
        ownerProofQueueCount == 0
            ? '- empty'
            : '- opt-in proof requires explicit PV/MultiPV reason',
      )
      ..writeln()
      ..writeln('## Design Findings');
    if (validationFindings.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final finding in validationFindings) {
        buffer.writeln(
          '- ${finding.severity.wire}: ${finding.id} -- ${finding.message}',
        );
      }
    }
    buffer
      ..writeln()
      ..writeln('## Warnings');
    if (warnings.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final warning in warnings) {
        buffer.writeln('- ${_cell(warning)}');
      }
    }
    buffer
      ..writeln()
      ..writeln('## Failures');
    if (failures.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final failure in failures) {
        buffer.writeln('- ${_cell(failure)}');
      }
    }
    buffer
      ..writeln()
      ..writeln('## Phase 32U Recommendation')
      ..writeln(phase32URecommendation.wire)
      ..writeln()
      ..writeln(
        'This debug-only adapter bridge design is internal-only. It does not implement a bridge runtime, emit active product labels, compute values, order moves, call the engine, expose Stockfish commands, expose raw UCI text, expose PV dumps, run Android, target UI, integrate with backend or persistence, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': debugOnlyAdapterBridgeDesignReportVersion,
      'designStatus': designStatus.wire,
      'sourceSummaryValidationStatus': sourceSummaryValidationStatus.wire,
      'sourceSummaryStatus': sourceSummaryStatus.wire,
      'sourceReadinessGateStatus': sourceReadinessGateStatus.wire,
      'sourcePrototypeValidationStatus': sourcePrototypeValidationStatus.wire,
      'totalBridgeRecords': totalBridgeRecords,
      'debugCoreInputCount': debugCoreInputCount,
      'debugContextInputCount': debugContextInputCount,
      'debugBlockedInputCount': debugBlockedInputCount,
      'debugFutureOnlyInputCount': debugFutureOnlyInputCount,
      'allowedFieldCount': allowedFieldCount,
      'blockedFieldCount': blockedFieldCount,
      'unsafeCount': unsafeCount,
      'blockerCount': blockerCount,
      'criticalCount': criticalCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'allowedFieldIds': allowedFieldIds,
      'blockedFieldIds': blockedFieldIds,
      'safeForPhase32U': safeForPhase32U,
      'phase32URecommendation': phase32URecommendation.wire,
      'inputGroups': inputGroups.map((group) => group.toJson()).toList(),
      'bridgeRecords': bridgeRecords.map((record) => record.toJson()).toList(),
      'validationFindings': validationFindings
          .map((finding) => finding.toJson())
          .toList(),
      'warnings': warnings,
      'failures': failures,
      'developerOnly': developerOnly,
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
    };
  }
}

class DebugOnlyAdapterBridgeDesign {
  const DebugOnlyAdapterBridgeDesign({
    this.validator = const DebugOnlyAdapterBridgeDesignValidator(),
  });

  final DebugOnlyAdapterBridgeDesignValidator validator;

  DebugOnlyAdapterBridgeDesignResult evaluate([
    DebugOnlyAdapterBridgeDesignRequest request =
        const DebugOnlyAdapterBridgeDesignRequest(),
  ]) {
    final validationResult =
        request.validationResult ??
        request.prototypeValidation.evaluate(
          InternalEvidenceAdapterPrototypeValidationRequest(
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final readinessGateResult =
        request.readinessGateResult ??
        request.readinessGate.evaluate(
          InternalEvidenceAdapterPrototypeReadinessGateRequest(
            validationResult: validationResult,
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
            validationResult: validationResult,
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
            validationResult: validationResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final inputGroups = _groupsFromSummaryValidation(
      summaryValidationResult: summaryValidationResult,
      summaryResult: summaryResult,
    );
    final bridgeRecords = _recordsFromGroups(inputGroups);
    final base = _resultFromGroupsAndRecords(
      summaryValidationResult: summaryValidationResult,
      summaryResult: summaryResult,
      readinessGateResult: readinessGateResult,
      validationResult: validationResult,
      inputGroups: inputGroups,
      bridgeRecords: bridgeRecords,
      validationFindings: const <DebugOnlyAdapterBridgeDesignFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromGroupsAndRecords(
      summaryValidationResult: summaryValidationResult,
      summaryResult: summaryResult,
      readinessGateResult: readinessGateResult,
      validationResult: validationResult,
      inputGroups: inputGroups,
      bridgeRecords: bridgeRecords,
      validationFindings: findings,
    );
  }
}

class DebugOnlyAdapterBridgeDesignValidator {
  const DebugOnlyAdapterBridgeDesignValidator();

  List<DebugOnlyAdapterBridgeDesignFinding> validate(
    DebugOnlyAdapterBridgeDesignResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <DebugOnlyAdapterBridgeDesignFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required DebugOnlyAdapterBridgeDesignSeverity severity,
      required String message,
      String? bridgeRecordId,
      DebugOnlyAdapterBridgeInputGroupId? bridgeGroupId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        DebugOnlyAdapterBridgeDesignFinding(
          id: id,
          severity: severity,
          message: message,
          bridgeRecordId: bridgeRecordId,
          bridgeGroupId: bridgeGroupId,
          fieldId: fieldId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase32U &&
        (result.sourceSummaryValidationStatus ==
                InternalAdapterReadinessSummaryValidationStatus
                    .blockedByUnsafeSummary ||
            result.sourceSummaryValidationStatus ==
                InternalAdapterReadinessSummaryValidationStatus
                    .blockedByPolicyBoundary ||
            result.unsafeCount > 0)) {
      add(
        id: 'unsafeSummaryValidationMarkedDesignReady',
        severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
        message: 'unsafe summary validation cannot be marked bridge-ready',
      );
    }

    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: DebugOnlyAdapterBridgeDesignSeverity.blocker,
        message: 'owner proof requires explicit PV/MultiPV reason',
      );
    }

    for (final fieldId in _blockedBridgeFieldIds) {
      if (!result.blockedFieldIds.contains(fieldId)) {
        add(
          id: 'blockedBridgeFieldMissing',
          severity: DebugOnlyAdapterBridgeDesignSeverity.blocker,
          message: '$fieldId must remain blocked from the debug bridge',
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

    for (final record in result.bridgeRecords) {
      for (final fieldId in record.activeFieldIds) {
        _checkActiveBridgeField(
          add,
          fieldId,
          bridgeRecordId: record.bridgeRecordId,
        );
      }
      for (final caseId in record.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          bridgeRecordId: record.bridgeRecordId,
        );
      }
      if (record.bridgeRole == DebugOnlyAdapterBridgeRole.debugCoreInput &&
          !record.adapterPacketIds.every(_isCorePacketId)) {
        add(
          id: 'debugCoreInputContainsNonCorePacket',
          severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
          message: 'debug core input contains non-core packet',
          bridgeRecordId: record.bridgeRecordId,
        );
      }
      if (record.contextOnly &&
          record.bridgeRole == DebugOnlyAdapterBridgeRole.debugCoreInput) {
        add(
          id: 'contextOnlyInputPromotedToDebugCore',
          severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
          message: 'context-only input cannot become debug core input',
          bridgeRecordId: record.bridgeRecordId,
        );
      }
      if (record.bridgeRole.isInactiveBoundary &&
          (!_recordIsInactiveSafe(record))) {
        add(
          id: 'blockedFutureInputMadeActive',
          severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
          message: 'blocked/future-only bridge input must remain inactive',
          bridgeRecordId: record.bridgeRecordId,
        );
      }
      if (record.isProductOutput) {
        add(
          id: 'productOutputActive',
          severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
          message: 'debug bridge design cannot be product output',
          bridgeRecordId: record.bridgeRecordId,
        );
      }
      if (record.isClassifierLabel) {
        add(
          id: 'classifierLabelOutputActive',
          severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
          message: 'debug bridge design cannot emit classifier labels',
          bridgeRecordId: record.bridgeRecordId,
        );
      }
      if (record.hasNumericScore) {
        add(
          id: 'numericScoreOutputActive',
          severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
          message: 'debug bridge design cannot emit numeric move scores',
          bridgeRecordId: record.bridgeRecordId,
        );
      }
      if (record.hasAggregateScore) {
        add(
          id: 'aggregateScoreOutputActive',
          severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
          message: 'debug bridge design cannot emit aggregate scores',
          bridgeRecordId: record.bridgeRecordId,
        );
      }
      if (record.ranksMoves) {
        add(
          id: 'moveRankingOutputActive',
          severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
          message: 'debug bridge design cannot rank moves',
          bridgeRecordId: record.bridgeRecordId,
        );
      }
      if (record.isOfficialMetric) {
        add(
          id: 'officialMetricOutputActive',
          severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
          message: 'debug bridge design cannot emit official metrics',
          bridgeRecordId: record.bridgeRecordId,
        );
      }
      if (record.cpLossOutputActive || record.winProbabilityOutputActive) {
        add(
          id: 'futureMetricOutputActive',
          severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
          message:
              'debug bridge design cannot activate CP-loss or win probability',
          bridgeRecordId: record.bridgeRecordId,
        );
      }
      if (record.quietPreparatoryScopeActive) {
        add(
          id: 'quietPreparatoryScopeActivated',
          severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
          message: 'quiet/preparatory scope must remain excluded',
          bridgeRecordId: record.bridgeRecordId,
        );
      }
      if (record.callsEngine) {
        add(
          id: 'engineCallFlagActive',
          severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
          message: 'debug bridge design cannot call an engine',
          bridgeRecordId: record.bridgeRecordId,
        );
      }
      if (record.writesPersistence) {
        add(
          id: 'persistenceWriteFlagActive',
          severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
          message: 'debug bridge design cannot write persistence',
          bridgeRecordId: record.bridgeRecordId,
        );
      }
      if (record.targetsUi) {
        add(
          id: 'uiTargetFlagActive',
          severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
          message: 'debug bridge design cannot target UI',
          bridgeRecordId: record.bridgeRecordId,
        );
      }
      if (record.backendOutputActive) {
        add(
          id: 'backendOutputActive',
          severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
          message: 'debug bridge design cannot target backend output',
          bridgeRecordId: record.bridgeRecordId,
        );
      }
      if (record.stockfishCommandFieldActive ||
          record.rawUciFieldActive ||
          record.pvDumpFieldActive) {
        add(
          id: 'stockfishRawUciPvDumpFieldActive',
          severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
          message:
              'Stockfish command, raw UCI, and PV dump fields must stay blocked',
          bridgeRecordId: record.bridgeRecordId,
        );
      }
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
        id: 'debugBridgeBoundaryPolicyViolation',
        severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
        message:
            'debug-only adapter bridge design crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<DebugOnlyAdapterBridgeDesignFinding> validateReportText(
    String reportText,
  ) {
    final findings = <DebugOnlyAdapterBridgeDesignFinding>[];
    void reportError(String id, String message) {
      findings.add(
        DebugOnlyAdapterBridgeDesignFinding(
          id: id,
          severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
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

List<DebugOnlyAdapterBridgeInputGroup> _groupsFromSummaryValidation({
  required InternalAdapterReadinessSummaryValidationResult
  summaryValidationResult,
  required InternalAdapterReadinessSummaryResult summaryResult,
}) {
  final coreRow = summaryValidationResult.rowForGroup(
    InternalAdapterReadinessSummaryGroupId.allowedCorePacketSummary,
  );
  final contextRow = summaryValidationResult.rowForGroup(
    InternalAdapterReadinessSummaryGroupId.constrainedContextPacketSummary,
  );
  final blockedRow = summaryValidationResult.rowForGroup(
    InternalAdapterReadinessSummaryGroupId.inactiveBlockedPacketSummary,
  );
  final futureRow = summaryValidationResult.rowForGroup(
    InternalAdapterReadinessSummaryGroupId.inactiveFutureOnlyPacketSummary,
  );
  final proofRow = summaryValidationResult.rowForGroup(
    InternalAdapterReadinessSummaryGroupId.androidProofBoundarySummary,
  );
  final ownerRow = summaryValidationResult.rowForGroup(
    InternalAdapterReadinessSummaryGroupId.ownerProofStatusSummary,
  );
  final activeSummaryGroup = summaryResult.summaryGroup(
    InternalAdapterReadinessSummaryGroupId.allowedActiveOutputFieldSummary,
  );
  final blockedSummaryGroup = summaryResult.summaryGroup(
    InternalAdapterReadinessSummaryGroupId.blockedOutputFieldSummary,
  );

  return <DebugOnlyAdapterBridgeInputGroup>[
    _groupFromRow(
      groupId: DebugOnlyAdapterBridgeInputGroupId.debugCoreInputGroup,
      designStatus: DebugOnlyAdapterBridgeInputGroupStatus.debugCoreInputReady,
      row: coreRow,
      summaryGroup: summaryResult.summaryGroup(
        InternalAdapterReadinessSummaryGroupId.allowedCorePacketSummary,
      ),
      activeFieldIds: _sortedStrings(_allowedBridgeFieldIds),
      blockedFieldIds: const <String>[],
      safeForFutureDebugBridge:
          coreRow.safeForNextPhase && coreRow.packetIds.every(_isCorePacketId),
      recommendation: DebugOnlyAdapterBridgeDesignRecommendation
          .allowDebugCoreInputForFutureBridge,
    ),
    _groupFromRow(
      groupId: DebugOnlyAdapterBridgeInputGroupId.debugContextInputGroup,
      designStatus:
          DebugOnlyAdapterBridgeInputGroupStatus.debugContextInputReady,
      row: contextRow,
      summaryGroup: summaryResult.summaryGroup(
        InternalAdapterReadinessSummaryGroupId.constrainedContextPacketSummary,
      ),
      activeFieldIds: _sortedStrings(_allowedBridgeFieldIds),
      blockedFieldIds: const <String>[],
      safeForFutureDebugBridge:
          contextRow.safeForNextPhase && contextRow.packetIds.isNotEmpty,
      recommendation: DebugOnlyAdapterBridgeDesignRecommendation
          .keepDebugContextInputContextOnly,
    ),
    _groupFromRow(
      groupId: DebugOnlyAdapterBridgeInputGroupId.debugBlockedInputGroup,
      designStatus:
          DebugOnlyAdapterBridgeInputGroupStatus.debugBlockedInputInactive,
      row: blockedRow,
      summaryGroup: summaryResult.summaryGroup(
        InternalAdapterReadinessSummaryGroupId.inactiveBlockedPacketSummary,
      ),
      activeFieldIds: const <String>[],
      blockedFieldIds: _blockedBridgeFieldIds,
      safeForFutureDebugBridge:
          blockedRow.safeForNextPhase &&
          blockedRow.activeOutputFieldIds.isEmpty,
      recommendation: DebugOnlyAdapterBridgeDesignRecommendation
          .keepDebugBlockedInputInactive,
    ),
    _groupFromRow(
      groupId: DebugOnlyAdapterBridgeInputGroupId.debugFutureOnlyInputGroup,
      designStatus:
          DebugOnlyAdapterBridgeInputGroupStatus.debugFutureOnlyInputInactive,
      row: futureRow,
      summaryGroup: summaryResult.summaryGroup(
        InternalAdapterReadinessSummaryGroupId.inactiveFutureOnlyPacketSummary,
      ),
      activeFieldIds: const <String>[],
      blockedFieldIds: _blockedBridgeFieldIds,
      safeForFutureDebugBridge:
          futureRow.safeForNextPhase && futureRow.activeOutputFieldIds.isEmpty,
      recommendation: DebugOnlyAdapterBridgeDesignRecommendation
          .keepDebugFutureOnlyInputInactive,
    ),
    DebugOnlyAdapterBridgeInputGroup(
      groupId: DebugOnlyAdapterBridgeInputGroupId.debugAllowedFieldGroup,
      designStatus:
          DebugOnlyAdapterBridgeInputGroupStatus.debugAllowedFieldsReady,
      packetIds: const <String>[],
      sourceSummaryGroupIds: _sortedGroupIds(
        activeSummaryGroup.sourceSummaryGroupIds,
      ),
      activeFieldIds: _sortedStrings(_allowedBridgeFieldIds),
      blockedFieldIds: const <String>[],
      supportCaseIds: _sortedStrings(activeSummaryGroup.supportCaseIds),
      newlyAddedSupportCaseIds: _sortedStrings(
        activeSummaryGroup.newlyAddedSupportCaseIds,
      ),
      androidProofCaseIds: const <String>[],
      warningReasons: const <String>[
        'allowed bridge fields are internal evidence-safe debug fields only',
      ],
      proofLimitReasons: const <String>[],
      futurePrerequisites: const <String>[],
      blockedBoundaryIds: const <String>[],
      safeForFutureDebugBridge: !_allowedBridgeFieldIds.any(
        _isBlockedBridgeFieldId,
      ),
      recommendation: DebugOnlyAdapterBridgeDesignRecommendation
          .keepDebugAllowedFieldsInternal,
    ),
    DebugOnlyAdapterBridgeInputGroup(
      groupId: DebugOnlyAdapterBridgeInputGroupId.debugBlockedFieldGroup,
      designStatus:
          DebugOnlyAdapterBridgeInputGroupStatus.debugBlockedFieldsReady,
      packetIds: const <String>[],
      sourceSummaryGroupIds: const <InternalEvidenceSummaryGroupId>[],
      activeFieldIds: const <String>[],
      blockedFieldIds: _sortedStrings(_blockedBridgeFieldIds),
      supportCaseIds: const <String>[],
      newlyAddedSupportCaseIds: const <String>[],
      androidProofCaseIds: const <String>[],
      warningReasons: _sortedStrings(<String>[
        ...blockedSummaryGroup.warningReasons,
        'blocked bridge fields remain explicit denials',
      ]),
      proofLimitReasons: const <String>[],
      futurePrerequisites: const <String>[],
      blockedBoundaryIds: _sortedStrings(_blockedBridgeFieldIds),
      safeForFutureDebugBridge: _blockedBridgeFieldIds.every(
        _blockedBridgeFieldIds.contains,
      ),
      recommendation: DebugOnlyAdapterBridgeDesignRecommendation
          .keepDebugBlockedFieldsDenied,
    ),
    _groupFromRow(
      groupId: DebugOnlyAdapterBridgeInputGroupId.debugProofBoundaryGroup,
      designStatus:
          DebugOnlyAdapterBridgeInputGroupStatus.debugProofBoundaryReady,
      row: proofRow,
      summaryGroup: summaryResult.summaryGroup(
        InternalAdapterReadinessSummaryGroupId.androidProofBoundarySummary,
      ),
      activeFieldIds: const <String>[],
      blockedFieldIds: const <String>[],
      safeForFutureDebugBridge:
          _setEquals(proofRow.androidProofCaseIds, _capturedAndroidProofIds) &&
          !proofRow.androidProofCaseIds.any(_phase32ECaseIds.contains),
      recommendation: DebugOnlyAdapterBridgeDesignRecommendation
          .keepDebugProofBoundaryCaptured,
    ),
    _groupFromRow(
      groupId: DebugOnlyAdapterBridgeInputGroupId.debugOwnerProofStatusGroup,
      designStatus:
          DebugOnlyAdapterBridgeInputGroupStatus.debugOwnerProofStatusReady,
      row: ownerRow,
      summaryGroup: summaryResult.summaryGroup(
        InternalAdapterReadinessSummaryGroupId.ownerProofStatusSummary,
      ),
      activeFieldIds: const <String>[],
      blockedFieldIds: const <String>[],
      safeForFutureDebugBridge: ownerRow.ownerProofQueueCount == 0,
      recommendation:
          DebugOnlyAdapterBridgeDesignRecommendation.keepDebugOwnerProofEmpty,
    ),
  ];
}

DebugOnlyAdapterBridgeInputGroup _groupFromRow({
  required DebugOnlyAdapterBridgeInputGroupId groupId,
  required DebugOnlyAdapterBridgeInputGroupStatus designStatus,
  required InternalAdapterReadinessSummaryValidationRow row,
  required InternalAdapterReadinessSummaryGroup summaryGroup,
  required List<String> activeFieldIds,
  required List<String> blockedFieldIds,
  required bool safeForFutureDebugBridge,
  required DebugOnlyAdapterBridgeDesignRecommendation recommendation,
}) {
  final unsafe =
      activeFieldIds.any(_isBlockedBridgeFieldId) ||
      activeFieldIds.any(_isLegacyBlockedOutputFieldId) ||
      row.hasUnsafeOutput;
  return DebugOnlyAdapterBridgeInputGroup(
    groupId: groupId,
    designStatus: unsafe
        ? DebugOnlyAdapterBridgeInputGroupStatus.unsafeGroup
        : safeForFutureDebugBridge
        ? designStatus
        : DebugOnlyAdapterBridgeInputGroupStatus.invalidGroup,
    packetIds: _sortedStrings(row.packetIds),
    sourceSummaryGroupIds: _sortedGroupIds(summaryGroup.sourceSummaryGroupIds),
    activeFieldIds: _sortedStrings(activeFieldIds),
    blockedFieldIds: _sortedStrings(blockedFieldIds),
    supportCaseIds: _sortedStrings(row.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(row.newlyAddedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(row.androidProofCaseIds),
    warningReasons: _sortedStrings(<String>[
      row.warningReason,
      ...summaryGroup.warningReasons,
    ]),
    proofLimitReasons: _sortedStrings(summaryGroup.proofLimitReasons),
    futurePrerequisites: _sortedStrings(summaryGroup.futurePrerequisites),
    blockedBoundaryIds: _sortedStrings(<String>[
      ...summaryGroup.blockedBoundaryIds,
      ...row.packetIds.where(
        (packetId) =>
            groupId ==
                DebugOnlyAdapterBridgeInputGroupId.debugBlockedInputGroup ||
            groupId ==
                DebugOnlyAdapterBridgeInputGroupId.debugFutureOnlyInputGroup,
      ),
    ]),
    safeForFutureDebugBridge: safeForFutureDebugBridge && !unsafe,
    recommendation: unsafe
        ? DebugOnlyAdapterBridgeDesignRecommendation.blockUnsafeBridgeDesign
        : safeForFutureDebugBridge
        ? recommendation
        : DebugOnlyAdapterBridgeDesignRecommendation
              .investigateBridgeDesignFailure,
  );
}

List<DebugOnlyAdapterBridgeRecord> _recordsFromGroups(
  List<DebugOnlyAdapterBridgeInputGroup> groups,
) {
  return <DebugOnlyAdapterBridgeRecord>[
    _recordFromGroup(
      groups,
      DebugOnlyAdapterBridgeInputGroupId.debugCoreInputGroup,
      DebugOnlyAdapterBridgeRole.debugCoreInput,
      DebugOnlyAdapterBridgeRecordDesignStatus.debugCoreInputDesigned,
      allowedForFutureDebugBridge: true,
      contextOnly: false,
      inactive: false,
      recommendation: DebugOnlyAdapterBridgeDesignRecommendation
          .allowDebugCoreInputForFutureBridge,
    ),
    _recordFromGroup(
      groups,
      DebugOnlyAdapterBridgeInputGroupId.debugContextInputGroup,
      DebugOnlyAdapterBridgeRole.debugContextOnlyInput,
      DebugOnlyAdapterBridgeRecordDesignStatus.debugContextOnlyInputDesigned,
      allowedForFutureDebugBridge: true,
      contextOnly: true,
      inactive: false,
      recommendation: DebugOnlyAdapterBridgeDesignRecommendation
          .keepDebugContextInputContextOnly,
    ),
    _recordFromGroup(
      groups,
      DebugOnlyAdapterBridgeInputGroupId.debugBlockedInputGroup,
      DebugOnlyAdapterBridgeRole.debugBlockedInput,
      DebugOnlyAdapterBridgeRecordDesignStatus.debugBlockedInputInactive,
      allowedForFutureDebugBridge: false,
      contextOnly: false,
      inactive: true,
      recommendation: DebugOnlyAdapterBridgeDesignRecommendation
          .keepDebugBlockedInputInactive,
    ),
    _recordFromGroup(
      groups,
      DebugOnlyAdapterBridgeInputGroupId.debugFutureOnlyInputGroup,
      DebugOnlyAdapterBridgeRole.debugFutureOnlyInput,
      DebugOnlyAdapterBridgeRecordDesignStatus.debugFutureOnlyInputInactive,
      allowedForFutureDebugBridge: false,
      contextOnly: false,
      inactive: true,
      recommendation: DebugOnlyAdapterBridgeDesignRecommendation
          .keepDebugFutureOnlyInputInactive,
    ),
    _recordFromGroup(
      groups,
      DebugOnlyAdapterBridgeInputGroupId.debugAllowedFieldGroup,
      DebugOnlyAdapterBridgeRole.debugAllowedField,
      DebugOnlyAdapterBridgeRecordDesignStatus.debugAllowedFieldDesigned,
      allowedForFutureDebugBridge: true,
      contextOnly: false,
      inactive: false,
      recommendation: DebugOnlyAdapterBridgeDesignRecommendation
          .keepDebugAllowedFieldsInternal,
    ),
    _recordFromGroup(
      groups,
      DebugOnlyAdapterBridgeInputGroupId.debugBlockedFieldGroup,
      DebugOnlyAdapterBridgeRole.debugBlockedField,
      DebugOnlyAdapterBridgeRecordDesignStatus.debugBlockedFieldDesigned,
      allowedForFutureDebugBridge: false,
      contextOnly: false,
      inactive: true,
      recommendation: DebugOnlyAdapterBridgeDesignRecommendation
          .keepDebugBlockedFieldsDenied,
    ),
    _recordFromGroup(
      groups,
      DebugOnlyAdapterBridgeInputGroupId.debugProofBoundaryGroup,
      DebugOnlyAdapterBridgeRole.debugProofBoundary,
      DebugOnlyAdapterBridgeRecordDesignStatus.debugProofBoundaryDesigned,
      allowedForFutureDebugBridge: true,
      contextOnly: false,
      inactive: false,
      recommendation: DebugOnlyAdapterBridgeDesignRecommendation
          .keepDebugProofBoundaryCaptured,
    ),
    _recordFromGroup(
      groups,
      DebugOnlyAdapterBridgeInputGroupId.debugOwnerProofStatusGroup,
      DebugOnlyAdapterBridgeRole.debugOwnerProofStatus,
      DebugOnlyAdapterBridgeRecordDesignStatus.debugOwnerProofStatusDesigned,
      allowedForFutureDebugBridge: true,
      contextOnly: false,
      inactive: false,
      recommendation:
          DebugOnlyAdapterBridgeDesignRecommendation.keepDebugOwnerProofEmpty,
    ),
  ];
}

DebugOnlyAdapterBridgeRecord _recordFromGroup(
  List<DebugOnlyAdapterBridgeInputGroup> groups,
  DebugOnlyAdapterBridgeInputGroupId groupId,
  DebugOnlyAdapterBridgeRole bridgeRole,
  DebugOnlyAdapterBridgeRecordDesignStatus validStatus, {
  required bool allowedForFutureDebugBridge,
  required bool contextOnly,
  required bool inactive,
  required DebugOnlyAdapterBridgeDesignRecommendation recommendation,
}) {
  final group = groups.singleWhere((group) => group.groupId == groupId);
  final unsafe =
      group.designStatus.isUnsafe ||
      group.activeFieldIds.any(_isBlockedBridgeFieldId) ||
      group.activeFieldIds.any(_isLegacyBlockedOutputFieldId);
  final invalid = !group.safeForFutureDebugBridge;
  final status = unsafe
      ? DebugOnlyAdapterBridgeRecordDesignStatus.unsafeRecord
      : invalid
      ? DebugOnlyAdapterBridgeRecordDesignStatus.invalidRecord
      : validStatus;
  return DebugOnlyAdapterBridgeRecord(
    bridgeRecordId: 'debug-bridge-${groupId.wire}',
    sourceValidationRowId:
        'summary-validation-${_sourceGroupFor(groupId).wire}',
    sourceSummaryGroupId: _sourceGroupFor(groupId),
    bridgeRole: bridgeRole,
    designStatus: status,
    allowedForFutureDebugBridge:
        allowedForFutureDebugBridge && !unsafe && !invalid,
    contextOnly: contextOnly,
    inactive: inactive,
    adapterPacketIds: _sortedStrings(group.packetIds),
    sourceSummaryGroupIds: _sortedGroupIds(group.sourceSummaryGroupIds),
    activeFieldIds: inactive
        ? const <String>[]
        : _sortedStrings(group.activeFieldIds),
    blockedFieldIds: _sortedStrings(group.blockedFieldIds),
    supportCaseIds: _sortedStrings(group.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(group.newlyAddedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(group.androidProofCaseIds),
    warningReasons: _sortedStrings(group.warningReasons),
    proofLimitReasons: _sortedStrings(group.proofLimitReasons),
    futurePrerequisites: _sortedStrings(group.futurePrerequisites),
    blockedBoundaryIds: _sortedStrings(group.blockedBoundaryIds),
    recommendation: unsafe
        ? DebugOnlyAdapterBridgeDesignRecommendation.blockUnsafeBridgeDesign
        : invalid
        ? DebugOnlyAdapterBridgeDesignRecommendation
              .investigateBridgeDesignFailure
        : recommendation,
  );
}

InternalAdapterReadinessSummaryGroupId _sourceGroupFor(
  DebugOnlyAdapterBridgeInputGroupId groupId,
) {
  return switch (groupId) {
    DebugOnlyAdapterBridgeInputGroupId.debugCoreInputGroup =>
      InternalAdapterReadinessSummaryGroupId.allowedCorePacketSummary,
    DebugOnlyAdapterBridgeInputGroupId.debugContextInputGroup =>
      InternalAdapterReadinessSummaryGroupId.constrainedContextPacketSummary,
    DebugOnlyAdapterBridgeInputGroupId.debugBlockedInputGroup =>
      InternalAdapterReadinessSummaryGroupId.inactiveBlockedPacketSummary,
    DebugOnlyAdapterBridgeInputGroupId.debugFutureOnlyInputGroup =>
      InternalAdapterReadinessSummaryGroupId.inactiveFutureOnlyPacketSummary,
    DebugOnlyAdapterBridgeInputGroupId.debugAllowedFieldGroup =>
      InternalAdapterReadinessSummaryGroupId.allowedActiveOutputFieldSummary,
    DebugOnlyAdapterBridgeInputGroupId.debugBlockedFieldGroup =>
      InternalAdapterReadinessSummaryGroupId.blockedOutputFieldSummary,
    DebugOnlyAdapterBridgeInputGroupId.debugProofBoundaryGroup =>
      InternalAdapterReadinessSummaryGroupId.androidProofBoundarySummary,
    DebugOnlyAdapterBridgeInputGroupId.debugOwnerProofStatusGroup =>
      InternalAdapterReadinessSummaryGroupId.ownerProofStatusSummary,
  };
}

DebugOnlyAdapterBridgeDesignResult _resultFromGroupsAndRecords({
  required InternalAdapterReadinessSummaryValidationResult
  summaryValidationResult,
  required InternalAdapterReadinessSummaryResult summaryResult,
  required InternalEvidenceAdapterPrototypeReadinessGateResult
  readinessGateResult,
  required InternalEvidenceAdapterPrototypeValidationResult validationResult,
  required List<DebugOnlyAdapterBridgeInputGroup> inputGroups,
  required List<DebugOnlyAdapterBridgeRecord> bridgeRecords,
  required List<DebugOnlyAdapterBridgeDesignFinding> validationFindings,
}) {
  final allowedFieldIds = _sortedStrings(
    inputGroups
        .where(
          (group) =>
              group.groupId ==
              DebugOnlyAdapterBridgeInputGroupId.debugAllowedFieldGroup,
        )
        .expand((group) => group.activeFieldIds),
  );
  final blockedFieldIds = _sortedStrings(
    inputGroups
        .where(
          (group) =>
              group.groupId ==
              DebugOnlyAdapterBridgeInputGroupId.debugBlockedFieldGroup,
        )
        .expand((group) => group.blockedFieldIds),
  );
  final unsafeCount = bridgeRecords
      .where(
        (record) =>
            record.hasUnsafeOutput ||
            record.designStatus ==
                DebugOnlyAdapterBridgeRecordDesignStatus.unsafeRecord,
      )
      .length;
  final blockerCount = validationFindings
      .where(
        (finding) =>
            finding.severity == DebugOnlyAdapterBridgeDesignSeverity.blocker,
      )
      .length;
  final criticalCount = validationFindings
      .where((finding) => finding.isCritical)
      .length;
  final base = DebugOnlyAdapterBridgeDesignResult(
    designStatus: DebugOnlyAdapterBridgeDesignStatus.invalid,
    sourceSummaryValidationStatus: summaryValidationResult.validationStatus,
    sourceSummaryStatus: summaryResult.summaryStatus,
    sourceReadinessGateStatus: readinessGateResult.readinessStatus,
    sourcePrototypeValidationStatus: validationResult.validationStatus,
    inputGroups: inputGroups,
    bridgeRecords: bridgeRecords,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...summaryValidationResult.warnings,
      if (bridgeRecords.any((record) => record.contextOnly))
        'debug context inputs remain context-only',
      if (bridgeRecords.any((record) => record.inactive))
        'debug blocked/future-only inputs remain inactive',
      if (summaryValidationResult.ownerProofQueueCount == 0)
        'owner proof status remains empty',
    ]),
    failures: _sortedStrings(<String>[
      ...summaryValidationResult.failures,
      ...validationFindings.map((finding) => finding.message),
    ]),
    totalBridgeRecords: bridgeRecords.length,
    debugCoreInputCount: bridgeRecords
        .where(
          (record) =>
              record.bridgeRole == DebugOnlyAdapterBridgeRole.debugCoreInput,
        )
        .length,
    debugContextInputCount: bridgeRecords
        .where(
          (record) =>
              record.bridgeRole ==
              DebugOnlyAdapterBridgeRole.debugContextOnlyInput,
        )
        .length,
    debugBlockedInputCount: bridgeRecords
        .where(
          (record) =>
              record.bridgeRole == DebugOnlyAdapterBridgeRole.debugBlockedInput,
        )
        .length,
    debugFutureOnlyInputCount: bridgeRecords
        .where(
          (record) =>
              record.bridgeRole ==
              DebugOnlyAdapterBridgeRole.debugFutureOnlyInput,
        )
        .length,
    allowedFieldCount: allowedFieldIds.length,
    blockedFieldCount: blockedFieldIds.length,
    unsafeCount: unsafeCount,
    blockerCount: blockerCount,
    criticalCount: criticalCount,
    ownerProofQueueCount: summaryValidationResult.ownerProofQueueCount,
    supportCaseIds: _sortedStrings(summaryValidationResult.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(
      summaryValidationResult.newlyAddedSupportCaseIds,
    ),
    androidProofCaseIds: _sortedStrings(
      summaryValidationResult.androidProofCaseIds,
    ),
    allowedFieldIds: allowedFieldIds,
    blockedFieldIds: blockedFieldIds,
    safeForPhase32U: false,
    phase32URecommendation: DebugOnlyAdapterBridgeDesignPhase32URecommendation
        .addMoreGoldenCoverageFirst,
    developerOnly:
        summaryValidationResult.developerOnly && summaryResult.developerOnly,
    productOutputActive: summaryValidationResult.productOutputActive,
    classifierOutputActive: summaryValidationResult.classifierOutputActive,
    finalMoveLabelOutputActive:
        summaryValidationResult.finalMoveLabelOutputActive,
    officialMetricOutputActive:
        summaryValidationResult.officialMetricOutputActive,
    cpLossOutputActive: summaryValidationResult.cpLossOutputActive,
    winProbabilityOutputActive:
        summaryValidationResult.winProbabilityOutputActive,
    numericOutputActive: summaryValidationResult.numericOutputActive,
    aggregateScoreOutputActive: false,
    moveRankingOutputActive: summaryValidationResult.moveRankingOutputActive,
    quietPreparatoryScopeActivated:
        summaryValidationResult.quietPreparatoryScopeActivated,
    engineCallsActive: summaryValidationResult.engineCallsActive,
    persistenceWritesActive: summaryValidationResult.persistenceWritesActive,
    uiTargetsActive: summaryValidationResult.uiTargetsActive,
    backendOutputActive: summaryValidationResult.backendOutputActive,
    stockfishCommandFieldActive: false,
    rawUciFieldActive: false,
    pvDumpFieldActive: false,
  );
  final status = _designStatusFor(
    base,
    summaryValidationResult: summaryValidationResult,
  );
  final safeForPhase32U =
      (status == DebugOnlyAdapterBridgeDesignStatus.designReadyWithWarnings ||
          status == DebugOnlyAdapterBridgeDesignStatus.designReadyClean) &&
      summaryValidationResult.safeForPhase32T &&
      !summaryValidationResult.isStrictlyBlocked &&
      !summaryValidationResult
          .hasUnsafeAdapterSummaryValidationPolicyViolation &&
      unsafeCount == 0 &&
      blockerCount == 0 &&
      criticalCount == 0 &&
      validationFindings.every((finding) => !finding.blocksStrict) &&
      bridgeRecords.every(
        (record) =>
            !record.hasUnsafeOutput &&
            record.designStatus !=
                DebugOnlyAdapterBridgeRecordDesignStatus.invalidRecord,
      ) &&
      inputGroups.every((group) => group.safeForFutureDebugBridge);
  return base.copyWith(
    designStatus: status,
    safeForPhase32U: safeForPhase32U,
    phase32URecommendation: _phase32URecommendationFor(
      status: status,
      safeForPhase32U: safeForPhase32U,
      ownerProofQueueCount: summaryValidationResult.ownerProofQueueCount,
    ),
  );
}

DebugOnlyAdapterBridgeDesignStatus _designStatusFor(
  DebugOnlyAdapterBridgeDesignResult result, {
  required InternalAdapterReadinessSummaryValidationResult
  summaryValidationResult,
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
    return DebugOnlyAdapterBridgeDesignStatus.blockedByPolicyBoundary;
  }
  if (summaryValidationResult.validationStatus ==
          InternalAdapterReadinessSummaryValidationStatus
              .blockedByUnsafeSummary ||
      summaryValidationResult.validationStatus ==
          InternalAdapterReadinessSummaryValidationStatus
              .blockedByPolicyBoundary ||
      summaryValidationResult.unsafeSummaryCount > 0 ||
      summaryValidationResult
          .hasUnsafeAdapterSummaryValidationPolicyViolation ||
      result.unsafeCount > 0 ||
      result.criticalCount > 0) {
    return DebugOnlyAdapterBridgeDesignStatus.blockedBySummaryValidationFailure;
  }
  if (!summaryValidationResult.safeForPhase32T ||
      summaryValidationResult.isStrictlyBlocked ||
      result.blockerCount > 0 ||
      result.validationFindings.any((finding) => finding.blocksStrict) ||
      result.bridgeRecords.any(
        (record) =>
            record.designStatus ==
            DebugOnlyAdapterBridgeRecordDesignStatus.invalidRecord,
      ) ||
      result.inputGroups.any((group) => !group.safeForFutureDebugBridge)) {
    return DebugOnlyAdapterBridgeDesignStatus.invalid;
  }
  if (result.bridgeRecords.isEmpty || result.inputGroups.isEmpty) {
    return DebugOnlyAdapterBridgeDesignStatus.invalid;
  }
  if (result.debugContextInputCount > 0 ||
      result.debugBlockedInputCount > 0 ||
      result.debugFutureOnlyInputCount > 0 ||
      result.warnings.isNotEmpty) {
    return DebugOnlyAdapterBridgeDesignStatus.designReadyWithWarnings;
  }
  return DebugOnlyAdapterBridgeDesignStatus.designReadyClean;
}

DebugOnlyAdapterBridgeDesignPhase32URecommendation _phase32URecommendationFor({
  required DebugOnlyAdapterBridgeDesignStatus status,
  required bool safeForPhase32U,
  required int ownerProofQueueCount,
}) {
  if (status ==
          DebugOnlyAdapterBridgeDesignStatus
              .blockedBySummaryValidationFailure ||
      status == DebugOnlyAdapterBridgeDesignStatus.blockedByPolicyBoundary) {
    return DebugOnlyAdapterBridgeDesignPhase32URecommendation
        .blockedByUnsafeBridgeDesign;
  }
  if (ownerProofQueueCount > 0) {
    return DebugOnlyAdapterBridgeDesignPhase32URecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase32U) {
    return DebugOnlyAdapterBridgeDesignPhase32URecommendation
        .addMoreGoldenCoverageFirst;
  }
  return DebugOnlyAdapterBridgeDesignPhase32URecommendation
      .validateDebugOnlyAdapterBridgeDesign;
}

bool _recordIsInactiveSafe(DebugOnlyAdapterBridgeRecord record) {
  return record.inactive &&
      record.bridgeRole.isInactiveBoundary &&
      record.activeFieldIds.isEmpty &&
      !record.hasUnsafeOutput;
}

bool _hasExplicitPvProofReason(DebugOnlyAdapterBridgeDesignResult result) {
  final reasons = <String>[
    ...result.warnings,
    ...result.failures,
    ...result.bridgeRecords.expand((record) => record.warningReasons),
    ...result.bridgeRecords.expand((record) => record.proofLimitReasons),
    ...result.bridgeRecords.expand((record) => record.futurePrerequisites),
  ].join(' ').toLowerCase();
  return reasons.contains('pv') || reasons.contains('multipv');
}

void _checkActiveBridgeField(
  void Function({
    required String id,
    required DebugOnlyAdapterBridgeDesignSeverity severity,
    required String message,
    String? bridgeRecordId,
    DebugOnlyAdapterBridgeInputGroupId? bridgeGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String fieldId, {
  String? bridgeRecordId,
}) {
  if (_isBlockedBridgeFieldId(fieldId) ||
      _isLegacyBlockedOutputFieldId(fieldId)) {
    add(
      id: 'activeBlockedBridgeField',
      severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
      message: '$fieldId cannot be an active debug bridge field',
      bridgeRecordId: bridgeRecordId,
      fieldId: fieldId,
    );
  }
}

void _checkAndroidProofCase(
  void Function({
    required String id,
    required DebugOnlyAdapterBridgeDesignSeverity severity,
    required String message,
    String? bridgeRecordId,
    DebugOnlyAdapterBridgeInputGroupId? bridgeGroupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String caseId,
  List<String> provenAndroidIds, {
  String? bridgeRecordId,
}) {
  if (_phase32ECaseIds.contains(caseId)) {
    add(
      id: 'phase32ECaseTreatedAsCapturedProof',
      severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
      message: '$caseId cannot be captured Android proof',
      bridgeRecordId: bridgeRecordId,
      caseId: caseId,
    );
    return;
  }
  if (!_capturedAndroidProofIds.contains(caseId) ||
      !provenAndroidIds.contains(caseId)) {
    add(
      id: 'unprovenAndroidProofId',
      severity: DebugOnlyAdapterBridgeDesignSeverity.critical,
      message: '$caseId is not captured Android proof',
      bridgeRecordId: bridgeRecordId,
      caseId: caseId,
    );
  }
}

List<String> _provenAndroidProofIds(GoldenAndroidProofEvidence? evidence) {
  return _sortedStrings(evidence?.targetCaseIds ?? const <String>[]);
}

int _compareFindings(
  DebugOnlyAdapterBridgeDesignFinding a,
  DebugOnlyAdapterBridgeDesignFinding b,
) {
  final severity = _severityRank(
    b.severity,
  ).compareTo(_severityRank(a.severity));
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.bridgeRecordId ?? '').compareTo(b.bridgeRecordId ?? '');
}

int _severityRank(DebugOnlyAdapterBridgeDesignSeverity severity) {
  return switch (severity) {
    DebugOnlyAdapterBridgeDesignSeverity.warning => 1,
    DebugOnlyAdapterBridgeDesignSeverity.blocker => 2,
    DebugOnlyAdapterBridgeDesignSeverity.critical => 3,
  };
}

bool _isCorePacketId(String packetId) {
  return packetId == 'packet-allowedEvidenceSummary' ||
      packetId == 'packet-improvedSupportSummary';
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.where((value) => value.trim().isNotEmpty).toSet().toList()
    ..sort();
}

List<InternalEvidenceSummaryGroupId> _sortedGroupIds(
  Iterable<InternalEvidenceSummaryGroupId> ids,
) {
  return ids.toSet().toList()..sort((a, b) => a.wire.compareTo(b.wire));
}

String _ids(Iterable<String> values) {
  final sorted = _sortedStrings(values);
  return sorted.isEmpty ? 'none' : sorted.map(_cell).join(', ');
}

String _summaryGroupIds(Iterable<InternalEvidenceSummaryGroupId> ids) {
  final sorted = _sortedGroupIds(ids);
  return sorted.isEmpty ? 'none' : sorted.map((id) => id.wire).join(', ');
}

String _recordIds(Iterable<DebugOnlyAdapterBridgeRecord> records) {
  return _ids(records.map((record) => record.bridgeRecordId));
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

bool _isBlockedBridgeFieldId(String value) {
  return _blockedBridgeFieldIds.contains(value);
}

bool _isLegacyBlockedOutputFieldId(String value) {
  return _legacyBlockedOutputFieldIds.contains(value);
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

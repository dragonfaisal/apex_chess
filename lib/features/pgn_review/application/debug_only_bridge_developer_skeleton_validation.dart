/// Developer-only validation for the debug-only bridge skeleton.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_skeleton.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_implementation_design.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugOnlyBridgeDeveloperSkeletonValidationReportVersion =
    'debug-only-bridge-developer-skeleton-validation-v1';

enum DebugOnlyBridgeDeveloperSkeletonValidationStatus {
  skeletonValidatedWithWarnings('skeletonValidatedWithWarnings'),
  skeletonValidatedClean('skeletonValidatedClean'),
  blockedByUnsafeSkeleton('blockedByUnsafeSkeleton'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const DebugOnlyBridgeDeveloperSkeletonValidationStatus(this.wire);

  final String wire;
}

enum DebugOnlyBridgeDeveloperSkeletonValidationCheckId {
  skeletonConsumesImplementationDesign('skeletonConsumesImplementationDesign'),
  inputPacketHasSafeFieldsOnly('inputPacketHasSafeFieldsOnly'),
  outputPacketIsDeveloperOnly('outputPacketIsDeveloperOnly'),
  policyDeniesProductBoundaries('policyDeniesProductBoundaries'),
  coreRecordsRemainCore('coreRecordsRemainCore'),
  contextRecordsRemainContextOnly('contextRecordsRemainContextOnly'),
  inactiveRecordsRemainInactive('inactiveRecordsRemainInactive'),
  deniedFieldsRemainInactive('deniedFieldsRemainInactive'),
  stockfishRawUciPvDumpRemainDenied('stockfishRawUciPvDumpRemainDenied'),
  runtimePrototypeWiringRemainBlocked('runtimePrototypeWiringRemainBlocked'),
  androidProofIdsAreCapturedOnly('androidProofIdsAreCapturedOnly'),
  phase32ECasesAreNotCapturedProof('phase32ECasesAreNotCapturedProof'),
  ownerProofQueueRemainsEmpty('ownerProofQueueRemainsEmpty'),
  noLabelsScoresRankingsMetrics('noLabelsScoresRankingsMetrics'),
  noUiBackendPersistenceEngineFields('noUiBackendPersistenceEngineFields'),
  noSchedulerExecution('noSchedulerExecution'),
  noQuietPreparatoryActivation('noQuietPreparatoryActivation'),
  reportContainsNoRawUciOrPvDump('reportContainsNoRawUciOrPvDump'),
  phase33HRequirementPresent('phase33HRequirementPresent');

  const DebugOnlyBridgeDeveloperSkeletonValidationCheckId(this.wire);

  final String wire;
}

enum DebugOnlyBridgeDeveloperSkeletonValidationCheckStatus {
  passed('passed'),
  passedWithWarnings('passedWithWarnings'),
  failed('failed'),
  blocked('blocked');

  const DebugOnlyBridgeDeveloperSkeletonValidationCheckStatus(this.wire);

  final String wire;

  bool get isPassed => this == passed || this == passedWithWarnings;

  bool get isWarning => this == passedWithWarnings;
}

enum DebugOnlyBridgeDeveloperSkeletonValidationSeverity {
  none('none'),
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const DebugOnlyBridgeDeveloperSkeletonValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict => this == blocker || this == critical;

  bool get isCritical => this == critical;
}

enum DebugOnlyBridgeDeveloperSkeletonValidationRowRole {
  inputPacket('inputPacket'),
  outputPacket('outputPacket'),
  policy('policy'),
  core('core'),
  context('context'),
  inactiveBlocked('inactiveBlocked'),
  inactiveFuture('inactiveFuture'),
  allowedFieldBoundary('allowedFieldBoundary'),
  deniedFieldBoundary('deniedFieldBoundary'),
  stockfishRawUciPvDumpDenied('stockfishRawUciPvDumpDenied'),
  runtimeBlocked('runtimeBlocked'),
  proofBoundary('proofBoundary'),
  ownerProofBoundary('ownerProofBoundary'),
  futureRequirement('futureRequirement');

  const DebugOnlyBridgeDeveloperSkeletonValidationRowRole(this.wire);

  final String wire;

  bool get isRecordRole =>
      this != inputPacket && this != outputPacket && this != policy;
}

enum DebugOnlyBridgeDeveloperSkeletonValidationRowStatus {
  validInputPacket('validInputPacket'),
  validOutputPacket('validOutputPacket'),
  validPolicy('validPolicy'),
  validCoreRecord('validCoreRecord'),
  validContextRecord('validContextRecord'),
  validInactiveRecord('validInactiveRecord'),
  validAllowedFieldBoundary('validAllowedFieldBoundary'),
  validDeniedBoundary('validDeniedBoundary'),
  validRuntimeBlocked('validRuntimeBlocked'),
  validProofBoundary('validProofBoundary'),
  validOwnerProofBoundary('validOwnerProofBoundary'),
  validFutureRequirement('validFutureRequirement'),
  unsafeRow('unsafeRow'),
  invalidRow('invalidRow');

  const DebugOnlyBridgeDeveloperSkeletonValidationRowStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == unsafeRow;

  bool get isInvalid => this == invalidRow;
}

enum DebugOnlyBridgeDeveloperSkeletonValidationRecommendation {
  keepInputPacketInternal('keepInputPacketInternal'),
  keepOutputPacketDeveloperOnly('keepOutputPacketDeveloperOnly'),
  keepPolicyBoundariesDenied('keepPolicyBoundariesDenied'),
  keepCoreRecordCore('keepCoreRecordCore'),
  keepContextRecordContextOnly('keepContextRecordContextOnly'),
  keepInactiveRecordInactive('keepInactiveRecordInactive'),
  keepAllowedFieldBoundaryInternal('keepAllowedFieldBoundaryInternal'),
  keepDeniedBoundaryDenied('keepDeniedBoundaryDenied'),
  keepStockfishRawUciPvDumpDenied('keepStockfishRawUciPvDumpDenied'),
  keepRuntimePrototypeWiringBlocked('keepRuntimePrototypeWiringBlocked'),
  keepProofBoundaryCapturedOnly('keepProofBoundaryCapturedOnly'),
  keepOwnerProofEmpty('keepOwnerProofEmpty'),
  requirePhase33HInspectionHarnessCheckpoint(
    'requirePhase33HInspectionHarnessCheckpoint',
  ),
  investigateSkeletonValidationFailure('investigateSkeletonValidationFailure'),
  blockUnsafeSkeletonValidation('blockUnsafeSkeletonValidation');

  const DebugOnlyBridgeDeveloperSkeletonValidationRecommendation(this.wire);

  final String wire;
}

enum DebugOnlyBridgeDeveloperSkeletonValidationPhase33HRecommendation {
  proceedToDebugOnlyBridgeDeveloperInspectionHarness(
    'proceedToDebugOnlyBridgeDeveloperInspectionHarness',
  ),
  proceedToDebugOnlyBridgeSkeletonValidationReportOnly(
    'proceedToDebugOnlyBridgeSkeletonValidationReportOnly',
  ),
  proceedToSkeletonHardening('proceedToSkeletonHardening'),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeSkeletonValidation('blockedByUnsafeSkeletonValidation');

  const DebugOnlyBridgeDeveloperSkeletonValidationPhase33HRecommendation(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeDeveloperSkeletonValidationReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeDeveloperSkeletonValidationReportFormat(this.wire);

  final String wire;
}

class DebugOnlyBridgeDeveloperSkeletonValidationRequest {
  const DebugOnlyBridgeDeveloperSkeletonValidationRequest({
    this.skeletonResult,
    this.inputPacket,
    this.outputPacket,
    this.policy,
    this.implementationDesignResult,
    this.skeleton = const DebugOnlyBridgeSkeleton(),
    this.implementationDesign = const DebugOnlyBridgeImplementationDesign(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const DebugOnlyBridgeDeveloperSkeletonValidationRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final DebugOnlyBridgeSkeletonResult? skeletonResult;
  final DebugOnlyBridgeInputPacket? inputPacket;
  final DebugOnlyBridgeOutputPacket? outputPacket;
  final DebugOnlyBridgePolicy? policy;
  final DebugOnlyBridgeImplementationDesignResult? implementationDesignResult;
  final DebugOnlyBridgeSkeleton skeleton;
  final DebugOnlyBridgeImplementationDesign implementationDesign;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class DebugOnlyBridgeDeveloperSkeletonValidationCheck {
  const DebugOnlyBridgeDeveloperSkeletonValidationCheck({
    required this.checkId,
    required this.checkStatus,
    required this.severity,
    required this.message,
    required this.recommendation,
  });

  final DebugOnlyBridgeDeveloperSkeletonValidationCheckId checkId;
  final DebugOnlyBridgeDeveloperSkeletonValidationCheckStatus checkStatus;
  final DebugOnlyBridgeDeveloperSkeletonValidationSeverity severity;
  final String message;
  final DebugOnlyBridgeDeveloperSkeletonValidationRecommendation recommendation;

  bool get isCritical => severity.isCritical;

  bool get blocksStrict => severity.blocksStrict;

  Map<String, Object?> toJson() => <String, Object?>{
    'checkId': checkId.wire,
    'checkStatus': checkStatus.wire,
    'severity': severity.wire,
    'message': message,
    'recommendation': recommendation.wire,
  };
}

class DebugOnlyBridgeDeveloperSkeletonValidationRow {
  const DebugOnlyBridgeDeveloperSkeletonValidationRow({
    required this.validationRowId,
    required this.sourceRecordId,
    required this.sourcePacketId,
    required this.role,
    required this.status,
    required this.developerOnly,
    required this.designOnly,
    required this.contextOnly,
    required this.inactive,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.androidProofCaseIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.blockedBoundaryIds,
    required this.safetyFlags,
    required this.findings,
    required this.recommendation,
  });

  final String validationRowId;
  final String sourceRecordId;
  final String sourcePacketId;
  final DebugOnlyBridgeDeveloperSkeletonValidationRowRole role;
  final DebugOnlyBridgeDeveloperSkeletonValidationRowStatus status;
  final bool developerOnly;
  final bool designOnly;
  final bool contextOnly;
  final bool inactive;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final List<String> androidProofCaseIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> blockedBoundaryIds;
  final Map<String, bool> safetyFlags;
  final List<String> findings;
  final DebugOnlyBridgeDeveloperSkeletonValidationRecommendation recommendation;

  bool get hasUnsafeOutput =>
      status.isUnsafe ||
      !developerOnly ||
      !designOnly ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId) ||
      safetyFlags.values.any((value) => value);

  bool get hasActiveDeniedField =>
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId);

  DebugOnlyBridgeDeveloperSkeletonValidationRow copyWith({
    String? validationRowId,
    String? sourceRecordId,
    String? sourcePacketId,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole? role,
    DebugOnlyBridgeDeveloperSkeletonValidationRowStatus? status,
    bool? developerOnly,
    bool? designOnly,
    bool? contextOnly,
    bool? inactive,
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    List<String>? androidProofCaseIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? blockedBoundaryIds,
    Map<String, bool>? safetyFlags,
    List<String>? findings,
    DebugOnlyBridgeDeveloperSkeletonValidationRecommendation? recommendation,
  }) {
    return DebugOnlyBridgeDeveloperSkeletonValidationRow(
      validationRowId: validationRowId ?? this.validationRowId,
      sourceRecordId: sourceRecordId ?? this.sourceRecordId,
      sourcePacketId: sourcePacketId ?? this.sourcePacketId,
      role: role ?? this.role,
      status: status ?? this.status,
      developerOnly: developerOnly ?? this.developerOnly,
      designOnly: designOnly ?? this.designOnly,
      contextOnly: contextOnly ?? this.contextOnly,
      inactive: inactive ?? this.inactive,
      allowedFieldIds: allowedFieldIds ?? this.allowedFieldIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      safetyFlags: safetyFlags ?? this.safetyFlags,
      findings: findings ?? this.findings,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'validationRowId': validationRowId,
    'sourceRecordId': sourceRecordId,
    'sourcePacketId': sourcePacketId,
    'role': role.wire,
    'status': status.wire,
    'developerOnly': developerOnly,
    'designOnly': designOnly,
    'contextOnly': contextOnly,
    'inactive': inactive,
    'allowedFieldIds': allowedFieldIds,
    'deniedFieldIds': deniedFieldIds,
    'androidProofCaseIds': androidProofCaseIds,
    'warningReasons': warningReasons,
    'proofLimitReasons': proofLimitReasons,
    'blockedBoundaryIds': blockedBoundaryIds,
    'safetyFlags': safetyFlags,
    'findings': findings,
    'recommendation': recommendation.wire,
  };
}

class DebugOnlyBridgeDeveloperSkeletonValidationFinding {
  const DebugOnlyBridgeDeveloperSkeletonValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.validationRowId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final DebugOnlyBridgeDeveloperSkeletonValidationSeverity severity;
  final String message;
  final String? validationRowId;
  final String? fieldId;
  final String? caseId;

  bool get isCritical => severity.isCritical;

  bool get blocksStrict => severity.blocksStrict;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'severity': severity.wire,
    'message': message,
    if (validationRowId != null) 'validationRowId': validationRowId,
    if (fieldId != null) 'fieldId': fieldId,
    if (caseId != null) 'caseId': caseId,
  };
}

class DebugOnlyBridgeDeveloperSkeletonValidationResult {
  const DebugOnlyBridgeDeveloperSkeletonValidationResult({
    required this.status,
    required this.sourceSkeletonStatus,
    required this.sourceImplementationDesignStatus,
    required this.skeletonResult,
    required this.implementationDesignResult,
    required this.inputPacket,
    required this.outputPacket,
    required this.policy,
    required this.validationChecks,
    required this.validationRows,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalChecks,
    required this.passedCheckCount,
    required this.warningCheckCount,
    required this.blockerCount,
    required this.criticalCount,
    required this.totalValidationRows,
    required this.inputPacketValidationCount,
    required this.outputPacketValidationCount,
    required this.policyValidationCount,
    required this.recordValidationCount,
    required this.validCoreRecordCount,
    required this.validContextRecordCount,
    required this.validInactiveRecordCount,
    required this.validDeniedBoundaryCount,
    required this.validRuntimeBlockedCount,
    required this.invalidRecordCount,
    required this.unsafeRecordCount,
    required this.ownerProofQueueCount,
    required this.activeDeniedFieldCount,
    required this.productOutputCount,
    required this.labelLeakCount,
    required this.scoreLeakCount,
    required this.metricLeakCount,
    required this.cpLossLeakCount,
    required this.winProbabilityLeakCount,
    required this.uiTargetCount,
    required this.backendTargetCount,
    required this.persistenceWriteCount,
    required this.engineCallCount,
    required this.schedulerExecutionCount,
    required this.stockfishCommandLeakCount,
    required this.rawUciLeakCount,
    required this.pvDumpLeakCount,
    required this.unsafeCount,
    required this.safeForPhase33H,
    required this.phase33HRecommendation,
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

  final DebugOnlyBridgeDeveloperSkeletonValidationStatus status;
  final DebugOnlyBridgeSkeletonStatus sourceSkeletonStatus;
  final DebugOnlyBridgeImplementationDesignStatus
  sourceImplementationDesignStatus;
  final DebugOnlyBridgeSkeletonResult skeletonResult;
  final DebugOnlyBridgeImplementationDesignResult implementationDesignResult;
  final DebugOnlyBridgeInputPacket inputPacket;
  final DebugOnlyBridgeOutputPacket outputPacket;
  final DebugOnlyBridgePolicy policy;
  final List<DebugOnlyBridgeDeveloperSkeletonValidationCheck> validationChecks;
  final List<DebugOnlyBridgeDeveloperSkeletonValidationRow> validationRows;
  final List<DebugOnlyBridgeDeveloperSkeletonValidationFinding>
  validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalChecks;
  final int passedCheckCount;
  final int warningCheckCount;
  final int blockerCount;
  final int criticalCount;
  final int totalValidationRows;
  final int inputPacketValidationCount;
  final int outputPacketValidationCount;
  final int policyValidationCount;
  final int recordValidationCount;
  final int validCoreRecordCount;
  final int validContextRecordCount;
  final int validInactiveRecordCount;
  final int validDeniedBoundaryCount;
  final int validRuntimeBlockedCount;
  final int invalidRecordCount;
  final int unsafeRecordCount;
  final int ownerProofQueueCount;
  final int activeDeniedFieldCount;
  final int productOutputCount;
  final int labelLeakCount;
  final int scoreLeakCount;
  final int metricLeakCount;
  final int cpLossLeakCount;
  final int winProbabilityLeakCount;
  final int uiTargetCount;
  final int backendTargetCount;
  final int persistenceWriteCount;
  final int engineCallCount;
  final int schedulerExecutionCount;
  final int stockfishCommandLeakCount;
  final int rawUciLeakCount;
  final int pvDumpLeakCount;
  final int unsafeCount;
  final bool safeForPhase33H;
  final DebugOnlyBridgeDeveloperSkeletonValidationPhase33HRecommendation
  phase33HRecommendation;
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
      status ==
          DebugOnlyBridgeDeveloperSkeletonValidationStatus
              .blockedByUnsafeSkeleton ||
      status ==
          DebugOnlyBridgeDeveloperSkeletonValidationStatus
              .blockedByPolicyBoundary ||
      status == DebugOnlyBridgeDeveloperSkeletonValidationStatus.invalid ||
      unsafeCount > 0 ||
      blockerCount > 0 ||
      criticalCount > 0;

  bool get hasUnsafeDebugOnlyBridgeDeveloperSkeletonValidationPolicyViolation =>
      status ==
          DebugOnlyBridgeDeveloperSkeletonValidationStatus
              .blockedByUnsafeSkeleton ||
      status ==
          DebugOnlyBridgeDeveloperSkeletonValidationStatus
              .blockedByPolicyBoundary ||
      unsafeCount > 0 ||
      criticalCount > 0 ||
      activeDeniedFieldCount > 0 ||
      productOutputCount > 0 ||
      labelLeakCount > 0 ||
      scoreLeakCount > 0 ||
      metricLeakCount > 0 ||
      cpLossLeakCount > 0 ||
      winProbabilityLeakCount > 0 ||
      uiTargetCount > 0 ||
      backendTargetCount > 0 ||
      persistenceWriteCount > 0 ||
      engineCallCount > 0 ||
      schedulerExecutionCount > 0 ||
      stockfishCommandLeakCount > 0 ||
      rawUciLeakCount > 0 ||
      pvDumpLeakCount > 0 ||
      !developerOnly ||
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
      pvDumpFieldActive;

  DebugOnlyBridgeDeveloperSkeletonValidationRow rowForRole(
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole role,
  ) {
    return validationRows.singleWhere((row) => row.role == role);
  }

  DebugOnlyBridgeDeveloperSkeletonValidationResult copyWith({
    DebugOnlyBridgeDeveloperSkeletonValidationStatus? status,
    DebugOnlyBridgeSkeletonStatus? sourceSkeletonStatus,
    DebugOnlyBridgeImplementationDesignStatus? sourceImplementationDesignStatus,
    DebugOnlyBridgeSkeletonResult? skeletonResult,
    DebugOnlyBridgeImplementationDesignResult? implementationDesignResult,
    DebugOnlyBridgeInputPacket? inputPacket,
    DebugOnlyBridgeOutputPacket? outputPacket,
    DebugOnlyBridgePolicy? policy,
    List<DebugOnlyBridgeDeveloperSkeletonValidationCheck>? validationChecks,
    List<DebugOnlyBridgeDeveloperSkeletonValidationRow>? validationRows,
    List<DebugOnlyBridgeDeveloperSkeletonValidationFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalChecks,
    int? passedCheckCount,
    int? warningCheckCount,
    int? blockerCount,
    int? criticalCount,
    int? totalValidationRows,
    int? inputPacketValidationCount,
    int? outputPacketValidationCount,
    int? policyValidationCount,
    int? recordValidationCount,
    int? validCoreRecordCount,
    int? validContextRecordCount,
    int? validInactiveRecordCount,
    int? validDeniedBoundaryCount,
    int? validRuntimeBlockedCount,
    int? invalidRecordCount,
    int? unsafeRecordCount,
    int? ownerProofQueueCount,
    int? activeDeniedFieldCount,
    int? productOutputCount,
    int? labelLeakCount,
    int? scoreLeakCount,
    int? metricLeakCount,
    int? cpLossLeakCount,
    int? winProbabilityLeakCount,
    int? uiTargetCount,
    int? backendTargetCount,
    int? persistenceWriteCount,
    int? engineCallCount,
    int? schedulerExecutionCount,
    int? stockfishCommandLeakCount,
    int? rawUciLeakCount,
    int? pvDumpLeakCount,
    int? unsafeCount,
    bool? safeForPhase33H,
    DebugOnlyBridgeDeveloperSkeletonValidationPhase33HRecommendation?
    phase33HRecommendation,
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
    return DebugOnlyBridgeDeveloperSkeletonValidationResult(
      status: status ?? this.status,
      sourceSkeletonStatus: sourceSkeletonStatus ?? this.sourceSkeletonStatus,
      sourceImplementationDesignStatus:
          sourceImplementationDesignStatus ??
          this.sourceImplementationDesignStatus,
      skeletonResult: skeletonResult ?? this.skeletonResult,
      implementationDesignResult:
          implementationDesignResult ?? this.implementationDesignResult,
      inputPacket: inputPacket ?? this.inputPacket,
      outputPacket: outputPacket ?? this.outputPacket,
      policy: policy ?? this.policy,
      validationChecks: validationChecks ?? this.validationChecks,
      validationRows: validationRows ?? this.validationRows,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalChecks: totalChecks ?? this.totalChecks,
      passedCheckCount: passedCheckCount ?? this.passedCheckCount,
      warningCheckCount: warningCheckCount ?? this.warningCheckCount,
      blockerCount: blockerCount ?? this.blockerCount,
      criticalCount: criticalCount ?? this.criticalCount,
      totalValidationRows: totalValidationRows ?? this.totalValidationRows,
      inputPacketValidationCount:
          inputPacketValidationCount ?? this.inputPacketValidationCount,
      outputPacketValidationCount:
          outputPacketValidationCount ?? this.outputPacketValidationCount,
      policyValidationCount:
          policyValidationCount ?? this.policyValidationCount,
      recordValidationCount:
          recordValidationCount ?? this.recordValidationCount,
      validCoreRecordCount: validCoreRecordCount ?? this.validCoreRecordCount,
      validContextRecordCount:
          validContextRecordCount ?? this.validContextRecordCount,
      validInactiveRecordCount:
          validInactiveRecordCount ?? this.validInactiveRecordCount,
      validDeniedBoundaryCount:
          validDeniedBoundaryCount ?? this.validDeniedBoundaryCount,
      validRuntimeBlockedCount:
          validRuntimeBlockedCount ?? this.validRuntimeBlockedCount,
      invalidRecordCount: invalidRecordCount ?? this.invalidRecordCount,
      unsafeRecordCount: unsafeRecordCount ?? this.unsafeRecordCount,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      activeDeniedFieldCount:
          activeDeniedFieldCount ?? this.activeDeniedFieldCount,
      productOutputCount: productOutputCount ?? this.productOutputCount,
      labelLeakCount: labelLeakCount ?? this.labelLeakCount,
      scoreLeakCount: scoreLeakCount ?? this.scoreLeakCount,
      metricLeakCount: metricLeakCount ?? this.metricLeakCount,
      cpLossLeakCount: cpLossLeakCount ?? this.cpLossLeakCount,
      winProbabilityLeakCount:
          winProbabilityLeakCount ?? this.winProbabilityLeakCount,
      uiTargetCount: uiTargetCount ?? this.uiTargetCount,
      backendTargetCount: backendTargetCount ?? this.backendTargetCount,
      persistenceWriteCount:
          persistenceWriteCount ?? this.persistenceWriteCount,
      engineCallCount: engineCallCount ?? this.engineCallCount,
      schedulerExecutionCount:
          schedulerExecutionCount ?? this.schedulerExecutionCount,
      stockfishCommandLeakCount:
          stockfishCommandLeakCount ?? this.stockfishCommandLeakCount,
      rawUciLeakCount: rawUciLeakCount ?? this.rawUciLeakCount,
      pvDumpLeakCount: pvDumpLeakCount ?? this.pvDumpLeakCount,
      unsafeCount: unsafeCount ?? this.unsafeCount,
      safeForPhase33H: safeForPhase33H ?? this.safeForPhase33H,
      phase33HRecommendation:
          phase33HRecommendation ?? this.phase33HRecommendation,
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
      ..writeln('# Debug-Only Bridge Developer Skeleton Validation')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeDeveloperSkeletonValidationReportVersion',
      )
      ..writeln('- validation status: ${status.wire}')
      ..writeln('- source skeleton status: ${sourceSkeletonStatus.wire}')
      ..writeln(
        '- source implementation design status: '
        '${sourceImplementationDesignStatus.wire}',
      )
      ..writeln('- total checks: $totalChecks')
      ..writeln('- passed checks: $passedCheckCount')
      ..writeln('- warning checks: $warningCheckCount')
      ..writeln('- total validation rows: $totalValidationRows')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- product output count: $productOutputCount')
      ..writeln('- runtime enabled count: $runtimeEnabledCount')
      ..writeln('- engine call count: $engineCallCount')
      ..writeln('- ui target count: $uiTargetCount')
      ..writeln('- persistence write count: $persistenceWriteCount')
      ..writeln('- safeForPhase33H: $safeForPhase33H')
      ..writeln('- Phase 33H recommendation: ${phase33HRecommendation.wire}')
      ..writeln()
      ..writeln('## Validation Check Table')
      ..writeln('| Check | Status | Severity | Recommendation | Message |')
      ..writeln('| --- | --- | --- | --- | --- |');
    for (final check in validationChecks) {
      buffer.writeln(
        '| ${check.checkId.wire} | ${check.checkStatus.wire} | '
        '${check.severity.wire} | ${check.recommendation.wire} | '
        '${_cell(check.message)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Input Packet Validation')
      ..writeln(
        _rowSummary(
          rowForRole(
            DebugOnlyBridgeDeveloperSkeletonValidationRowRole.inputPacket,
          ),
        ),
      )
      ..writeln()
      ..writeln('## Output Packet Validation')
      ..writeln(
        _rowSummary(
          rowForRole(
            DebugOnlyBridgeDeveloperSkeletonValidationRowRole.outputPacket,
          ),
        ),
      )
      ..writeln()
      ..writeln('## Policy Validation')
      ..writeln(
        _rowSummary(
          rowForRole(DebugOnlyBridgeDeveloperSkeletonValidationRowRole.policy),
        ),
      )
      ..writeln()
      ..writeln('## Bridge Record Validation Table')
      ..writeln(
        '| Row | Role | Status | Allowed fields | Denied fields | Developer-only | Design-only | Context-only | Inactive | Findings |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in validationRows.where((row) => row.role.isRecordRole)) {
      buffer.writeln(
        '| ${row.validationRowId} | ${row.role.wire} | ${row.status.wire} | '
        '${_ids(row.allowedFieldIds)} | ${_ids(row.deniedFieldIds)} | '
        '${row.developerOnly} | ${row.designOnly} | ${row.contextOnly} | '
        '${row.inactive} | ${_ids(row.findings)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Allowed/Denied Field Boundary Validation')
      ..writeln('- allowed field IDs: ${_ids(policy.allowedFieldIds)}')
      ..writeln('- denied field IDs: ${_ids(policy.deniedFieldIds)}')
      ..writeln()
      ..writeln('## Stockfish/Raw UCI/PV Denial Validation')
      ..writeln('- stockfish command leak count: $stockfishCommandLeakCount')
      ..writeln('- raw UCI leak count: $rawUciLeakCount')
      ..writeln('- PV dump leak count: $pvDumpLeakCount')
      ..writeln()
      ..writeln('## Runtime/Prototype/Wiring Blocked Validation')
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
      ..writeln()
      ..writeln('## Android Proof Boundary')
      ..writeln('- captured proof IDs: ${_ids(policy.capturedAndroidProofIds)}')
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
          '- ${finding.severity.wire}: ${finding.id}: '
          '${_cell(finding.message)}',
        );
      }
    }
    buffer
      ..writeln()
      ..writeln('## Phase 33H Recommendation')
      ..writeln('- ${phase33HRecommendation.wire}');
    return buffer.toString();
  }

  String renderJsonReport() {
    return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'version': debugOnlyBridgeDeveloperSkeletonValidationReportVersion,
      'status': status.wire,
      'sourceSkeletonStatus': sourceSkeletonStatus.wire,
      'sourceImplementationDesignStatus': sourceImplementationDesignStatus.wire,
      'validationChecks': validationChecks
          .map((check) => check.toJson())
          .toList(),
      'validationRows': validationRows.map((row) => row.toJson()).toList(),
      'validationFindings': validationFindings
          .map((finding) => finding.toJson())
          .toList(),
      'warnings': warnings,
      'failures': failures,
      'totalChecks': totalChecks,
      'passedCheckCount': passedCheckCount,
      'warningCheckCount': warningCheckCount,
      'blockerCount': blockerCount,
      'criticalCount': criticalCount,
      'totalValidationRows': totalValidationRows,
      'inputPacketValidationCount': inputPacketValidationCount,
      'outputPacketValidationCount': outputPacketValidationCount,
      'policyValidationCount': policyValidationCount,
      'recordValidationCount': recordValidationCount,
      'validCoreRecordCount': validCoreRecordCount,
      'validContextRecordCount': validContextRecordCount,
      'validInactiveRecordCount': validInactiveRecordCount,
      'validDeniedBoundaryCount': validDeniedBoundaryCount,
      'validRuntimeBlockedCount': validRuntimeBlockedCount,
      'invalidRecordCount': invalidRecordCount,
      'unsafeRecordCount': unsafeRecordCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'activeDeniedFieldCount': activeDeniedFieldCount,
      'productOutputCount': productOutputCount,
      'labelLeakCount': labelLeakCount,
      'scoreLeakCount': scoreLeakCount,
      'metricLeakCount': metricLeakCount,
      'cpLossLeakCount': cpLossLeakCount,
      'winProbabilityLeakCount': winProbabilityLeakCount,
      'uiTargetCount': uiTargetCount,
      'backendTargetCount': backendTargetCount,
      'persistenceWriteCount': persistenceWriteCount,
      'engineCallCount': engineCallCount,
      'schedulerExecutionCount': schedulerExecutionCount,
      'stockfishCommandLeakCount': stockfishCommandLeakCount,
      'rawUciLeakCount': rawUciLeakCount,
      'pvDumpLeakCount': pvDumpLeakCount,
      'unsafeCount': unsafeCount,
      'safeForPhase33H': safeForPhase33H,
      'phase33HRecommendation': phase33HRecommendation.wire,
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

  int get runtimeEnabledCount =>
      debugBridgeRuntimeImplemented ||
          executableBridgeSkeletonImplemented ||
          executableDebugBridgePrototypeImplemented ||
          implementationWiringImplemented
      ? 1
      : 0;
}

class DebugOnlyBridgeDeveloperSkeletonValidation {
  const DebugOnlyBridgeDeveloperSkeletonValidation({
    this.validator =
        const DebugOnlyBridgeDeveloperSkeletonValidationValidator(),
  });

  final DebugOnlyBridgeDeveloperSkeletonValidationValidator validator;

  DebugOnlyBridgeDeveloperSkeletonValidationResult evaluate([
    DebugOnlyBridgeDeveloperSkeletonValidationRequest request =
        const DebugOnlyBridgeDeveloperSkeletonValidationRequest(),
  ]) {
    final implementationDesignResult =
        request.implementationDesignResult ??
        request.implementationDesign.evaluate(
          DebugOnlyBridgeImplementationDesignRequest(
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final skeletonResult =
        request.skeletonResult ??
        request.skeleton.evaluate(
          DebugOnlyBridgeSkeletonRequest(
            implementationDesignResult: implementationDesignResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final inputPacket = request.inputPacket ?? skeletonResult.inputPacket;
    final policy = request.policy ?? skeletonResult.policy;
    final outputPacket =
        request.outputPacket ??
        skeletonResult.outputPacket.copyWith(policy: policy);
    final effectiveSkeletonResult = skeletonResult.copyWith(
      inputPacket: inputPacket,
      outputPacket: outputPacket,
      policy: policy,
    );
    final rows = _validationRows(
      skeletonResult: effectiveSkeletonResult,
      inputPacket: inputPacket,
      outputPacket: outputPacket,
      policy: policy,
    );
    final checks = _validationChecks(
      skeletonResult: effectiveSkeletonResult,
      implementationDesignResult: implementationDesignResult,
      inputPacket: inputPacket,
      outputPacket: outputPacket,
      policy: policy,
      rows: rows,
    );
    final base = _resultFromValidation(
      skeletonResult: effectiveSkeletonResult,
      implementationDesignResult: implementationDesignResult,
      inputPacket: inputPacket,
      outputPacket: outputPacket,
      policy: policy,
      validationChecks: checks,
      validationRows: rows,
      validationFindings:
          const <DebugOnlyBridgeDeveloperSkeletonValidationFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromValidation(
      skeletonResult: effectiveSkeletonResult,
      implementationDesignResult: implementationDesignResult,
      inputPacket: inputPacket,
      outputPacket: outputPacket,
      policy: policy,
      validationChecks: checks,
      validationRows: rows,
      validationFindings: findings,
    );
  }
}

class DebugOnlyBridgeDeveloperSkeletonValidationValidator {
  const DebugOnlyBridgeDeveloperSkeletonValidationValidator();

  List<DebugOnlyBridgeDeveloperSkeletonValidationFinding> validate(
    DebugOnlyBridgeDeveloperSkeletonValidationResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <DebugOnlyBridgeDeveloperSkeletonValidationFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);

    void add({
      required String id,
      required DebugOnlyBridgeDeveloperSkeletonValidationSeverity severity,
      required String message,
      String? validationRowId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        DebugOnlyBridgeDeveloperSkeletonValidationFinding(
          id: id,
          severity: severity,
          message: message,
          validationRowId: validationRowId,
          fieldId: fieldId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase33H &&
        (result
                .skeletonResult
                .hasUnsafeDebugOnlyBridgeDeveloperSkeletonPolicyViolation ||
            !result.skeletonResult.safeForPhase33G ||
            result.unsafeCount > 0)) {
      add(
        id: 'unsafeSkeletonResultMarkedValid',
        severity: DebugOnlyBridgeDeveloperSkeletonValidationSeverity.critical,
        message: 'unsafe Phase 33F skeleton result cannot validate as safe',
      );
    }
    if (result.safeForPhase33H &&
        (!result.implementationDesignResult.safeForPhase33F ||
            result
                .implementationDesignResult
                .hasUnsafeDebugOnlyBridgeImplementationDesignPolicyViolation)) {
      add(
        id: 'unsafeImplementationDesignInput',
        severity: DebugOnlyBridgeDeveloperSkeletonValidationSeverity.critical,
        message: 'unsafe implementation design input cannot validate skeleton',
      );
    }
    if (result.phase33HRequirementPresentCount != 1) {
      add(
        id: 'missingPhase33HRequirement',
        severity: DebugOnlyBridgeDeveloperSkeletonValidationSeverity.critical,
        message: 'Phase 33H inspection harness requirement must be present',
      );
    }
    for (final row in result.validationRows) {
      _checkRow(add, row, provenAndroidIds);
    }
    for (final fieldId in _deniedFieldIds) {
      if (!result.policy.deniedFieldIds.contains(fieldId) ||
          !result.inputPacket.deniedFieldIds.contains(fieldId) ||
          !result.outputPacket.deniedFieldIds.contains(fieldId)) {
        add(
          id: 'deniedFieldMissing',
          severity: DebugOnlyBridgeDeveloperSkeletonValidationSeverity.blocker,
          message: '$fieldId must remain denied',
          fieldId: fieldId,
        );
      }
    }
    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: DebugOnlyBridgeDeveloperSkeletonValidationSeverity.blocker,
        message: 'owner proof requires explicit PV/MultiPV reason',
      );
    }
    if (!result.developerOnly ||
        result.debugBridgeRuntimeImplemented ||
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
        id: 'developerSkeletonValidationBoundaryPolicyViolation',
        severity: DebugOnlyBridgeDeveloperSkeletonValidationSeverity.critical,
        message: 'developer skeleton validation crossed a blocked boundary',
      );
    }
    return findings..sort(_compareFindings);
  }

  List<DebugOnlyBridgeDeveloperSkeletonValidationFinding> validateReportText(
    String reportText,
  ) {
    final findings = <DebugOnlyBridgeDeveloperSkeletonValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        DebugOnlyBridgeDeveloperSkeletonValidationFinding(
          id: id,
          severity: DebugOnlyBridgeDeveloperSkeletonValidationSeverity.critical,
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
        'report contains active runtime, executable prototype, or wiring text',
      );
    }
    return findings..sort(_compareFindings);
  }
}

extension _Phase33HRequirementCount
    on DebugOnlyBridgeDeveloperSkeletonValidationResult {
  int get phase33HRequirementPresentCount => validationRows
      .where(
        (row) =>
            row.role ==
            DebugOnlyBridgeDeveloperSkeletonValidationRowRole.futureRequirement,
      )
      .length;
}

List<DebugOnlyBridgeDeveloperSkeletonValidationRow> _validationRows({
  required DebugOnlyBridgeSkeletonResult skeletonResult,
  required DebugOnlyBridgeInputPacket inputPacket,
  required DebugOnlyBridgeOutputPacket outputPacket,
  required DebugOnlyBridgePolicy policy,
}) {
  return <DebugOnlyBridgeDeveloperSkeletonValidationRow>[
    _inputPacketRow(inputPacket),
    _outputPacketRow(outputPacket),
    _policyRow(policy),
    ...outputPacket.records.map((record) => _recordRow(record, outputPacket)),
  ];
}

DebugOnlyBridgeDeveloperSkeletonValidationRow _inputPacketRow(
  DebugOnlyBridgeInputPacket packet,
) {
  final findings = _rowFindings(
    developerOnly: true,
    designOnly: true,
    allowedFieldIds: packet.allowedFieldIds,
    safetyFlags: _safeFlags(),
  );
  return DebugOnlyBridgeDeveloperSkeletonValidationRow(
    validationRowId: 'phase33g-inputPacket',
    sourceRecordId: 'none',
    sourcePacketId: packet.inputPacketId,
    role: DebugOnlyBridgeDeveloperSkeletonValidationRowRole.inputPacket,
    status: findings.isEmpty
        ? DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validInputPacket
        : DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.unsafeRow,
    developerOnly: true,
    designOnly: true,
    contextOnly: false,
    inactive: false,
    allowedFieldIds: _sortedStrings(packet.allowedFieldIds),
    deniedFieldIds: _sortedStrings(packet.deniedFieldIds),
    androidProofCaseIds: _sortedStrings(packet.androidProofCaseIds),
    warningReasons: _sortedStrings(packet.warningReasons),
    proofLimitReasons: _sortedStrings(packet.proofLimitReasons),
    blockedBoundaryIds: _sortedStrings(packet.blockedBoundaryIds),
    safetyFlags: _safeFlags(),
    findings: findings,
    recommendation: DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
        .keepInputPacketInternal,
  );
}

DebugOnlyBridgeDeveloperSkeletonValidationRow _outputPacketRow(
  DebugOnlyBridgeOutputPacket packet,
) {
  final findings = _rowFindings(
    developerOnly: packet.developerOnly,
    designOnly: true,
    allowedFieldIds: packet.allowedFieldIds,
    safetyFlags: _safeFlags(),
  );
  return DebugOnlyBridgeDeveloperSkeletonValidationRow(
    validationRowId: 'phase33g-outputPacket',
    sourceRecordId: 'none',
    sourcePacketId: packet.outputPacketId,
    role: DebugOnlyBridgeDeveloperSkeletonValidationRowRole.outputPacket,
    status: findings.isEmpty && packet.safeForDeveloperInspection
        ? DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validOutputPacket
        : DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.unsafeRow,
    developerOnly: packet.developerOnly,
    designOnly: true,
    contextOnly: false,
    inactive: false,
    allowedFieldIds: _sortedStrings(packet.allowedFieldIds),
    deniedFieldIds: _sortedStrings(packet.deniedFieldIds),
    androidProofCaseIds: _sortedStrings(packet.androidProofCaseIds),
    warningReasons: _sortedStrings(packet.warningReasons),
    proofLimitReasons: _sortedStrings(packet.proofLimitReasons),
    blockedBoundaryIds: _sortedStrings(packet.blockedBoundaryIds),
    safetyFlags: _safeFlags(),
    findings: packet.safeForDeveloperInspection
        ? findings
        : _sortedStrings(<String>[
            ...findings,
            'outputPacketNotSafeForDeveloperInspection',
          ]),
    recommendation: DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
        .keepOutputPacketDeveloperOnly,
  );
}

DebugOnlyBridgeDeveloperSkeletonValidationRow _policyRow(
  DebugOnlyBridgePolicy policy,
) {
  final safetyFlags = _policyFlags(policy);
  final findings = _rowFindings(
    developerOnly: true,
    designOnly: true,
    allowedFieldIds: policy.allowedFieldIds,
    safetyFlags: safetyFlags,
  );
  return DebugOnlyBridgeDeveloperSkeletonValidationRow(
    validationRowId: 'phase33g-policy',
    sourceRecordId: 'none',
    sourcePacketId: 'phase33f-policy',
    role: DebugOnlyBridgeDeveloperSkeletonValidationRowRole.policy,
    status: findings.isEmpty
        ? DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validPolicy
        : DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.unsafeRow,
    developerOnly: true,
    designOnly: true,
    contextOnly: false,
    inactive: false,
    allowedFieldIds: _sortedStrings(policy.allowedFieldIds),
    deniedFieldIds: _sortedStrings(policy.deniedFieldIds),
    androidProofCaseIds: _sortedStrings(policy.capturedAndroidProofIds),
    warningReasons: const <String>[],
    proofLimitReasons: const <String>[],
    blockedBoundaryIds: _sortedStrings(policy.deniedFieldIds),
    safetyFlags: safetyFlags,
    findings: findings,
    recommendation: DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
        .keepPolicyBoundariesDenied,
  );
}

DebugOnlyBridgeDeveloperSkeletonValidationRow _recordRow(
  DebugOnlyBridgeRecord record,
  DebugOnlyBridgeOutputPacket outputPacket,
) {
  final role = _rowRoleForRecordRole(record.role);
  final findings = _recordFindings(record);
  return DebugOnlyBridgeDeveloperSkeletonValidationRow(
    validationRowId: 'phase33g-${record.role.wire}',
    sourceRecordId: record.sourceRecordId,
    sourcePacketId: outputPacket.outputPacketId,
    role: role,
    status: findings.isEmpty
        ? _validRowStatusForRole(role)
        : DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.unsafeRow,
    developerOnly: record.developerOnly,
    designOnly: record.designOnly,
    contextOnly: record.contextOnly,
    inactive: record.inactive,
    allowedFieldIds: _sortedStrings(record.allowedFieldIds),
    deniedFieldIds: _sortedStrings(record.deniedFieldIds),
    androidProofCaseIds: _sortedStrings(record.androidProofCaseIds),
    warningReasons: _sortedStrings(record.warningReasons),
    proofLimitReasons: _sortedStrings(record.proofLimitReasons),
    blockedBoundaryIds: _sortedStrings(record.blockedBoundaryIds),
    safetyFlags: record.safetyFlags,
    findings: findings,
    recommendation: _recommendationForRowRole(role),
  );
}

List<DebugOnlyBridgeDeveloperSkeletonValidationCheck> _validationChecks({
  required DebugOnlyBridgeSkeletonResult skeletonResult,
  required DebugOnlyBridgeImplementationDesignResult implementationDesignResult,
  required DebugOnlyBridgeInputPacket inputPacket,
  required DebugOnlyBridgeOutputPacket outputPacket,
  required DebugOnlyBridgePolicy policy,
  required List<DebugOnlyBridgeDeveloperSkeletonValidationRow> rows,
}) {
  DebugOnlyBridgeDeveloperSkeletonValidationCheck check({
    required DebugOnlyBridgeDeveloperSkeletonValidationCheckId id,
    required bool passed,
    String okMessage = 'passed',
    String failMessage = 'failed',
    DebugOnlyBridgeDeveloperSkeletonValidationSeverity severity =
        DebugOnlyBridgeDeveloperSkeletonValidationSeverity.critical,
    DebugOnlyBridgeDeveloperSkeletonValidationRecommendation recommendation =
        DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
            .investigateSkeletonValidationFailure,
    bool warning = false,
  }) {
    return DebugOnlyBridgeDeveloperSkeletonValidationCheck(
      checkId: id,
      checkStatus: passed
          ? warning
                ? DebugOnlyBridgeDeveloperSkeletonValidationCheckStatus
                      .passedWithWarnings
                : DebugOnlyBridgeDeveloperSkeletonValidationCheckStatus.passed
          : severity.isCritical
          ? DebugOnlyBridgeDeveloperSkeletonValidationCheckStatus.blocked
          : DebugOnlyBridgeDeveloperSkeletonValidationCheckStatus.failed,
      severity: passed
          ? warning
                ? DebugOnlyBridgeDeveloperSkeletonValidationSeverity.warning
                : DebugOnlyBridgeDeveloperSkeletonValidationSeverity.none
          : severity,
      message: passed ? okMessage : failMessage,
      recommendation: passed
          ? recommendation
          : DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
                .blockUnsafeSkeletonValidation,
    );
  }

  final core = _rowsFor(
    rows,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.core,
  );
  final context = _rowsFor(
    rows,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.context,
  );
  final inactiveRows = rows.where(
    (row) =>
        row.role ==
            DebugOnlyBridgeDeveloperSkeletonValidationRowRole.inactiveBlocked ||
        row.role ==
            DebugOnlyBridgeDeveloperSkeletonValidationRowRole.inactiveFuture,
  );
  final deniedRows = rows.where(
    (row) =>
        row.role ==
            DebugOnlyBridgeDeveloperSkeletonValidationRowRole
                .deniedFieldBoundary ||
        row.role ==
            DebugOnlyBridgeDeveloperSkeletonValidationRowRole
                .stockfishRawUciPvDumpDenied,
  );
  final reportFindings =
      const DebugOnlyBridgeDeveloperSkeletonValidationValidator()
          .validateReportText(skeletonResult.renderMarkdownReport());
  return <DebugOnlyBridgeDeveloperSkeletonValidationCheck>[
    check(
      id: DebugOnlyBridgeDeveloperSkeletonValidationCheckId
          .skeletonConsumesImplementationDesign,
      passed:
          skeletonResult.sourceImplementationDesignStatus ==
              implementationDesignResult.implementationDesignStatus &&
          skeletonResult.sourceImplementationDesignSafeForPhase33F ==
              implementationDesignResult.safeForPhase33F &&
          inputPacket.sourceImplementationDesignId ==
              debugOnlyBridgeImplementationDesignReportVersion,
      okMessage: 'skeleton consumes Phase 33E implementation design',
      failMessage: 'skeleton did not consume Phase 33E implementation design',
      recommendation: DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepInputPacketInternal,
    ),
    check(
      id: DebugOnlyBridgeDeveloperSkeletonValidationCheckId
          .inputPacketHasSafeFieldsOnly,
      passed: !inputPacket.hasUnsafeInput,
      okMessage: 'input packet allowed fields are internal-only',
      failMessage: 'input packet contains active denied fields',
      recommendation: DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepInputPacketInternal,
    ),
    check(
      id: DebugOnlyBridgeDeveloperSkeletonValidationCheckId
          .outputPacketIsDeveloperOnly,
      passed:
          outputPacket.developerOnly &&
          outputPacket.safeForDeveloperInspection &&
          !outputPacket.hasUnsafeOutput,
      okMessage: 'output packet is developer-only',
      failMessage: 'output packet crossed developer-only boundary',
      recommendation: DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepOutputPacketDeveloperOnly,
    ),
    check(
      id: DebugOnlyBridgeDeveloperSkeletonValidationCheckId
          .policyDeniesProductBoundaries,
      passed: !policy.hasUnsafeAllowance,
      okMessage: 'policy denies all product boundaries',
      failMessage: 'policy enabled blocked output boundary',
      recommendation: DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepPolicyBoundariesDenied,
    ),
    check(
      id: DebugOnlyBridgeDeveloperSkeletonValidationCheckId
          .coreRecordsRemainCore,
      passed:
          core.length == 1 &&
          core.every(
            (row) =>
                !row.contextOnly &&
                !row.inactive &&
                row.status ==
                    DebugOnlyBridgeDeveloperSkeletonValidationRowStatus
                        .validCoreRecord,
          ),
      okMessage: 'core record remains core',
      failMessage: 'core record boundary changed',
      recommendation: DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepCoreRecordCore,
    ),
    check(
      id: DebugOnlyBridgeDeveloperSkeletonValidationCheckId
          .contextRecordsRemainContextOnly,
      passed:
          context.length == 1 &&
          context.every(
            (row) =>
                row.contextOnly &&
                row.status ==
                    DebugOnlyBridgeDeveloperSkeletonValidationRowStatus
                        .validContextRecord,
          ),
      okMessage: 'context record remains context-only',
      failMessage: 'context record was promoted',
      recommendation: DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepContextRecordContextOnly,
    ),
    check(
      id: DebugOnlyBridgeDeveloperSkeletonValidationCheckId
          .inactiveRecordsRemainInactive,
      passed:
          inactiveRows.length == 2 && inactiveRows.every((row) => row.inactive),
      okMessage: 'inactive records remain inactive',
      failMessage: 'inactive record became active',
      recommendation: DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepInactiveRecordInactive,
    ),
    check(
      id: DebugOnlyBridgeDeveloperSkeletonValidationCheckId
          .deniedFieldsRemainInactive,
      passed: deniedRows.every(
        (row) => row.inactive && row.allowedFieldIds.isEmpty,
      ),
      okMessage: 'denied field boundaries remain inactive',
      failMessage: 'denied field boundary became active',
      recommendation: DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepDeniedBoundaryDenied,
    ),
    check(
      id: DebugOnlyBridgeDeveloperSkeletonValidationCheckId
          .stockfishRawUciPvDumpRemainDenied,
      passed:
          policy.deniedFieldIds.toSet().containsAll(_engineDumpFieldIds) &&
          rows.any(
            (row) =>
                row.role ==
                    DebugOnlyBridgeDeveloperSkeletonValidationRowRole
                        .stockfishRawUciPvDumpDenied &&
                row.inactive &&
                row.deniedFieldIds.toSet().containsAll(_engineDumpFieldIds),
          ),
      okMessage: 'Stockfish command, raw UCI, and PV dump remain denied',
      failMessage: 'engine dump boundary changed',
      recommendation: DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepStockfishRawUciPvDumpDenied,
    ),
    check(
      id: DebugOnlyBridgeDeveloperSkeletonValidationCheckId
          .runtimePrototypeWiringRemainBlocked,
      passed:
          !skeletonResult.debugBridgeRuntimeImplemented &&
          !skeletonResult.executableBridgeSkeletonImplemented &&
          !skeletonResult.executableDebugBridgePrototypeImplemented &&
          !skeletonResult.implementationWiringImplemented,
      okMessage: 'runtime, executable prototype, and wiring remain blocked',
      failMessage: 'runtime/prototype/wiring flag became active',
      recommendation: DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepRuntimePrototypeWiringBlocked,
    ),
    check(
      id: DebugOnlyBridgeDeveloperSkeletonValidationCheckId
          .androidProofIdsAreCapturedOnly,
      passed:
          _sameStringSet(
            inputPacket.androidProofCaseIds,
            _capturedAndroidProofIds,
          ) &&
          _sameStringSet(
            policy.capturedAndroidProofIds,
            _capturedAndroidProofIds,
          ),
      okMessage: 'Android proof IDs are captured-only',
      failMessage: 'Android proof boundary changed',
      recommendation: DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepProofBoundaryCapturedOnly,
    ),
    check(
      id: DebugOnlyBridgeDeveloperSkeletonValidationCheckId
          .phase32ECasesAreNotCapturedProof,
      passed: !<String>{
        ...inputPacket.androidProofCaseIds,
        ...outputPacket.androidProofCaseIds,
        ...policy.capturedAndroidProofIds,
      }.any(_phase32ECaseIds.contains),
      okMessage: 'Phase 32E cases are not captured proof',
      failMessage: 'Phase 32E case was treated as captured proof',
      recommendation: DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepProofBoundaryCapturedOnly,
    ),
    check(
      id: DebugOnlyBridgeDeveloperSkeletonValidationCheckId
          .ownerProofQueueRemainsEmpty,
      passed: skeletonResult.ownerProofQueueCount == 0,
      okMessage: 'owner proof queue remains empty',
      failMessage: 'owner proof queue is not empty',
      severity: DebugOnlyBridgeDeveloperSkeletonValidationSeverity.blocker,
      recommendation: DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepOwnerProofEmpty,
    ),
    check(
      id: DebugOnlyBridgeDeveloperSkeletonValidationCheckId
          .noLabelsScoresRankingsMetrics,
      passed:
          !skeletonResult.classifierOutputActive &&
          !skeletonResult.finalMoveLabelOutputActive &&
          !skeletonResult.numericOutputActive &&
          !skeletonResult.aggregateScoreOutputActive &&
          !skeletonResult.moveRankingOutputActive &&
          !skeletonResult.officialMetricOutputActive &&
          !skeletonResult.cpLossOutputActive &&
          !skeletonResult.winProbabilityOutputActive &&
          rows.every((row) => !_rowHasLabelScoreMetricLeak(row)),
      okMessage: 'labels, scores, rankings, and metrics remain absent',
      failMessage: 'label, score, ranking, or metric output became active',
    ),
    check(
      id: DebugOnlyBridgeDeveloperSkeletonValidationCheckId
          .noUiBackendPersistenceEngineFields,
      passed:
          !skeletonResult.uiTargetsActive &&
          !skeletonResult.backendOutputActive &&
          !skeletonResult.persistenceWritesActive &&
          !skeletonResult.engineCallsActive &&
          rows.every((row) => !_rowHasIntegrationLeak(row)),
      okMessage: 'UI/backend/persistence/engine fields remain absent',
      failMessage: 'integration field became active',
    ),
    check(
      id: DebugOnlyBridgeDeveloperSkeletonValidationCheckId
          .noSchedulerExecution,
      passed: rows.every((row) => !_rowHasSchedulerExecution(row)),
      okMessage: 'scheduler execution remains absent',
      failMessage: 'scheduler execution field became active',
    ),
    check(
      id: DebugOnlyBridgeDeveloperSkeletonValidationCheckId
          .noQuietPreparatoryActivation,
      passed:
          !skeletonResult.quietPreparatoryScopeActivated &&
          rows.every(
            (row) => row.safetyFlags['quietPreparatoryScopeActive'] != true,
          ),
      okMessage: 'quiet/preparatory scope remains excluded',
      failMessage: 'quiet/preparatory scope became active',
    ),
    check(
      id: DebugOnlyBridgeDeveloperSkeletonValidationCheckId
          .reportContainsNoRawUciOrPvDump,
      passed: reportFindings.isEmpty,
      okMessage: 'report text contains no raw UCI or PV dump output',
      failMessage: 'report text leaked raw UCI or PV dump output',
    ),
    check(
      id: DebugOnlyBridgeDeveloperSkeletonValidationCheckId
          .phase33HRequirementPresent,
      passed: rows.any(
        (row) =>
            row.role ==
            DebugOnlyBridgeDeveloperSkeletonValidationRowRole.futureRequirement,
      ),
      okMessage: 'Phase 33H inspection harness requirement is present',
      failMessage: 'Phase 33H inspection harness requirement is missing',
      recommendation: DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .requirePhase33HInspectionHarnessCheckpoint,
    ),
  ];
}

DebugOnlyBridgeDeveloperSkeletonValidationResult _resultFromValidation({
  required DebugOnlyBridgeSkeletonResult skeletonResult,
  required DebugOnlyBridgeImplementationDesignResult implementationDesignResult,
  required DebugOnlyBridgeInputPacket inputPacket,
  required DebugOnlyBridgeOutputPacket outputPacket,
  required DebugOnlyBridgePolicy policy,
  required List<DebugOnlyBridgeDeveloperSkeletonValidationCheck>
  validationChecks,
  required List<DebugOnlyBridgeDeveloperSkeletonValidationRow> validationRows,
  required List<DebugOnlyBridgeDeveloperSkeletonValidationFinding>
  validationFindings,
}) {
  final activeDeniedFieldCount = validationRows
      .where((row) => row.hasActiveDeniedField)
      .length;
  final productOutputCount =
      _countFlag(validationRows, 'isProductOutput') +
      (skeletonResult.productOutputActive ? 1 : 0) +
      (policy.allowProductOutput ? 1 : 0);
  final labelLeakCount =
      _countFlag(validationRows, 'isClassifierLabel') +
      (skeletonResult.classifierOutputActive ? 1 : 0) +
      (skeletonResult.finalMoveLabelOutputActive ? 1 : 0) +
      (policy.allowClassifierLabels ? 1 : 0);
  final scoreLeakCount =
      _countFlag(validationRows, 'hasNumericScore') +
      _countFlag(validationRows, 'hasAggregateScore') +
      _countFlag(validationRows, 'ranksMoves') +
      (skeletonResult.numericOutputActive ? 1 : 0) +
      (skeletonResult.aggregateScoreOutputActive ? 1 : 0) +
      (skeletonResult.moveRankingOutputActive ? 1 : 0) +
      (policy.allowNumericScores ? 1 : 0) +
      (policy.allowAggregateScores ? 1 : 0) +
      (policy.allowMoveRanking ? 1 : 0);
  final metricLeakCount =
      _countFlag(validationRows, 'isOfficialMetric') +
      (skeletonResult.officialMetricOutputActive ? 1 : 0) +
      (policy.allowOfficialMetrics ? 1 : 0);
  final cpLossLeakCount =
      _countFlag(validationRows, 'exposesCpLoss') +
      (skeletonResult.cpLossOutputActive ? 1 : 0) +
      (policy.allowCpLoss ? 1 : 0);
  final winProbabilityLeakCount =
      _countFlag(validationRows, 'exposesWinProbability') +
      (skeletonResult.winProbabilityOutputActive ? 1 : 0) +
      (policy.allowWinProbability ? 1 : 0);
  final uiTargetCount =
      _countFlag(validationRows, 'targetsUi') +
      (skeletonResult.uiTargetsActive ? 1 : 0) +
      (policy.allowUi ? 1 : 0);
  final backendTargetCount =
      _countFlag(validationRows, 'targetsBackend') +
      (skeletonResult.backendOutputActive ? 1 : 0) +
      (policy.allowBackend ? 1 : 0);
  final persistenceWriteCount =
      _countFlag(validationRows, 'writesPersistence') +
      (skeletonResult.persistenceWritesActive ? 1 : 0) +
      (policy.allowPersistence ? 1 : 0);
  final engineCallCount =
      _countFlag(validationRows, 'callsEngine') +
      (skeletonResult.engineCallsActive ? 1 : 0) +
      (policy.allowDirectEngine ? 1 : 0);
  final schedulerExecutionCount = validationRows
      .where((row) => _rowHasSchedulerExecution(row))
      .length;
  final stockfishCommandLeakCount =
      _countFlag(validationRows, 'exposesStockfishCommand') +
      (skeletonResult.stockfishCommandFieldActive ? 1 : 0) +
      (policy.allowStockfishCommand ? 1 : 0);
  final rawUciLeakCount =
      _countFlag(validationRows, 'exposesRawUci') +
      (skeletonResult.rawUciFieldActive ? 1 : 0) +
      (policy.allowRawUci ? 1 : 0);
  final pvDumpLeakCount =
      _countFlag(validationRows, 'exposesPvDump') +
      (skeletonResult.pvDumpFieldActive ? 1 : 0) +
      (policy.allowPvDump ? 1 : 0);
  final invalidRecordCount = validationRows
      .where((row) => row.status.isInvalid)
      .length;
  final unsafeRecordCount = validationRows
      .where((row) => row.hasUnsafeOutput)
      .length;
  final blockerCount =
      validationChecks.where((check) => check.blocksStrict).length +
      validationFindings.where((finding) => finding.blocksStrict).length;
  final criticalCount =
      validationChecks.where((check) => check.isCritical).length +
      validationFindings.where((finding) => finding.isCritical).length;
  final unsafeCount =
      skeletonResult.unsafeCount +
      unsafeRecordCount +
      activeDeniedFieldCount +
      productOutputCount +
      labelLeakCount +
      scoreLeakCount +
      metricLeakCount +
      cpLossLeakCount +
      winProbabilityLeakCount +
      uiTargetCount +
      backendTargetCount +
      persistenceWriteCount +
      engineCallCount +
      schedulerExecutionCount +
      stockfishCommandLeakCount +
      rawUciLeakCount +
      pvDumpLeakCount;
  final base = DebugOnlyBridgeDeveloperSkeletonValidationResult(
    status: DebugOnlyBridgeDeveloperSkeletonValidationStatus.invalid,
    sourceSkeletonStatus: skeletonResult.status,
    sourceImplementationDesignStatus:
        implementationDesignResult.implementationDesignStatus,
    skeletonResult: skeletonResult,
    implementationDesignResult: implementationDesignResult,
    inputPacket: inputPacket,
    outputPacket: outputPacket,
    policy: policy,
    validationChecks: validationChecks,
    validationRows: validationRows,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...skeletonResult.warnings,
      ...validationChecks
          .where((check) => check.checkStatus.isWarning)
          .map((check) => check.message),
      'Phase 33G validates the developer skeleton before any inspection harness',
    ]),
    failures: _sortedStrings(<String>[
      ...skeletonResult.failures,
      ...validationRows.expand((row) => row.findings),
      ...validationFindings.map((finding) => finding.message),
    ]),
    totalChecks: validationChecks.length,
    passedCheckCount: validationChecks
        .where((check) => check.checkStatus.isPassed)
        .length,
    warningCheckCount: validationChecks
        .where((check) => check.checkStatus.isWarning)
        .length,
    blockerCount: blockerCount,
    criticalCount: criticalCount,
    totalValidationRows: validationRows.length,
    inputPacketValidationCount: _countRole(
      validationRows,
      DebugOnlyBridgeDeveloperSkeletonValidationRowRole.inputPacket,
    ),
    outputPacketValidationCount: _countRole(
      validationRows,
      DebugOnlyBridgeDeveloperSkeletonValidationRowRole.outputPacket,
    ),
    policyValidationCount: _countRole(
      validationRows,
      DebugOnlyBridgeDeveloperSkeletonValidationRowRole.policy,
    ),
    recordValidationCount: validationRows
        .where((row) => row.role.isRecordRole)
        .length,
    validCoreRecordCount: _countStatus(
      validationRows,
      DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validCoreRecord,
    ),
    validContextRecordCount: _countStatus(
      validationRows,
      DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validContextRecord,
    ),
    validInactiveRecordCount: _countStatus(
      validationRows,
      DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validInactiveRecord,
    ),
    validDeniedBoundaryCount: _countStatus(
      validationRows,
      DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validDeniedBoundary,
    ),
    validRuntimeBlockedCount: _countStatus(
      validationRows,
      DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validRuntimeBlocked,
    ),
    invalidRecordCount: invalidRecordCount,
    unsafeRecordCount: unsafeRecordCount,
    ownerProofQueueCount: skeletonResult.ownerProofQueueCount,
    activeDeniedFieldCount: activeDeniedFieldCount,
    productOutputCount: productOutputCount,
    labelLeakCount: labelLeakCount,
    scoreLeakCount: scoreLeakCount,
    metricLeakCount: metricLeakCount,
    cpLossLeakCount: cpLossLeakCount,
    winProbabilityLeakCount: winProbabilityLeakCount,
    uiTargetCount: uiTargetCount,
    backendTargetCount: backendTargetCount,
    persistenceWriteCount: persistenceWriteCount,
    engineCallCount: engineCallCount,
    schedulerExecutionCount: schedulerExecutionCount,
    stockfishCommandLeakCount: stockfishCommandLeakCount,
    rawUciLeakCount: rawUciLeakCount,
    pvDumpLeakCount: pvDumpLeakCount,
    unsafeCount: unsafeCount,
    safeForPhase33H: false,
    phase33HRecommendation:
        DebugOnlyBridgeDeveloperSkeletonValidationPhase33HRecommendation
            .addMoreGoldenCoverageFirst,
    developerOnly: skeletonResult.developerOnly,
    debugBridgeRuntimeImplemented: skeletonResult.debugBridgeRuntimeImplemented,
    executableBridgeSkeletonImplemented:
        skeletonResult.executableBridgeSkeletonImplemented,
    executableDebugBridgePrototypeImplemented:
        skeletonResult.executableDebugBridgePrototypeImplemented,
    implementationWiringImplemented:
        skeletonResult.implementationWiringImplemented,
    productOutputActive: skeletonResult.productOutputActive,
    classifierOutputActive: skeletonResult.classifierOutputActive,
    finalMoveLabelOutputActive: skeletonResult.finalMoveLabelOutputActive,
    officialMetricOutputActive: skeletonResult.officialMetricOutputActive,
    cpLossOutputActive: skeletonResult.cpLossOutputActive,
    winProbabilityOutputActive: skeletonResult.winProbabilityOutputActive,
    numericOutputActive: skeletonResult.numericOutputActive,
    aggregateScoreOutputActive: skeletonResult.aggregateScoreOutputActive,
    moveRankingOutputActive: skeletonResult.moveRankingOutputActive,
    quietPreparatoryScopeActivated:
        skeletonResult.quietPreparatoryScopeActivated,
    engineCallsActive: skeletonResult.engineCallsActive,
    persistenceWritesActive: skeletonResult.persistenceWritesActive,
    uiTargetsActive: skeletonResult.uiTargetsActive,
    backendOutputActive: skeletonResult.backendOutputActive,
    stockfishCommandFieldActive: skeletonResult.stockfishCommandFieldActive,
    rawUciFieldActive: skeletonResult.rawUciFieldActive,
    pvDumpFieldActive: skeletonResult.pvDumpFieldActive,
  );
  final status = _validationStatusFor(base);
  final safeForPhase33H =
      (status ==
              DebugOnlyBridgeDeveloperSkeletonValidationStatus
                  .skeletonValidatedWithWarnings ||
          status ==
              DebugOnlyBridgeDeveloperSkeletonValidationStatus
                  .skeletonValidatedClean) &&
      skeletonResult.safeForPhase33G &&
      !skeletonResult
          .hasUnsafeDebugOnlyBridgeDeveloperSkeletonPolicyViolation &&
      implementationDesignResult.safeForPhase33F &&
      !implementationDesignResult
          .hasUnsafeDebugOnlyBridgeImplementationDesignPolicyViolation &&
      unsafeCount == 0 &&
      blockerCount == 0 &&
      criticalCount == 0 &&
      validationRows.every((row) => !row.hasUnsafeOutput);
  return base.copyWith(
    status: status,
    safeForPhase33H: safeForPhase33H,
    phase33HRecommendation: _phase33HRecommendationFor(
      status: status,
      safeForPhase33H: safeForPhase33H,
      ownerProofQueueCount: skeletonResult.ownerProofQueueCount,
    ),
  );
}

DebugOnlyBridgeDeveloperSkeletonValidationStatus _validationStatusFor(
  DebugOnlyBridgeDeveloperSkeletonValidationResult result,
) {
  if (result.productOutputCount > 0 ||
      result.labelLeakCount > 0 ||
      result.scoreLeakCount > 0 ||
      result.metricLeakCount > 0 ||
      result.cpLossLeakCount > 0 ||
      result.winProbabilityLeakCount > 0 ||
      result.uiTargetCount > 0 ||
      result.backendTargetCount > 0 ||
      result.persistenceWriteCount > 0 ||
      result.engineCallCount > 0 ||
      result.schedulerExecutionCount > 0 ||
      result.stockfishCommandLeakCount > 0 ||
      result.rawUciLeakCount > 0 ||
      result.pvDumpLeakCount > 0 ||
      result.debugBridgeRuntimeImplemented ||
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
    return DebugOnlyBridgeDeveloperSkeletonValidationStatus
        .blockedByPolicyBoundary;
  }
  if (result
          .skeletonResult
          .hasUnsafeDebugOnlyBridgeDeveloperSkeletonPolicyViolation ||
      result.sourceSkeletonStatus ==
          DebugOnlyBridgeSkeletonStatus.blockedByUnsafeImplementationDesign ||
      result.sourceSkeletonStatus ==
          DebugOnlyBridgeSkeletonStatus.blockedByPolicyBoundary ||
      result.unsafeCount > 0 ||
      result.criticalCount > 0) {
    return DebugOnlyBridgeDeveloperSkeletonValidationStatus
        .blockedByUnsafeSkeleton;
  }
  if (result.blockerCount > 0 ||
      result.totalChecks == 0 ||
      result.totalValidationRows == 0 ||
      result.invalidRecordCount > 0) {
    return DebugOnlyBridgeDeveloperSkeletonValidationStatus.invalid;
  }
  if (result.warningCheckCount > 0 || result.warnings.isNotEmpty) {
    return DebugOnlyBridgeDeveloperSkeletonValidationStatus
        .skeletonValidatedWithWarnings;
  }
  return DebugOnlyBridgeDeveloperSkeletonValidationStatus
      .skeletonValidatedClean;
}

DebugOnlyBridgeDeveloperSkeletonValidationPhase33HRecommendation
_phase33HRecommendationFor({
  required DebugOnlyBridgeDeveloperSkeletonValidationStatus status,
  required bool safeForPhase33H,
  required int ownerProofQueueCount,
}) {
  if (status ==
          DebugOnlyBridgeDeveloperSkeletonValidationStatus
              .blockedByUnsafeSkeleton ||
      status ==
          DebugOnlyBridgeDeveloperSkeletonValidationStatus
              .blockedByPolicyBoundary) {
    return DebugOnlyBridgeDeveloperSkeletonValidationPhase33HRecommendation
        .blockedByUnsafeSkeletonValidation;
  }
  if (ownerProofQueueCount > 0) {
    return DebugOnlyBridgeDeveloperSkeletonValidationPhase33HRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase33H) {
    return DebugOnlyBridgeDeveloperSkeletonValidationPhase33HRecommendation
        .proceedToSkeletonHardening;
  }
  return DebugOnlyBridgeDeveloperSkeletonValidationPhase33HRecommendation
      .proceedToDebugOnlyBridgeDeveloperInspectionHarness;
}

void _checkRow(
  void Function({
    required String id,
    required DebugOnlyBridgeDeveloperSkeletonValidationSeverity severity,
    required String message,
    String? validationRowId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugOnlyBridgeDeveloperSkeletonValidationRow row,
  List<String> provenAndroidIds,
) {
  if (!row.developerOnly || !row.designOnly) {
    add(
      id: 'rowNotDeveloperOnly',
      severity: DebugOnlyBridgeDeveloperSkeletonValidationSeverity.critical,
      message: 'validation rows must stay developer-only and design-only',
      validationRowId: row.validationRowId,
    );
  }
  for (final fieldId in row.allowedFieldIds) {
    if (_isDeniedFieldId(fieldId) || _isLegacyDeniedFieldId(fieldId)) {
      add(
        id: 'activeDeniedField',
        severity: DebugOnlyBridgeDeveloperSkeletonValidationSeverity.critical,
        message: '$fieldId cannot be active skeleton validation output',
        validationRowId: row.validationRowId,
        fieldId: fieldId,
      );
    }
  }
  for (final caseId in row.androidProofCaseIds) {
    if (_phase32ECaseIds.contains(caseId)) {
      add(
        id: 'phase32ECaseTreatedAsCapturedProof',
        severity: DebugOnlyBridgeDeveloperSkeletonValidationSeverity.critical,
        message: '$caseId cannot be treated as captured Android proof',
        validationRowId: row.validationRowId,
        caseId: caseId,
      );
      continue;
    }
    if (!_capturedAndroidProofIds.contains(caseId) ||
        !provenAndroidIds.contains(caseId)) {
      add(
        id: 'unprovenAndroidProofId',
        severity: DebugOnlyBridgeDeveloperSkeletonValidationSeverity.critical,
        message: '$caseId is not captured Android proof',
        validationRowId: row.validationRowId,
        caseId: caseId,
      );
    }
  }
  if (row.role == DebugOnlyBridgeDeveloperSkeletonValidationRowRole.core &&
      (row.contextOnly || row.inactive)) {
    add(
      id: 'coreRecordSourcedFromNonCoreInput',
      severity: DebugOnlyBridgeDeveloperSkeletonValidationSeverity.critical,
      message: 'core record cannot be context-only or inactive',
      validationRowId: row.validationRowId,
    );
  }
  if (row.role == DebugOnlyBridgeDeveloperSkeletonValidationRowRole.context &&
      !row.contextOnly) {
    add(
      id: 'contextRecordPromotedToCore',
      severity: DebugOnlyBridgeDeveloperSkeletonValidationSeverity.critical,
      message: 'context record must remain context-only',
      validationRowId: row.validationRowId,
    );
  }
  if ((row.role ==
              DebugOnlyBridgeDeveloperSkeletonValidationRowRole
                  .inactiveBlocked ||
          row.role ==
              DebugOnlyBridgeDeveloperSkeletonValidationRowRole
                  .inactiveFuture ||
          row.role ==
              DebugOnlyBridgeDeveloperSkeletonValidationRowRole
                  .deniedFieldBoundary ||
          row.role ==
              DebugOnlyBridgeDeveloperSkeletonValidationRowRole
                  .stockfishRawUciPvDumpDenied ||
          row.role ==
              DebugOnlyBridgeDeveloperSkeletonValidationRowRole
                  .runtimeBlocked) &&
      (!row.inactive || row.allowedFieldIds.isNotEmpty)) {
    add(
      id: 'inactiveRecordMadeActive',
      severity: DebugOnlyBridgeDeveloperSkeletonValidationSeverity.critical,
      message: 'inactive and denied rows must stay inactive',
      validationRowId: row.validationRowId,
    );
  }
  for (final finding in row.findings) {
    add(
      id: finding,
      severity: DebugOnlyBridgeDeveloperSkeletonValidationSeverity.critical,
      message: finding,
      validationRowId: row.validationRowId,
    );
  }
}

List<String> _recordFindings(DebugOnlyBridgeRecord record) {
  final findings = _rowFindings(
    developerOnly: record.developerOnly,
    designOnly: record.designOnly,
    allowedFieldIds: record.allowedFieldIds,
    safetyFlags: record.safetyFlags,
  );
  if (record.role == DebugOnlyBridgeRecordRole.core &&
      (record.contextOnly ||
          record.inactive ||
          record.sourceImplementationComponentRole !=
              DebugOnlyBridgeImplementationDesignComponentRole
                  .bridgeCoreRecord)) {
    findings.add('coreRecordSourcedFromNonCoreInput');
  }
  if (record.role == DebugOnlyBridgeRecordRole.context &&
      (!record.contextOnly ||
          record.sourceImplementationComponentRole !=
              DebugOnlyBridgeImplementationDesignComponentRole
                  .bridgeContextRecord)) {
    findings.add('contextRecordPromotedToCore');
  }
  if (record.role.isInactiveBoundary &&
      (!record.inactive || record.allowedFieldIds.isNotEmpty)) {
    findings.add('inactiveRecordMadeActive');
  }
  return _sortedStrings(findings);
}

List<String> _rowFindings({
  required bool developerOnly,
  required bool designOnly,
  required Iterable<String> allowedFieldIds,
  required Map<String, bool> safetyFlags,
}) {
  final findings = <String>[];
  if (!developerOnly) findings.add('notDeveloperOnly');
  if (!designOnly) findings.add('notDesignOnly');
  for (final fieldId in allowedFieldIds) {
    if (_isDeniedFieldId(fieldId) || _isLegacyDeniedFieldId(fieldId)) {
      findings.add('activeDeniedField');
    }
  }
  for (final entry in safetyFlags.entries) {
    if (entry.value) findings.add('${entry.key}Active');
  }
  return _sortedStrings(findings);
}

DebugOnlyBridgeDeveloperSkeletonValidationRowRole _rowRoleForRecordRole(
  DebugOnlyBridgeRecordRole role,
) {
  return switch (role) {
    DebugOnlyBridgeRecordRole.core =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowRole.core,
    DebugOnlyBridgeRecordRole.context =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowRole.context,
    DebugOnlyBridgeRecordRole.inactiveBlocked =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowRole.inactiveBlocked,
    DebugOnlyBridgeRecordRole.inactiveFuture =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowRole.inactiveFuture,
    DebugOnlyBridgeRecordRole.allowedFieldBoundary =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowRole.allowedFieldBoundary,
    DebugOnlyBridgeRecordRole.deniedFieldBoundary =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowRole.deniedFieldBoundary,
    DebugOnlyBridgeRecordRole.stockfishRawUciPvDumpDenied =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowRole
          .stockfishRawUciPvDumpDenied,
    DebugOnlyBridgeRecordRole.runtimeBlocked =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowRole.runtimeBlocked,
    DebugOnlyBridgeRecordRole.proofBoundary =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowRole.proofBoundary,
    DebugOnlyBridgeRecordRole.ownerProofBoundary =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowRole.ownerProofBoundary,
    DebugOnlyBridgeRecordRole.futureRequirement =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowRole.futureRequirement,
  };
}

DebugOnlyBridgeDeveloperSkeletonValidationRowStatus _validRowStatusForRole(
  DebugOnlyBridgeDeveloperSkeletonValidationRowRole role,
) {
  return switch (role) {
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.inputPacket =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validInputPacket,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.outputPacket =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validOutputPacket,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.policy =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validPolicy,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.core =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validCoreRecord,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.context =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validContextRecord,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.inactiveBlocked ||
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.inactiveFuture =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validInactiveRecord,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.allowedFieldBoundary =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowStatus
          .validAllowedFieldBoundary,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.deniedFieldBoundary ||
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole
        .stockfishRawUciPvDumpDenied =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validDeniedBoundary,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.runtimeBlocked =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validRuntimeBlocked,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.proofBoundary =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validProofBoundary,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.ownerProofBoundary =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowStatus
          .validOwnerProofBoundary,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.futureRequirement =>
      DebugOnlyBridgeDeveloperSkeletonValidationRowStatus
          .validFutureRequirement,
  };
}

DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
_recommendationForRowRole(
  DebugOnlyBridgeDeveloperSkeletonValidationRowRole role,
) {
  return switch (role) {
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.inputPacket =>
      DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepInputPacketInternal,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.outputPacket =>
      DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepOutputPacketDeveloperOnly,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.policy =>
      DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepPolicyBoundariesDenied,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.core =>
      DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepCoreRecordCore,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.context =>
      DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepContextRecordContextOnly,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.inactiveBlocked ||
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.inactiveFuture =>
      DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepInactiveRecordInactive,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.allowedFieldBoundary =>
      DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepAllowedFieldBoundaryInternal,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.deniedFieldBoundary =>
      DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepDeniedBoundaryDenied,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole
        .stockfishRawUciPvDumpDenied =>
      DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepStockfishRawUciPvDumpDenied,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.runtimeBlocked =>
      DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepRuntimePrototypeWiringBlocked,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.proofBoundary =>
      DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepProofBoundaryCapturedOnly,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.ownerProofBoundary =>
      DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .keepOwnerProofEmpty,
    DebugOnlyBridgeDeveloperSkeletonValidationRowRole.futureRequirement =>
      DebugOnlyBridgeDeveloperSkeletonValidationRecommendation
          .requirePhase33HInspectionHarnessCheckpoint,
  };
}

Map<String, bool> _policyFlags(DebugOnlyBridgePolicy policy) {
  return <String, bool>{
    'isProductOutput': policy.allowProductOutput,
    'isClassifierLabel': policy.allowClassifierLabels,
    'hasNumericScore': policy.allowNumericScores,
    'hasAggregateScore': policy.allowAggregateScores,
    'ranksMoves': policy.allowMoveRanking,
    'isOfficialMetric': policy.allowOfficialMetrics,
    'exposesCpLoss': policy.allowCpLoss,
    'exposesWinProbability': policy.allowWinProbability,
    'exposesStockfishCommand': policy.allowStockfishCommand,
    'exposesRawUci': policy.allowRawUci,
    'exposesPvDump': policy.allowPvDump,
    'callsEngine': policy.allowDirectEngine,
    'writesPersistence': policy.allowPersistence,
    'targetsUi': policy.allowUi,
    'targetsBackend': policy.allowBackend,
    'implementsRuntime': policy.allowRuntime,
    'implementsExecutablePrototype': policy.allowExecutablePrototype,
    'implementsWiring': policy.allowWiring,
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
    'targetsBackend': false,
    'implementsRuntime': false,
    'implementsExecutablePrototype': false,
    'implementsWiring': false,
  };
}

bool _rowHasLabelScoreMetricLeak(
  DebugOnlyBridgeDeveloperSkeletonValidationRow row,
) {
  return row.safetyFlags['isClassifierLabel'] == true ||
      row.safetyFlags['hasNumericScore'] == true ||
      row.safetyFlags['hasAggregateScore'] == true ||
      row.safetyFlags['ranksMoves'] == true ||
      row.safetyFlags['isOfficialMetric'] == true ||
      row.safetyFlags['exposesCpLoss'] == true ||
      row.safetyFlags['exposesWinProbability'] == true;
}

bool _rowHasIntegrationLeak(DebugOnlyBridgeDeveloperSkeletonValidationRow row) {
  return row.safetyFlags['targetsUi'] == true ||
      row.safetyFlags['targetsBackend'] == true ||
      row.safetyFlags['writesPersistence'] == true ||
      row.safetyFlags['callsEngine'] == true;
}

bool _rowHasSchedulerExecution(
  DebugOnlyBridgeDeveloperSkeletonValidationRow row,
) {
  return row.allowedFieldIds.contains('schedulerExecution') ||
      row.safetyFlags['callsScheduler'] == true;
}

bool _hasExplicitPvProofReason(
  DebugOnlyBridgeDeveloperSkeletonValidationResult result,
) {
  final reasons = <String>[
    ...result.warnings,
    ...result.failures,
    ...result.validationRows.expand((row) => row.proofLimitReasons),
  ].join(' ').toLowerCase();
  return reasons.contains('pv') || reasons.contains('multipv');
}

List<DebugOnlyBridgeDeveloperSkeletonValidationRow> _rowsFor(
  Iterable<DebugOnlyBridgeDeveloperSkeletonValidationRow> rows,
  DebugOnlyBridgeDeveloperSkeletonValidationRowRole role,
) {
  return rows.where((row) => row.role == role).toList(growable: false);
}

int _countRole(
  Iterable<DebugOnlyBridgeDeveloperSkeletonValidationRow> rows,
  DebugOnlyBridgeDeveloperSkeletonValidationRowRole role,
) {
  return rows.where((row) => row.role == role).length;
}

int _countStatus(
  Iterable<DebugOnlyBridgeDeveloperSkeletonValidationRow> rows,
  DebugOnlyBridgeDeveloperSkeletonValidationRowStatus status,
) {
  return rows.where((row) => row.status == status).length;
}

int _countFlag(
  Iterable<DebugOnlyBridgeDeveloperSkeletonValidationRow> rows,
  String flag,
) {
  return rows.where((row) => row.safetyFlags[flag] == true).length;
}

List<String> _provenAndroidProofIds(GoldenAndroidProofEvidence? evidence) {
  return _sortedStrings(evidence?.targetCaseIds ?? const <String>[]);
}

int _compareFindings(
  DebugOnlyBridgeDeveloperSkeletonValidationFinding a,
  DebugOnlyBridgeDeveloperSkeletonValidationFinding b,
) {
  final severity = _severityRank(
    b.severity,
  ).compareTo(_severityRank(a.severity));
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.validationRowId ?? '').compareTo(b.validationRowId ?? '');
}

int _severityRank(DebugOnlyBridgeDeveloperSkeletonValidationSeverity severity) {
  return switch (severity) {
    DebugOnlyBridgeDeveloperSkeletonValidationSeverity.none => 0,
    DebugOnlyBridgeDeveloperSkeletonValidationSeverity.warning => 1,
    DebugOnlyBridgeDeveloperSkeletonValidationSeverity.blocker => 2,
    DebugOnlyBridgeDeveloperSkeletonValidationSeverity.critical => 3,
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

String _rowSummary(DebugOnlyBridgeDeveloperSkeletonValidationRow row) {
  return '- row: ${row.validationRowId}; status: ${row.status.wire}; '
      'allowed field IDs: ${_ids(row.allowedFieldIds)}; '
      'denied field IDs: ${_ids(row.deniedFieldIds)}; '
      'findings: ${_ids(row.findings)}';
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
  'schedulerExecution',
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

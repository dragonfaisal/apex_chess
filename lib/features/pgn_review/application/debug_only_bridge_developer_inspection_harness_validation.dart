/// Developer-only validation for the debug-only bridge inspection harness.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_inspection_harness.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_skeleton.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_skeleton_validation.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugOnlyBridgeDeveloperInspectionHarnessValidationReportVersion =
    'debug-only-bridge-developer-inspection-harness-validation-v1';

enum DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus {
  inspectionHarnessValidatedWithWarnings(
    'inspectionHarnessValidatedWithWarnings',
  ),
  inspectionHarnessValidatedClean('inspectionHarnessValidatedClean'),
  blockedByUnsafeInspectionHarness('blockedByUnsafeInspectionHarness'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus(this.wire);

  final String wire;
}

enum DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId {
  harnessConsumesSafeSkeletonValidation(
    'harnessConsumesSafeSkeletonValidation',
  ),
  harnessConsumesSafeSkeletonResult('harnessConsumesSafeSkeletonResult'),
  snapshotIsDeveloperOnly('snapshotIsDeveloperOnly'),
  snapshotHasSafeFieldsOnly('snapshotHasSafeFieldsOnly'),
  inputPacketInspectionIsSafe('inputPacketInspectionIsSafe'),
  outputPacketInspectionIsSafe('outputPacketInspectionIsSafe'),
  policyInspectionIsSafe('policyInspectionIsSafe'),
  recordInspectionsPreserveRoles('recordInspectionsPreserveRoles'),
  deniedFieldsRemainInactive('deniedFieldsRemainInactive'),
  stockfishRawUciPvDumpRemainDenied('stockfishRawUciPvDumpRemainDenied'),
  runtimePrototypeWiringRemainBlocked('runtimePrototypeWiringRemainBlocked'),
  schedulerExecutionRemainsDenied('schedulerExecutionRemainsDenied'),
  androidProofIdsAreCapturedOnly('androidProofIdsAreCapturedOnly'),
  phase32ECasesAreNotCapturedProof('phase32ECasesAreNotCapturedProof'),
  ownerProofQueueRemainsEmpty('ownerProofQueueRemainsEmpty'),
  noLabelsScoresRankingsMetrics('noLabelsScoresRankingsMetrics'),
  noUiBackendPersistenceEngineFields('noUiBackendPersistenceEngineFields'),
  noQuietPreparatoryActivation('noQuietPreparatoryActivation'),
  reportContainsNoRawUciOrPvDump('reportContainsNoRawUciOrPvDump'),
  phase33JRequirementPresent('phase33JRequirementPresent');

  const DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId(this.wire);

  final String wire;
}

enum DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckStatus {
  passed('passed'),
  passedWithWarnings('passedWithWarnings'),
  failed('failed'),
  blocked('blocked');

  const DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckStatus(
    this.wire,
  );

  final String wire;

  bool get isPassed => this == passed || this == passedWithWarnings;

  bool get isWarning => this == passedWithWarnings;
}

enum DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity {
  none('none'),
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict => this == blocker || this == critical;

  bool get isCritical => this == critical;
}

enum DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole {
  snapshotValidation('snapshotValidation'),
  inputPacketInspectionValidation('inputPacketInspectionValidation'),
  outputPacketInspectionValidation('outputPacketInspectionValidation'),
  policyInspectionValidation('policyInspectionValidation'),
  coreRecordInspectionValidation('coreRecordInspectionValidation'),
  contextRecordInspectionValidation('contextRecordInspectionValidation'),
  inactiveRecordInspectionValidation('inactiveRecordInspectionValidation'),
  allowedFieldBoundaryInspectionValidation(
    'allowedFieldBoundaryInspectionValidation',
  ),
  deniedFieldBoundaryInspectionValidation(
    'deniedFieldBoundaryInspectionValidation',
  ),
  stockfishRawUciPvDumpDeniedInspectionValidation(
    'stockfishRawUciPvDumpDeniedInspectionValidation',
  ),
  runtimeBlockedInspectionValidation('runtimeBlockedInspectionValidation'),
  proofBoundaryInspectionValidation('proofBoundaryInspectionValidation'),
  ownerProofBoundaryInspectionValidation(
    'ownerProofBoundaryInspectionValidation',
  ),
  futureRequirementInspectionValidation(
    'futureRequirementInspectionValidation',
  );

  const DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole(this.wire);

  final String wire;

  bool get isRecordValidation =>
      this != snapshotValidation &&
      this != inputPacketInspectionValidation &&
      this != outputPacketInspectionValidation &&
      this != policyInspectionValidation;
}

enum DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus {
  validSnapshot('validSnapshot'),
  validInputPacketInspection('validInputPacketInspection'),
  validOutputPacketInspection('validOutputPacketInspection'),
  validPolicyInspection('validPolicyInspection'),
  validCoreInspection('validCoreInspection'),
  validContextInspection('validContextInspection'),
  validInactiveInspection('validInactiveInspection'),
  validAllowedFieldBoundaryInspection('validAllowedFieldBoundaryInspection'),
  validDeniedBoundaryInspection('validDeniedBoundaryInspection'),
  validRuntimeBlockedInspection('validRuntimeBlockedInspection'),
  validProofBoundaryInspection('validProofBoundaryInspection'),
  validOwnerProofBoundaryInspection('validOwnerProofBoundaryInspection'),
  validFutureRequirementInspection('validFutureRequirementInspection'),
  unsafeRow('unsafeRow'),
  invalidRow('invalidRow');

  const DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == unsafeRow;

  bool get isInvalid => this == invalidRow;
}

enum DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation {
  keepSnapshotDeveloperOnly('keepSnapshotDeveloperOnly'),
  keepInputPacketInspectionSafe('keepInputPacketInspectionSafe'),
  keepOutputPacketInspectionSafe('keepOutputPacketInspectionSafe'),
  keepPolicyInspectionSafe('keepPolicyInspectionSafe'),
  keepCoreInspectionCore('keepCoreInspectionCore'),
  keepContextInspectionContextOnly('keepContextInspectionContextOnly'),
  keepInactiveInspectionInactive('keepInactiveInspectionInactive'),
  keepAllowedFieldBoundaryInternal('keepAllowedFieldBoundaryInternal'),
  keepDeniedBoundaryDenied('keepDeniedBoundaryDenied'),
  keepStockfishRawUciPvDumpDenied('keepStockfishRawUciPvDumpDenied'),
  keepRuntimePrototypeWiringBlocked('keepRuntimePrototypeWiringBlocked'),
  keepProofBoundaryCapturedOnly('keepProofBoundaryCapturedOnly'),
  keepOwnerProofEmpty('keepOwnerProofEmpty'),
  requirePhase33JDiagnosticCommand('requirePhase33JDiagnosticCommand'),
  investigateInspectionHarnessValidationFailure(
    'investigateInspectionHarnessValidationFailure',
  ),
  blockUnsafeInspectionHarnessValidation(
    'blockUnsafeInspectionHarnessValidation',
  );

  const DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeDeveloperInspectionHarnessValidationPhase33JRecommendation {
  proceedToDebugOnlyBridgeDeveloperDiagnosticCommand(
    'proceedToDebugOnlyBridgeDeveloperDiagnosticCommand',
  ),
  proceedToSelectedGoldenInspectionRun('proceedToSelectedGoldenInspectionRun'),
  proceedToInspectionHarnessValidationReportOnly(
    'proceedToInspectionHarnessValidationReportOnly',
  ),
  proceedToInspectionHarnessHardening('proceedToInspectionHarnessHardening'),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeInspectionHarnessValidation(
    'blockedByUnsafeInspectionHarnessValidation',
  );

  const DebugOnlyBridgeDeveloperInspectionHarnessValidationPhase33JRecommendation(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeDeveloperInspectionHarnessValidationReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeDeveloperInspectionHarnessValidationReportFormat(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeDeveloperInspectionHarnessValidationRequest {
  const DebugOnlyBridgeDeveloperInspectionHarnessValidationRequest({
    this.inspectionHarnessResult,
    this.snapshot,
    this.skeletonValidationResult,
    this.skeletonResult,
    this.inputPacket,
    this.outputPacket,
    this.policy,
    this.inspectionHarness = const DebugOnlyBridgeDeveloperInspectionHarness(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const DebugOnlyBridgeDeveloperInspectionHarnessValidationRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final DebugOnlyBridgeDeveloperInspectionHarnessResult?
  inspectionHarnessResult;
  final DebugOnlyBridgeDeveloperInspectionSnapshot? snapshot;
  final DebugOnlyBridgeDeveloperSkeletonValidationResult?
  skeletonValidationResult;
  final DebugOnlyBridgeSkeletonResult? skeletonResult;
  final DebugOnlyBridgeInputPacket? inputPacket;
  final DebugOnlyBridgeOutputPacket? outputPacket;
  final DebugOnlyBridgePolicy? policy;
  final DebugOnlyBridgeDeveloperInspectionHarness inspectionHarness;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class DebugOnlyBridgeDeveloperInspectionHarnessValidationCheck {
  const DebugOnlyBridgeDeveloperInspectionHarnessValidationCheck({
    required this.checkId,
    required this.checkStatus,
    required this.severity,
    required this.message,
    required this.recommendation,
  });

  final DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId checkId;
  final DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckStatus
  checkStatus;
  final DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity severity;
  final String message;
  final DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
  recommendation;

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

class DebugOnlyBridgeDeveloperInspectionHarnessValidationRow {
  const DebugOnlyBridgeDeveloperInspectionHarnessValidationRow({
    required this.validationRowId,
    required this.sourceInspectionRowId,
    required this.sourceSnapshotId,
    required this.sourceRecordId,
    required this.sourcePacketId,
    required this.role,
    required this.status,
    required this.developerOnly,
    required this.skeletonOnly,
    required this.contextOnly,
    required this.inactive,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.androidProofCaseIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.futurePrerequisites,
    required this.blockedBoundaryIds,
    required this.findings,
    required this.recommendation,
  });

  final String validationRowId;
  final String sourceInspectionRowId;
  final String sourceSnapshotId;
  final String sourceRecordId;
  final String sourcePacketId;
  final DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole role;
  final DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus status;
  final bool developerOnly;
  final bool skeletonOnly;
  final bool contextOnly;
  final bool inactive;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final List<String> androidProofCaseIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> futurePrerequisites;
  final List<String> blockedBoundaryIds;
  final List<String> findings;
  final DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
  recommendation;

  bool get hasActiveDeniedField =>
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId);

  bool get hasUnsafeOutput =>
      status.isUnsafe ||
      !developerOnly ||
      !skeletonOnly ||
      hasActiveDeniedField ||
      findings.any((finding) => finding.startsWith('unsafe:'));

  DebugOnlyBridgeDeveloperInspectionHarnessValidationRow copyWith({
    String? validationRowId,
    String? sourceInspectionRowId,
    String? sourceSnapshotId,
    String? sourceRecordId,
    String? sourcePacketId,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole? role,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus? status,
    bool? developerOnly,
    bool? skeletonOnly,
    bool? contextOnly,
    bool? inactive,
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    List<String>? androidProofCaseIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? futurePrerequisites,
    List<String>? blockedBoundaryIds,
    List<String>? findings,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation?
    recommendation,
  }) {
    return DebugOnlyBridgeDeveloperInspectionHarnessValidationRow(
      validationRowId: validationRowId ?? this.validationRowId,
      sourceInspectionRowId:
          sourceInspectionRowId ?? this.sourceInspectionRowId,
      sourceSnapshotId: sourceSnapshotId ?? this.sourceSnapshotId,
      sourceRecordId: sourceRecordId ?? this.sourceRecordId,
      sourcePacketId: sourcePacketId ?? this.sourcePacketId,
      role: role ?? this.role,
      status: status ?? this.status,
      developerOnly: developerOnly ?? this.developerOnly,
      skeletonOnly: skeletonOnly ?? this.skeletonOnly,
      contextOnly: contextOnly ?? this.contextOnly,
      inactive: inactive ?? this.inactive,
      allowedFieldIds: allowedFieldIds ?? this.allowedFieldIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      futurePrerequisites: futurePrerequisites ?? this.futurePrerequisites,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      findings: findings ?? this.findings,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'validationRowId': validationRowId,
    'sourceInspectionRowId': sourceInspectionRowId,
    'sourceSnapshotId': sourceSnapshotId,
    'sourceRecordId': sourceRecordId,
    'sourcePacketId': sourcePacketId,
    'role': role.wire,
    'status': status.wire,
    'developerOnly': developerOnly,
    'skeletonOnly': skeletonOnly,
    'contextOnly': contextOnly,
    'inactive': inactive,
    'allowedFieldIds': allowedFieldIds,
    'deniedFieldIds': deniedFieldIds,
    'androidProofCaseIds': androidProofCaseIds,
    'warningReasons': warningReasons,
    'proofLimitReasons': proofLimitReasons,
    'futurePrerequisites': futurePrerequisites,
    'blockedBoundaryIds': blockedBoundaryIds,
    'findings': findings,
    'recommendation': recommendation.wire,
  };
}

class DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding {
  const DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.validationRowId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity severity;
  final String message;
  final String? validationRowId;
  final String? fieldId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical => severity.isCritical;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'severity': severity.wire,
    'message': message,
    if (validationRowId != null) 'validationRowId': validationRowId,
    if (fieldId != null) 'fieldId': fieldId,
    if (caseId != null) 'caseId': caseId,
  };
}

class DebugOnlyBridgeDeveloperInspectionHarnessValidationResult {
  const DebugOnlyBridgeDeveloperInspectionHarnessValidationResult({
    required this.status,
    required this.sourceInspectionHarnessStatus,
    required this.sourceSkeletonValidationStatus,
    required this.sourceSkeletonStatus,
    required this.inspectionHarnessResult,
    required this.snapshot,
    required this.skeletonValidationResult,
    required this.skeletonResult,
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
    required this.snapshotValidationCount,
    required this.inputPacketValidationCount,
    required this.outputPacketValidationCount,
    required this.policyValidationCount,
    required this.recordValidationCount,
    required this.validCoreInspectionCount,
    required this.validContextInspectionCount,
    required this.validInactiveInspectionCount,
    required this.validDeniedBoundaryInspectionCount,
    required this.validRuntimeBlockedInspectionCount,
    required this.invalidRowCount,
    required this.unsafeRowCount,
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
    required this.safeForPhase33J,
    required this.phase33JRecommendation,
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

  final DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus status;
  final DebugOnlyBridgeDeveloperInspectionHarnessStatus
  sourceInspectionHarnessStatus;
  final DebugOnlyBridgeDeveloperSkeletonValidationStatus
  sourceSkeletonValidationStatus;
  final DebugOnlyBridgeSkeletonStatus sourceSkeletonStatus;
  final DebugOnlyBridgeDeveloperInspectionHarnessResult inspectionHarnessResult;
  final DebugOnlyBridgeDeveloperInspectionSnapshot snapshot;
  final DebugOnlyBridgeDeveloperSkeletonValidationResult
  skeletonValidationResult;
  final DebugOnlyBridgeSkeletonResult skeletonResult;
  final DebugOnlyBridgeInputPacket inputPacket;
  final DebugOnlyBridgeOutputPacket outputPacket;
  final DebugOnlyBridgePolicy policy;
  final List<DebugOnlyBridgeDeveloperInspectionHarnessValidationCheck>
  validationChecks;
  final List<DebugOnlyBridgeDeveloperInspectionHarnessValidationRow>
  validationRows;
  final List<DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding>
  validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalChecks;
  final int passedCheckCount;
  final int warningCheckCount;
  final int blockerCount;
  final int criticalCount;
  final int totalValidationRows;
  final int snapshotValidationCount;
  final int inputPacketValidationCount;
  final int outputPacketValidationCount;
  final int policyValidationCount;
  final int recordValidationCount;
  final int validCoreInspectionCount;
  final int validContextInspectionCount;
  final int validInactiveInspectionCount;
  final int validDeniedBoundaryInspectionCount;
  final int validRuntimeBlockedInspectionCount;
  final int invalidRowCount;
  final int unsafeRowCount;
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
  final bool safeForPhase33J;
  final DebugOnlyBridgeDeveloperInspectionHarnessValidationPhase33JRecommendation
  phase33JRecommendation;
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

  bool
  get hasUnsafeDebugOnlyBridgeDeveloperInspectionHarnessValidationPolicyViolation =>
      status ==
          DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus
              .blockedByUnsafeInspectionHarness ||
      status ==
          DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus
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

  int get runtimeEnabledCount =>
      debugBridgeRuntimeImplemented ||
          executableBridgeSkeletonImplemented ||
          executableDebugBridgePrototypeImplemented ||
          implementationWiringImplemented
      ? 1
      : 0;

  List<DebugOnlyBridgeDeveloperInspectionHarnessValidationRow> rowsForRole(
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole role,
  ) {
    return validationRows
        .where((row) => row.role == role)
        .toList(growable: false);
  }

  DebugOnlyBridgeDeveloperInspectionHarnessValidationRow rowForRole(
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole role,
  ) {
    return rowsForRole(role).first;
  }

  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult copyWith({
    DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus? status,
    DebugOnlyBridgeDeveloperInspectionHarnessStatus?
    sourceInspectionHarnessStatus,
    DebugOnlyBridgeDeveloperSkeletonValidationStatus?
    sourceSkeletonValidationStatus,
    DebugOnlyBridgeSkeletonStatus? sourceSkeletonStatus,
    DebugOnlyBridgeDeveloperInspectionHarnessResult? inspectionHarnessResult,
    DebugOnlyBridgeDeveloperInspectionSnapshot? snapshot,
    DebugOnlyBridgeDeveloperSkeletonValidationResult? skeletonValidationResult,
    DebugOnlyBridgeSkeletonResult? skeletonResult,
    DebugOnlyBridgeInputPacket? inputPacket,
    DebugOnlyBridgeOutputPacket? outputPacket,
    DebugOnlyBridgePolicy? policy,
    List<DebugOnlyBridgeDeveloperInspectionHarnessValidationCheck>?
    validationChecks,
    List<DebugOnlyBridgeDeveloperInspectionHarnessValidationRow>?
    validationRows,
    List<DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding>?
    validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalChecks,
    int? passedCheckCount,
    int? warningCheckCount,
    int? blockerCount,
    int? criticalCount,
    int? totalValidationRows,
    int? snapshotValidationCount,
    int? inputPacketValidationCount,
    int? outputPacketValidationCount,
    int? policyValidationCount,
    int? recordValidationCount,
    int? validCoreInspectionCount,
    int? validContextInspectionCount,
    int? validInactiveInspectionCount,
    int? validDeniedBoundaryInspectionCount,
    int? validRuntimeBlockedInspectionCount,
    int? invalidRowCount,
    int? unsafeRowCount,
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
    bool? safeForPhase33J,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationPhase33JRecommendation?
    phase33JRecommendation,
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
    return DebugOnlyBridgeDeveloperInspectionHarnessValidationResult(
      status: status ?? this.status,
      sourceInspectionHarnessStatus:
          sourceInspectionHarnessStatus ?? this.sourceInspectionHarnessStatus,
      sourceSkeletonValidationStatus:
          sourceSkeletonValidationStatus ?? this.sourceSkeletonValidationStatus,
      sourceSkeletonStatus: sourceSkeletonStatus ?? this.sourceSkeletonStatus,
      inspectionHarnessResult:
          inspectionHarnessResult ?? this.inspectionHarnessResult,
      snapshot: snapshot ?? this.snapshot,
      skeletonValidationResult:
          skeletonValidationResult ?? this.skeletonValidationResult,
      skeletonResult: skeletonResult ?? this.skeletonResult,
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
      snapshotValidationCount:
          snapshotValidationCount ?? this.snapshotValidationCount,
      inputPacketValidationCount:
          inputPacketValidationCount ?? this.inputPacketValidationCount,
      outputPacketValidationCount:
          outputPacketValidationCount ?? this.outputPacketValidationCount,
      policyValidationCount:
          policyValidationCount ?? this.policyValidationCount,
      recordValidationCount:
          recordValidationCount ?? this.recordValidationCount,
      validCoreInspectionCount:
          validCoreInspectionCount ?? this.validCoreInspectionCount,
      validContextInspectionCount:
          validContextInspectionCount ?? this.validContextInspectionCount,
      validInactiveInspectionCount:
          validInactiveInspectionCount ?? this.validInactiveInspectionCount,
      validDeniedBoundaryInspectionCount:
          validDeniedBoundaryInspectionCount ??
          this.validDeniedBoundaryInspectionCount,
      validRuntimeBlockedInspectionCount:
          validRuntimeBlockedInspectionCount ??
          this.validRuntimeBlockedInspectionCount,
      invalidRowCount: invalidRowCount ?? this.invalidRowCount,
      unsafeRowCount: unsafeRowCount ?? this.unsafeRowCount,
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
      safeForPhase33J: safeForPhase33J ?? this.safeForPhase33J,
      phase33JRecommendation:
          phase33JRecommendation ?? this.phase33JRecommendation,
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
      ..writeln('# Debug-Only Bridge Developer Inspection Harness Validation')
      ..writeln()
      ..writeln(
        '- version: '
        '$debugOnlyBridgeDeveloperInspectionHarnessValidationReportVersion',
      )
      ..writeln('- validation status: ${status.wire}')
      ..writeln(
        '- source inspection harness status: '
        '${sourceInspectionHarnessStatus.wire}',
      )
      ..writeln(
        '- source skeleton validation status: '
        '${sourceSkeletonValidationStatus.wire}',
      )
      ..writeln('- source skeleton status: ${sourceSkeletonStatus.wire}')
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
      ..writeln('- engine call count: $engineCallCount')
      ..writeln('- scheduler execution count: $schedulerExecutionCount')
      ..writeln('- ui target count: $uiTargetCount')
      ..writeln('- persistence write count: $persistenceWriteCount')
      ..writeln('- safeForPhase33J: $safeForPhase33J')
      ..writeln('- Phase 33J recommendation: ${phase33JRecommendation.wire}')
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
      ..writeln('## Snapshot Validation')
      ..writeln(
        _rowSummary(
          rowForRole(
            DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                .snapshotValidation,
          ),
        ),
      )
      ..writeln()
      ..writeln('## Input/Output Packet Validation')
      ..writeln(
        _rowSummary(
          rowForRole(
            DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                .inputPacketInspectionValidation,
          ),
        ),
      )
      ..writeln()
      ..writeln(
        _rowSummary(
          rowForRole(
            DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                .outputPacketInspectionValidation,
          ),
        ),
      )
      ..writeln()
      ..writeln('## Policy Validation')
      ..writeln(
        _rowSummary(
          rowForRole(
            DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                .policyInspectionValidation,
          ),
        ),
      )
      ..writeln()
      ..writeln('## Inspection Row Validation Table')
      ..writeln(
        '| Row | Role | Status | Source row | Allowed field IDs | Denied field IDs | Developer-only | Skeleton-only | Context-only | Inactive | Findings |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in validationRows.where(
      (row) => row.role.isRecordValidation,
    )) {
      buffer.writeln(
        '| ${row.validationRowId} | ${row.role.wire} | ${row.status.wire} | '
        '${row.sourceInspectionRowId} | ${_ids(row.allowedFieldIds)} | '
        '${_ids(row.deniedFieldIds)} | ${row.developerOnly} | '
        '${row.skeletonOnly} | ${row.contextOnly} | ${row.inactive} | '
        '${_ids(row.findings)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Allowed/Denied Field Boundary Validation')
      ..writeln('- allowed field IDs: ${_ids(snapshot.allowedFieldSummary)}')
      ..writeln('- denied field IDs: ${_ids(snapshot.deniedFieldSummary)}')
      ..writeln()
      ..writeln('## Stockfish/Raw UCI/PV Denial Validation')
      ..writeln('- Stockfish command leak count: $stockfishCommandLeakCount')
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
      ..writeln('## Scheduler Execution Denied Validation')
      ..writeln('- scheduler execution count: $schedulerExecutionCount')
      ..writeln()
      ..writeln('## Android Proof Boundary')
      ..writeln('- captured proof IDs: ${_ids(snapshot.proofBoundarySummary)}')
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
      ..writeln('## Phase 33J Recommendation')
      ..writeln('- ${phase33JRecommendation.wire}');
    return buffer.toString();
  }

  String renderJsonReport() {
    return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'version':
          debugOnlyBridgeDeveloperInspectionHarnessValidationReportVersion,
      'status': status.wire,
      'sourceInspectionHarnessStatus': sourceInspectionHarnessStatus.wire,
      'sourceSkeletonValidationStatus': sourceSkeletonValidationStatus.wire,
      'sourceSkeletonStatus': sourceSkeletonStatus.wire,
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
      'snapshotValidationCount': snapshotValidationCount,
      'inputPacketValidationCount': inputPacketValidationCount,
      'outputPacketValidationCount': outputPacketValidationCount,
      'policyValidationCount': policyValidationCount,
      'recordValidationCount': recordValidationCount,
      'validCoreInspectionCount': validCoreInspectionCount,
      'validContextInspectionCount': validContextInspectionCount,
      'validInactiveInspectionCount': validInactiveInspectionCount,
      'validDeniedBoundaryInspectionCount': validDeniedBoundaryInspectionCount,
      'validRuntimeBlockedInspectionCount': validRuntimeBlockedInspectionCount,
      'invalidRowCount': invalidRowCount,
      'unsafeRowCount': unsafeRowCount,
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
      'safeForPhase33J': safeForPhase33J,
      'phase33JRecommendation': phase33JRecommendation.wire,
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

class DebugOnlyBridgeDeveloperInspectionHarnessValidation {
  const DebugOnlyBridgeDeveloperInspectionHarnessValidation({
    this.validator =
        const DebugOnlyBridgeDeveloperInspectionHarnessValidationValidator(),
  });

  final DebugOnlyBridgeDeveloperInspectionHarnessValidationValidator validator;

  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult evaluate([
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRequest request =
        const DebugOnlyBridgeDeveloperInspectionHarnessValidationRequest(),
  ]) {
    final harnessResult =
        request.inspectionHarnessResult ??
        request.inspectionHarness.evaluate(
          DebugOnlyBridgeDeveloperInspectionHarnessRequest(
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final snapshot = request.snapshot ?? harnessResult.snapshot;
    final skeletonValidationResult =
        request.skeletonValidationResult ??
        harnessResult.skeletonValidationResult;
    final skeletonResult =
        request.skeletonResult ?? harnessResult.skeletonResult;
    final inputPacket = request.inputPacket ?? harnessResult.inputPacket;
    final policy = request.policy ?? harnessResult.policy;
    final outputPacket =
        request.outputPacket ??
        harnessResult.outputPacket.copyWith(policy: policy);
    final effectiveHarnessResult = harnessResult.copyWith(
      snapshot: snapshot,
      skeletonValidationResult: skeletonValidationResult,
      skeletonResult: skeletonResult,
      inputPacket: inputPacket,
      outputPacket: outputPacket,
      policy: policy,
    );
    final rows = _validationRows(
      snapshot: snapshot,
      inspectionRows: effectiveHarnessResult.inspectionRows,
    );
    final checks = _validationChecks(
      harnessResult: effectiveHarnessResult,
      snapshot: snapshot,
      skeletonValidationResult: skeletonValidationResult,
      skeletonResult: skeletonResult,
      inputPacket: inputPacket,
      outputPacket: outputPacket,
      policy: policy,
      rows: rows,
    );
    final base = _resultFromValidation(
      harnessResult: effectiveHarnessResult,
      snapshot: snapshot,
      skeletonValidationResult: skeletonValidationResult,
      skeletonResult: skeletonResult,
      inputPacket: inputPacket,
      outputPacket: outputPacket,
      policy: policy,
      validationChecks: checks,
      validationRows: rows,
      validationFindings:
          const <DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromValidation(
      harnessResult: effectiveHarnessResult,
      snapshot: snapshot,
      skeletonValidationResult: skeletonValidationResult,
      skeletonResult: skeletonResult,
      inputPacket: inputPacket,
      outputPacket: outputPacket,
      policy: policy,
      validationChecks: checks,
      validationRows: rows,
      validationFindings: findings,
    );
  }
}

class DebugOnlyBridgeDeveloperInspectionHarnessValidationValidator {
  const DebugOnlyBridgeDeveloperInspectionHarnessValidationValidator();

  List<DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding> validate(
    DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings =
        <DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);

    void add({
      required String id,
      required DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity
      severity,
      required String message,
      String? validationRowId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding(
          id: id,
          severity: severity,
          message: message,
          validationRowId: validationRowId,
          fieldId: fieldId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase33J &&
        (!result.inspectionHarnessResult.safeForPhase33I ||
            result
                .inspectionHarnessResult
                .hasUnsafeDebugOnlyBridgeDeveloperInspectionHarnessPolicyViolation)) {
      add(
        id: 'unsafeInspectionHarnessMarkedValid',
        severity: DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity
            .critical,
        message: 'unsafe Phase 33H inspection harness cannot validate as safe',
      );
    }
    if (result.safeForPhase33J &&
        (!result.skeletonValidationResult.safeForPhase33H ||
            result
                .skeletonValidationResult
                .hasUnsafeDebugOnlyBridgeDeveloperSkeletonValidationPolicyViolation)) {
      add(
        id: 'unsafeSkeletonValidationInput',
        severity: DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity
            .critical,
        message: 'unsafe Phase 33G skeleton validation cannot validate harness',
      );
    }
    if (result.safeForPhase33J &&
        (!result.skeletonResult.safeForPhase33G ||
            result
                .skeletonResult
                .hasUnsafeDebugOnlyBridgeDeveloperSkeletonPolicyViolation)) {
      add(
        id: 'unsafeSkeletonResultInput',
        severity: DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity
            .critical,
        message: 'unsafe Phase 33F skeleton cannot validate harness',
      );
    }
    if (result.phase33JRequirementPresentCount != 1) {
      add(
        id: 'missingPhase33JRequirement',
        severity: DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity
            .critical,
        message: 'Phase 33J diagnostic command requirement must be present',
      );
    }
    if (result.snapshot.hasUnsafeInspectionOutput) {
      add(
        id: 'unsafeSnapshot',
        severity: DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity
            .critical,
        message: 'inspection snapshot contains unsafe output',
      );
    }
    for (final row in result.validationRows) {
      _checkValidationRow(add, row, provenAndroidIds);
    }
    for (final fieldId in _deniedFieldIds) {
      if (!result.snapshot.deniedFieldSummary.contains(fieldId) ||
          !result.policy.deniedFieldIds.contains(fieldId) ||
          !result.inputPacket.deniedFieldIds.contains(fieldId) ||
          !result.outputPacket.deniedFieldIds.contains(fieldId)) {
        add(
          id: 'deniedFieldMissing',
          severity: DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity
              .blocker,
          message: '$fieldId must remain denied',
          fieldId: fieldId,
        );
      }
    }
    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity:
            DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity.blocker,
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
        id: 'inspectionHarnessValidationBoundaryPolicyViolation',
        severity: DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity
            .critical,
        message: 'inspection harness validation crossed a blocked boundary',
      );
    }
    return findings..sort(_compareFindings);
  }

  List<DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding>
  validateReportText(String reportText) {
    final findings =
        <DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding(
          id: id,
          severity: DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity
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

extension _Phase33JRequirementCount
    on DebugOnlyBridgeDeveloperInspectionHarnessValidationResult {
  int get phase33JRequirementPresentCount => validationRows
      .where(
        (row) =>
            row.role ==
            DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                .futureRequirementInspectionValidation,
      )
      .where(
        (row) => row.futurePrerequisites.contains(
          'phase33JDebugOnlyBridgeDeveloperDiagnosticCommand',
        ),
      )
      .length;
}

List<DebugOnlyBridgeDeveloperInspectionHarnessValidationRow> _validationRows({
  required DebugOnlyBridgeDeveloperInspectionSnapshot snapshot,
  required List<DebugOnlyBridgeDeveloperInspectionRow> inspectionRows,
}) {
  return <DebugOnlyBridgeDeveloperInspectionHarnessValidationRow>[
    _snapshotRow(snapshot),
    ...inspectionRows.map((row) => _rowFromInspection(snapshot, row)),
  ];
}

DebugOnlyBridgeDeveloperInspectionHarnessValidationRow _snapshotRow(
  DebugOnlyBridgeDeveloperInspectionSnapshot snapshot,
) {
  final findings = _rowFindings(
    developerOnly: snapshot.developerOnly,
    skeletonOnly: snapshot.skeletonOnly,
    allowedFieldIds: snapshot.allowedFieldSummary,
  );
  return DebugOnlyBridgeDeveloperInspectionHarnessValidationRow(
    validationRowId: 'phase33i-snapshot',
    sourceInspectionRowId: 'snapshot',
    sourceSnapshotId: snapshot.snapshotId,
    sourceRecordId: 'none',
    sourcePacketId: snapshot.outputPacketId,
    role: DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .snapshotValidation,
    status: findings.isEmpty
        ? DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
              .validSnapshot
        : DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
              .unsafeRow,
    developerOnly: snapshot.developerOnly,
    skeletonOnly: snapshot.skeletonOnly,
    contextOnly: false,
    inactive: false,
    allowedFieldIds: _sortedStrings(snapshot.allowedFieldSummary),
    deniedFieldIds: _sortedStrings(snapshot.deniedFieldSummary),
    androidProofCaseIds: _sortedStrings(snapshot.proofBoundarySummary),
    warningReasons: _sortedStrings(snapshot.warningSummary),
    proofLimitReasons: const <String>[],
    futurePrerequisites: _sortedStrings(<String>[
      ...snapshot.futurePrerequisiteSummary,
      'phase33JDebugOnlyBridgeDeveloperDiagnosticCommand',
    ]),
    blockedBoundaryIds: _sortedStrings(snapshot.blockedBoundarySummary),
    findings: findings,
    recommendation:
        DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
            .keepSnapshotDeveloperOnly,
  );
}

DebugOnlyBridgeDeveloperInspectionHarnessValidationRow _rowFromInspection(
  DebugOnlyBridgeDeveloperInspectionSnapshot snapshot,
  DebugOnlyBridgeDeveloperInspectionRow row,
) {
  final role = _validationRoleForInspectionRole(row.role);
  final findings = _inspectionRowFindings(row);
  return DebugOnlyBridgeDeveloperInspectionHarnessValidationRow(
    validationRowId: 'phase33i-${row.role.wire}',
    sourceInspectionRowId: row.inspectionRowId,
    sourceSnapshotId: snapshot.snapshotId,
    sourceRecordId: row.sourceRecordId,
    sourcePacketId: row.sourcePacketId,
    role: role,
    status: findings.isEmpty
        ? _validStatusForRole(role)
        : DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
              .unsafeRow,
    developerOnly: row.developerOnly,
    skeletonOnly: row.skeletonOnly,
    contextOnly: row.contextOnly,
    inactive: row.inactive,
    allowedFieldIds: _sortedStrings(row.allowedFieldIds),
    deniedFieldIds: _sortedStrings(row.deniedFieldIds),
    androidProofCaseIds: _sortedStrings(row.androidProofCaseIds),
    warningReasons: _sortedStrings(row.warningReasons),
    proofLimitReasons: _sortedStrings(row.proofLimitReasons),
    futurePrerequisites: _sortedStrings(<String>[
      ...row.futurePrerequisites,
      if (row.role ==
          DebugOnlyBridgeDeveloperInspectionRowRole.futureRequirementInspection)
        'phase33JDebugOnlyBridgeDeveloperDiagnosticCommand',
    ]),
    blockedBoundaryIds: _sortedStrings(row.blockedBoundaryIds),
    findings: findings,
    recommendation: _recommendationForRole(role),
  );
}

List<DebugOnlyBridgeDeveloperInspectionHarnessValidationCheck>
_validationChecks({
  required DebugOnlyBridgeDeveloperInspectionHarnessResult harnessResult,
  required DebugOnlyBridgeDeveloperInspectionSnapshot snapshot,
  required DebugOnlyBridgeDeveloperSkeletonValidationResult
  skeletonValidationResult,
  required DebugOnlyBridgeSkeletonResult skeletonResult,
  required DebugOnlyBridgeInputPacket inputPacket,
  required DebugOnlyBridgeOutputPacket outputPacket,
  required DebugOnlyBridgePolicy policy,
  required List<DebugOnlyBridgeDeveloperInspectionHarnessValidationRow> rows,
}) {
  DebugOnlyBridgeDeveloperInspectionHarnessValidationCheck check({
    required DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId id,
    required bool passed,
    required String okMessage,
    required String failMessage,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity severity =
        DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity.critical,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
        recommendation =
        DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
            .investigateInspectionHarnessValidationFailure,
  }) {
    return DebugOnlyBridgeDeveloperInspectionHarnessValidationCheck(
      checkId: id,
      checkStatus: passed
          ? DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckStatus
                .passed
          : severity.isCritical
          ? DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckStatus
                .blocked
          : DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckStatus
                .failed,
      severity: passed
          ? DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity.none
          : severity,
      message: passed ? okMessage : failMessage,
      recommendation: passed
          ? recommendation
          : DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
                .blockUnsafeInspectionHarnessValidation,
    );
  }

  final reportFindings =
      const DebugOnlyBridgeDeveloperInspectionHarnessValidationValidator()
          .validateReportText(harnessResult.renderMarkdownReport());
  final rowRoles = rows.map((row) => row.role).toSet();

  return <DebugOnlyBridgeDeveloperInspectionHarnessValidationCheck>[
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .harnessConsumesSafeSkeletonValidation,
      passed:
          skeletonValidationResult.safeForPhase33H &&
          !skeletonValidationResult
              .hasUnsafeDebugOnlyBridgeDeveloperSkeletonValidationPolicyViolation &&
          harnessResult.skeletonValidationResult == skeletonValidationResult,
      okMessage: 'inspection harness consumes safe skeleton validation',
      failMessage: 'inspection harness consumed unsafe skeleton validation',
    ),
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .harnessConsumesSafeSkeletonResult,
      passed:
          skeletonResult.safeForPhase33G &&
          !skeletonResult
              .hasUnsafeDebugOnlyBridgeDeveloperSkeletonPolicyViolation &&
          harnessResult.skeletonResult == skeletonResult,
      okMessage: 'inspection harness consumes safe skeleton result',
      failMessage: 'inspection harness consumed unsafe skeleton result',
    ),
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .snapshotIsDeveloperOnly,
      passed: snapshot.developerOnly && snapshot.skeletonOnly,
      okMessage: 'snapshot is developer-only and skeleton-only',
      failMessage: 'snapshot crossed developer-only boundary',
      recommendation:
          DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
              .keepSnapshotDeveloperOnly,
    ),
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .snapshotHasSafeFieldsOnly,
      passed: !snapshot.hasUnsafeInspectionOutput,
      okMessage: 'snapshot has safe fields only',
      failMessage: 'snapshot includes active denied fields',
      recommendation:
          DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
              .keepSnapshotDeveloperOnly,
    ),
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .inputPacketInspectionIsSafe,
      passed: _rowsFor(
        rows,
        DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
            .inputPacketInspectionValidation,
      ).every((row) => !row.hasUnsafeOutput),
      okMessage: 'input packet inspection is safe',
      failMessage: 'input packet inspection is unsafe',
      recommendation:
          DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
              .keepInputPacketInspectionSafe,
    ),
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .outputPacketInspectionIsSafe,
      passed:
          outputPacket.safeForDeveloperInspection &&
          _rowsFor(
            rows,
            DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                .outputPacketInspectionValidation,
          ).every((row) => !row.hasUnsafeOutput),
      okMessage: 'output packet inspection is safe',
      failMessage: 'output packet inspection is unsafe',
      recommendation:
          DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
              .keepOutputPacketInspectionSafe,
    ),
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .policyInspectionIsSafe,
      passed:
          !policy.hasUnsafeAllowance &&
          _rowsFor(
            rows,
            DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                .policyInspectionValidation,
          ).every((row) => !row.hasUnsafeOutput),
      okMessage: 'policy inspection is safe',
      failMessage: 'policy inspection is unsafe',
      recommendation:
          DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
              .keepPolicyInspectionSafe,
    ),
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .recordInspectionsPreserveRoles,
      passed:
          rowRoles.contains(
            DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                .coreRecordInspectionValidation,
          ) &&
          rowRoles.contains(
            DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                .contextRecordInspectionValidation,
          ) &&
          rowRoles.contains(
            DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                .inactiveRecordInspectionValidation,
          ) &&
          _rowsFor(
            rows,
            DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                .coreRecordInspectionValidation,
          ).every((row) => !row.contextOnly && !row.inactive) &&
          _rowsFor(
            rows,
            DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                .contextRecordInspectionValidation,
          ).every((row) => row.contextOnly && !row.inactive) &&
          _rowsFor(
            rows,
            DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                .inactiveRecordInspectionValidation,
          ).every((row) => row.inactive),
      okMessage: 'record inspections preserve roles',
      failMessage: 'record inspection role boundary changed',
      recommendation:
          DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
              .keepCoreInspectionCore,
    ),
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .deniedFieldsRemainInactive,
      passed:
          rows.every((row) => !row.hasActiveDeniedField) &&
          _deniedFieldIds.every(snapshot.deniedFieldSummary.contains),
      okMessage: 'denied fields remain inactive',
      failMessage: 'denied field became active or missing',
      recommendation:
          DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
              .keepDeniedBoundaryDenied,
    ),
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .stockfishRawUciPvDumpRemainDenied,
      passed:
          snapshot.deniedFieldSummary.contains('stockfishCommand') &&
          snapshot.deniedFieldSummary.contains('rawUci') &&
          snapshot.deniedFieldSummary.contains('pvDump') &&
          rows.every(
            (row) =>
                !row.allowedFieldIds.contains('stockfishCommand') &&
                !row.allowedFieldIds.contains('rawUci') &&
                !row.allowedFieldIds.contains('pvDump'),
          ),
      okMessage: 'Stockfish command, raw UCI, and PV dump remain denied',
      failMessage: 'engine dump field became active',
      recommendation:
          DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
              .keepStockfishRawUciPvDumpDenied,
    ),
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .runtimePrototypeWiringRemainBlocked,
      passed:
          !harnessResult.debugBridgeRuntimeImplemented &&
          !harnessResult.executableBridgeSkeletonImplemented &&
          !harnessResult.executableDebugBridgePrototypeImplemented &&
          !harnessResult.implementationWiringImplemented,
      okMessage: 'runtime, prototype, and wiring remain blocked',
      failMessage: 'runtime, prototype, or wiring became active',
      recommendation:
          DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
              .keepRuntimePrototypeWiringBlocked,
    ),
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .schedulerExecutionRemainsDenied,
      passed:
          snapshot.deniedFieldSummary.contains('schedulerExecution') &&
          rows.every((row) => !_rowHasSchedulerExecution(row)),
      okMessage: 'scheduler execution remains denied',
      failMessage: 'scheduler execution became active',
      recommendation:
          DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
              .keepRuntimePrototypeWiringBlocked,
    ),
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .androidProofIdsAreCapturedOnly,
      passed: _sameStringSet(
        snapshot.proofBoundarySummary,
        _capturedAndroidProofIds,
      ),
      okMessage: 'Android proof IDs are captured-only',
      failMessage: 'Android proof boundary changed',
      recommendation:
          DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
              .keepProofBoundaryCapturedOnly,
    ),
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .phase32ECasesAreNotCapturedProof,
      passed: !rows
          .expand((row) => row.androidProofCaseIds)
          .any(_phase32ECaseIds.contains),
      okMessage: 'Phase 32E cases are not captured proof',
      failMessage: 'Phase 32E case was treated as captured proof',
      recommendation:
          DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
              .keepProofBoundaryCapturedOnly,
    ),
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .ownerProofQueueRemainsEmpty,
      passed: harnessResult.ownerProofQueueCount == 0,
      okMessage: 'owner proof queue remains empty',
      failMessage: 'owner proof queue is not empty',
      severity:
          DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity.blocker,
      recommendation:
          DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
              .keepOwnerProofEmpty,
    ),
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .noLabelsScoresRankingsMetrics,
      passed:
          !harnessResult.classifierOutputActive &&
          !harnessResult.finalMoveLabelOutputActive &&
          !harnessResult.numericOutputActive &&
          !harnessResult.aggregateScoreOutputActive &&
          !harnessResult.moveRankingOutputActive &&
          !harnessResult.officialMetricOutputActive &&
          !harnessResult.cpLossOutputActive &&
          !harnessResult.winProbabilityOutputActive,
      okMessage: 'labels, scores, rankings, and metrics remain absent',
      failMessage: 'label, score, ranking, or metric output became active',
    ),
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .noUiBackendPersistenceEngineFields,
      passed:
          !harnessResult.uiTargetsActive &&
          !harnessResult.backendOutputActive &&
          !harnessResult.persistenceWritesActive &&
          !harnessResult.engineCallsActive,
      okMessage: 'UI/backend/persistence/engine fields remain absent',
      failMessage: 'integration field became active',
    ),
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .noQuietPreparatoryActivation,
      passed: !harnessResult.quietPreparatoryScopeActivated,
      okMessage: 'quiet/preparatory scope remains excluded',
      failMessage: 'quiet/preparatory scope became active',
    ),
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .reportContainsNoRawUciOrPvDump,
      passed: reportFindings.isEmpty,
      okMessage: 'report text contains no raw UCI or PV dump output',
      failMessage: 'report text leaked raw UCI or PV dump output',
    ),
    check(
      id: DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId
          .phase33JRequirementPresent,
      passed: rows.any(
        (row) =>
            row.role ==
                DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                    .futureRequirementInspectionValidation &&
            row.futurePrerequisites.contains(
              'phase33JDebugOnlyBridgeDeveloperDiagnosticCommand',
            ),
      ),
      okMessage: 'Phase 33J diagnostic command requirement is present',
      failMessage: 'Phase 33J diagnostic command requirement is missing',
      recommendation:
          DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
              .requirePhase33JDiagnosticCommand,
    ),
  ];
}

DebugOnlyBridgeDeveloperInspectionHarnessValidationResult
_resultFromValidation({
  required DebugOnlyBridgeDeveloperInspectionHarnessResult harnessResult,
  required DebugOnlyBridgeDeveloperInspectionSnapshot snapshot,
  required DebugOnlyBridgeDeveloperSkeletonValidationResult
  skeletonValidationResult,
  required DebugOnlyBridgeSkeletonResult skeletonResult,
  required DebugOnlyBridgeInputPacket inputPacket,
  required DebugOnlyBridgeOutputPacket outputPacket,
  required DebugOnlyBridgePolicy policy,
  required List<DebugOnlyBridgeDeveloperInspectionHarnessValidationCheck>
  validationChecks,
  required List<DebugOnlyBridgeDeveloperInspectionHarnessValidationRow>
  validationRows,
  required List<DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding>
  validationFindings,
}) {
  final activeDeniedFieldCount = validationRows
      .where((row) => row.hasActiveDeniedField)
      .length;
  final productOutputCount = harnessResult.productOutputCount;
  final labelLeakCount = harnessResult.labelLeakCount;
  final scoreLeakCount = harnessResult.scoreLeakCount;
  final metricLeakCount = harnessResult.metricLeakCount;
  final cpLossLeakCount = harnessResult.cpLossLeakCount;
  final winProbabilityLeakCount = harnessResult.winProbabilityLeakCount;
  final uiTargetCount = harnessResult.uiTargetCount;
  final backendTargetCount = harnessResult.backendTargetCount;
  final persistenceWriteCount = harnessResult.persistenceWriteCount;
  final engineCallCount = harnessResult.engineCallCount;
  final schedulerExecutionCount =
      harnessResult.schedulerExecutionCount +
      validationRows.where((row) => _rowHasSchedulerExecution(row)).length;
  final stockfishCommandLeakCount =
      harnessResult.stockfishCommandLeakCount +
      validationRows
          .where((row) => row.allowedFieldIds.contains('stockfishCommand'))
          .length;
  final rawUciLeakCount =
      harnessResult.rawUciLeakCount +
      validationRows
          .where((row) => row.allowedFieldIds.contains('rawUci'))
          .length;
  final pvDumpLeakCount =
      harnessResult.pvDumpLeakCount +
      validationRows
          .where((row) => row.allowedFieldIds.contains('pvDump'))
          .length;
  final invalidRowCount = validationRows
      .where((row) => row.status.isInvalid)
      .length;
  final unsafeRowCount = validationRows
      .where((row) => row.hasUnsafeOutput)
      .length;
  final blockerCount =
      validationChecks.where((check) => check.blocksStrict).length +
      validationFindings.where((finding) => finding.blocksStrict).length;
  final criticalCount =
      validationChecks.where((check) => check.isCritical).length +
      validationFindings.where((finding) => finding.isCritical).length;
  final unsafeCount =
      harnessResult.unsafeCount +
      unsafeRowCount +
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
  final base = DebugOnlyBridgeDeveloperInspectionHarnessValidationResult(
    status: DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus.invalid,
    sourceInspectionHarnessStatus: harnessResult.status,
    sourceSkeletonValidationStatus: skeletonValidationResult.status,
    sourceSkeletonStatus: skeletonResult.status,
    inspectionHarnessResult: harnessResult,
    snapshot: snapshot,
    skeletonValidationResult: skeletonValidationResult,
    skeletonResult: skeletonResult,
    inputPacket: inputPacket,
    outputPacket: outputPacket,
    policy: policy,
    validationChecks: validationChecks,
    validationRows: validationRows,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...harnessResult.warnings,
      ...validationChecks
          .where((check) => check.checkStatus.isWarning)
          .map((check) => check.message),
      'Phase 33I validates the developer inspection harness before diagnostics',
    ]),
    failures: _sortedStrings(<String>[
      ...harnessResult.failures,
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
    snapshotValidationCount: _countRole(
      validationRows,
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
          .snapshotValidation,
    ),
    inputPacketValidationCount: _countRole(
      validationRows,
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
          .inputPacketInspectionValidation,
    ),
    outputPacketValidationCount: _countRole(
      validationRows,
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
          .outputPacketInspectionValidation,
    ),
    policyValidationCount: _countRole(
      validationRows,
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
          .policyInspectionValidation,
    ),
    recordValidationCount: validationRows
        .where((row) => row.role.isRecordValidation)
        .length,
    validCoreInspectionCount: _countStatus(
      validationRows,
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
          .validCoreInspection,
    ),
    validContextInspectionCount: _countStatus(
      validationRows,
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
          .validContextInspection,
    ),
    validInactiveInspectionCount: _countStatus(
      validationRows,
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
          .validInactiveInspection,
    ),
    validDeniedBoundaryInspectionCount:
        _countStatus(
          validationRows,
          DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
              .validDeniedBoundaryInspection,
        ) +
        _countStatus(
          validationRows,
          DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
              .validAllowedFieldBoundaryInspection,
        ),
    validRuntimeBlockedInspectionCount: _countStatus(
      validationRows,
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
          .validRuntimeBlockedInspection,
    ),
    invalidRowCount: invalidRowCount,
    unsafeRowCount: unsafeRowCount,
    ownerProofQueueCount: harnessResult.ownerProofQueueCount,
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
    safeForPhase33J: false,
    phase33JRecommendation:
        DebugOnlyBridgeDeveloperInspectionHarnessValidationPhase33JRecommendation
            .addMoreGoldenCoverageFirst,
    developerOnly: harnessResult.developerOnly,
    debugBridgeRuntimeImplemented: harnessResult.debugBridgeRuntimeImplemented,
    executableBridgeSkeletonImplemented:
        harnessResult.executableBridgeSkeletonImplemented,
    executableDebugBridgePrototypeImplemented:
        harnessResult.executableDebugBridgePrototypeImplemented,
    implementationWiringImplemented:
        harnessResult.implementationWiringImplemented,
    productOutputActive: harnessResult.productOutputActive,
    classifierOutputActive: harnessResult.classifierOutputActive,
    finalMoveLabelOutputActive: harnessResult.finalMoveLabelOutputActive,
    officialMetricOutputActive: harnessResult.officialMetricOutputActive,
    cpLossOutputActive: harnessResult.cpLossOutputActive,
    winProbabilityOutputActive: harnessResult.winProbabilityOutputActive,
    numericOutputActive: harnessResult.numericOutputActive,
    aggregateScoreOutputActive: harnessResult.aggregateScoreOutputActive,
    moveRankingOutputActive: harnessResult.moveRankingOutputActive,
    quietPreparatoryScopeActivated:
        harnessResult.quietPreparatoryScopeActivated,
    engineCallsActive: harnessResult.engineCallsActive,
    persistenceWritesActive: harnessResult.persistenceWritesActive,
    uiTargetsActive: harnessResult.uiTargetsActive,
    backendOutputActive: harnessResult.backendOutputActive,
    stockfishCommandFieldActive: harnessResult.stockfishCommandFieldActive,
    rawUciFieldActive: harnessResult.rawUciFieldActive,
    pvDumpFieldActive: harnessResult.pvDumpFieldActive,
  );
  final status = _validationStatusFor(base);
  final safeForPhase33J =
      (status ==
              DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus
                  .inspectionHarnessValidatedWithWarnings ||
          status ==
              DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus
                  .inspectionHarnessValidatedClean) &&
      harnessResult.safeForPhase33I &&
      !harnessResult
          .hasUnsafeDebugOnlyBridgeDeveloperInspectionHarnessPolicyViolation &&
      skeletonValidationResult.safeForPhase33H &&
      !skeletonValidationResult
          .hasUnsafeDebugOnlyBridgeDeveloperSkeletonValidationPolicyViolation &&
      skeletonResult.safeForPhase33G &&
      !skeletonResult
          .hasUnsafeDebugOnlyBridgeDeveloperSkeletonPolicyViolation &&
      unsafeCount == 0 &&
      blockerCount == 0 &&
      criticalCount == 0 &&
      validationRows.every((row) => !row.hasUnsafeOutput);
  return base.copyWith(
    status: status,
    safeForPhase33J: safeForPhase33J,
    phase33JRecommendation: _phase33JRecommendationFor(
      status: status,
      safeForPhase33J: safeForPhase33J,
      ownerProofQueueCount: harnessResult.ownerProofQueueCount,
    ),
  );
}

DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus _validationStatusFor(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  if (result.activeDeniedFieldCount > 0 ||
      result.productOutputCount > 0 ||
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
    return DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus
        .blockedByPolicyBoundary;
  }
  if (result
          .inspectionHarnessResult
          .hasUnsafeDebugOnlyBridgeDeveloperInspectionHarnessPolicyViolation ||
      !result.inspectionHarnessResult.safeForPhase33I ||
      result
          .skeletonValidationResult
          .hasUnsafeDebugOnlyBridgeDeveloperSkeletonValidationPolicyViolation ||
      !result.skeletonValidationResult.safeForPhase33H ||
      result
          .skeletonResult
          .hasUnsafeDebugOnlyBridgeDeveloperSkeletonPolicyViolation ||
      !result.skeletonResult.safeForPhase33G ||
      result.unsafeCount > 0 ||
      result.criticalCount > 0) {
    return DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus
        .blockedByUnsafeInspectionHarness;
  }
  if (result.blockerCount > 0 ||
      result.totalChecks == 0 ||
      result.totalValidationRows == 0 ||
      result.invalidRowCount > 0) {
    return DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus.invalid;
  }
  if (result.warningCheckCount > 0 || result.warnings.isNotEmpty) {
    return DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus
        .inspectionHarnessValidatedWithWarnings;
  }
  return DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus
      .inspectionHarnessValidatedClean;
}

DebugOnlyBridgeDeveloperInspectionHarnessValidationPhase33JRecommendation
_phase33JRecommendationFor({
  required DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus status,
  required bool safeForPhase33J,
  required int ownerProofQueueCount,
}) {
  if (status ==
          DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus
              .blockedByUnsafeInspectionHarness ||
      status ==
          DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus
              .blockedByPolicyBoundary) {
    return DebugOnlyBridgeDeveloperInspectionHarnessValidationPhase33JRecommendation
        .blockedByUnsafeInspectionHarnessValidation;
  }
  if (ownerProofQueueCount > 0) {
    return DebugOnlyBridgeDeveloperInspectionHarnessValidationPhase33JRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase33J) {
    return DebugOnlyBridgeDeveloperInspectionHarnessValidationPhase33JRecommendation
        .proceedToInspectionHarnessHardening;
  }
  return DebugOnlyBridgeDeveloperInspectionHarnessValidationPhase33JRecommendation
      .proceedToDebugOnlyBridgeDeveloperDiagnosticCommand;
}

void _checkValidationRow(
  void Function({
    required String id,
    required DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity
    severity,
    required String message,
    String? validationRowId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugOnlyBridgeDeveloperInspectionHarnessValidationRow row,
  List<String> provenAndroidIds,
) {
  if (!row.developerOnly || !row.skeletonOnly) {
    add(
      id: 'rowNotDeveloperOrSkeletonOnly',
      severity:
          DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity.critical,
      message: 'validation rows must stay developer-only and skeleton-only',
      validationRowId: row.validationRowId,
    );
  }
  for (final fieldId in row.allowedFieldIds) {
    if (_isDeniedFieldId(fieldId) || _isLegacyDeniedFieldId(fieldId)) {
      add(
        id: 'activeDeniedField',
        severity: DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity
            .critical,
        message: '$fieldId is denied and cannot become active',
        validationRowId: row.validationRowId,
        fieldId: fieldId,
      );
    }
    if (fieldId == 'schedulerExecution' ||
        fieldId.toLowerCase().contains('schedulerexecution')) {
      add(
        id: 'schedulerExecutionFieldActive',
        severity: DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity
            .critical,
        message: '$fieldId would activate scheduler execution',
        validationRowId: row.validationRowId,
        fieldId: fieldId,
      );
    }
    if (fieldId == 'stockfishCommand' ||
        fieldId == 'rawUci' ||
        fieldId == 'pvDump' ||
        fieldId.toLowerCase().contains('stockfishcommand') ||
        fieldId.toLowerCase().contains('rawuci') ||
        fieldId.toLowerCase().contains('pvdump')) {
      add(
        id: 'stockfishRawUciPvDumpFieldActive',
        severity: DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity
            .critical,
        message: '$fieldId would expose a denied engine command or dump field',
        validationRowId: row.validationRowId,
        fieldId: fieldId,
      );
    }
  }
  if (row.role ==
          DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
              .coreRecordInspectionValidation &&
      (row.contextOnly || row.inactive)) {
    add(
      id: 'coreInspectionBoundaryViolation',
      severity:
          DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity.blocker,
      message: 'core inspection validation cannot be context-only or inactive',
      validationRowId: row.validationRowId,
    );
  }
  if (row.role ==
          DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
              .contextRecordInspectionValidation &&
      (!row.contextOnly || row.inactive)) {
    add(
      id: 'contextInspectionPromotedToCore',
      severity:
          DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity.blocker,
      message: 'context inspection validation must remain context-only',
      validationRowId: row.validationRowId,
    );
  }
  if (row.role ==
          DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
              .inactiveRecordInspectionValidation &&
      !row.inactive) {
    add(
      id: 'inactiveInspectionMadeActive',
      severity:
          DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity.blocker,
      message: 'inactive inspection validation must remain inactive',
      validationRowId: row.validationRowId,
    );
  }
  for (final proofId in row.androidProofCaseIds) {
    if (!provenAndroidIds.contains(proofId)) {
      add(
        id: 'unprovenAndroidProofId',
        severity:
            DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity.blocker,
        message: '$proofId is not captured Android proof',
        validationRowId: row.validationRowId,
        caseId: proofId,
      );
    }
    if (_phase32ECaseIds.contains(proofId)) {
      add(
        id: 'phase32ECaseClaimedAsCapturedProof',
        severity: DebugOnlyBridgeDeveloperInspectionHarnessValidationSeverity
            .critical,
        message: '$proofId cannot be treated as captured Android proof',
        validationRowId: row.validationRowId,
        caseId: proofId,
      );
    }
  }
}

DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
_validationRoleForInspectionRole(
  DebugOnlyBridgeDeveloperInspectionRowRole role,
) {
  return switch (role) {
    DebugOnlyBridgeDeveloperInspectionRowRole.inputPacketInspection =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
          .inputPacketInspectionValidation,
    DebugOnlyBridgeDeveloperInspectionRowRole.outputPacketInspection =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
          .outputPacketInspectionValidation,
    DebugOnlyBridgeDeveloperInspectionRowRole.policyInspection =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
          .policyInspectionValidation,
    DebugOnlyBridgeDeveloperInspectionRowRole.coreRecordInspection =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
          .coreRecordInspectionValidation,
    DebugOnlyBridgeDeveloperInspectionRowRole.contextRecordInspection =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
          .contextRecordInspectionValidation,
    DebugOnlyBridgeDeveloperInspectionRowRole.inactiveRecordInspection =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
          .inactiveRecordInspectionValidation,
    DebugOnlyBridgeDeveloperInspectionRowRole.allowedFieldBoundaryInspection =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
          .allowedFieldBoundaryInspectionValidation,
    DebugOnlyBridgeDeveloperInspectionRowRole.deniedFieldBoundaryInspection =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
          .deniedFieldBoundaryInspectionValidation,
    DebugOnlyBridgeDeveloperInspectionRowRole
        .stockfishRawUciPvDumpDeniedInspection =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
          .stockfishRawUciPvDumpDeniedInspectionValidation,
    DebugOnlyBridgeDeveloperInspectionRowRole.runtimeBlockedInspection =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
          .runtimeBlockedInspectionValidation,
    DebugOnlyBridgeDeveloperInspectionRowRole.proofBoundaryInspection =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
          .proofBoundaryInspectionValidation,
    DebugOnlyBridgeDeveloperInspectionRowRole.ownerProofBoundaryInspection =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
          .ownerProofBoundaryInspectionValidation,
    DebugOnlyBridgeDeveloperInspectionRowRole.futureRequirementInspection =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
          .futureRequirementInspectionValidation,
  };
}

DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
_validStatusForRole(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole role,
) {
  return switch (role) {
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .snapshotValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
          .validSnapshot,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .inputPacketInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
          .validInputPacketInspection,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .outputPacketInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
          .validOutputPacketInspection,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .policyInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
          .validPolicyInspection,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .coreRecordInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
          .validCoreInspection,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .contextRecordInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
          .validContextInspection,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .inactiveRecordInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
          .validInactiveInspection,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .allowedFieldBoundaryInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
          .validAllowedFieldBoundaryInspection,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .deniedFieldBoundaryInspectionValidation ||
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .stockfishRawUciPvDumpDeniedInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
          .validDeniedBoundaryInspection,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .runtimeBlockedInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
          .validRuntimeBlockedInspection,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .proofBoundaryInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
          .validProofBoundaryInspection,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .ownerProofBoundaryInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
          .validOwnerProofBoundaryInspection,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .futureRequirementInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus
          .validFutureRequirementInspection,
  };
}

DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
_recommendationForRole(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole role,
) {
  return switch (role) {
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .snapshotValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
          .keepSnapshotDeveloperOnly,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .inputPacketInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
          .keepInputPacketInspectionSafe,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .outputPacketInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
          .keepOutputPacketInspectionSafe,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .policyInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
          .keepPolicyInspectionSafe,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .coreRecordInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
          .keepCoreInspectionCore,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .contextRecordInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
          .keepContextInspectionContextOnly,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .inactiveRecordInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
          .keepInactiveInspectionInactive,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .allowedFieldBoundaryInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
          .keepAllowedFieldBoundaryInternal,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .deniedFieldBoundaryInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
          .keepDeniedBoundaryDenied,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .stockfishRawUciPvDumpDeniedInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
          .keepStockfishRawUciPvDumpDenied,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .runtimeBlockedInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
          .keepRuntimePrototypeWiringBlocked,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .proofBoundaryInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
          .keepProofBoundaryCapturedOnly,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .ownerProofBoundaryInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
          .keepOwnerProofEmpty,
    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
        .futureRequirementInspectionValidation =>
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRecommendation
          .requirePhase33JDiagnosticCommand,
  };
}

List<String> _inspectionRowFindings(DebugOnlyBridgeDeveloperInspectionRow row) {
  return _sortedStrings(<String>[
    ...row.findings,
    ..._rowFindings(
      developerOnly: row.developerOnly,
      skeletonOnly: row.skeletonOnly,
      allowedFieldIds: row.allowedFieldIds,
    ),
    if (row.status.isUnsafe) 'unsafe:sourceInspectionRowUnsafe',
    if (row.role ==
            DebugOnlyBridgeDeveloperInspectionRowRole.coreRecordInspection &&
        (row.contextOnly || row.inactive))
      'unsafe:coreInspectionBoundaryViolation',
    if (row.role ==
            DebugOnlyBridgeDeveloperInspectionRowRole.contextRecordInspection &&
        (!row.contextOnly || row.inactive))
      'unsafe:contextInspectionPromotedToCore',
    if (row.role ==
            DebugOnlyBridgeDeveloperInspectionRowRole
                .inactiveRecordInspection &&
        !row.inactive)
      'unsafe:inactiveInspectionMadeActive',
  ]);
}

List<String> _rowFindings({
  required bool developerOnly,
  required bool skeletonOnly,
  required Iterable<String> allowedFieldIds,
}) {
  return _sortedStrings(<String>[
    if (!developerOnly) 'unsafe:notDeveloperOnly',
    if (!skeletonOnly) 'unsafe:notSkeletonOnly',
    for (final fieldId in allowedFieldIds)
      if (_isDeniedFieldId(fieldId) || _isLegacyDeniedFieldId(fieldId))
        'unsafe:activeDeniedField:$fieldId',
  ]);
}

bool _rowHasSchedulerExecution(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationRow row,
) {
  return row.allowedFieldIds.contains('schedulerExecution') ||
      row.findings.any(
        (finding) => finding.toLowerCase().contains('schedulerexecution'),
      );
}

bool _hasExplicitPvProofReason(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  final reasons = <String>{
    ...result.snapshot.warningSummary,
    ...result.snapshot.futurePrerequisiteSummary,
    ...result.validationRows.expand((row) => row.warningReasons),
    ...result.validationRows.expand((row) => row.proofLimitReasons),
  }.map((reason) => reason.toLowerCase()).join(' ');
  return reasons.contains('owner proof pv') ||
      reasons.contains('owner proof multipv') ||
      reasons.contains('pv owner proof') ||
      reasons.contains('multipv owner proof') ||
      reasons.contains('explicit owner proof');
}

List<DebugOnlyBridgeDeveloperInspectionHarnessValidationRow> _rowsFor(
  List<DebugOnlyBridgeDeveloperInspectionHarnessValidationRow> rows,
  DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole role,
) {
  return rows.where((row) => row.role == role).toList(growable: false);
}

int _countRole(
  List<DebugOnlyBridgeDeveloperInspectionHarnessValidationRow> rows,
  DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole role,
) {
  return rows.where((row) => row.role == role).length;
}

int _countStatus(
  List<DebugOnlyBridgeDeveloperInspectionHarnessValidationRow> rows,
  DebugOnlyBridgeDeveloperInspectionHarnessValidationRowStatus status,
) {
  return rows.where((row) => row.status == status).length;
}

List<String> _provenAndroidProofIds(
  GoldenAndroidProofEvidence? androidProofEvidence,
) {
  final evidence = androidProofEvidence;
  if (evidence == null) return const <String>[];
  return _sortedStrings(
    evidence.targetCaseIds.where(
      (caseId) => evidence.isRealDeviceProofCapturedFor(caseId),
    ),
  );
}

Set<String> get _phase32ECaseIds => GoldenAnalysisCases.defaults
    .where((item) => item.id.endsWith('-32e'))
    .map((item) => item.id)
    .toSet();

bool _sameStringSet(Iterable<String> a, Iterable<String> b) {
  final left = _sortedStrings(a);
  final right = _sortedStrings(b);
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i += 1) {
    if (left[i] != right[i]) return false;
  }
  return true;
}

bool _isDeniedFieldId(String fieldId) => _deniedFieldIds.contains(fieldId);

bool _isLegacyDeniedFieldId(String fieldId) {
  final lower = fieldId.toLowerCase();
  return lower.contains('productlabel') ||
      lower.contains('finalmovelabel') ||
      lower.contains('classifier') ||
      lower.contains('brilliant') ||
      lower.contains('great') ||
      lower.contains('miss') ||
      lower.contains('bestgoodinaccuracy') ||
      lower.contains('numericmovescore') ||
      lower.contains('aggregatescore') ||
      lower.contains('officialaccuracy') ||
      lower.contains('acpl') ||
      lower.contains('cploss') ||
      lower.contains('winprobability') ||
      lower.contains('ranking') ||
      lower == 'uitarget' ||
      lower.contains('uioutput') ||
      lower.contains('uiintegration') ||
      lower.contains('backend') ||
      lower.contains('persistence') ||
      lower.contains('database') ||
      lower.contains('cache') ||
      lower.contains('directengine') ||
      lower.contains('enginecall') ||
      lower.contains('stockfishcommand') ||
      lower.contains('rawuci') ||
      lower.contains('pvdump') ||
      lower.contains('schedulerexecution');
}

int _compareFindings(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding a,
  DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding b,
) {
  final severity = b.severity.index.compareTo(a.severity.index);
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.validationRowId ?? '').compareTo(b.validationRowId ?? '');
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.where((value) => value.trim().isNotEmpty).toSet().toList()
    ..sort();
}

String _ids(Iterable<String> values) {
  final sorted = _sortedStrings(values);
  return sorted.isEmpty ? 'none' : sorted.join(', ');
}

String _rowSummary(DebugOnlyBridgeDeveloperInspectionHarnessValidationRow row) {
  return [
    '- row: ${row.validationRowId}',
    '- role: ${row.role.wire}',
    '- status: ${row.status.wire}',
    '- source inspection row: ${row.sourceInspectionRowId}',
    '- source packet: ${row.sourcePacketId}',
    '- allowed field IDs: ${_ids(row.allowedFieldIds)}',
    '- denied field IDs: ${_ids(row.deniedFieldIds)}',
    '- developer-only: ${row.developerOnly}',
    '- skeleton-only: ${row.skeletonOnly}',
    '- context-only: ${row.contextOnly}',
    '- inactive: ${row.inactive}',
    '- findings: ${_ids(row.findings)}',
  ].join('\n');
}

String _cell(String value) =>
    value.replaceAll('|', r'\|').replaceAll('\n', ' ');

const _capturedAndroidProofIds = <String>[
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
];

const _deniedFieldIds = <String>[
  'acpl',
  'aggregateScore',
  'backendOutput',
  'bestGoodInaccuracyMistakeBlunderStyleLabels',
  'brilliantGreatMissStyleLabels',
  'cpLoss',
  'directEngineCall',
  'finalMoveLabel',
  'moveRanking',
  'numericMoveScore',
  'officialAccuracy',
  'persistenceOutput',
  'productLabel',
  'pvDump',
  'rawUci',
  'schedulerExecution',
  'stockfishCommand',
  'uiOutput',
  'winProbability',
];

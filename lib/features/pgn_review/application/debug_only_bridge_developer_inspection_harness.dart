/// Developer-only inspection harness for the debug-only bridge skeleton.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_skeleton.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_skeleton_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_implementation_design.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugOnlyBridgeDeveloperInspectionHarnessReportVersion =
    'debug-only-bridge-developer-inspection-harness-v1';
const debugOnlyBridgeDeveloperInspectionSnapshotVersion =
    'phase33h-developer-inspection-snapshot-v1';

enum DebugOnlyBridgeDeveloperInspectionHarnessStatus {
  inspectionReadyWithWarnings('inspectionReadyWithWarnings'),
  inspectionReadyClean('inspectionReadyClean'),
  blockedByUnsafeSkeletonValidation('blockedByUnsafeSkeletonValidation'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const DebugOnlyBridgeDeveloperInspectionHarnessStatus(this.wire);

  final String wire;
}

enum DebugOnlyBridgeDeveloperInspectionRowRole {
  inputPacketInspection('inputPacketInspection'),
  outputPacketInspection('outputPacketInspection'),
  policyInspection('policyInspection'),
  coreRecordInspection('coreRecordInspection'),
  contextRecordInspection('contextRecordInspection'),
  inactiveRecordInspection('inactiveRecordInspection'),
  allowedFieldBoundaryInspection('allowedFieldBoundaryInspection'),
  deniedFieldBoundaryInspection('deniedFieldBoundaryInspection'),
  stockfishRawUciPvDumpDeniedInspection(
    'stockfishRawUciPvDumpDeniedInspection',
  ),
  runtimeBlockedInspection('runtimeBlockedInspection'),
  proofBoundaryInspection('proofBoundaryInspection'),
  ownerProofBoundaryInspection('ownerProofBoundaryInspection'),
  futureRequirementInspection('futureRequirementInspection');

  const DebugOnlyBridgeDeveloperInspectionRowRole(this.wire);

  final String wire;

  bool get isRecordInspection =>
      this != inputPacketInspection &&
      this != outputPacketInspection &&
      this != policyInspection;
}

enum DebugOnlyBridgeDeveloperInspectionRowStatus {
  inspected('inspected'),
  inspectedWithFindings('inspectedWithFindings'),
  blockedByBoundary('blockedByBoundary'),
  invalid('invalid');

  const DebugOnlyBridgeDeveloperInspectionRowStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == blockedByBoundary || this == invalid;
}

enum DebugOnlyBridgeDeveloperInspectionSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const DebugOnlyBridgeDeveloperInspectionSeverity(this.wire);

  final String wire;

  bool get blocksStrict => this == blocker || this == critical;

  bool get isCritical => this == critical;
}

enum DebugOnlyBridgeDeveloperInspectionRecommendation {
  keepInspectionDeveloperOnly('keepInspectionDeveloperOnly'),
  keepInputPacketInternal('keepInputPacketInternal'),
  keepOutputPacketDeveloperOnly('keepOutputPacketDeveloperOnly'),
  keepPolicyDenied('keepPolicyDenied'),
  keepCoreRecordInspectableOnly('keepCoreRecordInspectableOnly'),
  keepContextRecordContextOnly('keepContextRecordContextOnly'),
  keepInactiveRecordInactive('keepInactiveRecordInactive'),
  keepAllowedFieldBoundaryInternal('keepAllowedFieldBoundaryInternal'),
  keepDeniedBoundaryDenied('keepDeniedBoundaryDenied'),
  keepStockfishRawUciPvDumpDenied('keepStockfishRawUciPvDumpDenied'),
  keepRuntimePrototypeWiringBlocked('keepRuntimePrototypeWiringBlocked'),
  keepProofBoundaryCapturedOnly('keepProofBoundaryCapturedOnly'),
  keepOwnerProofEmpty('keepOwnerProofEmpty'),
  requirePhase33IInspectionHarnessValidation(
    'requirePhase33IInspectionHarnessValidation',
  ),
  investigateInspectionHarnessFailure('investigateInspectionHarnessFailure'),
  blockUnsafeInspectionHarness('blockUnsafeInspectionHarness');

  const DebugOnlyBridgeDeveloperInspectionRecommendation(this.wire);

  final String wire;
}

enum DebugOnlyBridgeDeveloperInspectionPhase33IRecommendation {
  validateDebugOnlyBridgeDeveloperInspectionHarness(
    'validateDebugOnlyBridgeDeveloperInspectionHarness',
  ),
  proceedToDebugOnlyBridgeDeveloperInspectionReportOnly(
    'proceedToDebugOnlyBridgeDeveloperInspectionReportOnly',
  ),
  proceedToInspectionHarnessHardening('proceedToInspectionHarnessHardening'),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeInspectionHarness('blockedByUnsafeInspectionHarness');

  const DebugOnlyBridgeDeveloperInspectionPhase33IRecommendation(this.wire);

  final String wire;
}

enum DebugOnlyBridgeDeveloperInspectionHarnessReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeDeveloperInspectionHarnessReportFormat(this.wire);

  final String wire;
}

class DebugOnlyBridgeDeveloperInspectionHarnessRequest {
  const DebugOnlyBridgeDeveloperInspectionHarnessRequest({
    this.skeletonValidationResult,
    this.skeletonResult,
    this.inputPacket,
    this.outputPacket,
    this.policy,
    this.implementationDesignResult,
    this.skeletonValidation =
        const DebugOnlyBridgeDeveloperSkeletonValidation(),
    this.skeleton = const DebugOnlyBridgeSkeleton(),
    this.implementationDesign = const DebugOnlyBridgeImplementationDesign(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const DebugOnlyBridgeDeveloperInspectionHarnessRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final DebugOnlyBridgeDeveloperSkeletonValidationResult?
  skeletonValidationResult;
  final DebugOnlyBridgeSkeletonResult? skeletonResult;
  final DebugOnlyBridgeInputPacket? inputPacket;
  final DebugOnlyBridgeOutputPacket? outputPacket;
  final DebugOnlyBridgePolicy? policy;
  final DebugOnlyBridgeImplementationDesignResult? implementationDesignResult;
  final DebugOnlyBridgeDeveloperSkeletonValidation skeletonValidation;
  final DebugOnlyBridgeSkeleton skeleton;
  final DebugOnlyBridgeImplementationDesign implementationDesign;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class DebugOnlyBridgeDeveloperInspectionSnapshot {
  const DebugOnlyBridgeDeveloperInspectionSnapshot({
    required this.snapshotId,
    required this.sourceValidationId,
    required this.sourceSkeletonResultId,
    required this.inputPacketId,
    required this.outputPacketId,
    required this.skeletonVersion,
    required this.policySummary,
    required this.packetSummary,
    required this.recordRoleSummary,
    required this.allowedFieldSummary,
    required this.deniedFieldSummary,
    required this.proofBoundarySummary,
    required this.runtimeBoundarySummary,
    required this.blockedBoundarySummary,
    required this.warningSummary,
    required this.futurePrerequisiteSummary,
    required this.recommendation,
    this.developerOnly = true,
    this.skeletonOnly = true,
  });

  final String snapshotId;
  final String sourceValidationId;
  final String sourceSkeletonResultId;
  final String inputPacketId;
  final String outputPacketId;
  final String skeletonVersion;
  final Map<String, Object?> policySummary;
  final Map<String, Object?> packetSummary;
  final Map<String, int> recordRoleSummary;
  final List<String> allowedFieldSummary;
  final List<String> deniedFieldSummary;
  final List<String> proofBoundarySummary;
  final List<String> runtimeBoundarySummary;
  final List<String> blockedBoundarySummary;
  final List<String> warningSummary;
  final List<String> futurePrerequisiteSummary;
  final DebugOnlyBridgeDeveloperInspectionRecommendation recommendation;
  final bool developerOnly;
  final bool skeletonOnly;

  bool get hasUnsafeInspectionOutput =>
      !developerOnly ||
      !skeletonOnly ||
      allowedFieldSummary.any(_isDeniedFieldId) ||
      allowedFieldSummary.any(_isLegacyDeniedFieldId);

  DebugOnlyBridgeDeveloperInspectionSnapshot copyWith({
    String? snapshotId,
    String? sourceValidationId,
    String? sourceSkeletonResultId,
    String? inputPacketId,
    String? outputPacketId,
    String? skeletonVersion,
    Map<String, Object?>? policySummary,
    Map<String, Object?>? packetSummary,
    Map<String, int>? recordRoleSummary,
    List<String>? allowedFieldSummary,
    List<String>? deniedFieldSummary,
    List<String>? proofBoundarySummary,
    List<String>? runtimeBoundarySummary,
    List<String>? blockedBoundarySummary,
    List<String>? warningSummary,
    List<String>? futurePrerequisiteSummary,
    DebugOnlyBridgeDeveloperInspectionRecommendation? recommendation,
    bool? developerOnly,
    bool? skeletonOnly,
  }) {
    return DebugOnlyBridgeDeveloperInspectionSnapshot(
      snapshotId: snapshotId ?? this.snapshotId,
      sourceValidationId: sourceValidationId ?? this.sourceValidationId,
      sourceSkeletonResultId:
          sourceSkeletonResultId ?? this.sourceSkeletonResultId,
      inputPacketId: inputPacketId ?? this.inputPacketId,
      outputPacketId: outputPacketId ?? this.outputPacketId,
      skeletonVersion: skeletonVersion ?? this.skeletonVersion,
      policySummary: policySummary ?? this.policySummary,
      packetSummary: packetSummary ?? this.packetSummary,
      recordRoleSummary: recordRoleSummary ?? this.recordRoleSummary,
      allowedFieldSummary: allowedFieldSummary ?? this.allowedFieldSummary,
      deniedFieldSummary: deniedFieldSummary ?? this.deniedFieldSummary,
      proofBoundarySummary: proofBoundarySummary ?? this.proofBoundarySummary,
      runtimeBoundarySummary:
          runtimeBoundarySummary ?? this.runtimeBoundarySummary,
      blockedBoundarySummary:
          blockedBoundarySummary ?? this.blockedBoundarySummary,
      warningSummary: warningSummary ?? this.warningSummary,
      futurePrerequisiteSummary:
          futurePrerequisiteSummary ?? this.futurePrerequisiteSummary,
      recommendation: recommendation ?? this.recommendation,
      developerOnly: developerOnly ?? this.developerOnly,
      skeletonOnly: skeletonOnly ?? this.skeletonOnly,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'snapshotId': snapshotId,
    'sourceValidationId': sourceValidationId,
    'sourceSkeletonResultId': sourceSkeletonResultId,
    'inputPacketId': inputPacketId,
    'outputPacketId': outputPacketId,
    'skeletonVersion': skeletonVersion,
    'policySummary': policySummary,
    'packetSummary': packetSummary,
    'recordRoleSummary': recordRoleSummary,
    'allowedFieldSummary': allowedFieldSummary,
    'deniedFieldSummary': deniedFieldSummary,
    'proofBoundarySummary': proofBoundarySummary,
    'runtimeBoundarySummary': runtimeBoundarySummary,
    'blockedBoundarySummary': blockedBoundarySummary,
    'warningSummary': warningSummary,
    'futurePrerequisiteSummary': futurePrerequisiteSummary,
    'recommendation': recommendation.wire,
    'developerOnly': developerOnly,
    'skeletonOnly': skeletonOnly,
  };
}

class DebugOnlyBridgeDeveloperInspectionRow {
  const DebugOnlyBridgeDeveloperInspectionRow({
    required this.inspectionRowId,
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

  final String inspectionRowId;
  final String sourceRecordId;
  final String sourcePacketId;
  final DebugOnlyBridgeDeveloperInspectionRowRole role;
  final DebugOnlyBridgeDeveloperInspectionRowStatus status;
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
  final DebugOnlyBridgeDeveloperInspectionRecommendation recommendation;

  bool get hasActiveDeniedField =>
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId);

  bool get hasUnsafeOutput =>
      status.isUnsafe ||
      !developerOnly ||
      !skeletonOnly ||
      hasActiveDeniedField ||
      findings.any((finding) => finding.startsWith('unsafe:'));

  DebugOnlyBridgeDeveloperInspectionRow copyWith({
    String? inspectionRowId,
    String? sourceRecordId,
    String? sourcePacketId,
    DebugOnlyBridgeDeveloperInspectionRowRole? role,
    DebugOnlyBridgeDeveloperInspectionRowStatus? status,
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
    DebugOnlyBridgeDeveloperInspectionRecommendation? recommendation,
  }) {
    return DebugOnlyBridgeDeveloperInspectionRow(
      inspectionRowId: inspectionRowId ?? this.inspectionRowId,
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
    'inspectionRowId': inspectionRowId,
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

class DebugOnlyBridgeDeveloperInspectionHarnessFinding {
  const DebugOnlyBridgeDeveloperInspectionHarnessFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.inspectionRowId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final DebugOnlyBridgeDeveloperInspectionSeverity severity;
  final String message;
  final String? inspectionRowId;
  final String? fieldId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical => severity.isCritical;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'severity': severity.wire,
    'message': message,
    if (inspectionRowId != null) 'inspectionRowId': inspectionRowId,
    if (fieldId != null) 'fieldId': fieldId,
    if (caseId != null) 'caseId': caseId,
  };
}

class DebugOnlyBridgeDeveloperInspectionHarnessResult {
  const DebugOnlyBridgeDeveloperInspectionHarnessResult({
    required this.status,
    required this.sourceSkeletonValidationStatus,
    required this.sourceSkeletonStatus,
    required this.skeletonValidationResult,
    required this.skeletonResult,
    required this.implementationDesignResult,
    required this.inputPacket,
    required this.outputPacket,
    required this.policy,
    required this.snapshot,
    required this.inspectionRows,
    required this.inspectionFindings,
    required this.warnings,
    required this.failures,
    required this.totalInspectionRows,
    required this.inputPacketInspectionCount,
    required this.outputPacketInspectionCount,
    required this.policyInspectionCount,
    required this.recordInspectionCount,
    required this.coreRecordInspectionCount,
    required this.contextRecordInspectionCount,
    required this.inactiveRecordInspectionCount,
    required this.deniedBoundaryInspectionCount,
    required this.runtimeBlockedInspectionCount,
    required this.proofBoundaryInspectionCount,
    required this.unsafeCount,
    required this.blockerCount,
    required this.criticalCount,
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
    required this.safeForPhase33I,
    required this.phase33IRecommendation,
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

  final DebugOnlyBridgeDeveloperInspectionHarnessStatus status;
  final DebugOnlyBridgeDeveloperSkeletonValidationStatus
  sourceSkeletonValidationStatus;
  final DebugOnlyBridgeSkeletonStatus sourceSkeletonStatus;
  final DebugOnlyBridgeDeveloperSkeletonValidationResult
  skeletonValidationResult;
  final DebugOnlyBridgeSkeletonResult skeletonResult;
  final DebugOnlyBridgeImplementationDesignResult implementationDesignResult;
  final DebugOnlyBridgeInputPacket inputPacket;
  final DebugOnlyBridgeOutputPacket outputPacket;
  final DebugOnlyBridgePolicy policy;
  final DebugOnlyBridgeDeveloperInspectionSnapshot snapshot;
  final List<DebugOnlyBridgeDeveloperInspectionRow> inspectionRows;
  final List<DebugOnlyBridgeDeveloperInspectionHarnessFinding>
  inspectionFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalInspectionRows;
  final int inputPacketInspectionCount;
  final int outputPacketInspectionCount;
  final int policyInspectionCount;
  final int recordInspectionCount;
  final int coreRecordInspectionCount;
  final int contextRecordInspectionCount;
  final int inactiveRecordInspectionCount;
  final int deniedBoundaryInspectionCount;
  final int runtimeBlockedInspectionCount;
  final int proofBoundaryInspectionCount;
  final int unsafeCount;
  final int blockerCount;
  final int criticalCount;
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
  final bool safeForPhase33I;
  final DebugOnlyBridgeDeveloperInspectionPhase33IRecommendation
  phase33IRecommendation;
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
          DebugOnlyBridgeDeveloperInspectionHarnessStatus
              .blockedByUnsafeSkeletonValidation ||
      status ==
          DebugOnlyBridgeDeveloperInspectionHarnessStatus
              .blockedByPolicyBoundary ||
      status == DebugOnlyBridgeDeveloperInspectionHarnessStatus.invalid ||
      unsafeCount > 0 ||
      blockerCount > 0 ||
      criticalCount > 0;

  bool get hasUnsafeDebugOnlyBridgeDeveloperInspectionHarnessPolicyViolation =>
      status ==
          DebugOnlyBridgeDeveloperInspectionHarnessStatus
              .blockedByUnsafeSkeletonValidation ||
      status ==
          DebugOnlyBridgeDeveloperInspectionHarnessStatus
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

  List<DebugOnlyBridgeDeveloperInspectionRow> rowsForRole(
    DebugOnlyBridgeDeveloperInspectionRowRole role,
  ) {
    return inspectionRows
        .where((row) => row.role == role)
        .toList(growable: false);
  }

  DebugOnlyBridgeDeveloperInspectionRow rowForRole(
    DebugOnlyBridgeDeveloperInspectionRowRole role,
  ) {
    return rowsForRole(role).first;
  }

  DebugOnlyBridgeDeveloperInspectionHarnessResult copyWith({
    DebugOnlyBridgeDeveloperInspectionHarnessStatus? status,
    DebugOnlyBridgeDeveloperSkeletonValidationStatus?
    sourceSkeletonValidationStatus,
    DebugOnlyBridgeSkeletonStatus? sourceSkeletonStatus,
    DebugOnlyBridgeDeveloperSkeletonValidationResult? skeletonValidationResult,
    DebugOnlyBridgeSkeletonResult? skeletonResult,
    DebugOnlyBridgeImplementationDesignResult? implementationDesignResult,
    DebugOnlyBridgeInputPacket? inputPacket,
    DebugOnlyBridgeOutputPacket? outputPacket,
    DebugOnlyBridgePolicy? policy,
    DebugOnlyBridgeDeveloperInspectionSnapshot? snapshot,
    List<DebugOnlyBridgeDeveloperInspectionRow>? inspectionRows,
    List<DebugOnlyBridgeDeveloperInspectionHarnessFinding>? inspectionFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalInspectionRows,
    int? inputPacketInspectionCount,
    int? outputPacketInspectionCount,
    int? policyInspectionCount,
    int? recordInspectionCount,
    int? coreRecordInspectionCount,
    int? contextRecordInspectionCount,
    int? inactiveRecordInspectionCount,
    int? deniedBoundaryInspectionCount,
    int? runtimeBlockedInspectionCount,
    int? proofBoundaryInspectionCount,
    int? unsafeCount,
    int? blockerCount,
    int? criticalCount,
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
    bool? safeForPhase33I,
    DebugOnlyBridgeDeveloperInspectionPhase33IRecommendation?
    phase33IRecommendation,
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
    return DebugOnlyBridgeDeveloperInspectionHarnessResult(
      status: status ?? this.status,
      sourceSkeletonValidationStatus:
          sourceSkeletonValidationStatus ?? this.sourceSkeletonValidationStatus,
      sourceSkeletonStatus: sourceSkeletonStatus ?? this.sourceSkeletonStatus,
      skeletonValidationResult:
          skeletonValidationResult ?? this.skeletonValidationResult,
      skeletonResult: skeletonResult ?? this.skeletonResult,
      implementationDesignResult:
          implementationDesignResult ?? this.implementationDesignResult,
      inputPacket: inputPacket ?? this.inputPacket,
      outputPacket: outputPacket ?? this.outputPacket,
      policy: policy ?? this.policy,
      snapshot: snapshot ?? this.snapshot,
      inspectionRows: inspectionRows ?? this.inspectionRows,
      inspectionFindings: inspectionFindings ?? this.inspectionFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalInspectionRows: totalInspectionRows ?? this.totalInspectionRows,
      inputPacketInspectionCount:
          inputPacketInspectionCount ?? this.inputPacketInspectionCount,
      outputPacketInspectionCount:
          outputPacketInspectionCount ?? this.outputPacketInspectionCount,
      policyInspectionCount:
          policyInspectionCount ?? this.policyInspectionCount,
      recordInspectionCount:
          recordInspectionCount ?? this.recordInspectionCount,
      coreRecordInspectionCount:
          coreRecordInspectionCount ?? this.coreRecordInspectionCount,
      contextRecordInspectionCount:
          contextRecordInspectionCount ?? this.contextRecordInspectionCount,
      inactiveRecordInspectionCount:
          inactiveRecordInspectionCount ?? this.inactiveRecordInspectionCount,
      deniedBoundaryInspectionCount:
          deniedBoundaryInspectionCount ?? this.deniedBoundaryInspectionCount,
      runtimeBlockedInspectionCount:
          runtimeBlockedInspectionCount ?? this.runtimeBlockedInspectionCount,
      proofBoundaryInspectionCount:
          proofBoundaryInspectionCount ?? this.proofBoundaryInspectionCount,
      unsafeCount: unsafeCount ?? this.unsafeCount,
      blockerCount: blockerCount ?? this.blockerCount,
      criticalCount: criticalCount ?? this.criticalCount,
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
      safeForPhase33I: safeForPhase33I ?? this.safeForPhase33I,
      phase33IRecommendation:
          phase33IRecommendation ?? this.phase33IRecommendation,
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
      ..writeln('# Debug-Only Bridge Developer Inspection Harness')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeDeveloperInspectionHarnessReportVersion',
      )
      ..writeln('- inspection status: ${status.wire}')
      ..writeln(
        '- source skeleton validation status: '
        '${sourceSkeletonValidationStatus.wire}',
      )
      ..writeln('- source skeleton status: ${sourceSkeletonStatus.wire}')
      ..writeln('- total inspection rows: $totalInspectionRows')
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
      ..writeln('- safeForPhase33I: $safeForPhase33I')
      ..writeln('- Phase 33I recommendation: ${phase33IRecommendation.wire}')
      ..writeln()
      ..writeln('## Inspection Snapshot Summary')
      ..writeln('- snapshot ID: ${snapshot.snapshotId}')
      ..writeln('- input packet ID: ${snapshot.inputPacketId}')
      ..writeln('- output packet ID: ${snapshot.outputPacketId}')
      ..writeln('- skeleton version: ${snapshot.skeletonVersion}')
      ..writeln(
        '- record role summary: '
        '${_summaryMap(snapshot.recordRoleSummary)}',
      )
      ..writeln()
      ..writeln('## Input Packet Inspection')
      ..writeln(
        _rowSummary(
          rowForRole(
            DebugOnlyBridgeDeveloperInspectionRowRole.inputPacketInspection,
          ),
        ),
      )
      ..writeln()
      ..writeln('## Output Packet Inspection')
      ..writeln(
        _rowSummary(
          rowForRole(
            DebugOnlyBridgeDeveloperInspectionRowRole.outputPacketInspection,
          ),
        ),
      )
      ..writeln()
      ..writeln('## Policy Inspection')
      ..writeln(
        _rowSummary(
          rowForRole(
            DebugOnlyBridgeDeveloperInspectionRowRole.policyInspection,
          ),
        ),
      )
      ..writeln()
      ..writeln('## Bridge Record Inspection Table')
      ..writeln(
        '| Row | Role | Source record | Allowed field IDs | Denied field IDs | Developer-only | Skeleton-only | Context-only | Inactive | Findings |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in inspectionRows.where(
      (row) => row.role.isRecordInspection,
    )) {
      buffer.writeln(
        '| ${row.inspectionRowId} | ${row.role.wire} | '
        '${row.sourceRecordId} | ${_ids(row.allowedFieldIds)} | '
        '${_ids(row.deniedFieldIds)} | ${row.developerOnly} | '
        '${row.skeletonOnly} | ${row.contextOnly} | ${row.inactive} | '
        '${_ids(row.findings)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Allowed/Denied Field Boundary Inspection')
      ..writeln('- allowed field IDs: ${_ids(snapshot.allowedFieldSummary)}')
      ..writeln('- denied field IDs: ${_ids(snapshot.deniedFieldSummary)}')
      ..writeln()
      ..writeln('## Stockfish/Raw UCI/PV Denial Inspection')
      ..writeln('- Stockfish command leak count: $stockfishCommandLeakCount')
      ..writeln('- raw UCI leak count: $rawUciLeakCount')
      ..writeln('- PV dump leak count: $pvDumpLeakCount')
      ..writeln()
      ..writeln('## Runtime/Prototype/Wiring Blocked Inspection')
      ..writeln(
        '- runtime boundary summary: '
        '${_ids(snapshot.runtimeBoundarySummary)}',
      )
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
      ..writeln('- captured proof IDs: ${_ids(snapshot.proofBoundarySummary)}')
      ..writeln()
      ..writeln('## Owner Proof Boundary')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Findings');
    if (inspectionFindings.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final finding in inspectionFindings) {
        buffer.writeln(
          '- ${finding.severity.wire}: ${finding.id}: '
          '${_cell(finding.message)}',
        );
      }
    }
    buffer
      ..writeln()
      ..writeln('## Phase 33I Recommendation')
      ..writeln('- ${phase33IRecommendation.wire}');
    return buffer.toString();
  }

  String renderJsonReport() {
    return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'version': debugOnlyBridgeDeveloperInspectionHarnessReportVersion,
      'snapshotVersion': debugOnlyBridgeDeveloperInspectionSnapshotVersion,
      'status': status.wire,
      'sourceSkeletonValidationStatus': sourceSkeletonValidationStatus.wire,
      'sourceSkeletonStatus': sourceSkeletonStatus.wire,
      'snapshot': snapshot.toJson(),
      'inspectionRows': inspectionRows.map((row) => row.toJson()).toList(),
      'inspectionFindings': inspectionFindings
          .map((finding) => finding.toJson())
          .toList(),
      'warnings': warnings,
      'failures': failures,
      'totalInspectionRows': totalInspectionRows,
      'inputPacketInspectionCount': inputPacketInspectionCount,
      'outputPacketInspectionCount': outputPacketInspectionCount,
      'policyInspectionCount': policyInspectionCount,
      'recordInspectionCount': recordInspectionCount,
      'coreRecordInspectionCount': coreRecordInspectionCount,
      'contextRecordInspectionCount': contextRecordInspectionCount,
      'inactiveRecordInspectionCount': inactiveRecordInspectionCount,
      'deniedBoundaryInspectionCount': deniedBoundaryInspectionCount,
      'runtimeBlockedInspectionCount': runtimeBlockedInspectionCount,
      'proofBoundaryInspectionCount': proofBoundaryInspectionCount,
      'unsafeCount': unsafeCount,
      'blockerCount': blockerCount,
      'criticalCount': criticalCount,
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
      'safeForPhase33I': safeForPhase33I,
      'phase33IRecommendation': phase33IRecommendation.wire,
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

class DebugOnlyBridgeDeveloperInspectionHarness {
  const DebugOnlyBridgeDeveloperInspectionHarness({
    this.validator = const DebugOnlyBridgeDeveloperInspectionHarnessValidator(),
  });

  final DebugOnlyBridgeDeveloperInspectionHarnessValidator validator;

  DebugOnlyBridgeDeveloperInspectionHarnessResult inspectSafeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
    bool includeWarnings = true,
  }) {
    return evaluate(
      DebugOnlyBridgeDeveloperInspectionHarnessRequest.safeDemo(
        cases: cases,
        includeWarnings: includeWarnings,
      ),
    );
  }

  DebugOnlyBridgeDeveloperInspectionHarnessResult evaluate([
    DebugOnlyBridgeDeveloperInspectionHarnessRequest request =
        const DebugOnlyBridgeDeveloperInspectionHarnessRequest(),
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
    final skeletonValidationResult =
        request.skeletonValidationResult ??
        request.skeletonValidation.evaluate(
          DebugOnlyBridgeDeveloperSkeletonValidationRequest(
            skeletonResult: effectiveSkeletonResult,
            inputPacket: inputPacket,
            outputPacket: outputPacket,
            policy: policy,
            implementationDesignResult: implementationDesignResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    return inspectSkeletonResult(
      skeletonValidationResult: skeletonValidationResult,
      skeletonResult: effectiveSkeletonResult,
      inputPacket: inputPacket,
      outputPacket: outputPacket,
      policy: policy,
      implementationDesignResult: implementationDesignResult,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
  }

  DebugOnlyBridgeDeveloperInspectionHarnessResult inspectSkeletonResult({
    required DebugOnlyBridgeDeveloperSkeletonValidationResult
    skeletonValidationResult,
    required DebugOnlyBridgeSkeletonResult skeletonResult,
    DebugOnlyBridgeInputPacket? inputPacket,
    DebugOnlyBridgeOutputPacket? outputPacket,
    DebugOnlyBridgePolicy? policy,
    DebugOnlyBridgeImplementationDesignResult? implementationDesignResult,
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final effectiveInputPacket = inputPacket ?? skeletonResult.inputPacket;
    final effectivePolicy = policy ?? skeletonResult.policy;
    final effectiveOutputPacket =
        outputPacket ??
        skeletonResult.outputPacket.copyWith(policy: effectivePolicy);
    final effectiveSkeletonResult = skeletonResult.copyWith(
      inputPacket: effectiveInputPacket,
      outputPacket: effectiveOutputPacket,
      policy: effectivePolicy,
    );
    final effectiveImplementationDesignResult =
        implementationDesignResult ??
        skeletonValidationResult.implementationDesignResult;
    final snapshot = buildInspectionSnapshot(
      skeletonValidationResult: skeletonValidationResult,
      skeletonResult: effectiveSkeletonResult,
      inputPacket: effectiveInputPacket,
      outputPacket: effectiveOutputPacket,
      policy: effectivePolicy,
    );
    final rows = <DebugOnlyBridgeDeveloperInspectionRow>[
      inspectInputPacket(effectiveInputPacket),
      inspectOutputPacket(effectiveOutputPacket),
      inspectPolicy(effectivePolicy),
      ...inspectRecords(effectiveOutputPacket),
    ];
    final base = _resultFromInspection(
      skeletonValidationResult: skeletonValidationResult,
      skeletonResult: effectiveSkeletonResult,
      implementationDesignResult: effectiveImplementationDesignResult,
      inputPacket: effectiveInputPacket,
      outputPacket: effectiveOutputPacket,
      policy: effectivePolicy,
      snapshot: snapshot,
      inspectionRows: rows,
      inspectionFindings:
          const <DebugOnlyBridgeDeveloperInspectionHarnessFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: cases,
      androidProofEvidence: androidProofEvidence,
    );
    return _resultFromInspection(
      skeletonValidationResult: skeletonValidationResult,
      skeletonResult: effectiveSkeletonResult,
      implementationDesignResult: effectiveImplementationDesignResult,
      inputPacket: effectiveInputPacket,
      outputPacket: effectiveOutputPacket,
      policy: effectivePolicy,
      snapshot: snapshot,
      inspectionRows: rows,
      inspectionFindings: findings,
    );
  }

  DebugOnlyBridgeDeveloperInspectionSnapshot buildInspectionSnapshot({
    required DebugOnlyBridgeDeveloperSkeletonValidationResult
    skeletonValidationResult,
    required DebugOnlyBridgeSkeletonResult skeletonResult,
    required DebugOnlyBridgeInputPacket inputPacket,
    required DebugOnlyBridgeOutputPacket outputPacket,
    required DebugOnlyBridgePolicy policy,
  }) {
    return DebugOnlyBridgeDeveloperInspectionSnapshot(
      snapshotId: 'phase33h-debug-only-bridge-developer-inspection-snapshot',
      sourceValidationId:
          debugOnlyBridgeDeveloperSkeletonValidationReportVersion,
      sourceSkeletonResultId: debugOnlyBridgeDeveloperSkeletonReportVersion,
      inputPacketId: inputPacket.inputPacketId,
      outputPacketId: outputPacket.outputPacketId,
      skeletonVersion: outputPacket.skeletonVersion,
      policySummary: <String, Object?>{
        'allowProductOutput': policy.allowProductOutput,
        'allowClassifierLabels': policy.allowClassifierLabels,
        'allowNumericScores': policy.allowNumericScores,
        'allowAggregateScores': policy.allowAggregateScores,
        'allowOfficialMetrics': policy.allowOfficialMetrics,
        'allowCpLoss': policy.allowCpLoss,
        'allowWinProbability': policy.allowWinProbability,
        'allowMoveRanking': policy.allowMoveRanking,
        'allowUi': policy.allowUi,
        'allowBackend': policy.allowBackend,
        'allowPersistence': policy.allowPersistence,
        'allowDirectEngine': policy.allowDirectEngine,
        'allowStockfishCommand': policy.allowStockfishCommand,
        'allowRawUci': policy.allowRawUci,
        'allowPvDump': policy.allowPvDump,
        'allowRuntime': policy.allowRuntime,
        'allowExecutablePrototype': policy.allowExecutablePrototype,
        'allowWiring': policy.allowWiring,
      },
      packetSummary: <String, Object?>{
        'inputPacketId': inputPacket.inputPacketId,
        'outputPacketId': outputPacket.outputPacketId,
        'safeForDeveloperInspection': outputPacket.safeForDeveloperInspection,
        'sourceSkeletonValidationSafeForPhase33H':
            skeletonValidationResult.safeForPhase33H,
        'sourceSkeletonSafeForPhase33G': skeletonResult.safeForPhase33G,
      },
      recordRoleSummary: _recordRoleSummary(outputPacket.records),
      allowedFieldSummary: _sortedStrings(policy.allowedFieldIds),
      deniedFieldSummary: _sortedStrings(policy.deniedFieldIds),
      proofBoundarySummary: _sortedStrings(policy.capturedAndroidProofIds),
      runtimeBoundarySummary: const <String>[
        'debugBridgeRuntimeBlocked',
        'executablePrototypeBlocked',
        'implementationWiringBlocked',
        'schedulerExecutionBlocked',
      ],
      blockedBoundarySummary: _sortedStrings(<String>[
        ...outputPacket.blockedBoundaryIds,
        ...policy.deniedFieldIds,
      ]),
      warningSummary: _sortedStrings(<String>[
        ...skeletonValidationResult.warnings,
        ...skeletonResult.warnings,
      ]),
      futurePrerequisiteSummary: _sortedStrings(<String>[
        ...inputPacket.futurePrerequisites,
        'phase33IValidateDebugOnlyBridgeDeveloperInspectionHarness',
      ]),
      recommendation: DebugOnlyBridgeDeveloperInspectionRecommendation
          .keepInspectionDeveloperOnly,
    );
  }

  DebugOnlyBridgeDeveloperInspectionRow inspectInputPacket(
    DebugOnlyBridgeInputPacket packet,
  ) {
    final findings = _rowFindings(
      developerOnly: true,
      skeletonOnly: true,
      allowedFieldIds: packet.allowedFieldIds,
      safetyFlags: _safeFlags(),
    );
    return DebugOnlyBridgeDeveloperInspectionRow(
      inspectionRowId: 'phase33h-inputPacket',
      sourceRecordId: 'none',
      sourcePacketId: packet.inputPacketId,
      role: DebugOnlyBridgeDeveloperInspectionRowRole.inputPacketInspection,
      status: _statusForFindings(findings),
      developerOnly: true,
      skeletonOnly: true,
      contextOnly: false,
      inactive: false,
      allowedFieldIds: _sortedStrings(packet.allowedFieldIds),
      deniedFieldIds: _sortedStrings(packet.deniedFieldIds),
      androidProofCaseIds: _sortedStrings(packet.androidProofCaseIds),
      warningReasons: _sortedStrings(packet.warningReasons),
      proofLimitReasons: _sortedStrings(packet.proofLimitReasons),
      futurePrerequisites: _sortedStrings(packet.futurePrerequisites),
      blockedBoundaryIds: _sortedStrings(packet.blockedBoundaryIds),
      findings: findings,
      recommendation: DebugOnlyBridgeDeveloperInspectionRecommendation
          .keepInputPacketInternal,
    );
  }

  DebugOnlyBridgeDeveloperInspectionRow inspectOutputPacket(
    DebugOnlyBridgeOutputPacket packet,
  ) {
    final findings = _sortedStrings(<String>[
      ..._rowFindings(
        developerOnly: packet.developerOnly,
        skeletonOnly: true,
        allowedFieldIds: packet.allowedFieldIds,
        safetyFlags: _safeFlags(),
      ),
      if (!packet.safeForDeveloperInspection)
        'unsafe:outputPacketNotSafeForDeveloperInspection',
    ]);
    return DebugOnlyBridgeDeveloperInspectionRow(
      inspectionRowId: 'phase33h-outputPacket',
      sourceRecordId: 'none',
      sourcePacketId: packet.outputPacketId,
      role: DebugOnlyBridgeDeveloperInspectionRowRole.outputPacketInspection,
      status: _statusForFindings(findings),
      developerOnly: packet.developerOnly,
      skeletonOnly: true,
      contextOnly: false,
      inactive: false,
      allowedFieldIds: _sortedStrings(packet.allowedFieldIds),
      deniedFieldIds: _sortedStrings(packet.deniedFieldIds),
      androidProofCaseIds: _sortedStrings(packet.androidProofCaseIds),
      warningReasons: _sortedStrings(packet.warningReasons),
      proofLimitReasons: _sortedStrings(packet.proofLimitReasons),
      futurePrerequisites: const <String>[
        'phase33IValidateDebugOnlyBridgeDeveloperInspectionHarness',
      ],
      blockedBoundaryIds: _sortedStrings(packet.blockedBoundaryIds),
      findings: findings,
      recommendation: DebugOnlyBridgeDeveloperInspectionRecommendation
          .keepOutputPacketDeveloperOnly,
    );
  }

  DebugOnlyBridgeDeveloperInspectionRow inspectPolicy(
    DebugOnlyBridgePolicy policy,
  ) {
    final safetyFlags = _policyFlags(policy);
    final findings = _rowFindings(
      developerOnly: true,
      skeletonOnly: true,
      allowedFieldIds: policy.allowedFieldIds,
      safetyFlags: safetyFlags,
    );
    return DebugOnlyBridgeDeveloperInspectionRow(
      inspectionRowId: 'phase33h-policy',
      sourceRecordId: 'none',
      sourcePacketId: 'phase33f-policy',
      role: DebugOnlyBridgeDeveloperInspectionRowRole.policyInspection,
      status: _statusForFindings(findings),
      developerOnly: true,
      skeletonOnly: true,
      contextOnly: false,
      inactive: false,
      allowedFieldIds: _sortedStrings(policy.allowedFieldIds),
      deniedFieldIds: _sortedStrings(policy.deniedFieldIds),
      androidProofCaseIds: _sortedStrings(policy.capturedAndroidProofIds),
      warningReasons: const <String>[],
      proofLimitReasons: const <String>[],
      futurePrerequisites: const <String>[
        'phase33IValidateDebugOnlyBridgeDeveloperInspectionHarness',
      ],
      blockedBoundaryIds: _sortedStrings(policy.deniedFieldIds),
      findings: findings,
      recommendation:
          DebugOnlyBridgeDeveloperInspectionRecommendation.keepPolicyDenied,
    );
  }

  List<DebugOnlyBridgeDeveloperInspectionRow> inspectRecords(
    DebugOnlyBridgeOutputPacket outputPacket,
  ) {
    return outputPacket.records
        .map((record) => _recordInspectionRow(record, outputPacket))
        .toList(growable: false);
  }

  List<DebugOnlyBridgeDeveloperInspectionRow> inspectDeniedBoundaries(
    DebugOnlyBridgeOutputPacket outputPacket,
  ) {
    return inspectRecords(outputPacket)
        .where(
          (row) =>
              row.role ==
                  DebugOnlyBridgeDeveloperInspectionRowRole
                      .deniedFieldBoundaryInspection ||
              row.role ==
                  DebugOnlyBridgeDeveloperInspectionRowRole
                      .stockfishRawUciPvDumpDeniedInspection,
        )
        .toList(growable: false);
  }

  List<DebugOnlyBridgeDeveloperInspectionRow> inspectRuntimeBoundaries(
    DebugOnlyBridgeOutputPacket outputPacket,
  ) {
    return inspectRecords(outputPacket)
        .where(
          (row) =>
              row.role ==
              DebugOnlyBridgeDeveloperInspectionRowRole
                  .runtimeBlockedInspection,
        )
        .toList(growable: false);
  }

  List<DebugOnlyBridgeDeveloperInspectionRow> inspectProofBoundaries(
    DebugOnlyBridgeOutputPacket outputPacket,
  ) {
    return inspectRecords(outputPacket)
        .where(
          (row) =>
              row.role ==
                  DebugOnlyBridgeDeveloperInspectionRowRole
                      .proofBoundaryInspection ||
              row.role ==
                  DebugOnlyBridgeDeveloperInspectionRowRole
                      .ownerProofBoundaryInspection,
        )
        .toList(growable: false);
  }

  String renderDeveloperInspectionSnapshot(
    DebugOnlyBridgeDeveloperInspectionHarnessResult result, {
    DebugOnlyBridgeDeveloperInspectionHarnessReportFormat format =
        DebugOnlyBridgeDeveloperInspectionHarnessReportFormat.markdown,
  }) {
    return switch (format) {
      DebugOnlyBridgeDeveloperInspectionHarnessReportFormat.markdown =>
        result.renderMarkdownReport(),
      DebugOnlyBridgeDeveloperInspectionHarnessReportFormat.json =>
        result.renderJsonReport(),
    };
  }
}

class DebugOnlyBridgeDeveloperInspectionHarnessValidator {
  const DebugOnlyBridgeDeveloperInspectionHarnessValidator();

  List<DebugOnlyBridgeDeveloperInspectionHarnessFinding> validate(
    DebugOnlyBridgeDeveloperInspectionHarnessResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <DebugOnlyBridgeDeveloperInspectionHarnessFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);

    void add({
      required String id,
      required DebugOnlyBridgeDeveloperInspectionSeverity severity,
      required String message,
      String? inspectionRowId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        DebugOnlyBridgeDeveloperInspectionHarnessFinding(
          id: id,
          severity: severity,
          message: message,
          inspectionRowId: inspectionRowId,
          fieldId: fieldId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase33I &&
        (!result.skeletonValidationResult.safeForPhase33H ||
            result
                .skeletonValidationResult
                .hasUnsafeDebugOnlyBridgeDeveloperSkeletonValidationPolicyViolation)) {
      add(
        id: 'unsafeSkeletonValidationInput',
        severity: DebugOnlyBridgeDeveloperInspectionSeverity.critical,
        message: 'unsafe Phase 33G validation cannot be inspection-ready',
      );
    }
    if (result.safeForPhase33I &&
        (!result.skeletonResult.safeForPhase33G ||
            result
                .skeletonResult
                .hasUnsafeDebugOnlyBridgeDeveloperSkeletonPolicyViolation)) {
      add(
        id: 'unsafeSkeletonResultInput',
        severity: DebugOnlyBridgeDeveloperInspectionSeverity.critical,
        message: 'unsafe Phase 33F skeleton cannot be inspection-ready',
      );
    }
    if (result.phase33IRequirementPresentCount != 1) {
      add(
        id: 'missingPhase33IRequirement',
        severity: DebugOnlyBridgeDeveloperInspectionSeverity.critical,
        message: 'Phase 33I inspection harness validation requirement missing',
      );
    }
    if (result.snapshot.hasUnsafeInspectionOutput) {
      add(
        id: 'unsafeInspectionSnapshot',
        severity: DebugOnlyBridgeDeveloperInspectionSeverity.critical,
        message: 'inspection snapshot contains unsafe output',
      );
    }
    for (final row in result.inspectionRows) {
      _checkInspectionRow(add, row, provenAndroidIds);
    }
    for (final fieldId in _deniedFieldIds) {
      if (!result.policy.deniedFieldIds.contains(fieldId) ||
          !result.inputPacket.deniedFieldIds.contains(fieldId) ||
          !result.outputPacket.deniedFieldIds.contains(fieldId) ||
          !result.snapshot.deniedFieldSummary.contains(fieldId)) {
        add(
          id: 'deniedFieldMissing',
          severity: DebugOnlyBridgeDeveloperInspectionSeverity.blocker,
          message: '$fieldId must remain denied in inspection harness',
          fieldId: fieldId,
        );
      }
    }
    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: DebugOnlyBridgeDeveloperInspectionSeverity.blocker,
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
        id: 'developerInspectionHarnessBoundaryPolicyViolation',
        severity: DebugOnlyBridgeDeveloperInspectionSeverity.critical,
        message: 'developer inspection harness crossed a blocked boundary',
      );
    }
    return findings..sort(_compareFindings);
  }

  List<DebugOnlyBridgeDeveloperInspectionHarnessFinding> validateReportText(
    String reportText,
  ) {
    final findings = <DebugOnlyBridgeDeveloperInspectionHarnessFinding>[];
    void reportError(String id, String message) {
      findings.add(
        DebugOnlyBridgeDeveloperInspectionHarnessFinding(
          id: id,
          severity: DebugOnlyBridgeDeveloperInspectionSeverity.critical,
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

extension _Phase33IRequirementCount
    on DebugOnlyBridgeDeveloperInspectionHarnessResult {
  int get phase33IRequirementPresentCount => inspectionRows
      .where(
        (row) =>
            row.role ==
            DebugOnlyBridgeDeveloperInspectionRowRole
                .futureRequirementInspection,
      )
      .length;
}

DebugOnlyBridgeDeveloperInspectionRow _recordInspectionRow(
  DebugOnlyBridgeRecord record,
  DebugOnlyBridgeOutputPacket outputPacket,
) {
  final role = _inspectionRoleForRecordRole(record.role);
  final findings = _recordFindings(record);
  return DebugOnlyBridgeDeveloperInspectionRow(
    inspectionRowId: 'phase33h-${record.role.wire}',
    sourceRecordId: record.sourceRecordId,
    sourcePacketId: outputPacket.outputPacketId,
    role: role,
    status: _statusForFindings(findings),
    developerOnly: record.developerOnly,
    skeletonOnly: record.designOnly,
    contextOnly: record.contextOnly,
    inactive: record.inactive,
    allowedFieldIds: _sortedStrings(record.allowedFieldIds),
    deniedFieldIds: _sortedStrings(record.deniedFieldIds),
    androidProofCaseIds: _sortedStrings(record.androidProofCaseIds),
    warningReasons: _sortedStrings(record.warningReasons),
    proofLimitReasons: _sortedStrings(record.proofLimitReasons),
    futurePrerequisites: _sortedStrings(<String>[
      ...record.proofLimitReasons.where(
        (reason) => reason.toLowerCase().contains('future'),
      ),
      if (record.role == DebugOnlyBridgeRecordRole.futureRequirement)
        'phase33IValidateDebugOnlyBridgeDeveloperInspectionHarness',
    ]),
    blockedBoundaryIds: _sortedStrings(record.blockedBoundaryIds),
    findings: findings,
    recommendation: _recommendationForRole(role),
  );
}

DebugOnlyBridgeDeveloperInspectionHarnessResult _resultFromInspection({
  required DebugOnlyBridgeDeveloperSkeletonValidationResult
  skeletonValidationResult,
  required DebugOnlyBridgeSkeletonResult skeletonResult,
  required DebugOnlyBridgeImplementationDesignResult implementationDesignResult,
  required DebugOnlyBridgeInputPacket inputPacket,
  required DebugOnlyBridgeOutputPacket outputPacket,
  required DebugOnlyBridgePolicy policy,
  required DebugOnlyBridgeDeveloperInspectionSnapshot snapshot,
  required List<DebugOnlyBridgeDeveloperInspectionRow> inspectionRows,
  required List<DebugOnlyBridgeDeveloperInspectionHarnessFinding>
  inspectionFindings,
}) {
  final activeDeniedFieldCount = inspectionRows
      .where((row) => row.hasActiveDeniedField)
      .length;
  final productOutputCount =
      (skeletonResult.productOutputActive ? 1 : 0) +
      (skeletonValidationResult.productOutputActive ? 1 : 0) +
      (policy.allowProductOutput ? 1 : 0);
  final labelLeakCount =
      (skeletonResult.classifierOutputActive ? 1 : 0) +
      (skeletonResult.finalMoveLabelOutputActive ? 1 : 0) +
      (skeletonValidationResult.classifierOutputActive ? 1 : 0) +
      (skeletonValidationResult.finalMoveLabelOutputActive ? 1 : 0) +
      (policy.allowClassifierLabels ? 1 : 0);
  final scoreLeakCount =
      (skeletonResult.numericOutputActive ? 1 : 0) +
      (skeletonResult.aggregateScoreOutputActive ? 1 : 0) +
      (skeletonResult.moveRankingOutputActive ? 1 : 0) +
      (skeletonValidationResult.numericOutputActive ? 1 : 0) +
      (skeletonValidationResult.aggregateScoreOutputActive ? 1 : 0) +
      (skeletonValidationResult.moveRankingOutputActive ? 1 : 0) +
      (policy.allowNumericScores ? 1 : 0) +
      (policy.allowAggregateScores ? 1 : 0) +
      (policy.allowMoveRanking ? 1 : 0);
  final metricLeakCount =
      (skeletonResult.officialMetricOutputActive ? 1 : 0) +
      (skeletonValidationResult.officialMetricOutputActive ? 1 : 0) +
      (policy.allowOfficialMetrics ? 1 : 0);
  final cpLossLeakCount =
      (skeletonResult.cpLossOutputActive ? 1 : 0) +
      (skeletonValidationResult.cpLossOutputActive ? 1 : 0) +
      (policy.allowCpLoss ? 1 : 0);
  final winProbabilityLeakCount =
      (skeletonResult.winProbabilityOutputActive ? 1 : 0) +
      (skeletonValidationResult.winProbabilityOutputActive ? 1 : 0) +
      (policy.allowWinProbability ? 1 : 0);
  final uiTargetCount =
      (skeletonResult.uiTargetsActive ? 1 : 0) +
      (skeletonValidationResult.uiTargetsActive ? 1 : 0) +
      (policy.allowUi ? 1 : 0);
  final backendTargetCount =
      (skeletonResult.backendOutputActive ? 1 : 0) +
      (skeletonValidationResult.backendOutputActive ? 1 : 0) +
      (policy.allowBackend ? 1 : 0);
  final persistenceWriteCount =
      (skeletonResult.persistenceWritesActive ? 1 : 0) +
      (skeletonValidationResult.persistenceWritesActive ? 1 : 0) +
      (policy.allowPersistence ? 1 : 0);
  final engineCallCount =
      (skeletonResult.engineCallsActive ? 1 : 0) +
      (skeletonValidationResult.engineCallsActive ? 1 : 0) +
      (policy.allowDirectEngine ? 1 : 0);
  final schedulerExecutionCount = inspectionRows
      .where((row) => _rowHasSchedulerExecution(row))
      .length;
  final stockfishCommandLeakCount =
      (skeletonResult.stockfishCommandFieldActive ? 1 : 0) +
      (skeletonValidationResult.stockfishCommandFieldActive ? 1 : 0) +
      (policy.allowStockfishCommand ? 1 : 0) +
      inspectionRows
          .where((row) => row.allowedFieldIds.contains('stockfishCommand'))
          .length;
  final rawUciLeakCount =
      (skeletonResult.rawUciFieldActive ? 1 : 0) +
      (skeletonValidationResult.rawUciFieldActive ? 1 : 0) +
      (policy.allowRawUci ? 1 : 0) +
      inspectionRows
          .where((row) => row.allowedFieldIds.contains('rawUci'))
          .length;
  final pvDumpLeakCount =
      (skeletonResult.pvDumpFieldActive ? 1 : 0) +
      (skeletonValidationResult.pvDumpFieldActive ? 1 : 0) +
      (policy.allowPvDump ? 1 : 0) +
      inspectionRows
          .where((row) => row.allowedFieldIds.contains('pvDump'))
          .length;
  final blockerCount = inspectionFindings
      .where((finding) => finding.blocksStrict)
      .length;
  final criticalCount = inspectionFindings
      .where((finding) => finding.isCritical)
      .length;
  final unsafeRowCount = inspectionRows
      .where((row) => row.hasUnsafeOutput)
      .length;
  final unsafeCount =
      skeletonValidationResult.unsafeCount +
      skeletonResult.unsafeCount +
      unsafeRowCount +
      (snapshot.hasUnsafeInspectionOutput ? 1 : 0) +
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
  final base = DebugOnlyBridgeDeveloperInspectionHarnessResult(
    status: DebugOnlyBridgeDeveloperInspectionHarnessStatus.invalid,
    sourceSkeletonValidationStatus: skeletonValidationResult.status,
    sourceSkeletonStatus: skeletonResult.status,
    skeletonValidationResult: skeletonValidationResult,
    skeletonResult: skeletonResult,
    implementationDesignResult: implementationDesignResult,
    inputPacket: inputPacket,
    outputPacket: outputPacket,
    policy: policy,
    snapshot: snapshot,
    inspectionRows: inspectionRows,
    inspectionFindings: inspectionFindings,
    warnings: _sortedStrings(<String>[
      ...skeletonValidationResult.warnings,
      ...skeletonResult.warnings,
      'Phase 33H creates a developer-only inspection snapshot over the skeleton',
    ]),
    failures: _sortedStrings(<String>[
      ...skeletonValidationResult.failures,
      ...skeletonResult.failures,
      ...inspectionRows.expand((row) => row.findings),
      ...inspectionFindings.map((finding) => finding.message),
    ]),
    totalInspectionRows: inspectionRows.length,
    inputPacketInspectionCount: _countRole(
      inspectionRows,
      DebugOnlyBridgeDeveloperInspectionRowRole.inputPacketInspection,
    ),
    outputPacketInspectionCount: _countRole(
      inspectionRows,
      DebugOnlyBridgeDeveloperInspectionRowRole.outputPacketInspection,
    ),
    policyInspectionCount: _countRole(
      inspectionRows,
      DebugOnlyBridgeDeveloperInspectionRowRole.policyInspection,
    ),
    recordInspectionCount: inspectionRows
        .where((row) => row.role.isRecordInspection)
        .length,
    coreRecordInspectionCount: _countRole(
      inspectionRows,
      DebugOnlyBridgeDeveloperInspectionRowRole.coreRecordInspection,
    ),
    contextRecordInspectionCount: _countRole(
      inspectionRows,
      DebugOnlyBridgeDeveloperInspectionRowRole.contextRecordInspection,
    ),
    inactiveRecordInspectionCount: _countRole(
      inspectionRows,
      DebugOnlyBridgeDeveloperInspectionRowRole.inactiveRecordInspection,
    ),
    deniedBoundaryInspectionCount:
        _countRole(
          inspectionRows,
          DebugOnlyBridgeDeveloperInspectionRowRole
              .deniedFieldBoundaryInspection,
        ) +
        _countRole(
          inspectionRows,
          DebugOnlyBridgeDeveloperInspectionRowRole
              .stockfishRawUciPvDumpDeniedInspection,
        ),
    runtimeBlockedInspectionCount: _countRole(
      inspectionRows,
      DebugOnlyBridgeDeveloperInspectionRowRole.runtimeBlockedInspection,
    ),
    proofBoundaryInspectionCount: _countRole(
      inspectionRows,
      DebugOnlyBridgeDeveloperInspectionRowRole.proofBoundaryInspection,
    ),
    unsafeCount: unsafeCount,
    blockerCount: blockerCount,
    criticalCount: criticalCount,
    ownerProofQueueCount: skeletonValidationResult.ownerProofQueueCount,
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
    safeForPhase33I: false,
    phase33IRecommendation:
        DebugOnlyBridgeDeveloperInspectionPhase33IRecommendation
            .addMoreGoldenCoverageFirst,
    developerOnly: skeletonValidationResult.developerOnly,
    debugBridgeRuntimeImplemented:
        skeletonValidationResult.debugBridgeRuntimeImplemented,
    executableBridgeSkeletonImplemented:
        skeletonValidationResult.executableBridgeSkeletonImplemented,
    executableDebugBridgePrototypeImplemented:
        skeletonValidationResult.executableDebugBridgePrototypeImplemented,
    implementationWiringImplemented:
        skeletonValidationResult.implementationWiringImplemented,
    productOutputActive: skeletonValidationResult.productOutputActive,
    classifierOutputActive: skeletonValidationResult.classifierOutputActive,
    finalMoveLabelOutputActive:
        skeletonValidationResult.finalMoveLabelOutputActive,
    officialMetricOutputActive:
        skeletonValidationResult.officialMetricOutputActive,
    cpLossOutputActive: skeletonValidationResult.cpLossOutputActive,
    winProbabilityOutputActive:
        skeletonValidationResult.winProbabilityOutputActive,
    numericOutputActive: skeletonValidationResult.numericOutputActive,
    aggregateScoreOutputActive:
        skeletonValidationResult.aggregateScoreOutputActive,
    moveRankingOutputActive: skeletonValidationResult.moveRankingOutputActive,
    quietPreparatoryScopeActivated:
        skeletonValidationResult.quietPreparatoryScopeActivated,
    engineCallsActive: skeletonValidationResult.engineCallsActive,
    persistenceWritesActive: skeletonValidationResult.persistenceWritesActive,
    uiTargetsActive: skeletonValidationResult.uiTargetsActive,
    backendOutputActive: skeletonValidationResult.backendOutputActive,
    stockfishCommandFieldActive:
        skeletonValidationResult.stockfishCommandFieldActive,
    rawUciFieldActive: skeletonValidationResult.rawUciFieldActive,
    pvDumpFieldActive: skeletonValidationResult.pvDumpFieldActive,
  );
  final status = _inspectionStatusFor(base);
  final safeForPhase33I =
      (status ==
              DebugOnlyBridgeDeveloperInspectionHarnessStatus
                  .inspectionReadyWithWarnings ||
          status ==
              DebugOnlyBridgeDeveloperInspectionHarnessStatus
                  .inspectionReadyClean) &&
      skeletonValidationResult.safeForPhase33H &&
      !skeletonValidationResult
          .hasUnsafeDebugOnlyBridgeDeveloperSkeletonValidationPolicyViolation &&
      skeletonResult.safeForPhase33G &&
      !skeletonResult
          .hasUnsafeDebugOnlyBridgeDeveloperSkeletonPolicyViolation &&
      unsafeCount == 0 &&
      blockerCount == 0 &&
      criticalCount == 0 &&
      inspectionRows.every((row) => !row.hasUnsafeOutput) &&
      !snapshot.hasUnsafeInspectionOutput;
  return base.copyWith(
    status: status,
    safeForPhase33I: safeForPhase33I,
    phase33IRecommendation: _phase33IRecommendationFor(
      status: status,
      safeForPhase33I: safeForPhase33I,
      ownerProofQueueCount: skeletonValidationResult.ownerProofQueueCount,
    ),
  );
}

DebugOnlyBridgeDeveloperInspectionHarnessStatus _inspectionStatusFor(
  DebugOnlyBridgeDeveloperInspectionHarnessResult result,
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
    return DebugOnlyBridgeDeveloperInspectionHarnessStatus
        .blockedByPolicyBoundary;
  }
  if (result
          .skeletonValidationResult
          .hasUnsafeDebugOnlyBridgeDeveloperSkeletonValidationPolicyViolation ||
      !result.skeletonValidationResult.safeForPhase33H ||
      result
          .skeletonResult
          .hasUnsafeDebugOnlyBridgeDeveloperSkeletonPolicyViolation ||
      !result.skeletonResult.safeForPhase33G ||
      result.unsafeCount > 0 ||
      result.criticalCount > 0) {
    return DebugOnlyBridgeDeveloperInspectionHarnessStatus
        .blockedByUnsafeSkeletonValidation;
  }
  if (result.blockerCount > 0 ||
      result.totalInspectionRows == 0 ||
      result.inspectionRows.any(
        (row) =>
            row.status == DebugOnlyBridgeDeveloperInspectionRowStatus.invalid,
      )) {
    return DebugOnlyBridgeDeveloperInspectionHarnessStatus.invalid;
  }
  if (result.warnings.isNotEmpty) {
    return DebugOnlyBridgeDeveloperInspectionHarnessStatus
        .inspectionReadyWithWarnings;
  }
  return DebugOnlyBridgeDeveloperInspectionHarnessStatus.inspectionReadyClean;
}

DebugOnlyBridgeDeveloperInspectionPhase33IRecommendation
_phase33IRecommendationFor({
  required DebugOnlyBridgeDeveloperInspectionHarnessStatus status,
  required bool safeForPhase33I,
  required int ownerProofQueueCount,
}) {
  if (status ==
          DebugOnlyBridgeDeveloperInspectionHarnessStatus
              .blockedByUnsafeSkeletonValidation ||
      status ==
          DebugOnlyBridgeDeveloperInspectionHarnessStatus
              .blockedByPolicyBoundary) {
    return DebugOnlyBridgeDeveloperInspectionPhase33IRecommendation
        .blockedByUnsafeInspectionHarness;
  }
  if (ownerProofQueueCount > 0) {
    return DebugOnlyBridgeDeveloperInspectionPhase33IRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase33I) {
    return DebugOnlyBridgeDeveloperInspectionPhase33IRecommendation
        .proceedToInspectionHarnessHardening;
  }
  return DebugOnlyBridgeDeveloperInspectionPhase33IRecommendation
      .validateDebugOnlyBridgeDeveloperInspectionHarness;
}

void _checkInspectionRow(
  void Function({
    required String id,
    required DebugOnlyBridgeDeveloperInspectionSeverity severity,
    required String message,
    String? inspectionRowId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugOnlyBridgeDeveloperInspectionRow row,
  List<String> provenAndroidIds,
) {
  if (!row.developerOnly || !row.skeletonOnly) {
    add(
      id: 'rowNotDeveloperOrSkeletonOnly',
      severity: DebugOnlyBridgeDeveloperInspectionSeverity.critical,
      message: 'inspection rows must stay developer-only and skeleton-only',
      inspectionRowId: row.inspectionRowId,
    );
  }
  for (final fieldId in row.allowedFieldIds) {
    if (_isDeniedFieldId(fieldId) || _isLegacyDeniedFieldId(fieldId)) {
      add(
        id: 'activeDeniedField',
        severity: DebugOnlyBridgeDeveloperInspectionSeverity.critical,
        message: '$fieldId is denied and cannot become active',
        inspectionRowId: row.inspectionRowId,
        fieldId: fieldId,
      );
    }
  }
  if (row.role ==
          DebugOnlyBridgeDeveloperInspectionRowRole.coreRecordInspection &&
      row.contextOnly) {
    add(
      id: 'coreRecordBoundaryViolation',
      severity: DebugOnlyBridgeDeveloperInspectionSeverity.blocker,
      message: 'core inspection row cannot be context-only',
      inspectionRowId: row.inspectionRowId,
    );
  }
  if (row.role ==
          DebugOnlyBridgeDeveloperInspectionRowRole.contextRecordInspection &&
      !row.contextOnly) {
    add(
      id: 'contextRecordPromotedToCore',
      severity: DebugOnlyBridgeDeveloperInspectionSeverity.blocker,
      message: 'context inspection row must remain context-only',
      inspectionRowId: row.inspectionRowId,
    );
  }
  if (row.role ==
          DebugOnlyBridgeDeveloperInspectionRowRole.inactiveRecordInspection &&
      !row.inactive) {
    add(
      id: 'inactiveRecordMadeActive',
      severity: DebugOnlyBridgeDeveloperInspectionSeverity.blocker,
      message: 'inactive inspection row must remain inactive',
      inspectionRowId: row.inspectionRowId,
    );
  }
  for (final proofId in row.androidProofCaseIds) {
    if (!provenAndroidIds.contains(proofId)) {
      add(
        id: 'unprovenAndroidProofId',
        severity: DebugOnlyBridgeDeveloperInspectionSeverity.blocker,
        message: '$proofId is not captured Android proof',
        inspectionRowId: row.inspectionRowId,
        caseId: proofId,
      );
    }
    if (_phase32ECaseIds.contains(proofId)) {
      add(
        id: 'phase32ECaseClaimedAsCapturedProof',
        severity: DebugOnlyBridgeDeveloperInspectionSeverity.critical,
        message: '$proofId cannot be treated as captured Android proof',
        inspectionRowId: row.inspectionRowId,
        caseId: proofId,
      );
    }
  }
}

DebugOnlyBridgeDeveloperInspectionRowStatus _statusForFindings(
  List<String> findings,
) {
  if (findings.any((finding) => finding.startsWith('unsafe:'))) {
    return DebugOnlyBridgeDeveloperInspectionRowStatus.blockedByBoundary;
  }
  if (findings.isNotEmpty) {
    return DebugOnlyBridgeDeveloperInspectionRowStatus.inspectedWithFindings;
  }
  return DebugOnlyBridgeDeveloperInspectionRowStatus.inspected;
}

DebugOnlyBridgeDeveloperInspectionRowRole _inspectionRoleForRecordRole(
  DebugOnlyBridgeRecordRole role,
) {
  return switch (role) {
    DebugOnlyBridgeRecordRole.core =>
      DebugOnlyBridgeDeveloperInspectionRowRole.coreRecordInspection,
    DebugOnlyBridgeRecordRole.context =>
      DebugOnlyBridgeDeveloperInspectionRowRole.contextRecordInspection,
    DebugOnlyBridgeRecordRole.inactiveBlocked ||
    DebugOnlyBridgeRecordRole.inactiveFuture =>
      DebugOnlyBridgeDeveloperInspectionRowRole.inactiveRecordInspection,
    DebugOnlyBridgeRecordRole.allowedFieldBoundary =>
      DebugOnlyBridgeDeveloperInspectionRowRole.allowedFieldBoundaryInspection,
    DebugOnlyBridgeRecordRole.deniedFieldBoundary =>
      DebugOnlyBridgeDeveloperInspectionRowRole.deniedFieldBoundaryInspection,
    DebugOnlyBridgeRecordRole.stockfishRawUciPvDumpDenied =>
      DebugOnlyBridgeDeveloperInspectionRowRole
          .stockfishRawUciPvDumpDeniedInspection,
    DebugOnlyBridgeRecordRole.runtimeBlocked =>
      DebugOnlyBridgeDeveloperInspectionRowRole.runtimeBlockedInspection,
    DebugOnlyBridgeRecordRole.proofBoundary =>
      DebugOnlyBridgeDeveloperInspectionRowRole.proofBoundaryInspection,
    DebugOnlyBridgeRecordRole.ownerProofBoundary =>
      DebugOnlyBridgeDeveloperInspectionRowRole.ownerProofBoundaryInspection,
    DebugOnlyBridgeRecordRole.futureRequirement =>
      DebugOnlyBridgeDeveloperInspectionRowRole.futureRequirementInspection,
  };
}

DebugOnlyBridgeDeveloperInspectionRecommendation _recommendationForRole(
  DebugOnlyBridgeDeveloperInspectionRowRole role,
) {
  return switch (role) {
    DebugOnlyBridgeDeveloperInspectionRowRole.inputPacketInspection =>
      DebugOnlyBridgeDeveloperInspectionRecommendation.keepInputPacketInternal,
    DebugOnlyBridgeDeveloperInspectionRowRole.outputPacketInspection =>
      DebugOnlyBridgeDeveloperInspectionRecommendation
          .keepOutputPacketDeveloperOnly,
    DebugOnlyBridgeDeveloperInspectionRowRole.policyInspection =>
      DebugOnlyBridgeDeveloperInspectionRecommendation.keepPolicyDenied,
    DebugOnlyBridgeDeveloperInspectionRowRole.coreRecordInspection =>
      DebugOnlyBridgeDeveloperInspectionRecommendation
          .keepCoreRecordInspectableOnly,
    DebugOnlyBridgeDeveloperInspectionRowRole.contextRecordInspection =>
      DebugOnlyBridgeDeveloperInspectionRecommendation
          .keepContextRecordContextOnly,
    DebugOnlyBridgeDeveloperInspectionRowRole.inactiveRecordInspection =>
      DebugOnlyBridgeDeveloperInspectionRecommendation
          .keepInactiveRecordInactive,
    DebugOnlyBridgeDeveloperInspectionRowRole.allowedFieldBoundaryInspection =>
      DebugOnlyBridgeDeveloperInspectionRecommendation
          .keepAllowedFieldBoundaryInternal,
    DebugOnlyBridgeDeveloperInspectionRowRole.deniedFieldBoundaryInspection =>
      DebugOnlyBridgeDeveloperInspectionRecommendation.keepDeniedBoundaryDenied,
    DebugOnlyBridgeDeveloperInspectionRowRole
        .stockfishRawUciPvDumpDeniedInspection =>
      DebugOnlyBridgeDeveloperInspectionRecommendation
          .keepStockfishRawUciPvDumpDenied,
    DebugOnlyBridgeDeveloperInspectionRowRole.runtimeBlockedInspection =>
      DebugOnlyBridgeDeveloperInspectionRecommendation
          .keepRuntimePrototypeWiringBlocked,
    DebugOnlyBridgeDeveloperInspectionRowRole.proofBoundaryInspection =>
      DebugOnlyBridgeDeveloperInspectionRecommendation
          .keepProofBoundaryCapturedOnly,
    DebugOnlyBridgeDeveloperInspectionRowRole.ownerProofBoundaryInspection =>
      DebugOnlyBridgeDeveloperInspectionRecommendation.keepOwnerProofEmpty,
    DebugOnlyBridgeDeveloperInspectionRowRole.futureRequirementInspection =>
      DebugOnlyBridgeDeveloperInspectionRecommendation
          .requirePhase33IInspectionHarnessValidation,
  };
}

List<String> _recordFindings(DebugOnlyBridgeRecord record) {
  return _sortedStrings(<String>[
    ..._rowFindings(
      developerOnly: record.developerOnly,
      skeletonOnly: record.designOnly,
      allowedFieldIds: record.allowedFieldIds,
      safetyFlags: record.safetyFlags,
    ),
    if (record.role == DebugOnlyBridgeRecordRole.core && record.contextOnly)
      'unsafe:coreRecordMarkedContextOnly',
    if (record.role == DebugOnlyBridgeRecordRole.context && !record.contextOnly)
      'unsafe:contextRecordPromotedToCore',
    if ((record.role == DebugOnlyBridgeRecordRole.inactiveBlocked ||
            record.role == DebugOnlyBridgeRecordRole.inactiveFuture) &&
        !record.inactive)
      'unsafe:inactiveRecordMadeActive',
  ]);
}

List<String> _rowFindings({
  required bool developerOnly,
  required bool skeletonOnly,
  required Iterable<String> allowedFieldIds,
  required Map<String, bool> safetyFlags,
}) {
  return _sortedStrings(<String>[
    if (!developerOnly) 'unsafe:notDeveloperOnly',
    if (!skeletonOnly) 'unsafe:notSkeletonOnly',
    for (final fieldId in allowedFieldIds)
      if (_isDeniedFieldId(fieldId) || _isLegacyDeniedFieldId(fieldId))
        'unsafe:activeDeniedField:$fieldId',
    for (final entry in safetyFlags.entries)
      if (entry.value) 'unsafe:${entry.key}',
  ]);
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
    'targetsUi': policy.allowUi,
    'targetsBackend': policy.allowBackend,
    'writesPersistence': policy.allowPersistence,
    'callsEngine': policy.allowDirectEngine,
    'exposesStockfishCommand': policy.allowStockfishCommand,
    'exposesRawUci': policy.allowRawUci,
    'exposesPvDump': policy.allowPvDump,
    'implementsRuntime': policy.allowRuntime,
    'implementsExecutablePrototype': policy.allowExecutablePrototype,
    'implementsWiring': policy.allowWiring,
    'schedulerExecutionActive': false,
    'quietPreparatoryScopeActive': false,
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
    'targetsUi': false,
    'targetsBackend': false,
    'writesPersistence': false,
    'callsEngine': false,
    'exposesStockfishCommand': false,
    'exposesRawUci': false,
    'exposesPvDump': false,
    'implementsRuntime': false,
    'implementsExecutablePrototype': false,
    'implementsWiring': false,
    'schedulerExecutionActive': false,
    'quietPreparatoryScopeActive': false,
  };
}

Map<String, int> _recordRoleSummary(List<DebugOnlyBridgeRecord> records) {
  final summary = <String, int>{};
  for (final role in DebugOnlyBridgeRecordRole.values) {
    summary[role.wire] = records.where((record) => record.role == role).length;
  }
  return summary;
}

bool _rowHasSchedulerExecution(DebugOnlyBridgeDeveloperInspectionRow row) {
  return row.allowedFieldIds.contains('schedulerExecution') ||
      row.findings.any(
        (finding) => finding.toLowerCase().contains('schedulerexecution'),
      );
}

bool _hasExplicitPvProofReason(
  DebugOnlyBridgeDeveloperInspectionHarnessResult result,
) {
  final reasons = <String>{
    ...result.snapshot.proofBoundarySummary,
    ...result.snapshot.warningSummary,
    ...result.snapshot.futurePrerequisiteSummary,
    ...result.inspectionRows.expand((row) => row.warningReasons),
    ...result.inspectionRows.expand((row) => row.proofLimitReasons),
  }.map((reason) => reason.toLowerCase()).join(' ');
  return reasons.contains('owner proof pv') ||
      reasons.contains('owner proof multipv') ||
      reasons.contains('pv owner proof') ||
      reasons.contains('multipv owner proof') ||
      reasons.contains('explicit owner proof');
}

int _countRole(
  List<DebugOnlyBridgeDeveloperInspectionRow> rows,
  DebugOnlyBridgeDeveloperInspectionRowRole role,
) {
  return rows.where((row) => row.role == role).length;
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
  DebugOnlyBridgeDeveloperInspectionHarnessFinding a,
  DebugOnlyBridgeDeveloperInspectionHarnessFinding b,
) {
  final severity = b.severity.index.compareTo(a.severity.index);
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.inspectionRowId ?? '').compareTo(b.inspectionRowId ?? '');
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.where((value) => value.trim().isNotEmpty).toSet().toList()
    ..sort();
}

String _ids(Iterable<String> values) {
  final sorted = _sortedStrings(values);
  return sorted.isEmpty ? 'none' : sorted.join(', ');
}

String _summaryMap(Map<String, int> values) {
  return values.entries
      .map((entry) => '${entry.key}=${entry.value}')
      .join(', ');
}

String _rowSummary(DebugOnlyBridgeDeveloperInspectionRow row) {
  return [
    '- row: ${row.inspectionRowId}',
    '- role: ${row.role.wire}',
    '- status: ${row.status.wire}',
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

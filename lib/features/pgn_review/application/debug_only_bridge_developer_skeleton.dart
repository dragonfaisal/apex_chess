/// Developer-only skeleton for the debug-only bridge contract.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_summary_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_implementation_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugOnlyBridgeDeveloperSkeletonReportVersion =
    'debug-only-bridge-developer-skeleton-v1';
const debugOnlyBridgeDeveloperSkeletonVersion =
    'phase33f-developer-only-skeleton-v1';

enum DebugOnlyBridgeSkeletonStatus {
  skeletonReadyWithWarnings('skeletonReadyWithWarnings'),
  skeletonReadyClean('skeletonReadyClean'),
  blockedByUnsafeImplementationDesign('blockedByUnsafeImplementationDesign'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const DebugOnlyBridgeSkeletonStatus(this.wire);

  final String wire;
}

enum DebugOnlyBridgeRecordRole {
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

  const DebugOnlyBridgeRecordRole(this.wire);

  final String wire;

  bool get isInactiveBoundary =>
      this == inactiveBlocked ||
      this == inactiveFuture ||
      this == deniedFieldBoundary ||
      this == stockfishRawUciPvDumpDenied ||
      this == runtimeBlocked;
}

enum DebugOnlyBridgeSkeletonRecommendation {
  keepCoreDeveloperOnly('keepCoreDeveloperOnly'),
  keepContextContextOnly('keepContextContextOnly'),
  keepInactiveRecordInactive('keepInactiveRecordInactive'),
  keepAllowedFieldBoundaryInternal('keepAllowedFieldBoundaryInternal'),
  keepDeniedFieldBoundaryDenied('keepDeniedFieldBoundaryDenied'),
  keepStockfishRawUciPvDumpDenied('keepStockfishRawUciPvDumpDenied'),
  keepRuntimePrototypeWiringBlocked('keepRuntimePrototypeWiringBlocked'),
  keepProofBoundaryCapturedOnly('keepProofBoundaryCapturedOnly'),
  keepOwnerProofEmpty('keepOwnerProofEmpty'),
  keepFutureRequirementDeveloperOnly('keepFutureRequirementDeveloperOnly'),
  investigateSkeletonFailure('investigateSkeletonFailure'),
  blockUnsafeSkeleton('blockUnsafeSkeleton');

  const DebugOnlyBridgeSkeletonRecommendation(this.wire);

  final String wire;
}

enum DebugOnlyBridgePhase33GRecommendation {
  validateDebugOnlyBridgeDeveloperSkeleton(
    'validateDebugOnlyBridgeDeveloperSkeleton',
  ),
  proceedToDebugOnlyBridgeSkeletonValidation(
    'proceedToDebugOnlyBridgeSkeletonValidation',
  ),
  proceedToDeveloperSkeletonReportOnly('proceedToDeveloperSkeletonReportOnly'),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeDeveloperSkeleton('blockedByUnsafeDeveloperSkeleton');

  const DebugOnlyBridgePhase33GRecommendation(this.wire);

  final String wire;
}

enum DebugOnlyBridgeSkeletonSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const DebugOnlyBridgeSkeletonSeverity(this.wire);

  final String wire;

  bool get blocksStrict => this == blocker || this == critical;

  bool get isCritical => this == critical;
}

enum DebugOnlyBridgeSkeletonReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeSkeletonReportFormat(this.wire);

  final String wire;
}

class DebugOnlyBridgeSkeletonRequest {
  const DebugOnlyBridgeSkeletonRequest({
    this.implementationDesignResult,
    this.readinessSummaryValidationResult,
    this.readinessSummaryResult,
    this.readinessGateResult,
    this.prototypeValidationResult,
    this.prototypeDesignResult,
    this.bridgeReadinessGateResult,
    this.implementationDesign = const DebugOnlyBridgeImplementationDesign(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const DebugOnlyBridgeSkeletonRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final DebugOnlyBridgeImplementationDesignResult? implementationDesignResult;
  final DebugBridgePrototypeDesignReadinessSummaryValidationResult?
  readinessSummaryValidationResult;
  final DebugBridgePrototypeDesignReadinessSummaryResult?
  readinessSummaryResult;
  final DebugBridgePrototypeDesignReadinessGateResult? readinessGateResult;
  final DebugOnlyBridgePrototypeDesignValidationResult?
  prototypeValidationResult;
  final DebugOnlyBridgePrototypeDesignResult? prototypeDesignResult;
  final DebugBridgeReadinessValidationGateResult? bridgeReadinessGateResult;
  final DebugOnlyBridgeImplementationDesign implementationDesign;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class DebugOnlyBridgeInputPacket {
  const DebugOnlyBridgeInputPacket({
    required this.sourceImplementationDesignId,
    required this.sourceValidationId,
    required this.sourceSummaryId,
    required this.sourceGateId,
    required this.sourceDesignId,
    required this.inputPacketId,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.approvedCoreRecordIds,
    required this.constrainedContextRecordIds,
    required this.inactiveBlockedRecordIds,
    required this.inactiveFutureRecordIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.futurePrerequisites,
    required this.blockedBoundaryIds,
  });

  final String sourceImplementationDesignId;
  final String sourceValidationId;
  final String sourceSummaryId;
  final String sourceGateId;
  final String sourceDesignId;
  final String inputPacketId;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final List<String> approvedCoreRecordIds;
  final List<String> constrainedContextRecordIds;
  final List<String> inactiveBlockedRecordIds;
  final List<String> inactiveFutureRecordIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> futurePrerequisites;
  final List<String> blockedBoundaryIds;

  bool get hasUnsafeInput =>
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId);

  DebugOnlyBridgeInputPacket copyWith({
    String? sourceImplementationDesignId,
    String? sourceValidationId,
    String? sourceSummaryId,
    String? sourceGateId,
    String? sourceDesignId,
    String? inputPacketId,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    List<String>? approvedCoreRecordIds,
    List<String>? constrainedContextRecordIds,
    List<String>? inactiveBlockedRecordIds,
    List<String>? inactiveFutureRecordIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? futurePrerequisites,
    List<String>? blockedBoundaryIds,
  }) {
    return DebugOnlyBridgeInputPacket(
      sourceImplementationDesignId:
          sourceImplementationDesignId ?? this.sourceImplementationDesignId,
      sourceValidationId: sourceValidationId ?? this.sourceValidationId,
      sourceSummaryId: sourceSummaryId ?? this.sourceSummaryId,
      sourceGateId: sourceGateId ?? this.sourceGateId,
      sourceDesignId: sourceDesignId ?? this.sourceDesignId,
      inputPacketId: inputPacketId ?? this.inputPacketId,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      allowedFieldIds: allowedFieldIds ?? this.allowedFieldIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      approvedCoreRecordIds:
          approvedCoreRecordIds ?? this.approvedCoreRecordIds,
      constrainedContextRecordIds:
          constrainedContextRecordIds ?? this.constrainedContextRecordIds,
      inactiveBlockedRecordIds:
          inactiveBlockedRecordIds ?? this.inactiveBlockedRecordIds,
      inactiveFutureRecordIds:
          inactiveFutureRecordIds ?? this.inactiveFutureRecordIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      futurePrerequisites: futurePrerequisites ?? this.futurePrerequisites,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'sourceImplementationDesignId': sourceImplementationDesignId,
    'sourceValidationId': sourceValidationId,
    'sourceSummaryId': sourceSummaryId,
    'sourceGateId': sourceGateId,
    'sourceDesignId': sourceDesignId,
    'inputPacketId': inputPacketId,
    'supportCaseIds': supportCaseIds,
    'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
    'androidProofCaseIds': androidProofCaseIds,
    'allowedFieldIds': allowedFieldIds,
    'deniedFieldIds': deniedFieldIds,
    'approvedCoreRecordIds': approvedCoreRecordIds,
    'constrainedContextRecordIds': constrainedContextRecordIds,
    'inactiveBlockedRecordIds': inactiveBlockedRecordIds,
    'inactiveFutureRecordIds': inactiveFutureRecordIds,
    'warningReasons': warningReasons,
    'proofLimitReasons': proofLimitReasons,
    'futurePrerequisites': futurePrerequisites,
    'blockedBoundaryIds': blockedBoundaryIds,
  };
}

class DebugOnlyBridgeOutputPacket {
  const DebugOnlyBridgeOutputPacket({
    required this.outputPacketId,
    required this.inputPacketId,
    required this.skeletonVersion,
    required this.records,
    required this.policy,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.blockedBoundaryIds,
    required this.supportCaseIds,
    required this.androidProofCaseIds,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.safeForDeveloperInspection,
    required this.recommendation,
    this.developerOnly = true,
  });

  final String outputPacketId;
  final String inputPacketId;
  final String skeletonVersion;
  final List<DebugOnlyBridgeRecord> records;
  final DebugOnlyBridgePolicy policy;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> blockedBoundaryIds;
  final List<String> supportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final bool safeForDeveloperInspection;
  final DebugOnlyBridgePhase33GRecommendation recommendation;
  final bool developerOnly;

  bool get hasUnsafeOutput =>
      !developerOnly ||
      !safeForDeveloperInspection ||
      policy.hasUnsafeAllowance ||
      records.any((record) => record.hasUnsafeOutput) ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId);

  DebugOnlyBridgeOutputPacket copyWith({
    String? outputPacketId,
    String? inputPacketId,
    String? skeletonVersion,
    List<DebugOnlyBridgeRecord>? records,
    DebugOnlyBridgePolicy? policy,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? blockedBoundaryIds,
    List<String>? supportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    bool? safeForDeveloperInspection,
    DebugOnlyBridgePhase33GRecommendation? recommendation,
    bool? developerOnly,
  }) {
    return DebugOnlyBridgeOutputPacket(
      outputPacketId: outputPacketId ?? this.outputPacketId,
      inputPacketId: inputPacketId ?? this.inputPacketId,
      skeletonVersion: skeletonVersion ?? this.skeletonVersion,
      records: records ?? this.records,
      policy: policy ?? this.policy,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      allowedFieldIds: allowedFieldIds ?? this.allowedFieldIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      safeForDeveloperInspection:
          safeForDeveloperInspection ?? this.safeForDeveloperInspection,
      recommendation: recommendation ?? this.recommendation,
      developerOnly: developerOnly ?? this.developerOnly,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'outputPacketId': outputPacketId,
    'inputPacketId': inputPacketId,
    'skeletonVersion': skeletonVersion,
    'records': records.map((record) => record.toJson()).toList(),
    'policy': policy.toJson(),
    'warningReasons': warningReasons,
    'proofLimitReasons': proofLimitReasons,
    'blockedBoundaryIds': blockedBoundaryIds,
    'supportCaseIds': supportCaseIds,
    'androidProofCaseIds': androidProofCaseIds,
    'allowedFieldIds': allowedFieldIds,
    'deniedFieldIds': deniedFieldIds,
    'safeForDeveloperInspection': safeForDeveloperInspection,
    'recommendation': recommendation.wire,
    'developerOnly': developerOnly,
  };
}

class DebugOnlyBridgeRecord {
  const DebugOnlyBridgeRecord({
    required this.recordId,
    required this.role,
    required this.sourceRecordId,
    required this.sourceImplementationComponentRole,
    required this.designOnly,
    required this.developerOnly,
    required this.contextOnly,
    required this.inactive,
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.supportCaseIds,
    required this.androidProofCaseIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.blockedBoundaryIds,
    required this.safetyFlags,
    required this.recommendation,
  });

  final String recordId;
  final DebugOnlyBridgeRecordRole role;
  final String sourceRecordId;
  final DebugOnlyBridgeImplementationDesignComponentRole
  sourceImplementationComponentRole;
  final bool designOnly;
  final bool developerOnly;
  final bool contextOnly;
  final bool inactive;
  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final List<String> supportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> blockedBoundaryIds;
  final Map<String, bool> safetyFlags;
  final DebugOnlyBridgeSkeletonRecommendation recommendation;

  bool get hasUnsafeOutput =>
      !developerOnly ||
      !designOnly ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId) ||
      safetyFlags.values.any((value) => value);

  DebugOnlyBridgeRecord copyWith({
    String? recordId,
    DebugOnlyBridgeRecordRole? role,
    String? sourceRecordId,
    DebugOnlyBridgeImplementationDesignComponentRole?
    sourceImplementationComponentRole,
    bool? designOnly,
    bool? developerOnly,
    bool? contextOnly,
    bool? inactive,
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    List<String>? supportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? blockedBoundaryIds,
    Map<String, bool>? safetyFlags,
    DebugOnlyBridgeSkeletonRecommendation? recommendation,
  }) {
    return DebugOnlyBridgeRecord(
      recordId: recordId ?? this.recordId,
      role: role ?? this.role,
      sourceRecordId: sourceRecordId ?? this.sourceRecordId,
      sourceImplementationComponentRole:
          sourceImplementationComponentRole ??
          this.sourceImplementationComponentRole,
      designOnly: designOnly ?? this.designOnly,
      developerOnly: developerOnly ?? this.developerOnly,
      contextOnly: contextOnly ?? this.contextOnly,
      inactive: inactive ?? this.inactive,
      allowedFieldIds: allowedFieldIds ?? this.allowedFieldIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      safetyFlags: safetyFlags ?? this.safetyFlags,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'recordId': recordId,
    'role': role.wire,
    'sourceRecordId': sourceRecordId,
    'sourceImplementationComponentRole': sourceImplementationComponentRole.wire,
    'designOnly': designOnly,
    'developerOnly': developerOnly,
    'contextOnly': contextOnly,
    'inactive': inactive,
    'allowedFieldIds': allowedFieldIds,
    'deniedFieldIds': deniedFieldIds,
    'supportCaseIds': supportCaseIds,
    'androidProofCaseIds': androidProofCaseIds,
    'warningReasons': warningReasons,
    'proofLimitReasons': proofLimitReasons,
    'blockedBoundaryIds': blockedBoundaryIds,
    'safetyFlags': safetyFlags,
    'recommendation': recommendation.wire,
  };
}

class DebugOnlyBridgePolicy {
  const DebugOnlyBridgePolicy({
    required this.allowedFieldIds,
    required this.deniedFieldIds,
    required this.capturedAndroidProofIds,
    this.allowProductOutput = false,
    this.allowClassifierLabels = false,
    this.allowNumericScores = false,
    this.allowAggregateScores = false,
    this.allowOfficialMetrics = false,
    this.allowCpLoss = false,
    this.allowWinProbability = false,
    this.allowMoveRanking = false,
    this.allowUi = false,
    this.allowBackend = false,
    this.allowPersistence = false,
    this.allowDirectEngine = false,
    this.allowStockfishCommand = false,
    this.allowRawUci = false,
    this.allowPvDump = false,
    this.allowRuntime = false,
    this.allowExecutablePrototype = false,
    this.allowWiring = false,
  });

  factory DebugOnlyBridgePolicy.safeDefault({
    required Iterable<String> allowedFieldIds,
    required Iterable<String> deniedFieldIds,
    required Iterable<String> capturedAndroidProofIds,
  }) {
    return DebugOnlyBridgePolicy(
      allowedFieldIds: _sortedStrings(allowedFieldIds),
      deniedFieldIds: _sortedStrings(deniedFieldIds),
      capturedAndroidProofIds: _sortedStrings(capturedAndroidProofIds),
    );
  }

  final List<String> allowedFieldIds;
  final List<String> deniedFieldIds;
  final List<String> capturedAndroidProofIds;
  final bool allowProductOutput;
  final bool allowClassifierLabels;
  final bool allowNumericScores;
  final bool allowAggregateScores;
  final bool allowOfficialMetrics;
  final bool allowCpLoss;
  final bool allowWinProbability;
  final bool allowMoveRanking;
  final bool allowUi;
  final bool allowBackend;
  final bool allowPersistence;
  final bool allowDirectEngine;
  final bool allowStockfishCommand;
  final bool allowRawUci;
  final bool allowPvDump;
  final bool allowRuntime;
  final bool allowExecutablePrototype;
  final bool allowWiring;

  bool get hasUnsafeAllowance =>
      allowProductOutput ||
      allowClassifierLabels ||
      allowNumericScores ||
      allowAggregateScores ||
      allowOfficialMetrics ||
      allowCpLoss ||
      allowWinProbability ||
      allowMoveRanking ||
      allowUi ||
      allowBackend ||
      allowPersistence ||
      allowDirectEngine ||
      allowStockfishCommand ||
      allowRawUci ||
      allowPvDump ||
      allowRuntime ||
      allowExecutablePrototype ||
      allowWiring ||
      allowedFieldIds.any(_isDeniedFieldId) ||
      allowedFieldIds.any(_isLegacyDeniedFieldId);

  DebugOnlyBridgePolicy copyWith({
    List<String>? allowedFieldIds,
    List<String>? deniedFieldIds,
    List<String>? capturedAndroidProofIds,
    bool? allowProductOutput,
    bool? allowClassifierLabels,
    bool? allowNumericScores,
    bool? allowAggregateScores,
    bool? allowOfficialMetrics,
    bool? allowCpLoss,
    bool? allowWinProbability,
    bool? allowMoveRanking,
    bool? allowUi,
    bool? allowBackend,
    bool? allowPersistence,
    bool? allowDirectEngine,
    bool? allowStockfishCommand,
    bool? allowRawUci,
    bool? allowPvDump,
    bool? allowRuntime,
    bool? allowExecutablePrototype,
    bool? allowWiring,
  }) {
    return DebugOnlyBridgePolicy(
      allowedFieldIds: allowedFieldIds ?? this.allowedFieldIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      capturedAndroidProofIds:
          capturedAndroidProofIds ?? this.capturedAndroidProofIds,
      allowProductOutput: allowProductOutput ?? this.allowProductOutput,
      allowClassifierLabels:
          allowClassifierLabels ?? this.allowClassifierLabels,
      allowNumericScores: allowNumericScores ?? this.allowNumericScores,
      allowAggregateScores: allowAggregateScores ?? this.allowAggregateScores,
      allowOfficialMetrics: allowOfficialMetrics ?? this.allowOfficialMetrics,
      allowCpLoss: allowCpLoss ?? this.allowCpLoss,
      allowWinProbability: allowWinProbability ?? this.allowWinProbability,
      allowMoveRanking: allowMoveRanking ?? this.allowMoveRanking,
      allowUi: allowUi ?? this.allowUi,
      allowBackend: allowBackend ?? this.allowBackend,
      allowPersistence: allowPersistence ?? this.allowPersistence,
      allowDirectEngine: allowDirectEngine ?? this.allowDirectEngine,
      allowStockfishCommand:
          allowStockfishCommand ?? this.allowStockfishCommand,
      allowRawUci: allowRawUci ?? this.allowRawUci,
      allowPvDump: allowPvDump ?? this.allowPvDump,
      allowRuntime: allowRuntime ?? this.allowRuntime,
      allowExecutablePrototype:
          allowExecutablePrototype ?? this.allowExecutablePrototype,
      allowWiring: allowWiring ?? this.allowWiring,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'allowedFieldIds': allowedFieldIds,
    'deniedFieldIds': deniedFieldIds,
    'capturedAndroidProofIds': capturedAndroidProofIds,
    'allowProductOutput': allowProductOutput,
    'allowClassifierLabels': allowClassifierLabels,
    'allowNumericScores': allowNumericScores,
    'allowAggregateScores': allowAggregateScores,
    'allowOfficialMetrics': allowOfficialMetrics,
    'allowCpLoss': allowCpLoss,
    'allowWinProbability': allowWinProbability,
    'allowMoveRanking': allowMoveRanking,
    'allowUi': allowUi,
    'allowBackend': allowBackend,
    'allowPersistence': allowPersistence,
    'allowDirectEngine': allowDirectEngine,
    'allowStockfishCommand': allowStockfishCommand,
    'allowRawUci': allowRawUci,
    'allowPvDump': allowPvDump,
    'allowRuntime': allowRuntime,
    'allowExecutablePrototype': allowExecutablePrototype,
    'allowWiring': allowWiring,
  };
}

class DebugOnlyBridgeSkeletonFinding {
  const DebugOnlyBridgeSkeletonFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.recordId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final DebugOnlyBridgeSkeletonSeverity severity;
  final String message;
  final String? recordId;
  final String? fieldId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical => severity.isCritical;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'severity': severity.wire,
    'message': message,
    if (recordId != null) 'recordId': recordId,
    if (fieldId != null) 'fieldId': fieldId,
    if (caseId != null) 'caseId': caseId,
  };
}

class DebugOnlyBridgeSkeletonResult {
  const DebugOnlyBridgeSkeletonResult({
    required this.status,
    required this.sourceImplementationDesignStatus,
    required this.sourceImplementationDesignSafeForPhase33F,
    required this.inputPacket,
    required this.outputPacket,
    required this.policy,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalRecords,
    required this.coreRecordCount,
    required this.contextRecordCount,
    required this.inactiveRecordCount,
    required this.deniedBoundaryRecordCount,
    required this.runtimeBlockedRecordCount,
    required this.futureRequirementCount,
    required this.unsafeCount,
    required this.blockerCount,
    required this.criticalCount,
    required this.ownerProofQueueCount,
    required this.safeForPhase33G,
    required this.phase33GRecommendation,
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

  final DebugOnlyBridgeSkeletonStatus status;
  final DebugOnlyBridgeImplementationDesignStatus
  sourceImplementationDesignStatus;
  final bool sourceImplementationDesignSafeForPhase33F;
  final DebugOnlyBridgeInputPacket inputPacket;
  final DebugOnlyBridgeOutputPacket outputPacket;
  final DebugOnlyBridgePolicy policy;
  final List<DebugOnlyBridgeSkeletonFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalRecords;
  final int coreRecordCount;
  final int contextRecordCount;
  final int inactiveRecordCount;
  final int deniedBoundaryRecordCount;
  final int runtimeBlockedRecordCount;
  final int futureRequirementCount;
  final int unsafeCount;
  final int blockerCount;
  final int criticalCount;
  final int ownerProofQueueCount;
  final bool safeForPhase33G;
  final DebugOnlyBridgePhase33GRecommendation phase33GRecommendation;
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
          DebugOnlyBridgeSkeletonStatus.blockedByUnsafeImplementationDesign ||
      status == DebugOnlyBridgeSkeletonStatus.blockedByPolicyBoundary ||
      status == DebugOnlyBridgeSkeletonStatus.invalid ||
      unsafeCount > 0 ||
      blockerCount > 0 ||
      criticalCount > 0;

  bool get hasUnsafeDebugOnlyBridgeDeveloperSkeletonPolicyViolation =>
      status ==
          DebugOnlyBridgeSkeletonStatus.blockedByUnsafeImplementationDesign ||
      status == DebugOnlyBridgeSkeletonStatus.blockedByPolicyBoundary ||
      unsafeCount > 0 ||
      criticalCount > 0 ||
      inputPacket.hasUnsafeInput ||
      outputPacket.hasUnsafeOutput ||
      policy.hasUnsafeAllowance ||
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

  DebugOnlyBridgeRecord recordForRole(DebugOnlyBridgeRecordRole role) {
    return outputPacket.records.singleWhere((record) => record.role == role);
  }

  DebugOnlyBridgeSkeletonResult copyWith({
    DebugOnlyBridgeSkeletonStatus? status,
    DebugOnlyBridgeImplementationDesignStatus? sourceImplementationDesignStatus,
    bool? sourceImplementationDesignSafeForPhase33F,
    DebugOnlyBridgeInputPacket? inputPacket,
    DebugOnlyBridgeOutputPacket? outputPacket,
    DebugOnlyBridgePolicy? policy,
    List<DebugOnlyBridgeSkeletonFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalRecords,
    int? coreRecordCount,
    int? contextRecordCount,
    int? inactiveRecordCount,
    int? deniedBoundaryRecordCount,
    int? runtimeBlockedRecordCount,
    int? futureRequirementCount,
    int? unsafeCount,
    int? blockerCount,
    int? criticalCount,
    int? ownerProofQueueCount,
    bool? safeForPhase33G,
    DebugOnlyBridgePhase33GRecommendation? phase33GRecommendation,
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
    return DebugOnlyBridgeSkeletonResult(
      status: status ?? this.status,
      sourceImplementationDesignStatus:
          sourceImplementationDesignStatus ??
          this.sourceImplementationDesignStatus,
      sourceImplementationDesignSafeForPhase33F:
          sourceImplementationDesignSafeForPhase33F ??
          this.sourceImplementationDesignSafeForPhase33F,
      inputPacket: inputPacket ?? this.inputPacket,
      outputPacket: outputPacket ?? this.outputPacket,
      policy: policy ?? this.policy,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalRecords: totalRecords ?? this.totalRecords,
      coreRecordCount: coreRecordCount ?? this.coreRecordCount,
      contextRecordCount: contextRecordCount ?? this.contextRecordCount,
      inactiveRecordCount: inactiveRecordCount ?? this.inactiveRecordCount,
      deniedBoundaryRecordCount:
          deniedBoundaryRecordCount ?? this.deniedBoundaryRecordCount,
      runtimeBlockedRecordCount:
          runtimeBlockedRecordCount ?? this.runtimeBlockedRecordCount,
      futureRequirementCount:
          futureRequirementCount ?? this.futureRequirementCount,
      unsafeCount: unsafeCount ?? this.unsafeCount,
      blockerCount: blockerCount ?? this.blockerCount,
      criticalCount: criticalCount ?? this.criticalCount,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      safeForPhase33G: safeForPhase33G ?? this.safeForPhase33G,
      phase33GRecommendation:
          phase33GRecommendation ?? this.phase33GRecommendation,
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
      ..writeln('# Debug-Only Bridge Developer Skeleton')
      ..writeln()
      ..writeln('- version: $debugOnlyBridgeDeveloperSkeletonReportVersion')
      ..writeln('- skeleton version: $debugOnlyBridgeDeveloperSkeletonVersion')
      ..writeln('- skeleton status: ${status.wire}')
      ..writeln(
        '- source implementation design status: '
        '${sourceImplementationDesignStatus.wire}',
      )
      ..writeln('- total records: $totalRecords')
      ..writeln('- core record count: $coreRecordCount')
      ..writeln('- context record count: $contextRecordCount')
      ..writeln('- inactive record count: $inactiveRecordCount')
      ..writeln('- denied boundary record count: $deniedBoundaryRecordCount')
      ..writeln('- runtime blocked record count: $runtimeBlockedRecordCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln(
        '- debug bridge runtime implemented: $debugBridgeRuntimeImplemented',
      )
      ..writeln(
        '- executable bridge skeleton implemented: '
        '$executableBridgeSkeletonImplemented',
      )
      ..writeln(
        '- implementation wiring implemented: $implementationWiringImplemented',
      )
      ..writeln('- safeForPhase33G: $safeForPhase33G')
      ..writeln('- Phase 33G recommendation: ${phase33GRecommendation.wire}')
      ..writeln()
      ..writeln('## Input Packet Summary')
      ..writeln('- input packet ID: ${inputPacket.inputPacketId}')
      ..writeln(
        '- source implementation design ID: '
        '${inputPacket.sourceImplementationDesignId}',
      )
      ..writeln(
        '- approved core record IDs: '
        '${_ids(inputPacket.approvedCoreRecordIds)}',
      )
      ..writeln(
        '- constrained context record IDs: '
        '${_ids(inputPacket.constrainedContextRecordIds)}',
      )
      ..writeln(
        '- inactive blocked record IDs: '
        '${_ids(inputPacket.inactiveBlockedRecordIds)}',
      )
      ..writeln(
        '- inactive future record IDs: '
        '${_ids(inputPacket.inactiveFutureRecordIds)}',
      )
      ..writeln()
      ..writeln('## Output Packet Summary')
      ..writeln('- output packet ID: ${outputPacket.outputPacketId}')
      ..writeln(
        '- safe for developer inspection: '
        '${outputPacket.safeForDeveloperInspection}',
      )
      ..writeln('- developer only: ${outputPacket.developerOnly}')
      ..writeln('- recommendation: ${outputPacket.recommendation.wire}')
      ..writeln()
      ..writeln('## Policy Summary')
      ..writeln('- allowed field IDs: ${_ids(policy.allowedFieldIds)}')
      ..writeln('- denied field IDs: ${_ids(policy.deniedFieldIds)}')
      ..writeln(
        '- captured Android proof IDs: '
        '${_ids(policy.capturedAndroidProofIds)}',
      )
      ..writeln('- allow product output: ${policy.allowProductOutput}')
      ..writeln('- allow classifier labels: ${policy.allowClassifierLabels}')
      ..writeln('- allow numeric scores: ${policy.allowNumericScores}')
      ..writeln('- allow aggregate scores: ${policy.allowAggregateScores}')
      ..writeln('- allow official metrics: ${policy.allowOfficialMetrics}')
      ..writeln('- allow CP-loss: ${policy.allowCpLoss}')
      ..writeln('- allow win probability: ${policy.allowWinProbability}')
      ..writeln('- allow move ranking: ${policy.allowMoveRanking}')
      ..writeln('- allow UI: ${policy.allowUi}')
      ..writeln('- allow backend: ${policy.allowBackend}')
      ..writeln('- allow persistence: ${policy.allowPersistence}')
      ..writeln('- allow direct engine: ${policy.allowDirectEngine}')
      ..writeln('- allow Stockfish command: ${policy.allowStockfishCommand}')
      ..writeln('- allow raw UCI: ${policy.allowRawUci}')
      ..writeln('- allow PV dump: ${policy.allowPvDump}')
      ..writeln('- allow runtime: ${policy.allowRuntime}')
      ..writeln(
        '- allow executable prototype: ${policy.allowExecutablePrototype}',
      )
      ..writeln('- allow wiring: ${policy.allowWiring}')
      ..writeln()
      ..writeln('## Bridge Record Table')
      ..writeln(
        '| Record | Role | Source role | Allowed fields | Denied fields | Developer-only | Design-only | Context-only | Inactive | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final record in outputPacket.records) {
      buffer.writeln(
        '| ${record.recordId} | ${record.role.wire} | '
        '${record.sourceImplementationComponentRole.wire} | '
        '${_ids(record.allowedFieldIds)} | ${_ids(record.deniedFieldIds)} | '
        '${record.developerOnly} | ${record.designOnly} | '
        '${record.contextOnly} | ${record.inactive} | '
        '${record.recommendation.wire} |',
      );
    }
    final runtime = recordForRole(DebugOnlyBridgeRecordRole.runtimeBlocked);
    buffer
      ..writeln()
      ..writeln('## Core/Context/Inactive Record Counts')
      ..writeln('- core: $coreRecordCount')
      ..writeln('- context: $contextRecordCount')
      ..writeln('- inactive blocked/future: $inactiveRecordCount')
      ..writeln()
      ..writeln('## Allowed And Denied Field Boundaries')
      ..writeln('- internal allowed field IDs: ${_ids(policy.allowedFieldIds)}')
      ..writeln('- denied field IDs: ${_ids(policy.deniedFieldIds)}')
      ..writeln()
      ..writeln('## Stockfish/Raw UCI/PV Dump Denial')
      ..writeln('- denied engine dump field IDs: ${_ids(_engineDumpFieldIds)}')
      ..writeln()
      ..writeln('## Runtime/Prototype/Wiring Blocked Status')
      ..writeln('- blocked boundary IDs: ${_ids(runtime.blockedBoundaryIds)}')
      ..writeln(
        '- executable bridge skeleton implemented: '
        '$executableBridgeSkeletonImplemented',
      )
      ..writeln()
      ..writeln('## Android Proof Boundary')
      ..writeln(
        '- captured proof IDs: ${_ids(inputPacket.androidProofCaseIds)}',
      )
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
      ..writeln('## Phase 33G Recommendation')
      ..writeln('- ${phase33GRecommendation.wire}');
    return buffer.toString();
  }

  String renderJsonReport() {
    return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'version': debugOnlyBridgeDeveloperSkeletonReportVersion,
      'skeletonVersion': debugOnlyBridgeDeveloperSkeletonVersion,
      'status': status.wire,
      'sourceImplementationDesignStatus': sourceImplementationDesignStatus.wire,
      'sourceImplementationDesignSafeForPhase33F':
          sourceImplementationDesignSafeForPhase33F,
      'inputPacket': inputPacket.toJson(),
      'outputPacket': outputPacket.toJson(),
      'policy': policy.toJson(),
      'validationFindings': validationFindings
          .map((finding) => finding.toJson())
          .toList(),
      'warnings': warnings,
      'failures': failures,
      'totalRecords': totalRecords,
      'coreRecordCount': coreRecordCount,
      'contextRecordCount': contextRecordCount,
      'inactiveRecordCount': inactiveRecordCount,
      'deniedBoundaryRecordCount': deniedBoundaryRecordCount,
      'runtimeBlockedRecordCount': runtimeBlockedRecordCount,
      'futureRequirementCount': futureRequirementCount,
      'unsafeCount': unsafeCount,
      'blockerCount': blockerCount,
      'criticalCount': criticalCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'safeForPhase33G': safeForPhase33G,
      'phase33GRecommendation': phase33GRecommendation.wire,
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

class DebugOnlyBridgeSkeleton {
  const DebugOnlyBridgeSkeleton({
    this.validator = const DebugOnlyBridgeSkeletonValidator(),
  });

  final DebugOnlyBridgeSkeletonValidator validator;

  DebugOnlyBridgeSkeletonResult evaluate([
    DebugOnlyBridgeSkeletonRequest request =
        const DebugOnlyBridgeSkeletonRequest(),
  ]) {
    final implementationDesignResult =
        request.implementationDesignResult ??
        request.implementationDesign.evaluate(
          DebugOnlyBridgeImplementationDesignRequest(
            readinessSummaryValidationResult:
                request.readinessSummaryValidationResult,
            readinessSummaryResult: request.readinessSummaryResult,
            readinessGateResult: request.readinessGateResult,
            prototypeValidationResult: request.prototypeValidationResult,
            prototypeDesignResult: request.prototypeDesignResult,
            bridgeReadinessGateResult: request.bridgeReadinessGateResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final inputPacket = buildInputFromImplementationDesign(
      implementationDesignResult,
    );
    final policy = DebugOnlyBridgePolicy.safeDefault(
      allowedFieldIds: inputPacket.allowedFieldIds,
      deniedFieldIds: inputPacket.deniedFieldIds,
      capturedAndroidProofIds: inputPacket.androidProofCaseIds,
    );
    final records = _recordsFromImplementationDesign(
      implementationDesignResult,
    );
    final outputPacket = DebugOnlyBridgeOutputPacket(
      outputPacketId: 'phase33f-debug-only-bridge-output-packet',
      inputPacketId: inputPacket.inputPacketId,
      skeletonVersion: debugOnlyBridgeDeveloperSkeletonVersion,
      records: records,
      policy: policy,
      warningReasons: inputPacket.warningReasons,
      proofLimitReasons: inputPacket.proofLimitReasons,
      blockedBoundaryIds: inputPacket.blockedBoundaryIds,
      supportCaseIds: inputPacket.supportCaseIds,
      androidProofCaseIds: inputPacket.androidProofCaseIds,
      allowedFieldIds: inputPacket.allowedFieldIds,
      deniedFieldIds: inputPacket.deniedFieldIds,
      safeForDeveloperInspection: true,
      recommendation: DebugOnlyBridgePhase33GRecommendation
          .validateDebugOnlyBridgeDeveloperSkeleton,
    );
    final base = _resultFromSkeleton(
      implementationDesignResult: implementationDesignResult,
      inputPacket: inputPacket,
      outputPacket: outputPacket,
      policy: policy,
      validationFindings: const <DebugOnlyBridgeSkeletonFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromSkeleton(
      implementationDesignResult: implementationDesignResult,
      inputPacket: inputPacket,
      outputPacket: outputPacket,
      policy: policy,
      validationFindings: findings,
    );
  }

  DebugOnlyBridgeInputPacket buildInputFromImplementationDesign(
    DebugOnlyBridgeImplementationDesignResult implementationDesignResult,
  ) {
    return DebugOnlyBridgeInputPacket(
      sourceImplementationDesignId:
          debugOnlyBridgeImplementationDesignReportVersion,
      sourceValidationId: 'phase33d-readiness-summary-validation',
      sourceSummaryId: 'phase33c-readiness-summary',
      sourceGateId: 'phase33b-readiness-gate',
      sourceDesignId: 'phase33a-validated-prototype-design',
      inputPacketId: 'phase33f-debug-only-bridge-input-packet',
      supportCaseIds: _sortedStrings(implementationDesignResult.supportCaseIds),
      newlyAddedSupportCaseIds: _sortedStrings(
        implementationDesignResult.newlyAddedSupportCaseIds,
      ),
      androidProofCaseIds: _sortedStrings(
        implementationDesignResult.androidProofCaseIds,
      ),
      allowedFieldIds: _sortedStrings(
        implementationDesignResult.allowedFieldIds,
      ),
      deniedFieldIds: _sortedStrings(<String>[
        ...implementationDesignResult.deniedFieldIds,
        ..._deniedFieldIds,
      ]),
      approvedCoreRecordIds: _recordIdsForImplementationRoles(
        implementationDesignResult,
        const <DebugOnlyBridgeImplementationDesignComponentRole>[
          DebugOnlyBridgeImplementationDesignComponentRole.bridgeCoreRecord,
        ],
      ),
      constrainedContextRecordIds: _recordIdsForImplementationRoles(
        implementationDesignResult,
        const <DebugOnlyBridgeImplementationDesignComponentRole>[
          DebugOnlyBridgeImplementationDesignComponentRole.bridgeContextRecord,
        ],
      ),
      inactiveBlockedRecordIds: _recordIdsForImplementationRoles(
        implementationDesignResult,
        const <DebugOnlyBridgeImplementationDesignComponentRole>[
          DebugOnlyBridgeImplementationDesignComponentRole
              .bridgeInactiveBlockedRecord,
        ],
      ),
      inactiveFutureRecordIds: _recordIdsForImplementationRoles(
        implementationDesignResult,
        const <DebugOnlyBridgeImplementationDesignComponentRole>[
          DebugOnlyBridgeImplementationDesignComponentRole
              .bridgeInactiveFutureRecord,
        ],
      ),
      warningReasons: _sortedStrings(implementationDesignResult.warnings),
      proofLimitReasons: _sortedStrings(
        implementationDesignResult.implementationDesignRecords.expand(
          (record) => record.proofLimitReasons,
        ),
      ),
      futurePrerequisites: _sortedStrings(
        implementationDesignResult.implementationDesignRecords.expand(
          (record) => record.futurePrerequisites,
        ),
      ),
      blockedBoundaryIds: _sortedStrings(
        implementationDesignResult.implementationDesignRecords.expand(
          (record) => record.blockedBoundaryIds,
        ),
      ),
    );
  }

  DebugOnlyBridgeInputPacket buildInputFromValidatedSummary(
    DebugBridgePrototypeDesignReadinessSummaryValidationResult
    readinessSummaryValidationResult,
  ) {
    List<String> idsFor(DebugBridgePrototypeDesignReadinessSummaryRole role) {
      return _sortedStrings(
        readinessSummaryValidationResult.recordRows
            .where((row) => row.summaryRole == role)
            .map((row) => row.sourceSummaryRecordId),
      );
    }

    return DebugOnlyBridgeInputPacket(
      sourceImplementationDesignId: 'phase33e-implementation-design-pending',
      sourceValidationId:
          debugBridgePrototypeDesignReadinessSummaryValidationReportVersion,
      sourceSummaryId: 'phase33c-readiness-summary',
      sourceGateId: 'phase33b-readiness-gate',
      sourceDesignId: 'phase33a-validated-prototype-design',
      inputPacketId: 'phase33f-debug-only-bridge-input-from-summary',
      supportCaseIds: _sortedStrings(
        readinessSummaryValidationResult.supportCaseIds,
      ),
      newlyAddedSupportCaseIds: _sortedStrings(
        readinessSummaryValidationResult.newlyAddedSupportCaseIds,
      ),
      androidProofCaseIds: _sortedStrings(
        readinessSummaryValidationResult.androidProofCaseIds,
      ),
      allowedFieldIds: _sortedStrings(
        readinessSummaryValidationResult.allowedFieldIds,
      ),
      deniedFieldIds: _sortedStrings(<String>[
        ...readinessSummaryValidationResult.deniedFieldIds,
        ..._deniedFieldIds,
      ]),
      approvedCoreRecordIds: idsFor(
        DebugBridgePrototypeDesignReadinessSummaryRole
            .readinessApprovedPrototypeCoreSummaryRecord,
      ),
      constrainedContextRecordIds: idsFor(
        DebugBridgePrototypeDesignReadinessSummaryRole
            .constrainedPrototypeContextSummaryRecord,
      ),
      inactiveBlockedRecordIds: idsFor(
        DebugBridgePrototypeDesignReadinessSummaryRole
            .inactivePrototypeBlockedSummaryRecord,
      ),
      inactiveFutureRecordIds: idsFor(
        DebugBridgePrototypeDesignReadinessSummaryRole
            .inactivePrototypeFutureOnlySummaryRecord,
      ),
      warningReasons: _sortedStrings(readinessSummaryValidationResult.warnings),
      proofLimitReasons: const <String>[],
      futurePrerequisites: const <String>[
        'phase33FDeveloperOnlyBridgeSkeleton',
      ],
      blockedBoundaryIds: _sortedStrings(
        readinessSummaryValidationResult.recordRows.expand(
          (row) => row.deniedFieldIds,
        ),
      ),
    );
  }

  DebugOnlyBridgeRecord createCoreRecord(
    DebugOnlyBridgeImplementationDesignRecord source,
  ) {
    return _recordFromSource(
      source,
      role: DebugOnlyBridgeRecordRole.core,
      allowedFieldIds: const <String>[],
      deniedFieldIds: const <String>[],
    );
  }

  DebugOnlyBridgeRecord createContextRecord(
    DebugOnlyBridgeImplementationDesignRecord source,
  ) {
    return _recordFromSource(
      source,
      role: DebugOnlyBridgeRecordRole.context,
      allowedFieldIds: const <String>[],
      deniedFieldIds: const <String>[],
    );
  }

  DebugOnlyBridgeRecord preserveInactiveRecord({
    required DebugOnlyBridgeImplementationDesignRecord source,
    required DebugOnlyBridgeRecordRole role,
  }) {
    return _recordFromSource(
      source,
      role: role,
      allowedFieldIds: const <String>[],
      deniedFieldIds: source.deniedFieldIds,
    );
  }

  DebugOnlyBridgeRecord createDeniedFieldBoundaryRecord(
    DebugOnlyBridgeImplementationDesignRecord source, {
    bool stockfishRawUciPvDumpOnly = false,
  }) {
    return _recordFromSource(
      source,
      role: stockfishRawUciPvDumpOnly
          ? DebugOnlyBridgeRecordRole.stockfishRawUciPvDumpDenied
          : DebugOnlyBridgeRecordRole.deniedFieldBoundary,
      allowedFieldIds: const <String>[],
      deniedFieldIds: stockfishRawUciPvDumpOnly
          ? _engineDumpFieldIds
          : <String>[...source.deniedFieldIds, ..._deniedFieldIds],
    );
  }

  DebugOnlyBridgeRecord createRuntimeBlockedRecord(
    DebugOnlyBridgeImplementationDesignRecord source,
  ) {
    return _recordFromSource(
      source,
      role: DebugOnlyBridgeRecordRole.runtimeBlocked,
      allowedFieldIds: const <String>[],
      deniedFieldIds: _engineDumpFieldIds,
    );
  }

  DebugOnlyBridgeRecord createProofBoundaryRecord(
    DebugOnlyBridgeImplementationDesignRecord source,
  ) {
    return _recordFromSource(
      source,
      role: DebugOnlyBridgeRecordRole.proofBoundary,
      allowedFieldIds: const <String>[],
      deniedFieldIds: const <String>[],
    );
  }

  DebugOnlyBridgeRecord createOwnerProofBoundaryRecord(
    DebugOnlyBridgeImplementationDesignRecord source,
  ) {
    return _recordFromSource(
      source,
      role: DebugOnlyBridgeRecordRole.ownerProofBoundary,
      allowedFieldIds: const <String>[],
      deniedFieldIds: const <String>[],
    );
  }

  List<DebugOnlyBridgeSkeletonFinding> validateNoDeniedFields(
    Iterable<String> allowedFieldIds,
  ) {
    return _deniedActiveFindings(allowedFieldIds);
  }

  String renderDeveloperOnlyDebugSnapshot(
    DebugOnlyBridgeSkeletonResult result, {
    DebugOnlyBridgeSkeletonReportFormat format =
        DebugOnlyBridgeSkeletonReportFormat.markdown,
  }) {
    return switch (format) {
      DebugOnlyBridgeSkeletonReportFormat.markdown =>
        result.renderMarkdownReport(),
      DebugOnlyBridgeSkeletonReportFormat.json => result.renderJsonReport(),
    };
  }
}

class DebugOnlyBridgeSkeletonValidator {
  const DebugOnlyBridgeSkeletonValidator();

  List<DebugOnlyBridgeSkeletonFinding> validate(
    DebugOnlyBridgeSkeletonResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <DebugOnlyBridgeSkeletonFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);

    void add({
      required String id,
      required DebugOnlyBridgeSkeletonSeverity severity,
      required String message,
      String? recordId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        DebugOnlyBridgeSkeletonFinding(
          id: id,
          severity: severity,
          message: message,
          recordId: recordId,
          fieldId: fieldId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase33G &&
        (!result.sourceImplementationDesignSafeForPhase33F ||
            result.sourceImplementationDesignStatus ==
                DebugOnlyBridgeImplementationDesignStatus
                    .blockedByUnsafeReadinessValidation ||
            result.sourceImplementationDesignStatus ==
                DebugOnlyBridgeImplementationDesignStatus
                    .blockedByPolicyBoundary ||
            result.unsafeCount > 0)) {
      add(
        id: 'unsafeImplementationDesignInputMarkedSkeletonReady',
        severity: DebugOnlyBridgeSkeletonSeverity.critical,
        message:
            'unsafe Phase 33E implementation design cannot be skeleton-ready',
      );
    }
    if (result.futureRequirementCount != 1) {
      add(
        id: 'missingPhase33FSkeletonRequirement',
        severity: DebugOnlyBridgeSkeletonSeverity.critical,
        message: 'Phase 33F developer skeleton requirement must be present',
      );
    }
    for (final fieldId in _deniedFieldIds) {
      if (!result.policy.deniedFieldIds.contains(fieldId) ||
          !result.inputPacket.deniedFieldIds.contains(fieldId) ||
          !result.outputPacket.deniedFieldIds.contains(fieldId)) {
        add(
          id: 'deniedFieldMissing',
          severity: DebugOnlyBridgeSkeletonSeverity.blocker,
          message: '$fieldId must remain denied',
          fieldId: fieldId,
        );
      }
    }
    for (final fieldId in result.inputPacket.allowedFieldIds) {
      _checkActiveAllowedField(add, fieldId);
    }
    for (final fieldId in result.outputPacket.allowedFieldIds) {
      _checkActiveAllowedField(add, fieldId);
    }
    for (final fieldId in result.policy.allowedFieldIds) {
      _checkActiveAllowedField(add, fieldId);
    }
    if (!_sameStringSet(
          result.inputPacket.androidProofCaseIds,
          _capturedAndroidProofIds,
        ) ||
        !_sameStringSet(
          result.outputPacket.androidProofCaseIds,
          _capturedAndroidProofIds,
        ) ||
        !_sameStringSet(
          result.policy.capturedAndroidProofIds,
          _capturedAndroidProofIds,
        )) {
      add(
        id: 'androidProofBoundaryMismatch',
        severity: DebugOnlyBridgeSkeletonSeverity.critical,
        message: 'Android proof IDs must remain exactly captured proof only',
      );
    }
    for (final caseId in <String>[
      ...result.inputPacket.androidProofCaseIds,
      ...result.outputPacket.androidProofCaseIds,
      ...result.policy.capturedAndroidProofIds,
    ]) {
      _checkAndroidProofCase(add, caseId, provenAndroidIds);
    }
    for (final record in result.outputPacket.records) {
      for (final fieldId in record.allowedFieldIds) {
        _checkActiveAllowedField(add, fieldId, recordId: record.recordId);
      }
      for (final caseId in record.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          recordId: record.recordId,
        );
      }
      _checkRecordBoundary(add, record);
      _checkSafetyFlags(add, record);
    }
    _checkPolicy(add, result.policy);
    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: DebugOnlyBridgeSkeletonSeverity.blocker,
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
        id: 'debugOnlyBridgeDeveloperSkeletonBoundaryPolicyViolation',
        severity: DebugOnlyBridgeSkeletonSeverity.critical,
        message: 'debug-only bridge developer skeleton crossed a boundary',
      );
    }
    return findings..sort(_compareFindings);
  }

  List<DebugOnlyBridgeSkeletonFinding> validateReportText(String reportText) {
    final findings = <DebugOnlyBridgeSkeletonFinding>[];
    void reportError(String id, String message) {
      findings.add(
        DebugOnlyBridgeSkeletonFinding(
          id: id,
          severity: DebugOnlyBridgeSkeletonSeverity.critical,
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
        'report contains active runtime, executable skeleton, or wiring text',
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

List<DebugOnlyBridgeRecord> _recordsFromImplementationDesign(
  DebugOnlyBridgeImplementationDesignResult implementationDesignResult,
) {
  final skeleton = const DebugOnlyBridgeSkeleton();
  final sourceByRole =
      <
        DebugOnlyBridgeImplementationDesignComponentRole,
        DebugOnlyBridgeImplementationDesignRecord
      >{
        for (final record
            in implementationDesignResult.implementationDesignRecords)
          record.componentRole: record,
      };
  return <DebugOnlyBridgeRecord>[
    skeleton.createCoreRecord(
      sourceByRole[DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeCoreRecord]!,
    ),
    skeleton.createContextRecord(
      sourceByRole[DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeContextRecord]!,
    ),
    skeleton.preserveInactiveRecord(
      source:
          sourceByRole[DebugOnlyBridgeImplementationDesignComponentRole
              .bridgeInactiveBlockedRecord]!,
      role: DebugOnlyBridgeRecordRole.inactiveBlocked,
    ),
    skeleton.preserveInactiveRecord(
      source:
          sourceByRole[DebugOnlyBridgeImplementationDesignComponentRole
              .bridgeInactiveFutureRecord]!,
      role: DebugOnlyBridgeRecordRole.inactiveFuture,
    ),
    _recordFromSource(
      sourceByRole[DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeAllowedFieldContract]!,
      role: DebugOnlyBridgeRecordRole.allowedFieldBoundary,
      allowedFieldIds: implementationDesignResult.allowedFieldIds,
      deniedFieldIds: const <String>[],
    ),
    skeleton.createDeniedFieldBoundaryRecord(
      sourceByRole[DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeDeniedFieldContract]!,
    ),
    skeleton.createDeniedFieldBoundaryRecord(
      sourceByRole[DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeRuntimeBlock]!,
      stockfishRawUciPvDumpOnly: true,
    ),
    skeleton.createRuntimeBlockedRecord(
      sourceByRole[DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeRuntimeBlock]!,
    ),
    skeleton.createProofBoundaryRecord(
      sourceByRole[DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeProofBoundary]!,
    ),
    skeleton.createOwnerProofBoundaryRecord(
      sourceByRole[DebugOnlyBridgeImplementationDesignComponentRole
          .bridgeOwnerProofBoundary]!,
    ),
    _recordFromSource(
      sourceByRole[DebugOnlyBridgeImplementationDesignComponentRole
          .phase33FImplementationSkeletonRequirement]!,
      role: DebugOnlyBridgeRecordRole.futureRequirement,
      allowedFieldIds: const <String>[],
      deniedFieldIds: const <String>[],
    ),
  ];
}

DebugOnlyBridgeRecord _recordFromSource(
  DebugOnlyBridgeImplementationDesignRecord source, {
  required DebugOnlyBridgeRecordRole role,
  required Iterable<String> allowedFieldIds,
  required Iterable<String> deniedFieldIds,
}) {
  return DebugOnlyBridgeRecord(
    recordId: 'phase33f-${role.wire}',
    role: role,
    sourceRecordId: source.implementationDesignRecordId,
    sourceImplementationComponentRole: source.componentRole,
    designOnly: true,
    developerOnly: true,
    contextOnly: role == DebugOnlyBridgeRecordRole.context,
    inactive:
        role.isInactiveBoundary ||
        role == DebugOnlyBridgeRecordRole.ownerProofBoundary,
    allowedFieldIds: _sortedStrings(allowedFieldIds),
    deniedFieldIds: _sortedStrings(deniedFieldIds),
    supportCaseIds: _sortedStrings(source.supportCaseIds),
    androidProofCaseIds: role == DebugOnlyBridgeRecordRole.proofBoundary
        ? _sortedStrings(source.androidProofCaseIds)
        : const <String>[],
    warningReasons: _sortedStrings(source.warningReasons),
    proofLimitReasons: _sortedStrings(source.proofLimitReasons),
    blockedBoundaryIds: _blockedBoundaryIdsForSkeletonRole(source, role),
    safetyFlags: _safeFlags(),
    recommendation: _recommendationForRole(role),
  );
}

List<String> _blockedBoundaryIdsForSkeletonRole(
  DebugOnlyBridgeImplementationDesignRecord source,
  DebugOnlyBridgeRecordRole role,
) {
  if (role == DebugOnlyBridgeRecordRole.runtimeBlocked) {
    return _sortedStrings(<String>[
      ...source.blockedBoundaryIds,
      'debugBridgeRuntime',
      'executableBridgeSkeleton',
      'executableDebugBridgePrototype',
      'implementationWiring',
      'schedulerExecution',
      'uiIntegration',
      'backendIntegration',
      'persistenceIntegration',
      'directEngineCall',
      'stockfishCommand',
      'rawUci',
      'pvDump',
    ]);
  }
  if (role == DebugOnlyBridgeRecordRole.stockfishRawUciPvDumpDenied) {
    return _sortedStrings(<String>[
      ...source.blockedBoundaryIds,
      'stockfishCommand',
      'rawUci',
      'pvDump',
    ]);
  }
  return _sortedStrings(source.blockedBoundaryIds);
}

DebugOnlyBridgeSkeletonResult _resultFromSkeleton({
  required DebugOnlyBridgeImplementationDesignResult implementationDesignResult,
  required DebugOnlyBridgeInputPacket inputPacket,
  required DebugOnlyBridgeOutputPacket outputPacket,
  required DebugOnlyBridgePolicy policy,
  required List<DebugOnlyBridgeSkeletonFinding> validationFindings,
}) {
  final records = outputPacket.records;
  final unsafeCount =
      implementationDesignResult.unsafeCount +
      (inputPacket.hasUnsafeInput ? 1 : 0) +
      (outputPacket.hasUnsafeOutput ? 1 : 0) +
      (policy.hasUnsafeAllowance ? 1 : 0) +
      records.where((record) => record.hasUnsafeOutput).length;
  final blockerCount = validationFindings
      .where((finding) => finding.blocksStrict)
      .length;
  final criticalCount = validationFindings
      .where((finding) => finding.isCritical)
      .length;
  final base = DebugOnlyBridgeSkeletonResult(
    status: DebugOnlyBridgeSkeletonStatus.invalid,
    sourceImplementationDesignStatus:
        implementationDesignResult.implementationDesignStatus,
    sourceImplementationDesignSafeForPhase33F:
        implementationDesignResult.safeForPhase33F,
    inputPacket: inputPacket,
    outputPacket: outputPacket,
    policy: policy,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...implementationDesignResult.warnings,
      'Phase 33F creates a developer-only skeleton; it remains unwired and engine-free',
    ]),
    failures: _sortedStrings(<String>[
      ...implementationDesignResult.failures,
      ...validationFindings.map((finding) => finding.message),
    ]),
    totalRecords: records.length,
    coreRecordCount: _countRole(records, DebugOnlyBridgeRecordRole.core),
    contextRecordCount: _countRole(records, DebugOnlyBridgeRecordRole.context),
    inactiveRecordCount:
        _countRole(records, DebugOnlyBridgeRecordRole.inactiveBlocked) +
        _countRole(records, DebugOnlyBridgeRecordRole.inactiveFuture),
    deniedBoundaryRecordCount:
        _countRole(records, DebugOnlyBridgeRecordRole.deniedFieldBoundary) +
        _countRole(
          records,
          DebugOnlyBridgeRecordRole.stockfishRawUciPvDumpDenied,
        ),
    runtimeBlockedRecordCount: _countRole(
      records,
      DebugOnlyBridgeRecordRole.runtimeBlocked,
    ),
    futureRequirementCount: _countRole(
      records,
      DebugOnlyBridgeRecordRole.futureRequirement,
    ),
    unsafeCount: unsafeCount,
    blockerCount: blockerCount,
    criticalCount: criticalCount,
    ownerProofQueueCount: implementationDesignResult.ownerProofQueueCount,
    safeForPhase33G: false,
    phase33GRecommendation:
        DebugOnlyBridgePhase33GRecommendation.addMoreGoldenCoverageFirst,
    developerOnly: implementationDesignResult.developerOnly,
    debugBridgeRuntimeImplemented:
        implementationDesignResult.debugBridgeRuntimeImplemented,
    executableBridgeSkeletonImplemented:
        implementationDesignResult.executableBridgeSkeletonImplemented,
    executableDebugBridgePrototypeImplemented:
        implementationDesignResult.executableDebugBridgePrototypeImplemented,
    implementationWiringImplemented:
        implementationDesignResult.implementationWiringImplemented,
    productOutputActive: implementationDesignResult.productOutputActive,
    classifierOutputActive: implementationDesignResult.classifierOutputActive,
    finalMoveLabelOutputActive:
        implementationDesignResult.finalMoveLabelOutputActive,
    officialMetricOutputActive:
        implementationDesignResult.officialMetricOutputActive,
    cpLossOutputActive: implementationDesignResult.cpLossOutputActive,
    winProbabilityOutputActive:
        implementationDesignResult.winProbabilityOutputActive,
    numericOutputActive: implementationDesignResult.numericOutputActive,
    aggregateScoreOutputActive:
        implementationDesignResult.aggregateScoreOutputActive,
    moveRankingOutputActive: implementationDesignResult.moveRankingOutputActive,
    quietPreparatoryScopeActivated:
        implementationDesignResult.quietPreparatoryScopeActivated,
    engineCallsActive: implementationDesignResult.engineCallsActive,
    persistenceWritesActive: implementationDesignResult.persistenceWritesActive,
    uiTargetsActive: implementationDesignResult.uiTargetsActive,
    backendOutputActive: implementationDesignResult.backendOutputActive,
    stockfishCommandFieldActive:
        implementationDesignResult.stockfishCommandFieldActive,
    rawUciFieldActive: implementationDesignResult.rawUciFieldActive,
    pvDumpFieldActive: implementationDesignResult.pvDumpFieldActive,
  );
  final status = _skeletonStatusFor(base);
  final safeForPhase33G =
      (status == DebugOnlyBridgeSkeletonStatus.skeletonReadyWithWarnings ||
          status == DebugOnlyBridgeSkeletonStatus.skeletonReadyClean) &&
      implementationDesignResult.safeForPhase33F &&
      !implementationDesignResult.isStrictlyBlocked &&
      !implementationDesignResult
          .hasUnsafeDebugOnlyBridgeImplementationDesignPolicyViolation &&
      unsafeCount == 0 &&
      blockerCount == 0 &&
      criticalCount == 0 &&
      outputPacket.safeForDeveloperInspection &&
      !outputPacket.hasUnsafeOutput &&
      !policy.hasUnsafeAllowance &&
      records.every((record) => !record.hasUnsafeOutput);
  return base.copyWith(
    status: status,
    safeForPhase33G: safeForPhase33G,
    phase33GRecommendation: _phase33GRecommendationFor(
      status: status,
      safeForPhase33G: safeForPhase33G,
      ownerProofQueueCount: implementationDesignResult.ownerProofQueueCount,
    ),
    outputPacket: outputPacket.copyWith(
      recommendation: _phase33GRecommendationFor(
        status: status,
        safeForPhase33G: safeForPhase33G,
        ownerProofQueueCount: implementationDesignResult.ownerProofQueueCount,
      ),
      safeForDeveloperInspection: safeForPhase33G,
    ),
  );
}

DebugOnlyBridgeSkeletonStatus _skeletonStatusFor(
  DebugOnlyBridgeSkeletonResult result,
) {
  if (result.policy.hasUnsafeAllowance ||
      result.outputPacket.hasUnsafeOutput ||
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
    return DebugOnlyBridgeSkeletonStatus.blockedByPolicyBoundary;
  }
  if (result.sourceImplementationDesignStatus ==
          DebugOnlyBridgeImplementationDesignStatus
              .blockedByUnsafeReadinessValidation ||
      result.sourceImplementationDesignStatus ==
          DebugOnlyBridgeImplementationDesignStatus.blockedByPolicyBoundary ||
      !result.sourceImplementationDesignSafeForPhase33F ||
      result.unsafeCount > 0 ||
      result.criticalCount > 0) {
    return DebugOnlyBridgeSkeletonStatus.blockedByUnsafeImplementationDesign;
  }
  if (result.blockerCount > 0 ||
      result.futureRequirementCount != 1 ||
      result.outputPacket.records.isEmpty) {
    return DebugOnlyBridgeSkeletonStatus.invalid;
  }
  if (result.warnings.isNotEmpty) {
    return DebugOnlyBridgeSkeletonStatus.skeletonReadyWithWarnings;
  }
  return DebugOnlyBridgeSkeletonStatus.skeletonReadyClean;
}

DebugOnlyBridgePhase33GRecommendation _phase33GRecommendationFor({
  required DebugOnlyBridgeSkeletonStatus status,
  required bool safeForPhase33G,
  required int ownerProofQueueCount,
}) {
  if (status ==
          DebugOnlyBridgeSkeletonStatus.blockedByUnsafeImplementationDesign ||
      status == DebugOnlyBridgeSkeletonStatus.blockedByPolicyBoundary) {
    return DebugOnlyBridgePhase33GRecommendation
        .blockedByUnsafeDeveloperSkeleton;
  }
  if (ownerProofQueueCount > 0) {
    return DebugOnlyBridgePhase33GRecommendation.runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase33G) {
    return DebugOnlyBridgePhase33GRecommendation.addMoreGoldenCoverageFirst;
  }
  return DebugOnlyBridgePhase33GRecommendation
      .validateDebugOnlyBridgeDeveloperSkeleton;
}

void _checkRecordBoundary(
  void Function({
    required String id,
    required DebugOnlyBridgeSkeletonSeverity severity,
    required String message,
    String? recordId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugOnlyBridgeRecord record,
) {
  if (!record.designOnly || !record.developerOnly) {
    add(
      id: 'skeletonRecordNotDeveloperOnly',
      severity: DebugOnlyBridgeSkeletonSeverity.critical,
      message: 'skeleton records must stay developer-only and design-only',
      recordId: record.recordId,
    );
  }
  if (record.role == DebugOnlyBridgeRecordRole.core) {
    if (record.contextOnly ||
        record.inactive ||
        record.sourceImplementationComponentRole !=
            DebugOnlyBridgeImplementationDesignComponentRole.bridgeCoreRecord) {
      add(
        id: 'coreRecordConsumesNonCoreInput',
        severity: DebugOnlyBridgeSkeletonSeverity.critical,
        message: 'core skeleton record can consume only approved core input',
        recordId: record.recordId,
      );
    }
  }
  if (record.role == DebugOnlyBridgeRecordRole.context) {
    if (!record.contextOnly ||
        record.sourceImplementationComponentRole !=
            DebugOnlyBridgeImplementationDesignComponentRole
                .bridgeContextRecord) {
      add(
        id: 'contextRecordPromotedToCore',
        severity: DebugOnlyBridgeSkeletonSeverity.critical,
        message: 'context skeleton record must stay context-only',
        recordId: record.recordId,
      );
    }
  }
  if (record.contextOnly && record.role == DebugOnlyBridgeRecordRole.core) {
    add(
      id: 'contextRecordPromotedToCore',
      severity: DebugOnlyBridgeSkeletonSeverity.critical,
      message: 'context-only record cannot become core',
      recordId: record.recordId,
    );
  }
  if (record.role == DebugOnlyBridgeRecordRole.inactiveBlocked &&
      (!record.inactive ||
          record.sourceImplementationComponentRole !=
              DebugOnlyBridgeImplementationDesignComponentRole
                  .bridgeInactiveBlockedRecord)) {
    add(
      id: 'blockedFutureRecordMadeActive',
      severity: DebugOnlyBridgeSkeletonSeverity.critical,
      message: 'blocked skeleton record must remain inactive',
      recordId: record.recordId,
    );
  }
  if (record.role == DebugOnlyBridgeRecordRole.inactiveFuture &&
      (!record.inactive ||
          record.sourceImplementationComponentRole !=
              DebugOnlyBridgeImplementationDesignComponentRole
                  .bridgeInactiveFutureRecord)) {
    add(
      id: 'blockedFutureRecordMadeActive',
      severity: DebugOnlyBridgeSkeletonSeverity.critical,
      message: 'future skeleton record must remain inactive',
      recordId: record.recordId,
    );
  }
  if (record.role.isInactiveBoundary &&
      (!record.inactive || record.allowedFieldIds.isNotEmpty)) {
    add(
      id: 'blockedFutureRecordMadeActive',
      severity: DebugOnlyBridgeSkeletonSeverity.critical,
      message:
          'blocked, future, denied, Stockfish, and runtime records must stay inactive',
      recordId: record.recordId,
    );
  }
}

void _checkSafetyFlags(
  void Function({
    required String id,
    required DebugOnlyBridgeSkeletonSeverity severity,
    required String message,
    String? recordId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugOnlyBridgeRecord record,
) {
  void critical(String id, String message) {
    add(
      id: id,
      severity: DebugOnlyBridgeSkeletonSeverity.critical,
      message: message,
      recordId: record.recordId,
    );
  }

  if (record.safetyFlags['isProductOutput'] == true) {
    critical('productOutputActive', 'skeleton cannot be product output');
  }
  if (record.safetyFlags['isClassifierLabel'] == true) {
    critical(
      'classifierLabelOutputActive',
      'skeleton cannot emit classifier labels',
    );
  }
  if (record.safetyFlags['hasNumericScore'] == true) {
    critical('numericScoreOutputActive', 'skeleton cannot emit numeric scores');
  }
  if (record.safetyFlags['hasAggregateScore'] == true) {
    critical(
      'aggregateScoreOutputActive',
      'skeleton cannot emit aggregate scores',
    );
  }
  if (record.safetyFlags['ranksMoves'] == true) {
    critical('moveRankingOutputActive', 'skeleton cannot rank moves');
  }
  if (record.safetyFlags['isOfficialMetric'] == true) {
    critical(
      'officialMetricOutputActive',
      'skeleton cannot emit official metrics',
    );
  }
  if (record.safetyFlags['exposesCpLoss'] == true ||
      record.safetyFlags['exposesWinProbability'] == true) {
    critical(
      'futureMetricOutputActive',
      'skeleton cannot expose CP-loss or win probability',
    );
  }
  if (record.safetyFlags['quietPreparatoryScopeActive'] == true) {
    critical(
      'quietPreparatoryScopeActivated',
      'quiet/preparatory scope must remain excluded',
    );
  }
  if (record.safetyFlags['callsEngine'] == true) {
    critical('engineCallFlagActive', 'skeleton cannot call an engine');
  }
  if (record.safetyFlags['writesPersistence'] == true) {
    critical('persistenceWriteFlagActive', 'skeleton cannot write persistence');
  }
  if (record.safetyFlags['targetsUi'] == true) {
    critical('uiTargetFlagActive', 'skeleton cannot target UI');
  }
  if (record.safetyFlags['targetsBackend'] == true) {
    critical('backendOutputActive', 'skeleton cannot target backend');
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
      'skeleton cannot implement runtime behavior',
    );
  }
  if (record.safetyFlags['implementsExecutablePrototype'] == true) {
    critical(
      'executablePrototypeImplementationFlagActive',
      'skeleton cannot implement executable prototype behavior',
    );
  }
  if (record.safetyFlags['implementsWiring'] == true) {
    critical(
      'implementationWiringFlagActive',
      'skeleton cannot implement wiring',
    );
  }
}

void _checkPolicy(
  void Function({
    required String id,
    required DebugOnlyBridgeSkeletonSeverity severity,
    required String message,
    String? recordId,
    String? fieldId,
    String? caseId,
  })
  add,
  DebugOnlyBridgePolicy policy,
) {
  if (policy.hasUnsafeAllowance) {
    add(
      id: 'debugOnlyBridgePolicyBoundaryViolation',
      severity: DebugOnlyBridgeSkeletonSeverity.critical,
      message: 'debug-only bridge policy enabled a blocked output boundary',
    );
  }
}

void _checkActiveAllowedField(
  void Function({
    required String id,
    required DebugOnlyBridgeSkeletonSeverity severity,
    required String message,
    String? recordId,
    String? fieldId,
    String? caseId,
  })
  add,
  String fieldId, {
  String? recordId,
}) {
  if (_isDeniedFieldId(fieldId) || _isLegacyDeniedFieldId(fieldId)) {
    add(
      id: 'activeDeniedField',
      severity: DebugOnlyBridgeSkeletonSeverity.critical,
      message: '$fieldId cannot be active skeleton output',
      recordId: recordId,
      fieldId: fieldId,
    );
  }
}

void _checkAndroidProofCase(
  void Function({
    required String id,
    required DebugOnlyBridgeSkeletonSeverity severity,
    required String message,
    String? recordId,
    String? fieldId,
    String? caseId,
  })
  add,
  String caseId,
  List<String> provenAndroidIds, {
  String? recordId,
}) {
  if (_phase32ECaseIds.contains(caseId)) {
    add(
      id: 'phase32ECaseTreatedAsCapturedProof',
      severity: DebugOnlyBridgeSkeletonSeverity.critical,
      message: '$caseId cannot be treated as captured Android proof',
      recordId: recordId,
      caseId: caseId,
    );
    return;
  }
  if (!_capturedAndroidProofIds.contains(caseId) ||
      !provenAndroidIds.contains(caseId)) {
    add(
      id: 'unprovenAndroidProofId',
      severity: DebugOnlyBridgeSkeletonSeverity.critical,
      message: '$caseId is not captured Android proof',
      recordId: recordId,
      caseId: caseId,
    );
  }
}

List<DebugOnlyBridgeSkeletonFinding> _deniedActiveFindings(
  Iterable<String> allowedFieldIds,
) {
  final findings = <DebugOnlyBridgeSkeletonFinding>[];
  for (final fieldId in allowedFieldIds) {
    if (_isDeniedFieldId(fieldId) || _isLegacyDeniedFieldId(fieldId)) {
      findings.add(
        DebugOnlyBridgeSkeletonFinding(
          id: 'activeDeniedField',
          severity: DebugOnlyBridgeSkeletonSeverity.critical,
          message: '$fieldId cannot be active skeleton output',
          fieldId: fieldId,
        ),
      );
    }
  }
  return findings..sort(_compareFindings);
}

DebugOnlyBridgeSkeletonRecommendation _recommendationForRole(
  DebugOnlyBridgeRecordRole role,
) {
  return switch (role) {
    DebugOnlyBridgeRecordRole.core =>
      DebugOnlyBridgeSkeletonRecommendation.keepCoreDeveloperOnly,
    DebugOnlyBridgeRecordRole.context =>
      DebugOnlyBridgeSkeletonRecommendation.keepContextContextOnly,
    DebugOnlyBridgeRecordRole.inactiveBlocked ||
    DebugOnlyBridgeRecordRole.inactiveFuture =>
      DebugOnlyBridgeSkeletonRecommendation.keepInactiveRecordInactive,
    DebugOnlyBridgeRecordRole.allowedFieldBoundary =>
      DebugOnlyBridgeSkeletonRecommendation.keepAllowedFieldBoundaryInternal,
    DebugOnlyBridgeRecordRole.deniedFieldBoundary =>
      DebugOnlyBridgeSkeletonRecommendation.keepDeniedFieldBoundaryDenied,
    DebugOnlyBridgeRecordRole.stockfishRawUciPvDumpDenied =>
      DebugOnlyBridgeSkeletonRecommendation.keepStockfishRawUciPvDumpDenied,
    DebugOnlyBridgeRecordRole.runtimeBlocked =>
      DebugOnlyBridgeSkeletonRecommendation.keepRuntimePrototypeWiringBlocked,
    DebugOnlyBridgeRecordRole.proofBoundary =>
      DebugOnlyBridgeSkeletonRecommendation.keepProofBoundaryCapturedOnly,
    DebugOnlyBridgeRecordRole.ownerProofBoundary =>
      DebugOnlyBridgeSkeletonRecommendation.keepOwnerProofEmpty,
    DebugOnlyBridgeRecordRole.futureRequirement =>
      DebugOnlyBridgeSkeletonRecommendation.keepFutureRequirementDeveloperOnly,
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
    'implementsRuntime': false,
    'implementsExecutablePrototype': false,
    'implementsWiring': false,
  };
}

bool _hasExplicitPvProofReason(DebugOnlyBridgeSkeletonResult result) {
  final reasons = <String>[
    ...result.warnings,
    ...result.failures,
    ...result.inputPacket.proofLimitReasons,
    ...result.outputPacket.proofLimitReasons,
  ].join(' ').toLowerCase();
  return reasons.contains('pv') || reasons.contains('multipv');
}

int _countRole(
  Iterable<DebugOnlyBridgeRecord> records,
  DebugOnlyBridgeRecordRole role,
) {
  return records.where((record) => record.role == role).length;
}

List<String> _recordIdsForImplementationRoles(
  DebugOnlyBridgeImplementationDesignResult implementationDesignResult,
  Iterable<DebugOnlyBridgeImplementationDesignComponentRole> roles,
) {
  final roleSet = roles.toSet();
  return _sortedStrings(
    implementationDesignResult.implementationDesignRecords
        .where((record) => roleSet.contains(record.componentRole))
        .map((record) => record.implementationDesignRecordId),
  );
}

List<String> _provenAndroidProofIds(GoldenAndroidProofEvidence? evidence) {
  return _sortedStrings(evidence?.targetCaseIds ?? const <String>[]);
}

int _compareFindings(
  DebugOnlyBridgeSkeletonFinding a,
  DebugOnlyBridgeSkeletonFinding b,
) {
  final severity = _severityRank(
    b.severity,
  ).compareTo(_severityRank(a.severity));
  if (severity != 0) return severity;
  final id = a.id.compareTo(b.id);
  if (id != 0) return id;
  return (a.recordId ?? '').compareTo(b.recordId ?? '');
}

int _severityRank(DebugOnlyBridgeSkeletonSeverity severity) {
  return switch (severity) {
    DebugOnlyBridgeSkeletonSeverity.warning => 1,
    DebugOnlyBridgeSkeletonSeverity.blocker => 2,
    DebugOnlyBridgeSkeletonSeverity.critical => 3,
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

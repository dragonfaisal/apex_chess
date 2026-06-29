import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton_diagnostic.dart';

const debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightVersion =
    'debug-only-bridge-analyzer-adapter-controlled-runtime-input-preflight-v1';

enum DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightStatus {
  controlledAnalyzerAdapterRuntimeInputPreflightReadyWithWarnings(
    'controlledAnalyzerAdapterRuntimeInputPreflightReadyWithWarnings',
  ),
  controlledAnalyzerAdapterRuntimeInputPreflightReadyClean(
    'controlledAnalyzerAdapterRuntimeInputPreflightReadyClean',
  ),
  blockedByUnsafeDisabledRuntimeExecutionSeamProbeDiagnostic(
    'blockedByUnsafeDisabledRuntimeExecutionSeamProbeDiagnostic',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidControlledRuntimeInputPreflight(
    'invalidControlledRuntimeInputPreflight',
  );

  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightStatus(
    this.wire,
  );

  final String wire;
}

class ControlledAnalyzerAdapterRuntimeInputPreflightInput {
  const ControlledAnalyzerAdapterRuntimeInputPreflightInput({
    required this.preflightId,
    required this.sourcePhase,
    required this.sourceDiagnosticIds,
    required this.sourceSeamProbeIds,
    required this.sourcePreflightIds,
    required this.sourceSkeletonIds,
    required this.sourcePreparationIds,
    required this.sourceCaseIds,
    required this.sourceActionIds,
    required this.sourcePatchIds,
    required this.sourceRefinementIds,
    required this.checkIds,
    required this.decisionId,
    required this.blockedReasonIds,
    required this.deniedFieldIds,
    required this.supportAreaIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.androidProofIds,
    required this.ownerProofRequired,
    required this.seamProbeRequested,
    required this.seamProbePerformed,
    required this.executionPerformed,
    required this.executionAllowed,
    required this.runtimeExecutionApproved,
    required this.analyzerRuntimeInputApproved,
    required this.analyzerRuntimeInputProduced,
    required this.analyzerWiringAllowed,
    required this.engineCallsAllowed,
    required this.schedulerAllowed,
    required this.persistenceAllowed,
    required this.productOutputAllowed,
    required this.productAdapterAllowed,
    required this.savedAnalysisAllowed,
    required this.recommendation,
  });

  final String preflightId;
  final String sourcePhase;
  final List<String> sourceDiagnosticIds;
  final List<String> sourceSeamProbeIds;
  final List<String> sourcePreflightIds;
  final List<String> sourceSkeletonIds;
  final List<String> sourcePreparationIds;
  final List<String> sourceCaseIds;
  final List<String> sourceActionIds;
  final List<String> sourcePatchIds;
  final List<String> sourceRefinementIds;
  final List<String> checkIds;
  final String decisionId;
  final List<String> blockedReasonIds;
  final List<String> deniedFieldIds;
  final List<String> supportAreaIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofIds;
  final bool ownerProofRequired;
  final bool seamProbeRequested;
  final bool seamProbePerformed;
  final bool executionPerformed;
  final bool executionAllowed;
  final bool runtimeExecutionApproved;
  final bool analyzerRuntimeInputApproved;
  final bool analyzerRuntimeInputProduced;
  final bool analyzerWiringAllowed;
  final bool engineCallsAllowed;
  final bool schedulerAllowed;
  final bool persistenceAllowed;
  final bool productOutputAllowed;
  final bool productAdapterAllowed;
  final bool savedAnalysisAllowed;
  final String recommendation;

  ControlledAnalyzerAdapterRuntimeInputPreflightInput copyWith({
    String? preflightId,
    String? sourcePhase,
    List<String>? sourceDiagnosticIds,
    List<String>? sourceSeamProbeIds,
    List<String>? sourcePreflightIds,
    List<String>? sourceSkeletonIds,
    List<String>? sourcePreparationIds,
    List<String>? sourceCaseIds,
    List<String>? sourceActionIds,
    List<String>? sourcePatchIds,
    List<String>? sourceRefinementIds,
    List<String>? checkIds,
    String? decisionId,
    List<String>? blockedReasonIds,
    List<String>? deniedFieldIds,
    List<String>? supportAreaIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? androidProofIds,
    bool? ownerProofRequired,
    bool? seamProbeRequested,
    bool? seamProbePerformed,
    bool? executionPerformed,
    bool? executionAllowed,
    bool? runtimeExecutionApproved,
    bool? analyzerRuntimeInputApproved,
    bool? analyzerRuntimeInputProduced,
    bool? analyzerWiringAllowed,
    bool? engineCallsAllowed,
    bool? schedulerAllowed,
    bool? persistenceAllowed,
    bool? productOutputAllowed,
    bool? productAdapterAllowed,
    bool? savedAnalysisAllowed,
    String? recommendation,
  }) {
    return ControlledAnalyzerAdapterRuntimeInputPreflightInput(
      preflightId: preflightId ?? this.preflightId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      sourceDiagnosticIds: sourceDiagnosticIds ?? this.sourceDiagnosticIds,
      sourceSeamProbeIds: sourceSeamProbeIds ?? this.sourceSeamProbeIds,
      sourcePreflightIds: sourcePreflightIds ?? this.sourcePreflightIds,
      sourceSkeletonIds: sourceSkeletonIds ?? this.sourceSkeletonIds,
      sourcePreparationIds: sourcePreparationIds ?? this.sourcePreparationIds,
      sourceCaseIds: sourceCaseIds ?? this.sourceCaseIds,
      sourceActionIds: sourceActionIds ?? this.sourceActionIds,
      sourcePatchIds: sourcePatchIds ?? this.sourcePatchIds,
      sourceRefinementIds: sourceRefinementIds ?? this.sourceRefinementIds,
      checkIds: checkIds ?? this.checkIds,
      decisionId: decisionId ?? this.decisionId,
      blockedReasonIds: blockedReasonIds ?? this.blockedReasonIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      supportAreaIds: supportAreaIds ?? this.supportAreaIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      androidProofIds: androidProofIds ?? this.androidProofIds,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      seamProbeRequested: seamProbeRequested ?? this.seamProbeRequested,
      seamProbePerformed: seamProbePerformed ?? this.seamProbePerformed,
      executionPerformed: executionPerformed ?? this.executionPerformed,
      executionAllowed: executionAllowed ?? this.executionAllowed,
      runtimeExecutionApproved:
          runtimeExecutionApproved ?? this.runtimeExecutionApproved,
      analyzerRuntimeInputApproved:
          analyzerRuntimeInputApproved ?? this.analyzerRuntimeInputApproved,
      analyzerRuntimeInputProduced:
          analyzerRuntimeInputProduced ?? this.analyzerRuntimeInputProduced,
      analyzerWiringAllowed:
          analyzerWiringAllowed ?? this.analyzerWiringAllowed,
      engineCallsAllowed: engineCallsAllowed ?? this.engineCallsAllowed,
      schedulerAllowed: schedulerAllowed ?? this.schedulerAllowed,
      persistenceAllowed: persistenceAllowed ?? this.persistenceAllowed,
      productOutputAllowed: productOutputAllowed ?? this.productOutputAllowed,
      productAdapterAllowed:
          productAdapterAllowed ?? this.productAdapterAllowed,
      savedAnalysisAllowed: savedAnalysisAllowed ?? this.savedAnalysisAllowed,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'preflightId': preflightId,
      'sourcePhase': sourcePhase,
      'sourceDiagnosticIds': sourceDiagnosticIds,
      'sourceSeamProbeIds': sourceSeamProbeIds,
      'sourcePreflightIds': sourcePreflightIds,
      'sourceSkeletonIds': sourceSkeletonIds,
      'sourcePreparationIds': sourcePreparationIds,
      'sourceCaseIds': sourceCaseIds,
      'sourceActionIds': sourceActionIds,
      'sourcePatchIds': sourcePatchIds,
      'sourceRefinementIds': sourceRefinementIds,
      'checkIds': checkIds,
      'decisionId': decisionId,
      'blockedReasonIds': blockedReasonIds,
      'deniedFieldIds': deniedFieldIds,
      'supportAreaIds': supportAreaIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'androidProofIds': androidProofIds,
      'ownerProofRequired': ownerProofRequired,
      'seamProbeRequested': seamProbeRequested,
      'seamProbePerformed': seamProbePerformed,
      'executionPerformed': executionPerformed,
      'executionAllowed': executionAllowed,
      'runtimeExecutionApproved': runtimeExecutionApproved,
      'analyzerRuntimeInputApproved': analyzerRuntimeInputApproved,
      'analyzerRuntimeInputProduced': analyzerRuntimeInputProduced,
      'analyzerWiringAllowed': analyzerWiringAllowed,
      'engineCallsAllowed': engineCallsAllowed,
      'schedulerAllowed': schedulerAllowed,
      'persistenceAllowed': persistenceAllowed,
      'productOutputAllowed': productOutputAllowed,
      'productAdapterAllowed': productAdapterAllowed,
      'savedAnalysisAllowed': savedAnalysisAllowed,
      'recommendation': recommendation,
    };
  }
}

class ControlledAnalyzerAdapterRuntimeInputPreflightCheck {
  const ControlledAnalyzerAdapterRuntimeInputPreflightCheck({
    required this.checkId,
    required this.checkStatus,
    required this.passed,
    required this.inspectedFieldIds,
    required this.blockedReasonIds,
    required this.deniedFieldIds,
    required this.warningReasons,
    required this.recommendation,
  });

  final String checkId;
  final String checkStatus;
  final bool passed;
  final List<String> inspectedFieldIds;
  final List<String> blockedReasonIds;
  final List<String> deniedFieldIds;
  final List<String> warningReasons;
  final String recommendation;

  ControlledAnalyzerAdapterRuntimeInputPreflightCheck copyWith({
    String? checkId,
    String? checkStatus,
    bool? passed,
    List<String>? inspectedFieldIds,
    List<String>? blockedReasonIds,
    List<String>? deniedFieldIds,
    List<String>? warningReasons,
    String? recommendation,
  }) {
    return ControlledAnalyzerAdapterRuntimeInputPreflightCheck(
      checkId: checkId ?? this.checkId,
      checkStatus: checkStatus ?? this.checkStatus,
      passed: passed ?? this.passed,
      inspectedFieldIds: inspectedFieldIds ?? this.inspectedFieldIds,
      blockedReasonIds: blockedReasonIds ?? this.blockedReasonIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      warningReasons: warningReasons ?? this.warningReasons,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'checkId': checkId,
      'checkStatus': checkStatus,
      'passed': passed,
      'inspectedFieldIds': inspectedFieldIds,
      'blockedReasonIds': blockedReasonIds,
      'deniedFieldIds': deniedFieldIds,
      'warningReasons': warningReasons,
      'recommendation': recommendation,
    };
  }
}

class ControlledAnalyzerAdapterRuntimeInputPreflightPolicy {
  const ControlledAnalyzerAdapterRuntimeInputPreflightPolicy({
    required this.policyId,
    required this.deniedFieldIds,
    required this.seamProbeAllowed,
    required this.executionAllowed,
    required this.runtimeExecutionApproved,
    required this.analyzerRuntimeInputApproved,
    required this.analyzerRuntimeInputProduced,
    required this.analyzerWiringAllowed,
    required this.engineCallsAllowed,
    required this.schedulerAllowed,
    required this.persistenceAllowed,
    required this.productOutputAllowed,
    required this.productAdapterAllowed,
    required this.savedAnalysisAllowed,
    required this.uiAllowed,
    required this.backendAllowed,
    required this.cacheAllowed,
    required this.databaseAllowed,
  });

  factory ControlledAnalyzerAdapterRuntimeInputPreflightPolicy.disabled({
    required Iterable<String> deniedFieldIds,
  }) {
    return ControlledAnalyzerAdapterRuntimeInputPreflightPolicy(
      policyId: 'controlled-runtime-input-preflight-policy',
      deniedFieldIds: _sorted(deniedFieldIds),
      seamProbeAllowed: false,
      executionAllowed: false,
      runtimeExecutionApproved: false,
      analyzerRuntimeInputApproved: false,
      analyzerRuntimeInputProduced: false,
      analyzerWiringAllowed: false,
      engineCallsAllowed: false,
      schedulerAllowed: false,
      persistenceAllowed: false,
      productOutputAllowed: false,
      productAdapterAllowed: false,
      savedAnalysisAllowed: false,
      uiAllowed: false,
      backendAllowed: false,
      cacheAllowed: false,
      databaseAllowed: false,
    );
  }

  final String policyId;
  final List<String> deniedFieldIds;
  final bool seamProbeAllowed;
  final bool executionAllowed;
  final bool runtimeExecutionApproved;
  final bool analyzerRuntimeInputApproved;
  final bool analyzerRuntimeInputProduced;
  final bool analyzerWiringAllowed;
  final bool engineCallsAllowed;
  final bool schedulerAllowed;
  final bool persistenceAllowed;
  final bool productOutputAllowed;
  final bool productAdapterAllowed;
  final bool savedAnalysisAllowed;
  final bool uiAllowed;
  final bool backendAllowed;
  final bool cacheAllowed;
  final bool databaseAllowed;

  ControlledAnalyzerAdapterRuntimeInputPreflightPolicy copyWith({
    String? policyId,
    List<String>? deniedFieldIds,
    bool? seamProbeAllowed,
    bool? executionAllowed,
    bool? runtimeExecutionApproved,
    bool? analyzerRuntimeInputApproved,
    bool? analyzerRuntimeInputProduced,
    bool? analyzerWiringAllowed,
    bool? engineCallsAllowed,
    bool? schedulerAllowed,
    bool? persistenceAllowed,
    bool? productOutputAllowed,
    bool? productAdapterAllowed,
    bool? savedAnalysisAllowed,
    bool? uiAllowed,
    bool? backendAllowed,
    bool? cacheAllowed,
    bool? databaseAllowed,
  }) {
    return ControlledAnalyzerAdapterRuntimeInputPreflightPolicy(
      policyId: policyId ?? this.policyId,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      seamProbeAllowed: seamProbeAllowed ?? this.seamProbeAllowed,
      executionAllowed: executionAllowed ?? this.executionAllowed,
      runtimeExecutionApproved:
          runtimeExecutionApproved ?? this.runtimeExecutionApproved,
      analyzerRuntimeInputApproved:
          analyzerRuntimeInputApproved ?? this.analyzerRuntimeInputApproved,
      analyzerRuntimeInputProduced:
          analyzerRuntimeInputProduced ?? this.analyzerRuntimeInputProduced,
      analyzerWiringAllowed:
          analyzerWiringAllowed ?? this.analyzerWiringAllowed,
      engineCallsAllowed: engineCallsAllowed ?? this.engineCallsAllowed,
      schedulerAllowed: schedulerAllowed ?? this.schedulerAllowed,
      persistenceAllowed: persistenceAllowed ?? this.persistenceAllowed,
      productOutputAllowed: productOutputAllowed ?? this.productOutputAllowed,
      productAdapterAllowed:
          productAdapterAllowed ?? this.productAdapterAllowed,
      savedAnalysisAllowed: savedAnalysisAllowed ?? this.savedAnalysisAllowed,
      uiAllowed: uiAllowed ?? this.uiAllowed,
      backendAllowed: backendAllowed ?? this.backendAllowed,
      cacheAllowed: cacheAllowed ?? this.cacheAllowed,
      databaseAllowed: databaseAllowed ?? this.databaseAllowed,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'policyId': policyId,
      'deniedFieldIds': deniedFieldIds,
      'seamProbeAllowed': seamProbeAllowed,
      'executionAllowed': executionAllowed,
      'runtimeExecutionApproved': runtimeExecutionApproved,
      'analyzerRuntimeInputApproved': analyzerRuntimeInputApproved,
      'analyzerRuntimeInputProduced': analyzerRuntimeInputProduced,
      'analyzerWiringAllowed': analyzerWiringAllowed,
      'engineCallsAllowed': engineCallsAllowed,
      'schedulerAllowed': schedulerAllowed,
      'persistenceAllowed': persistenceAllowed,
      'productOutputAllowed': productOutputAllowed,
      'productAdapterAllowed': productAdapterAllowed,
      'savedAnalysisAllowed': savedAnalysisAllowed,
      'uiAllowed': uiAllowed,
      'backendAllowed': backendAllowed,
      'cacheAllowed': cacheAllowed,
      'databaseAllowed': databaseAllowed,
    };
  }
}

class ControlledAnalyzerAdapterRuntimeInputPreflightDecision {
  const ControlledAnalyzerAdapterRuntimeInputPreflightDecision({
    required this.decisionId,
    required this.decisionStatus,
    required this.seamProbePerformed,
    required this.executionPerformed,
    required this.executionAllowed,
    required this.runtimeExecutionApproved,
    required this.analyzerRuntimeInputApproved,
    required this.analyzerRuntimeInputProduced,
    required this.analyzerWiringAllowed,
    required this.engineCallsAllowed,
    required this.schedulerAllowed,
    required this.persistenceAllowed,
    required this.productOutputAllowed,
    required this.productAdapterAllowed,
    required this.savedAnalysisAllowed,
    required this.blockedReasonIds,
    required this.warningReasons,
    required this.recommendation,
  });

  final String decisionId;
  final String decisionStatus;
  final bool seamProbePerformed;
  final bool executionPerformed;
  final bool executionAllowed;
  final bool runtimeExecutionApproved;
  final bool analyzerRuntimeInputApproved;
  final bool analyzerRuntimeInputProduced;
  final bool analyzerWiringAllowed;
  final bool engineCallsAllowed;
  final bool schedulerAllowed;
  final bool persistenceAllowed;
  final bool productOutputAllowed;
  final bool productAdapterAllowed;
  final bool savedAnalysisAllowed;
  final List<String> blockedReasonIds;
  final List<String> warningReasons;
  final String recommendation;

  ControlledAnalyzerAdapterRuntimeInputPreflightDecision copyWith({
    String? decisionId,
    String? decisionStatus,
    bool? seamProbePerformed,
    bool? executionPerformed,
    bool? executionAllowed,
    bool? runtimeExecutionApproved,
    bool? analyzerRuntimeInputApproved,
    bool? analyzerRuntimeInputProduced,
    bool? analyzerWiringAllowed,
    bool? engineCallsAllowed,
    bool? schedulerAllowed,
    bool? persistenceAllowed,
    bool? productOutputAllowed,
    bool? productAdapterAllowed,
    bool? savedAnalysisAllowed,
    List<String>? blockedReasonIds,
    List<String>? warningReasons,
    String? recommendation,
  }) {
    return ControlledAnalyzerAdapterRuntimeInputPreflightDecision(
      decisionId: decisionId ?? this.decisionId,
      decisionStatus: decisionStatus ?? this.decisionStatus,
      seamProbePerformed: seamProbePerformed ?? this.seamProbePerformed,
      executionPerformed: executionPerformed ?? this.executionPerformed,
      executionAllowed: executionAllowed ?? this.executionAllowed,
      runtimeExecutionApproved:
          runtimeExecutionApproved ?? this.runtimeExecutionApproved,
      analyzerRuntimeInputApproved:
          analyzerRuntimeInputApproved ?? this.analyzerRuntimeInputApproved,
      analyzerRuntimeInputProduced:
          analyzerRuntimeInputProduced ?? this.analyzerRuntimeInputProduced,
      analyzerWiringAllowed:
          analyzerWiringAllowed ?? this.analyzerWiringAllowed,
      engineCallsAllowed: engineCallsAllowed ?? this.engineCallsAllowed,
      schedulerAllowed: schedulerAllowed ?? this.schedulerAllowed,
      persistenceAllowed: persistenceAllowed ?? this.persistenceAllowed,
      productOutputAllowed: productOutputAllowed ?? this.productOutputAllowed,
      productAdapterAllowed:
          productAdapterAllowed ?? this.productAdapterAllowed,
      savedAnalysisAllowed: savedAnalysisAllowed ?? this.savedAnalysisAllowed,
      blockedReasonIds: blockedReasonIds ?? this.blockedReasonIds,
      warningReasons: warningReasons ?? this.warningReasons,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'decisionId': decisionId,
      'decisionStatus': decisionStatus,
      'seamProbePerformed': seamProbePerformed,
      'executionPerformed': executionPerformed,
      'executionAllowed': executionAllowed,
      'runtimeExecutionApproved': runtimeExecutionApproved,
      'analyzerRuntimeInputApproved': analyzerRuntimeInputApproved,
      'analyzerRuntimeInputProduced': analyzerRuntimeInputProduced,
      'analyzerWiringAllowed': analyzerWiringAllowed,
      'engineCallsAllowed': engineCallsAllowed,
      'schedulerAllowed': schedulerAllowed,
      'persistenceAllowed': persistenceAllowed,
      'productOutputAllowed': productOutputAllowed,
      'productAdapterAllowed': productAdapterAllowed,
      'savedAnalysisAllowed': savedAnalysisAllowed,
      'blockedReasonIds': blockedReasonIds,
      'warningReasons': warningReasons,
      'recommendation': recommendation,
    };
  }
}

class ControlledAnalyzerAdapterRuntimeInputPreflightBlockedReason {
  const ControlledAnalyzerAdapterRuntimeInputPreflightBlockedReason({
    required this.blockedReasonId,
    required this.blockedSurface,
    required this.blocked,
    required this.reason,
    required this.deniedFieldIds,
    required this.recommendation,
  });

  final String blockedReasonId;
  final String blockedSurface;
  final bool blocked;
  final String reason;
  final List<String> deniedFieldIds;
  final String recommendation;

  ControlledAnalyzerAdapterRuntimeInputPreflightBlockedReason copyWith({
    String? blockedReasonId,
    String? blockedSurface,
    bool? blocked,
    String? reason,
    List<String>? deniedFieldIds,
    String? recommendation,
  }) {
    return ControlledAnalyzerAdapterRuntimeInputPreflightBlockedReason(
      blockedReasonId: blockedReasonId ?? this.blockedReasonId,
      blockedSurface: blockedSurface ?? this.blockedSurface,
      blocked: blocked ?? this.blocked,
      reason: reason ?? this.reason,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'blockedReasonId': blockedReasonId,
      'blockedSurface': blockedSurface,
      'blocked': blocked,
      'reason': reason,
      'deniedFieldIds': deniedFieldIds,
      'recommendation': recommendation,
    };
  }
}

class ControlledAnalyzerAdapterRuntimeInputPreflightResult {
  ControlledAnalyzerAdapterRuntimeInputPreflightResult({
    required this.status,
    required this.sourceSeamProbeDiagnosticStatus,
    required this.sourceSeamProbeStatus,
    required this.sourceRuntimeExecutionPreflightDiagnosticStatus,
    required this.sourceRuntimeExecutionPreflightStatus,
    required this.sourceDisabledRuntimeSkeletonDiagnosticStatus,
    required this.input,
    required this.checks,
    required this.policy,
    required this.decision,
    required this.blockedReasons,
    required this.findings,
    required this.safeForPhase34P,
    required this.nextRecommendation,
  }) : totalChecks = checks.length,
       passedCheckCount = checks.where((check) => check.passed).length,
       warningCheckCount = checks
           .where((check) => check.warningReasons.isNotEmpty)
           .length,
       blockedReasonCount = blockedReasons.length,
       deniedFieldCount = _sorted(policy.deniedFieldIds).length,
       ownerProofQueueCount = input.ownerProofRequired ? 1 : 0,
       seamProbePerformedCount =
           (input.seamProbePerformed ? 1 : 0) +
           (decision.seamProbePerformed ? 1 : 0),
       runtimeExecutionCount =
           (input.executionAllowed ? 1 : 0) +
           (input.executionPerformed ? 1 : 0) +
           (policy.executionAllowed ? 1 : 0) +
           (decision.executionAllowed ? 1 : 0) +
           (decision.executionPerformed ? 1 : 0),
       runtimeExecutionApprovedCount =
           (input.runtimeExecutionApproved ? 1 : 0) +
           (policy.runtimeExecutionApproved ? 1 : 0) +
           (decision.runtimeExecutionApproved ? 1 : 0),
       analyzerRuntimeInputProducedCount =
           (input.analyzerRuntimeInputProduced ? 1 : 0) +
           (policy.analyzerRuntimeInputProduced ? 1 : 0) +
           (decision.analyzerRuntimeInputProduced ? 1 : 0),
       analyzerRuntimeInputApprovedCount =
           (input.analyzerRuntimeInputApproved ? 1 : 0) +
           (policy.analyzerRuntimeInputApproved ? 1 : 0) +
           (decision.analyzerRuntimeInputApproved ? 1 : 0),
       analyzerWiringCount =
           (input.analyzerWiringAllowed ? 1 : 0) +
           (policy.analyzerWiringAllowed ? 1 : 0) +
           (decision.analyzerWiringAllowed ? 1 : 0),
       executableRuntimeCount = _activeDeniedFieldIds(
         policy.deniedFieldIds,
       ).where((id) => id == 'runtimeExecutionResult').length,
       engineCallCount =
           (input.engineCallsAllowed ? 1 : 0) +
           (policy.engineCallsAllowed ? 1 : 0) +
           (decision.engineCallsAllowed ? 1 : 0),
       schedulerExecutionCount =
           (input.schedulerAllowed ? 1 : 0) +
           (policy.schedulerAllowed ? 1 : 0) +
           (decision.schedulerAllowed ? 1 : 0),
       persistenceWriteCount =
           (input.persistenceAllowed ? 1 : 0) +
           (policy.persistenceAllowed ? 1 : 0) +
           (decision.persistenceAllowed ? 1 : 0),
       productOutputCount =
           (input.productOutputAllowed ? 1 : 0) +
           (policy.productOutputAllowed ? 1 : 0) +
           (decision.productOutputAllowed ? 1 : 0),
       productAdapterCount =
           (input.productAdapterAllowed ? 1 : 0) +
           (policy.productAdapterAllowed ? 1 : 0) +
           (decision.productAdapterAllowed ? 1 : 0),
       savedAnalysisIntegrationCount =
           (input.savedAnalysisAllowed ? 1 : 0) +
           (policy.savedAnalysisAllowed ? 1 : 0) +
           (decision.savedAnalysisAllowed ? 1 : 0),
       uiBackendCacheDatabaseActivationCount =
           (policy.uiAllowed ? 1 : 0) +
           (policy.backendAllowed ? 1 : 0) +
           (policy.cacheAllowed ? 1 : 0) +
           (policy.databaseAllowed ? 1 : 0),
       activeDeniedFieldCount =
           _activeDeniedFieldIds(input.deniedFieldIds).length +
           _activeDeniedFieldIds(policy.deniedFieldIds).length +
           blockedReasons
               .expand((reason) => _activeDeniedFieldIds(reason.deniedFieldIds))
               .length,
       phase32EProofClaimCount = input.androidProofIds
           .where(_phase32ECaseIds.contains)
           .length,
       unprovenAndroidProofCount = input.androidProofIds
           .where((id) => !_capturedAndroidProofIds.contains(id))
           .length {
    unsafeCount = hasUnsafePolicyViolation ? 1 : 0;
    blockerCount = hasUnsafePolicyViolation ? 1 : 0;
    criticalCount = 0;
  }

  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightStatus
  status;
  final String sourceSeamProbeDiagnosticStatus;
  final String sourceSeamProbeStatus;
  final String sourceRuntimeExecutionPreflightDiagnosticStatus;
  final String sourceRuntimeExecutionPreflightStatus;
  final String sourceDisabledRuntimeSkeletonDiagnosticStatus;
  final ControlledAnalyzerAdapterRuntimeInputPreflightInput input;
  final List<ControlledAnalyzerAdapterRuntimeInputPreflightCheck> checks;
  final ControlledAnalyzerAdapterRuntimeInputPreflightPolicy policy;
  final ControlledAnalyzerAdapterRuntimeInputPreflightDecision decision;
  final List<ControlledAnalyzerAdapterRuntimeInputPreflightBlockedReason>
  blockedReasons;
  final List<String> findings;
  final bool safeForPhase34P;
  final String nextRecommendation;
  final int totalChecks;
  final int passedCheckCount;
  final int warningCheckCount;
  final int blockedReasonCount;
  final int deniedFieldCount;
  final int ownerProofQueueCount;
  final int seamProbePerformedCount;
  final int runtimeExecutionCount;
  final int runtimeExecutionApprovedCount;
  final int analyzerRuntimeInputProducedCount;
  final int analyzerRuntimeInputApprovedCount;
  final int analyzerWiringCount;
  final int executableRuntimeCount;
  final int engineCallCount;
  final int schedulerExecutionCount;
  final int persistenceWriteCount;
  final int productOutputCount;
  final int productAdapterCount;
  final int savedAnalysisIntegrationCount;
  final int uiBackendCacheDatabaseActivationCount;
  final int activeDeniedFieldCount;
  final int phase32EProofClaimCount;
  final int unprovenAndroidProofCount;
  late final int unsafeCount;
  late final int blockerCount;
  late final int criticalCount;

  bool get hasUnsafePolicyViolation =>
      !safeForPhase34P ||
      findings.isNotEmpty ||
      seamProbePerformedCount > 0 ||
      runtimeExecutionCount > 0 ||
      runtimeExecutionApprovedCount > 0 ||
      analyzerRuntimeInputProducedCount > 0 ||
      analyzerRuntimeInputApprovedCount > 0 ||
      analyzerWiringCount > 0 ||
      executableRuntimeCount > 0 ||
      engineCallCount > 0 ||
      schedulerExecutionCount > 0 ||
      persistenceWriteCount > 0 ||
      productOutputCount > 0 ||
      productAdapterCount > 0 ||
      savedAnalysisIntegrationCount > 0 ||
      uiBackendCacheDatabaseActivationCount > 0 ||
      activeDeniedFieldCount > 0 ||
      phase32EProofClaimCount > 0 ||
      unprovenAndroidProofCount > 0 ||
      ownerProofQueueCount > 0 ||
      totalChecks == 0 ||
      passedCheckCount != totalChecks ||
      blockedReasonCount == 0;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Controlled Analyzer Adapter Runtime Input Preflight')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightVersion',
      )
      ..writeln('- preflight status: ${status.wire}')
      ..writeln(
        '- source seam probe diagnostic status: $sourceSeamProbeDiagnosticStatus',
      )
      ..writeln('- source seam probe status: $sourceSeamProbeStatus')
      ..writeln(
        '- source runtime execution preflight diagnostic status: $sourceRuntimeExecutionPreflightDiagnosticStatus',
      )
      ..writeln(
        '- source runtime execution preflight status: $sourceRuntimeExecutionPreflightStatus',
      )
      ..writeln(
        '- source disabled runtime skeleton diagnostic status: $sourceDisabledRuntimeSkeletonDiagnosticStatus',
      )
      ..writeln('- safe for Phase 34P: $safeForPhase34P')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln()
      ..writeln('## Runtime Input Preflight Check Summary')
      ..writeln('| Check | Status | Passed | Blocked reasons |')
      ..writeln('| --- | --- | --- | --- |');
    for (final check in checks) {
      buffer.writeln(
        '| ${check.checkId} | ${check.checkStatus} | ${check.passed} | ${_ids(check.blockedReasonIds)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Runtime Input Preflight Decision Summary')
      ..writeln('- decision ID: ${decision.decisionId}')
      ..writeln('- decision status: ${decision.decisionStatus}')
      ..writeln('- seamProbePerformed: ${decision.seamProbePerformed}')
      ..writeln('- executionPerformed: ${decision.executionPerformed}')
      ..writeln('- executionAllowed: ${decision.executionAllowed}')
      ..writeln(
        '- runtimeExecutionApproved: ${decision.runtimeExecutionApproved}',
      )
      ..writeln(
        '- analyzerRuntimeInputApproved: ${decision.analyzerRuntimeInputApproved}',
      )
      ..writeln(
        '- analyzerRuntimeInputProduced: ${decision.analyzerRuntimeInputProduced}',
      )
      ..writeln('- analyzerWiringAllowed: ${decision.analyzerWiringAllowed}')
      ..writeln('- engineCallsAllowed: ${decision.engineCallsAllowed}')
      ..writeln('- schedulerAllowed: ${decision.schedulerAllowed}')
      ..writeln('- persistenceAllowed: ${decision.persistenceAllowed}')
      ..writeln('- productOutputAllowed: ${decision.productOutputAllowed}')
      ..writeln('- productAdapterAllowed: ${decision.productAdapterAllowed}')
      ..writeln('- savedAnalysisAllowed: ${decision.savedAnalysisAllowed}')
      ..writeln()
      ..writeln('## Blocked Reason Summary')
      ..writeln('| Reason | Surface | Blocked |')
      ..writeln('| --- | --- | --- |');
    for (final reason in blockedReasons) {
      buffer.writeln(
        '| ${reason.blockedReasonId} | ${reason.blockedSurface} | ${reason.blocked} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Denied Field Summary')
      ..writeln('- denied field count: $deniedFieldCount')
      ..writeln('- denied field IDs: ${_ids(policy.deniedFieldIds)}')
      ..writeln()
      ..writeln('## Proof Boundary Summary')
      ..writeln('- android proof IDs: ${_ids(input.androidProofIds)}')
      ..writeln('- owner proof required: ${input.ownerProofRequired}')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Safety Summary')
      ..writeln('- seam probe performed count: $seamProbePerformedCount')
      ..writeln('- runtime execution count: $runtimeExecutionCount')
      ..writeln(
        '- runtime execution approved count: $runtimeExecutionApprovedCount',
      )
      ..writeln(
        '- analyzer runtime input produced count: $analyzerRuntimeInputProducedCount',
      )
      ..writeln(
        '- analyzer runtime input approved count: $analyzerRuntimeInputApprovedCount',
      )
      ..writeln('- executable runtime count: $executableRuntimeCount')
      ..writeln('- analyzer wiring count: $analyzerWiringCount')
      ..writeln('- engine call count: $engineCallCount')
      ..writeln('- scheduler execution count: $schedulerExecutionCount')
      ..writeln('- persistence write count: $persistenceWriteCount')
      ..writeln('- product output count: $productOutputCount')
      ..writeln('- product adapter count: $productAdapterCount')
      ..writeln(
        '- saved analysis integration count: $savedAnalysisIntegrationCount',
      )
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln()
      ..writeln('## Recommendation')
      ..writeln('- safe for Phase 34P: $safeForPhase34P')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- findings: ${_ids(findings)}')
      ..writeln();
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent(' ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightVersion,
      'status': status.wire,
      'sourceSeamProbeDiagnosticStatus': sourceSeamProbeDiagnosticStatus,
      'sourceSeamProbeStatus': sourceSeamProbeStatus,
      'sourceRuntimeExecutionPreflightDiagnosticStatus':
          sourceRuntimeExecutionPreflightDiagnosticStatus,
      'sourceRuntimeExecutionPreflightStatus':
          sourceRuntimeExecutionPreflightStatus,
      'sourceDisabledRuntimeSkeletonDiagnosticStatus':
          sourceDisabledRuntimeSkeletonDiagnosticStatus,
      'safeForPhase34P': safeForPhase34P,
      'nextRecommendation': nextRecommendation,
      'counts': <String, Object?>{
        'totalChecks': totalChecks,
        'passedCheckCount': passedCheckCount,
        'warningCheckCount': warningCheckCount,
        'blockedReasonCount': blockedReasonCount,
        'deniedFieldCount': deniedFieldCount,
        'unsafeCount': unsafeCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'seamProbePerformedCount': seamProbePerformedCount,
        'runtimeExecutionCount': runtimeExecutionCount,
        'runtimeExecutionApprovedCount': runtimeExecutionApprovedCount,
        'analyzerRuntimeInputProducedCount': analyzerRuntimeInputProducedCount,
        'analyzerRuntimeInputApprovedCount': analyzerRuntimeInputApprovedCount,
        'executableRuntimeCount': executableRuntimeCount,
        'analyzerWiringCount': analyzerWiringCount,
        'engineCallCount': engineCallCount,
        'schedulerExecutionCount': schedulerExecutionCount,
        'persistenceWriteCount': persistenceWriteCount,
        'productOutputCount': productOutputCount,
        'productAdapterCount': productAdapterCount,
        'savedAnalysisIntegrationCount': savedAnalysisIntegrationCount,
        'activeDeniedFieldCount': activeDeniedFieldCount,
        'phase32EProofClaimCount': phase32EProofClaimCount,
        'unprovenAndroidProofCount': unprovenAndroidProofCount,
        'ownerProofQueueCount': ownerProofQueueCount,
      },
      'input': input.toJson(),
      'checks': checks.map((check) => check.toJson()).toList(),
      'policy': policy.toJson(),
      'decision': decision.toJson(),
      'blockedReasons': blockedReasons
          .map((reason) => reason.toJson())
          .toList(),
      'findings': findings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflight {
  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflight();

  ControlledAnalyzerAdapterRuntimeInputPreflightResult evaluate({
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticResult?
    disabledSeamProbeDiagnosticResult,
    DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult?
    disabledSeamProbeResult,
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticResult?
    runtimeExecutionPreflightDiagnosticResult,
    ControlledAnalyzerAdapterRuntimeExecutionPreflightResult?
    runtimeExecutionPreflightResult,
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticResult?
    disabledRuntimeSkeletonDiagnosticResult,
    DisabledAnalyzerAdapterRuntimeSkeletonResult? disabledRuntimeSkeletonResult,
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticResult?
    runtimePreparationDiagnosticResult,
    ControlledAnalyzerAdapterRuntimePreparationResult? runtimePreparationResult,
  }) {
    final preparation =
        runtimePreparationResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation()
            .evaluate();
    final preparationDiagnostic =
        runtimePreparationDiagnosticResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic()
            .evaluate(runtimePreparationResult: preparation);
    final skeleton =
        disabledRuntimeSkeletonResult ??
        const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeleton().evaluate(
          runtimePreparationDiagnosticResult: preparationDiagnostic,
          runtimePreparationResult: preparation,
        );
    final skeletonDiagnostic =
        disabledRuntimeSkeletonDiagnosticResult ??
        const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnostic()
            .evaluate(
              skeletonResult: skeleton,
              runtimePreparationDiagnosticResult: preparationDiagnostic,
              runtimePreparationResult: preparation,
            );
    final executionPreflight =
        runtimeExecutionPreflightResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflight()
            .evaluate(
              disabledRuntimeSkeletonDiagnosticResult: skeletonDiagnostic,
              disabledRuntimeSkeletonResult: skeleton,
              runtimePreparationDiagnosticResult: preparationDiagnostic,
              runtimePreparationResult: preparation,
            );
    final executionPreflightDiagnostic =
        runtimeExecutionPreflightDiagnosticResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnostic()
            .evaluate(
              runtimeExecutionPreflightResult: executionPreflight,
              disabledRuntimeSkeletonDiagnosticResult: skeletonDiagnostic,
              disabledRuntimeSkeletonResult: skeleton,
              runtimePreparationDiagnosticResult: preparationDiagnostic,
              runtimePreparationResult: preparation,
            );
    final seamProbe =
        disabledSeamProbeResult ??
        const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbe()
            .evaluate(
              runtimeExecutionPreflightDiagnosticResult:
                  executionPreflightDiagnostic,
              runtimeExecutionPreflightResult: executionPreflight,
              disabledRuntimeSkeletonDiagnosticResult: skeletonDiagnostic,
              disabledRuntimeSkeletonResult: skeleton,
              runtimePreparationDiagnosticResult: preparationDiagnostic,
              runtimePreparationResult: preparation,
            );
    final seamProbeDiagnostic =
        disabledSeamProbeDiagnosticResult ??
        const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnostic()
            .evaluate(
              seamProbeResult: seamProbe,
              runtimeExecutionPreflightDiagnosticResult:
                  executionPreflightDiagnostic,
              runtimeExecutionPreflightResult: executionPreflight,
              disabledRuntimeSkeletonDiagnosticResult: skeletonDiagnostic,
              disabledRuntimeSkeletonResult: skeleton,
              runtimePreparationDiagnosticResult: preparationDiagnostic,
              runtimePreparationResult: preparation,
            );
    final blockedReasons = _blockedReasonsFor(seamProbe);
    final checks = _checksFor(
      seamProbe: seamProbe,
      seamProbeDiagnostic: seamProbeDiagnostic,
      blockedReasons: blockedReasons,
    );
    final policy =
        ControlledAnalyzerAdapterRuntimeInputPreflightPolicy.disabled(
          deniedFieldIds: seamProbe.policy.deniedFieldIds,
        );
    final decision = ControlledAnalyzerAdapterRuntimeInputPreflightDecision(
      decisionId: _decisionId,
      decisionStatus: 'runtimeInputPreflightInspectedInputStillDisabled',
      seamProbePerformed: false,
      executionPerformed: false,
      executionAllowed: false,
      runtimeExecutionApproved: false,
      analyzerRuntimeInputApproved: false,
      analyzerRuntimeInputProduced: false,
      analyzerWiringAllowed: false,
      engineCallsAllowed: false,
      schedulerAllowed: false,
      persistenceAllowed: false,
      productOutputAllowed: false,
      productAdapterAllowed: false,
      savedAnalysisAllowed: false,
      blockedReasonIds: blockedReasons
          .map((reason) => reason.blockedReasonId)
          .toList(),
      warningReasons: const <String>[
        'runtimeInputPreflightExistsButAnalyzerRuntimeInputStillDisabled',
      ],
      recommendation: _phase34PRecommendation,
    );
    final input = ControlledAnalyzerAdapterRuntimeInputPreflightInput(
      preflightId: _preflightId,
      sourcePhase: 'Phase34N',
      sourceDiagnosticIds: <String>[
        debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticVersion,
      ],
      sourceSeamProbeIds: <String>[seamProbe.input.seamProbeId],
      sourcePreflightIds: _sorted(<String>[
        ...seamProbe.input.sourcePreflightIds,
        executionPreflight.input.preflightId,
      ]),
      sourceSkeletonIds: seamProbe.input.sourceSkeletonIds,
      sourcePreparationIds: seamProbe.input.sourcePreparationIds,
      sourceCaseIds: seamProbe.input.sourceCaseIds,
      sourceActionIds: seamProbe.input.sourceActionIds,
      sourcePatchIds: seamProbe.input.sourcePatchIds,
      sourceRefinementIds: seamProbe.input.sourceRefinementIds,
      checkIds: checks.map((check) => check.checkId).toList(),
      decisionId: decision.decisionId,
      blockedReasonIds: decision.blockedReasonIds,
      deniedFieldIds: policy.deniedFieldIds,
      supportAreaIds: seamProbe.input.supportAreaIds,
      warningReasons: _sorted(<String>[
        ...seamProbe.input.warningReasons,
        'controlledRuntimeInputPreflightNoAnalyzerRuntimeInput',
      ]),
      proofLimitReasons: seamProbe.input.proofLimitReasons,
      androidProofIds: seamProbe.input.androidProofIds,
      ownerProofRequired: seamProbe.input.ownerProofRequired,
      seamProbeRequested: seamProbe.input.seamProbeRequested,
      seamProbePerformed: false,
      executionPerformed: false,
      executionAllowed: false,
      runtimeExecutionApproved: false,
      analyzerRuntimeInputApproved: false,
      analyzerRuntimeInputProduced: false,
      analyzerWiringAllowed: false,
      engineCallsAllowed: false,
      schedulerAllowed: false,
      persistenceAllowed: false,
      productOutputAllowed: false,
      productAdapterAllowed: false,
      savedAnalysisAllowed: false,
      recommendation: _phase34PRecommendation,
    );
    final findings = _sorted(<String>[
      if (seamProbeDiagnostic.hasUnsafePolicyViolation ||
          !seamProbeDiagnostic.safeForPhase34O)
        'unsafePhase34NDisabledRuntimeExecutionSeamProbeDiagnostic',
      if (seamProbe.hasUnsafePolicyViolation || !seamProbe.safeForPhase34N)
        'unsafePhase34MDisabledRuntimeExecutionSeamProbe',
      if (executionPreflightDiagnostic.hasUnsafePolicyViolation ||
          !executionPreflightDiagnostic.safeForPhase34M)
        'unsafePhase34LRuntimeExecutionPreflightDiagnostic',
      if (executionPreflight.hasUnsafePolicyViolation ||
          !executionPreflight.safeForPhase34L)
        'unsafePhase34KRuntimeExecutionPreflight',
      if (skeletonDiagnostic.hasUnsafePolicyViolation ||
          !skeletonDiagnostic.safeForPhase34K)
        'unsafePhase34JDisabledRuntimeSkeletonDiagnostic',
      ...const ControlledAnalyzerAdapterRuntimeInputPreflightValidator()
          .validatePreflight(
            input: input,
            checks: checks,
            policy: policy,
            decision: decision,
            blockedReasons: blockedReasons,
          ),
    ]);
    final safeForPhase34P = findings.isEmpty;
    return ControlledAnalyzerAdapterRuntimeInputPreflightResult(
      status: !safeForPhase34P
          ? DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightStatus
                .blockedByPolicyBoundary
          : checks.any((check) => check.warningReasons.isNotEmpty)
          ? DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightStatus
                .controlledAnalyzerAdapterRuntimeInputPreflightReadyWithWarnings
          : DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightStatus
                .controlledAnalyzerAdapterRuntimeInputPreflightReadyClean,
      sourceSeamProbeDiagnosticStatus: seamProbeDiagnostic.status.wire,
      sourceSeamProbeStatus: seamProbe.status.wire,
      sourceRuntimeExecutionPreflightDiagnosticStatus:
          executionPreflightDiagnostic.status.wire,
      sourceRuntimeExecutionPreflightStatus: executionPreflight.status.wire,
      sourceDisabledRuntimeSkeletonDiagnosticStatus:
          skeletonDiagnostic.status.wire,
      input: input,
      checks: checks,
      policy: policy,
      decision: decision,
      blockedReasons: blockedReasons,
      findings: findings,
      safeForPhase34P: safeForPhase34P,
      nextRecommendation: safeForPhase34P
          ? _phase34PRecommendation
          : 'blockedByUnsafeControlledRuntimeInputPreflight',
    );
  }
}

class ControlledAnalyzerAdapterRuntimeInputPreflightValidator {
  const ControlledAnalyzerAdapterRuntimeInputPreflightValidator();

  List<String> validateResult(
    ControlledAnalyzerAdapterRuntimeInputPreflightResult result,
  ) {
    return validatePreflight(
      input: result.input,
      checks: result.checks,
      policy: result.policy,
      decision: result.decision,
      blockedReasons: result.blockedReasons,
    );
  }

  List<String> validatePreflight({
    required ControlledAnalyzerAdapterRuntimeInputPreflightInput input,
    required Iterable<ControlledAnalyzerAdapterRuntimeInputPreflightCheck>
    checks,
    required ControlledAnalyzerAdapterRuntimeInputPreflightPolicy policy,
    required ControlledAnalyzerAdapterRuntimeInputPreflightDecision decision,
    required Iterable<
      ControlledAnalyzerAdapterRuntimeInputPreflightBlockedReason
    >
    blockedReasons,
  }) {
    return _sorted(<String>[
      ...validateInput(input),
      ...checks.expand(validateCheck),
      ...validatePolicy(policy),
      ...validateDecision(decision),
      ...blockedReasons.expand(validateBlockedReason),
      if (!checks.any((check) => check.checkId == 'seamProbeDiagnosticPresent'))
        'seamProbeDiagnosticMissing',
      if (!checks.any((check) => check.checkId == 'seamProbeResultPresent'))
        'seamProbeResultMissing',
      if (!checks.any(
        (check) => check.checkId == 'seamProbeRequestedAsRefusedRecord',
      ))
        'refusedSeamProbeRecordMissing',
      if (!checks.any(
        (check) => check.checkId == 'analyzerRuntimeInputBoundaryPresent',
      ))
        'analyzerRuntimeInputBoundaryMissing',
      if (input.recommendation != _phase34PRecommendation ||
          decision.recommendation != _phase34PRecommendation)
        'missingPhase34PRuntimeInputPreflightDiagnosticRecommendation',
    ]);
  }

  List<String> validateInput(
    ControlledAnalyzerAdapterRuntimeInputPreflightInput input,
  ) {
    return _validateBoundary(
      sourceCaseIds: input.sourceCaseIds,
      supportAreaIds: input.supportAreaIds,
      proofLimitReasons: input.proofLimitReasons,
      androidProofIds: input.androidProofIds,
      ownerProofRequired: input.ownerProofRequired,
      deniedFieldIds: input.deniedFieldIds,
      blockedReasonIds: input.blockedReasonIds,
      seamProbePerformed: input.seamProbePerformed,
      executionPerformed: input.executionPerformed,
      executionAllowed: input.executionAllowed,
      runtimeExecutionApproved: input.runtimeExecutionApproved,
      analyzerRuntimeInputApproved: input.analyzerRuntimeInputApproved,
      analyzerRuntimeInputProduced: input.analyzerRuntimeInputProduced,
      analyzerWiringAllowed: input.analyzerWiringAllowed,
      engineCallsAllowed: input.engineCallsAllowed,
      schedulerAllowed: input.schedulerAllowed,
      persistenceAllowed: input.persistenceAllowed,
      productOutputAllowed: input.productOutputAllowed,
      productAdapterAllowed: input.productAdapterAllowed,
      savedAnalysisAllowed: input.savedAnalysisAllowed,
      recommendation: input.recommendation,
    );
  }

  List<String> validateCheck(
    ControlledAnalyzerAdapterRuntimeInputPreflightCheck check,
  ) {
    return _sorted(<String>[
      if (!_requiredCheckIds.contains(check.checkId))
        'unknownRuntimeInputPreflightCheck',
      if (!check.passed) 'runtimeInputPreflightCheckFailed',
      if (check.recommendation != _phase34PRecommendation)
        'missingPhase34PRuntimeInputPreflightDiagnosticRecommendation',
      if (_activeDeniedFieldIds(check.deniedFieldIds).isNotEmpty)
        'activeDeniedFields',
      if (check.blockedReasonIds.any((id) => id.startsWith('active:')))
        'blockedReasonActivated',
    ]);
  }

  List<String> validatePolicy(
    ControlledAnalyzerAdapterRuntimeInputPreflightPolicy policy,
  ) {
    return _sorted(<String>[
      ..._validateBoundary(
        sourceCaseIds: const <String>[],
        supportAreaIds: const <String>[],
        proofLimitReasons: const <String>[],
        androidProofIds: const <String>[],
        ownerProofRequired: false,
        deniedFieldIds: policy.deniedFieldIds,
        blockedReasonIds: const <String>[],
        seamProbePerformed: policy.seamProbeAllowed,
        executionPerformed: false,
        executionAllowed: policy.executionAllowed,
        runtimeExecutionApproved: policy.runtimeExecutionApproved,
        analyzerRuntimeInputApproved: policy.analyzerRuntimeInputApproved,
        analyzerRuntimeInputProduced: policy.analyzerRuntimeInputProduced,
        analyzerWiringAllowed: policy.analyzerWiringAllowed,
        engineCallsAllowed: policy.engineCallsAllowed,
        schedulerAllowed: policy.schedulerAllowed,
        persistenceAllowed: policy.persistenceAllowed,
        productOutputAllowed: policy.productOutputAllowed,
        productAdapterAllowed: policy.productAdapterAllowed,
        savedAnalysisAllowed: policy.savedAnalysisAllowed,
        recommendation: _phase34PRecommendation,
      ),
      if (policy.uiAllowed || policy.backendAllowed)
        'uiBackendActivationEnabled',
      if (policy.cacheAllowed || policy.databaseAllowed)
        'cacheDatabaseWriteEnabled',
    ]);
  }

  List<String> validateDecision(
    ControlledAnalyzerAdapterRuntimeInputPreflightDecision decision,
  ) {
    return _validateBoundary(
      sourceCaseIds: const <String>[],
      supportAreaIds: const <String>[],
      proofLimitReasons: const <String>[],
      androidProofIds: const <String>[],
      ownerProofRequired: false,
      deniedFieldIds: const <String>[],
      blockedReasonIds: decision.blockedReasonIds,
      seamProbePerformed: decision.seamProbePerformed,
      executionPerformed: decision.executionPerformed,
      executionAllowed: decision.executionAllowed,
      runtimeExecutionApproved: decision.runtimeExecutionApproved,
      analyzerRuntimeInputApproved: decision.analyzerRuntimeInputApproved,
      analyzerRuntimeInputProduced: decision.analyzerRuntimeInputProduced,
      analyzerWiringAllowed: decision.analyzerWiringAllowed,
      engineCallsAllowed: decision.engineCallsAllowed,
      schedulerAllowed: decision.schedulerAllowed,
      persistenceAllowed: decision.persistenceAllowed,
      productOutputAllowed: decision.productOutputAllowed,
      productAdapterAllowed: decision.productAdapterAllowed,
      savedAnalysisAllowed: decision.savedAnalysisAllowed,
      recommendation: decision.recommendation,
    );
  }

  List<String> validateBlockedReason(
    ControlledAnalyzerAdapterRuntimeInputPreflightBlockedReason reason,
  ) {
    return _sorted(<String>[
      if (!reason.blocked) 'blockedReasonActivated',
      if (reason.recommendation != _phase34PRecommendation)
        'missingPhase34PRuntimeInputPreflightDiagnosticRecommendation',
      if (_activeDeniedFieldIds(reason.deniedFieldIds).isNotEmpty)
        'activeDeniedFields',
      if (reason.blockedReasonId.startsWith('active:'))
        'blockedReasonActivated',
    ]);
  }

  List<String> validateReportText(String text) {
    final lower = text.toLowerCase();
    return _sorted(<String>[
      if (lower.contains('bestmove ')) 'reportTextLeak:stockfishBestMove',
      if (lower.contains('position fen ')) 'reportTextLeak:stockfishPosition',
      if (lower.contains('go movetime ')) 'reportTextLeak:stockfishCommand',
      if (lower.contains('info depth') && lower.contains(' pv '))
        'reportTextLeak:pvDump',
      if (lower.contains('backend://') ||
          lower.contains('http://secret') ||
          lower.contains('https://secret'))
        'reportTextLeak:backendSecret',
    ]);
  }

  List<String> _validateBoundary({
    required Iterable<String> sourceCaseIds,
    required Iterable<String> supportAreaIds,
    required Iterable<String> proofLimitReasons,
    required Iterable<String> androidProofIds,
    required bool ownerProofRequired,
    required Iterable<String> deniedFieldIds,
    required Iterable<String> blockedReasonIds,
    required bool seamProbePerformed,
    required bool executionPerformed,
    required bool executionAllowed,
    required bool runtimeExecutionApproved,
    required bool analyzerRuntimeInputApproved,
    required bool analyzerRuntimeInputProduced,
    required bool analyzerWiringAllowed,
    required bool engineCallsAllowed,
    required bool schedulerAllowed,
    required bool persistenceAllowed,
    required bool productOutputAllowed,
    required bool productAdapterAllowed,
    required bool savedAnalysisAllowed,
    required String recommendation,
  }) {
    final activeDenied = _activeDeniedFieldIds(deniedFieldIds);
    return _sorted(<String>[
      if (recommendation != _phase34PRecommendation)
        'missingPhase34PRuntimeInputPreflightDiagnosticRecommendation',
      if (seamProbePerformed) 'seamProbePerformedEnabled',
      if (executionPerformed) 'executionPerformedEnabled',
      if (executionAllowed) 'executionAllowedEnabled',
      if (runtimeExecutionApproved) 'runtimeExecutionApprovedEnabled',
      if (analyzerRuntimeInputApproved) 'analyzerRuntimeInputApproved',
      if (analyzerRuntimeInputProduced) 'analyzerRuntimeInputProduced',
      if (analyzerWiringAllowed) 'analyzerWiringEnabled',
      if (engineCallsAllowed) 'engineCallsEnabled',
      if (schedulerAllowed) 'schedulerExecutionEnabled',
      if (persistenceAllowed) 'persistenceWriteEnabled',
      if (productOutputAllowed) 'productOutputEnabled',
      if (productAdapterAllowed) 'productAdapterEnabled',
      if (savedAnalysisAllowed) 'savedAnalysisIntegrationEnabled',
      if (blockedReasonIds.any((id) => id.startsWith('active:')))
        'blockedReasonActivated',
      if (activeDenied.isNotEmpty) 'activeDeniedFields',
      if (activeDenied.any(_productFields.contains)) 'productLabelsEnabled',
      if (activeDenied.any(_finalLabelFields.contains)) 'finalLabelsEnabled',
      if (activeDenied.any(_classifierFields.contains))
        'classifierLabelsEnabled',
      if (activeDenied.any(_scoreFields.contains)) 'scoresEnabled',
      if (activeDenied.any(_rankingMetricFields.contains))
        'rankingsMetricsAccuracyAcplEnabled',
      if (activeDenied.contains('cpLoss')) 'cpLossEnabled',
      if (activeDenied.contains('winProbability')) 'winProbabilityEnabled',
      if (activeDenied.contains('thresholds')) 'thresholdsEnabled',
      if (activeDenied.contains('stockfishCommand')) 'stockfishCommandEnabled',
      if (activeDenied.contains('rawUci')) 'rawUciEnabled',
      if (activeDenied.contains('pvDump')) 'pvDumpEnabled',
      if (activeDenied.contains('androidCollectorRequirement'))
        'androidCollectorRequirementEnabled',
      if (activeDenied.contains('runtimeExecutionResult'))
        'runtimeExecutionResultEnabled',
      if (activeDenied.contains('analyzerRuntimeInput'))
        'analyzerRuntimeInputEnabled',
      if (activeDenied.contains('analyzerResult')) 'analyzerResultEnabled',
      if (activeDenied.contains('engineResult')) 'engineResultEnabled',
      if (activeDenied.contains('schedulerExecutionResult'))
        'schedulerExecutionResultEnabled',
      if (activeDenied.contains('cacheDatabaseWrite'))
        'cacheDatabaseWriteEnabled',
      if (activeDenied.contains('productAdapterBehavior'))
        'productAdapterBehaviorEnabled',
      if (activeDenied.contains('savedAnalysisIntegration'))
        'savedAnalysisIntegrationEnabled',
      if (activeDenied.contains('readinessSummaryChain'))
        'readinessSummaryChainEnabled',
      if (activeDenied.contains('readinessGate')) 'readinessGateEnabled',
      if (_isQuietSupport(supportAreaIds)) 'quietPreparatoryPromotion',
      if (sourceCaseIds.contains(_pvMultiPvBoundaryCaseId) &&
          !proofLimitReasons.any(_mentionsPvMultiPv))
        'pvMultiPvPromotion',
      if (androidProofIds.any(_phase32ECaseIds.contains))
        'phase32ECapturedProofClaim',
      if (androidProofIds.any((id) => !_capturedAndroidProofIds.contains(id)))
        'unprovenAndroidProofClaim',
      if (ownerProofRequired && !proofLimitReasons.any(_mentionsPvMultiPv))
        'ownerProofWithoutPvMultiPvReason',
    ]);
  }
}

List<ControlledAnalyzerAdapterRuntimeInputPreflightCheck> _checksFor({
  required DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult seamProbe,
  required DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticResult
  seamProbeDiagnostic,
  required List<ControlledAnalyzerAdapterRuntimeInputPreflightBlockedReason>
  blockedReasons,
}) {
  final blockedReasonIds = blockedReasons
      .map((reason) => reason.blockedReasonId)
      .toList();
  return _requiredCheckIds
      .map(
        (id) => ControlledAnalyzerAdapterRuntimeInputPreflightCheck(
          checkId: id,
          checkStatus: 'passedControlledRuntimeInputPreflightCheck',
          passed: _checkPassed(id, seamProbe, seamProbeDiagnostic),
          inspectedFieldIds: _inspectedFieldsForCheck(id),
          blockedReasonIds: blockedReasonIds,
          deniedFieldIds: _deniedFieldsForCheck(
            id,
            seamProbe.policy.deniedFieldIds,
          ),
          warningReasons: const <String>[
            'runtimeInputPreflightIsDeveloperOnlyNoAnalyzerRuntimeInput',
          ],
          recommendation: _phase34PRecommendation,
        ),
      )
      .toList(growable: false);
}

bool _checkPassed(
  String id,
  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult seamProbe,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticResult
  seamProbeDiagnostic,
) {
  return switch (id) {
    'seamProbeDiagnosticPresent' => seamProbeDiagnostic.totalDiagnosticRows > 0,
    'seamProbeResultPresent' => seamProbe.input.seamProbeId.isNotEmpty,
    'seamProbeRequestedAsRefusedRecord' =>
      seamProbe.attempt.seamProbeRequested && seamProbe.attempt.refused,
    'seamProbePerformedFalse' => seamProbe.seamProbePerformedCount == 0,
    'executionPerformedFalse' =>
      !seamProbe.input.executionPerformed &&
          !seamProbe.request.executionPerformed &&
          !seamProbe.response.executionPerformed &&
          !seamProbe.attempt.executionPerformed,
    'executionAllowedFalse' =>
      !seamProbe.input.executionAllowed &&
          !seamProbe.request.executionAllowed &&
          !seamProbe.response.executionAllowed &&
          !seamProbe.policy.executionAllowed &&
          !seamProbe.attempt.executionAllowed,
    'runtimeExecutionApprovedFalse' =>
      seamProbe.runtimeExecutionApprovedCount == 0,
    'analyzerRuntimeInputProducedFalse' =>
      seamProbe.analyzerRuntimeInputCount == 0,
    'analyzerRuntimeInputApprovedFalse' =>
      !seamProbe.policy.analyzerRuntimeInputAllowed,
    'analyzerWiringAllowedFalse' => seamProbe.analyzerWiringCount == 0,
    'engineCallsAllowedFalse' => seamProbe.engineCallCount == 0,
    'schedulerAllowedFalse' => seamProbe.schedulerExecutionCount == 0,
    'persistenceAllowedFalse' => seamProbe.persistenceWriteCount == 0,
    'productOutputAllowedFalse' => seamProbe.productOutputCount == 0,
    'productAdapterAllowedFalse' => seamProbe.productAdapterCount == 0,
    'savedAnalysisAllowedFalse' => seamProbe.savedAnalysisIntegrationCount == 0,
    'requestMetadataOnly' =>
      seamProbe.request.seamProbeRequested &&
          !seamProbe.request.seamProbePerformed,
    'responseRefusedMetadataOnly' =>
      seamProbe.response.responseStatus.contains('Refused') ||
          seamProbe.response.refusedReason.isNotEmpty,
    'refusedAttemptPresent' =>
      seamProbe.attempt.seamProbeRequested && seamProbe.attempt.refused,
    'disabledRuntimeSkeletonBoundaryPresent' => seamProbe.boundaries.any(
      (boundary) => boundary.boundaryId == 'disabledRuntimeSkeletonBoundary',
    ),
    'runtimeExecutionPreflightBoundaryPresent' => seamProbe.boundaries.any(
      (boundary) => boundary.boundaryId == 'runtimeExecutionPreflightBoundary',
    ),
    'analyzerRuntimeInputBoundaryPresent' => seamProbe.boundaries.any(
      (boundary) => boundary.boundaryId == 'analyzerRuntimeInputBoundary',
    ),
    'analyzerRuntimeInputBlocked' =>
      seamProbe.blockedReasons.any(
            (reason) => reason.blockedReasonId == 'analyzerRuntimeInputBlocked',
          ) ||
          seamProbe.boundaries.any(
            (boundary) =>
                boundary.boundaryId == 'analyzerRuntimeInputBoundary' &&
                boundary.blocked,
          ),
    'stockfishCommandBlocked' => seamProbe.policy.deniedFieldIds.contains(
      'stockfishCommand',
    ),
    'rawUciBlocked' => seamProbe.policy.deniedFieldIds.contains('rawUci'),
    'pvDumpBlocked' => seamProbe.policy.deniedFieldIds.contains('pvDump'),
    'androidCollectorBlocked' => seamProbe.blockedReasons.any(
      (reason) => reason.blockedReasonId == 'androidCollectorBlocked',
    ),
    'productLabelsBlocked' => seamProbe.policy.deniedFieldIds.contains(
      'productLabel',
    ),
    'numericScoresBlocked' => seamProbe.policy.deniedFieldIds.contains(
      'numericMoveScore',
    ),
    'officialMetricsBlocked' =>
      seamProbe.policy.deniedFieldIds.contains('officialMetric') ||
          seamProbe.policy.deniedFieldIds.contains('officialAccuracy'),
    'cpLossBlocked' => seamProbe.policy.deniedFieldIds.contains('cpLoss'),
    'winProbabilityBlocked' => seamProbe.policy.deniedFieldIds.contains(
      'winProbability',
    ),
    'phase32EProofHonestyPreserved' => seamProbe.phase32EProofClaimCount == 0,
    'quietPreparatoryExclusionPreserved' => !_isQuietSupport(
      seamProbe.input.supportAreaIds,
    ),
    _ => false,
  };
}

List<String> _inspectedFieldsForCheck(String id) {
  return switch (id) {
    'seamProbeDiagnosticPresent' => const <String>['sourceDiagnosticIds'],
    'seamProbeResultPresent' => const <String>['sourceSeamProbeIds'],
    'seamProbeRequestedAsRefusedRecord' => const <String>[
      'seamProbeRequested',
      'refused',
    ],
    'seamProbePerformedFalse' => const <String>['seamProbePerformed'],
    'executionPerformedFalse' => const <String>['executionPerformed'],
    'executionAllowedFalse' => const <String>['executionAllowed'],
    'runtimeExecutionApprovedFalse' => const <String>[
      'runtimeExecutionApproved',
    ],
    'analyzerRuntimeInputProducedFalse' => const <String>[
      'analyzerRuntimeInputProduced',
    ],
    'analyzerRuntimeInputApprovedFalse' => const <String>[
      'analyzerRuntimeInputApproved',
    ],
    'analyzerWiringAllowedFalse' => const <String>['analyzerWiringAllowed'],
    'engineCallsAllowedFalse' => const <String>['engineCallsAllowed'],
    'schedulerAllowedFalse' => const <String>['schedulerAllowed'],
    'persistenceAllowedFalse' => const <String>['persistenceAllowed'],
    'productOutputAllowedFalse' => const <String>['productOutputAllowed'],
    'productAdapterAllowedFalse' => const <String>['productAdapterAllowed'],
    'savedAnalysisAllowedFalse' => const <String>['savedAnalysisAllowed'],
    _ => const <String>['deniedFieldIds', 'blockedReasonIds'],
  };
}

List<String> _deniedFieldsForCheck(
  String id,
  Iterable<String> sourceDeniedFields,
) {
  final byCheck = <String, List<String>>{
    'stockfishCommandBlocked': <String>['stockfishCommand'],
    'rawUciBlocked': <String>['rawUci'],
    'pvDumpBlocked': <String>['pvDump'],
    'productLabelsBlocked': <String>['productLabel', 'finalMoveLabel'],
    'numericScoresBlocked': <String>['numericMoveScore', 'aggregateScore'],
    'officialMetricsBlocked': <String>['officialMetric', 'officialAccuracy'],
    'cpLossBlocked': <String>['cpLoss'],
    'winProbabilityBlocked': <String>['winProbability'],
    'analyzerRuntimeInputBlocked': <String>['analyzerRuntimeInput'],
  };
  return _sorted(byCheck[id] ?? sourceDeniedFields);
}

List<ControlledAnalyzerAdapterRuntimeInputPreflightBlockedReason>
_blockedReasonsFor(
  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult seamProbe,
) {
  final surfaces = <String>[
    'runtimeInputPreflight',
    'analyzerRuntimeInput',
    'runtimeExecution',
    'analyzerRuntime',
    'analyzerWiring',
    'engineCall',
    'StockfishBridge',
    'AndroidCollector',
    'schedulerExecution',
    'persistenceWrite',
    'productAdapter',
    'savedAnalysisIntegration',
    'UI',
    'backend',
    'cache',
    'database',
    'productOutput',
  ];
  return surfaces
      .map(
        (
          surface,
        ) => ControlledAnalyzerAdapterRuntimeInputPreflightBlockedReason(
          blockedReasonId: 'blocked-$surface',
          blockedSurface: surface,
          blocked: true,
          reason:
              'controlledRuntimeInputPreflightKeeps${surface}BlockedAndDoesNotProduceAnalyzerInput',
          deniedFieldIds: seamProbe.policy.deniedFieldIds,
          recommendation: _phase34PRecommendation,
        ),
      )
      .toList(growable: false);
}

List<String> _activeDeniedFieldIds(Iterable<String> deniedFieldIds) {
  return deniedFieldIds
      .where((id) => id.startsWith('active:'))
      .map((id) => id.substring('active:'.length))
      .toList();
}

bool _isQuietSupport(Iterable<String> supportAreaIds) {
  return supportAreaIds.any(
    (id) =>
        id == 'quietMove' ||
        id == 'quietPreparatoryMove' ||
        id == 'quietPreparatory',
  );
}

bool _mentionsPvMultiPv(String reason) {
  final lower = reason.toLowerCase();
  return lower.contains('pv') || lower.contains('multipv');
}

String _ids(Iterable<String> values) {
  final sorted = _sorted(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

List<String> _sorted(Iterable<String> values) {
  return values.where((value) => value.trim().isNotEmpty).toSet().toList()
    ..sort();
}

const _preflightId = 'controlled-analyzer-adapter-runtime-input-preflight';
const _decisionId = 'controlled-runtime-input-preflight-decision';
const _phase34PRecommendation =
    'runControlledAnalyzerAdapterRuntimeInputPreflightDiagnostic';
const _pvMultiPvBoundaryCaseId = 'pv-multipv-support-boundary-32e';

const _requiredCheckIds = <String>{
  'seamProbeDiagnosticPresent',
  'seamProbeResultPresent',
  'seamProbeRequestedAsRefusedRecord',
  'seamProbePerformedFalse',
  'executionPerformedFalse',
  'executionAllowedFalse',
  'runtimeExecutionApprovedFalse',
  'analyzerRuntimeInputProducedFalse',
  'analyzerRuntimeInputApprovedFalse',
  'analyzerWiringAllowedFalse',
  'engineCallsAllowedFalse',
  'schedulerAllowedFalse',
  'persistenceAllowedFalse',
  'productOutputAllowedFalse',
  'productAdapterAllowedFalse',
  'savedAnalysisAllowedFalse',
  'requestMetadataOnly',
  'responseRefusedMetadataOnly',
  'refusedAttemptPresent',
  'disabledRuntimeSkeletonBoundaryPresent',
  'runtimeExecutionPreflightBoundaryPresent',
  'analyzerRuntimeInputBoundaryPresent',
  'analyzerRuntimeInputBlocked',
  'stockfishCommandBlocked',
  'rawUciBlocked',
  'pvDumpBlocked',
  'androidCollectorBlocked',
  'productLabelsBlocked',
  'numericScoresBlocked',
  'officialMetricsBlocked',
  'cpLossBlocked',
  'winProbabilityBlocked',
  'phase32EProofHonestyPreserved',
  'quietPreparatoryExclusionPreserved',
};

const _capturedAndroidProofIds = <String>{
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
};

const _phase32ECaseIds = <String>{
  'king-safety-mating-net-32e',
  'king-safety-mating-net-pressure-32e',
  'endgame-candidate-spread-32e',
  'endgame-precision-candidate-spread-32e',
  'budget-pressure-depth-limited-32e',
  'budget-pressure-wide-candidate-32e',
  'suppression-forced-only-legal-32e',
  _pvMultiPvBoundaryCaseId,
};

const _productFields = <String>{'productLabel', 'productOutput'};
const _finalLabelFields = <String>{'finalMoveLabel'};
const _classifierFields = <String>{
  'classifierLabels',
  'classifierLabel',
  'brilliantGreatMiss',
  'brilliantLabel',
  'greatLabel',
  'missLabel',
  'bestGoodInaccuracyMistakeBlunder',
};
const _scoreFields = <String>{
  'numericMoveScore',
  'aggregateScore',
  'moveScore',
};
const _rankingMetricFields = <String>{
  'moveRanking',
  'officialMetric',
  'officialAccuracy',
  'accuracy',
  'acpl',
};

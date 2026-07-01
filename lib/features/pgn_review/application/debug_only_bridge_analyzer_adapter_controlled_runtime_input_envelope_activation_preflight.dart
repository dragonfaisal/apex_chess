import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope_diagnostic.dart';

const debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightVersion =
    'debug-only-bridge-analyzer-adapter-controlled-runtime-input-envelope-activation-preflight-v1';

enum DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightStatus {
  controlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightReadyWithWarnings(
    'controlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightReadyWithWarnings',
  ),
  controlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightReadyClean(
    'controlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightReadyClean',
  ),
  blockedByUnsafeDisabledRuntimeInputEnvelopeDiagnostic(
    'blockedByUnsafeDisabledRuntimeInputEnvelopeDiagnostic',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidControlledRuntimeInputEnvelopeActivationPreflight(
    'invalidControlledRuntimeInputEnvelopeActivationPreflight',
  );

  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightStatus(
    this.wire,
  );

  final String wire;
}

class ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightInput {
  const ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightInput({
    required this.activationPreflightId,
    required this.sourcePhase,
    required this.sourceDiagnosticIds,
    required this.sourceEnvelopeIds,
    required this.sourcePreflightIds,
    required this.sourceSeamProbeIds,
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
    required this.envelopeCreated,
    required this.envelopeDisabled,
    required this.activationPreflightCreated,
    required this.activationApproved,
    required this.activationPerformed,
    required this.activeRuntimeInputEnvelope,
    required this.playablePayloadCount,
    required this.analyzerRuntimeInputApproved,
    required this.analyzerRuntimeInputProduced,
    required this.runtimeExecutionApproved,
    required this.executionPerformed,
    required this.executionAllowed,
    required this.analyzerWiringAllowed,
    required this.engineCallsAllowed,
    required this.schedulerAllowed,
    required this.persistenceAllowed,
    required this.productOutputAllowed,
    required this.productAdapterAllowed,
    required this.savedAnalysisAllowed,
    required this.recommendation,
  });

  final String activationPreflightId;
  final String sourcePhase;
  final List<String> sourceDiagnosticIds;
  final List<String> sourceEnvelopeIds;
  final List<String> sourcePreflightIds;
  final List<String> sourceSeamProbeIds;
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
  final bool envelopeCreated;
  final bool envelopeDisabled;
  final bool activationPreflightCreated;
  final bool activationApproved;
  final bool activationPerformed;
  final bool activeRuntimeInputEnvelope;
  final int playablePayloadCount;
  final bool analyzerRuntimeInputApproved;
  final bool analyzerRuntimeInputProduced;
  final bool runtimeExecutionApproved;
  final bool executionPerformed;
  final bool executionAllowed;
  final bool analyzerWiringAllowed;
  final bool engineCallsAllowed;
  final bool schedulerAllowed;
  final bool persistenceAllowed;
  final bool productOutputAllowed;
  final bool productAdapterAllowed;
  final bool savedAnalysisAllowed;
  final String recommendation;

  ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightInput
  copyWith({
    String? activationPreflightId,
    String? sourcePhase,
    List<String>? sourceDiagnosticIds,
    List<String>? sourceEnvelopeIds,
    List<String>? sourcePreflightIds,
    List<String>? sourceSeamProbeIds,
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
    bool? envelopeCreated,
    bool? envelopeDisabled,
    bool? activationPreflightCreated,
    bool? activationApproved,
    bool? activationPerformed,
    bool? activeRuntimeInputEnvelope,
    int? playablePayloadCount,
    bool? analyzerRuntimeInputApproved,
    bool? analyzerRuntimeInputProduced,
    bool? runtimeExecutionApproved,
    bool? executionPerformed,
    bool? executionAllowed,
    bool? analyzerWiringAllowed,
    bool? engineCallsAllowed,
    bool? schedulerAllowed,
    bool? persistenceAllowed,
    bool? productOutputAllowed,
    bool? productAdapterAllowed,
    bool? savedAnalysisAllowed,
    String? recommendation,
  }) {
    return ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightInput(
      activationPreflightId:
          activationPreflightId ?? this.activationPreflightId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      sourceDiagnosticIds: sourceDiagnosticIds ?? this.sourceDiagnosticIds,
      sourceEnvelopeIds: sourceEnvelopeIds ?? this.sourceEnvelopeIds,
      sourcePreflightIds: sourcePreflightIds ?? this.sourcePreflightIds,
      sourceSeamProbeIds: sourceSeamProbeIds ?? this.sourceSeamProbeIds,
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
      envelopeCreated: envelopeCreated ?? this.envelopeCreated,
      envelopeDisabled: envelopeDisabled ?? this.envelopeDisabled,
      activationPreflightCreated:
          activationPreflightCreated ?? this.activationPreflightCreated,
      activationApproved: activationApproved ?? this.activationApproved,
      activationPerformed: activationPerformed ?? this.activationPerformed,
      activeRuntimeInputEnvelope:
          activeRuntimeInputEnvelope ?? this.activeRuntimeInputEnvelope,
      playablePayloadCount: playablePayloadCount ?? this.playablePayloadCount,
      analyzerRuntimeInputApproved:
          analyzerRuntimeInputApproved ?? this.analyzerRuntimeInputApproved,
      analyzerRuntimeInputProduced:
          analyzerRuntimeInputProduced ?? this.analyzerRuntimeInputProduced,
      runtimeExecutionApproved:
          runtimeExecutionApproved ?? this.runtimeExecutionApproved,
      executionPerformed: executionPerformed ?? this.executionPerformed,
      executionAllowed: executionAllowed ?? this.executionAllowed,
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
      'activationPreflightId': activationPreflightId,
      'sourcePhase': sourcePhase,
      'sourceDiagnosticIds': sourceDiagnosticIds,
      'sourceEnvelopeIds': sourceEnvelopeIds,
      'sourcePreflightIds': sourcePreflightIds,
      'sourceSeamProbeIds': sourceSeamProbeIds,
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
      'envelopeCreated': envelopeCreated,
      'envelopeDisabled': envelopeDisabled,
      'activationPreflightCreated': activationPreflightCreated,
      'activationApproved': activationApproved,
      'activationPerformed': activationPerformed,
      'activeRuntimeInputEnvelope': activeRuntimeInputEnvelope,
      'playablePayloadCount': playablePayloadCount,
      'analyzerRuntimeInputApproved': analyzerRuntimeInputApproved,
      'analyzerRuntimeInputProduced': analyzerRuntimeInputProduced,
      'runtimeExecutionApproved': runtimeExecutionApproved,
      'executionPerformed': executionPerformed,
      'executionAllowed': executionAllowed,
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

class ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightCheck {
  const ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightCheck({
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

  ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightCheck
  copyWith({
    String? checkId,
    String? checkStatus,
    bool? passed,
    List<String>? inspectedFieldIds,
    List<String>? blockedReasonIds,
    List<String>? deniedFieldIds,
    List<String>? warningReasons,
    String? recommendation,
  }) {
    return ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightCheck(
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

class ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightPolicy {
  const ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightPolicy({
    required this.policyId,
    required this.envelopeDisabled,
    required this.activationAllowed,
    required this.activationPerformed,
    required this.activeRuntimeInputEnvelopeAllowed,
    required this.playablePayloadCount,
    required this.analyzerRuntimeInputApproved,
    required this.analyzerRuntimeInputProduced,
    required this.runtimeExecutionApproved,
    required this.executionPerformed,
    required this.executionAllowed,
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
    required this.deniedFieldIds,
    required this.recommendation,
  });

  factory ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightPolicy.disabled({
    required List<String> deniedFieldIds,
  }) {
    return ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightPolicy(
      policyId: 'controlled-runtime-input-envelope-activation-preflight-policy',
      envelopeDisabled: true,
      activationAllowed: false,
      activationPerformed: false,
      activeRuntimeInputEnvelopeAllowed: false,
      playablePayloadCount: 0,
      analyzerRuntimeInputApproved: false,
      analyzerRuntimeInputProduced: false,
      runtimeExecutionApproved: false,
      executionPerformed: false,
      executionAllowed: false,
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
      deniedFieldIds: deniedFieldIds,
      recommendation: _phase34TRecommendation,
    );
  }

  final String policyId;
  final bool envelopeDisabled;
  final bool activationAllowed;
  final bool activationPerformed;
  final bool activeRuntimeInputEnvelopeAllowed;
  final int playablePayloadCount;
  final bool analyzerRuntimeInputApproved;
  final bool analyzerRuntimeInputProduced;
  final bool runtimeExecutionApproved;
  final bool executionPerformed;
  final bool executionAllowed;
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
  final List<String> deniedFieldIds;
  final String recommendation;

  ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightPolicy
  copyWith({
    String? policyId,
    bool? envelopeDisabled,
    bool? activationAllowed,
    bool? activationPerformed,
    bool? activeRuntimeInputEnvelopeAllowed,
    int? playablePayloadCount,
    bool? analyzerRuntimeInputApproved,
    bool? analyzerRuntimeInputProduced,
    bool? runtimeExecutionApproved,
    bool? executionPerformed,
    bool? executionAllowed,
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
    List<String>? deniedFieldIds,
    String? recommendation,
  }) {
    return ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightPolicy(
      policyId: policyId ?? this.policyId,
      envelopeDisabled: envelopeDisabled ?? this.envelopeDisabled,
      activationAllowed: activationAllowed ?? this.activationAllowed,
      activationPerformed: activationPerformed ?? this.activationPerformed,
      activeRuntimeInputEnvelopeAllowed:
          activeRuntimeInputEnvelopeAllowed ??
          this.activeRuntimeInputEnvelopeAllowed,
      playablePayloadCount: playablePayloadCount ?? this.playablePayloadCount,
      analyzerRuntimeInputApproved:
          analyzerRuntimeInputApproved ?? this.analyzerRuntimeInputApproved,
      analyzerRuntimeInputProduced:
          analyzerRuntimeInputProduced ?? this.analyzerRuntimeInputProduced,
      runtimeExecutionApproved:
          runtimeExecutionApproved ?? this.runtimeExecutionApproved,
      executionPerformed: executionPerformed ?? this.executionPerformed,
      executionAllowed: executionAllowed ?? this.executionAllowed,
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
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'policyId': policyId,
      'envelopeDisabled': envelopeDisabled,
      'activationAllowed': activationAllowed,
      'activationPerformed': activationPerformed,
      'activeRuntimeInputEnvelopeAllowed': activeRuntimeInputEnvelopeAllowed,
      'playablePayloadCount': playablePayloadCount,
      'analyzerRuntimeInputApproved': analyzerRuntimeInputApproved,
      'analyzerRuntimeInputProduced': analyzerRuntimeInputProduced,
      'runtimeExecutionApproved': runtimeExecutionApproved,
      'executionPerformed': executionPerformed,
      'executionAllowed': executionAllowed,
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
      'deniedFieldIds': deniedFieldIds,
      'recommendation': recommendation,
    };
  }
}

class ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDecision {
  const ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDecision({
    required this.decisionId,
    required this.decisionStatus,
    required this.envelopeDisabled,
    required this.activationApproved,
    required this.activationPerformed,
    required this.activeRuntimeInputEnvelope,
    required this.playablePayloadCount,
    required this.analyzerRuntimeInputApproved,
    required this.analyzerRuntimeInputProduced,
    required this.runtimeExecutionApproved,
    required this.executionPerformed,
    required this.executionAllowed,
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
  final bool envelopeDisabled;
  final bool activationApproved;
  final bool activationPerformed;
  final bool activeRuntimeInputEnvelope;
  final int playablePayloadCount;
  final bool analyzerRuntimeInputApproved;
  final bool analyzerRuntimeInputProduced;
  final bool runtimeExecutionApproved;
  final bool executionPerformed;
  final bool executionAllowed;
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

  ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDecision
  copyWith({
    String? decisionId,
    String? decisionStatus,
    bool? envelopeDisabled,
    bool? activationApproved,
    bool? activationPerformed,
    bool? activeRuntimeInputEnvelope,
    int? playablePayloadCount,
    bool? analyzerRuntimeInputApproved,
    bool? analyzerRuntimeInputProduced,
    bool? runtimeExecutionApproved,
    bool? executionPerformed,
    bool? executionAllowed,
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
    return ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDecision(
      decisionId: decisionId ?? this.decisionId,
      decisionStatus: decisionStatus ?? this.decisionStatus,
      envelopeDisabled: envelopeDisabled ?? this.envelopeDisabled,
      activationApproved: activationApproved ?? this.activationApproved,
      activationPerformed: activationPerformed ?? this.activationPerformed,
      activeRuntimeInputEnvelope:
          activeRuntimeInputEnvelope ?? this.activeRuntimeInputEnvelope,
      playablePayloadCount: playablePayloadCount ?? this.playablePayloadCount,
      analyzerRuntimeInputApproved:
          analyzerRuntimeInputApproved ?? this.analyzerRuntimeInputApproved,
      analyzerRuntimeInputProduced:
          analyzerRuntimeInputProduced ?? this.analyzerRuntimeInputProduced,
      runtimeExecutionApproved:
          runtimeExecutionApproved ?? this.runtimeExecutionApproved,
      executionPerformed: executionPerformed ?? this.executionPerformed,
      executionAllowed: executionAllowed ?? this.executionAllowed,
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
      'envelopeDisabled': envelopeDisabled,
      'activationApproved': activationApproved,
      'activationPerformed': activationPerformed,
      'activeRuntimeInputEnvelope': activeRuntimeInputEnvelope,
      'playablePayloadCount': playablePayloadCount,
      'analyzerRuntimeInputApproved': analyzerRuntimeInputApproved,
      'analyzerRuntimeInputProduced': analyzerRuntimeInputProduced,
      'runtimeExecutionApproved': runtimeExecutionApproved,
      'executionPerformed': executionPerformed,
      'executionAllowed': executionAllowed,
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

class ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightBlockedReason {
  const ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightBlockedReason({
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

  ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightBlockedReason
  copyWith({
    String? blockedReasonId,
    String? blockedSurface,
    bool? blocked,
    String? reason,
    List<String>? deniedFieldIds,
    String? recommendation,
  }) {
    return ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightBlockedReason(
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

class ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult {
  ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult({
    required this.status,
    required this.sourceDisabledRuntimeInputEnvelopeDiagnosticStatus,
    required this.sourceDisabledRuntimeInputEnvelopeStatus,
    required this.sourceRuntimeInputPreflightDiagnosticStatus,
    required this.sourceRuntimeInputPreflightStatus,
    required this.sourceDisabledSeamProbeDiagnosticStatus,
    required this.input,
    required this.checks,
    required this.policy,
    required this.decision,
    required this.blockedReasons,
    required this.findings,
    required this.safeForPhase34T,
    required this.nextRecommendation,
  }) : totalChecks = checks.length,
       passedCheckCount = checks.where((check) => check.passed).length,
       warningCheckCount = checks
           .where((check) => check.warningReasons.isNotEmpty)
           .length,
       blockedReasonCount = blockedReasons.length,
       deniedFieldCount = _sorted(policy.deniedFieldIds).length,
       ownerProofQueueCount = input.ownerProofRequired ? 1 : 0,
       disabledEnvelopeCount =
           (input.envelopeCreated && input.envelopeDisabled ? 1 : 0) +
           (decision.envelopeDisabled ? 0 : 1),
       activationPreflightCount = input.activationPreflightCreated ? 1 : 0,
       activationApprovedCount =
           (input.activationApproved ? 1 : 0) +
           (policy.activationAllowed ? 1 : 0) +
           (decision.activationApproved ? 1 : 0),
       activationPerformedCount =
           (input.activationPerformed ? 1 : 0) +
           (policy.activationPerformed ? 1 : 0) +
           (decision.activationPerformed ? 1 : 0),
       activeRuntimeInputEnvelopeCount =
           (input.activeRuntimeInputEnvelope ? 1 : 0) +
           (policy.activeRuntimeInputEnvelopeAllowed ? 1 : 0) +
           (decision.activeRuntimeInputEnvelope ? 1 : 0),
       playablePayloadCount =
           input.playablePayloadCount +
           policy.playablePayloadCount +
           decision.playablePayloadCount +
           _activeDeniedFieldIds(
             policy.deniedFieldIds,
           ).where(_payloadFields.contains).length,
       analyzerRuntimeInputApprovedCount =
           (input.analyzerRuntimeInputApproved ? 1 : 0) +
           (policy.analyzerRuntimeInputApproved ? 1 : 0) +
           (decision.analyzerRuntimeInputApproved ? 1 : 0),
       analyzerRuntimeInputProducedCount =
           (input.analyzerRuntimeInputProduced ? 1 : 0) +
           (policy.analyzerRuntimeInputProduced ? 1 : 0) +
           (decision.analyzerRuntimeInputProduced ? 1 : 0),
       runtimeExecutionApprovedCount =
           (input.runtimeExecutionApproved ? 1 : 0) +
           (policy.runtimeExecutionApproved ? 1 : 0) +
           (decision.runtimeExecutionApproved ? 1 : 0),
       runtimeExecutionCount =
           (input.executionAllowed ? 1 : 0) +
           (input.executionPerformed ? 1 : 0) +
           (policy.executionAllowed ? 1 : 0) +
           (policy.executionPerformed ? 1 : 0) +
           (decision.executionAllowed ? 1 : 0) +
           (decision.executionPerformed ? 1 : 0),
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
           checks
               .expand((check) => _activeDeniedFieldIds(check.deniedFieldIds))
               .length +
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

  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightStatus
  status;
  final String sourceDisabledRuntimeInputEnvelopeDiagnosticStatus;
  final String sourceDisabledRuntimeInputEnvelopeStatus;
  final String sourceRuntimeInputPreflightDiagnosticStatus;
  final String sourceRuntimeInputPreflightStatus;
  final String sourceDisabledSeamProbeDiagnosticStatus;
  final ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightInput
  input;
  final List<
    ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightCheck
  >
  checks;
  final ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightPolicy
  policy;
  final ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDecision
  decision;
  final List<
    ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightBlockedReason
  >
  blockedReasons;
  final List<String> findings;
  final bool safeForPhase34T;
  final String nextRecommendation;
  final int totalChecks;
  final int passedCheckCount;
  final int warningCheckCount;
  final int blockedReasonCount;
  final int deniedFieldCount;
  final int ownerProofQueueCount;
  final int disabledEnvelopeCount;
  final int activationPreflightCount;
  final int activationApprovedCount;
  final int activationPerformedCount;
  final int activeRuntimeInputEnvelopeCount;
  final int playablePayloadCount;
  final int analyzerRuntimeInputApprovedCount;
  final int analyzerRuntimeInputProducedCount;
  final int runtimeExecutionApprovedCount;
  final int runtimeExecutionCount;
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
      !safeForPhase34T ||
      findings.isNotEmpty ||
      totalChecks == 0 ||
      passedCheckCount != totalChecks ||
      blockedReasonCount == 0 ||
      disabledEnvelopeCount < 1 ||
      activationPreflightCount < 1 ||
      activationApprovedCount > 0 ||
      activationPerformedCount > 0 ||
      activeRuntimeInputEnvelopeCount > 0 ||
      playablePayloadCount > 0 ||
      analyzerRuntimeInputApprovedCount > 0 ||
      analyzerRuntimeInputProducedCount > 0 ||
      runtimeExecutionApprovedCount > 0 ||
      runtimeExecutionCount > 0 ||
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
      ownerProofQueueCount > 0;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln(
        '# Controlled Analyzer Adapter Runtime Input Envelope Activation Preflight',
      )
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightVersion',
      )
      ..writeln('- preflight status: ${status.wire}')
      ..writeln(
        '- source disabled runtime input envelope diagnostic status: $sourceDisabledRuntimeInputEnvelopeDiagnosticStatus',
      )
      ..writeln(
        '- source disabled runtime input envelope status: $sourceDisabledRuntimeInputEnvelopeStatus',
      )
      ..writeln(
        '- source runtime input preflight diagnostic status: $sourceRuntimeInputPreflightDiagnosticStatus',
      )
      ..writeln(
        '- source runtime input preflight status: $sourceRuntimeInputPreflightStatus',
      )
      ..writeln(
        '- source disabled seam probe diagnostic status: $sourceDisabledSeamProbeDiagnosticStatus',
      )
      ..writeln('- safe for Phase 34T: $safeForPhase34T')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln()
      ..writeln('## Activation Preflight Check Summary')
      ..writeln('| Check | Status | Passed | Blocked reasons |')
      ..writeln('| --- | --- | --- | --- |');
    for (final check in checks) {
      buffer.writeln(
        '| ${check.checkId} | ${check.checkStatus} | ${check.passed} | ${_ids(check.blockedReasonIds)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Activation Decision Summary')
      ..writeln('- decision ID: ${decision.decisionId}')
      ..writeln('- decision status: ${decision.decisionStatus}')
      ..writeln('- envelopeDisabled: ${decision.envelopeDisabled}')
      ..writeln('- activationApproved: ${decision.activationApproved}')
      ..writeln('- activationPerformed: ${decision.activationPerformed}')
      ..writeln(
        '- activeRuntimeInputEnvelope: ${decision.activeRuntimeInputEnvelope}',
      )
      ..writeln('- playablePayloadCount: ${decision.playablePayloadCount}')
      ..writeln(
        '- analyzerRuntimeInputApproved: ${decision.analyzerRuntimeInputApproved}',
      )
      ..writeln(
        '- analyzerRuntimeInputProduced: ${decision.analyzerRuntimeInputProduced}',
      )
      ..writeln(
        '- runtimeExecutionApproved: ${decision.runtimeExecutionApproved}',
      )
      ..writeln('- executionPerformed: ${decision.executionPerformed}')
      ..writeln('- executionAllowed: ${decision.executionAllowed}')
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
      ..writeln('- disabled envelope count: $disabledEnvelopeCount')
      ..writeln('- activation preflight count: $activationPreflightCount')
      ..writeln('- activation approved count: $activationApprovedCount')
      ..writeln('- activation performed count: $activationPerformedCount')
      ..writeln(
        '- active runtime input envelope count: $activeRuntimeInputEnvelopeCount',
      )
      ..writeln('- playable payload count: $playablePayloadCount')
      ..writeln(
        '- analyzer runtime input approved count: $analyzerRuntimeInputApprovedCount',
      )
      ..writeln(
        '- analyzer runtime input produced count: $analyzerRuntimeInputProducedCount',
      )
      ..writeln(
        '- runtime execution approved count: $runtimeExecutionApprovedCount',
      )
      ..writeln('- runtime execution count: $runtimeExecutionCount')
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
      ..writeln('- safe for Phase 34T: $safeForPhase34T')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- findings: ${_ids(findings)}')
      ..writeln();
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent(' ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightVersion,
      'status': status.wire,
      'sourceDisabledRuntimeInputEnvelopeDiagnosticStatus':
          sourceDisabledRuntimeInputEnvelopeDiagnosticStatus,
      'sourceDisabledRuntimeInputEnvelopeStatus':
          sourceDisabledRuntimeInputEnvelopeStatus,
      'sourceRuntimeInputPreflightDiagnosticStatus':
          sourceRuntimeInputPreflightDiagnosticStatus,
      'sourceRuntimeInputPreflightStatus': sourceRuntimeInputPreflightStatus,
      'sourceDisabledSeamProbeDiagnosticStatus':
          sourceDisabledSeamProbeDiagnosticStatus,
      'safeForPhase34T': safeForPhase34T,
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
        'disabledEnvelopeCount': disabledEnvelopeCount,
        'activationPreflightCount': activationPreflightCount,
        'activationApprovedCount': activationApprovedCount,
        'activationPerformedCount': activationPerformedCount,
        'activeRuntimeInputEnvelopeCount': activeRuntimeInputEnvelopeCount,
        'playablePayloadCount': playablePayloadCount,
        'analyzerRuntimeInputApprovedCount': analyzerRuntimeInputApprovedCount,
        'analyzerRuntimeInputProducedCount': analyzerRuntimeInputProducedCount,
        'runtimeExecutionApprovedCount': runtimeExecutionApprovedCount,
        'runtimeExecutionCount': runtimeExecutionCount,
        'analyzerWiringCount': analyzerWiringCount,
        'executableRuntimeCount': executableRuntimeCount,
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

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflight {
  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflight();

  ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult
  evaluate({
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticResult?
    disabledRuntimeInputEnvelopeDiagnosticResult,
    DisabledAnalyzerAdapterRuntimeInputEnvelopeResult?
    disabledRuntimeInputEnvelopeResult,
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticResult?
    runtimeInputPreflightDiagnosticResult,
    ControlledAnalyzerAdapterRuntimeInputPreflightResult?
    runtimeInputPreflightResult,
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticResult?
    disabledSeamProbeDiagnosticResult,
  }) {
    final envelope =
        disabledRuntimeInputEnvelopeResult ??
        const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelope()
            .evaluate(
              runtimeInputPreflightDiagnosticResult:
                  runtimeInputPreflightDiagnosticResult,
              runtimeInputPreflightResult: runtimeInputPreflightResult,
              disabledSeamProbeDiagnosticResult:
                  disabledSeamProbeDiagnosticResult,
            );
    final envelopeDiagnostic =
        disabledRuntimeInputEnvelopeDiagnosticResult ??
        const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnostic()
            .evaluate(
              disabledRuntimeInputEnvelopeResult: envelope,
              runtimeInputPreflightDiagnosticResult:
                  runtimeInputPreflightDiagnosticResult,
              runtimeInputPreflightResult: runtimeInputPreflightResult,
              disabledSeamProbeDiagnosticResult:
                  disabledSeamProbeDiagnosticResult,
            );
    final blockedReasons = _blockedReasonsFor(envelope);
    final checks = _checksFor(
      envelope: envelope,
      envelopeDiagnostic: envelopeDiagnostic,
      blockedReasons: blockedReasons,
    );
    final policy =
        ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightPolicy.disabled(
          deniedFieldIds: envelope.policy.deniedFieldIds,
        );
    final decision =
        ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDecision(
          decisionId: _decisionId,
          decisionStatus:
              'runtimeInputEnvelopeActivationPreflightInspectedEnvelopeStillDisabled',
          envelopeDisabled: true,
          activationApproved: false,
          activationPerformed: false,
          activeRuntimeInputEnvelope: false,
          playablePayloadCount: 0,
          analyzerRuntimeInputApproved: false,
          analyzerRuntimeInputProduced: false,
          runtimeExecutionApproved: false,
          executionPerformed: false,
          executionAllowed: false,
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
            'activationPreflightExistsButRuntimeInputEnvelopeStillDisabled',
          ],
          recommendation: _phase34TRecommendation,
        );
    final input =
        ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightInput(
          activationPreflightId: _activationPreflightId,
          sourcePhase: 'Phase34R',
          sourceDiagnosticIds: envelopeDiagnostic.rows
              .map((row) => row.diagnosticRowId)
              .toList(),
          sourceEnvelopeIds: <String>[envelope.input.envelopeId],
          sourcePreflightIds: envelope.input.sourcePreflightIds,
          sourceSeamProbeIds: envelope.input.sourceSeamProbeIds,
          sourceSkeletonIds: envelope.input.sourceSkeletonIds,
          sourcePreparationIds: envelope.input.sourcePreparationIds,
          sourceCaseIds: envelope.input.sourceCaseIds,
          sourceActionIds: envelope.input.sourceActionIds,
          sourcePatchIds: envelope.input.sourcePatchIds,
          sourceRefinementIds: envelope.input.sourceRefinementIds,
          checkIds: checks.map((check) => check.checkId).toList(),
          decisionId: decision.decisionId,
          blockedReasonIds: decision.blockedReasonIds,
          deniedFieldIds: policy.deniedFieldIds,
          supportAreaIds: envelope.input.supportAreaIds,
          warningReasons: _sorted(<String>[
            ...envelope.input.warningReasons,
            'controlledActivationPreflightNoRuntimeInputEnvelopeActivation',
          ]),
          proofLimitReasons: envelope.input.proofLimitReasons,
          androidProofIds: envelope.input.androidProofIds,
          ownerProofRequired: envelope.input.ownerProofRequired,
          envelopeCreated: envelope.input.envelopeCreated,
          envelopeDisabled: true,
          activationPreflightCreated: true,
          activationApproved: false,
          activationPerformed: false,
          activeRuntimeInputEnvelope: false,
          playablePayloadCount: 0,
          analyzerRuntimeInputApproved: false,
          analyzerRuntimeInputProduced: false,
          runtimeExecutionApproved: false,
          executionPerformed: false,
          executionAllowed: false,
          analyzerWiringAllowed: false,
          engineCallsAllowed: false,
          schedulerAllowed: false,
          persistenceAllowed: false,
          productOutputAllowed: false,
          productAdapterAllowed: false,
          savedAnalysisAllowed: false,
          recommendation: _phase34TRecommendation,
        );
    final findings = _sorted(<String>[
      if (envelopeDiagnostic.hasUnsafePolicyViolation ||
          !envelopeDiagnostic.safeForPhase34S)
        'unsafePhase34RDisabledRuntimeInputEnvelopeDiagnostic',
      if (envelope.hasUnsafePolicyViolation || !envelope.safeForPhase34R)
        'unsafePhase34QDisabledRuntimeInputEnvelope',
      if (runtimeInputPreflightDiagnosticResult != null &&
          (runtimeInputPreflightDiagnosticResult.hasUnsafePolicyViolation ||
              !runtimeInputPreflightDiagnosticResult.safeForPhase34Q))
        'unsafePhase34PRuntimeInputPreflightDiagnostic',
      if (runtimeInputPreflightResult != null &&
          (runtimeInputPreflightResult.hasUnsafePolicyViolation ||
              !runtimeInputPreflightResult.safeForPhase34P))
        'unsafePhase34ORuntimeInputPreflight',
      if (disabledSeamProbeDiagnosticResult != null &&
          (disabledSeamProbeDiagnosticResult.hasUnsafePolicyViolation ||
              !disabledSeamProbeDiagnosticResult.safeForPhase34O))
        'unsafePhase34NDisabledRuntimeExecutionSeamProbeDiagnostic',
      ...const ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightValidator()
          .validatePreflight(
            input: input,
            checks: checks,
            policy: policy,
            decision: decision,
            blockedReasons: blockedReasons,
          ),
    ]);
    final safeForPhase34T = findings.isEmpty;
    return ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult(
      status: !safeForPhase34T
          ? DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightStatus
                .blockedByPolicyBoundary
          : checks.any((check) => check.warningReasons.isNotEmpty)
          ? DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightStatus
                .controlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightReadyWithWarnings
          : DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightStatus
                .controlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightReadyClean,
      sourceDisabledRuntimeInputEnvelopeDiagnosticStatus:
          envelopeDiagnostic.status.wire,
      sourceDisabledRuntimeInputEnvelopeStatus: envelope.status.wire,
      sourceRuntimeInputPreflightDiagnosticStatus:
          envelope.sourceRuntimeInputPreflightDiagnosticStatus,
      sourceRuntimeInputPreflightStatus:
          envelope.sourceRuntimeInputPreflightStatus,
      sourceDisabledSeamProbeDiagnosticStatus:
          envelope.sourceSeamProbeDiagnosticStatus,
      input: input,
      checks: checks,
      policy: policy,
      decision: decision,
      blockedReasons: blockedReasons,
      findings: findings,
      safeForPhase34T: safeForPhase34T,
      nextRecommendation: safeForPhase34T
          ? _phase34TRecommendation
          : 'blockedByUnsafeRuntimeInputEnvelopeActivationPreflight',
    );
  }
}

class ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightValidator {
  const ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightValidator();

  List<String> validateResult(
    ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult
    result,
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
    required ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightInput
    input,
    required Iterable<
      ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightCheck
    >
    checks,
    required ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightPolicy
    policy,
    required ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDecision
    decision,
    required Iterable<
      ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightBlockedReason
    >
    blockedReasons,
  }) {
    return _sorted(<String>[
      ...validateInput(input),
      ...checks.expand(validateCheck),
      ...validatePolicy(policy),
      ...validateDecision(decision),
      ...blockedReasons.expand(validateBlockedReason),
      for (final requiredId in _requiredCheckIds)
        if (!checks.any((check) => check.checkId == requiredId))
          'missingActivationPreflightCheck:$requiredId',
      for (final requiredId in _requiredBlockedReasonIds)
        if (!blockedReasons.any(
          (reason) => reason.blockedReasonId == requiredId,
        ))
          'missingActivationPreflightBlockedReason:$requiredId',
      if (input.recommendation != _phase34TRecommendation ||
          decision.recommendation != _phase34TRecommendation)
        'missingPhase34TActivationPreflightDiagnosticRecommendation',
    ]);
  }

  List<String> validateInput(
    ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightInput input,
  ) {
    return _validateBoundary(
      sourceCaseIds: input.sourceCaseIds,
      supportAreaIds: input.supportAreaIds,
      proofLimitReasons: input.proofLimitReasons,
      androidProofIds: input.androidProofIds,
      ownerProofRequired: input.ownerProofRequired,
      deniedFieldIds: input.deniedFieldIds,
      blockedReasonIds: input.blockedReasonIds,
      envelopeDisabled: input.envelopeDisabled,
      activationApproved: input.activationApproved,
      activationPerformed: input.activationPerformed,
      activeRuntimeInputEnvelope: input.activeRuntimeInputEnvelope,
      playablePayloadCount: input.playablePayloadCount,
      analyzerRuntimeInputApproved: input.analyzerRuntimeInputApproved,
      analyzerRuntimeInputProduced: input.analyzerRuntimeInputProduced,
      runtimeExecutionApproved: input.runtimeExecutionApproved,
      executionPerformed: input.executionPerformed,
      executionAllowed: input.executionAllowed,
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
    ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightCheck check,
  ) {
    final activeDenied = _activeDeniedFieldIds(check.deniedFieldIds);
    return _sorted(<String>[
      if (!_requiredCheckIds.contains(check.checkId))
        'unknownActivationPreflightCheck',
      if (!check.passed) 'activationPreflightCheckFailed',
      if (check.recommendation != _phase34TRecommendation)
        'missingPhase34TActivationPreflightDiagnosticRecommendation',
      if (check.blockedReasonIds.any((id) => id.startsWith('active:')))
        'blockedReasonActivated',
      if (activeDenied.isNotEmpty) 'activeDeniedFields',
      ..._deniedFieldFindings(activeDenied),
    ]);
  }

  List<String> validatePolicy(
    ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightPolicy
    policy,
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
        envelopeDisabled: policy.envelopeDisabled,
        activationApproved: policy.activationAllowed,
        activationPerformed: policy.activationPerformed,
        activeRuntimeInputEnvelope: policy.activeRuntimeInputEnvelopeAllowed,
        playablePayloadCount: policy.playablePayloadCount,
        analyzerRuntimeInputApproved: policy.analyzerRuntimeInputApproved,
        analyzerRuntimeInputProduced: policy.analyzerRuntimeInputProduced,
        runtimeExecutionApproved: policy.runtimeExecutionApproved,
        executionPerformed: policy.executionPerformed,
        executionAllowed: policy.executionAllowed,
        analyzerWiringAllowed: policy.analyzerWiringAllowed,
        engineCallsAllowed: policy.engineCallsAllowed,
        schedulerAllowed: policy.schedulerAllowed,
        persistenceAllowed: policy.persistenceAllowed,
        productOutputAllowed: policy.productOutputAllowed,
        productAdapterAllowed: policy.productAdapterAllowed,
        savedAnalysisAllowed: policy.savedAnalysisAllowed,
        recommendation: policy.recommendation,
      ),
      if (policy.uiAllowed || policy.backendAllowed) 'uiBackendActivation',
      if (policy.cacheAllowed || policy.databaseAllowed)
        'cacheDatabaseWriteEnabled',
    ]);
  }

  List<String> validateDecision(
    ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDecision
    decision,
  ) {
    return _validateBoundary(
      sourceCaseIds: const <String>[],
      supportAreaIds: const <String>[],
      proofLimitReasons: const <String>[],
      androidProofIds: const <String>[],
      ownerProofRequired: false,
      deniedFieldIds: const <String>[],
      blockedReasonIds: decision.blockedReasonIds,
      envelopeDisabled: decision.envelopeDisabled,
      activationApproved: decision.activationApproved,
      activationPerformed: decision.activationPerformed,
      activeRuntimeInputEnvelope: decision.activeRuntimeInputEnvelope,
      playablePayloadCount: decision.playablePayloadCount,
      analyzerRuntimeInputApproved: decision.analyzerRuntimeInputApproved,
      analyzerRuntimeInputProduced: decision.analyzerRuntimeInputProduced,
      runtimeExecutionApproved: decision.runtimeExecutionApproved,
      executionPerformed: decision.executionPerformed,
      executionAllowed: decision.executionAllowed,
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
    ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightBlockedReason
    reason,
  ) {
    final activeDenied = _activeDeniedFieldIds(reason.deniedFieldIds);
    return _sorted(<String>[
      if (!_requiredBlockedReasonIds.contains(reason.blockedReasonId))
        'unknownActivationPreflightBlockedReason',
      if (!reason.blocked) 'blockedReasonActivated',
      if (reason.recommendation != _phase34TRecommendation)
        'missingPhase34TActivationPreflightDiagnosticRecommendation',
      if (reason.blockedReasonId.startsWith('active:'))
        'blockedReasonActivated',
      if (activeDenied.isNotEmpty) 'activeDeniedFields',
      ..._deniedFieldFindings(activeDenied),
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
      if (lower.contains('playable fen payload'))
        'reportTextLeak:playableFenPayload',
      if (lower.contains('pgn payload:')) 'reportTextLeak:pgnPayload',
      if (lower.contains('uci move payload')) 'reportTextLeak:uciMovePayload',
      if (lower.contains('activationapproved: true'))
        'reportTextLeak:activationApproval',
      if (lower.contains('activationperformed: true'))
        'reportTextLeak:activationPerformed',
      if (lower.contains('activeruntimeinputenvelope: true'))
        'reportTextLeak:activeRuntimeInputEnvelope',
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
    required bool envelopeDisabled,
    required bool activationApproved,
    required bool activationPerformed,
    required bool activeRuntimeInputEnvelope,
    required int playablePayloadCount,
    required bool analyzerRuntimeInputApproved,
    required bool analyzerRuntimeInputProduced,
    required bool runtimeExecutionApproved,
    required bool executionPerformed,
    required bool executionAllowed,
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
      if (recommendation != _phase34TRecommendation)
        'missingPhase34TActivationPreflightDiagnosticRecommendation',
      if (!envelopeDisabled) 'runtimeInputEnvelopeNotDisabled',
      if (activationApproved) 'activationApprovedEnabled',
      if (activationPerformed) 'activationPerformedEnabled',
      if (activeRuntimeInputEnvelope) 'activeRuntimeInputEnvelopeEnabled',
      if (playablePayloadCount > 0) 'playablePayloadEnabled',
      if (analyzerRuntimeInputApproved) 'analyzerRuntimeInputApproved',
      if (analyzerRuntimeInputProduced) 'analyzerRuntimeInputProduced',
      if (runtimeExecutionApproved) 'runtimeExecutionApprovedEnabled',
      if (executionAllowed) 'executionAllowedEnabled',
      if (executionPerformed) 'executionPerformedEnabled',
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
      ..._deniedFieldFindings(activeDenied),
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

List<ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightCheck>
_checksFor({
  required DisabledAnalyzerAdapterRuntimeInputEnvelopeResult envelope,
  required DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticResult
  envelopeDiagnostic,
  required List<
    ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightBlockedReason
  >
  blockedReasons,
}) {
  final blockedReasonIds = blockedReasons
      .map((reason) => reason.blockedReasonId)
      .toList();
  return _requiredCheckIds
      .map(
        (
          id,
        ) => ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightCheck(
          checkId: id,
          checkStatus:
              'passedControlledRuntimeInputEnvelopeActivationPreflightCheck',
          passed: _checkPassed(id, envelope, envelopeDiagnostic),
          inspectedFieldIds: _inspectedFieldsForCheck(id),
          blockedReasonIds: blockedReasonIds,
          deniedFieldIds: _deniedFieldsForCheck(
            id,
            envelope.policy.deniedFieldIds,
          ),
          warningReasons: const <String>[
            'activationPreflightIsDeveloperOnlyNoRuntimeInputEnvelopeActivation',
          ],
          recommendation: _phase34TRecommendation,
        ),
      )
      .toList(growable: false);
}

bool _checkPassed(
  String id,
  DisabledAnalyzerAdapterRuntimeInputEnvelopeResult envelope,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticResult
  envelopeDiagnostic,
) {
  return switch (id) {
    'disabledEnvelopeDiagnosticPresent' =>
      envelopeDiagnostic.totalDiagnosticRows > 0,
    'disabledEnvelopeResultPresent' => envelope.input.envelopeId.isNotEmpty,
    'envelopeCreatedAsDisabledMetadata' =>
      envelope.input.envelopeCreated && envelope.input.envelopeDisabled,
    'envelopeDisabledTrue' =>
      envelope.input.envelopeDisabled && envelope.policy.envelopeDisabled,
    'activeRuntimeInputEnvelopeFalse' =>
      envelope.activeRuntimeInputEnvelopeCount == 0,
    'activationApprovedFalse' => true,
    'activationPerformedFalse' => true,
    'playablePayloadCountZero' => envelope.activePayloadSlotCount == 0,
    'analyzerRuntimeInputApprovedFalse' =>
      envelope.analyzerRuntimeInputApprovedCount == 0,
    'analyzerRuntimeInputProducedFalse' =>
      envelope.analyzerRuntimeInputProducedCount == 0,
    'runtimeExecutionApprovedFalse' =>
      envelope.runtimeExecutionApprovedCount == 0,
    'executionAllowedFalse' =>
      !envelope.input.executionAllowed && !envelope.policy.executionAllowed,
    'executionPerformedFalse' =>
      !envelope.input.executionPerformed && !envelope.policy.executionPerformed,
    'analyzerWiringAllowedFalse' => envelope.analyzerWiringCount == 0,
    'engineCallsAllowedFalse' => envelope.engineCallCount == 0,
    'schedulerAllowedFalse' => envelope.schedulerExecutionCount == 0,
    'persistenceAllowedFalse' => envelope.persistenceWriteCount == 0,
    'productOutputAllowedFalse' => envelope.productOutputCount == 0,
    'productAdapterAllowedFalse' => envelope.productAdapterCount == 0,
    'savedAnalysisAllowedFalse' => envelope.savedAnalysisIntegrationCount == 0,
    'fenPayloadBlocked' =>
      _slotBlocked(envelope, 'fenPayloadSlotBlocked') &&
          envelope.policy.deniedFieldIds.contains('playableFenPayload'),
    'pgnPayloadBlocked' =>
      _slotBlocked(envelope, 'pgnPayloadSlotBlocked') &&
          envelope.policy.deniedFieldIds.contains('pgnPayload'),
    'moveListPayloadBlocked' =>
      _slotBlocked(envelope, 'moveListSlotBlocked') &&
          envelope.policy.deniedFieldIds.contains('moveListPayload'),
    'uciMovePayloadBlocked' =>
      _slotBlocked(envelope, 'uciMoveSlotBlocked') &&
          envelope.policy.deniedFieldIds.contains('uciMovePayload'),
    'engineOptionPayloadBlocked' =>
      _slotBlocked(envelope, 'engineOptionSlotBlocked') &&
          envelope.policy.deniedFieldIds.contains('engineOptionPayload'),
    'depthPayloadBlocked' =>
      _slotBlocked(envelope, 'depthSlotBlocked') &&
          envelope.policy.deniedFieldIds.contains('depthAnalysisValue'),
    'multiPvPayloadBlocked' =>
      _slotBlocked(envelope, 'multiPvSlotBlocked') &&
          envelope.policy.deniedFieldIds.contains('multiPvAnalysisValue'),
    'stockfishCommandBlocked' => envelope.policy.deniedFieldIds.contains(
      'stockfishCommand',
    ),
    'rawUciBlocked' => envelope.policy.deniedFieldIds.contains('rawUci'),
    'pvDumpBlocked' => envelope.policy.deniedFieldIds.contains('pvDump'),
    'androidCollectorBlocked' => envelope.blockedReasons.any(
      (reason) => reason.blockedReasonId == 'androidCollectorBlocked',
    ),
    'productLabelsBlocked' => envelope.policy.deniedFieldIds.contains(
      'productLabel',
    ),
    'numericScoresBlocked' => envelope.policy.deniedFieldIds.contains(
      'numericMoveScore',
    ),
    'officialMetricsBlocked' =>
      envelope.policy.deniedFieldIds.contains('officialMetric') ||
          envelope.policy.deniedFieldIds.contains('accuracy') ||
          envelope.policy.deniedFieldIds.contains('acpl'),
    'cpLossBlocked' => envelope.policy.deniedFieldIds.contains('cpLoss'),
    'winProbabilityBlocked' => envelope.policy.deniedFieldIds.contains(
      'winProbability',
    ),
    'phase32EProofHonestyPreserved' => envelope.phase32EProofClaimCount == 0,
    'quietPreparatoryExclusionPreserved' => !_isQuietSupport(
      envelope.input.supportAreaIds,
    ),
    _ => false,
  };
}

bool _slotBlocked(
  DisabledAnalyzerAdapterRuntimeInputEnvelopeResult envelope,
  String slotId,
) {
  return envelope.slots.any(
    (slot) =>
        slot.slotId == slotId &&
        slot.disabled &&
        slot.blocked &&
        slot.redacted &&
        !slot.activePayloadPresent,
  );
}

List<String> _inspectedFieldsForCheck(String id) {
  return switch (id) {
    'disabledEnvelopeDiagnosticPresent' => const <String>[
      'sourceDiagnosticIds',
    ],
    'disabledEnvelopeResultPresent' => const <String>['sourceEnvelopeIds'],
    'envelopeCreatedAsDisabledMetadata' => const <String>[
      'envelopeCreated',
      'envelopeDisabled',
    ],
    'activationApprovedFalse' => const <String>['activationApproved'],
    'activationPerformedFalse' => const <String>['activationPerformed'],
    'activeRuntimeInputEnvelopeFalse' => const <String>[
      'activeRuntimeInputEnvelope',
    ],
    'playablePayloadCountZero' => const <String>['playablePayloadCount'],
    'analyzerRuntimeInputApprovedFalse' => const <String>[
      'analyzerRuntimeInputApproved',
    ],
    'analyzerRuntimeInputProducedFalse' => const <String>[
      'analyzerRuntimeInputProduced',
    ],
    'runtimeExecutionApprovedFalse' => const <String>[
      'runtimeExecutionApproved',
    ],
    'executionAllowedFalse' => const <String>['executionAllowed'],
    'executionPerformedFalse' => const <String>['executionPerformed'],
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
    'fenPayloadBlocked': <String>['playableFenPayload'],
    'pgnPayloadBlocked': <String>['pgnPayload'],
    'moveListPayloadBlocked': <String>['moveListPayload'],
    'uciMovePayloadBlocked': <String>['uciMovePayload'],
    'engineOptionPayloadBlocked': <String>['engineOptionPayload'],
    'depthPayloadBlocked': <String>['depthAnalysisValue'],
    'multiPvPayloadBlocked': <String>['multiPvAnalysisValue'],
    'stockfishCommandBlocked': <String>['stockfishCommand'],
    'rawUciBlocked': <String>['rawUci'],
    'pvDumpBlocked': <String>['pvDump'],
    'androidCollectorBlocked': <String>['androidCollectorRequirement'],
    'productLabelsBlocked': <String>['productLabel', 'finalMoveLabel'],
    'numericScoresBlocked': <String>['numericMoveScore', 'aggregateScore'],
    'officialMetricsBlocked': <String>['officialMetric', 'accuracy', 'acpl'],
    'cpLossBlocked': <String>['cpLoss'],
    'winProbabilityBlocked': <String>['winProbability'],
  };
  return _sorted(byCheck[id] ?? sourceDeniedFields);
}

List<
  ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightBlockedReason
>
_blockedReasonsFor(DisabledAnalyzerAdapterRuntimeInputEnvelopeResult envelope) {
  return _requiredBlockedReasonIds
      .map(
        (
          id,
        ) => ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightBlockedReason(
          blockedReasonId: id,
          blockedSurface: id,
          blocked: true,
          reason:
              'controlledRuntimeInputEnvelopeActivationPreflightKeeps${id}Blocked',
          deniedFieldIds: _deniedFieldsForSurface(
            id,
            envelope.policy.deniedFieldIds,
          ),
          recommendation: _phase34TRecommendation,
        ),
      )
      .toList(growable: false);
}

List<String> _deniedFieldsForSurface(
  String id,
  Iterable<String> sourceDeniedFields,
) {
  final lower = id.toLowerCase();
  if (lower.contains('playablepayload')) {
    return const <String>[
      'playableFenPayload',
      'pgnPayload',
      'moveListPayload',
      'uciMovePayload',
      'engineOptionPayload',
      'depthAnalysisValue',
      'multiPvAnalysisValue',
    ];
  }
  if (lower.contains('stockfish')) return const <String>['stockfishCommand'];
  if (lower.contains('rawuci')) return const <String>['rawUci'];
  if (lower.contains('pvdump')) return const <String>['pvDump'];
  if (lower.contains('android')) {
    return const <String>['androidCollectorRequirement'];
  }
  if (lower.contains('scheduler')) return const <String>['schedulerExecution'];
  if (lower.contains('persistence')) return const <String>['persistenceWrite'];
  if (lower.contains('productadapter')) {
    return const <String>['productAdapterBehavior'];
  }
  if (lower.contains('savedanalysis')) {
    return const <String>['savedAnalysisIntegration'];
  }
  if (lower.contains('productlabels')) return const <String>['productLabel'];
  if (lower.contains('numericscores')) {
    return const <String>['numericMoveScore'];
  }
  if (lower.contains('officialmetrics')) {
    return const <String>['officialMetric'];
  }
  if (lower.contains('cploss')) return const <String>['cpLoss'];
  if (lower.contains('winprobability')) return const <String>['winProbability'];
  if (lower.contains('analyzerruntimeinput')) {
    return const <String>[
      'analyzerRuntimeInput',
      'analyzerRuntimeInputApproval',
      'analyzerRuntimeInputProduction',
    ];
  }
  if (lower.contains('activation')) {
    return const <String>['activeRuntimeInputEnvelope'];
  }
  if (lower.contains('runtimeexecution')) {
    return const <String>['runtimeExecutionResult'];
  }
  if (lower.contains('engine')) return const <String>['engineResult'];
  if (lower.contains('ui') || lower.contains('backend')) {
    return const <String>['uiState', 'backendResponse'];
  }
  if (lower.contains('cache') || lower.contains('database')) {
    return const <String>['cacheDatabaseWrite'];
  }
  return _sorted(sourceDeniedFields);
}

List<String> _deniedFieldFindings(Set<String> activeDenied) {
  return <String>[
    if (activeDenied.any(_productFields.contains)) 'productLabelsEnabled',
    if (activeDenied.any(_finalLabelFields.contains)) 'finalLabelsEnabled',
    if (activeDenied.any(_classifierFields.contains)) 'classifierLabelsEnabled',
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
    if (activeDenied.contains('analyzerRuntimeInputApproval'))
      'analyzerRuntimeInputApproved',
    if (activeDenied.contains('analyzerRuntimeInputProduction'))
      'analyzerRuntimeInputProduced',
    if (activeDenied.contains('activeRuntimeInputEnvelope'))
      'activeRuntimeInputEnvelopeEnabled',
    if (activeDenied.contains('playableFenPayload'))
      'playableFenPayloadEnabled',
    if (activeDenied.contains('pgnPayload')) 'pgnPayloadEnabled',
    if (activeDenied.contains('moveListPayload')) 'moveListPayloadEnabled',
    if (activeDenied.contains('uciMovePayload')) 'uciMovePayloadEnabled',
    if (activeDenied.contains('engineOptionPayload'))
      'engineOptionPayloadEnabled',
    if (activeDenied.contains('depthAnalysisValue'))
      'depthAnalysisValueEnabled',
    if (activeDenied.contains('multiPvAnalysisValue'))
      'multiPvAnalysisValueEnabled',
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
  ];
}

Set<String> _activeDeniedFieldIds(Iterable<String> deniedFieldIds) {
  return deniedFieldIds
      .where((id) => id.startsWith('active:'))
      .map((id) => id.substring('active:'.length))
      .toSet();
}

bool _isQuietSupport(Iterable<String> supportAreaIds) {
  return supportAreaIds.any((id) {
    final lower = id.toLowerCase();
    return lower.contains('quiet') || lower.contains('preparatory');
  });
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

const _activationPreflightId =
    'controlled-analyzer-adapter-runtime-input-envelope-activation-preflight';
const _decisionId =
    'controlled-runtime-input-envelope-activation-preflight-decision';
const _phase34TRecommendation =
    'runControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDiagnostic';
const _pvMultiPvBoundaryCaseId = 'pv-multipv-support-boundary-32e';

const _requiredCheckIds = <String>{
  'disabledEnvelopeDiagnosticPresent',
  'disabledEnvelopeResultPresent',
  'envelopeCreatedAsDisabledMetadata',
  'envelopeDisabledTrue',
  'activeRuntimeInputEnvelopeFalse',
  'activationApprovedFalse',
  'activationPerformedFalse',
  'playablePayloadCountZero',
  'analyzerRuntimeInputApprovedFalse',
  'analyzerRuntimeInputProducedFalse',
  'runtimeExecutionApprovedFalse',
  'executionAllowedFalse',
  'executionPerformedFalse',
  'analyzerWiringAllowedFalse',
  'engineCallsAllowedFalse',
  'schedulerAllowedFalse',
  'persistenceAllowedFalse',
  'productOutputAllowedFalse',
  'productAdapterAllowedFalse',
  'savedAnalysisAllowedFalse',
  'fenPayloadBlocked',
  'pgnPayloadBlocked',
  'moveListPayloadBlocked',
  'uciMovePayloadBlocked',
  'engineOptionPayloadBlocked',
  'depthPayloadBlocked',
  'multiPvPayloadBlocked',
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

const _requiredBlockedReasonIds = <String>{
  'activationPreflightOnly',
  'runtimeInputEnvelopeActivationNotApproved',
  'activationPerformedBlocked',
  'activeRuntimeInputEnvelopeBlocked',
  'playablePayloadsBlocked',
  'analyzerRuntimeInputNotApproved',
  'analyzerRuntimeInputProductionBlocked',
  'runtimeExecutionNotApproved',
  'executionAllowedFalse',
  'analyzerWiringBlocked',
  'engineCallsBlocked',
  'stockfishCommandBlocked',
  'rawUciBlocked',
  'pvDumpBlocked',
  'androidCollectorBlocked',
  'schedulerExecutionBlocked',
  'persistenceWriteBlocked',
  'productOutputBlocked',
  'productAdapterBlocked',
  'savedAnalysisBlocked',
  'uiBackendBlocked',
  'cacheDatabaseBlocked',
  'productLabelsBlocked',
  'numericScoresBlocked',
  'officialMetricsBlocked',
  'cpLossBlocked',
  'winProbabilityBlocked',
  'phase32EProofHonestyPreserved',
  'quietPreparatoryExclusionPreserved',
};

const _payloadFields = <String>{
  'playableFenPayload',
  'pgnPayload',
  'moveListPayload',
  'uciMovePayload',
  'engineOptionPayload',
  'depthAnalysisValue',
  'multiPvAnalysisValue',
  'stockfishCommand',
  'rawUci',
  'pvDump',
};
const _capturedAndroidProofIds = <String>{
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
};
const _phase32ECaseIds = <String>{
  'king-safety-mating-net-pressure-32e',
  'endgame-precision-candidate-spread-32e',
  'budget-pressure-wide-candidate-32e',
  'pv-multipv-support-boundary-32e',
};
const _productFields = <String>{
  'productLabel',
  'brilliantGreatMiss',
  'bestGoodInaccuracyMistakeBlunder',
};
const _finalLabelFields = <String>{'finalMoveLabel'};
const _classifierFields = <String>{
  'classifierLabels',
  'brilliantGreatMiss',
  'bestGoodInaccuracyMistakeBlunder',
};
const _scoreFields = <String>{'numericMoveScore', 'aggregateScore'};
const _rankingMetricFields = <String>{
  'moveRanking',
  'officialMetric',
  'accuracy',
  'acpl',
};

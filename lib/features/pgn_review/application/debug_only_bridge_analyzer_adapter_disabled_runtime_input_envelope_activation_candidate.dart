import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_envelope_activation_preflight.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_envelope_activation_preflight_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope_diagnostic.dart';

const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateVersion =
    'debug-only-bridge-analyzer-adapter-disabled-runtime-input-envelope-activation-candidate-v1';

enum DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateStatus {
  disabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateReadyWithWarnings(
    'disabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateReadyWithWarnings',
  ),
  disabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateReadyClean(
    'disabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateReadyClean',
  ),
  blockedByUnsafeActivationPreflightDiagnostic(
    'blockedByUnsafeActivationPreflightDiagnostic',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidDisabledRuntimeInputEnvelopeActivationCandidate(
    'invalidDisabledRuntimeInputEnvelopeActivationCandidate',
  );

  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateStatus(
    this.wire,
  );

  final String wire;
}

class DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateInput {
  const DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateInput({
    required this.activationCandidateId,
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
    required this.candidateRecordIds,
    required this.boundaryIds,
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
    required this.activationCandidateCreated,
    required this.activationCandidateDisabled,
    required this.activationCandidateApproved,
    required this.activationCandidatePromoted,
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

  final String activationCandidateId;
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
  final List<String> candidateRecordIds;
  final List<String> boundaryIds;
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
  final bool activationCandidateCreated;
  final bool activationCandidateDisabled;
  final bool activationCandidateApproved;
  final bool activationCandidatePromoted;
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

  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateInput copyWith({
    String? activationCandidateId,
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
    List<String>? candidateRecordIds,
    List<String>? boundaryIds,
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
    bool? activationCandidateCreated,
    bool? activationCandidateDisabled,
    bool? activationCandidateApproved,
    bool? activationCandidatePromoted,
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
    return DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateInput(
      activationCandidateId:
          activationCandidateId ?? this.activationCandidateId,
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
      candidateRecordIds: candidateRecordIds ?? this.candidateRecordIds,
      boundaryIds: boundaryIds ?? this.boundaryIds,
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
      activationCandidateCreated:
          activationCandidateCreated ?? this.activationCandidateCreated,
      activationCandidateDisabled:
          activationCandidateDisabled ?? this.activationCandidateDisabled,
      activationCandidateApproved:
          activationCandidateApproved ?? this.activationCandidateApproved,
      activationCandidatePromoted:
          activationCandidatePromoted ?? this.activationCandidatePromoted,
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
      'activationCandidateId': activationCandidateId,
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
      'candidateRecordIds': candidateRecordIds,
      'boundaryIds': boundaryIds,
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
      'activationCandidateCreated': activationCandidateCreated,
      'activationCandidateDisabled': activationCandidateDisabled,
      'activationCandidateApproved': activationCandidateApproved,
      'activationCandidatePromoted': activationCandidatePromoted,
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

class DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateRecord {
  const DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateRecord({
    required this.recordId,
    required this.recordRole,
    required this.recordStatus,
    required this.metadataOnly,
    required this.disabled,
    required this.blocked,
    required this.deniedFieldIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.recommendation,
  });

  final String recordId;
  final String recordRole;
  final String recordStatus;
  final bool metadataOnly;
  final bool disabled;
  final bool blocked;
  final List<String> deniedFieldIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final String recommendation;

  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateRecord
  copyWith({
    String? recordId,
    String? recordRole,
    String? recordStatus,
    bool? metadataOnly,
    bool? disabled,
    bool? blocked,
    List<String>? deniedFieldIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    String? recommendation,
  }) {
    return DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateRecord(
      recordId: recordId ?? this.recordId,
      recordRole: recordRole ?? this.recordRole,
      recordStatus: recordStatus ?? this.recordStatus,
      metadataOnly: metadataOnly ?? this.metadataOnly,
      disabled: disabled ?? this.disabled,
      blocked: blocked ?? this.blocked,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'recordId': recordId,
      'recordRole': recordRole,
      'recordStatus': recordStatus,
      'metadataOnly': metadataOnly,
      'disabled': disabled,
      'blocked': blocked,
      'deniedFieldIds': deniedFieldIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'recommendation': recommendation,
    };
  }
}

class DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidatePolicy {
  const DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidatePolicy({
    required this.policyId,
    required this.envelopeDisabled,
    required this.activationCandidateDisabled,
    required this.activationCandidateApprovalAllowed,
    required this.activationCandidatePromotionAllowed,
    required this.activationAllowed,
    required this.activationPerformed,
    required this.activeRuntimeInputEnvelopeAllowed,
    required this.playablePayloadCount,
    required this.analyzerRuntimeInputApproved,
    required this.analyzerRuntimeInputProduced,
    required this.runtimeExecutionApproved,
    required this.executionAllowed,
    required this.executionPerformed,
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

  factory DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidatePolicy.disabled({
    required List<String> deniedFieldIds,
  }) {
    return DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidatePolicy(
      policyId: 'disabled-runtime-input-envelope-activation-candidate-policy',
      envelopeDisabled: true,
      activationCandidateDisabled: true,
      activationCandidateApprovalAllowed: false,
      activationCandidatePromotionAllowed: false,
      activationAllowed: false,
      activationPerformed: false,
      activeRuntimeInputEnvelopeAllowed: false,
      playablePayloadCount: 0,
      analyzerRuntimeInputApproved: false,
      analyzerRuntimeInputProduced: false,
      runtimeExecutionApproved: false,
      executionAllowed: false,
      executionPerformed: false,
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
      recommendation: _phase34VRecommendation,
    );
  }

  final String policyId;
  final bool envelopeDisabled;
  final bool activationCandidateDisabled;
  final bool activationCandidateApprovalAllowed;
  final bool activationCandidatePromotionAllowed;
  final bool activationAllowed;
  final bool activationPerformed;
  final bool activeRuntimeInputEnvelopeAllowed;
  final int playablePayloadCount;
  final bool analyzerRuntimeInputApproved;
  final bool analyzerRuntimeInputProduced;
  final bool runtimeExecutionApproved;
  final bool executionAllowed;
  final bool executionPerformed;
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

  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidatePolicy
  copyWith({
    String? policyId,
    bool? envelopeDisabled,
    bool? activationCandidateDisabled,
    bool? activationCandidateApprovalAllowed,
    bool? activationCandidatePromotionAllowed,
    bool? activationAllowed,
    bool? activationPerformed,
    bool? activeRuntimeInputEnvelopeAllowed,
    int? playablePayloadCount,
    bool? analyzerRuntimeInputApproved,
    bool? analyzerRuntimeInputProduced,
    bool? runtimeExecutionApproved,
    bool? executionAllowed,
    bool? executionPerformed,
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
    return DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidatePolicy(
      policyId: policyId ?? this.policyId,
      envelopeDisabled: envelopeDisabled ?? this.envelopeDisabled,
      activationCandidateDisabled:
          activationCandidateDisabled ?? this.activationCandidateDisabled,
      activationCandidateApprovalAllowed:
          activationCandidateApprovalAllowed ??
          this.activationCandidateApprovalAllowed,
      activationCandidatePromotionAllowed:
          activationCandidatePromotionAllowed ??
          this.activationCandidatePromotionAllowed,
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
      executionAllowed: executionAllowed ?? this.executionAllowed,
      executionPerformed: executionPerformed ?? this.executionPerformed,
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
      'activationCandidateDisabled': activationCandidateDisabled,
      'activationCandidateApprovalAllowed': activationCandidateApprovalAllowed,
      'activationCandidatePromotionAllowed':
          activationCandidatePromotionAllowed,
      'activationAllowed': activationAllowed,
      'activationPerformed': activationPerformed,
      'activeRuntimeInputEnvelopeAllowed': activeRuntimeInputEnvelopeAllowed,
      'playablePayloadCount': playablePayloadCount,
      'analyzerRuntimeInputApproved': analyzerRuntimeInputApproved,
      'analyzerRuntimeInputProduced': analyzerRuntimeInputProduced,
      'runtimeExecutionApproved': runtimeExecutionApproved,
      'executionAllowed': executionAllowed,
      'executionPerformed': executionPerformed,
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

class DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBoundary {
  const DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBoundary({
    required this.boundaryId,
    required this.boundarySurface,
    required this.blocked,
    required this.deniedFieldIds,
    required this.recommendation,
  });

  final String boundaryId;
  final String boundarySurface;
  final bool blocked;
  final List<String> deniedFieldIds;
  final String recommendation;

  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBoundary
  copyWith({
    String? boundaryId,
    String? boundarySurface,
    bool? blocked,
    List<String>? deniedFieldIds,
    String? recommendation,
  }) {
    return DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBoundary(
      boundaryId: boundaryId ?? this.boundaryId,
      boundarySurface: boundarySurface ?? this.boundarySurface,
      blocked: blocked ?? this.blocked,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'boundaryId': boundaryId,
      'boundarySurface': boundarySurface,
      'blocked': blocked,
      'deniedFieldIds': deniedFieldIds,
      'recommendation': recommendation,
    };
  }
}

class DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBlockedReason {
  const DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBlockedReason({
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

  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBlockedReason
  copyWith({
    String? blockedReasonId,
    String? blockedSurface,
    bool? blocked,
    String? reason,
    List<String>? deniedFieldIds,
    String? recommendation,
  }) {
    return DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBlockedReason(
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

class DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateResult {
  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateResult({
    required this.status,
    required this.sourceActivationPreflightDiagnosticStatus,
    required this.sourceActivationPreflightStatus,
    required this.sourceDisabledRuntimeInputEnvelopeDiagnosticStatus,
    required this.sourceDisabledRuntimeInputEnvelopeStatus,
    required this.input,
    required this.records,
    required this.policy,
    required this.boundaries,
    required this.blockedReasons,
    required this.findings,
    required this.safeForPhase34V,
    required this.nextRecommendation,
  }) : candidateRecordCount = records.length,
       boundaryCount = boundaries.length,
       blockedReasonCount = blockedReasons.length,
       deniedFieldCount = policy.deniedFieldIds.length,
       disabledEnvelopeCount = input.envelopeCreated && input.envelopeDisabled
           ? 1
           : 0,
       activationPreflightCount = input.activationPreflightCreated ? 1 : 0,
       activationCandidateCount = input.activationCandidateCreated ? 1 : 0,
       activationCandidateApprovedCount = input.activationCandidateApproved
           ? 1
           : 0,
       activationCandidatePromotedCount = input.activationCandidatePromoted
           ? 1
           : 0,
       activationApprovedCount = input.activationApproved ? 1 : 0,
       activationPerformedCount = input.activationPerformed ? 1 : 0,
       activeRuntimeInputEnvelopeCount = input.activeRuntimeInputEnvelope
           ? 1
           : 0,
       playablePayloadCount =
           input.playablePayloadCount +
           _countActiveFields(input.deniedFieldIds, _payloadFields),
       analyzerRuntimeInputApprovedCount = input.analyzerRuntimeInputApproved
           ? 1
           : 0,
       analyzerRuntimeInputProducedCount = input.analyzerRuntimeInputProduced
           ? 1
           : 0,
       runtimeExecutionApprovedCount = input.runtimeExecutionApproved ? 1 : 0,
       runtimeExecutionCount =
           input.executionAllowed || input.executionPerformed ? 1 : 0,
       analyzerWiringCount = input.analyzerWiringAllowed ? 1 : 0,
       executableRuntimeCount = _countActiveFields(input.deniedFieldIds, const {
         'executableRuntime',
         'runtimeExecutionResult',
       }),
       engineCallCount = input.engineCallsAllowed ? 1 : 0,
       schedulerExecutionCount = input.schedulerAllowed ? 1 : 0,
       persistenceWriteCount = input.persistenceAllowed ? 1 : 0,
       productOutputCount =
           (input.productOutputAllowed ? 1 : 0) +
           _countActiveFields(input.deniedFieldIds, _productFields),
       productAdapterCount = input.productAdapterAllowed ? 1 : 0,
       savedAnalysisIntegrationCount = input.savedAnalysisAllowed ? 1 : 0,
       activeDeniedFieldCount = _activeDeniedFieldIds(
         input.deniedFieldIds,
       ).length,
       phase32EProofClaimCount =
           input.androidProofIds.any(_phase32ECaseIds.contains) ? 1 : 0,
       unprovenAndroidProofCount = input.androidProofIds
           .where((id) => !_capturedAndroidProofIds.contains(id))
           .length,
       ownerProofQueueCount = input.ownerProofRequired ? 1 : 0 {
    unsafeCount = hasUnsafePolicyViolation ? 1 : 0;
    blockerCount = hasUnsafePolicyViolation ? 1 : 0;
    criticalCount = 0;
  }

  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateStatus
  status;
  final String sourceActivationPreflightDiagnosticStatus;
  final String sourceActivationPreflightStatus;
  final String sourceDisabledRuntimeInputEnvelopeDiagnosticStatus;
  final String sourceDisabledRuntimeInputEnvelopeStatus;
  final DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateInput
  input;
  final List<
    DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateRecord
  >
  records;
  final DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidatePolicy
  policy;
  final List<
    DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBoundary
  >
  boundaries;
  final List<
    DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBlockedReason
  >
  blockedReasons;
  final List<String> findings;
  final bool safeForPhase34V;
  final String nextRecommendation;
  final int candidateRecordCount;
  final int boundaryCount;
  final int blockedReasonCount;
  final int deniedFieldCount;
  final int disabledEnvelopeCount;
  final int activationPreflightCount;
  final int activationCandidateCount;
  final int activationCandidateApprovedCount;
  final int activationCandidatePromotedCount;
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
  final int activeDeniedFieldCount;
  final int phase32EProofClaimCount;
  final int unprovenAndroidProofCount;
  final int ownerProofQueueCount;
  late final int unsafeCount;
  late final int blockerCount;
  late final int criticalCount;

  bool get hasUnsafePolicyViolation =>
      !safeForPhase34V ||
      findings.isNotEmpty ||
      disabledEnvelopeCount < 1 ||
      activationPreflightCount < 1 ||
      activationCandidateCount < 1 ||
      activationCandidateApprovedCount > 0 ||
      activationCandidatePromotedCount > 0 ||
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
      activeDeniedFieldCount > 0 ||
      phase32EProofClaimCount > 0 ||
      unprovenAndroidProofCount > 0 ||
      ownerProofQueueCount > 0 ||
      nextRecommendation != _phase34VRecommendation;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln(
        '# Disabled Analyzer Adapter Runtime Input Envelope Activation Candidate',
      )
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateVersion',
      )
      ..writeln('- status: ${status.wire}')
      ..writeln('- safe for Phase 34V: $safeForPhase34V')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- disabled envelope count: $disabledEnvelopeCount')
      ..writeln('- activation preflight count: $activationPreflightCount')
      ..writeln('- activation candidate count: $activationCandidateCount')
      ..writeln(
        '- activation candidate approved count: $activationCandidateApprovedCount',
      )
      ..writeln(
        '- activation candidate promoted count: $activationCandidatePromotedCount',
      )
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
      ..writeln('## Source Chain')
      ..writeln(
        '- activation preflight diagnostic: $sourceActivationPreflightDiagnosticStatus',
      )
      ..writeln('- activation preflight: $sourceActivationPreflightStatus')
      ..writeln(
        '- disabled runtime input envelope diagnostic: $sourceDisabledRuntimeInputEnvelopeDiagnosticStatus',
      )
      ..writeln(
        '- disabled runtime input envelope: $sourceDisabledRuntimeInputEnvelopeStatus',
      )
      ..writeln()
      ..writeln('## Candidate Records')
      ..writeln('| Record | Role | Metadata only | Disabled | Blocked |')
      ..writeln('| --- | --- | --- | --- | --- |');
    for (final record in records) {
      buffer.writeln(
        '| ${record.recordId} | ${record.recordRole} | ${record.metadataOnly} | ${record.disabled} | ${record.blocked} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Boundaries')
      ..writeln('| Boundary | Blocked | Denied fields |')
      ..writeln('| --- | --- | --- |');
    for (final boundary in boundaries) {
      buffer.writeln(
        '| ${boundary.boundaryId} | ${boundary.blocked} | ${_ids(boundary.deniedFieldIds)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Blocked Reasons')
      ..writeln('| Reason | Blocked | Denied fields |')
      ..writeln('| --- | --- | --- |');
    for (final reason in blockedReasons) {
      buffer.writeln(
        '| ${reason.blockedReasonId} | ${reason.blocked} | ${_ids(reason.deniedFieldIds)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Proof Boundary')
      ..writeln('- android proof IDs: ${_ids(input.androidProofIds)}')
      ..writeln('- owner proof required: ${input.ownerProofRequired}')
      ..writeln('- proof limit reasons: ${_ids(input.proofLimitReasons)}')
      ..writeln()
      ..writeln('## Denied Fields')
      ..writeln('- denied field count: $deniedFieldCount')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- denied field IDs: ${_ids(policy.deniedFieldIds)}')
      ..writeln()
      ..writeln('## Findings')
      ..writeln('- findings: ${_ids(findings)}');
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent(' ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateVersion,
      'status': status.wire,
      'sourceActivationPreflightDiagnosticStatus':
          sourceActivationPreflightDiagnosticStatus,
      'sourceActivationPreflightStatus': sourceActivationPreflightStatus,
      'sourceDisabledRuntimeInputEnvelopeDiagnosticStatus':
          sourceDisabledRuntimeInputEnvelopeDiagnosticStatus,
      'sourceDisabledRuntimeInputEnvelopeStatus':
          sourceDisabledRuntimeInputEnvelopeStatus,
      'safeForPhase34V': safeForPhase34V,
      'nextRecommendation': nextRecommendation,
      'counts': <String, Object?>{
        'unsafeCount': unsafeCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'candidateRecordCount': candidateRecordCount,
        'boundaryCount': boundaryCount,
        'blockedReasonCount': blockedReasonCount,
        'deniedFieldCount': deniedFieldCount,
        'disabledEnvelopeCount': disabledEnvelopeCount,
        'activationPreflightCount': activationPreflightCount,
        'activationCandidateCount': activationCandidateCount,
        'activationCandidateApprovedCount': activationCandidateApprovedCount,
        'activationCandidatePromotedCount': activationCandidatePromotedCount,
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
      'records': records.map((record) => record.toJson()).toList(),
      'policy': policy.toJson(),
      'boundaries': boundaries.map((boundary) => boundary.toJson()).toList(),
      'blockedReasons': blockedReasons
          .map((reason) => reason.toJson())
          .toList(),
      'findings': findings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidate {
  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidate();

  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateResult
  evaluate({
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticResult?
    activationPreflightDiagnosticResult,
    ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult?
    activationPreflightResult,
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeDiagnosticResult?
    disabledRuntimeInputEnvelopeDiagnosticResult,
    DisabledAnalyzerAdapterRuntimeInputEnvelopeResult?
    disabledRuntimeInputEnvelopeResult,
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticResult?
    runtimeInputPreflightDiagnosticResult,
    DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateInput?
    inputOverride,
    DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidatePolicy?
    policyOverride,
    List<DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateRecord>?
    recordsOverride,
    List<
      DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBoundary
    >?
    boundariesOverride,
    List<
      DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBlockedReason
    >?
    blockedReasonsOverride,
  }) {
    final preflight =
        activationPreflightResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflight()
            .evaluate(
              disabledRuntimeInputEnvelopeDiagnosticResult:
                  disabledRuntimeInputEnvelopeDiagnosticResult,
              disabledRuntimeInputEnvelopeResult:
                  disabledRuntimeInputEnvelopeResult,
              runtimeInputPreflightDiagnosticResult:
                  runtimeInputPreflightDiagnosticResult,
            );
    final diagnostic =
        activationPreflightDiagnosticResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnostic()
            .evaluate(
              activationPreflightResult: preflight,
              disabledRuntimeInputEnvelopeDiagnosticResult:
                  disabledRuntimeInputEnvelopeDiagnosticResult,
              disabledRuntimeInputEnvelopeResult:
                  disabledRuntimeInputEnvelopeResult,
              runtimeInputPreflightDiagnosticResult:
                  runtimeInputPreflightDiagnosticResult,
            );
    final policy =
        policyOverride ??
        DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidatePolicy.disabled(
          deniedFieldIds: preflight.policy.deniedFieldIds,
        );
    final records = recordsOverride ?? _recordsFor(policy.deniedFieldIds);
    final boundaries = boundariesOverride ?? _boundariesFor();
    final blockedReasons = blockedReasonsOverride ?? _blockedReasonsFor();
    final input =
        inputOverride ??
        DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateInput(
          activationCandidateId: _activationCandidateId,
          sourcePhase: 'Phase34T',
          sourceDiagnosticIds: diagnostic.rows
              .map((row) => row.diagnosticRowId)
              .toList(),
          sourceEnvelopeIds: preflight.input.sourceEnvelopeIds,
          sourcePreflightIds: _sorted(<String>[
            preflight.input.activationPreflightId,
            ...preflight.input.sourcePreflightIds,
          ]),
          sourceSeamProbeIds: preflight.input.sourceSeamProbeIds,
          sourceSkeletonIds: preflight.input.sourceSkeletonIds,
          sourcePreparationIds: preflight.input.sourcePreparationIds,
          sourceCaseIds: preflight.input.sourceCaseIds,
          sourceActionIds: preflight.input.sourceActionIds,
          sourcePatchIds: preflight.input.sourcePatchIds,
          sourceRefinementIds: preflight.input.sourceRefinementIds,
          candidateRecordIds: records.map((record) => record.recordId).toList(),
          boundaryIds: boundaries
              .map((boundary) => boundary.boundaryId)
              .toList(),
          blockedReasonIds: blockedReasons
              .map((reason) => reason.blockedReasonId)
              .toList(),
          deniedFieldIds: policy.deniedFieldIds,
          supportAreaIds: preflight.input.supportAreaIds,
          warningReasons: _sorted(<String>[
            ...preflight.input.warningReasons,
            'disabledActivationCandidateCreatedAsMetadataOnly',
          ]),
          proofLimitReasons: preflight.input.proofLimitReasons,
          androidProofIds: preflight.input.androidProofIds,
          ownerProofRequired: preflight.input.ownerProofRequired,
          envelopeCreated: preflight.input.envelopeCreated,
          envelopeDisabled: true,
          activationPreflightCreated:
              preflight.input.activationPreflightCreated,
          activationCandidateCreated: true,
          activationCandidateDisabled: true,
          activationCandidateApproved: false,
          activationCandidatePromoted: false,
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
          recommendation: _phase34VRecommendation,
        );
    final findings = _sorted(<String>[
      if (diagnostic.hasUnsafePolicyViolation || !diagnostic.safeForPhase34U)
        'unsafePhase34TActivationPreflightDiagnostic',
      if (preflight.hasUnsafePolicyViolation || !preflight.safeForPhase34T)
        'unsafePhase34SActivationPreflight',
      if (disabledRuntimeInputEnvelopeDiagnosticResult != null &&
          (disabledRuntimeInputEnvelopeDiagnosticResult
                  .hasUnsafePolicyViolation ||
              !disabledRuntimeInputEnvelopeDiagnosticResult.safeForPhase34S))
        'unsafePhase34RDisabledRuntimeInputEnvelopeDiagnostic',
      if (disabledRuntimeInputEnvelopeResult != null &&
          (disabledRuntimeInputEnvelopeResult.hasUnsafePolicyViolation ||
              !disabledRuntimeInputEnvelopeResult.safeForPhase34R))
        'unsafePhase34QDisabledRuntimeInputEnvelope',
      if (runtimeInputPreflightDiagnosticResult != null &&
          (runtimeInputPreflightDiagnosticResult.hasUnsafePolicyViolation ||
              !runtimeInputPreflightDiagnosticResult.safeForPhase34Q))
        'unsafePhase34PRuntimeInputPreflightDiagnostic',
      ...const DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateValidator()
          .validateCandidate(
            input: input,
            records: records,
            policy: policy,
            boundaries: boundaries,
            blockedReasons: blockedReasons,
          ),
    ]);
    final safeForPhase34V = findings.isEmpty;
    return DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateResult(
      status: !safeForPhase34V
          ? DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateStatus
                .blockedByPolicyBoundary
          : input.warningReasons.isNotEmpty ||
                records.any((r) => r.warningReasons.isNotEmpty)
          ? DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateStatus
                .disabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateReadyWithWarnings
          : DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateStatus
                .disabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateReadyClean,
      sourceActivationPreflightDiagnosticStatus: diagnostic.status.wire,
      sourceActivationPreflightStatus: preflight.status.wire,
      sourceDisabledRuntimeInputEnvelopeDiagnosticStatus:
          preflight.sourceDisabledRuntimeInputEnvelopeDiagnosticStatus,
      sourceDisabledRuntimeInputEnvelopeStatus:
          preflight.sourceDisabledRuntimeInputEnvelopeStatus,
      input: input,
      records: records,
      policy: policy,
      boundaries: boundaries,
      blockedReasons: blockedReasons,
      findings: findings,
      safeForPhase34V: safeForPhase34V,
      nextRecommendation: safeForPhase34V
          ? _phase34VRecommendation
          : 'blockedByUnsafeRuntimeInputEnvelopeActivationCandidate',
    );
  }

  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateResult
  buildDisabledActivationCandidate() {
    return evaluate();
  }

  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateRecord
  createDisabledActivationCandidateRecord(String recordId) {
    return _recordFor(recordId, const <String>[]);
  }

  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBlockedReason
  blockActivationCandidatePromotion() {
    return _blockedReasonFor('activationCandidatePromotionBlocked');
  }

  String renderDisabledActivationCandidateSnapshot(
    DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateResult result,
  ) {
    return result.renderMarkdown();
  }

  List<String> validateDisabledActivationCandidate(
    DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateResult result,
  ) {
    return const DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateValidator()
        .validateResult(result);
  }
}

class DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateValidator {
  const DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateValidator();

  List<String> validateResult(
    DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateResult result,
  ) {
    return validateCandidate(
      input: result.input,
      records: result.records,
      policy: result.policy,
      boundaries: result.boundaries,
      blockedReasons: result.blockedReasons,
    );
  }

  List<String> validateCandidate({
    required DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateInput
    input,
    required Iterable<
      DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateRecord
    >
    records,
    required DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidatePolicy
    policy,
    required Iterable<
      DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBoundary
    >
    boundaries,
    required Iterable<
      DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBlockedReason
    >
    blockedReasons,
  }) {
    return _sorted(<String>[
      ...validateInput(input),
      ...records.expand(validateRecord),
      ...validatePolicy(policy),
      ...boundaries.expand(validateBoundary),
      ...blockedReasons.expand(validateBlockedReason),
    ]);
  }

  List<String> validateInput(
    DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateInput input,
  ) {
    final activeDenied = _activeDeniedFieldIds(input.deniedFieldIds);
    return _sorted(<String>[
      if (input.recommendation != _phase34VRecommendation)
        'missingPhase34VDisabledActivationCandidateDiagnosticRecommendation',
      if (!input.envelopeDisabled) 'runtimeInputEnvelopeNotDisabled',
      if (!input.activationCandidateCreated) 'activationCandidateMissing',
      if (!input.activationCandidateDisabled) 'activationCandidateNotDisabled',
      if (input.activationCandidateApproved) 'activationCandidateApproved',
      if (input.activationCandidatePromoted) 'activationCandidatePromoted',
      if (input.activationApproved) 'activationApprovedEnabled',
      if (input.activationPerformed) 'activationPerformedEnabled',
      if (input.activeRuntimeInputEnvelope) 'activeRuntimeInputEnvelopeEnabled',
      if (input.playablePayloadCount > 0) 'playablePayloadEnabled',
      if (input.analyzerRuntimeInputApproved) 'analyzerRuntimeInputApproved',
      if (input.analyzerRuntimeInputProduced) 'analyzerRuntimeInputProduced',
      if (input.runtimeExecutionApproved) 'runtimeExecutionApprovedEnabled',
      if (input.executionAllowed) 'executionAllowedEnabled',
      if (input.executionPerformed) 'executionPerformedEnabled',
      if (input.analyzerWiringAllowed) 'analyzerWiringEnabled',
      if (input.engineCallsAllowed) 'engineCallsEnabled',
      if (input.schedulerAllowed) 'schedulerExecutionEnabled',
      if (input.persistenceAllowed) 'persistenceWriteEnabled',
      if (input.productOutputAllowed) 'productOutputEnabled',
      if (input.productAdapterAllowed) 'productAdapterEnabled',
      if (input.savedAnalysisAllowed) 'savedAnalysisIntegrationEnabled',
      if (input.candidateRecordIds.any((id) => id.startsWith('active:')))
        'activationCandidateRecordActivated',
      if (input.boundaryIds.any((id) => id.startsWith('active:')))
        'boundaryActivated',
      if (input.blockedReasonIds.any((id) => id.startsWith('active:')))
        'blockedReasonActivated',
      if (activeDenied.isNotEmpty) 'activeDeniedFields',
      ..._deniedFieldFindings(activeDenied),
      if (_isQuietSupport(input.supportAreaIds)) 'quietPreparatoryPromotion',
      if (input.sourceCaseIds.contains(_pvMultiPvBoundaryCaseId) &&
          !input.proofLimitReasons.any(_mentionsPvMultiPv))
        'pvMultiPvPromotion',
      if (input.androidProofIds.any(_phase32ECaseIds.contains))
        'phase32ECapturedProofClaim',
      if (input.androidProofIds.any(
        (id) => !_capturedAndroidProofIds.contains(id),
      ))
        'unprovenAndroidProofClaim',
      if (input.ownerProofRequired &&
          !input.proofLimitReasons.any(_mentionsPvMultiPv))
        'ownerProofWithoutPvMultiPvReason',
    ]);
  }

  List<String> validateRecord(
    DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateRecord record,
  ) {
    final activeDenied = _activeDeniedFieldIds(record.deniedFieldIds);
    return _sorted(<String>[
      if (!_requiredCandidateRecordIds.contains(record.recordId))
        'unknownActivationCandidateRecord',
      if (!record.metadataOnly) 'activationCandidateRecordNotMetadataOnly',
      if (!record.disabled) 'activationCandidateRecordNotDisabled',
      if (!record.blocked) 'activationCandidateRecordUnblocked',
      if (activeDenied.isNotEmpty) 'activeDeniedFields',
      ..._deniedFieldFindings(activeDenied),
      if (record.recommendation != _phase34VRecommendation)
        'missingPhase34VDisabledActivationCandidateDiagnosticRecommendation',
    ]);
  }

  List<String> validatePolicy(
    DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidatePolicy policy,
  ) {
    final activeDenied = _activeDeniedFieldIds(policy.deniedFieldIds);
    return _sorted(<String>[
      if (!policy.envelopeDisabled) 'runtimeInputEnvelopeNotDisabled',
      if (!policy.activationCandidateDisabled) 'activationCandidateNotDisabled',
      if (policy.activationCandidateApprovalAllowed)
        'activationCandidateApprovalEnabled',
      if (policy.activationCandidatePromotionAllowed)
        'activationCandidatePromotionEnabled',
      if (policy.activationAllowed) 'activationApprovedEnabled',
      if (policy.activationPerformed) 'activationPerformedEnabled',
      if (policy.activeRuntimeInputEnvelopeAllowed)
        'activeRuntimeInputEnvelopeEnabled',
      if (policy.playablePayloadCount > 0) 'playablePayloadEnabled',
      if (policy.analyzerRuntimeInputApproved) 'analyzerRuntimeInputApproved',
      if (policy.analyzerRuntimeInputProduced) 'analyzerRuntimeInputProduced',
      if (policy.runtimeExecutionApproved) 'runtimeExecutionApprovedEnabled',
      if (policy.executionAllowed) 'executionAllowedEnabled',
      if (policy.executionPerformed) 'executionPerformedEnabled',
      if (policy.analyzerWiringAllowed) 'analyzerWiringEnabled',
      if (policy.engineCallsAllowed) 'engineCallsEnabled',
      if (policy.schedulerAllowed) 'schedulerExecutionEnabled',
      if (policy.persistenceAllowed) 'persistenceWriteEnabled',
      if (policy.productOutputAllowed) 'productOutputEnabled',
      if (policy.productAdapterAllowed) 'productAdapterEnabled',
      if (policy.savedAnalysisAllowed) 'savedAnalysisIntegrationEnabled',
      if (policy.uiAllowed || policy.backendAllowed) 'uiBackendActivation',
      if (policy.cacheAllowed || policy.databaseAllowed)
        'cacheDatabaseWriteEnabled',
      if (activeDenied.isNotEmpty) 'activeDeniedFields',
      ..._deniedFieldFindings(activeDenied),
      if (policy.recommendation != _phase34VRecommendation)
        'missingPhase34VDisabledActivationCandidateDiagnosticRecommendation',
    ]);
  }

  List<String> validateBoundary(
    DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBoundary
    boundary,
  ) {
    final activeDenied = _activeDeniedFieldIds(boundary.deniedFieldIds);
    return _sorted(<String>[
      if (!_requiredBoundaryIds.contains(boundary.boundaryId))
        'unknownActivationCandidateBoundary',
      if (!boundary.blocked) 'activationCandidateBoundaryUnblocked',
      if (activeDenied.isNotEmpty) 'activeDeniedFields',
      ..._deniedFieldFindings(activeDenied),
      if (boundary.recommendation != _phase34VRecommendation)
        'missingPhase34VDisabledActivationCandidateDiagnosticRecommendation',
    ]);
  }

  List<String> validateBlockedReason(
    DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBlockedReason
    reason,
  ) {
    final activeDenied = _activeDeniedFieldIds(reason.deniedFieldIds);
    return _sorted(<String>[
      if (!_requiredBlockedReasonIds.contains(reason.blockedReasonId))
        'unknownActivationCandidateBlockedReason',
      if (!reason.blocked) 'blockedReasonActivated',
      if (activeDenied.isNotEmpty) 'activeDeniedFields',
      ..._deniedFieldFindings(activeDenied),
      if (reason.recommendation != _phase34VRecommendation)
        'missingPhase34VDisabledActivationCandidateDiagnosticRecommendation',
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
      if (lower.contains('activationcandidateapproved: true'))
        'reportTextLeak:activationCandidateApproved',
      if (lower.contains('activationcandidatepromoted: true'))
        'reportTextLeak:activationCandidatePromoted',
      if (lower.contains('activationapproved: true'))
        'reportTextLeak:activationApproved',
      if (lower.contains('activationperformed: true'))
        'reportTextLeak:activationPerformed',
      if (lower.contains('activeruntimeinputenvelope: true'))
        'reportTextLeak:activeRuntimeInputEnvelope',
      if (lower.contains('analyzerruntimeinputapproved: true'))
        'reportTextLeak:analyzerRuntimeInputApproved',
      if (lower.contains('analyzerruntimeinputproduced: true'))
        'reportTextLeak:analyzerRuntimeInputProduced',
      if (lower.contains('runtimeexecutionapproved: true'))
        'reportTextLeak:runtimeExecutionApproved',
      if (lower.contains('backend://') ||
          lower.contains('http://secret') ||
          lower.contains('https://secret'))
        'reportTextLeak:backendSecret',
    ]);
  }
}

List<DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateRecord>
_recordsFor(List<String> deniedFieldIds) {
  return _requiredCandidateRecordIds
      .map((id) => _recordFor(id, _deniedFieldsForSurface(id, deniedFieldIds)))
      .toList(growable: false);
}

DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateRecord _recordFor(
  String id,
  List<String> deniedFieldIds,
) {
  return DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateRecord(
    recordId: id,
    recordRole: id,
    recordStatus: 'disabledActivationCandidateMetadataOnly',
    metadataOnly: true,
    disabled: true,
    blocked: true,
    deniedFieldIds: deniedFieldIds,
    warningReasons: const <String>[
      'activationCandidateIsDeveloperOnlyAndNonConsumable',
    ],
    proofLimitReasons: id == 'proofBoundaryRecord'
        ? const <String>['pvMultiPvRemainsProofBoundaryWatchListOnly']
        : const <String>[],
    recommendation: _phase34VRecommendation,
  );
}

List<DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBoundary>
_boundariesFor() {
  return _requiredBoundaryIds
      .map(
        (id) =>
            DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBoundary(
              boundaryId: id,
              boundarySurface: id,
              blocked: true,
              deniedFieldIds: _deniedFieldsForSurface(id, _deniedFieldIds),
              recommendation: _phase34VRecommendation,
            ),
      )
      .toList(growable: false);
}

List<
  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBlockedReason
>
_blockedReasonsFor() {
  return _requiredBlockedReasonIds
      .map(_blockedReasonFor)
      .toList(growable: false);
}

DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBlockedReason
_blockedReasonFor(String id) {
  return DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateBlockedReason(
    blockedReasonId: id,
    blockedSurface: id,
    blocked: true,
    reason: 'disabled activation candidate keeps $id blocked',
    deniedFieldIds: _deniedFieldsForSurface(id, _deniedFieldIds),
    recommendation: _phase34VRecommendation,
  );
}

List<String> _deniedFieldsForSurface(
  String id,
  Iterable<String> fallbackDeniedFields,
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
  if (lower.contains('activationcandidateapproval')) {
    return const <String>['activationCandidateApproval'];
  }
  if (lower.contains('activationcandidatepromotion')) {
    return const <String>['activationCandidatePromotion'];
  }
  if (lower.contains('activation') ||
      lower.contains('activeruntimeinputenvelope')) {
    return const <String>['activeRuntimeInputEnvelope'];
  }
  if (lower.contains('analyzerruntimeinput')) {
    return const <String>[
      'analyzerRuntimeInput',
      'analyzerRuntimeInputApproval',
      'analyzerRuntimeInputProduction',
    ];
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
  final values = fallbackDeniedFields.toSet();
  return values.isEmpty ? const <String>[] : _sorted(values);
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
      'analyzerRuntimeInputApprovalEnabled',
    if (activeDenied.contains('analyzerRuntimeInputProduction'))
      'analyzerRuntimeInputProductionEnabled',
    if (activeDenied.contains('activationCandidateApproval'))
      'activationCandidateApprovalEnabled',
    if (activeDenied.contains('activationCandidatePromotion'))
      'activationCandidatePromotionEnabled',
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

int _countActiveFields(Iterable<String> ids, Set<String> fieldIds) {
  return _activeDeniedFieldIds(ids).where(fieldIds.contains).length;
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

const _activationCandidateId =
    'disabled-analyzer-adapter-runtime-input-envelope-activation-candidate';
const _phase34VRecommendation =
    'runDisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateDiagnostic';
const _pvMultiPvBoundaryCaseId = 'pv-multipv-support-boundary-32e';

const _requiredCandidateRecordIds = <String>{
  'disabledActivationCandidateRecord',
  'sourceEnvelopeReferenceRecord',
  'activationPreflightReferenceRecord',
  'activationPreflightDiagnosticReferenceRecord',
  'blockedPlayablePayloadRecord',
  'blockedAnalyzerRuntimeInputRecord',
  'blockedRuntimeExecutionRecord',
  'blockedAnalyzerWiringRecord',
  'blockedEngineRecord',
  'blockedSchedulerRecord',
  'blockedPersistenceRecord',
  'blockedProductAdapterRecord',
  'blockedSavedAnalysisRecord',
  'proofBoundaryRecord',
  'deniedFieldRecord',
  'recommendationRecord',
};

const _requiredBoundaryIds = <String>{
  'disabledActivationCandidateBoundary',
  'activationApprovalBoundary',
  'activationPromotionBoundary',
  'activeRuntimeInputEnvelopeBoundary',
  'playablePayloadBoundary',
  'analyzerRuntimeInputBoundary',
  'analyzerRuntimeInputApprovalBoundary',
  'runtimeExecutionBoundary',
  'analyzerWiringBoundary',
  'engineCallBoundary',
  'stockfishBridgeBoundary',
  'androidCollectorBoundary',
  'schedulerExecutionBoundary',
  'persistenceWriteBoundary',
  'productOutputBoundary',
  'productAdapterBoundary',
  'savedAnalysisBoundary',
  'uiBoundary',
  'backendBoundary',
  'cacheBoundary',
  'databaseBoundary',
};

const _requiredBlockedReasonIds = <String>{
  'activationCandidateDisabledByPolicy',
  'activationCandidateApprovalBlocked',
  'activationCandidatePromotionBlocked',
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

const _deniedFieldIds = <String>{
  'productLabel',
  'finalMoveLabel',
  'classifierLabels',
  'brilliantGreatMiss',
  'bestGoodInaccuracyMistakeBlunder',
  'numericMoveScore',
  'aggregateScore',
  'officialMetric',
  'accuracy',
  'acpl',
  'cpLoss',
  'winProbability',
  'moveRanking',
  'thresholds',
  'stockfishCommand',
  'rawUci',
  'pvDump',
  'androidCollectorRequirement',
  'playableFenPayload',
  'pgnPayload',
  'moveListPayload',
  'uciMovePayload',
  'engineOptionPayload',
  'depthAnalysisValue',
  'multiPvAnalysisValue',
  'activationCandidateApproval',
  'activationCandidatePromotion',
  'analyzerRuntimeInput',
  'analyzerRuntimeInputApproval',
  'analyzerRuntimeInputProduction',
  'activeRuntimeInputEnvelope',
  'runtimeExecutionResult',
  'analyzerResult',
  'engineResult',
  'schedulerExecutionResult',
  'cacheDatabaseWrite',
  'productAdapterBehavior',
  'savedAnalysisIntegration',
  'uiState',
  'backendResponse',
  'readinessSummaryChain',
  'readinessGate',
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

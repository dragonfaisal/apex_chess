import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe_diagnostic.dart';

const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeVersion =
    'debug-only-bridge-analyzer-adapter-disabled-runtime-input-envelope-v1';

enum DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeStatus {
  disabledAnalyzerAdapterRuntimeInputEnvelopeReadyWithWarnings(
    'disabledAnalyzerAdapterRuntimeInputEnvelopeReadyWithWarnings',
  ),
  disabledAnalyzerAdapterRuntimeInputEnvelopeReadyClean(
    'disabledAnalyzerAdapterRuntimeInputEnvelopeReadyClean',
  ),
  blockedByUnsafeRuntimeInputPreflightDiagnostic(
    'blockedByUnsafeRuntimeInputPreflightDiagnostic',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidDisabledRuntimeInputEnvelope('invalidDisabledRuntimeInputEnvelope');

  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeStatus(
    this.wire,
  );

  final String wire;
}

class DisabledAnalyzerAdapterRuntimeInputEnvelopeInput {
  const DisabledAnalyzerAdapterRuntimeInputEnvelopeInput({
    required this.envelopeId,
    required this.sourcePhase,
    required this.sourceDiagnosticIds,
    required this.sourcePreflightIds,
    required this.sourceSeamProbeIds,
    required this.sourceSkeletonIds,
    required this.sourcePreparationIds,
    required this.sourceCaseIds,
    required this.sourceActionIds,
    required this.sourcePatchIds,
    required this.sourceRefinementIds,
    required this.slotIds,
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
    required this.activeRuntimeInputEnvelope,
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

  final String envelopeId;
  final String sourcePhase;
  final List<String> sourceDiagnosticIds;
  final List<String> sourcePreflightIds;
  final List<String> sourceSeamProbeIds;
  final List<String> sourceSkeletonIds;
  final List<String> sourcePreparationIds;
  final List<String> sourceCaseIds;
  final List<String> sourceActionIds;
  final List<String> sourcePatchIds;
  final List<String> sourceRefinementIds;
  final List<String> slotIds;
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
  final bool activeRuntimeInputEnvelope;
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

  DisabledAnalyzerAdapterRuntimeInputEnvelopeInput copyWith({
    String? envelopeId,
    String? sourcePhase,
    List<String>? sourceDiagnosticIds,
    List<String>? sourcePreflightIds,
    List<String>? sourceSeamProbeIds,
    List<String>? sourceSkeletonIds,
    List<String>? sourcePreparationIds,
    List<String>? sourceCaseIds,
    List<String>? sourceActionIds,
    List<String>? sourcePatchIds,
    List<String>? sourceRefinementIds,
    List<String>? slotIds,
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
    bool? activeRuntimeInputEnvelope,
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
    return DisabledAnalyzerAdapterRuntimeInputEnvelopeInput(
      envelopeId: envelopeId ?? this.envelopeId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      sourceDiagnosticIds: sourceDiagnosticIds ?? this.sourceDiagnosticIds,
      sourcePreflightIds: sourcePreflightIds ?? this.sourcePreflightIds,
      sourceSeamProbeIds: sourceSeamProbeIds ?? this.sourceSeamProbeIds,
      sourceSkeletonIds: sourceSkeletonIds ?? this.sourceSkeletonIds,
      sourcePreparationIds: sourcePreparationIds ?? this.sourcePreparationIds,
      sourceCaseIds: sourceCaseIds ?? this.sourceCaseIds,
      sourceActionIds: sourceActionIds ?? this.sourceActionIds,
      sourcePatchIds: sourcePatchIds ?? this.sourcePatchIds,
      sourceRefinementIds: sourceRefinementIds ?? this.sourceRefinementIds,
      slotIds: slotIds ?? this.slotIds,
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
      activeRuntimeInputEnvelope:
          activeRuntimeInputEnvelope ?? this.activeRuntimeInputEnvelope,
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
      'envelopeId': envelopeId,
      'sourcePhase': sourcePhase,
      'sourceDiagnosticIds': sourceDiagnosticIds,
      'sourcePreflightIds': sourcePreflightIds,
      'sourceSeamProbeIds': sourceSeamProbeIds,
      'sourceSkeletonIds': sourceSkeletonIds,
      'sourcePreparationIds': sourcePreparationIds,
      'sourceCaseIds': sourceCaseIds,
      'sourceActionIds': sourceActionIds,
      'sourcePatchIds': sourcePatchIds,
      'sourceRefinementIds': sourceRefinementIds,
      'slotIds': slotIds,
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
      'activeRuntimeInputEnvelope': activeRuntimeInputEnvelope,
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

class DisabledAnalyzerAdapterRuntimeInputEnvelopeSlot {
  const DisabledAnalyzerAdapterRuntimeInputEnvelopeSlot({
    required this.slotId,
    required this.slotStatus,
    required this.slotPolicy,
    required this.disabled,
    required this.unset,
    required this.blocked,
    required this.redacted,
    required this.activePayloadPresent,
    required this.deniedFieldIds,
    required this.warningReasons,
    required this.recommendation,
  });

  final String slotId;
  final String slotStatus;
  final String slotPolicy;
  final bool disabled;
  final bool unset;
  final bool blocked;
  final bool redacted;
  final bool activePayloadPresent;
  final List<String> deniedFieldIds;
  final List<String> warningReasons;
  final String recommendation;

  DisabledAnalyzerAdapterRuntimeInputEnvelopeSlot copyWith({
    String? slotId,
    String? slotStatus,
    String? slotPolicy,
    bool? disabled,
    bool? unset,
    bool? blocked,
    bool? redacted,
    bool? activePayloadPresent,
    List<String>? deniedFieldIds,
    List<String>? warningReasons,
    String? recommendation,
  }) {
    return DisabledAnalyzerAdapterRuntimeInputEnvelopeSlot(
      slotId: slotId ?? this.slotId,
      slotStatus: slotStatus ?? this.slotStatus,
      slotPolicy: slotPolicy ?? this.slotPolicy,
      disabled: disabled ?? this.disabled,
      unset: unset ?? this.unset,
      blocked: blocked ?? this.blocked,
      redacted: redacted ?? this.redacted,
      activePayloadPresent: activePayloadPresent ?? this.activePayloadPresent,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      warningReasons: warningReasons ?? this.warningReasons,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'slotId': slotId,
      'slotStatus': slotStatus,
      'slotPolicy': slotPolicy,
      'disabled': disabled,
      'unset': unset,
      'blocked': blocked,
      'redacted': redacted,
      'activePayloadPresent': activePayloadPresent,
      'deniedFieldIds': deniedFieldIds,
      'warningReasons': warningReasons,
      'recommendation': recommendation,
    };
  }
}

class DisabledAnalyzerAdapterRuntimeInputEnvelopePolicy {
  const DisabledAnalyzerAdapterRuntimeInputEnvelopePolicy({
    required this.policyId,
    required this.envelopeDisabled,
    required this.activeRuntimeInputEnvelopeAllowed,
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

  final String policyId;
  final bool envelopeDisabled;
  final bool activeRuntimeInputEnvelopeAllowed;
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

  DisabledAnalyzerAdapterRuntimeInputEnvelopePolicy copyWith({
    String? policyId,
    bool? envelopeDisabled,
    bool? activeRuntimeInputEnvelopeAllowed,
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
    return DisabledAnalyzerAdapterRuntimeInputEnvelopePolicy(
      policyId: policyId ?? this.policyId,
      envelopeDisabled: envelopeDisabled ?? this.envelopeDisabled,
      activeRuntimeInputEnvelopeAllowed:
          activeRuntimeInputEnvelopeAllowed ??
          this.activeRuntimeInputEnvelopeAllowed,
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
      'activeRuntimeInputEnvelopeAllowed': activeRuntimeInputEnvelopeAllowed,
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

class DisabledAnalyzerAdapterRuntimeInputEnvelopeBoundary {
  const DisabledAnalyzerAdapterRuntimeInputEnvelopeBoundary({
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

  DisabledAnalyzerAdapterRuntimeInputEnvelopeBoundary copyWith({
    String? boundaryId,
    String? boundarySurface,
    bool? blocked,
    List<String>? deniedFieldIds,
    String? recommendation,
  }) {
    return DisabledAnalyzerAdapterRuntimeInputEnvelopeBoundary(
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

class DisabledAnalyzerAdapterRuntimeInputEnvelopeBlockedReason {
  const DisabledAnalyzerAdapterRuntimeInputEnvelopeBlockedReason({
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

  DisabledAnalyzerAdapterRuntimeInputEnvelopeBlockedReason copyWith({
    String? blockedReasonId,
    String? blockedSurface,
    bool? blocked,
    String? reason,
    List<String>? deniedFieldIds,
    String? recommendation,
  }) {
    return DisabledAnalyzerAdapterRuntimeInputEnvelopeBlockedReason(
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

class DisabledAnalyzerAdapterRuntimeInputEnvelopeResult {
  DisabledAnalyzerAdapterRuntimeInputEnvelopeResult({
    required this.status,
    required this.sourceRuntimeInputPreflightDiagnosticStatus,
    required this.sourceRuntimeInputPreflightStatus,
    required this.sourceSeamProbeDiagnosticStatus,
    required this.sourceSeamProbeStatus,
    required this.sourceRuntimeExecutionPreflightDiagnosticStatus,
    required this.input,
    required this.slots,
    required this.policy,
    required this.boundaries,
    required this.blockedReasons,
    required this.findings,
    required this.safeForPhase34R,
    required this.nextRecommendation,
  }) : slotCount = slots.length,
       boundaryCount = boundaries.length,
       blockedReasonCount = blockedReasons.length,
       disabledEnvelopeCount = input.envelopeCreated && input.envelopeDisabled
           ? 1
           : 0,
       activeRuntimeInputEnvelopeCount =
           (input.activeRuntimeInputEnvelope ? 1 : 0) +
           (policy.activeRuntimeInputEnvelopeAllowed ? 1 : 0),
       analyzerRuntimeInputApprovedCount =
           (input.analyzerRuntimeInputApproved ? 1 : 0) +
           (policy.analyzerRuntimeInputApproved ? 1 : 0),
       analyzerRuntimeInputProducedCount =
           (input.analyzerRuntimeInputProduced ? 1 : 0) +
           (policy.analyzerRuntimeInputProduced ? 1 : 0),
       runtimeExecutionApprovedCount =
           (input.runtimeExecutionApproved ? 1 : 0) +
           (policy.runtimeExecutionApproved ? 1 : 0),
       runtimeExecutionCount =
           (input.executionAllowed ? 1 : 0) +
           (input.executionPerformed ? 1 : 0) +
           (policy.executionAllowed ? 1 : 0) +
           (policy.executionPerformed ? 1 : 0),
       analyzerWiringCount =
           (input.analyzerWiringAllowed ? 1 : 0) +
           (policy.analyzerWiringAllowed ? 1 : 0),
       executableRuntimeCount = _activeDeniedFieldIds(
         policy.deniedFieldIds,
       ).where((id) => id == 'runtimeExecutionResult').length,
       engineCallCount =
           (input.engineCallsAllowed ? 1 : 0) +
           (policy.engineCallsAllowed ? 1 : 0),
       schedulerExecutionCount =
           (input.schedulerAllowed ? 1 : 0) + (policy.schedulerAllowed ? 1 : 0),
       persistenceWriteCount =
           (input.persistenceAllowed ? 1 : 0) +
           (policy.persistenceAllowed ? 1 : 0),
       productOutputCount =
           (input.productOutputAllowed ? 1 : 0) +
           (policy.productOutputAllowed ? 1 : 0),
       productAdapterCount =
           (input.productAdapterAllowed ? 1 : 0) +
           (policy.productAdapterAllowed ? 1 : 0),
       savedAnalysisIntegrationCount =
           (input.savedAnalysisAllowed ? 1 : 0) +
           (policy.savedAnalysisAllowed ? 1 : 0),
       uiBackendCacheDatabaseActivationCount =
           (policy.uiAllowed ? 1 : 0) +
           (policy.backendAllowed ? 1 : 0) +
           (policy.cacheAllowed ? 1 : 0) +
           (policy.databaseAllowed ? 1 : 0),
       activePayloadSlotCount = slots
           .where((slot) => slot.activePayloadPresent)
           .length,
       activeDeniedFieldCount =
           _activeDeniedFieldIds(input.deniedFieldIds).length +
           _activeDeniedFieldIds(policy.deniedFieldIds).length +
           slots
               .expand((slot) => _activeDeniedFieldIds(slot.deniedFieldIds))
               .length +
           boundaries
               .expand(
                 (boundary) => _activeDeniedFieldIds(boundary.deniedFieldIds),
               )
               .length +
           blockedReasons
               .expand((reason) => _activeDeniedFieldIds(reason.deniedFieldIds))
               .length,
       ownerProofQueueCount = input.ownerProofRequired ? 1 : 0,
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

  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeStatus status;
  final String sourceRuntimeInputPreflightDiagnosticStatus;
  final String sourceRuntimeInputPreflightStatus;
  final String sourceSeamProbeDiagnosticStatus;
  final String sourceSeamProbeStatus;
  final String sourceRuntimeExecutionPreflightDiagnosticStatus;
  final DisabledAnalyzerAdapterRuntimeInputEnvelopeInput input;
  final List<DisabledAnalyzerAdapterRuntimeInputEnvelopeSlot> slots;
  final DisabledAnalyzerAdapterRuntimeInputEnvelopePolicy policy;
  final List<DisabledAnalyzerAdapterRuntimeInputEnvelopeBoundary> boundaries;
  final List<DisabledAnalyzerAdapterRuntimeInputEnvelopeBlockedReason>
  blockedReasons;
  final List<String> findings;
  final bool safeForPhase34R;
  final String nextRecommendation;
  final int slotCount;
  final int boundaryCount;
  final int blockedReasonCount;
  final int disabledEnvelopeCount;
  final int activeRuntimeInputEnvelopeCount;
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
  final int activePayloadSlotCount;
  final int activeDeniedFieldCount;
  final int ownerProofQueueCount;
  final int phase32EProofClaimCount;
  final int unprovenAndroidProofCount;
  late final int unsafeCount;
  late final int blockerCount;
  late final int criticalCount;

  bool get hasUnsafePolicyViolation =>
      !safeForPhase34R ||
      findings.isNotEmpty ||
      disabledEnvelopeCount < 1 ||
      activeRuntimeInputEnvelopeCount > 0 ||
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
      activePayloadSlotCount > 0 ||
      activeDeniedFieldCount > 0 ||
      ownerProofQueueCount > 0 ||
      phase32EProofClaimCount > 0 ||
      unprovenAndroidProofCount > 0;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Disabled Analyzer Adapter Runtime Input Envelope')
      ..writeln()
      ..writeln('- status: ${status.wire}')
      ..writeln(
        '- source runtime input preflight diagnostic status: $sourceRuntimeInputPreflightDiagnosticStatus',
      )
      ..writeln(
        '- source runtime input preflight status: $sourceRuntimeInputPreflightStatus',
      )
      ..writeln('- safe for Phase 34R: $safeForPhase34R')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln()
      ..writeln('## Slot Summary')
      ..writeln('| Slot | Status | Policy | Disabled | Blocked | Redacted |')
      ..writeln('| --- | --- | --- | --- | --- | --- |');
    for (final slot in slots) {
      buffer.writeln(
        '| ${slot.slotId} | ${slot.slotStatus} | ${slot.slotPolicy} | ${slot.disabled} | ${slot.blocked} | ${slot.redacted} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Boundary Summary')
      ..writeln('| Boundary | Surface | Blocked |')
      ..writeln('| --- | --- | --- |');
    for (final boundary in boundaries) {
      buffer.writeln(
        '| ${boundary.boundaryId} | ${boundary.boundarySurface} | ${boundary.blocked} |',
      );
    }
    buffer
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
      ..writeln('- denied field count: ${policy.deniedFieldIds.length}')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln(
        '- active runtime input envelope count: $activeRuntimeInputEnvelopeCount',
      )
      ..writeln(
        '- analyzer runtime input approved count: $analyzerRuntimeInputApprovedCount',
      )
      ..writeln(
        '- analyzer runtime input produced count: $analyzerRuntimeInputProducedCount',
      )
      ..writeln('- runtime execution count: $runtimeExecutionCount')
      ..writeln()
      ..writeln('## Proof Boundary Summary')
      ..writeln('- android proof IDs: ${_ids(input.androidProofIds)}')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- Phase 32E proof claim count: $phase32EProofClaimCount')
      ..writeln()
      ..writeln('## Recommendation')
      ..writeln('- safeForPhase34R: $safeForPhase34R')
      ..writeln('- nextRecommendation: $nextRecommendation');
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent(' ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeVersion,
      'status': status.wire,
      'sourceRuntimeInputPreflightDiagnosticStatus':
          sourceRuntimeInputPreflightDiagnosticStatus,
      'sourceRuntimeInputPreflightStatus': sourceRuntimeInputPreflightStatus,
      'sourceSeamProbeDiagnosticStatus': sourceSeamProbeDiagnosticStatus,
      'sourceSeamProbeStatus': sourceSeamProbeStatus,
      'sourceRuntimeExecutionPreflightDiagnosticStatus':
          sourceRuntimeExecutionPreflightDiagnosticStatus,
      'safeForPhase34R': safeForPhase34R,
      'nextRecommendation': nextRecommendation,
      'counts': <String, Object?>{
        'slotCount': slotCount,
        'boundaryCount': boundaryCount,
        'blockedReasonCount': blockedReasonCount,
        'disabledEnvelopeCount': disabledEnvelopeCount,
        'activeRuntimeInputEnvelopeCount': activeRuntimeInputEnvelopeCount,
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
        'activePayloadSlotCount': activePayloadSlotCount,
        'activeDeniedFieldCount': activeDeniedFieldCount,
        'ownerProofQueueCount': ownerProofQueueCount,
        'phase32EProofClaimCount': phase32EProofClaimCount,
        'unprovenAndroidProofCount': unprovenAndroidProofCount,
        'unsafeCount': unsafeCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
      },
      'input': input.toJson(),
      'slots': slots.map((slot) => slot.toJson()).toList(growable: false),
      'policy': policy.toJson(),
      'boundaries': boundaries
          .map((boundary) => boundary.toJson())
          .toList(growable: false),
      'blockedReasons': blockedReasons
          .map((reason) => reason.toJson())
          .toList(growable: false),
      'findings': findings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelope {
  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelope();

  DisabledAnalyzerAdapterRuntimeInputEnvelopeResult evaluate({
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticResult?
    runtimeInputPreflightDiagnosticResult,
    ControlledAnalyzerAdapterRuntimeInputPreflightResult?
    runtimeInputPreflightResult,
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticResult?
    disabledSeamProbeDiagnosticResult,
    DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult?
    disabledSeamProbeResult,
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticResult?
    runtimeExecutionPreflightDiagnosticResult,
  }) {
    final runtimeInputPreflight =
        runtimeInputPreflightResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflight()
            .evaluate(
              disabledSeamProbeDiagnosticResult:
                  disabledSeamProbeDiagnosticResult,
              disabledSeamProbeResult: disabledSeamProbeResult,
              runtimeExecutionPreflightDiagnosticResult:
                  runtimeExecutionPreflightDiagnosticResult,
            );
    final runtimeInputPreflightDiagnostic =
        runtimeInputPreflightDiagnosticResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnostic()
            .evaluate(
              runtimeInputPreflightResult: runtimeInputPreflight,
              disabledSeamProbeDiagnosticResult:
                  disabledSeamProbeDiagnosticResult,
              disabledSeamProbeResult: disabledSeamProbeResult,
              runtimeExecutionPreflightDiagnosticResult:
                  runtimeExecutionPreflightDiagnosticResult,
            );
    final slots = _slotsFor();
    final boundaries = _boundariesFor();
    final blockedReasons = _blockedReasonsFor();
    final input = buildDisabledRuntimeInputEnvelope(
      runtimeInputPreflight: runtimeInputPreflight,
      runtimeInputPreflightDiagnostic: runtimeInputPreflightDiagnostic,
      slots: slots,
      boundaries: boundaries,
      blockedReasons: blockedReasons,
    );
    final policy = DisabledAnalyzerAdapterRuntimeInputEnvelopePolicy(
      policyId: 'disabled-runtime-input-envelope-policy',
      envelopeDisabled: true,
      activeRuntimeInputEnvelopeAllowed: false,
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
      deniedFieldIds: _deniedFieldIds,
      recommendation: _phase34RRecommendation,
    );
    final findings = _sorted(<String>[
      if (runtimeInputPreflightDiagnostic.hasUnsafePolicyViolation ||
          !runtimeInputPreflightDiagnostic.safeForPhase34Q)
        'unsafePhase34PRuntimeInputPreflightDiagnostic',
      if (runtimeInputPreflight.hasUnsafePolicyViolation ||
          !runtimeInputPreflight.safeForPhase34P)
        'unsafePhase34ORuntimeInputPreflight',
      if (disabledSeamProbeDiagnosticResult != null &&
          (disabledSeamProbeDiagnosticResult.hasUnsafePolicyViolation ||
              !disabledSeamProbeDiagnosticResult.safeForPhase34O))
        'unsafePhase34NDisabledRuntimeExecutionSeamProbeDiagnostic',
      if (disabledSeamProbeResult != null &&
          (disabledSeamProbeResult.hasUnsafePolicyViolation ||
              !disabledSeamProbeResult.safeForPhase34N))
        'unsafePhase34MDisabledRuntimeExecutionSeamProbe',
      if (runtimeExecutionPreflightDiagnosticResult != null &&
          (runtimeExecutionPreflightDiagnosticResult.hasUnsafePolicyViolation ||
              !runtimeExecutionPreflightDiagnosticResult.safeForPhase34M))
        'unsafePhase34LRuntimeExecutionPreflightDiagnostic',
      ...const DisabledAnalyzerAdapterRuntimeInputEnvelopeValidator()
          .validateEnvelope(
            input: input,
            slots: slots,
            policy: policy,
            boundaries: boundaries,
            blockedReasons: blockedReasons,
          ),
    ]);
    final safeForPhase34R = findings.isEmpty;
    return DisabledAnalyzerAdapterRuntimeInputEnvelopeResult(
      status: !safeForPhase34R
          ? DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeStatus
                .blockedByPolicyBoundary
          : slots.any((slot) => slot.warningReasons.isNotEmpty)
          ? DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeStatus
                .disabledAnalyzerAdapterRuntimeInputEnvelopeReadyWithWarnings
          : DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeStatus
                .disabledAnalyzerAdapterRuntimeInputEnvelopeReadyClean,
      sourceRuntimeInputPreflightDiagnosticStatus:
          runtimeInputPreflightDiagnostic.status.wire,
      sourceRuntimeInputPreflightStatus: runtimeInputPreflight.status.wire,
      sourceSeamProbeDiagnosticStatus:
          runtimeInputPreflight.sourceSeamProbeDiagnosticStatus,
      sourceSeamProbeStatus: runtimeInputPreflight.sourceSeamProbeStatus,
      sourceRuntimeExecutionPreflightDiagnosticStatus:
          runtimeInputPreflight.sourceRuntimeExecutionPreflightDiagnosticStatus,
      input: input,
      slots: slots,
      policy: policy,
      boundaries: boundaries,
      blockedReasons: blockedReasons,
      findings: findings,
      safeForPhase34R: safeForPhase34R,
      nextRecommendation: safeForPhase34R
          ? _phase34RRecommendation
          : 'blockedByUnsafeDisabledRuntimeInputEnvelope',
    );
  }

  DisabledAnalyzerAdapterRuntimeInputEnvelopeInput
  buildDisabledRuntimeInputEnvelope({
    required ControlledAnalyzerAdapterRuntimeInputPreflightResult
    runtimeInputPreflight,
    required DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticResult
    runtimeInputPreflightDiagnostic,
    required List<DisabledAnalyzerAdapterRuntimeInputEnvelopeSlot> slots,
    required List<DisabledAnalyzerAdapterRuntimeInputEnvelopeBoundary>
    boundaries,
    required List<DisabledAnalyzerAdapterRuntimeInputEnvelopeBlockedReason>
    blockedReasons,
  }) {
    return DisabledAnalyzerAdapterRuntimeInputEnvelopeInput(
      envelopeId: 'disabled-runtime-input-envelope',
      sourcePhase: 'Phase34Q',
      sourceDiagnosticIds: runtimeInputPreflightDiagnostic.rows
          .map((row) => row.diagnosticRowId)
          .toList(),
      sourcePreflightIds: _sorted(<String>[
        runtimeInputPreflight.input.preflightId,
        ...runtimeInputPreflight.input.sourcePreflightIds,
      ]),
      sourceSeamProbeIds: runtimeInputPreflight.input.sourceSeamProbeIds,
      sourceSkeletonIds: runtimeInputPreflight.input.sourceSkeletonIds,
      sourcePreparationIds: runtimeInputPreflight.input.sourcePreparationIds,
      sourceCaseIds: runtimeInputPreflight.input.sourceCaseIds,
      sourceActionIds: runtimeInputPreflight.input.sourceActionIds,
      sourcePatchIds: runtimeInputPreflight.input.sourcePatchIds,
      sourceRefinementIds: runtimeInputPreflight.input.sourceRefinementIds,
      slotIds: slots.map((slot) => slot.slotId).toList(),
      boundaryIds: boundaries.map((boundary) => boundary.boundaryId).toList(),
      blockedReasonIds: blockedReasons
          .map((reason) => reason.blockedReasonId)
          .toList(),
      deniedFieldIds: _deniedFieldIds,
      supportAreaIds: runtimeInputPreflight.input.supportAreaIds,
      warningReasons: runtimeInputPreflight.input.warningReasons,
      proofLimitReasons: runtimeInputPreflight.input.proofLimitReasons,
      androidProofIds: runtimeInputPreflight.input.androidProofIds,
      ownerProofRequired: runtimeInputPreflight.input.ownerProofRequired,
      envelopeCreated: true,
      envelopeDisabled: true,
      activeRuntimeInputEnvelope: false,
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
      recommendation: _phase34RRecommendation,
    );
  }

  DisabledAnalyzerAdapterRuntimeInputEnvelopeSlot
  createDisabledRuntimeInputSlot(
    String slotId, {
    List<String> warningReasons = const <String>[
      'disabledRuntimeInputEnvelopeMetadataOnly',
    ],
  }) {
    return DisabledAnalyzerAdapterRuntimeInputEnvelopeSlot(
      slotId: slotId,
      slotStatus: 'disabledRuntimeInputSlotMetadataOnly',
      slotPolicy: 'disabledUnsetOrRedacted',
      disabled: true,
      unset: true,
      blocked: false,
      redacted: true,
      activePayloadPresent: false,
      deniedFieldIds: const <String>[],
      warningReasons: warningReasons,
      recommendation: _phase34RRecommendation,
    );
  }

  DisabledAnalyzerAdapterRuntimeInputEnvelopeSlot blockRuntimeInputSlot(
    String slotId,
    String deniedFieldId,
  ) {
    return DisabledAnalyzerAdapterRuntimeInputEnvelopeSlot(
      slotId: slotId,
      slotStatus: 'runtimeInputSlotBlocked',
      slotPolicy: 'blockedAndRedacted',
      disabled: true,
      unset: true,
      blocked: true,
      redacted: true,
      activePayloadPresent: false,
      deniedFieldIds: <String>[deniedFieldId],
      warningReasons: const <String>['runtimeInputPayloadBlocked'],
      recommendation: _phase34RRecommendation,
    );
  }

  String renderDisabledRuntimeInputEnvelopeSnapshot(
    DisabledAnalyzerAdapterRuntimeInputEnvelopeResult result,
  ) {
    return result.renderMarkdown();
  }

  List<String> validateDisabledRuntimeInputEnvelope(
    DisabledAnalyzerAdapterRuntimeInputEnvelopeResult result,
  ) {
    return const DisabledAnalyzerAdapterRuntimeInputEnvelopeValidator()
        .validateResult(result);
  }
}

class DisabledAnalyzerAdapterRuntimeInputEnvelopeValidator {
  const DisabledAnalyzerAdapterRuntimeInputEnvelopeValidator();

  List<String> validateResult(
    DisabledAnalyzerAdapterRuntimeInputEnvelopeResult result,
  ) {
    return validateEnvelope(
      input: result.input,
      slots: result.slots,
      policy: result.policy,
      boundaries: result.boundaries,
      blockedReasons: result.blockedReasons,
    );
  }

  List<String> validateEnvelope({
    required DisabledAnalyzerAdapterRuntimeInputEnvelopeInput input,
    required Iterable<DisabledAnalyzerAdapterRuntimeInputEnvelopeSlot> slots,
    required DisabledAnalyzerAdapterRuntimeInputEnvelopePolicy policy,
    required Iterable<DisabledAnalyzerAdapterRuntimeInputEnvelopeBoundary>
    boundaries,
    required Iterable<DisabledAnalyzerAdapterRuntimeInputEnvelopeBlockedReason>
    blockedReasons,
  }) {
    return _sorted(<String>[
      ...validateInput(input),
      ...slots.expand(validateSlot),
      ...validatePolicy(policy),
      ...boundaries.expand(validateBoundary),
      ...blockedReasons.expand(validateBlockedReason),
    ]);
  }

  List<String> validateInput(
    DisabledAnalyzerAdapterRuntimeInputEnvelopeInput input,
  ) {
    final activeDenied = _activeDeniedFieldIds(input.deniedFieldIds);
    return _sorted(<String>[
      if (input.recommendation != _phase34RRecommendation)
        'missingPhase34RDisabledRuntimeInputEnvelopeDiagnosticRecommendation',
      if (!input.envelopeCreated) 'disabledRuntimeInputEnvelopeMissing',
      if (!input.envelopeDisabled) 'runtimeInputEnvelopeNotDisabled',
      if (input.activeRuntimeInputEnvelope) 'activeRuntimeInputEnvelopeEnabled',
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
      if (input.blockedReasonIds.any((id) => id.startsWith('active:')))
        'blockedReasonActivated',
      if (input.boundaryIds.any((id) => id.startsWith('active:')))
        'boundaryActivated',
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

  List<String> validateSlot(
    DisabledAnalyzerAdapterRuntimeInputEnvelopeSlot slot,
  ) {
    final activeDenied = _activeDeniedFieldIds(slot.deniedFieldIds);
    return _sorted(<String>[
      if (!_requiredSlotIds.contains(slot.slotId))
        'unknownRuntimeInputEnvelopeSlot',
      if (!slot.disabled && !slot.unset && !slot.blocked && !slot.redacted)
        'runtimeInputSlotNotDisabledUnsetBlockedOrRedacted',
      if (slot.activePayloadPresent) 'runtimeInputSlotActivePayloadPresent',
      if (activeDenied.isNotEmpty) 'activeDeniedFields',
      ..._deniedFieldFindings(activeDenied),
      if (slot.recommendation != _phase34RRecommendation)
        'missingPhase34RDisabledRuntimeInputEnvelopeDiagnosticRecommendation',
    ]);
  }

  List<String> validatePolicy(
    DisabledAnalyzerAdapterRuntimeInputEnvelopePolicy policy,
  ) {
    final activeDenied = _activeDeniedFieldIds(policy.deniedFieldIds);
    return _sorted(<String>[
      if (!policy.envelopeDisabled) 'runtimeInputEnvelopeNotDisabled',
      if (policy.activeRuntimeInputEnvelopeAllowed)
        'activeRuntimeInputEnvelopeEnabled',
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
      if (policy.recommendation != _phase34RRecommendation)
        'missingPhase34RDisabledRuntimeInputEnvelopeDiagnosticRecommendation',
    ]);
  }

  List<String> validateBoundary(
    DisabledAnalyzerAdapterRuntimeInputEnvelopeBoundary boundary,
  ) {
    final activeDenied = _activeDeniedFieldIds(boundary.deniedFieldIds);
    return _sorted(<String>[
      if (!_requiredBoundaryIds.contains(boundary.boundaryId))
        'unknownRuntimeInputEnvelopeBoundary',
      if (!boundary.blocked) 'runtimeInputEnvelopeBoundaryUnblocked',
      if (activeDenied.isNotEmpty) 'activeDeniedFields',
      ..._deniedFieldFindings(activeDenied),
      if (boundary.recommendation != _phase34RRecommendation)
        'missingPhase34RDisabledRuntimeInputEnvelopeDiagnosticRecommendation',
    ]);
  }

  List<String> validateBlockedReason(
    DisabledAnalyzerAdapterRuntimeInputEnvelopeBlockedReason reason,
  ) {
    final activeDenied = _activeDeniedFieldIds(reason.deniedFieldIds);
    return _sorted(<String>[
      if (!_requiredBlockedReasonIds.contains(reason.blockedReasonId))
        'unknownRuntimeInputEnvelopeBlockedReason',
      if (!reason.blocked) 'blockedReasonActivated',
      if (activeDenied.isNotEmpty) 'activeDeniedFields',
      ..._deniedFieldFindings(activeDenied),
      if (reason.recommendation != _phase34RRecommendation)
        'missingPhase34RDisabledRuntimeInputEnvelopeDiagnosticRecommendation',
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
      if (lower.contains('backend://') ||
          lower.contains('http://secret') ||
          lower.contains('https://secret'))
        'reportTextLeak:backendSecret',
    ]);
  }
}

List<DisabledAnalyzerAdapterRuntimeInputEnvelopeSlot> _slotsFor() {
  const envelope = DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelope();
  return <DisabledAnalyzerAdapterRuntimeInputEnvelopeSlot>[
    envelope.createDisabledRuntimeInputSlot('sourceChainSlot'),
    envelope.createDisabledRuntimeInputSlot('selectedGoldenSupportSlot'),
    envelope.createDisabledRuntimeInputSlot('proofBoundarySlot'),
    envelope.createDisabledRuntimeInputSlot('deniedFieldSlot'),
    envelope.createDisabledRuntimeInputSlot('runtimeInputCandidateSlot'),
    envelope.blockRuntimeInputSlot(
      'fenPayloadSlotBlocked',
      'playableFenPayload',
    ),
    envelope.blockRuntimeInputSlot('pgnPayloadSlotBlocked', 'pgnPayload'),
    envelope.blockRuntimeInputSlot('moveListSlotBlocked', 'moveListPayload'),
    envelope.blockRuntimeInputSlot('uciMoveSlotBlocked', 'uciMovePayload'),
    envelope.blockRuntimeInputSlot(
      'engineOptionSlotBlocked',
      'engineOptionPayload',
    ),
    envelope.blockRuntimeInputSlot('depthSlotBlocked', 'depthAnalysisValue'),
    envelope.blockRuntimeInputSlot(
      'multiPvSlotBlocked',
      'multiPvAnalysisValue',
    ),
    envelope.blockRuntimeInputSlot(
      'stockfishCommandSlotBlocked',
      'stockfishCommand',
    ),
    envelope.blockRuntimeInputSlot('rawUciSlotBlocked', 'rawUci'),
    envelope.blockRuntimeInputSlot('pvDumpSlotBlocked', 'pvDump'),
    envelope.blockRuntimeInputSlot('productLabelSlotBlocked', 'productLabel'),
    envelope.blockRuntimeInputSlot(
      'scoreMetricSlotBlocked',
      'numericMoveScore',
    ),
    envelope.blockRuntimeInputSlot(
      'persistenceSlotBlocked',
      'persistenceWrite',
    ),
    envelope.blockRuntimeInputSlot(
      'schedulerSlotBlocked',
      'schedulerExecution',
    ),
    envelope.blockRuntimeInputSlot(
      'productAdapterSlotBlocked',
      'productAdapterBehavior',
    ),
    envelope.blockRuntimeInputSlot(
      'savedAnalysisSlotBlocked',
      'savedAnalysisIntegration',
    ),
  ];
}

List<DisabledAnalyzerAdapterRuntimeInputEnvelopeBoundary> _boundariesFor() {
  return _requiredBoundaryIds
      .map(
        (id) => DisabledAnalyzerAdapterRuntimeInputEnvelopeBoundary(
          boundaryId: id,
          boundarySurface: id,
          blocked: true,
          deniedFieldIds: _deniedFieldsForSurface(id),
          recommendation: _phase34RRecommendation,
        ),
      )
      .toList();
}

List<DisabledAnalyzerAdapterRuntimeInputEnvelopeBlockedReason>
_blockedReasonsFor() {
  return _requiredBlockedReasonIds
      .map(
        (id) => DisabledAnalyzerAdapterRuntimeInputEnvelopeBlockedReason(
          blockedReasonId: id,
          blockedSurface: id,
          blocked: true,
          reason: 'blocked by disabled runtime input envelope policy',
          deniedFieldIds: _deniedFieldsForSurface(id),
          recommendation: _phase34RRecommendation,
        ),
      )
      .toList();
}

List<String> _deniedFieldsForSurface(String id) {
  final lower = id.toLowerCase();
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
  if (lower.contains('productlabel')) return const <String>['productLabel'];
  if (lower.contains('numericscore')) return const <String>['numericMoveScore'];
  if (lower.contains('officialmetric')) return const <String>['officialMetric'];
  if (lower.contains('cploss')) return const <String>['cpLoss'];
  if (lower.contains('winprobability')) return const <String>['winProbability'];
  if (lower.contains('analyzerruntimeinput')) {
    return const <String>['analyzerRuntimeInput'];
  }
  if (lower.contains('engine')) return const <String>['engineResult'];
  if (lower.contains('ui') || lower.contains('backend')) {
    return const <String>['uiState', 'backendResponse'];
  }
  if (lower.contains('cache') || lower.contains('database')) {
    return const <String>['cacheDatabaseWrite'];
  }
  return const <String>[];
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

String _ids(Iterable<String> ids) {
  final values = _sorted(ids);
  return values.isEmpty ? 'none' : values.join(', ');
}

List<String> _sorted(Iterable<String> values) {
  final sorted = values.toSet().toList()..sort();
  return sorted;
}

const _phase34RRecommendation =
    'runDisabledAnalyzerAdapterRuntimeInputEnvelopeDiagnostic';
const _pvMultiPvBoundaryCaseId = 'pv-multipv-support-boundary-32e';
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
const _requiredSlotIds = <String>{
  'sourceChainSlot',
  'selectedGoldenSupportSlot',
  'proofBoundarySlot',
  'deniedFieldSlot',
  'runtimeInputCandidateSlot',
  'fenPayloadSlotBlocked',
  'pgnPayloadSlotBlocked',
  'moveListSlotBlocked',
  'uciMoveSlotBlocked',
  'engineOptionSlotBlocked',
  'depthSlotBlocked',
  'multiPvSlotBlocked',
  'stockfishCommandSlotBlocked',
  'rawUciSlotBlocked',
  'pvDumpSlotBlocked',
  'productLabelSlotBlocked',
  'scoreMetricSlotBlocked',
  'persistenceSlotBlocked',
  'schedulerSlotBlocked',
  'productAdapterSlotBlocked',
  'savedAnalysisSlotBlocked',
};
const _requiredBoundaryIds = <String>{
  'disabledRuntimeInputEnvelopeBoundary',
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
  'runtimeInputEnvelopeDisabledByPolicy',
  'analyzerRuntimeInputNotApproved',
  'analyzerRuntimeInputProductionBlocked',
  'runtimeExecutionNotApproved',
  'executionAllowedFalse',
  'analyzerRuntimeInputBoundaryBlocked',
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
const _deniedFieldIds = <String>[
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
];
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

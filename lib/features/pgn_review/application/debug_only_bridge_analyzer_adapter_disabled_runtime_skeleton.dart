import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_diagnostic.dart';

const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonVersion =
    'debug-only-bridge-analyzer-adapter-disabled-runtime-skeleton-v1';

enum DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonStatus {
  disabledAnalyzerAdapterRuntimeSkeletonReadyWithWarnings(
    'disabledAnalyzerAdapterRuntimeSkeletonReadyWithWarnings',
  ),
  disabledAnalyzerAdapterRuntimeSkeletonReadyClean(
    'disabledAnalyzerAdapterRuntimeSkeletonReadyClean',
  ),
  blockedByUnsafeRuntimePreparationDiagnostic(
    'blockedByUnsafeRuntimePreparationDiagnostic',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidDisabledRuntimeSkeleton('invalidDisabledRuntimeSkeleton');

  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonStatus(this.wire);

  final String wire;
}

class DisabledAnalyzerAdapterRuntimeSkeletonRequest {
  const DisabledAnalyzerAdapterRuntimeSkeletonRequest({
    required this.skeletonId,
    required this.sourcePhase,
    required this.sourceDiagnosticIds,
    required this.sourcePreparationIds,
    required this.sourceCaseIds,
    required this.sourceActionIds,
    required this.sourcePatchIds,
    required this.sourceRefinementIds,
    required this.requestEnvelopeId,
    required this.policyId,
    required this.blockedSeamIds,
    required this.deniedFieldIds,
    required this.supportAreaIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.androidProofIds,
    required this.ownerProofRequired,
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

  final String skeletonId;
  final String sourcePhase;
  final List<String> sourceDiagnosticIds;
  final List<String> sourcePreparationIds;
  final List<String> sourceCaseIds;
  final List<String> sourceActionIds;
  final List<String> sourcePatchIds;
  final List<String> sourceRefinementIds;
  final String requestEnvelopeId;
  final String policyId;
  final List<String> blockedSeamIds;
  final List<String> deniedFieldIds;
  final List<String> supportAreaIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofIds;
  final bool ownerProofRequired;
  final bool executionAllowed;
  final bool analyzerWiringAllowed;
  final bool engineCallsAllowed;
  final bool schedulerAllowed;
  final bool persistenceAllowed;
  final bool productOutputAllowed;
  final bool productAdapterAllowed;
  final bool savedAnalysisAllowed;
  final String recommendation;

  DisabledAnalyzerAdapterRuntimeSkeletonRequest copyWith({
    String? skeletonId,
    String? sourcePhase,
    List<String>? sourceDiagnosticIds,
    List<String>? sourcePreparationIds,
    List<String>? sourceCaseIds,
    List<String>? sourceActionIds,
    List<String>? sourcePatchIds,
    List<String>? sourceRefinementIds,
    String? requestEnvelopeId,
    String? policyId,
    List<String>? blockedSeamIds,
    List<String>? deniedFieldIds,
    List<String>? supportAreaIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? androidProofIds,
    bool? ownerProofRequired,
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
    return DisabledAnalyzerAdapterRuntimeSkeletonRequest(
      skeletonId: skeletonId ?? this.skeletonId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      sourceDiagnosticIds: sourceDiagnosticIds ?? this.sourceDiagnosticIds,
      sourcePreparationIds: sourcePreparationIds ?? this.sourcePreparationIds,
      sourceCaseIds: sourceCaseIds ?? this.sourceCaseIds,
      sourceActionIds: sourceActionIds ?? this.sourceActionIds,
      sourcePatchIds: sourcePatchIds ?? this.sourcePatchIds,
      sourceRefinementIds: sourceRefinementIds ?? this.sourceRefinementIds,
      requestEnvelopeId: requestEnvelopeId ?? this.requestEnvelopeId,
      policyId: policyId ?? this.policyId,
      blockedSeamIds: blockedSeamIds ?? this.blockedSeamIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      supportAreaIds: supportAreaIds ?? this.supportAreaIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      androidProofIds: androidProofIds ?? this.androidProofIds,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
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
      'skeletonId': skeletonId,
      'sourcePhase': sourcePhase,
      'sourceDiagnosticIds': sourceDiagnosticIds,
      'sourcePreparationIds': sourcePreparationIds,
      'sourceCaseIds': sourceCaseIds,
      'sourceActionIds': sourceActionIds,
      'sourcePatchIds': sourcePatchIds,
      'sourceRefinementIds': sourceRefinementIds,
      'requestEnvelopeId': requestEnvelopeId,
      'policyId': policyId,
      'blockedSeamIds': blockedSeamIds,
      'deniedFieldIds': deniedFieldIds,
      'supportAreaIds': supportAreaIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'androidProofIds': androidProofIds,
      'ownerProofRequired': ownerProofRequired,
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

class DisabledAnalyzerAdapterRuntimeSkeletonResponse {
  const DisabledAnalyzerAdapterRuntimeSkeletonResponse({
    required this.skeletonId,
    required this.responseEnvelopeId,
    required this.requestEnvelopeId,
    required this.executionAttemptId,
    required this.executionRefusedReason,
    required this.blockedSeamIds,
    required this.deniedFieldIds,
    required this.warningReasons,
    required this.proofLimitReasons,
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

  final String skeletonId;
  final String responseEnvelopeId;
  final String requestEnvelopeId;
  final String executionAttemptId;
  final String executionRefusedReason;
  final List<String> blockedSeamIds;
  final List<String> deniedFieldIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final bool executionAllowed;
  final bool analyzerWiringAllowed;
  final bool engineCallsAllowed;
  final bool schedulerAllowed;
  final bool persistenceAllowed;
  final bool productOutputAllowed;
  final bool productAdapterAllowed;
  final bool savedAnalysisAllowed;
  final String recommendation;

  DisabledAnalyzerAdapterRuntimeSkeletonResponse copyWith({
    String? skeletonId,
    String? responseEnvelopeId,
    String? requestEnvelopeId,
    String? executionAttemptId,
    String? executionRefusedReason,
    List<String>? blockedSeamIds,
    List<String>? deniedFieldIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
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
    return DisabledAnalyzerAdapterRuntimeSkeletonResponse(
      skeletonId: skeletonId ?? this.skeletonId,
      responseEnvelopeId: responseEnvelopeId ?? this.responseEnvelopeId,
      requestEnvelopeId: requestEnvelopeId ?? this.requestEnvelopeId,
      executionAttemptId: executionAttemptId ?? this.executionAttemptId,
      executionRefusedReason:
          executionRefusedReason ?? this.executionRefusedReason,
      blockedSeamIds: blockedSeamIds ?? this.blockedSeamIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
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
      'skeletonId': skeletonId,
      'responseEnvelopeId': responseEnvelopeId,
      'requestEnvelopeId': requestEnvelopeId,
      'executionAttemptId': executionAttemptId,
      'executionRefusedReason': executionRefusedReason,
      'blockedSeamIds': blockedSeamIds,
      'deniedFieldIds': deniedFieldIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
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

class DisabledAnalyzerAdapterRuntimeSkeletonPolicy {
  const DisabledAnalyzerAdapterRuntimeSkeletonPolicy({
    required this.policyId,
    required this.deniedFieldIds,
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
    required this.executableRuntimeAllowed,
  });

  factory DisabledAnalyzerAdapterRuntimeSkeletonPolicy.disabledDefault({
    required List<String> deniedFieldIds,
  }) {
    return DisabledAnalyzerAdapterRuntimeSkeletonPolicy(
      policyId: 'disabled-analyzer-adapter-runtime-skeleton-policy',
      deniedFieldIds: _sorted(deniedFieldIds),
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
      executableRuntimeAllowed: false,
    );
  }

  final String policyId;
  final List<String> deniedFieldIds;
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
  final bool executableRuntimeAllowed;

  DisabledAnalyzerAdapterRuntimeSkeletonPolicy copyWith({
    String? policyId,
    List<String>? deniedFieldIds,
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
    bool? executableRuntimeAllowed,
  }) {
    return DisabledAnalyzerAdapterRuntimeSkeletonPolicy(
      policyId: policyId ?? this.policyId,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
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
      executableRuntimeAllowed:
          executableRuntimeAllowed ?? this.executableRuntimeAllowed,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'policyId': policyId,
      'deniedFieldIds': deniedFieldIds,
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
      'executableRuntimeAllowed': executableRuntimeAllowed,
    };
  }
}

class DisabledAnalyzerAdapterRuntimeSkeletonEnvelope {
  const DisabledAnalyzerAdapterRuntimeSkeletonEnvelope({
    required this.envelopeId,
    required this.envelopeRole,
    required this.skeletonId,
    required this.sourcePhase,
    required this.blockedSeamIds,
    required this.deniedFieldIds,
    required this.warningReasons,
    required this.proofLimitReasons,
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
  final String envelopeRole;
  final String skeletonId;
  final String sourcePhase;
  final List<String> blockedSeamIds;
  final List<String> deniedFieldIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final bool executionAllowed;
  final bool analyzerWiringAllowed;
  final bool engineCallsAllowed;
  final bool schedulerAllowed;
  final bool persistenceAllowed;
  final bool productOutputAllowed;
  final bool productAdapterAllowed;
  final bool savedAnalysisAllowed;
  final String recommendation;

  DisabledAnalyzerAdapterRuntimeSkeletonEnvelope copyWith({
    String? envelopeId,
    String? envelopeRole,
    String? skeletonId,
    String? sourcePhase,
    List<String>? blockedSeamIds,
    List<String>? deniedFieldIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
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
    return DisabledAnalyzerAdapterRuntimeSkeletonEnvelope(
      envelopeId: envelopeId ?? this.envelopeId,
      envelopeRole: envelopeRole ?? this.envelopeRole,
      skeletonId: skeletonId ?? this.skeletonId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      blockedSeamIds: blockedSeamIds ?? this.blockedSeamIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
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
      'envelopeRole': envelopeRole,
      'skeletonId': skeletonId,
      'sourcePhase': sourcePhase,
      'blockedSeamIds': blockedSeamIds,
      'deniedFieldIds': deniedFieldIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
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

class DisabledAnalyzerAdapterRuntimeSkeletonExecutionAttempt {
  const DisabledAnalyzerAdapterRuntimeSkeletonExecutionAttempt({
    required this.executionAttemptId,
    required this.skeletonId,
    required this.requestEnvelopeId,
    required this.responseEnvelopeId,
    required this.executionAttempted,
    required this.executionPerformed,
    required this.executionRefused,
    required this.executionRefusedReason,
    required this.blockedSeamIds,
    required this.deniedFieldIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.recommendation,
  });

  final String executionAttemptId;
  final String skeletonId;
  final String requestEnvelopeId;
  final String responseEnvelopeId;
  final bool executionAttempted;
  final bool executionPerformed;
  final bool executionRefused;
  final String executionRefusedReason;
  final List<String> blockedSeamIds;
  final List<String> deniedFieldIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final String recommendation;

  DisabledAnalyzerAdapterRuntimeSkeletonExecutionAttempt copyWith({
    String? executionAttemptId,
    String? skeletonId,
    String? requestEnvelopeId,
    String? responseEnvelopeId,
    bool? executionAttempted,
    bool? executionPerformed,
    bool? executionRefused,
    String? executionRefusedReason,
    List<String>? blockedSeamIds,
    List<String>? deniedFieldIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    String? recommendation,
  }) {
    return DisabledAnalyzerAdapterRuntimeSkeletonExecutionAttempt(
      executionAttemptId: executionAttemptId ?? this.executionAttemptId,
      skeletonId: skeletonId ?? this.skeletonId,
      requestEnvelopeId: requestEnvelopeId ?? this.requestEnvelopeId,
      responseEnvelopeId: responseEnvelopeId ?? this.responseEnvelopeId,
      executionAttempted: executionAttempted ?? this.executionAttempted,
      executionPerformed: executionPerformed ?? this.executionPerformed,
      executionRefused: executionRefused ?? this.executionRefused,
      executionRefusedReason:
          executionRefusedReason ?? this.executionRefusedReason,
      blockedSeamIds: blockedSeamIds ?? this.blockedSeamIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'executionAttemptId': executionAttemptId,
      'skeletonId': skeletonId,
      'requestEnvelopeId': requestEnvelopeId,
      'responseEnvelopeId': responseEnvelopeId,
      'executionAttempted': executionAttempted,
      'executionPerformed': executionPerformed,
      'executionRefused': executionRefused,
      'executionRefusedReason': executionRefusedReason,
      'blockedSeamIds': blockedSeamIds,
      'deniedFieldIds': deniedFieldIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'recommendation': recommendation,
    };
  }
}

class DisabledAnalyzerAdapterRuntimeSkeletonBlockedSeam {
  const DisabledAnalyzerAdapterRuntimeSkeletonBlockedSeam({
    required this.blockedSeamId,
    required this.seamRole,
    required this.targetSurface,
    required this.blocked,
    required this.blockReason,
    required this.deniedFieldIds,
    required this.recommendation,
  });

  final String blockedSeamId;
  final String seamRole;
  final String targetSurface;
  final bool blocked;
  final String blockReason;
  final List<String> deniedFieldIds;
  final String recommendation;

  DisabledAnalyzerAdapterRuntimeSkeletonBlockedSeam copyWith({
    String? blockedSeamId,
    String? seamRole,
    String? targetSurface,
    bool? blocked,
    String? blockReason,
    List<String>? deniedFieldIds,
    String? recommendation,
  }) {
    return DisabledAnalyzerAdapterRuntimeSkeletonBlockedSeam(
      blockedSeamId: blockedSeamId ?? this.blockedSeamId,
      seamRole: seamRole ?? this.seamRole,
      targetSurface: targetSurface ?? this.targetSurface,
      blocked: blocked ?? this.blocked,
      blockReason: blockReason ?? this.blockReason,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'blockedSeamId': blockedSeamId,
      'seamRole': seamRole,
      'targetSurface': targetSurface,
      'blocked': blocked,
      'blockReason': blockReason,
      'deniedFieldIds': deniedFieldIds,
      'recommendation': recommendation,
    };
  }
}

class DisabledAnalyzerAdapterRuntimeSkeletonResult {
  DisabledAnalyzerAdapterRuntimeSkeletonResult({
    required this.status,
    required this.sourceDiagnosticStatus,
    required this.sourcePreparationStatus,
    required this.request,
    required this.response,
    required this.policy,
    required this.envelopes,
    required this.executionAttempt,
    required this.blockedSeams,
    required this.findings,
    required this.safeForPhase34J,
    required this.nextRecommendation,
  }) : totalEnvelopes = envelopes.length,
       totalBlockedSeams = blockedSeams.length,
       deniedFieldCount = _sorted(policy.deniedFieldIds).length,
       ownerProofQueueCount = request.ownerProofRequired ? 1 : 0,
       activeDeniedFieldCount =
           _activeDeniedFieldIds(policy.deniedFieldIds).length +
           _countUnblockedDeniedSeams(blockedSeams),
       runtimeExecutionCount =
           (policy.executionAllowed ? 1 : 0) +
           (request.executionAllowed ? 1 : 0) +
           (response.executionAllowed ? 1 : 0) +
           (executionAttempt.executionPerformed ? 1 : 0),
       executableRuntimeCount = policy.executableRuntimeAllowed ? 1 : 0,
       analyzerWiringCount =
           (policy.analyzerWiringAllowed ? 1 : 0) +
           (request.analyzerWiringAllowed ? 1 : 0) +
           (response.analyzerWiringAllowed ? 1 : 0),
       engineCallCount =
           (policy.engineCallsAllowed ? 1 : 0) +
           (request.engineCallsAllowed ? 1 : 0) +
           (response.engineCallsAllowed ? 1 : 0),
       schedulerExecutionCount =
           (policy.schedulerAllowed ? 1 : 0) +
           (request.schedulerAllowed ? 1 : 0) +
           (response.schedulerAllowed ? 1 : 0),
       persistenceWriteCount =
           (policy.persistenceAllowed ? 1 : 0) +
           (request.persistenceAllowed ? 1 : 0) +
           (response.persistenceAllowed ? 1 : 0),
       productOutputCount =
           (policy.productOutputAllowed ? 1 : 0) +
           (request.productOutputAllowed ? 1 : 0) +
           (response.productOutputAllowed ? 1 : 0),
       productAdapterCount =
           (policy.productAdapterAllowed ? 1 : 0) +
           (request.productAdapterAllowed ? 1 : 0) +
           (response.productAdapterAllowed ? 1 : 0),
       savedAnalysisIntegrationCount =
           (policy.savedAnalysisAllowed ? 1 : 0) +
           (request.savedAnalysisAllowed ? 1 : 0) +
           (response.savedAnalysisAllowed ? 1 : 0),
       uiTargetCount = policy.uiAllowed ? 1 : 0,
       backendTargetCount = policy.backendAllowed ? 1 : 0,
       cacheDatabaseWriteCount =
           (policy.cacheAllowed ? 1 : 0) + (policy.databaseAllowed ? 1 : 0),
       phase32EProofClaimCount = request.androidProofIds
           .where(_phase32ECaseIds.contains)
           .length,
       unprovenAndroidProofCount = request.androidProofIds
           .where((id) => !_capturedAndroidProofIds.contains(id))
           .length {
    unsafeCount = hasUnsafePolicyViolation ? 1 : 0;
    blockerCount = hasUnsafePolicyViolation ? 1 : 0;
    criticalCount = 0;
  }

  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonStatus status;
  final String sourceDiagnosticStatus;
  final String sourcePreparationStatus;
  final DisabledAnalyzerAdapterRuntimeSkeletonRequest request;
  final DisabledAnalyzerAdapterRuntimeSkeletonResponse response;
  final DisabledAnalyzerAdapterRuntimeSkeletonPolicy policy;
  final List<DisabledAnalyzerAdapterRuntimeSkeletonEnvelope> envelopes;
  final DisabledAnalyzerAdapterRuntimeSkeletonExecutionAttempt executionAttempt;
  final List<DisabledAnalyzerAdapterRuntimeSkeletonBlockedSeam> blockedSeams;
  final List<String> findings;
  final bool safeForPhase34J;
  final String nextRecommendation;
  final int totalEnvelopes;
  final int totalBlockedSeams;
  final int deniedFieldCount;
  final int ownerProofQueueCount;
  final int activeDeniedFieldCount;
  final int runtimeExecutionCount;
  final int analyzerWiringCount;
  final int executableRuntimeCount;
  final int engineCallCount;
  final int schedulerExecutionCount;
  final int persistenceWriteCount;
  final int productOutputCount;
  final int productAdapterCount;
  final int savedAnalysisIntegrationCount;
  final int uiTargetCount;
  final int backendTargetCount;
  final int cacheDatabaseWriteCount;
  final int phase32EProofClaimCount;
  final int unprovenAndroidProofCount;
  late final int unsafeCount;
  late final int blockerCount;
  late final int criticalCount;

  bool get hasUnsafePolicyViolation =>
      !safeForPhase34J ||
      findings.isNotEmpty ||
      activeDeniedFieldCount > 0 ||
      runtimeExecutionCount > 0 ||
      executableRuntimeCount > 0 ||
      analyzerWiringCount > 0 ||
      engineCallCount > 0 ||
      schedulerExecutionCount > 0 ||
      persistenceWriteCount > 0 ||
      productOutputCount > 0 ||
      productAdapterCount > 0 ||
      savedAnalysisIntegrationCount > 0 ||
      uiTargetCount > 0 ||
      backendTargetCount > 0 ||
      cacheDatabaseWriteCount > 0 ||
      phase32EProofClaimCount > 0 ||
      unprovenAndroidProofCount > 0 ||
      ownerProofQueueCount > 0;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Disabled Analyzer Adapter Runtime Skeleton')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonVersion',
      )
      ..writeln('- skeleton status: ${status.wire}')
      ..writeln('- source diagnostic status: $sourceDiagnosticStatus')
      ..writeln('- source preparation status: $sourcePreparationStatus')
      ..writeln('- safe for Phase 34J: $safeForPhase34J')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln()
      ..writeln('## Request Envelope Summary')
      ..writeln('- request envelope ID: ${request.requestEnvelopeId}')
      ..writeln('- skeleton ID: ${request.skeletonId}')
      ..writeln('- source phase: ${request.sourcePhase}')
      ..writeln('- executionAllowed: ${request.executionAllowed}')
      ..writeln('- analyzerWiringAllowed: ${request.analyzerWiringAllowed}')
      ..writeln('- engineCallsAllowed: ${request.engineCallsAllowed}')
      ..writeln()
      ..writeln('## Response Envelope Summary')
      ..writeln('- response envelope ID: ${response.responseEnvelopeId}')
      ..writeln('- execution attempt ID: ${response.executionAttemptId}')
      ..writeln(
        '- execution refused reason: ${response.executionRefusedReason}',
      )
      ..writeln('- executionAllowed: ${response.executionAllowed}')
      ..writeln()
      ..writeln('## Disabled Execution Attempt Summary')
      ..writeln('- attempt ID: ${executionAttempt.executionAttemptId}')
      ..writeln('- execution attempted: ${executionAttempt.executionAttempted}')
      ..writeln('- execution performed: ${executionAttempt.executionPerformed}')
      ..writeln('- execution refused: ${executionAttempt.executionRefused}')
      ..writeln(
        '- execution refused reason: ${executionAttempt.executionRefusedReason}',
      )
      ..writeln()
      ..writeln('## Disabled Runtime Policy')
      ..writeln('- policy ID: ${policy.policyId}')
      ..writeln('- executionAllowed: ${policy.executionAllowed}')
      ..writeln('- analyzerWiringAllowed: ${policy.analyzerWiringAllowed}')
      ..writeln('- engineCallsAllowed: ${policy.engineCallsAllowed}')
      ..writeln('- schedulerAllowed: ${policy.schedulerAllowed}')
      ..writeln('- persistenceAllowed: ${policy.persistenceAllowed}')
      ..writeln('- productOutputAllowed: ${policy.productOutputAllowed}')
      ..writeln('- productAdapterAllowed: ${policy.productAdapterAllowed}')
      ..writeln('- savedAnalysisAllowed: ${policy.savedAnalysisAllowed}')
      ..writeln()
      ..writeln('## Runtime Skeleton Envelopes')
      ..writeln(
        '| Envelope | Role | Execution | Analyzer wiring | Engine calls | Product output |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- |');
    for (final envelope in envelopes) {
      buffer.writeln(
        '| ${envelope.envelopeId} | ${envelope.envelopeRole} | ${envelope.executionAllowed} | ${envelope.analyzerWiringAllowed} | ${envelope.engineCallsAllowed} | ${envelope.productOutputAllowed} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Blocked Seam Summary')
      ..writeln('| Seam | Target surface | Blocked |')
      ..writeln('| --- | --- | --- |');
    for (final seam in blockedSeams) {
      buffer.writeln(
        '| ${seam.blockedSeamId} | ${seam.targetSurface} | ${seam.blocked} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Denied Field Summary')
      ..writeln('- denied field count: $deniedFieldCount')
      ..writeln('- denied field IDs: ${_ids(policy.deniedFieldIds)}')
      ..writeln()
      ..writeln('## Safety Summary')
      ..writeln('- runtime execution count: $runtimeExecutionCount')
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
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Recommendation')
      ..writeln('- safe for Phase 34J: $safeForPhase34J')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- findings: ${_ids(findings)}')
      ..writeln();
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent(' ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonVersion,
      'status': status.wire,
      'sourceDiagnosticStatus': sourceDiagnosticStatus,
      'sourcePreparationStatus': sourcePreparationStatus,
      'safeForPhase34J': safeForPhase34J,
      'nextRecommendation': nextRecommendation,
      'counts': <String, Object?>{
        'totalEnvelopes': totalEnvelopes,
        'totalBlockedSeams': totalBlockedSeams,
        'deniedFieldCount': deniedFieldCount,
        'unsafeCount': unsafeCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
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
      'request': request.toJson(),
      'response': response.toJson(),
      'policy': policy.toJson(),
      'envelopes': envelopes.map((envelope) => envelope.toJson()).toList(),
      'executionAttempt': executionAttempt.toJson(),
      'blockedSeams': blockedSeams.map((seam) => seam.toJson()).toList(),
      'findings': findings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeleton {
  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeleton();

  DisabledAnalyzerAdapterRuntimeSkeletonResult evaluate({
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticResult?
    runtimePreparationDiagnosticResult,
    ControlledAnalyzerAdapterRuntimePreparationResult? runtimePreparationResult,
  }) {
    final preparation =
        runtimePreparationResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation()
            .evaluate();
    final diagnostic =
        runtimePreparationDiagnosticResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic()
            .evaluate(runtimePreparationResult: preparation);
    if (diagnostic.hasUnsafePolicyViolation || !diagnostic.safeForPhase34I) {
      return _blockedResult(diagnostic, preparation);
    }

    final request = buildDisabledRuntimeRequest(
      diagnostic: diagnostic,
      preparation: preparation,
    );
    final policy = DisabledAnalyzerAdapterRuntimeSkeletonPolicy.disabledDefault(
      deniedFieldIds: request.deniedFieldIds,
    );
    final attempt = createDisabledExecutionAttempt(request: request);
    final response = buildDisabledRuntimeResponse(
      request: request,
      attempt: attempt,
    );
    final envelopes = <DisabledAnalyzerAdapterRuntimeSkeletonEnvelope>[
      DisabledAnalyzerAdapterRuntimeSkeletonEnvelope(
        envelopeId: request.requestEnvelopeId,
        envelopeRole: _requestEnvelopeRole,
        skeletonId: request.skeletonId,
        sourcePhase: request.sourcePhase,
        blockedSeamIds: request.blockedSeamIds,
        deniedFieldIds: request.deniedFieldIds,
        warningReasons: request.warningReasons,
        proofLimitReasons: request.proofLimitReasons,
        executionAllowed: false,
        analyzerWiringAllowed: false,
        engineCallsAllowed: false,
        schedulerAllowed: false,
        persistenceAllowed: false,
        productOutputAllowed: false,
        productAdapterAllowed: false,
        savedAnalysisAllowed: false,
        recommendation: _phase34JRecommendation,
      ),
      DisabledAnalyzerAdapterRuntimeSkeletonEnvelope(
        envelopeId: response.responseEnvelopeId,
        envelopeRole: _responseEnvelopeRole,
        skeletonId: response.skeletonId,
        sourcePhase: request.sourcePhase,
        blockedSeamIds: response.blockedSeamIds,
        deniedFieldIds: response.deniedFieldIds,
        warningReasons: response.warningReasons,
        proofLimitReasons: response.proofLimitReasons,
        executionAllowed: false,
        analyzerWiringAllowed: false,
        engineCallsAllowed: false,
        schedulerAllowed: false,
        persistenceAllowed: false,
        productOutputAllowed: false,
        productAdapterAllowed: false,
        savedAnalysisAllowed: false,
        recommendation: _phase34JRecommendation,
      ),
    ];
    final blockedSeams = preparation.blockedSeams
        .map(
          (seam) => DisabledAnalyzerAdapterRuntimeSkeletonBlockedSeam(
            blockedSeamId: seam.blockedSeamId,
            seamRole: seam.seamRole,
            targetSurface: seam.targetSurface,
            blocked: seam.blocked,
            blockReason: seam.blockReason,
            deniedFieldIds: seam.deniedFieldIds,
            recommendation: _phase34JRecommendation,
          ),
        )
        .toList(growable: false);
    final findings = const DisabledAnalyzerAdapterRuntimeSkeletonValidator()
        .validateDisabledRuntimeSkeleton(
          request: request,
          response: response,
          policy: policy,
          envelopes: envelopes,
          executionAttempt: attempt,
          blockedSeams: blockedSeams,
          nextRecommendation: _phase34JRecommendation,
        );
    final safeForPhase34J = findings.isEmpty;
    return DisabledAnalyzerAdapterRuntimeSkeletonResult(
      status: safeForPhase34J
          ? DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonStatus
                .disabledAnalyzerAdapterRuntimeSkeletonReadyWithWarnings
          : DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonStatus
                .blockedByPolicyBoundary,
      sourceDiagnosticStatus: diagnostic.status.wire,
      sourcePreparationStatus: preparation.status.wire,
      request: request,
      response: response,
      policy: policy,
      envelopes: envelopes,
      executionAttempt: attempt,
      blockedSeams: blockedSeams,
      findings: findings,
      safeForPhase34J: safeForPhase34J,
      nextRecommendation: safeForPhase34J
          ? _phase34JRecommendation
          : 'blockedByUnsafeDisabledRuntimeSkeleton',
    );
  }

  DisabledAnalyzerAdapterRuntimeSkeletonRequest buildDisabledRuntimeRequest({
    required DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticResult
    diagnostic,
    required ControlledAnalyzerAdapterRuntimePreparationResult preparation,
  }) {
    return DisabledAnalyzerAdapterRuntimeSkeletonRequest(
      skeletonId: _skeletonId,
      sourcePhase: 'Phase34H',
      sourceDiagnosticIds: _sorted(
        diagnostic.rows.map((row) => row.diagnosticRowId),
      ),
      sourcePreparationIds: <String>[preparation.input.preparationId],
      sourceCaseIds: preparation.input.sourceCaseIds,
      sourceActionIds: preparation.input.sourceActionIds,
      sourcePatchIds: preparation.input.sourcePatchIds,
      sourceRefinementIds: preparation.input.sourceRefinementIds,
      requestEnvelopeId: 'disabled-runtime-skeleton-request-envelope',
      policyId: 'disabled-analyzer-adapter-runtime-skeleton-policy',
      blockedSeamIds: preparation.blockedSeams
          .map((seam) => seam.blockedSeamId)
          .toList(growable: false),
      deniedFieldIds: preparation.policy.deniedFieldIds,
      supportAreaIds: preparation.input.supportAreaIds,
      warningReasons: _sorted(<String>[
        ...preparation.input.warningReasons,
        'disabledRuntimeSkeletonRefusesExecution',
      ]),
      proofLimitReasons: preparation.input.proofLimitReasons,
      androidProofIds: preparation.input.androidProofIds,
      ownerProofRequired: preparation.input.ownerProofRequired,
      executionAllowed: false,
      analyzerWiringAllowed: false,
      engineCallsAllowed: false,
      schedulerAllowed: false,
      persistenceAllowed: false,
      productOutputAllowed: false,
      productAdapterAllowed: false,
      savedAnalysisAllowed: false,
      recommendation: _phase34JRecommendation,
    );
  }

  DisabledAnalyzerAdapterRuntimeSkeletonResponse buildDisabledRuntimeResponse({
    required DisabledAnalyzerAdapterRuntimeSkeletonRequest request,
    required DisabledAnalyzerAdapterRuntimeSkeletonExecutionAttempt attempt,
  }) {
    return DisabledAnalyzerAdapterRuntimeSkeletonResponse(
      skeletonId: request.skeletonId,
      responseEnvelopeId: 'disabled-runtime-skeleton-response-envelope',
      requestEnvelopeId: request.requestEnvelopeId,
      executionAttemptId: attempt.executionAttemptId,
      executionRefusedReason: attempt.executionRefusedReason,
      blockedSeamIds: request.blockedSeamIds,
      deniedFieldIds: request.deniedFieldIds,
      warningReasons: request.warningReasons,
      proofLimitReasons: request.proofLimitReasons,
      executionAllowed: false,
      analyzerWiringAllowed: false,
      engineCallsAllowed: false,
      schedulerAllowed: false,
      persistenceAllowed: false,
      productOutputAllowed: false,
      productAdapterAllowed: false,
      savedAnalysisAllowed: false,
      recommendation: _phase34JRecommendation,
    );
  }

  DisabledAnalyzerAdapterRuntimeSkeletonExecutionAttempt
  createDisabledExecutionAttempt({
    required DisabledAnalyzerAdapterRuntimeSkeletonRequest request,
  }) {
    return DisabledAnalyzerAdapterRuntimeSkeletonExecutionAttempt(
      executionAttemptId: 'disabled-runtime-skeleton-execution-attempt',
      skeletonId: request.skeletonId,
      requestEnvelopeId: request.requestEnvelopeId,
      responseEnvelopeId: 'disabled-runtime-skeleton-response-envelope',
      executionAttempted: true,
      executionPerformed: false,
      executionRefused: true,
      executionRefusedReason: 'executionDisabledByPhase34IPolicy',
      blockedSeamIds: request.blockedSeamIds,
      deniedFieldIds: request.deniedFieldIds,
      warningReasons: request.warningReasons,
      proofLimitReasons: request.proofLimitReasons,
      recommendation: _phase34JRecommendation,
    );
  }

  DisabledAnalyzerAdapterRuntimeSkeletonExecutionAttempt refuseExecution(
    DisabledAnalyzerAdapterRuntimeSkeletonRequest request,
  ) {
    return createDisabledExecutionAttempt(request: request);
  }

  String renderDisabledRuntimeSnapshot(
    DisabledAnalyzerAdapterRuntimeSkeletonResult result,
  ) {
    return result.renderMarkdown();
  }

  List<String> validateDisabledRuntimeSkeleton(
    DisabledAnalyzerAdapterRuntimeSkeletonResult result,
  ) {
    return const DisabledAnalyzerAdapterRuntimeSkeletonValidator()
        .validateResult(result);
  }

  DisabledAnalyzerAdapterRuntimeSkeletonResult _blockedResult(
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticResult
    diagnostic,
    ControlledAnalyzerAdapterRuntimePreparationResult preparation,
  ) {
    final request = DisabledAnalyzerAdapterRuntimeSkeletonRequest(
      skeletonId: _skeletonId,
      sourcePhase: 'Phase34H',
      sourceDiagnosticIds: const <String>[],
      sourcePreparationIds: <String>[preparation.input.preparationId],
      sourceCaseIds: const <String>[],
      sourceActionIds: const <String>[],
      sourcePatchIds: const <String>[],
      sourceRefinementIds: const <String>[],
      requestEnvelopeId: 'disabled-runtime-skeleton-request-envelope',
      policyId: 'disabled-analyzer-adapter-runtime-skeleton-policy',
      blockedSeamIds: const <String>[],
      deniedFieldIds: preparation.policy.deniedFieldIds,
      supportAreaIds: const <String>[],
      warningReasons: const <String>['unsafePhase34HDiagnostic'],
      proofLimitReasons: const <String>[],
      androidProofIds: const <String>[],
      ownerProofRequired: false,
      executionAllowed: false,
      analyzerWiringAllowed: false,
      engineCallsAllowed: false,
      schedulerAllowed: false,
      persistenceAllowed: false,
      productOutputAllowed: false,
      productAdapterAllowed: false,
      savedAnalysisAllowed: false,
      recommendation: 'blockedByUnsafeDisabledRuntimeSkeleton',
    );
    final attempt = createDisabledExecutionAttempt(request: request);
    final response = buildDisabledRuntimeResponse(
      request: request,
      attempt: attempt,
    );
    final policy = DisabledAnalyzerAdapterRuntimeSkeletonPolicy.disabledDefault(
      deniedFieldIds: request.deniedFieldIds,
    );
    return DisabledAnalyzerAdapterRuntimeSkeletonResult(
      status: DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonStatus
          .blockedByUnsafeRuntimePreparationDiagnostic,
      sourceDiagnosticStatus: diagnostic.status.wire,
      sourcePreparationStatus: preparation.status.wire,
      request: request,
      response: response,
      policy: policy,
      envelopes: const <DisabledAnalyzerAdapterRuntimeSkeletonEnvelope>[],
      executionAttempt: attempt,
      blockedSeams: const <DisabledAnalyzerAdapterRuntimeSkeletonBlockedSeam>[],
      findings: const <String>[
        'unsafePhase34HControlledRuntimePreparationDiagnostic',
      ],
      safeForPhase34J: false,
      nextRecommendation: 'blockedByUnsafeDisabledRuntimeSkeleton',
    );
  }
}

class DisabledAnalyzerAdapterRuntimeSkeletonValidator {
  const DisabledAnalyzerAdapterRuntimeSkeletonValidator();

  List<String> validateResult(
    DisabledAnalyzerAdapterRuntimeSkeletonResult result,
  ) {
    return validateDisabledRuntimeSkeleton(
      request: result.request,
      response: result.response,
      policy: result.policy,
      envelopes: result.envelopes,
      executionAttempt: result.executionAttempt,
      blockedSeams: result.blockedSeams,
      nextRecommendation: result.nextRecommendation,
    );
  }

  List<String> validateDisabledRuntimeSkeleton({
    required DisabledAnalyzerAdapterRuntimeSkeletonRequest request,
    required DisabledAnalyzerAdapterRuntimeSkeletonResponse response,
    required DisabledAnalyzerAdapterRuntimeSkeletonPolicy policy,
    required Iterable<DisabledAnalyzerAdapterRuntimeSkeletonEnvelope> envelopes,
    required DisabledAnalyzerAdapterRuntimeSkeletonExecutionAttempt
    executionAttempt,
    required Iterable<DisabledAnalyzerAdapterRuntimeSkeletonBlockedSeam>
    blockedSeams,
    required String nextRecommendation,
  }) {
    final findings = <String>[
      if (nextRecommendation != _phase34JRecommendation)
        'missingPhase34JDisabledRuntimeSkeletonDiagnosticRecommendation',
      ...validateRequest(request),
      ...validateResponse(response),
      ...validatePolicy(policy),
      ...validateExecutionAttempt(executionAttempt),
    ];
    for (final envelope in envelopes) {
      findings.addAll(validateEnvelope(envelope));
    }
    for (final seam in blockedSeams) {
      findings.addAll(validateBlockedSeam(seam));
    }
    return _sorted(findings);
  }

  List<String> validateRequest(
    DisabledAnalyzerAdapterRuntimeSkeletonRequest request,
  ) {
    return _validateBoundary(
      sourceCaseIds: request.sourceCaseIds,
      supportAreaIds: request.supportAreaIds,
      proofLimitReasons: request.proofLimitReasons,
      androidProofIds: request.androidProofIds,
      ownerProofRequired: request.ownerProofRequired,
      deniedFieldIds: request.deniedFieldIds,
      executionAllowed: request.executionAllowed,
      analyzerWiringAllowed: request.analyzerWiringAllowed,
      engineCallsAllowed: request.engineCallsAllowed,
      schedulerAllowed: request.schedulerAllowed,
      persistenceAllowed: request.persistenceAllowed,
      productOutputAllowed: request.productOutputAllowed,
      productAdapterAllowed: request.productAdapterAllowed,
      savedAnalysisAllowed: request.savedAnalysisAllowed,
      recommendation: request.recommendation,
    );
  }

  List<String> validateResponse(
    DisabledAnalyzerAdapterRuntimeSkeletonResponse response,
  ) {
    return _validateBoundary(
      sourceCaseIds: const <String>[],
      supportAreaIds: const <String>[],
      proofLimitReasons: response.proofLimitReasons,
      androidProofIds: const <String>[],
      ownerProofRequired: false,
      deniedFieldIds: response.deniedFieldIds,
      executionAllowed: response.executionAllowed,
      analyzerWiringAllowed: response.analyzerWiringAllowed,
      engineCallsAllowed: response.engineCallsAllowed,
      schedulerAllowed: response.schedulerAllowed,
      persistenceAllowed: response.persistenceAllowed,
      productOutputAllowed: response.productOutputAllowed,
      productAdapterAllowed: response.productAdapterAllowed,
      savedAnalysisAllowed: response.savedAnalysisAllowed,
      recommendation: response.recommendation,
    );
  }

  List<String> validatePolicy(
    DisabledAnalyzerAdapterRuntimeSkeletonPolicy policy,
  ) {
    final findings = _validateBoundary(
      sourceCaseIds: const <String>[],
      supportAreaIds: const <String>[],
      proofLimitReasons: const <String>[],
      androidProofIds: const <String>[],
      ownerProofRequired: false,
      deniedFieldIds: policy.deniedFieldIds,
      executionAllowed: policy.executionAllowed,
      analyzerWiringAllowed: policy.analyzerWiringAllowed,
      engineCallsAllowed: policy.engineCallsAllowed,
      schedulerAllowed: policy.schedulerAllowed,
      persistenceAllowed: policy.persistenceAllowed,
      productOutputAllowed: policy.productOutputAllowed,
      productAdapterAllowed: policy.productAdapterAllowed,
      savedAnalysisAllowed: policy.savedAnalysisAllowed,
      recommendation: _phase34JRecommendation,
    );
    return _sorted(<String>[
      ...findings,
      if (policy.uiAllowed || policy.backendAllowed)
        'uiBackendActivationEnabled',
      if (policy.cacheAllowed || policy.databaseAllowed)
        'cacheDatabaseWriteEnabled',
      if (policy.executableRuntimeAllowed) 'executableRuntimeEnabled',
    ]);
  }

  List<String> validateEnvelope(
    DisabledAnalyzerAdapterRuntimeSkeletonEnvelope envelope,
  ) {
    return _validateBoundary(
      sourceCaseIds: const <String>[],
      supportAreaIds: const <String>[],
      proofLimitReasons: envelope.proofLimitReasons,
      androidProofIds: const <String>[],
      ownerProofRequired: false,
      deniedFieldIds: envelope.deniedFieldIds,
      executionAllowed: envelope.executionAllowed,
      analyzerWiringAllowed: envelope.analyzerWiringAllowed,
      engineCallsAllowed: envelope.engineCallsAllowed,
      schedulerAllowed: envelope.schedulerAllowed,
      persistenceAllowed: envelope.persistenceAllowed,
      productOutputAllowed: envelope.productOutputAllowed,
      productAdapterAllowed: envelope.productAdapterAllowed,
      savedAnalysisAllowed: envelope.savedAnalysisAllowed,
      recommendation: envelope.recommendation,
    );
  }

  List<String> validateExecutionAttempt(
    DisabledAnalyzerAdapterRuntimeSkeletonExecutionAttempt attempt,
  ) {
    return _sorted(<String>[
      if (attempt.recommendation != _phase34JRecommendation)
        'missingPhase34JDisabledRuntimeSkeletonDiagnosticRecommendation',
      if (!attempt.executionAttempted) 'disabledExecutionAttemptMissing',
      if (!attempt.executionRefused) 'disabledExecutionAttemptNotRefused',
      if (attempt.executionPerformed) 'runtimeExecutionResultEnabled',
      if (attempt.executionRefusedReason.trim().isEmpty)
        'missingExecutionRefusedReason',
      if (_activeDeniedFieldIds(attempt.deniedFieldIds).isNotEmpty)
        'activeDeniedFields',
    ]);
  }

  List<String> validateBlockedSeam(
    DisabledAnalyzerAdapterRuntimeSkeletonBlockedSeam seam,
  ) {
    return _sorted(<String>[
      if (!seam.blocked) 'blockedSeamActivated',
      if (_activeDeniedFieldIds(seam.deniedFieldIds).isNotEmpty)
        'activeDeniedFields',
      if (seam.recommendation != _phase34JRecommendation)
        'missingPhase34JDisabledRuntimeSkeletonDiagnosticRecommendation',
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
      if (recommendation != _phase34JRecommendation)
        'missingPhase34JDisabledRuntimeSkeletonDiagnosticRecommendation',
      if (executionAllowed) 'executionAllowedEnabled',
      if (analyzerWiringAllowed) 'analyzerWiringEnabled',
      if (engineCallsAllowed) 'engineCallsEnabled',
      if (schedulerAllowed) 'schedulerExecutionEnabled',
      if (persistenceAllowed) 'persistenceWriteEnabled',
      if (productOutputAllowed) 'productOutputEnabled',
      if (productAdapterAllowed) 'productAdapterEnabled',
      if (savedAnalysisAllowed) 'savedAnalysisIntegrationEnabled',
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

int _countUnblockedDeniedSeams(
  Iterable<DisabledAnalyzerAdapterRuntimeSkeletonBlockedSeam> seams,
) {
  return seams.where((seam) => !seam.blocked).length;
}

List<String> _activeDeniedFieldIds(Iterable<String> deniedFieldIds) {
  return deniedFieldIds
      .where((id) => id.startsWith('active:'))
      .map((id) => id.substring('active:'.length))
      .toList();
}

bool _isQuietSupport(Iterable<String> supportAreaIds) {
  return supportAreaIds.any(
    (id) => id == 'quietMove' || id == 'quietPreparatoryMove',
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

const _skeletonId = 'disabled-analyzer-adapter-runtime-skeleton';
const _requestEnvelopeRole = 'disabledRuntimeRequestEnvelope';
const _responseEnvelopeRole = 'disabledRuntimeResponseEnvelope';
const _phase34JRecommendation =
    'runDisabledAnalyzerAdapterRuntimeSkeletonDiagnostic';
const _pvMultiPvBoundaryCaseId = 'pv-multipv-support-boundary-32e';

const _capturedAndroidProofIds = <String>{
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
};

const _phase32ECaseIds = <String>{
  'king-safety-mating-net-pressure-32e',
  'endgame-candidate-spread-pressure-32e',
  'budget-pressure-depth-limited-32e',
  'pv-multipv-support-boundary-32e',
};

const _productFields = <String>{'productLabel', 'productOutput'};
const _finalLabelFields = <String>{'finalMoveLabel'};
const _classifierFields = <String>{
  'classifierLabels',
  'brilliantGreatMiss',
  'brilliantGreatMissStyleLabels',
  'bestGoodInaccuracyMistakeBlunder',
};
const _scoreFields = <String>{'numericMoveScore', 'aggregateScore'};
const _rankingMetricFields = <String>{
  'moveRanking',
  'officialMetric',
  'officialAccuracy',
  'accuracy',
  'acpl',
};

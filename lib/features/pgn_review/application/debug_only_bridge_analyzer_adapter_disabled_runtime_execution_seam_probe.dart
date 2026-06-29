import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton_diagnostic.dart';

const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeVersion =
    'debug-only-bridge-analyzer-adapter-disabled-runtime-execution-seam-probe-v1';

enum DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeStatus {
  disabledAnalyzerAdapterRuntimeExecutionSeamProbeReadyWithWarnings(
    'disabledAnalyzerAdapterRuntimeExecutionSeamProbeReadyWithWarnings',
  ),
  disabledAnalyzerAdapterRuntimeExecutionSeamProbeReadyClean(
    'disabledAnalyzerAdapterRuntimeExecutionSeamProbeReadyClean',
  ),
  blockedByUnsafeRuntimeExecutionPreflightDiagnostic(
    'blockedByUnsafeRuntimeExecutionPreflightDiagnostic',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidDisabledRuntimeExecutionSeamProbe(
    'invalidDisabledRuntimeExecutionSeamProbe',
  );

  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeStatus(
    this.wire,
  );

  final String wire;
}

class DisabledAnalyzerAdapterRuntimeExecutionSeamProbeInput {
  const DisabledAnalyzerAdapterRuntimeExecutionSeamProbeInput({
    required this.seamProbeId,
    required this.sourcePhase,
    required this.sourceDiagnosticIds,
    required this.sourcePreflightIds,
    required this.sourceSkeletonIds,
    required this.sourcePreparationIds,
    required this.sourceCaseIds,
    required this.sourceActionIds,
    required this.sourcePatchIds,
    required this.sourceRefinementIds,
    required this.requestId,
    required this.responseId,
    required this.attemptId,
    required this.boundaryIds,
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

  final String seamProbeId;
  final String sourcePhase;
  final List<String> sourceDiagnosticIds;
  final List<String> sourcePreflightIds;
  final List<String> sourceSkeletonIds;
  final List<String> sourcePreparationIds;
  final List<String> sourceCaseIds;
  final List<String> sourceActionIds;
  final List<String> sourcePatchIds;
  final List<String> sourceRefinementIds;
  final String requestId;
  final String responseId;
  final String attemptId;
  final List<String> boundaryIds;
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
  final bool analyzerRuntimeInputProduced;
  final bool analyzerWiringAllowed;
  final bool engineCallsAllowed;
  final bool schedulerAllowed;
  final bool persistenceAllowed;
  final bool productOutputAllowed;
  final bool productAdapterAllowed;
  final bool savedAnalysisAllowed;
  final String recommendation;

  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeInput copyWith({
    String? seamProbeId,
    String? sourcePhase,
    List<String>? sourceDiagnosticIds,
    List<String>? sourcePreflightIds,
    List<String>? sourceSkeletonIds,
    List<String>? sourcePreparationIds,
    List<String>? sourceCaseIds,
    List<String>? sourceActionIds,
    List<String>? sourcePatchIds,
    List<String>? sourceRefinementIds,
    String? requestId,
    String? responseId,
    String? attemptId,
    List<String>? boundaryIds,
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
    return DisabledAnalyzerAdapterRuntimeExecutionSeamProbeInput(
      seamProbeId: seamProbeId ?? this.seamProbeId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      sourceDiagnosticIds: sourceDiagnosticIds ?? this.sourceDiagnosticIds,
      sourcePreflightIds: sourcePreflightIds ?? this.sourcePreflightIds,
      sourceSkeletonIds: sourceSkeletonIds ?? this.sourceSkeletonIds,
      sourcePreparationIds: sourcePreparationIds ?? this.sourcePreparationIds,
      sourceCaseIds: sourceCaseIds ?? this.sourceCaseIds,
      sourceActionIds: sourceActionIds ?? this.sourceActionIds,
      sourcePatchIds: sourcePatchIds ?? this.sourcePatchIds,
      sourceRefinementIds: sourceRefinementIds ?? this.sourceRefinementIds,
      requestId: requestId ?? this.requestId,
      responseId: responseId ?? this.responseId,
      attemptId: attemptId ?? this.attemptId,
      boundaryIds: boundaryIds ?? this.boundaryIds,
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
      'seamProbeId': seamProbeId,
      'sourcePhase': sourcePhase,
      'sourceDiagnosticIds': sourceDiagnosticIds,
      'sourcePreflightIds': sourcePreflightIds,
      'sourceSkeletonIds': sourceSkeletonIds,
      'sourcePreparationIds': sourcePreparationIds,
      'sourceCaseIds': sourceCaseIds,
      'sourceActionIds': sourceActionIds,
      'sourcePatchIds': sourcePatchIds,
      'sourceRefinementIds': sourceRefinementIds,
      'requestId': requestId,
      'responseId': responseId,
      'attemptId': attemptId,
      'boundaryIds': boundaryIds,
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

class DisabledAnalyzerAdapterRuntimeExecutionSeamProbeRequest {
  const DisabledAnalyzerAdapterRuntimeExecutionSeamProbeRequest({
    required this.seamProbeId,
    required this.requestId,
    required this.sourcePhase,
    required this.sourceDiagnosticIds,
    required this.sourcePreflightIds,
    required this.sourceSkeletonIds,
    required this.sourcePreparationIds,
    required this.sourceCaseIds,
    required this.sourceActionIds,
    required this.sourcePatchIds,
    required this.sourceRefinementIds,
    required this.boundaryIds,
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

  final String seamProbeId;
  final String requestId;
  final String sourcePhase;
  final List<String> sourceDiagnosticIds;
  final List<String> sourcePreflightIds;
  final List<String> sourceSkeletonIds;
  final List<String> sourcePreparationIds;
  final List<String> sourceCaseIds;
  final List<String> sourceActionIds;
  final List<String> sourcePatchIds;
  final List<String> sourceRefinementIds;
  final List<String> boundaryIds;
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
  final bool analyzerRuntimeInputProduced;
  final bool analyzerWiringAllowed;
  final bool engineCallsAllowed;
  final bool schedulerAllowed;
  final bool persistenceAllowed;
  final bool productOutputAllowed;
  final bool productAdapterAllowed;
  final bool savedAnalysisAllowed;
  final String recommendation;

  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeRequest copyWith({
    bool? seamProbePerformed,
    bool? executionPerformed,
    bool? executionAllowed,
    bool? runtimeExecutionApproved,
    bool? analyzerRuntimeInputProduced,
    bool? analyzerWiringAllowed,
    bool? engineCallsAllowed,
    bool? schedulerAllowed,
    bool? persistenceAllowed,
    bool? productOutputAllowed,
    bool? productAdapterAllowed,
    bool? savedAnalysisAllowed,
    List<String>? deniedFieldIds,
    List<String>? supportAreaIds,
    List<String>? proofLimitReasons,
    List<String>? androidProofIds,
    bool? ownerProofRequired,
    String? recommendation,
  }) {
    return DisabledAnalyzerAdapterRuntimeExecutionSeamProbeRequest(
      seamProbeId: seamProbeId,
      requestId: requestId,
      sourcePhase: sourcePhase,
      sourceDiagnosticIds: sourceDiagnosticIds,
      sourcePreflightIds: sourcePreflightIds,
      sourceSkeletonIds: sourceSkeletonIds,
      sourcePreparationIds: sourcePreparationIds,
      sourceCaseIds: sourceCaseIds,
      sourceActionIds: sourceActionIds,
      sourcePatchIds: sourcePatchIds,
      sourceRefinementIds: sourceRefinementIds,
      boundaryIds: boundaryIds,
      blockedReasonIds: blockedReasonIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      supportAreaIds: supportAreaIds ?? this.supportAreaIds,
      warningReasons: warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      androidProofIds: androidProofIds ?? this.androidProofIds,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      seamProbeRequested: seamProbeRequested,
      seamProbePerformed: seamProbePerformed ?? this.seamProbePerformed,
      executionPerformed: executionPerformed ?? this.executionPerformed,
      executionAllowed: executionAllowed ?? this.executionAllowed,
      runtimeExecutionApproved:
          runtimeExecutionApproved ?? this.runtimeExecutionApproved,
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
      'seamProbeId': seamProbeId,
      'requestId': requestId,
      'sourcePhase': sourcePhase,
      'sourceDiagnosticIds': sourceDiagnosticIds,
      'sourcePreflightIds': sourcePreflightIds,
      'sourceSkeletonIds': sourceSkeletonIds,
      'sourcePreparationIds': sourcePreparationIds,
      'sourceCaseIds': sourceCaseIds,
      'sourceActionIds': sourceActionIds,
      'sourcePatchIds': sourcePatchIds,
      'sourceRefinementIds': sourceRefinementIds,
      'boundaryIds': boundaryIds,
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

class DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResponse {
  const DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResponse({
    required this.seamProbeId,
    required this.requestId,
    required this.responseId,
    required this.attemptId,
    required this.responseStatus,
    required this.refusedReason,
    required this.boundaryIds,
    required this.blockedReasonIds,
    required this.deniedFieldIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.seamProbePerformed,
    required this.executionPerformed,
    required this.executionAllowed,
    required this.runtimeExecutionApproved,
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

  final String seamProbeId;
  final String requestId;
  final String responseId;
  final String attemptId;
  final String responseStatus;
  final String refusedReason;
  final List<String> boundaryIds;
  final List<String> blockedReasonIds;
  final List<String> deniedFieldIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final bool seamProbePerformed;
  final bool executionPerformed;
  final bool executionAllowed;
  final bool runtimeExecutionApproved;
  final bool analyzerRuntimeInputProduced;
  final bool analyzerWiringAllowed;
  final bool engineCallsAllowed;
  final bool schedulerAllowed;
  final bool persistenceAllowed;
  final bool productOutputAllowed;
  final bool productAdapterAllowed;
  final bool savedAnalysisAllowed;
  final String recommendation;

  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResponse copyWith({
    bool? seamProbePerformed,
    bool? executionPerformed,
    bool? executionAllowed,
    bool? runtimeExecutionApproved,
    bool? analyzerRuntimeInputProduced,
    bool? analyzerWiringAllowed,
    bool? engineCallsAllowed,
    bool? schedulerAllowed,
    bool? persistenceAllowed,
    bool? productOutputAllowed,
    bool? productAdapterAllowed,
    bool? savedAnalysisAllowed,
    List<String>? deniedFieldIds,
    String? recommendation,
  }) {
    return DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResponse(
      seamProbeId: seamProbeId,
      requestId: requestId,
      responseId: responseId,
      attemptId: attemptId,
      responseStatus: responseStatus,
      refusedReason: refusedReason,
      boundaryIds: boundaryIds,
      blockedReasonIds: blockedReasonIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      warningReasons: warningReasons,
      proofLimitReasons: proofLimitReasons,
      seamProbePerformed: seamProbePerformed ?? this.seamProbePerformed,
      executionPerformed: executionPerformed ?? this.executionPerformed,
      executionAllowed: executionAllowed ?? this.executionAllowed,
      runtimeExecutionApproved:
          runtimeExecutionApproved ?? this.runtimeExecutionApproved,
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
      'seamProbeId': seamProbeId,
      'requestId': requestId,
      'responseId': responseId,
      'attemptId': attemptId,
      'responseStatus': responseStatus,
      'refusedReason': refusedReason,
      'boundaryIds': boundaryIds,
      'blockedReasonIds': blockedReasonIds,
      'deniedFieldIds': deniedFieldIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'seamProbePerformed': seamProbePerformed,
      'executionPerformed': executionPerformed,
      'executionAllowed': executionAllowed,
      'runtimeExecutionApproved': runtimeExecutionApproved,
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

class DisabledAnalyzerAdapterRuntimeExecutionSeamProbePolicy {
  const DisabledAnalyzerAdapterRuntimeExecutionSeamProbePolicy({
    required this.policyId,
    required this.deniedFieldIds,
    required this.executionAllowed,
    required this.runtimeExecutionApproved,
    required this.analyzerRuntimeInputAllowed,
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

  factory DisabledAnalyzerAdapterRuntimeExecutionSeamProbePolicy.disabled({
    required Iterable<String> deniedFieldIds,
  }) {
    return DisabledAnalyzerAdapterRuntimeExecutionSeamProbePolicy(
      policyId: _policyId,
      deniedFieldIds: _sorted(deniedFieldIds),
      executionAllowed: false,
      runtimeExecutionApproved: false,
      analyzerRuntimeInputAllowed: false,
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
  final bool executionAllowed;
  final bool runtimeExecutionApproved;
  final bool analyzerRuntimeInputAllowed;
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

  DisabledAnalyzerAdapterRuntimeExecutionSeamProbePolicy copyWith({
    List<String>? deniedFieldIds,
    bool? executionAllowed,
    bool? runtimeExecutionApproved,
    bool? analyzerRuntimeInputAllowed,
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
    return DisabledAnalyzerAdapterRuntimeExecutionSeamProbePolicy(
      policyId: policyId,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      executionAllowed: executionAllowed ?? this.executionAllowed,
      runtimeExecutionApproved:
          runtimeExecutionApproved ?? this.runtimeExecutionApproved,
      analyzerRuntimeInputAllowed:
          analyzerRuntimeInputAllowed ?? this.analyzerRuntimeInputAllowed,
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
      'executionAllowed': executionAllowed,
      'runtimeExecutionApproved': runtimeExecutionApproved,
      'analyzerRuntimeInputAllowed': analyzerRuntimeInputAllowed,
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

class DisabledAnalyzerAdapterRuntimeExecutionSeamProbeAttempt {
  const DisabledAnalyzerAdapterRuntimeExecutionSeamProbeAttempt({
    required this.attemptId,
    required this.requestId,
    required this.seamProbeRequested,
    required this.seamProbePerformed,
    required this.executionPerformed,
    required this.executionAllowed,
    required this.runtimeExecutionApproved,
    required this.analyzerRuntimeInputProduced,
    required this.refused,
    required this.refusedReason,
    required this.blockedReasonIds,
    required this.deniedFieldIds,
    required this.recommendation,
  });

  final String attemptId;
  final String requestId;
  final bool seamProbeRequested;
  final bool seamProbePerformed;
  final bool executionPerformed;
  final bool executionAllowed;
  final bool runtimeExecutionApproved;
  final bool analyzerRuntimeInputProduced;
  final bool refused;
  final String refusedReason;
  final List<String> blockedReasonIds;
  final List<String> deniedFieldIds;
  final String recommendation;

  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeAttempt copyWith({
    bool? seamProbeRequested,
    bool? seamProbePerformed,
    bool? executionPerformed,
    bool? executionAllowed,
    bool? runtimeExecutionApproved,
    bool? analyzerRuntimeInputProduced,
    bool? refused,
    List<String>? deniedFieldIds,
    String? recommendation,
  }) {
    return DisabledAnalyzerAdapterRuntimeExecutionSeamProbeAttempt(
      attemptId: attemptId,
      requestId: requestId,
      seamProbeRequested: seamProbeRequested ?? this.seamProbeRequested,
      seamProbePerformed: seamProbePerformed ?? this.seamProbePerformed,
      executionPerformed: executionPerformed ?? this.executionPerformed,
      executionAllowed: executionAllowed ?? this.executionAllowed,
      runtimeExecutionApproved:
          runtimeExecutionApproved ?? this.runtimeExecutionApproved,
      analyzerRuntimeInputProduced:
          analyzerRuntimeInputProduced ?? this.analyzerRuntimeInputProduced,
      refused: refused ?? this.refused,
      refusedReason: refusedReason,
      blockedReasonIds: blockedReasonIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'attemptId': attemptId,
      'requestId': requestId,
      'seamProbeRequested': seamProbeRequested,
      'seamProbePerformed': seamProbePerformed,
      'executionPerformed': executionPerformed,
      'executionAllowed': executionAllowed,
      'runtimeExecutionApproved': runtimeExecutionApproved,
      'analyzerRuntimeInputProduced': analyzerRuntimeInputProduced,
      'refused': refused,
      'refusedReason': refusedReason,
      'blockedReasonIds': blockedReasonIds,
      'deniedFieldIds': deniedFieldIds,
      'recommendation': recommendation,
    };
  }
}

class DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBoundary {
  const DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBoundary({
    required this.boundaryId,
    required this.boundaryRole,
    required this.targetSurface,
    required this.blocked,
    required this.deniedFieldIds,
    required this.recommendation,
  });

  final String boundaryId;
  final String boundaryRole;
  final String targetSurface;
  final bool blocked;
  final List<String> deniedFieldIds;
  final String recommendation;

  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBoundary copyWith({
    bool? blocked,
    List<String>? deniedFieldIds,
    String? recommendation,
  }) {
    return DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBoundary(
      boundaryId: boundaryId,
      boundaryRole: boundaryRole,
      targetSurface: targetSurface,
      blocked: blocked ?? this.blocked,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'boundaryId': boundaryId,
      'boundaryRole': boundaryRole,
      'targetSurface': targetSurface,
      'blocked': blocked,
      'deniedFieldIds': deniedFieldIds,
      'recommendation': recommendation,
    };
  }
}

class DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBlockedReason {
  const DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBlockedReason({
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

  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBlockedReason copyWith({
    bool? blocked,
    List<String>? deniedFieldIds,
    String? recommendation,
  }) {
    return DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBlockedReason(
      blockedReasonId: blockedReasonId,
      blockedSurface: blockedSurface,
      blocked: blocked ?? this.blocked,
      reason: reason,
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

class DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult {
  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult({
    required this.status,
    required this.sourcePreflightDiagnosticStatus,
    required this.sourcePreflightStatus,
    required this.sourceDisabledRuntimeSkeletonDiagnosticStatus,
    required this.sourceDisabledRuntimeSkeletonStatus,
    required this.sourceRuntimePreparationDiagnosticStatus,
    required this.input,
    required this.request,
    required this.response,
    required this.policy,
    required this.attempt,
    required this.boundaries,
    required this.blockedReasons,
    required this.findings,
    required this.safeForPhase34N,
    required this.nextRecommendation,
  }) : seamProbeAttemptCount = attempt.seamProbeRequested ? 1 : 0,
       seamProbePerformedCount =
           (attempt.seamProbePerformed ? 1 : 0) +
           (request.seamProbePerformed ? 1 : 0) +
           (response.seamProbePerformed ? 1 : 0),
       totalBoundaries = boundaries.length,
       blockedBoundaryCount = boundaries
           .where((boundary) => boundary.blocked)
           .length,
       totalBlockedReasons = blockedReasons.length,
       deniedFieldCount = _sorted(policy.deniedFieldIds).length,
       ownerProofQueueCount = input.ownerProofRequired ? 1 : 0,
       activeDeniedFieldCount =
           _activeDeniedFieldIds(input.deniedFieldIds).length +
           _activeDeniedFieldIds(policy.deniedFieldIds).length +
           _activeDeniedFieldIds(request.deniedFieldIds).length +
           _activeDeniedFieldIds(response.deniedFieldIds).length +
           _activeDeniedFieldIds(attempt.deniedFieldIds).length +
           boundaries
               .expand(
                 (boundary) => _activeDeniedFieldIds(boundary.deniedFieldIds),
               )
               .length +
           blockedReasons
               .expand((reason) => _activeDeniedFieldIds(reason.deniedFieldIds))
               .length,
       runtimeExecutionCount =
           (input.executionAllowed ? 1 : 0) +
           (input.executionPerformed ? 1 : 0) +
           (request.executionAllowed ? 1 : 0) +
           (request.executionPerformed ? 1 : 0) +
           (response.executionAllowed ? 1 : 0) +
           (response.executionPerformed ? 1 : 0) +
           (policy.executionAllowed ? 1 : 0) +
           (attempt.executionAllowed ? 1 : 0) +
           (attempt.executionPerformed ? 1 : 0),
       runtimeExecutionApprovedCount =
           (input.runtimeExecutionApproved ? 1 : 0) +
           (request.runtimeExecutionApproved ? 1 : 0) +
           (response.runtimeExecutionApproved ? 1 : 0) +
           (policy.runtimeExecutionApproved ? 1 : 0) +
           (attempt.runtimeExecutionApproved ? 1 : 0),
       analyzerRuntimeInputCount =
           (input.analyzerRuntimeInputProduced ? 1 : 0) +
           (request.analyzerRuntimeInputProduced ? 1 : 0) +
           (response.analyzerRuntimeInputProduced ? 1 : 0) +
           (policy.analyzerRuntimeInputAllowed ? 1 : 0) +
           (attempt.analyzerRuntimeInputProduced ? 1 : 0),
       analyzerWiringCount =
           (input.analyzerWiringAllowed ? 1 : 0) +
           (request.analyzerWiringAllowed ? 1 : 0) +
           (response.analyzerWiringAllowed ? 1 : 0) +
           (policy.analyzerWiringAllowed ? 1 : 0),
       executableRuntimeCount = _activeDeniedFieldIds(
         policy.deniedFieldIds,
       ).where((id) => id == 'runtimeExecutionResult').length,
       engineCallCount =
           (input.engineCallsAllowed ? 1 : 0) +
           (request.engineCallsAllowed ? 1 : 0) +
           (response.engineCallsAllowed ? 1 : 0) +
           (policy.engineCallsAllowed ? 1 : 0),
       schedulerExecutionCount =
           (input.schedulerAllowed ? 1 : 0) +
           (request.schedulerAllowed ? 1 : 0) +
           (response.schedulerAllowed ? 1 : 0) +
           (policy.schedulerAllowed ? 1 : 0),
       persistenceWriteCount =
           (input.persistenceAllowed ? 1 : 0) +
           (request.persistenceAllowed ? 1 : 0) +
           (response.persistenceAllowed ? 1 : 0) +
           (policy.persistenceAllowed ? 1 : 0),
       productOutputCount =
           (input.productOutputAllowed ? 1 : 0) +
           (request.productOutputAllowed ? 1 : 0) +
           (response.productOutputAllowed ? 1 : 0) +
           (policy.productOutputAllowed ? 1 : 0),
       productAdapterCount =
           (input.productAdapterAllowed ? 1 : 0) +
           (request.productAdapterAllowed ? 1 : 0) +
           (response.productAdapterAllowed ? 1 : 0) +
           (policy.productAdapterAllowed ? 1 : 0),
       savedAnalysisIntegrationCount =
           (input.savedAnalysisAllowed ? 1 : 0) +
           (request.savedAnalysisAllowed ? 1 : 0) +
           (response.savedAnalysisAllowed ? 1 : 0) +
           (policy.savedAnalysisAllowed ? 1 : 0),
       uiBackendCacheDatabaseActivationCount =
           (policy.uiAllowed ? 1 : 0) +
           (policy.backendAllowed ? 1 : 0) +
           (policy.cacheAllowed ? 1 : 0) +
           (policy.databaseAllowed ? 1 : 0),
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

  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeStatus
  status;
  final String sourcePreflightDiagnosticStatus;
  final String sourcePreflightStatus;
  final String sourceDisabledRuntimeSkeletonDiagnosticStatus;
  final String sourceDisabledRuntimeSkeletonStatus;
  final String sourceRuntimePreparationDiagnosticStatus;
  final DisabledAnalyzerAdapterRuntimeExecutionSeamProbeInput input;
  final DisabledAnalyzerAdapterRuntimeExecutionSeamProbeRequest request;
  final DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResponse response;
  final DisabledAnalyzerAdapterRuntimeExecutionSeamProbePolicy policy;
  final DisabledAnalyzerAdapterRuntimeExecutionSeamProbeAttempt attempt;
  final List<DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBoundary>
  boundaries;
  final List<DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBlockedReason>
  blockedReasons;
  final List<String> findings;
  final bool safeForPhase34N;
  final String nextRecommendation;
  final int seamProbeAttemptCount;
  final int seamProbePerformedCount;
  final int totalBoundaries;
  final int blockedBoundaryCount;
  final int totalBlockedReasons;
  final int deniedFieldCount;
  final int ownerProofQueueCount;
  final int activeDeniedFieldCount;
  final int runtimeExecutionCount;
  final int runtimeExecutionApprovedCount;
  final int analyzerRuntimeInputCount;
  final int analyzerWiringCount;
  final int executableRuntimeCount;
  final int engineCallCount;
  final int schedulerExecutionCount;
  final int persistenceWriteCount;
  final int productOutputCount;
  final int productAdapterCount;
  final int savedAnalysisIntegrationCount;
  final int uiBackendCacheDatabaseActivationCount;
  final int phase32EProofClaimCount;
  final int unprovenAndroidProofCount;
  late final int unsafeCount;
  late final int blockerCount;
  late final int criticalCount;

  bool get hasUnsafePolicyViolation =>
      !safeForPhase34N ||
      findings.isNotEmpty ||
      seamProbePerformedCount > 0 ||
      runtimeExecutionCount > 0 ||
      runtimeExecutionApprovedCount > 0 ||
      analyzerRuntimeInputCount > 0 ||
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
      seamProbeAttemptCount < 1 ||
      blockedBoundaryCount != totalBoundaries;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Disabled Analyzer Adapter Runtime Execution Seam Probe')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeVersion',
      )
      ..writeln('- seam probe status: ${status.wire}')
      ..writeln(
        '- source preflight diagnostic status: $sourcePreflightDiagnosticStatus',
      )
      ..writeln('- source preflight status: $sourcePreflightStatus')
      ..writeln(
        '- source disabled runtime skeleton diagnostic status: $sourceDisabledRuntimeSkeletonDiagnosticStatus',
      )
      ..writeln(
        '- source disabled runtime skeleton status: $sourceDisabledRuntimeSkeletonStatus',
      )
      ..writeln('- safe for Phase 34N: $safeForPhase34N')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln()
      ..writeln('## Seam Probe Request Summary')
      ..writeln('- seam probe ID: ${request.seamProbeId}')
      ..writeln('- request ID: ${request.requestId}')
      ..writeln('- seamProbeRequested: ${request.seamProbeRequested}')
      ..writeln('- seamProbePerformed: ${request.seamProbePerformed}')
      ..writeln('- executionPerformed: ${request.executionPerformed}')
      ..writeln(
        '- runtimeExecutionApproved: ${request.runtimeExecutionApproved}',
      )
      ..writeln(
        '- analyzerRuntimeInputProduced: ${request.analyzerRuntimeInputProduced}',
      )
      ..writeln()
      ..writeln('## Seam Probe Response Summary')
      ..writeln('- response ID: ${response.responseId}')
      ..writeln('- response status: ${response.responseStatus}')
      ..writeln('- refused reason: ${response.refusedReason}')
      ..writeln('- seamProbePerformed: ${response.seamProbePerformed}')
      ..writeln('- executionPerformed: ${response.executionPerformed}')
      ..writeln(
        '- analyzerRuntimeInputProduced: ${response.analyzerRuntimeInputProduced}',
      )
      ..writeln()
      ..writeln('## Refused Seam Probe Attempt Summary')
      ..writeln('- attempt ID: ${attempt.attemptId}')
      ..writeln('- seamProbeRequested: ${attempt.seamProbeRequested}')
      ..writeln('- seamProbePerformed: ${attempt.seamProbePerformed}')
      ..writeln('- executionPerformed: ${attempt.executionPerformed}')
      ..writeln(
        '- runtimeExecutionApproved: ${attempt.runtimeExecutionApproved}',
      )
      ..writeln(
        '- analyzerRuntimeInputProduced: ${attempt.analyzerRuntimeInputProduced}',
      )
      ..writeln('- refused: ${attempt.refused}')
      ..writeln('- refused reason: ${attempt.refusedReason}')
      ..writeln()
      ..writeln('## Boundary Summary')
      ..writeln('| Boundary | Target surface | Blocked |')
      ..writeln('| --- | --- | --- |');
    for (final boundary in boundaries) {
      buffer.writeln(
        '| ${boundary.boundaryId} | ${boundary.targetSurface} | ${boundary.blocked} |',
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
      ..writeln('- denied field count: $deniedFieldCount')
      ..writeln('- denied field IDs: ${_ids(policy.deniedFieldIds)}')
      ..writeln()
      ..writeln('## Proof Boundary Summary')
      ..writeln('- android proof IDs: ${_ids(input.androidProofIds)}')
      ..writeln('- owner proof required: ${input.ownerProofRequired}')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Safety Summary')
      ..writeln('- seam probe attempt count: $seamProbeAttemptCount')
      ..writeln('- seam probe performed count: $seamProbePerformedCount')
      ..writeln('- runtime execution count: $runtimeExecutionCount')
      ..writeln(
        '- runtime execution approved count: $runtimeExecutionApprovedCount',
      )
      ..writeln('- analyzer runtime input count: $analyzerRuntimeInputCount')
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
      ..writeln('- safe for Phase 34N: $safeForPhase34N')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- findings: ${_ids(findings)}')
      ..writeln();
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent(' ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeVersion,
      'status': status.wire,
      'sourcePreflightDiagnosticStatus': sourcePreflightDiagnosticStatus,
      'sourcePreflightStatus': sourcePreflightStatus,
      'sourceDisabledRuntimeSkeletonDiagnosticStatus':
          sourceDisabledRuntimeSkeletonDiagnosticStatus,
      'sourceDisabledRuntimeSkeletonStatus':
          sourceDisabledRuntimeSkeletonStatus,
      'sourceRuntimePreparationDiagnosticStatus':
          sourceRuntimePreparationDiagnosticStatus,
      'safeForPhase34N': safeForPhase34N,
      'nextRecommendation': nextRecommendation,
      'counts': <String, Object?>{
        'seamProbeAttemptCount': seamProbeAttemptCount,
        'seamProbePerformedCount': seamProbePerformedCount,
        'totalBoundaries': totalBoundaries,
        'blockedBoundaryCount': blockedBoundaryCount,
        'totalBlockedReasons': totalBlockedReasons,
        'deniedFieldCount': deniedFieldCount,
        'unsafeCount': unsafeCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'runtimeExecutionCount': runtimeExecutionCount,
        'runtimeExecutionApprovedCount': runtimeExecutionApprovedCount,
        'analyzerRuntimeInputCount': analyzerRuntimeInputCount,
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
      'request': request.toJson(),
      'response': response.toJson(),
      'policy': policy.toJson(),
      'attempt': attempt.toJson(),
      'boundaries': boundaries.map((boundary) => boundary.toJson()).toList(),
      'blockedReasons': blockedReasons
          .map((reason) => reason.toJson())
          .toList(),
      'findings': findings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbe {
  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbe();

  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult evaluate({
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
    final preflight =
        runtimeExecutionPreflightResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflight()
            .evaluate(
              disabledRuntimeSkeletonDiagnosticResult: skeletonDiagnostic,
              disabledRuntimeSkeletonResult: skeleton,
              runtimePreparationDiagnosticResult: preparationDiagnostic,
              runtimePreparationResult: preparation,
            );
    final preflightDiagnostic =
        runtimeExecutionPreflightDiagnosticResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnostic()
            .evaluate(
              runtimeExecutionPreflightResult: preflight,
              disabledRuntimeSkeletonDiagnosticResult: skeletonDiagnostic,
              disabledRuntimeSkeletonResult: skeleton,
              runtimePreparationDiagnosticResult: preparationDiagnostic,
              runtimePreparationResult: preparation,
            );

    final boundaries = _boundariesFor(preflight);
    final blockedReasons = _blockedReasonsFor(preflight);
    final request = buildDisabledSeamProbeRequest(
      preflightDiagnostic: preflightDiagnostic,
      preflight: preflight,
      boundaries: boundaries,
      blockedReasons: blockedReasons,
    );
    final policy =
        DisabledAnalyzerAdapterRuntimeExecutionSeamProbePolicy.disabled(
          deniedFieldIds: request.deniedFieldIds,
        );
    final attempt = createDisabledSeamProbeAttempt(request: request);
    final response = buildDisabledSeamProbeResponse(
      request: request,
      attempt: attempt,
    );
    final input = DisabledAnalyzerAdapterRuntimeExecutionSeamProbeInput(
      seamProbeId: request.seamProbeId,
      sourcePhase: request.sourcePhase,
      sourceDiagnosticIds: request.sourceDiagnosticIds,
      sourcePreflightIds: request.sourcePreflightIds,
      sourceSkeletonIds: request.sourceSkeletonIds,
      sourcePreparationIds: request.sourcePreparationIds,
      sourceCaseIds: request.sourceCaseIds,
      sourceActionIds: request.sourceActionIds,
      sourcePatchIds: request.sourcePatchIds,
      sourceRefinementIds: request.sourceRefinementIds,
      requestId: request.requestId,
      responseId: response.responseId,
      attemptId: attempt.attemptId,
      boundaryIds: request.boundaryIds,
      blockedReasonIds: request.blockedReasonIds,
      deniedFieldIds: request.deniedFieldIds,
      supportAreaIds: request.supportAreaIds,
      warningReasons: request.warningReasons,
      proofLimitReasons: request.proofLimitReasons,
      androidProofIds: request.androidProofIds,
      ownerProofRequired: request.ownerProofRequired,
      seamProbeRequested: request.seamProbeRequested,
      seamProbePerformed: false,
      executionPerformed: false,
      executionAllowed: false,
      runtimeExecutionApproved: false,
      analyzerRuntimeInputProduced: false,
      analyzerWiringAllowed: false,
      engineCallsAllowed: false,
      schedulerAllowed: false,
      persistenceAllowed: false,
      productOutputAllowed: false,
      productAdapterAllowed: false,
      savedAnalysisAllowed: false,
      recommendation: _phase34NRecommendation,
    );
    final findings = _sorted(<String>[
      if (preflightDiagnostic.hasUnsafePolicyViolation ||
          !preflightDiagnostic.safeForPhase34M)
        'unsafePhase34LRuntimeExecutionPreflightDiagnostic',
      if (preflight.hasUnsafePolicyViolation || !preflight.safeForPhase34L)
        'unsafePhase34KRuntimeExecutionPreflight',
      ...const DisabledAnalyzerAdapterRuntimeExecutionSeamProbeValidator()
          .validateSeamProbe(
            input: input,
            request: request,
            response: response,
            policy: policy,
            attempt: attempt,
            boundaries: boundaries,
            blockedReasons: blockedReasons,
          ),
    ]);
    final safeForPhase34N = findings.isEmpty;
    return DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult(
      status: !safeForPhase34N
          ? DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeStatus
                .blockedByPolicyBoundary
          : request.warningReasons.isNotEmpty
          ? DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeStatus
                .disabledAnalyzerAdapterRuntimeExecutionSeamProbeReadyWithWarnings
          : DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeStatus
                .disabledAnalyzerAdapterRuntimeExecutionSeamProbeReadyClean,
      sourcePreflightDiagnosticStatus: preflightDiagnostic.status.wire,
      sourcePreflightStatus: preflight.status.wire,
      sourceDisabledRuntimeSkeletonDiagnosticStatus:
          skeletonDiagnostic.status.wire,
      sourceDisabledRuntimeSkeletonStatus: skeleton.status.wire,
      sourceRuntimePreparationDiagnosticStatus:
          preparationDiagnostic.status.wire,
      input: input,
      request: request,
      response: response,
      policy: policy,
      attempt: attempt,
      boundaries: boundaries,
      blockedReasons: blockedReasons,
      findings: findings,
      safeForPhase34N: safeForPhase34N,
      nextRecommendation: safeForPhase34N
          ? _phase34NRecommendation
          : 'blockedByUnsafeDisabledRuntimeExecutionSeamProbe',
    );
  }

  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeRequest
  buildDisabledSeamProbeRequest({
    required DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticResult
    preflightDiagnostic,
    required ControlledAnalyzerAdapterRuntimeExecutionPreflightResult preflight,
    required List<DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBoundary>
    boundaries,
    required List<DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBlockedReason>
    blockedReasons,
  }) {
    return DisabledAnalyzerAdapterRuntimeExecutionSeamProbeRequest(
      seamProbeId: _seamProbeId,
      requestId: _requestId,
      sourcePhase: 'Phase34L',
      sourceDiagnosticIds: <String>[
        debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticVersion,
      ],
      sourcePreflightIds: <String>[preflight.input.preflightId],
      sourceSkeletonIds: preflight.input.sourceSkeletonIds,
      sourcePreparationIds: preflight.input.sourcePreparationIds,
      sourceCaseIds: preflight.input.sourceCaseIds,
      sourceActionIds: preflight.input.sourceActionIds,
      sourcePatchIds: preflight.input.sourcePatchIds,
      sourceRefinementIds: preflight.input.sourceRefinementIds,
      boundaryIds: boundaries.map((boundary) => boundary.boundaryId).toList(),
      blockedReasonIds: blockedReasons
          .map((reason) => reason.blockedReasonId)
          .toList(),
      deniedFieldIds: preflight.input.deniedFieldIds,
      supportAreaIds: preflight.input.supportAreaIds,
      warningReasons: _sorted(<String>[
        ...preflight.input.warningReasons,
        ...preflightDiagnostic.rows.expand((row) => row.warningReasons),
        'disabledSeamProbeRequestedButRefusedByPolicy',
      ]),
      proofLimitReasons: preflight.input.proofLimitReasons,
      androidProofIds: preflight.input.androidProofIds,
      ownerProofRequired: preflight.input.ownerProofRequired,
      seamProbeRequested: true,
      seamProbePerformed: false,
      executionPerformed: false,
      executionAllowed: false,
      runtimeExecutionApproved: false,
      analyzerRuntimeInputProduced: false,
      analyzerWiringAllowed: false,
      engineCallsAllowed: false,
      schedulerAllowed: false,
      persistenceAllowed: false,
      productOutputAllowed: false,
      productAdapterAllowed: false,
      savedAnalysisAllowed: false,
      recommendation: _phase34NRecommendation,
    );
  }

  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeAttempt
  createDisabledSeamProbeAttempt({
    required DisabledAnalyzerAdapterRuntimeExecutionSeamProbeRequest request,
  }) {
    return DisabledAnalyzerAdapterRuntimeExecutionSeamProbeAttempt(
      attemptId: _attemptId,
      requestId: request.requestId,
      seamProbeRequested: request.seamProbeRequested,
      seamProbePerformed: false,
      executionPerformed: false,
      executionAllowed: false,
      runtimeExecutionApproved: false,
      analyzerRuntimeInputProduced: false,
      refused: true,
      refusedReason: 'seamProbeDisabledByPolicy',
      blockedReasonIds: request.blockedReasonIds,
      deniedFieldIds: request.deniedFieldIds,
      recommendation: _phase34NRecommendation,
    );
  }

  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeAttempt
  refuseDisabledSeamProbe({
    required DisabledAnalyzerAdapterRuntimeExecutionSeamProbeAttempt attempt,
  }) {
    return attempt.copyWith(
      seamProbePerformed: false,
      executionPerformed: false,
      executionAllowed: false,
      runtimeExecutionApproved: false,
      analyzerRuntimeInputProduced: false,
      refused: true,
      recommendation: _phase34NRecommendation,
    );
  }

  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResponse
  buildDisabledSeamProbeResponse({
    required DisabledAnalyzerAdapterRuntimeExecutionSeamProbeRequest request,
    required DisabledAnalyzerAdapterRuntimeExecutionSeamProbeAttempt attempt,
  }) {
    final refused = refuseDisabledSeamProbe(attempt: attempt);
    return DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResponse(
      seamProbeId: request.seamProbeId,
      requestId: request.requestId,
      responseId: _responseId,
      attemptId: refused.attemptId,
      responseStatus: 'disabledSeamProbeRefusedByPolicy',
      refusedReason: refused.refusedReason,
      boundaryIds: request.boundaryIds,
      blockedReasonIds: request.blockedReasonIds,
      deniedFieldIds: request.deniedFieldIds,
      warningReasons: request.warningReasons,
      proofLimitReasons: request.proofLimitReasons,
      seamProbePerformed: false,
      executionPerformed: false,
      executionAllowed: false,
      runtimeExecutionApproved: false,
      analyzerRuntimeInputProduced: false,
      analyzerWiringAllowed: false,
      engineCallsAllowed: false,
      schedulerAllowed: false,
      persistenceAllowed: false,
      productOutputAllowed: false,
      productAdapterAllowed: false,
      savedAnalysisAllowed: false,
      recommendation: _phase34NRecommendation,
    );
  }

  String renderDisabledSeamProbeSnapshot(
    DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult result,
  ) => result.renderMarkdown();

  List<String> validateDisabledSeamProbe(
    DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult result,
  ) => const DisabledAnalyzerAdapterRuntimeExecutionSeamProbeValidator()
      .validateResult(result);
}

class DisabledAnalyzerAdapterRuntimeExecutionSeamProbeValidator {
  const DisabledAnalyzerAdapterRuntimeExecutionSeamProbeValidator();

  List<String> validateResult(
    DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult result,
  ) {
    return validateSeamProbe(
      input: result.input,
      request: result.request,
      response: result.response,
      policy: result.policy,
      attempt: result.attempt,
      boundaries: result.boundaries,
      blockedReasons: result.blockedReasons,
    );
  }

  List<String> validateSeamProbe({
    required DisabledAnalyzerAdapterRuntimeExecutionSeamProbeInput input,
    required DisabledAnalyzerAdapterRuntimeExecutionSeamProbeRequest request,
    required DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResponse response,
    required DisabledAnalyzerAdapterRuntimeExecutionSeamProbePolicy policy,
    required DisabledAnalyzerAdapterRuntimeExecutionSeamProbeAttempt attempt,
    required Iterable<DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBoundary>
    boundaries,
    required Iterable<
      DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBlockedReason
    >
    blockedReasons,
  }) {
    final findings = <String>[
      ...validateInput(input),
      ...validateRequest(request),
      ...validateResponse(response),
      ...validatePolicy(policy),
      ...validateAttempt(attempt),
      ...boundaries.expand(validateBoundary),
      ...blockedReasons.expand(validateBlockedReason),
      if (!boundaries.any(
        (boundary) => boundary.boundaryId == 'analyzerRuntimeInputBoundary',
      ))
        'analyzerRuntimeInputBoundaryMissing',
      if (!attempt.seamProbeRequested) 'seamProbeAttemptMissing',
      if (!attempt.refused) 'seamProbeAttemptNotRefused',
      if (input.recommendation != _phase34NRecommendation ||
          request.recommendation != _phase34NRecommendation ||
          response.recommendation != _phase34NRecommendation ||
          attempt.recommendation != _phase34NRecommendation)
        'missingPhase34NDisabledSeamProbeDiagnosticRecommendation',
    ];
    return _sorted(findings);
  }

  List<String> validateInput(
    DisabledAnalyzerAdapterRuntimeExecutionSeamProbeInput input,
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

  List<String> validateRequest(
    DisabledAnalyzerAdapterRuntimeExecutionSeamProbeRequest request,
  ) {
    return _validateBoundary(
      sourceCaseIds: request.sourceCaseIds,
      supportAreaIds: request.supportAreaIds,
      proofLimitReasons: request.proofLimitReasons,
      androidProofIds: request.androidProofIds,
      ownerProofRequired: request.ownerProofRequired,
      deniedFieldIds: request.deniedFieldIds,
      blockedReasonIds: request.blockedReasonIds,
      seamProbePerformed: request.seamProbePerformed,
      executionPerformed: request.executionPerformed,
      executionAllowed: request.executionAllowed,
      runtimeExecutionApproved: request.runtimeExecutionApproved,
      analyzerRuntimeInputProduced: request.analyzerRuntimeInputProduced,
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
    DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResponse response,
  ) {
    return _validateBoundary(
      sourceCaseIds: const <String>[],
      supportAreaIds: const <String>[],
      proofLimitReasons: response.proofLimitReasons,
      androidProofIds: const <String>[],
      ownerProofRequired: false,
      deniedFieldIds: response.deniedFieldIds,
      blockedReasonIds: response.blockedReasonIds,
      seamProbePerformed: response.seamProbePerformed,
      executionPerformed: response.executionPerformed,
      executionAllowed: response.executionAllowed,
      runtimeExecutionApproved: response.runtimeExecutionApproved,
      analyzerRuntimeInputProduced: response.analyzerRuntimeInputProduced,
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
    DisabledAnalyzerAdapterRuntimeExecutionSeamProbePolicy policy,
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
        seamProbePerformed: false,
        executionPerformed: false,
        executionAllowed: policy.executionAllowed,
        runtimeExecutionApproved: policy.runtimeExecutionApproved,
        analyzerRuntimeInputProduced: policy.analyzerRuntimeInputAllowed,
        analyzerWiringAllowed: policy.analyzerWiringAllowed,
        engineCallsAllowed: policy.engineCallsAllowed,
        schedulerAllowed: policy.schedulerAllowed,
        persistenceAllowed: policy.persistenceAllowed,
        productOutputAllowed: policy.productOutputAllowed,
        productAdapterAllowed: policy.productAdapterAllowed,
        savedAnalysisAllowed: policy.savedAnalysisAllowed,
        recommendation: _phase34NRecommendation,
      ),
      if (policy.uiAllowed || policy.backendAllowed)
        'uiBackendActivationEnabled',
      if (policy.cacheAllowed || policy.databaseAllowed)
        'cacheDatabaseWriteEnabled',
    ]);
  }

  List<String> validateAttempt(
    DisabledAnalyzerAdapterRuntimeExecutionSeamProbeAttempt attempt,
  ) {
    return _sorted(<String>[
      ..._validateBoundary(
        sourceCaseIds: const <String>[],
        supportAreaIds: const <String>[],
        proofLimitReasons: const <String>[],
        androidProofIds: const <String>[],
        ownerProofRequired: false,
        deniedFieldIds: attempt.deniedFieldIds,
        blockedReasonIds: attempt.blockedReasonIds,
        seamProbePerformed: attempt.seamProbePerformed,
        executionPerformed: attempt.executionPerformed,
        executionAllowed: attempt.executionAllowed,
        runtimeExecutionApproved: attempt.runtimeExecutionApproved,
        analyzerRuntimeInputProduced: attempt.analyzerRuntimeInputProduced,
        analyzerWiringAllowed: false,
        engineCallsAllowed: false,
        schedulerAllowed: false,
        persistenceAllowed: false,
        productOutputAllowed: false,
        productAdapterAllowed: false,
        savedAnalysisAllowed: false,
        recommendation: attempt.recommendation,
      ),
      if (!attempt.seamProbeRequested) 'seamProbeAttemptMissing',
      if (!attempt.refused) 'seamProbeAttemptNotRefused',
      if (attempt.refusedReason != 'seamProbeDisabledByPolicy')
        'seamProbeRefusedReasonMissing',
    ]);
  }

  List<String> validateBoundary(
    DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBoundary boundary,
  ) {
    return _sorted(<String>[
      if (!_requiredBoundaryIds.contains(boundary.boundaryId))
        'unknownSeamProbeBoundary',
      if (!boundary.blocked) 'seamProbeBoundaryActivated',
      if (boundary.recommendation != _phase34NRecommendation)
        'missingPhase34NDisabledSeamProbeDiagnosticRecommendation',
      if (_activeDeniedFieldIds(boundary.deniedFieldIds).isNotEmpty)
        'activeDeniedFields',
    ]);
  }

  List<String> validateBlockedReason(
    DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBlockedReason reason,
  ) {
    return _sorted(<String>[
      if (!_requiredBlockedReasonIds.contains(reason.blockedReasonId))
        'unknownSeamProbeBlockedReason',
      if (!reason.blocked) 'blockedReasonActivated',
      if (reason.recommendation != _phase34NRecommendation)
        'missingPhase34NDisabledSeamProbeDiagnosticRecommendation',
      if (_activeDeniedFieldIds(reason.deniedFieldIds).isNotEmpty)
        'activeDeniedFields',
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
      if (recommendation != _phase34NRecommendation)
        'missingPhase34NDisabledSeamProbeDiagnosticRecommendation',
      if (seamProbePerformed) 'seamProbePerformedEnabled',
      if (executionPerformed) 'executionPerformedEnabled',
      if (executionAllowed) 'executionAllowedEnabled',
      if (runtimeExecutionApproved) 'runtimeExecutionApprovedEnabled',
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

List<DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBoundary> _boundariesFor(
  ControlledAnalyzerAdapterRuntimeExecutionPreflightResult preflight,
) {
  final denied = preflight.policy.deniedFieldIds;
  return _requiredBoundaryIds
      .map(
        (id) => DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBoundary(
          boundaryId: id,
          boundaryRole: id,
          targetSurface: id.replaceAll('Boundary', ''),
          blocked: true,
          deniedFieldIds: _deniedFieldsForBoundary(id, denied),
          recommendation: _phase34NRecommendation,
        ),
      )
      .toList(growable: false);
}

List<DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBlockedReason>
_blockedReasonsFor(
  ControlledAnalyzerAdapterRuntimeExecutionPreflightResult preflight,
) {
  final denied = preflight.policy.deniedFieldIds;
  return _requiredBlockedReasonIds
      .map(
        (id) => DisabledAnalyzerAdapterRuntimeExecutionSeamProbeBlockedReason(
          blockedReasonId: id,
          blockedSurface: _blockedSurfaceForReason(id),
          blocked: true,
          reason: '$id remains disabled for Phase 34M seam probe.',
          deniedFieldIds: _deniedFieldsForReason(id, denied),
          recommendation: _phase34NRecommendation,
        ),
      )
      .toList(growable: false);
}

List<String> _deniedFieldsForBoundary(
  String boundaryId,
  Iterable<String> base,
) {
  final mapped = switch (boundaryId) {
    'analyzerRuntimeInputBoundary' => const <String>['analyzerRuntimeInput'],
    'analyzerWiringBoundary' => const <String>['analyzerWiring'],
    'engineCallBoundary' => const <String>['engineResult'],
    'stockfishBridgeBoundary' => const <String>[
      'stockfishCommand',
      'rawUci',
      'pvDump',
    ],
    'androidCollectorBoundary' => const <String>['androidCollectorRequirement'],
    'schedulerExecutionBoundary' => const <String>['schedulerExecutionResult'],
    'persistenceWriteBoundary' ||
    'cacheBoundary' ||
    'databaseBoundary' => const <String>['cacheDatabaseWrite'],
    'productOutputBoundary' => const <String>['productLabel'],
    'productAdapterBoundary' => const <String>['productAdapterBehavior'],
    'savedAnalysisBoundary' => const <String>['savedAnalysisIntegration'],
    'uiBoundary' => const <String>['uiState'],
    'backendBoundary' => const <String>['backendResponse'],
    _ => const <String>[],
  };
  return _sorted(<String>{...base, ...mapped});
}

List<String> _deniedFieldsForReason(String reasonId, Iterable<String> base) {
  final mapped = switch (reasonId) {
    'stockfishCommandBlocked' => const <String>['stockfishCommand'],
    'rawUciBlocked' => const <String>['rawUci'],
    'pvDumpBlocked' => const <String>['pvDump'],
    'androidCollectorBlocked' => const <String>['androidCollectorRequirement'],
    'schedulerExecutionBlocked' => const <String>['schedulerExecutionResult'],
    'persistenceWriteBlocked' ||
    'cacheDatabaseBlocked' => const <String>['cacheDatabaseWrite'],
    'productOutputBlocked' ||
    'productLabelsBlocked' => const <String>['productLabel'],
    'productAdapterBlocked' => const <String>['productAdapterBehavior'],
    'savedAnalysisBlocked' => const <String>['savedAnalysisIntegration'],
    'numericScoresBlocked' => const <String>['numericMoveScore'],
    'officialMetricsBlocked' => const <String>['officialMetric'],
    'cpLossBlocked' => const <String>['cpLoss'],
    'winProbabilityBlocked' => const <String>['winProbability'],
    'analyzerRuntimeInputBlocked' => const <String>['analyzerRuntimeInput'],
    _ => const <String>[],
  };
  return _sorted(<String>{...base, ...mapped});
}

String _blockedSurfaceForReason(String reasonId) {
  return switch (reasonId) {
    'seamProbeDisabledByPolicy' => 'disabledRuntimeExecutionSeamProbe',
    'runtimeExecutionNotApproved' => 'runtimeExecutionApproval',
    'executionAllowedFalse' => 'executionPermission',
    'analyzerRuntimeInputBlocked' => 'analyzerRuntimeInput',
    'analyzerWiringBlocked' => 'analyzerWiring',
    'engineCallsBlocked' => 'engineCall',
    'stockfishCommandBlocked' => 'StockfishBridge',
    'rawUciBlocked' => 'rawUci',
    'pvDumpBlocked' => 'pvDump',
    'androidCollectorBlocked' => 'AndroidCollector',
    'schedulerExecutionBlocked' => 'schedulerExecution',
    'persistenceWriteBlocked' => 'persistenceWrite',
    'productOutputBlocked' => 'productOutput',
    'productAdapterBlocked' => 'productAdapter',
    'savedAnalysisBlocked' => 'savedAnalysis',
    'uiBackendBlocked' => 'uiBackend',
    'cacheDatabaseBlocked' => 'cacheDatabase',
    'productLabelsBlocked' => 'productLabels',
    'numericScoresBlocked' => 'numericScores',
    'officialMetricsBlocked' => 'officialMetrics',
    'cpLossBlocked' => 'cpLoss',
    'winProbabilityBlocked' => 'winProbability',
    'phase32EProofHonestyPreserved' => 'phase32EProofBoundary',
    'quietPreparatoryExclusionPreserved' => 'quietPreparatoryBoundary',
    _ => reasonId,
  };
}

List<String> _activeDeniedFieldIds(Iterable<String> ids) {
  return ids
      .where((id) => id.startsWith('active:'))
      .map((id) => id.substring('active:'.length))
      .toList(growable: false);
}

bool _isQuietSupport(Iterable<String> supportAreaIds) {
  return supportAreaIds.contains('quietMove') ||
      supportAreaIds.contains('quietPreparatoryMove') ||
      supportAreaIds.contains('quietPreparatory');
}

bool _mentionsPvMultiPv(String reason) {
  final normalized = reason.toLowerCase();
  return normalized.contains('pv') || normalized.contains('multipv');
}

String _ids(Iterable<String> ids) {
  final values = ids.toList()..sort();
  return values.isEmpty ? '-' : values.join(', ');
}

List<String> _sorted(Iterable<String> values) {
  final sorted = values.toSet().toList()..sort();
  return sorted;
}

const _phase34NRecommendation =
    'runDisabledAnalyzerAdapterRuntimeExecutionSeamProbeDiagnostic';
const _seamProbeId = 'disabled-analyzer-adapter-runtime-execution-seam-probe';
const _requestId = 'disabled-runtime-execution-seam-probe-request';
const _responseId = 'disabled-runtime-execution-seam-probe-response';
const _attemptId = 'disabled-runtime-execution-seam-probe-attempt';
const _policyId = 'disabled-runtime-execution-seam-probe-policy';
const _pvMultiPvBoundaryCaseId = 'pv-multipv-support-boundary-32e';

const _requiredBoundaryIds = <String>{
  'disabledRuntimeSkeletonBoundary',
  'runtimeExecutionPreflightBoundary',
  'analyzerRuntimeInputBoundary',
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
  'seamProbeDisabledByPolicy',
  'runtimeExecutionNotApproved',
  'executionAllowedFalse',
  'analyzerRuntimeInputBlocked',
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

const _capturedAndroidProofIds = <String>{
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
};

const _phase32ECaseIds = <String>{
  'king-safety-mating-net-32e',
  'endgame-candidate-spread-32e',
  'budget-pressure-depth-limited-32e',
  _pvMultiPvBoundaryCaseId,
};

const _productFields = <String>{
  'productLabel',
  'brilliantLabel',
  'greatLabel',
  'missLabel',
  'bestMoveLabel',
  'goodMoveLabel',
  'inaccuracyLabel',
  'mistakeLabel',
  'blunderLabel',
};

const _finalLabelFields = <String>{
  'finalMoveLabel',
  'bestMoveLabel',
  'goodMoveLabel',
  'inaccuracyLabel',
  'mistakeLabel',
  'blunderLabel',
};

const _classifierFields = <String>{
  'classifierLabel',
  'brilliantLabel',
  'greatLabel',
  'missLabel',
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

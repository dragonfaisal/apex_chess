import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton_diagnostic.dart';

const debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightVersion =
    'debug-only-bridge-analyzer-adapter-controlled-runtime-execution-preflight-v1';

enum DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightStatus {
  controlledAnalyzerAdapterRuntimeExecutionPreflightReadyWithWarnings(
    'controlledAnalyzerAdapterRuntimeExecutionPreflightReadyWithWarnings',
  ),
  controlledAnalyzerAdapterRuntimeExecutionPreflightReadyClean(
    'controlledAnalyzerAdapterRuntimeExecutionPreflightReadyClean',
  ),
  blockedByUnsafeDisabledRuntimeSkeletonDiagnostic(
    'blockedByUnsafeDisabledRuntimeSkeletonDiagnostic',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidControlledRuntimeExecutionPreflight(
    'invalidControlledRuntimeExecutionPreflight',
  );

  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightStatus(
    this.wire,
  );

  final String wire;
}

class ControlledAnalyzerAdapterRuntimeExecutionPreflightInput {
  const ControlledAnalyzerAdapterRuntimeExecutionPreflightInput({
    required this.preflightId,
    required this.sourcePhase,
    required this.sourceDiagnosticIds,
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
    required this.executionAllowed,
    required this.runtimeExecutionApproved,
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
  final bool executionAllowed;
  final bool runtimeExecutionApproved;
  final bool analyzerWiringAllowed;
  final bool engineCallsAllowed;
  final bool schedulerAllowed;
  final bool persistenceAllowed;
  final bool productOutputAllowed;
  final bool productAdapterAllowed;
  final bool savedAnalysisAllowed;
  final String recommendation;

  ControlledAnalyzerAdapterRuntimeExecutionPreflightInput copyWith({
    String? preflightId,
    String? sourcePhase,
    List<String>? sourceDiagnosticIds,
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
    bool? executionAllowed,
    bool? runtimeExecutionApproved,
    bool? analyzerWiringAllowed,
    bool? engineCallsAllowed,
    bool? schedulerAllowed,
    bool? persistenceAllowed,
    bool? productOutputAllowed,
    bool? productAdapterAllowed,
    bool? savedAnalysisAllowed,
    String? recommendation,
  }) {
    return ControlledAnalyzerAdapterRuntimeExecutionPreflightInput(
      preflightId: preflightId ?? this.preflightId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      sourceDiagnosticIds: sourceDiagnosticIds ?? this.sourceDiagnosticIds,
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
      executionAllowed: executionAllowed ?? this.executionAllowed,
      runtimeExecutionApproved:
          runtimeExecutionApproved ?? this.runtimeExecutionApproved,
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
      'executionAllowed': executionAllowed,
      'runtimeExecutionApproved': runtimeExecutionApproved,
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

class ControlledAnalyzerAdapterRuntimeExecutionPreflightCheck {
  const ControlledAnalyzerAdapterRuntimeExecutionPreflightCheck({
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

  ControlledAnalyzerAdapterRuntimeExecutionPreflightCheck copyWith({
    String? checkId,
    String? checkStatus,
    bool? passed,
    List<String>? inspectedFieldIds,
    List<String>? blockedReasonIds,
    List<String>? deniedFieldIds,
    List<String>? warningReasons,
    String? recommendation,
  }) {
    return ControlledAnalyzerAdapterRuntimeExecutionPreflightCheck(
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

class ControlledAnalyzerAdapterRuntimeExecutionPreflightPolicy {
  const ControlledAnalyzerAdapterRuntimeExecutionPreflightPolicy({
    required this.policyId,
    required this.deniedFieldIds,
    required this.executionAllowed,
    required this.runtimeExecutionApproved,
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

  factory ControlledAnalyzerAdapterRuntimeExecutionPreflightPolicy.disabled({
    required Iterable<String> deniedFieldIds,
  }) {
    return ControlledAnalyzerAdapterRuntimeExecutionPreflightPolicy(
      policyId: 'controlled-runtime-execution-preflight-policy',
      deniedFieldIds: _sorted(deniedFieldIds),
      executionAllowed: false,
      runtimeExecutionApproved: false,
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

  ControlledAnalyzerAdapterRuntimeExecutionPreflightPolicy copyWith({
    String? policyId,
    List<String>? deniedFieldIds,
    bool? executionAllowed,
    bool? runtimeExecutionApproved,
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
    return ControlledAnalyzerAdapterRuntimeExecutionPreflightPolicy(
      policyId: policyId ?? this.policyId,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      executionAllowed: executionAllowed ?? this.executionAllowed,
      runtimeExecutionApproved:
          runtimeExecutionApproved ?? this.runtimeExecutionApproved,
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

class ControlledAnalyzerAdapterRuntimeExecutionPreflightDecision {
  const ControlledAnalyzerAdapterRuntimeExecutionPreflightDecision({
    required this.decisionId,
    required this.decisionStatus,
    required this.executionAllowed,
    required this.runtimeExecutionApproved,
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
  final bool executionAllowed;
  final bool runtimeExecutionApproved;
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

  ControlledAnalyzerAdapterRuntimeExecutionPreflightDecision copyWith({
    String? decisionId,
    String? decisionStatus,
    bool? executionAllowed,
    bool? runtimeExecutionApproved,
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
    return ControlledAnalyzerAdapterRuntimeExecutionPreflightDecision(
      decisionId: decisionId ?? this.decisionId,
      decisionStatus: decisionStatus ?? this.decisionStatus,
      executionAllowed: executionAllowed ?? this.executionAllowed,
      runtimeExecutionApproved:
          runtimeExecutionApproved ?? this.runtimeExecutionApproved,
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
      'executionAllowed': executionAllowed,
      'runtimeExecutionApproved': runtimeExecutionApproved,
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

class ControlledAnalyzerAdapterRuntimeExecutionPreflightBlockedReason {
  const ControlledAnalyzerAdapterRuntimeExecutionPreflightBlockedReason({
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

  ControlledAnalyzerAdapterRuntimeExecutionPreflightBlockedReason copyWith({
    String? blockedReasonId,
    String? blockedSurface,
    bool? blocked,
    String? reason,
    List<String>? deniedFieldIds,
    String? recommendation,
  }) {
    return ControlledAnalyzerAdapterRuntimeExecutionPreflightBlockedReason(
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

class ControlledAnalyzerAdapterRuntimeExecutionPreflightResult {
  ControlledAnalyzerAdapterRuntimeExecutionPreflightResult({
    required this.status,
    required this.sourceDiagnosticStatus,
    required this.sourceSkeletonStatus,
    required this.sourceRuntimePreparationDiagnosticStatus,
    required this.sourceRuntimePreparationStatus,
    required this.input,
    required this.checks,
    required this.policy,
    required this.decision,
    required this.blockedReasons,
    required this.findings,
    required this.safeForPhase34L,
    required this.nextRecommendation,
  }) : totalChecks = checks.length,
       passedCheckCount = checks.where((check) => check.passed).length,
       warningCheckCount = checks
           .where((check) => check.warningReasons.isNotEmpty)
           .length,
       blockedReasonCount = blockedReasons.length,
       deniedFieldCount = _sorted(policy.deniedFieldIds).length,
       ownerProofQueueCount = input.ownerProofRequired ? 1 : 0,
       activeDeniedFieldCount =
           _activeDeniedFieldIds(policy.deniedFieldIds).length +
           blockedReasons
               .expand((reason) => _activeDeniedFieldIds(reason.deniedFieldIds))
               .length,
       runtimeExecutionCount =
           (input.executionAllowed ? 1 : 0) +
           (policy.executionAllowed ? 1 : 0) +
           (decision.executionAllowed ? 1 : 0) +
           (decision.runtimeExecutionApproved ? 1 : 0),
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

  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightStatus
  status;
  final String sourceDiagnosticStatus;
  final String sourceSkeletonStatus;
  final String sourceRuntimePreparationDiagnosticStatus;
  final String sourceRuntimePreparationStatus;
  final ControlledAnalyzerAdapterRuntimeExecutionPreflightInput input;
  final List<ControlledAnalyzerAdapterRuntimeExecutionPreflightCheck> checks;
  final ControlledAnalyzerAdapterRuntimeExecutionPreflightPolicy policy;
  final ControlledAnalyzerAdapterRuntimeExecutionPreflightDecision decision;
  final List<ControlledAnalyzerAdapterRuntimeExecutionPreflightBlockedReason>
  blockedReasons;
  final List<String> findings;
  final bool safeForPhase34L;
  final String nextRecommendation;
  final int totalChecks;
  final int passedCheckCount;
  final int warningCheckCount;
  final int blockedReasonCount;
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
  final int uiBackendCacheDatabaseActivationCount;
  final int phase32EProofClaimCount;
  final int unprovenAndroidProofCount;
  late final int unsafeCount;
  late final int blockerCount;
  late final int criticalCount;

  bool get hasUnsafePolicyViolation =>
      !safeForPhase34L ||
      findings.isNotEmpty ||
      activeDeniedFieldCount > 0 ||
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
      phase32EProofClaimCount > 0 ||
      unprovenAndroidProofCount > 0 ||
      ownerProofQueueCount > 0;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Controlled Analyzer Adapter Runtime Execution Preflight')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightVersion',
      )
      ..writeln('- preflight status: ${status.wire}')
      ..writeln('- source diagnostic status: $sourceDiagnosticStatus')
      ..writeln('- source skeleton status: $sourceSkeletonStatus')
      ..writeln(
        '- source runtime-preparation diagnostic status: $sourceRuntimePreparationDiagnosticStatus',
      )
      ..writeln(
        '- source runtime-preparation status: $sourceRuntimePreparationStatus',
      )
      ..writeln('- safe for Phase 34L: $safeForPhase34L')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln()
      ..writeln('## Preflight Check Summary')
      ..writeln('| Check | Status | Passed | Blocked reasons |')
      ..writeln('| --- | --- | --- | --- |');
    for (final check in checks) {
      buffer.writeln(
        '| ${check.checkId} | ${check.checkStatus} | ${check.passed} | ${_ids(check.blockedReasonIds)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Preflight Decision Summary')
      ..writeln('- decision ID: ${decision.decisionId}')
      ..writeln('- decision status: ${decision.decisionStatus}')
      ..writeln('- executionAllowed: ${decision.executionAllowed}')
      ..writeln(
        '- runtimeExecutionApproved: ${decision.runtimeExecutionApproved}',
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
      ..writeln()
      ..writeln('## Recommendation')
      ..writeln('- safe for Phase 34L: $safeForPhase34L')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- findings: ${_ids(findings)}')
      ..writeln();
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent(' ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightVersion,
      'status': status.wire,
      'sourceDiagnosticStatus': sourceDiagnosticStatus,
      'sourceSkeletonStatus': sourceSkeletonStatus,
      'sourceRuntimePreparationDiagnosticStatus':
          sourceRuntimePreparationDiagnosticStatus,
      'sourceRuntimePreparationStatus': sourceRuntimePreparationStatus,
      'safeForPhase34L': safeForPhase34L,
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
        'runtimeExecutionCount': runtimeExecutionCount,
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

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflight {
  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflight();

  ControlledAnalyzerAdapterRuntimeExecutionPreflightResult evaluate({
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
    final runtimeDiagnostic =
        runtimePreparationDiagnosticResult ??
        const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic()
            .evaluate(runtimePreparationResult: preparation);
    final skeleton =
        disabledRuntimeSkeletonResult ??
        const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeleton().evaluate(
          runtimePreparationDiagnosticResult: runtimeDiagnostic,
          runtimePreparationResult: preparation,
        );
    final skeletonDiagnostic =
        disabledRuntimeSkeletonDiagnosticResult ??
        const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnostic()
            .evaluate(
              skeletonResult: skeleton,
              runtimePreparationDiagnosticResult: runtimeDiagnostic,
              runtimePreparationResult: preparation,
            );
    final blockedReasons = _blockedReasonsFor(skeleton);
    final checks = _checksFor(skeleton, blockedReasons);
    final policy =
        ControlledAnalyzerAdapterRuntimeExecutionPreflightPolicy.disabled(
          deniedFieldIds: skeleton.policy.deniedFieldIds,
        );
    final decision = ControlledAnalyzerAdapterRuntimeExecutionPreflightDecision(
      decisionId: _decisionId,
      decisionStatus: 'executionPreflightInspectedRuntimeStillDisabled',
      executionAllowed: false,
      runtimeExecutionApproved: false,
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
        'runtimeExecutionPreflightExistsButExecutionStillDisabled',
      ],
      recommendation: _phase34LRecommendation,
    );
    final input = ControlledAnalyzerAdapterRuntimeExecutionPreflightInput(
      preflightId: _preflightId,
      sourcePhase: 'Phase34J',
      sourceDiagnosticIds: <String>[
        debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticVersion,
      ],
      sourceSkeletonIds: <String>[skeleton.request.skeletonId],
      sourcePreparationIds: skeleton.request.sourcePreparationIds,
      sourceCaseIds: skeleton.request.sourceCaseIds,
      sourceActionIds: skeleton.request.sourceActionIds,
      sourcePatchIds: skeleton.request.sourcePatchIds,
      sourceRefinementIds: skeleton.request.sourceRefinementIds,
      checkIds: checks.map((check) => check.checkId).toList(),
      decisionId: decision.decisionId,
      blockedReasonIds: decision.blockedReasonIds,
      deniedFieldIds: policy.deniedFieldIds,
      supportAreaIds: skeleton.request.supportAreaIds,
      warningReasons: _sorted(<String>[
        ...skeleton.request.warningReasons,
        'controlledRuntimeExecutionPreflightNoRuntimeExecution',
      ]),
      proofLimitReasons: skeleton.request.proofLimitReasons,
      androidProofIds: skeleton.request.androidProofIds,
      ownerProofRequired: skeleton.request.ownerProofRequired,
      executionAllowed: false,
      runtimeExecutionApproved: false,
      analyzerWiringAllowed: false,
      engineCallsAllowed: false,
      schedulerAllowed: false,
      persistenceAllowed: false,
      productOutputAllowed: false,
      productAdapterAllowed: false,
      savedAnalysisAllowed: false,
      recommendation: _phase34LRecommendation,
    );
    final findings = _sorted(<String>[
      if (skeletonDiagnostic.hasUnsafePolicyViolation ||
          !skeletonDiagnostic.safeForPhase34K)
        'unsafePhase34JDisabledRuntimeSkeletonDiagnostic',
      if (skeleton.hasUnsafePolicyViolation || !skeleton.safeForPhase34J)
        'unsafePhase34IDisabledRuntimeSkeleton',
      ...const ControlledAnalyzerAdapterRuntimeExecutionPreflightValidator()
          .validatePreflight(
            input: input,
            checks: checks,
            policy: policy,
            decision: decision,
            blockedReasons: blockedReasons,
            executionPerformed: skeleton.executionAttempt.executionPerformed,
          ),
    ]);
    final safeForPhase34L = findings.isEmpty;
    return ControlledAnalyzerAdapterRuntimeExecutionPreflightResult(
      status: !safeForPhase34L
          ? DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightStatus
                .blockedByPolicyBoundary
          : checks.any((check) => check.warningReasons.isNotEmpty)
          ? DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightStatus
                .controlledAnalyzerAdapterRuntimeExecutionPreflightReadyWithWarnings
          : DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightStatus
                .controlledAnalyzerAdapterRuntimeExecutionPreflightReadyClean,
      sourceDiagnosticStatus: skeletonDiagnostic.status.wire,
      sourceSkeletonStatus: skeleton.status.wire,
      sourceRuntimePreparationDiagnosticStatus: runtimeDiagnostic.status.wire,
      sourceRuntimePreparationStatus: preparation.status.wire,
      input: input,
      checks: checks,
      policy: policy,
      decision: decision,
      blockedReasons: blockedReasons,
      findings: findings,
      safeForPhase34L: safeForPhase34L,
      nextRecommendation: safeForPhase34L
          ? _phase34LRecommendation
          : 'blockedByUnsafeControlledRuntimeExecutionPreflight',
    );
  }
}

class ControlledAnalyzerAdapterRuntimeExecutionPreflightValidator {
  const ControlledAnalyzerAdapterRuntimeExecutionPreflightValidator();

  List<String> validateResult(
    ControlledAnalyzerAdapterRuntimeExecutionPreflightResult result,
  ) {
    return validatePreflight(
      input: result.input,
      checks: result.checks,
      policy: result.policy,
      decision: result.decision,
      blockedReasons: result.blockedReasons,
      executionPerformed: false,
    );
  }

  List<String> validatePreflight({
    required ControlledAnalyzerAdapterRuntimeExecutionPreflightInput input,
    required Iterable<ControlledAnalyzerAdapterRuntimeExecutionPreflightCheck>
    checks,
    required ControlledAnalyzerAdapterRuntimeExecutionPreflightPolicy policy,
    required ControlledAnalyzerAdapterRuntimeExecutionPreflightDecision
    decision,
    required Iterable<
      ControlledAnalyzerAdapterRuntimeExecutionPreflightBlockedReason
    >
    blockedReasons,
    required bool executionPerformed,
  }) {
    final findings = <String>[
      ...validateInput(input),
      ...checks.expand(validateCheck),
      ...validatePolicy(policy),
      ...validateDecision(decision),
      ...blockedReasons.expand(validateBlockedReason),
      if (executionPerformed) 'runtimeExecutionResultEnabled',
      if (!checks.any((check) => check.checkId == 'disabledSkeletonPresent'))
        'disabledSkeletonMissing',
      if (!checks.any((check) => check.checkId == 'requestEnvelopePresent'))
        'requestEnvelopeMissing',
      if (!checks.any((check) => check.checkId == 'responseEnvelopePresent'))
        'responseEnvelopeMissing',
      if (!checks.any(
        (check) => check.checkId == 'refusedExecutionAttemptPresent',
      ))
        'refusedExecutionAttemptMissing',
      if (input.recommendation != _phase34LRecommendation ||
          decision.recommendation != _phase34LRecommendation)
        'missingPhase34LRuntimeExecutionPreflightDiagnosticRecommendation',
    ];
    return _sorted(findings);
  }

  List<String> validateInput(
    ControlledAnalyzerAdapterRuntimeExecutionPreflightInput input,
  ) {
    return _validateBoundary(
      sourceCaseIds: input.sourceCaseIds,
      supportAreaIds: input.supportAreaIds,
      proofLimitReasons: input.proofLimitReasons,
      androidProofIds: input.androidProofIds,
      ownerProofRequired: input.ownerProofRequired,
      deniedFieldIds: input.deniedFieldIds,
      blockedReasonIds: input.blockedReasonIds,
      executionAllowed: input.executionAllowed,
      runtimeExecutionApproved: input.runtimeExecutionApproved,
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
    ControlledAnalyzerAdapterRuntimeExecutionPreflightCheck check,
  ) {
    return _sorted(<String>[
      if (!_requiredCheckIds.contains(check.checkId))
        'unknownRuntimeExecutionPreflightCheck',
      if (!check.passed) 'runtimeExecutionPreflightCheckFailed',
      if (check.recommendation != _phase34LRecommendation)
        'missingPhase34LRuntimeExecutionPreflightDiagnosticRecommendation',
      if (_activeDeniedFieldIds(check.deniedFieldIds).isNotEmpty)
        'activeDeniedFields',
      if (check.blockedReasonIds.any((id) => id.startsWith('active:')))
        'blockedReasonActivated',
    ]);
  }

  List<String> validatePolicy(
    ControlledAnalyzerAdapterRuntimeExecutionPreflightPolicy policy,
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
        executionAllowed: policy.executionAllowed,
        runtimeExecutionApproved: policy.runtimeExecutionApproved,
        analyzerWiringAllowed: policy.analyzerWiringAllowed,
        engineCallsAllowed: policy.engineCallsAllowed,
        schedulerAllowed: policy.schedulerAllowed,
        persistenceAllowed: policy.persistenceAllowed,
        productOutputAllowed: policy.productOutputAllowed,
        productAdapterAllowed: policy.productAdapterAllowed,
        savedAnalysisAllowed: policy.savedAnalysisAllowed,
        recommendation: _phase34LRecommendation,
      ),
      if (policy.uiAllowed || policy.backendAllowed)
        'uiBackendActivationEnabled',
      if (policy.cacheAllowed || policy.databaseAllowed)
        'cacheDatabaseWriteEnabled',
    ]);
  }

  List<String> validateDecision(
    ControlledAnalyzerAdapterRuntimeExecutionPreflightDecision decision,
  ) {
    return _validateBoundary(
      sourceCaseIds: const <String>[],
      supportAreaIds: const <String>[],
      proofLimitReasons: const <String>[],
      androidProofIds: const <String>[],
      ownerProofRequired: false,
      deniedFieldIds: const <String>[],
      blockedReasonIds: decision.blockedReasonIds,
      executionAllowed: decision.executionAllowed,
      runtimeExecutionApproved: decision.runtimeExecutionApproved,
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
    ControlledAnalyzerAdapterRuntimeExecutionPreflightBlockedReason reason,
  ) {
    return _sorted(<String>[
      if (!reason.blocked) 'blockedReasonActivated',
      if (reason.recommendation != _phase34LRecommendation)
        'missingPhase34LRuntimeExecutionPreflightDiagnosticRecommendation',
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
    required bool executionAllowed,
    required bool runtimeExecutionApproved,
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
      if (recommendation != _phase34LRecommendation)
        'missingPhase34LRuntimeExecutionPreflightDiagnosticRecommendation',
      if (executionAllowed) 'executionAllowedEnabled',
      if (runtimeExecutionApproved) 'runtimeExecutionApprovedEnabled',
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

List<ControlledAnalyzerAdapterRuntimeExecutionPreflightCheck> _checksFor(
  DisabledAnalyzerAdapterRuntimeSkeletonResult skeleton,
  List<ControlledAnalyzerAdapterRuntimeExecutionPreflightBlockedReason>
  blockedReasons,
) {
  final blockedReasonIds = blockedReasons
      .map((reason) => reason.blockedReasonId)
      .toList();
  return _requiredCheckIds
      .map(
        (id) => ControlledAnalyzerAdapterRuntimeExecutionPreflightCheck(
          checkId: id,
          checkStatus: 'passedDisabledRuntimeExecutionPreflightCheck',
          passed: _checkPassed(id, skeleton),
          inspectedFieldIds: _inspectedFieldsForCheck(id),
          blockedReasonIds: blockedReasonIds,
          deniedFieldIds: _deniedFieldsForCheck(
            id,
            skeleton.policy.deniedFieldIds,
          ),
          warningReasons: const <String>[
            'preflightCheckIsDeveloperOnlyNoRuntimeExecution',
          ],
          recommendation: _phase34LRecommendation,
        ),
      )
      .toList(growable: false);
}

bool _checkPassed(
  String id,
  DisabledAnalyzerAdapterRuntimeSkeletonResult source,
) {
  return switch (id) {
    'disabledSkeletonPresent' => source.request.skeletonId.isNotEmpty,
    'requestEnvelopePresent' => source.request.requestEnvelopeId.isNotEmpty,
    'responseEnvelopePresent' => source.response.responseEnvelopeId.isNotEmpty,
    'refusedExecutionAttemptPresent' =>
      source.executionAttempt.executionAttempted &&
          source.executionAttempt.executionRefused,
    'executionPerformedFalse' => !source.executionAttempt.executionPerformed,
    'executionAllowedFalse' =>
      !source.request.executionAllowed &&
          !source.response.executionAllowed &&
          !source.policy.executionAllowed,
    'analyzerWiringAllowedFalse' =>
      !source.request.analyzerWiringAllowed &&
          !source.response.analyzerWiringAllowed &&
          !source.policy.analyzerWiringAllowed,
    'engineCallsAllowedFalse' =>
      !source.request.engineCallsAllowed &&
          !source.response.engineCallsAllowed &&
          !source.policy.engineCallsAllowed,
    'schedulerAllowedFalse' =>
      !source.request.schedulerAllowed &&
          !source.response.schedulerAllowed &&
          !source.policy.schedulerAllowed,
    'persistenceAllowedFalse' =>
      !source.request.persistenceAllowed &&
          !source.response.persistenceAllowed &&
          !source.policy.persistenceAllowed,
    'productOutputAllowedFalse' =>
      !source.request.productOutputAllowed &&
          !source.response.productOutputAllowed &&
          !source.policy.productOutputAllowed,
    'productAdapterAllowedFalse' =>
      !source.request.productAdapterAllowed &&
          !source.response.productAdapterAllowed &&
          !source.policy.productAdapterAllowed,
    'savedAnalysisAllowedFalse' =>
      !source.request.savedAnalysisAllowed &&
          !source.response.savedAnalysisAllowed &&
          !source.policy.savedAnalysisAllowed,
    'stockfishCommandBlocked' => source.policy.deniedFieldIds.contains(
      'stockfishCommand',
    ),
    'rawUciBlocked' => source.policy.deniedFieldIds.contains('rawUci'),
    'pvDumpBlocked' => source.policy.deniedFieldIds.contains('pvDump'),
    'androidCollectorBlocked' => source.blockedSeams.any(
      (seam) => seam.blockedSeamId == 'AndroidCollector' && seam.blocked,
    ),
    'productLabelsBlocked' => source.policy.deniedFieldIds.contains(
      'productLabel',
    ),
    'numericScoresBlocked' => source.policy.deniedFieldIds.contains(
      'numericMoveScore',
    ),
    'officialMetricsBlocked' =>
      source.policy.deniedFieldIds.contains('officialMetric') ||
          source.policy.deniedFieldIds.contains('officialAccuracy'),
    'cpLossBlocked' => source.policy.deniedFieldIds.contains('cpLoss'),
    'winProbabilityBlocked' => source.policy.deniedFieldIds.contains(
      'winProbability',
    ),
    'phase32EProofHonestyPreserved' => source.phase32EProofClaimCount == 0,
    'quietPreparatoryExclusionPreserved' => !_isQuietSupport(
      source.request.supportAreaIds,
    ),
    _ => false,
  };
}

List<String> _inspectedFieldsForCheck(String id) {
  return switch (id) {
    'disabledSkeletonPresent' => const <String>['skeletonId'],
    'requestEnvelopePresent' => const <String>['requestEnvelopeId'],
    'responseEnvelopePresent' => const <String>['responseEnvelopeId'],
    'refusedExecutionAttemptPresent' => const <String>[
      'executionAttempted',
      'executionRefused',
    ],
    'executionPerformedFalse' => const <String>['executionPerformed'],
    'executionAllowedFalse' => const <String>['executionAllowed'],
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
  };
  return _sorted(byCheck[id] ?? sourceDeniedFields);
}

List<ControlledAnalyzerAdapterRuntimeExecutionPreflightBlockedReason>
_blockedReasonsFor(DisabledAnalyzerAdapterRuntimeSkeletonResult skeleton) {
  final surfaces = <String>[
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
        (surface) =>
            ControlledAnalyzerAdapterRuntimeExecutionPreflightBlockedReason(
              blockedReasonId: 'blocked-$surface',
              blockedSurface: surface,
              blocked: true,
              reason:
                  'controlledRuntimeExecutionPreflightKeeps${surface}Blocked',
              deniedFieldIds: skeleton.policy.deniedFieldIds,
              recommendation: _phase34LRecommendation,
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

const _preflightId = 'controlled-analyzer-adapter-runtime-execution-preflight';
const _decisionId = 'controlled-runtime-execution-preflight-decision';
const _phase34LRecommendation =
    'runControlledAnalyzerAdapterRuntimeExecutionPreflightDiagnostic';
const _pvMultiPvBoundaryCaseId = 'pv-multipv-support-boundary-32e';

const _requiredCheckIds = <String>{
  'disabledSkeletonPresent',
  'requestEnvelopePresent',
  'responseEnvelopePresent',
  'refusedExecutionAttemptPresent',
  'executionPerformedFalse',
  'executionAllowedFalse',
  'analyzerWiringAllowedFalse',
  'engineCallsAllowedFalse',
  'schedulerAllowedFalse',
  'persistenceAllowedFalse',
  'productOutputAllowedFalse',
  'productAdapterAllowedFalse',
  'savedAnalysisAllowedFalse',
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
  'king-safety-mating-net-pressure-32e',
  'endgame-precision-candidate-spread-32e',
  'budget-pressure-wide-candidate-32e',
  'endgame-candidate-spread-pressure-32e',
  'budget-pressure-depth-limited-32e',
  'pv-multipv-support-boundary-32e',
};

const _productFields = <String>{'productLabel', 'productOutput'};
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
  'officialAccuracy',
  'accuracy',
  'acpl',
};

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_diagnostic.dart';

const debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationVersion =
    'debug-only-bridge-analyzer-adapter-controlled-runtime-preparation-v1';

enum DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationStatus {
  controlledAnalyzerAdapterRuntimePreparationReadyWithWarnings(
    'controlledAnalyzerAdapterRuntimePreparationReadyWithWarnings',
  ),
  controlledAnalyzerAdapterRuntimePreparationReadyClean(
    'controlledAnalyzerAdapterRuntimePreparationReadyClean',
  ),
  blockedByUnsafeMetadataRefinementDiagnostic(
    'blockedByUnsafeMetadataRefinementDiagnostic',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidControlledRuntimePreparation('invalidControlledRuntimePreparation');

  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationStatus(
    this.wire,
  );

  final String wire;
}

class ControlledAnalyzerAdapterRuntimePreparationInput {
  const ControlledAnalyzerAdapterRuntimePreparationInput({
    required this.preparationId,
    required this.sourcePhase,
    required this.sourceDiagnosticIds,
    required this.sourceCaseIds,
    required this.sourceActionIds,
    required this.sourcePatchIds,
    required this.sourceRefinementIds,
    required this.supportAreaIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.androidProofIds,
    required this.ownerProofRequired,
    required this.recommendation,
  });

  final String preparationId;
  final String sourcePhase;
  final List<String> sourceDiagnosticIds;
  final List<String> sourceCaseIds;
  final List<String> sourceActionIds;
  final List<String> sourcePatchIds;
  final List<String> sourceRefinementIds;
  final List<String> supportAreaIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofIds;
  final bool ownerProofRequired;
  final String recommendation;

  ControlledAnalyzerAdapterRuntimePreparationInput copyWith({
    String? preparationId,
    String? sourcePhase,
    List<String>? sourceDiagnosticIds,
    List<String>? sourceCaseIds,
    List<String>? sourceActionIds,
    List<String>? sourcePatchIds,
    List<String>? sourceRefinementIds,
    List<String>? supportAreaIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? androidProofIds,
    bool? ownerProofRequired,
    String? recommendation,
  }) {
    return ControlledAnalyzerAdapterRuntimePreparationInput(
      preparationId: preparationId ?? this.preparationId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      sourceDiagnosticIds: sourceDiagnosticIds ?? this.sourceDiagnosticIds,
      sourceCaseIds: sourceCaseIds ?? this.sourceCaseIds,
      sourceActionIds: sourceActionIds ?? this.sourceActionIds,
      sourcePatchIds: sourcePatchIds ?? this.sourcePatchIds,
      sourceRefinementIds: sourceRefinementIds ?? this.sourceRefinementIds,
      supportAreaIds: supportAreaIds ?? this.supportAreaIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      androidProofIds: androidProofIds ?? this.androidProofIds,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'preparationId': preparationId,
      'sourcePhase': sourcePhase,
      'sourceDiagnosticIds': sourceDiagnosticIds,
      'sourceCaseIds': sourceCaseIds,
      'sourceActionIds': sourceActionIds,
      'sourcePatchIds': sourcePatchIds,
      'sourceRefinementIds': sourceRefinementIds,
      'supportAreaIds': supportAreaIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'androidProofIds': androidProofIds,
      'ownerProofRequired': ownerProofRequired,
      'recommendation': recommendation,
    };
  }
}

class ControlledAnalyzerAdapterRuntimePreparationPolicy {
  const ControlledAnalyzerAdapterRuntimePreparationPolicy({
    required this.policyId,
    required this.deniedFieldIds,
    required this.executionAllowed,
    required this.analyzerWiringAllowed,
    required this.engineCallsAllowed,
    required this.productOutputAllowed,
    required this.persistenceAllowed,
    required this.schedulerAllowed,
    required this.productAdapterAllowed,
    required this.savedAnalysisAllowed,
    required this.uiAllowed,
    required this.backendAllowed,
    required this.cacheAllowed,
    required this.databaseAllowed,
    required this.executableRuntimeAllowed,
  });

  factory ControlledAnalyzerAdapterRuntimePreparationPolicy.disabledDefault({
    List<String> deniedFieldIds = _defaultDeniedFieldIds,
  }) {
    return ControlledAnalyzerAdapterRuntimePreparationPolicy(
      policyId: 'controlled-runtime-preparation-disabled-policy',
      deniedFieldIds: _sorted(deniedFieldIds),
      executionAllowed: false,
      analyzerWiringAllowed: false,
      engineCallsAllowed: false,
      productOutputAllowed: false,
      persistenceAllowed: false,
      schedulerAllowed: false,
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
  final bool productOutputAllowed;
  final bool persistenceAllowed;
  final bool schedulerAllowed;
  final bool productAdapterAllowed;
  final bool savedAnalysisAllowed;
  final bool uiAllowed;
  final bool backendAllowed;
  final bool cacheAllowed;
  final bool databaseAllowed;
  final bool executableRuntimeAllowed;

  ControlledAnalyzerAdapterRuntimePreparationPolicy copyWith({
    String? policyId,
    List<String>? deniedFieldIds,
    bool? executionAllowed,
    bool? analyzerWiringAllowed,
    bool? engineCallsAllowed,
    bool? productOutputAllowed,
    bool? persistenceAllowed,
    bool? schedulerAllowed,
    bool? productAdapterAllowed,
    bool? savedAnalysisAllowed,
    bool? uiAllowed,
    bool? backendAllowed,
    bool? cacheAllowed,
    bool? databaseAllowed,
    bool? executableRuntimeAllowed,
  }) {
    return ControlledAnalyzerAdapterRuntimePreparationPolicy(
      policyId: policyId ?? this.policyId,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      executionAllowed: executionAllowed ?? this.executionAllowed,
      analyzerWiringAllowed:
          analyzerWiringAllowed ?? this.analyzerWiringAllowed,
      engineCallsAllowed: engineCallsAllowed ?? this.engineCallsAllowed,
      productOutputAllowed: productOutputAllowed ?? this.productOutputAllowed,
      persistenceAllowed: persistenceAllowed ?? this.persistenceAllowed,
      schedulerAllowed: schedulerAllowed ?? this.schedulerAllowed,
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
      'productOutputAllowed': productOutputAllowed,
      'persistenceAllowed': persistenceAllowed,
      'schedulerAllowed': schedulerAllowed,
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

class ControlledAnalyzerAdapterRuntimePreparationPrecondition {
  const ControlledAnalyzerAdapterRuntimePreparationPrecondition({
    required this.preconditionId,
    required this.description,
    required this.executableNow,
    required this.requiredForFutureRuntime,
    required this.blockedSeamIds,
    required this.warningReasons,
    required this.recommendation,
  });

  final String preconditionId;
  final String description;
  final bool executableNow;
  final bool requiredForFutureRuntime;
  final List<String> blockedSeamIds;
  final List<String> warningReasons;
  final String recommendation;

  ControlledAnalyzerAdapterRuntimePreparationPrecondition copyWith({
    String? preconditionId,
    String? description,
    bool? executableNow,
    bool? requiredForFutureRuntime,
    List<String>? blockedSeamIds,
    List<String>? warningReasons,
    String? recommendation,
  }) {
    return ControlledAnalyzerAdapterRuntimePreparationPrecondition(
      preconditionId: preconditionId ?? this.preconditionId,
      description: description ?? this.description,
      executableNow: executableNow ?? this.executableNow,
      requiredForFutureRuntime:
          requiredForFutureRuntime ?? this.requiredForFutureRuntime,
      blockedSeamIds: blockedSeamIds ?? this.blockedSeamIds,
      warningReasons: warningReasons ?? this.warningReasons,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'preconditionId': preconditionId,
      'description': description,
      'executableNow': executableNow,
      'requiredForFutureRuntime': requiredForFutureRuntime,
      'blockedSeamIds': blockedSeamIds,
      'warningReasons': warningReasons,
      'recommendation': recommendation,
    };
  }
}

class ControlledAnalyzerAdapterRuntimePreparationEnvelope {
  const ControlledAnalyzerAdapterRuntimePreparationEnvelope({
    required this.envelopeId,
    required this.envelopeRole,
    required this.preparationId,
    required this.sourcePhase,
    required this.sourceDiagnosticIds,
    required this.sourceCaseIds,
    required this.sourceActionIds,
    required this.sourcePatchIds,
    required this.sourceRefinementIds,
    required this.preconditionIds,
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
    required this.productOutputAllowed,
    required this.persistenceAllowed,
    required this.schedulerAllowed,
    required this.productAdapterAllowed,
    required this.savedAnalysisAllowed,
    required this.recommendation,
  });

  final String envelopeId;
  final String envelopeRole;
  final String preparationId;
  final String sourcePhase;
  final List<String> sourceDiagnosticIds;
  final List<String> sourceCaseIds;
  final List<String> sourceActionIds;
  final List<String> sourcePatchIds;
  final List<String> sourceRefinementIds;
  final List<String> preconditionIds;
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
  final bool productOutputAllowed;
  final bool persistenceAllowed;
  final bool schedulerAllowed;
  final bool productAdapterAllowed;
  final bool savedAnalysisAllowed;
  final String recommendation;

  ControlledAnalyzerAdapterRuntimePreparationEnvelope copyWith({
    String? envelopeId,
    String? envelopeRole,
    String? preparationId,
    String? sourcePhase,
    List<String>? sourceDiagnosticIds,
    List<String>? sourceCaseIds,
    List<String>? sourceActionIds,
    List<String>? sourcePatchIds,
    List<String>? sourceRefinementIds,
    List<String>? preconditionIds,
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
    bool? productOutputAllowed,
    bool? persistenceAllowed,
    bool? schedulerAllowed,
    bool? productAdapterAllowed,
    bool? savedAnalysisAllowed,
    String? recommendation,
  }) {
    return ControlledAnalyzerAdapterRuntimePreparationEnvelope(
      envelopeId: envelopeId ?? this.envelopeId,
      envelopeRole: envelopeRole ?? this.envelopeRole,
      preparationId: preparationId ?? this.preparationId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      sourceDiagnosticIds: sourceDiagnosticIds ?? this.sourceDiagnosticIds,
      sourceCaseIds: sourceCaseIds ?? this.sourceCaseIds,
      sourceActionIds: sourceActionIds ?? this.sourceActionIds,
      sourcePatchIds: sourcePatchIds ?? this.sourcePatchIds,
      sourceRefinementIds: sourceRefinementIds ?? this.sourceRefinementIds,
      preconditionIds: preconditionIds ?? this.preconditionIds,
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
      productOutputAllowed: productOutputAllowed ?? this.productOutputAllowed,
      persistenceAllowed: persistenceAllowed ?? this.persistenceAllowed,
      schedulerAllowed: schedulerAllowed ?? this.schedulerAllowed,
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
      'preparationId': preparationId,
      'sourcePhase': sourcePhase,
      'sourceDiagnosticIds': sourceDiagnosticIds,
      'sourceCaseIds': sourceCaseIds,
      'sourceActionIds': sourceActionIds,
      'sourcePatchIds': sourcePatchIds,
      'sourceRefinementIds': sourceRefinementIds,
      'preconditionIds': preconditionIds,
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
      'productOutputAllowed': productOutputAllowed,
      'persistenceAllowed': persistenceAllowed,
      'schedulerAllowed': schedulerAllowed,
      'productAdapterAllowed': productAdapterAllowed,
      'savedAnalysisAllowed': savedAnalysisAllowed,
      'recommendation': recommendation,
    };
  }
}

class ControlledAnalyzerAdapterRuntimePreparationBlockedSeam {
  const ControlledAnalyzerAdapterRuntimePreparationBlockedSeam({
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

  ControlledAnalyzerAdapterRuntimePreparationBlockedSeam copyWith({
    String? blockedSeamId,
    String? seamRole,
    String? targetSurface,
    bool? blocked,
    String? blockReason,
    List<String>? deniedFieldIds,
    String? recommendation,
  }) {
    return ControlledAnalyzerAdapterRuntimePreparationBlockedSeam(
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

class ControlledAnalyzerAdapterRuntimePreparationResult {
  ControlledAnalyzerAdapterRuntimePreparationResult({
    required this.status,
    required this.sourceMetadataRefinementDiagnosticStatus,
    required this.sourceMetadataRefinementStatus,
    required this.sourcePatchSetDiagnosticStatus,
    required this.input,
    required this.policy,
    required this.preconditions,
    required this.envelopes,
    required this.blockedSeams,
    required this.findings,
    required this.safeForPhase34H,
    required this.nextRecommendation,
  }) : totalPreconditions = preconditions.length,
       totalEnvelopes = envelopes.length,
       inputEnvelopeCount = envelopes
           .where((envelope) => envelope.envelopeRole == _inputEnvelopeRole)
           .length,
       outputEnvelopeCount = envelopes
           .where((envelope) => envelope.envelopeRole == _outputEnvelopeRole)
           .length,
       totalBlockedSeams = blockedSeams.length,
       deniedFieldCount = _sorted(policy.deniedFieldIds).length,
       ownerProofQueueCount = input.ownerProofRequired ? 1 : 0,
       activeDeniedFieldCount =
           _countUnblockedDeniedSeams(blockedSeams) +
           _countEnvelopeEnabledDenied(envelopes),
       productOutputCount =
           (policy.productOutputAllowed ? 1 : 0) +
           envelopes.where((envelope) => envelope.productOutputAllowed).length,
       productAdapterCount =
           (policy.productAdapterAllowed ? 1 : 0) +
           envelopes.where((envelope) => envelope.productAdapterAllowed).length,
       savedAnalysisIntegrationCount =
           (policy.savedAnalysisAllowed ? 1 : 0) +
           envelopes.where((envelope) => envelope.savedAnalysisAllowed).length,
       analyzerWiringCount =
           (policy.analyzerWiringAllowed ? 1 : 0) +
           envelopes.where((envelope) => envelope.analyzerWiringAllowed).length,
       runtimeExecutionCount =
           (policy.executionAllowed ? 1 : 0) +
           envelopes.where((envelope) => envelope.executionAllowed).length +
           preconditions
               .where((precondition) => precondition.executableNow)
               .length,
       executableRuntimeCount = policy.executableRuntimeAllowed ? 1 : 0,
       engineCallCount =
           (policy.engineCallsAllowed ? 1 : 0) +
           envelopes.where((envelope) => envelope.engineCallsAllowed).length,
       schedulerExecutionCount =
           (policy.schedulerAllowed ? 1 : 0) +
           envelopes.where((envelope) => envelope.schedulerAllowed).length,
       persistenceWriteCount =
           (policy.persistenceAllowed ? 1 : 0) +
           envelopes.where((envelope) => envelope.persistenceAllowed).length,
       uiTargetCount = policy.uiAllowed ? 1 : 0,
       backendTargetCount = policy.backendAllowed ? 1 : 0,
       cacheDatabaseWriteCount =
           (policy.cacheAllowed ? 1 : 0) + (policy.databaseAllowed ? 1 : 0),
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

  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationStatus status;
  final String sourceMetadataRefinementDiagnosticStatus;
  final String sourceMetadataRefinementStatus;
  final String sourcePatchSetDiagnosticStatus;
  final ControlledAnalyzerAdapterRuntimePreparationInput input;
  final ControlledAnalyzerAdapterRuntimePreparationPolicy policy;
  final List<ControlledAnalyzerAdapterRuntimePreparationPrecondition>
  preconditions;
  final List<ControlledAnalyzerAdapterRuntimePreparationEnvelope> envelopes;
  final List<ControlledAnalyzerAdapterRuntimePreparationBlockedSeam>
  blockedSeams;
  final List<String> findings;
  final bool safeForPhase34H;
  final String nextRecommendation;
  final int totalPreconditions;
  final int totalEnvelopes;
  final int inputEnvelopeCount;
  final int outputEnvelopeCount;
  final int totalBlockedSeams;
  final int deniedFieldCount;
  final int ownerProofQueueCount;
  final int activeDeniedFieldCount;
  final int productOutputCount;
  final int productAdapterCount;
  final int savedAnalysisIntegrationCount;
  final int analyzerWiringCount;
  final int runtimeExecutionCount;
  final int executableRuntimeCount;
  final int engineCallCount;
  final int schedulerExecutionCount;
  final int persistenceWriteCount;
  final int uiTargetCount;
  final int backendTargetCount;
  final int cacheDatabaseWriteCount;
  final int phase32EProofClaimCount;
  final int unprovenAndroidProofCount;
  late final int unsafeCount;
  late final int blockerCount;
  late final int criticalCount;

  bool get hasUnsafePolicyViolation =>
      !safeForPhase34H ||
      findings.isNotEmpty ||
      activeDeniedFieldCount > 0 ||
      productOutputCount > 0 ||
      productAdapterCount > 0 ||
      savedAnalysisIntegrationCount > 0 ||
      analyzerWiringCount > 0 ||
      runtimeExecutionCount > 0 ||
      executableRuntimeCount > 0 ||
      engineCallCount > 0 ||
      schedulerExecutionCount > 0 ||
      persistenceWriteCount > 0 ||
      uiTargetCount > 0 ||
      backendTargetCount > 0 ||
      cacheDatabaseWriteCount > 0 ||
      phase32EProofClaimCount > 0 ||
      unprovenAndroidProofCount > 0 ||
      ownerProofQueueCount > 0;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Controlled Analyzer Adapter Runtime Preparation')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationVersion',
      )
      ..writeln('- preparation status: ${status.wire}')
      ..writeln(
        '- source metadata refinement diagnostic status: $sourceMetadataRefinementDiagnosticStatus',
      )
      ..writeln('- safe for Phase 34H: $safeForPhase34H')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln()
      ..writeln('## Disabled Execution Policy')
      ..writeln('- executionAllowed: ${policy.executionAllowed}')
      ..writeln('- analyzerWiringAllowed: ${policy.analyzerWiringAllowed}')
      ..writeln('- engineCallsAllowed: ${policy.engineCallsAllowed}')
      ..writeln('- schedulerAllowed: ${policy.schedulerAllowed}')
      ..writeln('- persistenceAllowed: ${policy.persistenceAllowed}')
      ..writeln('- productOutputAllowed: ${policy.productOutputAllowed}')
      ..writeln('- productAdapterAllowed: ${policy.productAdapterAllowed}')
      ..writeln('- savedAnalysisAllowed: ${policy.savedAnalysisAllowed}')
      ..writeln()
      ..writeln('## Runtime Preconditions')
      ..writeln(
        '| Precondition | Executable now | Future runtime required | Blocked seams |',
      )
      ..writeln('| --- | --- | --- | --- |');
    for (final precondition in preconditions) {
      buffer.writeln(
        '| ${precondition.preconditionId} | ${precondition.executableNow} | ${precondition.requiredForFutureRuntime} | ${_ids(precondition.blockedSeamIds)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Runtime Preparation Envelopes')
      ..writeln(
        '| Envelope | Role | Execution allowed | Analyzer wiring allowed | Engine calls allowed | Product output allowed |',
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
      ..writeln('| Seam | Role | Target surface | Blocked |')
      ..writeln('| --- | --- | --- | --- |');
    for (final seam in blockedSeams) {
      buffer.writeln(
        '| ${seam.blockedSeamId} | ${seam.seamRole} | ${seam.targetSurface} | ${seam.blocked} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Denied Field Summary')
      ..writeln('- denied field count: $deniedFieldCount')
      ..writeln('- denied field ids: ${_ids(policy.deniedFieldIds)}')
      ..writeln()
      ..writeln('## Source Chain Summary')
      ..writeln('- source phase: ${input.sourcePhase}')
      ..writeln('- source diagnostics: ${_ids(input.sourceDiagnosticIds)}')
      ..writeln('- source cases: ${_ids(input.sourceCaseIds)}')
      ..writeln('- source actions: ${_ids(input.sourceActionIds)}')
      ..writeln('- source patches: ${_ids(input.sourcePatchIds)}')
      ..writeln('- source refinements: ${_ids(input.sourceRefinementIds)}')
      ..writeln()
      ..writeln('## Safety Summary')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
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
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Recommendation')
      ..writeln('- safe for Phase 34H: $safeForPhase34H')
      ..writeln('- next recommendation: $nextRecommendation')
      ..writeln('- findings: ${_ids(findings)}')
      ..writeln();
    return buffer.toString();
  }

  String renderJson() {
    return const JsonEncoder.withIndent(' ').convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version':
          debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationVersion,
      'status': status.wire,
      'sourceMetadataRefinementDiagnosticStatus':
          sourceMetadataRefinementDiagnosticStatus,
      'sourceMetadataRefinementStatus': sourceMetadataRefinementStatus,
      'sourcePatchSetDiagnosticStatus': sourcePatchSetDiagnosticStatus,
      'safeForPhase34H': safeForPhase34H,
      'nextRecommendation': nextRecommendation,
      'counts': <String, Object?>{
        'totalPreconditions': totalPreconditions,
        'totalEnvelopes': totalEnvelopes,
        'inputEnvelopeCount': inputEnvelopeCount,
        'outputEnvelopeCount': outputEnvelopeCount,
        'totalBlockedSeams': totalBlockedSeams,
        'deniedFieldCount': deniedFieldCount,
        'unsafeCount': unsafeCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'activeDeniedFieldCount': activeDeniedFieldCount,
        'runtimeExecutionCount': runtimeExecutionCount,
        'executableRuntimeCount': executableRuntimeCount,
        'analyzerWiringCount': analyzerWiringCount,
        'engineCallCount': engineCallCount,
        'schedulerExecutionCount': schedulerExecutionCount,
        'persistenceWriteCount': persistenceWriteCount,
        'productOutputCount': productOutputCount,
        'productAdapterCount': productAdapterCount,
        'savedAnalysisIntegrationCount': savedAnalysisIntegrationCount,
        'ownerProofQueueCount': ownerProofQueueCount,
        'phase32EProofClaimCount': phase32EProofClaimCount,
        'unprovenAndroidProofCount': unprovenAndroidProofCount,
      },
      'input': input.toJson(),
      'policy': policy.toJson(),
      'preconditions': preconditions
          .map((precondition) => precondition.toJson())
          .toList(growable: false),
      'envelopes': envelopes
          .map((envelope) => envelope.toJson())
          .toList(growable: false),
      'blockedSeams': blockedSeams
          .map((seam) => seam.toJson())
          .toList(growable: false),
      'findings': findings,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation {
  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation();

  ControlledAnalyzerAdapterRuntimePreparationResult evaluate({
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticResult?
    metadataRefinementDiagnosticResult,
  }) {
    final source =
        metadataRefinementDiagnosticResult ??
        const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnostic()
            .evaluate();
    if (source.hasUnsafePolicyViolation || !source.safeForPhase34G) {
      return _blockedResult(source);
    }

    final input = _inputFromSource(source);
    final policy =
        ControlledAnalyzerAdapterRuntimePreparationPolicy.disabledDefault(
          deniedFieldIds: _sorted(<String>[
            ..._defaultDeniedFieldIds,
            ...source.rows.expand((row) => row.deniedFieldIds),
          ]),
        );
    final blockedSeams = _blockedSeams(policy.deniedFieldIds);
    final preconditions = _preconditions(input.warningReasons);
    final envelopes = _envelopes(input, preconditions, blockedSeams, policy);
    final result = ControlledAnalyzerAdapterRuntimePreparationResult(
      status: DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationStatus
          .controlledAnalyzerAdapterRuntimePreparationReadyWithWarnings,
      sourceMetadataRefinementDiagnosticStatus: source.status.wire,
      sourceMetadataRefinementStatus: source.sourceMetadataRefinementStatus,
      sourcePatchSetDiagnosticStatus: source.sourcePatchSetStatus,
      input: input,
      policy: policy,
      preconditions: preconditions,
      envelopes: envelopes,
      blockedSeams: blockedSeams,
      findings:
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationValidator()
              .validatePreparation(
                input: input,
                policy: policy,
                preconditions: preconditions,
                envelopes: envelopes,
                blockedSeams: blockedSeams,
                nextRecommendation: _phase34HRecommendation,
              ),
      safeForPhase34H: true,
      nextRecommendation: _phase34HRecommendation,
    );
    if (result.findings.isEmpty) return result;
    return ControlledAnalyzerAdapterRuntimePreparationResult(
      status: DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationStatus
          .blockedByPolicyBoundary,
      sourceMetadataRefinementDiagnosticStatus:
          result.sourceMetadataRefinementDiagnosticStatus,
      sourceMetadataRefinementStatus: result.sourceMetadataRefinementStatus,
      sourcePatchSetDiagnosticStatus: result.sourcePatchSetDiagnosticStatus,
      input: input,
      policy: policy,
      preconditions: preconditions,
      envelopes: envelopes,
      blockedSeams: blockedSeams,
      findings: result.findings,
      safeForPhase34H: false,
      nextRecommendation: 'blockedByUnsafeControlledRuntimePreparation',
    );
  }

  ControlledAnalyzerAdapterRuntimePreparationResult _blockedResult(
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticResult
    source,
  ) {
    final input = ControlledAnalyzerAdapterRuntimePreparationInput(
      preparationId: _preparationId,
      sourcePhase: 'Phase34F',
      sourceDiagnosticIds: const <String>[],
      sourceCaseIds: const <String>[],
      sourceActionIds: const <String>[],
      sourcePatchIds: const <String>[],
      sourceRefinementIds: const <String>[],
      supportAreaIds: const <String>[],
      warningReasons: const <String>['unsafePhase34FDiagnostic'],
      proofLimitReasons: const <String>[],
      androidProofIds: const <String>[],
      ownerProofRequired: false,
      recommendation: 'blockedByUnsafeControlledRuntimePreparation',
    );
    final policy =
        ControlledAnalyzerAdapterRuntimePreparationPolicy.disabledDefault();
    return ControlledAnalyzerAdapterRuntimePreparationResult(
      status: DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationStatus
          .blockedByUnsafeMetadataRefinementDiagnostic,
      sourceMetadataRefinementDiagnosticStatus: source.status.wire,
      sourceMetadataRefinementStatus: source.sourceMetadataRefinementStatus,
      sourcePatchSetDiagnosticStatus: source.sourcePatchSetStatus,
      input: input,
      policy: policy,
      preconditions:
          const <ControlledAnalyzerAdapterRuntimePreparationPrecondition>[],
      envelopes: const <ControlledAnalyzerAdapterRuntimePreparationEnvelope>[],
      blockedSeams:
          const <ControlledAnalyzerAdapterRuntimePreparationBlockedSeam>[],
      findings: const <String>['unsafePhase34FMetadataRefinementDiagnostic'],
      safeForPhase34H: false,
      nextRecommendation: 'blockedByUnsafeControlledRuntimePreparation',
    );
  }
}

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationValidator {
  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationValidator();

  List<String> validateResult(
    ControlledAnalyzerAdapterRuntimePreparationResult result,
  ) {
    return validatePreparation(
      input: result.input,
      policy: result.policy,
      preconditions: result.preconditions,
      envelopes: result.envelopes,
      blockedSeams: result.blockedSeams,
      nextRecommendation: result.nextRecommendation,
    );
  }

  List<String> validatePreparation({
    required ControlledAnalyzerAdapterRuntimePreparationInput input,
    required ControlledAnalyzerAdapterRuntimePreparationPolicy policy,
    required Iterable<ControlledAnalyzerAdapterRuntimePreparationPrecondition>
    preconditions,
    required Iterable<ControlledAnalyzerAdapterRuntimePreparationEnvelope>
    envelopes,
    required Iterable<ControlledAnalyzerAdapterRuntimePreparationBlockedSeam>
    blockedSeams,
    required String nextRecommendation,
  }) {
    final findings = <String>[
      if (nextRecommendation != _phase34HRecommendation)
        'missingPhase34HRuntimePreparationDiagnosticRecommendation',
      ...validateInput(input),
      ...validatePolicy(policy),
    ];
    for (final precondition in preconditions) {
      findings.addAll(validatePrecondition(precondition));
    }
    for (final envelope in envelopes) {
      findings.addAll(validateEnvelope(envelope));
    }
    for (final seam in blockedSeams) {
      findings.addAll(validateBlockedSeam(seam));
    }
    return _sorted(findings);
  }

  List<String> validateInput(
    ControlledAnalyzerAdapterRuntimePreparationInput input,
  ) {
    return _sorted(<String>[
      if (input.recommendation != _phase34HRecommendation)
        'missingPhase34HRuntimePreparationDiagnosticRecommendation',
      if (input.ownerProofRequired &&
          !input.proofLimitReasons.any(_mentionsPvMultiPv))
        'ownerProofWithoutPvMultiPvReason',
      if (input.androidProofIds.any(_phase32ECaseIds.contains))
        'phase32ECapturedProofClaim',
      if (input.androidProofIds.any(
        (id) => !_capturedAndroidProofIds.contains(id),
      ))
        'unprovenAndroidProofClaim',
      if (_isQuietSupport(input.supportAreaIds)) 'quietPreparatoryPromotion',
      if (input.sourceCaseIds.contains(_pvMultiPvBoundaryCaseId) &&
          !input.proofLimitReasons.any(_mentionsPvMultiPv))
        'pvMultiPvPromotion',
    ]);
  }

  List<String> validatePolicy(
    ControlledAnalyzerAdapterRuntimePreparationPolicy policy,
  ) {
    final activeDenied = _activeDeniedFieldIds(policy.deniedFieldIds);
    return _sorted(<String>[
      if (policy.executionAllowed) 'executionAllowedEnabled',
      if (policy.analyzerWiringAllowed) 'analyzerWiringEnabled',
      if (policy.engineCallsAllowed) 'engineCallsEnabled',
      if (policy.schedulerAllowed) 'schedulerExecutionEnabled',
      if (policy.persistenceAllowed) 'persistenceWriteEnabled',
      if (policy.productOutputAllowed) 'productOutputEnabled',
      if (policy.productAdapterAllowed) 'productAdapterEnabled',
      if (policy.savedAnalysisAllowed) 'savedAnalysisIntegrationEnabled',
      if (policy.uiAllowed || policy.backendAllowed)
        'uiBackendActivationEnabled',
      if (policy.cacheAllowed || policy.databaseAllowed)
        'cacheDatabaseWriteEnabled',
      if (policy.executableRuntimeAllowed) 'executableRuntimeEnabled',
      if (activeDenied.isNotEmpty) 'activeDeniedFields',
      if (activeDenied.any(_productFields.contains)) 'productLabelsEnabled',
      if (activeDenied.any(_finalLabelFields.contains)) 'finalLabelsEnabled',
      if (activeDenied.any(_classifierFields.contains))
        'classifierLabelsEnabled',
      if (activeDenied.any(_scoreFields.contains)) 'scoresEnabled',
      if (activeDenied.any(_rankingMetricFields.contains))
        'rankingsMetricsEnabled',
      if (activeDenied.contains('cpLoss')) 'cpLossEnabled',
      if (activeDenied.contains('winProbability')) 'winProbabilityEnabled',
      if (activeDenied.contains('thresholds')) 'thresholdsEnabled',
      if (activeDenied.contains('stockfishCommand')) 'stockfishCommandEnabled',
      if (activeDenied.contains('rawUci')) 'rawUciEnabled',
      if (activeDenied.contains('pvDump')) 'pvDumpEnabled',
      if (activeDenied.contains('androidCollectorRequirement'))
        'androidCollectorRequirementEnabled',
      if (activeDenied.contains('readinessSummaryChain'))
        'readinessSummaryChainEnabled',
      if (activeDenied.contains('readinessGate')) 'readinessGateEnabled',
    ]);
  }

  List<String> validatePrecondition(
    ControlledAnalyzerAdapterRuntimePreparationPrecondition precondition,
  ) {
    return _sorted(<String>[
      if (precondition.executableNow) 'runtimePreconditionExecutable',
      if (precondition.recommendation != _phase34HRecommendation)
        'missingPhase34HRuntimePreparationDiagnosticRecommendation',
    ]);
  }

  List<String> validateEnvelope(
    ControlledAnalyzerAdapterRuntimePreparationEnvelope envelope,
  ) {
    final activeDenied = _activeDeniedFieldIds(envelope.deniedFieldIds);
    return _sorted(<String>[
      if (!_allowedEnvelopeRoles.contains(envelope.envelopeRole))
        'unknownEnvelopeRole',
      if (envelope.executionAllowed) 'runtimeExecutionResultEnabled',
      if (envelope.analyzerWiringAllowed) 'analyzerResultEnabled',
      if (envelope.engineCallsAllowed) 'engineResultEnabled',
      if (envelope.schedulerAllowed) 'schedulerExecutionResultEnabled',
      if (envelope.persistenceAllowed) 'persistenceWriteEnabled',
      if (envelope.productOutputAllowed) 'productOutputEnabled',
      if (envelope.productAdapterAllowed) 'productAdapterEnabled',
      if (envelope.savedAnalysisAllowed) 'savedAnalysisIntegrationEnabled',
      if (envelope.ownerProofRequired &&
          !envelope.proofLimitReasons.any(_mentionsPvMultiPv))
        'ownerProofWithoutPvMultiPvReason',
      if (envelope.androidProofIds.any(_phase32ECaseIds.contains))
        'phase32ECapturedProofClaim',
      if (envelope.androidProofIds.any(
        (id) => !_capturedAndroidProofIds.contains(id),
      ))
        'unprovenAndroidProofClaim',
      if (_isQuietSupport(envelope.supportAreaIds)) 'quietPreparatoryPromotion',
      if (envelope.sourceCaseIds.contains(_pvMultiPvBoundaryCaseId) &&
          !envelope.proofLimitReasons.any(_mentionsPvMultiPv))
        'pvMultiPvPromotion',
      if (activeDenied.isNotEmpty &&
          (envelope.executionAllowed ||
              envelope.analyzerWiringAllowed ||
              envelope.engineCallsAllowed ||
              envelope.productOutputAllowed))
        'activeDeniedFields',
      if (activeDenied.any(_productFields.contains)) 'productLabelsEnabled',
      if (activeDenied.any(_finalLabelFields.contains)) 'finalLabelsEnabled',
      if (activeDenied.any(_classifierFields.contains))
        'classifierLabelsEnabled',
      if (activeDenied.any(_scoreFields.contains)) 'scoresEnabled',
      if (activeDenied.any(_rankingMetricFields.contains))
        'rankingsMetricsEnabled',
      if (activeDenied.contains('cpLoss')) 'cpLossEnabled',
      if (activeDenied.contains('winProbability')) 'winProbabilityEnabled',
      if (activeDenied.contains('thresholds')) 'thresholdsEnabled',
      if (activeDenied.contains('stockfishCommand')) 'stockfishCommandEnabled',
      if (activeDenied.contains('rawUci')) 'rawUciEnabled',
      if (activeDenied.contains('pvDump')) 'pvDumpEnabled',
    ]);
  }

  List<String> validateBlockedSeam(
    ControlledAnalyzerAdapterRuntimePreparationBlockedSeam seam,
  ) {
    return _sorted(<String>[
      if (!_requiredBlockedSeamIds.contains(seam.blockedSeamId))
        'unknownBlockedSeam',
      if (!_allowedBlockedTargets.contains(seam.targetSurface))
        'unknownBlockedTargetSurface',
      if (!seam.blocked) 'blockedSeamActivated',
      if (!seam.blocked && seam.deniedFieldIds.isNotEmpty) 'activeDeniedFields',
      if (!seam.blocked && seam.blockedSeamId == 'analyzerRuntime')
        'runtimeExecutionResultEnabled',
      if (!seam.blocked && seam.blockedSeamId == 'analyzerWiring')
        'analyzerWiringEnabled',
      if (!seam.blocked && seam.blockedSeamId == 'engineCall')
        'engineResultEnabled',
      if (!seam.blocked && seam.blockedSeamId == 'schedulerExecution')
        'schedulerExecutionResultEnabled',
      if (!seam.blocked && seam.blockedSeamId == 'persistenceWrite')
        'persistenceWriteEnabled',
      if (!seam.blocked && seam.blockedSeamId == 'productAdapter')
        'productAdapterEnabled',
      if (!seam.blocked && seam.blockedSeamId == 'savedAnalysisIntegration')
        'savedAnalysisIntegrationEnabled',
      if (!seam.blocked &&
          (seam.blockedSeamId == 'UI' || seam.blockedSeamId == 'backend'))
        'uiBackendActivationEnabled',
      if (!seam.blocked &&
          (seam.blockedSeamId == 'cache' || seam.blockedSeamId == 'database'))
        'cacheDatabaseWriteEnabled',
      if (seam.recommendation != _phase34HRecommendation)
        'missingPhase34HRuntimePreparationDiagnosticRecommendation',
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
}

ControlledAnalyzerAdapterRuntimePreparationInput _inputFromSource(
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticResult
  source,
) {
  return ControlledAnalyzerAdapterRuntimePreparationInput(
    preparationId: _preparationId,
    sourcePhase: 'Phase34F',
    sourceDiagnosticIds: _sorted(source.rows.map((row) => row.diagnosticRowId)),
    sourceCaseIds: _sorted(source.rows.map((row) => row.sourceCaseId)),
    sourceActionIds: _sorted(source.rows.map((row) => row.sourceActionId)),
    sourcePatchIds: _sorted(source.rows.map((row) => row.sourcePatchId)),
    sourceRefinementIds: _sorted(source.rows.map((row) => row.refinementId)),
    supportAreaIds: _sorted(
      source.rows
          .expand((row) => row.supportAreaIds)
          .where((id) => id != 'quietMove' && id != 'quietPreparatoryMove'),
    ),
    warningReasons: _sorted(source.rows.expand((row) => row.warningReasons)),
    proofLimitReasons: _sorted(
      source.rows.expand((row) => row.proofLimitReasons),
    ),
    androidProofIds: _sorted(source.rows.expand((row) => row.androidProofIds)),
    ownerProofRequired: source.ownerProofQueueCount > 0,
    recommendation: _phase34HRecommendation,
  );
}

List<ControlledAnalyzerAdapterRuntimePreparationPrecondition> _preconditions(
  List<String> warningReasons,
) {
  return <ControlledAnalyzerAdapterRuntimePreparationPrecondition>[
    ControlledAnalyzerAdapterRuntimePreparationPrecondition(
      preconditionId: 'phase34HDiagnosticRequired',
      description:
          'Run the controlled runtime preparation diagnostic before any runtime skeleton.',
      executableNow: false,
      requiredForFutureRuntime: true,
      blockedSeamIds: const <String>['analyzerRuntime', 'analyzerWiring'],
      warningReasons: warningReasons,
      recommendation: _phase34HRecommendation,
    ),
    const ControlledAnalyzerAdapterRuntimePreparationPrecondition(
      preconditionId: 'disabledExecutionPolicyRequired',
      description:
          'Keep every execution permission disabled until a later explicit runtime phase.',
      executableNow: false,
      requiredForFutureRuntime: true,
      blockedSeamIds: <String>[
        'analyzerRuntime',
        'engineCall',
        'schedulerExecution',
      ],
      warningReasons: <String>[],
      recommendation: _phase34HRecommendation,
    ),
    const ControlledAnalyzerAdapterRuntimePreparationPrecondition(
      preconditionId: 'productAndPersistenceBlocked',
      description:
          'Keep product adapter, saved analysis, UI, backend, cache, and database seams blocked.',
      executableNow: false,
      requiredForFutureRuntime: true,
      blockedSeamIds: <String>[
        'productAdapter',
        'savedAnalysisIntegration',
        'UI',
        'backend',
        'cache',
        'database',
      ],
      warningReasons: <String>[],
      recommendation: _phase34HRecommendation,
    ),
  ];
}

List<ControlledAnalyzerAdapterRuntimePreparationEnvelope> _envelopes(
  ControlledAnalyzerAdapterRuntimePreparationInput input,
  List<ControlledAnalyzerAdapterRuntimePreparationPrecondition> preconditions,
  List<ControlledAnalyzerAdapterRuntimePreparationBlockedSeam> blockedSeams,
  ControlledAnalyzerAdapterRuntimePreparationPolicy policy,
) {
  final preconditionIds = preconditions
      .map((precondition) => precondition.preconditionId)
      .toList(growable: false);
  final blockedSeamIds = blockedSeams
      .map((seam) => seam.blockedSeamId)
      .toList(growable: false);
  ControlledAnalyzerAdapterRuntimePreparationEnvelope envelope(
    String id,
    String role,
  ) {
    return ControlledAnalyzerAdapterRuntimePreparationEnvelope(
      envelopeId: id,
      envelopeRole: role,
      preparationId: input.preparationId,
      sourcePhase: input.sourcePhase,
      sourceDiagnosticIds: input.sourceDiagnosticIds,
      sourceCaseIds: input.sourceCaseIds,
      sourceActionIds: input.sourceActionIds,
      sourcePatchIds: input.sourcePatchIds,
      sourceRefinementIds: input.sourceRefinementIds,
      preconditionIds: preconditionIds,
      blockedSeamIds: blockedSeamIds,
      deniedFieldIds: policy.deniedFieldIds,
      supportAreaIds: input.supportAreaIds,
      warningReasons: input.warningReasons,
      proofLimitReasons: input.proofLimitReasons,
      androidProofIds: input.androidProofIds,
      ownerProofRequired: input.ownerProofRequired,
      executionAllowed: false,
      analyzerWiringAllowed: false,
      engineCallsAllowed: false,
      productOutputAllowed: false,
      persistenceAllowed: false,
      schedulerAllowed: false,
      productAdapterAllowed: false,
      savedAnalysisAllowed: false,
      recommendation: _phase34HRecommendation,
    );
  }

  return <ControlledAnalyzerAdapterRuntimePreparationEnvelope>[
    envelope(
      'controlled-runtime-preparation-input-envelope',
      _inputEnvelopeRole,
    ),
    envelope(
      'controlled-runtime-preparation-output-envelope',
      _outputEnvelopeRole,
    ),
  ];
}

List<ControlledAnalyzerAdapterRuntimePreparationBlockedSeam> _blockedSeams(
  List<String> deniedFieldIds,
) {
  return _requiredBlockedSeamIds
      .map(
        (id) => ControlledAnalyzerAdapterRuntimePreparationBlockedSeam(
          blockedSeamId: id,
          seamRole: '${id}BlockedSeam',
          targetSurface: id,
          blocked: true,
          blockReason:
              'Blocked by Phase 34G disabled runtime-preparation policy.',
          deniedFieldIds: deniedFieldIds,
          recommendation: _phase34HRecommendation,
        ),
      )
      .toList(growable: false);
}

int _countUnblockedDeniedSeams(
  Iterable<ControlledAnalyzerAdapterRuntimePreparationBlockedSeam> seams,
) {
  return seams
      .where((seam) => !seam.blocked && seam.deniedFieldIds.isNotEmpty)
      .length;
}

int _countEnvelopeEnabledDenied(
  Iterable<ControlledAnalyzerAdapterRuntimePreparationEnvelope> envelopes,
) {
  return envelopes
      .where(
        (envelope) =>
            envelope.deniedFieldIds.isNotEmpty &&
            (envelope.executionAllowed ||
                envelope.analyzerWiringAllowed ||
                envelope.engineCallsAllowed ||
                envelope.productOutputAllowed),
      )
      .length;
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

const _preparationId = 'controlled-analyzer-adapter-runtime-preparation';
const _inputEnvelopeRole = 'futureAnalyzerAdapterRuntimeInputEnvelope';
const _outputEnvelopeRole = 'futureAnalyzerAdapterRuntimeOutputEnvelope';
const _phase34HRecommendation =
    'runControlledAnalyzerAdapterRuntimePreparationDiagnostic';
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

const _allowedEnvelopeRoles = <String>{_inputEnvelopeRole, _outputEnvelopeRole};

const _requiredBlockedSeamIds = <String>[
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
];

const _allowedBlockedTargets = <String>{
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
};

const _defaultDeniedFieldIds = <String>[
  'productLabel',
  'finalMoveLabel',
  'classifierLabels',
  'brilliantGreatMiss',
  'bestGoodInaccuracyMistakeBlunder',
  'numericMoveScore',
  'aggregateScore',
  'moveRanking',
  'officialMetric',
  'accuracy',
  'acpl',
  'cpLoss',
  'winProbability',
  'thresholds',
  'rawUci',
  'pvDump',
  'stockfishCommand',
  'engineResult',
  'analyzerResult',
  'runtimeExecutionResult',
  'savedAnalysisResult',
  'uiState',
  'backendResponse',
  'cacheDatabaseWrite',
  'schedulerExecutionResult',
  'androidCollectorRequirement',
  'readinessSummaryChain',
  'readinessGate',
];

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
  'accuracy',
  'acpl',
};

/// Developer-only evidence hardening plan for stabilized internal packets.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_review_aggregation_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_stability_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/narrow_internal_non_label_analysis_prototype.dart';

const internalPacketEvidenceHardeningPlanReportVersion =
    'internal-packet-evidence-hardening-plan-v1';

enum InternalPacketEvidenceHardeningStatus {
  readyForTargetedHardening('readyForTargetedHardening'),
  readyWithNarrowScope('readyWithNarrowScope'),
  blockedByUnsafePacket('blockedByUnsafePacket'),
  blockedByInstability('blockedByInstability'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const InternalPacketEvidenceHardeningStatus(this.wire);

  final String wire;
}

enum InternalPacketEvidenceHardeningActionType {
  preserveStablePacket('preserveStablePacket'),
  addGoldenCoverage('addGoldenCoverage'),
  addHandcraftedCase('addHandcraftedCase'),
  addFakeEvidence('addFakeEvidence'),
  keepProofLimited('keepProofLimited'),
  addOwnerAndroidProofOnlyIfPvRequired('addOwnerAndroidProofOnlyIfPvRequired'),
  keepWarningLimited('keepWarningLimited'),
  keepBlockedByPolicy('keepBlockedByPolicy'),
  keepExcludedByNegativeGuard('keepExcludedByNegativeGuard'),
  keepFutureOnly('keepFutureOnly'),
  investigateInstability('investigateInstability'),
  blockUnsafeScope('blockUnsafeScope');

  const InternalPacketEvidenceHardeningActionType(this.wire);

  final String wire;
}

enum InternalPacketEvidenceHardeningTargetKind {
  packet('packet'),
  warningScope('warningScope'),
  blockedScope('blockedScope'),
  futureOnlyScope('futureOnlyScope'),
  androidProofScope('androidProofScope');

  const InternalPacketEvidenceHardeningTargetKind(this.wire);

  final String wire;
}

enum InternalPacketEvidenceHardeningPriority {
  none('none', 0),
  low('low', 1),
  medium('medium', 2),
  high('high', 3),
  critical('critical', 4);

  const InternalPacketEvidenceHardeningPriority(this.wire, this.rank);

  final String wire;
  final int rank;
}

enum InternalPacketEvidencePhase32ERecommendation {
  addTargetedGoldenCoverageCases('addTargetedGoldenCoverageCases'),
  addTargetedFakeEvidence('addTargetedFakeEvidence'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  keepNarrowPrototypeOnly('keepNarrowPrototypeOnly'),
  blockedByUnsafeHardeningState('blockedByUnsafeHardeningState');

  const InternalPacketEvidencePhase32ERecommendation(this.wire);

  final String wire;
}

enum InternalPacketEvidenceHardeningValidationSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const InternalPacketEvidenceHardeningValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == InternalPacketEvidenceHardeningValidationSeverity.blocker ||
      this == InternalPacketEvidenceHardeningValidationSeverity.critical;
}

enum InternalPacketEvidenceHardeningPlanReportFormat {
  markdown('markdown'),
  json('json');

  const InternalPacketEvidenceHardeningPlanReportFormat(this.wire);

  final String wire;
}

class InternalPacketEvidenceHardeningPlanRequest {
  const InternalPacketEvidenceHardeningPlanRequest({
    this.stabilityResult,
    this.matrixResult,
    this.prototypeResult,
    this.stabilityPrototype = const InternalPacketStabilityPrototype(),
    this.matrix = const InternalPacketReviewAggregationMatrix(),
    this.prototype = const NarrowInternalNonLabelAnalysisPrototype(),
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.cases = GoldenAnalysisCases.defaults,
    this.includeWarningLimitedScopes = true,
    this.includeBlockedScopes = true,
    this.includeFutureOnlyScopes = true,
  });

  const InternalPacketEvidenceHardeningPlanRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarningLimitedScopes: includeWarnings);

  final InternalPacketStabilityPrototypeResult? stabilityResult;
  final InternalPacketReviewAggregationMatrixResult? matrixResult;
  final NarrowInternalNonLabelAnalysisPrototypeResult? prototypeResult;
  final InternalPacketStabilityPrototype stabilityPrototype;
  final InternalPacketReviewAggregationMatrix matrix;
  final NarrowInternalNonLabelAnalysisPrototype prototype;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final List<GoldenAnalysisCase> cases;
  final bool includeWarningLimitedScopes;
  final bool includeBlockedScopes;
  final bool includeFutureOnlyScopes;
}

class InternalPacketEvidenceHardeningTarget {
  const InternalPacketEvidenceHardeningTarget({
    required this.targetId,
    required this.targetKind,
    required this.scopeId,
    required this.currentStatus,
    required this.recommendedAction,
    required this.priority,
    required this.supportCaseIds,
    required this.androidProofCaseIds,
    required this.missingCoverageAreas,
    required this.suggestedCaseArea,
    required this.suggestedEvidenceType,
    required this.ownerProofAllowed,
    required this.ownerProofRequired,
    required this.reason,
    required this.nextStep,
    this.packetId,
    this.isProductOutput = false,
    this.isClassifierLabel = false,
    this.isOfficialMetric = false,
    this.hasNumericValue = false,
    this.ordersMoves = false,
    this.quietScopeActive = false,
    this.cpLossComputationImplemented = false,
    this.winProbabilityComputationImplemented = false,
    this.emittedOutputNames = const <String>[],
  });

  final String targetId;
  final InternalPacketEvidenceHardeningTargetKind targetKind;
  final InternalNonLabelPrototypeScopeId scopeId;
  final InternalPacketStabilityStatus currentStatus;
  final InternalPacketEvidenceHardeningActionType recommendedAction;
  final InternalPacketEvidenceHardeningPriority priority;
  final List<String> supportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> missingCoverageAreas;
  final String suggestedCaseArea;
  final String suggestedEvidenceType;
  final bool ownerProofAllowed;
  final bool ownerProofRequired;
  final String reason;
  final String nextStep;
  final String? packetId;
  final bool isProductOutput;
  final bool isClassifierLabel;
  final bool isOfficialMetric;
  final bool hasNumericValue;
  final bool ordersMoves;
  final bool quietScopeActive;
  final bool cpLossComputationImplemented;
  final bool winProbabilityComputationImplemented;
  final List<String> emittedOutputNames;

  bool get hasUnsafeOutput {
    return isProductOutput ||
        isClassifierLabel ||
        isOfficialMetric ||
        hasNumericValue ||
        ordersMoves ||
        quietScopeActive ||
        cpLossComputationImplemented ||
        winProbabilityComputationImplemented ||
        emittedOutputNames.any(_isForbiddenOutputName);
  }

  bool get addsCoverage =>
      recommendedAction ==
          InternalPacketEvidenceHardeningActionType.addGoldenCoverage ||
      recommendedAction ==
          InternalPacketEvidenceHardeningActionType.addHandcraftedCase ||
      recommendedAction ==
          InternalPacketEvidenceHardeningActionType.addFakeEvidence;

  bool get isBlockedOrFuture =>
      targetKind == InternalPacketEvidenceHardeningTargetKind.blockedScope ||
      targetKind == InternalPacketEvidenceHardeningTargetKind.futureOnlyScope;

  InternalPacketEvidenceHardeningTarget copyWith({
    String? targetId,
    InternalPacketEvidenceHardeningTargetKind? targetKind,
    InternalNonLabelPrototypeScopeId? scopeId,
    InternalPacketStabilityStatus? currentStatus,
    InternalPacketEvidenceHardeningActionType? recommendedAction,
    InternalPacketEvidenceHardeningPriority? priority,
    List<String>? supportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? missingCoverageAreas,
    String? suggestedCaseArea,
    String? suggestedEvidenceType,
    bool? ownerProofAllowed,
    bool? ownerProofRequired,
    String? reason,
    String? nextStep,
    String? packetId,
    bool? isProductOutput,
    bool? isClassifierLabel,
    bool? isOfficialMetric,
    bool? hasNumericValue,
    bool? ordersMoves,
    bool? quietScopeActive,
    bool? cpLossComputationImplemented,
    bool? winProbabilityComputationImplemented,
    List<String>? emittedOutputNames,
  }) {
    return InternalPacketEvidenceHardeningTarget(
      targetId: targetId ?? this.targetId,
      targetKind: targetKind ?? this.targetKind,
      scopeId: scopeId ?? this.scopeId,
      currentStatus: currentStatus ?? this.currentStatus,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      priority: priority ?? this.priority,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      missingCoverageAreas: missingCoverageAreas ?? this.missingCoverageAreas,
      suggestedCaseArea: suggestedCaseArea ?? this.suggestedCaseArea,
      suggestedEvidenceType:
          suggestedEvidenceType ?? this.suggestedEvidenceType,
      ownerProofAllowed: ownerProofAllowed ?? this.ownerProofAllowed,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      reason: reason ?? this.reason,
      nextStep: nextStep ?? this.nextStep,
      packetId: packetId ?? this.packetId,
      isProductOutput: isProductOutput ?? this.isProductOutput,
      isClassifierLabel: isClassifierLabel ?? this.isClassifierLabel,
      isOfficialMetric: isOfficialMetric ?? this.isOfficialMetric,
      hasNumericValue: hasNumericValue ?? this.hasNumericValue,
      ordersMoves: ordersMoves ?? this.ordersMoves,
      quietScopeActive: quietScopeActive ?? this.quietScopeActive,
      cpLossComputationImplemented:
          cpLossComputationImplemented ?? this.cpLossComputationImplemented,
      winProbabilityComputationImplemented:
          winProbabilityComputationImplemented ??
          this.winProbabilityComputationImplemented,
      emittedOutputNames: emittedOutputNames ?? this.emittedOutputNames,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'targetId': targetId,
      'targetKind': targetKind.wire,
      'scopeId': scopeId.wire,
      if (packetId != null) 'packetId': packetId,
      'currentStatus': currentStatus.wire,
      'recommendedAction': recommendedAction.wire,
      'priority': priority.wire,
      'supportCaseIds': supportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'missingCoverageAreas': missingCoverageAreas,
      'suggestedCaseArea': suggestedCaseArea,
      'suggestedEvidenceType': suggestedEvidenceType,
      'ownerProofAllowed': ownerProofAllowed,
      'ownerProofRequired': ownerProofRequired,
      'reason': reason,
      'nextStep': nextStep,
      'isProductOutput': isProductOutput,
      'isClassifierLabel': isClassifierLabel,
      'isOfficialMetric': isOfficialMetric,
      'hasNumericValue': hasNumericValue,
      'ordersMoves': ordersMoves,
      'quietScopeActive': quietScopeActive,
      'cpLossComputationImplemented': cpLossComputationImplemented,
      'winProbabilityComputationImplemented':
          winProbabilityComputationImplemented,
      'emittedOutputNames': emittedOutputNames,
    };
  }
}

class InternalPacketEvidenceHardeningPlanValidationFinding {
  const InternalPacketEvidenceHardeningPlanValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.targetId,
    this.scopeId,
    this.caseId,
  });

  final String id;
  final InternalPacketEvidenceHardeningValidationSeverity severity;
  final String message;
  final String? targetId;
  final InternalNonLabelPrototypeScopeId? scopeId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical =>
      severity == InternalPacketEvidenceHardeningValidationSeverity.critical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (targetId != null) 'targetId': targetId,
      if (scopeId != null) 'scopeId': scopeId!.wire,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class InternalPacketEvidenceHardeningPlanResult {
  const InternalPacketEvidenceHardeningPlanResult({
    required this.hardeningStatus,
    required this.sourceStabilityStatus,
    required this.sourceMatrixStatus,
    required this.sourcePrototypeStatus,
    required this.targets,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalTargets,
    required this.preserveCount,
    required this.addGoldenCoverageCount,
    required this.proofLimitedCount,
    required this.warningLimitedCount,
    required this.blockedCount,
    required this.futureOnlyCount,
    required this.highPriorityCount,
    required this.criticalCount,
    required this.supportCaseIds,
    required this.androidProofCaseIds,
    required this.suggestedHardCaseAreas,
    required this.safeForPhase32E,
    required this.phase32ERecommendation,
    this.developerOnly = true,
    this.productLabelsEmitted = false,
    this.classifierLabelsEmitted = false,
    this.finalMoveLabelsEmitted = false,
    this.officialMetricsAllowed = false,
    this.cpLossComputationImplemented = false,
    this.winProbabilityComputationImplemented = false,
    this.numericMoveValuesComputed = false,
    this.moveOrderingComputed = false,
    this.directEngineAccessUsed = false,
    this.uiOutputUsed = false,
    this.backendOutputUsed = false,
    this.persistenceUsed = false,
    this.emittedOutputFamilies = const <String>[],
  });

  final InternalPacketEvidenceHardeningStatus hardeningStatus;
  final InternalPacketStabilityPrototypeStatus sourceStabilityStatus;
  final InternalPacketReviewAggregationMatrixStatus sourceMatrixStatus;
  final NarrowInternalNonLabelAnalysisPrototypeStatus sourcePrototypeStatus;
  final List<InternalPacketEvidenceHardeningTarget> targets;
  final List<InternalPacketEvidenceHardeningPlanValidationFinding>
  validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalTargets;
  final int preserveCount;
  final int addGoldenCoverageCount;
  final int proofLimitedCount;
  final int warningLimitedCount;
  final int blockedCount;
  final int futureOnlyCount;
  final int highPriorityCount;
  final int criticalCount;
  final List<String> supportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> suggestedHardCaseAreas;
  final bool safeForPhase32E;
  final InternalPacketEvidencePhase32ERecommendation phase32ERecommendation;
  final bool developerOnly;
  final bool productLabelsEmitted;
  final bool classifierLabelsEmitted;
  final bool finalMoveLabelsEmitted;
  final bool officialMetricsAllowed;
  final bool cpLossComputationImplemented;
  final bool winProbabilityComputationImplemented;
  final bool numericMoveValuesComputed;
  final bool moveOrderingComputed;
  final bool directEngineAccessUsed;
  final bool uiOutputUsed;
  final bool backendOutputUsed;
  final bool persistenceUsed;
  final List<String> emittedOutputFamilies;

  bool get isStrictlyBlocked =>
      hardeningStatus ==
          InternalPacketEvidenceHardeningStatus.blockedByUnsafePacket ||
      hardeningStatus ==
          InternalPacketEvidenceHardeningStatus.blockedByInstability ||
      hardeningStatus ==
          InternalPacketEvidenceHardeningStatus.blockedByPolicyBoundary ||
      hardeningStatus == InternalPacketEvidenceHardeningStatus.invalid ||
      !safeForPhase32E ||
      criticalCount > 0;

  bool get hasUnsafeHardeningPolicyViolation {
    return criticalCount > 0 ||
        validationFindings.any((finding) => finding.isCritical) ||
        targets.any((target) => target.hasUnsafeOutput) ||
        productLabelsEmitted ||
        classifierLabelsEmitted ||
        finalMoveLabelsEmitted ||
        officialMetricsAllowed ||
        cpLossComputationImplemented ||
        winProbabilityComputationImplemented ||
        numericMoveValuesComputed ||
        moveOrderingComputed ||
        directEngineAccessUsed ||
        uiOutputUsed ||
        backendOutputUsed ||
        persistenceUsed ||
        emittedOutputFamilies.any(_isForbiddenOutputName);
  }

  List<InternalPacketEvidenceHardeningTarget> get preserveTargets => targets
      .where(
        (target) =>
            target.recommendedAction ==
            InternalPacketEvidenceHardeningActionType.preserveStablePacket,
      )
      .toList(growable: false);

  List<InternalPacketEvidenceHardeningTarget> get addCoverageTargets => targets
      .where(
        (target) =>
            target.recommendedAction ==
            InternalPacketEvidenceHardeningActionType.addGoldenCoverage,
      )
      .toList(growable: false);

  List<InternalPacketEvidenceHardeningTarget> get proofLimitedTargets => targets
      .where(
        (target) =>
            target.recommendedAction ==
                InternalPacketEvidenceHardeningActionType.keepProofLimited ||
            target.targetKind ==
                InternalPacketEvidenceHardeningTargetKind.androidProofScope,
      )
      .toList(growable: false);

  List<InternalPacketEvidenceHardeningTarget> get warningLimitedTargets =>
      targets
          .where(
            (target) =>
                target.targetKind ==
                InternalPacketEvidenceHardeningTargetKind.warningScope,
          )
          .toList(growable: false);

  List<InternalPacketEvidenceHardeningTarget> get blockedOrFutureTargets =>
      targets
          .where((target) => target.isBlockedOrFuture)
          .toList(growable: false);

  InternalPacketEvidenceHardeningTarget target(
    InternalNonLabelPrototypeScopeId scopeId,
  ) {
    return targets.singleWhere((target) => target.scopeId == scopeId);
  }

  InternalPacketEvidenceHardeningPlanResult copyWith({
    InternalPacketEvidenceHardeningStatus? hardeningStatus,
    InternalPacketStabilityPrototypeStatus? sourceStabilityStatus,
    InternalPacketReviewAggregationMatrixStatus? sourceMatrixStatus,
    NarrowInternalNonLabelAnalysisPrototypeStatus? sourcePrototypeStatus,
    List<InternalPacketEvidenceHardeningTarget>? targets,
    List<InternalPacketEvidenceHardeningPlanValidationFinding>?
    validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalTargets,
    int? preserveCount,
    int? addGoldenCoverageCount,
    int? proofLimitedCount,
    int? warningLimitedCount,
    int? blockedCount,
    int? futureOnlyCount,
    int? highPriorityCount,
    int? criticalCount,
    List<String>? supportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? suggestedHardCaseAreas,
    bool? safeForPhase32E,
    InternalPacketEvidencePhase32ERecommendation? phase32ERecommendation,
    bool? developerOnly,
    bool? productLabelsEmitted,
    bool? classifierLabelsEmitted,
    bool? finalMoveLabelsEmitted,
    bool? officialMetricsAllowed,
    bool? cpLossComputationImplemented,
    bool? winProbabilityComputationImplemented,
    bool? numericMoveValuesComputed,
    bool? moveOrderingComputed,
    bool? directEngineAccessUsed,
    bool? uiOutputUsed,
    bool? backendOutputUsed,
    bool? persistenceUsed,
    List<String>? emittedOutputFamilies,
  }) {
    return InternalPacketEvidenceHardeningPlanResult(
      hardeningStatus: hardeningStatus ?? this.hardeningStatus,
      sourceStabilityStatus:
          sourceStabilityStatus ?? this.sourceStabilityStatus,
      sourceMatrixStatus: sourceMatrixStatus ?? this.sourceMatrixStatus,
      sourcePrototypeStatus:
          sourcePrototypeStatus ?? this.sourcePrototypeStatus,
      targets: targets ?? this.targets,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalTargets: totalTargets ?? this.totalTargets,
      preserveCount: preserveCount ?? this.preserveCount,
      addGoldenCoverageCount:
          addGoldenCoverageCount ?? this.addGoldenCoverageCount,
      proofLimitedCount: proofLimitedCount ?? this.proofLimitedCount,
      warningLimitedCount: warningLimitedCount ?? this.warningLimitedCount,
      blockedCount: blockedCount ?? this.blockedCount,
      futureOnlyCount: futureOnlyCount ?? this.futureOnlyCount,
      highPriorityCount: highPriorityCount ?? this.highPriorityCount,
      criticalCount: criticalCount ?? this.criticalCount,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      suggestedHardCaseAreas:
          suggestedHardCaseAreas ?? this.suggestedHardCaseAreas,
      safeForPhase32E: safeForPhase32E ?? this.safeForPhase32E,
      phase32ERecommendation:
          phase32ERecommendation ?? this.phase32ERecommendation,
      developerOnly: developerOnly ?? this.developerOnly,
      productLabelsEmitted: productLabelsEmitted ?? this.productLabelsEmitted,
      classifierLabelsEmitted:
          classifierLabelsEmitted ?? this.classifierLabelsEmitted,
      finalMoveLabelsEmitted:
          finalMoveLabelsEmitted ?? this.finalMoveLabelsEmitted,
      officialMetricsAllowed:
          officialMetricsAllowed ?? this.officialMetricsAllowed,
      cpLossComputationImplemented:
          cpLossComputationImplemented ?? this.cpLossComputationImplemented,
      winProbabilityComputationImplemented:
          winProbabilityComputationImplemented ??
          this.winProbabilityComputationImplemented,
      numericMoveValuesComputed:
          numericMoveValuesComputed ?? this.numericMoveValuesComputed,
      moveOrderingComputed: moveOrderingComputed ?? this.moveOrderingComputed,
      directEngineAccessUsed:
          directEngineAccessUsed ?? this.directEngineAccessUsed,
      uiOutputUsed: uiOutputUsed ?? this.uiOutputUsed,
      backendOutputUsed: backendOutputUsed ?? this.backendOutputUsed,
      persistenceUsed: persistenceUsed ?? this.persistenceUsed,
      emittedOutputFamilies:
          emittedOutputFamilies ?? this.emittedOutputFamilies,
    );
  }

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Internal Packet Evidence Hardening Plan')
      ..writeln()
      ..writeln('- version: $internalPacketEvidenceHardeningPlanReportVersion')
      ..writeln('- hardening status: ${hardeningStatus.wire}')
      ..writeln('- source stability status: ${sourceStabilityStatus.wire}')
      ..writeln('- source matrix status: ${sourceMatrixStatus.wire}')
      ..writeln('- source prototype status: ${sourcePrototypeStatus.wire}')
      ..writeln('- total targets: $totalTargets')
      ..writeln('- preserve count: $preserveCount')
      ..writeln('- add coverage count: $addGoldenCoverageCount')
      ..writeln('- proof-limited count: $proofLimitedCount')
      ..writeln('- warning-limited count: $warningLimitedCount')
      ..writeln('- blocked count: $blockedCount')
      ..writeln('- future-only count: $futureOnlyCount')
      ..writeln('- high priority count: $highPriorityCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- safe for Phase 32E: $safeForPhase32E')
      ..writeln('- Phase 32E recommendation: ${phase32ERecommendation.wire}')
      ..writeln('- classifier output emitted: $classifierLabelsEmitted')
      ..writeln('- numeric value output emitted: $numericMoveValuesComputed')
      ..writeln('- move ordering output emitted: $moveOrderingComputed')
      ..writeln()
      ..writeln('## Hardening Policy')
      ..writeln('- this plan decides internal evidence hardening actions only')
      ..writeln(
        '- it does not classify moves, compute values, order moves, call an engine, integrate product output, or write files',
      )
      ..writeln()
      ..writeln('## Target Table')
      ..writeln(
        '| Target | Kind | Current Status | Action | Priority | Support Cases | Android Proof | Coverage Areas | Suggested Area | Evidence Type | Owner Proof | Next Step |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final target in targets) {
      buffer.writeln(
        '| ${target.targetId} | ${target.targetKind.wire} | ${target.currentStatus.wire} | ${target.recommendedAction.wire} | ${target.priority.wire} | ${_ids(target.supportCaseIds)} | ${_ids(target.androidProofCaseIds)} | ${_ids(target.missingCoverageAreas)} | ${_cell(target.suggestedCaseArea)} | ${target.suggestedEvidenceType} | ${target.ownerProofRequired
            ? "required"
            : target.ownerProofAllowed
            ? "allowed"
            : "not-needed"} | ${_cell(target.nextStep)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Priority Counts')
      ..writeln('- high priority count: $highPriorityCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln()
      ..writeln('## Preserve Actions')
      ..writeln('- ${_targetIds(preserveTargets)}')
      ..writeln()
      ..writeln('## Add-Coverage Actions')
      ..writeln('- ${_targetIds(addCoverageTargets)}')
      ..writeln()
      ..writeln('## Proof-Limited Actions')
      ..writeln('- ${_targetIds(proofLimitedTargets)}')
      ..writeln()
      ..writeln('## Warning-Limited Scopes')
      ..writeln('- ${_scopeIds(warningLimitedTargets)}')
      ..writeln()
      ..writeln('## Blocked And Future-Only Scopes')
      ..writeln('- ${_scopeIds(blockedOrFutureTargets)}')
      ..writeln()
      ..writeln('## Suggested Hard-Case Areas')
      ..writeln('- ${_ids(suggestedHardCaseAreas)}')
      ..writeln()
      ..writeln('## Support Case IDs')
      ..writeln('- ${_ids(supportCaseIds)}')
      ..writeln()
      ..writeln('## Android Proof IDs')
      ..writeln('- ${_ids(androidProofCaseIds)}')
      ..writeln()
      ..writeln('## Validation');
    if (validationFindings.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final finding in validationFindings) {
        buffer.writeln(
          '- ${finding.severity.wire}: ${finding.id} -- ${finding.message}',
        );
      }
    }
    buffer
      ..writeln()
      ..writeln('## Warnings');
    if (warnings.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final warning in warnings) {
        buffer.writeln('- $warning');
      }
    }
    buffer
      ..writeln()
      ..writeln('## Failures');
    if (failures.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final failure in failures) {
        buffer.writeln('- $failure');
      }
    }
    buffer
      ..writeln()
      ..writeln('## Phase 32E Recommendation')
      ..writeln(phase32ERecommendation.wire)
      ..writeln()
      ..writeln(
        'This plan keeps packet hardening internal-only. It does not emit user-facing output, compute product metrics, call the engine, run Android, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': internalPacketEvidenceHardeningPlanReportVersion,
      'hardeningStatus': hardeningStatus.wire,
      'sourceStabilityStatus': sourceStabilityStatus.wire,
      'sourceMatrixStatus': sourceMatrixStatus.wire,
      'sourcePrototypeStatus': sourcePrototypeStatus.wire,
      'totalTargets': totalTargets,
      'preserveCount': preserveCount,
      'addGoldenCoverageCount': addGoldenCoverageCount,
      'proofLimitedCount': proofLimitedCount,
      'warningLimitedCount': warningLimitedCount,
      'blockedCount': blockedCount,
      'futureOnlyCount': futureOnlyCount,
      'highPriorityCount': highPriorityCount,
      'criticalCount': criticalCount,
      'supportCaseIds': supportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'suggestedHardCaseAreas': suggestedHardCaseAreas,
      'safeForPhase32E': safeForPhase32E,
      'phase32ERecommendation': phase32ERecommendation.wire,
      'targets': targets.map((target) => target.toJson()).toList(),
      'validationFindings': validationFindings
          .map((finding) => finding.toJson())
          .toList(),
      'warnings': warnings,
      'failures': failures,
      'developerOnly': developerOnly,
      'productLabelsEmitted': productLabelsEmitted,
      'classifierLabelsEmitted': classifierLabelsEmitted,
      'finalMoveLabelsEmitted': finalMoveLabelsEmitted,
      'officialMetricsAllowed': officialMetricsAllowed,
      'cpLossComputationImplemented': cpLossComputationImplemented,
      'winProbabilityComputationImplemented':
          winProbabilityComputationImplemented,
      'numericMoveValuesComputed': numericMoveValuesComputed,
      'moveOrderingComputed': moveOrderingComputed,
      'directEngineAccessUsed': directEngineAccessUsed,
      'uiOutputUsed': uiOutputUsed,
      'backendOutputUsed': backendOutputUsed,
      'persistenceUsed': persistenceUsed,
      'emittedOutputFamilies': emittedOutputFamilies,
    };
  }
}

class InternalPacketEvidenceHardeningPlan {
  const InternalPacketEvidenceHardeningPlan({
    this.validator = const InternalPacketEvidenceHardeningPlanValidator(),
  });

  final InternalPacketEvidenceHardeningPlanValidator validator;

  InternalPacketEvidenceHardeningPlanResult evaluate([
    InternalPacketEvidenceHardeningPlanRequest request =
        const InternalPacketEvidenceHardeningPlanRequest(),
  ]) {
    final prototypeResult =
        request.prototypeResult ??
        request.prototype.run(
          NarrowInternalNonLabelAnalysisPrototypeRequest(
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
          ),
        );
    final matrixResult =
        request.matrixResult ??
        request.matrix.evaluate(
          InternalPacketReviewAggregationMatrixRequest(
            prototypeResult: prototypeResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarningLimitedScopes: request.includeWarningLimitedScopes,
            includeBlockedScopes: request.includeBlockedScopes,
            includeFutureOnlyScopes: request.includeFutureOnlyScopes,
          ),
        );
    final stabilityResult =
        request.stabilityResult ??
        request.stabilityPrototype.evaluate(
          InternalPacketStabilityPrototypeRequest(
            matrixResult: matrixResult,
            prototypeResult: prototypeResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarningLimitedScopes: request.includeWarningLimitedScopes,
            includeBlockedScopes: request.includeBlockedScopes,
            includeFutureOnlyScopes: request.includeFutureOnlyScopes,
          ),
        );
    final targets = _targetsFromStability(stabilityResult);
    final base = _resultFromTargets(
      targets: targets,
      stabilityResult: stabilityResult,
      matrixResult: matrixResult,
      prototypeResult: prototypeResult,
      validationFindings:
          const <InternalPacketEvidenceHardeningPlanValidationFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromTargets(
      targets: targets,
      stabilityResult: stabilityResult,
      matrixResult: matrixResult,
      prototypeResult: prototypeResult,
      validationFindings: findings,
    );
  }
}

class InternalPacketEvidenceHardeningPlanValidator {
  const InternalPacketEvidenceHardeningPlanValidator();

  List<InternalPacketEvidenceHardeningPlanValidationFinding> validate(
    InternalPacketEvidenceHardeningPlanResult result, {
    required List<GoldenAnalysisCase> cases,
    required GoldenAndroidProofEvidence? androidProofEvidence,
  }) {
    final findings = <InternalPacketEvidenceHardeningPlanValidationFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    final goldenCaseIds = cases.map((item) => item.id).toSet();

    void add({
      required String id,
      required InternalPacketEvidenceHardeningValidationSeverity severity,
      required String message,
      String? targetId,
      InternalNonLabelPrototypeScopeId? scopeId,
      String? caseId,
    }) {
      findings.add(
        InternalPacketEvidenceHardeningPlanValidationFinding(
          id: id,
          severity: severity,
          message: message,
          targetId: targetId,
          scopeId: scopeId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase32E &&
        (result.criticalCount > 0 ||
            result.targets.any(
              (target) =>
                  target.currentStatus.isUnsafe || target.hasUnsafeOutput,
            ))) {
      add(
        id: 'unsafeHardeningStateMarkedSafe',
        severity: InternalPacketEvidenceHardeningValidationSeverity.critical,
        message: 'unsafe hardening state cannot be marked safe',
      );
    }

    for (final target in result.targets) {
      if (target.hasUnsafeOutput) {
        add(
          id: 'hardeningTargetUnsafeOutputBoundary',
          severity: InternalPacketEvidenceHardeningValidationSeverity.critical,
          message: '${target.targetId} crossed a blocked output boundary',
          targetId: target.targetId,
          scopeId: target.scopeId,
        );
      }
      if (target.currentStatus == InternalPacketStabilityStatus.unstable &&
          target.recommendedAction ==
              InternalPacketEvidenceHardeningActionType.preserveStablePacket) {
        add(
          id: 'unstablePacketPreservedAsStable',
          severity: InternalPacketEvidenceHardeningValidationSeverity.blocker,
          message: '${target.targetId} is unstable and cannot be preserved',
          targetId: target.targetId,
          scopeId: target.scopeId,
        );
      }
      if (target.quietScopeActive ||
          (target.scopeId ==
                  InternalNonLabelPrototypeScopeId
                      .quietPreparatoryPrototypeScope &&
              target.recommendedAction !=
                  InternalPacketEvidenceHardeningActionType
                      .keepExcludedByNegativeGuard &&
              target.recommendedAction !=
                  InternalPacketEvidenceHardeningActionType
                      .keepBlockedByPolicy)) {
        add(
          id: 'quietPreparatoryHardeningActivated',
          severity: InternalPacketEvidenceHardeningValidationSeverity.critical,
          message: '${target.targetId} activated quiet or preparatory scope',
          targetId: target.targetId,
          scopeId: target.scopeId,
        );
      }
      if (target.cpLossComputationImplemented ||
          target.winProbabilityComputationImplemented) {
        add(
          id: 'futureComputationActivated',
          severity: InternalPacketEvidenceHardeningValidationSeverity.critical,
          message: '${target.targetId} activated a future computation',
          targetId: target.targetId,
          scopeId: target.scopeId,
        );
      }
      if (target.ownerProofRequired &&
          !_hasExplicitPvOwnerProofReason(target)) {
        add(
          id: 'ownerProofRequiredWithoutPvReason',
          severity: InternalPacketEvidenceHardeningValidationSeverity.blocker,
          message: '${target.targetId} requires owner proof without PV reason',
          targetId: target.targetId,
          scopeId: target.scopeId,
        );
      }
      if (target.isBlockedOrFuture &&
          target.recommendedAction ==
              InternalPacketEvidenceHardeningActionType.addGoldenCoverage) {
        add(
          id: 'blockedScopeReceivedCoverageAction',
          severity: InternalPacketEvidenceHardeningValidationSeverity.blocker,
          message: '${target.targetId} is blocked or future-only',
          targetId: target.targetId,
          scopeId: target.scopeId,
        );
      }
      for (final caseId in target.supportCaseIds) {
        if (!goldenCaseIds.contains(caseId)) {
          add(
            id: 'unknownSupportCaseId',
            severity: InternalPacketEvidenceHardeningValidationSeverity.blocker,
            message: '${target.targetId} cited unknown support case',
            targetId: target.targetId,
            scopeId: target.scopeId,
            caseId: caseId,
          );
        }
      }
      for (final caseId in target.androidProofCaseIds) {
        if (!_capturedAndroidProofIds.contains(caseId) ||
            !provenAndroidIds.contains(caseId)) {
          add(
            id: 'unprovenAndroidProofCitation',
            severity:
                InternalPacketEvidenceHardeningValidationSeverity.critical,
            message: '${target.targetId} cited unproven Android proof',
            targetId: target.targetId,
            scopeId: target.scopeId,
            caseId: caseId,
          );
        }
      }
    }

    if (result.productLabelsEmitted ||
        result.classifierLabelsEmitted ||
        result.finalMoveLabelsEmitted ||
        result.officialMetricsAllowed ||
        result.cpLossComputationImplemented ||
        result.winProbabilityComputationImplemented ||
        result.numericMoveValuesComputed ||
        result.moveOrderingComputed ||
        result.directEngineAccessUsed ||
        result.uiOutputUsed ||
        result.backendOutputUsed ||
        result.persistenceUsed ||
        result.emittedOutputFamilies.any(_isForbiddenOutputName)) {
      add(
        id: 'hardeningBoundaryPolicyViolation',
        severity: InternalPacketEvidenceHardeningValidationSeverity.critical,
        message: 'hardening plan crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<InternalPacketEvidenceHardeningPlanValidationFinding> validateReportText(
    String reportText,
  ) {
    final findings = <InternalPacketEvidenceHardeningPlanValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        InternalPacketEvidenceHardeningPlanValidationFinding(
          id: id,
          severity: InternalPacketEvidenceHardeningValidationSeverity.critical,
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
    if (reportText.contains(' pv ') ||
        reportText.contains('pvMoves') ||
        reportText.contains('e2e4 e7e5')) {
      reportError('pvDumpReportText', 'report contains PV dump text');
    }
    for (final token in const <String>[
      'Brilliant',
      'Great',
      'Miss',
      'Best',
      'Good',
      'Inaccuracy',
      'Mistake',
      'Blunder',
      'ACPL',
      'accuracy',
    ]) {
      if (reportText.contains(token)) {
        reportError('forbiddenReportOutputName', 'report contains $token');
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
        reportText.contains('moveRanking')) {
      reportError(
        'moveOrderingReportText',
        'report contains move ordering text',
      );
    }
    return findings..sort(_compareFindings);
  }
}

List<InternalPacketEvidenceHardeningTarget> _targetsFromStability(
  InternalPacketStabilityPrototypeResult stabilityResult,
) {
  final targets = stabilityResult.records.map(_targetFromRecord).toList();
  targets.sort((a, b) => a.scopeId.index.compareTo(b.scopeId.index));
  return List<InternalPacketEvidenceHardeningTarget>.unmodifiable(targets);
}

InternalPacketEvidenceHardeningTarget _targetFromRecord(
  InternalPacketStabilityRecord record,
) {
  final targetKind = _targetKindFor(record);
  final action = _actionFor(record);
  final priority = _priorityFor(record, action);
  final suggestedCaseArea = _suggestedCaseAreaFor(record.scopeId);
  final missingCoverageAreas = _missingCoverageAreasFor(
    record,
    action,
    suggestedCaseArea,
  );
  return InternalPacketEvidenceHardeningTarget(
    targetId: record.recordId,
    targetKind: targetKind,
    scopeId: record.scopeId,
    packetId: record.packetId,
    currentStatus: record.stabilityStatus,
    recommendedAction: action,
    priority: priority,
    supportCaseIds: record.supportCaseIds,
    androidProofCaseIds: record.androidProofCaseIds,
    missingCoverageAreas: missingCoverageAreas,
    suggestedCaseArea:
        action == InternalPacketEvidenceHardeningActionType.addGoldenCoverage ||
            action ==
                InternalPacketEvidenceHardeningActionType.addHandcraftedCase ||
            action == InternalPacketEvidenceHardeningActionType.addFakeEvidence
        ? suggestedCaseArea
        : '',
    suggestedEvidenceType: _suggestedEvidenceTypeFor(record, action),
    ownerProofAllowed: _ownerProofAllowed(record),
    ownerProofRequired: false,
    reason: _reasonFor(record, action),
    nextStep: _nextStepFor(record, action, suggestedCaseArea),
    isProductOutput: record.isProductOutput,
    isClassifierLabel: record.isClassifierLabel,
    isOfficialMetric: record.isOfficialMetric,
    hasNumericValue: record.hasNumericValue,
    ordersMoves: record.ordersMoves,
    quietScopeActive: record.quietScopeActive,
    cpLossComputationImplemented: record.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        record.winProbabilityComputationImplemented,
    emittedOutputNames: record.emittedOutputNames,
  );
}

InternalPacketEvidenceHardeningTargetKind _targetKindFor(
  InternalPacketStabilityRecord record,
) {
  if (record.scopeId ==
      InternalNonLabelPrototypeScopeId
          .androidProofConfidenceInternalPrototypeScope) {
    return InternalPacketEvidenceHardeningTargetKind.androidProofScope;
  }
  if (record.stabilityStatus ==
      InternalPacketStabilityStatus.warningLimitedOnly) {
    return InternalPacketEvidenceHardeningTargetKind.warningScope;
  }
  if (record.stabilityStatus ==
      InternalPacketStabilityStatus.futureOnlyCorrectly) {
    return InternalPacketEvidenceHardeningTargetKind.futureOnlyScope;
  }
  if (record.stabilityStatus ==
      InternalPacketStabilityStatus.blockedCorrectly) {
    return InternalPacketEvidenceHardeningTargetKind.blockedScope;
  }
  return InternalPacketEvidenceHardeningTargetKind.packet;
}

InternalPacketEvidenceHardeningActionType _actionFor(
  InternalPacketStabilityRecord record,
) {
  return switch (record.stabilityStatus) {
    InternalPacketStabilityStatus.stable =>
      InternalPacketEvidenceHardeningActionType.preserveStablePacket,
    InternalPacketStabilityStatus.stableNarrow =>
      InternalPacketEvidenceHardeningActionType.addGoldenCoverage,
    InternalPacketStabilityStatus.stableWithWarnings =>
      InternalPacketEvidenceHardeningActionType.addGoldenCoverage,
    InternalPacketStabilityStatus.proofLimitedStable =>
      InternalPacketEvidenceHardeningActionType.keepProofLimited,
    InternalPacketStabilityStatus.warningLimitedOnly =>
      InternalPacketEvidenceHardeningActionType.addGoldenCoverage,
    InternalPacketStabilityStatus.blockedCorrectly =>
      record.scopeId ==
              InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope
          ? InternalPacketEvidenceHardeningActionType
                .keepExcludedByNegativeGuard
          : InternalPacketEvidenceHardeningActionType.keepBlockedByPolicy,
    InternalPacketStabilityStatus.futureOnlyCorrectly =>
      InternalPacketEvidenceHardeningActionType.keepFutureOnly,
    InternalPacketStabilityStatus.unstable =>
      InternalPacketEvidenceHardeningActionType.investigateInstability,
    InternalPacketStabilityStatus.unsafe ||
    InternalPacketStabilityStatus.invalid =>
      InternalPacketEvidenceHardeningActionType.blockUnsafeScope,
  };
}

InternalPacketEvidenceHardeningPriority _priorityFor(
  InternalPacketStabilityRecord record,
  InternalPacketEvidenceHardeningActionType action,
) {
  if (record.hasUnsafeOutput ||
      record.quietScopeActive ||
      record.cpLossComputationImplemented ||
      record.winProbabilityComputationImplemented ||
      record.stabilityStatus.isUnsafe) {
    return InternalPacketEvidenceHardeningPriority.critical;
  }
  if (record.stabilityStatus == InternalPacketStabilityStatus.unstable ||
      (record.isCorePacket &&
          record.stabilityStatus.isStableCore &&
          (record.supportCaseIds.isEmpty ||
              record.activeSignalIds.isEmpty ||
              record.evidenceAreaIds.isEmpty ||
              record.bucketIds.isEmpty))) {
    return InternalPacketEvidenceHardeningPriority.high;
  }
  if (record.stabilityStatus ==
      InternalPacketStabilityStatus.warningLimitedOnly) {
    return InternalPacketEvidenceHardeningPriority.medium;
  }
  if (record.stabilityStatus == InternalPacketStabilityStatus.stableNarrow ||
      record.stabilityStatus ==
          InternalPacketStabilityStatus.stableWithWarnings ||
      action == InternalPacketEvidenceHardeningActionType.keepProofLimited) {
    return InternalPacketEvidenceHardeningPriority.low;
  }
  return InternalPacketEvidenceHardeningPriority.none;
}

List<String> _missingCoverageAreasFor(
  InternalPacketStabilityRecord record,
  InternalPacketEvidenceHardeningActionType action,
  String suggestedCaseArea,
) {
  if (action != InternalPacketEvidenceHardeningActionType.addGoldenCoverage &&
      action != InternalPacketEvidenceHardeningActionType.addHandcraftedCase &&
      action != InternalPacketEvidenceHardeningActionType.addFakeEvidence) {
    return const <String>[];
  }
  return _sortedStrings(<String>[suggestedCaseArea, ...record.coverageGapIds]);
}

String _suggestedEvidenceTypeFor(
  InternalPacketStabilityRecord record,
  InternalPacketEvidenceHardeningActionType action,
) {
  return switch (action) {
    InternalPacketEvidenceHardeningActionType.preserveStablePacket =>
      'currentGoldenSupport',
    InternalPacketEvidenceHardeningActionType.addGoldenCoverage ||
    InternalPacketEvidenceHardeningActionType.addHandcraftedCase =>
      'handcraftedGoldenCase',
    InternalPacketEvidenceHardeningActionType.addFakeEvidence =>
      'fakeEvidenceFixture',
    InternalPacketEvidenceHardeningActionType.keepProofLimited =>
      'ownerAndroidProofReferenceOnly',
    InternalPacketEvidenceHardeningActionType
        .addOwnerAndroidProofOnlyIfPvRequired =>
      'ownerAndroidProofTarget',
    InternalPacketEvidenceHardeningActionType.keepWarningLimited =>
      'warningOnly',
    InternalPacketEvidenceHardeningActionType.keepBlockedByPolicy ||
    InternalPacketEvidenceHardeningActionType.keepExcludedByNegativeGuard =>
      'policyBoundary',
    InternalPacketEvidenceHardeningActionType.keepFutureOnly =>
      'futureDesignOnly',
    InternalPacketEvidenceHardeningActionType.investigateInstability ||
    InternalPacketEvidenceHardeningActionType.blockUnsafeScope =>
      'investigation',
  };
}

bool _ownerProofAllowed(InternalPacketStabilityRecord record) {
  return record.scopeId ==
          InternalNonLabelPrototypeScopeId
              .androidProofConfidenceInternalPrototypeScope ||
      record.scopeId ==
          InternalNonLabelPrototypeScopeId
              .pvMultiPvSupportInternalPrototypeScope;
}

String _reasonFor(
  InternalPacketStabilityRecord record,
  InternalPacketEvidenceHardeningActionType action,
) {
  return switch (action) {
    InternalPacketEvidenceHardeningActionType.preserveStablePacket =>
      'stable packet already has current Golden support',
    InternalPacketEvidenceHardeningActionType.addGoldenCoverage =>
      record.stabilityStatus == InternalPacketStabilityStatus.warningLimitedOnly
          ? 'warning-limited scope needs targeted Golden coverage before broader prototype work'
          : 'stable packet keeps warnings visible and should receive targeted Golden coverage',
    InternalPacketEvidenceHardeningActionType.addHandcraftedCase =>
      'target should be covered by a handcrafted hard case',
    InternalPacketEvidenceHardeningActionType.addFakeEvidence =>
      'target can be covered by fake internal evidence only if real semantics are not claimed',
    InternalPacketEvidenceHardeningActionType.keepProofLimited =>
      'Android proof confidence remains limited to captured proof IDs',
    InternalPacketEvidenceHardeningActionType
        .addOwnerAndroidProofOnlyIfPvRequired =>
      'owner Android proof is only allowed for explicit PV/MultiPV proof needs',
    InternalPacketEvidenceHardeningActionType.keepWarningLimited =>
      'scope remains warning-limited',
    InternalPacketEvidenceHardeningActionType.keepBlockedByPolicy =>
      'scope remains blocked by policy',
    InternalPacketEvidenceHardeningActionType.keepExcludedByNegativeGuard =>
      'quiet/preparatory remains excluded by negative guard',
    InternalPacketEvidenceHardeningActionType.keepFutureOnly =>
      'scope remains future-only',
    InternalPacketEvidenceHardeningActionType.investigateInstability =>
      'unstable packet must be investigated before hardening',
    InternalPacketEvidenceHardeningActionType.blockUnsafeScope =>
      'unsafe or invalid scope must remain blocked',
  };
}

String _nextStepFor(
  InternalPacketStabilityRecord record,
  InternalPacketEvidenceHardeningActionType action,
  String suggestedCaseArea,
) {
  return switch (action) {
    InternalPacketEvidenceHardeningActionType.preserveStablePacket =>
      'preserve packet type and keep current support mapping',
    InternalPacketEvidenceHardeningActionType.addGoldenCoverage =>
      'plan targeted Golden coverage for $suggestedCaseArea',
    InternalPacketEvidenceHardeningActionType.addHandcraftedCase =>
      'design a handcrafted hard case for $suggestedCaseArea',
    InternalPacketEvidenceHardeningActionType.addFakeEvidence =>
      'add fake evidence only for pure internal fixture coverage',
    InternalPacketEvidenceHardeningActionType.keepProofLimited =>
      'keep proof IDs limited to ${_ids(record.androidProofCaseIds)}',
    InternalPacketEvidenceHardeningActionType
        .addOwnerAndroidProofOnlyIfPvRequired =>
      'queue owner proof only if a PV/MultiPV proof gap is explicit',
    InternalPacketEvidenceHardeningActionType.keepWarningLimited =>
      'keep scope outside core packet generation',
    InternalPacketEvidenceHardeningActionType.keepBlockedByPolicy =>
      'keep scope inactive under policy boundary',
    InternalPacketEvidenceHardeningActionType.keepExcludedByNegativeGuard =>
      'keep quiet/preparatory excluded by the negative guard',
    InternalPacketEvidenceHardeningActionType.keepFutureOnly =>
      'keep scope inactive until future prerequisites are met',
    InternalPacketEvidenceHardeningActionType.investigateInstability =>
      'investigate instability before preserving packet type',
    InternalPacketEvidenceHardeningActionType.blockUnsafeScope =>
      'block unsafe scope and investigate policy violation',
  };
}

String _suggestedCaseAreaFor(InternalNonLabelPrototypeScopeId scopeId) {
  return switch (scopeId) {
    InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope =>
      'king-safety / mating-net coverage',
    InternalNonLabelPrototypeScopeId.endgameInternalPrototypeScope =>
      'endgame precision coverage',
    InternalNonLabelPrototypeScopeId.suppressionSafetyInternalPrototypeScope =>
      'suppression safety coverage',
    InternalNonLabelPrototypeScopeId.budgetRiskInternalPrototypeScope =>
      'budget pressure coverage',
    InternalNonLabelPrototypeScopeId.forcingLineInternalPrototypeScope =>
      'forcing-line variation coverage',
    InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope =>
      'PV/MultiPV support coverage',
    InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope =>
      'tactical packet coverage',
    InternalNonLabelPrototypeScopeId.materialSwingInternalPrototypeScope =>
      'material swing coverage',
    InternalNonLabelPrototypeScopeId.candidateSpreadInternalPrototypeScope =>
      'candidate spread coverage',
    InternalNonLabelPrototypeScopeId
        .androidProofConfidenceInternalPrototypeScope =>
      'Android proof confidence coverage',
    InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope =>
      'quiet/preparatory negative guard coverage',
    InternalNonLabelPrototypeScopeId.productLabelPrototypeScope ||
    InternalNonLabelPrototypeScopeId.advancedLabelPrototypeScope ||
    InternalNonLabelPrototypeScopeId.officialMetricPrototypeScope ||
    InternalNonLabelPrototypeScopeId.cpLossPrototypeScope ||
    InternalNonLabelPrototypeScopeId.winProbabilityPrototypeScope ||
    InternalNonLabelPrototypeScopeId.uiProductIntegrationScope ||
    InternalNonLabelPrototypeScopeId.backendIntegrationScope ||
    InternalNonLabelPrototypeScopeId.persistenceScope ||
    InternalNonLabelPrototypeScopeId.directEngineAccessScope => '',
  };
}

InternalPacketEvidenceHardeningPlanResult _resultFromTargets({
  required List<InternalPacketEvidenceHardeningTarget> targets,
  required InternalPacketStabilityPrototypeResult stabilityResult,
  required InternalPacketReviewAggregationMatrixResult matrixResult,
  required NarrowInternalNonLabelAnalysisPrototypeResult prototypeResult,
  required List<InternalPacketEvidenceHardeningPlanValidationFinding>
  validationFindings,
}) {
  final criticalCount = targets
      .where(
        (target) =>
            target.priority == InternalPacketEvidenceHardeningPriority.critical,
      )
      .length;
  final highPriorityCount = targets
      .where(
        (target) =>
            target.priority == InternalPacketEvidenceHardeningPriority.high,
      )
      .length;
  final policyBoundaryLeaked =
      stabilityResult.hasUnsafeStabilityPolicyViolation ||
      matrixResult.hasUnsafeMatrixPolicyViolation ||
      prototypeResult.hasUnsafePrototypePolicyViolation ||
      targets.any((target) => target.hasUnsafeOutput);
  final safeForPhase32E =
      stabilityResult.safeForPhase32D &&
      !policyBoundaryLeaked &&
      criticalCount == 0 &&
      !validationFindings.any((finding) => finding.blocksStrict) &&
      !targets.any(
        (target) =>
            target.currentStatus == InternalPacketStabilityStatus.unstable ||
            target.currentStatus.isUnsafe,
      );
  final base = InternalPacketEvidenceHardeningPlanResult(
    hardeningStatus:
        InternalPacketEvidenceHardeningStatus.readyForTargetedHardening,
    sourceStabilityStatus: stabilityResult.prototypeStatus,
    sourceMatrixStatus: matrixResult.matrixStatus,
    sourcePrototypeStatus: prototypeResult.prototypeStatus,
    targets: targets,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...stabilityResult.warnings,
      ...matrixResult.warnings,
      ...prototypeResult.warnings,
    ]),
    failures: _sortedStrings(<String>[
      ...stabilityResult.failures,
      ...matrixResult.failures,
      ...prototypeResult.failures,
      ...validationFindings.map((finding) => finding.message),
    ]),
    totalTargets: targets.length,
    preserveCount: targets
        .where(
          (target) =>
              target.recommendedAction ==
              InternalPacketEvidenceHardeningActionType.preserveStablePacket,
        )
        .length,
    addGoldenCoverageCount: targets
        .where(
          (target) =>
              target.recommendedAction ==
              InternalPacketEvidenceHardeningActionType.addGoldenCoverage,
        )
        .length,
    proofLimitedCount: targets
        .where(
          (target) =>
              target.recommendedAction ==
                  InternalPacketEvidenceHardeningActionType.keepProofLimited ||
              target.targetKind ==
                  InternalPacketEvidenceHardeningTargetKind.androidProofScope,
        )
        .length,
    warningLimitedCount: targets
        .where(
          (target) =>
              target.targetKind ==
              InternalPacketEvidenceHardeningTargetKind.warningScope,
        )
        .length,
    blockedCount: targets
        .where(
          (target) =>
              target.targetKind ==
              InternalPacketEvidenceHardeningTargetKind.blockedScope,
        )
        .length,
    futureOnlyCount: targets
        .where(
          (target) =>
              target.targetKind ==
              InternalPacketEvidenceHardeningTargetKind.futureOnlyScope,
        )
        .length,
    highPriorityCount: highPriorityCount,
    criticalCount: criticalCount,
    supportCaseIds: _sortedStrings(
      targets.expand((target) => target.supportCaseIds),
    ),
    androidProofCaseIds: _sortedStrings(
      targets.expand((target) => target.androidProofCaseIds),
    ),
    suggestedHardCaseAreas: _sortedStrings(
      targets.expand((target) => target.missingCoverageAreas),
    ),
    safeForPhase32E: safeForPhase32E,
    phase32ERecommendation:
        InternalPacketEvidencePhase32ERecommendation.keepNarrowPrototypeOnly,
    productLabelsEmitted:
        stabilityResult.productLabelsEmitted ||
        matrixResult.productLabelsEmitted ||
        prototypeResult.productLabelsEmitted,
    classifierLabelsEmitted:
        stabilityResult.classifierLabelsEmitted ||
        matrixResult.classifierLabelsEmitted ||
        prototypeResult.classifierLabelsEmitted,
    finalMoveLabelsEmitted:
        stabilityResult.finalMoveLabelsEmitted ||
        matrixResult.finalMoveLabelsEmitted ||
        prototypeResult.finalMoveLabelsEmitted,
    officialMetricsAllowed:
        stabilityResult.officialMetricsAllowed ||
        matrixResult.officialMetricsAllowed ||
        prototypeResult.officialMetricsAllowed,
    cpLossComputationImplemented:
        stabilityResult.cpLossComputationImplemented ||
        matrixResult.cpLossComputationImplemented ||
        prototypeResult.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        stabilityResult.winProbabilityComputationImplemented ||
        matrixResult.winProbabilityComputationImplemented ||
        prototypeResult.winProbabilityComputationImplemented,
    numericMoveValuesComputed:
        stabilityResult.numericMoveValuesComputed ||
        matrixResult.numericMoveScoresComputed ||
        prototypeResult.numericMoveScoresComputed,
    moveOrderingComputed:
        stabilityResult.moveOrderingComputed ||
        matrixResult.moveRankingComputed ||
        prototypeResult.moveRankingComputed,
    directEngineAccessUsed:
        stabilityResult.directEngineAccessUsed ||
        matrixResult.directEngineAccessUsed ||
        prototypeResult.directEngineAccessUsed,
    uiOutputUsed:
        stabilityResult.uiOutputUsed ||
        matrixResult.uiOutputUsed ||
        prototypeResult.uiOutputUsed,
    backendOutputUsed:
        stabilityResult.backendOutputUsed ||
        matrixResult.backendOutputUsed ||
        prototypeResult.backendOutputUsed,
    persistenceUsed:
        stabilityResult.persistenceUsed ||
        matrixResult.persistenceUsed ||
        prototypeResult.persistenceUsed,
    emittedOutputFamilies: _sortedStrings(<String>[
      ...stabilityResult.emittedOutputFamilies,
      ...matrixResult.emittedOutputFamilies,
      ...prototypeResult.emittedOutputFamilies,
    ]),
  );
  return base.copyWith(
    hardeningStatus: _hardeningStatusFor(base),
    phase32ERecommendation: _phase32ERecommendationFor(base),
  );
}

InternalPacketEvidenceHardeningStatus _hardeningStatusFor(
  InternalPacketEvidenceHardeningPlanResult result,
) {
  if (result.criticalCount > 0 ||
      result.validationFindings.any((finding) => finding.isCritical)) {
    return InternalPacketEvidenceHardeningStatus.blockedByUnsafePacket;
  }
  if (result.targets.any(
    (target) => target.currentStatus == InternalPacketStabilityStatus.unstable,
  )) {
    return InternalPacketEvidenceHardeningStatus.blockedByInstability;
  }
  if (result.productLabelsEmitted ||
      result.classifierLabelsEmitted ||
      result.finalMoveLabelsEmitted ||
      result.officialMetricsAllowed ||
      result.cpLossComputationImplemented ||
      result.winProbabilityComputationImplemented ||
      result.numericMoveValuesComputed ||
      result.moveOrderingComputed ||
      result.directEngineAccessUsed ||
      result.uiOutputUsed ||
      result.backendOutputUsed ||
      result.persistenceUsed ||
      result.emittedOutputFamilies.any(_isForbiddenOutputName)) {
    return InternalPacketEvidenceHardeningStatus.blockedByPolicyBoundary;
  }
  if (result.targets.isEmpty) {
    return InternalPacketEvidenceHardeningStatus.invalid;
  }
  if (result.addGoldenCoverageCount > 0) {
    return InternalPacketEvidenceHardeningStatus.readyForTargetedHardening;
  }
  return InternalPacketEvidenceHardeningStatus.readyWithNarrowScope;
}

InternalPacketEvidencePhase32ERecommendation _phase32ERecommendationFor(
  InternalPacketEvidenceHardeningPlanResult result,
) {
  if (result.criticalCount > 0 ||
      result.validationFindings.any((finding) => finding.isCritical) ||
      result.hasUnsafeHardeningPolicyViolation) {
    return InternalPacketEvidencePhase32ERecommendation
        .blockedByUnsafeHardeningState;
  }
  if (result.targets.any(
    (target) =>
        target.recommendedAction ==
        InternalPacketEvidenceHardeningActionType
            .addOwnerAndroidProofOnlyIfPvRequired,
  )) {
    return InternalPacketEvidencePhase32ERecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (result.targets.any(
    (target) =>
        target.recommendedAction ==
        InternalPacketEvidenceHardeningActionType.addFakeEvidence,
  )) {
    return InternalPacketEvidencePhase32ERecommendation.addTargetedFakeEvidence;
  }
  if (result.addGoldenCoverageCount > 0) {
    return InternalPacketEvidencePhase32ERecommendation
        .addTargetedGoldenCoverageCases;
  }
  return InternalPacketEvidencePhase32ERecommendation.keepNarrowPrototypeOnly;
}

bool _hasExplicitPvOwnerProofReason(
  InternalPacketEvidenceHardeningTarget target,
) {
  final combined = '${target.reason} ${target.nextStep}'.toLowerCase();
  return combined.contains('pv') || combined.contains('multipv');
}

Set<String> _provenAndroidProofIds(
  GoldenAndroidProofEvidence? androidProofEvidence,
) {
  final proofIds = androidProofEvidence?.targetCaseIds ?? const <String>[];
  return proofIds
      .where(
        (caseId) =>
            _capturedAndroidProofIds.contains(caseId) &&
            (androidProofEvidence?.isRealDeviceProofCapturedFor(
                  caseId,
                  minMultiPvLineCount: 1,
                  requirePv: true,
                ) ??
                false),
      )
      .toSet();
}

String _ids(Iterable<String> values) {
  final sorted = _sortedStrings(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

String _targetIds(Iterable<InternalPacketEvidenceHardeningTarget> targets) {
  final ids = targets.map((target) => target.targetId).toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _scopeIds(Iterable<InternalPacketEvidenceHardeningTarget> targets) {
  final ids = targets.map((target) => target.scopeId.wire).toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _cell(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? '-' : normalized.replaceAll('|', '/');
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.where((value) => value.isNotEmpty).toSet().toList()..sort();
}

int _compareFindings(
  InternalPacketEvidenceHardeningPlanValidationFinding a,
  InternalPacketEvidenceHardeningPlanValidationFinding b,
) {
  final idCompare = a.id.compareTo(b.id);
  if (idCompare != 0) return idCompare;
  final targetCompare = (a.targetId ?? '').compareTo(b.targetId ?? '');
  if (targetCompare != 0) return targetCompare;
  final scopeCompare = (a.scopeId?.wire ?? '').compareTo(b.scopeId?.wire ?? '');
  if (scopeCompare != 0) return scopeCompare;
  return (a.caseId ?? '').compareTo(b.caseId ?? '');
}

bool _isForbiddenOutputName(String value) {
  final normalized = value.toLowerCase();
  return normalized.contains('productlabel') ||
      normalized.contains('movequality') ||
      normalized.contains('finalmove') ||
      normalized.contains('advancedcandidate') ||
      normalized.contains('brilliant') ||
      normalized.contains('great') ||
      normalized.contains('miss') ||
      normalized.contains('best') ||
      normalized.contains('good') ||
      normalized.contains('inaccuracy') ||
      normalized.contains('mistake') ||
      normalized.contains('blunder') ||
      normalized.contains('accuracy') ||
      normalized.contains('acpl') ||
      normalized.contains('numericmovescore') ||
      normalized.contains('rankedmoves');
}

const _capturedAndroidProofIds = <String>{
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
};

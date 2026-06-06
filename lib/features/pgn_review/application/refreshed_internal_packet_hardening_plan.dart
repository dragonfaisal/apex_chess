import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_review_aggregation_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_stability_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/narrow_internal_non_label_analysis_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/targeted_golden_coverage_impact_review.dart';

const refreshedInternalPacketHardeningPlanReportVersion =
    'refreshed-internal-packet-hardening-plan-v1';

enum RefreshedInternalPacketHardeningStatus {
  refreshedWithImprovedCoverage('refreshedWithImprovedCoverage'),
  refreshedWithWarnings('refreshedWithWarnings'),
  noRefreshNeeded('noRefreshNeeded'),
  needsMoreGoldenCoverage('needsMoreGoldenCoverage'),
  blockedByUnsafeImpact('blockedByUnsafeImpact'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const RefreshedInternalPacketHardeningStatus(this.wire);

  final String wire;
}

enum RefreshedInternalPacketHardeningActionType {
  preserveStablePacket('preserveStablePacket'),
  preserveImprovedPacket('preserveImprovedPacket'),
  downgradeCoverageNeedToWatch('downgradeCoverageNeedToWatch'),
  keepWarningLimitedButImproved('keepWarningLimitedButImproved'),
  keepProofLimited('keepProofLimited'),
  keepBlockedByPolicy('keepBlockedByPolicy'),
  keepExcludedByNegativeGuard('keepExcludedByNegativeGuard'),
  keepFutureOnly('keepFutureOnly'),
  addMoreGoldenCoverage('addMoreGoldenCoverage'),
  ownerProofOnlyIfPvRequired('ownerProofOnlyIfPvRequired'),
  investigateUnsafeImpact('investigateUnsafeImpact'),
  blockUnsafeScope('blockUnsafeScope');

  const RefreshedInternalPacketHardeningActionType(this.wire);

  final String wire;
}

enum RefreshedInternalPacketPhase32HRecommendation {
  validateRefreshedHardeningPlan('validateRefreshedHardeningPlan'),
  proceedToInternalPacketEvidenceRefresh(
    'proceedToInternalPacketEvidenceRefresh',
  ),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeRefresh('blockedByUnsafeRefresh');

  const RefreshedInternalPacketPhase32HRecommendation(this.wire);

  final String wire;
}

enum RefreshedInternalPacketHardeningValidationSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const RefreshedInternalPacketHardeningValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == RefreshedInternalPacketHardeningValidationSeverity.blocker ||
      this == RefreshedInternalPacketHardeningValidationSeverity.critical;
}

enum RefreshedInternalPacketHardeningPlanReportFormat {
  markdown('markdown'),
  json('json');

  const RefreshedInternalPacketHardeningPlanReportFormat(this.wire);

  final String wire;
}

class RefreshedInternalPacketHardeningPlanRequest {
  const RefreshedInternalPacketHardeningPlanRequest({
    this.impactReviewResult,
    this.hardeningPlanResult,
    this.stabilityResult,
    this.matrixResult,
    this.prototypeResult,
    this.impactReview = const TargetedGoldenCoverageImpactReview(),
    this.hardeningPlan = const InternalPacketEvidenceHardeningPlan(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const RefreshedInternalPacketHardeningPlanRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final TargetedGoldenCoverageImpactReviewResult? impactReviewResult;
  final InternalPacketEvidenceHardeningPlanResult? hardeningPlanResult;
  final InternalPacketStabilityPrototypeResult? stabilityResult;
  final InternalPacketReviewAggregationMatrixResult? matrixResult;
  final NarrowInternalNonLabelAnalysisPrototypeResult? prototypeResult;
  final TargetedGoldenCoverageImpactReview impactReview;
  final InternalPacketEvidenceHardeningPlan hardeningPlan;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class RefreshedInternalPacketHardeningTarget {
  const RefreshedInternalPacketHardeningTarget({
    required this.targetId,
    required this.targetKind,
    required this.scopeId,
    required this.previousActionFrom32D,
    required this.impactStatusFrom32F,
    required this.refreshedAction,
    required this.previousPriority,
    required this.refreshedPriority,
    required this.improvedByCaseIds,
    required this.supportCaseIds,
    required this.androidProofCaseIds,
    required this.remainingCoverageGaps,
    required this.stillWarningLimited,
    required this.stillBlocked,
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
  final String previousActionFrom32D;
  final TargetedGoldenCoverageImpactStatus impactStatusFrom32F;
  final RefreshedInternalPacketHardeningActionType refreshedAction;
  final InternalPacketEvidenceHardeningPriority previousPriority;
  final InternalPacketEvidenceHardeningPriority refreshedPriority;
  final List<String> improvedByCaseIds;
  final List<String> supportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> remainingCoverageGaps;
  final bool stillWarningLimited;
  final bool stillBlocked;
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

  bool get isImproved =>
      improvedByCaseIds.isNotEmpty ||
      refreshedAction ==
          RefreshedInternalPacketHardeningActionType.preserveImprovedPacket ||
      refreshedAction ==
          RefreshedInternalPacketHardeningActionType
              .downgradeCoverageNeedToWatch ||
      refreshedAction ==
          RefreshedInternalPacketHardeningActionType
              .keepWarningLimitedButImproved;

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

  bool get isBlockedOrFuture =>
      targetKind == InternalPacketEvidenceHardeningTargetKind.blockedScope ||
      targetKind == InternalPacketEvidenceHardeningTargetKind.futureOnlyScope;

  RefreshedInternalPacketHardeningTarget copyWith({
    String? targetId,
    InternalPacketEvidenceHardeningTargetKind? targetKind,
    InternalNonLabelPrototypeScopeId? scopeId,
    String? previousActionFrom32D,
    TargetedGoldenCoverageImpactStatus? impactStatusFrom32F,
    RefreshedInternalPacketHardeningActionType? refreshedAction,
    InternalPacketEvidenceHardeningPriority? previousPriority,
    InternalPacketEvidenceHardeningPriority? refreshedPriority,
    List<String>? improvedByCaseIds,
    List<String>? supportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? remainingCoverageGaps,
    bool? stillWarningLimited,
    bool? stillBlocked,
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
    return RefreshedInternalPacketHardeningTarget(
      targetId: targetId ?? this.targetId,
      targetKind: targetKind ?? this.targetKind,
      scopeId: scopeId ?? this.scopeId,
      previousActionFrom32D:
          previousActionFrom32D ?? this.previousActionFrom32D,
      impactStatusFrom32F: impactStatusFrom32F ?? this.impactStatusFrom32F,
      refreshedAction: refreshedAction ?? this.refreshedAction,
      previousPriority: previousPriority ?? this.previousPriority,
      refreshedPriority: refreshedPriority ?? this.refreshedPriority,
      improvedByCaseIds: improvedByCaseIds ?? this.improvedByCaseIds,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      remainingCoverageGaps:
          remainingCoverageGaps ?? this.remainingCoverageGaps,
      stillWarningLimited: stillWarningLimited ?? this.stillWarningLimited,
      stillBlocked: stillBlocked ?? this.stillBlocked,
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
      'previousActionFrom32D': previousActionFrom32D,
      'impactStatusFrom32F': impactStatusFrom32F.wire,
      'refreshedAction': refreshedAction.wire,
      'previousPriority': previousPriority.wire,
      'refreshedPriority': refreshedPriority.wire,
      'improvedByCaseIds': improvedByCaseIds,
      'supportCaseIds': supportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'remainingCoverageGaps': remainingCoverageGaps,
      'stillWarningLimited': stillWarningLimited,
      'stillBlocked': stillBlocked,
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

class RefreshedInternalPacketHardeningPlanValidationFinding {
  const RefreshedInternalPacketHardeningPlanValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.targetId,
    this.scopeId,
    this.caseId,
  });

  final String id;
  final RefreshedInternalPacketHardeningValidationSeverity severity;
  final String message;
  final String? targetId;
  final InternalNonLabelPrototypeScopeId? scopeId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical =>
      severity == RefreshedInternalPacketHardeningValidationSeverity.critical;

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

class RefreshedInternalPacketHardeningPlanResult {
  const RefreshedInternalPacketHardeningPlanResult({
    required this.refreshedStatus,
    required this.sourceImpactStatus,
    required this.sourceHardeningStatus,
    required this.targets,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalTargets,
    required this.improvedTargetCount,
    required this.preservedTargetCount,
    required this.warningLimitedImprovedCount,
    required this.stillWarningLimitedCount,
    required this.blockedCount,
    required this.futureOnlyCount,
    required this.proofLimitedCount,
    required this.ownerProofQueueCount,
    required this.unsafeCount,
    required this.criticalCount,
    required this.newSupportCaseIds,
    required this.androidProofCaseIds,
    required this.remainingCoverageGapIds,
    required this.safeForPhase32H,
    required this.phase32HRecommendation,
    this.developerOnly = true,
    this.productLabelsEmitted = false,
    this.advancedLabelsEmitted = false,
    this.classifierLabelsEmitted = false,
    this.finalMoveLabelsEmitted = false,
    this.officialMetricsAllowed = false,
    this.cpLossComputationImplemented = false,
    this.winProbabilityComputationImplemented = false,
    this.numericMoveValuesComputed = false,
    this.moveOrderingComputed = false,
    this.quietPreparatoryScopeActivated = false,
    this.directEngineAccessUsed = false,
    this.uiOutputUsed = false,
    this.backendOutputUsed = false,
    this.persistenceUsed = false,
    this.emittedOutputFamilies = const <String>[],
  });

  final RefreshedInternalPacketHardeningStatus refreshedStatus;
  final TargetedGoldenCoverageImpactStatus sourceImpactStatus;
  final InternalPacketEvidenceHardeningStatus sourceHardeningStatus;
  final List<RefreshedInternalPacketHardeningTarget> targets;
  final List<RefreshedInternalPacketHardeningPlanValidationFinding>
  validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalTargets;
  final int improvedTargetCount;
  final int preservedTargetCount;
  final int warningLimitedImprovedCount;
  final int stillWarningLimitedCount;
  final int blockedCount;
  final int futureOnlyCount;
  final int proofLimitedCount;
  final int ownerProofQueueCount;
  final int unsafeCount;
  final int criticalCount;
  final List<String> newSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> remainingCoverageGapIds;
  final bool safeForPhase32H;
  final RefreshedInternalPacketPhase32HRecommendation phase32HRecommendation;
  final bool developerOnly;
  final bool productLabelsEmitted;
  final bool advancedLabelsEmitted;
  final bool classifierLabelsEmitted;
  final bool finalMoveLabelsEmitted;
  final bool officialMetricsAllowed;
  final bool cpLossComputationImplemented;
  final bool winProbabilityComputationImplemented;
  final bool numericMoveValuesComputed;
  final bool moveOrderingComputed;
  final bool quietPreparatoryScopeActivated;
  final bool directEngineAccessUsed;
  final bool uiOutputUsed;
  final bool backendOutputUsed;
  final bool persistenceUsed;
  final List<String> emittedOutputFamilies;

  bool get isStrictlyBlocked =>
      refreshedStatus ==
          RefreshedInternalPacketHardeningStatus.blockedByUnsafeImpact ||
      refreshedStatus ==
          RefreshedInternalPacketHardeningStatus.blockedByPolicyBoundary ||
      refreshedStatus == RefreshedInternalPacketHardeningStatus.invalid ||
      !safeForPhase32H ||
      criticalCount > 0 ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeRefreshPolicyViolation {
    return unsafeCount > 0 ||
        criticalCount > 0 ||
        validationFindings.any((finding) => finding.isCritical) ||
        targets.any((target) => target.hasUnsafeOutput) ||
        productLabelsEmitted ||
        advancedLabelsEmitted ||
        classifierLabelsEmitted ||
        finalMoveLabelsEmitted ||
        officialMetricsAllowed ||
        cpLossComputationImplemented ||
        winProbabilityComputationImplemented ||
        numericMoveValuesComputed ||
        moveOrderingComputed ||
        quietPreparatoryScopeActivated ||
        directEngineAccessUsed ||
        uiOutputUsed ||
        backendOutputUsed ||
        persistenceUsed ||
        emittedOutputFamilies.any(_isForbiddenOutputName);
  }

  RefreshedInternalPacketHardeningTarget target(
    InternalNonLabelPrototypeScopeId scopeId,
  ) {
    return targets.singleWhere((target) => target.scopeId == scopeId);
  }

  List<RefreshedInternalPacketHardeningTarget> get improvedTargets =>
      targets.where((target) => target.isImproved).toList(growable: false);

  List<RefreshedInternalPacketHardeningTarget>
  get warningLimitedImprovedTargets => targets
      .where(
        (target) =>
            target.stillWarningLimited && target.improvedByCaseIds.isNotEmpty,
      )
      .toList(growable: false);

  List<RefreshedInternalPacketHardeningTarget> get blockedOrFutureTargets =>
      targets
          .where((target) => target.isBlockedOrFuture)
          .toList(growable: false);

  List<RefreshedInternalPacketHardeningTarget> get proofLimitedTargets =>
      targets
          .where(
            (target) =>
                target.targetKind ==
                    InternalPacketEvidenceHardeningTargetKind
                        .androidProofScope ||
                target.refreshedAction ==
                    RefreshedInternalPacketHardeningActionType.keepProofLimited,
          )
          .toList(growable: false);

  RefreshedInternalPacketHardeningPlanResult copyWith({
    RefreshedInternalPacketHardeningStatus? refreshedStatus,
    TargetedGoldenCoverageImpactStatus? sourceImpactStatus,
    InternalPacketEvidenceHardeningStatus? sourceHardeningStatus,
    List<RefreshedInternalPacketHardeningTarget>? targets,
    List<RefreshedInternalPacketHardeningPlanValidationFinding>?
    validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalTargets,
    int? improvedTargetCount,
    int? preservedTargetCount,
    int? warningLimitedImprovedCount,
    int? stillWarningLimitedCount,
    int? blockedCount,
    int? futureOnlyCount,
    int? proofLimitedCount,
    int? ownerProofQueueCount,
    int? unsafeCount,
    int? criticalCount,
    List<String>? newSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? remainingCoverageGapIds,
    bool? safeForPhase32H,
    RefreshedInternalPacketPhase32HRecommendation? phase32HRecommendation,
    bool? developerOnly,
    bool? productLabelsEmitted,
    bool? advancedLabelsEmitted,
    bool? classifierLabelsEmitted,
    bool? finalMoveLabelsEmitted,
    bool? officialMetricsAllowed,
    bool? cpLossComputationImplemented,
    bool? winProbabilityComputationImplemented,
    bool? numericMoveValuesComputed,
    bool? moveOrderingComputed,
    bool? quietPreparatoryScopeActivated,
    bool? directEngineAccessUsed,
    bool? uiOutputUsed,
    bool? backendOutputUsed,
    bool? persistenceUsed,
    List<String>? emittedOutputFamilies,
  }) {
    return RefreshedInternalPacketHardeningPlanResult(
      refreshedStatus: refreshedStatus ?? this.refreshedStatus,
      sourceImpactStatus: sourceImpactStatus ?? this.sourceImpactStatus,
      sourceHardeningStatus:
          sourceHardeningStatus ?? this.sourceHardeningStatus,
      targets: targets ?? this.targets,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalTargets: totalTargets ?? this.totalTargets,
      improvedTargetCount: improvedTargetCount ?? this.improvedTargetCount,
      preservedTargetCount: preservedTargetCount ?? this.preservedTargetCount,
      warningLimitedImprovedCount:
          warningLimitedImprovedCount ?? this.warningLimitedImprovedCount,
      stillWarningLimitedCount:
          stillWarningLimitedCount ?? this.stillWarningLimitedCount,
      blockedCount: blockedCount ?? this.blockedCount,
      futureOnlyCount: futureOnlyCount ?? this.futureOnlyCount,
      proofLimitedCount: proofLimitedCount ?? this.proofLimitedCount,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      unsafeCount: unsafeCount ?? this.unsafeCount,
      criticalCount: criticalCount ?? this.criticalCount,
      newSupportCaseIds: newSupportCaseIds ?? this.newSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      remainingCoverageGapIds:
          remainingCoverageGapIds ?? this.remainingCoverageGapIds,
      safeForPhase32H: safeForPhase32H ?? this.safeForPhase32H,
      phase32HRecommendation:
          phase32HRecommendation ?? this.phase32HRecommendation,
      developerOnly: developerOnly ?? this.developerOnly,
      productLabelsEmitted: productLabelsEmitted ?? this.productLabelsEmitted,
      advancedLabelsEmitted:
          advancedLabelsEmitted ?? this.advancedLabelsEmitted,
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
      quietPreparatoryScopeActivated:
          quietPreparatoryScopeActivated ?? this.quietPreparatoryScopeActivated,
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
      ..writeln('# Refreshed Internal Packet Hardening Plan')
      ..writeln()
      ..writeln('- version: $refreshedInternalPacketHardeningPlanReportVersion')
      ..writeln('- refreshed status: ${refreshedStatus.wire}')
      ..writeln('- source impact status: ${sourceImpactStatus.wire}')
      ..writeln('- source hardening status: ${sourceHardeningStatus.wire}')
      ..writeln('- total targets: $totalTargets')
      ..writeln('- improved target count: $improvedTargetCount')
      ..writeln('- preserved target count: $preservedTargetCount')
      ..writeln(
        '- warning-limited improved count: $warningLimitedImprovedCount',
      )
      ..writeln('- still warning-limited count: $stillWarningLimitedCount')
      ..writeln('- blocked count: $blockedCount')
      ..writeln('- future-only count: $futureOnlyCount')
      ..writeln('- proof-limited count: $proofLimitedCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- safe for Phase 32H: $safeForPhase32H')
      ..writeln('- Phase 32H recommendation: ${phase32HRecommendation.wire}')
      ..writeln('- classifier output emitted: $classifierLabelsEmitted')
      ..writeln('- numeric value output emitted: $numericMoveValuesComputed')
      ..writeln('- move ordering output emitted: $moveOrderingComputed')
      ..writeln()
      ..writeln('## Refresh Policy')
      ..writeln(
        '- this refresh updates developer-only packet hardening actions from Phase 32F coverage impact',
      )
      ..writeln(
        '- it does not classify moves, compute values, order moves, call an engine, integrate product output, run Android, or write files',
      )
      ..writeln()
      ..writeln('## Refreshed Target Table')
      ..writeln(
        '| Target | Kind | Scope | Previous Action | Impact | Refreshed Action | Previous Priority | Refreshed Priority | Improved By | Support Cases | Android Proof | Remaining Gaps | Warning-Limited | Blocked | Owner Proof | Next Step |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final target in targets) {
      buffer.writeln(
        '| ${_cell(target.targetId)} | ${target.targetKind.wire} | '
        '${target.scopeId.wire} | ${target.previousActionFrom32D} | '
        '${target.impactStatusFrom32F.wire} | ${target.refreshedAction.wire} | '
        '${target.previousPriority.wire} | ${target.refreshedPriority.wire} | '
        '${_ids(target.improvedByCaseIds)} | ${_ids(target.supportCaseIds)} | '
        '${_ids(target.androidProofCaseIds)} | '
        '${_ids(target.remainingCoverageGaps)} | '
        '${target.stillWarningLimited} | ${target.stillBlocked} | '
        '${target.ownerProofRequired
            ? "required"
            : target.ownerProofAllowed
            ? "allowed"
            : "not-needed"} | '
        '${_cell(target.nextStep)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Improved Targets')
      ..writeln('- ${_targetIds(improvedTargets)}')
      ..writeln()
      ..writeln('## Warning-Limited But Improved Targets')
      ..writeln('- ${_targetIds(warningLimitedImprovedTargets)}')
      ..writeln()
      ..writeln('## Blocked And Future-Only Targets')
      ..writeln('- ${_scopeIds(blockedOrFutureTargets)}')
      ..writeln()
      ..writeln('## Owner Proof Status')
      ..writeln(
        ownerProofQueueCount == 0
            ? '- empty'
            : '- opt-in proof remains queued for an explicit PV/MultiPV reason',
      )
      ..writeln()
      ..writeln('## New Support Case IDs')
      ..writeln('- ${_ids(newSupportCaseIds)}')
      ..writeln()
      ..writeln('## Android Proof IDs')
      ..writeln('- ${_ids(androidProofCaseIds)}')
      ..writeln()
      ..writeln('## Remaining Coverage Gaps')
      ..writeln('- ${_ids(remainingCoverageGapIds)}')
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
        buffer.writeln('- ${_cell(warning)}');
      }
    }
    buffer
      ..writeln()
      ..writeln('## Failures');
    if (failures.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final failure in failures) {
        buffer.writeln('- ${_cell(failure)}');
      }
    }
    buffer
      ..writeln()
      ..writeln('## Phase 32H Recommendation')
      ..writeln(phase32HRecommendation.wire)
      ..writeln()
      ..writeln(
        'This refreshed plan stays internal-only. It does not emit user-facing output, compute product metrics, call the engine, run Android, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': refreshedInternalPacketHardeningPlanReportVersion,
      'refreshedStatus': refreshedStatus.wire,
      'sourceImpactStatus': sourceImpactStatus.wire,
      'sourceHardeningStatus': sourceHardeningStatus.wire,
      'totalTargets': totalTargets,
      'improvedTargetCount': improvedTargetCount,
      'preservedTargetCount': preservedTargetCount,
      'warningLimitedImprovedCount': warningLimitedImprovedCount,
      'stillWarningLimitedCount': stillWarningLimitedCount,
      'blockedCount': blockedCount,
      'futureOnlyCount': futureOnlyCount,
      'proofLimitedCount': proofLimitedCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'unsafeCount': unsafeCount,
      'criticalCount': criticalCount,
      'newSupportCaseIds': newSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'remainingCoverageGapIds': remainingCoverageGapIds,
      'safeForPhase32H': safeForPhase32H,
      'phase32HRecommendation': phase32HRecommendation.wire,
      'targets': targets.map((target) => target.toJson()).toList(),
      'validationFindings': validationFindings
          .map((finding) => finding.toJson())
          .toList(),
      'warnings': warnings,
      'failures': failures,
      'developerOnly': developerOnly,
      'productLabelsEmitted': productLabelsEmitted,
      'advancedLabelsEmitted': advancedLabelsEmitted,
      'classifierLabelsEmitted': classifierLabelsEmitted,
      'finalMoveLabelsEmitted': finalMoveLabelsEmitted,
      'officialMetricsAllowed': officialMetricsAllowed,
      'cpLossComputationImplemented': cpLossComputationImplemented,
      'winProbabilityComputationImplemented':
          winProbabilityComputationImplemented,
      'numericMoveValuesComputed': numericMoveValuesComputed,
      'moveOrderingComputed': moveOrderingComputed,
      'quietPreparatoryScopeActivated': quietPreparatoryScopeActivated,
      'directEngineAccessUsed': directEngineAccessUsed,
      'uiOutputUsed': uiOutputUsed,
      'backendOutputUsed': backendOutputUsed,
      'persistenceUsed': persistenceUsed,
      'emittedOutputFamilies': emittedOutputFamilies,
    };
  }
}

class RefreshedInternalPacketHardeningPlan {
  const RefreshedInternalPacketHardeningPlan({
    this.validator = const RefreshedInternalPacketHardeningPlanValidator(),
  });

  final RefreshedInternalPacketHardeningPlanValidator validator;

  RefreshedInternalPacketHardeningPlanResult evaluate([
    RefreshedInternalPacketHardeningPlanRequest request =
        const RefreshedInternalPacketHardeningPlanRequest(),
  ]) {
    final hardeningResult =
        request.hardeningPlanResult ??
        request.hardeningPlan.evaluate(
          InternalPacketEvidenceHardeningPlanRequest(
            stabilityResult: request.stabilityResult,
            matrixResult: request.matrixResult,
            prototypeResult: request.prototypeResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarningLimitedScopes: request.includeWarnings,
          ),
        );
    final impactResult =
        request.impactReviewResult ??
        request.impactReview.evaluate(
          TargetedGoldenCoverageImpactReviewRequest(
            cases: request.cases,
            hardeningPlanResult: hardeningResult,
            stabilityResult: request.stabilityResult,
            matrixResult: request.matrixResult,
            prototypeResult: request.prototypeResult,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final targets = _targetsFromImpact(
      hardeningResult: hardeningResult,
      impactResult: impactResult,
    );
    final base = _resultFromTargets(
      hardeningResult: hardeningResult,
      impactResult: impactResult,
      targets: targets,
      validationFindings:
          const <RefreshedInternalPacketHardeningPlanValidationFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromTargets(
      hardeningResult: hardeningResult,
      impactResult: impactResult,
      targets: targets,
      validationFindings: findings,
    );
  }
}

class RefreshedInternalPacketHardeningPlanValidator {
  const RefreshedInternalPacketHardeningPlanValidator();

  List<RefreshedInternalPacketHardeningPlanValidationFinding> validate(
    RefreshedInternalPacketHardeningPlanResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <RefreshedInternalPacketHardeningPlanValidationFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required RefreshedInternalPacketHardeningValidationSeverity severity,
      required String message,
      String? targetId,
      InternalNonLabelPrototypeScopeId? scopeId,
      String? caseId,
    }) {
      findings.add(
        RefreshedInternalPacketHardeningPlanValidationFinding(
          id: id,
          severity: severity,
          message: message,
          targetId: targetId,
          scopeId: scopeId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase32H &&
        (result.unsafeCount > 0 ||
            result.sourceImpactStatus.isUnsafe ||
            result.targets.any((target) => target.hasUnsafeOutput))) {
      add(
        id: 'unsafeImpactMarkedSafe',
        severity: RefreshedInternalPacketHardeningValidationSeverity.critical,
        message: 'unsafe coverage impact cannot be marked safe',
      );
    }

    for (final caseId in result.androidProofCaseIds) {
      if (!_capturedAndroidProofIds.contains(caseId) ||
          !provenAndroidIds.contains(caseId)) {
        add(
          id: 'unprovenAndroidProofClaim',
          severity: RefreshedInternalPacketHardeningValidationSeverity.critical,
          message: 'refreshed plan cited unproven Android proof',
          caseId: caseId,
        );
      }
      if (_phase32ECaseIds.contains(caseId)) {
        add(
          id: 'phase32ECaseClaimedCapturedAndroidProof',
          severity: RefreshedInternalPacketHardeningValidationSeverity.critical,
          message: 'Phase 32E cases cannot become captured Android proof',
          caseId: caseId,
        );
      }
    }

    for (final target in result.targets) {
      for (final caseId in target.androidProofCaseIds) {
        if (!_capturedAndroidProofIds.contains(caseId) ||
            !provenAndroidIds.contains(caseId)) {
          add(
            id: 'targetUnprovenAndroidProofClaim',
            severity:
                RefreshedInternalPacketHardeningValidationSeverity.critical,
            message: 'target cited unproven Android proof',
            targetId: target.targetId,
            scopeId: target.scopeId,
            caseId: caseId,
          );
        }
        if (_phase32ECaseIds.contains(caseId)) {
          add(
            id: 'targetPhase32ECaseClaimedCapturedAndroidProof',
            severity:
                RefreshedInternalPacketHardeningValidationSeverity.critical,
            message: 'target treated a Phase 32E case as captured proof',
            targetId: target.targetId,
            scopeId: target.scopeId,
            caseId: caseId,
          );
        }
      }
      if (target.ownerProofRequired &&
          !_hasExplicitPvReason(
            '${target.targetId} ${target.reason} ${target.nextStep}',
          )) {
        add(
          id: 'ownerProofRequiredWithoutPvReason',
          severity: RefreshedInternalPacketHardeningValidationSeverity.blocker,
          message: 'owner proof requires an explicit PV/MultiPV reason',
          targetId: target.targetId,
          scopeId: target.scopeId,
        );
      }
      if (target.scopeId ==
              InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope &&
          (!target.stillBlocked || target.quietScopeActive)) {
        add(
          id: 'quietPreparatoryScopeActivated',
          severity: RefreshedInternalPacketHardeningValidationSeverity.critical,
          message: 'quiet/preparatory scope must remain excluded',
          targetId: target.targetId,
          scopeId: target.scopeId,
        );
      }
      if (_blockedPolicyScopes.contains(target.scopeId) &&
          target.targetKind ==
              InternalPacketEvidenceHardeningTargetKind.blockedScope &&
          !target.stillBlocked) {
        add(
          id: 'blockedPolicyScopeAllowed',
          severity: RefreshedInternalPacketHardeningValidationSeverity.critical,
          message: '${target.scopeId.wire} must remain blocked',
          targetId: target.targetId,
          scopeId: target.scopeId,
        );
      }
      if (target.isBlockedOrFuture &&
          _activeAllowedRefreshActions.contains(target.refreshedAction)) {
        add(
          id: 'blockedScopeReceivedActiveAction',
          severity: RefreshedInternalPacketHardeningValidationSeverity.critical,
          message: '${target.scopeId.wire} received an active refresh action',
          targetId: target.targetId,
          scopeId: target.scopeId,
        );
      }
      if (target.hasUnsafeOutput) {
        add(
          id: 'targetBoundaryPolicyViolation',
          severity: RefreshedInternalPacketHardeningValidationSeverity.critical,
          message: '${target.targetId} crossed a blocked output boundary',
          targetId: target.targetId,
          scopeId: target.scopeId,
        );
      }
    }

    if (result.productLabelsEmitted ||
        result.advancedLabelsEmitted ||
        result.classifierLabelsEmitted ||
        result.finalMoveLabelsEmitted ||
        result.officialMetricsAllowed ||
        result.cpLossComputationImplemented ||
        result.winProbabilityComputationImplemented ||
        result.numericMoveValuesComputed ||
        result.moveOrderingComputed ||
        result.quietPreparatoryScopeActivated ||
        result.directEngineAccessUsed ||
        result.uiOutputUsed ||
        result.backendOutputUsed ||
        result.persistenceUsed ||
        result.emittedOutputFamilies.any(_isForbiddenOutputName)) {
      add(
        id: 'refreshBoundaryPolicyViolation',
        severity: RefreshedInternalPacketHardeningValidationSeverity.critical,
        message: 'refreshed plan crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<RefreshedInternalPacketHardeningPlanValidationFinding>
  validateReportText(String reportText) {
    final findings = <RefreshedInternalPacketHardeningPlanValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        RefreshedInternalPacketHardeningPlanValidationFinding(
          id: id,
          severity: RefreshedInternalPacketHardeningValidationSeverity.critical,
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

List<RefreshedInternalPacketHardeningTarget> _targetsFromImpact({
  required InternalPacketEvidenceHardeningPlanResult hardeningResult,
  required TargetedGoldenCoverageImpactReviewResult impactResult,
}) {
  final impactByScope =
      <
        InternalNonLabelPrototypeScopeId,
        TargetedGoldenCoverageHardeningTargetImpactRow
      >{for (final row in impactResult.hardeningTargetRows) row.scopeId: row};
  final targets = <RefreshedInternalPacketHardeningTarget>[];
  for (final target in hardeningResult.targets) {
    final impactRow = impactByScope[target.scopeId];
    targets.add(_refreshedTargetFrom(target, impactRow, impactResult));
  }
  targets.sort((a, b) => a.scopeId.index.compareTo(b.scopeId.index));
  return List<RefreshedInternalPacketHardeningTarget>.unmodifiable(targets);
}

RefreshedInternalPacketHardeningTarget _refreshedTargetFrom(
  InternalPacketEvidenceHardeningTarget target,
  TargetedGoldenCoverageHardeningTargetImpactRow? impactRow,
  TargetedGoldenCoverageImpactReviewResult impactResult,
) {
  final improvedByCaseIds = _sortedStrings(
    impactRow?.newSupportCaseIds ?? const <String>[],
  );
  final supportCaseIds = _sortedStrings(target.supportCaseIds);
  final androidProofCaseIds = _sortedStrings(target.androidProofCaseIds);
  final stillWarningLimited =
      target.targetKind ==
      InternalPacketEvidenceHardeningTargetKind.warningScope;
  final stillBlocked = target.isBlockedOrFuture;
  final impactStatus = _impactStatusForTarget(
    target: target,
    impactRow: impactRow,
    impactResult: impactResult,
  );
  final action = _refreshedActionFor(
    target: target,
    impactRow: impactRow,
    impactResult: impactResult,
  );
  final refreshedPriority = _refreshedPriorityFor(
    target: target,
    action: action,
  );
  final gaps = _remainingGapsFor(
    target: target,
    action: action,
    improvedByCaseIds: improvedByCaseIds,
  );

  return RefreshedInternalPacketHardeningTarget(
    targetId: target.targetId,
    targetKind: target.targetKind,
    scopeId: target.scopeId,
    packetId: target.packetId,
    previousActionFrom32D:
        impactRow?.previousActionFrom32D ?? target.recommendedAction.wire,
    impactStatusFrom32F: impactStatus,
    refreshedAction: action,
    previousPriority: target.priority,
    refreshedPriority: refreshedPriority,
    improvedByCaseIds: improvedByCaseIds,
    supportCaseIds: supportCaseIds,
    androidProofCaseIds: androidProofCaseIds,
    remainingCoverageGaps: gaps,
    stillWarningLimited: stillWarningLimited,
    stillBlocked: stillBlocked,
    ownerProofAllowed: target.ownerProofAllowed,
    ownerProofRequired:
        action ==
            RefreshedInternalPacketHardeningActionType
                .ownerProofOnlyIfPvRequired &&
        target.ownerProofRequired,
    reason: _reasonFor(target, action, improvedByCaseIds),
    nextStep: _nextStepFor(target, action),
    isProductOutput: target.isProductOutput,
    isClassifierLabel: target.isClassifierLabel,
    isOfficialMetric: target.isOfficialMetric,
    hasNumericValue: target.hasNumericValue,
    ordersMoves: target.ordersMoves,
    quietScopeActive: target.quietScopeActive,
    cpLossComputationImplemented: target.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        target.winProbabilityComputationImplemented,
    emittedOutputNames: target.emittedOutputNames,
  );
}

RefreshedInternalPacketHardeningActionType _refreshedActionFor({
  required InternalPacketEvidenceHardeningTarget target,
  required TargetedGoldenCoverageHardeningTargetImpactRow? impactRow,
  required TargetedGoldenCoverageImpactReviewResult impactResult,
}) {
  if (target.hasUnsafeOutput ||
      impactResult.unsafeCaseCount > 0 ||
      impactResult.sourceImpactStatusOrUnsafe) {
    return RefreshedInternalPacketHardeningActionType.blockUnsafeScope;
  }
  if (target.ownerProofRequired &&
      _hasExplicitPvReason('${target.targetId} ${target.reason}')) {
    return RefreshedInternalPacketHardeningActionType
        .ownerProofOnlyIfPvRequired;
  }
  if (target.targetKind ==
      InternalPacketEvidenceHardeningTargetKind.androidProofScope) {
    return RefreshedInternalPacketHardeningActionType.keepProofLimited;
  }
  if (target.targetKind ==
      InternalPacketEvidenceHardeningTargetKind.futureOnlyScope) {
    return RefreshedInternalPacketHardeningActionType.keepFutureOnly;
  }
  if (target.targetKind ==
      InternalPacketEvidenceHardeningTargetKind.blockedScope) {
    return target.scopeId ==
            InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope
        ? RefreshedInternalPacketHardeningActionType.keepExcludedByNegativeGuard
        : RefreshedInternalPacketHardeningActionType.keepBlockedByPolicy;
  }
  if (target.targetKind ==
      InternalPacketEvidenceHardeningTargetKind.warningScope) {
    return (impactRow?.improved ?? false)
        ? RefreshedInternalPacketHardeningActionType
              .keepWarningLimitedButImproved
        : RefreshedInternalPacketHardeningActionType.addMoreGoldenCoverage;
  }
  if (target.scopeId ==
      InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope) {
    return (impactRow?.improved ?? false)
        ? RefreshedInternalPacketHardeningActionType
              .downgradeCoverageNeedToWatch
        : RefreshedInternalPacketHardeningActionType.addMoreGoldenCoverage;
  }
  if ((impactRow?.improved ?? false) &&
      (target.scopeId ==
              InternalNonLabelPrototypeScopeId
                  .forcingLineInternalPrototypeScope ||
          target.scopeId ==
              InternalNonLabelPrototypeScopeId
                  .candidateSpreadInternalPrototypeScope)) {
    return RefreshedInternalPacketHardeningActionType.preserveImprovedPacket;
  }
  return RefreshedInternalPacketHardeningActionType.preserveStablePacket;
}

InternalPacketEvidenceHardeningPriority _refreshedPriorityFor({
  required InternalPacketEvidenceHardeningTarget target,
  required RefreshedInternalPacketHardeningActionType action,
}) {
  return switch (action) {
    RefreshedInternalPacketHardeningActionType.blockUnsafeScope ||
    RefreshedInternalPacketHardeningActionType.investigateUnsafeImpact =>
      InternalPacketEvidenceHardeningPriority.critical,
    RefreshedInternalPacketHardeningActionType.addMoreGoldenCoverage =>
      target.priority.rank >=
              InternalPacketEvidenceHardeningPriority.medium.rank
          ? InternalPacketEvidenceHardeningPriority.medium
          : InternalPacketEvidenceHardeningPriority.low,
    RefreshedInternalPacketHardeningActionType.keepWarningLimitedButImproved ||
    RefreshedInternalPacketHardeningActionType.downgradeCoverageNeedToWatch ||
    RefreshedInternalPacketHardeningActionType.keepProofLimited ||
    RefreshedInternalPacketHardeningActionType.ownerProofOnlyIfPvRequired =>
      InternalPacketEvidenceHardeningPriority.low,
    _ => InternalPacketEvidenceHardeningPriority.none,
  };
}

TargetedGoldenCoverageImpactStatus _impactStatusForTarget({
  required InternalPacketEvidenceHardeningTarget target,
  required TargetedGoldenCoverageHardeningTargetImpactRow? impactRow,
  required TargetedGoldenCoverageImpactReviewResult impactResult,
}) {
  if (target.hasUnsafeOutput || impactResult.unsafeCaseCount > 0) {
    return TargetedGoldenCoverageImpactStatus.blockedByUnsafeCase;
  }
  if (impactRow?.improved ?? false) {
    return target.targetKind ==
            InternalPacketEvidenceHardeningTargetKind.warningScope
        ? TargetedGoldenCoverageImpactStatus.coverageImprovedWithWarnings
        : TargetedGoldenCoverageImpactStatus.coverageImproved;
  }
  return TargetedGoldenCoverageImpactStatus.noMeaningfulCoverageChange;
}

List<String> _remainingGapsFor({
  required InternalPacketEvidenceHardeningTarget target,
  required RefreshedInternalPacketHardeningActionType action,
  required List<String> improvedByCaseIds,
}) {
  if (action ==
      RefreshedInternalPacketHardeningActionType.addMoreGoldenCoverage) {
    return _sortedStrings(<String>[
      ...target.missingCoverageAreas,
      target.suggestedCaseArea,
    ]);
  }
  if (action ==
      RefreshedInternalPacketHardeningActionType.downgradeCoverageNeedToWatch) {
    return _sortedStrings(<String>[
      target.suggestedCaseArea,
      'PV/MultiPV support coverage',
    ]);
  }
  if (action ==
      RefreshedInternalPacketHardeningActionType
          .keepWarningLimitedButImproved) {
    return _sortedStrings(<String>[
      ...target.missingCoverageAreas,
      target.suggestedCaseArea,
    ]);
  }
  if (action ==
          RefreshedInternalPacketHardeningActionType.preserveImprovedPacket &&
      improvedByCaseIds.isEmpty) {
    return _sortedStrings(target.missingCoverageAreas);
  }
  return const <String>[];
}

String _reasonFor(
  InternalPacketEvidenceHardeningTarget target,
  RefreshedInternalPacketHardeningActionType action,
  List<String> improvedByCaseIds,
) {
  return switch (action) {
    RefreshedInternalPacketHardeningActionType.preserveStablePacket =>
      'stable packet remains preserved after coverage impact review',
    RefreshedInternalPacketHardeningActionType.preserveImprovedPacket =>
      'stable packet gained targeted Phase 32E support: ${_ids(improvedByCaseIds)}',
    RefreshedInternalPacketHardeningActionType.downgradeCoverageNeedToWatch =>
      'PV/MultiPV boundary support improved but remains warning-aware',
    RefreshedInternalPacketHardeningActionType.keepWarningLimitedButImproved =>
      'warning-limited scope gained support but remains outside core packets',
    RefreshedInternalPacketHardeningActionType.keepProofLimited =>
      'Android proof confidence remains limited to captured proof IDs',
    RefreshedInternalPacketHardeningActionType.keepBlockedByPolicy =>
      'scope remains blocked by policy',
    RefreshedInternalPacketHardeningActionType.keepExcludedByNegativeGuard =>
      'quiet/preparatory remains excluded by negative guard',
    RefreshedInternalPacketHardeningActionType.keepFutureOnly =>
      'scope remains future-only',
    RefreshedInternalPacketHardeningActionType.addMoreGoldenCoverage =>
      'target still needs more internal Golden coverage',
    RefreshedInternalPacketHardeningActionType.ownerProofOnlyIfPvRequired =>
      'owner proof remains opt-in for explicit PV/MultiPV reason',
    RefreshedInternalPacketHardeningActionType.investigateUnsafeImpact ||
    RefreshedInternalPacketHardeningActionType.blockUnsafeScope =>
      'unsafe impact must be investigated before refresh can proceed',
  };
}

String _nextStepFor(
  InternalPacketEvidenceHardeningTarget target,
  RefreshedInternalPacketHardeningActionType action,
) {
  return switch (action) {
    RefreshedInternalPacketHardeningActionType.preserveStablePacket =>
      'preserve packet type and current support mapping',
    RefreshedInternalPacketHardeningActionType.preserveImprovedPacket =>
      'preserve packet type with refreshed Phase 32E support mapping',
    RefreshedInternalPacketHardeningActionType.downgradeCoverageNeedToWatch =>
      'watch PV/MultiPV boundary coverage during Phase 32H validation',
    RefreshedInternalPacketHardeningActionType.keepWarningLimitedButImproved =>
      'keep warning-limited boundary visible during Phase 32H validation',
    RefreshedInternalPacketHardeningActionType.keepProofLimited =>
      'keep proof IDs limited to ${_ids(target.androidProofCaseIds)}',
    RefreshedInternalPacketHardeningActionType.keepBlockedByPolicy =>
      'keep scope inactive under policy boundary',
    RefreshedInternalPacketHardeningActionType.keepExcludedByNegativeGuard =>
      'keep quiet/preparatory excluded by the negative guard',
    RefreshedInternalPacketHardeningActionType.keepFutureOnly =>
      'keep scope inactive until future prerequisites are met',
    RefreshedInternalPacketHardeningActionType.addMoreGoldenCoverage =>
      'add more internal Golden coverage before broader prototype work',
    RefreshedInternalPacketHardeningActionType.ownerProofOnlyIfPvRequired =>
      'run owner proof only if explicit PV/MultiPV evidence is required',
    RefreshedInternalPacketHardeningActionType.investigateUnsafeImpact ||
    RefreshedInternalPacketHardeningActionType.blockUnsafeScope =>
      'block refresh and investigate unsafe impact',
  };
}

RefreshedInternalPacketHardeningPlanResult _resultFromTargets({
  required InternalPacketEvidenceHardeningPlanResult hardeningResult,
  required TargetedGoldenCoverageImpactReviewResult impactResult,
  required List<RefreshedInternalPacketHardeningTarget> targets,
  required List<RefreshedInternalPacketHardeningPlanValidationFinding>
  validationFindings,
}) {
  final unsafeCount =
      impactResult.unsafeCaseCount +
      targets.where((target) => target.hasUnsafeOutput).length;
  final criticalCount = validationFindings
      .where((finding) => finding.isCritical)
      .length;
  final ownerProofQueueCount = targets
      .where((target) => target.ownerProofRequired)
      .length;
  final base = RefreshedInternalPacketHardeningPlanResult(
    refreshedStatus: RefreshedInternalPacketHardeningStatus.invalid,
    sourceImpactStatus: impactResult.impactStatus,
    sourceHardeningStatus: hardeningResult.hardeningStatus,
    targets: targets,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...hardeningResult.warnings,
      ...impactResult.warnings,
      if (targets.any((target) => target.stillWarningLimited))
        'warning-limited scopes remain outside core packets',
    ]),
    failures: _sortedStrings(<String>[
      ...hardeningResult.failures,
      ...impactResult.failures,
      ...validationFindings.map((finding) => finding.message),
    ]),
    totalTargets: targets.length,
    improvedTargetCount: targets.where((target) => target.isImproved).length,
    preservedTargetCount: targets
        .where(
          (target) =>
              target.refreshedAction ==
                  RefreshedInternalPacketHardeningActionType
                      .preserveStablePacket ||
              target.refreshedAction ==
                  RefreshedInternalPacketHardeningActionType
                      .preserveImprovedPacket,
        )
        .length,
    warningLimitedImprovedCount: targets
        .where(
          (target) =>
              target.stillWarningLimited && target.improvedByCaseIds.isNotEmpty,
        )
        .length,
    stillWarningLimitedCount: targets
        .where((target) => target.stillWarningLimited)
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
    proofLimitedCount: targets
        .where(
          (target) =>
              target.targetKind ==
                  InternalPacketEvidenceHardeningTargetKind.androidProofScope ||
              target.refreshedAction ==
                  RefreshedInternalPacketHardeningActionType.keepProofLimited,
        )
        .length,
    ownerProofQueueCount: ownerProofQueueCount,
    unsafeCount: unsafeCount,
    criticalCount: criticalCount,
    newSupportCaseIds: _sortedStrings(impactResult.newSupportCaseIds),
    androidProofCaseIds: _sortedStrings(impactResult.androidProofCaseIds),
    remainingCoverageGapIds: _sortedStrings(
      targets.expand((target) => target.remainingCoverageGaps),
    ),
    safeForPhase32H:
        impactResult.safeForPhase32G &&
        hardeningResult.safeForPhase32E &&
        unsafeCount == 0 &&
        criticalCount == 0 &&
        !validationFindings.any((finding) => finding.blocksStrict) &&
        !impactResult.hasUnsafeImpactPolicyViolation &&
        !hardeningResult.hasUnsafeHardeningPolicyViolation,
    phase32HRecommendation: RefreshedInternalPacketPhase32HRecommendation
        .addMoreGoldenCoverageFirst,
    productLabelsEmitted:
        impactResult.productLabelsEmitted ||
        hardeningResult.productLabelsEmitted,
    advancedLabelsEmitted: impactResult.advancedLabelsEmitted,
    classifierLabelsEmitted:
        impactResult.classifierLabelsEmitted ||
        hardeningResult.classifierLabelsEmitted,
    finalMoveLabelsEmitted:
        impactResult.finalMoveLabelsEmitted ||
        hardeningResult.finalMoveLabelsEmitted,
    officialMetricsAllowed:
        impactResult.officialMetricsAllowed ||
        hardeningResult.officialMetricsAllowed,
    cpLossComputationImplemented:
        impactResult.cpLossComputationImplemented ||
        hardeningResult.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        impactResult.winProbabilityComputationImplemented ||
        hardeningResult.winProbabilityComputationImplemented,
    numericMoveValuesComputed:
        impactResult.numericMoveValuesComputed ||
        hardeningResult.numericMoveValuesComputed,
    moveOrderingComputed:
        impactResult.moveOrderingComputed ||
        hardeningResult.moveOrderingComputed,
    quietPreparatoryScopeActivated: impactResult.quietPreparatoryScopeActivated,
    directEngineAccessUsed:
        impactResult.directEngineAccessUsed ||
        hardeningResult.directEngineAccessUsed,
    uiOutputUsed: impactResult.uiOutputUsed || hardeningResult.uiOutputUsed,
    backendOutputUsed:
        impactResult.backendOutputUsed || hardeningResult.backendOutputUsed,
    persistenceUsed:
        impactResult.persistenceUsed || hardeningResult.persistenceUsed,
    emittedOutputFamilies: _sortedStrings(<String>[
      ...impactResult.emittedOutputFamilies,
      ...hardeningResult.emittedOutputFamilies,
    ]),
  );
  return base.copyWith(
    refreshedStatus: _statusFor(base),
    phase32HRecommendation: _phase32HRecommendationFor(base),
  );
}

RefreshedInternalPacketHardeningStatus _statusFor(
  RefreshedInternalPacketHardeningPlanResult result,
) {
  if (result.hasUnsafeRefreshPolicyViolation ||
      result.sourceImpactStatus.isUnsafe ||
      result.validationFindings.any((finding) => finding.isCritical)) {
    return RefreshedInternalPacketHardeningStatus.blockedByUnsafeImpact;
  }
  if (result.validationFindings.any((finding) => finding.blocksStrict)) {
    return RefreshedInternalPacketHardeningStatus.blockedByPolicyBoundary;
  }
  if (result.newSupportCaseIds.length < _phase32ECaseIds.length) {
    return RefreshedInternalPacketHardeningStatus.invalid;
  }
  if (result.improvedTargetCount == 0) {
    return RefreshedInternalPacketHardeningStatus.noRefreshNeeded;
  }
  if (result.ownerProofQueueCount > 0) {
    return RefreshedInternalPacketHardeningStatus.refreshedWithWarnings;
  }
  if (result.stillWarningLimitedCount > 0 ||
      result.remainingCoverageGapIds.isNotEmpty) {
    return RefreshedInternalPacketHardeningStatus.refreshedWithWarnings;
  }
  return RefreshedInternalPacketHardeningStatus.refreshedWithImprovedCoverage;
}

RefreshedInternalPacketPhase32HRecommendation _phase32HRecommendationFor(
  RefreshedInternalPacketHardeningPlanResult result,
) {
  if (result.hasUnsafeRefreshPolicyViolation ||
      result.sourceImpactStatus.isUnsafe ||
      result.validationFindings.any((finding) => finding.isCritical)) {
    return RefreshedInternalPacketPhase32HRecommendation.blockedByUnsafeRefresh;
  }
  if (result.ownerProofQueueCount > 0) {
    return RefreshedInternalPacketPhase32HRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (result.improvedTargetCount == 0) {
    return RefreshedInternalPacketPhase32HRecommendation
        .addMoreGoldenCoverageFirst;
  }
  if (result.stillWarningLimitedCount > 0 ||
      result.remainingCoverageGapIds.isNotEmpty) {
    return RefreshedInternalPacketPhase32HRecommendation
        .validateRefreshedHardeningPlan;
  }
  return RefreshedInternalPacketPhase32HRecommendation
      .proceedToInternalPacketEvidenceRefresh;
}

Set<String> _provenAndroidProofIds(
  GoldenAndroidProofEvidence? androidProofEvidence,
) {
  final proofIds = androidProofEvidence?.targetCaseIds ?? const <String>[];
  return proofIds.where(_capturedAndroidProofIds.contains).toSet();
}

bool _hasExplicitPvReason(String value) {
  final lower = value.toLowerCase();
  return lower.contains('pv') || lower.contains('multipv');
}

String _cell(String value) => value.replaceAll('|', '/');

String _ids(Iterable<String> values) {
  final ids = _sortedStrings(values);
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _scopeIds(Iterable<RefreshedInternalPacketHardeningTarget> values) {
  final ids = values.map((target) => target.scopeId.wire).toSet().toList()
    ..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _targetIds(Iterable<RefreshedInternalPacketHardeningTarget> values) {
  final ids = values.map((target) => target.targetId).toSet().toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.where((value) => value.isNotEmpty).toSet().toList()..sort();
}

int _compareFindings(
  RefreshedInternalPacketHardeningPlanValidationFinding a,
  RefreshedInternalPacketHardeningPlanValidationFinding b,
) {
  final severityCompare = b.severity.index.compareTo(a.severity.index);
  if (severityCompare != 0) return severityCompare;
  final idCompare = a.id.compareTo(b.id);
  if (idCompare != 0) return idCompare;
  final caseCompare = (a.caseId ?? '').compareTo(b.caseId ?? '');
  if (caseCompare != 0) return caseCompare;
  return (a.targetId ?? '').compareTo(b.targetId ?? '');
}

bool _isForbiddenOutputName(String value) {
  final normalized = value.trim().toLowerCase();
  return _forbiddenOutputNames.contains(normalized);
}

extension on TargetedGoldenCoverageImpactReviewResult {
  bool get sourceImpactStatusOrUnsafe =>
      impactStatus == TargetedGoldenCoverageImpactStatus.blockedByUnsafeCase ||
      impactStatus == TargetedGoldenCoverageImpactStatus.invalid;
}

const _phase32ECaseIds = <String>{
  'king-safety-mating-net-pressure-32e',
  'endgame-precision-candidate-spread-32e',
  'suppression-forced-only-legal-32e',
  'budget-pressure-wide-candidate-32e',
  'pv-multipv-support-boundary-32e',
};

const _capturedAndroidProofIds = <String>{
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
};

const _blockedPolicyScopes = <InternalNonLabelPrototypeScopeId>{
  InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
  InternalNonLabelPrototypeScopeId.productLabelPrototypeScope,
  InternalNonLabelPrototypeScopeId.advancedLabelPrototypeScope,
  InternalNonLabelPrototypeScopeId.officialMetricPrototypeScope,
  InternalNonLabelPrototypeScopeId.cpLossPrototypeScope,
  InternalNonLabelPrototypeScopeId.winProbabilityPrototypeScope,
  InternalNonLabelPrototypeScopeId.uiProductIntegrationScope,
  InternalNonLabelPrototypeScopeId.backendIntegrationScope,
  InternalNonLabelPrototypeScopeId.persistenceScope,
  InternalNonLabelPrototypeScopeId.directEngineAccessScope,
};

const _activeAllowedRefreshActions =
    <RefreshedInternalPacketHardeningActionType>{
      RefreshedInternalPacketHardeningActionType.preserveStablePacket,
      RefreshedInternalPacketHardeningActionType.preserveImprovedPacket,
      RefreshedInternalPacketHardeningActionType.downgradeCoverageNeedToWatch,
      RefreshedInternalPacketHardeningActionType.addMoreGoldenCoverage,
      RefreshedInternalPacketHardeningActionType.ownerProofOnlyIfPvRequired,
    };

const _forbiddenOutputNames = <String>{
  'brilliant',
  'great',
  'miss',
  'best',
  'good',
  'inaccuracy',
  'mistake',
  'blunder',
  'accuracy',
  'acpl',
  'cp-loss',
  'win probability',
  'score',
  'ranking',
};

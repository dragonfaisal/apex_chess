/// Developer-only validation for the refreshed internal packet hardening plan.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_review_aggregation_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_stability_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/narrow_internal_non_label_analysis_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_internal_packet_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/targeted_golden_coverage_impact_review.dart';

const refreshedPacketHardeningValidationReportVersion =
    'refreshed-packet-hardening-validation-v1';

enum RefreshedPacketHardeningValidationStatus {
  validatedWithWarnings('validatedWithWarnings'),
  validatedClean('validatedClean'),
  blockedByUnsafeRefresh('blockedByUnsafeRefresh'),
  blockedByMissingImpactSupport('blockedByMissingImpactSupport'),
  blockedByPolicyLeak('blockedByPolicyLeak'),
  blockedByUnprovenAndroidProof('blockedByUnprovenAndroidProof'),
  invalid('invalid');

  const RefreshedPacketHardeningValidationStatus(this.wire);

  final String wire;
}

enum RefreshedPacketHardeningValidationCheckId {
  refreshedPlanConsumesImpactReview('refreshedPlanConsumesImpactReview'),
  improvedTargetsHaveNewSupportCases('improvedTargetsHaveNewSupportCases'),
  preservedTargetsRemainStable('preservedTargetsRemainStable'),
  warningLimitedTargetsRemainWarningLimited(
    'warningLimitedTargetsRemainWarningLimited',
  ),
  pvMultiPvWatchListIsBoundaryOnly('pvMultiPvWatchListIsBoundaryOnly'),
  androidProofTargetRemainsProofLimited(
    'androidProofTargetRemainsProofLimited',
  ),
  noPhase32ECaseClaimsCapturedProof('noPhase32ECaseClaimsCapturedProof'),
  ownerProofQueueRemainsEmpty('ownerProofQueueRemainsEmpty'),
  quietScopeRemainsExcluded('quietScopeRemainsExcluded'),
  productLabelsRemainBlocked('productLabelsRemainBlocked'),
  officialMetricsRemainBlocked('officialMetricsRemainBlocked'),
  futureOnlyInputsRemainFutureOnly('futureOnlyInputsRemainFutureOnly'),
  integrationScopesRemainBlocked('integrationScopesRemainBlocked'),
  noLabelsScoresRankingsMetrics('noLabelsScoresRankingsMetrics'),
  noEngineOrAndroidRequirement('noEngineOrAndroidRequirement');

  const RefreshedPacketHardeningValidationCheckId(this.wire);

  final String wire;
}

enum RefreshedPacketHardeningValidationCheckStatus {
  passed('passed'),
  passedWithWarnings('passedWithWarnings'),
  failed('failed'),
  blocked('blocked'),
  notApplicable('notApplicable');

  const RefreshedPacketHardeningValidationCheckStatus(this.wire);

  final String wire;
}

enum RefreshedPacketHardeningValidationSeverity {
  none('none'),
  info('info'),
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const RefreshedPacketHardeningValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == RefreshedPacketHardeningValidationSeverity.blocker ||
      this == RefreshedPacketHardeningValidationSeverity.critical;
}

enum RefreshedPacketHardeningValidationRecommendation {
  keepRefreshedPlan('keepRefreshedPlan'),
  keepWarningsVisible('keepWarningsVisible'),
  keepProofLimited('keepProofLimited'),
  keepBlockedByPolicy('keepBlockedByPolicy'),
  keepFutureOnly('keepFutureOnly'),
  proceedToEvidenceRefresh('proceedToEvidenceRefresh'),
  addMoreGoldenCoverage('addMoreGoldenCoverage'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  investigateValidationFailure('investigateValidationFailure');

  const RefreshedPacketHardeningValidationRecommendation(this.wire);

  final String wire;
}

enum RefreshedPacketHardeningPhase32IRecommendation {
  proceedToInternalPacketEvidenceRefresh(
    'proceedToInternalPacketEvidenceRefresh',
  ),
  proceedToValidationSummaryOnly('proceedToValidationSummaryOnly'),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByValidationFailure('blockedByValidationFailure');

  const RefreshedPacketHardeningPhase32IRecommendation(this.wire);

  final String wire;
}

enum RefreshedPacketHardeningValidationReportFormat {
  markdown('markdown'),
  json('json');

  const RefreshedPacketHardeningValidationReportFormat(this.wire);

  final String wire;
}

class RefreshedPacketHardeningValidationRequest {
  const RefreshedPacketHardeningValidationRequest({
    this.refreshedPlanResult,
    this.impactReviewResult,
    this.hardeningPlanResult,
    this.stabilityResult,
    this.matrixResult,
    this.prototypeResult,
    this.refreshedPlan = const RefreshedInternalPacketHardeningPlan(),
    this.impactReview = const TargetedGoldenCoverageImpactReview(),
    this.hardeningPlan = const InternalPacketEvidenceHardeningPlan(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const RefreshedPacketHardeningValidationRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final RefreshedInternalPacketHardeningPlanResult? refreshedPlanResult;
  final TargetedGoldenCoverageImpactReviewResult? impactReviewResult;
  final InternalPacketEvidenceHardeningPlanResult? hardeningPlanResult;
  final InternalPacketStabilityPrototypeResult? stabilityResult;
  final InternalPacketReviewAggregationMatrixResult? matrixResult;
  final NarrowInternalNonLabelAnalysisPrototypeResult? prototypeResult;
  final RefreshedInternalPacketHardeningPlan refreshedPlan;
  final TargetedGoldenCoverageImpactReview impactReview;
  final InternalPacketEvidenceHardeningPlan hardeningPlan;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class RefreshedPacketHardeningValidationCheck {
  const RefreshedPacketHardeningValidationCheck({
    required this.checkId,
    required this.status,
    required this.severity,
    required this.relatedTargetIds,
    required this.relatedCaseIds,
    required this.relatedAndroidProofIds,
    required this.warningReason,
    required this.failureReason,
    required this.recommendation,
  });

  final RefreshedPacketHardeningValidationCheckId checkId;
  final RefreshedPacketHardeningValidationCheckStatus status;
  final RefreshedPacketHardeningValidationSeverity severity;
  final List<String> relatedTargetIds;
  final List<String> relatedCaseIds;
  final List<String> relatedAndroidProofIds;
  final String warningReason;
  final String failureReason;
  final RefreshedPacketHardeningValidationRecommendation recommendation;

  bool get blocksStrict =>
      severity.blocksStrict ||
      status == RefreshedPacketHardeningValidationCheckStatus.blocked ||
      status == RefreshedPacketHardeningValidationCheckStatus.failed;

  bool get isCritical =>
      severity == RefreshedPacketHardeningValidationSeverity.critical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'checkId': checkId.wire,
      'status': status.wire,
      'severity': severity.wire,
      'relatedTargetIds': relatedTargetIds,
      'relatedCaseIds': relatedCaseIds,
      'relatedAndroidProofIds': relatedAndroidProofIds,
      'warningReason': warningReason,
      'failureReason': failureReason,
      'recommendation': recommendation.wire,
    };
  }
}

class RefreshedPacketHardeningTargetValidationSummary {
  const RefreshedPacketHardeningTargetValidationSummary({
    required this.targetId,
    required this.scopeId,
    required this.targetKind,
    required this.refreshedAction,
    required this.validationStatus,
    required this.supportCaseIds,
    required this.improvedByCaseIds,
    required this.androidProofCaseIds,
    required this.stillWarningLimited,
    required this.stillBlocked,
    required this.ownerProofRequired,
    required this.failureReason,
  });

  final String targetId;
  final InternalNonLabelPrototypeScopeId scopeId;
  final InternalPacketEvidenceHardeningTargetKind targetKind;
  final RefreshedInternalPacketHardeningActionType refreshedAction;
  final RefreshedPacketHardeningValidationCheckStatus validationStatus;
  final List<String> supportCaseIds;
  final List<String> improvedByCaseIds;
  final List<String> androidProofCaseIds;
  final bool stillWarningLimited;
  final bool stillBlocked;
  final bool ownerProofRequired;
  final String failureReason;

  bool get isImproved => improvedByCaseIds.isNotEmpty;

  bool get isUnsafe =>
      validationStatus ==
          RefreshedPacketHardeningValidationCheckStatus.failed ||
      validationStatus == RefreshedPacketHardeningValidationCheckStatus.blocked;

  RefreshedPacketHardeningTargetValidationSummary copyWith({
    String? targetId,
    InternalNonLabelPrototypeScopeId? scopeId,
    InternalPacketEvidenceHardeningTargetKind? targetKind,
    RefreshedInternalPacketHardeningActionType? refreshedAction,
    RefreshedPacketHardeningValidationCheckStatus? validationStatus,
    List<String>? supportCaseIds,
    List<String>? improvedByCaseIds,
    List<String>? androidProofCaseIds,
    bool? stillWarningLimited,
    bool? stillBlocked,
    bool? ownerProofRequired,
    String? failureReason,
  }) {
    return RefreshedPacketHardeningTargetValidationSummary(
      targetId: targetId ?? this.targetId,
      scopeId: scopeId ?? this.scopeId,
      targetKind: targetKind ?? this.targetKind,
      refreshedAction: refreshedAction ?? this.refreshedAction,
      validationStatus: validationStatus ?? this.validationStatus,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      improvedByCaseIds: improvedByCaseIds ?? this.improvedByCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      stillWarningLimited: stillWarningLimited ?? this.stillWarningLimited,
      stillBlocked: stillBlocked ?? this.stillBlocked,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'targetId': targetId,
      'scopeId': scopeId.wire,
      'targetKind': targetKind.wire,
      'refreshedAction': refreshedAction.wire,
      'validationStatus': validationStatus.wire,
      'supportCaseIds': supportCaseIds,
      'improvedByCaseIds': improvedByCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'stillWarningLimited': stillWarningLimited,
      'stillBlocked': stillBlocked,
      'ownerProofRequired': ownerProofRequired,
      'failureReason': failureReason,
    };
  }
}

class RefreshedPacketHardeningValidationFinding {
  const RefreshedPacketHardeningValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.checkId,
    this.targetId,
    this.scopeId,
    this.caseId,
  });

  final String id;
  final RefreshedPacketHardeningValidationSeverity severity;
  final String message;
  final RefreshedPacketHardeningValidationCheckId? checkId;
  final String? targetId;
  final InternalNonLabelPrototypeScopeId? scopeId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical =>
      severity == RefreshedPacketHardeningValidationSeverity.critical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (checkId != null) 'checkId': checkId!.wire,
      if (targetId != null) 'targetId': targetId,
      if (scopeId != null) 'scopeId': scopeId!.wire,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class RefreshedPacketHardeningValidationResult {
  const RefreshedPacketHardeningValidationResult({
    required this.validationStatus,
    required this.sourceRefreshStatus,
    required this.sourceImpactStatus,
    required this.sourceHardeningStatus,
    required this.checks,
    required this.targetSummaries,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalChecks,
    required this.passedCount,
    required this.warningCount,
    required this.blockerCount,
    required this.criticalCount,
    required this.validatedTargetCount,
    required this.warningLimitedTargetCount,
    required this.blockedScopeCount,
    required this.futureOnlyScopeCount,
    required this.ownerProofQueueCount,
    required this.unsafeCount,
    required this.androidProofCaseIds,
    required this.phase32ECaseIds,
    required this.safeForPhase32I,
    required this.phase32IRecommendation,
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

  final RefreshedPacketHardeningValidationStatus validationStatus;
  final RefreshedInternalPacketHardeningStatus sourceRefreshStatus;
  final TargetedGoldenCoverageImpactStatus sourceImpactStatus;
  final InternalPacketEvidenceHardeningStatus sourceHardeningStatus;
  final List<RefreshedPacketHardeningValidationCheck> checks;
  final List<RefreshedPacketHardeningTargetValidationSummary> targetSummaries;
  final List<RefreshedPacketHardeningValidationFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalChecks;
  final int passedCount;
  final int warningCount;
  final int blockerCount;
  final int criticalCount;
  final int validatedTargetCount;
  final int warningLimitedTargetCount;
  final int blockedScopeCount;
  final int futureOnlyScopeCount;
  final int ownerProofQueueCount;
  final int unsafeCount;
  final List<String> androidProofCaseIds;
  final List<String> phase32ECaseIds;
  final bool safeForPhase32I;
  final RefreshedPacketHardeningPhase32IRecommendation phase32IRecommendation;
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
      validationStatus ==
          RefreshedPacketHardeningValidationStatus.blockedByUnsafeRefresh ||
      validationStatus ==
          RefreshedPacketHardeningValidationStatus
              .blockedByMissingImpactSupport ||
      validationStatus ==
          RefreshedPacketHardeningValidationStatus.blockedByPolicyLeak ||
      validationStatus ==
          RefreshedPacketHardeningValidationStatus
              .blockedByUnprovenAndroidProof ||
      validationStatus == RefreshedPacketHardeningValidationStatus.invalid ||
      !safeForPhase32I ||
      blockerCount > 0 ||
      criticalCount > 0 ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeValidationPolicyViolation {
    return unsafeCount > 0 ||
        criticalCount > 0 ||
        validationFindings.any((finding) => finding.isCritical) ||
        targetSummaries.any((summary) => summary.isUnsafe) ||
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

  RefreshedPacketHardeningValidationCheck check(
    RefreshedPacketHardeningValidationCheckId checkId,
  ) {
    return checks.singleWhere((check) => check.checkId == checkId);
  }

  RefreshedPacketHardeningTargetValidationSummary target(
    InternalNonLabelPrototypeScopeId scopeId,
  ) {
    return targetSummaries.singleWhere((target) => target.scopeId == scopeId);
  }

  List<RefreshedPacketHardeningTargetValidationSummary>
  get warningLimitedTargets => targetSummaries
      .where((target) => target.stillWarningLimited)
      .toList(growable: false);

  List<RefreshedPacketHardeningTargetValidationSummary>
  get blockedOrFutureTargets => targetSummaries
      .where((target) => target.stillBlocked)
      .toList(growable: false);

  RefreshedPacketHardeningValidationResult copyWith({
    RefreshedPacketHardeningValidationStatus? validationStatus,
    RefreshedInternalPacketHardeningStatus? sourceRefreshStatus,
    TargetedGoldenCoverageImpactStatus? sourceImpactStatus,
    InternalPacketEvidenceHardeningStatus? sourceHardeningStatus,
    List<RefreshedPacketHardeningValidationCheck>? checks,
    List<RefreshedPacketHardeningTargetValidationSummary>? targetSummaries,
    List<RefreshedPacketHardeningValidationFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalChecks,
    int? passedCount,
    int? warningCount,
    int? blockerCount,
    int? criticalCount,
    int? validatedTargetCount,
    int? warningLimitedTargetCount,
    int? blockedScopeCount,
    int? futureOnlyScopeCount,
    int? ownerProofQueueCount,
    int? unsafeCount,
    List<String>? androidProofCaseIds,
    List<String>? phase32ECaseIds,
    bool? safeForPhase32I,
    RefreshedPacketHardeningPhase32IRecommendation? phase32IRecommendation,
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
    return RefreshedPacketHardeningValidationResult(
      validationStatus: validationStatus ?? this.validationStatus,
      sourceRefreshStatus: sourceRefreshStatus ?? this.sourceRefreshStatus,
      sourceImpactStatus: sourceImpactStatus ?? this.sourceImpactStatus,
      sourceHardeningStatus:
          sourceHardeningStatus ?? this.sourceHardeningStatus,
      checks: checks ?? this.checks,
      targetSummaries: targetSummaries ?? this.targetSummaries,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalChecks: totalChecks ?? this.totalChecks,
      passedCount: passedCount ?? this.passedCount,
      warningCount: warningCount ?? this.warningCount,
      blockerCount: blockerCount ?? this.blockerCount,
      criticalCount: criticalCount ?? this.criticalCount,
      validatedTargetCount: validatedTargetCount ?? this.validatedTargetCount,
      warningLimitedTargetCount:
          warningLimitedTargetCount ?? this.warningLimitedTargetCount,
      blockedScopeCount: blockedScopeCount ?? this.blockedScopeCount,
      futureOnlyScopeCount: futureOnlyScopeCount ?? this.futureOnlyScopeCount,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      unsafeCount: unsafeCount ?? this.unsafeCount,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      phase32ECaseIds: phase32ECaseIds ?? this.phase32ECaseIds,
      safeForPhase32I: safeForPhase32I ?? this.safeForPhase32I,
      phase32IRecommendation:
          phase32IRecommendation ?? this.phase32IRecommendation,
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
      ..writeln('# Refreshed Packet Hardening Validation')
      ..writeln()
      ..writeln('- version: $refreshedPacketHardeningValidationReportVersion')
      ..writeln('- validation status: ${validationStatus.wire}')
      ..writeln('- source refresh status: ${sourceRefreshStatus.wire}')
      ..writeln('- source impact status: ${sourceImpactStatus.wire}')
      ..writeln('- source hardening status: ${sourceHardeningStatus.wire}')
      ..writeln('- total checks: $totalChecks')
      ..writeln('- passed count: $passedCount')
      ..writeln('- warning count: $warningCount')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- validated target count: $validatedTargetCount')
      ..writeln('- warning-limited target count: $warningLimitedTargetCount')
      ..writeln('- blocked scope count: $blockedScopeCount')
      ..writeln('- future-only scope count: $futureOnlyScopeCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- safe for Phase 32I: $safeForPhase32I')
      ..writeln('- Phase 32I recommendation: ${phase32IRecommendation.wire}')
      ..writeln('- classifier output emitted: $classifierLabelsEmitted')
      ..writeln('- numeric value output emitted: $numericMoveValuesComputed')
      ..writeln('- move ordering output emitted: $moveOrderingComputed')
      ..writeln()
      ..writeln('## Validation Policy')
      ..writeln(
        '- this validation checks the refreshed internal hardening plan only',
      )
      ..writeln(
        '- it does not classify moves, compute values, order moves, call an engine, integrate product output, run Android, or write files',
      )
      ..writeln()
      ..writeln('## Validation Check Table')
      ..writeln(
        '| Check | Status | Severity | Targets | Cases | Android Proof | Warning | Failure | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- | --- |');
    for (final check in checks) {
      buffer.writeln(
        '| ${check.checkId.wire} | ${check.status.wire} | '
        '${check.severity.wire} | ${_ids(check.relatedTargetIds)} | '
        '${_ids(check.relatedCaseIds)} | '
        '${_ids(check.relatedAndroidProofIds)} | '
        '${_cell(check.warningReason)} | ${_cell(check.failureReason)} | '
        '${check.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Target Validation Summary')
      ..writeln(
        '| Target | Scope | Kind | Action | Status | Support Cases | Improved By | Android Proof | Warning-Limited | Blocked | Owner Proof | Failure |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final target in targetSummaries) {
      buffer.writeln(
        '| ${_cell(target.targetId)} | ${target.scopeId.wire} | '
        '${target.targetKind.wire} | ${target.refreshedAction.wire} | '
        '${target.validationStatus.wire} | ${_ids(target.supportCaseIds)} | '
        '${_ids(target.improvedByCaseIds)} | '
        '${_ids(target.androidProofCaseIds)} | '
        '${target.stillWarningLimited} | ${target.stillBlocked} | '
        '${target.ownerProofRequired ? "required" : "not-required"} | '
        '${_cell(target.failureReason)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Warning-Limited Targets')
      ..writeln('- ${_ids(_targetIds(warningLimitedTargets))}')
      ..writeln()
      ..writeln('## Blocked And Future-Only Scopes')
      ..writeln('- ${_scopeIds(blockedOrFutureTargets)}')
      ..writeln()
      ..writeln('## Owner Proof Queue Status')
      ..writeln(
        ownerProofQueueCount == 0
            ? '- empty'
            : '- opt-in proof requires explicit PV/MultiPV reason',
      )
      ..writeln()
      ..writeln('## Android Proof IDs')
      ..writeln('- ${_ids(androidProofCaseIds)}')
      ..writeln()
      ..writeln('## Phase 32E Case IDs')
      ..writeln('- ${_ids(phase32ECaseIds)}')
      ..writeln()
      ..writeln('## Validation Findings');
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
      ..writeln('## Phase 32I Recommendation')
      ..writeln(phase32IRecommendation.wire)
      ..writeln()
      ..writeln(
        'This validation stays internal-only. It does not emit user-facing output, compute product metrics, call the engine, run Android, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': refreshedPacketHardeningValidationReportVersion,
      'validationStatus': validationStatus.wire,
      'sourceRefreshStatus': sourceRefreshStatus.wire,
      'sourceImpactStatus': sourceImpactStatus.wire,
      'sourceHardeningStatus': sourceHardeningStatus.wire,
      'totalChecks': totalChecks,
      'passedCount': passedCount,
      'warningCount': warningCount,
      'blockerCount': blockerCount,
      'criticalCount': criticalCount,
      'validatedTargetCount': validatedTargetCount,
      'warningLimitedTargetCount': warningLimitedTargetCount,
      'blockedScopeCount': blockedScopeCount,
      'futureOnlyScopeCount': futureOnlyScopeCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'unsafeCount': unsafeCount,
      'androidProofCaseIds': androidProofCaseIds,
      'phase32ECaseIds': phase32ECaseIds,
      'safeForPhase32I': safeForPhase32I,
      'phase32IRecommendation': phase32IRecommendation.wire,
      'checks': checks.map((check) => check.toJson()).toList(),
      'targetSummaries': targetSummaries
          .map((target) => target.toJson())
          .toList(),
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

class RefreshedPacketHardeningValidation {
  const RefreshedPacketHardeningValidation({
    this.validator = const RefreshedPacketHardeningValidationValidator(),
  });

  final RefreshedPacketHardeningValidationValidator validator;

  RefreshedPacketHardeningValidationResult evaluate([
    RefreshedPacketHardeningValidationRequest request =
        const RefreshedPacketHardeningValidationRequest(),
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
    final refreshResult =
        request.refreshedPlanResult ??
        request.refreshedPlan.evaluate(
          RefreshedInternalPacketHardeningPlanRequest(
            impactReviewResult: impactResult,
            hardeningPlanResult: hardeningResult,
            stabilityResult: request.stabilityResult,
            matrixResult: request.matrixResult,
            prototypeResult: request.prototypeResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final targetSummaries = _targetSummariesFrom(refreshResult);
    final checks = _checksFor(
      refreshResult: refreshResult,
      impactResult: impactResult,
      hardeningResult: hardeningResult,
      targetSummaries: targetSummaries,
    );
    final base = _resultFromChecks(
      refreshResult: refreshResult,
      impactResult: impactResult,
      hardeningResult: hardeningResult,
      checks: checks,
      targetSummaries: targetSummaries,
      validationFindings: const <RefreshedPacketHardeningValidationFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromChecks(
      refreshResult: refreshResult,
      impactResult: impactResult,
      hardeningResult: hardeningResult,
      checks: checks,
      targetSummaries: targetSummaries,
      validationFindings: findings,
    );
  }
}

class RefreshedPacketHardeningValidationValidator {
  const RefreshedPacketHardeningValidationValidator();

  List<RefreshedPacketHardeningValidationFinding> validate(
    RefreshedPacketHardeningValidationResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <RefreshedPacketHardeningValidationFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required RefreshedPacketHardeningValidationSeverity severity,
      required String message,
      RefreshedPacketHardeningValidationCheckId? checkId,
      String? targetId,
      InternalNonLabelPrototypeScopeId? scopeId,
      String? caseId,
    }) {
      findings.add(
        RefreshedPacketHardeningValidationFinding(
          id: id,
          severity: severity,
          message: message,
          checkId: checkId,
          targetId: targetId,
          scopeId: scopeId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase32I &&
        (result.unsafeCount > 0 ||
            result.sourceRefreshStatus ==
                RefreshedInternalPacketHardeningStatus.blockedByUnsafeImpact ||
            result.targetSummaries.any((target) => target.isUnsafe))) {
      add(
        id: 'unsafeRefreshMarkedValid',
        severity: RefreshedPacketHardeningValidationSeverity.critical,
        message: 'unsafe refreshed hardening plan cannot be marked valid',
      );
    }

    for (final check in result.checks) {
      if (check.blocksStrict) {
        add(
          id: 'validationCheckBlocked',
          severity: check.isCritical
              ? RefreshedPacketHardeningValidationSeverity.critical
              : RefreshedPacketHardeningValidationSeverity.blocker,
          message: '${check.checkId.wire} did not pass validation',
          checkId: check.checkId,
        );
      }
    }

    for (final target in result.targetSummaries) {
      if (_improvedActions.contains(target.refreshedAction) &&
          target.improvedByCaseIds.isEmpty) {
        add(
          id: 'improvedTargetMissingImpactSupport',
          severity: RefreshedPacketHardeningValidationSeverity.blocker,
          message: 'improved target must cite Phase 32E support',
          targetId: target.targetId,
          scopeId: target.scopeId,
        );
      }
      if (_warningScopes.contains(target.scopeId) &&
          (!target.stillWarningLimited ||
              target.targetKind !=
                  InternalPacketEvidenceHardeningTargetKind.warningScope ||
              target.refreshedAction ==
                  RefreshedInternalPacketHardeningActionType
                      .preserveStablePacket ||
              target.refreshedAction ==
                  RefreshedInternalPacketHardeningActionType
                      .preserveImprovedPacket)) {
        add(
          id: 'warningLimitedTargetPromotedToCorePacket',
          severity: RefreshedPacketHardeningValidationSeverity.critical,
          message: '${target.scopeId.wire} cannot be promoted in Phase 32H',
          targetId: target.targetId,
          scopeId: target.scopeId,
        );
      }
      if (_blockedOrFutureScopes.contains(target.scopeId) &&
          (!target.stillBlocked ||
              _activeRefreshActions.contains(target.refreshedAction))) {
        add(
          id: 'blockedScopeBecameActive',
          severity: RefreshedPacketHardeningValidationSeverity.critical,
          message: '${target.scopeId.wire} must remain inactive',
          targetId: target.targetId,
          scopeId: target.scopeId,
        );
      }
      for (final caseId in target.androidProofCaseIds) {
        if (!_capturedAndroidProofIds.contains(caseId) ||
            !provenAndroidIds.contains(caseId)) {
          add(
            id: 'targetUnprovenAndroidProofClaim',
            severity: RefreshedPacketHardeningValidationSeverity.critical,
            message: 'target cited unproven Android proof',
            targetId: target.targetId,
            scopeId: target.scopeId,
            caseId: caseId,
          );
        }
        if (_phase32ECaseIds.contains(caseId)) {
          add(
            id: 'phase32ECaseClaimedCapturedProof',
            severity: RefreshedPacketHardeningValidationSeverity.critical,
            message: 'Phase 32E case cannot be captured Android proof',
            targetId: target.targetId,
            scopeId: target.scopeId,
            caseId: caseId,
          );
        }
      }
      if (target.ownerProofRequired &&
          !_hasExplicitPvReason('${target.targetId} ${target.failureReason}')) {
        add(
          id: 'ownerProofRequiredWithoutPvReason',
          severity: RefreshedPacketHardeningValidationSeverity.blocker,
          message: 'owner proof requires explicit PV/MultiPV reason',
          targetId: target.targetId,
          scopeId: target.scopeId,
        );
      }
      if (target.scopeId ==
              InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope &&
          !target.stillBlocked) {
        add(
          id: 'quietPreparatoryScopeActivated',
          severity: RefreshedPacketHardeningValidationSeverity.critical,
          message: 'quiet/preparatory scope must remain excluded',
          targetId: target.targetId,
          scopeId: target.scopeId,
        );
      }
    }

    for (final caseId in result.androidProofCaseIds) {
      if (!_capturedAndroidProofIds.contains(caseId) ||
          !provenAndroidIds.contains(caseId)) {
        add(
          id: 'unprovenAndroidProofClaim',
          severity: RefreshedPacketHardeningValidationSeverity.critical,
          message: 'validation cited unproven Android proof',
          caseId: caseId,
        );
      }
      if (_phase32ECaseIds.contains(caseId)) {
        add(
          id: 'phase32ECaseClaimedCapturedProof',
          severity: RefreshedPacketHardeningValidationSeverity.critical,
          message: 'Phase 32E case cannot be captured Android proof',
          caseId: caseId,
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
        id: 'validationBoundaryPolicyViolation',
        severity: RefreshedPacketHardeningValidationSeverity.critical,
        message: 'validation crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<RefreshedPacketHardeningValidationFinding> validateReportText(
    String reportText,
  ) {
    final findings = <RefreshedPacketHardeningValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        RefreshedPacketHardeningValidationFinding(
          id: id,
          severity: RefreshedPacketHardeningValidationSeverity.critical,
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

List<RefreshedPacketHardeningTargetValidationSummary> _targetSummariesFrom(
  RefreshedInternalPacketHardeningPlanResult refreshResult,
) {
  final summaries = refreshResult.targets.map((target) {
    final status = _targetStatusFor(target);
    return RefreshedPacketHardeningTargetValidationSummary(
      targetId: target.targetId,
      scopeId: target.scopeId,
      targetKind: target.targetKind,
      refreshedAction: target.refreshedAction,
      validationStatus: status,
      supportCaseIds: _sortedStrings(target.supportCaseIds),
      improvedByCaseIds: _sortedStrings(target.improvedByCaseIds),
      androidProofCaseIds: _sortedStrings(target.androidProofCaseIds),
      stillWarningLimited: target.stillWarningLimited,
      stillBlocked: target.stillBlocked,
      ownerProofRequired: target.ownerProofRequired,
      failureReason:
          status == RefreshedPacketHardeningValidationCheckStatus.passed
          ? ''
          : status ==
                RefreshedPacketHardeningValidationCheckStatus.passedWithWarnings
          ? 'warning boundary remains visible'
          : 'target failed refreshed hardening validation',
    );
  }).toList();
  summaries.sort((a, b) => a.scopeId.index.compareTo(b.scopeId.index));
  return List<RefreshedPacketHardeningTargetValidationSummary>.unmodifiable(
    summaries,
  );
}

RefreshedPacketHardeningValidationCheckStatus _targetStatusFor(
  RefreshedInternalPacketHardeningTarget target,
) {
  if (target.hasUnsafeOutput ||
      target.refreshedAction ==
          RefreshedInternalPacketHardeningActionType.blockUnsafeScope ||
      target.refreshedAction ==
          RefreshedInternalPacketHardeningActionType.investigateUnsafeImpact) {
    return RefreshedPacketHardeningValidationCheckStatus.blocked;
  }
  if (target.stillWarningLimited ||
      target.refreshedAction ==
          RefreshedInternalPacketHardeningActionType
              .downgradeCoverageNeedToWatch) {
    return RefreshedPacketHardeningValidationCheckStatus.passedWithWarnings;
  }
  return RefreshedPacketHardeningValidationCheckStatus.passed;
}

List<RefreshedPacketHardeningValidationCheck> _checksFor({
  required RefreshedInternalPacketHardeningPlanResult refreshResult,
  required TargetedGoldenCoverageImpactReviewResult impactResult,
  required InternalPacketEvidenceHardeningPlanResult hardeningResult,
  required List<RefreshedPacketHardeningTargetValidationSummary>
  targetSummaries,
}) {
  final targetsByScope =
      <
        InternalNonLabelPrototypeScopeId,
        RefreshedPacketHardeningTargetValidationSummary
      >{for (final target in targetSummaries) target.scopeId: target};
  final impactByScope =
      <
        InternalNonLabelPrototypeScopeId,
        TargetedGoldenCoverageHardeningTargetImpactRow
      >{for (final row in impactResult.hardeningTargetRows) row.scopeId: row};
  final checks = <RefreshedPacketHardeningValidationCheck>[
    _check(
      checkId: RefreshedPacketHardeningValidationCheckId
          .refreshedPlanConsumesImpactReview,
      condition:
          refreshResult.sourceImpactStatus == impactResult.impactStatus &&
          refreshResult.sourceHardeningStatus ==
              hardeningResult.hardeningStatus &&
          _sameStrings(
            refreshResult.newSupportCaseIds,
            impactResult.newSupportCaseIds,
          ),
      relatedTargetIds: _targetIds(targetSummaries),
      relatedCaseIds: refreshResult.newSupportCaseIds,
      recommendation:
          RefreshedPacketHardeningValidationRecommendation.keepRefreshedPlan,
      failureReason: 'refreshed plan does not match the impact review input',
    ),
    _improvedSupportCheck(targetSummaries, impactByScope),
    _preservedTargetsCheck(targetsByScope),
    _warningLimitedCheck(targetsByScope),
    _pvWatchCheck(targetsByScope),
    _androidProofTargetCheck(targetsByScope, refreshResult.androidProofCaseIds),
    _noPhase32EProofCheck(refreshResult, targetSummaries),
    _ownerProofCheck(refreshResult, targetSummaries),
    _quietScopeCheck(targetsByScope),
    _productLabelScopeCheck(refreshResult, targetsByScope),
    _officialMetricScopeCheck(refreshResult, targetsByScope),
    _futureOnlyScopeCheck(refreshResult, targetsByScope),
    _integrationScopeCheck(refreshResult, targetsByScope),
    _noOutputBoundaryCheck(refreshResult),
    _noEngineOrAndroidRequirementCheck(refreshResult, targetSummaries),
  ];
  checks.sort((a, b) => a.checkId.index.compareTo(b.checkId.index));
  return List<RefreshedPacketHardeningValidationCheck>.unmodifiable(checks);
}

RefreshedPacketHardeningValidationCheck _improvedSupportCheck(
  List<RefreshedPacketHardeningTargetValidationSummary> targetSummaries,
  Map<
    InternalNonLabelPrototypeScopeId,
    TargetedGoldenCoverageHardeningTargetImpactRow
  >
  impactByScope,
) {
  final improvedTargets = targetSummaries
      .where((target) => target.isImproved)
      .toList(growable: false);
  final invalidTargets = improvedTargets.where((target) {
    final impact = impactByScope[target.scopeId];
    return target.improvedByCaseIds.isEmpty ||
        target.improvedByCaseIds.any(
          (caseId) => !_phase32ECaseIds.contains(caseId),
        ) ||
        impact == null ||
        !impact.improved;
  }).toList();
  return _check(
    checkId: RefreshedPacketHardeningValidationCheckId
        .improvedTargetsHaveNewSupportCases,
    condition: invalidTargets.isEmpty,
    relatedTargetIds: _targetIds(improvedTargets),
    relatedCaseIds: improvedTargets.expand(
      (target) => target.improvedByCaseIds,
    ),
    recommendation:
        RefreshedPacketHardeningValidationRecommendation.keepRefreshedPlan,
    failureReason: 'improved target is missing Phase 32E/32F support',
    severityWhenFailed: RefreshedPacketHardeningValidationSeverity.blocker,
  );
}

RefreshedPacketHardeningValidationCheck _preservedTargetsCheck(
  Map<
    InternalNonLabelPrototypeScopeId,
    RefreshedPacketHardeningTargetValidationSummary
  >
  targetsByScope,
) {
  final targets = _stablePreservedScopes
      .map((scope) => targetsByScope[scope])
      .whereType<RefreshedPacketHardeningTargetValidationSummary>()
      .toList();
  final valid =
      targets.length == _stablePreservedScopes.length &&
      targets.every(
        (target) =>
            target.refreshedAction ==
                RefreshedInternalPacketHardeningActionType
                    .preserveStablePacket &&
            target.supportCaseIds.isNotEmpty &&
            !target.stillBlocked &&
            !target.stillWarningLimited,
      );
  return _check(
    checkId:
        RefreshedPacketHardeningValidationCheckId.preservedTargetsRemainStable,
    condition: valid,
    relatedTargetIds: _targetIds(targets),
    recommendation:
        RefreshedPacketHardeningValidationRecommendation.keepRefreshedPlan,
    failureReason: 'preserved target is no longer stable',
  );
}

RefreshedPacketHardeningValidationCheck _warningLimitedCheck(
  Map<
    InternalNonLabelPrototypeScopeId,
    RefreshedPacketHardeningTargetValidationSummary
  >
  targetsByScope,
) {
  final targets = _warningScopes
      .map((scope) => targetsByScope[scope])
      .whereType<RefreshedPacketHardeningTargetValidationSummary>()
      .toList();
  final valid =
      targets.length == _warningScopes.length &&
      targets.every(
        (target) =>
            target.targetKind ==
                InternalPacketEvidenceHardeningTargetKind.warningScope &&
            target.stillWarningLimited &&
            target.refreshedAction ==
                RefreshedInternalPacketHardeningActionType
                    .keepWarningLimitedButImproved &&
            target.improvedByCaseIds.isNotEmpty,
      );
  return _check(
    checkId: RefreshedPacketHardeningValidationCheckId
        .warningLimitedTargetsRemainWarningLimited,
    condition: valid,
    passedStatus:
        RefreshedPacketHardeningValidationCheckStatus.passedWithWarnings,
    severityWhenPassed: RefreshedPacketHardeningValidationSeverity.warning,
    relatedTargetIds: _targetIds(targets),
    relatedCaseIds: targets.expand((target) => target.improvedByCaseIds),
    warningReason: 'warning-limited targets remain outside core packets',
    recommendation:
        RefreshedPacketHardeningValidationRecommendation.keepWarningsVisible,
    failureReason: 'warning-limited target was promoted or lost support',
  );
}

RefreshedPacketHardeningValidationCheck _pvWatchCheck(
  Map<
    InternalNonLabelPrototypeScopeId,
    RefreshedPacketHardeningTargetValidationSummary
  >
  targetsByScope,
) {
  final target =
      targetsByScope[InternalNonLabelPrototypeScopeId
          .pvMultiPvSupportInternalPrototypeScope];
  final valid =
      target != null &&
      target.refreshedAction ==
          RefreshedInternalPacketHardeningActionType
              .downgradeCoverageNeedToWatch &&
      target.improvedByCaseIds.contains('pv-multipv-support-boundary-32e') &&
      !target.ownerProofRequired &&
      !target.stillBlocked;
  return _check(
    checkId: RefreshedPacketHardeningValidationCheckId
        .pvMultiPvWatchListIsBoundaryOnly,
    condition: valid,
    passedStatus:
        RefreshedPacketHardeningValidationCheckStatus.passedWithWarnings,
    severityWhenPassed: RefreshedPacketHardeningValidationSeverity.warning,
    relatedTargetIds: target == null
        ? const <String>[]
        : <String>[target.targetId],
    relatedCaseIds: const <String>['pv-multipv-support-boundary-32e'],
    relatedAndroidProofIds: target?.androidProofCaseIds ?? const <String>[],
    warningReason: 'PV/MultiPV support remains boundary-only and watch-listed',
    recommendation:
        RefreshedPacketHardeningValidationRecommendation.keepWarningsVisible,
    failureReason: 'PV/MultiPV target was not kept boundary-only',
  );
}

RefreshedPacketHardeningValidationCheck _androidProofTargetCheck(
  Map<
    InternalNonLabelPrototypeScopeId,
    RefreshedPacketHardeningTargetValidationSummary
  >
  targetsByScope,
  List<String> androidProofCaseIds,
) {
  final target =
      targetsByScope[InternalNonLabelPrototypeScopeId
          .androidProofConfidenceInternalPrototypeScope];
  final valid =
      target != null &&
      target.targetKind ==
          InternalPacketEvidenceHardeningTargetKind.androidProofScope &&
      target.refreshedAction ==
          RefreshedInternalPacketHardeningActionType.keepProofLimited &&
      _sameStrings(target.androidProofCaseIds, _capturedAndroidProofIds) &&
      _sameStrings(androidProofCaseIds, _capturedAndroidProofIds);
  return _check(
    checkId: RefreshedPacketHardeningValidationCheckId
        .androidProofTargetRemainsProofLimited,
    condition: valid,
    relatedTargetIds: target == null
        ? const <String>[]
        : <String>[target.targetId],
    relatedAndroidProofIds: androidProofCaseIds,
    recommendation:
        RefreshedPacketHardeningValidationRecommendation.keepProofLimited,
    failureReason: 'Android proof target is not proof-limited to captured IDs',
    severityWhenFailed: RefreshedPacketHardeningValidationSeverity.critical,
  );
}

RefreshedPacketHardeningValidationCheck _noPhase32EProofCheck(
  RefreshedInternalPacketHardeningPlanResult refreshResult,
  List<RefreshedPacketHardeningTargetValidationSummary> targetSummaries,
) {
  final invalidProofIds = <String>[
    ...refreshResult.androidProofCaseIds.where(_phase32ECaseIds.contains),
    ...targetSummaries.expand(
      (target) => target.androidProofCaseIds.where(_phase32ECaseIds.contains),
    ),
  ];
  return _check(
    checkId: RefreshedPacketHardeningValidationCheckId
        .noPhase32ECaseClaimsCapturedProof,
    condition: invalidProofIds.isEmpty,
    relatedCaseIds: _phase32ECaseIds,
    relatedAndroidProofIds: refreshResult.androidProofCaseIds,
    recommendation:
        RefreshedPacketHardeningValidationRecommendation.keepProofLimited,
    failureReason: 'Phase 32E case was treated as captured Android proof',
    severityWhenFailed: RefreshedPacketHardeningValidationSeverity.critical,
  );
}

RefreshedPacketHardeningValidationCheck _ownerProofCheck(
  RefreshedInternalPacketHardeningPlanResult refreshResult,
  List<RefreshedPacketHardeningTargetValidationSummary> targetSummaries,
) {
  final requiredTargets = targetSummaries
      .where((target) => target.ownerProofRequired)
      .toList(growable: false);
  final valid =
      refreshResult.ownerProofQueueCount == 0 && requiredTargets.isEmpty;
  return _check(
    checkId:
        RefreshedPacketHardeningValidationCheckId.ownerProofQueueRemainsEmpty,
    condition: valid,
    relatedTargetIds: _targetIds(requiredTargets),
    recommendation:
        RefreshedPacketHardeningValidationRecommendation.keepRefreshedPlan,
    failureReason: 'owner proof queue is not empty',
    severityWhenFailed: RefreshedPacketHardeningValidationSeverity.blocker,
  );
}

RefreshedPacketHardeningValidationCheck _quietScopeCheck(
  Map<
    InternalNonLabelPrototypeScopeId,
    RefreshedPacketHardeningTargetValidationSummary
  >
  targetsByScope,
) {
  final target =
      targetsByScope[InternalNonLabelPrototypeScopeId
          .quietPreparatoryPrototypeScope];
  final valid =
      target != null &&
      target.stillBlocked &&
      target.refreshedAction ==
          RefreshedInternalPacketHardeningActionType
              .keepExcludedByNegativeGuard;
  return _check(
    checkId:
        RefreshedPacketHardeningValidationCheckId.quietScopeRemainsExcluded,
    condition: valid,
    relatedTargetIds: target == null
        ? const <String>[]
        : <String>[target.targetId],
    recommendation:
        RefreshedPacketHardeningValidationRecommendation.keepBlockedByPolicy,
    failureReason: 'quiet/preparatory scope is not excluded',
    severityWhenFailed: RefreshedPacketHardeningValidationSeverity.critical,
  );
}

RefreshedPacketHardeningValidationCheck _productLabelScopeCheck(
  RefreshedInternalPacketHardeningPlanResult refreshResult,
  Map<
    InternalNonLabelPrototypeScopeId,
    RefreshedPacketHardeningTargetValidationSummary
  >
  targetsByScope,
) {
  final targets = <RefreshedPacketHardeningTargetValidationSummary?>[
    targetsByScope[InternalNonLabelPrototypeScopeId.productLabelPrototypeScope],
    targetsByScope[InternalNonLabelPrototypeScopeId
        .advancedLabelPrototypeScope],
  ].whereType<RefreshedPacketHardeningTargetValidationSummary>().toList();
  final valid =
      targets.length == 2 &&
      targets.every(
        (target) =>
            target.stillBlocked &&
            target.refreshedAction ==
                RefreshedInternalPacketHardeningActionType.keepBlockedByPolicy,
      ) &&
      !refreshResult.productLabelsEmitted &&
      !refreshResult.advancedLabelsEmitted &&
      !refreshResult.classifierLabelsEmitted &&
      !refreshResult.finalMoveLabelsEmitted;
  return _check(
    checkId:
        RefreshedPacketHardeningValidationCheckId.productLabelsRemainBlocked,
    condition: valid,
    relatedTargetIds: _targetIds(targets),
    recommendation:
        RefreshedPacketHardeningValidationRecommendation.keepBlockedByPolicy,
    failureReason: 'product or advanced label scope became active',
    severityWhenFailed: RefreshedPacketHardeningValidationSeverity.critical,
  );
}

RefreshedPacketHardeningValidationCheck _officialMetricScopeCheck(
  RefreshedInternalPacketHardeningPlanResult refreshResult,
  Map<
    InternalNonLabelPrototypeScopeId,
    RefreshedPacketHardeningTargetValidationSummary
  >
  targetsByScope,
) {
  final target =
      targetsByScope[InternalNonLabelPrototypeScopeId
          .officialMetricPrototypeScope];
  final valid =
      target != null &&
      target.stillBlocked &&
      target.refreshedAction ==
          RefreshedInternalPacketHardeningActionType.keepBlockedByPolicy &&
      !refreshResult.officialMetricsAllowed;
  return _check(
    checkId:
        RefreshedPacketHardeningValidationCheckId.officialMetricsRemainBlocked,
    condition: valid,
    relatedTargetIds: target == null
        ? const <String>[]
        : <String>[target.targetId],
    recommendation:
        RefreshedPacketHardeningValidationRecommendation.keepBlockedByPolicy,
    failureReason: 'official metric scope became active',
    severityWhenFailed: RefreshedPacketHardeningValidationSeverity.critical,
  );
}

RefreshedPacketHardeningValidationCheck _futureOnlyScopeCheck(
  RefreshedInternalPacketHardeningPlanResult refreshResult,
  Map<
    InternalNonLabelPrototypeScopeId,
    RefreshedPacketHardeningTargetValidationSummary
  >
  targetsByScope,
) {
  final targets = _futureOnlyScopes
      .map((scope) => targetsByScope[scope])
      .whereType<RefreshedPacketHardeningTargetValidationSummary>()
      .toList();
  final valid =
      targets.length == _futureOnlyScopes.length &&
      targets.every(
        (target) =>
            target.stillBlocked &&
            target.refreshedAction ==
                RefreshedInternalPacketHardeningActionType.keepFutureOnly,
      ) &&
      !refreshResult.cpLossComputationImplemented &&
      !refreshResult.winProbabilityComputationImplemented;
  return _check(
    checkId: RefreshedPacketHardeningValidationCheckId
        .futureOnlyInputsRemainFutureOnly,
    condition: valid,
    relatedTargetIds: _targetIds(targets),
    recommendation:
        RefreshedPacketHardeningValidationRecommendation.keepFutureOnly,
    failureReason: 'future-only inputs became active',
    severityWhenFailed: RefreshedPacketHardeningValidationSeverity.critical,
  );
}

RefreshedPacketHardeningValidationCheck _integrationScopeCheck(
  RefreshedInternalPacketHardeningPlanResult refreshResult,
  Map<
    InternalNonLabelPrototypeScopeId,
    RefreshedPacketHardeningTargetValidationSummary
  >
  targetsByScope,
) {
  final targets = _integrationScopes
      .map((scope) => targetsByScope[scope])
      .whereType<RefreshedPacketHardeningTargetValidationSummary>()
      .toList();
  final valid =
      targets.length == _integrationScopes.length &&
      targets.every(
        (target) =>
            target.stillBlocked &&
            target.refreshedAction ==
                RefreshedInternalPacketHardeningActionType.keepBlockedByPolicy,
      ) &&
      !refreshResult.uiOutputUsed &&
      !refreshResult.backendOutputUsed &&
      !refreshResult.persistenceUsed &&
      !refreshResult.directEngineAccessUsed;
  return _check(
    checkId: RefreshedPacketHardeningValidationCheckId
        .integrationScopesRemainBlocked,
    condition: valid,
    relatedTargetIds: _targetIds(targets),
    recommendation:
        RefreshedPacketHardeningValidationRecommendation.keepBlockedByPolicy,
    failureReason: 'integration scope became active',
    severityWhenFailed: RefreshedPacketHardeningValidationSeverity.critical,
  );
}

RefreshedPacketHardeningValidationCheck _noOutputBoundaryCheck(
  RefreshedInternalPacketHardeningPlanResult refreshResult,
) {
  final valid =
      !refreshResult.productLabelsEmitted &&
      !refreshResult.advancedLabelsEmitted &&
      !refreshResult.classifierLabelsEmitted &&
      !refreshResult.finalMoveLabelsEmitted &&
      !refreshResult.officialMetricsAllowed &&
      !refreshResult.cpLossComputationImplemented &&
      !refreshResult.winProbabilityComputationImplemented &&
      !refreshResult.numericMoveValuesComputed &&
      !refreshResult.moveOrderingComputed &&
      !refreshResult.emittedOutputFamilies.any(_isForbiddenOutputName);
  return _check(
    checkId:
        RefreshedPacketHardeningValidationCheckId.noLabelsScoresRankingsMetrics,
    condition: valid,
    recommendation:
        RefreshedPacketHardeningValidationRecommendation.keepBlockedByPolicy,
    failureReason: 'labels, values, ordering, or metrics became active',
    severityWhenFailed: RefreshedPacketHardeningValidationSeverity.critical,
  );
}

RefreshedPacketHardeningValidationCheck _noEngineOrAndroidRequirementCheck(
  RefreshedInternalPacketHardeningPlanResult refreshResult,
  List<RefreshedPacketHardeningTargetValidationSummary> targetSummaries,
) {
  final valid =
      !refreshResult.directEngineAccessUsed &&
      refreshResult.ownerProofQueueCount == 0 &&
      targetSummaries.every((target) => !target.ownerProofRequired);
  return _check(
    checkId:
        RefreshedPacketHardeningValidationCheckId.noEngineOrAndroidRequirement,
    condition: valid,
    recommendation: RefreshedPacketHardeningValidationRecommendation
        .proceedToEvidenceRefresh,
    failureReason: 'validation introduced engine or Android requirement',
    severityWhenFailed: RefreshedPacketHardeningValidationSeverity.blocker,
  );
}

RefreshedPacketHardeningValidationCheck _check({
  required RefreshedPacketHardeningValidationCheckId checkId,
  required bool condition,
  RefreshedPacketHardeningValidationCheckStatus passedStatus =
      RefreshedPacketHardeningValidationCheckStatus.passed,
  RefreshedPacketHardeningValidationSeverity severityWhenPassed =
      RefreshedPacketHardeningValidationSeverity.none,
  RefreshedPacketHardeningValidationSeverity severityWhenFailed =
      RefreshedPacketHardeningValidationSeverity.blocker,
  Iterable<String> relatedTargetIds = const <String>[],
  Iterable<String> relatedCaseIds = const <String>[],
  Iterable<String> relatedAndroidProofIds = const <String>[],
  String warningReason = '',
  required String failureReason,
  required RefreshedPacketHardeningValidationRecommendation recommendation,
}) {
  return RefreshedPacketHardeningValidationCheck(
    checkId: checkId,
    status: condition
        ? passedStatus
        : severityWhenFailed ==
              RefreshedPacketHardeningValidationSeverity.critical
        ? RefreshedPacketHardeningValidationCheckStatus.blocked
        : RefreshedPacketHardeningValidationCheckStatus.failed,
    severity: condition ? severityWhenPassed : severityWhenFailed,
    relatedTargetIds: _sortedStrings(relatedTargetIds),
    relatedCaseIds: _sortedStrings(relatedCaseIds),
    relatedAndroidProofIds: _sortedStrings(relatedAndroidProofIds),
    warningReason: condition ? warningReason : '',
    failureReason: condition ? '' : failureReason,
    recommendation: condition
        ? recommendation
        : RefreshedPacketHardeningValidationRecommendation
              .investigateValidationFailure,
  );
}

RefreshedPacketHardeningValidationResult _resultFromChecks({
  required RefreshedInternalPacketHardeningPlanResult refreshResult,
  required TargetedGoldenCoverageImpactReviewResult impactResult,
  required InternalPacketEvidenceHardeningPlanResult hardeningResult,
  required List<RefreshedPacketHardeningValidationCheck> checks,
  required List<RefreshedPacketHardeningTargetValidationSummary>
  targetSummaries,
  required List<RefreshedPacketHardeningValidationFinding> validationFindings,
}) {
  final blockerCount =
      checks
          .where(
            (check) =>
                check.severity ==
                RefreshedPacketHardeningValidationSeverity.blocker,
          )
          .length +
      validationFindings
          .where(
            (finding) =>
                finding.severity ==
                RefreshedPacketHardeningValidationSeverity.blocker,
          )
          .length;
  final criticalCount =
      checks
          .where(
            (check) =>
                check.severity ==
                RefreshedPacketHardeningValidationSeverity.critical,
          )
          .length +
      validationFindings.where((finding) => finding.isCritical).length;
  final unsafeCount =
      refreshResult.unsafeCount +
      targetSummaries.where((target) => target.isUnsafe).length;
  final base = RefreshedPacketHardeningValidationResult(
    validationStatus: RefreshedPacketHardeningValidationStatus.invalid,
    sourceRefreshStatus: refreshResult.refreshedStatus,
    sourceImpactStatus: impactResult.impactStatus,
    sourceHardeningStatus: hardeningResult.hardeningStatus,
    checks: checks,
    targetSummaries: targetSummaries,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...refreshResult.warnings,
      if (checks.any(
        (check) =>
            check.status ==
            RefreshedPacketHardeningValidationCheckStatus.passedWithWarnings,
      ))
        'refreshed validation keeps warning-limited targets visible',
    ]),
    failures: _sortedStrings(<String>[
      ...refreshResult.failures,
      ...checks
          .where((check) => check.failureReason.isNotEmpty)
          .map((check) => check.failureReason),
      ...validationFindings.map((finding) => finding.message),
    ]),
    totalChecks: checks.length,
    passedCount: checks
        .where(
          (check) =>
              check.status ==
                  RefreshedPacketHardeningValidationCheckStatus.passed ||
              check.status ==
                  RefreshedPacketHardeningValidationCheckStatus
                      .passedWithWarnings,
        )
        .length,
    warningCount: checks
        .where(
          (check) =>
              check.severity ==
              RefreshedPacketHardeningValidationSeverity.warning,
        )
        .length,
    blockerCount: blockerCount,
    criticalCount: criticalCount,
    validatedTargetCount: targetSummaries.length,
    warningLimitedTargetCount: targetSummaries
        .where((target) => target.stillWarningLimited)
        .length,
    blockedScopeCount: targetSummaries
        .where(
          (target) =>
              target.targetKind ==
              InternalPacketEvidenceHardeningTargetKind.blockedScope,
        )
        .length,
    futureOnlyScopeCount: targetSummaries
        .where(
          (target) =>
              target.targetKind ==
              InternalPacketEvidenceHardeningTargetKind.futureOnlyScope,
        )
        .length,
    ownerProofQueueCount: targetSummaries
        .where((target) => target.ownerProofRequired)
        .length,
    unsafeCount: unsafeCount,
    androidProofCaseIds: _sortedStrings(refreshResult.androidProofCaseIds),
    phase32ECaseIds: _sortedStrings(refreshResult.newSupportCaseIds),
    safeForPhase32I:
        refreshResult.safeForPhase32H &&
        impactResult.safeForPhase32G &&
        hardeningResult.safeForPhase32E &&
        blockerCount == 0 &&
        criticalCount == 0 &&
        unsafeCount == 0 &&
        !validationFindings.any((finding) => finding.blocksStrict) &&
        !refreshResult.hasUnsafeRefreshPolicyViolation &&
        !impactResult.hasUnsafeImpactPolicyViolation &&
        !hardeningResult.hasUnsafeHardeningPolicyViolation,
    phase32IRecommendation: RefreshedPacketHardeningPhase32IRecommendation
        .addMoreGoldenCoverageFirst,
    productLabelsEmitted: refreshResult.productLabelsEmitted,
    advancedLabelsEmitted: refreshResult.advancedLabelsEmitted,
    classifierLabelsEmitted: refreshResult.classifierLabelsEmitted,
    finalMoveLabelsEmitted: refreshResult.finalMoveLabelsEmitted,
    officialMetricsAllowed: refreshResult.officialMetricsAllowed,
    cpLossComputationImplemented: refreshResult.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        refreshResult.winProbabilityComputationImplemented,
    numericMoveValuesComputed: refreshResult.numericMoveValuesComputed,
    moveOrderingComputed: refreshResult.moveOrderingComputed,
    quietPreparatoryScopeActivated:
        refreshResult.quietPreparatoryScopeActivated,
    directEngineAccessUsed: refreshResult.directEngineAccessUsed,
    uiOutputUsed: refreshResult.uiOutputUsed,
    backendOutputUsed: refreshResult.backendOutputUsed,
    persistenceUsed: refreshResult.persistenceUsed,
    emittedOutputFamilies: refreshResult.emittedOutputFamilies,
  );
  final validationStatus = _validationStatusFor(base);
  return base.copyWith(
    validationStatus: validationStatus,
    phase32IRecommendation: _phase32IRecommendationFor(
      base.copyWith(validationStatus: validationStatus),
    ),
  );
}

RefreshedPacketHardeningValidationStatus _validationStatusFor(
  RefreshedPacketHardeningValidationResult result,
) {
  if (result.hasUnsafeValidationPolicyViolation ||
      result.sourceRefreshStatus ==
          RefreshedInternalPacketHardeningStatus.blockedByUnsafeImpact) {
    return RefreshedPacketHardeningValidationStatus.blockedByUnsafeRefresh;
  }
  if (_hasUnprovenAndroidProof(result)) {
    return RefreshedPacketHardeningValidationStatus
        .blockedByUnprovenAndroidProof;
  }
  if (_hasPolicyLeak(result)) {
    return RefreshedPacketHardeningValidationStatus.blockedByPolicyLeak;
  }
  if (_hasMissingImpactSupport(result)) {
    return RefreshedPacketHardeningValidationStatus
        .blockedByMissingImpactSupport;
  }
  if (result.validationFindings.any((finding) => finding.blocksStrict) ||
      result.blockerCount > 0 ||
      result.criticalCount > 0) {
    return RefreshedPacketHardeningValidationStatus.invalid;
  }
  if (result.warningCount > 0 || result.warningLimitedTargetCount > 0) {
    return RefreshedPacketHardeningValidationStatus.validatedWithWarnings;
  }
  return RefreshedPacketHardeningValidationStatus.validatedClean;
}

RefreshedPacketHardeningPhase32IRecommendation _phase32IRecommendationFor(
  RefreshedPacketHardeningValidationResult result,
) {
  if (result.hasUnsafeValidationPolicyViolation ||
      result.validationStatus ==
          RefreshedPacketHardeningValidationStatus.blockedByUnsafeRefresh ||
      result.validationStatus ==
          RefreshedPacketHardeningValidationStatus
              .blockedByMissingImpactSupport ||
      result.validationStatus ==
          RefreshedPacketHardeningValidationStatus.blockedByPolicyLeak ||
      result.validationStatus ==
          RefreshedPacketHardeningValidationStatus
              .blockedByUnprovenAndroidProof) {
    return RefreshedPacketHardeningPhase32IRecommendation
        .blockedByValidationFailure;
  }
  if (result.ownerProofQueueCount > 0) {
    return RefreshedPacketHardeningPhase32IRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (result.passedCount < result.totalChecks) {
    return RefreshedPacketHardeningPhase32IRecommendation
        .addMoreGoldenCoverageFirst;
  }
  return RefreshedPacketHardeningPhase32IRecommendation
      .proceedToInternalPacketEvidenceRefresh;
}

bool _hasUnprovenAndroidProof(RefreshedPacketHardeningValidationResult result) {
  return result.validationFindings.any(
        (finding) =>
            finding.id.contains('AndroidProof') ||
            finding.id.contains('CapturedProof'),
      ) ||
      result
          .check(
            RefreshedPacketHardeningValidationCheckId
                .noPhase32ECaseClaimsCapturedProof,
          )
          .blocksStrict ||
      result
          .check(
            RefreshedPacketHardeningValidationCheckId
                .androidProofTargetRemainsProofLimited,
          )
          .blocksStrict;
}

bool _hasPolicyLeak(RefreshedPacketHardeningValidationResult result) {
  return result.validationFindings.any(
        (finding) =>
            finding.id.contains('Policy') ||
            finding.id.contains('Scope') ||
            finding.id.contains('Boundary') ||
            finding.id.contains('quiet'),
      ) ||
      result
          .check(
            RefreshedPacketHardeningValidationCheckId
                .productLabelsRemainBlocked,
          )
          .blocksStrict ||
      result
          .check(
            RefreshedPacketHardeningValidationCheckId
                .officialMetricsRemainBlocked,
          )
          .blocksStrict ||
      result
          .check(
            RefreshedPacketHardeningValidationCheckId
                .futureOnlyInputsRemainFutureOnly,
          )
          .blocksStrict ||
      result
          .check(
            RefreshedPacketHardeningValidationCheckId
                .integrationScopesRemainBlocked,
          )
          .blocksStrict ||
      result
          .check(
            RefreshedPacketHardeningValidationCheckId
                .noLabelsScoresRankingsMetrics,
          )
          .blocksStrict ||
      result
          .check(
            RefreshedPacketHardeningValidationCheckId.quietScopeRemainsExcluded,
          )
          .blocksStrict;
}

bool _hasMissingImpactSupport(RefreshedPacketHardeningValidationResult result) {
  return result
      .check(
        RefreshedPacketHardeningValidationCheckId
            .improvedTargetsHaveNewSupportCases,
      )
      .blocksStrict;
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

List<String> _targetIds(
  Iterable<RefreshedPacketHardeningTargetValidationSummary> values,
) {
  final ids = values.map((target) => target.targetId);
  return _sortedStrings(ids);
}

String _scopeIds(
  Iterable<RefreshedPacketHardeningTargetValidationSummary> values,
) {
  final ids = values.map((target) => target.scopeId.wire);
  return _ids(ids);
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.where((value) => value.isNotEmpty).toSet().toList()..sort();
}

bool _sameStrings(Iterable<String> left, Iterable<String> right) {
  final a = _sortedStrings(left);
  final b = _sortedStrings(right);
  if (a.length != b.length) return false;
  for (var index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) return false;
  }
  return true;
}

int _compareFindings(
  RefreshedPacketHardeningValidationFinding a,
  RefreshedPacketHardeningValidationFinding b,
) {
  final severityCompare = b.severity.index.compareTo(a.severity.index);
  if (severityCompare != 0) return severityCompare;
  final idCompare = a.id.compareTo(b.id);
  if (idCompare != 0) return idCompare;
  final checkCompare = (a.checkId?.wire ?? '').compareTo(b.checkId?.wire ?? '');
  if (checkCompare != 0) return checkCompare;
  return (a.targetId ?? '').compareTo(b.targetId ?? '');
}

bool _isForbiddenOutputName(String value) {
  final normalized = value.trim().toLowerCase();
  return _forbiddenOutputNames.contains(normalized);
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

const _stablePreservedScopes = <InternalNonLabelPrototypeScopeId>{
  InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.materialSwingInternalPrototypeScope,
};

const _warningScopes = <InternalNonLabelPrototypeScopeId>{
  InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.endgameInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.suppressionSafetyInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.budgetRiskInternalPrototypeScope,
};

const _futureOnlyScopes = <InternalNonLabelPrototypeScopeId>{
  InternalNonLabelPrototypeScopeId.cpLossPrototypeScope,
  InternalNonLabelPrototypeScopeId.winProbabilityPrototypeScope,
};

const _integrationScopes = <InternalNonLabelPrototypeScopeId>{
  InternalNonLabelPrototypeScopeId.uiProductIntegrationScope,
  InternalNonLabelPrototypeScopeId.backendIntegrationScope,
  InternalNonLabelPrototypeScopeId.persistenceScope,
  InternalNonLabelPrototypeScopeId.directEngineAccessScope,
};

const _blockedOrFutureScopes = <InternalNonLabelPrototypeScopeId>{
  InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
  InternalNonLabelPrototypeScopeId.productLabelPrototypeScope,
  InternalNonLabelPrototypeScopeId.advancedLabelPrototypeScope,
  InternalNonLabelPrototypeScopeId.officialMetricPrototypeScope,
  ..._futureOnlyScopes,
  ..._integrationScopes,
};

const _improvedActions = <RefreshedInternalPacketHardeningActionType>{
  RefreshedInternalPacketHardeningActionType.preserveImprovedPacket,
  RefreshedInternalPacketHardeningActionType.downgradeCoverageNeedToWatch,
  RefreshedInternalPacketHardeningActionType.keepWarningLimitedButImproved,
};

const _activeRefreshActions = <RefreshedInternalPacketHardeningActionType>{
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

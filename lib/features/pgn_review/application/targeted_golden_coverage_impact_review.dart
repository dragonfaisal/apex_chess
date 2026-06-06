/// Developer-only review of Phase 32E targeted Golden coverage impact.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_review.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_triage.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_review_aggregation_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_stability_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/narrow_internal_non_label_analysis_prototype.dart';

const targetedGoldenCoverageImpactReviewReportVersion =
    'targeted-golden-coverage-impact-review-v1';

enum TargetedGoldenCoverageImpactStatus {
  coverageImproved('coverageImproved'),
  coverageImprovedWithWarnings('coverageImprovedWithWarnings'),
  noMeaningfulCoverageChange('noMeaningfulCoverageChange'),
  needsMoreGoldenCoverage('needsMoreGoldenCoverage'),
  blockedByEvidenceMismatch('blockedByEvidenceMismatch'),
  blockedByUnsafeCase('blockedByUnsafeCase'),
  invalid('invalid');

  const TargetedGoldenCoverageImpactStatus(this.wire);

  final String wire;

  bool get isUnsafe =>
      this == TargetedGoldenCoverageImpactStatus.blockedByUnsafeCase ||
      this == TargetedGoldenCoverageImpactStatus.invalid;
}

enum TargetedGoldenCoverageImpactRecommendation {
  preserveCoverageImpact('preserveCoverageImpact'),
  refreshHardeningTarget('refreshHardeningTarget'),
  keepBoundaryLimited('keepBoundaryLimited'),
  keepProofLimited('keepProofLimited'),
  keepWarningLimited('keepWarningLimited'),
  keepBlockedByPolicy('keepBlockedByPolicy'),
  keepFutureOnly('keepFutureOnly'),
  investigateUnsafeCoverage('investigateUnsafeCoverage');

  const TargetedGoldenCoverageImpactRecommendation(this.wire);

  final String wire;
}

enum TargetedGoldenCoveragePhase32GRecommendation {
  refreshInternalPacketHardeningPlanFromCoverageImpact(
    'refreshInternalPacketHardeningPlanFromCoverageImpact',
  ),
  proceedToInternalPacketEvidenceRefresh(
    'proceedToInternalPacketEvidenceRefresh',
  ),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeCoverage('blockedByUnsafeCoverage');

  const TargetedGoldenCoveragePhase32GRecommendation(this.wire);

  final String wire;
}

enum TargetedGoldenCoverageImpactValidationSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const TargetedGoldenCoverageImpactValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == TargetedGoldenCoverageImpactValidationSeverity.blocker ||
      this == TargetedGoldenCoverageImpactValidationSeverity.critical;
}

enum TargetedGoldenCoverageImpactReviewReportFormat {
  markdown('markdown'),
  json('json');

  const TargetedGoldenCoverageImpactReviewReportFormat(this.wire);

  final String wire;
}

class TargetedGoldenCoverageImpactReviewRequest {
  const TargetedGoldenCoverageImpactReviewRequest({
    this.cases = GoldenAnalysisCases.defaults,
    this.evidenceReviewResult,
    this.triageResult,
    this.hardeningPlanResult,
    this.previousHardeningPlanResult,
    this.stabilityResult,
    this.matrixResult,
    this.prototypeResult,
    this.evidenceReviewRunner = const GoldenEvidenceReviewRunner(),
    this.triageRunner = const GoldenEvidenceTriageRunner(),
    this.hardeningPlan = const InternalPacketEvidenceHardeningPlan(),
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const TargetedGoldenCoverageImpactReviewRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final List<GoldenAnalysisCase> cases;
  final GoldenEvidenceReviewResult? evidenceReviewResult;
  final GoldenEvidenceTriageResult? triageResult;
  final InternalPacketEvidenceHardeningPlanResult? hardeningPlanResult;
  final InternalPacketEvidenceHardeningPlanResult? previousHardeningPlanResult;
  final InternalPacketStabilityPrototypeResult? stabilityResult;
  final InternalPacketReviewAggregationMatrixResult? matrixResult;
  final NarrowInternalNonLabelAnalysisPrototypeResult? prototypeResult;
  final GoldenEvidenceReviewRunner evidenceReviewRunner;
  final GoldenEvidenceTriageRunner triageRunner;
  final InternalPacketEvidenceHardeningPlan hardeningPlan;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class TargetedGoldenCoverageCaseImpactRow {
  const TargetedGoldenCoverageCaseImpactRow({
    required this.caseId,
    required this.targetArea,
    required this.motifs,
    required this.protectionStatus,
    required this.affectedHardeningTargets,
    required this.affectedPacketScopes,
    required this.supportContribution,
    required this.androidProofClaimed,
    required this.ownerProofRequired,
    required this.impactStatus,
    required this.recommendation,
  });

  final String caseId;
  final String targetArea;
  final List<String> motifs;
  final GoldenEvidenceReviewStatus protectionStatus;
  final List<String> affectedHardeningTargets;
  final List<InternalNonLabelPrototypeScopeId> affectedPacketScopes;
  final String supportContribution;
  final bool androidProofClaimed;
  final bool ownerProofRequired;
  final TargetedGoldenCoverageImpactStatus impactStatus;
  final TargetedGoldenCoverageImpactRecommendation recommendation;

  bool get isUnsafe => impactStatus.isUnsafe || androidProofClaimed;

  TargetedGoldenCoverageCaseImpactRow copyWith({
    String? caseId,
    String? targetArea,
    List<String>? motifs,
    GoldenEvidenceReviewStatus? protectionStatus,
    List<String>? affectedHardeningTargets,
    List<InternalNonLabelPrototypeScopeId>? affectedPacketScopes,
    String? supportContribution,
    bool? androidProofClaimed,
    bool? ownerProofRequired,
    TargetedGoldenCoverageImpactStatus? impactStatus,
    TargetedGoldenCoverageImpactRecommendation? recommendation,
  }) {
    return TargetedGoldenCoverageCaseImpactRow(
      caseId: caseId ?? this.caseId,
      targetArea: targetArea ?? this.targetArea,
      motifs: motifs ?? this.motifs,
      protectionStatus: protectionStatus ?? this.protectionStatus,
      affectedHardeningTargets:
          affectedHardeningTargets ?? this.affectedHardeningTargets,
      affectedPacketScopes: affectedPacketScopes ?? this.affectedPacketScopes,
      supportContribution: supportContribution ?? this.supportContribution,
      androidProofClaimed: androidProofClaimed ?? this.androidProofClaimed,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      impactStatus: impactStatus ?? this.impactStatus,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'caseId': caseId,
      'targetArea': targetArea,
      'motifs': motifs,
      'protectionStatus': protectionStatus.wire,
      'affectedHardeningTargets': affectedHardeningTargets,
      'affectedPacketScopes': affectedPacketScopes
          .map((scope) => scope.wire)
          .toList(),
      'supportContribution': supportContribution,
      'androidProofClaimed': androidProofClaimed,
      'ownerProofRequired': ownerProofRequired,
      'impactStatus': impactStatus.wire,
      'recommendation': recommendation.wire,
    };
  }
}

class TargetedGoldenCoverageHardeningTargetImpactRow {
  const TargetedGoldenCoverageHardeningTargetImpactRow({
    required this.targetId,
    required this.scopeId,
    required this.previousActionFrom32D,
    required this.currentActionAfter32E,
    required this.supportCaseIds,
    required this.newSupportCaseIds,
    required this.improved,
    required this.stillWarningLimited,
    required this.stillBlocked,
    required this.recommendation,
  });

  final String targetId;
  final InternalNonLabelPrototypeScopeId scopeId;
  final String previousActionFrom32D;
  final String currentActionAfter32E;
  final List<String> supportCaseIds;
  final List<String> newSupportCaseIds;
  final bool improved;
  final bool stillWarningLimited;
  final bool stillBlocked;
  final TargetedGoldenCoverageImpactRecommendation recommendation;

  TargetedGoldenCoverageHardeningTargetImpactRow copyWith({
    String? targetId,
    InternalNonLabelPrototypeScopeId? scopeId,
    String? previousActionFrom32D,
    String? currentActionAfter32E,
    List<String>? supportCaseIds,
    List<String>? newSupportCaseIds,
    bool? improved,
    bool? stillWarningLimited,
    bool? stillBlocked,
    TargetedGoldenCoverageImpactRecommendation? recommendation,
  }) {
    return TargetedGoldenCoverageHardeningTargetImpactRow(
      targetId: targetId ?? this.targetId,
      scopeId: scopeId ?? this.scopeId,
      previousActionFrom32D:
          previousActionFrom32D ?? this.previousActionFrom32D,
      currentActionAfter32E:
          currentActionAfter32E ?? this.currentActionAfter32E,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newSupportCaseIds: newSupportCaseIds ?? this.newSupportCaseIds,
      improved: improved ?? this.improved,
      stillWarningLimited: stillWarningLimited ?? this.stillWarningLimited,
      stillBlocked: stillBlocked ?? this.stillBlocked,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'targetId': targetId,
      'scopeId': scopeId.wire,
      'previousActionFrom32D': previousActionFrom32D,
      'currentActionAfter32E': currentActionAfter32E,
      'supportCaseIds': supportCaseIds,
      'newSupportCaseIds': newSupportCaseIds,
      'improved': improved,
      'stillWarningLimited': stillWarningLimited,
      'stillBlocked': stillBlocked,
      'recommendation': recommendation.wire,
    };
  }
}

class TargetedGoldenCoverageImpactReviewValidationFinding {
  const TargetedGoldenCoverageImpactReviewValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.caseId,
    this.targetId,
    this.scopeId,
  });

  final String id;
  final TargetedGoldenCoverageImpactValidationSeverity severity;
  final String message;
  final String? caseId;
  final String? targetId;
  final InternalNonLabelPrototypeScopeId? scopeId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical =>
      severity == TargetedGoldenCoverageImpactValidationSeverity.critical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (caseId != null) 'caseId': caseId,
      if (targetId != null) 'targetId': targetId,
      if (scopeId != null) 'scopeId': scopeId!.wire,
    };
  }
}

class TargetedGoldenCoverageImpactReviewResult {
  const TargetedGoldenCoverageImpactReviewResult({
    required this.impactStatus,
    required this.sourceEvidenceReviewStatus,
    required this.sourceHardeningStatus,
    required this.caseImpactRows,
    required this.hardeningTargetRows,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalGoldenCases,
    required this.protectedCount,
    required this.negativeGuardCount,
    required this.newCaseCount,
    required this.improvedTargetCount,
    required this.stillWarningLimitedCount,
    required this.blockedScopeCount,
    required this.ownerProofQueueCount,
    required this.unsafeCaseCount,
    required this.androidProofCaseIds,
    required this.newSupportCaseIds,
    required this.safeForPhase32G,
    required this.phase32GRecommendation,
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

  final TargetedGoldenCoverageImpactStatus impactStatus;
  final GoldenEvidenceReviewStatus sourceEvidenceReviewStatus;
  final InternalPacketEvidenceHardeningStatus sourceHardeningStatus;
  final List<TargetedGoldenCoverageCaseImpactRow> caseImpactRows;
  final List<TargetedGoldenCoverageHardeningTargetImpactRow>
  hardeningTargetRows;
  final List<TargetedGoldenCoverageImpactReviewValidationFinding>
  validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalGoldenCases;
  final int protectedCount;
  final int negativeGuardCount;
  final int newCaseCount;
  final int improvedTargetCount;
  final int stillWarningLimitedCount;
  final int blockedScopeCount;
  final int ownerProofQueueCount;
  final int unsafeCaseCount;
  final List<String> androidProofCaseIds;
  final List<String> newSupportCaseIds;
  final bool safeForPhase32G;
  final TargetedGoldenCoveragePhase32GRecommendation phase32GRecommendation;
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
      impactStatus == TargetedGoldenCoverageImpactStatus.blockedByUnsafeCase ||
      impactStatus ==
          TargetedGoldenCoverageImpactStatus.blockedByEvidenceMismatch ||
      impactStatus == TargetedGoldenCoverageImpactStatus.invalid ||
      !safeForPhase32G ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeImpactPolicyViolation {
    return unsafeCaseCount > 0 ||
        validationFindings.any((finding) => finding.isCritical) ||
        caseImpactRows.any((row) => row.isUnsafe) ||
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

  TargetedGoldenCoverageCaseImpactRow caseImpact(String caseId) {
    return caseImpactRows.singleWhere((row) => row.caseId == caseId);
  }

  TargetedGoldenCoverageHardeningTargetImpactRow targetImpact(
    InternalNonLabelPrototypeScopeId scopeId,
  ) {
    return hardeningTargetRows.singleWhere((row) => row.scopeId == scopeId);
  }

  List<TargetedGoldenCoverageHardeningTargetImpactRow>
  get warningLimitedTargetRows => hardeningTargetRows
      .where((row) => row.stillWarningLimited)
      .toList(growable: false);

  List<TargetedGoldenCoverageHardeningTargetImpactRow> get blockedTargetRows =>
      hardeningTargetRows
          .where((row) => row.stillBlocked)
          .toList(growable: false);

  TargetedGoldenCoverageImpactReviewResult copyWith({
    TargetedGoldenCoverageImpactStatus? impactStatus,
    GoldenEvidenceReviewStatus? sourceEvidenceReviewStatus,
    InternalPacketEvidenceHardeningStatus? sourceHardeningStatus,
    List<TargetedGoldenCoverageCaseImpactRow>? caseImpactRows,
    List<TargetedGoldenCoverageHardeningTargetImpactRow>? hardeningTargetRows,
    List<TargetedGoldenCoverageImpactReviewValidationFinding>?
    validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalGoldenCases,
    int? protectedCount,
    int? negativeGuardCount,
    int? newCaseCount,
    int? improvedTargetCount,
    int? stillWarningLimitedCount,
    int? blockedScopeCount,
    int? ownerProofQueueCount,
    int? unsafeCaseCount,
    List<String>? androidProofCaseIds,
    List<String>? newSupportCaseIds,
    bool? safeForPhase32G,
    TargetedGoldenCoveragePhase32GRecommendation? phase32GRecommendation,
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
    return TargetedGoldenCoverageImpactReviewResult(
      impactStatus: impactStatus ?? this.impactStatus,
      sourceEvidenceReviewStatus:
          sourceEvidenceReviewStatus ?? this.sourceEvidenceReviewStatus,
      sourceHardeningStatus:
          sourceHardeningStatus ?? this.sourceHardeningStatus,
      caseImpactRows: caseImpactRows ?? this.caseImpactRows,
      hardeningTargetRows: hardeningTargetRows ?? this.hardeningTargetRows,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalGoldenCases: totalGoldenCases ?? this.totalGoldenCases,
      protectedCount: protectedCount ?? this.protectedCount,
      negativeGuardCount: negativeGuardCount ?? this.negativeGuardCount,
      newCaseCount: newCaseCount ?? this.newCaseCount,
      improvedTargetCount: improvedTargetCount ?? this.improvedTargetCount,
      stillWarningLimitedCount:
          stillWarningLimitedCount ?? this.stillWarningLimitedCount,
      blockedScopeCount: blockedScopeCount ?? this.blockedScopeCount,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      unsafeCaseCount: unsafeCaseCount ?? this.unsafeCaseCount,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      newSupportCaseIds: newSupportCaseIds ?? this.newSupportCaseIds,
      safeForPhase32G: safeForPhase32G ?? this.safeForPhase32G,
      phase32GRecommendation:
          phase32GRecommendation ?? this.phase32GRecommendation,
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
      ..writeln('# Targeted Golden Coverage Impact Review')
      ..writeln()
      ..writeln('- version: $targetedGoldenCoverageImpactReviewReportVersion')
      ..writeln('- impact status: ${impactStatus.wire}')
      ..writeln(
        '- source evidence review status: ${sourceEvidenceReviewStatus.wire}',
      )
      ..writeln('- source hardening status: ${sourceHardeningStatus.wire}')
      ..writeln('- total Golden cases: $totalGoldenCases')
      ..writeln('- protected count: $protectedCount')
      ..writeln('- negative guard count: $negativeGuardCount')
      ..writeln('- new Phase 32E case count: $newCaseCount')
      ..writeln('- improved target count: $improvedTargetCount')
      ..writeln('- still warning-limited count: $stillWarningLimitedCount')
      ..writeln('- blocked scope count: $blockedScopeCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- unsafe case count: $unsafeCaseCount')
      ..writeln('- safe for Phase 32G: $safeForPhase32G')
      ..writeln('- Phase 32G recommendation: ${phase32GRecommendation.wire}')
      ..writeln('- classifier output emitted: $classifierLabelsEmitted')
      ..writeln('- numeric value output emitted: $numericMoveValuesComputed')
      ..writeln('- move ordering output emitted: $moveOrderingComputed')
      ..writeln()
      ..writeln('## Impact Policy')
      ..writeln('- this review measures internal Golden coverage impact only')
      ..writeln(
        '- it does not classify moves, compute values, order moves, call an engine, integrate product output, run Android, or write files',
      )
      ..writeln()
      ..writeln('## Phase 32E New Case Impact Table')
      ..writeln(
        '| Case | Target Area | Protection | Targets | Scopes | Contribution | Android Proof | Owner Proof | Status | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in caseImpactRows) {
      buffer.writeln(
        '| ${_cell(row.caseId)} | ${_cell(row.targetArea)} | '
        '${row.protectionStatus.wire} | '
        '${_ids(row.affectedHardeningTargets)} | '
        '${_scopeIds(row.affectedPacketScopes)} | '
        '${_cell(row.supportContribution)} | '
        '${row.androidProofClaimed ? "claimed" : "not-claimed"} | '
        '${row.ownerProofRequired ? "required" : "not-required"} | '
        '${row.impactStatus.wire} | ${row.recommendation.wire} |',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Hardening Target Impact Table')
      ..writeln(
        '| Target | Scope | Previous Action | Current Action | Support Cases | New Support | Improved | Warning-Limited | Blocked | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in hardeningTargetRows) {
      buffer.writeln(
        '| ${_cell(row.targetId)} | ${row.scopeId.wire} | '
        '${row.previousActionFrom32D} | ${row.currentActionAfter32E} | '
        '${_ids(row.supportCaseIds)} | ${_ids(row.newSupportCaseIds)} | '
        '${row.improved} | ${row.stillWarningLimited} | '
        '${row.stillBlocked} | ${row.recommendation.wire} |',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Aggregate Impact Counts')
      ..writeln('- total Golden cases: $totalGoldenCases')
      ..writeln('- protected count: $protectedCount')
      ..writeln('- negative guard count: $negativeGuardCount')
      ..writeln('- new case count: $newCaseCount')
      ..writeln('- improved target count: $improvedTargetCount')
      ..writeln('- still warning-limited count: $stillWarningLimitedCount')
      ..writeln('- blocked scope count: $blockedScopeCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- unsafe case count: $unsafeCaseCount')
      ..writeln()
      ..writeln('## New Support Case IDs')
      ..writeln('- ${_ids(newSupportCaseIds)}')
      ..writeln()
      ..writeln('## Android Proof IDs')
      ..writeln('- ${_ids(androidProofCaseIds)}')
      ..writeln()
      ..writeln('## Owner Proof Queue Status')
      ..writeln(
        ownerProofQueueCount == 0
            ? '- empty'
            : '- opt-in owner proof remains queued for explicit PV/MultiPV review',
      )
      ..writeln()
      ..writeln('## Warning-Limited Scopes')
      ..writeln(
        '- ${_scopeIds(warningLimitedTargetRows.map((row) => row.scopeId))}',
      )
      ..writeln()
      ..writeln('## Blocked And Future-Only Scopes')
      ..writeln('- ${_scopeIds(blockedTargetRows.map((row) => row.scopeId))}')
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
      ..writeln('## Phase 32G Recommendation')
      ..writeln(phase32GRecommendation.wire)
      ..writeln()
      ..writeln(
        'This impact review stays internal-only. It does not emit user-facing output, compute product metrics, call the engine, run Android, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': targetedGoldenCoverageImpactReviewReportVersion,
      'impactStatus': impactStatus.wire,
      'sourceEvidenceReviewStatus': sourceEvidenceReviewStatus.wire,
      'sourceHardeningStatus': sourceHardeningStatus.wire,
      'totalGoldenCases': totalGoldenCases,
      'protectedCount': protectedCount,
      'negativeGuardCount': negativeGuardCount,
      'newCaseCount': newCaseCount,
      'improvedTargetCount': improvedTargetCount,
      'stillWarningLimitedCount': stillWarningLimitedCount,
      'blockedScopeCount': blockedScopeCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'unsafeCaseCount': unsafeCaseCount,
      'androidProofCaseIds': androidProofCaseIds,
      'newSupportCaseIds': newSupportCaseIds,
      'safeForPhase32G': safeForPhase32G,
      'phase32GRecommendation': phase32GRecommendation.wire,
      'caseImpactRows': caseImpactRows.map((row) => row.toJson()).toList(),
      'hardeningTargetRows': hardeningTargetRows
          .map((row) => row.toJson())
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

class TargetedGoldenCoverageImpactReview {
  const TargetedGoldenCoverageImpactReview({
    this.validator = const TargetedGoldenCoverageImpactReviewValidator(),
  });

  final TargetedGoldenCoverageImpactReviewValidator validator;

  TargetedGoldenCoverageImpactReviewResult evaluate([
    TargetedGoldenCoverageImpactReviewRequest request =
        const TargetedGoldenCoverageImpactReviewRequest(),
  ]) {
    final evidenceReview =
        request.evidenceReviewResult ??
        request.evidenceReviewRunner.review(
          GoldenEvidenceReviewRequest(
            cases: request.cases,
            mode: GoldenEvidenceReviewMode.realDeviceEvidenceReferenceOnly,
            requireAllEvidence: true,
            androidProofEvidence: request.androidProofEvidence,
          ),
        );
    final triage =
        request.triageResult ??
        request.triageRunner.run(
          GoldenEvidenceTriageRequest(
            cases: request.cases,
            includeProtected: true,
          ),
        );
    final currentPlan =
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
    final previousPlan =
        request.previousHardeningPlanResult ??
        request.hardeningPlan.evaluate(
          InternalPacketEvidenceHardeningPlanRequest(
            cases: _prePhase32ECases(request.cases),
            androidProofEvidence: request.androidProofEvidence,
            includeWarningLimitedScopes: request.includeWarnings,
          ),
        );
    final caseRows = _caseImpactRows(
      cases: request.cases,
      reviewResult: evidenceReview,
      triageResult: triage,
      hardeningPlanResult: currentPlan,
      androidProofEvidence: request.androidProofEvidence,
    );
    final targetRows = _targetImpactRows(
      currentPlan: currentPlan,
      previousPlan: previousPlan,
      caseRows: caseRows,
    );
    final base = _resultFromRows(
      evidenceReview: evidenceReview,
      triage: triage,
      currentPlan: currentPlan,
      caseRows: caseRows,
      targetRows: targetRows,
      validationFindings:
          const <TargetedGoldenCoverageImpactReviewValidationFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromRows(
      evidenceReview: evidenceReview,
      triage: triage,
      currentPlan: currentPlan,
      caseRows: caseRows,
      targetRows: targetRows,
      validationFindings: findings,
    );
  }
}

class TargetedGoldenCoverageImpactReviewValidator {
  const TargetedGoldenCoverageImpactReviewValidator();

  List<TargetedGoldenCoverageImpactReviewValidationFinding> validate(
    TargetedGoldenCoverageImpactReviewResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <TargetedGoldenCoverageImpactReviewValidationFinding>[];
    final caseIds = cases.map((item) => item.id).toSet();
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required TargetedGoldenCoverageImpactValidationSeverity severity,
      required String message,
      String? caseId,
      String? targetId,
      InternalNonLabelPrototypeScopeId? scopeId,
    }) {
      findings.add(
        TargetedGoldenCoverageImpactReviewValidationFinding(
          id: id,
          severity: severity,
          message: message,
          caseId: caseId,
          targetId: targetId,
          scopeId: scopeId,
        ),
      );
    }

    if (result.safeForPhase32G &&
        (result.unsafeCaseCount > 0 ||
            result.caseImpactRows.any((row) => row.isUnsafe))) {
      add(
        id: 'unsafeCaseMarkedSafe',
        severity: TargetedGoldenCoverageImpactValidationSeverity.critical,
        message: 'unsafe coverage impact cannot be marked safe',
      );
    }

    for (final row in result.caseImpactRows) {
      if (!caseIds.contains(row.caseId)) {
        add(
          id: 'unknownPhase32ECase',
          severity: TargetedGoldenCoverageImpactValidationSeverity.blocker,
          message: 'impact row references an unknown Golden case',
          caseId: row.caseId,
        );
      }
      if (_phase32ECaseIds.contains(row.caseId) &&
          row.protectionStatus != GoldenEvidenceReviewStatus.passed &&
          row.protectionStatus !=
              GoldenEvidenceReviewStatus.passedWithWarnings &&
          row.impactStatus !=
              TargetedGoldenCoverageImpactStatus.blockedByEvidenceMismatch &&
          row.impactStatus != TargetedGoldenCoverageImpactStatus.invalid) {
        add(
          id: 'unprotectedCaseTreatedAsImproved',
          severity: TargetedGoldenCoverageImpactValidationSeverity.blocker,
          message: 'new case was treated as improved without protected review',
          caseId: row.caseId,
        );
      }
      if (row.androidProofClaimed) {
        add(
          id: 'phase32ECaseClaimedAndroidProof',
          severity: TargetedGoldenCoverageImpactValidationSeverity.critical,
          message: 'Phase 32E cases cannot claim captured Android proof',
          caseId: row.caseId,
        );
      }
      if (row.ownerProofRequired && !_hasExplicitPvReason(row.targetArea)) {
        add(
          id: 'ownerProofRequiredWithoutPvReason',
          severity: TargetedGoldenCoverageImpactValidationSeverity.blocker,
          message: 'owner proof requires explicit PV/MultiPV reason',
          caseId: row.caseId,
        );
      }
    }

    for (final row in result.hardeningTargetRows) {
      if (row.scopeId ==
              InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope &&
          !row.stillBlocked) {
        add(
          id: 'quietPreparatoryScopeActivated',
          severity: TargetedGoldenCoverageImpactValidationSeverity.critical,
          message: 'quiet/preparatory scope must remain excluded',
          targetId: row.targetId,
          scopeId: row.scopeId,
        );
      }
      if (_blockedProductBoundaryScopes.contains(row.scopeId) &&
          !row.stillBlocked) {
        add(
          id: 'blockedPolicyScopeAllowed',
          severity: TargetedGoldenCoverageImpactValidationSeverity.critical,
          message: '${row.scopeId.wire} must remain blocked',
          targetId: row.targetId,
          scopeId: row.scopeId,
        );
      }
      if (row.stillBlocked &&
          row.currentActionAfter32E ==
              InternalPacketEvidenceHardeningActionType
                  .addGoldenCoverage
                  .wire) {
        add(
          id: 'blockedScopeReceivedCoverageAction',
          severity: TargetedGoldenCoverageImpactValidationSeverity.critical,
          message: '${row.scopeId.wire} received an allowed coverage action',
          targetId: row.targetId,
          scopeId: row.scopeId,
        );
      }
    }

    for (final caseId in result.androidProofCaseIds) {
      if (!_capturedAndroidProofIds.contains(caseId) ||
          !provenAndroidIds.contains(caseId)) {
        add(
          id: 'unprovenAndroidProofClaim',
          severity: TargetedGoldenCoverageImpactValidationSeverity.critical,
          message: 'impact review cited unproven Android proof',
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
        id: 'impactReviewBoundaryPolicyViolation',
        severity: TargetedGoldenCoverageImpactValidationSeverity.critical,
        message: 'impact review crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<TargetedGoldenCoverageImpactReviewValidationFinding> validateReportText(
    String reportText,
  ) {
    final findings = <TargetedGoldenCoverageImpactReviewValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        TargetedGoldenCoverageImpactReviewValidationFinding(
          id: id,
          severity: TargetedGoldenCoverageImpactValidationSeverity.critical,
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

List<TargetedGoldenCoverageCaseImpactRow> _caseImpactRows({
  required List<GoldenAnalysisCase> cases,
  required GoldenEvidenceReviewResult reviewResult,
  required GoldenEvidenceTriageResult triageResult,
  required InternalPacketEvidenceHardeningPlanResult hardeningPlanResult,
  required GoldenAndroidProofEvidence? androidProofEvidence,
}) {
  final caseById = <String, GoldenAnalysisCase>{
    for (final item in cases) item.id: item,
  };
  final reviewById = <String, GoldenEvidenceCaseReview>{
    for (final review in reviewResult.caseReviews) review.caseId: review,
  };
  final triageById = <String, GoldenEvidenceTriageEntry>{
    for (final entry in triageResult.entries) entry.caseId: entry,
  };
  final androidProofIds =
      androidProofEvidence?.targetCaseIds.toSet() ?? const <String>{};
  final rows = <TargetedGoldenCoverageCaseImpactRow>[];
  for (final id in _phase32ECaseIds) {
    final item = caseById[id];
    final review = reviewById[id];
    final triage = triageById[id];
    final blueprint = _caseBlueprintFor(id);
    final androidProofClaimed = androidProofIds.contains(id);
    final ownerProofRequired =
        (review?.realEngineEvidenceNeeded ?? false) ||
        (triage?.realDeviceProofRequired ?? false);
    final protectionStatus =
        review?.status ?? GoldenEvidenceReviewStatus.failed;
    final affectedTargets = _targetIdsForScopes(
      hardeningPlanResult,
      blueprint.scopes,
    );
    final impactStatus = _caseImpactStatusFor(
      protectionStatus: protectionStatus,
      androidProofClaimed: androidProofClaimed,
      ownerProofRequired: ownerProofRequired,
      itemPresent: item != null,
    );
    rows.add(
      TargetedGoldenCoverageCaseImpactRow(
        caseId: id,
        targetArea: blueprint.targetArea,
        motifs: _sortedStrings(
          (item?.motifTags ?? const <GoldenMotifTag>[]).map(
            (motif) => motif.wire,
          ),
        ),
        protectionStatus: protectionStatus,
        affectedHardeningTargets: affectedTargets,
        affectedPacketScopes: blueprint.scopes,
        supportContribution: blueprint.supportContribution,
        androidProofClaimed: androidProofClaimed,
        ownerProofRequired: ownerProofRequired,
        impactStatus: impactStatus,
        recommendation: _caseRecommendationFor(
          impactStatus,
          ownerProofRequired: ownerProofRequired,
        ),
      ),
    );
  }
  rows.sort((a, b) => a.caseId.compareTo(b.caseId));
  return List<TargetedGoldenCoverageCaseImpactRow>.unmodifiable(rows);
}

List<TargetedGoldenCoverageHardeningTargetImpactRow> _targetImpactRows({
  required InternalPacketEvidenceHardeningPlanResult currentPlan,
  required InternalPacketEvidenceHardeningPlanResult previousPlan,
  required List<TargetedGoldenCoverageCaseImpactRow> caseRows,
}) {
  final previousByScope =
      <InternalNonLabelPrototypeScopeId, InternalPacketEvidenceHardeningTarget>{
        for (final target in previousPlan.targets) target.scopeId: target,
      };
  final casesByScope = <InternalNonLabelPrototypeScopeId, Set<String>>{};
  for (final caseRow in caseRows) {
    for (final scope in caseRow.affectedPacketScopes) {
      casesByScope.putIfAbsent(scope, () => <String>{}).add(caseRow.caseId);
    }
  }
  final rows = <TargetedGoldenCoverageHardeningTargetImpactRow>[];
  for (final target in currentPlan.targets) {
    final previous = previousByScope[target.scopeId];
    final mappedNewCaseIds = casesByScope[target.scopeId] ?? const <String>{};
    final directNewCaseIds = target.supportCaseIds
        .where(_phase32ECaseIds.contains)
        .toSet();
    final newSupportCaseIds = _sortedStrings({
      ...mappedNewCaseIds,
      ...directNewCaseIds,
    });
    final supportCaseIds = _sortedStrings(target.supportCaseIds);
    final previousSupportCaseIds = previous == null
        ? const <String>[]
        : previous.supportCaseIds;
    final improved =
        newSupportCaseIds.isNotEmpty ||
        supportCaseIds.length > previousSupportCaseIds.length;
    final stillWarningLimited =
        target.targetKind ==
        InternalPacketEvidenceHardeningTargetKind.warningScope;
    final stillBlocked = target.isBlockedOrFuture;
    rows.add(
      TargetedGoldenCoverageHardeningTargetImpactRow(
        targetId: target.targetId,
        scopeId: target.scopeId,
        previousActionFrom32D:
            previous?.recommendedAction.wire ?? 'notPresentBefore32E',
        currentActionAfter32E: target.recommendedAction.wire,
        supportCaseIds: supportCaseIds,
        newSupportCaseIds: newSupportCaseIds,
        improved: improved,
        stillWarningLimited: stillWarningLimited,
        stillBlocked: stillBlocked,
        recommendation: _targetRecommendationFor(
          target,
          improved: improved,
          stillWarningLimited: stillWarningLimited,
          stillBlocked: stillBlocked,
        ),
      ),
    );
  }
  rows.sort((a, b) => a.scopeId.index.compareTo(b.scopeId.index));
  return List<TargetedGoldenCoverageHardeningTargetImpactRow>.unmodifiable(
    rows,
  );
}

TargetedGoldenCoverageImpactReviewResult _resultFromRows({
  required GoldenEvidenceReviewResult evidenceReview,
  required GoldenEvidenceTriageResult triage,
  required InternalPacketEvidenceHardeningPlanResult currentPlan,
  required List<TargetedGoldenCoverageCaseImpactRow> caseRows,
  required List<TargetedGoldenCoverageHardeningTargetImpactRow> targetRows,
  required List<TargetedGoldenCoverageImpactReviewValidationFinding>
  validationFindings,
}) {
  final unsafeCaseCount = caseRows
      .where(
        (row) =>
            row.impactStatus ==
                TargetedGoldenCoverageImpactStatus.blockedByUnsafeCase ||
            row.androidProofClaimed,
      )
      .length;
  final ownerProofQueueCount =
      triage.recommendedOwnerRunProofQueue.targets.length;
  final improvedTargetCount = targetRows.where((row) => row.improved).length;
  final blockedScopeCount = targetRows.where((row) => row.stillBlocked).length;
  final stillWarningLimitedCount = targetRows
      .where((row) => row.stillWarningLimited)
      .length;
  final safeForPhase32G =
      currentPlan.safeForPhase32E &&
      evidenceReview.blockedUnsafeClaims == 0 &&
      unsafeCaseCount == 0 &&
      !validationFindings.any((finding) => finding.blocksStrict) &&
      !currentPlan.hasUnsafeHardeningPolicyViolation;
  final base = TargetedGoldenCoverageImpactReviewResult(
    impactStatus: TargetedGoldenCoverageImpactStatus.invalid,
    sourceEvidenceReviewStatus: evidenceReview.status,
    sourceHardeningStatus: currentPlan.hardeningStatus,
    caseImpactRows: caseRows,
    hardeningTargetRows: targetRows,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...evidenceReview.caseReviews.expand((review) => review.warnings),
      ...triage.warnings,
      ...currentPlan.warnings,
    ]),
    failures: _sortedStrings(<String>[
      ...evidenceReview.caseReviews.expand((review) => review.failures),
      ...triage.failures,
      ...currentPlan.failures,
      ...validationFindings.map((finding) => finding.message),
    ]),
    totalGoldenCases: evidenceReview.totalCases,
    protectedCount: triage.protectedCases.length,
    negativeGuardCount: triage.negativeGuardCases.length,
    newCaseCount: caseRows.length,
    improvedTargetCount: improvedTargetCount,
    stillWarningLimitedCount: stillWarningLimitedCount,
    blockedScopeCount: blockedScopeCount,
    ownerProofQueueCount: ownerProofQueueCount,
    unsafeCaseCount: unsafeCaseCount,
    androidProofCaseIds: _sortedStrings(
      evidenceReview.androidProofEvidenceCaseIds,
    ),
    newSupportCaseIds: _sortedStrings(caseRows.map((row) => row.caseId)),
    safeForPhase32G: safeForPhase32G,
    phase32GRecommendation:
        TargetedGoldenCoveragePhase32GRecommendation.addMoreGoldenCoverageFirst,
    productLabelsEmitted: currentPlan.productLabelsEmitted,
    classifierLabelsEmitted: currentPlan.classifierLabelsEmitted,
    finalMoveLabelsEmitted: currentPlan.finalMoveLabelsEmitted,
    officialMetricsAllowed: currentPlan.officialMetricsAllowed,
    cpLossComputationImplemented: currentPlan.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        currentPlan.winProbabilityComputationImplemented,
    numericMoveValuesComputed: currentPlan.numericMoveValuesComputed,
    moveOrderingComputed: currentPlan.moveOrderingComputed,
    directEngineAccessUsed: currentPlan.directEngineAccessUsed,
    uiOutputUsed: currentPlan.uiOutputUsed,
    backendOutputUsed: currentPlan.backendOutputUsed,
    persistenceUsed: currentPlan.persistenceUsed,
    emittedOutputFamilies: currentPlan.emittedOutputFamilies,
  );
  return base.copyWith(
    impactStatus: _impactStatusFor(base),
    phase32GRecommendation: _phase32GRecommendationFor(base),
  );
}

TargetedGoldenCoverageImpactStatus _caseImpactStatusFor({
  required GoldenEvidenceReviewStatus protectionStatus,
  required bool androidProofClaimed,
  required bool ownerProofRequired,
  required bool itemPresent,
}) {
  if (!itemPresent) return TargetedGoldenCoverageImpactStatus.invalid;
  if (androidProofClaimed) {
    return TargetedGoldenCoverageImpactStatus.blockedByUnsafeCase;
  }
  if (protectionStatus == GoldenEvidenceReviewStatus.blockedUnsafeClaim) {
    return TargetedGoldenCoverageImpactStatus.blockedByUnsafeCase;
  }
  if (protectionStatus == GoldenEvidenceReviewStatus.behaviorMismatch ||
      protectionStatus == GoldenEvidenceReviewStatus.budgetMismatch ||
      protectionStatus == GoldenEvidenceReviewStatus.failed ||
      protectionStatus == GoldenEvidenceReviewStatus.incompleteEvidence) {
    return TargetedGoldenCoverageImpactStatus.blockedByEvidenceMismatch;
  }
  if (ownerProofRequired ||
      protectionStatus == GoldenEvidenceReviewStatus.passedWithWarnings) {
    return TargetedGoldenCoverageImpactStatus.coverageImprovedWithWarnings;
  }
  return TargetedGoldenCoverageImpactStatus.coverageImproved;
}

TargetedGoldenCoverageImpactRecommendation _caseRecommendationFor(
  TargetedGoldenCoverageImpactStatus status, {
  required bool ownerProofRequired,
}) {
  if (status.isUnsafe) {
    return TargetedGoldenCoverageImpactRecommendation.investigateUnsafeCoverage;
  }
  if (ownerProofRequired) {
    return TargetedGoldenCoverageImpactRecommendation.keepBoundaryLimited;
  }
  return TargetedGoldenCoverageImpactRecommendation.refreshHardeningTarget;
}

TargetedGoldenCoverageImpactRecommendation _targetRecommendationFor(
  InternalPacketEvidenceHardeningTarget target, {
  required bool improved,
  required bool stillWarningLimited,
  required bool stillBlocked,
}) {
  if (target.targetKind ==
      InternalPacketEvidenceHardeningTargetKind.androidProofScope) {
    return TargetedGoldenCoverageImpactRecommendation.keepProofLimited;
  }
  if (stillBlocked) {
    return target.targetKind ==
            InternalPacketEvidenceHardeningTargetKind.futureOnlyScope
        ? TargetedGoldenCoverageImpactRecommendation.keepFutureOnly
        : TargetedGoldenCoverageImpactRecommendation.keepBlockedByPolicy;
  }
  if (stillWarningLimited) {
    return TargetedGoldenCoverageImpactRecommendation.keepWarningLimited;
  }
  if (improved) {
    return TargetedGoldenCoverageImpactRecommendation.refreshHardeningTarget;
  }
  return TargetedGoldenCoverageImpactRecommendation.preserveCoverageImpact;
}

TargetedGoldenCoverageImpactStatus _impactStatusFor(
  TargetedGoldenCoverageImpactReviewResult result,
) {
  if (result.unsafeCaseCount > 0 ||
      result.validationFindings.any((finding) => finding.isCritical) ||
      result.hasUnsafeImpactPolicyViolation) {
    return TargetedGoldenCoverageImpactStatus.blockedByUnsafeCase;
  }
  if (result.validationFindings.any((finding) => finding.blocksStrict)) {
    return TargetedGoldenCoverageImpactStatus.blockedByEvidenceMismatch;
  }
  if (result.newCaseCount < _phase32ECaseIds.length) {
    return TargetedGoldenCoverageImpactStatus.invalid;
  }
  if (result.improvedTargetCount == 0) {
    return TargetedGoldenCoverageImpactStatus.noMeaningfulCoverageChange;
  }
  if (result.stillWarningLimitedCount > 0 || result.ownerProofQueueCount > 0) {
    return TargetedGoldenCoverageImpactStatus.coverageImprovedWithWarnings;
  }
  return TargetedGoldenCoverageImpactStatus.coverageImproved;
}

TargetedGoldenCoveragePhase32GRecommendation _phase32GRecommendationFor(
  TargetedGoldenCoverageImpactReviewResult result,
) {
  if (result.hasUnsafeImpactPolicyViolation ||
      result.unsafeCaseCount > 0 ||
      result.validationFindings.any((finding) => finding.isCritical)) {
    return TargetedGoldenCoveragePhase32GRecommendation.blockedByUnsafeCoverage;
  }
  if (result.ownerProofQueueCount > 0) {
    return TargetedGoldenCoveragePhase32GRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (result.improvedTargetCount == 0) {
    return TargetedGoldenCoveragePhase32GRecommendation
        .addMoreGoldenCoverageFirst;
  }
  if (result.stillWarningLimitedCount > 0) {
    return TargetedGoldenCoveragePhase32GRecommendation
        .refreshInternalPacketHardeningPlanFromCoverageImpact;
  }
  return TargetedGoldenCoveragePhase32GRecommendation
      .proceedToInternalPacketEvidenceRefresh;
}

List<GoldenAnalysisCase> _prePhase32ECases(List<GoldenAnalysisCase> cases) {
  return List<GoldenAnalysisCase>.unmodifiable(
    cases.where((item) => !_phase32ECaseIds.contains(item.id)),
  );
}

List<String> _targetIdsForScopes(
  InternalPacketEvidenceHardeningPlanResult result,
  List<InternalNonLabelPrototypeScopeId> scopes,
) {
  final ids = <String>[];
  for (final scope in scopes) {
    for (final target in result.targets) {
      if (target.scopeId == scope) {
        ids.add(target.targetId);
        break;
      }
    }
  }
  return _sortedStrings(ids);
}

_CaseImpactBlueprint _caseBlueprintFor(String caseId) {
  return switch (caseId) {
    'king-safety-mating-net-pressure-32e' => const _CaseImpactBlueprint(
      targetArea: 'king-safety / mating-net coverage',
      supportContribution:
          'adds protected king-safety, forcing, and candidate-spread support',
      scopes: <InternalNonLabelPrototypeScopeId>[
        InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
        InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
        InternalNonLabelPrototypeScopeId.forcingLineInternalPrototypeScope,
        InternalNonLabelPrototypeScopeId.candidateSpreadInternalPrototypeScope,
      ],
    ),
    'endgame-precision-candidate-spread-32e' => const _CaseImpactBlueprint(
      targetArea: 'endgame precision coverage',
      supportContribution:
          'adds protected endgame precision and candidate-spread support',
      scopes: <InternalNonLabelPrototypeScopeId>[
        InternalNonLabelPrototypeScopeId.endgameInternalPrototypeScope,
        InternalNonLabelPrototypeScopeId.candidateSpreadInternalPrototypeScope,
      ],
    ),
    'suppression-forced-only-legal-32e' => const _CaseImpactBlueprint(
      targetArea: 'suppression safety / forced move coverage',
      supportContribution: 'adds protected forced suppression support',
      scopes: <InternalNonLabelPrototypeScopeId>[
        InternalNonLabelPrototypeScopeId
            .suppressionSafetyInternalPrototypeScope,
        InternalNonLabelPrototypeScopeId.forcingLineInternalPrototypeScope,
      ],
    ),
    'budget-pressure-wide-candidate-32e' => const _CaseImpactBlueprint(
      targetArea: 'budget pressure coverage',
      supportContribution: 'adds explicit budget pressure visibility',
      scopes: <InternalNonLabelPrototypeScopeId>[
        InternalNonLabelPrototypeScopeId.budgetRiskInternalPrototypeScope,
        InternalNonLabelPrototypeScopeId.forcingLineInternalPrototypeScope,
      ],
    ),
    'pv-multipv-support-boundary-32e' => const _CaseImpactBlueprint(
      targetArea: 'PV/MultiPV support boundary coverage',
      supportContribution:
          'adds boundary support without captured Android proof claim',
      scopes: <InternalNonLabelPrototypeScopeId>[
        InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope,
        InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
        InternalNonLabelPrototypeScopeId.candidateSpreadInternalPrototypeScope,
      ],
    ),
    _ => const _CaseImpactBlueprint(
      targetArea: 'unknown Phase 32E coverage',
      supportContribution: 'no recognized support contribution',
      scopes: <InternalNonLabelPrototypeScopeId>[],
    ),
  };
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

String _scopeIds(Iterable<InternalNonLabelPrototypeScopeId> values) {
  final ids = values.map((scope) => scope.wire).toSet().toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.where((value) => value.isNotEmpty).toSet().toList()..sort();
}

int _compareFindings(
  TargetedGoldenCoverageImpactReviewValidationFinding a,
  TargetedGoldenCoverageImpactReviewValidationFinding b,
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

class _CaseImpactBlueprint {
  const _CaseImpactBlueprint({
    required this.targetArea,
    required this.supportContribution,
    required this.scopes,
  });

  final String targetArea;
  final String supportContribution;
  final List<InternalNonLabelPrototypeScopeId> scopes;
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

const _blockedProductBoundaryScopes = <InternalNonLabelPrototypeScopeId>{
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

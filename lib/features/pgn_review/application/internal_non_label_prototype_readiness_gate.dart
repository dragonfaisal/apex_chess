/// Developer-only readiness gate for a future internal non-label prototype.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_experiment_runner.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_observation_review_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_profile_consistency_matrix.dart';

const internalNonLabelPrototypeReadinessGateReportVersion =
    'internal-non-label-prototype-readiness-gate-v1';

enum InternalNonLabelPrototypeReadinessStatus {
  readyForNarrowInternalPrototype('readyForNarrowInternalPrototype'),
  readyWithCoverageWarnings('readyWithCoverageWarnings'),
  blockedByUnsafeObservation('blockedByUnsafeObservation'),
  blockedByConsistencyFailure('blockedByConsistencyFailure'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  blockedByInsufficientStableObservations(
    'blockedByInsufficientStableObservations',
  ),
  blockedByUnprovenAndroidProof('blockedByUnprovenAndroidProof'),
  blockedByQuietScope('blockedByQuietScope'),
  invalid('invalid');

  const InternalNonLabelPrototypeReadinessStatus(this.wire);

  final String wire;
}

enum InternalNonLabelPrototypeScopeId {
  tacticalInternalPrototypeScope('tacticalInternalPrototypeScope'),
  materialSwingInternalPrototypeScope('materialSwingInternalPrototypeScope'),
  forcingLineInternalPrototypeScope('forcingLineInternalPrototypeScope'),
  candidateSpreadInternalPrototypeScope(
    'candidateSpreadInternalPrototypeScope',
  ),
  pvMultiPvSupportInternalPrototypeScope(
    'pvMultiPvSupportInternalPrototypeScope',
  ),
  androidProofConfidenceInternalPrototypeScope(
    'androidProofConfidenceInternalPrototypeScope',
  ),
  kingSafetyInternalPrototypeScope('kingSafetyInternalPrototypeScope'),
  endgameInternalPrototypeScope('endgameInternalPrototypeScope'),
  suppressionSafetyInternalPrototypeScope(
    'suppressionSafetyInternalPrototypeScope',
  ),
  budgetRiskInternalPrototypeScope('budgetRiskInternalPrototypeScope'),
  quietPreparatoryPrototypeScope('quietPreparatoryPrototypeScope'),
  productLabelPrototypeScope('productLabelPrototypeScope'),
  advancedLabelPrototypeScope('advancedLabelPrototypeScope'),
  officialMetricPrototypeScope('officialMetricPrototypeScope'),
  cpLossPrototypeScope('cpLossPrototypeScope'),
  winProbabilityPrototypeScope('winProbabilityPrototypeScope'),
  uiProductIntegrationScope('uiProductIntegrationScope'),
  backendIntegrationScope('backendIntegrationScope'),
  persistenceScope('persistenceScope'),
  directEngineAccessScope('directEngineAccessScope');

  const InternalNonLabelPrototypeScopeId(this.wire);

  final String wire;
}

enum InternalNonLabelPrototypeScopeReadiness {
  allowedInternalOnly('allowedInternalOnly'),
  allowedWithWarnings('allowedWithWarnings'),
  warningLimited('warningLimited'),
  blocked('blocked'),
  futureOnly('futureOnly'),
  invalid('invalid');

  const InternalNonLabelPrototypeScopeReadiness(this.wire);

  final String wire;

  bool get isAllowed =>
      this == InternalNonLabelPrototypeScopeReadiness.allowedInternalOnly ||
      this == InternalNonLabelPrototypeScopeReadiness.allowedWithWarnings;

  bool get isBlocked =>
      this == InternalNonLabelPrototypeScopeReadiness.blocked ||
      this == InternalNonLabelPrototypeScopeReadiness.futureOnly;
}

enum InternalNonLabelPrototypeReadinessRecommendation {
  proceedToNarrowInternalPrototype('proceedToNarrowInternalPrototype'),
  addGoldenCoverageFirst('addGoldenCoverageFirst'),
  fixUnsafeObservationFirst('fixUnsafeObservationFirst'),
  keepDesignOnly('keepDesignOnly'),
  blocked('blocked');

  const InternalNonLabelPrototypeReadinessRecommendation(this.wire);

  final String wire;
}

enum InternalNonLabelPrototypeReadinessValidationSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const InternalNonLabelPrototypeReadinessValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == InternalNonLabelPrototypeReadinessValidationSeverity.blocker ||
      this == InternalNonLabelPrototypeReadinessValidationSeverity.critical;
}

enum InternalNonLabelPrototypeReadinessReportFormat {
  markdown('markdown'),
  json('json');

  const InternalNonLabelPrototypeReadinessReportFormat(this.wire);

  final String wire;
}

class InternalNonLabelPrototypeReadinessGateRequest {
  const InternalNonLabelPrototypeReadinessGateRequest({
    this.reviewResult,
    this.runnerResult,
    this.consistencyResult,
    this.profileResult,
    this.coverageMatrixResult,
    this.reviewMatrix = const InternalSignalObservationReviewMatrix(),
    this.runner = const InternalSignalExperimentRunner(),
    this.consistencyMatrix = const InternalSignalProfileConsistencyMatrix(),
    this.profile = const InternalNonLabelSignalProfilePrototype(),
    this.coverageMatrix = const InternalEvidenceAreaCoverageMatrix(),
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.cases = GoldenAnalysisCases.defaults,
  });

  InternalNonLabelPrototypeReadinessGateRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  }) : this(cases: cases);

  final InternalSignalObservationReviewMatrixResult? reviewResult;
  final InternalSignalExperimentRunnerResult? runnerResult;
  final InternalSignalProfileConsistencyMatrixResult? consistencyResult;
  final InternalNonLabelSignalProfileResult? profileResult;
  final InternalEvidenceAreaCoverageMatrixResult? coverageMatrixResult;
  final InternalSignalObservationReviewMatrix reviewMatrix;
  final InternalSignalExperimentRunner runner;
  final InternalSignalProfileConsistencyMatrix consistencyMatrix;
  final InternalNonLabelSignalProfilePrototype profile;
  final InternalEvidenceAreaCoverageMatrix coverageMatrix;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final List<GoldenAnalysisCase> cases;
}

class InternalNonLabelPrototypeScopeReadinessRecord {
  const InternalNonLabelPrototypeScopeReadinessRecord({
    required this.scopeId,
    required this.readiness,
    required this.signalId,
    required this.observationStatus,
    required this.supportCaseIds,
    required this.androidProofCaseIds,
    required this.coverageGapIds,
    required this.policyBlockers,
    required this.warningReason,
    required this.recommendation,
  });

  final InternalNonLabelPrototypeScopeId scopeId;
  final InternalNonLabelPrototypeScopeReadiness readiness;
  final InternalNonLabelSignalId? signalId;
  final InternalSignalObservationReviewStatus? observationStatus;
  final List<String> supportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> coverageGapIds;
  final List<String> policyBlockers;
  final String warningReason;
  final InternalNonLabelPrototypeReadinessRecommendation recommendation;

  bool get isAllowed => readiness.isAllowed;

  bool get isWarningLimited =>
      readiness == InternalNonLabelPrototypeScopeReadiness.warningLimited;

  bool get isBlocked => readiness.isBlocked;

  InternalNonLabelPrototypeScopeReadinessRecord copyWith({
    InternalNonLabelPrototypeScopeId? scopeId,
    InternalNonLabelPrototypeScopeReadiness? readiness,
    InternalNonLabelSignalId? signalId,
    InternalSignalObservationReviewStatus? observationStatus,
    List<String>? supportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? coverageGapIds,
    List<String>? policyBlockers,
    String? warningReason,
    InternalNonLabelPrototypeReadinessRecommendation? recommendation,
  }) {
    return InternalNonLabelPrototypeScopeReadinessRecord(
      scopeId: scopeId ?? this.scopeId,
      readiness: readiness ?? this.readiness,
      signalId: signalId ?? this.signalId,
      observationStatus: observationStatus ?? this.observationStatus,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      coverageGapIds: coverageGapIds ?? this.coverageGapIds,
      policyBlockers: policyBlockers ?? this.policyBlockers,
      warningReason: warningReason ?? this.warningReason,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'scopeId': scopeId.wire,
      'readiness': readiness.wire,
      if (signalId != null) 'signalId': signalId!.wire,
      if (observationStatus != null)
        'observationStatus': observationStatus!.wire,
      'supportCaseIds': supportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'coverageGapIds': coverageGapIds,
      'policyBlockers': policyBlockers,
      'warningReason': warningReason,
      'recommendation': recommendation.wire,
    };
  }
}

class InternalNonLabelPrototypeReadinessValidationFinding {
  const InternalNonLabelPrototypeReadinessValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.scopeId,
    this.signalId,
    this.caseId,
  });

  final String id;
  final InternalNonLabelPrototypeReadinessValidationSeverity severity;
  final String message;
  final InternalNonLabelPrototypeScopeId? scopeId;
  final InternalNonLabelSignalId? signalId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical =>
      severity == InternalNonLabelPrototypeReadinessValidationSeverity.critical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (scopeId != null) 'scopeId': scopeId!.wire,
      if (signalId != null) 'signalId': signalId!.wire,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class InternalNonLabelPrototypeReadinessResult {
  const InternalNonLabelPrototypeReadinessResult({
    required this.overallStatus,
    required this.phase32ARecommendation,
    required this.reviewMatrixStatus,
    required this.runnerStatus,
    required this.consistencyMatrixStatus,
    required this.profileStatus,
    required this.coverageMatrixStatus,
    required this.scopeRecords,
    required this.validationFindings,
    required this.allowedScopeIds,
    required this.warningLimitedScopeIds,
    required this.blockedScopeIds,
    required this.stableObservationSignalIds,
    required this.warningObservationSignalIds,
    required this.supportCaseIds,
    required this.androidProofCaseIds,
    required this.coverageGapIds,
    required this.policyBlockers,
    required this.warnings,
    required this.failures,
    required this.safeForPhase32AInternalPrototype,
    required this.reviewUnsafeCount,
    required this.consistencyBlockerCount,
    required this.consistencyCriticalCount,
    this.developerOnly = true,
    this.productLabelsEmitted = false,
    this.classifierLabelsEmitted = false,
    this.finalMoveLabelsEmitted = false,
    this.officialMetricsAllowed = false,
    this.cpLossComputationImplemented = false,
    this.winProbabilityComputationImplemented = false,
    this.numericMoveScoresComputed = false,
    this.moveRankingComputed = false,
    this.directEngineAccessUsed = false,
    this.uiOutputUsed = false,
    this.backendOutputUsed = false,
    this.persistenceUsed = false,
    this.emittedOutputFamilies = const <String>[],
  });

  final InternalNonLabelPrototypeReadinessStatus overallStatus;
  final InternalNonLabelPrototypeReadinessRecommendation phase32ARecommendation;
  final InternalSignalObservationReviewMatrixStatus reviewMatrixStatus;
  final InternalSignalExperimentRunnerStatus runnerStatus;
  final InternalSignalProfileConsistencyMatrixStatus consistencyMatrixStatus;
  final InternalNonLabelSignalProfileStatus profileStatus;
  final InternalEvidenceAreaCoverageMatrixStatus coverageMatrixStatus;
  final List<InternalNonLabelPrototypeScopeReadinessRecord> scopeRecords;
  final List<InternalNonLabelPrototypeReadinessValidationFinding>
  validationFindings;
  final List<InternalNonLabelPrototypeScopeId> allowedScopeIds;
  final List<InternalNonLabelPrototypeScopeId> warningLimitedScopeIds;
  final List<InternalNonLabelPrototypeScopeId> blockedScopeIds;
  final List<InternalNonLabelSignalId> stableObservationSignalIds;
  final List<InternalNonLabelSignalId> warningObservationSignalIds;
  final List<String> supportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> coverageGapIds;
  final List<String> policyBlockers;
  final List<String> warnings;
  final List<String> failures;
  final bool safeForPhase32AInternalPrototype;
  final int reviewUnsafeCount;
  final int consistencyBlockerCount;
  final int consistencyCriticalCount;
  final bool developerOnly;
  final bool productLabelsEmitted;
  final bool classifierLabelsEmitted;
  final bool finalMoveLabelsEmitted;
  final bool officialMetricsAllowed;
  final bool cpLossComputationImplemented;
  final bool winProbabilityComputationImplemented;
  final bool numericMoveScoresComputed;
  final bool moveRankingComputed;
  final bool directEngineAccessUsed;
  final bool uiOutputUsed;
  final bool backendOutputUsed;
  final bool persistenceUsed;
  final List<String> emittedOutputFamilies;

  bool get isStrictlyBlocked =>
      !safeForPhase32AInternalPrototype ||
      overallStatus ==
          InternalNonLabelPrototypeReadinessStatus.blockedByUnsafeObservation ||
      overallStatus ==
          InternalNonLabelPrototypeReadinessStatus
              .blockedByConsistencyFailure ||
      overallStatus ==
          InternalNonLabelPrototypeReadinessStatus.blockedByPolicyBoundary ||
      overallStatus ==
          InternalNonLabelPrototypeReadinessStatus
              .blockedByInsufficientStableObservations ||
      overallStatus ==
          InternalNonLabelPrototypeReadinessStatus
              .blockedByUnprovenAndroidProof ||
      overallStatus ==
          InternalNonLabelPrototypeReadinessStatus.blockedByQuietScope ||
      overallStatus == InternalNonLabelPrototypeReadinessStatus.invalid;

  bool get hasUnsafeReadinessPolicyViolation {
    return reviewUnsafeCount > 0 ||
        consistencyBlockerCount > 0 ||
        consistencyCriticalCount > 0 ||
        validationFindings.any((finding) => finding.blocksStrict) ||
        productLabelsEmitted ||
        classifierLabelsEmitted ||
        finalMoveLabelsEmitted ||
        officialMetricsAllowed ||
        cpLossComputationImplemented ||
        winProbabilityComputationImplemented ||
        numericMoveScoresComputed ||
        moveRankingComputed ||
        directEngineAccessUsed ||
        uiOutputUsed ||
        backendOutputUsed ||
        persistenceUsed ||
        emittedOutputFamilies.any(_isForbiddenOutputName) ||
        scopeRecords.any(
          (scope) =>
              _integrationScopes.contains(scope.scopeId) && scope.isAllowed,
        );
  }

  InternalNonLabelPrototypeScopeReadinessRecord scope(
    InternalNonLabelPrototypeScopeId id,
  ) {
    return scopeRecords.singleWhere((scope) => scope.scopeId == id);
  }

  InternalNonLabelPrototypeReadinessResult copyWith({
    InternalNonLabelPrototypeReadinessStatus? overallStatus,
    InternalNonLabelPrototypeReadinessRecommendation? phase32ARecommendation,
    InternalSignalObservationReviewMatrixStatus? reviewMatrixStatus,
    InternalSignalExperimentRunnerStatus? runnerStatus,
    InternalSignalProfileConsistencyMatrixStatus? consistencyMatrixStatus,
    InternalNonLabelSignalProfileStatus? profileStatus,
    InternalEvidenceAreaCoverageMatrixStatus? coverageMatrixStatus,
    List<InternalNonLabelPrototypeScopeReadinessRecord>? scopeRecords,
    List<InternalNonLabelPrototypeReadinessValidationFinding>?
    validationFindings,
    List<InternalNonLabelPrototypeScopeId>? allowedScopeIds,
    List<InternalNonLabelPrototypeScopeId>? warningLimitedScopeIds,
    List<InternalNonLabelPrototypeScopeId>? blockedScopeIds,
    List<InternalNonLabelSignalId>? stableObservationSignalIds,
    List<InternalNonLabelSignalId>? warningObservationSignalIds,
    List<String>? supportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? coverageGapIds,
    List<String>? policyBlockers,
    List<String>? warnings,
    List<String>? failures,
    bool? safeForPhase32AInternalPrototype,
    int? reviewUnsafeCount,
    int? consistencyBlockerCount,
    int? consistencyCriticalCount,
    bool? developerOnly,
    bool? productLabelsEmitted,
    bool? classifierLabelsEmitted,
    bool? finalMoveLabelsEmitted,
    bool? officialMetricsAllowed,
    bool? cpLossComputationImplemented,
    bool? winProbabilityComputationImplemented,
    bool? numericMoveScoresComputed,
    bool? moveRankingComputed,
    bool? directEngineAccessUsed,
    bool? uiOutputUsed,
    bool? backendOutputUsed,
    bool? persistenceUsed,
    List<String>? emittedOutputFamilies,
  }) {
    return InternalNonLabelPrototypeReadinessResult(
      overallStatus: overallStatus ?? this.overallStatus,
      phase32ARecommendation:
          phase32ARecommendation ?? this.phase32ARecommendation,
      reviewMatrixStatus: reviewMatrixStatus ?? this.reviewMatrixStatus,
      runnerStatus: runnerStatus ?? this.runnerStatus,
      consistencyMatrixStatus:
          consistencyMatrixStatus ?? this.consistencyMatrixStatus,
      profileStatus: profileStatus ?? this.profileStatus,
      coverageMatrixStatus: coverageMatrixStatus ?? this.coverageMatrixStatus,
      scopeRecords: scopeRecords ?? this.scopeRecords,
      validationFindings: validationFindings ?? this.validationFindings,
      allowedScopeIds: allowedScopeIds ?? this.allowedScopeIds,
      warningLimitedScopeIds:
          warningLimitedScopeIds ?? this.warningLimitedScopeIds,
      blockedScopeIds: blockedScopeIds ?? this.blockedScopeIds,
      stableObservationSignalIds:
          stableObservationSignalIds ?? this.stableObservationSignalIds,
      warningObservationSignalIds:
          warningObservationSignalIds ?? this.warningObservationSignalIds,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      coverageGapIds: coverageGapIds ?? this.coverageGapIds,
      policyBlockers: policyBlockers ?? this.policyBlockers,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      safeForPhase32AInternalPrototype:
          safeForPhase32AInternalPrototype ??
          this.safeForPhase32AInternalPrototype,
      reviewUnsafeCount: reviewUnsafeCount ?? this.reviewUnsafeCount,
      consistencyBlockerCount:
          consistencyBlockerCount ?? this.consistencyBlockerCount,
      consistencyCriticalCount:
          consistencyCriticalCount ?? this.consistencyCriticalCount,
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
      numericMoveScoresComputed:
          numericMoveScoresComputed ?? this.numericMoveScoresComputed,
      moveRankingComputed: moveRankingComputed ?? this.moveRankingComputed,
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
      ..writeln('# Internal Non-Label Prototype Readiness Gate')
      ..writeln()
      ..writeln(
        '- version: $internalNonLabelPrototypeReadinessGateReportVersion',
      )
      ..writeln('- readiness status: ${overallStatus.wire}')
      ..writeln('- Phase 32A recommendation: ${phase32ARecommendation.wire}')
      ..writeln(
        '- safe for Phase 32A internal prototype: $safeForPhase32AInternalPrototype',
      )
      ..writeln('- review matrix status: ${reviewMatrixStatus.wire}')
      ..writeln('- runner status: ${runnerStatus.wire}')
      ..writeln('- consistency matrix status: ${consistencyMatrixStatus.wire}')
      ..writeln('- review unsafe count: $reviewUnsafeCount')
      ..writeln('- consistency blocker count: $consistencyBlockerCount')
      ..writeln('- consistency critical count: $consistencyCriticalCount')
      ..writeln('- classifier output emitted: $classifierLabelsEmitted')
      ..writeln('- numeric score values emitted: $numericMoveScoresComputed')
      ..writeln('- ordering output emitted: $moveRankingComputed')
      ..writeln()
      ..writeln('## Readiness Policy')
      ..writeln(
        '- this gate decides readiness only; it does not run a prototype or judge move quality',
      )
      ..writeln(
        '- Phase 32A may proceed only as a narrow developer-only, non-label, non-scoring, non-product experiment',
      )
      ..writeln()
      ..writeln('## Scope Table')
      ..writeln(
        '| Scope | Readiness | Signal | Observation | Support Cases | Android Proof | Gaps | Policy Blockers | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- | --- |');
    for (final scope in scopeRecords) {
      buffer.writeln(
        '| ${scope.scopeId.wire} | ${scope.readiness.wire} | ${scope.signalId?.wire ?? '-'} | ${scope.observationStatus?.wire ?? '-'} | ${_ids(scope.supportCaseIds)} | ${_ids(scope.androidProofCaseIds)} | ${_ids(scope.coverageGapIds)} | ${_ids(scope.policyBlockers)} | ${scope.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Allowed Internal Scopes')
      ..writeln('- ${_scopeIds(allowedScopeIds)}')
      ..writeln()
      ..writeln('## Warning-Limited Scopes')
      ..writeln('- ${_scopeIds(warningLimitedScopeIds)}')
      ..writeln()
      ..writeln('## Blocked Scopes')
      ..writeln('- ${_scopeIds(blockedScopeIds)}')
      ..writeln()
      ..writeln('## Stable Observations')
      ..writeln('- ${_signalIds(stableObservationSignalIds)}')
      ..writeln()
      ..writeln('## Warning Observations')
      ..writeln('- ${_signalIds(warningObservationSignalIds)}')
      ..writeln()
      ..writeln('## Support Cases')
      ..writeln('- ${_ids(supportCaseIds)}')
      ..writeln()
      ..writeln('## Android Proof References')
      ..writeln('- ${_ids(androidProofCaseIds)}')
      ..writeln()
      ..writeln('## Coverage Gaps')
      ..writeln('- ${_ids(coverageGapIds)}')
      ..writeln()
      ..writeln('## Policy Blockers')
      ..writeln('- ${_ids(policyBlockers)}')
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
      ..writeln('## Final Next Step')
      ..writeln(phase32ARecommendation.wire)
      ..writeln()
      ..writeln(
        'This gate produces a readiness decision only. It does not emit user-facing output, compute product metrics, call the engine, run Android, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': internalNonLabelPrototypeReadinessGateReportVersion,
      'overallStatus': overallStatus.wire,
      'phase32ARecommendation': phase32ARecommendation.wire,
      'reviewMatrixStatus': reviewMatrixStatus.wire,
      'runnerStatus': runnerStatus.wire,
      'consistencyMatrixStatus': consistencyMatrixStatus.wire,
      'profileStatus': profileStatus.wire,
      'coverageMatrixStatus': coverageMatrixStatus.wire,
      'allowedScopeIds': allowedScopeIds.map((id) => id.wire).toList(),
      'warningLimitedScopeIds': warningLimitedScopeIds
          .map((id) => id.wire)
          .toList(),
      'blockedScopeIds': blockedScopeIds.map((id) => id.wire).toList(),
      'stableObservationSignalIds': stableObservationSignalIds
          .map((id) => id.wire)
          .toList(),
      'warningObservationSignalIds': warningObservationSignalIds
          .map((id) => id.wire)
          .toList(),
      'supportCaseIds': supportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'coverageGapIds': coverageGapIds,
      'policyBlockers': policyBlockers,
      'warnings': warnings,
      'failures': failures,
      'safeForPhase32AInternalPrototype': safeForPhase32AInternalPrototype,
      'reviewUnsafeCount': reviewUnsafeCount,
      'consistencyBlockerCount': consistencyBlockerCount,
      'consistencyCriticalCount': consistencyCriticalCount,
      'scopeRecords': scopeRecords
          .map((scope) => scope.toJson())
          .toList(growable: false),
      'validationFindings': validationFindings
          .map((finding) => finding.toJson())
          .toList(growable: false),
      'developerOnly': developerOnly,
      'productLabelsEmitted': productLabelsEmitted,
      'classifierLabelsEmitted': classifierLabelsEmitted,
      'finalMoveLabelsEmitted': finalMoveLabelsEmitted,
      'officialMetricsAllowed': officialMetricsAllowed,
      'cpLossComputationImplemented': cpLossComputationImplemented,
      'winProbabilityComputationImplemented':
          winProbabilityComputationImplemented,
      'numericMoveScoresComputed': numericMoveScoresComputed,
      'moveRankingComputed': moveRankingComputed,
      'directEngineAccessUsed': directEngineAccessUsed,
      'uiOutputUsed': uiOutputUsed,
      'backendOutputUsed': backendOutputUsed,
      'persistenceUsed': persistenceUsed,
      'emittedOutputFamilies': emittedOutputFamilies,
    };
  }
}

class InternalNonLabelPrototypeReadinessGate {
  const InternalNonLabelPrototypeReadinessGate({
    this.validator = const InternalNonLabelPrototypeReadinessGateValidator(),
  });

  final InternalNonLabelPrototypeReadinessGateValidator validator;

  InternalNonLabelPrototypeReadinessResult evaluate([
    InternalNonLabelPrototypeReadinessGateRequest request =
        const InternalNonLabelPrototypeReadinessGateRequest(),
  ]) {
    final profileResult =
        request.profileResult ??
        request.profile.evaluate(
          InternalNonLabelSignalProfileRequest(
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
          ),
        );
    final coverageResult =
        request.coverageMatrixResult ??
        request.coverageMatrix.evaluate(
          InternalEvidenceAreaCoverageMatrixRequest(cases: request.cases),
        );
    final consistencyResult =
        request.consistencyResult ??
        request.consistencyMatrix.evaluate(
          InternalSignalProfileConsistencyMatrixRequest(
            profileResult: profileResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
          ),
        );
    final runnerResult =
        request.runnerResult ??
        request.runner.run(
          InternalSignalExperimentRunnerRequest(
            consistencyResult: consistencyResult,
            profileResult: profileResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
          ),
        );
    final reviewResult =
        request.reviewResult ??
        request.reviewMatrix.evaluate(
          InternalSignalObservationReviewMatrixRequest(
            runnerResult: runnerResult,
            consistencyResult: consistencyResult,
            profileResult: profileResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
          ),
        );

    final scopeRecords = _buildScopeRecords(reviewResult);
    final base = _resultFromScopes(
      scopeRecords: scopeRecords,
      reviewResult: reviewResult,
      runnerResult: runnerResult,
      consistencyResult: consistencyResult,
      profileResult: profileResult,
      coverageResult: coverageResult,
      validationFindings:
          const <InternalNonLabelPrototypeReadinessValidationFinding>[],
    );
    final findings = validator.validate(
      base,
      reviewResult: reviewResult,
      consistencyResult: consistencyResult,
    );
    final withValidation = _resultFromScopes(
      scopeRecords: scopeRecords,
      reviewResult: reviewResult,
      runnerResult: runnerResult,
      consistencyResult: consistencyResult,
      profileResult: profileResult,
      coverageResult: coverageResult,
      validationFindings: findings,
    );
    final status = _overallStatusFor(
      withValidation,
      reviewResult: reviewResult,
      consistencyResult: consistencyResult,
    );
    final safe =
        status ==
            InternalNonLabelPrototypeReadinessStatus
                .readyForNarrowInternalPrototype ||
        status ==
            InternalNonLabelPrototypeReadinessStatus.readyWithCoverageWarnings;
    return withValidation.copyWith(
      overallStatus: status,
      phase32ARecommendation: _phase32ARecommendationFor(status),
      safeForPhase32AInternalPrototype: safe,
    );
  }
}

class InternalNonLabelPrototypeReadinessGateValidator {
  const InternalNonLabelPrototypeReadinessGateValidator();

  List<InternalNonLabelPrototypeReadinessValidationFinding> validate(
    InternalNonLabelPrototypeReadinessResult result, {
    required InternalSignalObservationReviewMatrixResult reviewResult,
    required InternalSignalProfileConsistencyMatrixResult consistencyResult,
  }) {
    final findings = <InternalNonLabelPrototypeReadinessValidationFinding>[];

    void add({
      required String id,
      required InternalNonLabelPrototypeReadinessValidationSeverity severity,
      required String message,
      InternalNonLabelPrototypeScopeId? scopeId,
      InternalNonLabelSignalId? signalId,
      String? caseId,
    }) {
      findings.add(
        InternalNonLabelPrototypeReadinessValidationFinding(
          id: id,
          severity: severity,
          message: message,
          scopeId: scopeId,
          signalId: signalId,
          caseId: caseId,
        ),
      );
    }

    if (reviewResult.unsafeCount > 0 &&
        result.safeForPhase32AInternalPrototype) {
      add(
        id: 'readyDespiteUnsafeObservation',
        severity: InternalNonLabelPrototypeReadinessValidationSeverity.critical,
        message: 'readiness cannot be true with unsafe observations',
      );
    }
    if ((consistencyResult.blockerCount > 0 ||
            consistencyResult.criticalCount > 0) &&
        result.safeForPhase32AInternalPrototype) {
      add(
        id: 'readyDespiteConsistencyFailure',
        severity: InternalNonLabelPrototypeReadinessValidationSeverity.critical,
        message: 'readiness cannot be true with consistency failures',
      );
    }
    if (result.allowedScopeIds.isEmpty &&
        result.safeForPhase32AInternalPrototype) {
      add(
        id: 'readyWithoutStableAllowedScopes',
        severity: InternalNonLabelPrototypeReadinessValidationSeverity.blocker,
        message: 'readiness requires stable allowed scopes',
      );
    }
    if (!_containsAllAllowedScopes(result.allowedScopeIds)) {
      add(
        id: 'missingRequiredAllowedScope',
        severity: InternalNonLabelPrototypeReadinessValidationSeverity.blocker,
        message: 'one or more required narrow internal scopes are missing',
      );
    }

    final quietScope = result.scope(
      InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
    );
    if (_quietScopeActive(reviewResult)) {
      add(
        id: 'quietScopeActivated',
        severity: InternalNonLabelPrototypeReadinessValidationSeverity.critical,
        message: 'quiet/preparatory scope became active',
        scopeId: quietScope.scopeId,
        signalId: quietScope.signalId,
      );
    }
    if (!quietScope.isBlocked) {
      add(
        id: 'quietScopeNotBlocked',
        severity: InternalNonLabelPrototypeReadinessValidationSeverity.critical,
        message: 'quiet/preparatory scope must remain blocked',
        scopeId: quietScope.scopeId,
        signalId: quietScope.signalId,
      );
    }
    for (final scope in result.scopeRecords) {
      if (_policyScopes.contains(scope.scopeId) && !scope.isBlocked) {
        add(
          id: 'policyScopeNotBlocked',
          severity:
              InternalNonLabelPrototypeReadinessValidationSeverity.critical,
          message: '${scope.scopeId.wire} must remain blocked',
          scopeId: scope.scopeId,
          signalId: scope.signalId,
        );
      }
      if (_integrationScopes.contains(scope.scopeId) && scope.isAllowed) {
        add(
          id: 'integrationScopeAllowed',
          severity:
              InternalNonLabelPrototypeReadinessValidationSeverity.critical,
          message: '${scope.scopeId.wire} must not be allowed',
          scopeId: scope.scopeId,
        );
      }
      for (final caseId in scope.androidProofCaseIds) {
        if (!result.androidProofCaseIds.contains(caseId)) {
          add(
            id: 'unprovenAndroidProofScopeCitation',
            severity:
                InternalNonLabelPrototypeReadinessValidationSeverity.blocker,
            message: '${scope.scopeId.wire} cites unproven proof',
            scopeId: scope.scopeId,
            signalId: scope.signalId,
            caseId: caseId,
          );
        }
      }
    }

    if (reviewResult.unprovenAndroidCaseIds.isNotEmpty) {
      for (final caseId in reviewResult.unprovenAndroidCaseIds) {
        add(
          id: 'unprovenAndroidProofCitation',
          severity:
              InternalNonLabelPrototypeReadinessValidationSeverity.blocker,
          message: 'unproven Android proof citation blocks readiness',
          caseId: caseId,
        );
      }
    }

    if (result.productLabelsEmitted ||
        result.classifierLabelsEmitted ||
        result.finalMoveLabelsEmitted ||
        result.officialMetricsAllowed ||
        result.cpLossComputationImplemented ||
        result.winProbabilityComputationImplemented ||
        result.numericMoveScoresComputed ||
        result.moveRankingComputed ||
        result.directEngineAccessUsed ||
        result.uiOutputUsed ||
        result.backendOutputUsed ||
        result.persistenceUsed ||
        result.emittedOutputFamilies.any(_isForbiddenOutputName)) {
      add(
        id: 'readinessBoundaryPolicyViolation',
        severity: InternalNonLabelPrototypeReadinessValidationSeverity.critical,
        message: 'readiness gate crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<InternalNonLabelPrototypeReadinessValidationFinding> validateReportText(
    String reportText,
  ) {
    final findings = <InternalNonLabelPrototypeReadinessValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        InternalNonLabelPrototypeReadinessValidationFinding(
          id: id,
          severity:
              InternalNonLabelPrototypeReadinessValidationSeverity.critical,
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
        'numericMoveScoreReportText',
        'report contains numeric move score text',
      );
    }
    if (reportText.contains('rankedMoves') ||
        reportText.contains('moveRanking')) {
      reportError('moveOrderingReportText', 'report contains ordering text');
    }
    return findings..sort(_compareFindings);
  }
}

InternalNonLabelPrototypeReadinessResult _resultFromScopes({
  required List<InternalNonLabelPrototypeScopeReadinessRecord> scopeRecords,
  required InternalSignalObservationReviewMatrixResult reviewResult,
  required InternalSignalExperimentRunnerResult runnerResult,
  required InternalSignalProfileConsistencyMatrixResult consistencyResult,
  required InternalNonLabelSignalProfileResult profileResult,
  required InternalEvidenceAreaCoverageMatrixResult coverageResult,
  required List<InternalNonLabelPrototypeReadinessValidationFinding>
  validationFindings,
}) {
  final allowedScopeIds = _sortedScopeIds(
    scopeRecords
        .where((scope) => scope.isAllowed)
        .map((scope) => scope.scopeId),
  );
  final warningLimitedScopeIds = _sortedScopeIds(
    scopeRecords
        .where((scope) => scope.isWarningLimited)
        .map((scope) => scope.scopeId),
  );
  final blockedScopeIds = _sortedScopeIds(
    scopeRecords
        .where((scope) => scope.isBlocked)
        .map((scope) => scope.scopeId),
  );
  final stableObservationSignalIds = _sortedSignalIds(
    reviewResult.stableRows.map((row) => row.signalId),
  );
  final warningObservationSignalIds = _sortedSignalIds(
    reviewResult.warningRows.map((row) => row.signalId),
  );
  final supportCaseIds = _sortedStrings(
    scopeRecords.expand((scope) => scope.supportCaseIds),
  );
  final androidProofCaseIds = _sortedStrings(
    scopeRecords
        .expand((scope) => scope.androidProofCaseIds)
        .where(reviewResult.provenAndroidCaseIds.contains),
  );
  final coverageGapIds = _sortedStrings(
    scopeRecords.expand((scope) => scope.coverageGapIds),
  );
  final policyBlockers = _sortedStrings(
    scopeRecords.expand((scope) => scope.policyBlockers),
  );
  final warnings = _sortedStrings(<String>[
    ...reviewResult.warnings,
    ...scopeRecords
        .where((scope) => scope.warningReason.isNotEmpty)
        .map((scope) => '${scope.scopeId.wire}: ${scope.warningReason}'),
  ]);
  final failures = _sortedStrings(<String>[
    ...reviewResult.failures,
    ...validationFindings.map((finding) => finding.message),
  ]);
  final base = InternalNonLabelPrototypeReadinessResult(
    overallStatus: InternalNonLabelPrototypeReadinessStatus.invalid,
    phase32ARecommendation:
        InternalNonLabelPrototypeReadinessRecommendation.blocked,
    reviewMatrixStatus: reviewResult.matrixStatus,
    runnerStatus: runnerResult.runnerStatus,
    consistencyMatrixStatus: consistencyResult.matrixStatus,
    profileStatus: profileResult.status,
    coverageMatrixStatus: coverageResult.status,
    scopeRecords:
        List<InternalNonLabelPrototypeScopeReadinessRecord>.unmodifiable(
          scopeRecords,
        ),
    validationFindings: validationFindings,
    allowedScopeIds: allowedScopeIds,
    warningLimitedScopeIds: warningLimitedScopeIds,
    blockedScopeIds: blockedScopeIds,
    stableObservationSignalIds: stableObservationSignalIds,
    warningObservationSignalIds: warningObservationSignalIds,
    supportCaseIds: supportCaseIds,
    androidProofCaseIds: androidProofCaseIds,
    coverageGapIds: coverageGapIds,
    policyBlockers: policyBlockers,
    warnings: warnings,
    failures: failures,
    safeForPhase32AInternalPrototype: false,
    reviewUnsafeCount: reviewResult.unsafeCount,
    consistencyBlockerCount: consistencyResult.blockerCount,
    consistencyCriticalCount: consistencyResult.criticalCount,
    productLabelsEmitted:
        reviewResult.productLabelsEmitted || runnerResult.productLabelsEmitted,
    classifierLabelsEmitted:
        reviewResult.classifierLabelsEmitted ||
        runnerResult.classifierLabelsEmitted,
    finalMoveLabelsEmitted:
        reviewResult.finalMoveLabelsEmitted ||
        runnerResult.finalMoveLabelsEmitted,
    officialMetricsAllowed:
        reviewResult.officialMetricsAllowed ||
        runnerResult.officialMetricsAllowed,
    cpLossComputationImplemented:
        reviewResult.cpLossComputationImplemented ||
        runnerResult.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        reviewResult.winProbabilityComputationImplemented ||
        runnerResult.winProbabilityComputationImplemented,
    numericMoveScoresComputed:
        reviewResult.numericMoveScoresComputed ||
        runnerResult.numericMoveScoresComputed,
    moveRankingComputed:
        reviewResult.moveRankingComputed || runnerResult.moveRankingComputed,
    directEngineAccessUsed:
        reviewResult.directEngineAccessUsed ||
        runnerResult.directEngineAccessUsed,
    uiOutputUsed: reviewResult.uiOutputUsed || runnerResult.uiOutputUsed,
    backendOutputUsed:
        reviewResult.backendOutputUsed || runnerResult.backendOutputUsed,
    persistenceUsed:
        reviewResult.persistenceUsed || runnerResult.persistenceUsed,
    emittedOutputFamilies: _sortedStrings(<String>[
      ...reviewResult.emittedOutputFamilies,
      ...runnerResult.emittedOutputFamilies,
    ]),
  );
  return base.copyWith(
    overallStatus: _overallStatusFor(
      base,
      reviewResult: reviewResult,
      consistencyResult: consistencyResult,
    ),
    phase32ARecommendation: _phase32ARecommendationFor(
      _overallStatusFor(
        base,
        reviewResult: reviewResult,
        consistencyResult: consistencyResult,
      ),
    ),
  );
}

InternalNonLabelPrototypeReadinessStatus _overallStatusFor(
  InternalNonLabelPrototypeReadinessResult result, {
  required InternalSignalObservationReviewMatrixResult reviewResult,
  required InternalSignalProfileConsistencyMatrixResult consistencyResult,
}) {
  if (reviewResult.unsafeCount > 0) {
    return InternalNonLabelPrototypeReadinessStatus.blockedByUnsafeObservation;
  }
  if (consistencyResult.blockerCount > 0 ||
      consistencyResult.criticalCount > 0) {
    return InternalNonLabelPrototypeReadinessStatus.blockedByConsistencyFailure;
  }
  if (reviewResult.unprovenAndroidCaseIds.isNotEmpty) {
    return InternalNonLabelPrototypeReadinessStatus
        .blockedByUnprovenAndroidProof;
  }
  if (_quietScopeActive(reviewResult)) {
    return InternalNonLabelPrototypeReadinessStatus.blockedByQuietScope;
  }
  final quietScope = result.scopeRecords
      .where(
        (scope) =>
            scope.scopeId ==
            InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
      )
      .single;
  if (!quietScope.isBlocked) {
    return InternalNonLabelPrototypeReadinessStatus.blockedByQuietScope;
  }
  if (result.productLabelsEmitted ||
      result.classifierLabelsEmitted ||
      result.finalMoveLabelsEmitted ||
      result.officialMetricsAllowed ||
      result.cpLossComputationImplemented ||
      result.winProbabilityComputationImplemented ||
      result.numericMoveScoresComputed ||
      result.moveRankingComputed ||
      result.directEngineAccessUsed ||
      result.uiOutputUsed ||
      result.backendOutputUsed ||
      result.persistenceUsed ||
      result.emittedOutputFamilies.any(_isForbiddenOutputName) ||
      result.scopeRecords.any(
        (scope) => _policyScopes.contains(scope.scopeId) && !scope.isBlocked,
      ) ||
      result.scopeRecords.any(
        (scope) =>
            _integrationScopes.contains(scope.scopeId) && scope.isAllowed,
      )) {
    return InternalNonLabelPrototypeReadinessStatus.blockedByPolicyBoundary;
  }
  if (!_containsAllAllowedScopes(result.allowedScopeIds)) {
    return InternalNonLabelPrototypeReadinessStatus
        .blockedByInsufficientStableObservations;
  }
  if (result.warningLimitedScopeIds.isNotEmpty ||
      result.coverageGapIds.isNotEmpty ||
      result.warnings.isNotEmpty) {
    return InternalNonLabelPrototypeReadinessStatus.readyWithCoverageWarnings;
  }
  return InternalNonLabelPrototypeReadinessStatus
      .readyForNarrowInternalPrototype;
}

InternalNonLabelPrototypeReadinessRecommendation _phase32ARecommendationFor(
  InternalNonLabelPrototypeReadinessStatus status,
) {
  return switch (status) {
    InternalNonLabelPrototypeReadinessStatus.readyForNarrowInternalPrototype ||
    InternalNonLabelPrototypeReadinessStatus.readyWithCoverageWarnings =>
      InternalNonLabelPrototypeReadinessRecommendation
          .proceedToNarrowInternalPrototype,
    InternalNonLabelPrototypeReadinessStatus
        .blockedByInsufficientStableObservations =>
      InternalNonLabelPrototypeReadinessRecommendation.addGoldenCoverageFirst,
    InternalNonLabelPrototypeReadinessStatus.blockedByConsistencyFailure =>
      InternalNonLabelPrototypeReadinessRecommendation.keepDesignOnly,
    InternalNonLabelPrototypeReadinessStatus.blockedByUnsafeObservation ||
    InternalNonLabelPrototypeReadinessStatus.blockedByPolicyBoundary ||
    InternalNonLabelPrototypeReadinessStatus.blockedByUnprovenAndroidProof ||
    InternalNonLabelPrototypeReadinessStatus.blockedByQuietScope =>
      InternalNonLabelPrototypeReadinessRecommendation
          .fixUnsafeObservationFirst,
    InternalNonLabelPrototypeReadinessStatus.invalid =>
      InternalNonLabelPrototypeReadinessRecommendation.blocked,
  };
}

List<InternalNonLabelPrototypeScopeReadinessRecord> _buildScopeRecords(
  InternalSignalObservationReviewMatrixResult reviewResult,
) {
  final rowsBySignal =
      <InternalNonLabelSignalId, InternalSignalObservationReviewRow>{
        for (final row in reviewResult.rows) row.signalId: row,
      };
  final scopes = <InternalNonLabelPrototypeScopeReadinessRecord>[
    _allowedScope(
      scopeId: InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
      row: rowsBySignal[InternalNonLabelSignalId.tacticalPressureSignal],
    ),
    _allowedScope(
      scopeId:
          InternalNonLabelPrototypeScopeId.materialSwingInternalPrototypeScope,
      row: rowsBySignal[InternalNonLabelSignalId.materialSwingSignal],
    ),
    _allowedScope(
      scopeId:
          InternalNonLabelPrototypeScopeId.forcingLineInternalPrototypeScope,
      row: rowsBySignal[InternalNonLabelSignalId.forcingLineSignal],
    ),
    _allowedScope(
      scopeId: InternalNonLabelPrototypeScopeId
          .candidateSpreadInternalPrototypeScope,
      row: rowsBySignal[InternalNonLabelSignalId.candidateSpreadSignal],
    ),
    _allowedScope(
      scopeId: InternalNonLabelPrototypeScopeId
          .pvMultiPvSupportInternalPrototypeScope,
      row: rowsBySignal[InternalNonLabelSignalId.pvMultiPvSupportSignal],
    ),
    _allowedScope(
      scopeId: InternalNonLabelPrototypeScopeId
          .androidProofConfidenceInternalPrototypeScope,
      row: rowsBySignal[InternalNonLabelSignalId.androidProofConfidenceSignal],
    ),
    _warningScope(
      scopeId:
          InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
      row: rowsBySignal[InternalNonLabelSignalId.kingSafetySignal],
    ),
    _warningScope(
      scopeId: InternalNonLabelPrototypeScopeId.endgameInternalPrototypeScope,
      row: rowsBySignal[InternalNonLabelSignalId.endgameSupportSignal],
    ),
    _warningScope(
      scopeId: InternalNonLabelPrototypeScopeId
          .suppressionSafetyInternalPrototypeScope,
      row: rowsBySignal[InternalNonLabelSignalId.suppressionSafetySignal],
    ),
    _warningScope(
      scopeId:
          InternalNonLabelPrototypeScopeId.budgetRiskInternalPrototypeScope,
      row: rowsBySignal[InternalNonLabelSignalId.budgetRiskSignal],
    ),
    _blockedScope(
      scopeId: InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
      row:
          rowsBySignal[InternalNonLabelSignalId.quietPreparatorySignalExcluded],
      blocker: 'quiet-preparatory-uncertain',
    ),
    _blockedScope(
      scopeId: InternalNonLabelPrototypeScopeId.productLabelPrototypeScope,
      row: rowsBySignal[InternalNonLabelSignalId.productLabelSignalBlocked],
      blocker: 'product-facing output remains blocked',
    ),
    _blockedScope(
      scopeId: InternalNonLabelPrototypeScopeId.advancedLabelPrototypeScope,
      row: rowsBySignal[InternalNonLabelSignalId.advancedLabelSignalBlocked],
      blocker: 'advanced output remains blocked',
    ),
    _blockedScope(
      scopeId: InternalNonLabelPrototypeScopeId.officialMetricPrototypeScope,
      row: rowsBySignal[InternalNonLabelSignalId.officialMetricSignalBlocked],
      blocker: 'official metric output remains blocked',
    ),
    _futureScope(
      scopeId: InternalNonLabelPrototypeScopeId.cpLossPrototypeScope,
      row: rowsBySignal[InternalNonLabelSignalId.cpLossSignalFutureOnly],
      blocker: 'CP-loss computation remains future-only',
    ),
    _futureScope(
      scopeId: InternalNonLabelPrototypeScopeId.winProbabilityPrototypeScope,
      row:
          rowsBySignal[InternalNonLabelSignalId.winProbabilitySignalFutureOnly],
      blocker: 'win-probability computation remains future-only',
    ),
    _integrationBlockedScope(
      InternalNonLabelPrototypeScopeId.uiProductIntegrationScope,
      'UI and product integration remain blocked',
    ),
    _integrationBlockedScope(
      InternalNonLabelPrototypeScopeId.backendIntegrationScope,
      'backend integration remains blocked',
    ),
    _integrationBlockedScope(
      InternalNonLabelPrototypeScopeId.persistenceScope,
      'persistence integration remains blocked',
    ),
    _integrationBlockedScope(
      InternalNonLabelPrototypeScopeId.directEngineAccessScope,
      'direct engine access remains blocked',
    ),
  ];
  return List<InternalNonLabelPrototypeScopeReadinessRecord>.unmodifiable(
    scopes..sort((a, b) => a.scopeId.index.compareTo(b.scopeId.index)),
  );
}

InternalNonLabelPrototypeScopeReadinessRecord _allowedScope({
  required InternalNonLabelPrototypeScopeId scopeId,
  required InternalSignalObservationReviewRow? row,
}) {
  if (row == null || !row.isStable) {
    return _invalidScope(scopeId, 'missing stable observation');
  }
  final readiness =
      row.status == InternalSignalObservationReviewStatus.stableWithWarnings
      ? InternalNonLabelPrototypeScopeReadiness.allowedWithWarnings
      : InternalNonLabelPrototypeScopeReadiness.allowedInternalOnly;
  return InternalNonLabelPrototypeScopeReadinessRecord(
    scopeId: scopeId,
    readiness: readiness,
    signalId: row.signalId,
    observationStatus: row.status,
    supportCaseIds: row.supportCaseIds,
    androidProofCaseIds: row.androidProofCaseIds,
    coverageGapIds:
        readiness == InternalNonLabelPrototypeScopeReadiness.allowedWithWarnings
        ? <String>[scopeId.wire]
        : const <String>[],
    policyBlockers: const <String>[],
    warningReason: row.warningReason.isNotEmpty
        ? row.warningReason
        : row.futurePrerequisite,
    recommendation: InternalNonLabelPrototypeReadinessRecommendation
        .proceedToNarrowInternalPrototype,
  );
}

InternalNonLabelPrototypeScopeReadinessRecord _warningScope({
  required InternalNonLabelPrototypeScopeId scopeId,
  required InternalSignalObservationReviewRow? row,
}) {
  if (row == null) {
    return _invalidScope(scopeId, 'missing warning observation');
  }
  return InternalNonLabelPrototypeScopeReadinessRecord(
    scopeId: scopeId,
    readiness: InternalNonLabelPrototypeScopeReadiness.warningLimited,
    signalId: row.signalId,
    observationStatus: row.status,
    supportCaseIds: row.supportCaseIds,
    androidProofCaseIds: row.androidProofCaseIds,
    coverageGapIds: <String>[scopeId.wire],
    policyBlockers: const <String>[],
    warningReason: row.warningReason.isNotEmpty
        ? row.warningReason
        : row.futurePrerequisite,
    recommendation:
        InternalNonLabelPrototypeReadinessRecommendation.addGoldenCoverageFirst,
  );
}

InternalNonLabelPrototypeScopeReadinessRecord _blockedScope({
  required InternalNonLabelPrototypeScopeId scopeId,
  required InternalSignalObservationReviewRow? row,
  required String blocker,
}) {
  return InternalNonLabelPrototypeScopeReadinessRecord(
    scopeId: scopeId,
    readiness: InternalNonLabelPrototypeScopeReadiness.blocked,
    signalId: row?.signalId,
    observationStatus: row?.status,
    supportCaseIds: row?.supportCaseIds ?? const <String>[],
    androidProofCaseIds: row?.androidProofCaseIds ?? const <String>[],
    coverageGapIds: const <String>[],
    policyBlockers: <String>[blocker],
    warningReason: '',
    recommendation: InternalNonLabelPrototypeReadinessRecommendation.blocked,
  );
}

InternalNonLabelPrototypeScopeReadinessRecord _futureScope({
  required InternalNonLabelPrototypeScopeId scopeId,
  required InternalSignalObservationReviewRow? row,
  required String blocker,
}) {
  return InternalNonLabelPrototypeScopeReadinessRecord(
    scopeId: scopeId,
    readiness: InternalNonLabelPrototypeScopeReadiness.futureOnly,
    signalId: row?.signalId,
    observationStatus: row?.status,
    supportCaseIds: row?.supportCaseIds ?? const <String>[],
    androidProofCaseIds: row?.androidProofCaseIds ?? const <String>[],
    coverageGapIds: const <String>[],
    policyBlockers: <String>[blocker],
    warningReason: '',
    recommendation: InternalNonLabelPrototypeReadinessRecommendation.blocked,
  );
}

InternalNonLabelPrototypeScopeReadinessRecord _integrationBlockedScope(
  InternalNonLabelPrototypeScopeId scopeId,
  String blocker,
) {
  return InternalNonLabelPrototypeScopeReadinessRecord(
    scopeId: scopeId,
    readiness: InternalNonLabelPrototypeScopeReadiness.blocked,
    signalId: null,
    observationStatus: null,
    supportCaseIds: const <String>[],
    androidProofCaseIds: const <String>[],
    coverageGapIds: const <String>[],
    policyBlockers: <String>[blocker],
    warningReason: '',
    recommendation: InternalNonLabelPrototypeReadinessRecommendation.blocked,
  );
}

InternalNonLabelPrototypeScopeReadinessRecord _invalidScope(
  InternalNonLabelPrototypeScopeId scopeId,
  String reason,
) {
  return InternalNonLabelPrototypeScopeReadinessRecord(
    scopeId: scopeId,
    readiness: InternalNonLabelPrototypeScopeReadiness.invalid,
    signalId: null,
    observationStatus: null,
    supportCaseIds: const <String>[],
    androidProofCaseIds: const <String>[],
    coverageGapIds: <String>[scopeId.wire],
    policyBlockers: <String>[reason],
    warningReason: reason,
    recommendation:
        InternalNonLabelPrototypeReadinessRecommendation.addGoldenCoverageFirst,
  );
}

bool _containsAllAllowedScopes(
  Iterable<InternalNonLabelPrototypeScopeId> scopeIds,
) {
  final values = scopeIds.toSet();
  return _requiredAllowedScopes.every(values.contains);
}

bool _quietScopeActive(InternalSignalObservationReviewMatrixResult result) {
  try {
    final row = result.row(
      InternalNonLabelSignalId.quietPreparatorySignalExcluded,
    );
    return row.observed ||
        row.status != InternalSignalObservationReviewStatus.excludedCorrectly;
  } on StateError {
    return true;
  }
}

String _ids(Iterable<String> values) {
  final sorted = _sortedStrings(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

String _scopeIds(Iterable<InternalNonLabelPrototypeScopeId> values) {
  final ids = values.map((id) => id.wire).toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _signalIds(Iterable<InternalNonLabelSignalId> values) {
  final ids = values.map((id) => id.wire).toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.toSet().toList()..sort();
}

List<InternalNonLabelPrototypeScopeId> _sortedScopeIds(
  Iterable<InternalNonLabelPrototypeScopeId> values,
) {
  return values.toSet().toList()..sort((a, b) => a.index.compareTo(b.index));
}

List<InternalNonLabelSignalId> _sortedSignalIds(
  Iterable<InternalNonLabelSignalId> values,
) {
  return values.toSet().toList()..sort((a, b) => a.index.compareTo(b.index));
}

int _compareFindings(
  InternalNonLabelPrototypeReadinessValidationFinding a,
  InternalNonLabelPrototypeReadinessValidationFinding b,
) {
  final idCompare = a.id.compareTo(b.id);
  if (idCompare != 0) return idCompare;
  final scopeCompare = (a.scopeId?.wire ?? '').compareTo(b.scopeId?.wire ?? '');
  if (scopeCompare != 0) return scopeCompare;
  final signalCompare = (a.signalId?.wire ?? '').compareTo(
    b.signalId?.wire ?? '',
  );
  if (signalCompare != 0) return signalCompare;
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

const _requiredAllowedScopes = <InternalNonLabelPrototypeScopeId>{
  InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.materialSwingInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.forcingLineInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.candidateSpreadInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.androidProofConfidenceInternalPrototypeScope,
};

const _policyScopes = <InternalNonLabelPrototypeScopeId>{
  InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
  InternalNonLabelPrototypeScopeId.productLabelPrototypeScope,
  InternalNonLabelPrototypeScopeId.advancedLabelPrototypeScope,
  InternalNonLabelPrototypeScopeId.officialMetricPrototypeScope,
  InternalNonLabelPrototypeScopeId.cpLossPrototypeScope,
  InternalNonLabelPrototypeScopeId.winProbabilityPrototypeScope,
};

const _integrationScopes = <InternalNonLabelPrototypeScopeId>{
  InternalNonLabelPrototypeScopeId.uiProductIntegrationScope,
  InternalNonLabelPrototypeScopeId.backendIntegrationScope,
  InternalNonLabelPrototypeScopeId.persistenceScope,
  InternalNonLabelPrototypeScopeId.directEngineAccessScope,
};

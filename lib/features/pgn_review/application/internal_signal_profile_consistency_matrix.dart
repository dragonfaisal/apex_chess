/// Developer-only consistency matrix over internal non-label signal profiles.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_review.dart';
import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_guards.dart';
import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_harness.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_scoring_design.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';

const internalSignalProfileConsistencyMatrixReportVersion =
    'internal-signal-profile-consistency-matrix-v1';

enum InternalSignalProfileConsistencyCheckId {
  activeSignalHasSupportCases('activeSignalHasSupportCases'),
  activeSignalHasSourceDimension('activeSignalHasSourceDimension'),
  activeSignalHasEvidenceArea('activeSignalHasEvidenceArea'),
  warningSignalHasWarningReason('warningSignalHasWarningReason'),
  partialSignalHasFuturePrerequisite('partialSignalHasFuturePrerequisite'),
  androidProofSignalUsesCapturedIdsOnly(
    'androidProofSignalUsesCapturedIdsOnly',
  ),
  pvMultiPvSignalUsesProofOrPvSupport('pvMultiPvSignalUsesProofOrPvSupport'),
  candidateSpreadSignalHasSpreadSupport(
    'candidateSpreadSignalHasSpreadSupport',
  ),
  suppressionSignalShowsPartialCoverage(
    'suppressionSignalShowsPartialCoverage',
  ),
  budgetRiskSignalStaysWarningOnly('budgetRiskSignalStaysWarningOnly'),
  quietPreparatorySignalRemainsExcluded(
    'quietPreparatorySignalRemainsExcluded',
  ),
  productLabelSignalRemainsBlocked('productLabelSignalRemainsBlocked'),
  advancedLabelSignalRemainsBlocked('advancedLabelSignalRemainsBlocked'),
  officialMetricSignalRemainsBlocked('officialMetricSignalRemainsBlocked'),
  cpLossSignalRemainsFutureOnly('cpLossSignalRemainsFutureOnly'),
  winProbabilitySignalRemainsFutureOnly(
    'winProbabilitySignalRemainsFutureOnly',
  ),
  noSignalEmitsMoveLabel('noSignalEmitsMoveLabel'),
  noSignalEmitsNumericScore('noSignalEmitsNumericScore'),
  noSignalRanksMoves('noSignalRanksMoves'),
  noRawUciOrPvDumpInReports('noRawUciOrPvDumpInReports');

  const InternalSignalProfileConsistencyCheckId(this.wire);

  final String wire;
}

enum InternalSignalProfileConsistencyStatus {
  consistent('consistent'),
  consistentWithWarnings('consistentWithWarnings'),
  inconsistent('inconsistent'),
  blockedCorrectly('blockedCorrectly'),
  excludedCorrectly('excludedCorrectly'),
  futureOnlyCorrectly('futureOnlyCorrectly'),
  missingSupport('missingSupport'),
  invalid('invalid');

  const InternalSignalProfileConsistencyStatus(this.wire);

  final String wire;
}

enum InternalSignalProfileConsistencySeverity {
  none('none'),
  info('info'),
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const InternalSignalProfileConsistencySeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == InternalSignalProfileConsistencySeverity.blocker ||
      this == InternalSignalProfileConsistencySeverity.critical;
}

enum InternalSignalProfileConsistencyMatrixStatus {
  consistentInternalOnly('consistentInternalOnly'),
  consistentWithWarnings('consistentWithWarnings'),
  blockedByProfile('blockedByProfile'),
  blockedByValidation('blockedByValidation'),
  invalid('invalid');

  const InternalSignalProfileConsistencyMatrixStatus(this.wire);

  final String wire;
}

enum InternalSignalProfileConsistencyRecommendation {
  keepStable('keepStable'),
  keepWarningLimited('keepWarningLimited'),
  addGoldenSupport('addGoldenSupport'),
  restoreSourceMapping('restoreSourceMapping'),
  keepExcludedByNegativeGuard('keepExcludedByNegativeGuard'),
  keepBlockedByPolicy('keepBlockedByPolicy'),
  keepFutureOnly('keepFutureOnly'),
  removeForbiddenOutput('removeForbiddenOutput'),
  removeUnprovenAndroidProof('removeUnprovenAndroidProof'),
  avoidCombiningWithoutProof('avoidCombiningWithoutProof'),
  investigateMismatch('investigateMismatch');

  const InternalSignalProfileConsistencyRecommendation(this.wire);

  final String wire;
}

enum InternalSignalProfileConsistencyReportFormat {
  markdown('markdown'),
  json('json');

  const InternalSignalProfileConsistencyReportFormat(this.wire);

  final String wire;
}

enum InternalSignalProfileConsistencyNextPhase {
  guardedInternalSignalProfileExperiments(
    'Phase 31J -- Guarded Internal Non-Label Signal Profile Experiments',
  ),
  consistencyEvidenceFixes('Phase 31J -- Signal Consistency Evidence Fixes');

  const InternalSignalProfileConsistencyNextPhase(this.wire);

  final String wire;
}

class InternalSignalProfileConsistencyMatrixRequest {
  const InternalSignalProfileConsistencyMatrixRequest({
    this.profileResult,
    this.profileRequest,
    this.designResult,
    this.matrixRequest = const InternalEvidenceAreaCoverageMatrixRequest(),
    this.matrixResult,
    this.harnessResult,
    this.review,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.cases = GoldenAnalysisCases.defaults,
    this.profile = const InternalNonLabelSignalProfilePrototype(),
  });

  final InternalNonLabelSignalProfileResult? profileResult;
  final InternalNonLabelSignalProfileRequest? profileRequest;
  final InternalNonLabelScoringDesignResult? designResult;
  final InternalEvidenceAreaCoverageMatrixRequest matrixRequest;
  final InternalEvidenceAreaCoverageMatrixResult? matrixResult;
  final InternalBucketExperimentHarnessResult? harnessResult;
  final GoldenEvidenceReviewResult? review;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final List<GoldenAnalysisCase> cases;
  final InternalNonLabelSignalProfilePrototype profile;
}

class InternalSignalProfileConsistencyRow {
  const InternalSignalProfileConsistencyRow({
    required this.checkId,
    required this.status,
    required this.severity,
    required this.signalIds,
    required this.relatedDimensionIds,
    required this.relatedAreaIds,
    required this.relatedBucketIds,
    required this.supportCaseIds,
    required this.androidProofCaseIds,
    required this.warningReason,
    required this.blockerReason,
    required this.recommendation,
  });

  final InternalSignalProfileConsistencyCheckId checkId;
  final InternalSignalProfileConsistencyStatus status;
  final InternalSignalProfileConsistencySeverity severity;
  final List<InternalNonLabelSignalId> signalIds;
  final List<InternalNonLabelScoringDimensionId> relatedDimensionIds;
  final List<InternalEvidenceAreaId> relatedAreaIds;
  final List<InternalEvidenceBucketId> relatedBucketIds;
  final List<String> supportCaseIds;
  final List<String> androidProofCaseIds;
  final String warningReason;
  final String blockerReason;
  final InternalSignalProfileConsistencyRecommendation recommendation;

  bool get isWarning =>
      severity == InternalSignalProfileConsistencySeverity.warning;

  bool get isBlocker =>
      severity == InternalSignalProfileConsistencySeverity.blocker;

  bool get isCritical =>
      severity == InternalSignalProfileConsistencySeverity.critical;

  bool get isConsistent =>
      status == InternalSignalProfileConsistencyStatus.consistent ||
      status == InternalSignalProfileConsistencyStatus.consistentWithWarnings ||
      status == InternalSignalProfileConsistencyStatus.blockedCorrectly ||
      status == InternalSignalProfileConsistencyStatus.excludedCorrectly ||
      status == InternalSignalProfileConsistencyStatus.futureOnlyCorrectly;

  InternalSignalProfileConsistencyRow copyWith({
    InternalSignalProfileConsistencyCheckId? checkId,
    InternalSignalProfileConsistencyStatus? status,
    InternalSignalProfileConsistencySeverity? severity,
    List<InternalNonLabelSignalId>? signalIds,
    List<InternalNonLabelScoringDimensionId>? relatedDimensionIds,
    List<InternalEvidenceAreaId>? relatedAreaIds,
    List<InternalEvidenceBucketId>? relatedBucketIds,
    List<String>? supportCaseIds,
    List<String>? androidProofCaseIds,
    String? warningReason,
    String? blockerReason,
    InternalSignalProfileConsistencyRecommendation? recommendation,
  }) {
    return InternalSignalProfileConsistencyRow(
      checkId: checkId ?? this.checkId,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      signalIds: signalIds ?? this.signalIds,
      relatedDimensionIds: relatedDimensionIds ?? this.relatedDimensionIds,
      relatedAreaIds: relatedAreaIds ?? this.relatedAreaIds,
      relatedBucketIds: relatedBucketIds ?? this.relatedBucketIds,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      warningReason: warningReason ?? this.warningReason,
      blockerReason: blockerReason ?? this.blockerReason,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'checkId': checkId.wire,
      'status': status.wire,
      'severity': severity.wire,
      'signalIds': signalIds.map((id) => id.wire).toList(growable: false),
      'relatedDimensionIds': relatedDimensionIds
          .map((id) => id.wire)
          .toList(growable: false),
      'relatedAreaIds': relatedAreaIds
          .map((id) => id.wire)
          .toList(growable: false),
      'relatedBucketIds': relatedBucketIds
          .map((id) => id.wire)
          .toList(growable: false),
      'supportCaseIds': supportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'warningReason': warningReason,
      'blockerReason': blockerReason,
      'recommendation': recommendation.wire,
    };
  }
}

class InternalSignalProfileConsistencyValidationFinding {
  const InternalSignalProfileConsistencyValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.checkId,
    this.signalId,
    this.caseId,
  });

  final String id;
  final InternalSignalProfileConsistencySeverity severity;
  final String message;
  final InternalSignalProfileConsistencyCheckId? checkId;
  final InternalNonLabelSignalId? signalId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical =>
      severity == InternalSignalProfileConsistencySeverity.critical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (checkId != null) 'checkId': checkId!.wire,
      if (signalId != null) 'signalId': signalId!.wire,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class InternalSignalProfileConsistencyMatrixResult {
  const InternalSignalProfileConsistencyMatrixResult({
    required this.matrixStatus,
    required this.profileStatus,
    required this.scoringDesignStatus,
    required this.coverageMatrixStatus,
    required this.harnessStatus,
    required this.guardStatus,
    required this.guardAllowed,
    required this.rows,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalChecks,
    required this.consistentCount,
    required this.warningCount,
    required this.blockerCount,
    required this.criticalCount,
    required this.activeSignalsChecked,
    required this.blockedSignalsChecked,
    required this.excludedSignalsChecked,
    required this.futureOnlySignalsChecked,
    required this.safeForGuardedInternalExperiment,
    required this.nextRecommendation,
    required this.provenAndroidCaseIds,
    required this.unprovenAndroidCaseIds,
    required this.excludedScopeIds,
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

  final InternalSignalProfileConsistencyMatrixStatus matrixStatus;
  final InternalNonLabelSignalProfileStatus profileStatus;
  final InternalNonLabelScoringDesignStatus scoringDesignStatus;
  final InternalEvidenceAreaCoverageMatrixStatus coverageMatrixStatus;
  final InternalBucketExperimentHarnessStatus harnessStatus;
  final InternalBucketExperimentGuardStatus guardStatus;
  final bool guardAllowed;
  final List<InternalSignalProfileConsistencyRow> rows;
  final List<InternalSignalProfileConsistencyValidationFinding>
  validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalChecks;
  final int consistentCount;
  final int warningCount;
  final int blockerCount;
  final int criticalCount;
  final int activeSignalsChecked;
  final int blockedSignalsChecked;
  final int excludedSignalsChecked;
  final int futureOnlySignalsChecked;
  final bool safeForGuardedInternalExperiment;
  final InternalSignalProfileConsistencyNextPhase nextRecommendation;
  final List<String> provenAndroidCaseIds;
  final List<String> unprovenAndroidCaseIds;
  final List<String> excludedScopeIds;
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
      matrixStatus ==
          InternalSignalProfileConsistencyMatrixStatus.blockedByProfile ||
      matrixStatus ==
          InternalSignalProfileConsistencyMatrixStatus.blockedByValidation ||
      matrixStatus == InternalSignalProfileConsistencyMatrixStatus.invalid ||
      blockerCount > 0 ||
      criticalCount > 0 ||
      !safeForGuardedInternalExperiment;

  bool get hasUnsafeConsistencyPolicyViolation {
    return criticalCount > 0 ||
        validationFindings.any((finding) => finding.isCritical) ||
        unprovenAndroidCaseIds.isNotEmpty ||
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
        emittedOutputFamilies.any(_isForbiddenOutputName);
  }

  InternalSignalProfileConsistencyRow row(
    InternalSignalProfileConsistencyCheckId id,
  ) {
    return rows.singleWhere((row) => row.checkId == id);
  }

  InternalSignalProfileConsistencyMatrixResult copyWith({
    InternalSignalProfileConsistencyMatrixStatus? matrixStatus,
    InternalNonLabelSignalProfileStatus? profileStatus,
    InternalNonLabelScoringDesignStatus? scoringDesignStatus,
    InternalEvidenceAreaCoverageMatrixStatus? coverageMatrixStatus,
    InternalBucketExperimentHarnessStatus? harnessStatus,
    InternalBucketExperimentGuardStatus? guardStatus,
    bool? guardAllowed,
    List<InternalSignalProfileConsistencyRow>? rows,
    List<InternalSignalProfileConsistencyValidationFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalChecks,
    int? consistentCount,
    int? warningCount,
    int? blockerCount,
    int? criticalCount,
    int? activeSignalsChecked,
    int? blockedSignalsChecked,
    int? excludedSignalsChecked,
    int? futureOnlySignalsChecked,
    bool? safeForGuardedInternalExperiment,
    InternalSignalProfileConsistencyNextPhase? nextRecommendation,
    List<String>? provenAndroidCaseIds,
    List<String>? unprovenAndroidCaseIds,
    List<String>? excludedScopeIds,
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
    final effectiveRows = rows ?? this.rows;
    return InternalSignalProfileConsistencyMatrixResult(
      matrixStatus: matrixStatus ?? this.matrixStatus,
      profileStatus: profileStatus ?? this.profileStatus,
      scoringDesignStatus: scoringDesignStatus ?? this.scoringDesignStatus,
      coverageMatrixStatus: coverageMatrixStatus ?? this.coverageMatrixStatus,
      harnessStatus: harnessStatus ?? this.harnessStatus,
      guardStatus: guardStatus ?? this.guardStatus,
      guardAllowed: guardAllowed ?? this.guardAllowed,
      rows: effectiveRows,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalChecks: totalChecks ?? effectiveRows.length,
      consistentCount: consistentCount ?? this.consistentCount,
      warningCount: warningCount ?? this.warningCount,
      blockerCount: blockerCount ?? this.blockerCount,
      criticalCount: criticalCount ?? this.criticalCount,
      activeSignalsChecked: activeSignalsChecked ?? this.activeSignalsChecked,
      blockedSignalsChecked:
          blockedSignalsChecked ?? this.blockedSignalsChecked,
      excludedSignalsChecked:
          excludedSignalsChecked ?? this.excludedSignalsChecked,
      futureOnlySignalsChecked:
          futureOnlySignalsChecked ?? this.futureOnlySignalsChecked,
      safeForGuardedInternalExperiment:
          safeForGuardedInternalExperiment ??
          this.safeForGuardedInternalExperiment,
      nextRecommendation: nextRecommendation ?? this.nextRecommendation,
      provenAndroidCaseIds: provenAndroidCaseIds ?? this.provenAndroidCaseIds,
      unprovenAndroidCaseIds:
          unprovenAndroidCaseIds ?? this.unprovenAndroidCaseIds,
      excludedScopeIds: excludedScopeIds ?? this.excludedScopeIds,
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
    final warningRows = rows
        .where(
          (row) =>
              row.severity == InternalSignalProfileConsistencySeverity.warning,
        )
        .toList(growable: false);
    final blockerRows = rows
        .where((row) => row.severity.blocksStrict)
        .toList(growable: false);
    final buffer = StringBuffer()
      ..writeln('# Internal Signal Profile Consistency Matrix')
      ..writeln()
      ..writeln(
        '- version: $internalSignalProfileConsistencyMatrixReportVersion',
      )
      ..writeln('- matrix status: ${matrixStatus.wire}')
      ..writeln('- profile status: ${profileStatus.wire}')
      ..writeln('- scoring design status: ${scoringDesignStatus.wire}')
      ..writeln('- coverage matrix status: ${coverageMatrixStatus.wire}')
      ..writeln('- harness status: ${harnessStatus.wire}')
      ..writeln('- guard status: ${guardStatus.wire}')
      ..writeln('- guard allowed: $guardAllowed')
      ..writeln('- total checks: $totalChecks')
      ..writeln('- consistent checks: $consistentCount')
      ..writeln('- warning checks: $warningCount')
      ..writeln('- blocker checks: $blockerCount')
      ..writeln('- critical checks: $criticalCount')
      ..writeln(
        '- safe for guarded internal experiment: '
        '$safeForGuardedInternalExperiment',
      )
      ..writeln('- classifier output emitted: false')
      ..writeln('- numeric score values emitted: false')
      ..writeln('- move ranking emitted: false')
      ..writeln()
      ..writeln('## Consistency Policy')
      ..writeln(
        '- consistency checks require active internal signals to keep source '
        'dimensions, evidence areas, buckets, and Golden support cases',
      )
      ..writeln(
        '- warning and partial signals must keep visible caution reasons and '
        'future prerequisites before later internal experiments consume them',
      )
      ..writeln(
        '- blocked, excluded, and future-only signals must remain inactive; '
        'this matrix emits no labels, scores, rankings, metrics, engine calls, '
        'or writes',
      )
      ..writeln()
      ..writeln('## Consistency Check Table')
      ..writeln(
        '| Check | Status | Severity | Signals | Support Cases | Android Proof | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- |');

    for (final row in rows) {
      buffer.writeln(
        '| ${row.checkId.wire} | ${row.status.wire} | ${row.severity.wire} | '
        '${_signalIds(row.signalIds)} | ${_ids(row.supportCaseIds)} | '
        '${_ids(row.androidProofCaseIds)} | ${row.recommendation.wire} |',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Active Signal Checks')
      ..writeln(
        '- active signals checked: '
        '${_signalIds(_activeSignalIdsFromRows(rows))}',
      )
      ..writeln(
        '- source dimensions checked: '
        '${_dimensionIds(_dimensionIdsFromRows(rows))}',
      )
      ..writeln('- evidence areas checked: ${_areaIds(_areaIdsFromRows(rows))}')
      ..writeln()
      ..writeln('## Warning And Partial Signal Checks');
    if (warningRows.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final row in warningRows) {
        buffer.writeln(
          '- ${row.checkId.wire}: ${row.warningReason.isEmpty ? row.status.wire : row.warningReason}',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('## Blocked Excluded And Future Checks')
      ..writeln('- blocked signals checked: $blockedSignalsChecked')
      ..writeln('- excluded signals checked: $excludedSignalsChecked')
      ..writeln('- future-only signals checked: $futureOnlySignalsChecked')
      ..writeln('- quiet/preparatory exclusion: ${_ids(excludedScopeIds)}')
      ..writeln()
      ..writeln('## Android Proof Validity')
      ..writeln('- proven case IDs: ${_ids(provenAndroidCaseIds)}')
      ..writeln('- unproven case IDs: ${_ids(unprovenAndroidCaseIds)}')
      ..writeln()
      ..writeln('## Support Cases');
    for (final row in rows) {
      if (row.supportCaseIds.isNotEmpty) {
        buffer.writeln('- ${row.checkId.wire}: ${_ids(row.supportCaseIds)}');
      }
    }

    buffer
      ..writeln()
      ..writeln('## Warnings And Blockers');
    if (warningRows.isEmpty && blockerRows.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final row in warningRows) {
        buffer.writeln('- warning ${row.checkId.wire}: ${row.warningReason}');
      }
      for (final row in blockerRows) {
        buffer.writeln(
          '- ${row.severity.wire} ${row.checkId.wire}: ${row.blockerReason}',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('## Validation');
    if (validationFindings.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final finding in validationFindings) {
        buffer.writeln('- ${finding.severity.wire}: ${finding.id}');
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
      ..writeln('## Next Recommendation')
      ..writeln(nextRecommendation.wire)
      ..writeln()
      ..writeln(
        'This matrix checks internal signal consistency only. It does not '
        'judge move quality, emit user-facing output, compute product metrics, '
        'call the engine, run Android, or write files.',
      );

    return buffer.toString();
  }

  String renderJsonReport() {
    final payload = <String, Object?>{
      'version': internalSignalProfileConsistencyMatrixReportVersion,
      'matrixStatus': matrixStatus.wire,
      'profileStatus': profileStatus.wire,
      'scoringDesignStatus': scoringDesignStatus.wire,
      'coverageMatrixStatus': coverageMatrixStatus.wire,
      'harnessStatus': harnessStatus.wire,
      'guardStatus': guardStatus.wire,
      'guardAllowed': guardAllowed,
      'totalChecks': totalChecks,
      'consistentCount': consistentCount,
      'warningCount': warningCount,
      'blockerCount': blockerCount,
      'criticalCount': criticalCount,
      'activeSignalsChecked': activeSignalsChecked,
      'blockedSignalsChecked': blockedSignalsChecked,
      'excludedSignalsChecked': excludedSignalsChecked,
      'futureOnlySignalsChecked': futureOnlySignalsChecked,
      'safeForGuardedInternalExperiment': safeForGuardedInternalExperiment,
      'rows': rows.map((row) => row.toJson()).toList(growable: false),
      'validationFindings': validationFindings
          .map((finding) => finding.toJson())
          .toList(growable: false),
      'warnings': warnings,
      'failures': failures,
      'nextRecommendation': nextRecommendation.wire,
      'provenAndroidCaseIds': provenAndroidCaseIds,
      'unprovenAndroidCaseIds': unprovenAndroidCaseIds,
      'excludedScopeIds': excludedScopeIds,
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
    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}

class InternalSignalProfileConsistencyMatrix {
  const InternalSignalProfileConsistencyMatrix({
    this.validator = const InternalSignalProfileConsistencyMatrixValidator(),
  });

  final InternalSignalProfileConsistencyMatrixValidator validator;

  InternalSignalProfileConsistencyMatrixResult evaluate(
    InternalSignalProfileConsistencyMatrixRequest request,
  ) {
    final profileResult =
        request.profileResult ??
        request.profile.evaluate(
          request.profileRequest ??
              InternalNonLabelSignalProfileRequest(
                designResult: request.designResult,
                matrixRequest: request.matrixRequest,
                matrixResult: request.matrixResult,
                harnessResult: request.harnessResult,
                review: request.review,
                androidProofEvidence: request.androidProofEvidence,
                cases: request.cases,
              ),
        );

    if (profileResult.isStrictlyBlocked) {
      return _blockedByProfileResult(profileResult);
    }

    final rows = _buildRows(profileResult);
    final base = _resultFromRows(profileResult, rows);
    final findings = validator.validate(base, profileResult: profileResult);
    final status = _matrixStatusFor(base, findings);
    final strictSafe =
        base.blockerCount == 0 &&
        base.criticalCount == 0 &&
        findings.every((finding) => !finding.blocksStrict) &&
        !profileResult.hasUnsafeSignalProfilePolicyViolation;
    return base.copyWith(
      matrixStatus: status,
      validationFindings: findings,
      safeForGuardedInternalExperiment: strictSafe,
      nextRecommendation: strictSafe
          ? InternalSignalProfileConsistencyNextPhase
                .guardedInternalSignalProfileExperiments
          : InternalSignalProfileConsistencyNextPhase.consistencyEvidenceFixes,
    );
  }
}

class InternalSignalProfileConsistencyMatrixValidator {
  const InternalSignalProfileConsistencyMatrixValidator();

  List<InternalSignalProfileConsistencyValidationFinding> validate(
    InternalSignalProfileConsistencyMatrixResult result, {
    required InternalNonLabelSignalProfileResult profileResult,
  }) {
    final findings = <InternalSignalProfileConsistencyValidationFinding>[];

    void add({
      required String id,
      required InternalSignalProfileConsistencySeverity severity,
      required String message,
      InternalSignalProfileConsistencyCheckId? checkId,
      InternalNonLabelSignalId? signalId,
      String? caseId,
    }) {
      findings.add(
        InternalSignalProfileConsistencyValidationFinding(
          id: id,
          severity: severity,
          message: message,
          checkId: checkId,
          signalId: signalId,
          caseId: caseId,
        ),
      );
    }

    for (final signal in profileResult.signals) {
      if (signal.isActive && signal.supportingCaseIds.isEmpty) {
        add(
          id: 'activeSignalWithoutSupport',
          severity: InternalSignalProfileConsistencySeverity.blocker,
          message: '${signal.signalId.wire} has no support cases',
          checkId: InternalSignalProfileConsistencyCheckId
              .activeSignalHasSupportCases,
          signalId: signal.signalId,
        );
      }
      if (signal.isActive && signal.sourceDimensionIds.isEmpty) {
        add(
          id: 'activeSignalWithoutSourceDimension',
          severity: InternalSignalProfileConsistencySeverity.blocker,
          message: '${signal.signalId.wire} has no source dimension',
          checkId: InternalSignalProfileConsistencyCheckId
              .activeSignalHasSourceDimension,
          signalId: signal.signalId,
        );
      }
      if (signal.isActive && signal.relatedAreaIds.isEmpty) {
        add(
          id: 'activeSignalWithoutEvidenceArea',
          severity: InternalSignalProfileConsistencySeverity.blocker,
          message: '${signal.signalId.wire} has no evidence area',
          checkId: InternalSignalProfileConsistencyCheckId
              .activeSignalHasEvidenceArea,
          signalId: signal.signalId,
        );
      }
      if (signal.status == InternalNonLabelSignalStatus.activeWithWarnings &&
          signal.warningReasons.isEmpty &&
          signal.futurePrerequisites.isEmpty) {
        add(
          id: 'warningSignalWithoutReason',
          severity: InternalSignalProfileConsistencySeverity.blocker,
          message: '${signal.signalId.wire} has no warning reason',
          checkId: InternalSignalProfileConsistencyCheckId
              .warningSignalHasWarningReason,
          signalId: signal.signalId,
        );
      }
      if (signal.status == InternalNonLabelSignalStatus.partial &&
          signal.futurePrerequisites.isEmpty) {
        add(
          id: 'partialSignalWithoutFuturePrerequisite',
          severity: InternalSignalProfileConsistencySeverity.blocker,
          message: '${signal.signalId.wire} has no future prerequisite',
          checkId: InternalSignalProfileConsistencyCheckId
              .partialSignalHasFuturePrerequisite,
          signalId: signal.signalId,
        );
      }
      if (signal.quietScopeActive) {
        add(
          id: 'quietSignalBecameActive',
          severity: InternalSignalProfileConsistencySeverity.critical,
          message: '${signal.signalId.wire} activated quiet scope',
          checkId: InternalSignalProfileConsistencyCheckId
              .quietPreparatorySignalRemainsExcluded,
          signalId: signal.signalId,
        );
      }
      if (signal.productLabelsActive ||
          signal.advancedLabelsActive ||
          signal.officialMetricsActive ||
          signal.claimsOfficialMetrics) {
        add(
          id: 'blockedSignalBecameActive',
          severity: InternalSignalProfileConsistencySeverity.critical,
          message: '${signal.signalId.wire} crossed a blocked policy boundary',
          signalId: signal.signalId,
        );
      }
      if (signal.cpLossComputationImplemented ||
          signal.winProbabilityComputationImplemented) {
        add(
          id: 'futureComputationMarkedImplemented',
          severity: InternalSignalProfileConsistencySeverity.critical,
          message: '${signal.signalId.wire} marked future computation active',
          signalId: signal.signalId,
        );
      }
      if (signal.emitsProductLabel ||
          signal.emitsClassifierLabel ||
          signal.emitsFinalMoveLabel ||
          signal.emittedOutputNames.any(_isForbiddenOutputName)) {
        add(
          id: 'signalEmitsForbiddenLabel',
          severity: InternalSignalProfileConsistencySeverity.critical,
          message: '${signal.signalId.wire} emitted a forbidden output',
          checkId:
              InternalSignalProfileConsistencyCheckId.noSignalEmitsMoveLabel,
          signalId: signal.signalId,
        );
      }
      if (signal.hasNumericMoveScore) {
        add(
          id: 'signalEmitsNumericScore',
          severity: InternalSignalProfileConsistencySeverity.critical,
          message: '${signal.signalId.wire} emitted a numeric score',
          checkId:
              InternalSignalProfileConsistencyCheckId.noSignalEmitsNumericScore,
          signalId: signal.signalId,
        );
      }
      if (signal.ranksMoves) {
        add(
          id: 'signalRanksMoves',
          severity: InternalSignalProfileConsistencySeverity.critical,
          message: '${signal.signalId.wire} ranked moves',
          checkId: InternalSignalProfileConsistencyCheckId.noSignalRanksMoves,
          signalId: signal.signalId,
        );
      }
      for (final caseId in signal.androidProofCaseIds) {
        if (!profileResult.provenAndroidCaseIds.contains(caseId)) {
          add(
            id: 'unprovenAndroidProofCitation',
            severity: InternalSignalProfileConsistencySeverity.blocker,
            message: '${signal.signalId.wire} cited unproven Android proof',
            checkId: InternalSignalProfileConsistencyCheckId
                .androidProofSignalUsesCapturedIdsOnly,
            signalId: signal.signalId,
            caseId: caseId,
          );
        }
      }
    }

    for (final caseId in result.unprovenAndroidCaseIds) {
      add(
        id: 'unprovenAndroidProofResultCitation',
        severity: InternalSignalProfileConsistencySeverity.blocker,
        message: 'unproven Android proof citation remains present',
        checkId: InternalSignalProfileConsistencyCheckId
            .androidProofSignalUsesCapturedIdsOnly,
        signalId: InternalNonLabelSignalId.androidProofConfidenceSignal,
        caseId: caseId,
      );
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
        id: 'matrixBoundaryPolicyViolation',
        severity: InternalSignalProfileConsistencySeverity.critical,
        message: 'consistency matrix crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<InternalSignalProfileConsistencyValidationFinding> validateReportText(
    String reportText,
  ) {
    final findings = <InternalSignalProfileConsistencyValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        InternalSignalProfileConsistencyValidationFinding(
          id: id,
          severity: InternalSignalProfileConsistencySeverity.critical,
          message: message,
          checkId:
              InternalSignalProfileConsistencyCheckId.noRawUciOrPvDumpInReports,
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
      reportError('pvDumpReportText', 'report contains PV line text');
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
      reportError('moveRankingReportText', 'report contains move ranking text');
    }
    return findings..sort(_compareFindings);
  }
}

InternalSignalProfileConsistencyMatrixResult _blockedByProfileResult(
  InternalNonLabelSignalProfileResult profileResult,
) {
  return InternalSignalProfileConsistencyMatrixResult(
    matrixStatus: InternalSignalProfileConsistencyMatrixStatus.blockedByProfile,
    profileStatus: profileResult.status,
    scoringDesignStatus: profileResult.scoringDesignStatus,
    coverageMatrixStatus: profileResult.matrixStatus,
    harnessStatus: profileResult.harnessStatus,
    guardStatus: profileResult.guardStatus,
    guardAllowed: profileResult.guardAllowed,
    rows: const <InternalSignalProfileConsistencyRow>[],
    validationFindings:
        const <InternalSignalProfileConsistencyValidationFinding>[],
    warnings: profileResult.warnings,
    failures: _sortedStrings(<String>[
      ...profileResult.failures,
      'signal profile did not complete a consistency-matrix input',
    ]),
    totalChecks: 0,
    consistentCount: 0,
    warningCount: 0,
    blockerCount: 1,
    criticalCount: 0,
    activeSignalsChecked: 0,
    blockedSignalsChecked: 0,
    excludedSignalsChecked: 0,
    futureOnlySignalsChecked: 0,
    safeForGuardedInternalExperiment: false,
    nextRecommendation:
        InternalSignalProfileConsistencyNextPhase.consistencyEvidenceFixes,
    provenAndroidCaseIds: profileResult.provenAndroidCaseIds,
    unprovenAndroidCaseIds: profileResult.unprovenAndroidCaseIds,
    excludedScopeIds: profileResult.excludedScopeIds,
    productLabelsEmitted: profileResult.productLabelsEmitted,
    classifierLabelsEmitted: profileResult.classifierLabelsEmitted,
    finalMoveLabelsEmitted: profileResult.finalMoveLabelsEmitted,
    officialMetricsAllowed: profileResult.officialMetricsAllowed,
    cpLossComputationImplemented: profileResult.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        profileResult.winProbabilityComputationImplemented,
    numericMoveScoresComputed: profileResult.numericMoveScoresComputed,
    moveRankingComputed: profileResult.moveRankingComputed,
    directEngineAccessUsed: profileResult.directEngineAccessUsed,
    uiOutputUsed: profileResult.uiOutputUsed,
    backendOutputUsed: profileResult.backendOutputUsed,
    persistenceUsed: profileResult.persistenceUsed,
    emittedOutputFamilies: profileResult.emittedOutputFamilies,
  );
}

InternalSignalProfileConsistencyMatrixResult _resultFromRows(
  InternalNonLabelSignalProfileResult profileResult,
  List<InternalSignalProfileConsistencyRow> rows,
) {
  final consistentCount = rows.where((row) => row.isConsistent).length;
  final warningCount = rows.where((row) => row.isWarning).length;
  final blockerCount = rows.where((row) => row.isBlocker).length;
  final criticalCount = rows.where((row) => row.isCritical).length;
  final activeSignalsChecked = profileResult.signals
      .where((signal) => signal.isActive)
      .length;
  final blockedSignalsChecked = profileResult.signals
      .where(
        (signal) =>
            signal.status == InternalNonLabelSignalStatus.blockedByPolicy,
      )
      .length;
  final excludedSignalsChecked = profileResult.signals
      .where((signal) => signal.status == InternalNonLabelSignalStatus.excluded)
      .length;
  final futureOnlySignalsChecked = profileResult.signals
      .where(
        (signal) => signal.status == InternalNonLabelSignalStatus.futureOnly,
      )
      .length;
  final safe =
      blockerCount == 0 &&
      criticalCount == 0 &&
      !profileResult.hasUnsafeSignalProfilePolicyViolation;

  return InternalSignalProfileConsistencyMatrixResult(
    matrixStatus: warningCount > 0
        ? InternalSignalProfileConsistencyMatrixStatus.consistentWithWarnings
        : InternalSignalProfileConsistencyMatrixStatus.consistentInternalOnly,
    profileStatus: profileResult.status,
    scoringDesignStatus: profileResult.scoringDesignStatus,
    coverageMatrixStatus: profileResult.matrixStatus,
    harnessStatus: profileResult.harnessStatus,
    guardStatus: profileResult.guardStatus,
    guardAllowed: profileResult.guardAllowed,
    rows: rows,
    validationFindings:
        const <InternalSignalProfileConsistencyValidationFinding>[],
    warnings: profileResult.warnings,
    failures: profileResult.failures,
    totalChecks: rows.length,
    consistentCount: consistentCount,
    warningCount: warningCount,
    blockerCount: blockerCount,
    criticalCount: criticalCount,
    activeSignalsChecked: activeSignalsChecked,
    blockedSignalsChecked: blockedSignalsChecked,
    excludedSignalsChecked: excludedSignalsChecked,
    futureOnlySignalsChecked: futureOnlySignalsChecked,
    safeForGuardedInternalExperiment: safe,
    nextRecommendation: safe
        ? InternalSignalProfileConsistencyNextPhase
              .guardedInternalSignalProfileExperiments
        : InternalSignalProfileConsistencyNextPhase.consistencyEvidenceFixes,
    provenAndroidCaseIds: profileResult.provenAndroidCaseIds,
    unprovenAndroidCaseIds: profileResult.unprovenAndroidCaseIds,
    excludedScopeIds: profileResult.excludedScopeIds,
    productLabelsEmitted: profileResult.productLabelsEmitted,
    classifierLabelsEmitted: profileResult.classifierLabelsEmitted,
    finalMoveLabelsEmitted: profileResult.finalMoveLabelsEmitted,
    officialMetricsAllowed: profileResult.officialMetricsAllowed,
    cpLossComputationImplemented: profileResult.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        profileResult.winProbabilityComputationImplemented,
    numericMoveScoresComputed: profileResult.numericMoveScoresComputed,
    moveRankingComputed: profileResult.moveRankingComputed,
    directEngineAccessUsed: profileResult.directEngineAccessUsed,
    uiOutputUsed: profileResult.uiOutputUsed,
    backendOutputUsed: profileResult.backendOutputUsed,
    persistenceUsed: profileResult.persistenceUsed,
    emittedOutputFamilies: profileResult.emittedOutputFamilies,
  );
}

InternalSignalProfileConsistencyMatrixStatus _matrixStatusFor(
  InternalSignalProfileConsistencyMatrixResult result,
  List<InternalSignalProfileConsistencyValidationFinding> findings,
) {
  if (findings.any((finding) => finding.blocksStrict) ||
      result.blockerCount > 0 ||
      result.criticalCount > 0) {
    return InternalSignalProfileConsistencyMatrixStatus.blockedByValidation;
  }
  if (result.warningCount > 0 ||
      findings.any(
        (finding) =>
            finding.severity ==
            InternalSignalProfileConsistencySeverity.warning,
      )) {
    return InternalSignalProfileConsistencyMatrixStatus.consistentWithWarnings;
  }
  return InternalSignalProfileConsistencyMatrixStatus.consistentInternalOnly;
}

List<InternalSignalProfileConsistencyRow> _buildRows(
  InternalNonLabelSignalProfileResult profile,
) {
  final rows = <InternalSignalProfileConsistencyRow>[
    _activeSupportRow(profile),
    _activeSourceRow(profile),
    _activeAreaRow(profile),
    _warningReasonRow(profile),
    _partialPrerequisiteRow(profile),
    _androidProofRow(profile),
    _pvMultiPvRow(profile),
    _candidateSpreadRow(profile),
    _suppressionRow(profile),
    _budgetRiskRow(profile),
    _quietExcludedRow(profile),
    _blockedSignalRow(
      profile,
      checkId: InternalSignalProfileConsistencyCheckId
          .productLabelSignalRemainsBlocked,
      signalId: InternalNonLabelSignalId.productLabelSignalBlocked,
    ),
    _blockedSignalRow(
      profile,
      checkId: InternalSignalProfileConsistencyCheckId
          .advancedLabelSignalRemainsBlocked,
      signalId: InternalNonLabelSignalId.advancedLabelSignalBlocked,
    ),
    _blockedSignalRow(
      profile,
      checkId: InternalSignalProfileConsistencyCheckId
          .officialMetricSignalRemainsBlocked,
      signalId: InternalNonLabelSignalId.officialMetricSignalBlocked,
    ),
    _futureOnlyRow(
      profile,
      checkId:
          InternalSignalProfileConsistencyCheckId.cpLossSignalRemainsFutureOnly,
      signalId: InternalNonLabelSignalId.cpLossSignalFutureOnly,
      implemented: profile.cpLossComputationImplemented,
    ),
    _futureOnlyRow(
      profile,
      checkId: InternalSignalProfileConsistencyCheckId
          .winProbabilitySignalRemainsFutureOnly,
      signalId: InternalNonLabelSignalId.winProbabilitySignalFutureOnly,
      implemented: profile.winProbabilityComputationImplemented,
    ),
    _noLabelRow(profile),
    _noNumericScoreRow(profile),
    _noRankingRow(profile),
    _reportPolicyRow(profile),
  ];
  return List<InternalSignalProfileConsistencyRow>.unmodifiable(
    rows..sort((a, b) => a.checkId.index.compareTo(b.checkId.index)),
  );
}

InternalSignalProfileConsistencyRow _activeSupportRow(
  InternalNonLabelSignalProfileResult profile,
) {
  final active = _activeSignals(profile);
  final missing = active
      .where((signal) => signal.supportingCaseIds.isEmpty)
      .toList(growable: false);
  final relevant = missing.isEmpty ? active : missing;
  return _row(
    checkId:
        InternalSignalProfileConsistencyCheckId.activeSignalHasSupportCases,
    status: missing.isEmpty
        ? InternalSignalProfileConsistencyStatus.consistent
        : InternalSignalProfileConsistencyStatus.missingSupport,
    severity: missing.isEmpty
        ? InternalSignalProfileConsistencySeverity.none
        : InternalSignalProfileConsistencySeverity.blocker,
    signals: relevant,
    warningReason: '',
    blockerReason: missing.isEmpty
        ? ''
        : 'active signals require supporting Golden cases',
    recommendation: missing.isEmpty
        ? InternalSignalProfileConsistencyRecommendation.keepStable
        : InternalSignalProfileConsistencyRecommendation.addGoldenSupport,
  );
}

InternalSignalProfileConsistencyRow _activeSourceRow(
  InternalNonLabelSignalProfileResult profile,
) {
  final active = _activeSignals(profile);
  final missing = active
      .where((signal) => signal.sourceDimensionIds.isEmpty)
      .toList(growable: false);
  return _row(
    checkId:
        InternalSignalProfileConsistencyCheckId.activeSignalHasSourceDimension,
    status: missing.isEmpty
        ? InternalSignalProfileConsistencyStatus.consistent
        : InternalSignalProfileConsistencyStatus.inconsistent,
    severity: missing.isEmpty
        ? InternalSignalProfileConsistencySeverity.none
        : InternalSignalProfileConsistencySeverity.blocker,
    signals: missing.isEmpty ? active : missing,
    warningReason: '',
    blockerReason: missing.isEmpty
        ? ''
        : 'active signals require source dimensions',
    recommendation: missing.isEmpty
        ? InternalSignalProfileConsistencyRecommendation.keepStable
        : InternalSignalProfileConsistencyRecommendation.restoreSourceMapping,
  );
}

InternalSignalProfileConsistencyRow _activeAreaRow(
  InternalNonLabelSignalProfileResult profile,
) {
  final active = _activeSignals(profile);
  final missing = active
      .where((signal) => signal.relatedAreaIds.isEmpty)
      .toList(growable: false);
  return _row(
    checkId:
        InternalSignalProfileConsistencyCheckId.activeSignalHasEvidenceArea,
    status: missing.isEmpty
        ? InternalSignalProfileConsistencyStatus.consistent
        : InternalSignalProfileConsistencyStatus.inconsistent,
    severity: missing.isEmpty
        ? InternalSignalProfileConsistencySeverity.none
        : InternalSignalProfileConsistencySeverity.blocker,
    signals: missing.isEmpty ? active : missing,
    warningReason: '',
    blockerReason: missing.isEmpty
        ? ''
        : 'active signals require evidence-area mapping',
    recommendation: missing.isEmpty
        ? InternalSignalProfileConsistencyRecommendation.keepStable
        : InternalSignalProfileConsistencyRecommendation.restoreSourceMapping,
  );
}

InternalSignalProfileConsistencyRow _warningReasonRow(
  InternalNonLabelSignalProfileResult profile,
) {
  final warningSignals = profile.signals
      .where(
        (signal) =>
            signal.status == InternalNonLabelSignalStatus.activeWithWarnings,
      )
      .toList(growable: false);
  final missing = warningSignals
      .where(
        (signal) =>
            signal.warningReasons.isEmpty && signal.futurePrerequisites.isEmpty,
      )
      .toList(growable: false);
  return _row(
    checkId:
        InternalSignalProfileConsistencyCheckId.warningSignalHasWarningReason,
    status: missing.isEmpty
        ? InternalSignalProfileConsistencyStatus.consistentWithWarnings
        : InternalSignalProfileConsistencyStatus.inconsistent,
    severity: missing.isEmpty
        ? InternalSignalProfileConsistencySeverity.warning
        : InternalSignalProfileConsistencySeverity.blocker,
    signals: missing.isEmpty ? warningSignals : missing,
    warningReason: missing.isEmpty
        ? 'warning-ready signals keep visible caution reasons'
        : '',
    blockerReason: missing.isEmpty
        ? ''
        : 'warning-ready signals require a warning reason',
    recommendation: missing.isEmpty
        ? InternalSignalProfileConsistencyRecommendation.keepWarningLimited
        : InternalSignalProfileConsistencyRecommendation.investigateMismatch,
  );
}

InternalSignalProfileConsistencyRow _partialPrerequisiteRow(
  InternalNonLabelSignalProfileResult profile,
) {
  final partial = profile.signals
      .where((signal) => signal.status == InternalNonLabelSignalStatus.partial)
      .toList(growable: false);
  final missing = partial
      .where((signal) => signal.futurePrerequisites.isEmpty)
      .toList(growable: false);
  return _row(
    checkId: InternalSignalProfileConsistencyCheckId
        .partialSignalHasFuturePrerequisite,
    status: missing.isEmpty
        ? InternalSignalProfileConsistencyStatus.consistentWithWarnings
        : InternalSignalProfileConsistencyStatus.inconsistent,
    severity: missing.isEmpty
        ? InternalSignalProfileConsistencySeverity.warning
        : InternalSignalProfileConsistencySeverity.blocker,
    signals: missing.isEmpty ? partial : missing,
    warningReason: missing.isEmpty
        ? 'partial signals keep future prerequisites visible'
        : '',
    blockerReason: missing.isEmpty
        ? ''
        : 'partial signals require future prerequisites',
    recommendation: missing.isEmpty
        ? InternalSignalProfileConsistencyRecommendation.keepWarningLimited
        : InternalSignalProfileConsistencyRecommendation.addGoldenSupport,
  );
}

InternalSignalProfileConsistencyRow _androidProofRow(
  InternalNonLabelSignalProfileResult profile,
) {
  final signal = profile.signal(
    InternalNonLabelSignalId.androidProofConfidenceSignal,
  );
  final proof = signal.androidProofCaseIds.toSet();
  final captured = _capturedAndroidProofIds.toSet();
  final invalid = proof.difference(captured).toList()..sort();
  final missingCaptured = captured.difference(proof).toList()..sort();
  final hasInvalid =
      invalid.isNotEmpty ||
      signal.supportingCaseIds.any((caseId) => !captured.contains(caseId)) ||
      profile.unprovenAndroidCaseIds.isNotEmpty;
  return _row(
    checkId: InternalSignalProfileConsistencyCheckId
        .androidProofSignalUsesCapturedIdsOnly,
    status: hasInvalid
        ? InternalSignalProfileConsistencyStatus.inconsistent
        : InternalSignalProfileConsistencyStatus.consistent,
    severity: hasInvalid
        ? InternalSignalProfileConsistencySeverity.blocker
        : missingCaptured.isEmpty
        ? InternalSignalProfileConsistencySeverity.none
        : InternalSignalProfileConsistencySeverity.warning,
    signals: <InternalNonLabelSignalProfileEntry>[signal],
    warningReason: !hasInvalid && missingCaptured.isNotEmpty
        ? 'captured proof set is incomplete in this profile'
        : '',
    blockerReason: hasInvalid
        ? 'Android proof signal must cite captured proof IDs only'
        : '',
    recommendation: hasInvalid
        ? InternalSignalProfileConsistencyRecommendation
              .removeUnprovenAndroidProof
        : InternalSignalProfileConsistencyRecommendation.keepStable,
  );
}

InternalSignalProfileConsistencyRow _pvMultiPvRow(
  InternalNonLabelSignalProfileResult profile,
) {
  final signal = profile.signal(
    InternalNonLabelSignalId.pvMultiPvSupportSignal,
  );
  final hasPvArea = signal.relatedAreaIds.contains(
    InternalEvidenceAreaId.pvMultiPvArea,
  );
  final hasProof =
      signal.androidProofCaseIds.isNotEmpty &&
      signal.androidProofCaseIds.every(profile.provenAndroidCaseIds.contains);
  final consistent =
      hasPvArea && hasProof && signal.supportingCaseIds.isNotEmpty;
  return _row(
    checkId: InternalSignalProfileConsistencyCheckId
        .pvMultiPvSignalUsesProofOrPvSupport,
    status: consistent
        ? InternalSignalProfileConsistencyStatus.consistent
        : InternalSignalProfileConsistencyStatus.inconsistent,
    severity: consistent
        ? InternalSignalProfileConsistencySeverity.none
        : InternalSignalProfileConsistencySeverity.blocker,
    signals: <InternalNonLabelSignalProfileEntry>[signal],
    warningReason: '',
    blockerReason: consistent
        ? ''
        : 'PV/MultiPV support requires proof-backed or PV-supported cases',
    recommendation: consistent
        ? InternalSignalProfileConsistencyRecommendation.keepStable
        : InternalSignalProfileConsistencyRecommendation
              .avoidCombiningWithoutProof,
  );
}

InternalSignalProfileConsistencyRow _candidateSpreadRow(
  InternalNonLabelSignalProfileResult profile,
) {
  final signal = profile.signal(InternalNonLabelSignalId.candidateSpreadSignal);
  final consistent =
      signal.relatedAreaIds.contains(
        InternalEvidenceAreaId.candidateSpreadArea,
      ) &&
      signal.relatedBucketIds.contains(
        InternalEvidenceBucketId.candidateSpreadSupported,
      ) &&
      signal.supportingCaseIds.isNotEmpty;
  return _row(
    checkId: InternalSignalProfileConsistencyCheckId
        .candidateSpreadSignalHasSpreadSupport,
    status: consistent
        ? InternalSignalProfileConsistencyStatus.consistent
        : InternalSignalProfileConsistencyStatus.inconsistent,
    severity: consistent
        ? InternalSignalProfileConsistencySeverity.none
        : InternalSignalProfileConsistencySeverity.blocker,
    signals: <InternalNonLabelSignalProfileEntry>[signal],
    warningReason: '',
    blockerReason: consistent
        ? ''
        : 'candidate-spread signal requires spread evidence support',
    recommendation: consistent
        ? InternalSignalProfileConsistencyRecommendation.keepStable
        : InternalSignalProfileConsistencyRecommendation.restoreSourceMapping,
  );
}

InternalSignalProfileConsistencyRow _suppressionRow(
  InternalNonLabelSignalProfileResult profile,
) {
  final signal = profile.signal(
    InternalNonLabelSignalId.suppressionSafetySignal,
  );
  final hasPartialAreas = <InternalEvidenceAreaId>{
    InternalEvidenceAreaId.budgetPressureArea,
    InternalEvidenceAreaId.openingSuppressionArea,
    InternalEvidenceAreaId.forcedMoveSuppressionArea,
    InternalEvidenceAreaId.invalidFenSuppressionArea,
  }.every(signal.relatedAreaIds.contains);
  final consistent =
      signal.status == InternalNonLabelSignalStatus.activeWithWarnings &&
      signal.confidence == InternalNonLabelSignalConfidence.warningOnly &&
      signal.warningReasons.isNotEmpty &&
      hasPartialAreas;
  return _row(
    checkId: InternalSignalProfileConsistencyCheckId
        .suppressionSignalShowsPartialCoverage,
    status: consistent
        ? InternalSignalProfileConsistencyStatus.consistentWithWarnings
        : InternalSignalProfileConsistencyStatus.inconsistent,
    severity: consistent
        ? InternalSignalProfileConsistencySeverity.warning
        : InternalSignalProfileConsistencySeverity.blocker,
    signals: <InternalNonLabelSignalProfileEntry>[signal],
    warningReason: consistent
        ? 'suppression safety remains warning-only with partial subareas visible'
        : '',
    blockerReason: consistent
        ? ''
        : 'suppression safety must preserve partial subarea visibility',
    recommendation: consistent
        ? InternalSignalProfileConsistencyRecommendation.keepWarningLimited
        : InternalSignalProfileConsistencyRecommendation.addGoldenSupport,
  );
}

InternalSignalProfileConsistencyRow _budgetRiskRow(
  InternalNonLabelSignalProfileResult profile,
) {
  final signal = profile.signal(InternalNonLabelSignalId.budgetRiskSignal);
  final consistent =
      signal.status == InternalNonLabelSignalStatus.partial &&
      signal.confidence == InternalNonLabelSignalConfidence.warningOnly &&
      signal.futurePrerequisites.isNotEmpty;
  return _row(
    checkId: InternalSignalProfileConsistencyCheckId
        .budgetRiskSignalStaysWarningOnly,
    status: consistent
        ? InternalSignalProfileConsistencyStatus.consistentWithWarnings
        : InternalSignalProfileConsistencyStatus.inconsistent,
    severity: consistent
        ? InternalSignalProfileConsistencySeverity.warning
        : InternalSignalProfileConsistencySeverity.blocker,
    signals: <InternalNonLabelSignalProfileEntry>[signal],
    warningReason: consistent
        ? 'budget risk remains partial and warning-only until more coverage exists'
        : '',
    blockerReason: consistent
        ? ''
        : 'budget risk must not become active high-confidence without coverage',
    recommendation: consistent
        ? InternalSignalProfileConsistencyRecommendation.keepWarningLimited
        : InternalSignalProfileConsistencyRecommendation.addGoldenSupport,
  );
}

InternalSignalProfileConsistencyRow _quietExcludedRow(
  InternalNonLabelSignalProfileResult profile,
) {
  final signal = profile.signal(
    InternalNonLabelSignalId.quietPreparatorySignalExcluded,
  );
  final consistent =
      signal.status == InternalNonLabelSignalStatus.excluded &&
      !signal.quietScopeActive;
  return _row(
    checkId: InternalSignalProfileConsistencyCheckId
        .quietPreparatorySignalRemainsExcluded,
    status: consistent
        ? InternalSignalProfileConsistencyStatus.excludedCorrectly
        : InternalSignalProfileConsistencyStatus.inconsistent,
    severity: consistent
        ? InternalSignalProfileConsistencySeverity.info
        : InternalSignalProfileConsistencySeverity.critical,
    signals: <InternalNonLabelSignalProfileEntry>[signal],
    warningReason: '',
    blockerReason: consistent
        ? ''
        : 'quiet/preparatory signal must remain excluded',
    recommendation: consistent
        ? InternalSignalProfileConsistencyRecommendation
              .keepExcludedByNegativeGuard
        : InternalSignalProfileConsistencyRecommendation.investigateMismatch,
  );
}

InternalSignalProfileConsistencyRow _blockedSignalRow(
  InternalNonLabelSignalProfileResult profile, {
  required InternalSignalProfileConsistencyCheckId checkId,
  required InternalNonLabelSignalId signalId,
}) {
  final signal = profile.signal(signalId);
  final consistent =
      signal.status == InternalNonLabelSignalStatus.blockedByPolicy &&
      !signal.productLabelsActive &&
      !signal.advancedLabelsActive &&
      !signal.officialMetricsActive &&
      !signal.claimsOfficialMetrics;
  return _row(
    checkId: checkId,
    status: consistent
        ? InternalSignalProfileConsistencyStatus.blockedCorrectly
        : InternalSignalProfileConsistencyStatus.inconsistent,
    severity: consistent
        ? InternalSignalProfileConsistencySeverity.info
        : InternalSignalProfileConsistencySeverity.critical,
    signals: <InternalNonLabelSignalProfileEntry>[signal],
    warningReason: '',
    blockerReason: consistent
        ? ''
        : '${signal.signalId.wire} must stay blocked',
    recommendation: consistent
        ? InternalSignalProfileConsistencyRecommendation.keepBlockedByPolicy
        : InternalSignalProfileConsistencyRecommendation.investigateMismatch,
  );
}

InternalSignalProfileConsistencyRow _futureOnlyRow(
  InternalNonLabelSignalProfileResult profile, {
  required InternalSignalProfileConsistencyCheckId checkId,
  required InternalNonLabelSignalId signalId,
  required bool implemented,
}) {
  final signal = profile.signal(signalId);
  final consistent =
      signal.status == InternalNonLabelSignalStatus.futureOnly && !implemented;
  return _row(
    checkId: checkId,
    status: consistent
        ? InternalSignalProfileConsistencyStatus.futureOnlyCorrectly
        : InternalSignalProfileConsistencyStatus.inconsistent,
    severity: consistent
        ? InternalSignalProfileConsistencySeverity.info
        : InternalSignalProfileConsistencySeverity.critical,
    signals: <InternalNonLabelSignalProfileEntry>[signal],
    warningReason: '',
    blockerReason: consistent
        ? ''
        : '${signal.signalId.wire} must stay future-only',
    recommendation: consistent
        ? InternalSignalProfileConsistencyRecommendation.keepFutureOnly
        : InternalSignalProfileConsistencyRecommendation.investigateMismatch,
  );
}

InternalSignalProfileConsistencyRow _noLabelRow(
  InternalNonLabelSignalProfileResult profile,
) {
  final leaking = profile.signals
      .where(
        (signal) =>
            signal.emitsProductLabel ||
            signal.emitsClassifierLabel ||
            signal.emitsFinalMoveLabel ||
            signal.emittedOutputNames.any(_isForbiddenOutputName),
      )
      .toList(growable: false);
  final consistent =
      leaking.isEmpty &&
      !profile.productLabelsEmitted &&
      !profile.classifierLabelsEmitted &&
      !profile.finalMoveLabelsEmitted &&
      !profile.emittedOutputFamilies.any(_isForbiddenOutputName);
  return _row(
    checkId: InternalSignalProfileConsistencyCheckId.noSignalEmitsMoveLabel,
    status: consistent
        ? InternalSignalProfileConsistencyStatus.consistent
        : InternalSignalProfileConsistencyStatus.inconsistent,
    severity: consistent
        ? InternalSignalProfileConsistencySeverity.none
        : InternalSignalProfileConsistencySeverity.critical,
    signals: leaking,
    warningReason: '',
    blockerReason: consistent
        ? ''
        : 'signals must not emit forbidden move-label output',
    recommendation: consistent
        ? InternalSignalProfileConsistencyRecommendation.keepStable
        : InternalSignalProfileConsistencyRecommendation.removeForbiddenOutput,
  );
}

InternalSignalProfileConsistencyRow _noNumericScoreRow(
  InternalNonLabelSignalProfileResult profile,
) {
  final leaking = profile.signals
      .where((signal) => signal.hasNumericMoveScore)
      .toList(growable: false);
  final consistent = leaking.isEmpty && !profile.numericMoveScoresComputed;
  return _row(
    checkId: InternalSignalProfileConsistencyCheckId.noSignalEmitsNumericScore,
    status: consistent
        ? InternalSignalProfileConsistencyStatus.consistent
        : InternalSignalProfileConsistencyStatus.inconsistent,
    severity: consistent
        ? InternalSignalProfileConsistencySeverity.none
        : InternalSignalProfileConsistencySeverity.critical,
    signals: leaking,
    warningReason: '',
    blockerReason: consistent
        ? ''
        : 'signals must not emit numeric move scores',
    recommendation: consistent
        ? InternalSignalProfileConsistencyRecommendation.keepStable
        : InternalSignalProfileConsistencyRecommendation.removeForbiddenOutput,
  );
}

InternalSignalProfileConsistencyRow _noRankingRow(
  InternalNonLabelSignalProfileResult profile,
) {
  final leaking = profile.signals
      .where((signal) => signal.ranksMoves)
      .toList(growable: false);
  final consistent = leaking.isEmpty && !profile.moveRankingComputed;
  return _row(
    checkId: InternalSignalProfileConsistencyCheckId.noSignalRanksMoves,
    status: consistent
        ? InternalSignalProfileConsistencyStatus.consistent
        : InternalSignalProfileConsistencyStatus.inconsistent,
    severity: consistent
        ? InternalSignalProfileConsistencySeverity.none
        : InternalSignalProfileConsistencySeverity.critical,
    signals: leaking,
    warningReason: '',
    blockerReason: consistent ? '' : 'signals must not rank moves',
    recommendation: consistent
        ? InternalSignalProfileConsistencyRecommendation.keepStable
        : InternalSignalProfileConsistencyRecommendation.removeForbiddenOutput,
  );
}

InternalSignalProfileConsistencyRow _reportPolicyRow(
  InternalNonLabelSignalProfileResult profile,
) {
  return _row(
    checkId: InternalSignalProfileConsistencyCheckId.noRawUciOrPvDumpInReports,
    status: InternalSignalProfileConsistencyStatus.consistent,
    severity: InternalSignalProfileConsistencySeverity.none,
    signals: profile.signals,
    warningReason: '',
    blockerReason: '',
    recommendation: InternalSignalProfileConsistencyRecommendation.keepStable,
  );
}

InternalSignalProfileConsistencyRow _row({
  required InternalSignalProfileConsistencyCheckId checkId,
  required InternalSignalProfileConsistencyStatus status,
  required InternalSignalProfileConsistencySeverity severity,
  required List<InternalNonLabelSignalProfileEntry> signals,
  required String warningReason,
  required String blockerReason,
  required InternalSignalProfileConsistencyRecommendation recommendation,
}) {
  return InternalSignalProfileConsistencyRow(
    checkId: checkId,
    status: status,
    severity: severity,
    signalIds: _sortedSignalIds(signals.map((signal) => signal.signalId)),
    relatedDimensionIds: _sortedDimensionIds(
      signals.expand((signal) => signal.sourceDimensionIds),
    ),
    relatedAreaIds: _sortedAreaIds(
      signals.expand((signal) => signal.relatedAreaIds),
    ),
    relatedBucketIds: _sortedBucketIds(
      signals.expand((signal) => signal.relatedBucketIds),
    ),
    supportCaseIds: _sortedStrings(
      signals.expand((signal) => signal.supportingCaseIds),
    ),
    androidProofCaseIds: _sortedStrings(
      signals.expand((signal) => signal.androidProofCaseIds),
    ),
    warningReason: warningReason,
    blockerReason: blockerReason,
    recommendation: recommendation,
  );
}

List<InternalNonLabelSignalProfileEntry> _activeSignals(
  InternalNonLabelSignalProfileResult profile,
) {
  return profile.signals
      .where((signal) => signal.isActive)
      .toList(growable: false);
}

List<InternalNonLabelSignalId> _activeSignalIdsFromRows(
  Iterable<InternalSignalProfileConsistencyRow> rows,
) {
  final ids = <InternalNonLabelSignalId>{};
  for (final row in rows) {
    if (row.checkId ==
            InternalSignalProfileConsistencyCheckId
                .activeSignalHasSupportCases ||
        row.checkId ==
            InternalSignalProfileConsistencyCheckId
                .activeSignalHasSourceDimension ||
        row.checkId ==
            InternalSignalProfileConsistencyCheckId
                .activeSignalHasEvidenceArea) {
      ids.addAll(row.signalIds);
    }
  }
  return _sortedSignalIds(ids);
}

List<InternalNonLabelScoringDimensionId> _dimensionIdsFromRows(
  Iterable<InternalSignalProfileConsistencyRow> rows,
) {
  return _sortedDimensionIds(
    rows
        .where(_isActiveSignalCheckRow)
        .expand((row) => row.relatedDimensionIds),
  );
}

List<InternalEvidenceAreaId> _areaIdsFromRows(
  Iterable<InternalSignalProfileConsistencyRow> rows,
) {
  return _sortedAreaIds(
    rows.where(_isActiveSignalCheckRow).expand((row) => row.relatedAreaIds),
  );
}

bool _isActiveSignalCheckRow(InternalSignalProfileConsistencyRow row) {
  return row.checkId ==
          InternalSignalProfileConsistencyCheckId.activeSignalHasSupportCases ||
      row.checkId ==
          InternalSignalProfileConsistencyCheckId
              .activeSignalHasSourceDimension ||
      row.checkId ==
          InternalSignalProfileConsistencyCheckId.activeSignalHasEvidenceArea;
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.toSet().toList()..sort();
}

List<InternalNonLabelSignalId> _sortedSignalIds(
  Iterable<InternalNonLabelSignalId> values,
) {
  return values.toSet().toList()..sort((a, b) => a.index.compareTo(b.index));
}

List<InternalNonLabelScoringDimensionId> _sortedDimensionIds(
  Iterable<InternalNonLabelScoringDimensionId> values,
) {
  return values.toSet().toList()..sort((a, b) => a.index.compareTo(b.index));
}

List<InternalEvidenceAreaId> _sortedAreaIds(
  Iterable<InternalEvidenceAreaId> values,
) {
  return values.toSet().toList()..sort((a, b) => a.index.compareTo(b.index));
}

List<InternalEvidenceBucketId> _sortedBucketIds(
  Iterable<InternalEvidenceBucketId> values,
) {
  return values.toSet().toList()..sort((a, b) => a.index.compareTo(b.index));
}

String _ids(Iterable<String> values) {
  final sorted = _sortedStrings(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

String _signalIds(Iterable<InternalNonLabelSignalId> values) {
  final ids = values.map((id) => id.wire).toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _dimensionIds(Iterable<InternalNonLabelScoringDimensionId> values) {
  final ids = values.map((id) => id.wire).toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _areaIds(Iterable<InternalEvidenceAreaId> values) {
  final ids = values.map((id) => id.wire).toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

int _compareFindings(
  InternalSignalProfileConsistencyValidationFinding a,
  InternalSignalProfileConsistencyValidationFinding b,
) {
  final idCompare = a.id.compareTo(b.id);
  if (idCompare != 0) return idCompare;
  final checkCompare = (a.checkId?.wire ?? '').compareTo(b.checkId?.wire ?? '');
  if (checkCompare != 0) return checkCompare;
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

const _capturedAndroidProofIds = <String>{
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
};

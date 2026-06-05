/// Developer-only review matrix over internal signal experiment observations.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_scoring_design.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_experiment_runner.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_profile_consistency_matrix.dart';

const internalSignalObservationReviewMatrixReportVersion =
    'internal-signal-observation-review-matrix-v1';

enum InternalSignalObservationReviewStatus {
  stable('stable'),
  stableWithWarnings('stableWithWarnings'),
  warningOnly('warningOnly'),
  needsMoreGoldenCoverage('needsMoreGoldenCoverage'),
  blockedCorrectly('blockedCorrectly'),
  excludedCorrectly('excludedCorrectly'),
  futureOnlyCorrectly('futureOnlyCorrectly'),
  invalid('invalid'),
  unsafe('unsafe');

  const InternalSignalObservationReviewStatus(this.wire);

  final String wire;
}

enum InternalSignalObservationReviewMatrixStatus {
  readyInternalOnly('readyInternalOnly'),
  readyWithWarnings('readyWithWarnings'),
  blockedByRunner('blockedByRunner'),
  blockedByValidation('blockedByValidation'),
  unsafe('unsafe'),
  invalid('invalid');

  const InternalSignalObservationReviewMatrixStatus(this.wire);

  final String wire;
}

enum InternalSignalObservationReviewRecommendation {
  keepStable('keepStable'),
  keepWarningOnly('keepWarningOnly'),
  addGoldenCoverage('addGoldenCoverage'),
  keepExcluded('keepExcluded'),
  keepBlockedByPolicy('keepBlockedByPolicy'),
  keepFutureOnly('keepFutureOnly'),
  investigateUnsafeOutput('investigateUnsafeOutput');

  const InternalSignalObservationReviewRecommendation(this.wire);

  final String wire;
}

enum InternalSignalObservationReviewValidationSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const InternalSignalObservationReviewValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == InternalSignalObservationReviewValidationSeverity.blocker ||
      this == InternalSignalObservationReviewValidationSeverity.critical;
}

enum InternalSignalObservationReviewReportFormat {
  markdown('markdown'),
  json('json');

  const InternalSignalObservationReviewReportFormat(this.wire);

  final String wire;
}

enum InternalSignalObservationReviewNextRecommendation {
  guardedInternalPrototype(
    'Phase 31L -- Guarded Internal Non-Label Prototype Readiness Review',
  ),
  observationEvidenceFixes('Phase 31L -- Observation Evidence Fixes');

  const InternalSignalObservationReviewNextRecommendation(this.wire);

  final String wire;
}

class InternalSignalObservationReviewMatrixRequest {
  const InternalSignalObservationReviewMatrixRequest({
    this.runnerResult,
    this.consistencyResult,
    this.profileResult,
    this.runnerRequest,
    this.runner = const InternalSignalExperimentRunner(),
    this.consistencyMatrix = const InternalSignalProfileConsistencyMatrix(),
    this.profile = const InternalNonLabelSignalProfilePrototype(),
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.cases = GoldenAnalysisCases.defaults,
  });

  InternalSignalObservationReviewMatrixRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(
         cases: cases,
         runnerRequest: InternalSignalExperimentRunnerRequest.safeDemo(
           includeWarningSignals: includeWarnings,
         ),
       );

  final InternalSignalExperimentRunnerResult? runnerResult;
  final InternalSignalProfileConsistencyMatrixResult? consistencyResult;
  final InternalNonLabelSignalProfileResult? profileResult;
  final InternalSignalExperimentRunnerRequest? runnerRequest;
  final InternalSignalExperimentRunner runner;
  final InternalSignalProfileConsistencyMatrix consistencyMatrix;
  final InternalNonLabelSignalProfilePrototype profile;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final List<GoldenAnalysisCase> cases;
}

class InternalSignalObservationReviewRow {
  const InternalSignalObservationReviewRow({
    required this.signalId,
    required this.status,
    required this.sourceSignalStatus,
    required this.qualitativeConfidence,
    required this.observed,
    required this.supportCaseIds,
    required this.androidProofCaseIds,
    required this.sourceDimensionIds,
    required this.evidenceAreaIds,
    required this.bucketIds,
    required this.warningReason,
    required this.blockerReason,
    required this.futurePrerequisite,
    required this.recommendation,
  });

  final InternalNonLabelSignalId signalId;
  final InternalSignalObservationReviewStatus status;
  final InternalNonLabelSignalStatus sourceSignalStatus;
  final InternalNonLabelSignalConfidence qualitativeConfidence;
  final bool observed;
  final List<String> supportCaseIds;
  final List<String> androidProofCaseIds;
  final List<InternalNonLabelScoringDimensionId> sourceDimensionIds;
  final List<InternalEvidenceAreaId> evidenceAreaIds;
  final List<InternalEvidenceBucketId> bucketIds;
  final String warningReason;
  final String blockerReason;
  final String futurePrerequisite;
  final InternalSignalObservationReviewRecommendation recommendation;

  bool get isStable =>
      status == InternalSignalObservationReviewStatus.stable ||
      status == InternalSignalObservationReviewStatus.stableWithWarnings;

  bool get isWarning =>
      status == InternalSignalObservationReviewStatus.warningOnly ||
      status == InternalSignalObservationReviewStatus.needsMoreGoldenCoverage ||
      status == InternalSignalObservationReviewStatus.stableWithWarnings;

  bool get isInactivePolicyRow =>
      status == InternalSignalObservationReviewStatus.blockedCorrectly ||
      status == InternalSignalObservationReviewStatus.excludedCorrectly ||
      status == InternalSignalObservationReviewStatus.futureOnlyCorrectly;

  bool get isUnsafe =>
      status == InternalSignalObservationReviewStatus.unsafe ||
      status == InternalSignalObservationReviewStatus.invalid;

  InternalSignalObservationReviewRow copyWith({
    InternalNonLabelSignalId? signalId,
    InternalSignalObservationReviewStatus? status,
    InternalNonLabelSignalStatus? sourceSignalStatus,
    InternalNonLabelSignalConfidence? qualitativeConfidence,
    bool? observed,
    List<String>? supportCaseIds,
    List<String>? androidProofCaseIds,
    List<InternalNonLabelScoringDimensionId>? sourceDimensionIds,
    List<InternalEvidenceAreaId>? evidenceAreaIds,
    List<InternalEvidenceBucketId>? bucketIds,
    String? warningReason,
    String? blockerReason,
    String? futurePrerequisite,
    InternalSignalObservationReviewRecommendation? recommendation,
  }) {
    return InternalSignalObservationReviewRow(
      signalId: signalId ?? this.signalId,
      status: status ?? this.status,
      sourceSignalStatus: sourceSignalStatus ?? this.sourceSignalStatus,
      qualitativeConfidence:
          qualitativeConfidence ?? this.qualitativeConfidence,
      observed: observed ?? this.observed,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      sourceDimensionIds: sourceDimensionIds ?? this.sourceDimensionIds,
      evidenceAreaIds: evidenceAreaIds ?? this.evidenceAreaIds,
      bucketIds: bucketIds ?? this.bucketIds,
      warningReason: warningReason ?? this.warningReason,
      blockerReason: blockerReason ?? this.blockerReason,
      futurePrerequisite: futurePrerequisite ?? this.futurePrerequisite,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'signalId': signalId.wire,
      'status': status.wire,
      'sourceSignalStatus': sourceSignalStatus.wire,
      'qualitativeConfidence': qualitativeConfidence.wire,
      'observed': observed,
      'supportCaseIds': supportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'sourceDimensionIds': sourceDimensionIds
          .map((id) => id.wire)
          .toList(growable: false),
      'evidenceAreaIds': evidenceAreaIds
          .map((id) => id.wire)
          .toList(growable: false),
      'bucketIds': bucketIds.map((id) => id.wire).toList(growable: false),
      'warningReason': warningReason,
      'blockerReason': blockerReason,
      'futurePrerequisite': futurePrerequisite,
      'recommendation': recommendation.wire,
    };
  }
}

class InternalSignalObservationReviewValidationFinding {
  const InternalSignalObservationReviewValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.signalId,
    this.caseId,
  });

  final String id;
  final InternalSignalObservationReviewValidationSeverity severity;
  final String message;
  final InternalNonLabelSignalId? signalId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical =>
      severity == InternalSignalObservationReviewValidationSeverity.critical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (signalId != null) 'signalId': signalId!.wire,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class InternalSignalObservationReviewMatrixResult {
  const InternalSignalObservationReviewMatrixResult({
    required this.matrixStatus,
    required this.runnerStatus,
    required this.consistencyMatrixStatus,
    required this.profileStatus,
    required this.rows,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalRows,
    required this.stableCount,
    required this.warningCount,
    required this.inactivePolicyCount,
    required this.unsafeCount,
    required this.safeForLaterInternalPrototype,
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

  final InternalSignalObservationReviewMatrixStatus matrixStatus;
  final InternalSignalExperimentRunnerStatus runnerStatus;
  final InternalSignalProfileConsistencyMatrixStatus consistencyMatrixStatus;
  final InternalNonLabelSignalProfileStatus profileStatus;
  final List<InternalSignalObservationReviewRow> rows;
  final List<InternalSignalObservationReviewValidationFinding>
  validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalRows;
  final int stableCount;
  final int warningCount;
  final int inactivePolicyCount;
  final int unsafeCount;
  final bool safeForLaterInternalPrototype;
  final InternalSignalObservationReviewNextRecommendation nextRecommendation;
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
          InternalSignalObservationReviewMatrixStatus.blockedByRunner ||
      matrixStatus ==
          InternalSignalObservationReviewMatrixStatus.blockedByValidation ||
      matrixStatus == InternalSignalObservationReviewMatrixStatus.invalid ||
      matrixStatus == InternalSignalObservationReviewMatrixStatus.unsafe ||
      unsafeCount > 0 ||
      !safeForLaterInternalPrototype;

  bool get hasUnsafeReviewPolicyViolation {
    return unsafeCount > 0 ||
        validationFindings.any((finding) => finding.blocksStrict) ||
        rows.any((row) => row.isUnsafe) ||
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

  List<InternalSignalObservationReviewRow> get stableRows =>
      rows.where((row) => row.isStable).toList(growable: false);

  List<InternalSignalObservationReviewRow> get warningRows =>
      rows.where((row) => row.isWarning).toList(growable: false);

  List<InternalSignalObservationReviewRow> get inactivePolicyRows =>
      rows.where((row) => row.isInactivePolicyRow).toList(growable: false);

  InternalSignalObservationReviewRow row(InternalNonLabelSignalId id) {
    return rows.singleWhere((row) => row.signalId == id);
  }

  InternalSignalObservationReviewMatrixResult copyWith({
    InternalSignalObservationReviewMatrixStatus? matrixStatus,
    InternalSignalExperimentRunnerStatus? runnerStatus,
    InternalSignalProfileConsistencyMatrixStatus? consistencyMatrixStatus,
    InternalNonLabelSignalProfileStatus? profileStatus,
    List<InternalSignalObservationReviewRow>? rows,
    List<InternalSignalObservationReviewValidationFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalRows,
    int? stableCount,
    int? warningCount,
    int? inactivePolicyCount,
    int? unsafeCount,
    bool? safeForLaterInternalPrototype,
    InternalSignalObservationReviewNextRecommendation? nextRecommendation,
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
    return InternalSignalObservationReviewMatrixResult(
      matrixStatus: matrixStatus ?? this.matrixStatus,
      runnerStatus: runnerStatus ?? this.runnerStatus,
      consistencyMatrixStatus:
          consistencyMatrixStatus ?? this.consistencyMatrixStatus,
      profileStatus: profileStatus ?? this.profileStatus,
      rows: effectiveRows,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalRows: totalRows ?? effectiveRows.length,
      stableCount: stableCount ?? this.stableCount,
      warningCount: warningCount ?? this.warningCount,
      inactivePolicyCount: inactivePolicyCount ?? this.inactivePolicyCount,
      unsafeCount: unsafeCount ?? this.unsafeCount,
      safeForLaterInternalPrototype:
          safeForLaterInternalPrototype ?? this.safeForLaterInternalPrototype,
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
    final buffer = StringBuffer()
      ..writeln('# Internal Signal Observation Review Matrix')
      ..writeln()
      ..writeln(
        '- version: $internalSignalObservationReviewMatrixReportVersion',
      )
      ..writeln('- review matrix status: ${matrixStatus.wire}')
      ..writeln('- runner status: ${runnerStatus.wire}')
      ..writeln('- consistency matrix status: ${consistencyMatrixStatus.wire}')
      ..writeln('- profile status: ${profileStatus.wire}')
      ..writeln('- total review rows: $totalRows')
      ..writeln('- stable observation count: $stableCount')
      ..writeln('- warning observation count: $warningCount')
      ..writeln('- inactive policy observation count: $inactivePolicyCount')
      ..writeln('- unsafe observation count: $unsafeCount')
      ..writeln(
        '- safe for later internal prototype: $safeForLaterInternalPrototype',
      )
      ..writeln('- classifier output emitted: $classifierLabelsEmitted')
      ..writeln('- numeric score values emitted: $numericMoveScoresComputed')
      ..writeln('- ordering output emitted: $moveRankingComputed')
      ..writeln()
      ..writeln('## Review Policy')
      ..writeln(
        '- this matrix reviews internal observations for stability and evidence coverage only',
      )
      ..writeln(
        '- reviewed observations do not classify moves, compute values, order moves, call an engine, or write files',
      )
      ..writeln()
      ..writeln('## Review Table')
      ..writeln(
        '| Signal | Review Status | Source Status | Confidence | Observed | Support Cases | Android Proof | Warning | Blocker | Future Prerequisite | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in rows) {
      buffer.writeln(
        '| ${row.signalId.wire} | ${row.status.wire} | ${row.sourceSignalStatus.wire} | ${row.qualitativeConfidence.wire} | ${row.observed} | ${_ids(row.supportCaseIds)} | ${_ids(row.androidProofCaseIds)} | ${_dash(row.warningReason)} | ${_dash(row.blockerReason)} | ${_dash(row.futurePrerequisite)} | ${row.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Stable Observations')
      ..writeln('- ${_rowIds(stableRows)}')
      ..writeln()
      ..writeln('## Warning Observations')
      ..writeln('- ${_rowIds(warningRows)}')
      ..writeln()
      ..writeln('## Inactive Policy Observations')
      ..writeln('- ${_rowIds(inactivePolicyRows)}')
      ..writeln('- quiet/preparatory exclusion: ${_ids(excludedScopeIds)}')
      ..writeln()
      ..writeln('## Support Cases');
    for (final row in rows.where((row) => row.supportCaseIds.isNotEmpty)) {
      buffer.writeln('- ${row.signalId.wire}: ${_ids(row.supportCaseIds)}');
    }
    buffer
      ..writeln()
      ..writeln('## Android Proof References')
      ..writeln('- proven case IDs: ${_ids(provenAndroidCaseIds)}')
      ..writeln('- unproven case IDs: ${_ids(unprovenAndroidCaseIds)}')
      ..writeln()
      ..writeln('## Recommendations');
    for (final row in rows) {
      buffer.writeln('- ${row.signalId.wire}: ${row.recommendation.wire}');
    }
    buffer
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
      ..writeln('## Next Recommendation')
      ..writeln(nextRecommendation.wire)
      ..writeln()
      ..writeln(
        'This review matrix produces internal observation review records only. It does not emit user-facing output, compute product metrics, call the engine, run Android, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': internalSignalObservationReviewMatrixReportVersion,
      'matrixStatus': matrixStatus.wire,
      'runnerStatus': runnerStatus.wire,
      'consistencyMatrixStatus': consistencyMatrixStatus.wire,
      'profileStatus': profileStatus.wire,
      'totalRows': totalRows,
      'stableCount': stableCount,
      'warningCount': warningCount,
      'inactivePolicyCount': inactivePolicyCount,
      'unsafeCount': unsafeCount,
      'safeForLaterInternalPrototype': safeForLaterInternalPrototype,
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
  }
}

class InternalSignalObservationReviewMatrix {
  const InternalSignalObservationReviewMatrix({
    this.validator = const InternalSignalObservationReviewMatrixValidator(),
  });

  final InternalSignalObservationReviewMatrixValidator validator;

  InternalSignalObservationReviewMatrixResult evaluate([
    InternalSignalObservationReviewMatrixRequest request =
        const InternalSignalObservationReviewMatrixRequest(),
  ]) {
    final profileResult =
        request.profileResult ??
        request.profile.evaluate(
          InternalNonLabelSignalProfileRequest(
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
          ),
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
    final runnerRequest =
        request.runnerRequest ??
        InternalSignalExperimentRunnerRequest(
          consistencyResult: consistencyResult,
          profileResult: profileResult,
          androidProofEvidence: request.androidProofEvidence,
          cases: request.cases,
        );
    final runnerResult =
        request.runnerResult ?? request.runner.run(runnerRequest);

    if (runnerResult.isStrictlyBlocked) {
      return _blockedByRunnerResult(
        runnerResult: runnerResult,
        consistencyResult: consistencyResult,
        profileResult: profileResult,
      );
    }

    final rows = _buildRows(runnerResult);
    final base = _resultFromRows(
      rows: rows,
      runnerResult: runnerResult,
      consistencyResult: consistencyResult,
      profileResult: profileResult,
      validationFindings:
          const <InternalSignalObservationReviewValidationFinding>[],
    );
    final findings = validator.validate(base, runnerResult: runnerResult);
    final findingUnsafeCount = findings
        .where((finding) => finding.blocksStrict)
        .length;
    final withValidation = _resultFromRows(
      rows: rows,
      runnerResult: runnerResult,
      consistencyResult: consistencyResult,
      profileResult: profileResult,
      validationFindings: findings,
      additionalUnsafeCount: findingUnsafeCount,
    );
    return withValidation.copyWith(
      matrixStatus: _matrixStatusFor(withValidation),
      safeForLaterInternalPrototype: !withValidation.isStrictlyBlocked,
      nextRecommendation: withValidation.isStrictlyBlocked
          ? InternalSignalObservationReviewNextRecommendation
                .observationEvidenceFixes
          : InternalSignalObservationReviewNextRecommendation
                .guardedInternalPrototype,
    );
  }
}

class InternalSignalObservationReviewMatrixValidator {
  const InternalSignalObservationReviewMatrixValidator();

  List<InternalSignalObservationReviewValidationFinding> validate(
    InternalSignalObservationReviewMatrixResult result, {
    required InternalSignalExperimentRunnerResult runnerResult,
  }) {
    final findings = <InternalSignalObservationReviewValidationFinding>[];

    void add({
      required String id,
      required InternalSignalObservationReviewValidationSeverity severity,
      required String message,
      InternalNonLabelSignalId? signalId,
      String? caseId,
    }) {
      findings.add(
        InternalSignalObservationReviewValidationFinding(
          id: id,
          severity: severity,
          message: message,
          signalId: signalId,
          caseId: caseId,
        ),
      );
    }

    if (runnerResult.hasUnsafeRunnerPolicyViolation) {
      add(
        id: 'runnerPolicyViolationPropagated',
        severity: InternalSignalObservationReviewValidationSeverity.critical,
        message: 'runner result crossed a blocked output boundary',
      );
    }

    for (final observation in runnerResult.observations) {
      if (observation.isProductOutput ||
          observation.isClassifierLabel ||
          observation.emittedOutputNames.any(_isForbiddenOutputName)) {
        add(
          id: 'observationEmitsForbiddenOutput',
          severity: InternalSignalObservationReviewValidationSeverity.critical,
          message: '${observation.signalId.wire} emitted forbidden output',
          signalId: observation.signalId,
        );
      }
      if (observation.hasNumericScore) {
        add(
          id: 'observationEmitsNumericScore',
          severity: InternalSignalObservationReviewValidationSeverity.critical,
          message: '${observation.signalId.wire} emitted a numeric score',
          signalId: observation.signalId,
        );
      }
      if (observation.ranksMoves) {
        add(
          id: 'observationRanksMoves',
          severity: InternalSignalObservationReviewValidationSeverity.critical,
          message: '${observation.signalId.wire} ordered moves',
          signalId: observation.signalId,
        );
      }
      if (observation.isOfficialMetric) {
        add(
          id: 'observationEmitsOfficialMetric',
          severity: InternalSignalObservationReviewValidationSeverity.critical,
          message: '${observation.signalId.wire} emitted official metric',
          signalId: observation.signalId,
        );
      }
      if (observation.quietScopeActive ||
          (observation.signalId ==
                  InternalNonLabelSignalId.quietPreparatorySignalExcluded &&
              observation.observed)) {
        add(
          id: 'quietPreparatoryObservationActivated',
          severity: InternalSignalObservationReviewValidationSeverity.critical,
          message: '${observation.signalId.wire} activated quiet scope',
          signalId: observation.signalId,
        );
      }
      if (observation.cpLossComputationImplemented ||
          observation.winProbabilityComputationImplemented) {
        add(
          id: 'futureComputationActivated',
          severity: InternalSignalObservationReviewValidationSeverity.critical,
          message: '${observation.signalId.wire} activated future computation',
          signalId: observation.signalId,
        );
      }
      for (final caseId in observation.androidProofCaseIds) {
        if (!runnerResult.provenAndroidCaseIds.contains(caseId)) {
          add(
            id: 'unprovenAndroidProofCitation',
            severity: InternalSignalObservationReviewValidationSeverity.blocker,
            message: '${observation.signalId.wire} cited unproven proof',
            signalId: observation.signalId,
            caseId: caseId,
          );
        }
      }
    }

    for (final row in result.rows) {
      if (row.isStable && row.supportCaseIds.isEmpty) {
        add(
          id: 'stableObservationWithoutSupport',
          severity: InternalSignalObservationReviewValidationSeverity.blocker,
          message: '${row.signalId.wire} is stable without support cases',
          signalId: row.signalId,
        );
      }
      if (row.isStable &&
          (row.sourceDimensionIds.isEmpty || row.evidenceAreaIds.isEmpty)) {
        add(
          id: 'stableObservationWithoutSourceMapping',
          severity: InternalSignalObservationReviewValidationSeverity.blocker,
          message: '${row.signalId.wire} is stable without source mapping',
          signalId: row.signalId,
        );
      }
      if ((row.status == InternalSignalObservationReviewStatus.warningOnly ||
              row.status ==
                  InternalSignalObservationReviewStatus
                      .needsMoreGoldenCoverage) &&
          row.warningReason.isEmpty &&
          row.futurePrerequisite.isEmpty) {
        add(
          id: 'warningObservationWithoutReason',
          severity: InternalSignalObservationReviewValidationSeverity.blocker,
          message: '${row.signalId.wire} warning row lacks reason',
          signalId: row.signalId,
        );
      }
      if (row.isInactivePolicyRow && row.observed) {
        add(
          id: 'inactivePolicyObservationBecameActive',
          severity: InternalSignalObservationReviewValidationSeverity.critical,
          message: '${row.signalId.wire} inactive policy row became active',
          signalId: row.signalId,
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
        id: 'reviewBoundaryPolicyViolation',
        severity: InternalSignalObservationReviewValidationSeverity.critical,
        message: 'review matrix crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<InternalSignalObservationReviewValidationFinding> validateReportText(
    String reportText,
  ) {
    final findings = <InternalSignalObservationReviewValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        InternalSignalObservationReviewValidationFinding(
          id: id,
          severity: InternalSignalObservationReviewValidationSeverity.critical,
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
      reportError('moveRankingReportText', 'report contains ordering text');
    }
    return findings..sort(_compareFindings);
  }
}

InternalSignalObservationReviewMatrixResult _blockedByRunnerResult({
  required InternalSignalExperimentRunnerResult runnerResult,
  required InternalSignalProfileConsistencyMatrixResult consistencyResult,
  required InternalNonLabelSignalProfileResult profileResult,
}) {
  return InternalSignalObservationReviewMatrixResult(
    matrixStatus: InternalSignalObservationReviewMatrixStatus.blockedByRunner,
    runnerStatus: runnerResult.runnerStatus,
    consistencyMatrixStatus: consistencyResult.matrixStatus,
    profileStatus: profileResult.status,
    rows: const <InternalSignalObservationReviewRow>[],
    validationFindings:
        const <InternalSignalObservationReviewValidationFinding>[],
    warnings: runnerResult.warnings,
    failures: _sortedStrings(<String>[
      ...runnerResult.failures,
      'runner did not produce a safe observation input',
    ]),
    totalRows: 0,
    stableCount: 0,
    warningCount: 0,
    inactivePolicyCount: 0,
    unsafeCount: 0,
    safeForLaterInternalPrototype: false,
    nextRecommendation: InternalSignalObservationReviewNextRecommendation
        .observationEvidenceFixes,
    provenAndroidCaseIds: runnerResult.provenAndroidCaseIds,
    unprovenAndroidCaseIds: runnerResult.unprovenAndroidCaseIds,
    excludedScopeIds: runnerResult.excludedScopeIds,
    productLabelsEmitted: runnerResult.productLabelsEmitted,
    classifierLabelsEmitted: runnerResult.classifierLabelsEmitted,
    finalMoveLabelsEmitted: runnerResult.finalMoveLabelsEmitted,
    officialMetricsAllowed: runnerResult.officialMetricsAllowed,
    cpLossComputationImplemented: runnerResult.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        runnerResult.winProbabilityComputationImplemented,
    numericMoveScoresComputed: runnerResult.numericMoveScoresComputed,
    moveRankingComputed: runnerResult.moveRankingComputed,
    directEngineAccessUsed: runnerResult.directEngineAccessUsed,
    uiOutputUsed: runnerResult.uiOutputUsed,
    backendOutputUsed: runnerResult.backendOutputUsed,
    persistenceUsed: runnerResult.persistenceUsed,
    emittedOutputFamilies: runnerResult.emittedOutputFamilies,
  );
}

InternalSignalObservationReviewMatrixResult _resultFromRows({
  required List<InternalSignalObservationReviewRow> rows,
  required InternalSignalExperimentRunnerResult runnerResult,
  required InternalSignalProfileConsistencyMatrixResult consistencyResult,
  required InternalNonLabelSignalProfileResult profileResult,
  required List<InternalSignalObservationReviewValidationFinding>
  validationFindings,
  int additionalUnsafeCount = 0,
}) {
  final unsafeCount =
      rows.where((row) => row.isUnsafe).length + additionalUnsafeCount;
  final warnings = _sortedStrings(<String>[
    ...runnerResult.warnings,
    ...rows
        .where((row) => row.isWarning)
        .map(
          (row) =>
              '${row.signalId.wire}: ${row.warningReason.isNotEmpty ? row.warningReason : row.futurePrerequisite}',
        ),
  ]);
  final failures = _sortedStrings(<String>[
    ...runnerResult.failures,
    ...validationFindings.map((finding) => finding.message),
  ]);
  final base = InternalSignalObservationReviewMatrixResult(
    matrixStatus: InternalSignalObservationReviewMatrixStatus.readyInternalOnly,
    runnerStatus: runnerResult.runnerStatus,
    consistencyMatrixStatus: consistencyResult.matrixStatus,
    profileStatus: profileResult.status,
    rows: List<InternalSignalObservationReviewRow>.unmodifiable(rows),
    validationFindings: validationFindings,
    warnings: warnings,
    failures: failures,
    totalRows: rows.length,
    stableCount: rows.where((row) => row.isStable).length,
    warningCount: rows.where((row) => row.isWarning).length,
    inactivePolicyCount: rows.where((row) => row.isInactivePolicyRow).length,
    unsafeCount: unsafeCount,
    safeForLaterInternalPrototype: unsafeCount == 0,
    nextRecommendation: InternalSignalObservationReviewNextRecommendation
        .guardedInternalPrototype,
    provenAndroidCaseIds: runnerResult.provenAndroidCaseIds,
    unprovenAndroidCaseIds: runnerResult.unprovenAndroidCaseIds,
    excludedScopeIds: runnerResult.excludedScopeIds,
    productLabelsEmitted: runnerResult.productLabelsEmitted,
    classifierLabelsEmitted: runnerResult.classifierLabelsEmitted,
    finalMoveLabelsEmitted: runnerResult.finalMoveLabelsEmitted,
    officialMetricsAllowed: runnerResult.officialMetricsAllowed,
    cpLossComputationImplemented: runnerResult.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        runnerResult.winProbabilityComputationImplemented,
    numericMoveScoresComputed: runnerResult.numericMoveScoresComputed,
    moveRankingComputed: runnerResult.moveRankingComputed,
    directEngineAccessUsed: runnerResult.directEngineAccessUsed,
    uiOutputUsed: runnerResult.uiOutputUsed,
    backendOutputUsed: runnerResult.backendOutputUsed,
    persistenceUsed: runnerResult.persistenceUsed,
    emittedOutputFamilies: runnerResult.emittedOutputFamilies,
  );
  return base.copyWith(matrixStatus: _matrixStatusFor(base));
}

InternalSignalObservationReviewMatrixStatus _matrixStatusFor(
  InternalSignalObservationReviewMatrixResult result,
) {
  if (result.unsafeCount > 0 ||
      result.validationFindings.any((finding) => finding.blocksStrict) ||
      result.unprovenAndroidCaseIds.isNotEmpty ||
      result.hasUnsafeReviewPolicyViolation) {
    return InternalSignalObservationReviewMatrixStatus.unsafe;
  }
  if (result.validationFindings.isNotEmpty) {
    return InternalSignalObservationReviewMatrixStatus.blockedByValidation;
  }
  if (result.warningCount > 0 || result.warnings.isNotEmpty) {
    return InternalSignalObservationReviewMatrixStatus.readyWithWarnings;
  }
  return InternalSignalObservationReviewMatrixStatus.readyInternalOnly;
}

List<InternalSignalObservationReviewRow> _buildRows(
  InternalSignalExperimentRunnerResult runnerResult,
) {
  final rows = <InternalSignalObservationReviewRow>[];
  for (final observation in runnerResult.observations) {
    rows.add(
      _rowForObservation(observation, runnerResult.provenAndroidCaseIds),
    );
  }
  return List<InternalSignalObservationReviewRow>.unmodifiable(
    rows..sort((a, b) => a.signalId.index.compareTo(b.signalId.index)),
  );
}

InternalSignalObservationReviewRow _rowForObservation(
  InternalSignalExperimentObservation observation,
  List<String> provenAndroidCaseIds,
) {
  final proofValid = observation.androidProofCaseIds.every(
    provenAndroidCaseIds.contains,
  );
  if (observation.hasUnsafeOutput || !proofValid) {
    return _baseRow(
      observation,
      status: InternalSignalObservationReviewStatus.unsafe,
      recommendation:
          InternalSignalObservationReviewRecommendation.investigateUnsafeOutput,
    );
  }
  final hasSupport = observation.supportCaseIds.isNotEmpty;
  final hasSource =
      observation.sourceDimensionIds.isNotEmpty &&
      observation.evidenceAreaIds.isNotEmpty;
  final hasWarning =
      observation.warningReason.isNotEmpty ||
      observation.futurePrerequisite.isNotEmpty;

  return switch (observation.signalStatus) {
    InternalNonLabelSignalStatus.active =>
      observation.observed && hasSupport && hasSource
          ? _baseRow(
              observation,
              status: hasWarning
                  ? InternalSignalObservationReviewStatus.stableWithWarnings
                  : InternalSignalObservationReviewStatus.stable,
              recommendation:
                  InternalSignalObservationReviewRecommendation.keepStable,
            )
          : _baseRow(
              observation,
              status: InternalSignalObservationReviewStatus.unsafe,
              recommendation: InternalSignalObservationReviewRecommendation
                  .investigateUnsafeOutput,
            ),
    InternalNonLabelSignalStatus.activeWithWarnings => _baseRow(
      observation,
      status: hasWarning
          ? InternalSignalObservationReviewStatus.warningOnly
          : InternalSignalObservationReviewStatus.invalid,
      recommendation:
          InternalSignalObservationReviewRecommendation.keepWarningOnly,
    ),
    InternalNonLabelSignalStatus.partial => _baseRow(
      observation,
      status: hasWarning
          ? InternalSignalObservationReviewStatus.needsMoreGoldenCoverage
          : InternalSignalObservationReviewStatus.invalid,
      recommendation:
          InternalSignalObservationReviewRecommendation.addGoldenCoverage,
    ),
    InternalNonLabelSignalStatus.excluded => _baseRow(
      observation,
      status: !observation.observed
          ? InternalSignalObservationReviewStatus.excludedCorrectly
          : InternalSignalObservationReviewStatus.unsafe,
      recommendation: !observation.observed
          ? InternalSignalObservationReviewRecommendation.keepExcluded
          : InternalSignalObservationReviewRecommendation
                .investigateUnsafeOutput,
    ),
    InternalNonLabelSignalStatus.blockedByPolicy => _baseRow(
      observation,
      status: !observation.observed
          ? InternalSignalObservationReviewStatus.blockedCorrectly
          : InternalSignalObservationReviewStatus.unsafe,
      recommendation: !observation.observed
          ? InternalSignalObservationReviewRecommendation.keepBlockedByPolicy
          : InternalSignalObservationReviewRecommendation
                .investigateUnsafeOutput,
    ),
    InternalNonLabelSignalStatus.futureOnly => _baseRow(
      observation,
      status: !observation.observed
          ? InternalSignalObservationReviewStatus.futureOnlyCorrectly
          : InternalSignalObservationReviewStatus.unsafe,
      recommendation: !observation.observed
          ? InternalSignalObservationReviewRecommendation.keepFutureOnly
          : InternalSignalObservationReviewRecommendation
                .investigateUnsafeOutput,
    ),
    InternalNonLabelSignalStatus.inactive ||
    InternalNonLabelSignalStatus.invalid => _baseRow(
      observation,
      status: InternalSignalObservationReviewStatus.invalid,
      recommendation:
          InternalSignalObservationReviewRecommendation.investigateUnsafeOutput,
    ),
  };
}

InternalSignalObservationReviewRow _baseRow(
  InternalSignalExperimentObservation observation, {
  required InternalSignalObservationReviewStatus status,
  required InternalSignalObservationReviewRecommendation recommendation,
}) {
  return InternalSignalObservationReviewRow(
    signalId: observation.signalId,
    status: status,
    sourceSignalStatus: observation.signalStatus,
    qualitativeConfidence: observation.qualitativeConfidence,
    observed: observation.observed,
    supportCaseIds: observation.supportCaseIds,
    androidProofCaseIds: observation.androidProofCaseIds,
    sourceDimensionIds: observation.sourceDimensionIds,
    evidenceAreaIds: observation.evidenceAreaIds,
    bucketIds: observation.bucketIds,
    warningReason: observation.warningReason,
    blockerReason: observation.blockerReason,
    futurePrerequisite: observation.futurePrerequisite,
    recommendation: recommendation,
  );
}

String _rowIds(Iterable<InternalSignalObservationReviewRow> rows) {
  final ids = rows.map((row) => row.signalId.wire).toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _ids(Iterable<String> values) {
  final sorted = _sortedStrings(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

String _dash(String value) {
  return value.isEmpty ? '-' : value;
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.toSet().toList()..sort();
}

int _compareFindings(
  InternalSignalObservationReviewValidationFinding a,
  InternalSignalObservationReviewValidationFinding b,
) {
  final idCompare = a.id.compareTo(b.id);
  if (idCompare != 0) return idCompare;
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

/// Developer-only guarded internal signal experiment runner.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_scoring_design.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_profile_consistency_matrix.dart';

const internalSignalExperimentRunnerReportVersion =
    'internal-signal-experiment-runner-v1';

enum InternalSignalExperimentRunnerStatus {
  completedInternalOnly('completedInternalOnly'),
  completedWithWarnings('completedWithWarnings'),
  skippedByConsistencyGate('skippedByConsistencyGate'),
  blocked('blocked'),
  invalidRequest('invalidRequest'),
  failed('failed');

  const InternalSignalExperimentRunnerStatus(this.wire);

  final String wire;
}

enum InternalSignalExperimentRunnerReportFormat {
  markdown('markdown'),
  json('json');

  const InternalSignalExperimentRunnerReportFormat(this.wire);

  final String wire;
}

enum InternalSignalExperimentRunnerValidationSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const InternalSignalExperimentRunnerValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == InternalSignalExperimentRunnerValidationSeverity.blocker ||
      this == InternalSignalExperimentRunnerValidationSeverity.critical;
}

enum InternalSignalExperimentRunnerNextRecommendation {
  guardedInternalObservationReview(
    'Phase 31K -- Guarded Internal Signal Observation Review',
  ),
  consistencyEvidenceFixes('Phase 31K -- Consistency Evidence Fixes');

  const InternalSignalExperimentRunnerNextRecommendation(this.wire);

  final String wire;
}

class InternalSignalExperimentRunnerRequest {
  const InternalSignalExperimentRunnerRequest({
    this.experimentId = 'phase-31j-safe-demo',
    this.includeActiveSignals = true,
    this.includeWarningSignals = true,
    this.includeBlockedSignals = true,
    this.includeFutureOnlySignals = true,
    this.includeAndroidProofReferences = true,
    this.strictConsistencyRequired = true,
    this.notes = '',
    this.consistencyResult,
    this.profileResult,
    this.consistencyMatrix = const InternalSignalProfileConsistencyMatrix(),
    this.profile = const InternalNonLabelSignalProfilePrototype(),
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.cases = GoldenAnalysisCases.defaults,
  });

  const InternalSignalExperimentRunnerRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarningSignals = true,
    bool includeAndroidProofReferences = true,
  }) : this(
         cases: cases,
         includeWarningSignals: includeWarningSignals,
         includeAndroidProofReferences: includeAndroidProofReferences,
       );

  final String experimentId;
  final bool includeActiveSignals;
  final bool includeWarningSignals;
  final bool includeBlockedSignals;
  final bool includeFutureOnlySignals;
  final bool includeAndroidProofReferences;
  final bool strictConsistencyRequired;
  final String notes;
  final InternalSignalProfileConsistencyMatrixResult? consistencyResult;
  final InternalNonLabelSignalProfileResult? profileResult;
  final InternalSignalProfileConsistencyMatrix consistencyMatrix;
  final InternalNonLabelSignalProfilePrototype profile;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final List<GoldenAnalysisCase> cases;
}

class InternalSignalExperimentObservation {
  const InternalSignalExperimentObservation({
    required this.signalId,
    required this.signalStatus,
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
    this.isProductOutput = false,
    this.isClassifierLabel = false,
    this.isOfficialMetric = false,
    this.hasNumericScore = false,
    this.ranksMoves = false,
    this.quietScopeActive = false,
    this.cpLossComputationImplemented = false,
    this.winProbabilityComputationImplemented = false,
    this.emittedOutputNames = const <String>[],
  });

  final InternalNonLabelSignalId signalId;
  final InternalNonLabelSignalStatus signalStatus;
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
  final bool isProductOutput;
  final bool isClassifierLabel;
  final bool isOfficialMetric;
  final bool hasNumericScore;
  final bool ranksMoves;
  final bool quietScopeActive;
  final bool cpLossComputationImplemented;
  final bool winProbabilityComputationImplemented;
  final List<String> emittedOutputNames;

  bool get isActiveObservation =>
      observed && signalStatus == InternalNonLabelSignalStatus.active;

  bool get isWarningObservation =>
      observed &&
      (signalStatus == InternalNonLabelSignalStatus.activeWithWarnings ||
          signalStatus == InternalNonLabelSignalStatus.partial ||
          warningReason.isNotEmpty);

  bool get isInactivePolicyObservation =>
      !observed &&
      (signalStatus == InternalNonLabelSignalStatus.excluded ||
          signalStatus == InternalNonLabelSignalStatus.blockedByPolicy ||
          signalStatus == InternalNonLabelSignalStatus.futureOnly);

  bool get hasUnsafeOutput {
    return isProductOutput ||
        isClassifierLabel ||
        isOfficialMetric ||
        hasNumericScore ||
        ranksMoves ||
        quietScopeActive ||
        cpLossComputationImplemented ||
        winProbabilityComputationImplemented ||
        emittedOutputNames.any(_isForbiddenOutputName);
  }

  InternalSignalExperimentObservation copyWith({
    InternalNonLabelSignalId? signalId,
    InternalNonLabelSignalStatus? signalStatus,
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
    bool? isProductOutput,
    bool? isClassifierLabel,
    bool? isOfficialMetric,
    bool? hasNumericScore,
    bool? ranksMoves,
    bool? quietScopeActive,
    bool? cpLossComputationImplemented,
    bool? winProbabilityComputationImplemented,
    List<String>? emittedOutputNames,
  }) {
    return InternalSignalExperimentObservation(
      signalId: signalId ?? this.signalId,
      signalStatus: signalStatus ?? this.signalStatus,
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
      isProductOutput: isProductOutput ?? this.isProductOutput,
      isClassifierLabel: isClassifierLabel ?? this.isClassifierLabel,
      isOfficialMetric: isOfficialMetric ?? this.isOfficialMetric,
      hasNumericScore: hasNumericScore ?? this.hasNumericScore,
      ranksMoves: ranksMoves ?? this.ranksMoves,
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
      'signalId': signalId.wire,
      'signalStatus': signalStatus.wire,
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
      'isProductOutput': isProductOutput,
      'isClassifierLabel': isClassifierLabel,
      'isOfficialMetric': isOfficialMetric,
      'hasNumericScore': hasNumericScore,
      'ranksMoves': ranksMoves,
      'quietScopeActive': quietScopeActive,
      'cpLossComputationImplemented': cpLossComputationImplemented,
      'winProbabilityComputationImplemented':
          winProbabilityComputationImplemented,
      'emittedOutputNames': emittedOutputNames,
    };
  }
}

class InternalSignalExperimentRunnerValidationFinding {
  const InternalSignalExperimentRunnerValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.signalId,
    this.caseId,
  });

  final String id;
  final InternalSignalExperimentRunnerValidationSeverity severity;
  final String message;
  final InternalNonLabelSignalId? signalId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical =>
      severity == InternalSignalExperimentRunnerValidationSeverity.critical;

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

class InternalSignalExperimentRunnerResult {
  const InternalSignalExperimentRunnerResult({
    required this.runnerStatus,
    required this.experimentId,
    required this.consistencyMatrixStatus,
    required this.profileStatus,
    required this.consistencyGatePassed,
    required this.consistencyBlockerCount,
    required this.consistencyCriticalCount,
    required this.consistencySafeForExperiment,
    required this.observations,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
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

  final InternalSignalExperimentRunnerStatus runnerStatus;
  final String experimentId;
  final InternalSignalProfileConsistencyMatrixStatus consistencyMatrixStatus;
  final InternalNonLabelSignalProfileStatus profileStatus;
  final bool consistencyGatePassed;
  final int consistencyBlockerCount;
  final int consistencyCriticalCount;
  final bool consistencySafeForExperiment;
  final List<InternalSignalExperimentObservation> observations;
  final List<InternalSignalExperimentRunnerValidationFinding>
  validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final InternalSignalExperimentRunnerNextRecommendation nextRecommendation;
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

  int get observationCount => observations.length;

  List<InternalSignalExperimentObservation> get activeObservations =>
      observations
          .where((observation) => observation.isActiveObservation)
          .toList(growable: false);

  List<InternalSignalExperimentObservation> get warningObservations =>
      observations
          .where((observation) => observation.isWarningObservation)
          .toList(growable: false);

  List<InternalSignalExperimentObservation> get inactiveObservations =>
      observations
          .where((observation) => observation.isInactivePolicyObservation)
          .toList(growable: false);

  bool get isStrictlyBlocked =>
      runnerStatus ==
          InternalSignalExperimentRunnerStatus.skippedByConsistencyGate ||
      runnerStatus == InternalSignalExperimentRunnerStatus.blocked ||
      runnerStatus == InternalSignalExperimentRunnerStatus.invalidRequest ||
      runnerStatus == InternalSignalExperimentRunnerStatus.failed ||
      !consistencyGatePassed ||
      consistencyBlockerCount > 0 ||
      consistencyCriticalCount > 0 ||
      !consistencySafeForExperiment;

  bool get hasUnsafeRunnerPolicyViolation {
    return validationFindings.any((finding) => finding.isCritical) ||
        unprovenAndroidCaseIds.isNotEmpty ||
        observations.any((observation) => observation.hasUnsafeOutput) ||
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

  InternalSignalExperimentObservation observation(InternalNonLabelSignalId id) {
    return observations.singleWhere(
      (observation) => observation.signalId == id,
    );
  }

  InternalSignalExperimentRunnerResult copyWith({
    InternalSignalExperimentRunnerStatus? runnerStatus,
    String? experimentId,
    InternalSignalProfileConsistencyMatrixStatus? consistencyMatrixStatus,
    InternalNonLabelSignalProfileStatus? profileStatus,
    bool? consistencyGatePassed,
    int? consistencyBlockerCount,
    int? consistencyCriticalCount,
    bool? consistencySafeForExperiment,
    List<InternalSignalExperimentObservation>? observations,
    List<InternalSignalExperimentRunnerValidationFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    InternalSignalExperimentRunnerNextRecommendation? nextRecommendation,
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
    return InternalSignalExperimentRunnerResult(
      runnerStatus: runnerStatus ?? this.runnerStatus,
      experimentId: experimentId ?? this.experimentId,
      consistencyMatrixStatus:
          consistencyMatrixStatus ?? this.consistencyMatrixStatus,
      profileStatus: profileStatus ?? this.profileStatus,
      consistencyGatePassed:
          consistencyGatePassed ?? this.consistencyGatePassed,
      consistencyBlockerCount:
          consistencyBlockerCount ?? this.consistencyBlockerCount,
      consistencyCriticalCount:
          consistencyCriticalCount ?? this.consistencyCriticalCount,
      consistencySafeForExperiment:
          consistencySafeForExperiment ?? this.consistencySafeForExperiment,
      observations: observations ?? this.observations,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
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
      ..writeln('# Internal Signal Experiment Runner')
      ..writeln()
      ..writeln('- version: $internalSignalExperimentRunnerReportVersion')
      ..writeln('- experiment id: $experimentId')
      ..writeln('- runner status: ${runnerStatus.wire}')
      ..writeln('- consistency gate status: ${consistencyMatrixStatus.wire}')
      ..writeln('- profile status: ${profileStatus.wire}')
      ..writeln('- consistency gate passed: $consistencyGatePassed')
      ..writeln('- consistency blockers: $consistencyBlockerCount')
      ..writeln('- consistency criticals: $consistencyCriticalCount')
      ..writeln('- consistency safe: $consistencySafeForExperiment')
      ..writeln('- observation count: $observationCount')
      ..writeln('- classifier output emitted: false')
      ..writeln('- numeric score values emitted: false')
      ..writeln('- move ranking emitted: false')
      ..writeln()
      ..writeln('## Runner Policy')
      ..writeln(
        '- the consistency gate must pass before any signal observation is '
        'created',
      )
      ..writeln(
        '- observations are internal evidence visibility records only; they '
        'do not judge move quality, compute scores, rank moves, call an '
        'engine, or write files',
      )
      ..writeln()
      ..writeln('## Observation Table')
      ..writeln(
        '| Signal | Status | Confidence | Observed | Support Cases | Android Proof | Warning | Blocker | Future Prerequisite |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- | --- |');
    if (observations.isEmpty) {
      buffer.writeln('| - | - | - | - | - | - | - | - | - |');
    } else {
      for (final observation in observations) {
        buffer.writeln(
          '| ${observation.signalId.wire} | '
          '${observation.signalStatus.wire} | '
          '${observation.qualitativeConfidence.wire} | '
          '${observation.observed} | ${_ids(observation.supportCaseIds)} | '
          '${_ids(observation.androidProofCaseIds)} | '
          '${observation.warningReason.isEmpty ? '-' : observation.warningReason} | '
          '${observation.blockerReason.isEmpty ? '-' : observation.blockerReason} | '
          '${observation.futurePrerequisite.isEmpty ? '-' : observation.futurePrerequisite} |',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('## Active Observations')
      ..writeln('- ${_observationIds(activeObservations)}')
      ..writeln()
      ..writeln('## Warning Observations')
      ..writeln('- ${_observationIds(warningObservations)}')
      ..writeln()
      ..writeln('## Inactive Blocked Excluded Future Signals')
      ..writeln('- ${_observationIds(inactiveObservations)}')
      ..writeln('- quiet/preparatory exclusion: ${_ids(excludedScopeIds)}')
      ..writeln()
      ..writeln('## Support Cases');
    for (final observation in observations) {
      if (observation.supportCaseIds.isEmpty) continue;
      buffer.writeln(
        '- ${observation.signalId.wire}: ${_ids(observation.supportCaseIds)}',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Android Proof References')
      ..writeln('- proven case IDs: ${_ids(provenAndroidCaseIds)}')
      ..writeln('- unproven case IDs: ${_ids(unprovenAndroidCaseIds)}')
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
        'This runner produces internal signal observations only. It does not '
        'emit user-facing output, compute product metrics, call the engine, '
        'run Android, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    final payload = <String, Object?>{
      'version': internalSignalExperimentRunnerReportVersion,
      'experimentId': experimentId,
      'runnerStatus': runnerStatus.wire,
      'consistencyMatrixStatus': consistencyMatrixStatus.wire,
      'profileStatus': profileStatus.wire,
      'consistencyGatePassed': consistencyGatePassed,
      'consistencyBlockerCount': consistencyBlockerCount,
      'consistencyCriticalCount': consistencyCriticalCount,
      'consistencySafeForExperiment': consistencySafeForExperiment,
      'observationCount': observationCount,
      'observations': observations
          .map((observation) => observation.toJson())
          .toList(growable: false),
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

class InternalSignalExperimentRunner {
  const InternalSignalExperimentRunner({
    this.validator = const InternalSignalExperimentRunnerValidator(),
  });

  final InternalSignalExperimentRunnerValidator validator;

  InternalSignalExperimentRunnerResult run(
    InternalSignalExperimentRunnerRequest request,
  ) {
    if (request.experimentId.trim().isEmpty) {
      return _invalidRequestResult(request, 'experimentId is required');
    }

    final profileResult =
        request.profileResult ??
        request.profile.evaluate(
          InternalNonLabelSignalProfileRequest(
            androidProofEvidence: request.androidProofEvidence,
            cases: request.cases,
          ),
        );
    final consistencyResult =
        request.consistencyResult ??
        request.consistencyMatrix.evaluate(
          InternalSignalProfileConsistencyMatrixRequest(
            profileResult: profileResult,
            androidProofEvidence: request.androidProofEvidence,
            cases: request.cases,
          ),
        );
    final gatePassed = _consistencyGatePassed(consistencyResult);
    if (!gatePassed) {
      return _skippedByConsistencyGateResult(
        request: request,
        profileResult: profileResult,
        consistencyResult: consistencyResult,
      );
    }

    final observations = _buildObservations(
      request: request,
      profileResult: profileResult,
    );
    final warningMessages = _warningMessages(observations);
    final base = InternalSignalExperimentRunnerResult(
      runnerStatus: warningMessages.isEmpty
          ? InternalSignalExperimentRunnerStatus.completedInternalOnly
          : InternalSignalExperimentRunnerStatus.completedWithWarnings,
      experimentId: request.experimentId,
      consistencyMatrixStatus: consistencyResult.matrixStatus,
      profileStatus: profileResult.status,
      consistencyGatePassed: true,
      consistencyBlockerCount: consistencyResult.blockerCount,
      consistencyCriticalCount: consistencyResult.criticalCount,
      consistencySafeForExperiment:
          consistencyResult.safeForGuardedInternalExperiment,
      observations: observations,
      validationFindings:
          const <InternalSignalExperimentRunnerValidationFinding>[],
      warnings: _sortedStrings(<String>[
        ...profileResult.warnings,
        ...consistencyResult.warnings,
        ...warningMessages,
      ]),
      failures: _sortedStrings(<String>[
        ...profileResult.failures,
        ...consistencyResult.failures,
      ]),
      nextRecommendation: InternalSignalExperimentRunnerNextRecommendation
          .guardedInternalObservationReview,
      provenAndroidCaseIds: consistencyResult.provenAndroidCaseIds,
      unprovenAndroidCaseIds: consistencyResult.unprovenAndroidCaseIds,
      excludedScopeIds: consistencyResult.excludedScopeIds,
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
    final findings = validator.validate(
      base,
      consistencyResult: consistencyResult,
    );
    final blocked = findings.any((finding) => finding.blocksStrict);
    return base.copyWith(
      runnerStatus: blocked
          ? InternalSignalExperimentRunnerStatus.blocked
          : base.runnerStatus,
      validationFindings: findings,
      nextRecommendation: blocked
          ? InternalSignalExperimentRunnerNextRecommendation
                .consistencyEvidenceFixes
          : base.nextRecommendation,
    );
  }
}

class InternalSignalExperimentRunnerValidator {
  const InternalSignalExperimentRunnerValidator();

  List<InternalSignalExperimentRunnerValidationFinding> validate(
    InternalSignalExperimentRunnerResult result, {
    required InternalSignalProfileConsistencyMatrixResult consistencyResult,
  }) {
    final findings = <InternalSignalExperimentRunnerValidationFinding>[];

    void add({
      required String id,
      required InternalSignalExperimentRunnerValidationSeverity severity,
      required String message,
      InternalNonLabelSignalId? signalId,
      String? caseId,
    }) {
      findings.add(
        InternalSignalExperimentRunnerValidationFinding(
          id: id,
          severity: severity,
          message: message,
          signalId: signalId,
          caseId: caseId,
        ),
      );
    }

    final consistencyUnsafe =
        consistencyResult.blockerCount > 0 ||
        consistencyResult.criticalCount > 0 ||
        !consistencyResult.safeForGuardedInternalExperiment;
    if (consistencyUnsafe && result.observations.any((row) => row.observed)) {
      add(
        id: 'runnerObservedDespiteUnsafeConsistencyGate',
        severity: InternalSignalExperimentRunnerValidationSeverity.critical,
        message: 'runner observed signals despite unsafe consistency gate',
      );
    }

    for (final observation in result.observations) {
      if (observation.observed && observation.supportCaseIds.isEmpty) {
        add(
          id: 'activeObservationWithoutSupport',
          severity: InternalSignalExperimentRunnerValidationSeverity.blocker,
          message: '${observation.signalId.wire} has no support cases',
          signalId: observation.signalId,
        );
      }
      if (observation.isProductOutput ||
          observation.isClassifierLabel ||
          observation.emittedOutputNames.any(_isForbiddenOutputName)) {
        add(
          id: 'observationEmitsForbiddenLabel',
          severity: InternalSignalExperimentRunnerValidationSeverity.critical,
          message: '${observation.signalId.wire} emitted blocked output',
          signalId: observation.signalId,
        );
      }
      if (observation.hasNumericScore) {
        add(
          id: 'observationEmitsNumericScore',
          severity: InternalSignalExperimentRunnerValidationSeverity.critical,
          message: '${observation.signalId.wire} emitted a numeric score',
          signalId: observation.signalId,
        );
      }
      if (observation.ranksMoves) {
        add(
          id: 'observationRanksMoves',
          severity: InternalSignalExperimentRunnerValidationSeverity.critical,
          message: '${observation.signalId.wire} ranked moves',
          signalId: observation.signalId,
        );
      }
      if (observation.isOfficialMetric) {
        add(
          id: 'observationEmitsOfficialMetric',
          severity: InternalSignalExperimentRunnerValidationSeverity.critical,
          message: '${observation.signalId.wire} emitted official metric',
          signalId: observation.signalId,
        );
      }
      if (observation.quietScopeActive ||
          (observation.signalId ==
                  InternalNonLabelSignalId.quietPreparatorySignalExcluded &&
              observation.observed)) {
        add(
          id: 'quietPreparatoryObservationBecameActive',
          severity: InternalSignalExperimentRunnerValidationSeverity.critical,
          message: '${observation.signalId.wire} activated quiet scope',
          signalId: observation.signalId,
        );
      }
      if (observation.cpLossComputationImplemented ||
          observation.winProbabilityComputationImplemented) {
        add(
          id: 'futureComputationActivated',
          severity: InternalSignalExperimentRunnerValidationSeverity.critical,
          message: '${observation.signalId.wire} activated future computation',
          signalId: observation.signalId,
        );
      }
      for (final caseId in observation.androidProofCaseIds) {
        if (!result.provenAndroidCaseIds.contains(caseId)) {
          add(
            id: 'unprovenAndroidProofCitation',
            severity: InternalSignalExperimentRunnerValidationSeverity.blocker,
            message: '${observation.signalId.wire} cited unproven proof',
            signalId: observation.signalId,
            caseId: caseId,
          );
        }
      }
    }

    for (final caseId in result.unprovenAndroidCaseIds) {
      add(
        id: 'unprovenAndroidProofResultCitation',
        severity: InternalSignalExperimentRunnerValidationSeverity.blocker,
        message: 'unproven Android proof citation remains present',
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
        id: 'runnerBoundaryPolicyViolation',
        severity: InternalSignalExperimentRunnerValidationSeverity.critical,
        message: 'runner crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<InternalSignalExperimentRunnerValidationFinding> validateReportText(
    String reportText,
  ) {
    final findings = <InternalSignalExperimentRunnerValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        InternalSignalExperimentRunnerValidationFinding(
          id: id,
          severity: InternalSignalExperimentRunnerValidationSeverity.critical,
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

bool _consistencyGatePassed(
  InternalSignalProfileConsistencyMatrixResult result,
) {
  return result.blockerCount == 0 &&
      result.criticalCount == 0 &&
      result.safeForGuardedInternalExperiment &&
      !result.hasUnsafeConsistencyPolicyViolation;
}

InternalSignalExperimentRunnerResult _invalidRequestResult(
  InternalSignalExperimentRunnerRequest request,
  String failure,
) {
  return InternalSignalExperimentRunnerResult(
    runnerStatus: InternalSignalExperimentRunnerStatus.invalidRequest,
    experimentId: request.experimentId,
    consistencyMatrixStatus:
        InternalSignalProfileConsistencyMatrixStatus.consistentWithWarnings,
    profileStatus: InternalNonLabelSignalProfileStatus.readyWithWarnings,
    consistencyGatePassed: false,
    consistencyBlockerCount: 0,
    consistencyCriticalCount: 0,
    consistencySafeForExperiment: false,
    observations: const <InternalSignalExperimentObservation>[],
    validationFindings:
        const <InternalSignalExperimentRunnerValidationFinding>[],
    warnings: const <String>[],
    failures: <String>[failure],
    nextRecommendation: InternalSignalExperimentRunnerNextRecommendation
        .consistencyEvidenceFixes,
    provenAndroidCaseIds: const <String>[],
    unprovenAndroidCaseIds: const <String>[],
    excludedScopeIds: const <String>['quiet-preparatory-uncertain'],
  );
}

InternalSignalExperimentRunnerResult _skippedByConsistencyGateResult({
  required InternalSignalExperimentRunnerRequest request,
  required InternalNonLabelSignalProfileResult profileResult,
  required InternalSignalProfileConsistencyMatrixResult consistencyResult,
}) {
  return InternalSignalExperimentRunnerResult(
    runnerStatus: InternalSignalExperimentRunnerStatus.skippedByConsistencyGate,
    experimentId: request.experimentId,
    consistencyMatrixStatus: consistencyResult.matrixStatus,
    profileStatus: profileResult.status,
    consistencyGatePassed: false,
    consistencyBlockerCount: consistencyResult.blockerCount,
    consistencyCriticalCount: consistencyResult.criticalCount,
    consistencySafeForExperiment:
        consistencyResult.safeForGuardedInternalExperiment,
    observations: const <InternalSignalExperimentObservation>[],
    validationFindings:
        const <InternalSignalExperimentRunnerValidationFinding>[],
    warnings: consistencyResult.warnings,
    failures: _sortedStrings(<String>[
      ...profileResult.failures,
      ...consistencyResult.failures,
      'consistency gate blocked internal signal experiment runner',
    ]),
    nextRecommendation: InternalSignalExperimentRunnerNextRecommendation
        .consistencyEvidenceFixes,
    provenAndroidCaseIds: consistencyResult.provenAndroidCaseIds,
    unprovenAndroidCaseIds: consistencyResult.unprovenAndroidCaseIds,
    excludedScopeIds: consistencyResult.excludedScopeIds,
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

List<InternalSignalExperimentObservation> _buildObservations({
  required InternalSignalExperimentRunnerRequest request,
  required InternalNonLabelSignalProfileResult profileResult,
}) {
  final observations = <InternalSignalExperimentObservation>[];
  for (final signal in profileResult.signals) {
    final include = switch (signal.status) {
      InternalNonLabelSignalStatus.active => request.includeActiveSignals,
      InternalNonLabelSignalStatus.activeWithWarnings ||
      InternalNonLabelSignalStatus.partial => request.includeWarningSignals,
      InternalNonLabelSignalStatus.excluded ||
      InternalNonLabelSignalStatus.blockedByPolicy =>
        request.includeBlockedSignals,
      InternalNonLabelSignalStatus.futureOnly =>
        request.includeFutureOnlySignals,
      InternalNonLabelSignalStatus.inactive ||
      InternalNonLabelSignalStatus.invalid => false,
    };
    if (!include) continue;
    final observed =
        signal.status == InternalNonLabelSignalStatus.active ||
        signal.status == InternalNonLabelSignalStatus.activeWithWarnings ||
        signal.status == InternalNonLabelSignalStatus.partial;
    observations.add(
      InternalSignalExperimentObservation(
        signalId: signal.signalId,
        signalStatus: signal.status,
        qualitativeConfidence: signal.confidence,
        observed: observed,
        supportCaseIds: signal.supportingCaseIds,
        androidProofCaseIds: request.includeAndroidProofReferences
            ? _validAndroidProofIds(
                signal.androidProofCaseIds,
                profileResult.provenAndroidCaseIds,
              )
            : const <String>[],
        sourceDimensionIds: signal.sourceDimensionIds,
        evidenceAreaIds: signal.relatedAreaIds,
        bucketIds: signal.relatedBucketIds,
        warningReason: _joinedOrEmpty(signal.warningReasons),
        blockerReason: _joinedOrEmpty(signal.blockerReasons),
        futurePrerequisite: _joinedOrEmpty(signal.futurePrerequisites),
        isProductOutput: signal.emitsProductLabel,
        isClassifierLabel: signal.emitsClassifierLabel,
        isOfficialMetric: signal.claimsOfficialMetrics,
        hasNumericScore: signal.hasNumericMoveScore,
        ranksMoves: signal.ranksMoves,
        quietScopeActive: signal.quietScopeActive,
        cpLossComputationImplemented: signal.cpLossComputationImplemented,
        winProbabilityComputationImplemented:
            signal.winProbabilityComputationImplemented,
        emittedOutputNames: signal.emittedOutputNames,
      ),
    );
  }
  return List<InternalSignalExperimentObservation>.unmodifiable(
    observations..sort((a, b) => a.signalId.index.compareTo(b.signalId.index)),
  );
}

List<String> _validAndroidProofIds(
  Iterable<String> caseIds,
  Iterable<String> provenCaseIds,
) {
  final proven = provenCaseIds.toSet();
  return _sortedStrings(caseIds.where(proven.contains));
}

List<String> _warningMessages(
  Iterable<InternalSignalExperimentObservation> observations,
) {
  return _sortedStrings(
    observations
        .where((observation) => observation.isWarningObservation)
        .map(
          (observation) =>
              '${observation.signalId.wire}: ${observation.warningReason.isEmpty ? observation.futurePrerequisite : observation.warningReason}',
        ),
  );
}

String _observationIds(Iterable<InternalSignalExperimentObservation> values) {
  final ids = values.map((value) => value.signalId.wire).toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _ids(Iterable<String> values) {
  final sorted = _sortedStrings(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

String _joinedOrEmpty(Iterable<String> values) {
  final sorted = _sortedStrings(values);
  return sorted.join(', ');
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.toSet().toList()..sort();
}

int _compareFindings(
  InternalSignalExperimentRunnerValidationFinding a,
  InternalSignalExperimentRunnerValidationFinding b,
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

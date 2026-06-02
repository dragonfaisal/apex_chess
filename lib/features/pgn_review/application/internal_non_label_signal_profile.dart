/// Developer-only qualitative signal profile prototype.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/basic_classifier_evidence_contract.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_review.dart';
import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_guards.dart';
import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_harness.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_scoring_design.dart';

const internalNonLabelSignalProfileReportVersion =
    'internal-non-label-signal-profile-v1';

enum InternalNonLabelSignalId {
  tacticalPressureSignal('tacticalPressureSignal'),
  materialSwingSignal('materialSwingSignal'),
  forcingLineSignal('forcingLineSignal'),
  kingSafetySignal('kingSafetySignal'),
  candidateSpreadSignal('candidateSpreadSignal'),
  pvMultiPvSupportSignal('pvMultiPvSupportSignal'),
  androidProofConfidenceSignal('androidProofConfidenceSignal'),
  endgameSupportSignal('endgameSupportSignal'),
  suppressionSafetySignal('suppressionSafetySignal'),
  budgetRiskSignal('budgetRiskSignal'),
  quietPreparatorySignalExcluded('quietPreparatorySignalExcluded'),
  productLabelSignalBlocked('productLabelSignalBlocked'),
  advancedLabelSignalBlocked('advancedLabelSignalBlocked'),
  officialMetricSignalBlocked('officialMetricSignalBlocked'),
  cpLossSignalFutureOnly('cpLossSignalFutureOnly'),
  winProbabilitySignalFutureOnly('winProbabilitySignalFutureOnly');

  const InternalNonLabelSignalId(this.wire);

  final String wire;
}

enum InternalNonLabelSignalStatus {
  active('active'),
  activeWithWarnings('activeWithWarnings'),
  partial('partial'),
  excluded('excluded'),
  blockedByPolicy('blockedByPolicy'),
  futureOnly('futureOnly'),
  inactive('inactive'),
  invalid('invalid');

  const InternalNonLabelSignalStatus(this.wire);

  final String wire;
}

enum InternalNonLabelSignalConfidence {
  highConfidence('highConfidence'),
  mediumConfidence('mediumConfidence'),
  lowConfidence('lowConfidence'),
  warningOnly('warningOnly'),
  excluded('excluded'),
  blocked('blocked'),
  futureOnly('futureOnly');

  const InternalNonLabelSignalConfidence(this.wire);

  final String wire;
}

enum InternalNonLabelSignalProfileStatus {
  profileReadyInternalOnly('profileReadyInternalOnly'),
  readyWithWarnings('readyWithWarnings'),
  blockedByDesign('blockedByDesign'),
  blockedByValidation('blockedByValidation'),
  invalid('invalid');

  const InternalNonLabelSignalProfileStatus(this.wire);

  final String wire;
}

enum InternalNonLabelSignalProfileValidationSeverity {
  warning('warning'),
  error('error');

  const InternalNonLabelSignalProfileValidationSeverity(this.wire);

  final String wire;
}

enum InternalNonLabelSignalProfileReportFormat {
  markdown('markdown'),
  json('json');

  const InternalNonLabelSignalProfileReportFormat(this.wire);

  final String wire;
}

enum InternalNonLabelSignalProfileNextPhase {
  guardedInternalSignalExperiments(
    'Phase 31I -- Guarded Internal Non-Label Signal Experiments',
  ),
  signalProfileEvidenceFixes('Phase 31I -- Signal Profile Evidence Fixes');

  const InternalNonLabelSignalProfileNextPhase(this.wire);

  final String wire;
}

class InternalNonLabelSignalProfileRequest {
  const InternalNonLabelSignalProfileRequest({
    this.designResult,
    this.matrixRequest = const InternalEvidenceAreaCoverageMatrixRequest(),
    this.matrixResult,
    this.harnessResult,
    this.bucketPrototype,
    this.contract,
    this.review,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.cases = GoldenAnalysisCases.defaults,
    this.design = const InternalNonLabelScoringDesign(),
    this.matrix = const InternalEvidenceAreaCoverageMatrix(),
    this.bucketBuilder = const InternalEvidenceBucketBuilder(),
    this.contractBuilder = const BasicClassifierEvidenceContractBuilder(),
    this.reviewRunner = const GoldenEvidenceReviewRunner(),
  });

  final InternalNonLabelScoringDesignResult? designResult;
  final InternalEvidenceAreaCoverageMatrixRequest matrixRequest;
  final InternalEvidenceAreaCoverageMatrixResult? matrixResult;
  final InternalBucketExperimentHarnessResult? harnessResult;
  final InternalEvidenceBucketPrototype? bucketPrototype;
  final BasicClassifierEvidenceContractPrototype? contract;
  final GoldenEvidenceReviewResult? review;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final List<GoldenAnalysisCase> cases;
  final InternalNonLabelScoringDesign design;
  final InternalEvidenceAreaCoverageMatrix matrix;
  final InternalEvidenceBucketBuilder bucketBuilder;
  final BasicClassifierEvidenceContractBuilder contractBuilder;
  final GoldenEvidenceReviewRunner reviewRunner;
}

class InternalNonLabelSignalProfileEntry {
  const InternalNonLabelSignalProfileEntry({
    required this.signalId,
    required this.status,
    required this.confidence,
    required this.sourceDimensionIds,
    required this.relatedAreaIds,
    required this.relatedBucketIds,
    required this.supportingCaseIds,
    required this.protectedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.confidenceReason,
    required this.warningReasons,
    required this.blockerReasons,
    required this.futurePrerequisites,
    this.emitsProductLabel = false,
    this.emitsClassifierLabel = false,
    this.emitsFinalMoveLabel = false,
    this.hasNumericMoveScore = false,
    this.ranksMoves = false,
    this.claimsOfficialMetrics = false,
    this.cpLossComputationImplemented = false,
    this.winProbabilityComputationImplemented = false,
    this.quietScopeActive = false,
    this.productLabelsActive = false,
    this.advancedLabelsActive = false,
    this.officialMetricsActive = false,
    this.emittedOutputNames = const <String>[],
  });

  final InternalNonLabelSignalId signalId;
  final InternalNonLabelSignalStatus status;
  final InternalNonLabelSignalConfidence confidence;
  final List<InternalNonLabelScoringDimensionId> sourceDimensionIds;
  final List<InternalEvidenceAreaId> relatedAreaIds;
  final List<InternalEvidenceBucketId> relatedBucketIds;
  final List<String> supportingCaseIds;
  final List<String> protectedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final String confidenceReason;
  final List<String> warningReasons;
  final List<String> blockerReasons;
  final List<String> futurePrerequisites;
  final bool emitsProductLabel;
  final bool emitsClassifierLabel;
  final bool emitsFinalMoveLabel;
  final bool hasNumericMoveScore;
  final bool ranksMoves;
  final bool claimsOfficialMetrics;
  final bool cpLossComputationImplemented;
  final bool winProbabilityComputationImplemented;
  final bool quietScopeActive;
  final bool productLabelsActive;
  final bool advancedLabelsActive;
  final bool officialMetricsActive;
  final List<String> emittedOutputNames;

  bool get isActive =>
      status == InternalNonLabelSignalStatus.active ||
      status == InternalNonLabelSignalStatus.activeWithWarnings;

  bool get hasUnsafeSignalPolicyViolation {
    return emitsProductLabel ||
        emitsClassifierLabel ||
        emitsFinalMoveLabel ||
        hasNumericMoveScore ||
        ranksMoves ||
        claimsOfficialMetrics ||
        cpLossComputationImplemented ||
        winProbabilityComputationImplemented ||
        quietScopeActive ||
        productLabelsActive ||
        advancedLabelsActive ||
        officialMetricsActive ||
        emittedOutputNames.any(_isForbiddenEmittedOutput);
  }

  InternalNonLabelSignalProfileEntry copyWith({
    InternalNonLabelSignalId? signalId,
    InternalNonLabelSignalStatus? status,
    InternalNonLabelSignalConfidence? confidence,
    List<InternalNonLabelScoringDimensionId>? sourceDimensionIds,
    List<InternalEvidenceAreaId>? relatedAreaIds,
    List<InternalEvidenceBucketId>? relatedBucketIds,
    List<String>? supportingCaseIds,
    List<String>? protectedSupportCaseIds,
    List<String>? androidProofCaseIds,
    String? confidenceReason,
    List<String>? warningReasons,
    List<String>? blockerReasons,
    List<String>? futurePrerequisites,
    bool? emitsProductLabel,
    bool? emitsClassifierLabel,
    bool? emitsFinalMoveLabel,
    bool? hasNumericMoveScore,
    bool? ranksMoves,
    bool? claimsOfficialMetrics,
    bool? cpLossComputationImplemented,
    bool? winProbabilityComputationImplemented,
    bool? quietScopeActive,
    bool? productLabelsActive,
    bool? advancedLabelsActive,
    bool? officialMetricsActive,
    List<String>? emittedOutputNames,
  }) {
    return InternalNonLabelSignalProfileEntry(
      signalId: signalId ?? this.signalId,
      status: status ?? this.status,
      confidence: confidence ?? this.confidence,
      sourceDimensionIds: sourceDimensionIds ?? this.sourceDimensionIds,
      relatedAreaIds: relatedAreaIds ?? this.relatedAreaIds,
      relatedBucketIds: relatedBucketIds ?? this.relatedBucketIds,
      supportingCaseIds: supportingCaseIds ?? this.supportingCaseIds,
      protectedSupportCaseIds:
          protectedSupportCaseIds ?? this.protectedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      confidenceReason: confidenceReason ?? this.confidenceReason,
      warningReasons: warningReasons ?? this.warningReasons,
      blockerReasons: blockerReasons ?? this.blockerReasons,
      futurePrerequisites: futurePrerequisites ?? this.futurePrerequisites,
      emitsProductLabel: emitsProductLabel ?? this.emitsProductLabel,
      emitsClassifierLabel: emitsClassifierLabel ?? this.emitsClassifierLabel,
      emitsFinalMoveLabel: emitsFinalMoveLabel ?? this.emitsFinalMoveLabel,
      hasNumericMoveScore: hasNumericMoveScore ?? this.hasNumericMoveScore,
      ranksMoves: ranksMoves ?? this.ranksMoves,
      claimsOfficialMetrics:
          claimsOfficialMetrics ?? this.claimsOfficialMetrics,
      cpLossComputationImplemented:
          cpLossComputationImplemented ?? this.cpLossComputationImplemented,
      winProbabilityComputationImplemented:
          winProbabilityComputationImplemented ??
          this.winProbabilityComputationImplemented,
      quietScopeActive: quietScopeActive ?? this.quietScopeActive,
      productLabelsActive: productLabelsActive ?? this.productLabelsActive,
      advancedLabelsActive: advancedLabelsActive ?? this.advancedLabelsActive,
      officialMetricsActive:
          officialMetricsActive ?? this.officialMetricsActive,
      emittedOutputNames: emittedOutputNames ?? this.emittedOutputNames,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'signalId': signalId.wire,
      'status': status.wire,
      'confidence': confidence.wire,
      'sourceDimensionIds': sourceDimensionIds.map((id) => id.wire).toList(),
      'relatedAreaIds': relatedAreaIds.map((id) => id.wire).toList(),
      'relatedBucketIds': relatedBucketIds.map((id) => id.wire).toList(),
      'supportingCaseIds': supportingCaseIds,
      'protectedSupportCaseIds': protectedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'confidenceReason': confidenceReason,
      'warningReasons': warningReasons,
      'blockerReasons': blockerReasons,
      'futurePrerequisites': futurePrerequisites,
      'emitsProductLabel': emitsProductLabel,
      'emitsClassifierLabel': emitsClassifierLabel,
      'emitsFinalMoveLabel': emitsFinalMoveLabel,
      'hasNumericMoveScore': hasNumericMoveScore,
      'ranksMoves': ranksMoves,
      'claimsOfficialMetrics': claimsOfficialMetrics,
      'cpLossComputationImplemented': cpLossComputationImplemented,
      'winProbabilityComputationImplemented':
          winProbabilityComputationImplemented,
      'quietScopeActive': quietScopeActive,
      'productLabelsActive': productLabelsActive,
      'advancedLabelsActive': advancedLabelsActive,
      'officialMetricsActive': officialMetricsActive,
      'emittedOutputNames': emittedOutputNames,
    };
  }
}

class InternalNonLabelSignalProfileValidationFinding {
  const InternalNonLabelSignalProfileValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.signalId,
    this.caseId,
  });

  final String id;
  final InternalNonLabelSignalProfileValidationSeverity severity;
  final String message;
  final InternalNonLabelSignalId? signalId;
  final String? caseId;

  bool get isError =>
      severity == InternalNonLabelSignalProfileValidationSeverity.error;

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

class InternalNonLabelSignalProfileResult {
  const InternalNonLabelSignalProfileResult({
    required this.status,
    required this.scoringDesignStatus,
    required this.matrixStatus,
    required this.harnessStatus,
    required this.guardStatus,
    required this.guardAllowed,
    required this.signalCount,
    required this.signals,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.nextRecommendedPhase,
    required this.provenAndroidCaseIds,
    required this.unprovenAndroidCaseIds,
    required this.excludedScopeIds,
    this.developerOnly = true,
    this.safeForFutureInternalExperiments = true,
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

  final InternalNonLabelSignalProfileStatus status;
  final InternalNonLabelScoringDesignStatus scoringDesignStatus;
  final InternalEvidenceAreaCoverageMatrixStatus matrixStatus;
  final InternalBucketExperimentHarnessStatus harnessStatus;
  final InternalBucketExperimentGuardStatus guardStatus;
  final bool guardAllowed;
  final int signalCount;
  final List<InternalNonLabelSignalProfileEntry> signals;
  final List<InternalNonLabelSignalProfileValidationFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final InternalNonLabelSignalProfileNextPhase nextRecommendedPhase;
  final List<String> provenAndroidCaseIds;
  final List<String> unprovenAndroidCaseIds;
  final List<String> excludedScopeIds;
  final bool developerOnly;
  final bool safeForFutureInternalExperiments;
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

  bool get hasValidationErrors =>
      validationFindings.any((finding) => finding.isError);

  bool get hasWarnings =>
      warnings.isNotEmpty ||
      validationFindings.any(
        (finding) =>
            finding.severity ==
            InternalNonLabelSignalProfileValidationSeverity.warning,
      ) ||
      signals.any((signal) => signal.warningReasons.isNotEmpty);

  bool get isStrictlyBlocked =>
      status == InternalNonLabelSignalProfileStatus.blockedByDesign ||
      status == InternalNonLabelSignalProfileStatus.blockedByValidation ||
      status == InternalNonLabelSignalProfileStatus.invalid;

  bool get hasUnsafeSignalProfilePolicyViolation {
    return hasValidationErrors ||
        signals.any((signal) => signal.hasUnsafeSignalPolicyViolation) ||
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
        emittedOutputFamilies.any(_isForbiddenEmittedOutput);
  }

  InternalNonLabelSignalProfileEntry signal(InternalNonLabelSignalId id) {
    return signals.singleWhere((signal) => signal.signalId == id);
  }

  List<InternalNonLabelSignalProfileEntry> get activeSignals => signals
      .where((signal) => signal.status == InternalNonLabelSignalStatus.active)
      .toList(growable: false);

  List<InternalNonLabelSignalProfileEntry> get warningSignals => signals
      .where(
        (signal) =>
            signal.status == InternalNonLabelSignalStatus.activeWithWarnings ||
            signal.status == InternalNonLabelSignalStatus.partial,
      )
      .toList(growable: false);

  InternalNonLabelSignalProfileResult copyWith({
    InternalNonLabelSignalProfileStatus? status,
    InternalNonLabelScoringDesignStatus? scoringDesignStatus,
    InternalEvidenceAreaCoverageMatrixStatus? matrixStatus,
    InternalBucketExperimentHarnessStatus? harnessStatus,
    InternalBucketExperimentGuardStatus? guardStatus,
    bool? guardAllowed,
    int? signalCount,
    List<InternalNonLabelSignalProfileEntry>? signals,
    List<InternalNonLabelSignalProfileValidationFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    InternalNonLabelSignalProfileNextPhase? nextRecommendedPhase,
    List<String>? provenAndroidCaseIds,
    List<String>? unprovenAndroidCaseIds,
    List<String>? excludedScopeIds,
    bool? developerOnly,
    bool? safeForFutureInternalExperiments,
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
    final effectiveSignals = signals ?? this.signals;
    return InternalNonLabelSignalProfileResult(
      status: status ?? this.status,
      scoringDesignStatus: scoringDesignStatus ?? this.scoringDesignStatus,
      matrixStatus: matrixStatus ?? this.matrixStatus,
      harnessStatus: harnessStatus ?? this.harnessStatus,
      guardStatus: guardStatus ?? this.guardStatus,
      guardAllowed: guardAllowed ?? this.guardAllowed,
      signalCount: signalCount ?? effectiveSignals.length,
      signals: effectiveSignals,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      nextRecommendedPhase: nextRecommendedPhase ?? this.nextRecommendedPhase,
      provenAndroidCaseIds: provenAndroidCaseIds ?? this.provenAndroidCaseIds,
      unprovenAndroidCaseIds:
          unprovenAndroidCaseIds ?? this.unprovenAndroidCaseIds,
      excludedScopeIds: excludedScopeIds ?? this.excludedScopeIds,
      developerOnly: developerOnly ?? this.developerOnly,
      safeForFutureInternalExperiments:
          safeForFutureInternalExperiments ??
          this.safeForFutureInternalExperiments,
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
      ..writeln('# Internal Non-Label Signal Profile')
      ..writeln()
      ..writeln('- version: $internalNonLabelSignalProfileReportVersion')
      ..writeln('- profile status: ${status.wire}')
      ..writeln('- scoring design status: ${scoringDesignStatus.wire}')
      ..writeln('- matrix status: ${matrixStatus.wire}')
      ..writeln('- harness status: ${harnessStatus.wire}')
      ..writeln('- guard status: ${guardStatus.wire}')
      ..writeln('- guard allowed: $guardAllowed')
      ..writeln('- developer only: $developerOnly')
      ..writeln(
        '- safe for future internal-only experiments: '
        '$safeForFutureInternalExperiments',
      )
      ..writeln('- classifier output emitted: false')
      ..writeln('- numeric score values emitted: false')
      ..writeln('- move ranking emitted: false')
      ..writeln()
      ..writeln('## Qualitative Signal Policy')
      ..writeln(
        '- signals use qualitative confidence only: highConfidence, '
        'mediumConfidence, lowConfidence, warningOnly, excluded, blocked, '
        'and futureOnly',
      )
      ..writeln(
        '- the profile records internal evidence signals only; it does not '
        'judge move quality, compute scores, rank moves, create thresholds, '
        'call an engine, or write files',
      )
      ..writeln()
      ..writeln('## Signal Table')
      ..writeln(
        '| Signal | Status | Confidence | Source Dimensions | Support Cases | Android Proof | Warning | Blocker | Future Prerequisites |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- | --- |');
    if (signals.isEmpty) {
      buffer.writeln('| - | - | - | - | - | - | - | - | - |');
    } else {
      for (final signal in signals) {
        buffer.writeln(
          '| ${signal.signalId.wire} | ${signal.status.wire} | '
          '${signal.confidence.wire} | '
          '${_dimensionIds(signal.sourceDimensionIds)} | '
          '${_ids(signal.supportingCaseIds)} | '
          '${_ids(signal.androidProofCaseIds)} | '
          '${_ids(signal.warningReasons)} | '
          '${_ids(signal.blockerReasons)} | '
          '${_ids(signal.futurePrerequisites)} |',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('## Signal Source Mapping');
    for (final signal in signals) {
      buffer.writeln(
        '- ${signal.signalId.wire}: dimensions '
        '${_dimensionIds(signal.sourceDimensionIds)}; areas '
        '${_areaIds(signal.relatedAreaIds)}; buckets '
        '${_bucketIds(signal.relatedBucketIds)}',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Support Cases');
    for (final signal in signals) {
      buffer.writeln(
        '- ${signal.signalId.wire}: ${_ids(signal.supportingCaseIds)}',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Android Proof Support')
      ..writeln('- proven case IDs: ${_ids(provenAndroidCaseIds)}')
      ..writeln('- unproven case IDs: ${_ids(unprovenAndroidCaseIds)}')
      ..writeln()
      ..writeln('## Signal Status Summary')
      ..writeln('- active: ${_signalIds(activeSignals)}')
      ..writeln('- warning or partial: ${_signalIds(warningSignals)}')
      ..writeln(
        '- excluded: ${_signalIds(signals.where((signal) => signal.status == InternalNonLabelSignalStatus.excluded))}',
      )
      ..writeln(
        '- blocked: ${_signalIds(signals.where((signal) => signal.status == InternalNonLabelSignalStatus.blockedByPolicy))}',
      )
      ..writeln(
        '- future-only: ${_signalIds(signals.where((signal) => signal.status == InternalNonLabelSignalStatus.futureOnly))}',
      )
      ..writeln()
      ..writeln('## Future Prerequisites');
    var wrotePrerequisite = false;
    for (final signal in signals) {
      if (signal.futurePrerequisites.isEmpty) continue;
      wrotePrerequisite = true;
      buffer.writeln(
        '- ${signal.signalId.wire}: '
        '${signal.futurePrerequisites.join("; ")}',
      );
    }
    if (!wrotePrerequisite) {
      buffer.writeln('- none');
    }

    buffer
      ..writeln()
      ..writeln('## Excluded Blocked And Future Signals')
      ..writeln('- quiet/preparatory exclusion: ${_ids(excludedScopeIds)}')
      ..writeln('- product-label signal: blocked')
      ..writeln('- advanced-label signal: blocked')
      ..writeln('- official-metric signal: blocked')
      ..writeln('- CP-loss signal: future-only')
      ..writeln('- win-probability signal: future-only')
      ..writeln()
      ..writeln('## Validation');
    if (validationFindings.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final finding in validationFindings) {
        buffer.writeln(
          '- ${finding.severity.wire}: ${finding.id}: ${finding.message}',
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
      ..writeln(nextRecommendedPhase.wire)
      ..writeln()
      ..writeln(
        'This profile defines internal qualitative signal availability only. '
        'It does not judge move quality, emit user-facing output, compute '
        'product metrics, call the engine, run Android, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    final payload = <String, Object?>{
      'version': internalNonLabelSignalProfileReportVersion,
      'profileStatus': status.wire,
      'scoringDesignStatus': scoringDesignStatus.wire,
      'matrixStatus': matrixStatus.wire,
      'harnessStatus': harnessStatus.wire,
      'guardStatus': guardStatus.wire,
      'guardAllowed': guardAllowed,
      'signalCount': signalCount,
      'signals': signals.map((signal) => signal.toJson()).toList(),
      'validationFindings': validationFindings
          .map((finding) => finding.toJson())
          .toList(),
      'warnings': warnings,
      'failures': failures,
      'nextRecommendedPhase': nextRecommendedPhase.wire,
      'provenAndroidCaseIds': provenAndroidCaseIds,
      'unprovenAndroidCaseIds': unprovenAndroidCaseIds,
      'excludedScopeIds': excludedScopeIds,
      'developerOnly': developerOnly,
      'safeForFutureInternalExperiments': safeForFutureInternalExperiments,
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

class InternalNonLabelSignalProfilePrototype {
  const InternalNonLabelSignalProfilePrototype({
    this.validator = const InternalNonLabelSignalProfileValidator(),
  });

  final InternalNonLabelSignalProfileValidator validator;

  InternalNonLabelSignalProfileResult evaluate(
    InternalNonLabelSignalProfileRequest request,
  ) {
    final designResult =
        request.designResult ??
        request.design.evaluate(
          InternalNonLabelScoringDesignRequest(
            matrixRequest: request.matrixRequest,
            matrixResult: request.matrixResult,
            harnessResult: request.harnessResult,
            bucketPrototype: request.bucketPrototype,
            contract: request.contract,
            review: request.review,
            androidProofEvidence: request.androidProofEvidence,
            cases: request.cases,
            matrix: request.matrix,
            bucketBuilder: request.bucketBuilder,
            contractBuilder: request.contractBuilder,
            reviewRunner: request.reviewRunner,
          ),
        );
    if (designResult.isStrictlyBlocked) {
      return _blockedByDesignResult(designResult);
    }

    final signals = _buildSignals(designResult);
    final base = InternalNonLabelSignalProfileResult(
      status: InternalNonLabelSignalProfileStatus.profileReadyInternalOnly,
      scoringDesignStatus: designResult.status,
      matrixStatus: designResult.matrixStatus,
      harnessStatus: designResult.harnessStatus,
      guardStatus: designResult.guardStatus,
      guardAllowed: designResult.guardAllowed,
      signalCount: signals.length,
      signals: signals,
      validationFindings:
          const <InternalNonLabelSignalProfileValidationFinding>[],
      warnings: _sortedStrings(designResult.warnings),
      failures: designResult.failures,
      nextRecommendedPhase: InternalNonLabelSignalProfileNextPhase
          .guardedInternalSignalExperiments,
      provenAndroidCaseIds: designResult.provenAndroidCaseIds,
      unprovenAndroidCaseIds: designResult.unprovenAndroidCaseIds,
      excludedScopeIds: designResult.excludedScopeIds,
      productLabelsEmitted: designResult.productLabelsEmitted,
      classifierLabelsEmitted: designResult.classifierLabelsEmitted,
      finalMoveLabelsEmitted: designResult.finalMoveLabelsEmitted,
      officialMetricsAllowed: designResult.officialMetricsAllowed,
      cpLossComputationImplemented: designResult.cpLossComputationImplemented,
      winProbabilityComputationImplemented:
          designResult.winProbabilityComputationImplemented,
      numericMoveScoresComputed: designResult.numericMoveScoresComputed,
      moveRankingComputed: false,
      directEngineAccessUsed: designResult.directEngineAccessUsed,
      uiOutputUsed: designResult.uiOutputUsed,
      backendOutputUsed: designResult.backendOutputUsed,
      persistenceUsed: designResult.persistenceUsed,
      emittedOutputFamilies: designResult.emittedOutputFamilies,
    );
    final findings = validator.validate(base);
    final status = _profileStatusFor(base, findings);
    return base.copyWith(
      status: status,
      validationFindings: findings,
      safeForFutureInternalExperiments: !base
          .copyWith(status: status, validationFindings: findings)
          .hasUnsafeSignalProfilePolicyViolation,
      nextRecommendedPhase: findings.any((finding) => finding.isError)
          ? InternalNonLabelSignalProfileNextPhase.signalProfileEvidenceFixes
          : InternalNonLabelSignalProfileNextPhase
                .guardedInternalSignalExperiments,
    );
  }
}

class InternalNonLabelSignalProfileValidator {
  const InternalNonLabelSignalProfileValidator();

  List<InternalNonLabelSignalProfileValidationFinding> validate(
    InternalNonLabelSignalProfileResult result,
  ) {
    final findings = <InternalNonLabelSignalProfileValidationFinding>[];

    void error({
      required String id,
      required String message,
      InternalNonLabelSignalId? signalId,
      String? caseId,
    }) {
      findings.add(
        InternalNonLabelSignalProfileValidationFinding(
          id: id,
          severity: InternalNonLabelSignalProfileValidationSeverity.error,
          message: message,
          signalId: signalId,
          caseId: caseId,
        ),
      );
    }

    for (final signal in result.signals) {
      if (signal.isActive && signal.supportingCaseIds.isEmpty) {
        error(
          id: 'activeSignalWithoutCases',
          message: '${signal.signalId.wire} cannot be active without cases',
          signalId: signal.signalId,
        );
      }
      if (signal.emitsProductLabel ||
          signal.emitsClassifierLabel ||
          signal.emitsFinalMoveLabel) {
        error(
          id: 'signalEmitsLabel',
          message: '${signal.signalId.wire} cannot emit labels',
          signalId: signal.signalId,
        );
      }
      if (signal.hasNumericMoveScore) {
        error(
          id: 'signalEmitsNumericScore',
          message: '${signal.signalId.wire} cannot emit numeric scores',
          signalId: signal.signalId,
        );
      }
      if (signal.ranksMoves) {
        error(
          id: 'signalRanksMoves',
          message: '${signal.signalId.wire} cannot rank moves',
          signalId: signal.signalId,
        );
      }
      if (signal.claimsOfficialMetrics || signal.officialMetricsActive) {
        error(
          id: 'signalClaimsOfficialMetric',
          message: '${signal.signalId.wire} cannot claim metrics',
          signalId: signal.signalId,
        );
      }
      if (signal.cpLossComputationImplemented ||
          signal.winProbabilityComputationImplemented) {
        error(
          id: 'futureComputationMarkedImplemented',
          message:
              '${signal.signalId.wire} cannot mark future computation '
              'implemented',
          signalId: signal.signalId,
        );
      }
      if (signal.quietScopeActive) {
        error(
          id: 'quietSignalBecameActive',
          message: '${signal.signalId.wire} cannot activate quiet scope',
          signalId: signal.signalId,
        );
      }
      if (signal.productLabelsActive || signal.advancedLabelsActive) {
        error(
          id: 'labelPolicySignalBecameActive',
          message: '${signal.signalId.wire} cannot activate label policy',
          signalId: signal.signalId,
        );
      }
      for (final output in signal.emittedOutputNames) {
        if (_isForbiddenEmittedOutput(output)) {
          error(
            id: 'forbiddenSignalOutputName',
            message: 'forbidden output name emitted: $output',
            signalId: signal.signalId,
          );
        }
      }
      for (final caseId in signal.androidProofCaseIds) {
        if (!result.provenAndroidCaseIds.contains(caseId)) {
          error(
            id: 'unprovenAndroidProofSupport',
            message: 'Android proof support must use proven cases only',
            signalId: signal.signalId,
            caseId: caseId,
          );
        }
      }
    }

    final quiet = _signalOrNull(
      result.signals,
      InternalNonLabelSignalId.quietPreparatorySignalExcluded,
    );
    if (quiet != null &&
        quiet.status != InternalNonLabelSignalStatus.excluded) {
      error(
        id: 'quietSignalNotExcluded',
        message: 'quiet/preparatory signal must remain excluded',
        signalId: quiet.signalId,
      );
    }

    for (final id in const <InternalNonLabelSignalId>[
      InternalNonLabelSignalId.productLabelSignalBlocked,
      InternalNonLabelSignalId.advancedLabelSignalBlocked,
      InternalNonLabelSignalId.officialMetricSignalBlocked,
    ]) {
      final signal = _signalOrNull(result.signals, id);
      if (signal != null &&
          signal.status != InternalNonLabelSignalStatus.blockedByPolicy) {
        error(
          id: 'policySignalNotBlocked',
          message: '${id.wire} must remain blocked by policy',
          signalId: id,
        );
      }
    }

    for (final id in const <InternalNonLabelSignalId>[
      InternalNonLabelSignalId.cpLossSignalFutureOnly,
      InternalNonLabelSignalId.winProbabilitySignalFutureOnly,
    ]) {
      final signal = _signalOrNull(result.signals, id);
      if (signal != null &&
          signal.status != InternalNonLabelSignalStatus.futureOnly) {
        error(
          id: 'futureSignalNotFutureOnly',
          message: '${id.wire} must remain future-only',
          signalId: id,
        );
      }
    }

    final android = _signalOrNull(
      result.signals,
      InternalNonLabelSignalId.androidProofConfidenceSignal,
    );
    if (android != null) {
      final proof = android.androidProofCaseIds.toSet();
      for (final caseId in android.supportingCaseIds) {
        if (!proof.contains(caseId)) {
          error(
            id: 'androidConfidenceUsesUnprovenCase',
            message: 'Android confidence signal cannot cite unproven cases',
            signalId: android.signalId,
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
        result.numericMoveScoresComputed ||
        result.moveRankingComputed ||
        result.directEngineAccessUsed ||
        result.uiOutputUsed ||
        result.backendOutputUsed ||
        result.persistenceUsed) {
      error(
        id: 'profileOutputPolicyViolation',
        message: 'signal profile crossed a blocked boundary',
      );
    }

    for (final output in result.emittedOutputFamilies) {
      if (_isForbiddenEmittedOutput(output)) {
        error(
          id: 'forbiddenOutputFamily',
          message: 'forbidden output family emitted: $output',
        );
      }
    }

    for (final caseId in result.unprovenAndroidCaseIds) {
      error(
        id: 'unprovenAndroidProofCitation',
        message: 'unproven Android proof citation is blocked',
        signalId: InternalNonLabelSignalId.androidProofConfidenceSignal,
        caseId: caseId,
      );
    }

    return findings..sort(_compareFindings);
  }

  List<InternalNonLabelSignalProfileValidationFinding> validateReportText(
    String reportText,
  ) {
    final findings = <InternalNonLabelSignalProfileValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        InternalNonLabelSignalProfileValidationFinding(
          id: id,
          severity: InternalNonLabelSignalProfileValidationSeverity.error,
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
    return findings..sort(_compareFindings);
  }
}

InternalNonLabelSignalProfileResult _blockedByDesignResult(
  InternalNonLabelScoringDesignResult designResult,
) {
  return InternalNonLabelSignalProfileResult(
    status: InternalNonLabelSignalProfileStatus.blockedByDesign,
    scoringDesignStatus: designResult.status,
    matrixStatus: designResult.matrixStatus,
    harnessStatus: designResult.harnessStatus,
    guardStatus: designResult.guardStatus,
    guardAllowed: designResult.guardAllowed,
    signalCount: 0,
    signals: const <InternalNonLabelSignalProfileEntry>[],
    validationFindings:
        const <InternalNonLabelSignalProfileValidationFinding>[],
    warnings: designResult.warnings,
    failures: _sortedStrings(<String>[
      ...designResult.failures,
      'scoring design did not complete an internal-only profile input',
    ]),
    nextRecommendedPhase:
        InternalNonLabelSignalProfileNextPhase.signalProfileEvidenceFixes,
    provenAndroidCaseIds: designResult.provenAndroidCaseIds,
    unprovenAndroidCaseIds: designResult.unprovenAndroidCaseIds,
    excludedScopeIds: designResult.excludedScopeIds,
    safeForFutureInternalExperiments: false,
    productLabelsEmitted: designResult.productLabelsEmitted,
    classifierLabelsEmitted: designResult.classifierLabelsEmitted,
    finalMoveLabelsEmitted: designResult.finalMoveLabelsEmitted,
    officialMetricsAllowed: designResult.officialMetricsAllowed,
    cpLossComputationImplemented: designResult.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        designResult.winProbabilityComputationImplemented,
    numericMoveScoresComputed: designResult.numericMoveScoresComputed,
    directEngineAccessUsed: designResult.directEngineAccessUsed,
    uiOutputUsed: designResult.uiOutputUsed,
    backendOutputUsed: designResult.backendOutputUsed,
    persistenceUsed: designResult.persistenceUsed,
    emittedOutputFamilies: designResult.emittedOutputFamilies,
  );
}

List<InternalNonLabelSignalProfileEntry> _buildSignals(
  InternalNonLabelScoringDesignResult designResult,
) {
  final signals = <InternalNonLabelSignalProfileEntry>[];
  for (final definition in _signalDefinitions) {
    signals.add(_signalFor(definition, designResult));
  }
  return List<InternalNonLabelSignalProfileEntry>.unmodifiable(
    signals..sort((a, b) => a.signalId.index.compareTo(b.signalId.index)),
  );
}

InternalNonLabelSignalProfileEntry _signalFor(
  _SignalDefinition definition,
  InternalNonLabelScoringDesignResult designResult,
) {
  final dimensions = definition.dimensionIds
      .map(designResult.dimension)
      .toList(growable: false);
  final supportCaseIds = <String>{};
  final protectedCaseIds = <String>{};
  final androidProofCaseIds = <String>{};
  final relatedAreas = <InternalEvidenceAreaId>{};
  final relatedBuckets = <InternalEvidenceBucketId>{};
  final warnings = <String>{};
  final blockers = <String>{};
  final futurePrerequisites = <String>{};

  for (final dimension in dimensions) {
    supportCaseIds.addAll(dimension.supportingCaseIds);
    protectedCaseIds.addAll(dimension.protectedSupportCaseIds);
    androidProofCaseIds.addAll(dimension.androidProofCaseIds);
    relatedAreas.addAll(dimension.relatedAreaIds);
    relatedBuckets.addAll(dimension.relatedBucketIds);
    warnings.addAll(dimension.warnings);
    blockers.addAll(dimension.blockers);
    futurePrerequisites.addAll(dimension.futurePrerequisites);
  }

  final status = _signalStatusFor(definition, dimensions);
  final confidence = _confidenceFor(
    definition: definition,
    status: status,
    protectedSupportCaseCount: protectedCaseIds.length,
    androidProofCaseCount: androidProofCaseIds.length,
    supportCaseCount: supportCaseIds.length,
  );
  final confidenceReason = _confidenceReasonFor(
    definition: definition,
    status: status,
    confidence: confidence,
    supportCaseCount: supportCaseIds.length,
    androidProofCaseCount: androidProofCaseIds.length,
  );

  if (status == InternalNonLabelSignalStatus.partial) {
    warnings.add('warning-only due to partial coverage');
  }
  if (status == InternalNonLabelSignalStatus.activeWithWarnings &&
      warnings.isEmpty) {
    warnings.add('warning-ready design dimension');
  }

  return InternalNonLabelSignalProfileEntry(
    signalId: definition.id,
    status: status,
    confidence: confidence,
    sourceDimensionIds: List<InternalNonLabelScoringDimensionId>.unmodifiable(
      definition.dimensionIds,
    ),
    relatedAreaIds: _sortedAreaIds(relatedAreas),
    relatedBucketIds: _sortedBucketIds(relatedBuckets),
    supportingCaseIds: _sortedStrings(supportCaseIds),
    protectedSupportCaseIds: _sortedStrings(protectedCaseIds),
    androidProofCaseIds: _sortedStrings(androidProofCaseIds),
    confidenceReason: confidenceReason,
    warningReasons: _sortedStrings(warnings),
    blockerReasons: _sortedStrings(blockers),
    futurePrerequisites: _sortedStrings(futurePrerequisites),
  );
}

InternalNonLabelSignalStatus _signalStatusFor(
  _SignalDefinition definition,
  List<InternalNonLabelScoringDimensionDesign> dimensions,
) {
  if (definition.fixedStatus != null) return definition.fixedStatus!;
  if (dimensions.any(
    (dimension) =>
        dimension.readiness ==
        InternalNonLabelScoringDimensionReadiness.invalid,
  )) {
    return InternalNonLabelSignalStatus.invalid;
  }
  if (dimensions.any(
    (dimension) =>
        dimension.readiness ==
        InternalNonLabelScoringDimensionReadiness.partialNeedsMoreCases,
  )) {
    return InternalNonLabelSignalStatus.partial;
  }
  if (dimensions.any(
    (dimension) =>
        dimension.readiness ==
        InternalNonLabelScoringDimensionReadiness.designReadyWithWarnings,
  )) {
    return InternalNonLabelSignalStatus.activeWithWarnings;
  }
  if (dimensions.every(
    (dimension) =>
        dimension.readiness ==
        InternalNonLabelScoringDimensionReadiness.designReady,
  )) {
    return InternalNonLabelSignalStatus.active;
  }
  return InternalNonLabelSignalStatus.inactive;
}

InternalNonLabelSignalConfidence _confidenceFor({
  required _SignalDefinition definition,
  required InternalNonLabelSignalStatus status,
  required int protectedSupportCaseCount,
  required int androidProofCaseCount,
  required int supportCaseCount,
}) {
  if (definition.fixedConfidence != null) return definition.fixedConfidence!;
  return switch (status) {
    InternalNonLabelSignalStatus.active =>
      protectedSupportCaseCount >= 3
          ? InternalNonLabelSignalConfidence.highConfidence
          : InternalNonLabelSignalConfidence.mediumConfidence,
    InternalNonLabelSignalStatus.activeWithWarnings =>
      definition.warningOnlyWhenWarningReady
          ? InternalNonLabelSignalConfidence.warningOnly
          : InternalNonLabelSignalConfidence.mediumConfidence,
    InternalNonLabelSignalStatus.partial =>
      InternalNonLabelSignalConfidence.warningOnly,
    InternalNonLabelSignalStatus.excluded =>
      InternalNonLabelSignalConfidence.excluded,
    InternalNonLabelSignalStatus.blockedByPolicy =>
      InternalNonLabelSignalConfidence.blocked,
    InternalNonLabelSignalStatus.futureOnly =>
      InternalNonLabelSignalConfidence.futureOnly,
    InternalNonLabelSignalStatus.inactive ||
    InternalNonLabelSignalStatus.invalid =>
      InternalNonLabelSignalConfidence.lowConfidence,
  };
}

String _confidenceReasonFor({
  required _SignalDefinition definition,
  required InternalNonLabelSignalStatus status,
  required InternalNonLabelSignalConfidence confidence,
  required int supportCaseCount,
  required int androidProofCaseCount,
}) {
  if (definition.confidenceReason != null) {
    return definition.confidenceReason!;
  }
  return switch (confidence) {
    InternalNonLabelSignalConfidence.highConfidence =>
      'multiple protected support cases back this internal signal',
    InternalNonLabelSignalConfidence.mediumConfidence =>
      'supported by protected cases with warning-ready design coverage',
    InternalNonLabelSignalConfidence.lowConfidence =>
      'insufficient support for active profile use',
    InternalNonLabelSignalConfidence.warningOnly =>
      'partial coverage keeps this signal warning-only',
    InternalNonLabelSignalConfidence.excluded =>
      'quiet/preparatory scope remains excluded',
    InternalNonLabelSignalConfidence.blocked => 'blocked by policy',
    InternalNonLabelSignalConfidence.futureOnly =>
      'future-only internal input is not implemented',
  };
}

InternalNonLabelSignalProfileStatus _profileStatusFor(
  InternalNonLabelSignalProfileResult result,
  List<InternalNonLabelSignalProfileValidationFinding> findings,
) {
  if (findings.any((finding) => finding.isError)) {
    return InternalNonLabelSignalProfileStatus.blockedByValidation;
  }
  if (result.hasWarnings ||
      result.signals.any(
        (signal) =>
            signal.status == InternalNonLabelSignalStatus.activeWithWarnings ||
            signal.status == InternalNonLabelSignalStatus.partial,
      )) {
    return InternalNonLabelSignalProfileStatus.readyWithWarnings;
  }
  return InternalNonLabelSignalProfileStatus.profileReadyInternalOnly;
}

InternalNonLabelSignalProfileEntry? _signalOrNull(
  List<InternalNonLabelSignalProfileEntry> signals,
  InternalNonLabelSignalId id,
) {
  for (final signal in signals) {
    if (signal.signalId == id) return signal;
  }
  return null;
}

int _compareFindings(
  InternalNonLabelSignalProfileValidationFinding a,
  InternalNonLabelSignalProfileValidationFinding b,
) {
  final idCompare = a.id.compareTo(b.id);
  if (idCompare != 0) return idCompare;
  final signalCompare = (a.signalId?.wire ?? '').compareTo(
    b.signalId?.wire ?? '',
  );
  if (signalCompare != 0) return signalCompare;
  return (a.caseId ?? '').compareTo(b.caseId ?? '');
}

String _ids(Iterable<String> values) {
  final sorted = _sortedStrings(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

String _signalIds(Iterable<InternalNonLabelSignalProfileEntry> values) {
  final ids = values.map((signal) => signal.signalId.wire).toList()..sort();
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

String _bucketIds(Iterable<InternalEvidenceBucketId> values) {
  final ids = values.map((id) => id.wire).toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.toList()..sort();
}

List<InternalEvidenceAreaId> _sortedAreaIds(
  Iterable<InternalEvidenceAreaId> values,
) {
  return values.toList()..sort((a, b) => a.index.compareTo(b.index));
}

List<InternalEvidenceBucketId> _sortedBucketIds(
  Iterable<InternalEvidenceBucketId> values,
) {
  return values.toList()..sort((a, b) => a.index.compareTo(b.index));
}

bool _isForbiddenEmittedOutput(String value) {
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

class _SignalDefinition {
  const _SignalDefinition({
    required this.id,
    required this.dimensionIds,
    this.fixedStatus,
    this.fixedConfidence,
    this.warningOnlyWhenWarningReady = false,
    this.confidenceReason,
  });

  final InternalNonLabelSignalId id;
  final List<InternalNonLabelScoringDimensionId> dimensionIds;
  final InternalNonLabelSignalStatus? fixedStatus;
  final InternalNonLabelSignalConfidence? fixedConfidence;
  final bool warningOnlyWhenWarningReady;
  final String? confidenceReason;
}

const _signalDefinitions = <_SignalDefinition>[
  _SignalDefinition(
    id: InternalNonLabelSignalId.tacticalPressureSignal,
    dimensionIds: <InternalNonLabelScoringDimensionId>[
      InternalNonLabelScoringDimensionId.tacticalPressureDimension,
    ],
  ),
  _SignalDefinition(
    id: InternalNonLabelSignalId.materialSwingSignal,
    dimensionIds: <InternalNonLabelScoringDimensionId>[
      InternalNonLabelScoringDimensionId.materialSwingDimension,
    ],
  ),
  _SignalDefinition(
    id: InternalNonLabelSignalId.forcingLineSignal,
    dimensionIds: <InternalNonLabelScoringDimensionId>[
      InternalNonLabelScoringDimensionId.forcingLineDimension,
    ],
  ),
  _SignalDefinition(
    id: InternalNonLabelSignalId.kingSafetySignal,
    dimensionIds: <InternalNonLabelScoringDimensionId>[
      InternalNonLabelScoringDimensionId.kingSafetyDimension,
    ],
  ),
  _SignalDefinition(
    id: InternalNonLabelSignalId.candidateSpreadSignal,
    dimensionIds: <InternalNonLabelScoringDimensionId>[
      InternalNonLabelScoringDimensionId.candidateSpreadDimension,
    ],
  ),
  _SignalDefinition(
    id: InternalNonLabelSignalId.pvMultiPvSupportSignal,
    dimensionIds: <InternalNonLabelScoringDimensionId>[
      InternalNonLabelScoringDimensionId.pvMultiPvSupportDimension,
    ],
  ),
  _SignalDefinition(
    id: InternalNonLabelSignalId.androidProofConfidenceSignal,
    dimensionIds: <InternalNonLabelScoringDimensionId>[
      InternalNonLabelScoringDimensionId.androidProofConfidenceDimension,
    ],
    confidenceReason: 'limited to captured Android proof cases',
  ),
  _SignalDefinition(
    id: InternalNonLabelSignalId.endgameSupportSignal,
    dimensionIds: <InternalNonLabelScoringDimensionId>[
      InternalNonLabelScoringDimensionId.endgamePrecisionDimension,
    ],
  ),
  _SignalDefinition(
    id: InternalNonLabelSignalId.suppressionSafetySignal,
    dimensionIds: <InternalNonLabelScoringDimensionId>[
      InternalNonLabelScoringDimensionId.suppressionSafetyDimension,
    ],
    warningOnlyWhenWarningReady: true,
  ),
  _SignalDefinition(
    id: InternalNonLabelSignalId.budgetRiskSignal,
    dimensionIds: <InternalNonLabelScoringDimensionId>[
      InternalNonLabelScoringDimensionId.budgetRiskDimension,
    ],
  ),
  _SignalDefinition(
    id: InternalNonLabelSignalId.quietPreparatorySignalExcluded,
    dimensionIds: <InternalNonLabelScoringDimensionId>[
      InternalNonLabelScoringDimensionId.quietPreparatoryDimensionExcluded,
    ],
    fixedStatus: InternalNonLabelSignalStatus.excluded,
    fixedConfidence: InternalNonLabelSignalConfidence.excluded,
  ),
  _SignalDefinition(
    id: InternalNonLabelSignalId.productLabelSignalBlocked,
    dimensionIds: <InternalNonLabelScoringDimensionId>[
      InternalNonLabelScoringDimensionId.productLabelDimensionBlocked,
    ],
    fixedStatus: InternalNonLabelSignalStatus.blockedByPolicy,
    fixedConfidence: InternalNonLabelSignalConfidence.blocked,
  ),
  _SignalDefinition(
    id: InternalNonLabelSignalId.advancedLabelSignalBlocked,
    dimensionIds: <InternalNonLabelScoringDimensionId>[
      InternalNonLabelScoringDimensionId.advancedLabelDimensionBlocked,
    ],
    fixedStatus: InternalNonLabelSignalStatus.blockedByPolicy,
    fixedConfidence: InternalNonLabelSignalConfidence.blocked,
  ),
  _SignalDefinition(
    id: InternalNonLabelSignalId.officialMetricSignalBlocked,
    dimensionIds: <InternalNonLabelScoringDimensionId>[
      InternalNonLabelScoringDimensionId.officialMetricDimensionBlocked,
    ],
    fixedStatus: InternalNonLabelSignalStatus.blockedByPolicy,
    fixedConfidence: InternalNonLabelSignalConfidence.blocked,
  ),
  _SignalDefinition(
    id: InternalNonLabelSignalId.cpLossSignalFutureOnly,
    dimensionIds: <InternalNonLabelScoringDimensionId>[
      InternalNonLabelScoringDimensionId.cpLossDimensionFutureOnly,
    ],
    fixedStatus: InternalNonLabelSignalStatus.futureOnly,
    fixedConfidence: InternalNonLabelSignalConfidence.futureOnly,
  ),
  _SignalDefinition(
    id: InternalNonLabelSignalId.winProbabilitySignalFutureOnly,
    dimensionIds: <InternalNonLabelScoringDimensionId>[
      InternalNonLabelScoringDimensionId.winProbabilityDimensionFutureOnly,
    ],
    fixedStatus: InternalNonLabelSignalStatus.futureOnly,
    fixedConfidence: InternalNonLabelSignalConfidence.futureOnly,
  ),
];

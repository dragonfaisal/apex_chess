/// Developer-only non-label scoring design informed by coverage evidence.
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

const internalNonLabelScoringDesignReportVersion =
    'internal-non-label-scoring-design-v1';

enum InternalNonLabelScoringDimensionId {
  tacticalPressureDimension('tacticalPressureDimension'),
  materialSwingDimension('materialSwingDimension'),
  forcingLineDimension('forcingLineDimension'),
  kingSafetyDimension('kingSafetyDimension'),
  endgamePrecisionDimension('endgamePrecisionDimension'),
  suppressionSafetyDimension('suppressionSafetyDimension'),
  candidateSpreadDimension('candidateSpreadDimension'),
  pvMultiPvSupportDimension('pvMultiPvSupportDimension'),
  androidProofConfidenceDimension('androidProofConfidenceDimension'),
  budgetRiskDimension('budgetRiskDimension'),
  quietPreparatoryDimensionExcluded('quietPreparatoryDimensionExcluded'),
  productLabelDimensionBlocked('productLabelDimensionBlocked'),
  advancedLabelDimensionBlocked('advancedLabelDimensionBlocked'),
  officialMetricDimensionBlocked('officialMetricDimensionBlocked'),
  cpLossDimensionFutureOnly('cpLossDimensionFutureOnly'),
  winProbabilityDimensionFutureOnly('winProbabilityDimensionFutureOnly');

  const InternalNonLabelScoringDimensionId(this.wire);

  final String wire;
}

enum InternalNonLabelScoringDimensionReadiness {
  designReady('designReady'),
  designReadyWithWarnings('designReadyWithWarnings'),
  partialNeedsMoreCases('partialNeedsMoreCases'),
  futureOnly('futureOnly'),
  excluded('excluded'),
  blockedByPolicy('blockedByPolicy'),
  unsupported('unsupported'),
  invalid('invalid');

  const InternalNonLabelScoringDimensionReadiness(this.wire);

  final String wire;
}

enum InternalNonLabelScoringSignalType {
  primarySignal('primarySignal'),
  secondarySignal('secondarySignal'),
  supportingSignal('supportingSignal'),
  suppressionSignal('suppressionSignal'),
  confidenceSignal('confidenceSignal'),
  riskSignal('riskSignal'),
  excludedSignal('excludedSignal'),
  blockedSignal('blockedSignal'),
  futureSignal('futureSignal');

  const InternalNonLabelScoringSignalType(this.wire);

  final String wire;
}

enum InternalNonLabelScoringDesignStatus {
  designReadyInternalOnly('designReadyInternalOnly'),
  designReadyWithWarnings('designReadyWithWarnings'),
  blockedByMatrix('blockedByMatrix'),
  blockedByValidation('blockedByValidation'),
  invalid('invalid');

  const InternalNonLabelScoringDesignStatus(this.wire);

  final String wire;
}

enum InternalNonLabelScoringDesignRecommendation {
  keepDesignStable('keepDesignStable'),
  addHandcraftedCase('addHandcraftedCase'),
  addFakeEvidence('addFakeEvidence'),
  addOwnerAndroidProofOnlyIfPvRequired('addOwnerAndroidProofOnlyIfPvRequired'),
  keepExcludedByNegativeGuard('keepExcludedByNegativeGuard'),
  keepBlockedByPolicy('keepBlockedByPolicy'),
  futureInternalInputOnly('futureInternalInputOnly');

  const InternalNonLabelScoringDesignRecommendation(this.wire);

  final String wire;
}

enum InternalNonLabelScoringDesignValidationSeverity {
  warning('warning'),
  error('error');

  const InternalNonLabelScoringDesignValidationSeverity(this.wire);

  final String wire;
}

enum InternalNonLabelScoringDesignReportFormat {
  markdown('markdown'),
  json('json');

  const InternalNonLabelScoringDesignReportFormat(this.wire);

  final String wire;
}

enum InternalNonLabelScoringDesignNextPhase {
  guardedNonLabelPrototype(
    'Phase 31H -- Guarded Internal Non-Label Scoring Prototype',
  ),
  designEvidenceFixes('Phase 31H -- Design Evidence Fixes');

  const InternalNonLabelScoringDesignNextPhase(this.wire);

  final String wire;
}

class InternalNonLabelScoringDesignRequest {
  const InternalNonLabelScoringDesignRequest({
    this.matrixRequest = const InternalEvidenceAreaCoverageMatrixRequest(),
    this.matrixResult,
    this.harnessResult,
    this.bucketPrototype,
    this.contract,
    this.review,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.cases = GoldenAnalysisCases.defaults,
    this.matrix = const InternalEvidenceAreaCoverageMatrix(),
    this.bucketBuilder = const InternalEvidenceBucketBuilder(),
    this.contractBuilder = const BasicClassifierEvidenceContractBuilder(),
    this.reviewRunner = const GoldenEvidenceReviewRunner(),
  });

  final InternalEvidenceAreaCoverageMatrixRequest matrixRequest;
  final InternalEvidenceAreaCoverageMatrixResult? matrixResult;
  final InternalBucketExperimentHarnessResult? harnessResult;
  final InternalEvidenceBucketPrototype? bucketPrototype;
  final BasicClassifierEvidenceContractPrototype? contract;
  final GoldenEvidenceReviewResult? review;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final List<GoldenAnalysisCase> cases;
  final InternalEvidenceAreaCoverageMatrix matrix;
  final InternalEvidenceBucketBuilder bucketBuilder;
  final BasicClassifierEvidenceContractBuilder contractBuilder;
  final GoldenEvidenceReviewRunner reviewRunner;
}

class InternalNonLabelScoringDimensionDesign {
  const InternalNonLabelScoringDimensionDesign({
    required this.dimensionId,
    required this.readiness,
    required this.signalType,
    required this.relatedAreaIds,
    required this.relatedBucketIds,
    required this.relatedContractFields,
    required this.supportingCaseIds,
    required this.protectedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.warnings,
    required this.blockers,
    required this.futurePrerequisites,
    required this.recommendation,
    this.emitsProductLabel = false,
    this.emitsClassifierLabel = false,
    this.emitsFinalMoveLabel = false,
    this.hasNumericMoveScore = false,
    this.claimsOfficialMetrics = false,
    this.cpLossComputationImplemented = false,
    this.winProbabilityComputationImplemented = false,
    this.quietScopeActive = false,
    this.productLabelsActive = false,
    this.advancedLabelsActive = false,
    this.officialMetricsActive = false,
    this.emittedOutputNames = const <String>[],
  });

  final InternalNonLabelScoringDimensionId dimensionId;
  final InternalNonLabelScoringDimensionReadiness readiness;
  final InternalNonLabelScoringSignalType signalType;
  final List<InternalEvidenceAreaId> relatedAreaIds;
  final List<InternalEvidenceBucketId> relatedBucketIds;
  final List<BasicClassifierContractField> relatedContractFields;
  final List<String> supportingCaseIds;
  final List<String> protectedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> warnings;
  final List<String> blockers;
  final List<String> futurePrerequisites;
  final InternalNonLabelScoringDesignRecommendation recommendation;
  final bool emitsProductLabel;
  final bool emitsClassifierLabel;
  final bool emitsFinalMoveLabel;
  final bool hasNumericMoveScore;
  final bool claimsOfficialMetrics;
  final bool cpLossComputationImplemented;
  final bool winProbabilityComputationImplemented;
  final bool quietScopeActive;
  final bool productLabelsActive;
  final bool advancedLabelsActive;
  final bool officialMetricsActive;
  final List<String> emittedOutputNames;

  bool get designReadyLike =>
      readiness == InternalNonLabelScoringDimensionReadiness.designReady ||
      readiness ==
          InternalNonLabelScoringDimensionReadiness.designReadyWithWarnings;

  bool get activeForFuturePrototype =>
      readiness == InternalNonLabelScoringDimensionReadiness.designReady ||
      readiness ==
          InternalNonLabelScoringDimensionReadiness.designReadyWithWarnings ||
      readiness ==
          InternalNonLabelScoringDimensionReadiness.partialNeedsMoreCases;

  bool get hasUnsafeDimensionPolicyViolation {
    return emitsProductLabel ||
        emitsClassifierLabel ||
        emitsFinalMoveLabel ||
        hasNumericMoveScore ||
        claimsOfficialMetrics ||
        cpLossComputationImplemented ||
        winProbabilityComputationImplemented ||
        quietScopeActive ||
        productLabelsActive ||
        advancedLabelsActive ||
        officialMetricsActive ||
        emittedOutputNames.any(_isForbiddenEmittedOutput);
  }

  InternalNonLabelScoringDimensionDesign copyWith({
    InternalNonLabelScoringDimensionId? dimensionId,
    InternalNonLabelScoringDimensionReadiness? readiness,
    InternalNonLabelScoringSignalType? signalType,
    List<InternalEvidenceAreaId>? relatedAreaIds,
    List<InternalEvidenceBucketId>? relatedBucketIds,
    List<BasicClassifierContractField>? relatedContractFields,
    List<String>? supportingCaseIds,
    List<String>? protectedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? warnings,
    List<String>? blockers,
    List<String>? futurePrerequisites,
    InternalNonLabelScoringDesignRecommendation? recommendation,
    bool? emitsProductLabel,
    bool? emitsClassifierLabel,
    bool? emitsFinalMoveLabel,
    bool? hasNumericMoveScore,
    bool? claimsOfficialMetrics,
    bool? cpLossComputationImplemented,
    bool? winProbabilityComputationImplemented,
    bool? quietScopeActive,
    bool? productLabelsActive,
    bool? advancedLabelsActive,
    bool? officialMetricsActive,
    List<String>? emittedOutputNames,
  }) {
    return InternalNonLabelScoringDimensionDesign(
      dimensionId: dimensionId ?? this.dimensionId,
      readiness: readiness ?? this.readiness,
      signalType: signalType ?? this.signalType,
      relatedAreaIds: relatedAreaIds ?? this.relatedAreaIds,
      relatedBucketIds: relatedBucketIds ?? this.relatedBucketIds,
      relatedContractFields:
          relatedContractFields ?? this.relatedContractFields,
      supportingCaseIds: supportingCaseIds ?? this.supportingCaseIds,
      protectedSupportCaseIds:
          protectedSupportCaseIds ?? this.protectedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      warnings: warnings ?? this.warnings,
      blockers: blockers ?? this.blockers,
      futurePrerequisites: futurePrerequisites ?? this.futurePrerequisites,
      recommendation: recommendation ?? this.recommendation,
      emitsProductLabel: emitsProductLabel ?? this.emitsProductLabel,
      emitsClassifierLabel: emitsClassifierLabel ?? this.emitsClassifierLabel,
      emitsFinalMoveLabel: emitsFinalMoveLabel ?? this.emitsFinalMoveLabel,
      hasNumericMoveScore: hasNumericMoveScore ?? this.hasNumericMoveScore,
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
      'dimensionId': dimensionId.wire,
      'readiness': readiness.wire,
      'signalType': signalType.wire,
      'relatedAreaIds': relatedAreaIds.map((id) => id.wire).toList(),
      'relatedBucketIds': relatedBucketIds.map((id) => id.wire).toList(),
      'relatedContractFields': _safeContractFieldNames(relatedContractFields),
      'supportingCaseIds': supportingCaseIds,
      'protectedSupportCaseIds': protectedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'warnings': warnings,
      'blockers': blockers,
      'futurePrerequisites': futurePrerequisites,
      'recommendation': recommendation.wire,
      'emitsProductLabel': emitsProductLabel,
      'emitsClassifierLabel': emitsClassifierLabel,
      'emitsFinalMoveLabel': emitsFinalMoveLabel,
      'hasNumericMoveScore': hasNumericMoveScore,
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

class InternalNonLabelScoringDesignValidationFinding {
  const InternalNonLabelScoringDesignValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.dimensionId,
    this.caseId,
  });

  final String id;
  final InternalNonLabelScoringDesignValidationSeverity severity;
  final String message;
  final InternalNonLabelScoringDimensionId? dimensionId;
  final String? caseId;

  bool get isError =>
      severity == InternalNonLabelScoringDesignValidationSeverity.error;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (dimensionId != null) 'dimensionId': dimensionId!.wire,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class InternalNonLabelScoringDesignResult {
  const InternalNonLabelScoringDesignResult({
    required this.status,
    required this.matrixStatus,
    required this.harnessStatus,
    required this.guardStatus,
    required this.guardAllowed,
    required this.dimensionCount,
    required this.dimensions,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.nextRecommendedPhase,
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
    this.directEngineAccessUsed = false,
    this.uiOutputUsed = false,
    this.backendOutputUsed = false,
    this.persistenceUsed = false,
    this.emittedOutputFamilies = const <String>[],
  });

  final InternalNonLabelScoringDesignStatus status;
  final InternalEvidenceAreaCoverageMatrixStatus matrixStatus;
  final InternalBucketExperimentHarnessStatus harnessStatus;
  final InternalBucketExperimentGuardStatus guardStatus;
  final bool guardAllowed;
  final int dimensionCount;
  final List<InternalNonLabelScoringDimensionDesign> dimensions;
  final List<InternalNonLabelScoringDesignValidationFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final InternalNonLabelScoringDesignNextPhase nextRecommendedPhase;
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
            InternalNonLabelScoringDesignValidationSeverity.warning,
      ) ||
      dimensions.any((dimension) => dimension.warnings.isNotEmpty);

  bool get isStrictlyBlocked =>
      status == InternalNonLabelScoringDesignStatus.blockedByMatrix ||
      status == InternalNonLabelScoringDesignStatus.blockedByValidation ||
      status == InternalNonLabelScoringDesignStatus.invalid;

  bool get hasUnsafeScoringDesignPolicyViolation {
    return hasValidationErrors ||
        dimensions.any(
          (dimension) => dimension.hasUnsafeDimensionPolicyViolation,
        ) ||
        unprovenAndroidCaseIds.isNotEmpty ||
        productLabelsEmitted ||
        classifierLabelsEmitted ||
        finalMoveLabelsEmitted ||
        officialMetricsAllowed ||
        cpLossComputationImplemented ||
        winProbabilityComputationImplemented ||
        numericMoveScoresComputed ||
        directEngineAccessUsed ||
        uiOutputUsed ||
        backendOutputUsed ||
        persistenceUsed ||
        emittedOutputFamilies.any(_isForbiddenEmittedOutput);
  }

  InternalNonLabelScoringDimensionDesign dimension(
    InternalNonLabelScoringDimensionId id,
  ) {
    return dimensions.singleWhere((dimension) => dimension.dimensionId == id);
  }

  List<InternalNonLabelScoringDimensionDesign> get designReadyDimensions =>
      dimensions
          .where(
            (dimension) =>
                dimension.readiness ==
                InternalNonLabelScoringDimensionReadiness.designReady,
          )
          .toList(growable: false);

  List<InternalNonLabelScoringDimensionDesign> get warningDimensions =>
      dimensions
          .where(
            (dimension) =>
                dimension.readiness ==
                    InternalNonLabelScoringDimensionReadiness
                        .designReadyWithWarnings ||
                dimension.readiness ==
                    InternalNonLabelScoringDimensionReadiness
                        .partialNeedsMoreCases,
          )
          .toList(growable: false);

  InternalNonLabelScoringDesignResult copyWith({
    InternalNonLabelScoringDesignStatus? status,
    InternalEvidenceAreaCoverageMatrixStatus? matrixStatus,
    InternalBucketExperimentHarnessStatus? harnessStatus,
    InternalBucketExperimentGuardStatus? guardStatus,
    bool? guardAllowed,
    int? dimensionCount,
    List<InternalNonLabelScoringDimensionDesign>? dimensions,
    List<InternalNonLabelScoringDesignValidationFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    InternalNonLabelScoringDesignNextPhase? nextRecommendedPhase,
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
    bool? directEngineAccessUsed,
    bool? uiOutputUsed,
    bool? backendOutputUsed,
    bool? persistenceUsed,
    List<String>? emittedOutputFamilies,
  }) {
    final effectiveDimensions = dimensions ?? this.dimensions;
    return InternalNonLabelScoringDesignResult(
      status: status ?? this.status,
      matrixStatus: matrixStatus ?? this.matrixStatus,
      harnessStatus: harnessStatus ?? this.harnessStatus,
      guardStatus: guardStatus ?? this.guardStatus,
      guardAllowed: guardAllowed ?? this.guardAllowed,
      dimensionCount: dimensionCount ?? effectiveDimensions.length,
      dimensions: effectiveDimensions,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      nextRecommendedPhase: nextRecommendedPhase ?? this.nextRecommendedPhase,
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
      ..writeln('# Internal Non-Label Scoring Design')
      ..writeln()
      ..writeln('- version: $internalNonLabelScoringDesignReportVersion')
      ..writeln('- scoring design status: ${status.wire}')
      ..writeln('- matrix status: ${matrixStatus.wire}')
      ..writeln('- harness status: ${harnessStatus.wire}')
      ..writeln('- guard status: ${guardStatus.wire}')
      ..writeln('- guard allowed: $guardAllowed')
      ..writeln('- developer only: $developerOnly')
      ..writeln('- classifier output emitted: false')
      ..writeln('- numeric score values emitted: false')
      ..writeln()
      ..writeln('## Design-Only Signal Policy')
      ..writeln(
        '- dimensions use qualitative signal types only: primarySignal, '
        'secondarySignal, supportingSignal, suppressionSignal, '
        'confidenceSignal, riskSignal, excludedSignal, blockedSignal, '
        'and futureSignal',
      )
      ..writeln(
        '- the design records future inputs and prerequisites only; it does '
        'not compute scores, rank moves, create thresholds, call an engine, '
        'or write files',
      )
      ..writeln()
      ..writeln('## Dimension Table')
      ..writeln(
        '| Dimension | Readiness | Signal | Evidence Areas | Support Cases | Android Proof | Future Prerequisites | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- |');
    if (dimensions.isEmpty) {
      buffer.writeln('| - | - | - | - | - | - | - | - |');
    } else {
      for (final dimension in dimensions) {
        buffer.writeln(
          '| ${dimension.dimensionId.wire} | ${dimension.readiness.wire} | '
          '${dimension.signalType.wire} | ${_areaIds(dimension.relatedAreaIds)} | '
          '${_ids(dimension.supportingCaseIds)} | '
          '${_ids(dimension.androidProofCaseIds)} | '
          '${_ids(dimension.futurePrerequisites)} | '
          '${dimension.recommendation.wire} |',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('## Readiness Summary')
      ..writeln('- design-ready: ${_dimensionIds(designReadyDimensions)}')
      ..writeln('- warning or partial: ${_dimensionIds(warningDimensions)}')
      ..writeln(
        '- excluded: ${_dimensionIds(dimensions.where((dimension) => dimension.readiness == InternalNonLabelScoringDimensionReadiness.excluded))}',
      )
      ..writeln(
        '- blocked: ${_dimensionIds(dimensions.where((dimension) => dimension.readiness == InternalNonLabelScoringDimensionReadiness.blockedByPolicy))}',
      )
      ..writeln(
        '- future-only: ${_dimensionIds(dimensions.where((dimension) => dimension.readiness == InternalNonLabelScoringDimensionReadiness.futureOnly))}',
      )
      ..writeln()
      ..writeln('## Support Mapping');
    for (final dimension in dimensions) {
      buffer.writeln(
        '- ${dimension.dimensionId.wire}: ${_ids(dimension.supportingCaseIds)}',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Android Proof Support')
      ..writeln('- proven case IDs: ${_ids(provenAndroidCaseIds)}')
      ..writeln('- unproven case IDs: ${_ids(unprovenAndroidCaseIds)}')
      ..writeln()
      ..writeln('## Future Prerequisites');
    var wrotePrerequisite = false;
    for (final dimension in dimensions) {
      if (dimension.futurePrerequisites.isEmpty) continue;
      wrotePrerequisite = true;
      buffer.writeln(
        '- ${dimension.dimensionId.wire}: '
        '${dimension.futurePrerequisites.join("; ")}',
      );
    }
    if (!wrotePrerequisite) {
      buffer.writeln('- none');
    }

    buffer
      ..writeln()
      ..writeln('## Excluded Blocked And Future Dimensions')
      ..writeln('- quiet/preparatory exclusion: ${_ids(excludedScopeIds)}')
      ..writeln('- product-label dimension: blocked')
      ..writeln('- advanced-label dimension: blocked')
      ..writeln('- official-metric dimension: blocked')
      ..writeln('- CP-loss dimension: future-only')
      ..writeln('- win-probability dimension: future-only')
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
        'This design defines future internal signal structure only. It does '
        'not judge move quality, emit user-facing output, compute product '
        'metrics, call the engine, run Android, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    final payload = <String, Object?>{
      'version': internalNonLabelScoringDesignReportVersion,
      'scoringDesignStatus': status.wire,
      'matrixStatus': matrixStatus.wire,
      'harnessStatus': harnessStatus.wire,
      'guardStatus': guardStatus.wire,
      'guardAllowed': guardAllowed,
      'dimensionCount': dimensionCount,
      'dimensions': dimensions.map((dimension) => dimension.toJson()).toList(),
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
      'productLabelsEmitted': productLabelsEmitted,
      'classifierLabelsEmitted': classifierLabelsEmitted,
      'finalMoveLabelsEmitted': finalMoveLabelsEmitted,
      'officialMetricsAllowed': officialMetricsAllowed,
      'cpLossComputationImplemented': cpLossComputationImplemented,
      'winProbabilityComputationImplemented':
          winProbabilityComputationImplemented,
      'numericMoveScoresComputed': numericMoveScoresComputed,
      'directEngineAccessUsed': directEngineAccessUsed,
      'uiOutputUsed': uiOutputUsed,
      'backendOutputUsed': backendOutputUsed,
      'persistenceUsed': persistenceUsed,
      'emittedOutputFamilies': emittedOutputFamilies,
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}

class InternalNonLabelScoringDesign {
  const InternalNonLabelScoringDesign({
    this.validator = const InternalNonLabelScoringDesignValidator(),
  });

  final InternalNonLabelScoringDesignValidator validator;

  InternalNonLabelScoringDesignResult evaluate(
    InternalNonLabelScoringDesignRequest request,
  ) {
    final matrixResult =
        request.matrixResult ?? request.matrix.evaluate(request.matrixRequest);
    if (matrixResult.isStrictlyBlocked) {
      return _blockedByMatrixResult(matrixResult);
    }

    final review =
        request.review ??
        request.reviewRunner.review(
          GoldenEvidenceReviewRequest(
            cases: request.cases,
            mode: GoldenEvidenceReviewMode.realDeviceEvidenceReferenceOnly,
            requireAllEvidence: true,
            androidProofEvidence: request.androidProofEvidence,
          ),
        );
    final contract =
        request.contract ??
        request.contractBuilder.evaluate(
          BasicClassifierEvidenceContractRequest(
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
          ),
        );
    final buckets =
        request.bucketPrototype ??
        request.bucketBuilder.evaluate(
          InternalEvidenceBucketRequest(
            cases: request.cases,
            contract: contract,
            review: review,
            androidProofEvidence: request.androidProofEvidence,
          ),
        );

    final dimensions = _buildDimensions(
      matrixResult: matrixResult,
      contract: contract,
      buckets: buckets,
      androidProofEvidence: request.androidProofEvidence,
    );
    final base = InternalNonLabelScoringDesignResult(
      status: InternalNonLabelScoringDesignStatus.designReadyInternalOnly,
      matrixStatus: matrixResult.status,
      harnessStatus: matrixResult.harnessStatus,
      guardStatus: matrixResult.guardStatus,
      guardAllowed: matrixResult.guardAllowed,
      dimensionCount: dimensions.length,
      dimensions: dimensions,
      validationFindings:
          const <InternalNonLabelScoringDesignValidationFinding>[],
      warnings: _sortedStrings(matrixResult.warnings),
      failures: matrixResult.failures,
      nextRecommendedPhase:
          InternalNonLabelScoringDesignNextPhase.guardedNonLabelPrototype,
      provenAndroidCaseIds: matrixResult.provenAndroidCaseIds,
      unprovenAndroidCaseIds: matrixResult.unprovenAndroidCaseIds,
      excludedScopeIds: matrixResult.excludedScopeIds,
      productLabelsEmitted: matrixResult.productOutputEmitted,
      classifierLabelsEmitted: matrixResult.classifierLabelsEmitted,
      finalMoveLabelsEmitted: false,
      officialMetricsAllowed: matrixResult.officialMetricsEmitted,
      cpLossComputationImplemented: matrixResult.cpLossComputed,
      winProbabilityComputationImplemented: matrixResult.winProbabilityComputed,
      numericMoveScoresComputed: false,
      directEngineAccessUsed: matrixResult.directEngineAccessUsed,
      uiOutputUsed: matrixResult.uiOutputUsed,
      backendOutputUsed: matrixResult.backendOutputUsed,
      persistenceUsed: matrixResult.persistenceUsed,
      emittedOutputFamilies: matrixResult.emittedOutputFamilies,
    );
    final findings = validator.validate(base);
    return base.copyWith(
      status: _designStatusFor(base, findings),
      validationFindings: findings,
      nextRecommendedPhase: findings.any((finding) => finding.isError)
          ? InternalNonLabelScoringDesignNextPhase.designEvidenceFixes
          : InternalNonLabelScoringDesignNextPhase.guardedNonLabelPrototype,
    );
  }
}

class InternalNonLabelScoringDesignValidator {
  const InternalNonLabelScoringDesignValidator();

  List<InternalNonLabelScoringDesignValidationFinding> validate(
    InternalNonLabelScoringDesignResult result,
  ) {
    final findings = <InternalNonLabelScoringDesignValidationFinding>[];

    void error({
      required String id,
      required String message,
      InternalNonLabelScoringDimensionId? dimensionId,
      String? caseId,
    }) {
      findings.add(
        InternalNonLabelScoringDesignValidationFinding(
          id: id,
          severity: InternalNonLabelScoringDesignValidationSeverity.error,
          message: message,
          dimensionId: dimensionId,
          caseId: caseId,
        ),
      );
    }

    for (final dimension in result.dimensions) {
      if (dimension.designReadyLike && dimension.supportingCaseIds.isEmpty) {
        error(
          id: 'designReadyDimensionWithoutCases',
          message:
              '${dimension.dimensionId.wire} cannot be design-ready '
              'without support cases',
          dimensionId: dimension.dimensionId,
        );
      }
      if (dimension.emitsProductLabel ||
          dimension.emitsClassifierLabel ||
          dimension.emitsFinalMoveLabel) {
        error(
          id: 'dimensionEmitsLabel',
          message: '${dimension.dimensionId.wire} cannot emit labels',
          dimensionId: dimension.dimensionId,
        );
      }
      if (dimension.hasNumericMoveScore) {
        error(
          id: 'dimensionEmitsNumericScore',
          message: '${dimension.dimensionId.wire} cannot emit numeric scores',
          dimensionId: dimension.dimensionId,
        );
      }
      if (dimension.claimsOfficialMetrics || dimension.officialMetricsActive) {
        error(
          id: 'dimensionClaimsOfficialMetric',
          message: '${dimension.dimensionId.wire} cannot claim metrics',
          dimensionId: dimension.dimensionId,
        );
      }
      if (dimension.cpLossComputationImplemented ||
          dimension.winProbabilityComputationImplemented) {
        error(
          id: 'futureComputationMarkedImplemented',
          message:
              '${dimension.dimensionId.wire} cannot mark future computation '
              'implemented',
          dimensionId: dimension.dimensionId,
        );
      }
      if (dimension.quietScopeActive) {
        error(
          id: 'quietDimensionBecameActive',
          message: '${dimension.dimensionId.wire} cannot activate quiet scope',
          dimensionId: dimension.dimensionId,
        );
      }
      if (dimension.productLabelsActive || dimension.advancedLabelsActive) {
        error(
          id: 'labelPolicyDimensionBecameActive',
          message: '${dimension.dimensionId.wire} cannot activate label policy',
          dimensionId: dimension.dimensionId,
        );
      }
      for (final output in dimension.emittedOutputNames) {
        if (_isForbiddenEmittedOutput(output)) {
          error(
            id: 'forbiddenDimensionOutputName',
            message: 'forbidden output name emitted: $output',
            dimensionId: dimension.dimensionId,
          );
        }
      }
      for (final caseId in dimension.androidProofCaseIds) {
        if (!result.provenAndroidCaseIds.contains(caseId)) {
          error(
            id: 'unprovenAndroidProofSupport',
            message: 'Android proof support must use proven cases only',
            dimensionId: dimension.dimensionId,
            caseId: caseId,
          );
        }
      }
    }

    final quiet = _dimensionOrNull(
      result.dimensions,
      InternalNonLabelScoringDimensionId.quietPreparatoryDimensionExcluded,
    );
    if (quiet != null &&
        quiet.readiness != InternalNonLabelScoringDimensionReadiness.excluded) {
      error(
        id: 'quietDimensionNotExcluded',
        message: 'quiet/preparatory dimension must remain excluded',
        dimensionId: quiet.dimensionId,
      );
    }

    for (final id in const <InternalNonLabelScoringDimensionId>[
      InternalNonLabelScoringDimensionId.productLabelDimensionBlocked,
      InternalNonLabelScoringDimensionId.advancedLabelDimensionBlocked,
      InternalNonLabelScoringDimensionId.officialMetricDimensionBlocked,
    ]) {
      final dimension = _dimensionOrNull(result.dimensions, id);
      if (dimension != null &&
          dimension.readiness !=
              InternalNonLabelScoringDimensionReadiness.blockedByPolicy) {
        error(
          id: 'policyDimensionNotBlocked',
          message: '${id.wire} must remain blocked by policy',
          dimensionId: id,
        );
      }
    }

    for (final id in const <InternalNonLabelScoringDimensionId>[
      InternalNonLabelScoringDimensionId.cpLossDimensionFutureOnly,
      InternalNonLabelScoringDimensionId.winProbabilityDimensionFutureOnly,
    ]) {
      final dimension = _dimensionOrNull(result.dimensions, id);
      if (dimension != null &&
          dimension.readiness !=
              InternalNonLabelScoringDimensionReadiness.futureOnly) {
        error(
          id: 'futureDimensionNotFutureOnly',
          message: '${id.wire} must remain future-only',
          dimensionId: id,
        );
      }
    }

    final android = _dimensionOrNull(
      result.dimensions,
      InternalNonLabelScoringDimensionId.androidProofConfidenceDimension,
    );
    if (android != null) {
      final proof = android.androidProofCaseIds.toSet();
      for (final caseId in android.supportingCaseIds) {
        if (!proof.contains(caseId)) {
          error(
            id: 'androidConfidenceUsesUnprovenCase',
            message: 'Android confidence dimension cannot cite unproven cases',
            dimensionId: android.dimensionId,
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
        result.directEngineAccessUsed ||
        result.uiOutputUsed ||
        result.backendOutputUsed ||
        result.persistenceUsed) {
      error(
        id: 'designOutputPolicyViolation',
        message: 'design result crossed a blocked boundary',
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
        dimensionId:
            InternalNonLabelScoringDimensionId.androidProofConfidenceDimension,
        caseId: caseId,
      );
    }

    return findings..sort(_compareFindings);
  }

  List<InternalNonLabelScoringDesignValidationFinding> validateReportText(
    String reportText,
  ) {
    final findings = <InternalNonLabelScoringDesignValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        InternalNonLabelScoringDesignValidationFinding(
          id: id,
          severity: InternalNonLabelScoringDesignValidationSeverity.error,
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
    return findings..sort(_compareFindings);
  }
}

InternalNonLabelScoringDesignResult _blockedByMatrixResult(
  InternalEvidenceAreaCoverageMatrixResult matrixResult,
) {
  return InternalNonLabelScoringDesignResult(
    status: InternalNonLabelScoringDesignStatus.blockedByMatrix,
    matrixStatus: matrixResult.status,
    harnessStatus: matrixResult.harnessStatus,
    guardStatus: matrixResult.guardStatus,
    guardAllowed: matrixResult.guardAllowed,
    dimensionCount: 0,
    dimensions: const <InternalNonLabelScoringDimensionDesign>[],
    validationFindings:
        const <InternalNonLabelScoringDesignValidationFinding>[],
    warnings: matrixResult.warnings,
    failures: _sortedStrings(<String>[
      ...matrixResult.failures,
      'coverage matrix did not complete an internal-only design input',
    ]),
    nextRecommendedPhase:
        InternalNonLabelScoringDesignNextPhase.designEvidenceFixes,
    provenAndroidCaseIds: matrixResult.provenAndroidCaseIds,
    unprovenAndroidCaseIds: matrixResult.unprovenAndroidCaseIds,
    excludedScopeIds: matrixResult.excludedScopeIds,
    productLabelsEmitted: matrixResult.productOutputEmitted,
    classifierLabelsEmitted: matrixResult.classifierLabelsEmitted,
    officialMetricsAllowed: matrixResult.officialMetricsEmitted,
    cpLossComputationImplemented: matrixResult.cpLossComputed,
    winProbabilityComputationImplemented: matrixResult.winProbabilityComputed,
    directEngineAccessUsed: matrixResult.directEngineAccessUsed,
    uiOutputUsed: matrixResult.uiOutputUsed,
    backendOutputUsed: matrixResult.backendOutputUsed,
    persistenceUsed: matrixResult.persistenceUsed,
    emittedOutputFamilies: matrixResult.emittedOutputFamilies,
  );
}

List<InternalNonLabelScoringDimensionDesign> _buildDimensions({
  required InternalEvidenceAreaCoverageMatrixResult matrixResult,
  required BasicClassifierEvidenceContractPrototype contract,
  required InternalEvidenceBucketPrototype buckets,
  required GoldenAndroidProofEvidence? androidProofEvidence,
}) {
  final dimensions = <InternalNonLabelScoringDimensionDesign>[];
  for (final definition in _dimensionDefinitions) {
    dimensions.add(
      _dimensionFor(
        definition: definition,
        matrixResult: matrixResult,
        contract: contract,
        buckets: buckets,
        androidProofEvidence: androidProofEvidence,
      ),
    );
  }
  return List<InternalNonLabelScoringDimensionDesign>.unmodifiable(
    dimensions
      ..sort((a, b) => a.dimensionId.index.compareTo(b.dimensionId.index)),
  );
}

InternalNonLabelScoringDimensionDesign _dimensionFor({
  required _DimensionDefinition definition,
  required InternalEvidenceAreaCoverageMatrixResult matrixResult,
  required BasicClassifierEvidenceContractPrototype contract,
  required InternalEvidenceBucketPrototype buckets,
  required GoldenAndroidProofEvidence? androidProofEvidence,
}) {
  final supportCaseIds = <String>{};
  final protectedCaseIds = <String>{};
  final androidProofCaseIds = <String>{};
  final relatedBuckets = <InternalEvidenceBucketId>{};
  final relatedFields = <BasicClassifierContractField>{};
  final warnings = <String>{};
  final blockers = <String>{};
  final areaStatuses = <InternalEvidenceAreaCoverageStatus>[];

  for (final areaId in definition.areaIds) {
    final area = matrixResult.area(areaId);
    areaStatuses.add(area.status);
    supportCaseIds.addAll(area.supportCaseIds);
    protectedCaseIds.addAll(area.protectedSupportCaseIds);
    for (final caseId in area.androidProofCaseIds) {
      if (_proofStillValid(androidProofEvidence, caseId)) {
        androidProofCaseIds.add(caseId);
      }
    }
    relatedBuckets.addAll(area.relatedBucketIds);
    relatedFields.addAll(area.relatedContractFields);
    warnings.addAll(area.warnings);
    blockers.addAll(area.blockers);
  }

  for (final bucketId in relatedBuckets.toList()) {
    final bucket = buckets.bucket(bucketId);
    blockers.addAll(bucket.blockers);
    if (bucket.status == InternalEvidenceBucketStatus.partial) {
      warnings.add('${bucketId.wire}: bucket is partial support only');
    }
  }

  final futurePrerequisites = <String>{
    ...definition.futurePrerequisites,
    ..._fieldPrerequisites(contract, relatedFields),
  };

  final readiness = _readinessFor(
    definition: definition,
    supportCaseCount: supportCaseIds.length,
    androidProofCaseCount: androidProofCaseIds.length,
    areaStatuses: areaStatuses,
  );
  final recommendation = _recommendationFor(
    definition: definition,
    readiness: readiness,
    supportCaseCount: supportCaseIds.length,
    androidProofCaseCount: androidProofCaseIds.length,
  );

  return InternalNonLabelScoringDimensionDesign(
    dimensionId: definition.id,
    readiness: readiness,
    signalType: definition.signalType,
    relatedAreaIds: List<InternalEvidenceAreaId>.unmodifiable(
      definition.areaIds,
    ),
    relatedBucketIds: _sortedBucketIds(relatedBuckets),
    relatedContractFields: _sortedFields(relatedFields),
    supportingCaseIds: _sortedStrings(supportCaseIds),
    protectedSupportCaseIds: _sortedStrings(protectedCaseIds),
    androidProofCaseIds: _sortedStrings(androidProofCaseIds),
    warnings: _sortedStrings(<String>{
      ...warnings,
      if (definition.warnWhenLimitedProof && androidProofCaseIds.length == 3)
        'limited to captured Android proof IDs',
      if (readiness ==
          InternalNonLabelScoringDimensionReadiness.partialNeedsMoreCases)
        'needs more Golden cases before prototype use',
    }),
    blockers: _sortedStrings(blockers),
    futurePrerequisites: _sortedStrings(futurePrerequisites),
    recommendation: recommendation,
  );
}

InternalNonLabelScoringDimensionReadiness _readinessFor({
  required _DimensionDefinition definition,
  required int supportCaseCount,
  required int androidProofCaseCount,
  required List<InternalEvidenceAreaCoverageStatus> areaStatuses,
}) {
  if (definition.fixedReadiness != null) return definition.fixedReadiness!;
  if (supportCaseCount == 0) {
    return InternalNonLabelScoringDimensionReadiness.unsupported;
  }
  if (definition.id ==
      InternalNonLabelScoringDimensionId.androidProofConfidenceDimension) {
    return androidProofCaseCount == 3
        ? InternalNonLabelScoringDimensionReadiness.designReady
        : InternalNonLabelScoringDimensionReadiness.partialNeedsMoreCases;
  }
  if (definition.id ==
      InternalNonLabelScoringDimensionId.pvMultiPvSupportDimension) {
    return androidProofCaseCount == supportCaseCount && supportCaseCount >= 3
        ? InternalNonLabelScoringDimensionReadiness.designReady
        : InternalNonLabelScoringDimensionReadiness.partialNeedsMoreCases;
  }
  if (definition.partialIfAnyAreaPartial &&
      areaStatuses.contains(InternalEvidenceAreaCoverageStatus.partial)) {
    return definition.id ==
            InternalNonLabelScoringDimensionId.suppressionSafetyDimension
        ? InternalNonLabelScoringDimensionReadiness.designReadyWithWarnings
        : InternalNonLabelScoringDimensionReadiness.partialNeedsMoreCases;
  }
  if (definition.warningReadiness) {
    return InternalNonLabelScoringDimensionReadiness.designReadyWithWarnings;
  }
  return InternalNonLabelScoringDimensionReadiness.designReady;
}

InternalNonLabelScoringDesignRecommendation _recommendationFor({
  required _DimensionDefinition definition,
  required InternalNonLabelScoringDimensionReadiness readiness,
  required int supportCaseCount,
  required int androidProofCaseCount,
}) {
  if (definition.fixedRecommendation != null) {
    return definition.fixedRecommendation!;
  }
  if (definition.id ==
      InternalNonLabelScoringDimensionId.androidProofConfidenceDimension) {
    return androidProofCaseCount == 3
        ? InternalNonLabelScoringDesignRecommendation.keepDesignStable
        : InternalNonLabelScoringDesignRecommendation
              .addOwnerAndroidProofOnlyIfPvRequired;
  }
  if (readiness == InternalNonLabelScoringDimensionReadiness.designReady ||
      readiness ==
          InternalNonLabelScoringDimensionReadiness.designReadyWithWarnings) {
    return InternalNonLabelScoringDesignRecommendation.keepDesignStable;
  }
  if (supportCaseCount == 0) {
    return InternalNonLabelScoringDesignRecommendation.addHandcraftedCase;
  }
  return InternalNonLabelScoringDesignRecommendation.addHandcraftedCase;
}

InternalNonLabelScoringDesignStatus _designStatusFor(
  InternalNonLabelScoringDesignResult result,
  List<InternalNonLabelScoringDesignValidationFinding> findings,
) {
  if (findings.any((finding) => finding.isError)) {
    return InternalNonLabelScoringDesignStatus.blockedByValidation;
  }
  if (result.hasWarnings ||
      result.dimensions.any(
        (dimension) =>
            dimension.readiness ==
                InternalNonLabelScoringDimensionReadiness
                    .designReadyWithWarnings ||
            dimension.readiness ==
                InternalNonLabelScoringDimensionReadiness.partialNeedsMoreCases,
      )) {
    return InternalNonLabelScoringDesignStatus.designReadyWithWarnings;
  }
  return InternalNonLabelScoringDesignStatus.designReadyInternalOnly;
}

List<String> _fieldPrerequisites(
  BasicClassifierEvidenceContractPrototype contract,
  Set<BasicClassifierContractField> fields,
) {
  final prerequisites = <String>{};
  for (final field in fields) {
    final status = contract.field(field).status;
    if (status == BasicClassifierEvidenceFieldStatus.futureOnly ||
        status == BasicClassifierEvidenceFieldStatus.notImplemented) {
      if (field == BasicClassifierContractField.cpLossAvailable) {
        prerequisites.add(
          'implement internal CP-loss calculation later, non-official first',
        );
      } else if (field ==
          BasicClassifierContractField.winProbabilityAvailable) {
        prerequisites.add(
          'implement internal win-probability transform later, non-official first',
        );
      } else {
        prerequisites.add('${field.wire}: future evidence input required');
      }
    }
  }
  return _sortedStrings(prerequisites);
}

bool _proofStillValid(
  GoldenAndroidProofEvidence? androidProofEvidence,
  String caseId,
) {
  if (androidProofEvidence == null) return false;
  return androidProofEvidence.isRealDeviceProofCapturedFor(
    caseId,
    minMultiPvLineCount: 1,
    requirePv: true,
  );
}

InternalNonLabelScoringDimensionDesign? _dimensionOrNull(
  List<InternalNonLabelScoringDimensionDesign> dimensions,
  InternalNonLabelScoringDimensionId id,
) {
  for (final dimension in dimensions) {
    if (dimension.dimensionId == id) return dimension;
  }
  return null;
}

int _compareFindings(
  InternalNonLabelScoringDesignValidationFinding a,
  InternalNonLabelScoringDesignValidationFinding b,
) {
  final idCompare = a.id.compareTo(b.id);
  if (idCompare != 0) return idCompare;
  final dimensionCompare = (a.dimensionId?.wire ?? '').compareTo(
    b.dimensionId?.wire ?? '',
  );
  if (dimensionCompare != 0) return dimensionCompare;
  return (a.caseId ?? '').compareTo(b.caseId ?? '');
}

String _ids(Iterable<String> values) {
  final sorted = _sortedStrings(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

String _areaIds(List<InternalEvidenceAreaId> values) {
  return values.isEmpty ? '-' : values.map((value) => value.wire).join(', ');
}

String _dimensionIds(Iterable<InternalNonLabelScoringDimensionDesign> values) {
  final ids = values.map((dimension) => dimension.dimensionId.wire).toList()
    ..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.toList()..sort();
}

List<InternalEvidenceBucketId> _sortedBucketIds(
  Iterable<InternalEvidenceBucketId> values,
) {
  return values.toList()..sort((a, b) => a.index.compareTo(b.index));
}

List<BasicClassifierContractField> _sortedFields(
  Iterable<BasicClassifierContractField> values,
) {
  return values.toList()..sort((a, b) => a.index.compareTo(b.index));
}

List<String> _safeContractFieldNames(
  List<BasicClassifierContractField> fields,
) {
  return fields
      .where(
        (field) =>
            field != BasicClassifierContractField.officialAccuracyAvailable &&
            field != BasicClassifierContractField.officialAcplAvailable,
      )
      .map((field) => field.wire)
      .toList();
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
      normalized.contains('numericmovescore');
}

class _DimensionDefinition {
  const _DimensionDefinition({
    required this.id,
    required this.areaIds,
    required this.signalType,
    this.futurePrerequisites = const <String>[],
    this.fixedReadiness,
    this.fixedRecommendation,
    this.partialIfAnyAreaPartial = false,
    this.warningReadiness = false,
    this.warnWhenLimitedProof = false,
  });

  final InternalNonLabelScoringDimensionId id;
  final List<InternalEvidenceAreaId> areaIds;
  final InternalNonLabelScoringSignalType signalType;
  final List<String> futurePrerequisites;
  final InternalNonLabelScoringDimensionReadiness? fixedReadiness;
  final InternalNonLabelScoringDesignRecommendation? fixedRecommendation;
  final bool partialIfAnyAreaPartial;
  final bool warningReadiness;
  final bool warnWhenLimitedProof;
}

const _dimensionDefinitions = <_DimensionDefinition>[
  _DimensionDefinition(
    id: InternalNonLabelScoringDimensionId.tacticalPressureDimension,
    areaIds: <InternalEvidenceAreaId>[InternalEvidenceAreaId.tacticalArea],
    signalType: InternalNonLabelScoringSignalType.primarySignal,
  ),
  _DimensionDefinition(
    id: InternalNonLabelScoringDimensionId.materialSwingDimension,
    areaIds: <InternalEvidenceAreaId>[InternalEvidenceAreaId.materialSwingArea],
    signalType: InternalNonLabelScoringSignalType.primarySignal,
  ),
  _DimensionDefinition(
    id: InternalNonLabelScoringDimensionId.forcingLineDimension,
    areaIds: <InternalEvidenceAreaId>[InternalEvidenceAreaId.forcingLineArea],
    signalType: InternalNonLabelScoringSignalType.primarySignal,
  ),
  _DimensionDefinition(
    id: InternalNonLabelScoringDimensionId.kingSafetyDimension,
    areaIds: <InternalEvidenceAreaId>[InternalEvidenceAreaId.kingSafetyArea],
    signalType: InternalNonLabelScoringSignalType.secondarySignal,
    warningReadiness: true,
  ),
  _DimensionDefinition(
    id: InternalNonLabelScoringDimensionId.endgamePrecisionDimension,
    areaIds: <InternalEvidenceAreaId>[
      InternalEvidenceAreaId.conservativeEndgameArea,
    ],
    signalType: InternalNonLabelScoringSignalType.supportingSignal,
    warningReadiness: true,
    futurePrerequisites: <String>[
      'add more conservative endgame Golden cases before broad prototype use',
    ],
  ),
  _DimensionDefinition(
    id: InternalNonLabelScoringDimensionId.suppressionSafetyDimension,
    areaIds: <InternalEvidenceAreaId>[
      InternalEvidenceAreaId.safetySuppressionArea,
      InternalEvidenceAreaId.budgetPressureArea,
      InternalEvidenceAreaId.openingSuppressionArea,
      InternalEvidenceAreaId.forcedMoveSuppressionArea,
      InternalEvidenceAreaId.invalidFenSuppressionArea,
    ],
    signalType: InternalNonLabelScoringSignalType.suppressionSignal,
    partialIfAnyAreaPartial: true,
    futurePrerequisites: <String>[
      'add more opening, forced-move, invalid-FEN, and budget hard cases if needed',
    ],
  ),
  _DimensionDefinition(
    id: InternalNonLabelScoringDimensionId.candidateSpreadDimension,
    areaIds: <InternalEvidenceAreaId>[
      InternalEvidenceAreaId.candidateSpreadArea,
    ],
    signalType: InternalNonLabelScoringSignalType.supportingSignal,
  ),
  _DimensionDefinition(
    id: InternalNonLabelScoringDimensionId.pvMultiPvSupportDimension,
    areaIds: <InternalEvidenceAreaId>[InternalEvidenceAreaId.pvMultiPvArea],
    signalType: InternalNonLabelScoringSignalType.confidenceSignal,
    futurePrerequisites: <String>[
      'keep PV/MultiPV use limited to proof-backed or explicitly PV-supported cases',
    ],
  ),
  _DimensionDefinition(
    id: InternalNonLabelScoringDimensionId.androidProofConfidenceDimension,
    areaIds: <InternalEvidenceAreaId>[
      InternalEvidenceAreaId.androidProofBackedArea,
    ],
    signalType: InternalNonLabelScoringSignalType.confidenceSignal,
    warnWhenLimitedProof: true,
    futurePrerequisites: <String>[
      'add owner Android proof only when a new proof-required case appears',
    ],
  ),
  _DimensionDefinition(
    id: InternalNonLabelScoringDimensionId.budgetRiskDimension,
    areaIds: <InternalEvidenceAreaId>[
      InternalEvidenceAreaId.budgetPressureArea,
    ],
    signalType: InternalNonLabelScoringSignalType.riskSignal,
    fixedReadiness:
        InternalNonLabelScoringDimensionReadiness.partialNeedsMoreCases,
    fixedRecommendation:
        InternalNonLabelScoringDesignRecommendation.addHandcraftedCase,
    futurePrerequisites: <String>[
      'add more Golden cases for budget pressure before prototype use',
    ],
  ),
  _DimensionDefinition(
    id: InternalNonLabelScoringDimensionId.quietPreparatoryDimensionExcluded,
    areaIds: <InternalEvidenceAreaId>[
      InternalEvidenceAreaId.quietPreparatoryExcludedArea,
    ],
    signalType: InternalNonLabelScoringSignalType.excludedSignal,
    fixedReadiness: InternalNonLabelScoringDimensionReadiness.excluded,
    fixedRecommendation:
        InternalNonLabelScoringDesignRecommendation.keepExcludedByNegativeGuard,
    futurePrerequisites: <String>[
      'remain excluded until the negative guard policy changes with proof',
    ],
  ),
  _DimensionDefinition(
    id: InternalNonLabelScoringDimensionId.productLabelDimensionBlocked,
    areaIds: <InternalEvidenceAreaId>[
      InternalEvidenceAreaId.productLabelOutputBlockedArea,
    ],
    signalType: InternalNonLabelScoringSignalType.blockedSignal,
    fixedReadiness: InternalNonLabelScoringDimensionReadiness.blockedByPolicy,
    fixedRecommendation:
        InternalNonLabelScoringDesignRecommendation.keepBlockedByPolicy,
  ),
  _DimensionDefinition(
    id: InternalNonLabelScoringDimensionId.advancedLabelDimensionBlocked,
    areaIds: <InternalEvidenceAreaId>[
      InternalEvidenceAreaId.advancedLabelGateBlockedArea,
    ],
    signalType: InternalNonLabelScoringSignalType.blockedSignal,
    fixedReadiness: InternalNonLabelScoringDimensionReadiness.blockedByPolicy,
    fixedRecommendation:
        InternalNonLabelScoringDesignRecommendation.keepBlockedByPolicy,
  ),
  _DimensionDefinition(
    id: InternalNonLabelScoringDimensionId.officialMetricDimensionBlocked,
    areaIds: <InternalEvidenceAreaId>[
      InternalEvidenceAreaId.officialMetricsBlockedArea,
    ],
    signalType: InternalNonLabelScoringSignalType.blockedSignal,
    fixedReadiness: InternalNonLabelScoringDimensionReadiness.blockedByPolicy,
    fixedRecommendation:
        InternalNonLabelScoringDesignRecommendation.keepBlockedByPolicy,
  ),
  _DimensionDefinition(
    id: InternalNonLabelScoringDimensionId.cpLossDimensionFutureOnly,
    areaIds: <InternalEvidenceAreaId>[
      InternalEvidenceAreaId.cpLossComputationBlockedArea,
    ],
    signalType: InternalNonLabelScoringSignalType.futureSignal,
    fixedReadiness: InternalNonLabelScoringDimensionReadiness.futureOnly,
    fixedRecommendation:
        InternalNonLabelScoringDesignRecommendation.futureInternalInputOnly,
    futurePrerequisites: <String>[
      'implement internal CP-loss calculation later, non-official first',
    ],
  ),
  _DimensionDefinition(
    id: InternalNonLabelScoringDimensionId.winProbabilityDimensionFutureOnly,
    areaIds: <InternalEvidenceAreaId>[
      InternalEvidenceAreaId.winProbabilityComputationBlockedArea,
    ],
    signalType: InternalNonLabelScoringSignalType.futureSignal,
    fixedReadiness: InternalNonLabelScoringDimensionReadiness.futureOnly,
    fixedRecommendation:
        InternalNonLabelScoringDesignRecommendation.futureInternalInputOnly,
    futurePrerequisites: <String>[
      'implement internal win-probability transform later, non-official first',
    ],
  ),
];

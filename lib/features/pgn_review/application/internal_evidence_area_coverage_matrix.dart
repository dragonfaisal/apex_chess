/// Developer-only evidence-area coverage matrix for internal bucket results.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/basic_classifier_evidence_contract.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_review.dart';
import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_guards.dart';
import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_harness.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';

const internalEvidenceAreaCoverageMatrixReportVersion =
    'internal-evidence-area-coverage-matrix-v1';

enum InternalEvidenceAreaId {
  tacticalArea('tacticalArea'),
  materialSwingArea('materialSwingArea'),
  forcingLineArea('forcingLineArea'),
  kingSafetyArea('kingSafetyArea'),
  conservativeEndgameArea('conservativeEndgameArea'),
  safetySuppressionArea('safetySuppressionArea'),
  androidProofBackedArea('androidProofBackedArea'),
  candidateSpreadArea('candidateSpreadArea'),
  pvMultiPvArea('pvMultiPvArea'),
  budgetPressureArea('budgetPressureArea'),
  openingSuppressionArea('openingSuppressionArea'),
  forcedMoveSuppressionArea('forcedMoveSuppressionArea'),
  invalidFenSuppressionArea('invalidFenSuppressionArea'),
  quietPreparatoryExcludedArea('quietPreparatoryExcludedArea'),
  productLabelOutputBlockedArea('productLabelOutputBlockedArea'),
  advancedLabelGateBlockedArea('advancedLabelGateBlockedArea'),
  officialMetricsBlockedArea('officialMetricsBlockedArea'),
  cpLossComputationBlockedArea('cpLossComputationBlockedArea'),
  winProbabilityComputationBlockedArea('winProbabilityComputationBlockedArea');

  const InternalEvidenceAreaId(this.wire);

  final String wire;
}

enum InternalEvidenceAreaCoverageStatus {
  strong('strong'),
  adequate('adequate'),
  partial('partial'),
  weak('weak'),
  excluded('excluded'),
  blockedByPolicy('blockedByPolicy'),
  futureOnly('futureOnly'),
  unsupported('unsupported'),
  invalid('invalid');

  const InternalEvidenceAreaCoverageStatus(this.wire);

  final String wire;
}

enum InternalEvidenceAreaCoverageMatrixStatus {
  readyInternalOnly('readyInternalOnly'),
  readyWithWarnings('readyWithWarnings'),
  blockedByHarness('blockedByHarness'),
  blockedByValidation('blockedByValidation'),
  invalid('invalid');

  const InternalEvidenceAreaCoverageMatrixStatus(this.wire);

  final String wire;
}

enum InternalEvidenceAreaGapRecommendation {
  keepStable('keepStable'),
  addHandcraftedCase('addHandcraftedCase'),
  addFakeEvidence('addFakeEvidence'),
  addOwnerAndroidProofOnlyIfPvRequired('addOwnerAndroidProofOnlyIfPvRequired'),
  keepExcludedByNegativeGuard('keepExcludedByNegativeGuard'),
  keepBlockedByPolicy('keepBlockedByPolicy'),
  investigateMismatch('investigateMismatch'),
  futureProductInputOnly('futureProductInputOnly');

  const InternalEvidenceAreaGapRecommendation(this.wire);

  final String wire;
}

enum InternalEvidenceAreaCoverageValidationSeverity {
  warning('warning'),
  error('error');

  const InternalEvidenceAreaCoverageValidationSeverity(this.wire);

  final String wire;
}

enum InternalEvidenceAreaCoverageMatrixReportFormat {
  markdown('markdown'),
  json('json');

  const InternalEvidenceAreaCoverageMatrixReportFormat(this.wire);

  final String wire;
}

enum InternalEvidenceAreaCoverageNextPhase {
  internalNonLabelScoringDesign(
    'Phase 31G -- Internal Non-Label Coverage-Informed Scoring Design',
  ),
  coverageEvidenceFixes('Phase 31G -- Coverage Evidence Fixes');

  const InternalEvidenceAreaCoverageNextPhase(this.wire);

  final String wire;
}

class InternalEvidenceAreaCoverageMatrixRequest {
  const InternalEvidenceAreaCoverageMatrixRequest({
    this.harnessRequest = const InternalBucketExperimentHarnessRequest(),
    this.harnessResult,
    this.bucketPrototype,
    this.contract,
    this.review,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.cases = GoldenAnalysisCases.defaults,
    this.harness = const InternalBucketExperimentHarness(),
    this.bucketBuilder = const InternalEvidenceBucketBuilder(),
    this.contractBuilder = const BasicClassifierEvidenceContractBuilder(),
    this.reviewRunner = const GoldenEvidenceReviewRunner(),
  });

  final InternalBucketExperimentHarnessRequest harnessRequest;
  final InternalBucketExperimentHarnessResult? harnessResult;
  final InternalEvidenceBucketPrototype? bucketPrototype;
  final BasicClassifierEvidenceContractPrototype? contract;
  final GoldenEvidenceReviewResult? review;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final List<GoldenAnalysisCase> cases;
  final InternalBucketExperimentHarness harness;
  final InternalEvidenceBucketBuilder bucketBuilder;
  final BasicClassifierEvidenceContractBuilder contractBuilder;
  final GoldenEvidenceReviewRunner reviewRunner;
}

class InternalEvidenceAreaCoverageEntry {
  const InternalEvidenceAreaCoverageEntry({
    required this.areaId,
    required this.status,
    required this.supportCaseIds,
    required this.protectedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.relatedBucketIds,
    required this.relatedContractFields,
    required this.supportCaseCount,
    required this.protectedSupportCaseCount,
    required this.androidProofCaseCount,
    required this.bucketStatusSupport,
    required this.motifCoverageSupport,
    required this.suppressionSupport,
    required this.negativeGuardExclusion,
    required this.futureOnlyFieldCount,
    required this.blockedPolicyCount,
    required this.warningCount,
    required this.warnings,
    required this.blockers,
    required this.recommendation,
    this.isProductOutput = false,
    this.isClassifierLabel = false,
    this.isOfficialMetric = false,
    this.isQuietScope = false,
    this.cpLossComputationImplemented = false,
    this.winProbabilityComputationImplemented = false,
  });

  final InternalEvidenceAreaId areaId;
  final InternalEvidenceAreaCoverageStatus status;
  final List<String> supportCaseIds;
  final List<String> protectedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<InternalEvidenceBucketId> relatedBucketIds;
  final List<BasicClassifierContractField> relatedContractFields;
  final int supportCaseCount;
  final int protectedSupportCaseCount;
  final int androidProofCaseCount;
  final int bucketStatusSupport;
  final int motifCoverageSupport;
  final int suppressionSupport;
  final bool negativeGuardExclusion;
  final int futureOnlyFieldCount;
  final int blockedPolicyCount;
  final int warningCount;
  final List<String> warnings;
  final List<String> blockers;
  final InternalEvidenceAreaGapRecommendation recommendation;
  final bool isProductOutput;
  final bool isClassifierLabel;
  final bool isOfficialMetric;
  final bool isQuietScope;
  final bool cpLossComputationImplemented;
  final bool winProbabilityComputationImplemented;

  bool get isActive =>
      status == InternalEvidenceAreaCoverageStatus.strong ||
      status == InternalEvidenceAreaCoverageStatus.adequate ||
      status == InternalEvidenceAreaCoverageStatus.partial ||
      status == InternalEvidenceAreaCoverageStatus.weak;

  bool get isUnsafeIfActive =>
      isActive &&
      (isProductOutput ||
          isClassifierLabel ||
          isOfficialMetric ||
          isQuietScope ||
          cpLossComputationImplemented ||
          winProbabilityComputationImplemented);

  InternalEvidenceAreaCoverageEntry copyWith({
    InternalEvidenceAreaId? areaId,
    InternalEvidenceAreaCoverageStatus? status,
    List<String>? supportCaseIds,
    List<String>? protectedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<InternalEvidenceBucketId>? relatedBucketIds,
    List<BasicClassifierContractField>? relatedContractFields,
    int? supportCaseCount,
    int? protectedSupportCaseCount,
    int? androidProofCaseCount,
    int? bucketStatusSupport,
    int? motifCoverageSupport,
    int? suppressionSupport,
    bool? negativeGuardExclusion,
    int? futureOnlyFieldCount,
    int? blockedPolicyCount,
    int? warningCount,
    List<String>? warnings,
    List<String>? blockers,
    InternalEvidenceAreaGapRecommendation? recommendation,
    bool? isProductOutput,
    bool? isClassifierLabel,
    bool? isOfficialMetric,
    bool? isQuietScope,
    bool? cpLossComputationImplemented,
    bool? winProbabilityComputationImplemented,
  }) {
    final effectiveSupport = supportCaseIds ?? this.supportCaseIds;
    final effectiveProtected =
        protectedSupportCaseIds ?? this.protectedSupportCaseIds;
    final effectiveAndroid = androidProofCaseIds ?? this.androidProofCaseIds;
    final effectiveWarnings = warnings ?? this.warnings;
    return InternalEvidenceAreaCoverageEntry(
      areaId: areaId ?? this.areaId,
      status: status ?? this.status,
      supportCaseIds: effectiveSupport,
      protectedSupportCaseIds: effectiveProtected,
      androidProofCaseIds: effectiveAndroid,
      relatedBucketIds: relatedBucketIds ?? this.relatedBucketIds,
      relatedContractFields:
          relatedContractFields ?? this.relatedContractFields,
      supportCaseCount: supportCaseCount ?? effectiveSupport.length,
      protectedSupportCaseCount:
          protectedSupportCaseCount ?? effectiveProtected.length,
      androidProofCaseCount: androidProofCaseCount ?? effectiveAndroid.length,
      bucketStatusSupport: bucketStatusSupport ?? this.bucketStatusSupport,
      motifCoverageSupport: motifCoverageSupport ?? this.motifCoverageSupport,
      suppressionSupport: suppressionSupport ?? this.suppressionSupport,
      negativeGuardExclusion:
          negativeGuardExclusion ?? this.negativeGuardExclusion,
      futureOnlyFieldCount: futureOnlyFieldCount ?? this.futureOnlyFieldCount,
      blockedPolicyCount: blockedPolicyCount ?? this.blockedPolicyCount,
      warningCount: warningCount ?? effectiveWarnings.length,
      warnings: effectiveWarnings,
      blockers: blockers ?? this.blockers,
      recommendation: recommendation ?? this.recommendation,
      isProductOutput: isProductOutput ?? this.isProductOutput,
      isClassifierLabel: isClassifierLabel ?? this.isClassifierLabel,
      isOfficialMetric: isOfficialMetric ?? this.isOfficialMetric,
      isQuietScope: isQuietScope ?? this.isQuietScope,
      cpLossComputationImplemented:
          cpLossComputationImplemented ?? this.cpLossComputationImplemented,
      winProbabilityComputationImplemented:
          winProbabilityComputationImplemented ??
          this.winProbabilityComputationImplemented,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'areaId': areaId.wire,
      'status': status.wire,
      'supportCaseIds': supportCaseIds,
      'protectedSupportCaseIds': protectedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'relatedBucketIds': relatedBucketIds.map((id) => id.wire).toList(),
      'relatedContractFields': relatedContractFields
          .map((field) => field.wire)
          .toList(),
      'coverageStrength': <String, Object?>{
        'supportCaseCount': supportCaseCount,
        'protectedSupportCaseCount': protectedSupportCaseCount,
        'androidProofCaseCount': androidProofCaseCount,
        'bucketStatusSupport': bucketStatusSupport,
        'motifCoverageSupport': motifCoverageSupport,
        'suppressionSupport': suppressionSupport,
        'negativeGuardExclusion': negativeGuardExclusion,
        'futureOnlyFieldCount': futureOnlyFieldCount,
        'blockedPolicyCount': blockedPolicyCount,
        'warningCount': warningCount,
      },
      'warnings': warnings,
      'blockers': blockers,
      'recommendation': recommendation.wire,
      'isProductOutput': isProductOutput,
      'isClassifierLabel': isClassifierLabel,
      'isOfficialMetric': isOfficialMetric,
      'isQuietScope': isQuietScope,
      'cpLossComputationImplemented': cpLossComputationImplemented,
      'winProbabilityComputationImplemented':
          winProbabilityComputationImplemented,
    };
  }
}

class InternalEvidenceAreaCoverageValidationFinding {
  const InternalEvidenceAreaCoverageValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.areaId,
    this.caseId,
  });

  final String id;
  final InternalEvidenceAreaCoverageValidationSeverity severity;
  final String message;
  final InternalEvidenceAreaId? areaId;
  final String? caseId;

  bool get isError =>
      severity == InternalEvidenceAreaCoverageValidationSeverity.error;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (areaId != null) 'areaId': areaId!.wire,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class InternalEvidenceAreaCoverageMatrixResult {
  const InternalEvidenceAreaCoverageMatrixResult({
    required this.status,
    required this.harnessStatus,
    required this.guardStatus,
    required this.guardAllowed,
    required this.areaCount,
    required this.entries,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.nextRecommendedPhase,
    required this.provenAndroidCaseIds,
    required this.unprovenAndroidCaseIds,
    required this.excludedScopeIds,
    this.developerOnly = true,
    this.productOutputEmitted = false,
    this.classifierLabelsEmitted = false,
    this.officialMetricsEmitted = false,
    this.cpLossComputed = false,
    this.winProbabilityComputed = false,
    this.directEngineAccessUsed = false,
    this.uiOutputUsed = false,
    this.backendOutputUsed = false,
    this.persistenceUsed = false,
    this.emittedOutputFamilies = const <String>[],
  });

  final InternalEvidenceAreaCoverageMatrixStatus status;
  final InternalBucketExperimentHarnessStatus harnessStatus;
  final InternalBucketExperimentGuardStatus guardStatus;
  final bool guardAllowed;
  final int areaCount;
  final List<InternalEvidenceAreaCoverageEntry> entries;
  final List<InternalEvidenceAreaCoverageValidationFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final InternalEvidenceAreaCoverageNextPhase nextRecommendedPhase;
  final List<String> provenAndroidCaseIds;
  final List<String> unprovenAndroidCaseIds;
  final List<String> excludedScopeIds;
  final bool developerOnly;
  final bool productOutputEmitted;
  final bool classifierLabelsEmitted;
  final bool officialMetricsEmitted;
  final bool cpLossComputed;
  final bool winProbabilityComputed;
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
            InternalEvidenceAreaCoverageValidationSeverity.warning,
      ) ||
      entries.any((entry) => entry.warningCount > 0);

  bool get isStrictlyBlocked =>
      status == InternalEvidenceAreaCoverageMatrixStatus.blockedByHarness ||
      status == InternalEvidenceAreaCoverageMatrixStatus.blockedByValidation ||
      status == InternalEvidenceAreaCoverageMatrixStatus.invalid;

  bool get hasUnsafeMatrixPolicyViolation {
    return hasValidationErrors ||
        entries.any((entry) => entry.isUnsafeIfActive) ||
        unprovenAndroidCaseIds.isNotEmpty ||
        productOutputEmitted ||
        classifierLabelsEmitted ||
        officialMetricsEmitted ||
        cpLossComputed ||
        winProbabilityComputed ||
        directEngineAccessUsed ||
        uiOutputUsed ||
        backendOutputUsed ||
        persistenceUsed ||
        emittedOutputFamilies.any(_isForbiddenEmittedOutput);
  }

  InternalEvidenceAreaCoverageEntry area(InternalEvidenceAreaId id) {
    return entries.singleWhere((entry) => entry.areaId == id);
  }

  List<InternalEvidenceAreaCoverageEntry> get strongAreas => entries
      .where(
        (entry) => entry.status == InternalEvidenceAreaCoverageStatus.strong,
      )
      .toList(growable: false);

  List<InternalEvidenceAreaCoverageEntry> get adequateAreas => entries
      .where(
        (entry) => entry.status == InternalEvidenceAreaCoverageStatus.adequate,
      )
      .toList(growable: false);

  List<InternalEvidenceAreaCoverageEntry> get partialAreas => entries
      .where(
        (entry) => entry.status == InternalEvidenceAreaCoverageStatus.partial,
      )
      .toList(growable: false);

  InternalEvidenceAreaCoverageMatrixResult copyWith({
    InternalEvidenceAreaCoverageMatrixStatus? status,
    InternalBucketExperimentHarnessStatus? harnessStatus,
    InternalBucketExperimentGuardStatus? guardStatus,
    bool? guardAllowed,
    int? areaCount,
    List<InternalEvidenceAreaCoverageEntry>? entries,
    List<InternalEvidenceAreaCoverageValidationFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    InternalEvidenceAreaCoverageNextPhase? nextRecommendedPhase,
    List<String>? provenAndroidCaseIds,
    List<String>? unprovenAndroidCaseIds,
    List<String>? excludedScopeIds,
    bool? developerOnly,
    bool? productOutputEmitted,
    bool? classifierLabelsEmitted,
    bool? officialMetricsEmitted,
    bool? cpLossComputed,
    bool? winProbabilityComputed,
    bool? directEngineAccessUsed,
    bool? uiOutputUsed,
    bool? backendOutputUsed,
    bool? persistenceUsed,
    List<String>? emittedOutputFamilies,
  }) {
    final effectiveEntries = entries ?? this.entries;
    return InternalEvidenceAreaCoverageMatrixResult(
      status: status ?? this.status,
      harnessStatus: harnessStatus ?? this.harnessStatus,
      guardStatus: guardStatus ?? this.guardStatus,
      guardAllowed: guardAllowed ?? this.guardAllowed,
      areaCount: areaCount ?? effectiveEntries.length,
      entries: effectiveEntries,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      nextRecommendedPhase: nextRecommendedPhase ?? this.nextRecommendedPhase,
      provenAndroidCaseIds: provenAndroidCaseIds ?? this.provenAndroidCaseIds,
      unprovenAndroidCaseIds:
          unprovenAndroidCaseIds ?? this.unprovenAndroidCaseIds,
      excludedScopeIds: excludedScopeIds ?? this.excludedScopeIds,
      developerOnly: developerOnly ?? this.developerOnly,
      productOutputEmitted: productOutputEmitted ?? this.productOutputEmitted,
      classifierLabelsEmitted:
          classifierLabelsEmitted ?? this.classifierLabelsEmitted,
      officialMetricsEmitted:
          officialMetricsEmitted ?? this.officialMetricsEmitted,
      cpLossComputed: cpLossComputed ?? this.cpLossComputed,
      winProbabilityComputed:
          winProbabilityComputed ?? this.winProbabilityComputed,
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
      ..writeln('# Internal Evidence Area Coverage Matrix')
      ..writeln()
      ..writeln('- version: $internalEvidenceAreaCoverageMatrixReportVersion')
      ..writeln('- matrix status: ${status.wire}')
      ..writeln('- harness status: ${harnessStatus.wire}')
      ..writeln('- guard status: ${guardStatus.wire}')
      ..writeln('- guard allowed: $guardAllowed')
      ..writeln('- developer only: $developerOnly')
      ..writeln('- classifier output emitted: false')
      ..writeln()
      ..writeln('## Coverage Strength Policy')
      ..writeln(
        '- coverage strength uses support-case counts, protected-case counts, '
        'captured Android proof counts, bucket support status, motif support, '
        'suppression support, negative-guard exclusion, future-only field '
        'counts, policy-block counts, and warning counts',
      )
      ..writeln(
        '- coverage strength is evidence coverage only; it does not score moves, '
        'classify moves, compute product metrics, call an engine, or write files',
      )
      ..writeln()
      ..writeln('## Area Table')
      ..writeln(
        '| Area | Status | Support Cases | Android Proof | Buckets | Recommendation |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- |');
    if (entries.isEmpty) {
      buffer.writeln('| - | - | - | - | - | - |');
    } else {
      for (final entry in entries) {
        buffer.writeln(
          '| ${entry.areaId.wire} | ${entry.status.wire} | '
          '${_ids(entry.supportCaseIds)} | ${_ids(entry.androidProofCaseIds)} | '
          '${_bucketIds(entry.relatedBucketIds)} | '
          '${entry.recommendation.wire} |',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('## Coverage Statuses')
      ..writeln('- strong: ${_areaIds(strongAreas)}')
      ..writeln('- adequate: ${_areaIds(adequateAreas)}')
      ..writeln('- partial: ${_areaIds(partialAreas)}')
      ..writeln(
        '- excluded: ${_areaIds(entries.where((entry) => entry.status == InternalEvidenceAreaCoverageStatus.excluded))}',
      )
      ..writeln(
        '- blocked: ${_areaIds(entries.where((entry) => entry.status == InternalEvidenceAreaCoverageStatus.blockedByPolicy))}',
      )
      ..writeln(
        '- future-only: ${_areaIds(entries.where((entry) => entry.status == InternalEvidenceAreaCoverageStatus.futureOnly))}',
      )
      ..writeln()
      ..writeln('## Support Cases');
    for (final entry in entries) {
      buffer.writeln('- ${entry.areaId.wire}: ${_ids(entry.supportCaseIds)}');
    }

    buffer
      ..writeln()
      ..writeln('## Android Proof Support')
      ..writeln('- proven case IDs: ${_ids(provenAndroidCaseIds)}')
      ..writeln('- unproven case IDs: ${_ids(unprovenAndroidCaseIds)}')
      ..writeln()
      ..writeln('## Gaps And Recommendations');
    for (final entry in entries.where((entry) => entry.warnings.isNotEmpty)) {
      buffer.writeln(
        '- ${entry.areaId.wire}: ${entry.recommendation.wire}; '
        '${entry.warnings.join("; ")}',
      );
    }
    if (!entries.any((entry) => entry.warnings.isNotEmpty)) {
      buffer.writeln('- none');
    }

    buffer
      ..writeln()
      ..writeln('## Excluded And Blocked Areas')
      ..writeln('- quiet/preparatory exclusion: ${_ids(excludedScopeIds)}')
      ..writeln('- product-label block: active')
      ..writeln('- advanced-label block: active')
      ..writeln('- official-metric block: active')
      ..writeln('- CP-loss computation block: active')
      ..writeln('- win-probability computation block: active')
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
      ..writeln('## Next Recommended Phase')
      ..writeln(nextRecommendedPhase.wire)
      ..writeln()
      ..writeln(
        'This matrix analyzes internal evidence-area coverage only. It does '
        'not judge move quality, emit user-facing output, compute product '
        'metrics, call the engine, run Android, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    final payload = <String, Object?>{
      'version': internalEvidenceAreaCoverageMatrixReportVersion,
      'matrixStatus': status.wire,
      'harnessStatus': harnessStatus.wire,
      'guardStatus': guardStatus.wire,
      'guardAllowed': guardAllowed,
      'areaCount': areaCount,
      'areas': entries.map((entry) => entry.toJson()).toList(),
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
      'productOutputEmitted': productOutputEmitted,
      'classifierLabelsEmitted': classifierLabelsEmitted,
      'officialMetricsEmitted': officialMetricsEmitted,
      'cpLossComputed': cpLossComputed,
      'winProbabilityComputed': winProbabilityComputed,
      'directEngineAccessUsed': directEngineAccessUsed,
      'uiOutputUsed': uiOutputUsed,
      'backendOutputUsed': backendOutputUsed,
      'persistenceUsed': persistenceUsed,
      'emittedOutputFamilies': emittedOutputFamilies,
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}

class InternalEvidenceAreaCoverageMatrix {
  const InternalEvidenceAreaCoverageMatrix({
    this.validator = const InternalEvidenceAreaCoverageMatrixValidator(),
  });

  final InternalEvidenceAreaCoverageMatrixValidator validator;

  InternalEvidenceAreaCoverageMatrixResult evaluate(
    InternalEvidenceAreaCoverageMatrixRequest request,
  ) {
    final harnessResult =
        request.harnessResult ?? request.harness.run(request.harnessRequest);
    if (!harnessResult.allowed) {
      return _blockedByHarnessResult(harnessResult);
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

    final entries = _buildEntries(
      harnessResult: harnessResult,
      buckets: buckets,
      contract: contract,
      review: review,
      androidProofEvidence: request.androidProofEvidence,
    );
    final base = InternalEvidenceAreaCoverageMatrixResult(
      status: InternalEvidenceAreaCoverageMatrixStatus.readyInternalOnly,
      harnessStatus: harnessResult.status,
      guardStatus: harnessResult.guardStatus,
      guardAllowed: harnessResult.guardAllowed,
      areaCount: entries.length,
      entries: entries,
      validationFindings:
          const <InternalEvidenceAreaCoverageValidationFinding>[],
      warnings: _sortedStrings(<String>[
        ...harnessResult.warnings,
        ...harnessResult.partialWarnings,
      ]),
      failures: harnessResult.failures,
      nextRecommendedPhase:
          InternalEvidenceAreaCoverageNextPhase.internalNonLabelScoringDesign,
      provenAndroidCaseIds: harnessResult.androidProofCaseIds,
      unprovenAndroidCaseIds: harnessResult.unprovenAndroidCaseIds,
      excludedScopeIds: harnessResult.excludedScopeIds,
      productOutputEmitted: harnessResult.productOutputEmitted,
      classifierLabelsEmitted: harnessResult.classifierLabelsEmitted,
      officialMetricsEmitted: harnessResult.officialMetricsEmitted,
      cpLossComputed: harnessResult.cpLossComputed,
      winProbabilityComputed: harnessResult.winProbabilityComputed,
      directEngineAccessUsed: harnessResult.directEngineAccessUsed,
      uiOutputUsed: harnessResult.uiOutputUsed,
      backendOutputUsed: harnessResult.backendOutputUsed,
      persistenceUsed: harnessResult.persistenceUsed,
    );
    final findings = validator.validate(base);
    final status = _matrixStatusFor(base, findings);
    return base.copyWith(
      status: status,
      validationFindings: findings,
      nextRecommendedPhase: findings.any((finding) => finding.isError)
          ? InternalEvidenceAreaCoverageNextPhase.coverageEvidenceFixes
          : InternalEvidenceAreaCoverageNextPhase.internalNonLabelScoringDesign,
    );
  }
}

class InternalEvidenceAreaCoverageMatrixValidator {
  const InternalEvidenceAreaCoverageMatrixValidator();

  List<InternalEvidenceAreaCoverageValidationFinding> validate(
    InternalEvidenceAreaCoverageMatrixResult result,
  ) {
    final findings = <InternalEvidenceAreaCoverageValidationFinding>[];

    void error({
      required String id,
      required String message,
      InternalEvidenceAreaId? areaId,
      String? caseId,
    }) {
      findings.add(
        InternalEvidenceAreaCoverageValidationFinding(
          id: id,
          severity: InternalEvidenceAreaCoverageValidationSeverity.error,
          message: message,
          areaId: areaId,
          caseId: caseId,
        ),
      );
    }

    for (final entry in result.entries) {
      if ((entry.status == InternalEvidenceAreaCoverageStatus.strong ||
              entry.status == InternalEvidenceAreaCoverageStatus.adequate) &&
          entry.supportCaseIds.isEmpty) {
        error(
          id: 'supportedAreaWithoutCases',
          message:
              '${entry.areaId.wire} cannot be ${entry.status.wire} '
              'without support cases',
          areaId: entry.areaId,
        );
      }
      if (entry.isUnsafeIfActive) {
        error(
          id: 'areaBecameUnsafeOutput',
          message: '${entry.areaId.wire} cannot become active output',
          areaId: entry.areaId,
        );
      }
      if (entry.isActive && entry.isClassifierLabel) {
        error(
          id: 'areaBecameClassifierLabel',
          message: '${entry.areaId.wire} cannot become a classifier label',
          areaId: entry.areaId,
        );
      }
    }

    final android = _entryOrNull(
      result.entries,
      InternalEvidenceAreaId.androidProofBackedArea,
    );
    if (android != null) {
      final proven = android.androidProofCaseIds.toSet();
      for (final caseId in android.supportCaseIds) {
        if (!proven.contains(caseId)) {
          error(
            id: 'unprovenAndroidProofAreaCase',
            message: 'androidProofBackedArea cannot cite unproven cases',
            areaId: android.areaId,
            caseId: caseId,
          );
        }
      }
    }

    final quiet = _entryOrNull(
      result.entries,
      InternalEvidenceAreaId.quietPreparatoryExcludedArea,
    );
    if (quiet != null &&
        quiet.status != InternalEvidenceAreaCoverageStatus.excluded) {
      error(
        id: 'quietAreaNotExcluded',
        message: 'quiet/preparatory area must remain excluded',
        areaId: quiet.areaId,
      );
    }

    for (final id in const <InternalEvidenceAreaId>[
      InternalEvidenceAreaId.productLabelOutputBlockedArea,
      InternalEvidenceAreaId.advancedLabelGateBlockedArea,
      InternalEvidenceAreaId.officialMetricsBlockedArea,
    ]) {
      final entry = _entryOrNull(result.entries, id);
      if (entry != null &&
          entry.status != InternalEvidenceAreaCoverageStatus.blockedByPolicy) {
        error(
          id: 'policyAreaNotBlocked',
          message: '${id.wire} must remain blocked by policy',
          areaId: id,
        );
      }
    }

    for (final id in const <InternalEvidenceAreaId>[
      InternalEvidenceAreaId.cpLossComputationBlockedArea,
      InternalEvidenceAreaId.winProbabilityComputationBlockedArea,
    ]) {
      final entry = _entryOrNull(result.entries, id);
      if (entry != null &&
          (entry.status == InternalEvidenceAreaCoverageStatus.strong ||
              entry.status == InternalEvidenceAreaCoverageStatus.adequate ||
              entry.status == InternalEvidenceAreaCoverageStatus.partial ||
              entry.cpLossComputationImplemented ||
              entry.winProbabilityComputationImplemented)) {
        error(
          id: 'futureComputationMarkedImplemented',
          message: '${id.wire} must not be implemented in this phase',
          areaId: id,
        );
      }
    }

    if (result.productOutputEmitted ||
        result.classifierLabelsEmitted ||
        result.officialMetricsEmitted ||
        result.cpLossComputed ||
        result.winProbabilityComputed ||
        result.directEngineAccessUsed ||
        result.uiOutputUsed ||
        result.backendOutputUsed ||
        result.persistenceUsed) {
      error(
        id: 'matrixOutputPolicyViolation',
        message: 'matrix result crossed a blocked boundary',
      );
    }

    for (final output in result.emittedOutputFamilies) {
      if (_isForbiddenEmittedOutput(output)) {
        error(
          id: 'forbiddenOutputEmitted',
          message: 'forbidden output family emitted: $output',
        );
      }
    }

    for (final caseId in result.unprovenAndroidCaseIds) {
      error(
        id: 'unprovenAndroidProofCitation',
        message: 'unproven Android proof citation is blocked',
        areaId: InternalEvidenceAreaId.androidProofBackedArea,
        caseId: caseId,
      );
    }

    return findings..sort(_compareValidationFindings);
  }
}

InternalEvidenceAreaCoverageMatrixResult _blockedByHarnessResult(
  InternalBucketExperimentHarnessResult harnessResult,
) {
  return InternalEvidenceAreaCoverageMatrixResult(
    status: InternalEvidenceAreaCoverageMatrixStatus.blockedByHarness,
    harnessStatus: harnessResult.status,
    guardStatus: harnessResult.guardStatus,
    guardAllowed: harnessResult.guardAllowed,
    areaCount: 0,
    entries: const <InternalEvidenceAreaCoverageEntry>[],
    validationFindings: const <InternalEvidenceAreaCoverageValidationFinding>[],
    warnings: harnessResult.warnings,
    failures: _sortedStrings(<String>[
      ...harnessResult.failures,
      'harness did not complete an internal-only run',
    ]),
    nextRecommendedPhase:
        InternalEvidenceAreaCoverageNextPhase.coverageEvidenceFixes,
    provenAndroidCaseIds: harnessResult.androidProofCaseIds,
    unprovenAndroidCaseIds: harnessResult.unprovenAndroidCaseIds,
    excludedScopeIds: harnessResult.excludedScopeIds,
    productOutputEmitted: harnessResult.productOutputEmitted,
    classifierLabelsEmitted: harnessResult.classifierLabelsEmitted,
    officialMetricsEmitted: harnessResult.officialMetricsEmitted,
    cpLossComputed: harnessResult.cpLossComputed,
    winProbabilityComputed: harnessResult.winProbabilityComputed,
    directEngineAccessUsed: harnessResult.directEngineAccessUsed,
    uiOutputUsed: harnessResult.uiOutputUsed,
    backendOutputUsed: harnessResult.backendOutputUsed,
    persistenceUsed: harnessResult.persistenceUsed,
  );
}

List<InternalEvidenceAreaCoverageEntry> _buildEntries({
  required InternalBucketExperimentHarnessResult harnessResult,
  required InternalEvidenceBucketPrototype buckets,
  required BasicClassifierEvidenceContractPrototype contract,
  required GoldenEvidenceReviewResult review,
  required GoldenAndroidProofEvidence? androidProofEvidence,
}) {
  final protectedCaseIds = review.caseReviews
      .where((entry) => entry.passedLike)
      .map((entry) => entry.caseId)
      .toSet();
  final reviewById = <String, GoldenEvidenceCaseReview>{
    for (final entry in review.caseReviews) entry.caseId: entry,
  };
  final observationsByBucket =
      <InternalEvidenceBucketId, InternalBucketExperimentObservation>{
        for (final observation in [
          ...harnessResult.observations,
          ...harnessResult.inactiveObservations,
        ])
          observation.bucketId: observation,
      };
  final provenAndroidIds = <String>{
    ...harnessResult.androidProofCaseIds,
    ...buckets.capturedAndroidProofCaseIds,
  };

  final entries = <InternalEvidenceAreaCoverageEntry>[];
  for (final definition in _areaDefinitions) {
    entries.add(
      _entryFor(
        definition: definition,
        buckets: buckets,
        contract: contract,
        reviewById: reviewById,
        protectedCaseIds: protectedCaseIds,
        observationsByBucket: observationsByBucket,
        provenAndroidIds: provenAndroidIds,
        androidProofEvidence: androidProofEvidence,
      ),
    );
  }
  return List<InternalEvidenceAreaCoverageEntry>.unmodifiable(
    entries..sort((a, b) => a.areaId.index.compareTo(b.areaId.index)),
  );
}

InternalEvidenceAreaCoverageEntry _entryFor({
  required _AreaDefinition definition,
  required InternalEvidenceBucketPrototype buckets,
  required BasicClassifierEvidenceContractPrototype contract,
  required Map<String, GoldenEvidenceCaseReview> reviewById,
  required Set<String> protectedCaseIds,
  required Map<InternalEvidenceBucketId, InternalBucketExperimentObservation>
  observationsByBucket,
  required Set<String> provenAndroidIds,
  required GoldenAndroidProofEvidence? androidProofEvidence,
}) {
  final supportCaseIds = <String>{};
  final androidProofCaseIds = <String>{};
  final warnings = <String>{};
  final blockers = <String>{};
  final bucketStatuses = <InternalEvidenceBucketStatus>[];

  for (final bucketId in definition.bucketIds) {
    final bucket = buckets.bucket(bucketId);
    final observation = observationsByBucket[bucketId];
    bucketStatuses.add(bucket.status);
    final observedOrInactiveSupport =
        observation?.supportCaseIds ?? bucket.supportingCaseIds;
    supportCaseIds.addAll(observedOrInactiveSupport);
    if (observation?.warningReason != null) {
      warnings.add('${bucketId.wire}: ${observation!.warningReason}');
    }
    if (observation?.blockedReason != null) {
      blockers.add('${bucketId.wire}: ${observation!.blockedReason}');
    }
    blockers.addAll(bucket.blockers);
  }

  final protectedSupportCaseIds = supportCaseIds
      .where(protectedCaseIds.contains)
      .toSet();
  for (final caseId in supportCaseIds) {
    if (provenAndroidIds.contains(caseId) &&
        _proofStillValid(androidProofEvidence, caseId)) {
      androidProofCaseIds.add(caseId);
    }
  }

  final futureOnlyFieldCount = definition.fields.where((field) {
    final status = contract.field(field).status;
    return status == BasicClassifierEvidenceFieldStatus.futureOnly ||
        status == BasicClassifierEvidenceFieldStatus.notImplemented;
  }).length;
  final blockedPolicyCount = definition.fields
      .where(
        (field) =>
            contract.field(field).status ==
            BasicClassifierEvidenceFieldStatus.blockedByPolicy,
      )
      .length;
  final motifCoverageSupport = supportCaseIds
      .where(
        (caseId) =>
            reviewById[caseId]?.satisfiedMotifEvidenceGroups.any(
              definition.motifGroups.contains,
            ) ??
            false,
      )
      .length;
  final suppressionSupport = supportCaseIds
      .where(
        (caseId) =>
            (reviewById[caseId]?.expectedSuppressionsSatisfied.isNotEmpty ??
                false) ||
            (reviewById[caseId]?.satisfiedMotifEvidenceGroups.contains(
                  GoldenMotifEvidenceGroup.suppression,
                ) ??
                false) ||
            (reviewById[caseId]?.satisfiedMotifEvidenceGroups.contains(
                  GoldenMotifEvidenceGroup.budget,
                ) ??
                false),
      )
      .length;
  final bucketStatusSupport = _bucketStatusSupport(bucketStatuses);
  if (definition.warnWhenSingleSupport && supportCaseIds.length == 1) {
    warnings.add('single supporting case; add coverage before wider use');
  }
  final status = _coverageStatusFor(
    definition: definition,
    supportCaseCount: supportCaseIds.length,
    protectedSupportCaseCount: protectedSupportCaseIds.length,
    androidProofCaseCount: androidProofCaseIds.length,
    bucketStatusSupport: bucketStatusSupport,
    suppressionSupport: suppressionSupport,
    futureOnlyFieldCount: futureOnlyFieldCount,
    blockedPolicyCount: blockedPolicyCount,
  );
  final recommendation = _recommendationFor(
    definition: definition,
    status: status,
    supportCaseCount: supportCaseIds.length,
    androidProofCaseCount: androidProofCaseIds.length,
  );
  return InternalEvidenceAreaCoverageEntry(
    areaId: definition.id,
    status: status,
    supportCaseIds: _sortedStrings(supportCaseIds),
    protectedSupportCaseIds: _sortedStrings(protectedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(androidProofCaseIds),
    relatedBucketIds: List<InternalEvidenceBucketId>.unmodifiable(
      definition.bucketIds,
    ),
    relatedContractFields: List<BasicClassifierContractField>.unmodifiable(
      definition.fields,
    ),
    supportCaseCount: supportCaseIds.length,
    protectedSupportCaseCount: protectedSupportCaseIds.length,
    androidProofCaseCount: androidProofCaseIds.length,
    bucketStatusSupport: bucketStatusSupport,
    motifCoverageSupport: motifCoverageSupport,
    suppressionSupport: suppressionSupport,
    negativeGuardExclusion: definition.negativeGuardExclusion,
    futureOnlyFieldCount: futureOnlyFieldCount,
    blockedPolicyCount: blockedPolicyCount,
    warningCount: warnings.length,
    warnings: _sortedStrings(warnings),
    blockers: _sortedStrings(blockers),
    recommendation: recommendation,
    isQuietScope: definition.quietScope,
  );
}

InternalEvidenceAreaCoverageStatus _coverageStatusFor({
  required _AreaDefinition definition,
  required int supportCaseCount,
  required int protectedSupportCaseCount,
  required int androidProofCaseCount,
  required int bucketStatusSupport,
  required int suppressionSupport,
  required int futureOnlyFieldCount,
  required int blockedPolicyCount,
}) {
  if (definition.fixedStatus != null) return definition.fixedStatus!;
  if (definition.id == InternalEvidenceAreaId.androidProofBackedArea) {
    return androidProofCaseCount >= 3
        ? InternalEvidenceAreaCoverageStatus.adequate
        : InternalEvidenceAreaCoverageStatus.partial;
  }
  if (definition.id == InternalEvidenceAreaId.pvMultiPvArea) {
    return androidProofCaseCount == supportCaseCount && supportCaseCount >= 3
        ? InternalEvidenceAreaCoverageStatus.adequate
        : InternalEvidenceAreaCoverageStatus.partial;
  }
  if (bucketStatusSupport == 0 || supportCaseCount == 0) {
    return InternalEvidenceAreaCoverageStatus.weak;
  }
  if (definition.id == InternalEvidenceAreaId.tacticalArea &&
      protectedSupportCaseCount >= 4) {
    return InternalEvidenceAreaCoverageStatus.strong;
  }
  if (definition.id == InternalEvidenceAreaId.safetySuppressionArea &&
      suppressionSupport >= 4) {
    return InternalEvidenceAreaCoverageStatus.strong;
  }
  if (definition.warnWhenSingleSupport && supportCaseCount <= 1) {
    return InternalEvidenceAreaCoverageStatus.partial;
  }
  if (supportCaseCount >= definition.adequateSupportThreshold) {
    return InternalEvidenceAreaCoverageStatus.adequate;
  }
  return InternalEvidenceAreaCoverageStatus.partial;
}

InternalEvidenceAreaGapRecommendation _recommendationFor({
  required _AreaDefinition definition,
  required InternalEvidenceAreaCoverageStatus status,
  required int supportCaseCount,
  required int androidProofCaseCount,
}) {
  if (definition.fixedRecommendation != null) {
    return definition.fixedRecommendation!;
  }
  if (definition.id == InternalEvidenceAreaId.androidProofBackedArea) {
    return androidProofCaseCount >= 3
        ? InternalEvidenceAreaGapRecommendation.keepStable
        : InternalEvidenceAreaGapRecommendation
              .addOwnerAndroidProofOnlyIfPvRequired;
  }
  if (status == InternalEvidenceAreaCoverageStatus.strong ||
      status == InternalEvidenceAreaCoverageStatus.adequate) {
    return InternalEvidenceAreaGapRecommendation.keepStable;
  }
  if (supportCaseCount == 0) {
    return InternalEvidenceAreaGapRecommendation.addHandcraftedCase;
  }
  if (definition.warnWhenSingleSupport) {
    return InternalEvidenceAreaGapRecommendation.addHandcraftedCase;
  }
  return InternalEvidenceAreaGapRecommendation.addFakeEvidence;
}

InternalEvidenceAreaCoverageMatrixStatus _matrixStatusFor(
  InternalEvidenceAreaCoverageMatrixResult result,
  List<InternalEvidenceAreaCoverageValidationFinding> findings,
) {
  if (findings.any((finding) => finding.isError)) {
    return InternalEvidenceAreaCoverageMatrixStatus.blockedByValidation;
  }
  if (result.hasWarnings ||
      result.entries.any(
        (entry) => entry.status == InternalEvidenceAreaCoverageStatus.partial,
      )) {
    return InternalEvidenceAreaCoverageMatrixStatus.readyWithWarnings;
  }
  return InternalEvidenceAreaCoverageMatrixStatus.readyInternalOnly;
}

int _bucketStatusSupport(List<InternalEvidenceBucketStatus> statuses) {
  if (statuses.isEmpty) return 0;
  if (statuses.every(
    (status) => status == InternalEvidenceBucketStatus.supported,
  )) {
    return 2;
  }
  if (statuses.any(
    (status) => status == InternalEvidenceBucketStatus.partial,
  )) {
    return 1;
  }
  return 0;
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

InternalEvidenceAreaCoverageEntry? _entryOrNull(
  List<InternalEvidenceAreaCoverageEntry> entries,
  InternalEvidenceAreaId id,
) {
  for (final entry in entries) {
    if (entry.areaId == id) return entry;
  }
  return null;
}

int _compareValidationFindings(
  InternalEvidenceAreaCoverageValidationFinding a,
  InternalEvidenceAreaCoverageValidationFinding b,
) {
  final idCompare = a.id.compareTo(b.id);
  if (idCompare != 0) return idCompare;
  final areaCompare = (a.areaId?.wire ?? '').compareTo(b.areaId?.wire ?? '');
  if (areaCompare != 0) return areaCompare;
  return (a.caseId ?? '').compareTo(b.caseId ?? '');
}

String _ids(Iterable<String> values) {
  final sorted = _sortedStrings(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

String _bucketIds(List<InternalEvidenceBucketId> values) {
  return values.isEmpty ? '-' : values.map((value) => value.wire).join(', ');
}

String _areaIds(Iterable<InternalEvidenceAreaCoverageEntry> entries) {
  final ids = entries.map((entry) => entry.areaId.wire).toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.toList()..sort();
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
      normalized.contains('acpl');
}

class _AreaDefinition {
  const _AreaDefinition({
    required this.id,
    required this.bucketIds,
    required this.fields,
    required this.motifGroups,
    this.adequateSupportThreshold = 2,
    this.warnWhenSingleSupport = false,
    this.negativeGuardExclusion = false,
    this.quietScope = false,
    this.fixedStatus,
    this.fixedRecommendation,
  });

  final InternalEvidenceAreaId id;
  final List<InternalEvidenceBucketId> bucketIds;
  final List<BasicClassifierContractField> fields;
  final List<GoldenMotifEvidenceGroup> motifGroups;
  final int adequateSupportThreshold;
  final bool warnWhenSingleSupport;
  final bool negativeGuardExclusion;
  final bool quietScope;
  final InternalEvidenceAreaCoverageStatus? fixedStatus;
  final InternalEvidenceAreaGapRecommendation? fixedRecommendation;
}

const _areaDefinitions = <_AreaDefinition>[
  _AreaDefinition(
    id: InternalEvidenceAreaId.tacticalArea,
    bucketIds: <InternalEvidenceBucketId>[
      InternalEvidenceBucketId.tacticalSupported,
    ],
    fields: <BasicClassifierContractField>[
      BasicClassifierContractField.tacticalSignalAvailable,
      BasicClassifierContractField.captureOrPromotionAvailable,
      BasicClassifierContractField.givesCheckAvailable,
      BasicClassifierContractField.candidateSpreadSignalAvailable,
      BasicClassifierContractField.mateSignalAvailable,
    ],
    motifGroups: <GoldenMotifEvidenceGroup>[
      GoldenMotifEvidenceGroup.tactical,
      GoldenMotifEvidenceGroup.forcing,
    ],
    adequateSupportThreshold: 3,
  ),
  _AreaDefinition(
    id: InternalEvidenceAreaId.materialSwingArea,
    bucketIds: <InternalEvidenceBucketId>[
      InternalEvidenceBucketId.materialSwingSupported,
    ],
    fields: <BasicClassifierContractField>[
      BasicClassifierContractField.materialSwingAvailable,
      BasicClassifierContractField.majorEvalSwingAvailable,
      BasicClassifierContractField.queenWinEvidenceAvailable,
      BasicClassifierContractField.sacrificeCompensationAvailable,
    ],
    motifGroups: <GoldenMotifEvidenceGroup>[GoldenMotifEvidenceGroup.material],
  ),
  _AreaDefinition(
    id: InternalEvidenceAreaId.forcingLineArea,
    bucketIds: <InternalEvidenceBucketId>[
      InternalEvidenceBucketId.forcingLineSupported,
    ],
    fields: <BasicClassifierContractField>[
      BasicClassifierContractField.forcingLineSignalAvailable,
      BasicClassifierContractField.candidateSpreadSignalAvailable,
    ],
    motifGroups: <GoldenMotifEvidenceGroup>[GoldenMotifEvidenceGroup.forcing],
  ),
  _AreaDefinition(
    id: InternalEvidenceAreaId.kingSafetyArea,
    bucketIds: <InternalEvidenceBucketId>[
      InternalEvidenceBucketId.kingSafetySupported,
    ],
    fields: <BasicClassifierContractField>[
      BasicClassifierContractField.kingSafetySignalAvailable,
      BasicClassifierContractField.exposedKingSignalAvailable,
      BasicClassifierContractField.matingNetSignalAvailable,
      BasicClassifierContractField.kingHuntSignalAvailable,
      BasicClassifierContractField.mateSignalAvailable,
    ],
    motifGroups: <GoldenMotifEvidenceGroup>[
      GoldenMotifEvidenceGroup.kingSafety,
    ],
  ),
  _AreaDefinition(
    id: InternalEvidenceAreaId.conservativeEndgameArea,
    bucketIds: <InternalEvidenceBucketId>[
      InternalEvidenceBucketId.endgameConservativeSupported,
    ],
    fields: <BasicClassifierContractField>[
      BasicClassifierContractField.candidateSpreadAvailable,
    ],
    motifGroups: <GoldenMotifEvidenceGroup>[
      GoldenMotifEvidenceGroup.positional,
    ],
  ),
  _AreaDefinition(
    id: InternalEvidenceAreaId.safetySuppressionArea,
    bucketIds: <InternalEvidenceBucketId>[
      InternalEvidenceBucketId.safetySuppressionSupported,
      InternalEvidenceBucketId.invalidFenSuppressed,
      InternalEvidenceBucketId.openingSuppressed,
      InternalEvidenceBucketId.forcedMoveSuppressed,
      InternalEvidenceBucketId.budgetPressureVisible,
    ],
    fields: <BasicClassifierContractField>[
      BasicClassifierContractField.invalidFenSuppressionAvailable,
      BasicClassifierContractField.openingSuppressionAvailable,
      BasicClassifierContractField.forcedMoveSuppressionAvailable,
      BasicClassifierContractField.budgetPressureAvailable,
      BasicClassifierContractField.negativeGuardScopeExcluded,
    ],
    motifGroups: <GoldenMotifEvidenceGroup>[
      GoldenMotifEvidenceGroup.suppression,
      GoldenMotifEvidenceGroup.budget,
    ],
    adequateSupportThreshold: 4,
  ),
  _AreaDefinition(
    id: InternalEvidenceAreaId.androidProofBackedArea,
    bucketIds: <InternalEvidenceBucketId>[
      InternalEvidenceBucketId.androidProofBacked,
    ],
    fields: <BasicClassifierContractField>[
      BasicClassifierContractField.pvAvailable,
      BasicClassifierContractField.multiPvAvailable,
    ],
    motifGroups: <GoldenMotifEvidenceGroup>[
      GoldenMotifEvidenceGroup.realDeviceProof,
    ],
    adequateSupportThreshold: 3,
  ),
  _AreaDefinition(
    id: InternalEvidenceAreaId.candidateSpreadArea,
    bucketIds: <InternalEvidenceBucketId>[
      InternalEvidenceBucketId.candidateSpreadSupported,
    ],
    fields: <BasicClassifierContractField>[
      BasicClassifierContractField.candidateSpreadAvailable,
      BasicClassifierContractField.candidateSpreadSignalAvailable,
    ],
    motifGroups: <GoldenMotifEvidenceGroup>[
      GoldenMotifEvidenceGroup.tactical,
      GoldenMotifEvidenceGroup.forcing,
    ],
    adequateSupportThreshold: 3,
  ),
  _AreaDefinition(
    id: InternalEvidenceAreaId.pvMultiPvArea,
    bucketIds: <InternalEvidenceBucketId>[
      InternalEvidenceBucketId.pvMultiPvSupported,
    ],
    fields: <BasicClassifierContractField>[
      BasicClassifierContractField.pvAvailable,
      BasicClassifierContractField.multiPvAvailable,
    ],
    motifGroups: <GoldenMotifEvidenceGroup>[
      GoldenMotifEvidenceGroup.realDeviceProof,
    ],
    adequateSupportThreshold: 3,
  ),
  _AreaDefinition(
    id: InternalEvidenceAreaId.budgetPressureArea,
    bucketIds: <InternalEvidenceBucketId>[
      InternalEvidenceBucketId.budgetPressureVisible,
    ],
    fields: <BasicClassifierContractField>[
      BasicClassifierContractField.budgetPressureAvailable,
    ],
    motifGroups: <GoldenMotifEvidenceGroup>[GoldenMotifEvidenceGroup.budget],
    warnWhenSingleSupport: true,
  ),
  _AreaDefinition(
    id: InternalEvidenceAreaId.openingSuppressionArea,
    bucketIds: <InternalEvidenceBucketId>[
      InternalEvidenceBucketId.openingSuppressed,
    ],
    fields: <BasicClassifierContractField>[
      BasicClassifierContractField.openingSuppressionAvailable,
    ],
    motifGroups: <GoldenMotifEvidenceGroup>[
      GoldenMotifEvidenceGroup.suppression,
    ],
    warnWhenSingleSupport: true,
  ),
  _AreaDefinition(
    id: InternalEvidenceAreaId.forcedMoveSuppressionArea,
    bucketIds: <InternalEvidenceBucketId>[
      InternalEvidenceBucketId.forcedMoveSuppressed,
    ],
    fields: <BasicClassifierContractField>[
      BasicClassifierContractField.forcedMoveSuppressionAvailable,
    ],
    motifGroups: <GoldenMotifEvidenceGroup>[
      GoldenMotifEvidenceGroup.suppression,
    ],
    warnWhenSingleSupport: true,
  ),
  _AreaDefinition(
    id: InternalEvidenceAreaId.invalidFenSuppressionArea,
    bucketIds: <InternalEvidenceBucketId>[
      InternalEvidenceBucketId.invalidFenSuppressed,
    ],
    fields: <BasicClassifierContractField>[
      BasicClassifierContractField.invalidFenSuppressionAvailable,
    ],
    motifGroups: <GoldenMotifEvidenceGroup>[
      GoldenMotifEvidenceGroup.suppression,
    ],
    warnWhenSingleSupport: true,
  ),
  _AreaDefinition(
    id: InternalEvidenceAreaId.quietPreparatoryExcludedArea,
    bucketIds: <InternalEvidenceBucketId>[
      InternalEvidenceBucketId.quietPreparatoryExcluded,
    ],
    fields: <BasicClassifierContractField>[
      BasicClassifierContractField.negativeGuardScopeExcluded,
    ],
    motifGroups: <GoldenMotifEvidenceGroup>[
      GoldenMotifEvidenceGroup.uncertainty,
    ],
    negativeGuardExclusion: true,
    quietScope: true,
    fixedStatus: InternalEvidenceAreaCoverageStatus.excluded,
    fixedRecommendation:
        InternalEvidenceAreaGapRecommendation.keepExcludedByNegativeGuard,
  ),
  _AreaDefinition(
    id: InternalEvidenceAreaId.productLabelOutputBlockedArea,
    bucketIds: <InternalEvidenceBucketId>[
      InternalEvidenceBucketId.productLabelOutputBlocked,
    ],
    fields: <BasicClassifierContractField>[
      BasicClassifierContractField.productLabelOutputAvailable,
    ],
    motifGroups: <GoldenMotifEvidenceGroup>[],
    fixedStatus: InternalEvidenceAreaCoverageStatus.blockedByPolicy,
    fixedRecommendation:
        InternalEvidenceAreaGapRecommendation.keepBlockedByPolicy,
  ),
  _AreaDefinition(
    id: InternalEvidenceAreaId.advancedLabelGateBlockedArea,
    bucketIds: <InternalEvidenceBucketId>[
      InternalEvidenceBucketId.advancedLabelGateBlocked,
    ],
    fields: <BasicClassifierContractField>[],
    motifGroups: <GoldenMotifEvidenceGroup>[],
    fixedStatus: InternalEvidenceAreaCoverageStatus.blockedByPolicy,
    fixedRecommendation:
        InternalEvidenceAreaGapRecommendation.keepBlockedByPolicy,
  ),
  _AreaDefinition(
    id: InternalEvidenceAreaId.officialMetricsBlockedArea,
    bucketIds: <InternalEvidenceBucketId>[
      InternalEvidenceBucketId.officialMetricsBlocked,
    ],
    fields: <BasicClassifierContractField>[
      BasicClassifierContractField.officialAccuracyAvailable,
      BasicClassifierContractField.officialAcplAvailable,
    ],
    motifGroups: <GoldenMotifEvidenceGroup>[],
    fixedStatus: InternalEvidenceAreaCoverageStatus.blockedByPolicy,
    fixedRecommendation:
        InternalEvidenceAreaGapRecommendation.keepBlockedByPolicy,
  ),
  _AreaDefinition(
    id: InternalEvidenceAreaId.cpLossComputationBlockedArea,
    bucketIds: <InternalEvidenceBucketId>[
      InternalEvidenceBucketId.cpLossComputationBlocked,
    ],
    fields: <BasicClassifierContractField>[
      BasicClassifierContractField.cpLossAvailable,
    ],
    motifGroups: <GoldenMotifEvidenceGroup>[],
    fixedStatus: InternalEvidenceAreaCoverageStatus.futureOnly,
    fixedRecommendation:
        InternalEvidenceAreaGapRecommendation.futureProductInputOnly,
  ),
  _AreaDefinition(
    id: InternalEvidenceAreaId.winProbabilityComputationBlockedArea,
    bucketIds: <InternalEvidenceBucketId>[
      InternalEvidenceBucketId.winProbabilityComputationBlocked,
    ],
    fields: <BasicClassifierContractField>[
      BasicClassifierContractField.winProbabilityAvailable,
    ],
    motifGroups: <GoldenMotifEvidenceGroup>[],
    fixedStatus: InternalEvidenceAreaCoverageStatus.futureOnly,
    fixedRecommendation:
        InternalEvidenceAreaGapRecommendation.futureProductInputOnly,
  ),
];

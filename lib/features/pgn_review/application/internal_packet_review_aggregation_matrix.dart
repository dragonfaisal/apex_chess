/// Developer-only review and aggregation matrix for Phase 32A packets.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_observation_review_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/narrow_internal_non_label_analysis_prototype.dart';

const internalPacketReviewAggregationMatrixReportVersion =
    'internal-packet-review-aggregation-matrix-v1';

enum InternalPacketReviewAggregationMatrixStatus {
  readyInternalOnly('readyInternalOnly'),
  readyWithWarnings('readyWithWarnings'),
  blockedByPrototype('blockedByPrototype'),
  blockedByValidation('blockedByValidation'),
  unsafe('unsafe'),
  invalid('invalid');

  const InternalPacketReviewAggregationMatrixStatus(this.wire);

  final String wire;
}

enum InternalPacketReviewStatus {
  stable('stable'),
  stableNarrow('stableNarrow'),
  stableWithWarnings('stableWithWarnings'),
  needsMoreGoldenCoverage('needsMoreGoldenCoverage'),
  proofLimited('proofLimited'),
  warningOnly('warningOnly'),
  blockedCorrectly('blockedCorrectly'),
  futureOnlyCorrectly('futureOnlyCorrectly'),
  unsafe('unsafe'),
  invalid('invalid');

  const InternalPacketReviewStatus(this.wire);

  final String wire;

  bool get isStablePacket =>
      this == InternalPacketReviewStatus.stable ||
      this == InternalPacketReviewStatus.stableNarrow ||
      this == InternalPacketReviewStatus.stableWithWarnings ||
      this == InternalPacketReviewStatus.proofLimited;

  bool get isUnsafe =>
      this == InternalPacketReviewStatus.unsafe ||
      this == InternalPacketReviewStatus.invalid;
}

enum InternalPacketSupportBreadth {
  broadGoldenSupport('broadGoldenSupport'),
  narrowGoldenSupport('narrowGoldenSupport'),
  thinGoldenSupport('thinGoldenSupport'),
  proofLimitedSupport('proofLimitedSupport'),
  warningOnlySupport('warningOnlySupport'),
  blockedBoundary('blockedBoundary'),
  futureOnlyBoundary('futureOnlyBoundary'),
  none('none');

  const InternalPacketSupportBreadth(this.wire);

  final String wire;
}

enum InternalPacketReviewRecommendation {
  keepStable('keepStable'),
  keepStableButNarrow('keepStableButNarrow'),
  addGoldenCoverage('addGoldenCoverage'),
  keepProofLimited('keepProofLimited'),
  keepWarningLimited('keepWarningLimited'),
  keepBlockedByPolicy('keepBlockedByPolicy'),
  keepFutureOnly('keepFutureOnly'),
  investigateUnsafePacket('investigateUnsafePacket');

  const InternalPacketReviewRecommendation(this.wire);

  final String wire;
}

enum InternalPacketReviewPhase32CRecommendation {
  proceedToInternalPacketStabilityPrototype(
    'proceedToInternalPacketStabilityPrototype',
  ),
  addGoldenCoverageFirst('addGoldenCoverageFirst'),
  keepNarrowPrototypeOnly('keepNarrowPrototypeOnly'),
  blockedByUnsafePacket('blockedByUnsafePacket'),
  blockedByPolicyBoundary('blockedByPolicyBoundary');

  const InternalPacketReviewPhase32CRecommendation(this.wire);

  final String wire;
}

enum InternalPacketReviewValidationSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const InternalPacketReviewValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == InternalPacketReviewValidationSeverity.blocker ||
      this == InternalPacketReviewValidationSeverity.critical;
}

enum InternalPacketReviewAggregationMatrixReportFormat {
  markdown('markdown'),
  json('json');

  const InternalPacketReviewAggregationMatrixReportFormat(this.wire);

  final String wire;
}

class InternalPacketReviewAggregationMatrixRequest {
  const InternalPacketReviewAggregationMatrixRequest({
    this.prototypeResult,
    this.readinessResult,
    this.reviewResult,
    this.prototype = const NarrowInternalNonLabelAnalysisPrototype(),
    this.readinessGate = const InternalNonLabelPrototypeReadinessGate(),
    this.reviewMatrix = const InternalSignalObservationReviewMatrix(),
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.cases = GoldenAnalysisCases.defaults,
    this.includeWarningLimitedScopes = true,
    this.includeBlockedScopes = true,
    this.includeFutureOnlyScopes = true,
  });

  const InternalPacketReviewAggregationMatrixRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarningLimitedScopes: includeWarnings);

  final NarrowInternalNonLabelAnalysisPrototypeResult? prototypeResult;
  final InternalNonLabelPrototypeReadinessResult? readinessResult;
  final InternalSignalObservationReviewMatrixResult? reviewResult;
  final NarrowInternalNonLabelAnalysisPrototype prototype;
  final InternalNonLabelPrototypeReadinessGate readinessGate;
  final InternalSignalObservationReviewMatrix reviewMatrix;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final List<GoldenAnalysisCase> cases;
  final bool includeWarningLimitedScopes;
  final bool includeBlockedScopes;
  final bool includeFutureOnlyScopes;
}

class InternalPacketReviewAggregationRow {
  const InternalPacketReviewAggregationRow({
    required this.packetId,
    required this.allowedScopeId,
    required this.reviewStatus,
    required this.supportCaseIds,
    required this.androidProofCaseIds,
    required this.activeSignalIds,
    required this.evidenceAreaIds,
    required this.bucketIds,
    required this.qualitativeConfidence,
    required this.supportBreadth,
    required this.warningReasons,
    required this.coverageGapIds,
    required this.futurePrerequisites,
    required this.blockedBoundaryIds,
    required this.recommendation,
    this.isCorePacket = false,
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

  final String packetId;
  final InternalNonLabelPrototypeScopeId allowedScopeId;
  final InternalPacketReviewStatus reviewStatus;
  final List<String> supportCaseIds;
  final List<String> androidProofCaseIds;
  final List<InternalNonLabelSignalId> activeSignalIds;
  final List<InternalEvidenceAreaId> evidenceAreaIds;
  final List<InternalEvidenceBucketId> bucketIds;
  final InternalNonLabelSignalConfidence qualitativeConfidence;
  final InternalPacketSupportBreadth supportBreadth;
  final List<String> warningReasons;
  final List<String> coverageGapIds;
  final List<String> futurePrerequisites;
  final List<String> blockedBoundaryIds;
  final InternalPacketReviewRecommendation recommendation;
  final bool isCorePacket;
  final bool isProductOutput;
  final bool isClassifierLabel;
  final bool isOfficialMetric;
  final bool hasNumericScore;
  final bool ranksMoves;
  final bool quietScopeActive;
  final bool cpLossComputationImplemented;
  final bool winProbabilityComputationImplemented;
  final List<String> emittedOutputNames;

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

  bool get isWarningLimitedScope =>
      reviewStatus == InternalPacketReviewStatus.warningOnly;

  bool get isBlockedOrFutureOnly =>
      reviewStatus == InternalPacketReviewStatus.blockedCorrectly ||
      reviewStatus == InternalPacketReviewStatus.futureOnlyCorrectly;

  InternalPacketReviewAggregationRow copyWith({
    String? packetId,
    InternalNonLabelPrototypeScopeId? allowedScopeId,
    InternalPacketReviewStatus? reviewStatus,
    List<String>? supportCaseIds,
    List<String>? androidProofCaseIds,
    List<InternalNonLabelSignalId>? activeSignalIds,
    List<InternalEvidenceAreaId>? evidenceAreaIds,
    List<InternalEvidenceBucketId>? bucketIds,
    InternalNonLabelSignalConfidence? qualitativeConfidence,
    InternalPacketSupportBreadth? supportBreadth,
    List<String>? warningReasons,
    List<String>? coverageGapIds,
    List<String>? futurePrerequisites,
    List<String>? blockedBoundaryIds,
    InternalPacketReviewRecommendation? recommendation,
    bool? isCorePacket,
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
    return InternalPacketReviewAggregationRow(
      packetId: packetId ?? this.packetId,
      allowedScopeId: allowedScopeId ?? this.allowedScopeId,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      activeSignalIds: activeSignalIds ?? this.activeSignalIds,
      evidenceAreaIds: evidenceAreaIds ?? this.evidenceAreaIds,
      bucketIds: bucketIds ?? this.bucketIds,
      qualitativeConfidence:
          qualitativeConfidence ?? this.qualitativeConfidence,
      supportBreadth: supportBreadth ?? this.supportBreadth,
      warningReasons: warningReasons ?? this.warningReasons,
      coverageGapIds: coverageGapIds ?? this.coverageGapIds,
      futurePrerequisites: futurePrerequisites ?? this.futurePrerequisites,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      recommendation: recommendation ?? this.recommendation,
      isCorePacket: isCorePacket ?? this.isCorePacket,
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
      'packetId': packetId,
      'allowedScopeId': allowedScopeId.wire,
      'reviewStatus': reviewStatus.wire,
      'supportCaseIds': supportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'activeSignalIds': activeSignalIds.map((id) => id.wire).toList(),
      'evidenceAreaIds': evidenceAreaIds.map((id) => id.wire).toList(),
      'bucketIds': bucketIds.map((id) => id.wire).toList(),
      'qualitativeConfidence': qualitativeConfidence.wire,
      'supportBreadth': supportBreadth.wire,
      'warningReasons': warningReasons,
      'coverageGapIds': coverageGapIds,
      'futurePrerequisites': futurePrerequisites,
      'blockedBoundaryIds': blockedBoundaryIds,
      'recommendation': recommendation.wire,
      'isCorePacket': isCorePacket,
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

class InternalPacketReviewAggregationMatrixValidationFinding {
  const InternalPacketReviewAggregationMatrixValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.packetId,
    this.scopeId,
    this.signalId,
    this.caseId,
  });

  final String id;
  final InternalPacketReviewValidationSeverity severity;
  final String message;
  final String? packetId;
  final InternalNonLabelPrototypeScopeId? scopeId;
  final InternalNonLabelSignalId? signalId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical =>
      severity == InternalPacketReviewValidationSeverity.critical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (packetId != null) 'packetId': packetId,
      if (scopeId != null) 'scopeId': scopeId!.wire,
      if (signalId != null) 'signalId': signalId!.wire,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class InternalPacketReviewAggregationMatrixResult {
  const InternalPacketReviewAggregationMatrixResult({
    required this.matrixStatus,
    required this.prototypeStatus,
    required this.readinessStatus,
    required this.reviewMatrixStatus,
    required this.rows,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalPackets,
    required this.stablePacketCount,
    required this.stableNarrowPacketCount,
    required this.proofLimitedPacketCount,
    required this.warningLimitedScopeCount,
    required this.blockedScopeCount,
    required this.unsafePacketCount,
    required this.uniqueSupportCaseIds,
    required this.androidProofCaseIds,
    required this.coverageGapIds,
    required this.safeForPhase32C,
    required this.phase32CRecommendation,
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

  final InternalPacketReviewAggregationMatrixStatus matrixStatus;
  final NarrowInternalNonLabelAnalysisPrototypeStatus prototypeStatus;
  final InternalNonLabelPrototypeReadinessStatus readinessStatus;
  final InternalSignalObservationReviewMatrixStatus reviewMatrixStatus;
  final List<InternalPacketReviewAggregationRow> rows;
  final List<InternalPacketReviewAggregationMatrixValidationFinding>
  validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalPackets;
  final int stablePacketCount;
  final int stableNarrowPacketCount;
  final int proofLimitedPacketCount;
  final int warningLimitedScopeCount;
  final int blockedScopeCount;
  final int unsafePacketCount;
  final List<String> uniqueSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> coverageGapIds;
  final bool safeForPhase32C;
  final InternalPacketReviewPhase32CRecommendation phase32CRecommendation;
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
          InternalPacketReviewAggregationMatrixStatus.blockedByPrototype ||
      matrixStatus ==
          InternalPacketReviewAggregationMatrixStatus.blockedByValidation ||
      matrixStatus == InternalPacketReviewAggregationMatrixStatus.unsafe ||
      matrixStatus == InternalPacketReviewAggregationMatrixStatus.invalid ||
      !safeForPhase32C ||
      unsafePacketCount > 0;

  bool get hasUnsafeMatrixPolicyViolation {
    return unsafePacketCount > 0 ||
        validationFindings.any((finding) => finding.blocksStrict) ||
        rows.any((row) => row.reviewStatus.isUnsafe || row.hasUnsafeOutput) ||
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

  List<InternalPacketReviewAggregationRow> get packetRows =>
      rows.where((row) => row.isCorePacket).toList(growable: false);

  List<InternalPacketReviewAggregationRow> get stablePacketRows => packetRows
      .where(
        (row) =>
            row.reviewStatus == InternalPacketReviewStatus.stable ||
            row.reviewStatus == InternalPacketReviewStatus.stableWithWarnings,
      )
      .toList(growable: false);

  List<InternalPacketReviewAggregationRow> get proofLimitedRows => packetRows
      .where(
        (row) => row.reviewStatus == InternalPacketReviewStatus.proofLimited,
      )
      .toList(growable: false);

  List<InternalPacketReviewAggregationRow> get warningLimitedRows =>
      rows.where((row) => row.isWarningLimitedScope).toList(growable: false);

  List<InternalPacketReviewAggregationRow> get blockedOrFutureRows =>
      rows.where((row) => row.isBlockedOrFutureOnly).toList(growable: false);

  InternalPacketReviewAggregationRow row(
    InternalNonLabelPrototypeScopeId scopeId,
  ) {
    return rows.singleWhere((row) => row.allowedScopeId == scopeId);
  }

  InternalPacketReviewAggregationMatrixResult copyWith({
    InternalPacketReviewAggregationMatrixStatus? matrixStatus,
    NarrowInternalNonLabelAnalysisPrototypeStatus? prototypeStatus,
    InternalNonLabelPrototypeReadinessStatus? readinessStatus,
    InternalSignalObservationReviewMatrixStatus? reviewMatrixStatus,
    List<InternalPacketReviewAggregationRow>? rows,
    List<InternalPacketReviewAggregationMatrixValidationFinding>?
    validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalPackets,
    int? stablePacketCount,
    int? stableNarrowPacketCount,
    int? proofLimitedPacketCount,
    int? warningLimitedScopeCount,
    int? blockedScopeCount,
    int? unsafePacketCount,
    List<String>? uniqueSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? coverageGapIds,
    bool? safeForPhase32C,
    InternalPacketReviewPhase32CRecommendation? phase32CRecommendation,
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
    return InternalPacketReviewAggregationMatrixResult(
      matrixStatus: matrixStatus ?? this.matrixStatus,
      prototypeStatus: prototypeStatus ?? this.prototypeStatus,
      readinessStatus: readinessStatus ?? this.readinessStatus,
      reviewMatrixStatus: reviewMatrixStatus ?? this.reviewMatrixStatus,
      rows: rows ?? this.rows,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalPackets: totalPackets ?? this.totalPackets,
      stablePacketCount: stablePacketCount ?? this.stablePacketCount,
      stableNarrowPacketCount:
          stableNarrowPacketCount ?? this.stableNarrowPacketCount,
      proofLimitedPacketCount:
          proofLimitedPacketCount ?? this.proofLimitedPacketCount,
      warningLimitedScopeCount:
          warningLimitedScopeCount ?? this.warningLimitedScopeCount,
      blockedScopeCount: blockedScopeCount ?? this.blockedScopeCount,
      unsafePacketCount: unsafePacketCount ?? this.unsafePacketCount,
      uniqueSupportCaseIds: uniqueSupportCaseIds ?? this.uniqueSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      coverageGapIds: coverageGapIds ?? this.coverageGapIds,
      safeForPhase32C: safeForPhase32C ?? this.safeForPhase32C,
      phase32CRecommendation:
          phase32CRecommendation ?? this.phase32CRecommendation,
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
      ..writeln('# Internal Packet Review Aggregation Matrix')
      ..writeln()
      ..writeln(
        '- version: $internalPacketReviewAggregationMatrixReportVersion',
      )
      ..writeln('- matrix status: ${matrixStatus.wire}')
      ..writeln('- prototype status: ${prototypeStatus.wire}')
      ..writeln('- readiness status: ${readinessStatus.wire}')
      ..writeln('- review matrix status: ${reviewMatrixStatus.wire}')
      ..writeln('- total packets: $totalPackets')
      ..writeln('- stable packet count: $stablePacketCount')
      ..writeln('- stable narrow packet count: $stableNarrowPacketCount')
      ..writeln('- proof-limited packet count: $proofLimitedPacketCount')
      ..writeln('- warning-limited scope count: $warningLimitedScopeCount')
      ..writeln('- blocked or future-only scope count: $blockedScopeCount')
      ..writeln('- unsafe packet count: $unsafePacketCount')
      ..writeln('- safe for Phase 32C: $safeForPhase32C')
      ..writeln('- Phase 32C recommendation: ${phase32CRecommendation.wire}')
      ..writeln('- classifier output emitted: $classifierLabelsEmitted')
      ..writeln('- numeric value output emitted: $numericMoveScoresComputed')
      ..writeln('- move ordering output emitted: $moveRankingComputed')
      ..writeln()
      ..writeln('## Review Policy')
      ..writeln('- this matrix reviews and aggregates internal packets only')
      ..writeln(
        '- it does not classify moves, compute values, order moves, call an engine, integrate product output, or write files',
      )
      ..writeln()
      ..writeln('## Packet Review Table')
      ..writeln(
        '| Packet | Scope | Status | Confidence | Breadth | Support Cases | Android Proof | Signals | Areas | Buckets | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in rows) {
      buffer.writeln(
        '| ${row.packetId} | ${row.allowedScopeId.wire} | ${row.reviewStatus.wire} | ${row.qualitativeConfidence.wire} | ${row.supportBreadth.wire} | ${_ids(row.supportCaseIds)} | ${_ids(row.androidProofCaseIds)} | ${_signalIds(row.activeSignalIds)} | ${_areaIds(row.evidenceAreaIds)} | ${_bucketIds(row.bucketIds)} | ${row.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Aggregate Counts')
      ..writeln('- total packets: $totalPackets')
      ..writeln('- stable packet count: $stablePacketCount')
      ..writeln('- stable narrow packet count: $stableNarrowPacketCount')
      ..writeln('- proof-limited packet count: $proofLimitedPacketCount')
      ..writeln('- warning-limited scope count: $warningLimitedScopeCount')
      ..writeln('- blocked or future-only scope count: $blockedScopeCount')
      ..writeln('- unsafe packet count: $unsafePacketCount')
      ..writeln()
      ..writeln('## Stable Packets')
      ..writeln('- ${_rowIds(stablePacketRows)}')
      ..writeln()
      ..writeln('## Proof-Limited Packets')
      ..writeln('- ${_rowIds(proofLimitedRows)}')
      ..writeln()
      ..writeln('## Warning-Limited Scopes')
      ..writeln('- ${_rowScopeIds(warningLimitedRows)}')
      ..writeln()
      ..writeln('## Blocked And Future-Only Scopes')
      ..writeln('- ${_rowScopeIds(blockedOrFutureRows)}')
      ..writeln()
      ..writeln('## Support Case IDs')
      ..writeln('- ${_ids(uniqueSupportCaseIds)}')
      ..writeln()
      ..writeln('## Android Proof IDs')
      ..writeln('- ${_ids(androidProofCaseIds)}')
      ..writeln()
      ..writeln('## Coverage Gaps')
      ..writeln('- ${_ids(coverageGapIds)}')
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
      ..writeln('## Phase 32C Recommendation')
      ..writeln(phase32CRecommendation.wire)
      ..writeln()
      ..writeln(
        'This matrix keeps packet review internal-only. It does not emit user-facing output, compute product metrics, call the engine, run Android, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': internalPacketReviewAggregationMatrixReportVersion,
      'matrixStatus': matrixStatus.wire,
      'prototypeStatus': prototypeStatus.wire,
      'readinessStatus': readinessStatus.wire,
      'reviewMatrixStatus': reviewMatrixStatus.wire,
      'totalPackets': totalPackets,
      'stablePacketCount': stablePacketCount,
      'stableNarrowPacketCount': stableNarrowPacketCount,
      'proofLimitedPacketCount': proofLimitedPacketCount,
      'warningLimitedScopeCount': warningLimitedScopeCount,
      'blockedScopeCount': blockedScopeCount,
      'unsafePacketCount': unsafePacketCount,
      'uniqueSupportCaseIds': uniqueSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'coverageGapIds': coverageGapIds,
      'safeForPhase32C': safeForPhase32C,
      'phase32CRecommendation': phase32CRecommendation.wire,
      'rows': rows.map((row) => row.toJson()).toList(),
      'validationFindings': validationFindings
          .map((finding) => finding.toJson())
          .toList(),
      'warnings': warnings,
      'failures': failures,
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

class InternalPacketReviewAggregationMatrix {
  const InternalPacketReviewAggregationMatrix({
    this.validator = const InternalPacketReviewAggregationMatrixValidator(),
  });

  final InternalPacketReviewAggregationMatrixValidator validator;

  InternalPacketReviewAggregationMatrixResult evaluate([
    InternalPacketReviewAggregationMatrixRequest request =
        const InternalPacketReviewAggregationMatrixRequest(),
  ]) {
    final reviewResult =
        request.reviewResult ??
        request.reviewMatrix.evaluate(
          InternalSignalObservationReviewMatrixRequest(
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
          ),
        );
    final readinessResult =
        request.readinessResult ??
        request.readinessGate.evaluate(
          InternalNonLabelPrototypeReadinessGateRequest(
            reviewResult: reviewResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
          ),
        );
    final prototypeResult =
        request.prototypeResult ??
        request.prototype.run(
          NarrowInternalNonLabelAnalysisPrototypeRequest(
            readinessResult: readinessResult,
            reviewResult: reviewResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
          ),
        );

    final rows = _buildRows(
      request: request,
      prototypeResult: prototypeResult,
      readinessResult: readinessResult,
      reviewResult: reviewResult,
    );
    final base = _resultFromRows(
      rows: rows,
      prototypeResult: prototypeResult,
      readinessResult: readinessResult,
      reviewResult: reviewResult,
      validationFindings:
          const <InternalPacketReviewAggregationMatrixValidationFinding>[],
    );
    final findings = validator.validate(
      base,
      prototypeResult: prototypeResult,
      readinessResult: readinessResult,
      reviewResult: reviewResult,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromRows(
      rows: rows,
      prototypeResult: prototypeResult,
      readinessResult: readinessResult,
      reviewResult: reviewResult,
      validationFindings: findings,
    );
  }
}

class InternalPacketReviewAggregationMatrixValidator {
  const InternalPacketReviewAggregationMatrixValidator();

  List<InternalPacketReviewAggregationMatrixValidationFinding> validate(
    InternalPacketReviewAggregationMatrixResult result, {
    required NarrowInternalNonLabelAnalysisPrototypeResult prototypeResult,
    required InternalNonLabelPrototypeReadinessResult readinessResult,
    required InternalSignalObservationReviewMatrixResult reviewResult,
    required List<GoldenAnalysisCase> cases,
    required GoldenAndroidProofEvidence? androidProofEvidence,
  }) {
    final findings = <InternalPacketReviewAggregationMatrixValidationFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(
      reviewResult,
      androidProofEvidence,
    );
    final goldenCaseIds = cases.map((item) => item.id).toSet();

    void add({
      required String id,
      required InternalPacketReviewValidationSeverity severity,
      required String message,
      String? packetId,
      InternalNonLabelPrototypeScopeId? scopeId,
      InternalNonLabelSignalId? signalId,
      String? caseId,
    }) {
      findings.add(
        InternalPacketReviewAggregationMatrixValidationFinding(
          id: id,
          severity: severity,
          message: message,
          packetId: packetId,
          scopeId: scopeId,
          signalId: signalId,
          caseId: caseId,
        ),
      );
    }

    if (prototypeResult.isStrictlyBlocked &&
        result.rows.any((row) => row.isCorePacket)) {
      add(
        id: 'matrixReviewedPacketsDespiteBlockedPrototype',
        severity: InternalPacketReviewValidationSeverity.critical,
        message: 'matrix cannot review core packets from a blocked prototype',
      );
    }

    if (readinessResult.reviewUnsafeCount > 0 ||
        readinessResult.consistencyBlockerCount > 0 ||
        readinessResult.consistencyCriticalCount > 0) {
      add(
        id: 'readinessUnsafeForAggregation',
        severity: InternalPacketReviewValidationSeverity.critical,
        message: 'readiness inputs are unsafe for packet aggregation',
      );
    }

    for (final row in result.rows) {
      if (row.hasUnsafeOutput) {
        add(
          id: 'packetUnsafeOutputBoundary',
          severity: InternalPacketReviewValidationSeverity.critical,
          message: '${row.packetId} crossed a blocked output boundary',
          packetId: row.packetId,
          scopeId: row.allowedScopeId,
        );
      }
      if (row.isCorePacket &&
          !_allowedPacketScopes.contains(row.allowedScopeId)) {
        add(
          id: _warningLimitedPrototypeScopes.contains(row.allowedScopeId)
              ? 'warningLimitedScopeBecameCorePacket'
              : 'blockedScopeBecameCorePacket',
          severity: InternalPacketReviewValidationSeverity.blocker,
          message: '${row.allowedScopeId.wire} cannot become a core packet',
          packetId: row.packetId,
          scopeId: row.allowedScopeId,
        );
      }
      if (row.isCorePacket) {
        if (row.supportCaseIds.isEmpty) {
          add(
            id: 'stablePacketWithoutSupportCases',
            severity: InternalPacketReviewValidationSeverity.blocker,
            message: '${row.packetId} lacks supporting Golden cases',
            packetId: row.packetId,
            scopeId: row.allowedScopeId,
          );
        }
        if (row.activeSignalIds.isEmpty) {
          add(
            id: 'stablePacketWithoutActiveSignals',
            severity: InternalPacketReviewValidationSeverity.blocker,
            message: '${row.packetId} lacks active signal mapping',
            packetId: row.packetId,
            scopeId: row.allowedScopeId,
          );
        }
        if (row.evidenceAreaIds.isEmpty) {
          add(
            id: 'stablePacketWithoutEvidenceAreas',
            severity: InternalPacketReviewValidationSeverity.blocker,
            message: '${row.packetId} lacks evidence area mapping',
            packetId: row.packetId,
            scopeId: row.allowedScopeId,
          );
        }
        if (row.bucketIds.isEmpty) {
          add(
            id: 'stablePacketWithoutBuckets',
            severity: InternalPacketReviewValidationSeverity.blocker,
            message: '${row.packetId} lacks bucket mapping',
            packetId: row.packetId,
            scopeId: row.allowedScopeId,
          );
        }
      }
      if (row.quietScopeActive ||
          (row.isCorePacket &&
              row.allowedScopeId ==
                  InternalNonLabelPrototypeScopeId
                      .quietPreparatoryPrototypeScope)) {
        add(
          id: 'quietPreparatoryPacketActivated',
          severity: InternalPacketReviewValidationSeverity.critical,
          message: '${row.packetId} activated quiet or preparatory scope',
          packetId: row.packetId,
          scopeId: row.allowedScopeId,
        );
      }
      if (row.cpLossComputationImplemented ||
          row.winProbabilityComputationImplemented) {
        add(
          id: 'futureComputationActivated',
          severity: InternalPacketReviewValidationSeverity.critical,
          message: '${row.packetId} activated a future computation',
          packetId: row.packetId,
          scopeId: row.allowedScopeId,
        );
      }
      for (final caseId in row.supportCaseIds) {
        if (!goldenCaseIds.contains(caseId)) {
          add(
            id: 'unknownSupportCaseId',
            severity: InternalPacketReviewValidationSeverity.blocker,
            message: '${row.packetId} cited an unknown support case',
            packetId: row.packetId,
            scopeId: row.allowedScopeId,
            caseId: caseId,
          );
        }
      }
      for (final caseId in row.androidProofCaseIds) {
        if (!_capturedAndroidProofIds.contains(caseId) ||
            !provenAndroidIds.contains(caseId)) {
          add(
            id: 'unprovenAndroidProofCitation',
            severity: InternalPacketReviewValidationSeverity.blocker,
            message: '${row.packetId} cited unproven Android proof',
            packetId: row.packetId,
            scopeId: row.allowedScopeId,
            caseId: caseId,
          );
        }
      }
    }

    final warningCoreScopes = result.rows
        .where(
          (row) =>
              row.isCorePacket &&
              _warningLimitedPrototypeScopes.contains(row.allowedScopeId),
        )
        .toList(growable: false);
    for (final row in warningCoreScopes) {
      add(
        id: 'warningLimitedScopeCannotBecomeCorePacket',
        severity: InternalPacketReviewValidationSeverity.blocker,
        message: '${row.allowedScopeId.wire} must remain warning-limited',
        packetId: row.packetId,
        scopeId: row.allowedScopeId,
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
        severity: InternalPacketReviewValidationSeverity.critical,
        message: 'matrix crossed a blocked output or integration boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<InternalPacketReviewAggregationMatrixValidationFinding>
  validateReportText(String reportText) {
    final findings = <InternalPacketReviewAggregationMatrixValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        InternalPacketReviewAggregationMatrixValidationFinding(
          id: id,
          severity: InternalPacketReviewValidationSeverity.critical,
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

List<InternalPacketReviewAggregationRow> _buildRows({
  required InternalPacketReviewAggregationMatrixRequest request,
  required NarrowInternalNonLabelAnalysisPrototypeResult prototypeResult,
  required InternalNonLabelPrototypeReadinessResult readinessResult,
  required InternalSignalObservationReviewMatrixResult reviewResult,
}) {
  final rows = <InternalPacketReviewAggregationRow>[];
  final reviewRowsBySignal =
      <InternalNonLabelSignalId, InternalSignalObservationReviewRow>{
        for (final row in reviewResult.rows) row.signalId: row,
      };

  for (final packet in prototypeResult.packets) {
    rows.add(
      _packetRow(
        packet: packet,
        readinessResult: readinessResult,
        reviewResult: reviewResult,
        androidProofEvidence: request.androidProofEvidence,
      ),
    );
  }

  if (request.includeWarningLimitedScopes) {
    for (final scope in readinessResult.scopeRecords.where(
      (scope) => scope.isWarningLimited,
    )) {
      rows.add(_warningScopeRow(scope, reviewRowsBySignal));
    }
  }

  if (request.includeBlockedScopes || request.includeFutureOnlyScopes) {
    for (final scope in readinessResult.scopeRecords.where(
      (scope) =>
          scope.readiness == InternalNonLabelPrototypeScopeReadiness.blocked ||
          scope.readiness == InternalNonLabelPrototypeScopeReadiness.futureOnly,
    )) {
      if (scope.readiness ==
              InternalNonLabelPrototypeScopeReadiness.futureOnly &&
          !request.includeFutureOnlyScopes) {
        continue;
      }
      if (scope.readiness == InternalNonLabelPrototypeScopeReadiness.blocked &&
          !request.includeBlockedScopes) {
        continue;
      }
      rows.add(_blockedOrFutureScopeRow(scope, reviewRowsBySignal));
    }
  }

  return List<InternalPacketReviewAggregationRow>.unmodifiable(
    rows..sort(
      (a, b) => a.allowedScopeId.index.compareTo(b.allowedScopeId.index),
    ),
  );
}

InternalPacketReviewAggregationRow _packetRow({
  required NarrowInternalAnalysisPrototypePacket packet,
  required InternalNonLabelPrototypeReadinessResult readinessResult,
  required InternalSignalObservationReviewMatrixResult reviewResult,
  required GoldenAndroidProofEvidence? androidProofEvidence,
}) {
  final proofValid = packet.androidProofCaseIds.every(
    (caseId) =>
        _capturedAndroidProofIds.contains(caseId) &&
        _provenAndroidProofIds(
          reviewResult,
          androidProofEvidence,
        ).contains(caseId),
  );
  final hasMapping =
      packet.activeSignalIds.isNotEmpty &&
      packet.evidenceAreaIds.isNotEmpty &&
      packet.bucketIds.isNotEmpty;
  final supportBreadth = _supportBreadthFor(
    packet.supportCaseIds,
    packet.androidProofCaseIds,
  );
  final warningReasons = _packetWarningReasons(packet, readinessResult);
  final status = _packetStatusFor(
    packet: packet,
    proofValid: proofValid,
    hasMapping: hasMapping,
    warningReasons: warningReasons,
  );
  return InternalPacketReviewAggregationRow(
    packetId: packet.packetId,
    allowedScopeId: packet.allowedScopeId,
    reviewStatus: status,
    supportCaseIds: packet.supportCaseIds,
    androidProofCaseIds: packet.androidProofCaseIds,
    activeSignalIds: packet.activeSignalIds,
    evidenceAreaIds: packet.evidenceAreaIds,
    bucketIds: packet.bucketIds,
    qualitativeConfidence: packet.qualitativeConfidence,
    supportBreadth: status == InternalPacketReviewStatus.proofLimited
        ? InternalPacketSupportBreadth.proofLimitedSupport
        : supportBreadth,
    warningReasons: warningReasons,
    coverageGapIds: packet.coverageGapIds,
    futurePrerequisites: packet.futurePrerequisites,
    blockedBoundaryIds: packet.blockedScopeIds.map((id) => id.wire).toList(),
    recommendation: _recommendationFor(status),
    isCorePacket: true,
    isProductOutput: packet.isProductOutput,
    isClassifierLabel: packet.isClassifierLabel,
    isOfficialMetric: packet.isOfficialMetric,
    hasNumericScore: packet.hasNumericScore,
    ranksMoves: packet.ranksMoves,
    quietScopeActive: packet.quietScopeActive,
    cpLossComputationImplemented: packet.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        packet.winProbabilityComputationImplemented,
    emittedOutputNames: packet.emittedOutputNames,
  );
}

InternalPacketReviewAggregationRow _warningScopeRow(
  InternalNonLabelPrototypeScopeReadinessRecord scope,
  Map<InternalNonLabelSignalId, InternalSignalObservationReviewRow>
  rowsBySignal,
) {
  final reviewRow = scope.signalId == null
      ? null
      : rowsBySignal[scope.signalId];
  final warningReasons = _sortedStrings(<String>[
    scope.warningReason,
    ...scope.coverageGapIds,
  ]);
  return InternalPacketReviewAggregationRow(
    packetId: '${scope.scopeId.wire}-warning-scope-review',
    allowedScopeId: scope.scopeId,
    reviewStatus: InternalPacketReviewStatus.warningOnly,
    supportCaseIds: scope.supportCaseIds,
    androidProofCaseIds: scope.androidProofCaseIds,
    activeSignalIds: scope.signalId == null
        ? const <InternalNonLabelSignalId>[]
        : <InternalNonLabelSignalId>[scope.signalId!],
    evidenceAreaIds:
        reviewRow?.evidenceAreaIds ?? const <InternalEvidenceAreaId>[],
    bucketIds: reviewRow?.bucketIds ?? const <InternalEvidenceBucketId>[],
    qualitativeConfidence: InternalNonLabelSignalConfidence.warningOnly,
    supportBreadth: InternalPacketSupportBreadth.warningOnlySupport,
    warningReasons: warningReasons,
    coverageGapIds: scope.coverageGapIds,
    futurePrerequisites: _sortedStrings(<String>[
      scope.warningReason,
      ...scope.policyBlockers,
    ]),
    blockedBoundaryIds: const <String>[],
    recommendation: InternalPacketReviewRecommendation.keepWarningLimited,
  );
}

InternalPacketReviewAggregationRow _blockedOrFutureScopeRow(
  InternalNonLabelPrototypeScopeReadinessRecord scope,
  Map<InternalNonLabelSignalId, InternalSignalObservationReviewRow>
  rowsBySignal,
) {
  final reviewRow = scope.signalId == null
      ? null
      : rowsBySignal[scope.signalId];
  final isFuture =
      scope.readiness == InternalNonLabelPrototypeScopeReadiness.futureOnly;
  return InternalPacketReviewAggregationRow(
    packetId: '${scope.scopeId.wire}-policy-boundary-review',
    allowedScopeId: scope.scopeId,
    reviewStatus: isFuture
        ? InternalPacketReviewStatus.futureOnlyCorrectly
        : InternalPacketReviewStatus.blockedCorrectly,
    supportCaseIds: scope.supportCaseIds,
    androidProofCaseIds: scope.androidProofCaseIds,
    activeSignalIds: scope.signalId == null
        ? const <InternalNonLabelSignalId>[]
        : <InternalNonLabelSignalId>[scope.signalId!],
    evidenceAreaIds:
        reviewRow?.evidenceAreaIds ?? const <InternalEvidenceAreaId>[],
    bucketIds: reviewRow?.bucketIds ?? const <InternalEvidenceBucketId>[],
    qualitativeConfidence: isFuture
        ? InternalNonLabelSignalConfidence.futureOnly
        : InternalNonLabelSignalConfidence.blocked,
    supportBreadth: isFuture
        ? InternalPacketSupportBreadth.futureOnlyBoundary
        : InternalPacketSupportBreadth.blockedBoundary,
    warningReasons: const <String>[],
    coverageGapIds: scope.coverageGapIds,
    futurePrerequisites: isFuture ? scope.policyBlockers : const <String>[],
    blockedBoundaryIds: _sortedStrings(<String>[
      scope.scopeId.wire,
      ...scope.policyBlockers,
    ]),
    recommendation: isFuture
        ? InternalPacketReviewRecommendation.keepFutureOnly
        : InternalPacketReviewRecommendation.keepBlockedByPolicy,
  );
}

InternalPacketReviewAggregationMatrixResult _resultFromRows({
  required List<InternalPacketReviewAggregationRow> rows,
  required NarrowInternalNonLabelAnalysisPrototypeResult prototypeResult,
  required InternalNonLabelPrototypeReadinessResult readinessResult,
  required InternalSignalObservationReviewMatrixResult reviewResult,
  required List<InternalPacketReviewAggregationMatrixValidationFinding>
  validationFindings,
}) {
  final packetRows = rows.where((row) => row.isCorePacket).toList();
  final unsafePacketCount = rows
      .where((row) => row.reviewStatus.isUnsafe)
      .length;
  final warnings = _sortedStrings(<String>[
    ...prototypeResult.warnings,
    ...readinessResult.warnings,
    ...reviewResult.warnings,
    ...rows.expand((row) => row.warningReasons),
  ]);
  final failures = _sortedStrings(<String>[
    ...prototypeResult.failures,
    ...readinessResult.failures,
    ...reviewResult.failures,
    ...validationFindings.map((finding) => finding.message),
  ]);
  final stablePacketCount = packetRows
      .where(
        (row) =>
            row.reviewStatus == InternalPacketReviewStatus.stable ||
            row.reviewStatus == InternalPacketReviewStatus.stableWithWarnings,
      )
      .length;
  final stableNarrowPacketCount = packetRows
      .where(
        (row) => row.reviewStatus == InternalPacketReviewStatus.stableNarrow,
      )
      .length;
  final proofLimitedPacketCount = packetRows
      .where(
        (row) => row.reviewStatus == InternalPacketReviewStatus.proofLimited,
      )
      .length;
  final safeForPhase32C =
      unsafePacketCount == 0 &&
      !prototypeResult.isStrictlyBlocked &&
      !prototypeResult.hasUnsafePrototypePolicyViolation &&
      !readinessResult.hasUnsafeReadinessPolicyViolation &&
      !reviewResult.hasUnsafeReviewPolicyViolation &&
      !validationFindings.any((finding) => finding.blocksStrict) &&
      packetRows.length == 6;
  final base = InternalPacketReviewAggregationMatrixResult(
    matrixStatus: InternalPacketReviewAggregationMatrixStatus.readyInternalOnly,
    prototypeStatus: prototypeResult.prototypeStatus,
    readinessStatus: readinessResult.overallStatus,
    reviewMatrixStatus: reviewResult.matrixStatus,
    rows: rows,
    validationFindings: validationFindings,
    warnings: warnings,
    failures: failures,
    totalPackets: packetRows.length,
    stablePacketCount: stablePacketCount,
    stableNarrowPacketCount: stableNarrowPacketCount,
    proofLimitedPacketCount: proofLimitedPacketCount,
    warningLimitedScopeCount: rows
        .where((row) => row.isWarningLimitedScope)
        .length,
    blockedScopeCount: rows.where((row) => row.isBlockedOrFutureOnly).length,
    unsafePacketCount: unsafePacketCount,
    uniqueSupportCaseIds: _sortedStrings(
      rows.expand((row) => row.supportCaseIds),
    ),
    androidProofCaseIds: _sortedStrings(
      rows.expand((row) => row.androidProofCaseIds),
    ),
    coverageGapIds: _sortedStrings(<String>[
      ...prototypeResult.coverageGapIds,
      ...readinessResult.coverageGapIds,
      ...rows.expand((row) => row.coverageGapIds),
    ]),
    safeForPhase32C: safeForPhase32C,
    phase32CRecommendation: InternalPacketReviewPhase32CRecommendation
        .proceedToInternalPacketStabilityPrototype,
    productLabelsEmitted:
        prototypeResult.productLabelsEmitted ||
        readinessResult.productLabelsEmitted ||
        reviewResult.productLabelsEmitted,
    classifierLabelsEmitted:
        prototypeResult.classifierLabelsEmitted ||
        readinessResult.classifierLabelsEmitted ||
        reviewResult.classifierLabelsEmitted,
    finalMoveLabelsEmitted:
        prototypeResult.finalMoveLabelsEmitted ||
        readinessResult.finalMoveLabelsEmitted ||
        reviewResult.finalMoveLabelsEmitted,
    officialMetricsAllowed:
        prototypeResult.officialMetricsAllowed ||
        readinessResult.officialMetricsAllowed ||
        reviewResult.officialMetricsAllowed,
    cpLossComputationImplemented:
        prototypeResult.cpLossComputationImplemented ||
        readinessResult.cpLossComputationImplemented ||
        reviewResult.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        prototypeResult.winProbabilityComputationImplemented ||
        readinessResult.winProbabilityComputationImplemented ||
        reviewResult.winProbabilityComputationImplemented,
    numericMoveScoresComputed:
        prototypeResult.numericMoveScoresComputed ||
        readinessResult.numericMoveScoresComputed ||
        reviewResult.numericMoveScoresComputed,
    moveRankingComputed:
        prototypeResult.moveRankingComputed ||
        readinessResult.moveRankingComputed ||
        reviewResult.moveRankingComputed,
    directEngineAccessUsed:
        prototypeResult.directEngineAccessUsed ||
        readinessResult.directEngineAccessUsed ||
        reviewResult.directEngineAccessUsed,
    uiOutputUsed:
        prototypeResult.uiOutputUsed ||
        readinessResult.uiOutputUsed ||
        reviewResult.uiOutputUsed,
    backendOutputUsed:
        prototypeResult.backendOutputUsed ||
        readinessResult.backendOutputUsed ||
        reviewResult.backendOutputUsed,
    persistenceUsed:
        prototypeResult.persistenceUsed ||
        readinessResult.persistenceUsed ||
        reviewResult.persistenceUsed,
    emittedOutputFamilies: _sortedStrings(<String>[
      ...prototypeResult.emittedOutputFamilies,
      ...readinessResult.emittedOutputFamilies,
      ...reviewResult.emittedOutputFamilies,
    ]),
  );
  return base.copyWith(
    matrixStatus: _matrixStatusFor(base),
    phase32CRecommendation: _phase32CRecommendationFor(base),
  );
}

InternalPacketReviewStatus _packetStatusFor({
  required NarrowInternalAnalysisPrototypePacket packet,
  required bool proofValid,
  required bool hasMapping,
  required List<String> warningReasons,
}) {
  if (packet.hasUnsafeOutput ||
      !proofValid ||
      packet.quietScopeActive ||
      packet.cpLossComputationImplemented ||
      packet.winProbabilityComputationImplemented ||
      !_allowedPacketScopes.contains(packet.allowedScopeId)) {
    return InternalPacketReviewStatus.unsafe;
  }
  if (packet.supportCaseIds.isEmpty || !hasMapping) {
    return InternalPacketReviewStatus.invalid;
  }
  if (packet.allowedScopeId ==
      InternalNonLabelPrototypeScopeId
          .androidProofConfidenceInternalPrototypeScope) {
    return InternalPacketReviewStatus.proofLimited;
  }
  if (packet.allowedScopeId ==
      InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope) {
    return InternalPacketReviewStatus.stableWithWarnings;
  }
  if (packet.supportCaseIds.length == 1) {
    return InternalPacketReviewStatus.needsMoreGoldenCoverage;
  }
  if (packet.supportCaseIds.length == 2) {
    return InternalPacketReviewStatus.stableNarrow;
  }
  return InternalPacketReviewStatus.stable;
}

InternalPacketSupportBreadth _supportBreadthFor(
  List<String> supportCaseIds,
  List<String> androidProofCaseIds,
) {
  if (supportCaseIds.isEmpty) return InternalPacketSupportBreadth.none;
  if (androidProofCaseIds.isNotEmpty &&
      supportCaseIds.length == androidProofCaseIds.length &&
      supportCaseIds.every(androidProofCaseIds.contains)) {
    return InternalPacketSupportBreadth.proofLimitedSupport;
  }
  if (supportCaseIds.length >= 3) {
    return InternalPacketSupportBreadth.broadGoldenSupport;
  }
  if (supportCaseIds.length == 2) {
    return InternalPacketSupportBreadth.narrowGoldenSupport;
  }
  return InternalPacketSupportBreadth.thinGoldenSupport;
}

List<String> _packetWarningReasons(
  NarrowInternalAnalysisPrototypePacket packet,
  InternalNonLabelPrototypeReadinessResult readinessResult,
) {
  final reasons = <String>{};
  final scopeRecord = _scopeOrNull(readinessResult, packet.allowedScopeId);
  if (scopeRecord?.warningReason.isNotEmpty ?? false) {
    reasons.add(scopeRecord!.warningReason);
  }
  if (packet.coverageGapIds.contains(packet.allowedScopeId.wire)) {
    reasons.add(packet.allowedScopeId.wire);
  }
  if (packet.allowedScopeId ==
      InternalNonLabelPrototypeScopeId
          .androidProofConfidenceInternalPrototypeScope) {
    reasons.add('limited to captured Android proof IDs');
  }
  if (packet.allowedScopeId ==
      InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope) {
    reasons.add('limited to proof-backed PV and MultiPV support');
  }
  return _sortedStrings(reasons);
}

InternalPacketReviewRecommendation _recommendationFor(
  InternalPacketReviewStatus status,
) {
  return switch (status) {
    InternalPacketReviewStatus.stable =>
      InternalPacketReviewRecommendation.keepStable,
    InternalPacketReviewStatus.stableNarrow =>
      InternalPacketReviewRecommendation.keepStableButNarrow,
    InternalPacketReviewStatus.stableWithWarnings =>
      InternalPacketReviewRecommendation.keepStable,
    InternalPacketReviewStatus.needsMoreGoldenCoverage =>
      InternalPacketReviewRecommendation.addGoldenCoverage,
    InternalPacketReviewStatus.proofLimited =>
      InternalPacketReviewRecommendation.keepProofLimited,
    InternalPacketReviewStatus.warningOnly =>
      InternalPacketReviewRecommendation.keepWarningLimited,
    InternalPacketReviewStatus.blockedCorrectly =>
      InternalPacketReviewRecommendation.keepBlockedByPolicy,
    InternalPacketReviewStatus.futureOnlyCorrectly =>
      InternalPacketReviewRecommendation.keepFutureOnly,
    InternalPacketReviewStatus.unsafe || InternalPacketReviewStatus.invalid =>
      InternalPacketReviewRecommendation.investigateUnsafePacket,
  };
}

InternalPacketReviewAggregationMatrixStatus _matrixStatusFor(
  InternalPacketReviewAggregationMatrixResult result,
) {
  if (result.unsafePacketCount > 0 ||
      result.validationFindings.any((finding) => finding.isCritical) ||
      result.productLabelsEmitted ||
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
    return InternalPacketReviewAggregationMatrixStatus.unsafe;
  }
  if (result.validationFindings.any((finding) => finding.blocksStrict)) {
    return InternalPacketReviewAggregationMatrixStatus.blockedByValidation;
  }
  if (result.totalPackets == 0) {
    return InternalPacketReviewAggregationMatrixStatus.blockedByPrototype;
  }
  if (result.warningLimitedScopeCount > 0 ||
      result.coverageGapIds.isNotEmpty ||
      result.warnings.isNotEmpty ||
      result.proofLimitedPacketCount > 0) {
    return InternalPacketReviewAggregationMatrixStatus.readyWithWarnings;
  }
  return InternalPacketReviewAggregationMatrixStatus.readyInternalOnly;
}

InternalPacketReviewPhase32CRecommendation _phase32CRecommendationFor(
  InternalPacketReviewAggregationMatrixResult result,
) {
  if (result.unsafePacketCount > 0 ||
      result.validationFindings.any((finding) => finding.isCritical)) {
    return InternalPacketReviewPhase32CRecommendation.blockedByUnsafePacket;
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
    return InternalPacketReviewPhase32CRecommendation.blockedByPolicyBoundary;
  }
  if (result.validationFindings.any((finding) => finding.blocksStrict)) {
    return InternalPacketReviewPhase32CRecommendation.addGoldenCoverageFirst;
  }
  if (!result.safeForPhase32C) {
    return InternalPacketReviewPhase32CRecommendation.keepNarrowPrototypeOnly;
  }
  return InternalPacketReviewPhase32CRecommendation
      .proceedToInternalPacketStabilityPrototype;
}

InternalNonLabelPrototypeScopeReadinessRecord? _scopeOrNull(
  InternalNonLabelPrototypeReadinessResult result,
  InternalNonLabelPrototypeScopeId scopeId,
) {
  for (final scope in result.scopeRecords) {
    if (scope.scopeId == scopeId) return scope;
  }
  return null;
}

List<String> _provenAndroidProofIds(
  InternalSignalObservationReviewMatrixResult reviewResult,
  GoldenAndroidProofEvidence? androidProofEvidence,
) {
  final proofIds = androidProofEvidence?.targetCaseIds ?? const <String>[];
  return _sortedStrings(
    reviewResult.provenAndroidCaseIds.where(
      (caseId) =>
          _capturedAndroidProofIds.contains(caseId) &&
          proofIds.contains(caseId) &&
          (androidProofEvidence?.isRealDeviceProofCapturedFor(
                caseId,
                minMultiPvLineCount: 1,
                requirePv: true,
              ) ??
              false),
    ),
  );
}

String _ids(Iterable<String> values) {
  final sorted = _sortedStrings(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

String _rowIds(Iterable<InternalPacketReviewAggregationRow> rows) {
  final ids = rows.map((row) => row.packetId).toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _rowScopeIds(Iterable<InternalPacketReviewAggregationRow> rows) {
  final ids = rows.map((row) => row.allowedScopeId.wire).toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _signalIds(Iterable<InternalNonLabelSignalId> values) {
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
  return values.where((value) => value.isNotEmpty).toSet().toList()..sort();
}

int _compareFindings(
  InternalPacketReviewAggregationMatrixValidationFinding a,
  InternalPacketReviewAggregationMatrixValidationFinding b,
) {
  final idCompare = a.id.compareTo(b.id);
  if (idCompare != 0) return idCompare;
  final packetCompare = (a.packetId ?? '').compareTo(b.packetId ?? '');
  if (packetCompare != 0) return packetCompare;
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

const _capturedAndroidProofIds = <String>{
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
};

const _allowedPacketScopes = <InternalNonLabelPrototypeScopeId>{
  InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.materialSwingInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.forcingLineInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.candidateSpreadInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.androidProofConfidenceInternalPrototypeScope,
};

const _warningLimitedPrototypeScopes = <InternalNonLabelPrototypeScopeId>{
  InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.endgameInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.suppressionSafetyInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.budgetRiskInternalPrototypeScope,
};

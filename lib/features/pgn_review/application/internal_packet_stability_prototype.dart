/// Developer-only stability prototype for Phase 32B internal packet rows.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_review_aggregation_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/narrow_internal_non_label_analysis_prototype.dart';

const internalPacketStabilityPrototypeReportVersion =
    'internal-packet-stability-prototype-v1';

enum InternalPacketStabilityPrototypeStatus {
  stableInternalOnly('stableInternalOnly'),
  stableWithWarnings('stableWithWarnings'),
  blockedByMatrix('blockedByMatrix'),
  blockedByValidation('blockedByValidation'),
  unsafe('unsafe'),
  invalid('invalid');

  const InternalPacketStabilityPrototypeStatus(this.wire);

  final String wire;
}

enum InternalPacketStabilityStatus {
  stable('stable'),
  stableNarrow('stableNarrow'),
  stableWithWarnings('stableWithWarnings'),
  proofLimitedStable('proofLimitedStable'),
  warningLimitedOnly('warningLimitedOnly'),
  blockedCorrectly('blockedCorrectly'),
  futureOnlyCorrectly('futureOnlyCorrectly'),
  unstable('unstable'),
  unsafe('unsafe'),
  invalid('invalid');

  const InternalPacketStabilityStatus(this.wire);

  final String wire;

  bool get isStableCore =>
      this == InternalPacketStabilityStatus.stable ||
      this == InternalPacketStabilityStatus.stableNarrow ||
      this == InternalPacketStabilityStatus.stableWithWarnings ||
      this == InternalPacketStabilityStatus.proofLimitedStable;

  bool get isWarningLimited =>
      this == InternalPacketStabilityStatus.warningLimitedOnly;

  bool get isBlockedOrFutureOnly =>
      this == InternalPacketStabilityStatus.blockedCorrectly ||
      this == InternalPacketStabilityStatus.futureOnlyCorrectly;

  bool get isUnsafe =>
      this == InternalPacketStabilityStatus.unsafe ||
      this == InternalPacketStabilityStatus.invalid;
}

enum InternalPacketStabilityRecommendation {
  preserveStablePacket('preserveStablePacket'),
  preserveStableNarrowPacket('preserveStableNarrowPacket'),
  preserveProofLimitedPacket('preserveProofLimitedPacket'),
  keepWarningLimited('keepWarningLimited'),
  addGoldenCoverage('addGoldenCoverage'),
  keepBlockedByPolicy('keepBlockedByPolicy'),
  keepFutureOnly('keepFutureOnly'),
  investigateInstability('investigateInstability');

  const InternalPacketStabilityRecommendation(this.wire);

  final String wire;
}

enum InternalPacketStabilityPhase32DRecommendation {
  proceedToInternalPacketEvidenceHardeningPlan(
    'proceedToInternalPacketEvidenceHardeningPlan',
  ),
  addGoldenCoverageFirst('addGoldenCoverageFirst'),
  keepNarrowPrototypeOnly('keepNarrowPrototypeOnly'),
  investigateInstabilityFirst('investigateInstabilityFirst'),
  blockedByUnsafeOutput('blockedByUnsafeOutput');

  const InternalPacketStabilityPhase32DRecommendation(this.wire);

  final String wire;
}

enum InternalPacketStabilityValidationSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const InternalPacketStabilityValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == InternalPacketStabilityValidationSeverity.blocker ||
      this == InternalPacketStabilityValidationSeverity.critical;
}

enum InternalPacketStabilityPrototypeReportFormat {
  markdown('markdown'),
  json('json');

  const InternalPacketStabilityPrototypeReportFormat(this.wire);

  final String wire;
}

class InternalPacketStabilityPrototypeRequest {
  const InternalPacketStabilityPrototypeRequest({
    this.matrixResult,
    this.prototypeResult,
    this.readinessResult,
    this.matrix = const InternalPacketReviewAggregationMatrix(),
    this.prototype = const NarrowInternalNonLabelAnalysisPrototype(),
    this.readinessGate = const InternalNonLabelPrototypeReadinessGate(),
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.cases = GoldenAnalysisCases.defaults,
    this.includeWarningLimitedScopes = true,
    this.includeBlockedScopes = true,
    this.includeFutureOnlyScopes = true,
  });

  const InternalPacketStabilityPrototypeRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarningLimitedScopes: includeWarnings);

  final InternalPacketReviewAggregationMatrixResult? matrixResult;
  final NarrowInternalNonLabelAnalysisPrototypeResult? prototypeResult;
  final InternalNonLabelPrototypeReadinessResult? readinessResult;
  final InternalPacketReviewAggregationMatrix matrix;
  final NarrowInternalNonLabelAnalysisPrototype prototype;
  final InternalNonLabelPrototypeReadinessGate readinessGate;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final List<GoldenAnalysisCase> cases;
  final bool includeWarningLimitedScopes;
  final bool includeBlockedScopes;
  final bool includeFutureOnlyScopes;
}

class InternalPacketStabilityRecord {
  const InternalPacketStabilityRecord({
    required this.recordId,
    required this.packetId,
    required this.scopeId,
    required this.stabilityStatus,
    required this.sourceReviewStatus,
    required this.supportCaseIds,
    required this.androidProofCaseIds,
    required this.activeSignalIds,
    required this.evidenceAreaIds,
    required this.bucketIds,
    required this.qualitativeConfidence,
    required this.stabilityReason,
    required this.warningReason,
    required this.proofLimitReason,
    required this.coverageGapIds,
    required this.blockedBoundaryIds,
    required this.futurePrerequisites,
    required this.recommendation,
    this.isCorePacket = false,
    this.isProductOutput = false,
    this.isClassifierLabel = false,
    this.isOfficialMetric = false,
    this.hasNumericValue = false,
    this.ordersMoves = false,
    this.quietScopeActive = false,
    this.cpLossComputationImplemented = false,
    this.winProbabilityComputationImplemented = false,
    this.emittedOutputNames = const <String>[],
  });

  final String recordId;
  final String? packetId;
  final InternalNonLabelPrototypeScopeId scopeId;
  final InternalPacketStabilityStatus stabilityStatus;
  final InternalPacketReviewStatus sourceReviewStatus;
  final List<String> supportCaseIds;
  final List<String> androidProofCaseIds;
  final List<InternalNonLabelSignalId> activeSignalIds;
  final List<InternalEvidenceAreaId> evidenceAreaIds;
  final List<InternalEvidenceBucketId> bucketIds;
  final InternalNonLabelSignalConfidence qualitativeConfidence;
  final String stabilityReason;
  final String warningReason;
  final String proofLimitReason;
  final List<String> coverageGapIds;
  final List<String> blockedBoundaryIds;
  final List<String> futurePrerequisites;
  final InternalPacketStabilityRecommendation recommendation;
  final bool isCorePacket;
  final bool isProductOutput;
  final bool isClassifierLabel;
  final bool isOfficialMetric;
  final bool hasNumericValue;
  final bool ordersMoves;
  final bool quietScopeActive;
  final bool cpLossComputationImplemented;
  final bool winProbabilityComputationImplemented;
  final List<String> emittedOutputNames;

  bool get hasUnsafeOutput {
    return isProductOutput ||
        isClassifierLabel ||
        isOfficialMetric ||
        hasNumericValue ||
        ordersMoves ||
        quietScopeActive ||
        cpLossComputationImplemented ||
        winProbabilityComputationImplemented ||
        emittedOutputNames.any(_isForbiddenOutputName);
  }

  bool get isWarningLimitedScope => stabilityStatus.isWarningLimited;

  bool get isBlockedOrFutureOnly => stabilityStatus.isBlockedOrFutureOnly;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'recordId': recordId,
      if (packetId != null) 'packetId': packetId,
      'scopeId': scopeId.wire,
      'stabilityStatus': stabilityStatus.wire,
      'sourceReviewStatus': sourceReviewStatus.wire,
      'supportCaseIds': supportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'activeSignalIds': activeSignalIds.map((id) => id.wire).toList(),
      'evidenceAreaIds': evidenceAreaIds.map((id) => id.wire).toList(),
      'bucketIds': bucketIds.map((id) => id.wire).toList(),
      'qualitativeConfidence': qualitativeConfidence.wire,
      'stabilityReason': stabilityReason,
      'warningReason': warningReason,
      'proofLimitReason': proofLimitReason,
      'coverageGapIds': coverageGapIds,
      'blockedBoundaryIds': blockedBoundaryIds,
      'futurePrerequisites': futurePrerequisites,
      'recommendation': recommendation.wire,
      'isCorePacket': isCorePacket,
      'isProductOutput': isProductOutput,
      'isClassifierLabel': isClassifierLabel,
      'isOfficialMetric': isOfficialMetric,
      'hasNumericValue': hasNumericValue,
      'ordersMoves': ordersMoves,
      'quietScopeActive': quietScopeActive,
      'cpLossComputationImplemented': cpLossComputationImplemented,
      'winProbabilityComputationImplemented':
          winProbabilityComputationImplemented,
      'emittedOutputNames': emittedOutputNames,
    };
  }
}

class InternalPacketStabilityPrototypeValidationFinding {
  const InternalPacketStabilityPrototypeValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.recordId,
    this.packetId,
    this.scopeId,
    this.signalId,
    this.caseId,
  });

  final String id;
  final InternalPacketStabilityValidationSeverity severity;
  final String message;
  final String? recordId;
  final String? packetId;
  final InternalNonLabelPrototypeScopeId? scopeId;
  final InternalNonLabelSignalId? signalId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical =>
      severity == InternalPacketStabilityValidationSeverity.critical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (recordId != null) 'recordId': recordId,
      if (packetId != null) 'packetId': packetId,
      if (scopeId != null) 'scopeId': scopeId!.wire,
      if (signalId != null) 'signalId': signalId!.wire,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class InternalPacketStabilityPrototypeResult {
  const InternalPacketStabilityPrototypeResult({
    required this.prototypeStatus,
    required this.sourceMatrixStatus,
    required this.sourcePrototypeStatus,
    required this.sourceReadinessStatus,
    required this.records,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalStabilityRecords,
    required this.stableCount,
    required this.stableNarrowCount,
    required this.stableWithWarningsCount,
    required this.proofLimitedStableCount,
    required this.warningLimitedCount,
    required this.blockedOrFutureOnlyCount,
    required this.unstableCount,
    required this.unsafeCount,
    required this.uniqueSupportCaseIds,
    required this.androidProofCaseIds,
    required this.coverageGapIds,
    required this.safeForPhase32D,
    required this.phase32DRecommendation,
    this.developerOnly = true,
    this.productLabelsEmitted = false,
    this.classifierLabelsEmitted = false,
    this.finalMoveLabelsEmitted = false,
    this.officialMetricsAllowed = false,
    this.cpLossComputationImplemented = false,
    this.winProbabilityComputationImplemented = false,
    this.numericMoveValuesComputed = false,
    this.moveOrderingComputed = false,
    this.directEngineAccessUsed = false,
    this.uiOutputUsed = false,
    this.backendOutputUsed = false,
    this.persistenceUsed = false,
    this.emittedOutputFamilies = const <String>[],
  });

  final InternalPacketStabilityPrototypeStatus prototypeStatus;
  final InternalPacketReviewAggregationMatrixStatus sourceMatrixStatus;
  final NarrowInternalNonLabelAnalysisPrototypeStatus sourcePrototypeStatus;
  final InternalNonLabelPrototypeReadinessStatus sourceReadinessStatus;
  final List<InternalPacketStabilityRecord> records;
  final List<InternalPacketStabilityPrototypeValidationFinding>
  validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalStabilityRecords;
  final int stableCount;
  final int stableNarrowCount;
  final int stableWithWarningsCount;
  final int proofLimitedStableCount;
  final int warningLimitedCount;
  final int blockedOrFutureOnlyCount;
  final int unstableCount;
  final int unsafeCount;
  final List<String> uniqueSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> coverageGapIds;
  final bool safeForPhase32D;
  final InternalPacketStabilityPhase32DRecommendation phase32DRecommendation;
  final bool developerOnly;
  final bool productLabelsEmitted;
  final bool classifierLabelsEmitted;
  final bool finalMoveLabelsEmitted;
  final bool officialMetricsAllowed;
  final bool cpLossComputationImplemented;
  final bool winProbabilityComputationImplemented;
  final bool numericMoveValuesComputed;
  final bool moveOrderingComputed;
  final bool directEngineAccessUsed;
  final bool uiOutputUsed;
  final bool backendOutputUsed;
  final bool persistenceUsed;
  final List<String> emittedOutputFamilies;

  bool get isStrictlyBlocked =>
      prototypeStatus ==
          InternalPacketStabilityPrototypeStatus.blockedByMatrix ||
      prototypeStatus ==
          InternalPacketStabilityPrototypeStatus.blockedByValidation ||
      prototypeStatus == InternalPacketStabilityPrototypeStatus.unsafe ||
      prototypeStatus == InternalPacketStabilityPrototypeStatus.invalid ||
      !safeForPhase32D ||
      unstableCount > 0 ||
      unsafeCount > 0;

  bool get hasUnsafeStabilityPolicyViolation {
    return unsafeCount > 0 ||
        validationFindings.any((finding) => finding.isCritical) ||
        records.any(
          (record) => record.stabilityStatus.isUnsafe || record.hasUnsafeOutput,
        ) ||
        productLabelsEmitted ||
        classifierLabelsEmitted ||
        finalMoveLabelsEmitted ||
        officialMetricsAllowed ||
        cpLossComputationImplemented ||
        winProbabilityComputationImplemented ||
        numericMoveValuesComputed ||
        moveOrderingComputed ||
        directEngineAccessUsed ||
        uiOutputUsed ||
        backendOutputUsed ||
        persistenceUsed ||
        emittedOutputFamilies.any(_isForbiddenOutputName);
  }

  List<InternalPacketStabilityRecord> get corePacketRecords =>
      records.where((record) => record.isCorePacket).toList(growable: false);

  List<InternalPacketStabilityRecord> get stablePacketRecords =>
      corePacketRecords
          .where(
            (record) =>
                record.stabilityStatus == InternalPacketStabilityStatus.stable,
          )
          .toList(growable: false);

  List<InternalPacketStabilityRecord> get stableNarrowRecords =>
      corePacketRecords
          .where(
            (record) =>
                record.stabilityStatus ==
                InternalPacketStabilityStatus.stableNarrow,
          )
          .toList(growable: false);

  List<InternalPacketStabilityRecord> get stableWithWarningsRecords =>
      corePacketRecords
          .where(
            (record) =>
                record.stabilityStatus ==
                InternalPacketStabilityStatus.stableWithWarnings,
          )
          .toList(growable: false);

  List<InternalPacketStabilityRecord> get proofLimitedStableRecords =>
      corePacketRecords
          .where(
            (record) =>
                record.stabilityStatus ==
                InternalPacketStabilityStatus.proofLimitedStable,
          )
          .toList(growable: false);

  List<InternalPacketStabilityRecord> get warningLimitedRecords => records
      .where((record) => record.isWarningLimitedScope)
      .toList(growable: false);

  List<InternalPacketStabilityRecord> get blockedOrFutureOnlyRecords => records
      .where((record) => record.isBlockedOrFutureOnly)
      .toList(growable: false);

  InternalPacketStabilityRecord record(
    InternalNonLabelPrototypeScopeId scopeId,
  ) {
    return records.singleWhere((record) => record.scopeId == scopeId);
  }

  InternalPacketStabilityPrototypeResult copyWith({
    InternalPacketStabilityPrototypeStatus? prototypeStatus,
    InternalPacketReviewAggregationMatrixStatus? sourceMatrixStatus,
    NarrowInternalNonLabelAnalysisPrototypeStatus? sourcePrototypeStatus,
    InternalNonLabelPrototypeReadinessStatus? sourceReadinessStatus,
    List<InternalPacketStabilityRecord>? records,
    List<InternalPacketStabilityPrototypeValidationFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalStabilityRecords,
    int? stableCount,
    int? stableNarrowCount,
    int? stableWithWarningsCount,
    int? proofLimitedStableCount,
    int? warningLimitedCount,
    int? blockedOrFutureOnlyCount,
    int? unstableCount,
    int? unsafeCount,
    List<String>? uniqueSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? coverageGapIds,
    bool? safeForPhase32D,
    InternalPacketStabilityPhase32DRecommendation? phase32DRecommendation,
    bool? developerOnly,
    bool? productLabelsEmitted,
    bool? classifierLabelsEmitted,
    bool? finalMoveLabelsEmitted,
    bool? officialMetricsAllowed,
    bool? cpLossComputationImplemented,
    bool? winProbabilityComputationImplemented,
    bool? numericMoveValuesComputed,
    bool? moveOrderingComputed,
    bool? directEngineAccessUsed,
    bool? uiOutputUsed,
    bool? backendOutputUsed,
    bool? persistenceUsed,
    List<String>? emittedOutputFamilies,
  }) {
    return InternalPacketStabilityPrototypeResult(
      prototypeStatus: prototypeStatus ?? this.prototypeStatus,
      sourceMatrixStatus: sourceMatrixStatus ?? this.sourceMatrixStatus,
      sourcePrototypeStatus:
          sourcePrototypeStatus ?? this.sourcePrototypeStatus,
      sourceReadinessStatus:
          sourceReadinessStatus ?? this.sourceReadinessStatus,
      records: records ?? this.records,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalStabilityRecords:
          totalStabilityRecords ?? this.totalStabilityRecords,
      stableCount: stableCount ?? this.stableCount,
      stableNarrowCount: stableNarrowCount ?? this.stableNarrowCount,
      stableWithWarningsCount:
          stableWithWarningsCount ?? this.stableWithWarningsCount,
      proofLimitedStableCount:
          proofLimitedStableCount ?? this.proofLimitedStableCount,
      warningLimitedCount: warningLimitedCount ?? this.warningLimitedCount,
      blockedOrFutureOnlyCount:
          blockedOrFutureOnlyCount ?? this.blockedOrFutureOnlyCount,
      unstableCount: unstableCount ?? this.unstableCount,
      unsafeCount: unsafeCount ?? this.unsafeCount,
      uniqueSupportCaseIds: uniqueSupportCaseIds ?? this.uniqueSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      coverageGapIds: coverageGapIds ?? this.coverageGapIds,
      safeForPhase32D: safeForPhase32D ?? this.safeForPhase32D,
      phase32DRecommendation:
          phase32DRecommendation ?? this.phase32DRecommendation,
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
      numericMoveValuesComputed:
          numericMoveValuesComputed ?? this.numericMoveValuesComputed,
      moveOrderingComputed: moveOrderingComputed ?? this.moveOrderingComputed,
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
      ..writeln('# Internal Packet Stability Prototype')
      ..writeln()
      ..writeln('- version: $internalPacketStabilityPrototypeReportVersion')
      ..writeln('- prototype status: ${prototypeStatus.wire}')
      ..writeln('- source matrix status: ${sourceMatrixStatus.wire}')
      ..writeln('- source prototype status: ${sourcePrototypeStatus.wire}')
      ..writeln('- source readiness status: ${sourceReadinessStatus.wire}')
      ..writeln('- total stability records: $totalStabilityRecords')
      ..writeln('- stable count: $stableCount')
      ..writeln('- stable narrow count: $stableNarrowCount')
      ..writeln('- stable with warnings count: $stableWithWarningsCount')
      ..writeln('- proof-limited stable count: $proofLimitedStableCount')
      ..writeln('- warning-limited count: $warningLimitedCount')
      ..writeln('- blocked or future-only count: $blockedOrFutureOnlyCount')
      ..writeln('- unstable count: $unstableCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- safe for Phase 32D: $safeForPhase32D')
      ..writeln('- Phase 32D recommendation: ${phase32DRecommendation.wire}')
      ..writeln('- classifier output emitted: $classifierLabelsEmitted')
      ..writeln('- numeric value output emitted: $numericMoveValuesComputed')
      ..writeln('- move ordering output emitted: $moveOrderingComputed')
      ..writeln()
      ..writeln('## Stability Policy')
      ..writeln('- this prototype stabilizes internal packet behavior only')
      ..writeln(
        '- it does not classify moves, compute values, order moves, call an engine, integrate product output, or write files',
      )
      ..writeln()
      ..writeln('## Stability Table')
      ..writeln(
        '| Record | Scope | Stability | Source Review | Confidence | Support Cases | Android Proof | Signals | Areas | Buckets | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final record in records) {
      buffer.writeln(
        '| ${record.recordId} | ${record.scopeId.wire} | ${record.stabilityStatus.wire} | ${record.sourceReviewStatus.wire} | ${record.qualitativeConfidence.wire} | ${_ids(record.supportCaseIds)} | ${_ids(record.androidProofCaseIds)} | ${_signalIds(record.activeSignalIds)} | ${_areaIds(record.evidenceAreaIds)} | ${_bucketIds(record.bucketIds)} | ${record.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Aggregate Counts')
      ..writeln('- total stability records: $totalStabilityRecords')
      ..writeln('- stable count: $stableCount')
      ..writeln('- stable narrow count: $stableNarrowCount')
      ..writeln('- stable with warnings count: $stableWithWarningsCount')
      ..writeln('- proof-limited stable count: $proofLimitedStableCount')
      ..writeln('- warning-limited count: $warningLimitedCount')
      ..writeln('- blocked or future-only count: $blockedOrFutureOnlyCount')
      ..writeln('- unstable count: $unstableCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln()
      ..writeln('## Stable Packets')
      ..writeln('- ${_recordIds(stablePacketRecords)}')
      ..writeln()
      ..writeln('## Stable Narrow Packets')
      ..writeln('- ${_recordIds(stableNarrowRecords)}')
      ..writeln()
      ..writeln('## Stable With Warnings Packets')
      ..writeln('- ${_recordIds(stableWithWarningsRecords)}')
      ..writeln()
      ..writeln('## Proof-Limited Stable Packets')
      ..writeln('- ${_recordIds(proofLimitedStableRecords)}')
      ..writeln()
      ..writeln('## Warning-Limited Scopes')
      ..writeln('- ${_scopeIds(warningLimitedRecords)}')
      ..writeln()
      ..writeln('## Blocked And Future-Only Scopes')
      ..writeln('- ${_scopeIds(blockedOrFutureOnlyRecords)}')
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
      ..writeln('## Phase 32D Recommendation')
      ..writeln(phase32DRecommendation.wire)
      ..writeln()
      ..writeln(
        'This prototype preserves internal-only packet stability. It does not emit user-facing output, compute product metrics, call the engine, run Android, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': internalPacketStabilityPrototypeReportVersion,
      'prototypeStatus': prototypeStatus.wire,
      'sourceMatrixStatus': sourceMatrixStatus.wire,
      'sourcePrototypeStatus': sourcePrototypeStatus.wire,
      'sourceReadinessStatus': sourceReadinessStatus.wire,
      'totalStabilityRecords': totalStabilityRecords,
      'stableCount': stableCount,
      'stableNarrowCount': stableNarrowCount,
      'stableWithWarningsCount': stableWithWarningsCount,
      'proofLimitedStableCount': proofLimitedStableCount,
      'warningLimitedCount': warningLimitedCount,
      'blockedOrFutureOnlyCount': blockedOrFutureOnlyCount,
      'unstableCount': unstableCount,
      'unsafeCount': unsafeCount,
      'uniqueSupportCaseIds': uniqueSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'coverageGapIds': coverageGapIds,
      'safeForPhase32D': safeForPhase32D,
      'phase32DRecommendation': phase32DRecommendation.wire,
      'records': records.map((record) => record.toJson()).toList(),
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
      'numericMoveValuesComputed': numericMoveValuesComputed,
      'moveOrderingComputed': moveOrderingComputed,
      'directEngineAccessUsed': directEngineAccessUsed,
      'uiOutputUsed': uiOutputUsed,
      'backendOutputUsed': backendOutputUsed,
      'persistenceUsed': persistenceUsed,
      'emittedOutputFamilies': emittedOutputFamilies,
    };
  }
}

class InternalPacketStabilityPrototype {
  const InternalPacketStabilityPrototype({
    this.validator = const InternalPacketStabilityPrototypeValidator(),
  });

  final InternalPacketStabilityPrototypeValidator validator;

  InternalPacketStabilityPrototypeResult evaluate([
    InternalPacketStabilityPrototypeRequest request =
        const InternalPacketStabilityPrototypeRequest(),
  ]) {
    final readinessResult =
        request.readinessResult ??
        request.readinessGate.evaluate(
          InternalNonLabelPrototypeReadinessGateRequest(
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
          ),
        );
    final prototypeResult =
        request.prototypeResult ??
        request.prototype.run(
          NarrowInternalNonLabelAnalysisPrototypeRequest(
            readinessResult: readinessResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
          ),
        );
    final matrixResult =
        request.matrixResult ??
        request.matrix.evaluate(
          InternalPacketReviewAggregationMatrixRequest(
            prototypeResult: prototypeResult,
            readinessResult: readinessResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarningLimitedScopes: request.includeWarningLimitedScopes,
            includeBlockedScopes: request.includeBlockedScopes,
            includeFutureOnlyScopes: request.includeFutureOnlyScopes,
          ),
        );
    final provenAndroidIds = _provenAndroidProofIds(
      request.androidProofEvidence,
    );
    final records = _recordsFromMatrix(matrixResult, provenAndroidIds);
    final base = _resultFromRecords(
      records: records,
      matrixResult: matrixResult,
      prototypeResult: prototypeResult,
      readinessResult: readinessResult,
      validationFindings:
          const <InternalPacketStabilityPrototypeValidationFinding>[],
    );
    final findings = validator.validate(
      base,
      matrixResult: matrixResult,
      prototypeResult: prototypeResult,
      readinessResult: readinessResult,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromRecords(
      records: records,
      matrixResult: matrixResult,
      prototypeResult: prototypeResult,
      readinessResult: readinessResult,
      validationFindings: findings,
    );
  }
}

class InternalPacketStabilityPrototypeValidator {
  const InternalPacketStabilityPrototypeValidator();

  List<InternalPacketStabilityPrototypeValidationFinding> validate(
    InternalPacketStabilityPrototypeResult result, {
    required InternalPacketReviewAggregationMatrixResult matrixResult,
    required NarrowInternalNonLabelAnalysisPrototypeResult prototypeResult,
    required InternalNonLabelPrototypeReadinessResult readinessResult,
    required List<GoldenAnalysisCase> cases,
    required GoldenAndroidProofEvidence? androidProofEvidence,
  }) {
    final findings = <InternalPacketStabilityPrototypeValidationFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    final goldenCaseIds = cases.map((item) => item.id).toSet();

    void add({
      required String id,
      required InternalPacketStabilityValidationSeverity severity,
      required String message,
      String? recordId,
      String? packetId,
      InternalNonLabelPrototypeScopeId? scopeId,
      InternalNonLabelSignalId? signalId,
      String? caseId,
    }) {
      findings.add(
        InternalPacketStabilityPrototypeValidationFinding(
          id: id,
          severity: severity,
          message: message,
          recordId: recordId,
          packetId: packetId,
          scopeId: scopeId,
          signalId: signalId,
          caseId: caseId,
        ),
      );
    }

    if (matrixResult.isStrictlyBlocked && result.corePacketRecords.isNotEmpty) {
      add(
        id: 'sourceMatrixBlockedForStability',
        severity: InternalPacketStabilityValidationSeverity.blocker,
        message: 'source matrix is not safe for packet stability',
      );
    }
    if (matrixResult.hasUnsafeMatrixPolicyViolation) {
      add(
        id: 'sourceMatrixUnsafeForStability',
        severity: InternalPacketStabilityValidationSeverity.critical,
        message: 'source matrix crossed a blocked output boundary',
      );
    }
    if (prototypeResult.hasUnsafePrototypePolicyViolation ||
        readinessResult.hasUnsafeReadinessPolicyViolation) {
      add(
        id: 'upstreamPrototypeUnsafeForStability',
        severity: InternalPacketStabilityValidationSeverity.critical,
        message: 'upstream prototype or readiness gate is unsafe',
      );
    }

    for (final record in result.records) {
      if (record.hasUnsafeOutput) {
        add(
          id: 'recordUnsafeOutputBoundary',
          severity: InternalPacketStabilityValidationSeverity.critical,
          message: '${record.recordId} crossed a blocked output boundary',
          recordId: record.recordId,
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      if (record.isCorePacket &&
          !_allowedPacketScopes.contains(record.scopeId)) {
        add(
          id: _warningLimitedPrototypeScopes.contains(record.scopeId)
              ? 'warningLimitedScopePromotedToStablePacket'
              : 'blockedScopePromotedToStablePacket',
          severity: InternalPacketStabilityValidationSeverity.blocker,
          message: '${record.scopeId.wire} cannot become a stable packet',
          recordId: record.recordId,
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      final sourceWasStable =
          record.isCorePacket && record.sourceReviewStatus.isStablePacket;
      if (record.stabilityStatus.isStableCore || sourceWasStable) {
        if (record.supportCaseIds.isEmpty) {
          add(
            id: 'stableRecordWithoutSupportCases',
            severity: InternalPacketStabilityValidationSeverity.blocker,
            message: '${record.recordId} lacks supporting Golden cases',
            recordId: record.recordId,
            packetId: record.packetId,
            scopeId: record.scopeId,
          );
        }
        if (record.activeSignalIds.isEmpty) {
          add(
            id: 'stableRecordWithoutActiveSignals',
            severity: InternalPacketStabilityValidationSeverity.blocker,
            message: '${record.recordId} lacks active signal mapping',
            recordId: record.recordId,
            packetId: record.packetId,
            scopeId: record.scopeId,
          );
        }
        if (record.evidenceAreaIds.isEmpty) {
          add(
            id: 'stableRecordWithoutEvidenceAreas',
            severity: InternalPacketStabilityValidationSeverity.blocker,
            message: '${record.recordId} lacks evidence area mapping',
            recordId: record.recordId,
            packetId: record.packetId,
            scopeId: record.scopeId,
          );
        }
        if (record.bucketIds.isEmpty) {
          add(
            id: 'stableRecordWithoutBuckets',
            severity: InternalPacketStabilityValidationSeverity.blocker,
            message: '${record.recordId} lacks bucket mapping',
            recordId: record.recordId,
            packetId: record.packetId,
            scopeId: record.scopeId,
          );
        }
      }
      if (record.stabilityStatus ==
              InternalPacketStabilityStatus.proofLimitedStable &&
          record.androidProofCaseIds.isEmpty) {
        add(
          id: 'proofLimitedStableRecordWithoutProofIds',
          severity: InternalPacketStabilityValidationSeverity.blocker,
          message: '${record.recordId} lacks proof IDs',
          recordId: record.recordId,
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      if (record.quietScopeActive ||
          (record.isCorePacket &&
              record.scopeId ==
                  InternalNonLabelPrototypeScopeId
                      .quietPreparatoryPrototypeScope)) {
        add(
          id: 'quietPreparatoryRecordActivated',
          severity: InternalPacketStabilityValidationSeverity.critical,
          message: '${record.recordId} activated quiet or preparatory scope',
          recordId: record.recordId,
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      if (record.cpLossComputationImplemented ||
          record.winProbabilityComputationImplemented) {
        add(
          id: 'futureComputationActivated',
          severity: InternalPacketStabilityValidationSeverity.critical,
          message: '${record.recordId} activated a future computation',
          recordId: record.recordId,
          packetId: record.packetId,
          scopeId: record.scopeId,
        );
      }
      for (final caseId in record.supportCaseIds) {
        if (!goldenCaseIds.contains(caseId)) {
          add(
            id: 'unknownSupportCaseId',
            severity: InternalPacketStabilityValidationSeverity.blocker,
            message: '${record.recordId} cited an unknown support case',
            recordId: record.recordId,
            packetId: record.packetId,
            scopeId: record.scopeId,
            caseId: caseId,
          );
        }
      }
      for (final caseId in record.androidProofCaseIds) {
        if (!_capturedAndroidProofIds.contains(caseId) ||
            !provenAndroidIds.contains(caseId)) {
          add(
            id: 'unprovenAndroidProofCitation',
            severity: InternalPacketStabilityValidationSeverity.blocker,
            message: '${record.recordId} cited unproven Android proof',
            recordId: record.recordId,
            packetId: record.packetId,
            scopeId: record.scopeId,
            caseId: caseId,
          );
        }
      }
    }

    final promotedWarningScopes = result.records.where(
      (record) =>
          record.isCorePacket &&
          _warningLimitedPrototypeScopes.contains(record.scopeId),
    );
    for (final record in promotedWarningScopes) {
      add(
        id: 'warningLimitedScopeCannotBecomeStablePacket',
        severity: InternalPacketStabilityValidationSeverity.blocker,
        message: '${record.scopeId.wire} must remain warning-limited',
        recordId: record.recordId,
        packetId: record.packetId,
        scopeId: record.scopeId,
      );
    }

    if (result.productLabelsEmitted ||
        result.classifierLabelsEmitted ||
        result.finalMoveLabelsEmitted ||
        result.officialMetricsAllowed ||
        result.cpLossComputationImplemented ||
        result.winProbabilityComputationImplemented ||
        result.numericMoveValuesComputed ||
        result.moveOrderingComputed ||
        result.directEngineAccessUsed ||
        result.uiOutputUsed ||
        result.backendOutputUsed ||
        result.persistenceUsed ||
        result.emittedOutputFamilies.any(_isForbiddenOutputName)) {
      add(
        id: 'stabilityBoundaryPolicyViolation',
        severity: InternalPacketStabilityValidationSeverity.critical,
        message: 'stability prototype crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<InternalPacketStabilityPrototypeValidationFinding> validateReportText(
    String reportText,
  ) {
    final findings = <InternalPacketStabilityPrototypeValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        InternalPacketStabilityPrototypeValidationFinding(
          id: id,
          severity: InternalPacketStabilityValidationSeverity.critical,
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

List<InternalPacketStabilityRecord> _recordsFromMatrix(
  InternalPacketReviewAggregationMatrixResult matrixResult,
  Set<String> provenAndroidIds,
) {
  final records = matrixResult.rows
      .map((row) => _recordFromReviewRow(row, provenAndroidIds))
      .toList();
  records.sort((a, b) => a.scopeId.index.compareTo(b.scopeId.index));
  return List<InternalPacketStabilityRecord>.unmodifiable(records);
}

InternalPacketStabilityRecord _recordFromReviewRow(
  InternalPacketReviewAggregationRow row,
  Set<String> provenAndroidIds,
) {
  final status = _stabilityStatusFor(row, provenAndroidIds);
  return InternalPacketStabilityRecord(
    recordId: row.isCorePacket ? row.packetId : row.allowedScopeId.wire,
    packetId: row.isCorePacket ? row.packetId : null,
    scopeId: row.allowedScopeId,
    stabilityStatus: status,
    sourceReviewStatus: row.reviewStatus,
    supportCaseIds: row.supportCaseIds,
    androidProofCaseIds: row.androidProofCaseIds,
    activeSignalIds: row.activeSignalIds,
    evidenceAreaIds: row.evidenceAreaIds,
    bucketIds: row.bucketIds,
    qualitativeConfidence: row.qualitativeConfidence,
    stabilityReason: _stabilityReasonFor(row, status),
    warningReason: row.warningReasons.isEmpty ? '' : _ids(row.warningReasons),
    proofLimitReason: _proofLimitReasonFor(row, status),
    coverageGapIds: row.coverageGapIds,
    blockedBoundaryIds: row.blockedBoundaryIds,
    futurePrerequisites: row.futurePrerequisites,
    recommendation: _recommendationFor(status),
    isCorePacket: row.isCorePacket,
    isProductOutput: row.isProductOutput,
    isClassifierLabel: row.isClassifierLabel,
    isOfficialMetric: row.isOfficialMetric,
    hasNumericValue: row.hasNumericScore,
    ordersMoves: row.ranksMoves,
    quietScopeActive: row.quietScopeActive,
    cpLossComputationImplemented: row.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        row.winProbabilityComputationImplemented,
    emittedOutputNames: row.emittedOutputNames,
  );
}

InternalPacketStabilityStatus _stabilityStatusFor(
  InternalPacketReviewAggregationRow row,
  Set<String> provenAndroidIds,
) {
  final proofValid = row.androidProofCaseIds.every(
    (caseId) =>
        _capturedAndroidProofIds.contains(caseId) &&
        provenAndroidIds.contains(caseId),
  );
  final hasStableMapping =
      row.supportCaseIds.isNotEmpty &&
      row.activeSignalIds.isNotEmpty &&
      row.evidenceAreaIds.isNotEmpty &&
      row.bucketIds.isNotEmpty;
  if (row.hasUnsafeOutput ||
      row.quietScopeActive ||
      row.cpLossComputationImplemented ||
      row.winProbabilityComputationImplemented ||
      !proofValid) {
    return InternalPacketStabilityStatus.unsafe;
  }
  if (row.isCorePacket && !_allowedPacketScopes.contains(row.allowedScopeId)) {
    return InternalPacketStabilityStatus.unsafe;
  }
  return switch (row.reviewStatus) {
    InternalPacketReviewStatus.stable =>
      hasStableMapping
          ? InternalPacketStabilityStatus.stable
          : InternalPacketStabilityStatus.invalid,
    InternalPacketReviewStatus.stableNarrow =>
      hasStableMapping
          ? InternalPacketStabilityStatus.stableNarrow
          : InternalPacketStabilityStatus.invalid,
    InternalPacketReviewStatus.stableWithWarnings =>
      hasStableMapping
          ? InternalPacketStabilityStatus.stableWithWarnings
          : InternalPacketStabilityStatus.invalid,
    InternalPacketReviewStatus.needsMoreGoldenCoverage =>
      InternalPacketStabilityStatus.unstable,
    InternalPacketReviewStatus.proofLimited =>
      hasStableMapping && row.androidProofCaseIds.isNotEmpty
          ? InternalPacketStabilityStatus.proofLimitedStable
          : InternalPacketStabilityStatus.invalid,
    InternalPacketReviewStatus.warningOnly =>
      row.isCorePacket
          ? InternalPacketStabilityStatus.unsafe
          : InternalPacketStabilityStatus.warningLimitedOnly,
    InternalPacketReviewStatus.blockedCorrectly =>
      row.isCorePacket
          ? InternalPacketStabilityStatus.unsafe
          : InternalPacketStabilityStatus.blockedCorrectly,
    InternalPacketReviewStatus.futureOnlyCorrectly =>
      row.isCorePacket
          ? InternalPacketStabilityStatus.unsafe
          : InternalPacketStabilityStatus.futureOnlyCorrectly,
    InternalPacketReviewStatus.unsafe => InternalPacketStabilityStatus.unsafe,
    InternalPacketReviewStatus.invalid => InternalPacketStabilityStatus.invalid,
  };
}

String _stabilityReasonFor(
  InternalPacketReviewAggregationRow row,
  InternalPacketStabilityStatus status,
) {
  return switch (status) {
    InternalPacketStabilityStatus.stable =>
      'source packet reviewed stable with current Golden support',
    InternalPacketStabilityStatus.stableNarrow =>
      'source packet reviewed stable but narrow',
    InternalPacketStabilityStatus.stableWithWarnings =>
      'source packet remains stable with warnings visible',
    InternalPacketStabilityStatus.proofLimitedStable =>
      'source packet remains stable only within captured Android proof IDs',
    InternalPacketStabilityStatus.warningLimitedOnly =>
      'scope remains outside core packet generation with coverage gaps visible',
    InternalPacketStabilityStatus.blockedCorrectly =>
      'scope remains inactive under policy boundary',
    InternalPacketStabilityStatus.futureOnlyCorrectly =>
      'scope remains inactive until future prerequisites are met',
    InternalPacketStabilityStatus.unstable =>
      'source packet needs more Golden coverage before stabilization',
    InternalPacketStabilityStatus.unsafe =>
      '${row.allowedScopeId.wire} crossed a blocked stability boundary',
    InternalPacketStabilityStatus.invalid =>
      '${row.allowedScopeId.wire} lacks required support or mapping',
  };
}

String _proofLimitReasonFor(
  InternalPacketReviewAggregationRow row,
  InternalPacketStabilityStatus status,
) {
  if (status == InternalPacketStabilityStatus.proofLimitedStable) {
    return 'limited to captured Android proof IDs only';
  }
  if (row.androidProofCaseIds.isNotEmpty &&
      row.allowedScopeId ==
          InternalNonLabelPrototypeScopeId
              .pvMultiPvSupportInternalPrototypeScope) {
    return 'uses captured Android proof as supporting evidence only';
  }
  return '';
}

InternalPacketStabilityRecommendation _recommendationFor(
  InternalPacketStabilityStatus status,
) {
  return switch (status) {
    InternalPacketStabilityStatus.stable =>
      InternalPacketStabilityRecommendation.preserveStablePacket,
    InternalPacketStabilityStatus.stableNarrow =>
      InternalPacketStabilityRecommendation.preserveStableNarrowPacket,
    InternalPacketStabilityStatus.stableWithWarnings =>
      InternalPacketStabilityRecommendation.preserveStablePacket,
    InternalPacketStabilityStatus.proofLimitedStable =>
      InternalPacketStabilityRecommendation.preserveProofLimitedPacket,
    InternalPacketStabilityStatus.warningLimitedOnly =>
      InternalPacketStabilityRecommendation.keepWarningLimited,
    InternalPacketStabilityStatus.blockedCorrectly =>
      InternalPacketStabilityRecommendation.keepBlockedByPolicy,
    InternalPacketStabilityStatus.futureOnlyCorrectly =>
      InternalPacketStabilityRecommendation.keepFutureOnly,
    InternalPacketStabilityStatus.unstable =>
      InternalPacketStabilityRecommendation.addGoldenCoverage,
    InternalPacketStabilityStatus.unsafe ||
    InternalPacketStabilityStatus.invalid =>
      InternalPacketStabilityRecommendation.investigateInstability,
  };
}

InternalPacketStabilityPrototypeResult _resultFromRecords({
  required List<InternalPacketStabilityRecord> records,
  required InternalPacketReviewAggregationMatrixResult matrixResult,
  required NarrowInternalNonLabelAnalysisPrototypeResult prototypeResult,
  required InternalNonLabelPrototypeReadinessResult readinessResult,
  required List<InternalPacketStabilityPrototypeValidationFinding>
  validationFindings,
}) {
  final stableCount = records
      .where(
        (record) =>
            record.stabilityStatus == InternalPacketStabilityStatus.stable,
      )
      .length;
  final stableNarrowCount = records
      .where(
        (record) =>
            record.stabilityStatus ==
            InternalPacketStabilityStatus.stableNarrow,
      )
      .length;
  final stableWithWarningsCount = records
      .where(
        (record) =>
            record.stabilityStatus ==
            InternalPacketStabilityStatus.stableWithWarnings,
      )
      .length;
  final proofLimitedStableCount = records
      .where(
        (record) =>
            record.stabilityStatus ==
            InternalPacketStabilityStatus.proofLimitedStable,
      )
      .length;
  final warningLimitedCount = records
      .where(
        (record) =>
            record.stabilityStatus ==
            InternalPacketStabilityStatus.warningLimitedOnly,
      )
      .length;
  final blockedOrFutureOnlyCount = records
      .where((record) => record.stabilityStatus.isBlockedOrFutureOnly)
      .length;
  final unstableCount = records
      .where(
        (record) =>
            record.stabilityStatus == InternalPacketStabilityStatus.unstable,
      )
      .length;
  final unsafeCount = records
      .where((record) => record.stabilityStatus.isUnsafe)
      .length;
  final warnings = _sortedStrings(<String>[
    ...matrixResult.warnings,
    ...prototypeResult.warnings,
    ...readinessResult.warnings,
    ...records
        .where((record) => record.warningReason.isNotEmpty)
        .map((record) => record.warningReason),
  ]);
  final failures = _sortedStrings(<String>[
    ...matrixResult.failures,
    ...prototypeResult.failures,
    ...readinessResult.failures,
    ...validationFindings.map((finding) => finding.message),
  ]);
  final safeForPhase32D =
      matrixResult.safeForPhase32C &&
      matrixResult.phase32CRecommendation ==
          InternalPacketReviewPhase32CRecommendation
              .proceedToInternalPacketStabilityPrototype &&
      !matrixResult.hasUnsafeMatrixPolicyViolation &&
      !prototypeResult.hasUnsafePrototypePolicyViolation &&
      !readinessResult.hasUnsafeReadinessPolicyViolation &&
      !validationFindings.any((finding) => finding.blocksStrict) &&
      unstableCount == 0 &&
      unsafeCount == 0 &&
      records.where((record) => record.isCorePacket).length ==
          matrixResult.totalPackets;
  final base = InternalPacketStabilityPrototypeResult(
    prototypeStatus: InternalPacketStabilityPrototypeStatus.stableInternalOnly,
    sourceMatrixStatus: matrixResult.matrixStatus,
    sourcePrototypeStatus: prototypeResult.prototypeStatus,
    sourceReadinessStatus: readinessResult.overallStatus,
    records: records,
    validationFindings: validationFindings,
    warnings: warnings,
    failures: failures,
    totalStabilityRecords: records.length,
    stableCount: stableCount,
    stableNarrowCount: stableNarrowCount,
    stableWithWarningsCount: stableWithWarningsCount,
    proofLimitedStableCount: proofLimitedStableCount,
    warningLimitedCount: warningLimitedCount,
    blockedOrFutureOnlyCount: blockedOrFutureOnlyCount,
    unstableCount: unstableCount,
    unsafeCount: unsafeCount,
    uniqueSupportCaseIds: _sortedStrings(
      records.expand((record) => record.supportCaseIds),
    ),
    androidProofCaseIds: _sortedStrings(
      records.expand((record) => record.androidProofCaseIds),
    ),
    coverageGapIds: _sortedStrings(<String>[
      ...matrixResult.coverageGapIds,
      ...prototypeResult.coverageGapIds,
      ...readinessResult.coverageGapIds,
      ...records.expand((record) => record.coverageGapIds),
    ]),
    safeForPhase32D: safeForPhase32D,
    phase32DRecommendation: InternalPacketStabilityPhase32DRecommendation
        .proceedToInternalPacketEvidenceHardeningPlan,
    productLabelsEmitted:
        matrixResult.productLabelsEmitted ||
        prototypeResult.productLabelsEmitted ||
        readinessResult.productLabelsEmitted,
    classifierLabelsEmitted:
        matrixResult.classifierLabelsEmitted ||
        prototypeResult.classifierLabelsEmitted ||
        readinessResult.classifierLabelsEmitted,
    finalMoveLabelsEmitted:
        matrixResult.finalMoveLabelsEmitted ||
        prototypeResult.finalMoveLabelsEmitted ||
        readinessResult.finalMoveLabelsEmitted,
    officialMetricsAllowed:
        matrixResult.officialMetricsAllowed ||
        prototypeResult.officialMetricsAllowed ||
        readinessResult.officialMetricsAllowed,
    cpLossComputationImplemented:
        matrixResult.cpLossComputationImplemented ||
        prototypeResult.cpLossComputationImplemented ||
        readinessResult.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        matrixResult.winProbabilityComputationImplemented ||
        prototypeResult.winProbabilityComputationImplemented ||
        readinessResult.winProbabilityComputationImplemented,
    numericMoveValuesComputed:
        matrixResult.numericMoveScoresComputed ||
        prototypeResult.numericMoveScoresComputed ||
        readinessResult.numericMoveScoresComputed,
    moveOrderingComputed:
        matrixResult.moveRankingComputed ||
        prototypeResult.moveRankingComputed ||
        readinessResult.moveRankingComputed,
    directEngineAccessUsed:
        matrixResult.directEngineAccessUsed ||
        prototypeResult.directEngineAccessUsed ||
        readinessResult.directEngineAccessUsed,
    uiOutputUsed:
        matrixResult.uiOutputUsed ||
        prototypeResult.uiOutputUsed ||
        readinessResult.uiOutputUsed,
    backendOutputUsed:
        matrixResult.backendOutputUsed ||
        prototypeResult.backendOutputUsed ||
        readinessResult.backendOutputUsed,
    persistenceUsed:
        matrixResult.persistenceUsed ||
        prototypeResult.persistenceUsed ||
        readinessResult.persistenceUsed,
    emittedOutputFamilies: _sortedStrings(<String>[
      ...matrixResult.emittedOutputFamilies,
      ...prototypeResult.emittedOutputFamilies,
      ...readinessResult.emittedOutputFamilies,
    ]),
  );
  return base.copyWith(
    prototypeStatus: _prototypeStatusFor(base),
    phase32DRecommendation: _phase32DRecommendationFor(base),
  );
}

InternalPacketStabilityPrototypeStatus _prototypeStatusFor(
  InternalPacketStabilityPrototypeResult result,
) {
  if (result.unsafeCount > 0 ||
      result.validationFindings.any((finding) => finding.isCritical) ||
      result.productLabelsEmitted ||
      result.classifierLabelsEmitted ||
      result.finalMoveLabelsEmitted ||
      result.officialMetricsAllowed ||
      result.cpLossComputationImplemented ||
      result.winProbabilityComputationImplemented ||
      result.numericMoveValuesComputed ||
      result.moveOrderingComputed ||
      result.directEngineAccessUsed ||
      result.uiOutputUsed ||
      result.backendOutputUsed ||
      result.persistenceUsed ||
      result.emittedOutputFamilies.any(_isForbiddenOutputName)) {
    return InternalPacketStabilityPrototypeStatus.unsafe;
  }
  if (result.validationFindings.any((finding) => finding.blocksStrict)) {
    return InternalPacketStabilityPrototypeStatus.blockedByValidation;
  }
  if (result.sourceMatrixStatus ==
          InternalPacketReviewAggregationMatrixStatus.blockedByPrototype ||
      result.sourceMatrixStatus ==
          InternalPacketReviewAggregationMatrixStatus.blockedByValidation ||
      result.sourceMatrixStatus ==
          InternalPacketReviewAggregationMatrixStatus.invalid) {
    return InternalPacketStabilityPrototypeStatus.blockedByMatrix;
  }
  if (result.records.isEmpty) {
    return InternalPacketStabilityPrototypeStatus.invalid;
  }
  if (result.warningLimitedCount > 0 ||
      result.coverageGapIds.isNotEmpty ||
      result.warnings.isNotEmpty ||
      result.proofLimitedStableCount > 0 ||
      result.stableWithWarningsCount > 0) {
    return InternalPacketStabilityPrototypeStatus.stableWithWarnings;
  }
  return InternalPacketStabilityPrototypeStatus.stableInternalOnly;
}

InternalPacketStabilityPhase32DRecommendation _phase32DRecommendationFor(
  InternalPacketStabilityPrototypeResult result,
) {
  if (result.unsafeCount > 0 ||
      result.validationFindings.any((finding) => finding.isCritical) ||
      result.hasUnsafeStabilityPolicyViolation) {
    return InternalPacketStabilityPhase32DRecommendation.blockedByUnsafeOutput;
  }
  if (result.unstableCount > 0) {
    return InternalPacketStabilityPhase32DRecommendation
        .investigateInstabilityFirst;
  }
  if (result.validationFindings.any((finding) => finding.blocksStrict)) {
    return InternalPacketStabilityPhase32DRecommendation.addGoldenCoverageFirst;
  }
  if (!result.safeForPhase32D) {
    return InternalPacketStabilityPhase32DRecommendation
        .keepNarrowPrototypeOnly;
  }
  return InternalPacketStabilityPhase32DRecommendation
      .proceedToInternalPacketEvidenceHardeningPlan;
}

Set<String> _provenAndroidProofIds(
  GoldenAndroidProofEvidence? androidProofEvidence,
) {
  final proofIds = androidProofEvidence?.targetCaseIds ?? const <String>[];
  return proofIds
      .where(
        (caseId) =>
            _capturedAndroidProofIds.contains(caseId) &&
            (androidProofEvidence?.isRealDeviceProofCapturedFor(
                  caseId,
                  minMultiPvLineCount: 1,
                  requirePv: true,
                ) ??
                false),
      )
      .toSet();
}

String _ids(Iterable<String> values) {
  final sorted = _sortedStrings(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

String _recordIds(Iterable<InternalPacketStabilityRecord> records) {
  final ids = records.map((record) => record.recordId).toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _scopeIds(Iterable<InternalPacketStabilityRecord> records) {
  final ids = records.map((record) => record.scopeId.wire).toList()..sort();
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
  InternalPacketStabilityPrototypeValidationFinding a,
  InternalPacketStabilityPrototypeValidationFinding b,
) {
  final idCompare = a.id.compareTo(b.id);
  if (idCompare != 0) return idCompare;
  final recordCompare = (a.recordId ?? '').compareTo(b.recordId ?? '');
  if (recordCompare != 0) return recordCompare;
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

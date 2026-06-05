/// Developer-only narrow internal non-label analysis prototype packets.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_experiment_runner.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_observation_review_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_profile_consistency_matrix.dart';

const narrowInternalNonLabelAnalysisPrototypeReportVersion =
    'narrow-internal-non-label-analysis-prototype-v1';

enum NarrowInternalNonLabelAnalysisPrototypeStatus {
  completedInternalPrototype('completedInternalPrototype'),
  completedWithCoverageWarnings('completedWithCoverageWarnings'),
  skippedByReadinessGate('skippedByReadinessGate'),
  blockedByPolicy('blockedByPolicy'),
  invalidRequest('invalidRequest'),
  failed('failed');

  const NarrowInternalNonLabelAnalysisPrototypeStatus(this.wire);

  final String wire;
}

enum NarrowInternalNonLabelAnalysisPrototypeReportFormat {
  markdown('markdown'),
  json('json');

  const NarrowInternalNonLabelAnalysisPrototypeReportFormat(this.wire);

  final String wire;
}

enum NarrowInternalNonLabelAnalysisPrototypeValidationSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const NarrowInternalNonLabelAnalysisPrototypeValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this ==
          NarrowInternalNonLabelAnalysisPrototypeValidationSeverity.blocker ||
      this ==
          NarrowInternalNonLabelAnalysisPrototypeValidationSeverity.critical;
}

enum NarrowInternalNonLabelAnalysisPrototypeNextRecommendation {
  internalPacketConsistencyReview(
    'Phase 32B -- Internal Prototype Packet Consistency Review',
  ),
  addGoldenCoverageBeforeExpansion(
    'Phase 32B -- Add Golden Coverage Before Expansion',
  ),
  fixPrototypeSafetyFirst('Phase 32B -- Prototype Safety Fixes');

  const NarrowInternalNonLabelAnalysisPrototypeNextRecommendation(this.wire);

  final String wire;
}

class NarrowInternalNonLabelAnalysisPrototypeRequest {
  const NarrowInternalNonLabelAnalysisPrototypeRequest({
    this.experimentId = 'phase-32a-safe-demo',
    this.includeWarningLimitedScopes = true,
    this.includeBlockedScopes = true,
    this.includeFutureOnlyScopes = true,
    this.includeAndroidProofReferences = true,
    this.strictReadinessRequired = true,
    this.notes = const <String>[],
    this.readinessResult,
    this.reviewResult,
    this.runnerResult,
    this.consistencyResult,
    this.profileResult,
    this.readinessGate = const InternalNonLabelPrototypeReadinessGate(),
    this.reviewMatrix = const InternalSignalObservationReviewMatrix(),
    this.runner = const InternalSignalExperimentRunner(),
    this.consistencyMatrix = const InternalSignalProfileConsistencyMatrix(),
    this.profile = const InternalNonLabelSignalProfilePrototype(),
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.cases = GoldenAnalysisCases.defaults,
  });

  NarrowInternalNonLabelAnalysisPrototypeRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarningLimitedScopes: includeWarnings);

  final String experimentId;
  final bool includeWarningLimitedScopes;
  final bool includeBlockedScopes;
  final bool includeFutureOnlyScopes;
  final bool includeAndroidProofReferences;
  final bool strictReadinessRequired;
  final List<String> notes;
  final InternalNonLabelPrototypeReadinessResult? readinessResult;
  final InternalSignalObservationReviewMatrixResult? reviewResult;
  final InternalSignalExperimentRunnerResult? runnerResult;
  final InternalSignalProfileConsistencyMatrixResult? consistencyResult;
  final InternalNonLabelSignalProfileResult? profileResult;
  final InternalNonLabelPrototypeReadinessGate readinessGate;
  final InternalSignalObservationReviewMatrix reviewMatrix;
  final InternalSignalExperimentRunner runner;
  final InternalSignalProfileConsistencyMatrix consistencyMatrix;
  final InternalNonLabelSignalProfilePrototype profile;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final List<GoldenAnalysisCase> cases;
}

class NarrowInternalAnalysisPrototypePacket {
  const NarrowInternalAnalysisPrototypePacket({
    required this.packetId,
    required this.allowedScopeId,
    required this.activeSignalIds,
    required this.evidenceAreaIds,
    required this.bucketIds,
    required this.supportCaseIds,
    required this.androidProofCaseIds,
    required this.qualitativeConfidence,
    required this.warningLimitedScopeIds,
    required this.coverageGapIds,
    required this.blockedScopeIds,
    required this.futurePrerequisites,
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
  final List<InternalNonLabelSignalId> activeSignalIds;
  final List<InternalEvidenceAreaId> evidenceAreaIds;
  final List<InternalEvidenceBucketId> bucketIds;
  final List<String> supportCaseIds;
  final List<String> androidProofCaseIds;
  final InternalNonLabelSignalConfidence qualitativeConfidence;
  final List<InternalNonLabelPrototypeScopeId> warningLimitedScopeIds;
  final List<String> coverageGapIds;
  final List<InternalNonLabelPrototypeScopeId> blockedScopeIds;
  final List<String> futurePrerequisites;
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

  NarrowInternalAnalysisPrototypePacket copyWith({
    String? packetId,
    InternalNonLabelPrototypeScopeId? allowedScopeId,
    List<InternalNonLabelSignalId>? activeSignalIds,
    List<InternalEvidenceAreaId>? evidenceAreaIds,
    List<InternalEvidenceBucketId>? bucketIds,
    List<String>? supportCaseIds,
    List<String>? androidProofCaseIds,
    InternalNonLabelSignalConfidence? qualitativeConfidence,
    List<InternalNonLabelPrototypeScopeId>? warningLimitedScopeIds,
    List<String>? coverageGapIds,
    List<InternalNonLabelPrototypeScopeId>? blockedScopeIds,
    List<String>? futurePrerequisites,
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
    return NarrowInternalAnalysisPrototypePacket(
      packetId: packetId ?? this.packetId,
      allowedScopeId: allowedScopeId ?? this.allowedScopeId,
      activeSignalIds: activeSignalIds ?? this.activeSignalIds,
      evidenceAreaIds: evidenceAreaIds ?? this.evidenceAreaIds,
      bucketIds: bucketIds ?? this.bucketIds,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      qualitativeConfidence:
          qualitativeConfidence ?? this.qualitativeConfidence,
      warningLimitedScopeIds:
          warningLimitedScopeIds ?? this.warningLimitedScopeIds,
      coverageGapIds: coverageGapIds ?? this.coverageGapIds,
      blockedScopeIds: blockedScopeIds ?? this.blockedScopeIds,
      futurePrerequisites: futurePrerequisites ?? this.futurePrerequisites,
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
      'activeSignalIds': activeSignalIds.map((id) => id.wire).toList(),
      'evidenceAreaIds': evidenceAreaIds.map((id) => id.wire).toList(),
      'bucketIds': bucketIds.map((id) => id.wire).toList(),
      'supportCaseIds': supportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'qualitativeConfidence': qualitativeConfidence.wire,
      'warningLimitedScopeIds': warningLimitedScopeIds
          .map((id) => id.wire)
          .toList(),
      'coverageGapIds': coverageGapIds,
      'blockedScopeIds': blockedScopeIds.map((id) => id.wire).toList(),
      'futurePrerequisites': futurePrerequisites,
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

class NarrowInternalNonLabelAnalysisPrototypeValidationFinding {
  const NarrowInternalNonLabelAnalysisPrototypeValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.packetId,
    this.scopeId,
    this.signalId,
    this.caseId,
  });

  final String id;
  final NarrowInternalNonLabelAnalysisPrototypeValidationSeverity severity;
  final String message;
  final String? packetId;
  final InternalNonLabelPrototypeScopeId? scopeId;
  final InternalNonLabelSignalId? signalId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical =>
      severity ==
      NarrowInternalNonLabelAnalysisPrototypeValidationSeverity.critical;

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

class NarrowInternalNonLabelAnalysisPrototypeResult {
  const NarrowInternalNonLabelAnalysisPrototypeResult({
    required this.prototypeStatus,
    required this.experimentId,
    required this.readinessStatus,
    required this.phase32ARecommendation,
    required this.reviewMatrixStatus,
    required this.runnerStatus,
    required this.consistencyMatrixStatus,
    required this.profileStatus,
    required this.readinessGatePassed,
    required this.safeForPhase32AInternalPrototype,
    required this.reviewUnsafeCount,
    required this.consistencyBlockerCount,
    required this.consistencyCriticalCount,
    required this.packets,
    required this.warningLimitedScopeIds,
    required this.blockedScopeIds,
    required this.supportCaseIds,
    required this.androidProofCaseIds,
    required this.coverageGapIds,
    required this.futurePrerequisites,
    required this.policyBlockers,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.nextRecommendation,
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

  final NarrowInternalNonLabelAnalysisPrototypeStatus prototypeStatus;
  final String experimentId;
  final InternalNonLabelPrototypeReadinessStatus readinessStatus;
  final InternalNonLabelPrototypeReadinessRecommendation phase32ARecommendation;
  final InternalSignalObservationReviewMatrixStatus reviewMatrixStatus;
  final InternalSignalExperimentRunnerStatus runnerStatus;
  final InternalSignalProfileConsistencyMatrixStatus consistencyMatrixStatus;
  final InternalNonLabelSignalProfileStatus profileStatus;
  final bool readinessGatePassed;
  final bool safeForPhase32AInternalPrototype;
  final int reviewUnsafeCount;
  final int consistencyBlockerCount;
  final int consistencyCriticalCount;
  final List<NarrowInternalAnalysisPrototypePacket> packets;
  final List<InternalNonLabelPrototypeScopeId> warningLimitedScopeIds;
  final List<InternalNonLabelPrototypeScopeId> blockedScopeIds;
  final List<String> supportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> coverageGapIds;
  final List<String> futurePrerequisites;
  final List<String> policyBlockers;
  final List<NarrowInternalNonLabelAnalysisPrototypeValidationFinding>
  validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final NarrowInternalNonLabelAnalysisPrototypeNextRecommendation
  nextRecommendation;
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

  int get packetCount => packets.length;

  List<InternalNonLabelPrototypeScopeId> get allowedScopePacketIds =>
      _sortedScopeIds(packets.map((packet) => packet.allowedScopeId));

  bool get isStrictlyBlocked =>
      !readinessGatePassed ||
      !safeForPhase32AInternalPrototype ||
      prototypeStatus ==
          NarrowInternalNonLabelAnalysisPrototypeStatus
              .skippedByReadinessGate ||
      prototypeStatus ==
          NarrowInternalNonLabelAnalysisPrototypeStatus.blockedByPolicy ||
      prototypeStatus ==
          NarrowInternalNonLabelAnalysisPrototypeStatus.invalidRequest ||
      prototypeStatus == NarrowInternalNonLabelAnalysisPrototypeStatus.failed ||
      reviewUnsafeCount > 0 ||
      consistencyBlockerCount > 0 ||
      consistencyCriticalCount > 0;

  bool get hasUnsafePrototypePolicyViolation {
    return validationFindings.any((finding) => finding.blocksStrict) ||
        packets.any((packet) => packet.hasUnsafeOutput) ||
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

  NarrowInternalAnalysisPrototypePacket packet(
    InternalNonLabelPrototypeScopeId id,
  ) {
    return packets.singleWhere((packet) => packet.allowedScopeId == id);
  }

  NarrowInternalNonLabelAnalysisPrototypeResult copyWith({
    NarrowInternalNonLabelAnalysisPrototypeStatus? prototypeStatus,
    String? experimentId,
    InternalNonLabelPrototypeReadinessStatus? readinessStatus,
    InternalNonLabelPrototypeReadinessRecommendation? phase32ARecommendation,
    InternalSignalObservationReviewMatrixStatus? reviewMatrixStatus,
    InternalSignalExperimentRunnerStatus? runnerStatus,
    InternalSignalProfileConsistencyMatrixStatus? consistencyMatrixStatus,
    InternalNonLabelSignalProfileStatus? profileStatus,
    bool? readinessGatePassed,
    bool? safeForPhase32AInternalPrototype,
    int? reviewUnsafeCount,
    int? consistencyBlockerCount,
    int? consistencyCriticalCount,
    List<NarrowInternalAnalysisPrototypePacket>? packets,
    List<InternalNonLabelPrototypeScopeId>? warningLimitedScopeIds,
    List<InternalNonLabelPrototypeScopeId>? blockedScopeIds,
    List<String>? supportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? coverageGapIds,
    List<String>? futurePrerequisites,
    List<String>? policyBlockers,
    List<NarrowInternalNonLabelAnalysisPrototypeValidationFinding>?
    validationFindings,
    List<String>? warnings,
    List<String>? failures,
    NarrowInternalNonLabelAnalysisPrototypeNextRecommendation?
    nextRecommendation,
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
    return NarrowInternalNonLabelAnalysisPrototypeResult(
      prototypeStatus: prototypeStatus ?? this.prototypeStatus,
      experimentId: experimentId ?? this.experimentId,
      readinessStatus: readinessStatus ?? this.readinessStatus,
      phase32ARecommendation:
          phase32ARecommendation ?? this.phase32ARecommendation,
      reviewMatrixStatus: reviewMatrixStatus ?? this.reviewMatrixStatus,
      runnerStatus: runnerStatus ?? this.runnerStatus,
      consistencyMatrixStatus:
          consistencyMatrixStatus ?? this.consistencyMatrixStatus,
      profileStatus: profileStatus ?? this.profileStatus,
      readinessGatePassed: readinessGatePassed ?? this.readinessGatePassed,
      safeForPhase32AInternalPrototype:
          safeForPhase32AInternalPrototype ??
          this.safeForPhase32AInternalPrototype,
      reviewUnsafeCount: reviewUnsafeCount ?? this.reviewUnsafeCount,
      consistencyBlockerCount:
          consistencyBlockerCount ?? this.consistencyBlockerCount,
      consistencyCriticalCount:
          consistencyCriticalCount ?? this.consistencyCriticalCount,
      packets: packets ?? this.packets,
      warningLimitedScopeIds:
          warningLimitedScopeIds ?? this.warningLimitedScopeIds,
      blockedScopeIds: blockedScopeIds ?? this.blockedScopeIds,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      coverageGapIds: coverageGapIds ?? this.coverageGapIds,
      futurePrerequisites: futurePrerequisites ?? this.futurePrerequisites,
      policyBlockers: policyBlockers ?? this.policyBlockers,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      nextRecommendation: nextRecommendation ?? this.nextRecommendation,
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
      ..writeln('# Narrow Internal Non-Label Analysis Prototype')
      ..writeln()
      ..writeln(
        '- version: $narrowInternalNonLabelAnalysisPrototypeReportVersion',
      )
      ..writeln('- prototype status: ${prototypeStatus.wire}')
      ..writeln('- experiment id: $experimentId')
      ..writeln('- readiness gate status: ${readinessStatus.wire}')
      ..writeln('- Phase 32A recommendation: ${phase32ARecommendation.wire}')
      ..writeln('- readiness gate passed: $readinessGatePassed')
      ..writeln(
        '- safe for Phase 32A internal prototype: $safeForPhase32AInternalPrototype',
      )
      ..writeln('- packet count: $packetCount')
      ..writeln('- review unsafe count: $reviewUnsafeCount')
      ..writeln('- consistency blocker count: $consistencyBlockerCount')
      ..writeln('- consistency critical count: $consistencyCriticalCount')
      ..writeln('- classifier output emitted: $classifierLabelsEmitted')
      ..writeln('- numeric score values emitted: $numericMoveScoresComputed')
      ..writeln('- ordering output emitted: $moveRankingComputed')
      ..writeln()
      ..writeln('## Prototype Policy')
      ..writeln(
        '- this prototype creates developer-only internal packets from stable allowed observations',
      )
      ..writeln(
        '- packets do not classify moves, compute values, order moves, call an engine, or write files',
      )
      ..writeln()
      ..writeln('## Packet Table')
      ..writeln(
        '| Packet | Allowed Scope | Signals | Confidence | Support Cases | Android Proof | Evidence Areas | Buckets |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- |');
    for (final packet in packets) {
      buffer.writeln(
        '| ${packet.packetId} | ${packet.allowedScopeId.wire} | ${_signalIds(packet.activeSignalIds)} | ${packet.qualitativeConfidence.wire} | ${_ids(packet.supportCaseIds)} | ${_ids(packet.androidProofCaseIds)} | ${_areaIds(packet.evidenceAreaIds)} | ${_bucketIds(packet.bucketIds)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Allowed Scope Packets')
      ..writeln('- ${_scopeIds(allowedScopePacketIds)}')
      ..writeln()
      ..writeln('## Warning-Limited Scopes')
      ..writeln('- ${_scopeIds(warningLimitedScopeIds)}')
      ..writeln()
      ..writeln('## Blocked Scopes')
      ..writeln('- ${_scopeIds(blockedScopeIds)}')
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
      ..writeln('## Future Prerequisites')
      ..writeln('- ${_ids(futurePrerequisites)}')
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
      ..writeln('## Next Recommendation')
      ..writeln(nextRecommendation.wire)
      ..writeln()
      ..writeln(
        'This prototype emits internal packets only. It does not emit user-facing output, compute product metrics, call the engine, run Android, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': narrowInternalNonLabelAnalysisPrototypeReportVersion,
      'prototypeStatus': prototypeStatus.wire,
      'experimentId': experimentId,
      'readinessStatus': readinessStatus.wire,
      'phase32ARecommendation': phase32ARecommendation.wire,
      'reviewMatrixStatus': reviewMatrixStatus.wire,
      'runnerStatus': runnerStatus.wire,
      'consistencyMatrixStatus': consistencyMatrixStatus.wire,
      'profileStatus': profileStatus.wire,
      'readinessGatePassed': readinessGatePassed,
      'safeForPhase32AInternalPrototype': safeForPhase32AInternalPrototype,
      'reviewUnsafeCount': reviewUnsafeCount,
      'consistencyBlockerCount': consistencyBlockerCount,
      'consistencyCriticalCount': consistencyCriticalCount,
      'packetCount': packetCount,
      'allowedScopePacketIds': allowedScopePacketIds
          .map((id) => id.wire)
          .toList(),
      'warningLimitedScopeIds': warningLimitedScopeIds
          .map((id) => id.wire)
          .toList(),
      'blockedScopeIds': blockedScopeIds.map((id) => id.wire).toList(),
      'supportCaseIds': supportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'coverageGapIds': coverageGapIds,
      'futurePrerequisites': futurePrerequisites,
      'policyBlockers': policyBlockers,
      'packets': packets.map((packet) => packet.toJson()).toList(),
      'validationFindings': validationFindings
          .map((finding) => finding.toJson())
          .toList(),
      'warnings': warnings,
      'failures': failures,
      'nextRecommendation': nextRecommendation.wire,
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

class NarrowInternalNonLabelAnalysisPrototype {
  const NarrowInternalNonLabelAnalysisPrototype({
    this.validator = const NarrowInternalNonLabelAnalysisPrototypeValidator(),
  });

  final NarrowInternalNonLabelAnalysisPrototypeValidator validator;

  NarrowInternalNonLabelAnalysisPrototypeResult run([
    NarrowInternalNonLabelAnalysisPrototypeRequest request =
        const NarrowInternalNonLabelAnalysisPrototypeRequest(),
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
    final readinessResult =
        request.readinessResult ??
        request.readinessGate.evaluate(
          InternalNonLabelPrototypeReadinessGateRequest(
            reviewResult: reviewResult,
            runnerResult: runnerResult,
            consistencyResult: consistencyResult,
            profileResult: profileResult,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
          ),
        );

    final gatePassed =
        readinessResult.safeForPhase32AInternalPrototype &&
        !readinessResult.isStrictlyBlocked &&
        reviewResult.unsafeCount == 0 &&
        consistencyResult.blockerCount == 0 &&
        consistencyResult.criticalCount == 0;

    if (!gatePassed) {
      final skipped = _resultFromPackets(
        request: request,
        readinessResult: readinessResult,
        reviewResult: reviewResult,
        runnerResult: runnerResult,
        consistencyResult: consistencyResult,
        profileResult: profileResult,
        packets: const <NarrowInternalAnalysisPrototypePacket>[],
        validationFindings:
            const <NarrowInternalNonLabelAnalysisPrototypeValidationFinding>[],
        forcedStatus: NarrowInternalNonLabelAnalysisPrototypeStatus
            .skippedByReadinessGate,
      );
      final findings = validator.validate(
        skipped,
        readinessResult: readinessResult,
        reviewResult: reviewResult,
        consistencyResult: consistencyResult,
      );
      return skipped.copyWith(
        validationFindings: findings,
        failures: _sortedStrings(<String>[
          ...skipped.failures,
          ...findings.map((finding) => finding.message),
        ]),
      );
    }

    final packets = _buildPackets(
      request: request,
      readinessResult: readinessResult,
      reviewResult: reviewResult,
    );
    final base = _resultFromPackets(
      request: request,
      readinessResult: readinessResult,
      reviewResult: reviewResult,
      runnerResult: runnerResult,
      consistencyResult: consistencyResult,
      profileResult: profileResult,
      packets: packets,
      validationFindings:
          const <NarrowInternalNonLabelAnalysisPrototypeValidationFinding>[],
    );
    final findings = validator.validate(
      base,
      readinessResult: readinessResult,
      reviewResult: reviewResult,
      consistencyResult: consistencyResult,
    );
    final withValidation = _resultFromPackets(
      request: request,
      readinessResult: readinessResult,
      reviewResult: reviewResult,
      runnerResult: runnerResult,
      consistencyResult: consistencyResult,
      profileResult: profileResult,
      packets: packets,
      validationFindings: findings,
    );
    return withValidation.copyWith(
      prototypeStatus: _statusFor(withValidation),
      nextRecommendation: _nextRecommendationFor(withValidation),
    );
  }
}

class NarrowInternalNonLabelAnalysisPrototypeValidator {
  const NarrowInternalNonLabelAnalysisPrototypeValidator();

  List<NarrowInternalNonLabelAnalysisPrototypeValidationFinding> validate(
    NarrowInternalNonLabelAnalysisPrototypeResult result, {
    required InternalNonLabelPrototypeReadinessResult readinessResult,
    required InternalSignalObservationReviewMatrixResult reviewResult,
    required InternalSignalProfileConsistencyMatrixResult consistencyResult,
  }) {
    final findings =
        <NarrowInternalNonLabelAnalysisPrototypeValidationFinding>[];

    void add({
      required String id,
      required NarrowInternalNonLabelAnalysisPrototypeValidationSeverity
      severity,
      required String message,
      String? packetId,
      InternalNonLabelPrototypeScopeId? scopeId,
      InternalNonLabelSignalId? signalId,
      String? caseId,
    }) {
      findings.add(
        NarrowInternalNonLabelAnalysisPrototypeValidationFinding(
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

    if (!readinessResult.safeForPhase32AInternalPrototype &&
        result.prototypeStatus !=
            NarrowInternalNonLabelAnalysisPrototypeStatus
                .skippedByReadinessGate) {
      add(
        id: 'prototypeRanDespiteFailedReadinessGate',
        severity:
            NarrowInternalNonLabelAnalysisPrototypeValidationSeverity.critical,
        message: 'prototype cannot run when readiness gate is unsafe',
      );
    }
    if (readinessResult.isStrictlyBlocked &&
        result.prototypeStatus !=
            NarrowInternalNonLabelAnalysisPrototypeStatus
                .skippedByReadinessGate) {
      add(
        id: 'prototypeRanDespiteBlockedReadinessGate',
        severity:
            NarrowInternalNonLabelAnalysisPrototypeValidationSeverity.critical,
        message: 'prototype cannot run when readiness gate is blocked',
      );
    }
    if (reviewResult.unsafeCount > 0 &&
        result.prototypeStatus !=
            NarrowInternalNonLabelAnalysisPrototypeStatus
                .skippedByReadinessGate) {
      add(
        id: 'prototypeRanDespiteUnsafeObservations',
        severity:
            NarrowInternalNonLabelAnalysisPrototypeValidationSeverity.critical,
        message: 'prototype cannot run with unsafe observations',
      );
    }
    if ((consistencyResult.blockerCount > 0 ||
            consistencyResult.criticalCount > 0) &&
        result.prototypeStatus !=
            NarrowInternalNonLabelAnalysisPrototypeStatus
                .skippedByReadinessGate) {
      add(
        id: 'prototypeRanDespiteConsistencyFailure',
        severity:
            NarrowInternalNonLabelAnalysisPrototypeValidationSeverity.critical,
        message: 'prototype cannot run with consistency blockers',
      );
    }

    for (final packet in result.packets) {
      if (!_allowedPacketScopes.contains(packet.allowedScopeId)) {
        add(
          id: _warningLimitedPrototypeScopes.contains(packet.allowedScopeId)
              ? 'warningLimitedScopePacket'
              : 'blockedScopePacket',
          severity:
              NarrowInternalNonLabelAnalysisPrototypeValidationSeverity.blocker,
          message: '${packet.allowedScopeId.wire} cannot become a core packet',
          packetId: packet.packetId,
          scopeId: packet.allowedScopeId,
        );
      }
      if (packet.supportCaseIds.isEmpty) {
        add(
          id: 'packetWithoutSupportCases',
          severity:
              NarrowInternalNonLabelAnalysisPrototypeValidationSeverity.blocker,
          message: '${packet.packetId} lacks supporting Golden cases',
          packetId: packet.packetId,
          scopeId: packet.allowedScopeId,
        );
      }
      if (packet.activeSignalIds.isEmpty ||
          packet.evidenceAreaIds.isEmpty ||
          packet.bucketIds.isEmpty) {
        add(
          id: 'packetWithoutSourceMapping',
          severity:
              NarrowInternalNonLabelAnalysisPrototypeValidationSeverity.blocker,
          message: '${packet.packetId} lacks source signal mapping',
          packetId: packet.packetId,
          scopeId: packet.allowedScopeId,
        );
      }
      if (packet.hasUnsafeOutput) {
        add(
          id: 'packetUnsafeOutputBoundary',
          severity: NarrowInternalNonLabelAnalysisPrototypeValidationSeverity
              .critical,
          message: '${packet.packetId} crossed an output boundary',
          packetId: packet.packetId,
          scopeId: packet.allowedScopeId,
        );
      }
      if (packet.quietScopeActive ||
          packet.allowedScopeId ==
              InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope) {
        add(
          id: 'quietPreparatoryPacketActivated',
          severity: NarrowInternalNonLabelAnalysisPrototypeValidationSeverity
              .critical,
          message: '${packet.packetId} activated quiet scope',
          packetId: packet.packetId,
          scopeId: packet.allowedScopeId,
        );
      }
      if (packet.cpLossComputationImplemented ||
          packet.winProbabilityComputationImplemented) {
        add(
          id: 'futureComputationActivated',
          severity: NarrowInternalNonLabelAnalysisPrototypeValidationSeverity
              .critical,
          message: '${packet.packetId} activated future computation',
          packetId: packet.packetId,
          scopeId: packet.allowedScopeId,
        );
      }
      for (final caseId in packet.androidProofCaseIds) {
        if (!readinessResult.androidProofCaseIds.contains(caseId) ||
            !reviewResult.provenAndroidCaseIds.contains(caseId)) {
          add(
            id: 'unprovenAndroidProofCitation',
            severity: NarrowInternalNonLabelAnalysisPrototypeValidationSeverity
                .blocker,
            message: '${packet.packetId} cited unproven proof',
            packetId: packet.packetId,
            scopeId: packet.allowedScopeId,
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
        result.persistenceUsed ||
        result.emittedOutputFamilies.any(_isForbiddenOutputName)) {
      add(
        id: 'prototypeBoundaryPolicyViolation',
        severity:
            NarrowInternalNonLabelAnalysisPrototypeValidationSeverity.critical,
        message: 'prototype crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<NarrowInternalNonLabelAnalysisPrototypeValidationFinding>
  validateReportText(String reportText) {
    final findings =
        <NarrowInternalNonLabelAnalysisPrototypeValidationFinding>[];
    void reportError(String id, String message) {
      findings.add(
        NarrowInternalNonLabelAnalysisPrototypeValidationFinding(
          id: id,
          severity: NarrowInternalNonLabelAnalysisPrototypeValidationSeverity
              .critical,
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

List<NarrowInternalAnalysisPrototypePacket> _buildPackets({
  required NarrowInternalNonLabelAnalysisPrototypeRequest request,
  required InternalNonLabelPrototypeReadinessResult readinessResult,
  required InternalSignalObservationReviewMatrixResult reviewResult,
}) {
  final rowsBySignal =
      <InternalNonLabelSignalId, InternalSignalObservationReviewRow>{
        for (final row in reviewResult.rows) row.signalId: row,
      };
  final futurePrerequisites = _futurePrerequisites(
    reviewResult,
    readinessResult,
  );
  final packets = <NarrowInternalAnalysisPrototypePacket>[];
  for (final scope in readinessResult.scopeRecords.where(
    (scope) => scope.isAllowed,
  )) {
    final signalId = scope.signalId;
    if (signalId == null) continue;
    final row = rowsBySignal[signalId];
    if (row == null) continue;
    packets.add(
      NarrowInternalAnalysisPrototypePacket(
        packetId: '${scope.scopeId.wire}-packet',
        allowedScopeId: scope.scopeId,
        activeSignalIds: <InternalNonLabelSignalId>[signalId],
        evidenceAreaIds: row.evidenceAreaIds,
        bucketIds: row.bucketIds,
        supportCaseIds: row.supportCaseIds,
        androidProofCaseIds: request.includeAndroidProofReferences
            ? row.androidProofCaseIds
            : const <String>[],
        qualitativeConfidence: row.qualitativeConfidence,
        warningLimitedScopeIds: request.includeWarningLimitedScopes
            ? readinessResult.warningLimitedScopeIds
            : const <InternalNonLabelPrototypeScopeId>[],
        coverageGapIds: readinessResult.coverageGapIds,
        blockedScopeIds: request.includeBlockedScopes
            ? readinessResult.blockedScopeIds
            : const <InternalNonLabelPrototypeScopeId>[],
        futurePrerequisites: futurePrerequisites,
      ),
    );
  }
  return List<NarrowInternalAnalysisPrototypePacket>.unmodifiable(
    packets..sort(
      (a, b) => a.allowedScopeId.index.compareTo(b.allowedScopeId.index),
    ),
  );
}

NarrowInternalNonLabelAnalysisPrototypeResult _resultFromPackets({
  required NarrowInternalNonLabelAnalysisPrototypeRequest request,
  required InternalNonLabelPrototypeReadinessResult readinessResult,
  required InternalSignalObservationReviewMatrixResult reviewResult,
  required InternalSignalExperimentRunnerResult runnerResult,
  required InternalSignalProfileConsistencyMatrixResult consistencyResult,
  required InternalNonLabelSignalProfileResult profileResult,
  required List<NarrowInternalAnalysisPrototypePacket> packets,
  required List<NarrowInternalNonLabelAnalysisPrototypeValidationFinding>
  validationFindings,
  NarrowInternalNonLabelAnalysisPrototypeStatus? forcedStatus,
}) {
  final futurePrerequisites = _futurePrerequisites(
    reviewResult,
    readinessResult,
  );
  final warnings = _sortedStrings(<String>[
    ...readinessResult.warnings,
    ...reviewResult.warnings,
    ...packets.expand((packet) => packet.coverageGapIds),
  ]);
  final failures = _sortedStrings(<String>[
    ...readinessResult.failures,
    ...reviewResult.failures,
    ...validationFindings.map((finding) => finding.message),
  ]);
  final status =
      forcedStatus ??
      (validationFindings.any((finding) => finding.blocksStrict)
          ? NarrowInternalNonLabelAnalysisPrototypeStatus.blockedByPolicy
          : packets.isEmpty
          ? NarrowInternalNonLabelAnalysisPrototypeStatus.invalidRequest
          : warnings.isNotEmpty ||
                readinessResult.warningLimitedScopeIds.isNotEmpty ||
                readinessResult.coverageGapIds.isNotEmpty
          ? NarrowInternalNonLabelAnalysisPrototypeStatus
                .completedWithCoverageWarnings
          : NarrowInternalNonLabelAnalysisPrototypeStatus
                .completedInternalPrototype);

  return NarrowInternalNonLabelAnalysisPrototypeResult(
    prototypeStatus: status,
    experimentId: request.experimentId,
    readinessStatus: readinessResult.overallStatus,
    phase32ARecommendation: readinessResult.phase32ARecommendation,
    reviewMatrixStatus: reviewResult.matrixStatus,
    runnerStatus: runnerResult.runnerStatus,
    consistencyMatrixStatus: consistencyResult.matrixStatus,
    profileStatus: profileResult.status,
    readinessGatePassed:
        readinessResult.safeForPhase32AInternalPrototype &&
        !readinessResult.isStrictlyBlocked,
    safeForPhase32AInternalPrototype:
        readinessResult.safeForPhase32AInternalPrototype,
    reviewUnsafeCount: reviewResult.unsafeCount,
    consistencyBlockerCount: consistencyResult.blockerCount,
    consistencyCriticalCount: consistencyResult.criticalCount,
    packets: packets,
    warningLimitedScopeIds: readinessResult.warningLimitedScopeIds,
    blockedScopeIds: readinessResult.blockedScopeIds,
    supportCaseIds: _sortedStrings(
      packets.expand((packet) => packet.supportCaseIds),
    ),
    androidProofCaseIds: _sortedStrings(
      packets.expand((packet) => packet.androidProofCaseIds),
    ),
    coverageGapIds: readinessResult.coverageGapIds,
    futurePrerequisites: futurePrerequisites,
    policyBlockers: readinessResult.policyBlockers,
    validationFindings: validationFindings,
    warnings: warnings,
    failures: failures,
    nextRecommendation:
        NarrowInternalNonLabelAnalysisPrototypeNextRecommendation
            .internalPacketConsistencyReview,
    productLabelsEmitted:
        readinessResult.productLabelsEmitted ||
        reviewResult.productLabelsEmitted ||
        runnerResult.productLabelsEmitted,
    classifierLabelsEmitted:
        readinessResult.classifierLabelsEmitted ||
        reviewResult.classifierLabelsEmitted ||
        runnerResult.classifierLabelsEmitted,
    finalMoveLabelsEmitted:
        readinessResult.finalMoveLabelsEmitted ||
        reviewResult.finalMoveLabelsEmitted ||
        runnerResult.finalMoveLabelsEmitted,
    officialMetricsAllowed:
        readinessResult.officialMetricsAllowed ||
        reviewResult.officialMetricsAllowed ||
        runnerResult.officialMetricsAllowed,
    cpLossComputationImplemented:
        readinessResult.cpLossComputationImplemented ||
        reviewResult.cpLossComputationImplemented ||
        runnerResult.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        readinessResult.winProbabilityComputationImplemented ||
        reviewResult.winProbabilityComputationImplemented ||
        runnerResult.winProbabilityComputationImplemented,
    numericMoveScoresComputed:
        readinessResult.numericMoveScoresComputed ||
        reviewResult.numericMoveScoresComputed ||
        runnerResult.numericMoveScoresComputed,
    moveRankingComputed:
        readinessResult.moveRankingComputed ||
        reviewResult.moveRankingComputed ||
        runnerResult.moveRankingComputed,
    directEngineAccessUsed:
        readinessResult.directEngineAccessUsed ||
        reviewResult.directEngineAccessUsed ||
        runnerResult.directEngineAccessUsed,
    uiOutputUsed:
        readinessResult.uiOutputUsed ||
        reviewResult.uiOutputUsed ||
        runnerResult.uiOutputUsed,
    backendOutputUsed:
        readinessResult.backendOutputUsed ||
        reviewResult.backendOutputUsed ||
        runnerResult.backendOutputUsed,
    persistenceUsed:
        readinessResult.persistenceUsed ||
        reviewResult.persistenceUsed ||
        runnerResult.persistenceUsed,
    emittedOutputFamilies: _sortedStrings(<String>[
      ...readinessResult.emittedOutputFamilies,
      ...reviewResult.emittedOutputFamilies,
      ...runnerResult.emittedOutputFamilies,
    ]),
  );
}

NarrowInternalNonLabelAnalysisPrototypeStatus _statusFor(
  NarrowInternalNonLabelAnalysisPrototypeResult result,
) {
  if (result.validationFindings.any((finding) => finding.blocksStrict) ||
      result.hasUnsafePrototypePolicyViolation) {
    return NarrowInternalNonLabelAnalysisPrototypeStatus.blockedByPolicy;
  }
  if (result.packets.isEmpty) {
    return NarrowInternalNonLabelAnalysisPrototypeStatus.invalidRequest;
  }
  if (result.warningLimitedScopeIds.isNotEmpty ||
      result.coverageGapIds.isNotEmpty ||
      result.warnings.isNotEmpty) {
    return NarrowInternalNonLabelAnalysisPrototypeStatus
        .completedWithCoverageWarnings;
  }
  return NarrowInternalNonLabelAnalysisPrototypeStatus
      .completedInternalPrototype;
}

NarrowInternalNonLabelAnalysisPrototypeNextRecommendation
_nextRecommendationFor(NarrowInternalNonLabelAnalysisPrototypeResult result) {
  if (result.hasUnsafePrototypePolicyViolation) {
    return NarrowInternalNonLabelAnalysisPrototypeNextRecommendation
        .fixPrototypeSafetyFirst;
  }
  if (result.coverageGapIds.isNotEmpty ||
      result.warningLimitedScopeIds.isNotEmpty) {
    return NarrowInternalNonLabelAnalysisPrototypeNextRecommendation
        .addGoldenCoverageBeforeExpansion;
  }
  return NarrowInternalNonLabelAnalysisPrototypeNextRecommendation
      .internalPacketConsistencyReview;
}

List<String> _futurePrerequisites(
  InternalSignalObservationReviewMatrixResult reviewResult,
  InternalNonLabelPrototypeReadinessResult readinessResult,
) {
  return _sortedStrings(<String>[
    ...reviewResult.rows
        .where((row) => row.futurePrerequisite.isNotEmpty)
        .map((row) => '${row.signalId.wire}: ${row.futurePrerequisite}'),
    ...readinessResult.scopeRecords
        .where(
          (scope) =>
              scope.readiness ==
              InternalNonLabelPrototypeScopeReadiness.futureOnly,
        )
        .expand((scope) => scope.policyBlockers),
  ]);
}

String _ids(Iterable<String> values) {
  final sorted = _sortedStrings(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

String _signalIds(Iterable<InternalNonLabelSignalId> values) {
  final ids = values.map((id) => id.wire).toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _scopeIds(Iterable<InternalNonLabelPrototypeScopeId> values) {
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

List<InternalNonLabelPrototypeScopeId> _sortedScopeIds(
  Iterable<InternalNonLabelPrototypeScopeId> values,
) {
  return values.toSet().toList()..sort((a, b) => a.index.compareTo(b.index));
}

int _compareFindings(
  NarrowInternalNonLabelAnalysisPrototypeValidationFinding a,
  NarrowInternalNonLabelAnalysisPrototypeValidationFinding b,
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

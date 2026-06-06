/// Developer-only adapter prototype packets for internal evidence summaries.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_design.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_summary_layer.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_evidence_readiness_gate.dart';

const internalEvidenceAdapterPrototypeReportVersion =
    'internal-evidence-adapter-prototype-v1';

enum InternalEvidenceAdapterPrototypeStatus {
  completedWithWarnings('completedWithWarnings'),
  completedClean('completedClean'),
  skippedByUnsafeDesign('skippedByUnsafeDesign'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const InternalEvidenceAdapterPrototypeStatus(this.wire);

  final String wire;
}

enum InternalEvidenceAdapterPacketRole {
  coreEvidencePacket('coreEvidencePacket'),
  contextOnlyPacket('contextOnlyPacket'),
  blockedBoundaryPacket('blockedBoundaryPacket'),
  futureOnlyPacket('futureOnlyPacket');

  const InternalEvidenceAdapterPacketRole(this.wire);

  final String wire;

  bool get isCore => this == coreEvidencePacket;

  bool get isContextOnly => this == contextOnlyPacket;

  bool get isInactive =>
      this == blockedBoundaryPacket || this == futureOnlyPacket;
}

enum InternalEvidenceAdapterPrototypePhase32ORecommendation {
  reviewInternalEvidenceAdapterPrototype(
    'reviewInternalEvidenceAdapterPrototype',
  ),
  proceedToAdapterPrototypeValidation('proceedToAdapterPrototypeValidation'),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeAdapterPrototype('blockedByUnsafeAdapterPrototype');

  const InternalEvidenceAdapterPrototypePhase32ORecommendation(this.wire);

  final String wire;
}

enum InternalEvidenceAdapterPrototypeValidationSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const InternalEvidenceAdapterPrototypeValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == InternalEvidenceAdapterPrototypeValidationSeverity.blocker ||
      this == InternalEvidenceAdapterPrototypeValidationSeverity.critical;
}

enum InternalEvidenceAdapterPrototypeReportFormat {
  markdown('markdown'),
  json('json');

  const InternalEvidenceAdapterPrototypeReportFormat(this.wire);

  final String wire;
}

class InternalEvidenceAdapterPrototypeRequest {
  const InternalEvidenceAdapterPrototypeRequest({
    this.designResult,
    this.summaryResult,
    this.readinessResult,
    this.adapterDesign = const InternalEvidenceAdapterDesign(),
    this.summaryLayer = const InternalEvidenceSummaryLayer(),
    this.readinessGate = const RefreshedPacketEvidenceReadinessGate(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const InternalEvidenceAdapterPrototypeRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final InternalEvidenceAdapterDesignResult? designResult;
  final InternalEvidenceSummaryLayerResult? summaryResult;
  final RefreshedPacketEvidenceReadinessGateResult? readinessResult;
  final InternalEvidenceAdapterDesign adapterDesign;
  final InternalEvidenceSummaryLayer summaryLayer;
  final RefreshedPacketEvidenceReadinessGate readinessGate;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class InternalEvidenceAdapterPacket {
  const InternalEvidenceAdapterPacket({
    required this.adapterPacketId,
    required this.sourceAdapterRecordId,
    required this.sourceSummaryGroupIds,
    required this.adapterRole,
    required this.allowedEvidenceRecordIds,
    required this.activeOutputFieldIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.evidenceAreaIds,
    required this.bucketIds,
    required this.qualitativeConfidence,
    required this.internalWarnings,
    required this.internalConstraints,
    required this.futurePrerequisites,
    required this.androidProofCaseIds,
    required this.proofLimitReason,
    required this.watchListReason,
    required this.warningLimitedReason,
    required this.blockedOutputFieldIds,
    this.isProductOutput = false,
    this.isClassifierLabel = false,
    this.isOfficialMetric = false,
    this.hasNumericScore = false,
    this.ranksMoves = false,
    this.callsEngine = false,
    this.writesPersistence = false,
    this.targetsUi = false,
    this.cpLossOutputActive = false,
    this.winProbabilityOutputActive = false,
    this.quietPreparatoryScopeActive = false,
    this.backendOutputActive = false,
  });

  final String adapterPacketId;
  final String sourceAdapterRecordId;
  final List<InternalEvidenceSummaryGroupId> sourceSummaryGroupIds;
  final InternalEvidenceAdapterPacketRole adapterRole;
  final List<String> allowedEvidenceRecordIds;
  final List<String> activeOutputFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<InternalEvidenceAreaId> evidenceAreaIds;
  final List<InternalEvidenceBucketId> bucketIds;
  final String qualitativeConfidence;
  final List<String> internalWarnings;
  final List<String> internalConstraints;
  final List<String> futurePrerequisites;
  final List<String> androidProofCaseIds;
  final String proofLimitReason;
  final String watchListReason;
  final String warningLimitedReason;
  final List<String> blockedOutputFieldIds;
  final bool isProductOutput;
  final bool isClassifierLabel;
  final bool isOfficialMetric;
  final bool hasNumericScore;
  final bool ranksMoves;
  final bool callsEngine;
  final bool writesPersistence;
  final bool targetsUi;
  final bool cpLossOutputActive;
  final bool winProbabilityOutputActive;
  final bool quietPreparatoryScopeActive;
  final bool backendOutputActive;

  bool get hasBlockedActiveField =>
      activeOutputFieldIds.any(_isBlockedOutputFieldId);

  bool get hasUnsafeOutput {
    return isProductOutput ||
        isClassifierLabel ||
        isOfficialMetric ||
        hasNumericScore ||
        ranksMoves ||
        callsEngine ||
        writesPersistence ||
        targetsUi ||
        cpLossOutputActive ||
        winProbabilityOutputActive ||
        quietPreparatoryScopeActive ||
        backendOutputActive ||
        hasBlockedActiveField;
  }

  bool get isInactiveSafe =>
      adapterRole.isInactive &&
      activeOutputFieldIds.isEmpty &&
      allowedEvidenceRecordIds.isEmpty &&
      !hasUnsafeOutput;

  InternalEvidenceAdapterPacket copyWith({
    String? adapterPacketId,
    String? sourceAdapterRecordId,
    List<InternalEvidenceSummaryGroupId>? sourceSummaryGroupIds,
    InternalEvidenceAdapterPacketRole? adapterRole,
    List<String>? allowedEvidenceRecordIds,
    List<String>? activeOutputFieldIds,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<InternalEvidenceAreaId>? evidenceAreaIds,
    List<InternalEvidenceBucketId>? bucketIds,
    String? qualitativeConfidence,
    List<String>? internalWarnings,
    List<String>? internalConstraints,
    List<String>? futurePrerequisites,
    List<String>? androidProofCaseIds,
    String? proofLimitReason,
    String? watchListReason,
    String? warningLimitedReason,
    List<String>? blockedOutputFieldIds,
    bool? isProductOutput,
    bool? isClassifierLabel,
    bool? isOfficialMetric,
    bool? hasNumericScore,
    bool? ranksMoves,
    bool? callsEngine,
    bool? writesPersistence,
    bool? targetsUi,
    bool? cpLossOutputActive,
    bool? winProbabilityOutputActive,
    bool? quietPreparatoryScopeActive,
    bool? backendOutputActive,
  }) {
    return InternalEvidenceAdapterPacket(
      adapterPacketId: adapterPacketId ?? this.adapterPacketId,
      sourceAdapterRecordId:
          sourceAdapterRecordId ?? this.sourceAdapterRecordId,
      sourceSummaryGroupIds:
          sourceSummaryGroupIds ?? this.sourceSummaryGroupIds,
      adapterRole: adapterRole ?? this.adapterRole,
      allowedEvidenceRecordIds:
          allowedEvidenceRecordIds ?? this.allowedEvidenceRecordIds,
      activeOutputFieldIds: activeOutputFieldIds ?? this.activeOutputFieldIds,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      evidenceAreaIds: evidenceAreaIds ?? this.evidenceAreaIds,
      bucketIds: bucketIds ?? this.bucketIds,
      qualitativeConfidence:
          qualitativeConfidence ?? this.qualitativeConfidence,
      internalWarnings: internalWarnings ?? this.internalWarnings,
      internalConstraints: internalConstraints ?? this.internalConstraints,
      futurePrerequisites: futurePrerequisites ?? this.futurePrerequisites,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      proofLimitReason: proofLimitReason ?? this.proofLimitReason,
      watchListReason: watchListReason ?? this.watchListReason,
      warningLimitedReason: warningLimitedReason ?? this.warningLimitedReason,
      blockedOutputFieldIds:
          blockedOutputFieldIds ?? this.blockedOutputFieldIds,
      isProductOutput: isProductOutput ?? this.isProductOutput,
      isClassifierLabel: isClassifierLabel ?? this.isClassifierLabel,
      isOfficialMetric: isOfficialMetric ?? this.isOfficialMetric,
      hasNumericScore: hasNumericScore ?? this.hasNumericScore,
      ranksMoves: ranksMoves ?? this.ranksMoves,
      callsEngine: callsEngine ?? this.callsEngine,
      writesPersistence: writesPersistence ?? this.writesPersistence,
      targetsUi: targetsUi ?? this.targetsUi,
      cpLossOutputActive: cpLossOutputActive ?? this.cpLossOutputActive,
      winProbabilityOutputActive:
          winProbabilityOutputActive ?? this.winProbabilityOutputActive,
      quietPreparatoryScopeActive:
          quietPreparatoryScopeActive ?? this.quietPreparatoryScopeActive,
      backendOutputActive: backendOutputActive ?? this.backendOutputActive,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'adapterPacketId': adapterPacketId,
      'sourceAdapterRecordId': sourceAdapterRecordId,
      'sourceSummaryGroupIds': sourceSummaryGroupIds
          .map((id) => id.wire)
          .toList(),
      'adapterRole': adapterRole.wire,
      'allowedEvidenceRecordIds': allowedEvidenceRecordIds,
      'activeOutputFieldIds': activeOutputFieldIds,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'evidenceAreaIds': evidenceAreaIds.map((id) => id.wire).toList(),
      'bucketIds': bucketIds.map((id) => id.wire).toList(),
      'qualitativeConfidence': qualitativeConfidence,
      'internalWarnings': internalWarnings,
      'internalConstraints': internalConstraints,
      'futurePrerequisites': futurePrerequisites,
      'androidProofCaseIds': androidProofCaseIds,
      'proofLimitReason': proofLimitReason,
      'watchListReason': watchListReason,
      'warningLimitedReason': warningLimitedReason,
      'blockedOutputFieldIds': blockedOutputFieldIds,
      'isProductOutput': isProductOutput,
      'isClassifierLabel': isClassifierLabel,
      'isOfficialMetric': isOfficialMetric,
      'hasNumericScore': hasNumericScore,
      'ranksMoves': ranksMoves,
      'callsEngine': callsEngine,
      'writesPersistence': writesPersistence,
      'targetsUi': targetsUi,
      'cpLossOutputActive': cpLossOutputActive,
      'winProbabilityOutputActive': winProbabilityOutputActive,
      'quietPreparatoryScopeActive': quietPreparatoryScopeActive,
      'backendOutputActive': backendOutputActive,
    };
  }
}

class InternalEvidenceAdapterPrototypeFinding {
  const InternalEvidenceAdapterPrototypeFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.adapterPacketId,
    this.groupId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final InternalEvidenceAdapterPrototypeValidationSeverity severity;
  final String message;
  final String? adapterPacketId;
  final InternalEvidenceSummaryGroupId? groupId;
  final String? fieldId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical =>
      severity == InternalEvidenceAdapterPrototypeValidationSeverity.critical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (adapterPacketId != null) 'adapterPacketId': adapterPacketId,
      if (groupId != null) 'groupId': groupId!.wire,
      if (fieldId != null) 'fieldId': fieldId,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class InternalEvidenceAdapterPrototypeResult {
  const InternalEvidenceAdapterPrototypeResult({
    required this.prototypeStatus,
    required this.sourceDesignStatus,
    required this.sourceSummaryStatus,
    required this.sourceReadinessStatus,
    required this.packets,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalPackets,
    required this.corePacketCount,
    required this.contextOnlyPacketCount,
    required this.blockedPacketCount,
    required this.futureOnlyPacketCount,
    required this.unsafeCount,
    required this.criticalCount,
    required this.ownerProofQueueCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.activeOutputFieldIds,
    required this.blockedOutputFieldIds,
    required this.safeForPhase32O,
    required this.phase32ORecommendation,
    this.developerOnly = true,
    this.productOutputActive = false,
    this.classifierOutputActive = false,
    this.finalMoveLabelOutputActive = false,
    this.officialMetricOutputActive = false,
    this.cpLossOutputActive = false,
    this.winProbabilityOutputActive = false,
    this.numericOutputActive = false,
    this.moveRankingOutputActive = false,
    this.quietPreparatoryScopeActivated = false,
    this.engineCallsActive = false,
    this.persistenceWritesActive = false,
    this.uiTargetsActive = false,
    this.backendOutputActive = false,
  });

  final InternalEvidenceAdapterPrototypeStatus prototypeStatus;
  final InternalEvidenceAdapterDesignStatus sourceDesignStatus;
  final InternalEvidenceSummaryLayerStatus sourceSummaryStatus;
  final RefreshedPacketEvidenceReadinessStatus sourceReadinessStatus;
  final List<InternalEvidenceAdapterPacket> packets;
  final List<InternalEvidenceAdapterPrototypeFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalPackets;
  final int corePacketCount;
  final int contextOnlyPacketCount;
  final int blockedPacketCount;
  final int futureOnlyPacketCount;
  final int unsafeCount;
  final int criticalCount;
  final int ownerProofQueueCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> activeOutputFieldIds;
  final List<String> blockedOutputFieldIds;
  final bool safeForPhase32O;
  final InternalEvidenceAdapterPrototypePhase32ORecommendation
  phase32ORecommendation;
  final bool developerOnly;
  final bool productOutputActive;
  final bool classifierOutputActive;
  final bool finalMoveLabelOutputActive;
  final bool officialMetricOutputActive;
  final bool cpLossOutputActive;
  final bool winProbabilityOutputActive;
  final bool numericOutputActive;
  final bool moveRankingOutputActive;
  final bool quietPreparatoryScopeActivated;
  final bool engineCallsActive;
  final bool persistenceWritesActive;
  final bool uiTargetsActive;
  final bool backendOutputActive;

  bool get isStrictlyBlocked =>
      prototypeStatus ==
          InternalEvidenceAdapterPrototypeStatus.skippedByUnsafeDesign ||
      prototypeStatus ==
          InternalEvidenceAdapterPrototypeStatus.blockedByPolicyBoundary ||
      prototypeStatus == InternalEvidenceAdapterPrototypeStatus.invalid ||
      !safeForPhase32O ||
      unsafeCount > 0 ||
      criticalCount > 0 ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeAdapterPrototypePolicyViolation {
    return unsafeCount > 0 ||
        criticalCount > 0 ||
        validationFindings.any((finding) => finding.isCritical) ||
        packets.any((packet) => packet.hasUnsafeOutput) ||
        activeOutputFieldIds.any(_isBlockedOutputFieldId) ||
        productOutputActive ||
        classifierOutputActive ||
        finalMoveLabelOutputActive ||
        officialMetricOutputActive ||
        cpLossOutputActive ||
        winProbabilityOutputActive ||
        numericOutputActive ||
        moveRankingOutputActive ||
        quietPreparatoryScopeActivated ||
        engineCallsActive ||
        persistenceWritesActive ||
        uiTargetsActive ||
        backendOutputActive;
  }

  InternalEvidenceAdapterPacket packet(String adapterPacketId) {
    return packets.singleWhere(
      (packet) => packet.adapterPacketId == adapterPacketId,
    );
  }

  InternalEvidenceAdapterPacket packetForGroup(
    InternalEvidenceSummaryGroupId groupId,
  ) {
    return packets.singleWhere(
      (packet) => packet.sourceSummaryGroupIds.contains(groupId),
    );
  }

  List<InternalEvidenceAdapterPacket> get corePackets => packets
      .where((packet) => packet.adapterRole.isCore)
      .toList(growable: false);

  List<InternalEvidenceAdapterPacket> get contextOnlyPackets => packets
      .where((packet) => packet.adapterRole.isContextOnly)
      .toList(growable: false);

  List<InternalEvidenceAdapterPacket> get blockedOrFuturePackets => packets
      .where((packet) => packet.adapterRole.isInactive)
      .toList(growable: false);

  InternalEvidenceAdapterPrototypeResult copyWith({
    InternalEvidenceAdapterPrototypeStatus? prototypeStatus,
    InternalEvidenceAdapterDesignStatus? sourceDesignStatus,
    InternalEvidenceSummaryLayerStatus? sourceSummaryStatus,
    RefreshedPacketEvidenceReadinessStatus? sourceReadinessStatus,
    List<InternalEvidenceAdapterPacket>? packets,
    List<InternalEvidenceAdapterPrototypeFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalPackets,
    int? corePacketCount,
    int? contextOnlyPacketCount,
    int? blockedPacketCount,
    int? futureOnlyPacketCount,
    int? unsafeCount,
    int? criticalCount,
    int? ownerProofQueueCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? activeOutputFieldIds,
    List<String>? blockedOutputFieldIds,
    bool? safeForPhase32O,
    InternalEvidenceAdapterPrototypePhase32ORecommendation?
    phase32ORecommendation,
    bool? developerOnly,
    bool? productOutputActive,
    bool? classifierOutputActive,
    bool? finalMoveLabelOutputActive,
    bool? officialMetricOutputActive,
    bool? cpLossOutputActive,
    bool? winProbabilityOutputActive,
    bool? numericOutputActive,
    bool? moveRankingOutputActive,
    bool? quietPreparatoryScopeActivated,
    bool? engineCallsActive,
    bool? persistenceWritesActive,
    bool? uiTargetsActive,
    bool? backendOutputActive,
  }) {
    return InternalEvidenceAdapterPrototypeResult(
      prototypeStatus: prototypeStatus ?? this.prototypeStatus,
      sourceDesignStatus: sourceDesignStatus ?? this.sourceDesignStatus,
      sourceSummaryStatus: sourceSummaryStatus ?? this.sourceSummaryStatus,
      sourceReadinessStatus:
          sourceReadinessStatus ?? this.sourceReadinessStatus,
      packets: packets ?? this.packets,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalPackets: totalPackets ?? this.totalPackets,
      corePacketCount: corePacketCount ?? this.corePacketCount,
      contextOnlyPacketCount:
          contextOnlyPacketCount ?? this.contextOnlyPacketCount,
      blockedPacketCount: blockedPacketCount ?? this.blockedPacketCount,
      futureOnlyPacketCount:
          futureOnlyPacketCount ?? this.futureOnlyPacketCount,
      unsafeCount: unsafeCount ?? this.unsafeCount,
      criticalCount: criticalCount ?? this.criticalCount,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      activeOutputFieldIds: activeOutputFieldIds ?? this.activeOutputFieldIds,
      blockedOutputFieldIds:
          blockedOutputFieldIds ?? this.blockedOutputFieldIds,
      safeForPhase32O: safeForPhase32O ?? this.safeForPhase32O,
      phase32ORecommendation:
          phase32ORecommendation ?? this.phase32ORecommendation,
      developerOnly: developerOnly ?? this.developerOnly,
      productOutputActive: productOutputActive ?? this.productOutputActive,
      classifierOutputActive:
          classifierOutputActive ?? this.classifierOutputActive,
      finalMoveLabelOutputActive:
          finalMoveLabelOutputActive ?? this.finalMoveLabelOutputActive,
      officialMetricOutputActive:
          officialMetricOutputActive ?? this.officialMetricOutputActive,
      cpLossOutputActive: cpLossOutputActive ?? this.cpLossOutputActive,
      winProbabilityOutputActive:
          winProbabilityOutputActive ?? this.winProbabilityOutputActive,
      numericOutputActive: numericOutputActive ?? this.numericOutputActive,
      moveRankingOutputActive:
          moveRankingOutputActive ?? this.moveRankingOutputActive,
      quietPreparatoryScopeActivated:
          quietPreparatoryScopeActivated ?? this.quietPreparatoryScopeActivated,
      engineCallsActive: engineCallsActive ?? this.engineCallsActive,
      persistenceWritesActive:
          persistenceWritesActive ?? this.persistenceWritesActive,
      uiTargetsActive: uiTargetsActive ?? this.uiTargetsActive,
      backendOutputActive: backendOutputActive ?? this.backendOutputActive,
    );
  }

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Internal Evidence Adapter Prototype')
      ..writeln()
      ..writeln('- version: $internalEvidenceAdapterPrototypeReportVersion')
      ..writeln('- prototype status: ${prototypeStatus.wire}')
      ..writeln('- source design status: ${sourceDesignStatus.wire}')
      ..writeln('- source summary status: ${sourceSummaryStatus.wire}')
      ..writeln('- source readiness status: ${sourceReadinessStatus.wire}')
      ..writeln('- total packets: $totalPackets')
      ..writeln('- core packet count: $corePacketCount')
      ..writeln('- context-only packet count: $contextOnlyPacketCount')
      ..writeln('- blocked packet count: $blockedPacketCount')
      ..writeln('- future-only packet count: $futureOnlyPacketCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- safe for Phase 32O: $safeForPhase32O')
      ..writeln('- Phase 32O recommendation: ${phase32ORecommendation.wire}')
      ..writeln()
      ..writeln('## Prototype Policy')
      ..writeln(
        '- this layer creates internal adapter prototype packets from the Phase 32M design only',
      )
      ..writeln(
        '- core packets come from allowed and improved support summaries; context packets remain context-only',
      )
      ..writeln(
        '- blocked and future-only packets remain inactive and carry no active fields',
      )
      ..writeln()
      ..writeln('## Adapter Packet Table')
      ..writeln(
        '| Packet | Source Record | Groups | Role | Allowed Records | Active Fields | Support Cases | New Phase 32E Support | Areas | Buckets | Android Proof | Blocked Fields |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final packet in packets) {
      buffer.writeln(
        '| ${_cell(packet.adapterPacketId)} | '
        '${_cell(packet.sourceAdapterRecordId)} | '
        '${_groupIds(packet.sourceSummaryGroupIds)} | '
        '${packet.adapterRole.wire} | '
        '${_ids(packet.allowedEvidenceRecordIds)} | '
        '${_ids(packet.activeOutputFieldIds)} | '
        '${_ids(packet.supportCaseIds)} | '
        '${_ids(packet.newlyAddedSupportCaseIds)} | '
        '${_areaIds(packet.evidenceAreaIds)} | '
        '${_bucketIds(packet.bucketIds)} | '
        '${_ids(packet.androidProofCaseIds)} | '
        '${_ids(packet.blockedOutputFieldIds)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Core Packets')
      ..writeln('- ${_packetIds(corePackets)}')
      ..writeln()
      ..writeln('## Context-Only Packets')
      ..writeln('- ${_packetIds(contextOnlyPackets)}')
      ..writeln()
      ..writeln('## Blocked And Future-Only Packets')
      ..writeln('- ${_packetIds(blockedOrFuturePackets)}')
      ..writeln()
      ..writeln('## Active Output Field Summary')
      ..writeln('- ${_ids(activeOutputFieldIds)}')
      ..writeln()
      ..writeln('## Blocked Output Field Summary')
      ..writeln('- ${_ids(blockedOutputFieldIds)}')
      ..writeln()
      ..writeln('## Android Proof IDs')
      ..writeln('- ${_ids(androidProofCaseIds)}')
      ..writeln()
      ..writeln('## Owner Proof Status')
      ..writeln(
        ownerProofQueueCount == 0
            ? '- empty'
            : '- opt-in proof requires explicit PV/MultiPV reason',
      )
      ..writeln()
      ..writeln('## Validation Findings');
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
        buffer.writeln('- ${_cell(warning)}');
      }
    }
    buffer
      ..writeln()
      ..writeln('## Failures');
    if (failures.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final failure in failures) {
        buffer.writeln('- ${_cell(failure)}');
      }
    }
    buffer
      ..writeln()
      ..writeln('## Phase 32O Recommendation')
      ..writeln(phase32ORecommendation.wire)
      ..writeln()
      ..writeln(
        'This adapter prototype is internal-only. It does not emit active product labels, compute values, order moves, call the engine, run Android, target UI, integrate with backend or persistence, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': internalEvidenceAdapterPrototypeReportVersion,
      'prototypeStatus': prototypeStatus.wire,
      'sourceDesignStatus': sourceDesignStatus.wire,
      'sourceSummaryStatus': sourceSummaryStatus.wire,
      'sourceReadinessStatus': sourceReadinessStatus.wire,
      'totalPackets': totalPackets,
      'corePacketCount': corePacketCount,
      'contextOnlyPacketCount': contextOnlyPacketCount,
      'blockedPacketCount': blockedPacketCount,
      'futureOnlyPacketCount': futureOnlyPacketCount,
      'unsafeCount': unsafeCount,
      'criticalCount': criticalCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'activeOutputFieldIds': activeOutputFieldIds,
      'blockedOutputFieldIds': blockedOutputFieldIds,
      'safeForPhase32O': safeForPhase32O,
      'phase32ORecommendation': phase32ORecommendation.wire,
      'packets': packets.map((packet) => packet.toJson()).toList(),
      'validationFindings': validationFindings
          .map((finding) => finding.toJson())
          .toList(),
      'warnings': warnings,
      'failures': failures,
      'developerOnly': developerOnly,
      'productOutputActive': productOutputActive,
      'classifierOutputActive': classifierOutputActive,
      'finalMoveLabelOutputActive': finalMoveLabelOutputActive,
      'officialMetricOutputActive': officialMetricOutputActive,
      'cpLossOutputActive': cpLossOutputActive,
      'winProbabilityOutputActive': winProbabilityOutputActive,
      'numericOutputActive': numericOutputActive,
      'moveRankingOutputActive': moveRankingOutputActive,
      'quietPreparatoryScopeActivated': quietPreparatoryScopeActivated,
      'engineCallsActive': engineCallsActive,
      'persistenceWritesActive': persistenceWritesActive,
      'uiTargetsActive': uiTargetsActive,
      'backendOutputActive': backendOutputActive,
    };
  }
}

class InternalEvidenceAdapterPrototype {
  const InternalEvidenceAdapterPrototype({
    this.validator = const InternalEvidenceAdapterPrototypeValidator(),
  });

  final InternalEvidenceAdapterPrototypeValidator validator;

  InternalEvidenceAdapterPrototypeResult evaluate([
    InternalEvidenceAdapterPrototypeRequest request =
        const InternalEvidenceAdapterPrototypeRequest(),
  ]) {
    final designResult =
        request.designResult ??
        request.adapterDesign.evaluate(
          InternalEvidenceAdapterDesignRequest(
            summaryResult: request.summaryResult,
            readinessResult: request.readinessResult,
            summaryLayer: request.summaryLayer,
            readinessGate: request.readinessGate,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final canPrototype =
        designResult.safeForPhase32N &&
        !designResult.isStrictlyBlocked &&
        !designResult.hasUnsafeAdapterDesignPolicyViolation;
    final packets = canPrototype
        ? _packetsFromDesign(designResult.adapterRecords)
        : const <InternalEvidenceAdapterPacket>[];
    final base = _resultFromPackets(
      designResult: designResult,
      packets: packets,
      validationFindings: const <InternalEvidenceAdapterPrototypeFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromPackets(
      designResult: designResult,
      packets: packets,
      validationFindings: findings,
    );
  }
}

class InternalEvidenceAdapterPrototypeValidator {
  const InternalEvidenceAdapterPrototypeValidator();

  List<InternalEvidenceAdapterPrototypeFinding> validate(
    InternalEvidenceAdapterPrototypeResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <InternalEvidenceAdapterPrototypeFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required InternalEvidenceAdapterPrototypeValidationSeverity severity,
      required String message,
      String? adapterPacketId,
      InternalEvidenceSummaryGroupId? groupId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        InternalEvidenceAdapterPrototypeFinding(
          id: id,
          severity: severity,
          message: message,
          adapterPacketId: adapterPacketId,
          groupId: groupId,
          fieldId: fieldId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase32O &&
        (result.sourceDesignStatus ==
                InternalEvidenceAdapterDesignStatus.blockedByUnsafeSummary ||
            result.unsafeCount > 0)) {
      add(
        id: 'unsafeDesignMarkedRunnable',
        severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
        message: 'unsafe adapter design cannot be marked runnable',
      );
    }

    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: InternalEvidenceAdapterPrototypeValidationSeverity.blocker,
        message: 'owner proof requires explicit PV/MultiPV reason',
      );
    }

    for (final packet in result.packets) {
      for (final fieldId in packet.activeOutputFieldIds) {
        _checkActiveField(
          add,
          fieldId,
          adapterPacketId: packet.adapterPacketId,
          groupId: _firstGroupId(packet),
        );
      }
      if (_contextOnlyGroupIds.any(packet.sourceSummaryGroupIds.contains) &&
          packet.adapterRole ==
              InternalEvidenceAdapterPacketRole.coreEvidencePacket) {
        add(
          id: 'contextOnlyPacketPromotedToCore',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: '${packet.adapterPacketId} promoted context-only evidence',
          adapterPacketId: packet.adapterPacketId,
          groupId: _firstGroupId(packet),
        );
      }
      if (_blockedGroupIds.any(packet.sourceSummaryGroupIds.contains) &&
          (packet.adapterRole !=
                  InternalEvidenceAdapterPacketRole.blockedBoundaryPacket ||
              !packet.isInactiveSafe)) {
        add(
          id: 'blockedPacketMadeActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: '${packet.adapterPacketId} must remain inactive',
          adapterPacketId: packet.adapterPacketId,
          groupId: _firstGroupId(packet),
        );
      }
      if (packet.sourceSummaryGroupIds.contains(
            InternalEvidenceSummaryGroupId.futureOnlySummary,
          ) &&
          (packet.adapterRole !=
                  InternalEvidenceAdapterPacketRole.futureOnlyPacket ||
              !packet.isInactiveSafe)) {
        add(
          id: 'futureOnlyPacketMadeActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: '${packet.adapterPacketId} must remain future-only',
          adapterPacketId: packet.adapterPacketId,
          groupId: _firstGroupId(packet),
        );
      }
      if (packet.adapterRole ==
              InternalEvidenceAdapterPacketRole.coreEvidencePacket &&
          (packet.supportCaseIds.isEmpty ||
              packet.allowedEvidenceRecordIds.isEmpty)) {
        add(
          id: 'corePacketMissingSupportMapping',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.blocker,
          message: 'core adapter packet requires support and evidence IDs',
          adapterPacketId: packet.adapterPacketId,
          groupId: _firstGroupId(packet),
        );
      }
      if (packet.isProductOutput) {
        add(
          id: 'productOutputActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'packet cannot be product output',
          adapterPacketId: packet.adapterPacketId,
        );
      }
      if (packet.isClassifierLabel) {
        add(
          id: 'classifierLabelOutputActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'packet cannot emit classifier labels',
          adapterPacketId: packet.adapterPacketId,
        );
      }
      if (packet.isOfficialMetric) {
        add(
          id: 'officialMetricOutputActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'packet cannot emit official metrics',
          adapterPacketId: packet.adapterPacketId,
        );
      }
      if (packet.hasNumericScore) {
        add(
          id: 'numericScoreOutputActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'packet cannot emit numeric move values',
          adapterPacketId: packet.adapterPacketId,
        );
      }
      if (packet.ranksMoves) {
        add(
          id: 'moveRankingOutputActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'packet cannot order moves',
          adapterPacketId: packet.adapterPacketId,
        );
      }
      if (packet.cpLossOutputActive || packet.winProbabilityOutputActive) {
        add(
          id: 'futureMetricOutputActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'packet cannot activate CP-loss or win probability',
          adapterPacketId: packet.adapterPacketId,
        );
      }
      if (packet.quietPreparatoryScopeActive) {
        add(
          id: 'quietPreparatoryScopeActivated',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'quiet/preparatory scope must remain excluded',
          adapterPacketId: packet.adapterPacketId,
        );
      }
      if (packet.callsEngine) {
        add(
          id: 'engineCallFlagActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'adapter prototype packet cannot call an engine',
          adapterPacketId: packet.adapterPacketId,
        );
      }
      if (packet.writesPersistence) {
        add(
          id: 'persistenceWriteFlagActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'adapter prototype packet cannot write persistence',
          adapterPacketId: packet.adapterPacketId,
        );
      }
      if (packet.targetsUi) {
        add(
          id: 'uiTargetFlagActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'adapter prototype packet cannot target UI',
          adapterPacketId: packet.adapterPacketId,
        );
      }
      if (packet.backendOutputActive) {
        add(
          id: 'backendOutputActive',
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
          message: 'adapter prototype packet cannot target backend output',
          adapterPacketId: packet.adapterPacketId,
        );
      }
      for (final caseId in packet.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          adapterPacketId: packet.adapterPacketId,
          groupId: _firstGroupId(packet),
        );
      }
    }

    for (final fieldId in result.activeOutputFieldIds) {
      _checkActiveField(add, fieldId);
    }
    for (final caseId in result.androidProofCaseIds) {
      _checkAndroidProofCase(add, caseId, provenAndroidIds);
    }

    if (result.productOutputActive ||
        result.classifierOutputActive ||
        result.finalMoveLabelOutputActive ||
        result.officialMetricOutputActive ||
        result.cpLossOutputActive ||
        result.winProbabilityOutputActive ||
        result.numericOutputActive ||
        result.moveRankingOutputActive ||
        result.quietPreparatoryScopeActivated ||
        result.engineCallsActive ||
        result.persistenceWritesActive ||
        result.uiTargetsActive ||
        result.backendOutputActive) {
      add(
        id: 'prototypeBoundaryPolicyViolation',
        severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
        message: 'adapter prototype crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<InternalEvidenceAdapterPrototypeFinding> validateReportText(
    String reportText,
  ) {
    final findings = <InternalEvidenceAdapterPrototypeFinding>[];
    void reportError(String id, String message) {
      findings.add(
        InternalEvidenceAdapterPrototypeFinding(
          id: id,
          severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
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
    if (lower.contains('active fields: productlabel') ||
        lower.contains('active fields: finalmovelabel') ||
        lower.contains('active fields: numericmovescore')) {
      reportError(
        'activeBlockedFieldReportText',
        'report contains blocked active output text',
      );
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
        reportText.contains('moveRanking active')) {
      reportError(
        'moveOrderingReportText',
        'report contains active move ordering text',
      );
    }
    return findings..sort(_compareFindings);
  }
}

List<InternalEvidenceAdapterPacket> _packetsFromDesign(
  List<InternalEvidenceAdapterDesignRecord> records,
) {
  return records.map(_packetFromRecord).toList(growable: false);
}

InternalEvidenceAdapterPacket _packetFromRecord(
  InternalEvidenceAdapterDesignRecord record,
) {
  final role = _packetRoleFor(record.adapterRole);
  final activeOutputFieldIds = role.isInactive
      ? const <String>[]
      : _sortedStrings(record.allowedOutputFieldIds);
  return InternalEvidenceAdapterPacket(
    adapterPacketId: _packetIdFor(record),
    sourceAdapterRecordId: record.adapterRecordId,
    sourceSummaryGroupIds: <InternalEvidenceSummaryGroupId>[
      record.sourceSummaryGroupId,
    ],
    adapterRole: role,
    allowedEvidenceRecordIds: role.isInactive
        ? const <String>[]
        : _sortedStrings(record.allowedInputRecordIds),
    activeOutputFieldIds: activeOutputFieldIds,
    supportCaseIds: _sortedStrings(record.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(record.newlyAddedSupportCaseIds),
    evidenceAreaIds: _sortedAreaIds(record.evidenceAreaIds),
    bucketIds: _sortedBucketIds(record.bucketIds),
    qualitativeConfidence: _confidenceFor(role),
    internalWarnings: _warningsFor(record, role),
    internalConstraints: _constraintsFor(record, role),
    futurePrerequisites: _sortedStrings(<String>[record.futurePrerequisite]),
    androidProofCaseIds: _sortedStrings(record.androidProofCaseIds),
    proofLimitReason: record.proofLimitReason,
    watchListReason:
        record.sourceSummaryGroupId ==
            InternalEvidenceSummaryGroupId.constrainedWatchListSummary
        ? _firstNonEmpty(record.proofLimitReason, record.warningReason)
        : '',
    warningLimitedReason:
        record.sourceSummaryGroupId ==
            InternalEvidenceSummaryGroupId.warningLimitedSummary
        ? _firstNonEmpty(record.warningReason, record.futurePrerequisite)
        : '',
    blockedOutputFieldIds: _sortedStrings(record.blockedOutputFieldIds),
    isProductOutput: false,
    isClassifierLabel: false,
    isOfficialMetric: false,
    hasNumericScore: false,
    ranksMoves: false,
    callsEngine: false,
    writesPersistence: false,
    targetsUi: false,
    cpLossOutputActive: false,
    winProbabilityOutputActive: false,
    quietPreparatoryScopeActive: false,
    backendOutputActive: false,
  );
}

InternalEvidenceAdapterPrototypeResult _resultFromPackets({
  required InternalEvidenceAdapterDesignResult designResult,
  required List<InternalEvidenceAdapterPacket> packets,
  required List<InternalEvidenceAdapterPrototypeFinding> validationFindings,
}) {
  final packetUnsafeCount = packets
      .where((packet) => packet.hasUnsafeOutput)
      .length;
  final unsafeCount = designResult.unsafeCount + packetUnsafeCount;
  final criticalCount =
      designResult.criticalCount +
      validationFindings.where((finding) => finding.isCritical).length;
  final base = InternalEvidenceAdapterPrototypeResult(
    prototypeStatus: InternalEvidenceAdapterPrototypeStatus.invalid,
    sourceDesignStatus: designResult.designStatus,
    sourceSummaryStatus: designResult.sourceSummaryStatus,
    sourceReadinessStatus: designResult.sourceReadinessStatus,
    packets: packets,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...designResult.warnings,
      if (packets.any((packet) => packet.adapterRole.isContextOnly))
        'context-only prototype packets remain outside core output',
      if (packets.any((packet) => packet.adapterRole.isInactive))
        'blocked and future-only prototype packets remain inactive',
    ]),
    failures: _sortedStrings(<String>[
      ...designResult.failures,
      ...validationFindings.map((finding) => finding.message),
    ]),
    totalPackets: packets.length,
    corePacketCount: packets
        .where((packet) => packet.adapterRole.isCore)
        .length,
    contextOnlyPacketCount: packets
        .where((packet) => packet.adapterRole.isContextOnly)
        .length,
    blockedPacketCount: packets
        .where(
          (packet) =>
              packet.adapterRole ==
              InternalEvidenceAdapterPacketRole.blockedBoundaryPacket,
        )
        .length,
    futureOnlyPacketCount: packets
        .where(
          (packet) =>
              packet.adapterRole ==
              InternalEvidenceAdapterPacketRole.futureOnlyPacket,
        )
        .length,
    unsafeCount: unsafeCount,
    criticalCount: criticalCount,
    ownerProofQueueCount: designResult.ownerProofQueueCount,
    supportCaseIds: _sortedStrings(
      packets.expand((packet) => packet.supportCaseIds),
    ),
    newlyAddedSupportCaseIds: _sortedStrings(
      packets.expand((packet) => packet.newlyAddedSupportCaseIds),
    ),
    androidProofCaseIds: _sortedStrings(designResult.androidProofCaseIds),
    activeOutputFieldIds: _sortedStrings(
      packets.expand((packet) => packet.activeOutputFieldIds),
    ),
    blockedOutputFieldIds: _sortedStrings(designResult.blockedOutputFieldIds),
    safeForPhase32O: false,
    phase32ORecommendation:
        InternalEvidenceAdapterPrototypePhase32ORecommendation
            .addMoreGoldenCoverageFirst,
    productOutputActive: designResult.productOutputFieldsAllowed,
    classifierOutputActive: designResult.classifierOutputFieldsAllowed,
    finalMoveLabelOutputActive: designResult.finalMoveLabelOutputAllowed,
    officialMetricOutputActive: designResult.officialMetricOutputFieldsAllowed,
    cpLossOutputActive: designResult.cpLossOutputAllowed,
    winProbabilityOutputActive: designResult.winProbabilityOutputAllowed,
    numericOutputActive: designResult.numericMoveScoreOutputAllowed,
    moveRankingOutputActive: designResult.moveRankingOutputAllowed,
    quietPreparatoryScopeActivated: designResult.quietPreparatoryScopeActivated,
    engineCallsActive: designResult.directEngineAccessUsed,
    persistenceWritesActive: designResult.persistenceUsed,
    uiTargetsActive: designResult.uiOutputUsed,
    backendOutputActive: designResult.backendOutputUsed,
  );
  final status = _prototypeStatusFor(base, designResult: designResult);
  final safeForPhase32O =
      (status == InternalEvidenceAdapterPrototypeStatus.completedWithWarnings ||
          status == InternalEvidenceAdapterPrototypeStatus.completedClean) &&
      designResult.safeForPhase32N &&
      !designResult.isStrictlyBlocked &&
      !designResult.hasUnsafeAdapterDesignPolicyViolation &&
      unsafeCount == 0 &&
      criticalCount == 0 &&
      !validationFindings.any((finding) => finding.blocksStrict) &&
      packets.every(_packetSafeForPrototype);
  return base.copyWith(
    prototypeStatus: status,
    safeForPhase32O: safeForPhase32O,
    phase32ORecommendation: _phase32ORecommendationFor(
      status: status,
      safeForPhase32O: safeForPhase32O,
      ownerProofQueueCount: designResult.ownerProofQueueCount,
      contextOnlyPacketCount: base.contextOnlyPacketCount,
    ),
  );
}

InternalEvidenceAdapterPrototypeStatus _prototypeStatusFor(
  InternalEvidenceAdapterPrototypeResult result, {
  required InternalEvidenceAdapterDesignResult designResult,
}) {
  if (designResult.designStatus ==
          InternalEvidenceAdapterDesignStatus.blockedByUnsafeSummary ||
      designResult.unsafeCount > 0 ||
      result.unsafeCount > 0 ||
      result.criticalCount > 0 ||
      result.validationFindings.any((finding) => finding.isCritical)) {
    return InternalEvidenceAdapterPrototypeStatus.skippedByUnsafeDesign;
  }
  if (result.productOutputActive ||
      result.classifierOutputActive ||
      result.finalMoveLabelOutputActive ||
      result.officialMetricOutputActive ||
      result.cpLossOutputActive ||
      result.winProbabilityOutputActive ||
      result.numericOutputActive ||
      result.moveRankingOutputActive ||
      result.quietPreparatoryScopeActivated ||
      result.engineCallsActive ||
      result.persistenceWritesActive ||
      result.uiTargetsActive ||
      result.backendOutputActive ||
      result.activeOutputFieldIds.any(_isBlockedOutputFieldId)) {
    return InternalEvidenceAdapterPrototypeStatus.blockedByPolicyBoundary;
  }
  if (!designResult.safeForPhase32N ||
      designResult.isStrictlyBlocked ||
      result.validationFindings.any((finding) => finding.blocksStrict)) {
    return InternalEvidenceAdapterPrototypeStatus.invalid;
  }
  if (result.packets.isEmpty) {
    return InternalEvidenceAdapterPrototypeStatus.invalid;
  }
  if (result.contextOnlyPacketCount > 0 || result.warnings.isNotEmpty) {
    return InternalEvidenceAdapterPrototypeStatus.completedWithWarnings;
  }
  return InternalEvidenceAdapterPrototypeStatus.completedClean;
}

InternalEvidenceAdapterPrototypePhase32ORecommendation
_phase32ORecommendationFor({
  required InternalEvidenceAdapterPrototypeStatus status,
  required bool safeForPhase32O,
  required int ownerProofQueueCount,
  required int contextOnlyPacketCount,
}) {
  if (status == InternalEvidenceAdapterPrototypeStatus.skippedByUnsafeDesign ||
      status ==
          InternalEvidenceAdapterPrototypeStatus.blockedByPolicyBoundary) {
    return InternalEvidenceAdapterPrototypePhase32ORecommendation
        .blockedByUnsafeAdapterPrototype;
  }
  if (ownerProofQueueCount > 0) {
    return InternalEvidenceAdapterPrototypePhase32ORecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase32O) {
    return InternalEvidenceAdapterPrototypePhase32ORecommendation
        .addMoreGoldenCoverageFirst;
  }
  if (contextOnlyPacketCount > 0) {
    return InternalEvidenceAdapterPrototypePhase32ORecommendation
        .reviewInternalEvidenceAdapterPrototype;
  }
  return InternalEvidenceAdapterPrototypePhase32ORecommendation
      .proceedToAdapterPrototypeValidation;
}

bool _packetSafeForPrototype(InternalEvidenceAdapterPacket packet) {
  if (packet.hasUnsafeOutput) return false;
  if (packet.adapterRole.isCore) {
    return packet.supportCaseIds.isNotEmpty &&
        packet.allowedEvidenceRecordIds.isNotEmpty &&
        packet.activeOutputFieldIds.isNotEmpty;
  }
  if (packet.adapterRole.isContextOnly) {
    return packet.activeOutputFieldIds.isNotEmpty &&
        !packet.activeOutputFieldIds.any(_isBlockedOutputFieldId);
  }
  return packet.isInactiveSafe;
}

InternalEvidenceAdapterPacketRole _packetRoleFor(
  InternalEvidenceAdapterRole role,
) {
  return switch (role) {
    InternalEvidenceAdapterRole.coreEvidence =>
      InternalEvidenceAdapterPacketRole.coreEvidencePacket,
    InternalEvidenceAdapterRole.contextualConstraint =>
      InternalEvidenceAdapterPacketRole.contextOnlyPacket,
    InternalEvidenceAdapterRole.blockedBoundary =>
      InternalEvidenceAdapterPacketRole.blockedBoundaryPacket,
    InternalEvidenceAdapterRole.futureOnlyInput =>
      InternalEvidenceAdapterPacketRole.futureOnlyPacket,
  };
}

String _packetIdFor(InternalEvidenceAdapterDesignRecord record) {
  return record.adapterRecordId.replaceFirst('adapter-', 'packet-');
}

String _confidenceFor(InternalEvidenceAdapterPacketRole role) {
  return switch (role) {
    InternalEvidenceAdapterPacketRole.coreEvidencePacket =>
      'summary-backed internal evidence',
    InternalEvidenceAdapterPacketRole.contextOnlyPacket =>
      'constraint-only internal evidence',
    InternalEvidenceAdapterPacketRole.blockedBoundaryPacket =>
      'inactive blocked boundary',
    InternalEvidenceAdapterPacketRole.futureOnlyPacket =>
      'inactive future-only boundary',
  };
}

List<String> _warningsFor(
  InternalEvidenceAdapterDesignRecord record,
  InternalEvidenceAdapterPacketRole role,
) {
  return _sortedStrings(<String>[
    if (role.isContextOnly) 'context-only packet, not core output',
    if (record.warningReason.isNotEmpty) record.warningReason,
  ]);
}

List<String> _constraintsFor(
  InternalEvidenceAdapterDesignRecord record,
  InternalEvidenceAdapterPacketRole role,
) {
  return _sortedStrings(<String>[
    'developer-only internal adapter packet',
    if (role.isContextOnly) 'must remain context-only',
    if (role.isInactive) 'must remain inactive',
    if (record.proofLimitReason.isNotEmpty) record.proofLimitReason,
    if (record.blockedReason.isNotEmpty) record.blockedReason,
  ]);
}

String _firstNonEmpty(String first, String second) {
  return first.isNotEmpty ? first : second;
}

void _checkActiveField(
  void Function({
    required String id,
    required InternalEvidenceAdapterPrototypeValidationSeverity severity,
    required String message,
    String? adapterPacketId,
    InternalEvidenceSummaryGroupId? groupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String fieldId, {
  String? adapterPacketId,
  InternalEvidenceSummaryGroupId? groupId,
}) {
  if (!_isBlockedOutputFieldId(fieldId)) return;
  add(
    id: 'blockedOutputFieldActive',
    severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
    message: '$fieldId cannot be an active prototype output field',
    adapterPacketId: adapterPacketId,
    groupId: groupId,
    fieldId: fieldId,
  );
  if (fieldId == 'productLabel') {
    add(
      id: 'productOutputActive',
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: 'product label field cannot be active',
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'finalMoveLabel' ||
      fieldId == 'brilliantGreatMissStyleLabels' ||
      fieldId == 'bestGoodInaccuracyMistakeBlunderStyleLabels') {
    add(
      id: 'classifierLabelOutputActive',
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: 'classifier or final label field cannot be active',
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'numericMoveScore') {
    add(
      id: 'numericScoreOutputActive',
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: 'numeric move value field cannot be active',
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'moveRanking') {
    add(
      id: 'moveRankingOutputActive',
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: 'move ordering field cannot be active',
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'officialAccuracy' || fieldId == 'acpl') {
    add(
      id: 'officialMetricOutputActive',
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: 'official metric field cannot be active',
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'cpLoss' || fieldId == 'winProbability') {
    add(
      id: 'futureMetricOutputActive',
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: 'future metric field cannot be active',
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'uiOutputFields' ||
      fieldId == 'backendPersistenceFields' ||
      fieldId == 'directEngineCallFields') {
    add(
      id: 'integrationOutputActive',
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: 'integration output field cannot be active',
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
}

void _checkAndroidProofCase(
  void Function({
    required String id,
    required InternalEvidenceAdapterPrototypeValidationSeverity severity,
    required String message,
    String? adapterPacketId,
    InternalEvidenceSummaryGroupId? groupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String caseId,
  Set<String> provenAndroidIds, {
  String? adapterPacketId,
  InternalEvidenceSummaryGroupId? groupId,
}) {
  if (!_capturedAndroidProofIds.contains(caseId) ||
      !provenAndroidIds.contains(caseId)) {
    add(
      id: 'unprovenAndroidProofClaim',
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: 'adapter prototype cited unproven Android proof',
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      caseId: caseId,
    );
  }
  if (_phase32ECaseIds.contains(caseId)) {
    add(
      id: 'phase32ECaseClaimedCapturedProof',
      severity: InternalEvidenceAdapterPrototypeValidationSeverity.critical,
      message: 'Phase 32E case cannot be captured Android proof',
      adapterPacketId: adapterPacketId,
      groupId: groupId,
      caseId: caseId,
    );
  }
}

bool _hasExplicitPvProofReason(InternalEvidenceAdapterPrototypeResult result) {
  final reasons = <String>[
    ...result.packets.expand((packet) => packet.internalWarnings),
    ...result.packets.expand((packet) => packet.internalConstraints),
    ...result.packets.expand((packet) => packet.futurePrerequisites),
    ...result.packets.map((packet) => packet.proofLimitReason),
    ...result.packets.map((packet) => packet.watchListReason),
  ].join(' ').toLowerCase();
  return reasons.contains('pv') || reasons.contains('multipv');
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

String _packetIds(Iterable<InternalEvidenceAdapterPacket> packets) {
  return _ids(packets.map((packet) => packet.adapterPacketId));
}

InternalEvidenceSummaryGroupId? _firstGroupId(
  InternalEvidenceAdapterPacket packet,
) {
  return packet.sourceSummaryGroupIds.isEmpty
      ? null
      : packet.sourceSummaryGroupIds.first;
}

String _cell(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? '-' : normalized.replaceAll('|', '/');
}

String _ids(Iterable<String> values) {
  final ids = _sortedStrings(values);
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _groupIds(Iterable<InternalEvidenceSummaryGroupId> values) {
  final ids = values.map((id) => id.wire).toSet().toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _areaIds(Iterable<InternalEvidenceAreaId> values) {
  final ids = values.map((id) => id.wire).toSet().toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

String _bucketIds(Iterable<InternalEvidenceBucketId> values) {
  final ids = values.map((id) => id.wire).toSet().toList()..sort();
  return ids.isEmpty ? '-' : ids.join(', ');
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.where((value) => value.isNotEmpty).toSet().toList()..sort();
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

int _compareFindings(
  InternalEvidenceAdapterPrototypeFinding a,
  InternalEvidenceAdapterPrototypeFinding b,
) {
  final severityCompare = b.severity.index.compareTo(a.severity.index);
  if (severityCompare != 0) return severityCompare;
  final idCompare = a.id.compareTo(b.id);
  if (idCompare != 0) return idCompare;
  final packetCompare = (a.adapterPacketId ?? '').compareTo(
    b.adapterPacketId ?? '',
  );
  if (packetCompare != 0) return packetCompare;
  final groupCompare = (a.groupId?.wire ?? '').compareTo(b.groupId?.wire ?? '');
  if (groupCompare != 0) return groupCompare;
  final fieldCompare = (a.fieldId ?? '').compareTo(b.fieldId ?? '');
  if (fieldCompare != 0) return fieldCompare;
  return (a.caseId ?? '').compareTo(b.caseId ?? '');
}

bool _isBlockedOutputFieldId(String value) {
  return _blockedOutputFieldIds.contains(value);
}

const _contextOnlyGroupIds = <InternalEvidenceSummaryGroupId>{
  InternalEvidenceSummaryGroupId.constrainedWatchListSummary,
  InternalEvidenceSummaryGroupId.proofLimitedSummary,
  InternalEvidenceSummaryGroupId.warningLimitedSummary,
};

const _blockedGroupIds = <InternalEvidenceSummaryGroupId>{
  InternalEvidenceSummaryGroupId.blockedBoundarySummary,
};

const _phase32ECaseIds = <String>{
  'king-safety-mating-net-pressure-32e',
  'endgame-precision-candidate-spread-32e',
  'suppression-forced-only-legal-32e',
  'budget-pressure-wide-candidate-32e',
  'pv-multipv-support-boundary-32e',
};

const _capturedAndroidProofIds = <String>{
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
};

const _blockedOutputFieldIds = <String>{
  'productLabel',
  'finalMoveLabel',
  'brilliantGreatMissStyleLabels',
  'bestGoodInaccuracyMistakeBlunderStyleLabels',
  'numericMoveScore',
  'officialAccuracy',
  'acpl',
  'cpLoss',
  'winProbability',
  'moveRanking',
  'uiOutputFields',
  'backendPersistenceFields',
  'directEngineCallFields',
};

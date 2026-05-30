/// Static developer evidence ingested from owner-run Android golden proof.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_policy.dart';

const goldenAndroidProofEvidenceVersion = 'golden-android-proof-evidence-v1';

class GoldenAndroidProofEvidence {
  const GoldenAndroidProofEvidence({
    required this.proofVersion,
    required this.sourceId,
    required this.sourceNote,
    required this.deviceFamily,
    required this.deviceModel,
    required this.platform,
    required this.abi,
    required this.engineIdentity,
    required this.stubIdentityDetected,
    required this.runs,
  });

  final String proofVersion;
  final String sourceId;
  final String sourceNote;
  final String deviceFamily;
  final String deviceModel;
  final String platform;
  final String abi;
  final String engineIdentity;
  final bool stubIdentityDetected;
  final List<GoldenAndroidProofRunEvidence> runs;

  static const phase30uS22Ultra = GoldenAndroidProofEvidence(
    proofVersion: goldenAndroidProofEvidenceVersion,
    sourceId: 's22-ultra-phase-30u-owner-queue',
    sourceNote: 'owner-run Android proof, developer evidence only',
    deviceFamily: 'S22 Ultra',
    deviceModel: 'SM S908U1',
    platform: 'android',
    abi: 'arm64-v8a',
    engineIdentity: 'apex-stockfish-bridge/0.3.0',
    stubIdentityDetected: false,
    runs: <GoldenAndroidProofRunEvidence>[
      _balancedDefaultRun,
      _performanceMeasuredRun,
    ],
  );

  List<String> get targetCaseIds {
    final ids = <String>{};
    for (final run in runs) {
      for (final row in run.caseRows) {
        ids.add(row.caseId);
      }
    }
    return ids.toList()..sort();
  }

  List<GoldenAndroidProofCaseEvidence> rowsFor(String caseId) {
    final rows = <GoldenAndroidProofCaseEvidence>[];
    for (final run in runs) {
      rows.addAll(run.caseRows.where((row) => row.caseId == caseId));
    }
    rows.sort((a, b) => _presetRank(a.preset).compareTo(_presetRank(b.preset)));
    return List<GoldenAndroidProofCaseEvidence>.unmodifiable(rows);
  }

  GoldenAndroidProofCaseEvidence? preferredRowFor(String caseId) {
    final rows = rowsFor(caseId);
    if (rows.isEmpty) return null;
    for (final row in rows) {
      if (row.preset == 'balancedDefault' && row.isCaptured) return row;
    }
    for (final row in rows) {
      if (row.isCaptured) return row;
    }
    return rows.first;
  }

  Map<DeepCandidateReasonCode, int> reasonCountsFor(String caseId) {
    final counts = <DeepCandidateReasonCode, int>{};
    for (final row in rowsFor(caseId).where((row) => row.isCaptured)) {
      for (final entry in row.reasonCodeCounts.entries) {
        counts[entry.key] = _maxInt(counts[entry.key] ?? 0, entry.value);
      }
    }
    return Map<DeepCandidateReasonCode, int>.unmodifiable(counts);
  }

  bool isRealDeviceProofCapturedFor(
    String caseId, {
    int? minMultiPvLineCount,
    bool requirePv = false,
  }) {
    if (stubIdentityDetected) return false;
    if (platform != 'android') return false;
    if (abi != 'arm64-v8a') return false;
    if (engineIdentity.trim().isEmpty) return false;
    final minMultiPv = minMultiPvLineCount ?? 0;
    return rowsFor(caseId).any(
      (row) =>
          row.isCaptured &&
          row.failures.isEmpty &&
          row.selectedDeepCount > 0 &&
          row.executedDeepCount > 0 &&
          (!requirePv || row.pvPresent) &&
          row.multiPvLineCount >= minMultiPv,
    );
  }

  String renderMarkdownSummary() {
    final buffer = StringBuffer()
      ..writeln('## Android Proof Evidence')
      ..writeln('- source: $sourceId')
      ..writeln('- proof version: $proofVersion')
      ..writeln('- source note: $sourceNote')
      ..writeln('- device: $deviceFamily / $deviceModel')
      ..writeln('- platform: $platform')
      ..writeln('- ABI: $abi')
      ..writeln('- engine identity: $engineIdentity')
      ..writeln('- stub identity detected: $stubIdentityDetected')
      ..writeln('- proven case IDs: ${targetCaseIds.join(", ")}');
    return buffer.toString().trimRight();
  }

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'proofVersion': proofVersion,
      'sourceId': sourceId,
      'sourceNote': sourceNote,
      'deviceFamily': deviceFamily,
      'deviceModel': deviceModel,
      'platform': platform,
      'abi': abi,
      'engineIdentity': engineIdentity,
      'stubIdentityDetected': stubIdentityDetected,
      'targetCaseIds': targetCaseIds,
      'runs': runs.map((run) => run.toJson()).toList(),
      'developerOnly': true,
      'productClaims': false,
    };
  }
}

class GoldenAndroidProofRunEvidence {
  const GoldenAndroidProofRunEvidence({
    required this.preset,
    required this.status,
    required this.targetCaseCount,
    required this.executedTargetCount,
    required this.selectedDeepCount,
    required this.executedDeepCount,
    required this.fastEngineCalls,
    required this.deepEngineCalls,
    required this.totalEngineCalls,
    required this.elapsedMs,
    required this.timeoutCount,
    required this.warningCount,
    required this.failureCount,
    required this.budgetPressureCount,
    required this.missingPvCount,
    required this.insufficientMultiPvCount,
    required this.warnings,
    required this.failures,
    required this.caseRows,
  });

  final String preset;
  final String status;
  final int targetCaseCount;
  final int executedTargetCount;
  final int selectedDeepCount;
  final int executedDeepCount;
  final int fastEngineCalls;
  final int deepEngineCalls;
  final int totalEngineCalls;
  final int elapsedMs;
  final int timeoutCount;
  final int warningCount;
  final int failureCount;
  final int budgetPressureCount;
  final int missingPvCount;
  final int insufficientMultiPvCount;
  final List<String> warnings;
  final List<String> failures;
  final List<GoldenAndroidProofCaseEvidence> caseRows;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'preset': preset,
      'status': status,
      'targetCaseCount': targetCaseCount,
      'executedTargetCount': executedTargetCount,
      'selectedDeepCount': selectedDeepCount,
      'executedDeepCount': executedDeepCount,
      'fastEngineCalls': fastEngineCalls,
      'deepEngineCalls': deepEngineCalls,
      'totalEngineCalls': totalEngineCalls,
      'elapsedMs': elapsedMs,
      'timeoutCount': timeoutCount,
      'warningCount': warningCount,
      'failureCount': failureCount,
      'budgetPressureCount': budgetPressureCount,
      'missingPvCount': missingPvCount,
      'insufficientMultiPvCount': insufficientMultiPvCount,
      'warnings': warnings,
      'failures': failures,
      'caseRows': caseRows.map((row) => row.toJson()).toList(),
    };
  }
}

class GoldenAndroidProofCaseEvidence {
  const GoldenAndroidProofCaseEvidence({
    required this.caseId,
    required this.preset,
    required this.proofStatus,
    required this.selectedDeepCount,
    required this.executedDeepCount,
    required this.pvPresent,
    required this.multiPvLineCount,
    required this.reasonCodeCounts,
    required this.warnings,
    required this.failures,
    required this.nextAction,
  });

  final String caseId;
  final String preset;
  final String proofStatus;
  final int selectedDeepCount;
  final int executedDeepCount;
  final bool pvPresent;
  final int multiPvLineCount;
  final Map<DeepCandidateReasonCode, int> reasonCodeCounts;
  final List<String> warnings;
  final List<String> failures;
  final String nextAction;

  bool get isCaptured =>
      proofStatus == 'proofCaptured' ||
      proofStatus == 'proofCapturedWithWarnings';

  Map<String, Object?> toJson() {
    final reasonEntries = reasonCodeCounts.entries.toList()
      ..sort((a, b) => a.key.wire.compareTo(b.key.wire));
    return <String, Object?>{
      'caseId': caseId,
      'preset': preset,
      'proofStatus': proofStatus,
      'selectedDeepCount': selectedDeepCount,
      'executedDeepCount': executedDeepCount,
      'pvPresent': pvPresent,
      'multiPvLineCount': multiPvLineCount,
      'reasonCodeCounts': <String, Object?>{
        for (final entry in reasonEntries) entry.key.wire: entry.value,
      },
      'warnings': warnings,
      'failures': failures,
      'nextAction': nextAction,
    };
  }
}

const _balancedDefaultRun = GoldenAndroidProofRunEvidence(
  preset: 'balancedDefault',
  status: 'completedWithWarnings',
  targetCaseCount: 3,
  executedTargetCount: 3,
  selectedDeepCount: 3,
  executedDeepCount: 3,
  fastEngineCalls: 3,
  deepEngineCalls: 6,
  totalEngineCalls: 9,
  elapsedMs: 1672,
  timeoutCount: 0,
  warningCount: 1,
  failureCount: 0,
  budgetPressureCount: 0,
  missingPvCount: 0,
  insufficientMultiPvCount: 0,
  warnings: <String>['real Android golden owner proof queue run'],
  failures: <String>[],
  caseRows: <GoldenAndroidProofCaseEvidence>[
    GoldenAndroidProofCaseEvidence(
      caseId: 'mate-threat-fast-evidence',
      preset: 'balancedDefault',
      proofStatus: 'proofCaptured',
      selectedDeepCount: 1,
      executedDeepCount: 1,
      pvPresent: true,
      multiPvLineCount: 3,
      reasonCodeCounts: <DeepCandidateReasonCode, int>{
        DeepCandidateReasonCode.candidateEvalSpread: 1,
        DeepCandidateReasonCode.givesCheck: 1,
        DeepCandidateReasonCode.tacticalSignal: 1,
      },
      warnings: <String>[],
      failures: <String>[],
      nextAction: 'updateGoldenEvidence',
    ),
    GoldenAndroidProofCaseEvidence(
      caseId: 'queen-win-major-swing',
      preset: 'balancedDefault',
      proofStatus: 'proofCaptured',
      selectedDeepCount: 1,
      executedDeepCount: 1,
      pvPresent: true,
      multiPvLineCount: 3,
      reasonCodeCounts: <DeepCandidateReasonCode, int>{
        DeepCandidateReasonCode.captureOrPromotion: 1,
        DeepCandidateReasonCode.majorEvalSwing: 1,
        DeepCandidateReasonCode.materialSwing: 1,
        DeepCandidateReasonCode.previousEvalAvailable: 1,
      },
      warnings: <String>[],
      failures: <String>[],
      nextAction: 'updateGoldenEvidence',
    ),
    GoldenAndroidProofCaseEvidence(
      caseId: 'simple-tactical-capture-check',
      preset: 'balancedDefault',
      proofStatus: 'proofCaptured',
      selectedDeepCount: 1,
      executedDeepCount: 1,
      pvPresent: true,
      multiPvLineCount: 3,
      reasonCodeCounts: <DeepCandidateReasonCode, int>{
        DeepCandidateReasonCode.candidateEvalSpread: 1,
        DeepCandidateReasonCode.captureOrPromotion: 1,
        DeepCandidateReasonCode.givesCheck: 1,
        DeepCandidateReasonCode.tacticalSignal: 1,
      },
      warnings: <String>[],
      failures: <String>[],
      nextAction: 'updateGoldenEvidence',
    ),
  ],
);

const _performanceMeasuredRun = GoldenAndroidProofRunEvidence(
  preset: 'performanceMeasured',
  status: 'completedWithWarnings',
  targetCaseCount: 3,
  executedTargetCount: 3,
  selectedDeepCount: 6,
  executedDeepCount: 6,
  fastEngineCalls: 6,
  deepEngineCalls: 12,
  totalEngineCalls: 18,
  elapsedMs: 4505,
  timeoutCount: 0,
  warningCount: 1,
  failureCount: 0,
  budgetPressureCount: 0,
  missingPvCount: 0,
  insufficientMultiPvCount: 0,
  warnings: <String>['real Android golden owner proof queue run'],
  failures: <String>[],
  caseRows: <GoldenAndroidProofCaseEvidence>[
    GoldenAndroidProofCaseEvidence(
      caseId: 'mate-threat-fast-evidence',
      preset: 'performanceMeasured',
      proofStatus: 'proofCaptured',
      selectedDeepCount: 1,
      executedDeepCount: 1,
      pvPresent: true,
      multiPvLineCount: 3,
      reasonCodeCounts: <DeepCandidateReasonCode, int>{
        DeepCandidateReasonCode.candidateEvalSpread: 1,
        DeepCandidateReasonCode.givesCheck: 1,
        DeepCandidateReasonCode.tacticalSignal: 1,
      },
      warnings: <String>[],
      failures: <String>[],
      nextAction: 'updateGoldenEvidence',
    ),
    GoldenAndroidProofCaseEvidence(
      caseId: 'queen-win-major-swing',
      preset: 'performanceMeasured',
      proofStatus: 'proofCaptured',
      selectedDeepCount: 1,
      executedDeepCount: 1,
      pvPresent: true,
      multiPvLineCount: 3,
      reasonCodeCounts: <DeepCandidateReasonCode, int>{
        DeepCandidateReasonCode.captureOrPromotion: 1,
        DeepCandidateReasonCode.majorEvalSwing: 1,
        DeepCandidateReasonCode.materialSwing: 1,
        DeepCandidateReasonCode.previousEvalAvailable: 1,
      },
      warnings: <String>[],
      failures: <String>[],
      nextAction: 'updateGoldenEvidence',
    ),
    GoldenAndroidProofCaseEvidence(
      caseId: 'simple-tactical-capture-check',
      preset: 'performanceMeasured',
      proofStatus: 'proofCaptured',
      selectedDeepCount: 1,
      executedDeepCount: 1,
      pvPresent: true,
      multiPvLineCount: 3,
      reasonCodeCounts: <DeepCandidateReasonCode, int>{
        DeepCandidateReasonCode.candidateEvalSpread: 1,
        DeepCandidateReasonCode.captureOrPromotion: 1,
        DeepCandidateReasonCode.givesCheck: 1,
        DeepCandidateReasonCode.tacticalSignal: 1,
      },
      warnings: <String>[],
      failures: <String>[],
      nextAction: 'updateGoldenEvidence',
    ),
  ],
);

int _presetRank(String preset) {
  return switch (preset) {
    'balancedDefault' => 0,
    'performanceMeasured' => 1,
    _ => 2,
  };
}

int _maxInt(int a, int b) => a > b ? a : b;

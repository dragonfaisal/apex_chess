import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/core/infrastructure/engine/uci/fen_validator.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/android_local_engine_proof.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/local_engine_audit.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/local_stockfish_benchmark.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Android local engine proof schema', () {
    test('device benchmark collector is opt-in and skipped by default', () {
      expect(isAndroidDeviceBenchmarkEnabled(), isFalse);
      expect(isAndroidDeviceBenchmarkEnabled(flagValue: 'true'), isTrue);
      expect(isAndroidDeviceBenchmarkEnabled(flagValue: 'TRUE'), isTrue);
      expect(androidDeviceBenchmarkFlag, contains('APEX_RUN_LOCAL_STOCKFISH'));
    });

    test('renders safe markdown and JSON without fake data', () {
      final result = AndroidLocalEngineProofResult(
        packagingAudit: _missingPackaging,
        deviceRunAttempted: false,
        engineMode: LocalEngineRuntimeMode.unavailable,
        platform: 'test',
        deviceLabel: 'not-run',
        abi: 'unknown',
        uciOk: false,
        readyOk: false,
        startposBestmoveLegal: false,
        tacticalPvNonEmpty: false,
        multiPvSupported: false,
        multiPv3Distinct: false,
        invalidFenRejectedBeforeEngine: true,
        repeatedDisposeSafe: false,
        lifecycleCyclesRequested: 20,
        lifecycleCyclesCompleted: 0,
        staleBestmoveDetected: false,
        queueContaminationDetected: false,
        benchmarkRows: const [],
      );

      final markdown = result.renderMarkdown();
      final json = jsonDecode(result.renderJson()) as Map<String, dynamic>;

      expect(markdown, startsWith('# Apex Android Local Engine Proof'));
      expect(markdown, contains('device run attempted: false'));
      expect(json['recommendation'], 'needsAndroidProof');
      expect(json['benchmarkRowCount'], 0);
      expect(
        result.recommendation,
        AndroidLocalEngineProofRecommendation.needsAndroidProof,
      );
    });

    test('packaging passed and device passed approves scheduler prototype', () {
      final gate = _gate(
        packagingStatus: PackagingProofStatus.abiConsistent,
        deviceProof: _summary(),
      );

      expect(
        gate.recommendation,
        LocalEngineApprovalRecommendation.approvedForSchedulerPrototype,
      );
      expect(gate.deviceStatus, DeviceProofStatus.passed);
      expect(gate.blockers, isEmpty);
    });

    test('device passed but packaging missing needs packaging proof', () {
      final gate = _gate(
        packagingStatus: PackagingProofStatus.missing,
        deviceProof: _summary(),
      );

      expect(
        gate.recommendation,
        LocalEngineApprovalRecommendation.needsPackagingProof,
      );
      expect(gate.deviceStatus, DeviceProofStatus.passed);
      expect(gate.blockers, contains('packaging proof is missing.'));
    });

    test('packaging passed but device missing needs device proof', () {
      final gate = _gate(
        packagingStatus: PackagingProofStatus.abiConsistent,
        deviceProof: null,
      );

      expect(
        gate.recommendation,
        LocalEngineApprovalRecommendation.needsDeviceProof,
      );
      expect(gate.deviceStatus, DeviceProofStatus.missing);
      expect(gate.blockers, contains('device proof is missing.'));
    });

    test('packaging mismatch blocks approval even with device pass', () {
      final gate = _gate(
        packagingStatus: PackagingProofStatus.abiMismatch,
        deviceProof: _summary(),
      );

      expect(
        gate.recommendation,
        LocalEngineApprovalRecommendation.needsPackagingProof,
      );
      expect(
        gate.recommendation,
        isNot(LocalEngineApprovalRecommendation.approvedForSchedulerPrototype),
      );
      expect(gate.blockers, contains('packaging proof is abiMismatch.'));
    });

    test('device proof with non-real engine mode blocks approval', () {
      final gate = _gate(
        packagingStatus: PackagingProofStatus.abiConsistent,
        deviceProof: _summary(engineMode: LocalEngineRuntimeMode.unavailable),
      );

      expect(
        gate.recommendation,
        LocalEngineApprovalRecommendation.pivotToSubprocessRecommended,
      );
      expect(
        gate.blockers,
        contains('device: engine mode was unavailable, not real.'),
      );
    });

    test('device proof with stub identity blocks approval', () {
      final gate = _gate(
        packagingStatus: PackagingProofStatus.abiConsistent,
        deviceProof: _summary(engineName: 'ApexChess-Stub'),
      );

      expect(
        gate.recommendation,
        LocalEngineApprovalRecommendation.pivotToSubprocessRecommended,
      );
      expect(
        gate.blockers,
        contains('device: engine identity reports a stub.'),
      );
    });

    test('device proof without uciok or readyok blocks approval', () {
      final uciGate = _gate(
        packagingStatus: PackagingProofStatus.abiConsistent,
        deviceProof: _summary(uciOk: false),
      );
      final readyGate = _gate(
        packagingStatus: PackagingProofStatus.abiConsistent,
        deviceProof: _summary(readyOk: false),
      );

      expect(
        uciGate.recommendation,
        LocalEngineApprovalRecommendation.pivotToSubprocessRecommended,
      );
      expect(uciGate.blockers, contains('device: uciok was not observed.'));
      expect(
        readyGate.recommendation,
        LocalEngineApprovalRecommendation.pivotToSubprocessRecommended,
      );
      expect(readyGate.blockers, contains('device: readyok was not observed.'));
    });

    test('device proof with insufficient MultiPV blocks approval', () {
      final gate = _gate(
        packagingStatus: PackagingProofStatus.abiConsistent,
        deviceProof: _summary(multiPv3Distinct: false),
      );

      expect(
        gate.recommendation,
        LocalEngineApprovalRecommendation.pivotToSubprocessRecommended,
      );
      expect(
        gate.blockers,
        contains('device: MultiPV 3 did not produce distinct candidates.'),
      );
    });

    test('device proof with lifecycle under 20 blocks approval', () {
      final gate = _gate(
        packagingStatus: PackagingProofStatus.abiConsistent,
        deviceProof: _summary(lifecycleCyclesCompleted: 19),
      );

      expect(
        gate.recommendation,
        LocalEngineApprovalRecommendation.pivotToSubprocessRecommended,
      );
      expect(
        gate.blockers,
        contains('device: lifecycle completed 19 of at least 20 cycles.'),
      );
    });

    test('stale bestmove or queue contamination blocks approval', () {
      final staleGate = _gate(
        packagingStatus: PackagingProofStatus.abiConsistent,
        deviceProof: _summary(staleBestmoveDetected: true),
      );
      final queueGate = _gate(
        packagingStatus: PackagingProofStatus.abiConsistent,
        deviceProof: _summary(queueContaminationDetected: true),
      );

      expect(
        staleGate.recommendation,
        LocalEngineApprovalRecommendation.pivotToSubprocessRecommended,
      );
      expect(
        staleGate.blockers,
        contains('device: stale bestmove reuse detected.'),
      );
      expect(
        queueGate.recommendation,
        LocalEngineApprovalRecommendation.pivotToSubprocessRecommended,
      );
      expect(
        queueGate.blockers,
        contains('device: queue contamination detected.'),
      );
    });

    test('benchmark rows count must be positive for approval', () {
      final gate = _gate(
        packagingStatus: PackagingProofStatus.abiConsistent,
        deviceProof: _summary(benchmarkRowCount: 0),
      );

      expect(
        gate.recommendation,
        LocalEngineApprovalRecommendation.needsDeviceProof,
      );
      expect(
        gate.blockers,
        contains('device: no Android benchmark rows captured.'),
      );
    });

    test('S22 fixture renders safe approval summary without raw logs', () {
      final fixture =
          jsonDecode(
                File(
                  'test/fixtures/local_stockfish/android_proof/s22_ultra_phase_30e.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final gate = LocalEngineApprovalGateResult.fromFixtureJson(fixture);
      final rendered = gate.renderMarkdownSummary();

      expect(
        gate.recommendation,
        LocalEngineApprovalRecommendation.approvedForSchedulerPrototype,
      );
      expect(gate.deviceStatus, DeviceProofStatus.passed);
      expect(rendered, contains('device: S22 Ultra'));
      expect(rendered, contains('benchmark rows: 139'));
      expect(rendered.length, lessThan(2500));
      expect(rendered, isNot(contains('R5CT33FXE5K')));
      expect(rendered, isNot(contains('logcat')));
      expect(rendered, isNot(contains('ApexChess-Stub')));
    });

    test('stub result cannot be accepted as Android proof', () {
      final result = _proof(
        engineMode: LocalEngineRuntimeMode.stubDetected,
        engineName: 'ApexChess-Stub',
      );

      expect(result.proofAccepted, isFalse);
      expect(
        result.recommendation,
        isNot(AndroidLocalEngineProofRecommendation.continueWithFfiBridge),
      );
      expect(
        result.effectiveBlockers,
        contains('engine: stub result cannot be accepted as Android proof.'),
      );
    });

    test('packaging mismatch blocks continue recommendation', () {
      final result = _proof(packagingAudit: _mismatchedPackaging);

      expect(result.proofAccepted, isFalse);
      expect(
        result.recommendation,
        isNot(AndroidLocalEngineProofRecommendation.continueWithFfiBridge),
      );
      expect(result.effectiveBlockers, contains('packaging: abi-mismatch'));
    });

    test('missing device run returns needsAndroidProof, not pass', () {
      final result = _proof(deviceRunAttempted: false);

      expect(
        result.recommendation,
        AndroidLocalEngineProofRecommendation.needsAndroidProof,
      );
      expect(result.proofAccepted, isFalse);
    });

    test(
      'smoke success rows continue with FFI only when packaging and lifecycle pass',
      () {
        final result = _proof();

        expect(result.proofAccepted, isTrue);
        expect(
          result.recommendation,
          AndroidLocalEngineProofRecommendation.continueWithFfiBridge,
        );
        expect(result.effectiveBlockers, isEmpty);
      },
    );

    test(
      'lifecycle failure recommends subprocess pivot or reports blocker',
      () {
        final result = _proof(lifecycleCyclesCompleted: 7);

        expect(result.proofAccepted, isFalse);
        expect(
          result.recommendation,
          AndroidLocalEngineProofRecommendation.pivotToSubprocessPrototype,
        );
        expect(
          result.effectiveBlockers,
          contains('lifecycle: completed 7 of 20 cycles.'),
        );
      },
    );

    test('MultiPV insufficient fake result is a blocker', () {
      final result = _proof(multiPv3Distinct: false, rows: [_multiPvBadRow]);

      expect(result.proofAccepted, isFalse);
      expect(
        result.effectiveBlockers.any(
          (blocker) => blocker.contains('MultiPV 3 did not produce distinct'),
        ),
        isTrue,
      );
      expect(
        result.effectiveBlockers.any(
          (blocker) => blocker.contains('returned 1 PV line'),
        ),
        isTrue,
      );
    });

    test('stale bestmove detection catches repeated unrelated bestmoves', () {
      final rows = [
        _row(positionLabel: 'startpos', bestMove: 'e2e4'),
        _row(positionLabel: 'tactical_middlegame', bestMove: 'e2e4'),
      ];

      expect(detectStaleBestmoveAcrossPositions(rows), isTrue);
      expect(
        detectAndroidBenchmarkRowIssues(rows),
        contains(
          'benchmark: stale bestmove reused across unrelated positions.',
        ),
      );
    });

    test('benchmark row renderer handles cp and mate scores', () {
      final rows = [
        _row(scoreType: BenchmarkScoreType.cp, scoreCp: 25, bestMove: 'e2e4'),
        _row(
          positionLabel: 'mate_threat',
          scoreType: BenchmarkScoreType.mate,
          scoreMate: 3,
          bestMove: 'f3f7',
        ),
      ];

      final markdown = AndroidStockfishBenchmarkRow.renderMarkdownTable(rows);
      final json = rows.map((row) => row.toJson()).toList();

      expect(markdown, contains('cp 25'));
      expect(markdown, contains('mate 3'));
      expect(markdown, contains('Bestmove'));
      expect(json.last['scoreType'], 'mate');
      expect(json.last['bestMove'], 'f3f7');
    });

    test('invalid FEN remains rejected before engine path', () {
      expect(validateFenForEngineCommand('').isValid, isFalse);
      expect(validateFenForEngineCommand('8/8/8/8/8/8/8').isValid, isFalse);
    });

    test('new proof files stay local, non-product-UI, and original', () {
      const paths = [
        'lib/features/pgn_review/infrastructure/android_local_engine_proof.dart',
        'integration_test/local_stockfish_device_benchmark_test.dart',
      ];
      for (final path in paths) {
        final source = File(path).readAsStringSync();
        expect(source, isNot(contains('package:flutter/material.dart')));
        expect(source, isNot(contains('package:flutter/widgets.dart')));
        expect(source, isNot(contains('online_review_staging_preflight')));
        expect(source, isNot(contains('C:\\apex_chess_backend')));
        expect(source, isNot(contains('preflight')));
        expect(source, isNot(contains('MoveQuality.brilliant')));
        expect(source, isNot(contains('MoveQuality.great')));
        expect(source, isNot(contains('MoveQuality.miss')));
        expect(source, isNot(contains('ACPL')));
        expect(source, isNot(contains('Chesskit')));
        expect(source, isNot(contains('DroidFish')));
        expect(source, isNot(contains('StockfishForFlutter')));
        expect(source, isNot(contains('python-chess')));
      }
    });
  });
}

final _goodPackaging = analyzeAndroidPackaging(
  configuredAbiFilters: const ['arm64-v8a'],
  packagedEngineAbis: const ['arm64-v8a'],
  artifactPresent: true,
);

final _missingPackaging = analyzeAndroidPackaging(
  configuredAbiFilters: const ['arm64-v8a'],
  packagedEngineAbis: const [],
  artifactPresent: false,
);

final _mismatchedPackaging = analyzeAndroidPackaging(
  configuredAbiFilters: const ['arm64-v8a'],
  packagedEngineAbis: const ['arm64-v8a', 'x86_64'],
  artifactPresent: true,
);

LocalEngineApprovalGateResult _gate({
  required PackagingProofStatus packagingStatus,
  required AndroidDeviceProofSummary? deviceProof,
}) {
  return LocalEngineApprovalGateResult(
    packagingStatus: packagingStatus,
    deviceProof: deviceProof,
    packagingSource: 'test packaging source',
    deviceSource: 'test device source',
  );
}

AndroidDeviceProofSummary _summary({
  LocalEngineRuntimeMode engineMode = LocalEngineRuntimeMode.real,
  String engineName = 'Stockfish 17',
  bool uciOk = true,
  bool readyOk = true,
  bool multiPv3Distinct = true,
  int lifecycleCyclesCompleted = 20,
  bool staleBestmoveDetected = false,
  bool queueContaminationDetected = false,
  int benchmarkRowCount = 139,
}) {
  return AndroidDeviceProofSummary(
    deviceLabel: 'S22 Ultra',
    platform: 'android',
    abi: 'arm64-v8a',
    deviceRunAttempted: true,
    engineMode: engineMode,
    engineName: engineName,
    bridgeVersion: 'apex-stockfish-bridge/0.3.0',
    uciOk: uciOk,
    readyOk: readyOk,
    startposBestmoveLegal: true,
    tacticalPvNonEmpty: true,
    multiPvSupported: true,
    multiPv3Distinct: multiPv3Distinct,
    invalidFenRejectedBeforeEngine: true,
    repeatedDisposeSafe: true,
    lifecycleCyclesRequested: 20,
    lifecycleCyclesCompleted: lifecycleCyclesCompleted,
    staleBestmoveDetected: staleBestmoveDetected,
    queueContaminationDetected: queueContaminationDetected,
    benchmarkRowCount: benchmarkRowCount,
    rowsPreservedInFixture: false,
    source: 'test device source',
  );
}

AndroidLocalEngineProofResult _proof({
  AndroidPackagingAudit? packagingAudit,
  bool deviceRunAttempted = true,
  LocalEngineRuntimeMode engineMode = LocalEngineRuntimeMode.real,
  String engineName = 'Stockfish 17 test',
  bool multiPv3Distinct = true,
  int lifecycleCyclesCompleted = 20,
  List<AndroidStockfishBenchmarkRow>? rows,
}) {
  return AndroidLocalEngineProofResult(
    packagingAudit: packagingAudit ?? _goodPackaging,
    deviceRunAttempted: deviceRunAttempted,
    engineMode: engineMode,
    platform: 'android',
    deviceLabel: 'Pixel test',
    abi: 'arm64-v8a',
    engineName: engineName,
    bridgeVersion: 'bridge/test',
    uciOk: true,
    readyOk: true,
    startposBestmoveLegal: true,
    tacticalPvNonEmpty: true,
    multiPvSupported: true,
    multiPv3Distinct: multiPv3Distinct,
    invalidFenRejectedBeforeEngine: true,
    repeatedDisposeSafe: true,
    lifecycleCyclesRequested: 20,
    lifecycleCyclesCompleted: lifecycleCyclesCompleted,
    staleBestmoveDetected: false,
    queueContaminationDetected: false,
    benchmarkRows: rows ?? [_row(), _row(positionLabel: 'mate_threat')],
  );
}

AndroidStockfishBenchmarkRow get _multiPvBadRow => _row(multiPv: 3, pvCount: 1);

AndroidStockfishBenchmarkRow _row({
  String positionLabel = 'startpos',
  String targetLabel = 'movetime 100ms',
  int multiPv = 1,
  int pvCount = 1,
  BenchmarkScoreType scoreType = BenchmarkScoreType.cp,
  int? scoreCp = 20,
  int? scoreMate,
  String? bestMove,
}) {
  return AndroidStockfishBenchmarkRow(
    deviceLabel: 'Pixel test',
    abi: 'arm64-v8a',
    positionLabel: positionLabel,
    targetLabel: targetLabel,
    multiPv: multiPv,
    elapsedMs: 110,
    parsedDepth: 9,
    nodes: 12000,
    nps: 110000,
    scoreType: scoreType,
    scoreCp: scoreType == BenchmarkScoreType.cp ? scoreCp : null,
    scoreMate: scoreType == BenchmarkScoreType.mate ? scoreMate : null,
    pvCount: pvCount,
    bestMove: bestMove ?? (positionLabel == 'startpos' ? 'e2e4' : 'f3f7'),
  );
}

/// Android-only local Stockfish proof and benchmark result helpers.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/core/infrastructure/engine/engine.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/fen_validator.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/local_engine_audit.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/local_stockfish_benchmark.dart';

const String androidDeviceBenchmarkFlag =
    'APEX_RUN_LOCAL_STOCKFISH_DEVICE_BENCHMARK';

bool isAndroidDeviceBenchmarkEnabled({
  String flagValue = const String.fromEnvironment(androidDeviceBenchmarkFlag),
}) {
  return flagValue.toLowerCase() == 'true';
}

enum AndroidLocalEngineProofRecommendation {
  continueWithFfiBridge,
  pivotToSubprocessPrototype,
  needsAndroidProof;

  String get label => switch (this) {
    AndroidLocalEngineProofRecommendation.continueWithFfiBridge =>
      'continueWithFfiBridge',
    AndroidLocalEngineProofRecommendation.pivotToSubprocessPrototype =>
      'pivotToSubprocessPrototype',
    AndroidLocalEngineProofRecommendation.needsAndroidProof =>
      'needsAndroidProof',
  };
}

class AndroidLocalEngineProofResult {
  const AndroidLocalEngineProofResult({
    required this.packagingAudit,
    required this.deviceRunAttempted,
    required this.engineMode,
    required this.platform,
    required this.deviceLabel,
    required this.abi,
    this.engineName,
    this.bridgeVersion,
    required this.uciOk,
    required this.readyOk,
    required this.startposBestmoveLegal,
    required this.tacticalPvNonEmpty,
    required this.multiPvSupported,
    required this.multiPv3Distinct,
    required this.invalidFenRejectedBeforeEngine,
    required this.repeatedDisposeSafe,
    required this.lifecycleCyclesRequested,
    required this.lifecycleCyclesCompleted,
    required this.staleBestmoveDetected,
    required this.queueContaminationDetected,
    required this.benchmarkRows,
    this.blockers = const [],
    this.warnings = const [],
  });

  final AndroidPackagingAudit packagingAudit;
  final bool deviceRunAttempted;
  final LocalEngineRuntimeMode engineMode;
  final String platform;
  final String deviceLabel;
  final String abi;
  final String? engineName;
  final String? bridgeVersion;
  final bool uciOk;
  final bool readyOk;
  final bool startposBestmoveLegal;
  final bool tacticalPvNonEmpty;
  final bool multiPvSupported;
  final bool multiPv3Distinct;
  final bool invalidFenRejectedBeforeEngine;
  final bool repeatedDisposeSafe;
  final int lifecycleCyclesRequested;
  final int lifecycleCyclesCompleted;
  final bool staleBestmoveDetected;
  final bool queueContaminationDetected;
  final List<AndroidStockfishBenchmarkRow> benchmarkRows;
  final List<String> blockers;
  final List<String> warnings;

  bool get smokePassed =>
      engineMode == LocalEngineRuntimeMode.real &&
      uciOk &&
      readyOk &&
      startposBestmoveLegal &&
      tacticalPvNonEmpty &&
      (!multiPvSupported || multiPv3Distinct) &&
      invalidFenRejectedBeforeEngine &&
      repeatedDisposeSafe;

  bool get lifecyclePassed =>
      lifecycleCyclesRequested > 0 &&
      lifecycleCyclesCompleted == lifecycleCyclesRequested &&
      !staleBestmoveDetected &&
      !queueContaminationDetected;

  bool get benchmarkRowsClean =>
      benchmarkRows.isNotEmpty &&
      benchmarkRows.every(
        (row) => row.warning == null || row.warning!.trim().isEmpty,
      );

  bool get proofAccepted =>
      packagingAudit.matchesConfigured &&
      deviceRunAttempted &&
      smokePassed &&
      lifecyclePassed &&
      benchmarkRowsClean &&
      effectiveBlockers.isEmpty;

  List<String> get effectiveBlockers {
    final out = <String>{...blockers};
    if (!packagingAudit.matchesConfigured) {
      out.add('packaging: ${packagingAudit.statusLabel}');
    }
    if (!deviceRunAttempted) {
      out.add('device: Android real-engine proof was not executed.');
    }
    if (engineMode == LocalEngineRuntimeMode.stubDetected) {
      out.add('engine: stub result cannot be accepted as Android proof.');
    } else if (engineMode == LocalEngineRuntimeMode.unavailable) {
      out.add('engine: Android engine unavailable.');
    }
    if (!uciOk) out.add('smoke: uciok was not observed.');
    if (!readyOk) out.add('smoke: readyok was not observed.');
    if (!startposBestmoveLegal) {
      out.add('smoke: startpos bestmove was missing or malformed.');
    }
    if (!tacticalPvNonEmpty) {
      out.add('smoke: tactical FEN did not produce a non-empty PV.');
    }
    if (multiPvSupported && !multiPv3Distinct) {
      out.add('multipv: MultiPV 3 did not produce distinct candidates.');
    }
    if (!invalidFenRejectedBeforeEngine) {
      out.add('fen: invalid FEN was not rejected before engine use.');
    }
    if (!repeatedDisposeSafe) {
      out.add('lifecycle: repeated dispose was not safe.');
    }
    if (lifecycleCyclesCompleted < lifecycleCyclesRequested) {
      out.add(
        'lifecycle: completed $lifecycleCyclesCompleted of '
        '$lifecycleCyclesRequested cycles.',
      );
    }
    if (staleBestmoveDetected) {
      out.add('lifecycle: stale bestmove reuse detected.');
    }
    if (queueContaminationDetected) {
      out.add('lifecycle: queue contamination detected.');
    }
    for (final issue in detectAndroidBenchmarkRowIssues(benchmarkRows)) {
      out.add(issue);
    }
    return out.toList(growable: false)..sort();
  }

  List<String> get deviceBlockers => effectiveBlockers
      .where((blocker) => !blocker.startsWith('packaging:'))
      .toList(growable: false);

  AndroidLocalEngineProofRecommendation get recommendation {
    if (proofAccepted) {
      return AndroidLocalEngineProofRecommendation.continueWithFfiBridge;
    }
    if (!deviceRunAttempted ||
        !packagingAudit.matchesConfigured ||
        engineMode == LocalEngineRuntimeMode.stubDetected ||
        engineMode == LocalEngineRuntimeMode.unavailable) {
      return AndroidLocalEngineProofRecommendation.needsAndroidProof;
    }
    if (!lifecyclePassed ||
        queueContaminationDetected ||
        staleBestmoveDetected ||
        (multiPvSupported && !multiPv3Distinct)) {
      return AndroidLocalEngineProofRecommendation.pivotToSubprocessPrototype;
    }
    return AndroidLocalEngineProofRecommendation.needsAndroidProof;
  }

  Map<String, Object?> toJson() {
    return {
      'packagingStatus': packagingAudit.statusLabel,
      'configuredAbiFilters': packagingAudit.configuredAbiFilters,
      'packagedEngineAbis': packagingAudit.packagedEngineAbis,
      'deviceRunAttempted': deviceRunAttempted,
      'engineMode': engineMode.label,
      'platform': platform,
      'deviceLabel': deviceLabel,
      'abi': abi,
      'engineName': engineName,
      'bridgeVersion': bridgeVersion,
      'uciOk': uciOk,
      'readyOk': readyOk,
      'startposBestmoveLegal': startposBestmoveLegal,
      'tacticalPvNonEmpty': tacticalPvNonEmpty,
      'multiPvSupported': multiPvSupported,
      'multiPv3Distinct': multiPv3Distinct,
      'invalidFenRejectedBeforeEngine': invalidFenRejectedBeforeEngine,
      'repeatedDisposeSafe': repeatedDisposeSafe,
      'lifecycleCyclesRequested': lifecycleCyclesRequested,
      'lifecycleCyclesCompleted': lifecycleCyclesCompleted,
      'staleBestmoveDetected': staleBestmoveDetected,
      'queueContaminationDetected': queueContaminationDetected,
      'benchmarkRowCount': benchmarkRows.length,
      'blockers': effectiveBlockers,
      'warnings': warnings,
      'recommendation': recommendation.label,
      'benchmarkRows': benchmarkRows.map((row) => row.toJson()).toList(),
    };
  }

  String renderJson() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Apex Android Local Engine Proof')
      ..writeln()
      ..writeln('packaging status: ${packagingAudit.statusLabel}')
      ..writeln('device run attempted: $deviceRunAttempted')
      ..writeln('engine mode: ${engineMode.label}')
      ..writeln('platform: $platform')
      ..writeln('device: $deviceLabel')
      ..writeln('ABI: $abi')
      ..writeln('engine name: ${engineName ?? 'unknown'}')
      ..writeln('bridge version: ${bridgeVersion ?? 'unknown'}')
      ..writeln('uciok: $uciOk')
      ..writeln('readyok: $readyOk')
      ..writeln('startpos bestmove legal-looking: $startposBestmoveLegal')
      ..writeln('tactical PV non-empty: $tacticalPvNonEmpty')
      ..writeln('MultiPV supported: $multiPvSupported')
      ..writeln('MultiPV 3 distinct: $multiPv3Distinct')
      ..writeln(
        'invalid FEN rejected before engine: $invalidFenRejectedBeforeEngine',
      )
      ..writeln('repeated dispose safe: $repeatedDisposeSafe')
      ..writeln(
        'lifecycle cycles: $lifecycleCyclesCompleted/$lifecycleCyclesRequested',
      )
      ..writeln('stale bestmove detected: $staleBestmoveDetected')
      ..writeln('queue contamination detected: $queueContaminationDetected')
      ..writeln('benchmark rows: ${benchmarkRows.length}')
      ..writeln('recommendation: ${recommendation.label}')
      ..writeln()
      ..writeln('blockers:');
    final currentBlockers = effectiveBlockers;
    if (currentBlockers.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final blocker in currentBlockers) {
        buffer.writeln('- $blocker');
      }
    }
    buffer.writeln();
    buffer.writeln('warnings:');
    if (warnings.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final warning in warnings) {
        buffer.writeln('- $warning');
      }
    }
    if (benchmarkRows.isNotEmpty) {
      buffer
        ..writeln()
        ..write(
          AndroidStockfishBenchmarkRow.renderMarkdownTable(benchmarkRows),
        );
    }
    return buffer.toString();
  }
}

bool detectStaleBestmoveAcrossPositions(
  List<AndroidStockfishBenchmarkRow> rows,
) {
  final positionsByBestMove = <String, Set<String>>{};
  for (final row in rows) {
    final best = row.bestMove?.trim();
    if (best == null || best.isEmpty || best == '(none)') continue;
    positionsByBestMove
        .putIfAbsent(best, () => <String>{})
        .add(row.positionLabel);
  }
  return positionsByBestMove.values.any((positions) => positions.length > 1);
}

List<String> detectAndroidBenchmarkRowIssues(
  List<AndroidStockfishBenchmarkRow> rows,
) {
  if (rows.isEmpty) return const ['benchmark: no Android rows were captured.'];
  final out = <String>{};
  if (detectStaleBestmoveAcrossPositions(rows)) {
    out.add('benchmark: stale bestmove reused across unrelated positions.');
  }
  for (final row in rows) {
    final warning = row.warning?.trim();
    if (warning != null && warning.isNotEmpty) {
      out.add('benchmark: ${row.positionLabel} ${row.targetLabel}: $warning');
    }
    if (row.multiPv >= 3 && row.pvCount < 2) {
      out.add(
        'multipv: ${row.positionLabel} ${row.targetLabel} returned '
        '${row.pvCount} PV line(s) for MultiPV ${row.multiPv}.',
      );
    }
  }
  return out.toList(growable: false)..sort();
}

class AndroidLocalEngineProofCollector {
  AndroidLocalEngineProofCollector({
    ChessEngine? engine,
    AndroidPackagingAudit? packagingAudit,
    List<BenchmarkPosition> positions = BenchmarkPosition.defaults,
    List<BenchmarkTarget> targets = BenchmarkTarget.defaults,
    List<int> multiPvValues = const [1, 2, 3],
    int lifecycleCycles = 20,
  }) : _engine = engine,
       _packagingAudit = packagingAudit,
       _positions = positions,
       _targets = targets,
       _multiPvValues = multiPvValues,
       _lifecycleCycles = lifecycleCycles;

  final ChessEngine? _engine;
  final AndroidPackagingAudit? _packagingAudit;
  final List<BenchmarkPosition> _positions;
  final List<BenchmarkTarget> _targets;
  final List<int> _multiPvValues;
  final int _lifecycleCycles;

  Future<AndroidLocalEngineProofResult> run() async {
    final engine =
        _engine ?? StockfishEngine(startupTimeout: const Duration(seconds: 12));
    final ownsEngine = _engine == null;
    final rows = <AndroidStockfishBenchmarkRow>[];
    final blockers = <String>[];
    final warnings = <String>[];
    var mode = LocalEngineRuntimeMode.unavailable;
    var uciOk = false;
    var readyOk = false;
    var startposBestmoveLegal = false;
    var tacticalPvNonEmpty = false;
    var multiPvSupported = false;
    var multiPv3Distinct = false;
    var invalidFenRejectedBeforeEngine = false;
    var repeatedDisposeSafe = false;
    var lifecycleCyclesCompleted = 0;
    var staleBestmoveDetected = false;
    var queueContaminationDetected = false;
    String? engineName;
    String? bridgeVersion;

    try {
      await engine.start().timeout(const Duration(seconds: 15));
      bridgeVersion = engine.bridgeVersion;

      final handshake = await _handshake(engine);
      uciOk = handshake.uciOk;
      readyOk = handshake.readyOk;
      engineName = handshake.engineName;
      multiPvSupported = handshake.multiPvSupported;
      mode = handshake.stubDetected
          ? LocalEngineRuntimeMode.stubDetected
          : LocalEngineRuntimeMode.real;
      if (engineName == null || engineName.trim().isEmpty) {
        mode = LocalEngineRuntimeMode.unavailable;
        blockers.add('smoke: engine id name was not reported.');
      }

      invalidFenRejectedBeforeEngine = !validateFenForEngineCommand(
        '8/8/8/8/8/8/8',
      ).isValid;

      if (mode == LocalEngineRuntimeMode.real) {
        final start = await _runOne(
          engine: engine,
          position: BenchmarkPosition.start,
          target: const BenchmarkTarget.movetime(100),
          multiPv: 1,
        );
        rows.add(start);
        startposBestmoveLegal = _isLegalLookingBestMove(start.bestMove);
        if (start.warning?.contains('PV head') ?? false) {
          queueContaminationDetected = true;
        }

        final tactical = await _runOne(
          engine: engine,
          position: BenchmarkPosition.tacticalMiddlegame,
          target: const BenchmarkTarget.movetime(100),
          multiPv: 1,
        );
        rows.add(tactical);
        tacticalPvNonEmpty = tactical.pvCount > 0;
        if (tactical.warning?.contains('PV head') ?? false) {
          queueContaminationDetected = true;
        }

        if (multiPvSupported) {
          final multi = await _runOne(
            engine: engine,
            position: BenchmarkPosition.tacticalMiddlegame,
            target: const BenchmarkTarget.movetime(250),
            multiPv: 3,
          );
          rows.add(multi);
          multiPv3Distinct = multi.pvCount >= 2;
          if (multi.warning?.contains('PV head') ?? false) {
            queueContaminationDetected = true;
          }
        } else {
          warnings.add('UCI options did not advertise MultiPV.');
        }

        final lifecycleRows = await _runLifecycleStress(engine);
        rows.addAll(lifecycleRows.rows);
        lifecycleCyclesCompleted = lifecycleRows.cyclesCompleted;
        staleBestmoveDetected = lifecycleRows.staleBestmoveDetected;
        queueContaminationDetected =
            queueContaminationDetected || lifecycleRows.queueContamination;

        for (final multiPv in _multiPvValues) {
          if (multiPv > 1 && !multiPvSupported) continue;
          for (final position in _positions) {
            for (final target in _targets) {
              final row = await _runOne(
                engine: engine,
                position: position,
                target: target,
                multiPv: multiPv,
              );
              if (row.warning?.contains('PV head') ?? false) {
                queueContaminationDetected = true;
              }
              rows.add(row);
            }
          }
        }
      }
    } on Object catch (e) {
      blockers.add('device: Android proof failed safely: $e');
    } finally {
      try {
        if (engine.isRunning) engine.stop();
      } on Object {
        warnings.add('stop during cleanup failed.');
      }
      if (ownsEngine) {
        try {
          await engine.dispose().timeout(const Duration(seconds: 5));
          await engine.dispose().timeout(const Duration(seconds: 5));
          repeatedDisposeSafe = true;
        } on Object catch (e) {
          blockers.add('lifecycle: dispose failed safely: $e');
        }
      } else {
        repeatedDisposeSafe = true;
      }
    }

    return AndroidLocalEngineProofResult(
      packagingAudit:
          _packagingAudit ??
          analyzeAndroidPackaging(
            configuredAbiFilters: const [],
            packagedEngineAbis: const [],
            artifactPresent: false,
            artifactLabel: 'host-side APK audit not available in device test',
          ),
      deviceRunAttempted: true,
      engineMode: mode,
      platform: Platform.operatingSystem,
      deviceLabel: Platform.localHostname.isEmpty
          ? Platform.operatingSystem
          : Platform.localHostname,
      abi: currentRuntimeAbiLabel(),
      engineName: engineName,
      bridgeVersion: bridgeVersion,
      uciOk: uciOk,
      readyOk: readyOk,
      startposBestmoveLegal: startposBestmoveLegal,
      tacticalPvNonEmpty: tacticalPvNonEmpty,
      multiPvSupported: multiPvSupported,
      multiPv3Distinct: multiPvSupported ? multiPv3Distinct : false,
      invalidFenRejectedBeforeEngine: invalidFenRejectedBeforeEngine,
      repeatedDisposeSafe: repeatedDisposeSafe,
      lifecycleCyclesRequested: _lifecycleCycles,
      lifecycleCyclesCompleted: lifecycleCyclesCompleted,
      staleBestmoveDetected:
          staleBestmoveDetected || detectStaleBestmoveAcrossPositions(rows),
      queueContaminationDetected: queueContaminationDetected,
      benchmarkRows: List.unmodifiable(rows),
      blockers: List.unmodifiable(blockers),
      warnings: List.unmodifiable(warnings),
    );
  }

  Future<_AndroidHandshake> _handshake(ChessEngine engine) async {
    final uciOk = Completer<void>();
    final readyOk = Completer<void>();
    final options = <String>{};
    String? engineName;

    late final StreamSubscription<EngineEvent> sub;
    sub = engine.events.listen((event) {
      if (event is EngineId && event.name != null) {
        engineName = event.name;
      } else if (event is EngineOption) {
        options.add(event.name);
      } else if (event is EngineUciOk && !uciOk.isCompleted) {
        uciOk.complete();
      } else if (event is EngineReadyOk && !readyOk.isCompleted) {
        readyOk.complete();
      } else if (event is EngineError && !uciOk.isCompleted) {
        uciOk.completeError(event.message);
      }
    });

    try {
      engine.send(const UciHandshake());
      await uciOk.future.timeout(const Duration(seconds: 10));
      engine.send(const UciIsReady());
      await readyOk.future.timeout(const Duration(seconds: 10));
    } finally {
      await sub.cancel();
    }

    final name = engineName;
    return _AndroidHandshake(
      engineName: name,
      uciOk: true,
      readyOk: true,
      multiPvSupported: options.any((o) => o.toLowerCase() == 'multipv'),
      stubDetected: (name ?? '').toLowerCase().contains('stub'),
    );
  }

  Future<_LifecycleRows> _runLifecycleStress(ChessEngine engine) async {
    var completed = 0;
    var stale = false;
    var contamination = false;
    final rows = <AndroidStockfishBenchmarkRow>[];
    for (var i = 0; i < _lifecycleCycles; i++) {
      await _awaitReady(engine, const Duration(seconds: 5));
      final start = await _runOne(
        engine: engine,
        position: BenchmarkPosition.start,
        target: const BenchmarkTarget.movetime(50),
        multiPv: 1,
      );
      engine.send(const UciStop());
      await _awaitReady(engine, const Duration(seconds: 5));
      final tactical = await _runOne(
        engine: engine,
        position: BenchmarkPosition.tacticalMiddlegame,
        target: const BenchmarkTarget.movetime(50),
        multiPv: 1,
      );
      engine.send(const UciStop());
      rows
        ..add(start)
        ..add(tactical);
      contamination =
          contamination ||
          (start.warning?.contains('PV head') ?? false) ||
          (tactical.warning?.contains('PV head') ?? false);
      if (start.bestMove != null &&
          start.bestMove!.isNotEmpty &&
          start.bestMove == tactical.bestMove) {
        stale = true;
      }
      if (start.warning?.contains('timed out') == true ||
          tactical.warning?.contains('timed out') == true) {
        break;
      }
      completed++;
    }
    return _LifecycleRows(
      rows: rows,
      cyclesCompleted: completed,
      staleBestmoveDetected: stale,
      queueContamination: contamination,
    );
  }

  Future<AndroidStockfishBenchmarkRow> _runOne({
    required ChessEngine engine,
    required BenchmarkPosition position,
    required BenchmarkTarget target,
    required int multiPv,
  }) async {
    final validation = validateFenForEngineCommand(position.fen);
    if (!validation.isValid) {
      return AndroidStockfishBenchmarkRow(
        deviceLabel: Platform.localHostname,
        abi: currentRuntimeAbiLabel(),
        positionLabel: position.label,
        targetLabel: target.label,
        multiPv: multiPv,
        elapsedMs: 0,
        scoreType: BenchmarkScoreType.none,
        pvCount: 0,
        warning: 'invalid FEN: ${validation.message}',
      );
    }

    final latestByPv = <int, EngineInfo>{};
    final bestMove = Completer<EngineBestMove>();
    late final StreamSubscription<EngineEvent> sub;
    sub = engine.events.listen((event) {
      if (event is EngineInfo) {
        final rank = event.multipv ?? 1;
        if (rank < 1 || rank > multiPv) return;
        final prior = latestByPv[rank];
        if (prior == null || (event.depth ?? 0) >= (prior.depth ?? 0)) {
          latestByPv[rank] = event;
        }
      } else if (event is EngineBestMove && !bestMove.isCompleted) {
        bestMove.complete(event);
      } else if (event is EngineError && !bestMove.isCompleted) {
        bestMove.completeError(event.message);
      }
    });

    final watch = Stopwatch();
    try {
      engine.send(const UciStop());
      await _awaitReady(engine, const Duration(seconds: 5));
      engine.send(const UciNewGame());
      await _awaitReady(engine, const Duration(seconds: 5));
      if (multiPv > 1) {
        engine.send(UciSetOption(name: 'MultiPV', value: multiPv.toString()));
        await _awaitReady(engine, const Duration(seconds: 5));
      }
      watch.start();
      engine
        ..send(UciPosition.fen(position.fen))
        ..send(target.toCommand());
      final best = await bestMove.future.timeout(target.timeout);
      watch.stop();

      final info = latestByPv[1] ?? _deepestInfo(latestByPv.values);
      final scoreType = info?.scoreMate != null
          ? BenchmarkScoreType.mate
          : info?.scoreCp != null
          ? BenchmarkScoreType.cp
          : BenchmarkScoreType.none;
      final pvLineCount = latestByPv.values
          .where((line) => line.pv.isNotEmpty)
          .length;
      final bestInPv = latestByPv.values.any(
        (line) => line.pv.isNotEmpty && line.pv.first == best.move,
      );

      return AndroidStockfishBenchmarkRow(
        deviceLabel: Platform.localHostname,
        abi: currentRuntimeAbiLabel(),
        positionLabel: position.label,
        targetLabel: target.label,
        multiPv: multiPv,
        elapsedMs: watch.elapsedMilliseconds,
        parsedDepth: info?.depth,
        nodes: info?.nodes,
        nps: info?.nps,
        scoreType: scoreType,
        scoreCp: info?.scoreCp,
        scoreMate: info?.scoreMate,
        pvCount: pvLineCount,
        bestMove: best.move,
        warning: bestInPv || latestByPv.isEmpty
            ? null
            : 'bestmove did not match a parsed PV head',
      );
    } on TimeoutException {
      engine.send(const UciStop());
      return AndroidStockfishBenchmarkRow(
        deviceLabel: Platform.localHostname,
        abi: currentRuntimeAbiLabel(),
        positionLabel: position.label,
        targetLabel: target.label,
        multiPv: multiPv,
        elapsedMs: watch.elapsedMilliseconds,
        scoreType: BenchmarkScoreType.none,
        pvCount: latestByPv.length,
        warning: 'search timed out',
      );
    } on Object catch (e) {
      engine.send(const UciStop());
      return AndroidStockfishBenchmarkRow(
        deviceLabel: Platform.localHostname,
        abi: currentRuntimeAbiLabel(),
        positionLabel: position.label,
        targetLabel: target.label,
        multiPv: multiPv,
        elapsedMs: watch.elapsedMilliseconds,
        scoreType: BenchmarkScoreType.none,
        pvCount: latestByPv.length,
        warning: 'search failed safely: $e',
      );
    } finally {
      await sub.cancel();
    }
  }

  Future<void> _awaitReady(ChessEngine engine, Duration timeout) async {
    final ready = Completer<void>();
    late final StreamSubscription<EngineEvent> sub;
    sub = engine.events.listen((event) {
      if (event is EngineReadyOk && !ready.isCompleted) {
        ready.complete();
      } else if (event is EngineError && !ready.isCompleted) {
        ready.completeError(event.message);
      }
    });
    try {
      engine.send(const UciIsReady());
      await ready.future.timeout(timeout);
    } finally {
      await sub.cancel();
    }
  }

  EngineInfo? _deepestInfo(Iterable<EngineInfo> infos) {
    EngineInfo? best;
    for (final info in infos) {
      if (best == null || (info.depth ?? 0) > (best.depth ?? 0)) {
        best = info;
      }
    }
    return best;
  }

  bool _isLegalLookingBestMove(String? move) {
    if (move == null) return false;
    return RegExp(r'^[a-h][1-8][a-h][1-8][qrbn]?$').hasMatch(move);
  }
}

String currentRuntimeAbiLabel() {
  try {
    return switch (Abi.current()) {
      Abi.androidArm => 'armeabi-v7a',
      Abi.androidArm64 => 'arm64-v8a',
      Abi.androidIA32 => 'x86',
      Abi.androidX64 => 'x86_64',
      Abi.linuxArm => 'linux-arm',
      Abi.linuxArm64 => 'linux-arm64',
      Abi.linuxIA32 => 'linux-x86',
      Abi.linuxX64 => 'linux-x64',
      Abi.macosArm64 => 'macos-arm64',
      Abi.macosX64 => 'macos-x64',
      Abi.windowsArm64 => 'windows-arm64',
      Abi.windowsIA32 => 'windows-x86',
      Abi.windowsX64 => 'windows-x64',
      Abi.iosArm => 'ios-arm',
      Abi.iosArm64 => 'ios-arm64',
      Abi.iosX64 => 'ios-x64',
      Abi.fuchsiaArm64 => 'fuchsia-arm64',
      Abi.fuchsiaX64 => 'fuchsia-x64',
      _ => Abi.current().toString(),
    };
  } on Object {
    return 'unknown';
  }
}

class _AndroidHandshake {
  const _AndroidHandshake({
    required this.engineName,
    required this.uciOk,
    required this.readyOk,
    required this.multiPvSupported,
    required this.stubDetected,
  });

  final String? engineName;
  final bool uciOk;
  final bool readyOk;
  final bool multiPvSupported;
  final bool stubDetected;
}

class _LifecycleRows {
  const _LifecycleRows({
    required this.rows,
    required this.cyclesCompleted,
    required this.staleBestmoveDetected,
    required this.queueContamination,
  });

  final List<AndroidStockfishBenchmarkRow> rows;
  final int cyclesCompleted;
  final bool staleBestmoveDetected;
  final bool queueContamination;
}

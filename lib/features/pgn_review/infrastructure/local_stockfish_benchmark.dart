/// Opt-in local Stockfish benchmark harness.
library;

import 'dart:async';

import 'package:apex_chess/core/infrastructure/engine/engine.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/fen_validator.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/local_engine_audit.dart';

class BenchmarkPosition {
  const BenchmarkPosition({required this.label, required this.fen});

  final String label;
  final String fen;

  static const start = BenchmarkPosition(
    label: 'startpos',
    fen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
  );

  static const tacticalMiddlegame = BenchmarkPosition(
    label: 'tactical_middlegame',
    fen:
        'r3k2r/p1ppqpb1/bn2pnp1/2pP4/1p2P3/2N2N2/PPPB1PPP/R2QKB1R w KQkq - 0 1',
  );

  static const endgame = BenchmarkPosition(
    label: 'endgame',
    fen: '8/8/8/8/8/2k5/5K2/6Q1 w - - 0 1',
  );

  static const mateThreat = BenchmarkPosition(
    label: 'mate_threat',
    fen: 'r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/5Q2/PPPP1PPP/RNB1K1NR w KQkq - 4 4',
  );

  static const defaults = <BenchmarkPosition>[
    start,
    tacticalMiddlegame,
    endgame,
    mateThreat,
  ];
}

enum BenchmarkTargetKind { movetime, depth }

class BenchmarkTarget {
  const BenchmarkTarget.movetime(int milliseconds)
    : kind = BenchmarkTargetKind.movetime,
      value = milliseconds;

  const BenchmarkTarget.depth(int depth)
    : kind = BenchmarkTargetKind.depth,
      value = depth;

  final BenchmarkTargetKind kind;
  final int value;

  String get label => switch (kind) {
    BenchmarkTargetKind.movetime => 'movetime ${value}ms',
    BenchmarkTargetKind.depth => 'depth $value',
  };

  UciGo toCommand() => switch (kind) {
    BenchmarkTargetKind.movetime => UciGo.movetime(
      Duration(milliseconds: value),
    ),
    BenchmarkTargetKind.depth => UciGo.depth(value),
  };

  Duration get timeout => switch (kind) {
    BenchmarkTargetKind.movetime => Duration(milliseconds: value + 10000),
    BenchmarkTargetKind.depth => const Duration(seconds: 75),
  };

  static const defaults = <BenchmarkTarget>[
    BenchmarkTarget.movetime(50),
    BenchmarkTarget.movetime(100),
    BenchmarkTarget.movetime(250),
    BenchmarkTarget.movetime(500),
    BenchmarkTarget.depth(10),
    BenchmarkTarget.depth(12),
    BenchmarkTarget.depth(14),
    BenchmarkTarget.depth(16),
  ];
}

enum BenchmarkScoreType {
  cp,
  mate,
  none;

  String get label => name;
}

class BenchmarkResult {
  const BenchmarkResult({
    required this.positionLabel,
    required this.targetLabel,
    required this.elapsedMs,
    this.parsedDepth,
    required this.scoreType,
    this.scoreCp,
    this.scoreMate,
    this.nodes,
    this.nps,
    required this.multipvLineCount,
    this.bestMove,
    this.pv = const [],
    this.warning,
  });

  final String positionLabel;
  final String targetLabel;
  final int elapsedMs;
  final int? parsedDepth;
  final BenchmarkScoreType scoreType;
  final int? scoreCp;
  final int? scoreMate;
  final int? nodes;
  final int? nps;
  final int multipvLineCount;
  final String? bestMove;
  final List<String> pv;
  final String? warning;

  String get scoreLabel => switch (scoreType) {
    BenchmarkScoreType.cp => 'cp ${scoreCp ?? '?'}',
    BenchmarkScoreType.mate => 'mate ${scoreMate ?? '?'}',
    BenchmarkScoreType.none => 'none',
  };
}

class AndroidStockfishBenchmarkRow {
  const AndroidStockfishBenchmarkRow({
    required this.deviceLabel,
    required this.abi,
    required this.positionLabel,
    required this.targetLabel,
    required this.multiPv,
    required this.elapsedMs,
    this.parsedDepth,
    this.nodes,
    this.nps,
    required this.scoreType,
    this.scoreCp,
    this.scoreMate,
    required this.pvCount,
    this.bestMove,
    this.warning,
  });

  final String deviceLabel;
  final String abi;
  final String positionLabel;
  final String targetLabel;
  final int multiPv;
  final int elapsedMs;
  final int? parsedDepth;
  final int? nodes;
  final int? nps;
  final BenchmarkScoreType scoreType;
  final int? scoreCp;
  final int? scoreMate;
  final int pvCount;
  final String? bestMove;
  final String? warning;

  String get scoreLabel => switch (scoreType) {
    BenchmarkScoreType.cp => 'cp ${scoreCp ?? '?'}',
    BenchmarkScoreType.mate => 'mate ${scoreMate ?? '?'}',
    BenchmarkScoreType.none => 'none',
  };

  String toMarkdownRow() {
    return '| ${_benchmarkMarkdownCell(deviceLabel)} | '
        '${_benchmarkMarkdownCell(abi)} | '
        '${_benchmarkMarkdownCell(positionLabel)} | '
        '${_benchmarkMarkdownCell(targetLabel)} | '
        '$multiPv | $elapsedMs | ${parsedDepth ?? '?'} | ${nodes ?? '?'} | '
        '${nps ?? '?'} | ${_benchmarkMarkdownCell(scoreLabel)} | '
        '$pvCount | ${_benchmarkMarkdownCell(bestMove ?? '')} | '
        '${_benchmarkMarkdownCell(warning ?? '')} |';
  }

  Map<String, Object?> toJson() {
    return {
      'deviceLabel': deviceLabel,
      'abi': abi,
      'positionLabel': positionLabel,
      'targetLabel': targetLabel,
      'multiPv': multiPv,
      'elapsedMs': elapsedMs,
      'parsedDepth': parsedDepth,
      'nodes': nodes,
      'nps': nps,
      'scoreType': scoreType.label,
      'scoreCp': scoreCp,
      'scoreMate': scoreMate,
      'pvCount': pvCount,
      'bestMove': bestMove,
      'warning': warning,
    };
  }

  static String renderMarkdownTable(List<AndroidStockfishBenchmarkRow> rows) {
    final buffer = StringBuffer()
      ..writeln(
        '| Device | ABI | Position | Target | MultiPV | Elapsed ms | Depth | Nodes | NPS | Score | PV count | Bestmove | Warning |',
      )
      ..writeln('|---|---|---|---|---:|---:|---:|---:|---:|---|---:|---|---|');
    for (final row in rows) {
      buffer.writeln(row.toMarkdownRow());
    }
    return buffer.toString();
  }
}

String _benchmarkMarkdownCell(Object value) {
  return value
      .toString()
      .replaceAll('|', '/')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

class LocalStockfishBenchmarkReport {
  const LocalStockfishBenchmarkReport({
    required this.engineMode,
    required this.platform,
    required this.targetPositionsCount,
    required this.results,
    required this.multiPvSupported,
    required this.warnings,
    required this.nextRecommendation,
    this.androidBenchmarkStatus = 'unproven by host command',
    this.engineName,
    this.bridgeVersion,
    this.audit,
  });

  final LocalEngineRuntimeMode engineMode;
  final String platform;
  final int targetPositionsCount;
  final List<BenchmarkResult> results;
  final bool multiPvSupported;
  final List<String> warnings;
  final String nextRecommendation;
  final String androidBenchmarkStatus;
  final String? engineName;
  final String? bridgeVersion;
  final LocalEngineAuditReport? audit;

  double get averageElapsedMs {
    if (results.isEmpty) return 0;
    final total = results.fold<int>(0, (sum, r) => sum + r.elapsedMs);
    return total / results.length;
  }

  int get maxElapsedMs {
    if (results.isEmpty) return 0;
    return results.map((r) => r.elapsedMs).reduce((a, b) => a > b ? a : b);
  }

  String render() {
    final buffer = StringBuffer()
      ..writeln('# Apex Local Stockfish Benchmark')
      ..writeln()
      ..writeln('engine mode: ${engineMode.label}')
      ..writeln('platform/ABI: $platform')
      ..writeln('engine name: ${engineName ?? 'unknown'}')
      ..writeln('bridge version: ${bridgeVersion ?? 'unknown'}')
      ..writeln('target positions count: $targetPositionsCount')
      ..writeln('MultiPV support: ${multiPvSupported ? 'yes' : 'no'}')
      ..writeln('Android benchmark status: $androidBenchmarkStatus')
      ..writeln('average elapsed ms: ${averageElapsedMs.toStringAsFixed(1)}')
      ..writeln('max elapsed ms: $maxElapsedMs')
      ..writeln()
      ..writeln('results:');
    if (results.isEmpty) {
      buffer.writeln('- no benchmark rows');
    } else {
      for (final result in results) {
        buffer.writeln(
          '- ${result.positionLabel} | ${result.targetLabel} | '
          'elapsed=${result.elapsedMs}ms | '
          'depth=${result.parsedDepth ?? '?'} | '
          'score=${result.scoreLabel} | '
          'nodes=${result.nodes ?? '?'} | '
          'nps=${result.nps ?? '?'} | '
          'multipv=${result.multipvLineCount} | '
          'bestmove=${result.bestMove ?? '?'}'
          '${result.warning == null ? '' : ' | warning=${result.warning}'}',
        );
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
    buffer
      ..writeln()
      ..writeln('next recommendation: $nextRecommendation');
    return buffer.toString();
  }
}

class LocalStockfishBenchmarkRunner {
  LocalStockfishBenchmarkRunner({
    ChessEngine? engine,
    LocalEngineAuditor auditor = const LocalEngineAuditor(),
    List<BenchmarkPosition> positions = BenchmarkPosition.defaults,
    List<BenchmarkTarget> targets = BenchmarkTarget.defaults,
    int multiPv = 3,
  }) : _engine = engine,
       _auditor = auditor,
       _positions = positions,
       _targets = targets,
       _multiPv = multiPv.clamp(1, 5).toInt();

  final ChessEngine? _engine;
  final LocalEngineAuditor _auditor;
  final List<BenchmarkPosition> _positions;
  final List<BenchmarkTarget> _targets;
  final int _multiPv;

  Future<LocalStockfishBenchmarkReport> run() async {
    final audit = await _auditor.run();
    final warnings = <String>[...audit.warnings];
    if (!audit.currentBridgeLoadable && _engine == null) {
      warnings.add('No host-loadable bridge; benchmark rows were not run.');
      return LocalStockfishBenchmarkReport(
        engineMode: LocalEngineRuntimeMode.unavailable,
        platform: audit.currentPlatform,
        targetPositionsCount: _positions.length,
        results: const [],
        multiPvSupported: false,
        warnings: List.unmodifiable(warnings),
        nextRecommendation:
            'Build/load a host bridge or run this harness on Android before using benchmark facts.',
        audit: audit,
      );
    }

    final engine = _engine ?? StockfishEngine();
    final ownsEngine = _engine == null;
    final results = <BenchmarkResult>[];
    var mode = audit.runtimeMode;
    String? engineName;
    var multiPvSupported = false;

    try {
      if (!engine.isRunning) await engine.start();
      final handshake = await _handshake(engine);
      engineName = handshake.engineName;
      multiPvSupported = handshake.multiPvSupported;
      if (handshake.stubDetected) {
        mode = LocalEngineRuntimeMode.stubDetected;
        warnings.add('UCI id reports a stub engine; full benchmark not run.');
      } else {
        mode = LocalEngineRuntimeMode.real;
        for (final position in _positions) {
          for (final target in _targets) {
            results.add(
              await _runOne(
                engine: engine,
                position: position,
                target: target,
                multiPv: multiPvSupported ? _multiPv : 1,
              ),
            );
          }
        }
      }
    } on Object catch (e) {
      warnings.add('Benchmark failed safely: $e');
      if (results.isEmpty) mode = LocalEngineRuntimeMode.unavailable;
    } finally {
      if (ownsEngine) {
        await engine.dispose();
      }
    }

    final observations = results
        .map(
          (r) => EngineSearchObservation(
            positionLabel: r.positionLabel,
            bestMove: r.bestMove,
            scoreCp: r.scoreCp,
            scoreMate: r.scoreMate,
            depth: r.parsedDepth,
            nodes: r.nodes,
            elapsed: Duration(milliseconds: r.elapsedMs),
          ),
        )
        .toList(growable: false);
    final stubFindings = detectSuspiciousStubBehavior(observations);
    if (stubFindings.isNotEmpty) {
      mode = LocalEngineRuntimeMode.stubDetected;
      warnings.addAll(stubFindings.map((f) => 'Stub suspicion: ${f.message}.'));
    }

    return LocalStockfishBenchmarkReport(
      engineMode: mode,
      platform: audit.currentPlatform,
      targetPositionsCount: _positions.length,
      results: List.unmodifiable(results),
      multiPvSupported: multiPvSupported,
      warnings: List.unmodifiable(warnings),
      nextRecommendation: _benchmarkRecommendation(mode, results),
      engineName: engineName,
      bridgeVersion: engine.bridgeVersion,
      audit: audit,
    );
  }

  Future<_UciHandshake> _handshake(ChessEngine engine) async {
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
      await uciOk.future.timeout(const Duration(seconds: 8));
      engine.send(const UciIsReady());
      await readyOk.future.timeout(const Duration(seconds: 8));
    } finally {
      await sub.cancel();
    }

    final name = engineName ?? 'unknown';
    return _UciHandshake(
      engineName: name,
      multiPvSupported: options.any((o) => o.toLowerCase() == 'multipv'),
      stubDetected: name.toLowerCase().contains('stub'),
    );
  }

  Future<BenchmarkResult> _runOne({
    required ChessEngine engine,
    required BenchmarkPosition position,
    required BenchmarkTarget target,
    required int multiPv,
  }) async {
    final fenValidation = validateFenForEngineCommand(position.fen);
    if (!fenValidation.isValid) {
      return BenchmarkResult(
        positionLabel: position.label,
        targetLabel: target.label,
        elapsedMs: 0,
        scoreType: BenchmarkScoreType.none,
        multipvLineCount: 0,
        warning: 'invalid FEN: ${fenValidation.message}',
      );
    }

    final latestByPv = <int, EngineInfo>{};
    final bestMove = Completer<EngineBestMove>();
    late final StreamSubscription<EngineEvent> sub;
    sub = engine.events.listen((event) {
      if (event is EngineInfo) {
        final rank = event.multipv ?? 1;
        if (rank < 1 || rank > multiPv) return;
        if (event.scoreCp == null && event.scoreMate == null) return;
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
      if (multiPv > 1) {
        engine.send(UciSetOption(name: 'MultiPV', value: multiPv.toString()));
        await _awaitReady(engine, const Duration(seconds: 5));
      }
      engine.send(const UciNewGame());
      await _awaitReady(engine, const Duration(seconds: 5));

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
      final bestInPv = latestByPv.values.any(
        (line) => line.pv.isNotEmpty && line.pv.first == best.move,
      );
      return BenchmarkResult(
        positionLabel: position.label,
        targetLabel: target.label,
        elapsedMs: watch.elapsedMilliseconds,
        parsedDepth: info?.depth,
        scoreType: scoreType,
        scoreCp: info?.scoreCp,
        scoreMate: info?.scoreMate,
        nodes: info?.nodes,
        nps: info?.nps,
        multipvLineCount: latestByPv.length,
        bestMove: best.move,
        pv: info?.pv ?? const [],
        warning: bestInPv || latestByPv.isEmpty
            ? null
            : 'bestmove did not match a parsed PV head',
      );
    } on TimeoutException {
      engine.send(const UciStop());
      return BenchmarkResult(
        positionLabel: position.label,
        targetLabel: target.label,
        elapsedMs: watch.elapsedMilliseconds,
        scoreType: BenchmarkScoreType.none,
        multipvLineCount: latestByPv.length,
        warning: 'search timed out',
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
}

class _UciHandshake {
  const _UciHandshake({
    required this.engineName,
    required this.multiPvSupported,
    required this.stubDetected,
  });

  final String engineName;
  final bool multiPvSupported;
  final bool stubDetected;
}

String _benchmarkRecommendation(
  LocalEngineRuntimeMode mode,
  List<BenchmarkResult> results,
) {
  return switch (mode) {
    LocalEngineRuntimeMode.real when results.isNotEmpty =>
      'Review device timings; keep the isolate bridge only if lifecycle smoke stays stable on target Android.',
    LocalEngineRuntimeMode.stubDetected =>
      'Do not build Phase 30C on these numbers; remove or hard-disable the stub path for analysis builds.',
    LocalEngineRuntimeMode.real =>
      'Real engine started, but no benchmark rows were produced; inspect warnings before Phase 30C.',
    LocalEngineRuntimeMode.unavailable =>
      'No real local benchmark facts yet; build/load the bridge before Phase 30C scheduler work.',
  };
}

/// Local Stockfish artifact and stub audit helpers.
library;

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/core/infrastructure/engine/stockfish/stockfish_library.dart';

enum LocalEngineRuntimeMode {
  real,
  unavailable,
  stubDetected;

  String get label => switch (this) {
    LocalEngineRuntimeMode.real => 'real',
    LocalEngineRuntimeMode.unavailable => 'unavailable',
    LocalEngineRuntimeMode.stubDetected => 'stub-detected',
  };
}

class LocalEngineAuditReport {
  const LocalEngineAuditReport({
    required this.repoRoot,
    required this.runtimeMode,
    required this.androidBuildMode,
    required this.currentPlatform,
    required this.currentBridgeLibrary,
    required this.currentBridgeLoadable,
    required this.vendoredStockfishPresent,
    required this.nnuePresent,
    required this.stockfishMainRenamed,
    required this.stubBridgeSourcePresent,
    required this.stubFallbackSelectable,
    required this.androidAbiFilters,
    required this.androidBuiltEngineAbis,
    required this.androidApkEngineAbis,
    required this.androidCmakeDefines,
    required this.androidCmakeSourceCount,
    required this.androidCmakeStockfishSourceCount,
    required this.androidCmakeTargetJson,
    required this.warnings,
    required this.nextRecommendation,
  });

  final String repoRoot;
  final LocalEngineRuntimeMode runtimeMode;
  final LocalEngineRuntimeMode androidBuildMode;
  final String currentPlatform;
  final String currentBridgeLibrary;
  final bool currentBridgeLoadable;
  final bool vendoredStockfishPresent;
  final bool nnuePresent;
  final bool stockfishMainRenamed;
  final bool stubBridgeSourcePresent;
  final bool stubFallbackSelectable;
  final List<String> androidAbiFilters;
  final List<String> androidBuiltEngineAbis;
  final List<String> androidApkEngineAbis;
  final List<String> androidCmakeDefines;
  final int androidCmakeSourceCount;
  final int androidCmakeStockfishSourceCount;
  final String? androidCmakeTargetJson;
  final List<String> warnings;
  final String nextRecommendation;

  bool get androidBuildContainsRealEngine =>
      androidBuildMode == LocalEngineRuntimeMode.real;

  bool get activeAndroidBuildUsesStub =>
      androidBuildMode == LocalEngineRuntimeMode.stubDetected;

  String render() {
    final buffer = StringBuffer()
      ..writeln('# Apex Local Stockfish Engine Audit')
      ..writeln()
      ..writeln('runtime mode: ${runtimeMode.label}')
      ..writeln('android build mode: ${androidBuildMode.label}')
      ..writeln('platform: $currentPlatform')
      ..writeln('bridge library: $currentBridgeLibrary')
      ..writeln('bridge loadable on host: $currentBridgeLoadable')
      ..writeln('vendored Stockfish source: $vendoredStockfishPresent')
      ..writeln('NNUE file present: $nnuePresent')
      ..writeln('stockfish_main patch present: $stockfishMainRenamed')
      ..writeln('stub source present: $stubBridgeSourcePresent')
      ..writeln('stub fallback selectable: $stubFallbackSelectable')
      ..writeln(
        'Android ABI filters: ${androidAbiFilters.isEmpty ? 'none' : androidAbiFilters.join(', ')}',
      )
      ..writeln(
        'Android built engine ABIs: ${androidBuiltEngineAbis.isEmpty ? 'none' : androidBuiltEngineAbis.join(', ')}',
      )
      ..writeln(
        'Android APK engine ABIs: ${androidApkEngineAbis.isEmpty ? 'unknown' : androidApkEngineAbis.join(', ')}',
      )
      ..writeln(
        'CMake defines: ${androidCmakeDefines.isEmpty ? 'unknown' : androidCmakeDefines.join(', ')}',
      )
      ..writeln('CMake source count: $androidCmakeSourceCount')
      ..writeln(
        'CMake Stockfish source count: $androidCmakeStockfishSourceCount',
      )
      ..writeln('CMake target JSON: ${androidCmakeTargetJson ?? 'not found'}')
      ..writeln()
      ..writeln('warnings:');
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

class LocalEngineAuditor {
  const LocalEngineAuditor();

  Future<LocalEngineAuditReport> run({Directory? repoRoot}) async {
    final root = repoRoot ?? _findRepoRoot(Directory.current);
    final nativeRoot = Directory(_join(root.path, 'src', 'native'));
    final stockfishSrc = Directory(
      _join(nativeRoot.path, 'vendor', 'Stockfish', 'src'),
    );
    final mainCpp = File(_join(stockfishSrc.path, 'main.cpp'));
    final nnue = File(_join(stockfishSrc.path, 'nn-37f18f62d772.nnue'));
    final bridge = File(_join(nativeRoot.path, 'stockfish_bridge.cpp'));
    final cmake = File(_join(nativeRoot.path, 'CMakeLists.txt'));

    final bridgeSource = _readIfExists(bridge);
    final cmakeSource = _readIfExists(cmake);
    final mainSource = _readIfExists(mainCpp);
    final stubMarkers = detectStubMarkersInSource(bridgeSource + cmakeSource);

    final cmakeTarget = _readLatestAndroidCmakeTarget(root);
    final abiFilters = _readAndroidAbiFilters(root);
    final builtAbis = _readAndroidBuiltEngineAbis(root);
    final apkAbis = await _readAndroidApkEngineAbis(root);
    final currentLoadable = isStockfishBridgeLoadableForCurrentPlatform();

    final cmakeReal = cmakeTarget.defines.contains('STOCKFISH_REAL=1');
    final cmakeStub = cmakeTarget.defines.contains('STOCKFISH_STUB=1');
    final androidMode = cmakeStub
        ? LocalEngineRuntimeMode.stubDetected
        : cmakeReal && builtAbis.isNotEmpty
        ? LocalEngineRuntimeMode.real
        : LocalEngineRuntimeMode.unavailable;
    final runtimeMode = currentLoadable
        ? cmakeStub
              ? LocalEngineRuntimeMode.stubDetected
              : LocalEngineRuntimeMode.real
        : LocalEngineRuntimeMode.unavailable;

    final warnings = <String>[];
    if (!stockfishSrc.existsSync()) {
      warnings.add('Vendored Stockfish source is missing.');
    }
    if (!nnue.existsSync()) {
      warnings.add('Stockfish NNUE file is missing.');
    }
    if (!mainSource.contains('stockfish_main')) {
      warnings.add('Stockfish main.cpp is not patched to stockfish_main.');
    }
    if (stubMarkers.isNotEmpty) {
      warnings.add(
        'Stub bridge markers are present: ${stubMarkers.map((m) => m.code).join(', ')}.',
      );
    }
    if (cmakeStub) {
      warnings.add(
        'The active Android CMake target is compiled as STOCKFISH_STUB.',
      );
    }
    if (!currentLoadable) {
      warnings.add(
        'The current host cannot load $currentBridgeLibraryName; host benchmarks will report unavailable.',
      );
    }
    if (abiFilters.isNotEmpty && !abiFilters.contains('arm64-v8a')) {
      warnings.add('Android abiFilters do not include arm64-v8a.');
    }
    final extraApkAbis = apkAbis.where((abi) => !abiFilters.contains(abi));
    if (abiFilters.isNotEmpty && extraApkAbis.isNotEmpty) {
      warnings.add(
        'Existing debug APK contains engine ABIs outside current abiFilters: ${extraApkAbis.join(', ')}.',
      );
    }

    return LocalEngineAuditReport(
      repoRoot: root.path,
      runtimeMode: runtimeMode,
      androidBuildMode: androidMode,
      currentPlatform: Platform.operatingSystem,
      currentBridgeLibrary: currentBridgeLibraryName,
      currentBridgeLoadable: currentLoadable,
      vendoredStockfishPresent:
          stockfishSrc.existsSync() &&
          File(_join(stockfishSrc.path, 'uci.cpp')).existsSync() &&
          File(_join(stockfishSrc.path, 'engine.cpp')).existsSync(),
      nnuePresent: nnue.existsSync(),
      stockfishMainRenamed: mainSource.contains('stockfish_main'),
      stubBridgeSourcePresent: stubMarkers.isNotEmpty,
      stubFallbackSelectable:
          cmakeSource.contains('STOCKFISH_STUB') &&
          cmakeSource.contains('STOCKFISH_SOURCES_DIR'),
      androidAbiFilters: abiFilters,
      androidBuiltEngineAbis: builtAbis,
      androidApkEngineAbis: apkAbis,
      androidCmakeDefines: cmakeTarget.defines,
      androidCmakeSourceCount: cmakeTarget.sourceCount,
      androidCmakeStockfishSourceCount: cmakeTarget.stockfishSourceCount,
      androidCmakeTargetJson: cmakeTarget.path,
      warnings: List.unmodifiable(warnings),
      nextRecommendation: _recommendation(
        runtimeMode: runtimeMode,
        androidMode: androidMode,
        currentLoadable: currentLoadable,
      ),
    );
  }
}

class StubSourceMarker {
  const StubSourceMarker(this.code, this.message);

  final String code;
  final String message;
}

List<StubSourceMarker> detectStubMarkersInSource(String source) {
  final markers = <StubSourceMarker>[];
  if (source.contains('STOCKFISH_STUB')) {
    markers.add(
      const StubSourceMarker(
        'stockfish_stub_define',
        'source contains the STOCKFISH_STUB build define',
      ),
    );
  }
  if (source.contains('ApexChess-Stub')) {
    markers.add(
      const StubSourceMarker(
        'stub_engine_id',
        'source contains the ApexChess-Stub UCI id',
      ),
    );
  }
  if (source.contains('score cp 0') && source.contains('bestmove e2e4')) {
    markers.add(
      const StubSourceMarker(
        'constant_stub_output',
        'source contains constant cp 0 / e2e4 output',
      ),
    );
  }
  return markers;
}

class EngineSearchObservation {
  const EngineSearchObservation({
    required this.positionLabel,
    this.bestMove,
    this.scoreCp,
    this.scoreMate,
    this.depth,
    this.nodes,
    required this.elapsed,
  });

  final String positionLabel;
  final String? bestMove;
  final int? scoreCp;
  final int? scoreMate;
  final int? depth;
  final int? nodes;
  final Duration elapsed;
}

class StubBehaviorFinding {
  const StubBehaviorFinding(this.code, this.message);

  final String code;
  final String message;
}

List<StubBehaviorFinding> detectSuspiciousStubBehavior(
  List<EngineSearchObservation> observations,
) {
  if (observations.length < 2) return const [];

  final findings = <StubBehaviorFinding>[];
  final bestMoves = observations
      .map((o) => o.bestMove)
      .whereType<String>()
      .where((m) => m.isNotEmpty && m != '(none)')
      .toSet();
  if (bestMoves.length == 1 && observations.length >= 2) {
    findings.add(
      const StubBehaviorFinding(
        'same_bestmove',
        'unrelated positions produced the same bestmove',
      ),
    );
  }

  final cpScores = observations.map((o) => o.scoreCp).whereType<int>().toSet();
  final mateScores = observations
      .map((o) => o.scoreMate)
      .whereType<int>()
      .toSet();
  if (cpScores.length == 1 &&
      mateScores.isEmpty &&
      observations.where((o) => o.scoreCp != null).length >= 2) {
    findings.add(
      const StubBehaviorFinding(
        'constant_cp',
        'unrelated positions produced a constant centipawn score',
      ),
    );
  }

  final allTinyAndImmediate = observations.every((o) {
    final shallow = (o.depth ?? 0) <= 1;
    final tinyNodes = (o.nodes ?? 0) <= 1;
    return shallow && tinyNodes && o.elapsed.inMilliseconds <= 20;
  });
  if (allTinyAndImmediate) {
    findings.add(
      const StubBehaviorFinding(
        'immediate_no_search',
        'responses were immediate with no meaningful depth or node count',
      ),
    );
  }

  return findings;
}

String get currentBridgeLibraryName {
  if (Platform.isAndroid || Platform.isLinux) return 'libstockfish_bridge.so';
  if (Platform.isWindows) return 'stockfish_bridge.dll';
  if (Platform.isMacOS || Platform.isIOS) return 'process symbols';
  return 'unsupported';
}

bool isStockfishBridgeLoadableForCurrentPlatform() {
  try {
    final lib = openStockfishBridge();
    lib.lookup<NativeFunction<Void Function()>>('stockfish_create');
    return true;
  } on Object {
    return false;
  }
}

class _CmakeTargetSnapshot {
  const _CmakeTargetSnapshot({
    this.path,
    this.defines = const [],
    this.sourceCount = 0,
    this.stockfishSourceCount = 0,
  });

  final String? path;
  final List<String> defines;
  final int sourceCount;
  final int stockfishSourceCount;
}

_CmakeTargetSnapshot _readLatestAndroidCmakeTarget(Directory root) {
  final cxx = Directory(_join(root.path, 'build', '.cxx'));
  if (!cxx.existsSync()) return const _CmakeTargetSnapshot();

  final files =
      cxx.listSync(recursive: true).whereType<File>().where((f) {
        final name = _basename(f.path);
        return name.startsWith('target-stockfish_bridge-') &&
            name.endsWith('.json') &&
            f.path.contains('${_sep}reply$_sep');
      }).toList()..sort((a, b) {
        final aArm = a.path.contains('arm64-v8a') ? 0 : 1;
        final bArm = b.path.contains('arm64-v8a') ? 0 : 1;
        if (aArm != bArm) return aArm.compareTo(bArm);
        return b.statSync().modified.compareTo(a.statSync().modified);
      });
  if (files.isEmpty) return const _CmakeTargetSnapshot();

  try {
    final path = files.first.path;
    final json = jsonDecode(files.first.readAsStringSync()) as Map;
    final defines = <String>{};
    for (final group in (json['compileGroups'] as List? ?? const [])) {
      if (group is! Map) continue;
      for (final define in (group['defines'] as List? ?? const [])) {
        if (define is Map && define['define'] is String) {
          defines.add(define['define'] as String);
        }
      }
    }
    final sources = (json['sources'] as List? ?? const [])
        .whereType<Map>()
        .map((s) => s['path'])
        .whereType<String>()
        .toList(growable: false);
    return _CmakeTargetSnapshot(
      path: path,
      defines: defines.toList(growable: false)..sort(),
      sourceCount: sources.length,
      stockfishSourceCount: sources
          .where((s) => s.replaceAll('\\', '/').contains('vendor/Stockfish'))
          .length,
    );
  } on Object {
    return const _CmakeTargetSnapshot();
  }
}

List<String> _readAndroidAbiFilters(Directory root) {
  final buildGradle = File(
    _join(root.path, 'android', 'app', 'build.gradle.kts'),
  );
  final source = _readIfExists(buildGradle);
  final match = RegExp(
    r'abiFilters\s*\+=\s*listOf\(([^)]*)\)',
    dotAll: true,
  ).firstMatch(source);
  if (match == null) return const [];
  final body = match.group(1) ?? '';
  final abis = RegExp(
    '"([^"]+)"',
  ).allMatches(body).map((m) => m.group(1)!).toList(growable: false)..sort();
  return abis;
}

List<String> _readAndroidBuiltEngineAbis(Directory root) {
  final abis = <String>{};
  final merged = Directory(
    _join(
      root.path,
      'build',
      'app',
      'intermediates',
      'merged_native_libs',
      'debug',
      'mergeDebugNativeLibs',
      'out',
      'lib',
    ),
  );
  if (merged.existsSync()) {
    for (final entity in merged.listSync()) {
      if (entity is! Directory) continue;
      final lib = File(_join(entity.path, 'libstockfish_bridge.so'));
      if (lib.existsSync()) abis.add(_basename(entity.path));
    }
  }

  final cxx = Directory(
    _join(root.path, 'build', 'app', 'intermediates', 'cxx'),
  );
  if (cxx.existsSync()) {
    for (final file
        in cxx
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => _basename(f.path) == 'libstockfish_bridge.so')) {
      final parent = _basename(Directory(file.parent.path).path);
      if (parent.isNotEmpty) abis.add(parent);
    }
  }
  return abis.toList(growable: false)..sort();
}

Future<List<String>> _readAndroidApkEngineAbis(Directory root) async {
  final apk = File(
    _join(root.path, 'build', 'app', 'outputs', 'flutter-apk', 'app-debug.apk'),
  );
  if (!apk.existsSync()) return const [];
  try {
    final result = await Process.run('tar', ['-tf', apk.path]);
    if (result.exitCode != 0) return const [];
    final lines = result.stdout.toString().split(RegExp(r'\r?\n'));
    final abis = <String>{};
    for (final line in lines) {
      final match = RegExp(
        r'^lib/([^/]+)/libstockfish_bridge\.so$',
      ).firstMatch(line.trim());
      if (match != null) abis.add(match.group(1)!);
    }
    return abis.toList(growable: false)..sort();
  } on Object {
    return const [];
  }
}

Directory _findRepoRoot(Directory start) {
  var current = start.absolute;
  while (true) {
    if (File(_join(current.path, 'pubspec.yaml')).existsSync()) return current;
    final parent = current.parent;
    if (parent.path == current.path) return start.absolute;
    current = parent;
  }
}

String _recommendation({
  required LocalEngineRuntimeMode runtimeMode,
  required LocalEngineRuntimeMode androidMode,
  required bool currentLoadable,
}) {
  if (androidMode == LocalEngineRuntimeMode.stubDetected ||
      runtimeMode == LocalEngineRuntimeMode.stubDetected) {
    return 'Make real Stockfish mandatory for analysis builds before Phase 30C.';
  }
  if (androidMode == LocalEngineRuntimeMode.real && !currentLoadable) {
    return 'Benchmark on Android or build a host bridge; do not infer speed from unavailable host runtime.';
  }
  if (androidMode == LocalEngineRuntimeMode.real &&
      runtimeMode == LocalEngineRuntimeMode.real) {
    return 'Use benchmark numbers to decide whether the isolate bridge is enough for Phase 30C.';
  }
  return 'Finish real engine artifact wiring before building more analysis behavior.';
}

String _readIfExists(File file) {
  try {
    return file.existsSync() ? file.readAsStringSync() : '';
  } on Object {
    return '';
  }
}

String _join(
  String a,
  String b, [
  String? c,
  String? d,
  String? e,
  String? f,
  String? g,
  String? h,
  String? i,
  String? j,
  String? k,
  String? l,
]) {
  final parts = <String>[
    a,
    b,
    if (c != null) c,
    if (d != null) d,
    if (e != null) e,
    if (f != null) f,
    if (g != null) g,
    if (h != null) h,
    if (i != null) i,
    if (j != null) j,
    if (k != null) k,
    if (l != null) l,
  ];
  return parts.join(_sep);
}

String get _sep => Platform.pathSeparator;

String _basename(String path) {
  final normalized = path.replaceAll('\\', '/');
  final slash = normalized.lastIndexOf('/');
  return slash < 0 ? normalized : normalized.substring(slash + 1);
}

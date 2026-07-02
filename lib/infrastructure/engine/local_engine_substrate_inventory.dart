import 'dart:convert';
import 'dart:io';

const localEngineSubstrateInventoryNextRecommendation =
    'implementLocalUciHandshakeProbe';

class LocalEngineSubstrateInventory {
  const LocalEngineSubstrateInventory({
    required this.stockfishVendorDirectoryExists,
    required this.nativeBridgeDirectoryExists,
    required this.cmakeFileExists,
    required this.androidGradleFileExists,
    required this.androidAbiFiltersMentioned,
    required this.arm64V8aMentioned,
    required this.stockfishSourceCandidatePaths,
    required this.stockfishBinaryCandidatePaths,
    required this.nativeBridgeCandidatePaths,
    required this.cmakeCandidatePaths,
    required this.gradleCandidatePaths,
    required this.missingRequiredPieces,
    required this.warnings,
    required this.blockers,
    required this.safeForPhase35B,
    required this.nextRecommendation,
  });

  final bool stockfishVendorDirectoryExists;
  final bool nativeBridgeDirectoryExists;
  final bool cmakeFileExists;
  final bool androidGradleFileExists;
  final bool androidAbiFiltersMentioned;
  final bool arm64V8aMentioned;
  final List<String> stockfishSourceCandidatePaths;
  final List<String> stockfishBinaryCandidatePaths;
  final List<String> nativeBridgeCandidatePaths;
  final List<String> cmakeCandidatePaths;
  final List<String> gradleCandidatePaths;
  final List<String> missingRequiredPieces;
  final List<String> warnings;
  final List<String> blockers;
  final bool safeForPhase35B;
  final String nextRecommendation;

  Map<String, Object?> toJson() => {
    'stockfishVendorDirectoryExists': stockfishVendorDirectoryExists,
    'nativeBridgeDirectoryExists': nativeBridgeDirectoryExists,
    'cmakeFileExists': cmakeFileExists,
    'androidGradleFileExists': androidGradleFileExists,
    'androidAbiFiltersMentioned': androidAbiFiltersMentioned,
    'arm64V8aMentioned': arm64V8aMentioned,
    'stockfishSourceCandidatePaths': stockfishSourceCandidatePaths,
    'stockfishBinaryCandidatePaths': stockfishBinaryCandidatePaths,
    'nativeBridgeCandidatePaths': nativeBridgeCandidatePaths,
    'cmakeCandidatePaths': cmakeCandidatePaths,
    'gradleCandidatePaths': gradleCandidatePaths,
    'missingRequiredPieces': missingRequiredPieces,
    'warnings': warnings,
    'blockers': blockers,
    'safeForPhase35B': safeForPhase35B,
    'nextRecommendation': nextRecommendation,
    'forbiddenOperationsNotAttempted': const [
      'stockfishExecution',
      'ffiCall',
      'nativeProcessSpawn',
      'uciCommand',
      'fenOrPgnAnalysis',
      'classifierLabeling',
      'schedulerExecution',
      'analyzerRuntimeWiring',
      'persistenceWrite',
    ],
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Apex Local Engine Substrate Inventory')
      ..writeln()
      ..writeln('phase: Phase 35A - Local Engine Substrate Inventory')
      ..writeln('safeForPhase35B: $safeForPhase35B')
      ..writeln('nextRecommendation: $nextRecommendation')
      ..writeln()
      ..writeln('## Detected Substrate')
      ..writeln(
        '- stockfish vendor directory exists: '
        '$stockfishVendorDirectoryExists',
      )
      ..writeln(
        '- native bridge directory exists: $nativeBridgeDirectoryExists',
      )
      ..writeln('- CMake files exist: $cmakeFileExists')
      ..writeln('- Android Gradle file exists: $androidGradleFileExists')
      ..writeln('- Android ABI filters mentioned: $androidAbiFiltersMentioned')
      ..writeln('- arm64-v8a mentioned: $arm64V8aMentioned')
      ..writeln()
      ..writeln('## Stockfish Source Candidates');
    _writeList(buffer, stockfishSourceCandidatePaths);
    buffer
      ..writeln()
      ..writeln('## Stockfish Binary Candidates');
    _writeList(buffer, stockfishBinaryCandidatePaths);
    buffer
      ..writeln()
      ..writeln('## Native Bridge Candidates');
    _writeList(buffer, nativeBridgeCandidatePaths);
    buffer
      ..writeln()
      ..writeln('## CMake Candidates');
    _writeList(buffer, cmakeCandidatePaths);
    buffer
      ..writeln()
      ..writeln('## Gradle Candidates');
    _writeList(buffer, gradleCandidatePaths);
    buffer
      ..writeln()
      ..writeln('## Missing Required Pieces');
    _writeList(buffer, missingRequiredPieces);
    buffer
      ..writeln()
      ..writeln('## Blockers');
    _writeList(buffer, blockers);
    buffer
      ..writeln()
      ..writeln('## Warnings');
    _writeList(buffer, warnings);
    buffer
      ..writeln()
      ..writeln('## Safety Notes')
      ..writeln('- Stockfish execution: not attempted')
      ..writeln('- FFI calls: not attempted')
      ..writeln('- Native process spawn: not attempted')
      ..writeln('- UCI commands: not sent')
      ..writeln('- Analyzer runtime wiring: not changed')
      ..writeln('- Persistence/cache/database writes: not attempted');
    return buffer.toString();
  }

  static void _writeList(StringBuffer buffer, List<String> values) {
    if (values.isEmpty) {
      buffer.writeln('- none');
      return;
    }
    for (final value in values) {
      buffer.writeln('- $value');
    }
  }
}

class LocalEngineSubstrateInventoryRunner {
  const LocalEngineSubstrateInventoryRunner();

  LocalEngineSubstrateInventory run({Directory? repoRoot}) {
    final root = repoRoot ?? _findRepoRoot(Directory.current);
    final stockfishVendorDirectoryExists = _dirExists(
      root,
      _stockfishVendorDirectory,
    );
    final stockfishSourceDirectoryExists = _dirExists(
      root,
      _stockfishSourceDirectory,
    );
    final nativeBridgeDirectoryExists = _dirExists(root, _nativeBridgeRoot);
    final nativeCmakeExists = _fileExists(root, _nativeCmakeFile);
    final androidCmakeExists = _fileExists(root, _androidCmakeFile);
    final cmakeFileExists = nativeCmakeExists && androidCmakeExists;
    final androidGradleFileExists = _fileExists(root, _androidGradleFile);
    final gradleSource = _readIfExists(root, _androidGradleFile);
    final nativeCmakeSource = _readIfExists(root, _nativeCmakeFile);
    final androidCmakeSource = _readIfExists(root, _androidCmakeFile);

    final androidAbiFiltersMentioned = gradleSource.contains('abiFilters');
    final arm64V8aMentioned = gradleSource.contains('arm64-v8a');

    final stockfishSourceCandidates = _existingPaths(root, const [
      _stockfishVendorDirectory,
      _stockfishSourceDirectory,
      'src/native/vendor/Stockfish/src/main.cpp',
      'src/native/vendor/Stockfish/src/uci.cpp',
      'src/native/vendor/Stockfish/src/search.cpp',
      'src/native/vendor/Stockfish/src/nn-37f18f62d772.nnue',
    ]);
    final nativeBridgeCandidates = _existingPaths(root, const [
      _nativeBridgeRoot,
      'src/native/stockfish_bridge.cpp',
      'src/native/stockfish_bridge.h',
      'lib/core/infrastructure/engine/stockfish/stockfish_bindings.dart',
      'lib/core/infrastructure/engine/stockfish/stockfish_library.dart',
      'lib/core/infrastructure/engine/stockfish/stockfish_engine.dart',
      'lib/core/infrastructure/engine/stockfish/stockfish_isolate.dart',
    ]);
    final cmakeCandidates = _existingPaths(root, const [
      _nativeCmakeFile,
      _androidCmakeFile,
    ]);
    final gradleCandidates = _existingPaths(root, const [
      _androidGradleFile,
      'android/build.gradle.kts',
      'android/settings.gradle.kts',
      'android/gradle.properties',
    ]);
    final stockfishBinaryCandidates = _findBridgeBinaryCandidates(root);

    final missingRequiredPieces = <String>[];
    if (!stockfishVendorDirectoryExists) {
      missingRequiredPieces.add(_stockfishVendorDirectory);
    }
    if (!stockfishSourceDirectoryExists) {
      missingRequiredPieces.add(_stockfishSourceDirectory);
    }
    for (final path in const [
      'src/native/vendor/Stockfish/src/main.cpp',
      'src/native/vendor/Stockfish/src/uci.cpp',
      'src/native/vendor/Stockfish/src/search.cpp',
      'src/native/vendor/Stockfish/src/nn-37f18f62d772.nnue',
      'src/native/stockfish_bridge.cpp',
      'src/native/stockfish_bridge.h',
      _nativeCmakeFile,
      _androidCmakeFile,
      _androidGradleFile,
    ]) {
      if (!_exists(root, path)) missingRequiredPieces.add(path);
    }
    if (!androidAbiFiltersMentioned) {
      missingRequiredPieces.add('android app Gradle abiFilters');
    }
    if (!arm64V8aMentioned) {
      missingRequiredPieces.add('android app Gradle arm64-v8a ABI filter');
    }

    final blockers = <String>[];
    if (!stockfishSourceDirectoryExists && stockfishBinaryCandidates.isEmpty) {
      blockers.add(
        'No Stockfish source directory or bridge binary candidate was found.',
      );
    }
    if (!nativeBridgeDirectoryExists || nativeBridgeCandidates.length < 2) {
      blockers.add('Native bridge source/header candidates are incomplete.');
    }
    if (!cmakeFileExists) {
      blockers.add(
        'Required native and Android CMake entry points are missing.',
      );
    }
    if (!androidGradleFileExists) {
      blockers.add('Android app Gradle file is missing.');
    }
    if (!androidAbiFiltersMentioned || !arm64V8aMentioned) {
      blockers.add('Android ABI filter configuration is incomplete.');
    }
    if (!nativeCmakeSource.contains('STOCKFISH_REAL=1')) {
      blockers.add('Native CMake does not declare real Stockfish mode.');
    }
    if (!androidCmakeSource.contains('add_subdirectory')) {
      blockers.add('Android CMake entry point does not forward to src/native.');
    }

    final warnings = <String>[];
    if (stockfishBinaryCandidates.isEmpty) {
      warnings.add(
        'No built/prebuilt libstockfish_bridge.so candidate was found; Phase 35B may need a device/build context before a handshake can run.',
      );
    }
    if (!nativeCmakeSource.contains('message(FATAL_ERROR') ||
        !nativeCmakeSource.contains('APEX_ALLOW_STOCKFISH_STUB is OFF')) {
      warnings.add(
        'Native CMake fail-closed stub policy was not clearly detected.',
      );
    }
    if (stockfishBinaryCandidates.isNotEmpty &&
        !stockfishBinaryCandidates.any((path) => path.contains('arm64-v8a'))) {
      warnings.add(
        'Bridge binary candidates exist, but no arm64-v8a binary candidate was found.',
      );
    }

    blockers.sort();
    missingRequiredPieces.sort();
    warnings.sort();

    return LocalEngineSubstrateInventory(
      stockfishVendorDirectoryExists: stockfishVendorDirectoryExists,
      nativeBridgeDirectoryExists: nativeBridgeDirectoryExists,
      cmakeFileExists: cmakeFileExists,
      androidGradleFileExists: androidGradleFileExists,
      androidAbiFiltersMentioned: androidAbiFiltersMentioned,
      arm64V8aMentioned: arm64V8aMentioned,
      stockfishSourceCandidatePaths: List.unmodifiable(
        stockfishSourceCandidates,
      ),
      stockfishBinaryCandidatePaths: List.unmodifiable(
        stockfishBinaryCandidates,
      ),
      nativeBridgeCandidatePaths: List.unmodifiable(nativeBridgeCandidates),
      cmakeCandidatePaths: List.unmodifiable(cmakeCandidates),
      gradleCandidatePaths: List.unmodifiable(gradleCandidates),
      missingRequiredPieces: List.unmodifiable(missingRequiredPieces),
      warnings: List.unmodifiable(warnings),
      blockers: List.unmodifiable(blockers),
      safeForPhase35B: blockers.isEmpty,
      nextRecommendation: localEngineSubstrateInventoryNextRecommendation,
    );
  }
}

const _stockfishVendorDirectory = 'src/native/vendor/Stockfish';
const _stockfishSourceDirectory = 'src/native/vendor/Stockfish/src';
const _nativeBridgeRoot = 'src/native';
const _nativeCmakeFile = 'src/native/CMakeLists.txt';
const _androidCmakeFile = 'android/app/src/main/cpp/CMakeLists.txt';
const _androidGradleFile = 'android/app/build.gradle.kts';

Directory _findRepoRoot(Directory start) {
  var current = start.absolute;
  while (true) {
    if (File(_join(current.path, 'pubspec.yaml')).existsSync() &&
        Directory(_join(current.path, '.git')).existsSync()) {
      return current;
    }
    final parent = current.parent;
    if (parent.path == current.path) return start.absolute;
    current = parent;
  }
}

List<String> _existingPaths(Directory root, List<String> paths) {
  final out = <String>[];
  for (final path in paths) {
    if (_exists(root, path)) out.add(path);
  }
  out.sort();
  return out;
}

List<String> _findBridgeBinaryCandidates(Directory root) {
  final out = <String>{};
  for (final path in const [
    'android/app/src/main/jniLibs',
    'build/app/intermediates/cxx',
    'build/app/intermediates/merged_native_libs',
    'build/app/intermediates/stripped_native_libs',
  ]) {
    final directory = Directory(_path(root, path));
    if (!directory.existsSync()) continue;
    for (final entity in directory.listSync(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      if (_basename(entity.path) == 'libstockfish_bridge.so') {
        out.add(_relativePath(root, entity.path));
      }
    }
  }
  return out.toList(growable: false)..sort();
}

bool _exists(Directory root, String relativePath) =>
    File(_path(root, relativePath)).existsSync() ||
    Directory(_path(root, relativePath)).existsSync();

bool _fileExists(Directory root, String relativePath) =>
    File(_path(root, relativePath)).existsSync();

bool _dirExists(Directory root, String relativePath) =>
    Directory(_path(root, relativePath)).existsSync();

String _readIfExists(Directory root, String relativePath) {
  final file = File(_path(root, relativePath));
  if (!file.existsSync()) return '';
  return file.readAsStringSync();
}

String _path(Directory root, String relativePath) =>
    _join(root.path, relativePath.split('/').join(Platform.pathSeparator));

String _join(String left, String right) {
  if (left.endsWith(Platform.pathSeparator)) return '$left$right';
  return '$left${Platform.pathSeparator}$right';
}

String _basename(String path) => path.split(RegExp(r'[\\/]')).last;

String _relativePath(Directory root, String absolutePath) {
  final normalizedRoot = root.absolute.path;
  final normalizedPath = File(absolutePath).absolute.path;
  if (normalizedPath.startsWith(normalizedRoot)) {
    final start =
        normalizedRoot.length +
        (normalizedRoot.endsWith(Platform.pathSeparator) ? 0 : 1);
    return normalizedPath.substring(start).replaceAll('\\', '/');
  }
  return normalizedPath.replaceAll('\\', '/');
}

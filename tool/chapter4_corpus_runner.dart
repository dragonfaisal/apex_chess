import 'dart:io';

const _fixturePath =
    'test/fixtures/classification/apex_classification_policy_corpus_v1.json';
const _exportTestPath =
    'test/core/domain/services/classification_policy_corpus_test.dart';
const _exportTestName = 'exports JSON and CSV when invoked by CLI tool';

const _exportFlag = 'APEX_CHAPTER4_CORPUS_EXPORT';
const _fixtureEnvironment = 'APEX_CHAPTER4_CORPUS_FIXTURE';
const _jsonEnvironment = 'APEX_CHAPTER4_CORPUS_JSON';
const _csvEnvironment = 'APEX_CHAPTER4_CORPUS_CSV';
const _pliesEnvironment = 'APEX_CHAPTER4_CORPUS_PERFORMANCE_PLIES';
const _iterationsEnvironment = 'APEX_CHAPTER4_CORPUS_PERFORMANCE_ITERATIONS';

const _defaultJsonOutput =
    r'C:\apex_chess_reports\chapter4\Apex_Chess_Chapter_4_Corpus_Results.json';
const _defaultCsvOutput =
    r'C:\apex_chess_reports\chapter4\Apex_Chess_Chapter_4_Label_Matrix.csv';

void main(List<String> args) {
  final options = _Options.parse(args);
  if (options.help) {
    stdout.writeln(_usage);
    return;
  }

  try {
    final repositoryRoot = _findRepositoryRoot();
    _rejectRepositoryOutput(
      outputPath: options.jsonOutput,
      repositoryRoot: repositoryRoot,
      optionName: '--json-output',
    );
    _rejectRepositoryOutput(
      outputPath: options.csvOutput,
      repositoryRoot: repositoryRoot,
      optionName: '--csv-output',
    );

    final process = Process.runSync(
      'flutter',
      <String>[
        'test',
        '--no-pub',
        _exportTestPath,
        '--plain-name',
        _exportTestName,
      ],
      workingDirectory: repositoryRoot.path,
      runInShell: true,
      environment: <String, String>{
        _exportFlag: '1',
        _fixtureEnvironment: options.fixturePath,
        _jsonEnvironment: File(options.jsonOutput).absolute.path,
        _csvEnvironment: File(options.csvOutput).absolute.path,
        _pliesEnvironment: options.performancePlies.toString(),
        _iterationsEnvironment: options.performanceIterations.toString(),
      },
    );
    stdout.write(process.stdout);
    stderr.write(process.stderr);
    exitCode = process.exitCode;
  } on Object catch (error, stackTrace) {
    stderr
      ..writeln('Chapter 4 corpus runner failed: $error')
      ..writeln(stackTrace);
    exitCode = 2;
  }
}

class _Options {
  const _Options({
    required this.fixturePath,
    required this.jsonOutput,
    required this.csvOutput,
    required this.performancePlies,
    required this.performanceIterations,
    required this.help,
  });

  final String fixturePath;
  final String jsonOutput;
  final String csvOutput;
  final int performancePlies;
  final int performanceIterations;
  final bool help;

  factory _Options.parse(List<String> args) {
    var fixture = _fixturePath;
    var json = _defaultJsonOutput;
    var csv = _defaultCsvOutput;
    var plies = 100;
    var iterations = 1000;
    var help = false;

    String valueAt(int index, String name) {
      if (index + 1 >= args.length) {
        throw FormatException('Missing value for $name.');
      }
      return args[index + 1];
    }

    for (var index = 0; index < args.length; index++) {
      final arg = args[index];
      if (arg == '--help' || arg == '-h') {
        help = true;
      } else if (arg.startsWith('--fixture=')) {
        fixture = arg.substring('--fixture='.length);
      } else if (arg == '--fixture') {
        fixture = valueAt(index, arg);
        index++;
      } else if (arg.startsWith('--json-output=')) {
        json = arg.substring('--json-output='.length);
      } else if (arg == '--json-output') {
        json = valueAt(index, arg);
        index++;
      } else if (arg.startsWith('--csv-output=')) {
        csv = arg.substring('--csv-output='.length);
      } else if (arg == '--csv-output') {
        csv = valueAt(index, arg);
        index++;
      } else if (arg.startsWith('--performance-plies=')) {
        plies = _positiveInt(
          arg.substring('--performance-plies='.length),
          '--performance-plies',
        );
      } else if (arg.startsWith('--performance-iterations=')) {
        iterations = _positiveInt(
          arg.substring('--performance-iterations='.length),
          '--performance-iterations',
        );
      } else {
        throw FormatException('Unknown argument: $arg');
      }
    }
    return _Options(
      fixturePath: fixture,
      jsonOutput: json,
      csvOutput: csv,
      performancePlies: plies,
      performanceIterations: iterations,
      help: help,
    );
  }
}

Directory _findRepositoryRoot() {
  final starts = <Directory>[
    Directory.current.absolute,
    File.fromUri(Platform.script).parent.absolute,
  ];
  for (final start in starts) {
    var cursor = start;
    while (true) {
      if (File(
            '${cursor.path}${Platform.pathSeparator}pubspec.yaml',
          ).existsSync() &&
          File(
            '${cursor.path}${Platform.pathSeparator}$_exportTestPath',
          ).existsSync()) {
        return cursor;
      }
      final parent = cursor.parent;
      if (parent.path == cursor.path) break;
      cursor = parent;
    }
  }
  throw StateError('Unable to locate the Apex Chess repository root.');
}

void _rejectRepositoryOutput({
  required String outputPath,
  required Directory repositoryRoot,
  required String optionName,
}) {
  final root = repositoryRoot.absolute.path.toLowerCase();
  final output = File(outputPath).absolute.path.toLowerCase();
  final rootPrefix = root.endsWith(Platform.pathSeparator)
      ? root
      : '$root${Platform.pathSeparator}';
  if (output == root || output.startsWith(rootPrefix)) {
    throw FormatException('$optionName must be outside the repository.');
  }
}

int _positiveInt(String raw, String name) {
  final parsed = int.tryParse(raw);
  if (parsed == null || parsed <= 0) {
    throw FormatException('$name must be a positive integer.');
  }
  return parsed;
}

const _usage = r'''
Usage:
  dart run tool/chapter4_corpus_runner.dart [options]

Options:
  --fixture <path>                 Frozen corpus fixture.
  --json-output <path>             JSON result destination.
  --csv-output <path>              CSV label matrix destination.
  --performance-plies=<count>      Synthetic timeline length (default 100).
  --performance-iterations=<count> Repetitions (default 1000).
  --help                            Show this help.

The default output paths are outside the repository under
C:\apex_chess_reports\chapter4\.

The launcher runs the focused Flutter corpus export test because the production
classifier is loaded under the Flutter runtime.
''';

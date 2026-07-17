import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/infrastructure/openings/opening_index.dart';

Future<void> main(List<String> arguments) async {
  final sourcePath = arguments.isEmpty
      ? 'assets/openings/eco.tsv'
      : arguments.first;
  final source = File(sourcePath);
  if (!await source.exists()) {
    stderr.writeln('Opening source is missing: $sourcePath');
    exitCode = 2;
    return;
  }

  final body = await source.readAsString();
  final index = OpeningIndex.fromTsv(body);
  final metrics = index.metrics;
  final denominator =
      metrics.oldTerminalPositions + metrics.missingPrefixPositionsVsOld;
  final oldCoverage = denominator == 0
      ? 0.0
      : metrics.oldTerminalPositions * 100.0 / denominator;

  const samples = 100000;
  var lookupMicros = 0;
  if (index.isAvailable) {
    final lines = const LineSplitter()
        .convert(body)
        .skip(1)
        .where((line) => line.trim().isNotEmpty);
    final first = lines.first.split('\t');
    final pgn = first[2];
    // The first bundled row is 1.Nh3 from the standard initial position.
    // Keeping this benchmark input fixed makes successive reports comparable.
    final before = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
    final after = 'rnbqkbnr/pppppppp/8/8/8/7N/PPPPPPPP/RNBQKB1R b KQkq - 1 1';
    if (!pgn.contains('Nh3')) {
      throw const FormatException('Unexpected first opening benchmark row.');
    }
    final watch = Stopwatch()..start();
    for (var i = 0; i < samples; i++) {
      index.lookupTransition(
        fenBefore: before,
        playedMoveUci: 'g1h3',
        fenAfter: after,
        ply: 0,
        standardStart: true,
      );
    }
    watch.stop();
    lookupMicros = watch.elapsedMicroseconds;
  }

  final report = <String, Object?>{
    'contract': 'apex-opening-coverage-v1',
    'sourcePath': sourcePath.replaceAll('\\', '/'),
    'artifactIdentity': index.identity.toJson(),
    'artifactSemanticId': index.identity.semanticId,
    'artifactVerification': index.verification.name,
    'unavailableReasonCode': index.unavailableReasonCode,
    ...metrics.toJson(),
    'oldUniquePrefixCoveragePercent': oldCoverage,
    'missingPrefixReductionCount': metrics.missingPrefixPositionsVsOld,
    'missingPrefixReductionPercent': 100.0 - oldCoverage,
    'lookupSamples': index.isAvailable ? samples : 0,
    'lookupTotalMicros': lookupMicros,
    'lookupMicrosPerOperation': index.isAvailable
        ? lookupMicros / samples
        : null,
    'lookupCount': index.lookupCount,
  };
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(report));
  if (!index.isAvailable) exitCode = 1;
}

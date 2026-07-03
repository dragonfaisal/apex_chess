import 'dart:io' as io;

import 'package:apex_chess/features/analysis/domain/analyzer_expected_points.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_expected_points_delta_probe.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

const analyzerExpectedPointsReportExitSuccess = 0;
const analyzerExpectedPointsReportExitUsage = 64;
const analyzerExpectedPointsReportExitBlockedStrict = 68;

enum AnalyzerExpectedPointsReportFormat {
  markdown('markdown'),
  json('json');

  const AnalyzerExpectedPointsReportFormat(this.wire);

  final String wire;
}

class AnalyzerExpectedPointsCommandRequest {
  const AnalyzerExpectedPointsCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.timeout,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const AnalyzerExpectedPointsCommandRequest.invalid(this.failure)
    : isValid = false,
      format = AnalyzerExpectedPointsReportFormat.markdown,
      strict = false,
      timeout = defaultLocalSearchEvalProbeTimeout,
      showHelp = false;

  final bool isValid;
  final String failure;
  final AnalyzerExpectedPointsReportFormat format;
  final bool strict;
  final Duration timeout;
  final bool showHelp;
}

class AnalyzerExpectedPointsCommandResult {
  const AnalyzerExpectedPointsCommandResult({
    required this.exitCode,
    required this.stdoutText,
    required this.stderrText,
    this.result,
  });

  final int exitCode;
  final String stdoutText;
  final String stderrText;
  final AnalyzerExpectedPointsDeltaResult? result;
}

Future<void> main(List<String> args) async {
  final result = await runAnalyzerExpectedPointsCommand(args: args);
  if (result.stdoutText.isNotEmpty) io.stdout.write(result.stdoutText);
  if (result.stderrText.isNotEmpty) io.stderr.write(result.stderrText);
  io.exitCode = result.exitCode;
}

Future<AnalyzerExpectedPointsCommandResult> runAnalyzerExpectedPointsCommand({
  required List<String> args,
  LocalAnalyzerExpectedPointsDeltaProbe? probe,
}) async {
  final request = validateAnalyzerExpectedPointsArgs(args);
  if (!request.isValid) {
    return AnalyzerExpectedPointsCommandResult(
      exitCode: analyzerExpectedPointsReportExitUsage,
      stdoutText: '',
      stderrText: _usage(request.failure),
    );
  }
  if (request.showHelp) {
    return AnalyzerExpectedPointsCommandResult(
      exitCode: analyzerExpectedPointsReportExitSuccess,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = await (probe ?? LocalAnalyzerExpectedPointsDeltaProbe()).run(
    const AnalyzerExpectedPointsDeltaRequest.controlled(),
    timeout: request.timeout,
  );
  final stdoutText = switch (request.format) {
    AnalyzerExpectedPointsReportFormat.markdown => result.renderMarkdown(),
    AnalyzerExpectedPointsReportFormat.json => '${result.renderJson()}\n',
  };
  final blocked = request.strict && !result.safeForPhase35L;

  return AnalyzerExpectedPointsCommandResult(
    exitCode: blocked
        ? analyzerExpectedPointsReportExitBlockedStrict
        : analyzerExpectedPointsReportExitSuccess,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

AnalyzerExpectedPointsCommandRequest validateAnalyzerExpectedPointsArgs(
  List<String> args,
) {
  var format = AnalyzerExpectedPointsReportFormat.markdown;
  var strict = false;
  var timeout = defaultLocalSearchEvalProbeTimeout;
  var formatSeen = false;
  var timeoutSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const AnalyzerExpectedPointsCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return AnalyzerExpectedPointsCommandRequest.valid(
        format: AnalyzerExpectedPointsReportFormat.markdown,
        strict: false,
        timeout: timeout,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const AnalyzerExpectedPointsCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const AnalyzerExpectedPointsCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_timeoutFlag)) {
      if (timeoutSeen) {
        return const AnalyzerExpectedPointsCommandRequest.invalid(
          'duplicateTimeout',
        );
      }
      final parsed = int.tryParse(arg.substring(_timeoutFlag.length).trim());
      if (parsed == null || parsed <= 0 || parsed > 30000) {
        return const AnalyzerExpectedPointsCommandRequest.invalid(
          'invalidTimeout',
        );
      }
      timeout = Duration(milliseconds: parsed);
      timeoutSeen = true;
      continue;
    }
    if (arg == _strictFlag) {
      strict = true;
      continue;
    }
    return const AnalyzerExpectedPointsCommandRequest.invalid('unknownFlag');
  }

  return AnalyzerExpectedPointsCommandRequest.valid(
    format: format,
    strict: strict,
    timeout: timeout,
  );
}

AnalyzerExpectedPointsReportFormat? _formatByWire(String value) {
  for (final format in AnalyzerExpectedPointsReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Apex analyzer expected-points delta probe usage: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/analyzer_expected_points_delta_probe_report.dart',
    )
    ..writeln(
      '  dart run tool/analyzer_expected_points_delta_probe_report.dart --format=markdown --strict',
    )
    ..writeln(
      '  dart run tool/analyzer_expected_points_delta_probe_report.dart --format=json --strict',
    )
    ..writeln(
      '  dart run tool/analyzer_expected_points_delta_probe_report.dart --timeout-ms=5000',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln('  --timeout-ms=<1..30000>')
    ..writeln()
    ..writeln('Safety:')
    ..writeln('  Phase 35K wraps the controlled CP loss candidate probe and')
    ..writeln('  computes provisional developer-only expected-points values.')
    ..writeln('  It does not compute official Win%, official CP-loss,')
    ..writeln('  accuracy, ACPL, move quality, classifier labels, saved')
    ..writeln('  analysis, scheduler execution, product UI, or backend work.');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _timeoutFlag = '--timeout-ms=';
const _strictFlag = '--strict';

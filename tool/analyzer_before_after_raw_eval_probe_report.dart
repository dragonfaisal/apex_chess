import 'dart:io' as io;

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_before_after_raw_eval_probe.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

const analyzerBeforeAfterRawEvalReportExitSuccess = 0;
const analyzerBeforeAfterRawEvalReportExitUsage = 64;
const analyzerBeforeAfterRawEvalReportExitBlockedStrict = 68;

enum AnalyzerBeforeAfterRawEvalReportFormat {
  markdown('markdown'),
  json('json');

  const AnalyzerBeforeAfterRawEvalReportFormat(this.wire);

  final String wire;
}

class AnalyzerBeforeAfterRawEvalCommandRequest {
  const AnalyzerBeforeAfterRawEvalCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.timeout,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const AnalyzerBeforeAfterRawEvalCommandRequest.invalid(this.failure)
    : isValid = false,
      format = AnalyzerBeforeAfterRawEvalReportFormat.markdown,
      strict = false,
      timeout = defaultLocalSearchEvalProbeTimeout,
      showHelp = false;

  final bool isValid;
  final String failure;
  final AnalyzerBeforeAfterRawEvalReportFormat format;
  final bool strict;
  final Duration timeout;
  final bool showHelp;
}

class AnalyzerBeforeAfterRawEvalCommandResult {
  const AnalyzerBeforeAfterRawEvalCommandResult({
    required this.exitCode,
    required this.stdoutText,
    required this.stderrText,
    this.result,
  });

  final int exitCode;
  final String stdoutText;
  final String stderrText;
  final AnalyzerBeforeAfterRawEvalResult? result;
}

Future<void> main(List<String> args) async {
  final result = await runAnalyzerBeforeAfterRawEvalCommand(args: args);
  if (result.stdoutText.isNotEmpty) io.stdout.write(result.stdoutText);
  if (result.stderrText.isNotEmpty) io.stderr.write(result.stderrText);
  io.exitCode = result.exitCode;
}

Future<AnalyzerBeforeAfterRawEvalCommandResult>
runAnalyzerBeforeAfterRawEvalCommand({
  required List<String> args,
  LocalAnalyzerBeforeAfterRawEvalProbe? probe,
}) async {
  final request = validateAnalyzerBeforeAfterRawEvalArgs(args);
  if (!request.isValid) {
    return AnalyzerBeforeAfterRawEvalCommandResult(
      exitCode: analyzerBeforeAfterRawEvalReportExitUsage,
      stdoutText: '',
      stderrText: _usage(request.failure),
    );
  }
  if (request.showHelp) {
    return AnalyzerBeforeAfterRawEvalCommandResult(
      exitCode: analyzerBeforeAfterRawEvalReportExitSuccess,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = await (probe ?? LocalAnalyzerBeforeAfterRawEvalProbe()).run(
    const AnalyzerBeforeAfterRawEvalRequest.controlled(),
    timeout: request.timeout,
  );
  final stdoutText = switch (request.format) {
    AnalyzerBeforeAfterRawEvalReportFormat.markdown => result.renderMarkdown(),
    AnalyzerBeforeAfterRawEvalReportFormat.json => '${result.renderJson()}\n',
  };
  final blocked = request.strict && !result.safeForPhase35I;

  return AnalyzerBeforeAfterRawEvalCommandResult(
    exitCode: blocked
        ? analyzerBeforeAfterRawEvalReportExitBlockedStrict
        : analyzerBeforeAfterRawEvalReportExitSuccess,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

AnalyzerBeforeAfterRawEvalCommandRequest validateAnalyzerBeforeAfterRawEvalArgs(
  List<String> args,
) {
  var format = AnalyzerBeforeAfterRawEvalReportFormat.markdown;
  var strict = false;
  var timeout = defaultLocalSearchEvalProbeTimeout;
  var formatSeen = false;
  var timeoutSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const AnalyzerBeforeAfterRawEvalCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return AnalyzerBeforeAfterRawEvalCommandRequest.valid(
        format: AnalyzerBeforeAfterRawEvalReportFormat.markdown,
        strict: false,
        timeout: timeout,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const AnalyzerBeforeAfterRawEvalCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const AnalyzerBeforeAfterRawEvalCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_timeoutFlag)) {
      if (timeoutSeen) {
        return const AnalyzerBeforeAfterRawEvalCommandRequest.invalid(
          'duplicateTimeout',
        );
      }
      final parsed = int.tryParse(arg.substring(_timeoutFlag.length).trim());
      if (parsed == null || parsed <= 0 || parsed > 30000) {
        return const AnalyzerBeforeAfterRawEvalCommandRequest.invalid(
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
    return const AnalyzerBeforeAfterRawEvalCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return AnalyzerBeforeAfterRawEvalCommandRequest.valid(
    format: format,
    strict: strict,
    timeout: timeout,
  );
}

AnalyzerBeforeAfterRawEvalReportFormat? _formatByWire(String value) {
  for (final format in AnalyzerBeforeAfterRawEvalReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Apex analyzer before/after raw eval probe usage: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/analyzer_before_after_raw_eval_probe_report.dart',
    )
    ..writeln(
      '  dart run tool/analyzer_before_after_raw_eval_probe_report.dart --format=markdown --strict',
    )
    ..writeln(
      '  dart run tool/analyzer_before_after_raw_eval_probe_report.dart --format=json --strict',
    )
    ..writeln(
      '  dart run tool/analyzer_before_after_raw_eval_probe_report.dart --timeout-ms=5000',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln('  --timeout-ms=<1..30000>')
    ..writeln()
    ..writeln('Safety:')
    ..writeln('  Phase 35H uses one controlled before FEN, one controlled')
    ..writeln('  after FEN, playedMoveUci=e2e4 for traceability, and depth 1.')
    ..writeln(
      '  It returns raw normalized before/after analyzer evidence only.',
    )
    ..writeln('  It does not compute delta, CP-loss, Win%, accuracy, ACPL,')
    ..writeln('  classifier labels, saved analysis, scheduler execution,')
    ..writeln('  product UI, or backend work.');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _timeoutFlag = '--timeout-ms=';
const _strictFlag = '--strict';

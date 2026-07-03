import 'dart:io' as io;

import 'package:apex_chess/features/analysis/domain/analyzer_raw_eval_result.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_single_fen_raw_eval.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_single_fen_raw_eval_adapter.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

const analyzerSingleFenRawEvalReportExitSuccess = 0;
const analyzerSingleFenRawEvalReportExitUsage = 64;
const analyzerSingleFenRawEvalReportExitBlockedStrict = 68;

enum AnalyzerSingleFenRawEvalReportFormat {
  markdown('markdown'),
  json('json');

  const AnalyzerSingleFenRawEvalReportFormat(this.wire);

  final String wire;
}

class AnalyzerSingleFenRawEvalCommandRequest {
  const AnalyzerSingleFenRawEvalCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.timeout,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const AnalyzerSingleFenRawEvalCommandRequest.invalid(this.failure)
    : isValid = false,
      format = AnalyzerSingleFenRawEvalReportFormat.markdown,
      strict = false,
      timeout = defaultLocalSearchEvalProbeTimeout,
      showHelp = false;

  final bool isValid;
  final String failure;
  final AnalyzerSingleFenRawEvalReportFormat format;
  final bool strict;
  final Duration timeout;
  final bool showHelp;
}

class AnalyzerSingleFenRawEvalCommandResult {
  const AnalyzerSingleFenRawEvalCommandResult({
    required this.exitCode,
    required this.stdoutText,
    required this.stderrText,
    this.result,
  });

  final int exitCode;
  final String stdoutText;
  final String stderrText;
  final AnalyzerRawEvalResult? result;
}

Future<void> main(List<String> args) async {
  final result = await runAnalyzerSingleFenRawEvalCommand(args: args);
  if (result.stdoutText.isNotEmpty) io.stdout.write(result.stdoutText);
  if (result.stderrText.isNotEmpty) io.stderr.write(result.stderrText);
  io.exitCode = result.exitCode;
}

Future<AnalyzerSingleFenRawEvalCommandResult>
runAnalyzerSingleFenRawEvalCommand({
  required List<String> args,
  LocalAnalyzerSingleFenRawEvalAdapter? adapter,
}) async {
  final request = validateAnalyzerSingleFenRawEvalArgs(args);
  if (!request.isValid) {
    return AnalyzerSingleFenRawEvalCommandResult(
      exitCode: analyzerSingleFenRawEvalReportExitUsage,
      stdoutText: '',
      stderrText: _usage(request.failure),
    );
  }
  if (request.showHelp) {
    return AnalyzerSingleFenRawEvalCommandResult(
      exitCode: analyzerSingleFenRawEvalReportExitSuccess,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = await (adapter ?? LocalAnalyzerSingleFenRawEvalAdapter())
      .evaluate(
        const AnalyzerSingleFenRawEvalRequest.controlled(),
        timeout: request.timeout,
      );
  final stdoutText = switch (request.format) {
    AnalyzerSingleFenRawEvalReportFormat.markdown => result.renderMarkdown(),
    AnalyzerSingleFenRawEvalReportFormat.json => '${result.renderJson()}\n',
  };
  final blocked = request.strict && !result.safeForPhase35H;

  return AnalyzerSingleFenRawEvalCommandResult(
    exitCode: blocked
        ? analyzerSingleFenRawEvalReportExitBlockedStrict
        : analyzerSingleFenRawEvalReportExitSuccess,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

AnalyzerSingleFenRawEvalCommandRequest validateAnalyzerSingleFenRawEvalArgs(
  List<String> args,
) {
  var format = AnalyzerSingleFenRawEvalReportFormat.markdown;
  var strict = false;
  var timeout = defaultLocalSearchEvalProbeTimeout;
  var formatSeen = false;
  var timeoutSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const AnalyzerSingleFenRawEvalCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return AnalyzerSingleFenRawEvalCommandRequest.valid(
        format: AnalyzerSingleFenRawEvalReportFormat.markdown,
        strict: false,
        timeout: timeout,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const AnalyzerSingleFenRawEvalCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const AnalyzerSingleFenRawEvalCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_timeoutFlag)) {
      if (timeoutSeen) {
        return const AnalyzerSingleFenRawEvalCommandRequest.invalid(
          'duplicateTimeout',
        );
      }
      final parsed = int.tryParse(arg.substring(_timeoutFlag.length).trim());
      if (parsed == null || parsed <= 0 || parsed > 30000) {
        return const AnalyzerSingleFenRawEvalCommandRequest.invalid(
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
    return const AnalyzerSingleFenRawEvalCommandRequest.invalid('unknownFlag');
  }

  return AnalyzerSingleFenRawEvalCommandRequest.valid(
    format: format,
    strict: strict,
    timeout: timeout,
  );
}

AnalyzerSingleFenRawEvalReportFormat? _formatByWire(String value) {
  for (final format in AnalyzerSingleFenRawEvalReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Apex analyzer single-FEN raw eval adapter usage: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/analyzer_single_fen_raw_eval_adapter_report.dart',
    )
    ..writeln(
      '  dart run tool/analyzer_single_fen_raw_eval_adapter_report.dart --format=markdown --strict',
    )
    ..writeln(
      '  dart run tool/analyzer_single_fen_raw_eval_adapter_report.dart --format=json --strict',
    )
    ..writeln(
      '  dart run tool/analyzer_single_fen_raw_eval_adapter_report.dart --timeout-ms=5000',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln('  --timeout-ms=<1..30000>')
    ..writeln()
    ..writeln('Safety:')
    ..writeln('  Phase 35G requests one controlled FEN at depth 1 and returns')
    ..writeln('  raw normalized analyzer-facing fields only. It does not')
    ..writeln('  analyze PGNs, compare moves, classify, persist, schedule,')
    ..writeln('  or connect to product UI/backend surfaces.');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _timeoutFlag = '--timeout-ms=';
const _strictFlag = '--strict';

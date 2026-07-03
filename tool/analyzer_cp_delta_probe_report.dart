import 'dart:io' as io;

import 'package:apex_chess/features/analysis/domain/analyzer_cp_delta.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_cp_delta_probe.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

const analyzerCpDeltaReportExitSuccess = 0;
const analyzerCpDeltaReportExitUsage = 64;
const analyzerCpDeltaReportExitBlockedStrict = 68;

enum AnalyzerCpDeltaReportFormat {
  markdown('markdown'),
  json('json');

  const AnalyzerCpDeltaReportFormat(this.wire);

  final String wire;
}

class AnalyzerCpDeltaCommandRequest {
  const AnalyzerCpDeltaCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.timeout,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const AnalyzerCpDeltaCommandRequest.invalid(this.failure)
    : isValid = false,
      format = AnalyzerCpDeltaReportFormat.markdown,
      strict = false,
      timeout = defaultLocalSearchEvalProbeTimeout,
      showHelp = false;

  final bool isValid;
  final String failure;
  final AnalyzerCpDeltaReportFormat format;
  final bool strict;
  final Duration timeout;
  final bool showHelp;
}

class AnalyzerCpDeltaCommandResult {
  const AnalyzerCpDeltaCommandResult({
    required this.exitCode,
    required this.stdoutText,
    required this.stderrText,
    this.result,
  });

  final int exitCode;
  final String stdoutText;
  final String stderrText;
  final AnalyzerCpDeltaResult? result;
}

Future<void> main(List<String> args) async {
  final result = await runAnalyzerCpDeltaCommand(args: args);
  if (result.stdoutText.isNotEmpty) io.stdout.write(result.stdoutText);
  if (result.stderrText.isNotEmpty) io.stderr.write(result.stderrText);
  io.exitCode = result.exitCode;
}

Future<AnalyzerCpDeltaCommandResult> runAnalyzerCpDeltaCommand({
  required List<String> args,
  LocalAnalyzerCpDeltaProbe? probe,
}) async {
  final request = validateAnalyzerCpDeltaArgs(args);
  if (!request.isValid) {
    return AnalyzerCpDeltaCommandResult(
      exitCode: analyzerCpDeltaReportExitUsage,
      stdoutText: '',
      stderrText: _usage(request.failure),
    );
  }
  if (request.showHelp) {
    return AnalyzerCpDeltaCommandResult(
      exitCode: analyzerCpDeltaReportExitSuccess,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = await (probe ?? LocalAnalyzerCpDeltaProbe()).run(
    const AnalyzerCpDeltaRequest.controlled(),
    timeout: request.timeout,
  );
  final stdoutText = switch (request.format) {
    AnalyzerCpDeltaReportFormat.markdown => result.renderMarkdown(),
    AnalyzerCpDeltaReportFormat.json => '${result.renderJson()}\n',
  };
  final blocked = request.strict && !result.safeForPhase35J;

  return AnalyzerCpDeltaCommandResult(
    exitCode: blocked
        ? analyzerCpDeltaReportExitBlockedStrict
        : analyzerCpDeltaReportExitSuccess,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

AnalyzerCpDeltaCommandRequest validateAnalyzerCpDeltaArgs(List<String> args) {
  var format = AnalyzerCpDeltaReportFormat.markdown;
  var strict = false;
  var timeout = defaultLocalSearchEvalProbeTimeout;
  var formatSeen = false;
  var timeoutSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const AnalyzerCpDeltaCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return AnalyzerCpDeltaCommandRequest.valid(
        format: AnalyzerCpDeltaReportFormat.markdown,
        strict: false,
        timeout: timeout,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const AnalyzerCpDeltaCommandRequest.invalid('duplicateFormat');
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const AnalyzerCpDeltaCommandRequest.invalid('unknownFormat');
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_timeoutFlag)) {
      if (timeoutSeen) {
        return const AnalyzerCpDeltaCommandRequest.invalid('duplicateTimeout');
      }
      final parsed = int.tryParse(arg.substring(_timeoutFlag.length).trim());
      if (parsed == null || parsed <= 0 || parsed > 30000) {
        return const AnalyzerCpDeltaCommandRequest.invalid('invalidTimeout');
      }
      timeout = Duration(milliseconds: parsed);
      timeoutSeen = true;
      continue;
    }
    if (arg == _strictFlag) {
      strict = true;
      continue;
    }
    return const AnalyzerCpDeltaCommandRequest.invalid('unknownFlag');
  }

  return AnalyzerCpDeltaCommandRequest.valid(
    format: format,
    strict: strict,
    timeout: timeout,
  );
}

AnalyzerCpDeltaReportFormat? _formatByWire(String value) {
  for (final format in AnalyzerCpDeltaReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Apex analyzer CP delta probe usage: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/analyzer_cp_delta_probe_report.dart')
    ..writeln(
      '  dart run tool/analyzer_cp_delta_probe_report.dart --format=markdown --strict',
    )
    ..writeln(
      '  dart run tool/analyzer_cp_delta_probe_report.dart --format=json --strict',
    )
    ..writeln(
      '  dart run tool/analyzer_cp_delta_probe_report.dart --timeout-ms=5000',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln('  --timeout-ms=<1..30000>')
    ..writeln()
    ..writeln('Safety:')
    ..writeln('  Phase 35I uses the controlled Phase 35H before/after result')
    ..writeln('  and computes only mover-perspective CP delta. It does not')
    ..writeln('  compute CP-loss, Win%, accuracy, ACPL, move quality,')
    ..writeln('  classifier labels, saved analysis, scheduler execution,')
    ..writeln('  product UI, or backend work.');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _timeoutFlag = '--timeout-ms=';
const _strictFlag = '--strict';

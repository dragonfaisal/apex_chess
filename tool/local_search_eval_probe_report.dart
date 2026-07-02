import 'dart:io' as io;

import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart';

const localSearchEvalProbeExitSuccess = 0;
const localSearchEvalProbeExitUsage = 64;
const localSearchEvalProbeExitBlockedStrict = 68;

enum LocalSearchEvalProbeReportFormat {
  markdown('markdown'),
  json('json');

  const LocalSearchEvalProbeReportFormat(this.wire);

  final String wire;
}

class LocalSearchEvalProbeCommandRequest {
  const LocalSearchEvalProbeCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.timeout,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const LocalSearchEvalProbeCommandRequest.invalid(this.failure)
    : isValid = false,
      format = LocalSearchEvalProbeReportFormat.markdown,
      strict = false,
      timeout = defaultLocalSearchEvalProbeTimeout,
      showHelp = false;

  final bool isValid;
  final String failure;
  final LocalSearchEvalProbeReportFormat format;
  final bool strict;
  final Duration timeout;
  final bool showHelp;
}

class LocalSearchEvalProbeCommandResult {
  const LocalSearchEvalProbeCommandResult({
    required this.exitCode,
    required this.stdoutText,
    required this.stderrText,
    this.result,
  });

  final int exitCode;
  final String stdoutText;
  final String stderrText;
  final LocalSearchEvalProbeResult? result;
}

Future<void> main(List<String> args) async {
  final result = await runLocalSearchEvalProbeCommand(args: args);
  if (result.stdoutText.isNotEmpty) io.stdout.write(result.stdoutText);
  if (result.stderrText.isNotEmpty) io.stderr.write(result.stderrText);
  io.exitCode = result.exitCode;
}

Future<LocalSearchEvalProbeCommandResult> runLocalSearchEvalProbeCommand({
  required List<String> args,
  LocalSearchEvalProbe? probe,
}) async {
  final request = validateLocalSearchEvalProbeArgs(args);
  if (!request.isValid) {
    return LocalSearchEvalProbeCommandResult(
      exitCode: localSearchEvalProbeExitUsage,
      stdoutText: '',
      stderrText: _usage(request.failure),
    );
  }
  if (request.showHelp) {
    return LocalSearchEvalProbeCommandResult(
      exitCode: localSearchEvalProbeExitSuccess,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = await (probe ?? LocalSearchEvalProbe()).run(
    timeout: request.timeout,
  );
  final stdoutText = switch (request.format) {
    LocalSearchEvalProbeReportFormat.markdown => result.renderMarkdown(),
    LocalSearchEvalProbeReportFormat.json => '${result.renderJson()}\n',
  };
  final blocked = request.strict && !result.safeForPhase35E;

  return LocalSearchEvalProbeCommandResult(
    exitCode: blocked
        ? localSearchEvalProbeExitBlockedStrict
        : localSearchEvalProbeExitSuccess,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

LocalSearchEvalProbeCommandRequest validateLocalSearchEvalProbeArgs(
  List<String> args,
) {
  var format = LocalSearchEvalProbeReportFormat.markdown;
  var strict = false;
  var timeout = defaultLocalSearchEvalProbeTimeout;
  var formatSeen = false;
  var timeoutSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const LocalSearchEvalProbeCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return LocalSearchEvalProbeCommandRequest.valid(
        format: LocalSearchEvalProbeReportFormat.markdown,
        strict: false,
        timeout: timeout,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const LocalSearchEvalProbeCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const LocalSearchEvalProbeCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_timeoutFlag)) {
      if (timeoutSeen) {
        return const LocalSearchEvalProbeCommandRequest.invalid(
          'duplicateTimeout',
        );
      }
      final parsed = int.tryParse(arg.substring(_timeoutFlag.length).trim());
      if (parsed == null || parsed <= 0 || parsed > 30000) {
        return const LocalSearchEvalProbeCommandRequest.invalid(
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
    return const LocalSearchEvalProbeCommandRequest.invalid('unknownFlag');
  }

  return LocalSearchEvalProbeCommandRequest.valid(
    format: format,
    strict: strict,
    timeout: timeout,
  );
}

LocalSearchEvalProbeReportFormat? _formatByWire(String value) {
  for (final format in LocalSearchEvalProbeReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Apex local search eval probe usage: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/local_search_eval_probe_report.dart')
    ..writeln(
      '  dart run tool/local_search_eval_probe_report.dart --format=markdown --strict',
    )
    ..writeln(
      '  dart run tool/local_search_eval_probe_report.dart --format=json --strict',
    )
    ..writeln(
      '  dart run tool/local_search_eval_probe_report.dart --timeout-ms=5000',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln('  --timeout-ms=<1..30000>')
    ..writeln()
    ..writeln('Safety:')
    ..writeln('  This command sends only the controlled Phase 35D sequence:')
    ..writeln('  uci, isready, ucinewgame, controlled FEN position command,')
    ..writeln('  isready, go depth 1. It does not use PGN/imported games,')
    ..writeln('  MultiPV, Win%, CP-loss, classifier labels, saved analysis,')
    ..writeln('  scheduler execution, product UI, or backend integration.');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _timeoutFlag = '--timeout-ms=';
const _strictFlag = '--strict';

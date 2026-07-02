import 'dart:io' as io;

import 'package:apex_chess/infrastructure/engine/local_fen_position_input_probe.dart';

const localFenPositionInputProbeExitSuccess = 0;
const localFenPositionInputProbeExitUsage = 64;
const localFenPositionInputProbeExitBlockedStrict = 68;

enum LocalFenPositionInputProbeReportFormat {
  markdown('markdown'),
  json('json');

  const LocalFenPositionInputProbeReportFormat(this.wire);

  final String wire;
}

class LocalFenPositionInputProbeCommandRequest {
  const LocalFenPositionInputProbeCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.timeout,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const LocalFenPositionInputProbeCommandRequest.invalid(this.failure)
    : isValid = false,
      format = LocalFenPositionInputProbeReportFormat.markdown,
      strict = false,
      timeout = defaultLocalFenPositionInputProbeTimeout,
      showHelp = false;

  final bool isValid;
  final String failure;
  final LocalFenPositionInputProbeReportFormat format;
  final bool strict;
  final Duration timeout;
  final bool showHelp;
}

class LocalFenPositionInputProbeCommandResult {
  const LocalFenPositionInputProbeCommandResult({
    required this.exitCode,
    required this.stdoutText,
    required this.stderrText,
    this.result,
  });

  final int exitCode;
  final String stdoutText;
  final String stderrText;
  final LocalFenPositionInputProbeResult? result;
}

Future<void> main(List<String> args) async {
  final result = await runLocalFenPositionInputProbeCommand(args: args);
  if (result.stdoutText.isNotEmpty) io.stdout.write(result.stdoutText);
  if (result.stderrText.isNotEmpty) io.stderr.write(result.stderrText);
  io.exitCode = result.exitCode;
}

Future<LocalFenPositionInputProbeCommandResult>
runLocalFenPositionInputProbeCommand({
  required List<String> args,
  LocalFenPositionInputProbe? probe,
}) async {
  final request = validateLocalFenPositionInputProbeArgs(args);
  if (!request.isValid) {
    return LocalFenPositionInputProbeCommandResult(
      exitCode: localFenPositionInputProbeExitUsage,
      stdoutText: '',
      stderrText: _usage(request.failure),
    );
  }
  if (request.showHelp) {
    return LocalFenPositionInputProbeCommandResult(
      exitCode: localFenPositionInputProbeExitSuccess,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = await (probe ?? LocalFenPositionInputProbe()).run(
    timeout: request.timeout,
  );
  final stdoutText = switch (request.format) {
    LocalFenPositionInputProbeReportFormat.markdown => result.renderMarkdown(),
    LocalFenPositionInputProbeReportFormat.json => '${result.renderJson()}\n',
  };
  final blocked = request.strict && !result.safeForPhase35D;

  return LocalFenPositionInputProbeCommandResult(
    exitCode: blocked
        ? localFenPositionInputProbeExitBlockedStrict
        : localFenPositionInputProbeExitSuccess,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

LocalFenPositionInputProbeCommandRequest validateLocalFenPositionInputProbeArgs(
  List<String> args,
) {
  var format = LocalFenPositionInputProbeReportFormat.markdown;
  var strict = false;
  var timeout = defaultLocalFenPositionInputProbeTimeout;
  var formatSeen = false;
  var timeoutSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const LocalFenPositionInputProbeCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return LocalFenPositionInputProbeCommandRequest.valid(
        format: LocalFenPositionInputProbeReportFormat.markdown,
        strict: false,
        timeout: timeout,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const LocalFenPositionInputProbeCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const LocalFenPositionInputProbeCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_timeoutFlag)) {
      if (timeoutSeen) {
        return const LocalFenPositionInputProbeCommandRequest.invalid(
          'duplicateTimeout',
        );
      }
      final parsed = int.tryParse(arg.substring(_timeoutFlag.length).trim());
      if (parsed == null || parsed <= 0 || parsed > 30000) {
        return const LocalFenPositionInputProbeCommandRequest.invalid(
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
    return const LocalFenPositionInputProbeCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return LocalFenPositionInputProbeCommandRequest.valid(
    format: format,
    strict: strict,
    timeout: timeout,
  );
}

LocalFenPositionInputProbeReportFormat? _formatByWire(String value) {
  for (final format in LocalFenPositionInputProbeReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Apex controlled FEN position input probe usage: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/local_fen_position_input_probe_report.dart')
    ..writeln(
      '  dart run tool/local_fen_position_input_probe_report.dart --format=markdown --strict',
    )
    ..writeln(
      '  dart run tool/local_fen_position_input_probe_report.dart --format=json --strict',
    )
    ..writeln(
      '  dart run tool/local_fen_position_input_probe_report.dart --timeout-ms=5000',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln('  --timeout-ms=<1..30000>')
    ..writeln()
    ..writeln('Safety:')
    ..writeln('  This command sends only the controlled Phase 35C sequence:')
    ..writeln('  uci, isready, ucinewgame, controlled FEN position command,')
    ..writeln('  isready. It does not send go/search/evaluation commands and')
    ..writeln('  does not parse scores, mate lines, best moves, or MultiPV.');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _timeoutFlag = '--timeout-ms=';
const _strictFlag = '--strict';

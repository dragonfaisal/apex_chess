import 'dart:io' as io;

import 'package:apex_chess/infrastructure/engine/local_uci_handshake_probe.dart';

const localUciHandshakeProbeExitSuccess = 0;
const localUciHandshakeProbeExitUsage = 64;
const localUciHandshakeProbeExitBlockedStrict = 68;

enum LocalUciHandshakeProbeReportFormat {
  markdown('markdown'),
  json('json');

  const LocalUciHandshakeProbeReportFormat(this.wire);

  final String wire;
}

class LocalUciHandshakeProbeCommandRequest {
  const LocalUciHandshakeProbeCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.timeout,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const LocalUciHandshakeProbeCommandRequest.invalid(this.failure)
    : isValid = false,
      format = LocalUciHandshakeProbeReportFormat.markdown,
      strict = false,
      timeout = defaultLocalUciHandshakeProbeTimeout,
      showHelp = false;

  final bool isValid;
  final String failure;
  final LocalUciHandshakeProbeReportFormat format;
  final bool strict;
  final Duration timeout;
  final bool showHelp;
}

class LocalUciHandshakeProbeCommandResult {
  const LocalUciHandshakeProbeCommandResult({
    required this.exitCode,
    required this.stdoutText,
    required this.stderrText,
    this.result,
  });

  final int exitCode;
  final String stdoutText;
  final String stderrText;
  final LocalUciHandshakeProbeResult? result;
}

Future<void> main(List<String> args) async {
  final result = await runLocalUciHandshakeProbeCommand(args: args);
  if (result.stdoutText.isNotEmpty) io.stdout.write(result.stdoutText);
  if (result.stderrText.isNotEmpty) io.stderr.write(result.stderrText);
  io.exitCode = result.exitCode;
}

Future<LocalUciHandshakeProbeCommandResult> runLocalUciHandshakeProbeCommand({
  required List<String> args,
  LocalUciHandshakeProbe? probe,
}) async {
  final request = validateLocalUciHandshakeProbeArgs(args);
  if (!request.isValid) {
    return LocalUciHandshakeProbeCommandResult(
      exitCode: localUciHandshakeProbeExitUsage,
      stdoutText: '',
      stderrText: _usage(request.failure),
    );
  }
  if (request.showHelp) {
    return LocalUciHandshakeProbeCommandResult(
      exitCode: localUciHandshakeProbeExitSuccess,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = await (probe ?? LocalUciHandshakeProbe()).run(
    timeout: request.timeout,
  );
  final stdoutText = switch (request.format) {
    LocalUciHandshakeProbeReportFormat.markdown => result.renderMarkdown(),
    LocalUciHandshakeProbeReportFormat.json => '${result.renderJson()}\n',
  };
  final blocked = request.strict && !result.safeForPhase35C;

  return LocalUciHandshakeProbeCommandResult(
    exitCode: blocked
        ? localUciHandshakeProbeExitBlockedStrict
        : localUciHandshakeProbeExitSuccess,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

LocalUciHandshakeProbeCommandRequest validateLocalUciHandshakeProbeArgs(
  List<String> args,
) {
  var format = LocalUciHandshakeProbeReportFormat.markdown;
  var strict = false;
  var timeout = defaultLocalUciHandshakeProbeTimeout;
  var formatSeen = false;
  var timeoutSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const LocalUciHandshakeProbeCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return LocalUciHandshakeProbeCommandRequest.valid(
        format: LocalUciHandshakeProbeReportFormat.markdown,
        strict: false,
        timeout: timeout,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const LocalUciHandshakeProbeCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const LocalUciHandshakeProbeCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_timeoutFlag)) {
      if (timeoutSeen) {
        return const LocalUciHandshakeProbeCommandRequest.invalid(
          'duplicateTimeout',
        );
      }
      final parsed = int.tryParse(arg.substring(_timeoutFlag.length).trim());
      if (parsed == null || parsed <= 0 || parsed > 30000) {
        return const LocalUciHandshakeProbeCommandRequest.invalid(
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
    return const LocalUciHandshakeProbeCommandRequest.invalid('unknownFlag');
  }

  return LocalUciHandshakeProbeCommandRequest.valid(
    format: format,
    strict: strict,
    timeout: timeout,
  );
}

LocalUciHandshakeProbeReportFormat? _formatByWire(String value) {
  for (final format in LocalUciHandshakeProbeReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Apex local UCI handshake probe usage: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/local_uci_handshake_probe_report.dart')
    ..writeln(
      '  dart run tool/local_uci_handshake_probe_report.dart --format=markdown --strict',
    )
    ..writeln(
      '  dart run tool/local_uci_handshake_probe_report.dart --format=json --strict',
    )
    ..writeln(
      '  dart run tool/local_uci_handshake_probe_report.dart --timeout-ms=2500',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln('  --timeout-ms=<1..30000>')
    ..writeln()
    ..writeln('Safety:')
    ..writeln('  This command sends only uci and isready through the existing')
    ..writeln('  local engine boundary. It does not send FEN, PGN, position,')
    ..writeln('  go, or analysis commands.');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _timeoutFlag = '--timeout-ms=';
const _strictFlag = '--strict';

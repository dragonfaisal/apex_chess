import 'dart:io' as io;

import 'package:apex_chess/infrastructure/engine/local_raw_eval_perspective.dart';
import 'package:apex_chess/infrastructure/engine/local_raw_eval_perspective_normalizer.dart';

const localRawEvalPerspectiveNormalizationExitSuccess = 0;
const localRawEvalPerspectiveNormalizationExitUsage = 64;
const localRawEvalPerspectiveNormalizationExitBlockedStrict = 68;

enum LocalRawEvalPerspectiveNormalizationReportFormat {
  markdown('markdown'),
  json('json');

  const LocalRawEvalPerspectiveNormalizationReportFormat(this.wire);

  final String wire;
}

class LocalRawEvalPerspectiveNormalizationCommandRequest {
  const LocalRawEvalPerspectiveNormalizationCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.timeout,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const LocalRawEvalPerspectiveNormalizationCommandRequest.invalid(this.failure)
    : isValid = false,
      format = LocalRawEvalPerspectiveNormalizationReportFormat.markdown,
      strict = false,
      timeout = defaultLocalRawEvalPerspectiveNormalizationTimeout,
      showHelp = false;

  final bool isValid;
  final String failure;
  final LocalRawEvalPerspectiveNormalizationReportFormat format;
  final bool strict;
  final Duration timeout;
  final bool showHelp;
}

class LocalRawEvalPerspectiveNormalizationCommandResult {
  const LocalRawEvalPerspectiveNormalizationCommandResult({
    required this.exitCode,
    required this.stdoutText,
    required this.stderrText,
    this.result,
  });

  final int exitCode;
  final String stdoutText;
  final String stderrText;
  final LocalRawEvalPerspective? result;
}

Future<void> main(List<String> args) async {
  final result = await runLocalRawEvalPerspectiveNormalizationCommand(
    args: args,
  );
  if (result.stdoutText.isNotEmpty) io.stdout.write(result.stdoutText);
  if (result.stderrText.isNotEmpty) io.stderr.write(result.stderrText);
  io.exitCode = result.exitCode;
}

Future<LocalRawEvalPerspectiveNormalizationCommandResult>
runLocalRawEvalPerspectiveNormalizationCommand({
  required List<String> args,
  LocalRawEvalPerspectiveNormalizationProbe? probe,
}) async {
  final request = validateLocalRawEvalPerspectiveNormalizationArgs(args);
  if (!request.isValid) {
    return LocalRawEvalPerspectiveNormalizationCommandResult(
      exitCode: localRawEvalPerspectiveNormalizationExitUsage,
      stdoutText: '',
      stderrText: _usage(request.failure),
    );
  }
  if (request.showHelp) {
    return LocalRawEvalPerspectiveNormalizationCommandResult(
      exitCode: localRawEvalPerspectiveNormalizationExitSuccess,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = await (probe ?? LocalRawEvalPerspectiveNormalizationProbe())
      .run(timeout: request.timeout);
  final stdoutText = switch (request.format) {
    LocalRawEvalPerspectiveNormalizationReportFormat.markdown =>
      result.renderMarkdown(),
    LocalRawEvalPerspectiveNormalizationReportFormat.json =>
      '${result.renderJson()}\n',
  };
  final blocked = request.strict && !result.safeForPhase35G;

  return LocalRawEvalPerspectiveNormalizationCommandResult(
    exitCode: blocked
        ? localRawEvalPerspectiveNormalizationExitBlockedStrict
        : localRawEvalPerspectiveNormalizationExitSuccess,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

LocalRawEvalPerspectiveNormalizationCommandRequest
validateLocalRawEvalPerspectiveNormalizationArgs(List<String> args) {
  var format = LocalRawEvalPerspectiveNormalizationReportFormat.markdown;
  var strict = false;
  var timeout = defaultLocalRawEvalPerspectiveNormalizationTimeout;
  var formatSeen = false;
  var timeoutSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const LocalRawEvalPerspectiveNormalizationCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return LocalRawEvalPerspectiveNormalizationCommandRequest.valid(
        format: LocalRawEvalPerspectiveNormalizationReportFormat.markdown,
        strict: false,
        timeout: timeout,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const LocalRawEvalPerspectiveNormalizationCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const LocalRawEvalPerspectiveNormalizationCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_timeoutFlag)) {
      if (timeoutSeen) {
        return const LocalRawEvalPerspectiveNormalizationCommandRequest.invalid(
          'duplicateTimeout',
        );
      }
      final parsed = int.tryParse(arg.substring(_timeoutFlag.length).trim());
      if (parsed == null || parsed <= 0 || parsed > 30000) {
        return const LocalRawEvalPerspectiveNormalizationCommandRequest.invalid(
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
    return const LocalRawEvalPerspectiveNormalizationCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return LocalRawEvalPerspectiveNormalizationCommandRequest.valid(
    format: format,
    strict: strict,
    timeout: timeout,
  );
}

LocalRawEvalPerspectiveNormalizationReportFormat? _formatByWire(String value) {
  for (final format
      in LocalRawEvalPerspectiveNormalizationReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Apex raw eval perspective normalization usage: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/local_raw_eval_perspective_normalization_report.dart',
    )
    ..writeln(
      '  dart run tool/local_raw_eval_perspective_normalization_report.dart --format=markdown --strict',
    )
    ..writeln(
      '  dart run tool/local_raw_eval_perspective_normalization_report.dart --format=json --strict',
    )
    ..writeln(
      '  dart run tool/local_raw_eval_perspective_normalization_report.dart --timeout-ms=5000',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln('  --timeout-ms=<1..30000>')
    ..writeln()
    ..writeln('Safety:')
    ..writeln('  Phase 35F treats raw UCI score as side-to-move perspective')
    ..writeln('  and emits explicit White/Black perspective fields only.')
    ..writeln('  It does not compute Win%, CP-loss, accuracy, classifier')
    ..writeln('  labels, analyzer runtime output, product UI, or persistence.');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _timeoutFlag = '--timeout-ms=';
const _strictFlag = '--strict';

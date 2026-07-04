import 'dart:io' as io;

import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_private_draft_classifier_probe.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

const analyzerPrivateDraftClassifierReportExitSuccess = 0;
const analyzerPrivateDraftClassifierReportExitUsage = 64;
const analyzerPrivateDraftClassifierReportExitBlockedStrict = 68;

enum AnalyzerPrivateDraftClassifierReportFormat {
  markdown('markdown'),
  json('json');

  const AnalyzerPrivateDraftClassifierReportFormat(this.wire);

  final String wire;
}

class AnalyzerPrivateDraftClassifierCommandRequest {
  const AnalyzerPrivateDraftClassifierCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.timeout,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const AnalyzerPrivateDraftClassifierCommandRequest.invalid(this.failure)
    : isValid = false,
      format = AnalyzerPrivateDraftClassifierReportFormat.markdown,
      strict = false,
      timeout = defaultLocalSearchEvalProbeTimeout,
      showHelp = false;

  final bool isValid;
  final String failure;
  final AnalyzerPrivateDraftClassifierReportFormat format;
  final bool strict;
  final Duration timeout;
  final bool showHelp;
}

class AnalyzerPrivateDraftClassifierCommandResult {
  const AnalyzerPrivateDraftClassifierCommandResult({
    required this.exitCode,
    required this.stdoutText,
    required this.stderrText,
    this.result,
  });

  final int exitCode;
  final String stdoutText;
  final String stderrText;
  final AnalyzerPrivateDraftClassifierResult? result;
}

Future<void> main(List<String> args) async {
  final result = await runAnalyzerPrivateDraftClassifierCommand(args: args);
  if (result.stdoutText.isNotEmpty) io.stdout.write(result.stdoutText);
  if (result.stderrText.isNotEmpty) io.stderr.write(result.stderrText);
  io.exitCode = result.exitCode;
}

Future<AnalyzerPrivateDraftClassifierCommandResult>
runAnalyzerPrivateDraftClassifierCommand({
  required List<String> args,
  LocalAnalyzerPrivateDraftClassifierProbe? probe,
}) async {
  final request = validateAnalyzerPrivateDraftClassifierArgs(args);
  if (!request.isValid) {
    return AnalyzerPrivateDraftClassifierCommandResult(
      exitCode: analyzerPrivateDraftClassifierReportExitUsage,
      stdoutText: '',
      stderrText: _usage(request.failure),
    );
  }
  if (request.showHelp) {
    return AnalyzerPrivateDraftClassifierCommandResult(
      exitCode: analyzerPrivateDraftClassifierReportExitSuccess,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = await (probe ?? LocalAnalyzerPrivateDraftClassifierProbe())
      .run(
        const AnalyzerPrivateDraftClassifierRequest.controlled(),
        timeout: request.timeout,
      );
  final stdoutText = switch (request.format) {
    AnalyzerPrivateDraftClassifierReportFormat.markdown =>
      result.renderMarkdown(),
    AnalyzerPrivateDraftClassifierReportFormat.json =>
      '${result.renderJson()}\n',
  };
  final blocked = request.strict && !result.safeForPhase35O;

  return AnalyzerPrivateDraftClassifierCommandResult(
    exitCode: blocked
        ? analyzerPrivateDraftClassifierReportExitBlockedStrict
        : analyzerPrivateDraftClassifierReportExitSuccess,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

AnalyzerPrivateDraftClassifierCommandRequest
validateAnalyzerPrivateDraftClassifierArgs(List<String> args) {
  var format = AnalyzerPrivateDraftClassifierReportFormat.markdown;
  var strict = false;
  var timeout = defaultLocalSearchEvalProbeTimeout;
  var formatSeen = false;
  var timeoutSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const AnalyzerPrivateDraftClassifierCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return AnalyzerPrivateDraftClassifierCommandRequest.valid(
        format: AnalyzerPrivateDraftClassifierReportFormat.markdown,
        strict: false,
        timeout: timeout,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const AnalyzerPrivateDraftClassifierCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const AnalyzerPrivateDraftClassifierCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_timeoutFlag)) {
      if (timeoutSeen) {
        return const AnalyzerPrivateDraftClassifierCommandRequest.invalid(
          'duplicateTimeout',
        );
      }
      final parsed = int.tryParse(arg.substring(_timeoutFlag.length).trim());
      if (parsed == null || parsed <= 0 || parsed > 30000) {
        return const AnalyzerPrivateDraftClassifierCommandRequest.invalid(
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
    return const AnalyzerPrivateDraftClassifierCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return AnalyzerPrivateDraftClassifierCommandRequest.valid(
    format: format,
    strict: strict,
    timeout: timeout,
  );
}

AnalyzerPrivateDraftClassifierReportFormat? _formatByWire(String value) {
  for (final format in AnalyzerPrivateDraftClassifierReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Apex private draft classifier probe usage: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/analyzer_private_draft_classifier_probe_report.dart',
    )
    ..writeln(
      '  dart run tool/analyzer_private_draft_classifier_probe_report.dart --format=markdown --strict',
    )
    ..writeln(
      '  dart run tool/analyzer_private_draft_classifier_probe_report.dart --format=json --strict',
    )
    ..writeln(
      '  dart run tool/analyzer_private_draft_classifier_probe_report.dart --timeout-ms=5000',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln('  --timeout-ms=<1..30000>')
    ..writeln()
    ..writeln('Safety:')
    ..writeln('  Phase 35N consumes the controlled draft classification')
    ..writeln('  gate and computes only a developer-only private bucket.')
    ..writeln('  It does not produce public labels, official move quality,')
    ..writeln('  official Win%, official CP-loss, accuracy, ACPL, saved')
    ..writeln('  analysis, scheduler execution, product UI, or backend work.');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _timeoutFlag = '--timeout-ms=';
const _strictFlag = '--strict';

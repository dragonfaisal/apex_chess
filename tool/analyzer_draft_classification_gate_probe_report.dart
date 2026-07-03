import 'dart:io' as io;

import 'package:apex_chess/features/analysis/domain/analyzer_draft_classification_gate.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_draft_classification_gate_probe.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

const analyzerDraftClassificationGateReportExitSuccess = 0;
const analyzerDraftClassificationGateReportExitUsage = 64;
const analyzerDraftClassificationGateReportExitBlockedStrict = 68;

enum AnalyzerDraftClassificationGateReportFormat {
  markdown('markdown'),
  json('json');

  const AnalyzerDraftClassificationGateReportFormat(this.wire);

  final String wire;
}

class AnalyzerDraftClassificationGateCommandRequest {
  const AnalyzerDraftClassificationGateCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.timeout,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const AnalyzerDraftClassificationGateCommandRequest.invalid(this.failure)
    : isValid = false,
      format = AnalyzerDraftClassificationGateReportFormat.markdown,
      strict = false,
      timeout = defaultLocalSearchEvalProbeTimeout,
      showHelp = false;

  final bool isValid;
  final String failure;
  final AnalyzerDraftClassificationGateReportFormat format;
  final bool strict;
  final Duration timeout;
  final bool showHelp;
}

class AnalyzerDraftClassificationGateCommandResult {
  const AnalyzerDraftClassificationGateCommandResult({
    required this.exitCode,
    required this.stdoutText,
    required this.stderrText,
    this.result,
  });

  final int exitCode;
  final String stdoutText;
  final String stderrText;
  final AnalyzerDraftClassificationGateResult? result;
}

Future<void> main(List<String> args) async {
  final result = await runAnalyzerDraftClassificationGateCommand(args: args);
  if (result.stdoutText.isNotEmpty) io.stdout.write(result.stdoutText);
  if (result.stderrText.isNotEmpty) io.stderr.write(result.stderrText);
  io.exitCode = result.exitCode;
}

Future<AnalyzerDraftClassificationGateCommandResult>
runAnalyzerDraftClassificationGateCommand({
  required List<String> args,
  LocalAnalyzerDraftClassificationGateProbe? probe,
}) async {
  final request = validateAnalyzerDraftClassificationGateArgs(args);
  if (!request.isValid) {
    return AnalyzerDraftClassificationGateCommandResult(
      exitCode: analyzerDraftClassificationGateReportExitUsage,
      stdoutText: '',
      stderrText: _usage(request.failure),
    );
  }
  if (request.showHelp) {
    return AnalyzerDraftClassificationGateCommandResult(
      exitCode: analyzerDraftClassificationGateReportExitSuccess,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = await (probe ?? LocalAnalyzerDraftClassificationGateProbe())
      .run(
        const AnalyzerDraftClassificationGateRequest.controlled(),
        timeout: request.timeout,
      );
  final stdoutText = switch (request.format) {
    AnalyzerDraftClassificationGateReportFormat.markdown =>
      result.renderMarkdown(),
    AnalyzerDraftClassificationGateReportFormat.json =>
      '${result.renderJson()}\n',
  };
  final blocked = request.strict && !result.safeForPhase35N;

  return AnalyzerDraftClassificationGateCommandResult(
    exitCode: blocked
        ? analyzerDraftClassificationGateReportExitBlockedStrict
        : analyzerDraftClassificationGateReportExitSuccess,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

AnalyzerDraftClassificationGateCommandRequest
validateAnalyzerDraftClassificationGateArgs(List<String> args) {
  var format = AnalyzerDraftClassificationGateReportFormat.markdown;
  var strict = false;
  var timeout = defaultLocalSearchEvalProbeTimeout;
  var formatSeen = false;
  var timeoutSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const AnalyzerDraftClassificationGateCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return AnalyzerDraftClassificationGateCommandRequest.valid(
        format: AnalyzerDraftClassificationGateReportFormat.markdown,
        strict: false,
        timeout: timeout,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const AnalyzerDraftClassificationGateCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const AnalyzerDraftClassificationGateCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_timeoutFlag)) {
      if (timeoutSeen) {
        return const AnalyzerDraftClassificationGateCommandRequest.invalid(
          'duplicateTimeout',
        );
      }
      final parsed = int.tryParse(arg.substring(_timeoutFlag.length).trim());
      if (parsed == null || parsed <= 0 || parsed > 30000) {
        return const AnalyzerDraftClassificationGateCommandRequest.invalid(
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
    return const AnalyzerDraftClassificationGateCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return AnalyzerDraftClassificationGateCommandRequest.valid(
    format: format,
    strict: strict,
    timeout: timeout,
  );
}

AnalyzerDraftClassificationGateReportFormat? _formatByWire(String value) {
  for (final format in AnalyzerDraftClassificationGateReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Apex draft classification gate probe usage: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/analyzer_draft_classification_gate_probe_report.dart',
    )
    ..writeln(
      '  dart run tool/analyzer_draft_classification_gate_probe_report.dart --format=markdown --strict',
    )
    ..writeln(
      '  dart run tool/analyzer_draft_classification_gate_probe_report.dart --format=json --strict',
    )
    ..writeln(
      '  dart run tool/analyzer_draft_classification_gate_probe_report.dart --timeout-ms=5000',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln('  --timeout-ms=<1..30000>')
    ..writeln()
    ..writeln('Safety:')
    ..writeln('  Phase 35M consumes controlled move quality draft evidence')
    ..writeln('  and computes only internal structural eligibility for')
    ..writeln('  future classifier work. It does not produce public labels,')
    ..writeln('  official move quality, official Win%, official CP-loss,')
    ..writeln('  accuracy, ACPL, saved analysis, scheduler execution,')
    ..writeln('  product UI, or backend work.');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _timeoutFlag = '--timeout-ms=';
const _strictFlag = '--strict';

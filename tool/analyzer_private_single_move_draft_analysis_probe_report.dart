import 'dart:io' as io;

import 'package:apex_chess/features/analysis/domain/analyzer_private_single_move_draft_analysis.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_private_single_move_draft_analysis_probe.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

const analyzerPrivateSingleMoveDraftAnalysisReportExitSuccess = 0;
const analyzerPrivateSingleMoveDraftAnalysisReportExitUsage = 64;
const analyzerPrivateSingleMoveDraftAnalysisReportExitBlockedStrict = 68;

enum AnalyzerPrivateSingleMoveDraftAnalysisReportFormat {
  markdown('markdown'),
  json('json');

  const AnalyzerPrivateSingleMoveDraftAnalysisReportFormat(this.wire);

  final String wire;
}

class AnalyzerPrivateSingleMoveDraftAnalysisCommandRequest {
  const AnalyzerPrivateSingleMoveDraftAnalysisCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.timeout,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const AnalyzerPrivateSingleMoveDraftAnalysisCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = AnalyzerPrivateSingleMoveDraftAnalysisReportFormat.markdown,
      strict = false,
      timeout = defaultLocalSearchEvalProbeTimeout,
      showHelp = false;

  final bool isValid;
  final String failure;
  final AnalyzerPrivateSingleMoveDraftAnalysisReportFormat format;
  final bool strict;
  final Duration timeout;
  final bool showHelp;
}

class AnalyzerPrivateSingleMoveDraftAnalysisCommandResult {
  const AnalyzerPrivateSingleMoveDraftAnalysisCommandResult({
    required this.exitCode,
    required this.stdoutText,
    required this.stderrText,
    this.result,
  });

  final int exitCode;
  final String stdoutText;
  final String stderrText;
  final AnalyzerPrivateSingleMoveDraftAnalysisResult? result;
}

Future<void> main(List<String> args) async {
  final result = await runAnalyzerPrivateSingleMoveDraftAnalysisCommand(
    args: args,
  );
  if (result.stdoutText.isNotEmpty) io.stdout.write(result.stdoutText);
  if (result.stderrText.isNotEmpty) io.stderr.write(result.stderrText);
  io.exitCode = result.exitCode;
}

Future<AnalyzerPrivateSingleMoveDraftAnalysisCommandResult>
runAnalyzerPrivateSingleMoveDraftAnalysisCommand({
  required List<String> args,
  LocalAnalyzerPrivateSingleMoveDraftAnalysisProbe? probe,
}) async {
  final request = validateAnalyzerPrivateSingleMoveDraftAnalysisArgs(args);
  if (!request.isValid) {
    return AnalyzerPrivateSingleMoveDraftAnalysisCommandResult(
      exitCode: analyzerPrivateSingleMoveDraftAnalysisReportExitUsage,
      stdoutText: '',
      stderrText: _usage(request.failure),
    );
  }
  if (request.showHelp) {
    return AnalyzerPrivateSingleMoveDraftAnalysisCommandResult(
      exitCode: analyzerPrivateSingleMoveDraftAnalysisReportExitSuccess,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result =
      await (probe ?? LocalAnalyzerPrivateSingleMoveDraftAnalysisProbe()).run(
        const AnalyzerPrivateSingleMoveDraftAnalysisRequest.controlled(),
        timeout: request.timeout,
      );
  final stdoutText = switch (request.format) {
    AnalyzerPrivateSingleMoveDraftAnalysisReportFormat.markdown =>
      result.renderMarkdown(),
    AnalyzerPrivateSingleMoveDraftAnalysisReportFormat.json =>
      '${result.renderJson()}\n',
  };
  final blocked = request.strict && !result.safeForPhase36A;

  return AnalyzerPrivateSingleMoveDraftAnalysisCommandResult(
    exitCode: blocked
        ? analyzerPrivateSingleMoveDraftAnalysisReportExitBlockedStrict
        : analyzerPrivateSingleMoveDraftAnalysisReportExitSuccess,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

AnalyzerPrivateSingleMoveDraftAnalysisCommandRequest
validateAnalyzerPrivateSingleMoveDraftAnalysisArgs(List<String> args) {
  var format = AnalyzerPrivateSingleMoveDraftAnalysisReportFormat.markdown;
  var strict = false;
  var timeout = defaultLocalSearchEvalProbeTimeout;
  var formatSeen = false;
  var timeoutSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const AnalyzerPrivateSingleMoveDraftAnalysisCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return AnalyzerPrivateSingleMoveDraftAnalysisCommandRequest.valid(
        format: AnalyzerPrivateSingleMoveDraftAnalysisReportFormat.markdown,
        strict: false,
        timeout: timeout,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const AnalyzerPrivateSingleMoveDraftAnalysisCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const AnalyzerPrivateSingleMoveDraftAnalysisCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_timeoutFlag)) {
      if (timeoutSeen) {
        return const AnalyzerPrivateSingleMoveDraftAnalysisCommandRequest.invalid(
          'duplicateTimeout',
        );
      }
      final parsed = int.tryParse(arg.substring(_timeoutFlag.length).trim());
      if (parsed == null || parsed <= 0 || parsed > 30000) {
        return const AnalyzerPrivateSingleMoveDraftAnalysisCommandRequest.invalid(
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
    return const AnalyzerPrivateSingleMoveDraftAnalysisCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return AnalyzerPrivateSingleMoveDraftAnalysisCommandRequest.valid(
    format: format,
    strict: strict,
    timeout: timeout,
  );
}

AnalyzerPrivateSingleMoveDraftAnalysisReportFormat? _formatByWire(
  String value,
) {
  for (final format
      in AnalyzerPrivateSingleMoveDraftAnalysisReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Apex private single-move draft analysis usage: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/analyzer_private_single_move_draft_analysis_probe_report.dart',
    )
    ..writeln(
      '  dart run tool/analyzer_private_single_move_draft_analysis_probe_report.dart --format=markdown --strict',
    )
    ..writeln(
      '  dart run tool/analyzer_private_single_move_draft_analysis_probe_report.dart --format=json --strict',
    )
    ..writeln(
      '  dart run tool/analyzer_private_single_move_draft_analysis_probe_report.dart --timeout-ms=5000',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln('  --timeout-ms=<1..30000>')
    ..writeln()
    ..writeln('Safety:')
    ..writeln('  Phase 35Q packages the controlled private classifier path')
    ..writeln('  into a developer-only internal result contract. It does not')
    ..writeln('  produce public labels, official move quality, official Win%,')
    ..writeln('  official CP-loss, accuracy, ACPL, saved analysis, scheduler')
    ..writeln('  execution, product UI, archive, stats, or backend work.');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _timeoutFlag = '--timeout-ms=';
const _strictFlag = '--strict';

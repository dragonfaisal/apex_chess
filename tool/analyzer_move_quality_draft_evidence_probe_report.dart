import 'dart:io' as io;

import 'package:apex_chess/features/analysis/domain/analyzer_move_quality_draft_evidence.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_move_quality_draft_evidence_probe.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

const analyzerMoveQualityDraftEvidenceReportExitSuccess = 0;
const analyzerMoveQualityDraftEvidenceReportExitUsage = 64;
const analyzerMoveQualityDraftEvidenceReportExitBlockedStrict = 68;

enum AnalyzerMoveQualityDraftEvidenceReportFormat {
  markdown('markdown'),
  json('json');

  const AnalyzerMoveQualityDraftEvidenceReportFormat(this.wire);

  final String wire;
}

class AnalyzerMoveQualityDraftEvidenceCommandRequest {
  const AnalyzerMoveQualityDraftEvidenceCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.timeout,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const AnalyzerMoveQualityDraftEvidenceCommandRequest.invalid(this.failure)
    : isValid = false,
      format = AnalyzerMoveQualityDraftEvidenceReportFormat.markdown,
      strict = false,
      timeout = defaultLocalSearchEvalProbeTimeout,
      showHelp = false;

  final bool isValid;
  final String failure;
  final AnalyzerMoveQualityDraftEvidenceReportFormat format;
  final bool strict;
  final Duration timeout;
  final bool showHelp;
}

class AnalyzerMoveQualityDraftEvidenceCommandResult {
  const AnalyzerMoveQualityDraftEvidenceCommandResult({
    required this.exitCode,
    required this.stdoutText,
    required this.stderrText,
    this.result,
  });

  final int exitCode;
  final String stdoutText;
  final String stderrText;
  final AnalyzerMoveQualityDraftEvidenceResult? result;
}

Future<void> main(List<String> args) async {
  final result = await runAnalyzerMoveQualityDraftEvidenceCommand(args: args);
  if (result.stdoutText.isNotEmpty) io.stdout.write(result.stdoutText);
  if (result.stderrText.isNotEmpty) io.stderr.write(result.stderrText);
  io.exitCode = result.exitCode;
}

Future<AnalyzerMoveQualityDraftEvidenceCommandResult>
runAnalyzerMoveQualityDraftEvidenceCommand({
  required List<String> args,
  LocalAnalyzerMoveQualityDraftEvidenceProbe? probe,
}) async {
  final request = validateAnalyzerMoveQualityDraftEvidenceArgs(args);
  if (!request.isValid) {
    return AnalyzerMoveQualityDraftEvidenceCommandResult(
      exitCode: analyzerMoveQualityDraftEvidenceReportExitUsage,
      stdoutText: '',
      stderrText: _usage(request.failure),
    );
  }
  if (request.showHelp) {
    return AnalyzerMoveQualityDraftEvidenceCommandResult(
      exitCode: analyzerMoveQualityDraftEvidenceReportExitSuccess,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = await (probe ?? LocalAnalyzerMoveQualityDraftEvidenceProbe())
      .run(
        const AnalyzerMoveQualityDraftEvidenceRequest.controlled(),
        timeout: request.timeout,
      );
  final stdoutText = switch (request.format) {
    AnalyzerMoveQualityDraftEvidenceReportFormat.markdown =>
      result.renderMarkdown(),
    AnalyzerMoveQualityDraftEvidenceReportFormat.json =>
      '${result.renderJson()}\n',
  };
  final blocked = request.strict && !result.safeForPhase35M;

  return AnalyzerMoveQualityDraftEvidenceCommandResult(
    exitCode: blocked
        ? analyzerMoveQualityDraftEvidenceReportExitBlockedStrict
        : analyzerMoveQualityDraftEvidenceReportExitSuccess,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

AnalyzerMoveQualityDraftEvidenceCommandRequest
validateAnalyzerMoveQualityDraftEvidenceArgs(List<String> args) {
  var format = AnalyzerMoveQualityDraftEvidenceReportFormat.markdown;
  var strict = false;
  var timeout = defaultLocalSearchEvalProbeTimeout;
  var formatSeen = false;
  var timeoutSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const AnalyzerMoveQualityDraftEvidenceCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return AnalyzerMoveQualityDraftEvidenceCommandRequest.valid(
        format: AnalyzerMoveQualityDraftEvidenceReportFormat.markdown,
        strict: false,
        timeout: timeout,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const AnalyzerMoveQualityDraftEvidenceCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const AnalyzerMoveQualityDraftEvidenceCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_timeoutFlag)) {
      if (timeoutSeen) {
        return const AnalyzerMoveQualityDraftEvidenceCommandRequest.invalid(
          'duplicateTimeout',
        );
      }
      final parsed = int.tryParse(arg.substring(_timeoutFlag.length).trim());
      if (parsed == null || parsed <= 0 || parsed > 30000) {
        return const AnalyzerMoveQualityDraftEvidenceCommandRequest.invalid(
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
    return const AnalyzerMoveQualityDraftEvidenceCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return AnalyzerMoveQualityDraftEvidenceCommandRequest.valid(
    format: format,
    strict: strict,
    timeout: timeout,
  );
}

AnalyzerMoveQualityDraftEvidenceReportFormat? _formatByWire(String value) {
  for (final format in AnalyzerMoveQualityDraftEvidenceReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Apex move quality draft evidence probe usage: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/analyzer_move_quality_draft_evidence_probe_report.dart',
    )
    ..writeln(
      '  dart run tool/analyzer_move_quality_draft_evidence_probe_report.dart --format=markdown --strict',
    )
    ..writeln(
      '  dart run tool/analyzer_move_quality_draft_evidence_probe_report.dart --format=json --strict',
    )
    ..writeln(
      '  dart run tool/analyzer_move_quality_draft_evidence_probe_report.dart --timeout-ms=5000',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln('  --timeout-ms=<1..30000>')
    ..writeln()
    ..writeln('Safety:')
    ..writeln('  Phase 35L wraps controlled expected-points evidence into an')
    ..writeln('  internal draft evidence object only. It does not produce')
    ..writeln('  public labels, official move quality, official Win%, official')
    ..writeln('  CP-loss, accuracy, ACPL, saved analysis, scheduler execution,')
    ..writeln('  product UI, or backend work.');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _timeoutFlag = '--timeout-ms=';
const _strictFlag = '--strict';

import 'dart:io' as io;

import 'package:apex_chess/features/analysis/domain/analyzer_legacy_reintegration_contract.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_legacy_reintegration_probe.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

const analyzerLegacyReintegrationReportExitSuccess = 0;
const analyzerLegacyReintegrationReportExitUsage = 64;
const analyzerLegacyReintegrationReportExitBlockedStrict = 68;

enum AnalyzerLegacyReintegrationReportFormat {
  markdown('markdown'),
  json('json');

  const AnalyzerLegacyReintegrationReportFormat(this.wire);

  final String wire;
}

class AnalyzerLegacyReintegrationCommandRequest {
  const AnalyzerLegacyReintegrationCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.timeout,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const AnalyzerLegacyReintegrationCommandRequest.invalid(this.failure)
    : isValid = false,
      format = AnalyzerLegacyReintegrationReportFormat.markdown,
      strict = false,
      timeout = defaultLocalSearchEvalProbeTimeout,
      showHelp = false;

  final bool isValid;
  final String failure;
  final AnalyzerLegacyReintegrationReportFormat format;
  final bool strict;
  final Duration timeout;
  final bool showHelp;
}

class AnalyzerLegacyReintegrationCommandResult {
  const AnalyzerLegacyReintegrationCommandResult({
    required this.exitCode,
    required this.stdoutText,
    required this.stderrText,
    this.result,
  });

  final int exitCode;
  final String stdoutText;
  final String stderrText;
  final AnalyzerLegacyReintegrationResult? result;
}

Future<void> main(List<String> args) async {
  final result = await runAnalyzerLegacyReintegrationCommand(args: args);
  if (result.stdoutText.isNotEmpty) io.stdout.write(result.stdoutText);
  if (result.stderrText.isNotEmpty) io.stderr.write(result.stderrText);
  io.exitCode = result.exitCode;
}

Future<AnalyzerLegacyReintegrationCommandResult>
runAnalyzerLegacyReintegrationCommand({
  required List<String> args,
  LocalAnalyzerLegacyReintegrationProbe? probe,
}) async {
  final request = validateAnalyzerLegacyReintegrationArgs(args);
  if (!request.isValid) {
    return AnalyzerLegacyReintegrationCommandResult(
      exitCode: analyzerLegacyReintegrationReportExitUsage,
      stdoutText: '',
      stderrText: _usage(request.failure),
    );
  }
  if (request.showHelp) {
    return AnalyzerLegacyReintegrationCommandResult(
      exitCode: analyzerLegacyReintegrationReportExitSuccess,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = await (probe ?? LocalAnalyzerLegacyReintegrationProbe()).run(
    const AnalyzerLegacyReintegrationRequest.controlled(),
    timeout: request.timeout,
  );
  final stdoutText = switch (request.format) {
    AnalyzerLegacyReintegrationReportFormat.markdown => result.renderMarkdown(),
    AnalyzerLegacyReintegrationReportFormat.json => '${result.renderJson()}\n',
  };
  final blocked = request.strict && !result.safeForPhase36B;

  return AnalyzerLegacyReintegrationCommandResult(
    exitCode: blocked
        ? analyzerLegacyReintegrationReportExitBlockedStrict
        : analyzerLegacyReintegrationReportExitSuccess,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

AnalyzerLegacyReintegrationCommandRequest
validateAnalyzerLegacyReintegrationArgs(List<String> args) {
  var format = AnalyzerLegacyReintegrationReportFormat.markdown;
  var strict = false;
  var timeout = defaultLocalSearchEvalProbeTimeout;
  var formatSeen = false;
  var timeoutSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const AnalyzerLegacyReintegrationCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return AnalyzerLegacyReintegrationCommandRequest.valid(
        format: AnalyzerLegacyReintegrationReportFormat.markdown,
        strict: false,
        timeout: timeout,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const AnalyzerLegacyReintegrationCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const AnalyzerLegacyReintegrationCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_timeoutFlag)) {
      if (timeoutSeen) {
        return const AnalyzerLegacyReintegrationCommandRequest.invalid(
          'duplicateTimeout',
        );
      }
      final parsed = int.tryParse(arg.substring(_timeoutFlag.length).trim());
      if (parsed == null || parsed <= 0 || parsed > 30000) {
        return const AnalyzerLegacyReintegrationCommandRequest.invalid(
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
    return const AnalyzerLegacyReintegrationCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return AnalyzerLegacyReintegrationCommandRequest.valid(
    format: format,
    strict: strict,
    timeout: timeout,
  );
}

AnalyzerLegacyReintegrationReportFormat? _formatByWire(String value) {
  for (final format in AnalyzerLegacyReintegrationReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Apex legacy reintegration probe usage: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/analyzer_legacy_reintegration_probe_report.dart')
    ..writeln(
      '  dart run tool/analyzer_legacy_reintegration_probe_report.dart --format=markdown --strict',
    )
    ..writeln(
      '  dart run tool/analyzer_legacy_reintegration_probe_report.dart --format=json --strict',
    )
    ..writeln(
      '  dart run tool/analyzer_legacy_reintegration_probe_report.dart --timeout-ms=5000',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln('  --timeout-ms=<1..30000>')
    ..writeln()
    ..writeln('Safety:')
    ..writeln('  Phase 36A wraps the controlled Phase 35Q private result')
    ..writeln('  in a developer-only legacy reintegration seam. It does')
    ..writeln('  not call legacy public classifier, saved analysis, UI,')
    ..writeln('  archive, stats, backend, scheduler, or product review code.');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _timeoutFlag = '--timeout-ms=';
const _strictFlag = '--strict';

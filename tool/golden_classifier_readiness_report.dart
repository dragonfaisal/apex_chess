import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_classifier_readiness_gate.dart';

const goldenClassifierReadinessReportExitSuccess = 0;
const goldenClassifierReadinessReportExitUsage = 64;
const goldenClassifierReadinessReportExitBlockedStrict = 68;
const goldenClassifierReadinessReportExitUnsafeClaim = 69;

class GoldenClassifierReadinessReportCommandResult {
  const GoldenClassifierReadinessReportCommandResult({
    required this.exitCode,
    required this.format,
    required this.strict,
    required this.stdoutText,
    required this.stderrText,
    this.result,
    this.commandFailure,
  });

  final int exitCode;
  final GoldenClassifierReadinessReportFormat format;
  final bool strict;
  final String stdoutText;
  final String stderrText;
  final GoldenClassifierReadinessResult? result;
  final String? commandFailure;
}

class GoldenClassifierReadinessReportCommandRequest {
  const GoldenClassifierReadinessReportCommandRequest.valid({
    required this.format,
    required this.strict,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const GoldenClassifierReadinessReportCommandRequest.invalid(this.failure)
    : isValid = false,
      format = GoldenClassifierReadinessReportFormat.markdown,
      strict = false,
      showHelp = false;

  final bool isValid;
  final String failure;
  final GoldenClassifierReadinessReportFormat format;
  final bool strict;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runGoldenClassifierReadinessReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

GoldenClassifierReadinessReportCommandResult
runGoldenClassifierReadinessReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  GoldenClassifierReadinessGate gate = const GoldenClassifierReadinessGate(),
}) {
  final request = validateGoldenClassifierReadinessReportArgs(args);
  if (!request.isValid) {
    return GoldenClassifierReadinessReportCommandResult(
      exitCode: goldenClassifierReadinessReportExitUsage,
      format: request.format,
      strict: request.strict,
      stdoutText: '',
      stderrText: _usage(request.failure),
      commandFailure: request.failure,
    );
  }
  if (request.showHelp) {
    return GoldenClassifierReadinessReportCommandResult(
      exitCode: goldenClassifierReadinessReportExitSuccess,
      format: request.format,
      strict: request.strict,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = gate.evaluate(GoldenClassifierReadinessRequest(cases: cases));
  final stdoutText = switch (request.format) {
    GoldenClassifierReadinessReportFormat.markdown =>
      result.renderMarkdownReport(),
    GoldenClassifierReadinessReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return GoldenClassifierReadinessReportCommandResult(
    exitCode: goldenClassifierReadinessReportExitCode(result, request),
    format: request.format,
    strict: request.strict,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

GoldenClassifierReadinessReportCommandRequest
validateGoldenClassifierReadinessReportArgs(List<String> args) {
  var format = GoldenClassifierReadinessReportFormat.markdown;
  var strict = false;
  var formatSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const GoldenClassifierReadinessReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const GoldenClassifierReadinessReportCommandRequest.valid(
        format: GoldenClassifierReadinessReportFormat.markdown,
        strict: false,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const GoldenClassifierReadinessReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const GoldenClassifierReadinessReportCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg == _strictFlag) {
      strict = true;
      continue;
    }
    return const GoldenClassifierReadinessReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return GoldenClassifierReadinessReportCommandRequest.valid(
    format: format,
    strict: strict,
  );
}

int goldenClassifierReadinessReportExitCode(
  GoldenClassifierReadinessResult result,
  GoldenClassifierReadinessReportCommandRequest request,
) {
  if (result.hasUnsafeReadinessClaim) {
    return goldenClassifierReadinessReportExitUnsafeClaim;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return goldenClassifierReadinessReportExitBlockedStrict;
  }
  return goldenClassifierReadinessReportExitSuccess;
}

GoldenClassifierReadinessReportFormat? _formatByWire(String value) {
  for (final format in GoldenClassifierReadinessReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Golden Classifier Readiness report command usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/golden_classifier_readiness_report.dart')
    ..writeln(
      '  dart run tool/golden_classifier_readiness_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/golden_classifier_readiness_report.dart --strict',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _strictFlag = '--strict';

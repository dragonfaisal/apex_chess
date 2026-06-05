import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_experiment_runner.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_observation_review_matrix.dart';

const internalSignalObservationReviewMatrixReportExitSuccess = 0;
const internalSignalObservationReviewMatrixReportExitUsage = 64;
const internalSignalObservationReviewMatrixReportExitBlockedStrict = 68;
const internalSignalObservationReviewMatrixReportExitUnsafePolicy = 69;

class InternalSignalObservationReviewMatrixReportCommandResult {
  const InternalSignalObservationReviewMatrixReportCommandResult({
    required this.exitCode,
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    required this.stdoutText,
    required this.stderrText,
    this.result,
    this.commandFailure,
  });

  final int exitCode;
  final InternalSignalObservationReviewReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final InternalSignalObservationReviewMatrixResult? result;
  final String? commandFailure;
}

class InternalSignalObservationReviewMatrixReportCommandRequest {
  const InternalSignalObservationReviewMatrixReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalSignalObservationReviewMatrixReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = InternalSignalObservationReviewReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalSignalObservationReviewReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalSignalObservationReviewMatrixReportCommand(
    args: args,
  );
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

InternalSignalObservationReviewMatrixReportCommandResult
runInternalSignalObservationReviewMatrixReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalSignalObservationReviewMatrix matrix =
      const InternalSignalObservationReviewMatrix(),
  InternalSignalObservationReviewMatrixRequest? request,
}) {
  final commandRequest =
      validateInternalSignalObservationReviewMatrixReportArgs(args);
  if (!commandRequest.isValid) {
    return InternalSignalObservationReviewMatrixReportCommandResult(
      exitCode: internalSignalObservationReviewMatrixReportExitUsage,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: '',
      stderrText: _usage(commandRequest.failure),
      commandFailure: commandRequest.failure,
    );
  }
  if (commandRequest.showHelp) {
    return InternalSignalObservationReviewMatrixReportCommandResult(
      exitCode: internalSignalObservationReviewMatrixReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final matrixRequest =
      request ??
      InternalSignalObservationReviewMatrixRequest(
        cases: cases,
        runnerRequest: InternalSignalExperimentRunnerRequest.safeDemo(
          cases: cases,
          includeWarningSignals: commandRequest.includeWarnings,
        ),
      );
  final result = matrix.evaluate(matrixRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalSignalObservationReviewReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalSignalObservationReviewReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return InternalSignalObservationReviewMatrixReportCommandResult(
    exitCode: internalSignalObservationReviewMatrixReportExitCode(
      result,
      commandRequest,
    ),
    format: commandRequest.format,
    strict: commandRequest.strict,
    safeDemo: commandRequest.safeDemo,
    includeWarnings: commandRequest.includeWarnings,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

InternalSignalObservationReviewMatrixReportCommandRequest
validateInternalSignalObservationReviewMatrixReportArgs(List<String> args) {
  var format = InternalSignalObservationReviewReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalSignalObservationReviewMatrixReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalSignalObservationReviewMatrixReportCommandRequest.valid(
        format: InternalSignalObservationReviewReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalSignalObservationReviewMatrixReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalSignalObservationReviewMatrixReportCommandRequest.invalid(
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
    if (arg == _safeDemoFlag) {
      if (safeDemoSeen) {
        return const InternalSignalObservationReviewMatrixReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const InternalSignalObservationReviewMatrixReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const InternalSignalObservationReviewMatrixReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalSignalObservationReviewMatrixReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int internalSignalObservationReviewMatrixReportExitCode(
  InternalSignalObservationReviewMatrixResult result,
  InternalSignalObservationReviewMatrixReportCommandRequest request,
) {
  if (result.hasUnsafeReviewPolicyViolation) {
    return internalSignalObservationReviewMatrixReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalSignalObservationReviewMatrixReportExitBlockedStrict;
  }
  return internalSignalObservationReviewMatrixReportExitSuccess;
}

InternalSignalObservationReviewReportFormat? _formatByWire(String value) {
  for (final format in InternalSignalObservationReviewReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Internal Signal Observation Review Matrix report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/internal_signal_observation_review_matrix_report.dart',
    )
    ..writeln(
      '  dart run tool/internal_signal_observation_review_matrix_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_signal_observation_review_matrix_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_signal_observation_review_matrix_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_signal_observation_review_matrix_report.dart --include-warnings',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln('  --safe-demo')
    ..writeln('  --include-warnings');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';

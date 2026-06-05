import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_experiment_runner.dart';

const internalSignalExperimentRunnerReportExitSuccess = 0;
const internalSignalExperimentRunnerReportExitUsage = 64;
const internalSignalExperimentRunnerReportExitBlockedStrict = 68;
const internalSignalExperimentRunnerReportExitUnsafePolicy = 69;

class InternalSignalExperimentRunnerReportCommandResult {
  const InternalSignalExperimentRunnerReportCommandResult({
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
  final InternalSignalExperimentRunnerReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final InternalSignalExperimentRunnerResult? result;
  final String? commandFailure;
}

class InternalSignalExperimentRunnerReportCommandRequest {
  const InternalSignalExperimentRunnerReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalSignalExperimentRunnerReportCommandRequest.invalid(this.failure)
    : isValid = false,
      format = InternalSignalExperimentRunnerReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalSignalExperimentRunnerReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalSignalExperimentRunnerReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

InternalSignalExperimentRunnerReportCommandResult
runInternalSignalExperimentRunnerReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalSignalExperimentRunner runner =
      const InternalSignalExperimentRunner(),
  InternalSignalExperimentRunnerRequest? request,
}) {
  final commandRequest = validateInternalSignalExperimentRunnerReportArgs(args);
  if (!commandRequest.isValid) {
    return InternalSignalExperimentRunnerReportCommandResult(
      exitCode: internalSignalExperimentRunnerReportExitUsage,
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
    return InternalSignalExperimentRunnerReportCommandResult(
      exitCode: internalSignalExperimentRunnerReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final runnerRequest =
      request ??
      InternalSignalExperimentRunnerRequest.safeDemo(
        cases: cases,
        includeWarningSignals: commandRequest.includeWarnings,
      );
  final result = runner.run(runnerRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalSignalExperimentRunnerReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalSignalExperimentRunnerReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return InternalSignalExperimentRunnerReportCommandResult(
    exitCode: internalSignalExperimentRunnerReportExitCode(
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

InternalSignalExperimentRunnerReportCommandRequest
validateInternalSignalExperimentRunnerReportArgs(List<String> args) {
  var format = InternalSignalExperimentRunnerReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalSignalExperimentRunnerReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalSignalExperimentRunnerReportCommandRequest.valid(
        format: InternalSignalExperimentRunnerReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalSignalExperimentRunnerReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalSignalExperimentRunnerReportCommandRequest.invalid(
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
        return const InternalSignalExperimentRunnerReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const InternalSignalExperimentRunnerReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const InternalSignalExperimentRunnerReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalSignalExperimentRunnerReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int internalSignalExperimentRunnerReportExitCode(
  InternalSignalExperimentRunnerResult result,
  InternalSignalExperimentRunnerReportCommandRequest request,
) {
  if (result.hasUnsafeRunnerPolicyViolation) {
    return internalSignalExperimentRunnerReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalSignalExperimentRunnerReportExitBlockedStrict;
  }
  return internalSignalExperimentRunnerReportExitSuccess;
}

InternalSignalExperimentRunnerReportFormat? _formatByWire(String value) {
  for (final format in InternalSignalExperimentRunnerReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Internal Signal Experiment Runner report usage error: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/internal_signal_experiment_runner_report.dart')
    ..writeln(
      '  dart run tool/internal_signal_experiment_runner_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_signal_experiment_runner_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_signal_experiment_runner_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_signal_experiment_runner_report.dart --include-warnings',
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

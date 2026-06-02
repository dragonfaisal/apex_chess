import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_guards.dart';

const internalBucketExperimentGuardsReportExitSuccess = 0;
const internalBucketExperimentGuardsReportExitUsage = 64;
const internalBucketExperimentGuardsReportExitBlockedStrict = 68;
const internalBucketExperimentGuardsReportExitUnsafePolicy = 69;

class InternalBucketExperimentGuardsReportCommandResult {
  const InternalBucketExperimentGuardsReportCommandResult({
    required this.exitCode,
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.stdoutText,
    required this.stderrText,
    this.result,
    this.commandFailure,
  });

  final int exitCode;
  final InternalBucketExperimentGuardsReportFormat format;
  final bool strict;
  final bool safeDemo;
  final String stdoutText;
  final String stderrText;
  final InternalBucketExperimentGuardResult? result;
  final String? commandFailure;
}

class InternalBucketExperimentGuardsReportCommandRequest {
  const InternalBucketExperimentGuardsReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalBucketExperimentGuardsReportCommandRequest.invalid(this.failure)
    : isValid = false,
      format = InternalBucketExperimentGuardsReportFormat.markdown,
      strict = false,
      safeDemo = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalBucketExperimentGuardsReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalBucketExperimentGuardsReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

InternalBucketExperimentGuardsReportCommandResult
runInternalBucketExperimentGuardsReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalBucketExperimentGuard guard = const InternalBucketExperimentGuard(),
  InternalBucketExperimentRequest? request,
}) {
  final commandRequest = validateInternalBucketExperimentGuardsReportArgs(args);
  if (!commandRequest.isValid) {
    return InternalBucketExperimentGuardsReportCommandResult(
      exitCode: internalBucketExperimentGuardsReportExitUsage,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      stdoutText: '',
      stderrText: _usage(commandRequest.failure),
      commandFailure: commandRequest.failure,
    );
  }
  if (commandRequest.showHelp) {
    return InternalBucketExperimentGuardsReportCommandResult(
      exitCode: internalBucketExperimentGuardsReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final experimentRequest =
      request ?? InternalBucketExperimentRequest.safeDemo(cases: cases);
  final result = guard.evaluate(experimentRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalBucketExperimentGuardsReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalBucketExperimentGuardsReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return InternalBucketExperimentGuardsReportCommandResult(
    exitCode: internalBucketExperimentGuardsReportExitCode(
      result,
      commandRequest,
    ),
    format: commandRequest.format,
    strict: commandRequest.strict,
    safeDemo: commandRequest.safeDemo,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

InternalBucketExperimentGuardsReportCommandRequest
validateInternalBucketExperimentGuardsReportArgs(List<String> args) {
  var format = InternalBucketExperimentGuardsReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var formatSeen = false;
  var safeDemoSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalBucketExperimentGuardsReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalBucketExperimentGuardsReportCommandRequest.valid(
        format: InternalBucketExperimentGuardsReportFormat.markdown,
        strict: false,
        safeDemo: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalBucketExperimentGuardsReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalBucketExperimentGuardsReportCommandRequest.invalid(
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
        return const InternalBucketExperimentGuardsReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    return const InternalBucketExperimentGuardsReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalBucketExperimentGuardsReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
  );
}

int internalBucketExperimentGuardsReportExitCode(
  InternalBucketExperimentGuardResult result,
  InternalBucketExperimentGuardsReportCommandRequest request,
) {
  if (result.hasUnsafeExperimentPolicyViolation) {
    return internalBucketExperimentGuardsReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalBucketExperimentGuardsReportExitBlockedStrict;
  }
  return internalBucketExperimentGuardsReportExitSuccess;
}

InternalBucketExperimentGuardsReportFormat? _formatByWire(String value) {
  for (final format in InternalBucketExperimentGuardsReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Internal Bucket Experiment Guards report command usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/internal_bucket_experiment_guards_report.dart')
    ..writeln(
      '  dart run tool/internal_bucket_experiment_guards_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_bucket_experiment_guards_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_bucket_experiment_guards_report.dart --safe-demo',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln('  --safe-demo');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';

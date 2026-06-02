import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_harness.dart';

const internalBucketExperimentHarnessReportExitSuccess = 0;
const internalBucketExperimentHarnessReportExitUsage = 64;
const internalBucketExperimentHarnessReportExitBlockedStrict = 68;
const internalBucketExperimentHarnessReportExitUnsafePolicy = 69;

class InternalBucketExperimentHarnessReportCommandResult {
  const InternalBucketExperimentHarnessReportCommandResult({
    required this.exitCode,
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includePartial,
    required this.stdoutText,
    required this.stderrText,
    this.result,
    this.commandFailure,
  });

  final int exitCode;
  final InternalBucketExperimentHarnessReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includePartial;
  final String stdoutText;
  final String stderrText;
  final InternalBucketExperimentHarnessResult? result;
  final String? commandFailure;
}

class InternalBucketExperimentHarnessReportCommandRequest {
  const InternalBucketExperimentHarnessReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includePartial,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalBucketExperimentHarnessReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = InternalBucketExperimentHarnessReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includePartial = false,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalBucketExperimentHarnessReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includePartial;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalBucketExperimentHarnessReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

InternalBucketExperimentHarnessReportCommandResult
runInternalBucketExperimentHarnessReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalBucketExperimentHarness harness =
      const InternalBucketExperimentHarness(),
  InternalBucketExperimentHarnessRequest? request,
}) {
  final commandRequest = validateInternalBucketExperimentHarnessReportArgs(
    args,
  );
  if (!commandRequest.isValid) {
    return InternalBucketExperimentHarnessReportCommandResult(
      exitCode: internalBucketExperimentHarnessReportExitUsage,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includePartial: commandRequest.includePartial,
      stdoutText: '',
      stderrText: _usage(commandRequest.failure),
      commandFailure: commandRequest.failure,
    );
  }
  if (commandRequest.showHelp) {
    return InternalBucketExperimentHarnessReportCommandResult(
      exitCode: internalBucketExperimentHarnessReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includePartial: commandRequest.includePartial,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final harnessRequest =
      request ??
      InternalBucketExperimentHarnessRequest.safeDemo(
        cases: cases,
        includePartialBuckets: commandRequest.includePartial,
      );
  final result = harness.run(harnessRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalBucketExperimentHarnessReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalBucketExperimentHarnessReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return InternalBucketExperimentHarnessReportCommandResult(
    exitCode: internalBucketExperimentHarnessReportExitCode(
      result,
      commandRequest,
    ),
    format: commandRequest.format,
    strict: commandRequest.strict,
    safeDemo: commandRequest.safeDemo,
    includePartial: commandRequest.includePartial,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

InternalBucketExperimentHarnessReportCommandRequest
validateInternalBucketExperimentHarnessReportArgs(List<String> args) {
  var format = InternalBucketExperimentHarnessReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includePartial = false;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includePartialSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalBucketExperimentHarnessReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalBucketExperimentHarnessReportCommandRequest.valid(
        format: InternalBucketExperimentHarnessReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includePartial: false,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalBucketExperimentHarnessReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalBucketExperimentHarnessReportCommandRequest.invalid(
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
        return const InternalBucketExperimentHarnessReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includePartialFlag) {
      if (includePartialSeen) {
        return const InternalBucketExperimentHarnessReportCommandRequest.invalid(
          'duplicateIncludePartial',
        );
      }
      includePartial = true;
      includePartialSeen = true;
      continue;
    }
    return const InternalBucketExperimentHarnessReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalBucketExperimentHarnessReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includePartial: includePartial,
  );
}

int internalBucketExperimentHarnessReportExitCode(
  InternalBucketExperimentHarnessResult result,
  InternalBucketExperimentHarnessReportCommandRequest request,
) {
  if (result.hasUnsafeHarnessOutputPolicyViolation) {
    return internalBucketExperimentHarnessReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalBucketExperimentHarnessReportExitBlockedStrict;
  }
  return internalBucketExperimentHarnessReportExitSuccess;
}

InternalBucketExperimentHarnessReportFormat? _formatByWire(String value) {
  for (final format in InternalBucketExperimentHarnessReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Internal Bucket Experiment Harness report usage error: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/internal_bucket_experiment_harness_report.dart')
    ..writeln(
      '  dart run tool/internal_bucket_experiment_harness_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_bucket_experiment_harness_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_bucket_experiment_harness_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_bucket_experiment_harness_report.dart --include-partial',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln('  --safe-demo')
    ..writeln('  --include-partial');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includePartialFlag = '--include-partial';

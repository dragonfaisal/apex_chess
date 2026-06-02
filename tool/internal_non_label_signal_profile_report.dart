import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_harness.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';

const internalNonLabelSignalProfileReportExitSuccess = 0;
const internalNonLabelSignalProfileReportExitUsage = 64;
const internalNonLabelSignalProfileReportExitBlockedStrict = 68;
const internalNonLabelSignalProfileReportExitUnsafePolicy = 69;

class InternalNonLabelSignalProfileReportCommandResult {
  const InternalNonLabelSignalProfileReportCommandResult({
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
  final InternalNonLabelSignalProfileReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includePartial;
  final String stdoutText;
  final String stderrText;
  final InternalNonLabelSignalProfileResult? result;
  final String? commandFailure;
}

class InternalNonLabelSignalProfileReportCommandRequest {
  const InternalNonLabelSignalProfileReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includePartial,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalNonLabelSignalProfileReportCommandRequest.invalid(this.failure)
    : isValid = false,
      format = InternalNonLabelSignalProfileReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includePartial = false,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalNonLabelSignalProfileReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includePartial;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalNonLabelSignalProfileReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

InternalNonLabelSignalProfileReportCommandResult
runInternalNonLabelSignalProfileReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalNonLabelSignalProfilePrototype profile =
      const InternalNonLabelSignalProfilePrototype(),
  InternalNonLabelSignalProfileRequest? request,
}) {
  final commandRequest = validateInternalNonLabelSignalProfileReportArgs(args);
  if (!commandRequest.isValid) {
    return InternalNonLabelSignalProfileReportCommandResult(
      exitCode: internalNonLabelSignalProfileReportExitUsage,
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
    return InternalNonLabelSignalProfileReportCommandResult(
      exitCode: internalNonLabelSignalProfileReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includePartial: commandRequest.includePartial,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final profileRequest =
      request ??
      InternalNonLabelSignalProfileRequest(
        cases: cases,
        matrixRequest: InternalEvidenceAreaCoverageMatrixRequest(
          cases: cases,
          harnessRequest: InternalBucketExperimentHarnessRequest.safeDemo(
            cases: cases,
            includePartialBuckets: commandRequest.includePartial,
          ),
        ),
      );
  final result = profile.evaluate(profileRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalNonLabelSignalProfileReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalNonLabelSignalProfileReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return InternalNonLabelSignalProfileReportCommandResult(
    exitCode: internalNonLabelSignalProfileReportExitCode(
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

InternalNonLabelSignalProfileReportCommandRequest
validateInternalNonLabelSignalProfileReportArgs(List<String> args) {
  var format = InternalNonLabelSignalProfileReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includePartial = false;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includePartialSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalNonLabelSignalProfileReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalNonLabelSignalProfileReportCommandRequest.valid(
        format: InternalNonLabelSignalProfileReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includePartial: false,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalNonLabelSignalProfileReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalNonLabelSignalProfileReportCommandRequest.invalid(
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
        return const InternalNonLabelSignalProfileReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includePartialFlag) {
      if (includePartialSeen) {
        return const InternalNonLabelSignalProfileReportCommandRequest.invalid(
          'duplicateIncludePartial',
        );
      }
      includePartial = true;
      includePartialSeen = true;
      continue;
    }
    return const InternalNonLabelSignalProfileReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalNonLabelSignalProfileReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includePartial: includePartial,
  );
}

int internalNonLabelSignalProfileReportExitCode(
  InternalNonLabelSignalProfileResult result,
  InternalNonLabelSignalProfileReportCommandRequest request,
) {
  if (result.hasUnsafeSignalProfilePolicyViolation) {
    return internalNonLabelSignalProfileReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalNonLabelSignalProfileReportExitBlockedStrict;
  }
  return internalNonLabelSignalProfileReportExitSuccess;
}

InternalNonLabelSignalProfileReportFormat? _formatByWire(String value) {
  for (final format in InternalNonLabelSignalProfileReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Internal Non-Label Signal Profile report usage error: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/internal_non_label_signal_profile_report.dart')
    ..writeln(
      '  dart run tool/internal_non_label_signal_profile_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_non_label_signal_profile_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_non_label_signal_profile_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_non_label_signal_profile_report.dart --include-partial',
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

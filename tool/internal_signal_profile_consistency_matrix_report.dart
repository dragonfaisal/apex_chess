import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_harness.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_profile_consistency_matrix.dart';

const internalSignalProfileConsistencyMatrixReportExitSuccess = 0;
const internalSignalProfileConsistencyMatrixReportExitUsage = 64;
const internalSignalProfileConsistencyMatrixReportExitBlockedStrict = 68;
const internalSignalProfileConsistencyMatrixReportExitUnsafePolicy = 69;

class InternalSignalProfileConsistencyMatrixReportCommandResult {
  const InternalSignalProfileConsistencyMatrixReportCommandResult({
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
  final InternalSignalProfileConsistencyReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includePartial;
  final String stdoutText;
  final String stderrText;
  final InternalSignalProfileConsistencyMatrixResult? result;
  final String? commandFailure;
}

class InternalSignalProfileConsistencyMatrixReportCommandRequest {
  const InternalSignalProfileConsistencyMatrixReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includePartial,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalSignalProfileConsistencyMatrixReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = InternalSignalProfileConsistencyReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includePartial = false,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalSignalProfileConsistencyReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includePartial;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalSignalProfileConsistencyMatrixReportCommand(
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

InternalSignalProfileConsistencyMatrixReportCommandResult
runInternalSignalProfileConsistencyMatrixReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalSignalProfileConsistencyMatrix consistencyMatrix =
      const InternalSignalProfileConsistencyMatrix(),
  InternalSignalProfileConsistencyMatrixRequest? request,
}) {
  final commandRequest =
      validateInternalSignalProfileConsistencyMatrixReportArgs(args);
  if (!commandRequest.isValid) {
    return InternalSignalProfileConsistencyMatrixReportCommandResult(
      exitCode: internalSignalProfileConsistencyMatrixReportExitUsage,
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
    return InternalSignalProfileConsistencyMatrixReportCommandResult(
      exitCode: internalSignalProfileConsistencyMatrixReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includePartial: commandRequest.includePartial,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final profileRequest = InternalNonLabelSignalProfileRequest(
    cases: cases,
    matrixRequest: InternalEvidenceAreaCoverageMatrixRequest(
      cases: cases,
      harnessRequest: InternalBucketExperimentHarnessRequest.safeDemo(
        cases: cases,
        includePartialBuckets: commandRequest.includePartial,
      ),
    ),
  );
  final matrixRequest =
      request ??
      InternalSignalProfileConsistencyMatrixRequest(
        cases: cases,
        profileRequest: profileRequest,
      );
  final result = consistencyMatrix.evaluate(matrixRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalSignalProfileConsistencyReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalSignalProfileConsistencyReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return InternalSignalProfileConsistencyMatrixReportCommandResult(
    exitCode: internalSignalProfileConsistencyMatrixReportExitCode(
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

InternalSignalProfileConsistencyMatrixReportCommandRequest
validateInternalSignalProfileConsistencyMatrixReportArgs(List<String> args) {
  var format = InternalSignalProfileConsistencyReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includePartial = false;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includePartialSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalSignalProfileConsistencyMatrixReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalSignalProfileConsistencyMatrixReportCommandRequest.valid(
        format: InternalSignalProfileConsistencyReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includePartial: false,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalSignalProfileConsistencyMatrixReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalSignalProfileConsistencyMatrixReportCommandRequest.invalid(
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
        return const InternalSignalProfileConsistencyMatrixReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includePartialFlag) {
      if (includePartialSeen) {
        return const InternalSignalProfileConsistencyMatrixReportCommandRequest.invalid(
          'duplicateIncludePartial',
        );
      }
      includePartial = true;
      includePartialSeen = true;
      continue;
    }
    return const InternalSignalProfileConsistencyMatrixReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalSignalProfileConsistencyMatrixReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includePartial: includePartial,
  );
}

int internalSignalProfileConsistencyMatrixReportExitCode(
  InternalSignalProfileConsistencyMatrixResult result,
  InternalSignalProfileConsistencyMatrixReportCommandRequest request,
) {
  if (result.hasUnsafeConsistencyPolicyViolation) {
    return internalSignalProfileConsistencyMatrixReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalSignalProfileConsistencyMatrixReportExitBlockedStrict;
  }
  return internalSignalProfileConsistencyMatrixReportExitSuccess;
}

InternalSignalProfileConsistencyReportFormat? _formatByWire(String value) {
  for (final format in InternalSignalProfileConsistencyReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Internal Signal Profile Consistency Matrix report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/internal_signal_profile_consistency_matrix_report.dart',
    )
    ..writeln(
      '  dart run tool/internal_signal_profile_consistency_matrix_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_signal_profile_consistency_matrix_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_signal_profile_consistency_matrix_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_signal_profile_consistency_matrix_report.dart --include-partial',
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

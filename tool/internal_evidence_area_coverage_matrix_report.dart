import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_harness.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';

const internalEvidenceAreaCoverageMatrixReportExitSuccess = 0;
const internalEvidenceAreaCoverageMatrixReportExitUsage = 64;
const internalEvidenceAreaCoverageMatrixReportExitBlockedStrict = 68;
const internalEvidenceAreaCoverageMatrixReportExitUnsafePolicy = 69;

class InternalEvidenceAreaCoverageMatrixReportCommandResult {
  const InternalEvidenceAreaCoverageMatrixReportCommandResult({
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
  final InternalEvidenceAreaCoverageMatrixReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includePartial;
  final String stdoutText;
  final String stderrText;
  final InternalEvidenceAreaCoverageMatrixResult? result;
  final String? commandFailure;
}

class InternalEvidenceAreaCoverageMatrixReportCommandRequest {
  const InternalEvidenceAreaCoverageMatrixReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includePartial,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalEvidenceAreaCoverageMatrixReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = InternalEvidenceAreaCoverageMatrixReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includePartial = false,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalEvidenceAreaCoverageMatrixReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includePartial;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalEvidenceAreaCoverageMatrixReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

InternalEvidenceAreaCoverageMatrixReportCommandResult
runInternalEvidenceAreaCoverageMatrixReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalEvidenceAreaCoverageMatrix matrix =
      const InternalEvidenceAreaCoverageMatrix(),
  InternalEvidenceAreaCoverageMatrixRequest? request,
}) {
  final commandRequest = validateInternalEvidenceAreaCoverageMatrixReportArgs(
    args,
  );
  if (!commandRequest.isValid) {
    return InternalEvidenceAreaCoverageMatrixReportCommandResult(
      exitCode: internalEvidenceAreaCoverageMatrixReportExitUsage,
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
    return InternalEvidenceAreaCoverageMatrixReportCommandResult(
      exitCode: internalEvidenceAreaCoverageMatrixReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includePartial: commandRequest.includePartial,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final matrixRequest =
      request ??
      InternalEvidenceAreaCoverageMatrixRequest(
        cases: cases,
        harnessRequest: InternalBucketExperimentHarnessRequest.safeDemo(
          cases: cases,
          includePartialBuckets: commandRequest.includePartial,
        ),
      );
  final result = matrix.evaluate(matrixRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalEvidenceAreaCoverageMatrixReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalEvidenceAreaCoverageMatrixReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return InternalEvidenceAreaCoverageMatrixReportCommandResult(
    exitCode: internalEvidenceAreaCoverageMatrixReportExitCode(
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

InternalEvidenceAreaCoverageMatrixReportCommandRequest
validateInternalEvidenceAreaCoverageMatrixReportArgs(List<String> args) {
  var format = InternalEvidenceAreaCoverageMatrixReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includePartial = false;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includePartialSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalEvidenceAreaCoverageMatrixReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalEvidenceAreaCoverageMatrixReportCommandRequest.valid(
        format: InternalEvidenceAreaCoverageMatrixReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includePartial: false,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalEvidenceAreaCoverageMatrixReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalEvidenceAreaCoverageMatrixReportCommandRequest.invalid(
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
        return const InternalEvidenceAreaCoverageMatrixReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includePartialFlag) {
      if (includePartialSeen) {
        return const InternalEvidenceAreaCoverageMatrixReportCommandRequest.invalid(
          'duplicateIncludePartial',
        );
      }
      includePartial = true;
      includePartialSeen = true;
      continue;
    }
    return const InternalEvidenceAreaCoverageMatrixReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalEvidenceAreaCoverageMatrixReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includePartial: includePartial,
  );
}

int internalEvidenceAreaCoverageMatrixReportExitCode(
  InternalEvidenceAreaCoverageMatrixResult result,
  InternalEvidenceAreaCoverageMatrixReportCommandRequest request,
) {
  if (result.hasUnsafeMatrixPolicyViolation) {
    return internalEvidenceAreaCoverageMatrixReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalEvidenceAreaCoverageMatrixReportExitBlockedStrict;
  }
  return internalEvidenceAreaCoverageMatrixReportExitSuccess;
}

InternalEvidenceAreaCoverageMatrixReportFormat? _formatByWire(String value) {
  for (final format in InternalEvidenceAreaCoverageMatrixReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Internal Evidence Area Coverage Matrix report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/internal_evidence_area_coverage_matrix_report.dart',
    )
    ..writeln(
      '  dart run tool/internal_evidence_area_coverage_matrix_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_evidence_area_coverage_matrix_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_evidence_area_coverage_matrix_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_evidence_area_coverage_matrix_report.dart --include-partial',
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

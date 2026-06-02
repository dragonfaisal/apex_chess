import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';

const internalEvidenceBucketsReportExitSuccess = 0;
const internalEvidenceBucketsReportExitUsage = 64;
const internalEvidenceBucketsReportExitBlockedStrict = 68;
const internalEvidenceBucketsReportExitUnsafePolicy = 69;

class InternalEvidenceBucketsReportCommandResult {
  const InternalEvidenceBucketsReportCommandResult({
    required this.exitCode,
    required this.format,
    required this.strict,
    required this.stdoutText,
    required this.stderrText,
    this.result,
    this.commandFailure,
  });

  final int exitCode;
  final InternalEvidenceBucketsReportFormat format;
  final bool strict;
  final String stdoutText;
  final String stderrText;
  final InternalEvidenceBucketPrototype? result;
  final String? commandFailure;
}

class InternalEvidenceBucketsReportCommandRequest {
  const InternalEvidenceBucketsReportCommandRequest.valid({
    required this.format,
    required this.strict,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalEvidenceBucketsReportCommandRequest.invalid(this.failure)
    : isValid = false,
      format = InternalEvidenceBucketsReportFormat.markdown,
      strict = false,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalEvidenceBucketsReportFormat format;
  final bool strict;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalEvidenceBucketsReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

InternalEvidenceBucketsReportCommandResult
runInternalEvidenceBucketsReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalEvidenceBucketBuilder builder = const InternalEvidenceBucketBuilder(),
}) {
  final request = validateInternalEvidenceBucketsReportArgs(args);
  if (!request.isValid) {
    return InternalEvidenceBucketsReportCommandResult(
      exitCode: internalEvidenceBucketsReportExitUsage,
      format: request.format,
      strict: request.strict,
      stdoutText: '',
      stderrText: _usage(request.failure),
      commandFailure: request.failure,
    );
  }
  if (request.showHelp) {
    return InternalEvidenceBucketsReportCommandResult(
      exitCode: internalEvidenceBucketsReportExitSuccess,
      format: request.format,
      strict: request.strict,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = builder.evaluate(InternalEvidenceBucketRequest(cases: cases));
  final stdoutText = switch (request.format) {
    InternalEvidenceBucketsReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalEvidenceBucketsReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return InternalEvidenceBucketsReportCommandResult(
    exitCode: internalEvidenceBucketsReportExitCode(result, request),
    format: request.format,
    strict: request.strict,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

InternalEvidenceBucketsReportCommandRequest
validateInternalEvidenceBucketsReportArgs(List<String> args) {
  var format = InternalEvidenceBucketsReportFormat.markdown;
  var strict = false;
  var formatSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalEvidenceBucketsReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalEvidenceBucketsReportCommandRequest.valid(
        format: InternalEvidenceBucketsReportFormat.markdown,
        strict: false,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalEvidenceBucketsReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalEvidenceBucketsReportCommandRequest.invalid(
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
    return const InternalEvidenceBucketsReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalEvidenceBucketsReportCommandRequest.valid(
    format: format,
    strict: strict,
  );
}

int internalEvidenceBucketsReportExitCode(
  InternalEvidenceBucketPrototype result,
  InternalEvidenceBucketsReportCommandRequest request,
) {
  if (result.hasUnsafeBucketPolicyViolation) {
    return internalEvidenceBucketsReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalEvidenceBucketsReportExitBlockedStrict;
  }
  return internalEvidenceBucketsReportExitSuccess;
}

InternalEvidenceBucketsReportFormat? _formatByWire(String value) {
  for (final format in InternalEvidenceBucketsReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Internal Evidence Buckets report command usage error: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/internal_evidence_buckets_report.dart')
    ..writeln(
      '  dart run tool/internal_evidence_buckets_report.dart --format=json',
    )
    ..writeln('  dart run tool/internal_evidence_buckets_report.dart --strict')
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _strictFlag = '--strict';

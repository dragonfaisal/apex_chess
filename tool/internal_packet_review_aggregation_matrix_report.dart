import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_review_aggregation_matrix.dart';

const internalPacketReviewAggregationMatrixReportExitSuccess = 0;
const internalPacketReviewAggregationMatrixReportExitUsage = 64;
const internalPacketReviewAggregationMatrixReportExitBlockedStrict = 68;
const internalPacketReviewAggregationMatrixReportExitUnsafePolicy = 69;

class InternalPacketReviewAggregationMatrixReportCommandResult {
  const InternalPacketReviewAggregationMatrixReportCommandResult({
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
  final InternalPacketReviewAggregationMatrixReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final InternalPacketReviewAggregationMatrixResult? result;
  final String? commandFailure;
}

class InternalPacketReviewAggregationMatrixReportCommandRequest {
  const InternalPacketReviewAggregationMatrixReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalPacketReviewAggregationMatrixReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = InternalPacketReviewAggregationMatrixReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalPacketReviewAggregationMatrixReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalPacketReviewAggregationMatrixReportCommand(
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

InternalPacketReviewAggregationMatrixReportCommandResult
runInternalPacketReviewAggregationMatrixReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalPacketReviewAggregationMatrix matrix =
      const InternalPacketReviewAggregationMatrix(),
  InternalPacketReviewAggregationMatrixRequest? request,
}) {
  final commandRequest =
      validateInternalPacketReviewAggregationMatrixReportArgs(args);
  if (!commandRequest.isValid) {
    return InternalPacketReviewAggregationMatrixReportCommandResult(
      exitCode: internalPacketReviewAggregationMatrixReportExitUsage,
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
    return InternalPacketReviewAggregationMatrixReportCommandResult(
      exitCode: internalPacketReviewAggregationMatrixReportExitSuccess,
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
      InternalPacketReviewAggregationMatrixRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = matrix.evaluate(matrixRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalPacketReviewAggregationMatrixReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalPacketReviewAggregationMatrixReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return InternalPacketReviewAggregationMatrixReportCommandResult(
    exitCode: internalPacketReviewAggregationMatrixReportExitCode(
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

InternalPacketReviewAggregationMatrixReportCommandRequest
validateInternalPacketReviewAggregationMatrixReportArgs(List<String> args) {
  var format = InternalPacketReviewAggregationMatrixReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalPacketReviewAggregationMatrixReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalPacketReviewAggregationMatrixReportCommandRequest.valid(
        format: InternalPacketReviewAggregationMatrixReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalPacketReviewAggregationMatrixReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalPacketReviewAggregationMatrixReportCommandRequest.invalid(
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
        return const InternalPacketReviewAggregationMatrixReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const InternalPacketReviewAggregationMatrixReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const InternalPacketReviewAggregationMatrixReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalPacketReviewAggregationMatrixReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int internalPacketReviewAggregationMatrixReportExitCode(
  InternalPacketReviewAggregationMatrixResult result,
  InternalPacketReviewAggregationMatrixReportCommandRequest request,
) {
  if (result.hasUnsafeMatrixPolicyViolation) {
    return internalPacketReviewAggregationMatrixReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalPacketReviewAggregationMatrixReportExitBlockedStrict;
  }
  return internalPacketReviewAggregationMatrixReportExitSuccess;
}

InternalPacketReviewAggregationMatrixReportFormat? _formatByWire(String value) {
  for (final format
      in InternalPacketReviewAggregationMatrixReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Internal Packet Review Aggregation Matrix report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/internal_packet_review_aggregation_matrix_report.dart',
    )
    ..writeln(
      '  dart run tool/internal_packet_review_aggregation_matrix_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_packet_review_aggregation_matrix_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_packet_review_aggregation_matrix_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_packet_review_aggregation_matrix_report.dart --include-warnings',
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

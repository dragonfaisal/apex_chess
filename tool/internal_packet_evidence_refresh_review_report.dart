import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_refresh_review.dart';

const internalPacketEvidenceRefreshReviewReportExitSuccess = 0;
const internalPacketEvidenceRefreshReviewReportExitUsage = 64;
const internalPacketEvidenceRefreshReviewReportExitBlockedStrict = 68;
const internalPacketEvidenceRefreshReviewReportExitUnsafePolicy = 69;

class InternalPacketEvidenceRefreshReviewReportCommandResult {
  const InternalPacketEvidenceRefreshReviewReportCommandResult({
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
  final InternalPacketEvidenceRefreshReviewReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final InternalPacketEvidenceRefreshReviewResult? result;
  final String? commandFailure;
}

class InternalPacketEvidenceRefreshReviewReportCommandRequest {
  const InternalPacketEvidenceRefreshReviewReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalPacketEvidenceRefreshReviewReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = InternalPacketEvidenceRefreshReviewReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalPacketEvidenceRefreshReviewReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalPacketEvidenceRefreshReviewReportCommand(
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

InternalPacketEvidenceRefreshReviewReportCommandResult
runInternalPacketEvidenceRefreshReviewReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalPacketEvidenceRefreshReview review =
      const InternalPacketEvidenceRefreshReview(),
  InternalPacketEvidenceRefreshReviewRequest? request,
}) {
  final commandRequest = validateInternalPacketEvidenceRefreshReviewReportArgs(
    args,
  );
  if (!commandRequest.isValid) {
    return InternalPacketEvidenceRefreshReviewReportCommandResult(
      exitCode: internalPacketEvidenceRefreshReviewReportExitUsage,
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
    return InternalPacketEvidenceRefreshReviewReportCommandResult(
      exitCode: internalPacketEvidenceRefreshReviewReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final reviewRequest =
      request ??
      InternalPacketEvidenceRefreshReviewRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = review.evaluate(reviewRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalPacketEvidenceRefreshReviewReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalPacketEvidenceRefreshReviewReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return InternalPacketEvidenceRefreshReviewReportCommandResult(
    exitCode: internalPacketEvidenceRefreshReviewReportExitCode(
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

InternalPacketEvidenceRefreshReviewReportCommandRequest
validateInternalPacketEvidenceRefreshReviewReportArgs(List<String> args) {
  var format = InternalPacketEvidenceRefreshReviewReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalPacketEvidenceRefreshReviewReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalPacketEvidenceRefreshReviewReportCommandRequest.valid(
        format: InternalPacketEvidenceRefreshReviewReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalPacketEvidenceRefreshReviewReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalPacketEvidenceRefreshReviewReportCommandRequest.invalid(
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
        return const InternalPacketEvidenceRefreshReviewReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const InternalPacketEvidenceRefreshReviewReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const InternalPacketEvidenceRefreshReviewReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalPacketEvidenceRefreshReviewReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int internalPacketEvidenceRefreshReviewReportExitCode(
  InternalPacketEvidenceRefreshReviewResult result,
  InternalPacketEvidenceRefreshReviewReportCommandRequest request,
) {
  if (result.hasUnsafeReviewPolicyViolation) {
    return internalPacketEvidenceRefreshReviewReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalPacketEvidenceRefreshReviewReportExitBlockedStrict;
  }
  return internalPacketEvidenceRefreshReviewReportExitSuccess;
}

InternalPacketEvidenceRefreshReviewReportFormat? _formatByWire(String value) {
  for (final format in InternalPacketEvidenceRefreshReviewReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Internal Packet Evidence Refresh Review report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/internal_packet_evidence_refresh_review_report.dart',
    )
    ..writeln(
      '  dart run tool/internal_packet_evidence_refresh_review_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_packet_evidence_refresh_review_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_packet_evidence_refresh_review_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_packet_evidence_refresh_review_report.dart --include-warnings',
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

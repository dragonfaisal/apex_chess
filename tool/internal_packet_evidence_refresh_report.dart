import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_refresh.dart';

const internalPacketEvidenceRefreshReportExitSuccess = 0;
const internalPacketEvidenceRefreshReportExitUsage = 64;
const internalPacketEvidenceRefreshReportExitBlockedStrict = 68;
const internalPacketEvidenceRefreshReportExitUnsafePolicy = 69;

class InternalPacketEvidenceRefreshReportCommandResult {
  const InternalPacketEvidenceRefreshReportCommandResult({
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
  final InternalPacketEvidenceRefreshReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final InternalPacketEvidenceRefreshResult? result;
  final String? commandFailure;
}

class InternalPacketEvidenceRefreshReportCommandRequest {
  const InternalPacketEvidenceRefreshReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalPacketEvidenceRefreshReportCommandRequest.invalid(this.failure)
    : isValid = false,
      format = InternalPacketEvidenceRefreshReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalPacketEvidenceRefreshReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalPacketEvidenceRefreshReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

InternalPacketEvidenceRefreshReportCommandResult
runInternalPacketEvidenceRefreshReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalPacketEvidenceRefresh refresh = const InternalPacketEvidenceRefresh(),
  InternalPacketEvidenceRefreshRequest? request,
}) {
  final commandRequest = validateInternalPacketEvidenceRefreshReportArgs(args);
  if (!commandRequest.isValid) {
    return InternalPacketEvidenceRefreshReportCommandResult(
      exitCode: internalPacketEvidenceRefreshReportExitUsage,
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
    return InternalPacketEvidenceRefreshReportCommandResult(
      exitCode: internalPacketEvidenceRefreshReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final refreshRequest =
      request ??
      InternalPacketEvidenceRefreshRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = refresh.evaluate(refreshRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalPacketEvidenceRefreshReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalPacketEvidenceRefreshReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return InternalPacketEvidenceRefreshReportCommandResult(
    exitCode: internalPacketEvidenceRefreshReportExitCode(
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

InternalPacketEvidenceRefreshReportCommandRequest
validateInternalPacketEvidenceRefreshReportArgs(List<String> args) {
  var format = InternalPacketEvidenceRefreshReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalPacketEvidenceRefreshReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalPacketEvidenceRefreshReportCommandRequest.valid(
        format: InternalPacketEvidenceRefreshReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalPacketEvidenceRefreshReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalPacketEvidenceRefreshReportCommandRequest.invalid(
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
        return const InternalPacketEvidenceRefreshReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const InternalPacketEvidenceRefreshReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const InternalPacketEvidenceRefreshReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalPacketEvidenceRefreshReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int internalPacketEvidenceRefreshReportExitCode(
  InternalPacketEvidenceRefreshResult result,
  InternalPacketEvidenceRefreshReportCommandRequest request,
) {
  if (result.hasUnsafeRefreshPolicyViolation) {
    return internalPacketEvidenceRefreshReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalPacketEvidenceRefreshReportExitBlockedStrict;
  }
  return internalPacketEvidenceRefreshReportExitSuccess;
}

InternalPacketEvidenceRefreshReportFormat? _formatByWire(String value) {
  for (final format in InternalPacketEvidenceRefreshReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Internal Packet Evidence Refresh report usage error: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/internal_packet_evidence_refresh_report.dart')
    ..writeln(
      '  dart run tool/internal_packet_evidence_refresh_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_packet_evidence_refresh_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_packet_evidence_refresh_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_packet_evidence_refresh_report.dart --include-warnings',
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

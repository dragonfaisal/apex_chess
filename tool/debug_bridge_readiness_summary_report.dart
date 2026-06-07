import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugBridgeReadinessSummaryReportExitSuccess = 0;
const debugBridgeReadinessSummaryReportExitUsage = 64;
const debugBridgeReadinessSummaryReportExitBlockedStrict = 68;
const debugBridgeReadinessSummaryReportExitUnsafePolicy = 69;

class DebugBridgeReadinessSummaryReportCommandResult {
  const DebugBridgeReadinessSummaryReportCommandResult({
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
  final DebugBridgeReadinessSummaryReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugBridgeReadinessSummaryResult? result;
  final String? commandFailure;
}

class DebugBridgeReadinessSummaryReportCommandRequest {
  const DebugBridgeReadinessSummaryReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const DebugBridgeReadinessSummaryReportCommandRequest.invalid(this.failure)
    : isValid = false,
      format = DebugBridgeReadinessSummaryReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugBridgeReadinessSummaryReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runDebugBridgeReadinessSummaryReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

DebugBridgeReadinessSummaryReportCommandResult
runDebugBridgeReadinessSummaryReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  DebugBridgeReadinessSummary summary = const DebugBridgeReadinessSummary(),
  DebugBridgeReadinessSummaryRequest? request,
}) {
  final commandRequest = validateDebugBridgeReadinessSummaryReportArgs(args);
  if (!commandRequest.isValid) {
    return DebugBridgeReadinessSummaryReportCommandResult(
      exitCode: debugBridgeReadinessSummaryReportExitUsage,
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
    return DebugBridgeReadinessSummaryReportCommandResult(
      exitCode: debugBridgeReadinessSummaryReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final summaryRequest =
      request ??
      DebugBridgeReadinessSummaryRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = summary.evaluate(summaryRequest);
  final stdoutText = switch (commandRequest.format) {
    DebugBridgeReadinessSummaryReportFormat.markdown =>
      result.renderMarkdownReport(),
    DebugBridgeReadinessSummaryReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings = const DebugBridgeReadinessSummaryValidator()
      .validateReportText(stdoutText);

  return DebugBridgeReadinessSummaryReportCommandResult(
    exitCode: debugBridgeReadinessSummaryReportExitCode(
      result,
      commandRequest,
      reportFindings: reportFindings,
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

DebugBridgeReadinessSummaryReportCommandRequest
validateDebugBridgeReadinessSummaryReportArgs(List<String> args) {
  var format = DebugBridgeReadinessSummaryReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const DebugBridgeReadinessSummaryReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const DebugBridgeReadinessSummaryReportCommandRequest.valid(
        format: DebugBridgeReadinessSummaryReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const DebugBridgeReadinessSummaryReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const DebugBridgeReadinessSummaryReportCommandRequest.invalid(
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
        return const DebugBridgeReadinessSummaryReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const DebugBridgeReadinessSummaryReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const DebugBridgeReadinessSummaryReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return DebugBridgeReadinessSummaryReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int debugBridgeReadinessSummaryReportExitCode(
  DebugBridgeReadinessSummaryResult result,
  DebugBridgeReadinessSummaryReportCommandRequest request, {
  List<DebugBridgeReadinessSummaryFinding> reportFindings =
      const <DebugBridgeReadinessSummaryFinding>[],
}) {
  if (result.hasUnsafeDebugBridgeReadinessSummaryPolicyViolation ||
      reportFindings.any((finding) => finding.isCritical)) {
    return debugBridgeReadinessSummaryReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return debugBridgeReadinessSummaryReportExitBlockedStrict;
  }
  return debugBridgeReadinessSummaryReportExitSuccess;
}

DebugBridgeReadinessSummaryReportFormat? _formatByWire(String value) {
  for (final format in DebugBridgeReadinessSummaryReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Debug Bridge Readiness Summary report usage error: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/debug_bridge_readiness_summary_report.dart')
    ..writeln(
      '  dart run tool/debug_bridge_readiness_summary_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/debug_bridge_readiness_summary_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/debug_bridge_readiness_summary_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/debug_bridge_readiness_summary_report.dart --include-warnings',
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

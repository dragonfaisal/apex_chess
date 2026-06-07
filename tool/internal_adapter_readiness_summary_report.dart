import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_adapter_readiness_summary.dart';

const internalAdapterReadinessSummaryReportExitSuccess = 0;
const internalAdapterReadinessSummaryReportExitUsage = 64;
const internalAdapterReadinessSummaryReportExitBlockedStrict = 68;
const internalAdapterReadinessSummaryReportExitUnsafePolicy = 69;

class InternalAdapterReadinessSummaryReportCommandResult {
  const InternalAdapterReadinessSummaryReportCommandResult({
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
  final InternalAdapterReadinessSummaryReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final InternalAdapterReadinessSummaryResult? result;
  final String? commandFailure;
}

class InternalAdapterReadinessSummaryReportCommandRequest {
  const InternalAdapterReadinessSummaryReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalAdapterReadinessSummaryReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = InternalAdapterReadinessSummaryReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalAdapterReadinessSummaryReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalAdapterReadinessSummaryReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

InternalAdapterReadinessSummaryReportCommandResult
runInternalAdapterReadinessSummaryReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalAdapterReadinessSummary summary =
      const InternalAdapterReadinessSummary(),
  InternalAdapterReadinessSummaryRequest? request,
}) {
  final commandRequest = validateInternalAdapterReadinessSummaryReportArgs(
    args,
  );
  if (!commandRequest.isValid) {
    return InternalAdapterReadinessSummaryReportCommandResult(
      exitCode: internalAdapterReadinessSummaryReportExitUsage,
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
    return InternalAdapterReadinessSummaryReportCommandResult(
      exitCode: internalAdapterReadinessSummaryReportExitSuccess,
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
      InternalAdapterReadinessSummaryRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = summary.evaluate(summaryRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalAdapterReadinessSummaryReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalAdapterReadinessSummaryReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings = const InternalAdapterReadinessSummaryValidator()
      .validateReportText(stdoutText);

  return InternalAdapterReadinessSummaryReportCommandResult(
    exitCode: internalAdapterReadinessSummaryReportExitCode(
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

InternalAdapterReadinessSummaryReportCommandRequest
validateInternalAdapterReadinessSummaryReportArgs(List<String> args) {
  var format = InternalAdapterReadinessSummaryReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalAdapterReadinessSummaryReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalAdapterReadinessSummaryReportCommandRequest.valid(
        format: InternalAdapterReadinessSummaryReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalAdapterReadinessSummaryReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalAdapterReadinessSummaryReportCommandRequest.invalid(
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
        return const InternalAdapterReadinessSummaryReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const InternalAdapterReadinessSummaryReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const InternalAdapterReadinessSummaryReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalAdapterReadinessSummaryReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int internalAdapterReadinessSummaryReportExitCode(
  InternalAdapterReadinessSummaryResult result,
  InternalAdapterReadinessSummaryReportCommandRequest request, {
  List<InternalAdapterReadinessSummaryFinding> reportFindings =
      const <InternalAdapterReadinessSummaryFinding>[],
}) {
  if (result.hasUnsafeAdapterSummaryPolicyViolation ||
      reportFindings.any((finding) => finding.isCritical)) {
    return internalAdapterReadinessSummaryReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalAdapterReadinessSummaryReportExitBlockedStrict;
  }
  return internalAdapterReadinessSummaryReportExitSuccess;
}

InternalAdapterReadinessSummaryReportFormat? _formatByWire(String value) {
  for (final format in InternalAdapterReadinessSummaryReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Internal Adapter Readiness Summary report usage error: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/internal_adapter_readiness_summary_report.dart')
    ..writeln(
      '  dart run tool/internal_adapter_readiness_summary_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_adapter_readiness_summary_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_adapter_readiness_summary_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_adapter_readiness_summary_report.dart --include-warnings',
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

import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugBridgePrototypeDesignReadinessSummaryReportExitSuccess = 0;
const debugBridgePrototypeDesignReadinessSummaryReportExitUsage = 64;
const debugBridgePrototypeDesignReadinessSummaryReportExitBlockedStrict = 68;
const debugBridgePrototypeDesignReadinessSummaryReportExitUnsafePolicy = 69;

class DebugBridgePrototypeDesignReadinessSummaryReportCommandResult {
  const DebugBridgePrototypeDesignReadinessSummaryReportCommandResult({
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
  final DebugBridgePrototypeDesignReadinessSummaryReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugBridgePrototypeDesignReadinessSummaryResult? result;
  final String? commandFailure;
}

class DebugBridgePrototypeDesignReadinessSummaryReportCommandRequest {
  const DebugBridgePrototypeDesignReadinessSummaryReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const DebugBridgePrototypeDesignReadinessSummaryReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = DebugBridgePrototypeDesignReadinessSummaryReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugBridgePrototypeDesignReadinessSummaryReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runDebugBridgePrototypeDesignReadinessSummaryReportCommand(
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

DebugBridgePrototypeDesignReadinessSummaryReportCommandResult
runDebugBridgePrototypeDesignReadinessSummaryReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  DebugBridgePrototypeDesignReadinessSummary summary =
      const DebugBridgePrototypeDesignReadinessSummary(),
  DebugBridgePrototypeDesignReadinessSummaryRequest? request,
}) {
  final commandRequest =
      validateDebugBridgePrototypeDesignReadinessSummaryReportArgs(args);
  if (!commandRequest.isValid) {
    return DebugBridgePrototypeDesignReadinessSummaryReportCommandResult(
      exitCode: debugBridgePrototypeDesignReadinessSummaryReportExitUsage,
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
    return DebugBridgePrototypeDesignReadinessSummaryReportCommandResult(
      exitCode: debugBridgePrototypeDesignReadinessSummaryReportExitSuccess,
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
      DebugBridgePrototypeDesignReadinessSummaryRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = summary.evaluate(summaryRequest);
  final stdoutText = switch (commandRequest.format) {
    DebugBridgePrototypeDesignReadinessSummaryReportFormat.markdown =>
      result.renderMarkdownReport(),
    DebugBridgePrototypeDesignReadinessSummaryReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings =
      const DebugBridgePrototypeDesignReadinessSummaryValidator()
          .validateReportText(stdoutText);

  return DebugBridgePrototypeDesignReadinessSummaryReportCommandResult(
    exitCode: debugBridgePrototypeDesignReadinessSummaryReportExitCode(
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

DebugBridgePrototypeDesignReadinessSummaryReportCommandRequest
validateDebugBridgePrototypeDesignReadinessSummaryReportArgs(
  List<String> args,
) {
  var format = DebugBridgePrototypeDesignReadinessSummaryReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const DebugBridgePrototypeDesignReadinessSummaryReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const DebugBridgePrototypeDesignReadinessSummaryReportCommandRequest.valid(
        format: DebugBridgePrototypeDesignReadinessSummaryReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const DebugBridgePrototypeDesignReadinessSummaryReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const DebugBridgePrototypeDesignReadinessSummaryReportCommandRequest.invalid(
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
        return const DebugBridgePrototypeDesignReadinessSummaryReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const DebugBridgePrototypeDesignReadinessSummaryReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const DebugBridgePrototypeDesignReadinessSummaryReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return DebugBridgePrototypeDesignReadinessSummaryReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int debugBridgePrototypeDesignReadinessSummaryReportExitCode(
  DebugBridgePrototypeDesignReadinessSummaryResult result,
  DebugBridgePrototypeDesignReadinessSummaryReportCommandRequest request, {
  List<DebugBridgePrototypeDesignReadinessSummaryFinding> reportFindings =
      const <DebugBridgePrototypeDesignReadinessSummaryFinding>[],
}) {
  if (result
          .hasUnsafeDebugBridgePrototypeDesignReadinessSummaryPolicyViolation ||
      reportFindings.any((finding) => finding.isCritical)) {
    return debugBridgePrototypeDesignReadinessSummaryReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return debugBridgePrototypeDesignReadinessSummaryReportExitBlockedStrict;
  }
  return debugBridgePrototypeDesignReadinessSummaryReportExitSuccess;
}

DebugBridgePrototypeDesignReadinessSummaryReportFormat? _formatByWire(
  String value,
) {
  for (final format
      in DebugBridgePrototypeDesignReadinessSummaryReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Debug Bridge Prototype Design Readiness Summary report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/debug_bridge_prototype_design_readiness_summary_report.dart',
    )
    ..writeln(
      '  dart run tool/debug_bridge_prototype_design_readiness_summary_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/debug_bridge_prototype_design_readiness_summary_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/debug_bridge_prototype_design_readiness_summary_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/debug_bridge_prototype_design_readiness_summary_report.dart --include-warnings',
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

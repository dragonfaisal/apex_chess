import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_summary_validation.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugBridgeReadinessSummaryValidationReportExitSuccess = 0;
const debugBridgeReadinessSummaryValidationReportExitUsage = 64;
const debugBridgeReadinessSummaryValidationReportExitBlockedStrict = 68;
const debugBridgeReadinessSummaryValidationReportExitUnsafePolicy = 69;

class DebugBridgeReadinessSummaryValidationReportCommandResult {
  const DebugBridgeReadinessSummaryValidationReportCommandResult({
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
  final DebugBridgeReadinessSummaryValidationReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugBridgeReadinessSummaryValidationResult? result;
  final String? commandFailure;
}

class DebugBridgeReadinessSummaryValidationReportCommandRequest {
  const DebugBridgeReadinessSummaryValidationReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const DebugBridgeReadinessSummaryValidationReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = DebugBridgeReadinessSummaryValidationReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugBridgeReadinessSummaryValidationReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runDebugBridgeReadinessSummaryValidationReportCommand(
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

DebugBridgeReadinessSummaryValidationReportCommandResult
runDebugBridgeReadinessSummaryValidationReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  DebugBridgeReadinessSummaryValidation validation =
      const DebugBridgeReadinessSummaryValidation(),
  DebugBridgeReadinessSummaryValidationRequest? request,
}) {
  final commandRequest =
      validateDebugBridgeReadinessSummaryValidationReportArgs(args);
  if (!commandRequest.isValid) {
    return DebugBridgeReadinessSummaryValidationReportCommandResult(
      exitCode: debugBridgeReadinessSummaryValidationReportExitUsage,
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
    return DebugBridgeReadinessSummaryValidationReportCommandResult(
      exitCode: debugBridgeReadinessSummaryValidationReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final validationRequest =
      request ??
      DebugBridgeReadinessSummaryValidationRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = validation.evaluate(validationRequest);
  final stdoutText = switch (commandRequest.format) {
    DebugBridgeReadinessSummaryValidationReportFormat.markdown =>
      result.renderMarkdownReport(),
    DebugBridgeReadinessSummaryValidationReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings = const DebugBridgeReadinessSummaryValidationValidator()
      .validateReportText(stdoutText);

  return DebugBridgeReadinessSummaryValidationReportCommandResult(
    exitCode: debugBridgeReadinessSummaryValidationReportExitCode(
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

DebugBridgeReadinessSummaryValidationReportCommandRequest
validateDebugBridgeReadinessSummaryValidationReportArgs(List<String> args) {
  var format = DebugBridgeReadinessSummaryValidationReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const DebugBridgeReadinessSummaryValidationReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const DebugBridgeReadinessSummaryValidationReportCommandRequest.valid(
        format: DebugBridgeReadinessSummaryValidationReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const DebugBridgeReadinessSummaryValidationReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const DebugBridgeReadinessSummaryValidationReportCommandRequest.invalid(
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
        return const DebugBridgeReadinessSummaryValidationReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const DebugBridgeReadinessSummaryValidationReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const DebugBridgeReadinessSummaryValidationReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return DebugBridgeReadinessSummaryValidationReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int debugBridgeReadinessSummaryValidationReportExitCode(
  DebugBridgeReadinessSummaryValidationResult result,
  DebugBridgeReadinessSummaryValidationReportCommandRequest request, {
  List<DebugBridgeReadinessSummaryValidationFinding> reportFindings =
      const <DebugBridgeReadinessSummaryValidationFinding>[],
}) {
  if (result.hasUnsafeDebugBridgeReadinessSummaryValidationPolicyViolation ||
      reportFindings.any((finding) => finding.isCritical)) {
    return debugBridgeReadinessSummaryValidationReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return debugBridgeReadinessSummaryValidationReportExitBlockedStrict;
  }
  return debugBridgeReadinessSummaryValidationReportExitSuccess;
}

DebugBridgeReadinessSummaryValidationReportFormat? _formatByWire(String value) {
  for (final format
      in DebugBridgeReadinessSummaryValidationReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Debug Bridge Readiness Summary Validation report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/debug_bridge_readiness_summary_validation_report.dart',
    )
    ..writeln(
      '  dart run tool/debug_bridge_readiness_summary_validation_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/debug_bridge_readiness_summary_validation_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/debug_bridge_readiness_summary_validation_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/debug_bridge_readiness_summary_validation_report.dart --include-warnings',
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

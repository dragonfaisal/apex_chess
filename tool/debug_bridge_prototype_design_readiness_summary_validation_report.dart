import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_summary_validation.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugBridgePrototypeDesignReadinessSummaryValidationReportExitSuccess = 0;
const debugBridgePrototypeDesignReadinessSummaryValidationReportExitUsage = 64;
const debugBridgePrototypeDesignReadinessSummaryValidationReportExitBlockedStrict =
    68;
const debugBridgePrototypeDesignReadinessSummaryValidationReportExitUnsafePolicy =
    69;

class DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandResult {
  const DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandResult({
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
  final DebugBridgePrototypeDesignReadinessSummaryValidationReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugBridgePrototypeDesignReadinessSummaryValidationResult? result;
  final String? commandFailure;
}

class DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandRequest {
  const DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = DebugBridgePrototypeDesignReadinessSummaryValidationReportFormat
          .markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugBridgePrototypeDesignReadinessSummaryValidationReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result =
      runDebugBridgePrototypeDesignReadinessSummaryValidationReportCommand(
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

DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandResult
runDebugBridgePrototypeDesignReadinessSummaryValidationReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  DebugBridgePrototypeDesignReadinessSummaryValidation validation =
      const DebugBridgePrototypeDesignReadinessSummaryValidation(),
  DebugBridgePrototypeDesignReadinessSummaryValidationRequest? request,
}) {
  final commandRequest =
      validateDebugBridgePrototypeDesignReadinessSummaryValidationReportArgs(
        args,
      );
  if (!commandRequest.isValid) {
    return DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandResult(
      exitCode:
          debugBridgePrototypeDesignReadinessSummaryValidationReportExitUsage,
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
    return DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandResult(
      exitCode:
          debugBridgePrototypeDesignReadinessSummaryValidationReportExitSuccess,
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
      DebugBridgePrototypeDesignReadinessSummaryValidationRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = validation.evaluate(validationRequest);
  final stdoutText = switch (commandRequest.format) {
    DebugBridgePrototypeDesignReadinessSummaryValidationReportFormat.markdown =>
      result.renderMarkdownReport(),
    DebugBridgePrototypeDesignReadinessSummaryValidationReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings =
      const DebugBridgePrototypeDesignReadinessSummaryValidationValidator()
          .validateReportText(stdoutText);

  return DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandResult(
    exitCode:
        debugBridgePrototypeDesignReadinessSummaryValidationReportExitCode(
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

DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandRequest
validateDebugBridgePrototypeDesignReadinessSummaryValidationReportArgs(
  List<String> args,
) {
  var format =
      DebugBridgePrototypeDesignReadinessSummaryValidationReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandRequest.valid(
        format: DebugBridgePrototypeDesignReadinessSummaryValidationReportFormat
            .markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandRequest.invalid(
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
        return const DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int debugBridgePrototypeDesignReadinessSummaryValidationReportExitCode(
  DebugBridgePrototypeDesignReadinessSummaryValidationResult result,
  DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandRequest
  request, {
  List<DebugBridgePrototypeDesignReadinessSummaryValidationFinding>
      reportFindings =
      const <DebugBridgePrototypeDesignReadinessSummaryValidationFinding>[],
}) {
  if (result
          .hasUnsafeDebugBridgePrototypeDesignReadinessSummaryValidationPolicyViolation ||
      reportFindings.any((finding) => finding.isCritical)) {
    return debugBridgePrototypeDesignReadinessSummaryValidationReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return debugBridgePrototypeDesignReadinessSummaryValidationReportExitBlockedStrict;
  }
  return debugBridgePrototypeDesignReadinessSummaryValidationReportExitSuccess;
}

DebugBridgePrototypeDesignReadinessSummaryValidationReportFormat? _formatByWire(
  String value,
) {
  for (final format
      in DebugBridgePrototypeDesignReadinessSummaryValidationReportFormat
          .values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Debug Bridge Prototype Design Readiness Summary Validation report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/debug_bridge_prototype_design_readiness_summary_validation_report.dart',
    )
    ..writeln(
      '  dart run tool/debug_bridge_prototype_design_readiness_summary_validation_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/debug_bridge_prototype_design_readiness_summary_validation_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/debug_bridge_prototype_design_readiness_summary_validation_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/debug_bridge_prototype_design_readiness_summary_validation_report.dart --include-warnings',
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

import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_skeleton_validation.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugOnlyBridgeDeveloperSkeletonValidationReportExitSuccess = 0;
const debugOnlyBridgeDeveloperSkeletonValidationReportExitUsage = 64;
const debugOnlyBridgeDeveloperSkeletonValidationReportExitBlockedStrict = 68;
const debugOnlyBridgeDeveloperSkeletonValidationReportExitUnsafePolicy = 69;

class DebugOnlyBridgeDeveloperSkeletonValidationReportCommandResult {
  const DebugOnlyBridgeDeveloperSkeletonValidationReportCommandResult({
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
  final DebugOnlyBridgeDeveloperSkeletonValidationReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyBridgeDeveloperSkeletonValidationResult? result;
  final String? commandFailure;
}

class DebugOnlyBridgeDeveloperSkeletonValidationReportCommandRequest {
  const DebugOnlyBridgeDeveloperSkeletonValidationReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const DebugOnlyBridgeDeveloperSkeletonValidationReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = DebugOnlyBridgeDeveloperSkeletonValidationReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeDeveloperSkeletonValidationReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runDebugOnlyBridgeDeveloperSkeletonValidationReportCommand(
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

DebugOnlyBridgeDeveloperSkeletonValidationReportCommandResult
runDebugOnlyBridgeDeveloperSkeletonValidationReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  DebugOnlyBridgeDeveloperSkeletonValidation validation =
      const DebugOnlyBridgeDeveloperSkeletonValidation(),
  DebugOnlyBridgeDeveloperSkeletonValidationRequest? request,
}) {
  final commandRequest =
      validateDebugOnlyBridgeDeveloperSkeletonValidationReportArgs(args);
  if (!commandRequest.isValid) {
    return DebugOnlyBridgeDeveloperSkeletonValidationReportCommandResult(
      exitCode: debugOnlyBridgeDeveloperSkeletonValidationReportExitUsage,
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
    return DebugOnlyBridgeDeveloperSkeletonValidationReportCommandResult(
      exitCode: debugOnlyBridgeDeveloperSkeletonValidationReportExitSuccess,
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
      DebugOnlyBridgeDeveloperSkeletonValidationRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = validation.evaluate(validationRequest);
  final stdoutText = switch (commandRequest.format) {
    DebugOnlyBridgeDeveloperSkeletonValidationReportFormat.markdown =>
      result.renderMarkdownReport(),
    DebugOnlyBridgeDeveloperSkeletonValidationReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings =
      const DebugOnlyBridgeDeveloperSkeletonValidationValidator()
          .validateReportText(stdoutText);

  return DebugOnlyBridgeDeveloperSkeletonValidationReportCommandResult(
    exitCode: debugOnlyBridgeDeveloperSkeletonValidationReportExitCode(
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

DebugOnlyBridgeDeveloperSkeletonValidationReportCommandRequest
validateDebugOnlyBridgeDeveloperSkeletonValidationReportArgs(
  List<String> args,
) {
  var format = DebugOnlyBridgeDeveloperSkeletonValidationReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const DebugOnlyBridgeDeveloperSkeletonValidationReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const DebugOnlyBridgeDeveloperSkeletonValidationReportCommandRequest.valid(
        format: DebugOnlyBridgeDeveloperSkeletonValidationReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const DebugOnlyBridgeDeveloperSkeletonValidationReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const DebugOnlyBridgeDeveloperSkeletonValidationReportCommandRequest.invalid(
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
        return const DebugOnlyBridgeDeveloperSkeletonValidationReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const DebugOnlyBridgeDeveloperSkeletonValidationReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const DebugOnlyBridgeDeveloperSkeletonValidationReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return DebugOnlyBridgeDeveloperSkeletonValidationReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int debugOnlyBridgeDeveloperSkeletonValidationReportExitCode(
  DebugOnlyBridgeDeveloperSkeletonValidationResult result,
  DebugOnlyBridgeDeveloperSkeletonValidationReportCommandRequest request, {
  List<DebugOnlyBridgeDeveloperSkeletonValidationFinding> reportFindings =
      const <DebugOnlyBridgeDeveloperSkeletonValidationFinding>[],
}) {
  if (result
          .hasUnsafeDebugOnlyBridgeDeveloperSkeletonValidationPolicyViolation ||
      reportFindings.any((finding) => finding.isCritical)) {
    return debugOnlyBridgeDeveloperSkeletonValidationReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return debugOnlyBridgeDeveloperSkeletonValidationReportExitBlockedStrict;
  }
  return debugOnlyBridgeDeveloperSkeletonValidationReportExitSuccess;
}

DebugOnlyBridgeDeveloperSkeletonValidationReportFormat? _formatByWire(
  String value,
) {
  for (final format
      in DebugOnlyBridgeDeveloperSkeletonValidationReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Debug-Only Bridge Developer Skeleton Validation report usage error: '
      '$failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/debug_only_bridge_developer_skeleton_validation_report.dart',
    )
    ..writeln(
      '  dart run tool/debug_only_bridge_developer_skeleton_validation_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/debug_only_bridge_developer_skeleton_validation_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/debug_only_bridge_developer_skeleton_validation_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/debug_only_bridge_developer_skeleton_validation_report.dart --include-warnings',
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

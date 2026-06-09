import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_skeleton.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugOnlyBridgeDeveloperSkeletonReportExitSuccess = 0;
const debugOnlyBridgeDeveloperSkeletonReportExitUsage = 64;
const debugOnlyBridgeDeveloperSkeletonReportExitBlockedStrict = 68;
const debugOnlyBridgeDeveloperSkeletonReportExitUnsafePolicy = 69;

class DebugOnlyBridgeDeveloperSkeletonReportCommandResult {
  const DebugOnlyBridgeDeveloperSkeletonReportCommandResult({
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
  final DebugOnlyBridgeSkeletonReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyBridgeSkeletonResult? result;
  final String? commandFailure;
}

class DebugOnlyBridgeDeveloperSkeletonReportCommandRequest {
  const DebugOnlyBridgeDeveloperSkeletonReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const DebugOnlyBridgeDeveloperSkeletonReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = DebugOnlyBridgeSkeletonReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeSkeletonReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runDebugOnlyBridgeDeveloperSkeletonReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

DebugOnlyBridgeDeveloperSkeletonReportCommandResult
runDebugOnlyBridgeDeveloperSkeletonReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  DebugOnlyBridgeSkeleton skeleton = const DebugOnlyBridgeSkeleton(),
  DebugOnlyBridgeSkeletonRequest? request,
}) {
  final commandRequest = validateDebugOnlyBridgeDeveloperSkeletonReportArgs(
    args,
  );
  if (!commandRequest.isValid) {
    return DebugOnlyBridgeDeveloperSkeletonReportCommandResult(
      exitCode: debugOnlyBridgeDeveloperSkeletonReportExitUsage,
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
    return DebugOnlyBridgeDeveloperSkeletonReportCommandResult(
      exitCode: debugOnlyBridgeDeveloperSkeletonReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final skeletonRequest =
      request ??
      DebugOnlyBridgeSkeletonRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = skeleton.evaluate(skeletonRequest);
  final stdoutText = switch (commandRequest.format) {
    DebugOnlyBridgeSkeletonReportFormat.markdown =>
      result.renderMarkdownReport(),
    DebugOnlyBridgeSkeletonReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings = const DebugOnlyBridgeSkeletonValidator()
      .validateReportText(stdoutText);

  return DebugOnlyBridgeDeveloperSkeletonReportCommandResult(
    exitCode: debugOnlyBridgeDeveloperSkeletonReportExitCode(
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

DebugOnlyBridgeDeveloperSkeletonReportCommandRequest
validateDebugOnlyBridgeDeveloperSkeletonReportArgs(List<String> args) {
  var format = DebugOnlyBridgeSkeletonReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const DebugOnlyBridgeDeveloperSkeletonReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const DebugOnlyBridgeDeveloperSkeletonReportCommandRequest.valid(
        format: DebugOnlyBridgeSkeletonReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const DebugOnlyBridgeDeveloperSkeletonReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const DebugOnlyBridgeDeveloperSkeletonReportCommandRequest.invalid(
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
        return const DebugOnlyBridgeDeveloperSkeletonReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const DebugOnlyBridgeDeveloperSkeletonReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const DebugOnlyBridgeDeveloperSkeletonReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return DebugOnlyBridgeDeveloperSkeletonReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int debugOnlyBridgeDeveloperSkeletonReportExitCode(
  DebugOnlyBridgeSkeletonResult result,
  DebugOnlyBridgeDeveloperSkeletonReportCommandRequest request, {
  List<DebugOnlyBridgeSkeletonFinding> reportFindings =
      const <DebugOnlyBridgeSkeletonFinding>[],
}) {
  if (result.hasUnsafeDebugOnlyBridgeDeveloperSkeletonPolicyViolation ||
      reportFindings.any((finding) => finding.isCritical)) {
    return debugOnlyBridgeDeveloperSkeletonReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return debugOnlyBridgeDeveloperSkeletonReportExitBlockedStrict;
  }
  return debugOnlyBridgeDeveloperSkeletonReportExitSuccess;
}

DebugOnlyBridgeSkeletonReportFormat? _formatByWire(String value) {
  for (final format in DebugOnlyBridgeSkeletonReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Debug-Only Bridge Developer Skeleton report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/debug_only_bridge_developer_skeleton_report.dart',
    )
    ..writeln(
      '  dart run tool/debug_only_bridge_developer_skeleton_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/debug_only_bridge_developer_skeleton_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/debug_only_bridge_developer_skeleton_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/debug_only_bridge_developer_skeleton_report.dart --include-warnings',
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

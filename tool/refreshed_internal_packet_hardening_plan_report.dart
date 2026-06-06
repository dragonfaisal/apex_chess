import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_internal_packet_hardening_plan.dart';

const refreshedInternalPacketHardeningPlanReportExitSuccess = 0;
const refreshedInternalPacketHardeningPlanReportExitUsage = 64;
const refreshedInternalPacketHardeningPlanReportExitBlockedStrict = 68;
const refreshedInternalPacketHardeningPlanReportExitUnsafePolicy = 69;

class RefreshedInternalPacketHardeningPlanReportCommandResult {
  const RefreshedInternalPacketHardeningPlanReportCommandResult({
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
  final RefreshedInternalPacketHardeningPlanReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final RefreshedInternalPacketHardeningPlanResult? result;
  final String? commandFailure;
}

class RefreshedInternalPacketHardeningPlanReportCommandRequest {
  const RefreshedInternalPacketHardeningPlanReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const RefreshedInternalPacketHardeningPlanReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = RefreshedInternalPacketHardeningPlanReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final RefreshedInternalPacketHardeningPlanReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runRefreshedInternalPacketHardeningPlanReportCommand(
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

RefreshedInternalPacketHardeningPlanReportCommandResult
runRefreshedInternalPacketHardeningPlanReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  RefreshedInternalPacketHardeningPlan plan =
      const RefreshedInternalPacketHardeningPlan(),
  RefreshedInternalPacketHardeningPlanRequest? request,
}) {
  final commandRequest = validateRefreshedInternalPacketHardeningPlanReportArgs(
    args,
  );
  if (!commandRequest.isValid) {
    return RefreshedInternalPacketHardeningPlanReportCommandResult(
      exitCode: refreshedInternalPacketHardeningPlanReportExitUsage,
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
    return RefreshedInternalPacketHardeningPlanReportCommandResult(
      exitCode: refreshedInternalPacketHardeningPlanReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final planRequest =
      request ??
      RefreshedInternalPacketHardeningPlanRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = plan.evaluate(planRequest);
  final stdoutText = switch (commandRequest.format) {
    RefreshedInternalPacketHardeningPlanReportFormat.markdown =>
      result.renderMarkdownReport(),
    RefreshedInternalPacketHardeningPlanReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return RefreshedInternalPacketHardeningPlanReportCommandResult(
    exitCode: refreshedInternalPacketHardeningPlanReportExitCode(
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

RefreshedInternalPacketHardeningPlanReportCommandRequest
validateRefreshedInternalPacketHardeningPlanReportArgs(List<String> args) {
  var format = RefreshedInternalPacketHardeningPlanReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const RefreshedInternalPacketHardeningPlanReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const RefreshedInternalPacketHardeningPlanReportCommandRequest.valid(
        format: RefreshedInternalPacketHardeningPlanReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const RefreshedInternalPacketHardeningPlanReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const RefreshedInternalPacketHardeningPlanReportCommandRequest.invalid(
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
        return const RefreshedInternalPacketHardeningPlanReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const RefreshedInternalPacketHardeningPlanReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const RefreshedInternalPacketHardeningPlanReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return RefreshedInternalPacketHardeningPlanReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int refreshedInternalPacketHardeningPlanReportExitCode(
  RefreshedInternalPacketHardeningPlanResult result,
  RefreshedInternalPacketHardeningPlanReportCommandRequest request,
) {
  if (result.hasUnsafeRefreshPolicyViolation) {
    return refreshedInternalPacketHardeningPlanReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return refreshedInternalPacketHardeningPlanReportExitBlockedStrict;
  }
  return refreshedInternalPacketHardeningPlanReportExitSuccess;
}

RefreshedInternalPacketHardeningPlanReportFormat? _formatByWire(String value) {
  for (final format
      in RefreshedInternalPacketHardeningPlanReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Refreshed Internal Packet Hardening Plan report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/refreshed_internal_packet_hardening_plan_report.dart',
    )
    ..writeln(
      '  dart run tool/refreshed_internal_packet_hardening_plan_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/refreshed_internal_packet_hardening_plan_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/refreshed_internal_packet_hardening_plan_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/refreshed_internal_packet_hardening_plan_report.dart --include-warnings',
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

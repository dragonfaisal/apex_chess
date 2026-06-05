import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_hardening_plan.dart';

const internalPacketEvidenceHardeningPlanReportExitSuccess = 0;
const internalPacketEvidenceHardeningPlanReportExitUsage = 64;
const internalPacketEvidenceHardeningPlanReportExitBlockedStrict = 68;
const internalPacketEvidenceHardeningPlanReportExitUnsafePolicy = 69;

class InternalPacketEvidenceHardeningPlanReportCommandResult {
  const InternalPacketEvidenceHardeningPlanReportCommandResult({
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
  final InternalPacketEvidenceHardeningPlanReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final InternalPacketEvidenceHardeningPlanResult? result;
  final String? commandFailure;
}

class InternalPacketEvidenceHardeningPlanReportCommandRequest {
  const InternalPacketEvidenceHardeningPlanReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalPacketEvidenceHardeningPlanReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = InternalPacketEvidenceHardeningPlanReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalPacketEvidenceHardeningPlanReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalPacketEvidenceHardeningPlanReportCommand(
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

InternalPacketEvidenceHardeningPlanReportCommandResult
runInternalPacketEvidenceHardeningPlanReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalPacketEvidenceHardeningPlan plan =
      const InternalPacketEvidenceHardeningPlan(),
  InternalPacketEvidenceHardeningPlanRequest? request,
}) {
  final commandRequest = validateInternalPacketEvidenceHardeningPlanReportArgs(
    args,
  );
  if (!commandRequest.isValid) {
    return InternalPacketEvidenceHardeningPlanReportCommandResult(
      exitCode: internalPacketEvidenceHardeningPlanReportExitUsage,
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
    return InternalPacketEvidenceHardeningPlanReportCommandResult(
      exitCode: internalPacketEvidenceHardeningPlanReportExitSuccess,
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
      InternalPacketEvidenceHardeningPlanRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = plan.evaluate(planRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalPacketEvidenceHardeningPlanReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalPacketEvidenceHardeningPlanReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return InternalPacketEvidenceHardeningPlanReportCommandResult(
    exitCode: internalPacketEvidenceHardeningPlanReportExitCode(
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

InternalPacketEvidenceHardeningPlanReportCommandRequest
validateInternalPacketEvidenceHardeningPlanReportArgs(List<String> args) {
  var format = InternalPacketEvidenceHardeningPlanReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalPacketEvidenceHardeningPlanReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalPacketEvidenceHardeningPlanReportCommandRequest.valid(
        format: InternalPacketEvidenceHardeningPlanReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalPacketEvidenceHardeningPlanReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalPacketEvidenceHardeningPlanReportCommandRequest.invalid(
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
        return const InternalPacketEvidenceHardeningPlanReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const InternalPacketEvidenceHardeningPlanReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const InternalPacketEvidenceHardeningPlanReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalPacketEvidenceHardeningPlanReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int internalPacketEvidenceHardeningPlanReportExitCode(
  InternalPacketEvidenceHardeningPlanResult result,
  InternalPacketEvidenceHardeningPlanReportCommandRequest request,
) {
  if (result.hasUnsafeHardeningPolicyViolation) {
    return internalPacketEvidenceHardeningPlanReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalPacketEvidenceHardeningPlanReportExitBlockedStrict;
  }
  return internalPacketEvidenceHardeningPlanReportExitSuccess;
}

InternalPacketEvidenceHardeningPlanReportFormat? _formatByWire(String value) {
  for (final format in InternalPacketEvidenceHardeningPlanReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Internal Packet Evidence Hardening Plan report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/internal_packet_evidence_hardening_plan_report.dart',
    )
    ..writeln(
      '  dart run tool/internal_packet_evidence_hardening_plan_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_packet_evidence_hardening_plan_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_packet_evidence_hardening_plan_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_packet_evidence_hardening_plan_report.dart --include-warnings',
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

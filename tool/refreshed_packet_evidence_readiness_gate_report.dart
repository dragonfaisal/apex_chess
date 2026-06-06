import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_evidence_readiness_gate.dart';

const refreshedPacketEvidenceReadinessGateReportExitSuccess = 0;
const refreshedPacketEvidenceReadinessGateReportExitUsage = 64;
const refreshedPacketEvidenceReadinessGateReportExitBlockedStrict = 68;
const refreshedPacketEvidenceReadinessGateReportExitUnsafePolicy = 69;

class RefreshedPacketEvidenceReadinessGateReportCommandResult {
  const RefreshedPacketEvidenceReadinessGateReportCommandResult({
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
  final RefreshedPacketEvidenceReadinessGateReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final RefreshedPacketEvidenceReadinessGateResult? result;
  final String? commandFailure;
}

class RefreshedPacketEvidenceReadinessGateReportCommandRequest {
  const RefreshedPacketEvidenceReadinessGateReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const RefreshedPacketEvidenceReadinessGateReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = RefreshedPacketEvidenceReadinessGateReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final RefreshedPacketEvidenceReadinessGateReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runRefreshedPacketEvidenceReadinessGateReportCommand(
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

RefreshedPacketEvidenceReadinessGateReportCommandResult
runRefreshedPacketEvidenceReadinessGateReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  RefreshedPacketEvidenceReadinessGate gate =
      const RefreshedPacketEvidenceReadinessGate(),
  RefreshedPacketEvidenceReadinessGateRequest? request,
}) {
  final commandRequest = validateRefreshedPacketEvidenceReadinessGateReportArgs(
    args,
  );
  if (!commandRequest.isValid) {
    return RefreshedPacketEvidenceReadinessGateReportCommandResult(
      exitCode: refreshedPacketEvidenceReadinessGateReportExitUsage,
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
    return RefreshedPacketEvidenceReadinessGateReportCommandResult(
      exitCode: refreshedPacketEvidenceReadinessGateReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final gateRequest =
      request ??
      RefreshedPacketEvidenceReadinessGateRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = gate.evaluate(gateRequest);
  final stdoutText = switch (commandRequest.format) {
    RefreshedPacketEvidenceReadinessGateReportFormat.markdown =>
      result.renderMarkdownReport(),
    RefreshedPacketEvidenceReadinessGateReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return RefreshedPacketEvidenceReadinessGateReportCommandResult(
    exitCode: refreshedPacketEvidenceReadinessGateReportExitCode(
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

RefreshedPacketEvidenceReadinessGateReportCommandRequest
validateRefreshedPacketEvidenceReadinessGateReportArgs(List<String> args) {
  var format = RefreshedPacketEvidenceReadinessGateReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const RefreshedPacketEvidenceReadinessGateReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const RefreshedPacketEvidenceReadinessGateReportCommandRequest.valid(
        format: RefreshedPacketEvidenceReadinessGateReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const RefreshedPacketEvidenceReadinessGateReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const RefreshedPacketEvidenceReadinessGateReportCommandRequest.invalid(
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
        return const RefreshedPacketEvidenceReadinessGateReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const RefreshedPacketEvidenceReadinessGateReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const RefreshedPacketEvidenceReadinessGateReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return RefreshedPacketEvidenceReadinessGateReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int refreshedPacketEvidenceReadinessGateReportExitCode(
  RefreshedPacketEvidenceReadinessGateResult result,
  RefreshedPacketEvidenceReadinessGateReportCommandRequest request,
) {
  if (result.hasUnsafeReadinessPolicyViolation) {
    return refreshedPacketEvidenceReadinessGateReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return refreshedPacketEvidenceReadinessGateReportExitBlockedStrict;
  }
  return refreshedPacketEvidenceReadinessGateReportExitSuccess;
}

RefreshedPacketEvidenceReadinessGateReportFormat? _formatByWire(String value) {
  for (final format
      in RefreshedPacketEvidenceReadinessGateReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Refreshed Packet Evidence Readiness Gate report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/refreshed_packet_evidence_readiness_gate_report.dart',
    )
    ..writeln(
      '  dart run tool/refreshed_packet_evidence_readiness_gate_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/refreshed_packet_evidence_readiness_gate_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/refreshed_packet_evidence_readiness_gate_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/refreshed_packet_evidence_readiness_gate_report.dart --include-warnings',
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

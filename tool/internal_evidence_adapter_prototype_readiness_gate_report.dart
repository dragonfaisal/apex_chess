import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_readiness_gate.dart';

const internalEvidenceAdapterPrototypeReadinessGateReportExitSuccess = 0;
const internalEvidenceAdapterPrototypeReadinessGateReportExitUsage = 64;
const internalEvidenceAdapterPrototypeReadinessGateReportExitBlockedStrict = 68;
const internalEvidenceAdapterPrototypeReadinessGateReportExitUnsafePolicy = 69;

class InternalEvidenceAdapterPrototypeReadinessGateReportCommandResult {
  const InternalEvidenceAdapterPrototypeReadinessGateReportCommandResult({
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
  final InternalEvidenceAdapterPrototypeReadinessGateReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final InternalEvidenceAdapterPrototypeReadinessGateResult? result;
  final String? commandFailure;
}

class InternalEvidenceAdapterPrototypeReadinessGateReportCommandRequest {
  const InternalEvidenceAdapterPrototypeReadinessGateReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalEvidenceAdapterPrototypeReadinessGateReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format =
          InternalEvidenceAdapterPrototypeReadinessGateReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalEvidenceAdapterPrototypeReadinessGateReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalEvidenceAdapterPrototypeReadinessGateReportCommand(
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

InternalEvidenceAdapterPrototypeReadinessGateReportCommandResult
runInternalEvidenceAdapterPrototypeReadinessGateReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalEvidenceAdapterPrototypeReadinessGate readinessGate =
      const InternalEvidenceAdapterPrototypeReadinessGate(),
  InternalEvidenceAdapterPrototypeReadinessGateRequest? request,
}) {
  final commandRequest =
      validateInternalEvidenceAdapterPrototypeReadinessGateReportArgs(args);
  if (!commandRequest.isValid) {
    return InternalEvidenceAdapterPrototypeReadinessGateReportCommandResult(
      exitCode: internalEvidenceAdapterPrototypeReadinessGateReportExitUsage,
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
    return InternalEvidenceAdapterPrototypeReadinessGateReportCommandResult(
      exitCode: internalEvidenceAdapterPrototypeReadinessGateReportExitSuccess,
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
      InternalEvidenceAdapterPrototypeReadinessGateRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = readinessGate.evaluate(gateRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalEvidenceAdapterPrototypeReadinessGateReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalEvidenceAdapterPrototypeReadinessGateReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings =
      const InternalEvidenceAdapterPrototypeReadinessGateValidator()
          .validateReportText(stdoutText);

  return InternalEvidenceAdapterPrototypeReadinessGateReportCommandResult(
    exitCode: internalEvidenceAdapterPrototypeReadinessGateReportExitCode(
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

InternalEvidenceAdapterPrototypeReadinessGateReportCommandRequest
validateInternalEvidenceAdapterPrototypeReadinessGateReportArgs(
  List<String> args,
) {
  var format =
      InternalEvidenceAdapterPrototypeReadinessGateReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalEvidenceAdapterPrototypeReadinessGateReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalEvidenceAdapterPrototypeReadinessGateReportCommandRequest.valid(
        format:
            InternalEvidenceAdapterPrototypeReadinessGateReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalEvidenceAdapterPrototypeReadinessGateReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalEvidenceAdapterPrototypeReadinessGateReportCommandRequest.invalid(
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
        return const InternalEvidenceAdapterPrototypeReadinessGateReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const InternalEvidenceAdapterPrototypeReadinessGateReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const InternalEvidenceAdapterPrototypeReadinessGateReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalEvidenceAdapterPrototypeReadinessGateReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int internalEvidenceAdapterPrototypeReadinessGateReportExitCode(
  InternalEvidenceAdapterPrototypeReadinessGateResult result,
  InternalEvidenceAdapterPrototypeReadinessGateReportCommandRequest request, {
  List<InternalEvidenceAdapterPrototypeReadinessFinding> reportFindings =
      const <InternalEvidenceAdapterPrototypeReadinessFinding>[],
}) {
  if (result.hasUnsafeAdapterReadinessPolicyViolation ||
      reportFindings.any((finding) => finding.isCritical)) {
    return internalEvidenceAdapterPrototypeReadinessGateReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalEvidenceAdapterPrototypeReadinessGateReportExitBlockedStrict;
  }
  return internalEvidenceAdapterPrototypeReadinessGateReportExitSuccess;
}

InternalEvidenceAdapterPrototypeReadinessGateReportFormat? _formatByWire(
  String value,
) {
  for (final format
      in InternalEvidenceAdapterPrototypeReadinessGateReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Internal Evidence Adapter Prototype Readiness Gate report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/internal_evidence_adapter_prototype_readiness_gate_report.dart',
    )
    ..writeln(
      '  dart run tool/internal_evidence_adapter_prototype_readiness_gate_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_evidence_adapter_prototype_readiness_gate_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_evidence_adapter_prototype_readiness_gate_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_evidence_adapter_prototype_readiness_gate_report.dart --include-warnings',
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

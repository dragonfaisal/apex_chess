import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_design.dart';

const internalEvidenceAdapterDesignReportExitSuccess = 0;
const internalEvidenceAdapterDesignReportExitUsage = 64;
const internalEvidenceAdapterDesignReportExitBlockedStrict = 68;
const internalEvidenceAdapterDesignReportExitUnsafePolicy = 69;

class InternalEvidenceAdapterDesignReportCommandResult {
  const InternalEvidenceAdapterDesignReportCommandResult({
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
  final InternalEvidenceAdapterDesignReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final InternalEvidenceAdapterDesignResult? result;
  final String? commandFailure;
}

class InternalEvidenceAdapterDesignReportCommandRequest {
  const InternalEvidenceAdapterDesignReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalEvidenceAdapterDesignReportCommandRequest.invalid(this.failure)
    : isValid = false,
      format = InternalEvidenceAdapterDesignReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalEvidenceAdapterDesignReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalEvidenceAdapterDesignReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

InternalEvidenceAdapterDesignReportCommandResult
runInternalEvidenceAdapterDesignReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalEvidenceAdapterDesign adapterDesign =
      const InternalEvidenceAdapterDesign(),
  InternalEvidenceAdapterDesignRequest? request,
}) {
  final commandRequest = validateInternalEvidenceAdapterDesignReportArgs(args);
  if (!commandRequest.isValid) {
    return InternalEvidenceAdapterDesignReportCommandResult(
      exitCode: internalEvidenceAdapterDesignReportExitUsage,
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
    return InternalEvidenceAdapterDesignReportCommandResult(
      exitCode: internalEvidenceAdapterDesignReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final designRequest =
      request ??
      InternalEvidenceAdapterDesignRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = adapterDesign.evaluate(designRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalEvidenceAdapterDesignReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalEvidenceAdapterDesignReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return InternalEvidenceAdapterDesignReportCommandResult(
    exitCode: internalEvidenceAdapterDesignReportExitCode(
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

InternalEvidenceAdapterDesignReportCommandRequest
validateInternalEvidenceAdapterDesignReportArgs(List<String> args) {
  var format = InternalEvidenceAdapterDesignReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalEvidenceAdapterDesignReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalEvidenceAdapterDesignReportCommandRequest.valid(
        format: InternalEvidenceAdapterDesignReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalEvidenceAdapterDesignReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalEvidenceAdapterDesignReportCommandRequest.invalid(
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
        return const InternalEvidenceAdapterDesignReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const InternalEvidenceAdapterDesignReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const InternalEvidenceAdapterDesignReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalEvidenceAdapterDesignReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int internalEvidenceAdapterDesignReportExitCode(
  InternalEvidenceAdapterDesignResult result,
  InternalEvidenceAdapterDesignReportCommandRequest request,
) {
  if (result.hasUnsafeAdapterDesignPolicyViolation) {
    return internalEvidenceAdapterDesignReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalEvidenceAdapterDesignReportExitBlockedStrict;
  }
  return internalEvidenceAdapterDesignReportExitSuccess;
}

InternalEvidenceAdapterDesignReportFormat? _formatByWire(String value) {
  for (final format in InternalEvidenceAdapterDesignReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Internal Evidence Adapter Design report usage error: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/internal_evidence_adapter_design_report.dart')
    ..writeln(
      '  dart run tool/internal_evidence_adapter_design_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_evidence_adapter_design_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_evidence_adapter_design_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_evidence_adapter_design_report.dart --include-warnings',
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

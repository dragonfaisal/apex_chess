import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype.dart';

const internalEvidenceAdapterPrototypeReportExitSuccess = 0;
const internalEvidenceAdapterPrototypeReportExitUsage = 64;
const internalEvidenceAdapterPrototypeReportExitBlockedStrict = 68;
const internalEvidenceAdapterPrototypeReportExitUnsafePolicy = 69;

class InternalEvidenceAdapterPrototypeReportCommandResult {
  const InternalEvidenceAdapterPrototypeReportCommandResult({
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
  final InternalEvidenceAdapterPrototypeReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final InternalEvidenceAdapterPrototypeResult? result;
  final String? commandFailure;
}

class InternalEvidenceAdapterPrototypeReportCommandRequest {
  const InternalEvidenceAdapterPrototypeReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalEvidenceAdapterPrototypeReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = InternalEvidenceAdapterPrototypeReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalEvidenceAdapterPrototypeReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalEvidenceAdapterPrototypeReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

InternalEvidenceAdapterPrototypeReportCommandResult
runInternalEvidenceAdapterPrototypeReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalEvidenceAdapterPrototype adapterPrototype =
      const InternalEvidenceAdapterPrototype(),
  InternalEvidenceAdapterPrototypeRequest? request,
}) {
  final commandRequest = validateInternalEvidenceAdapterPrototypeReportArgs(
    args,
  );
  if (!commandRequest.isValid) {
    return InternalEvidenceAdapterPrototypeReportCommandResult(
      exitCode: internalEvidenceAdapterPrototypeReportExitUsage,
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
    return InternalEvidenceAdapterPrototypeReportCommandResult(
      exitCode: internalEvidenceAdapterPrototypeReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final prototypeRequest =
      request ??
      InternalEvidenceAdapterPrototypeRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = adapterPrototype.evaluate(prototypeRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalEvidenceAdapterPrototypeReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalEvidenceAdapterPrototypeReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return InternalEvidenceAdapterPrototypeReportCommandResult(
    exitCode: internalEvidenceAdapterPrototypeReportExitCode(
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

InternalEvidenceAdapterPrototypeReportCommandRequest
validateInternalEvidenceAdapterPrototypeReportArgs(List<String> args) {
  var format = InternalEvidenceAdapterPrototypeReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalEvidenceAdapterPrototypeReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalEvidenceAdapterPrototypeReportCommandRequest.valid(
        format: InternalEvidenceAdapterPrototypeReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalEvidenceAdapterPrototypeReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalEvidenceAdapterPrototypeReportCommandRequest.invalid(
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
        return const InternalEvidenceAdapterPrototypeReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const InternalEvidenceAdapterPrototypeReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const InternalEvidenceAdapterPrototypeReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalEvidenceAdapterPrototypeReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int internalEvidenceAdapterPrototypeReportExitCode(
  InternalEvidenceAdapterPrototypeResult result,
  InternalEvidenceAdapterPrototypeReportCommandRequest request,
) {
  if (result.hasUnsafeAdapterPrototypePolicyViolation) {
    return internalEvidenceAdapterPrototypeReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalEvidenceAdapterPrototypeReportExitBlockedStrict;
  }
  return internalEvidenceAdapterPrototypeReportExitSuccess;
}

InternalEvidenceAdapterPrototypeReportFormat? _formatByWire(String value) {
  for (final format in InternalEvidenceAdapterPrototypeReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Internal Evidence Adapter Prototype report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/internal_evidence_adapter_prototype_report.dart')
    ..writeln(
      '  dart run tool/internal_evidence_adapter_prototype_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_evidence_adapter_prototype_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_evidence_adapter_prototype_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_evidence_adapter_prototype_report.dart --include-warnings',
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

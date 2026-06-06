import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_validation.dart';

const internalEvidenceAdapterPrototypeValidationReportExitSuccess = 0;
const internalEvidenceAdapterPrototypeValidationReportExitUsage = 64;
const internalEvidenceAdapterPrototypeValidationReportExitBlockedStrict = 68;
const internalEvidenceAdapterPrototypeValidationReportExitUnsafePolicy = 69;

class InternalEvidenceAdapterPrototypeValidationReportCommandResult {
  const InternalEvidenceAdapterPrototypeValidationReportCommandResult({
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
  final InternalEvidenceAdapterPrototypeValidationReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final InternalEvidenceAdapterPrototypeValidationResult? result;
  final String? commandFailure;
}

class InternalEvidenceAdapterPrototypeValidationReportCommandRequest {
  const InternalEvidenceAdapterPrototypeValidationReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalEvidenceAdapterPrototypeValidationReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = InternalEvidenceAdapterPrototypeValidationReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalEvidenceAdapterPrototypeValidationReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalEvidenceAdapterPrototypeValidationReportCommand(
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

InternalEvidenceAdapterPrototypeValidationReportCommandResult
runInternalEvidenceAdapterPrototypeValidationReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalEvidenceAdapterPrototypeValidation validation =
      const InternalEvidenceAdapterPrototypeValidation(),
  InternalEvidenceAdapterPrototypeValidationRequest? request,
}) {
  final commandRequest =
      validateInternalEvidenceAdapterPrototypeValidationReportArgs(args);
  if (!commandRequest.isValid) {
    return InternalEvidenceAdapterPrototypeValidationReportCommandResult(
      exitCode: internalEvidenceAdapterPrototypeValidationReportExitUsage,
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
    return InternalEvidenceAdapterPrototypeValidationReportCommandResult(
      exitCode: internalEvidenceAdapterPrototypeValidationReportExitSuccess,
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
      InternalEvidenceAdapterPrototypeValidationRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = validation.evaluate(validationRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalEvidenceAdapterPrototypeValidationReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalEvidenceAdapterPrototypeValidationReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings =
      const InternalEvidenceAdapterPrototypeValidationValidator()
          .validateReportText(stdoutText);

  return InternalEvidenceAdapterPrototypeValidationReportCommandResult(
    exitCode: internalEvidenceAdapterPrototypeValidationReportExitCode(
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

InternalEvidenceAdapterPrototypeValidationReportCommandRequest
validateInternalEvidenceAdapterPrototypeValidationReportArgs(
  List<String> args,
) {
  var format = InternalEvidenceAdapterPrototypeValidationReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalEvidenceAdapterPrototypeValidationReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalEvidenceAdapterPrototypeValidationReportCommandRequest.valid(
        format: InternalEvidenceAdapterPrototypeValidationReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalEvidenceAdapterPrototypeValidationReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalEvidenceAdapterPrototypeValidationReportCommandRequest.invalid(
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
        return const InternalEvidenceAdapterPrototypeValidationReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const InternalEvidenceAdapterPrototypeValidationReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const InternalEvidenceAdapterPrototypeValidationReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalEvidenceAdapterPrototypeValidationReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int internalEvidenceAdapterPrototypeValidationReportExitCode(
  InternalEvidenceAdapterPrototypeValidationResult result,
  InternalEvidenceAdapterPrototypeValidationReportCommandRequest request, {
  List<InternalEvidenceAdapterPrototypeValidationFinding> reportFindings =
      const <InternalEvidenceAdapterPrototypeValidationFinding>[],
}) {
  if (result.hasUnsafeAdapterValidationPolicyViolation ||
      reportFindings.any((finding) => finding.isCritical)) {
    return internalEvidenceAdapterPrototypeValidationReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalEvidenceAdapterPrototypeValidationReportExitBlockedStrict;
  }
  return internalEvidenceAdapterPrototypeValidationReportExitSuccess;
}

InternalEvidenceAdapterPrototypeValidationReportFormat? _formatByWire(
  String value,
) {
  for (final format
      in InternalEvidenceAdapterPrototypeValidationReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Internal Evidence Adapter Prototype Validation report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/internal_evidence_adapter_prototype_validation_report.dart',
    )
    ..writeln(
      '  dart run tool/internal_evidence_adapter_prototype_validation_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_evidence_adapter_prototype_validation_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_evidence_adapter_prototype_validation_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_evidence_adapter_prototype_validation_report.dart --include-warnings',
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

import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/basic_classifier_evidence_contract.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const basicClassifierEvidenceContractReportExitSuccess = 0;
const basicClassifierEvidenceContractReportExitUsage = 64;
const basicClassifierEvidenceContractReportExitBlockedStrict = 68;
const basicClassifierEvidenceContractReportExitUnsafePolicy = 69;

class BasicClassifierEvidenceContractReportCommandResult {
  const BasicClassifierEvidenceContractReportCommandResult({
    required this.exitCode,
    required this.format,
    required this.strict,
    required this.stdoutText,
    required this.stderrText,
    this.result,
    this.commandFailure,
  });

  final int exitCode;
  final BasicClassifierEvidenceContractReportFormat format;
  final bool strict;
  final String stdoutText;
  final String stderrText;
  final BasicClassifierEvidenceContractPrototype? result;
  final String? commandFailure;
}

class BasicClassifierEvidenceContractReportCommandRequest {
  const BasicClassifierEvidenceContractReportCommandRequest.valid({
    required this.format,
    required this.strict,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const BasicClassifierEvidenceContractReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = BasicClassifierEvidenceContractReportFormat.markdown,
      strict = false,
      showHelp = false;

  final bool isValid;
  final String failure;
  final BasicClassifierEvidenceContractReportFormat format;
  final bool strict;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runBasicClassifierEvidenceContractReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

BasicClassifierEvidenceContractReportCommandResult
runBasicClassifierEvidenceContractReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  BasicClassifierEvidenceContractBuilder builder =
      const BasicClassifierEvidenceContractBuilder(),
}) {
  final request = validateBasicClassifierEvidenceContractReportArgs(args);
  if (!request.isValid) {
    return BasicClassifierEvidenceContractReportCommandResult(
      exitCode: basicClassifierEvidenceContractReportExitUsage,
      format: request.format,
      strict: request.strict,
      stdoutText: '',
      stderrText: _usage(request.failure),
      commandFailure: request.failure,
    );
  }
  if (request.showHelp) {
    return BasicClassifierEvidenceContractReportCommandResult(
      exitCode: basicClassifierEvidenceContractReportExitSuccess,
      format: request.format,
      strict: request.strict,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = builder.evaluate(
    BasicClassifierEvidenceContractRequest(cases: cases),
  );
  final stdoutText = switch (request.format) {
    BasicClassifierEvidenceContractReportFormat.markdown =>
      result.renderMarkdownReport(),
    BasicClassifierEvidenceContractReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return BasicClassifierEvidenceContractReportCommandResult(
    exitCode: basicClassifierEvidenceContractReportExitCode(result, request),
    format: request.format,
    strict: request.strict,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

BasicClassifierEvidenceContractReportCommandRequest
validateBasicClassifierEvidenceContractReportArgs(List<String> args) {
  var format = BasicClassifierEvidenceContractReportFormat.markdown;
  var strict = false;
  var formatSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const BasicClassifierEvidenceContractReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const BasicClassifierEvidenceContractReportCommandRequest.valid(
        format: BasicClassifierEvidenceContractReportFormat.markdown,
        strict: false,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const BasicClassifierEvidenceContractReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const BasicClassifierEvidenceContractReportCommandRequest.invalid(
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
    return const BasicClassifierEvidenceContractReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return BasicClassifierEvidenceContractReportCommandRequest.valid(
    format: format,
    strict: strict,
  );
}

int basicClassifierEvidenceContractReportExitCode(
  BasicClassifierEvidenceContractPrototype result,
  BasicClassifierEvidenceContractReportCommandRequest request,
) {
  if (result.hasUnsafeOutputPolicyViolation) {
    return basicClassifierEvidenceContractReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return basicClassifierEvidenceContractReportExitBlockedStrict;
  }
  return basicClassifierEvidenceContractReportExitSuccess;
}

BasicClassifierEvidenceContractReportFormat? _formatByWire(String value) {
  for (final format in BasicClassifierEvidenceContractReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Basic Classifier Evidence Contract report command usage error: '
      '$failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/basic_classifier_evidence_contract_report.dart')
    ..writeln(
      '  dart run tool/basic_classifier_evidence_contract_report.dart '
      '--format=json',
    )
    ..writeln(
      '  dart run tool/basic_classifier_evidence_contract_report.dart --strict',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _strictFlag = '--strict';

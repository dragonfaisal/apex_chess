import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/basic_classifier_foundation_design.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const basicClassifierFoundationDesignReportExitSuccess = 0;
const basicClassifierFoundationDesignReportExitUsage = 64;
const basicClassifierFoundationDesignReportExitBlockedStrict = 68;
const basicClassifierFoundationDesignReportExitUnsafePolicy = 69;

class BasicClassifierFoundationDesignReportCommandResult {
  const BasicClassifierFoundationDesignReportCommandResult({
    required this.exitCode,
    required this.format,
    required this.strict,
    required this.stdoutText,
    required this.stderrText,
    this.result,
    this.commandFailure,
  });

  final int exitCode;
  final BasicClassifierFoundationDesignReportFormat format;
  final bool strict;
  final String stdoutText;
  final String stderrText;
  final BasicClassifierFoundationDesignResult? result;
  final String? commandFailure;
}

class BasicClassifierFoundationDesignReportCommandRequest {
  const BasicClassifierFoundationDesignReportCommandRequest.valid({
    required this.format,
    required this.strict,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const BasicClassifierFoundationDesignReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = BasicClassifierFoundationDesignReportFormat.markdown,
      strict = false,
      showHelp = false;

  final bool isValid;
  final String failure;
  final BasicClassifierFoundationDesignReportFormat format;
  final bool strict;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runBasicClassifierFoundationDesignReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

BasicClassifierFoundationDesignReportCommandResult
runBasicClassifierFoundationDesignReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  BasicClassifierFoundationDesigner designer =
      const BasicClassifierFoundationDesigner(),
}) {
  final request = validateBasicClassifierFoundationDesignReportArgs(args);
  if (!request.isValid) {
    return BasicClassifierFoundationDesignReportCommandResult(
      exitCode: basicClassifierFoundationDesignReportExitUsage,
      format: request.format,
      strict: request.strict,
      stdoutText: '',
      stderrText: _usage(request.failure),
      commandFailure: request.failure,
    );
  }
  if (request.showHelp) {
    return BasicClassifierFoundationDesignReportCommandResult(
      exitCode: basicClassifierFoundationDesignReportExitSuccess,
      format: request.format,
      strict: request.strict,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = designer.evaluate(
    BasicClassifierFoundationDesignRequest(cases: cases),
  );
  final stdoutText = switch (request.format) {
    BasicClassifierFoundationDesignReportFormat.markdown =>
      result.renderMarkdownReport(),
    BasicClassifierFoundationDesignReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return BasicClassifierFoundationDesignReportCommandResult(
    exitCode: basicClassifierFoundationDesignReportExitCode(result, request),
    format: request.format,
    strict: request.strict,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

BasicClassifierFoundationDesignReportCommandRequest
validateBasicClassifierFoundationDesignReportArgs(List<String> args) {
  var format = BasicClassifierFoundationDesignReportFormat.markdown;
  var strict = false;
  var formatSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const BasicClassifierFoundationDesignReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const BasicClassifierFoundationDesignReportCommandRequest.valid(
        format: BasicClassifierFoundationDesignReportFormat.markdown,
        strict: false,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const BasicClassifierFoundationDesignReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const BasicClassifierFoundationDesignReportCommandRequest.invalid(
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
    return const BasicClassifierFoundationDesignReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return BasicClassifierFoundationDesignReportCommandRequest.valid(
    format: format,
    strict: strict,
  );
}

int basicClassifierFoundationDesignReportExitCode(
  BasicClassifierFoundationDesignResult result,
  BasicClassifierFoundationDesignReportCommandRequest request,
) {
  if (result.hasUnsafeOutputPolicyViolation) {
    return basicClassifierFoundationDesignReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return basicClassifierFoundationDesignReportExitBlockedStrict;
  }
  return basicClassifierFoundationDesignReportExitSuccess;
}

BasicClassifierFoundationDesignReportFormat? _formatByWire(String value) {
  for (final format in BasicClassifierFoundationDesignReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Basic Classifier Foundation Design report command usage error: '
      '$failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/basic_classifier_foundation_design_report.dart')
    ..writeln(
      '  dart run tool/basic_classifier_foundation_design_report.dart '
      '--format=json',
    )
    ..writeln(
      '  dart run tool/basic_classifier_foundation_design_report.dart --strict',
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

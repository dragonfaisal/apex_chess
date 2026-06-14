import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_prototype_design_validation.dart';

import 'debug_only_bridge_developer_diagnostic_command.dart';

const debugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationExitSuccess =
    0;
const debugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationExitUsage =
    64;
const debugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationExitBlockedStrict =
    68;
const debugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationExitUnsafePolicy =
    69;

enum DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportFormat(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportCommandResult {
  const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportCommandResult({
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
  final DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportFormat
  format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationResult?
  result;
  final String? commandFailure;
}

class _CommandRequest {
  const _CommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const _CommandRequest.invalid(this.failure)
    : isValid = false,
      format =
          DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportFormat
              .markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportFormat
  format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result =
      runDebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportCommand(
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

DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportCommandResult
runDebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportCommand({
  required List<String> args,
  DebugOnlyBridgeSelectedGoldenDiagnosticValidation selectedGoldenValidation =
      const DebugOnlyBridgeSelectedGoldenDiagnosticValidation(),
  DebugOnlyBridgeAnalyzerAdapterBoundaryDesign boundaryDesign =
      const DebugOnlyBridgeAnalyzerAdapterBoundaryDesign(),
  DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidation boundaryValidation =
      const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidation(),
  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign prototypeDesign =
      const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign(),
  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidation validation =
      const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidation(),
}) {
  final request = _parseArgs(args);
  if (!request.isValid) {
    return DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationExitUsage,
      format: request.format,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: '',
      stderrText: _usage(request.failure),
      commandFailure: request.failure,
    );
  }
  if (request.showHelp) {
    return DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationExitSuccess,
      format: request.format,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final selectedGoldenValidationResult = selectedGoldenValidation.evaluate();
  final boundaryDesignResult = boundaryDesign.evaluate(
    selectedGoldenValidationResult: selectedGoldenValidationResult,
  );
  final boundaryValidationResult = boundaryValidation.evaluate(
    boundaryDesignResult: boundaryDesignResult,
    selectedGoldenValidationResult: selectedGoldenValidationResult,
  );
  final prototypeDesignResult = prototypeDesign.evaluate(
    boundaryValidationResult: boundaryValidationResult,
  );
  final result = validation.evaluate(
    prototypeDesignResult: prototypeDesignResult,
  );
  final stdoutText = switch (request.format) {
    DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportFormat
        .markdown =>
      result.renderMarkdown(),
    DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportFormat
        .json =>
      '${result.renderJson()}\n',
  };
  final textFindings =
      const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationValidator()
          .validateReportText(stdoutText);
  final exitCode = _exitCode(
    result,
    request,
    hasTextLeak: textFindings.isNotEmpty,
  );

  return DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportCommandResult(
    exitCode: exitCode,
    format: request.format,
    strict: request.strict,
    safeDemo: request.safeDemo,
    includeWarnings: request.includeWarnings,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

int _exitCode(
  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationResult result,
  _CommandRequest request, {
  required bool hasTextLeak,
}) {
  if (hasTextLeak) {
    return debugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationExitUnsafePolicy;
  }
  if (request.strict && result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationExitBlockedStrict;
  }
  return debugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationExitSuccess;
}

_CommandRequest _parseArgs(List<String> args) {
  var format =
      DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportFormat
          .markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const _CommandRequest.invalid('helpCannotBeCombined');
      }
      return const _CommandRequest.valid(
        format:
            DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportFormat
                .markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const _CommandRequest.invalid('duplicateFormat');
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const _CommandRequest.invalid('unknownFormat');
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
        return const _CommandRequest.invalid('duplicateSafeDemo');
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const _CommandRequest.invalid('duplicateIncludeWarnings');
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const _CommandRequest.invalid('unknownFlag');
  }

  return _CommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportFormat?
_formatByWire(String wire) {
  for (final format
      in DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationReportFormat
          .values) {
    if (format.wire == wire) return format;
  }
  return null;
}

String _usage(String failure) {
  return [
    if (failure.isNotEmpty && failure != 'help') 'error: $failure',
    'usage: dart run tool/debug_only_bridge_analyzer_adapter_boundary_prototype_design_validation_report.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings]',
    'defaults: --format=markdown --safe-demo --include-warnings',
  ].join('\n');
}

const _formatFlag = '--format=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';

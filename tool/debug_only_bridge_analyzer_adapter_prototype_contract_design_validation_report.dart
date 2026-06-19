import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_prototype_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_contract_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_contract_design_validation.dart';

import 'debug_only_bridge_developer_diagnostic_command.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationExitSuccess =
    0;
const debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationExitUsage =
    64;
const debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationExitBlockedStrict =
    68;
const debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationExitUnsafePolicy =
    69;

enum DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportFormat(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportCommandResult {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportCommandResult({
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
  final DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportFormat
  format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationResult?
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
          DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportFormat
              .markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportFormat
  format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result =
      runDebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportCommand(
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

DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportCommandResult
runDebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportCommand({
  required List<String> args,
  DebugOnlyBridgeSelectedGoldenDiagnosticValidation selectedGoldenValidation =
      const DebugOnlyBridgeSelectedGoldenDiagnosticValidation(),
  DebugOnlyBridgeAnalyzerAdapterBoundaryDesign boundaryDesign =
      const DebugOnlyBridgeAnalyzerAdapterBoundaryDesign(),
  DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidation boundaryValidation =
      const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidation(),
  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign prototypeDesign =
      const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign(),
  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidation
      prototypeValidation =
      const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidation(),
  DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign contractDesign =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign(),
  DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidation validation =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidation(),
}) {
  final request = _parseArgs(args);
  if (!request.isValid) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationExitUsage,
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
    return DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationExitSuccess,
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
  final prototypeValidationResult = prototypeValidation.evaluate(
    prototypeDesignResult: prototypeDesignResult,
  );
  final contractDesignResult = contractDesign.evaluate(
    prototypeValidationResult: prototypeValidationResult,
  );
  final result = validation.evaluate(
    contractDesignResult: contractDesignResult,
  );
  final stdoutText = switch (request.format) {
    DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportFormat
        .markdown =>
      result.renderMarkdown(),
    DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportFormat
        .json =>
      '${result.renderJson()}\n',
  };
  final textFindings =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationValidator()
          .validateReportText(stdoutText);
  final exitCode = _exitCode(
    result,
    request,
    hasTextLeak: textFindings.isNotEmpty,
  );

  return DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportCommandResult(
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
  DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationResult result,
  _CommandRequest request, {
  required bool hasTextLeak,
}) {
  if (hasTextLeak) {
    return debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationExitUnsafePolicy;
  }
  if (request.strict && result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationExitBlockedStrict;
  }
  return debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationExitSuccess;
}

_CommandRequest _parseArgs(List<String> args) {
  var format =
      DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportFormat
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
            DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportFormat
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

DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportFormat?
_formatByWire(String wire) {
  for (final format
      in DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationReportFormat
          .values) {
    if (format.wire == wire) return format;
  }
  return null;
}

String _usage(String failure) {
  return [
    if (failure.isNotEmpty && failure != 'help') 'error: $failure',
    'usage: dart run tool/debug_only_bridge_analyzer_adapter_prototype_contract_design_validation_report.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings]',
    'defaults: --format=markdown --safe-demo --include-warnings',
  ].join('\n');
}

const _formatFlag = '--format=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';

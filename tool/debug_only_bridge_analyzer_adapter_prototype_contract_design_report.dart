import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_prototype_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_contract_design.dart';

import 'debug_only_bridge_developer_diagnostic_command.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignExitSuccess = 0;
const debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignExitUsage = 64;
const debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignExitBlockedStrict =
    68;
const debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignExitUnsafePolicy =
    69;

enum DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportFormat(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportCommandResult {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportCommandResult({
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
  final DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportFormat
  format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignResult? result;
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
      format = DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportFormat
          .markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportFormat
  format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result =
      runDebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportCommand(
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

DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportCommandResult
runDebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportCommand({
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
}) {
  final request = _parseArgs(args);
  if (!request.isValid) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportCommandResult(
      exitCode: debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignExitUsage,
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
    return DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignExitSuccess,
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
  final result = contractDesign.evaluate(
    prototypeValidationResult: prototypeValidationResult,
  );
  final stdoutText = switch (request.format) {
    DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportFormat
        .markdown =>
      result.renderMarkdown(),
    DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportFormat.json =>
      '${result.renderJson()}\n',
  };
  final textFindings =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidator()
          .validateReportText(stdoutText);
  final exitCode = _exitCode(
    result,
    request,
    hasTextLeak: textFindings.isNotEmpty,
  );

  return DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportCommandResult(
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
  DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignResult result,
  _CommandRequest request, {
  required bool hasTextLeak,
}) {
  if (hasTextLeak) {
    return debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignExitUnsafePolicy;
  }
  if (request.strict && result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignExitBlockedStrict;
  }
  return debugOnlyBridgeAnalyzerAdapterPrototypeContractDesignExitSuccess;
}

_CommandRequest _parseArgs(List<String> args) {
  var format = DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportFormat
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
            DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportFormat
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

DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportFormat?
_formatByWire(String wire) {
  for (final format
      in DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignReportFormat
          .values) {
    if (format.wire == wire) return format;
  }
  return null;
}

String _usage(String failure) {
  return [
    if (failure.isNotEmpty && failure != 'help') 'error: $failure',
    'usage: dart run tool/debug_only_bridge_analyzer_adapter_prototype_contract_design_report.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings]',
    'defaults: --format=markdown --safe-demo --include-warnings',
  ].join('\n');
}

const _formatFlag = '--format=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';

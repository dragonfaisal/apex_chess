import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design.dart';

import 'debug_only_bridge_developer_diagnostic_command.dart';

const debugOnlyBridgeAnalyzerAdapterBoundaryDesignExitSuccess = 0;
const debugOnlyBridgeAnalyzerAdapterBoundaryDesignExitUsage = 64;
const debugOnlyBridgeAnalyzerAdapterBoundaryDesignExitBlockedStrict = 68;
const debugOnlyBridgeAnalyzerAdapterBoundaryDesignExitUnsafePolicy = 69;

enum DebugOnlyBridgeAnalyzerAdapterBoundaryDesignReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignReportFormat(this.wire);

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterBoundaryDesignReportCommandResult {
  const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignReportCommandResult({
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
  final DebugOnlyBridgeAnalyzerAdapterBoundaryDesignReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyBridgeAnalyzerAdapterBoundaryDesignResult? result;
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
          DebugOnlyBridgeAnalyzerAdapterBoundaryDesignReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeAnalyzerAdapterBoundaryDesignReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runDebugOnlyBridgeAnalyzerAdapterBoundaryDesignReportCommand(
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

DebugOnlyBridgeAnalyzerAdapterBoundaryDesignReportCommandResult
runDebugOnlyBridgeAnalyzerAdapterBoundaryDesignReportCommand({
  required List<String> args,
  DebugOnlyBridgeAnalyzerAdapterBoundaryDesign design =
      const DebugOnlyBridgeAnalyzerAdapterBoundaryDesign(),
  DebugOnlyBridgeSelectedGoldenDiagnosticValidation selectedGoldenValidation =
      const DebugOnlyBridgeSelectedGoldenDiagnosticValidation(),
}) {
  final request = _parseArgs(args);
  if (!request.isValid) {
    return DebugOnlyBridgeAnalyzerAdapterBoundaryDesignReportCommandResult(
      exitCode: debugOnlyBridgeAnalyzerAdapterBoundaryDesignExitUsage,
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
    return DebugOnlyBridgeAnalyzerAdapterBoundaryDesignReportCommandResult(
      exitCode: debugOnlyBridgeAnalyzerAdapterBoundaryDesignExitSuccess,
      format: request.format,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final selectedGoldenValidationResult = selectedGoldenValidation.evaluate();
  final result = design.evaluate(
    selectedGoldenValidationResult: selectedGoldenValidationResult,
  );
  final stdoutText = switch (request.format) {
    DebugOnlyBridgeAnalyzerAdapterBoundaryDesignReportFormat.markdown =>
      result.renderMarkdown(),
    DebugOnlyBridgeAnalyzerAdapterBoundaryDesignReportFormat.json =>
      '${result.renderJson()}\n',
  };
  final textFindings =
      const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidator()
          .validateReportText(stdoutText);
  final exitCode = _exitCode(
    result,
    request,
    hasTextLeak: textFindings.isNotEmpty,
  );

  return DebugOnlyBridgeAnalyzerAdapterBoundaryDesignReportCommandResult(
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
  DebugOnlyBridgeAnalyzerAdapterBoundaryDesignResult result,
  _CommandRequest request, {
  required bool hasTextLeak,
}) {
  if (hasTextLeak) {
    return debugOnlyBridgeAnalyzerAdapterBoundaryDesignExitUnsafePolicy;
  }
  if (request.strict && result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterBoundaryDesignExitBlockedStrict;
  }
  return debugOnlyBridgeAnalyzerAdapterBoundaryDesignExitSuccess;
}

_CommandRequest _parseArgs(List<String> args) {
  var format =
      DebugOnlyBridgeAnalyzerAdapterBoundaryDesignReportFormat.markdown;
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
            DebugOnlyBridgeAnalyzerAdapterBoundaryDesignReportFormat.markdown,
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

DebugOnlyBridgeAnalyzerAdapterBoundaryDesignReportFormat? _formatByWire(
  String wire,
) {
  for (final format
      in DebugOnlyBridgeAnalyzerAdapterBoundaryDesignReportFormat.values) {
    if (format.wire == wire) return format;
  }
  return null;
}

String _usage(String failure) {
  return [
    if (failure.isNotEmpty && failure != 'help') 'error: $failure',
    'usage: dart run tool/debug_only_bridge_analyzer_adapter_boundary_design_report.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings]',
    'defaults: --format=markdown --safe-demo --include-warnings',
  ].join('\n');
}

const _formatFlag = '--format=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';

import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_selected_golden_diagnostic_validation.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

import 'debug_only_bridge_analyzer_adapter_prototype_diagnostic_command.dart'
    as diagnostic_command;

const debugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationExitSuccess =
    0;
const debugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationExitUsage =
    64;
const debugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationExitBlockedStrict =
    68;
const debugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationExitUnsafePolicy =
    69;

enum DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportFormat(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportCommandResult {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportCommandResult({
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
  final DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportFormat
  format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationResult?
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
          DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportFormat
              .markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportFormat
  format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result =
      runDebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportCommand(
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

DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportCommandResult
runDebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportCommand({
  required List<String> args,
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidation
      validation =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidation(),
}) {
  final request = _parseArgs(args);
  if (!request.isValid) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationExitUsage,
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
    return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationExitSuccess,
      format: request.format,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final source = _buildValidationSourceFromDiagnosticCommand();
  final result = validation.evaluate(source: source);
  final stdoutText = switch (request.format) {
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportFormat
        .markdown =>
      result.renderMarkdown(),
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportFormat
        .json =>
      '${result.renderJson()}\n',
  };
  final reportFindings =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationValidator()
          .validateReportTexts(<String>[stdoutText]);
  final exitCode = _exitCode(
    result,
    request,
    hasTextLeak: reportFindings.isNotEmpty,
  );
  return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportCommandResult(
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

DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSource
_buildValidationSourceFromDiagnosticCommand() {
  diagnostic_command.DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandResult
  run(List<String> args) {
    return diagnostic_command
        .runDebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommand(
          args: args,
        );
  }

  final base = run(const <String>[]);
  final defaultMarkdown = run(const <String>['--golden-case=default-selected']);
  final defaultMarkdownRepeat = run(const <String>[
    '--golden-case=default-selected',
  ]);
  final defaultJson = run(const <String>[
    '--golden-case=default-selected',
    '--format=json',
  ]);
  final defaultStrict = run(const <String>[
    '--golden-case=default-selected',
    '--strict',
  ]);
  final allSafeMarkdown = run(const <String>[
    '--golden-case=all-safe-selected',
  ]);
  final allSafeMarkdownRepeat = run(const <String>[
    '--golden-case=all-safe-selected',
  ]);
  final allSafeJson = run(const <String>[
    '--golden-case=all-safe-selected',
    '--format=json',
  ]);
  final allSafeStrict = run(const <String>[
    '--golden-case=all-safe-selected',
    '--strict',
  ]);
  final singleMarkdown = run(const <String>[
    '--golden-case=queen-win-major-swing',
  ]);
  final singleMarkdownRepeat = run(const <String>[
    '--golden-case=queen-win-major-swing',
  ]);
  final listGoldenCases = run(const <String>['--list-golden-cases']);
  final listGoldenCasesRepeat = run(const <String>['--list-golden-cases']);
  final goldenSection = run(const <String>['--section=golden']);
  final goldenSectionRepeat = run(const <String>['--section=golden']);

  final defaultRows = _rowsFromSelected(defaultMarkdown);
  final allSafeRows = _rowsFromSelected(allSafeMarkdown);
  final singleRows = _rowsFromSelected(singleMarkdown);

  return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSource(
    phase33YDiagnosticPathSafe:
        base.exitCode ==
            diagnostic_command
                .debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess &&
        (base.diagnosticResult?.safeForPhase33Z ?? false) &&
        !(base.diagnosticResult?.hasUnsafePolicyViolation ?? true),
    phase33ZSelectedDiagnosticPathSafe:
        _selectedCommandSafe(defaultMarkdown) &&
        _selectedCommandSafe(defaultJson) &&
        _selectedCommandSafe(defaultStrict) &&
        _selectedCommandSafe(allSafeMarkdown) &&
        _selectedCommandSafe(allSafeJson) &&
        _selectedCommandSafe(allSafeStrict) &&
        _selectedCommandSafe(singleMarkdown) &&
        _selectedCommandSafe(goldenSection),
    defaultSelectedOutputDeterministic:
        defaultMarkdown.stdoutText == defaultMarkdownRepeat.stdoutText,
    allSafeSelectedOutputDeterministic:
        allSafeMarkdown.stdoutText == allSafeMarkdownRepeat.stdoutText,
    singleSelectedCaseOutputDeterministic:
        singleMarkdown.stdoutText == singleMarkdownRepeat.stdoutText,
    listGoldenCasesOutputDeterministic:
        listGoldenCases.exitCode ==
            diagnostic_command
                .debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess &&
        listGoldenCases.stdoutText == listGoldenCasesRepeat.stdoutText,
    goldenSectionOutputDeterministic:
        goldenSection.stdoutText == goldenSectionRepeat.stdoutText,
    markdownJsonStrictModesSafe:
        _selectedCommandSafe(defaultMarkdown) &&
        _selectedCommandSafe(defaultJson) &&
        _selectedCommandSafe(defaultStrict) &&
        _selectedCommandSafe(allSafeMarkdown) &&
        _selectedCommandSafe(allSafeJson) &&
        _selectedCommandSafe(allSafeStrict),
    defaultSelectedRows: defaultRows,
    allSafeSelectedRows: allSafeRows,
    singleSelectedRows: singleRows,
    listedGoldenCaseIds:
        GoldenAnalysisCases.defaults.map((item) => item.id).toList()..sort(),
    reportTexts: <String>[
      defaultMarkdown.stdoutText,
      defaultJson.stdoutText,
      defaultStrict.stdoutText,
      allSafeMarkdown.stdoutText,
      allSafeJson.stdoutText,
      allSafeStrict.stdoutText,
      singleMarkdown.stdoutText,
      listGoldenCases.stdoutText,
      goldenSection.stdoutText,
    ],
  );
}

bool _selectedCommandSafe(
  diagnostic_command.DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandResult
  result,
) {
  final selected = result.selectedGoldenDiagnostic;
  return result.exitCode ==
          diagnostic_command
              .debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess &&
      selected != null &&
      selected.safeForPhase34A &&
      !selected.hasUnsafePolicyViolation;
}

List<
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
>
_rowsFromSelected(
  diagnostic_command.DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandResult
  result,
) {
  final selected = result.selectedGoldenDiagnostic;
  if (selected == null) {
    return const <
      DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
    >[];
  }
  return selected.rows
      .map(
        (row) =>
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow(
              caseId: row.caseId,
              title: row.title,
              sourcePhase: row.sourcePhase,
              selectedReason: row.selectedReason,
              diagnosticRole: row.diagnosticRole.wire,
              supportAreaIds: row.supportAreaIds,
              warningReasons: row.warningReasons,
              proofLimitReasons: row.proofLimitReasons,
              androidProofIds: row.androidProofIds,
              ownerProofRequired: row.ownerProofRequired,
              activeDeniedFieldIds: row.activeDeniedFieldIds,
              blockedBoundaryIds: row.blockedBoundaryIds,
              recommendation: row.recommendation,
            ),
      )
      .toList(growable: false);
}

int _exitCode(
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationResult
  result,
  _CommandRequest request, {
  required bool hasTextLeak,
}) {
  if (hasTextLeak) {
    return debugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationExitUnsafePolicy;
  }
  if (request.strict && result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationExitBlockedStrict;
  }
  if (result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationExitUnsafePolicy;
  }
  return debugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationExitSuccess;
}

_CommandRequest _parseArgs(List<String> args) {
  var format =
      DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportFormat
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
            DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportFormat
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
      if (parsed == null) return const _CommandRequest.invalid('unknownFormat');
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

DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportFormat?
_formatByWire(String wire) {
  for (final format
      in DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportFormat
          .values) {
    if (format.wire == wire) return format;
  }
  return null;
}

String _usage(String failure) {
  return [
    if (failure.isNotEmpty && failure != 'help') 'error: $failure',
    'usage: dart run tool/debug_only_bridge_analyzer_adapter_prototype_selected_golden_diagnostic_validation_report.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings]',
    'defaults: --format=markdown --safe-demo --include-warnings',
  ].join('\n');
}

const _formatFlag = '--format=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';

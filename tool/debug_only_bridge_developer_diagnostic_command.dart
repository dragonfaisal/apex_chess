import 'dart:convert';
import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_inspection_harness_validation.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugOnlyBridgeDeveloperDiagnosticCommandVersion =
    'debug-only-bridge-developer-diagnostic-command-v1';

const debugOnlyBridgeDeveloperDiagnosticCommandExitSuccess = 0;
const debugOnlyBridgeDeveloperDiagnosticCommandExitUsage = 64;
const debugOnlyBridgeDeveloperDiagnosticCommandExitBlockedStrict = 68;
const debugOnlyBridgeDeveloperDiagnosticCommandExitUnsafePolicy = 69;

enum DebugOnlyBridgeDeveloperDiagnosticFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeDeveloperDiagnosticFormat(this.wire);

  final String wire;
}

enum DebugOnlyBridgeDeveloperDiagnosticSection {
  all('all'),
  snapshot('snapshot'),
  packets('packets'),
  policy('policy'),
  records('records'),
  boundaries('boundaries'),
  proof('proof'),
  runtime('runtime'),
  recommendation('recommendation'),
  golden('golden');

  const DebugOnlyBridgeDeveloperDiagnosticSection(this.wire);

  final String wire;
}

class DebugOnlyBridgeDeveloperDiagnosticCommandResult {
  const DebugOnlyBridgeDeveloperDiagnosticCommandResult({
    required this.exitCode,
    required this.format,
    required this.section,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    required this.stdoutText,
    required this.stderrText,
    this.goldenCaseSelection,
    this.listGoldenCases = false,
    this.result,
    this.selectedGoldenDiagnostic,
    this.commandFailure,
  });

  final int exitCode;
  final DebugOnlyBridgeDeveloperDiagnosticFormat format;
  final DebugOnlyBridgeDeveloperDiagnosticSection section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final String? goldenCaseSelection;
  final bool listGoldenCases;
  final DebugOnlyBridgeDeveloperInspectionHarnessValidationResult? result;
  final DebugOnlyBridgeSelectedGoldenDiagnosticResult? selectedGoldenDiagnostic;
  final String? commandFailure;
}

class DebugOnlyBridgeDeveloperDiagnosticCommandRequest {
  const DebugOnlyBridgeDeveloperDiagnosticCommandRequest.valid({
    required this.format,
    required this.section,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.goldenCaseSelection,
    this.listGoldenCases = false,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const DebugOnlyBridgeDeveloperDiagnosticCommandRequest.invalid(this.failure)
    : isValid = false,
      format = DebugOnlyBridgeDeveloperDiagnosticFormat.markdown,
      section = DebugOnlyBridgeDeveloperDiagnosticSection.all,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      goldenCaseSelection = null,
      listGoldenCases = false,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeDeveloperDiagnosticFormat format;
  final DebugOnlyBridgeDeveloperDiagnosticSection section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String? goldenCaseSelection;
  final bool listGoldenCases;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runDebugOnlyBridgeDeveloperDiagnosticCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

DebugOnlyBridgeDeveloperDiagnosticCommandResult
runDebugOnlyBridgeDeveloperDiagnosticCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  DebugOnlyBridgeDeveloperInspectionHarnessValidation validation =
      const DebugOnlyBridgeDeveloperInspectionHarnessValidation(),
  DebugOnlyBridgeDeveloperInspectionHarnessValidationRequest? request,
}) {
  final commandRequest = validateDebugOnlyBridgeDeveloperDiagnosticArgs(args);
  if (!commandRequest.isValid) {
    return DebugOnlyBridgeDeveloperDiagnosticCommandResult(
      exitCode: debugOnlyBridgeDeveloperDiagnosticCommandExitUsage,
      format: commandRequest.format,
      section: commandRequest.section,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      goldenCaseSelection: commandRequest.goldenCaseSelection,
      listGoldenCases: commandRequest.listGoldenCases,
      stdoutText: '',
      stderrText: _usage(commandRequest.failure),
      commandFailure: commandRequest.failure,
    );
  }
  if (commandRequest.showHelp) {
    return DebugOnlyBridgeDeveloperDiagnosticCommandResult(
      exitCode: debugOnlyBridgeDeveloperDiagnosticCommandExitSuccess,
      format: commandRequest.format,
      section: commandRequest.section,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      goldenCaseSelection: commandRequest.goldenCaseSelection,
      listGoldenCases: commandRequest.listGoldenCases,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  if (commandRequest.listGoldenCases) {
    final stdoutText = switch (commandRequest.format) {
      DebugOnlyBridgeDeveloperDiagnosticFormat.markdown =>
        _renderGoldenCaseListMarkdown(cases),
      DebugOnlyBridgeDeveloperDiagnosticFormat.json =>
        '${_renderGoldenCaseListJson(cases)}\n',
    };
    return DebugOnlyBridgeDeveloperDiagnosticCommandResult(
      exitCode: debugOnlyBridgeDeveloperDiagnosticCommandExitSuccess,
      format: commandRequest.format,
      section: commandRequest.section,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      goldenCaseSelection: commandRequest.goldenCaseSelection,
      listGoldenCases: true,
      stdoutText: stdoutText,
      stderrText: '',
    );
  }

  final selectedGoldenBuildResult = _buildSelectedGoldenDiagnosticIfRequested(
    commandRequest,
    cases,
  );
  if (selectedGoldenBuildResult.failure != null) {
    return DebugOnlyBridgeDeveloperDiagnosticCommandResult(
      exitCode: debugOnlyBridgeDeveloperDiagnosticCommandExitUsage,
      format: commandRequest.format,
      section: commandRequest.section,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      goldenCaseSelection: commandRequest.goldenCaseSelection,
      listGoldenCases: commandRequest.listGoldenCases,
      stdoutText: '',
      stderrText: _usage(selectedGoldenBuildResult.failure!),
      commandFailure: selectedGoldenBuildResult.failure,
    );
  }
  final selectedGoldenDiagnostic = selectedGoldenBuildResult.result;

  final validationRequest =
      request ??
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = validation.evaluate(validationRequest);
  final stdoutText = switch (commandRequest.format) {
    DebugOnlyBridgeDeveloperDiagnosticFormat.markdown => _renderMarkdown(
      result,
      commandRequest.section,
      selectedGoldenDiagnostic: selectedGoldenDiagnostic,
    ),
    DebugOnlyBridgeDeveloperDiagnosticFormat.json =>
      '${_renderJson(result, commandRequest.section, selectedGoldenDiagnostic: selectedGoldenDiagnostic)}\n',
  };
  final reportFindings =
      const DebugOnlyBridgeDeveloperInspectionHarnessValidationValidator()
          .validateReportText(stdoutText);

  return DebugOnlyBridgeDeveloperDiagnosticCommandResult(
    exitCode: debugOnlyBridgeDeveloperDiagnosticCommandExitCode(
      result,
      commandRequest,
      reportFindings: reportFindings,
      selectedGoldenDiagnostic: selectedGoldenDiagnostic,
    ),
    format: commandRequest.format,
    section: commandRequest.section,
    strict: commandRequest.strict,
    safeDemo: commandRequest.safeDemo,
    includeWarnings: commandRequest.includeWarnings,
    goldenCaseSelection: commandRequest.goldenCaseSelection,
    listGoldenCases: commandRequest.listGoldenCases,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
    selectedGoldenDiagnostic: selectedGoldenDiagnostic,
  );
}

DebugOnlyBridgeDeveloperDiagnosticCommandRequest
validateDebugOnlyBridgeDeveloperDiagnosticArgs(List<String> args) {
  var format = DebugOnlyBridgeDeveloperDiagnosticFormat.markdown;
  var section = DebugOnlyBridgeDeveloperDiagnosticSection.all;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var sectionSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;
  var goldenCaseSelectionSeen = false;
  var listGoldenCasesSeen = false;
  String? goldenCaseSelection;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const DebugOnlyBridgeDeveloperDiagnosticCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const DebugOnlyBridgeDeveloperDiagnosticCommandRequest.valid(
        format: DebugOnlyBridgeDeveloperDiagnosticFormat.markdown,
        section: DebugOnlyBridgeDeveloperDiagnosticSection.all,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        goldenCaseSelection: null,
        listGoldenCases: false,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const DebugOnlyBridgeDeveloperDiagnosticCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const DebugOnlyBridgeDeveloperDiagnosticCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_sectionFlag)) {
      if (sectionSeen) {
        return const DebugOnlyBridgeDeveloperDiagnosticCommandRequest.invalid(
          'duplicateSection',
        );
      }
      final parsed = _sectionByWire(arg.substring(_sectionFlag.length).trim());
      if (parsed == null) {
        return const DebugOnlyBridgeDeveloperDiagnosticCommandRequest.invalid(
          'unknownSection',
        );
      }
      section = parsed;
      sectionSeen = true;
      continue;
    }
    if (arg.startsWith(_goldenCaseFlag)) {
      if (goldenCaseSelectionSeen) {
        return const DebugOnlyBridgeDeveloperDiagnosticCommandRequest.invalid(
          'duplicateGoldenCase',
        );
      }
      goldenCaseSelection = arg.substring(_goldenCaseFlag.length).trim();
      if (goldenCaseSelection.isEmpty) {
        return const DebugOnlyBridgeDeveloperDiagnosticCommandRequest.invalid(
          'emptyGoldenCase',
        );
      }
      goldenCaseSelectionSeen = true;
      continue;
    }
    if (arg == _listGoldenCasesFlag) {
      if (listGoldenCasesSeen) {
        return const DebugOnlyBridgeDeveloperDiagnosticCommandRequest.invalid(
          'duplicateListGoldenCases',
        );
      }
      listGoldenCasesSeen = true;
      continue;
    }
    if (arg == _strictFlag) {
      strict = true;
      continue;
    }
    if (arg == _safeDemoFlag) {
      if (safeDemoSeen) {
        return const DebugOnlyBridgeDeveloperDiagnosticCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const DebugOnlyBridgeDeveloperDiagnosticCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const DebugOnlyBridgeDeveloperDiagnosticCommandRequest.invalid(
      'unknownFlag',
    );
  }

  if (listGoldenCasesSeen && goldenCaseSelectionSeen) {
    return const DebugOnlyBridgeDeveloperDiagnosticCommandRequest.invalid(
      'listGoldenCasesCannotBeCombinedWithGoldenCase',
    );
  }

  return DebugOnlyBridgeDeveloperDiagnosticCommandRequest.valid(
    format: format,
    section: section,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
    goldenCaseSelection: goldenCaseSelection,
    listGoldenCases: listGoldenCasesSeen,
  );
}

int debugOnlyBridgeDeveloperDiagnosticCommandExitCode(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
  DebugOnlyBridgeDeveloperDiagnosticCommandRequest request, {
  List<DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding>
      reportFindings =
      const <DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding>[],
  DebugOnlyBridgeSelectedGoldenDiagnosticResult? selectedGoldenDiagnostic,
}) {
  final hasReportLeak = reportFindings.any((finding) => finding.isCritical);
  if (result
          .hasUnsafeDebugOnlyBridgeDeveloperInspectionHarnessValidationPolicyViolation ||
      hasReportLeak ||
      (selectedGoldenDiagnostic?.hasUnsafePolicyViolation ?? false)) {
    return debugOnlyBridgeDeveloperDiagnosticCommandExitUnsafePolicy;
  }
  if (request.strict &&
      (result.blockerCount > 0 ||
          result.criticalCount > 0 ||
          result.unsafeCount > 0 ||
          result.activeDeniedFieldCount > 0 ||
          result.productOutputCount > 0 ||
          result.labelLeakCount > 0 ||
          result.scoreLeakCount > 0 ||
          result.metricLeakCount > 0 ||
          result.cpLossLeakCount > 0 ||
          result.winProbabilityLeakCount > 0 ||
          result.uiTargetCount > 0 ||
          result.backendTargetCount > 0 ||
          result.persistenceWriteCount > 0 ||
          result.engineCallCount > 0 ||
          result.schedulerExecutionCount > 0 ||
          result.stockfishCommandLeakCount > 0 ||
          result.rawUciLeakCount > 0 ||
          result.pvDumpLeakCount > 0 ||
          result.runtimeEnabledCount > 0 ||
          _hasUnprovenAndroidProof(result) ||
          _hasPhase32ECapturedProofClaim(result) ||
          (selectedGoldenDiagnostic?.hasStrictBlocker ?? false) ||
          !result.safeForPhase33J)) {
    return debugOnlyBridgeDeveloperDiagnosticCommandExitBlockedStrict;
  }
  return debugOnlyBridgeDeveloperDiagnosticCommandExitSuccess;
}

String _renderMarkdown(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
  DebugOnlyBridgeDeveloperDiagnosticSection section, {
  DebugOnlyBridgeSelectedGoldenDiagnosticResult? selectedGoldenDiagnostic,
}) {
  final buffer = StringBuffer()
    ..writeln('# Debug-Only Bridge Developer Diagnostic')
    ..writeln()
    ..writeln('- version: $debugOnlyBridgeDeveloperDiagnosticCommandVersion')
    ..writeln('- diagnostic status: ${result.status.wire}')
    ..writeln('- selected section: ${section.wire}')
    ..writeln('- safe for next step: ${result.safeForPhase33J}')
    ..writeln(
      '- recommendation: proceedToSelectedGoldenBridgeDiagnosticValidation',
    )
    ..writeln();

  if (_includeSection(section, DebugOnlyBridgeDeveloperDiagnosticSection.all)) {
    _writeSourceChain(buffer, result);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeDeveloperDiagnosticSection.snapshot,
  )) {
    _writeSnapshot(buffer, result);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeDeveloperDiagnosticSection.packets,
  )) {
    _writePackets(buffer, result);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeDeveloperDiagnosticSection.policy,
  )) {
    _writePolicy(buffer, result);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeDeveloperDiagnosticSection.records,
  )) {
    _writeRecords(buffer, result);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeDeveloperDiagnosticSection.boundaries,
  )) {
    _writeBoundaries(buffer, result);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeDeveloperDiagnosticSection.proof,
  )) {
    _writeProof(buffer, result);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeDeveloperDiagnosticSection.runtime,
  )) {
    _writeRuntime(buffer, result);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeDeveloperDiagnosticSection.recommendation,
  )) {
    _writeRecommendation(buffer, result);
  }
  if (selectedGoldenDiagnostic != null &&
      _includeSection(
        section,
        DebugOnlyBridgeDeveloperDiagnosticSection.golden,
      )) {
    _writeSelectedGoldenDiagnostic(buffer, selectedGoldenDiagnostic);
  }

  return buffer.toString();
}

String _renderJson(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
  DebugOnlyBridgeDeveloperDiagnosticSection section, {
  DebugOnlyBridgeSelectedGoldenDiagnosticResult? selectedGoldenDiagnostic,
}) {
  return const JsonEncoder.withIndent('  ').convert(
    _jsonPayload(
      result,
      section,
      selectedGoldenDiagnostic: selectedGoldenDiagnostic,
    ),
  );
}

Map<String, Object?> _jsonPayload(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
  DebugOnlyBridgeDeveloperDiagnosticSection section, {
  DebugOnlyBridgeSelectedGoldenDiagnosticResult? selectedGoldenDiagnostic,
}) {
  final payload = <String, Object?>{
    'version': debugOnlyBridgeDeveloperDiagnosticCommandVersion,
    'diagnosticStatus': result.status.wire,
    'section': section.wire,
    'safeForNextStep': result.safeForPhase33J,
    'recommendation': 'proceedToSelectedGoldenBridgeDiagnosticValidation',
    'counts': _countsJson(result),
  };
  if (_includeSection(section, DebugOnlyBridgeDeveloperDiagnosticSection.all)) {
    payload['sourcePhaseChain'] = _sourceChainJson(result);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeDeveloperDiagnosticSection.snapshot,
  )) {
    payload['snapshot'] = _snapshotJson(result);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeDeveloperDiagnosticSection.packets,
  )) {
    payload['packets'] = _packetsJson(result);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeDeveloperDiagnosticSection.policy,
  )) {
    payload['policy'] = _policyJson(result);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeDeveloperDiagnosticSection.records,
  )) {
    payload['records'] = _recordsJson(result);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeDeveloperDiagnosticSection.boundaries,
  )) {
    payload['boundaries'] = _boundariesJson(result);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeDeveloperDiagnosticSection.proof,
  )) {
    payload['proof'] = _proofJson(result);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeDeveloperDiagnosticSection.runtime,
  )) {
    payload['runtime'] = _runtimeJson(result);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeDeveloperDiagnosticSection.recommendation,
  )) {
    payload['next'] = _recommendationJson(result);
  }
  if (selectedGoldenDiagnostic != null &&
      _includeSection(
        section,
        DebugOnlyBridgeDeveloperDiagnosticSection.golden,
      )) {
    payload['selectedGoldenDiagnostic'] = selectedGoldenDiagnostic.toJson();
  }
  return payload;
}

void _writeSourceChain(
  StringBuffer buffer,
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  buffer
    ..writeln('## Source Phase Chain')
    ..writeln('- 33F skeleton: ${result.sourceSkeletonStatus.wire}')
    ..writeln(
      '- 33G skeleton validation: ${result.sourceSkeletonValidationStatus.wire}',
    )
    ..writeln(
      '- 33H inspection harness: ${result.sourceInspectionHarnessStatus.wire}',
    )
    ..writeln('- 33I inspection harness validation: ${result.status.wire}')
    ..writeln();
}

void _writeSnapshot(
  StringBuffer buffer,
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  final snapshot = result.snapshot;
  buffer
    ..writeln('## Inspection Snapshot Summary')
    ..writeln('- snapshot ID: ${snapshot.snapshotId}')
    ..writeln('- input packet ID: ${snapshot.inputPacketId}')
    ..writeln('- output packet ID: ${snapshot.outputPacketId}')
    ..writeln('- skeleton version: ${snapshot.skeletonVersion}')
    ..writeln('- developer-only: ${snapshot.developerOnly}')
    ..writeln('- skeleton-only: ${snapshot.skeletonOnly}')
    ..writeln('- record roles: ${_mapSummary(snapshot.recordRoleSummary)}')
    ..writeln('- allowed fields: ${_ids(snapshot.allowedFieldSummary)}')
    ..writeln('- denied fields: ${_ids(snapshot.deniedFieldSummary)}')
    ..writeln('- warnings: ${_ids(snapshot.warningSummary)}')
    ..writeln(
      '- future prerequisites: ${_ids(snapshot.futurePrerequisiteSummary)}',
    )
    ..writeln();
}

void _writePackets(
  StringBuffer buffer,
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  buffer
    ..writeln('## Input/Output Packet Summary')
    ..writeln('- input packet ID: ${result.inputPacket.inputPacketId}')
    ..writeln(
      '- approved core records: ${_ids(result.inputPacket.approvedCoreRecordIds)}',
    )
    ..writeln(
      '- constrained context records: ${_ids(result.inputPacket.constrainedContextRecordIds)}',
    )
    ..writeln(
      '- inactive blocked records: ${_ids(result.inputPacket.inactiveBlockedRecordIds)}',
    )
    ..writeln(
      '- inactive future records: ${_ids(result.inputPacket.inactiveFutureRecordIds)}',
    )
    ..writeln('- output packet ID: ${result.outputPacket.outputPacketId}')
    ..writeln(
      '- output safe for developer inspection: ${result.outputPacket.safeForDeveloperInspection}',
    )
    ..writeln('- total bridge records: ${result.outputPacket.records.length}')
    ..writeln();
}

void _writePolicy(
  StringBuffer buffer,
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  final policy = result.policy;
  buffer
    ..writeln('## Policy Summary')
    ..writeln('- unsafe allowance: ${policy.hasUnsafeAllowance}')
    ..writeln('- allowed field IDs: ${_ids(policy.allowedFieldIds)}')
    ..writeln('- denied field IDs: ${_ids(policy.deniedFieldIds)}')
    ..writeln(
      '- captured Android proof IDs: ${_ids(policy.capturedAndroidProofIds)}',
    )
    ..writeln('- product output allowed: ${policy.allowProductOutput}')
    ..writeln('- classifier labels allowed: ${policy.allowClassifierLabels}')
    ..writeln('- numeric scores allowed: ${policy.allowNumericScores}')
    ..writeln('- aggregate scores allowed: ${policy.allowAggregateScores}')
    ..writeln('- official metrics allowed: ${policy.allowOfficialMetrics}')
    ..writeln('- CP-loss allowed: ${policy.allowCpLoss}')
    ..writeln('- win probability allowed: ${policy.allowWinProbability}')
    ..writeln('- move ranking allowed: ${policy.allowMoveRanking}')
    ..writeln('- UI allowed: ${policy.allowUi}')
    ..writeln('- backend allowed: ${policy.allowBackend}')
    ..writeln('- persistence allowed: ${policy.allowPersistence}')
    ..writeln('- direct engine allowed: ${policy.allowDirectEngine}')
    ..writeln('- scheduler execution allowed: false')
    ..writeln();
}

void _writeRecords(
  StringBuffer buffer,
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  buffer
    ..writeln('## Record Role Summary')
    ..writeln('| Role | Count |')
    ..writeln('| --- | --- |');
  final summary = result.snapshot.recordRoleSummary.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  for (final entry in summary) {
    buffer.writeln('| ${entry.key} | ${entry.value} |');
  }
  buffer
    ..writeln()
    ..writeln('## Inspection Record Rows')
    ..writeln('| Row | Role | Status | Context-only | Inactive | Findings |')
    ..writeln('| --- | --- | --- | --- | --- | --- |');
  for (final row in result.validationRows.where(
    (row) => row.role.isRecordValidation,
  )) {
    buffer.writeln(
      '| ${row.validationRowId} | ${row.role.wire} | ${row.status.wire} | '
      '${row.contextOnly} | ${row.inactive} | ${_ids(row.findings)} |',
    );
  }
  buffer.writeln();
}

void _writeBoundaries(
  StringBuffer buffer,
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  buffer
    ..writeln('## Boundary Summary')
    ..writeln('- allowed fields: ${_ids(result.snapshot.allowedFieldSummary)}')
    ..writeln('- denied fields: ${_ids(result.snapshot.deniedFieldSummary)}')
    ..writeln(
      '- Stockfish/raw UCI/PV dump denied: ${result.stockfishCommandLeakCount == 0 && result.rawUciLeakCount == 0 && result.pvDumpLeakCount == 0}',
    )
    ..writeln(
      '- scheduler execution denied: ${result.schedulerExecutionCount == 0}',
    )
    ..writeln('- active denied field count: ${result.activeDeniedFieldCount}')
    ..writeln('- product output count: ${result.productOutputCount}')
    ..writeln('- label leak count: ${result.labelLeakCount}')
    ..writeln('- score leak count: ${result.scoreLeakCount}')
    ..writeln('- metric leak count: ${result.metricLeakCount}')
    ..writeln('- CP-loss leak count: ${result.cpLossLeakCount}')
    ..writeln('- win probability leak count: ${result.winProbabilityLeakCount}')
    ..writeln('- UI target count: ${result.uiTargetCount}')
    ..writeln('- backend target count: ${result.backendTargetCount}')
    ..writeln('- persistence write count: ${result.persistenceWriteCount}')
    ..writeln('- engine call count: ${result.engineCallCount}')
    ..writeln();
}

void _writeProof(
  StringBuffer buffer,
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  buffer
    ..writeln('## Android Proof Boundary')
    ..writeln(
      '- captured proof IDs: ${_ids(result.snapshot.proofBoundarySummary)}',
    )
    ..writeln(
      '- phase 32E captured proof claim present: ${_hasPhase32ECapturedProofClaim(result)}',
    )
    ..writeln(
      '- unproven captured proof present: ${_hasUnprovenAndroidProof(result)}',
    )
    ..writeln()
    ..writeln('## Owner Proof Boundary')
    ..writeln('- owner proof queue count: ${result.ownerProofQueueCount}')
    ..writeln();
}

void _writeRuntime(
  StringBuffer buffer,
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  buffer
    ..writeln('## Runtime/Prototype/Wiring Blocked Summary')
    ..writeln(
      '- debug bridge runtime implemented: ${result.debugBridgeRuntimeImplemented}',
    )
    ..writeln(
      '- executable bridge skeleton implemented: ${result.executableBridgeSkeletonImplemented}',
    )
    ..writeln(
      '- executable debug bridge prototype implemented: ${result.executableDebugBridgePrototypeImplemented}',
    )
    ..writeln(
      '- implementation wiring implemented: ${result.implementationWiringImplemented}',
    )
    ..writeln('- runtime enabled count: ${result.runtimeEnabledCount}')
    ..writeln('- engine calls active: ${result.engineCallsActive}')
    ..writeln('- persistence writes active: ${result.persistenceWritesActive}')
    ..writeln('- UI targets active: ${result.uiTargetsActive}')
    ..writeln('- backend output active: ${result.backendOutputActive}')
    ..writeln();
}

void _writeRecommendation(
  StringBuffer buffer,
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  buffer
    ..writeln('## Recommendation')
    ..writeln('- safe for Phase 33J: ${result.safeForPhase33J}')
    ..writeln(
      '- Phase 33I recommendation: ${result.phase33JRecommendation.wire}',
    )
    ..writeln(
      '- next recommendation: proceedToSelectedGoldenBridgeDiagnosticValidation',
    )
    ..writeln('- warning summary: ${_ids(result.warnings)}')
    ..writeln('- failure summary: ${_ids(result.failures)}')
    ..writeln();
}

void _writeSelectedGoldenDiagnostic(
  StringBuffer buffer,
  DebugOnlyBridgeSelectedGoldenDiagnosticResult result,
) {
  buffer
    ..writeln('## Selected Golden Diagnostic')
    ..writeln('- selection: ${result.selection}')
    ..writeln('- status: ${result.status.wire}')
    ..writeln('- safe for next step: ${result.safeForNextStep}')
    ..writeln(
      '- next recommendation: proceedToSelectedGoldenBridgeDiagnosticValidation',
    )
    ..writeln('- selected rows: ${result.rows.length}')
    ..writeln('- blocker count: ${result.blockerCount}')
    ..writeln('- critical count: ${result.criticalCount}')
    ..writeln('- unsafe count: ${result.unsafeCount}')
    ..writeln('- active denied field count: ${result.activeDeniedFieldCount}')
    ..writeln('- product output count: ${result.productOutputCount}')
    ..writeln('- engine call count: ${result.engineCallCount}')
    ..writeln('- scheduler execution count: ${result.schedulerExecutionCount}')
    ..writeln(
      '- Stockfish/raw UCI/PV dump denied: ${result.stockfishCommandLeakCount == 0 && result.rawUciLeakCount == 0 && result.pvDumpLeakCount == 0}',
    )
    ..writeln()
    ..writeln('### Selected Golden Rows')
    ..writeln(
      '| Case ID | Title | Source phase | Role | Selected reason | Support areas | Blocked boundaries | Android proof IDs | Warnings | Proof limits | Owner proof required | Active denied fields | Recommendation |',
    )
    ..writeln(
      '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
    );

  for (final row in result.rows) {
    buffer.writeln(
      '| ${row.caseId} | ${row.caseTitle} | ${row.sourcePhase} | '
      '${row.diagnosticRole.wire} | ${row.selectedReason} | '
      '${_ids(row.supportAreaIds)} | ${_ids(row.blockedBoundaryIds)} | '
      '${_ids(row.androidProofCaseIds)} | ${_ids(row.warningReasons)} | '
      '${_ids(row.proofLimitReasons)} | ${row.ownerProofRequired} | '
      '${_ids(row.activeDeniedFields)} | ${row.recommendation} |',
    );
  }
  buffer.writeln();
}

Map<String, Object?> _sourceChainJson(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  return <String, Object?>{
    'phase33F': result.sourceSkeletonStatus.wire,
    'phase33G': result.sourceSkeletonValidationStatus.wire,
    'phase33H': result.sourceInspectionHarnessStatus.wire,
    'phase33I': result.status.wire,
  };
}

Map<String, Object?> _snapshotJson(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  final snapshot = result.snapshot;
  return <String, Object?>{
    'snapshotId': snapshot.snapshotId,
    'inputPacketId': snapshot.inputPacketId,
    'outputPacketId': snapshot.outputPacketId,
    'skeletonVersion': snapshot.skeletonVersion,
    'developerOnly': snapshot.developerOnly,
    'skeletonOnly': snapshot.skeletonOnly,
    'recordRoleSummary': snapshot.recordRoleSummary,
    'allowedFieldSummary': snapshot.allowedFieldSummary,
    'deniedFieldSummary': snapshot.deniedFieldSummary,
    'warningSummary': snapshot.warningSummary,
    'futurePrerequisiteSummary': snapshot.futurePrerequisiteSummary,
  };
}

Map<String, Object?> _packetsJson(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  return <String, Object?>{
    'inputPacketId': result.inputPacket.inputPacketId,
    'outputPacketId': result.outputPacket.outputPacketId,
    'approvedCoreRecordIds': result.inputPacket.approvedCoreRecordIds,
    'constrainedContextRecordIds':
        result.inputPacket.constrainedContextRecordIds,
    'inactiveBlockedRecordIds': result.inputPacket.inactiveBlockedRecordIds,
    'inactiveFutureRecordIds': result.inputPacket.inactiveFutureRecordIds,
    'safeForDeveloperInspection':
        result.outputPacket.safeForDeveloperInspection,
    'totalBridgeRecords': result.outputPacket.records.length,
  };
}

Map<String, Object?> _policyJson(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  final policy = result.policy;
  return <String, Object?>{
    'hasUnsafeAllowance': policy.hasUnsafeAllowance,
    'allowedFieldIds': policy.allowedFieldIds,
    'deniedFieldIds': policy.deniedFieldIds,
    'capturedAndroidProofIds': policy.capturedAndroidProofIds,
    'allowProductOutput': policy.allowProductOutput,
    'allowClassifierLabels': policy.allowClassifierLabels,
    'allowNumericScores': policy.allowNumericScores,
    'allowAggregateScores': policy.allowAggregateScores,
    'allowOfficialMetrics': policy.allowOfficialMetrics,
    'allowCpLoss': policy.allowCpLoss,
    'allowWinProbability': policy.allowWinProbability,
    'allowMoveRanking': policy.allowMoveRanking,
    'allowUi': policy.allowUi,
    'allowBackend': policy.allowBackend,
    'allowPersistence': policy.allowPersistence,
    'allowDirectEngine': policy.allowDirectEngine,
    'allowSchedulerExecution': false,
  };
}

Map<String, Object?> _recordsJson(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  return <String, Object?>{
    'recordRoleSummary': result.snapshot.recordRoleSummary,
    'validationRows': result.validationRows
        .where((row) => row.role.isRecordValidation)
        .map(
          (row) => <String, Object?>{
            'validationRowId': row.validationRowId,
            'role': row.role.wire,
            'status': row.status.wire,
            'contextOnly': row.contextOnly,
            'inactive': row.inactive,
            'findings': row.findings,
          },
        )
        .toList(),
  };
}

Map<String, Object?> _boundariesJson(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  return <String, Object?>{
    'allowedFieldIds': result.snapshot.allowedFieldSummary,
    'deniedFieldIds': result.snapshot.deniedFieldSummary,
    'stockfishRawUciPvDumpDenied':
        result.stockfishCommandLeakCount == 0 &&
        result.rawUciLeakCount == 0 &&
        result.pvDumpLeakCount == 0,
    'schedulerExecutionDenied': result.schedulerExecutionCount == 0,
    'activeDeniedFieldCount': result.activeDeniedFieldCount,
    'productOutputCount': result.productOutputCount,
    'labelLeakCount': result.labelLeakCount,
    'scoreLeakCount': result.scoreLeakCount,
    'metricLeakCount': result.metricLeakCount,
    'cpLossLeakCount': result.cpLossLeakCount,
    'winProbabilityLeakCount': result.winProbabilityLeakCount,
    'uiTargetCount': result.uiTargetCount,
    'backendTargetCount': result.backendTargetCount,
    'persistenceWriteCount': result.persistenceWriteCount,
    'engineCallCount': result.engineCallCount,
  };
}

Map<String, Object?> _proofJson(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  return <String, Object?>{
    'capturedProofIds': result.snapshot.proofBoundarySummary,
    'phase32ECapturedProofClaimPresent': _hasPhase32ECapturedProofClaim(result),
    'unprovenCapturedProofPresent': _hasUnprovenAndroidProof(result),
    'ownerProofQueueCount': result.ownerProofQueueCount,
  };
}

Map<String, Object?> _runtimeJson(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  return <String, Object?>{
    'debugBridgeRuntimeImplemented': result.debugBridgeRuntimeImplemented,
    'executableBridgeSkeletonImplemented':
        result.executableBridgeSkeletonImplemented,
    'executableDebugBridgePrototypeImplemented':
        result.executableDebugBridgePrototypeImplemented,
    'implementationWiringImplemented': result.implementationWiringImplemented,
    'runtimeEnabledCount': result.runtimeEnabledCount,
    'engineCallsActive': result.engineCallsActive,
    'persistenceWritesActive': result.persistenceWritesActive,
    'uiTargetsActive': result.uiTargetsActive,
    'backendOutputActive': result.backendOutputActive,
  };
}

Map<String, Object?> _recommendationJson(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  return <String, Object?>{
    'safeForPhase33J': result.safeForPhase33J,
    'phase33IRecommendation': result.phase33JRecommendation.wire,
    'nextRecommendation': 'proceedToSelectedGoldenBridgeDiagnosticValidation',
    'warnings': result.warnings,
    'failures': result.failures,
  };
}

Map<String, Object?> _countsJson(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  return <String, Object?>{
    'blockerCount': result.blockerCount,
    'criticalCount': result.criticalCount,
    'unsafeCount': result.unsafeCount,
    'activeDeniedFieldCount': result.activeDeniedFieldCount,
    'productOutputCount': result.productOutputCount,
    'labelLeakCount': result.labelLeakCount,
    'scoreLeakCount': result.scoreLeakCount,
    'metricLeakCount': result.metricLeakCount,
    'cpLossLeakCount': result.cpLossLeakCount,
    'winProbabilityLeakCount': result.winProbabilityLeakCount,
    'uiTargetCount': result.uiTargetCount,
    'backendTargetCount': result.backendTargetCount,
    'persistenceWriteCount': result.persistenceWriteCount,
    'engineCallCount': result.engineCallCount,
    'schedulerExecutionCount': result.schedulerExecutionCount,
    'stockfishCommandLeakCount': result.stockfishCommandLeakCount,
    'rawUciLeakCount': result.rawUciLeakCount,
    'pvDumpLeakCount': result.pvDumpLeakCount,
  };
}

enum DebugOnlyBridgeSelectedGoldenDiagnosticStatus {
  selectedGoldenDiagnosticReadyWithWarnings(
    'selectedGoldenDiagnosticReadyWithWarnings',
  ),
  selectedGoldenDiagnosticReadyClean('selectedGoldenDiagnosticReadyClean'),
  blockedByUnsafeGoldenSelection('blockedByUnsafeGoldenSelection'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidGoldenSelection('invalidGoldenSelection');

  const DebugOnlyBridgeSelectedGoldenDiagnosticStatus(this.wire);

  final String wire;
}

enum DebugOnlyBridgeSelectedGoldenDiagnosticRole {
  coreSupport('coreSupport'),
  contextOnly('contextOnly'),
  proofBoundaryOnly('proofBoundaryOnly'),
  warningLimited('warningLimited'),
  excludedNegativeGuard('excludedNegativeGuard');

  const DebugOnlyBridgeSelectedGoldenDiagnosticRole(this.wire);

  final String wire;
}

class DebugOnlyBridgeSelectedGoldenDiagnosticRow {
  const DebugOnlyBridgeSelectedGoldenDiagnosticRow({
    required this.caseId,
    required this.caseTitle,
    required this.sourcePhase,
    required this.selectedReason,
    required this.diagnosticRole,
    required this.supportAreaIds,
    required this.blockedBoundaryIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.androidProofCaseIds,
    required this.ownerProofRequired,
    required this.activeDeniedFields,
    required this.recommendation,
  });

  final String caseId;
  final String caseTitle;
  final String sourcePhase;
  final String selectedReason;
  final DebugOnlyBridgeSelectedGoldenDiagnosticRole diagnosticRole;
  final List<String> supportAreaIds;
  final List<String> blockedBoundaryIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofCaseIds;
  final bool ownerProofRequired;
  final List<String> activeDeniedFields;
  final String recommendation;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'caseId': caseId,
      'caseName': caseTitle,
      'sourcePhase': sourcePhase,
      'selectedReason': selectedReason,
      'diagnosticRole': diagnosticRole.wire,
      'supportAreaIds': supportAreaIds,
      'blockedBoundaryIds': blockedBoundaryIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'androidProofCaseIds': androidProofCaseIds,
      'ownerProofRequired': ownerProofRequired,
      'activeDeniedFields': activeDeniedFields,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyBridgeSelectedGoldenDiagnosticResult {
  DebugOnlyBridgeSelectedGoldenDiagnosticResult({
    required this.selection,
    required this.rows,
  }) : activeDeniedFieldCount = rows.fold<int>(
         0,
         (total, row) => total + row.activeDeniedFields.length,
       ),
       unprovenAndroidProofCount = rows
           .where(
             (row) => row.androidProofCaseIds.any(
               (caseId) => !_capturedAndroidProofIds.contains(caseId),
             ),
           )
           .length,
       phase32ECapturedProofClaimCount = rows
           .where(
             (row) => row.androidProofCaseIds.any(_phase32ECaseIds.contains),
           )
           .length,
       quietPreparatoryCoreActivationCount = rows
           .where(
             (row) =>
                 row.diagnosticRole ==
                     DebugOnlyBridgeSelectedGoldenDiagnosticRole.coreSupport &&
                 row.supportAreaIds.contains('quietPreparatoryMove'),
           )
           .length,
       ownerProofWithoutReasonCount = rows
           .where(
             (row) =>
                 row.ownerProofRequired &&
                 !row.proofLimitReasons.any(
                   (reason) => reason.contains('pvMultiPv'),
                 ),
           )
           .length {
    final hasPolicyLeak =
        activeDeniedFieldCount > 0 ||
        unprovenAndroidProofCount > 0 ||
        phase32ECapturedProofClaimCount > 0 ||
        quietPreparatoryCoreActivationCount > 0 ||
        ownerProofWithoutReasonCount > 0;
    productOutputCount = 0;
    labelLeakCount = 0;
    scoreLeakCount = 0;
    metricLeakCount = 0;
    cpLossLeakCount = 0;
    winProbabilityLeakCount = 0;
    uiTargetCount = 0;
    backendTargetCount = 0;
    persistenceWriteCount = 0;
    engineCallCount = 0;
    schedulerExecutionCount = 0;
    stockfishCommandLeakCount = 0;
    rawUciLeakCount = 0;
    pvDumpLeakCount = 0;
    blockerCount = hasPolicyLeak ? 1 : 0;
    criticalCount = 0;
    unsafeCount = hasPolicyLeak ? 1 : 0;
    safeForNextStep = !hasPolicyLeak;
    status = hasPolicyLeak
        ? DebugOnlyBridgeSelectedGoldenDiagnosticStatus
              .blockedByUnsafeGoldenSelection
        : rows.any(
            (row) =>
                row.warningReasons.isNotEmpty ||
                row.proofLimitReasons.isNotEmpty,
          )
        ? DebugOnlyBridgeSelectedGoldenDiagnosticStatus
              .selectedGoldenDiagnosticReadyWithWarnings
        : DebugOnlyBridgeSelectedGoldenDiagnosticStatus
              .selectedGoldenDiagnosticReadyClean;
  }

  final String selection;
  final List<DebugOnlyBridgeSelectedGoldenDiagnosticRow> rows;
  late final DebugOnlyBridgeSelectedGoldenDiagnosticStatus status;
  late final bool safeForNextStep;
  late final int blockerCount;
  late final int criticalCount;
  late final int unsafeCount;
  final int activeDeniedFieldCount;
  late final int productOutputCount;
  late final int labelLeakCount;
  late final int scoreLeakCount;
  late final int metricLeakCount;
  late final int cpLossLeakCount;
  late final int winProbabilityLeakCount;
  late final int uiTargetCount;
  late final int backendTargetCount;
  late final int persistenceWriteCount;
  late final int engineCallCount;
  late final int schedulerExecutionCount;
  late final int stockfishCommandLeakCount;
  late final int rawUciLeakCount;
  late final int pvDumpLeakCount;
  final int unprovenAndroidProofCount;
  final int phase32ECapturedProofClaimCount;
  final int quietPreparatoryCoreActivationCount;
  final int ownerProofWithoutReasonCount;

  bool get hasUnsafePolicyViolation =>
      blockerCount > 0 ||
      criticalCount > 0 ||
      unsafeCount > 0 ||
      activeDeniedFieldCount > 0 ||
      productOutputCount > 0 ||
      labelLeakCount > 0 ||
      scoreLeakCount > 0 ||
      metricLeakCount > 0 ||
      cpLossLeakCount > 0 ||
      winProbabilityLeakCount > 0 ||
      uiTargetCount > 0 ||
      backendTargetCount > 0 ||
      persistenceWriteCount > 0 ||
      engineCallCount > 0 ||
      schedulerExecutionCount > 0 ||
      stockfishCommandLeakCount > 0 ||
      rawUciLeakCount > 0 ||
      pvDumpLeakCount > 0 ||
      unprovenAndroidProofCount > 0 ||
      phase32ECapturedProofClaimCount > 0 ||
      quietPreparatoryCoreActivationCount > 0 ||
      ownerProofWithoutReasonCount > 0 ||
      !safeForNextStep;

  bool get hasStrictBlocker => hasUnsafePolicyViolation;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'selection': selection,
      'status': status.wire,
      'safeForNextStep': safeForNextStep,
      'nextRecommendation': 'proceedToSelectedGoldenBridgeDiagnosticValidation',
      'counts': <String, Object?>{
        'selectedRowCount': rows.length,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'unsafeCount': unsafeCount,
        'activeDeniedFieldCount': activeDeniedFieldCount,
        'productOutputCount': productOutputCount,
        'labelLeakCount': labelLeakCount,
        'scoreLeakCount': scoreLeakCount,
        'metricLeakCount': metricLeakCount,
        'cpLossLeakCount': cpLossLeakCount,
        'winProbabilityLeakCount': winProbabilityLeakCount,
        'uiTargetCount': uiTargetCount,
        'backendTargetCount': backendTargetCount,
        'persistenceWriteCount': persistenceWriteCount,
        'engineCallCount': engineCallCount,
        'schedulerExecutionCount': schedulerExecutionCount,
        'stockfishCommandLeakCount': stockfishCommandLeakCount,
        'rawUciLeakCount': rawUciLeakCount,
        'pvDumpLeakCount': pvDumpLeakCount,
        'unprovenAndroidProofCount': unprovenAndroidProofCount,
        'phase32ECapturedProofClaimCount': phase32ECapturedProofClaimCount,
        'quietPreparatoryCoreActivationCount':
            quietPreparatoryCoreActivationCount,
        'ownerProofWithoutReasonCount': ownerProofWithoutReasonCount,
      },
      'rows': rows.map((row) => row.toJson()).toList(growable: false),
    };
  }
}

const debugOnlyBridgeSelectedGoldenDiagnosticValidationReportVersion =
    'debug-only-bridge-selected-golden-diagnostic-validation-v1';

enum DebugOnlyBridgeSelectedGoldenDiagnosticValidationStatus {
  selectedGoldenDiagnosticValidatedWithWarnings(
    'selectedGoldenDiagnosticValidatedWithWarnings',
  ),
  selectedGoldenDiagnosticValidatedClean(
    'selectedGoldenDiagnosticValidatedClean',
  ),
  blockedByUnsafeGoldenDiagnostic('blockedByUnsafeGoldenDiagnostic'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidGoldenDiagnostic('invalidGoldenDiagnostic');

  const DebugOnlyBridgeSelectedGoldenDiagnosticValidationStatus(this.wire);

  final String wire;
}

enum DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId {
  defaultSelectedSetIsSafe('defaultSelectedSetIsSafe'),
  allSafeSelectedSetIsSafe('allSafeSelectedSetIsSafe'),
  singleKnownGoldenCaseIsSafe('singleKnownGoldenCaseIsSafe'),
  listGoldenCasesIsSafe('listGoldenCasesIsSafe'),
  goldenSectionIsSafe('goldenSectionIsSafe'),
  selectedRowsAreDeterministic('selectedRowsAreDeterministic'),
  selectedRolesAreAllowed('selectedRolesAreAllowed'),
  quietPreparatoryRemainsExcludedNegativeGuard(
    'quietPreparatoryRemainsExcludedNegativeGuard',
  ),
  phase32ECasesDoNotClaimCapturedAndroidProof(
    'phase32ECasesDoNotClaimCapturedAndroidProof',
  ),
  pvMultiPvCaseRemainsBoundaryOnly('pvMultiPvCaseRemainsBoundaryOnly'),
  androidProofIdsRemainCapturedOnly('androidProofIdsRemainCapturedOnly'),
  ownerProofQueueRemainsEmpty('ownerProofQueueRemainsEmpty'),
  deniedFieldsRemainInactive('deniedFieldsRemainInactive'),
  noLabelsScoresRankingsMetrics('noLabelsScoresRankingsMetrics'),
  noCpLossOrWinProbability('noCpLossOrWinProbability'),
  noStockfishCommandRawUciPvDump('noStockfishCommandRawUciPvDump'),
  noUiBackendPersistenceEngineScheduler(
    'noUiBackendPersistenceEngineScheduler',
  ),
  reportContainsNoRawUciOrPvDump('reportContainsNoRawUciOrPvDump'),
  phase33MRequirementPresent('phase33MRequirementPresent');

  const DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId(this.wire);

  final String wire;
}

enum DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckStatus {
  passed('passed'),
  passedWithWarnings('passedWithWarnings'),
  failed('failed'),
  blocked('blocked');

  const DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckStatus(this.wire);

  final String wire;

  bool get isPassed => this == passed || this == passedWithWarnings;

  bool get isWarning => this == passedWithWarnings;
}

enum DebugOnlyBridgeSelectedGoldenDiagnosticValidationRowStatus {
  valid('valid'),
  validWithWarnings('validWithWarnings'),
  unsafeRow('unsafeRow'),
  invalidRow('invalidRow');

  const DebugOnlyBridgeSelectedGoldenDiagnosticValidationRowStatus(this.wire);

  final String wire;

  bool get isUnsafe => this == unsafeRow;

  bool get isInvalid => this == invalidRow;
}

class DebugOnlyBridgeSelectedGoldenDiagnosticValidationFinding {
  const DebugOnlyBridgeSelectedGoldenDiagnosticValidationFinding({
    required this.id,
    required this.message,
    this.critical = false,
  });

  final String id;
  final String message;
  final bool critical;

  bool get isBlocker => !critical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'message': message,
      'critical': critical,
    };
  }
}

class DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheck {
  const DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheck({
    required this.checkId,
    required this.status,
    this.findings = const <String>[],
  });

  final DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId checkId;
  final DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckStatus status;
  final List<String> findings;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'checkId': checkId.wire,
      'status': status.wire,
      'findings': findings,
    };
  }
}

class DebugOnlyBridgeSelectedGoldenDiagnosticValidationRow {
  const DebugOnlyBridgeSelectedGoldenDiagnosticValidationRow({
    required this.validationRowId,
    required this.caseId,
    required this.sourcePhase,
    required this.selectedReason,
    required this.diagnosticRole,
    required this.supportAreaIds,
    required this.blockedBoundaryIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.androidProofCaseIds,
    required this.ownerProofRequired,
    required this.activeDeniedFields,
    required this.status,
    required this.findings,
    required this.recommendation,
  });

  final String validationRowId;
  final String caseId;
  final String sourcePhase;
  final String selectedReason;
  final DebugOnlyBridgeSelectedGoldenDiagnosticRole diagnosticRole;
  final List<String> supportAreaIds;
  final List<String> blockedBoundaryIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofCaseIds;
  final bool ownerProofRequired;
  final List<String> activeDeniedFields;
  final DebugOnlyBridgeSelectedGoldenDiagnosticValidationRowStatus status;
  final List<String> findings;
  final String recommendation;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'validationRowId': validationRowId,
      'caseId': caseId,
      'sourcePhase': sourcePhase,
      'selectedReason': selectedReason,
      'diagnosticRole': diagnosticRole.wire,
      'supportAreaIds': supportAreaIds,
      'blockedBoundaryIds': blockedBoundaryIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'androidProofCaseIds': androidProofCaseIds,
      'ownerProofRequired': ownerProofRequired,
      'activeDeniedFields': activeDeniedFields,
      'status': status.wire,
      'findings': findings,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyBridgeSelectedGoldenDiagnosticValidationResult {
  DebugOnlyBridgeSelectedGoldenDiagnosticValidationResult({
    required this.status,
    required this.checks,
    required this.selectedRows,
    required this.defaultSelectedRowCount,
    required this.allSafeSelectedRowCount,
    required this.safeForPhase33M,
    required this.phase33MRecommendation,
    required this.reportFindings,
  }) : totalChecks = checks.length,
       passedCheckCount = checks.where((check) => check.status.isPassed).length,
       warningCheckCount = checks
           .where((check) => check.status.isWarning)
           .length,
       blockerCount =
           checks
               .where(
                 (check) =>
                     check.status ==
                     DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckStatus
                         .blocked,
               )
               .length +
           reportFindings.where((finding) => finding.isBlocker).length,
       criticalCount = reportFindings
           .where((finding) => finding.critical)
           .length,
       totalSelectedRows = selectedRows.length,
       coreSupportRowCount = selectedRows
           .where(
             (row) =>
                 row.diagnosticRole ==
                 DebugOnlyBridgeSelectedGoldenDiagnosticRole.coreSupport,
           )
           .length,
       contextOnlyRowCount = selectedRows
           .where(
             (row) =>
                 row.diagnosticRole ==
                 DebugOnlyBridgeSelectedGoldenDiagnosticRole.contextOnly,
           )
           .length,
       proofBoundaryOnlyRowCount = selectedRows
           .where(
             (row) =>
                 row.diagnosticRole ==
                 DebugOnlyBridgeSelectedGoldenDiagnosticRole.proofBoundaryOnly,
           )
           .length,
       warningLimitedRowCount = selectedRows
           .where(
             (row) =>
                 row.diagnosticRole ==
                 DebugOnlyBridgeSelectedGoldenDiagnosticRole.warningLimited,
           )
           .length,
       excludedNegativeGuardRowCount = selectedRows
           .where(
             (row) =>
                 row.diagnosticRole ==
                 DebugOnlyBridgeSelectedGoldenDiagnosticRole
                     .excludedNegativeGuard,
           )
           .length,
       invalidRowCount = selectedRows
           .where((row) => row.status.isInvalid)
           .length,
       unsafeRowCount = selectedRows.where((row) => row.status.isUnsafe).length,
       activeDeniedFieldCount = selectedRows.fold<int>(
         0,
         (total, row) => total + row.activeDeniedFields.length,
       ),
       productOutputCount = _countActiveFields(selectedRows, _productFields),
       labelLeakCount = _countActiveFields(selectedRows, _labelFields),
       scoreLeakCount = _countActiveFields(selectedRows, _scoreFields),
       metricLeakCount = _countActiveFields(selectedRows, _metricFields),
       cpLossLeakCount = _countActiveFields(selectedRows, const {'cpLoss'}),
       winProbabilityLeakCount = _countActiveFields(selectedRows, const {
         'winProbability',
       }),
       moveRankingLeakCount = _countActiveFields(selectedRows, const {
         'moveRanking',
       }),
       uiTargetCount = _countActiveFields(selectedRows, const {'uiOutput'}),
       backendTargetCount = _countActiveFields(selectedRows, const {
         'backendOutput',
         'backendTarget',
       }),
       persistenceWriteCount = _countActiveFields(selectedRows, const {
         'persistenceOutput',
         'persistenceWrite',
       }),
       engineCallCount = _countActiveFields(selectedRows, const {
         'directEngineCall',
         'engineResults',
       }),
       schedulerExecutionCount = _countActiveFields(selectedRows, const {
         'schedulerExecution',
       }),
       androidCollectorExecutionCount = _countActiveFields(selectedRows, const {
         'androidCollectorExecution',
       }),
       stockfishCommandLeakCount = _countActiveFields(selectedRows, const {
         'stockfishCommand',
       }),
       rawUciLeakCount = _countActiveFields(selectedRows, const {'rawUci'}),
       pvDumpLeakCount = _countActiveFields(selectedRows, const {'pvDump'}),
       unprovenAndroidProofCount = selectedRows
           .where(
             (row) => row.androidProofCaseIds.any(
               (caseId) => !_capturedAndroidProofIds.contains(caseId),
             ),
           )
           .length,
       phase32EProofClaimCount = selectedRows
           .where(
             (row) =>
                 _phase32ECaseIds.contains(row.caseId) &&
                 row.androidProofCaseIds.isNotEmpty,
           )
           .length,
       ownerProofQueueCount = selectedRows
           .where((row) => row.ownerProofRequired)
           .length {
    unsafeCount =
        unsafeRowCount +
        activeDeniedFieldCount +
        productOutputCount +
        labelLeakCount +
        scoreLeakCount +
        metricLeakCount +
        cpLossLeakCount +
        winProbabilityLeakCount +
        moveRankingLeakCount +
        uiTargetCount +
        backendTargetCount +
        persistenceWriteCount +
        engineCallCount +
        schedulerExecutionCount +
        androidCollectorExecutionCount +
        stockfishCommandLeakCount +
        rawUciLeakCount +
        pvDumpLeakCount +
        unprovenAndroidProofCount +
        phase32EProofClaimCount +
        ownerProofQueueCount;
  }

  final DebugOnlyBridgeSelectedGoldenDiagnosticValidationStatus status;
  final List<DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheck> checks;
  final List<DebugOnlyBridgeSelectedGoldenDiagnosticValidationRow> selectedRows;
  final int totalChecks;
  final int passedCheckCount;
  final int warningCheckCount;
  final int blockerCount;
  final int criticalCount;
  late final int unsafeCount;
  final int totalSelectedRows;
  final int defaultSelectedRowCount;
  final int allSafeSelectedRowCount;
  final int coreSupportRowCount;
  final int contextOnlyRowCount;
  final int proofBoundaryOnlyRowCount;
  final int warningLimitedRowCount;
  final int excludedNegativeGuardRowCount;
  final int invalidRowCount;
  final int unsafeRowCount;
  final int activeDeniedFieldCount;
  final int productOutputCount;
  final int labelLeakCount;
  final int scoreLeakCount;
  final int metricLeakCount;
  final int cpLossLeakCount;
  final int winProbabilityLeakCount;
  final int moveRankingLeakCount;
  final int uiTargetCount;
  final int backendTargetCount;
  final int persistenceWriteCount;
  final int engineCallCount;
  final int schedulerExecutionCount;
  final int androidCollectorExecutionCount;
  final int stockfishCommandLeakCount;
  final int rawUciLeakCount;
  final int pvDumpLeakCount;
  final int unprovenAndroidProofCount;
  final int phase32EProofClaimCount;
  final int ownerProofQueueCount;
  final bool safeForPhase33M;
  final String phase33MRecommendation;
  final List<DebugOnlyBridgeSelectedGoldenDiagnosticValidationFinding>
  reportFindings;

  bool get hasUnsafePolicyViolation =>
      blockerCount > 0 ||
      criticalCount > 0 ||
      unsafeCount > 0 ||
      !safeForPhase33M;

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Debug-Only Bridge Selected Golden Diagnostic Validation')
      ..writeln()
      ..writeln(
        '- version: $debugOnlyBridgeSelectedGoldenDiagnosticValidationReportVersion',
      )
      ..writeln('- validation status: ${status.wire}')
      ..writeln('- safe for Phase 33M: $safeForPhase33M')
      ..writeln('- Phase 33M recommendation: $phase33MRecommendation')
      ..writeln('- blocker count: $blockerCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- product output count: $productOutputCount')
      ..writeln('- engine call count: $engineCallCount')
      ..writeln('- scheduler execution count: $schedulerExecutionCount')
      ..writeln(
        '- Android collector execution count: $androidCollectorExecutionCount',
      )
      ..writeln()
      ..writeln('## Validation Check Table')
      ..writeln('| Check | Status | Findings |')
      ..writeln('| --- | --- | --- |');
    for (final check in checks) {
      buffer.writeln(
        '| ${check.checkId.wire} | ${check.status.wire} | ${_ids(check.findings)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Selected Row Validation Table')
      ..writeln(
        '| Row | Case ID | Source phase | Role | Status | Support areas | Blocked boundaries | Android proof IDs | Owner proof | Active denied fields | Findings | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final row in selectedRows) {
      buffer.writeln(
        '| ${row.validationRowId} | ${row.caseId} | ${row.sourcePhase} | '
        '${row.diagnosticRole.wire} | ${row.status.wire} | '
        '${_ids(row.supportAreaIds)} | ${_ids(row.blockedBoundaryIds)} | '
        '${_ids(row.androidProofCaseIds)} | ${row.ownerProofRequired} | '
        '${_ids(row.activeDeniedFields)} | ${_ids(row.findings)} | '
        '${row.recommendation} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Default Selected Set Validation')
      ..writeln('- default selected row count: $defaultSelectedRowCount')
      ..writeln('- default selected set is safe: ${blockerCount == 0}')
      ..writeln()
      ..writeln('## All-Safe Selected Set Validation')
      ..writeln('- all-safe selected row count: $allSafeSelectedRowCount')
      ..writeln(
        '- quiet/preparatory excluded negative guard rows: $excludedNegativeGuardRowCount',
      )
      ..writeln()
      ..writeln('## Phase 32E Proof Honesty Validation')
      ..writeln('- Phase 32E proof claim count: $phase32EProofClaimCount')
      ..writeln('- unproven Android proof count: $unprovenAndroidProofCount')
      ..writeln()
      ..writeln('## PV/MultiPV Boundary-Only Validation')
      ..writeln('- proof-boundary-only row count: $proofBoundaryOnlyRowCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln()
      ..writeln('## Allowed/Denied Field Validation')
      ..writeln('- active denied field count: $activeDeniedFieldCount')
      ..writeln('- label leak count: $labelLeakCount')
      ..writeln('- score leak count: $scoreLeakCount')
      ..writeln('- metric leak count: $metricLeakCount')
      ..writeln('- CP-loss leak count: $cpLossLeakCount')
      ..writeln('- win probability leak count: $winProbabilityLeakCount')
      ..writeln('- move ranking leak count: $moveRankingLeakCount')
      ..writeln('- Stockfish command leak count: $stockfishCommandLeakCount')
      ..writeln('- raw UCI leak count: $rawUciLeakCount')
      ..writeln('- PV dump leak count: $pvDumpLeakCount')
      ..writeln()
      ..writeln('## Boundary Validation')
      ..writeln('- UI target count: $uiTargetCount')
      ..writeln('- backend target count: $backendTargetCount')
      ..writeln('- persistence write count: $persistenceWriteCount')
      ..writeln('- engine call count: $engineCallCount')
      ..writeln('- scheduler execution count: $schedulerExecutionCount')
      ..writeln(
        '- Android collector execution count: $androidCollectorExecutionCount',
      );
    return buffer.toString();
  }

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': debugOnlyBridgeSelectedGoldenDiagnosticValidationReportVersion,
      'validationStatus': status.wire,
      'safeForPhase33M': safeForPhase33M,
      'phase33MRecommendation': phase33MRecommendation,
      'counts': <String, Object?>{
        'totalChecks': totalChecks,
        'passedCheckCount': passedCheckCount,
        'warningCheckCount': warningCheckCount,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'unsafeCount': unsafeCount,
        'totalSelectedRows': totalSelectedRows,
        'defaultSelectedRowCount': defaultSelectedRowCount,
        'allSafeSelectedRowCount': allSafeSelectedRowCount,
        'coreSupportRowCount': coreSupportRowCount,
        'contextOnlyRowCount': contextOnlyRowCount,
        'proofBoundaryOnlyRowCount': proofBoundaryOnlyRowCount,
        'warningLimitedRowCount': warningLimitedRowCount,
        'excludedNegativeGuardRowCount': excludedNegativeGuardRowCount,
        'invalidRowCount': invalidRowCount,
        'unsafeRowCount': unsafeRowCount,
        'activeDeniedFieldCount': activeDeniedFieldCount,
        'productOutputCount': productOutputCount,
        'labelLeakCount': labelLeakCount,
        'scoreLeakCount': scoreLeakCount,
        'metricLeakCount': metricLeakCount,
        'cpLossLeakCount': cpLossLeakCount,
        'winProbabilityLeakCount': winProbabilityLeakCount,
        'moveRankingLeakCount': moveRankingLeakCount,
        'uiTargetCount': uiTargetCount,
        'backendTargetCount': backendTargetCount,
        'persistenceWriteCount': persistenceWriteCount,
        'engineCallCount': engineCallCount,
        'schedulerExecutionCount': schedulerExecutionCount,
        'androidCollectorExecutionCount': androidCollectorExecutionCount,
        'stockfishCommandLeakCount': stockfishCommandLeakCount,
        'rawUciLeakCount': rawUciLeakCount,
        'pvDumpLeakCount': pvDumpLeakCount,
        'unprovenAndroidProofCount': unprovenAndroidProofCount,
        'phase32EProofClaimCount': phase32EProofClaimCount,
        'ownerProofQueueCount': ownerProofQueueCount,
      },
      'checks': checks.map((check) => check.toJson()).toList(growable: false),
      'selectedRows': selectedRows
          .map((row) => row.toJson())
          .toList(growable: false),
      'reportFindings': reportFindings
          .map((finding) => finding.toJson())
          .toList(growable: false),
    };
  }
}

class DebugOnlyBridgeSelectedGoldenDiagnosticValidation {
  const DebugOnlyBridgeSelectedGoldenDiagnosticValidation();

  DebugOnlyBridgeSelectedGoldenDiagnosticValidationResult evaluate({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    String singleCaseId = 'queen-win-major-swing',
  }) {
    final defaultDiagnostic = _diagnosticForSelection(
      _defaultSelectedGoldenSelection,
      cases,
    );
    final allSafeDiagnostic = _diagnosticForSelection(
      _allSafeSelectedGoldenSelection,
      cases,
    );
    final singleDiagnostic = _diagnosticForSelection(singleCaseId, cases);
    if (defaultDiagnostic == null ||
        allSafeDiagnostic == null ||
        singleDiagnostic == null) {
      return DebugOnlyBridgeSelectedGoldenDiagnosticValidationResult(
        status: DebugOnlyBridgeSelectedGoldenDiagnosticValidationStatus
            .invalidGoldenDiagnostic,
        checks: <DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheck>[
          DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheck(
            checkId: DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
                .singleKnownGoldenCaseIsSafe,
            status: DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckStatus
                .blocked,
            findings: <String>['unknownGoldenCase'],
          ),
        ],
        selectedRows:
            const <DebugOnlyBridgeSelectedGoldenDiagnosticValidationRow>[],
        defaultSelectedRowCount: 0,
        allSafeSelectedRowCount: 0,
        safeForPhase33M: false,
        phase33MRecommendation:
            'blockedByUnsafeSelectedGoldenDiagnosticValidation',
        reportFindings:
            const <DebugOnlyBridgeSelectedGoldenDiagnosticValidationFinding>[
              DebugOnlyBridgeSelectedGoldenDiagnosticValidationFinding(
                id: 'unknownGoldenCase',
                message: 'Unknown Golden case cannot be marked valid.',
              ),
            ],
      );
    }

    final selectedRows = allSafeDiagnostic.rows
        .map(
          (row) =>
              const DebugOnlyBridgeSelectedGoldenDiagnosticValidationValidator()
                  .validateRow(
                    row,
                    knownCaseIds: cases.map((item) => item.id).toSet(),
                  ),
        )
        .toList(growable: false);
    final allRows = <DebugOnlyBridgeSelectedGoldenDiagnosticRow>[
      ...defaultDiagnostic.rows,
      ...allSafeDiagnostic.rows,
      ...singleDiagnostic.rows,
    ];
    final selectedSectionText = _selectedGoldenSectionText(defaultDiagnostic);
    final listText = _renderGoldenCaseListMarkdown(cases);
    final defaultJson = const JsonEncoder.withIndent(
      '  ',
    ).convert(defaultDiagnostic.toJson());
    final repeatDefaultJson = const JsonEncoder.withIndent('  ').convert(
      _diagnosticForSelection(_defaultSelectedGoldenSelection, cases)!.toJson(),
    );
    final reportFindings =
        <DebugOnlyBridgeSelectedGoldenDiagnosticValidationFinding>[
          ...const DebugOnlyBridgeSelectedGoldenDiagnosticValidationValidator()
              .validateReportText(selectedSectionText),
          ...const DebugOnlyBridgeSelectedGoldenDiagnosticValidationValidator()
              .validateReportText(defaultJson),
          ...const DebugOnlyBridgeSelectedGoldenDiagnosticValidationValidator()
              .validateReportText(listText),
        ];

    final checks = <DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheck>[
      _check(
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
            .defaultSelectedSetIsSafe,
        defaultDiagnostic.safeForNextStep,
        warning:
            defaultDiagnostic.status ==
            DebugOnlyBridgeSelectedGoldenDiagnosticStatus
                .selectedGoldenDiagnosticReadyWithWarnings,
      ),
      _check(
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
            .allSafeSelectedSetIsSafe,
        allSafeDiagnostic.safeForNextStep,
        warning:
            allSafeDiagnostic.status ==
            DebugOnlyBridgeSelectedGoldenDiagnosticStatus
                .selectedGoldenDiagnosticReadyWithWarnings,
      ),
      _check(
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
            .singleKnownGoldenCaseIsSafe,
        singleDiagnostic.safeForNextStep,
        warning:
            singleDiagnostic.status ==
            DebugOnlyBridgeSelectedGoldenDiagnosticStatus
                .selectedGoldenDiagnosticReadyWithWarnings,
      ),
      _check(
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
            .listGoldenCasesIsSafe,
        reportFindings.isEmpty &&
            listText.contains(_defaultSelectedGoldenSelection),
      ),
      _check(
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
            .goldenSectionIsSafe,
        selectedSectionText.contains('## Selected Golden Diagnostic') &&
            reportFindings.isEmpty,
        warning: defaultDiagnostic.rows.any(
          (row) =>
              row.warningReasons.isNotEmpty || row.proofLimitReasons.isNotEmpty,
        ),
      ),
      _check(
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
            .selectedRowsAreDeterministic,
        defaultJson == repeatDefaultJson,
      ),
      _check(
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
            .selectedRolesAreAllowed,
        selectedRows.every((row) => !row.status.isInvalid),
      ),
      _check(
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
            .quietPreparatoryRemainsExcludedNegativeGuard,
        _quietRows(allSafeDiagnostic.rows).every(
          (row) =>
              row.diagnosticRole ==
              DebugOnlyBridgeSelectedGoldenDiagnosticRole.excludedNegativeGuard,
        ),
      ),
      _check(
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
            .phase32ECasesDoNotClaimCapturedAndroidProof,
        allRows
            .where((row) => _phase32ECaseIds.contains(row.caseId))
            .every((row) => row.androidProofCaseIds.isEmpty),
      ),
      _check(
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
            .pvMultiPvCaseRemainsBoundaryOnly,
        allRows
            .where((row) => row.caseId == _pvMultiPvBoundaryCaseId)
            .every(
              (row) =>
                  row.diagnosticRole ==
                      DebugOnlyBridgeSelectedGoldenDiagnosticRole
                          .proofBoundaryOnly &&
                  row.androidProofCaseIds.isEmpty &&
                  !row.ownerProofRequired,
            ),
      ),
      _check(
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
            .androidProofIdsRemainCapturedOnly,
        allRows.every(
          (row) =>
              row.androidProofCaseIds.every(_capturedAndroidProofIds.contains),
        ),
      ),
      _check(
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
            .ownerProofQueueRemainsEmpty,
        allRows.every((row) => !row.ownerProofRequired),
      ),
      _check(
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
            .deniedFieldsRemainInactive,
        allRows.every((row) => row.activeDeniedFields.isEmpty),
      ),
      _check(
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
            .noLabelsScoresRankingsMetrics,
        !_hasAnyActiveField(allRows, {
          ..._labelFields,
          ..._scoreFields,
          ..._metricFields,
          'moveRanking',
        }),
      ),
      _check(
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
            .noCpLossOrWinProbability,
        !_hasAnyActiveField(allRows, const {'cpLoss', 'winProbability'}),
      ),
      _check(
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
            .noStockfishCommandRawUciPvDump,
        !_hasAnyActiveField(allRows, const {
          'stockfishCommand',
          'rawUci',
          'pvDump',
        }),
      ),
      _check(
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
            .noUiBackendPersistenceEngineScheduler,
        !_hasAnyActiveField(allRows, const {
          'uiOutput',
          'backendOutput',
          'persistenceOutput',
          'directEngineCall',
          'engineResults',
          'schedulerExecution',
          'androidCollectorExecution',
        }),
      ),
      _check(
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
            .reportContainsNoRawUciOrPvDump,
        reportFindings.isEmpty,
      ),
      _check(
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId
            .phase33MRequirementPresent,
        _phase33MRecommendation ==
            'proceedToDebugOnlyBridgeAnalyzerAdapterBoundaryDesign',
      ),
    ];

    final anyBlocked = checks.any(
      (check) =>
          check.status ==
          DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckStatus.blocked,
    );
    final anyUnsafeRows = selectedRows.any((row) => row.status.isUnsafe);
    final hasCriticalReport = reportFindings.any((finding) => finding.critical);
    final safe = !anyBlocked && !anyUnsafeRows && reportFindings.isEmpty;
    final status = !safe
        ? hasCriticalReport
              ? DebugOnlyBridgeSelectedGoldenDiagnosticValidationStatus
                    .blockedByPolicyBoundary
              : DebugOnlyBridgeSelectedGoldenDiagnosticValidationStatus
                    .blockedByUnsafeGoldenDiagnostic
        : checks.any((check) => check.status.isWarning)
        ? DebugOnlyBridgeSelectedGoldenDiagnosticValidationStatus
              .selectedGoldenDiagnosticValidatedWithWarnings
        : DebugOnlyBridgeSelectedGoldenDiagnosticValidationStatus
              .selectedGoldenDiagnosticValidatedClean;

    return DebugOnlyBridgeSelectedGoldenDiagnosticValidationResult(
      status: status,
      checks: checks,
      selectedRows: selectedRows,
      defaultSelectedRowCount: defaultDiagnostic.rows.length,
      allSafeSelectedRowCount: allSafeDiagnostic.rows.length,
      safeForPhase33M: safe,
      phase33MRecommendation: safe
          ? _phase33MRecommendation
          : 'blockedByUnsafeSelectedGoldenDiagnosticValidation',
      reportFindings: reportFindings,
    );
  }

  DebugOnlyBridgeSelectedGoldenDiagnosticResult? _diagnosticForSelection(
    String selection,
    List<GoldenAnalysisCase> cases,
  ) {
    return _buildSelectedGoldenDiagnosticIfRequested(
      DebugOnlyBridgeDeveloperDiagnosticCommandRequest.valid(
        format: DebugOnlyBridgeDeveloperDiagnosticFormat.markdown,
        section: DebugOnlyBridgeDeveloperDiagnosticSection.all,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        goldenCaseSelection: selection,
      ),
      cases,
    ).result;
  }
}

class DebugOnlyBridgeSelectedGoldenDiagnosticValidationValidator {
  const DebugOnlyBridgeSelectedGoldenDiagnosticValidationValidator();

  DebugOnlyBridgeSelectedGoldenDiagnosticValidationRow validateRow(
    DebugOnlyBridgeSelectedGoldenDiagnosticRow row, {
    Set<String> knownCaseIds = const <String>{},
  }) {
    final findings = <String>[
      if (knownCaseIds.isNotEmpty && !knownCaseIds.contains(row.caseId))
        'unknownGoldenCase',
      if (row.activeDeniedFields.isNotEmpty) 'activeDeniedField',
      if (_hasActiveField(row, _productFields)) 'productOutput',
      if (_hasActiveField(row, _labelFields)) 'labelLeak',
      if (_hasActiveField(row, _scoreFields)) 'scoreLeak',
      if (_hasActiveField(row, _metricFields)) 'metricLeak',
      if (_hasActiveField(row, const {'cpLoss'})) 'cpLossLeak',
      if (_hasActiveField(row, const {'winProbability'})) 'winProbabilityLeak',
      if (_hasActiveField(row, const {'moveRanking'})) 'moveRankingLeak',
      if (_hasActiveField(row, const {'uiOutput'})) 'uiTarget',
      if (_hasActiveField(row, const {'backendOutput', 'backendTarget'}))
        'backendTarget',
      if (_hasActiveField(row, const {'persistenceOutput', 'persistenceWrite'}))
        'persistenceWrite',
      if (_hasActiveField(row, const {'directEngineCall', 'engineResults'}))
        'engineCall',
      if (_hasActiveField(row, const {'schedulerExecution'}))
        'schedulerExecution',
      if (_hasActiveField(row, const {'androidCollectorExecution'}))
        'androidCollectorExecution',
      if (_hasActiveField(row, const {'stockfishCommand'}))
        'stockfishCommandLeak',
      if (_hasActiveField(row, const {'rawUci'})) 'rawUciLeak',
      if (_hasActiveField(row, const {'pvDump'})) 'pvDumpLeak',
      if (row.androidProofCaseIds.any(
        (caseId) => !_capturedAndroidProofIds.contains(caseId),
      ))
        'unprovenAndroidProof',
      if (_phase32ECaseIds.contains(row.caseId) &&
          row.androidProofCaseIds.isNotEmpty)
        'phase32EProofClaim',
      if (row.caseId == _pvMultiPvBoundaryCaseId &&
          (row.diagnosticRole !=
                  DebugOnlyBridgeSelectedGoldenDiagnosticRole
                      .proofBoundaryOnly ||
              row.androidProofCaseIds.isNotEmpty ||
              row.ownerProofRequired))
        'pvMultiPvBoundaryViolation',
      if (_isQuietRow(row) &&
          row.diagnosticRole !=
              DebugOnlyBridgeSelectedGoldenDiagnosticRole.excludedNegativeGuard)
        'quietPreparatoryCoreActivation',
      if (row.ownerProofRequired &&
          !row.proofLimitReasons.any((reason) => reason.contains('pvMultiPv')))
        'ownerProofWithoutPvReason',
    ]..sort();
    final hasUnsafe = findings.isNotEmpty;
    final status = hasUnsafe
        ? DebugOnlyBridgeSelectedGoldenDiagnosticValidationRowStatus.unsafeRow
        : row.warningReasons.isNotEmpty || row.proofLimitReasons.isNotEmpty
        ? DebugOnlyBridgeSelectedGoldenDiagnosticValidationRowStatus
              .validWithWarnings
        : DebugOnlyBridgeSelectedGoldenDiagnosticValidationRowStatus.valid;

    return DebugOnlyBridgeSelectedGoldenDiagnosticValidationRow(
      validationRowId: 'phase33l-${row.caseId}',
      caseId: row.caseId,
      sourcePhase: row.sourcePhase,
      selectedReason: row.selectedReason,
      diagnosticRole: row.diagnosticRole,
      supportAreaIds: row.supportAreaIds,
      blockedBoundaryIds: row.blockedBoundaryIds,
      warningReasons: row.warningReasons,
      proofLimitReasons: row.proofLimitReasons,
      androidProofCaseIds: row.androidProofCaseIds,
      ownerProofRequired: row.ownerProofRequired,
      activeDeniedFields: row.activeDeniedFields,
      status: status,
      findings: findings,
      recommendation: hasUnsafe
          ? 'fixSelectedGoldenDiagnosticBoundary'
          : _phase33MRecommendation,
    );
  }

  List<DebugOnlyBridgeSelectedGoldenDiagnosticValidationFinding>
  validateReportText(String text) {
    final findings =
        <DebugOnlyBridgeSelectedGoldenDiagnosticValidationFinding>[];
    for (final token in _rawReportLeakTokens) {
      if (text.contains(token)) {
        findings.add(
          DebugOnlyBridgeSelectedGoldenDiagnosticValidationFinding(
            id: 'reportTextLeak:$token',
            message:
                'Selected Golden diagnostic validation report leaked $token.',
            critical: true,
          ),
        );
      }
    }
    return findings;
  }
}

class _SelectedGoldenDiagnosticBuildResult {
  const _SelectedGoldenDiagnosticBuildResult.result(this.result)
    : failure = null;

  const _SelectedGoldenDiagnosticBuildResult.failure(this.failure)
    : result = null;

  final DebugOnlyBridgeSelectedGoldenDiagnosticResult? result;
  final String? failure;
}

_SelectedGoldenDiagnosticBuildResult _buildSelectedGoldenDiagnosticIfRequested(
  DebugOnlyBridgeDeveloperDiagnosticCommandRequest request,
  List<GoldenAnalysisCase> cases,
) {
  if (request.goldenCaseSelection == null &&
      request.section != DebugOnlyBridgeDeveloperDiagnosticSection.golden) {
    return const _SelectedGoldenDiagnosticBuildResult.result(null);
  }

  final selection =
      request.goldenCaseSelection ?? _defaultSelectedGoldenSelection;
  final ids = _resolveSelectedGoldenCaseIds(selection, cases);
  if (ids == null) {
    return const _SelectedGoldenDiagnosticBuildResult.failure(
      'unknownGoldenCase',
    );
  }
  final byId = {for (final item in cases) item.id: item};
  if (ids.any((id) => !byId.containsKey(id))) {
    return const _SelectedGoldenDiagnosticBuildResult.failure(
      'configuredGoldenCaseMissing',
    );
  }

  final rows = ids
      .map((id) => _selectedGoldenRowForCase(byId[id]!))
      .toList(growable: false);
  return _SelectedGoldenDiagnosticBuildResult.result(
    DebugOnlyBridgeSelectedGoldenDiagnosticResult(
      selection: selection,
      rows: rows,
    ),
  );
}

List<String>? _resolveSelectedGoldenCaseIds(
  String selection,
  List<GoldenAnalysisCase> cases,
) {
  if (selection == _defaultSelectedGoldenSelection) {
    return _defaultSelectedGoldenCaseIds;
  }
  if (selection == _allSafeSelectedGoldenSelection) {
    return _allSafeSelectedGoldenCaseIds;
  }
  if (cases.any((item) => item.id == selection)) {
    return <String>[selection];
  }
  return null;
}

DebugOnlyBridgeSelectedGoldenDiagnosticRow _selectedGoldenRowForCase(
  GoldenAnalysisCase item,
) {
  final role = _selectedGoldenRoleForCase(item);
  final supportAreaIds = _supportAreaIdsForCase(item);
  final proofLimitReasons = <String>[
    if (_phase32ECaseIds.contains(item.id)) 'phase32ECaseIsNotCapturedProof',
    if (item.id == _pvMultiPvBoundaryCaseId)
      'pvMultiPvBoundaryWatchListOnlyNoOwnerProof',
    if (role ==
        DebugOnlyBridgeSelectedGoldenDiagnosticRole.excludedNegativeGuard)
      'quietPreparatoryExcludedFromActiveCoreOutput',
  ];
  final warningReasons = <String>[
    'developerOnlySelectedGoldenDiagnosticNoEngineExecution',
    if (role == DebugOnlyBridgeSelectedGoldenDiagnosticRole.warningLimited)
      'diagnosticCoverageIsWarningLimited',
    if (role == DebugOnlyBridgeSelectedGoldenDiagnosticRole.proofBoundaryOnly)
      'proofBoundaryOnlyNoCapturedAndroidProofClaim',
    if (role ==
        DebugOnlyBridgeSelectedGoldenDiagnosticRole.excludedNegativeGuard)
      'negativeGuardOnlyNotCoreSupport',
  ];
  final androidProofCaseIds =
      _capturedAndroidProofIds.contains(item.id) &&
          !_phase32ECaseIds.contains(item.id)
      ? <String>[item.id]
      : const <String>[];

  return DebugOnlyBridgeSelectedGoldenDiagnosticRow(
    caseId: item.id,
    caseTitle: item.title,
    sourcePhase: _sourcePhaseForCase(item),
    selectedReason: _selectedReasonForCase(item),
    diagnosticRole: role,
    supportAreaIds: supportAreaIds,
    blockedBoundaryIds: _blockedBoundaryIdsForCase(item, role),
    warningReasons: warningReasons,
    proofLimitReasons: proofLimitReasons,
    androidProofCaseIds: androidProofCaseIds,
    ownerProofRequired: false,
    activeDeniedFields: const <String>[],
    recommendation: 'proceedToSelectedGoldenBridgeDiagnosticValidation',
  );
}

DebugOnlyBridgeSelectedGoldenDiagnosticRole _selectedGoldenRoleForCase(
  GoldenAnalysisCase item,
) {
  if (_isQuietPreparatoryCase(item)) {
    return DebugOnlyBridgeSelectedGoldenDiagnosticRole.excludedNegativeGuard;
  }
  if (item.id == _pvMultiPvBoundaryCaseId) {
    return DebugOnlyBridgeSelectedGoldenDiagnosticRole.proofBoundaryOnly;
  }
  if (item.category == GoldenAnalysisCategory.budgetPressure) {
    return DebugOnlyBridgeSelectedGoldenDiagnosticRole.warningLimited;
  }
  if (item.category == GoldenAnalysisCategory.endgamePrecision ||
      item.category == GoldenAnalysisCategory.openingKnownSkip ||
      item.category == GoldenAnalysisCategory.forcedMoveSkip) {
    return DebugOnlyBridgeSelectedGoldenDiagnosticRole.contextOnly;
  }
  return DebugOnlyBridgeSelectedGoldenDiagnosticRole.coreSupport;
}

List<String> _supportAreaIdsForCase(GoldenAnalysisCase item) {
  final values = <String>{
    item.category.wire,
    item.sourceType.wire,
    item.evidenceIntent.wire,
    ...item.motifTags.map((tag) => tag.wire),
    if (_phase32ECaseIds.contains(item.id)) 'phase32E',
    if (item.id == _pvMultiPvBoundaryCaseId) 'pvMultiPvBoundary',
    if (_capturedAndroidProofIds.contains(item.id)) 'capturedAndroidProof',
  }.where((value) => value.trim().isNotEmpty).toList()..sort();
  return values;
}

List<String> _blockedBoundaryIdsForCase(
  GoldenAnalysisCase item,
  DebugOnlyBridgeSelectedGoldenDiagnosticRole role,
) {
  final values = <String>{
    ..._selectedGoldenAlwaysBlockedBoundaryIds,
    if (_phase32ECaseIds.contains(item.id)) 'phase32ECapturedAndroidProofClaim',
    if (item.id == _pvMultiPvBoundaryCaseId) 'pvMultiPvOwnerProofEscalation',
    if (role ==
        DebugOnlyBridgeSelectedGoldenDiagnosticRole.excludedNegativeGuard)
      'quietPreparatoryCoreActivation',
  }.toList()..sort();
  return values;
}

String _selectedReasonForCase(GoldenAnalysisCase item) {
  return _selectedReasonByCaseId[item.id] ??
      switch (_selectedGoldenRoleForCase(item)) {
        DebugOnlyBridgeSelectedGoldenDiagnosticRole.excludedNegativeGuard =>
          'quiet/preparatory negative guard remains excluded from active core output',
        DebugOnlyBridgeSelectedGoldenDiagnosticRole.proofBoundaryOnly =>
          'PV/MultiPV boundary watch-list evidence only',
        DebugOnlyBridgeSelectedGoldenDiagnosticRole.warningLimited =>
          'warning-limited budget or breadth pressure coverage',
        DebugOnlyBridgeSelectedGoldenDiagnosticRole.contextOnly =>
          'context-only conservative Golden coverage',
        DebugOnlyBridgeSelectedGoldenDiagnosticRole.coreSupport =>
          'developer-only core support coverage',
      };
}

String _sourcePhaseForCase(GoldenAnalysisCase item) {
  if (_phase32ECaseIds.contains(item.id) ||
      item.notes.any((note) => note.contains('Phase 32E'))) {
    return 'Phase 32E';
  }
  if (item.notes.any((note) => note.contains('Phase 30W'))) {
    return 'Phase 30W';
  }
  return 'existing';
}

bool _isQuietPreparatoryCase(GoldenAnalysisCase item) {
  return item.category == GoldenAnalysisCategory.quietPreparatoryMove ||
      item.motifTags.any(
        (tag) =>
            tag == GoldenMotifTag.quietMove ||
            tag == GoldenMotifTag.quietPreparatoryMove,
      );
}

String _renderGoldenCaseListMarkdown(List<GoldenAnalysisCase> cases) {
  final sorted = cases.toList()..sort((a, b) => a.id.compareTo(b.id));
  final buffer = StringBuffer()
    ..writeln('# Debug-Only Bridge Golden Case Selection')
    ..writeln()
    ..writeln('- version: $debugOnlyBridgeDeveloperDiagnosticCommandVersion')
    ..writeln('- default selection: $_defaultSelectedGoldenSelection')
    ..writeln('- expanded selection: $_allSafeSelectedGoldenSelection')
    ..writeln(
      '- next recommendation: proceedToSelectedGoldenBridgeDiagnosticValidation',
    )
    ..writeln()
    ..writeln(
      '| Case ID | Title | Category | Source phase | Default | All safe |',
    )
    ..writeln('| --- | --- | --- | --- | --- | --- |');
  for (final item in sorted) {
    buffer.writeln(
      '| ${item.id} | ${item.title} | ${item.category.wire} | '
      '${_sourcePhaseForCase(item)} | '
      '${_defaultSelectedGoldenCaseIds.contains(item.id)} | '
      '${_allSafeSelectedGoldenCaseIds.contains(item.id)} |',
    );
  }
  return buffer.toString();
}

String _renderGoldenCaseListJson(List<GoldenAnalysisCase> cases) {
  final sorted = cases.toList()..sort((a, b) => a.id.compareTo(b.id));
  return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
    'version': debugOnlyBridgeDeveloperDiagnosticCommandVersion,
    'defaultSelection': _defaultSelectedGoldenSelection,
    'expandedSelection': _allSafeSelectedGoldenSelection,
    'nextRecommendation': 'proceedToSelectedGoldenBridgeDiagnosticValidation',
    'cases': sorted
        .map(
          (item) => <String, Object?>{
            'caseId': item.id,
            'caseName': item.title,
            'category': item.category.wire,
            'sourcePhase': _sourcePhaseForCase(item),
            'includedInDefaultSelection': _defaultSelectedGoldenCaseIds
                .contains(item.id),
            'includedInAllSafeSelection': _allSafeSelectedGoldenCaseIds
                .contains(item.id),
          },
        )
        .toList(growable: false),
  });
}

DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheck _check(
  DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckId checkId,
  bool condition, {
  bool warning = false,
}) {
  if (!condition) {
    return DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheck(
      checkId: checkId,
      status:
          DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckStatus.blocked,
      findings: <String>['checkFailed'],
    );
  }
  return DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheck(
    checkId: checkId,
    status: warning
        ? DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckStatus
              .passedWithWarnings
        : DebugOnlyBridgeSelectedGoldenDiagnosticValidationCheckStatus.passed,
    findings: warning ? <String>['warningLimitedDiagnostic'] : const <String>[],
  );
}

String _selectedGoldenSectionText(
  DebugOnlyBridgeSelectedGoldenDiagnosticResult result,
) {
  final buffer = StringBuffer();
  _writeSelectedGoldenDiagnostic(buffer, result);
  return buffer.toString();
}

Iterable<DebugOnlyBridgeSelectedGoldenDiagnosticRow> _quietRows(
  Iterable<DebugOnlyBridgeSelectedGoldenDiagnosticRow> rows,
) {
  return rows.where(_isQuietRow);
}

bool _isQuietRow(DebugOnlyBridgeSelectedGoldenDiagnosticRow row) {
  return row.supportAreaIds.contains('quietPreparatoryMove') ||
      row.supportAreaIds.contains('quietMove');
}

bool _hasAnyActiveField(
  Iterable<DebugOnlyBridgeSelectedGoldenDiagnosticRow> rows,
  Set<String> fieldIds,
) {
  return rows.any((row) => _hasActiveField(row, fieldIds));
}

bool _hasActiveField(
  DebugOnlyBridgeSelectedGoldenDiagnosticRow row,
  Set<String> fieldIds,
) {
  return row.activeDeniedFields.any(fieldIds.contains);
}

int _countActiveFields(
  Iterable<DebugOnlyBridgeSelectedGoldenDiagnosticValidationRow> rows,
  Set<String> fieldIds,
) {
  var count = 0;
  for (final row in rows) {
    count += row.activeDeniedFields.where(fieldIds.contains).length;
  }
  return count;
}

bool _includeSection(
  DebugOnlyBridgeDeveloperDiagnosticSection selected,
  DebugOnlyBridgeDeveloperDiagnosticSection target,
) {
  return selected == DebugOnlyBridgeDeveloperDiagnosticSection.all ||
      selected == target;
}

bool _hasUnprovenAndroidProof(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  return result.validationFindings.any(
    (finding) => finding.id == 'unprovenAndroidProofId',
  );
}

bool _hasPhase32ECapturedProofClaim(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
) {
  return result.validationFindings.any(
    (finding) => finding.id == 'phase32ECaseClaimedAsCapturedProof',
  );
}

String _ids(Iterable<String> values) {
  final sorted =
      values.where((value) => value.trim().isNotEmpty).toSet().toList()..sort();
  return sorted.isEmpty ? 'none' : sorted.join(', ');
}

String _mapSummary(Map<String, int> values) {
  if (values.isEmpty) return 'none';
  final entries = values.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return entries.map((entry) => '${entry.key}=${entry.value}').join(', ');
}

DebugOnlyBridgeDeveloperDiagnosticFormat? _formatByWire(String wire) {
  for (final format in DebugOnlyBridgeDeveloperDiagnosticFormat.values) {
    if (format.wire == wire) return format;
  }
  return null;
}

DebugOnlyBridgeDeveloperDiagnosticSection? _sectionByWire(String wire) {
  for (final section in DebugOnlyBridgeDeveloperDiagnosticSection.values) {
    if (section.wire == wire) return section;
  }
  return null;
}

String _usage(String failure) {
  return [
    if (failure.isNotEmpty && failure != 'help') 'error: $failure',
    'usage: dart run tool/debug_only_bridge_developer_diagnostic_command.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings] [--section=all|snapshot|packets|policy|records|boundaries|proof|runtime|recommendation|golden] [--golden-case=<caseId>|default-selected|all-safe-selected] [--list-golden-cases]',
    'defaults: --format=markdown --safe-demo --include-warnings --section=all',
  ].join('\n');
}

const _formatFlag = '--format=';
const _sectionFlag = '--section=';
const _goldenCaseFlag = '--golden-case=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';
const _listGoldenCasesFlag = '--list-golden-cases';

const _defaultSelectedGoldenSelection = 'default-selected';
const _allSafeSelectedGoldenSelection = 'all-safe-selected';
const _pvMultiPvBoundaryCaseId = 'pv-multipv-support-boundary-32e';
const _phase33MRecommendation =
    'proceedToDebugOnlyBridgeAnalyzerAdapterBoundaryDesign';

const _defaultSelectedGoldenCaseIds = <String>[
  'queen-win-major-swing',
  'forcing-line-variation-hard-case',
  'sacrifice-compensation-hard-case',
  'king-safety-mating-net-pressure-32e',
  'endgame-precision-candidate-spread-32e',
  'budget-pressure-wide-candidate-32e',
  _pvMultiPvBoundaryCaseId,
];

const _allSafeSelectedGoldenCaseIds = <String>[
  ..._defaultSelectedGoldenCaseIds,
  'simple-tactical-capture-check',
  'mate-threat-fast-evidence',
  'material-sacrifice-compensation',
  'king-safety-mating-net-hard-case',
  'technical-endgame-conservative',
  'budget-pressure-candidates',
  'quiet-preparatory-uncertain',
  'quiet-preparatory-hard-case',
  'suppression-forced-only-legal-32e',
];

const _phase32ECaseIds = <String>{
  'king-safety-mating-net-pressure-32e',
  'endgame-precision-candidate-spread-32e',
  'suppression-forced-only-legal-32e',
  'budget-pressure-wide-candidate-32e',
  _pvMultiPvBoundaryCaseId,
};

const _capturedAndroidProofIds = <String>{
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
};

const _selectedGoldenAlwaysBlockedBoundaryIds = <String>{
  'androidCollectorExecution',
  'backendTarget',
  'classifierLabels',
  'cpLoss',
  'directEngineCall',
  'engineResults',
  'finalMoveLabels',
  'moveRanking',
  'numericMoveScores',
  'officialMetrics',
  'persistenceWrite',
  'productOutput',
  'rawUci',
  'schedulerExecution',
  'stockfishCommand',
  'uiTarget',
  'pvDump',
  'winProbability',
};

const _productFields = <String>{'productLabel', 'productOutput'};

const _labelFields = <String>{
  'productLabel',
  'finalMoveLabel',
  'brilliantGreatMissStyleLabels',
  'bestGoodInaccuracyMistakeBlunderStyleLabels',
  'classifierLabels',
};

const _scoreFields = <String>{'numericMoveScore', 'aggregateScore'};

const _metricFields = <String>{'officialAccuracy', 'acpl'};

const _rawReportLeakTokens = <String>{
  'uciok',
  'readyok',
  'info depth',
  'bestmove ',
  'pv e2e4',
  'position fen',
  'go depth',
  'go movetime',
};

const _selectedReasonByCaseId = <String, String>{
  'queen-win-major-swing':
      'tactical/material swing case with captured Android proof boundary preserved',
  'forcing-line-variation-hard-case':
      'forcing-line case for developer-only bridge support coverage',
  'sacrifice-compensation-hard-case':
      'candidate-spread material compensation case for internal support coverage',
  'king-safety-mating-net-pressure-32e':
      'Phase 32E king-safety and mating-net coverage without captured proof claim',
  'endgame-precision-candidate-spread-32e':
      'Phase 32E endgame candidate-spread context coverage',
  'budget-pressure-wide-candidate-32e':
      'Phase 32E budget-pressure coverage kept warning-limited',
  _pvMultiPvBoundaryCaseId:
      'Phase 32E PV/MultiPV boundary watch-list evidence only',
  'simple-tactical-capture-check':
      'tactical capture/check case with captured Android proof boundary preserved',
  'mate-threat-fast-evidence':
      'mate-threat fast-evidence case with captured Android proof boundary preserved',
  'material-sacrifice-compensation':
      'material compensation case for developer-only support coverage',
  'king-safety-mating-net-hard-case':
      'king-safety hard case for developer-only support coverage',
  'technical-endgame-conservative':
      'technical endgame context case kept conservative',
  'budget-pressure-candidates': 'budget-pressure coverage kept warning-limited',
  'quiet-preparatory-uncertain':
      'quiet/preparatory negative guard remains excluded from active core output',
  'quiet-preparatory-hard-case':
      'quiet/preparatory hard negative guard remains excluded from active core output',
  'suppression-forced-only-legal-32e':
      'Phase 32E forced-only suppression case kept context-only',
};

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
  recommendation('recommendation');

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
    this.result,
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
  final DebugOnlyBridgeDeveloperInspectionHarnessValidationResult? result;
  final String? commandFailure;
}

class DebugOnlyBridgeDeveloperDiagnosticCommandRequest {
  const DebugOnlyBridgeDeveloperDiagnosticCommandRequest.valid({
    required this.format,
    required this.section,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
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
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeDeveloperDiagnosticFormat format;
  final DebugOnlyBridgeDeveloperDiagnosticSection section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
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
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

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
    ),
    DebugOnlyBridgeDeveloperDiagnosticFormat.json =>
      '${_renderJson(result, commandRequest.section)}\n',
  };
  final reportFindings =
      const DebugOnlyBridgeDeveloperInspectionHarnessValidationValidator()
          .validateReportText(stdoutText);

  return DebugOnlyBridgeDeveloperDiagnosticCommandResult(
    exitCode: debugOnlyBridgeDeveloperDiagnosticCommandExitCode(
      result,
      commandRequest,
      reportFindings: reportFindings,
    ),
    format: commandRequest.format,
    section: commandRequest.section,
    strict: commandRequest.strict,
    safeDemo: commandRequest.safeDemo,
    includeWarnings: commandRequest.includeWarnings,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
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

  return DebugOnlyBridgeDeveloperDiagnosticCommandRequest.valid(
    format: format,
    section: section,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int debugOnlyBridgeDeveloperDiagnosticCommandExitCode(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
  DebugOnlyBridgeDeveloperDiagnosticCommandRequest request, {
  List<DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding>
      reportFindings =
      const <DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding>[],
}) {
  final hasReportLeak = reportFindings.any((finding) => finding.isCritical);
  if (result
          .hasUnsafeDebugOnlyBridgeDeveloperInspectionHarnessValidationPolicyViolation ||
      hasReportLeak) {
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
          !result.safeForPhase33J)) {
    return debugOnlyBridgeDeveloperDiagnosticCommandExitBlockedStrict;
  }
  return debugOnlyBridgeDeveloperDiagnosticCommandExitSuccess;
}

String _renderMarkdown(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
  DebugOnlyBridgeDeveloperDiagnosticSection section,
) {
  final buffer = StringBuffer()
    ..writeln('# Debug-Only Bridge Developer Diagnostic')
    ..writeln()
    ..writeln('- version: $debugOnlyBridgeDeveloperDiagnosticCommandVersion')
    ..writeln('- diagnostic status: ${result.status.wire}')
    ..writeln('- selected section: ${section.wire}')
    ..writeln('- safe for next step: ${result.safeForPhase33J}')
    ..writeln('- recommendation: proceedToSelectedGoldenBridgeDiagnosticRun')
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

  return buffer.toString();
}

String _renderJson(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
  DebugOnlyBridgeDeveloperDiagnosticSection section,
) {
  return const JsonEncoder.withIndent(
    '  ',
  ).convert(_jsonPayload(result, section));
}

Map<String, Object?> _jsonPayload(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
  DebugOnlyBridgeDeveloperDiagnosticSection section,
) {
  final payload = <String, Object?>{
    'version': debugOnlyBridgeDeveloperDiagnosticCommandVersion,
    'diagnosticStatus': result.status.wire,
    'section': section.wire,
    'safeForNextStep': result.safeForPhase33J,
    'recommendation': 'proceedToSelectedGoldenBridgeDiagnosticRun',
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
      '- next recommendation: proceedToSelectedGoldenBridgeDiagnosticRun',
    )
    ..writeln('- warning summary: ${_ids(result.warnings)}')
    ..writeln('- failure summary: ${_ids(result.failures)}')
    ..writeln();
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
    'nextRecommendation': 'proceedToSelectedGoldenBridgeDiagnosticRun',
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
    'usage: dart run tool/debug_only_bridge_developer_diagnostic_command.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings] [--section=all|snapshot|packets|policy|records|boundaries|proof|runtime|recommendation]',
    'defaults: --format=markdown --safe-demo --include-warnings --section=all',
  ].join('\n');
}

const _formatFlag = '--format=';
const _sectionFlag = '--section=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';

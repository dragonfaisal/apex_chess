import 'dart:convert';
import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_inspection_harness.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_inspection_harness_validation.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandVersion =
    'debug-only-bridge-analyzer-adapter-prototype-diagnostic-command-v1';

const debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess = 0;
const debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitUsage = 64;
const debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitBlockedStrict =
    68;
const debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitUnsafePolicy =
    69;

enum DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat(this.wire);

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection {
  all('all'),
  snapshot('snapshot'),
  packets('packets'),
  policy('policy'),
  records('records'),
  proof('proof'),
  boundaries('boundaries'),
  runtime('runtime'),
  recommendation('recommendation');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection(this.wire);

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus {
  prototypeDiagnosticCommandReadyWithWarnings(
    'prototypeDiagnosticCommandReadyWithWarnings',
  ),
  prototypeDiagnosticCommandReadyClean('prototypeDiagnosticCommandReadyClean'),
  blockedByUnsafeInspectionHarnessValidation(
    'blockedByUnsafeInspectionHarnessValidation',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidPrototypeDiagnosticCommand('invalidPrototypeDiagnosticCommand');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus(this.wire);

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandResult {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandResult({
    required this.exitCode,
    required this.format,
    required this.section,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    required this.stdoutText,
    required this.stderrText,
    this.diagnosticResult,
    this.commandFailure,
  });

  final int exitCode;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat format;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult?
  diagnosticResult;
  final String? commandFailure;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.valid({
    required this.format,
    required this.section,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat.markdown,
      section = DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.all,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat format;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult {
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult({
    required this.validationResult,
    required this.harnessResult,
  }) : status = _diagnosticStatus(validationResult, harnessResult),
       safeForPhase33Z =
           validationResult.safeForPhase33Y &&
           validationResult.phase33YRecommendation == _phase33YRequirement &&
           !validationResult.hasUnsafePolicyViolation &&
           harnessResult.safeForPhase33X &&
           harnessResult.phase33XRecommendation == _phase33XRequirement &&
           !harnessResult.hasUnsafePolicyViolation,
       nextRecommendation = _phase33ZRecommendation,
       unsafeCount =
           validationResult.unsafeCount +
           (harnessResult.unsafeCount > 0 ? 1 : 0),
       blockerCount =
           validationResult.blockerCount +
           (harnessResult.blockerCount > 0 ? 1 : 0),
       criticalCount =
           validationResult.criticalCount +
           (harnessResult.criticalCount > 0 ? 1 : 0),
       analyzerWiringCount =
           validationResult.analyzerWiringCount +
           harnessResult.analyzerWiringCount,
       runtimeImplementationCount =
           validationResult.runtimeImplementationCount +
           harnessResult.runtimeImplementationCount,
       executablePrototypeCount =
           validationResult.executablePrototypeCount +
           harnessResult.executablePrototypeCount,
       engineCallCount =
           validationResult.engineCallCount + harnessResult.engineCallCount,
       schedulerExecutionCount =
           validationResult.schedulerExecutionCount +
           harnessResult.schedulerExecutionCount,
       persistenceWriteCount =
           validationResult.persistenceWriteCount +
           harnessResult.persistenceWriteCount,
       productOutputCount =
           validationResult.productOutputCount +
           harnessResult.productOutputCount,
       activeDeniedFieldCount =
           validationResult.activeDeniedFieldCount +
           harnessResult.activeDeniedFieldCount,
       labelLeakCount =
           validationResult.labelLeakCount + harnessResult.labelLeakCount,
       finalLabelLeakCount =
           validationResult.finalLabelLeakCount +
           harnessResult.finalLabelLeakCount,
       scoreLeakCount =
           validationResult.scoreLeakCount + harnessResult.scoreLeakCount,
       metricLeakCount =
           validationResult.metricLeakCount + harnessResult.metricLeakCount,
       cpLossLeakCount =
           validationResult.cpLossLeakCount + harnessResult.cpLossLeakCount,
       winProbabilityLeakCount =
           validationResult.winProbabilityLeakCount +
           harnessResult.winProbabilityLeakCount,
       moveRankingLeakCount =
           validationResult.moveRankingLeakCount +
           harnessResult.moveRankingLeakCount,
       thresholdLeakCount =
           validationResult.thresholdLeakCount +
           harnessResult.thresholdLeakCount,
       uiTargetCount =
           validationResult.uiTargetCount + harnessResult.uiTargetCount,
       backendTargetCount =
           validationResult.backendTargetCount +
           harnessResult.backendTargetCount,
       stockfishCommandLeakCount =
           validationResult.stockfishCommandLeakCount +
           harnessResult.stockfishCommandLeakCount,
       rawUciLeakCount =
           validationResult.rawUciLeakCount + harnessResult.rawUciLeakCount,
       pvDumpLeakCount =
           validationResult.pvDumpLeakCount + harnessResult.pvDumpLeakCount,
       androidCollectorRequirementCount =
           validationResult.androidCollectorRequirementCount +
           harnessResult.androidCollectorRequirementCount,
       unprovenAndroidProofCount =
           validationResult.unprovenAndroidProofCount +
           harnessResult.unprovenAndroidProofCount,
       phase32EProofClaimCount =
           validationResult.phase32EProofClaimCount +
           harnessResult.phase32EProofClaimCount,
       productAdapterBehaviorCount =
           validationResult.productAdapterBehaviorCount +
           harnessResult.productAdapterBehaviorCount,
       savedAnalysisIntegrationCount =
           validationResult.savedAnalysisIntegrationCount +
           harnessResult.savedAnalysisIntegrationCount,
       ownerProofQueueCount =
           validationResult.ownerProofQueueCount +
           harnessResult.ownerProofQueueCount;

  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationResult
  validationResult;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult harnessResult;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus status;
  final bool safeForPhase33Z;
  final String nextRecommendation;
  final int unsafeCount;
  final int blockerCount;
  final int criticalCount;
  final int analyzerWiringCount;
  final int runtimeImplementationCount;
  final int executablePrototypeCount;
  final int engineCallCount;
  final int schedulerExecutionCount;
  final int persistenceWriteCount;
  final int productOutputCount;
  final int activeDeniedFieldCount;
  final int labelLeakCount;
  final int finalLabelLeakCount;
  final int scoreLeakCount;
  final int metricLeakCount;
  final int cpLossLeakCount;
  final int winProbabilityLeakCount;
  final int moveRankingLeakCount;
  final int thresholdLeakCount;
  final int uiTargetCount;
  final int backendTargetCount;
  final int stockfishCommandLeakCount;
  final int rawUciLeakCount;
  final int pvDumpLeakCount;
  final int androidCollectorRequirementCount;
  final int unprovenAndroidProofCount;
  final int phase32EProofClaimCount;
  final int productAdapterBehaviorCount;
  final int savedAnalysisIntegrationCount;
  final int ownerProofQueueCount;

  bool get hasUnsafePolicyViolation =>
      !safeForPhase33Z ||
      validationResult.hasUnsafePolicyViolation ||
      harnessResult.hasUnsafePolicyViolation ||
      nextRecommendation != _phase33ZRecommendation ||
      unsafeCount > 0 ||
      blockerCount > 0 ||
      criticalCount > 0 ||
      activeDeniedFieldCount > 0 ||
      productOutputCount > 0 ||
      labelLeakCount > 0 ||
      finalLabelLeakCount > 0 ||
      scoreLeakCount > 0 ||
      metricLeakCount > 0 ||
      cpLossLeakCount > 0 ||
      winProbabilityLeakCount > 0 ||
      moveRankingLeakCount > 0 ||
      thresholdLeakCount > 0 ||
      uiTargetCount > 0 ||
      backendTargetCount > 0 ||
      persistenceWriteCount > 0 ||
      engineCallCount > 0 ||
      schedulerExecutionCount > 0 ||
      analyzerWiringCount > 0 ||
      runtimeImplementationCount > 0 ||
      executablePrototypeCount > 0 ||
      productAdapterBehaviorCount > 0 ||
      savedAnalysisIntegrationCount > 0 ||
      stockfishCommandLeakCount > 0 ||
      rawUciLeakCount > 0 ||
      pvDumpLeakCount > 0 ||
      androidCollectorRequirementCount > 0 ||
      unprovenAndroidProofCount > 0 ||
      phase32EProofClaimCount > 0 ||
      ownerProofQueueCount > 0;
}

void main(List<String> args) {
  final result = runDebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommand(
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

DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandResult
runDebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommand({
  required List<String> args,
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness harness =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness(),
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidation
      validation =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidation(),
}) {
  final request = validateDebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticArgs(
    args,
  );
  if (!request.isValid) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitUsage,
      format: request.format,
      section: request.section,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: '',
      stderrText: _usage(request.failure),
      commandFailure: request.failure,
    );
  }
  if (request.showHelp) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      format: request.format,
      section: request.section,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final harnessResult = harness.inspectSafeDemo();
  final validationResult = validation.evaluate(harnessResult: harnessResult);
  final diagnostic = DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult(
    validationResult: validationResult,
    harnessResult: harnessResult,
  );
  final stdoutText = switch (request.format) {
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat.markdown =>
      _renderMarkdown(diagnostic, request.section),
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat.json =>
      '${_renderJson(diagnostic, request.section)}\n',
  };
  final reportFindings =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationValidator()
          .validateReportText(stdoutText);

  return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandResult(
    exitCode: debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitCode(
      diagnostic,
      request,
      reportFindings: reportFindings,
    ),
    format: request.format,
    section: request.section,
    strict: request.strict,
    safeDemo: request.safeDemo,
    includeWarnings: request.includeWarnings,
    stdoutText: stdoutText,
    stderrText: '',
    diagnosticResult: diagnostic,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest
validateDebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticArgs(
  List<String> args,
) {
  var format = DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat.markdown;
  var section = DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.all;
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
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.valid(
        format:
            DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat.markdown,
        section: DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.all,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_sectionFlag)) {
      if (sectionSeen) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'duplicateSection',
        );
      }
      final parsed = _sectionByWire(arg.substring(_sectionFlag.length).trim());
      if (parsed == null) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
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
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.valid(
    format: format,
    section: section,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitCode(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest request, {
  List<String> reportFindings = const <String>[],
}) {
  final hasReportLeak = reportFindings.any(_isCriticalFinding);
  if (diagnostic.hasUnsafePolicyViolation || hasReportLeak) {
    return debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitUnsafePolicy;
  }
  if (request.strict &&
      (diagnostic.blockerCount > 0 ||
          diagnostic.criticalCount > 0 ||
          diagnostic.unsafeCount > 0 ||
          diagnostic.activeDeniedFieldCount > 0 ||
          diagnostic.productOutputCount > 0 ||
          diagnostic.labelLeakCount > 0 ||
          diagnostic.finalLabelLeakCount > 0 ||
          diagnostic.scoreLeakCount > 0 ||
          diagnostic.metricLeakCount > 0 ||
          diagnostic.cpLossLeakCount > 0 ||
          diagnostic.winProbabilityLeakCount > 0 ||
          diagnostic.moveRankingLeakCount > 0 ||
          diagnostic.thresholdLeakCount > 0 ||
          diagnostic.uiTargetCount > 0 ||
          diagnostic.backendTargetCount > 0 ||
          diagnostic.persistenceWriteCount > 0 ||
          diagnostic.engineCallCount > 0 ||
          diagnostic.schedulerExecutionCount > 0 ||
          diagnostic.analyzerWiringCount > 0 ||
          diagnostic.runtimeImplementationCount > 0 ||
          diagnostic.executablePrototypeCount > 0 ||
          diagnostic.productAdapterBehaviorCount > 0 ||
          diagnostic.savedAnalysisIntegrationCount > 0 ||
          diagnostic.stockfishCommandLeakCount > 0 ||
          diagnostic.rawUciLeakCount > 0 ||
          diagnostic.pvDumpLeakCount > 0 ||
          diagnostic.androidCollectorRequirementCount > 0 ||
          diagnostic.unprovenAndroidProofCount > 0 ||
          diagnostic.phase32EProofClaimCount > 0 ||
          diagnostic.nextRecommendation != _phase33ZRecommendation ||
          !diagnostic.safeForPhase33Z)) {
    return debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitBlockedStrict;
  }
  return debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess;
}

String _renderMarkdown(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection section,
) {
  final buffer = StringBuffer()
    ..writeln('# Debug-Only Bridge Analyzer Adapter Prototype Diagnostic')
    ..writeln()
    ..writeln(
      '- version: $debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandVersion',
    )
    ..writeln('- diagnostic status: ${diagnostic.status.wire}')
    ..writeln('- selected section: ${section.wire}')
    ..writeln('- safe for Phase 33Z: ${diagnostic.safeForPhase33Z}')
    ..writeln('- safe for next step: ${diagnostic.safeForPhase33Z}')
    ..writeln('- next recommendation: ${diagnostic.nextRecommendation}')
    ..writeln('- blocker count: ${diagnostic.blockerCount}')
    ..writeln('- critical count: ${diagnostic.criticalCount}')
    ..writeln('- unsafe count: ${diagnostic.unsafeCount}')
    ..writeln();

  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.all,
  )) {
    _writeSourceChain(buffer, diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.snapshot,
  )) {
    _writeSnapshot(buffer, diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.packets,
  )) {
    _writePackets(buffer, diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.policy,
  )) {
    _writePolicy(buffer, diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.records,
  )) {
    _writeRecords(buffer, diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.proof,
  )) {
    _writeProof(buffer, diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.boundaries,
  )) {
    _writeBoundaries(buffer, diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.runtime,
  )) {
    _writeRuntime(buffer, diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.recommendation,
  )) {
    _writeRecommendation(buffer, diagnostic);
  }
  return buffer.toString();
}

String _renderJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection section,
) {
  return const JsonEncoder.withIndent(
    ' ',
  ).convert(_jsonPayload(diagnostic, section));
}

Map<String, Object?> _jsonPayload(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection section,
) {
  final payload = <String, Object?>{
    'version': debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandVersion,
    'diagnosticStatus': diagnostic.status.wire,
    'section': section.wire,
    'safeForPhase33Z': diagnostic.safeForPhase33Z,
    'safeForNextStep': diagnostic.safeForPhase33Z,
    'nextRecommendation': diagnostic.nextRecommendation,
    'counts': _countsJson(diagnostic),
  };
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.all,
  )) {
    payload['sourcePhaseChain'] = _sourceChainJson(diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.snapshot,
  )) {
    payload['snapshot'] = _snapshotJson(diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.packets,
  )) {
    payload['packets'] = _packetsJson(diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.policy,
  )) {
    payload['policy'] = _policyJson(diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.records,
  )) {
    payload['records'] = _recordsJson(diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.proof,
  )) {
    payload['proof'] = _proofJson(diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.boundaries,
  )) {
    payload['boundaries'] = _boundariesJson(diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.runtime,
  )) {
    payload['runtime'] = _runtimeJson(diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.recommendation,
  )) {
    payload['next'] = _recommendationJson(diagnostic);
  }
  return payload;
}

void _writeSourceChain(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  buffer
    ..writeln('## Source Phase Chain')
    ..writeln(
      '- 33U skeleton: ${diagnostic.harnessResult.sourceSkeletonStatus.wire}',
    )
    ..writeln(
      '- 33V skeleton validation: ${diagnostic.harnessResult.sourceValidationStatus.wire}',
    )
    ..writeln(
      '- 33W inspection harness: ${diagnostic.harnessResult.status.wire}',
    )
    ..writeln(
      '- 33X inspection harness validation: ${diagnostic.validationResult.status.wire}',
    )
    ..writeln();
}

void _writeSnapshot(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  final snapshot = diagnostic.harnessResult.snapshot;
  buffer
    ..writeln('## Inspection Snapshot Summary')
    ..writeln('- snapshot ID: ${snapshot.snapshotId}')
    ..writeln('- input packet ID: ${snapshot.inputPacketId}')
    ..writeln('- context packet ID: ${snapshot.contextPacketId}')
    ..writeln('- skeleton version: ${snapshot.skeletonVersion}')
    ..writeln('- developer-only: ${snapshot.developerOnly}')
    ..writeln('- in-memory only: ${snapshot.inMemoryOnly}')
    ..writeln('- analyzer unwired: ${snapshot.analyzerUnwired}')
    ..writeln(
      '- safe for developer inspection: ${snapshot.safeForDeveloperInspection}',
    )
    ..writeln('- warning summary: ${_ids(snapshot.warningReasons)}')
    ..writeln(
      '- future prerequisites: ${_ids(_futurePrerequisites(diagnostic))}',
    )
    ..writeln();
}

void _writePackets(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  final snapshot = diagnostic.harnessResult.snapshot;
  buffer
    ..writeln('## Packet Summary')
    ..writeln('- input packet ID: ${snapshot.inputPacketId}')
    ..writeln('- context packet ID: ${snapshot.contextPacketId}')
    ..writeln(
      '- input packet validations: ${diagnostic.harnessResult.inputPacketInspectionCount}',
    )
    ..writeln(
      '- context packet validations: ${diagnostic.harnessResult.contextPacketInspectionCount}',
    )
    ..writeln('- packet summary: ${_mapSummary(snapshot.packetSummary)}')
    ..writeln();
}

void _writePolicy(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  final policy = diagnostic.harnessResult.snapshot.policySummary;
  buffer
    ..writeln('## Policy Flag Summary')
    ..writeln('- unsafe policy allowance: ${policy['hasUnsafeAllowance']}')
    ..writeln('- product output allowed: ${policy['allowsProductOutput']}')
    ..writeln('- analyzer wiring allowed: ${policy['allowsAnalyzerWiring']}')
    ..writeln(
      '- runtime implementation allowed: ${policy['allowsRuntimeImplementation']}',
    )
    ..writeln(
      '- executable prototype allowed: ${policy['allowsExecutablePrototype']}',
    )
    ..writeln('- engine calls allowed: ${policy['allowsEngineCalls']}')
    ..writeln(
      '- scheduler execution allowed: ${policy['allowsSchedulerExecution']}',
    )
    ..writeln(
      '- persistence writes allowed: ${policy['allowsPersistenceWrites']}',
    )
    ..writeln('- UI targets allowed: ${policy['allowsUiTargets']}')
    ..writeln('- backend targets allowed: ${policy['allowsBackendTargets']}')
    ..writeln('- product adapter allowed: ${policy['allowsProductAdapter']}')
    ..writeln(
      '- saved analysis integration allowed: ${policy['allowsSavedAnalysisIntegration']}',
    )
    ..writeln(
      '- classifier labels allowed: ${policy['allowsClassifierLabels']}',
    )
    ..writeln('- final labels allowed: ${policy['allowsFinalLabels']}')
    ..writeln('- numeric scores allowed: ${policy['allowsNumericScores']}')
    ..writeln('- aggregate scores allowed: ${policy['allowsAggregateScores']}')
    ..writeln('- official metrics allowed: ${policy['allowsOfficialMetrics']}')
    ..writeln('- CP-loss allowed: ${policy['allowsCpLoss']}')
    ..writeln('- win probability allowed: ${policy['allowsWinProbability']}')
    ..writeln('- move ranking allowed: ${policy['allowsMoveRanking']}')
    ..writeln(
      '- Stockfish command allowed: ${policy['allowsStockfishCommand']}',
    )
    ..writeln('- raw UCI allowed: ${policy['allowsRawUci']}')
    ..writeln('- PV dump allowed: ${policy['allowsPvDump']}')
    ..writeln();
}

void _writeRecords(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  final summary =
      diagnostic.harnessResult.snapshot.recordRoleSummary.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
  buffer
    ..writeln('## Record Role Summary')
    ..writeln('| Role | Count |')
    ..writeln('| --- | --- |');
  for (final entry in summary) {
    buffer.writeln('| ${entry.key} | ${entry.value} |');
  }
  buffer
    ..writeln()
    ..writeln('## Inspection Validation Rows')
    ..writeln('| Row | Role | Status | Findings |')
    ..writeln('| --- | --- | --- | --- |');
  for (final row in diagnostic.validationResult.validationRows) {
    buffer.writeln(
      '| ${row.validationRowId} | ${row.validationRole.wire} | '
      '${row.status.wire} | ${_ids(row.findings)} |',
    );
  }
  buffer.writeln();
}

void _writeProof(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  buffer
    ..writeln('## Android Proof Boundary Summary')
    ..writeln(
      '- captured proof IDs: ${_ids(diagnostic.harnessResult.snapshot.androidProofCaseIds)}',
    )
    ..writeln(
      '- unproven Android proof count: ${diagnostic.unprovenAndroidProofCount}',
    )
    ..writeln(
      '- Phase 32E proof claim count: ${diagnostic.phase32EProofClaimCount}',
    )
    ..writeln()
    ..writeln('## Owner Proof Summary')
    ..writeln('- owner proof queue count: ${diagnostic.ownerProofQueueCount}')
    ..writeln();
}

void _writeBoundaries(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  final snapshot = diagnostic.harnessResult.snapshot;
  buffer
    ..writeln('## Allowed/Denied Field Summary')
    ..writeln('- allowed fields: ${_ids(snapshot.allowedFieldIds)}')
    ..writeln('- denied fields: ${_ids(snapshot.deniedFieldIds)}')
    ..writeln(
      '- active denied field count: ${diagnostic.activeDeniedFieldCount}',
    )
    ..writeln('- product output count: ${diagnostic.productOutputCount}')
    ..writeln('- label leak count: ${diagnostic.labelLeakCount}')
    ..writeln('- final label leak count: ${diagnostic.finalLabelLeakCount}')
    ..writeln('- score leak count: ${diagnostic.scoreLeakCount}')
    ..writeln('- metric leak count: ${diagnostic.metricLeakCount}')
    ..writeln('- CP-loss leak count: ${diagnostic.cpLossLeakCount}')
    ..writeln(
      '- win probability leak count: ${diagnostic.winProbabilityLeakCount}',
    )
    ..writeln('- move ranking leak count: ${diagnostic.moveRankingLeakCount}')
    ..writeln('- threshold leak count: ${diagnostic.thresholdLeakCount}')
    ..writeln(
      '- Stockfish/raw UCI/PV dump denied: ${diagnostic.stockfishCommandLeakCount == 0 && diagnostic.rawUciLeakCount == 0 && diagnostic.pvDumpLeakCount == 0}',
    )
    ..writeln('- blocked boundaries: ${_ids(snapshot.blockedBoundaryIds)}')
    ..writeln();
}

void _writeRuntime(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  buffer
    ..writeln('## Runtime/Analyzer/Engine/Scheduler/Product Blocked Summary')
    ..writeln('- analyzer wiring count: ${diagnostic.analyzerWiringCount}')
    ..writeln(
      '- runtime implementation count: ${diagnostic.runtimeImplementationCount}',
    )
    ..writeln(
      '- executable prototype count: ${diagnostic.executablePrototypeCount}',
    )
    ..writeln('- engine call count: ${diagnostic.engineCallCount}')
    ..writeln(
      '- scheduler execution count: ${diagnostic.schedulerExecutionCount}',
    )
    ..writeln('- persistence write count: ${diagnostic.persistenceWriteCount}')
    ..writeln(
      '- product adapter behavior count: ${diagnostic.productAdapterBehaviorCount}',
    )
    ..writeln(
      '- saved analysis integration count: ${diagnostic.savedAnalysisIntegrationCount}',
    )
    ..writeln();
}

void _writeRecommendation(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  buffer
    ..writeln('## Recommendation')
    ..writeln('- safe for Phase 33Z: ${diagnostic.safeForPhase33Z}')
    ..writeln('- safe for next step: ${diagnostic.safeForPhase33Z}')
    ..writeln('- next recommendation: ${diagnostic.nextRecommendation}')
    ..writeln('- warnings: ${_ids(_warnings(diagnostic))}')
    ..writeln(
      '- future prerequisites: ${_ids(_futurePrerequisites(diagnostic))}',
    )
    ..writeln();
}

Map<String, Object?> _sourceChainJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  return <String, Object?>{
    'phase33U': diagnostic.harnessResult.sourceSkeletonStatus.wire,
    'phase33V': diagnostic.harnessResult.sourceValidationStatus.wire,
    'phase33W': diagnostic.harnessResult.status.wire,
    'phase33X': diagnostic.validationResult.status.wire,
  };
}

Map<String, Object?> _snapshotJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  final snapshot = diagnostic.harnessResult.snapshot;
  return <String, Object?>{
    'snapshotId': snapshot.snapshotId,
    'inputPacketId': snapshot.inputPacketId,
    'contextPacketId': snapshot.contextPacketId,
    'skeletonVersion': snapshot.skeletonVersion,
    'developerOnly': snapshot.developerOnly,
    'inMemoryOnly': snapshot.inMemoryOnly,
    'analyzerUnwired': snapshot.analyzerUnwired,
    'safeForDeveloperInspection': snapshot.safeForDeveloperInspection,
    'warningSummary': snapshot.warningReasons,
    'futurePrerequisites': _futurePrerequisites(diagnostic),
  };
}

Map<String, Object?> _packetsJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  final snapshot = diagnostic.harnessResult.snapshot;
  return <String, Object?>{
    'inputPacketId': snapshot.inputPacketId,
    'contextPacketId': snapshot.contextPacketId,
    'inputPacketInspectionCount':
        diagnostic.harnessResult.inputPacketInspectionCount,
    'contextPacketInspectionCount':
        diagnostic.harnessResult.contextPacketInspectionCount,
    'packetSummary': snapshot.packetSummary,
  };
}

Map<String, Object?> _policyJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  return Map<String, Object?>.from(
    diagnostic.harnessResult.snapshot.policySummary,
  );
}

Map<String, Object?> _recordsJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  return <String, Object?>{
    'recordRoleSummary': diagnostic.harnessResult.snapshot.recordRoleSummary,
    'validationRows': diagnostic.validationResult.validationRows
        .map(
          (row) => <String, Object?>{
            'validationRowId': row.validationRowId,
            'validationRole': row.validationRole.wire,
            'status': row.status.wire,
            'findings': row.findings,
          },
        )
        .toList(growable: false),
  };
}

Map<String, Object?> _proofJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  return <String, Object?>{
    'capturedProofIds': diagnostic.harnessResult.snapshot.androidProofCaseIds,
    'unprovenAndroidProofCount': diagnostic.unprovenAndroidProofCount,
    'phase32EProofClaimCount': diagnostic.phase32EProofClaimCount,
    'ownerProofQueueCount': diagnostic.ownerProofQueueCount,
  };
}

Map<String, Object?> _boundariesJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  final snapshot = diagnostic.harnessResult.snapshot;
  return <String, Object?>{
    'allowedFieldIds': snapshot.allowedFieldIds,
    'deniedFieldIds': snapshot.deniedFieldIds,
    'activeDeniedFieldCount': diagnostic.activeDeniedFieldCount,
    'productOutputCount': diagnostic.productOutputCount,
    'labelLeakCount': diagnostic.labelLeakCount,
    'finalLabelLeakCount': diagnostic.finalLabelLeakCount,
    'scoreLeakCount': diagnostic.scoreLeakCount,
    'metricLeakCount': diagnostic.metricLeakCount,
    'cpLossLeakCount': diagnostic.cpLossLeakCount,
    'winProbabilityLeakCount': diagnostic.winProbabilityLeakCount,
    'moveRankingLeakCount': diagnostic.moveRankingLeakCount,
    'thresholdLeakCount': diagnostic.thresholdLeakCount,
    'stockfishRawUciPvDumpDenied':
        diagnostic.stockfishCommandLeakCount == 0 &&
        diagnostic.rawUciLeakCount == 0 &&
        diagnostic.pvDumpLeakCount == 0,
    'blockedBoundaryIds': snapshot.blockedBoundaryIds,
  };
}

Map<String, Object?> _runtimeJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  return <String, Object?>{
    'analyzerWiringCount': diagnostic.analyzerWiringCount,
    'runtimeImplementationCount': diagnostic.runtimeImplementationCount,
    'executablePrototypeCount': diagnostic.executablePrototypeCount,
    'engineCallCount': diagnostic.engineCallCount,
    'schedulerExecutionCount': diagnostic.schedulerExecutionCount,
    'persistenceWriteCount': diagnostic.persistenceWriteCount,
    'productAdapterBehaviorCount': diagnostic.productAdapterBehaviorCount,
    'savedAnalysisIntegrationCount': diagnostic.savedAnalysisIntegrationCount,
  };
}

Map<String, Object?> _recommendationJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  return <String, Object?>{
    'safeForPhase33Z': diagnostic.safeForPhase33Z,
    'safeForNextStep': diagnostic.safeForPhase33Z,
    'nextRecommendation': diagnostic.nextRecommendation,
    'warnings': _warnings(diagnostic),
    'futurePrerequisites': _futurePrerequisites(diagnostic),
  };
}

Map<String, Object?> _countsJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  return <String, Object?>{
    'blockerCount': diagnostic.blockerCount,
    'criticalCount': diagnostic.criticalCount,
    'unsafeCount': diagnostic.unsafeCount,
    'analyzerWiringCount': diagnostic.analyzerWiringCount,
    'runtimeImplementationCount': diagnostic.runtimeImplementationCount,
    'executablePrototypeCount': diagnostic.executablePrototypeCount,
    'engineCallCount': diagnostic.engineCallCount,
    'schedulerExecutionCount': diagnostic.schedulerExecutionCount,
    'persistenceWriteCount': diagnostic.persistenceWriteCount,
    'productOutputCount': diagnostic.productOutputCount,
    'activeDeniedFieldCount': diagnostic.activeDeniedFieldCount,
    'labelLeakCount': diagnostic.labelLeakCount,
    'finalLabelLeakCount': diagnostic.finalLabelLeakCount,
    'scoreLeakCount': diagnostic.scoreLeakCount,
    'metricLeakCount': diagnostic.metricLeakCount,
    'cpLossLeakCount': diagnostic.cpLossLeakCount,
    'winProbabilityLeakCount': diagnostic.winProbabilityLeakCount,
    'moveRankingLeakCount': diagnostic.moveRankingLeakCount,
    'thresholdLeakCount': diagnostic.thresholdLeakCount,
    'uiTargetCount': diagnostic.uiTargetCount,
    'backendTargetCount': diagnostic.backendTargetCount,
    'stockfishCommandLeakCount': diagnostic.stockfishCommandLeakCount,
    'rawUciLeakCount': diagnostic.rawUciLeakCount,
    'pvDumpLeakCount': diagnostic.pvDumpLeakCount,
    'androidCollectorRequirementCount':
        diagnostic.androidCollectorRequirementCount,
    'unprovenAndroidProofCount': diagnostic.unprovenAndroidProofCount,
    'phase32EProofClaimCount': diagnostic.phase32EProofClaimCount,
    'ownerProofQueueCount': diagnostic.ownerProofQueueCount,
  };
}

DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus _diagnosticStatus(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationResult
  validation,
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult harness,
) {
  final sourceSafe =
      validation.safeForPhase33Y &&
      validation.phase33YRecommendation == _phase33YRequirement &&
      !validation.hasUnsafePolicyViolation &&
      harness.safeForPhase33X &&
      harness.phase33XRecommendation == _phase33XRequirement &&
      !harness.hasUnsafePolicyViolation;
  if (!sourceSafe) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus
        .blockedByUnsafeInspectionHarnessValidation;
  }
  if (_phase33ZRecommendation.isEmpty) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus
        .invalidPrototypeDiagnosticCommand;
  }
  if (validation.unsafeCount > 0 || harness.unsafeCount > 0) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus
        .blockedByPolicyBoundary;
  }
  if (validation.warningCheckCount > 0 ||
      harness.status ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionStatus
              .prototypeInspectionReadyWithWarnings) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus
        .prototypeDiagnosticCommandReadyWithWarnings;
  }
  return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus
      .prototypeDiagnosticCommandReadyClean;
}

bool _includeSection(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection selected,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection target,
) {
  return selected ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.all ||
      selected == target;
}

List<String> _warnings(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  return _sorted(<String>[
    ...diagnostic.harnessResult.snapshot.warningReasons,
    ...diagnostic.validationResult.validationRows.expand(
      (row) => row.warningReasons,
    ),
  ]);
}

List<String> _futurePrerequisites(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  return _sorted(
    diagnostic.validationResult.validationRows
        .where(
          (row) =>
              row.validationRole ==
              DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
                  .futureRequirementValidation,
        )
        .expand((row) => row.allowedFieldIds),
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat? _formatByWire(
  String wire,
) {
  for (final format
      in DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat.values) {
    if (format.wire == wire) return format;
  }
  return null;
}

DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection? _sectionByWire(
  String wire,
) {
  for (final section
      in DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.values) {
    if (section.wire == wire) return section;
  }
  return null;
}

bool _isCriticalFinding(String finding) =>
    finding.startsWith('reportTextLeak:');

String _ids(Iterable<String> values) {
  final sorted = _sorted(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

String _mapSummary(Map<String, Object?> values) {
  if (values.isEmpty) return '-';
  final entries = values.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return entries.map((entry) => '${entry.key}: ${entry.value}').join(', ');
}

List<String> _sorted(Iterable<String> values) {
  return values.where((value) => value.trim().isNotEmpty).toSet().toList()
    ..sort();
}

String _usage(String failure) {
  return [
    if (failure.isNotEmpty && failure != 'help') 'error: $failure',
    'usage: dart run tool/debug_only_bridge_analyzer_adapter_prototype_diagnostic_command.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings] [--section=all|snapshot|packets|policy|records|proof|boundaries|runtime|recommendation]',
    'defaults: --format=markdown --safe-demo --include-warnings --section=all',
  ].join('\n');
}

const _formatFlag = '--format=';
const _sectionFlag = '--section=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';

const _phase33XRequirement =
    'validateDebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness';
const _phase33YRequirement =
    'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommand';
const _phase33ZRecommendation =
    'proceedToSelectedGoldenAnalyzerAdapterPrototypeDiagnosticRun';

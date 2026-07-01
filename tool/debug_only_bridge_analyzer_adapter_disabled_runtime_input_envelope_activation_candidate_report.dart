import 'dart:convert';
import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope_activation_candidate.dart';

const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportExitSuccess =
    0;
const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportExitUsage =
    64;
const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportExitBlockedStrict =
    68;
const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportExitUnsafePolicy =
    69;

enum DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportFormat(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection {
  all('all'),
  candidate('candidate'),
  boundaries('boundaries'),
  blockedReasons('blocked-reasons'),
  denied('denied'),
  proof('proof'),
  recommendation('recommendation');

  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportCommandResult {
  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportCommandResult({
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
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
  section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateResult?
  result;
  final String? commandFailure;
}

class _CommandRequest {
  const _CommandRequest.valid({
    required this.format,
    required this.section,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const _CommandRequest.invalid(this.failure)
    : isValid = false,
      format =
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportFormat
              .markdown,
      section =
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
              .all,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
  section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result =
      runDebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportCommand(
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

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportCommandResult
runDebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportCommand({
  required List<String> args,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidate
      activationCandidate =
      const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidate(),
}) {
  final request = _parseArgs(args);
  if (!request.isValid) {
    return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportExitUsage,
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
    return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportExitSuccess,
      format: request.format,
      section: request.section,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = activationCandidate.evaluate();
  final stdoutText = switch (request.format) {
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportFormat
        .markdown =>
      _renderMarkdown(result, request.section),
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportFormat
        .json =>
      '${_renderJson(result, request.section)}\n',
  };
  final reportFindings =
      const DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateValidator()
          .validateReportText(stdoutText);
  return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportCommandResult(
    exitCode: _exitCode(
      result,
      request,
      hasTextLeak: reportFindings.isNotEmpty,
    ),
    format: request.format,
    section: request.section,
    strict: request.strict,
    safeDemo: request.safeDemo,
    includeWarnings: request.includeWarnings,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

String _renderMarkdown(
  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateResult result,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
  section,
) {
  if (section ==
      DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
          .all) {
    return result.renderMarkdown();
  }
  final buffer = StringBuffer()
    ..writeln(
      '# Disabled Analyzer Adapter Runtime Input Envelope Activation Candidate',
    )
    ..writeln()
    ..writeln('- candidate status: ${result.status.wire}')
    ..writeln('- selected section: ${section.wire}')
    ..writeln('- safe for Phase 34V: ${result.safeForPhase34V}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln();
  switch (section) {
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
        .candidate:
      _writeCandidate(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
        .boundaries:
      _writeBoundaries(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
        .blockedReasons:
      _writeBlockedReasons(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
        .denied:
      _writeDenied(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
        .proof:
      _writeProof(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
        .recommendation:
      _writeRecommendation(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
        .all:
      break;
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderJson(
  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateResult result,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
  section,
) {
  if (section ==
      DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
          .all) {
    return result.renderJson();
  }
  final payload = <String, Object?>{
    'version':
        debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateVersion,
    'status': result.status.wire,
    'section': section.wire,
    'safeForPhase34V': result.safeForPhase34V,
    'nextRecommendation': result.nextRecommendation,
  };
  switch (section) {
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
        .candidate:
      payload['candidate'] = <String, Object?>{
        'input': result.input.toJson(),
        'records': result.records
            .map((record) => record.toJson())
            .toList(growable: false),
      };
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
        .boundaries:
      payload['boundaries'] = result.boundaries
          .map((boundary) => boundary.toJson())
          .toList(growable: false);
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
        .blockedReasons:
      payload['blockedReasons'] = result.blockedReasons
          .map((reason) => reason.toJson())
          .toList(growable: false);
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
        .denied:
      payload['denied'] = <String, Object?>{
        'deniedFieldCount': result.deniedFieldCount,
        'activeDeniedFieldCount': result.activeDeniedFieldCount,
        'deniedFieldIds': result.policy.deniedFieldIds,
      };
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
        .proof:
      payload['proof'] = <String, Object?>{
        'androidProofIds': result.input.androidProofIds,
        'ownerProofRequired': result.input.ownerProofRequired,
        'proofLimitReasons': result.input.proofLimitReasons,
      };
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
        .recommendation:
      payload['recommendation'] = <String, Object?>{
        'safeForPhase34V': result.safeForPhase34V,
        'nextRecommendation': result.nextRecommendation,
        'findings': result.findings,
      };
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
        .all:
      break;
  }
  return const JsonEncoder.withIndent(' ').convert(payload);
}

void _writeCandidate(
  StringBuffer buffer,
  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateResult result,
) {
  buffer
    ..writeln('## Candidate Record Summary')
    ..writeln(
      '- activation candidate ID: ${result.input.activationCandidateId}',
    )
    ..writeln(
      '- activation candidate disabled: ${result.input.activationCandidateDisabled}',
    )
    ..writeln(
      '- activation candidate approved: ${result.input.activationCandidateApproved}',
    )
    ..writeln(
      '- activation candidate promoted: ${result.input.activationCandidatePromoted}',
    )
    ..writeln('- candidate record count: ${result.candidateRecordCount}')
    ..writeln('| Record | Role | Disabled | Blocked |')
    ..writeln('| --- | --- | --- | --- |');
  for (final record in result.records) {
    buffer.writeln(
      '| ${record.recordId} | ${record.recordRole} | ${record.disabled} | ${record.blocked} |',
    );
  }
}

void _writeBoundaries(
  StringBuffer buffer,
  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateResult result,
) {
  buffer
    ..writeln('## Boundary Summary')
    ..writeln('| Boundary | Blocked | Denied fields |')
    ..writeln('| --- | --- | --- |');
  for (final boundary in result.boundaries) {
    buffer.writeln(
      '| ${boundary.boundaryId} | ${boundary.blocked} | ${_ids(boundary.deniedFieldIds)} |',
    );
  }
}

void _writeBlockedReasons(
  StringBuffer buffer,
  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateResult result,
) {
  buffer
    ..writeln('## Blocked Reason Summary')
    ..writeln('| Reason | Blocked | Denied fields |')
    ..writeln('| --- | --- | --- |');
  for (final reason in result.blockedReasons) {
    buffer.writeln(
      '| ${reason.blockedReasonId} | ${reason.blocked} | ${_ids(reason.deniedFieldIds)} |',
    );
  }
}

void _writeDenied(
  StringBuffer buffer,
  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateResult result,
) {
  buffer
    ..writeln('## Denied Field Summary')
    ..writeln('- denied field count: ${result.deniedFieldCount}')
    ..writeln('- active denied field count: ${result.activeDeniedFieldCount}')
    ..writeln('- denied field IDs: ${_ids(result.policy.deniedFieldIds)}');
}

void _writeProof(
  StringBuffer buffer,
  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateResult result,
) {
  buffer
    ..writeln('## Proof Boundary Summary')
    ..writeln('- android proof IDs: ${_ids(result.input.androidProofIds)}')
    ..writeln('- owner proof required: ${result.input.ownerProofRequired}')
    ..writeln('- proof limit reasons: ${_ids(result.input.proofLimitReasons)}');
}

void _writeRecommendation(
  StringBuffer buffer,
  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateResult result,
) {
  buffer
    ..writeln('## Recommendation')
    ..writeln('- safe for Phase 34V: ${result.safeForPhase34V}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln('- findings: ${_ids(result.findings)}');
}

int _exitCode(
  DisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateResult result,
  _CommandRequest request, {
  required bool hasTextLeak,
}) {
  if (hasTextLeak || result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportExitUnsafePolicy;
  }
  if (request.strict &&
      (result.blockerCount > 0 ||
          result.criticalCount > 0 ||
          result.unsafeCount > 0 ||
          result.disabledEnvelopeCount < 1 ||
          result.activationPreflightCount < 1 ||
          result.activationCandidateCount < 1 ||
          result.activationCandidateApprovedCount > 0 ||
          result.activationCandidatePromotedCount > 0 ||
          result.activationApprovedCount > 0 ||
          result.activationPerformedCount > 0 ||
          result.activeRuntimeInputEnvelopeCount > 0 ||
          result.playablePayloadCount > 0 ||
          result.analyzerRuntimeInputApprovedCount > 0 ||
          result.analyzerRuntimeInputProducedCount > 0 ||
          result.runtimeExecutionApprovedCount > 0 ||
          result.runtimeExecutionCount > 0 ||
          result.analyzerWiringCount > 0 ||
          result.executableRuntimeCount > 0 ||
          result.engineCallCount > 0 ||
          result.schedulerExecutionCount > 0 ||
          result.persistenceWriteCount > 0 ||
          result.productOutputCount > 0 ||
          result.productAdapterCount > 0 ||
          result.savedAnalysisIntegrationCount > 0 ||
          result.activeDeniedFieldCount > 0 ||
          !result.safeForPhase34V ||
          result.nextRecommendation !=
              'runDisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateDiagnostic')) {
    return debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportExitBlockedStrict;
  }
  return debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportExitSuccess;
}

_CommandRequest _parseArgs(List<String> args) {
  var format =
      DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportFormat
          .markdown;
  var section =
      DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
          .all;
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
        return const _CommandRequest.invalid('helpCannotBeCombined');
      }
      return const _CommandRequest.valid(
        format:
            DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportFormat
                .markdown,
        section:
            DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
                .all,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) return const _CommandRequest.invalid('duplicateFormat');
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) return const _CommandRequest.invalid('unknownFormat');
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_sectionFlag)) {
      if (sectionSeen) return const _CommandRequest.invalid('duplicateSection');
      final parsed = _sectionByWire(arg.substring(_sectionFlag.length).trim());
      if (parsed == null) {
        return const _CommandRequest.invalid('unknownSection');
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
    section: section,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportFormat?
_formatByWire(String wire) {
  for (final format
      in DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportFormat
          .values) {
    if (format.wire == wire) return format;
  }
  return null;
}

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection?
_sectionByWire(String wire) {
  for (final section
      in DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
          .values) {
    if (section.wire == wire) return section;
  }
  return null;
}

String _ids(Iterable<String> values) {
  final sorted =
      values.where((value) => value.trim().isNotEmpty).toSet().toList()..sort();
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

String _usage(String reason) {
  return 'usage: dart run tool/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope_activation_candidate_report.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings] [--section=all|candidate|boundaries|blocked-reasons|denied|proof|recommendation]\nreason: $reason\n';
}

const _formatFlag = '--format=';
const _sectionFlag = '--section=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';

import 'dart:convert';
import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation.dart';

const debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportExitSuccess =
    0;
const debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportExitUsage =
    64;
const debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportExitBlockedStrict =
    68;
const debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportExitUnsafePolicy =
    69;

enum DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportFormat(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection {
  all('all'),
  preconditions('preconditions'),
  envelopes('envelopes'),
  blockedSeams('blocked-seams'),
  policy('policy'),
  denied('denied'),
  recommendation('recommendation');

  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportCommandResult {
  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportCommandResult({
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
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
  section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final ControlledAnalyzerAdapterRuntimePreparationResult? result;
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
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportFormat
              .markdown,
      section =
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
              .all,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
  section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result =
      runDebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportCommand(
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

DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportCommandResult
runDebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportCommand({
  required List<String> args,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation preparation =
      const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation(),
}) {
  final request = _parseArgs(args);
  if (!request.isValid) {
    return DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportExitUsage,
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
    return DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportExitSuccess,
      format: request.format,
      section: request.section,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = preparation.evaluate();
  final stdoutText = switch (request.format) {
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportFormat
        .markdown =>
      _renderMarkdown(result, request.section),
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportFormat
        .json =>
      '${_renderJson(result, request.section)}\n',
  };
  final reportFindings =
      const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationValidator()
          .validateReportText(stdoutText);
  return DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportCommandResult(
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
  ControlledAnalyzerAdapterRuntimePreparationResult result,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
  section,
) {
  if (section ==
      DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
          .all) {
    return result.renderMarkdown();
  }
  final buffer = StringBuffer()
    ..writeln('# Controlled Analyzer Adapter Runtime Preparation')
    ..writeln()
    ..writeln('- preparation status: ${result.status.wire}')
    ..writeln('- selected section: ${section.wire}')
    ..writeln('- safe for Phase 34H: ${result.safeForPhase34H}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln();
  switch (section) {
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
        .preconditions:
      buffer
        ..writeln('## Runtime Preconditions')
        ..writeln('| Precondition | Executable now | Blocked seams |')
        ..writeln('| --- | --- | --- |');
      for (final precondition in result.preconditions) {
        buffer.writeln(
          '| ${precondition.preconditionId} | ${precondition.executableNow} | ${_ids(precondition.blockedSeamIds)} |',
        );
      }
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
        .envelopes:
      buffer
        ..writeln('## Runtime Preparation Envelopes')
        ..writeln(
          '| Envelope | Role | Execution allowed | Analyzer wiring allowed | Engine calls allowed |',
        )
        ..writeln('| --- | --- | --- | --- | --- |');
      for (final envelope in result.envelopes) {
        buffer.writeln(
          '| ${envelope.envelopeId} | ${envelope.envelopeRole} | ${envelope.executionAllowed} | ${envelope.analyzerWiringAllowed} | ${envelope.engineCallsAllowed} |',
        );
      }
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
        .blockedSeams:
      buffer
        ..writeln('## Blocked Seam Summary')
        ..writeln('| Seam | Target surface | Blocked |')
        ..writeln('| --- | --- | --- |');
      for (final seam in result.blockedSeams) {
        buffer.writeln(
          '| ${seam.blockedSeamId} | ${seam.targetSurface} | ${seam.blocked} |',
        );
      }
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
        .policy:
      _writePolicy(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
        .denied:
      buffer
        ..writeln('## Denied Field Summary')
        ..writeln('- denied field count: ${result.deniedFieldCount}')
        ..writeln('- denied field ids: ${_ids(result.policy.deniedFieldIds)}');
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
        .recommendation:
      _writeRecommendation(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
        .all:
      break;
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderJson(
  ControlledAnalyzerAdapterRuntimePreparationResult result,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
  section,
) {
  if (section ==
      DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
          .all) {
    return result.renderJson();
  }
  final payload = <String, Object?>{
    'version':
        debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationVersion,
    'status': result.status.wire,
    'section': section.wire,
    'safeForPhase34H': result.safeForPhase34H,
    'nextRecommendation': result.nextRecommendation,
  };
  switch (section) {
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
        .preconditions:
      payload['preconditions'] = result.preconditions
          .map((precondition) => precondition.toJson())
          .toList(growable: false);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
        .envelopes:
      payload['envelopes'] = result.envelopes
          .map((envelope) => envelope.toJson())
          .toList(growable: false);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
        .blockedSeams:
      payload['blockedSeams'] = result.blockedSeams
          .map((seam) => seam.toJson())
          .toList(growable: false);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
        .policy:
      payload['policy'] = result.policy.toJson();
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
        .denied:
      payload['denied'] = <String, Object?>{
        'deniedFieldCount': result.deniedFieldCount,
        'deniedFieldIds': result.policy.deniedFieldIds,
      };
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
        .recommendation:
      payload['recommendation'] = <String, Object?>{
        'safeForPhase34H': result.safeForPhase34H,
        'nextRecommendation': result.nextRecommendation,
        'findings': result.findings,
      };
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
        .all:
      break;
  }
  return const JsonEncoder.withIndent(' ').convert(payload);
}

void _writePolicy(
  StringBuffer buffer,
  ControlledAnalyzerAdapterRuntimePreparationResult result,
) {
  buffer
    ..writeln('## Disabled Execution Policy')
    ..writeln('- executionAllowed: ${result.policy.executionAllowed}')
    ..writeln('- analyzerWiringAllowed: ${result.policy.analyzerWiringAllowed}')
    ..writeln('- engineCallsAllowed: ${result.policy.engineCallsAllowed}')
    ..writeln('- schedulerAllowed: ${result.policy.schedulerAllowed}')
    ..writeln('- persistenceAllowed: ${result.policy.persistenceAllowed}')
    ..writeln('- productOutputAllowed: ${result.policy.productOutputAllowed}')
    ..writeln('- productAdapterAllowed: ${result.policy.productAdapterAllowed}')
    ..writeln('- savedAnalysisAllowed: ${result.policy.savedAnalysisAllowed}');
}

void _writeRecommendation(
  StringBuffer buffer,
  ControlledAnalyzerAdapterRuntimePreparationResult result,
) {
  buffer
    ..writeln('## Recommendation')
    ..writeln('- safe for Phase 34H: ${result.safeForPhase34H}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln('- findings: ${_ids(result.findings)}');
}

int _exitCode(
  ControlledAnalyzerAdapterRuntimePreparationResult result,
  _CommandRequest request, {
  required bool hasTextLeak,
}) {
  if (hasTextLeak) {
    return debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportExitUnsafePolicy;
  }
  if (request.strict && result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportExitBlockedStrict;
  }
  if (result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportExitUnsafePolicy;
  }
  return debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportExitSuccess;
}

_CommandRequest _parseArgs(List<String> args) {
  var format =
      DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportFormat
          .markdown;
  var section =
      DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
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
            DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportFormat
                .markdown,
        section:
            DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
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

DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportFormat?
_formatByWire(String wire) {
  for (final format
      in DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportFormat
          .values) {
    if (format.wire == wire) return format;
  }
  return null;
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection?
_sectionByWire(String wire) {
  for (final section
      in DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportSection
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

String _usage(String failure) {
  return [
    if (failure.isNotEmpty && failure != 'help') 'error: $failure',
    'usage: dart run tool/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_report.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings] [--section=all|preconditions|envelopes|blocked-seams|policy|denied|recommendation]',
    'defaults: --format=markdown --safe-demo --include-warnings --section=all',
  ].join('\n');
}

const _formatFlag = '--format=';
const _sectionFlag = '--section=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';

import 'dart:io' as io;

import 'package:apex_chess/infrastructure/engine/local_engine_substrate_inventory.dart';

const localEngineSubstrateInventoryExitSuccess = 0;
const localEngineSubstrateInventoryExitUsage = 64;
const localEngineSubstrateInventoryExitBlockedStrict = 68;

enum LocalEngineSubstrateInventoryReportFormat {
  markdown('markdown'),
  json('json');

  const LocalEngineSubstrateInventoryReportFormat(this.wire);

  final String wire;
}

class LocalEngineSubstrateInventoryCommandRequest {
  const LocalEngineSubstrateInventoryCommandRequest.valid({
    required this.format,
    required this.strict,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const LocalEngineSubstrateInventoryCommandRequest.invalid(this.failure)
    : isValid = false,
      format = LocalEngineSubstrateInventoryReportFormat.markdown,
      strict = false,
      showHelp = false;

  final bool isValid;
  final String failure;
  final LocalEngineSubstrateInventoryReportFormat format;
  final bool strict;
  final bool showHelp;
}

class LocalEngineSubstrateInventoryCommandResult {
  const LocalEngineSubstrateInventoryCommandResult({
    required this.exitCode,
    required this.stdoutText,
    required this.stderrText,
    this.inventory,
  });

  final int exitCode;
  final String stdoutText;
  final String stderrText;
  final LocalEngineSubstrateInventory? inventory;
}

void main(List<String> args) {
  final result = runLocalEngineSubstrateInventoryCommand(args: args);
  if (result.stdoutText.isNotEmpty) io.stdout.write(result.stdoutText);
  if (result.stderrText.isNotEmpty) io.stderr.write(result.stderrText);
  io.exitCode = result.exitCode;
}

LocalEngineSubstrateInventoryCommandResult
runLocalEngineSubstrateInventoryCommand({
  required List<String> args,
  LocalEngineSubstrateInventoryRunner runner =
      const LocalEngineSubstrateInventoryRunner(),
}) {
  final request = validateLocalEngineSubstrateInventoryArgs(args);
  if (!request.isValid) {
    return LocalEngineSubstrateInventoryCommandResult(
      exitCode: localEngineSubstrateInventoryExitUsage,
      stdoutText: '',
      stderrText: _usage(request.failure),
    );
  }
  if (request.showHelp) {
    return LocalEngineSubstrateInventoryCommandResult(
      exitCode: localEngineSubstrateInventoryExitSuccess,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final inventory = runner.run();
  final stdoutText = switch (request.format) {
    LocalEngineSubstrateInventoryReportFormat.markdown =>
      inventory.renderMarkdown(),
    LocalEngineSubstrateInventoryReportFormat.json =>
      '${inventory.renderJson()}\n',
  };
  final blocked = request.strict && !inventory.safeForPhase35B;

  return LocalEngineSubstrateInventoryCommandResult(
    exitCode: blocked
        ? localEngineSubstrateInventoryExitBlockedStrict
        : localEngineSubstrateInventoryExitSuccess,
    stdoutText: stdoutText,
    stderrText: '',
    inventory: inventory,
  );
}

LocalEngineSubstrateInventoryCommandRequest
validateLocalEngineSubstrateInventoryArgs(List<String> args) {
  var format = LocalEngineSubstrateInventoryReportFormat.markdown;
  var strict = false;
  var formatSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const LocalEngineSubstrateInventoryCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const LocalEngineSubstrateInventoryCommandRequest.valid(
        format: LocalEngineSubstrateInventoryReportFormat.markdown,
        strict: false,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const LocalEngineSubstrateInventoryCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const LocalEngineSubstrateInventoryCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg == _strictFlag) {
      strict = true;
      continue;
    }
    return const LocalEngineSubstrateInventoryCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return LocalEngineSubstrateInventoryCommandRequest.valid(
    format: format,
    strict: strict,
  );
}

LocalEngineSubstrateInventoryReportFormat? _formatByWire(String value) {
  for (final format in LocalEngineSubstrateInventoryReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Apex local engine substrate inventory usage: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/local_engine_substrate_inventory_report.dart')
    ..writeln(
      '  dart run tool/local_engine_substrate_inventory_report.dart --format=markdown --strict',
    )
    ..writeln(
      '  dart run tool/local_engine_substrate_inventory_report.dart --format=json --strict',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln()
    ..writeln('Safety:')
    ..writeln('  This command inspects expected paths only. It does not run')
    ..writeln('  Stockfish, call FFI, spawn native processes, or send UCI.');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _strictFlag = '--strict';

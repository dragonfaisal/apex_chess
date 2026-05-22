import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/infrastructure/online_review_manual_preflight_result_review.dart';

const onlineReviewManualPreflightResultReviewExitSuccess = 0;
const onlineReviewManualPreflightResultReviewExitReviewedFailure = 2;
const onlineReviewManualPreflightResultReviewExitUsage = 64;
const onlineReviewManualPreflightResultReviewExitUnsafeOutput = 70;

class OnlineReviewManualPreflightResultReviewCommandResult {
  const OnlineReviewManualPreflightResultReviewCommandResult({
    required this.exitCode,
    required this.review,
    this.commandFailure,
  });

  final int exitCode;
  final OnlineReviewManualPreflightResultReview review;
  final String? commandFailure;

  String get markdown {
    final buffer = StringBuffer()
      ..write(renderOnlineReviewManualPreflightResultReviewMarkdown(review));
    final failure = commandFailure;
    if (failure != null) {
      buffer
        ..writeln()
        ..writeln('## Command Failure')
        ..writeln()
        ..writeln('* `$failure`');
    }
    return buffer.toString();
  }
}

Future<void> main(List<String> args) async {
  final result = await runOnlineReviewManualPreflightResultReviewCommand(
    args: args,
  );
  io.stdout.write(result.markdown);
  io.exitCode = result.exitCode;
}

Future<OnlineReviewManualPreflightResultReviewCommandResult>
runOnlineReviewManualPreflightResultReviewCommand({
  required List<String> args,
  FutureOr<String> Function()? stdinReader,
  FutureOr<String> Function(String path)? fileReader,
  String? currentDirectory,
}) async {
  final request = validateOnlineReviewManualPreflightResultReviewArgs(
    args,
    currentDirectory: currentDirectory ?? io.Directory.current.path,
  );
  if (!request.isValid) {
    return _usageResult(request.failure);
  }

  final output = await _readInput(
    request: request,
    stdinReader: stdinReader,
    fileReader: fileReader,
  );
  if (output == null) {
    return _usageResult('inputReadFailed');
  }

  final review = reviewOnlineReviewManualPreflightCommandOutput(
    OnlineReviewManualPreflightResultReviewInput(
      exitCode: request.manualPreflightExitCode,
      stdoutText: output,
      stderrText: '',
    ),
  );
  return OnlineReviewManualPreflightResultReviewCommandResult(
    exitCode: onlineReviewManualPreflightResultReviewCommandExitCode(review),
    review: review,
  );
}

OnlineReviewManualPreflightResultReviewCommandRequest
validateOnlineReviewManualPreflightResultReviewArgs(
  List<String> args, {
  required String currentDirectory,
}) {
  String? inputFile;
  bool useStdin = false;
  int? exitCode;

  for (final arg in args) {
    final lower = arg.toLowerCase();
    if (lower.contains(_httpsPrefix) || lower.contains(_httpPrefix)) {
      return const OnlineReviewManualPreflightResultReviewCommandRequest.invalid(
        'unsafeInputPath',
      );
    }
    if (arg == _stdinFlag) {
      useStdin = true;
      continue;
    }
    if (arg.startsWith(_inputFileFlag)) {
      inputFile = arg.substring(_inputFileFlag.length).trim();
      continue;
    }
    if (arg.startsWith(_exitCodeFlag)) {
      final parsed = int.tryParse(arg.substring(_exitCodeFlag.length).trim());
      if (parsed == null || parsed < 0 || parsed > 255) {
        return const OnlineReviewManualPreflightResultReviewCommandRequest.invalid(
          'invalidExitCode',
        );
      }
      exitCode = parsed;
      continue;
    }
    return const OnlineReviewManualPreflightResultReviewCommandRequest.invalid(
      'unknownFlag',
    );
  }

  if (useStdin && inputFile != null) {
    return const OnlineReviewManualPreflightResultReviewCommandRequest.invalid(
      'multipleInputModes',
    );
  }
  if (!useStdin && inputFile == null) {
    return const OnlineReviewManualPreflightResultReviewCommandRequest.invalid(
      'missingInputMode',
    );
  }
  if (exitCode == null) {
    return const OnlineReviewManualPreflightResultReviewCommandRequest.invalid(
      'missingExitCode',
    );
  }
  final path = inputFile;
  if (path != null &&
      !_isSafeLocalInputPath(path, currentDirectory: currentDirectory)) {
    return const OnlineReviewManualPreflightResultReviewCommandRequest.invalid(
      'unsafeInputPath',
    );
  }

  return OnlineReviewManualPreflightResultReviewCommandRequest.valid(
    inputFile: inputFile,
    useStdin: useStdin,
    manualPreflightExitCode: exitCode,
  );
}

int onlineReviewManualPreflightResultReviewCommandExitCode(
  OnlineReviewManualPreflightResultReview review,
) {
  return switch (review.status) {
    OnlineReviewManualPreflightResultReviewStatus.compatibleBackend =>
      onlineReviewManualPreflightResultReviewExitSuccess,
    OnlineReviewManualPreflightResultReviewStatus.rejectedForUnsafeOutput =>
      onlineReviewManualPreflightResultReviewExitUnsafeOutput,
    OnlineReviewManualPreflightResultReviewStatus.notRun ||
    OnlineReviewManualPreflightResultReviewStatus.safetyGateFailed ||
    OnlineReviewManualPreflightResultReviewStatus.networkFailed ||
    OnlineReviewManualPreflightResultReviewStatus.incompatibleBackend =>
      onlineReviewManualPreflightResultReviewExitReviewedFailure,
  };
}

class OnlineReviewManualPreflightResultReviewCommandRequest {
  const OnlineReviewManualPreflightResultReviewCommandRequest.valid({
    required this.inputFile,
    required this.useStdin,
    required this.manualPreflightExitCode,
  }) : isValid = true,
       failure = '';

  const OnlineReviewManualPreflightResultReviewCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      inputFile = null,
      useStdin = false,
      manualPreflightExitCode = null;

  final bool isValid;
  final String? inputFile;
  final bool useStdin;
  final int? manualPreflightExitCode;
  final String failure;
}

Future<String?> _readInput({
  required OnlineReviewManualPreflightResultReviewCommandRequest request,
  required FutureOr<String> Function()? stdinReader,
  required FutureOr<String> Function(String path)? fileReader,
}) async {
  try {
    if (request.useStdin) {
      if (stdinReader != null) {
        return await stdinReader();
      }
      return await io.stdin.transform(utf8.decoder).join();
    }
    final path = request.inputFile;
    if (path == null) {
      return null;
    }
    if (fileReader != null) {
      return await fileReader(path);
    }
    final file = io.File(path);
    if (!file.existsSync() ||
        file.statSync().type != io.FileSystemEntityType.file) {
      return null;
    }
    return file.readAsStringSync();
  } on FormatException {
    return null;
  } on io.FileSystemException {
    return null;
  }
}

OnlineReviewManualPreflightResultReviewCommandResult _usageResult(
  String failure,
) {
  final review = reviewOnlineReviewManualPreflightCommandOutput(
    const OnlineReviewManualPreflightResultReviewInput(
      exitCode: null,
      stdoutText: null,
      stderrText: null,
    ),
  );
  return OnlineReviewManualPreflightResultReviewCommandResult(
    exitCode: onlineReviewManualPreflightResultReviewExitUsage,
    review: review,
    commandFailure: failure,
  );
}

bool _isSafeLocalInputPath(String path, {required String currentDirectory}) {
  final trimmed = path.trim();
  if (trimmed.isEmpty) {
    return false;
  }
  final lower = trimmed.toLowerCase();
  if (lower.contains(_httpsPrefix) ||
      lower.contains(_httpPrefix) ||
      lower.startsWith('file:') ||
      lower.contains('\n') ||
      lower.contains('\r')) {
    return false;
  }

  final relative = _relativePolicyPath(
    trimmed,
    currentDirectory,
  ).replaceAll('\\', '/').toLowerCase();
  if (relative.startsWith(_allowedFixtureRoot)) {
    return true;
  }
  return !_forbiddenCommittedRoots.any(relative.startsWith);
}

String _relativePolicyPath(String path, String currentDirectory) {
  final normalizedPath = path.replaceAll('\\', '/');
  final normalizedCurrent = currentDirectory.replaceAll('\\', '/');
  final lowerPath = normalizedPath.toLowerCase();
  final lowerCurrent = normalizedCurrent.toLowerCase();
  if (lowerPath.startsWith('$lowerCurrent/')) {
    return normalizedPath.substring(normalizedCurrent.length + 1);
  }
  if (normalizedPath.startsWith('./')) {
    return normalizedPath.substring(2);
  }
  return normalizedPath;
}

const _inputFileFlag = '--input-file=';
const _stdinFlag = '--stdin';
const _exitCodeFlag = '--exit-code=';
const _allowedFixtureRoot =
    'test/fixtures/online_review_manual_preflight_result_review/';
const _forbiddenCommittedRoots = [
  '.github/',
  '.git/',
  'docs/',
  'lib/',
  'test/',
  'tool/',
];
const _httpsPrefix =
    'https'
    '://';
const _httpPrefix =
    'http'
    '://';

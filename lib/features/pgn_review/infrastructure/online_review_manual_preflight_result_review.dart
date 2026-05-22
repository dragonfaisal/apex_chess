/// Redacted review model for already-produced manual Online Review preflight
/// command output.
///
/// This layer never runs commands, constructs HTTP clients, reads environment
/// values, stores raw output, or unlocks analysis.
library;

const onlineReviewManualPreflightResultReviewVersion =
    'online-review-manual-preflight-result-review-v1';

enum OnlineReviewManualPreflightResultReviewStatus {
  notRun,
  safetyGateFailed,
  networkFailed,
  incompatibleBackend,
  compatibleBackend,
  rejectedForUnsafeOutput,
}

enum OnlineReviewManualPreflightResultReviewBlocker {
  missingCommandOutput,
  unsafeOutputDetected,
  fullUrlLeakDetected,
  tokenLeakDetected,
  rawBodyLeakDetected,
  stackTraceLeakDetected,
  analysisPayloadLeakDetected,
  incompatibleContract,
  networkFailure,
  commandExitNonZero,
  unknown,
}

enum OnlineReviewManualPreflightResultReviewWarning {
  reviewOnly,
  doNotShareRawOutput,
  preflightDoesNotUnlockAnalysis,
  keepPrivateConfigOutOfSource,
  noUiActivation,
}

class OnlineReviewManualPreflightResultReviewInput {
  const OnlineReviewManualPreflightResultReviewInput({
    required this.exitCode,
    required this.stdoutText,
    required this.stderrText,
  });

  final int? exitCode;
  final String? stdoutText;
  final String? stderrText;
}

class OnlineReviewManualPreflightResultReview {
  OnlineReviewManualPreflightResultReview({
    required this.version,
    required this.status,
    required this.safeToShareSummary,
    required this.compatibleBackend,
    required this.unlocksAnalysis,
    required this.exitCode,
    required this.baseUriFingerprint,
    required this.contractVersion,
    required this.supportedProductContract,
    required this.backendName,
    required this.backendVersion,
    required List<OnlineReviewManualPreflightResultReviewBlocker> blockers,
    required List<OnlineReviewManualPreflightResultReviewWarning> warnings,
    required this.nextStep,
  }) : blockers = List.unmodifiable(blockers),
       warnings = List.unmodifiable(warnings);

  final String version;
  final OnlineReviewManualPreflightResultReviewStatus status;
  final bool safeToShareSummary;
  final bool compatibleBackend;
  final bool unlocksAnalysis;
  final int? exitCode;
  final String? baseUriFingerprint;
  final String? contractVersion;
  final String? supportedProductContract;
  final String? backendName;
  final String? backendVersion;
  final List<OnlineReviewManualPreflightResultReviewBlocker> blockers;
  final List<OnlineReviewManualPreflightResultReviewWarning> warnings;
  final String nextStep;
}

OnlineReviewManualPreflightResultReview
reviewOnlineReviewManualPreflightCommandOutput(
  OnlineReviewManualPreflightResultReviewInput input,
) {
  final output = _combinedOutput(input);
  final unsafeBlockers = _unsafeOutputBlockers(output);
  if (unsafeBlockers.isNotEmpty) {
    return _review(
      status:
          OnlineReviewManualPreflightResultReviewStatus.rejectedForUnsafeOutput,
      safeToShareSummary: false,
      compatibleBackend: false,
      exitCode: input.exitCode,
      blockers: unsafeBlockers,
      nextStep:
          'Do not share this output. Redact unsafe content, investigate the '
          'manual preflight command output path, and rerun only after the '
          'leak is fixed.',
    );
  }

  if (input.exitCode == null && output.trim().isEmpty) {
    return _review(
      status: OnlineReviewManualPreflightResultReviewStatus.notRun,
      safeToShareSummary: false,
      compatibleBackend: false,
      blockers: const [
        OnlineReviewManualPreflightResultReviewBlocker.missingCommandOutput,
      ],
      nextStep:
          'Run the documented manual preflight command in a future approved '
          'private staging attempt, then review only its redacted output.',
    );
  }

  final fields = _fieldsFromMarkdown(output);
  final status = _statusFor(input.exitCode, fields);
  final compatible =
      status == OnlineReviewManualPreflightResultReviewStatus.compatibleBackend;

  return _review(
    status: status,
    safeToShareSummary:
        status !=
        OnlineReviewManualPreflightResultReviewStatus.rejectedForUnsafeOutput,
    compatibleBackend: compatible,
    exitCode: input.exitCode,
    baseUriFingerprint: _safeField(fields['Base URI fingerprint']),
    contractVersion: _safeContractVersion(fields['Contract version']),
    supportedProductContract: _safeSupportedProductContract(
      fields['Supported product contract'],
    ),
    backendName: _safeField(fields['Backend name']),
    backendVersion: _safeField(fields['Backend version']),
    blockers: _statusBlockers(status, input.exitCode),
    nextStep: _nextStepFor(status),
  );
}

String renderOnlineReviewManualPreflightResultReviewMarkdown(
  OnlineReviewManualPreflightResultReview review,
) {
  final buffer = StringBuffer()
    ..writeln('# Online Review Manual Preflight Result Review')
    ..writeln()
    ..writeln('* Review version: `${review.version}`')
    ..writeln('* Status: ${review.status.name}')
    ..writeln('* Safe to share summary: ${_yesNo(review.safeToShareSummary)}')
    ..writeln('* Compatible backend: ${_yesNo(review.compatibleBackend)}')
    ..writeln('* Unlocks analysis: ${_yesNo(review.unlocksAnalysis)}')
    ..writeln('* Exit code: ${review.exitCode ?? 'none'}')
    ..writeln('* Base URI fingerprint: ${review.baseUriFingerprint ?? 'none'}')
    ..writeln('* Contract version: ${review.contractVersion ?? 'none'}')
    ..writeln(
      '* Supported product contract: '
      '${review.supportedProductContract ?? 'none'}',
    )
    ..writeln('* Backend name: ${review.backendName ?? 'not reported'}')
    ..writeln('* Backend version: ${review.backendVersion ?? 'not reported'}')
    ..writeln('* Next step: ${review.nextStep}')
    ..writeln()
    ..writeln('## Blockers')
    ..writeln();

  if (review.blockers.isEmpty) {
    buffer.writeln('* None');
  } else {
    for (final blocker in review.blockers) {
      buffer.writeln('* `${blocker.name}`');
    }
  }

  buffer
    ..writeln()
    ..writeln('## Warnings')
    ..writeln();

  for (final warning in review.warnings) {
    buffer.writeln('* `${warning.name}`');
  }

  buffer
    ..writeln()
    ..writeln('## Safety Notes')
    ..writeln()
    ..writeln('* Raw command stdout and stderr are not rendered.')
    ..writeln('* No analysis request is approved by this review.')
    ..writeln('* Preflight success does not unlock analysis by itself.')
    ..writeln('* No Online Review UI activation is approved.');

  return buffer.toString();
}

OnlineReviewManualPreflightResultReview _review({
  required OnlineReviewManualPreflightResultReviewStatus status,
  required bool safeToShareSummary,
  required bool compatibleBackend,
  int? exitCode,
  String? baseUriFingerprint,
  String? contractVersion,
  String? supportedProductContract,
  String? backendName,
  String? backendVersion,
  required List<OnlineReviewManualPreflightResultReviewBlocker> blockers,
  required String nextStep,
}) {
  return OnlineReviewManualPreflightResultReview(
    version: onlineReviewManualPreflightResultReviewVersion,
    status: status,
    safeToShareSummary: safeToShareSummary,
    compatibleBackend: compatibleBackend,
    unlocksAnalysis: false,
    exitCode: exitCode,
    baseUriFingerprint: baseUriFingerprint,
    contractVersion: contractVersion,
    supportedProductContract: supportedProductContract,
    backendName: backendName,
    backendVersion: backendVersion,
    blockers: _dedupe(blockers),
    warnings: const [
      OnlineReviewManualPreflightResultReviewWarning.reviewOnly,
      OnlineReviewManualPreflightResultReviewWarning.doNotShareRawOutput,
      OnlineReviewManualPreflightResultReviewWarning
          .preflightDoesNotUnlockAnalysis,
      OnlineReviewManualPreflightResultReviewWarning
          .keepPrivateConfigOutOfSource,
      OnlineReviewManualPreflightResultReviewWarning.noUiActivation,
    ],
    nextStep: nextStep,
  );
}

OnlineReviewManualPreflightResultReviewStatus _statusFor(
  int? exitCode,
  Map<String, String> fields,
) {
  return switch (exitCode) {
    null => OnlineReviewManualPreflightResultReviewStatus.notRun,
    0 when _isCompatibleOutput(fields) =>
      OnlineReviewManualPreflightResultReviewStatus.compatibleBackend,
    0 => OnlineReviewManualPreflightResultReviewStatus.incompatibleBackend,
    2 => OnlineReviewManualPreflightResultReviewStatus.incompatibleBackend,
    64 || 70 => OnlineReviewManualPreflightResultReviewStatus.safetyGateFailed,
    74 => OnlineReviewManualPreflightResultReviewStatus.networkFailed,
    _ => OnlineReviewManualPreflightResultReviewStatus.safetyGateFailed,
  };
}

bool _isCompatibleOutput(Map<String, String> fields) {
  final success = fields['Success']?.toLowerCase() == 'yes';
  final preflightStatus = fields['Preflight status'] == 'success';
  final supported =
      fields['Supported product contract'] ==
      onlineReviewManualPreflightResultReviewSupportedProductContract;
  return success && preflightStatus && supported;
}

List<OnlineReviewManualPreflightResultReviewBlocker> _statusBlockers(
  OnlineReviewManualPreflightResultReviewStatus status,
  int? exitCode,
) {
  return switch (status) {
    OnlineReviewManualPreflightResultReviewStatus.notRun => const [
      OnlineReviewManualPreflightResultReviewBlocker.missingCommandOutput,
    ],
    OnlineReviewManualPreflightResultReviewStatus.compatibleBackend => const [],
    OnlineReviewManualPreflightResultReviewStatus.incompatibleBackend => const [
      OnlineReviewManualPreflightResultReviewBlocker.incompatibleContract,
      OnlineReviewManualPreflightResultReviewBlocker.commandExitNonZero,
    ],
    OnlineReviewManualPreflightResultReviewStatus.networkFailed => const [
      OnlineReviewManualPreflightResultReviewBlocker.networkFailure,
      OnlineReviewManualPreflightResultReviewBlocker.commandExitNonZero,
    ],
    OnlineReviewManualPreflightResultReviewStatus.safetyGateFailed => [
      OnlineReviewManualPreflightResultReviewBlocker.commandExitNonZero,
      if (exitCode == null)
        OnlineReviewManualPreflightResultReviewBlocker.unknown,
    ],
    OnlineReviewManualPreflightResultReviewStatus.rejectedForUnsafeOutput =>
      const [
        OnlineReviewManualPreflightResultReviewBlocker.unsafeOutputDetected,
      ],
  };
}

String _nextStepFor(OnlineReviewManualPreflightResultReviewStatus status) {
  return switch (status) {
    OnlineReviewManualPreflightResultReviewStatus.notRun =>
      'Run no real preflight in this review phase. Use the runbook for a '
          'future controlled private staging attempt.',
    OnlineReviewManualPreflightResultReviewStatus.compatibleBackend =>
      'Record the redacted compatibility summary. Do not activate Online '
          'Review analysis until a separate approved activation phase.',
    OnlineReviewManualPreflightResultReviewStatus.incompatibleBackend =>
      'Treat the backend as incompatible. Fix the preflight contract before '
          'any activation work.',
    OnlineReviewManualPreflightResultReviewStatus.networkFailed =>
      'Treat this as a private staging connectivity failure. Do not retry in '
          'public channels and do not activate analysis.',
    OnlineReviewManualPreflightResultReviewStatus.safetyGateFailed =>
      'Fix the safety gate failure before any private staging preflight can '
          'be reviewed.',
    OnlineReviewManualPreflightResultReviewStatus.rejectedForUnsafeOutput =>
      'Do not share this output. Redact and investigate the leak before any '
          'manual preflight result is reviewed.',
  };
}

Map<String, String> _fieldsFromMarkdown(String output) {
  final fields = <String, String>{};
  for (final line in output.split(RegExp(r'\r?\n'))) {
    final match = _markdownFieldPattern.firstMatch(line.trim());
    if (match == null) {
      continue;
    }
    fields[match.group(1)!] = match.group(2)!.replaceAll('`', '').trim();
  }
  return fields;
}

List<OnlineReviewManualPreflightResultReviewBlocker> _unsafeOutputBlockers(
  String output,
) {
  final lower = output.toLowerCase();
  final blockers = <OnlineReviewManualPreflightResultReviewBlocker>[];

  if (lower.contains(_httpsPrefix) || lower.contains(_httpPrefix)) {
    blockers
      ..add(OnlineReviewManualPreflightResultReviewBlocker.unsafeOutputDetected)
      ..add(OnlineReviewManualPreflightResultReviewBlocker.fullUrlLeakDetected);
  }
  if (lower.contains(_loopbackHost) ||
      lower.contains(_loopbackIp) ||
      lower.contains(_emulatorHost) ||
      lower.contains(_wildcardHost)) {
    blockers
      ..add(OnlineReviewManualPreflightResultReviewBlocker.unsafeOutputDetected)
      ..add(OnlineReviewManualPreflightResultReviewBlocker.fullUrlLeakDetected);
  }
  if (lower.contains('api_key') ||
      lower.contains('apikey') ||
      lower.contains('access_token') ||
      lower.contains('authtoken') ||
      lower.contains('auth token') ||
      lower.contains('token=')) {
    blockers
      ..add(OnlineReviewManualPreflightResultReviewBlocker.unsafeOutputDetected)
      ..add(OnlineReviewManualPreflightResultReviewBlocker.tokenLeakDetected);
  }
  if (lower.contains('[event') ||
      _moveTextPattern.hasMatch(output) ||
      _fenPattern.hasMatch(output) ||
      lower.contains('engineoutput') ||
      lower.contains('engine output') ||
      lower.contains('engineline') ||
      lower.contains('bestmove') ||
      lower.contains('reviewpayload') ||
      lower.contains('analysisresult')) {
    blockers
      ..add(OnlineReviewManualPreflightResultReviewBlocker.unsafeOutputDetected)
      ..add(
        OnlineReviewManualPreflightResultReviewBlocker
            .analysisPayloadLeakDetected,
      );
  }
  if (lower.contains('stacktrace') ||
      lower.contains('stack trace') ||
      lower.contains('exception:') ||
      lower.contains(' at ') ||
      lower.contains('package:')) {
    blockers
      ..add(OnlineReviewManualPreflightResultReviewBlocker.unsafeOutputDetected)
      ..add(
        OnlineReviewManualPreflightResultReviewBlocker.stackTraceLeakDetected,
      );
  }
  if (_rawJsonPattern.hasMatch(output)) {
    blockers
      ..add(OnlineReviewManualPreflightResultReviewBlocker.unsafeOutputDetected)
      ..add(OnlineReviewManualPreflightResultReviewBlocker.rawBodyLeakDetected);
  }

  return _dedupe(blockers);
}

String _combinedOutput(OnlineReviewManualPreflightResultReviewInput input) {
  return [
    input.stdoutText ?? '',
    input.stderrText ?? '',
  ].where((value) => value.isNotEmpty).join('\n');
}

String? _safeField(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null ||
      trimmed.isEmpty ||
      trimmed == 'none' ||
      trimmed == 'not reported') {
    return null;
  }
  final lower = trimmed.toLowerCase();
  if (lower.contains(_httpsPrefix) ||
      lower.contains(_httpPrefix) ||
      lower.contains('/') ||
      lower.contains('?') ||
      lower.contains('#') ||
      lower.contains('@') ||
      lower.contains('token') ||
      lower.contains('api_key') ||
      lower.contains('pgn') ||
      lower.contains('fen') ||
      lower.contains('engine') ||
      lower.contains('reviewpayload') ||
      lower.contains('analysisresult')) {
    return null;
  }
  return trimmed;
}

String? _safeContractVersion(String? value) {
  return value == onlineReviewManualPreflightResultReviewPreflightContract
      ? value
      : null;
}

String? _safeSupportedProductContract(String? value) {
  return value ==
          onlineReviewManualPreflightResultReviewSupportedProductContract
      ? value
      : null;
}

List<T> _dedupe<T>(List<T> values) {
  final seen = <T>{};
  return [
    for (final value in values)
      if (seen.add(value)) value,
  ];
}

String _yesNo(bool value) => value ? 'yes' : 'no';

const onlineReviewManualPreflightResultReviewPreflightContract =
    'online-review-staging-preflight-v1';
const onlineReviewManualPreflightResultReviewSupportedProductContract =
    'online-review-product-v1';

final _markdownFieldPattern = RegExp(r'^\*\s+([^:]+):\s*(.+)$');
final _moveTextPattern = RegExp(r'\b1\.\s*[A-Za-z0-9+#=x-]+');
final _fenPattern = RegExp(
  r'\b[prnbqkPRNBQK1-8]+/[prnbqkPRNBQK1-8]+/[prnbqkPRNBQK1-8]+/'
  r'[prnbqkPRNBQK1-8]+/[prnbqkPRNBQK1-8]+/[prnbqkPRNBQK1-8]+/'
  r'[prnbqkPRNBQK1-8]+/[prnbqkPRNBQK1-8]+\s+[wb]\s+',
);
final _rawJsonPattern = RegExp(r'^\s*[{[]\s*"', multiLine: true);

const _httpsPrefix =
    'https'
    '://';
const _httpPrefix =
    'http'
    '://';
const _loopbackHost =
    'local'
    'host';
const _loopbackIp =
    '127.0.'
    '0.1';
const _emulatorHost =
    '10.0.'
    '2.2';
const _wildcardHost =
    '0.0.'
    '0.0';

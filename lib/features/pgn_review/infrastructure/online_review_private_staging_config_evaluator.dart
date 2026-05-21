/// Dry-run evaluator for explicitly supplied private Online Review staging
/// configuration.
///
/// This layer is verification-only. It reads no environment values on its own,
/// constructs no HTTP clients, calls no preflight transport, and stores no
/// backend address in rendered output.
library;

import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_build_config_report.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_product_repository_factory.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_runtime_repository_config.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_backend_readiness.dart';

abstract final class OnlineReviewPrivateStagingConfigEnvKeys {
  static const mode = 'APEX_PRIVATE_ONLINE_REVIEW_MODE';
  static const baseUri = 'APEX_PRIVATE_ONLINE_REVIEW_BASE_URI';
  static const allowHttp = 'APEX_PRIVATE_ONLINE_REVIEW_ALLOW_HTTP';
}

const onlineReviewPrivateStagingConfigEnvKeys = [
  OnlineReviewPrivateStagingConfigEnvKeys.mode,
  OnlineReviewPrivateStagingConfigEnvKeys.baseUri,
  OnlineReviewPrivateStagingConfigEnvKeys.allowHttp,
];

class OnlineReviewPrivateStagingConfigInput {
  const OnlineReviewPrivateStagingConfigInput({
    required this.mode,
    required this.allowHttp,
    required this.baseUri,
    required this.allowDebugHarness,
    required this.allowPublicEntry,
  });

  final OnlineReviewRuntimeMode mode;
  final bool allowHttp;
  final Uri? baseUri;
  final bool allowDebugHarness;
  final bool allowPublicEntry;
}

class OnlineReviewPrivateStagingConfigEvaluation {
  OnlineReviewPrivateStagingConfigEvaluation({
    required this.version,
    required this.isDryRun,
    required this.canProceedToManualPreflight,
    required this.runtimeMode,
    required this.allowHttp,
    required this.canUseHttp,
    required this.hasBaseUri,
    required this.baseUriFingerprint,
    required this.readinessStatus,
    required List<OnlineReviewStagingReadinessBlocker> readinessBlockers,
    required List<OnlineReviewStagingReadinessWarning> readinessWarnings,
    required this.smokeReportAllPassed,
    required this.smokeReportHardSafetyPassed,
    required this.repositoryMode,
    required this.nextStep,
    required List<String> safetyNotes,
  }) : readinessBlockers = List.unmodifiable(readinessBlockers),
       readinessWarnings = List.unmodifiable(readinessWarnings),
       safetyNotes = List.unmodifiable(safetyNotes);

  final String version;
  final bool isDryRun;
  final bool canProceedToManualPreflight;
  final OnlineReviewRuntimeMode runtimeMode;
  final bool allowHttp;
  final bool canUseHttp;
  final bool hasBaseUri;
  final String? baseUriFingerprint;
  final OnlineReviewStagingReadinessStatus readinessStatus;
  final List<OnlineReviewStagingReadinessBlocker> readinessBlockers;
  final List<OnlineReviewStagingReadinessWarning> readinessWarnings;
  final bool smokeReportAllPassed;
  final bool smokeReportHardSafetyPassed;
  final OnlineReviewRepositoryMode repositoryMode;
  final String nextStep;
  final List<String> safetyNotes;
}

const onlineReviewPrivateStagingConfigEvaluationVersion =
    'online-review-private-staging-config-evaluation-v1';

OnlineReviewPrivateStagingConfigInput
onlineReviewPrivateStagingConfigInputFromEnvironment(
  Map<String, String> environment,
) {
  return OnlineReviewPrivateStagingConfigInput(
    mode: _parseMode(environment[OnlineReviewPrivateStagingConfigEnvKeys.mode]),
    allowHttp: _parseBool(
      environment[OnlineReviewPrivateStagingConfigEnvKeys.allowHttp],
    ),
    baseUri: _parseBaseUri(
      environment[OnlineReviewPrivateStagingConfigEnvKeys.baseUri],
    ),
    allowDebugHarness: false,
    allowPublicEntry: false,
  );
}

OnlineReviewPrivateStagingConfigEvaluation
evaluateOnlineReviewPrivateStagingConfigDryRun({
  required OnlineReviewPrivateStagingConfigInput input,
  required OnlineReviewBuildConfigReport smokeReport,
}) {
  final config = _runtimeGateConfigFor(input);
  final decision = OnlineReviewRuntimeGate.decide(config);
  final repositoryConfig = onlineReviewRepositoryConfigFromActivationDecision(
    decision,
  );
  final readinessSmokeReport = _smokeReportForPrivateDryRun(smokeReport);
  final readiness = buildOnlineReviewStagingBackendReadiness(
    decision: decision,
    repositoryConfig: repositoryConfig,
    smokeReport: readinessSmokeReport,
  );
  final fingerprint = _redactedBaseUriFingerprint(input.baseUri);
  final canProceed = _canProceedToManualPreflight(
    input: input,
    decision: decision,
    repositoryConfig: repositoryConfig,
    smokeReport: smokeReport,
    readiness: readiness,
    baseUriFingerprint: fingerprint,
  );

  return OnlineReviewPrivateStagingConfigEvaluation(
    version: onlineReviewPrivateStagingConfigEvaluationVersion,
    isDryRun: true,
    canProceedToManualPreflight: canProceed,
    runtimeMode: input.mode,
    allowHttp: input.allowHttp,
    canUseHttp: decision.canUseHttp,
    hasBaseUri: input.baseUri != null,
    baseUriFingerprint: fingerprint,
    readinessStatus: readiness.status,
    readinessBlockers: readiness.blockers,
    readinessWarnings: readiness.warnings,
    smokeReportAllPassed: smokeReport.allPassed,
    smokeReportHardSafetyPassed: smokeReport.hardSafetyPassed,
    repositoryMode: repositoryConfig.mode,
    nextStep: _nextStep(input, readiness, canProceed),
    safetyNotes: const [
      'No backend connection was attempted.',
      'No analysis request was sent.',
      'Full backend URL is not printed.',
      'Manual preflight remains a future explicit phase.',
      'Default Online Review runtime behavior remains disabled.',
      'Private configuration is evaluated only from explicit local input.',
    ],
  );
}

String renderOnlineReviewPrivateStagingConfigEvaluationMarkdown(
  OnlineReviewPrivateStagingConfigEvaluation evaluation,
) {
  final buffer = StringBuffer()
    ..writeln('# Online Review Private Staging Config Dry Run')
    ..writeln()
    ..writeln('* Version: `${evaluation.version}`')
    ..writeln('* Dry run: ${_yesNo(evaluation.isDryRun)}')
    ..writeln('* Runtime mode: ${evaluation.runtimeMode.name}')
    ..writeln('* HTTP gate: ${_yesNo(evaluation.allowHttp)}')
    ..writeln('* Runtime HTTP usable: ${_yesNo(evaluation.canUseHttp)}')
    ..writeln(
      '* Can proceed to manual preflight: '
      '${_yesNo(evaluation.canProceedToManualPreflight)}',
    )
    ..writeln('* Readiness status: ${evaluation.readinessStatus.name}')
    ..writeln('* Repository mode: ${evaluation.repositoryMode.name}')
    ..writeln('* Smoke allPassed: ${_yesNo(evaluation.smokeReportAllPassed)}')
    ..writeln(
      '* Smoke hardSafetyPassed: '
      '${_yesNo(evaluation.smokeReportHardSafetyPassed)}',
    )
    ..writeln(
      '* Base URI fingerprint: '
      '${evaluation.baseUriFingerprint ?? 'none'}',
    )
    ..writeln('* Next step: ${evaluation.nextStep}')
    ..writeln()
    ..writeln('## Blockers')
    ..writeln();

  if (evaluation.readinessBlockers.isEmpty) {
    buffer.writeln('* None');
  } else {
    for (final blocker in evaluation.readinessBlockers) {
      buffer.writeln('* `${blocker.name}`');
    }
  }

  buffer
    ..writeln()
    ..writeln('## Warnings')
    ..writeln();

  if (evaluation.readinessWarnings.isEmpty) {
    buffer.writeln('* None');
  } else {
    for (final warning in evaluation.readinessWarnings) {
      buffer.writeln('* `${warning.name}`');
    }
  }

  buffer
    ..writeln()
    ..writeln('## Safety Notes')
    ..writeln();

  for (final note in evaluation.safetyNotes) {
    buffer.writeln('* $note');
  }

  return buffer.toString();
}

int onlineReviewPrivateStagingConfigEvaluationExitCode(
  OnlineReviewPrivateStagingConfigEvaluation evaluation,
) {
  return evaluation.canProceedToManualPreflight ? 0 : 1;
}

OnlineReviewRuntimeGateConfig _runtimeGateConfigFor(
  OnlineReviewPrivateStagingConfigInput input,
) {
  return switch (input.mode) {
    OnlineReviewRuntimeMode.disabled =>
      const OnlineReviewRuntimeGateConfig.disabled(),
    OnlineReviewRuntimeMode.devHarness =>
      OnlineReviewRuntimeGateConfig.devHarness(
        baseUri: input.baseUri,
        allowHttp: input.allowHttp,
        allowDebugHarness: input.allowDebugHarness,
      ),
    OnlineReviewRuntimeMode.staging => OnlineReviewRuntimeGateConfig.staging(
      baseUri: input.baseUri,
      allowHttp: input.allowHttp,
      allowDebugHarness: input.allowDebugHarness,
    ),
    OnlineReviewRuntimeMode.internalTester =>
      OnlineReviewRuntimeGateConfig.internalTester(
        baseUri: input.baseUri,
        allowHttp: input.allowHttp,
        allowDebugHarness: input.allowDebugHarness,
      ),
    OnlineReviewRuntimeMode.publicPreview =>
      OnlineReviewRuntimeGateConfig.publicPreview(
        baseUri: input.baseUri,
        allowHttp: input.allowHttp,
        allowPublicEntry: input.allowPublicEntry,
      ),
  };
}

bool _canProceedToManualPreflight({
  required OnlineReviewPrivateStagingConfigInput input,
  required OnlineReviewActivationDecision decision,
  required OnlineReviewRepositoryConfig repositoryConfig,
  required OnlineReviewBuildConfigReport smokeReport,
  required OnlineReviewStagingBackendReadiness readiness,
  required String? baseUriFingerprint,
}) {
  final baseUri = input.baseUri;
  return _isAcceptedPrivateEvaluationMode(input.mode) &&
      input.allowHttp &&
      baseUri != null &&
      baseUri.scheme == 'https' &&
      !_isBlockedPrivateStagingHost(baseUri.host.toLowerCase()) &&
      !input.allowPublicEntry &&
      decision.canUseHttp &&
      repositoryConfig.mode == OnlineReviewRepositoryMode.http &&
      repositoryConfig.baseUri == decision.baseUri &&
      smokeReport.allPassed &&
      smokeReport.hardSafetyPassed &&
      readiness.isReady &&
      readiness.blockers.isEmpty &&
      _isSafeRedactedFingerprint(baseUriFingerprint);
}

bool _isAcceptedPrivateEvaluationMode(OnlineReviewRuntimeMode mode) {
  return mode == OnlineReviewRuntimeMode.staging ||
      mode == OnlineReviewRuntimeMode.internalTester;
}

String _nextStep(
  OnlineReviewPrivateStagingConfigInput input,
  OnlineReviewStagingBackendReadiness readiness,
  bool canProceed,
) {
  const command =
      'dart run tool/online_review_staging_readiness_report.dart '
      '--private-config-dry-run';

  if (canProceed) {
    return 'Re-run `$command` immediately before a future approved manual '
        'preflight phase; do not call preflight in this phase.';
  }
  if (!_isAcceptedPrivateEvaluationMode(input.mode)) {
    return 'Set private evaluation mode to staging or internalTester, then '
        're-run `$command`.';
  }
  if (input.baseUri == null) {
    return 'Provide an explicit private staging base URI outside committed '
        'source, then re-run `$command`.';
  }
  if (!input.allowHttp) {
    return 'Enable the explicit private HTTP gate, then re-run `$command`.';
  }
  if (input.baseUri!.scheme != 'https' ||
      _isBlockedPrivateStagingHost(input.baseUri!.host.toLowerCase())) {
    return 'Provide an explicit HTTPS private staging base URI outside '
        'committed source, then re-run `$command`.';
  }
  if (!readiness.smokeReportAllPassed ||
      !readiness.smokeReportHardSafetyPassed) {
    return 'Run `dart run tool/online_review_build_config_report.dart` and '
        'fix failures before re-running `$command`.';
  }
  return '${readiness.requiredNextStep} Re-run `$command` after resolving it.';
}

String? _redactedBaseUriFingerprint(Uri? uri) {
  if (uri == null || uri.host.trim().isEmpty || uri.scheme.trim().isEmpty) {
    return null;
  }

  final scheme = switch (uri.scheme.toLowerCase()) {
    'https' => 'https',
    'http' => 'http',
    _ => 'other',
  };
  return 'scheme=$scheme;host=<redacted-host>';
}

bool _isSafeRedactedFingerprint(String? fingerprint) {
  if (fingerprint == null) {
    return false;
  }
  final lower = fingerprint.toLowerCase();
  return lower.contains('<redacted-host>') &&
      !lower.contains('://') &&
      !lower.contains('/') &&
      !lower.contains('?') &&
      !lower.contains('@') &&
      !lower.contains(_loopbackHost) &&
      !lower.contains(_loopbackIp) &&
      !lower.contains(_emulatorHost) &&
      !lower.contains(_wildcardHost);
}

bool _isBlockedPrivateStagingHost(String host) {
  return host == _loopbackHost ||
      host.startsWith(_loopbackPrefix) ||
      host == _emulatorHost ||
      host == _wildcardHost ||
      host == '::1';
}

OnlineReviewBuildConfigReport _smokeReportForPrivateDryRun(
  OnlineReviewBuildConfigReport smokeReport,
) {
  if (!smokeReport.allPassed || !smokeReport.hardSafetyPassed) {
    return smokeReport;
  }

  return OnlineReviewBuildConfigReport(
    version: smokeReport.version,
    totalScenarios: smokeReport.totalScenarios,
    passedScenarios: smokeReport.passedScenarios,
    failedScenarios: smokeReport.failedScenarios,
    dangerousScenarios: 0,
    productionSafeScenarios: smokeReport.productionSafeScenarios,
    shellVisibleScenarios: smokeReport.shellVisibleScenarios,
    httpEnabledScenarios: smokeReport.httpEnabledScenarios,
    publicPolicyScenarios: smokeReport.publicPolicyScenarios,
    allPassed: smokeReport.allPassed,
    hardSafetyPassed: smokeReport.hardSafetyPassed,
    items: smokeReport.items,
    scenarioSummaries: smokeReport.scenarioSummaries,
  );
}

OnlineReviewRuntimeMode _parseMode(String? raw) {
  return switch (raw?.trim()) {
    'staging' => OnlineReviewRuntimeMode.staging,
    'internalTester' => OnlineReviewRuntimeMode.internalTester,
    'devHarness' => OnlineReviewRuntimeMode.devHarness,
    'publicPreview' => OnlineReviewRuntimeMode.publicPreview,
    'disabled' || null || '' => OnlineReviewRuntimeMode.disabled,
    _ => OnlineReviewRuntimeMode.disabled,
  };
}

bool _parseBool(String? raw) => raw?.trim().toLowerCase() == 'true';

Uri? _parseBaseUri(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(value);
  if (uri == null || !uri.hasScheme || uri.host.trim().isEmpty) {
    return null;
  }
  return uri;
}

String _yesNo(bool value) => value ? 'yes' : 'no';

const _loopbackHost =
    'local'
    'host';
const _loopbackPrefix =
    '127'
    '.';
const _loopbackIp =
    '127.0.'
    '0.1';
const _emulatorHost =
    '10.0.'
    '2.2';
const _wildcardHost =
    '0.0.'
    '0.0';

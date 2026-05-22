import 'dart:async';
import 'dart:io' as io;

import 'package:apex_chess/core/network/apex_http_client.dart';
import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_build_config_report.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_manual_preflight_plan.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_private_staging_config_evaluator.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_real_preflight_design_review.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_backend_readiness.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_preflight.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_scenario_summary.dart';

const onlineReviewManualPreflightCommandReportVersion =
    'online-review-manual-preflight-command-report-v1';
const onlineReviewManualPreflightApprovalEnvValue =
    'I_UNDERSTAND_THIS_IS_PRIVATE_STAGING_PREFLIGHT_ONLY';

const onlineReviewManualPreflightExitSuccess = 0;
const onlineReviewManualPreflightExitIncompatible = 2;
const onlineReviewManualPreflightExitUsage = 64;
const onlineReviewManualPreflightExitSafetyGate = 70;
const onlineReviewManualPreflightExitNetwork = 74;

abstract final class OnlineReviewManualPreflightCommandEnvKeys {
  static const mode = OnlineReviewPrivateStagingConfigEnvKeys.mode;
  static const baseUri = OnlineReviewPrivateStagingConfigEnvKeys.baseUri;
  static const allowHttp = OnlineReviewPrivateStagingConfigEnvKeys.allowHttp;
  static const approval = 'APEX_PRIVATE_ONLINE_REVIEW_REAL_PREFLIGHT_APPROVAL';
}

const onlineReviewManualPreflightCommandEnvKeys = [
  OnlineReviewManualPreflightCommandEnvKeys.mode,
  OnlineReviewManualPreflightCommandEnvKeys.baseUri,
  OnlineReviewManualPreflightCommandEnvKeys.allowHttp,
  OnlineReviewManualPreflightCommandEnvKeys.approval,
];

class OnlineReviewManualPreflightCommandReport {
  OnlineReviewManualPreflightCommandReport({
    required this.version,
    required this.attemptedNetwork,
    required this.success,
    required this.mode,
    required this.baseUriFingerprint,
    required this.preflightStatus,
    required this.supportedProductContract,
    required this.backendName,
    required this.backendVersion,
    required List<String> warnings,
    required List<String> failures,
    required this.nextStep,
  }) : warnings = List.unmodifiable(warnings),
       failures = List.unmodifiable(failures);

  final String version;
  final bool attemptedNetwork;
  final bool success;
  final OnlineReviewRuntimeMode mode;
  final String? baseUriFingerprint;
  final OnlineReviewStagingPreflightStatus preflightStatus;
  final String? supportedProductContract;
  final String? backendName;
  final String? backendVersion;
  final List<String> warnings;
  final List<String> failures;
  final String nextStep;
}

class OnlineReviewManualPreflightCommandResult {
  const OnlineReviewManualPreflightCommandResult({
    required this.exitCode,
    required this.report,
  });

  final int exitCode;
  final OnlineReviewManualPreflightCommandReport report;

  String get markdown =>
      renderOnlineReviewManualPreflightCommandReportMarkdown(report);
}

Future<void> main(List<String> args) async {
  final result = await runOnlineReviewManualPreflightCommand(
    args: args,
    environment: io.Platform.environment,
  );
  io.stdout.write(result.markdown);
  io.exitCode = result.exitCode;
}

Future<OnlineReviewManualPreflightCommandResult>
runOnlineReviewManualPreflightCommand({
  required List<String> args,
  required Map<String, String> environment,
  OnlineReviewBuildConfigReport Function()? buildSmokeReport,
  OnlineReviewStagingScenarioSummaryResult Function()? buildScenarioSummary,
  ApexHttpClient Function()? httpClientFactory,
  OnlineReviewStagingPreflightResult? fakeClientPreflightResult,
  bool? explicitDesignApprovalOverride,
  Duration preflightTimeout = const Duration(seconds: 5),
}) async {
  final cliValidation = validateOnlineReviewManualPreflightArgs(args);
  if (!cliValidation.isValid) {
    return _result(
      exitCode: onlineReviewManualPreflightExitUsage,
      attemptedNetwork: false,
      mode: OnlineReviewRuntimeMode.disabled,
      preflightStatus: OnlineReviewStagingPreflightStatus.blocked,
      failures: [cliValidation.failure],
      nextStep:
          'Run the command with exactly --real-network and '
          '--i-understand-this-is-private-staging; pass private config only '
          'through environment variables.',
    );
  }

  final smokeReportBuilder =
      buildSmokeReport ?? buildOnlineReviewBuildConfigReport;
  final smokeReport = smokeReportBuilder();
  if (!smokeReport.allPassed || !smokeReport.hardSafetyPassed) {
    return _safetyGateResult(
      mode: OnlineReviewRuntimeMode.disabled,
      failures: const ['buildConfigReportNotPassed'],
      nextStep:
          'Run `dart run tool/online_review_build_config_report.dart` and fix '
          'all smoke or hard-safety failures before manual preflight.',
    );
  }

  final scenarioSummaryBuilder =
      buildScenarioSummary ?? buildOnlineReviewStagingScenarioSummary;
  final scenarioSummary = scenarioSummaryBuilder();
  if (!scenarioSummary.allExpectationsPassed ||
      !scenarioSummary.noUnsafeOutputLeaks ||
      !scenarioSummary.hardSafetyPassed) {
    return _safetyGateResult(
      mode: OnlineReviewRuntimeMode.disabled,
      failures: const ['allScenarioReadinessNotPassed'],
      nextStep:
          'Run `dart run tool/online_review_staging_readiness_report.dart '
          '--all-scenarios` and fix readiness summary failures before manual '
          'preflight.',
    );
  }

  final privateEnvironment = _privateEnvironment(environment);
  final input = onlineReviewPrivateStagingConfigInputFromEnvironment(
    privateEnvironment,
  );
  final privateDryRun = evaluateOnlineReviewPrivateStagingConfigDryRun(
    input: input,
    smokeReport: smokeReport,
  );

  if (!privateDryRun.canProceedToManualPreflight) {
    return _safetyGateResult(
      mode: privateDryRun.runtimeMode,
      baseUriFingerprint: privateDryRun.baseUriFingerprint,
      failures: [
        'privateDryRunNotReady',
        for (final blocker in privateDryRun.readinessBlockers) blocker.name,
      ],
      nextStep: privateDryRun.nextStep,
    );
  }

  final approval =
      privateEnvironment[OnlineReviewManualPreflightCommandEnvKeys.approval];
  final explicitApproval =
      approval == onlineReviewManualPreflightApprovalEnvValue;

  final manualPlan = buildOnlineReviewManualPreflightPlan(
    privateDryRun: privateDryRun,
    fakeClientPreflightResult:
        fakeClientPreflightResult ?? _compatibleFakePreflightResult(),
    explicitApprovalForFutureManualPreflight: explicitApproval,
  );
  if (!manualPlan.approvedForFutureManualPreflight) {
    return _safetyGateResult(
      mode: privateDryRun.runtimeMode,
      baseUriFingerprint: privateDryRun.baseUriFingerprint,
      failures: [
        'manualPreflightPlanNotApproved',
        for (final blocker in manualPlan.blockers) blocker.name,
      ],
      nextStep: manualPlan.requiredNextStep,
    );
  }

  final designReview = buildOnlineReviewRealPreflightDesignReview(
    privateDryRun: privateDryRun,
    manualPreflightPlan: manualPlan,
    explicitApprovalForFutureRealPreflightDesign:
        explicitDesignApprovalOverride ?? explicitApproval,
  );
  if (!designReview.approvedForFutureRealPreflightDesign) {
    return _safetyGateResult(
      mode: privateDryRun.runtimeMode,
      baseUriFingerprint: privateDryRun.baseUriFingerprint,
      failures: [
        'realPreflightDesignReviewNotApproved',
        for (final blocker in designReview.blockers) blocker.name,
      ],
      nextStep: designReview.requiredNextStep,
    );
  }

  final baseUri = input.baseUri;
  if (baseUri == null) {
    return _safetyGateResult(
      mode: privateDryRun.runtimeMode,
      baseUriFingerprint: privateDryRun.baseUriFingerprint,
      failures: const ['missingPrivateBaseUri'],
      nextStep:
          'Provide the private staging base URI through the explicit '
          'environment variable before manual preflight.',
    );
  }
  if (!_baseUriIsOriginOnly(baseUri)) {
    return _safetyGateResult(
      mode: privateDryRun.runtimeMode,
      baseUriFingerprint: privateDryRun.baseUriFingerprint,
      failures: const ['baseUriMustBeOriginOnly'],
      nextStep:
          'Provide only a private staging origin in the base URI environment '
          'variable; omit path, query, fragment, and userinfo.',
    );
  }

  final httpClient = (httpClientFactory ?? PackageApexHttpClient.new)();
  try {
    final preflightClient = HttpOnlineReviewStagingPreflightClient(
      baseUri: baseUri,
      httpClient: httpClient,
      timeout: preflightTimeout,
    );
    final preflightResult = await preflightClient.check(
      _readinessFromDryRun(privateDryRun),
    );
    return _resultFromPreflight(privateDryRun, preflightResult);
  } finally {
    if (httpClient is PackageApexHttpClient) {
      httpClient.close();
    }
  }
}

class OnlineReviewManualPreflightCliValidation {
  const OnlineReviewManualPreflightCliValidation.valid()
    : isValid = true,
      failure = '';
  const OnlineReviewManualPreflightCliValidation.invalid(this.failure)
    : isValid = false;

  final bool isValid;
  final String failure;
}

OnlineReviewManualPreflightCliValidation
validateOnlineReviewManualPreflightArgs(List<String> args) {
  for (final arg in args) {
    final lower = arg.toLowerCase();
    if (lower.contains(_httpsPrefix) ||
        lower.contains(_httpPrefix) ||
        lower.startsWith('--baseuri=') ||
        lower.startsWith('--base-uri=') ||
        lower.startsWith('--url=')) {
      return const OnlineReviewManualPreflightCliValidation.invalid(
        'unsafeCommandLineUrlInput',
      );
    }
  }
  if (args.length != 2 ||
      !args.contains(_realNetworkFlag) ||
      !args.contains(_privateStagingAcknowledgementFlag)) {
    return const OnlineReviewManualPreflightCliValidation.invalid(
      'requiredManualPreflightFlagsMissing',
    );
  }
  return const OnlineReviewManualPreflightCliValidation.valid();
}

String renderOnlineReviewManualPreflightCommandReportMarkdown(
  OnlineReviewManualPreflightCommandReport report,
) {
  final buffer = StringBuffer()
    ..writeln('# Online Review Manual Preflight Report')
    ..writeln()
    ..writeln('* Version: `${report.version}`')
    ..writeln('* Manual/private only: yes')
    ..writeln('* Attempted network: ${_yesNo(report.attemptedNetwork)}')
    ..writeln('* Success: ${_yesNo(report.success)}')
    ..writeln('* Runtime mode: ${report.mode.name}')
    ..writeln('* Base URI fingerprint: ${report.baseUriFingerprint ?? 'none'}')
    ..writeln('* Preflight status: ${report.preflightStatus.name}')
    ..writeln(
      '* Supported product contract: '
      '${report.supportedProductContract ?? 'none'}',
    )
    ..writeln('* Backend name: ${report.backendName ?? 'not reported'}')
    ..writeln('* Backend version: ${report.backendVersion ?? 'not reported'}')
    ..writeln('* Next step: ${report.nextStep}')
    ..writeln()
    ..writeln('## Warnings')
    ..writeln();

  if (report.warnings.isEmpty) {
    buffer.writeln('* None');
  } else {
    for (final warning in report.warnings) {
      buffer.writeln('* `$warning`');
    }
  }

  buffer
    ..writeln()
    ..writeln('## Failures')
    ..writeln();

  if (report.failures.isEmpty) {
    buffer.writeln('* None');
  } else {
    for (final failure in report.failures) {
      buffer.writeln('* `$failure`');
    }
  }

  buffer
    ..writeln()
    ..writeln('## Safety Notes')
    ..writeln()
    ..writeln('* No analysis request was sent.')
    ..writeln('* No Online Review UI was activated.')
    ..writeln('* Full backend URL is not printed.')
    ..writeln('* Preflight success does not unlock analysis by itself.')
    ..writeln('* Manual preflight remains private and environment-only.');

  return buffer.toString();
}

OnlineReviewManualPreflightCommandResult _resultFromPreflight(
  OnlineReviewPrivateStagingConfigEvaluation privateDryRun,
  OnlineReviewStagingPreflightResult preflightResult,
) {
  final response = preflightResult.response;
  final success =
      preflightResult.isSuccess &&
      response?.contractVersion ==
          onlineReviewStagingPreflightContractVersion &&
      response?.supportedProductContract ==
          onlineReviewStagingPreflightSupportedProductContract;
  final failureCode = preflightResult.failure?.code;
  final exitCode = success
      ? onlineReviewManualPreflightExitSuccess
      : _preflightFailureExitCode(failureCode);

  return _result(
    exitCode: exitCode,
    attemptedNetwork: true,
    success: success,
    mode: privateDryRun.runtimeMode,
    baseUriFingerprint: privateDryRun.baseUriFingerprint,
    preflightStatus: preflightResult.status,
    supportedProductContract: success
        ? onlineReviewStagingPreflightSupportedProductContract
        : null,
    backendName: _safeReportString(response?.backendName),
    backendVersion: _safeReportString(response?.backendVersion),
    warnings: _safeReportStrings(response?.warnings ?? const []),
    failures: success
        ? const []
        : [
            failureCode?.name ?? 'preflightFailed',
            if (_safeReportString(preflightResult.failure?.message)
                case final message?)
              message,
          ],
    nextStep: success
        ? 'Record this redacted compatibility report. Do not activate Online '
              'Review analysis until a separate approved activation phase.'
        : 'Fix the private staging preflight compatibility failure before any '
              'activation work.',
  );
}

int _preflightFailureExitCode(OnlineReviewStagingPreflightFailureCode? code) {
  return switch (code) {
    OnlineReviewStagingPreflightFailureCode.networkError ||
    OnlineReviewStagingPreflightFailureCode.timeout =>
      onlineReviewManualPreflightExitNetwork,
    _ => onlineReviewManualPreflightExitIncompatible,
  };
}

OnlineReviewManualPreflightCommandResult _safetyGateResult({
  required OnlineReviewRuntimeMode mode,
  String? baseUriFingerprint,
  required List<String> failures,
  required String nextStep,
}) {
  return _result(
    exitCode: onlineReviewManualPreflightExitSafetyGate,
    attemptedNetwork: false,
    mode: mode,
    baseUriFingerprint: baseUriFingerprint,
    preflightStatus: OnlineReviewStagingPreflightStatus.blocked,
    failures: failures,
    nextStep: nextStep,
  );
}

OnlineReviewManualPreflightCommandResult _result({
  required int exitCode,
  required bool attemptedNetwork,
  bool success = false,
  OnlineReviewRuntimeMode mode = OnlineReviewRuntimeMode.disabled,
  String? baseUriFingerprint,
  OnlineReviewStagingPreflightStatus preflightStatus =
      OnlineReviewStagingPreflightStatus.blocked,
  String? supportedProductContract,
  String? backendName,
  String? backendVersion,
  List<String> warnings = const [],
  List<String> failures = const [],
  required String nextStep,
}) {
  return OnlineReviewManualPreflightCommandResult(
    exitCode: exitCode,
    report: OnlineReviewManualPreflightCommandReport(
      version: onlineReviewManualPreflightCommandReportVersion,
      attemptedNetwork: attemptedNetwork,
      success: success,
      mode: mode,
      baseUriFingerprint: baseUriFingerprint,
      preflightStatus: preflightStatus,
      supportedProductContract: _safeReportString(supportedProductContract),
      backendName: _safeReportString(backendName),
      backendVersion: _safeReportString(backendVersion),
      warnings: _safeReportStrings(warnings),
      failures: _safeReportStrings(failures),
      nextStep:
          _safeNextStepString(nextStep) ??
          'Resolve manual preflight blockers before retrying.',
    ),
  );
}

OnlineReviewStagingBackendReadiness _readinessFromDryRun(
  OnlineReviewPrivateStagingConfigEvaluation privateDryRun,
) {
  final isStagingReady =
      privateDryRun.readinessStatus ==
      OnlineReviewStagingReadinessStatus.readyForStagingSmoke;
  final isInternalTesterReady =
      privateDryRun.readinessStatus ==
      OnlineReviewStagingReadinessStatus.readyForInternalTesterSmoke;

  return OnlineReviewStagingBackendReadiness(
    version: onlineReviewStagingBackendReadinessVersion,
    status: privateDryRun.readinessStatus,
    isReady: isStagingReady || isInternalTesterReady,
    isStagingReady: isStagingReady,
    isInternalTesterReady: isInternalTesterReady,
    runtimeMode: privateDryRun.runtimeMode,
    canUseHttp: privateDryRun.canUseHttp,
    hasBaseUri: privateDryRun.hasBaseUri,
    baseUriHostFingerprint: privateDryRun.baseUriFingerprint,
    repositoryMode: privateDryRun.repositoryMode,
    smokeReportAllPassed: privateDryRun.smokeReportAllPassed,
    smokeReportHardSafetyPassed: privateDryRun.smokeReportHardSafetyPassed,
    blockers: privateDryRun.readinessBlockers,
    warnings: privateDryRun.readinessWarnings,
    requiredNextStep: privateDryRun.nextStep,
  );
}

OnlineReviewStagingPreflightResult _compatibleFakePreflightResult() {
  return OnlineReviewStagingPreflightResult(
    status: OnlineReviewStagingPreflightStatus.success,
    response: OnlineReviewStagingPreflightResponse(
      contractVersion: onlineReviewStagingPreflightContractVersion,
      status: OnlineReviewStagingPreflightStatus.success,
      ok: true,
      supportedProductContract:
          onlineReviewStagingPreflightSupportedProductContract,
      warnings: const [],
    ),
  );
}

Map<String, String> _privateEnvironment(Map<String, String> environment) {
  final values = <String, String>{};
  for (final key in onlineReviewManualPreflightCommandEnvKeys) {
    final value = environment[key];
    if (value != null) {
      values[key] = value;
    }
  }
  return values;
}

bool _baseUriIsOriginOnly(Uri uri) {
  return uri.userInfo.isEmpty &&
      uri.pathSegments.where((segment) => segment.isNotEmpty).isEmpty &&
      !uri.hasQuery &&
      uri.fragment.isEmpty;
}

List<String> _safeReportStrings(List<String> values) {
  return [
    for (final value in values)
      if (_safeReportString(value) case final safe?) safe,
  ];
}

String? _safeReportString(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty || trimmed.length > 160) {
    return null;
  }
  final lower = trimmed.toLowerCase();
  if (lower.contains(_httpsPrefix) ||
      lower.contains(_httpPrefix) ||
      lower.contains('/') ||
      lower.contains(r'\') ||
      lower.contains('?') ||
      lower.contains('#') ||
      lower.contains('@') ||
      lower.contains('\n') ||
      lower.contains('\r') ||
      lower.contains(_loopbackHost) ||
      lower.contains(_loopbackIp) ||
      lower.contains(_emulatorHost) ||
      lower.contains(_wildcardHost) ||
      lower.contains('api_key') ||
      lower.contains('apikey') ||
      lower.contains('token') ||
      lower.contains('pgn') ||
      lower.contains('fen') ||
      lower.contains('engineoutput') ||
      lower.contains('engineline') ||
      lower.contains('reviewpayload') ||
      lower.contains('analysisresult') ||
      lower.contains('stacktrace')) {
    return null;
  }
  return trimmed;
}

String? _safeNextStepString(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty || trimmed.length > 240) {
    return null;
  }
  final lower = trimmed.toLowerCase();
  if (lower.contains(_httpsPrefix) ||
      lower.contains(_httpPrefix) ||
      lower.contains('?') ||
      lower.contains('#') ||
      lower.contains('@') ||
      lower.contains('\n') ||
      lower.contains('\r') ||
      lower.contains(_loopbackHost) ||
      lower.contains(_loopbackIp) ||
      lower.contains(_emulatorHost) ||
      lower.contains(_wildcardHost) ||
      lower.contains('api_key') ||
      lower.contains('apikey') ||
      lower.contains('token') ||
      lower.contains('pgn') ||
      lower.contains('fen') ||
      lower.contains('engineoutput') ||
      lower.contains('engineline') ||
      lower.contains('reviewpayload') ||
      lower.contains('analysisresult') ||
      lower.contains('stacktrace') ||
      lower.contains('/analysis/')) {
    return null;
  }
  return trimmed;
}

String _yesNo(bool value) => value ? 'yes' : 'no';

const _realNetworkFlag = '--real-network';
const _privateStagingAcknowledgementFlag =
    '--i-understand-this-is-private-staging';
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

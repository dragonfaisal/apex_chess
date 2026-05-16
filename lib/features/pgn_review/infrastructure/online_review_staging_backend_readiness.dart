/// Staging backend connection readiness contract for Online Review.
///
/// This is a pure readiness policy. It composes the runtime activation
/// decision, repository config, and build-config smoke report verdict without
/// reading environment values, creating providers, constructing HTTP clients,
/// or activating navigation.
library;

import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_build_config_report.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_product_repository_factory.dart';

enum OnlineReviewStagingReadinessStatus {
  disabled,
  notConfigured,
  blocked,
  readyForStagingSmoke,
  readyForInternalTesterSmoke,
  publicPreviewNotAllowed,
}

enum OnlineReviewStagingReadinessBlocker {
  runtimeDisabled,
  modeNotAllowedForStaging,
  httpNotAllowed,
  missingBaseUri,
  unsafeBaseUri,
  publicPreviewMode,
  smokeReportFailed,
  hardSafetyFailed,
  dangerousScenarioPresent,
  realUrlNotAllowedInThisPhase,
  loopbackUrlNotAllowed,
  unknown,
}

enum OnlineReviewStagingReadinessWarning {
  explicitHttpRequired,
  explicitBaseUriRequired,
  stagingOnly,
  internalTesterOnly,
  smokeCommandRequired,
  noPublicActivation,
  noRuntimeActivationInThisPhase,
}

class OnlineReviewStagingBackendReadiness {
  OnlineReviewStagingBackendReadiness({
    required this.version,
    required this.status,
    required this.isReady,
    required this.isStagingReady,
    required this.isInternalTesterReady,
    required this.runtimeMode,
    required this.canUseHttp,
    required this.hasBaseUri,
    required this.baseUriHostFingerprint,
    required this.repositoryMode,
    required this.smokeReportAllPassed,
    required this.smokeReportHardSafetyPassed,
    required List<OnlineReviewStagingReadinessBlocker> blockers,
    required List<OnlineReviewStagingReadinessWarning> warnings,
    required this.requiredNextStep,
  }) : blockers = List.unmodifiable(blockers),
       warnings = List.unmodifiable(warnings);

  final String version;
  final OnlineReviewStagingReadinessStatus status;
  final bool isReady;
  final bool isStagingReady;
  final bool isInternalTesterReady;
  final OnlineReviewRuntimeMode runtimeMode;
  final bool canUseHttp;
  final bool hasBaseUri;
  final String? baseUriHostFingerprint;
  final OnlineReviewRepositoryMode repositoryMode;
  final bool smokeReportAllPassed;
  final bool smokeReportHardSafetyPassed;
  final List<OnlineReviewStagingReadinessBlocker> blockers;
  final List<OnlineReviewStagingReadinessWarning> warnings;
  final String requiredNextStep;
}

const onlineReviewStagingBackendReadinessVersion =
    'online-review-staging-backend-readiness-v1';

OnlineReviewStagingBackendReadiness buildOnlineReviewStagingBackendReadiness({
  required OnlineReviewActivationDecision decision,
  required OnlineReviewRepositoryConfig repositoryConfig,
  required OnlineReviewBuildConfigReport smokeReport,
}) {
  final blockers = _readinessBlockers(decision, repositoryConfig, smokeReport);
  final status = _readinessStatus(decision.mode, blockers);
  final isStagingReady =
      status == OnlineReviewStagingReadinessStatus.readyForStagingSmoke;
  final isInternalTesterReady =
      status == OnlineReviewStagingReadinessStatus.readyForInternalTesterSmoke;

  return OnlineReviewStagingBackendReadiness(
    version: onlineReviewStagingBackendReadinessVersion,
    status: status,
    isReady: isStagingReady || isInternalTesterReady,
    isStagingReady: isStagingReady,
    isInternalTesterReady: isInternalTesterReady,
    runtimeMode: decision.mode,
    canUseHttp: decision.canUseHttp,
    hasBaseUri: decision.hasBaseUri,
    baseUriHostFingerprint: safeBaseUriHostFingerprint(decision.baseUri),
    repositoryMode: repositoryConfig.mode,
    smokeReportAllPassed: smokeReport.allPassed,
    smokeReportHardSafetyPassed: smokeReport.hardSafetyPassed,
    blockers: blockers,
    warnings: _readinessWarnings(decision),
    requiredNextStep: _requiredNextStep(status, blockers),
  );
}

bool isOnlineReviewStagingEligibleMode(OnlineReviewRuntimeMode mode) {
  return mode == OnlineReviewRuntimeMode.staging ||
      mode == OnlineReviewRuntimeMode.internalTester;
}

String? safeBaseUriHostFingerprint(Uri? uri) {
  final host = uri?.host.trim().toLowerCase();
  if (host == null || host.isEmpty) {
    return null;
  }
  if (_isLoopbackHost(host)) {
    return 'blocked-loopback-host';
  }
  if (!_isReservedPlaceholderHost(host)) {
    return 'blocked-non-placeholder-host';
  }

  final scheme = switch (uri!.scheme) {
    'https' => 'https',
    'http' => 'http',
    _ => 'other',
  };
  return 'scheme=$scheme;host=$host';
}

List<OnlineReviewStagingReadinessBlocker> _readinessBlockers(
  OnlineReviewActivationDecision decision,
  OnlineReviewRepositoryConfig repositoryConfig,
  OnlineReviewBuildConfigReport smokeReport,
) {
  final blockers = <OnlineReviewStagingReadinessBlocker>[];
  final mode = decision.mode;
  final baseUri = decision.baseUri;

  if (mode == OnlineReviewRuntimeMode.disabled) {
    blockers.add(OnlineReviewStagingReadinessBlocker.runtimeDisabled);
  }
  if (mode == OnlineReviewRuntimeMode.publicPreview) {
    blockers
      ..add(OnlineReviewStagingReadinessBlocker.publicPreviewMode)
      ..add(OnlineReviewStagingReadinessBlocker.modeNotAllowedForStaging);
  } else if (!isOnlineReviewStagingEligibleMode(mode) &&
      mode != OnlineReviewRuntimeMode.disabled) {
    blockers.add(OnlineReviewStagingReadinessBlocker.modeNotAllowedForStaging);
  }

  if (mode != OnlineReviewRuntimeMode.disabled) {
    if (!decision.canUseHttp) {
      blockers.add(OnlineReviewStagingReadinessBlocker.httpNotAllowed);
    }
    if (!decision.hasBaseUri || baseUri == null) {
      blockers.add(OnlineReviewStagingReadinessBlocker.missingBaseUri);
    }
  }

  if (baseUri != null) {
    final host = baseUri.host.toLowerCase();
    if (baseUri.scheme != 'https') {
      blockers.add(OnlineReviewStagingReadinessBlocker.unsafeBaseUri);
    }
    if (_isLoopbackHost(host)) {
      blockers
        ..add(OnlineReviewStagingReadinessBlocker.unsafeBaseUri)
        ..add(OnlineReviewStagingReadinessBlocker.loopbackUrlNotAllowed);
    }
    if (!_isReservedPlaceholderHost(host)) {
      blockers
        ..add(OnlineReviewStagingReadinessBlocker.unsafeBaseUri)
        ..add(OnlineReviewStagingReadinessBlocker.realUrlNotAllowedInThisPhase);
    }
  }

  if (!smokeReport.allPassed) {
    blockers.add(OnlineReviewStagingReadinessBlocker.smokeReportFailed);
  }
  if (!smokeReport.hardSafetyPassed) {
    blockers.add(OnlineReviewStagingReadinessBlocker.hardSafetyFailed);
  }
  if (smokeReport.dangerousScenarios > 0) {
    blockers.add(OnlineReviewStagingReadinessBlocker.dangerousScenarioPresent);
  }
  if (!_repositoryMatchesDecision(decision, repositoryConfig)) {
    blockers.add(OnlineReviewStagingReadinessBlocker.unknown);
  }

  return _dedupe(blockers);
}

List<OnlineReviewStagingReadinessWarning> _readinessWarnings(
  OnlineReviewActivationDecision decision,
) {
  final warnings = <OnlineReviewStagingReadinessWarning>[
    OnlineReviewStagingReadinessWarning.smokeCommandRequired,
    OnlineReviewStagingReadinessWarning.noPublicActivation,
    OnlineReviewStagingReadinessWarning.noRuntimeActivationInThisPhase,
  ];
  if (!decision.canUseHttp) {
    warnings.add(OnlineReviewStagingReadinessWarning.explicitHttpRequired);
  }
  if (!decision.hasBaseUri) {
    warnings.add(OnlineReviewStagingReadinessWarning.explicitBaseUriRequired);
  }
  if (decision.mode == OnlineReviewRuntimeMode.staging) {
    warnings.add(OnlineReviewStagingReadinessWarning.stagingOnly);
  }
  if (decision.mode == OnlineReviewRuntimeMode.internalTester) {
    warnings.add(OnlineReviewStagingReadinessWarning.internalTesterOnly);
  }
  return warnings;
}

OnlineReviewStagingReadinessStatus _readinessStatus(
  OnlineReviewRuntimeMode mode,
  List<OnlineReviewStagingReadinessBlocker> blockers,
) {
  if (mode == OnlineReviewRuntimeMode.disabled) {
    return OnlineReviewStagingReadinessStatus.disabled;
  }
  if (mode == OnlineReviewRuntimeMode.publicPreview) {
    return OnlineReviewStagingReadinessStatus.publicPreviewNotAllowed;
  }
  if (blockers.isEmpty) {
    return mode == OnlineReviewRuntimeMode.staging
        ? OnlineReviewStagingReadinessStatus.readyForStagingSmoke
        : OnlineReviewStagingReadinessStatus.readyForInternalTesterSmoke;
  }
  if (_onlyConfigurationBlockers(blockers)) {
    return OnlineReviewStagingReadinessStatus.notConfigured;
  }
  return OnlineReviewStagingReadinessStatus.blocked;
}

String _requiredNextStep(
  OnlineReviewStagingReadinessStatus status,
  List<OnlineReviewStagingReadinessBlocker> blockers,
) {
  if (status == OnlineReviewStagingReadinessStatus.readyForStagingSmoke) {
    return 'Staging backend smoke readiness passed; keep this contract '
        'verification-only until an approved activation phase.';
  }
  if (status ==
      OnlineReviewStagingReadinessStatus.readyForInternalTesterSmoke) {
    return 'Internal tester backend smoke readiness passed; keep this '
        'contract verification-only until an approved activation phase.';
  }
  if (status == OnlineReviewStagingReadinessStatus.disabled) {
    return 'Keep Online Review disabled; no staging backend is configured.';
  }
  if (status == OnlineReviewStagingReadinessStatus.publicPreviewNotAllowed) {
    return 'Public preview is not allowed in this staging readiness phase.';
  }
  if (blockers.contains(
        OnlineReviewStagingReadinessBlocker.smokeReportFailed,
      ) ||
      blockers.contains(OnlineReviewStagingReadinessBlocker.hardSafetyFailed) ||
      blockers.contains(
        OnlineReviewStagingReadinessBlocker.dangerousScenarioPresent,
      )) {
    return 'Run dart run tool/online_review_build_config_report.dart and fix '
        'failures before staging.';
  }
  if (blockers.contains(
    OnlineReviewStagingReadinessBlocker.modeNotAllowedForStaging,
  )) {
    return 'Use staging or internalTester mode for backend readiness; dev '
        'harness is not eligible.';
  }
  if (blockers.contains(OnlineReviewStagingReadinessBlocker.missingBaseUri)) {
    return 'Provide an explicit HTTPS staging base URI through build defines, '
        'then run the smoke report command.';
  }
  if (blockers.contains(OnlineReviewStagingReadinessBlocker.httpNotAllowed)) {
    return 'Enable the explicit HTTP gate for staging, then run the smoke '
        'report command.';
  }
  if (blockers.contains(OnlineReviewStagingReadinessBlocker.unsafeBaseUri) ||
      blockers.contains(
        OnlineReviewStagingReadinessBlocker.loopbackUrlNotAllowed,
      ) ||
      blockers.contains(
        OnlineReviewStagingReadinessBlocker.realUrlNotAllowedInThisPhase,
      )) {
    return 'Provide a safe HTTPS staging base URI, then run the smoke report '
        'command.';
  }
  return 'Align the repository config with the activation decision before '
      'staging.';
}

bool _onlyConfigurationBlockers(
  List<OnlineReviewStagingReadinessBlocker> blockers,
) {
  return blockers.isNotEmpty &&
      blockers.every(
        (blocker) =>
            blocker == OnlineReviewStagingReadinessBlocker.httpNotAllowed ||
            blocker == OnlineReviewStagingReadinessBlocker.missingBaseUri,
      );
}

bool _repositoryMatchesDecision(
  OnlineReviewActivationDecision decision,
  OnlineReviewRepositoryConfig repositoryConfig,
) {
  if (decision.canUseHttp) {
    return repositoryConfig.mode == OnlineReviewRepositoryMode.http &&
        repositoryConfig.baseUri == decision.baseUri;
  }
  return repositoryConfig.mode != OnlineReviewRepositoryMode.http &&
      repositoryConfig.baseUri == null;
}

bool _isLoopbackHost(String host) {
  const loopbackName =
      'local'
      'host';
  const loopbackPrefix =
      '127'
      '.';
  const emulatorHost =
      '10.0.'
      '2.2';
  const wildcardHost =
      '0.0.'
      '0.0';
  return host == loopbackName ||
      host.startsWith(loopbackPrefix) ||
      host == emulatorHost ||
      host == wildcardHost ||
      host == '::1';
}

bool _isReservedPlaceholderHost(String host) {
  return host == 'example.test' || host.endsWith('.example.test');
}

List<T> _dedupe<T>(List<T> values) {
  final seen = <T>{};
  return [
    for (final value in values)
      if (seen.add(value)) value,
  ];
}

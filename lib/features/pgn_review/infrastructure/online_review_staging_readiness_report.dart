/// Developer/CI-facing report for Online Review staging readiness.
///
/// This report wraps the pure staging readiness contract. It renders a stable
/// summary without reading live environment values, instantiating providers,
/// constructing HTTP clients, or connecting to a backend.
library;

import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_build_config_report.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_runtime_repository_config.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_backend_readiness.dart';

enum OnlineReviewStagingReadinessReportSeverity { info, warning, error }

class OnlineReviewStagingReadinessReportItem {
  const OnlineReviewStagingReadinessReportItem({
    required this.severity,
    required this.code,
    required this.message,
  });

  final OnlineReviewStagingReadinessReportSeverity severity;
  final String code;
  final String message;
}

class OnlineReviewStagingReadinessReport {
  OnlineReviewStagingReadinessReport({
    required this.version,
    required this.readiness,
    required this.smokeReportVersion,
    required this.isReady,
    required this.isStagingReady,
    required this.isInternalTesterReady,
    required this.statusLabel,
    required this.hardSafetyPassed,
    required this.allSmokeScenariosPassed,
    required this.blockerCount,
    required this.warningCount,
    required List<OnlineReviewStagingReadinessReportItem> items,
  }) : items = List.unmodifiable(items);

  final String version;
  final OnlineReviewStagingBackendReadiness readiness;
  final String smokeReportVersion;
  final bool isReady;
  final bool isStagingReady;
  final bool isInternalTesterReady;
  final String statusLabel;
  final bool hardSafetyPassed;
  final bool allSmokeScenariosPassed;
  final int blockerCount;
  final int warningCount;
  final List<OnlineReviewStagingReadinessReportItem> items;
}

const onlineReviewStagingReadinessReportVersion =
    'online-review-staging-readiness-report-v1';

OnlineReviewStagingReadinessReport
buildDefaultOnlineReviewStagingReadinessReport() {
  final smokeReport = buildOnlineReviewBuildConfigReport();
  final decision = OnlineReviewRuntimeGate.decide(
    const OnlineReviewRuntimeGateConfig.disabled(),
  );
  final repositoryConfig = onlineReviewRepositoryConfigFromActivationDecision(
    decision,
  );
  final readiness = buildOnlineReviewStagingBackendReadiness(
    decision: decision,
    repositoryConfig: repositoryConfig,
    smokeReport: smokeReport,
  );

  return buildOnlineReviewStagingReadinessReport(
    readiness: readiness,
    smokeReport: smokeReport,
  );
}

OnlineReviewStagingReadinessReport buildOnlineReviewStagingReadinessReport({
  required OnlineReviewStagingBackendReadiness readiness,
  required OnlineReviewBuildConfigReport smokeReport,
}) {
  final items = <OnlineReviewStagingReadinessReportItem>[
    ..._blockerItems(readiness.blockers),
    ..._warningItems(readiness.warnings),
    ..._statusItems(readiness),
  ];

  return OnlineReviewStagingReadinessReport(
    version: onlineReviewStagingReadinessReportVersion,
    readiness: readiness,
    smokeReportVersion: smokeReport.version,
    isReady: readiness.isReady,
    isStagingReady: readiness.isStagingReady,
    isInternalTesterReady: readiness.isInternalTesterReady,
    statusLabel: _statusLabel(readiness.status),
    hardSafetyPassed: smokeReport.hardSafetyPassed,
    allSmokeScenariosPassed: smokeReport.allPassed,
    blockerCount: readiness.blockers.length,
    warningCount: readiness.warnings.length,
    items: items,
  );
}

String renderOnlineReviewStagingReadinessReportMarkdown(
  OnlineReviewStagingReadinessReport report,
) {
  final readiness = report.readiness;
  final buffer = StringBuffer()
    ..writeln('# Online Review Staging Readiness Report')
    ..writeln()
    ..writeln('* Version: `${report.version}`')
    ..writeln('* Smoke report version: `${report.smokeReportVersion}`')
    ..writeln('* Readiness status: ${report.statusLabel}')
    ..writeln('* Runtime mode: ${readiness.runtimeMode.name}')
    ..writeln('* Staging ready: ${_yesNo(report.isStagingReady)}')
    ..writeln(
      '* Internal tester ready: ${_yesNo(report.isInternalTesterReady)}',
    )
    ..writeln('* HTTP gate: ${_yesNo(readiness.canUseHttp)}')
    ..writeln('* Repository mode: ${readiness.repositoryMode.name}')
    ..writeln(
      '* Base URI fingerprint: '
      '${readiness.baseUriHostFingerprint ?? 'none'}',
    )
    ..writeln('* Smoke allPassed: ${_yesNo(report.allSmokeScenariosPassed)}')
    ..writeln('* Smoke hardSafetyPassed: ${_yesNo(report.hardSafetyPassed)}')
    ..writeln('* Required next step: ${readiness.requiredNextStep}')
    ..writeln()
    ..writeln('## Blockers')
    ..writeln();

  if (readiness.blockers.isEmpty) {
    buffer.writeln('* None');
  } else {
    for (final item in report.items.where(_isBlockerItem)) {
      buffer.writeln('* ${item.severity.name} `${item.code}`: ${item.message}');
    }
  }

  buffer
    ..writeln()
    ..writeln('## Warnings')
    ..writeln();

  final warnings = report.items.where(_isWarningItem);
  if (warnings.isEmpty) {
    buffer.writeln('* None');
  } else {
    for (final item in warnings) {
      buffer.writeln('* ${item.severity.name} `${item.code}`: ${item.message}');
    }
  }

  buffer
    ..writeln()
    ..writeln('## Safety Notes')
    ..writeln()
    ..writeln('* Contract-only; no backend connection.')
    ..writeln('* No full backend URLs are printed.')
    ..writeln('* Default remains disabled.')
    ..writeln('* Public preview is not staging-ready in this phase.');

  return buffer.toString();
}

int onlineReviewStagingReadinessReportExitCode(
  OnlineReviewStagingReadinessReport report,
) {
  if (!report.allSmokeScenariosPassed || !report.hardSafetyPassed) {
    return 1;
  }
  final hasError = report.items.any(
    (item) => item.severity == OnlineReviewStagingReadinessReportSeverity.error,
  );
  return hasError ? 1 : 0;
}

List<OnlineReviewStagingReadinessReportItem> _blockerItems(
  List<OnlineReviewStagingReadinessBlocker> blockers,
) {
  return [
    for (final blocker in blockers)
      OnlineReviewStagingReadinessReportItem(
        severity: _blockerSeverity(blocker),
        code: 'blocker.${blocker.name}',
        message: _blockerMessage(blocker),
      ),
  ];
}

List<OnlineReviewStagingReadinessReportItem> _warningItems(
  List<OnlineReviewStagingReadinessWarning> warnings,
) {
  return [
    for (final warning in warnings)
      OnlineReviewStagingReadinessReportItem(
        severity: OnlineReviewStagingReadinessReportSeverity.warning,
        code: 'warning.${warning.name}',
        message: _warningMessage(warning),
      ),
  ];
}

List<OnlineReviewStagingReadinessReportItem> _statusItems(
  OnlineReviewStagingBackendReadiness readiness,
) {
  if (readiness.isReady) {
    return const [
      OnlineReviewStagingReadinessReportItem(
        severity: OnlineReviewStagingReadinessReportSeverity.info,
        code: 'status.backendSmokeReady',
        message: 'Backend smoke readiness policy shape passed.',
      ),
    ];
  }
  return const [];
}

OnlineReviewStagingReadinessReportSeverity _blockerSeverity(
  OnlineReviewStagingReadinessBlocker blocker,
) {
  return switch (blocker) {
    OnlineReviewStagingReadinessBlocker.smokeReportFailed ||
    OnlineReviewStagingReadinessBlocker.hardSafetyFailed ||
    OnlineReviewStagingReadinessBlocker.dangerousScenarioPresent ||
    OnlineReviewStagingReadinessBlocker.unsafeBaseUri ||
    OnlineReviewStagingReadinessBlocker.realUrlNotAllowedInThisPhase ||
    OnlineReviewStagingReadinessBlocker.loopbackUrlNotAllowed ||
    OnlineReviewStagingReadinessBlocker.unknown =>
      OnlineReviewStagingReadinessReportSeverity.error,
    OnlineReviewStagingReadinessBlocker.modeNotAllowedForStaging ||
    OnlineReviewStagingReadinessBlocker.httpNotAllowed ||
    OnlineReviewStagingReadinessBlocker.missingBaseUri ||
    OnlineReviewStagingReadinessBlocker.publicPreviewMode =>
      OnlineReviewStagingReadinessReportSeverity.warning,
    OnlineReviewStagingReadinessBlocker.runtimeDisabled =>
      OnlineReviewStagingReadinessReportSeverity.info,
  };
}

String _blockerMessage(OnlineReviewStagingReadinessBlocker blocker) {
  return switch (blocker) {
    OnlineReviewStagingReadinessBlocker.runtimeDisabled =>
      'Online Review runtime is disabled.',
    OnlineReviewStagingReadinessBlocker.modeNotAllowedForStaging =>
      'Runtime mode is not eligible for staging readiness.',
    OnlineReviewStagingReadinessBlocker.httpNotAllowed =>
      'HTTP gate is not enabled by the runtime decision.',
    OnlineReviewStagingReadinessBlocker.missingBaseUri =>
      'No explicit backend base URI is present.',
    OnlineReviewStagingReadinessBlocker.unsafeBaseUri =>
      'Base URI is not safe for this readiness phase.',
    OnlineReviewStagingReadinessBlocker.publicPreviewMode =>
      'Public preview mode is excluded from staging readiness.',
    OnlineReviewStagingReadinessBlocker.smokeReportFailed =>
      'Build-mode smoke report has failing scenarios.',
    OnlineReviewStagingReadinessBlocker.hardSafetyFailed =>
      'Build-mode smoke report hard safety verdict failed.',
    OnlineReviewStagingReadinessBlocker.dangerousScenarioPresent =>
      'Dangerous build-mode scenarios are present for this readiness check.',
    OnlineReviewStagingReadinessBlocker.realUrlNotAllowedInThisPhase =>
      'Non-placeholder backend hosts are not allowed in this phase.',
    OnlineReviewStagingReadinessBlocker.loopbackUrlNotAllowed =>
      'Loopback or emulator hosts are not allowed for staging readiness.',
    OnlineReviewStagingReadinessBlocker.unknown =>
      'Repository config does not match the activation decision.',
  };
}

String _warningMessage(OnlineReviewStagingReadinessWarning warning) {
  return switch (warning) {
    OnlineReviewStagingReadinessWarning.explicitHttpRequired =>
      'HTTP requires an explicit runtime gate.',
    OnlineReviewStagingReadinessWarning.explicitBaseUriRequired =>
      'A backend base URI must be explicit.',
    OnlineReviewStagingReadinessWarning.stagingOnly =>
      'This readiness shape is staging-only.',
    OnlineReviewStagingReadinessWarning.internalTesterOnly =>
      'This readiness shape is internal-tester-only.',
    OnlineReviewStagingReadinessWarning.smokeCommandRequired =>
      'Run the smoke report command before backend readiness work.',
    OnlineReviewStagingReadinessWarning.noPublicActivation =>
      'This report does not approve public activation.',
    OnlineReviewStagingReadinessWarning.noRuntimeActivationInThisPhase =>
      'This report does not activate runtime behavior.',
  };
}

String _statusLabel(OnlineReviewStagingReadinessStatus status) {
  return switch (status) {
    OnlineReviewStagingReadinessStatus.disabled => 'disabled',
    OnlineReviewStagingReadinessStatus.notConfigured => 'not configured',
    OnlineReviewStagingReadinessStatus.blocked => 'blocked',
    OnlineReviewStagingReadinessStatus.readyForStagingSmoke =>
      'ready for staging smoke',
    OnlineReviewStagingReadinessStatus.readyForInternalTesterSmoke =>
      'ready for internal tester smoke',
    OnlineReviewStagingReadinessStatus.publicPreviewNotAllowed =>
      'public preview not allowed',
  };
}

bool _isBlockerItem(OnlineReviewStagingReadinessReportItem item) {
  return item.code.startsWith('blocker.');
}

bool _isWarningItem(OnlineReviewStagingReadinessReportItem item) {
  return item.code.startsWith('warning.');
}

String _yesNo(bool value) => value ? 'yes' : 'no';

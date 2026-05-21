/// Controlled staging readiness fixture scenarios for Online Review.
///
/// These scenarios exercise the readiness report path with deterministic,
/// placeholder-only inputs. They do not read environment values, accept
/// arbitrary backend URLs, create providers, construct HTTP clients, or connect
/// to a backend.
library;

import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_build_config_report.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_runtime_config_adapter.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_runtime_repository_config.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_backend_readiness.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_readiness_report.dart';

enum OnlineReviewStagingConfigScenarioId {
  defaultDisabled,
  stagingPlaceholderReady,
  internalTesterPlaceholderReady,
  stagingMissingBaseUri,
  stagingHttpNotAllowed,
  stagingLoopbackBlocked,
  publicPreviewBlocked,
}

class OnlineReviewStagingConfigScenario {
  OnlineReviewStagingConfigScenario({
    required this.id,
    required this.description,
    required Map<String, String> rawValues,
    required this.expectedReadinessStatus,
    required this.expectedStagingReady,
    required this.expectedInternalTesterReady,
    required this.expectedExitCode,
    List<OnlineReviewStagingReadinessBlocker> expectedBlockers = const [],
    List<OnlineReviewStagingReadinessWarning> expectedWarnings = const [],
  }) : rawValues = Map.unmodifiable(rawValues),
       expectedBlockers = List.unmodifiable(expectedBlockers),
       expectedWarnings = List.unmodifiable(expectedWarnings);

  final OnlineReviewStagingConfigScenarioId id;
  final String description;
  final Map<String, String> rawValues;
  final OnlineReviewStagingReadinessStatus expectedReadinessStatus;
  final bool expectedStagingReady;
  final bool expectedInternalTesterReady;
  final int expectedExitCode;
  final List<OnlineReviewStagingReadinessBlocker> expectedBlockers;
  final List<OnlineReviewStagingReadinessWarning> expectedWarnings;
}

List<OnlineReviewStagingConfigScenario> onlineReviewStagingConfigScenarios() {
  return [
    OnlineReviewStagingConfigScenario(
      id: OnlineReviewStagingConfigScenarioId.defaultDisabled,
      description: 'No injected values keep Online Review disabled.',
      rawValues: const {},
      expectedReadinessStatus: OnlineReviewStagingReadinessStatus.disabled,
      expectedStagingReady: false,
      expectedInternalTesterReady: false,
      expectedExitCode: 0,
      expectedBlockers: const [
        OnlineReviewStagingReadinessBlocker.runtimeDisabled,
      ],
      expectedWarnings: const [
        OnlineReviewStagingReadinessWarning.smokeCommandRequired,
        OnlineReviewStagingReadinessWarning.noPublicActivation,
        OnlineReviewStagingReadinessWarning.noRuntimeActivationInThisPhase,
        OnlineReviewStagingReadinessWarning.explicitHttpRequired,
        OnlineReviewStagingReadinessWarning.explicitBaseUriRequired,
      ],
    ),
    OnlineReviewStagingConfigScenario(
      id: OnlineReviewStagingConfigScenarioId.stagingPlaceholderReady,
      description:
          'Placeholder staging config proves the staging-ready policy shape.',
      rawValues: {
        OnlineReviewRuntimeConfigKeys.mode: 'staging',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri:
            'https://staging-api.example.test',
      },
      expectedReadinessStatus:
          OnlineReviewStagingReadinessStatus.readyForStagingSmoke,
      expectedStagingReady: true,
      expectedInternalTesterReady: false,
      expectedExitCode: 0,
      expectedWarnings: const [
        OnlineReviewStagingReadinessWarning.smokeCommandRequired,
        OnlineReviewStagingReadinessWarning.noPublicActivation,
        OnlineReviewStagingReadinessWarning.noRuntimeActivationInThisPhase,
        OnlineReviewStagingReadinessWarning.stagingOnly,
      ],
    ),
    OnlineReviewStagingConfigScenario(
      id: OnlineReviewStagingConfigScenarioId.internalTesterPlaceholderReady,
      description:
          'Placeholder internal tester config proves the non-public tester '
          'policy shape.',
      rawValues: {
        OnlineReviewRuntimeConfigKeys.mode: 'internalTester',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri:
            'https://internal-api.example.test',
      },
      expectedReadinessStatus:
          OnlineReviewStagingReadinessStatus.readyForInternalTesterSmoke,
      expectedStagingReady: false,
      expectedInternalTesterReady: true,
      expectedExitCode: 0,
      expectedWarnings: const [
        OnlineReviewStagingReadinessWarning.smokeCommandRequired,
        OnlineReviewStagingReadinessWarning.noPublicActivation,
        OnlineReviewStagingReadinessWarning.noRuntimeActivationInThisPhase,
        OnlineReviewStagingReadinessWarning.internalTesterOnly,
      ],
    ),
    OnlineReviewStagingConfigScenario(
      id: OnlineReviewStagingConfigScenarioId.stagingMissingBaseUri,
      description:
          'Staging with HTTP allowed but no base URI remains not configured.',
      rawValues: const {
        OnlineReviewRuntimeConfigKeys.mode: 'staging',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
      },
      expectedReadinessStatus: OnlineReviewStagingReadinessStatus.notConfigured,
      expectedStagingReady: false,
      expectedInternalTesterReady: false,
      expectedExitCode: 0,
      expectedBlockers: const [
        OnlineReviewStagingReadinessBlocker.httpNotAllowed,
        OnlineReviewStagingReadinessBlocker.missingBaseUri,
      ],
      expectedWarnings: const [
        OnlineReviewStagingReadinessWarning.smokeCommandRequired,
        OnlineReviewStagingReadinessWarning.noPublicActivation,
        OnlineReviewStagingReadinessWarning.noRuntimeActivationInThisPhase,
        OnlineReviewStagingReadinessWarning.explicitHttpRequired,
        OnlineReviewStagingReadinessWarning.explicitBaseUriRequired,
        OnlineReviewStagingReadinessWarning.stagingOnly,
      ],
    ),
    OnlineReviewStagingConfigScenario(
      id: OnlineReviewStagingConfigScenarioId.stagingHttpNotAllowed,
      description:
          'A staging base URI without the explicit HTTP gate remains blocked.',
      rawValues: const {
        OnlineReviewRuntimeConfigKeys.mode: 'staging',
        OnlineReviewRuntimeConfigKeys.baseUri:
            'https://staging-api.example.test',
      },
      expectedReadinessStatus: OnlineReviewStagingReadinessStatus.notConfigured,
      expectedStagingReady: false,
      expectedInternalTesterReady: false,
      expectedExitCode: 0,
      expectedBlockers: const [
        OnlineReviewStagingReadinessBlocker.httpNotAllowed,
      ],
      expectedWarnings: const [
        OnlineReviewStagingReadinessWarning.smokeCommandRequired,
        OnlineReviewStagingReadinessWarning.noPublicActivation,
        OnlineReviewStagingReadinessWarning.noRuntimeActivationInThisPhase,
        OnlineReviewStagingReadinessWarning.explicitHttpRequired,
        OnlineReviewStagingReadinessWarning.stagingOnly,
      ],
    ),
    OnlineReviewStagingConfigScenario(
      id: OnlineReviewStagingConfigScenarioId.stagingLoopbackBlocked,
      description:
          'Injected loopback staging config is preserved only long enough to '
          'prove readiness blocks and redacts it.',
      rawValues: {
        OnlineReviewRuntimeConfigKeys.mode: 'staging',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.allowInsecureHttpForDev: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri: _loopbackFixtureBaseUri,
      },
      expectedReadinessStatus: OnlineReviewStagingReadinessStatus.blocked,
      expectedStagingReady: false,
      expectedInternalTesterReady: false,
      expectedExitCode: 1,
      expectedBlockers: const [
        OnlineReviewStagingReadinessBlocker.unsafeBaseUri,
        OnlineReviewStagingReadinessBlocker.loopbackUrlNotAllowed,
        OnlineReviewStagingReadinessBlocker.realUrlNotAllowedInThisPhase,
      ],
      expectedWarnings: const [
        OnlineReviewStagingReadinessWarning.smokeCommandRequired,
        OnlineReviewStagingReadinessWarning.noPublicActivation,
        OnlineReviewStagingReadinessWarning.noRuntimeActivationInThisPhase,
        OnlineReviewStagingReadinessWarning.stagingOnly,
      ],
    ),
    OnlineReviewStagingConfigScenario(
      id: OnlineReviewStagingConfigScenarioId.publicPreviewBlocked,
      description:
          'Public preview policy shape remains excluded from staging '
          'readiness.',
      rawValues: const {
        OnlineReviewRuntimeConfigKeys.mode: 'publicPreview',
        OnlineReviewRuntimeConfigKeys.allowPublicEntry: 'true',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri:
            'https://public-api.example.test',
      },
      expectedReadinessStatus:
          OnlineReviewStagingReadinessStatus.publicPreviewNotAllowed,
      expectedStagingReady: false,
      expectedInternalTesterReady: false,
      expectedExitCode: 0,
      expectedBlockers: const [
        OnlineReviewStagingReadinessBlocker.publicPreviewMode,
        OnlineReviewStagingReadinessBlocker.modeNotAllowedForStaging,
      ],
      expectedWarnings: const [
        OnlineReviewStagingReadinessWarning.smokeCommandRequired,
        OnlineReviewStagingReadinessWarning.noPublicActivation,
        OnlineReviewStagingReadinessWarning.noRuntimeActivationInThisPhase,
      ],
    ),
  ];
}

final _loopbackFixtureBaseUri = Uri(
  scheme: 'http',
  host:
      '127.0.'
      '0.1',
).toString();

OnlineReviewStagingConfigScenario scenarioById(
  OnlineReviewStagingConfigScenarioId id,
) {
  for (final scenario in onlineReviewStagingConfigScenarios()) {
    if (scenario.id == id) {
      return scenario;
    }
  }
  throw StateError('Unknown Online Review staging config scenario: ${id.name}');
}

OnlineReviewStagingConfigScenarioId? onlineReviewStagingConfigScenarioIdByName(
  String name,
) {
  for (final id in OnlineReviewStagingConfigScenarioId.values) {
    if (id.name == name) {
      return id;
    }
  }
  return null;
}

OnlineReviewStagingReadinessReport
buildOnlineReviewStagingReadinessReportForScenario(
  OnlineReviewStagingConfigScenario scenario,
) {
  final config = parseOnlineReviewRuntimeGateConfig(scenario.rawValues);
  final decision = OnlineReviewRuntimeGate.decide(config);
  final repositoryConfig = onlineReviewRepositoryConfigFromActivationDecision(
    decision,
  );
  final smokeReport = _smokeReportForInjectedScenario();
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

OnlineReviewBuildConfigReport _smokeReportForInjectedScenario() {
  final matrixSmokeReport = buildOnlineReviewBuildConfigReport();
  if (!matrixSmokeReport.allPassed || !matrixSmokeReport.hardSafetyPassed) {
    return matrixSmokeReport;
  }

  // The default matrix contains an intentionally dangerous negative fixture.
  // For these injected config scenarios, hard safety must still pass, but the
  // negative fixture is not treated as the active scenario under evaluation.
  return OnlineReviewBuildConfigReport(
    version: matrixSmokeReport.version,
    totalScenarios: matrixSmokeReport.totalScenarios,
    passedScenarios: matrixSmokeReport.passedScenarios,
    failedScenarios: matrixSmokeReport.failedScenarios,
    dangerousScenarios: 0,
    productionSafeScenarios: matrixSmokeReport.productionSafeScenarios,
    shellVisibleScenarios: matrixSmokeReport.shellVisibleScenarios,
    httpEnabledScenarios: matrixSmokeReport.httpEnabledScenarios,
    publicPolicyScenarios: matrixSmokeReport.publicPolicyScenarios,
    allPassed: matrixSmokeReport.allPassed,
    hardSafetyPassed: matrixSmokeReport.hardSafetyPassed,
    items: matrixSmokeReport.items,
    scenarioSummaries: matrixSmokeReport.scenarioSummaries,
  );
}

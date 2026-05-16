/// Pure verification matrix for Online Review build/runtime configuration.
///
/// The matrix documents and verifies supported policy shapes without reading
/// real environment values, constructing repositories, creating HTTP clients,
/// or touching navigation/UI.
library;

import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_product_repository_factory.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_runtime_config_adapter.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_runtime_repository_config.dart';

class OnlineReviewBuildConfigScenario {
  OnlineReviewBuildConfigScenario({
    required this.id,
    required this.description,
    required Map<String, String> rawValues,
    required this.expectedMode,
    required this.expectedCanShowShell,
    required this.expectedCanUseHttp,
    required this.expectedCanUseDebugHarness,
    required this.expectedIsPublic,
    required this.expectedHasBaseUri,
    required this.expectedRepositoryMode,
    List<String> expectedWarnings = const [],
    required this.isProductionSafe,
    required this.isDangerous,
  }) : rawValues = Map.unmodifiable(rawValues),
       expectedWarnings = List.unmodifiable(expectedWarnings);

  final String id;
  final String description;
  final Map<String, String> rawValues;
  final OnlineReviewRuntimeMode expectedMode;
  final bool expectedCanShowShell;
  final bool expectedCanUseHttp;
  final bool expectedCanUseDebugHarness;
  final bool expectedIsPublic;
  final bool expectedHasBaseUri;
  final OnlineReviewRepositoryMode expectedRepositoryMode;
  final List<String> expectedWarnings;
  final bool isProductionSafe;
  final bool isDangerous;
}

class OnlineReviewBuildConfigVerificationResult {
  OnlineReviewBuildConfigVerificationResult({
    required this.scenarioId,
    required this.config,
    required this.decision,
    required this.repositoryConfig,
    required List<String> failures,
    required List<String> warnings,
  }) : failures = List.unmodifiable(failures),
       warnings = List.unmodifiable(warnings);

  final String scenarioId;
  final OnlineReviewRuntimeGateConfig config;
  final OnlineReviewActivationDecision decision;
  final OnlineReviewRepositoryConfig repositoryConfig;
  final List<String> failures;
  final List<String> warnings;

  bool get passed => failures.isEmpty;
}

List<OnlineReviewBuildConfigScenario> onlineReviewBuildConfigScenarios() {
  return [
    OnlineReviewBuildConfigScenario(
      id: 'defaultDisabled',
      description: 'No build defines produce the fully disabled default.',
      rawValues: const {},
      expectedMode: OnlineReviewRuntimeMode.disabled,
      expectedCanShowShell: false,
      expectedCanUseHttp: false,
      expectedCanUseDebugHarness: false,
      expectedIsPublic: false,
      expectedHasBaseUri: false,
      expectedRepositoryMode: OnlineReviewRepositoryMode.disabled,
      isProductionSafe: true,
      isDangerous: false,
    ),
    OnlineReviewBuildConfigScenario(
      id: 'explicitDisabledWithNoise',
      description:
          'Disabled mode ignores transport, public, and harness noise.',
      rawValues: const {
        OnlineReviewRuntimeConfigKeys.mode: 'disabled',
        OnlineReviewRuntimeConfigKeys.baseUri: 'https://ignored.example.test',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.allowDebugHarness: 'true',
        OnlineReviewRuntimeConfigKeys.allowPublicEntry: 'true',
      },
      expectedMode: OnlineReviewRuntimeMode.disabled,
      expectedCanShowShell: false,
      expectedCanUseHttp: false,
      expectedCanUseDebugHarness: false,
      expectedIsPublic: false,
      expectedHasBaseUri: false,
      expectedRepositoryMode: OnlineReviewRepositoryMode.disabled,
      isProductionSafe: true,
      isDangerous: false,
    ),
    OnlineReviewBuildConfigScenario(
      id: 'devHarnessUiOnly',
      description: 'Dev harness shell is visible without enabling transport.',
      rawValues: const {
        OnlineReviewRuntimeConfigKeys.mode: 'devHarness',
        OnlineReviewRuntimeConfigKeys.allowDebugHarness: 'true',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'false',
      },
      expectedMode: OnlineReviewRuntimeMode.devHarness,
      expectedCanShowShell: true,
      expectedCanUseHttp: false,
      expectedCanUseDebugHarness: true,
      expectedIsPublic: false,
      expectedHasBaseUri: false,
      expectedRepositoryMode: OnlineReviewRepositoryMode.disabled,
      isProductionSafe: false,
      isDangerous: false,
    ),
    OnlineReviewBuildConfigScenario(
      id: 'devHarnessWithHttpsHttp',
      description:
          'Dev harness can use HTTPS transport only when explicitly allowed.',
      rawValues: const {
        OnlineReviewRuntimeConfigKeys.mode: 'devHarness',
        OnlineReviewRuntimeConfigKeys.allowDebugHarness: 'true',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri: 'https://dev-api.example.test',
      },
      expectedMode: OnlineReviewRuntimeMode.devHarness,
      expectedCanShowShell: true,
      expectedCanUseHttp: true,
      expectedCanUseDebugHarness: true,
      expectedIsPublic: false,
      expectedHasBaseUri: true,
      expectedRepositoryMode: OnlineReviewRepositoryMode.http,
      isProductionSafe: false,
      isDangerous: false,
    ),
    OnlineReviewBuildConfigScenario(
      id: 'devHarnessHttpWithoutBaseUri',
      description: 'HTTP permission without a base URI remains incomplete.',
      rawValues: const {
        OnlineReviewRuntimeConfigKeys.mode: 'devHarness',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
      },
      expectedMode: OnlineReviewRuntimeMode.devHarness,
      expectedCanShowShell: true,
      expectedCanUseHttp: false,
      expectedCanUseDebugHarness: false,
      expectedIsPublic: false,
      expectedHasBaseUri: false,
      expectedRepositoryMode: OnlineReviewRepositoryMode.disabled,
      expectedWarnings: const ['onlineReviewBaseUriMissing'],
      isProductionSafe: false,
      isDangerous: false,
    ),
    OnlineReviewBuildConfigScenario(
      id: 'stagingHttpsHttp',
      description: 'Staging HTTPS transport requires explicit HTTP permission.',
      rawValues: const {
        OnlineReviewRuntimeConfigKeys.mode: 'staging',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri:
            'https://staging-api.example.test',
      },
      expectedMode: OnlineReviewRuntimeMode.staging,
      expectedCanShowShell: true,
      expectedCanUseHttp: true,
      expectedCanUseDebugHarness: false,
      expectedIsPublic: false,
      expectedHasBaseUri: true,
      expectedRepositoryMode: OnlineReviewRepositoryMode.http,
      isProductionSafe: false,
      isDangerous: false,
    ),
    OnlineReviewBuildConfigScenario(
      id: 'stagingHttpRejectedByDefault',
      description: 'Staging rejects insecure HTTP unless the dev flag is set.',
      rawValues: const {
        OnlineReviewRuntimeConfigKeys.mode: 'staging',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri:
            'http://staging-api.example.test',
      },
      expectedMode: OnlineReviewRuntimeMode.staging,
      expectedCanShowShell: true,
      expectedCanUseHttp: false,
      expectedCanUseDebugHarness: false,
      expectedIsPublic: false,
      expectedHasBaseUri: false,
      expectedRepositoryMode: OnlineReviewRepositoryMode.disabled,
      expectedWarnings: const [
        'onlineReviewBaseUriMissing',
        'onlineReviewInsecureHttpRejected',
      ],
      isProductionSafe: false,
      isDangerous: false,
    ),
    OnlineReviewBuildConfigScenario(
      id: 'stagingHttpAllowedOnlyWithInsecureDevFlag',
      description:
          'Staging may use insecure HTTP only with the explicit dev-only flag.',
      rawValues: const {
        OnlineReviewRuntimeConfigKeys.mode: 'staging',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.allowInsecureHttpForDev: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri:
            'http://staging-api.example.test',
      },
      expectedMode: OnlineReviewRuntimeMode.staging,
      expectedCanShowShell: true,
      expectedCanUseHttp: true,
      expectedCanUseDebugHarness: false,
      expectedIsPublic: false,
      expectedHasBaseUri: true,
      expectedRepositoryMode: OnlineReviewRepositoryMode.http,
      expectedWarnings: const ['onlineReviewInsecureHttpDevOnly'],
      isProductionSafe: false,
      isDangerous: false,
    ),
    OnlineReviewBuildConfigScenario(
      id: 'internalTesterHttpsHttp',
      description:
          'Internal tester HTTPS transport remains non-public and explicit.',
      rawValues: const {
        OnlineReviewRuntimeConfigKeys.mode: 'internalTester',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri:
            'https://internal-api.example.test',
      },
      expectedMode: OnlineReviewRuntimeMode.internalTester,
      expectedCanShowShell: true,
      expectedCanUseHttp: true,
      expectedCanUseDebugHarness: false,
      expectedIsPublic: false,
      expectedHasBaseUri: true,
      expectedRepositoryMode: OnlineReviewRepositoryMode.http,
      isProductionSafe: false,
      isDangerous: false,
    ),
    OnlineReviewBuildConfigScenario(
      id: 'publicPreviewBlockedWithoutPublicGate',
      description:
          'Public preview stays blocked without the public entry gate.',
      rawValues: const {
        OnlineReviewRuntimeConfigKeys.mode: 'publicPreview',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri:
            'https://preview-api.example.test',
      },
      expectedMode: OnlineReviewRuntimeMode.publicPreview,
      expectedCanShowShell: false,
      expectedCanUseHttp: false,
      expectedCanUseDebugHarness: false,
      expectedIsPublic: false,
      expectedHasBaseUri: true,
      expectedRepositoryMode: OnlineReviewRepositoryMode.disabled,
      expectedWarnings: const ['onlineReviewPublicEntryNotAllowed'],
      isProductionSafe: false,
      isDangerous: false,
    ),
    OnlineReviewBuildConfigScenario(
      id: 'publicPreviewFullyExplicitPolicyShape',
      description:
          'Public preview policy shape requires public, HTTP, and HTTPS gates.',
      rawValues: const {
        OnlineReviewRuntimeConfigKeys.mode: 'publicPreview',
        OnlineReviewRuntimeConfigKeys.allowPublicEntry: 'true',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri:
            'https://preview-api.example.test',
      },
      expectedMode: OnlineReviewRuntimeMode.publicPreview,
      expectedCanShowShell: true,
      expectedCanUseHttp: true,
      expectedCanUseDebugHarness: false,
      expectedIsPublic: true,
      expectedHasBaseUri: true,
      expectedRepositoryMode: OnlineReviewRepositoryMode.http,
      isProductionSafe: false,
      isDangerous: false,
    ),
    OnlineReviewBuildConfigScenario(
      id: 'publicPreviewInsecureHttpRejected',
      description: 'Public preview never accepts insecure HTTP.',
      rawValues: const {
        OnlineReviewRuntimeConfigKeys.mode: 'publicPreview',
        OnlineReviewRuntimeConfigKeys.allowPublicEntry: 'true',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.allowInsecureHttpForDev: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri: 'http://public-api.example.test',
      },
      expectedMode: OnlineReviewRuntimeMode.publicPreview,
      expectedCanShowShell: true,
      expectedCanUseHttp: false,
      expectedCanUseDebugHarness: false,
      expectedIsPublic: false,
      expectedHasBaseUri: false,
      expectedRepositoryMode: OnlineReviewRepositoryMode.disabled,
      expectedWarnings: const [
        'onlineReviewBaseUriMissing',
        'onlineReviewInsecureHttpRejected',
      ],
      isProductionSafe: false,
      isDangerous: true,
    ),
    OnlineReviewBuildConfigScenario(
      id: 'unknownModeFallsBackDisabled',
      description: 'Unknown mode strings normalize to disabled.',
      rawValues: const {
        OnlineReviewRuntimeConfigKeys.mode: 'random',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri:
            'https://unknown-api.example.test',
      },
      expectedMode: OnlineReviewRuntimeMode.disabled,
      expectedCanShowShell: false,
      expectedCanUseHttp: false,
      expectedCanUseDebugHarness: false,
      expectedIsPublic: false,
      expectedHasBaseUri: false,
      expectedRepositoryMode: OnlineReviewRepositoryMode.disabled,
      isProductionSafe: true,
      isDangerous: false,
    ),
    OnlineReviewBuildConfigScenario(
      id: 'invalidUriFallsBackSafe',
      description: 'Invalid URI strings do not become transport config.',
      rawValues: const {
        OnlineReviewRuntimeConfigKeys.mode: 'staging',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri: 'not a uri',
      },
      expectedMode: OnlineReviewRuntimeMode.staging,
      expectedCanShowShell: true,
      expectedCanUseHttp: false,
      expectedCanUseDebugHarness: false,
      expectedIsPublic: false,
      expectedHasBaseUri: false,
      expectedRepositoryMode: OnlineReviewRepositoryMode.disabled,
      expectedWarnings: const ['onlineReviewBaseUriMissing'],
      isProductionSafe: false,
      isDangerous: false,
    ),
    OnlineReviewBuildConfigScenario(
      id: 'baseUriWithoutAllowHttpDoesNothing',
      description: 'A base URI alone never enables transport.',
      rawValues: const {
        OnlineReviewRuntimeConfigKeys.mode: 'staging',
        OnlineReviewRuntimeConfigKeys.baseUri:
            'https://staging-api.example.test',
      },
      expectedMode: OnlineReviewRuntimeMode.staging,
      expectedCanShowShell: true,
      expectedCanUseHttp: false,
      expectedCanUseDebugHarness: false,
      expectedIsPublic: false,
      expectedHasBaseUri: true,
      expectedRepositoryMode: OnlineReviewRepositoryMode.disabled,
      isProductionSafe: false,
      isDangerous: false,
    ),
    OnlineReviewBuildConfigScenario(
      id: 'allowHttpWithoutModeDoesNothing',
      description: 'HTTP and base URI inputs do nothing without a mode.',
      rawValues: const {
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri:
            'https://implicit-api.example.test',
      },
      expectedMode: OnlineReviewRuntimeMode.disabled,
      expectedCanShowShell: false,
      expectedCanUseHttp: false,
      expectedCanUseDebugHarness: false,
      expectedIsPublic: false,
      expectedHasBaseUri: false,
      expectedRepositoryMode: OnlineReviewRepositoryMode.disabled,
      isProductionSafe: true,
      isDangerous: false,
    ),
  ];
}

OnlineReviewBuildConfigVerificationResult verifyOnlineReviewBuildConfigScenario(
  OnlineReviewBuildConfigScenario scenario,
) {
  final config = parseOnlineReviewRuntimeGateConfig(scenario.rawValues);
  final decision = OnlineReviewRuntimeGate.decide(config);
  final repositoryConfig = onlineReviewRepositoryConfigFromActivationDecision(
    decision,
  );
  final warnings = [
    ...decision.warnings,
    ..._matrixSafetyWarnings(scenario.rawValues, config),
  ];
  final failures = <String>[];

  _expectEquals(
    failures,
    scenario.id,
    'mode',
    scenario.expectedMode,
    config.mode,
  );
  _expectEquals(
    failures,
    scenario.id,
    'canShowShell',
    scenario.expectedCanShowShell,
    decision.canShowShell,
  );
  _expectEquals(
    failures,
    scenario.id,
    'canUseHttp',
    scenario.expectedCanUseHttp,
    decision.canUseHttp,
  );
  _expectEquals(
    failures,
    scenario.id,
    'canUseDebugHarness',
    scenario.expectedCanUseDebugHarness,
    decision.canUseDebugHarness,
  );
  _expectEquals(
    failures,
    scenario.id,
    'isPublic',
    scenario.expectedIsPublic,
    decision.isPublic,
  );
  _expectEquals(
    failures,
    scenario.id,
    'hasBaseUri',
    scenario.expectedHasBaseUri,
    decision.hasBaseUri,
  );
  _expectEquals(
    failures,
    scenario.id,
    'repository mode',
    scenario.expectedRepositoryMode,
    repositoryConfig.mode,
  );

  if (!_sameStrings(scenario.expectedWarnings, warnings)) {
    failures.add(
      '${scenario.id}: expected warnings ${scenario.expectedWarnings} '
      'but got $warnings',
    );
  }

  final expectedRepositoryMode = decision.canUseHttp
      ? OnlineReviewRepositoryMode.http
      : OnlineReviewRepositoryMode.disabled;
  if (repositoryConfig.mode != expectedRepositoryMode) {
    failures.add(
      '${scenario.id}: expected repository mode $expectedRepositoryMode '
      'from activation decision but got ${repositoryConfig.mode}',
    );
  }
  if (decision.canUseHttp && repositoryConfig.baseUri == null) {
    failures.add('${scenario.id}: HTTP decision requires repository baseUri');
  }
  if (!decision.canUseHttp && repositoryConfig.baseUri != null) {
    failures.add(
      '${scenario.id}: disabled HTTP decision must not carry repository baseUri',
    );
  }

  return OnlineReviewBuildConfigVerificationResult(
    scenarioId: scenario.id,
    config: config,
    decision: decision,
    repositoryConfig: repositoryConfig,
    failures: failures,
    warnings: warnings,
  );
}

List<OnlineReviewBuildConfigVerificationResult>
verifyOnlineReviewBuildConfigMatrix() {
  return [
    for (final scenario in onlineReviewBuildConfigScenarios())
      verifyOnlineReviewBuildConfigScenario(scenario),
  ];
}

List<String> _matrixSafetyWarnings(
  Map<String, String> rawValues,
  OnlineReviewRuntimeGateConfig config,
) {
  final rawBaseUri = rawValues[OnlineReviewRuntimeConfigKeys.baseUri]?.trim();
  if (rawBaseUri == null || rawBaseUri.isEmpty) {
    return const [];
  }

  final uri = Uri.tryParse(rawBaseUri);
  if (uri?.scheme != 'http') {
    return const [];
  }

  if (config.baseUri?.scheme == 'http') {
    return const ['onlineReviewInsecureHttpDevOnly'];
  }
  return const ['onlineReviewInsecureHttpRejected'];
}

void _expectEquals<T>(
  List<String> failures,
  String scenarioId,
  String field,
  T expected,
  T actual,
) {
  if (expected != actual) {
    failures.add('$scenarioId: expected $field=$expected but got $actual');
  }
}

bool _sameStrings(List<String> expected, List<String> actual) {
  if (expected.length != actual.length) {
    return false;
  }
  for (var i = 0; i < expected.length; i++) {
    if (expected[i] != actual[i]) {
      return false;
    }
  }
  return true;
}

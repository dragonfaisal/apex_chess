/// Environment/config adapter for the Online Review runtime gate.
///
/// The parser is intentionally pure: callers pass raw configuration values and
/// receive a runtime gate config. Reading Dart build defines is kept in the
/// thin [fromEnvironment] bridge so parser behavior stays deterministic in
/// tests.
library;

import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';

abstract final class OnlineReviewRuntimeConfigKeys {
  static const mode = 'APEX_ONLINE_REVIEW_MODE';
  static const baseUri = 'APEX_ONLINE_REVIEW_BASE_URI';
  static const allowHttp = 'APEX_ONLINE_REVIEW_ALLOW_HTTP';
  static const allowDebugHarness = 'APEX_ONLINE_REVIEW_ALLOW_DEBUG_HARNESS';
  static const allowPublicEntry = 'APEX_ONLINE_REVIEW_ALLOW_PUBLIC_ENTRY';
  static const allowInsecureHttpForDev =
      'APEX_ONLINE_REVIEW_ALLOW_INSECURE_HTTP_FOR_DEV';
}

abstract final class OnlineReviewRuntimeConfigAdapter {
  static OnlineReviewRuntimeGateConfig fromMap(Map<String, String> values) {
    final mode = _parseMode(values[OnlineReviewRuntimeConfigKeys.mode]);
    if (mode == OnlineReviewRuntimeMode.disabled) {
      return const OnlineReviewRuntimeGateConfig.disabled();
    }

    final allowHttp = _parseBool(
      values[OnlineReviewRuntimeConfigKeys.allowHttp],
    );
    final allowDebugHarness = _parseBool(
      values[OnlineReviewRuntimeConfigKeys.allowDebugHarness],
    );
    final allowPublicEntry = _parseBool(
      values[OnlineReviewRuntimeConfigKeys.allowPublicEntry],
    );
    final allowInsecureHttpForDev = _parseBool(
      values[OnlineReviewRuntimeConfigKeys.allowInsecureHttpForDev],
    );
    final baseUri = _parseBaseUri(
      values[OnlineReviewRuntimeConfigKeys.baseUri],
      mode: mode,
      allowInsecureHttpForDev: allowInsecureHttpForDev,
    );

    return switch (mode) {
      OnlineReviewRuntimeMode.disabled =>
        const OnlineReviewRuntimeGateConfig.disabled(),
      OnlineReviewRuntimeMode.devHarness =>
        OnlineReviewRuntimeGateConfig.devHarness(
          baseUri: baseUri,
          allowHttp: allowHttp,
          allowDebugHarness: allowDebugHarness,
        ),
      OnlineReviewRuntimeMode.staging => OnlineReviewRuntimeGateConfig.staging(
        baseUri: baseUri,
        allowHttp: allowHttp,
        allowDebugHarness: allowDebugHarness,
      ),
      OnlineReviewRuntimeMode.internalTester =>
        OnlineReviewRuntimeGateConfig.internalTester(
          baseUri: baseUri,
          allowHttp: allowHttp,
          allowDebugHarness: allowDebugHarness,
        ),
      OnlineReviewRuntimeMode.publicPreview =>
        OnlineReviewRuntimeGateConfig.publicPreview(
          baseUri: baseUri,
          allowHttp: allowHttp,
          allowPublicEntry: allowPublicEntry,
        ),
    };
  }

  static OnlineReviewRuntimeGateConfig fromEnvironment() {
    const mode = String.fromEnvironment(OnlineReviewRuntimeConfigKeys.mode);
    const baseUri = String.fromEnvironment(
      OnlineReviewRuntimeConfigKeys.baseUri,
    );
    const allowHttp = bool.fromEnvironment(
      OnlineReviewRuntimeConfigKeys.allowHttp,
    );
    const allowDebugHarness = bool.fromEnvironment(
      OnlineReviewRuntimeConfigKeys.allowDebugHarness,
    );
    const allowPublicEntry = bool.fromEnvironment(
      OnlineReviewRuntimeConfigKeys.allowPublicEntry,
    );
    const allowInsecureHttpForDev = bool.fromEnvironment(
      OnlineReviewRuntimeConfigKeys.allowInsecureHttpForDev,
    );

    return fromMap({
      OnlineReviewRuntimeConfigKeys.mode: mode,
      OnlineReviewRuntimeConfigKeys.baseUri: baseUri,
      OnlineReviewRuntimeConfigKeys.allowHttp: allowHttp.toString(),
      OnlineReviewRuntimeConfigKeys.allowDebugHarness: allowDebugHarness
          .toString(),
      OnlineReviewRuntimeConfigKeys.allowPublicEntry: allowPublicEntry
          .toString(),
      OnlineReviewRuntimeConfigKeys.allowInsecureHttpForDev:
          allowInsecureHttpForDev.toString(),
    });
  }
}

OnlineReviewRuntimeGateConfig parseOnlineReviewRuntimeGateConfig(
  Map<String, String> values,
) {
  return OnlineReviewRuntimeConfigAdapter.fromMap(values);
}

OnlineReviewRuntimeGateConfig onlineReviewRuntimeGateConfigFromEnvironment() {
  return OnlineReviewRuntimeConfigAdapter.fromEnvironment();
}

OnlineReviewRuntimeMode _parseMode(String? raw) {
  return switch (raw?.trim()) {
    'devHarness' => OnlineReviewRuntimeMode.devHarness,
    'staging' => OnlineReviewRuntimeMode.staging,
    'internalTester' => OnlineReviewRuntimeMode.internalTester,
    'publicPreview' => OnlineReviewRuntimeMode.publicPreview,
    'disabled' || null || '' => OnlineReviewRuntimeMode.disabled,
    _ => OnlineReviewRuntimeMode.disabled,
  };
}

bool _parseBool(String? raw) => raw?.trim().toLowerCase() == 'true';

Uri? _parseBaseUri(
  String? raw, {
  required OnlineReviewRuntimeMode mode,
  required bool allowInsecureHttpForDev,
}) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(value);
  if (uri == null || !uri.hasScheme || uri.host.trim().isEmpty) {
    return null;
  }

  if (uri.scheme == 'https') {
    return uri;
  }

  final canUseInsecureDevUri =
      uri.scheme == 'http' &&
      allowInsecureHttpForDev &&
      (mode == OnlineReviewRuntimeMode.devHarness ||
          mode == OnlineReviewRuntimeMode.staging);
  if (canUseInsecureDevUri) {
    return uri;
  }

  return null;
}

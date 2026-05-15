/// Runtime activation policy for the Online Review product path.
///
/// This layer is intentionally side-effect free. It decides whether UI,
/// debug harnesses, and HTTP transport are allowed, but it never constructs
/// repositories, HTTP clients, routes, or widgets.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum OnlineReviewRuntimeMode {
  disabled,
  devHarness,
  staging,
  internalTester,
  publicPreview,
}

class OnlineReviewRuntimeGateConfig {
  const OnlineReviewRuntimeGateConfig({
    this.mode = OnlineReviewRuntimeMode.disabled,
    this.baseUri,
    this.allowHttp = false,
    this.allowDebugHarness = false,
    this.allowPublicEntry = false,
  });

  const OnlineReviewRuntimeGateConfig.disabled()
    : this(
        mode: OnlineReviewRuntimeMode.disabled,
        baseUri: null,
        allowHttp: false,
        allowDebugHarness: false,
        allowPublicEntry: false,
      );

  const OnlineReviewRuntimeGateConfig.devHarness({
    this.baseUri,
    this.allowHttp = false,
    this.allowDebugHarness = true,
  }) : mode = OnlineReviewRuntimeMode.devHarness,
       allowPublicEntry = false;

  const OnlineReviewRuntimeGateConfig.staging({
    this.baseUri,
    this.allowHttp = false,
    this.allowDebugHarness = false,
  }) : mode = OnlineReviewRuntimeMode.staging,
       allowPublicEntry = false;

  const OnlineReviewRuntimeGateConfig.internalTester({
    this.baseUri,
    this.allowHttp = false,
    this.allowDebugHarness = false,
  }) : mode = OnlineReviewRuntimeMode.internalTester,
       allowPublicEntry = false;

  const OnlineReviewRuntimeGateConfig.publicPreview({
    this.baseUri,
    this.allowHttp = false,
    this.allowPublicEntry = false,
  }) : mode = OnlineReviewRuntimeMode.publicPreview,
       allowDebugHarness = false;

  final OnlineReviewRuntimeMode mode;
  final Uri? baseUri;
  final bool allowHttp;
  final bool allowDebugHarness;
  final bool allowPublicEntry;
}

class OnlineReviewActivationDecision {
  OnlineReviewActivationDecision({
    required this.mode,
    required this.isEnabled,
    required this.canShowShell,
    required this.canUseHttp,
    required this.canUseDebugHarness,
    required this.requiresExplicitBaseUri,
    required this.hasBaseUri,
    required this.baseUri,
    required this.isPublic,
    required this.reasonCode,
    Iterable<String> warnings = const [],
  }) : warnings = List.unmodifiable(warnings);

  final OnlineReviewRuntimeMode mode;
  final bool isEnabled;
  final bool canShowShell;
  final bool canUseHttp;
  final bool canUseDebugHarness;
  final bool requiresExplicitBaseUri;
  final bool hasBaseUri;
  final Uri? baseUri;
  final bool isPublic;
  final String reasonCode;
  final List<String> warnings;
}

class OnlineReviewRuntimeGate {
  const OnlineReviewRuntimeGate._();

  static OnlineReviewActivationDecision decide(
    OnlineReviewRuntimeGateConfig config,
  ) {
    final hasBaseUri = config.baseUri != null;
    final requiresExplicitBaseUri =
        config.mode != OnlineReviewRuntimeMode.disabled && config.allowHttp;

    final warnings = <String>[];
    if (requiresExplicitBaseUri && !hasBaseUri) {
      warnings.add('onlineReviewBaseUriMissing');
    }
    if (config.mode == OnlineReviewRuntimeMode.publicPreview &&
        !config.allowPublicEntry) {
      warnings.add('onlineReviewPublicEntryNotAllowed');
    }

    final isEnabled = _isEnabled(config);
    final canShowShell = _canShowShell(config);
    final canUseHttp =
        isEnabled && config.allowHttp && hasBaseUri && canShowShell;
    final canUseDebugHarness =
        isEnabled &&
        config.allowDebugHarness &&
        config.mode != OnlineReviewRuntimeMode.publicPreview;
    final isPublic =
        config.mode == OnlineReviewRuntimeMode.publicPreview &&
        config.allowPublicEntry &&
        config.allowHttp &&
        hasBaseUri;

    return OnlineReviewActivationDecision(
      mode: config.mode,
      isEnabled: isEnabled,
      canShowShell: canShowShell,
      canUseHttp: canUseHttp,
      canUseDebugHarness: canUseDebugHarness,
      requiresExplicitBaseUri: requiresExplicitBaseUri,
      hasBaseUri: hasBaseUri,
      baseUri: config.baseUri,
      isPublic: isPublic,
      reasonCode: _reasonCode(config, warnings),
      warnings: warnings,
    );
  }

  static bool _isEnabled(OnlineReviewRuntimeGateConfig config) {
    return switch (config.mode) {
      OnlineReviewRuntimeMode.disabled => false,
      OnlineReviewRuntimeMode.devHarness => true,
      OnlineReviewRuntimeMode.staging => true,
      OnlineReviewRuntimeMode.internalTester => true,
      OnlineReviewRuntimeMode.publicPreview => config.allowPublicEntry,
    };
  }

  static bool _canShowShell(OnlineReviewRuntimeGateConfig config) {
    return switch (config.mode) {
      OnlineReviewRuntimeMode.disabled => false,
      OnlineReviewRuntimeMode.devHarness => true,
      OnlineReviewRuntimeMode.staging => true,
      OnlineReviewRuntimeMode.internalTester => true,
      OnlineReviewRuntimeMode.publicPreview => config.allowPublicEntry,
    };
  }

  static String _reasonCode(
    OnlineReviewRuntimeGateConfig config,
    List<String> warnings,
  ) {
    if (config.mode == OnlineReviewRuntimeMode.disabled) {
      return 'onlineReviewDisabled';
    }
    if (warnings.contains('onlineReviewPublicEntryNotAllowed')) {
      return 'onlineReviewPublicEntryNotAllowed';
    }
    if (warnings.contains('onlineReviewBaseUriMissing')) {
      return 'onlineReviewConfigIncomplete';
    }
    return switch (config.mode) {
      OnlineReviewRuntimeMode.disabled => 'onlineReviewDisabled',
      OnlineReviewRuntimeMode.devHarness => 'onlineReviewDevHarness',
      OnlineReviewRuntimeMode.staging => 'onlineReviewStaging',
      OnlineReviewRuntimeMode.internalTester => 'onlineReviewInternalTester',
      OnlineReviewRuntimeMode.publicPreview => 'onlineReviewPublicPreview',
    };
  }
}

final onlineReviewRuntimeGateConfigProvider =
    Provider<OnlineReviewRuntimeGateConfig>((ref) {
      return const OnlineReviewRuntimeGateConfig.disabled();
    });

final onlineReviewActivationDecisionProvider =
    Provider<OnlineReviewActivationDecision>((ref) {
      final config = ref.watch(onlineReviewRuntimeGateConfigProvider);
      return OnlineReviewRuntimeGate.decide(config);
    });

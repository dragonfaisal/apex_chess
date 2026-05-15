/// Guarded developer-only harness for the Online Review product shell.
///
/// This file owns the activation seam only. Enabling the harness exposes the
/// shell for explicit dev/test composition, but it does not change repository
/// configuration or activate live HTTP.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';
import 'package:apex_chess/features/pgn_review/presentation/online_review_product_shell.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';

enum OnlineReviewShellActivationMode { disabled, devHarness }

class OnlineReviewShellFeatureConfig {
  const OnlineReviewShellFeatureConfig._(this.mode, {required this.reasonCode});

  const OnlineReviewShellFeatureConfig.disabled()
    : this._(
        OnlineReviewShellActivationMode.disabled,
        reasonCode: 'onlineReviewDisabled',
      );

  const OnlineReviewShellFeatureConfig.devHarness()
    : this._(
        OnlineReviewShellActivationMode.devHarness,
        reasonCode: 'onlineReviewDevHarness',
      );

  factory OnlineReviewShellFeatureConfig.fromDecision(
    OnlineReviewActivationDecision decision,
  ) {
    if (decision.canShowShell && decision.canUseDebugHarness) {
      return OnlineReviewShellFeatureConfig._(
        OnlineReviewShellActivationMode.devHarness,
        reasonCode: decision.reasonCode,
      );
    }
    return OnlineReviewShellFeatureConfig._(
      OnlineReviewShellActivationMode.disabled,
      reasonCode: decision.reasonCode,
    );
  }

  final OnlineReviewShellActivationMode mode;
  final String reasonCode;

  bool get isEnabled => mode == OnlineReviewShellActivationMode.devHarness;
}

final onlineReviewShellFeatureConfigProvider =
    Provider<OnlineReviewShellFeatureConfig>((ref) {
      final decision = ref.watch(onlineReviewActivationDecisionProvider);
      return OnlineReviewShellFeatureConfig.fromDecision(decision);
    });

class OnlineReviewProductDevHarness extends ConsumerWidget {
  const OnlineReviewProductDevHarness({
    super.key,
    this.pgn = _defaultDevPgn,
    this.mode = ApexOnlineReviewMode.onlineFast,
  });

  final String pgn;
  final ApexOnlineReviewMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(onlineReviewShellFeatureConfigProvider);
    if (!config.isEnabled) {
      return const _DisabledHarness();
    }

    return Scaffold(
      key: const ValueKey('online-review-dev-harness'),
      backgroundColor: ApexColors.deepSpace,
      appBar: AppBar(title: const Text('Online Review Dev Harness')),
      body: OnlineReviewProductShell(pgn: pgn, mode: mode),
    );
  }
}

class _DisabledHarness extends StatelessWidget {
  const _DisabledHarness();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('online-review-dev-harness-disabled'),
      backgroundColor: ApexColors.deepSpace,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(ApexSpacing.lg),
              child: GlassPanel(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Online Review dev harness',
                      style: ApexTypography.titleMedium.copyWith(
                        color: ApexColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: ApexSpacing.sm),
                    Text(
                      'Disabled by default. Enable the explicit harness gate '
                      'to open the shell in a dev or test context.',
                      style: ApexTypography.bodyMedium.copyWith(
                        color: ApexColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _defaultDevPgn = '1. e4 e5 2. Nf3 Nc6 *';

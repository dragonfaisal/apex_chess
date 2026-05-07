/// Connect-Account onboarding — first launch or Switch-Account flow.
///
/// Reuses the shared [UsernameValidator] / pill so the user only has to
/// provide a handle the public API agrees exists. On connect we persist
/// `(source, username)` via [AccountController] and either:
///
///   * push HomeScreen (first-launch path), or
///   * pop back to whoever pushed us (switch-account path).
///
/// The "Skip for now" path leaves the account as `null`; the rest of the
/// app gracefully falls back to per-screen username fields so nothing is
/// gated behind onboarding.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/features/user_validation/data/username_validator.dart';
import 'package:apex_chess/features/user_validation/presentation/username_validation_controller.dart';
import 'package:apex_chess/features/user_validation/presentation/widgets/username_validation_pill.dart';
import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_loading.dart';
import 'package:apex_chess/shared_ui/widgets/apex_platform_badge.dart';
import 'package:apex_chess/shared_ui/widgets/apex_snack.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';

import '../../domain/apex_account.dart';
import '../controllers/account_controller.dart';

class ConnectAccountScreen extends ConsumerStatefulWidget {
  const ConnectAccountScreen({
    super.key,
    this.allowSkip = true,
    this.onComplete,
  });

  /// When true (the default first-launch path), shows a "Skip for now"
  /// link below the CTA. Set false when the screen is reached from a
  /// Switch-Account button on Home — we still allow Back, just no skip.
  final bool allowSkip;

  /// Optional hook invoked after a successful connect / skip. Useful
  /// for the Switch-Account flow so the caller can pop back.
  final VoidCallback? onComplete;

  @override
  ConsumerState<ConnectAccountScreen> createState() =>
      _ConnectAccountScreenState();
}

class _ConnectAccountScreenState extends ConsumerState<ConnectAccountScreen> {
  final _textController = TextEditingController();
  AccountSource _source = AccountSource.chessCom;
  UsernameValidationController? _validation;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(accountControllerProvider).valueOrNull;
    if (existing != null) {
      _source = existing.source;
      _textController.text = existing.username;
    }
    _textController.addListener(_onTextChange);
    // Validation controller is created here so we can listen to it for
    // the whole widget lifetime — the build() method reads
    // `.value` to decide whether CONNECT is enabled, but since it's a
    // ValueNotifier the parent won't rebuild on its own when the pill
    // flips from `checking` → `exists`. Forwarding the notification to
    // setState() keeps the CTA in sync with the pill.
    _validation = UsernameValidationController(
      ref.read(usernameValidatorProvider),
    )..addListener(_onValidationChange);
    // Seed the pill with whatever the user pre-filled from an earlier
    // account; otherwise the first keystroke has to rediscover existence.
    WidgetsBinding.instance.addPostFrameCallback((_) => _pushValidation());
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChange);
    _textController.dispose();
    _validation?.removeListener(_onValidationChange);
    _validation?.dispose();
    super.dispose();
  }

  UsernameValidationController _ensureValidation() => _validation!;

  void _onValidationChange() {
    if (!mounted) return;
    setState(() {});
  }

  void _onTextChange() {
    _pushValidation();
    if (mounted) setState(() {});
  }

  void _pushValidation() {
    _ensureValidation().updateInput(
      source: _source.wire,
      username: _textController.text,
    );
  }

  void _onSourceChanged(AccountSource src) {
    if (src == _source) return;
    setState(() => _source = src);
    unawaited(ref.read(connectionPresenceProvider.notifier).checkNow());
    _pushValidation();
  }

  Future<void> _connect() async {
    final name = _textController.text.trim();
    if (name.isEmpty) return;
    unawaited(ref.read(connectionPresenceProvider.notifier).checkNow());
    setState(() => _busy = true);
    try {
      await ref
          .read(accountControllerProvider.notifier)
          .connect(ApexAccount(source: _source, username: name));
      if (!mounted) return;
      // Phase A audit § 7: connect used to silently leave the user on
      // this screen when the backend failed. Surface success briefly
      // (so the user knows the connect worked) and call onComplete to
      // pop back automatically.
      showApexGlassToast(
        context,
        message: ApexCopy.synced,
        detail: name,
        type: ApexGlassToastType.success,
      );
      widget.onComplete?.call();
    } catch (e) {
      if (!mounted) return;
      showApexGlassToast(
        context,
        message: ApexCopy.tryAgain,
        type: ApexGlassToastType.warning,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _skip() async {
    await ref.read(accountControllerProvider.notifier).markOnboardingSeen();
    if (!mounted) return;
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final state = _ensureValidation().value;
    final existingAccount = ref.watch(accountControllerProvider).valueOrNull;
    final isExactConnectedAccount =
        existingAccount != null &&
        existingAccount.source == _source &&
        PlayerIdentityDisplay.normalizeUsername(existingAccount.username) ==
            PlayerIdentityDisplay.normalizeUsername(_textController.text);
    final canConnect =
        !_busy &&
        state.existence == UsernameExistence.exists &&
        _textController.text.trim().isNotEmpty;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 160,
                  child: Center(child: ApexPulseLoader(size: 120)),
                ),
                const SizedBox(height: 20),
                Text(
                  ApexCopy.onboardingTitle,
                  textAlign: TextAlign.center,
                  style: ApexTypography.headlineMedium.copyWith(
                    letterSpacing: 4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  ApexCopy.onboardingHeadline,
                  textAlign: TextAlign.center,
                  style: ApexTypography.titleMedium.copyWith(
                    color: ApexColors.sapphireBright,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ApexCopy.onboardingSub,
                  textAlign: TextAlign.center,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 26),
                GlassPanel(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                  accentColor: ApexColors.sapphire,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SourcePicker(
                        source: _source,
                        onChanged: _onSourceChanged,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _textController,
                        textInputAction: TextInputAction.go,
                        onSubmitted: (_) {
                          if (canConnect) _connect();
                        },
                        style: ApexTypography.bodyMedium.copyWith(
                          color: ApexColors.textPrimary,
                          fontSize: 14,
                          fontFamily: 'JetBrains Mono',
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: ApexColors.sapphireBright,
                            size: 20,
                          ),
                          suffixIcon: UsernameValidationPill(
                            controller: _ensureValidation(),
                          ),
                          suffixIconConstraints: const BoxConstraints(
                            minHeight: 32,
                            minWidth: 0,
                          ),
                          hintText: _source == AccountSource.chessCom
                              ? 'e.g. hikaru'
                              : 'e.g. DrNykterstein',
                          hintStyle: ApexTypography.bodyMedium.copyWith(
                            color: ApexColors.textTertiary,
                            fontFamily: 'JetBrains Mono',
                          ),
                          filled: true,
                          fillColor: ApexColors.deepSpace.withValues(
                            alpha: 0.55,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: ApexColors.subtleBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: ApexColors.subtleBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: ApexColors.sapphire.withValues(
                                alpha: 0.55,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (isExactConnectedAccount) ...[
                        const SizedBox(height: 8),
                        const _ConnectedAccountNotice(),
                      ],
                      const SizedBox(height: 14),
                      _ConnectCta(
                        enabled: canConnect,
                        busy: _busy,
                        onTap: _connect,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        ApexCopy.onboardingPrivacy,
                        textAlign: TextAlign.center,
                        style: ApexTypography.bodyMedium.copyWith(
                          color: ApexColors.textTertiary,
                          letterSpacing: 0.6,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.allowSkip) ...[
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: _busy ? null : _skip,
                    style: TextButton.styleFrom(
                      foregroundColor: ApexColors.textTertiary,
                    ),
                    child: const Text(ApexCopy.onboardingSkip),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SourcePicker extends StatelessWidget {
  const _SourcePicker({required this.source, required this.onChanged});

  final AccountSource source;
  final ValueChanged<AccountSource> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SourceChip(
          platform: PlayerIdentityPlatform.chessCom,
          selected: source == AccountSource.chessCom,
          onTap: () => onChanged(AccountSource.chessCom),
        ),
        const SizedBox(width: 10),
        _SourceChip(
          platform: PlayerIdentityPlatform.lichess,
          selected: source == AccountSource.lichess,
          onTap: () => onChanged(AccountSource.lichess),
        ),
      ],
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({
    required this.platform,
    required this.selected,
    required this.onTap,
  });

  final PlayerIdentityPlatform platform;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final display = ApexPlatformBadgeDisplay.fromPlatform(platform);
    final activeAccent = platform == PlayerIdentityPlatform.lichess
        ? ApexColors.aurora
        : ApexColors.sapphireBright;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: display.label,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            key: ValueKey('connect-source-${platform.name}-chip'),
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: selected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        activeAccent.withValues(alpha: 0.26),
                        ApexColors.sapphire.withValues(alpha: 0.34),
                        ApexColors.deepSpace.withValues(alpha: 0.78),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        ApexColors.deepSpace.withValues(alpha: 0.62),
                        ApexColors.deepSpace.withValues(alpha: 0.50),
                      ],
                    ),
              border: Border.all(
                color: selected
                    ? activeAccent.withValues(alpha: 0.92)
                    : ApexColors.subtleBorder.withValues(alpha: 0.78),
                width: selected ? 1.25 : 0.7,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: activeAccent.withValues(alpha: 0.20),
                        blurRadius: 18,
                        spreadRadius: -7,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: ApexPlatformBadge(platform: platform, selected: selected),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConnectCta extends StatelessWidget {
  const _ConnectCta({
    required this.enabled,
    required this.busy,
    required this.onTap,
  });

  final bool enabled;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        key: const ValueKey('connect-account-cta'),
        duration: const Duration(milliseconds: 200),
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: enabled
              ? ApexGradients.sapphire
              : LinearGradient(
                  colors: [
                    ApexColors.deepSpace.withValues(alpha: 0.68),
                    ApexColors.deepSpace.withValues(alpha: 0.56),
                  ],
                ),
          border: enabled
              ? null
              : Border.all(
                  color: ApexColors.subtleBorder.withValues(alpha: 0.82),
                  width: 0.7,
                ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: ApexColors.sapphire.withValues(alpha: 0.35),
                    blurRadius: 22,
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: ApexPulseLoader(
                  size: 20,
                  color: ApexColors.textOnAccent,
                ),
              )
            : Text(
                ApexCopy.onboardingConnect,
                key: const ValueKey('connect-account-cta-label'),
                style: ApexTypography.labelLarge.copyWith(
                  color: enabled
                      ? ApexColors.textOnAccent
                      : ApexColors.textSecondary,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class _ConnectedAccountNotice extends StatelessWidget {
  const _ConnectedAccountNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: ApexColors.sapphireBright.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ApexColors.sapphireBright.withValues(alpha: 0.28),
          width: 0.7,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: ApexColors.sapphireBright,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ApexCopy.connectedAccountNotice,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.sapphireBright,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

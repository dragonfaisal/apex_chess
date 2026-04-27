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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/features/user_validation/data/username_validator.dart';
import 'package:apex_chess/features/user_validation/presentation/username_validation_controller.dart';
import 'package:apex_chess/features/user_validation/presentation/widgets/username_validation_pill.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';
import 'package:apex_chess/shared_ui/widgets/quantum_shatter_loader.dart';

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

class _ConnectAccountScreenState
    extends ConsumerState<ConnectAccountScreen> {
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
    _validation =
        UsernameValidationController(ref.read(usernameValidatorProvider))
          ..addListener(_onValidationChange);
    // Seed the pill with whatever the user pre-filled from an earlier
    // account; otherwise the first keystroke has to rediscover existence.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _pushValidation());
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

  void _onTextChange() => _pushValidation();

  void _pushValidation() {
    _ensureValidation().updateInput(
      source: _source.wire,
      username: _textController.text,
    );
  }

  void _onSourceChanged(AccountSource src) {
    if (src == _source) return;
    setState(() => _source = src);
    _pushValidation();
  }

  Future<void> _connect() async {
    final name = _textController.text.trim();
    if (name.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(accountControllerProvider.notifier).connect(
            ApexAccount(source: _source, username: name),
          );
      if (!mounted) return;
      // Phase A audit § 7: connect used to silently leave the user on
      // this screen when the backend failed. Surface success briefly
      // (so the user knows the connect worked) and call onComplete to
      // pop back automatically.
      messenger.showSnackBar(SnackBar(
        content: Text('Connected to ${_source.wire} as $name'),
        backgroundColor: ApexColors.aurora,
        duration: const Duration(seconds: 2),
      ));
      widget.onComplete?.call();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text('Connect failed: $e'),
        backgroundColor: ApexColors.rubyDeep,
        duration: const Duration(seconds: 4),
      ));
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
    final canConnect = !_busy &&
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
                  child: Center(
                    child: QuantumShatterLoader(size: 140),
                  ),
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
                              minHeight: 32, minWidth: 0),
                          hintText: _source == AccountSource.chessCom
                              ? 'e.g. hikaru'
                              : 'e.g. DrNykterstein',
                          hintStyle: ApexTypography.bodyMedium.copyWith(
                            color: ApexColors.textTertiary,
                            fontFamily: 'JetBrains Mono',
                          ),
                          filled: true,
                          fillColor:
                              ApexColors.deepSpace.withValues(alpha: 0.55),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: ApexColors.subtleBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: ApexColors.subtleBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: ApexColors.sapphire
                                  .withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ),
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
          label: ApexCopy.importSourceChessCom,
          selected: source == AccountSource.chessCom,
          onTap: () => onChanged(AccountSource.chessCom),
        ),
        const SizedBox(width: 10),
        _SourceChip(
          label: ApexCopy.importSourceLichess,
          selected: source == AccountSource.lichess,
          onTap: () => onChanged(AccountSource.lichess),
        ),
      ],
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: selected
                ? ApexGradients.sapphire
                : LinearGradient(
                    colors: [
                      ApexColors.deepSpace.withValues(alpha: 0.6),
                      ApexColors.deepSpace.withValues(alpha: 0.6),
                    ],
                  ),
            border: Border.all(
              color: selected
                  ? ApexColors.sapphireBright
                  : ApexColors.subtleBorder,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: ApexTypography.labelLarge.copyWith(
              fontSize: 12,
              color: selected
                  ? ApexColors.textOnAccent
                  : ApexColors.textSecondary,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
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
        duration: const Duration(milliseconds: 200),
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: enabled
              ? ApexGradients.sapphire
              : LinearGradient(
                  colors: [
                    ApexColors.deepSpace.withValues(alpha: 0.6),
                    ApexColors.deepSpace.withValues(alpha: 0.6),
                  ],
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
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(ApexColors.textOnAccent),
                ),
              )
            : Text(
                ApexCopy.onboardingConnect,
                style: ApexTypography.labelLarge.copyWith(
                  color: enabled
                      ? ApexColors.textOnAccent
                      : ApexColors.textTertiary,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

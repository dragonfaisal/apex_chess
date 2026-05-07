/// Opponent Insights screen.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/import_match/domain/imported_game.dart';
import 'package:apex_chess/features/import_match/presentation/controllers/recent_searches_controller.dart';
import 'package:apex_chess/features/user_validation/presentation/username_validation_controller.dart';
import 'package:apex_chess/features/user_validation/presentation/widgets/username_validation_pill.dart';
import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_loading.dart';
import 'package:apex_chess/shared_ui/widgets/apex_platform_badge.dart';
import 'package:apex_chess/shared_ui/widgets/apex_snack.dart';
import 'package:apex_chess/shared_ui/widgets/apex_side_marker.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';

import '../../data/profile_scanner_service.dart';
import '../../domain/profile_scan_result.dart';
import '../controllers/profile_scanner_controller.dart';

class ProfileScannerScreen extends ConsumerStatefulWidget {
  const ProfileScannerScreen({super.key});

  @override
  ConsumerState<ProfileScannerScreen> createState() =>
      _ProfileScannerScreenState();
}

class _ProfileScannerScreenState extends ConsumerState<ProfileScannerScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _source = 'chess.com';
  UsernameValidationController? _validation;
  bool _showRecents = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_updateRecentVisibility);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_updateRecentVisibility);
    _focusNode.dispose();
    _controller.dispose();
    _validation?.dispose();
    super.dispose();
  }

  UsernameValidationController _ensureValidation() {
    return _validation ??= UsernameValidationController(
      ref.read(usernameValidatorProvider),
    );
  }

  void _onTextChanged() {
    _ensureValidation().updateInput(
      source: _source,
      username: _controller.text,
    );
    if (mounted) setState(() {});
    _updateRecentVisibility();
  }

  void _updateRecentVisibility() {
    if (!mounted) return;
    final shouldShow = _focusNode.hasFocus && _controller.text.trim().isEmpty;
    if (_showRecents == shouldShow) return;
    setState(() => _showRecents = shouldShow);
  }

  void _onSourceChanged(String source) {
    setState(() => _source = source);
    _ensureValidation().updateInput(source: source, username: _controller.text);
  }

  Future<void> _scan() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    FocusScope.of(context).unfocus();
    final account = ref.read(accountControllerProvider).valueOrNull;
    await ref
        .read(profileScannerControllerProvider.notifier)
        .scan(
          username: name,
          source: _source,
          connectedUsername: account?.username,
          connectedSource: account?.source.wire,
        );
  }

  GameSource get _gameSource =>
      _source == 'lichess' ? GameSource.lichess : GameSource.chessCom;

  void _useRecent(String username) {
    _controller.text = username;
    _controller.selection = TextSelection.collapsed(offset: username.length);
    _focusNode.unfocus();
    setState(() => _showRecents = false);
  }

  void _cancelScan() {
    ref.read(profileScannerControllerProvider.notifier).cancel();
    showApexSnack(
      context,
      message: ApexCopy.scannerCancelled,
      color: ApexColors.textTertiary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileScannerControllerProvider);
    final recents = ref
        .watch(recentSearchesProvider)
        .maybeWhen(
          data: (s) => s.forSource(_gameSource),
          orElse: () => const <String>[],
        );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
        child: SafeArea(
          child: RefreshIndicator(
            color: ApexColors.sapphireBright,
            backgroundColor: ApexColors.nebula,
            onRefresh: () => ref
                .read(connectionPresenceProvider.notifier)
                .refresh(showSyncing: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                18,
                8,
                18,
                MediaQuery.viewInsetsOf(context).bottom + 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(onBack: () => Navigator.of(context).pop()),
                  const SizedBox(height: 16),
                  _InputCard(
                    controller: _controller,
                    source: _source,
                    onSourceChanged: _onSourceChanged,
                    onSubmit: _scan,
                    isLoading: state.isLoading,
                    validation: _ensureValidation(),
                    focusNode: _focusNode,
                    showRecents: _showRecents && recents.isNotEmpty,
                    recents: recents,
                    onRecentTapped: _useRecent,
                    onClearRecents: () => ref
                        .read(recentSearchesProvider.notifier)
                        .clear(_gameSource),
                    onRemoveRecent: (u) => ref
                        .read(recentSearchesProvider.notifier)
                        .remove(_gameSource, u),
                  ),
                  const SizedBox(height: 20),
                  if (state.isLoading)
                    _LoadingCard(
                      progress: state.progress,
                      onCancel: _cancelScan,
                    )
                  else if (state.wasCancelled)
                    const _CancelledCard()
                  else if (state.error != null)
                    _ErrorCard(message: state.error!)
                  else if (state.result != null)
                    _ResultSection(result: state.result!)
                  else
                    const _ScannerEmptyState(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ApexColors.textPrimary,
            size: 18,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ApexCopy.scannerTitle,
                style: ApexTypography.headlineMedium.copyWith(letterSpacing: 3),
              ),
              const SizedBox(height: 2),
              Text(
                ApexCopy.scannerSubtitle,
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary,
                  letterSpacing: 1,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Input card ────────────────────────────────────────────────────────

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.controller,
    required this.source,
    required this.onSourceChanged,
    required this.onSubmit,
    required this.isLoading,
    required this.validation,
    required this.focusNode,
    required this.showRecents,
    required this.recents,
    required this.onRecentTapped,
    required this.onClearRecents,
    required this.onRemoveRecent,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String source;
  final ValueChanged<String> onSourceChanged;
  final VoidCallback onSubmit;
  final bool isLoading;
  final UsernameValidationController validation;
  final bool showRecents;
  final List<String> recents;
  final ValueChanged<String> onRecentTapped;
  final VoidCallback onClearRecents;
  final ValueChanged<String> onRemoveRecent;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      accentColor: ApexColors.sapphireBright,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _SourceToggle(
                platform: PlayerIdentityPlatform.chessCom,
                selected: source == 'chess.com',
                onTap: () => onSourceChanged('chess.com'),
              ),
              const SizedBox(width: 8),
              _SourceToggle(
                platform: PlayerIdentityPlatform.lichess,
                selected: source == 'lichess',
                onTap: () => onSourceChanged('lichess'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: !isLoading,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSubmit(),
            cursorColor: ApexColors.sapphireBright,
            autofillHints: const [],
            enableSuggestions: false,
            autocorrect: false,
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textPrimary,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
            decoration: InputDecoration(
              hintText: 'Opponent username',
              hintStyle: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textTertiary,
              ),
              prefixIcon: const Icon(
                Icons.person_search_rounded,
                color: ApexColors.sapphireBright,
                size: 18,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UsernameValidationPill(controller: validation),
                  if (controller.text.isNotEmpty)
                    IconButton(
                      tooltip: ApexCopy.clear,
                      onPressed: controller.clear,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: ApexColors.textTertiary,
                        size: 18,
                      ),
                    ),
                ],
              ),
              suffixIconConstraints: const BoxConstraints(
                minHeight: 32,
                minWidth: 0,
              ),
              filled: true,
              fillColor: ApexColors.nebula.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: ApexColors.stardustLine.withValues(alpha: 0.4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: ApexColors.sapphireBright,
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: ApexColors.stardustLine.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          if (showRecents)
            _RecentSearchesDropdown(
              entries: recents,
              onTap: onRecentTapped,
              onClear: onClearRecents,
              onRemove: onRemoveRecent,
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onSubmit,
              icon: isLoading
                  ? const ApexPulseLoader(
                      size: 14,
                      color: ApexColors.sapphireBright,
                    )
                  : const Icon(Icons.insights_rounded, size: 16),
              label: Text(
                isLoading ? ApexCopy.scannerRunning : ApexCopy.scannerCta,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: ApexColors.sapphireBright,
                side: BorderSide(
                  color: ApexColors.sapphire.withValues(alpha: 0.45),
                  width: 0.8,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceToggle extends StatelessWidget {
  const _SourceToggle({
    required this.platform,
    required this.selected,
    required this.onTap,
  });

  final PlayerIdentityPlatform platform;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? ApexColors.sapphireDeep.withValues(alpha: 0.35)
                : ApexColors.nebula.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? ApexColors.sapphireBright.withValues(alpha: 0.7)
                  : ApexColors.stardustLine.withValues(alpha: 0.3),
              width: selected ? 1.0 : 0.6,
            ),
          ),
          child: Center(
            child: ApexPlatformBadge(
              platform: platform,
              compact: true,
              selected: selected,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentSearchesDropdown extends StatelessWidget {
  const _RecentSearchesDropdown({
    required this.entries,
    required this.onTap,
    required this.onClear,
    required this.onRemove,
  });

  final List<String> entries;
  final ValueChanged<String> onTap;
  final VoidCallback onClear;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(vertical: 6),
        margin: null,
        borderRadius: 12,
        accentAlpha: 0.18,
        fillAlpha: 0.55,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 8, 4),
              child: Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 14,
                    color: ApexColors.sapphireBright.withValues(alpha: 0.75),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'RECENT SEARCHES',
                    style: ApexTypography.bodyMedium.copyWith(
                      color: ApexColors.textTertiary,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onClear,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 28),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      ApexCopy.clear,
                      style: ApexTypography.bodyMedium.copyWith(
                        color: ApexColors.ruby.withValues(alpha: 0.85),
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            for (final entry in entries)
              InkWell(
                onTap: () => onTap(entry),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_search_rounded,
                        size: 16,
                        color: ApexColors.textTertiary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry,
                          overflow: TextOverflow.ellipsis,
                          style: ApexTypography.bodyMedium.copyWith(
                            color: ApexColors.textPrimary,
                            fontSize: 13,
                            fontFamily: 'JetBrains Mono',
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => onRemove(entry),
                        iconSize: 14,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        icon: Icon(
                          Icons.close_rounded,
                          color: ApexColors.textTertiary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Loading ──────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.progress, required this.onCancel});
  final ScanProgress? progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    final overall = p?.overall ?? 0.0;
    return GlassPanel(
      accentColor: ApexColors.aurora,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        children: [
          ApexLoadingScaffold(
            title: ApexCopy.scannerLoading,
            messages: const [
              'Checking games...',
              'Building profile...',
              'Reviewing public signals...',
            ],
            progress: overall == 0 ? null : overall,
            compact: true,
          ),
          const SizedBox(height: 8),
          if (p != null)
            Text(
              p.currentGame == null
                  ? 'Preparing review...'
                  : 'Game ${p.completed + 1}/${p.total}  ·  '
                        'ply ${p.currentPly}/${p.currentPlyTotal}\n'
                        '${p.currentGame}',
              textAlign: TextAlign.center,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textTertiary,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: ApexColors.ruby,
              side: BorderSide(
                color: ApexColors.ruby.withValues(alpha: 0.55),
                width: 1,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: onCancel,
            icon: const Icon(Icons.close_rounded, size: 16),
            label: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _ScannerEmptyState extends StatelessWidget {
  const _ScannerEmptyState();

  @override
  Widget build(BuildContext context) {
    return const ApexEmptyStateCard(
      icon: Icons.query_stats_rounded,
      title: 'Search an opponent',
      message: 'Review public games and performance signals.',
    );
  }
}

class _CancelledCard extends StatelessWidget {
  const _CancelledCard();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      accentColor: ApexColors.textTertiary,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const Icon(
            Icons.cancel_outlined,
            color: ApexColors.textTertiary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Scan cancelled.',
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error ────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      accentColor: ApexColors.ruby,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: ApexColors.ruby,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: ApexTypography.bodyMedium.copyWith(color: ApexColors.ruby),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Result ───────────────────────────────────────────────────────────

class _ResultSection extends StatelessWidget {
  const _ResultSection({required this.result});
  final ProfileScanResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SuspicionCard(result: result),
        const SizedBox(height: 14),
        _SampleList(games: result.games),
      ],
    );
  }
}

class _SuspicionCard extends StatelessWidget {
  const _SuspicionCard({required this.result});
  final ProfileScanResult result;

  @override
  Widget build(BuildContext context) {
    final accent = _suspicionColor(result.suspicion);
    return GlassPanel(
      accentColor: accent,
      accentAlpha: 0.55,
      showGlow: true,
      glowIntensity: 0.22,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: Center(
              child: _SuspicionDial(
                accuracy: result.averageAccuracy,
                accent: accent,
                label: result.suspicion.label,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ApexPlatformBadge(
                platform: PlayerIdentityPlatform.fromWire(result.source),
                compact: true,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  '${result.username} · ${result.sampleSize} games',
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textTertiary,
                    fontSize: 11,
                    letterSpacing: 0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _neutralVerdict(result),
            textAlign: TextAlign.center,
            style: ApexTypography.bodyLarge.copyWith(
              color: ApexColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _suspicionColor(SuspicionLevel s) => switch (s) {
    SuspicionLevel.clean => ApexColors.great,
    SuspicionLevel.moderate => ApexColors.inaccuracy,
    SuspicionLevel.suspicious => ApexColors.ruby,
  };

  String _neutralVerdict(ProfileScanResult result) {
    final rating = result.averageRating ?? 'this rating';
    final accuracy = result.averageAccuracy.toStringAsFixed(0);
    final match = (result.averageEngineMatchRate * 100).toStringAsFixed(0);
    return switch (result.suspicion) {
      SuspicionLevel.clean =>
        'Typical profile sample for $rating: $accuracy% accuracy, '
            '$match% top-line match.',
      SuspicionLevel.moderate =>
        'Elevated profile sample for $rating: $accuracy% accuracy, '
            '$match% top-line match.',
      SuspicionLevel.suspicious =>
        'High-variance profile sample for $rating. Review the games manually.',
    };
  }
}

class _SuspicionDial extends StatelessWidget {
  const _SuspicionDial({
    required this.accuracy,
    required this.accent,
    required this.label,
  });

  final double accuracy;
  final Color accent;
  final String label;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SuspicionDialPainter(accuracy: accuracy, accent: accent),
      child: SizedBox(
        width: 180,
        height: 180,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                accuracy.toStringAsFixed(1),
                style: ApexTypography.displayLarge.copyWith(
                  color: accent,
                  fontSize: 44,
                  letterSpacing: -1,
                ),
              ),
              Text(
                '% ACCURACY',
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label.toUpperCase(),
                style: ApexTypography.labelLarge.copyWith(
                  color: accent,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuspicionDialPainter extends CustomPainter {
  _SuspicionDialPainter({required this.accuracy, required this.accent});

  final double accuracy;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 8;

    // Background ring.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = ApexColors.stardustLine.withValues(alpha: 0.35),
    );

    // Progress arc (0–100 mapped to full rotation starting from 12 o'clock).
    final sweep = (accuracy / 100.0) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [accent.withValues(alpha: 0.4), accent],
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + sweep,
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(_SuspicionDialPainter old) =>
      old.accuracy != accuracy || old.accent != accent;
}

class _SampleList extends StatelessWidget {
  const _SampleList({required this.games});
  final List<GameAccuracy> games;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SAMPLE GAMES',
            style: ApexTypography.labelLarge.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          for (final g in games)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: _SamplePlayers(white: g.white, black: g.black),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    g.result,
                    style: ApexTypography.bodyMedium.copyWith(
                      color: ApexColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${g.accuracy.toStringAsFixed(1)}%',
                    style: ApexTypography.monoEval.copyWith(
                      color: ApexColors.sapphireBright,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SamplePlayers extends StatelessWidget {
  const _SamplePlayers({required this.white, required this.black});

  final String white;
  final String black;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ApexSideMarker(side: ApexSideMarkerSide.white, size: 12),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            white,
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textPrimary,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            'vs',
            style: TextStyle(color: ApexColors.textTertiary, fontSize: 11),
          ),
        ),
        const ApexSideMarker(side: ApexSideMarkerSide.black, size: 12),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            black,
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textPrimary,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

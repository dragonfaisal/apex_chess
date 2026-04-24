/// Premium "Import Match" screen — Apex Chess Deep Space Cinematic.
///
/// Inspired by chessplus.pages.dev, rebuilt on top of the Apex design
/// language (`GlassPanel`, Sapphire/Ruby accents, Sora typography).
///
/// Flow:
///   1. User picks a source (Chess.com or Lichess) and types a username.
///   2. Taps "Fetch Games" — controller hits the public API, streams back
///      an `ImportedGame` list.
///   3. Taps any row → [DepthPickerDialog] offers Fast (depth 14) or
///      Quantum Deep (depth 22), both backed by the **local** Stockfish.
///   4. On selection, the PGN runs through `LocalGameAnalyzer` and we
///      push the ReviewScreen on the navigator.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/features/account/domain/apex_account.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/archives/data/archive_save_hook.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/import_match/domain/imported_game.dart';
import 'package:apex_chess/features/import_match/presentation/controllers/import_controller.dart';
import 'package:apex_chess/features/mistake_vault/data/mistake_vault_save_hook.dart';
import 'package:apex_chess/features/import_match/presentation/controllers/recent_searches_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/user_validation/presentation/username_validation_controller.dart';
import 'package:apex_chess/features/user_validation/presentation/widgets/username_validation_pill.dart';
import 'package:apex_chess/features/pgn_review/presentation/views/review_screen.dart';
import 'package:apex_chess/infrastructure/engine/local_game_analyzer.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';
import 'package:apex_chess/shared_ui/widgets/quantum_shatter_loader.dart';

class ImportMatchScreen extends ConsumerStatefulWidget {
  const ImportMatchScreen({super.key});

  @override
  ConsumerState<ImportMatchScreen> createState() =>
      _ImportMatchScreenState();
}

class _ImportMatchScreenState extends ConsumerState<ImportMatchScreen> {
  final _controller = TextEditingController();
  final _usernameFocus = FocusNode();
  final _scrollController = ScrollController();

  // Live-Fetch debounce — 600ms after the user stops typing (or toggles
  // source) we auto-invoke Fetch. Guards:
  //   * Minimum username length so a single keystroke doesn't spam HTTP.
  //   * [_lastAutoKey] dedupes identical (source, username) combos so
  //     a rebuild / source ping-pong can't re-fire the same query.
  //   * Cancelled on submit (Enter), on tapping a recent, on source
  //     toggle (re-scheduled), and on dispose.
  Timer? _autoFetchDebounce;
  String? _lastAutoKey;
  static const Duration _autoFetchWindow = Duration(milliseconds: 600);
  static const int _autoFetchMinLength = 3;

  @override
  void initState() {
    super.initState();
    // Trigger `fetchMore` when the list is near the bottom. Cheap
    // listener — Flutter de-duplicates notifications to each scroll
    // position update, and `fetchMore` itself guards on already-loading.
    _scrollController.addListener(_maybeFetchMore);
    // Prefill from the connected Apex account so returning users don't
    // retype their handle every session. We do this in a post-frame
    // callback so the ref.read happens after widget mount and we can
    // touch the (now-running) controller providers safely.
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillFromAccount());
  }

  void _prefillFromAccount() {
    if (!mounted) return;
    final account = ref.read(accountControllerProvider).valueOrNull;
    if (account == null) return;
    if (_controller.text.isNotEmpty) return;
    final notifier = ref.read(importControllerProvider.notifier);
    final desiredSource = account.source == AccountSource.chessCom
        ? GameSource.chessCom
        : GameSource.lichess;
    if (ref.read(importControllerProvider).source != desiredSource) {
      notifier.setSource(desiredSource);
    }
    _controller.text = account.username;
    _controller.selection = TextSelection.collapsed(
        offset: account.username.length);
    notifier.setUsername(account.username);
    // Seed the dedupe key so the debounce timer doesn't instantly
    // fire on the prefill — user hasn't asked for a fetch yet.
    _lastAutoKey = '${desiredSource.name}:${account.username}';
  }

  @override
  void dispose() {
    _autoFetchDebounce?.cancel();
    _scrollController.removeListener(_maybeFetchMore);
    _scrollController.dispose();
    _usernameFocus.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Schedules an auto-fetch 600ms after the latest typing / source
  /// change. Callers pass the *intended* next username so this works
  /// from both [TextField.onChanged] (before the notifier has been
  /// updated) and source-toggle callbacks.
  void _scheduleAutoFetch({required GameSource source, required String username}) {
    _autoFetchDebounce?.cancel();
    final trimmed = username.trim();
    if (trimmed.length < _autoFetchMinLength) return;
    final key = '${source.name}:$trimmed';
    if (key == _lastAutoKey) return;
    _autoFetchDebounce = Timer(_autoFetchWindow, () {
      // Re-check at fire-time: the user may have cleared or edited the
      // field after the timer was scheduled, or tapped a recent (which
      // drives its own immediate fetch). Bail if state has drifted.
      if (!mounted) return;
      if (_controller.text.trim() != trimmed) return;
      final state = ref.read(importControllerProvider);
      if (state.source != source) return;
      if (state.isLoading) return;
      _lastAutoKey = key;
      ref.read(importControllerProvider.notifier).fetch();
    });
  }

  void _cancelAutoFetch() {
    _autoFetchDebounce?.cancel();
    _autoFetchDebounce = null;
  }

  void _maybeFetchMore() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    // 220px pre-fetch threshold so new cards start loading *before* the
    // user hits the spinner — keeps the feed feeling continuous rather
    // than paged.
    if (pos.pixels >= pos.maxScrollExtent - 220) {
      ref.read(importControllerProvider.notifier).fetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importControllerProvider);
    final notifier = ref.read(importControllerProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAppBar(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 8),
                child: Text(
                  ApexCopy.importSubtitle,
                  textAlign: TextAlign.center,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textTertiary,
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              _SourceToggle(
                source: state.source,
                onChanged: (src) {
                  notifier.setSource(src);
                  // Source change with an existing username is the only
                  // case where the *same* text should trigger a new fetch
                  // — clear the dedupe key so the debounce fires.
                  _lastAutoKey = null;
                  _scheduleAutoFetch(
                      source: src, username: _controller.text);
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _UsernameField(
                  controller: _controller,
                  focusNode: _usernameFocus,
                  onChanged: (v) {
                    notifier.setUsername(v);
                    _scheduleAutoFetch(
                        source: state.source, username: v);
                  },
                  onSubmitted: (v) {
                    // Explicit Enter: fire immediately and cancel the
                    // pending auto-fetch so we don't double-hit the API.
                    _cancelAutoFetch();
                    _lastAutoKey = '${state.source.name}:${v.trim()}';
                    notifier.fetch();
                  },
                  source: state.source,
                  onRecentTapped: (username) {
                    _controller.text = username;
                    _controller.selection = TextSelection.collapsed(
                        offset: username.length);
                    notifier.setUsername(username);
                    _usernameFocus.unfocus();
                    _cancelAutoFetch();
                    _lastAutoKey = '${state.source.name}:$username';
                    notifier.fetch();
                  },
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _FetchButton(
                  isLoading: state.isLoading,
                  onTap: () {
                    _cancelAutoFetch();
                    _lastAutoKey =
                        '${state.source.name}:${_controller.text.trim()}';
                    notifier.fetch();
                  },
                ),
              ),
              const SizedBox(height: 18),
              Expanded(child: _buildBody(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: ApexColors.textSecondary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              ApexCopy.importTitle,
              textAlign: TextAlign.center,
              style: ApexTypography.titleMedium.copyWith(
                color: ApexColors.textPrimary,
                letterSpacing: 3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildBody(ImportState state) {
    if (state.isLoading) {
      return const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
              strokeWidth: 2.4, color: ApexColors.sapphireBright),
        ),
      );
    }
    // Full-screen error is only appropriate when we have nothing to show
    // yet — if a pagination fetch fails *after* a successful first page,
    // we keep the already-loaded games visible and let the footer surface
    // the error inline.
    if (state.errorMessage != null && state.games.isEmpty) {
      return _EmptyState(
        icon: Icons.cloud_off_rounded,
        label: state.errorMessage!,
        accent: ApexColors.ruby,
      );
    }
    if (!state.hasFetched) {
      return const _EmptyState(
        icon: Icons.search_rounded,
        label: 'Pick a source, enter a username, tap Fetch.',
      );
    }
    if (state.games.isEmpty) {
      return const _EmptyState(
        icon: Icons.inbox_rounded,
        label: ApexCopy.importEmpty,
      );
    }
    // +1 row reserved for the footer (loader, inline error, or
    // "end of feed" marker).
    final itemCount = state.games.length + 1;
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
      itemBuilder: (_, i) {
        if (i == state.games.length) {
          return _PaginationFooter(
            isLoading: state.isLoadingMore,
            hasMore: state.hasMore,
            errorMessage: state.errorMessage,
            onRetry: () => ref
                .read(importControllerProvider.notifier)
                .fetchMore(),
          );
        }
        return _GameCard(game: state.games[i]);
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: itemCount,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pagination footer — shown below the last card.
// ─────────────────────────────────────────────────────────────────────────────

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.isLoading,
    required this.hasMore,
    this.errorMessage,
    this.onRetry,
  });

  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    // Inline pagination error — keeps the already-loaded list visible
    // and offers a Retry so a single blip doesn't force a full reset.
    if (errorMessage != null && !isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.ruby,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'RETRY',
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.sapphireBright,
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      );
    }
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ApexColors.sapphireBright,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Loading more games…',
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            '— end of feed —',
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
        ),
      );
    }
    // hasMore but not yet loading — reserve a little space so the
    // scroll-trigger threshold has something to reach.
    return const SizedBox(height: 40);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Source toggle (Chess.com / Lichess)
// ─────────────────────────────────────────────────────────────────────────────

class _SourceToggle extends StatelessWidget {
  const _SourceToggle({required this.source, required this.onChanged});

  final GameSource source;
  final ValueChanged<GameSource> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassPanel(
        padding: const EdgeInsets.all(4),
        margin: null,
        borderRadius: 14,
        accentAlpha: 0.18,
        fillAlpha: 0.38,
        child: Row(
          children: [
            Expanded(
              child: _SourceChip(
                label: ApexCopy.importSourceChessCom,
                active: source == GameSource.chessCom,
                onTap: () => onChanged(GameSource.chessCom),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _SourceChip(
                label: ApexCopy.importSourceLichess,
                active: source == GameSource.lichess,
                onTap: () => onChanged(GameSource.lichess),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: active ? ApexGradients.sapphire : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox(
            height: 38,
            child: Center(
              child: Text(
                label,
                style: ApexTypography.labelLarge.copyWith(
                  letterSpacing: 1.5,
                  fontSize: 12,
                  color: active
                      ? Colors.white
                      : ApexColors.textTertiary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Username field + Fetch button
// ─────────────────────────────────────────────────────────────────────────────

class _UsernameField extends ConsumerStatefulWidget {
  const _UsernameField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.source,
    required this.onRecentTapped,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final GameSource source;
  final ValueChanged<String> onRecentTapped;

  @override
  ConsumerState<_UsernameField> createState() => _UsernameFieldState();
}

class _UsernameFieldState extends ConsumerState<_UsernameField> {
  bool _showDropdown = false;
  UsernameValidationController? _validation;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void didUpdateWidget(covariant _UsernameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _pushValidationInput();
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    _validation?.dispose();
    super.dispose();
  }

  UsernameValidationController _ensureValidation() {
    return _validation ??=
        UsernameValidationController(ref.read(usernameValidatorProvider));
  }

  String get _sourceKey => switch (widget.source) {
        GameSource.chessCom => 'chess.com',
        GameSource.lichess => 'lichess',
      };

  void _pushValidationInput() {
    _ensureValidation().updateInput(
      source: _sourceKey,
      username: widget.controller.text,
    );
  }

  void _onFocusChange() {
    // Only show the dropdown on focus when the field is empty —
    // `_onTextChange` won't fire if the user re-focuses a field that
    // already contained a username, so we have to re-check here too.
    final empty = widget.controller.text.trim().isEmpty;
    setState(() {
      _showDropdown = widget.focusNode.hasFocus && empty;
    });
  }

  void _onTextChange() {
    // Hide the dropdown once the user starts typing a fresh username —
    // the suggestions become noisy mid-typing.
    final empty = widget.controller.text.trim().isEmpty;
    if (_showDropdown != (widget.focusNode.hasFocus && empty)) {
      setState(() {
        _showDropdown = widget.focusNode.hasFocus && empty;
      });
    }
    _pushValidationInput();
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = switch (widget.source) {
      GameSource.chessCom => 'e.g. hikaru',
      GameSource.lichess => 'e.g. DrNykterstein',
    };

    final recents = ref
        .watch(recentSearchesProvider)
        .maybeWhen(
          data: (s) => s.forSource(widget.source),
          orElse: () => const <String>[],
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          textInputAction: TextInputAction.search,
          style: ApexTypography.bodyMedium.copyWith(
            color: ApexColors.textPrimary,
            fontSize: 14,
            fontFamily: 'JetBrains Mono',
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person_outline_rounded,
                color: ApexColors.sapphireBright, size: 20),
            suffixIcon:
                UsernameValidationPill(controller: _ensureValidation()),
            suffixIconConstraints:
                const BoxConstraints(minHeight: 32, minWidth: 0),
            hintText: placeholder,
            hintStyle: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontFamily: 'JetBrains Mono',
            ),
            filled: true,
            fillColor: ApexColors.deepSpace.withValues(alpha: 0.55),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: ApexColors.subtleBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: ApexColors.subtleBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: ApexColors.sapphire.withValues(alpha: 0.55)),
            ),
          ),
        ),
        if (_showDropdown && recents.isNotEmpty)
          _RecentSearchesDropdown(
            entries: recents,
            onTap: widget.onRecentTapped,
            onClear: () => ref
                .read(recentSearchesProvider.notifier)
                .clear(widget.source),
            onRemove: (u) => ref
                .read(recentSearchesProvider.notifier)
                .remove(widget.source, u),
          ),
      ],
    );
  }
}

/// Sapphire-tinted dropdown listing the user's recent successful searches
/// for the active source. Shown below the field while it has focus and is
/// empty. Entries have a swipe-free remove button so the user can prune
/// the list without leaving the screen.
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
                  Icon(Icons.history_rounded,
                      size: 14,
                      color: ApexColors.sapphireBright
                          .withValues(alpha: 0.75)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      'CLEAR',
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
                      horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.person_search_rounded,
                          size: 16,
                          color: ApexColors.textTertiary),
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
                            minWidth: 28, minHeight: 28),
                        icon: Icon(Icons.close_rounded,
                            color: ApexColors.textTertiary
                                .withValues(alpha: 0.7)),
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

class _FetchButton extends StatelessWidget {
  const _FetchButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            gradient: ApexGradients.sapphire,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: ApexColors.sapphire.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: -6,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading) ...[
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                ] else ...[
                  const Icon(Icons.bolt_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                ],
                Text(
                  ApexCopy.importFetch,
                  style: ApexTypography.labelLarge.copyWith(
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Game card
// ─────────────────────────────────────────────────────────────────────────────

class _GameCard extends ConsumerWidget {
  const _GameCard({required this.game});

  final ImportedGame game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accentColor = switch (game.result) {
      GameResult.whiteWon => ApexColors.brilliant,
      GameResult.blackWon => ApexColors.ruby,
      GameResult.draw => ApexColors.textTertiary,
      GameResult.unknown => ApexColors.subtleBorder,
    };
    final outcome = game.userOutcomeLabel;
    final outcomeColor = switch (outcome) {
      'Won' => ApexColors.brilliant,
      'Lost' => ApexColors.ruby,
      'Drew' => ApexColors.textSecondary,
      _ => ApexColors.textTertiary,
    };

    return GlassPanel(
      padding: EdgeInsets.zero,
      margin: null,
      borderRadius: 16,
      accentColor: accentColor,
      accentAlpha: 0.28,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDepthPicker(context, ref),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _SourceBadge(source: game.source),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PlayerRow(
                        name: game.whiteName,
                        rating: game.whiteRating,
                        light: true,
                        isUser: game.userColor == PlayerColor.white,
                      ),
                      const SizedBox(height: 4),
                      _PlayerRow(
                        name: game.blackName,
                        rating: game.blackRating,
                        light: false,
                        isUser: game.userColor == PlayerColor.black,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _MetaPill(icon: Icons.timer_outlined,
                              label: game.timeControl ?? '—'),
                          const SizedBox(width: 6),
                          _MetaPill(icon: Icons.history_rounded,
                              label: '${game.moveCount} moves'),
                          const SizedBox(width: 6),
                          _MetaPill(icon: Icons.calendar_today_outlined,
                              label: game.relativeTime),
                        ],
                      ),
                      if (game.openingName != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${game.eco != null ? '${game.eco} • ' : ''}${game.openingName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ApexTypography.bodyMedium.copyWith(
                            color: ApexColors.book,
                            fontSize: 11,
                            fontFamily: 'JetBrains Mono',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      game.resultLabel,
                      style: ApexTypography.monoEval.copyWith(
                        color: accentColor,
                        fontSize: 17,
                      ),
                    ),
                    if (outcome != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        outcome,
                        style: ApexTypography.bodyMedium.copyWith(
                          color: outcomeColor,
                          fontSize: 10,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openDepthPicker(BuildContext context, WidgetRef ref) async {
    final depth = await showDialog<int>(
      context: context,
      barrierColor: ApexColors.spaceVoid.withValues(alpha: 0.72),
      builder: (_) => const DepthPickerDialog(),
    );
    if (depth == null) return;
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: ApexColors.spaceVoid.withValues(alpha: 0.72),
      builder: (_) => _ImportAnalysisDialog(
        pgn: game.pgn,
        depth: depth,
        source: game.source == GameSource.chessCom
            ? ArchiveSource.chessCom
            : ArchiveSource.lichess,
        playedAt: game.playedAt,
        userIsWhite: game.userColor == null
            ? null
            : game.userColor == PlayerColor.white,
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source});
  final GameSource source;

  @override
  Widget build(BuildContext context) {
    final label = switch (source) {
      GameSource.chessCom => 'CC',
      GameSource.lichess => 'LI',
    };
    final color = switch (source) {
      GameSource.chessCom => const Color(0xFF81B64C),
      GameSource.lichess => const Color(0xFFB8B5AF),
    };
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 0.6),
      ),
      child: Text(
        label,
        style: ApexTypography.monoEval.copyWith(
          color: color, fontSize: 14, fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.name,
    required this.rating,
    required this.light,
    required this.isUser,
  });

  final String name;
  final int? rating;
  final bool light;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final dotColor = light ? Colors.white : ApexColors.trueBlack;
    final dotBorder = light
        ? ApexColors.subtleBorder
        : Colors.white.withValues(alpha: 0.25);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            border: Border.all(color: dotBorder, width: 0.6),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ApexTypography.bodyMedium.copyWith(
              color: isUser ? ApexColors.sapphireBright : ApexColors.textPrimary,
              fontSize: 13,
              fontWeight: isUser ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ),
        if (rating != null) ...[
          const SizedBox(width: 8),
          Text(
            rating.toString(),
            style: ApexTypography.monoEval.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ApexColors.elevatedSurface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: ApexColors.textTertiary, size: 11),
          const SizedBox(width: 4),
          Text(
            label,
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 10,
              fontFamily: 'JetBrains Mono',
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.label,
    this.accent = ApexColors.sapphire,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: accent.withValues(alpha: 0.7), size: 40),
          const SizedBox(height: 14),
          Text(
            label,
            textAlign: TextAlign.center,
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Depth picker dialog — returns the selected depth (14 or 22) via pop.
// ─────────────────────────────────────────────────────────────────────────────

class DepthPickerDialog extends StatelessWidget {
  const DepthPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: GlassPanel.dialog(
        accentColor: ApexColors.sapphire,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.tune_rounded,
                    color: ApexColors.sapphireBright, size: 22),
                const SizedBox(width: 10),
                Text(
                  ApexCopy.depthPickerTitle,
                  style: ApexTypography.titleMedium.copyWith(letterSpacing: 3),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _DepthOption(
              label: ApexCopy.depthFastLabel,
              tag: ApexCopy.depthFastTag,
              blurb: ApexCopy.depthFastBlurb,
              icon: Icons.flash_on_rounded,
              accent: ApexColors.electricBlue,
              onTap: () => Navigator.of(context).pop(14),
            ),
            const SizedBox(height: 12),
            _DepthOption(
              label: ApexCopy.depthDeepLabel,
              tag: ApexCopy.depthDeepTag,
              blurb: ApexCopy.depthDeepBlurb,
              icon: Icons.auto_awesome_rounded,
              accent: ApexColors.sapphire,
              onTap: () => Navigator.of(context).pop(22),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepthOption extends StatelessWidget {
  const _DepthOption({
    required this.label,
    required this.tag,
    required this.blurb,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final String tag;
  final String blurb;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ApexColors.elevatedSurface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accent.withValues(alpha: 0.35), width: 0.6,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flex row: label shrinks with ellipsis before the pill
                    // gets clipped. Previously the bare Text(label) forced
                    // its intrinsic width onto the parent Expanded, which
                    // is what was producing the "RIGHT OVERFLOWED BY 61
                    // PIXELS" warning on narrow phones.
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ApexTypography.labelLarge.copyWith(
                              color: ApexColors.textPrimary,
                              letterSpacing: 1.4,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: ApexTypography.monoEval.copyWith(
                              color: accent, fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      blurb,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ApexTypography.bodyMedium.copyWith(
                        color: ApexColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded,
                  color: accent.withValues(alpha: 0.8)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Analysis progress dialog (shared with Home's PGN flow).
// ─────────────────────────────────────────────────────────────────────────────

class _ImportAnalysisDialog extends ConsumerStatefulWidget {
  const _ImportAnalysisDialog({
    required this.pgn,
    required this.depth,
    required this.source,
    this.playedAt,
    this.userIsWhite,
  });
  final String pgn;
  final int depth;
  final ArchiveSource source;
  final DateTime? playedAt;
  /// Null when we don't know which colour the user played (PGN
  /// uploads). The Mistake Vault hook uses this to skip opponent plies.
  final bool? userIsWhite;

  @override
  ConsumerState<_ImportAnalysisDialog> createState() =>
      _ImportAnalysisDialogState();
}

class _ImportAnalysisDialogState
    extends ConsumerState<_ImportAnalysisDialog> {
  int _completed = 0;
  int _total = 1;
  bool _done = false;
  // Guards the post-frame navigation callback so it is enqueued at most once,
  // even if build() runs multiple times before the callback fires. Without
  // this, an ancestor rebuild between `_done = true` and the next frame would
  // queue a second pop→push pair and tear down the freshly-pushed review.
  bool _navigated = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    try {
      final analyzer = ref.read(gameAnalyzerProvider);
      final timeline = await analyzer.analyzeFromPgn(
        widget.pgn,
        depth: widget.depth,
        onProgress: (c, t) {
          if (!mounted) return;
          setState(() {
            _completed = c;
            _total = t;
          });
        },
      );
      if (!mounted) return;
      ref.read(reviewControllerProvider.notifier).loadTimeline(timeline);
      // Fire-and-forget save — failures never block the review flow.
      final archiveId = await saveAnalysisToArchive(
        ref: ref,
        timeline: timeline,
        pgn: widget.pgn,
        depth: widget.depth,
        source: widget.source,
        playedAt: widget.playedAt,
      );
      if (archiveId != null) {
        unawaited(saveMistakeDrillsFromTimeline(
          ref: ref,
          timeline: timeline,
          archiveId: archiveId,
          userIsWhite: widget.userIsWhite,
        ));
      }
      if (!mounted) return;
      setState(() => _done = true);
    } on LocalAnalysisException catch (e) {
      if (mounted) setState(() => _error = e.userMessage);
    } catch (_) {
      if (mounted) setState(() => _error = ApexCopy.analysisFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done && !_navigated) {
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ReviewScreen()),
        );
      });
    }

    final progress = _total > 0 ? _completed / _total : 0.0;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: GlassPanel.dialog(
        accentColor: _error == null ? ApexColors.sapphire : ApexColors.ruby,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  _error == null
                      ? Icons.auto_awesome_rounded
                      : Icons.error_outline_rounded,
                  color: _error == null
                      ? ApexColors.sapphireBright
                      : ApexColors.ruby,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  _error == null
                      ? '${ApexCopy.scanHeader(widget.depth)} · D${widget.depth}'
                      : 'Scan failed',
                  style: ApexTypography.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (_error != null) ...[
              Text(
                _error!,
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.ruby,
                ),
              ),
              const SizedBox(height: 16),
              // CLOSE escape hatch — without this the dialog is
              // undismissable when an analysis failure puts us in the
              // error branch (barrierDismissible: false).
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'CLOSE',
                    style: ApexTypography.labelLarge.copyWith(
                      color: ApexColors.sapphire,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Radar sweep behind the progress readout gives the user an
              // immediate visual signal that the engine is *actually
              // working* — the sweep rotates independently of the
              // progress ticks, so a frozen engine is obvious.
              SizedBox(
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const QuantumShatterLoader(size: 220),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: ApexTypography.displayLarge.copyWith(
                            fontSize: 38,
                            color: ApexColors.sapphireBright,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'QUANTUM SCAN',
                          style: ApexTypography.bodyMedium.copyWith(
                            color: ApexColors.textTertiary,
                            fontSize: 10,
                            letterSpacing: 3.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor:
                      ApexColors.deepSpace.withValues(alpha: 0.65),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      ApexColors.sapphireBright),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$_completed / $_total plies',
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary,
                  fontFamily: 'JetBrains Mono',
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

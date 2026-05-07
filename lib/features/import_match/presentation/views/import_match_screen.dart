/// Import Games screen.
///
/// Flow:
///   1. User picks a source (Chess.com or Lichess) and types a handle.
///   2. The username-validation controller pings the public profile
///      endpoint; the pill turns green the instant the handle resolves.
///   3. Auto-fetch then fires after verification.
///   4. Tapping any row opens [DepthPickerDialog] (Fast, Deep, or Offline).
///   5. On selection, the PGN runs through `LocalGameAnalyzer` and we
///      push the ReviewScreen on the navigator.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/features/account/domain/apex_account.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/archives/data/archive_save_hook.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/import_match/domain/imported_game.dart';
import 'package:apex_chess/features/import_match/presentation/controllers/import_controller.dart';
import 'package:apex_chess/features/import_match/presentation/models/import_discovery_display.dart';
import 'package:apex_chess/features/import_match/presentation/models/imported_game_card_display.dart';
import 'package:apex_chess/features/home/presentation/controllers/home_activity_controller.dart';
import 'package:apex_chess/features/mistake_vault/data/mistake_vault_save_hook.dart';
import 'package:apex_chess/features/import_match/presentation/controllers/recent_searches_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/pgn_review/domain/review_analysis_provider.dart';
import 'package:apex_chess/features/user_validation/presentation/username_validation_controller.dart';
import 'package:apex_chess/features/user_validation/presentation/widgets/username_validation_pill.dart';
import 'package:apex_chess/features/pgn_review/presentation/views/review_summary_screen.dart';
import 'package:apex_chess/infrastructure/engine/local_game_analyzer.dart';
import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_loading.dart';
import 'package:apex_chess/shared_ui/widgets/apex_game_card.dart';
import 'package:apex_chess/shared_ui/widgets/apex_snack.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';

class ImportMatchScreen extends ConsumerStatefulWidget {
  const ImportMatchScreen({super.key});

  @override
  ConsumerState<ImportMatchScreen> createState() => _ImportMatchScreenState();
}

class _ImportMatchScreenState extends ConsumerState<ImportMatchScreen> {
  final _controller = TextEditingController();
  final _gameFilterController = TextEditingController();
  final _usernameFocus = FocusNode();
  final _scrollController = ScrollController();
  String _gameFilter = '';

  // Live-Fetch debounce — 600 ms after the username-validation pill
  // confirms the handle exists we auto-invoke Fetch. Guards:
  //   * Only fires on verification success (green pill), not on raw
  //     keystrokes, so we never hit the games API for typos.
  //   * [_lastAutoKey] dedupes identical (source, username) combos so
  //     a rebuild / source ping-pong can't re-fire the same query.
  //   * Cancelled on submit (Enter), on tapping a recent, on source
  //     toggle, and on dispose.
  Timer? _autoFetchDebounce;
  Timer? _gameFilterDebounce;
  String? _lastAutoKey;
  bool _hadConnectionIssue = false;
  int? _gameFilterBaselineCount;
  String _gameFilterBaselineQuery = '';
  static const Duration _autoFetchWindow = Duration(milliseconds: 600);
  static const Duration _gameFilterWindow = Duration(milliseconds: 240);

  @override
  void initState() {
    super.initState();
    // Trigger `fetchMore` when the list is near the bottom. Cheap
    // listener — Flutter de-duplicates notifications to each scroll
    // position update, and `fetchMore` itself guards on already-loading.
    _scrollController.addListener(_maybeFetchMore);
    _gameFilterController.addListener(_onGameFilterChanged);
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
    _applyConnectedAccount(account);
  }

  void _applyConnectedAccount(ApexAccount account, {ApexAccount? previous}) {
    final current = _controller.text.trim();
    final previousName = previous?.username.trim().toLowerCase();
    final canOverwrite =
        current.isEmpty ||
        (previousName != null && current.toLowerCase() == previousName);
    if (!canOverwrite) return;
    final notifier = ref.read(importControllerProvider.notifier);
    final desiredSource = account.source == AccountSource.chessCom
        ? GameSource.chessCom
        : GameSource.lichess;
    if (ref.read(importControllerProvider).source != desiredSource) {
      notifier.setSource(desiredSource);
    }
    _controller.text = account.username;
    _controller.selection = TextSelection.collapsed(
      offset: account.username.length,
    );
    notifier.setUsername(account.username);
    // Seed the dedupe key so the debounce timer doesn't instantly
    // fire on the prefill — user hasn't asked for a fetch yet.
    _lastAutoKey = '${desiredSource.name}:${account.username}';
  }

  void _onImportStateChanged(ImportState? previous, ImportState next) {
    if (!mounted) return;
    final error = next.errorMessage;
    if (error != null && error != previous?.errorMessage) {
      final presence = ref.read(connectionPresenceProvider);
      _hadConnectionIssue = presence.isOffline;
      if (presence.isOffline && next.games.isNotEmpty) {
        _showApexSnack(
          ApexCopy.offline,
          detail: ApexCopy.showingSavedData,
          color: ApexColors.inaccuracy,
        );
      }
      return;
    }
    final finishedFetch =
        previous?.isLoading == true &&
        !next.isLoading &&
        next.errorMessage == null &&
        next.hasFetched &&
        next.games.isNotEmpty;
    if (_hadConnectionIssue && finishedFetch) {
      _hadConnectionIssue = false;
      final shouldNotify = ref
          .read(connectionPresenceProvider.notifier)
          .markSynced();
      if (shouldNotify) _showApexSnack(ApexCopy.synced, color: ApexColors.best);
    }
  }

  void _showApexSnack(String message, {String? detail, required Color color}) {
    showApexSnack(context, message: message, detail: detail, color: color);
  }

  @override
  void dispose() {
    _autoFetchDebounce?.cancel();
    _gameFilterDebounce?.cancel();
    _scrollController.removeListener(_maybeFetchMore);
    _scrollController.dispose();
    _usernameFocus.dispose();
    _gameFilterController.removeListener(_onGameFilterChanged);
    _gameFilterController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onGameFilterChanged() {
    _gameFilterDebounce?.cancel();
    _gameFilterDebounce = Timer(_gameFilterWindow, () {
      if (!mounted) return;
      final query = _gameFilterController.text.trim();
      setState(() {
        _gameFilter = _gameFilterController.text;
        if (query.isEmpty) {
          _gameFilterBaselineCount = null;
          _gameFilterBaselineQuery = '';
        } else if (query.toLowerCase() != _gameFilterBaselineQuery) {
          _gameFilterBaselineQuery = query.toLowerCase();
          _gameFilterBaselineCount = ref
              .read(importControllerProvider)
              .games
              .length;
        }
      });
    });
  }

  /// Schedules an auto-fetch 600 ms *after the username-validation
  /// controller has confirmed the handle exists*. We never fire on raw
  /// keystrokes anymore — verifying first means zero wasted requests
  /// on typos. Callers pass the verified handle so the dedupe key
  /// reflects the exact string that resolved.
  void _scheduleAutoFetchAfterVerification({
    required GameSource source,
    required String username,
  }) {
    _autoFetchDebounce?.cancel();
    final trimmed = username.trim();
    if (trimmed.isEmpty) return;
    final key = '${source.name}:$trimmed';
    if (key == _lastAutoKey) return;
    _autoFetchDebounce = Timer(_autoFetchWindow, () {
      // Re-check at fire-time: the user may have cleared or edited the
      // field after verification, or tapped a recent (which drives its
      // own immediate fetch). Bail if state has drifted.
      if (!mounted) return;
      if (_controller.text.trim() != trimmed) return;
      final state = ref.read(importControllerProvider);
      if (state.source != source) return;
      if (state.isLoading) return;
      _lastAutoKey = key;
      _clearGameFilter();
      _fetchNow();
    });
  }

  void _cancelAutoFetch() {
    _autoFetchDebounce?.cancel();
    _autoFetchDebounce = null;
  }

  void _fetchNow() {
    ref.read(importControllerProvider.notifier).fetch();
  }

  void _fetchMoreNow() {
    ref.read(importControllerProvider.notifier).fetchMore();
  }

  void _clearGameFilter() {
    _gameFilterDebounce?.cancel();
    _gameFilterController.clear();
    if (_gameFilter.isNotEmpty) {
      setState(() {
        _gameFilter = '';
        _gameFilterBaselineQuery = '';
        _gameFilterBaselineCount = null;
      });
    }
  }

  void _maybeFetchMore() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    // 220px pre-fetch threshold so new cards start loading *before* the
    // user hits the spinner — keeps the feed feeling continuous rather
    // than paged.
    if (pos.pixels >= pos.maxScrollExtent - 220) {
      _fetchMoreNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ImportState>(importControllerProvider, _onImportStateChanged);
    ref.listen(accountControllerProvider, (previous, next) {
      final account = next.valueOrNull;
      if (account == null) return;
      _applyConnectedAccount(account, previous: previous?.valueOrNull);
    });
    final state = ref.watch(importControllerProvider);
    final notifier = ref.read(importControllerProvider.notifier);

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
        child: SafeArea(
          child: RefreshIndicator(
            color: ApexColors.sapphireBright,
            backgroundColor: ApexColors.nebula,
            onRefresh: () async {
              await ref
                  .read(connectionPresenceProvider.notifier)
                  .refresh(showSyncing: true);
              if (ref.read(importControllerProvider).hasFetched) {
                _fetchNow();
              }
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
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
                          ),
                        ),
                      ),
                      _SourceToggle(
                        source: state.source,
                        onChanged: (src) {
                          notifier.setSource(src);
                          _cancelAutoFetch();
                          _lastAutoKey = null;
                          _clearGameFilter();
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
                            _cancelAutoFetch();
                          },
                          onSubmitted: (v) {
                            _cancelAutoFetch();
                            _lastAutoKey = '${state.source.name}:${v.trim()}';
                            _clearGameFilter();
                            _fetchNow();
                          },
                          onVerified: (v) {
                            _scheduleAutoFetchAfterVerification(
                              source: state.source,
                              username: v,
                            );
                          },
                          source: state.source,
                          onRecentTapped: (username) {
                            _controller.text = username;
                            _controller.selection = TextSelection.collapsed(
                              offset: username.length,
                            );
                            notifier.setUsername(username);
                            _usernameFocus.unfocus();
                            _cancelAutoFetch();
                            _lastAutoKey = '${state.source.name}:$username';
                            _clearGameFilter();
                            _fetchNow();
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      _AutoFetchStatus(state: state),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
                ..._buildBodySlivers(state, _gameFilter),
                SliverToBoxAdapter(child: SizedBox(height: bottomInset + 24)),
              ],
            ),
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
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: ApexColors.textSecondary,
            ),
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

  List<Widget> _buildBodySlivers(ImportState state, String filterQuery) {
    if (state.isLoading) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ApexLoadingScaffold(
            title: 'Fetching recent games',
            messages: ['Fetching recent games...', 'Loading game list...'],
            compact: true,
          ),
        ),
      ];
    }
    // Full-screen error is only appropriate when we have nothing to show
    // yet — if a pagination fetch fails *after* a successful first page,
    // we keep the already-loaded games visible and let the footer surface
    // the error inline.
    if (state.errorMessage != null && state.games.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptyState(
            icon: Icons.cloud_off_rounded,
            label: state.emptyErrorMessage ?? ApexCopy.noConnection,
            accent: ApexColors.ruby,
          ),
        ),
      ];
    }
    final discovery = ImportDiscoveryDisplay.from(
      state: state,
      query: filterQuery,
      searchBaselineCount: _gameFilterBaselineCount,
    );
    if (discovery.emptyState == ImportDiscoveryEmptyState.notFetched) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptyState(
            icon: Icons.search_rounded,
            label: discovery.emptyLabel,
          ),
        ),
      ];
    }
    if (discovery.emptyState == ImportDiscoveryEmptyState.noGames) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptyState(
            icon: Icons.inbox_rounded,
            label: discovery.emptyLabel,
          ),
        ),
      ];
    }
    final visibleGames = discovery.games;
    final isFiltering = discovery.isFiltering;
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
          child: _LoadedGamesFilterField(controller: _gameFilterController),
        ),
      ),
      if (visibleGames.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptyState(
            icon: Icons.manage_search_rounded,
            label: discovery.emptyLabel,
            actionLabel: discovery.showSearchOlderAction
                ? ApexCopy.searchOlderGames
                : null,
            isLoading: discovery.showSearchingOlder,
            onAction: discovery.showSearchOlderAction ? _fetchMoreNow : null,
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
          sliver: SliverList.separated(
            itemBuilder: (_, i) {
              if (!isFiltering && i == visibleGames.length) {
                return _PaginationFooter(
                  isLoading: state.isLoadingMore,
                  hasMore: state.hasMore,
                  errorMessage: state.errorMessage,
                  onRetry: _fetchMoreNow,
                );
              }
              return _GameCard(
                game: visibleGames[i],
                filterQuery: _gameFilter,
                connectedHandle: state.username,
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: visibleGames.length + (isFiltering ? 0 : 1),
          ),
        ),
    ];
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
                  color: active ? Colors.white : ApexColors.textTertiary,
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
    required this.onVerified,
    required this.source,
    required this.onRecentTapped,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  /// Fires when the validation pill confirms the handle exists on the
  /// current provider. Parent uses this to schedule the auto-fetch.
  final ValueChanged<String> onVerified;
  final GameSource source;
  final ValueChanged<String> onRecentTapped;

  @override
  ConsumerState<_UsernameField> createState() => _UsernameFieldState();
}

class _UsernameFieldState extends ConsumerState<_UsernameField> {
  bool _showDropdown = false;
  UsernameValidationController? _validation;
  String? _lastVerifiedQuery;

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
      // Source toggle → re-validate against the new provider; forget the
      // previous verification so auto-fetch will re-arm on success.
      _lastVerifiedQuery = null;
      _pushValidationInput();
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    _validation?.removeListener(_onValidationChange);
    _validation?.dispose();
    super.dispose();
  }

  UsernameValidationController _ensureValidation() {
    final existing = _validation;
    if (existing != null) return existing;
    final created = UsernameValidationController(
      ref.read(usernameValidatorProvider),
    );
    created.addListener(_onValidationChange);
    _validation = created;
    return created;
  }

  void _onValidationChange() {
    final v = _validation;
    if (v == null) return;
    // Fire exactly once per (source, username) verification success.
    if (!v.value.isGreen) return;
    final verified = v.value.query;
    if (verified.isEmpty) return;
    if (verified == _lastVerifiedQuery) return;
    _lastVerifiedQuery = verified;
    widget.onVerified(verified);
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
    setState(() {
      _showDropdown = widget.focusNode.hasFocus && empty;
    });
    _pushValidationInput();
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = switch (widget.source) {
      GameSource.chessCom => 'Search Chess.com username',
      GameSource.lichess => 'Search Lichess username',
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
          cursorColor: ApexColors.sapphireBright,
          autofillHints: const [],
          enableSuggestions: false,
          autocorrect: false,
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
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                UsernameValidationPill(controller: _ensureValidation()),
                if (widget.controller.text.isNotEmpty)
                  IconButton(
                    tooltip: ApexCopy.clear,
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged('');
                      _lastVerifiedQuery = null;
                    },
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
                color: ApexColors.sapphire.withValues(alpha: 0.55),
              ),
            ),
          ),
        ),
        if (_showDropdown && recents.isNotEmpty)
          _RecentSearchesDropdown(
            entries: recents,
            onTap: widget.onRecentTapped,
            onClear: () =>
                ref.read(recentSearchesProvider.notifier).clear(widget.source),
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
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
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

/// Status strip that replaced the old "Fetch Games" button. Shows a
/// subtle sapphire progress line while a fetch is in flight and a
/// muted hint otherwise so the user understands ingestion is automatic.
class _AutoFetchStatus extends StatelessWidget {
  const _AutoFetchStatus({required this.state});

  final ImportState state;

  @override
  Widget build(BuildContext context) {
    final isLoading = state.isLoading;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: isLoading
                ? const ApexPulseLoader(size: 14)
                : const Icon(
                    Icons.search_rounded,
                    size: 14,
                    color: ApexColors.sapphireBright,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isLoading ? 'Fetching recent games...' : ApexCopy.importAutoFetch,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textTertiary,
                fontSize: 12,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadedGamesFilterField extends StatelessWidget {
  const _LoadedGamesFilterField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          cursorColor: ApexColors.sapphireBright,
          autofillHints: const [],
          enableSuggestions: false,
          autocorrect: false,
          style: ApexTypography.bodyMedium.copyWith(
            color: ApexColors.textPrimary,
            fontSize: 13,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.manage_search_rounded,
              color: ApexColors.sapphireBright,
              size: 19,
            ),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: ApexCopy.clear,
                    onPressed: controller.clear,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: ApexColors.textTertiary,
                      size: 18,
                    ),
                  ),
            hintText: ApexCopy.searchOpponentOpening,
            hintStyle: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
            ),
            filled: true,
            fillColor: ApexColors.deepSpace.withValues(alpha: 0.48),
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
                color: ApexColors.sapphire.withValues(alpha: 0.55),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Game card
// ─────────────────────────────────────────────────────────────────────────────

class _GameCard extends ConsumerWidget {
  const _GameCard({
    required this.game,
    required this.filterQuery,
    required this.connectedHandle,
  });

  final ImportedGame game;
  final String filterQuery;
  final String connectedHandle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchLabel = game.localFilterMatchLabel(
      filterQuery,
      connectedHandle: connectedHandle,
    );
    return ApexGameCard(
      model: game.toApexGameCardDisplay(),
      onTap: () => _openDepthPicker(context, ref),
      trailing: matchLabel == null ? null : _SearchMatchPill(label: matchLabel),
      actions: [
        _ReviewModeAction(
          label: 'Fast',
          icon: Icons.flash_on_rounded,
          onTap: () => _startAnalysis(context, ref, AnalysisProfile.fastReview),
        ),
        _ReviewModeAction(
          label: 'Deep',
          icon: Icons.auto_awesome_rounded,
          onTap: () => _startAnalysis(context, ref, AnalysisProfile.deepReview),
        ),
      ],
    );
  }

  Future<void> _openDepthPicker(BuildContext context, WidgetRef ref) async {
    final profile = await showDialog<AnalysisProfile>(
      context: context,
      barrierColor: ApexColors.spaceVoid.withValues(alpha: 0.72),
      builder: (_) => const DepthPickerDialog(),
    );
    if (profile == null) return;
    if (!context.mounted) return;
    _startAnalysis(context, ref, profile);
  }

  void _startAnalysis(
    BuildContext context,
    WidgetRef ref,
    AnalysisProfile profile,
  ) {
    unawaited(
      ref.read(homeActivityControllerProvider.notifier).recordImportReview(),
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: ApexColors.spaceVoid.withValues(alpha: 0.72),
      builder: (_) => _ImportAnalysisDialog(
        pgn: game.pgn,
        profile: profile,
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

class _SearchMatchPill extends StatelessWidget {
  const _SearchMatchPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('import-search-match-pill'),
      constraints: const BoxConstraints(maxWidth: 126),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: ApexColors.sapphire.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: ApexColors.sapphireBright.withValues(alpha: 0.22),
          width: 0.55,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: ApexTypography.bodyMedium.copyWith(
          color: ApexColors.textTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ReviewModeAction extends StatelessWidget {
  const _ReviewModeAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        foregroundColor: ApexColors.sapphireBright,
        side: BorderSide(
          color: ApexColors.sapphire.withValues(alpha: 0.45),
          width: 0.7,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.label,
    this.accent = ApexColors.sapphire,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;

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
          if (isLoading) ...[
            const SizedBox(height: 14),
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ApexColors.sapphireBright,
              ),
            ),
          ] else if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 10),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Review profile picker.
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
                Icon(
                  Icons.tune_rounded,
                  color: ApexColors.sapphireBright,
                  size: 22,
                ),
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
              onTap: () =>
                  Navigator.of(context).pop(AnalysisProfile.fastReview),
            ),
            const SizedBox(height: 12),
            _DepthOption(
              label: ApexCopy.depthDeepLabel,
              tag: ApexCopy.depthDeepTag,
              blurb: ApexCopy.depthDeepBlurb,
              icon: Icons.auto_awesome_rounded,
              accent: ApexColors.sapphire,
              onTap: () =>
                  Navigator.of(context).pop(AnalysisProfile.deepReview),
            ),
            const SizedBox(height: 12),
            _DepthOption(
              label: ApexCopy.depthOfflineLabel,
              tag: ApexCopy.depthOfflineTag,
              blurb: ApexCopy.depthOfflineBlurb,
              icon: Icons.offline_bolt_rounded,
              accent: ApexColors.aurora,
              onTap: () =>
                  Navigator.of(context).pop(AnalysisProfile.offlineReview),
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
              color: accent.withValues(alpha: 0.35),
              width: 0.6,
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
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: ApexTypography.monoEval.copyWith(
                              color: accent,
                              fontSize: 10,
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
              Icon(
                Icons.chevron_right_rounded,
                color: accent.withValues(alpha: 0.8),
              ),
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
    required this.profile,
    required this.source,
    this.playedAt,
    this.userIsWhite,
  });
  final String pgn;
  final AnalysisProfile profile;
  final ArchiveSource source;
  final DateTime? playedAt;

  /// Null when we don't know which colour the user played (PGN
  /// uploads). The Mistake Vault hook uses this to skip opponent plies.
  final bool? userIsWhite;

  @override
  ConsumerState<_ImportAnalysisDialog> createState() =>
      _ImportAnalysisDialogState();
}

class _ImportAnalysisDialogState extends ConsumerState<_ImportAnalysisDialog> {
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
      final pipeline = await ref.read(reviewAnalysisPipelineProvider.future);
      final result = await pipeline.analyzeGame(
        GameReviewRequest(
          pgn: widget.pgn,
          profile: widget.profile,
          userIsWhite: widget.userIsWhite,
          onProgress: (c, t) {
            if (!mounted) return;
            setState(() {
              _completed = c;
              _total = t;
            });
          },
        ),
      );
      final timeline = result.timeline;
      final mode = widget.profile.id == AnalysisProfileId.fastReview
          ? AnalysisMode.quick
          : AnalysisMode.deep;
      final depth = result.metadata.depth;
      if (!mounted) return;
      // Phase A integration audit: if the imported user played as Black,
      // flip the board automatically so they appear at the bottom of the
      // review screen. `userIsWhite == false` means the imported game's
      // user is the Black side; `null` falls back to White-at-bottom for
      // raw PGN imports where user colour is unknowable.
      ref
          .read(reviewControllerProvider.notifier)
          .loadTimeline(
            timeline,
            userIsBlack: widget.userIsWhite == false,
            mode: mode,
            userIsWhite: widget.userIsWhite,
          );
      // Fire-and-forget save — failures never block the review flow.
      final archiveId = await saveAnalysisToArchive(
        ref: ref,
        timeline: timeline,
        pgn: widget.pgn,
        depth: depth,
        source: widget.source,
        playedAt: widget.playedAt,
        analysisMode: mode,
      );
      if (archiveId != null) {
        unawaited(
          saveMistakeDrillsFromTimeline(
            ref: ref,
            timeline: timeline,
            archiveId: archiveId,
            userIsWhite: widget.userIsWhite,
          ),
        );
      }
      unawaited(
        ref
            .read(homeActivityControllerProvider.notifier)
            .markCompleted(HomeActivityKind.importGame),
      );
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
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ReviewSummaryScreen()));
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
                  _error == null ? widget.profile.label : 'Scan failed',
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
            ] else
              ApexLoadingScaffold(
                title: widget.profile.label,
                messages: const [
                  'Reading PGN...',
                  'Checking opening...',
                  'Building review...',
                  'Analyzing tactics...',
                  'Saving review...',
                ],
                progress: progress,
                progressMessage: '$_completed / $_total plies analyzed',
                compact: true,
              ),
          ],
        ),
      ),
    );
  }
}

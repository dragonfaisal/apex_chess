/// Archive — saved review list with filters.
///
/// Reads from [archiveControllerProvider] and renders a compact list of
/// previously analyzed games. Each row opens [ReviewScreen] from the
/// cached timeline when available, or replays the persisted PGN locally.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/presentation/controllers/archive_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/pgn_review/domain/review_analysis_provider.dart';
import 'package:apex_chess/features/pgn_review/domain/review_summary.dart';
import 'package:apex_chess/features/pgn_review/presentation/views/review_summary_screen.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_loading.dart';
import 'package:apex_chess/shared_ui/widgets/apex_snack.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';

class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({
    super.key,
    this.showBackButton = true,
    this.initialFilters,
  });

  final bool showBackButton;
  final ArchiveFilters? initialFilters;

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  bool _appliedInitialFilters = false;

  @override
  Widget build(BuildContext context) {
    if (!_appliedInitialFilters && widget.initialFilters != null) {
      _appliedInitialFilters = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(archiveControllerProvider.notifier)
            .setFilters(widget.initialFilters!);
      });
    }
    final state = ref.watch(archiveControllerProvider);
    final visible = state.visible;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                gamesCount: state.games.length,
                brilliants: state.totalBrilliants,
                blunders: state.totalBlunders,
                showBackButton: widget.showBackButton,
              ),
              _FilterBar(filters: state.filters),
              const SizedBox(height: 4),
              Expanded(child: _buildBody(context, ref, state, visible)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ArchiveState state,
    List<ArchivedGame> visible,
  ) {
    if (state.isLoading) {
      return const Center(
        child: ApexLoadingScaffold(
          title: 'Loading archive',
          messages: ['Loading saved reviews...'],
          compact: true,
        ),
      );
    }
    if (state.error != null) {
      return _EmptyState(
        icon: Icons.error_outline_rounded,
        label: state.error!,
        accent: ApexColors.ruby,
      );
    }
    if (state.games.isEmpty) {
      return const _EmptyState(
        icon: Icons.inventory_2_outlined,
        label: 'No saved reviews yet. Run a review and it will appear here.',
      );
    }
    if (visible.isEmpty) {
      return _FilterEmptyState(
        onClear: () =>
            ref.read(archiveControllerProvider.notifier).clearFilters(),
      );
    }
    final account = ref.watch(accountControllerProvider).valueOrNull;
    final handle = account?.username.trim().toLowerCase();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
      itemBuilder: (_, i) => _ArchiveCard(
        game: visible[i],
        // `null` if no account is connected — card falls back to a
        // "White vs Black" layout without a user perspective.
        userHandle: handle,
        onTap: () => _openArchivedGame(context, ref, visible[i]),
        onDelete: () =>
            ref.read(archiveControllerProvider.notifier).remove(visible[i].id),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: visible.length,
    );
  }

  Future<void> _openArchivedGame(
    BuildContext context,
    WidgetRef ref,
    ArchivedGame game,
  ) async {
    // Phase 6 instant-reopen: if the saved record carries a *current*
    // cached timeline, push the review screen straight away without
    // spawning the engine. Phase A audit: stale-cache invalidation —
    // when the classifier brain has changed under our feet, force a
    // re-scan rather than show counts produced by the old brain.
    final cached = game.cachedTimeline;
    final userIsBlack = _userIsBlack(ref, game);
    // `userIsWhite` for the coach service: if the archive row knows
    // which colour the user played, pass the opposite of `userIsBlack`;
    // otherwise stay `null` so the coach copy falls back to the
    // unknown-side phrasing.
    final bool? userIsWhite = _userColorKnown(ref, game) ? !userIsBlack : null;
    if (game.isCacheCurrent && cached != null && cached.moves.isNotEmpty) {
      ref
          .read(reviewControllerProvider.notifier)
          .loadTimeline(
            cached,
            userIsBlack: userIsBlack,
            mode: _modeForProfile(game.analysisProfileId),
            userIsWhite: userIsWhite,
          );
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ReviewSummaryScreen()),
      );
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final toastBottomMargin = MediaQuery.paddingOf(context).bottom + 78;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ReanalysisDialog(),
    );
    try {
      final pipeline = await ref.read(reviewAnalysisPipelineProvider.future);
      final result = await pipeline.analyzeGame(
        GameReviewRequest(
          pgn: game.pgn,
          profile: game.analysisProfile,
          userIsWhite: userIsWhite,
        ),
      );
      final timeline = result.timeline;
      final mode = _modeForProfile(game.analysisProfileId);
      ref
          .read(reviewControllerProvider.notifier)
          .loadTimeline(
            timeline,
            userIsBlack: userIsBlack,
            mode: mode,
            userIsWhite: userIsWhite,
          );
      // Persist the freshly-computed timeline back onto the archive
      // record so the *next* reopen is instant — even when the user's
      // archive predates Phase 6 and was originally saved without a
      // cached timeline.
      try {
        await ref
            .read(archiveControllerProvider.notifier)
            .updateCachedTimeline(game.id, timeline);
      } catch (_) {
        /* persistence is best-effort */
      }
      if (!navigator.mounted) return;
      navigator.pop();
      navigator.push(
        MaterialPageRoute<void>(builder: (_) => const ReviewSummaryScreen()),
      );
    } catch (e) {
      if (!navigator.mounted) return;
      navigator.pop();
      showApexGlassToastOnMessenger(
        messenger,
        bottomMargin: toastBottomMargin,
        message: ApexCopy.tryAgain,
        type: ApexGlassToastType.warning,
      );
    }
  }

  /// Did the imported user play this game as Black? Compares the
  /// connected account's username against the PGN's `Black` header
  /// (case-insensitive). Falls back to `false` (White-at-bottom) when
  /// no account is connected — same default as a raw PGN import.
  static bool _userIsBlack(WidgetRef ref, ArchivedGame game) {
    final account = ref.read(accountControllerProvider).valueOrNull;
    final me = account?.username.trim().toLowerCase();
    if (me == null || me.isEmpty) return false;
    return game.black.trim().toLowerCase() == me;
  }

  /// Did we match the connected handle against either side? When
  /// `false` the coach card should render the "unknown side" copy
  /// variants instead of attributing "Allowed forced mate" blame to
  /// a colour we only guessed at.
  static bool _userColorKnown(WidgetRef ref, ArchivedGame game) {
    final account = ref.read(accountControllerProvider).valueOrNull;
    final me = account?.username.trim().toLowerCase();
    if (me == null || me.isEmpty) return false;
    return game.white.trim().toLowerCase() == me ||
        game.black.trim().toLowerCase() == me;
  }

  static AnalysisMode _modeForProfile(String profileId) {
    return profileId == 'fast_review' ? AnalysisMode.quick : AnalysisMode.deep;
  }
}

// ── Header ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.gamesCount,
    required this.brilliants,
    required this.blunders,
    required this.showBackButton,
  });

  final int gamesCount;
  final int brilliants;
  final int blunders;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ApexColors.textPrimary,
                size: 18,
              ),
            )
          else
            const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ApexCopy.archivesTitle,
                  style: ApexTypography.headlineMedium.copyWith(
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$gamesCount saved reviews · $brilliants Brilliant · $blunders Blunder',
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
      ),
    );
  }
}

// ── Filter bar ───────────────────────────────────────────────────────

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filters});
  final ArchiveFilters filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ArchiveSearchField(current: filters.search),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: _sortLabel(filters.sort),
                  icon: Icons.sort_rounded,
                  selected: filters.sort != ArchiveSort.newest,
                  onTap: () => _showSortSheet(context, ref),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: _sourceLabel(filters.source),
                  icon: Icons.cloud_outlined,
                  selected: filters.source != null,
                  onTap: () => _showSourceSheet(context, ref),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: _modeLabel(filters.mode),
                  icon: Icons.flash_on_rounded,
                  selected: filters.mode != ArchiveModeFilter.any,
                  onTap: () => _showModeSheet(context, ref),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: _colorLabel(filters.color),
                  icon: Icons.swap_vert_rounded,
                  selected: filters.color != ArchiveColorFilter.any,
                  onTap: () => _showColorSheet(context, ref),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: _resultLabel(filters.result),
                  icon: Icons.flag_outlined,
                  selected: filters.result != ArchiveResultFilter.any,
                  onTap: () => _showResultSheet(context, ref),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: filters.minBrilliants > 0
                      ? '≥${filters.minBrilliants} brilliants'
                      : 'Any brilliants',
                  icon: Icons.auto_awesome_rounded,
                  selected: filters.minBrilliants > 0,
                  onTap: () => _showBrilliantsSheet(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _sourceLabel(ArchiveSource? s) => switch (s) {
    null => 'All sources',
    ArchiveSource.chessCom => 'Chess.com',
    ArchiveSource.lichess => 'Lichess',
    ArchiveSource.pgn => 'PGN paste',
  };

  String _modeLabel(ArchiveModeFilter m) => switch (m) {
    ArchiveModeFilter.any => 'Any mode',
    ArchiveModeFilter.quick => 'Fast only',
    ArchiveModeFilter.deep => 'Deep only',
    ArchiveModeFilter.offline => 'Offline only',
  };

  String _colorLabel(ArchiveColorFilter c) => switch (c) {
    ArchiveColorFilter.any => 'Any colour',
    ArchiveColorFilter.white => 'You: White',
    ArchiveColorFilter.black => 'You: Black',
  };

  void _showSourceSheet(BuildContext context, WidgetRef ref) {
    _showSheet(context, 'Source', [
      _SheetOption(
        label: 'All sources',
        selected: filters.source == null,
        onTap: () {
          ref.read(archiveControllerProvider.notifier).setSource(null);
          Navigator.of(context).pop();
        },
      ),
      for (final s in ArchiveSource.values)
        _SheetOption(
          label: _sourceLabel(s),
          selected: filters.source == s,
          onTap: () {
            ref.read(archiveControllerProvider.notifier).setSource(s);
            Navigator.of(context).pop();
          },
        ),
    ]);
  }

  void _showModeSheet(BuildContext context, WidgetRef ref) {
    _showSheet(context, 'Analysis mode', [
      for (final m in ArchiveModeFilter.values)
        _SheetOption(
          label: _modeLabel(m),
          selected: filters.mode == m,
          onTap: () {
            ref.read(archiveControllerProvider.notifier).setModeFilter(m);
            Navigator.of(context).pop();
          },
        ),
    ]);
  }

  void _showColorSheet(BuildContext context, WidgetRef ref) {
    final current = ref.read(archiveControllerProvider).filters.perspective;
    _showSheet(
      context,
      current == null
          ? 'Set your player name on a game to filter by colour'
          : 'Filter by your colour ($current)',
      [
        for (final c in ArchiveColorFilter.values)
          _SheetOption(
            label: _colorLabel(c),
            selected: filters.color == c,
            onTap: () {
              ref
                  .read(archiveControllerProvider.notifier)
                  .setColorFilter(c, perspective: current);
              Navigator.of(context).pop();
            },
          ),
      ],
    );
  }

  String _sortLabel(ArchiveSort s) => switch (s) {
    ArchiveSort.newest => 'Newest',
    ArchiveSort.oldest => 'Oldest',
    ArchiveSort.mostBrilliants => 'Most brilliants',
    ArchiveSort.mostBlunders => 'Most blunders',
    ArchiveSort.highestAccuracy => 'Highest accuracy',
  };

  String _resultLabel(ArchiveResultFilter r) => switch (r) {
    ArchiveResultFilter.any => 'All results',
    ArchiveResultFilter.wins => 'Wins',
    ArchiveResultFilter.losses => 'Losses',
    ArchiveResultFilter.draws => 'Draws',
  };

  void _showSortSheet(BuildContext context, WidgetRef ref) {
    _showSheet(context, 'Sort by', [
      for (final s in ArchiveSort.values)
        _SheetOption(
          label: _sortLabel(s),
          selected: filters.sort == s,
          onTap: () {
            ref.read(archiveControllerProvider.notifier).setSort(s);
            Navigator.of(context).pop();
          },
        ),
    ]);
  }

  void _showResultSheet(BuildContext context, WidgetRef ref) {
    final current = ref.read(archiveControllerProvider).filters.perspective;
    _showSheet(
      context,
      current == null
          ? 'Set your player name on a game to filter by result'
          : 'Result for $current',
      [
        for (final r in ArchiveResultFilter.values)
          _SheetOption(
            label: _resultLabel(r),
            selected: filters.result == r,
            onTap: () {
              ref
                  .read(archiveControllerProvider.notifier)
                  .setResultFilter(r, current);
              Navigator.of(context).pop();
            },
          ),
      ],
    );
  }

  void _showBrilliantsSheet(BuildContext context, WidgetRef ref) {
    _showSheet(context, 'Minimum brilliants', [
      for (final n in const [0, 1, 2, 3, 5])
        _SheetOption(
          label: n == 0 ? 'Any' : '≥ $n',
          selected: filters.minBrilliants == n,
          onTap: () {
            ref.read(archiveControllerProvider.notifier).setMinBrilliants(n);
            Navigator.of(context).pop();
          },
        ),
    ]);
  }

  void _showSheet(
    BuildContext context,
    String title,
    List<_SheetOption> items,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ApexColors.deepSpace,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: ApexTypography.titleMedium.copyWith(
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 3,
                ),
                child: Material(
                  key: ValueKey(
                    'archive_sheet_option_${_keyFor(item.label)}_${item.selected ? 'selected' : 'normal'}',
                  ),
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: item.selected
                            ? ApexColors.mistake.withValues(alpha: 0.10)
                            : ApexColors.nebula.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: item.selected
                              ? ApexColors.mistake.withValues(alpha: 0.36)
                              : ApexColors.stardustLine.withValues(alpha: 0.18),
                          width: 0.7,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.label,
                              style: ApexTypography.bodyLarge.copyWith(
                                color: item.selected
                                    ? ApexColors.mistake
                                    : ApexColors.textPrimary,
                                fontWeight: item.selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (item.selected)
                            Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: ApexColors.mistake.withValues(alpha: 0.88),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  static String _keyFor(String label) => label
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

class _SheetOption {
  const _SheetOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
}

/// Plain-text archive search field — matches against opponent name,
/// opening name, and ECO code (lower-cased substring).
class _ArchiveSearchField extends ConsumerStatefulWidget {
  const _ArchiveSearchField({required this.current});
  final String current;

  @override
  ConsumerState<_ArchiveSearchField> createState() =>
      _ArchiveSearchFieldState();
}

class _ArchiveSearchFieldState extends ConsumerState<_ArchiveSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Phase 20.1 device feedback § 7: explicit cursor colour and
    // disabled autofill kill Android's yellow autofill bar that was
    // flashing through the dark theme on the search field.
    return TextField(
      controller: _controller,
      cursorColor: ApexColors.sapphireBright,
      autofillHints: const [],
      enableSuggestions: false,
      autocorrect: false,
      textInputAction: TextInputAction.search,
      style: ApexTypography.bodyMedium.copyWith(
        color: ApexColors.textPrimary,
        fontSize: 12,
      ),
      decoration: InputDecoration(
        isDense: true,
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 16,
          color: ApexColors.textTertiary,
        ),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear',
                icon: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: ApexColors.textTertiary,
                ),
                onPressed: () {
                  _controller.clear();
                  ref.read(archiveControllerProvider.notifier).setSearch('');
                  setState(() {});
                },
              ),
        hintText: 'Search opponent, opening, ECO…',
        hintStyle: ApexTypography.bodyMedium.copyWith(
          color: ApexColors.textTertiary,
          fontSize: 12,
        ),
        filled: true,
        fillColor: ApexColors.nebula.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ApexColors.stardustLine.withValues(alpha: 0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ApexColors.stardustLine.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ApexColors.sapphire.withValues(alpha: 0.55),
          ),
        ),
      ),
      onChanged: (v) {
        ref.read(archiveControllerProvider.notifier).setSearch(v);
        setState(() {});
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Phase 20.1 device feedback § 7: pinned splash/highlight stop the
    // default Material yellow ripple from leaking through on Android.
    return Material(
      key: ValueKey(
        'archive_filter_${label.toLowerCase().replaceAll(' ', '_')}_${selected ? 'selected' : 'normal'}',
      ),
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        splashColor: (selected ? ApexColors.mistake : ApexColors.sapphire)
            .withValues(alpha: 0.18),
        highlightColor: (selected ? ApexColors.mistake : ApexColors.sapphire)
            .withValues(alpha: 0.10),
        hoverColor: (selected ? ApexColors.mistake : ApexColors.sapphire)
            .withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? ApexColors.mistake.withValues(alpha: 0.22)
                : ApexColors.nebula.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? ApexColors.mistake.withValues(alpha: 0.78)
                  : ApexColors.stardustLine.withValues(alpha: 0.4),
              width: selected ? 1.0 : 0.7,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: selected
                    ? ApexColors.mistake
                    : ApexColors.sapphireBright,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: ApexTypography.bodyMedium.copyWith(
                  color: selected ? ApexColors.mistake : ApexColors.textPrimary,
                  fontSize: 12,
                  letterSpacing: 0.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Card ─────────────────────────────────────────────────────────────

class _ArchiveCard extends StatelessWidget {
  const _ArchiveCard({
    required this.game,
    required this.userHandle,
    required this.onTap,
    required this.onDelete,
  });

  final ArchivedGame game;

  /// Connected account handle, lower-cased. `null` when no account is
  /// connected — card falls back to the legacy "White vs Black" layout.
  final String? userHandle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final userIsBlack = game.userIsBlackFor(userHandle);
    final headline = game.resultHeadline(userHandle: userHandle);
    final isWin = headline.startsWith('You won') || headline == 'White won';
    final isLoss = headline.startsWith('You lost') || headline == 'Black won';
    final accent = headline.startsWith('Draw')
        ? ApexColors.inaccuracy
        : isWin
        ? ApexColors.best
        : isLoss
        ? ApexColors.blunder
        : ApexColors.sapphire;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: GlassPanel(
        padding: const EdgeInsets.fromLTRB(16, 15, 10, 15),
        accentColor: accent,
        accentAlpha: 0.22,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headline,
                        style: ApexTypography.titleMedium.copyWith(
                          fontSize: 15,
                          color: ApexColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _metaLine,
                        style: ApexTypography.bodyMedium.copyWith(
                          color: ApexColors.textTertiary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: ApexColors.textTertiary,
                  ),
                  tooltip: 'Remove from archive',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              game.openingLine,
              style: ApexTypography.bodyMedium.copyWith(
                color: game.openingName == null
                    ? ApexColors.textTertiary
                    : ApexColors.book,
                fontSize: 11.5,
                fontWeight: game.openingName == null
                    ? FontWeight.w500
                    : FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              _accuracyText(userIsBlack),
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            _QualitySummaryChips(game: game),
            const SizedBox(height: 9),
            Row(
              children: [
                Flexible(
                  child: Text(
                    game.secondaryResultText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ApexTypography.bodyMedium.copyWith(
                      color: ApexColors.textTertiary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (userIsBlack != null) ...[
                  const SizedBox(width: 8),
                  _CompactTag(
                    label: userIsBlack ? 'You: Black' : 'You: White',
                    color: ApexColors.aurora,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _metaLine {
    return [
      game.sourceLabel,
      game.reviewModeLabel,
      if (game.timeControl != null && game.timeControl!.isNotEmpty)
        game.timeControl!,
      game.relativePlayedAt,
    ].join(' • ');
  }

  String _accuracyText(bool? userIsBlack) {
    final tl = game.cachedTimeline;
    if (userIsBlack != null && tl != null) {
      final summary = const ReviewSummaryService().compute(
        timeline: tl,
        userIsWhite: !userIsBlack,
      );
      return 'You ${summary.userAccuracyPct.toStringAsFixed(0)}% • Opp ${summary.opponentAccuracyPct.toStringAsFixed(0)}%';
    }
    return 'ACPL ${game.averageCpLoss.toStringAsFixed(1)}';
  }
}

class _CompactTag extends StatelessWidget {
  const _CompactTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 0.6),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ApexTypography.bodyMedium.copyWith(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _QualitySummaryChips extends StatelessWidget {
  const _QualitySummaryChips({required this.game});

  final ArchivedGame game;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 5,
      children: [
        _QualityPill(
          label: 'Brilliant',
          count: game.brilliantCount,
          color: ApexColors.brilliant,
        ),
        _QualityPill(
          label: 'Great',
          count: game.greatCount,
          color: ApexColors.sapphireBright,
        ),
        _QualityPill(
          label: 'Miss',
          count: game.missCount,
          color: ApexColors.miss,
        ),
        _QualityPill(
          label: 'Blunder',
          count: game.blunderCount,
          color: ApexColors.blunder,
        ),
      ],
    );
  }
}

class _QualityPill extends StatelessWidget {
  const _QualityPill({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isZero = count == 0;
    final effective = isZero ? ApexColors.textTertiary : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: effective.withValues(alpha: isZero ? 0.06 : 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: effective.withValues(alpha: isZero ? 0.14 : 0.30),
          width: 0.5,
        ),
      ),
      child: Text(
        '$label $count',
        style: ApexTypography.bodyMedium.copyWith(
          color: effective,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.label, this.accent});

  final IconData icon;
  final String label;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? ApexColors.textTertiary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: color),
            const SizedBox(height: 14),
            Text(
              label,
              textAlign: TextAlign.center,
              style: ApexTypography.bodyLarge.copyWith(
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterEmptyState extends StatelessWidget {
  const _FilterEmptyState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: GlassPanel(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          accentColor: ApexColors.mistake,
          accentAlpha: 0.18,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.filter_alt_off_rounded,
                size: 22,
                color: ApexColors.mistake.withValues(alpha: 0.85),
              ),
              const SizedBox(height: 8),
              Text(
                ApexCopy.noMatchingGames,
                textAlign: TextAlign.center,
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: onClear,
                child: const Text(ApexCopy.clearFilters),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Re-analysis dialog (re-opening a saved game) ─────────────────────

class _ReanalysisDialog extends StatelessWidget {
  const _ReanalysisDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: GlassPanel.dialog(
        accentColor: ApexColors.aurora,
        child: ApexLoadingScaffold(
          title: ApexCopy.reanalysisPending,
          messages: const ['Loading saved review...', 'Building review...'],
          compact: true,
        ),
      ),
    );
  }
}

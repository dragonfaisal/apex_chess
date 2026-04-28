/// Archived Intel — saved game list with filters.
///
/// Reads from [archiveControllerProvider] and renders a glassmorphism
/// list of previously analyzed games. The filter sheet lives in the
/// app bar; each row taps into [ReviewScreen] against a freshly
/// re-analysed timeline (cheap — the PGN is persisted and the
/// Quantum Scan runs again locally).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/presentation/controllers/archive_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/views/review_summary_screen.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';
import 'package:apex_chess/shared_ui/widgets/quantum_shatter_loader.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(archiveControllerProvider);
    final visible = state.visible;

    return Scaffold(
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
        child: SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 2.6,
            color: ApexColors.sapphireBright,
          ),
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
        label:
            'No archived intel yet. Run a Quantum Scan — results land here automatically.',
      );
    }
    if (visible.isEmpty) {
      return const _EmptyState(
        icon: Icons.filter_alt_outlined,
        label: 'No games match the current filters.',
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
        onDelete: () => ref
            .read(archiveControllerProvider.notifier)
            .remove(visible[i].id),
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
      ref.read(reviewControllerProvider.notifier).loadTimeline(
            cached,
            userIsBlack: userIsBlack,
            mode: game.analysisMode,
            userIsWhite: userIsWhite,
          );
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ReviewSummaryScreen()),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ReanalysisDialog(),
    );
    try {
      final analyzer = ref.read(gameAnalyzerProvider);
      final timeline = await analyzer.analyzeFromPgn(
        game.pgn,
        depth: game.depth,
        // Re-analysis must honour the original Quick/Deep choice so a
        // Quick archive doesn't silently re-run as Deep (and acquire
        // Brilliant / Great / Forced tags it never had).
        mode: game.analysisMode,
      );
      ref.read(reviewControllerProvider.notifier).loadTimeline(
            timeline,
            userIsBlack: userIsBlack,
            mode: game.analysisMode,
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
      } catch (_) {/* persistence is best-effort */}
      if (!navigator.mounted) return;
      navigator.pop();
      navigator.push(
        MaterialPageRoute<void>(builder: (_) => const ReviewSummaryScreen()),
      );
    } catch (e) {
      if (!navigator.mounted) return;
      navigator.pop();
      messenger.showSnackBar(SnackBar(
        content: Text('Re-analysis failed: $e'),
        backgroundColor: ApexColors.rubyDeep,
      ));
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
}

// ── Header ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.gamesCount,
    required this.brilliants,
    required this.blunders,
  });

  final int gamesCount;
  final int brilliants;
  final int blunders;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: ApexColors.textPrimary, size: 18),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ApexCopy.archivesTitle,
                    style: ApexTypography.headlineMedium.copyWith(
                      letterSpacing: 3,
                    )),
                const SizedBox(height: 2),
                Text(
                  '$gamesCount games · $brilliants brilliants · $blunders blunders',
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
                  onTap: () => _showSortSheet(context, ref),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: _sourceLabel(filters.source),
                  icon: Icons.cloud_outlined,
                  onTap: () => _showSourceSheet(context, ref),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: _modeLabel(filters.mode),
                  icon: Icons.flash_on_rounded,
                  onTap: () => _showModeSheet(context, ref),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: _colorLabel(filters.color),
                  icon: Icons.swap_vert_rounded,
                  onTap: () => _showColorSheet(context, ref),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: _resultLabel(filters.result),
                  icon: Icons.flag_outlined,
                  onTap: () => _showResultSheet(context, ref),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: filters.minBrilliants > 0
                      ? '≥${filters.minBrilliants} brilliants'
                      : 'Any brilliants',
                  icon: Icons.auto_awesome_rounded,
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
        ArchiveModeFilter.quick => 'Quick only',
        ArchiveModeFilter.deep => 'Deep only',
      };

  String _colorLabel(ArchiveColorFilter c) => switch (c) {
        ArchiveColorFilter.any => 'Any colour',
        ArchiveColorFilter.white => 'You: White',
        ArchiveColorFilter.black => 'You: Black',
      };

  void _showSourceSheet(BuildContext context, WidgetRef ref) {
    _showSheet(context, 'Source', [
      ('All sources', () {
        ref.read(archiveControllerProvider.notifier).setSource(null);
        Navigator.of(context).pop();
      }),
      for (final s in ArchiveSource.values)
        (_sourceLabel(s), () {
          ref.read(archiveControllerProvider.notifier).setSource(s);
          Navigator.of(context).pop();
        }),
    ]);
  }

  void _showModeSheet(BuildContext context, WidgetRef ref) {
    _showSheet(context, 'Analysis mode', [
      for (final m in ArchiveModeFilter.values)
        (_modeLabel(m), () {
          ref.read(archiveControllerProvider.notifier).setModeFilter(m);
          Navigator.of(context).pop();
        }),
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
          (_colorLabel(c), () {
            ref
                .read(archiveControllerProvider.notifier)
                .setColorFilter(c, perspective: current);
            Navigator.of(context).pop();
          }),
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
        (_sortLabel(s), () {
          ref.read(archiveControllerProvider.notifier).setSort(s);
          Navigator.of(context).pop();
        }),
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
          (_resultLabel(r), () {
            ref
                .read(archiveControllerProvider.notifier)
                .setResultFilter(r, current);
            Navigator.of(context).pop();
          }),
      ],
    );
  }

  void _showBrilliantsSheet(BuildContext context, WidgetRef ref) {
    _showSheet(context, 'Minimum brilliants', [
      for (final n in const [0, 1, 2, 3, 5])
        (n == 0 ? 'Any' : '≥ $n', () {
          ref
              .read(archiveControllerProvider.notifier)
              .setMinBrilliants(n);
          Navigator.of(context).pop();
        }),
    ]);
  }

  void _showSheet(
    BuildContext context,
    String title,
    List<(String, VoidCallback)> items,
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
            for (final (label, cb) in items)
              ListTile(
                onTap: cb,
                title: Text(label,
                    style: ApexTypography.bodyLarge
                        .copyWith(color: ApexColors.textPrimary)),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
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
      style: ApexTypography.bodyMedium.copyWith(
        color: ApexColors.textPrimary,
        fontSize: 12,
      ),
      decoration: InputDecoration(
        isDense: true,
        prefixIcon: const Icon(Icons.search_rounded,
            size: 16, color: ApexColors.textTertiary),
        hintText: 'Search opponent, opening, ECO…',
        hintStyle: ApexTypography.bodyMedium
            .copyWith(color: ApexColors.textTertiary, fontSize: 12),
        filled: true,
        fillColor: ApexColors.nebula.withValues(alpha: 0.6),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: ApexColors.stardustLine.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: ApexColors.stardustLine.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: ApexColors.sapphire.withValues(alpha: 0.55)),
        ),
      ),
      onChanged: (v) =>
          ref.read(archiveControllerProvider.notifier).setSearch(v),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Phase 20.1 device feedback § 7: pinned splash/highlight stop the
    // default Material yellow ripple from leaking through on Android.
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: ApexColors.sapphire.withValues(alpha: 0.18),
        highlightColor: ApexColors.sapphire.withValues(alpha: 0.10),
        hoverColor: ApexColors.sapphire.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: ApexColors.nebula.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ApexColors.stardustLine.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 14, color: ApexColors.sapphireBright),
              const SizedBox(width: 6),
              Text(label,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  )),
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

  /// `true` if the user played Black in this game, `false` for White,
  /// `null` when we can't tell (raw PGN or handle doesn't match either
  /// side).
  bool? get _userIsBlack {
    final me = userHandle;
    if (me == null || me.isEmpty) return null;
    if (game.black.trim().toLowerCase() == me) return true;
    if (game.white.trim().toLowerCase() == me) return false;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final accent = game.brilliantCount > 0
        ? ApexColors.aurora
        : (game.blunderCount >= 3
            ? ApexColors.ruby
            : ApexColors.sapphire);
    final userIsBlack = _userIsBlack;
    final matchupText = _matchupText(userIsBlack);
    final acplText = _acplText(userIsBlack);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: GlassPanel(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        accentColor: accent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phase A audit § 4: top pill strip may now include
                  // Source / Result / Depth / Mode / User-side. Wrap so
                  // it line-breaks on narrow phones instead of forcing
                  // the card into overflow.
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _SourcePill(source: game.source),
                      _ResultPill(result: game.result),
                      _DepthPill(depth: game.depth),
                      _ModePill(mode: game.analysisMode),
                      if (userIsBlack != null)
                        _UserSidePill(isBlack: userIsBlack),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    matchupText,
                    style: ApexTypography.titleMedium
                        .copyWith(fontSize: 14, letterSpacing: 0.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Phase 20.1 device feedback § 6: tighter vertical
                  // rhythm — opening + plies live on one quiet line, and
                  // per-side ACPL gets a dedicated row in monospace so
                  // the user can compare YOU vs OPPONENT at a glance.
                  Text(
                    '${game.openingName ?? '—'}  ·  ${game.totalPlies} plies',
                    style: ApexTypography.bodyMedium.copyWith(
                      color: ApexColors.textTertiary,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    acplText,
                    style: ApexTypography.bodyMedium.copyWith(
                      color: ApexColors.textSecondary,
                      fontSize: 11,
                      fontFamily: 'JetBrains Mono',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Premium SVG badges — one glyph per quality tier, count
                  // rendered to the right of the icon. The Wrap guards
                  // against squeeze on narrow rows where three pills
                  // would otherwise overflow.
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (game.brilliantCount > 0)
                        _SvgCountPill(
                          quality: MoveQuality.brilliant,
                          count: game.brilliantCount,
                        ),
                      if (game.blunderCount > 0)
                        _SvgCountPill(
                          quality: MoveQuality.blunder,
                          count: game.blunderCount,
                        ),
                      if (game.mistakeCount > 0)
                        _SvgCountPill(
                          quality: MoveQuality.mistake,
                          count: game.mistakeCount,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.close_rounded,
                  size: 18, color: ApexColors.textTertiary),
              tooltip: 'Remove from archive',
            ),
          ],
        ),
      ),
    );
  }

  static String _nameOf(String name, String? rating) =>
      rating == null || rating.isEmpty ? name : '$name ($rating)';

  /// Headline line on the card. When we know the user's side we render
  /// "You (rating) vs Opponent (rating)" so the archive reads from the
  /// user's perspective; otherwise we fall back to the legacy "White
  /// vs Black" format.
  String _matchupText(bool? userIsBlack) {
    if (userIsBlack == null) {
      return '${_nameOf(game.white, game.whiteRating)}  vs  '
          '${_nameOf(game.black, game.blackRating)}';
    }
    final myRating = userIsBlack ? game.blackRating : game.whiteRating;
    final oppName = userIsBlack ? game.white : game.black;
    final oppRating = userIsBlack ? game.whiteRating : game.blackRating;
    final me = myRating == null || myRating.isEmpty ? 'You' : 'You ($myRating)';
    return '$me  vs  ${_nameOf(oppName, oppRating)}';
  }

  /// ACPL line — per-side when we know the user, aggregate otherwise.
  /// Only the cached timeline can yield per-side ACPL; pre-cache records
  /// fall back to the single persisted figure.
  String _acplText(bool? userIsBlack) {
    final tl = game.cachedTimeline;
    if (userIsBlack == null || tl == null) {
      return '${game.averageCpLoss.toStringAsFixed(1)} ACPL';
    }
    final you = userIsBlack ? tl.averageCpLossBlack : tl.averageCpLossWhite;
    final opp = userIsBlack ? tl.averageCpLossWhite : tl.averageCpLossBlack;
    return 'You ${you.toStringAsFixed(1)} · Opp ${opp.toStringAsFixed(1)} ACPL';
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({required this.mode});
  final AnalysisMode mode;

  @override
  Widget build(BuildContext context) {
    final label = mode == AnalysisMode.quick ? 'QUICK' : 'DEEP';
    final color = mode == AnalysisMode.quick
        ? ApexColors.electricBlue
        : ApexColors.sapphireBright;
    return _Pill(label: label, color: color);
  }
}

class _UserSidePill extends StatelessWidget {
  const _UserSidePill({required this.isBlack});
  final bool isBlack;

  @override
  Widget build(BuildContext context) {
    final label = isBlack ? 'YOU ◼' : 'YOU ◻';
    return _Pill(label: label, color: ApexColors.aurora);
  }
}

class _SourcePill extends StatelessWidget {
  const _SourcePill({required this.source});
  final ArchiveSource source;

  @override
  Widget build(BuildContext context) {
    final label = switch (source) {
      ArchiveSource.chessCom => 'Chess.com',
      ArchiveSource.lichess => 'Lichess',
      ArchiveSource.pgn => 'PGN',
    };
    return _Pill(label: label, color: ApexColors.sapphireBright);
  }
}

class _ResultPill extends StatelessWidget {
  const _ResultPill({required this.result});
  final String result;

  @override
  Widget build(BuildContext context) {
    final color = switch (result) {
      '1-0' => ApexColors.sapphireBright,
      '0-1' => ApexColors.ruby,
      '1/2-1/2' => ApexColors.textTertiary,
      _ => ApexColors.textTertiary,
    };
    return _Pill(label: result, color: color);
  }
}

class _DepthPill extends StatelessWidget {
  const _DepthPill({required this.depth});
  final int depth;

  @override
  Widget build(BuildContext context) {
    return _Pill(label: 'D$depth', color: ApexColors.aurora);
  }
}

/// SVG-backed count badge — used in the archive row to show how many
/// brilliants/blunders/mistakes a scanned game contains. Replaces the
/// old text-symbol pill so the archive list matches the Review board's
/// premium asset language.
class _SvgCountPill extends StatelessWidget {
  const _SvgCountPill({required this.quality, required this.count});

  final MoveQuality quality;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: quality.color.withValues(alpha: 0.12),
        border: Border.all(
            color: quality.color.withValues(alpha: 0.4), width: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: SvgPicture.asset(
              quality.svgAssetPath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: ApexTypography.bodyMedium.copyWith(
              color: quality.color,
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: ApexTypography.bodyMedium.copyWith(
          color: color,
          fontSize: 10,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.label,
    this.accent,
  });

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 120,
              child: Center(child: QuantumShatterLoader(size: 120)),
            ),
            const SizedBox(height: 12),
            Text(
              ApexCopy.reanalysisPending,
              textAlign: TextAlign.center,
              style: ApexTypography.titleMedium.copyWith(
                letterSpacing: 2,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

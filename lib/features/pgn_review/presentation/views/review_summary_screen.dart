/// Chess.com-style summary screen shown after analysis completes,
/// **before** the detailed move-by-move review.
///
/// Phase 20.1 § 3 contract: every number rendered here comes from a
/// real data source (the [AnalysisTimeline] loaded on the
/// [reviewControllerProvider]). There are no "fake" statistics — the
/// summary is pure derivation.
///
/// Layout:
///   ┌─ Result / opening / mode header
///   ├─ Accuracy pair (You / Opponent)
///   ├─ Counts strip (Best / Excellent / Mistake / Blunder / …)
///   ├─ Highlights (key turning point, biggest mistake, best move)
///   ├─ Phase breakdown (opening / middle / endgame with weakness tag)
///   └─ CTA row: Review Moves · Save · Add to Academy · Re-analyze Deep
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/game_identity_service.dart';
import 'package:apex_chess/core/domain/services/move_quality_display.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/domain/review_summary.dart';
import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_player_avatar.dart';

import '../controllers/review_controller.dart';
import 'review_screen.dart';

/// Optional hook the caller can install to trigger a Deep re-analysis
/// when the summary was generated from a Quick scan. Called when the
/// user taps the "Re-analyze Deep" CTA. When `null`, the CTA is
/// hidden.
typedef OnReanalyzeDeep = Future<void> Function();

/// Optional hook for the "Save Game" CTA. `null` → hidden (most
/// in-app flows already save on analysis completion, so this is only
/// surfaced when the caller explicitly wires it).
typedef OnSaveGame = Future<void> Function();

/// Optional hook for "Add Mistakes to Academy". `null` → hidden.
typedef OnAddMistakesToAcademy = Future<void> Function();

class ReviewSummaryScreen extends ConsumerWidget {
  const ReviewSummaryScreen({
    super.key,
    this.onReanalyzeDeep,
    this.onSaveGame,
    this.onAddMistakesToAcademy,
  });

  final OnReanalyzeDeep? onReanalyzeDeep;
  final OnSaveGame? onSaveGame;
  final OnAddMistakesToAcademy? onAddMistakesToAcademy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewControllerProvider);
    final timeline = state.timeline;

    return Scaffold(
      backgroundColor: ApexColors.darkSurface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ApexColors.textSecondary,
            size: 18,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Game Summary',
          style: ApexTypography.titleMedium.copyWith(
            letterSpacing: 3,
            fontSize: 13,
            color: ApexColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: timeline == null
          ? const Center(
              child: Text(
                'No analysis loaded.',
                style: TextStyle(color: ApexColors.textTertiary),
              ),
            )
          : _SummaryBody(
              timeline: timeline,
              summary: const ReviewSummaryService().compute(
                timeline: timeline,
                userIsWhite: state.userIsWhite,
              ),
              mode: state.mode,
              onReanalyzeDeep: onReanalyzeDeep,
              onSaveGame: onSaveGame,
              onAddMistakesToAcademy: onAddMistakesToAcademy,
            ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({
    required this.timeline,
    required this.summary,
    required this.mode,
    this.onReanalyzeDeep,
    this.onSaveGame,
    this.onAddMistakesToAcademy,
  });

  final AnalysisTimeline timeline;
  final ReviewSummary summary;
  final AnalysisMode mode;
  final OnReanalyzeDeep? onReanalyzeDeep;
  final OnSaveGame? onSaveGame;
  final OnAddMistakesToAcademy? onAddMistakesToAcademy;

  @override
  Widget build(BuildContext context) {
    final players = _SummaryPlayerPair.from(
      timeline: timeline,
      userIsWhite: summary.userIsWhite,
    );
    return Container(
      decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
          children: [
            _ResultHeader(summary: summary, timeline: timeline),
            if (mode == AnalysisMode.quick) ...[
              const SizedBox(height: 10),
              const _FastReviewBanner(),
            ] else ...[
              const SizedBox(height: 10),
              const _DeepReviewNotice(),
            ],
            const SizedBox(height: 16),
            _PlayerCardsRow(summary: summary, players: players),
            const SizedBox(height: 16),
            _MoveQualityTable(counts: summary.counts, players: players),
            const SizedBox(height: 16),
            _HighlightsBlock(summary: summary),
            const SizedBox(height: 16),
            _PhaseBlock(summary: summary),
            const SizedBox(height: 20),
            _CtaRow(
              isQuick: mode == AnalysisMode.quick,
              onReanalyzeDeep: onReanalyzeDeep,
              onSaveGame: onSaveGame,
              onAddMistakesToAcademy: onAddMistakesToAcademy,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Result / opening header ────────────────────────────────────────

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.summary, required this.timeline});

  final ReviewSummary summary;
  final AnalysisTimeline timeline;

  @override
  Widget build(BuildContext context) {
    final resultLabel = const GameIdentityService().resultLabel(
      summary.result ?? '*',
      userIsWhite: summary.userIsWhite,
    );
    final modeLabel = _profileLabel(timeline);
    final sourceLabel = _sourceLabel(timeline);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ApexColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  resultLabel,
                  style: ApexTypography.headlineMedium.copyWith(
                    fontSize: 22,
                    color: ApexColors.textPrimary,
                  ),
                ),
              ),
              Wrap(
                spacing: 6,
                children: [
                  _ModePill(label: modeLabel),
                  _ModePill(label: sourceLabel),
                ],
              ),
            ],
          ),
          if (summary.openingLabel != null) ...[
            const SizedBox(height: 6),
            Text(
              summary.openingLabel!,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.electricBlue.withAlpha(180),
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            '${summary.totalPlies} plies analyzed',
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  static String _profileLabel(AnalysisTimeline timeline) {
    switch (timeline.analysisProfileId) {
      case 'fast_review':
        return 'Fast';
      case 'offline_review':
        return 'Offline';
      default:
        return 'Deep';
    }
  }

  static String _sourceLabel(AnalysisTimeline timeline) {
    final site = timeline.headers['Site']?.toLowerCase() ?? '';
    if (site.contains('chess.com')) return 'Chess.com';
    if (site.contains('lichess')) return 'Lichess';
    return 'PGN';
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isQuick = label == 'Fast';
    final color = isQuick ? ApexColors.inaccuracy : ApexColors.electricBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(120), width: 0.6),
      ),
      child: Text(
        label,
        style: ApexTypography.labelLarge.copyWith(
          color: color.withAlpha(230),
          fontSize: 10,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}

class _SummaryPlayerPair {
  const _SummaryPlayerPair({required this.white, required this.black});

  final _SummaryPlayerIdentity white;
  final _SummaryPlayerIdentity black;

  factory _SummaryPlayerPair.from({
    required AnalysisTimeline timeline,
    required bool? userIsWhite,
  }) {
    final h = timeline.headers;
    return _SummaryPlayerPair(
      white: _SummaryPlayerIdentity(
        name: h['White'] ?? 'White',
        rating: h['WhiteElo'],
        isWhite: true,
        isUser: userIsWhite == true,
        avatarUrl: h['WhiteAvatar'] ?? h['WhiteAvatarUrl'],
      ),
      black: _SummaryPlayerIdentity(
        name: h['Black'] ?? 'Black',
        rating: h['BlackElo'],
        isWhite: false,
        isUser: userIsWhite == false,
        avatarUrl: h['BlackAvatar'] ?? h['BlackAvatarUrl'],
      ),
    );
  }
}

class _SummaryPlayerIdentity {
  const _SummaryPlayerIdentity({
    required this.name,
    required this.isWhite,
    required this.isUser,
    this.rating,
    this.avatarUrl,
  });

  final String name;
  final String? rating;
  final bool isWhite;
  final bool isUser;
  final String? avatarUrl;

  String get sideLabel => isWhite ? 'White' : 'Black';
  String get compactFallback => isUser ? 'You' : 'Opp';
  PlayerIdentityDisplay get identity => PlayerIdentityDisplay.fromRaw(
    username: name,
    platform: PlayerIdentityPlatform.pgn,
    rating: rating,
    avatarUrl: avatarUrl,
    isConnectedUser: isUser,
    isOpponent: !isUser,
    side: isWhite ? PlayerIdentitySide.white : PlayerIdentitySide.black,
  );

  String get tableName {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == sideLabel) return compactFallback;
    return trimmed;
  }
}

class _SideMarker extends StatelessWidget {
  const _SideMarker({required this.isWhite, this.size = 13});

  final bool isWhite;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fill = isWhite ? const Color(0xFFF4F7FB) : const Color(0xFF05070D);
    final stroke = isWhite
        ? ApexColors.textPrimary.withAlpha(210)
        : ApexColors.sapphireBright.withAlpha(120);
    return Semantics(
      label: isWhite ? 'White side' : 'Black side',
      child: Container(
        key: ValueKey(
          isWhite ? 'summary-white-side-marker' : 'summary-black-side-marker',
        ),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          border: Border.all(color: stroke, width: 1),
          boxShadow: [
            BoxShadow(
              color: (isWhite ? Colors.white : ApexColors.sapphireBright)
                  .withAlpha(isWhite ? 80 : 55),
              blurRadius: 8,
              spreadRadius: -3,
            ),
          ],
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            width: size * 0.34,
            height: size * 0.34,
            margin: EdgeInsets.all(size * 0.16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(isWhite ? 145 : 42),
            ),
          ),
        ),
      ),
    );
  }
}

class _YouChip extends StatelessWidget {
  const _YouChip({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 6,
        vertical: compact ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: ApexColors.sapphireBright.withAlpha(28),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: ApexColors.sapphireBright.withAlpha(95),
          width: 0.5,
        ),
      ),
      child: Text(
        'YOU',
        style: ApexTypography.labelLarge.copyWith(
          color: ApexColors.sapphireBright,
          fontSize: compact ? 7.5 : 9,
          letterSpacing: compact ? 0.5 : 0.8,
        ),
      ),
    );
  }
}

// ── Player cards ───────────────────────────────────────────────────

class _PlayerCardsRow extends StatelessWidget {
  const _PlayerCardsRow({required this.summary, required this.players});

  final ReviewSummary summary;
  final _SummaryPlayerPair players;

  @override
  Widget build(BuildContext context) {
    final white = _PlayerCard(
      identity: players.white,
      result: _sideResult('1-0'),
      accuracy: summary.userIsWhite == true
          ? summary.userAccuracyPct
          : summary.opponentAccuracyPct,
      acpl: summary.userIsWhite == true
          ? summary.userAverageCpLoss
          : summary.opponentAverageCpLoss,
    );
    final black = _PlayerCard(
      identity: players.black,
      result: _sideResult('0-1'),
      accuracy: summary.userIsWhite == false
          ? summary.userAccuracyPct
          : summary.opponentAccuracyPct,
      acpl: summary.userIsWhite == false
          ? summary.userAverageCpLoss
          : summary.opponentAverageCpLoss,
    );
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth < 380) {
          return Column(children: [white, const SizedBox(height: 10), black]);
        }
        return Row(
          children: [
            Expanded(child: white),
            const SizedBox(width: 10),
            Expanded(child: black),
          ],
        );
      },
    );
  }

  String _sideResult(String winningResult) {
    final result = summary.result;
    if (result == winningResult) return 'Won';
    if (result == '1/2-1/2') return 'Draw';
    if (result == '*' || result == null) return 'Open';
    return 'Lost';
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.identity,
    required this.result,
    required this.accuracy,
    required this.acpl,
  });

  final _SummaryPlayerIdentity identity;
  final String result;
  final double accuracy;
  final double acpl;

  @override
  Widget build(BuildContext context) {
    final accent = identity.isUser
        ? ApexColors.sapphireBright
        : ApexColors.textTertiary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ApexColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ApexPlayerAvatar(
                identity: identity.identity,
                size: ApexPlayerAvatarSize.small,
                showConnectedBadge: identity.isUser,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  identity.tableName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ApexTypography.titleMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              if (identity.isUser) const _YouChip(),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            [
              identity.sideLabel,
              if (identity.rating != null && identity.rating!.isNotEmpty)
                identity.rating!,
              result,
            ].join(' · '),
            style: ApexTypography.bodyMedium.copyWith(
              color: accent,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Text(
            '${accuracy.toStringAsFixed(1)}%',
            style: ApexTypography.headlineMedium.copyWith(
              fontSize: 24,
              color: ApexColors.textPrimary,
              fontFamily: 'JetBrains Mono',
            ),
          ),
          Text(
            'ACPL ${acpl.toStringAsFixed(1)}',
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textSecondary,
              fontSize: 11,
              fontFamily: 'JetBrains Mono',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Accuracy row ───────────────────────────────────────────────────

// ignore: unused_element
class _AccuracyRow extends StatelessWidget {
  const _AccuracyRow({required this.summary});

  final ReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AccuracyCard(
            label: 'YOU',
            accuracy: summary.userAccuracyPct,
            acpl: summary.userAverageCpLoss,
            colorKnown: summary.userIsWhite != null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _AccuracyCard(
            label: 'OPPONENT',
            accuracy: summary.opponentAccuracyPct,
            acpl: summary.opponentAverageCpLoss,
            colorKnown: summary.userIsWhite != null,
          ),
        ),
      ],
    );
  }
}

class _AccuracyCard extends StatelessWidget {
  const _AccuracyCard({
    required this.label,
    required this.accuracy,
    required this.acpl,
    required this.colorKnown,
  });

  final String label;
  final double accuracy;
  final double acpl;
  final bool colorKnown;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ApexColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: ApexTypography.labelLarge.copyWith(
              fontSize: 10,
              letterSpacing: 1.6,
              color: ApexColors.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            colorKnown ? '${accuracy.toStringAsFixed(1)}%' : '—',
            style: ApexTypography.headlineMedium.copyWith(
              fontSize: 26,
              color: ApexColors.textPrimary,
              fontFamily: 'JetBrains Mono',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'ACPL ${acpl.toStringAsFixed(1)}',
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textSecondary,
              fontSize: 11,
              fontFamily: 'JetBrains Mono',
            ),
          ),
          const SizedBox(height: 4),
          // Phase 20.1 device feedback § 5: never present a single
          // game's accuracy as stable player skill. The summary screen
          // is always one game by definition, so we always tag the
          // figure as preliminary here. Profile-level "preliminary"
          // gating across multiple games lands in PR #21.
          Text(
            'Preliminary · 1 game',
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 10,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick scan banner ──────────────────────────────────────────────

/// Deep-mode notice: local Stockfish runs PV1-PV3 and the classifier uses
/// the alternate lines to verify Brilliant / Great / Forced reads.
class _DeepReviewNotice extends StatelessWidget {
  const _DeepReviewNotice();

  @override
  Widget build(BuildContext context) {
    final color = ApexColors.sapphireBright;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(90), width: 0.6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deep Review',
                  style: ApexTypography.labelLarge.copyWith(
                    color: color,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stronger tactical verification is active for final review.',
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textSecondary,
                    fontSize: 11,
                    height: 1.35,
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

class _FastReviewBanner extends StatelessWidget {
  const _FastReviewBanner();

  @override
  Widget build(BuildContext context) {
    final color = ApexColors.inaccuracy;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(120), width: 0.6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.flash_on_rounded, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fast Review',
                  style: ApexTypography.labelLarge.copyWith(
                    color: color.withAlpha(240),
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fast local fallback is preview-only on this device. Use '
                  'Deep Review for final tactical badges.',
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textSecondary,
                    fontSize: 11,
                    height: 1.35,
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

// ── Move quality table ─────────────────────────────────────────────

class _MoveQualityTable extends StatelessWidget {
  const _MoveQualityTable({required this.counts, required this.players});

  final ReviewCounts counts;
  final _SummaryPlayerPair players;

  @override
  Widget build(BuildContext context) {
    const visibleRows = MoveQualityDisplay.countOrder;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: ApexColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MOVE QUALITY',
            style: ApexTypography.labelLarge.copyWith(
              fontSize: 10,
              letterSpacing: 1.6,
              color: ApexColors.textTertiary,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 350;
              final columnWidth = compact ? 64.0 : 78.0;
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Label',
                          style: ApexTypography.bodyMedium.copyWith(
                            color: ApexColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      _CountHeader(
                        identity: players.white,
                        compact: compact,
                        width: columnWidth,
                      ),
                      _CountHeader(
                        identity: players.black,
                        compact: compact,
                        width: columnWidth,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  for (final label in visibleRows)
                    _MoveQualityRow(
                      label: label,
                      white: counts.whiteDisplayCounts[label] ?? 0,
                      black: counts.blackDisplayCounts[label] ?? 0,
                      cellWidth: columnWidth,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CountHeader extends StatelessWidget {
  const _CountHeader({
    required this.identity,
    required this.compact,
    required this.width,
  });

  final _SummaryPlayerIdentity identity;
  final bool compact;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _SideMarker(isWhite: identity.isWhite, size: compact ? 9 : 10),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              compact ? identity.compactFallback : identity.tableName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textTertiary,
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (identity.isUser && !compact) ...[
            const SizedBox(width: 4),
            const _YouChip(compact: true),
          ],
        ],
      ),
    );
  }
}

class _MoveQualityRow extends StatelessWidget {
  const _MoveQualityRow({
    required this.label,
    required this.white,
    required this.black,
    required this.cellWidth,
  });

  final ReviewMoveLabel label;
  final int white;
  final int black;
  final double cellWidth;

  @override
  Widget build(BuildContext context) {
    final dim = white == 0 && black == 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.label,
              style: ApexTypography.bodyMedium.copyWith(
                color: dim ? ApexColors.textTertiary : label.color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _CountCell(white, width: cellWidth),
          _CountCell(black, width: cellWidth),
        ],
      ),
    );
  }
}

class _CountCell extends StatelessWidget {
  const _CountCell(this.value, {required this.width});
  final int value;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        '$value',
        textAlign: TextAlign.right,
        style: ApexTypography.bodyMedium.copyWith(
          color: value == 0 ? ApexColors.textTertiary : ApexColors.textPrimary,
          fontSize: 12,
          fontFamily: 'JetBrains Mono',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Per-player counts ──────────────────────────────────────────────

// ignore: unused_element
class _PerPlayerCounts extends StatelessWidget {
  const _PerPlayerCounts({required this.counts});

  final ReviewCounts counts;

  /// Display order: trophy tiers → Best/Excellent/Good → Book →
  /// problem tiers (Inaccuracy/Mistake/Missed/Blunder). Same on both
  /// sides so the YOU and OPPONENT columns line up visually.
  static const List<MoveQuality> _displayOrder = [
    MoveQuality.brilliant,
    MoveQuality.great,
    MoveQuality.best,
    MoveQuality.excellent,
    MoveQuality.good,
    MoveQuality.book,
    MoveQuality.inaccuracy,
    MoveQuality.mistake,
    MoveQuality.missedWin,
    MoveQuality.blunder,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: ApexColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COUNTS BY PLAYER',
            style: ApexTypography.labelLarge.copyWith(
              fontSize: 10,
              letterSpacing: 1.6,
              color: ApexColors.textTertiary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _PlayerCountColumn(
                  label: 'YOU',
                  tiers: counts.user,
                  displayOrder: _displayOrder,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 0.5,
                height: 240,
                color: ApexColors.subtleBorder,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PlayerCountColumn(
                  label: 'OPPONENT',
                  tiers: counts.opponent,
                  displayOrder: _displayOrder,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayerCountColumn extends StatelessWidget {
  const _PlayerCountColumn({
    required this.label,
    required this.tiers,
    required this.displayOrder,
  });

  final String label;
  final ReviewCountsByTier tiers;
  final List<MoveQuality> displayOrder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ApexTypography.labelLarge.copyWith(
            fontSize: 11,
            letterSpacing: 1.6,
            color: ApexColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        for (final tier in displayOrder)
          _PerTierRow(tier: tier, count: tiers.forTier(tier)),
      ],
    );
  }
}

class _PerTierRow extends StatelessWidget {
  const _PerTierRow({required this.tier, required this.count});

  final MoveQuality tier;
  final int count;

  @override
  Widget build(BuildContext context) {
    final dim = count == 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SvgPicture.asset(
            tier.svgAssetPath,
            width: 12,
            height: 12,
            colorFilter: dim
                ? const ColorFilter.mode(Color(0x66808080), BlendMode.srcATop)
                : null,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              tier.label,
              style: ApexTypography.bodyMedium.copyWith(
                color: dim
                    ? ApexColors.textTertiary
                    : tier.color.withAlpha(230),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$count',
            style: ApexTypography.bodyMedium.copyWith(
              color: dim ? ApexColors.textTertiary : ApexColors.textPrimary,
              fontSize: 11,
              fontFamily: 'JetBrains Mono',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Counts strip ───────────────────────────────────────────────────

// ignore: unused_element
class _CountsStrip extends StatelessWidget {
  const _CountsStrip({required this.counts});

  final ReviewCounts counts;

  @override
  Widget build(BuildContext context) {
    final rows = <(MoveQuality, int)>[
      (MoveQuality.brilliant, counts.brilliant),
      (MoveQuality.great, counts.great),
      (MoveQuality.best, counts.best),
      (MoveQuality.excellent, counts.excellent),
      (MoveQuality.good, counts.good),
      (MoveQuality.book, counts.book),
      (MoveQuality.inaccuracy, counts.inaccuracy),
      (MoveQuality.mistake, counts.mistake),
      (MoveQuality.missedWin, counts.missedWin),
      (MoveQuality.blunder, counts.blunder),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      decoration: BoxDecoration(
        color: ApexColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COUNTS',
            style: ApexTypography.labelLarge.copyWith(
              fontSize: 10,
              letterSpacing: 1.6,
              color: ApexColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: rows
                .where((e) => e.$2 > 0)
                .map((e) => _CountChip(tier: e.$1, count: e.$2))
                .toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.tier, required this.count});

  final MoveQuality tier;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: tier.color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tier.color.withAlpha(110), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(tier.svgAssetPath, width: 14, height: 14),
          const SizedBox(width: 6),
          Text(
            '${tier.label} · $count',
            style: ApexTypography.bodyMedium.copyWith(
              color: tier.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Highlights ─────────────────────────────────────────────────────

class _HighlightsBlock extends StatelessWidget {
  const _HighlightsBlock({required this.summary});

  final ReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    final h = summary.highlights;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ApexColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KEY MOMENTS',
            style: ApexTypography.labelLarge.copyWith(
              fontSize: 10,
              letterSpacing: 1.6,
              color: ApexColors.textTertiary,
            ),
          ),
          const SizedBox(height: 10),
          _HighlightRow(
            label: 'Brilliant moment',
            move: h.brilliantMoment,
            emptyCopy: 'No Brilliant move in this game.',
          ),
          const SizedBox(height: 8),
          _HighlightRow(
            label: 'Best move',
            move: h.bestUserMove,
            emptyCopy: 'No standout best move — steady play.',
          ),
          const SizedBox(height: 8),
          _HighlightRow(
            label: 'Biggest mistake',
            move: h.biggestMistake,
            emptyCopy: 'No major mistake found.',
          ),
          const SizedBox(height: 8),
          _HighlightRow(
            label: 'Turning point',
            move: h.keyTurningPoint,
            emptyCopy: 'No decisive swing — balanced game.',
          ),
          if (h.checkmate != null) ...[
            const SizedBox(height: 8),
            _HighlightRow(label: 'Checkmate', move: h.checkmate, emptyCopy: ''),
          ],
        ],
      ),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  const _HighlightRow({
    required this.label,
    required this.move,
    required this.emptyCopy,
  });

  final String label;
  final MoveAnalysis? move;
  final String emptyCopy;

  @override
  Widget build(BuildContext context) {
    if (move == null) {
      return Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              emptyCopy,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      );
    }
    final m = move!;
    final moveNum = '${(m.ply ~/ 2) + 1}${m.ply.isEven ? '.' : '…'}';
    final visibleLabel = MoveQualityDisplay.labelForMove(m);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    m.classification.svgAssetPath,
                    width: 14,
                    height: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$moveNum ${m.san} — ${visibleLabel.label}',
                      style: ApexTypography.bodyMedium.copyWith(
                        color: visibleLabel.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Phase block ────────────────────────────────────────────────────

class _PhaseBlock extends StatelessWidget {
  const _PhaseBlock({required this.summary});

  final ReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    final weakest = summary.weakestPhase;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ApexColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'PHASE PERFORMANCE',
                  style: ApexTypography.labelLarge.copyWith(
                    fontSize: 10,
                    letterSpacing: 1.6,
                    color: ApexColors.textTertiary,
                  ),
                ),
              ),
              if (weakest != null)
                Text(
                  'Weakest: ${_phaseLabel(weakest.phase)}',
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.mistake.withAlpha(220),
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          for (final phase in summary.phases) ...[
            _PhaseRow(
              breakdown: phase,
              isWeakest: weakest?.phase == phase.phase,
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }

  static String _phaseLabel(GamePhase p) {
    switch (p) {
      case GamePhase.opening:
        return 'Opening';
      case GamePhase.middlegame:
        return 'Middlegame';
      case GamePhase.endgame:
        return 'Endgame';
    }
  }
}

class _PhaseRow extends StatelessWidget {
  const _PhaseRow({required this.breakdown, required this.isWeakest});

  final PhaseBreakdown breakdown;
  final bool isWeakest;

  @override
  Widget build(BuildContext context) {
    final empty = breakdown.plies == 0;
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            _label(breakdown.phase),
            style: ApexTypography.bodyMedium.copyWith(
              color: isWeakest
                  ? ApexColors.mistake.withAlpha(220)
                  : ApexColors.textPrimary,
              fontSize: 12,
              fontWeight: isWeakest ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            empty
                ? '—'
                : '${breakdown.accuracyPct.toStringAsFixed(0)}% · ACPL '
                      '${breakdown.averageCpLoss.toStringAsFixed(1)} · '
                      '${breakdown.plies} plies',
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textSecondary,
              fontSize: 11,
              fontFamily: 'JetBrains Mono',
            ),
          ),
        ),
      ],
    );
  }

  static String _label(GamePhase p) {
    switch (p) {
      case GamePhase.opening:
        return 'Opening';
      case GamePhase.middlegame:
        return 'Middlegame';
      case GamePhase.endgame:
        return 'Endgame';
    }
  }
}

// ── CTA row ────────────────────────────────────────────────────────

class _CtaRow extends StatelessWidget {
  const _CtaRow({
    required this.isQuick,
    this.onReanalyzeDeep,
    this.onSaveGame,
    this.onAddMistakesToAcademy,
  });

  final bool isQuick;
  final OnReanalyzeDeep? onReanalyzeDeep;
  final OnSaveGame? onSaveGame;
  final OnAddMistakesToAcademy? onAddMistakesToAcademy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ReviewScreen()));
          },
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Start Review'),
          style: ElevatedButton.styleFrom(
            backgroundColor: ApexColors.electricBlue,
            foregroundColor: ApexColors.darkSurface,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        if (isQuick && onReanalyzeDeep != null) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => onReanalyzeDeep!.call(),
            icon: const Icon(Icons.radar_rounded),
            label: const Text('Re-analyze'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ApexColors.inaccuracy,
              side: BorderSide(
                color: ApexColors.inaccuracy.withAlpha(180),
                width: 0.7,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
        if (onAddMistakesToAcademy != null) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => onAddMistakesToAcademy!.call(),
            icon: const Icon(Icons.school_rounded),
            label: const Text('Add Mistakes to Academy'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ApexColors.textPrimary,
              side: BorderSide(color: ApexColors.subtleBorder, width: 0.7),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
        if (onSaveGame != null) ...[
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => onSaveGame!.call(),
            icon: const Icon(Icons.bookmark_add_rounded),
            label: const Text('Save Game'),
            style: TextButton.styleFrom(
              foregroundColor: ApexColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

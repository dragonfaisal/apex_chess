/// Premium evaluation bar — cinematic horizontal White/Black indicator.
///
/// Renders the sigmoid Win% as a filled gradient strip (White fill on the
/// left, Black fill on the right) with a numerical score badge that
/// handles every UCI edge case:
///
///   * `cp == null && mateIn == null`   → em-dash, neutral colour
///   * `mateIn != null`                  → `M<n>` in the mater's colour
///   * negative `cp`                     → shows a minus sign and Black
///                                         badge (high-contrast)
///   * extreme `cp` (e.g. ±99999 from a mate-in-N fallback)
///                                       → clamped to `±99.9`
///   * `isSearching == true`             → spinner in the trailing slot
///
/// Colouring and text alignment are mirrored when the board is flipped
/// (Black at the bottom), so the user's side always reads on the left.
library;

import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

class ApexEvalBar extends StatelessWidget {
  const ApexEvalBar({
    super.key,
    required this.scoreCp,
    required this.mateIn,
    required this.depth,
    this.isSearching = false,
    this.errorMessage,
    this.flipped = false,
    this.openingLabel,
    this.height = 52,
  });

  /// Centipawn eval from **White's** POV.
  final int? scoreCp;

  /// Moves-to-mate from **White's** POV (positive = White mates).
  final int? mateIn;

  /// Search depth reached (0 if unknown).
  final int depth;

  /// Whether a new eval is in flight (shows a spinner).
  final bool isSearching;

  /// Fatal error; when present, replaces the body with a red explainer.
  final String? errorMessage;

  /// Board orientation — mirrors the badge to match the user's POV.
  final bool flipped;

  /// Optional opening name / ECO code to display inline.
  final String? openingLabel;

  final double height;

  // ── Derived state ────────────────────────────────────────────────────
  double get _winPercent {
    if (mateIn != null) return mateIn! > 0 ? 100 : 0;
    if (scoreCp == null) return 50;
    // Logistic curve mirroring EvaluationAnalyzer.calculateWinPercentage.
    final clamped = scoreCp!.clamp(-1000, 1000).toDouble();
    final w = 2.0 / (1.0 + _expApprox(-0.00368208 * clamped)) - 1.0;
    return 50 + 50 * w;
  }

  static double _expApprox(double x) {
    // Tiny wrapper so the file doesn't need to import `dart:math`.
    // Using the identity exp(x) = (1 + x/n)^n with n=1024 is plenty
    // accurate for visual-only eval bar fill.
    var y = 1.0 + x / 1024.0;
    for (var i = 0; i < 10; i++) {
      y = y * y;
    }
    return y;
  }

  String get _scoreText {
    if (errorMessage != null) return '…';
    if (mateIn != null) return 'M${mateIn!.abs()}';
    if (scoreCp == null) return '—';
    final pawns = (scoreCp! / 100).clamp(-99.9, 99.9);
    final sign = pawns >= 0 ? '+' : '';
    return '$sign${pawns.toStringAsFixed(1)}';
  }

  /// True when the position favours White (badge renders light).
  bool get _whiteBetter {
    if (mateIn != null) return mateIn! > 0;
    if (scoreCp == null) return true;
    return scoreCp! >= 0;
  }

  @override
  Widget build(BuildContext context) {
    final winPct = _winPercent;
    final isError = errorMessage != null;
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ApexColors.elevatedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isError
              ? ApexColors.mistake.withValues(alpha: 0.45)
              : ApexColors.subtleBorder,
          width: 0.6,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Fill strip beneath everything — subtle so it doesn't fight the
          // numeric badge for attention.
          if (!isError)
            Positioned.fill(
              child: _FillStrip(winPercent: winPct, flipped: flipped),
            ),
          Row(
            children: [
              _ScoreBadge(
                text: _scoreText,
                whiteBetter: _whiteBetter,
                isError: isError,
                flipped: flipped,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isError
                    ? Text(
                        errorMessage!,
                        style: ApexTypography.bodyMedium.copyWith(
                          color: ApexColors.ruby.withValues(alpha: 0.85),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : Row(
                        children: [
                          if (depth > 0)
                            Text(
                              'D$depth',
                              style: ApexTypography.bodyMedium.copyWith(
                                color: ApexColors.textTertiary,
                                fontFamily: 'JetBrains Mono',
                                fontSize: 12,
                              ),
                            ),
                          if (openingLabel != null) ...[
                            const SizedBox(width: 10),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: ApexColors.book
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: ApexColors.book
                                        .withValues(alpha: 0.35),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  openingLabel!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: ApexTypography.bodyMedium.copyWith(
                                    color: ApexColors.book,
                                    fontSize: 11,
                                    fontFamily: 'JetBrains Mono',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
              if (isSearching)
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ApexColors.sapphireBright
                          .withValues(alpha: 0.85),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FillStrip extends StatelessWidget {
  const _FillStrip({required this.winPercent, required this.flipped});

  final double winPercent; // 0..100 — White side share from the left.
  final bool flipped;

  @override
  Widget build(BuildContext context) {
    final fraction = (winPercent / 100).clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final whiteWidth = constraints.maxWidth * fraction;
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ApexColors.trueBlack.withValues(alpha: 0.72),
                    ApexColors.trueBlack.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            Positioned(
              left: flipped ? null : 0,
              right: flipped ? 0 : null,
              top: 0,
              bottom: 0,
              width: whiteWidth,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: flipped
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    end: flipped
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.95),
                      Colors.white.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Centre dividing line for the 50/50 mark reference.
            Positioned(
              left: constraints.maxWidth / 2 - 0.5,
              top: 0,
              bottom: 0,
              width: 1,
              child: ColoredBox(
                color: ApexColors.sapphire.withValues(alpha: 0.18),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({
    required this.text,
    required this.whiteBetter,
    required this.isError,
    required this.flipped,
  });

  final String text;
  final bool whiteBetter;
  final bool isError;
  final bool flipped;

  @override
  Widget build(BuildContext context) {
    // When `whiteBetter` is true, render on light surface; otherwise dark.
    final light = flipped ? !whiteBetter : whiteBetter;
    final bg = isError
        ? ApexColors.cardSurface
        : (light ? Colors.white : ApexColors.trueBlack);
    final fg = isError
        ? ApexColors.ruby
        : (light ? ApexColors.trueBlack : Colors.white);
    return Container(
      width: 76,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(13.5),
          bottomLeft: Radius.circular(13.5),
        ),
      ),
      child: Text(
        text,
        style: ApexTypography.monoEval.copyWith(color: fg, fontSize: 16),
      ),
    );
  }
}

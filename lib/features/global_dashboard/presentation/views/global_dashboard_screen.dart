/// Global Dashboard — multi-chart analytics across the user's entire
/// archive. Corporate-analytics feel: hero KPI cards, accuracy trend,
/// move-quality distribution, result split, and a paginated recent-
/// games table. Everything reads from the local Hive archive — no
/// network, no engine, instant.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';

import '../controllers/dashboard_controller.dart';

class GlobalDashboardScreen extends ConsumerWidget {
  const GlobalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
        child: SafeArea(
          child: Column(
            children: [
              _AppBar(),
              Expanded(
                child: stats.hasData
                    ? _DashboardBody(stats: stats)
                    : const _EmptyState(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              ApexCopy.dashboardTitle,
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
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights_rounded,
                size: 72, color: ApexColors.sapphire.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text(
              ApexCopy.dashboardEmpty,
              textAlign: TextAlign.center,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ApexCopy.dashboardSubtitle,
            textAlign: TextAlign.center,
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 12,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 16),
          _KpiRow(stats: stats),
          const SizedBox(height: 18),
          _AccuracyTrendCard(stats: stats),
          const SizedBox(height: 14),
          _QualityPieCard(stats: stats),
          const SizedBox(height: 14),
          _ResultSplitCard(stats: stats),
          const SizedBox(height: 18),
          const _RecentGamesTable(),
        ],
      ),
    );
  }
}

// ── KPI row ────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _KpiCard(
        label: 'Games',
        value: '${stats.gamesAnalyzed}',
        accent: ApexColors.sapphire,
        icon: Icons.analytics_rounded,
      ),
      _KpiCard(
        label: 'Avg Accuracy',
        value: '${stats.averageAccuracy.toStringAsFixed(1)}%',
        accent: ApexColors.emerald,
        icon: Icons.auto_graph_rounded,
      ),
      _KpiCard(
        label: 'Brilliants',
        value: '${stats.totalBrilliants}',
        accent: ApexColors.aurora,
        icon: Icons.auto_awesome_rounded,
      ),
      _KpiCard(
        label: 'Blunders',
        value: '${stats.totalBlunders}',
        accent: ApexColors.ruby,
        icon: Icons.error_outline_rounded,
      ),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        // Auto-wrap into 2×2 on narrow phones, 1×4 on tablets / desktop.
        final crossAxisCount = box.maxWidth >= 640 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: crossAxisCount == 4 ? 1.35 : 1.55,
          children: cards,
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
  });

  final String label;
  final String value;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(12),
      accentColor: accent,
      accentAlpha: 0.45,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accent),
          Text(
            value,
            style: ApexTypography.headlineMedium.copyWith(
              color: ApexColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Accuracy trend ─────────────────────────────────────────────────────

class _AccuracyTrendCard extends StatelessWidget {
  const _AccuracyTrendCard({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      accentColor: ApexColors.emerald,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(
            title: 'ACCURACY TREND',
            subtitle: 'Higher is better — one point per analysed game.',
            accent: ApexColors.emerald,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: LineChart(_data(stats.accuracyTrend)),
          ),
        ],
      ),
    );
  }

  LineChartData _data(List<double> trend) {
    final spots = <FlSpot>[];
    for (var i = 0; i < trend.length; i++) {
      spots.add(FlSpot(i.toDouble(), trend[i]));
    }
    final maxX = spots.isEmpty
        ? 1.0
        : (spots.length - 1).toDouble().clamp(1.0, double.infinity);
    return LineChartData(
      minY: 0,
      maxY: 100,
      minX: 0,
      maxX: maxX,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 25,
        getDrawingHorizontalLine: (value) => FlLine(
          color: ApexColors.stardustLine.withValues(alpha: 0.35),
          strokeWidth: 0.6,
          dashArray: const [4, 4],
        ),
      ),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => ApexColors.cosmicDust,
          getTooltipItems: (items) => items
              .map((s) => LineTooltipItem(
                    '${s.y.toStringAsFixed(1)}%',
                    ApexTypography.bodyMedium.copyWith(
                      color: ApexColors.textPrimary,
                      fontSize: 11,
                    ),
                  ))
              .toList(),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          preventCurveOverShooting: true,
          barWidth: 2.4,
          color: ApexColors.emeraldBright,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ApexColors.emerald.withValues(alpha: 0.45),
                ApexColors.emerald.withValues(alpha: 0.02),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Quality pie ────────────────────────────────────────────────────────

class _QualityPieCard extends StatelessWidget {
  const _QualityPieCard({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final entries = stats.qualityDistribution.entries
        .where((e) => e.value > 0 && e.key != MoveQuality.book)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (s, e) => s + e.value);

    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      accentColor: ApexColors.sapphire,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(
            title: 'MOVE QUALITY',
            subtitle: 'Aggregate distribution across every ply scanned.',
            accent: ApexColors.sapphire,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 36,
                      startDegreeOffset: -90,
                      sections: entries.isEmpty
                          ? []
                          : entries
                              .map((e) => PieChartSectionData(
                                    value: e.value.toDouble(),
                                    color: _qualityColor(e.key),
                                    radius: 42,
                                    title: '',
                                  ))
                              .toList(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: entries
                        .map((e) => _LegendChip(
                              color: _qualityColor(e.key),
                              label: _qualityLabel(e.key),
                              count: e.value,
                              percent: total == 0 ? 0 : e.value / total,
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _qualityColor(MoveQuality q) => switch (q) {
        MoveQuality.brilliant => ApexColors.brilliant,
        MoveQuality.best => ApexColors.best,
        MoveQuality.excellent => ApexColors.great,
        MoveQuality.good => ApexColors.sapphireDeep,
        MoveQuality.inaccuracy => ApexColors.inaccuracy,
        MoveQuality.mistake => ApexColors.mistake,
        MoveQuality.blunder => ApexColors.blunder,
        MoveQuality.book => ApexColors.book,
      };

  String _qualityLabel(MoveQuality q) => switch (q) {
        MoveQuality.brilliant => 'Brilliant',
        MoveQuality.best => 'Best',
        MoveQuality.excellent => 'Excellent',
        MoveQuality.good => 'Solid',
        MoveQuality.inaccuracy => 'Inaccuracy',
        MoveQuality.mistake => 'Mistake',
        MoveQuality.blunder => 'Blunder',
        MoveQuality.book => 'Theory',
      };
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.label,
    required this.count,
    required this.percent,
  });

  final Color color;
  final String label;
  final int count;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.55), blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textSecondary,
                fontSize: 11.5,
              ),
            ),
          ),
          Text(
            '$count · ${(percent * 100).toStringAsFixed(0)}%',
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textPrimary,
              fontSize: 11,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Result split ───────────────────────────────────────────────────────

class _ResultSplitCard extends StatelessWidget {
  const _ResultSplitCard({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final hasPerspective =
        stats.perspective != null && stats.perspective!.isNotEmpty;
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      accentColor: ApexColors.ruby,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(
            title: 'RESULT SPLIT',
            subtitle: hasPerspective
                ? 'From the perspective of @${stats.perspective!}.'
                : 'Connect an account to resolve W/L/D — showing unresolved only.',
            accent: ApexColors.ruby,
          ),
          const SizedBox(height: 14),
          if (!hasPerspective)
            Text(
              'No perspective set. Connect an account on Home → Connect Account.',
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textTertiary,
                fontSize: 11.5,
              ),
            )
          else
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: [stats.wins, stats.draws, stats.losses]
                      .fold<int>(0, (m, v) => v > m ? v : m)
                      .toDouble()
                      .clamp(1, double.infinity),
                  barTouchData: BarTouchData(enabled: false),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (v, meta) {
                          final label = switch (v.toInt()) {
                            0 => 'Wins',
                            1 => 'Draws',
                            2 => 'Losses',
                            _ => '',
                          };
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              label,
                              style: ApexTypography.bodyMedium.copyWith(
                                color: ApexColors.textTertiary,
                                fontSize: 10.5,
                                letterSpacing: 0.6,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    _bar(0, stats.wins.toDouble(), ApexColors.emerald),
                    _bar(1, stats.draws.toDouble(), ApexColors.sapphire),
                    _bar(2, stats.losses.toDouble(), ApexColors.ruby),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) => BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: y,
            width: 28,
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [color.withValues(alpha: 0.55), color],
            ),
          ),
        ],
      );
}

// ── Recent games table ─────────────────────────────────────────────────

class _RecentGamesTable extends ConsumerWidget {
  const _RecentGamesTable();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slice = ref.watch(dashboardVisibleGamesProvider);
    final page = ref.watch(dashboardPageProvider);
    final total = ref.watch(dashboardStatsProvider).gamesAnalyzed;
    final hasPrev = page > 0;
    final hasNext = (page + 1) * dashboardPageSize < total;

    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      accentColor: ApexColors.sapphire,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(
            title: 'RECENT SCANS',
            subtitle:
                'Page ${page + 1} • ${slice.length}/$total shown.',
            accent: ApexColors.sapphire,
          ),
          const SizedBox(height: 8),
          ...slice.map((g) => _RecentRow(game: g)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: hasPrev
                    ? () => ref
                        .read(dashboardPageProvider.notifier)
                        .prev()
                    : null,
                icon: const Icon(Icons.chevron_left_rounded),
                color: ApexColors.textSecondary,
                disabledColor: ApexColors.textTertiary
                    .withValues(alpha: 0.35),
              ),
              IconButton(
                onPressed: hasNext
                    ? () => ref
                        .read(dashboardPageProvider.notifier)
                        .next()
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
                color: ApexColors.textSecondary,
                disabledColor: ApexColors.textTertiary
                    .withValues(alpha: 0.35),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.game});
  final ArchivedGame game;

  @override
  Widget build(BuildContext context) {
    final acc = (100 - game.averageCpLoss).clamp(0, 100);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              '${game.white} vs ${game.black}',
              overflow: TextOverflow.ellipsis,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              game.result,
              textAlign: TextAlign.center,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textSecondary,
                fontSize: 11,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${acc.toStringAsFixed(0)}%',
              textAlign: TextAlign.right,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.emeraldBright,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared bits ────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 6,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [accent, accent.withValues(alpha: 0.2)],
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ApexTypography.titleMedium.copyWith(
                  color: ApexColors.textPrimary,
                  letterSpacing: 2,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary,
                  fontSize: 10.5,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Lichess-style Advantage Chart using fl_chart.
///
/// Plots Win% (0–100) for each ply. 50% = equal.
/// Area above 50% fills with a White/Cyan gradient.
/// Area below 50% fills with a Charcoal/Dark Blue gradient.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

class EvaluationChart extends StatelessWidget {
  final List<double> winPercentages;
  final int? selectedPly;
  final ValueChanged<int>? onPlySelected;

  const EvaluationChart({
    super.key,
    required this.winPercentages,
    this.selectedPly,
    this.onPlySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (winPercentages.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: ApexColors.elevatedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11.5),
        child: LineChart(_buildChartData(),
            duration: const Duration(milliseconds: 150)),
      ),
    );
  }

  LineChartData _buildChartData() {
    final spots = <FlSpot>[];
    for (int i = 0; i < winPercentages.length; i++) {
      spots.add(FlSpot(i.toDouble(), winPercentages[i]));
    }
    return LineChartData(
      minY: 0, maxY: 100, minX: 0,
      maxX: (winPercentages.length - 1).toDouble().clamp(1, double.infinity),
      gridData: FlGridData(
        show: true, drawVerticalLine: false, horizontalInterval: 50,
        getDrawingHorizontalLine: (value) {
          if (value == 50) {
            return FlLine(color: ApexColors.textTertiary.withAlpha(80),
                strokeWidth: 1, dashArray: [4, 4]);
          }
          return FlLine(color: Colors.transparent);
        },
      ),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        enabled: onPlySelected != null,
        touchCallback: (event, response) {
          if (event is FlTapUpEvent && response?.lineBarSpots != null) {
            final spot = response!.lineBarSpots!.first;
            onPlySelected?.call(spot.x.toInt());
          }
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => ApexColors.cardSurface,
          getTooltipItems: (spots) => spots.map((spot) {
            final ply = spot.x.toInt();
            final moveNum = (ply ~/ 2) + 1;
            final side = ply % 2 == 0 ? 'W' : 'B';
            return LineTooltipItem(
              '$moveNum$side: ${spot.y.toStringAsFixed(1)}%',
              TextStyle(color: ApexColors.textPrimary, fontSize: 11,
                  fontFamily: 'JetBrains Mono'));
          }).toList(),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots, isCurved: true, curveSmoothness: 0.2,
          color: ApexColors.electricBlue, barWidth: 1.5,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true,
            getDotPainter: (spot, _, __, ___) {
              final isSelected = selectedPly != null &&
                  spot.x.toInt() == selectedPly;
              if (isSelected) {
                return FlDotCirclePainter(radius: 4,
                    color: ApexColors.electricBlue, strokeWidth: 2,
                    strokeColor: ApexColors.textPrimary);
              }
              return FlDotCirclePainter(radius: 0,
                  color: Colors.transparent, strokeWidth: 0,
                  strokeColor: Colors.transparent);
            }),
          belowBarData: BarAreaData(show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [
                ApexColors.electricBlue.withAlpha(0),
                ApexColors.electricBlue.withAlpha(0),
                const Color(0xFF0A1628).withAlpha(60),
                const Color(0xFF0A1628).withAlpha(100),
              ], stops: const [0.0, 0.5, 0.5, 1.0])),
          aboveBarData: BarAreaData(show: true,
            cutOffY: 50, applyCutOffY: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [
                Colors.white.withAlpha(30),
                ApexColors.electricBlue.withAlpha(20),
                ApexColors.electricBlue.withAlpha(0),
              ], stops: const [0.0, 0.5, 1.0])),
        ),
      ],
      extraLinesData: ExtraLinesData(horizontalLines: [
        HorizontalLine(y: 50,
            color: ApexColors.textTertiary.withAlpha(40), strokeWidth: 0.5),
      ]),
    );
  }
}

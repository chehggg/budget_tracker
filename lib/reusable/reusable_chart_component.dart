import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

FlTitlesData getCustomChartTitleData({required BuildContext context, AxisTitles? bottomTitle, AxisTitles? topTitle}) =>
    FlTitlesData(
      rightTitles: AxisTitles(drawBelowEverything: false),
      topTitles: topTitle ?? AxisTitles(drawBelowEverything: false),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          getTitlesWidget:
              (value, meta) => Text(
                NumberFormat.compact().format(value),
                textAlign: TextAlign.right,
                style: context.customTt.numberFontSmall!.copyWith(fontSize: 10),
              ),
          reservedSize: 24,
          showTitles: false,
          maxIncluded: true,
        ),
      ),
      bottomTitles: bottomTitle ?? const AxisTitles(),
    );

LineChartBarData getCustomLineChartBarData({
  required List<FlSpot> spots,
  required Color color,
  bool isCurved = false,
  bool showGradient = true,
  List<int>? dashArray,
  FlDotData? dotData,
  List<int> showingIndicators = const [],
}) {
  return LineChartBarData(
    curveSmoothness: 0.5,
    isCurved: isCurved,
    dashArray: dashArray,
    barWidth: 1.5,
    isStrokeCapRound: true,
    isStrokeJoinRound: true,
    showingIndicators: showingIndicators,
    belowBarData: BarAreaData(
      show: showGradient,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [(color.withAlpha(50)), Colors.transparent],
      ),
    ),
    color: color,
    dotData: dotData ?? const FlDotData(show: false),
    spots: spots,
  );
}

FlGridData get customGrid {
  return FlGridData(
    show: true,
    drawVerticalLine: false,
    getDrawingHorizontalLine: (value) => FlLine(strokeWidth: 0.5, color: Colors.white.withAlpha(50), dashArray: [1,5]),
  );
}

LineTouchData getCustomLineTouchData({
  required BuildContext context,
  GetLineTooltipItems? getTooltipItems,
}) {
  return LineTouchData(
    getTouchedSpotIndicator: (barData, spotIndexes) {
      return spotIndexes
          .map(
            (el) => TouchedSpotIndicatorData(
              FlLine(strokeWidth: 1, color: barData.color),
              FlDotData(),
            ),
          )
          .toList();
    },
    touchSpotThreshold: 50,
    touchTooltipData: LineTouchTooltipData(
      tooltipHorizontalAlignment: FLHorizontalAlignment.left,
      getTooltipColor: (touchedSpot) {
        return context.cs.surface;
      },
      getTooltipItems: getTooltipItems ?? defaultLineTooltipItem,
      tooltipHorizontalOffset: 20,
      fitInsideVertically: true,
      fitInsideHorizontally: true,
    ),
  );
}

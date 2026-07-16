import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

ExtraLinesData getExtraLines(BuildContext context, {required List<double> y}) {
  return ExtraLinesData(
    horizontalLines:
        y.map((y) {
          return HorizontalLine(
            y: 0,
            color: context.customCs.fadeColor2,
            dashArray: [2, 10],
          );
        }).toList(),
  );
}

FlTitlesData getCustomChartTitleData({
  required BuildContext context,
  AxisTitles? bottomTitle,
  // AxisTitles? leftTitle,
  bool showLeft = false,
  AxisTitles? topTitle,
}) => FlTitlesData(
  rightTitles: AxisTitles(drawBelowEverything: false),
  topTitles: topTitle ?? AxisTitles(drawBelowEverything: false),
  leftTitles: AxisTitles(
    sideTitles: SideTitles(
      showTitles: showLeft,
      getTitlesWidget:
          (value, meta) => Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              NumberFormat.compact().format(value),
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: context.customTt.numberFontSmall!.copyWith(
                fontSize: 10,
                color: context.customCs.fadeColor1,
              ),
            ),
          ),
      reservedSize: 30,
      minIncluded: false,
      maxIncluded: false,
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
    aboveBarData: BarAreaData(
      applyCutOffY: true,
      show: showGradient,
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [(color.withAlpha(50)), Colors.transparent],
      ),
    ),
    belowBarData: BarAreaData(
      applyCutOffY: true,
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
    getDrawingHorizontalLine:
        (value) => FlLine(strokeWidth: 0.5, color: Colors.white.withAlpha(50), dashArray: [1, 5]),
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
              FlLine(strokeWidth: 1, color: barData.color ?? Colors.white),
              FlDotData(
                getDotPainter: (spot, p1, p2, p3) {
                  return FlDotCirclePainter(color: p2.color ?? Colors.white);
                },
              ),
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

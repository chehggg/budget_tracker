import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

ExtraLinesData getHorizontalExtraLines(
  BuildContext context, {
  required List<double> y,
  List<double>? x,
  List<bool>? showYLabel,
  List<bool>? dash,
  List<String?>? texts,
}) {
  return ExtraLinesData(
    horizontalLines:
        y.mapIndexed((index, y) {
          final value = context.read<CurrencyRepository>().formatCurrency(
            y,
            abbreviated: true,
            compact: true,
            showSymbol: false,
          );
          return HorizontalLine(
            y: y,
            color: context.customCs.fadeColor1,
            strokeWidth: dash?.elementAtOrNull(index) ?? true ? 1 : 0.5,
            dashArray: (dash?.elementAtOrNull(index) ?? true) ? [2, 10] : null,
            label: HorizontalLineLabel(
              show: showYLabel?.elementAtOrNull(index) ?? false,
              padding: EdgeInsets.only(bottom: 6),
              alignment: Alignment.topRight,
              style: context.customTt.paragraphTextSmall!.copyWith(
                fontSize: 9,
                color: context.customCs.fadeColor1,
                height: 1.2,
              ),
              labelResolver: (line) {
                return texts?.elementAtOrNull(index) ?? "Target: $value";
              },
            ),
          );
        }).toList(),
    verticalLines:
        x?.map((element) {
          return VerticalLine(x: element, color: context.customCs.fadeColor1, strokeWidth: 0.5);
        }).toList() ??
        [],
  );
}

FlTitlesData getCustomChartTitleData({
  required BuildContext context,
  AxisTitles? bottomTitle,
  // AxisTitles? leftTitle,
  bool padLeft = false,
  bool showLeft = false,
  bool padRight = false,
  bool showRight = false,
  AxisTitles? topTitle,
}) => FlTitlesData(
  topTitles: topTitle ?? AxisTitles(drawBelowEverything: false),
  leftTitles: AxisTitles(
    sideTitles: SideTitles(
      showTitles: showLeft || padLeft,
      getTitlesWidget:
          (value, meta) => Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child:
                !padLeft
                    ? Text(
                      NumberFormat.compact().format(value),
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: context.customTt.numberFontSmall!.copyWith(
                        fontSize: 10,
                        color: context.customCs.fadeColor1,
                      ),
                    )
                    : SizedBox.shrink(),
          ),
      reservedSize: 30,
      minIncluded: false,
      maxIncluded: false,
    ),
  ),
  rightTitles: AxisTitles(
    sideTitles: SideTitles(
      showTitles: showRight || padRight,
      getTitlesWidget:
          (value, meta) => Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child:
                !padRight
                    ? Text(
                      NumberFormat.compact().format(value),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: context.customTt.numberFontSmall!.copyWith(
                        fontSize: 10,
                        color: context.customCs.fadeColor1,
                      ),
                    )
                    : SizedBox.shrink(),
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
  double? barWidth,
}) {
  return LineChartBarData(
    curveSmoothness: 0.5,
    isCurved: isCurved,
    dashArray: dashArray,
    barWidth: barWidth ?? 1.5,
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
  bool enabled = true,
  BaseTouchCallback<LineTouchResponse>? touchCallback,
  Color Function(LineBarSpot)? getTooltipColor,
  CalculateTouchDistance? distanceCalculator,
}) {
  return LineTouchData(
    enabled: true,
    handleBuiltInTouches: enabled,
    touchCallback: touchCallback,
    distanceCalculator:
        distanceCalculator ??
        ((Offset touchPoint, Offset spotPixelCoordinates) =>
            (touchPoint.dx - spotPixelCoordinates.dx).abs()),
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
      tooltipMargin: 400,
      tooltipHorizontalAlignment: FLHorizontalAlignment.left,
      getTooltipColor:
          getTooltipColor ??
          (touchedSpot) {
            return context.cs.surface.withAlpha(200);
          },
      getTooltipItems: getTooltipItems ?? defaultLineTooltipItem,
      tooltipHorizontalOffset: 0,
      fitInsideVertically: true,
      fitInsideHorizontally: true,
      // showOnTopOfTheChartBoxArea: true,
    ),
  );
}

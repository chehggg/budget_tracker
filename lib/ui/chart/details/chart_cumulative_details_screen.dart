import 'dart:math';

import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/reusable_chart_component.dart';
import 'package:budget_tracker/ui/chart/chart_reusables.dart';
import 'package:budget_tracker/ui/chart/chart_screen.dart';
import 'package:budget_tracker/ui/chart/chart_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CumulativeBalanceDetailScreen extends StatefulWidget {
  const CumulativeBalanceDetailScreen({super.key});

  @override
  State<CumulativeBalanceDetailScreen> createState() => _CumulativeBalanceDetailScreenState();
}

class _CumulativeBalanceDetailScreenState extends State<CumulativeBalanceDetailScreen> {
  bool _showDiff = false;

  @override
  Widget build(BuildContext context) {
    final metric = context.select((ChartViewModel state) => state.chartMetric);
    final overview = context.select((ChartViewModel state) => state.cumulativeComparison);
    final maxLength = context.chartMod.xRange;
    final change = context.chartMod.getPercentageChange(
      current: overview.first,
      previous: overview.last,
    );
    final columns = [
      "Day",
      context.chartMod.prevRangeStart.formatMonth(),
      context.chartMod.rangeStart.formatMonth(),
      "Change %",
    ];

    return CustomScaffold(
      appBarTitle: Text("Details"),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            sliver: SliverToBoxAdapter(
              child: CustomChartDetailTitleBar(
                title: "Cumulative",
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              child: Row(
                spacing: 12,
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 2,
                    child: SegmentedButton(
                      showSelectedIcon: false,
                      segments:
                          ChartMetric.values
                              .map(
                                (el) => ButtonSegment(value: el, label: Text(el.name.capitalize())),
                              )
                              .toList(),
                      style: SegmentedButton.styleFrom(
                        visualDensity: VisualDensity(vertical: -0),
                        side: BorderSide(color: context.customCs.fadeColor2!),
                      ),
                      onSelectionChanged: (value) {
                        context.chartMod.updateChartMetric(value.first);
                      },
                      selected: {metric},
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: CustomDropDownMenu(
                      initSelection: "Total",
                      onSelected: (value) {
                        setState(() {
                          _showDiff = value != "Total";
                        });
                      },
                      entries:
                          [
                            "Total",
                            "Change",
                          ].map((el) => DropdownMenuEntry(value: el, label: el)).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!_showDiff)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              sliver: SliverToBoxAdapter(
                child: NewCumulativeLineChart(
                  titleData: getCustomChartTitleData(
                    context: context,
                    showLeft: true,
                    bottomTitle: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final isMatch = context.chartMod.matchLabelDate(value.round());
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Transform.scale(
                              scale: isMatch ? 1.2 : 1,
                              child: Text(
                                context.chartMod.getInitials(
                                  value.round(),
                                  useInitials: true,
                                  useDotForMonth: true,
                                ),
                                style: context.tt.bodyMedium!.copyWith(
                                  fontSize: 10,
                                  color: context.cs.primary.withAlpha(isMatch ? 250 : 100),
                                  fontWeight: FontWeight(600),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (!_showDiff)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
                child: Row(
                  spacing: 12,
                  children: [
                    LabelIndicator(
                      text: context.chartMod.curDisplayPeriod,
                      color: context.chartMod.accentColors.current,
                      fade: true,
                    ),
                    LabelIndicator(
                      text: context.chartMod.prevDisplayPeriod,
                      color: context.chartMod.accentColors.previous,
                      fade: true,
                    ),
                  ],
                ),
              ),
            ),

          if (_showDiff)
            SliverToBoxAdapter(
              child: PercentageChangeLineChart(
                change: change,
              ),
            ),
          if (_showDiff)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Row(
                  spacing: 12,
                  children: [
                    LabelIndicator(
                      text:
                          context.chartMod.chartMetric == ChartMetric.expense
                              ? "Lower than previous"
                              : "Higher than previous",
                      color: context.chartMod.accentColors.positive,
                      fade: true,
                    ),
                    LabelIndicator(
                      text:
                          context.chartMod.chartMetric == ChartMetric.expense
                              ? "Higher than previous"
                              : "Lower than previous",
                      color: context.chartMod.accentColors.negative,
                      fade: true,
                    ),
                  ],
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: DataTable(
                columnSpacing: 4,
                horizontalMargin: 0,
                dataRowMaxHeight: 60,
                dataRowMinHeight: 40,
                dataTextStyle: context.tt.bodyMedium,
                headingTextStyle: context.customTt.numberFontSmall,
                dividerThickness: 0,
                border: TableBorder(
                  horizontalInside: BorderSide.none,
                ),
                columns:
                    columns.map((el) {
                      return DataColumn(
                        label: Text(el),
                        headingRowAlignment: MainAxisAlignment.center,
                      );
                    }).toList(),
                rows:
                    List.generate(maxLength, (index) {
                      final prev = overview.last.entries.elementAtOrNull(index);
                      final current = overview.first.entries.elementAtOrNull(index);

                      final el = [prev, current];
                      final currentVal = change.values.elementAt(index);
                      final currentChange = currentVal['change'];
                      final currentPercentage = currentVal['percentage'];
                      return DataRow(
                        cells: [
                          // DataCell(Center(child: Text((i + 1).toString()))),
                          DataCell(
                            Center(child: Text((context.chartMod.getInitials(index)).toString())),
                          ),
                          ...el.map((entry) {
                            return DataCell(
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 2,
                                  children: [
                                    Text(
                                      entry == null
                                          ? "-"
                                          : context.chartMod.compactCurrencyFormat(
                                            entry.value,
                                          ),
                                    ),
                                    if (entry != null)
                                      Text(
                                        context.chartMod.showMonths
                                            ? entry.key.formatMonth()
                                            : entry.key.formatPrettyShort(),
                                        style: context.customTt.paragraphTextSmall,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          DataCell(
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 2,
                                children: [
                                  Text(
                                    currentChange == null
                                        ? "-"
                                        : context.chartMod.compactCurrencyFormat(
                                          currentChange,
                                        ),
                                  ),
                                  if (currentPercentage != null)
                                    Text(
                                      currentPercentage.isInfinite || currentPercentage.isNaN
                                          ? "-"
                                          : currentPercentage.formatSignedCompactPercentage(),
                                      style: context.customTt.paragraphTextSmall!.copyWith(
                                        color:
                                            currentPercentage.isInfinite || currentPercentage.isNaN
                                                ? null
                                                : context.chartMod.getChangePercentageColor(
                                                  currentPercentage,
                                                ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
            ),
          ),
        ],
      ),
    );
  }
}

class PercentageChangeLineChart extends StatelessWidget {
  const PercentageChangeLineChart({
    super.key,
    required this.change,
  });

  final Map<int, Map<String, double?>> change;

  @override
  Widget build(BuildContext context) {
    final maxChange = change.entries.fold(
      double.negativeInfinity,
      (init, entry) => max(init, entry.value['change'] ?? double.negativeInfinity),
    );
    final minChange = change.entries.fold(
      double.infinity,
      (init, entry) => min(init, entry.value['change'] ?? double.infinity),
    );
    final stop = ((maxChange - 0) / (maxChange - minChange)).clamp(0.0, 1.0);
    return Container(
      height: 180,
      padding: EdgeInsets.only(left: 12, right: 12),
      child: LineChart(
        LineChartData(
          lineTouchData: getCustomLineTouchData(
            context: context,
            getTooltipItems:
                (touchedSpots) =>
                    touchedSpots.map((el) {
                      final index = el.spotIndex;
                      final percentage = change.values.elementAtOrNull(index)?['percentage'] ?? 0;
                      final y = el.y;
                      final initials = context.chartMod.getInitials(index, useInitials: false);
                      return LineTooltipItem(
                        "${context.chartMod.period == ChartPeriod.month ? "D" : ""}"
                        "$initials\n",
                        context.customTt.numberFontSmall!.copyWith(
                          fontSize: 10,
                          color: context.customCs.fadeColor1,
                        ),
                        children: [
                          TextSpan(
                            text: context.chartMod.currencyFormat(
                              y,
                              alwaysShowSign: true,
                              abbreviated: true,
                              compact: true,
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text:
                                " (${percentage.isFinite ? percentage.formatSignedCompactPercentage() : "-"})",
                            style: TextStyle(
                              color:
                                  percentage.isFinite
                                      ? context.chartMod.getChangePercentageColor(
                                        percentage,
                                      )
                                      : context.customCs.fadeColor1,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
          ),
          titlesData: getCustomChartTitleData(
            context: context,
            showLeft: true,
            bottomTitle: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final isMatch = context.chartMod.matchLabelDate(value.round());
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Transform.scale(
                      scale: isMatch ? 1.2 : 1,
                      child: Text(
                        context.chartMod.getInitials(
                          value.round(),
                          useInitials: true,
                          useDotForMonth: true,
                        ),
                        style: context.tt.bodyMedium!.copyWith(
                          fontSize: 10,
                          color: context.cs.primary.withAlpha(isMatch ? 250 : 100),
                          fontWeight: FontWeight(600),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: customGrid,
          borderData: FlBorderData(show: false),
          maxX: change.length - 1,
          extraLinesData: getHorizontalExtraLines(context, y: [0]),
          lineBarsData: [
            LineChartBarData(
              barWidth: 1,
              isStrokeCapRound: true,
              isStrokeJoinRound: true,
              aboveBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    (context.chartMod.getChangePercentageColor(-1).withAlpha(50)),
                    Colors.transparent,
                  ],
                ),
                applyCutOffY: true,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (context.chartMod.getChangePercentageColor(1).withAlpha(50)),
                    Colors.transparent,
                  ],
                ),
                applyCutOffY: true,
              ),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  context.chartMod.getChangePercentageColor(1),
                  context.chartMod.getChangePercentageColor(1),
                  context.chartMod.getChangePercentageColor(-1),
                  context.chartMod.getChangePercentageColor(-1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, stop, stop, 1],
              ),
              preventCurveOverShooting: true,
              // color: Colors.white,
              dotData: FlDotData(
                checkToShowDot: (spot, barData) {
                  return true;
                },
                getDotPainter: (spot, p1, data, p3) {
                  return FlDotCirclePainter(
                    radius: 2,
                    color: context.chartMod.getChangePercentageColor(
                      spot.y,
                    ),
                  );
                },
              ),
              spots:
                  change.entries
                      .where(
                        (el) => el.value['change'] != null && el.value['change']!.isFinite,
                      )
                      .map((el) {
                        return FlSpot(el.key.toDouble(), el.value['change']!);
                      })
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

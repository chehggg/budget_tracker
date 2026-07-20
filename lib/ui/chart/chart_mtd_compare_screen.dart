import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/reusable_chart_component.dart';
import 'package:budget_tracker/ui/chart/chart_reusables.dart';
import 'package:budget_tracker/ui/chart/chart_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChartMtdCompareScreen extends StatelessWidget {
  const ChartMtdCompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.select((ChartViewModel state) => state.balanceOverview);
    final curOverview = context.select((ChartViewModel state) => state.curRangeSummary);
    final prevOverview = context.select((ChartViewModel state) => state.prevRangeToDayCumulative);
    return CustomScaffold(
      padHorizontal: true,
      appBarTitle: Text("Comparison"),
      child: CustomSpacedScrollView(
        children: [
          CustomChartDetailTitleBar(
            title: "MTD Comparsion",
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 14, right: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  data.entries.map((el) {
                    final prevValue = el.value['previous'] ?? 0;
                    final currentValue = el.value['current'] ?? 0;

                    final change = (currentValue - prevValue) * (el.key == "expense" ? -1 : 1);
                    final changePercentage = change / prevValue.abs();
                    final largerBetter = el.key != 'expense';
                    final symbol =
                        (changePercentage.isNaN || changePercentage.isInfinite)
                            ? ""
                            : (changePercentage >= 0 ? "▲ " : "▼ ");
                    final isGood =
                        (largerBetter && changePercentage >= 0) ||
                        (!largerBetter && changePercentage < 0);
                    final color =
                        (changePercentage.isInfinite || changePercentage.isNaN)
                            ? context.customCs.fadeColor1
                            : isGood
                            ? Colors.green.shade400
                            : Colors.red.shade400;
                    return Column(
                      spacing: 4,
                      children: [
                        Text(
                          el.key.capitalize(),
                          style: context.customTt.numberFontSmall!.copyWith(fontSize: 14),
                        ),
                        // Text(, style: context.customTt.numberFontSmall!.copyWith(color: color, fontSize: 20)),
                        Text(
                          symbol + changePercentage.formatCompactPercentage().replaceAll('-', ''),
                          style: context.customTt.numberFontSmall!.copyWith(
                            color: color,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          context.chartMod.currencyFormat(change, alwaysShowSign: true),
                          style: context.tt.bodyMedium!.copyWith(color: color, fontSize: 14),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 40, right: 40),
            child: SizedBox(
              height: 160,
              child: MtdChart(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: [
                LabelIndicator(
                  color: Colors.blue,
                  text: "Previous",
                ),
                LabelIndicator(
                  color: Colors.amber,
                  text: "Current",
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20, bottom: 10),
            child: Divider(),
          ),
          Text('MTD Expense%', style: context.customTt.dateLabel),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                ...[curOverview, prevOverview].mapIndexed((i, el) {
                  final percentage = ((el.expense ?? 0) / (el.income ?? 1)).clamp(0.01, 1.00);
                  return Column(
                    spacing: 4,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        spacing: 12,
                        children: [
                          // Flexible(
                          //   flex: 3,
                          //   fit: FlexFit.tight,
                          //   child: Text(
                          //     i == 0 ? "Current" : "Previous",
                          //     style: context.customTt.numberFontSmall,
                          //   ),
                          // ),
                          // Flexible(
                          //   flex: 1,
                          //   fit: FlexFit.tight,
                          //   child: Text(
                          //     "",
                          //     // context.chartMod.currencyFormat(change, alwaysShowSign: true),
                          //     textAlign: TextAlign.end,
                          //     style: context.customTt.numberFontMedium!.copyWith(
                          //       color: color,
                          //       fontSize: 12,
                          //     ),
                          //   ),
                          // ),
                          // Flexible(
                          //   flex: 1,
                          //   fit: FlexFit.tight,
                          //   child: Text(
                          //     symbol +
                          //         changePercentage.formatCompactPercentage().replaceAll("-", ""),
                          //     textAlign: TextAlign.end,
                          //     style: context.customTt.numberFontMedium!.copyWith(
                          //       color: color,
                          //       fontSize: 18,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(
                        height: 36,
                        width: double.infinity,
                        child: Stack(
                          alignment: AlignmentGeometry.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20, bottom: 4),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: context.chartMod.accentColors.positive.withAlpha(100),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                width: double.infinity,
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: percentage,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: context.chartMod.accentColors.negative,
                                      // color: currentBigger ? Colors.blue.shade900 : Colors.amber,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: VerticalDivider(
                                color: Colors.white,
                                thickness: 1,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: percentage == 1 ? 0 : null,
                              left:
                                  percentage == 1
                                      ? null
                                      : (percentage * context.mq.size.width - 50).clamp(
                                        0,
                                        context.mq.size.width,
                                      ),
                              child: Text(
                                "Till ${i == 0 ? context.chartMod.curMTD.formatShorter() : context.chartMod.previousMTD.formatShorter()}: ${percentage.formatCompactPercentage()}",
                                style: context.customTt.paragraphTextSmall,
                              ),
                            ),
                            // Positioned(
                            //   top: 0,
                            //   left: 0,
                            //   child: Text("Current Month", style: context.customTt.paragraphTextSmall),
                            // ),
                          ],
                        ),
                      ),
                      Column(
                        spacing: 4,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Expense",
                                style: context.customTt.paragraphTextSmall,
                              ),
                              Text(
                                "Income",
                                style: context.customTt.paragraphTextSmall,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.chartMod.currencyFormat(el.expense ?? 0, compact: true),
                                style: context.customTt.numberFontSmall!,
                              ),
                              Text(
                                context.chartMod.currencyFormat(el.income ?? 0, compact: true),
                                style: context.customTt.numberFontSmall!,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MtdChart extends StatelessWidget {
  const MtdChart({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.select((ChartViewModel state) => state.balanceOverview);
    return BarChart(
      BarChartData(
        rotationQuarterTurns: 0,
        alignment: BarChartAlignment.spaceBetween,
        gridData: customGrid,
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(y: 0, color: context.customCs.fadeColor2, dashArray: [2, 5]),
          ],
        ),
        barTouchData: BarTouchData(
          enabled: false,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: EdgeInsets.only(top: 20),
            direction: TooltipDirection.bottom,
            tooltipHorizontalAlignment: FLHorizontalAlignment.center,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem("", context.tt.bodyMedium!);
              // if (large) {
              //   return BarTooltipItem("", context.tt.bodyMedium!);
              // }
            },
            getTooltipColor: (group) {
              return Colors.transparent;
            },
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: getCustomChartTitleData(
          context: context,
        ),
        barGroups:
            data.entries.mapIndexed((index, dataEntry) {
              final int largerIndex =
                  dataEntry.value.entries.first.value.abs() >
                          dataEntry.value.entries.last.value.abs()
                      ? 0
                      : 1;
              return BarChartGroupData(
                // groupVertically: true,
                barsSpace: 2,
                showingTooltipIndicators: [largerIndex],
                x: index,
                barRods:
                    dataEntry.value.entries.map((entry) {
                      return BarChartRodData(
                        borderRadius: BorderRadius.circular(3),
                        toY: entry.value,
                        label: BarChartRodLabel(
                          show: true,
                          offset: Offset(entry.key == "current" ? 20 : -20, 10),
                          text:
                              entry.value != 0
                                  ? context.chartMod.currencyFormat(
                                    entry.value,
                                    abbreviated: true,
                                    compact: true,
                                    alwaysShowSign: true,
                                  )
                                  : "",
                          style: context.customTt.paragraphText!.copyWith(fontSize: 10),
                        ),
                        width: 12,
                        color:
                            entry.key == "current"
                                ? context.cs.secondary
                                : Colors.blue.shade700.withAlpha(200),
                      );
                    }).toList(),
              );
            }).toList(),
      ),
    );
  }
}

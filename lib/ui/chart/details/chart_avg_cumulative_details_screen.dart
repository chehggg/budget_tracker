import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/reusable_chart_component.dart';
import 'package:budget_tracker/ui/chart/details/chart_cumulative_details_screen.dart';
import 'package:budget_tracker/ui/chart/chart_reusables.dart';
import 'package:budget_tracker/ui/chart/chart_screen.dart';
import 'package:budget_tracker/ui/chart/chart_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AvgCumulativeBalanceDetailScreen extends StatefulWidget {
  const AvgCumulativeBalanceDetailScreen({super.key});

  @override
  State<AvgCumulativeBalanceDetailScreen> createState() => _AvgCumulativeBalanceDetailScreenState();
}

class _AvgCumulativeBalanceDetailScreenState extends State<AvgCumulativeBalanceDetailScreen> {
  bool _showDiff = false;

  @override
  Widget build(BuildContext context) {
    final metric = context.select((ChartViewModel state) => state.chartMetric);
    final overview = context.select((ChartViewModel state) => state.avgCumulativeComparison);
    final maxLength = context.chartMod.xRange;
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
                title: "Cumulative Average",
                dialogTitle: "Cumulative Graph",
                dialogDescription: Text.rich(
                  TextSpan(
                    text:
                        "This chart tracks the running average of costs across your selected date range."
                        "The value is calculated by dividing the cumulative total by the number of days elapsed up to that point."
                        "\n- Ongoing ranges: from start date up until today."
                        "\n- Completed ranges: from start date up until end of the period."
                        "\nThe change graph compares the current cumulative data against the same points in previous period."
                        "For example, when viewing monthly data for July 2026, the change compares the data between 1 July with 1 Jun, 2 July with 2 Jun, etc."
                        "\n- Expense: Positive change implies higher cost in current period (undesirable)"
                        "\n- Income & Balance: Positive change indicates a higher balance in current period (desirable).",
                  ),
                ),
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
          if (_showDiff)
            SliverToBoxAdapter(
              child: PercentageChangeLineChart(
                change: context.chartMod.getPercentageChange(
                  previous: overview.first,
                  current: overview.last,
                ),
              ),
            ),
          if (!_showDiff)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              sliver: SliverToBoxAdapter(
                child: NewAverageCumulativeLineChart(
                  titleData: getCustomChartTitleData(
                    showLeft: true,
                    context: context,
                    bottomTitle: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 30,
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final isMatch = context.chartMod.matchLabelDate(value.round());
                          return Padding(
                            padding: const EdgeInsets.only(top: 16.0),
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
                      final prev = overview.first.entries.elementAtOrNull(index);
                      final current = overview.last.entries.elementAtOrNull(index);
                      final el = [prev, current];
                      final change =
                          el.first?.value == null || el.last?.value == null
                              ? null
                              : (el.last!.value - el.first!.value);
                      final percentage =
                          change == null ? null : ((change) / (el.first?.value ?? 1).abs());
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
                                          : context.chartMod.currencyFormat(
                                            entry.value,
                                            abbreviated: true,
                                            compact: true,
                                            showSymbol: false,
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
                                    change == null
                                        ? "-"
                                        : context.chartMod.currencyFormat(
                                          change,
                                          abbreviated: true,
                                          compact: true,
                                          showSymbol: false,
                                        ),
                                  ),
                                  if (percentage != null)
                                    Text(
                                      percentage.isInfinite || percentage.isNaN
                                          ? "-"
                                          : percentage.formatSignedCompactPercentage(),
                                      style: context.customTt.paragraphTextSmall!.copyWith(
                                        color:
                                            percentage.isInfinite || percentage.isNaN
                                                ? null
                                                : context.chartMod.getChangePercentageColor(
                                                  percentage,
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

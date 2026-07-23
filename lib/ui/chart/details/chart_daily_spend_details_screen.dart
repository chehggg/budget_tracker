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
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DailySpendDetailsScreen extends StatefulWidget {
  const DailySpendDetailsScreen({super.key});

  @override
  State<DailySpendDetailsScreen> createState() => _DailySpendDetailsScreenState();
}

class _DailySpendDetailsScreenState extends State<DailySpendDetailsScreen> {
  bool _showDiff = false;

  @override
  Widget build(BuildContext context) {
    final metric = context.select((ChartViewModel state) => state.chartMetric);

    return CustomScaffold(
      appBarTitle: Text("Details"),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            sliver: SliverToBoxAdapter(
              child: CustomChartDetailTitleBar(
                title: "Daily Spend",
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
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              sliver: SliverToBoxAdapter(
                child: DifferenceBarChart(),
              ),
            ),
          if (!_showDiff)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              sliver: SliverToBoxAdapter(
                child: DailyBarChart(
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
                              alignment: Alignment.center,
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
            child: DailySpendTable(),
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

class DailySpendTable extends StatelessWidget {
  const DailySpendTable({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final overview = context.select((ChartViewModel state) => state.dailyCost);
    final metric = context.select((ChartViewModel state) => state.chartMetric);
    final columns = [
      "Day",
      context.chartMod.prevRangeStart.formatMonth(),
      context.chartMod.rangeStart.formatMonth(),
      "Change %",
    ];
    return Theme(
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
            overview.mapIndexed((index, row) {
              final prev = row.entries.first;
              final cur = row.entries.last;
              final prevVal = metric.getCostMetric(prev.value);
              final curValue = metric.getCostMetric(cur.value);
              final diff = (curValue ?? 0) - (prevVal ?? 0);
              final percentage = diff / ((prevVal ?? 1).abs());
              final showValues =
                  prev.key.isBeforeOrSameMoment(DateTime.now().standard) &&
                  cur.key.isBeforeOrSameMoment(DateTime.now().standard);
              return DataRow(
                cells: [
                  DataCell(
                    Center(child: Text((context.chartMod.getInitials(index)).toString())),
                  ),
                  ...row.entries.map((entry) {
                    final costMetric = metric.getCostMetric(entry.value);
                    final showValue = entry.key.isBeforeOrSameMoment(DateTime.now().standard);
                    return DataCell(
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          context.chartMod.updateListDate(entry.key);
                          context.go('/');
                        },
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 2,
                            children: [
                              Text(
                                showValue
                                    ? context.chartMod.currencyFormat(
                                      costMetric ?? 0,
                                      abbreviated: true,
                                      compact: true,
                                      showSymbol: false,
                                    )
                                    : "-",
                              ),
                              if (showValue)
                                Text(
                                  context.chartMod.showMonths
                                      ? entry.key.formatMonth()
                                      : entry.key.formatPrettyShort(),
                                  style: context.customTt.paragraphTextSmall,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (row.entries.length == 1)
                    DataCell(
                      Center(child: Text("-")),
                    ),
                  DataCell(
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 2,
                        children: [
                          Text(
                            showValues
                                ? context.chartMod.currencyFormat(
                                  diff,
                                  abbreviated: true,
                                  compact: true,
                                  showSymbol: false,
                                )
                                : "-",
                          ),
                          if (showValues)
                            Text(
                              percentage.formatSignedCompactPercentage(),
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
    );
  }
}

class DifferenceBarChart extends StatelessWidget {
  const DifferenceBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final overview = context.select((ChartViewModel state) => state.dailyCost);
    final metric = context.select((ChartViewModel state) => state.chartMetric);
    return Container(
      height: 180,
      padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          gridData: customGrid,
          borderData: FlBorderData(show: false),
          extraLinesData: getHorizontalExtraLines(context, y: [0]),
          titlesData: getCustomChartTitleData(
            showLeft: true,
            context: context,
            bottomTitle: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      context.chartMod.getInitials(
                        value.round(),
                        useDotForMonth: true,
                        useInitials: true,
                      ),
                      style: context.tt.bodyMedium!.copyWith(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups:
              overview.mapIndexed((index, el) {
                final prev = el.entries.first;
                final current = el.entries.last;
                final prevValue = metric.getCostMetric(prev.value);
                final curValue = metric.getCostMetric(current.value);
                final diff = (curValue ?? 0) - (prevValue ?? 0);
                final percentage = diff / ((prevValue ?? 1).abs());
                final showValues =
                    prev.key.isBeforeOrSameMoment(DateTime.now().standard) &&
                    current.key.isBeforeOrSameMoment(DateTime.now().standard);
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      width: 4,
                      toY: percentage.isFinite && showValues ? diff : 0,
                      color: context.chartMod.getChangePercentageColor(diff),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}

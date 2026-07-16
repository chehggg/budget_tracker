import 'dart:math';
import 'dart:ui';

import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/languages.dart';
import 'package:budget_tracker/reusable/reusable_chart_component.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/chart/chart_reusables.dart';
import 'package:budget_tracker/ui/chart/chart_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/ui/list/main_list_screen.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final contextWatch = context.watch<ChartViewModel>();
    final ready = context.select((ChartViewModel state) => state.ready);
    final showMonth = context.chartMod.showMonths;

    final displayPeriod = context.chartMod.curDisplayPeriod;
    final displayDetailsPeriod = context.chartMod.displayDetailsPeriodDuration;

    final FlTitlesData chartTitleData = getCustomChartTitleData(
      context: context,
      showLeft: true,
      bottomTitle: AxisTitles(
        sideTitles: SideTitles(
          interval: 1,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                context.chartMod.getInitials(
                  value.round(),
                  useInitials: true,
                  useDotForMonth: true,
                ),
                style: context.tt.bodyMedium!.copyWith(fontSize: 10),
              ),
            );
          },
          showTitles: true,
          maxIncluded: true,
        ),
      ),
    );

    SliverPadding getDivider() => SliverPadding(
      padding: const EdgeInsets.only(top: 18, bottom: 4),
      sliver: SliverToBoxAdapter(
        child: Divider(),
      ),
    );

    return CustomScaffold(
      appBarTitle: Text(
        AppLocale.aboutTitle.getString(context),
      ),
      ready: ready,
      safeAreaPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        children: [
          ChartFilterButtons(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: ChartHeaderDelegate(
                    displayPeriod: displayPeriod,
                    displayDetailsPeriod: displayDetailsPeriod,
                  ),
                ),
                ChartSection(
                  title: "MoM Overview",
                  child: YearMonthOverview(),
                ),
                getDivider(),
                // ChartSection(
                //   title: showMonth ? "YTM Overview" : "MTD Overview",
                //   pathName: '/chart/balance-compare',
                //   showLabelSubtitle: true,
                //   child: SummaryData(),
                // ),
                const ChartSection(
                  title: "Category Breakdown",
                  pathName: '/chart/category-breakdown',
                  child: CategoryBreakdownChart(),
                ),
                getDivider(),
                ChartSection(
                  title: showMonth ? "Monthly Spend" : "Daily Spend",
                  pathName: '/chart/daily-spend',
                  showLabelSubtitle: true,
                  child: DailyBarChart(
                    titleData: chartTitleData,
                  ),
                ),
                getDivider(),
                ChartSection(
                  title: "Cumulative",
                  showLabelSubtitle: true,
                  pathName: '/chart/cumulative-balance',
                  child: NewCumulativeLineChart(
                    titleData: chartTitleData,
                  ),
                ),
                getDivider(),
                ChartSection(
                  title: "Cumulative Average",
                  pathName: '/chart/cumulative-avg',
                  showLabelSubtitle: true,
                  child: NewAverageCumulativeLineChart(
                    titleData: chartTitleData,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartFilterButtons extends StatelessWidget {
  const ChartFilterButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final period = context.select((ChartViewModel state) => state.period);
    return Column(
      spacing: 8,
      children: [
        Container(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: context.cs.surface),
          height: 44,
          width: double.infinity,
          child: SegmentedButton(
            style: SegmentedButton.styleFrom(
              side: BorderSide(color: context.customCs.fadeColor1?.withAlpha(120) ?? Colors.white),
              visualDensity: VisualDensity(vertical: 0),
              textStyle: context.customTt.dateLabel?.copyWith(fontSize: 20),
            ),
            showSelectedIcon: false,
            onSelectionChanged: (value) => context.chartMod.updatePeriod(value.first),
            segments:
                ChartPeriod.values
                    .map(
                      (el) => ButtonSegment(
                        value: el,
                        label: Text(
                          el.name.capitalize(),
                        ),
                      ),
                    )
                    .toList(),
            selected: {period},
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 12.0),
        //   child: GestureDetector(
        //     behavior: HitTestBehavior.translucent,
        //     onHorizontalDragEnd: (details) {
        //       if (details.primaryVelocity == null) return;
        //       if (details.primaryVelocity!.abs() < 100) return;
        //       debugPrint(details.primaryVelocity!.toStringAsFixed(0));
        //       context.chartMod.updatePeriodDuration(increase: details.primaryVelocity! < 0);
        //     },
        //     child: ReusableContainer(
        //       height: 120,
        //       padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        //       width: double.infinity,
        //       filled: true,
        //       highlight: true,
        //       child: Row(
        //         children: [
        //           // Icon(
        //           //   Icons.keyboard_arrow_left_rounded,
        //           //   color: context.cs.surface,
        //           //   size: 40,
        //           // ),
        //           Expanded(
        //             child: Column(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 Text(
        //                   "Current View",
        //                   style: context.customTt.numberFontSmall?.copyWith(
        //                     color: context.cs.onSecondary.withAlpha(200),
        //                     fontSize: 14,
        //                     fontWeight: FontWeight(600),
        //                   ),
        //                 ),
        //                 Text(
        //                   displayPeriod,
        //                   style: context.customTt.numberFontLarge?.copyWith(
        //                     color: context.cs.surface,
        //                     fontSize: 52,
        //                     height: 1.1,
        //                   ),
        //                 ),
        //                 SizedBox(
        //                   height: 3,
        //                 ),
        //                 Text(
        //                   displayDetailsPeriod,
        //                   style: context.customTt.paragraphText?.copyWith(
        //                     color: context.cs.surface,
        //                     fontSize: 16,
        //                     height: 1.3,
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ),
        //           Icon(Icons.arrow_right_outlined, color: context.cs.surface),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

class ChartSection extends StatelessWidget {
  const ChartSection({
    super.key,
    this.showLabelSubtitle = false,
    required this.title,
    required this.child,
    this.pathName,
  });

  final String title;
  final Widget child;
  final bool showLabelSubtitle;
  final String? pathName;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 12.0, left: 12, right: 12),
      sliver: SliverToBoxAdapter(
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: context.customTt.dateLabel,
                      ),
                    ),
                    IconButton(
                      onPressed:
                          () =>
                              pathName != null
                                  ? context.push(pathName!, extra: context.chartMod)
                                  : null,
                      icon: FaIcon(FontAwesomeIcons.angleRight, size: 18),
                    ),
                  ],
                ),
                if (showLabelSubtitle)
                  Row(
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
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class CategoryBreakdownChart extends StatelessWidget {
  const CategoryBreakdownChart({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.select((ChartViewModel state) => state.simplifiedCurRangeCategorySummary);
    final total = context.select((ChartViewModel state) => state.curRangeSummary);
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12, bottom: 12),
      child: Row(
        spacing: 30,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 150,
            width: 140,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 60,
                startDegreeOffset: -90,
                sections: [
                  ...data.entries.map(
                    (e) => PieChartSectionData(
                      color: e.key.color ?? Colors.amber,
                      cornerRadius: 12,
                      value: e.value.expense ?? 0,
                      radius: 8,
                      titlePositionPercentageOffset: 3,
                      // badgeWidget: Column(
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      //     Text(e.key.name ?? ""),
                      //     Text(
                      //       NumberFormat.percentPattern().format(e.value.expense! / total.expense!),
                      //     ),
                      //   ],
                      // ),
                      showTitle: false,
                      badgePositionPercentageOffset: 5,
                      // title:
                      //     e.key.name ??
                      //     " ${NumberFormat.percentPattern().format(e.value.expense! / total.expense!)}",
                    ),
                  ),
                  // PieChartSectionData(
                  //   value: total.expense,
                  //   color: Colors.transparent,
                  //   showTitle: false,
                  // ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Column(
              spacing: 8,
              children: [
                ...data.entries.map(
                  (e) {
                    final percentage = e.value.expense! / total.expense!;
                    return Row(
                      spacing: 8,
                      children: [
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: LabelIndicator(
                            text: e.key.capName,
                            color: e.key.color ?? Colors.amber,
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: Text(
                            context.chartMod.currencyFormat(
                              e.value.expense!,
                              abbreviated: true,
                              compact: true,
                            ),
                            style: context.tt.bodyMedium!.copyWith(
                              fontSize: 12,
                              color: context.cs.primary,
                            ),
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: Text(
                            "(${NumberFormat.percentPattern().format(percentage)})",
                            style: context.tt.bodyMedium!.copyWith(
                              fontSize: 12,
                              color: context.cs.primary,
                            ),
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class CategoryBreakdownList extends StatelessWidget {
//   const CategoryBreakdownList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final summary = context.select((ChartViewModel state) => state.categoryComparison);
//     return ListView.builder(
//       itemCount: summary.length,
//       itemBuilder: (context, index) {
//         final category = summary.entries.elementAt(index).key;
//         final metrics = summary.entries.elementAt(index).value;
//         final prevRangeValue = metrics.first.expense ?? 0;
//         final curRangeValue = metrics.last.expense ?? 0;
//         final percentageChange = (curRangeValue / prevRangeValue).abs();
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Row(
//             spacing: 20,
//             children: [
//               CategoryIconContainer(
//                 category: category,
//                 size: 24,
//               ),
//               Expanded(
//                 child: Column(
//                   spacing: 4,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(child: Text(category.capName)),
//                         Text(
//                           "${curRangeValue.customCurrencyFormat("RM")} (${NumberFormat.percentPattern().format(percentageChange)})",
//                         ),
//                       ],
//                     ),
//                     Container(
//                       width: double.infinity,
//                       height: 8,
//                       decoration: BoxDecoration(
//                         color: context.customCs.fadeColor2,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: FractionallySizedBox(
//                         widthFactor: min(percentageChange, 1),
//                         alignment: Alignment.centerLeft,
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: percentageChange > 1 ? Colors.red : context.customCs.fadeColor1,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // CategoryIconContainer(category: category),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

class DailyBarChart extends StatelessWidget {
  const DailyBarChart({
    super.key,
    this.titleData,
  });

  final FlTitlesData? titleData;

  @override
  Widget build(BuildContext context) {
    final data = context.select((ChartViewModel state) => state.dayToDayComparison);
    final showMonths = context.select((ChartViewModel state) => state.showMonths);
    final curRangeStart = context.chartMod.rangeStart;
    final prevRangeStart = context.chartMod.prevRangeStart;
    return Container(
      height: 180,
      padding: EdgeInsets.only(top: 12),
      child: BarChart(
        duration: Durations.medium1,
        BarChartData(
          extraLinesData: getExtraLines(context, y: [0]),
          alignment: BarChartAlignment.spaceBetween,
          // groupsSpace: 20,
          barTouchData: BarTouchData(
            touchExtraThreshold: EdgeInsets.all(20),
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => context.cs.surface,
              tooltipHorizontalOffset: 0,
              fitInsideHorizontally: true,
              // fitInsideVertically: true,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final String curDate =
                    showMonths
                        ? curRangeStart.addMonth(group.x).formatMonth()
                        : curRangeStart.addDay(group.x).formatShorter();
                final String prevDate =
                    showMonths
                        ? prevRangeStart.addMonth(group.x).formatMonth()
                        : prevRangeStart.addDay(group.x).formatShorter();
                return BarTooltipItem(
                  "$curDate: ${context.chartMod.currencyFormat(group.barRods.first.toY)}\n"
                  "$prevDate: ${context.chartMod.currencyFormat(group.barRods.last.toY)}",
                  context.tt.bodyMedium!.copyWith(fontSize: 10),
                  textAlign: TextAlign.end,
                );
              },
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: customGrid,
          titlesData: titleData,
          // maxY: maxValue,
          barGroups:
              data.mapIndexed((i, el) {
                return BarChartGroupData(
                  x: i,
                  groupVertically: true,
                  barRods:
                      el.entries.map(
                        (entry) {
                          final isPrev = entry.key.isBefore(curRangeStart);
                          return BarChartRodData(
                            width: isPrev ? 2 : 5,
                            color:
                                isPrev ? Colors.blue.shade400.withAlpha(150) : context.cs.secondary,
                            toY: context.chartMod.chartMetric.getCostMetric(entry.value) ?? 0,
                          );
                        },
                      ).toList(),
                );
              }).toList(),
        ),
      ),
    );
  }
}

class SummaryData extends StatelessWidget {
  const SummaryData({super.key, this.large = false});

  final bool large;
  @override
  Widget build(BuildContext context) {
    final data = context.select((ChartViewModel state) => state.balanceOverview);
    final size = 220.0;
    final balanceOffset = context.chartMod.balanceOffset;
    return Container(
      height: size,
      padding: EdgeInsets.only(bottom: 30, left: 10, right: 10, top: 30),
      child: Stack(
        // spacing: 40,
        children: [
          ...data.entries.map((el) {
            final alignment = switch (el.key) {
              "expense" => Alignment(-1, -1.15),
              "income" =>
                el.value.entries.fold(0.0, (init, entry) => max(init, entry.value)) == 0
                    ? Alignment(-1, 0.07)
                    : Alignment(1, 0.07),
              "balance" => Alignment(balanceOffset, 1.25),
              _ => Alignment(0, 0),
            };
            final prevValue = el.value['previous'] ?? 0;
            final currentValue = el.value['current'] ?? 0;

            final changePercentage =
                (el.key == 'expense' ? -1 : 1) * currentValue.calculatePercentageChange(prevValue);

            final largerBetter = el.key != 'expense';
            final symbol =
                (changePercentage.isNaN || changePercentage.isInfinite)
                    ? ""
                    : (changePercentage >= 0 ? "▲ " : "▼ ");
            final isGood =
                (largerBetter && changePercentage >= 0) || (!largerBetter && changePercentage < 0);
            final color =
                (changePercentage.isInfinite || changePercentage.isNaN)
                    ? context.customCs.fadeColor1
                    : isGood
                    ? context.chartMod.accentColors.positive
                    : context.chartMod.accentColors.negative;
            return Positioned.fill(
              child: Align(
                alignment: alignment,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        el.key.capitalize(),
                        style: context.tt.bodyMedium!.copyWith(fontSize: 12),
                      ),
                      Text(
                        "${symbol} ${changePercentage.formatCompactPercentage().replaceAll('-', '')}",
                        style: context.customTt.numberFontSmall!.copyWith(
                          fontSize: 12,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Padding(
            padding: EdgeInsets.only(left: 70, right: context.chartMod.padRight ? 70 : 0),
            // width: ,
            child: BarChart(
              BarChartData(
                rotationQuarterTurns: large ? 0 : 1,
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
                                borderRadius: BorderRadius.circular(large ? 4 : 2),
                                toY: entry.value,
                                label: BarChartRodLabel(
                                  show: !large,
                                  offset:
                                      large
                                          ? Offset(entry.key == "current" ? 14 : -14, 10)
                                          : Offset(entry.key == "current" ? 16 : -16, -30),
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
                                width: large ? 10 : 7,
                                color:
                                    entry.key == "current"
                                        ? context.cs.secondary
                                        : Colors.blue.shade700.withAlpha(200),
                              );
                            }).toList(),
                      );
                    }).toList(),
              ),
            ),
          ),
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     Text("1"),
          //     Text("2"),
          //     Text("3"),
          //   ],
          // ),
        ],
      ),
    );
  }
}

// class BudgetWidget extends StatelessWidget {
//   const BudgetWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final contextRead = context.read<AppModel>();
//     final contextWatch = context.watch<AppModel>();
//     return Column(
//       children:
//           (contextRead.budgetMetrics[contextWatch.formatedSelectedYearMonth] ?? []).map((e) {
//             final double curAmount = e['amount'] ?? 0;
//             final double budgetAmount = e['budget'] ?? 1;

//             final String curAmountString = contextRead.customCurrencyFormat(curAmount, true);
//             final String budgetAmountString = contextRead.customCurrencyFormat(budgetAmount, true);

//             final double spendPercentage = curAmount / budgetAmount;
//             final String budgetMessage =
//                 spendPercentage > 1
//                     ? "${((spendPercentage - 1) * 100).round()}% over"
//                     : "${(spendPercentage * 100).round()}%";

//             return GestureDetector(
//               onTap: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => ChartBudgetDetailsScreen(curBudgetId: e['id']),
//                   ),
//                 );
//                 debugPrint('updated!');
//               },
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // SizedBox(height: 12,),
//                   Container(
//                     width: double.maxFinite,
//                     child: Text(
//                       '${e['name']}',
//                       textAlign: TextAlign.left,
//                       style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 20),
//                     ),
//                   ),
//                   Container(
//                     width: double.maxFinite,
//                     child: Text(
//                       '$budgetMessage ($curAmountString/$budgetAmountString)',
//                       textAlign: TextAlign.left,
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2, top: 8),
//                     child: Container(
//                       height: 50,
//                       decoration: BoxDecoration(
//                         // border: BoxBorder.all(color: Colors.white)
//                       ),
//                       child: Row(
//                         spacing: 30,
//                         children: [
//                           Expanded(
//                             child: BudgetBarChart(
//                               budget: budgetAmount,
//                               current: curAmount,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//     );
//   }
// }

class CustomChartSection extends StatefulWidget {
  const CustomChartSection({
    super.key,
    required this.title,
    required this.pageChildren,
    required this.sectionHeight,
  });

  final String title;
  final double sectionHeight;
  final List<Widget> pageChildren;

  @override
  State<CustomChartSection> createState() => _CustomChartSectionState();
}

class _CustomChartSectionState extends State<CustomChartSection> {
  int _currentDateTrendPageIndex = 0;
  late PageController _controller;

  void updateTrendPage(DragEndDetails details, int pageLength) {
    if (details.primaryVelocity == null || pageLength == 1) return;
    if (details.primaryVelocity! > 200 && _currentDateTrendPageIndex > 0) {
      // scroll left, back
      setState(() {
        _currentDateTrendPageIndex = _currentDateTrendPageIndex - 1;
      });
    } else if (details.primaryVelocity! < -200 && _currentDateTrendPageIndex < pageLength - 1) {
      setState(() {
        _currentDateTrendPageIndex = _currentDateTrendPageIndex + 1;
      });
    }

    _controller.animateToPage(
      _currentDateTrendPageIndex,
      duration: Durations.long1,
      curve: Curves.easeInOutExpo,
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 1);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.sectionHeight,
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          updateTrendPage(details, widget.pageChildren.length);
        },
        child: Column(
          spacing: 0,
          children: [
            Row(
              children: [
                Expanded(
                  child: ChartTitleBar(
                    title: widget.title,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: PageIndicator(
                    pageLength: widget.pageChildren.length,
                    currentPage: _currentDateTrendPageIndex,
                  ),
                ),
              ],
            ),
            Expanded(
              // child: const DateTrendLineChart()
              child: PageView.builder(
                itemCount: widget.pageChildren.length,
                // padEnds: false,
                physics: NeverScrollableScrollPhysics(),
                controller: _controller,
                itemBuilder: (context, index) {
                  return widget.pageChildren[index];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartLegendItem extends StatelessWidget {
  const ChartLegendItem({
    super.key,
    required this.primaryColor,
    required this.title,
    this.trailing,
    this.tileWidth,
    this.fontSize = 13,
  });

  final Color primaryColor;
  final String title;
  final Widget? trailing;

  final double? tileWidth;
  final double? fontSize;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tileWidth,
      child: ListTile(
        leading: Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withAlpha(200),
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: fontSize),
        ),
        visualDensity: VisualDensity(vertical: -4),
        dense: true,
        contentPadding: EdgeInsets.only(right: 16),
        trailing: trailing,
      ),
    );
  }
}

class ChartTitleBar extends StatelessWidget {
  const ChartTitleBar({super.key, this.title, this.description});

  final String? title;
  final String? description;
  @override
  Widget build(BuildContext context) {
    final appTextTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Text(
            title!,
            style: context.customTt.dateLabel!.copyWith(
              // fontSize: 20,
              // color: Theme.of(context).colorScheme.primary
            ),
          ),
        if (description != null)
          Text(
            description!,
            style: appTextTheme.bodyMedium!.copyWith(
              // fontSize: 14
              color: context.cs.primary.withAlpha(180),
            ),
          ),
      ],
    );
  }
}

class PercentageBar extends StatelessWidget {
  const PercentageBar({
    super.key,
    required this.height,
    required this.color,
    required this.percentage,
  });

  final double height;
  final Color color;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: height,
              width: constraint.maxWidth,
              decoration: BoxDecoration(
                color: color.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Container(
              height: height,
              width: constraint.maxWidth * (percentage).abs(),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withAlpha(100),
                    color,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        );
      },
    );
  }
}

class NewCumulativeLineChart extends StatelessWidget {
  const NewCumulativeLineChart({super.key, this.titleData});

  final FlTitlesData? titleData;

  @override
  Widget build(BuildContext context) {
    final cumulativeComparison = context.select(
      (ChartViewModel state) => state.cumulativeComparison,
    );
    final curRangeStart = context.select((ChartViewModel state) => state.rangeStart);
    final prevRangeStart = context.select((ChartViewModel state) => state.prevRangeStart);
    final showMonths = context.select((ChartViewModel state) => state.showMonths);
    final metric = context.select((ChartViewModel state) => state.chartMetric);
    final now = DateTime.now().standard;
    return Container(
      height: 180,
      padding: EdgeInsets.only(top: 12),
      child: LineChart(
        LineChartData(
          titlesData: titleData ?? FlTitlesData(),
          minY: metric != ChartMetric.balance ? 0 : null,
          borderData: FlBorderData(show: false),
          lineTouchData: getCustomLineTouchData(
            context: context,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map(
                (spot) {
                  final isPrev = spot.barIndex == 0;

                  final String curDate =
                      showMonths
                          ? curRangeStart.addMonth(spot.x.round()).formatMonth()
                          : curRangeStart.addDay(spot.x.round()).formatShorter();
                  final String prevDate =
                      showMonths
                          ? prevRangeStart.addMonth(spot.x.round()).formatMonth()
                          : prevRangeStart.addDay(spot.x.round()).formatShorter();
                  return LineTooltipItem(
                    "${isPrev ? prevDate : curDate}: ${context.chartMod.currencyFormat(spot.y, abbreviated: true, compact: true)}",
                    context.customTt.numberFontSmall!.copyWith(
                      fontSize: 10,
                      color:
                          isPrev
                              ? context.chartMod.accentColors.previous
                              : context.chartMod.accentColors.current,
                    ),
                    textAlign: TextAlign.right,
                  );
                },
              ).toList();
            },
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 0,
                dashArray: [2, 10],
                color: context.customCs.fadeColor2,
                strokeWidth: 1,
              ),
            ],
          ),
          gridData: customGrid,
          lineBarsData:
              cumulativeComparison.mapIndexed((i, element) {
                final bool isPrev = i == 0;
                final Color mainColor = isPrev ? Colors.blue.shade300 : context.cs.secondary;
                return getCustomLineChartBarData(
                  showingIndicators: [0],
                  dashArray: isPrev ? [2, 10] : null,
                  color: mainColor,
                  dotData: FlDotData(
                    checkToShowDot: (spot, barData) {
                      if (showMonths) {
                        return !isPrev &&
                            curRangeStart.addMonth(spot.x.round()).isInSameYearMonthAs(now);
                      } else {
                        return !isPrev &&
                            curRangeStart.addDay(spot.x.round()).isAtSameMomentAs(now);
                      }
                    },
                  ),
                  spots: [
                    ...element.entries.map(
                      (entry) {
                        int index;
                        if (showMonths) {
                          index = entry.key.month - element.keys.first.month;
                        } else {
                          index = entry.key.difference(element.keys.first).inDays;
                        }
                        return FlSpot(index.toDouble(), entry.value);
                      },
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}

class NewAverageCumulativeLineChart extends StatelessWidget {
  const NewAverageCumulativeLineChart({super.key, this.titleData});

  final FlTitlesData? titleData;

  @override
  Widget build(BuildContext context) {
    final cumulativeComparison = context.select(
      (ChartViewModel state) => state.avgCumulativeComparison,
    );
    final metric = context.select((ChartViewModel state) => state.chartMetric);
    final curRangeStart = context.select((ChartViewModel state) => state.rangeStart);
    final prevRangeStart = context.select((ChartViewModel state) => state.prevRangeStart);
    final showMonths = context.select((ChartViewModel state) => state.showMonths);
    final now = DateTime.now().standard;
    return Container(
      height: 180,
      padding: EdgeInsets.only(top: 12),
      child: LineChart(
        LineChartData(
          minY: metric != ChartMetric.balance ? 0 : null,
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 0,
                dashArray: [2, 10],
                color: context.customCs.fadeColor2,
                strokeWidth: 1,
              ),
            ],
          ),
          titlesData: titleData ?? FlTitlesData(),
          borderData: FlBorderData(show: false),
          lineTouchData: getCustomLineTouchData(
            context: context,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map(
                (spot) {
                  final isPrev = spot.barIndex == 0;

                  final String curDate =
                      showMonths
                          ? curRangeStart.addMonth(spot.x.round()).formatMonth()
                          : curRangeStart.addDay(spot.x.round()).formatShorter();
                  final String prevDate =
                      showMonths
                          ? prevRangeStart.addMonth(spot.x.round()).formatMonth()
                          : prevRangeStart.addDay(spot.x.round()).formatShorter();
                  return LineTooltipItem(
                    "${isPrev ? prevDate : curDate}: ${context.chartMod.currencyFormat(spot.y)}",
                    context.tt.bodyMedium!.copyWith(fontSize: 10),
                    textAlign: TextAlign.right,
                  );
                },
              ).toList();
            },
          ),
          gridData: customGrid,
          lineBarsData:
              cumulativeComparison.mapIndexed((i, element) {
                final bool isPrev = i == 0;
                final Color mainColor = isPrev ? Colors.blue.shade300 : context.cs.secondary;
                return getCustomLineChartBarData(
                  spots: [
                    ...element.entries.map(
                      (entry) {
                        int index;
                        if (showMonths) {
                          index = entry.key.month - element.keys.first.month;
                        } else {
                          index = entry.key.difference(element.keys.first).inDays;
                        }
                        return FlSpot(index.toDouble(), entry.value);
                      },
                    ),
                  ],
                  color: mainColor,
                  dashArray: isPrev ? [2, 10] : null,
                  dotData: FlDotData(
                    checkToShowDot: (spot, barData) {
                      if (showMonths) {
                        return !isPrev &&
                            curRangeStart.addMonth(spot.x.round()).isInSameYearMonthAs(now);
                      } else {
                        return !isPrev &&
                            curRangeStart.addDay(spot.x.round()).isAtSameMomentAs(now);
                      }
                    },
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}

class YearMonthOverview extends StatelessWidget {
  const YearMonthOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final overview = context.select((ChartViewModel state) => state.sixMonthOverview);
    final start = context.select((ChartViewModel state) => state.rangeStart);
    return Container(
      height: 180,
      child: BarChart(
        BarChartData(
          gridData: customGrid,
          titlesData: getCustomChartTitleData(
            context: context,
            bottomTitle: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(overview.keys.elementAt(value.round()).formatMonth());
                },
              ),
            ),
          ),
          barGroups:
              overview.entries.mapIndexed((i, el) {
                return BarChartGroupData(
                  x: i,
                  barRods:
                      [
                        ChartMetric.expense,
                        ChartMetric.income,
                      ].mapIndexed((metricIndex, e) {
                        final expense = metricIndex == 0;
                        final income = metricIndex == 1;
                        return BarChartRodData(
                          width: 10,
                          toY: e.getCostMetric(el.value) ?? 0,
                          color: (expense
                                  ? context.chartMod.accentColors.negative
                                  : context.chartMod.accentColors.positive)
                              .withAlpha(el.key.isInSameYearMonthAs(start) ? 250 : 100),
                        );
                      }).toList(),
                );
              }).toList(),
        ),
      ),
    );
  }
}

class ChartHeaderDelegate extends SliverPersistentHeaderDelegate {
  ChartHeaderDelegate({required this.displayPeriod, required this.displayDetailsPeriod});

  final String displayPeriod, displayDetailsPeriod;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0, 1);
    return Container(
      color: context.cs.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity == null) return;
            if (details.primaryVelocity! > 500) {
              // swipe right
              context.chartMod.updatePeriodDuration(increase: false);
            } else if (details.primaryVelocity! < -500) {
              // swipe left
              context.chartMod.updatePeriodDuration(increase: true);
            }
          },
          child: ReusableContainer(
            height: 120,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            width: double.infinity,
            filled: true,
            highlight: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Current View",
                  style: context.customTt.numberFontSmall?.copyWith(
                    color: context.cs.onSecondary.withAlpha(200),
                    fontSize: lerpDouble(14, 14, progress),
                    height: lerpDouble(1.4, 1.4, progress),
                    fontWeight: FontWeight(600),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.chartMod.updatePeriodDuration(increase: false),
                      icon: FaIcon(
                        FontAwesomeIcons.angleLeft,
                        color: context.cs.surface,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        displayPeriod,
                        textAlign: TextAlign.center,
                        style: context.customTt.numberFontLarge?.copyWith(
                          color: context.cs.surface,
                          fontSize: lerpDouble(52, 36, progress),
                          height: 1.2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.chartMod.updatePeriodDuration(increase: true),
                      icon: FaIcon(
                        FontAwesomeIcons.angleRight,
                        color: context.cs.surface,
                      ),
                    ),
                  ],
                ),
                Text(
                  displayDetailsPeriod,
                  style: context.customTt.paragraphText?.copyWith(
                    color: context.cs.surface.withAlpha(
                      lerpDouble(200, 0, progress)!.round(),
                    ),
                    fontSize: lerpDouble(16, 12, progress),
                    height: lerpDouble(1.3, 0.01, progress),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 140;

  @override
  double get minExtent => 100;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

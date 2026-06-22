// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/screens/settings/chart_details_screen.dart';
import 'package:budget_tracker/ui/chart/chart_category_breakdown_screen.dart';
import 'package:budget_tracker/ui/chart/chart_viewmodel.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/ui/list/list_screen.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  static List<String> weekdayInitials = [
    "M",
    "T",
    "W",
    "T",
    "F",
    "S",
    "S",
  ];

  static List<String> monthInitials = [
    "J",
    "F",
    "M",
    "A",
    "M",
    "J",
    "J",
    "A",
    "S",
    "O",
    "N",
    "D",
  ];

  @override
  Widget build(BuildContext context) {
    final ready = context.select((ChartModel state) => state.ready);
    final rangeType = context.select((ChartModel state) => state.rangeType);
    final type = context.select((ChartModel state) => state.type);
    final period = context.select((ChartModel state) => state.period);

    final FlTitlesData chartTitleData = FlTitlesData(
      rightTitles: AxisTitles(drawBelowEverything: false),
      topTitles: AxisTitles(drawBelowEverything: false),
      leftTitles: AxisTitles(
        // axisNameWidget: Padding(
        //   padding: const EdgeInsets.only(left: 40.0),
        //   child: Text(
        //     "Amount (${context.select((AppModel state) => state.currencySymbol)})",
        //     style: Theme.of(context).textTheme.labelSmall,
        //   ),
        // ),
        // axisNameSize: 40,
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
          // interval: 50
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          interval: 1,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final day = value.toInt();
            String text = "";
            switch (period) {
              case ChartPeriod.week:
                text = weekdayInitials.elementAtOrNull(day) ?? "";
              case ChartPeriod.year:
                text = monthInitials.elementAtOrNull(day) ?? "";
              default:
                text = "•";
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                text,
                style: context.tt.bodyMedium!.copyWith(fontSize: 10),
              ),
            );
          },
          showTitles: true,
          maxIncluded: true,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Visualize".toUpperCase(),
        ),
        actions: [
          SizedBox(
            height: 40,
            child: DropdownMenu(
              inputDecorationTheme: InputDecorationThemeData(),
              onSelected: (value) {
                if (value == null) return;
                context.chartMod.updateCostType(value);
              },
              initialSelection: type,
              dropdownMenuEntries:
                  CostType.values
                      .map((type) => DropdownMenuEntry(value: type, label: type.name))
                      .toList(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        minimum: EdgeInsets.fromLTRB(12, 12, 12, 0),
        child:
            ready
                ? CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: const ChartFilterButtons(),
                    ),
                    const ChartSection(
                      title: "Category Breakdown",
                      page: ChartCategoryBreakdownScreen(),
                      child: CategoryBreakdownChart(),
                    ),
                    ChartSection(
                      title: "Day by Day Comparison",
                      showLabelSubtitle: true,
                      page: ChartCategoryBreakdownScreen(),
                      child: DayToDayBarChart(
                        titleData: chartTitleData,
                      ),
                    ),
                    ChartSection(
                      title: "Cumulative Spend",
                      showLabelSubtitle: true,
                      page: ChartCategoryBreakdownScreen(),
                      child: NewCumulativeLineChart(
                        titleData: chartTitleData,
                      ),
                    ),
                    ChartSection(
                      title: "Cumulative Average Spend",
                      showLabelSubtitle: true,
                      page: ChartCategoryBreakdownScreen(),
                      child: NewAverageCumulativeLineChart(
                        titleData: chartTitleData,
                      ),
                    ),
                    // const ChartSection(
                    //   title: "Category Comparison",
                    //   child: CategoryBreakdownList(),
                    // ),
                    // const ChartSection(
                    //   title: "Date Trend",
                    //   child: DayBarChart(),
                    // ),
                    // SliverPadding(
                    //   padding: const EdgeInsets.only(top: 12.0),
                    //   sliver: SliverToBoxAdapter(
                    //     child: Column(
                    //       spacing: 12,
                    //       crossAxisAlignment: CrossAxisAlignment.stretch,
                    //       children: [
                    //         Text("Daily Trend", style: context.customTt.dateLabel),
                    //         SizedBox(
                    //           height: 250,
                    //           child: DayBarChart(titleData: chartTitleData),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // SliverPadding(
                    //   padding: const EdgeInsets.only(top: 12.0),
                    //   sliver: SliverToBoxAdapter(
                    //     child: SizedBox(
                    //       height: 300,
                    //       child: Expanded(
                    //         child: NewAvgCumulativeLineChart(titleData: chartTitleData),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // SliverPadding(
                    //   padding: const EdgeInsets.only(top: 12.0),
                    //   sliver: SliverToBoxAdapter(
                    //     child: CustomChartSection(
                    //       title: "Daily Cumulative Spend",
                    //       sectionHeight: 300,
                    //       pageChildren: [
                    //         // DailyTotalBarChart(),
                    //         // DailyTotalBarChart(titleData: chartTitleData),
                    //         DailyCumulativeSpendLineChart(titleData: chartTitleData),
                    //         // DateTrendLineChart(titleData: chartTitleData()),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // Column(
                    //   spacing: 20,
                    //   children: [
                    // const DateBreadcrumb(),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    //   child: SegmentedButton(
                    //     segments: CostType.values.map((costType) {
                    //       return ButtonSegment(
                    //         value: costType,
                    //         icon: Icon(Icons.money),
                    //         label: Text(costType.name)
                    //       );
                    //     }).toList(),
                    //     selected: {_selectedCostType},
                    //     onSelectionChanged: (newSelection) {
                    //       setState(() {
                    //         _selectedCostType = newSelection.first;
                    //       });
                    //     },
                    //   ),
                    // ),
                    // Expanded(
                    //   child: SingleChildScrollView(
                    //     child: Column(
                    //       spacing: 20,
                    //       mainAxisSize: MainAxisSize.min,
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Padding(
                    //           padding: const EdgeInsets.all(16.0),
                    //           // child: const BudgetWidget(),
                    //           child: const CustomChartSection(
                    //             title: "Budget breakdown",
                    //             sectionHeight: 270,
                    //             pageChildren: [BudgetWidget()],
                    //           ),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    //           child: CustomChartSection(
                    //             title: "Expense breakdown",
                    //             sectionHeight: 240,
                    //             pageChildren: [
                    //               BreakdownPieChart(
                    //                 selectedCostType: _selectedCostType,
                    //               ),
                    //               DateBreakdownChart(
                    //                 selectedCostType: _selectedCostType,
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    //           child: CustomChartSection(
                    //             title: "Spending Trend",
                    //             sectionHeight: 300,
                    //             pageChildren: [
                    //               DailyTotalBarChart(titleData: chartTitleData()),
                    //               // DailyCumulativeSpendLineChart(titleData: chartTitleData()),
                    //               // DateTrendLineChart(titleData: chartTitleData()),
                    //             ],
                    //           ),
                    //         ),
                    //         // Divider(),
                    //         // CategoryList(
                    //         //   selectedCostType: _selectedCostType,
                    //         // ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    //   ],
                    // ),
                  ],
                )
                : Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
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
    final type = context.select((ChartModel state) => state.type);
    final period = context.select((ChartModel state) => state.period);
    final displayPeriod = context.select((ChartModel state) => state.displayPeriodDuration);
    final displayDetailsPeriod = context.select(
      (ChartModel state) => state.displayDetailsPeriodDuration,
    );
    debugPrint('rebuild');
    return Column(
      spacing: 12,
      children: [
        SizedBox(
          width: double.infinity,
          child: SegmentedButton(
            style: SegmentedButton.styleFrom(
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
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity == null) return;
            if (details.primaryVelocity!.abs() < 1000) return;
            debugPrint(details.primaryVelocity!.toStringAsFixed(0));
            context.chartMod.updatePeriodDuration(increase: details.primaryVelocity! < 0);
          },
          child: ReusableContainer(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            width: double.infinity,
            filled: true,
            highlight: true,
            child: Row(
              children: [
                Icon(
                  Icons.arrow_left_outlined,
                  color: context.cs.surface,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Your charts for",
                        style: context.customTt.paragraphText?.copyWith(color: context.cs.surface),
                      ),
                      Text(
                        displayPeriod,
                        style: context.customTt.elegantLabelLarge?.copyWith(
                          color: context.cs.surface,
                          fontSize: 40,
                        ),
                      ),
                      Text(
                        displayDetailsPeriod,
                        style: context.customTt.paragraphText?.copyWith(color: context.cs.surface),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_right_outlined, color: context.cs.surface),
              ],
            ),
          ),
        ),
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
    this.page,
  });

  final String title;
  final Widget child;
  final bool showLabelSubtitle;
  final Widget? page;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 12.0),
      sliver: SliverToBoxAdapter(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap:
              () =>
                  context.nav.push(MaterialPageRoute(builder: (context) => page ?? Placeholder())),
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
                      IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_outlined)),
                      // Text(
                      //   "Expand →",
                      //   style: context.customTt.numberFontSmall?.copyWith(
                      //     color: context.customCs.fadeColor1,
                      //     fontSize: 14,
                      //   ),
                      // ),
                    ],
                  ),
                  if (showLabelSubtitle)
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: context.cs.secondary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Current Range",
                          style: context.customTt.paragraphText?.copyWith(fontSize: 12),
                        ),
                        SizedBox(width: 20),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.blue.shade400,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Previous Range",
                          style: context.customTt.paragraphText?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                ],
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryBreakdownChart extends StatelessWidget {
  const CategoryBreakdownChart({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.select((ChartModel state) => state.simplifiedCurRangeCategorySummary);
    final total = context.select((ChartModel state) => state.curRangeSummary);
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
                            text: e.key.name?.capitalize() ?? "",
                            color: e.key.color ?? Colors.amber,
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: Text(
                            NumberFormat.compactCurrency(symbol: "RM").format(e.value.expense!),
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

class CategoryBreakdownList extends StatelessWidget {
  const CategoryBreakdownList({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = context.select((ChartModel state) => state.categoryComparison);
    return ListView.builder(
      itemCount: summary.length,
      itemBuilder: (context, index) {
        final category = summary.entries.elementAt(index).key;
        final metrics = summary.entries.elementAt(index).value;
        final prevRangeValue = metrics.first.expense ?? 0;
        final curRangeValue = metrics.last.expense ?? 0;
        final percentageChange = (curRangeValue / prevRangeValue).abs();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            spacing: 20,
            children: [
              CategoryIconContainer(
                category: category,
                size: 24,
              ),
              Expanded(
                child: Column(
                  spacing: 4,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text((category.name ?? "").capitalize())),
                        Text(
                          "${curRangeValue.customCurrencyFormat("RM")} (${NumberFormat.percentPattern().format(percentageChange)})",
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        color: context.customCs.fadeColor2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: min(percentageChange, 1),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: percentageChange > 1 ? Colors.red : context.customCs.fadeColor1,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // CategoryIconContainer(category: category),
            ],
          ),
        );
      },
    );
  }
}

class DayToDayBarChart extends StatelessWidget {
  const DayToDayBarChart({
    super.key,
    this.titleData,
  });

  final FlTitlesData? titleData;

  @override
  Widget build(BuildContext context) {
    final data = context.select((ChartModel state) => state.dayToDayComparison);
    final showMonths = context.select((ChartModel state) => state.showMonths);
    final curRangeStart = context.chartMod.rangeStart;
    final prevRangeStart = context.chartMod.prevRangeStart;
    return Container(
      height: 180,
      padding: EdgeInsets.only(left: 12, right: 12, top: 12),
      child: BarChart(
        duration: Durations.medium1,
        BarChartData(
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
                  "$curDate: ${group.barRods.first.toY.customCurrencyFormat("RM")}\n"
                  "$prevDate: ${group.barRods.last.toY.customCurrencyFormat("RM")}",
                  context.tt.bodyMedium!.copyWith(fontSize: 10),
                  textAlign: TextAlign.end,
                );
              },
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(drawVerticalLine: false),
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
                            toY: entry.value.expense ?? 0,
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

class OverviewBudgetBar extends StatelessWidget {
  const OverviewBudgetBar({super.key});

  @override
  Widget build(BuildContext context) {
    final expense = context.select((AppModel state) => state.totalCurrentMonthExpense);
    final budget = context.select((AppModel state) => state.totalBudget);
    final percentage = context.select((AppModel state) => state.budgetPercentage);
    final currencySymbol = context.select((AppModel state) => state.currencySymbol);
    final remainingAverageSpend = context.select(
      (AppModel state) => state.remainingDayAverageSpend,
    );
    // final percentage = expense/budget;

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   tooltipKey.currentState!.ensureTooltipVisible();
    // });
    return LayoutBuilder(
      builder: (context, constraints) {
        const double thresholdPosition = 0.75;
        return Column(
          children: [
            Text("You have spent:"),
            Text(
              NumberFormat("#0%").format(percentage),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 32.0, bottom: 4),
                  child: PercentageBar(
                    height: 12,
                    color: Colors.red,
                    percentage: percentage * thresholdPosition,
                  ),
                ),
                Positioned(
                  left:
                      constraints.maxWidth * thresholdPosition -
                      (17 * 2) -
                      (100 * (percentage > (4 / 3) ? percentage / (4 / 3) : 0)),
                  // widthFactor: 0.7,
                  child: Column(
                    spacing: 8,
                    children: [
                      Text(
                        "Threshold",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 20,
                        child: VerticalDivider(
                          thickness: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              ' spend below ${remainingAverageSpend.customCurrencyFormat(currencySymbol)} daily to reach your target',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextButton(onPressed: () {}, child: Text('or change your budget ? (but should you?)')),
          ],
        );
      },
    );
  }
}

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

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class BreakdownPieChart extends StatelessWidget {
  const BreakdownPieChart({super.key, required this.selectedCostType});

  final CostType selectedCostType;

  @override
  Widget build(BuildContext context) {
    final selectedThemeMode = context.select((ThemeModel state) => state.theme);
    final summarizedCategoryData = context.select((AppModel state) {
      final categoryData = state.getcurrentMonthCategoryView(true, CostType.expense);
      final Map<String, CostMetric> summarizedData = {};
      int i = 0;
      double totalOtherExpense = 0;
      if (categoryData.length < 5) {
        return categoryData;
      } else {
        for (i; i < categoryData.length; i++) {
          if (i < 4) {
            summarizedData[categoryData.entries.toList()[i].key] =
                categoryData.entries.toList()[i].value;
          } else {
            totalOtherExpense += categoryData.entries.toList()[i].value.expense!;
          }
        }
        summarizedData['other'] = CostMetric(expense: totalOtherExpense);
        return summarizedData;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChartTitleBar(
          description: "by Category",
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              spacing: 20,
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    duration: Durations.medium1,
                    curve: Curves.fastOutSlowIn,
                    PieChartData(
                      startDegreeOffset: -90,
                      centerSpaceRadius: 48,
                      pieTouchData: PieTouchData(
                        enabled: true,
                        touchCallback: (touchEvent, response) {
                          if (touchEvent is FlTapDownEvent) {
                            if (response?.touchedSection?.touchedSection != null) {
                              debugPrint("Touched!");
                              final categoryTitle = response!.touchedSection!.touchedSection!.title;
                              // updateCategory(categoryTitle);
                            }
                          }
                        },
                      ),
                      sections:
                          summarizedCategoryData.entries.map((data) {
                            final currentCategory = context.read<AppModel>().getCategoryEntry(
                              data.key,
                            );
                            Color primaryColor;
                            Color secColor;
                            if (currentCategory != null) {
                              primaryColor = currentCategory.colorScheme(selectedThemeMode).primary;
                              secColor =
                                  currentCategory.colorScheme(selectedThemeMode).primaryContainer;
                              // categoryColorScheme = currentCategory.colorScheme;
                            } else {
                              primaryColor = Colors.amber;
                              secColor = Colors.amber.shade700;
                            }
                            return PieChartSectionData(
                              value: data.value.expense!.abs(),
                              radius: 20,
                              // title: category,
                              // badgeWidget: currentCategory.generateRoundedIcon(30, categoryColorScheme.primary, categoryColorScheme.onPrimary),
                              // badgePositionPercentageOffset: 1,
                              showTitle: false,
                              gradient: LinearGradient(
                                stops: [0, 1],
                                colors: [
                                  primaryColor.withAlpha(200),
                                  secColor,
                                ],
                              ),
                              // color: categoryColorScheme.primary.withAlpha(200)
                            );
                          }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        summarizedCategoryData.entries.map((data) {
                          final category = context.read<AppModel>().getCategoryEntry(data.key);
                          final totalAmount = context.read<AppModel>().totalCurrentMonthExpense;
                          // final category = data['category'] as CostItemCategory?;
                          Color primaryColor;
                          if (category != null) {
                            primaryColor = category.colorScheme(selectedThemeMode).primary;
                          } else {
                            primaryColor = Colors.amber;
                          }
                          return SizedBox(
                            height: 28,
                            child: ChartLegendItem(
                              primaryColor: primaryColor,
                              title: data.key,
                              trailing: Text(
                                // NumberFormat('#0%').format(data['percentage']),
                                context.read<AppModel>().getCategoryPercentage(data.value.expense!),
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  fontSize: 13,
                                  // color: Theme.of(context).colorScheme.primary
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

class DateBreakdownChart extends StatelessWidget {
  const DateBreakdownChart({super.key, required this.selectedCostType});

  final CostType selectedCostType;

  @override
  Widget build(BuildContext context) {
    final dateData = context.select(
      (AppModel state) => state.summarizedDateGroupDataForCustomCostType(selectedCostType),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChartTitleBar(
          description: "by Date",
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              spacing: 20,
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    duration: Durations.medium1,
                    curve: Curves.fastOutSlowIn,
                    PieChartData(
                      startDegreeOffset: -90,
                      centerSpaceRadius: 48,
                      pieTouchData: PieTouchData(
                        enabled: true,
                        touchCallback: (touchEvent, response) {
                          if (touchEvent is FlTapDownEvent) {
                            if (response?.touchedSection?.touchedSection != null) {
                              debugPrint("Touched!");
                              // final categoryTitle = response!.touchedSection!.touchedSection!.title;
                              // updateCategory(categoryTitle);
                            }
                          }
                        },
                      ),
                      sections:
                          dateData.map((data) {
                            return PieChartSectionData(
                              value: data['amount'],
                              radius: 20,
                              showTitle: false,
                            );
                          }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        dateData.map((data) {
                          return SizedBox(
                            height: 28,
                            child: ListTile(
                              leading: Container(
                                height: 12,
                                width: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.amber,
                                ),
                              ),
                              title: Text(
                                data['date'] as String,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.copyWith(fontSize: 13),
                              ),
                              visualDensity: VisualDensity(vertical: -4),
                              dense: true,
                              contentPadding: EdgeInsets.only(right: 16),
                              trailing: Text(
                                NumberFormat('#0%').format(data['percentage']),
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  fontSize: 13,
                                  // color: Theme.of(context).colorScheme.primary
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

// class DateTrendLineChart extends StatelessWidget {
//   const DateTrendLineChart({
//     super.key,
//     required this.titleData,
//   });

//   final FlTitlesData titleData;

//   @override
//   Widget build(BuildContext context) {
//     final currentMonthData = context.select((AppModel state) => state.currentCumulativeAverage);
//     final previousMonthData = context.select((AppModel state) => state.previousCumulativeAverage);

//     final colorTheme = Theme.of(context).colorScheme;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       spacing: 4,
//       children: [
//         const ChartTitleBar(
//           description: "Cumulative average spend",
//         ),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//             child: SpendTrendLineChart(
//               currentMonthData: currentMonthData,
//               previousMonthData: previousMonthData,
//               titleData: titleData,
//             ),
//           ),
//         ),
//         // Align(
//         //   alignment: Alignment.center,
//         //   child: Row(
//         //     spacing: 12,
//         //     mainAxisSize: MainAxisSize.min,
//         //     children: [
//         //       ChartLegendItem(
//         //         primaryColor: colorTheme.primary,
//         //         title: "This month",
//         //         tileWidth: 200,
//         //       ),
//         //       ChartLegendItem(
//         //         primaryColor: colorTheme.tertiary,
//         //         title: "Previous month",
//         //         tileWidth: 200,
//         //       ),
//         //     ],
//         //   ),
//         // )
//       ],
//     );
//   }
// }

// class DailyCumulativeSpendLineChart extends StatelessWidget {
//   const DailyCumulativeSpendLineChart({
//     super.key,
//     required this.titleData,
//   });

//   final FlTitlesData titleData;

//   @override
//   Widget build(BuildContext context) {
//     final currentMonthData = context.select((AppModel state) => state.currentCumulative);
//     final previousMonthData = context.select((AppModel state) => state.previousCumulative);

//     final colorTheme = Theme.of(context).colorScheme;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       spacing: 4,
//       children: [
//         const ChartTitleBar(
//           description: "Cumulative spend",
//         ),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//             child: SpendTrendLineChart(
//               currentMonthData: currentMonthData,
//               previousMonthData: previousMonthData,
//               titleData: titleData,
//             ),
//           ),
//         ),
//         // Align(
//         //   alignment: Alignment.center,
//         //   child: Container(
//         //     // decoration: ,
//         //     child: Row(
//         //       spacing: 12,
//         //       mainAxisSize: MainAxisSize.min,
//         //       mainAxisAlignment: MainAxisAlignment.center,
//         //       children: [
//         //         ChartLegendItem(
//         //           primaryColor: colorTheme.primary,
//         //           title: "This month",
//         //           tileWidth: 160,
//         //           fontSize: 10,
//         //         ),
//         //         ChartLegendItem(
//         //           primaryColor: colorTheme.tertiary,
//         //           title: "Previous month",
//         //           tileWidth: 160,
//         //           fontSize: 10,
//         //         ),
//         //       ],
//         //     ),
//         //   ),
//         // )
//       ],
//     );
//   }
// }

// class SpendTrendLineChart extends StatelessWidget {
//   const SpendTrendLineChart({
//     super.key,
//     required this.currentMonthData,
//     required this.previousMonthData,
//     required this.titleData,
//   });

//   final Map<int, double> currentMonthData;
//   final Map<int, double> previousMonthData;
//   // final List<double> previousMonthData;
//   final FlTitlesData titleData;

//   @override
//   Widget build(BuildContext context) {
//     final yearMonth = context.select((AppModel state) => state.selectedYearMonth);
//     return LineChart(
//       LineChartData(
//         borderData: FlBorderData(show: false),
//         lineTouchData: LineTouchData(
//           touchTooltipData: LineTouchTooltipData(
//             // fitInsideHorizontally: true,
//             fitInsideVertically: true,
//             getTooltipColor: (touchedSpot) => Colors.transparent,
//             getTooltipItems: (touchedSpots) {
//               return touchedSpots.map((spot) {
//                 final modelRead = context.read<AppModel>();
//                 final index = spot.spotIndex + 1;
//                 final lineIndex = spot.barIndex;
//                 String tooltipText = "";
//                 if (lineIndex == 0) {
//                   tooltipText =
//                       "Current: ${modelRead.customCurrencyFormat(currentMonthData[index]!, true)}";
//                 } else {
//                   tooltipText =
//                       "Previous: ${modelRead.customCurrencyFormat(previousMonthData[index]!, true)}";
//                 }
//                 return LineTooltipItem(
//                   tooltipText,
//                   Theme.of(
//                     context,
//                   ).textTheme.bodySmall!.copyWith(fontSize: 10, color: spot.bar.color),
//                 );
//               }).toList();
//             },
//           ),
//         ),
//         maxY: [...currentMonthData.values, ...previousMonthData.values].maxCeiling(),
//         minY: 0,
//         minX: 1,
//         gridData: FlGridData(show: true),
//         titlesData: titleData,
//         lineBarsData: [
//           spendTrendLineData(context, true, yearMonth), // current month data
//           spendTrendLineData(context, false, yearMonth), // previous month data
//         ],
//       ),
//     );
//   }

//   LineChartBarData spendTrendLineData(BuildContext context, bool currentMonth, DateTime yearMonth) {
//     final displayData = currentMonth ? currentMonthData : previousMonthData;
//     final colorTheme = Theme.of(context).colorScheme;
//     return LineChartBarData(
//       // current month data
//       isCurved: true,
//       barWidth: currentMonth ? 3 : 1,
//       color: currentMonth ? colorTheme.primary : colorTheme.tertiary,
//       preventCurveOvershootingThreshold: 0,
//       dashArray: currentMonth ? null : [10, 5],
//       curveSmoothness: 0.5,
//       isStrokeCapRound: true,
//       preventCurveOverShooting: true,
//       dotData: FlDotData(
//         show: currentMonth ? true : false,
//         checkToShowDot: (spot, barData) {
//           // if the month is completed, do not show dot
//           if (!yearMonth.isInSameYearMonthAs(DateTime.now())) return false;
//           // only show dot for the latest date
//           if (spot.x == displayData.length) return true;

//           return false;
//         },
//       ),
//       spots:
//           displayData
//               .map((int dayInt, double amount) {
//                 return MapEntry(dayInt, FlSpot(dayInt.toDouble(), amount));
//               })
//               .values
//               .toList(),
//     );
//   }
// }

// class CategoryList extends StatefulWidget {
//   const CategoryList({super.key, required this.selectedCostType});

//   final CostType selectedCostType;

//   @override
//   State<CategoryList> createState() => _CategoryListState();
// }

// class _CategoryListState extends State<CategoryList> {
//   bool _isSortDescending = true;

//   List<Widget> categoryListTile(Map<String, CostMetric> data, BuildContext context) =>
//       data.entries.map((categoryData) {
//         final selectedThemeMode = context.select((ThemeModel state) => state.theme);
//         final categoryName = categoryData.key;
//         final CostItemCategory categoryEntry =
//             context.read<AppModel>().getCategoryEntry(categoryName) ?? CostItemCategory();
//         final double categoryAmount = categoryData.value.expense!;
//         final ColorScheme categoryColorScheme = categoryEntry.colorScheme(selectedThemeMode);
//         // final amountString = categoryAmount.toStringAsFixed(categoryAmount % 1 == 0? 0 : 2);
//         final amountString = context.read<AppModel>().customCurrencyFormat(categoryAmount, false);
//         final currencySymbol = context.select((AppModel state) => state.currencySymbol);
//         final maxAmount = context.select(
//           (AppModel state) => state.getMaxCurrentMonthCategoryAmount(CostType.expense),
//         );
//         final percentageString = context.read<AppModel>().getCategoryPercentage(categoryAmount);
//         final List<CostItem> costItems = context.select(
//           (AppModel state) => state.currentMonthCategoryList[categoryName] ?? [],
//         );

//         return Theme(
//           data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//           child: ExpansionTile(
//             key: ValueKey(categoryName),
//             tilePadding: EdgeInsets.fromLTRB(4, 4, 4, 4),
//             childrenPadding: EdgeInsets.fromLTRB(4, 0, 4, 8),
//             title: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(categoryName),
//                 Text.rich(
//                   TextSpan(
//                     children: [
//                       TextSpan(
//                         text: '$amountString ',
//                         style: Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 12),
//                       ),
//                       TextSpan(
//                         text: '($percentageString)',
//                         style: Theme.of(context).textTheme.labelMedium!.copyWith(
//                           fontSize: 12,
//                           color: categoryColorScheme.primary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             // leading: categoryEntry.generateRoundedIcon(56, selectedThemeMode),
//             subtitle: PercentageBar(
//               height: 8,
//               color: categoryColorScheme.primaryFixed,
//               percentage: categoryAmount / maxAmount,
//             ),
//             children:
//                 costItems.map((CostItem costItem) {
//                   return ListTile(
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                     visualDensity: VisualDensity(vertical: -3),
//                     dense: true,
//                     leading: Container(
//                       width: MediaQuery.of(context).size.width * 0.12,
//                       child: Text(
//                         (costItem.date).displayFormat(),
//                         style: Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 12),
//                       ),
//                     ),
//                     title: Flex(
//                       direction: Axis.horizontal,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       // mainAxisAlignment: MainAxisAlignment.end,
//                       spacing: 20,
//                       children: [
//                         Flexible(
//                           flex: 4,
//                           child: Text(
//                             costItem.name,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         Flexible(
//                           flex: 10,
//                           fit: FlexFit.tight,
//                           child: Divider(
//                             color: Colors.white.withAlpha(80),
//                           ),
//                         ),
//                       ],
//                     ),
//                     trailing: Container(
//                       width: MediaQuery.of(context).size.width * 0.12,
//                       child: Text(
//                         costItem.getCurrencyValue(currencySymbol, false),
//                         textAlign: TextAlign.right,
//                         style: Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 12),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//           ),
//         );
//       }).toList();

//   @override
//   Widget build(BuildContext context) {
//     final Map<String, CostMetric> categoryData = context.select(
//       (AppModel state) => state.getcurrentMonthCategoryView(_isSortDescending, CostType.expense),
//     );

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             mainAxisSize: MainAxisSize.max,
//             children: [
//               Expanded(
//                 child: ChartTitleBar(
//                   title: "Expense overview",
//                   description: "by Category",
//                 ),
//               ),
//               IconButton(
//                 onPressed: () => setState(() => _isSortDescending = !_isSortDescending),
//                 icon: Transform.scale(scaleY: _isSortDescending ? 1 : -1, child: Icon(Icons.sort)),
//               ),
//             ],
//           ),
//         ),
//         ...categoryListTile(categoryData, context),
//       ],
//     );
//   }
// }

// class FastCustomScrollPhysics extends ScrollPhysics {
//   const FastCustomScrollPhysics({super.parent});

//   @override
//   FastCustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
//     return FastCustomScrollPhysics(parent: buildParent(ancestor)!);
//   }

//   @override
//   SpringDescription get spring => const SpringDescription(
//     mass: 5,
//     stiffness: 100,
//     damping: 50,
//   );
// }

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

// class BudgetBarChart extends StatelessWidget {
//   const BudgetBarChart({
//     super.key,
//     this.current = 0,
//     this.budget = 0,
//   });

//   final double current;
//   final double budget;

//   @override
//   Widget build(BuildContext context) {
//     return BarChart(
//       BarChartData(
//         borderData: FlBorderData(show: false),
//         maxY: max(current, budget) + 1,
//         gridData: FlGridData(
//           horizontalInterval: budget,
//           getDrawingHorizontalLine: (value) {
//             if (value == budget.roundToDouble()) return FlLine(color: Colors.white, strokeWidth: 1);
//             return FlLine(strokeWidth: 0);
//           },
//           // show: false
//         ),
//         titlesData: FlTitlesData(
//           bottomTitles: AxisTitles(drawBelowEverything: false),
//           topTitles: AxisTitles(drawBelowEverything: false),
//           leftTitles: AxisTitles(drawBelowEverything: false),
//           rightTitles: AxisTitles(
//             sideTitles: SideTitles(
//               interval: budget,
//               reservedSize: 30,
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 if (value == budget.roundToDouble()) {
//                   return SideTitleWidget(
//                     meta: meta,
//                     fitInside: SideTitleFitInsideData(
//                       enabled: budget > current,
//                       axisPosition: 0,
//                       parentAxisSize: budget > current ? 50 : 0,
//                       distanceFromEdge: 0,
//                     ),
//                     child: Text('Limit'),
//                   );
//                 }
//                 return SizedBox.shrink();
//               },
//             ),
//           ),
//         ),
//         barGroups: [
//           BarChartGroupData(
//             x: 1,
//             barsSpace: 0,
//             barRods: [
//               BarChartRodData(
//                 toY: current,
//                 color: current > budget ? Colors.red : context.read<ThemeModel>().color,
//                 width: 12,
//                 backDrawRodData: BackgroundBarChartRodData(
//                   show: true,
//                   color: Colors.grey.withAlpha(100),
//                   fromY: 0,
//                   toY: budget,
//                 ),
//               ),
//               // BarChartRodData(toY: 40),
//             ],
//           ),
//         ],
//         rotationQuarterTurns: 1,
//       ),
//     );
//   }
// }

class NewCumulativeLineChart extends StatelessWidget {
  const NewCumulativeLineChart({super.key, this.titleData});

  final FlTitlesData? titleData;

  @override
  Widget build(BuildContext context) {
    final cumulativeComparison = context.select((ChartModel state) => state.cumulativeComparison);
    final curRangeStart = context.select((ChartModel state) => state.rangeStart);
    final prevRangeStart = context.select((ChartModel state) => state.prevRangeStart);
    final showMonths = context.select((ChartModel state) => state.showMonths);

    final now = DateTime.now().standard;
    return Container(
      height: 180,
      padding: EdgeInsets.only(left: 12, right: 12, top: 12),
      child: LineChart(
        LineChartData(
          titlesData: titleData ?? FlTitlesData(),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
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
                      "${isPrev ? prevDate : curDate}: ${spot.y.customCurrencyFormat("RM")}",
                      context.tt.bodyMedium!.copyWith(fontSize: 10),
                      textAlign: TextAlign.right,
                    );
                  },
                ).toList();
              },
              tooltipHorizontalOffset: 20,
              fitInsideVertically: true,
              fitInsideHorizontally: true,
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine:
                (value) => FlLine(strokeWidth: 1, color: context.customCs.fadeColor3),
          ),
          lineBarsData:
              cumulativeComparison.mapIndexed((i, element) {
                final bool isPrev = i == 0;
                final Color mainColor = isPrev ? Colors.blue.shade300 : context.cs.secondary;
                return LineChartBarData(
                  dashArray: isPrev ? [2, 8] : null,
                  barWidth: 1.5,
                  isStrokeCapRound: true,
                  isStrokeJoinRound: true,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [(mainColor.withAlpha(50)), Colors.transparent],
                    ),
                  ),
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
                    // FlSpot(0, 0),
                    ...element.entries.mapIndexed(
                      (dateIndex, entry) => FlSpot(dateIndex.toDouble(), entry.value),
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
      (ChartModel state) => state.avgCumulativeComparison,
    );
    final curRangeStart = context.select((ChartModel state) => state.rangeStart);
    final prevRangeStart = context.select((ChartModel state) => state.prevRangeStart);
    final showMonths = context.select((ChartModel state) => state.showMonths);
    final now = DateTime.now().standard;
    return Container(
      height: 180,
      padding: EdgeInsets.only(left: 12, right: 12, top: 12),
      child: LineChart(
        LineChartData(
          titlesData: titleData ?? FlTitlesData(),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
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
                      "${isPrev ? prevDate : curDate}: ${spot.y.customCurrencyFormat("RM")}",
                      context.tt.bodyMedium!.copyWith(fontSize: 10),
                      textAlign: TextAlign.right,
                    );
                  },
                ).toList();
              },
              tooltipHorizontalOffset: 20,
              fitInsideVertically: true,
              fitInsideHorizontally: true,
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine:
                (value) => FlLine(strokeWidth: 1, color: context.customCs.fadeColor3),
          ),
          lineBarsData:
              cumulativeComparison.mapIndexed((i, element) {
                final bool isPrev = i == 0;
                final Color mainColor = isPrev ? Colors.blue.shade300 : context.cs.secondary;
                return LineChartBarData(
                  curveSmoothness: 0.5,
                  isCurved: true,
                  // preventCurveOverShooting: true,
                  dashArray: isPrev ? [2, 8] : null,
                  barWidth: 1.5,
                  isStrokeCapRound: true,
                  isStrokeJoinRound: true,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [(mainColor.withAlpha(50)), Colors.transparent],
                    ),
                  ),
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
                    // FlSpot(0, 0),
                    ...element.entries.mapIndexed(
                      (dateIndex, entry) => FlSpot(dateIndex.toDouble(), entry.value),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}

class LabelIndicator extends StatelessWidget {
  const LabelIndicator({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color,
          ),
        ),
        SizedBox(width: 6),
        Text(
          text,
          style: context.tt.bodyMedium!.copyWith(fontSize: 12, color: context.cs.primary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

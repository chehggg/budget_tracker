// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/reusable/reusable_chart_component.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/chart/chart_category_breakdown_screen.dart';
import 'package:budget_tracker/ui/chart/chart_viewmodel.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/ui/list/main_list_screen.dart';

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
    final type = context.select((ChartModel state) => state.type);
    final period = context.select((ChartModel state) => state.period);

    final FlTitlesData chartTitleData = getCustomChartTitleData(
      context: context,
      bottomTitle: AxisTitles(
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
                  ],
                )
                : Center(
                  child: CircularProgressIndicator(),
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
            if (details.primaryVelocity!.abs() < 100) return;
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
                    ],
                  ),
                  if (showLabelSubtitle)
                    Row(
                      spacing: 12,
                      children: [
                        LabelIndicator(
                          text: "Current Range",
                          color: context.cs.secondary,
                          fade: true,
                        ),
                        LabelIndicator(
                          text: "Previous Range",
                          color: Colors.blue.shade400,
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
                    "${isPrev ? prevDate : curDate}: ${spot.y.customCurrencyFormat("RM")}",
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
                  dashArray: isPrev ? [2, 8] : null,
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
                    "${isPrev ? prevDate : curDate}: ${spot.y.customCurrencyFormat("RM")}",
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
                    ...element.entries.mapIndexed(
                      (dateIndex, entry) => FlSpot(dateIndex.toDouble(), entry.value),
                    ),
                  ],
                  color: mainColor,
                  dashArray: isPrev ? [2, 8] : null,
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

class LabelIndicator extends StatelessWidget {
  const LabelIndicator({super.key, required this.text, this.color, this.fade = false});

  final String text;
  final Color? color;
  final bool fade;

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
          style: context.tt.bodyMedium!.copyWith(
            fontSize: 12,
            color: fade ? context.customCs.fadeColor1 : context.cs.primary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

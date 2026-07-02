import 'dart:math';

import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/reusable_chart_component.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/form/form_screen.dart';
import 'package:budget_tracker/ui/goal/goal_form_screen.dart';
import 'package:budget_tracker/ui/goal/goal_form_viewmodel.dart';
import 'package:budget_tracker/ui/goal/goal_info_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GoalDetailsScreen extends StatelessWidget {
  const GoalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goal = context.select((GoalInfoViewmodel state) => state.goal);
    final ready = context.select((GoalInfoViewmodel state) => state.ready);
    return Scaffold(
      appBar: AppBar(
        title: Text("Goal Details"),
        actions: [
          IconButton(
            onPressed: () async {
              final response = await showDialog(
                context: context,
                builder: (context) => DeleteItemDialog(),
              );
              if (response == null) return;
              if (response && context.mounted) {
                await context.goalInfoMod.deleteGoal();
                context.pop();
                // context.showSuccessNotification(message: "Goal is deleted");
              }
            },
            icon: Icon(Icons.delete),
          ),
          IconButton(
            onPressed: () {
              context.nav.push(
                MaterialPageRoute(
                  builder: (context) {
                    return ChangeNotifierProvider(
                      create:
                          (context) => GoalFormViewmodel(
                            categoryRepo: context.read(),
                            goalRepository: context.read(),
                            initGoal: goal,
                          ),
                      child: const GoalFormInfoScreen(),
                    );
                  },
                ),
              );
            },
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      body: SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child:
            ready
                ? const GoalInfoBody()
                : const Center(
                  child: CircularProgressIndicator(),
                ),
      ),
    );
  }
}

class GoalInfoBody extends StatelessWidget {
  const GoalInfoBody({super.key});

  @override
  Widget build(BuildContext context) {
    final goalProgress = context.select((GoalInfoViewmodel state) => state.pastProgress);
    final curProgress = context.select((GoalInfoViewmodel state) => state.currentGoalProgress);
    final progress = curProgress.progress;
    final dividerPercentage = progress * 0.008;
    debugPrint('goal progress: ${goalProgress.length}');
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: const GoalInfoTitleContainer(),
        ),
        SliverToBoxAdapter(
          child: Stack(
            alignment: AlignmentDirectional(0, 0.8),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 160,
                  ),
                  SizedBox(
                    height: 0,
                    width: 150,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 130,
                        startDegreeOffset: -180,
                        sections: [
                          PieChartSectionData(
                            value: min(1, progress),
                            radius: 8,
                            showTitle: false,
                            color:
                                curProgress.achieved
                                    ? Colors.green.shade800
                                    : Colors.red.shade900.withAlpha(150),
                          ),
                          PieChartSectionData(
                            value: dividerPercentage,
                            radius: 20,
                            showTitle: false,
                            color: context.customCs.fadeColor1,
                          ),
                          PieChartSectionData(
                            value: (1 - progress).abs(),
                            radius: 8,
                            showTitle: false,
                            color:
                                curProgress.achieved
                                    ? context.customCs.fadeColor2
                                    : Colors.red.shade800,
                          ),
                          PieChartSectionData(
                            value: max(1, progress) + dividerPercentage,
                            radius: 8,
                            showTitle: false,
                            color: Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    curProgress.date!.formatMonthLonger(),
                    style: context.customTt.paragraphText,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    curProgress.progress.formatDecimalPercentage(),
                    style: context.customTt.dateLabel!.copyWith(fontSize: 48, height: 1),
                  ),
                  Text(
                    "${curProgress.value.formatRoundedString()} / ${curProgress.target!.formatRoundedString()}",
                    style: context.customTt.numberFontSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: const GoalDetailsExpansionTile(),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Text("Visualize", style: context.customTt.dateLabel),
              // SizedBox(
              //   height: 100,
              //   child: BarChart(
              //     BarChartData(
              //       extraLinesData: ExtraLinesData(
              //         horizontalLines: [
              //           HorizontalLine(
              //             y: spendPerday,
              //             strokeWidth: 1.2,
              //             color: Colors.blue.shade400,
              //             dashArray: [2, 5],
              //             strokeCap: StrokeCap.round,
              //           ),
              //         ],
              //       ),
              //       titlesData: FlTitlesData(show: false),
              //       barGroups: [
              //         ...List.generate(
              //           dayinCurMonth,
              //           (i) => DateTime.now().startOfMonth.addDay(i),
              //         ).map(
              //           (date) {
              //             final CostMetric metric =Z
              //                 context.goalInfoMod.barChartData[date] ?? CostMetric();
              //             return BarChartGroupData(
              //               x: date.day,
              //               barRods: [
              //                 BarChartRodData(toY: metric.expense!, color: context.cs.secondary),
              //               ],
              //             );
              //           },
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 8.0, bottom: 20),
              //   child: Text(
              //     "${context.goalInfoMod.targetReachingDays}/${DateTime.now().day} days which your daily target reached!",
              //   ),
              // ),
              // SizedBox(
              //   height: 10,
              // ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          sliver: SliverToBoxAdapter(
            child: Divider(),
          ),
        ),
        // SliverPadding(
        //   padding: const EdgeInsets.symmetric(vertical: 12.0),
        //   sliver: SliverToBoxAdapter(
        //     child: const AverageSpendBarChart(),
        //   ),
        // ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          sliver: SliverToBoxAdapter(
            child: const GoalInfoLineChart(),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          sliver: SliverToBoxAdapter(
            child: const GoalInfoHeatmapChart(),
          ),
        ),
        if (context.goalInfoMod.showHistory)
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            sliver: SliverToBoxAdapter(
              child: Divider(),
            ),
          ),
        if (context.goalInfoMod.showHistory)
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text("History", style: context.customTt.dateLabel),
              ),
              ...goalProgress.map(
                (progress) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ReusableContainer(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
                    child: Row(
                      spacing: 12,
                      children: [
                        Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: progress.achieved ? Colors.green : Colors.red,
                          ),
                        ),
                        Expanded(child: Text(progress.date?.formatMonthLonger() ?? "No date")),
                        Text(progress.progress.formatCompactPercentage()),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
      ],
    );
  }
}

class GoalInfoTitleContainer extends StatelessWidget {
  const GoalInfoTitleContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final goal = context.select((GoalInfoViewmodel state) => state.goal);
    final curProgress = context.select((GoalInfoViewmodel state) => state.currentGoalProgress);
    return Container(
      // padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
      // padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.cs.primary.withAlpha(150),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  goal.goalType!.name.capitalize(),
                  style: context.customTt.numberFontSmall?.copyWith(
                    // fontSize: 40,
                    fontSize: 12,
                    color: context.cs.surface,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      curProgress.achieved
                          ? Colors.green.shade800.withAlpha(120)
                          : Colors.red.shade800.withAlpha(120),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  curProgress.status,
                  style: context.customTt.numberFontSmall?.copyWith(
                    // fontSize: 40,
                    fontSize: 12,
                    color: context.cs.primary,
                  ),
                ),
              ),
              if (curProgress.achieved)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withAlpha(120),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "5 month streak",
                    style: context.customTt.numberFontSmall?.copyWith(
                      // fontSize: 40,
                      fontSize: 12,
                      color: context.cs.primary,
                    ),
                  ),
                ),
            ],
          ),
          Text(
            goal.title ?? "",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.customTt.numberFontLarge!.copyWith(
              fontSize: 36,
              height: 1.2,
              // color: context.cs.surface,
            ),
          ),
          Text(
            goal.description ?? "",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.tt.bodyMedium
          ),
        ],
      ),
    );
  }
}

class GoalDetailsExpansionTile extends StatelessWidget {
  const GoalDetailsExpansionTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(dividerColor: Colors.transparent, splashFactory: NoSplash.splashFactory),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text("Details", style: context.customTt.numberFontSmall!.copyWith(fontSize: 16)),
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.only(bottom: 20),
        expandedAlignment: AlignmentGeometry.centerLeft,

        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...context.goalInfoMod.goalInfo.entries.map(
                (entry) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Text(entry.key, style: context.customTt.paragraphTextSmall),
                    ),
                    Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: Text(
                        entry.value,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: context.customTt.paragraphTextSmall,
                      ),
                    ),
                  ],
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       "Title",
              //       style: context.customTt.paragraphTextSmall,
              //     ),
              //     Text(
              //       goal.title ?? "",
              //       style: context.customTt.paragraphTextSmall,
              //     ),
              //   ],
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       "Description",
              //       style: context.customTt.paragraphTextSmall,
              //     ),
              //     Text(
              //       goal.description ?? "",
              //       style: context.customTt.paragraphTextSmall,
              //     ),
              //   ],
              // ),
              // Row(
              //   spacing: 10,
              //   children: [
              //     Expanded(
              //       child: Column(
              //         children: [
              //           Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Text(
              //                 "Created",
              //                 style: context.customTt.paragraphTextSmall,
              //               ),
              //               Text(
              //                 goal.lastCreated!.formatFull(),
              //                 style: context.customTt.paragraphTextSmall,
              //               ),
              //             ],
              //           ),
              //           Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Text(
              //                 "Last Modified",
              //                 style: context.customTt.paragraphTextSmall,
              //               ),
              //               Text(
              //                 goal.lastModified!.formatFull(),
              //                 style: context.customTt.paragraphTextSmall,
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),
              //     ),
              //     Expanded(
              //       child: Column(
              //         children: [
              //           Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Text(
              //                 "Created",
              //                 style: context.customTt.paragraphTextSmall,
              //               ),
              //               Text(
              //                 goal.lastCreated!.formatFull(),
              //                 style: context.customTt.paragraphTextSmall,
              //               ),
              //             ],
              //           ),
              //           Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Text(
              //                 "Last Modified",
              //                 style: context.customTt.paragraphTextSmall,
              //               ),
              //               Text(
              //                 goal.lastModified!.formatFull(),
              //                 style: context.customTt.paragraphTextSmall,
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

class GoalInfoHeatmapChart extends StatelessWidget {
  const GoalInfoHeatmapChart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dailSpendPercent = context.goalInfoMod.targetReachingPercentage;
    final dailyData = context.goalInfoMod.dailyData.entries;
    final days = context.goalInfoMod.displayDayTitle;
    final daysWithData = dailyData.where((entry) => entry.value != null).length;
    final targetReachingDays = context.goalInfoMod.targetReachingDays;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      // spacing: 4,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Spend Heatmap - $days",
                style: context.customTt.dateLabel,
              ),
            ),
            IconButton(
              iconSize: 16,

              visualDensity: VisualDensity(vertical: -4, horizontal: -4),
              padding: EdgeInsets.zero,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => HeatmapDialog(context: context),
                );
              },
              icon: Icon(
                Icons.help_outline,
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8),
            child: FractionallySizedBox(
              widthFactor: 0.6,
              child: Row(
                spacing: 6,
                children: [
                  Text("0", style: context.customTt.paragraphTextSmall),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.green.shade800, context.cs.secondary],
                        ),
                      ),
                    ),
                  ),
                  Text("Limit", style: context.customTt.paragraphTextSmall),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.red.shade800,
                    ),
                  ),
                  Text("Exceed", style: context.customTt.paragraphTextSmall),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: HeatmapGraph(
            target: context.goalInfoMod.targetSpendPerDay,
            totalCount: context.goalInfoMod.dataCount,
            getTooltipMessage: (index) {
              final dayData = dailyData.elementAtOrNull(index);
              if (dayData == null) {
                return "No data";
              } else {
                final percentage =
                    (dayData.value?.expense ?? 0) / context.goalInfoMod.targetSpendPerDay;
                // ignore: prefer_adjacent_string_concatenation
                return "${dayData.key.formatShorter()}\n${dayData.value == null ? "No Data" : (dayData.value!.expense ?? 0).customCurrencyFormat("RM")}" +
                    // ignore: unnecessary_string_interpolations
                    "${dayData.value != null ? " (${NumberFormat.percentPattern().format(percentage)})" : ""}";
              }
            },
            data: context.goalInfoMod.indexedDailyData,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12, right: 12.0),
          child: Text.rich(
            TextSpan(
              text: "You have spent below the daily spend limit for ",
              style: context.customTt.paragraphTextSmall!.copyWith(fontSize: 14),
              children: [
                // ignore: prefer_interpolation_to_compose_strings
                TextSpan(
                  text: targetReachingDays.toString() + "/" + daysWithData.toString(),
                  style: context.customTt.numberFontSmall!.copyWith(
                    fontSize: 14,
                    color: context.cs.secondary,
                  ),
                ),
                TextSpan(text: " days ("),
                TextSpan(
                  text: dailSpendPercent.formatCompactPercentage(),
                  style: context.customTt.numberFontSmall!.copyWith(
                    fontSize: 14,
                    color: context.cs.secondary,
                  ),
                ),
                TextSpan(text: ") this month."),
              ],
            ),
            // "You have spent below the daily spend limit for ${context.goalInfoMod.targetReachingDays}/${dailyData.where((entry) => entry.value != null).length} days (${dailSpendPercent.formatCompactPercentage()}) this month.",
            // style: context.customTt.paragraphText!.copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class GoalInfoLineChart extends StatelessWidget {
  const GoalInfoLineChart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final goal = context.goalInfoMod.goal;
    final target = goal.target;
    final goalProgress = context.goalInfoMod.currentGoalProgress;
    final achieved = goalProgress.achieved;
    final days = context.goalInfoMod.displayDayTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Cumulative - $days",
                    style: context.customTt.dateLabel,
                  ),
                ),
                IconButton(
                  iconSize: 16,
                  visualDensity: VisualDensity(vertical: -4, horizontal: -4),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => SpendBelowDialog(context: context),
                    );
                  },
                  icon: Icon(
                    Icons.help_outline,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 8),
                child: FractionallySizedBox(
                  widthFactor: 0.6,
                  child: Row(
                    spacing: 6,
                    children: [
                      Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.blue.shade800,
                        ),
                      ),
                      Text("Limit", style: context.customTt.paragraphTextSmall),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: context.cs.secondary,
                        ),
                      ),
                      Text("Spend", style: context.customTt.paragraphTextSmall),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.only(top: 12, left: 4, right: 4, bottom: 12),
          height: 160,
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(show: false),
              lineTouchData: getCustomLineTouchData(
                context: context,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map(
                    (spot) {
                      final startDate = context.goalInfoMod.chartStartDate.addDay(
                        spot.x.round() - 1,
                      );
                      final label = spot.barIndex == 0 ? "Limit" : startDate.formatShorter();
                      final color =
                          spot.barIndex == 0 ? Colors.blue.shade300 : context.cs.secondary;
                      return LineTooltipItem(
                        "$label: ${spot.y.customCurrencyFormat("RM", round: true)}",
                        context.tt.bodyMedium!.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight(500),
                          color: color,
                        ),
                        textAlign: TextAlign.end,
                      );
                    },
                  ).toList();
                },
              ),
              borderData: FlBorderData(show: false),
              gridData: customGrid,
              lineBarsData: [
                getCustomLineChartBarData(
                  isCurved: false,
                  showGradient: true,
                  color: Colors.blue.shade400,
                  dashArray: [2, 8],
                  spots: [
                    ...List.generate(
                      context.goalInfoMod.dataCount,
                      (i) => i + 1,
                    ).map((i) => FlSpot(i.toDouble(), target!)),
                    // FlSpot(1, target!),
                    // FlSpot(dayinCurMonth.toDouble(), target),
                  ],
                ),
                getCustomLineChartBarData(
                  dotData: FlDotData(
                    checkToShowDot: (spot, barData) {
                      final date = context.goalInfoMod.chartStartDate.addDay(spot.x.round() - 1);
                      return DateTime.now().standard == date;
                    },
                  ),
                  isCurved: false,
                  color: context.cs.secondary,
                  spots: [
                    ...context.goalInfoMod.lineChartData.entries
                        .where((entry) => entry.value != null)
                        .mapIndexed(
                          (index, el) {
                            return FlSpot((index + 1).toDouble(), el.value?.expense ?? 0);
                          },
                        ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 12),
          child:
              achieved
                  ? Text.rich(
                    TextSpan(
                      text: "Spend below ",
                      style: context.customTt.paragraphTextSmall!.copyWith(fontSize: 14),
                      children: [
                        TextSpan(
                          text: context.goalInfoMod.remainingValueOverDay.customCurrencyFormat(
                            "RM",
                          ),
                          style: context.customTt.numberFontSmall!.copyWith(
                            fontSize: 14,
                            color: context.cs.secondary,
                          ),
                        ),
                        TextSpan(text: " per day to achieve this goal."),
                      ],
                    ),
                  )
                  : Text.rich(
                    TextSpan(text: "Your current month expense has exceeds the limit."),
                    style: context.customTt.paragraphTextSmall!.copyWith(fontSize: 14),
                  ),
        ),
      ],
    );
  }
}

class SpendBelowDialog extends StatelessWidget {
  const SpendBelowDialog({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext dialogContext) {
    final double target = context.goalInfoMod.goal.target!;
    final highlightFontStyle = context.customTt.numberFontSmall!.copyWith(
      color: context.cs.secondary,
      fontSize: 12,
    );
    return AlertDialog(
      title: Text("Spend below metrics"),
      content: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              text:
                  "This metric shows the max spend you should allocate per day for the rest of the month to prevent overspend.\n\n",
              style: context.customTt.paragraphText!.copyWith(
                fontSize: 12,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: "Your current budget is ",
                ),
                TextSpan(text: target.customCurrencyFormat("RM"), style: highlightFontStyle),
                TextSpan(
                  text: ".\n\nYour spend till today (",
                ),
                TextSpan(text: DateTime.now().formatShort(), style: highlightFontStyle),
                TextSpan(
                  text: ") is ",
                ),
                TextSpan(
                  text: context.goalInfoMod.currentGoalProgress.value.customCurrencyFormat("RM"),
                  style: highlightFontStyle,
                ),
                TextSpan(
                  text: ".\n\nTo prevent budget overrun, you would need to spend below ",
                ),
                TextSpan(
                  text: context.goalInfoMod.remainingValue.customCurrencyFormat("RM"),
                  style: highlightFontStyle,
                ),
                TextSpan(
                  text: " over ",
                ),
                TextSpan(
                  text: context.goalInfoMod.remainingDays.toString(),
                  style: highlightFontStyle,
                ),
                TextSpan(
                  text: " days, which, if distrubuted evenly, is equivalent to ",
                ),
                TextSpan(
                  text: context.goalInfoMod.remainingValueOverDay.customCurrencyFormat("RM"),
                  style: highlightFontStyle,
                ),
                TextSpan(
                  text: " per day.",
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        AffirmativeTextButton(
          text: "I Understand",
          onTap: Navigator.of(dialogContext).pop,
        ),
      ],
    );
  }
}

class HeatmapGraph extends StatefulWidget {
  const HeatmapGraph({
    super.key,
    this.target,
    required this.totalCount,
    required this.data,
    this.getTooltipMessage,
  });

  final double? target;
  final int totalCount;
  final Map<int, double> data;
  final String Function(int)? getTooltipMessage;

  @override
  State<HeatmapGraph> createState() => _HeatmapGraphState();
}

class _HeatmapGraphState extends State<HeatmapGraph> {
  int _expandedIndex = -1;

  void tapHeatmap(int index) async {
    Tooltip.dismissAllToolTips();
    setState(() {
      _expandedIndex = index;
    });
    await Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted && _expandedIndex == index) {
        setState(() {
          _expandedIndex = -1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 36,
      ),
      itemCount: widget.totalCount,
      itemBuilder: (context, index) {
        final expanded = index == _expandedIndex;
        final value = widget.data.values.elementAtOrNull(index);
        final message = widget.getTooltipMessage == null ? "" : widget.getTooltipMessage!(index);
        Color color;
        if (value != null) {
          if (widget.target != null) {
            if (value > widget.target!) {
              color = Colors.red.shade800;
            } else {
              color =
                  Color.lerp(
                    Colors.green.shade800,
                    context.cs.secondary,
                    (value) / widget.target!,
                  )!;
            }
          } else {
            color = Colors.green;
          }
        } else {
          color = context.customCs.fadeColor2!;
        }
        return Tooltip(
          enableTapToDismiss: false,
          textStyle: context.tt.bodyMedium!.copyWith(
            fontSize: 12,
            color: Color.lerp(color, Colors.white, 0.8),
            fontWeight: FontWeight(500),
          ),
          decoration: BoxDecoration(
            color: context.cs.surface,
            borderRadius: BorderRadius.circular(4),
          ),
          onTriggered: () => tapHeatmap(index),
          message: message,
          textAlign: TextAlign.center,
          triggerMode: TooltipTriggerMode.tap,
          preferBelow: false,
          // waitDuration: Durations.medium1,
          // showDuration: ,
          child: Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              height: expanded ? 24 : 18,
              width: expanded ? 24 : 18,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AverageSpendBarChart extends StatelessWidget {
  const AverageSpendBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final targetAverageSpendPerDay = context.goalInfoMod.targetSpendPerDay;
    final currentAverageSpend = context.goalInfoMod.currentSpendPerDay;
    final difference = context.goalInfoMod.spendPerDayTargetDifference;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        Flexible(
          flex: 3,
          fit: FlexFit.tight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Current Spend Per Day",
                      // style: context.customTt.numberFontLarge!.copyWith(fontSize: 36, height: 1.1),
                    ),
                  ),
                  IconButton(
                    iconSize: 16,
                    visualDensity: VisualDensity(vertical: -4, horizontal: -4),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => SpendPerDayDialog(context: context),
                      );
                    },
                    icon: Icon(
                      Icons.help_outline,
                    ),
                  ),
                ],
              ),
              Text(
                (difference > 0 ? "> " : "< ") +
                    NumberFormat.percentPattern().format(difference.abs()),
                style: context.customTt.numberFontLarge!.copyWith(fontSize: 36, height: 1.1),
              ),
              Text(
                // ignore: prefer_interpolation_to_compose_strings
                "compared to the spend per day limit. " +
                    (difference > 0
                        ? "Reduce expense to prevent overrun."
                        : "Keep up current spend."),
                style: context.customTt.paragraphText!.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: Container(
            padding: EdgeInsets.only(top: 16),
            height: 90,
            child: BarChart(
              BarChartData(
                rotationQuarterTurns: 1,
                titlesData: FlTitlesData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barsSpace: 24,
                    barRods: [
                      ...[
                        targetAverageSpendPerDay,
                        currentAverageSpend,
                      ].mapIndexed(
                        (index, val) => BarChartRodData(
                          toY: val,
                          color: index == 0 ? Colors.blue.shade400 : context.cs.secondary,
                          width: 12,
                          borderRadius: BorderRadius.circular(3),
                          label: BarChartRodLabel(
                            text: "What",
                            offset: Offset(-16, -20),
                            style: context.customTt.paragraphText!.copyWith(fontSize: 10),
                          ),
                        ),
                      ),
                      // BarChartRodData(toY: targetAverageSpendPerDay),
                      // BarChartRodData(toY: currentAverageSpend)
                    ],
                  ),
                ],
                borderData: FlBorderData(show: false),
                gridData: customGrid,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HeatmapDialog extends StatelessWidget {
  const HeatmapDialog({super.key, required this.context});

  final BuildContext context;
  @override
  Widget build(BuildContext dialogContext) {
    final highlightFontStyle = context.customTt.numberFontSmall!.copyWith(
      color: context.cs.secondary,
      fontSize: 12,
    );
    return AlertDialog(
      title: Text("Spend Heatmap"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              text:
                  "This graph shows how many day in current month you have spent within/over the spend per day limit specified by the budget. ",
              style: context.customTt.paragraphText!.copyWith(fontSize: 12, height: 1.5),
              children: [
                TextSpan(
                  text: 'Red indicates the spend exceeds limit on that day.\n\n',
                  style: highlightFontStyle,
                ),
                TextSpan(
                  text:
                      "If your budget is distributed evenly across the month, your spend per day limit is ",
                ),
                TextSpan(
                  text: context.goalInfoMod.targetSpendPerDay.customCurrencyFormat("RM"),
                  style: highlightFontStyle,
                ),
                TextSpan(text: ".\n\nUp till today, you have spend within the limit for "),
                TextSpan(
                  text: '${context.goalInfoMod.targetReachingDays}',
                  style: highlightFontStyle,
                ),
                TextSpan(text: " out of "),
                TextSpan(text: '${context.goalInfoMod.currentDay}', style: highlightFontStyle),
                TextSpan(text: " days, which is equivalent to "),
                TextSpan(
                  text: NumberFormat.percentPattern().format(
                    context.goalInfoMod.targetReachingPercentage,
                  ),
                  style: highlightFontStyle,
                ),
                TextSpan(text: " of all the days."),
              ],
            ),
          ),
          Text('\nLegend', style: context.customTt.numberFontSmall!.copyWith(fontSize: 14)),
          Row(
            spacing: 6,
            children: [
              Text("Low", style: context.customTt.paragraphText!.copyWith(fontSize: 14)),
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.green, context.cs.secondary],
                    ),
                  ),
                ),
              ),
              Text("High", style: context.customTt.paragraphText!.copyWith(fontSize: 14)),
              SizedBox(
                width: 10,
              ),
              Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.red,
                ),
              ),
              Text("Exceed", style: context.customTt.paragraphText!.copyWith(fontSize: 14)),
            ],
          ),
        ],
      ),
      actions: [
        AffirmativeTextButton(
          text: 'I Understand',
          onTap: Navigator.of(dialogContext).pop,
        ),
      ],
    );
  }
}

class SpendPerDayDialog extends StatelessWidget {
  const SpendPerDayDialog({super.key, required this.context});

  final BuildContext context;
  @override
  Widget build(BuildContext dialogContext) {
    final highlightFontStyle = context.customTt.numberFontSmall!.copyWith(
      color: context.cs.secondary,
      fontSize: 12,
    );
    return AlertDialog(
      title: Text("Current Spend Per Day"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text:
                  "This metric compares the current spend per day to the spend per day limit specified by the budget.",
              style: context.customTt.paragraphText!.copyWith(fontSize: 12, height: 1.5),
              children: [
                TextSpan(
                  text: " A positive percentage difference is undesirable ",
                  style: highlightFontStyle,
                ),
                TextSpan(
                  text:
                      "as it means that your spending are exceeding limit on average.\n\nIf your budget is distributed evenly across the month, your spend per day limit is ",
                ),
                TextSpan(
                  text: context.goalInfoMod.targetSpendPerDay.customCurrencyFormat("RM"),
                  style: highlightFontStyle,
                ),
                TextSpan(text: ".\n\nThis month, you have spent "),
                TextSpan(
                  text: context.goalInfoMod.currentGoalProgress.value.customCurrencyFormat("RM"),
                  style: highlightFontStyle,
                ),
                TextSpan(text: " across "),
                TextSpan(
                  text: '${context.goalInfoMod.currentDay}',
                  style: highlightFontStyle,
                ),
                TextSpan(text: " days, which is equivalent to "),
                TextSpan(
                  text: context.goalInfoMod.currentSpendPerDay.customCurrencyFormat("RM"),
                  style: highlightFontStyle,
                ),
                TextSpan(text: " per day.\n\n"),
                TextSpan(text: "Compare to spend per day limit, the percentage difference is "),
                TextSpan(
                  text: NumberFormat.percentPattern().format(
                    context.goalInfoMod.spendPerDayTargetDifference,
                  ),
                  style: highlightFontStyle,
                ),
                TextSpan(text: "."),
              ],
            ),
          ),
        ],
      ),
      actions: [
        AffirmativeTextButton(
          text: " I Understand",
          onTap: Navigator.of(dialogContext).pop,
        ),
      ],
    );
  }
}

import 'dart:math';

import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/classes/goal_class.dart';
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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GoalInfoScreen extends StatelessWidget {
  const GoalInfoScreen({super.key});

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
              if (response) {
                await context.goalInfoMod.deleteGoal();
                context.nav.pushNamedAndRemoveUntil('/goals', (route) => false);
                context.showSuccessNotification(message: "Goal is deleted");
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
                      child: GoalInfoFormScreen(),
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
    // final goal = context.select((GoalInfoViewmodel state) => state.goal);
    final curProgress = context.select((GoalInfoViewmodel state) => state.currentGoalProgress);
    // final dayinCurMonth = DateTime.now().dayinCurrentMonth;
    // final spendPerday = (goal.target ?? 0) / dayinCurMonth;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: const GoalInfoTitleContainer(),
        ),
        SliverToBoxAdapter(
          child: Stack(
            alignment: AlignmentDirectional(0, 0.9),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 170,
                  ),
                  SizedBox(
                    height: 10,
                    width: 150,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 130,
                        startDegreeOffset: -180,
                        sections: [
                          PieChartSectionData(
                            value: min(1, curProgress.progress),
                            radius: 8,
                            showTitle: false,
                            color: context.cs.secondary,
                          ),
                          PieChartSectionData(
                            value: max(0, 1 - curProgress.progress),
                            radius: 8,
                            showTitle: false,
                            color: context.customCs.fadeColor2,
                          ),
                          PieChartSectionData(
                            value: 1,
                            radius: 8,
                            showTitle: false,
                            color: Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "${curProgress.value.formatRoundedString()} / ${curProgress.target!.formatRoundedString()}",
                    style: context.customTt.numberFontSmall,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    curProgress.progress.formatDecimalPercentage(),
                    style: context.customTt.dateLabel!.copyWith(fontSize: 48, height: 1),
                  ),
                  Text(
                    "Towards the goals",
                    style: context.customTt.paragraphText,
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
              //             final CostMetric metric =
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
        // SliverList(
        //   delegate: SliverChildListDelegate([

        //     Padding(
        //       padding: const EdgeInsets.symmetric(vertical: 4.0),
        //       child: Text("History", style: context.customTt.dateLabel),
        //     ),
        //     ...goalProgress.map(
        //       (el) => Padding(
        //         padding: const EdgeInsets.symmetric(vertical: 4.0),
        //         child: ReusableContainer(
        //           child: Text(el.date?.formatMonth() ?? "No date"),
        //         ),
        //       ),
        //     ),
        //   ]),
        // ),
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
            style: context.customTt.paragraphText!.copyWith(
              // color: context.cs.surface.withAlpha(150),
            ),
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
                      child: Text(entry.key, style: context.customTt.paragraphText),
                    ),
                    Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: Text(
                        entry.value,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: context.customTt.paragraphText,
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
    final dayinCurMonth = context.goalInfoMod.dataCount;
    // final dayinCurMonth = context.goalInfoMod.dayinCurrentMonth;
    final spendPerday = (context.goalInfoMod.goal.target ?? 0) / dayinCurMonth;
    final percentage = context.goalInfoMod.targetReachingPercentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      // spacing: 4,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Spend Heatmap",
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
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: HeatmapGraph(
            target: spendPerday,
            totalCount: dayinCurMonth,
            getTooltipMessage: (index) {
              final val = context.goalInfoMod.dailyData.entries.elementAtOrNull(index);
              if (val == null) {
                return "No data";
              } else {
                final percentage = (val.value?.expense ?? 0) / spendPerday;
                // ignore: prefer_adjacent_string_concatenation
                return "${val.key.formatShorter()}: ${val.value == null ? "No Data" : (val.value!.expense ?? 0).customCurrencyFormat("RM")}" +
                    // ignore: unnecessary_string_interpolations
                    "${val.value != null ? " (${NumberFormat.percentPattern().format(percentage)})" : ""}";
              }
            },
            data: context.goalInfoMod.indexedDailyData,
          ),
        ),
        Align(
          alignment: Alignment(0.9, 0),
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: FractionallySizedBox(
              widthFactor: 0.6,
              child: Row(
                spacing: 6,
                children: [
                  Text("0", style: context.customTt.paragraphText!.copyWith(fontSize: 14)),
                  Expanded(
                    child: Container(
                      height: 12,
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
                  Text("Limit", style: context.customTt.paragraphText!.copyWith(fontSize: 14)),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.red,
                    ),
                  ),
                  Text("Exceed", style: context.customTt.paragraphText!.copyWith(fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
        Text(
          percentage.formatCompactPercentage(),
          style: context.customTt.numberFontLarge,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Text(
            "of all days in current month where you reach your daily spend.",
            style: context.customTt.paragraphText,
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
    final target = context.goalInfoMod.goal.target;
    final achieved = context.goalInfoMod.currentGoalProgress.achieved;

    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Remaining Daily Spend",
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
          ],
        ),
        Container(
          padding: EdgeInsets.only(top: 12, left: 4, right: 4, bottom: 12),
          height: 140,
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(show: false),
              lineTouchData: getCustomLineTouchData(
                context: context,
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
                  spots: [
                    ...context.goalInfoMod.lineChartData.entries.map(
                      (el) => FlSpot(el.key.day.toDouble(), el.value.expense!),
                    ),
                  ],
                  isCurved: false,
                  color: context.cs.secondary,
                ),
              ],
            ),
          ),
        ),
        Text(
          achieved
              ? "< ${context.goalInfoMod.remainingValueOverDay.customCurrencyFormat("RM")}"
              : "-",
          style: context.customTt.numberFontLarge!.copyWith(height: 1),
        ),
        Text(
          "daily spend until the end of the month to achieve this budget goal.",
          style: context.customTt.paragraphText,
        ),
        SizedBox(
          height: 8,
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
      if (_expandedIndex == index) {
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
              color = Colors.red;
            } else {
              color =
                  Color.lerp(
                    Colors.green.withAlpha(150),
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
          textStyle: context.customTt.numberFontSmall!.copyWith(
            fontSize: 12,
            color: context.cs.primary,
          ),
          decoration: BoxDecoration(
            color: context.cs.surface.withAlpha(220),
            borderRadius: BorderRadius.circular(4),
          ),
          onTriggered: () => tapHeatmap(index),
          message: message,
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

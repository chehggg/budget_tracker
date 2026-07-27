import 'dart:math';

import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/data/repos/shared_element_repository.dart';
import 'package:budget_tracker/reusable/reusable_chart_component.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/chart/chart_reusables.dart';
import 'package:budget_tracker/ui/form/form_screen.dart';
import 'package:budget_tracker/ui/goal/goal_info_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GoalPastDetailsScreen extends StatefulWidget {
  const GoalPastDetailsScreen({super.key, required this.date});

  final DateTime date;

  @override
  State<GoalPastDetailsScreen> createState() => _GoalPastDetailsScreenState();
}

class _GoalPastDetailsScreenState extends State<GoalPastDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GoalInfoViewModel>().updatePreviousDate(widget.date);
  }

  @override
  Widget build(BuildContext context) {
    // final goal = context.select((GoalInfoViewModel state) => state.goal);
    final ready = context.select((GoalInfoViewModel state) => state.ready);
    return CustomScaffold(
      appBarTitle: Text("Goal Past Details - ${widget.date.formatMonth()}"),
      padHorizontal: true,
      actions: [
        // IconButton(
        //   onPressed: () async {
        //     final response = await showDialog(
        //       context: context,
        //       builder: (context) => DeleteItemDialog(),
        //     );
        //     if (response == null) return;
        //     if (response && context.mounted) {
        //       await context.goalInfoMod.deleteGoal();
        //       if (context.mounted) {
        //         context.pop();
        //       }
        //     }
        //   },
        //   icon: Icon(Icons.delete),
        // ),
        // IconButton(
        //   onPressed: () {
        //     context.push('/goals/edit-goal', extra: goal);
        //   },
        //   icon: Icon(Icons.edit),
        // ),
      ],
      ready: ready,
      child: const GoalInfoBody(
        showPrevious: true,
      ),
    );
  }
}

class GoalDetailsScreen extends StatelessWidget {
  const GoalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goal = context.select((GoalInfoViewModel state) => state.goal);
    final ready = context.select((GoalInfoViewModel state) => state.ready);
    return CustomScaffold(
      appBarTitle: Text("Goal Details"),
      padHorizontal: true,
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
              if (context.mounted) {
                context.pop();
              }
            }
          },
          icon: Icon(Icons.delete),
        ),
        IconButton(
          onPressed: () {
            context.push('/goals/edit-goal', extra: goal);
          },
          icon: Icon(Icons.edit),
        ),
      ],
      ready: ready,
      child: const GoalInfoBody(),
    );
  }
}

class GoalInfoBody extends StatelessWidget {
  const GoalInfoBody({super.key, this.showPrevious = false});

  final bool showPrevious;

  @override
  Widget build(BuildContext context) {
    final pastProgress = context.select((GoalInfoViewModel state) => state.pastProgress.reversed);
    final curProgress = context.select(
      (GoalInfoViewModel state) =>
          showPrevious ? state.currentViewedPastGoalProgress : state.currentGoalProgress,
    );
    final progress = curProgress.progress;
    final streak = context.goalInfoMod.streak;
    final chartProgress = progress.clamp(0.0, 1.0);
    final extraProgress = (1 - progress).abs();
    final dividerPercentage = progress * 0.008;
    // debugPrint('goal progress: ${pastProgress.length}');
    
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
                    height: 170,
                  ),
                  SizedBox(
                    height: 0,
                    width: 150,
                    child: PieChart(
                      duration: Duration.zero,
                      PieChartData(
                        centerSpaceRadius: 130,
                        startDegreeOffset: -180,
                        sections: [
                          PieChartSectionData(
                            value: chartProgress,
                            radius: 10,
                            showTitle: false,
                            color:
                                curProgress.achieved
                                    ? context.goalInfoMod.accentColors.positive
                                    : context.goalInfoMod.accentColors.negative,
                          ),
                          PieChartSectionData(
                            value: dividerPercentage,
                            radius: 20,
                            showTitle: false,
                            color: context.customCs.fadeColor1,
                          ),
                          PieChartSectionData(
                            value: extraProgress,
                            radius: 10,
                            showTitle: false,
                            color:
                                curProgress.achieved
                                    ? context.customCs.fadeColor2
                                    : curProgress.goalType == GoalType.budget
                                    ? context.goalInfoMod.accentColors.negative.withAlpha(100)
                                    : context.customCs.fadeColor2,
                          ),
                          PieChartSectionData(
                            value: chartProgress + extraProgress + dividerPercentage,
                            radius: 10,
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
                spacing: 4,
                children: [
                  Text(
                    curProgress.date?.formatMonthLonger() ?? "",
                    style: context.customTt.paragraphTitle,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    curProgress.progress.formatDecimalPercentage(),
                    style: context.customTt.dateLabel!.copyWith(fontSize: 48, height: 1),
                  ),
                  SizedBox(
                    height: 1,
                  ),
                  Text(
                    "${curProgress.value.formatRoundedString()} / ${curProgress.target?.formatRoundedString()}",
                    style: context.tt.bodyMedium!.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: GoalDetailsExpansionTile(),
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
            child: GoalInfoLineChart(),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          sliver: SliverToBoxAdapter(
            child: GoalAvgTargetInfoChart(),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          sliver: SliverToBoxAdapter(
            child: GoalInfoHeatmapChart(),
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
              if (streak > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ReusableContainer(
                    padding: EdgeInsets.all(12),
                    filled: true,
                    highlight: true,
                    child: Row(
                      spacing: 12,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.fire,
                          color: Colors.red,
                        ),
                        Text(
                          "$streak streak${streak.getPlural()}, keep it up!",
                          style: context.customTt.numberLabel!.copyWith(color: context.cs.surface),
                        ),
                      ],
                    ),
                  ),
                ),
              ...pastProgress.map(
                (progress) => GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => context.push('/goals//details-past', extra: progress.date),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                      ),
                      child: Column(
                        spacing: 4,
                        children: [
                          Row(
                            spacing: 12,
                            children: [
                              Expanded(
                                child: Text(
                                  progress.date?.formatMonthLonger() ?? "No date",
                                  style: context.customTt.numberFontSmall,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            spacing: 10,
                            children: [
                              Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  color:
                                      progress.achieved
                                          ? context.goalInfoMod.accentColors.positive
                                          : context.goalInfoMod.accentColors.negative,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              Expanded(
                                child: Text(progress.status, style: context.customTt.paragraphText),
                              ),
                              Text(
                                // ignore: prefer_interpolation_to_compose_strings, prefer_adjacent_string_concatenation
                                context.goalInfoMod.compactCurrencyFormat(progress.value) +
                                    // ignore: prefer_interpolation_to_compose_strings
                                    " / " +
                                    context.goalInfoMod.compactCurrencyFormat(
                                      progress.target ?? 0,
                                    ),
                                style: context.customTt.paragraphText,
                              ),
                              Text(
                                "(${progress.progress.formatCompactPercentage()})",
                                style: context.customTt.numberFontSmall!.copyWith(
                                  fontSize: 14,
                                  color:
                                      progress.achieved
                                          ? context.goalInfoMod.accentColors.positive
                                          : context.goalInfoMod.accentColors.negative,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        SliverToBoxAdapter(child: SizedBox(height: 20)),
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
    final goal = context.select((GoalInfoViewModel state) => state.goal);
    // ignore: unused_local_variable
    final curProgress = context.select((GoalInfoViewModel state) => state.currentGoalProgress);
    final streak = context.select((GoalInfoViewModel state) => state.streak);
    return Container(
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // FaIcon(
              //   goal.goalType == GoalType.budget
              //       ? FontAwesomeIcons.coins
              //       : goal.goalType == GoalType.savings
              //       ? FontAwesomeIcons.piggyBank
              //       : FontAwesomeIcons.creditCard,
              //   size: 12,
              // ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: BoxBorder.all(color: Colors.white.withAlpha(50)),
                  color: context.cs.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  spacing: 8,
                  children: [
                    FaIcon(
                      goal.goalType == GoalType.budget
                          ? FontAwesomeIcons.coins
                          : goal.goalType == GoalType.savings
                          ? FontAwesomeIcons.piggyBank
                          : FontAwesomeIcons.creditCard,
                      size: 12,
                    ),
                    Text(
                      goal.goalType!.name.capitalize(),
                      style: context.customTt.paragraphText?.copyWith(
                        // fontSize: 40,
                        fontSize: 12,

                        color: context.cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              //   decoration: BoxDecoration(
              //     border: BoxBorder.all(color: Colors.white.withAlpha(50)),
              //     color:
              //         curProgress.currentStatus == "Pending"
              //             ? context.cs.secondary.withAlpha(60)
              //             : curProgress.achieved
              //             ? context.goalInfoMod.accentColors.positive.withAlpha(60)
              //             : context.goalInfoMod.accentColors.negative.withAlpha(60),
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: Text(
              //     curProgress.currentStatus,
              //     style: context.customTt.paragraphText?.copyWith(
              //       // fontSize: 40,
              //       fontSize: 12,
              //       color: context.cs.primary,
              //     ),
              //   ),
              // ),
              if (streak > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: BoxBorder.all(color: Colors.white.withAlpha(50)),
                    color: Colors.deepOrange.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.fire,
                        color: Colors.red,
                        size: 12,
                      ),
                      Text(
                        "$streak",
                        style: context.customTt.paragraphText?.copyWith(
                          fontSize: 12,
                          color: context.cs.primary,
                        ),
                      ),
                    ],
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
            style: context.tt.bodyMedium,
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
    final dailyTarget = context.goalInfoMod.targetSpendPerDay;
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
                          colors: [context.goalInfoMod.accentColors.positive, context.cs.secondary],
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
                      color: context.goalInfoMod.accentColors.negative,
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
            target: dailyTarget,
            totalCount: context.goalInfoMod.dataCount,
            getTooltipMessage: (index) {
              final dayData = dailyData.elementAtOrNull(index);
              if (dayData == null) {
                return "No data";
              } else {
                final percentage = (dayData.value ?? 0) / dailyTarget;
                final data =
                    dayData.value == null
                        ? "No Data"
                        : context.goalInfoMod.compactCurrencyFormat(dayData.value ?? 0);
                final label = dayData.key.formatEvenShorter();
                // ignore: prefer_adjacent_string_concatenation
                return "$label\n$data" +
                    // ignore: unnecessary_string_interpolations
                    "${dayData.value != null ? " (${percentage.formatCompactPercentage()})" : ""}";
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
                  text: "$targetReachingDays/$daysWithData",
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
    final goalProgress = context.goalInfoMod.currentGoalProgress;
    final showAvg = context.select((GoalInfoViewModel state) => state.showAvgLine);
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
                      LabelIndicator(
                        text: "Spend",
                        color: context.goalInfoMod.accentColors.current,
                        fade: true,
                      ),
                      LabelIndicator(
                        text: "Target Daily Average",
                        color: Colors.lightGreen,
                        fade: true,
                        showVisibleSymbol: true,
                        enabled: showAvg,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        GoalCumulativeChart(),
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
                          text: context.goalInfoMod.currencyFormat(
                            context.goalInfoMod.remainingValueOverDay,
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

class GoalCumulativeChart extends StatefulWidget {
  const GoalCumulativeChart({
    super.key,
  });

  @override
  State<GoalCumulativeChart> createState() => _GoalCumulativeChartState();
}

class _GoalCumulativeChartState extends State<GoalCumulativeChart> {
  int? _index;

  @override
  Widget build(BuildContext context) {
    final target = context.goalInfoMod.goal.target;
    final showAvgLine = context.goalInfoMod.showAvgLine;
    final progress = context.goalInfoMod.currentGoalProgress;
    final cumulativeSpots = context.goalInfoMod.lineChartCumulativeData.entries
        .where((entry) => entry.value != null)
        .mapIndexed(
          (index, el) {
            return FlSpot((index + 1).toDouble(), (el.value ?? 0).clamp(0, double.infinity));
          },
        );
    final dailyAvgSpots = List.generate(
      context.goalInfoMod.dataCount,
      (i) {
        final target = (i + 1) * context.goalInfoMod.targetSpendPerDay;
        return FlSpot((i + 1).toDouble(), target);
      },
    );
    final diffSpots = cumulativeSpots.mapIndexed((index, el) {
      final currentY = el.y;
      final targetY = dailyAvgSpots.elementAt(index).y;
      final diff = (currentY - targetY);
      return FlSpot(index.toDouble(), diff);
    });
    final indicatorIndex = _index ?? defaultIndex;

    return Container(
      padding: EdgeInsets.only(top: 12, left: 4, right: 4, bottom: 12),
      height: 200,
      child: LineChart(
        LineChartData(
          titlesData: getCustomChartTitleData(
            context: context,
            bottomTitle: AxisTitles(
              sideTitles: SideTitles(
                interval: 1,
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return ChartBottomTitleLabel(value: value);
                },
              ),
            ),
          ),
          extraLinesData: getHorizontalExtraLines(context, y: [target ?? 0], showYLabel: [true]),
          maxY: ((progress.value * 1.4) > (target ?? 0)) ? progress.value * 1.4 : null,
          minY: 0,
          lineTouchData: getCustomLineTouchData(
            enabled: false,
            context: context,
            touchCallback: (event, response) {
              if (!event.isInterestedForInteractions ||
                  response == null ||
                  response.lineBarSpots == null) {
                setState(() {
                  _isTouched = false; // Reset touch state
                  _index = defaultIndex;
                });
                return;
              }

              setState(() {
                _isTouched = true;
                _index = response.lineBarSpots?.first.x.round() ?? defaultIndex;
              });
            },
            getTooltipColor: (barSpot) {
              return context.cs.surface;
            },
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map(
                (spot) {
                  final startDate = context.goalInfoMod.chartStartDate.addDay(
                    spot.x.round() - 1,
                  );
                  final label = switch (spot.barIndex) {
                    0 => startDate.formatEvenShorter(),
                    1 => "Avg",
                    2 => "Diff",
                    _ => "",
                  };
                  final color = switch (spot.barIndex) {
                    0 => context.goalInfoMod.accentColors.current,
                    1 => Colors.lightGreen,
                    2 => context.read<SharedElementRepository>().accentColors.getColorByValue(
                      spot.y,
                      reversed: progress.goalType == GoalType.budget,
                    ),
                    _ => Colors.transparent,
                  };
                  final data = switch (spot.barIndex) {
                    2 =>
                      (spot.y >= 0 ? "▲" : "▼") +
                          context.goalInfoMod.compactCurrencyFormat(
                            spot.y.abs(),
                          ),
                    _ => context.goalInfoMod.compactCurrencyFormat(spot.y),
                  };
                  // == 0 ? "Limit" : startDate.formatShorter();
                  return LineTooltipItem(
                    "$label: $data",
                    context.tt.bodyMedium!.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight(500),
                      color: color,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.end,
                  );
                },
              ).toList();
            },
          ),
          borderData: FlBorderData(show: false),
          gridData: customGrid,
          showingTooltipIndicators: [
            // ShowingTooltipIndicators([LineBarSpot(LineChartBarData(), 1, spots.elementAtOrNull(8) ?? FlSpot(0, 0))]),
            ShowingTooltipIndicators([
              if (cumulativeSpots.elementAtOrNull(_index) != null)
                LineBarSpot(
                  LineChartBarData(),
                  0,
                  cumulativeSpots.elementAtOrNull(_index) ?? FlSpot(0, 0),
                ),
              if (showAvgLine)
                LineBarSpot(
                  LineChartBarData(),
                  1,
                  dailyAvgSpots.elementAtOrNull(_index) ?? FlSpot(0, 0),
                ),
              if (cumulativeSpots.elementAtOrNull(_index) != null && showAvgLine)
                LineBarSpot(
                  LineChartBarData(),
                  2,
                  diffSpots.elementAtOrNull(indicatorIndex) ?? FlSpot(0, 0),
                ),
            ]),
            // ShowingTooltipIndicators([
            //   LineBarSpot(LineChartBarData(), 0, FlSpot(0, target ?? 0)),
            // ]),
          ],
          lineBarsData: [
            // getCustomLineChartBarData(
            //   isCurved: false,
            //   showGradient: true,
            //   color: Colors.white,
            //   dashArray: [2, 8],
            //   spots: targetSpots,
            // ),
            getCustomLineChartBarData(
              dotData: FlDotData(
                checkToShowDot: (spot, barData) {
                  final date = context.goalInfoMod.chartStartDate.addDay(spot.x.round() - 1);
                  return DateTime.now().standard == date;
                },
              ),
              showingIndicators: [indicatorIndex],
              isCurved: false,
              color: context.cs.secondary,
              spots: cumulativeSpots.toList(),
            ),
            getCustomLineChartBarData(
              dotData: FlDotData(
                checkToShowDot: (spot, barData) {
                  return false;
                },
              ),
              showingIndicators: [indicatorIndex],
              isCurved: false,
              showGradient: true,
              color: Colors.lightGreen,
              dashArray: [1, 15],
              spots: [...dailyAvgSpots],
            ),
          ],
        ),
      ),
    );
  }
}

class GoalAvgTargetInfoChart extends StatelessWidget {
  const GoalAvgTargetInfoChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Daily Spend",
          style: context.customTt.dateLabel,
        ),
        GoalAvgTargetBarChart(),
      ],
    );
  }
}

class GoalAvgTargetBarChart extends StatefulWidget {
  const GoalAvgTargetBarChart({super.key});

  @override
  State<GoalAvgTargetBarChart> createState() => _GoalAvgTargetBarChartState();
}

class _GoalAvgTargetBarChartState extends State<GoalAvgTargetBarChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final dailyData = context.goalInfoMod.dailyData.entries;
    final maxData = dailyData.fold(0.0, (init, entry) => max(init, entry.value ?? 0));
    final dailyTarget = context.goalInfoMod.targetSpendPerDay;
    final List<int> showValues = [];
    final isBudget = goal.goalType == GoalType.budget;
    for (final (index, entry) in dailyData.indexed) {
      if ((entry.value ?? 0) > dailyTarget) {
        showValues.add(index);
      }
    }
    return SizedBox(
      height: 200,
      child: BarChart(
        duration: Duration.zero,
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          maxY: max(dailyTarget, maxData) * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchCallback: (event, response) {
              setState(() {
                if (event.isInterestedForInteractions) {
                  _touchedIndex = response?.spot?.touchedBarGroup.x;
                } else {
                  _touchedIndex = null;
                }
              });
            },
            // touchExtraThreshold: EdgeInsets.symmetric(vertical: 50),
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.black,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final date = dailyData.elementAt(groupIndex).key;
                final value = dailyData.elementAt(groupIndex).value ?? 0;
                final percentage = (value / dailyTarget).formatCompactPercentage();
                final c = group.barRods.first.toY;
                return BarTooltipItem(
                  // ignore: prefer_interpolation_to_compose_strings
                  date.formatEvenShorter() +
                      "\n" +
                      context.goalInfoMod.compactCurrencyFormat(
                        c,
                      ),
                  context.tt.bodyMedium!.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight(500),
                    height: 1.2,
                  ),
                  children: [
                    TextSpan(
                      text: " ($percentage)",
                      style: TextStyle(
                        color: context.goalInfoMod.accentColors.getColorByValue(
                          value - dailyTarget,
                          reversed: goal.goalType == GoalType.budget,
                        ),
                      ),
                    ),
                  ],
                );
              },
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              tooltipMargin: 200,
            ),
            allowTouchBarBackDraw: true,
          ),
          gridData: customGrid,
          borderData: FlBorderData(show: false),
          titlesData: getCustomChartTitleData(
            context: context,
            bottomTitle: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return ChartBottomTitleLabel(value: value);
                },
              ),
            ),
          ),
          extraLinesData: getHorizontalExtraLines(context, y: [dailyTarget], showYLabel: [true]),
          barGroups: [
            ...dailyData.mapIndexed((index, el) {
              final value = el.value ?? 0;
              return BarChartGroupData(
                // showingTooltipIndicators: [0],
                groupVertically: true,
                x: index,
                barRods: [
                  BarChartRodData(
                    backDrawRodData: BackgroundBarChartRodData(
                      fromY: 0,
                      toY: maxData,
                      show: true,
                      color: Colors.transparent,
                    ),
                    toY: value,
                    color: context.goalInfoMod.accentColors.getColorByValue(-1, reversed: isBudget),
                    width: 4,
                    rodStackItems: [
                      BarChartRodStackItem(
                        0,
                        dailyTarget,
                        context.goalInfoMod.accentColors.getColorByValue(1, reversed: isBudget),
                      ),
                    ],
                    label: BarChartRodLabel(
                      show: showValues.contains(index),
                      text: '\n${(value / dailyTarget).formatCompactPercentage()}',
                      style: context.customTt.paragraphTextSmall!.copyWith(
                        fontSize: 9,
                        color: context.goalInfoMod.accentColors.getColorByValue(
                          -1,
                          reversed: isBudget,
                        ),
                      ),
                      offset: Offset(0, 10),
                    ),
                  ),
                  BarChartRodData(
                    toY: maxData,
                    width: 0.5,
                    color: _touchedIndex == index ? Colors.white : Colors.transparent,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
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
                TextSpan(
                  text: context.goalInfoMod.currencyFormat(target),
                  style: highlightFontStyle,
                ),
                TextSpan(
                  text: ".\n\nYour spend till today (",
                ),
                TextSpan(text: DateTime.now().formatShort(), style: highlightFontStyle),
                TextSpan(
                  text: ") is ",
                ),
                TextSpan(
                  text: context.goalInfoMod.currencyFormat(
                    context.goalInfoMod.currentGoalProgress.value,
                  ),
                  style: highlightFontStyle,
                ),
                TextSpan(
                  text: ".\n\nTo prevent budget overrun, you would need to spend below ",
                ),
                TextSpan(
                  text: context.goalInfoMod.currencyFormat(context.goalInfoMod.remainingValue),
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
                  text: context.goalInfoMod.currencyFormat(
                    context.goalInfoMod.remainingValueOverDay,
                  ),
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
              color = context.goalInfoMod.accentColors.negative;
            } else {
              color =
                  Color.lerp(
                    context.goalInfoMod.accentColors.positive,
                    context.cs.secondary,
                    (value) / widget.target!,
                  )!;
            }
          } else {
            color = context.goalInfoMod.accentColors.positive;
          }
        } else {
          color = context.customCs.fadeColor2!;
        }
        return Tooltip(
          enableTapToDismiss: false,
          textStyle: context.tt.bodyMedium!.copyWith(
            fontSize: 9,
            color: Color.lerp(color, Colors.white, 1),
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
                  text: context.goalInfoMod.currencyFormat(context.goalInfoMod.targetSpendPerDay),
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
          //   Row(
          //     spacing: 6,
          //     children: [
          //       Text("Low", style: context.customTt.paragraphText!.copyWith(fontSize: 14)),
          //       Expanded(
          //         child: Container(
          //           height: 10,
          //           decoration: BoxDecoration(
          //             borderRadius: BorderRadius.circular(2),
          //             gradient: LinearGradient(
          //               begin: Alignment.centerLeft,
          //               end: Alignment.centerRight,
          //               colors: [Colors.green, context.cs.secondary],
          //             ),
          //           ),
          //         ),
          //       ),
          //       Text("High", style: context.customTt.paragraphText!.copyWith(fontSize: 14)),
          //       SizedBox(
          //         width: 10,
          //       ),
          //       Container(
          //         height: 10,
          //         width: 10,
          //         decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(2),
          //           color: Colors.red,
          //         ),
          //       ),
          //       Text("Exceed", style: context.customTt.paragraphText!.copyWith(fontSize: 14)),
          //     ],
          //   ),
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
                  text: context.goalInfoMod.currencyFormat(context.goalInfoMod.targetSpendPerDay),
                  style: highlightFontStyle,
                ),
                TextSpan(text: ".\n\nThis month, you have spent "),
                TextSpan(
                  text: context.goalInfoMod.currencyFormat(
                    context.goalInfoMod.currentGoalProgress.value,
                  ),
                  style: highlightFontStyle,
                ),
                TextSpan(text: " across "),
                TextSpan(
                  text: '${context.goalInfoMod.currentDay}',
                  style: highlightFontStyle,
                ),
                TextSpan(text: " days, which is equivalent to "),
                TextSpan(
                  text: context.goalInfoMod.currencyFormat(context.goalInfoMod.currentSpendPerDay),
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

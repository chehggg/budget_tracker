import 'dart:math';

import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/classes/goal_class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
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

class GoalPastDetailsScreen extends StatelessWidget {
  const GoalPastDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ready = context.select((GoalInfoViewModel state) => state.ready);
    final prevDate = context.select((GoalInfoViewModel state) => state.prevDate);
    return CustomScaffold(
      appBarTitle: Text("Goal Past Details - ${prevDate?.formatMonth()}"),
      // padHorizontal: true,
      actions: [],
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
      // padHorizontal: true,
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
        //   icon: FaIcon(
        //     FontAwesomeIcons.trash,
        //     size: 18,
        //   ),
        // ),
        IconButton(
          onPressed: () {
            context.push('/goals/edit-goal', extra: goal);
          },
          icon: FaIcon(FontAwesomeIcons.pencil, size: 18),
        ),
        CustomMenuAnchor(
          animated: true,
          items: [
            MenuChild(
              icon: FontAwesomeIcons.copy,
              name: "Duplicate",
              onTap: () async {
                final response = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Copy Goal"),
                      content: Text(
                        "Create a copy of this goal?",
                      ),
                      actions: [
                        DismissTextButton(
                          onTap: () => context.pop(false),
                        ),
                        AffirmativeTextButton(onTap: () => context.pop(true)),
                      ],
                    );
                  },
                );
                if (response == true) {
                  context.goalInfoMod.createDuplicate();
                  context.pop();
                }
              },
            ),
            MenuChild(
              icon: FontAwesomeIcons.calendarCheck,
              name: "Mark as done",
              onTap: () async {
                final response = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("End Goal"),
                      content: Text(
                        "Mark this goal as completed? \nThis month's progress will be discarded, but previous goal progress will still be visible.",
                      ),
                      actions: [
                        DismissTextButton(
                          onTap: () => context.pop(false),
                        ),
                        AffirmativeTextButton(onTap: () => context.pop(true)),
                      ],
                    );
                  },
                );
                if (response == true) {
                  context.goalInfoMod.updateEndDate();
                  context.pop();
                }
              },
            ),
            MenuChild(
              onTap: () async {
                final response = await showDialog(
                  context: context,
                  builder: (context) {
                    return DeleteItemDialog();
                  },
                );
                if (response == true) {
                  context.goalInfoMod.deleteGoal();
                  context.pop();
                }
              },
              color: Colors.red,
              icon: FontAwesomeIcons.trash,
              name: "Delete",
            ),
          ],
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

  Widget get sliverPad {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      sliver: SliverToBoxAdapter(
        child: Divider(),
      ),
    );
  }

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GoalInfoTitleContainer(
              showPrevious: showPrevious,
            ),
          ),
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
                                curProgress.isBudget && !curProgress.achieved
                                    ? context.goalInfoMod.accentColors.negative.withAlpha(150)
                                    : !curProgress.isBudget && curProgress.achieved
                                    ? context.goalInfoMod.accentColors.positive.withAlpha(150)
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
                    curProgress.currentStatus,
                    style: context.tt.bodyMedium!.copyWith(
                      fontSize: 16,
                      height: 1.1,
                      fontWeight: FontWeight(600),
                      color:
                          curProgress.currentStatus == "Pending"
                              ? context.cs.secondary.withAlpha(250)
                              : curProgress.achieved
                              ? context.goalInfoMod.accentColors.positive.withAlpha(
                                250,
                              )
                              : context.goalInfoMod.accentColors.negative.withAlpha(
                                250,
                              ),
                    ),
                  ),
                  // Text(
                  //   curProgress.date?.formatMonthLonger() ?? "",
                  //   style: context.customTt.paragraphTitle,
                  // ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    curProgress.progress.formatDecimalPercentage(),
                    style: context.customTt.dateLabel!.copyWith(fontSize: 48, height: 1.1),
                  ),
                  Text(
                    "${curProgress.value.formatRoundedString()} / ${curProgress.target?.formatRoundedString()}",
                    style: context.tt.bodyMedium!.copyWith(
                      fontSize: 14,
                      color: context.customCs.fadeColor1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!showPrevious)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GoalDetailsExpansionTile(),
            ),
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
        sliverPad,
        // SliverPadding(
        //   padding: const EdgeInsets.symmetric(vertical: 12.0),
        //   sliver: SliverToBoxAdapter(
        //     child: const AverageSpendBarChart(),
        //   ),
        // ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
          sliver: SliverToBoxAdapter(
            child: GoalInfoLineChart(showPrevious: showPrevious),
          ),
        ),
        sliverPad,
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
          sliver: SliverToBoxAdapter(
            child: GoalAvgTargetInfoChart(showPrevious: showPrevious),
          ),
        ),
        sliverPad,
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
          sliver: SliverToBoxAdapter(
            child: GoalInfoHeatmapChart(showPrevious: showPrevious),
          ),
        ),
        if (context.goalInfoMod.showHistory && !showPrevious)
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            sliver: SliverToBoxAdapter(
              child: Divider(),
            ),
          ),
        if (context.goalInfoMod.showHistory && !showPrevious)
          PaginatedPastProgressList(
            itemPerPage: 6,
          ),
        SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

class PaginatedPastProgressList extends StatefulWidget {
  const PaginatedPastProgressList({
    super.key,
    required this.itemPerPage,
  });

  final int itemPerPage;

  @override
  State<PaginatedPastProgressList> createState() => _PaginatedPastProgressListState();
}

class _PaginatedPastProgressListState extends State<PaginatedPastProgressList> {
  int _curPage = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final slicedItems = context.goalInfoMod.pastProgress.slices(widget.itemPerPage);
    final pagedItems = slicedItems.elementAt(_curPage - 1);
    final streak = context.goalInfoMod.streak;

    return SliverList(
      delegate: SliverChildListDelegate([
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
                child: Text("History", style: context.customTt.dateLabel),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  if (_curPage > 1) {
                    _curPage--;
                  }
                });
              },
              icon: FaIcon(
                FontAwesomeIcons.angleLeft,
                size: 16,
              ),
            ),
            Row(
              children: [
                Text("$_curPage "),
                Text(
                  "of ${slicedItems.length}",
                  style: context.customTt.paragraphText,
                ),
              ],
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  if (_curPage < slicedItems.length) {
                    _curPage++;
                  }
                });
              },
              icon: FaIcon(FontAwesomeIcons.angleRight, size: 16),
            ),
          ],
        ),
        if (streak > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
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
        ...pagedItems.map(
          (progress) => GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              context.goalInfoMod.updatePreviousDate(progress.date!);
              context.push(
                '/goals/details-past',
                extra: context.goalInfoMod,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
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
    );
  }
}

class GoalInfoTitleContainer extends StatelessWidget {
  const GoalInfoTitleContainer({super.key, required this.showPrevious});

  final bool showPrevious;

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
          if (!showPrevious)
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
          if (!showPrevious)
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

class GoalInfoHeatmapChart extends StatefulWidget {
  const GoalInfoHeatmapChart({
    super.key,
    required this.showPrevious,
  });

  final bool showPrevious;

  @override
  State<GoalInfoHeatmapChart> createState() => _GoalInfoHeatmapChartState();
}

class _GoalInfoHeatmapChartState extends State<GoalInfoHeatmapChart> {
  DateTime _initDate = DateTime.now().startOfMonth;

  @override
  Widget build(BuildContext context) {
    final dailSpendPercent = context.goalInfoMod.targetReachingPercentage;
    final isOverall = context.goalInfoMod.goal.goalTracking == GoalTrackingPeriod.overall;
    final dailyData =
        widget.showPrevious
            ? context.goalInfoMod.previousDailyData
            : Map.fromEntries(
              context.goalInfoMod.currentDailyData.entries.where(
                (el) => isOverall ? el.key.isInSameYearMonthAs(_initDate) : true,
              ),
            );
    final dataCount =
        context.goalInfoMod.getDynamicProgress(previous: widget.showPrevious).displayedDataCount;
    final targetReachingDays = context.goalInfoMod.targetReachingDays;
    final dateCount = _initDate.dayinCurrentMonth;
    final dailyTarget = context.goalInfoMod.targetSpendPerDay;
    // final date = widget.showPrevious
    //                 ? context.goalInfoMod.previousDailyData
    //                 : Map.fromEntries(
    //                   context.goalInfoMod.currentDailyData.entries.where(
    //                     (el) => isOverall ? el.key.isInSameYearMonthAs(_initDate) : true,
    //                   ),
    //                 );
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
            if (isOverall)
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _initDate = _initDate.addMonth(-1);
                      });
                    },
                    icon: FaIcon(
                      FontAwesomeIcons.angleLeft,
                      size: 14,
                    ),
                  ),
                  Text(_initDate.formatMonthLonger()),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _initDate = _initDate.addMonth(1);
                      });
                    },
                    icon: FaIcon(FontAwesomeIcons.angleRight, size: 14),
                  ),
                ],
              ),
            // IconButton(
            //   iconSize: 16,

            //   visualDensity: VisualDensity(vertical: -4, horizontal: -4),
            //   padding: EdgeInsets.zero,
            //   onPressed: () {
            //     showDialog(
            //       context: context,
            //       builder: (_) => HeatmapDialog(context: context),
            //     );
            //   },
            //   icon: Icon(
            //     Icons.help_outline,
            //   ),
            // ),
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
          padding: const EdgeInsets.only(top: 8),
          child: HeatmapGraph(
            isBudget: context.goalInfoMod.currentGoalProgress.isBudget,
            target: dailyTarget,
            totalCount: isOverall ? _initDate.dayinCurrentMonth : dataCount,
            getTooltipMessage: (index) {
              final dayData = dailyData.entries.elementAtOrNull(index);
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
            data: dailyData,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12, right: 12.0),
          child: Text.rich(
            TextSpan(
              text: "You spent below the daily spend limit for ",
              style: context.customTt.paragraphTextSmall!.copyWith(fontSize: 14),
              children: [
                // ignore: prefer_interpolation_to_compose_strings
                TextSpan(
                  text: "$targetReachingDays/$dataCount",
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
                TextSpan(text: ")."),
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
  const GoalInfoLineChart({super.key, required this.showPrevious});

  final bool showPrevious;

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
                    "Cumulative",
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
                    spacing: 12,
                    children: [
                      LabelIndicator(
                        text: "Spend",
                        color: context.goalInfoMod.accentColors.current,
                        fade: true,
                      ),
                      GestureDetector(
                        onTap: () {
                          context.goalInfoMod.toggleShowAvgLine();
                        },
                        child: LabelIndicator(
                          text: "Target Daily Average",
                          color: Colors.lightGreen,
                          fade: true,
                          showVisibleSymbol: true,
                          enabled: showAvg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        GoalCumulativeChart(showPrevious: showPrevious),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 12),
          child:
              achieved
                  ? Text.rich(
                    TextSpan(
                      text: "Spend below ",
                      style: context.customTt.paragraphTextSmall!.copyWith(fontSize: 14),
                      children: [
                        // TextSpan(
                        //   text: context.goalInfoMod.currencyFormat(
                        //     context.goalInfoMod.remainingValueOverDay,
                        //   ),
                        //   style: context.customTt.numberFontSmall!.copyWith(
                        //     fontSize: 14,
                        //     color: context.cs.secondary,
                        //   ),
                        // ),
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
  const GoalCumulativeChart({super.key, this.showPrevious = false});

  final bool showPrevious;

  @override
  State<GoalCumulativeChart> createState() => _GoalCumulativeChartState();
}

class _GoalCumulativeChartState extends State<GoalCumulativeChart> {
  int? _index;

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final contextWatch = context.watch<GoalInfoViewModel>();
    final target = context.goalInfoMod.goal.target;
    final showAvgLine = context.goalInfoMod.showAvgLine;
    final curViewedProgress = context.select(
      (GoalInfoViewModel state) =>
          widget.showPrevious ? state.currentViewedPastGoalProgress : state.currentGoalProgress,
    );
    final cumulativeSpots = context.goalInfoMod
        .getLineChartCumulativeData(previous: widget.showPrevious)
        .entries
        // .where((entry) => entry.value != null)
        .mapIndexed(
          (index, el) {
            return FlSpot(index.toDouble(), (el.value ?? 0).clamp(0, double.infinity));
          },
        );
    final dailyAvg = curViewedProgress.dailyTarget;
    final dailyAvgSpots = List.generate(
      curViewedProgress.totalData,
      (i) => FlSpot(i.toDouble(), dailyAvg * (i + 1)),
    );
    final int defaultIndex = (cumulativeSpots.length - 1).clamp(0, double.infinity).round();
    final diffSpots = cumulativeSpots.mapIndexed((index, el) {
      final currentY = el.y;
      final targetY = dailyAvgSpots.elementAt(index).y;
      final diff = (currentY - targetY);
      return FlSpot(index.toDouble(), diff);
    });
    final int indicatorIndex = _index ?? defaultIndex;
    return Container(
      padding: EdgeInsets.only(top: 12, left: 4, right: 4, bottom: 12),
      height: 200,
      child: LineChart(
        duration: Duration.zero,
        LineChartData(
          titlesData: getCustomChartTitleData(
            context: context,
            bottomTitle: AxisTitles(
              sideTitles: SideTitles(
                interval: cumulativeSpots.length > 50 ? null : 1,
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return ChartBottomTitleLabel(value: value);
                },
              ),
            ),
            showLeft: true,
            showRight: true,
          ),
          extraLinesData: getHorizontalExtraLines(
            context,
            y: [target ?? 0],
            showYLabel: [true],
            x: [indicatorIndex.toDouble()],
          ),
          maxY:
              ((curViewedProgress.value * 1.4) > (target ?? 0))
                  ? curViewedProgress.value * 1.4
                  : target,
          minY: 0,
          maxX: dailyAvgSpots.length - 1,
          lineTouchData: getCustomLineTouchData(
            enabled: false,
            context: context,
            touchCallback: (event, response) {
              if (!event.isInterestedForInteractions ||
                  response == null ||
                  response.lineBarSpots == null) {
                setState(() {
                  _index = defaultIndex;
                });
                return;
              }

              setState(() {
                _index = response.lineBarSpots?.first.x.round() ?? defaultIndex;
              });
            },
            getTooltipColor: (barSpot) {
              return context.cs.surface.withAlpha(200);
            },
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map(
                (spot) {
                  final startDate = (curViewedProgress.date ?? DateTime.now().standard).addDay(
                    spot.x.round(),
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
                    2 =>
                      (curViewedProgress.compareValueWithTarget(value: spot.y, target: 0))
                          ? context.goalInfoMod.accentColors.positive
                          : context.goalInfoMod.accentColors.negative,
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
            ShowingTooltipIndicators([
              if (cumulativeSpots.elementAtOrNull(indicatorIndex) != null)
                LineBarSpot(
                  LineChartBarData(),
                  0,
                  cumulativeSpots.elementAtOrNull(indicatorIndex) ?? FlSpot(0, 0),
                ),
              if (showAvgLine)
                LineBarSpot(
                  LineChartBarData(),
                  1,
                  dailyAvgSpots.elementAtOrNull(indicatorIndex) ?? FlSpot(0, 0),
                ),
              if (cumulativeSpots.elementAtOrNull(indicatorIndex) != null && showAvgLine)
                LineBarSpot(
                  LineChartBarData(),
                  2,
                  diffSpots.elementAtOrNull(indicatorIndex) ?? FlSpot(0, 0),
                ),
            ]),
          ],
          lineBarsData: [
            getCustomLineChartBarData(
              dotData: FlDotData(
                checkToShowDot: (spot, barData) {
                  final date = curViewedProgress.date?.addDay(spot.x.round());
                  return DateTime.now().standard == date;
                },
              ),
              showingIndicators: [indicatorIndex],
              isCurved: false,
              color: context.cs.secondary,
              spots: cumulativeSpots.toList(),
            ),
            if (showAvgLine)
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
  const GoalAvgTargetInfoChart({super.key, required this.showPrevious});

  final bool showPrevious;

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
        GoalProgressDailyBarChart(
          showPrevious: showPrevious,
        ),
      ],
    );
  }
}

class GoalProgressDailyBarChart extends StatefulWidget {
  const GoalProgressDailyBarChart({super.key, required this.showPrevious});

  final bool showPrevious;

  @override
  State<GoalProgressDailyBarChart> createState() => _GoalProgressDailyBarChartState();
}

class _GoalProgressDailyBarChartState extends State<GoalProgressDailyBarChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final contextWatch = context.watch<GoalInfoViewModel>();
    final curViewedProgress =
        widget.showPrevious
            ? context.goalInfoMod.currentViewedPastGoalProgress
            : context.goalInfoMod.currentGoalProgress;
    // final dailyData = context.goalInfoMod.cu;
    final dailyData = context.select(
      (GoalInfoViewModel state) =>
          widget.showPrevious ? state.previousDailyData.entries : state.currentDailyData.entries,
    );
    final maxData = dailyData.fold(0.0, (init, entry) => max(init, entry.value ?? 0));
    final dailyTarget = curViewedProgress.dailyTarget;
    final showAvgLine = context.select((GoalInfoViewModel state) => state.showAvgLine);
    final List<int> showValues = [];
    final isBudget = curViewedProgress.isBudget;
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
                          reversed: curViewedProgress.isBudget,
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
                interval: dailyData.length > 50 ? null : 1,
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return ChartBottomTitleLabel(value: value);
                },
              ),
            ),
            showLeft: true,
            showRight: true,
          ),
          extraLinesData: getHorizontalExtraLines(
            context,
            y: [0, if (showAvgLine) dailyTarget],
            showYLabel: [false, true],
          ),
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
                    // color: context.goalInfoMod.accentColors.negative,
                    color:
                        isBudget
                            ? context.goalInfoMod.accentColors.negative
                            : context.goalInfoMod.accentColors.positive,
                    width: 4,
                    rodStackItems: [
                      BarChartRodStackItem(
                        isBudget ? 0 : double.maxFinite * -1,
                        isBudget ? dailyTarget : 0,
                        isBudget
                            ? context.goalInfoMod.accentColors.positive
                            : context.goalInfoMod.accentColors.negative,
                      ),
                    ],
                    label: BarChartRodLabel(
                      show: showValues.contains(index),
                      text:
                          '\n${context.goalInfoMod.currencyFormat(value, compact: true, abbreviated: true, showSymbol: false, decimalDigits: 0)}',
                      style: context.customTt.paragraphTextSmall!.copyWith(
                        fontSize: 9,
                        color:
                            isBudget
                                ? context.goalInfoMod.accentColors.negative
                                : context.goalInfoMod.accentColors.positive,
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
    this.isBudget = true,
    required this.totalCount,
    required this.data,
    this.getTooltipMessage,
  });

  final bool isBudget;
  final double? target;
  final int totalCount;
  final Map<DateTime, double?> data;
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
    final count = (widget.totalCount / 7).ceil();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Column(
          children:
              List.generate(count, (el) {
                return Container(
                  height: 36,
                  child: Center(
                    child: Text(
                      "${(7 * el) + 1}",
                      style: context.customTt.paragraphText!.copyWith(fontSize: 12),
                    ),
                  ),
                );
              }).toList(),
        ),
        Expanded(
          child: GridView.builder(
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
              final date = widget.data.keys.elementAtOrNull(index);
              final message =
                  widget.getTooltipMessage == null ? "" : widget.getTooltipMessage!(index);
              Color color;
              if (value != null) {
                if (widget.target != null) {
                  if (widget.isBudget) {
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
                    color = context.goalInfoMod.accentColors.getColorByValue(
                      value - widget.target!,
                      reversed: widget.isBudget,
                    );
                  }
                } else {
                  color = context.goalInfoMod.accentColors.positive;
                }
              } else {
                if (date?.isBefore(DateTime.now()) ?? false) {
                  color =
                      widget.isBudget
                          ? context.goalInfoMod.accentColors.positive
                          : context.goalInfoMod.accentColors.negative;
                } else {
                  color = context.customCs.fadeColor2!;
                }
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
          ),
        ),
        Column(
          children:
              List.generate(count, (el) {
                return Container(
                  height: 36,
                  child: Center(
                    child: Text(
                      "${7 * (el + 1)}",
                      style: context.customTt.paragraphText!.copyWith(fontSize: 12),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
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

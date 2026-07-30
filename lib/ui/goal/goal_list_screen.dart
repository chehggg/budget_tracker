import 'package:budget_tracker/custom/classes/goal_class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/goal/goal_list_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GoalScreen extends StatelessWidget {
  const GoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ready = context.select((GoalViewModel state) => state.ready);
    final searchEnabled = context.select((GoalViewModel state) => state.searchOn);
    return PopScope(
      canPop: !searchEnabled,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.goalMod.toggleSearch(value: false);
        context.navMod.toggleFab(show: true);
      },
      child: CustomScaffold(
        appBarTitle:
            searchEnabled
                ? Row(
                  children: [
                    BackButton(
                      onPressed: () {
                        context.goalMod.toggleSearch(value: false);
                        context.navMod.toggleFab(show: true);
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        style: context.tt.bodyMedium,
                        autofocus: true,
                        decoration: InputDecoration(
                          filled: false,
                          hintText: "Search for goals via text or description...",
                          hintStyle: context.customTt.paragraphText,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onChanged: context.goalMod.updateSearch,
                      ),
                    ),
                  ],
                )
                : Text("GOALS"),
        actions:
            searchEnabled
                ? []
                : [
                  IconButton(
                    onPressed: () {
                      context.goalMod.toggleSearch(value: true);
                      context.navMod.toggleFab(show: false);
                    },
                    icon: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 20),
                  ),
                  IconButton(
                    onPressed: () async {
                      final response = await showCustomModalSheet(
                        context: context,
                        builder: (context) {
                          return GoalListFilterSheet();
                        },
                      );
                      if (response == null) return;
                      // context.push("/goals/new-goal");
                    },
                    icon: FaIcon(FontAwesomeIcons.layerGroup, size: 20),
                  ),
                  IconButton(
                    onPressed: () {
                      context.push("/goals/new-goal");
                    },
                    icon: FaIcon(FontAwesomeIcons.plus, size: 20),
                  ),
                ],
        ready: ready,
        child: const GoalBody(),
      ),
    );
  }
}

class GoalListFilterSheet extends StatelessWidget {
  const GoalListFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "List View",
                  style: context.customTt.dateLabel,
                ),
              ),
              IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: FaIcon(
                  FontAwesomeIcons.check,
                  size: 18,
                ),
              ),
            ],
          ),
          Divider(
            height: 20,
          ),
          Text(
            "Group by",
            style: context.customTt.dateLabel!.copyWith(fontSize: 20),
          ),
          CustomDropDownMenu(
            entries:
                [
                  "Progress",
                  "Tracking Type",
                  "Goal Type",
                ].map((el) => DropdownMenuEntry(value: el, label: el)).toList(),
          ),
          Text(
            "Sort by",
            style: context.customTt.dateLabel!.copyWith(fontSize: 20),
          ),
          CustomDropDownMenu(
            entries:
                [
                  "Progress",
                  "Name",
                  "Last Created",
                  "Last Modified",
                ].map((el) => DropdownMenuEntry(value: el, label: el)).toList(),
          ),
        ],
      ),
    );
  }
}

class GoalBody extends StatelessWidget {
  const GoalBody({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final contextWatch = context.watch<GoalViewModel>();
    final goals = context.select((GoalViewModel state) => state.goalOverview);
    final goalsInProgress = goals.entries.where(
      (entry) => entry.key.isStarted && !entry.key.isEnded,
    );

    final finishedGoals = [
      ...goals.entries.where((entry) => entry.key.isEnded),
      ...goals.entries.where((entry) => !entry.key.isStarted),
    ];

    debugPrint("update goal screen");
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          sliver: SliverToBoxAdapter(
            child: ReusableContainer(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 12),
              filled: true,
              highlight: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Text(
                  //   "${goals.length} ${usePlural ? "goals" : "goal"}",
                  //   style: context.customTt.numberFontLarge!.copyWith(color: context.cs.surface),
                  // ),
                  Text(
                    "Past month progress",
                    style: context.customTt.paragraphText!.copyWith(color: context.cs.surface),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.ideographic,
                    spacing: 10,
                    children: [
                      Text(
                        "68%",
                        style: context.customTt.numberFontLarge!.copyWith(
                          color: context.cs.surface,
                          height: 1.3,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Achieved (6/8)",
                          style: context.customTt.numberFontSmall!.copyWith(
                            color: context.cs.surface,
                          ),
                        ),
                      ),
                      Text(
                        "See more",
                        style: context.customTt.paragraphText!.copyWith(
                          color: context.cs.surface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 12),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: true,
                title: Row(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text("In Progress", style: context.customTt.dateLabel),
                    Text(
                      "(${(goalsInProgress.length)} goal${goalsInProgress.length.getPlural()})",
                      style: context.customTt.paragraphText,
                    ),
                  ],
                ),
                tilePadding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                children: [
                  ...goalsInProgress.map((goalEntry) {
                    final goalProgress = goalEntry.value;
                    return GoalTile(goalProgress: goalProgress, goal: goalEntry.key);
                  }),
                ],
              ),
            ),
          ),
        ),
        if (finishedGoals.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 0),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: false,
                  title: Row(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text("Not In Progress", style: context.customTt.dateLabel),
                      Text(
                        "(${(finishedGoals.length)} goal${finishedGoals.length.getPlural()})",
                        style: context.customTt.paragraphText,
                      ),
                    ],
                  ),
                  tilePadding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  childrenPadding: EdgeInsets.only(top: 0),
                  dense: true,
                  children: [
                    ...finishedGoals.map((entry) {
                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 12.0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                context.push('/goals/details', extra: entry.key);
                              },
                              behavior: HitTestBehavior.translucent,
                              child: Column(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    entry.key.title ?? "",
                                    style: context.customTt.paragraphTitle!.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  Text(
                                    entry.key.isEnded
                                        ? "Ended on ${entry.key.endDate?.formatMonthLonger() ?? ""}"
                                        : "Will start on ${entry.key.startDate?.formatMonthLonger() ?? ""}",
                                    style: context.customTt.paragraphTextSmall!.copyWith(
                                      // decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Divider(),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }
}

class GoalTile extends StatelessWidget {
  const GoalTile({
    super.key,
    required this.goalProgress,
    required this.goal,
  });

  final Goal goal;
  final GoalProgress goalProgress;

  @override
  Widget build(BuildContext context) {
    context.watch<GoalViewModel>();
    final clampedProgress = goalProgress.progress.clamp(0.0, 1.0);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.push('/goals/details', extra: goal);
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                            Expanded(
                              child: Text(
                                goal.title ?? "Untitled Goal",
                                style: context.customTt.numberFontMedium!.copyWith(
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: BoxBorder.all(
                                  width: 1,
                                  color: Colors.white.withAlpha(50),
                                ),
                                color:
                                    goalProgress.currentStatus == "Pending"
                                        ? context.cs.secondary.withAlpha(60)
                                        : goalProgress.achieved
                                        ? context.goalMod.accentColors.positive.withAlpha(
                                          60,
                                        )
                                        : context.goalMod.accentColors.negative.withAlpha(
                                          60,
                                        ),
                              ),
                              child: Center(
                                child: Text(
                                  goalProgress.currentStatus,
                                  style: context.customTt.paragraphText!.copyWith(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              // ignore: prefer_interpolation_to_compose_strings
                              (goal.goalTracking == GoalTrackingPeriod.monthly
                                      ? "Mthly"
                                      : "Until ${DateFormat('MMM yy').format(goal.endDate ?? DateTime.now())}") +
                                  ", ${NumberFormat.compact().format(goalProgress.value)} / ${NumberFormat.compact().format(goalProgress.target)}",
                              style: context.customTt.paragraphTextSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Stack(
                  alignment: Alignment(0, 1.4),
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 36,
                        ),
                        Container(
                          // padding: EdgeInsets.only(right: 10),
                          width: 110,
                          height: 20,
                          clipBehavior: Clip.none,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: PieChart(
                              duration: Duration.zero,
                              PieChartData(
                                centerSpaceRadius: 44,
                                startDegreeOffset: -180,
                                sections: [
                                  PieChartSectionData(
                                    value: clampedProgress,
                                    radius: 6,
                                    cornerRadius: 8,
                                    color:
                                        goalProgress.achieved
                                            ? context.goalMod.accentColors.positive
                                            : context.goalMod.accentColors.negative,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    value: 1 - clampedProgress,
                                    radius: 6,
                                    cornerRadius: 8,
                                    color: context.customCs.fadeColor2,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    value: 1,
                                    cornerRadius: 8,
                                    radius: 6,
                                    color: Colors.transparent,
                                    showTitle: false,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      NumberFormat.percentPattern().format(goalProgress.progress),
                      style: context.customTt.dateLabel,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}

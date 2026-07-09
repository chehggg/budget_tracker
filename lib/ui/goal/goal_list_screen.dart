import 'dart:math';

import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/goal/goal_list_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GoalScreenWrapper extends StatelessWidget {
  const GoalScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: ChangeNotifierProvider(
        create: (context) {
          return GoalViewModel(costItemRepo: context.read(), goalRepo: context.read());
        },
        child: const GoalScreen(),
      ),
    );
  }
}

class GoalScreen extends StatelessWidget {
  const GoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ready = context.select((GoalViewModel state) => state.ready);
    return CustomScaffold(
      appBarTitle: Text("GOALS"),
      actions: [
        IconButton(
          onPressed: () {
            context.push("/goals/new-goal");
          },
          icon: Icon(Icons.add),
        ),
      ],
      ready: ready,
      child: GoalBody(),
    );
  }
}

class GoalBody extends StatelessWidget {
  const GoalBody({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = context.select((GoalViewModel state) => state.goalOverview);
    final usePlural = goals.length >= 2;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          sliver: SliverToBoxAdapter(
            child: ReusableContainer(
              filled: true,
              highlight: true,
              child: Text(
                "${goals.length} ${usePlural ? "goals" : "goals"}",
                style: context.customTt.dateLabel!.copyWith(color: context.cs.surface),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            goals.entries
                .map(
                  (goalEntry) => Column(
                    children: [
                      ReusableContainer(
                        filled: false,
                        showBorder: false,
                        // customColor:  Colors.green.withAlpha(40),
                        // highlight: true,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                        onTap: () {
                          context.push('/goals/details', extra: goalEntry.key);
                        },
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
                                      spacing: 4,
                                      children: [
                                        // Text("🔥"),
                                        // Icon(Icons.fire_hydrant_alt, size: 20, color: Colors.deepOrange.shade300,),
                                        Expanded(
                                          child: Text(
                                            goalEntry.key.title ?? "Untitled Goal",
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
                                      height: 8,
                                    ),
                                    Row(
                                      spacing: 8,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color:
                                                goalEntry.value.achieved
                                                    ? Colors.green.shade800.withAlpha(120)
                                                    : Colors.red.shade800.withAlpha(120),
                                          ),
                                          child: Text(
                                            goalEntry.value.status,
                                            style: context.customTt.numberFontSmall!.copyWith(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${NumberFormat.compact().format(goalEntry.value.value)} / ${NumberFormat.compact().format(goalEntry.value.target)}",
                                          style: context.customTt.paragraphText,
                                        ),
                                        // ReusableContainer(
                                        //   chil
                                        // )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Stack(
                              alignment: Alignment(0, 1.2),
                              clipBehavior: Clip.none,
                              children: [
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Container(
                                      // padding: EdgeInsets.only(right: 10),
                                      width: 110,
                                      height: 20,
                                      clipBehavior: Clip.none,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 16.0),
                                        child: PieChart(
                                          PieChartData(
                                            centerSpaceRadius: 44,
                                            startDegreeOffset: -180,
                                            sections: [
                                              PieChartSectionData(
                                                value: min(goalEntry.value.progress, 1),
                                                radius: 6,
                                                color:
                                                    goalEntry.value.achieved
                                                        ? Colors.green.shade800
                                                        : Colors.red.shade800,
                                                showTitle: false,
                                              ),
                                              PieChartSectionData(
                                                value: 1 - min(goalEntry.value.progress, 1),
                                                radius: 6,
                                                color: context.customCs.fadeColor2,
                                                showTitle: false,
                                              ),
                                              PieChartSectionData(
                                                value: 1,
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
                                  NumberFormat.percentPattern().format(goalEntry.value.progress),
                                  style: context.customTt.dateLabel,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        indent: 20,
                        endIndent: 20,
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

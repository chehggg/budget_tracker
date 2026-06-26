import 'dart:math';

import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/goal/goal_form_screen.dart';
import 'package:budget_tracker/ui/goal/goal_info_screen.dart';
import 'package:budget_tracker/ui/goal/goal_info_viewmodel.dart';
import 'package:budget_tracker/ui/goal/goal_view_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GoalScreen extends StatelessWidget {
  const GoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ready = context.select((GoalModel state) => state.ready);
    return Scaffold(
      appBar: AppBar(
        title: Text("GOALS"),
        actions: [
          IconButton(
            onPressed: () {
              context.navMod.goTo("/goals-form");
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(child: ready ? const GoalBody() : Center(child: CircularProgressIndicator())),
    );
  }
}

class GoalBody extends StatelessWidget {
  const GoalBody({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = context.select((GoalModel state) => state.goalOverview);
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
                  (e) => Column(
                    children: [
                      ReusableContainer(
                        filled: false,
                        showBorder: false,
                        // customColor:  Colors.green.withAlpha(40),
                        // highlight: true,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChangeNotifierProvider(
                                    create:
                                        (context) => GoalInfoViewmodel(
                                          goalRepos: context.read(),
                                          costItemRepo: context.read(),
                                          categoryRepo: context.read(),
                                          goal: e.key,
                                        ),
                                    child: const GoalInfoScreen(),
                                  ),
                            ),
                          );
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
                                            e.key.title ?? "Untitled Goal",
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
                                                e.value.achieved
                                                    ? Colors.green.shade800.withAlpha(120)
                                                    : Colors.red.shade800.withAlpha(120),
                                          ),
                                          child: Text(
                                            e.value.status,
                                            style: context.customTt.numberFontSmall!.copyWith(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${NumberFormat.compact().format(e.value.value)} / ${NumberFormat.compact().format(e.value.target)}",
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
                              alignment: Alignment(0,1.2),
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
                                                value: min(e.value.progress, 1),
                                                radius: 6,
                                                color:
                                                    e.value.achieved
                                                        ? Colors.green.shade800
                                                        : Colors.red.shade800,
                                                showTitle: false,
                                              ),
                                              PieChartSectionData(
                                                value: 1 - min(e.value.progress, 1),
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
                                  NumberFormat.percentPattern().format(e.value.progress),
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

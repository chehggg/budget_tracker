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
        actions: [
          IconButton(
            onPressed: () async {
              await context.nav.push(
                MaterialPageRoute(builder: (context) => const GoalFormScreen()),
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(child: ready ? Center(child: CircularProgressIndicator()) : GoalBody()),
    );
  }
}

class GoalBody extends StatelessWidget {
  const GoalBody({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = context.select((GoalModel state) => state.goalOverview);

    // final goals = context.select((GoalModel state) => state);
    // final test = context.select((ListModel state) => state.currentMonth);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: ReusableContainer(
              child: Text("There is ${goals.length} goals!"),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            goals.entries
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                    child: ReusableContainer(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ChangeNotifierProvider(
                                  create:
                                      (context) => GoalInfoViewmodel(
                                        goalRepository: context.read(),
                                        costItemRepo: context.read(),
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
                                      Text("🔥"),
                                      // Icon(Icons.fire_hydrant_alt, size: 20, color: Colors.deepOrange.shade300,),
                                      Expanded(
                                        child: Text(
                                          e.key.title ?? "Untitled Goal",
                                          style: context.customTt.dateLabel!.copyWith(fontSize: 20),
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
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color:
                                              e.value.achieved
                                                  ? Colors.green.shade800
                                                  : Colors.red.shade800,
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
                          Column(
                            children: [
                              SizedBox(
                                height: 24,
                              ),
                              Container(
                                // padding: EdgeInsets.only(right: 10),
                                width: 120,
                                height: 40,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsGeometry.only(top: 25),
                                      child: PieChart(
                                        PieChartData(
                                          centerSpaceRadius: 50,
                                          startDegreeOffset: -180,
                                          sections: [
                                            PieChartSectionData(
                                              value: min(e.value.progress, 1),
                                              radius: 6,
                                              color: context.cs.secondary,
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
                                    Text(
                                      NumberFormat.percentPattern().format(e.value.progress),
                                      style: context.customTt.dateLabel,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

import 'dart:math';

import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/form/form_screen.dart';
import 'package:budget_tracker/ui/goal/goal_form_screen.dart';
import 'package:budget_tracker/ui/goal/goal_form_viewmodel.dart';
import 'package:budget_tracker/ui/goal/goal_info_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GoalInfoScreen extends StatelessWidget {
  const GoalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goal = context.select((GoalInfoViewmodel state) => state.goal);
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
                context.nav.pushNamedAndRemoveUntil('/goals', ModalRoute.withName('/goals'));
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
                          (context) =>
                              GoalFormViewmodel(goalRepository: context.read(), initGoal: goal),
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
        child: const GoalInfoBody(),
      ),
    );
  }
}

class GoalInfoBody extends StatelessWidget {
  const GoalInfoBody({super.key});

  @override
  Widget build(BuildContext context) {
    final goal = context.select((GoalInfoViewmodel state) => state.goal);
    final goalProgress = context.select((GoalInfoViewmodel state) => state.goalProgress);
    final curProgress = goalProgress.last;
    final dayinCurMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
    final spendPerday = (goal.target ?? 0) / dayinCurMonth;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text(goal.title ?? "", style: context.customTt.dateLabel)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: curProgress.achieved ? Colors.green.shade800 : Colors.red.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      curProgress.status,
                      style: context.customTt.numberFontSmall?.copyWith(
                        // fontSize: 40,
                        color: context.cs.primary,
                        // color: curProgress.achieved ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              Text(goal.description ?? "", style: context.customTt.paragraphText),
            ],
          ),
        ),
        // SliverToBoxAdapter(
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.stretch,
        //     children: [
        //       SizedBox(
        //         height: 16,
        //       ),
        //       // Divider(),
        //       Text("Current Status", style: context.customTt.paragraphTitle),
        //       Text(
        //         curProgress.status,
        //         style: context.customTt.elegantLabelLarge?.copyWith(
        //           // fontSize: 40,
        //           color: curProgress.achieved ? Colors.green : Colors.red,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        SliverToBoxAdapter(
          child: Stack(
            alignment: AlignmentDirectional(0, 0.6),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 160,
                  ),
                  SizedBox(
                    height: 40,
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
                            value: 1 - curProgress.progress,
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
                    "${curProgress.value} / ${curProgress.target}",
                    style: context.customTt.numberFontSmall,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    NumberFormat.percentPattern().format(curProgress.progress),
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
          child: Theme(
            data: Theme.of(
              context,
            ).copyWith(dividerColor: Colors.transparent, splashFactory: NoSplash.splashFactory),
            child: ExpansionTile(
              title: Text("Details", style: context.customTt.paragraphTitle),
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              expandedAlignment: AlignmentGeometry.centerLeft,

              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Created on ${goal.lastCreated!.formatFull()}",
                      style: context.customTt.paragraphText,
                    ),
                    Text(
                      "Last Modified on ${goal.lastModified!.formatFull()}",
                      style: context.customTt.paragraphText,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Divider(),
              Text("Visualize", style: context.customTt.dateLabel),
              SizedBox(
                height: 100,
                child: BarChart(
                  BarChartData(
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: spendPerday,
                          strokeWidth: 1.2,
                          color: Colors.blue.shade400,
                          dashArray: [2, 5],
                          strokeCap: StrokeCap.round,
                        ),
                      ],
                    ),
                    titlesData: FlTitlesData(show: false),
                    barGroups: [
                      ...List.generate(
                        dayinCurMonth,
                        (i) => DateTime.now().startOfMonth.addDay(i),
                      ).map(
                        (date) {
                          final CostMetric metric =
                              context.goalInfoMod.barChartData[date] ?? CostMetric();
                          return BarChartGroupData(
                            x: date.day,
                            barRods: [
                              BarChartRodData(toY: metric.expense!, color: context.cs.secondary),
                            ],
                          );
                        },
                      ),
                      // BarChartGroupData(x: x)
                      // LineChartBarData(
                      //   spots: [
                      //     FlSpot(0, spendPerday),
                      //     FlSpot(dayinCurMonth.toDouble(), spendPerday),
                      //   ],
                      // ),
                      // LineChartBarData(
                      //   spots: [
                      //     ...context.goalInfoMod.barChartData.entries.map(
                      //       (el) => FlSpot(el.key.day.toDouble(), el.value.expense!),
                      //     ),
                      //     // FlSpot(0, goal.target!),
                      //     // FlSpot(30, goal.target!),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 20),
                child: Text(
                  "${context.goalInfoMod.targetReachingDays}/${DateTime.now().day} days which your daily target reached!",
                ),
              ),
              SizedBox(
                height: 100,
                child: LineChart(
                  LineChartData(
                    titlesData: FlTitlesData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          FlSpot(0, goal.target!),
                          FlSpot(dayinCurMonth.toDouble(), goal.target!),
                        ],
                      ),
                      LineChartBarData(
                        spots: [
                          ...context.goalInfoMod.lineChartData.entries.map(
                            (el) => FlSpot(el.key.day.toDouble(), el.value.expense!),
                          ),
                          // FlSpot(0, goal.target!),
                          // FlSpot(30, goal.target!),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 20),
                child: Text(
                  // ignore: prefer_adjacent_string_concatenation
                  "${context.goalInfoMod.remainingValue.customCurrencyFormat("RM")} before exceeding target, which translate to " +
                      "${context.goalInfoMod.remainingValueOverDay.customCurrencyFormat("RM")} per day!",
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: HeatmapGraph(
                  target: spendPerday,
                  totalCount: dayinCurMonth,
                  getTooltipMessage: (index) {
                    final val = context.goalInfoMod.barChartData.entries.elementAtOrNull(index);
                    if (val == null) {
                      return "No data yet";
                    } else {
                      return "${val.key.formatShorter()}: ${val.value.expense!.customCurrencyFormat("RM")}";
                    }
                  },
                  data:
                      context.goalInfoMod.barChartData.entries
                          .map((el) => el.value.expense ?? 0)
                          .toList(),
                ),
              ),
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Good Job!",
                      style: context.customTt.paragraphTitle,
                    ),
                    SizedBox(height: 6,),
                    Text(
                      NumberFormat.percentPattern().format(context.goalInfoMod.targetReachingDays / DateTime.now().day),
                      style: context.customTt.numberFontLarge!.copyWith(height: 1.1),
                    ),
                    Text(
                      "or days where you reach your daily spend. (${context.goalInfoMod.targetReachingDays}/${DateTime.now().day})",
                      style: context.customTt.paragraphText,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text("History", style: context.customTt.dateLabel),
            ),
            ...goalProgress.map(
              (el) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ReusableContainer(
                  child: Text(el.date?.formatMonth() ?? "No date"),
                ),
              ),
            ),
          ]),
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
  final List<double> data;
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
        mainAxisExtent: 26,
      ),
      itemCount: widget.totalCount,
      itemBuilder: (context, index) {
        final expanded = index == _expandedIndex;
        final value = widget.data.elementAtOrNull(index);
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
          textStyle: context.tt.bodyMedium!.copyWith(fontSize: 12, color: context.cs.primary),
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
              height: expanded ? 20 : 16,
              width: expanded ? 20 : 16,
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

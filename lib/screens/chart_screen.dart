// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:budget_tracker/models/theme_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:budget_tracker/extensions.dart';
import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/screens/cost_list_screen.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  String? _selectedCategory;
  final CostType _selectedCostType = CostType.expense;

  void updateSelectedCategory(String categoryName) {
    setState(() {
      _selectedCategory = categoryName;
      // debugPrint("This works");
    });
  } 

  FlTitlesData chartTitleData() {
    return FlTitlesData(
      rightTitles: AxisTitles(drawBelowEverything: false), 
      topTitles: AxisTitles(drawBelowEverything: false),
      leftTitles: AxisTitles(
        axisNameWidget: Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Text(
            "Amount (${context.select((AppModel state) => state.currencySymbol)})", 
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        // axisNameSize: 40,
        sideTitles: SideTitles(
          getTitlesWidget: (value, meta) => Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              value.toStringAsFixed(value % 1 == 0? 0 : 1),
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 10),
            ),
          ),
          reservedSize: 40,
          showTitles: true,
          maxIncluded: true,
          // interval: 50
        )
      ),
      bottomTitles: AxisTitles(
        axisNameSize: 16,
        axisNameWidget: Padding(
          padding: const EdgeInsets.only(left: 60.0),
          child: Text("Day", style: Theme.of(context).textTheme.labelSmall,),
        ),
        sideTitles: SideTitles(
          getTitlesWidget: (value, meta) {
            if ((value-1) % 2 != 0) return SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                value.toStringAsFixed(0),
                style: Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 10),
              ),
            );
          },
          reservedSize: 30,
          showTitles: true,
          maxIncluded: true,
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Visualize", style: Theme.of(context).textTheme.headlineLarge,),
      ),
      body: SafeArea(
        child: Column(
          spacing: 20,
          children: [
            const DateBreadcrumb(),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: SegmentedButton(
            //     segments: CostType.values.map((costType) {
            //       return ButtonSegment(
            //         value: costType,
            //         icon: Icon(Icons.money),
            //         label: Text(costType.name)
            //       );
            //     }).toList(), 
            //     selected: {_selectedCostType},
            //     onSelectionChanged: (newSelection) {
            //       setState(() {
            //         _selectedCostType = newSelection.first;
            //       });
            //     },
            //   ),
            // ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 20,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      // child: const BudgetWidget(),
                      child: const CustomChartSection(
                        title: "Budget breakdown", 
                        sectionHeight: 270,
                        pageChildren: [
                          BudgetWidget()
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CustomChartSection(
                        title: "Expense breakdown",
                        sectionHeight: 240,
                        pageChildren: [
                          BreakdownPieChart(selectedCostType: _selectedCostType,),
                          DateBreakdownChart(selectedCostType: _selectedCostType,),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CustomChartSection(
                        title: "Spending Trend",
                        sectionHeight: 300,
                        pageChildren: [
                          DailyTotalBarChart(titleData: chartTitleData()),
                          DailyCumulativeSpendLineChart(titleData: chartTitleData()),
                          DateTrendLineChart(titleData: chartTitleData()),
                        ],
                      ),
                    ),
                    // Divider(),
                    CategoryList(selectedCostType: _selectedCostType,),
                  ]
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DailyTotalBarChart extends StatelessWidget {
  const DailyTotalBarChart({
    super.key,
    required this.titleData,
  });

  final FlTitlesData titleData; 
  
  @override
  Widget build(BuildContext context) {
    final data = context.select((AppModel state) => state.getDailyMetric(CostType.expense));
    final maxValue = (data.values.map<double>((metric) => metric.expense!)).toList().maxCeiling();
    // debugPrint('max value: ${maxValue}');
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChartTitleBar(
          description: "Daily Spend",
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16,16,16,0),
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(),
                titlesData: titleData,
                maxY: maxValue,
                barGroups: data.map((dayInt, metric) =>
                  MapEntry(
                    dayInt, 
                    BarChartGroupData(
                      x: dayInt,
                      barRods: [
                        BarChartRodData(
                          toY: metric.expense?? 0,
                          // rodStackItems: [
                          //   BarChartRodStackItem(fromY, toY, color)
                          // ]
                        )
                      ]
                    )
                  )
                ).values.toList()
              )
            ),
          ),
        ),
      ],
    );
  }
}

class BudgetWidget extends StatelessWidget {
  const BudgetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final contextRead = context.read<AppModel>();
    final contextWatch = context.watch<AppModel>();
    return Column(
      children: (contextRead.budgetMetrics[contextWatch.formatedSelectedYearMonth] ?? []).map((e) {
        final double curAmount = e['amount'] ?? 0;
        final double budgetAmount = e['budget'] ?? 0;

        final String curAmountString = contextRead.customCurrencyFormat(curAmount, true); 
        final String budgetAmountString = contextRead.customCurrencyFormat(budgetAmount, true); 

        final double spendPercentage = curAmount/budgetAmount;
        final String budgetMessage = spendPercentage > 1 ? "${((spendPercentage - 1) * 100).round()}% over" : "${(spendPercentage * 100).round()}%" ;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 12,),
            Text(
              '${e['name']}', 
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 20),
            ),
            Text('$budgetMessage ($curAmountString/$budgetAmountString)', textAlign: TextAlign.left,),
            Padding(
              padding: const EdgeInsets.only(left: 2.0,right: 2.0, bottom: 2, top: 8),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  // border: BoxBorder.all(color: Colors.white)
                ),
                child: Row(
                  spacing: 30,
                  children: [
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          borderData: FlBorderData(show: false),
                          maxY: max(curAmount,budgetAmount) + 1,
                          gridData: FlGridData(
                            horizontalInterval: budgetAmount,
                            getDrawingHorizontalLine: (value) {
                              if (value == budgetAmount.roundToDouble()) return FlLine(color: Colors.white, strokeWidth: 1);
                              // if (value == curAmount.roundToDouble()) return FlLine(color: Colors.white, strokeWidth: 1);
                              return FlLine(strokeWidth: 0);
                            },
                            // show: false
                          ),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(drawBelowEverything: false),
                            topTitles: AxisTitles(drawBelowEverything: false),
                            leftTitles: AxisTitles(drawBelowEverything: false),
                            rightTitles: AxisTitles(sideTitles: SideTitles(
                              interval: budgetAmount,
                              reservedSize: 30,
                              showTitles: true, 
                              getTitlesWidget: (value, meta) {
                                // if (value == curAmount.roundToDouble()) {
                                //   return SideTitleWidget(
                                //     meta: meta,
                                //      fitInside: SideTitleFitInsideData(
                                //       enabled: budgetAmount < curAmount, 
                                //       axisPosition: 0, 
                                //       parentAxisSize: budgetAmount < curAmount ? 100 : 0, 
                                //       distanceFromEdge: 0
                                //     ),
                                //     child: Text('Current'), 
                                //   );
                                // }
                                if (value == budgetAmount.roundToDouble()) {
                                  return SideTitleWidget(
                                    meta: meta,
                                    fitInside: SideTitleFitInsideData(
                                      enabled: budgetAmount > curAmount, 
                                      axisPosition: 0, 
                                      parentAxisSize: budgetAmount > curAmount ? 50 : 0, 
                                      distanceFromEdge: 0
                                    ),
                                    child: Text('Limit'), 
                                  );
                                }
                                return SizedBox.shrink();
                              },
                            ),
                          ),
                          ),
                          barGroups: [
                            BarChartGroupData(
                              x: 1,
                              barsSpace: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: curAmount,
                                  color: curAmount > budgetAmount ? Colors.red : context.read<ThemeModel>().color,
                                  width: 12,
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    color: Colors.grey.withAlpha(100),
                                    fromY: 0,
                                    toY: budgetAmount
                                  )
                                ),
                                // BarChartRodData(toY: 40),
                              ]
                            )
                          ],
                          rotationQuarterTurns: 1
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList()
    );
  }
}

class OverviewBudgetBar extends StatelessWidget {
  const OverviewBudgetBar({super.key});
  
  @override
  Widget build(BuildContext context) {
    final expense = context.select((AppModel state) => state.totalCurrentMonthExpense);
    final budget = context.select((AppModel state) => state.totalBudget);
    final percentage = context.select((AppModel state) => state.budgetPercentage);
    final currencySymbol = context.select((AppModel state) => state.currencySymbol);
    final remainingAverageSpend = context.select((AppModel state) => state.remainingDayAverageSpend);
    // final percentage = expense/budget;

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   tooltipKey.currentState!.ensureTooltipVisible();
    // });
    return LayoutBuilder(
      builder: (context, constraints) {
        const double thresholdPosition = 0.75;
        return Column(
          children: [
            Text("You have spent:"),
            Text(
              NumberFormat("#0%").format(percentage),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 32.0, bottom: 4),
                  child: PercentageBar(
                    height: 12, 
                    color: Colors.red, 
                    percentage: percentage * thresholdPosition
                  ),
                ),
                Positioned(
                  left: constraints.maxWidth * thresholdPosition - (17 * 2) 
                    - (100* (percentage > (4/3)? percentage/(4/3) : 0)),
                  // widthFactor: 0.7,
                  child: Column(
                    spacing: 8,
                    children: [
                      Text("Threshold", textAlign: TextAlign.center,),
                      SizedBox(
                        height: 20,
                        child: VerticalDivider(thickness: 2,)
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              ' spend below ${remainingAverageSpend.customCurrencyFormat(currencySymbol)} daily to reach your target',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: () {

              }, 
              child: Text('or change your budget ? (but should you?)')
            )
          ],
        );
      }
    );
  }
}

class CustomChartSection extends StatefulWidget {
  const CustomChartSection({
    super.key,
    required this.title,
    required this.pageChildren,
    required this.sectionHeight
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
    if (details.primaryVelocity! > 200 && _currentDateTrendPageIndex > 0) { // scroll left, back
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
      curve: Curves.easeInOutExpo
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
                  child: ChartTitleBar(title: widget.title,),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: PageIndicator(
                    pageLength: widget.pageChildren.length, 
                    currentPage: _currentDateTrendPageIndex
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
              )
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class BreakdownPieChart extends StatelessWidget {
  const BreakdownPieChart({
    super.key,
    required this.selectedCostType
  });

  final CostType selectedCostType;
  
  @override
  Widget build(BuildContext context) {
    final selectedThemeMode = context.select((ThemeModel state) => state.theme);
    final summarizedCategoryData = context.select((AppModel state) {
      final categoryData = state.getcurrentMonthCategoryView(true, CostType.expense);
      final Map<String,CostMetric> summarizedData = {};
      int i = 0;
      double totalOtherExpense = 0;
      if (categoryData.length < 5) {
        return categoryData;
      } else {
        for(i; i < categoryData.length; i ++) {
          if (i < 4) {
            summarizedData[categoryData.entries.toList()[i].key] = categoryData.entries.toList()[i].value;  
          } else {
            totalOtherExpense += categoryData.entries.toList()[i].value.expense!;
          }
        }
        summarizedData['other'] = CostMetric(expense: totalOtherExpense);  
        return summarizedData;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChartTitleBar(
          description: "by Category",
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
                              final categoryTitle = response!.touchedSection!.touchedSection!.title;
                              // updateCategory(categoryTitle);
                            }
                          }
                        },
                      ),
                      sections: summarizedCategoryData.entries.map((data) {
                        final currentCategory = context.read<AppModel>().getCategoryEntry(data.key);
                        Color primaryColor;
                        Color secColor;
                        if (currentCategory != null) {
                          primaryColor = currentCategory.colorScheme(selectedThemeMode).primary;
                          secColor = currentCategory.colorScheme(selectedThemeMode).primaryContainer;
                          // categoryColorScheme = currentCategory.colorScheme;
                        } else {
                          primaryColor = Colors.amber;
                          secColor = Colors.amber.shade700;
                        }
                        return PieChartSectionData(
                          value: data.value.expense!.abs(),
                          radius: 20,
                          // title: category,
                          // badgeWidget: currentCategory.generateRoundedIcon(30, categoryColorScheme.primary, categoryColorScheme.onPrimary),
                          // badgePositionPercentageOffset: 1,
                          showTitle: false,
                          gradient: LinearGradient(
                            stops: [0,1],
                            colors: [
                              primaryColor.withAlpha(200),
                              secColor,
                            ]
                          ),
                          // color: categoryColorScheme.primary.withAlpha(200)
                        );
                      }
                      ).toList(),
                    )
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: summarizedCategoryData.entries.map((data) {
                      final category = context.read<AppModel>().getCategoryEntry(data.key);
                      final totalAmount = context.read<AppModel>().totalCurrentMonthExpense;
                      // final category = data['category'] as CostItemCategory?;
                      Color primaryColor;
                      if (category != null) {
                        primaryColor = category.colorScheme(selectedThemeMode).primary;
                      } else {
                        primaryColor = Colors.amber;
                      }
                      return SizedBox(
                        height: 28,
                        child: ChartLegendItem(
                          primaryColor: primaryColor,
                          title: data.key,
                          trailing: Text(
                            // NumberFormat('#0%').format(data['percentage']),
                            context.read<AppModel>().getCategoryPercentage(data.value.expense!),
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 13, 
                              // color: Theme.of(context).colorScheme.primary
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
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
          )
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: fontSize),
        ),
        visualDensity: VisualDensity(vertical: -4),
        dense: true,
        contentPadding: EdgeInsets.only(right: 16),
        trailing: trailing
      ),
    );
  }
}

class DateBreakdownChart extends StatelessWidget {
  const DateBreakdownChart({
    super.key,
    required this.selectedCostType
  });

  final CostType selectedCostType;
  
  @override
  Widget build(BuildContext context) {
    final dateData = context.select((AppModel state) => 
      state.summarizedDateGroupDataForCustomCostType(selectedCostType)
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
                      sections: dateData.map((data) {
                        return  PieChartSectionData(
                          value: data['amount'],
                          radius: 20,
                          showTitle: false,
                        );
                      }
                      ).toList(),
                    )
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: dateData.map((data) {
                      return SizedBox(
                        height: 28,
                        child: ListTile(
                          leading: Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.amber,
                            )
                          ),
                          title: Text(
                            data['date'] as String,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 13),
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
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ChartTitleBar extends StatelessWidget {
  const ChartTitleBar({
    super.key,
    this.title,
    this.description
  });

  final String? title;
  final String? description;
  @override
  Widget build(BuildContext context) {
    final appTextTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) Text(title!, style: appTextTheme.labelLarge!.copyWith(
          fontSize: 20, 
          color: Theme.of(context).colorScheme.primary),
        ),
        if (description !=null) Text(description!, style: appTextTheme.bodyMedium!.copyWith(
          fontSize: 14
        )),
      ]
    );
  }
}
class DateTrendLineChart extends StatelessWidget {
  const DateTrendLineChart({
    super.key,
    required this.titleData,
  });

  final FlTitlesData titleData;

  @override
  Widget build(BuildContext context) {
    final currentMonthData = context.select((AppModel state) => state.currentCumulativeAverage);
    final previousMonthData = context.select((AppModel state) => state.previousCumulativeAverage);
    
    final colorTheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        const ChartTitleBar(
          description: "Cumulative average spend",
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16,16,16,0),
            child: SpendTrendLineChart(
              currentMonthData: currentMonthData, 
              previousMonthData: previousMonthData,
              titleData: titleData,
            ),
          ),
        ),
        // Align(
        //   alignment: Alignment.center,
        //   child: Row(
        //     spacing: 12,
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       ChartLegendItem(
        //         primaryColor: colorTheme.primary, 
        //         title: "This month",
        //         tileWidth: 200,
        //       ),
        //       ChartLegendItem(
        //         primaryColor: colorTheme.tertiary, 
        //         title: "Previous month",
        //         tileWidth: 200,
        //       ),
        //     ],
        //   ),
        // )
      ],
    );
  }
}

class DailyCumulativeSpendLineChart extends StatelessWidget {
  const DailyCumulativeSpendLineChart({
    super.key,
    required this.titleData,
  });

  final FlTitlesData titleData;

  @override
  Widget build(BuildContext context) {
    final currentMonthData = context.select((AppModel state) => state.currentCumulative);
    final previousMonthData = context.select((AppModel state) => state.previousCumulative);
    
    final colorTheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        const ChartTitleBar(
          description: "Cumulative spend",
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16,16,16,0),
            child: SpendTrendLineChart(
              currentMonthData: currentMonthData, 
              previousMonthData: previousMonthData,
              titleData: titleData,
            ),
          ),
        ),
        // Align(
        //   alignment: Alignment.center,
        //   child: Container(
        //     // decoration: ,
        //     child: Row(
        //       spacing: 12,
        //       mainAxisSize: MainAxisSize.min,
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         ChartLegendItem(
        //           primaryColor: colorTheme.primary, 
        //           title: "This month",
        //           tileWidth: 160,
        //           fontSize: 10,
        //         ),
        //         ChartLegendItem(
        //           primaryColor: colorTheme.tertiary, 
        //           title: "Previous month",
        //           tileWidth: 160,
        //           fontSize: 10,
        //         ),
        //       ],
        //     ),
        //   ),
        // )
      ],
    );
  }
}

class SpendTrendLineChart extends StatelessWidget {
  const SpendTrendLineChart({
    super.key,
    required this.currentMonthData,
    required this.previousMonthData,
    required this.titleData,
  });

  final Map<int,double> currentMonthData;
  final Map<int,double> previousMonthData;
  // final List<double> previousMonthData;
  final FlTitlesData titleData;

  @override
  Widget build(BuildContext context) {
    final yearMonth = context.select((AppModel state) => state.selectedYearMonth); 
    return LineChart(
      LineChartData(
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            // fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor:(touchedSpot) => Colors.transparent,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot){
                final modelRead = context.read<AppModel>();
                final index = spot.spotIndex + 1;
                final lineIndex = spot.barIndex;
                String tooltipText = "";
                if (lineIndex == 0) {
                  tooltipText = "Current: ${modelRead.customCurrencyFormat(currentMonthData[index]!, true)}";
                } else {
                  tooltipText = "Previous: ${modelRead.customCurrencyFormat(previousMonthData[index]!, true) }";
                }
                return LineTooltipItem(
                  tooltipText, 
                  Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 10, color: spot.bar.color),
                );
              }).toList();  
            },
          )
        ),
        maxY: [...currentMonthData.values, ...previousMonthData.values].maxCeiling(),
        minY: 0,
        minX: 1,
        gridData: FlGridData(show: true),
        titlesData: titleData,
        lineBarsData: [
          spendTrendLineData(context, true, yearMonth), // current month data
          spendTrendLineData(context, false, yearMonth), // previous month data
        ]
      )
    );
  }

  LineChartBarData spendTrendLineData(BuildContext context, bool currentMonth, DateTime yearMonth) {
    final displayData = currentMonth ? currentMonthData : previousMonthData;
    final colorTheme = Theme.of(context).colorScheme;
    return LineChartBarData( // current month data
      isCurved: true,
      barWidth: currentMonth ? 3 : 1,
      color: currentMonth ? colorTheme.primary : colorTheme.tertiary,
      preventCurveOvershootingThreshold: 0,
      dashArray: currentMonth ? null : [10,5],
      curveSmoothness: 0.5,
      isStrokeCapRound: true,
      preventCurveOverShooting: true,
      dotData: FlDotData(
        show: currentMonth ? true : false,
        checkToShowDot: (spot, barData) {
          // if the month is completed, do not show dot
          if (!yearMonth.isInSameYearMonthAs(DateTime.now())) return false;
          // only show dot for the latest date
          if (spot.x == displayData.length) return true;
          
          return false;
        },
      ),
      spots: displayData.map((int dayInt, double amount){
        return MapEntry(dayInt, FlSpot(dayInt.toDouble(), amount));
      }).values.toList(),
    );
  }

}

class CategoryList extends StatefulWidget {
  const CategoryList({
    super.key,
    required this.selectedCostType
  });

  final CostType selectedCostType;

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  bool _isSortDescending = true;

  List<Widget> categoryListTile(Map<String,CostMetric> data, BuildContext context) => data.entries.map((categoryData) {
    final selectedThemeMode = context.select((ThemeModel state) => state.theme);
    final categoryName = categoryData.key;
    final CostItemCategory categoryEntry = context.read<AppModel>().getCategoryEntry(categoryName)!;
    final double categoryAmount = categoryData.value.expense!;
    final ColorScheme categoryColorScheme = categoryEntry.colorScheme(selectedThemeMode);
    // final amountString = categoryAmount.toStringAsFixed(categoryAmount % 1 == 0? 0 : 2);    
    final amountString = context.read<AppModel>().customCurrencyFormat(categoryAmount, false);    
    final currencySymbol = context.select((AppModel state) => state.currencySymbol);
    final maxAmount = context.select((AppModel state) => state.getMaxCurrentMonthCategoryAmount(CostType.expense));
    final percentageString = context.read<AppModel>().getCategoryPercentage(categoryAmount);
    final List<CostItem> costItems = context.select((AppModel state) => state.currentMonthCategoryList[categoryName]?? []);
    
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: ValueKey(categoryName),
        tilePadding: EdgeInsets.fromLTRB(24,4,30,4),
        childrenPadding: EdgeInsets.fromLTRB(24,0,30,8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(categoryName),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$amountString ',
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontSize: 12
                    )
                  ),
                  TextSpan(
                    text: '($percentageString)',
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontSize: 12,
                      color: categoryColorScheme.primary
                    )
                  ),
                ]
              ) 
            )
          ],
        ),
        leading: categoryEntry.generateRoundedIcon(56, selectedThemeMode),
        subtitle: PercentageBar(
          height: 8, 
          color: categoryColorScheme.primaryFixed, 
          percentage: categoryAmount/maxAmount
        ), 
        children: costItems.map((CostItem costItem) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            visualDensity: VisualDensity(vertical: -3),
            dense: true,
            leading: Container(
              width: MediaQuery.of(context).size.width* 0.1,  
              child: Text((costItem.dateTime).displayFormat())
            ),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.end,
              spacing: 20,
              children: [
                Text(costItem.name),
                Expanded(child: Divider(color: Colors.white.withAlpha(80),))
              ],
            ),
            trailing: Container(
              width: MediaQuery.of(context).size.width* 0.12,  
              child: Text(
                costItem.getCurrencyValue(currencySymbol, false),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontSize: 12
                )
              ),
            ),
          );
        }).toList(),
      ),
    );
  }).toList();

  @override
  Widget build(BuildContext context) {
    final Map<String,CostMetric> categoryData = context.select((AppModel state) => 
      state.getcurrentMonthCategoryView(_isSortDescending, CostType.expense)
    );
 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: ChartTitleBar(
                  title: "Expense overview",
                  description: "by Category",
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _isSortDescending = !_isSortDescending), 
                icon: Transform.scale(
                  scaleY: _isSortDescending? 1 : -1,
                  child: Icon(Icons.sort)
                )
              )
            ],
          ),
        ),
        ...categoryListTile(categoryData, context)
      ],
    );
  }
}

class FastCustomScrollPhysics extends ScrollPhysics {
  const FastCustomScrollPhysics({super.parent});

  @override
  FastCustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FastCustomScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(
    mass: 5,
    stiffness: 100,
    damping: 50,
  );
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
                borderRadius: BorderRadius.circular(12)
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
                  ]
                ),
                borderRadius: BorderRadius.circular(12)
              ),
            )
          ],
        );
      }
    );
  }
}


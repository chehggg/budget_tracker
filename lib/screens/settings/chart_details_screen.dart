import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/ui/chart/chart_screen.dart';
import 'package:budget_tracker/screens/settings/recurring_settings_screen.dart';
import 'package:budget_tracker/ui/settings/settings_screen.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChartBudgetDetailsScreen extends StatefulWidget {
  const ChartBudgetDetailsScreen({
    super.key,
    required this.curBudgetId
  });

  final String curBudgetId;

  @override
  State<ChartBudgetDetailsScreen> createState() => _ChartBudgetDetailsScreenState();
}

class _ChartBudgetDetailsScreenState extends State<ChartBudgetDetailsScreen> {
  String _selectedGroup = "None";
  @override
  Widget build(BuildContext context) {
    debugPrint("details built");
    final contextRead = context.read<AppModel>();
    final contextWatch = context.watch<AppModel>();
    // final contextRead = context.read<AppModel>();
    final Budget budget = contextRead.budgets.firstWhere((budget) => budget.id == widget.curBudgetId);

    // final selectedCostItems = List.cm contextRead.currentMonthDailyCostItems.values
    // final categoryMetrics = contextWatch.currentMonthCategoryList..removeWhere((key, value) => budget.categories!.isEmpty? false : !budget.categories!.contains(key));
    // final categoryMetrics = contextWatch.currentMonthCategoryList;    
    // final categoryMetrics = contextWatch.currentMonthCategoryList;
    final dailyMetrics = contextWatch.currentMonthDailyCostItems;
    
    List<CostItem> result = [];

    dailyMetrics.forEach((date, costItems) {
      for (CostItem item in costItems) {
        if (budget.categories!.contains(item.category)){
          result.add(item);
        }
      }
    });
    final categoryGroup = groupBy(result, (item) => item.category);
    final dateGroup = groupBy(result, (item) => item.date);
    // }
    // if (_selectedGroup == "None") {
    final String categoryDescription = budget.categories!.isEmpty ? "All" : budget.categories!.join(", ");
    
    final curBudgetMetrics = contextRead.budgetMetrics[contextRead.formatedSelectedYearMonth]!.firstWhere((e) => e['id'] == widget.curBudgetId);
    final double curAmount = curBudgetMetrics['amount'] ?? 0;
    final double budgetAmount = curBudgetMetrics['budget'] ?? 1;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(budget.name ?? "", style: Theme.of(context).textTheme.headlineSmall,),
                Text(widget.curBudgetId),
                Text("Categories", style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 18)),
                Text(categoryDescription),
                Container(
                  height: 50,
                  child: BudgetBarChart(current:  curAmount, budget:  budgetAmount,)
                ),
                Text("Expense under budget"),
                CustomDropDownMenu(
                  initialSelection: _selectedGroup,
                  dropdownMenuEntries: ["None", "Date","Category"],
                  onSelected: (value) {
                    setState(() => _selectedGroup = value);
                  },
                ),
                // Text("Categories count : ${categoryMetrics.entries.length}"),
                if (_selectedGroup == "None") ...result.map((costItem) {
                  return CustomSettingsTile(
                    horizontalPadding: 0,
                      title: costItem.name,
                      trailingWidget: Text(costItem.amount.toString()),
                      // subtitle: Column(
                      //   // children: value.map((costItem) => Text(costItem.name)).toList()
                      // ),
                    // )
                  );
                }),
                if (_selectedGroup == "Date") ...dateGroup.map((date, costItems) {
                  return MapEntry(date,
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        showTrailingIcon: false,
                        tilePadding: EdgeInsets.all(0),
                        initiallyExpanded: true,
                        title: Text(date.formatFull(), style: Theme.of(context).textTheme.titleMedium),
                        children: costItems.map((item) {
                          return ListTile(
                            contentPadding: EdgeInsets.all(0),
                            dense: true,
                            title: Text(item.name),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }).values,
                if (_selectedGroup == "Category") ...categoryGroup.map((category, costItems) {
                  return MapEntry(category,
                    ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(category),
                      children: costItems.map((item) {
                        return ListTile(
                          leading: Text(item.date.formatFull()),
                          title: Text(item.name),
                        );
                      }).toList(),
                    ),
                  );
                }).values
              ],
            ),
          )
        )
      ),
    );
  }
}
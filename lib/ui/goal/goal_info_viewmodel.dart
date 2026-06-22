import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/classes/goal_class.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/goal_repository.dart';
import 'package:flutter/material.dart';

class GoalInfoViewmodel extends ChangeNotifier {
  GoalInfoViewmodel({
    required CostItemRepository costItemRepo,
    required GoalRepository goalRepository,
    required Goal goal,
  }) : _costItemRepo = costItemRepo,
       _goalRepository = goalRepository,
       _goal = goal {
    init();
  }

  final CostItemRepository _costItemRepo;
  final GoalRepository _goalRepository;

  final int dayinCurMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
  // final double dailyTarget = _goal;

  final Goal _goal;
  Goal get goal => _goal;
  List<GoalProgress> get goalProgress => _goal.getGoalProgress(_costItemRepo.costItems);
  GoalProgress get currentGoal => goalProgress.last;

  Map<DateTime, CostMetric> get barChartData => Map.fromEntries(
    List.generate(
          DateTime.now().day,
          (i) => DateTime.now().startOfMonth.addDay(i),
        )
        .map(
          (el) => MapEntry(
            el,
            CostMetric.fromCostItemList(
              goalProgress.last.items?.where((item) => item.date.isAtSameMomentAs(el)).toList() ??
                  [],
            ),
          ),
        )
        .toList(),
  );

  int get targetReachingDays =>
      barChartData.entries
          .where((entry) => (entry.value.expense!) < (_goal.target! / dayinCurMonth))
          .length;

  double get remainingValue => currentGoal.target! - currentGoal.value;
  double get remainingValueOverDay {
    final remainingDays = dayinCurMonth - DateTime.now().day;
    return remainingValue / remainingDays;
  }

  Map<DateTime, CostMetric> get lineChartData {
    double income = 0;
    double expense = 0;
    List<MapEntry<DateTime, CostMetric>> mapEntries = [];
    for (int i = 0; i < barChartData.length; i++) {
      final entry = barChartData.entries.elementAt(i);
      expense += entry.value.expense!;
      income += entry.value.income!;
      mapEntries.add(MapEntry(entry.key, CostMetric(expense: expense, income: income)));
    }
    return Map.fromEntries(mapEntries);
    // return Map.fromEntries(
    //   List.generate(
    //     barChartData.length,
    //     (i) => barChartData.entries.elementAt(i),
    //   ).map(
    //     (el) {
    //       metric.combine(el.value);
    //       return MapEntry(el.key, metric);
    //     },
    //   ).toList(),
    // );
  }

  Future<void> init() async {
    await _costItemRepo.ready;
    await _goalRepository.ready;
  }

  Future<void> deleteGoal() async {
    await _goalRepository.deleteGoal(_goal);
  }
}

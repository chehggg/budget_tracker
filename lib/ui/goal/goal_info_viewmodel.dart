import 'dart:async';

import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/classes/goal_class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:budget_tracker/data/repos/goal_repository.dart';
import 'package:budget_tracker/data/repos/shared_element_repository.dart';
import 'package:flutter/material.dart';

class GoalInfoViewModel extends ChangeNotifier {
  GoalInfoViewModel({
    required CostItemRepository costItemRepo,
    required GoalRepository goalRepos,
    required CategoryRepository categoryRepo,
    required CurrencyRepository currencyRepo,
    required SharedElementRepository sharedElementRepo,
    required Goal goal,
  }) : _costItemRepo = costItemRepo,
       _goalRepo = goalRepos,
       _categoryRepo = categoryRepo,
       _currencyRepo = currencyRepo,
       _sharedElementRepo = sharedElementRepo,
       _goal = goal {
    init();
  }

  final CostItemRepository _costItemRepo;
  final GoalRepository _goalRepo;
  final CategoryRepository _categoryRepo;
  final CurrencyRepository _currencyRepo;
  final SharedElementRepository _sharedElementRepo;

  Future<void> init() async {
    await _costItemRepo.ready;
    await _goalRepo.ready;
    await _categoryRepo.ready;
    await _sharedElementRepo.ready;

    _pastProgress = _goal.getPastGoalProgress(_costItemRepo.costItems);
    _currentGoalProgress =
        _goal.getGoalProgress(
          _costItemRepo.costItems,
          _goal.isEnded ? goal.endDate! : DateTime.now(),
        )!;
    _isInit = true;

    _subscription = _goalRepo.streamValue.listen((_) {
      notifyListeners();
    });
    _sharedElementSubscription = _sharedElementRepo.sharedStream.listen((_) {
      notifyListeners();
    });

    notifyListeners();
  }

  StreamSubscription<bool>? _subscription;
  StreamSubscription<bool>? _sharedElementSubscription;

  final int dayinCurrentMonth = DateTime.now().dayinCurrentMonth;

  bool get showHistory => _pastProgress.isNotEmpty;

  final Goal _goal;
  Goal get goal => _goal;

  bool _isInit = false;
  bool get ready => _isInit;

  List<GoalProgress> _pastProgress = [];
  List<GoalProgress> get pastProgress => _pastProgress;

  int get streak {
    final index = _pastProgress.lastIndexWhere((progress) => !progress.achieved);
    if (index == -1) return _pastProgress.length;
    return _pastProgress.length - (index + 1);
  }

  late GoalProgress _currentGoalProgress;
  GoalProgress get currentGoalProgress => _currentGoalProgress;

  int get currentDay => DateTime.now().day;
  double get targetSpendPerDay => (_goal.target ?? 0) / dayinCurrentMonth;
  double get currentSpendPerDay => (currentGoalProgress.value) / currentDay;
  double get spendPerDayTargetDifference =>
      (currentSpendPerDay - targetSpendPerDay) / (currentSpendPerDay);

  DateTime get chartStartDate {
    if (_goal.goalTracking == GoalTrackingPeriod.monthly) {
      return DateTime.now().startOfMonth;
    } else {
      // if
      if (DateTime.now().standard.addDay(-48).isAfter(_goal.startDate!)) {
        return DateTime.now().standard.addDay(-48);
      } else {
        return _goal.startDate!;
      }
    }
  }

  int get dataCount =>
      _goal.goalTracking == GoalTrackingPeriod.monthly ? DateTime.now().dayinCurrentMonth : 49;

  String get displayDayTitle =>
      goal.goalTracking == GoalTrackingPeriod.monthly
          ? chartStartDate.formatMonthLonger()
          : "Last 7 weeks";

  Map<DateTime, CostMetric?> get dailyData => Map.fromEntries(
    List.generate(
      dataCount,
      (i) => chartStartDate.addDay(i),
    ).map(
      (date) {
        final CostMetric? metric;
        final items =
            currentGoalProgress.items?.where((item) => item.date!.isAtSameMomentAs(date)) ?? [];
        if (date.isAfter(DateTime.now().standard) && items.isEmpty) {
          metric = null;
        } else {
          metric = CostMetric.fromCostItemList(items.toList());
        }
        return MapEntry(date, metric);
      },
    ).toList(),
  );
  Map<int, double> get indexedDailyData {
    final indexedMap = dailyData.entries.indexed;
    final filteredItem = indexedMap.where((listItem) => listItem.$2.value != null);
    return Map.fromEntries(
      filteredItem.map((listItem) => MapEntry(listItem.$1, listItem.$2.value!.expense ?? 0)),
    );
  }

  int get targetReachingDays =>
      dailyData.entries
          .where(
            (entry) =>
                (entry.value != null) &&
                ((entry.value?.expense ?? 0) < (_goal.target! / dayinCurrentMonth)),
          )
          .length;
  double get targetReachingPercentage => targetReachingDays / currentDay;

  double get remainingValue => currentGoalProgress.target! - currentGoalProgress.value;
  int get remainingDays => dayinCurrentMonth - DateTime.now().day;
  double get remainingValueOverDay {
    return remainingValue / remainingDays;
  }

  Map<DateTime, CostMetric?> get lineChartData {
    CostMetric metric = CostMetric();
    List<MapEntry<DateTime, CostMetric?>> mapEntries = [];
    for (int i = 0; i < dailyData.length; i++) {
      final entry = dailyData.entries.elementAt(i);
      metric = metric.combineWith(entry.value ?? CostMetric());
      mapEntries.add(
        MapEntry(
          entry.key,
          entry.value == null ? null : metric,
        ),
      );
    }
    return Map.fromEntries(mapEntries);
  }

  Map<String, String> get goalInfo => {
    "Goal Name": _goal.title ?? "",
    "Description": _goal.description ?? "",
    "Goal Tracking": "${_goal.goalType!.name.capitalize()}, ${_goal.goalTracking!.name}",
    "Period":
        "${_goal.startDate!.formatMonthLonger()} - ${_goal.endDate?.formatMonthLonger() ?? "cont."}",
    "Target": _goal.target!.formatRoundedString(),
    "Categories": _goal.categories?.length.toString() ?? "All",
    "Filter":
        _goal.filter == null ? 'NA' : '${_goal.filter?.matchType.name} ${_goal.filter?.query}',
    "Created": _goal.lastCreated!.formatShort(),
    "Last Modified": _goal.lastModified?.formatShort() ?? "",
  };

  Future<void> deleteGoal() async {
    await _goalRepo.deleteGoal(_goal);
  }

  AccentColor get accentColors => _sharedElementRepo.accentColors;

  String Function(
    double value, {
    bool abbreviated,
    bool alwaysShowSign,
    bool compact,
    int? decimalDigits,
    bool showSymbol,
  })
  get currencyFormat => _currencyRepo.formatCurrency;

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
    _sharedElementSubscription?.cancel();
  }
}

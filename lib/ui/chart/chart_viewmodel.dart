import 'dart:math';

import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class ChartModel extends ChangeNotifier {
  ChartModel({required CostItemRepository costItemRepo, required CategoryRepository categoryRepo})
    : _costItemRepo = costItemRepo,
      _categoryRepo = categoryRepo {
    init();
  }
  final CostItemRepository _costItemRepo;
  final CategoryRepository _categoryRepo;

  void init() async {
    await _costItemRepo.ready;
    await _categoryRepo.ready;

    _isInitalized = true;

    notifyListeners();
  }

  bool _isInitalized = false;
  bool get ready => _isInitalized;

  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now().startOfMonth,
    end: DateTime.now().standardNow,
  );
  DateTime get rangeStart => _selectedDateRange.start;
  DateTime get rangeEnd => _selectedDateRange.end;

  Map<DateTime, CostMetric> get curMonthdailyOverviewTrend {
    final result = List.generate(
      _selectedDateRange.duration.inDays + 1,
      (i) => rangeStart.add(Duration(days: i)),
    ).map((date) {
      final metrics = _costItemRepo.daySummary[date] ?? CostMetric();
      return MapEntry(date, metrics);
    });

    return Map.fromEntries(result);
  }

  Map<DateTime, CostMetric> get prevMonthDailyOverview {
    final result = List.generate(
      _selectedDateRange.duration.inDays + 1,
      (i) {
        return DateTime(rangeStart.year, rangeStart.month - 1, rangeStart.day + i);
      },
    ).map((date) {
      final metrics = _costItemRepo.daySummary[date] ?? CostMetric();
      return MapEntry(date, metrics);
    });

    return Map.fromEntries(result);
  }

  Map<int, List<CostMetric>> get dailyOverviewComparsion {
    return curMonthdailyOverviewTrend.map(
      (date, metric) => MapEntry(date.day, [
        metric,
        prevMonthDailyOverview.entries
            .firstWhere((prevMonthEntry) => prevMonthEntry.key.day == date.day)
            .value,
      ]),
    );
  }

  double dailyRangePercentile(double percent) {
    final maxValue = curMonthdailyOverviewTrend.entries.fold<double>(
      0,
      (prev, entry) => max(prev, entry.value.expense ?? 0),
    );
    return maxValue * percent / 100;
  }

  void updateDateRange(String rangeType) {
    final now = DateTime.now();
    switch (rangeType) {
      case 'month':
        _selectedDateRange = DateTimeRange(start: now.startOfMonth, end: now.endOfMonth);
      case 'mtd':
        _selectedDateRange = DateTimeRange(start: now.startOfMonth, end: now.standardNow);
    }
    // _selectedDateRange = range;
    notifyListeners();
  }
}

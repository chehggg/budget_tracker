import 'dart:math';

import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

enum DateRangeType { thisMonth, thisYear, thisWeek, oneWeek, oneMonth, oneYear, custom }

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

  bool get showMonths =>
      [DateRangeType.thisYear, DateRangeType.oneYear].contains(_rangeType) ||
      (_rangeType == DateRangeType.custom && _curRange.duration.inDays > 35);

  DateRangeType _rangeType = DateRangeType.thisMonth;

  DateTimeRange _curRange = DateTimeRange(
    start: DateTime.now().startOfMonth,
    end: DateTime.now().standardNow,
  );
  DateTime get rangeStart => _curRange.start;
  DateTime get rangeEnd => _curRange.end;

  DateTimeRange get _prevRange {
    switch (_rangeType) {
      case DateRangeType.oneMonth:
        return DateTimeRange(
          start: rangeStart.toSOM(-1),
          end: rangeStart.toEOM(-1),
        );
      case DateRangeType.oneWeek:
        return DateTimeRange(
          start: rangeStart.toSOM(-1),
          end: rangeStart.toEOM(-1),
        );
      default:
        return _curRange;
    }
  }

  Map<DateTime, CostMetric> get curRangeOverview {
    final result = List.generate(
      _curRange.duration.inDays + 1,
      (i) => rangeStart.add(Duration(days: i)),
    ).map((date) {
      final metrics = _costItemRepo.daySummary[date] ?? CostMetric();
      return MapEntry(date, metrics);
    });

    return Map.fromEntries(result);
  }

  Map<DateTime, CostMetric> get prevRangeOverview {
    final result = List.generate(
      _prevRange.duration.inDays + 1,
      (i) {
        return DateTime(rangeStart.year, rangeStart.month - 1, rangeStart.day + i);
      },
    ).map((date) {
      final metrics = _costItemRepo.daySummary[date] ?? CostMetric();
      return MapEntry(date, metrics);
    });

    return Map.fromEntries(result);
  }

  List<Map<DateTime, double>> get overviewComparisonView {
    Map<DateTime, CostMetric> largerMap, smallerMap;

    if (curRangeOverview.length > prevRangeOverview.length) {
      largerMap = curRangeOverview;
      smallerMap = prevRangeOverview;
    } else {
      smallerMap = curRangeOverview;
      largerMap = prevRangeOverview;
    }

    return largerMap.entries.mapIndexed((index, entry) {
      Map<DateTime, double> newMap = {};
      final smallerEntry = smallerMap.entries.elementAtOrNull(index);
      newMap[entry.key] = entry.value.expense ?? 0;
      if (smallerEntry != null) {
        newMap[smallerEntry.key] = smallerEntry.value.expense ?? 0;
      }

      return newMap;
    }).toList();
  }

  Map<DateTime, double> calculateCumulative(DateTimeRange range) {
    double total = 0;
    Map<DateTime, double> result = {};
    curRangeOverview.forEach((date, metric) {
      total += metric.expense ?? 0;
      result.addEntries([MapEntry(date, total)]);
    });
    return result;
  }

  Map<DateTime, double> calculateAverageCumulative(DateTimeRange range) {
    Map<DateTime, double> result = {};
    calculateCumulative(_curRange).entries.mapIndexed((index, entry) {
      result.addEntries([MapEntry(entry.key, entry.value / index)]);
    });
    return result;
  }

  List<Map<DateTime, double>> get cumulativeComparison => [
    calculateCumulative(_curRange),
    calculateCumulative(_prevRange),
  ];

  List<Map<DateTime, double>> get avgCumulativeComparison => [
    calculateAverageCumulative(_curRange),
    calculateAverageCumulative(_prevRange),
  ];

  double dailyRangePercentile(double percent) {
    final maxValue = curRangeOverview.entries.fold<double>(
      0,
      (prev, entry) => max(prev, entry.value.expense ?? 0),
    );
    return maxValue * percent / 100;
  }

  // void getCu

  void updateDateRange(DateRangeType rangeType) {
    final now = DateTime.now();
    switch (rangeType) {
      case DateRangeType.thisMonth:
        _curRange = DateTimeRange(start: now.startOfMonth, end: now.endOfMonth);
      case DateRangeType.thisYear:
        _curRange = DateTimeRange(start: now.startOfYear, end: now.endOfYear);
      case DateRangeType.thisWeek:
        _curRange = DateTimeRange(start: now.startOfWeek, end: now.endOfWeek);
      case DateRangeType.oneWeek:
        _curRange = DateTimeRange(start: now.standardNow.addDay(-7), end: now.standardNow);
      case DateRangeType.oneMonth:
        _curRange = DateTimeRange(start: now.standardNow.addMonth(-1), end: now.standardNow);
      case DateRangeType.oneYear:
        _curRange = DateTimeRange(start: now.standardNow.addYear(-1), end: now.standardNow);
      default:
        return;
    }
    // _selectedDateRange = range;
    notifyListeners();
  }
}

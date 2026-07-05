import 'dart:async';
import 'dart:math';

import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:budget_tracker/data/repos/shared_element_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:week_number/iso.dart';

enum DateRangeType { thisMonth, thisYear, thisWeek, oneWeek, oneMonth, oneYear, custom }

class ChartViewModel extends ChangeNotifier {
  ChartViewModel({
    required CostItemRepository costItemRepo,
    required CurrencyRepository currencyRepo,
    required CategoryRepository categoryRepo,
    required SharedElementRepository sharedRepo,
  }) : _costItemRepo = costItemRepo,
       _currencyRepo = currencyRepo,
       _sharedRepo = sharedRepo,
       _categoryRepo = categoryRepo {
    init();
  }
  final CostItemRepository _costItemRepo;
  final CategoryRepository _categoryRepo;
  final CurrencyRepository _currencyRepo;
  final SharedElementRepository _sharedRepo;

  void init() async {
    await _costItemRepo.ready;
    await _categoryRepo.ready;
    await _currencyRepo.ready;

    getInitValue();

    _periodStart = _sharedRepo.displayDate;

    _itemSubscription = _costItemRepo.valueStream.listen((value) {
      // debugPrint('stream updated');
      // debugPrint(
      //   'stream: day summary: ${value.daySummary.entries.last.key},${value.daySummary.entries.last.value.expense}',
      // );
      getInitValue();
      // _costItems = value.items.where((i) => i.costType == _type).toList();
      // _daySummary = _costItemRepo.daySummary;
      // _monthSummary = _costItemRepo.monthSummary;
      notifyListeners();
    });
    _categorySubscription = _categoryRepo.categoryStream.listen((value) => notifyListeners());

    _isInitalized = true;

    notifyListeners();
  }

  void getInitValue() {
    // _costItems = _costItemRepo.costItems.where((i) => i.costType == _type).toList();
    _costItems = _costItemRepo.costItems.toList();
    _daySummary = _costItemRepo.daySummary;
    _monthSummary = _costItemRepo.monthSummary;
  }

  bool _isInitalized = false;
  bool get ready => _isInitalized;

  bool get showMonths => _period == ChartPeriod.year;
  bool get showPrevious => _rangeType != DateRangeType.custom;

  ChartPeriod _period = ChartPeriod.month;
  ChartPeriod get period => _period;

  CostType _type = CostType.expense;
  CostType get type => _type;

  DateTime _periodStart = DateTime.now().standard;

  // ignore: unused_field
  StreamSubscription<CostItemRepoDataStream>? _itemSubscription;
  StreamSubscription<List<CostItemCategory>>? _categorySubscription;

  List<CostItem> _costItems = [];
  Map<DateTime, CostMetric> _daySummary = {};
  Map<DateTime, CostMetric> _monthSummary = {};

  String get displayPeriodDuration {
    switch (_period) {
      case ChartPeriod.month:
        return DateFormat('MMMM yyyy').format(_periodStart);
      case ChartPeriod.week:
        return "${_curRange.end.year}, Week ${_periodStart.weekNumber}";
      case ChartPeriod.year:
        return DateFormat('yyyy').format(_periodStart);
      case ChartPeriod.custom:
        return "Custom";
    }
  }

  String get prevDisplayPeriod {
    switch (_period) {
      case ChartPeriod.month:
        return DateFormat('MMMM yyyy').format(_prevRange.start);
      case ChartPeriod.week:
        return "${_curRange.end.year}, Week ${_prevRange.start.weekNumber}";
      case ChartPeriod.year:
        return DateFormat('yyyy').format(_prevRange.start);
      case ChartPeriod.custom:
        return "Custom";
    }
  }

  String get displayDetailsPeriodDuration {
    return '${DateFormat("dd MMM yyyy").format(_curRange.start)} - ${DateFormat("dd MMM yyyy").format(_curRange.end)}';
  }

  DateRangeType _rangeType = DateRangeType.thisMonth;
  DateRangeType get rangeType => _rangeType;

  DateTimeRange _curRange = DateTimeRange(
    start: DateTime.now().startOfMonth,
    end: DateTime.now().endOfMonth,
  );
  DateTime get rangeStart => _curRange.start;
  DateTime get rangeEnd => _curRange.end;
  DateTime get prevRangeStart => _prevRange.start;

  DateTimeRange get _prevRange {
    switch (_period) {
      case ChartPeriod.month:
        return DateTimeRange(
          start: rangeStart.addMonth(-1),
          end: rangeStart.addMonth(-1).endOfMonth,
        );
      case ChartPeriod.week:
        return DateTimeRange(start: rangeStart.addDay(-7), end: rangeStart.addDay(-7).endOfWeek);
      case ChartPeriod.year:
        return DateTimeRange(start: rangeStart.addYear(-1), end: rangeStart.addYear(-1).endOfYear);
      case ChartPeriod.custom:
        return DateTimeRange(start: rangeStart, end: rangeEnd);
    }
  }

  String Function(
    double value, {
    bool abbreviated,
    bool alwaysShowSign,
    bool compact,
    int? decimalDigits,
  })
  get currencyFormat => _currencyRepo.formatCurrency;

  Map<CostItemCategory, List<CostItem>> getItemsGroupedByCategory({bool curRange = true}) {
    final items = _costItems.where(
      (item) => item.date!.isWithinRange(curRange ? _curRange : _prevRange),
    );
    return groupBy(items, (item) => _categoryRepo.getCategoryById(item.categoryId!));
  }

  Map<CostItemCategory, CostMetric> getCategorySummary({
    bool curRange = true,
    bool simplified = false,
  }) {
    debugPrint("get category summary called");
    final items = getItemsGroupedByCategory(curRange: curRange);
    Map<CostItemCategory, CostMetric> result = items.map(
      (id, list) => MapEntry(id, CostMetric.fromCostItemList(list)),
    );
    final sorted = Map.fromEntries(
      result.entries.sorted((a, b) => b.value.expense!.compareTo(a.value.expense!)),
    );
    if (!simplified) return sorted;
    if (sorted.length <= 5) {
      return sorted;
    } else {
      double expense = sorted.entries.foldIndexed(
        0.0,
        ((index, previous, element) => previous + (index >= 4 ? element.value.expense ?? 0 : 0)),
      );
      return Map.fromEntries([
        ...sorted.entries.take(4),
        MapEntry(CostItemCategory(name: "others"), CostMetric(expense: expense, income: 0)),
      ]);
    }
  }

  Map<CostItemCategory, CostMetric> get curRangeCategorySummary =>
      getCategorySummary(curRange: true, simplified: false);
  Map<CostItemCategory, CostMetric> get simplifiedCurRangeCategorySummary =>
      getCategorySummary(curRange: true, simplified: true);
  Map<CostItemCategory, CostMetric> get _prevRangeCategorySummary =>
      getCategorySummary(curRange: false, simplified: false);

  List<CostItemCategory>? _hiddenCategories;
  List<CostItemCategory>? get hiddenCategories => _hiddenCategories;

  Map<CostItemCategory, CostMetric> get filteredCurRangeCategorySummary {
    final filteredEntries = curRangeCategorySummary.entries.where((entry) {
      if (_hiddenCategories == null) return true;
      return !_hiddenCategories!.contains(entry.key);
    });
    return Map.fromEntries(filteredEntries);
  }

  void toggleHideCategory(CostItemCategory category) {
    if (_hiddenCategories == null) {
      _hiddenCategories = [category];
    } else if (_hiddenCategories!.contains(category)) {
      _hiddenCategories!.remove(category);
      if (_hiddenCategories!.isEmpty) {
        _hiddenCategories = null;
      }
    } else {
      _hiddenCategories!.add(category);
    }

    notifyListeners();
  }

  CostMetric get filteredCurRangeSummary {
    debugPrint("get filtered summary");
    CostMetric base = CostMetric(expense: 0, income: 0);
    return filteredCurRangeCategorySummary.entries.fold<CostMetric>(base, (
      CostMetric metric,
      MapEntry<CostItemCategory, CostMetric> entry,
    ) {
      return metric.combineWith(entry.value);
    });
  }

  Map<CostItemCategory, List<CostMetric>> get categoryComparison {
    final categories = {
      ...simplifiedCurRangeCategorySummary.keys,
      ..._prevRangeCategorySummary.keys,
    };
    Map<CostItemCategory, List<CostMetric>> result = {};
    for (final category in categories) {
      result[category] = [
        _prevRangeCategorySummary[category] ?? CostMetric(),
        curRangeCategorySummary[category] ?? CostMetric(),
      ];
    }
    return Map.fromEntries(result.entries.take(3));
  }

  CostMetric get curRangeSummary {
    final items = _costItems.where((item) => item.date!.isWithinRange(_curRange)).toList();
    return CostMetric.fromCostItemList(items);
  }

  Map<DateTime, CostMetric> getRangeOverview({bool isCurrent = true}) {
    Iterable<MapEntry<DateTime, CostMetric>> result = {};
    final DateTimeRange range = isCurrent ? _curRange : _prevRange;

    if (showMonths) {
      result = List.generate(range.end.month - range.start.month + 1, (i) => i).map((i) {
        final date = range.start.addMonth(i);
        final metrics = _monthSummary[date] ?? CostMetric();
        return MapEntry(date, metrics);
      });
    } else {
      result = List.generate(range.duration.inDays + 1, (i) => i).map((i) {
        final date = range.start.addDay(i);
        final metrics = _daySummary[date] ?? CostMetric();
        return MapEntry(date, metrics);
      });
    }

    return Map.fromEntries(result);
  }

  Map<DateTime, CostMetric> get prevRangeOverview => getRangeOverview(isCurrent: false);
  Map<DateTime, CostMetric> get curRangeOverview => getRangeOverview(isCurrent: true);

  List<Map<DateTime, CostMetric>> get dayToDayComparison {
    final maxLength = max(prevRangeOverview.length, curRangeOverview.length);
    List<Map<DateTime, CostMetric>> result = [];
    for (int i = 0; i < maxLength; i++) {
      List<MapEntry<DateTime, CostMetric>> entries = [];
      final curData = curRangeOverview.entries.elementAtOrNull(i);
      if (curData != null) {
        entries.add(curData);
      }
      final prevData = prevRangeOverview.entries.elementAtOrNull(i);
      if (prevData != null) {
        entries.add(prevData);
      }
      result.add(Map.fromEntries(entries));
    }
    return result;
  }

  Map<DateTime, CostMetric> calculateCumulativeMetric({bool isCurrent = true}) {
    CostMetric totalMetric = CostMetric();
    List<MapEntry<DateTime, CostMetric>> result = [];
    final rangeMap = isCurrent ? curRangeOverview : prevRangeOverview;
    rangeMap.forEach((key, metric) {
      totalMetric = totalMetric.combineWith(metric);
      if (key.isAfter(DateTime.now().standard) && metric.isEmpty) {
      } else {
        result.add(MapEntry(key, totalMetric));
      }
    });
    return Map.fromEntries(result);
  }

  Map<DateTime, double> calculateCumulative({bool isCurrent = true, CostType? type}) {
    return calculateCumulativeMetric(isCurrent: isCurrent).map(
      (key, value) => MapEntry(
        key,
        type == null
            ? value.balance
            : type == CostType.expense
            ? value.expense ?? 0
            : value.income ?? 0,
      ),
    );
    // double total = 0;
    // List<MapEntry<DateTime, double>> result = [];
    // final rangeMap = isCurrent ? curRangeOverview : prevRangeOverview;
    // rangeMap.forEach((key, metric) {
    //   total += (_type == CostType.expense ? (metric.expense ?? 0) : (metric.income ?? 0));
    //   result.add(MapEntry(key, total));
    // });
    // return Map.fromEntries(result);
  }

  Map<DateTime, double> calculateAverageCumulative({bool isCurrent = true}) {
    // List<MapEntry<DateTime, double>> result = [];
    return Map.fromEntries(
      calculateCumulative(isCurrent: isCurrent).entries.mapIndexed((index, entry) {
        return MapEntry(entry.key, entry.value / (index + 1));
      }),
    );
    // return Map.fromEntries(result);
  }

  List<Map<DateTime, double>> get cumulativeComparison => [
    calculateCumulative(isCurrent: false, type: CostType.expense),
    calculateCumulative(isCurrent: true, type: CostType.expense),
  ];

  List<Map<DateTime, double>> get avgCumulativeComparison => [
    calculateAverageCumulative(isCurrent: false),
    calculateAverageCumulative(isCurrent: true),
  ];

  CostMetric get prevRangeToDayCumulative {
    final cumulative = calculateCumulativeMetric(isCurrent: false);
    final index = cumulativeComparison.last.entries.toList().indexWhere(
      (entry) => entry.key.isAtSameMomentAs(DateTime.now().standard),
    );
    if (index == -1) return cumulative.values.lastOrNull ?? CostMetric();
    return cumulative.values.elementAt(index);
  }

  double get balancePercentageDifference {
    return (curRangeSummary.balance - prevRangeToDayCumulative.balance) / (curRangeSummary.balance);
  }

  double dailyRangePercentile(double percent) {
    return 0;
    // final maxValue = curRangeOverview.entries.fold<double>(
    //   0,
    //   (prev, entry) => max(prev, entry.value.expense ?? 0),
    // );
    // return maxValue * percent / 100;
  }

  Map<String, Map<String, double>> get balanceOverview => {
    "expense": {
      "previous": (prevRangeToDayCumulative.expense ?? 0) * -1,
      "current": (curRangeSummary.expense ?? 0) * -1,
    },
    "income": {
      "previous": prevRangeToDayCumulative.income ?? 0,
      "current": curRangeSummary.income ?? 0,
    },
    "balance": {
      "previous": prevRangeToDayCumulative.balance,
      "current": curRangeSummary.balance,
    },
  };

  double get chartMax {
    final maxIncome = [
      curRangeSummary.income ?? 0,
      prevRangeToDayCumulative.income ?? 0,
      curRangeSummary.expense ?? 0,
      prevRangeToDayCumulative.expense ?? 0,
    ].fold(0.0, (prev, value) => max(prev, value));

    return maxIncome * 1.6;
  }

  // double get chartMin {
  //   return [curRangeSummary.expense ?? 0, prevRangeToDayCumulative.expense ?? 0].fold(0.0, (prev, value) => max(prev,value)) * -1.2;
  // }

  void updatePeriod(ChartPeriod selectedPeriod) {
    _period = selectedPeriod;
    switch (_period) {
      case ChartPeriod.month:
        _curRange = DateTimeRange(start: _periodStart.startOfMonth, end: _periodStart.endOfMonth);
      case ChartPeriod.week:
        _curRange = DateTimeRange(start: _periodStart.startOfWeek, end: _periodStart.endOfWeek);
      case ChartPeriod.year:
        _curRange = DateTimeRange(start: _periodStart.startOfYear, end: _periodStart.endOfYear);
      case ChartPeriod.custom:
        _curRange = DateTimeRange(start: _periodStart.startOfYear, end: _periodStart.endOfYear);
      // case DateRangeType.thisYear:
      //   _curRange = DateTimeRange(start: now.startOfYear, end: now.endOfYear);
      // case DateRangeType.thisWeek:
      //   _curRange = DateTimeRange(start: now.startOfWeek, end: now.endOfWeek);
      // case DateRangeType.oneWeek:
      //   _curRange = DateTimeRange(start: now.standardNow.addDay(-6), end: now.standardNow);
      // case DateRangeType.oneMonth:
      //   _curRange = DateTimeRange(start: now.standardNow.addMonth(-1), end: now.standardNow);
      // case DateRangeType.oneYear:
      //   _curRange = DateTimeRange(start: now.standardNow.addYear(-1), end: now.standardNow);
    }

    notifyListeners();
    // debugPrint("log range, $_curRange, $_prevRange");
  }

  void updatePeriodDuration({bool increase = false}) {
    switch (_period) {
      case ChartPeriod.month:
        _periodStart = _periodStart.addMonth(increase ? 1 : -1);
      case ChartPeriod.week:
        _periodStart = _periodStart.addDay(increase ? 7 : -7);
      case ChartPeriod.year:
        _periodStart = _periodStart.addYear(increase ? 1 : -1);
      case ChartPeriod.custom:
        _periodStart = _periodStart.addYear(increase ? 1 : -1);
    }

    _sharedRepo.updateDisplayDate(_periodStart);
    updatePeriod(_period);
  }

  void updateCostType(CostType type) {
    _type = type;
    notifyListeners();
  }
}

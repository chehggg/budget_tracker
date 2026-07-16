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
      getInitValue();
      notifyListeners();
    });
    _categorySubscription = _categoryRepo.categoryStream.listen((value) => notifyListeners());

    _isInitalized = true;

    notifyListeners();
  }

  void getInitValue() {
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

  YearMonth _yearMonth = YearMonth(useRange: false, date1: DateTime.now());
  YearMonth get yearMonth => _yearMonth;

  CostType _type = CostType.expense;
  CostType get type => _type;

  DateTime _periodStart = DateTime.now().standard;

  StreamSubscription<CostItemRepoDataStream>? _itemSubscription;
  StreamSubscription<List<CostItemCategory>>? _categorySubscription;

  List<CostItem> _costItems = [];
  Map<DateTime, CostMetric> _daySummary = {};
  Map<DateTime, CostMetric> _monthSummary = {};

  ChartMetric _chartMetric = ChartMetric.balance;
  ChartMetric get chartMetric => _chartMetric;

  static List<String> get weekdayInitials => [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  static List<String> get monthInitials => [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  String getInitials(int index, {bool useInitials = false, bool useDotForMonth = false}) {
    switch (_period) {
      case ChartPeriod.month:
        if (useDotForMonth) {
          return "•";
        } else {
          return (index + 1).toString();
        }
      case ChartPeriod.week:
        return weekdayInitials.elementAtOrNull(index)?.substring(0, useInitials ? 1 : null) ?? "";
      case ChartPeriod.year:
        return monthInitials.elementAtOrNull(index)?.substring(0, useInitials ? 1 : null) ?? "";
      case ChartPeriod.custom:
        return (index + 1).toString();
    }
  }

  String get curDisplayPeriod {
    switch (_period) {
      case ChartPeriod.month:
        return DateFormat('MMMM yyyy').format(_periodStart);
      case ChartPeriod.week:
        return "${_curRange.end.year}, W${_periodStart.weekNumber}";
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

  Map<DateTime, CostMetric> get sixMonthOverview {
    switch (_period) {
      case ChartPeriod.month:
        int startMonth, endMonth;
        final index = _costItemRepo.monthSummary.keys.toList().indexWhere(
          (date) => date.isInSameYearMonthAs(_periodStart),
        );
        if (index < 0) {
          startMonth = -7;
          endMonth = 0;
        } else {
          startMonth = -7 + index;
          endMonth = startMonth + 7;
        }
        return Map.fromEntries(
          _costItemRepo.monthSummary.entries
              .where(
                (entry) {
                  return entry.key.isWithinRange(
                    DateTimeRange(
                      start: _periodStart.addMonth(startMonth),
                      end: _periodStart.addMonth(endMonth),
                    ),
                  );
                },
              )
              .toList()
              .reversed,
        );
      case ChartPeriod.week:
        return {};
      case ChartPeriod.year:
        return Map.fromEntries(
          _costItemRepo.yearSummary.entries
              .where(
                (entry) {
                  return entry.key.isWithinRange(
                    DateTimeRange(
                      start: _periodStart.addYear(-4),
                      end: _periodStart.addYear(3),
                    ),
                  );
                },
              )
              .toList()
              .reversed,
        );
      case ChartPeriod.custom:
        return {};
    }
  }

  void updateChartMetric(ChartMetric newMetric) {
    _chartMetric = newMetric;
    notifyListeners();
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
  DateTime get prevRangeEnd => _prevRange.end;

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
    bool showSymbol,
    bool compact,
    int? decimalDigits,
  })
  get currencyFormat => _currencyRepo.formatCurrency;

  Map<CostItemCategory, List<CostItem>> getItemsGroupedByCategory({
    bool curRange = true,
    CostType? type = CostType.expense,
  }) {
    final items = _costItems.where(
      (item) => item.date!.isWithinRange(curRange ? _curRange : _prevRange),
    );
    final grouped = groupBy(items, (item) => _categoryRepo.getCategoryById(item.categoryId!));
    return Map.fromEntries(
      grouped.entries.toList().where((entry) => type == null ? true : entry.key.costType == type),
    );
  }

  Map<CostItemCategory, CostMetric> getCategorySummary({
    bool curRange = true,
    bool simplified = false,
    CostType type = CostType.expense,
    SortType order = SortType.dsc,
    String sortBy = "Amount",
  }) {
    debugPrint("get category summary called");
    final items = getItemsGroupedByCategory(curRange: curRange, type: type);
    Map<CostItemCategory, CostMetric> result = items.map(
      (id, list) => MapEntry(id, CostMetric.fromCostItemList(list)),
    );
    final sorted = Map.fromEntries(
      result.entries.sorted((a, b) {
        if (sortBy == "Amount") {
          return type == CostType.expense
              ? order.sortItem<double>(a.value.expense!, b.value.expense!)
              : order.sortItem<double>(a.value.income!, b.value.income!);
        } else if (sortBy == "Name") {
          return order.sortItem<String>(a.key.name!.toLowerCase(), b.key.name!.toLowerCase());
        } else {
          return order.sortItem<String>(a.key.name!.toLowerCase(), b.key.name!.toLowerCase());
        }
      }),
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

  Map<CostItemCategory, List<CostItem>> get curRangeSortedCategoryItems {
    final items = getItemsGroupedByCategory(
      curRange: true,
      type: _breakdownType,
    );
    return Map.fromEntries(
      items.entries.map((entry) {
        return MapEntry(
          entry.key,
          entry.value.sorted((a, b) {
            if (_itemSortBy == "Amount") {
              return _itemOrder.sortItem<double>(a.amount!, b.amount!);
            } else if (_itemSortBy == "Date") {
              return _itemOrder.sortItem<DateTime>(a.date!, b.date!);
            } else if (_itemSortBy == "Name") {
              return _itemOrder.sortItem<String>(a.name ?? "", b.name ?? "");
            } else {
              return _itemOrder.sortItem<double>(a.amount!, b.amount!);
            }
          }),
        );
      }).toList(),
    );
  }

  Map<CostItemCategory, CostMetric> get curRangeDetailedCategorySummary => getCategorySummary(
    curRange: true,
    simplified: false,
    order: _categoryOrder,
    type: _breakdownType,
    sortBy: _categorySortBy,
  );

  Map<CostItemCategory, CostMetric> get simplifiedCurRangeCategorySummary =>
      getCategorySummary(curRange: true, simplified: true);
  Map<CostItemCategory, CostMetric> get _prevRangeCategorySummary =>
      getCategorySummary(curRange: false, simplified: false);

  List<CostItemCategory>? _hiddenCategories;
  List<CostItemCategory>? get hiddenCategories => _hiddenCategories;

  CostType _breakdownType = CostType.expense;
  CostType get breakdownType => _breakdownType;

  double get maxCategoryAmount {
    return curRangeDetailedCategorySummary.entries.fold(
      0.0,
      (init, entry) => max(
        init,
        _breakdownType == CostType.expense ? entry.value.expense! : entry.value.income!,
      ),
    );
  }

  void changeBreakdownType(CostType type) {
    _breakdownType = type;
    notifyListeners();
  }

  // String _category
  SortType _categoryOrder = SortType.dsc;
  SortType _itemOrder = SortType.dsc;

  String _categorySortBy = "Amount";
  String _itemSortBy = "Amount";

  CategoryBreakdownSort get breakdownSort => CategoryBreakdownSort(
    categoryOrder: _categoryOrder,
    categorySortBy: _categorySortBy,
    itemOrder: _itemOrder,
    itemSortBy: _itemSortBy,
  );

  CostItemCategory? _expandedCat;
  CostItemCategory? get expandedCat => _expandedCat;

  void changeCategoryOrder(SortType type) {
    _categoryOrder = type;
    notifyListeners();
  }

  void changeItemOrder(SortType type) {
    _itemOrder = type;
    notifyListeners();
  }

  void changeCategorySortBy(String by) {
    _categorySortBy = by;
    notifyListeners();
  }

  void changeItemSortBy(String by) {
    _itemSortBy = by;
    notifyListeners();
  }

  void updateCategorySort(CategoryBreakdownSort result) {
    _categoryOrder = result.categoryOrder;
    _categorySortBy = result.categorySortBy;
    _itemOrder = result.itemOrder;
    _itemSortBy = result.itemSortBy;
    notifyListeners();
  }

  Map<CostItemCategory, CostMetric> get filteredCurRangeCategorySummary {
    final filteredEntries = curRangeDetailedCategorySummary.entries.where((entry) {
      final notHidden = _hiddenCategories == null ? true : !_hiddenCategories!.contains(entry.key);
      return notHidden;
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
        curRangeDetailedCategorySummary[category] ?? CostMetric(),
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
      final prevData = prevRangeOverview.entries.elementAtOrNull(i);
      if (prevData != null) {
        entries.add(prevData);
      }
      final curData = curRangeOverview.entries.elementAtOrNull(i);
      if (curData != null) {
        entries.add(curData);
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

  Map<DateTime, double> calculateCumulative({
    bool isCurrent = true,
    ChartMetric type = ChartMetric.balance,
  }) {
    return calculateCumulativeMetric(isCurrent: isCurrent).map(
      (key, value) => MapEntry(key, type.getCostMetric(value) ?? 0),
    );
  }

  Map<DateTime, double> calculateAverageCumulative({
    bool isCurrent = true,
    ChartMetric type = ChartMetric.balance,
  }) {
    return Map.fromEntries(
      calculateCumulative(isCurrent: isCurrent, type: type).entries.mapIndexed((index, entry) {
        return MapEntry(entry.key, entry.value / (index + 1));
      }),
    );
  }

  List<Map<DateTime, double>> get cumulativeComparison => [
    calculateCumulative(isCurrent: false, type: _chartMetric),
    calculateCumulative(isCurrent: true, type: _chartMetric),
  ];

  Map<int, Map<String, double?>> getPercentageChange({
    required Map<DateTime, double> previous,
    required Map<DateTime, double> current,
    // ChartMetric? chartMetric,
  }) {
    final maxLength = max(previous.length, current.length);
    // final metric = chartMetric ?? _chartMetric;
    return Map.fromEntries(
      List.generate(maxLength, (i) {
        final curEntry = current.entries.elementAtOrNull(i);
        final prevEntry = previous.entries.elementAtOrNull(i);
        final curValue = curEntry?.value;
        final prevValue = prevEntry?.value;
        if (curValue == null || prevValue == null) {
          return MapEntry(i, {
            "change": null,
            "percentage": null,
          });
        } else {
          final change = curValue - prevValue;
          final percentage = change / (prevValue.abs());
          return MapEntry(i, {
            "change": change,
            "percentage": percentage,
          });
        }
      }),
    );
  }

  DateTime get curMTD =>
      rangeStart.isInSameYearMonthAs(DateTime.now())
          ? DateTime.now().standard
          : rangeStart.endOfMonth;

  DateTime get previousMTD {
    switch (_period) {
      case ChartPeriod.month:
        return rangeStart.isInSameYearMonthAs(DateTime.now())
            ? curMTD.addMonth(-1)
            : curMTD.addMonth(-1).endOfMonth;
      case ChartPeriod.week:
        return curMTD.addDay(-7);
      case ChartPeriod.year:
        return curMTD.addYear(-1);
      case ChartPeriod.custom:
        return curMTD.addYear(-1);
    }
    ;
  }

  List<Map<DateTime, double>> get avgCumulativeComparison => [
    calculateAverageCumulative(isCurrent: false, type: _chartMetric),
    calculateAverageCumulative(isCurrent: true, type: _chartMetric),
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

  // double get chartMax {
  //   final incomeMax = max(
  //     curRangeSummary.income ?? 0.01,
  //     prevRangeToDayCumulative.income ?? 0.01,
  //   );
  //   final expenseMax = max(
  //     curRangeSummary.expense ?? 0.01,
  //     prevRangeToDayCumulative.expense ?? 0.01,
  //   );
  //   return incomeMax * 1.5;
  // }

  bool get padRight {
    return max(
          curRangeSummary.income ?? 0,
          prevRangeToDayCumulative.income ?? 0,
        ) >
        0;
  }

  // bool get padRight {
  //   return max(
  //     curRangeSummary.income ?? 0,
  //     prevRangeToDayCumulative.income ?? 0,
  //   ) > 0;
  // }

  double get balanceOffset {
    double curve(double x) {
      return 1 - 0.8 * pow(1 - x.abs(), 1.1);
    }

    double alignment = -1;
    final incomeMax = max(
      curRangeSummary.income ?? 0.01,
      prevRangeToDayCumulative.income ?? 0.01,
    );
    final expenseMax = max(
      curRangeSummary.expense ?? 0.01,
      prevRangeToDayCumulative.expense ?? 0.01,
    );

    final isCurrentLarger = curRangeSummary.balance.abs() > prevRangeToDayCumulative.balance.abs();
    final isLargerNegative =
        isCurrentLarger ? (curRangeSummary.balance < 0) : (prevRangeToDayCumulative.balance < 0);

    if (prevRangeToDayCumulative.balance == 0 && curRangeSummary.balance == 0) {
      return -1;
    }
    alignment =
        (isCurrentLarger ? curRangeSummary.balance : prevRangeToDayCumulative.balance) /
        (isLargerNegative ? expenseMax : incomeMax);
    debugPrint('alignment: ${alignment}');

    debugPrint('altered alignment: ${curve(alignment.abs()) * (isLargerNegative ? -1 : 1)}');
    return curve(alignment.abs()) * (isLargerNegative ? -1 : 1);
  }

  // double get chartMin {
  //   final expenseMax = max(
  //     curRangeSummary.expense ?? 0.01,
  //     prevRangeToDayCumulative.expense ?? 0.01,
  //   );
  //   return expenseMax * -1.5;
  // }

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

  void expandTileAfterFormUpdate(CostItemCategory category) {
    _expandedCat = category;
    notifyListeners();
  }

  AccentColor get accentColors => _sharedRepo.accentColors;

  Color getChangePercentageColor(double value, {ChartMetric? metric}) {
    return accentColors.getColorByValue(
      value,
      reversed: (metric ?? _chartMetric) == ChartMetric.expense,
    );
  }

  @override
  void dispose() {
    _itemSubscription?.cancel();
    _categorySubscription?.cancel();
    super.dispose();
  }
}

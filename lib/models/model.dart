import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:budget_tracker/custom/category_class.dart';
import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/enum.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/screens/settings/budget_settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:budget_tracker/constants/categories.dart';
import 'package:budget_tracker/constants/currency.dart';
import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/models/theme_model.dart';

class AppModel extends ChangeNotifier {
  AppModel({required CostItemRepository costItemRepository})
    : _costItemRepository = costItemRepository {
    initialize();
  }

  final CostItemRepository _costItemRepository;
  final sharedPref = SharedPreferencesAsync();

  List<Budget> _budgets = [];
  UnmodifiableListView<Budget> get budgets => UnmodifiableListView(_budgets);

  String _localeName = "en";
  String? _filteredString;

  Set<String> _filteredCategories = {};
  Set<String> get filteredCategories => _filteredCategories;

  DateTimeRange? _filterDateRange;
  DateTimeRange? get filterDateRange => _filterDateRange;

  DateRangeFilterType _dateRangeFilter = DateRangeFilterType.none;
  DateRangeFilterType get dateRangeFilter => _dateRangeFilter;

  bool get isFilteredActive =>
      _filteredString != null ||
      _filteredCategories.length < _categories.length ||
      _filterDateRange != null;

  final Map<DateTime, CostMetric> _yearMonthMetrics = {};
  final SplayTreeMap<DateTime, CostMetric> _dayMetrics = SplayTreeMap<DateTime, CostMetric>(
    (a, b) => b.compareTo(a),
  );
  final Map<DateTime, Map<String, CostMetric>> _yearMonthCategoryMetrics = {};
  // final Map<String, Map<String, CostMetric>> _summarizedYearMonthCategoryMetrics = {};
  final Map<DateTime, Map<String, List<CostItem>>> _yearMonthCategoryGroupedList = {};

  final SplayTreeMap<DateTime, List<CostItem>> _dailyCostItems =
      SplayTreeMap<DateTime, List<CostItem>>((a, b) => b.compareTo(a));

  UnmodifiableMapView<DateTime, List<CostItem>> get currentMonthDailyCostItems {
    final Map<DateTime, List<CostItem>> currentMonthCostItem = Map.fromEntries(
      _dailyCostItems.entries.where(
        (entry) => entry.key.isInSameYearMonthAs(selectedYearMonth),
      ),
    );

    if (isFilteredActive) {
      final Map<DateTime, List<CostItem>> temp = {};
      // debugPrint("this triggeredd!");
      currentMonthCostItem.forEach((key, value) {
        bool isCategoryIncluded(CostItem costItem) =>
            _filteredCategories.contains(costItem.category);
        bool isFilterStringMatch(CostItem costItem) =>
            _filteredString != null ? costItem.name.contains(_filteredString!) : true;
        bool isDateWithinFilter(CostItem costItem) =>
            _filterDateRange != null
                ? costItem.date.isBefore(
                      _filterDateRange!.end.add(Duration(days: 1)),
                    ) &&
                    costItem.date.isAfter(
                      _filterDateRange!.start.subtract(Duration(days: 1)),
                    )
                : true;
        bool isMatch(CostItem costItem) =>
            isCategoryIncluded(costItem) &&
            isFilterStringMatch(costItem) &&
            isDateWithinFilter(costItem);

        if (value.any(isMatch)) {
          temp.putIfAbsent(key, () => []).addAll(value.where(isMatch));
        }
      });
      return UnmodifiableMapView(temp);
    } else {
      return UnmodifiableMapView(currentMonthCostItem);
    }
  }

  List<CostItem> _costItems = [];
  UnmodifiableListView<CostItem> get costItems => UnmodifiableListView(_costItems);

  List<CostItemCategory> _categories = [];
  UnmodifiableListView<CostItemCategory> get categories => UnmodifiableListView(_categories);

  List<NoteHistory> _notes = [];
  UnmodifiableListView<NoteHistory> notes(String? category) {
    if (category == null) return UnmodifiableListView([]);
    return UnmodifiableListView(
      _notes.where((note) => note.categoryName == category).toList(),
    );
  }

  List<double> getPercentiles() {
    final sortedAmountList =
        _filteredCostItems.map((costItem) => costItem.amount).toList()
          ..sort((a, b) => a.compareTo(b));
    return [
      sortedAmountList[(0 * sortedAmountList.length).round()],
      sortedAmountList[(1 / 4 * sortedAmountList.length - 1 / 2).round()],
      sortedAmountList[(1 / 2 * sortedAmountList.length - 1 / 2).round()],
      sortedAmountList[(3 / 4 * sortedAmountList.length - 1 / 2).round()],
      sortedAmountList[(1 * sortedAmountList.length - 1).round()],
    ];
  }

  // filter items by month
  // date format: yyyy-MM-dd
  UnmodifiableListView<CostItem> get _filteredCostItems {
    return UnmodifiableListView(
      _costItems.where(
        (costItem) => costItem.date.isInSameYearMonthAs(selectedYearMonth),
      ),
    );
  }

  UnmodifiableListView<CostItem> get filteredCostItems => _filteredCostItems;

  SplayTreeMap<String, List<Map<String, dynamic>>> _budgetMetrics = SplayTreeMap();
  UnmodifiableMapView<String, List<Map<String, dynamic>>> get budgetMetrics =>
      UnmodifiableMapView(_budgetMetrics);

  UnmodifiableMapView<String, List<CostItem>> get currentCategoryList {
    return UnmodifiableMapView(
      _yearMonthCategoryGroupedList[_selectedYearMonth]!,
    );
  }

  UnmodifiableMapView<DateTime, CostMetric> get yearMonthOverview =>
      UnmodifiableMapView(_yearMonthMetrics);

  void updateFilterString(String? newString) {
    _filteredString = newString == "" ? null : newString;
    debugPrint('new string: $newString');
    notifyListeners();
  }

  // get daily total for bar chart
  UnmodifiableMapView<int, CostMetric> getDailyMetric(
    CostType costType, {
    int monthDifference = 0,
  }) {
    int totalDays = selectedYearMonth.getTotalDayInMonth(
      pastMonth: monthDifference,
    );
    return UnmodifiableMapView(
      Map.fromIterable(
        List.generate(totalDays, (day) => day),
        key: (i) => (i + 1),
        value: (i) {
          final date = DateTime(
            selectedYearMonth.year,
            selectedYearMonth.month - monthDifference,
            i + 1,
          );
          return _dayMetrics[date] ?? CostMetric();
        },
      ),
    );
  }

  // get cumulative total for line chart
  UnmodifiableMapView<int, double> getDailyCumulative(
    CostType costType, {
    int monthDifference = 0,
  }) {
    double cumulative = 0;
    return UnmodifiableMapView(
      getDailyMetric(costType, monthDifference: monthDifference).map((
        int key,
        CostMetric value,
      ) {
        cumulative += value.expense ?? 0;
        return MapEntry(key, cumulative);
      }),
    );
  }

  // get cumulative average for line chart
  UnmodifiableMapView<int, double> getCumulativeAverage(
    CostType costType, {
    int monthDifference = 0,
  }) {
    return UnmodifiableMapView(
      getDailyCumulative(costType, monthDifference: monthDifference).map((
        int dayInt,
        double cumulativeTotal,
      ) {
        return MapEntry(dayInt, cumulativeTotal / dayInt);
      }),
    );
  }

  UnmodifiableMapView<int, CostMetric> get currentDailyMetric => getDailyMetric(CostType.expense);
  UnmodifiableMapView<int, double> get currentCumulative => getDailyCumulative(CostType.expense);
  UnmodifiableMapView<int, double> get currentCumulativeAverage =>
      getCumulativeAverage(CostType.expense);
  UnmodifiableMapView<int, double> get previousCumulative =>
      getDailyCumulative(CostType.expense, monthDifference: 1);
  UnmodifiableMapView<int, double> get previousCumulativeAverage =>
      getCumulativeAverage(CostType.expense, monthDifference: 1);

  UnmodifiableListView<Map<String, dynamic>> summarizedDateGroupDataForCustomCostType(
    CostType costType,
  ) {
    //create sorted list
    final tempList =
        getDailyMetric(costType)
            .map((dateInt, metric) {
              return MapEntry<int, Map<String, dynamic>>(dateInt, {
                "date":
                    DateTime(
                      _selectedYearMonth.year,
                      _selectedYearMonth.month,
                      dateInt,
                    ).displayFormat(),
                "amount": metric.expense,
                "percentage": metric.expense! / totalCurrentMonthExpense,
              });
            })
            .values
            .toList()
          ..removeWhere((a) => a["amount"] == 0) // remove empty days
          ..sort(
            (a, b) => (b["amount"] as double).compareTo((a["amount"] as double)),
          ); // sort days

    if (tempList.length <= 5) return UnmodifiableListView(tempList);

    // add up amount beyond the 5 categories
    double otherAmount = 0;
    double otherPercentage = 0;
    int i = 4;
    for (i; i < tempList.length; i++) {
      otherAmount += tempList[i]['amount'] as double;
      otherPercentage += tempList[i]['percentage'] as double;
    }

    final resultList = [
      ...tempList.getRange(0, 4),
      {"date": "Other", "amount": otherAmount, "percentage": otherPercentage},
    ];

    return UnmodifiableListView(resultList);
  }

  String get currencySymbol =>
      currencies.where((currency) => currency['name'] == _currencyName).first['symbol'];

  String get thousandSeparator =>
      currencies
          .where((currency) => currency['name'] == _currencyName)
          .first['thousands_separator'];

  String get decimalSeparator =>
      currencies.where((currency) => currency['name'] == _currencyName).first['decimal_separator'];

  String _currencyName = currencies.first['name'];
  String get currencyName => _currencyName;

  DateTime _selectedYearMonth = DateTime.now();
  DateTime get selectedYearMonth => _selectedYearMonth;
  String get formatedSelectedYearMonth => DateFormat('yyyy-MM').format(_selectedYearMonth);

  CostItem? _tempRecCostItem;
  CostItem? get tempRecCostItem => _tempRecCostItem;

  void saveTempRecCostFromForm(CostItemFormResult result) {
    _tempRecCostItem = CostItem.fromForm(result, id: Uuid().v4());
    notifyListeners();
  }

  void saveTempRecCostFromExistingCost(CostItem item) {
    _tempRecCostItem = item;
    notifyListeners();
  }

  void removeTempCostItem() {
    _tempRecCostItem = null;
    notifyListeners();
  }

  // void saveCostItemFromTemp(List<DateTime> dates) {
  //   for (var date in dates) {
  //     createCostItem(
  //       CostItemFormResult(
  //         name: _tempRecCostItem?.name ?? "",
  //         category: _tempRecCostItem?.category ?? "",
  //         date: date,
  //         costType: _tempRecCostItem?.costType ?? CostType.expense,
  //         amount: _tempRecCostItem?.amount ?? 0,
  //       ),
  //     );
  //   }
  // }

  double calculateDailyTotal(String date, [CostType? costType]) {
    final dailyFilteredCostItems = _costItems.where((costItem) => costItem.date == date).toList();

    if (costType == null) {
      // not specify particular cost type, get balance
      double expense = calculateTotal(CostType.expense, dailyFilteredCostItems);
      double income = calculateTotal(CostType.income, dailyFilteredCostItems);
      return income - expense;
    } else {
      return calculateTotal(costType, dailyFilteredCostItems);
    }
  }

  void clearFilter() {
    updateFilterString(null);
    updateFilteredCategories(
      Set.from(categories.map((category) => category.name)),
    );
    updateFilteredDateRange(null, DateRangeFilterType.none);
    resetMetric();
    notifyListeners();
  }

  double getDailyTotal(DateTime date) {
    if (isFilteredActive) {
      return currentMonthDailyCostItems[date]?.fold<double>(
            0,
            (double value, CostItem costItem) => value + costItem.getAbsoluteAmount(),
          ) ??
          0;
    } else {
      return _dayMetrics[date]?.balance ?? 0;
    }
  }

  // return accumulated expense
  double get totalCurrentMonthExpense {
    if (isFilteredActive) {
      double amount = 0;
      currentMonthDailyCostItems.forEach((key, value) {
        for (var costItem in value) {
          if (costItem.costType == CostType.expense) amount += costItem.amount;
        }
      });
      return amount;
    } else {
      return _yearMonthMetrics[_selectedYearMonth]?.expense ?? 0;
    }
  }

  double get totalCurrentMonthIncome {
    if (isFilteredActive) {
      double amount = 0;
      currentMonthDailyCostItems.forEach((key, value) {
        for (var costItem in value) {
          if (costItem.costType == CostType.income) amount += costItem.amount;
        }
      });
      return amount;
    } else {
      return _yearMonthMetrics[_selectedYearMonth]?.income ?? 0;
    }
  }

  Map<String, List<CostItem>> get currentMonthCategoryList =>
      _yearMonthCategoryGroupedList[_selectedYearMonth] ?? {};

  double get totalCurrentMonthBalance => totalCurrentMonthIncome - totalCurrentMonthExpense;

  double get totalBudget => 2000;

  double get budgetPercentage => totalCurrentMonthExpense / totalBudget;

  double get remainingDayAverageSpend {
    final remainingDay = _selectedYearMonth.getTotalDayInMonth() - DateTime.now().day;
    return (totalBudget - totalCurrentMonthExpense) / remainingDay;
  }

  Map<String, CostMetric> getcurrentMonthCategoryView(
    bool isDescending,
    CostType costType,
  ) {
    final initCategoryView = _yearMonthCategoryMetrics[_selectedYearMonth] ?? {};

    final sorted =
        initCategoryView.entries.toList()
          ..sort((a, b) {
            if (isDescending) {
              return b.value.expense!.compareTo(a.value.expense!);
            } else {
              return a.value.expense!.compareTo(b.value.expense!);
            }
          })
          ..removeWhere(
            (item) =>
                costType == CostType.expense ? item.value.expense == 0 : item.value.income == 0,
          );

    return {for (var entry in sorted) entry.key: entry.value};
  }

  double getMaxCurrentMonthCategoryAmount(CostType costType) {
    return getcurrentMonthCategoryView(
      true,
      costType,
    ).entries.toList().first.value.expense!;
  }

  String getTotalAsString(String type, {bool useSuffix = false}) {
    switch (type) {
      case 'expense':
        return customCurrencyFormat(totalCurrentMonthExpense, useSuffix);
      case 'income':
        return customCurrencyFormat(totalCurrentMonthIncome, useSuffix);
      case 'balance':
        return customCurrencyFormat(totalCurrentMonthBalance, useSuffix);
      default:
        return "";
    }
  }

  double calculateTotal(CostType costType, List<CostItem> list) {
    double total = 0;
    for (CostItem item in list.where((item) => item.costType == costType)) {
      total += item.amount;
    }
    return total;
  }

  List<double> getDailyBudgetForWholeMonth([CostType? costType]) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final List<double> dailyBudgetList = [];

    for (var day in List.generate(daysInMonth, (day) => day)) {
      final dayString = DateFormat(
        "yyyy-MM-dd",
      ).format(DateTime(now.year, now.month, day));
      dailyBudgetList.add(calculateDailyTotal(dayString, costType));
    }
    return dailyBudgetList;
  }

  String getFormattedCostItemValue(CostItem costItem) {
    if (costItem.costType == CostType.expense) {
      return customCurrencyFormat(costItem.amount, false, true, "-");
    } else {
      return customCurrencyFormat(costItem.amount, false, true, "+");
    }
  }

  CostItemCategory? getCategoryEntry(String categoryname) {
    if (categories.any((categoryItem) => categoryItem.name == categoryname)) {
      return categories.where((categoryItem) => categoryItem.name == categoryname).first;
    } else {
      return null;
    }
  }

  String getCategoryPercentage(double categoryAmount) {
    double percentage = categoryAmount / totalCurrentMonthExpense;
    if (percentage > 0.01) {
      return NumberFormat('#0%').format(percentage);
    } else {
      return "<1%";
    }
  }

  String customCurrencyFormat(
    double value,
    bool useSuffix, [
    bool? usePositiveSign,
    String? overrideSign,
  ]) {
    final String sign;
    if (overrideSign != null) {
      sign = overrideSign;
    } else if (value < 0) {
      sign = "-";
    } else if (usePositiveSign == true) {
      sign = "+";
    } else {
      sign = "";
    }

    String formatDecimal(double value, double div, String suffix) {
      return NumberFormat.compact(locale: _localeName).format(value);
      // if (value % div == 0) {
      //   return NumberFormat.compact(locale: _localeName).format(value / div);
      // } else {
      // }
    }

    final absValue = value.abs();
    String rawString;
    if (useSuffix) {
      if (absValue > 1e9) {
        rawString = formatDecimal(absValue, 1e9, "b");
      } else if (absValue > 1e6) {
        rawString = formatDecimal(absValue, 1e6, "M");
      } else if (absValue > 1e3) {
        rawString = formatDecimal(absValue, 1e3, "k");
      } else {
        rawString = formatDecimal(absValue, 1, "");
      }
      rawString = '$sign$currencySymbol$rawString';
    } else {
      if (absValue % 1 == 0) {
        rawString = NumberFormat("$sign$currencySymbol#,##0").format(absValue);
      } else {
        rawString = NumberFormat(
          "$sign$currencySymbol#,##0.00",
        ).format(absValue);
      }
    }
    return rawString
        .replaceAll(
          RegExp(r','),
          '!',
        ) // convert thousand & decimal separator to temp symbol first
        .replaceAll(RegExp(r'\.'), '?')
        .replaceAll(RegExp(r'!'), thousandSeparator)
        .replaceAll(RegExp(r'\?'), decimalSeparator);
  }

  void updateFilteredCategories(Set<String> newFilteredCategories) {
    _filteredCategories = newFilteredCategories;
    debugPrint(
      "new filtered categories: length: ${_filteredCategories.length}",
    );
    notifyListeners();
  }

  void updateFilteredDateRange(
    DateTimeRange? newDateRange,
    DateRangeFilterType dateFilter,
  ) {
    _filterDateRange = newDateRange;
    _dateRangeFilter = dateFilter;
    notifyListeners();
  }

  void initialize() async {
    // set currency setting in initial run
    // var format = NumberFormat.simpleCurrency(locale: Platform.localeName);
    // _currencySymbol = format.currencySymbol;

    // set initial month as current month
    _selectedYearMonth = DateTime.now().startOfMonth;

    // add default categories
    _categories = [...defaultCostItemCategories];
    _filteredCategories.addAll(_categories.map((category) => category.name!));

    final sharedPrefCurrency = await sharedPref.getString('currency');

    if (sharedPrefCurrency != null) {
      _currencyName = sharedPrefCurrency;
    } else {
      _currencyName = currencies.first['name'];
    }

    // get file for cost items
    // await _costItemRepository.getCostItems();
    // _costItems = _costItemRepository.costItems;

    // get budgets
    // await readBudget();

    // get note history
    // await readNoteFromFile();

    resetMetric();
    debugPrint("refresh");
  }

  void changeCurrency(Map<String, dynamic> currency) {
    _currencyName = currency['name'] as String;
    notifyListeners();

    final sharedPref = SharedPreferencesAsync();
    sharedPref.setString("currency", _currencyName);
  }

  void changeYearMonth(bool isIncrease, {DateTime? specificYearMonth}) {
    if (specificYearMonth != null) {
      _selectedYearMonth = specificYearMonth;
    } else {
      if (isIncrease) {
        _selectedYearMonth = DateTime(
          _selectedYearMonth.year,
          _selectedYearMonth.month + 1,
          1,
        );
      } else {
        _selectedYearMonth = DateTime(
          _selectedYearMonth.year,
          _selectedYearMonth.month - 1,
          1,
        );
      }
    }
    notifyListeners();
  }

  void createNewCategories() {}

  void updateAppModel(ThemeModel themeModel) {
    //change datetime and number locale
    // _localeName = themeModel.appLocale.toLanguageTag();
    // debugPrint("newLocale: $_localeName");
    notifyListeners();
  }

  // create a new item after form is submitted
  void createCostItem(CostItemFormResult result) {
    final newCostItem = CostItem.fromForm(result, id: Uuid().v4());

    if (_costItems.isEmpty) {
      _costItems.insert(0, newCostItem);
    } else {
      // insert in descending order based on date
      final size = _costItems.length;

      int i = 0;
      int insertIndex = size; // default to the end of array if the date is the earliest

      for (i; i < size; i++) {
        if (newCostItem.date.isAfter(_costItems[i].date)) {
          insertIndex = i;
          break;
        }
      }
      _costItems.insert(insertIndex, newCostItem);
    }
    addDailyCostItems(newCostItem);
    updateMetric(newCostItem);
    updateCategoryList(newCostItem.date);

    notifyListeners();
    writeCostItemsToFile();
  }

  void addDailyCostItems(CostItem newCostItem) {
    _dailyCostItems.putIfAbsent(newCostItem.date, () => []).add(newCostItem);
    // if (_dailyCostItems.containsKey(newCostItem.date)) {
    //   _dailyCostItems[newCostItem.date]!.insert(0, newCostItem);
    // } else {
    //   _dailyCostItems[newCostItem.date] = [newCostItem];
    // }
    notifyListeners();
  }

  void deleteDailyCostItems(CostItem oldCostItem) {
    _dailyCostItems[oldCostItem.date]!.removeWhere(
      (costItem) => costItem.uuid == oldCostItem.uuid,
    );
    if (_dailyCostItems[oldCostItem.date]!.isEmpty) {
      _dailyCostItems.remove(oldCostItem.date);
    }
    notifyListeners();
  }

  void updateMetric(CostItem costItem) {
    // update day metrics
    _dayMetrics.putIfAbsent(costItem.date, () => CostMetric()).addToMetric(costItem);

    // update yearmonth metrics
    final yearMonthDate = costItem.date.startOfMonth;
    _yearMonthMetrics.putIfAbsent(yearMonthDate, () => CostMetric()).addToMetric(costItem);

    // update yearmonth metric metrics
    _yearMonthCategoryMetrics
        .putIfAbsent(yearMonthDate, () => {})
        .putIfAbsent(costItem.category, () => CostMetric())
        .addToMetric(costItem);

    // debugPrint(_yearMonthMetrics[yearMonthDate]!.expense.toString());

    // update against budgets
    notifyListeners();
  }

  void removeMetric(CostItem initCostItem) {
    _dayMetrics[initCostItem.date]!.minusFromMetric(initCostItem);

    final yearMonthDate = initCostItem.date.startOfMonth;
    _yearMonthMetrics[yearMonthDate]!.minusFromMetric(initCostItem);

    _yearMonthCategoryMetrics[yearMonthDate]![initCostItem.category]!.minusFromMetric(initCostItem);
  }

  void updateCategoryList(DateTime yearMonth) {
    final dateItem = _costItems.where(
      (item) => item.date.isInSameYearMonthAs(yearMonth),
    );
    _yearMonthCategoryGroupedList[yearMonth.startOfMonth] = groupBy(
      dateItem,
      (item) => item.category,
    );
  }

  void resetMetric() {
    clearMetric();

    for (var item in _costItems) {
      updateMetric(item);
      addDailyCostItems(item);
    }

    for (var yearMonth in _yearMonthMetrics.keys) {
      updateCategoryList(yearMonth);
    }

    if (_budgets.isNotEmpty) {
      calculateMonthlyBudget();
    }

    notifyListeners();
  }

  void clearMetric() {
    _yearMonthMetrics.clear();
    _dayMetrics.clear();
    _yearMonthCategoryMetrics.clear();
    _dailyCostItems.clear();
    notifyListeners();
  }

  Future<void> cacheBudget() async {
    final String budgetJson = jsonEncode(
      _budgets.map((e) => e.toJson()).toList(),
    );
    await sharedPref.setString("budgets", budgetJson);
    notifyListeners();
  }

  Future<void>? readBudget() async {
    final budgetString = await sharedPref.getString("budgets");
    if (budgetString != null) {
      _budgets =
          (jsonDecode(budgetString) as List<dynamic>)
              .map((e) => Budget.fromJson(e as Map<String, dynamic>))
              .toList();
      notifyListeners();
    }
  }

  Future<void> createBudget(Budget newBudget) async {
    newBudget.id = Uuid().v1();
    _budgets.add(newBudget);
    _budgets.sort(
      (a, b) => b.priority!.compareTo(a.priority!),
    );
    _budgets = _budgets;
    debugPrint("Updated!");

    // update in shared pref
    calculateMonthlyBudget();
    await cacheBudget();
  }

  void calculateMonthlyBudget() {
    Map<DateTime, List<Map<String, dynamic>>> budgetMap = SplayTreeMap();
    /*
    year month
    - list of budgets
    - budget amount
     */
    for (MapEntry<DateTime, CostMetric> yearMonthEntry in _yearMonthMetrics.entries) {
      final DateTime yearMonth = yearMonthEntry.key;
      for (Budget curBudget in _budgets) {
        // if budget applies to all month or to this specific month
        if (curBudget.appliedType == BudgetApplyMonth.all ||
            (curBudget.appliedType == BudgetApplyMonth.specific &&
                curBudget.months!.contains(yearMonth))) {
          if (budgetMap[yearMonth] == null) budgetMap[yearMonth] = [];

          double sum = 0;
          if (curBudget.categories != null && curBudget.categories!.isEmpty) {
            // budget for all categories
            sum = yearMonthEntry.value.expense!;
          } else {
            // specific budget
            for (String category in curBudget.categories!) {
              sum += _yearMonthCategoryMetrics[yearMonth]![category]?.expense ?? 0;
            }
          }
          int i = budgetMap[yearMonth]!.indexWhere(
            (e) => e['id'] == curBudget.id,
          );
          if (i != -1) {
            budgetMap[yearMonth]![i] = {
              "id": curBudget.id,
              "name": curBudget.name,
              "categories": curBudget.categories,
              "budget": curBudget.amount,
              "amount": sum,
            };
          } else {
            budgetMap[yearMonth]!.add({
              "id": curBudget.id,
              "name": curBudget.name,
              "categories": curBudget.categories,
              "budget": curBudget.amount,
              "amount": sum,
            });
          }
        }
      }
    }
    _budgetMetrics = SplayTreeMap.from(budgetMap);
    notifyListeners();
  }

  void deleteBudget(String budgetId) async {
    _budgets.removeWhere((e) => e.id == budgetId);
    debugPrint('budget deleted!');
    notifyListeners();

    calculateMonthlyBudget();
    await cacheBudget();
  }

  void updateBudget(String budgetId, Budget updatedBudget) async {
    final budgetIndex = _budgets.indexWhere((e) => e.id == budgetId);
    _budgets[budgetIndex] = Budget.update(updatedBudget, budgetId);
    _budgets.sort(
      (a, b) => b.priority!.compareTo(a.priority!),
    );
    notifyListeners();

    calculateMonthlyBudget();
    await cacheBudget();
  }

  // void enableBudget(Budget budget, bool value) {
  //   _budgets.where
  // }

  // void updateCostItem(CostItemFormResult result, String itemUuid) {
  //   final int initIndex = _costItems.indexWhere(
  //     (costItem) => costItem.uuid == itemUuid,
  //   );
  //   final CostItem initCostItem = _costItems.firstWhere(
  //     (costItem) => costItem.uuid == itemUuid,
  //   );
  //   final CostItem updatedCostItem = CostItem.update(
  //     initCostItem,
  //     result,
  //     itemUuid,
  //   );
  //   // if (result.name.trim() != "") {
  //   //   createNewNoteHistory(NoteHistory(categoryName: result.category, note: result.name));
  //   // }

  //   // if date the same, no need to perform sorting
  //   if (_costItems[initIndex].date == result.date) {
  //     _costItems[initIndex] = updatedCostItem;
  //   } else {
  //     _costItems.removeAt(initIndex);

  //     int insertIndex = _costItems.length;
  //     int i = initIndex - 1;
  //     final DateTime updatedDate = updatedCostItem.date;

  //     while (i >= 0 && i < _costItems.length) {
  //       // debugPrint("current i: $i");

  //       final afterDate = _costItems[i].date;

  //       if (updatedDate.isAfter(afterDate) || updatedDate.isAtSameMomentAs(afterDate)) {
  //         if (i == 0) {
  //           // first item, latest cost item
  //           insertIndex = i;
  //           break;
  //         } else if (updatedDate.isBefore(_costItems[i - 1].date) ||
  //             updatedDate.isAtSameMomentAs(_costItems[i - 1].date)) {
  //           insertIndex = i;
  //           break;
  //         } else {
  //           // prior date is
  //           i--;
  //         }
  //       } else {
  //         i++;
  //       }
  //     }
  //     _costItems.insert(insertIndex, updatedCostItem);

  //     removeMetric(initCostItem);
  //     updateMetric(updatedCostItem);
  //   }

  //   deleteDailyCostItems(initCostItem);
  //   addDailyCostItems(updatedCostItem);
  //   updateCategoryList(initCostItem.date);
  //   updateCategoryList(updatedCostItem.date);

  //   notifyListeners();
  //   writeCostItemsToFile();
  // }

  void deleteCostItem(String costItemId) {
    final CostItem deletedCostItem =
        _costItems.where((costItem) => costItem.uuid == costItemId).first;
    _costItems.removeWhere((costItem) => costItem.uuid == costItemId);

    deleteDailyCostItems(deletedCostItem);
    removeMetric(deletedCostItem);
    updateCategoryList(deletedCostItem.date);
    notifyListeners();
    writeCostItemsToFile();
  }

  // convert cost item list into csv and
  // update file
  Future<void> writeCostItemsToFile() async {
    final List<List<dynamic>> result = List.generate(
      _costItems.length,
      (i) => _costItems[i].toCsv(),
    );

    const List<String> headers = [
      'uuid',
      'date',
      'costType',
      'category',
      'amount',
      'name',
    ];

    final List<List<dynamic>> data = [headers, ...result];

    try {
      final csvString = csv.encode(data);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/budget.csv');

      file.writeAsStringSync(csvString);
    } catch (e) {
      debugPrint("error writing data to file, $e");
    }

    // try {
    //   await writeDataToFirebase();
    // } catch (e) {
    //   debugPrint("error writing data to firebase: $e");
    // }
  }

  Future<void> loadCostItemOnStart() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/budget.csv');
      _costItems = await parseCostItemData(file);
    } catch (e) {
      debugPrint("error reading file on load, $e");
    }
  }

  Future<String?> exportCostItem() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/budget.csv');
      final csvString = file.readAsStringSync();
      final List<int> list = csvString.codeUnits;
      final String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'nomi-output-${Uuid().v4().split('-').first}.csv',
        allowedExtensions: ['csv'],
        bytes: Uint8List.fromList(list),
      );
      return outputFile;
    } catch (e) {
      debugPrint("error: $e");
      return null;
    }
  }

  Future<String?> loadCostItemFromFile({bool overwrite = true}) async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: false,
        allowedExtensions: ['csv'],
        type: FileType.custom,
      );
      if (result == null) return null;

      final file = File(result.files.single.path!);
      final parsedResult = await parseCostItemData(file);
      if (overwrite) {
        _costItems = parsedResult;
      } else {
        _costItems.addAll(parsedResult);
      }
      resetMetric();
      // notifyListeners();
      await writeCostItemsToFile();
      return "success";
    } catch (e) {
      // debugPrint("error reading data from file: $e");
      return e.toString();
    }
  }

  Future<List<CostItem>> parseCostItemData(File file) async {
    try {
      final csvString = file.readAsStringSync();
      final List<List<dynamic>> decodedData = csv.decode(csvString);
      decodedData.removeAt(0);
      return decodedData.map((List<dynamic> item) => CostItem.fromCsv(item, newId: true)).toList();
    } catch (e) {
      debugPrint('error in parsing data: $e');
      return [];
    }
  }

  Future<void> clearCostItem() async {
    try {
      _costItems = [];
      await writeCostItemsToFile();
      notifyListeners();
    } catch (e) {
      debugPrint('error in parsing data: $e');
    }
  }

  void createNewNoteHistory(NoteHistory newNote) async {
    final index = _notes.indexWhere((NoteHistory note) => note == newNote);
    if (index != -1) {
      // existing note
      _notes.removeAt(index); // remove old and push to first item
    }
    _notes.insert(0, newNote);

    // only keep a maximum of 100 latest note for memory sake
    while (_notes.length > 100) {
      _notes.removeLast();
    }

    // update the note history to file
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/notes.txt');
      final text = jsonEncode(_notes.map((note) => note.toJson()).toList());

      // debugPrint("Write file: $text");
      file.writeAsStringSync(text);
    } catch (e) {
      debugPrint("error writing note history to file, error: $e");
    }
  }

  Future<void> readNoteFromFile() async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/notes.txt');
      final noteFileString = file.readAsStringSync();

      // debugPrint("Read file: $noteFileString");
      _notes =
          (jsonDecode(noteFileString) as List)
              .map(
                (jsonObj) => NoteHistory.fromJson(jsonObj as Map<String, dynamic>),
              )
              .toList();
    } catch (e) {
      debugPrint("error in reading note history file, error: $e");
    }
  }

  Future<void> writeDataToFirebase() async {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      // DocumentReference result =  await db.collection('costItem').add(user);
      db
          .collection('costItem')
          .doc('entry')
          // .update({'value':'new'})
          .update({
            'entry': _costItems.map((costItem) => costItem.toJson()).toList(),
          })
          .then((_) => debugPrint("Written data to firebase! Result"));
      // await ref.set({
      //   'value': {
      //     'c': [
      //       'this is a test',
      //       'this is a test 2',
      //       'this is a test 3',
      //     ]
      //   }
      // });
    } catch (e) {
      debugPrint('Error when writing data to firebase: $e');
    }
  }
}

class RelativeDateRange {
  RelativeDateRange({
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  final String name;
  final DateTime startDate;
  final DateTime endDate;

  RelativeDateRange.toCurrent({required this.name, required this.startDate})
    : endDate = DateTime.now();
}

enum DateRangeFilterType { relative, absolute, none }

enum ExchangeRateType { current, custom }

class Budget {
  String? id;
  String? name;
  bool? enabled = true;
  double? amount = 0;
  int? priority;
  BudgetAmount? amountCalType;
  BudgetApplyMonth? appliedType;
  List<DateTime>? months;
  List<String>? categories;

  Budget({
    this.id,
    this.name,
    this.enabled,
    this.priority,
    this.amount,
    this.amountCalType,
    this.appliedType,
    this.months,
    this.categories,
  });

  Budget.update(Budget result, String this.id)
    : name = result.name,
      enabled = result.enabled,
      amount = result.amount,
      priority = result.priority,
      amountCalType = result.amountCalType,
      appliedType = result.appliedType,
      months = result.months,
      categories = result.categories;

  Budget.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    enabled = json['enabled'];
    amount = json['amount'];
    priority = json['priority'];
    appliedType = BudgetApplyMonth.values[json['appliedType'] ?? 0];
    amountCalType = BudgetAmount.values[json['amountCalType'] ?? 0];
    months = [];
    // months = jsonDecode(json['months']) == null? [] : List.from((jsonDecode(json['months']) as List).map((e) => DateFormat('yyyy-MM').parse(e as String)));
    categories = List.from(jsonDecode(json['categories'] ?? "[]"));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['enabled'] = enabled;
    data['amount'] = amount;
    data['priority'] = priority;
    data['appliedType'] = appliedType?.index;
    data['amountCalType'] = amountCalType?.index;
    if (months != null && months!.isNotEmpty) {
      data['months'] = jsonEncode(
        months!.map((e) => DateFormat('yyyy-MM').format(e)),
      );
    }
    data['categories'] = jsonEncode(categories);
    return data;
  }
}

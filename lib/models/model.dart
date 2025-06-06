import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

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

import 'package:budget_tracker/utility/categories.dart';
import 'package:budget_tracker/utility/currency.dart';
import 'package:budget_tracker/extensions.dart';
import 'package:budget_tracker/models/theme_model.dart';

class AppModel extends ChangeNotifier {
  AppModel(){
    setInitSettings();
  }

  String _localeName = "en";
  String? _filteredString;

  Set<String> _filteredCategories = {};
  Set<String> get filteredCategories => _filteredCategories;

  DateTimeRange? _filterDateRange;
  DateTimeRange? get filterDateRange => _filterDateRange;

  dateRangeFilterType _dateRangeFilter = dateRangeFilterType.none;
  dateRangeFilterType get dateRangeFilter => _dateRangeFilter;

  bool get isFilteredActive => _filteredString != null || _filteredCategories.length < _categories.length || _filterDateRange != null;  

  final Map<String, CostMetric> _yearMonthMetrics = {};
  final SplayTreeMap<String, CostMetric> _dayMetrics = SplayTreeMap<String,CostMetric>((a,b) => b.standardDateParse().compareTo(a.standardDateParse()));
  final Map<String, Map<String, CostMetric>> _yearMonthCategoryMetrics = {};
  // final Map<String, Map<String, CostMetric>> _summarizedYearMonthCategoryMetrics = {};
  final Map<String, Map<String, List<CostItem>>> _yearMonthCategoryGroupedList = {};

  final SplayTreeMap<String, List<CostItem>> _dailyCostItems = SplayTreeMap<String,List<CostItem>>((a,b) => 
    b.standardDateParse().compareTo(a.standardDateParse())
  );

  
  UnmodifiableMapView<String, List<CostItem>> get currentMonthDailyCostItems {
    final Map<String,List<CostItem>> currentMonthCostItem = Map.from(_dailyCostItems)..removeWhere((key, value) => !key.startsWith(formatedSelectedYearMonth));
    if (isFilteredActive) {
      final Map<String,List<CostItem>> temp = {};
      // debugPrint("this triggeredd!");
      currentMonthCostItem.forEach((key, value){
        bool isCategoryIncluded(CostItem costItem) => _filteredCategories.contains(costItem.category); 
        bool isFilterStringMatch(CostItem costItem) => _filteredString != null? costItem.name.contains(_filteredString!) : true; 
        bool isDateWithinFilter(CostItem costItem) => _filterDateRange != null? 
          costItem.getDateTime().isBefore(_filterDateRange!.end.add(Duration(days: 1))) && 
          costItem.getDateTime().isAfter(_filterDateRange!.start.subtract(Duration(days: 1))) : 
          true; 
        bool isMatch(CostItem costItem) => isCategoryIncluded(costItem) && isFilterStringMatch(costItem) && isDateWithinFilter(costItem);

        if (value.any(isMatch)) temp.putIfAbsent(key, () => []).addAll(value.where(isMatch)); 
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
    return UnmodifiableListView(_notes.where((note) => note.categoryName == category).toList());
  }

  List<double> getPercentiles() {
    final sortedAmountList = _filteredCostItems.map((costItem) => costItem.amount).toList()..sort((a,b) => a.compareTo(b));
    return [
      sortedAmountList[(0 * sortedAmountList.length).round()],
      sortedAmountList[(1/4 * sortedAmountList.length - 1/2).round()],
      sortedAmountList[(1/2 * sortedAmountList.length - 1/2).round()],
      sortedAmountList[(3/4 * sortedAmountList.length - 1/2).round()],
      sortedAmountList[(1 * sortedAmountList.length - 1).round()]
    ];
  }

  // filter items by month
  // date format: yyyy-MM-dd
  UnmodifiableListView<CostItem> get _filteredCostItems {
    return UnmodifiableListView(_costItems.where((costItem) {
      final costItemDate = costItem.getDateTime();
      final year = costItemDate.year;
      final month = costItemDate.month;
      return year == _selectedYearMonth.year && month == _selectedYearMonth.month;
    }
    ));
  }


  UnmodifiableListView<CostItem> get filteredCostItems => _filteredCostItems;

  UnmodifiableMapView<String,List<CostItem>> get currentCategoryList {
    return UnmodifiableMapView(_yearMonthCategoryGroupedList[formatedSelectedYearMonth]!);
  }

  UnmodifiableMapView<String,CostMetric> get yearMonthOverview => UnmodifiableMapView(_yearMonthMetrics);

  void updateFilterString(String? newString) {
    _filteredString = newString == "" ? null : newString;
    debugPrint('new string: $newString');
    notifyListeners();
  }

  // get daily total for bar chart
  UnmodifiableMapView<int, CostMetric> getDailyMetric(CostType costType, {int monthDifference = 0}) {
    int totalDays = selectedYearMonth.getTotalDayInMonth(pastMonth: monthDifference);
    return UnmodifiableMapView(
      Map.fromIterable(List.generate(totalDays, (day) => day),
        key: (i) => (i + 1),
        value: (i) {
          final formattedDate = DateTime(selectedYearMonth.year, selectedYearMonth.month - monthDifference, i + 1);
          return _dayMetrics[formattedDate.standardFormat()] ?? CostMetric(); 
        } 
      )
    );
  }

  // get cumulative total for line chart
  UnmodifiableMapView<int, double> getDailyCumulative(CostType costType, {int monthDifference = 0}) {
    double cumulative = 0;
    return UnmodifiableMapView(
      getDailyMetric(costType, monthDifference: monthDifference).map((int key, CostMetric value) {
        cumulative += value.expense ?? 0;
        return MapEntry(
          key, 
          cumulative
        );
      })
    );
  }

 
  // get cumulative average for line chart 
  UnmodifiableMapView<int, double> getCumulativeAverage(CostType costType, {int monthDifference = 0}) {
    return UnmodifiableMapView(
      getDailyCumulative(costType, monthDifference: monthDifference).map((int dayInt, double cumulativeTotal) {
        return MapEntry(dayInt, cumulativeTotal/dayInt);
      })
    );
  }

  UnmodifiableMapView<int, CostMetric> get currentDailyMetric => getDailyMetric(CostType.expense);
  UnmodifiableMapView<int, double> get currentCumulative => getDailyCumulative(CostType.expense);
  UnmodifiableMapView<int, double> get currentCumulativeAverage => getCumulativeAverage(CostType.expense);
  UnmodifiableMapView<int, double> get previousCumulative => getDailyCumulative(CostType.expense, monthDifference: 1);
  UnmodifiableMapView<int, double> get previousCumulativeAverage => getCumulativeAverage(CostType.expense, monthDifference: 1);

  UnmodifiableListView<Map<String,dynamic>> summarizedDateGroupDataForCustomCostType(CostType costType) {
    //create sorted list
    final tempList = getDailyMetric(costType).map((dateInt,metric) {
      return MapEntry<int,Map<String,dynamic>>(
        dateInt, 
        {
          "date": DateTime(_selectedYearMonth.year,_selectedYearMonth.month,dateInt).displayFormat(),
          "amount": metric.expense,
          "percentage": metric.expense!/totalCurrentMonthExpense
        }
      );
    }).values.toList()
      ..removeWhere((a) => a["amount"] == 0) // remove empty days
      ..sort((a,b) => (b["amount"] as double).compareTo((a["amount"] as double))); // sort days
    
    if (tempList.length <= 5) return UnmodifiableListView(tempList); 
    
    // add up amount beyond the 5 categories
    double otherAmount = 0;
    double otherPercentage = 0;
    int i = 4;
    for (i; i < tempList.length; i ++) {
      otherAmount += tempList[i]['amount'] as double;
      otherPercentage += tempList[i]['percentage'] as double;
    }

    final resultList = [...tempList.getRange(0, 4), {
      "date": "Other",
      "amount": otherAmount,
      "percentage": otherPercentage 
    }];
    
    return UnmodifiableListView(resultList);
  }

  String get currencySymbol => currencies.where((currency) =>
    currency['name'] == _currencyName 
  ).first['symbol'];

  String get thousandSeparator => currencies.where((currency) =>
    currency['name'] == _currencyName 
  ).first['thousands_separator'];

  String get decimalSeparator => currencies.where((currency) =>
    currency['name'] == _currencyName 
  ).first['decimal_separator'];

  String _currencyName = currencies.first['name'];
  String get currencyName => _currencyName;
  
  DateTime _selectedYearMonth = DateTime.now();
  DateTime get selectedYearMonth => _selectedYearMonth;
  String get formatedSelectedYearMonth => DateFormat('yyyy-MM').format(_selectedYearMonth);

  double calculateDailyTotal(String date, [CostType? costType]) {
    final dailyFilteredCostItems = _costItems.where((costItem) => costItem.date == date).toList();
    
    if (costType == null) { // not specify particular cost type, get balance
      double expense = calculateTotal(CostType.expense, dailyFilteredCostItems);
      double income = calculateTotal(CostType.income, dailyFilteredCostItems);
      return income - expense;
    } else {
      return calculateTotal(costType, dailyFilteredCostItems);
    }
  }
  
  void clearFilter() {
    updateFilterString(null);
    updateFilteredCategories(Set.from(categories.map((category)=> category.name)));
    updateFilteredDateRange(null, dateRangeFilterType.none);
    resetMetric();
    notifyListeners();
  }

  double getDailyTotal(String date) {
    if (isFilteredActive) {
      return currentMonthDailyCostItems[date]?.fold<double>(0, (double value, CostItem costItem) => value + costItem.getAbsoluteAmount()) ?? 0;
    } else {
      return _dayMetrics[date]?.balance?? 0;
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
      return _yearMonthMetrics[formatedSelectedYearMonth]?.expense ?? 0;
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
      return _yearMonthMetrics[formatedSelectedYearMonth]?.income ?? 0;
    }
  }
  
  Map<String,List<CostItem>> get currentMonthCategoryList => _yearMonthCategoryGroupedList[formatedSelectedYearMonth] ?? {};

  double get totalCurrentMonthbalance => totalCurrentMonthIncome - totalCurrentMonthExpense;

  double get totalBudget => 2000; 

  double get budgetPercentage => totalCurrentMonthExpense/totalBudget;
  
  double get remainingDayAverageSpend {
    final remainingDay = _selectedYearMonth.getTotalDayInMonth() - DateTime.now().day; 
    return (totalBudget - totalCurrentMonthExpense)/remainingDay;
  }

  Map<String,CostMetric> getcurrentMonthCategoryView(bool isDescending, CostType costType) {
    final initCategoryView = _yearMonthCategoryMetrics[formatedSelectedYearMonth] ?? {};

    final sorted = initCategoryView.entries.toList()..sort((a, b) {
      if (isDescending) {
        return b.value.expense!.compareTo(a.value.expense!); 
      } else {
        return a.value.expense!.compareTo(b.value.expense!);
      }
    })..removeWhere((item) => costType == CostType.expense ? item.value.expense == 0 : item.value.income == 0);

    return {for (var entry in sorted) entry.key: entry.value};
  }

  double getMaxCurrentMonthCategoryAmount(CostType costType) {
    return getcurrentMonthCategoryView(true, costType).entries.toList().first.value.expense!;
  }

  String getTotalAsString(String type, {bool useSuffix = false}) {
    switch (type) {
      case 'expense':
        return customCurrencyFormat(totalCurrentMonthExpense, useSuffix);
      case 'income':
        return customCurrencyFormat(totalCurrentMonthIncome, useSuffix) ;
      case 'balance':
        return  customCurrencyFormat(totalCurrentMonthbalance, useSuffix);
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
      final dayString = DateFormat("yyyy-MM-dd").format(DateTime(now.year, now.month, day));
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
    double percentage = categoryAmount/totalCurrentMonthExpense;
    if (percentage > 0.01) {
      return NumberFormat('#0%').format(percentage);
    } else {
      return "<1%";
    }
  }
  String customCurrencyFormat(double value, bool useSuffix, [bool? usePositiveSign, String? overrideSign]) {
    final String sign; 
    if (overrideSign != null) {
      sign = overrideSign;
    } else if (value < 0) {
      sign = "-";
    }  else if (usePositiveSign == true) {
      sign = "+";
    } else {
      sign = "";
    }

    String formatDecimal(double value, double div, String suffix) {
      if (value % div == 0) {
        return NumberFormat.compact(locale: _localeName).format(value / div);
      } else {
        return NumberFormat.compact(locale: _localeName).format(value);
      }
    }

    final absValue = value.abs();
    String rawString;
    if (useSuffix) {
      if (absValue > 1e9) {
        rawString =  formatDecimal(absValue,1e9,"b");
      } else if (absValue > 1e6) {
        rawString =  formatDecimal(absValue,1e6,"M");
      } else if (absValue > 1e3) {
        rawString =  formatDecimal(absValue,1e3,"k");
      } else {
        rawString =  formatDecimal(absValue,1,"");
      }
      rawString = '$sign$currencySymbol$rawString';
    } else {
      if (absValue % 1 == 0) {
        rawString =  NumberFormat("$sign$currencySymbol#,##0").format(absValue);
      } else {
        rawString =  NumberFormat("$sign$currencySymbol#,##0.00").format(absValue);
      }
    }
    return rawString
    .replaceAll(RegExp(r','), '!') // convert thousand & decimal separator to temp symbol first
    .replaceAll(RegExp(r'\.'), '?')
    .replaceAll(RegExp(r'!'), thousandSeparator)
    .replaceAll(RegExp(r'\?'), decimalSeparator);
  }

  void updateFilteredCategories(Set<String> newFilteredCategories) {
    _filteredCategories =  newFilteredCategories;
    debugPrint("new filtered categories: length: ${_filteredCategories.length}");
    notifyListeners();
  }

  void updateFilteredDateRange(DateTimeRange? newDateRange, dateRangeFilterType dateFilter) {
    _filterDateRange = newDateRange;
    _dateRangeFilter = dateFilter;
    notifyListeners();
  }
  void setInitSettings() async {
    // set currency setting in initial run
    // var format = NumberFormat.simpleCurrency(locale: Platform.localeName);
    // _currencySymbol = format.currencySymbol;

    // set initial month as current month
    _selectedYearMonth = DateTime.now();

    // add default categories
    _categories = [...defaultCostItemCategories];
    _filteredCategories.addAll(_categories.map((category) => category.name));
    
    final sharedPref = SharedPreferencesAsync();
    final sharedPrefCurrency = await sharedPref.getString('currency');

    if (sharedPrefCurrency != null) {
      _currencyName = sharedPrefCurrency;
    } else {
      _currencyName = currencies.first['name'];
    }
    

    // get file for cost items
    await loadCostItemOnLoad();

    // get note history
    await readNoteFromFile();
    
    resetMetric();
    debugPrint("refresh");
  }
  
  void changeCurrency(Map<String,dynamic> currency) {
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
        _selectedYearMonth = DateTime(_selectedYearMonth.year,_selectedYearMonth.month + 1);
      } else {
        _selectedYearMonth = DateTime(_selectedYearMonth.year,_selectedYearMonth.month - 1);
      }
    }
    notifyListeners();
  }

  void createNewCategories() {

  }

  void updateAppModel(ThemeModel themeModel) {
    //change datetime and number locale 
    _localeName = themeModel.appLocale.toLanguageTag();
    debugPrint("newLocale: $_localeName");
    notifyListeners();
  }

  // create a new item after form is submitted
  void createNewItem(CostItemFormResult result) {
    final newCostItem = CostItem.fromForm(result);
    
    // if (result.name.trim() != "") {
    //   createNewNoteHistory(NoteHistory(categoryName: result.category, note: result.name));
    // }
    
    if (_costItems.isEmpty) {
      _costItems.add(newCostItem);
    } else { // insert in descending order based on date 
      final size = _costItems.length;
      
      int i = 0;
      int insertIndex = size; // default to the end of array if the date is the earliest

      for (i; i < size; i++) {
        if (newCostItem.getDateTime().isAfter(_costItems[i].getDateTime())) {
          insertIndex = i;
          break;
        }
      }
      _costItems.insert(insertIndex, newCostItem);
    }
    addDailyCostItems(newCostItem);
    updateMetric(newCostItem);
    updateCategoryList(newCostItem.getYearMonthString());

    notifyListeners();
    writeCostItemsToFile();
  }

  void addDailyCostItems(CostItem newCostItem) {
    if (_dailyCostItems.containsKey(newCostItem.date)) {
      _dailyCostItems[newCostItem.date]!.insert(0,newCostItem);
    } else {
      _dailyCostItems[newCostItem.date] = [newCostItem];
    }
    notifyListeners();
  }

  void deleteDailyCostItems(CostItem oldCostItem) {
    _dailyCostItems[oldCostItem.date]!.removeWhere((costItem) => costItem.uuid == oldCostItem.uuid);
    notifyListeners();
  }

  void updateMetric(CostItem costItem) {
    // update day metrics
    _dayMetrics.putIfAbsent(costItem.date, () => CostMetric()).add(costItem);

    // update yearmonth metrics
    var yearMonthString = costItem.getYearMonthString();
    _yearMonthMetrics.putIfAbsent(yearMonthString, () => CostMetric()).add(costItem);

    // update yearmonth metric metrics
    _yearMonthCategoryMetrics
      .putIfAbsent(yearMonthString, () => {})
      .putIfAbsent(costItem.category, () => CostMetric())
      .add(costItem);

    notifyListeners();
  }

  void removeMetric(CostItem initCostItem) {
    _dayMetrics[initCostItem.date]!.minus(initCostItem);
    
    final yearMonthString = initCostItem.getYearMonthString();
    _yearMonthMetrics[yearMonthString]!.minus(initCostItem);

    _yearMonthCategoryMetrics[yearMonthString]![initCostItem.category]!.minus(initCostItem);
  }

  void updateCategoryList(String yearMonth) {
    final dateItem = _costItems.where((item) => 
      item.getYearMonthString() == yearMonth
    );
    _yearMonthCategoryGroupedList[yearMonth] = groupBy(dateItem, (item) => item.category);
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

    notifyListeners();
  }

  void clearMetric() {
    _yearMonthMetrics.clear();
    _dayMetrics.clear();
    _yearMonthCategoryMetrics.clear();
    _dailyCostItems.clear();
    notifyListeners();
  }

  void updateCostItem(CostItemFormResult result, String itemUuid) {
    final int initIndex = _costItems.indexWhere((costItem) => costItem.uuid == itemUuid);
    final CostItem initCostItem = _costItems.firstWhere((costItem) => costItem.uuid == itemUuid);
    final CostItem updatedCostItem = CostItem.update(result, itemUuid);
    // if (result.name.trim() != "") {
    //   createNewNoteHistory(NoteHistory(categoryName: result.category, note: result.name));
    // }

    // if date the same, no need to perform sorting
    if (_costItems[initIndex].date == result.date) {
      _costItems[initIndex] = updatedCostItem; 

    } else {
      _costItems.removeAt(initIndex);

      int insertIndex = _costItems.length;
      int i = initIndex - 1;
      final DateTime updatedDate = updatedCostItem.getDateTime();
      
      while (i >= 0 && i < _costItems.length) {
        // debugPrint("current i: $i");

        final afterDate = _costItems[i].getDateTime();
        
        if (updatedDate.isAfter(afterDate) || updatedDate.isAtSameMomentAs(afterDate)) {
          if (i == 0) { // first item, latest cost item
            insertIndex = i;
            break;
          } else if (updatedDate.isBefore(_costItems[i - 1].getDateTime()) 
            || updatedDate.isAtSameMomentAs(_costItems[i - 1].getDateTime())
          ) {
            insertIndex = i;
            break;
          } else { // prior date is 
            i --;
          }
        } else {
          i ++;
        }
      }
      _costItems.insert(insertIndex, updatedCostItem);

      removeMetric(initCostItem);
      updateMetric(updatedCostItem);
    }

    deleteDailyCostItems(initCostItem);
    addDailyCostItems(updatedCostItem);
    updateCategoryList(initCostItem.getYearMonthString());
    updateCategoryList(updatedCostItem.getYearMonthString());

    notifyListeners();
    writeCostItemsToFile();
  }

  void deleteCostItem(String costItemId) {
    final CostItem deletedCostItem = _costItems.where((costItem) => costItem.uuid == costItemId).first;
    _costItems.removeWhere((costItem) => costItem.uuid == costItemId);
    
    deleteDailyCostItems(deletedCostItem);
    removeMetric(deletedCostItem);
    updateCategoryList(deletedCostItem.getYearMonthString());
    notifyListeners();
    writeCostItemsToFile();
  }

  // convert cost item list into csv and 
  // update file 
  Future<void> writeCostItemsToFile() async {
    final List<List<dynamic>> result = List.generate(
      _costItems.length, 
      (i) => _costItems[i].toList()
    );

    const List<String> headers = [
      'uuid',
      'date',
      'costType',
      'category',
      'amount',
      'name',
    ];

    final String csv = '${headers.join(',')},\r\n${ListToCsvConverter().convert(result)}';

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/budget.csv');

      file.writeAsStringSync(csv);
    } catch (e)  {
      debugPrint("error finding file");
    }

    // try {
    //   await writeDataToFirebase();
    // } catch (e) {
    //   debugPrint("error writing data to firebase: $e");
    // }
  }

  Future<void> loadCostItemOnLoad() async {
    try {
      debugPrint("the file is red!");
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/budget.csv');
      parseCostItemData(file);
    } catch (e) {
      debugPrint("error reading file");
      return;
    }
  }

  Future<String?> exportCostItem() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/budget.csv');
      final csvString = file.readAsStringSync();
      final List<int> list = csvString.codeUnits;
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'budget_output.csv',
        bytes: Uint8List.fromList(list)
      );
      return outputFile;
    } catch (e) {
      debugPrint("error: $e");
      return null;
    }
  }

  Future<int> loadCostItemFromFile() async {
    try{
      final result = await FilePicker.platform.pickFiles(
        // allowedExtensions: ['csv'],
        // type: FileType.custom
      );
      if (result != null) {
        final file = File(result.files.single.path!);
        final parsedResult  = await parseCostItemData(file);
        if (parsedResult == 0) return 0;
        await writeCostItemsToFile();
        return 1;
      } 
      return 2;
    } catch (e) {
      debugPrint("error in loading data from file: $e");
      return 0;
    }
  }

  Future<int> parseCostItemData(File file) async {
    try {
      final csvString = file.readAsStringSync();
      final List<List<dynamic>> costItemLists = CsvToListConverter().convert(csvString);
      costItemLists.removeAt(0);
      _costItems = costItemLists.map((List<dynamic> item) => CostItem.fromList(item)).toList();
      notifyListeners();
      return 1;
    } catch (e) {
      debugPrint('error in parsing data: $e');
      return 0;
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
    if (index != -1) { // existing note
      _notes.removeAt(index); // remove old and push to first item
    }
    _notes.insert(0, newNote);
    
    // only keep a maximum of 100 latest note for memory sake
    while (_notes.length > 100) {
      _notes.removeLast();
    }

    // update the note history to file
    try {
      final Directory directory  = await getApplicationDocumentsDirectory();
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
      final Directory directory  = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/notes.txt');
      final noteFileString = file.readAsStringSync();
      
      // debugPrint("Read file: $noteFileString");
      _notes = (jsonDecode(noteFileString) as List).map((jsonObj) => 
        NoteHistory.fromJson(jsonObj as Map<String, dynamic>)
      ).toList(); 
    } catch (e) {
      debugPrint("error in reading note history file, error: $e");
    }
  }

  Future<void> writeDataToFirebase() async {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      // DocumentReference result =  await db.collection('costItem').add(user);
      db.collection('costItem')
        .doc('entry')
        // .update({'value':'new'})
        .update({'entry':_costItems.map((costItem) => costItem.toJson()).toList()})
        .then((_) =>
          debugPrint("Written data to firebase! Result")
        )
      ;
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

class CostItem {
  CostItem(
      this.name,
      this.amount,
      this.category,
    {
      this.uuid,
      required this.date,
      required this.costType,
    }
  );

  String? uuid;
  String category;
  String name;
  double amount;
  String date;
  CostType costType;

  // create a instance of cost item from form
  CostItem.fromForm(CostItemFormResult result) :
    uuid = Uuid().v4(),
    date = result.date,
    costType = result.costType,
    category = result.category,
    amount = result.amount,
    name  = result.name
  ;

  CostItem.update(CostItemFormResult result, String id) :
    uuid = id,
    date = result.date,
    costType = result.costType,
    category = result.category,
    amount = result.amount,
    name  = result.name
  ;

  // create cost item into json
  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'date': date,
    'costType': costType.name,
    'category': category,
    'amount': amount,
    'name': name,
  };

  // CostItem.fromJson(Map<String, dynamic> json) : 
  //   uuid = json['uuid'] as String,
  //   name = json['name'] as String,
  //   amount = json['amount'] as double,
  //   costType = CostType.values.where((costType) => costType.name == json['costType']).first,
  //   date = json['date'] as String;

  List<dynamic> toList() {
    final jsonObject = toJson();
    return List.generate(jsonObject.length, (i) => jsonObject.values.elementAt(i));
  }

  CostItem.fromList(List<dynamic> list) :
    uuid = list[0] as String,
    date = list[1] as String, 
    costType = CostType.values.where((costType) => costType.name == list[2] as String).first,
    category = list[3] as String,
    amount = list[4] as double,
    name = list[5] as String;

  DateTime getDateTime() => date.standardDateParse(); 
  String getYearMonthString() => date.substring(0,7); //DateFormat: yyyy-MM-dd

  String getCurrencyValue(String currencySymbol, [bool? includeSign]) {
    final String value = amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);
    final String? sign;
    if (includeSign == false) {
      sign = '';
    } else {
      sign = costType == CostType.expense? '-' : '+';
    }
    return '$sign $currencySymbol$value';
  }

  double getAbsoluteAmount() => costType == CostType.expense? 0 - amount: amount;
  // CostItemCategory get categoryItem {
  //   return AppModel().categories.where((categoryItem) => categoryItem.name == category).first;
  // }
}

enum CostType {
  expense,
  income,
}

class CostItemFormResult {
  CostItemFormResult(
    {
      required this.name,
      required this.category,
      required this.date,
      required this.costType,
      required this.amount
    }
  );

  String name;
  String category;
  String date;
  CostType costType;
  double amount;

}

class FormArgument {
  const FormArgument({
    required this.isNew,
    this.selectedCostItem
  });

  final bool isNew;
  final CostItem? selectedCostItem;
}

class CostItemCategory {
  const CostItemCategory({
    required this.name,
    required this.color,
    required this.imagePath,
    required this.costType
  });

  final String name;
  final Color color;
  final String imagePath;
  final CostType costType;

  ColorScheme get colorScheme {
    Brightness brightness;
    final themeMode = ThemeMode.dark;
    switch (themeMode) {
      case ThemeMode.dark:
        brightness = Brightness.dark;
      case ThemeMode.light:
        brightness = Brightness.light;
      default:
        brightness = PlatformDispatcher.instance.platformBrightness;
    } 

    // debugPrint("getColorScheme, brightness: ${brightness.name}, theme: ${themeMode}");
    return ColorScheme.fromSeed(
      seedColor: color,
      dynamicSchemeVariant: DynamicSchemeVariant.rainbow,
      contrastLevel: 0,
      brightness: brightness 
    );
  }

  Widget createIcon(double size, [Color? foregroundColor]) {
    final fg = foregroundColor ?? colorScheme.onPrimaryContainer; 
    return Image.asset(
      imagePath,
      color: fg,
      height: size,
      width: size,
    );
  }
  Widget generateRoundedIcon(double size, [Color? backgroundColor, Color? foregroundColor]) {
    final bg = backgroundColor ?? colorScheme.primaryContainer; 
    // final bg = backgroundColor ?? colorScheme.primary; 
    final fg = foregroundColor ?? colorScheme.onPrimaryContainer; 
    return Container(
      height: size + 12,
      width: size + 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bg.withValues(
              red: min<double>((bg.r + 20/255), 1),
              blue: min<double>((bg.b + 20/255), 1),
              green: min<double>((bg.g + 20/255), 1),
            ),
            bg,
            bg.withAlpha(100),

          ]
        ),
        // color: bg
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: createIcon(size, fg)
      ),
    );
  }

  // String getLocalizedName(BuildContext context) {
  //   final Map<String,dynamic> categoryJson = jsonDecode(AppLocalizations.of(context)!.categories);
  //   return categoryJson[name] ?? "NA";
  // }
}



class NoteHistory {
  const NoteHistory({required this.categoryName, required this.note});
  
  final String categoryName;
  final String note;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NoteHistory) return false;
      return categoryName == other.categoryName &&
        note == other.note;
  }
  @override
  int get hashCode => categoryName.hashCode ^ note.hashCode;

  NoteHistory.fromJson(Map<String,dynamic> json) :
    categoryName = json['categoryName'] as String,
    note = json['note'] as String;

  Map<String,String> toJson() => { 
    'categoryName' : categoryName,
    'note': note
  };
}

class CostMetric {
  CostMetric({
    this.expense = 0,
    this.income = 0,
  });

  double? expense;
  double? income;
  
  get balance => (income ?? 0) - (expense ?? 0);

  // CostMetric.update(CostMetric initMetric, double newExpense, double newIncome): 
  //   expense =  initMetric.expense! + newExpense,
  //   income = initMetric.income! + newIncome;

  void add(CostItem costItem) {
    expense = expense! + (costItem.costType == CostType.expense ? costItem.amount: 0); 
    income = income! + (costItem.costType == CostType.income ? costItem.amount: 0);
  }

  void minus(CostItem costItem) {
    expense = expense! - (costItem.costType == CostType.expense ? costItem.amount: 0); 
    income = income! - (costItem.costType == CostType.income ? costItem.amount: 0);
  }
}


class CategoryGroupMetric {
  const CategoryGroupMetric({
    this.costItem,
    this.metric,
  });

  final List<CostItem>? costItem;
  final CostMetric? metric;
}

class RelativeDateRange {
  RelativeDateRange({
    required this.name, 
    required this.startDate, 
    required this.endDate
  });

  final String name;
  final DateTime startDate;
  final DateTime endDate;

  RelativeDateRange.toCurrent({required this.name, required this.startDate}) :
    endDate = DateTime.now();
}

enum dateRangeFilterType {
  relative,
  absolute,
  none
}
import 'dart:convert';
import 'dart:io';

import 'package:budget_tracker/categories.dart';
import 'package:budget_tracker/currency.dart';
import 'package:budget_tracker/extensions.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppModel extends ChangeNotifier {

  AppModel(){
    setInitSettings();
  }

  String _localeName = "en";

  List<CostItem> _costItems = [];
  UnmodifiableListView<CostItem> get costItems => UnmodifiableListView(_costItems);

  List<CostItemCategory> _categories = [];
  UnmodifiableListView<CostItemCategory> get categories => UnmodifiableListView(_categories);

  List<NoteHistory> _notes = [];
  UnmodifiableListView<NoteHistory> notes(String? category) {
    if (category == null) return UnmodifiableListView([]);
    return UnmodifiableListView(
      _notes.where((note) => note.categoryName == category).toList()
    );
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

  UnmodifiableMapView<String, List<CostItem>> get dateGroupedItem {
    if (_filteredCostItems.isNotEmpty) {
      return UnmodifiableMapView(
        groupBy(_filteredCostItems, (item) => item.date)
      );
    } else {
      return UnmodifiableMapView({}); // return empty map
    }
  }

  UnmodifiableListView<Map<String,dynamic>> get categoryGroupedData {
    if (_filteredCostItems.isEmpty) return UnmodifiableListView([]); // return empty map
    
    return UnmodifiableListView(
      groupBy(_filteredCostItems, (item) => item.category).map((category, costItems) {
        final categoryAmount = calculateTotal(costItems.first.costType, costItems); 
        final totalAmount = calculateTotal(costItems.first.costType, _filteredCostItems); 
        return MapEntry<String,Map<String,dynamic>>(
          category, 
          {
            'name': category,
            'amount': categoryAmount,
            'percentage': categoryAmount/totalAmount,
            'items' : costItems..sort((a,b) => b.amount.compareTo(a.amount)), // sort descending
            'category' : getCategoryEntry(category)
          }
        );
      }).values.toList()
    );
  }

  UnmodifiableListView<Map<String,dynamic>> categoryGroupDataForCustomCostType(CostType customCostType) {
    if (categoryGroupedData.isEmpty) return UnmodifiableListView([]); // return empty map
    
    // filter items by cost tyle
    final temp = [...categoryGroupedData];
    temp.removeWhere((Map category) => 
      defaultCostItemCategories.where((CostItemCategory categoryEntry) => 
        category['name'] == categoryEntry.name
      ).first.costType != customCostType
    );

    // sort key by amount (descending)
    temp.sort((a, b) => 
      (b['amount'] as double).compareTo((a['amount'] as double)),
    );

    // return map with sorted key 
    return UnmodifiableListView<Map<String,dynamic>>(temp);
  }

  UnmodifiableListView<Map<String,dynamic>> summarizedCategoryGroupDataForCustomCostType(CostType customCostType) {
    if (categoryGroupedData.isEmpty) return UnmodifiableListView([]); // return empty map
    
    final initList = categoryGroupDataForCustomCostType(customCostType); 
    // get only the top 5 category by amount
    // if category less than 5, then return the ori list 
    if (initList.length <= 5) return initList; 

    // add up amount beyond the 5 categories
    double otherAmount = 0;
    double otherPercentage = 0;
    int i = 4;
    for (i; i < initList.length; i ++) {
      otherAmount += initList[i]['amount'] as double;
      otherPercentage += initList[i]['percentage'] as double;
    }

    final resultList = [...initList.getRange(0, 4), {
        "name": "Other",
        "amount": otherAmount,
        "percentage": otherPercentage 
      }]
    ;
    
    return UnmodifiableListView(resultList);
  }

  UnmodifiableListView<Map<String,dynamic>> get monthlyOverview {
    // grouped by year & month, yyyy-MM
    final monthGroupedMap = groupBy(_costItems, (item) => item.date.substring(0,7));
    return UnmodifiableListView<Map<String,dynamic>>(
      monthGroupedMap.map((month, monthlyCostItems) {
        return MapEntry(
          month, 
          {
            "month": month,
            "expense": calculateTotal(CostType.expense, monthlyCostItems), 
            "income": calculateTotal(CostType.income, monthlyCostItems), 
            "balance": calculateTotal(CostType.income, monthlyCostItems) - calculateTotal(CostType.expense, monthlyCostItems), 
          }
        );
      }).values
    );
  }

  // get daily total
  // to display via bar chart
  UnmodifiableListView<double> getDailyTotalList(CostType costType, {int monthDifference = 0}) {
    int totalDays = getDayRange(monthDifference: monthDifference);

    return UnmodifiableListView(
      List<double>.generate(totalDays, (day) {
          final dateString = DateTime(
            _selectedYearMonth.year,
            _selectedYearMonth.month + monthDifference,
            day + 1
          ).standardFormat();

          return calculateDailyTotal(dateString, costType);
        }
      )
    );
  }

  int getDayRange({int monthDifference = 0}) {
    int totalDays;
    // if calculating value for this month, show up to latest data only
    if (monthDifference == 0 && _selectedYearMonth.month == DateTime.now().month) {
      // generate graph until latest date where there is entry (prioritized)
      // else get up to today
      if (_filteredCostItems.first.getDateTime().isAfter(_selectedYearMonth)) {
        totalDays = _filteredCostItems.first.getDateTime().day;
      } else {
        totalDays = _selectedYearMonth.day;
      }
    } else {
      totalDays = _selectedYearMonth.getTotalDayInMonth(monthDif: monthDifference);
    }
    return totalDays;
  }

  // get cumulative total
  UnmodifiableListView<double> getDailyCumulativeTotalList(CostType costType, {int monthDifference = 0}) {
    double cumulative = 0;
    return UnmodifiableListView(
      getDailyTotalList(costType, monthDifference: monthDifference).map((double dailyTotal) {
        cumulative += dailyTotal;
        return cumulative;
      })
    );
  }

  // get cumulative divided by the number of day (normaized)
  UnmodifiableListView<double> getDailyCumulativeAverageList(CostType costType, {int monthDifference = 0}) {
    return UnmodifiableListView(
      getDailyCumulativeTotalList(costType, monthDifference: monthDifference).asMap().map((int dayInt, double cumulativeTotal) {
        return MapEntry(dayInt, cumulativeTotal/(dayInt+1));
      }).values.toList()
    );
  }

  UnmodifiableListView<Map<String,dynamic>> summarizedDateGroupDataForCustomCostType(CostType costType) {
    //create sorted list
    final tempList = getDailyTotalList(costType).asMap().map((dateInt,amount) {
      return MapEntry<int,Map<String,dynamic>>(
        dateInt, 
        {
          "date": DateTime(_selectedYearMonth.year,_selectedYearMonth.month,dateInt).displayFormat(),
          "amount": amount,
          "percentage": amount/totalCurrentMonthExpense
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

  double maximumCategoryAmount(CostType providedCostType) {
    double max = 0;
    for (var i in categoryGroupDataForCustomCostType(providedCostType)) {
      final double categoryAmount = i['amount'] as double;

      if (categoryAmount > max) {
        max = categoryAmount;
      }
    }
    return max;
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
  
  String getFormattedDailyTotal(String date) {
    final double total = calculateDailyTotal(date);
    return customFormatAmount(total, false, true);
  }

  // return accumulated expense
  double get totalCurrentMonthExpense => calculateTotal(CostType.expense, _filteredCostItems); 

  double get totalCurrentMonthIncome => calculateTotal(CostType.income, _filteredCostItems);

  double get totalCurrentMonthbalance => totalCurrentMonthIncome - totalCurrentMonthExpense;

  double get totalBudget => 2000; 

  double get budgetPercentage => totalCurrentMonthExpense/totalBudget;
  
  double get remainingDayAverageSpend {
    final remainingDay = _selectedYearMonth.getTotalDayInMonth() - DateTime.now().day; 
    return (totalBudget - totalCurrentMonthExpense)/remainingDay;
  }


  String getTotalAsString(String type, {bool useSuffix = false}) {
    switch (type) {
      case 'expense':
        return customFormatAmount(totalCurrentMonthExpense, useSuffix);
      case 'income':
        return customFormatAmount(totalCurrentMonthIncome, useSuffix) ;
      case 'balance':
        return  customFormatAmount(totalCurrentMonthbalance, useSuffix);
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
      return customFormatAmount(costItem.amount, false, true, "-");
    } else {
      return customFormatAmount(costItem.amount, false, true, "+");
    }
  }

  CostItemCategory getCategoryEntry(String categoryname) => 
    categories.where((categoryItem) => categoryItem.name == categoryname).first;
  
  String customFormatAmount(double value, bool useSuffix, [bool? usePositiveSign, String? overrideSign]) {
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
        // return NumberFormat("$sign$currencySymbol#0$suffix").format(value / div);
        return NumberFormat.compact(locale: _localeName).format(value / div);
      } else {
        // return NumberFormat("$sign$currencySymbol#.00$suffix").format(value / div);
        // return NumberFormat.compact(locale: _localeName).format(value / div);
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

  void setInitSettings() async {
    // set currency setting in initial run
    // var format = NumberFormat.simpleCurrency(locale: Platform.localeName);
    // _currencySymbol = format.currencySymbol;

    // set initial month as current month
    _selectedYearMonth = DateTime.now();

    // add default categories
    _categories = [...defaultCostItemCategories];
    
    final sharedPref = SharedPreferencesAsync();
    final sharedPrefCurrency = await sharedPref.getString('currency');

    if (sharedPrefCurrency != null) {
      _currencyName = sharedPrefCurrency;
    } else {
      _currencyName = currencies.first['name'];
    }
    // get file for cost items
    readCostItemsFromFile();

    // get note history
    readNoteFromFile();
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
    
    if (result.name.trim() != "") {
      createNewNoteHistory(NoteHistory(categoryName: result.category, note: result.name));
    }
    
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
      _costItems.insert(insertIndex,newCostItem);
    }

    notifyListeners();
    writeCostItemsToFile();
  }

  void updateCostItem(CostItemFormResult result, String itemUuid) {
    final int initIndex = _costItems.indexWhere((costItem) => costItem.uuid == itemUuid);
    final CostItem updatedCostItem = CostItem.update(result, itemUuid);

    if (result.name.trim() != "") {
      createNewNoteHistory(NoteHistory(categoryName: result.category, note: result.name));
    }

    // if date the same, no need to perform sorting
    if (_costItems[initIndex].date == result.date) {
      _costItems[initIndex] = updatedCostItem; 

    } else {
      _costItems.removeAt(initIndex);

      int insertIndex = _costItems.length;
      int i = initIndex - 1;
      final DateTime updatedDate = updatedCostItem.getDateTime();
      
      while (i >= 0 && i < _costItems.length) {
        debugPrint("current i: $i");

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

    }

    notifyListeners();
    writeCostItemsToFile();
  }

  void deleteCostItem(String costItemId) {
    _costItems.removeWhere((costItem) => costItem.uuid == costItemId);
    
    writeCostItemsToFile();
    notifyListeners();
  }

  // convert cost item list into csv and 
  // update file 
  void writeCostItemsToFile() async {
    final List<List<dynamic>> result = List.generate(
      _costItems.length, 
      (i) => _costItems[i].toList()
    );
    final String csv = ListToCsvConverter().convert(result);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/budget.csv');

      file.writeAsStringSync(csv);
    } catch (e)  {
      debugPrint("error finding file");
    }
  }

  void readCostItemsFromFile() async {
    try {
      debugPrint("the file is red!");
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/budget.csv');

      final csvString = file.readAsStringSync();
      final List<List<dynamic>> costItemLists = CsvToListConverter().convert(csvString);

      _costItems = costItemLists.map((List<dynamic> item) => CostItem.fromList(item)).toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint("error reading file");
      return null;
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

  void readNoteFromFile() async {
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
    name  = result.name,
    amount = result.amount,
    uuid = Uuid().v4(),
    category = result.category,
    date = result.date,
    costType = result.costType
  ;

  CostItem.update(CostItemFormResult result, String id) :
    name  = result.name,
    amount = result.amount,
    uuid = id,
    category = result.category,
    date = result.date,
    costType = result.costType
  ;

  // create cost item into json
  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'category': category,
    'costType': costType.name,
    'amount': amount,
    'date': date,
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
    category = list[1] as String,
    costType = CostType.values.where((costType) => costType.name == list[2] as String).first,
    amount = list[3] as double,
    date = list[4] as String, 
    name = list[5] as String;

  DateTime getDateTime() => date.standardDateParse();

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
      dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
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
        color: bg
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: createIcon(size, fg)
      ),
    );
  }

  String getLocalizedName(BuildContext context) {
    final Map<String,dynamic> categoryJson = jsonDecode(AppLocalizations.of(context)!.categories);
    return categoryJson[name] ?? "NA";
  }
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


import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/extensions.dart';
// import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:flutter/material.dart';

class ListModel extends ChangeNotifier {
  ListModel({required CostItemRepository costItemRepo}) : _costItemRepository = costItemRepo {
    init();
  }

  Future<void> init() async {
    _isInitialized = false;

    await _costItemRepository.ready;
    getCurMonthData();

    _isInitialized = true;
    debugPrint("viewmodel done");
    notifyListeners();
  }

  final CostItemRepository _costItemRepository;

  bool _isInitialized = false;
  bool get ready => _isInitialized;

  DateTime _curYearMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime get currentMonth => _curYearMonth;

  bool _isSearchOpened = false;
  bool get isSearchOpened => _isSearchOpened;

  bool _isBlurred = false;
  bool get isBlurred => _isBlurred;

  String _searchText = "";

  Map<DateTime, List<CostItem>> _dayGroupedCostItems = {};

  Map<DateTime, CostMetric> _dailySummary = {};
  Map<DateTime, CostMetric> get dailySummary => _dailySummary;

  CostMetric _totalSummary = CostMetric();
  CostMetric get monthSummary => _totalSummary;

  Map<DateTime, List<CostItem>> get outputCostItems {
    if (_searchText == "") return _dayGroupedCostItems;
    final filteredItems = _dayGroupedCostItems.map(
      (key, value) => MapEntry(key, value.where((item) => item.name.contains(_searchText)).toList()),
    );
    return Map.fromEntries(filteredItems.entries.where((entry) => entry.value.isNotEmpty));
  }

  Map<DateTime, CostMetric> get outputDailySummary {
    return outputCostItems.map((key, value) => MapEntry(key, CostMetric.fromCostItemList(value)));
  }

  void getCurMonthData() {
    _dayGroupedCostItems = Map.fromEntries(
      _costItemRepository.gbDateCostItems.entries.where(
        (entry) => entry.key.isInSameYearMonthAs(_curYearMonth),
      ),
    );

    _dailySummary = Map.fromEntries(
      _costItemRepository.daySummary.entries.where(
        (entry) => entry.key.isInSameYearMonthAs(_curYearMonth),
      ),
    );

    _totalSummary = _costItemRepository.monthSummary[_curYearMonth] ?? CostMetric();

    notifyListeners();
  }

  void updateSearch(String searchValue) {
    _searchText = searchValue;

    notifyListeners();
  }

  void changeYearMonth(DateTime newYearMonth) {
    _curYearMonth = newYearMonth;
    getCurMonthData();
    notifyListeners();
  }

  // void searchCostItem() {
  //   updateSearch(searchValue)
  // }

  void toggleSearch([bool? value]) {
    if (value != null) {
      _isSearchOpened = value;
    } else {
      _isSearchOpened = !_isSearchOpened;
    }
    notifyListeners();
  }

  void toggleBlur({bool? value}) {
    if (value != null) {
      _isBlurred = value;
    } else {
      _isBlurred = !_isBlurred;
    }
    notifyListeners();
  }
}

import 'dart:math';

import 'package:budget_tracker/constants/categories.dart';
import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/data/repos/category_repository.dart';
// import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class ListModel extends ChangeNotifier {
  ListModel({required CostItemRepository costItemRepo, required CategoryRepository categoryRepo})
    : _costItemRepo = costItemRepo,
      _categoryRepo = categoryRepo {
    init();
  }

  Future<void> init() async {
    _isInitialized = false;

    await _costItemRepo.ready;
    await _categoryRepo.ready;
    getCurMonthData();

    _isInitialized = true;
    debugPrint("viewmodel done");
    notifyListeners();
  }

  final CostItemRepository _costItemRepo;
  final CategoryRepository _categoryRepo;

  bool _isInitialized = false;
  bool get ready => _isInitialized;

  bool _selectionMode = false;
  bool get selectionMode => _selectionMode;

  List<CostItem> _selectedItems = [];
  UnmodifiableListView<CostItem> get selectedItems => UnmodifiableListView(_selectedItems);

  DateTime _curYearMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime get currentMonth => _curYearMonth;

  bool _isSearchOpened = false;
  bool get isSearchOpened => _isSearchOpened;

  bool _isBlurred = false;
  bool get isBlurred => _isBlurred;

  List<String> _filteredCategories = [];
  UnmodifiableListView<String> get filteredCategories => UnmodifiableListView(_filteredCategories);

  String _searchText = "";

  Map<DateTime, List<CostItem>> _dayGroupedCostItems = {};

  Map<DateTime, CostMetric> _dailySummary = {};
  Map<DateTime, CostMetric> get dailySummary => _dailySummary;

  // CostMetric _totalSummary = CostMetric();
  // CostMetric get monthSummary => _totalSummary;

  Map<DateTime, List<CostItem>> get outputCostItems {
    final sorted = _dayGroupedCostItems.map(
      (key, value) =>
          MapEntry(key, value.sorted((a, b) => b.lastModified!.compareTo(a.lastModified!))),
    );
    if (_searchText == "") return sorted;
    final filteredItems = sorted.map(
      (key, value) => MapEntry(
        key,
        value.where((item) {
          final bool searchQuery = _searchText.isNotEmpty ? item.name.contains(_searchText) : true;
          final bool categoryQuery =
              _filteredCategories.isNotEmpty ? _filteredCategories.contains(item.category) : true;
          return searchQuery && categoryQuery;
        }).toList(),
      ),
    );
    return Map.fromEntries(filteredItems.entries.where((entry) => entry.value.isNotEmpty));
  }

  Map<DateTime, CostMetric> get outputDailySummary {
    return outputCostItems.map((key, value) => MapEntry(key, CostMetric.fromCostItemList(value)));
  }

  CostMetric get outputMonthSummary {
    double income = 0;
    double expense = 0;
    for (final entry in outputDailySummary.entries) {
      income += entry.value.income ?? 0;
      expense += entry.value.expense ?? 0;
    }
    return CostMetric(income: income, expense: expense);
  }

  Map<DateTime, CostMetric> get monthlyOverview => _costItemRepo.monthSummary;

  void getCurMonthData() {
    _dayGroupedCostItems = Map.fromEntries(
      _costItemRepo.gbDateCostItems.entries
          .where(
            (entry) => entry.key.isInSameYearMonthAs(_curYearMonth),
          )
          .sorted((a, b) => b.key.compareTo(a.key)),
    );

    _dailySummary = Map.fromEntries(
      _costItemRepo.daySummary.entries.where(
        (entry) => entry.key.isInSameYearMonthAs(_curYearMonth),
      ),
    );

    // _totalSummary = _costItemRepo.monthSummary[_curYearMonth] ?? CostMetric();

    // debugPrint('get curMonth data loaded, total: ${_totalSummary.balance}');

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

  void toggleCategoryFilter(String id, bool selected) {
    if (selected) {
      _filteredCategories.add(id);
    } else {
      _filteredCategories.remove(id);
    }
    notifyListeners();
  }

  void toggleAllCategoryFilter(bool selected) {
    if (selected) {
      _filteredCategories.addAll(_categoryRepo.categories.map((el) => el.id!));
    } else {
      _filteredCategories.clear();
    }
    notifyListeners();
  }

  void toggleSelectionMode(bool value) {
    _selectionMode = value;
    if (!value) {
      _selectedItems.clear();
    }
    notifyListeners();
  }

  void updateSelection(CostItem item, bool selected) {
    if (selected) {
      _selectedItems.add(item);
    } else {
      _selectedItems.removeWhere((el) => el.uuid == item.uuid);
    }
    notifyListeners();
  }

  Future<void> deleteSelectedItems() async {
    for (CostItem item in _selectedItems) {
      await _costItemRepo.deleteCostItem(item);
    }
    _selectionMode = false;
    notifyListeners();
  }

  double get maxAmount =>
      _costItemRepo.costItems.fold(0, (init, item) => max(init, item.signedAmount));
  double get minAmount =>
      _costItemRepo.costItems.fold(0, (init, item) => min(init, item.signedAmount));
}

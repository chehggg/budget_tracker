import 'dart:math';

import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class ListViewModel extends ChangeNotifier {
  ListViewModel({
    required CostItemRepository costItemRepo,
    required CategoryRepository categoryRepo,
    required CurrencyRepository currencyRepo,
  }) : _costItemRepo = costItemRepo,
       _currencyRepo = currencyRepo,
       _categoryRepo = categoryRepo {
    init();
  }
  final CostItemRepository _costItemRepo;
  final CategoryRepository _categoryRepo;
  final CurrencyRepository _currencyRepo;

  Future<void> init() async {
    await _costItemRepo.ready;
    await _categoryRepo.ready;
    await _currencyRepo.ready;

    _isInitialized = true;
    notifyListeners();
  }

  bool _isInitialized = false;
  bool get ready => _isInitialized;

  bool _selectionMode = false;
  bool get selectionMode => _selectionMode;

  final List<CostItem> _selectedItems = [];
  UnmodifiableListView<CostItem> get selectedItems => UnmodifiableListView(_selectedItems);

  DateTime _curYearMonth = DateTime.now().startOfMonth;
  DateTime get currentMonth => _curYearMonth;

  bool _isSearchOpened = false;
  bool get isSearchOpened => _isSearchOpened;

  bool _isBlurred = false;
  bool get isBlurred => _isBlurred;

  List<String> _filteredCategories = [];
  UnmodifiableListView<String> get filteredCategories => UnmodifiableListView(_filteredCategories);

  String _searchText = "";

  Map<DateTime, List<CostItem>> get outputCostItems {
    final sorted = curMonthGbDateCostItems.map(
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
    final summary = outputCostItems.map(
      (key, value) => MapEntry(key, CostMetric.fromCostItemList(value)),
    );
    return summary;
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

  Map<DateTime, List<CostItem>> get curMonthGbDateCostItems => Map.fromEntries(
    _costItemRepo.gbDateCostItems.entries
        .where(
          (entry) => entry.key.isInSameYearMonthAs(_curYearMonth),
        )
        .sorted((a, b) => b.key.compareTo(a.key)),
  );

  CostItemCategory findCatInList(CostItem item) {
    return _categoryRepo.categories.firstWhereOrNull(
          (category) => category.id == item.categoryId,
        ) ??
        CostItemCategory.error();
  }

  void updateSearch(String searchValue) {
    _searchText = searchValue;

    notifyListeners();
  }

  void changeYearMonth(DateTime newYearMonth) {
    _curYearMonth = newYearMonth;
    notifyListeners();
  }

  void toggleSearch([bool? value]) {
    if (value != null) {
      _isSearchOpened = value;
    } else {
      _isSearchOpened = !_isSearchOpened;
    }
    if (!_isSearchOpened) {
      _searchText = "";
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
    _selectedItems.clear();
    notifyListeners();
  }

  double get maxAmount =>
      _costItemRepo.costItems.fold(0, (init, item) => max(init, item.signedAmount));
  double get minAmount =>
      _costItemRepo.costItems.fold(0, (init, item) => min(init, item.signedAmount));

  String Function(
    double value, {
    bool abbreviated,
    bool alwaysShowSign,
    bool compact,
    int? decimalDigits,
  })
  get currencyFormat => _currencyRepo.formatCurrency;
}

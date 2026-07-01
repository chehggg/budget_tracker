import 'dart:async';
import 'dart:math';

import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/enums/match_type.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:budget_tracker/data/repos/shared_element_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class ListViewModel extends ChangeNotifier {
  ListViewModel({
    required CostItemRepository costItemRepo,
    required CategoryRepository categoryRepo,
    required CurrencyRepository currencyRepo,
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

  Future<void> init() async {
    await _costItemRepo.ready;
    await _categoryRepo.ready;
    await _currencyRepo.ready;

    // _curYearMonth = _sharedRepo.displayDate;

    _isInitialized = true;

    _itemSubscription = _costItemRepo.valueStream.listen((value) {
      debugPrint("subscription trigger refresh for cost items.");
      _curYearMonth = value.date ?? DateTime.now().startOfMonth;
      notifyListeners();
    });

    _currencySubscription = _currencyRepo.currencyStream.listen((value) {
      debugPrint("currency trigger refresh.");
      notifyListeners();
    });

    notifyListeners();
  }

  StreamSubscription<CostItemRepoDataStream>? _itemSubscription;
  StreamSubscription<Currency>? _currencySubscription;

  bool _isInitialized = false;
  bool get ready => _isInitialized;

  bool _selectionMode = false;
  bool get selectionMode => _selectionMode;

  NumRangeMatchType? _rangeMatch;
  NumRangeMatchType? get numberRange => _rangeMatch;

  final List<CostItem> _selectedItems = [];
  UnmodifiableListView<CostItem> get selectedItems => UnmodifiableListView(_selectedItems);

  DateTime _curYearMonth = DateTime.now().startOfMonth;
  DateTime get currentMonth => _curYearMonth;

  bool _isSearchOpened = false;
  bool get isSearchOpened => _isSearchOpened;

  bool _isBlurred = false;
  bool get isBlurred => _isBlurred;

  List<CostItemCategory> _filteredCategories = [];
  UnmodifiableListView<CostItemCategory> get filteredCategories =>
      UnmodifiableListView(_filteredCategories);

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
          final bool searchQuery =
              (_searchText.isNotEmpty ? item.name?.toLowerCase().contains(_searchText.toLowerCase()) : true) ?? true;
          final bool categoryQuery =
              _filteredCategories.isNotEmpty
                  ? _filteredCategories.map((cat) => cat.id).contains(item.categoryId)
                  : true;
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
    _sharedRepo.updateDisplayDate(newYearMonth);
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
      _filteredCategories.clear();
      _rangeMatch = null;
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

  void updateCategoryFilter(List<CostItemCategory> categories) {
    _filteredCategories = categories;
    notifyListeners();
  }

  // void toggleCategoryFilter(String id, bool selected) {
  //   if (selected) {
  //     _filteredCategories.add(id);
  //   } else {
  //     _filteredCategories.remove(id);
  //   }
  //   notifyListeners();
  // }

  // void toggleAllCategoryFilter(bool selected) {
  //   if (selected) {
  //     _filteredCategories.addAll(_categoryRepo.categories.map((el) => el.id!));
  //   } else {
  //     _filteredCategories.clear();
  //   }
  //   notifyListeners();
  // }

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
      _costItemRepo.costItems.fold(0, (init, item) => max(init, item.absoluteAmount));
  double get minAmount =>
      _costItemRepo.costItems.fold(0, (init, item) => min(init, item.absoluteAmount));

  String Function(
    double value, {
    bool abbreviated,
    bool alwaysShowSign,
    bool compact,
    int? decimalDigits,
  })
  get currencyFormat => _currencyRepo.formatCurrency;
}

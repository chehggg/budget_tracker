import 'dart:async';
import 'dart:math';

import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
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
    await _sharedRepo.ready;

    _itemSubscription = _costItemRepo.valueStream.listen((value) {
      debugPrint("subscription trigger refresh for cost items.");
      // _curYearMonth = value.date ?? DateTime.now().startOfMonth;
      // _refresh = (value.date ?? DateTime.now()).millisecondsSinceEpoch;
      updateYearMonth(YearMonth(useRange: false, date1: value.date?? DateTime.now()));
      getScrollPosition(value.date?? DateTime.now());
      _refresh = DateTime.now().millisecondsSinceEpoch;
      notifyListeners();
    });

    _currencySubscription = _currencyRepo.currencyStream.listen((value) {
      debugPrint("currency trigger refresh.");
      notifyListeners();
    });

    _categorySubscription = _categoryRepo.categoryStream.listen((value) {
      notifyListeners();
    });

    _sharedElSubscription = _sharedRepo.sharedStream.listen((value) {
      debugPrint("shared subscription trigger refresh for list.");
      notifyListeners();
    });

    _sharedDateSubscription = _sharedRepo.sharedDateStream.listen((value) {
      if (_sharedRepo.syncDate) {
        _yearMonth = value;
        notifyListeners();
      }
    });

    _isBlurred = displayConfig.hideAmountOnStart;

    _isInitialized = true;
    notifyListeners();
  }

  StreamSubscription<bool>? _sharedElSubscription;
  StreamSubscription<YearMonth>? _sharedDateSubscription;
  StreamSubscription<CostItemRepoDataStream>? _itemSubscription;
  StreamSubscription<Currency>? _currencySubscription;
  StreamSubscription<List<CostItemCategory>>? _categorySubscription;

  bool _isInitialized = false;
  bool get ready => _isInitialized;

  bool _selectionMode = false;
  bool get selectionMode => _selectionMode;

  int _refresh = 0;
  int get scrollRefresh => _refresh;

  double _scrollPosition = 0;
  double get scrollPosition => _scrollPosition;
  // NumRangeMatchType? _rangeMatch;
  // NumRangeMatchType? get numberRange => _rangeMatch;

  RangeValues? _priceRange;
  RangeValues? get priceRange => _priceRange;

  final List<CostItem> _selectedItems = [];
  UnmodifiableListView<CostItem> get selectedItems => UnmodifiableListView(_selectedItems);

  YearMonth _yearMonth = YearMonth(useRange: false, date1: DateTime.now().startOfMonth);
  YearMonth get currentYearMonth => _yearMonth;

  DateTimeRange? _currentRange;
  DateTimeRange? get currentRange => _currentRange;

  Set<CostType>? _types;
  Set<CostType>? get types => _types;

  bool _isSearchOpened = false;
  bool get isSearchOpened => _isSearchOpened;

  bool _isBlurred = false;
  bool get isBlurred => _isBlurred;

  List<CostItemCategory>? _filteredCategories;
  UnmodifiableListView<CostItemCategory>? get filteredCategories =>
      _filteredCategories != null ? UnmodifiableListView(_filteredCategories!) : null;

  String _searchText = "";

  ListDisplayConfig get displayConfig => _sharedRepo.listScreenConfig;

  AccentColor get accentColors => _sharedRepo.accentColors;

  Map<DateTime, List<CostItem>> get outputCostItems {
    final sorted = curMonthGbDateCostItems.map(
      (key, value) =>
          MapEntry(key, value.sorted((a, b) => b.lastModified!.compareTo(a.lastModified!))),
    );
    // if (_searchText == "") return sorted;
    final filteredItems = sorted.map(
      (key, value) => MapEntry(
        key,
        value.where((item) {
          final bool rangeQuery =
              (_priceRange != null
                  ? ((item.amount ?? 0) <= _priceRange!.end &&
                      (item.amount ?? 0) >= _priceRange!.start)
                  : true);
          final bool searchQuery =
              (_searchText.isNotEmpty
                  ? item.name?.toLowerCase().contains(_searchText.toLowerCase()) ?? false
                  : true);
          final bool categoryQuery =
              _filteredCategories != null
                  ? _filteredCategories!.map((cat) => cat.id).contains(item.categoryId)
                  : true;
          return rangeQuery && searchQuery && categoryQuery;
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
          (entry) {
            return _yearMonth.isWithin(entry.key);
          },
        )
        .sorted((a, b) => b.key.compareTo(a.key)),
  );

  // void scrollToPositionAfterEntry(ScrollController controller, DateTime date) {
  //   updateYearMonth(YearMonth(useRange: false, date1: date.startOfMonth));
  //   final index = getScrollPosition(date);
  //   controller.jumpTo(index);
  // }

  void getScrollPosition(DateTime date) {
    final index = outputCostItems.entries.toList().indexWhere((entry) => entry.key == date);
    if (index == -1) {
      return;
    }
    // final itemCount = outputCostItems.entries.length - index - 1;
    final count = outputCostItems.entries
        .toList()
        .sublist(0, index)
        .fold(0, (init, entry) => init += entry.value.length);
    _scrollPosition = 40.0 + (60 * index) + (52 * count);
    debugPrint("count: $count, scrollPosition:${_scrollPosition.round()}");
    notifyListeners();
  }

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

  void updateYearMonth(YearMonth newYearMonth) {
    if (_sharedRepo.syncDate) {
      _sharedRepo.updateYearMonth(newYearMonth);
    } else {
      _yearMonth = newYearMonth;
    }
    notifyListeners();
  }

  void incrementYearMonth({bool increase = true}) {
    final value = increase ? 1 : -1;
    _yearMonth = _yearMonth.copyWith(
      date1: _yearMonth.date1.addMonth(value),
      date2: () => _yearMonth.date2?.addMonth(value),
    );
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
      _filteredCategories = null;
      _priceRange = null;
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

  void updateCategoryFilter(List<CostItemCategory>? categories) {
    _filteredCategories = categories;
    // debugPrint("category list: ${categories.length}");
    notifyListeners();
  }

  void updateDateRange(DateTimeRange? range) {
    debugPrint("update date range, range: ${range?.start} - ${range?.end}");
    _currentRange = range;
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

  void updateRangeFilter({required RangeValues range, required Set<CostType> types}) {
    _priceRange = range;
    _types = types;
    notifyListeners();
  }

  List<CostItem> get items => outputCostItems.values.flattenedToList;
  // double get maxAmount => outputCostItems.values.flattenedToList.fold(
  //   double.negativeInfinity,
  //   (init, item) => max(init, item.absoluteAmount),
  // );
  // double get minAmount => outputCostItems.values.flattenedToList.fold(
  //   double.infinity,
  //   (init, item) => min(init, item.absoluteAmount),
  // );

  String Function(
    double value, {
    bool abbreviated,
    bool alwaysShowSign,
    bool compact,
    int? decimalDigits,
  })
  get currencyFormat => _currencyRepo.formatCurrency;

  @override
  void dispose() {
    _itemSubscription?.cancel();
    _sharedElSubscription?.cancel();
    _categorySubscription?.cancel();
    _currencySubscription?.cancel();
    super.dispose();
  }
}

import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/enums/match_type.dart';
import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class TextSelectionViewmodel extends ChangeNotifier {
  TextSelectionViewmodel({
    required CostItemRepository itemRepo,
    required CategoryRepository categoryRepo,
    this.initFilter,
  }) : _itemRepo = itemRepo,
       _categoryRepo = categoryRepo {
    init();
  }

  final CostItemRepository _itemRepo;
  final CategoryRepository _categoryRepo;
  final StringFilter? initFilter;

  void init() async {
    await _itemRepo.ready;
    await _categoryRepo.ready;

    final itemLength = 200;
    if (_itemRepo.costItems.length < itemLength) {
      _items = _itemRepo.costItems;
    } else {
      _items = List.from(
        _itemRepo.costItems.sublist((_itemRepo.costItems.length - 200)),
      );
    }

    if (initFilter != null) {
      _filter = initFilter!;
    }

    _isInit = true;
    notifyListeners();
  }

  bool _isInit = false;
  bool get ready => _isInit;

  List<CostItem> _items = [];
  UnmodifiableListView<CostItem> get displayedItems => UnmodifiableListView(
    _items.where(
      (item) => _filter.checkMatch(item.name?.toLowerCase() ?? ""),
    ),
  );

  CostItemCategory getItemCategory(CostItem item) =>
      _categoryRepo.categories.firstWhereOrNull((category) => category.id == item.categoryId) ??
      CostItemCategory.error();

  StringFilter _filter = StringFilter.initial();
  StringFilter get filter => _filter;
  // String? _filterText;
  // String? get filterText => _filterText;

  // StringMatchType _matchType = StringMatchType.contain;
  // StringMatchType get matchType => _matchType;

  void updateFilter(String text) {
    _filter = _filter.copyWith(newQuery: text);
    notifyListeners();
  }

  void updateMatchType(StringMatchType type) {
    _filter = _filter.copyWith(type: type);
    notifyListeners();
  }
}

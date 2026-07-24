import 'package:budget_tracker/constants/categories.dart';
import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CategoryFormViewModel extends ChangeNotifier {
  CategoryFormViewModel({
    CostItemCategory? initCategory,
    required CategoryRepository categoryRepo,
    required CostItemRepository costItemRepo,
    required CurrencyRepository currencyRepo,
  }) : _initCategory = initCategory,
       _categoryRepo = categoryRepo,
       _currencyRepo = currencyRepo,
       _costItemRepo = costItemRepo {
    init();
  }

  final CostItemCategory? _initCategory;
  final CategoryRepository _categoryRepo;
  final CostItemRepository _costItemRepo;
  final CurrencyRepository _currencyRepo;

  CostItemCategory _draft = CostItemCategory(id: Uuid().v7());
  CostItemCategory get draft => _draft;

  CostItemCategory? _default;
  CostItemCategory? get defaultCat => _default;

  bool get inEditMode => _initCategory != null;

  final bool _isCostItemLoaded = false;
  bool get costItemReady => _isCostItemLoaded;

  void init() async {
    if (inEditMode) {
      _draft = _initCategory!;
    }
    await _categoryRepo.ready;
    await _costItemRepo.ready;

    getDefaultItem();

    _isInit = true;
    notifyListeners();
  }

  bool _isInit = false;
  bool get ready => _isInit;

  void updateColor(Color color) {
    debugPrint("color updated");
    _draft = _draft.copyWith(color: color);
    notifyListeners();
  }

  void updateCostType(CostType type) {
    _draft = _draft.copyWith(costType: type);
    notifyListeners();
  }

  void updateTitle(String newName) {
    _draft = _draft.copyWith(name: newName);
    notifyListeners();
  }

  void updateIcon(String path) {
    _draft = _draft.copyWith(imagePath: path, iconName: () => null);
    notifyListeners();
  }

  void updateIconData(String iconName) {
    _draft = _draft.copyWith(iconName: () => iconName);
    // debugPrint('icon data: ${iconData}');
    notifyListeners();
  }

  String? validateForm() {
    if (_draft.name?.isEmpty ?? true) {
      return "Name cannot be empty!";
    }
    if (_draft.costType == null) {
      return "Cost type cannot be empty!";
    }

    return null;
  }

  Future<void> submitCategory() async {
    // _draft = _draft.copyWith()
    if (inEditMode) {
      await _categoryRepo.updateCategory(_draft);
    } else {
      await _categoryRepo.addCategory(_draft);
    }
    notifyListeners();
  }

  List<CostItem>? getCategoryItems() {
    if (inEditMode) {
      return _costItemRepo.costItems.where((el) => el.categoryId == _draft.id).toList();
    }
    return null;
  }

  void getDefaultItem() {
    _default = defaultCostItemCategories.firstWhereOrNull((el) => el.id == _draft.id);
  }

  void resetCategory() async {
    _draft = _default!;
    await _categoryRepo.updateCategory(_draft);
    notifyListeners();
  }

  Future<void> deleteCategoryItem() async {
    await _categoryRepo.deleteCategory(_draft);
    await _costItemRepo.deleteCostItemByCategory(_draft);
    notifyListeners();
  }

  String Function(
    double value, {
    bool abbreviated,
    bool alwaysShowSign,
    bool compact,
    int? decimalDigits,
  })
  get currencyFormat => _currencyRepo.formatCurrency;
}

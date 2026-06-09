import 'dart:collection';

import 'package:budget_tracker/custom/category_class.dart';
import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/enum.dart';
import 'package:budget_tracker/custom/saved_item_class.dart';
import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/saved_item_repository.dart';
import 'package:budget_tracker/custom/saved_item_option_enum.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class FormModel extends ChangeNotifier {
  FormModel({
    required CostItemRepository costItemRepo,
    required SavedItemRepository savedItemRepo,
    required CategoryRepository categoryRepo,
    this.initCostItem,
  }) : _costItemRepository = costItemRepo,
       _savedItemRepository = savedItemRepo,
       _categoryRepo = categoryRepo {
    initialize();
  }

  final CostItem? initCostItem;
  final CostItemRepository _costItemRepository;
  final SavedItemRepository _savedItemRepository;
  final CategoryRepository _categoryRepo;

  CostItemFormResult? get formResult {
    if (selectedCategory == null) return null;
    return CostItemFormResult(
      name: _itemDesc,
      date: _date,
      costType: _type,
      category: _selectedCategory!,
      amount: _amount,
    );
  }

  FormGroup _formGroup = FormGroup.expense;
  FormGroup get formGroup => _formGroup;

  List<CostItemCategory> get categories =>
      _categoryRepo.categories
          .where((category) => category.costType == _formGroup.costType)
          .toList();

  bool _isLoaded = false;
  bool get ready => _isLoaded;

  UnmodifiableListView<SavedItem> get savedItems => _savedItemRepository.savedItems;

  CostItemCategory getCatById(SavedItem item) {
    return _categoryRepo.categories.firstWhereOrNull((el) => el.id == item.category) ?? CostItemCategory.error();
  }

  CostItemCategory? _selectedCategory;
  CostItemCategory? get selectedCategory => _selectedCategory;

  List<SavedItemOption> _saveOptions = [SavedItemOption.amount, SavedItemOption.description];
  UnmodifiableListView<SavedItemOption> get saveOptions => UnmodifiableListView(_saveOptions);

  double _amount = 0;
  double get amount => _amount;

  String _itemDesc = "";
  String get itemDesc => _itemDesc;

  CostType _type = CostType.expense;
  CostType get type => _type;

  DateTime _date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime get date => _date;

  String _savedTitle = "";
  String get savedTitle => _savedTitle;

  Future<void> initialize() async {
    _isLoaded = false;
    populateInitValue();
    await _categoryRepo.ready;

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> reloadCategory() async {
    await _categoryRepo.getCategory(revertToDefault: true);
  }

  void selectNewCategory(CostItemCategory category) {
    _selectedCategory = category;
    _type = category.costType!;
    notifyListeners();
  }

  void updateFormGroup(FormGroup group) {
    _formGroup = group;
    notifyListeners();
  }

  void selectSavedItem(SavedItem item) {
    _selectedCategory = categories.firstWhere(
      (cat) => cat.name == item.category,
    );
    _amount = item.amount!;
    _itemDesc = item.description!;
    _type = item.costType!;
    // _date = item.date;

    notifyListeners();
  }

  void updateDate(DateTime newDate) {
    debugPrint("date updated");
    _date = newDate;
    notifyListeners();
  }

  void updateAmount(double amount) {
    _amount = amount;
    notifyListeners();
  }

  void updateDesc(String value) {
    _itemDesc = value;
    notifyListeners();
  }

  void updateSavedItemTitle(String value) {
    _savedTitle = value;
    notifyListeners();
  }

  void updateSaveOption(SavedItemOption option, bool value) {
    if (value) {
      _saveOptions.add(option);
    } else {
      _saveOptions.remove(option);
    }
    notifyListeners();
  }

  void getV() async {}

  void populateInitValue() {
    debugPrint('initializing form model');

    if (initCostItem != null) {
      debugPrint('found cost item');
      _selectedCategory =
          categories.firstWhereOrNull(
            (cat) => cat.id == initCostItem!.categoryId,
          ) ??
          CostItemCategory(
            id: "0",
            name: "Category 404",
            costType: initCostItem!.costType,
            imagePath: "assets/images/warning.svg",
            color: Colors.white,
          );
      _amount = initCostItem!.amount;
      _itemDesc = initCostItem!.name;
      _date = initCostItem!.date;
      _type = initCostItem!.costType;
      _formGroup = _type == CostType.expense ? FormGroup.expense : FormGroup.income;
    }
    notifyListeners();
  }

  void deleteItem() {
    _costItemRepository.deleteCostItem(initCostItem!);
  }

  Future<Result<void>> submitForm() async {
    if (formResult != null) {
      if (initCostItem != null) {
        await _costItemRepository.updateCostItem(
          CostItem.update(initCostItem!, formResult!),
        );
      } else {
        await _costItemRepository.createCostItem(CostItem.fromForm(formResult!, id: Uuid().v4()));
      }
    }
    return Result.error(Exception("no form result, cannot create cost item"));
  }

}

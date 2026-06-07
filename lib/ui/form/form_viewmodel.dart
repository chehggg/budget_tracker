import 'dart:collection';

import 'package:budget_tracker/constants/categories.dart';
import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/enum.dart';
import 'package:budget_tracker/custom/saved_item_class.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/saved_item_repository.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class FormModel extends ChangeNotifier {
  FormModel({
    required CostItemRepository costItemRepo,
    required SavedItemRepository savedItemRepo,
    this.initCostItem,
  }) : _costItemRepository = costItemRepo,
       _savedItemRepository = savedItemRepo {
    initialize();
  }

  final CostItem? initCostItem;
  final CostItemRepository _costItemRepository;
  final SavedItemRepository _savedItemRepository;

  CostItemFormResult? get formResult {
    if (selectedCategory == null) return null;
    return CostItemFormResult(
      name: _itemDesc,
      date: _date,
      costType: _type,
      category: _selectedCategory!.name!,
      amount: _amount,
    );
  }

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  UnmodifiableListView<SavedItem> get savedItem => _savedItemRepository.savedItems;

  CostItemCategory? _selectedCategory;
  CostItemCategory? get selectedCategory => _selectedCategory;

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

  void initialize() async {
    _isLoaded = false;
    populateInitValue();
    // await loadFavorite();

    _isLoaded = true;
    notifyListeners();
  }

  void selectNewCategory(CostItemCategory category) {
    _selectedCategory = category;
    _type = category.costType!;
    notifyListeners();
  }

  void selectSavedItem(SavedItem item) {
    _selectedCategory = defaultCostItemCategories.firstWhere(
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

  void populateInitValue() {
    debugPrint('initializing form model');

    if (initCostItem != null) {
      debugPrint('found cost item');
      _selectedCategory = defaultCostItemCategories.firstWhere(
        (cat) => cat.name == initCostItem!.category,
      );
      _amount = initCostItem!.amount;
      _itemDesc = initCostItem!.name;
      _date = initCostItem!.date;
      _type = initCostItem!.costType;
    }
  }

  void deleteItem() {
    _costItemRepository.deleteCostItem(initCostItem!);
  }

  // Future<void> loadFavorite() async {
  //   final pref = SharedPreferencesAsync();
  //   try {
  //     final String? prefString = await pref.getString("savedItems");
  //     if (prefString == null) return;

  //     _savedItems.clear();
  //     _savedItems.addAll(
  //       (jsonDecode(prefString) as List<dynamic>).map((item) => CostItem.fromJson(item)).toList(),
  //     );

  //     notifyListeners();
  //   } catch (e) {
  //     debugPrint("Error loading saved items from shared pref, error: ${e.toString()}");
  //   }

  //   _isLoaded = true;
  //   notifyListeners();
  // }

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

  Future<void> saveItem() async {
    _savedItemRepository.addToSaved(
      SavedItem.fromFormResult(Uuid().v4(), _savedTitle, formResult!),
    );
  }
}

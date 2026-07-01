import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/classes/saved_item_class.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/saved_item_repository.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SavedItemViewModel extends ChangeNotifier {
  SavedItemViewModel({
    CostItem? initCostData,
    SavedItem? initItem,
    required CategoryRepository categoryRepo,
    required SavedItemRepository savedItemRepo,
  }) : _savedItemRepo = savedItemRepo,
       _categoryRepo = categoryRepo,
       _initItem = initItem,
       _initCostItem = initCostData {
    init();
  }

  final SavedItem? _initItem;
  final CostItem? _initCostItem;
  final SavedItemRepository _savedItemRepo;
  final CategoryRepository _categoryRepo;

  void init() async {
    _isLoaded = false;
    await _savedItemRepo.ready;
    await _categoryRepo.ready;

    // edit existing item
    if (inEditMode) {
      _draftedItem = _initItem!;
    } else {
      _draftedItem = SavedItem(
        id: Uuid().v4(),
        costType: _initCostItem?.costType,
        category: _initCostItem?.categoryId,
        description: _initCostItem?.name,
        amount: _initCostItem?.amount,
        date: _initCostItem?.date,
      );
    }
    _isLoaded = true;
    notifyListeners();
  }

  SavedItem _draftedItem = SavedItem();
  SavedItem get draft => _draftedItem;

  bool get inEditMode => _initItem != null;

  bool _isLoaded = false;
  bool get ready => _isLoaded;

  bool _keepDesc = true;
  bool get keepDesc => _keepDesc;

  bool _keepAmount = true;
  bool get keepAmount => _keepAmount;

  bool _keepDate = false;
  bool get keepDate => _keepDate;

  CostItemCategory get curCategory => _categoryRepo.getCategoryById(_draftedItem.category ?? "1");

  void toggleKeepValue(bool? value, String metric) {
    if (value == null) return;
    switch (metric) {
      case "description":
        _keepDesc = value;
      case "amount":
        _keepAmount = value;
      case "date":
        _keepDate = value;
    }
    notifyListeners();
  }

  void updateAmount(String newAmount) {
    _draftedItem = _draftedItem.copyWith(amount: () => double.tryParse(newAmount) ?? 0);
    notifyListeners();
  }

  void updateDate(String newDateString) {
    _draftedItem = _draftedItem.copyWith(date: () => newDateString.dateParseFull());
    notifyListeners();
  }

  void updateDesc(String desc) {
    _draftedItem = _draftedItem.copyWith(description: () => desc);
    notifyListeners();
  }

  void updateTitle(String newTitle) {
    _draftedItem = _draftedItem.copyWith(title: newTitle);
    notifyListeners();
  }

  Future<void> submitSavedItem() async {
    _draftedItem = _draftedItem.copyWith(
      lastModified: DateTime.now(),
      description: !keepDesc ? () => null : null,
      date: !keepDate ? () => null : null,
      amount: !keepAmount ? () => null : null,
    );
    if (inEditMode) {
      await _savedItemRepo.updateSaved(_draftedItem);
    } else {
      await _savedItemRepo.addToSaved(_draftedItem);
    }
  }

  Future<void> deleteSavedItem() async {
    if (inEditMode) {
      await _savedItemRepo.removeSaved(_draftedItem);
      notifyListeners();
    }
  }
}

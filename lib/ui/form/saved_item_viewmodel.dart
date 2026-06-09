import 'dart:collection';

import 'package:budget_tracker/custom/category_class.dart';
import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/saved_item_class.dart';
import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/saved_item_repository.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SavedItemModel extends ChangeNotifier {
  SavedItemModel({
    this.formData,
    required CostItemCategory category,
    required SavedItemRepository savedItemRepository,
    required CategoryRepository categoryRepo,
  }) : _savedItemRepository = savedItemRepository,
      //  _categoryRepo = categoryRepo,
       _category = category {
    init();
  }

  final SavedItemRepository _savedItemRepository;
  // final CategoryRepository _categoryRepo;
  final CostItemFormResult? formData;
  final CostItemCategory _category;

  void init() {
    _isLoaded = false;
    // await _categoryRepo.ready;
    if (formData != null) {
      _description = formData!.name;
      _amount = formData!.amount;
      _date = formData!.date;
      debugPrint("pass data, desc: $_description");
    }
    _isLoaded = true;
    notifyListeners();
  }

  CostItemCategory get selectedCategory => _category;

  bool _isLoaded = false;
  bool get ready => _isLoaded;

  String _title = "";

  String _description = "";
  String get description => _description;

  double _amount = 0;
  double get amount => _amount;
  
  DateTime _date = DateTime.now();
  DateTime get date => _date;

  bool _keepDesc = true;
  bool get keepDesc => _keepDesc;

  bool _keepAmount = true;
  bool get keepAmount => _keepAmount;

  bool _keepDate = false;
  bool get keepDate => _keepDate;

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

  void updateAmount(String value) {
    _amount = double.tryParse(value) ?? 0;
    notifyListeners();
  }

  void updateDate(DateTime newDate) {
    _date = newDate;
    notifyListeners();
  }

  void updateDesc(String desc) {
    _description = desc;
    notifyListeners();
  }

  void updateTitle(String value) {
    _title = value;
    notifyListeners();
  }

  Future<void> saveItem() async {
    await _savedItemRepository.addToSaved(
      SavedItem(
        id: Uuid().v4(),
        title: _title,
        category: _category.id,
        costType: _category.costType,
        description: _keepDesc ? _description : null,
        date: _keepDate ? _date : null,
        amount: _keepAmount ? _amount : null,
      ),
    );
  }
}

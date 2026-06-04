import 'package:budget_tracker/constants/categories.dart';
import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/enum.dart';
import 'package:budget_tracker/models/model.dart';
import 'package:flutter/material.dart';

class FormModel extends ChangeNotifier {
  FormModel({this.costItem}) {
    populateInitValue();
  }

  void populateInitValue() {
    debugPrint('initializing form model');

    if (costItem != null) {
      debugPrint('found cost item');
      _selectedCategory = defaultCostItemCategories
          .firstWhere((cat) => cat.name == costItem!.category);
      _amount = costItem!.amount;
      _itemDesc = costItem!.name;
      _date = costItem!.date;
      _type = costItem!.costType;
    }
  }

  final CostItem? costItem;

  CostItemCategory? _selectedCategory;
  CostItemCategory? get selectedCategory => _selectedCategory;

  double _amount = 0;
  double get amount => _amount;

  String _itemDesc = "";
  String get itemDesc => _itemDesc;

  CostType _type = CostType.expense;
  CostType get type => _type;

  DateTime _date = DateTime.now();
  DateTime get date => _date;

  void selectNewCategory(CostItemCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void updateDate(DateTime date) {
    _date = date;
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

  CostItemFormResult? get formResult {
    if (selectedCategory == null) return null;
    return CostItemFormResult(
        name: _itemDesc,
        date: _date,
        costType: _type,
        category: _selectedCategory!.name!,
        amount: _amount);
  }
}

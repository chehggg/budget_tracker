import 'dart:collection';
import 'dart:convert';

import 'package:budget_tracker/constants/categories.dart';
import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/enum.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormModel extends ChangeNotifier {
  FormModel({this.costItem}) {
    initialize();
  }

  final CostItem? costItem;

  void initialize() async {
    _isLoaded = false;
    populateInitValue();
    await loadFavorite();

    _isLoaded = true;
    notifyListeners();
  }

  void populateInitValue() {
    debugPrint('initializing form model');

    if (costItem != null) {
      debugPrint('found cost item');
      _selectedCategory = defaultCostItemCategories.firstWhere(
        (cat) => cat.name == costItem!.category,
      );
      _amount = costItem!.amount;
      _itemDesc = costItem!.name;
      _date = costItem!.date;
      _type = costItem!.costType;
    }
  }

  Future<void> loadFavorite() async {
    final pref = SharedPreferencesAsync();
    try {
      final String? prefString = await pref.getString("savedItems");
      if (prefString == null) return;

      _favorites.clear();
      _favorites.addAll(
        (jsonDecode(prefString) as List<dynamic>).map((item) => CostItem.fromJson(item)).toList(),
      );

      notifyListeners();
    } catch (e) {
      debugPrint("Error loading saved items from shared pref, error: ${e.toString()}");
    }

    _isLoaded = true;
    notifyListeners();
  }

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  final List<CostItem> _favorites = [];
  UnmodifiableListView<CostItem> get favorites => UnmodifiableListView<CostItem>(_favorites);

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

  void selectNewCategory(CostItemCategory category) {
    _selectedCategory = category;
    _type = category.costType!;
    notifyListeners();
  }

  void selectFavorite(CostItem favorite) {
    _selectedCategory = defaultCostItemCategories.firstWhere(
      (cat) => cat.name == favorite.category,
    );
    _amount = favorite.amount;
    _itemDesc = favorite.name;
    _date = favorite.date;
    _type = favorite.costType;

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

  Future<void> addToFavorite(CostItem itemId) async {
    _favorites.add(itemId);
    notifyListeners();

    final pref = SharedPreferencesAsync();
    try {
      await pref.setString(
        "savedItems",
        jsonEncode(
          _favorites,
          toEncodable: (val) => val is CostItem ? val.toJson() : null,
        ),
      );
    } catch (e) {
      debugPrint('Error writing saved items to shared pref, error: ${e.toString()}');
    }
  }
}

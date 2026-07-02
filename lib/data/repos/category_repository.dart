import 'dart:async';

import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/data/services/local_service.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class CategoryRepository {
  CategoryRepository({required LocalServices localServices}) : _localServices = localServices {
    _initFuture = _init();
  }

  final LocalServices _localServices;

  List<CostItemCategory> _categories = [];
  UnmodifiableListView<CostItemCategory> get categories => UnmodifiableListView(_categories);

  late Future<void> _initFuture;
  Future<void> get ready => _initFuture;

  Future<void> _init() async {
    await getCategory();
  }

  final StreamController<List<CostItemCategory>> _streamController =
      StreamController<List<CostItemCategory>>.broadcast();

  Stream<List<CostItemCategory>> get categoryStream => _streamController.stream;

  Future<void> getCategory({bool customFile = false, bool revertToDefault = false}) async {
    Result<List<CostItemCategory>> result;
    result = await _localServices.loadCategoriesFile();
    // if (revertToDefault) {
    //   result = await _categoryServices.();
    // } else {
    // result = await _categoryServices.loadDefaultCategoryJson();
    // }

    switch (result) {
      case Ok():
        _categories = result.value;

      case Error():
        debugPrint(result.error.toString());
    }
  }

  CostItemCategory getCategoryById(String id) {
    return categories.firstWhereOrNull((el) => el.id == id) ?? CostItemCategory.error();
  }

  Future<void> addCategory(CostItemCategory item) async {
    _categories.add(item);
    await _localServices.writeCategoriesFile(_categories);
    _streamController.add(_categories);
  }

  Future<void> deleteCategory(CostItemCategory deletedItem) async {
    _categories.removeWhere((el) => el.id == deletedItem.id);
    await _localServices.writeCategoriesFile(_categories);
    _streamController.add(_categories);
  }

  Future<void> updateCategory(CostItemCategory updatedItem) async {
    final index = _categories.indexWhere((el) => el.id == updatedItem.id);
    _categories.removeAt(index);
    _categories.insert(index, updatedItem);
    await _localServices.writeCategoriesFile(_categories);
    _streamController.add(_categories);
  }
}

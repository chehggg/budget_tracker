import 'dart:collection';

import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/data/services/local_service.dart';
import 'package:budget_tracker/utils/result.dart';
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

  // Future<void> exportCategory() async {
  //   await _categoryServices.exportCategoryJson(_categories);
  // }

  Future<void> addCategory({
    required String name,
    required Color color,
    required String path,
    required CostType type,
  }) async {
    _categories.add(
      CostItemCategory(
        id: (_categories.length + 1).toString(),
        name: name,
        color: color,
        imagePath: path,
        costType: type,
      ),
    );
  }
}

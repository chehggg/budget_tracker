import 'dart:collection';

import 'package:budget_tracker/custom/category_class.dart';
import 'package:budget_tracker/custom/enum.dart';
import 'package:budget_tracker/data/services/category_service.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:flutter/material.dart';

class CategoryRepository {
  CategoryRepository({required CategoryServices categoryServices})
    : _categoryServices = categoryServices {
    _initFuture = _init();
  }

  final CategoryServices _categoryServices;

  List<CostItemCategory> _categories = [];
  UnmodifiableListView<CostItemCategory> get categories => UnmodifiableListView(_categories);

  late Future<void> _initFuture;
  Future<void> get ready => _initFuture;

  Future<void> _init() async {
    await getCategory();
  }

  Future<void> getCategory({bool customFile = false}) async {
    Result<List<CostItemCategory>> result;
    result = await _categoryServices.loadDefaultCategoryJson();

    switch (result) {
      case Ok():
        _categories = result.value;

      case Error():
        debugPrint(result.error.toString());
    }
  }

  Future<void> exportCategory() async {
    await _categoryServices.exportCategoryJson(_categories);
  }

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

import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:flutter/material.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel({
    required CostItemRepository costItemRepository,
    required CategoryRepository categoryRepository,
  }) : _costItemRepository = costItemRepository,
       _categoryRepository = categoryRepository;

  final CostItemRepository _costItemRepository;
  final CategoryRepository _categoryRepository;

  Future<void> exportCostItemData() async {
    await _costItemRepository.exportCostItem();
  }

  Future<void> loadData() async {
    await _costItemRepository.getCostItem(customFile: true);
  }
  
  // Future<void> exportCategoryData() async {
  //   await _categoryRepository.exportCategory();
  // }
  // Future<void> loadFile() async {
  // }
}

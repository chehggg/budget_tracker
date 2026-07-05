import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:flutter/material.dart';

class ChartCategoryBreakdownViewModel extends ChangeNotifier {
  ChartCategoryBreakdownViewModel({
    required CategoryRepository categoryRepo,
    required CostItemRepository costItemRepo,
  }) : _categoryRepo = categoryRepo,
       _costItemRepo = costItemRepo;

  final CategoryRepository _categoryRepo;
  final CostItemRepository _costItemRepo;

  Future<void> init() async {
    await _categoryRepo.ready;
    await _costItemRepo.ready;
  }
}

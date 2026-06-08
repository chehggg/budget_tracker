import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({required CostItemRepository costItemRepo}) : _costItemRepo = costItemRepo;

  final CostItemRepository _costItemRepo;

} 
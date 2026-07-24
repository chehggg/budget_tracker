import 'dart:async';

import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:budget_tracker/data/repos/exchange_rate_repository.dart';
import 'package:budget_tracker/data/repos/goal_repository.dart';
import 'package:budget_tracker/data/repos/saved_item_repository.dart';
import 'package:budget_tracker/data/repos/shared_element_repository.dart';
import 'package:budget_tracker/data/services/exporter_service.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required CostItemRepository costItemRepo,
    required CategoryRepository categoryRepo,
    required CurrencyRepository currencyRepo,
    required ExchangeRateRepository exchangeRateRepo,
    required GoalRepository goalRepo,
    required SavedItemRepository savedItemRepo,
    required SharedElementRepository sharedElementRepo,
    required ExporterServices exportServices,
  }) : _costItemRepo = costItemRepo,
       _currencyRepo = currencyRepo,
       _exchangeRateRepo = exchangeRateRepo,
       _goalRepo = goalRepo,
       _savedItemRepo = savedItemRepo,
       _sharedElementRepo = sharedElementRepo,
       _exportServices = exportServices,
       _categoryRepo = categoryRepo {
    init();
  }

  final CostItemRepository _costItemRepo;
  final CategoryRepository _categoryRepo;
  final CurrencyRepository _currencyRepo;
  //  final result = await context.read<ExporterServices>().loadData();
  final ExchangeRateRepository _exchangeRateRepo;
  final GoalRepository _goalRepo;
  final SavedItemRepository _savedItemRepo;
  final SharedElementRepository _sharedElementRepo;
  final ExporterServices _exportServices;

  Future<void> init() async {
    await _costItemRepo.ready;
    await _categoryRepo.ready;
    await _currencyRepo.ready;

    _currencySubscription = _currencyRepo.currencyStream.listen((value) => notifyListeners());

    _isInit = true;
    notifyListeners();
  }

  // ignore: unused_field
  StreamSubscription<Currency>? _currencySubscription;

  bool _isInit = false;
  bool get ready => _isInit;

  final bool _isLoading = false;
  bool get loading => _isLoading;

  Future<void> exportCostItemData() async {
    await _costItemRepo.exportCostItem();
  }

  Future<void> updateCurrency(Currency currency) async {
    await _currencyRepo.changeCurrency(currency);
  }

  Future<void> loadData() async {
    await _costItemRepo.getCostItem(customFile: true);
  }

  String get displayedCurrency =>
      _currencyRepo.currency.name.isEmpty ? "Custom" : _currencyRepo.currency.name;

  Future<void> resetRepo() async {
    await _costItemRepo.restart();
    await _categoryRepo.restart();
    await _currencyRepo.restart();
    await _exchangeRateRepo.restart();
    await _goalRepo.restart();
    await _savedItemRepo.restart();
    await _sharedElementRepo.restart();
  }

  Future<String> loadAllData() async {
    final result = await _exportServices.loadData();
    switch (result) {
      case Ok():
        await resetRepo();
        return "";
      case Error():
        return result.error.toString();
    }
  }

  Future<String> exportData() async {
    final result = await _exportServices.exportData();
    switch (result) {
      case Ok():
        return "";
      case Error():
        return result.error.toString();
    }
  }

  Future<String> deleteData() async {
    final result = await _exportServices.clearData();
    switch (result) {
      case Ok():
        await resetRepo();
        return "";
      case Error():
        return result.error.toString();
    }
  }
}

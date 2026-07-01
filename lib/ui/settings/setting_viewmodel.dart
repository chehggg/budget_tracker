import 'dart:async';

import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required CostItemRepository costItemRepo,
    required CategoryRepository categoryRepo,
    required CurrencyRepository currencyRepo,
  }) : _costItemRepository = costItemRepo,
       _currencyRepo = currencyRepo,
       _categoryRepository = categoryRepo {
    init();
  }

  final CostItemRepository _costItemRepository;
  final CategoryRepository _categoryRepository;
  final CurrencyRepository _currencyRepo;

  Future<void> init() async {
    await _costItemRepository.ready;
    await _categoryRepository.ready;
    await _currencyRepo.ready;

    _currencySubscription  =  _currencyRepo.currencyStream.listen((value) => notifyListeners());
    
    _isInit = true;
    notifyListeners();
  }

  StreamSubscription<Currency>? _currencySubscription;

  bool _isInit = false;
  bool get ready => _isInit;

  Future<void> exportCostItemData() async {
    await _costItemRepository.exportCostItem();
  }

  Future<void> updateCurrency(Currency currency) async {
    await _currencyRepo.changeCurrency(currency);
  }

  Future<void> loadData() async {
    await _costItemRepository.getCostItem(customFile: true);
  }

  String get displayedCurrency => "${_currencyRepo.currency.name} (${_currencyRepo.currency.symbol})";
}

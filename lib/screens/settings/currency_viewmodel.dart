import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class CurrencyViewModel extends ChangeNotifier {
  CurrencyViewModel({required CurrencyRepository currencyRepo, this.isCurrencyExchange = false})
    : _currencyRepo = currencyRepo {
    init();
  }

  final bool isCurrencyExchange;
  final CurrencyRepository _currencyRepo;

  Future<void> init() async {
    await _currencyRepo.ready;

    _selectedCurrency = _currencyRepo.currency;

    _currencies = [
      if (!isCurrencyExchange) _selectedCurrency,
      ..._currencyRepo.recentCurrencies.where((currency) => (currency.isoCode != _selectedCurrency.isoCode)),
      ..._currencyRepo.availableCurrencies.where(
        (currency) => (currency.isoCode != _selectedCurrency.isoCode) && !_currencyRepo.recentCurrencies.contains(currency),
      ),
    ];
    _filteredCurrencies = _currencies;

    _isInit = true;

    notifyListeners();
  }

  List<Currency> _filteredCurrencies = [];
  List<Currency> get filteredCurrencies => _filteredCurrencies;

  void updateFilteredCurrencies() {
    _filteredCurrencies = [
      ..._currencies.where(
        (currency) =>
            (currency.country.toLowerCase().contains(_filterString.toLowerCase()) ||
                currency.isoCode.toLowerCase().contains(_filterString.toLowerCase()) ||
                currency.name.toLowerCase().contains(_filterString.toLowerCase()) ||
                currency.symbol.toLowerCase().contains(_filterString.toLowerCase())),
      ),
    ];
    notifyListeners();
  }

  List<Currency> _currencies = [];
  List<Currency> get currencies => _currencies;

  Currency _selectedCurrency = CommonCurrencies().usd;
  Currency get selectedCurrency => _selectedCurrency;

  Currency _selectedExchangeCurrency = CommonCurrencies().usd;
  Currency get selectedExchangeCurrency => _selectedExchangeCurrency;

  bool _isInit = false;
  bool get ready => _isInit;

  String _filterString = "";
  String get filterString => _filterString;

  void updateCurrency(Currency newCurrency) {
    _selectedCurrency = newCurrency;
    _currencyRepo.updateRecentlyUsedCurrencies(newCurrency);
    _currencyRepo.changeCurrency(_selectedCurrency);
  }

  void updateFilter(String filter) {
    _filterString = filter;
    updateFilteredCurrencies();
    notifyListeners();
  }

  void selectExchangeCurrency(Currency newCurrency) {
    _selectedExchangeCurrency = newCurrency;
    _currencyRepo.updateRecentlyUsedCurrencies(newCurrency);
    notifyListeners();
  }

}

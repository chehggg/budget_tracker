import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:budget_tracker/data/services/api_service.dart';
import 'package:budget_tracker/data/services/local_service.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money2/money2.dart';

class CurrencyRepository {
  CurrencyRepository({required LocalServices localServices, required ApiServices apiServices})
    : _localServices = localServices,
      _apiServices = apiServices {
    _initFuture = init();
  }

  final LocalServices _localServices;
  final ApiServices _apiServices;

  Future<void> init() async {
    final result = await _localServices.getCurrency();

    switch (result) {
      case Ok():
        if (result.value != null) {
          _currency = result.value!;
        } else {
          _currency = getDefaultCurrency();
          await _localServices.writeCurrency(_currency);
        }
      case Error():
        _currency = getDefaultCurrency();
        await _localServices.writeCurrency(_currency);
    }

    final recentResult = await _localServices.getRecentlyUsedCurrency();
    switch (recentResult) {
      case Ok():
        if (recentResult.value != null) {
          _recentlyUsedCurrencies = recentResult.value!;
        } else {
          _recentlyUsedCurrencies = [];
        }
      case Error():
        _recentlyUsedCurrencies = [];
    }
  }

  final StreamController<Currency> _currencyController = StreamController.broadcast();
  Stream<Currency> get currencyStream => _currencyController.stream;

  List<Currency> _recentlyUsedCurrencies = [];
  List<Currency> get recentCurrencies => _recentlyUsedCurrencies;

  Map<String, double> _exchangeRates = {};
  Map<String, double> get exchangeRates => _exchangeRates;

  // final StreamController<String> _currencyStreamController = StreamController<String>.broadcast();
  // Stream<String> get valueStream => _currencyStreamController.stream;

  late final Future<void> _initFuture;
  Future<void> get ready => _initFuture;

  late Currency _currency;
  Currency get currency => _currency;

  final List<Currency> _currencies = [
    ...Currencies().getRegistered().where(
      (currency) =>
          currency.isIso &&
          !currency.country.startsWith("ZZ") &&
          currency.country != currency.country.toUpperCase(),
    ),
  ];
  List<Currency> get availableCurrencies => _currencies;

  Currency getDefaultCurrency() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    final code =
        NumberFormat.compactCurrency(locale: deviceLocale.toLanguageTag()).currencyName ?? "";
    return Currencies().find(code) ?? CommonCurrencies().usd;
  }

  Future<void> updateRecentlyUsedCurrencies(Currency currency) async {
    final index = _recentlyUsedCurrencies.indexWhere((el) => el.name == currency.name);

    if (index != -1) {
      _recentlyUsedCurrencies.removeAt(index);
    }
    _recentlyUsedCurrencies.insert(0, currency);

    if (_recentlyUsedCurrencies.length > 10) {
      _recentlyUsedCurrencies.removeLast();
    }
    await _localServices.writeRecentlyUsedCurrency(_recentlyUsedCurrencies);
  }

  Future<void> changeCurrency(Currency newCurrency) async {
    _currency = newCurrency;
    await _localServices.writeCurrency(_currency);
    updateRecentlyUsedCurrencies(_currency);

    _currencyController.add(_currency);
  }

  Future<void> getExchangeRates() async {
    final response = await _apiServices.getExchangeRate();
    switch (response) {
      case Ok():
        _exchangeRates = response.value.rates ?? {};
        debugPrint("get exchange rate value! ${_exchangeRates.length}");
      case Error():
        _exchangeRates = {};
        debugPrint("cannot retrieve exchange rate, ${response.error}");
    }
  }

  String formatCurrency(
    double value, {
    bool abbreviated = false,
    bool alwaysShowSign = false,
    bool showSymbol = true,
    bool compact = false,
    int? decimalDigits,
  }) {
    double transformedValue = value;
    String suffix = "";
    String pattern = _currency.pattern;

    if (abbreviated) {
      if (value.abs() >= pow(10, 3) && value.abs() < pow(10, 6)) {
        transformedValue = value / pow(10, 3);
        suffix = "k";
      } else if (value.abs() >= pow(10, 6) && value.abs() < pow(10, 9)) {
        transformedValue = value / pow(10, 6);
        suffix = "M";
      } else if (value.abs() >= pow(10, 9) && value.abs() < pow(10, 12)) {
        transformedValue = value / pow(10, 9);
        suffix = "B";
      } else if (value.abs() >= pow(10, 12)) {
        transformedValue = value / pow(10, 12);
        suffix = "T";
      }
      pattern = pattern.endsWith("S") ? pattern.replaceAll(r"S", "${suffix}S") : "$pattern$suffix";
    }

    if (alwaysShowSign) {
      pattern = "+$pattern";
    }

    if (compact && transformedValue % 1 == 0) {
      pattern = pattern.replaceAll(RegExp(r'\.0{2,}'), '');
    } else if (decimalDigits != null) {
      transformedValue = double.parse(transformedValue.toStringAsFixed(decimalDigits));
      pattern = pattern.replaceAll(
        RegExp(r'0(.0{1,}|$|(?=[S;]))'),
        '0.${List.filled(decimalDigits, '0').join()}',
      );
    }
    if (!showSymbol) {
      pattern = pattern.replaceAll(r"S", "");
    }
    final money = Money.fromNumWithCurrency(transformedValue, _currency);

    return money.format(pattern);
  }

  Future<void> updateCurrencyFormat(Currency newCurrency) async {
    _currency = Currency.create(
      _currency.isoCode.contains("- C") ? _currency.isoCode : "${_currency.isoCode} - C",
      newCurrency.decimalDigits,
      pattern: newCurrency.pattern,
      symbol: newCurrency.symbol,
      groupSeparator: newCurrency.groupSeparator,
      decimalSeparator: newCurrency.decimalSeparator,
      name: _currency.name.contains("Custom") ? currency.name : "${currency.name} (Custom)",
    );
    Currencies().register(_currency);
    await updateRecentlyUsedCurrencies(_currency);
    await _localServices.writeCurrency(_currency);
    _currencyController.add(_currency);
  }

  Future<void> clearRecentlyUsedCurrency() async {
    _recentlyUsedCurrencies = [];
    await _localServices.writeRecentlyUsedCurrency(_recentlyUsedCurrencies);
  }
}

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:budget_tracker/data/services/local_service.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:intl/intl.dart';
import 'package:money2/money2.dart';

class CurrencyRepository {
  CurrencyRepository({required LocalServices localServices}) : _localServices = localServices {
    _initFuture = init();
  }

  final LocalServices _localServices;

  Future<void> init() async {
    final result = await _localServices.getCurrency();

    //update incorrect separators for money2
    // final malaysiaCurrency = CommonCurrencies().myr.copyWith(
    //   groupSeparator: ",",
    //   decimalSeparator: ".",
    // );
    // final indonesiaCurrency = CommonCurrencies().idr.copyWith(
    //   groupSeparator: ".",
    //   decimalSeparator: ",",
    // );

    // Currencies().registerList([malaysiaCurrency, indonesiaCurrency]);

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
  }

  final StreamController<String> _currencyStreamController = StreamController<String>.broadcast();
  Stream<String> get valueStream => _currencyStreamController.stream;

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

  Future<void> changeCurrency(Currency newCurrency) async {
    _currency = newCurrency;
    await _localServices.writeCurrency(_currency);
    // _currencyStreamController.add(_currency.isoCode);
  }

  String formatCurrency(
    double value, {
    bool abbreviated = false,
    bool alwaysShowSign = false,
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

    final money = Money.fromNumWithCurrency(transformedValue, _currency);

    if (alwaysShowSign) {
      pattern = "+$pattern";
    }

    if (compact && transformedValue % 1 == 0) {
      pattern = pattern.replaceAll(r'.00', '');
    } else if (decimalDigits != null) {
      pattern = pattern.replaceAll(r'.00', '.${List.generate(decimalDigits, (i) => "0").join()}');
    }

    return money.format(pattern);
  }
}

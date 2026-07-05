import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class AdditionalCurrencySettingsViewModel extends ChangeNotifier {
  AdditionalCurrencySettingsViewModel({required CurrencyRepository currencyRepo})
    : _currencyRepo = currencyRepo {
    init();
  }

  final CurrencyRepository _currencyRepo;

  Future<void> init() async {
    await _currencyRepo.ready;
    _currency = _currencyRepo.currency;
    if (_currency.pattern.startsWith("S")) {
      _symbolPosition = "Front";
    } else if (_currency.pattern.endsWith("S")) {
      _symbolPosition = "Back";
    } else {
      _symbolPosition = "None";
    }
    _symbolSpace = _currency.pattern.contains(RegExp(r'S | S'));

    _isInit = true;
    notifyListeners();
  }

  Currency _currency = CommonCurrencies().usd;
  Currency get currency => _currency;

  String _symbolPosition = "None";
  String get symbolPosition => _symbolPosition;

  bool _symbolSpace = false;
  bool get symbolSpace => _symbolSpace;

  bool _isInit = false;
  bool get ready => _isInit;

  // void updateThousandSeparator(String? separator) {
  //   if (separator == null) return;
  //   _currency = _currency.copyWith(groupSeparator: separator);
  //   _currencyRepo.updateCurrencyFormat(_currency);
  //   notifyListeners();
  // }

  void updateSeparator(String? separator, {bool isDecimal = false}) {
    if (separator == null) return;
    if (isDecimal) {
      _currency = _currency.copyWith(
        decimalSeparator: separator,
        groupSeparator: separator == "." ? "," : ".",
      );
    } else {
      _currency = _currency.copyWith(
        groupSeparator: separator,
        decimalSeparator: separator == "." ? "," : ".",
      );
    }
    _currencyRepo.updateCurrencyFormat(_currency);
    notifyListeners();
  }

  void updateSymbol(String symbol) {
    _currency = _currency.copyWith(symbol: symbol);
    _currencyRepo.updateCurrencyFormat(_currency);
    notifyListeners();
  }

  void updateDecimalDigit(int decimal) {
    _currency = _currency.copyWith(decimalDigits: decimal);
    _currencyRepo.updateCurrencyFormat(_currency);
    notifyListeners();
  }

  void toggleSymbolSpace(bool? value) {
    if (value == null) return;
    _symbolSpace = !_symbolSpace;
    final spaceFront = " S";
    final spaceBehind = "S ";
    if (_symbolSpace) {
      _currency = _currency.copyWith(
        pattern: _currency.pattern.replaceAll(
          'S',
          _symbolPosition == "Front" ? spaceBehind : spaceFront,
        ),
      );
    } else {
      _currency = _currency.copyWith(
        pattern: _currency.pattern.replaceAll(
          _symbolPosition == "Front" ? spaceBehind : spaceFront,
          "S",
        ),
      );
    }
    _currencyRepo.updateCurrencyFormat(_currency);
    notifyListeners();
  }

  void updateSymbolPosition(String? position) {
    if (position == null) return;
    final initPattern = _currency.pattern;
    final String newPattern;
    switch (position) {
      case "Front":
        newPattern = initPattern
            .replaceAll("S", "")
            .split(";")
            .map((substr) => "S$substr")
            .join(";");
      case "Back":
        newPattern = initPattern
            .replaceAll("S", "")
            .split(";")
            .map((substr) => "${substr}S")
            .join(";");
      case "None":
        newPattern = initPattern.replaceAll("S", "");
      default:
        newPattern = initPattern;
      // _currency = _currency.copyWith(pattern: _currency.pattern.repla);
    }
    _currency = _currency.copyWith(pattern: newPattern);
    _currencyRepo.updateCurrencyFormat(_currency);
    notifyListeners();
  }

  String Function(
    double value, {
    bool abbreviated,
    bool alwaysShowSign,
    bool compact,
    int? decimalDigits,
  })
  get formatCurrency => _currencyRepo.formatCurrency;
}

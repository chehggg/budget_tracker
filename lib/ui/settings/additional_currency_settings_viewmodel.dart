import 'package:budget_tracker/custom/enums/enum.dart';
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
      _symbolPosition = SymbolPosition.front;
    } else if (_currency.pattern.endsWith("S")) {
      _symbolPosition = SymbolPosition.back;
    } else {
      _symbolPosition = SymbolPosition.none;
    }
    _symbolSpace = _currency.pattern.contains(RegExp(r'S | S'));

    _isInit = true;
    notifyListeners();
  }

  Currency _currency = CommonCurrencies().usd;
  Currency get currency => _currency;

  SymbolPosition _symbolPosition = SymbolPosition.front;
  SymbolPosition get symbolPosition => _symbolPosition;

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

  void updateSeparator(NumberSeparator? separator, {bool isDecimal = false}) {
    if (separator == null) return;
    String switchSymbol(String symbol) {
      return symbol == "." ? "," : ".";
    }

    if (isDecimal) {
      _currency = _currency.copyWith(
        decimalSeparator: separator.symbol,
        groupSeparator:
            _currency.groupSeparator == separator.symbol
                ? switchSymbol(separator.symbol)
                : _currency.groupSeparator,
      );
    } else {
      _currency = _currency.copyWith(
        groupSeparator: separator.symbol,
        decimalSeparator:
            _currency.decimalSeparator == separator.symbol
                ? switchSymbol(separator.symbol)
                : _currency.decimalSeparator,
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
          _symbolPosition == SymbolPosition.front ? spaceBehind : spaceFront,
        ),
      );
    } else {
      _currency = _currency.copyWith(
        pattern: _currency.pattern.replaceAll(
          RegExp(r'\ *S\ *'),
          "S",
        ),
      );
    }
    _currencyRepo.updateCurrencyFormat(_currency);
    notifyListeners();
  }

  void updateSymbolPosition(SymbolPosition? position) {
    if (position == null) return;
    _symbolPosition = position;
    final initPattern = _currency.pattern;
    final String newPattern;
    switch (position) {
      case SymbolPosition.front:
        newPattern = initPattern
            .replaceAll("S", "")
            .split(";")
            .map((substr) => "S$substr")
            .join(";");
      case SymbolPosition.back:
        newPattern = initPattern
            .replaceAll("S", "")
            .split(";")
            .map((substr) => "${substr}S")
            .join(";");
      case SymbolPosition.none:
        newPattern = initPattern.replaceAll("S", "");
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

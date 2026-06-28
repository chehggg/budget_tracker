import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class ExRateViewModel extends ChangeNotifier {
  ExRateViewModel({
    required CurrencyRepository currencyRepo,
    required this.baseCurrency,
    required this.targetCurrency,
  }) : _currencyRepo = currencyRepo {
    init();
  }

  final CurrencyRepository _currencyRepo;
  Currency baseCurrency;
  Currency targetCurrency;

  Future<void> init() async {
    await getDefaultExchangeRate();
    _customExchangeRateValue = _defaultRate;
    _exRateController = TextEditingController(text: _customExchangeRateValue.toStringAsFixed(4))
      ..addListener(() => updateCustomExchangeRate());
    _isRateLoaded = true;

    notifyListeners();
  }

  bool _isRateLoaded = false;
  bool get ready => _isRateLoaded;

  double _baseAmount = 1;
  double get base => _baseAmount;

  TextEditingController _exRateController = TextEditingController();
  TextEditingController get exRateController => _exRateController;

  double get convertedValue => _baseAmount * resultRate;
  String get formattedConvertedValue {
    // debugPrint("isInverse? ${_isInverse}, resultRate: ${resultRate}");
    final money = Money.fromNumWithCurrency(
      convertedValue,
      targetCurrency,
    );
    final pattern = targetCurrency.pattern.replaceAll(r"S", "");
    return money.format(pattern);
    // _baseAmount * _exchangeRateValue;
  }

  double _defaultRate = 1;

  double _customExchangeRateValue = 1;

  double get resultRate {
    if (useCustomRate) {
      return _customExchangeRateValue;
    } else {
      return _defaultRate;
    }
  }

  bool _isInverse = false;
  bool get isInverse => _isInverse;

  bool _useCustomRate = false;
  bool get useCustomRate => _useCustomRate;

  void inverseRate(bool val) {
    _isInverse = val;
    _customExchangeRateValue =
        _isInverse
            ? (_customExchangeRateValue == 0 ? 0 : (1 / _customExchangeRateValue))
            : _customExchangeRateValue;
    _exRateController.value = _exRateController.value.copyWith(
      text: _customExchangeRateValue.toStringAsFixed(4),
    );
    notifyListeners();
  }

  void updateBaseAmount(String text) {
    _baseAmount = double.tryParse(text) ?? 0;
    notifyListeners();
  }

  void toggleCustomExchangeRate() {
    _useCustomRate = !useCustomRate;
    notifyListeners();
  }

  void updateCustomExchangeRate() {
    final val = double.tryParse(_exRateController.text) ?? 1;
    _customExchangeRateValue = _isInverse ? (val == 0 ? 0 : (1 / val)) : val;
    notifyListeners();
  }

  void resetCustomExchangeRate() {
    _customExchangeRateValue = isInverse ? (1/_defaultRate) : _defaultRate;
    _exRateController.value = _exRateController.value.copyWith(
      text: _customExchangeRateValue.toStringAsFixed(4),
    );
    notifyListeners();
  }

  Future<void> getDefaultExchangeRate() async {
    await _currencyRepo.getExchangeRates();
    debugPrint('viewmodel trigger exchange rate');

    final initRate = _currencyRepo.exchangeRates[baseCurrency.isoCode] ?? 1;
    final targetRate = _currencyRepo.exchangeRates[targetCurrency.isoCode] ?? 1;

    _defaultRate = targetRate / initRate;
  }

  @override
  void dispose() {
    super.dispose();
    _exRateController.dispose();
  }
}

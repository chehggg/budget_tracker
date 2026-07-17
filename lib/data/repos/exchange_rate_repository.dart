import 'package:budget_tracker/data/services/api_service.dart';
import 'package:budget_tracker/utils/result.dart';

class ExchangeRateRepository {
  ExchangeRateRepository({required ApiServices apiServices}) : _apiServices = apiServices {
    _initFuture = _init();
  }

  final ApiServices _apiServices;

  Future<void> restart() async {
    await _init();
  }
  
  Future<void> _init() async {
    final result = await _apiServices.getExchangeRate();
    switch (result) {
      case Ok():
        _exchangeRates = result.value.rates ?? {};
      case Error():
        _exchangeRates = {};
    }
  }

  Future<void>? _initFuture;
  Future<void> get ready => _initFuture ?? Future.value();

  Map<String, double> _exchangeRates = {};
  Map<String, double> get exchangeRates => _exchangeRates;
}

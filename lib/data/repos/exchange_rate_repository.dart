import 'package:budget_tracker/data/services/api_service.dart';
import 'package:budget_tracker/utils/result.dart';

class ExchangeRateRepository {
  ExchangeRateRepository({required ApiServices apiServices}) : _apiServices = apiServices {
    _initFuture = init();
  }

  final ApiServices _apiServices;

  Future<void> init() async {
    final result = await _apiServices.getExchangeRate();
    switch (result) {
      case Ok():
        _exchangeRates = result.value.rates ?? {};
      case Error():
        _exchangeRates = {};
    }
  }

  late final Future<void> _initFuture;
  Future<void> get ready => _initFuture;

  Map<String, double> _exchangeRates = {};
  Map<String, double> get exchangeRates => _exchangeRates;
}

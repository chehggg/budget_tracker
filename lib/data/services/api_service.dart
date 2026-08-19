import 'package:budget_tracker/constants/api_key.dart';
import 'package:budget_tracker/custom/classes/exchange_rate_class.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  final pref = SharedPreferencesAsync();

  Future<void> storeExchangeRateAsCache(String json) async {
    await pref.setString("exchangeRate", json);
  }

  Future<Result<ExchangeRateResponse>> getExchangeRate() async {
    try {
      final String? cache = await pref.getString("exchangeRate");
      debugPrint("Exchange rate cache: $cache");
      if (cache != null) {
        final response = ExchangeRateResponse.fromJson(cache);
        if (response.date?.isBefore(DateTime.now().standard) ?? false) {
          return await getDataFromApi();
        } else {
          debugPrint(
            "Local service return exchange rate from cache!, rate lengths: ${response.rates?.length}",
          );
          return Result.ok(response);
        }
      } else {
        return await getDataFromApi();
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<ExchangeRateResponse>> getDataFromApi() async {
    try {
      debugPrint("Get exchange rate data from API");
      final baseUri = Uri.parse(
        "https://api.exchangeratesapi.io/v1/latest",
      );
      final uri = baseUri.replace(
        queryParameters: {"access_key": exchangeRateKey},
      );
      final http.Response response = await http.get(uri);
      final body = ExchangeRateResponse.fromJson(response.body);
      if (response.statusCode == 200) {
        debugPrint("Raw data: ${response.body}");
        await storeExchangeRateAsCache(response.body);
        return Result.ok(body);
      } else {
        debugPrint("Raw data: ${response.body}");
        return Result.error(Exception("${body.error?['code']}: ${body.error?['message']}"));
      }
    } on Exception catch (e) {
      debugPrint("cannot retrieve exchange rate in api service, $e");
      return Result.error(e);
    }
  }
}

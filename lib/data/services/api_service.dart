import 'package:budget_tracker/custom/classes/exchange_rate_class.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  final key = "2b09be99ce5fa53c61fa61f828abd9bd";
  final pref = SharedPreferencesAsync();

  Future<void> storeExchangeRateAsCache(String json) async {
    await pref.setString("exchangeRate", json);
  }

  Future<Result<ExchangeRateResponse>> getExchangeRate() async {
    try {
      final String? cache = await pref.getString("exchangeRate");

      if (cache != null) {
        final response = ExchangeRateResponse.fromJson(cache);
        if (response.date?.isBefore(DateTime.now().standard) ?? false) {
          return await getDataFromApi();
        } else {
          return Result.ok(ExchangeRateResponse.fromJson(cache));
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
      final url = Uri(
        path: "https://api.exchangeratesapi.io/v1/latest",
        queryParameters: {"acccess_key": key},
      );
      final http.Response response = await http.get(url);
      final body = ExchangeRateResponse.fromJson(response.body);
      if (response.statusCode == 200) {
        await storeExchangeRateAsCache(response.body);
        return Result.ok(body);
      } else {
        return Result.error(Exception("${body.error?['type']}: ${body.error?['info']}"));
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}

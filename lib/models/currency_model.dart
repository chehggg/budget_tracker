import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyModel extends ChangeNotifier {
  // CurrencyModel(){
  //   getCurrencyList();
  //   getExchangeRate();
  // }
  
  Map<String, dynamic> _currencies = {};
  Map<String, dynamic> _rates = {};

  UnmodifiableMapView<String, dynamic> get currencies => UnmodifiableMapView(_currencies); 
  UnmodifiableMapView<String, dynamic> get rates => UnmodifiableMapView(_rates); 
  
  Future<void> getCurrencyList() async {
    final sharedPref = SharedPreferencesAsync();
    final c = await sharedPref.getString('currencies');
    if (c == null) {
      final String exchangeUrl = 'https://openexchangerates.org/api/currencies.json';
      final http.Response response = await http.get(Uri.parse(exchangeUrl));
      _currencies = jsonDecode(response.body) as Map<String,dynamic>;

      await sharedPref.setString("currencies", response.body);
    } else {
      _currencies = jsonDecode(c) as Map<String,dynamic>;
    }
    notifyListeners();
  }

  Future<void> getExchangeRate() async {
    Future<http.Response> getRateApi() async {
      final String appId = '2c55cdcc21cd43a1812ef122de1ae59b';
      final String convertCurrencyUrl = 'https://openexchangerates.org/api/latest.json?app_id=$appId';

      return await http.get(Uri.parse(convertCurrencyUrl));
    }

    final sharedPref = SharedPreferencesAsync();
    final rates = await sharedPref.getString('exchangeRate');
    final timestamp = await sharedPref.getInt('exchangeRateLastRetrievedTimestamp');
    final currentUnix = (DateTime.now().millisecondsSinceEpoch/1000).round();

    debugPrint("timestamp: $timestamp");
    debugPrint("current timestamp: $currentUnix");
    if (timestamp == null || currentUnix - timestamp > 300) {
      debugPrint("update exchange rates");
      final response = await getRateApi();
      _rates = jsonDecode(response.body)['rates'] as Map<String, dynamic>;
      // await sharedPref.setInt("exchangeRateLastRetrievedTimestamp", int.parse(jsonDecode(response.body)['timestamp']));
      await sharedPref.setString("exchangeRate", jsonEncode(jsonDecode(response.body)['rates'] as Map<String,dynamic>));
    } else {
      _rates = jsonDecode(rates!) as Map<String,dynamic>;
      await sharedPref.setInt("exchangeRateLastRetrievedTimestamp", currentUnix);
    }
    notifyListeners();
  }
}
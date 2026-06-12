import 'dart:convert';
import 'dart:io';

import 'package:budget_tracker/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  final sharedPref = SharedPreferencesAsync();

  Future<Result<String>> getCurrency() async {
    final customCurrency = await sharedPref.getString('currency');

    if (customCurrency == null) {
      final format = NumberFormat.simpleCurrency(locale: Platform.localeName);
      return Result.ok(format.currencySymbol);
    } 

    return Result.ok(customCurrency);
  }

  Future<Result<Color>> getAccentColor() async {
    final accentColor = await sharedPref.getInt('currency');
    
    if (accentColor == null) {
      return Result.ok(Colors.amber);
    }
    return Result.ok(Color(accentColor));
  }

  Future<Result<List<Map>>> getCurrencies() async {
    final response = await rootBundle.loadString('assets/currencies.json');
    final data = jsonDecode(response);
    return Result.ok(data as List<Map>);
  }

}
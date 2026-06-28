// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:budget_tracker/custom/extensions/extensions.dart';

class ExchangeRateResponse {
  ExchangeRateResponse({
    this.success,
    this.base,
    this.date,
    this.rates,
    this.error,
  });

  final bool? success;
  final String? base;
  final DateTime? date;
  final Map<String, double>? rates;
  final Map<String, dynamic>? error;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'success': success,
      'base': base,
      'date': date?.formatStd(),
      'rates': rates,
      'error': error,
    };
  }

  factory ExchangeRateResponse.fromMap(Map<String, dynamic> map) {
    return ExchangeRateResponse(
      success: map['success'] != null ? map['success'] as bool : null,
      base: map['base'] != null ? map['base'] as String : null,
      date: map['date'] != null ? (map['date'] as String).dateParseStd() : null,
      rates:
          map['rates'] != null
              ? (map['rates'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(key, (value as num).toDouble()),
              )
              : null,
      error:
          map['error'] != null
              ? Map<String, dynamic>.from((map['error'] as Map<String, dynamic>))
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ExchangeRateResponse.fromJson(String source) =>
      ExchangeRateResponse.fromMap(json.decode(source) as Map<String, dynamic>);
}

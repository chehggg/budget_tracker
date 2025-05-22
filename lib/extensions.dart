import 'dart:math';
import 'package:intl/intl.dart';

extension DayExtension on DateTime {
  int getTotalDayInMonth({int pastMonth = 0}) {
    return DateTime(year, month + 1 - pastMonth, 0).day; 
  }

  bool isInSameYearMonthAs(DateTime anotherDate) {
    return (month == anotherDate.month && year == anotherDate.year); 
  }

  String standardFormat() =>  DateFormat("yyyy-MM-dd").format(this);
  String displayFormat() =>  DateFormat("d MMM").format(this);

  List<int> getFullMonthWeekdayList() {
    final int days = getTotalDayInMonth();
    final int startDateWeekday = DateTime(year,month,1).weekday;
    int currentWeekday = startDateWeekday - 1;
    
    return List.generate(days, (day) {
      currentWeekday ++;
      if (currentWeekday == 8 ) {
        currentWeekday = 1;
      } 
      return currentWeekday; 
    });
  }
}

extension DoubleExtension on double {
  double ceilingToFirstDigit() {
    final maxValueDigit = (toInt()).toString().length;
    return pow(10, maxValueDigit - 1) * ((this / pow(10, maxValueDigit - 1)).toInt() + 1);
  } 

  String customCurrencyFormat(String currencySymbol, {bool usePositiveSign = false, bool useSuffix = false }) {
    final absValue = abs();
    final sign = this < 0 ? "-" : usePositiveSign ? "+" : "";
    if (useSuffix) {
      return sign + currencySymbol + NumberFormat.compact().format(absValue);
    }
    if (absValue % 1 == 0) {
      return NumberFormat("$sign$currencySymbol#,##0").format(absValue);
    } else {
      return NumberFormat("$sign$currencySymbol#,##0.00").format(absValue);
    }
  }
  // double formatPerce
} 

extension StringExtension on String {
  DateTime standardDateParse() => DateFormat("yyyy-MM-dd").parse(this);

  String capitalizeFirstLetter(){
    final List<String> substrings = split(" ");
    String capitalizeString = '';
    for (String substring in  substrings) {
      final int firstLetterIndex = substring.indexOf(RegExp(r'[a-z]')); 
      final capitalizedSubString = substring.replaceRange(
        firstLetterIndex, 
        firstLetterIndex, 
        substring[firstLetterIndex].toUpperCase()
      );
      capitalizeString += ("$capitalizedSubString ");
    }
    return capitalizeString.trim();
  }

  double parseCustomDecimalPlace(int decimalPlace) {
    return double.parse(double.parse(this).toStringAsFixed(decimalPlace));
  }
}

extension IterableExtension on Iterable<double> {
  double? maxCeiling() {
    final double maxValue = reduce(max);
    final digit = maxValue.round().toString().length - 2;
    // debugPrint("digit: ${digit}, maxvalue: ${maxValue}, ${(maxValue/(pow(10,4)))}");
    return (maxValue/(pow(10,digit))).ceil() * (pow(10,digit).toDouble());
  }
}
import 'dart:math';
import 'package:budget_tracker/constants/categories.dart';
import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money2/money2.dart';

extension DayExtension on DateTime {
  int getTotalDayInMonth({int pastMonth = 0}) {
    return DateTime(year, month + 1 - pastMonth, 0).day;
  }

  bool isInSameYearMonthAs(DateTime anotherDate) {
    return (month == anotherDate.month && year == anotherDate.year);
  }

  String formatStd() => DateFormat("yyyy-MM-dd").format(this);
  String displayFormat() => DateFormat("d MMM").format(this);
  String formatFull() => DateFormat('MMMM dd, yyyy').format(this);
  String formatShort() => DateFormat('dd-MM-yyyy').format(this);

  /// format datetime in "dd MMM" format
  String formatShorter() => DateFormat('dd MMM').format(this);

  /// format datetime in "d MMM" format
  String formatEvenShorter() => DateFormat('d MMM').format(this);

  /// format datetime in "MMM yyyy" format
  String formatMonth() => DateFormat('MMM yyyy').format(this);

  /// format datetime in "MMMM yyyy" format
  String formatMonthLonger() => DateFormat('MMMM yyyy').format(this);

  /// format datetime in "E, d MMM" format
  String formatPretty({Locale? locale}) {
    if (locale?.languageCode == "ja") {
      return DateFormat('MMMd日 (E)', locale.toString()).format(this);
    }
    return DateFormat('E, d MMM', locale?.toString()).format(this);
  }

  String formatPrettyShort({Locale? locale}) => DateFormat('d MMM yyyy').format(this);
  // String formatPretty({Locale? locale}) => DateFormat('E, d MMM', locale.toString()).format(this);

  DateTime toSOM(int addMonth) => DateTime(year, month + addMonth, 1);
  DateTime toEOM(int addMonth) => DateTime(year, month + addMonth + 1, 0);
  DateTime addYear(int addYear) => DateTime(year + addYear, month, day);
  DateTime addWeek(int addWeek) => DateTime(year, month, day + (addWeek * 7));
  DateTime addMonth(int addMonth) => DateTime(year, month + addMonth, day);
  DateTime addDay(int addDay) => DateTime(year, month, day + addDay);
  DateTime get standard => DateTime(year, month, day);
  DateTime get startOfMonth => DateTime(year, month, 1);
  DateTime get endOfMonth => DateTime(year, month + 1, 0);
  DateTime get startOfYear => DateTime(year, 1, 1);
  DateTime get endOfYear => DateTime(year, 12, 31);
  DateTime get startOfWeek => DateTime(year, month, day - (weekday - 1));
  DateTime get endOfWeek => DateTime(year, month, day - (weekday - 1) + 6);
  int get dayinCurrentMonth => DateTime(year, month + 1, 0).day;

  bool isWithinRange(DateTimeRange range, {bool inclusive = true, bool setEndToEoM = false}) {
    final realEnd = setEndToEoM ? range.end.endOfMonth : range.end;
    if (!inclusive) {
      return isBefore(realEnd) && isAfter(range.start);
    }
    return (isBefore(realEnd) || isAtSameMomentAs(realEnd)) && isAfter(range.start) ||
        isAtSameMomentAs(range.start);
  }

  bool isBeforeOrSameMoment(DateTime newDate) {
    return (isBefore(newDate) || isAtSameMomentAs(newDate));
  }

  bool isAfterOrSameMoment(DateTime newDate) {
    return (isAfter(newDate) || isAtSameMomentAs(newDate));
  }

  List<int> getFullMonthWeekdayList() {
    final int days = getTotalDayInMonth();
    final int startDateWeekday = DateTime(year, month, 1).weekday;
    int currentWeekday = startDateWeekday - 1;

    return List.generate(days, (day) {
      currentWeekday++;
      if (currentWeekday == 8) {
        currentWeekday = 1;
      }
      return currentWeekday;
    });
  }
}

extension DateTimeRangeExtension on DateTimeRange {
  String formatYearMonth() {
    return "${start.formatMonth()} - ${end.formatMonth()}";
  }
}

extension DoubleExtension on double {
  double ceilingToFirstDigit() {
    final maxValueDigit = (toInt()).toString().length;
    return pow(10, maxValueDigit - 1) * ((this / pow(10, maxValueDigit - 1)).toInt() + 1);
  }

  String compactFormat() {
    if (this < 1000) {
      return toStringAsFixed(0);
    } else {
      return NumberFormat.compact().format(this);
    }
  }

  String formatRoundedString() {
    if (this % 1 == 0) {
      return toStringAsFixed(0);
    } else {
      return toStringAsFixed(2);
    }
  }

  String formatCompactPercentage() {
    return NumberFormat.percentPattern().format(this);
  }

  String formatSignedCompactPercentage() {
    return NumberFormat('+#0%;-#0%').format(this);
  }

  String formatDecimalPercentage() {
    return NumberFormat.decimalPercentPattern(decimalDigits: 1).format(this);
  }

  String customCurrencyFormat(
    String currencySymbol, {
    bool usePositiveSign = false,
    bool useSuffix = false,
    bool round = false,
  }) {
    final absValue = abs();
    final sign =
        this < 0
            ? "-"
            : usePositiveSign
            ? "+"
            : "";
    if (useSuffix) {
      return sign + currencySymbol + NumberFormat.compact().format(absValue);
    }
    if (absValue % 1 == 0 || round) {
      return NumberFormat("$sign$currencySymbol#,##0").format(absValue);
    } else {
      return NumberFormat("$sign$currencySymbol#,##0.00").format(absValue);
    }
  }

  double calculatePercentageChange(double previousValue) {
    return (this - previousValue) / (previousValue.abs());
  }

  // double formatPerce
}

extension StringExtension on String {
  DateTime dateParseStd() => DateFormat("yyyy-MM-dd").parse(this);
  DateTime? dateParseFull() => DateFormat('MMMM dd, yyyy').tryParse(this);
  DateTime dateParseShort() => DateFormat('dd-MM-yyyy').parse(this);

  String capitalize() {
    final first = substring(0, 1).toUpperCase();
    final second = substring(1, length);
    return first + second;
  }

  String capitalizeFirstLetter() {
    final List<String> substrings = split(" ");
    String capitalizeString = '';
    for (String substring in substrings) {
      final int firstLetterIndex = substring.indexOf(RegExp(r'[a-z]'));
      final capitalizedSubString = substring.replaceRange(
        firstLetterIndex,
        firstLetterIndex,
        substring[firstLetterIndex].toUpperCase(),
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
    return (maxValue / (pow(10, digit))).ceil() * (pow(10, digit).toDouble());
  }
}

@immutable
class MyTexts extends ThemeExtension<MyTexts> {
  const MyTexts({
    this.numberLabel,
    this.numberFontLarge,
    this.numberFontMedium,
    this.numberFontSmall,
    this.elegantLabel,
    this.elegantLabelLarge,
    this.dateLabel,
    this.paragraphTitle,
    this.paragraphText,
    this.paragraphTextSmall,
  });

  final TextStyle? numberFontLarge;
  final TextStyle? numberFontMedium;
  final TextStyle? numberFontSmall;
  final TextStyle? numberLabel;
  final TextStyle? elegantLabel;
  final TextStyle? elegantLabelLarge;
  final TextStyle? dateLabel;
  final TextStyle? paragraphText;
  final TextStyle? paragraphTitle;
  final TextStyle? paragraphTextSmall;
  // final TextStyle? numberLabel;
  // final TextStyle? numberLabel;

  @override
  MyTexts copyWith({TextStyle? numberFont, TextStyle? numberLabel}) {
    return MyTexts(
      numberFontLarge: numberFont ?? numberFontLarge,
      numberFontMedium: numberFont ?? numberFontMedium,
      numberFontSmall: numberFont ?? numberFontSmall,
      numberLabel: numberLabel ?? this.numberLabel,
      dateLabel: dateLabel ?? dateLabel,
      paragraphText: paragraphText ?? paragraphText,
      paragraphTextSmall: paragraphTextSmall ?? paragraphTextSmall,
      paragraphTitle: paragraphTitle ?? paragraphTitle,
    );
  }

  @override
  MyTexts lerp(MyTexts? other, double t) {
    if (other is! MyTexts) {
      return this;
    }
    return MyTexts(
      numberFontLarge: TextStyle.lerp(numberFontLarge, other.numberFontLarge, t),
      numberFontMedium: TextStyle.lerp(numberFontMedium, other.numberFontMedium, t),
      numberFontSmall: TextStyle.lerp(numberFontSmall, other.numberFontSmall, t),
      numberLabel: TextStyle.lerp(numberLabel, other.numberLabel, t),
      dateLabel: TextStyle.lerp(dateLabel, other.dateLabel, t),
      paragraphText: TextStyle.lerp(paragraphText, other.paragraphText, t),
      paragraphTextSmall: TextStyle.lerp(paragraphTextSmall, other.paragraphTextSmall, t),
      paragraphTitle: TextStyle.lerp(paragraphTitle, other.paragraphTitle, t),
    );
  }
}

@immutable
class MyColors extends ThemeExtension<MyColors> {
  const MyColors({
    this.flipCardColor,
    this.dropdownColor,
    this.onFlipCard,
    this.fadeColor1,
    this.fadeColor2,
    this.fadeColor3,
    this.fadeColor4,
    // this.numberFontLarge,
    // this.numberFontMedium,
    // this.numberFontSmall,
    // this.dateLabel
  });

  // final TextStyle? numberFontLarge;
  // final TextStyle? numberFontMedium;
  // final TextStyle? numberFontSmall;
  final Color? flipCardColor;
  final Color? dropdownColor;
  final Color? onFlipCard;
  final Color? fadeColor1;
  final Color? fadeColor2;
  final Color? fadeColor3;
  final Color? fadeColor4;
  // final TextStyle? dateLabel;
  // final TextStyle? flipCardColor;
  // final TextStyle? flipCardColor;

  @override
  MyColors copyWith({Color? flipCardColor, Color? onFlipCard}) {
    return MyColors(
      flipCardColor: flipCardColor ?? this.flipCardColor,
      dropdownColor: dropdownColor ?? this.dropdownColor,
      onFlipCard: onFlipCard ?? this.onFlipCard,
      fadeColor1: fadeColor1 ?? fadeColor1,
      fadeColor2: fadeColor2 ?? fadeColor2,
      fadeColor3: fadeColor3 ?? fadeColor3,
      fadeColor4: fadeColor4 ?? fadeColor4,
    );
  }

  @override
  MyColors lerp(MyColors? other, double t) {
    if (other is! MyColors) {
      return this;
    }
    return MyColors(
      flipCardColor: Color.lerp(flipCardColor, other.flipCardColor, t),
      dropdownColor: Color.lerp(dropdownColor, other.dropdownColor, t),
      onFlipCard: Color.lerp(onFlipCard, other.onFlipCard, t),
      fadeColor1: Color.lerp(fadeColor1, other.fadeColor1, t),
      fadeColor2: Color.lerp(fadeColor2, other.fadeColor2, t),
      fadeColor3: Color.lerp(fadeColor3, other.fadeColor3, t),
      fadeColor4: Color.lerp(fadeColor4, other.fadeColor3, t),
    );
  }
}

class CustomUtils {
  double mapToRange({
    required double value,
    required double min,
    required double max,
  }) {
    // Prevent division by zero if min and max are identical
    if (max - min == 0) return 0.0;

    // Calculate percentage and clamp between 0.0 and 1.0
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }

  CostItemCategory? findInList(String name) {
    return defaultCostItemCategories.firstWhereOrNull((cat) => cat.name == name);
  }
}

extension VisualDensityExtension on VisualDensity {
  static VisualDensity get minimum => VisualDensity(horizontal: -4.0, vertical: -4.0);
}

extension CurrencyExtension on Currency {
  bool get symbolOnLeft => pattern.startsWith("S");
}

extension IntegerExtension on int {
  String getPlural({String? customPlural}) {
    if (this >= 2) {
      return customPlural ?? "s";
    } else {
      return "";
    }
  }
}

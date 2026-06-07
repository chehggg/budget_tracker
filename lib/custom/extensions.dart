import 'dart:math';
import 'package:budget_tracker/constants/categories.dart';
import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/ui/form/form_viewmodel.dart';
import 'package:budget_tracker/ui/list/list_viewmodel.dart';
import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/models/navigation_model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  String formatPretty() => DateFormat('E, d MMM').format(this);

  DateTime get startOfMonth => DateTime(year, month, 1);

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

extension DoubleExtension on double {
  double ceilingToFirstDigit() {
    final maxValueDigit = (toInt()).toString().length;
    return pow(10, maxValueDigit - 1) * ((this / pow(10, maxValueDigit - 1)).toInt() + 1);
  }

  String customCurrencyFormat(
    String currencySymbol, {
    bool usePositiveSign = false,
    bool useSuffix = false,
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
    if (absValue % 1 == 0) {
      return NumberFormat("$sign$currencySymbol#,##0").format(absValue);
    } else {
      return NumberFormat("$sign$currencySymbol#,##0.00").format(absValue);
    }
  }
  // double formatPerce
}

extension StringExtension on String {
  DateTime dateParseStd() => DateFormat("yyyy-MM-dd").parse(this);
  DateTime dateParseFull() => DateFormat('MMMM dd, yyyy').parse(this);
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

extension BuildContextExtension on BuildContext {
  ThemeData get _theme => Theme.of(this);
  NavigatorState get nav => Navigator.of(this);
  TextTheme get tt => _theme.textTheme;
  ColorScheme get cs => _theme.colorScheme;
  MyTexts get customTt => _theme.extension<MyTexts>()!;
  MyColors get customCs => _theme.extension<MyColors>()!;

  MediaQueryData get mq => MediaQuery.of(this);

  AppModel get appMod => read<AppModel>();
  NavigationModel get navMod => read<NavigationModel>();
  FormModel get formMod => read<FormModel>();
  ThemeModel get themeMod => read<ThemeModel>();
  ListModel get listMod => read<ListModel>();
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
  });

  final TextStyle? numberFontLarge;
  final TextStyle? numberFontMedium;
  final TextStyle? numberFontSmall;
  final TextStyle? numberLabel;
  final TextStyle? elegantLabel;
  final TextStyle? elegantLabelLarge;
  final TextStyle? dateLabel;
  // final TextStyle? numberLabel;
  // final TextStyle? numberLabel;

  @override
  MyTexts copyWith({TextStyle? numberFont, TextStyle? numberLabel}) {
    return MyTexts(
      numberFontLarge: numberFont ?? this.numberFontLarge,
      numberFontMedium: numberFont ?? this.numberFontMedium,
      numberFontSmall: numberFont ?? this.numberFontSmall,
      numberLabel: numberLabel ?? this.numberLabel,
      dateLabel: dateLabel ?? this.dateLabel,
    );
  }

  @override
  MyTexts lerp(MyTexts? other, double t) {
    if (other is! MyTexts) {
      return this;
    }
    return MyTexts(
      numberFontLarge: TextStyle.lerp(numberFontLarge, other.numberFontLarge, t),
      numberFontMedium: TextStyle.lerp(numberFontMedium, other.numberFontLarge, t),
      numberFontSmall: TextStyle.lerp(numberFontSmall, other.numberFontSmall, t),
      numberLabel: TextStyle.lerp(numberLabel, other.numberLabel, t),
      dateLabel: TextStyle.lerp(dateLabel, other.dateLabel, t),
    );
  }
}

@immutable
class MyColors extends ThemeExtension<MyColors> {
  const MyColors({
    this.flipCardColor,
    this.onFlipCard,
    this.fadeColor1,
    this.fadeColor2,
    this.fadeColor3,
    // this.numberFontLarge,
    // this.numberFontMedium,
    // this.numberFontSmall,
    // this.dateLabel
  });

  // final TextStyle? numberFontLarge;
  // final TextStyle? numberFontMedium;
  // final TextStyle? numberFontSmall;
  final Color? flipCardColor;
  final Color? onFlipCard;
  final Color? fadeColor1;
  final Color? fadeColor2;
  final Color? fadeColor3;
  // final TextStyle? dateLabel;
  // final TextStyle? flipCardColor;
  // final TextStyle? flipCardColor;

  @override
  MyColors copyWith({Color? flipCardColor, Color? onFlipCard}) {
    return MyColors(
      flipCardColor: flipCardColor ?? this.flipCardColor,
      onFlipCard: onFlipCard ?? this.onFlipCard,
    );
  }

  @override
  MyColors lerp(MyColors? other, double t) {
    if (other is! MyColors) {
      return this;
    }
    return MyColors(
      flipCardColor: Color.lerp(flipCardColor, other.flipCardColor, t),
      onFlipCard: Color.lerp(onFlipCard, other.onFlipCard, t),
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

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/enums/match_type.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';

class CostItem {
  const CostItem({
    this.name,
    this.amount,
    this.categoryId,
    this.uuid,
    this.lastCreated,
    this.lastModified,
    this.date,
    this.costType,
  });

  final String? uuid;
  final String? categoryId;
  final String? name;
  final double? amount;
  final DateTime? date;
  final CostType? costType;
  final DateTime? lastCreated;
  final DateTime? lastModified;

  // create cost item into json
  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'date': date?.formatStd(),
    'costType': costType?.name,
    'categoryId': categoryId,
    'amount': amount,
    'name': name,
    'lastCreated': lastCreated?.toString(),
    'lastModified': lastModified?.toString(),
  };

  CostItem.fromJson(Map<String, dynamic> json)
    : uuid = json['uuid'] as String?,
      name = json['name'] as String?,
      amount = json['amount'] as double?,
      categoryId = json['categoryId'] as String?,
      costType = CostType.values.byName(json['costType'] as String? ?? 'expense'),
      date = (json['date'] as String?)?.dateParseStd(),
      lastCreated = DateTime.tryParse(json['lastCreated'] ?? "") ?? DateTime.now(),
      lastModified = DateTime.tryParse(json['lastModified'] ?? "") ?? DateTime.now();

  bool get isExpense => costType == CostType.expense;
  double get absoluteAmount => costType == CostType.expense ? 0 - amount! : amount!;

  // double get signedAmount => isExpense ? 0 - amount : amount;

  // List<dynamic> toCsv() {
  //   final jsonObject = toJson();
  //   return List.generate(jsonObject.length, (i) => jsonObject.values.elementAt(i));
  // }

  // CostItem.fromCsv(List<dynamic> list, {bool newId = false})
  //   : uuid = newId ? Uuid().v4() : list[0] as String,
  //     date = (list[1] as String).dateParseStd(),
  //     costType = CostType.values.where((costType) => costType.name == list[2] as String).first,
  //     category = list[3] as String,
  //     categoryId = list[4] as String,
  //     amount = double.tryParse(list[5] as String) ?? 0,
  //     name = list[6] as String,
  //     lastCreated = DateTime.tryParse(list.elementAtOrNull(7)) ?? DateTime.now(),
  //     lastModified = DateTime.tryParse(list.elementAtOrNull(8)) ?? DateTime.now();

  // CostItem.fromCsvLegacy(List<dynamic> list, {bool newId = false})
  //   : uuid = newId ? Uuid().v4() : list[0] as String,
  //     date = (list[1] as String).dateParseStd(),
  //     costType = CostType.values.where((costType) => costType.name == list[2] as String).first,
  //     category = list[3] as String,
  //     amount = double.tryParse(list[4] as String) ?? 0,
  //     name = list[5] as String,
  //     lastCreated = DateTime.tryParse(list.elementAtOrNull(6)) ?? DateTime.now(),
  //     lastModified = DateTime.tryParse(list.elementAtOrNull(7)) ?? DateTime.now();

  CostItem copyWith({
    String? uuid,
    String? categoryId,
    String? name,
    double? amount,
    DateTime? date,
    CostType? costType,
    DateTime? lastCreated,
    DateTime? lastModified,
  }) {
    return CostItem(
      uuid: uuid ?? this.uuid,
      categoryId: categoryId ?? this.categoryId ?? "0",
      name: name ?? this.name,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      costType: costType ?? this.costType,
      lastCreated: lastCreated ?? this.lastCreated,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}

class NoteHistory {
  const NoteHistory({required this.categoryName, required this.note});

  final String categoryName;
  final String note;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NoteHistory) return false;
    return categoryName == other.categoryName && note == other.note;
  }

  @override
  int get hashCode => categoryName.hashCode ^ note.hashCode;

  NoteHistory.fromJson(Map<String, dynamic> json)
    : categoryName = json['categoryName'] as String,
      note = json['note'] as String;

  Map<String, String> toJson() => {'categoryName': categoryName, 'note': note};
}

class CategoryGroupMetric {
  const CategoryGroupMetric({
    this.costItem,
    this.metric,
  });

  final List<CostItem>? costItem;
  final CostMetric? metric;
}

class FormArgument {
  const FormArgument({
    // required this.isNew,
    this.oriRoute,
    this.selectedCostItem,
  });

  // final bool isNew;
  final String? oriRoute;
  final CostItem? selectedCostItem;
}

class CostMetric {
  CostMetric({
    this.expense = 0,
    this.income = 0,
  });

  double? expense;
  double? income;

  double get balance => (income ?? 0) - (expense ?? 0);

  void combine(CostMetric otherMetric) {
    expense = expense! + otherMetric.expense!;
    income = income! + otherMetric.income!;
  }

  void addToMetric(CostItem costItem) {
    expense = expense! + (costItem.costType == CostType.expense ? costItem.amount ?? 0 : 0);
    income = income! + (costItem.costType == CostType.income ? costItem.amount ?? 0 : 0);
  }

  void minusFromMetric(CostItem costItem) {
    expense = expense! - (costItem.costType == CostType.expense ? costItem.amount ?? 0 : 0);
    income = income! - (costItem.costType == CostType.income ? costItem.amount ?? 0 : 0);
  }

  factory CostMetric.fromCostItemList(List<CostItem> items) {
    double expense = 0;
    double income = 0;

    for (CostItem item in items) {
      if (item.isExpense) {
        expense += item.amount ?? 0;
      } else {
        income += item.amount ?? 0;
      }
    }

    return CostMetric(expense: expense, income: income);
  }

  CostMetric combineWith(CostMetric otherMetric) {
    return CostMetric(
      expense: (this.expense ?? 0) + (otherMetric.expense ?? 0),
      income: (this.income ?? 0) + (otherMetric.income ?? 0),
    );
  }

  bool get isEmpty => income == 0 && expense == 0;
}

class StringFilter {
  StringFilter({required this.query, required this.matchType});

  final String query;
  final StringMatchType matchType;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'query': query,
      'matchType': matchType.name,
    };
  }

  factory StringFilter.initial() => StringFilter(query: "", matchType: StringMatchType.contain);

  factory StringFilter.fromMap(Map<String, dynamic> map) {
    return StringFilter(
      query: map['query'] as String,
      matchType: StringMatchType.values.byName(['matchType'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  StringFilter copyWith({StringMatchType? type, String? newQuery}) {
    return StringFilter(matchType: type ?? this.matchType, query: newQuery ?? this.query);
  }

  factory StringFilter.fromJson(String source) =>
      StringFilter.fromMap(json.decode(source) as Map<String, dynamic>);

  bool checkMatch(String text) {
    switch (matchType) {
      case StringMatchType.contain:
        return text.contains(query);
      case StringMatchType.notContain:
        return !text.contains(query);
      case StringMatchType.match:
        return text == query;
      case StringMatchType.notMatch:
        return text != query;
      case StringMatchType.startWith:
        return text.startsWith(query);
      case StringMatchType.notStartWith:
        return !text.startsWith(query);
      case StringMatchType.endWith:
        return text.endsWith(query);
      case StringMatchType.notEndWith:
        return !text.endsWith(query);
    }
  }
}

class PriceRangeFilter {
  PriceRangeFilter({required this.firstValue, this.secondValue, required this.matchType});

  final double firstValue;
  final double? secondValue;
  final NumRangeMatchType matchType;

  bool isInRange(double amount) {
    switch (matchType) {
      case NumRangeMatchType.lt:
        return amount > firstValue;
      case NumRangeMatchType.lte:
        return amount >= firstValue;
      case NumRangeMatchType.st:
        return amount < firstValue;
      case NumRangeMatchType.ste:
        return amount <= firstValue;
      case NumRangeMatchType.btn:
        return amount >= firstValue && amount <= secondValue!;
    }
  }
}

class CategoryIconResult {
  CategoryIconResult({this.path, this.iconName});

  final String? path;
  final String? iconName;
}

class FontAwesomeIcon {
  FontAwesomeIcon({required this.icon, required this.name});

  final FaIconData icon;
  final String name;
}

class AccentColor {
  AccentColor({
    required this.positive,
    required this.negative,
    required this.previous,
    required this.current,
  });

  final Color positive;
  final Color negative;
  final Color previous;
  final Color current;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'positive': positive.toHexString(),
      'negative': negative.toHexString(),
      'previous': previous.toHexString(),
      'current': current.toHexString(),
    };
  }

  factory AccentColor.fromMap(Map<String, dynamic> map) {
    return AccentColor(
      positive:
          map['positive'] != null
              ? ((map['positive'] as String).toColor() ?? Colors.green)
              : Colors.green,
      negative:
          map['negative'] != null
              ? ((map['negative'] as String).toColor() ?? Colors.red)
              : Colors.red,
      previous:
          map['previous'] != null
              ? ((map['previous'] as String).toColor() ?? Colors.blue)
              : Colors.blue,
      current:
          map['previous'] != null
              ? ((map['previous'] as String).toColor() ?? Colors.amber)
              : Colors.amber,
    );
  }

  String toJson() => json.encode(toMap());

  factory AccentColor.fromJson(String source) =>
      AccentColor.fromMap(json.decode(source) as Map<String, dynamic>);

  AccentColor copyWith({
    Color? positive,
    Color? negative,
    Color? previous,
    Color? current,
  }) {
    return AccentColor(
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      previous: previous ?? this.previous,
      current: current ?? this.current,
    );
  }
}

class ListDisplayConfig {
  ListDisplayConfig({
    this.showAmountColor = true,
    this.showTotalColor = true,
    this.hideAmountOnStart = false,
  });

  final bool showAmountColor;
  final bool showTotalColor;
  final bool hideAmountOnStart;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'showAmountColor': showAmountColor,
      'showTotalColor': showTotalColor,
      'hideAmountOnStart': hideAmountOnStart,
    };
  }

  factory ListDisplayConfig.fromMap(Map<String, dynamic> map) {
    return ListDisplayConfig(
      showAmountColor: map['showAmountColor'] as bool,
      showTotalColor: map['showTotalColor'] as bool,
      hideAmountOnStart: map['hideAmountOnStart'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory ListDisplayConfig.fromJson(String source) =>
      ListDisplayConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  ListDisplayConfig copyWith({
    bool? showAmountColor,
    bool? showTotalColor,
    bool? hideAmountOnStart,
  }) {
    return ListDisplayConfig(
      showAmountColor: showAmountColor ?? this.showAmountColor,
      showTotalColor: showTotalColor ?? this.showTotalColor,
      hideAmountOnStart: hideAmountOnStart ?? this.hideAmountOnStart,
    );
  }
}

class CategoryBreakdownSort {
  CategoryBreakdownSort({
    required this.categoryOrder,
    required this.categorySortBy,
    required this.itemOrder,
    required this.itemSortBy,
  });

  final SortType categoryOrder;
  final String categorySortBy;
  final SortType itemOrder;
  final String itemSortBy;
}

import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

class CostItem {
  CostItem(
    this.name,
    this.amount,
    this.category, {
    this.categoryId,
    this.uuid,
    this.image,
    this.lastCreated,
    this.lastModified,
    required this.date,
    required this.costType,
  });

  String? uuid;
  String category;
  String? categoryId;
  String? image;
  String name;
  double amount;
  DateTime date;
  CostType costType;
  DateTime? lastCreated;
  DateTime? lastModified;

  // create a instance of cost item from form
  CostItem.fromForm(CostItemFormResult result, {required String id})
    : uuid = id,
      date = result.date,
      costType = result.costType,
      category = result.category.name!,
      categoryId = result.category.id,
      amount = result.amount,
      name = result.name,
      lastCreated = DateTime.now(),
      lastModified = DateTime.now();

  CostItem.update(CostItem initItem, CostItemFormResult result)
    : uuid = initItem.uuid,
      date = result.date,
      costType = result.costType,
      category = result.category.name!,
      categoryId = result.category.id!,
      amount = result.amount,
      name = result.name,
      lastCreated = initItem.lastCreated,
      lastModified = DateTime.now();

  // create cost item into json
  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'date': date.formatStd(),
    'costType': costType.name,
    'category': category,
    'categoryId': categoryId,
    'amount': amount,
    'name': name,
    'lastCreated': lastCreated?.toString(),
    'lastModified': lastModified?.toString(),
  };

  CostItem.fromJson(Map<String, dynamic> json)
    : uuid = json['uuid'] as String,
      name = json['name'] as String,
      amount = json['amount'] as double,
      category = json['category'] as String,
      categoryId = json['categoryId'] as String,
      costType = CostType.fromString(json['costType']),
      date = (json['date'] as String).dateParseStd(),
      lastCreated = DateTime.tryParse(json['lastCreated'] ?? "") ?? DateTime.now(),
      lastModified = DateTime.tryParse(json['lastModified'] ?? "") ?? DateTime.now();

  bool get isExpense => costType == CostType.expense;

  double get signedAmount => isExpense ? 0 - amount : amount;

  List<dynamic> toCsv() {
    final jsonObject = toJson();
    return List.generate(jsonObject.length, (i) => jsonObject.values.elementAt(i));
  }

  CostItem.fromCsv(List<dynamic> list, {bool newId = false})
    : uuid = newId ? Uuid().v4() : list[0] as String,
      date = (list[1] as String).dateParseStd(),
      costType = CostType.values.where((costType) => costType.name == list[2] as String).first,
      category = list[3] as String,
      categoryId = list[4] as String,
      amount = double.tryParse(list[5] as String) ?? 0,
      name = list[6] as String,
      lastCreated = DateTime.tryParse(list.elementAtOrNull(7)) ?? DateTime.now(),
      lastModified = DateTime.tryParse(list.elementAtOrNull(8)) ?? DateTime.now();

  CostItem.fromCsvLegacy(List<dynamic> list, {bool newId = false})
    : uuid = newId ? Uuid().v4() : list[0] as String,
      date = (list[1] as String).dateParseStd(),
      costType = CostType.values.where((costType) => costType.name == list[2] as String).first,
      category = list[3] as String,
      amount = double.tryParse(list[4] as String) ?? 0,
      name = list[5] as String,
      lastCreated = DateTime.tryParse(list.elementAtOrNull(6)) ?? DateTime.now(),
      lastModified = DateTime.tryParse(list.elementAtOrNull(7)) ?? DateTime.now();

  String getCurrencyValue(String currencySymbol, [bool? includeSign]) {
    final String value = amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);
    final String? sign;
    if (includeSign == false) {
      sign = '';
    } else {
      sign = costType == CostType.expense ? '-' : '+';
    }
    return '$sign $currencySymbol$value';
  }

  double getAbsoluteAmount() => costType == CostType.expense ? 0 - amount : amount;
}

class CostItemFormResult {
  CostItemFormResult({
    required this.name,
    required this.category,
    required this.date,
    required this.costType,
    required this.amount,
  });

  String name;
  CostItemCategory category;
  DateTime date;
  CostType costType;
  double amount;
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
    expense = expense! + (costItem.costType == CostType.expense ? costItem.amount : 0);
    income = income! + (costItem.costType == CostType.income ? costItem.amount : 0);
  }

  void minusFromMetric(CostItem costItem) {
    expense = expense! - (costItem.costType == CostType.expense ? costItem.amount : 0);
    income = income! - (costItem.costType == CostType.income ? costItem.amount : 0);
  }

  factory CostMetric.fromCostItemList(List<CostItem> items) {
    double expense = 0;
    double income = 0;

    for (CostItem item in items) {
      if (item.isExpense) {
        expense += item.amount;
      } else {
        income += item.amount;
      }
    }

    return CostMetric(expense: expense, income: income);
  }
}

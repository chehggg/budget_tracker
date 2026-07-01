// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:budget_tracker/custom/enums/enum.dart';

class SavedItem {
  const SavedItem({
    this.id,
    this.title,
    this.description,
    this.category,
    this.date,
    this.costType,
    this.amount,
    this.lastModified,
  });

  final String? id;
  final String? title;
  final String? description;
  final DateTime? date;
  final String? category;
  final CostType? costType;
  final double? amount;
  final DateTime? lastModified;

  // SavedItem.fromFormResult(String this.id, String this.title, CostItemFormResult result)
  //   : description = result.name,
  //     category = result.category.id,
  //     costType = result.costType,
  //     amount = result.amount,
  //     date = result.date;

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "category": category,
    "costType": costType?.name,
    "date": date?.toString(),
    "amount": amount,
    "lastModified": (lastModified ?? DateTime.now).toString(),
  };

  SavedItem.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      title = json['title'],
      description = json['description'],
      category = json['category'],
      date = DateTime.tryParse(json['date'] ?? ""),
      costType = CostType.values.byName(json['costType'] ?? "expense"),
      amount = json['amount'],
      lastModified = DateTime.tryParse(json['lastModified'] ?? "") ?? DateTime.now();

  SavedItem copyWith({
    String? id,
    String? title,
    String? Function()? description,
    DateTime? Function()? date,
    double? Function()? amount,
    String? category,
    CostType? costType,
    DateTime? lastModified,
  }) {
    return SavedItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description != null ? description() : this.description,
      date: date != null ? date() : this.date,
      amount: amount != null ? amount() : this.amount,
      category: category ?? this.category,
      costType: costType ?? this.costType,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}

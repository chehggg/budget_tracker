import 'package:budget_tracker/custom/enum.dart';

class SavedItem {
  SavedItem({
    this.id,
    this.title,
    this.description,
    this.category,
    this.date,
    this.costType,
    this.amount,
  });

  String? id;
  String? title;
  String? description;
  DateTime? date;
  String? category;
  CostType? costType;
  double? amount;

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
    "costType": costType!.name,
    "date": date.toString(),
    "amount": amount,
  };

  SavedItem.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      title = json['title'],
      description = json['description'],
      category = json['category'],
      date = DateTime.tryParse(json['date']),
      costType = CostType.values.firstWhere((type) => type.name == json['costType']),
      amount = json['amount'];
}

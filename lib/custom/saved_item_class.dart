import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/enum.dart';

class SavedItem {
  SavedItem({
    this.id,
    this.title,
    this.description,
    this.category,
    this.costType,
    this.amount,
  });

  String? id;
  String? title;
  String? description;
  String? category;
  CostType? costType;
  double? amount;

  SavedItem.fromFormResult(String this.id, String this.title, CostItemFormResult result)
    : description = result.name,
      category = result.category,
      costType = result.costType,
      amount = result.amount;

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "category": category,
    "costType": costType!.name,
    "amount": amount,
  };

  SavedItem.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      title = json['title'],
      description = json['description'],
      category = json['category'],
      costType = CostType.values.firstWhere((type) => type.name == json['costType']),
      amount = double.parse(json['amount']);
}

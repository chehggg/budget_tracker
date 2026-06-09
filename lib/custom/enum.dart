import 'package:collection/collection.dart';

enum CostType {
  expense,
  income;

  factory CostType.from(String value) {
    return CostType.values.firstWhere((type) => type.name == value, orElse: () => CostType.expense);
  }
}

enum FormGroup {
  expense,
  income,
  favorite;

  CostType? get costType {
    return CostType.values.firstWhereOrNull((costType) => costType.name == name);
  }
}

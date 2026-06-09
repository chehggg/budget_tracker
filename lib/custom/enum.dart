import 'package:collection/collection.dart';

enum CostType {
  expense,
  income;

  factory CostType.from(String value) => value == "expense" ? CostType.expense : CostType.income;
}

enum FormGroup {
  expense,
  income,
  favorite;

  CostType? get costType {
    return switch (this) {
      FormGroup.expense => CostType.expense,
      FormGroup.income => CostType.income,
      FormGroup.favorite => null,
    };
  }
}

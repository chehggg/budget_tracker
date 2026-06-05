import 'package:collection/collection.dart';

enum CostType {
  expense,
  income,
}

enum FormGroup {
  expense,
  income,
  favorite;

  CostType? get costType {
    return CostType.values.firstWhereOrNull((costType) => costType.name == name);
  }
}

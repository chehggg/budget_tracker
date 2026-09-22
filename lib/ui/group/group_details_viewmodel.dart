import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:budget_tracker/data/repos/group_repository.dart';
import 'package:budget_tracker/data/repos/shared_element_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class GroupDetailsViewModel extends ChangeNotifier {
  GroupDetailsViewModel({
    required this.group,
    required GroupRepository groupRepo,
    required CostItemRepository costItemRepo,
    required SharedElementRepository sharedRepo,
    required CurrencyRepository currencyRepo,
  }) : _groupRepo = groupRepo,
       _sharedRepo = sharedRepo,
       _costItemRepo = costItemRepo,
       _currencyRepo = currencyRepo {
    init();
  }

  void init() async {
    await _currencyRepo.ready;
    await _groupRepo.ready;
    await _sharedRepo.ready;
  }

  // CostGroup _group;
  CostGroup group;

  final GroupRepository _groupRepo;
  final CostItemRepository _costItemRepo;
  final CurrencyRepository _currencyRepo;
  final SharedElementRepository _sharedRepo;

  List<CostGroup> get groups => _groupRepo.groups;

  List<CostItem> get items => _costItemRepo.costItems
      .where((item) => item.group == group.id)
      .sorted((a, b) => b.date!.compareTo(a.date!));

  CostMetric get groupCostMetric => CostMetric.fromCostItemList(items);

  String Function(
    double value, {
    String? customIso,
    bool abbreviated,
    bool alwaysShowSign,
    bool showSymbol,
    bool compact,
    int? decimalDigits,
  })
  get currencyFormat => _currencyRepo.formatCurrency;

  AccentColor get accentColor => _sharedRepo.accentColors;

  Future<void> deleteGroup() async {
    await _groupRepo.deleteGroup(group);
  }
}

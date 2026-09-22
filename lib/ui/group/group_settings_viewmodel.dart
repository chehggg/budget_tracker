import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:budget_tracker/data/repos/group_repository.dart';
import 'package:flutter/material.dart';

class GroupSettingsViewModel extends ChangeNotifier {
  GroupSettingsViewModel({
    required GroupRepository groupRepo,
    required CostItemRepository costItemRepo,
    required CurrencyRepository currencyRepo,
  }) : _groupRepo = groupRepo,
       _costItemRepo = costItemRepo,
       _currencyRepo = currencyRepo {
    init();
  }

  void init() async {
    await _groupRepo.ready;
    await _currencyRepo.ready;
  }

  final GroupRepository _groupRepo;
  final CostItemRepository _costItemRepo;
  final CurrencyRepository _currencyRepo;

  List<CostGroup> get groups => _groupRepo.groups;

  CostMetric getMetricFromGroup(CostGroup group) {
    return CostMetric.fromCostItemList(
      _costItemRepo.costItems.where((item) => item.group == group.id).toList(),
    );
  }
  // String getFormattedCurrency(CostGroup group, double amount) {
  //   if (group.currency != null) {
  //     final money = Money.fromNum(amount, isoCode: group.currency!);
  //     return money.format();
  //   }
  //   return currencyFormat(amount);
  // }

  // final money = Money.fromNumWithCurrency();
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
}

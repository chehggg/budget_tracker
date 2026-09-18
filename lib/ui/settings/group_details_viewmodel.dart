import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:budget_tracker/data/repos/group_repository.dart';
import 'package:flutter/material.dart';

class GroupDetailsViewModel extends ChangeNotifier {
  GroupDetailsViewModel({
    required this.group,
    required GroupRepository groupRepo,
    required CurrencyRepository currencyRepo,
  }) : _groupRepo = groupRepo,
       _currencyRepo = currencyRepo {
    init();
  }

  void init() async {
    await _currencyRepo.ready;
  }

  // CostGroup _group;
  CostGroup group;

  final GroupRepository _groupRepo;
  final CurrencyRepository _currencyRepo;

  List<CostGroup> get groups => _groupRepo.groups;


  String Function(
    double value, {
    bool abbreviated,
    bool alwaysShowSign,
    bool compact,
    int? decimalDigits,
  })
  get currencyFormat => _currencyRepo.formatCurrency;
}

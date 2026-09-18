import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:budget_tracker/data/repos/group_repository.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GroupSettingsViewModel extends ChangeNotifier {
  GroupSettingsViewModel({
    required GroupRepository groupRepo,
    required CurrencyRepository currencyRepo,
  }) : _groupRepo = groupRepo,
       _currencyRepo = currencyRepo {
    init();
  }

  void init() {}

  final GroupRepository _groupRepo;
  final CurrencyRepository _currencyRepo;

  List<CostGroup> get groups => _groupRepo.groups;

  CostGroup _draft = CostGroup();
  CostGroup get draft => _draft;

  void updateGroupName(String name) {
    _draft = _draft.copyWith(name: name);
    notifyListeners();
  }

  void updateGroupDesc(String desc) {
    _draft = _draft.copyWith(description: desc);
    notifyListeners();
  }

  void toggleAddToMain(bool val) {
    _draft = _draft.copyWith(addToMain: val);
    notifyListeners();
  }

  Future<String?> addGroup() async {
    if (draft.name?.isEmpty ?? true) {
      return "Name cannot be empty";
    } else if (draft.description?.isEmpty ?? true) {
      return "Description cannot be empty";
    } else {
      await _groupRepo.addGroup(_draft.copyWith(id: Uuid().v4()));
      notifyListeners();
      return null;
    }
  }

  String Function(
    double value, {
    bool abbreviated,
    bool alwaysShowSign,
    bool compact,
    int? decimalDigits,
  })
  get currencyFormat => _currencyRepo.formatCurrency;
}

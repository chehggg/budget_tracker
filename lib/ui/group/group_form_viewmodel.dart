import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/data/repos/group_repository.dart';
import 'package:budget_tracker/data/repos/shared_element_repository.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';
import 'package:uuid/uuid.dart';

class GroupFormViewModel extends ChangeNotifier {
  GroupFormViewModel({
    required CostGroup? initGroup,
    required GroupRepository groupRepo,
  }) : _groupRepo = groupRepo,
       _initGroup = initGroup {
    init();
  }

  void init() async {
    debugPrint("initializing group form");
    if (isEditMode) {
      _draft = _initGroup!;
      _currency = _draft.currency != null ? Currencies().find(_draft.currency!) : null;
    }

    await _groupRepo.ready;

    _isInitialized = true;
    notifyListeners();
  }

  final GroupRepository _groupRepo;

  final CostGroup? _initGroup;

  bool _isInitialized = false;
  bool get isInit => _isInitialized;

  bool get isEditMode => _initGroup != null;

  CostGroup _draft = CostGroup(name: 'My Group');
  CostGroup get draft => _draft;

  Currency? _currency;
  String get currencyName {
    if (_currency == null) return "Default";
    return "${_currency!.name} (${_currency!.symbol})";
  }

  void updateGroupName(String name) {
    _draft = _draft.copyWith(name: name);
    notifyListeners();
  }

  void updateCurrency(Currency newCurrency) {
    _currency = newCurrency;
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

  Future<String?> submitGroup() async {
    if (draft.name?.isEmpty ?? true) {
      return "Name cannot be empty";
      // } else if (draft.description?.isEmpty ?? true) {
      //   return "Description cannot be empty";
    } else {
      if (isEditMode) {
        await _groupRepo.updateGroup(_draft.copyWith(currency: _currency?.isoCode));
      } else {
        await _groupRepo.addGroup(_draft.copyWith(id: Uuid().v4(), currency: _currency?.isoCode));
      }
      notifyListeners();
      return null;
    }
  }

  Future<void> deleteGroup() async {
    await _groupRepo.deleteGroup(_draft);
  }
}

import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/data/repos/group_repository.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GroupSettingsViewModel extends ChangeNotifier {
  GroupSettingsViewModel({required GroupRepository groupRepo}) : _groupRepo = groupRepo {
    init();
  }

  void init() {}

  final GroupRepository _groupRepo;

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

  void addGroup() async {
    await _groupRepo.addGroup(_draft.copyWith(id: Uuid().v4()));
    notifyListeners();
  }
}

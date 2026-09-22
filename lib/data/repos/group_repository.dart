import 'dart:async';

import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/data/services/local_service.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:flutter/material.dart';

class GroupRepository {
  GroupRepository({required LocalServices localServices}) : _localServices = localServices {
    _initFuture = _init();
  }

  final LocalServices _localServices;

  // Future<void> restart() async {
  //   await _init();
  //   _controller.add(true);
  // }

  Future<void> _init() async {
    await loadGroups();
  }

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Stream<bool> get streamValue => _controller.stream;

  Future<void>? _initFuture;
  Future<void> get ready => _initFuture ?? Future.value();

  List<CostGroup> _groups = [];
  List<CostGroup> get groups => _groups;

  Future<void> addGroup(CostGroup group) async {
    _groups.add(group);
    await _localServices.writeGroupsFile(_groups);
  }

  CostGroup? _viewedGroup;
  CostGroup? get viewedGroup => _viewedGroup;

  Future<void> loadGroups() async {
    final result = await _localServices.loadGroupsFile();
    switch (result) {
      case Ok():
        _groups = result.value;
      case Error():
        _groups = [];
    }
  }

  void changeGroupView(CostGroup? newGroup) {
    _viewedGroup = newGroup;
    _controller.add(true);
  }

  Future<void> deleteGroup(CostGroup deletedGroup) async {
    _groups.removeWhere((goal) => goal.id == deletedGroup.id);
    await _localServices.writeGroupsFile(_groups);
    // _controller.add(true);
  }

  Future<void> updateGroup(CostGroup updatedGroup) async {
    _groups.removeWhere((goal) => goal.id == updatedGroup.id);
    _groups.add(updatedGroup);
    // debugPrint("group updated!, item count: ${updatedGroup.items?.length ?? 0}");
    await _localServices.writeGroupsFile(_groups);
    // _controller.add(true);
  }
}

import 'dart:async';

import 'package:budget_tracker/custom/classes/goal_class.dart';
import 'package:budget_tracker/data/services/local_service.dart';
import 'package:budget_tracker/utils/result.dart';

class GoalRepository {
  GoalRepository({required LocalServices localServices}) : _localServices = localServices {
    _initFuture = init();
  }

  final LocalServices _localServices;

  Future<void> init() async {
    await loadGoals();
  }

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Stream<bool> get streamValue => _controller.stream;

  late final Future<void> _initFuture;
  Future<void> get ready => _initFuture;

  List<Goal> _goals = [];
  List<Goal> get goals => _goals;

  Future<void> addGoal(Goal goal) async {
    _goals.add(goal);
    await _localServices.writeGoalsFile(_goals);
    _controller.add(true);
  }

  Future<void> loadGoals() async {
    final result = await _localServices.loadGoalsFile();
    switch (result) {
      case Ok():
        _goals = result.value;
      case Error():
        _goals = [];
    }
  }

  Future<void> deleteGoal(Goal deletedGoal) async {
    _goals.removeWhere((goal) => goal.id == deletedGoal.id);
    await _localServices.writeGoalsFile(_goals);
    _controller.add(true);
  }

  Future<void> updateGoal(Goal updatedGoal) async {
    _goals.removeWhere((goal) => goal.id == updatedGoal.id);
    _goals.add(updatedGoal);
    await _localServices.writeGoalsFile(_goals);
    _controller.add(true);
  }
}

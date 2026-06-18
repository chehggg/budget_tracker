import 'package:budget_tracker/custom/classes/goal_class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/data/repos/goal_repository.dart';
import 'package:flutter/material.dart';

class GoalFormViewmodel extends ChangeNotifier {
  GoalFormViewmodel({required GoalRepository goalRepository, Goal? initGoal})
    : _initGoal = initGoal,
      _goalRepository = goalRepository {
    init();
  }

  final GoalRepository _goalRepository;
  final Goal? _initGoal;

  Future<void> init() async {
    if (_initGoal != null) {
      _uuid = _initGoal.id!;
    } else {
      _uuid = "";
    }
  }

  late String _uuid;
  String _title = "";
  String get title => _title;

  GoalType _goalType = GoalType.budget;
  GoalType get goalType => _goalType;

  Goal get _curGoal => Goal(
    id: _uuid,
    title: _title,
    goalType: _goalType,
  );

  void updateGoalType(GoalType type) {
    _goalType = type;
    notifyListeners();
  }

  void updateTitle(String text) {
    _title = text;
    notifyListeners();
  }

  void createGoal() {
    _goalRepository.addGoal(_curGoal);
  }
}

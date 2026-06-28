import 'package:budget_tracker/custom/classes/goal_class.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/goal_repository.dart';
import 'package:flutter/material.dart';

class GoalViewModel extends ChangeNotifier {
  GoalViewModel({required CostItemRepository costItemRepo, required GoalRepository goalRepository})
    : _costItemRepo = costItemRepo,
      _goalRepository = goalRepository {
    init();
  }

  final CostItemRepository _costItemRepo;
  final GoalRepository _goalRepository;

  Future<void> init() async {
    _isInit = false;
    await _costItemRepo.ready;
    await _goalRepository.ready;
    _isInit = true;

    debugPrint('goal view model done');
    notifyListeners();
  }

  bool _isInit = false;
  bool get ready => _isInit;

  Map<Goal, GoalProgress> get goalOverview => Map.fromEntries(
    _goalRepository.goals.map(
      (goal) => MapEntry(
        goal,
        goal.getGoalProgress(
          _costItemRepo.costItems,
          goal.isEnded ? goal.endDate! : DateTime.now(),
        )!,
      ),
    ),
  );
}

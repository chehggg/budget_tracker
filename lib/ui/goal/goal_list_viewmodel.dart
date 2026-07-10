import 'dart:async';

import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/classes/goal_class.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/goal_repository.dart';
import 'package:budget_tracker/data/repos/shared_element_repository.dart';
import 'package:flutter/material.dart';

class GoalViewModel extends ChangeNotifier {
  GoalViewModel({
    required CostItemRepository costItemRepo,
    required GoalRepository goalRepo,
    required SharedElementRepository sharedElementRepo,
  }) : _costItemRepo = costItemRepo,
       _goalRepo = goalRepo,
       _sharedElementRepo = sharedElementRepo {
    init();
  }

  final CostItemRepository _costItemRepo;
  final GoalRepository _goalRepo;
  final SharedElementRepository _sharedElementRepo;

  Future<void> init() async {
    _isInit = false;
    await _costItemRepo.ready;
    await _goalRepo.ready;
    await _sharedElementRepo.ready;
    
    _isInit = true;

    _subscription = _goalRepo.streamValue.listen((_) {
      notifyListeners();
    });
    _sharedElementSubscription = _sharedElementRepo.sharedStream.listen((_) {
      notifyListeners();
    });

    debugPrint('goal view model done');
    notifyListeners();
  }

  StreamSubscription<bool>? _subscription;
  StreamSubscription<bool>? _sharedElementSubscription;

  bool _isInit = false;
  bool get ready => _isInit;

  Map<Goal, GoalProgress> get goalOverview => Map.fromEntries(
    _goalRepo.goals.map(
      (goal) => MapEntry(
        goal,
        goal.getGoalProgress(
          _costItemRepo.costItems,
          goal.isEnded ? goal.endDate! : DateTime.now(),
        )!,
      ),
    ),
  );

  AccentColor get accentColors => _sharedElementRepo.accentColors;

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
    _sharedElementSubscription?.cancel();
  }
}

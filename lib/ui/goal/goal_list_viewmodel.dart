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
    _costItemSubscription = _costItemRepo.valueStream.listen((_) {
      notifyListeners();
    });
    _sharedElementSubscription = _sharedElementRepo.sharedStream.listen((_) {
      notifyListeners();
    });

    notifyListeners();
  }

  StreamSubscription<bool>? _subscription;
  StreamSubscription? _costItemSubscription;
  StreamSubscription<bool>? _sharedElementSubscription;

  bool _isInit = false;
  bool get ready => _isInit;

  String _searchText = "";
  String get searchText => _searchText;

  bool _searchOn = false;
  bool get searchOn => _searchOn;

  List<Goal> get _filteredGoals =>
      _goalRepo.goals.where((goal) {
          if (_searchText.isNotEmpty) {
            return goal.title?.toLowerCase().contains(_searchText.toLowerCase()) ?? false;
          } else {
            return true;
          }
        }).toList()
        ..sort((a, b) => a.lastCreated!.compareTo(b.lastCreated!));

  Map<Goal, GoalProgress> get goalOverview {
    Map<Goal, GoalProgress> result = {};

    for (final goal in _filteredGoals) {
      final progress = goal.getGoalProgress(
        _costItemRepo.costItems,
        goal.isEnded ? (goal.endDate ?? DateTime.now()) : DateTime.now(),
      );
      if (progress != null) {
        result.addEntries([MapEntry(goal, progress)]);
      }
    }
    return result;
  }

  AccentColor get accentColors => _sharedElementRepo.accentColors;

  void updateSearch(String text) {
    _searchText = text;
    notifyListeners();
  }

  void toggleSearch({bool? value}) {
    _searchOn = value ?? !_searchOn;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
    _sharedElementSubscription?.cancel();
    _costItemSubscription?.cancel();
  }
}

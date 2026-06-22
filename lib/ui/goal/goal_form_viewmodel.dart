import 'package:budget_tracker/custom/classes/goal_category.dart';
import 'package:budget_tracker/custom/classes/goal_class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/data/repos/goal_repository.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GoalFormViewmodel extends ChangeNotifier {
  GoalFormViewmodel({
    required GoalRepository goalRepository,
    Goal? initGoal,
    GoalCategory? goalCategory,
  }) : _initGoal = initGoal,
       _goalRepository = goalRepository,
       _goalCategory = goalCategory {
    init();
  }

  final GoalRepository _goalRepository;
  final Goal? _initGoal;
  final GoalCategory? _goalCategory;

  Future<void> init() async {
    if (_initGoal != null) {
      debugPrint("found init goals, title: ${_initGoal.title}");
      _uuid = _initGoal.id!;
      _title = _initGoal.title!;
      _description = _initGoal.description!;
      _goalType = _initGoal.goalType!;
      _trackingPeriod = _initGoal.goalTracking!;
      _target = _initGoal.target;
    } else {
      _uuid = Uuid().v4();
      if (_goalCategory != null) {
        _title = _goalCategory.title;
        _description = _goalCategory.description;
        _goalType = _goalCategory.type;
        _trackingPeriod = _goalCategory.trackingPeriod;
      }
    }
    await _goalRepository.ready;

    _isInitialized = true;
    notifyListeners();
  }

  bool get isEditMode => _initGoal != null;

  bool _isInitialized = false;
  bool get isInit => _isInitialized;

  late String _uuid;

  String _title = "";
  String get title => _title;

  String _description = "";
  String get description => _description;
  
  double? _target;
  double? get target => _target;

  GoalType _goalType = GoalType.budget;
  GoalType get goalType => _goalType;

  GoalTrackingPeriod _trackingPeriod = GoalTrackingPeriod.monthly;
  GoalTrackingPeriod get trackingPeriod => _trackingPeriod;

  DateTime _startDate = DateTime.now().startOfMonth;
  DateTime _endDate = DateTime.now().addMonth(1).startOfMonth;

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  Goal get _curGoal => Goal(
    id: _uuid,
    title: _title,
    description: _description,
    goalType: _goalType,
    goalTracking: _trackingPeriod,
    startDate: _startDate,
    endDate: _endDate,
    target: _target,
    lastCreated: _initGoal?.lastCreated ?? DateTime.now(),
    lastModified: DateTime.now(),
  );

  void updateGoalType(GoalType type) {
    _goalType = type;
    notifyListeners();
  }

  void updateTracking(GoalTrackingPeriod newTrackingPeriod) {
    _trackingPeriod = newTrackingPeriod;
    notifyListeners();
  }

  void updateTitle(String text) {
    _title = text;
    notifyListeners();
  }

  void updateDesc(String text) {
    _description = text;
    notifyListeners();
  }

  void updateTarget(String value) {
    debugPrint('update target');
    _target = double.tryParse(value);
    notifyListeners();
  }

  Future<void> createGoal() async {
    await _goalRepository.addGoal(_curGoal);
  }

  Future<void> deleteGoal() async {
    await _goalRepository.deleteGoal(_curGoal);
  }

  Future<void> updateGoal() async {
    await _goalRepository.updateGoal(_curGoal);
  }

  String? validateForm() {
    if (_target == null) return "Goal target cannot be empty!";
    return null;
  }
 
  void updateStartDate(DateTime newDate) {
    _startDate = newDate;
    notifyListeners();
  }

  void updateEndDate(DateTime newDate) {
    _endDate = newDate;
    notifyListeners();
  }
}

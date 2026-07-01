import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/classes/goal_category.dart';
import 'package:budget_tracker/custom/classes/goal_class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/goal_repository.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GoalFormViewmodel extends ChangeNotifier {
  GoalFormViewmodel({
    required GoalRepository goalRepository,
    required CategoryRepository categoryRepo,
    Goal? initGoal,
    GoalCategory? goalCategory,
  }) : _initGoal = initGoal,
       _goalRepository = goalRepository,
       _categoryRepo = categoryRepo,
       _goalCategory = goalCategory {
    init();
  }

  final GoalRepository _goalRepository;
  final CategoryRepository _categoryRepo;
  final Goal? _initGoal;
  final GoalCategory? _goalCategory;

  Future<void> init() async {
    if (_initGoal != null) {
      _draftedGoal = _initGoal;
      debugPrint("found init goals, title: ${_initGoal.title}");
    } else {
      _draftedGoal = Goal(id: Uuid().v4());

      if (_goalCategory != null) {
        _draftedGoal = _draftedGoal.copyWith(
          title: _goalCategory.title,
          description: _goalCategory.description,
          goalType: _goalCategory.type,
          startDate: DateTime.now().startOfMonth,
          goalTracking: _goalCategory.trackingPeriod,
        );
      }
    }
    _startDateController.value = _startDateController.value.copyWith(
      text: _draftedGoal.startDate!.formatMonthLonger(),
    );
    _endDateController.value = _endDateController.value.copyWith(
      text: _draftedGoal.endDate?.formatMonthLonger(),
    );

    await _goalRepository.ready;
    await _categoryRepo.ready;

    _isInitialized = true;
    notifyListeners();
  }

  TextEditingController _startDateController = TextEditingController();
  TextEditingController get startDateController => _startDateController;

  TextEditingController _endDateController = TextEditingController();
  TextEditingController get endDateController => _endDateController;

  Goal _draftedGoal = Goal();
  Goal get draftGoal => _draftedGoal;

  bool get isEditMode => _initGoal != null;

  bool _isInitialized = false;
  bool get isInit => _isInitialized;

  StringFilter? get draftedFilter =>
      _draftedGoal.matchType == null
          ? null
          : StringFilter(
            matchType: _draftedGoal.matchType!,
            query: _draftedGoal.filterString!,
          );

  List<CostItemCategory>? get categories =>
      _draftedGoal.categories?.map((id) => getCatById(id)).toList();

  bool _isEndChecked = false;
  bool get isEndChecked => _isEndChecked;

  CostItemCategory getCatById(String id) {
    return _categoryRepo.getCategoryById(id);
  }

  void updateGoalType(GoalType type) {
    _draftedGoal = _draftedGoal.copyWith(goalType: type);
    notifyListeners();
  }

  void updateTracking(GoalTrackingPeriod newTrackingPeriod) {
    _draftedGoal = _draftedGoal.copyWith(goalTracking: newTrackingPeriod);
    notifyListeners();
  }

  void updateTitle(String text) {
    _draftedGoal = _draftedGoal.copyWith(title: text);
    notifyListeners();
  }

  void updateDesc(String text) {
    _draftedGoal = _draftedGoal.copyWith(description: text);
    notifyListeners();
  }

  void updateTarget(String value) {
    _draftedGoal = _draftedGoal.copyWith(target: double.tryParse(value));
    notifyListeners();
  }

  void checkEndDate(bool? value) {
    if (value != null) {
      _isEndChecked = value;
      if (!value) {
        updateEndDate(null);
      } else {
        updateEndDate(_draftedGoal.startDate!.addMonth(3).startOfMonth);
      }
      notifyListeners();
    }
  }

  void updateCategories(List<CostItemCategory> newCategories) {
    _draftedGoal = _draftedGoal.copyWith(categories: newCategories.map((cat) => cat.id!).toList());
    notifyListeners();
  }

  void updateFilterString(StringFilter filter) {
    _draftedGoal = _draftedGoal.copyWith(filterString: filter.query, matchType: filter.matchType);
    notifyListeners();
  }

  Future<void> submitGoal() async {
    _draftedGoal = _draftedGoal.copyWith(
      lastCreated: DateTime.now(),
      lastModified: isEditMode ? DateTime.now() : null,
    );
    return isEditMode
        ? await _goalRepository.addGoal(_draftedGoal)
        : await _goalRepository.updateGoal(_draftedGoal);
  }

  Future<void> deleteGoal() async {
    await _goalRepository.deleteGoal(_draftedGoal);
  }

  Future<void> updateGoal() async {
    _draftedGoal = _draftedGoal.copyWith(lastModified: DateTime.now());
    await _goalRepository.updateGoal(_draftedGoal);
  }

  String? validateForm() {
    if (_draftedGoal.target == null) return "Goal target cannot be empty!";
    if (_draftedGoal.endDate?.isBeforeOrSameMoment(_draftedGoal.startDate!) ?? false) {
      return "End date must be later than start date.";
    }
    return null;
  }

  void updateStartDate(DateTime newDate) {
    _draftedGoal = _draftedGoal.copyWith(startDate: newDate);
    _startDateController.value = _startDateController.value.copyWith(
      text: newDate.formatMonthLonger(),
    );
    notifyListeners();
  }

  void updateEndDate(DateTime? newDate) {
    _draftedGoal = _draftedGoal.copyWith(endDate: newDate);
    _endDateController.value = _endDateController.value.copyWith(
      text: newDate?.formatMonthLonger() ?? "",
    );
    notifyListeners();
    // _endDate = newDate;
    // notifyListeners();
  }
}

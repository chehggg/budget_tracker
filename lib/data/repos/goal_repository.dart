import 'package:budget_tracker/custom/classes/goal_class.dart';
import 'package:budget_tracker/data/services/local_service.dart';

class GoalRepository {
  GoalRepository({required LocalServices localServices}) : _localServices = localServices {
    _initFuture = init();
  }

  final LocalServices _localServices;

  Future<void> init() async {}

  late final Future<void> _initFuture;
  Future<void> get ready => _initFuture;

  final List<Goal> _goals = [];
  List<Goal> get goals => _goals;

  Future<void> addGoal(Goal goal) async {
    _goals.add(goal);
    await _localServices.writeGoalsFile(_goals);
  }

  Future<void> removeGoal(Goal deletedGoal) async {
    _goals.removeWhere((goal) => goal.id == deletedGoal.id);
    await _localServices.writeGoalsFile(_goals);
  }

  Future<void> updateGoal(Goal updatedGoal) async {
    _goals.removeWhere((goal) => goal.id == updatedGoal.id);
    _goals.add(updatedGoal);
    await _localServices.writeGoalsFile(_goals);
  }
}

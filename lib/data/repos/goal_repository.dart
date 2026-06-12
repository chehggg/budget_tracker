import 'package:budget_tracker/custom/classes/goal_class.dart';
import 'package:budget_tracker/data/services/goal_service.dart';

class GoalRepository {
  GoalRepository({required GoalService goalService}) : _goalService = goalService {
    _initFuture = init();
  }

  final GoalService _goalService;

  Future<void> init() async {
  }

  late final Future<void> _initFuture;
  Future<void> get ready => _initFuture;

  final List<Goal> _goals = [];
  List<Goal> get goals => _goals;

  Future<void> addGoal(Goal goal) async {
    _goals.add(goal);
    await _goalService.writeGoalToFile(_goals);
  }

  Future<void> removeGoal(Goal deletedGoal) async {
    _goals.removeWhere((goal) => goal.id == deletedGoal.id);
    await _goalService.writeGoalToFile(_goals);
  }
  
}

import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/data/services/local_service.dart';

class GroupRepository {
  GroupRepository({required LocalServices localServices}) : _localServices = localServices {
    _initFuture = _init();
  }

  final LocalServices _localServices;

  Future<void> restart() async {
    await  _init();
    // _controller.add(true);
  }
  
  Future<void> _init() async {
    await loadGroups();
  }

  // final StreamController<bool> _controller = StreamController<bool>.broadcast();
  // Stream<bool> get streamValue => _controller.stream;

  Future<void>? _initFuture;
  Future<void> get ready => _initFuture ?? Future.value();

  List<CostGroup> _groups = [];
  List<CostGroup> get groups => _groups;

  Future<void> addGroup(CostGroup group) async {
    _groups.add(group);
    // await _localServices.writeGoalsFile(_goals);
    // _controller.add(true);
  }

  Future<void> loadGroups() async {
    final result = await _localServices.loadGroupsFile();
    switch (result) {
      case Ok():
        _groups = result.value;
      case Error():
        _groups = [];
    }
  }

  Future<void> deleteGroup(CostGroup deletedGroup) async {
    _groups.removeWhere((goal) => goal.id == deletedGroup.id);
    await _localServices.writeGoalsFile(_groups);
    // _controller.add(true);
  }

  Future<void> updateGoal(CostGroup updatedGoal) async {
    _groups.removeWhere((goal) => goal.id == updatedGoal.id);
    _groups.add(updatedGoal);
    await _localServices.writeGoalsFile(_groups);
    // _controller.add(true);
  }
}
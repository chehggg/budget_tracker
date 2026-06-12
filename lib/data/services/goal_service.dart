import 'dart:convert';
import 'dart:io';

import 'package:budget_tracker/custom/classes/goal_class.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:path_provider/path_provider.dart';

class GoalService {

  Future<Result<void>> getGoals() async {
    return Result.ok(null);
  } 

  Future<Result<void>> writeGoalToFile(List<Goal> goals) async {
    final List<Map<String, dynamic>> result = List.generate(
      goals.length,
      (i) => goals[i].toJson(),
    );

    try {
      final jsonString = jsonEncode(result);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/goals.json');

      file.writeAsStringSync(jsonString);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

}
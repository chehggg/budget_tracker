import 'package:budget_tracker/custom/classes/goal_class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/goal_repository.dart';
import 'package:flutter/material.dart';

class GoalModel extends ChangeNotifier {
  GoalModel({required CostItemRepository costItemRepo, required GoalRepository goalRepository})
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
    _goalRepository.goals.map((goal) => MapEntry(goal, goal.getGoalProgress(_costItemRepo.costItems).last)),
  );

  // List<GoalProgress> getGoalProgress(Goal goal) {
  //   List<GoalProgress> resultList = [];
  //   final start = goal.startDate!;
  //   final end = goal.endDate ?? DateTime.now().startOfMonth;

  //   if (goal.goalTracking == GoalTrackingPeriod.monthly) {
  //     resultList =
  //         List.generate(
  //               end.month - start.month + 1,
  //               (i) => start.addMonth(i),
  //             )
  //             .map(
  //               (month) => GoalProgress(
  //                 date: month,
  //                 items:
  //                     _costItemRepo.costItems.where((item) {
  //                       final dateQuery = item.date.isInSameYearMonthAs(month);
  //                       final categoryQuery = goal.categories?.contains(item.categoryId) ?? true;
  //                       final nameQuery = item.name.contains(goal.filterString ?? "");
  //                       return dateQuery && categoryQuery && nameQuery;
  //                       // return dateQuery;
  //                     }).toList(),
  //                 goalType: goal.goalType,
  //                 target: goal.target,
  //               ),
  //             )
  //             .toList();
  //     // // DateTime iDate = start;
  //     // // for (i)
  //     // // resultList.add(
  //     // //   GoalProgress(
  //     // //     date: iDate,
  //     // //     items:
  //     // //         _costItemRepo.costItems.where((item) {
  //     // //           final dateQuery = item.date.isInSameYearMonthAs(iDate);
  //     // //           // final categoryQuery = goal.categories?.contains(item.categoryId) ?? true;
  //     // //           // final nameQuery = item.name.contains(goal.filterString ?? "");
  //     // //           // return dateQuery && categoryQuery && nameQuery;
  //     // //           return dateQuery;
  //     // //         }).toList(),
  //     // //     goalType: goal.goalType,
  //     // //     target: goal.target,
  //     // //   ),
  //     // // );
  //     // while (iDate.isBefore(end) || iDate.isAtSameMomentAs(end)) {
  //     //   resultList.add(
  //     //     GoalProgress(
  //     //       date: iDate,
  //     //       items:
  //     //           _costItemRepo.costItems.where((item) {
  //     //             final dateQuery = item.date.isInSameYearMonthAs(iDate);
  //     //             // final categoryQuery = goal.categories?.contains(item.categoryId) ?? true;
  //     //             // final nameQuery = item.name.contains(goal.filterString ?? "");
  //     //             // return dateQuery && categoryQuery && nameQuery;
  //     //             return dateQuery;
  //     //           }).toList(),
  //     //       goalType: goal.goalType,
  //     //       target: goal.target,
  //     //     ),
  //     //   );
  //     //   iDate = iDate.addMonth(1);
  //     // }
  //   } else {
  //     resultList.add(
  //       GoalProgress(
  //         date: start,
  //         items:
  //             _costItemRepo.costItems.where((item) {
  //               final dateQuery =
  //                   (item.date.isAtSameMomentAs(start)) ||
  //                   (item.date.isAtSameMomentAs(end)) ||
  //                   (item.date.isAfter(start) && item.date.isBefore(start));
  //               final categoryQuery = goal.categories?.contains(item.categoryId) ?? true;
  //               final nameQuery = item.name.contains(goal.filterString ?? "");
  //               return dateQuery && categoryQuery && nameQuery;
  //             }).toList(),
  //         goalType: goal.goalType,
  //         target: goal.target,
  //       ),
  //     );
  //   }
  //   return resultList;
  // }
}

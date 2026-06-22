import 'dart:math';

import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:flutter/material.dart';

class Goal {
  Goal({
    this.id,
    this.title,
    this.description,
    this.target,
    this.startDate,
    this.endDate,
    this.categories,
    this.filterString,
    this.goalType,
    this.goalTracking,
    this.lastCreated,
    this.lastModified,
  });

  final String? id;
  final String? title;
  final String? description;
  final double? target;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? categories;
  final String? filterString;
  final GoalType? goalType;
  final GoalTrackingPeriod? goalTracking;
  final DateTime? lastCreated;
  final DateTime? lastModified;

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    id: json["id"] as String?,
    title: json["title"] as String?,
    description: json["description"] as String?,
    target: (json["target"] as num?)?.toDouble(), // Safely converts int or double
    startDate: (json['startDate'] as String?)?.dateParseFull(),
    endDate: (json['endDate'] as String?)?.dateParseFull(),
    categories:
        json["categories"] != null ? List<String>.from(json["categories"] as Iterable) : null,
    filterString: json["filterString"] as String?,
    goalType: GoalType.values.byName(json["goalType"]),
    goalTracking: GoalTrackingPeriod.values.byName(json["goalTracking"]),
    lastCreated: DateTime.tryParse(json["lastCreated"] as String? ?? "") ?? DateTime.now(),
    lastModified: DateTime.tryParse(json["lastModified"] as String? ?? "") ?? DateTime.now(),
  );

  // Method to convert a Goal object into a Map (JSON)
  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "target": target,
    "startDate": startDate?.formatFull(),
    "endDate": endDate?.formatFull(),
    "categories": categories != null ? List<dynamic>.from(categories!) : null,
    "filterString": filterString,
    "goalType": goalType?.name,
    "goalTracking": goalTracking?.name,
    "lastCreated": lastCreated?.toString(),
    "lastModified": lastModified?.toString(),
  };

  List<GoalProgress> getGoalProgress(List<CostItem> items) {
    List<GoalProgress> resultList = [];
    final end = endDate ?? DateTime.now().startOfMonth;

    if (goalTracking == GoalTrackingPeriod.monthly) {
      resultList =
          List.generate(
                min(1, end.month - startDate!.month),
                (i) => startDate!.addMonth(i),
              )
              .map(
                (month) => GoalProgress(
                  date: month,
                  items:
                      items.where((item) {
                        final dateQuery = item.date.isInSameYearMonthAs(month);
                        final categoryQuery = categories?.contains(item.categoryId) ?? true;
                        final nameQuery = item.name.contains(filterString ?? "");
                        return dateQuery && categoryQuery && nameQuery;
                        // return dateQuery;
                      }).toList(),
                  goalType: goalType,
                  target: target,
                ),
              )
              .toList();
    } else {
      resultList.add(
        GoalProgress(
          date: startDate!,
          items:
              items.where((item) {
                final dateQuery =
                    (item.date.isAtSameMomentAs(startDate!)) ||
                    (item.date.isAtSameMomentAs(end)) ||
                    (item.date.isAfter(startDate!) && item.date.isBefore(startDate!));
                final categoryQuery = categories?.contains(item.categoryId) ?? true;
                final nameQuery = item.name.contains(filterString ?? "");
                return dateQuery && categoryQuery && nameQuery;
              }).toList(),
          goalType: goalType,
          target: target,
        ),
      );
    }
    return resultList;
  }
}

class GoalProgress {
  GoalProgress({
    this.date,
    this.items,
    this.goalType,
    this.target,
  });

  final DateTime? date;
  final List<CostItem>? items;
  final GoalType? goalType;
  final double? target;

  double get value {
    switch (goalType) {
      case GoalType.budget:
        return CostMetric.fromCostItemList(items ?? []).expense ?? 0;
      case GoalType.savings:
        return max(0, CostMetric.fromCostItemList(items ?? []).balance);
      case GoalType.payment:
        return max(0, CostMetric.fromCostItemList(items ?? []).balance);
      default:
        return 0;
    }
  }

  double get progress => max(0, value / (target ?? 1));

  bool get achieved {
    switch (goalType) {
      case GoalType.budget:
        return progress < 1;
      case GoalType.savings:
        return progress > 1;
      case GoalType.payment:
        return progress > 1;
      default:
        return false;
    }
  }

  String get status {
    switch (goalType) {
      case GoalType.budget:
        return achieved ? "Contained" : "Overbudget";
      case GoalType.savings:
        return achieved ? "Achieved" : "Not Achieved";
      case GoalType.payment:
        return achieved ? "Not Achieved" : "Achieved";
      default:
        return "";
    }
  }
}

final List<Goal> exampleGoals = [
  Goal(
    title: "Create a monthly budget",
    goalType: GoalType.budget,
    goalTracking: GoalTrackingPeriod.monthly,
  ),
  Goal(
    title: "Limit spend on certain categories",
    goalType: GoalType.budget,
    goalTracking: GoalTrackingPeriod.monthly,
  ),
  Goal(
    title: "Save a certain amount every month",
    goalType: GoalType.savings,
    goalTracking: GoalTrackingPeriod.monthly,
  ),
  Goal(
    title: "Save for a travel plan/major purchase",
    goalType: GoalType.savings,
    goalTracking: GoalTrackingPeriod.overall,
  ),
  Goal(
    title: "Save for generational wealth",
    goalType: GoalType.savings,
    goalTracking: GoalTrackingPeriod.overall,
  ),
  Goal(
    title: "Build up emergency fund",
    goalType: GoalType.savings,
    goalTracking: GoalTrackingPeriod.overall,
  ),
  Goal(
    title: "Monthly DCA Investment/Fund Contribution",
    goalType: GoalType.payment,
    goalTracking: GoalTrackingPeriod.monthly,
  ),
  Goal(
    title: "Contribute to monthly payment of debt",
    goalType: GoalType.payment,
    goalTracking: GoalTrackingPeriod.monthly,
  ),
  Goal(
    title: "Pay off short-term debt",
    goalType: GoalType.payment,
    goalTracking: GoalTrackingPeriod.overall,
  ),
  Goal(
    title: "Plan for retirement",
    goalType: GoalType.savings,
    goalTracking: GoalTrackingPeriod.overall,
  ),
];

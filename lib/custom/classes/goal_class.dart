// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/enums/match_type.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:collection/collection.dart';

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
    this.matchType,
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
  final StringMatchType? matchType;
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
    matchType: json["matchType"] != null ? StringMatchType.values.byName(json["matchType"]) : null,
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
    "matchType": matchType?.name,
    "goalType": goalType?.name,
    "goalTracking": goalTracking?.name,
    "lastCreated": lastCreated?.toString(),
    "lastModified": lastModified?.toString(),
  };

  bool get isEnded => endDate?.isBefore(DateTime.now().startOfMonth) ?? false;
  bool get isStarted => startDate?.isBeforeOrSameMoment(DateTime.now().startOfMonth) ?? true;

  List<GoalProgress> getPastGoalProgress(List<CostItem> items) {
    if (!isStarted) return [];
    final cur = DateTime.now().startOfMonth;
    DateTime end;
    if (isEnded) {
      end = endDate!;
    } else {
      end = cur;
    }
    if (goalTracking == GoalTrackingPeriod.monthly) {
      return List.generate(
        max(1, end.month - startDate!.month),
        (i) {
          final month = startDate!.addMonth(i);
          return getGoalProgress(items, month)!;
        },
      );
    } else {
      return [];
    }
  }

  double? getMetric(CostMetric? metric) {
    if (metric == null) return null;
    switch (goalType) {
      case GoalType.budget:
        return metric.expense ?? 0;
      case GoalType.savings:
        return metric.balance;
      case GoalType.payment:
        return metric.balance.abs();
      default:
        return null;
    }
  }

  StringFilter? get filter =>
      filterString != null && matchType != null
          ? StringFilter(matchType: matchType!, query: filterString!)
          : null;

  GoalProgress? getGoalProgress(List<CostItem> items, DateTime yearMonth) {
    if (endDate?.isBefore(yearMonth.startOfMonth) ?? false) {
      return null;
    }
    final filteredItems =
        items.where((item) {
          final categoryQuery = categories?.contains(item.categoryId) ?? true;
          final nameQuery = item.name != null ? (filter?.checkMatch(item.name!) ?? true) : true;
          return categoryQuery && nameQuery;
        }).toList();

    if (goalTracking == GoalTrackingPeriod.monthly) {
      return GoalProgress(
        date: yearMonth.startOfMonth,
        goalTracking: goalTracking,
        items:
            filteredItems.where((item) {
              return item.date!.isInSameYearMonthAs(yearMonth);
            }).toList(),
        goalType: goalType,
        target: target,
      );
    } else if (goalTracking == GoalTrackingPeriod.overall) {
      return GoalProgress(
        date: startDate!,
        endDate: endDate ?? DateTime.now().add(Duration(days: 1000)),
        goalTracking: goalTracking,
        items:
            filteredItems
                .where(
                  (item) =>
                      (item.date!.isAfterOrSameMoment(startDate!)) &&
                      (item.date!.isBeforeOrSameMoment(endDate ?? DateTime.now().standard)),
                )
                .toList(),
        goalType: goalType,
        target: target,
      );
    } else {
      return null;
    }
  }

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    double? target,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categories,
    String? filterString,
    StringMatchType? matchType,
    GoalType? goalType,
    GoalTrackingPeriod? goalTracking,
    DateTime? lastCreated,
    DateTime? lastModified,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      target: target ?? this.target,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categories: categories ?? this.categories,
      filterString: filterString ?? this.filterString,
      matchType: matchType ?? this.matchType,
      goalType: goalType ?? this.goalType,
      goalTracking: goalTracking ?? this.goalTracking,
      lastCreated: lastCreated ?? this.lastCreated,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}

class GoalProgress {
  GoalProgress({
    this.date,
    this.endDate,
    this.items,
    this.goalType,
    this.goalTracking,
    this.target,
  });

  final DateTime? date;
  final DateTime? endDate;
  final List<CostItem>? items;
  final GoalType? goalType;
  final GoalTrackingPeriod? goalTracking;
  final double? target;

  double get value {
    switch (goalType) {
      case GoalType.budget:
        return CostMetric.fromCostItemList(items ?? []).expense ?? 0;
      case GoalType.savings:
        return max(0, CostMetric.fromCostItemList(items ?? []).balance);
      case GoalType.payment:
        return max(0, CostMetric.fromCostItemList(items ?? []).balance.abs());
      default:
        return 0;
    }
  }

  double get progress => (value / (target ?? 1)).clamp(0, double.infinity);

  bool get achieved {
    switch (goalType) {
      case GoalType.budget:
        return progress < 1;
      case GoalType.savings:
        return progress >= 1;
      case GoalType.payment:
        return progress >= 1;
      default:
        return false;
    }
  }

  String get status {
    switch (goalType) {
      case GoalType.budget:
        return achieved ? "Contained" : "Overspent";
      case GoalType.savings:
        return achieved ? "Achieved" : "Not Achieved";
      case GoalType.payment:
        return achieved ? "Achieved" : "Not Achieved";
      default:
        return "";
    }
  }

  String get currentStatus {
    switch (goalType) {
      case GoalType.budget:
        return achieved ? "Contained" : "Overbudget";
      case GoalType.savings:
        return achieved ? "Achieved" : "Pending";
      case GoalType.payment:
        return achieved ? "Achieved" : "Pending";
      default:
        return "";
    }
  }

  int get displayedDataCount {
    if (date == null) return 1;
    final lastDate = items?.sorted((a, b) => b.date!.compareTo(a.date!)).firstOrNull?.date ?? DateTime.now().standard;
    final finalDate = lastDate.isAfter(DateTime.now().standard) ? lastDate : DateTime.now().standard;
    return finalDate.difference(date!).inDays + 1;
  }

  int get totalData {
    if (date == null) return 1;
    switch (goalTracking) {
      case GoalTrackingPeriod.monthly:
        return date!.getTotalDayInMonth();
      case GoalTrackingPeriod.overall:
        return endDate?.difference(date!).inDays ?? 1;
      default:
        return 1;
    }
  }

  bool get isBudget => goalType == GoalType.budget;

  double get dailyTarget => (target ?? 0) / totalData;

  bool compareValueWithTarget({required double value, required double target}) {
    if (goalType == GoalType.budget) {
      return value <= target;
    } else {
      return value >= target;
    }
  }

  bool isWithinDailyTarget(double value) {
    switch (goalType) {
      case GoalType.budget:
        return value <= dailyTarget;
      case GoalType.savings:
        return value >= dailyTarget;
      case GoalType.payment:
        return value >= dailyTarget;
      default:
        return true;
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

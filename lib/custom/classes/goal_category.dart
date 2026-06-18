import 'package:budget_tracker/custom/enums/enum.dart';

class GoalCategory {
  const GoalCategory({
    required this.title,
    required this.description,
    required this.type,
    required this.trackingPeriod,
  });

  final String title;
  final String description;
  final GoalType type;
  final GoalTrackingPeriod trackingPeriod;
}

const List<GoalCategory> defaultGoalCategories = [
  GoalCategory(
    title: "Create a monthly budget",
    description: "rem ipsum dolor sit amet, consectetur adipiscing elit.",
    type: GoalType.budget,
    trackingPeriod: GoalTrackingPeriod.monthly,
  ),
  GoalCategory(
    title: "Cut spending on Certain Categories",
    description: "rem ipsum dolor sit amet, consectetur adipiscing elit.",
    type: GoalType.budget,
    trackingPeriod: GoalTrackingPeriod.monthly,
  ),
  GoalCategory(
    title: "Control Total Spendings Over a Period of Months",
    description: "rem ipsum dolor sit amet, consectetur adipiscing elit.",
    type: GoalType.budget,
    trackingPeriod: GoalTrackingPeriod.overall,
  ),
  GoalCategory(
    title: "Build Emergency Fund",
    description: "rem ipsum dolor sit amet, consectetur adipiscing elit.",
    type: GoalType.savings,
    trackingPeriod: GoalTrackingPeriod.overall,
  ),
  GoalCategory(
    title: "Set Monthly Savings Target",
    description: "rem ipsum dolor sit amet, consectetur adipiscing elit.",
    type: GoalType.savings,
    trackingPeriod: GoalTrackingPeriod.monthly,
  ),
  GoalCategory(
    title: "Save for Travel / Major Purchase",
    description: "rem ipsum dolor sit amet, consectetur adipiscing elit.",
    type: GoalType.savings,
    trackingPeriod: GoalTrackingPeriod.overall,
  ),
  GoalCategory(
    title: "Pay off short-term debt",
    description: "rem ipsum dolor sit amet, consectetur adipiscing elit.",
    type: GoalType.payment,
    trackingPeriod: GoalTrackingPeriod.overall,
  ),
  GoalCategory(
    title: "Pay off monthly installment of long term debt",
    description: "rem ipsum dolor sit amet, consectetur adipiscing elit.",
    type: GoalType.payment,
    trackingPeriod: GoalTrackingPeriod.monthly,
  ),
  GoalCategory(
    title: "Allocate Fund for Investment",
    description: "rem ipsum dolor sit amet, consectetur adipiscing elit.",
    type: GoalType.payment,
    trackingPeriod: GoalTrackingPeriod.monthly,
  ),
];

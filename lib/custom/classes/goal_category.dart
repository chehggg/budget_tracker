import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GoalCategory {
  const GoalCategory({
    required this.title,
    required this.description,
    required this.type,
    required this.trackingPeriod,
    required this.icon,
  });

  final String title;
  final String description;
  final GoalType type;
  final GoalTrackingPeriod trackingPeriod;
  final FaIconData icon;
}

const List<GoalCategory> defaultGoalCategories = [
  GoalCategory(
    title: "Set a Full Monthly Budget",
    description: "Track your expenses in a completely monthly plan.",
    type: GoalType.budget,
    trackingPeriod: GoalTrackingPeriod.monthly,
    icon: FontAwesomeIcons.piggyBank,
  ),
  GoalCategory(
    title: "Set a Customized Monthly Budget",
    description: "Set a monthly limit for selected categories or items.",
    type: GoalType.budget,
    trackingPeriod: GoalTrackingPeriod.monthly,
    icon: FontAwesomeIcons.magnifyingGlassDollar,
  ),
  GoalCategory(
    title: "Set a Total Spending Budget",
    description: "Track total spendings across a certain period of time (e.g., travel, event).",
    type: GoalType.budget,
    trackingPeriod: GoalTrackingPeriod.overall,
    icon: FontAwesomeIcons.wallet,
  ),
  GoalCategory(
    title: "Build up Emergency Fund",
    description: "Save up a financial safety net for unexpected expenses and rainy days.",
    type: GoalType.savings,
    trackingPeriod: GoalTrackingPeriod.overall,
    icon: FontAwesomeIcons.sackDollar,
  ),
  GoalCategory(
    title: "Set a Monthly Savings Target",
    description: "Commit to saving a fixed amount of money every month to build a habit.",
    type: GoalType.savings,
    trackingPeriod: GoalTrackingPeriod.monthly,
    icon: FontAwesomeIcons.chartLine,
  ),
  GoalCategory(
    title: "Save up for Travel / Major Purchase",
    description:
        "Commit to saving for a specific long-term milestone, like a vacation, vehicle, or home.",
    type: GoalType.savings,
    trackingPeriod: GoalTrackingPeriod.overall,
    icon: FontAwesomeIcons.houseChimney,
  ),
  GoalCategory(
    title: "Pay off Short-Term Debt",
    description: "Keep track of short term debt payment (e.g., credit card, borrowed money etc.).",
    type: GoalType.payment,
    trackingPeriod: GoalTrackingPeriod.overall,
    icon: FontAwesomeIcons.commentDollar,
  ),
  GoalCategory(
    title: "Track monthly installment",
    description: "Keep track of regular recurring payments like a mortgage or car loan.",
    type: GoalType.payment,
    trackingPeriod: GoalTrackingPeriod.monthly,
    icon: FontAwesomeIcons.landmark,
  ),
  GoalCategory(
    title: "Set a Monthly Investment Fund",
    description: "Set aside a fixed monthly amount to build up your wealth.",
    type: GoalType.payment,
    trackingPeriod: GoalTrackingPeriod.monthly,
    icon: FontAwesomeIcons.percent,
  ),
];

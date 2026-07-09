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
    title: "Create a monthly budget",
    description: "rem ipsum dolor sit amet, consectetur adipiscing elit.",
    type: GoalType.budget,
    trackingPeriod: GoalTrackingPeriod.monthly,
    icon: FontAwesomeIcons.piggyBank,
  ),
  GoalCategory(
    title: "Cut spending on Certain Categories",
    description: "rem ipsum dolor sit amet, consectetur adipiscing elit.",
    type: GoalType.budget,
    trackingPeriod: GoalTrackingPeriod.monthly,
    icon: FontAwesomeIcons.magnifyingGlassDollar,
  ),
  GoalCategory(
    title: "Control Total Spendings Over a Period of Months",
    description: "rem ipsum dolor sit amet, consectetur adipiscing elit.",
    type: GoalType.budget,
    trackingPeriod: GoalTrackingPeriod.overall,
    icon: FontAwesomeIcons.wallet,
  ),
  GoalCategory(
    title: "Build Emergency Fund",
    description: "rem ipsum dolor sit amet, consectetur adipiscing elit.",
    type: GoalType.savings,
    trackingPeriod: GoalTrackingPeriod.overall,
    icon: FontAwesomeIcons.sackDollar,
  ),
  GoalCategory(
    title: "Set Monthly Savings Target",
    description: "rem ipsum dolor sit amet, consectetur adipiscing elit.",
    type: GoalType.savings,
    trackingPeriod: GoalTrackingPeriod.monthly,
    icon: FontAwesomeIcons.chartLine,
  ),
  GoalCategory(
    title: "Save for Travel / Major Purchase",
    description: "rem ipsum dolor sit amet, consectetur adipiscing elit.",
    type: GoalType.savings,
    trackingPeriod: GoalTrackingPeriod.overall,
    icon: FontAwesomeIcons.houseChimney,
  ),
  GoalCategory(
    title: "Pay off short-term debt",
    description: "rem ipsum dolor sit amet, consectetur adipiscing elit.",
    type: GoalType.payment,
    trackingPeriod: GoalTrackingPeriod.overall,
    icon: FontAwesomeIcons.commentDollar,
  ),
  GoalCategory(
    title: "Pay off monthly installment of long term debt",
    description: "rem ipsum dolor sit amet, consectetur adipiscing elit.",
    type: GoalType.payment,
    trackingPeriod: GoalTrackingPeriod.monthly,
    icon: FontAwesomeIcons.landmark,
  ),
  GoalCategory(
    title: "Allocate Fund for Investment",
    description: "rem ipsum dolor sit amet, consectetur adipiscing elit.",
    type: GoalType.payment,
    trackingPeriod: GoalTrackingPeriod.monthly,
    icon: FontAwesomeIcons.percent,
  ),
];

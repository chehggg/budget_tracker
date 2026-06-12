enum CostType {
  expense,
  income;

  factory CostType.fromString(String? value) =>
      value == "income" ? CostType.income : CostType.expense;
}

enum FormGroup {
  expense(CostType.expense),
  income(CostType.income),
  favorite(null);

  final CostType? costType;
  const FormGroup(this.costType);
}

enum GoalType {
  budget("Keep spending within a specified amount."),
  savings("Save above a specified amount of money."),
  payment("Keep track of long-term financial commitments (investment, morgage, loan etc.).");

  final String description;

  const GoalType(this.description);
}

enum GoalTrackingPeriod {
  overall("Total", "Track your progress across the entire lifespan of the goal."),
  monthly("Monthly", "Keep track of your goal progress on a routinely, monthly basis.");

  final String title;
  final String description;

  const GoalTrackingPeriod(this.title, this.description);
}

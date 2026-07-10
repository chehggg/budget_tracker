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

enum ChartPeriod { week, month, year, custom }

enum KeyboardButtonType { char, delete, done, date }

enum KeyboardLayout { simple, complex }

enum SimpleKeyboardButtonType { decimal, doubleZero }

enum NumberSeparator {
  stop("."),
  comma(","),
  space(" ", applicableToDecimal: false),
  underscore("_", applicableToDecimal: false);

  final String symbol;
  final bool applicableToDecimal;
  final bool applicableToThousand;

  const NumberSeparator(
    this.symbol, {
    this.applicableToDecimal = true,
    this.applicableToThousand = true,
  });
}

enum SymbolPosition {
  front,back,none
}

enum SortType {
  asc, dsc;

  int sortItem<T extends Comparable>(T a, T b) {
    if (this == asc) {
      return a.compareTo(b);
    } else {
      return b.compareTo(a);

    }
  }
}

import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:budget_tracker/constants/categories.dart';
import 'package:budget_tracker/custom/category_class.dart';
import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/ui/list/list_viewmodel.dart';
import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CostListScreen extends StatefulWidget {
  const CostListScreen({
    super.key,
  });

  @override
  State<CostListScreen> createState() => _CostListScreenState();
}

class _CostListScreenState extends State<CostListScreen> {
  late final ScrollController _controller;
  bool expanded = true;

  void animateScroll() {
    if (expanded) {
      _controller.animateTo(80, duration: Durations.medium1, curve: Curves.easeInOut);
    } else {
      _controller.animateTo(0, duration: Durations.medium1, curve: Curves.easeInOut);
    }
    // setState(() {
    //   expanded = !expanded;
    // });
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(() {
      setState(() {
        if (_controller.offset < 10) {
          expanded = true;
        } else {
          expanded = false;
        }
        debugPrint(expanded.toString());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ready = context.select((ListModel state) => state.ready);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const ListViewAppBar(),
      body:
          ready
              ? SafeArea(
                minimum: EdgeInsets.only(top: 8),
                child: Flex(
                  direction: Axis.vertical,
                  children: [
                    const DateBreadcrumb(),
                    Expanded(
                      child: CustomScrollView(
                        controller: _controller,
                        slivers: [
                          SummaryTab(
                            onPressed: animateScroll,
                          ),
                          const CostEntryList(),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              : Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
    );
  }
}

class ListViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ListViewAppBar({
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final isBlurred = context.select((ListModel state) => state.isBlurred);
    final isSearchOpened = context.select((ListModel state) => state.isSearchOpened);
    final selectionMode = context.select((ListModel state) => state.selectionMode);
    final selectedItemLength = context.select((ListModel state) => state.selectedItems.length);

    if (selectionMode) {
      return AppBar(
        actionsPadding: EdgeInsets.only(right: 10),
        animateColor: true,
        backgroundColor: context.customCs.fadeColor2,
        leading: BackButton(
          onPressed: () {
            context.listMod.toggleSelectionMode(false);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Flushbar(
                flushbarPosition: FlushbarPosition.TOP,
                duration: Duration(seconds: 1),
                title: "$selectedItemLength items deleted",
                message: "$selectedItemLength items deleted",
              ).show(context);
              context.listMod.deleteSelectedItems();
            },
            icon: Icon(Icons.delete),
          ),
        ],
        title: Text(
          "Selected: ${selectedItemLength}",
          style: context.customTt.numberFontMedium!,
        ),
      );
    } else if (isSearchOpened) {
      return AppBar(
        actionsPadding: EdgeInsets.only(right: 10),
        backgroundColor: context.customCs.fadeColor2,
        leading: BackButton(
          onPressed: () {
            context.listMod.toggleSearch(false);
          },
        ),
        title: const SearchTabTextField(),
      );
    } else {
      return AppBar(
        actionsPadding: EdgeInsets.only(right: 10),
        title: Text("OVERVIEW", style: context.customTt.dateLabel),
        actions: [
          IconButton(
            onPressed: context.listMod.toggleSearch,
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: context.listMod.toggleBlur,
            icon: Icon(!isBlurred ? Icons.visibility : Icons.visibility_off),
          ),
          // IconButton(
          //   onPressed: context.listMod.getCurMonthData,
          //   icon: Icon(Icons.refresh),
          // ),
        ],
      );
    }
  }
}

class DateBreadcrumb extends StatelessWidget {
  const DateBreadcrumb({super.key});

  @override
  Widget build(BuildContext context) {
    final curMonth = context.select((ListModel state) => state.currentMonth);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const MonthSelectorDialog(),
        );
      },
      onHorizontalDragEnd: (details) {
        debugPrint(details.primaryVelocity.toString());
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! > 500) {
          // swipe right
          context.listMod.changeYearMonth(DateTime(curMonth.year, curMonth.month - 1));
        } else if (details.primaryVelocity! < -500) {
          // swipe left
          context.listMod.changeYearMonth(DateTime(curMonth.year, curMonth.month + 1));
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        // decoration: BoxDecoration(
        //   color: Theme.of(context).colorScheme.surfaceContainerHigh,
        // ),
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: IconButton(
                style: ElevatedButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                ),
                onPressed: () {
                  context.listMod.changeYearMonth(DateTime(curMonth.year, curMonth.month - 1));
                },
                icon: Icon(Icons.arrow_back_ios),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  DateFormat(
                    "yMMMM",
                  ).format(curMonth),
                  style: context.customTt.dateLabel!.copyWith(fontSize: 30),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: IconButton(
                style: ElevatedButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                ),
                onPressed: () {
                  context.listMod.changeYearMonth(DateTime(curMonth.year, curMonth.month + 1));
                },
                icon: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CostEntryList extends StatelessWidget {
  const CostEntryList({super.key});

  @override
  Widget build(BuildContext context) {
    final groupedCostItems = context.select((ListModel state) => state.outputCostItems);
    final dailySummary = context.select((ListModel state) => state.outputDailySummary);
    final selectionMode = context.select((ListModel state) => state.selectionMode);
    final selectedItems = context.select((ListModel state) => state.selectedItems);
    // ignore: unused_local_variable
    final selectedItemLength = context.select((ListModel state) => state.selectedItems.length);

    debugPrint(
      "rebuilt, item count: ${groupedCostItems.entries.isNotEmpty ? groupedCostItems.entries.first.value.length : 0}",
    );
    // debugPrint("rebuilt, item count: ${groupedCostItems.entries.length}");
    if (groupedCostItems.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: context.mq.size.height * 0.5,
          child: Center(
            child: const Text("Nothing here...!?"),
          ),
        ),
      );
    } else {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 12),
        sliver: SliverList.builder(
          itemCount: groupedCostItems.length,
          itemBuilder: (context, index) {
            // ignore: unused_local_variable
            final spacing = context.read<ThemeModel>().spacingValue;
            final DateTime date = groupedCostItems.keys.elementAt(index);
            final List<CostItem> costItems = groupedCostItems.values.elementAt(index);

            final String dateString = date.formatPretty();
            final double daySummary = dailySummary[date]!.balance;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      textBaseline: TextBaseline.ideographic,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(dateString, style: context.customTt.dateLabel!.copyWith()),
                        // style: context.tt.bodyLarge),
                        HideableText(
                          NumberFormat.currency(symbol: "RM").format(daySummary),
                          isCurrency: true,
                          textStyle: context.customTt.numberFontMedium!.copyWith(
                            color: daySummary < 0 ? Colors.redAccent : Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...costItems.map((costItem) {
                    final CostItemCategory cat = context.listMod.findCatInList(costItem);
                    final selected = selectedItems.any((item) => item.uuid == costItem.uuid);
                    return GestureDetector(
                      onLongPress: () {
                        context.listMod.toggleSelectionMode(true);
                        context.listMod.updateSelection(costItem, true);
                      },
                      onTap: () {
                        if (selectionMode) {
                          context.listMod.updateSelection(costItem, !selected);
                        } else {
                          context.navMod.openForm(
                            FormArgument(selectedCostItem: costItem),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? context.customCs.fadeColor3 : Colors.transparent,
                        ),
                        child: Row(
                          spacing: 12,
                          children: [
                            if (selectionMode)
                              Checkbox(
                                visualDensity: VisualDensity(vertical: -4, horizontal: -4),
                                value: selected,
                                onChanged: (value) {
                                  if (value != null) {
                                    context.listMod.updateSelection(costItem, value);
                                  }
                                },
                              ),
                            CategoryIconContainer(
                              category: cat,
                              size: 20,
                            ),
                            Expanded(
                              child: Text(
                                "${costItem.name}",
                                // maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: context.tt.bodyMedium,
                              ),
                            ),
                            HideableText(
                              NumberFormat.currency(symbol: "RM").format(costItem.signedAmount),
                              isCurrency: true,
                              textStyle: context.customTt.numberFontSmall!.copyWith(
                                color:
                                    costItem.isExpense
                                        ? Colors.red.withAlpha(200)
                                        : Colors.green.withAlpha(200),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      );
    }
  }
}

class SummaryTab extends StatelessWidget {
  const SummaryTab({super.key, this.onPressed});

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final expense = context.select((ListModel state) => state.outputMonthSummary.expense ?? 0);
    final income = context.select((ListModel state) => state.outputMonthSummary.income ?? 0);
    final balance = income - expense;

    return SliverPersistentHeader(
      delegate: SummaryHeaderDelegate(
        expense: expense,
        income: income,
        balance: balance,
        onPressed: onPressed,
      ),
      pinned: true,
      floating: true,
    );
  }
}

class SummaryHeaderDelegate extends SliverPersistentHeaderDelegate {
  const SummaryHeaderDelegate({
    required this.expense,
    required this.income,
    required this.balance,
    this.onPressed,
  });

  final double expense, income, balance;
  final void Function()? onPressed;

  Widget expenseMetricCard(
    BuildContext context, {
    String labelText = "",
    double progress = 0,
    String value = "",
    bool isBig = false,
  }) {
    final appColorTheme = context.cs;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          // label
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Opacity(
              opacity: lerpDouble(1, !isBig ? 0 : 1, Interval(0, 0.6).transform(progress))!,
              child: Text(
                labelText,
                style: context.customTt.numberLabel!.copyWith(
                  height: lerpDouble(
                    1.5,
                    !isBig ? 0.01 : 1.5,
                    Interval(0.3, 0.7).transform(progress),
                  ),
                  color: appColorTheme.onSecondary.withAlpha(200),
                ),
              ),
            ),
          ],
        ),
        Opacity(
          opacity: !isBig ? lerpDouble(1, 0, Interval(0, 0.8).transform(progress))! : 1,
          child: HideableText(
            maxLine: 1,
            value,
            isCurrency: true,
            textStyle:
                isBig
                    ? context.customTt.numberFontLarge!.copyWith(
                      height: 1.2,
                      fontSize: lerpDouble(50, 30, progress),
                      color: context.customCs.onFlipCard,
                    )
                    : context.customTt.numberFontSmall!.copyWith(
                      height: lerpDouble(1.2, 0.01, Interval(0.2, 0.8).transform(progress)),
                      fontSize: lerpDouble(22, 12, progress),
                      color: context.customCs.onFlipCard,
                    ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0, 1);
    return Container(
      width: context.mq.size.width,
      color: context.cs.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: context.customCs.flipCardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  spacing: 0,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    expenseMetricCard(
                      context,
                      labelText: "Summary",
                      progress: progress,
                      value: NumberFormat.currency(symbol: "RM", decimalDigits: 0).format(balance),
                      isBig: true,
                    ),
                    Opacity(
                      opacity: lerpDouble(1, 0, progress)!,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          spacing: 20,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            HideableText(
                              "-${NumberFormat.compactCurrency(symbol: "RM").format(expense)}",
                              textStyle: context.customTt.numberFontSmall!.copyWith(
                                color: Colors.red,
                                height: 1,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              "+${NumberFormat.compactCurrency(symbol: "RM").format(income)}",
                              style: context.customTt.numberFontSmall!.copyWith(
                                color: Colors.green,
                                height: 1,
                                fontSize: 18,
                              ),
                            ),
                            // Expanded(
                            //   child: expenseMetricCard(
                            //     context,
                            //     labelText: "Expense",
                            //     progress: progress,
                            //     value: NumberFormat.compactCurrency(symbol: "RM").format(expense),
                            //     isBig: false,
                            //   ),
                            // ),
                            // Expanded(
                            //   child: expenseMetricCard(
                            //     context,
                            //     labelText: "Income",
                            //     progress: progress,
                            //     value: NumberFormat.compactCurrency(symbol: "RM").format(income),
                            //     isBig: false,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Expanded(child: SizedBox()),
              Container(
                width: 100,
                // height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: BoxBorder.all(color: Colors.transparent),
                ),
                clipBehavior: Clip.hardEdge,
                child: AnimatedScale(
                  scale: lerpDouble(1, 0.5, Interval(0.1, 1).transform(progress))!,
                  duration: Durations.short1,
                  child: Opacity(
                    opacity: lerpDouble(1, 0, Interval(0, 0.7).transform(progress))!,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: const SummaryChart(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 157;

  @override
  double get minExtent => 105;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

class SummaryChart extends StatefulWidget {
  const SummaryChart({super.key});

  // final Map<String, Map<String, dynamic>> summaryData;

  @override
  State<SummaryChart> createState() => _SummaryChartState();
}

class _SummaryChartState extends State<SummaryChart> {
  late PageController _controller;
  int _currentPage = 0;
  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // _controller.jumpTo(0);
    setState(() {
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final expense = context.select((ListModel state) => state.outputMonthSummary.expense ?? 0);
    final income = context.select((ListModel state) => state.outputMonthSummary.income ?? 0);
    final balance = income - expense;

    final double balancePercentage = income > 0 ? balance / income : 0;
    // get month to update the chart whenever month change
    // ignore: unused_local_variable
    // final expense = context.select(
    //   (AppModel state) => state.totalCurrentMonthExpense.customCurrencyFormat('RM'),
    // );
    // final month = context.select((AppModel state) => state.selectedYearMonth);
    final List<Widget> charts = [];

    charts.add(
      Stack(
        alignment: Alignment.center,
        children: [
          Column(
            spacing: 4,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Balance',
                style: context.customTt.numberFontSmall!.copyWith(
                  color: context.cs.surface.withAlpha(150),
                  height: 1,
                  fontSize: 12,
                ),
              ),
              Text(
                income > 0 ? NumberFormat.percentPattern().format(balancePercentage) : "N/A",
                style: context.customTt.numberFontMedium!.copyWith(
                  color: context.cs.surface,
                  fontWeight: FontWeight(700),
                  height: 1,
                ),
              ),
            ],
          ),
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              startDegreeOffset: -90,
              centerSpaceColor: Colors.transparent,
              sections: [
                PieChartSectionData(
                  showTitle: false,
                  value: balancePercentage == 0 ? 0.001 : balancePercentage,
                  radius: 10,
                  color: context.customCs.onFlipCard,
                  // color: Colors.green.shade800,
                  // cornerRadius: 10,
                ),
                PieChartSectionData(
                  showTitle: false,
                  value: 1 - balancePercentage,
                  radius: 10,
                  color: context.cs.surface.withAlpha(20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    // charts.add(customPieChart(expense, context, "Budget"));
    // if (widget.summaryData['expense']!['value'] > 0) {
    // }
    // if (widget.summaryData['income']!['value'] > 0) {
    //   charts.add(customPieChart(widget.summaryData, context, "Balance"));
    // }
    return charts.first;
    // return Column(
    //   mainAxisAlignment: MainAxisAlignment.end,
    //   crossAxisAlignment: CrossAxisAlignment.end,
    //   children: [
    //     Container(
    //       // decoration: BoxDecoration(border: Border.all()),
    //       child: Expanded(
    //         child: PageView(
    //           onPageChanged:
    //               (value) => setState(() {
    //                 _currentPage = value;
    //               }),
    //           controller: _controller,
    //           children: charts,
    //         ),
    //       ),
    //     ),
    //     PageIndicator(
    //       pageLength: charts.length,
    //       currentPage: _currentPage,
    //     ),
    //   ],
    // );
  }

  Widget customPieChart(
    Map<String, Map<String, dynamic>> totalCost,
    BuildContext context,
    String chartValue,
  ) {
    double percentage;
    double dividend;
    double divisor;
    Color barColor;
    if (chartValue == "Balance") {
      dividend = totalCost['balance']!['value'];
      // if balance is negative, set the balance as 0%
      // pass small value to balance so that the chart does not treat it as 0
      // which trigger bug (color spans whole circle)
      if (dividend < 0) {
        dividend = 0.0002;
      }
      divisor = totalCost['income']!['value'];
      barColor = Colors.greenAccent;
    } else {
      // budget
      dividend = totalCost['expense']!['value'];
      divisor = 4000;
      barColor = Colors.redAccent;
    }

    percentage = dividend / divisor;
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          duration: Durations.extralong1,
          curve: Curves.fastOutSlowIn,
          PieChartData(
            centerSpaceColor: Theme.of(context).colorScheme.surfaceContainer,
            centerSpaceRadius: 35,
            startDegreeOffset: 270,
            sections: [
              PieChartSectionData(
                value: dividend < 0 ? 0 : dividend,
                color: barColor,
                radius: 8,
                showTitle: false,
                // titlePositionPercentageOffset: 1
              ),
              PieChartSectionData(
                value: divisor - dividend <= 0 ? 0 : divisor - dividend,
                color: Theme.of(context).colorScheme.primary.withAlpha(20),
                radius: 8,
                showTitle: false,
              ),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              chartValue,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                fontSize: 12,
              ),
            ),
            HideableText(
              NumberFormat("#0%").format(percentage),
              textStyle: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 24),
            ),
          ],
        ),
      ],
    );
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.pageLength,
    required this.currentPage,
  });

  final int pageLength;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    // final actualPage = controller.page
    return Row(
      spacing: 8,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        pageLength,
        (int value) => AnimatedContainer(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color:
                currentPage == value
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withAlpha(80),
            shape: BoxShape.circle,
          ),
          duration: Durations.medium1,
        ),
      ),
    );
  }
}

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  Widget createCustomFilterChip(
    BuildContext context, {
    IconData? icon,
    String text = "",
    Function()? onTap,
    bool isActive = false,
  }) {
    final borderRadius = BorderRadius.circular(12);
    return Flexible(
      fit: FlexFit.tight,
      child: Material(
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Container(
            // height: toolbarHeight - 16,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: BoxBorder.all(color: context.cs.primary, width: 0.5),
              borderRadius: borderRadius,
              color: isActive ? context.cs.primary.withAlpha(50) : context.cs.primary.withAlpha(10),
            ),
            child: Row(
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? Icons.check : icon,
                  color: context.cs.primary,
                  // size: toolbarHeight / 2 - 10,
                ),
                Text(text, style: context.tt.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomFilterAppBar(BuildContext context) {
    final isCategoryFiltered = context.select(
      (AppModel state) => state.filteredCategories.length < state.categories.length,
    );
    final isDateFiltered = context.select((AppModel state) => state.filterDateRange != null);
    // final toolbarHeight = MediaQuery.of(context).size.height * 0.05;

    return Padding(
      padding: EdgeInsets.all(8),
      child: Flex(
        direction: Axis.horizontal,
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          createCustomFilterChip(
            context,
            icon: Icons.category,
            text: "Category",
            onTap: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Column(
                      children: [
                        Text("Filter Category", style: context.customTt.dateLabel),
                        Text("selected category", style: context.customTt.numberFontMedium),
                      ],
                    ),
                    content: ListView.builder(
                      itemCount: 2,
                      itemBuilder: (context, index) {},
                    ),
                  );
                },
              );
            },
            isActive: isCategoryFiltered,
          ),
          createCustomFilterChip(
            context,
            icon: Icons.date_range,
            text: "Date",
            // onTap: () async => showFilterDateDialog(),
            isActive: isDateFiltered,
          ),
          createCustomFilterChip(
            context,
            icon: Icons.money,
            text: "Amount",
            // onTap: () async => showFilterAmountDialog(),
            isActive: isDateFiltered,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: context.cs.surface),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: PopScope(
          onPopInvokedWithResult: (didPop, result) {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SearchTabTextField(),
              bottomFilterAppBar(context),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchTabTextField extends StatefulWidget {
  const SearchTabTextField({
    super.key,
  });

  @override
  State<SearchTabTextField> createState() => _SearchTabTextFieldState();
}

class _SearchTabTextFieldState extends State<SearchTabTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() => context.listMod.updateSearch(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: context.tt.bodyMedium!,
      controller: _controller,
      autofocus: true,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        visualDensity: VisualDensity(vertical: -4, horizontal: -4),
        focusedBorder: InputBorder.none,
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.all(0),
        suffixIcon: IconButton(
          visualDensity: VisualDensity(vertical: -4, horizontal: -4),
          iconSize: 24,
          onPressed: () {
            _controller.clear();
            context.listMod.updateSearch("");
          },
          icon: Icon(Icons.clear),
        ),
        hint: Row(
          spacing: 8,
          children: [
            Icon(Icons.search, color: context.customCs.fadeColor2),
            Text(
              "Search items via description...",
              style: context.tt.bodyMedium!.copyWith(color: context.customCs.fadeColor2),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterAmountDialog extends StatefulWidget {
  const FilterAmountDialog({super.key});

  @override
  State<FilterAmountDialog> createState() => FilterAmountDialogState();
}

class FilterAmountDialogState extends State<FilterAmountDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Amount Filter"),
      content: RangeSlider(
        values: RangeValues(context.listMod.minAmount, context.listMod.maxAmount),
        onChanged: (values) {},
      ),
      actions: [
        const DismissTextButton(text: "Cancel"),
        const AffirmativeTextButton(text: "Save"),
      ],
    );
  }
}

class CategoryFilterDialog extends StatefulWidget {
  const CategoryFilterDialog({super.key});

  @override
  State<CategoryFilterDialog> createState() => _CategoryFilterDialogState();
}

class _CategoryFilterDialogState extends State<CategoryFilterDialog> {
  @override
  Widget build(BuildContext context) {
    final categories = defaultCostItemCategories;
    final filteredCategories = context.select((ListModel state) => state.filteredCategories);
    final bool allItemSelected = categories.length == filteredCategories.length;
    return AlertDialog(
      title: Text("Category Filter"),
      content: CustomScrollView(
        slivers: [
          Row(
            children: [
              Expanded(
                child: Text(allItemSelected ? "Unselect All" : "Select All"),
              ),
              Checkbox(
                value: allItemSelected,
                onChanged: (value) {
                  if (value != null) {
                    context.listMod.toggleAllCategoryFilter(value);
                  }
                },
              ),
            ],
          ),
          SliverList.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories.elementAt(index);
              return Row(
                spacing: 12,
                children: [
                  CategoryIconContainer(category: category),
                  Expanded(child: Text(category.name!)),
                  Checkbox(
                    value: filteredCategories.contains(category.id!),
                    onChanged: (value) {
                      if (value != null) {
                        context.listMod.toggleCategoryFilter(category.id!, value);
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      actions: [
        const DismissTextButton(text: "Cancel"),
        const AffirmativeTextButton(text: "Save"),
      ],
    );
  }
}

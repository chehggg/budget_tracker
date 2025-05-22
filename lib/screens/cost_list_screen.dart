import 'dart:ui' as ui;

import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/models/navigation_model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CostListScreen extends StatelessWidget {
  const CostListScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    debugPrint("list screen is build");
    final isBlur = context.select((ThemeModel state) => state.isBlurApplied);
    return Scaffold(
      body: SafeArea(
        child: Flex(
          direction: Axis.vertical,
          children: [
            const DateSelector(),
            const BudgetSummaryBar(),
            Expanded(child: const CostEntryList()),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.title),
        actions: [
          IconButton(
            onPressed: null, 
            icon: Icon(Icons.search)
          ),
          IconButton(
            onPressed: () => context.read<ThemeModel>().toggleBlur(),
            icon: Icon(!isBlur?  Icons.visibility : Icons.visibility_off)
          ),
          IconButton(
            onPressed: () => context.read<AppModel>().refreshMetric(),
            icon: Icon(Icons.refresh)
          )
        ],
      ),
      // bottomNavigationBar: CustomNavigationBottomBar(),
      // floatingActionButton: FloatingActionButton.large(
      //   onPressed: (){
      //     Navigator.of(context).pushNamed('/form', 
      //       arguments:  FormArgument(isNew: true));
      //   },
      //   shape: CircleBorder(),
      //   enableFeedback: true,
      //   elevation: 0,
      //   child: Icon(Icons.add),
        
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

    );
  }
}

class DateSelector extends StatelessWidget {
  const DateSelector({super.key});

  @override
  Widget build(BuildContext context) {
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
        if (details.primaryVelocity! > 500) { // swipe right
          context.read<AppModel>().changeYearMonth(false);
        } else if (details.primaryVelocity! < -500){ // swipe left
          context.read<AppModel>().changeYearMonth(true);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                context.read<AppModel>().changeYearMonth(false);
              }, 
              icon: Icon(Icons.arrow_back_ios)
            ),
            Expanded(
              child: Center(
                child: Text(
                  DateFormat("yMMMM", context.select((ThemeModel state) => state.appLocale.toLanguageTag())).format(context.select((AppModel state) => state.selectedYearMonth)),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20),
                ),
              )
            ),
            IconButton(
              onPressed: () {
                context.read<AppModel>().changeYearMonth(true);
              }, 
              icon: Icon(Icons.arrow_forward_ios)
            ),
          ],
        ),
      ),
    );
  }
}

class CostEntryList extends StatefulWidget {
  const CostEntryList({super.key});

  @override
  State<CostEntryList> createState() => _CostEntryListState();
}

class _CostEntryListState extends State<CostEntryList> {

  @override 
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    // final appState = context.watch<AppModel>();
    final groupedCostItems = context.select((AppModel model) => model.dateGroupedItem);
    final locale = context.select((ThemeModel model) => model.appLocale);
    // final mode = context.select((ThemeModel model) => model.theme); // include this so that the list change color when theme change
    final appModelFunction = context.watch<AppModel>();
    
    if (groupedCostItems.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.emptyListDisplay),
      );
    } else {
      return Scrollbar(
        thickness: 4,
        // trackVisibility: true,
        thumbVisibility: true,
        radius: Radius.circular(200),
        child: NotificationListener<OverscrollIndicatorNotification>(
          child: ListView.builder(
            itemCount: groupedCostItems.length,
            itemBuilder:(context, index) {
              final String groupedDate = groupedCostItems.keys.elementAt(index);
              final List<CostItem> costItems = groupedCostItems.values.elementAt(index);
              // final String formattedDate = DateFormat('dd MMMM',locale.toLanguageTag()).format(costItems.first.getDateTime());
              final String formattedDate = DateFormat('d MMM (E)',locale.toLanguageTag()).format(costItems.first.getDateTime());
              final String dailyBudget = appModelFunction.getFormattedDailyTotal(groupedDate);
              return Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent, 
                  disabledColor: Theme.of(context).colorScheme.onSurface
                ),
                child: ExpansionTile(
                  enabled: false,
                  dense: true,
                  initiallyExpanded: true,
                  tilePadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  minTileHeight: 10,
                  childrenPadding: const EdgeInsets.fromLTRB(0,0,0,12),
                  title: Text(
                    formattedDate, 
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      fontSize: 12,
                      // letterSpacing: 4,
                      color: Theme.of(context).colorScheme.primary
                    ),
                  ),
                  trailing: Text(
                    dailyBudget, 
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 16,
                      color: dailyBudget[0] == "-" ? Colors.redAccent : Colors.greenAccent
                    ),
                  ),
                  children: costItems.map((costItem) {
                    final CostItemCategory category = appModelFunction.getCategoryEntry(costItem.category)!;
                    final ColorScheme categoryColorScheme = category.colorScheme;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              // color: categoryColorScheme.primaryContainer
                            ),
                            child: ListTile(
                              dense: true,
                              tileColor: Colors.transparent,
                              visualDensity: VisualDensity(vertical: 0),
                              contentPadding: EdgeInsets.only(left: 16, right: 16),
                              shape: RoundedRectangleBorder(side: BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(8)),
                              title: Text(
                                costItem.name, 
                                maxLines: 3,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                // style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: categoryColorScheme.onSurface),
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontSize: 14
                                ),
                              ),
                              leading: category.generateRoundedIcon(36, categoryColorScheme.primaryContainer, categoryColorScheme.onPrimaryContainer),
                              trailing: Text(
                                appModelFunction.getFormattedCostItemValue(costItem),
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  fontSize: 14
                                  // color: categoryColorScheme.onPrimaryContainer
                                ),
                              ),
                              onTap: () => context.read<NavigationModel>().openForm(
                                FormArgument(isNew: false, selectedCostItem: costItem)
                              )
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      );
    }
  }
}

class BudgetSummaryBar extends StatelessWidget {
  const BudgetSummaryBar({
    super.key,
  });

  bool hasTextOverflow(
    String text, 
    TextStyle style,
    double textScaleFactor,
    {
      double minWidth = 0, 
      double maxWidth = double.infinity, 
      int maxLines = 1
    }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: ui.TextDirection.ltr,
      textScaler: TextScaler.linear(textScaleFactor),
    )..layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String,Map<String,dynamic>> totalCost = context.select((AppModel state) => {
      "income": {
        "value": state.totalCurrentMonthIncome,
        "string": state.getTotalAsString("income"),
        "stringSuffix": state.getTotalAsString("income", useSuffix: true)
      },
      "expense": {
        "value": state.totalCurrentMonthExpense,
        "string": state.getTotalAsString("expense"),
        "stringSuffix": state.getTotalAsString("expense", useSuffix: true)
      },
      "balance": {
        "value": state.totalCurrentMonthbalance,
        "string": state.getTotalAsString("balance"),
        "stringSuffix": state.getTotalAsString("balance", useSuffix: true)
      },
    });

    final screenSize = MediaQuery.of(context).size; 
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container( // main box
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12)
        ),
        height: screenSize.height * 0.14, // 12 as spacing between the rightmost container
        width: screenSize.width,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 8,
              children: [
                SizedBox(
                  width: constraints.maxWidth * 3/5,
                  child: Column( // vertical
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 20,
                    children: [
                      costCard(
                        context,
                        AppLocalizations.of(context)!.balance, 
                        totalCost['balance']!,
                        isBig: true
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          spacing: 10,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth * 1.3/5,
                              child: costCard(
                                context,
                                AppLocalizations.of(context)!.expense, 
                                totalCost['expense']!,
                              )
                            ),
                            SizedBox(
                              width: constraints.maxWidth * 1.3/5,
                              child: costCard(
                                context,
                                AppLocalizations.of(context)!.income, 
                                totalCost['income']!,
                              )
                            ),
                          ]
                        ),
                      )
                    ],
                  ),
                ),
                // VerticalDivider(),
                SizedBox(
                  width: constraints.maxWidth * 2/5 - 32,
                  child: SummaryChart(summaryData: totalCost,)
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget costCard(
    BuildContext context,
    String labelText,
    Map<String,dynamic> value,
    {bool isBig = false}
  ) {
    final appTheme = Theme.of(context);
    final appTextTheme = appTheme.textTheme;
    final appColorTheme = appTheme.colorScheme;
    final isBlur = context.select((ThemeModel state) => state.isBlurApplied);
    final TextStyle mainTextStyle;
    if (isBig) {
      mainTextStyle =  appTextTheme.displayMedium!.copyWith(
        fontSize: 32
      );
    } else {
      mainTextStyle =  appTextTheme.displaySmall!.copyWith(
        fontSize: 16
      );
    }
    return Column( 
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row( // label
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Text(
              labelText, 
              style: appTextTheme.labelSmall!.copyWith(
                color: appColorTheme.primary,
                fontSize: 12
              ),
            ),
            if(isBlur) Icon(
              Icons.visibility_off, 
              size: 12, 
              color: appColorTheme.secondary
            )
          ],
        ),
        BlurrableText(
          value['string'], 
          blurAmount: isBig ? 8: 4, 
          isVisible: !isBlur, 
          textStyle: mainTextStyle,
          overflowText: value['stringSuffix'],
        )
      ],
    );
  }
}

class SummaryChart extends StatefulWidget {
  const SummaryChart({
    super.key,
    required this.summaryData
  });

  final Map<String,Map<String,dynamic>> summaryData;

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
    // get month to update the chart whenever month change
    // ignore: unused_local_variable
    // final month = context.select((AppModel state) => state.selectedYearMonth);
    final List<Widget> charts = [];

    if (widget.summaryData['expense']!['value'] > 0) {
      charts.add(customPieChart(widget.summaryData, context, "Budget"));
    }
    if (widget.summaryData['income']!['value'] > 0) {
      charts.add(customPieChart(widget.summaryData, context, "Balance"));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            // decoration: BoxDecoration(border: Border.all()),
            child: PageView(
              onPageChanged: (value) => setState(() {
                _currentPage = value;
              }),
              controller: _controller,
              children: charts
            ),
          ),
        ),
        PageIndicator(pageLength: charts.length, currentPage: _currentPage,)
      ],
    );
  }

  Widget customPieChart(
    Map<String, Map<String, dynamic>> totalCost, 
    BuildContext context,
    String chartValue
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
    } else { // budget
      dividend = totalCost['expense']!['value'];
      divisor = 4000;
      barColor = Colors.redAccent;
    }

    percentage = dividend/divisor;
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          duration: Durations.extralong1,
          curve: Curves.fastOutSlowIn,
          PieChartData(
            centerSpaceColor: Theme.of(context).colorScheme.surfaceContainer,
            centerSpaceRadius: 40,
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
                showTitle: false
              ),
            ]
          )
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$chartValue",
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                fontSize: 12,
              ),
            ),
            BlurrableText(
              // percentage >= 0? NumberFormat("#0%").format(percentage) : "0%",
              NumberFormat("#0%").format(percentage),
              blurAmount: 4, 
              isVisible: !context.select((ThemeModel state) => state.isBlurApplied), 
              textStyle: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 24)
            )
          ]
        )
        
      ]
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
      children: List.generate(pageLength, (int value) => 
        AnimatedContainer(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: currentPage == value ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withAlpha(80),
            shape: BoxShape.circle
          ),
          duration: Durations.medium1,
        ),
      ) 
    );
  }
}

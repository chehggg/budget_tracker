import 'dart:ui';

import 'package:budget_tracker/constants/categories.dart';
import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/ui/list/list_viewmodel.dart';
import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/models/navigation_model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CostListScreen extends StatelessWidget {
  const CostListScreen({super.key});

  // Future<void> showFilterCategoryDialog() {
  //   return showDialog(
  //     context: context,
  //     builder: (context) {
  //       final fullCategories = context.read<AppModel>().categories;
  //       Set<String> selectedCategories = context.read<AppModel>().filteredCategories;
  //       final selectedThemeMode = context.select((ThemeModel state) => state.theme);
  //       Set<CostItemCategory> displayCategories = {};
  //       final TextEditingController controller = TextEditingController();
  //       return StatefulBuilder(builder: (context, setState) {
  //         final theme = Theme.of(context);
  //         final hintColor = theme.colorScheme.primary.withAlpha(100);
  //         displayCategories = Set.from(controller.text == ""
  //             ? fullCategories
  //             : fullCategories.where((category) => category.name!.contains(controller.text)));
  //         return AlertDialog(
  //           title: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text("Filter Category"),
  //               Text(
  //                 "${selectedCategories.length} selected ${selectedCategories.length <= 1 ? "category" : "categories"}",
  //                 overflow: TextOverflow.fade,
  //                 maxLines: 1,
  //                 style: Theme.of(context).textTheme.bodyMedium,
  //               ),
  //             ],
  //           ),
  //           contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
  //           content: SizedBox(
  //             height: MediaQuery.of(context).size.height * 0.5,
  //             width: MediaQuery.of(context).size.width * 0.7,
  //             child: Column(
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 16),
  //                   child: TextField(
  //                     controller: controller,
  //                     style: theme.textTheme.bodyMedium!,
  //                     decoration: InputDecoration(
  //                       border:
  //                           OutlineInputBorder(borderRadius: BorderRadius.circular(200), borderSide: BorderSide.none),
  //                       fillColor: theme.colorScheme.primary.withAlpha(30),
  //                       contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //                       filled: true,
  //                       isDense: true,
  //                       hint: Row(
  //                         spacing: 8,
  //                         children: [
  //                           Icon(Icons.search, color: hintColor),
  //                           Text(
  //                             "Search for categories...",
  //                             style: theme.textTheme.bodyMedium!.copyWith(color: hintColor),
  //                           ),
  //                         ],
  //                       ),
  //                       hintStyle: Theme.of(context).textTheme.bodyMedium,
  //                     ),
  //                     onChanged: (value) {
  //                       setState(() {});
  //                     },
  //                   ),
  //                 ),
  //                 Expanded(
  //                   child: SingleChildScrollView(
  //                     child: Column(mainAxisSize: MainAxisSize.min, children: [
  //                       ...displayCategories.map((category) {
  //                         final bool isCategorySelected = selectedCategories.contains(category.name);
  //                         return ListTile(
  //                           contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
  //                           // visualDensity: VisualDensity(vertical: -1, horizontal: 2),
  //                           title: Text(category.name ?? ""),
  //                           leading: Padding(
  //                             padding: const EdgeInsets.only(left: 12.0),
  //                             child: Container(
  //                                 decoration: BoxDecoration(
  //                                     shape: BoxShape.circle,
  //                                     color: category.colorScheme(selectedThemeMode).primaryContainer),
  //                                 child: Padding(
  //                                   padding: const EdgeInsets.all(8.0),
  //                                   child: Image.asset(
  //                                     category.imagePath ?? "",
  //                                     width: 28,
  //                                     height: 28,
  //                                     color: category.colorScheme(selectedThemeMode).onPrimaryContainer,
  //                                   ),
  //                                 )),
  //                           ),
  //                           trailing: Checkbox(
  //                               value: isCategorySelected,
  //                               onChanged: (newValue) {
  //                                 if (!selectedCategories.remove(category.name)) {
  //                                   debugPrint('adding new item');
  //                                   selectedCategories.add(category.name ?? "");
  //                                 }
  //                                 setState(() => {});
  //                               }),
  //                           onTap: () {
  //                             if (!selectedCategories.remove(category.name)) {
  //                               debugPrint('adding new item');
  //                               selectedCategories.add(category.name ?? "");
  //                             }
  //                             setState(() => {});
  //                           },
  //                         );
  //                       }),
  //                     ]),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           actions: [
  //             TextButton(
  //                 onPressed: () {
  //                   if (selectedCategories.length == fullCategories.length) {
  //                     selectedCategories.clear();
  //                   } else {
  //                     selectedCategories = Set.from(fullCategories.map((category) => category.name));
  //                   }
  //                   setState(() {});
  //                 },
  //                 child: Text(selectedCategories.length == fullCategories.length ? "Unselect all" : "Select all")),
  //             TextButton(
  //                 onPressed: () {
  //                   context.read<AppModel>().updateFilteredCategories(selectedCategories);
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: const Text("Save"))
  //           ],
  //         );
  //       });
  //     },
  //   );
  // }

  // Future<void> showFilterAmountDialog() {
  //   return showDialog(
  //       context: context,
  //       builder: (context) {
  //         final percentiles = context.read<AppModel>().getPercentiles();
  //         final max = percentiles.last;
  //         final percentileString = percentiles
  //             .map((percentile) => context.read<AppModel>().customCurrencyFormat(percentile, false))
  //             .toList();
  //         final Map<String, String> percentileMap = {
  //           "<25%": "<${percentileString[1]}",
  //           "25% - 50%": "${percentileString[1]} - ${percentileString[2]}",
  //           "50% - 75%": "${percentileString[2]} - ${percentileString[3]}",
  //           ">75%": ">${percentileString[3]}",
  //         };
  //         RangeValues _rangeValue = RangeValues(0, max);
  //         Set<String> _selectedPercentileRange = {};
  //         return StatefulBuilder(builder: (context, setState) {
  //           return AlertDialog(
  //             title: Text("Filter Amount"),
  //             contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
  //             content: Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //               child: SizedBox(
  //                 height: MediaQuery.of(context).size.height * 0.4,
  //                 width: MediaQuery.of(context).size.width * 0.7,
  //                 child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     // mainAxisAlignment: MainAxisAlignment.start,
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         "Filter by range",
  //                         textAlign: TextAlign.left,
  //                       ),
  //                       Theme(
  //                         data: Theme.of(context).copyWith(
  //                             sliderTheme: SliderThemeData(
  //                                 valueIndicatorTextStyle: Theme.of(context).textTheme.bodySmall,
  //                                 valueIndicatorColor: Theme.of(context).colorScheme.primary.withAlpha(50))),
  //                         child: RangeSlider(
  //                           values: _rangeValue,
  //                           onChanged: (newValue) {
  //                             setState(() => _rangeValue = newValue);
  //                           },
  //                           divisions: max.round(),
  //                           labels:
  //                               RangeLabels(_rangeValue.start.round().toString(), _rangeValue.end.round().toString()),
  //                           min: 0,
  //                           max: max,
  //                         ),
  //                       ),
  //                       const Divider(),
  //                       Text(
  //                         "Filter by quartile",
  //                         textAlign: TextAlign.left,
  //                       ),
  //                       ...percentileMap
  //                           .map((key, value) => MapEntry(
  //                               key,
  //                               ListTile(
  //                                 title: Row(
  //                                   mainAxisSize: MainAxisSize.max,
  //                                   children: [
  //                                     Expanded(child: Text(key)),
  //                                     Text("(${value})"),
  //                                   ],
  //                                 ),
  //                                 trailing: Checkbox(
  //                                     value: _selectedPercentileRange.contains(key),
  //                                     onChanged: (newValue) {
  //                                       newValue == true
  //                                           ? _selectedPercentileRange.add(key)
  //                                           : _selectedPercentileRange.remove(key);
  //                                       setState(() => {});
  //                                     }),
  //                               )))
  //                           .values
  //                     ]),
  //               ),
  //             ),
  //             actions: [TextButton(onPressed: () {}, child: Text("Save"))],
  //           );
  //         });
  //       });
  // }

  // Future<void> showFilterDateDialog() {
  //   return showDialog(
  //       context: context,
  //       builder: (context) {
  //         DateTimeRange? _selectedDateRange = context.select((AppModel state) => state.filterDateRange);
  //         DateRangeFilterType dateFilter = context.select((AppModel state) => state.dateRangeFilter);
  //         final now = DateTime.now();
  //         final today = DateTime(now.year, now.month, now.day);
  //         final Map<String, DateTimeRange> dateRanges = {
  //           "Today": DateTimeRange(start: today, end: today),
  //           "Yesterday": DateTimeRange(
  //               start: today.subtract(const Duration(days: 1)), end: today.subtract(const Duration(days: 1))),
  //           "Last 3 Days": DateTimeRange(start: today.subtract(const Duration(days: 2)), end: today),
  //           "Last 5 Days": DateTimeRange(start: today.subtract(const Duration(days: 4)), end: today),
  //           "Last 7 Days": DateTimeRange(start: today.subtract(const Duration(days: 6)), end: today),
  //           "This week": DateTimeRange(start: today.subtract(Duration(days: today.weekday - 1)), end: today),
  //           "Last week": DateTimeRange(
  //               start: today.subtract(Duration(days: today.weekday - 1 + 7)),
  //               end: today.subtract(Duration(days: today.weekday % 7))),
  //           "Last 2 weeks": DateTimeRange(start: today.subtract(Duration(days: today.weekday - 1 + 7)), end: today),
  //           "Last 3 weeks": DateTimeRange(start: today.subtract(Duration(days: today.weekday - 1 + 14)), end: today)
  //         };
  //         String subtitleText = "";
  //         bool showReset = dateFilter != DateRangeFilterType.none ? true : false;
  //         return StatefulBuilder(builder: (context, setState) {
  //           if (_selectedDateRange != null) {
  //             if (_selectedDateRange!.start == _selectedDateRange!.end) {
  //               subtitleText = "Selected range: ${_selectedDateRange!.start.displayFormat()}";
  //             } else {
  //               subtitleText =
  //                   "Selected range: ${_selectedDateRange!.start.displayFormat()} - ${_selectedDateRange!.end.displayFormat()}";
  //             }
  //           } else {
  //             subtitleText = "No range selected";
  //           }
  //           return AlertDialog(
  //             title: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text("Filter Date"),
  //                 Text(
  //                   subtitleText,
  //                   overflow: TextOverflow.fade,
  //                   maxLines: 1,
  //                   style: Theme.of(context).textTheme.bodyMedium,
  //                 ),
  //               ],
  //             ),
  //             contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
  //             content: Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //               child: SizedBox(
  //                 width: MediaQuery.of(context).size.width * 0.6,
  //                 child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     crossAxisAlignment: CrossAxisAlignment.stretch,
  //                     spacing: 12,
  //                     children: [
  //                       Row(
  //                         spacing: 16,
  //                         mainAxisSize: MainAxisSize.max,
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         children: [
  //                           SizedBox(
  //                               height: 40,
  //                               child: FittedBox(
  //                                   fit: BoxFit.fill,
  //                                   child: Switch(
  //                                       value: dateFilter == DateRangeFilterType.relative,
  //                                       onChanged: (value) {
  //                                         dateFilter = value ? DateRangeFilterType.relative : DateRangeFilterType.none;
  //                                         _selectedDateRange = null;
  //                                         setState(() {});
  //                                       }))),
  //                           Expanded(
  //                               child: Text(
  //                             "Relative range",
  //                             textAlign: TextAlign.left,
  //                             style: Theme.of(context).textTheme.bodyMedium,
  //                           )),
  //                         ],
  //                       ),
  //                       DropdownMenu(
  //                         width: MediaQuery.of(context).size.width * 0.5,
  //                         menuHeight: 300,
  //                         initialSelection: dateRanges.values.first,
  //                         inputDecorationTheme: InputDecorationTheme(
  //                           border: const UnderlineInputBorder(),
  //                           isDense: true,
  //                           contentPadding: const EdgeInsets.symmetric(horizontal: 12),
  //                           constraints: BoxConstraints.tight(const Size.fromHeight(40)),
  //                         ),
  //                         textStyle: Theme.of(context).textTheme.bodyMedium,
  //                         dropdownMenuEntries: dateRanges
  //                             .map(
  //                               (key, value) => MapEntry(
  //                                   key,
  //                                   DropdownMenuEntry(
  //                                     value: value,
  //                                     label: key,
  //                                     enabled: dateFilter == DateRangeFilterType.relative,
  //                                   )),
  //                             )
  //                             .values
  //                             .toList(),
  //                         onSelected: (value) {
  //                           if (dateFilter != DateRangeFilterType.relative) return;
  //                           _selectedDateRange = value as DateTimeRange;
  //                           setState(() {});
  //                         },
  //                         selectedTrailingIcon: Icon(Icons.check),
  //                       ),
  //                       const Divider(),
  //                       Row(
  //                         spacing: 16,
  //                         mainAxisSize: MainAxisSize.min,
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         children: [
  //                           SizedBox(
  //                               height: 40,
  //                               child: FittedBox(
  //                                   fit: BoxFit.fill,
  //                                   child: Switch(
  //                                       value: dateFilter == DateRangeFilterType.absolute,
  //                                       onChanged: (value) async {
  //                                         dateFilter = value ? DateRangeFilterType.absolute : DateRangeFilterType.none;
  //                                         _selectedDateRange = null;
  //                                         if (value) {
  //                                           final dateRange = await showCalendarDatePicker2Dialog(
  //                                             context: context,
  //                                             config: CalendarDatePicker2WithActionButtonsConfig(
  //                                                 calendarType: CalendarDatePicker2Type.range),
  //                                             dialogSize: Size(MediaQuery.of(context).size.width * 0.6,
  //                                                 MediaQuery.of(context).size.height * 0.6),
  //                                             value: [
  //                                               DateTime(now.year, now.month, 1),
  //                                               DateTime(now.year, now.month + 1, 0)
  //                                             ],
  //                                           );
  //                                           if (dateRange != null) {
  //                                             _selectedDateRange =
  //                                                 DateTimeRange(start: dateRange.first!, end: dateRange.last!);
  //                                           } else {
  //                                             dateFilter = DateRangeFilterType.none;
  //                                           }
  //                                         }
  //                                         setState(() {});
  //                                       }))),
  //                           Expanded(
  //                               child: Text(
  //                             "Custom range",
  //                             textAlign: TextAlign.left,
  //                             style: Theme.of(context).textTheme.bodyMedium,
  //                           )),
  //                         ],
  //                       ),
  //                       dateFilter == DateRangeFilterType.absolute && _selectedDateRange != null
  //                           ? GestureDetector(child: Text('${subtitleText.split(":").last} (Change date)'))
  //                           : SizedBox.shrink()
  //                     ]),
  //               ),
  //             ),
  //             actions: [
  //               showReset
  //                   ? TextButton(
  //                       onPressed: () {
  //                         context.read<AppModel>().updateFilteredDateRange(null, DateRangeFilterType.none);
  //                         Navigator.of(context).pop();
  //                       },
  //                       child: Text(
  //                         "Reset to default",
  //                         style: TextStyle(color: Colors.lightBlue),
  //                       ))
  //                   : SizedBox.shrink(),
  //               TextButton(
  //                   onPressed: () {
  //                     context.read<AppModel>().updateFilteredDateRange(_selectedDateRange, dateFilter);
  //                     Navigator.of(context).pop();
  //                   },
  //                   child: Text("Save"))
  //             ],
  //           );
  //         });
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ListModel(costItemRepo: context.read()),
      child: const CostListBody(),
    );
  }
}

class CostListBody extends StatelessWidget {
  const CostListBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isSearchOpened = context.select((ListModel state) => state.isSearchOpened);
    final isBlurred = context.select((ListModel state) => state.isBlurred);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar:
          context.listMod.isSearchOpened
              ? null
              : AppBar(
                title: Text("OVERVIEW", style: context.customTt.dateLabel),
                actions: [
                  IconButton(onPressed: context.listMod.toggleSearch, icon: Icon(Icons.search)),
                  IconButton(
                    onPressed: context.listMod.toggleBlur,
                    icon: Icon(!isBlurred ? Icons.visibility : Icons.visibility_off),
                  ),
                  IconButton(onPressed: context.listMod.getCurMonthData, icon: Icon(Icons.refresh)),
                ],
              ),
      body: SafeArea(
        child: Flex(
          direction: Axis.vertical,
          children: [
            ...isSearchOpened ? [const SearchTab()] : [],
            const DateBreadcrumb(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  const SummaryTab(),
                  const CostEntryList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
          context.listMod.changeYearMonth(DateTime(curMonth.year, curMonth.month + 1));
        } else if (details.primaryVelocity! < -500) {
          // swipe left
          context.listMod.changeYearMonth(DateTime(curMonth.year, curMonth.month - 1));
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

class CostEntryList extends StatefulWidget {
  const CostEntryList({super.key});

  @override
  State<CostEntryList> createState() => _CostEntryListState();
}

class _CostEntryListState extends State<CostEntryList> {
  @override
  Widget build(BuildContext context) {
    final ready = context.select((ListModel state) => state.ready);
    debugPrint('ready: $ready');

    final groupedCostItems = context.select((ListModel state) => state.outputCostItems);
    final dailySummary = context.select((ListModel state) => state.outputDailySummary);

    if (!ready) {
      return SliverToBoxAdapter(
        child: CircularProgressIndicator(),
      );
    }
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
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
        sliver: SliverList.builder(
          itemCount: groupedCostItems.length,
          itemBuilder: (context, index) {
            final spacing = context.read<ThemeModel>().spacingValue;
            final DateTime date = groupedCostItems.keys.elementAt(index);
            final List<CostItem> costItems = groupedCostItems.values.elementAt(index);

            final String dateString = date.formatPretty();
            final double daySummary = dailySummary[date]!.balance;

            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Container(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: context.cs.surfaceContainer.withAlpha(0),
                ),
                child: Column(
                  children: [
                    Row(
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
                    SizedBox(
                      height: 10,
                    ),
                    ...costItems.map((costItem) {
                      final cat = CustomUtils().findInList(costItem.category);

                      return GestureDetector(
                        onTap:
                            () => context.read<NavigationModel>().openForm(
                              FormArgument(selectedCostItem: costItem),
                            ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            spacing: 12,
                            children: [
                              CategoryIconContainer(
                                category: cat ?? CostItemCategory(name: "Placeholder"),
                                size: 20,
                              ),
                              Expanded(
                                child: Text(
                                  "${costItem.name} ${costItem.lastModified}",
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
              ),
            );
          },
        ),
      );
    }
  }
}

class SummaryTab extends StatelessWidget {
  const SummaryTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final monthMetrics = context.select((ListModel state) => state.monthSummary);
    final expense = monthMetrics.expense ?? 0;
    final income = monthMetrics.income ?? 0;
    final balance = monthMetrics.balance;

    return SliverPersistentHeader(
      delegate: SummaryHeaderDelegate(expense: expense, income: income, balance: balance),
      pinned: true,
    );
  }
}

class SummaryHeaderDelegate extends SliverPersistentHeaderDelegate {
  const SummaryHeaderDelegate({
    required this.expense,
    required this.income,
    required this.balance,
  });

  final double expense, income, balance;

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
                      height: 1,
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
                  spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    expenseMetricCard(
                      context,
                      labelText: "Balance",
                      progress: progress,
                      value: NumberFormat.compactCurrency(symbol: "RM").format(balance),
                      isBig: true,
                    ),
                    Row(
                      spacing: 20,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: expenseMetricCard(
                            context,
                            labelText: "Expense",
                            progress: progress,
                            value: NumberFormat.compactCurrency(symbol: "RM").format(expense),
                            isBig: false,
                          ),
                        ),
                        Expanded(
                          child: expenseMetricCard(
                            context,
                            labelText: "Income",
                            progress: progress,
                            value: NumberFormat.compactCurrency(symbol: "RM").format(income),
                            isBig: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Expanded(child: SizedBox()),
              Container(
                width: 135,
                // height: 250,
                alignment: Alignment.centerRight,
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
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
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
  double get maxExtent => 190;

  @override
  double get minExtent => 115;

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
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Balance',
                style: context.customTt.numberLabel!.copyWith(
                  color: context.cs.onPrimary,
                  height: 0.5,
                ),
              ),
              Text(
                '20',
                style: context.customTt.numberFontLarge!.copyWith(
                  color: context.cs.onPrimary,
                  height: 1,
                ),
              ),
            ],
          ),
          PieChart(
            PieChartData(
              // sectionsSpace: 5,
              sectionsSpace: 0,
              centerSpaceRadius: 52,
              startDegreeOffset: -90,
              sections: [
                PieChartSectionData(
                  showTitle: false,
                  value: 3,
                  radius: 10,
                  color: context.customCs.onFlipCard,
                  cornerRadius: 10,
                ),
                PieChartSectionData(
                  showTitle: false,
                  value: 2,
                  radius: 10,
                  color: context.cs.surface.withAlpha(50),
                  // cornerRadius: 10,
                ),
                // PieChartSectionData(value: 1, radius: 10),
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
      style: context.tt.bodyMedium!.copyWith(fontSize: 12),
      controller: _controller,
      autofocus: true,
      decoration: InputDecoration(
        focusedBorder: InputBorder.none,
        border: InputBorder.none,
        isDense: true,
        prefixIcon: IconButton(
          iconSize: 24,
          onPressed: () {
            // context.appMod.clearFilter();
            context.listMod.toggleSearch();
          },
          icon: Icon(Icons.arrow_back),
        ),
        suffixIcon: IconButton(
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

import 'dart:ui' as ui;

import 'package:budget_tracker/extensions.dart';
import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/models/navigation_model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CostListScreen extends StatefulWidget {
  const CostListScreen({super.key});

  @override
  State<CostListScreen> createState() => _CostListScreenState();
}

class _CostListScreenState extends State<CostListScreen> {
  bool _isSearchOpened = false;
  final TextEditingController _controller = TextEditingController();

  Future<void> showFilterCategoryDialog() {
    return showDialog(context: context, builder:(context) {
      final fullCategories = context.read<AppModel>().categories;
      Set<String> selectedCategories = context.read<AppModel>().filteredCategories;
      final selectedThemeMode = context.select((ThemeModel state) => state.theme);
      Set<CostItemCategory> displayCategories = {};
      final TextEditingController controller = TextEditingController();
      return StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          final hintColor = theme.colorScheme.primary.withAlpha(100);
          displayCategories = Set.from(
            controller.text == ""? 
            fullCategories: 
            fullCategories.where((category) => category.name.contains(controller.text))
          );
          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Filter Category"),
                Text(
                  "${selectedCategories.length} selected ${selectedCategories.length <= 1? "category": "categories"}", 
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
            content: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.7,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 16),
                    child: TextField(
                      controller: controller,
                      style: theme.textTheme.bodyMedium!,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius:  BorderRadius.circular(200), borderSide: BorderSide.none),
                        fillColor: theme.colorScheme.primary.withAlpha(30),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        filled: true,
                        isDense: true,
                        hint: Row(
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.search,
                              color: hintColor
                            ),
                            Text(
                              "Search for categories...", 
                              style: theme.textTheme.bodyMedium!.copyWith(color: hintColor),
                            ),
                          ],
                        ),
                        hintStyle: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onChanged: (value) {
                        setState((){});
                      },
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...displayCategories.map((category) {
                            final bool isCategorySelected = selectedCategories.contains(category.name);
                            return ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                              // visualDensity: VisualDensity(vertical: -1, horizontal: 2),
                              title: Text(category.name),
                              leading: Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: category.colorScheme(selectedThemeMode).primaryContainer
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      category.imagePath, 
                                      width: 28, 
                                      height: 28,
                                      color: category.colorScheme(selectedThemeMode).onPrimaryContainer,
                                    ),
                                  )
                                ),
                              ),
                              trailing: Checkbox(
                                value: isCategorySelected, 
                                onChanged: (newValue) {
                                  if (!selectedCategories.remove(category.name)) {
                                    debugPrint('adding new item');
                                    selectedCategories.add(category.name);
                                  }
                                  setState(() => {});
                                }
                              ),
                              onTap: (){
                                if (!selectedCategories.remove(category.name)) {
                                  debugPrint('adding new item');
                                  selectedCategories.add(category.name);
                                }
                                setState(()=>{});
                              },
                            );
                          }),
                        ]
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: (){
                  if (selectedCategories.length == fullCategories.length) {
                    selectedCategories.clear();
                  } else {
                    selectedCategories = Set.from(fullCategories.map((category) => category.name));
                  } 
                  setState((){});
                }, 
                child: Text(selectedCategories.length == fullCategories.length? "Unselect all" : "Select all")),
              TextButton(
                onPressed: () {
                  context.read<AppModel>().updateFilteredCategories(selectedCategories);
                  Navigator.of(context).pop();
                }, 
                child: const Text("Save")
              )
            ],
          );
        }
      );
    },);
  }

  Future<void> showFilterAmountDialog() {
    return showDialog(context: context, builder:(context) {
      final percentiles = context.read<AppModel>().getPercentiles();
      final max = percentiles.last;
      final percentileString = percentiles.map((percentile) => context.read<AppModel>().customCurrencyFormat(percentile, false)).toList();
      final Map<String,String> percentileMap = {
        "<25%": "<${percentileString[1]}",
        "25% - 50%": "${percentileString[1]} - ${percentileString[2]}",
        "50% - 75%": "${percentileString[2]} - ${percentileString[3]}",
        ">75%": ">${percentileString[3]}",
      };
      RangeValues _rangeValue = RangeValues(0, max);
      Set<String> _selectedPercentileRange = {};
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Filter Amount"),
            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
            content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Filter by range", textAlign: TextAlign.left,),
                    Theme(
                      data: Theme.of(context).copyWith(
                        sliderTheme: SliderThemeData(
                          valueIndicatorTextStyle: Theme.of(context).textTheme.bodySmall, 
                          valueIndicatorColor: Theme.of(context).colorScheme.primary.withAlpha(50)
                        )
                      ),
                      child: RangeSlider(
                        values: _rangeValue,   
                        onChanged: (newValue) {
                          setState(() =>  _rangeValue = newValue);
                        },
                        divisions: max.round(),
                        labels: RangeLabels(_rangeValue.start.round().toString(), _rangeValue.end.round().toString()),
                        min: 0,
                        max: max,
                      ),
                    ),
                    const Divider(),
                    
                    Text("Filter by quartile", textAlign: TextAlign.left,),
                    ...percentileMap.map((key, value) => MapEntry(
                      key,
                      ListTile(
                        title: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(child: Text(key)),
                            Text("(${value})"),
                          ],
                        ),
                        trailing: Checkbox(
                          value: _selectedPercentileRange.contains(key), 
                          onChanged: (newValue) {
                            newValue == true? _selectedPercentileRange.add(key):_selectedPercentileRange.remove(key);
                            setState(()=>{});
                          }
                        ),
                      )
                    )).values
                  ]
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: (){}, child: Text("Save"))
            ],
          );
        }
      );
    });
  }

  Future<void> showFilterDateDialog() {
    return showDialog(context: context, builder:(context) {
      DateTimeRange? _selectedDateRange = context.select((AppModel state) => state.filterDateRange);
      DateRangeFilterType dateFilter = context.select((AppModel state) => state.dateRangeFilter);
      final now = DateTime.now();
      final today = DateTime(now.year,now.month,now.day);
      final Map<String, DateTimeRange> dateRanges = {
        "Today": DateTimeRange(
          start: today, 
          end: today
        ),
        "Yesterday": DateTimeRange(
          start: today.subtract(const Duration(days: 1)), 
          end: today.subtract(const Duration(days: 1))
        ),
        "Last 3 Days": DateTimeRange(
          start: today.subtract(const Duration(days: 2)), 
          end: today
        ),
        "Last 5 Days": DateTimeRange(
          start: today.subtract(const Duration(days: 4)), 
          end: today
        ),
        "Last 7 Days": DateTimeRange(
          start: today.subtract(const Duration(days: 6)), 
          end: today
        ),
        "This week": DateTimeRange(
          start: today.subtract(Duration(days: today.weekday - 1)), 
          end: today
        ),
        "Last week": DateTimeRange(
          start: today.subtract(Duration(days: today.weekday - 1 + 7)), 
          end: today.subtract(Duration(days: today.weekday % 7))
        ),
        "Last 2 weeks": DateTimeRange(
          start: today.subtract(Duration(days: today.weekday - 1 + 7)), 
          end: today
        ),
        "Last 3 weeks": DateTimeRange(
          start: today.subtract(Duration(days: today.weekday - 1 + 14)), 
          end: today
        )
      };
      String subtitleText = "";
      bool showReset = dateFilter != DateRangeFilterType.none? true: false;
      return StatefulBuilder(
        builder: (context, setState) {
          if (_selectedDateRange != null) {
            if (_selectedDateRange!.start == _selectedDateRange!.end) {
              subtitleText = "Selected range: ${_selectedDateRange!.start.displayFormat()}";
            } else {
              subtitleText = "Selected range: ${_selectedDateRange!.start.displayFormat()} - ${_selectedDateRange!.end.displayFormat()}"; 
            }
          } else {
            subtitleText = "No range selected";
          }
          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Filter Date"),
                Text(
                  subtitleText,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
            content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    Row(
                      spacing: 16,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 40,
                          child: FittedBox(fit: BoxFit.fill, child: Switch(value: dateFilter ==  DateRangeFilterType.relative, onChanged: (value) {
                            dateFilter = value? DateRangeFilterType.relative: DateRangeFilterType.none;
                            _selectedDateRange = null;
                            setState((){});
                          }))
                        ),
                        Expanded(
                          child: Text(
                            "Relative range", 
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        ),
                      ],
                    ),
                    DropdownMenu(
                      width: MediaQuery.of(context).size.width * 0.5,
                      menuHeight: 300,
                      initialSelection: dateRanges.values.first,
                      inputDecorationTheme: InputDecorationTheme(
                        border: const UnderlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        constraints: BoxConstraints.tight(const 
                          Size.fromHeight(40)
                        ),
                      ),
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                      dropdownMenuEntries: dateRanges.map((key, value) => MapEntry(key, 
                        DropdownMenuEntry(
                          value: value, 
                          label: key,
                          enabled: dateFilter == DateRangeFilterType.relative,
                        )
                      ),).values.toList(),
                      onSelected: (value) {
                        if (dateFilter != DateRangeFilterType.relative) return;
                        _selectedDateRange = value as DateTimeRange;
                        setState((){});
                      },
                      selectedTrailingIcon: Icon(Icons.check),
                    ),
                    const Divider(),
                    Row(
                      spacing: 16,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 40,
                          child: FittedBox(fit: BoxFit.fill, child: Switch(value: dateFilter == DateRangeFilterType.absolute, onChanged: (value) async {
                            dateFilter = value ? DateRangeFilterType.absolute: DateRangeFilterType.none;
                            _selectedDateRange = null;
                            if (value) {
                              final dateRange = await showCalendarDatePicker2Dialog(
                                context: context, 
                                config: CalendarDatePicker2WithActionButtonsConfig(
                                  calendarType: CalendarDatePicker2Type.range
                                ),
                                dialogSize: Size(MediaQuery.of(context).size.width * 0.6, MediaQuery.of(context).size.height * 0.6),
                                value: [DateTime(now.year,now.month,1), DateTime(now.year,now.month + 1, 0)],
                              );
                              if (dateRange!= null) {
                                _selectedDateRange = DateTimeRange(start: dateRange.first!, end: dateRange.last!);
                              } else {
                                dateFilter = DateRangeFilterType.none;
                              }
                            }
                            setState((){});
                          }))
                        ),
                        Expanded(
                          child: Text(
                            "Custom range", 
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        ),
                      ],
                    ),
                    dateFilter == DateRangeFilterType.absolute && _selectedDateRange != null? 
                      GestureDetector(
                        child: Text('${subtitleText.split(":").last} (Change date)')
                      )
                      : SizedBox.shrink()
                  ]
                ),
              ),
            ),
            actions: [
              showReset? TextButton(
                onPressed: (){
                  context.read<AppModel>().updateFilteredDateRange(null, DateRangeFilterType.none);
                  Navigator.of(context).pop();
                }, 
                child: Text(
                  "Reset to default",
                  style: TextStyle(color: Colors.lightBlue),
                )
              ) : SizedBox.shrink(),
              TextButton(
                onPressed: (){
                  context.read<AppModel>().updateFilteredDateRange(_selectedDateRange, dateFilter);
                  Navigator.of(context).pop();
                }, 
                child: Text("Save")
              )
            ],
          );
        }
      );
    });
  }

  Widget titleAppBar() {
    if (!_isSearchOpened) {
      return Text("Overview");
    } else {
      var theme = Theme.of(context);
      var hintColor = theme.colorScheme.primary.withAlpha(100);
      return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          debugPrint("this triggered");
          setState(() => _isSearchOpened = false);
        },
        child: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(borderRadius:  BorderRadius.circular(200), borderSide: BorderSide(width: 0, color: theme.colorScheme.primary)),
            border: OutlineInputBorder(borderRadius:  BorderRadius.circular(200), borderSide: BorderSide(width: 0, color: theme.colorScheme.primary)),
            fillColor: theme.colorScheme.primary.withAlpha(10),
            filled: true,
            isDense: true,
            // contentPadding: EdgeInsets.symmetric(vertical: 15),
            prefixIcon: IconButton(
              iconSize: 24,
              onPressed: () {
                setState(() => _isSearchOpened = false);
                context.read<AppModel>().clearFilter();
              },
              icon: Icon(Icons.arrow_back)
            ),
            suffixIcon: IconButton(
              iconSize: 24,
              onPressed: () {
                _controller.clear();
                context.read<AppModel>().updateFilterString("");
                setState(() {
                  
                });
              },
              icon: Icon(Icons.clear)
            ),
            hint: Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.search,
                  color: hintColor
                ),
                Text(
                  "Search for a cost item...", 
                  style: theme.textTheme.bodyMedium!.copyWith(color: hintColor),
                ),
              ],
            ),
            hintStyle: Theme.of(context).textTheme.bodyMedium,
          ),
          onChanged: (value) {
            debugPrint("controller value updated");
            context.read<AppModel>().updateFilterString(value);
          },
        ),
      );
    }
  }

  AppBar bottomFilterAppBar() {
    final isCategoryFiltered = context.select((AppModel state) => state.filteredCategories.length < state.categories.length);
    final isDateFiltered = context.select((AppModel state) => state.filterDateRange != null);
    final toolbarHeight = MediaQuery.of(context).size.height * 0.05;
    final contextTheme = Theme.of(context);
    final borderRadius = BorderRadius.circular(20);

    Widget createCustomFilterChip({IconData? icon, String text = "", Function()? onTap, bool isActive = false}) {
      return Expanded(
        child: Material(
          borderRadius: borderRadius,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            child: Container(
              height: toolbarHeight - 16,
              // padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: BoxBorder.all(color: contextTheme.colorScheme.primary, width: 0.5),
                borderRadius: borderRadius,
                color: isActive? contextTheme.colorScheme.primary.withAlpha(50) : contextTheme.colorScheme.primary.withAlpha(10)
              ),
              child: Row(
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isActive? Icons.check : icon, color: contextTheme.colorScheme.primary, size: toolbarHeight/2 - 10,),
                  Text(text, style: contextTheme.textTheme.labelSmall)
                ],
              ),
            ),
          ),
        ),
      );
    }

    return AppBar(
      toolbarHeight: toolbarHeight,
      title: Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          createCustomFilterChip(
            icon: Icons.category,
            text: "Category",
            onTap: () async => showFilterCategoryDialog(),
            isActive: isCategoryFiltered
          ),
          createCustomFilterChip(
            icon: Icons.date_range,
            text: "Date",
            onTap: () async => showFilterDateDialog(),
            isActive: isDateFiltered
          ),
          createCustomFilterChip(
            icon: Icons.money,
            text: "Amount",
            onTap: () async => showFilterAmountDialog(),
            isActive: isDateFiltered
          ),
        ],
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    // debugPrint("list screen is build");
    final isBlur = context.select((ThemeModel state) => state.isListBlurred);
    return Scaffold(
      body: SafeArea(
        child: Flex(
          direction: Axis.vertical,
          children: [
            const DateBreadcrumb(),
            const SummaryTab(),
            Expanded(child: const CostEntryList()),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // title: Text(AppLocalizations.of(context)!.title),
        title: titleAppBar(),
        bottom: _isSearchOpened? bottomFilterAppBar() : null,
        actions: !_isSearchOpened? [
          IconButton(
            onPressed: () => setState(() => _isSearchOpened = !_isSearchOpened), 
            icon: Icon(Icons.search)
          ),
          IconButton(
            onPressed: () => context.read<ThemeModel>().toggleBlur(),
            icon: Icon(!isBlur?  Icons.visibility : Icons.visibility_off)
          ),
          IconButton(
            onPressed: () => context.read<AppModel>().resetMetric(),
            icon: Icon(Icons.refresh)
          )
        ] : [],
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

class DateBreadcrumb extends StatelessWidget {
  const DateBreadcrumb({super.key});

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
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: IconButton(
                style: ElevatedButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                ),
                onPressed: () {
                  context.read<AppModel>().changeYearMonth(false);
                }, 
                icon: Icon(Icons.arrow_back_ios)
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  DateFormat("yMMMM").format(context.select((AppModel state) => state.selectedYearMonth)),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20),
                ),
              )
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: IconButton(
                style: ElevatedButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                ),
                onPressed: () {
                  context.read<AppModel>().changeYearMonth(true);
                }, 
                icon: Icon(Icons.arrow_forward_ios)
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
    // final groupedCostItems = context.select((AppModel model) => model.currentMonthDailyCostItems);
    final groupedCostItems = context.watch<AppModel>().currentMonthDailyCostItems;
    final appModelFunction = context.read<AppModel>();
    final selectedThemeMode = context.select((ThemeModel state) => state.theme);
    if (groupedCostItems.isEmpty) {
      return Center(
        child: const Text("Empty list"),
      );
    } else {
      return Scrollbar(
        thickness: 4,
        thumbVisibility: true,
        radius: Radius.circular(200),
        child: NotificationListener<OverscrollIndicatorNotification>(
          child: ListView.builder(
            itemCount: groupedCostItems.length,
            itemBuilder:(context, index) {
              final String dateString = groupedCostItems.keys.elementAt(index);
              final List<CostItem> costItems = groupedCostItems.values.elementAt(index);
              final String formattedDateString = DateFormat('d MMM (E)').format(dateString.standardDateParse());
              final String dailyBudget = appModelFunction.customCurrencyFormat(context.watch<AppModel>().getDailyTotal(dateString), false, true);

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
                    formattedDateString, 
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary
                    ),
                  ),
                  trailing: HideableText(
                    dailyBudget, 
                    isCurrency: true,
                    textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 16,
                      color: dailyBudget[0] == "-" ? Colors.redAccent : Colors.greenAccent
                    ),
                  ),
                    // isBlur? "***": dailyBudget, 
                    // style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    //   fontSize: 16,
                    //   color: dailyBudget[0] == "-" ? Colors.redAccent : Colors.greenAccent
                    // ),
                  // ),
                  children: costItems.map((costItem) {
                    final CostItemCategory category = appModelFunction.getCategoryEntry(costItem.category)!;
                    final ColorScheme categoryColorScheme = category.colorScheme(selectedThemeMode);
                    final spacing = context.read<ThemeModel>().spacingValue; 
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              dense: true,
                              tileColor: Colors.transparent,
                              visualDensity: VisualDensity(vertical: spacing - 5), 
                              contentPadding: EdgeInsets.only(left: 10, right: 16, top: spacing - 1, bottom: spacing - 1),
                              shape: RoundedRectangleBorder(side: BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(8)),
                              title: Text(
                                costItem.name, 
                                maxLines: 3,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                              leading: category.generateRoundedIcon(30, selectedThemeMode, categoryColorScheme.primaryContainer, categoryColorScheme.onPrimaryContainer),
                              trailing: HideableText(
                                appModelFunction.getFormattedCostItemValue(costItem),
                                isCurrency: true,
                                textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  fontSize: 14
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

class SummaryTab extends StatelessWidget {
  const SummaryTab({
    super.key,
  });

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
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20,10,10,10),
                  child: costCard(
                    context,
                    "Balance", 
                    totalCost['balance']!,
                    isBig: true
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20,0,0,10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      costCard(
                        context,
                        "Income", 
                        totalCost['income']!,
                      ),
                      const SizedBox(width: 30,),
                      costCard(
                        context,
                        "Expense", 
                        totalCost['expense']!,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                height: 120,
                width: 100,
                child: SummaryChart(summaryData: totalCost,),
              ),
            )
            
          ],
        ),
      ),
    );
    // return Padding(
    //   padding: const EdgeInsets.all(12.0),
    //   child: Container( // main box
    //     padding: const EdgeInsets.all(16),
    //     decoration: BoxDecoration(
    //       color: Theme.of(context).colorScheme.secondaryContainer,
    //       borderRadius: BorderRadius.circular(12)
    //     ),
    //     height: screenSize.height * 0.2, // 12 as spacing between the rightmost container
    //     // width: screenSize.width,
    //     child: Row(
    //       mainAxisSize: MainAxisSize.min,
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       spacing: 8,
    //       children: [
    //         SizedBox(
    //           width: screenSize.width * 0.5,
    //           child: Column( // vertical
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             mainAxisAlignment: MainAxisAlignment.start,
    //             mainAxisSize: MainAxisSize.min,
    //             spacing: 20,
    //             children: [
    //               costCard(
    //                 context,
    //                 "Balance", 
    //                 totalCost['balance']!,
    //                 isBig: true
    //               ),
    //               Row(
    //                 spacing: 10,
    //                 mainAxisSize: MainAxisSize.max,
    //                 children: [
    //                   Flexible(
    //                     child: costCard(
    //                       context,
    //                       "Expense", 
    //                       totalCost['expense']!,
    //                     )
    //                   ),
    //                   Flexible(
    //                     child: costCard(
    //                       context,
    //                       "Income", 
    //                       totalCost['income']!,
    //                     )
    //                   ),
    //                 ]
    //               )
    //             ],
    //           ),
    //         ),
    //         SizedBox(
    //           width: screenSize.width * 0.3,
    //           child: SummaryChart(summaryData: totalCost,)
    //         ),
    //       ],
    //     )
    //   ),
    // );
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
            )
          ],
        ),
        HideableText(
          value['string'], 
          isCurrency: true,
          textStyle: mainTextStyle
        ),
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
        Container(
          // decoration: BoxDecoration(border: Border.all()),
          child: Expanded(
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
              chartValue,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                fontSize: 12,
              ),
            ),
            HideableText(
              NumberFormat("#0%").format(percentage),
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

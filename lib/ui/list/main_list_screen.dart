import 'dart:math';
import 'dart:ui';

import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/languages.dart';
import 'package:budget_tracker/ui/list/main_list_viewmodel.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gif_view/gif_view.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CostListScreenWrapper extends StatelessWidget {
  const CostListScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final isSearchOpened = context.select((ListViewModel state) => state.isSearchOpened);
    return ScreenWrapper(
      canPop: !isSearchOpened,
      popAction: (didPop, result) {
        debugPrint("child screen pop fired");
        if (isSearchOpened) {
          context.navMod.toggleFab(show: true);
          context.listMod.toggleSearch(false);
        }
      },
      child: const CostListScreen(),
    );
  }
}

class CostListScreen extends StatefulWidget {
  const CostListScreen({
    super.key,
    this.initDate,
  });

  final DateTime? initDate;
  @override
  State<CostListScreen> createState() => _CostListScreenState();
}

class _CostListScreenState extends State<CostListScreen> {
  late final ScrollController _controller;
  bool expanded = true;
  int _refresh = 0;
  OverlayEntry? _overlay;

  void addOverlay() {
    _overlay = OverlayEntry(builder: (context) => LoadingOverlay());
    Overlay.of(context).insert(_overlay!);
  }

  void removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void scrollToPosition(double position) {
    if (_controller.hasClients) {
      if (context.listMod.resetScroll) {
        _controller.jumpTo(0);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.animateTo(position, duration: Durations.medium1, curve: Curves.easeOutCirc);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _refresh = context.listMod.scrollRefresh;
    _controller = ScrollController();
    _controller.addListener(() {
      setState(() {
        if (_controller.offset < 10) {
          expanded = true;
        } else {
          expanded = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final refresh = context.select((ListViewModel state) => state.scrollRefresh);
    final scrollPosition = context.select((ListViewModel state) => state.scrollPosition);
    final isSearchOpened = context.select((ListViewModel state) => state.isSearchOpened);
    final ready = context.select((ListViewModel state) => state.ready);
    if (_refresh != refresh) {
      scrollToPosition(scrollPosition);
      _refresh = refresh;
    }
    return CustomScaffold(
      resizeInset: false,
      customAppBar: const ListViewAppBar(),
      safeAreaPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      ready: ready,
      child: Flex(
        direction: Axis.vertical,
        children: [
          isSearchOpened ? const ItemFilterChips() : const DateBreadcrumb(),
          Expanded(
            child: Scrollbar(
              thickness: 2,
              radius: Radius.circular(12),
              controller: _controller,
              child: CustomScrollView(
                controller: _controller,
                slivers: [
                  SummaryTab(),
                  const CostEntryList(),
                ],
              ),
            ),
          ),
        ],
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
    final isBlurred = context.select((ListViewModel state) => state.isBlurred);
    final isSearchOpened = context.select((ListViewModel state) => state.isSearchOpened);
    final selectionMode = context.select((ListViewModel state) => state.selectionMode);
    final selectedItemLength = context.select((ListViewModel state) => state.selectedItems.length);

    if (selectionMode) {
      return AppBar(
        actionsPadding: EdgeInsets.only(right: 10),
        animateColor: true,
        // backgroundColor: context.customCs.fadeColor2,
        leading: BackButton(
          onPressed: () => context.listMod.toggleSelectionMode(false),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context.showSuccessNotification(
                message:
                    "$selectedItemLength ${selectedItemLength > 1 ? "items" : "item"} deleted.",
              );
              context.listMod.deleteSelectedItems();
            },
            icon: Icon(Icons.delete),
          ),
        ],
        title: Text(
          "Selected: $selectedItemLength",
          style: context.customTt.numberFontMedium!,
        ),
      );
    } else if (isSearchOpened) {
      return AppBar(
        scrolledUnderElevation: 0,
        actionsPadding: EdgeInsets.only(right: 10),
        // backgroundColor: context.customCs.fadeColor3,
        leading: BackButton(
          onPressed: () {
            context.listMod.toggleSearch(false);
            context.navMod.toggleFab(show: true);
          },
        ),
        title: Row(
          children: [
            Expanded(child: const SearchTabTextField()),
          ],
        ),
      );
    } else {
      return AppBar(
        scrolledUnderElevation: 0,
        actionsPadding: EdgeInsets.only(right: 8),
        title: Text(AppLocale.overview.getString(context), style: context.customTt.dateLabel),
        actions: [
          IconButton(
            onPressed: () {
              context.listMod.toggleSearch();
              context.navMod.toggleFab(show: false);
            },
            icon: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 20),
          ),
          IconButton(
            onPressed: context.listMod.toggleBlur,
            icon: FaIcon(
              !isBlurred ? FontAwesomeIcons.solidEye : FontAwesomeIcons.solidEyeSlash,
              size: 20,
            ),
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
    final currentYearMonth = context.select((ListViewModel state) => state.currentYearMonth);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        showDialog(
          context: context,
          builder:
              (_) => ChangeNotifierProvider.value(
                value: context.listMod,
                child: const MonthSelectorDialog(),
              ),
        );
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! > 500) {
          // swipe right
          context.listMod.incrementYearMonth(increase: false);
        } else if (details.primaryVelocity! < -500) {
          // swipe left
          context.listMod.incrementYearMonth(increase: true);
        }
      },
      child: Container(
        height: 44,
        decoration: BoxDecoration(color: context.cs.surface),
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.18,
              child: IconButton(
                iconSize: 24,
                style: ElevatedButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                ),
                onPressed: () {
                  context.listMod.incrementYearMonth(increase: false);
                },
                icon: Icon(Icons.arrow_back_ios),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  currentYearMonth.formatYearMonth(),
                  style: context.customTt.dateLabel!.copyWith(fontSize: 28),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.18,
              child: IconButton(
                iconSize: 24,
                style: ElevatedButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                ),
                onPressed: () {
                  context.listMod.incrementYearMonth(increase: true);
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

class ItemFilterChips extends StatelessWidget {
  const ItemFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = context.select((ListViewModel state) => state.filteredCategories);
    final curYearMonth = context.select((ListViewModel state) => state.currentYearMonth);
    final hasValue = categories != null;
    return Container(
      height: 44,
      decoration: BoxDecoration(color: context.cs.surface),
      padding: EdgeInsets.only(left: 12, right: 12),
      child: Row(
        spacing: 8,
        children: [
          Flexible(
            fit: FlexFit.tight,
            flex: 2,
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                if (details.primaryVelocity! > 500) {
                  // swipe right
                  context.listMod.incrementYearMonth(increase: false);
                } else if (details.primaryVelocity! < -500) {
                  // swipe left
                  context.listMod.incrementYearMonth(increase: true);
                }
              },
              onTap: () async {
                await showDialog(
                  context: context,
                  builder:
                      (_) => ChangeNotifierProvider.value(
                        value: context.listMod,
                        child: const MonthSelectorDialog(),
                      ),
                );
              },
              child: ReusableContainer(
                height: 42,
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 8,
                  children: [
                    FaIcon(FontAwesomeIcons.angleLeft, size: 14),
                    Row(
                      spacing: 10,
                      children: [
                        // FaIcon(FontAwesomeIcons.calendar, size: 14),
                        Text(
                          curYearMonth.formatYearMonth(),
                          style: context.customTt.numberFontSmall!.copyWith(
                            fontSize: 14,
                            // color: hasValue ? context.cs.primary : context.customCs.fadeColor1,
                          ),
                        ),
                      ],
                    ),
                    FaIcon(FontAwesomeIcons.angleRight, size: 14),
                  ],
                ),
              ),
            ),
          ),
          ReusableContainer(
            height: 42,
            padding: EdgeInsets.symmetric(
              horizontal: 12.0,
            ),
            onTap: () async {
              final response = await context.push<List<CostItemCategory>? Function()>(
                '/categories',
                extra: context.listMod.filteredCategories,
              );
              if (response != null && context.mounted) {
                context.listMod.updateCategoryFilter(response());
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 12,
              children: [
                FaIcon(FontAwesomeIcons.folder, size: 14),
                if (hasValue)
                  ReusableContainer(
                    customColor: context.cs.secondary,
                    padding: EdgeInsets.only(),
                    radius: 4,
                    height: 20,
                    width: 20,
                    filled: true,
                    highlight: true,
                    child: Center(
                      child: Text(
                        "${categories.length}",
                        style: context.customTt.numberFontSmall!.copyWith(
                          fontSize: 12,
                          color: context.cs.surface,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ReusableContainer(
            height: 42,
            padding: EdgeInsets.symmetric(
              horizontal: 12.0,
            ),
            onTap: () async {
              final response = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
                // constraints: BoxConstraints(maxHeight: 350),
                builder: (sheetContext) {
                  return ChangeNotifierProvider.value(
                    value: context.listMod,
                    child: SliderBottomSheet(),
                  );
                },
              );
              // <Map<String, dynamic>?>(
              //   context: context,
              //   builder: (dialogContext) {
              //     return RangeSliderAlertDialog(
              //       items: context.listMod.items,
              //       initRange: context.listMod.priceRange,
              //       initCostTypes: context.listMod.types,
              //     );
              //   },
              // );
              if (response != null && context.mounted) {
                context.listMod.updateRangeFilter(
                  range: response['range'],
                  types: response['types'],
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 12,
              children: [
                FaIcon(FontAwesomeIcons.moneyBill, size: 14),
                // if (hasValue)
                //   Text(
                //     " (${categories.length})",
                //     style: TextStyle(color: Colors.black, fontSize: 12),
                //   ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SliderBottomSheet extends StatefulWidget {
  const SliderBottomSheet({
    super.key,
    this.expenseRange,
    this.incomeRange,
  });

  final RangeValues? expenseRange;
  final RangeValues? incomeRange;
  @override
  State<SliderBottomSheet> createState() => _SliderBottomSheetState();
}

class _SliderBottomSheetState extends State<SliderBottomSheet> {
  RangeValues _expenseRange = RangeValues(0, 1);
  RangeValues _incomeRange = RangeValues(0, 1);
  RangeValues _defaultExpenseRange = RangeValues(0, 1);
  RangeValues _defaultIncomeRange = RangeValues(0, 1);

  @override
  void initState() {
    super.initState();
    double expenseMin = 0, expenseMax = 1, incomeMin = 0, incomeMax = 1;
    final items = context.listMod.items;
    for (final item in items) {
      final amount = item.amount ?? 0;
      if (item.isExpense) {
        expenseMin = amount < expenseMin ? amount : expenseMin;
        expenseMax = amount > expenseMax ? amount : expenseMax;
      } else {
        incomeMin = amount < incomeMin ? amount : incomeMin;
        incomeMax = amount > incomeMax ? amount : incomeMax;
      }
    }
    _defaultExpenseRange = RangeValues(expenseMin, expenseMax);
    _defaultIncomeRange = RangeValues(incomeMin, incomeMax);

    _expenseRange = widget.expenseRange ?? _defaultExpenseRange;
    _incomeRange = widget.incomeRange ?? _defaultIncomeRange;
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint("bottom sheet rebuild");
    return Theme(
      data: Theme.of(context).copyWith(
        sliderTheme: SliderThemeData(
          padding: EdgeInsets.symmetric(vertical: 14),
          trackHeight: 1,
          overlayColor: Colors.transparent,
          activeTrackColor: context.cs.secondary,
          rangeThumbShape: RoundRangeSliderThumbShape(
            enabledThumbRadius: 8,
            pressedElevation: 0,
          ),
          showValueIndicator: ShowValueIndicator.alwaysVisible,
          valueIndicatorTextStyle: context.customTt.numberFontSmall!.copyWith(
            fontSize: 12,
            color: context.cs.surface,
          ),
          valueIndicatorColor: context.cs.primary,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Expense"),
              CostSlider(
                range: _defaultExpenseRange,
                selectedRange: _expenseRange,
                onChanged: (value) {
                  setState(() {
                    _expenseRange = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Text("Income"),
              CostSlider(
                range: _defaultIncomeRange,
                selectedRange: _incomeRange,
                onChanged: (value) {
                  setState(() {
                    _incomeRange = value;
                  });
                },
              ),
              SizedBox(height: 30),
              Container(
                alignment: Alignment.centerRight,
                child: AffirmativeTextButton(
                  onTap: () {
                    context.pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CostSlider extends StatefulWidget {
  const CostSlider({super.key, required this.range, required this.selectedRange, this.onChanged});
  final RangeValues range;
  final RangeValues selectedRange;
  final ValueChanged<RangeValues>? onChanged;
  @override
  State<CostSlider> createState() => _CostSliderState();
}

class _CostSliderState extends State<CostSlider> {
  late final TextEditingController _rangeMinController;
  late final TextEditingController _rangeMaxController;
  String? _rangeError;

  bool get hasError => _rangeError != null && _rangeError != "";

  @override
  void initState() {
    super.initState();

    _rangeMinController = TextEditingController(text: widget.selectedRange.start.toStringAsFixed(0))
      ..addListener(() {
        checkError(_rangeMinController.text, isStart: true);
        if (!hasError) {
          widget.onChanged?.call(
            RangeValues(double.parse(_rangeMinController.text), widget.selectedRange.end),
          );
        }
      });
    _rangeMaxController = TextEditingController(text: widget.selectedRange.end.toStringAsFixed(0))
      ..addListener(() {
        checkError(_rangeMaxController.text, isStart: false);
        if (!hasError) {
          widget.onChanged?.call(
            RangeValues(widget.selectedRange.start, double.parse(_rangeMaxController.text)),
          );
        }
      });
  }

  void checkError(String text, {required bool isStart}) {
    setState(() {
      if (double.tryParse(text) == null) {
        _rangeError = "This value format is unsupported";
      } else {
        final value = double.parse(text);
        if (isStart) {
          if (value > widget.selectedRange.end || value < 0) {
            _rangeError = "This value is out of bound. Change the value.";
          } else {
            _rangeError = null;
          }
        } else {
          if (value < widget.selectedRange.start || value > widget.range.end) {
            _rangeError = "This value is out of bound. Change the value.";
          } else {
            _rangeError = null;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RangeSlider(
          values: widget.selectedRange,
          // labels: RangeLabels(
          //   widget.selectedRange.start.round().toString(),
          //   widget.selectedRange.end.round().toString(),
          // ),
          divisions: max(
            1,
            (widget.range.end - widget.range.start).round(),
          ),
          min: widget.range.start,
          max: widget.range.end,
          onChanged: (value) {
            widget.onChanged?.call(value);
            setState(() {
              _rangeMinController.value = _rangeMinController.value.copyWith(
                text: value.start.toStringAsFixed(0),
              );
              _rangeMaxController.value = _rangeMaxController.value.copyWith(
                text: value.end.toStringAsFixed(0),
              );
            });
          },
        ),
        Row(
          spacing: 20,
          children: [
            Expanded(
              child: TextFormField(
                controller: _rangeMinController,
                decoration: InputDecoration(
                  visualDensity: VisualDensity(vertical: -1),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                ),
                style: context.tt.bodyMedium,
                keyboardType: TextInputType.numberWithOptions(),
              ),
            ),
            SizedBox(width: 100),
            Expanded(
              child: TextFormField(
                controller: _rangeMaxController,
                textAlign: TextAlign.end,
                decoration: InputDecoration(
                  visualDensity: VisualDensity(vertical: -1),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                ),
                style: context.tt.bodyMedium,
                keyboardType: TextInputType.numberWithOptions(),
              ),
            ),
          ],
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              _rangeError ?? "",
              style: context.customTt.paragraphTextSmall!.copyWith(color: Colors.red),
            ),
          ),
      ],
    );
  }
}

class CostEntryList extends StatelessWidget {
  const CostEntryList({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('cost list rebuild');

    // ignore: unused_local_variable
    final contextWatch = context.watch<ListViewModel>();
    final groupedCostItems = context.select((ListViewModel state) => state.outputCostItems);
    final dailySummary = context.select((ListViewModel state) => state.outputDailySummary);
    final selectionMode = context.select((ListViewModel state) => state.selectionMode);
    final selectedItems = context.select((ListViewModel state) => state.selectedItems);
    // ignore: unused_local_variable
    final itemLength = context.select((ListViewModel state) => state.outputCostItems.length);
    // ignore: unused_local_variable
    final selectedItemLength = context.select((ListViewModel state) => state.selectedItems.length);
    final locale = FlutterLocalization.instance.currentLocale;
    if (groupedCostItems.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: context.mq.size.height * 0.5,
          child: Center(
            child: Column(
              spacing: 12,
              mainAxisSize: MainAxisSize.min,
              children: [
                GifView.asset(
                  'assets/images/ghost.gif',
                  withOpacityAnimation: false,
                  height: 24,
                  width: 24,
                  frameRate: 4,
                ),
                Text("Nothing here...", style: context.customTt.paragraphText),
              ],
            ),
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

            final String dateString = date.formatPretty(locale: locale);
            final double daySummary = dailySummary[date]!.balance;

            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    // decoration: BoxDecoration(border: BoxBorder.all(color: Colors.white)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        textBaseline: TextBaseline.ideographic,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(dateString, style: context.customTt.dateLabel!.copyWith()),
                          HideableText(
                            context.listMod.currencyFormat(
                              daySummary,
                              alwaysShowSign: true,
                              compact: true,
                            ),
                            textStyle: context.customTt.numberFontMedium!.copyWith(
                              color:
                                  contextWatch.displayConfig.showTotalColor
                                      ? contextWatch.accentColors.getColorByValue(daySummary)
                                      : context.cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...costItems.map((costItem) {
                    final CostItemCategory cat = context.listMod.findCatInList(costItem);
                    final selected = selectedItems.any((item) => item.uuid == costItem.uuid);
                    return GestureDetector(
                      onLongPress: () {
                        context.listMod.toggleSelectionMode(true);
                        context.listMod.updateSelection(costItem, true);
                        HapticFeedback.selectionClick();
                      },
                      onTap: () {
                        if (selectionMode) {
                          context.listMod.updateSelection(costItem, !selected);
                        } else {
                          context.push(
                            '/form',
                            extra: FormArgument(selectedCostItem: costItem),
                          );
                        }
                      },
                      child: Container(
                        height: 52,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? context.customCs.fadeColor3 : Colors.transparent,
                          // border: BoxBorder.all(color: Colors.white)
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
                                "${costItem.name == "" ? "[no desc]" : costItem.name}",
                                // maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: context.tt.bodyMedium!.copyWith(
                                  color: costItem.name == "" ? context.customCs.fadeColor2 : null,
                                  fontStyle: costItem.name == "" ? FontStyle.italic : null,
                                ),
                              ),
                            ),
                            HideableText(
                              context.listMod.currencyFormat(
                                costItem.absoluteAmount,
                                alwaysShowSign: true,
                                compact: true,
                              ),
                              textStyle: context.customTt.numberFontSmall!.copyWith(
                                color:
                                    contextWatch.displayConfig.showAmountColor
                                        ? (costItem.isExpense
                                            ? contextWatch.accentColors.negative
                                            : contextWatch.accentColors.positive)
                                        : context.cs.primary.withAlpha(200),
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
    // ignore: unused_local_variable
    final listen = context.watch<ListViewModel>();
    final expense = context.select((ListViewModel state) => state.outputMonthSummary.expense ?? 0);
    final income = context.select((ListViewModel state) => state.outputMonthSummary.income ?? 0);
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
    String overflowText = "",
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
                style: context.customTt.numberFontSmall!.copyWith(
                  fontSize: 14,
                  height: lerpDouble(
                    1.6,
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
            value,
            overflowText: overflowText,
            maxLine: 1,
            isCurrency: true,
            textStyle:
                isBig
                    ? context.customTt.numberFontLarge!.copyWith(
                      height: 1.1,
                      fontSize: lerpDouble(52, 36, progress),
                      color: context.customCs.onFlipCard,
                    )
                    : context.customTt.numberFontSmall!.copyWith(
                      height: lerpDouble(1.2, 0.01, Interval(0.2, 0.8).transform(progress)),
                      fontSize: lerpDouble(20, 1, progress),
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
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      overflowText: context.listMod.currencyFormat(
                        balance,
                        abbreviated: true,
                        alwaysShowSign: true,
                        compact: true,
                        decimalDigits: 2,
                      ),
                      progress: progress,
                      value: context.listMod.currencyFormat(
                        balance,
                        alwaysShowSign: true,
                        compact: true,
                        decimalDigits: 0,
                      ),
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
                              overflowText: "",
                              context.listMod.currencyFormat(
                                -expense,
                                alwaysShowSign: true,
                                compact: true,
                                abbreviated: true,
                              ),
                              textStyle: context.customTt.numberFontSmall!.copyWith(
                                color: Colors.red,
                                height: 1,
                                fontSize: 18,
                              ),
                            ),
                            HideableText(
                              overflowText: "",
                              context.listMod.currencyFormat(
                                income,
                                alwaysShowSign: true,
                                compact: true,
                                abbreviated: true,
                              ),
                              textStyle: context.customTt.numberFontSmall!.copyWith(
                                color: Colors.green,
                                height: 1,
                                fontSize: 18,
                              ),
                            ),
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
                  scale: lerpDouble(1, 0.5, Interval(0, 1).transform(progress))!,
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
  double get maxExtent => 140;

  @override
  double get minExtent => 100;

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
  // int _currentPage = 0;
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
  Widget build(BuildContext context) {
    final expense = context.select((ListViewModel state) => state.outputMonthSummary.expense ?? 0);
    final income = context.select((ListViewModel state) => state.outputMonthSummary.income ?? 0);
    final balance = income - expense;

    final double balancePercentage =
        balance == 0 && income == 0 ? 0.001 : max(0.001, balance / income);
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
              HideableText(
                income > 0 ? NumberFormat.percentPattern().format(balancePercentage) : "N/A",
                asteriskCount: 2,
                textStyle: context.customTt.numberFontMedium!.copyWith(
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
              centerSpaceRadius: 36,
              startDegreeOffset: -90,
              centerSpaceColor: Colors.transparent,
              sections: [
                PieChartSectionData(
                  showTitle: false,
                  value: balancePercentage,
                  radius: 8,
                  color: context.customCs.onFlipCard,
                  // color: Colors.green.shade800,
                  // cornerRadius: 10,
                ),
                PieChartSectionData(
                  showTitle: false,
                  value: 1 - balancePercentage,
                  radius: 8,
                  color: context.cs.surface.withAlpha(20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return charts.first;
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
        // visualDensity: VisualDensity(vertical: -4, horizontal: -4),
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        border: InputBorder.none,
        isDense: true,
        filled: false,
        contentPadding: EdgeInsets.all(0),
        hint: Row(
          spacing: 8,
          children: [
            Icon(Icons.search, color: context.customCs.fadeColor2),
            Text(
              "Search items...",
              style: context.tt.bodyMedium!.copyWith(color: context.customCs.fadeColor2),
            ),
          ],
        ),
      ),
    );
  }
}

class RangeSliderAlertDialog extends StatefulWidget {
  const RangeSliderAlertDialog({
    super.key,

    required this.items,
    this.initRange,
    this.initCostTypes,
  });
  final List<CostItem> items;
  final RangeValues? initRange;
  final Set<CostType>? initCostTypes;

  @override
  State<RangeSliderAlertDialog> createState() => _RangeSliderAlertDialogState();
}

class _RangeSliderAlertDialogState extends State<RangeSliderAlertDialog> {
  RangeValues _curRange = RangeValues(0, 1);
  Set<CostType> _costTypes = Set.from(CostType.values);

  @override
  void initState() {
    super.initState();
    _curRange = widget.initRange ?? RangeValues(minimum, maximum);
    _costTypes = widget.initCostTypes ?? _costTypes;
  }

  List<CostItem> get filteredItems {
    return widget.items.where((item) => _costTypes.contains(item.costType)).toList();
  }

  double get minimum {
    return filteredItems.isEmpty
        ? 0
        : filteredItems.fold(double.infinity, (initial, item) => min(initial, item.absoluteAmount));
  }

  double get maximum {
    return filteredItems.isEmpty
        ? 0
        : filteredItems.fold(
          double.negativeInfinity,
          (initial, item) => max(initial, item.absoluteAmount),
        );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Cost Range"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 50,
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton(
            style: SegmentedButton.styleFrom(visualDensity: VisualDensity(vertical: -0)),
            multiSelectionEnabled: true,
            segments:
                CostType.values
                    .map((el) => ButtonSegment(value: el, label: Text(el.name)))
                    .toList(),
            selected: _costTypes,
            onSelectionChanged: (value) {
              setState(() {
                _costTypes = value;
                _curRange = RangeValues(minimum, maximum);
              });
            },
          ),
          Column(
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  sliderTheme: SliderThemeData(
                    trackHeight: 2,
                    activeTrackColor: context.cs.secondary,
                    rangeThumbShape: RoundRangeSliderThumbShape(
                      enabledThumbRadius: 8,
                      pressedElevation: 0,
                    ),
                    showValueIndicator: ShowValueIndicator.alwaysVisible,
                    valueIndicatorTextStyle: context.customTt.numberFontSmall!.copyWith(
                      fontSize: 12,
                      color: context.cs.surface,
                    ),
                    valueIndicatorColor: context.cs.primary,
                  ),
                ),
                child: RangeSlider(
                  values: _curRange,
                  labels: RangeLabels(
                    _curRange.start.round().toString(),
                    _curRange.end.round().toString(),
                  ),
                  divisions: max(1, (maximum - minimum).round()),
                  min: minimum,
                  max: maximum,
                  onChanged: (RangeValues value) {
                    setState(() {
                      _curRange = value;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    minimum.toString(),
                    style: context.customTt.paragraphTextSmall,
                  ),
                  Text(maximum.toString(), style: context.customTt.paragraphTextSmall),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        DismissTextButton(
          onTap: context.pop,
        ),
        AffirmativeTextButton(
          text: "Apply",
          onTap: () {
            context.pop({"range": _curRange, "types": _costTypes});
          },
        ),
      ],
    );
  }
}

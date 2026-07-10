import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/chart/chart_reusables.dart';
import 'package:budget_tracker/ui/chart/chart_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChartCategoryBreakdownScreen extends StatelessWidget {
  const ChartCategoryBreakdownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final type = context.select((ChartViewModel state) => state.breakdownType);
    return CustomScaffold(
      appBarTitle: Text('Details'),
      actions: [IconButton(onPressed: () {}, icon: FaIcon(FontAwesomeIcons.sort, size: 20))],
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          if (details.primaryVelocity!.abs() < 1000) return;
          debugPrint(details.primaryVelocity!.toStringAsFixed(0));
          context.chartMod.updatePeriodDuration(increase: details.primaryVelocity! < 0);
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              sliver: SliverToBoxAdapter(
                child: CustomChartDetailTitleBar(
                  title: "Category Breakdown",
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SegmentedButton(
                selectedIcon: FaIcon(FontAwesomeIcons.check),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: Colors.transparent,
                  selectedForegroundColor: context.cs.primary,
                  foregroundColor: context.customCs.fadeColor1,
                  side: BorderSide.none,
                  textStyle: context.customTt.dateLabel!.copyWith(fontSize: 20),
                  splashFactory: NoSplash.splashFactory,
                ),
                segments: [
                  ...CostType.values.map(
                    (el) => ButtonSegment(
                      value: el,
                      label: Text(el.name.capitalize()),
                      icon: FaIcon(FontAwesomeIcons.moneyBill),
                    ),
                  ),
                ],
                onSelectionChanged: (type) => context.chartMod.changeBreakdownType(type.first),
                selected: {type},
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                height: 260,
                child: CategoryPieChart(),
              ),
            ),
            // SliverPadding(
            //   padding: const EdgeInsets.only(top: 20, bottom: 12.0),
            //   sliver: SliverToBoxAdapter(
            //     child: Divider(),
            //   ),
            // ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Category List",
                        style: context.customTt.dateLabel,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final response = await showDialog<CategoryBreakdownSort?>(
                          context: context,
                          builder: (dialogContext) {
                            return BreakdownSortDialog(
                              init: context.chartMod.breakdownSort,
                            );
                          },
                        );
                        if (response != null && context.mounted) {
                          context.chartMod.updateCategorySort(response);
                        }
                      },
                      icon: FaIcon(FontAwesomeIcons.sort, size: 18),
                    ),
                  ],
                ),
              ),
            ),
            const CategorySpendList(),
          ],
        ),
      ),
    );
  }
}

class BreakdownSortDialog extends StatefulWidget {
  const BreakdownSortDialog({
    super.key,
    required this.init,
  });

  final CategoryBreakdownSort init;

  @override
  State<BreakdownSortDialog> createState() => _BreakdownSortDialogState();
}

class _BreakdownSortDialogState extends State<BreakdownSortDialog> {
  SortType _categoryOrder = SortType.asc;
  SortType _itemOrder = SortType.asc;

  final List<String> _categorySortByGroup = ["Amount", "Name"];
  final List<String> _itemSortByGroup = ["Amount", "Name", "Date"];
  String _categorySortBy = "Amount";
  String _itemSortBy = "Amount";

  FaIconData getIcon(SortType type) {
    return type == SortType.asc
        ? FontAwesomeIcons.arrowDownShortWide
        : FontAwesomeIcons.arrowDownWideShort;
  }

  @override
  void initState() {
    super.initState();
    _categoryOrder = widget.init.categoryOrder;
    _categorySortBy = widget.init.categorySortBy;
    _itemOrder = widget.init.itemOrder;
    _itemSortBy = widget.init.itemSortBy;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Sort Breakdown List"),
      content: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Sort Category"),
          Row(
            spacing: 8,
            children: [
              Flexible(
                flex: 2,
                child: CustomDropDownMenu(
                  onSelected: (value) {
                    setState(() {
                      _categorySortBy = value ?? _categorySortBy;
                    });
                  },
                  initSelection: _categorySortBy,
                  entries:
                      _categorySortByGroup
                          .map(
                            (el) => DropdownMenuEntry(value: el, label: el),
                          )
                          .toList(),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _categoryOrder = _categoryOrder == SortType.asc ? SortType.dsc : SortType.asc;
                  });
                },
                icon: FaIcon(
                  getIcon(_categoryOrder),
                  size: 20,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 4,
          ),
          Text("Sort Item"),
          Row(
            spacing: 8,
            children: [
              Flexible(
                flex: 2,
                child: CustomDropDownMenu(
                  onSelected: (value) {
                    setState(() {
                      _itemSortBy = value ?? _categorySortBy;
                    });
                  },
                  initSelection: _itemSortBy,
                  entries:
                      _itemSortByGroup
                          .map(
                            (el) => DropdownMenuEntry(value: el, label: el),
                          )
                          .toList(),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _itemOrder = _itemOrder == SortType.asc ? SortType.dsc : SortType.asc;
                  });
                },
                icon: FaIcon(
                  getIcon(_itemOrder),
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        DismissTextButton(
          onTap: () => context.pop(null),
        ),
        AffirmativeTextButton(
          onTap:
              () => context.pop(
                CategoryBreakdownSort(
                  categoryOrder: _categoryOrder,
                  categorySortBy: _categorySortBy,
                  itemOrder: _itemOrder,
                  itemSortBy: _itemSortBy,
                ),
              ),
        ),
      ],
    );
  }
}

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key});
  @override
  Widget build(BuildContext context) {
    final data = context.select((ChartViewModel state) => state.filteredCurRangeCategorySummary);
    final total = context.select((ChartViewModel state) => state.filteredCurRangeSummary);
    final type = context.select((ChartViewModel state) => state.breakdownType);
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(type.name.capitalize(), style: context.customTt.numberFontSmall),
            Text(
              NumberFormat.currency(
                symbol: "RM",
                decimalDigits: 0,
              ).format(type == CostType.expense ? total.expense : total.income),
              style: context.customTt.elegantLabelLarge,
            ),
          ],
        ),
        PieChart(
          PieChartData(
            startDegreeOffset: -90,
            centerSpaceRadius: 100,
            sections:
                data.entries.map(
                  (entry) {
                    final value = entry.value;
                    final percentage =
                        type == CostType.expense
                            ? value.expense! / total.expense!
                            : value.income! / total.income!;
                    return PieChartSectionData(
                      cornerRadius: 12,
                      value: type == CostType.expense ? value.expense : value.income,
                      radius: 12,
                      color: entry.key.color,
                      badgeWidget:
                          percentage > 0.1
                              ? Container(
                                padding: EdgeInsets.all(4),
                                constraints: BoxConstraints(minWidth: 50),
                                decoration: BoxDecoration(
                                  color: context.cs.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  // spacing: 10,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      entry.key.name!.capitalize(),
                                      style: context.customTt.numberFontSmall!.copyWith(
                                        color: context.cs.surface,
                                        fontSize: 10,
                                      ),
                                    ),
                                    Text(
                                      NumberFormat.percentPattern().format(percentage),
                                      style: context.customTt.numberFontSmall!.copyWith(
                                        color: context.cs.surface,
                                        fontWeight: FontWeight(700),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : null,
                      badgePositionPercentageOffset: 0,
                      showTitle: false,
                    );
                  },
                ).toList(),
          ),
        ),
      ],
    );
  }
}

class CategorySpendList extends StatelessWidget {
  const CategorySpendList({super.key});

  @override
  Widget build(BuildContext context) {
    final items = context.select((ChartViewModel state) => state.curRangeSortedCategoryItems);
    final data = context.select((ChartViewModel state) => state.curRangeDetailedCategorySummary);
    final type = context.select((ChartViewModel state) => state.breakdownType);
    final max = context.select((ChartViewModel state) => state.maxCategoryAmount);

    return SliverList.builder(
      itemCount: data.length,
      itemBuilder: (context, i) {
        final category = data.keys.elementAt(i);
        final metric = data.values.elementAt(i);
        final value = type == CostType.expense ? metric.expense : metric.income;
        final percentage = value! / max;
        final matchedItems = items.entries.firstWhere((entry) => entry.key == category).value;
        return CategoryTile(
          key: ValueKey(category),
          category: category,
          value: value,
          percentage: percentage,
          items: matchedItems,
        );
      },
    );
  }
}

class CategoryTile extends StatefulWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.value,
    required this.percentage,
    required this.items,
  });

  final CostItemCategory category;
  final double? value;
  final double percentage;
  final List<CostItem> items;

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final bool isHidden = context.select(
      (ChartViewModel state) => state.hiddenCategories?.contains(widget.category) ?? false,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          // key: ValueKey((widget.category.name ?? "")),
          dense: true,
          onExpansionChanged:
              (value) => setState(() {
                _expanded = value;
              }),
          splashColor: Colors.transparent,
          showTrailingIcon: false,
          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
          tilePadding: EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: EdgeInsets.fromLTRB(12, 0, 12, 10),
          title: Row(
            spacing: 12,
            children: [
              CategoryIconContainer(
                category: widget.category,
                fade: isHidden ? 0 : null,
                size: 20,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          (widget.category.name ?? "").capitalize(),
                          style: context.tt.bodyMedium!.copyWith(
                            fontSize: 16,
                            color: isHidden ? context.customCs.fadeColor1 : null,
                          ),
                        ),
                        SizedBox(
                          height: 16,
                          child: IconButton(
                            iconSize: 14,
                            padding: EdgeInsets.zero,
                            splashColor: Colors.transparent,
                            visualDensity: VisualDensity(vertical: -4),
                            onPressed: () {
                              context.chartMod.toggleHideCategory(widget.category);
                            },
                            icon: Icon(isHidden ? Icons.visibility_off : Icons.visibility),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                widget.value!.customCurrencyFormat("RM"),
                                style: context.customTt.numberFontSmall?.copyWith(
                                  color: isHidden ? context.customCs.fadeColor1 : null,
                                ),
                              ),
                              Icon(
                                _expanded ? Icons.expand_less : Icons.expand_more,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.customCs.fadeColor2,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      height: 10,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: widget.percentage.isNaN ? 0 : widget.percentage.clamp(0, 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.category.color?.withAlpha(isHidden ? 50 : 255),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children:
              widget.items.map((item) {
                return GestureDetector(
                  onTap: () async {
                    final response = await context.push(
                      '/form',
                      extra: FormArgument(
                        selectedCostItem: item,
                        oriRoute: '/chart/category-breakdown',
                      ),
                    );
                    setState(() {
                      debugPrint("Expanded");
                      _expanded = true;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      spacing: 14,
                      children: [
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: Text(
                            DateFormat('d MMM').format(item.date!),
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                          flex: 11,
                          fit: FlexFit.tight,
                          child: Text(
                            item.name!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text(
                            item.amount!.customCurrencyFormat(""),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}

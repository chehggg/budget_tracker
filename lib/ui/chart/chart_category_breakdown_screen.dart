import 'dart:math';

import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/chart/chart_viewmodel.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChartCategoryBreakdownScreen extends StatelessWidget {
  const ChartCategoryBreakdownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category Breakdown'),
      ),
      body: SafeArea(
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
              // SliverToBoxAdapter(
              //   child: Padding(
              //     padding: const EdgeInsets.only(left: 12.0, right: 12, top: 12),
              //     child: const ChartFilterButtons(),
              //   ),
              // ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0, bottom: 20),
                  child: SizedBox(
                    height: 220,
                    child: const CategoryPieChart(),
                  ),
                ),
              ),
              const CategorySpendList(),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key});
  @override
  Widget build(BuildContext context) {
    final data = context.select((ChartViewModel state) => state.curRangeCategorySummary);
    final total = context.select((ChartViewModel state) => state.curRangeSummary);
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Expense', style: context.customTt.numberFontSmall),
            Text(
              NumberFormat.currency(symbol: "RM", decimalDigits: 0).format(total.expense),
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
                    final percentage = entry.value.expense! / total.expense!;
                    return PieChartSectionData(
                      value: entry.value.expense,
                      radius: 8,
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
    final items = context.select((ChartViewModel state) => state.getItemsGroupedByCategory());
    final data = context.select((ChartViewModel state) => state.curRangeCategorySummary);
    final max = data.isEmpty ? 0 : data.entries.first.value.expense;
    return SliverList.builder(
      itemCount: data.length,
      itemBuilder: (context, i) {
        final category = data.keys.elementAt(i);
        final value = data.values.elementAt(i).expense;
        final percentage = value! / max!;
        final matchedItems = items.entries
            .firstWhere((entry) => entry.key == category)
            .value
            .sorted((a, b) => b.amount.compareTo(a.amount));
        return CategoryTile(
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
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
                size: 20,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          (widget.category.name ?? "").capitalize(),
                          style: context.tt.bodyMedium!.copyWith(fontSize: 16),
                        ),
                        Row(
                          children: [
                            Text(
                              widget.value!.customCurrencyFormat("RM"),
                              style: context.customTt.numberFontSmall,
                            ),
                            Icon(
                              _expanded ? Icons.expand_less : Icons.expand_more,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.customCs.fadeColor2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: 6,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: min(widget.percentage, 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.category.color,
                            borderRadius: BorderRadius.circular(8),
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
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    spacing: 14,
                    children: [
                      Flexible(
                        flex: 2,
                        fit: FlexFit.tight,
                        child: Text(
                          DateFormat('d MMM').format(item.date),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Flexible(
                        flex: 11,
                        fit: FlexFit.tight,
                        child: Text(
                          item.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        fit: FlexFit.tight,
                        child: Text(
                          item.amount.customCurrencyFormat(""),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}

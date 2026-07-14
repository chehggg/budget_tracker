import 'dart:math';

import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/reusable_chart_component.dart';
import 'package:budget_tracker/ui/chart/chart_reusables.dart';
import 'package:budget_tracker/ui/chart/chart_screen.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class CumulativeBalanceDetailScreen extends StatelessWidget {
  const CumulativeBalanceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final overview = context.chartMod.cumulativeComparison;
    final maxLength = max(overview.first.length, overview.last.length);
    final columns = [
      "Day",
      context.chartMod.prevRangeStart.formatMonth(),
      context.chartMod.rangeStart.formatMonth(),
      "Change %",
    ];

    return CustomScaffold(
      appBarTitle: Text("Cumulative Balance"),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            sliver: SliverToBoxAdapter(
              child: CustomChartDetailTitleBar(
                title: "Cumulative Balance",
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: NewCumulativeLineChart(
              titleData: getCustomChartTitleData(context: context),
            ),
          ),
          SliverToBoxAdapter(
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: DataTable(
                columnSpacing: 4,
                horizontalMargin: 0,
                dataRowMaxHeight: 60,
                dataRowMinHeight: 40,
                dataTextStyle: context.tt.bodyMedium,
                headingTextStyle: context.customTt.numberFontSmall,
                dividerThickness: 0,
                border: TableBorder(
                  horizontalInside: BorderSide.none,
                ),
                columns:
                    columns.map((el) {
                      return DataColumn(
                        label: Text(el),
                        headingRowAlignment: MainAxisAlignment.center,
                      );
                    }).toList(),
                rows:
                    List.generate(maxLength, (index) {
                      final prev = overview.first.entries.elementAtOrNull(index);
                      final current = overview.last.entries.elementAtOrNull(index);

                      return [prev, current];
                    }).mapIndexed((i, el) {
                      final change =
                          el.first?.value == null || el.last?.value == null
                              ? null
                              : (el.last!.value - el.first!.value);
                      final percentage =
                          change == null ? null : ((change) / (el.first?.value ?? 1).abs());
                      return DataRow(
                        cells: [
                          // DataCell(Center(child: Text((i + 1).toString()))),
                          DataCell(
                            Center(child: Text((context.chartMod.getInitials(i)).toString())),
                          ),
                          ...el.map((entry) {
                            return DataCell(
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 2,
                                  children: [
                                    Text(
                                      entry == null
                                          ? "-"
                                          : context.chartMod.currencyFormat(
                                            entry.value,
                                            abbreviated: true,
                                            compact: true,
                                          ),
                                    ),
                                    if (entry != null)
                                      Text(
                                        entry.key.formatPrettyShort(),
                                        style: context.customTt.paragraphTextSmall,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          DataCell(
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 2,
                                children: [
                                  Text(
                                    change == null
                                        ? "-"
                                        : context.chartMod.currencyFormat(
                                          change,
                                          abbreviated: true,
                                          compact: true,
                                          alwaysShowSign: true,
                                        ),
                                  ),
                                  if (percentage != null)
                                    Text(
                                      percentage.formatSignedCompactPercentage(),
                                      style: context.customTt.paragraphTextSmall!.copyWith(
                                        color: context.chartMod.accentColors.getColorByValue(
                                          percentage,
                                          reversed: true,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                // rows:  [
                //   DataRow(cells: [DataCell(Text("What")), DataCell(Text("What"))]),
                //   DataRow(cells: [DataCell(Text("What")), DataCell(Text("What"))]),
                //   DataRow(cells: [DataCell(Text("What")), DataCell(Text("What"))]),
                // ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
            ),
          ),
        ],
      ),
    );
  }
}

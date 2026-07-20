import 'dart:math';
import 'dart:ui';

import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/languages.dart';
import 'package:budget_tracker/reusable/reusable_chart_component.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/chart/chart_reusables.dart';
import 'package:budget_tracker/ui/chart/chart_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/ui/list/main_list_screen.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final contextWatch = context.watch<ChartViewModel>();
    final ready = context.select((ChartViewModel state) => state.ready);
    final showMonth = context.chartMod.showMonths;
    final currentEmpty = context.chartMod.noCurData;
    final prevEmpty = context.chartMod.noPrevData;

    final displayPeriod = context.chartMod.curDisplayPeriod;
    final displayDetailsPeriod = context.chartMod.displayDetailsPeriodDuration;

    final FlTitlesData chartTitleData = getCustomChartTitleData(
      context: context,
      showLeft: true,
      showRight: true,
      bottomTitle: AxisTitles(
        sideTitles: SideTitles(
          interval: 1,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final isMatch = context.chartMod.matchLabelDate(value.round());
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Transform.scale(
                alignment: Alignment.center,
                scale: isMatch ? 1.2 : 1,
                child: Text(
                  context.chartMod.getInitials(
                    value.round(),
                    useInitials: true,
                    useDotForMonth: true,
                  ),
                  style: context.tt.bodyMedium!.copyWith(
                    fontSize: 10,
                    color: context.cs.primary.withAlpha(isMatch ? 250 : 100),
                    fontWeight:  FontWeight(600),
                  ),
                ),
              ),
            );
          },
          showTitles: true,
          maxIncluded: true,
        ),
      ),
    );

    SliverPadding getDivider() => SliverPadding(
      padding: const EdgeInsets.only(top: 18, bottom: 4),
      sliver: SliverToBoxAdapter(
        child: Divider(),
      ),
    );

    return CustomScaffold(
      appBarTitle: Text(
        AppLocale.aboutTitle.getString(context),
      ),
      actions: [
        IconButton(
          onPressed: () => context.chartMod.resetPeriod(),
          icon: FaIcon(
            FontAwesomeIcons.arrowRotateLeft,
            size: 20,
          ),
        ),
      ],
      ready: ready,
      safeAreaPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        children: [
          ChartFilterButtons(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: ChartHeaderDelegate(
                    displayPeriod: displayPeriod,
                    displayDetailsPeriod: displayDetailsPeriod,
                  ),
                ),
                ChartSection(
                  title: "MoM Overview",
                  child: YearMonthOverview(),
                ),
                getDivider(),
                // ChartSection(
                //   title: showMonth ? "YTM Overview" : "MTD Overview",
                //   pathName: '/chart/balance-compare',
                //   showLabelSubtitle: true,
                //   child: SummaryData(),
                // ),
                const ChartSection(
                  title: "Category Breakdown",
                  pathName: '/chart/category-breakdown',
                  child: CategoryBreakdownChart(),
                ),
                getDivider(),
                ChartSection(
                  title: showMonth ? "Monthly Spend" : "Daily Spend",
                  pathName: '/chart/daily-spend',
                  showLabelSubtitle: true,
                  showCurrentLabel: !currentEmpty,
                  showPreviousLabel: !prevEmpty,
                  child: DailyBarChart(
                    titleData: chartTitleData,
                  ),
                ),
                getDivider(),
                ChartSection(
                  title: "Cumulative",
                  showLabelSubtitle: true,
                  showCurrentLabel: !currentEmpty,
                  showPreviousLabel: !prevEmpty,
                  pathName: '/chart/cumulative-balance',
                  child: NewCumulativeLineChart(
                    titleData: chartTitleData,
                  ),
                ),
                getDivider(),
                ChartSection(
                  title: "Cumulative Average",
                  pathName: '/chart/cumulative-avg',
                  showLabelSubtitle: true,
                  showCurrentLabel: !currentEmpty,
                  showPreviousLabel: !prevEmpty,
                  child: NewAverageCumulativeLineChart(
                    titleData: chartTitleData,
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartFilterButtons extends StatelessWidget {
  const ChartFilterButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final period = context.select((ChartViewModel state) => state.period);
    return Column(
      spacing: 8,
      children: [
        Container(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: context.cs.surface),
          height: 44,
          width: double.infinity,
          child: SegmentedButton(
            style: SegmentedButton.styleFrom(
              side: BorderSide(color: context.customCs.fadeColor1?.withAlpha(120) ?? Colors.white),
              visualDensity: VisualDensity(vertical: 0),
              textStyle: context.customTt.dateLabel?.copyWith(fontSize: 20),
            ),
            showSelectedIcon: false,
            onSelectionChanged: (value) => context.chartMod.updatePeriod(value.first),
            segments:
                ChartPeriod.values
                    .map(
                      (el) => ButtonSegment(
                        value: el,
                        label: Text(
                          el.name.capitalize().substring(0, 1),
                        ),
                      ),
                    )
                    .toList(),
            selected: {period},
          ),
        ),
      ],
    );
  }
}

class ChartSection extends StatelessWidget {
  const ChartSection({
    super.key,
    this.showLabelSubtitle = false,
    this.showCurrentLabel = true,
    this.showPreviousLabel = true,
    required this.title,
    required this.child,
    this.pathName,
  });

  final String title;
  final Widget child;
  final bool showLabelSubtitle;
  final bool showCurrentLabel;
  final bool showPreviousLabel;
  final String? pathName;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 12.0, left: 12, right: 12),
      sliver: SliverToBoxAdapter(
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: context.customTt.dateLabel,
                      ),
                    ),
                    IconButton(
                      onPressed:
                          () =>
                              pathName != null
                                  ? context.push(pathName!, extra: context.chartMod)
                                  : null,
                      icon: FaIcon(FontAwesomeIcons.angleRight, size: 18),
                    ),
                  ],
                ),
                if (showLabelSubtitle)
                  Row(
                    spacing: 12,
                    children: [
                      if (!showCurrentLabel && !showPreviousLabel)
                        LabelIndicator(
                          text: "",
                          color: Colors.transparent,
                          fade: true,
                        ),
                      if (showCurrentLabel)
                        LabelIndicator(
                          text: context.chartMod.curDisplayPeriod,
                          color: context.chartMod.accentColors.current,
                          fade: true,
                        ),
                      if (showPreviousLabel)
                        LabelIndicator(
                          text: context.chartMod.prevDisplayPeriod,
                          color: context.chartMod.accentColors.previous,
                          fade: true,
                        ),
                    ],
                  ),
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class CategoryBreakdownChart extends StatelessWidget {
  const CategoryBreakdownChart({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.select((ChartViewModel state) => state.simplifiedCurRangeCategorySummary);
    final total = context.select((ChartViewModel state) => state.curRangeSummary);
    final isEmpty = context.chartMod.noCurData;
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12, bottom: 12),
      child: SizedBox(
        height: 150,
        child:
            isEmpty
                ? const NoDataChartSection()
                : Row(
                  spacing: 30,
                  children: [
                    SizedBox(
                      width: 140,
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 60,
                          startDegreeOffset: -90,
                          sections: [
                            ...data.entries.map(
                              (e) => PieChartSectionData(
                                color: e.key.color ?? Colors.amber,
                                cornerRadius: 12,
                                value: e.value.expense ?? 0,
                                radius: 8,
                                titlePositionPercentageOffset: 3,
                                showTitle: false,
                                badgePositionPercentageOffset: 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8,
                        children: [
                          ...data.entries.map(
                            (e) {
                              final percentage = e.value.expense! / total.expense!;
                              return Row(
                                spacing: 8,
                                children: [
                                  Flexible(
                                    flex: 2,
                                    fit: FlexFit.tight,
                                    child: LabelIndicator(
                                      text: e.key.capName,
                                      color: e.key.color ?? Colors.amber,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 2,
                                    fit: FlexFit.tight,
                                    child: Text(
                                      context.chartMod.currencyFormat(
                                        e.value.expense!,
                                        abbreviated: true,
                                        compact: true,
                                        showSymbol: false,
                                      ),
                                      style: context.tt.bodyMedium!.copyWith(
                                        fontSize: 12,
                                        color: context.cs.primary,
                                      ),
                                      textAlign: TextAlign.end,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    fit: FlexFit.tight,
                                    child: Text(
                                      "(${NumberFormat.percentPattern().format(percentage)})",
                                      style: context.tt.bodyMedium!.copyWith(
                                        fontSize: 12,
                                        color: context.cs.primary,
                                      ),
                                      textAlign: TextAlign.end,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

class DailyBarChart extends StatelessWidget {
  const DailyBarChart({
    super.key,
    this.titleData,
  });

  final FlTitlesData? titleData;

  @override
  Widget build(BuildContext context) {
    final data = context.select((ChartViewModel state) => state.dayToDayComparison);
    final isEmpty = context.chartMod.noData;
    final curRangeStart = context.chartMod.rangeStart;
    return Container(
      height: 180,
      padding: EdgeInsets.only(top: 12),
      child:
          isEmpty
              ? const NoDataChartSection()
              : BarChart(
                duration: Durations.medium1,
                BarChartData(
                  extraLinesData: getExtraLines(context, y: [0]),
                  alignment: BarChartAlignment.spaceBetween,
                  // groupsSpace: 20,
                  barTouchData: BarTouchData(
                    touchExtraThreshold: EdgeInsets.all(20),
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => context.cs.surface,
                      tooltipHorizontalOffset: 0,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final String curDate = context.chartMod.getFormatLabel(
                          data.elementAtOrNull(groupIndex)?.entries.elementAtOrNull(1)?.key,
                        );
                        final String prevDate = context.chartMod.getFormatLabel(
                          data.elementAtOrNull(groupIndex)?.entries.elementAtOrNull(0)?.key,
                        );
                        return BarTooltipItem(
                          "$curDate: ${context.chartMod.currencyFormat(group.barRods.last.toY, abbreviated: true, compact: true, showSymbol: false)}\n",
                          context.customTt.numberFontSmall!.copyWith(
                            fontSize: 10,
                            color: context.chartMod.accentColors.current,
                          ),
                          textAlign: TextAlign.end,
                          children: [
                            TextSpan(
                              text:
                                  "$prevDate: ${context.chartMod.currencyFormat(group.barRods.first.toY, abbreviated: true, compact: true, showSymbol: false)}",
                              style: TextStyle(
                                color: context.chartMod.accentColors.previous,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: customGrid,
                  titlesData: titleData,
                  // maxY: maxValue,
                  barGroups:
                      data.mapIndexed((i, el) {
                        return BarChartGroupData(
                          x: i,
                          groupVertically: true,
                          barRods:
                              el.entries.map(
                                (entry) {
                                  final isPrev = entry.key.isBefore(curRangeStart);
                                  return BarChartRodData(
                                    width: isPrev ? 2 : 5,
                                    color:
                                        isPrev
                                            ? Colors.blue.shade400.withAlpha(150)
                                            : context.cs.secondary,
                                    toY:
                                        context.chartMod.chartMetric.getCostMetric(entry.value) ??
                                        0,
                                  );
                                },
                              ).toList(),
                        );
                      }).toList(),
                ),
              ),
    );
  }
}

class SummaryData extends StatelessWidget {
  const SummaryData({super.key, this.large = false});

  final bool large;
  @override
  Widget build(BuildContext context) {
    final data = context.select((ChartViewModel state) => state.balanceOverview);
    final size = 220.0;
    final balanceOffset = context.chartMod.balanceOffset;
    return Container(
      height: size,
      padding: EdgeInsets.only(bottom: 30, left: 10, right: 10, top: 30),
      child: Stack(
        // spacing: 40,
        children: [
          ...data.entries.map((el) {
            final alignment = switch (el.key) {
              "expense" => Alignment(-1, -1.15),
              "income" =>
                el.value.entries.fold(0.0, (init, entry) => max(init, entry.value)) == 0
                    ? Alignment(-1, 0.07)
                    : Alignment(1, 0.07),
              "balance" => Alignment(balanceOffset, 1.25),
              _ => Alignment(0, 0),
            };
            final prevValue = el.value['previous'] ?? 0;
            final currentValue = el.value['current'] ?? 0;

            final changePercentage =
                (el.key == 'expense' ? -1 : 1) * currentValue.calculatePercentageChange(prevValue);

            final largerBetter = el.key != 'expense';
            final symbol =
                (changePercentage.isNaN || changePercentage.isInfinite)
                    ? ""
                    : (changePercentage >= 0 ? "▲ " : "▼ ");
            final isGood =
                (largerBetter && changePercentage >= 0) || (!largerBetter && changePercentage < 0);
            final color =
                (changePercentage.isInfinite || changePercentage.isNaN)
                    ? context.customCs.fadeColor1
                    : isGood
                    ? context.chartMod.accentColors.positive
                    : context.chartMod.accentColors.negative;
            return Positioned.fill(
              child: Align(
                alignment: alignment,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        el.key.capitalize(),
                        style: context.tt.bodyMedium!.copyWith(fontSize: 12),
                      ),
                      Text(
                        "${symbol} ${changePercentage.formatCompactPercentage().replaceAll('-', '')}",
                        style: context.customTt.numberFontSmall!.copyWith(
                          fontSize: 12,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Padding(
            padding: EdgeInsets.only(left: 70, right: context.chartMod.padRight ? 70 : 0),
            // width: ,
            child: BarChart(
              BarChartData(
                rotationQuarterTurns: large ? 0 : 1,
                alignment: BarChartAlignment.spaceBetween,
                gridData: customGrid,
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(y: 0, color: context.customCs.fadeColor2, dashArray: [2, 5]),
                  ],
                ),
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: EdgeInsets.only(top: 20),
                    direction: TooltipDirection.bottom,
                    tooltipHorizontalAlignment: FLHorizontalAlignment.center,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem("", context.tt.bodyMedium!);
                      // if (large) {
                      //   return BarTooltipItem("", context.tt.bodyMedium!);
                      // }
                    },
                    getTooltipColor: (group) {
                      return Colors.transparent;
                    },
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: getCustomChartTitleData(
                  context: context,
                ),
                barGroups:
                    data.entries.mapIndexed((index, dataEntry) {
                      final int largerIndex =
                          dataEntry.value.entries.first.value.abs() >
                                  dataEntry.value.entries.last.value.abs()
                              ? 0
                              : 1;
                      return BarChartGroupData(
                        // groupVertically: true,
                        barsSpace: 2,
                        showingTooltipIndicators: [largerIndex],
                        x: index,
                        barRods:
                            dataEntry.value.entries.map((entry) {
                              return BarChartRodData(
                                borderRadius: BorderRadius.circular(large ? 4 : 2),
                                toY: entry.value,
                                label: BarChartRodLabel(
                                  show: !large,
                                  offset:
                                      large
                                          ? Offset(entry.key == "current" ? 14 : -14, 10)
                                          : Offset(entry.key == "current" ? 16 : -16, -30),
                                  text:
                                      entry.value != 0
                                          ? context.chartMod.currencyFormat(
                                            entry.value,
                                            abbreviated: true,
                                            compact: true,
                                            alwaysShowSign: true,
                                          )
                                          : "",
                                  style: context.customTt.paragraphText!.copyWith(fontSize: 10),
                                ),
                                width: large ? 10 : 7,
                                color:
                                    entry.key == "current"
                                        ? context.cs.secondary
                                        : Colors.blue.shade700.withAlpha(200),
                              );
                            }).toList(),
                      );
                    }).toList(),
              ),
            ),
          ),
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     Text("1"),
          //     Text("2"),
          //     Text("3"),
          //   ],
          // ),
        ],
      ),
    );
  }
}

class CustomChartSection extends StatefulWidget {
  const CustomChartSection({
    super.key,
    required this.title,
    required this.pageChildren,
    required this.sectionHeight,
  });

  final String title;
  final double sectionHeight;
  final List<Widget> pageChildren;

  @override
  State<CustomChartSection> createState() => _CustomChartSectionState();
}

class _CustomChartSectionState extends State<CustomChartSection> {
  int _currentDateTrendPageIndex = 0;
  late PageController _controller;

  void updateTrendPage(DragEndDetails details, int pageLength) {
    if (details.primaryVelocity == null || pageLength == 1) return;
    if (details.primaryVelocity! > 200 && _currentDateTrendPageIndex > 0) {
      // scroll left, back
      setState(() {
        _currentDateTrendPageIndex = _currentDateTrendPageIndex - 1;
      });
    } else if (details.primaryVelocity! < -200 && _currentDateTrendPageIndex < pageLength - 1) {
      setState(() {
        _currentDateTrendPageIndex = _currentDateTrendPageIndex + 1;
      });
    }

    _controller.animateToPage(
      _currentDateTrendPageIndex,
      duration: Durations.long1,
      curve: Curves.easeInOutExpo,
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 1);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.sectionHeight,
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          updateTrendPage(details, widget.pageChildren.length);
        },
        child: Column(
          spacing: 0,
          children: [
            Row(
              children: [
                Expanded(
                  child: ChartTitleBar(
                    title: widget.title,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: PageIndicator(
                    pageLength: widget.pageChildren.length,
                    currentPage: _currentDateTrendPageIndex,
                  ),
                ),
              ],
            ),
            Expanded(
              // child: const DateTrendLineChart()
              child: PageView.builder(
                itemCount: widget.pageChildren.length,
                // padEnds: false,
                physics: NeverScrollableScrollPhysics(),
                controller: _controller,
                itemBuilder: (context, index) {
                  return widget.pageChildren[index];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartLegendItem extends StatelessWidget {
  const ChartLegendItem({
    super.key,
    required this.primaryColor,
    required this.title,
    this.trailing,
    this.tileWidth,
    this.fontSize = 13,
  });

  final Color primaryColor;
  final String title;
  final Widget? trailing;

  final double? tileWidth;
  final double? fontSize;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tileWidth,
      child: ListTile(
        leading: Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withAlpha(200),
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: fontSize),
        ),
        visualDensity: VisualDensity(vertical: -4),
        dense: true,
        contentPadding: EdgeInsets.only(right: 16),
        trailing: trailing,
      ),
    );
  }
}

class ChartTitleBar extends StatelessWidget {
  const ChartTitleBar({super.key, this.title, this.description});

  final String? title;
  final String? description;
  @override
  Widget build(BuildContext context) {
    final appTextTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Text(
            title!,
            style: context.customTt.dateLabel!.copyWith(
              // fontSize: 20,
              // color: Theme.of(context).colorScheme.primary
            ),
          ),
        if (description != null)
          Text(
            description!,
            style: appTextTheme.bodyMedium!.copyWith(
              // fontSize: 14
              color: context.cs.primary.withAlpha(180),
            ),
          ),
      ],
    );
  }
}

class PercentageBar extends StatelessWidget {
  const PercentageBar({
    super.key,
    required this.height,
    required this.color,
    required this.percentage,
  });

  final double height;
  final Color color;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: height,
              width: constraint.maxWidth,
              decoration: BoxDecoration(
                color: color.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Container(
              height: height,
              width: constraint.maxWidth * (percentage).abs(),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withAlpha(100),
                    color,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        );
      },
    );
  }
}

class NewCumulativeLineChart extends StatelessWidget {
  const NewCumulativeLineChart({super.key, this.titleData});

  final FlTitlesData? titleData;

  @override
  Widget build(BuildContext context) {
    final cumulativeComparison = context.select(
      (ChartViewModel state) => state.cumulativeComparison,
    );
    final isEmpty = context.chartMod.noData;
    final curRangeStart = context.select((ChartViewModel state) => state.rangeStart);
    final showMonths = context.select((ChartViewModel state) => state.showMonths);
    final metric = context.select((ChartViewModel state) => state.chartMetric);
    final now = DateTime.now().standard;
    return Container(
      height: 180,
      padding: EdgeInsets.only(top: 12),
      child:
          isEmpty
              ? const NoDataChartSection()
              : LineChart(
                curve: Curves.easeOut,
                LineChartData(
                  maxX: context.chartMod.xRange.toDouble(),
                  titlesData: titleData ?? FlTitlesData(),
                  minY: metric != ChartMetric.balance ? 0 : null,
                  borderData: FlBorderData(show: false),
                  lineTouchData: getCustomLineTouchData(
                    context: context,
                    getTooltipItems:
                        (touchedSpots) =>
                            touchedSpots.map(
                              (spot) {
                                final isPrev = spot.barIndex == 0;

                                final String curDate = context.chartMod.getFormatLabel(
                                  cumulativeComparison
                                      .elementAtOrNull(1)
                                      ?.entries
                                      .elementAtOrNull(spot.x.round())
                                      ?.key,
                                );
                                final String prevDate = context.chartMod.getFormatLabel(
                                  cumulativeComparison
                                      .elementAtOrNull(0)
                                      ?.entries
                                      .elementAtOrNull(spot.x.round())
                                      ?.key,
                                );
                                return LineTooltipItem(
                                  "${isPrev ? prevDate : curDate}: ${context.chartMod.currencyFormat(spot.y, abbreviated: true, compact: true, showSymbol: false)}",
                                  context.customTt.numberFontSmall!.copyWith(
                                    fontSize: 10,
                                    color:
                                        isPrev
                                            ? context.chartMod.accentColors.previous
                                            : context.chartMod.accentColors.current,
                                  ),
                                  textAlign: TextAlign.right,
                                );
                              },
                            ).toList(),
                  ),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: 0,
                        dashArray: [2, 10],
                        color: context.customCs.fadeColor2,
                        strokeWidth: 1,
                      ),
                    ],
                  ),
                  gridData: customGrid,
                  lineBarsData:
                      cumulativeComparison.mapIndexed((i, element) {
                        final bool isPrev = i == 0;
                        final Color mainColor =
                            isPrev ? Colors.blue.shade300 : context.cs.secondary;
                        return getCustomLineChartBarData(
                          showingIndicators: [0],
                          dashArray: isPrev ? [2, 10] : null,
                          color: mainColor,
                          dotData: FlDotData(
                            checkToShowDot: (spot, barData) {
                              if (showMonths) {
                                return !isPrev &&
                                    curRangeStart.addMonth(spot.x.round()).isInSameYearMonthAs(now);
                              } else {
                                return !isPrev &&
                                    curRangeStart.addDay(spot.x.round()).isAtSameMomentAs(now);
                              }
                            },
                          ),
                          spots: [
                            ...element.entries.map(
                              (entry) {
                                int index;
                                if (showMonths) {
                                  index = entry.key.month - element.keys.first.month;
                                } else {
                                  index = entry.key.difference(element.keys.first).inDays;
                                }
                                return FlSpot(index.toDouble(), entry.value);
                              },
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
    );
  }
}

class NewAverageCumulativeLineChart extends StatelessWidget {
  const NewAverageCumulativeLineChart({super.key, this.titleData});

  final FlTitlesData? titleData;

  @override
  Widget build(BuildContext context) {
    final cumulativeComparison = context.select(
      (ChartViewModel state) => state.avgCumulativeComparison,
    );
    final isEmpty = context.chartMod.noData;
    final metric = context.select((ChartViewModel state) => state.chartMetric);
    final curRangeStart = context.select((ChartViewModel state) => state.rangeStart);
    final showMonths = context.select((ChartViewModel state) => state.showMonths);
    final now = DateTime.now().standard;
    return Container(
      height: 180,
      padding: EdgeInsets.only(top: 12),
      child:
          isEmpty
              ? const NoDataChartSection()
              : LineChart(
                LineChartData(
                  maxX: context.chartMod.xRange.toDouble(),
                  minY: metric != ChartMetric.balance ? 0 : null,
                  extraLinesData: getExtraLines(context, y: [0]),
                  titlesData: titleData ?? FlTitlesData(),
                  borderData: FlBorderData(show: false),
                  lineTouchData: getCustomLineTouchData(
                    context: context,
                    getTooltipItems:
                        (touchedSpots) =>
                            touchedSpots.map(
                              (spot) {
                                final isPrev = spot.barIndex == 0;

                                final String curDate = context.chartMod.getFormatLabel(
                                  cumulativeComparison
                                      .elementAtOrNull(1)
                                      ?.entries
                                      .elementAtOrNull(spot.x.round())
                                      ?.key,
                                );
                                final String prevDate = context.chartMod.getFormatLabel(
                                  cumulativeComparison
                                      .elementAtOrNull(0)
                                      ?.entries
                                      .elementAtOrNull(spot.x.round())
                                      ?.key,
                                );
                                return LineTooltipItem(
                                  "${isPrev ? prevDate : curDate}: ${context.chartMod.currencyFormat(spot.y, abbreviated: true, compact: true, showSymbol: false)}",
                                  context.customTt.numberFontSmall!.copyWith(
                                    fontSize: 10,
                                    color:
                                        isPrev
                                            ? context.chartMod.accentColors.previous
                                            : context.chartMod.accentColors.current,
                                  ),
                                  textAlign: TextAlign.right,
                                );
                              },
                            ).toList(),
                  ),
                  gridData: customGrid,
                  lineBarsData:
                      cumulativeComparison.mapIndexed((i, element) {
                        final bool isPrev = i == 0;
                        final Color mainColor =
                            isPrev ? Colors.blue.shade300 : context.cs.secondary;
                        return getCustomLineChartBarData(
                          spots: [
                            ...element.entries.map(
                              (entry) {
                                int index;
                                if (showMonths) {
                                  index = entry.key.month - element.keys.first.month;
                                } else {
                                  index = entry.key.difference(element.keys.first).inDays;
                                }
                                return FlSpot(index.toDouble(), entry.value);
                              },
                            ),
                          ],
                          color: mainColor,
                          dashArray: isPrev ? [2, 10] : null,
                          dotData: FlDotData(
                            checkToShowDot: (spot, barData) {
                              if (showMonths) {
                                return !isPrev &&
                                    curRangeStart.addMonth(spot.x.round()).isInSameYearMonthAs(now);
                              } else {
                                return !isPrev &&
                                    curRangeStart.addDay(spot.x.round()).isAtSameMomentAs(now);
                              }
                            },
                          ),
                        );
                      }).toList(),
                ),
              ),
    );
  }
}

class YearMonthOverview extends StatelessWidget {
  const YearMonthOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final overview = context.select((ChartViewModel state) => state.rangeOverview);
    return Container(
      height: 180,
      padding: EdgeInsets.only(bottom: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          BarChart(
            duration: Duration.zero,
            BarChartData(
              minY: 0,
              borderData: FlBorderData(show: false),
              gridData: customGrid,
              barTouchData: BarTouchData(enabled: false),
              alignment: BarChartAlignment.spaceBetween,
              titlesData: getCustomChartTitleData(
                context: context,
                padRight: true,
                showLeft: true,
                bottomTitle: AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: 32,
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20.0, right: 10),
                        child: Transform.rotate(
                          alignment: Alignment.bottomLeft,
                          angle: -0.5,
                          child: Text(
                            context.chartMod.getDisplayPeriodLabel(
                              overview.keys.elementAt(value.round()),
                            ),
                            style: context.tt.bodyMedium!.copyWith(fontSize: 10),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups:
                  overview.entries.mapIndexed((i, el) {
                    return BarChartGroupData(
                      x: i,
                      barRods:
                          [
                            ChartMetric.expense,
                            ChartMetric.income,
                          ].mapIndexed((metricIndex, e) {
                            final isExpense = metricIndex == 0;
                            return BarChartRodData(
                              width: 6,
                              toY: e.getCostMetric(el.value) ?? 0,
                              color: (isExpense
                                      ? context.chartMod.accentColors.negative
                                      : context.chartMod.accentColors.positive)
                                  .withAlpha(context.chartMod.matchItem(el.key) ? 250 : 100),
                            );
                          }).toList(),
                    );
                  }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 7.0,
            ),
            child: LineChart(
              duration: Duration.zero,
              LineChartData(
                extraLinesData: getExtraLines(context, y: [0]),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: getCustomChartTitleData(
                  padLeft: true,
                  showRight: true,
                  context: context,
                  bottomTitle: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 40,
                      showTitles: true,
                      getTitlesWidget: (value, meta) => SizedBox.shrink(),
                    ),
                  ),
                ),
                lineTouchData: getCustomLineTouchData(
                  context: context,
                  getTooltipItems:
                      (touchedSpots) =>
                          touchedSpots.map(
                            (el) {
                              final i = el.spotIndex;
                              final metric = overview.entries.elementAt(i);
                              return LineTooltipItem(
                                "${metric.key.formatMonth()}: ${context.chartMod.currencyFormat(metric.value.balance, abbreviated: true, compact: true)}",
                                context.customTt.numberFontSmall!.copyWith(fontSize: 10),
                                children: [
                                  TextSpan(
                                    text:
                                        "\n+${context.chartMod.currencyFormat(metric.value.income ?? 0, abbreviated: true, compact: true)}",
                                    style: TextStyle(
                                      color: context.chartMod.getChangePercentageColor(1),
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        " -${context.chartMod.currencyFormat(metric.value.expense ?? 0, abbreviated: true, compact: true)}",
                                    style: TextStyle(
                                      color: context.chartMod.getChangePercentageColor(-1),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ).toList(),
                ),
                lineBarsData: [
                  getCustomLineChartBarData(
                    color: context.cs.primary,
                    barWidth: 1,
                    dashArray: [2, 5],
                    showGradient: false,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, p1, p2, index) {
                        final isCurrent = context.chartMod.matchItem(
                          overview.entries.elementAt(spot.x.round()).key,
                        );
                        // .isInSameYearMonthAs(start);
                        return FlDotCirclePainter(
                          color: context.cs.primary,
                          radius: isCurrent ? 6 : 3,
                        );
                      },
                    ),
                    spots:
                        overview.entries
                            .mapIndexed(
                              (index, entry) => FlSpot(index.toDouble(), entry.value.balance),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartHeaderDelegate extends SliverPersistentHeaderDelegate {
  ChartHeaderDelegate({required this.displayPeriod, required this.displayDetailsPeriod});

  final String displayPeriod, displayDetailsPeriod;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0, 1);
    return Container(
      color: context.cs.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity == null) return;
            if (details.primaryVelocity! > 500) {
              // swipe right
              context.chartMod.updatePeriodDuration(increase: false);
            } else if (details.primaryVelocity! < -500) {
              // swipe left
              context.chartMod.updatePeriodDuration(increase: true);
            }
          },
          child: ReusableContainer(
            height: 120,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            width: double.infinity,
            filled: true,
            highlight: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Current View",
                  style: context.customTt.numberFontSmall?.copyWith(
                    color: context.cs.onSecondary.withAlpha(200),
                    fontSize: lerpDouble(14, 14, progress),
                    height: lerpDouble(1.4, 1.4, progress),
                    fontWeight: FontWeight(600),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.chartMod.updatePeriodDuration(increase: false),
                      icon: FaIcon(
                        FontAwesomeIcons.angleLeft,
                        color: context.cs.surface,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        child: Text(
                          displayPeriod,
                          textAlign: TextAlign.center,
                          style: context.customTt.numberFontLarge?.copyWith(
                            color: context.cs.surface,
                            fontSize: lerpDouble(52, 36, progress),
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.chartMod.updatePeriodDuration(increase: true),
                      icon: FaIcon(
                        FontAwesomeIcons.angleRight,
                        color: context.cs.surface,
                      ),
                    ),
                  ],
                ),
                Text(
                  displayDetailsPeriod,
                  style: context.customTt.paragraphText?.copyWith(
                    color: context.cs.surface.withAlpha(
                      lerpDouble(200, 0, progress)!.round(),
                    ),
                    fontSize: lerpDouble(16, 12, progress),
                    height: lerpDouble(1.3, 0.01, progress),
                  ),
                ),
              ],
            ),
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
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class NoDataChartSection extends StatelessWidget {
  const NoDataChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "No Data",
        style: TextStyle(color: context.customCs.fadeColor1),
      ),
    );
  }
}

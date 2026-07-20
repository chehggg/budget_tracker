import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/classes/goal_category.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/goal/goal_form_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GoalTypeSelectionScreen extends StatefulWidget {
  const GoalTypeSelectionScreen({super.key});

  @override
  State<GoalTypeSelectionScreen> createState() => _GoalTypeSelectionScreenState();
}

class _GoalTypeSelectionScreenState extends State<GoalTypeSelectionScreen> {
  GoalType _goalType = GoalType.budget;
  @override
  Widget build(BuildContext context) {
    final goalCategories = defaultGoalCategories.where((category) => category.type == _goalType);
    return CustomScaffold(
      padHorizontal: true,
      appBarTitle: Text("New Goal"),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Text("Page 1 of 2"),
                Text(
                  "What kind of goal do you want to set?",
                  style: context.customTt.elegantLabelLarge,
                ),
                SegmentedButton(
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity(vertical: 0),
                    selectedBackgroundColor: context.cs.primary,
                    selectedForegroundColor: context.cs.surface,
                    textStyle: context.tt.labelSmall!.copyWith(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(8),
                    ),
                  ),
                  expandedInsets: EdgeInsets.only(top: 12),
                  segments:
                      GoalType.values
                          .map(
                            (type) => ButtonSegment(
                              value: type,
                              label: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  type.name.capitalize(),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  selected: {_goalType},
                  onSelectionChanged: (val) => setState(() => _goalType = val.first),
                ),
                Text(
                  _goalType.description,
                  style: context.customTt.paragraphText,
                ),
              ],
            ),
          ),
          SliverList.builder(
            itemCount: goalCategories.length,
            itemBuilder: (context, index) {
              final category = goalCategories.elementAt(index);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ReusableContainer(
                  onTap: () => context.go('/goals/new-goal-detail', extra: category),
                  // onTap: () => context.go('/'),
                  padding: EdgeInsets.all(20),
                  child: Row(
                    spacing: 20,
                    children: [
                      FaIcon(
                        category.icon,
                        size: 36,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 4,
                          children: [
                            Text(
                              category.title,
                              textAlign: TextAlign.left,
                              style: context.customTt.paragraphTitle,
                            ),
                            Text(
                              category.description,
                              textAlign: TextAlign.left,
                              style: context.customTt.paragraphText,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class GoalFormInfoScreen extends StatelessWidget {
  const GoalFormInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Goal details"),
        actions: [
          IconButton(
            onPressed: () async {
              final error = context.goalFormMod.validateForm();
              if (error != null) {
                context.showErrorNotification(message: error);
              } else {
                await context.goalFormMod.submitGoal();

                if (context.mounted) {
                  context.go('/goals');
                }
                // if (context.goalFormMod.isEditMode) {
                //   context.showSuccessNotification(message: "Goal updated!");
                // } else {
                //   if (context.mounted) {
                //     context.showSuccessNotification(message: "New goal created!");
                //   }
                // }
              }
            },
            icon: Icon(Icons.check),
          ),
          IconButton(
            onPressed: () async {
              await context.goalFormMod.deleteGoal();
              if (context.mounted) {
                context.go('/goals');
                // context.showSuccessNotification(message: "Goal deleted!");
              }
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: SafeArea(
        minimum: EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: const GoalInfoFormBody(),
      ),
    );
  }
}

class GoalInfoFormBody extends StatefulWidget {
  const GoalInfoFormBody({super.key});

  @override
  State<GoalInfoFormBody> createState() => _GoalInfoFormBodyState();
}

class _GoalInfoFormBodyState extends State<GoalInfoFormBody> {
  bool _openAdvanced = false;
  late final TextEditingController _titleController;
  late final TextEditingController _targetController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();

    final draftedGoal = context.goalFormMod.draftGoal;

    _titleController = TextEditingController(
      text: draftedGoal.title,
    )..addListener(() {
      context.goalFormMod.updateTitle(_titleController.text);
    });
    _descController = TextEditingController(
      text: draftedGoal.description,
    )..addListener(() {
      context.goalFormMod.updateDesc(_descController.text);
    });
    _targetController = TextEditingController(
      text: draftedGoal.target?.formatRoundedString(),
    )..addListener(() {
      context.goalFormMod.updateTarget(_targetController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final draftedGoal = context.select((GoalFormViewModel state) => state.draftGoal);
    final endDateCheck = context.select((GoalFormViewModel state) => state.isEndChecked);
    final startDateController = context.select(
      (GoalFormViewModel state) => state.startDateController,
    );
    final endDateController = context.select((GoalFormViewModel state) => state.endDateController);

    final mainSubtitle = switch (draftedGoal.goalType!) {
      GoalType.budget => "I want to keep my spend below",
      GoalType.savings => "I want to save above",
      GoalType.payment => "I want to commit to payment of above",
    };

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Text('Basic Infomation', style: context.customTt.dateLabel),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          sliver: SliverToBoxAdapter(
            child: ReusableContainer(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
              filled: true,
              highlight: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mainSubtitle,
                    style: TextStyle(color: context.cs.surface),
                  ),
                  TextFormField(
                    controller: _targetController,
                    cursorColor: context.cs.surface,
                    textAlign: TextAlign.end,
                    keyboardType: TextInputType.numberWithOptions(),
                    style: context.customTt.elegantLabelLarge?.copyWith(
                      fontSize: 50,
                      height: 1.2,
                      color: context.cs.surface,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Text(
                        "RM",
                        style: context.customTt.elegantLabelLarge?.copyWith(
                          fontSize: 50,
                          color: context.cs.surface,
                        ),
                      ),
                      hintText: "0.00",
                      isDense: true,
                      visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          sliver: SliverToBoxAdapter(
            child: GoalsTextField(
              fieldLabel: "Name",
              hintText: "Give this goal a title...",
              controller: _titleController,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          sliver: SliverToBoxAdapter(
            child: GoalsTextField(
              fieldLabel: "Description",
              hintText: "Describe this goal...",
              controller: _descController,
              minLines: 3,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          sliver: SliverToBoxAdapter(
            child: Row(
              spacing: 10,
              children: [
                Expanded(
                  child: GoalTapTextField(
                    controller: startDateController,
                    fieldLabel: "From",
                    onTap: () async {
                      final DateTime? response = await showDialog(
                        context: context,
                        builder: (_) {
                          return DateDialog(
                            initDate: draftedGoal.startDate,
                          );
                        },
                      );
                      if (response != null) {
                        context.goalFormMod.updateStartDate(response);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: GoalTapTextField(
                    controller: endDateController,
                    checkbox: true,
                    checkboxVal: endDateCheck,
                    onCheckboxChanged: context.goalFormMod.checkEndDate,
                    fieldLabel: "End",
                    onTap: () async {
                      final DateTime? response = await showDialog(
                        context: context,
                        builder: (_) {
                          return DateDialog(
                            initDate: draftedGoal.endDate,
                          );
                        },
                      );
                      if (response != null) {
                        context.goalFormMod.updateEndDate(response);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Row(
            children: [
              Transform.scale(
                scale: 0.7,
                alignment: Alignment.centerLeft,
                child: Switch(
                  value: _openAdvanced,
                  onChanged: (val) {
                    setState(() {
                      _openAdvanced = val;
                    });
                  },
                ),
              ),
              Text("Show advanced settings"),
            ],
          ),
        ),
        if (_openAdvanced)
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            sliver: SliverToBoxAdapter(
              child: const GoalFormTrackingSection(),
            ),
          ),
        if (_openAdvanced)
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Conditions',
                    style: context.customTt.dateLabel,
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    'Apply a filter to only include item that you want to keep track within this budget.',
                    style: context.customTt.paragraphText,
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      const GoalFormCategoryFilterTile(),
                      const GoalFormStringFilterFile(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 40,
          ),
        ),
      ],
    );
  }
}

class GoalFormStringFilterFile extends StatelessWidget {
  const GoalFormStringFilterFile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final initFilter = context.select((GoalFormViewModel state) => state.draftedFilter);
    return InkWell(
      onTap: () async {
        final StringFilter? response = await context.push('/goals/text-filter', extra: initFilter);
        if (response == null) return;
        context.goalFormMod.updateFilterString(response);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Item Description",
            style: context.customTt.numberFontMedium!.copyWith(fontSize: 16),
          ),
          Text.rich(
            TextSpan(
              text:
                  initFilter == null
                      ? "Includes all item descriptions."
                      : "Includes where description ${initFilter.matchType.text} ",
              style: context.customTt.paragraphText,
              children: [
                TextSpan(text: initFilter?.query, style: context.customTt.paragraphTitle),
                TextSpan(text: "."),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GoalFormCategoryFilterTile extends StatelessWidget {
  const GoalFormCategoryFilterTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List<CostItemCategory>? categories = context.select(
      (GoalFormViewModel state) => state.categories,
    );
    return InkWell(
      onTap: () async {
        final List<CostItemCategory>? Function()? response = await context.push(
          '/goals/category',
          extra: categories,
        );

        if (response == null) return;
        context.goalFormMod.updateCategories(response());
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Categories",
              style: context.customTt.numberFontMedium!.copyWith(fontSize: 16),
            ),
            Text(
              categories == null
                  ? "Includes all categories."
                  : "Includes ${categories.length} ${categories.length < 2 ? "category." : "categories."}",
              style: context.customTt.paragraphText,
            ),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     SizedBox(
            //       width: 4,
            //     ),
            //     Expanded(
            //       child:
            //     ),
            //     Checkbox(value: true, onChanged: (val) {}),
            //   ],
            // ),
            if (categories != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Wrap(
                  // alignment: WrapAlignment.spaceBetween,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...categories.map(
                      (el) => CategoryIconContainer(
                        category: el,
                        size: 20,
                      ),
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

class GoalFormTrackingSection extends StatelessWidget {
  const GoalFormTrackingSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final trackingPeriod = context.select(
      (GoalFormViewModel state) => state.draftGoal.goalTracking,
    );
    return RadioGroup<GoalTrackingPeriod>(
      groupValue: trackingPeriod,
      onChanged: (val) {
        if (val == null) return;
        context.goalFormMod.updateTracking(val);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        // spacing: 8,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Divider(),
          ),
          Row(
            children: [
              Text(
                'Goal Tracking',
                style: context.customTt.dateLabel,
                textAlign: TextAlign.left,
              ),
              IconButton(iconSize: 16, onPressed: () {}, icon: Icon(Icons.help_outline)),
            ],
          ),
          Text(
            'Goal Trackin fasdiuflasdjkfhlj sd fjdsklahfg',
            style: context.customTt.paragraphText,
            textAlign: TextAlign.left,
          ),
          SizedBox(
            height: 8,
          ),
          ...GoalTrackingPeriod.values.map((e) {
            return InkWell(
              onTap: () => context.goalFormMod.updateTracking(e),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 8,
                  children: [
                    Radio<GoalTrackingPeriod>(value: e),
                    Expanded(
                      child: Text(
                        e.name.capitalize(),
                        style: context.customTt.numberFontMedium!.copyWith(fontSize: 16),
                      ),
                    ),
                    // Expanded(
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       SizedBox(
                    //         height: 32,
                    //         child: Align(
                    //           alignment: Alignment.centerLeft,
                    //           child: Text(
                    //             e.name.capitalize(),
                    //             style: context.customTt.numberFontSmall!.copyWith(fontSize: 16),
                    //           ),
                    //         ),
                    //       ),
                    //       // Text(e.description, style: context.customTt.paragraphText),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class GoalsTextField extends StatelessWidget {
  const GoalsTextField({
    super.key,
    this.controller,
    required this.fieldLabel,
    this.minLines,
    this.hintText,
  });

  final TextEditingController? controller;
  final String fieldLabel;
  final int? minLines;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      hintText: hintText,
      isDense: true,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(fieldLabel),
        TextFormField(
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.text,
          style: context.tt.bodyMedium!.copyWith(fontSize: 14),
          decoration: inputDecoration,
          controller: controller,
          minLines: minLines ?? 1,
          maxLines: 10,
        ),
      ],
    );
  }
}

class GoalTapTextField extends StatelessWidget {
  const GoalTapTextField({
    super.key,
    this.controller,
    required this.fieldLabel,
    this.minLines,
    this.hintText,
    this.checkbox = false,
    this.checkboxVal,
    this.onTap,
    this.onCheckboxChanged,
  });

  final TextEditingController? controller;
  final String fieldLabel;
  final int? minLines;
  final String? hintText;
  final bool checkbox;
  final bool? checkboxVal;

  final GestureTapCallback? onTap;

  final ValueChanged<bool?>? onCheckboxChanged;

  bool get active => !checkbox || (checkbox && checkboxVal == true);
  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: active,
      hintText: hintText,
      isDense: true,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => checkbox ? onCheckboxChanged?.call(!(checkboxVal ?? false)) : null,
          child: Row(
            children: [
              if (checkbox)
                SizedBox(
                  height: 16,
                  width: 20,
                  child: Transform.scale(
                    scale: 0.8,
                    child: Checkbox(value: checkboxVal ?? false, onChanged: onCheckboxChanged),
                  ),
                ),
              if (checkbox)
                SizedBox(
                  width: 10,
                ),
              Text(fieldLabel),
            ],
          ),
        ),
        TextFormField(
          onTap: active ? onTap : null,
          readOnly: true,
          style: context.tt.bodyMedium!.copyWith(
            fontSize: 14,
            color: active ? null : context.customCs.fadeColor2,
          ),
          decoration: inputDecoration,
          controller: controller,
          minLines: minLines ?? 1,
          maxLines: 10,
        ),
      ],
    );
  }
}

class GoalsDropDownField extends StatelessWidget {
  const GoalsDropDownField({
    super.key,
    this.controller,
    this.onSelected,
    this.showCheckbox = false,
    this.checkboxValue,
    this.onCheckboxValueChanged,
    required this.values,
    required this.selectedValue,
    required this.fieldLabel,
  });

  final TextEditingController? controller;
  final String fieldLabel;
  final List<String> values;
  final String selectedValue;
  final ValueChanged<Object?>? onSelected;
  final bool showCheckbox;
  final bool? checkboxValue;
  final ValueChanged<bool?>? onCheckboxValueChanged;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.customCs.fadeColor2 ?? Colors.transparent),
    );

    final inputDecoTheme = InputDecorationTheme(
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      isDense: false,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      filled: !showCheckbox || (showCheckbox && checkboxValue == true),
      fillColor: context.customCs.fadeColor4,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Row(
          spacing: 12,
          children: [
            if (showCheckbox)
              Transform.scale(
                scale: 0.8,
                child: Checkbox(value: checkboxValue, onChanged: onCheckboxValueChanged),
              ),
            Text(fieldLabel),
          ],
        ),
        DropdownMenu(
          showTrailingIcon: true,
          // width: 160,
          enabled: showCheckbox ? checkboxValue == true : true,
          textStyle: context.customTt.paragraphTitle,
          expandedInsets: EdgeInsets.zero,
          // menuStyle: MenuStyle(),
          menuStyle: MenuStyle(
            visualDensity: VisualDensity.comfortable,
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
            // fixedSize: WidgetStatePropertyAll(Size.fromWidth(160)),
            backgroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 42, 42, 44)),
          ),
          inputDecorationTheme: inputDecoTheme,
          initialSelection: selectedValue,
          onSelected: onSelected,
          dropdownMenuEntries:
              values.map((e) => DropdownMenuEntry(value: e, label: e.toString())).toList(),
        ),
      ],
    );
  }
}

class DateDialog extends StatefulWidget {
  const DateDialog({super.key, this.initDate});

  final DateTime? initDate;
  @override
  State<DateDialog> createState() => _DateDialogState();
}

class _DateDialogState extends State<DateDialog> {
  int _monthIndex = 0;
  int _yearIndex = 0;

  static List<String> monthList = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];
  final yearList = List.generate(11, (i) {
    final el = DateTime.now().year + i - 5;
    return el.toString();
  });

  DateTime get selectedYearMonth => DateFormat(
    "MMMM yyyy",
  ).parse('${monthList.elementAt(_monthIndex)} ${yearList.elementAt(_yearIndex)}');

  @override
  void initState() {
    super.initState();

    if (widget.initDate != null) {
      _monthIndex = monthList.indexWhere(
        (month) => month == DateFormat('MMMM').format(widget.initDate!),
      );
      _yearIndex = yearList.indexWhere((year) => year == widget.initDate!.year.toString());
    }
    debugPrint('$_monthIndex, $_yearIndex');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Start Month"),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 140,
            width: 100,
            child: CarouselSlider(
              options: CarouselOptions(
                initialPage: _monthIndex,
                enableInfiniteScroll: true,
                height: 70,
                aspectRatio: 4 / 3,
                viewportFraction: 0.2,
                onPageChanged: (index, reason) {
                  setState(() => _monthIndex = index);
                },
                scrollDirection: Axis.vertical,
              ),
              items: [
                ...monthList.mapIndexed(
                  (i, month) {
                    final isCurrent = i == _monthIndex;
                    final isAdjacent =
                        (i == (_monthIndex + 1) % 12) || (i == (_monthIndex + 12 - 1) % 12);
                    return Center(
                      child: AnimatedScale(
                        scale: isCurrent ? 1.1 : 0.9,
                        duration: Durations.short4,
                        curve: Curves.easeOut,
                        child: Text(
                          month,
                          style: context.tt.bodyMedium!.copyWith(
                            color:
                                isCurrent
                                    ? Colors.white
                                    : Colors.white.withAlpha(isAdjacent ? 100 : 50),
                            fontSize: 18,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 140,
            width: 100,
            child: CarouselSlider(
              options: CarouselOptions(
                initialPage: _yearIndex,
                enableInfiniteScroll: false,
                height: 70,
                aspectRatio: 4 / 3,
                viewportFraction: 0.2,
                onPageChanged: (index, reason) {
                  setState(() => _yearIndex = index);
                },
                scrollDirection: Axis.vertical,
              ),
              items: [
                ...yearList.mapIndexed(
                  (i, month) {
                    final isCurrent = i == _yearIndex;
                    final isAdjacent = i == _yearIndex + 1 || i == _yearIndex - 1;
                    return Center(
                      child: AnimatedScale(
                        scale: isCurrent ? 1.1 : 0.9,
                        duration: Durations.short4,
                        curve: Curves.easeOut,
                        child: Text(
                          month,
                          style: context.tt.bodyMedium!.copyWith(
                            color:
                                isCurrent
                                    ? Colors.white
                                    : Colors.white.withAlpha(isAdjacent ? 100 : 50),
                            fontSize: 18,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        DismissTextButton(
          text: "Cancel",
          onTap: context.pop,
        ),
        AffirmativeTextButton(
          text: "Confirm",
          onTap: () => context.pop(selectedYearMonth),
        ),
      ],
    );
  }
}

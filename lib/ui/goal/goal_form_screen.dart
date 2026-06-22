import 'package:budget_tracker/custom/classes/goal_category.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/goal/goal_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GoalFormScreen extends StatelessWidget {
  const GoalFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GoalTypeSelectionScreen();
  }
}

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
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(12.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Page 1 of 3"),
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
            ),
            SliverList.builder(
              itemCount: goalCategories.length,
              itemBuilder: (context, index) {
                final category = goalCategories.elementAt(index);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ReusableContainer(
                    onTap:
                        () => context.nav.push(
                          MaterialPageRoute(
                            builder:
                                (context) => ChangeNotifierProvider(
                                  create:
                                      (context) => GoalFormViewmodel(
                                        goalRepository: context.read(),
                                        goalCategory: category,
                                      ),
                                  child: const GoalInfoFormScreen(),
                                ),
                          ),
                        ),
                    padding: EdgeInsets.all(20),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GoalInfoFormScreen extends StatelessWidget {
  const GoalInfoFormScreen({super.key});

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
                if (context.goalFormMod.isEditMode) {
                  await context.goalFormMod.updateGoal();
                  context.nav.pushNamedAndRemoveUntil('/goals', ModalRoute.withName('/goals'));
                  context.showSuccessNotification(message: "Goal updated!");
                } else {
                  await context.goalFormMod.createGoal();
                  context.nav.pushNamedAndRemoveUntil('/goals', ModalRoute.withName('/goals'));
                  context.showSuccessNotification(message: "New goal created!");
                }
              }
            },
            icon: Icon(Icons.check),
          ),
          IconButton(
            onPressed: () async {
              await context.goalFormMod.deleteGoal();
              context.nav.pushNamedAndRemoveUntil('/goals', ModalRoute.withName('/goals'));
              context.showSuccessNotification(message: "Goal deleted!");
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: SafeArea(
        minimum: EdgeInsets.fromLTRB(12, 12, 12, 20),
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
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _titleController;
  late final TextEditingController _targetController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _startDateController = TextEditingController(
      text: DateFormat("MMMM yyyy").format(context.goalFormMod.startDate),
    );
    _endDateController = TextEditingController(
      text: DateFormat("MMMM yyyy").format(context.goalFormMod.endDate),
    );

    _titleController = TextEditingController(
      // text: context.goalFormMod.title,
      text: context.goalFormMod.title,
    )..addListener(() {
      context.goalFormMod.updateTitle(_titleController.text);
    });
    _descController = TextEditingController(
      text: context.goalFormMod.description,
    )..addListener(() {
      context.goalFormMod.updateDesc(_descController.text);
    });
    _targetController = TextEditingController(
      text: context.goalFormMod.target?.toStringAsFixed(2),
    )..addListener(() {
      context.goalFormMod.updateTarget(_targetController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final goalType = context.select((GoalFormViewmodel state) => state.goalType);
    final trackingPeriod = context.select((GoalFormViewmodel state) => state.trackingPeriod);
    final mainSubtitle = switch (goalType) {
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
                      // prefixStyle: context.customTt.elegantLabelLarge?.copyWith(
                      //   fontSize: 50,
                      //   color: context.cs.surface,
                      // ),
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
            child: GoalsDropDownField(
              fieldLabel: "From",
              controller: _startDateController,
              values: ["This Month", "Custom"],
              selectedValue: "What",
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          sliver: SliverToBoxAdapter(
            child: GoalsDropDownField(
              fieldLabel: "End",
              controller: _endDateController,
              values: ["Specific Month", "After n Months"],
              selectedValue: "What",
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
              child: RadioGroup<GoalTrackingPeriod>(
                groupValue: trackingPeriod,
                onChanged: (val) {
                  if (val == null) return;
                  context.goalFormMod.updateTracking(val);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Divider(),
                    ),
                    Text(
                      'Goal Tracking',
                      style: context.customTt.dateLabel,
                      textAlign: TextAlign.left,
                    ),
                    ...GoalTrackingPeriod.values.map((e) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Radio<GoalTrackingPeriod>(value: e),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 30,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      e.name.capitalize(),
                                      style: context.customTt.paragraphTitle,
                                    ),
                                  ),
                                ),
                                Text(e.description, style: context.customTt.paragraphText),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        if (_openAdvanced)
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            sliver: SliverToBoxAdapter(
              child: RadioGroup(
                onChanged: (val) {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Item Filter',
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
                        ReusableContainer(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Category"),
                              Text(
                                "Include all categories.",
                                style: context.customTt.paragraphText,
                              ),
                            ],
                          ),
                        ),
                        ReusableContainer(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Item Description"),
                              Text(
                                "Include all item descriptions.",
                                style: context.customTt.paragraphText,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
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
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.customCs.fadeColor2 ?? Colors.transparent),
    );

    final inputDecoration = InputDecoration(
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      hintText: hintText,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      visualDensity: VisualDensity.comfortable,
      fillColor: context.customCs.fadeColor4,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(fieldLabel),
        TextFormField(
          // enabled: checkboxValue,
          // keyboardType: keyboardType,
          // onTap: onTap,
          // textAlign: textAlign,
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

    final inputDecoration = InputDecoration(
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      isDense: false,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      fillColor: context.customCs.fadeColor4,
    );

    final inputDecoTheme = InputDecorationTheme(
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      isDense: false,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      fillColor: context.customCs.fadeColor4,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Row(
          spacing: 12,
          children: [
            if (showCheckbox) Checkbox(value: checkboxValue, onChanged: onCheckboxValueChanged),
            Text(fieldLabel),
          ],
        ),
        Row(
          spacing: 12,
          children: [
            Flexible(
              flex: 3,
              fit: FlexFit.tight,
              child: DropdownMenu(
                enabled: showCheckbox ? checkboxValue == true : true,
                textStyle: context.customTt.paragraphTitle,
                expandedInsets: EdgeInsets.zero,
                // menuStyle: MenuStyle(),
                inputDecorationTheme: inputDecoTheme,
                initialSelection: selectedValue,
                onSelected: onSelected,
                dropdownMenuEntries:
                    values.map((e) => DropdownMenuEntry(value: e, label: e.toString())).toList(),
              ),
            ),
            Flexible(
              flex: 3,
              fit: FlexFit.tight,
              child: TextFormField(
                enabled: false,
                readOnly: true,
                // enabled: checkboxValue,
                // keyboardType: keyboardType,
                // onTap: onTap,
                // textAlign: textAlign,
                style: context.tt.bodyMedium!.copyWith(fontSize: 14),
                decoration: inputDecoration,
                controller: controller,
              ),
            ),
            Flexible(flex: 1, fit: FlexFit.tight, child: SizedBox()),
          ],
        ),
      ],
    );
  }
}

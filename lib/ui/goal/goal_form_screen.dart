import 'package:budget_tracker/custom/classes/goal_category.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/goal/goal_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GoalFormScreen extends StatelessWidget {
  const GoalFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoalFormViewmodel(goalRepository: context.read()),
      child: const GoalTypeSelectionScreen(),
    );
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
                    Text(_goalType.description, style: context.customTt.paragraphText,),
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
                          MaterialPageRoute(builder: (context) => GoalInfoFormScreen()),
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
    final goalType = context.select((GoalFormViewmodel state) => state.goalType);
    return ChangeNotifierProvider(
      create: (context) => GoalFormViewmodel(goalRepository: context.read()),
      child: const GoalInfoFormBody(),
    );
  }
}

class GoalInfoFormBody extends StatelessWidget {
  const GoalInfoFormBody ({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
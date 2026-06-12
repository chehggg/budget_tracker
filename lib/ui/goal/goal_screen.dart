import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/goal/goal_form_screen.dart';
import 'package:budget_tracker/ui/goal/goal_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GoalScreen extends StatelessWidget {
  const GoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GoalFormScreen()),
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(child: GoalBody()),
    );
  }
}

class GoalBody extends StatelessWidget {
  const GoalBody({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = context.select((GoalModel state) => state.goalOverview);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: ReusableContainer(
              child: Text("There is ${goals.length} goals!"),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            goals.entries
                .map(
                  (e) => ReusableContainer(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GoalFormScreen()),
                      );
                    },
                    child: Column(
                      children: [
                        Text(e.key.title ?? "Untitled Goal"),
                        Row(
                          children: [
                            Text(
                              e.key.description ?? "This is a descriptiondfahkljhl sjdhflhasj",
                            ),
                            Text(
                              e.value.progress.toString(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

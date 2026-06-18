import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/goal/goal_form_screen.dart';
import 'package:budget_tracker/ui/goal/goal_view_model.dart';
import 'package:budget_tracker/ui/list/list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GoalScreen extends StatelessWidget {
  const GoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // return ChangeNotifierProvider(
    //   create: (context) => GoalModel(costItemRepo: context.read(), goalRepository: context.read()),
    //   child: Scaffold(
    //     appBar: AppBar(
    //       actions: [
    //         IconButton(
    //           onPressed: () async {
    //             await Navigator.push(
    //               context,
    //               MaterialPageRoute(builder: (context) => const GoalFormScreen()),
    //             );
    //           },
    //           icon: Icon(Icons.add),
    //         ),
    //       ],
    //     ),
    //     body: SafeArea(child: GoalBody()),
    //   ),
    // );
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await context.nav.push(
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
    // final dynamic model = Provider.of(context, listen: false);
    // debugPrint("Found provider runtime type: ${model.runtimeType}");
    final ready = context.select((GoalModel state) => state.ready);
    // final goals = context.select((GoalModel state) => state.goalOverview);
    final goals = {};
    final test = context.select((ListModel state) => state.currentMonth);
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

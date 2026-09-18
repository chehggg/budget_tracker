import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class GroupSettingsScreen extends StatelessWidget {
  const GroupSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBarTitle: Text("Cost Group"),
      actions: [
        IconButton(
          icon: FaIcon(FontAwesomeIcons.plus),
          onPressed: () async {
            final response = await context.push('/settings/group-details');
          },
        ),
      ],
      child: CustomScrollView(
        slivers: [
          if (context.groupMod.groups.isEmpty)
            SliverToBoxAdapter(
              child: Text(
                "Add a group to track a subset of expenses or an isolated budget (i.e., travel expenses etc.)",
                style: context.customTt.paragraphTextSmall,
              ),
            ),
          if (context.groupMod.groups.isNotEmpty)
            SliverList(
              delegate: SliverChildListDelegate([
                ...context.groupMod.groups.map(
                  (e) => ListTile(
                    title: Text(e.name ?? ""),
                    subtitle: Text(e.description ?? ""),
                    onTap: () {
                      context.push('/settings/group-details');
                    },
                  ),
                ),
              ]),
            ),
        ],
      ),
    );
  }
}

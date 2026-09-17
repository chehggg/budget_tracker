import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GroupSettingsScreen extends StatelessWidget {
  const GroupSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBarTitle: Text("Cost Group"),
      actions: [
        IconButton(
          icon: FaIcon(FontAwesomeIcons.plus),
          onPressed: () {},
        ),
      ],
      child: CustomScrollView(
        slivers: [
          if (context.groupMod.groups.isEmpty)
            SliverToBoxAdapter(
              child: Text("You have no group"),
            ),
          if (context.groupMod.groups.isNotEmpty)
            SliverList(
              delegate: SliverChildListDelegate([
                ...context.groupMod.groups.map(
                  (e) => ListTile(
                    title: Text(e.name ?? ""),
                    subtitle: Text(e.description ?? ""),
                    onTap: () {},
                  ),
                ),
              ]),
            ),
        ],
      ),
    );
  }
}

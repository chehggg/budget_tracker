import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/group/group_settings_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GroupSettingsScreen extends StatelessWidget {
  const GroupSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = context.select((GroupSettingsViewModel state) => state.groups);
    final contextWatch = context.watch<GroupSettingsViewModel>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        context.navMod.toggleFab(show: true);
        context.pop();
      },
      child: CustomScaffold(
        appBarTitle: Text("Cost Group"),
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.plus),
            onPressed: () async {
              final response = await context.push('/settings/group-form');
            },
          ),
        ],
        child:
            groups.isEmpty
                ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 10,
                    children: [
                      Text(
                        "You have no budget group as of now.",
                        style: context.customTt.paragraphTextSmall,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "Add a group to track a subset of expenses\n or an isolated budget (i.e., travel expenses etc.)",
                        style: context.customTt.paragraphTextSmall,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextButton(
                        onPressed: () async {
                          await context.push('/settings/group-form');
                        },
                        child: Text("Add group"),
                      ),
                    ],
                  ),
                )
                : CustomScrollView(
                  slivers: [
                    if (context.groupMod.groups.isNotEmpty)
                      SliverList(
                        delegate: SliverChildListDelegate([
                          ...groups.map(
                            (group) => ReusableContainer(
                              showBorder: false,
                              padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          group.name ?? "",
                                          style: context.customTt.numberFontSmall,
                                        ),
                                      ),
                                      Text(
                                        context.groupMod.currencyFormat(
                                          context.groupMod.getMetricFromGroup(group).balance,
                                          customIso: group.currency
                                          // showSymbol: false,
                                          // compact: true,
                                        ),
                                        style: context.customTt.paragraphText,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    group.description ?? "",
                                    style: context.customTt.paragraphText,
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Divider(),
                                ],
                              ),
                              onTap: () {
                                context.push('/settings/group-details', extra: group);
                              },
                            ),
                          ),
                        ]),
                      ),
                  ],
                ),
      ),
    );
  }
}

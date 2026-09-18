import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/ui/settings/group_settings_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GroupSettingsScreen extends StatelessWidget {
  const GroupSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final curValue = context.select((GroupSettingsViewModel state) => state.draft);
    return CustomScaffold(
      appBarTitle: Text("Add Cost Group"),
      bottomSheet: BottomSheet(
        enableDrag: false,
        onClosing: () {},
        builder: (context) {
          return SizedBox(
            child: Row(
              children: [
                Expanded(
                  child: AffirmativeTextButton(
                    onTap: () async {
                      final addResponse = await context.groupMod.addGroup();
                      if (context.mounted) {
                        if (addResponse != null) {
                          context.showErrorNotification(message: addResponse);
                        } else {
                          context.pop(true);
                        }
                      }
                    },
                  ),
                ),
                Expanded(
                  child: DismissTextButton(
                    onTap: () {
                      context.pop(false);
                    },
                  ),
                ),
              ],
            ),
          );
          // return BottomSheetButtons();
        },
      ),
      actions: [
        IconButton(
          icon: FaIcon(FontAwesomeIcons.plus),
          onPressed: () {},
        ),
      ],
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              CustomTextField(
                fieldLabel: "Name",
                onChanged: context.groupMod.updateGroupName,
              ),
              CustomTextField(
                fieldLabel: "Description",
                onChanged: context.groupMod.updateGroupDesc,
              ),
              CustomSwitchListTile(
                title: "Add item to main group",
                value: curValue.addToMain ?? false,
                onSelected: context.groupMod.toggleAddToMain,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

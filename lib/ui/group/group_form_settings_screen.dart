import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/ui/group/group_form_viewmodel.dart';
import 'package:budget_tracker/ui/settings/settings_screen.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:money2/money2.dart';
import 'package:provider/provider.dart';

class GroupFormSettingsScreen extends StatelessWidget {
  const GroupFormSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctxWatch = context.watch<GroupFormViewModel>();
    final draft = ctxWatch.draft;
    return CustomScaffold(
      ready: ctxWatch.isInit,
      appBarTitle: Text("Add Cost Group"),
      bottomSheet: BottomSheet(
        enableDrag: false,
        onClosing: () {},
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(30),
            child: Row(
              spacing: 12,
              children: [
                if (context.groupFormsMod.isEditMode)
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: CustomTextButton(
                      bgColor: Colors.red.shade800.withAlpha(50),
                      fgColor: Colors.red,
                      borderColor: Colors.red.shade800,
                      inverse: false,
                      icon: FontAwesomeIcons.trash,
                      text: "Delete",
                      onTap: () async {
                        await context.groupFormsMod.deleteGroup();
                        if (context.mounted) {
                          context.go('/settings/groups');
                          context.showSuccessNotification(message: "Group deleted!");
                        }
                      },
                    ),
                  ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 2,
                  child: CustomTextButton(
                    bgColor: context.cs.secondary,
                    inverse: true,
                    icon: FontAwesomeIcons.solidFloppyDisk,
                    text: context.groupFormsMod.isEditMode ? "Update Group" : "Create Group",
                    onTap: () async {
                      final response = await context.groupFormsMod.submitGroup();

                      if (response != null) {
                        context.showErrorNotification(message: response);
                      } else {
                        context.go('/settings/groups');
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
                child: CustomTextField(
                  initialValue: draft.name ?? "",
                  fieldLabel: "Name",
                  onChanged: context.groupFormsMod.updateGroupName,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
                child: CustomTextField(
                  initialValue: draft.description ?? "",
                  fieldLabel: "Description",
                  minLines: 2,
                  onChanged: context.groupFormsMod.updateGroupDesc,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Divider(
                height: 30,
              ),
              CustomSettingsTile(
                titleWidget: Text("Currency", style: context.customTt.paragraphTitle),
                trailingWidget: Text(
                  ctxWatch.currencyName,
                  style: context.customTt.paragraphTitle,
                ),
                onTap: () async {
                  final Currency? response = await context.push('settings/group-currency');
                  if (response != null && context.mounted) {
                    context.groupFormsMod.updateCurrency(response);
                  }
                },
              ),
              CustomSwitchListTile(
                enabled: ctxWatch.currencyName == "Default",
                title: "Automatically add item to main",
                value: draft.addToMain ?? false,
                onSelected: context.groupFormsMod.toggleAddToMain,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/form/form_screen.dart';
import 'package:budget_tracker/ui/group/group_details_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GroupDetailsScreen extends StatelessWidget {
  const GroupDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final curGroup = context.select((GroupDetailsViewModel state) => state.group);
    // final noItem = curGroup.items?.isEmpty ?? true;

    void goToForm() {
      context.push('form', extra: FormArgument(costGroup: curGroup));
    }

    return CustomScaffold(
      appBarTitle: Text("Cost Group Details"),
      actions: [
        IconButton(icon: FaIcon(FontAwesomeIcons.plus), iconSize: 18, onPressed: goToForm),
        CustomMenuAnchor(
          animated: true,
          items: [
            MenuChild(
              icon: FontAwesomeIcons.pencil,
              name: "Edit",
              onTap: () async {
                context.push('settings/group-form', extra: curGroup);
              },
            ),
            MenuChild(
              onTap: () async {
                final resposne = await context.push('/settings/group-add', extra: curGroup);
                // final response = await showDialog(
                //   context: context,
                //   builder: (context) {
                //     return DeleteItemDialog();
                //   },
                // );
                // if (response == true && context.mounted) {
                //   await context.groupDetailsMod.deleteGroup();
                //   if (context.mounted) {
                //     context.showSuccessNotification(message: "Group deleted!");
                //   }
                // }
              },
              // color: Colors.red,
              icon: FontAwesomeIcons.squarePlus,
              name: "Add to main",
            ),
            MenuChild(
              onTap: () async {
                final response = await showDialog(
                  context: context,
                  builder: (context) {
                    return DeleteItemDialog();
                  },
                );
                if (response == true && context.mounted) {
                  await context.groupDetailsMod.deleteGroup();
                  if (context.mounted) {
                    context.go('/settings/groups');
                    context.showSuccessNotification(message: "Group deleted!");
                  }
                }
              },
              color: Colors.red,
              icon: FontAwesomeIcons.trash,
              name: "Delete",
            ),
          ],
        ),
      ],
      child: CustomScrollView(
        // physics: noItem ? NeverScrollableScrollPhysics() : ScrollPhysics(),
        // shrinkWrap: !noItem,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  curGroup.name ?? "",
                  style: context.customTt.elegantLabelLarge,
                ),
                Text(
                  curGroup.description ?? "",
                  style: context.customTt.paragraphTitle,
                ),
                SizedBox(
                  height: 20,
                ),
                ReusableContainer(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  highlight: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Balance",
                        style: context.customTt.paragraphTitle!.copyWith(
                          color: context.customCs.onFlipCard,
                        ),
                      ),
                      Row(
                        spacing: 12,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            context.groupDetailsMod.currencyFormat(
                              context.groupDetailsMod.groupCostMetric.balance,
                              customIso: curGroup.currency,
                              compact: true,
                            ),
                            style: context.customTt.numberFontLarge!.copyWith(
                              color: context.customCs.onFlipCard,
                              height: 1.2,
                            ),
                          ),
                          // SizedBox(width: 10),
                          Text(
                            context.groupDetailsMod.currencyFormat(
                              context.groupDetailsMod.groupCostMetric.income ?? 0,
                              customIso: curGroup.currency,
                              alwaysShowSign: true,
                              showSymbol: false,
                              compact: true,
                            ),
                            style: context.customTt.numberFontSmall!.copyWith(
                              color: context.groupDetailsMod.accentColor.positive,
                            ),
                          ),
                          Text(
                            context.groupDetailsMod.currencyFormat(
                              (context.groupDetailsMod.groupCostMetric.expense ?? 0) * -1,
                              customIso: curGroup.currency,
                              alwaysShowSign: true,
                              showSymbol: false,
                              compact: true,
                            ),
                            style: context.customTt.numberFontSmall!.copyWith(
                              color: context.groupDetailsMod.accentColor.negative,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          // if (curGroup.items?.isEmpty ?? true)
          //   SliverToBoxAdapter(
          //     child: SizedBox(
          //       height: context.mq.size.height * 0.6,
          //       child: Center(
          //         child: Column(
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             Text(
          //               "No cost item yet!",
          //               style: context.customTt.paragraphText,
          //             ),
          //             TextButton(
          //               onPressed: goToForm,
          //               child: Text("Add cost item"),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 12,
            ),
          ),
          SliverList.builder(
            itemCount: context.groupDetailsMod.items.length,
            itemBuilder: (context, index) {
              final item = context.groupDetailsMod.items.elementAt(index);
              return ReusableContainer(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                showBorder: false,
                child: Row(
                  spacing: 10,
                  children: [
                    SizedBox(
                      width: context.mq.size.width * 0.22,
                      child: Text(
                        item.date?.formatPrettyShort() ?? "",
                        style: context.customTt.paragraphTextSmall!.copyWith(fontSize: 14),
                      ),
                    ),
                    SizedBox(
                      width: context.mq.size.width * 0.55,
                      child: Text(
                        item.name ?? "",
                        style: context.customTt.paragraphTitle!.copyWith(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.amount != null
                            ? context.groupDetailsMod.currencyFormat(
                              item.amount!,
                              customIso: curGroup.currency,
                            )
                            : "",
                        style: context.customTt.paragraphTitle!.copyWith(fontSize: 14),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/settings/group_details_viewmodel.dart';
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
    return CustomScaffold(
      appBarTitle: Text("Cost Group Details"),
      actions: [
        IconButton(
          icon: FaIcon(FontAwesomeIcons.plus),
          onPressed: () {
            context.push('form', extra: FormArgument(costGroup: curGroup));
          },
        ),
      ],
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: Text(curGroup.name ?? "")),
          ReusableContainer(
            child: Row(
              children: [
                Text(
                  context.groupDetailsMod.currencyFormat(
                    curGroup.metric.balance,
                  ),
                ),
                Text(
                  context.groupDetailsMod.currencyFormat(
                    curGroup.metric.income ?? 0,
                  ),
                ),
                Text(
                  context.groupDetailsMod.currencyFormat(
                    curGroup.metric.expense ?? 0,
                  ),
                ),
              ],
            ),
          ),
          SliverList.builder(
            itemCount: curGroup.items?.length,
            itemBuilder: (context, index) {
              final item = curGroup.items?.elementAt(index);
              return ReusableContainer(
                showBorder: false,
                child: Row(
                  children: [
                    Expanded(child: Text(item?.name ?? "")),
                    Text(
                      item?.amount != null
                          ? context.groupDetailsMod.currencyFormat(item!.amount!)
                          : "",
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

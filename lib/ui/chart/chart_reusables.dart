import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/ui/chart/chart_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomChartDetailTitleBar extends StatelessWidget {
  const CustomChartDetailTitleBar({super.key, this.title = ""});
  final String title;

  @override
  Widget build(BuildContext context) {
    final displayPeriodDuration = context.select(
      (ChartViewModel state) => state.displayPeriodDuration,
    );
    final range = context.select(
      (ChartViewModel state) => state.displayDetailsPeriodDuration,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(
          title,
          style: context.customTt.numberFontLarge?.copyWith(
            fontSize: 36,
            height: 1.2,
          ),
        ),
        Row(
          spacing: 12,
          children: [
            Text(
              "View: $displayPeriodDuration",
              style: context.customTt.paragraphTitle,
            ),
            Text(
              "($range)",
              style: context.customTt.paragraphText,
            ),
          ],
        ),
        // SizedBox(height: 20,)
        // Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(),)
        // TextButton(
        //   onPressed: () {},
        //   child: Text(
        //     "Change view",
        //     textAlign: TextAlign.left,
        //   ),
        // ),
      ],
    );
  }
}

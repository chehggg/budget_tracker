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
      (ChartViewModel state) => state.curDisplayPeriod,
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

class LabelIndicator extends StatelessWidget {
  const LabelIndicator({super.key, required this.text, this.color, this.fade = false});

  final String text;
  final Color? color;
  final bool fade;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color,
          ),
        ),
        SizedBox(width: 6),
        Text(
          text,
          style: context.tt.bodyMedium!.copyWith(
            fontSize: 12,
            color: fade ? context.customCs.fadeColor1 : context.cs.primary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

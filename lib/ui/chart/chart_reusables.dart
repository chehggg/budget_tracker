import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/ui/chart/chart_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class CustomChartDetailTitleBar extends StatelessWidget {
  const CustomChartDetailTitleBar({
    super.key,
    this.title = "",
    this.dialogTitle = "",
    this.dialogDescription,
  });
  final String title;
  final String dialogTitle;
  final Text? dialogDescription;

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
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: context.customTt.numberFontLarge?.copyWith(
                  fontSize: 36,
                  height: 1.2,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(title: Text(dialogTitle), content: dialogDescription);
                  },
                );
              },
              icon: FaIcon(FontAwesomeIcons.circleQuestion),
            ),
          ],
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
        SizedBox(
          height: 6,
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
  const LabelIndicator({
    super.key,
    required this.text,
    this.color,
    this.fade = false,
    this.fadeAll = false,
  });

  final String text;
  final Color? color;
  final bool fade;
  final bool fadeAll;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: fadeAll ? 0.5 : 1,
      child: Row(
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
      ),
    );
  }
}

class ChartBottomTitleLabel extends StatelessWidget {
  const ChartBottomTitleLabel({
    super.key,
    required this.value,
    this.isMatch = false,
    this.useChartModel = false,
  });

  final bool isMatch;
  final bool useChartModel;
  final double value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Transform.scale(
        scale: isMatch ? 1.2 : 1,
        alignment: Alignment.center,
        child: Text(
          useChartModel
              ? context.chartMod.getInitials(
                value.round(),
                useInitials: true,
                useDotForMonth: true,
              )
              : "•",
          style: context.tt.bodyMedium!.copyWith(
            fontSize: 10,
            color: context.cs.primary.withAlpha(isMatch ? 250 : 100),
            fontWeight: FontWeight(600),
          ),
        ),
      ),
    );
  }
}

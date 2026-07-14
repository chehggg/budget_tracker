import 'package:budget_tracker/widgets.dart';
import 'package:flutter/material.dart';

class LineChartDetailsScreen extends StatelessWidget {
  const LineChartDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBarTitle: Text("Day to day chart"),
      actions: [],
      child: CustomScrollView(
        slivers: [SliverList(delegate: SliverChildListDelegate([]))],
      ),
    );
  }
}

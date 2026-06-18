import 'package:budget_tracker/ui/list/list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = context.select((ListModel state) => state.currentMonth.toIso8601String());
    return Text(text);
  }
}
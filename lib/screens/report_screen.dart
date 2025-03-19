import 'package:budget_tracker/models/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CostReportScreen extends StatelessWidget {
  const CostReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report"),
        // backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: CostReport()
      ),
    );
  }
}

class CostReport extends StatelessWidget {
  const CostReport({super.key});

  @override
  Widget build(BuildContext context) {
    final reportData = context.select((AppModel state) => state.monthlyOverview,);
    return DataTable(
      columns: [
        DataColumn(
          label: const Text("Month")
        ),
        DataColumn(
          label: Text(AppLocalizations.of(context)!.expense)
        ),
        DataColumn(
          label: Text(AppLocalizations.of(context)!.income)
        ),
        DataColumn(
          label: Text(AppLocalizations.of(context)!.balance)
        ),
      ]
      , 
      rows: reportData.map((monthlyData) {
        return DataRow(
          cells: [
            DataCell(Text(monthlyData['month'])),
            DataCell(Text((monthlyData['expense'] as double).toString()) ),
            DataCell(Text((monthlyData['income'] as double).toString())),
            DataCell(Text((monthlyData['balance'] as double).toString())),
          ]
        );
      }).toList()
    );
  }
}
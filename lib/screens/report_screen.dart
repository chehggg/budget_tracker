import 'package:budget_tracker/models/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final reportData = context.select((AppModel state) => state.yearMonthOverview,);
    return DataTable(
      columns: [
        DataColumn(
          label: const Text("Month")
        ),
        DataColumn(
          // label: Text(AppLocalizations.of(context)!.expense)
          label: Text("Expense")
        ),
        DataColumn(
          // label: Text(AppLocalizations.of(context)!.income)
          label: Text("Income")
        ),
        DataColumn(
          // label: Text(AppLocalizations.of(context)!.balance)
          label: Text("Balance")
        ),
      ]
      , 
      rows: reportData.entries.toList().map((data) {
        return DataRow(
          cells: [
            DataCell(Text(data.key)),
            DataCell(Text(context.read<AppModel>().customCurrencyFormat(data.value.expense!, false))),
            DataCell(Text(context.read<AppModel>().customCurrencyFormat(data.value.income!, false))),
            DataCell(Text(context.read<AppModel>().customCurrencyFormat(data.value.balance!, false))),
          ]
        );
      }).toList()
    );
  }
}
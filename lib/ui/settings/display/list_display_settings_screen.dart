import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/data/repos/shared_element_repository.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListDisplaySettingsScreen extends StatefulWidget {
  const ListDisplaySettingsScreen({super.key});

  @override
  State<ListDisplaySettingsScreen> createState() => _ListDisplaySettingsScreenState();
}

class _ListDisplaySettingsScreenState extends State<ListDisplaySettingsScreen> {
  late ListDisplayConfig _config;
  bool _hideAmount = false;
  bool _showAmountColor = true;
  bool _showTotalColor = true;
  bool _syncDate = false;

  @override
  void initState() {
    super.initState();
    final config = context.read<SharedElementRepository>().listScreenConfig;
    _hideAmount = config.hideAmountOnStart;
    _showAmountColor = config.showAmountColor;
    _showTotalColor = config.showTotalColor;
    _syncDate = context.read<SharedElementRepository>().syncDate;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("display rebuilt");
    final repoRead = context.read<SharedElementRepository>();
    return Scaffold(
      appBar: AppBar(title: Text("Title")),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  CustomSwitchListTile(
                    title: "Hide amount on App Start",
                    value: _hideAmount,
                    onSelected: (value) {
                      setState(() {
                        _hideAmount = value;
                        repoRead.toggleHideOnStart(value);
                      });
                    },
                  ),
                  CustomSwitchListTile(
                    title: "+/- Color for item amount",
                    value: _showAmountColor,
                    onSelected: (value) {
                      setState(() {
                        _showAmountColor = value;
                        repoRead.toggleShowAmountColor(value);
                      });
                    },
                  ),
                  CustomSwitchListTile(
                    title: "+/- Color for daily amount",
                    value: _showTotalColor,
                    onSelected: (value) {
                      setState(() {
                        _showTotalColor = value;
                        repoRead.toggleShowTotalColor(value);
                      });
                    },
                  ),
                  CustomSwitchListTile(
                    title: "Sync date in list & chart screen",
                    value: _syncDate,
                    onSelected: (value) {
                      setState(() {
                        _syncDate = value;
                        repoRead.toggleSyncDate(value);
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

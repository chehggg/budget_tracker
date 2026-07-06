import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/ui/settings/additional_currency_settings_viewmodel.dart';
import 'package:budget_tracker/ui/settings/settings_screen.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:money2/src/currency.dart';
import 'package:provider/provider.dart';

class AdditionalCurrencySettingScreen extends StatelessWidget {
  const AdditionalCurrencySettingScreen({super.key});

  static Map<String, String> separators = {
    ".": "Dot (.)",
    ",": "Comma (,)",
  };

  @override
  Widget build(BuildContext context) {
    final modelWatch = context.watch<AdditionalCurrencySettingsViewModel>();
    final currency = modelWatch.currency;
    final ready = context.select((AdditionalCurrencySettingsViewModel state) => state.ready);

    return Scaffold(
      appBar: AppBar(
        title: Text("Currency Settings"),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('Current Format'),
                        Text(
                          context.currencySetMod.formatCurrency(12345.67),
                          textAlign: TextAlign.end,
                          style: context.customTt.numberFontLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Divider(),
            )),
            SliverToBoxAdapter(
              child: CustomSettingsTile(
                title: "Currency Symbol",
                trailingWidget: Text(currency.symbol, style: context.tt.bodyMedium),
              ),
            ),
            SliverToBoxAdapter(
              child: SymbolPositionSettingsTile(),
            ),
            SliverToBoxAdapter(
              child: ThousandSeparatorSettingsTile(separators: separators, currency: currency),
            ),
            SliverToBoxAdapter(
              child: DecimalSeparatorSettingsTile(separators: separators, currency: currency),
            ),
            SliverToBoxAdapter(
              child: const SymbolSpaceSettingsTile(),
            ),
          ],
        ),
      ),
    );
  }
}

class SymbolPositionSettingsTile extends StatelessWidget {
  const SymbolPositionSettingsTile({
    super.key,
  });

  static Map<String, String> symbolPositions = {
    "Front": "In front of number",
    "Back": "At the back of number",
    "None": "Do not show symbol",
  };

  @override
  Widget build(BuildContext context) {
    final contextWatch = context.watch<AdditionalCurrencySettingsViewModel>();
    final symbolPosition = context.select(
      (AdditionalCurrencySettingsViewModel state) => state.symbolPosition,
    );
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      title: Text(
        "Symbol Position",
        style: context.tt.bodyMedium,
      ),
      trailing: SizedBox(
        width: 160,
        child: DropdownMenu(
          initialSelection: symbolPosition,
          onSelected: (value) {
            context.currencySetMod.updateSymbolPosition(value);
          },
          expandedInsets: EdgeInsets.zero,
          dropdownMenuEntries:
              SymbolPosition.values
                  .map(
                    (el) => DropdownMenuEntry(
                      value: el,
                      label: el.name.capitalize(),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity(vertical: -2),
                      ),
                    ),
                  )
                  .toList(),
          textStyle: context.tt.bodyMedium,
          inputDecorationTheme: InputDecorationThemeData(
            visualDensity: VisualDensity(vertical: -4),
            constraints: BoxConstraints(maxHeight: 40),
          ),
          menuStyle: MenuStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
            visualDensity: VisualDensity.comfortable,
            backgroundColor: WidgetStatePropertyAll(
              context.cs.surfaceContainer ?? Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}

class ThousandSeparatorSettingsTile extends StatelessWidget {
  const ThousandSeparatorSettingsTile({
    super.key,
    required this.separators,
    required this.currency,
  });

  final Map<String, String> separators;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final contextWatch = context.watch<AdditionalCurrencySettingsViewModel>();
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      title: Text(
        "Thousand separator",
        style: context.tt.bodyMedium,
      ),
      trailing: SizedBox(
        width: 160,
        child: DropdownMenu(
          initialSelection:
              NumberSeparator.values.firstWhereOrNull(
                (separator) => separator.symbol == contextWatch.currency.groupSeparator,
              ) ??
              NumberSeparator.comma,
          onSelected: (value) {
            context.currencySetMod.updateSeparator(value, isDecimal: false);
          },
          expandedInsets: EdgeInsets.zero,
          dropdownMenuEntries:
              NumberSeparator.values
                  .where((separator) => separator.applicableToThousand)
                  .map(
                    (el) => DropdownMenuEntry(
                      value: el,
                      label: "${el.name} (${el.symbol})",
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity(vertical: -2),
                      ),
                    ),
                  )
                  .toList(),
          textStyle: context.tt.bodyMedium,
          inputDecorationTheme: InputDecorationThemeData(
            visualDensity: VisualDensity(vertical: -4),
            constraints: BoxConstraints(maxHeight: 40),
          ),
          menuStyle: MenuStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
            visualDensity: VisualDensity.comfortable,
            backgroundColor: WidgetStatePropertyAll(
              context.cs.surfaceContainer ?? Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}

class DecimalSeparatorSettingsTile extends StatelessWidget {
  const DecimalSeparatorSettingsTile({
    super.key,
    required this.separators,
    required this.currency,
  });

  final Map<String, String> separators;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final contextWatch = context.watch<AdditionalCurrencySettingsViewModel>();
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      title: Text(
        "Decimal separator",
        style: context.tt.bodyMedium,
      ),
      trailing: SizedBox(
        width: 160,
        child: DropdownMenu(
          initialSelection:
              NumberSeparator.values.firstWhereOrNull(
                (separator) => separator.symbol == contextWatch.currency.decimalSeparator,
              ) ??
              NumberSeparator.comma,
          onSelected: (value) {
            context.currencySetMod.updateSeparator(value, isDecimal: true);
          },
          expandedInsets: EdgeInsets.zero,
          dropdownMenuEntries:
              NumberSeparator.values
                  .where((separator) => separator.applicableToDecimal)
                  .map(
                    (el) => DropdownMenuEntry(
                      value: el,
                      label: "${el.name} (${el.symbol})",
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity(vertical: -2),
                      ),
                    ),
                  )
                  .toList(),
          textStyle: context.tt.bodyMedium,
          inputDecorationTheme: InputDecorationThemeData(
            visualDensity: VisualDensity(vertical: -4),
            constraints: BoxConstraints(maxHeight: 40),
          ),
          menuStyle: MenuStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
            visualDensity: VisualDensity.comfortable,
            backgroundColor: WidgetStatePropertyAll(
              context.cs.surfaceContainer ?? Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}

class SymbolSpaceSettingsTile extends StatelessWidget {
  const SymbolSpaceSettingsTile({
    super.key,
  });

  static Map<bool, String> symbolSpaceOptions = {
    true: "Space between symbol and number.",
    false: "No space between symbol and number.",
  };

  @override
  Widget build(BuildContext context) {
    final contextWatch = context.watch<AdditionalCurrencySettingsViewModel>();
    final symbolSpace = context.select(
      (AdditionalCurrencySettingsViewModel state) => state.symbolSpace,
    );
    final symbolPosition = context.select(
      (AdditionalCurrencySettingsViewModel state) => state.symbolPosition,
    );
    return CustomSwitchListTile(
      title: "Symbol Space",
      value: symbolSpace,
      onSelected: (value) {
        context.currencySetMod.toggleSymbolSpace(value);
      },
    );

    // ListTile(
    //   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    //   title: Text(
    //     "Symbol Space",
    //     style: context.tt.bodyMedium,
    //   ),
    //   trailing: SizedBox(
    //     width: 160,
    //     child: DropdownMenu(
    //       initialSelection: symbolSpace,
    //       onSelected: (value) {
    //         context.currencySetMod.toggleSymbolSpace(value);
    //       },
    //       expandedInsets: EdgeInsets.zero,
    //       dropdownMenuEntries:
    //           [true, false]
    //               .map(
    //                 (el) => DropdownMenuEntry(
    //                   value: el,
    //                   label: el.toString().capitalize(),
    //                   style: TextButton.styleFrom(
    //                     visualDensity: VisualDensity(vertical: -2),
    //                   ),
    //                 ),
    //               )
    //               .toList(),
    //       textStyle: context.tt.bodyMedium,
    //       inputDecorationTheme: InputDecorationThemeData(
    //         visualDensity: VisualDensity(vertical: -4),
    //         constraints: BoxConstraints(maxHeight: 40),
    //       ),
    //       menuStyle: MenuStyle(
    //         padding: WidgetStatePropertyAll(EdgeInsets.zero),
    //         visualDensity: VisualDensity.comfortable,
    //         backgroundColor: WidgetStatePropertyAll(
    //           context.cs.surfaceContainer ?? Colors.transparent,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}

class AdditionalCurrencySettingsDialog<T> extends StatelessWidget {
  const AdditionalCurrencySettingsDialog({
    super.key,
    this.title,
    this.onChanged,
    required this.groupValue,
    required this.map,
    required this.context,
  });

  final String? title;
  final ValueChanged<T?>? onChanged;
  final Map<T, String> map;
  final BuildContext context;
  final T? groupValue;

  @override
  Widget build(BuildContext _) {
    return ListenableBuilder(
      listenable: context.currencySetMod,
      builder: (listenableContext, child) {
        debugPrint("dialog rebuild");
        return AlertDialog(
          title: Text(
            title ?? "",
            style: context.customTt.dateLabel,
          ),
          content: RadioGroup(
            groupValue: groupValue,
            onChanged: onChanged ?? (T? value) {},
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...map.entries.map(
                  (entry) => RadioListTile(
                    value: entry.key,
                    title: Text(entry.value, style: context.tt.bodyMedium),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

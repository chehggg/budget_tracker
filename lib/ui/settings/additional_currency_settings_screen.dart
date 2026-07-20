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

    return CustomScaffold(
      appBarTitle: Text("Currency Settings"),
      ready: ready,
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Divider(),
            ),
          ),
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
    );
  }
}

class SymbolPositionSettingsTile extends StatelessWidget {
  const SymbolPositionSettingsTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final contextWatch = context.watch<AdditionalCurrencySettingsViewModel>();
    final symbolPosition = contextWatch.symbolPosition;
    return CustomDropdownListTile(
      title: 'Symbol Position',
      initSelection: symbolPosition,
      onSelected: (value) {
        context.currencySetMod.updateSymbolPosition(value);
      },
      entries:
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
    return CustomDropdownListTile(
      title: "Thousand separator",
      initSelection:
          NumberSeparator.values.firstWhereOrNull(
            (separator) => separator.symbol == contextWatch.currency.groupSeparator,
          ) ??
          NumberSeparator.comma,
      onSelected: (value) {
        context.currencySetMod.updateSeparator(value, isDecimal: false);
      },
      entries:
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
    return CustomDropdownListTile(
      title: "Decimal separator",
      initSelection:
          NumberSeparator.values.firstWhereOrNull(
            (separator) => separator.symbol == contextWatch.currency.decimalSeparator,
          ) ??
          NumberSeparator.comma,
      onSelected: (value) {
        context.currencySetMod.updateSeparator(value, isDecimal: true);
      },
      entries:
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
    );
  }
}

class SymbolSpaceSettingsTile extends StatelessWidget {
  const SymbolSpaceSettingsTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final contextWatch = context.watch<AdditionalCurrencySettingsViewModel>();
    final symbolSpace = contextWatch.symbolSpace;

    return CustomSwitchListTile(
      title: "Symbol Space",
      value: symbolSpace,
      onSelected: (value) {
        context.currencySetMod.toggleSymbolSpace(value);
      },
    );
  }
}


import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/ui/settings/additional_currency_settings_viewmodel.dart';
import 'package:budget_tracker/ui/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        title: Text("Additional Currency Settings"),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: CustomSettingsTile(
                title: "Current Format",
                trailingWidget: Text(
                  context.currencySetMod.formatCurrency(12345.67),
                  style: context.tt.bodyMedium,
                ),
              ),
            ),
            SliverToBoxAdapter(child: Divider()),
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
    final symbolPosition = context.select((AdditionalCurrencySettingsViewModel state) => state.symbolPosition);
    return CustomSettingsTile(
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContext) {
            return ListenableBuilder(
              listenable: context.currencySetMod,
              builder: (listenableContext, child) {
                return AlertDialog(
                  title: Text("Symbol Position", style: context.customTt.dateLabel,),
                  content: RadioGroup(
                    groupValue: contextWatch.symbolPosition,
                    onChanged: context.currencySetMod.updateSymbolPosition,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...symbolPositions.entries.map(
                          (entry) => RadioListTile(
                            value: entry.key,
                            title: Text(
                              entry.value,
                              style: context.tt.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      title: "Symbol position",
      trailingWidget: Text(symbolPositions[symbolPosition] ?? "", style: context.tt.bodyMedium),
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
    return CustomSettingsTile(
      title: "Thousand separator",
      trailingWidget: Text(
        separators[currency.groupSeparator] ?? "",
        style: context.tt.bodyMedium,
      ),
      onTap: () async {
        await showDialog(
          context: context,
          builder: (dialogContext) {
            return ListenableBuilder(
              listenable: context.currencySetMod,
              builder: (listenableContext, child) {
                debugPrint("dialog rebuild");
                return AlertDialog(
                  title: Text(
                    "Decimal Separators",
                    style: context.customTt.dateLabel,
                  ),
                  content: RadioGroup(
                    groupValue: contextWatch.currency.groupSeparator,
                    onChanged:
                        (value) => context.currencySetMod.updateSeparator(value, isDecimal: false),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...separators.entries.map(
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
          },
        );
      },
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
    return CustomSettingsTile(
      title: "Decimal separator",
      trailingWidget: Text(
        separators[currency.decimalSeparator] ?? "",
        style: context.tt.bodyMedium,
      ),
      onTap: () async {
        await showDialog(
          context: context,
          builder: (dialogContext) {
            return ListenableBuilder(
              listenable: context.currencySetMod,
              builder: (listenableContext, child) {
                debugPrint("dialog rebuild");
                return AlertDialog(
                  title: Text(
                    "Decimal Separators",
                    style: context.customTt.dateLabel,
                  ),
                  content: RadioGroup(
                    groupValue: contextWatch.currency.decimalSeparator,
                    onChanged:
                        (value) => context.currencySetMod.updateSeparator(value, isDecimal: true),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...separators.entries.map(
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
          },
        );
      },
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
    return CustomSettingsTile(
      title: "Space between symbol",
      onTap: () async {
        if (symbolPosition == "None") return;
        await showDialog(
          context: context,
          builder: (dialogContext) {
            return ListenableBuilder(
              listenable: context.currencySetMod,
              builder: (listenableContext, child) {
                return AlertDialog(
                  title: Text(
                    "Symbol Space",
                    style: context.customTt.dateLabel,
                  ),
                  content: RadioGroup(
                    groupValue: contextWatch.symbolSpace,
                    onChanged: context.currencySetMod.toggleSymbolSpace,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...symbolSpaceOptions.entries.map(
                          (entry) => Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(splashFactory: NoSplash.splashFactory),
                            child: RadioListTile(
                              visualDensity: VisualDensity(horizontal: -4, vertical: -2),
                              contentPadding: EdgeInsets.symmetric(horizontal: 0),
                              value: entry.key,
                              title: Text(entry.value, style: context.tt.bodyMedium),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      trailingWidget: Text(
        symbolSpace.toString().capitalize(),
        style: context.tt.bodyMedium,
      ),
    );
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

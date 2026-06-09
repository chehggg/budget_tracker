import 'package:another_flushbar/flushbar.dart';
import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/models/navigation_model.dart';
import 'package:budget_tracker/constants/currency.dart';
import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/settings/setting_viewmodel.dart';
import 'package:collection/wrappers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: SettingsList(),
        ),
      ),
    );
  }
}

IconData getThemeModeIcon(ThemeMode themeMode) {
  switch (themeMode) {
    case ThemeMode.dark:
      return Icons.dark_mode;
    case ThemeMode.light:
      return Icons.light_mode;
    case ThemeMode.system:
      return Icons.computer;
  }
}

class SettingsList extends StatelessWidget {
  const SettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedThemeMode = context.select((ThemeModel state) => state.theme);
    final selectedCurrencySymbol = context.select(
      (AppModel state) => '${state.currencySymbol} (${state.currencyName})',
    );
    final selectedLanguage = context.select((ThemeModel state) {
      switch (state.appLocale.languageCode) {
        case "en":
          return "English";
        case "zh":
          return "中文（简体）";
        case "ja":
          return "日本語";
        default:
          return "Undefined";
      }
    });
    return Material(
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // SettingsSectionTitle(titleName: "General", icon: Icons.display_settings),
                // CustomSettingsTile(trailingWidget: SizedBox.shrink(), title: "Theme Mode"),
                // CustomSettingsTile(trailingWidget: SizedBox.shrink(), title: "Currency"),
                CurrencySettingsTile(
                  selectedCurrencySymbol: selectedCurrencySymbol,
                ),
                const BudgetSettingsTile(),
                const RecurringCostSettingsTile(),
                const HideCostSettingsTile(),
                Divider(),
                ThemeModeSettingsTile(selectedThemeMode: selectedThemeMode),
                const ColorSettingsTile(),
                const VisualDensitySettingsTile(),
                const FormGridColumnItemSettingsTile(),
                const FontSizeSettingsTile(),
                Divider(),
                const ExportDataSettingsTile(),
                const LoadDataSettingsTile(),
                const ClearDataSettingsTile(),
                Divider(),
                const AboutSettingsTile(),
                const ReportBugSettingsTile(),
                const SupportMeSettingsTile(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AboutSettingsTile extends StatelessWidget {
  const AboutSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      title: "About",
      onTap:
          () => showDialog(
            context: context,
            builder: (context) => AboutDialog(),
          ),
    );
  }
}

class ReportBugSettingsTile extends StatelessWidget {
  const ReportBugSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      title: "Report a bug",
      onTap:
          () => showDialog(
            context: context,
            builder: (context) => AboutDialog(),
          ),
    );
  }
}

class SupportMeSettingsTile extends StatelessWidget {
  const SupportMeSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      title: "Support Me",
      onTap:
          () => showDialog(
            context: context,
            builder: (context) => AboutDialog(),
          ),
    );
  }
}

class ColorSettingsTile extends StatelessWidget {
  const ColorSettingsTile({super.key});
  @override
  Widget build(BuildContext context) {
    Color selectedColor = context.select((ThemeModel model) => model.color);
    return CustomSettingsTile(
      trailingWidget: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: selectedColor,
        ),
      ),
      title: "Color",
      onTap:
          () => showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text("Color"),
                    content: Column(
                      spacing: 0,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Spacing between list tiles."),
                        SizedBox(
                          height: 8,
                        ),
                        BlockPicker(
                          pickerColor: selectedColor,
                          onColorChanged: (color) => context.read<ThemeModel>().updateColor(color),
                        ),
                      ],
                    ),
                    // actions: [
                    //   TextButton(onPressed: () {}, child: const Text('Confirm'))
                    // ],
                  );
                },
              );
            },
          ),
    );
  }
}

class VisualDensitySettingsTile extends StatelessWidget {
  const VisualDensitySettingsTile({super.key});
  @override
  Widget build(BuildContext context) {
    int spacingValue = context.select((ThemeModel model) => model.spacingValue);
    return CustomSettingsTile(
      trailingWidget: Text(spacingValue.toString()),
      title: "Spacing",
      onTap:
          () => showDialog(
            context: context,
            builder: (context) {
              double sliderValue = context.read<ThemeModel>().spacingValue.toDouble();
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text("Spacing"),
                    content: Column(
                      spacing: 0,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Spacing between list tiles."),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "Higher value indicate more space between cost items and settings tile.",
                        ),
                        // SizedBox(height: 40,),
                        Padding(
                          padding: const EdgeInsets.only(top: 60.0, bottom: 15),
                          child: SliderTheme(
                            data: SliderThemeData(
                              showValueIndicator: ShowValueIndicator.alwaysVisible,
                            ),
                            child: Slider(
                              label: sliderValue.toStringAsFixed(0),
                              value: sliderValue,
                              min: 1,
                              max: 5,
                              divisions: 4,
                              onChanged: (value) {
                                setState(() => sliderValue = value);
                                context.read<ThemeModel>().updateSpacingValue(
                                  value.round(),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    // actions: [
                    //   TextButton(onPressed: () {}, child: const Text('Confirm'))
                    // ],
                  );
                },
              );
            },
          ),
    );
  }
}

class RecurringCostSettingsTile extends StatelessWidget {
  const RecurringCostSettingsTile({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      trailingWidget: SizedBox.shrink(),
      title: "Add Recurring Item",
      onTap: () => Navigator.of(context).pushNamed('/recurring'),
    );
  }
}

class BudgetSettingsTile extends StatelessWidget {
  const BudgetSettingsTile({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      trailingWidget: SizedBox.shrink(),
      title: "Budget",
      onTap: () => Navigator.of(context).pushNamed('/budgets'),
    );
  }
}

class FormGridColumnItemSettingsTile extends StatelessWidget {
  const FormGridColumnItemSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    int gridSize = context.select((ThemeModel model) => model.gridSize);
    return CustomSettingsTile(
      trailingWidget: Text(gridSize.toString()),
      title: "Grid Size",
      onTap:
          () => showDialog(
            context: context,
            builder: (context) {
              int selectedGridSize = gridSize;
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    // actionsPadding: EdgeInsets.all(12),
                    title: Text("Grid size"),
                    content: RadioGroup(
                      groupValue: selectedGridSize,
                      onChanged: (int? value) {
                        setState(() => selectedGridSize = value ?? 4);
                        context.read<ThemeModel>().updateGridSize(value ?? 4);
                      },
                      child: Column(
                        spacing: 0,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Amount of item within a row in the cost entry screen.",
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ListTile(
                            title: Text('3'),
                            leading: Radio(value: 3),
                            visualDensity: VisualDensity(
                              vertical: -2,
                              horizontal: -2,
                            ),
                            dense: true,
                            contentPadding: EdgeInsets.all(0),
                          ),
                          ListTile(
                            title: Text('4'),
                            leading: Radio(value: 4),
                            visualDensity: VisualDensity(
                              vertical: -2,
                              horizontal: -2,
                            ),
                            dense: true,
                            contentPadding: EdgeInsets.all(0),
                          ),
                          ListTile(
                            title: Text('5'),
                            leading: Radio(value: 5),
                            visualDensity: VisualDensity(
                              vertical: -2,
                              horizontal: -2,
                            ),
                            dense: true,
                            contentPadding: EdgeInsets.all(0),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}

class FontSizeSettingsTile extends StatelessWidget {
  const FontSizeSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    int fontFactor = context.select((ThemeModel model) => model.fontSizeFactor);
    return CustomSettingsTile(
      trailingWidget: Text(fontFactor.toString()),
      title: "Font Size Factor",
      onTap:
          () => showDialog(
            context: context,
            builder: (context) {
              double sliderValue = context.read<ThemeModel>().fontSizeFactor.toDouble();
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text("Font Size Factor"),
                    content: Column(
                      spacing: 0,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Apply a scale factor to all font size. Higher value indicates larger font.",
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 60.0, bottom: 15),
                          child: SliderTheme(
                            data: SliderThemeData(
                              showValueIndicator: ShowValueIndicator.alwaysVisible,
                            ),
                            child: Slider(
                              label: sliderValue.toStringAsFixed(0),
                              value: sliderValue,
                              min: 1,
                              max: 5,
                              divisions: 4,
                              onChanged: (value) {
                                setState(() => sliderValue = value);
                                context.read<ThemeModel>().updateFontSizeFactor(
                                  value.round(),
                                );
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}

class HideCostSettingsTile extends StatelessWidget {
  const HideCostSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final blur = context.select((ThemeModel state) => state.defaultBlur);
    debugPrint("rebuild");
    return CustomSettingsTile(
      trailingWidget: Text(blur.name),
      title: "Hide Amount On Start",
      onTap:
          () => showDialog(
            context: context,
            builder: (context) {
              final themeStateRead = context.read<ThemeModel>();
              ValueBlur curDefBlur = themeStateRead.defaultBlur;
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text("Hide Amount On Start"),
                    content: Column(
                      spacing: 0,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hide amount when app opened. This can be toggled on and off afterwards from the top.",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        SizedBox(height: 20),
                        DialogListTile(
                          title: "All",
                          trailing: Switch(
                            value: curDefBlur == ValueBlur.all,
                            onChanged: (value) {
                              themeStateRead.updateDefaultBlur(
                                ValueBlur.all,
                                value,
                              );
                              setState(
                                () => curDefBlur = themeStateRead.defaultBlur,
                              );
                            },
                          ),
                        ),
                        Divider(),
                        DialogListTile(
                          title: "Summary",
                          trailing: Switch(
                            value: [
                              ValueBlur.all,
                              ValueBlur.summary,
                            ].contains(curDefBlur),
                            onChanged: (value) {
                              context.read<ThemeModel>().updateDefaultBlur(
                                ValueBlur.summary,
                                value,
                              );
                              setState(
                                () => curDefBlur = themeStateRead.defaultBlur,
                              );
                            },
                          ),
                        ),
                        DialogListTile(
                          title: "List",
                          trailing: Switch(
                            value: [
                              ValueBlur.all,
                              ValueBlur.list,
                            ].contains(curDefBlur),
                            onChanged: (value) {
                              context.read<ThemeModel>().updateDefaultBlur(
                                ValueBlur.list,
                                value,
                              );
                              setState(
                                () => curDefBlur = themeStateRead.defaultBlur,
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}

class FontFamilySettingsTile extends StatelessWidget {
  const FontFamilySettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      trailingWidget: SizedBox.shrink(),
      title: "Font",
      onTap: () {},
    );
  }
}

class SettingsSectionTitle extends StatelessWidget {
  const SettingsSectionTitle({
    super.key,
    required this.titleName,
    required this.icon,
  });

  final IconData icon;
  final String titleName;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      contentPadding: EdgeInsets.only(top: 10, left: 8, right: 8),
      // visualDensity: VisualDensity(vertical: 0),
      dense: true,
      title: Text(
        titleName,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class LanguageSetting extends StatelessWidget {
  const LanguageSetting({
    super.key,
    required this.selectedLanguage,
  });

  final String selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // title: Text(AppLocalizations.of(context)!.language),
      title: Text("Language"),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      trailing: Text(
        selectedLanguage,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      onTap: () => changeLanguageDialog(context),
    );
  }

  Future changeLanguageDialog(BuildContext context) {
    const List<Map<String, String>> languages = [
      {
        "display": "English",
        "locale": "en",
      },
      {
        "display": "中文（简体）",
        "locale": "zh",
      },
      {
        "display": "日本語",
        "locale": "ja",
      },
    ];

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // title: Text(AppLocalizations.of(context)!.changeLanguage),
          title: Text("Change language"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                languages
                    .map(
                      (language) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.only(),
                        title: Text(language['display']!),
                        onTap: () {
                          context.read<ThemeModel>().updateLanguage(
                            language['locale']!,
                          );
                          Navigator.pop(context);
                        },
                      ),
                    )
                    .toList(),
          ),
        );
      },
    );
  }
}

class CurrencySettingsTile extends StatelessWidget {
  const CurrencySettingsTile({
    super.key,
    required this.selectedCurrencySymbol,
  });

  final String selectedCurrencySymbol;

  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      title: "Currency",
      trailingWidget: Text(
        selectedCurrencySymbol,
        // style: Theme.of(context).textTheme.labelLarge
      ),
      onTap: () => changeCurrencyDialog(context),
    );
  }

  Future changeCurrencyDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return const CurrencySettingsDialog();
      },
    );
  }
}

class CustomSettingsTile extends StatelessWidget {
  const CustomSettingsTile({
    super.key,
    this.trailingWidget,
    this.subtitle,
    this.titleWidget,
    this.verticalPadding = 0,
    this.horizontalPadding = 16,
    this.leading,
    this.title,
    this.onTap,
  });

  final Widget? trailingWidget;
  final Widget? leading;
  final Widget? subtitle;
  final double verticalPadding;
  final double horizontalPadding;
  final String? title;
  final Widget? titleWidget;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    // final title = ti
    return ListTile(
      title:
          title != null
              ? Text(title!, style: Theme.of(context).textTheme.titleMedium)
              : titleWidget,
      subtitle: subtitle,
      dense: true,
      trailing: trailingWidget,
      leading: leading,
      // leadingAndTrailingTextStyle: Theme.of(context).textTheme.bodyMedium,
      contentPadding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      onTap: onTap,
    );
  }
}

class ThemeModeSettingsTile extends StatelessWidget {
  const ThemeModeSettingsTile({
    super.key,
    required this.selectedThemeMode,
  });

  final ThemeMode selectedThemeMode;

  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      title: "Theme Mode",
      onTap: () => showThemeModeDialog(context),
      trailingWidget: Text(selectedThemeMode.name),
    );
  }

  Future showThemeModeDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Theme Mode"),
          content: RadioGroup<ThemeMode>(
            groupValue: selectedThemeMode,
            onChanged: (ThemeMode? mode) {
              if (mode != null) {
                context.read<ThemeModel>().updateTheme(mode);
                Navigator.pop(context);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  ThemeMode.values.map((ThemeMode mode) {
                    return ListTile(
                      contentPadding: EdgeInsets.all(0),
                      visualDensity: VisualDensity(vertical: -2),
                      dense: true,
                      title: Text(mode.name),
                      leading: Radio(value: mode),
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class CurrencySettingsDialog extends StatefulWidget {
  const CurrencySettingsDialog({super.key});

  @override
  State<CurrencySettingsDialog> createState() => _CurrencySettingsDialogState();
}

class _CurrencySettingsDialogState extends State<CurrencySettingsDialog> {
  List<Map<String, dynamic>> _displayedCurrencies = [];
  String _selectedCurrencySymbol = "";
  String _selectedCurrencyName = "";
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    resetCurrencies();
    // _displayedCurrencies = currencies;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void resetCurrencies() {
    _selectedCurrencySymbol = context.read<AppModel>().currencySymbol;
    _selectedCurrencyName = context.read<AppModel>().currencyName;

    final defaultCurrency = [...currencies];
    final selectedCurrencyIndex = currencies.indexWhere(
      (currency) =>
          currency['symbol'] == _selectedCurrencySymbol &&
          currency['name'] == _selectedCurrencyName,
    );
    debugPrint(selectedCurrencyIndex.toString());
    if (selectedCurrencyIndex != -1) {
      defaultCurrency.removeRange(
        selectedCurrencyIndex,
        selectedCurrencyIndex + 1,
      );

      setState(() {
        _displayedCurrencies = [
          currencies[selectedCurrencyIndex],
          // ...defaultCurrency
          ...defaultCurrency,
        ];
      });
    } else {
      setState(() {
        _displayedCurrencies = currencies;
      });
    }
  }

  void searchCurrency(String query) {
    if (query == "") {
      resetCurrencies();
    } else {
      final defaultCurrency = [...currencies];
      final selectedCurrencyIndex = currencies.indexWhere(
        (currency) =>
            currency['symbol'] == _selectedCurrencySymbol &&
            currency['name'] == _selectedCurrencyName,
      );
      debugPrint(selectedCurrencyIndex.toString());
      if (selectedCurrencyIndex != -1) {
        defaultCurrency.removeRange(
          selectedCurrencyIndex,
          selectedCurrencyIndex + 1,
        );
        setState(() {
          _displayedCurrencies = [
            currencies[selectedCurrencyIndex],
            ...defaultCurrency.where(
              (currency) =>
                  (currency['name'] as String).toLowerCase().contains(query) ||
                  (currency['symbol'] as String).toLowerCase().contains(query),
            ),
          ];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Change currency"),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 0.7,
        child: Column(
          spacing: 10,
          children: [
            TextFormField(
              controller: _controller,
              onChanged: searchCurrency,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search),
                // hintText: AppLocalizations.of(context)!.searchCurrency,
                hintText: "Search currency",
                hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
                ),
                fillColor: Theme.of(context).colorScheme.surfaceDim,
              ),
            ),
            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: _displayedCurrencies.length,
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> currency = _displayedCurrencies.elementAt(index);
                    final Icon? icon;
                    if (_selectedCurrencySymbol == currency['symbol'] &&
                        _selectedCurrencyName == currency['name']) {
                      icon = Icon(Icons.check);
                    } else {
                      icon = null;
                    }
                    return DialogListTile(
                      title: '${currency['symbol'] as String} (${currency['name'] as String})',
                      trailing: icon,
                      onTap: () {
                        setState(() {
                          _selectedCurrencySymbol =
                              _displayedCurrencies.elementAt(index)['symbol'] as String;
                        });
                        context.read<AppModel>().changeCurrency(currency);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExportDataSettingsTile extends StatelessWidget {
  const ExportDataSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      title: "Export data",
      trailingWidget: const SizedBox.shrink(),
      onTap: () => showExportDialog(context),
    );
  }

  Future showExportDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Export data"),
          content: const Text(
            "Press confirm to export the cost item as CSV into your desired location",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await context.read<SettingsViewModel>().exportCostItemData();
                // if (context.mounted) {
                //   Navigator.pop(context);
                //   if (outputPath != null) {
                //     Flushbar(
                //       // title: "Saved!",
                //       message: "File successfully saved to $outputPath",
                //       flushbarPosition: FlushbarPosition.TOP,
                //       duration: Duration(seconds: 3),
                //       flushbarStyle: FlushbarStyle.GROUNDED,
                //     ).show(context);
                //   }
                // }
              },
              child: const Text("confirm"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("cancel"),
            ),
          ],
        );
      },
    );
  }
}

class LoadDataSettingsTile extends StatelessWidget {
  const LoadDataSettingsTile({super.key});

  final loadOptions = const [
    {
      "function": "Append",
      "desc": "Import selected file's data into existing list.",
      "overwrite": false,
      "flushMsg": "Data appended"
    },
    {
      "function": "Overwrite",
      "desc": "Replace existing list with selected file's data. Previous data will be deleted.",
      "overwrite": true,
      "flushMsg": "Data overwrited"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      title: "Load data",
      trailingWidget: const SizedBox.shrink(),
      onTap: () => showLoadItemDialog(context),
    );
  }

  Future showLoadItemDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Load data"),
          content: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select one of the following options:",
                ),
                ...loadOptions.map(
                  (option) => ReusableContainer(
                    filled: true,
                    height: 100,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    onTap: () async {
                      final result = await context.read<SettingsViewModel>().loadData();
                      // if (result == null) return;
                      // if (result == "success") {
                      //   context.nav.pop();
                      //   Flushbar(
                      //     message: option['flushMsg'] as String? ?? "",
                      //     flushbarPosition: FlushbarPosition.TOP,
                      //     duration: Duration(seconds: 3),
                      //     flushbarStyle: FlushbarStyle.GROUNDED,
                      //   ).show(context);
                      // } else {
                      //   Flushbar(
                      //     message: "Operation failed. Error: $result ",
                      //     flushbarPosition: FlushbarPosition.TOP,
                      //     duration: Duration(seconds: 3),
                      //     flushbarStyle: FlushbarStyle.GROUNDED,
                      //   );
                      // }
                    },
                    child: Column(
                      spacing: 4,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(option['function'] as String? ?? "Function"),
                        Text(
                          option['desc'] as String? ?? "Desc",
                          style: context.tt.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Back",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ClearDataSettingsTile extends StatelessWidget {
  const ClearDataSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      title: "Clear data",
      trailingWidget: const SizedBox.shrink(),
      onTap:
          () => showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Clear data"),
                content: const Text(
                  "Warning: All existing data will be removed. This action cannot be undone. It is recommended to keep a export current data as backup.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              content: Column(
                                children: [
                                  const Text("Type clear to clear data"),
                                  TextFormField(),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    await context.read<AppModel>().clearCostItem();
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      context.read<NavigationModel>().backToHomeScreen();
                                    }
                                  },
                                  child: Text("Confirm"),
                                ),
                              ],
                            ),
                      );
                    },
                    child: const Text(
                      "Clear",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
}

class TestingSettings extends StatelessWidget {
  const TestingSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("Test sending data to firebase"),
      onTap: () => context.read<AppModel>().writeDataToFirebase(),
    );
  }
}

class SyncFirebaseDataSetting extends StatelessWidget {
  const SyncFirebaseDataSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("Sync data to cloud"),
      trailing: Switch(value: false, onChanged: (value) {}),
    );
  }
}

class DialogListTile extends StatelessWidget {
  const DialogListTile({
    super.key,
    this.title,
    this.trailing,
    this.leading,
    this.onTap,
  });

  final String? title;
  final Widget? trailing;
  final Widget? leading;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      title: title == null ? null : Text(title!),
      trailing: trailing,
      leading: leading,
      onTap: onTap,
    );
  }
}

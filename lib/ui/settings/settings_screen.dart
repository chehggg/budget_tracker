import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:budget_tracker/data/repos/exchange_rate_repository.dart';
import 'package:budget_tracker/data/repos/goal_repository.dart';
import 'package:budget_tracker/data/repos/saved_item_repository.dart';
import 'package:budget_tracker/data/repos/shared_element_repository.dart';
import 'package:budget_tracker/data/services/exporter_service.dart';
import 'package:budget_tracker/languages.dart';
import 'package:budget_tracker/models/navigator_model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/settings/setting_viewmodel.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:money2/money2.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsScreenWrapper extends StatelessWidget {
  const SettingsScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (context) => SettingsViewModel(
            costItemRepo: context.read(),
            categoryRepo: context.read(),
            currencyRepo: context.read(),
          ),
      child: const SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.settings.getString(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: const SettingsList(),
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
    // final selectedThemeMode = context.select((ThemeModel state) => state.theme);
    // final selectedCurrencySymbol = context.select(
    //   (AppModel state) => '${state.currencySymbol} (${state.currencyName})',
    // );
    // final selectedLanguage = context.select((ThemeModel state) {
    //   switch (state.appLocale.languageCode) {
    //     case "en":
    //       return "English";
    //     case "zh":
    //       return "中文（简体）";
    //     case "ja":
    //       return "日本語";
    //     default:
    //       return "Undefined";
    //   }
    // });
    return Material(
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SettingsSectionTitle(text: "Display"),
                const ListScreenDisplaySettingsTile(),
                const GlobalDisplaySettingsTile(),
                const SettingsDivider(),
                const SettingsSectionTitle(text: "Configuration"),
                CurrencySettingsTile(
                  selectedCurrencySymbol: context.select(
                    (SettingsViewModel state) => state.displayedCurrency,
                  ),
                ),
                CurrencyAdditionalSettingsTile(),
                KeyboardSettingsTile(),
                ChangeLanguageSettingsTile(),
                // const BudgetSettingsTile(),
                // Divider(),
                // const SettingsSectionTitle(text: "Theme"),
                // ThemeModeSettingsTile(selectedThemeMode: selectedThemeMode),
                // const ColorSettingsTile(),
                // const VisualDensitySettingsTile(),
                // const FormGridColumnItemSettingsTile(),
                // const FontSizeSettingsTile(),
                const SettingsDivider(),
                SettingsSectionTitle(text: AppLocale.data.getString(context)),
                const ExportDataSettingsTile(),
                const LoadDataSettingsTile(),
                const ClearDataSettingsTile(),
                const SettingsDivider(),
                SettingsSectionTitle(text: AppLocale.aboutTitle.getString(context)),
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

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 2),
      child: Divider(),
    );
  }
}

class SettingsSectionTitle extends StatelessWidget {
  const SettingsSectionTitle({super.key, required this.text});

  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Text(text, style: context.customTt.dateLabel),
    );
  }
}

class AboutSettingsTile extends StatelessWidget {
  const AboutSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      title: "About",
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: "Nomi",
          applicationVersion: "1",
        );
      },
    );
  }
}

class ReportBugSettingsTile extends StatelessWidget {
  const ReportBugSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      titleWidget: Row(
        spacing: 8,
        children: [
          Text("Report issue", style: context.tt.bodyMedium),
          Icon(
            Icons.open_in_new,
            size: 16,
          ),
        ],
      ),
      // title: "Report issue",
      onTap: () async {
        await launchUrlString("https://github.com/chehggg/budget_tracker/issues/new");
      },
    );
  }
}

class SupportMeSettingsTile extends StatelessWidget {
  const SupportMeSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      // title: "Support Me",
      titleWidget: Row(
        spacing: 8,
        children: [
          Text("Support Me", style: context.tt.bodyMedium),
          Icon(Icons.open_in_new, size: 16),
        ],
      ),
      onTap: () async {
        await launchUrlString("https://github.com/chehggg/");
      },
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

// class RecurringCostSettingsTile extends StatelessWidget {
//   const RecurringCostSettingsTile({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return CustomSettingsTile(
//       trailingWidget: SizedBox.shrink(),
//       title: "Add Recurring Item",
//       onTap: () => Navigator.of(context).pushNamed('/recurring'),
//     );
//   }
// }

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

class ListScreenDisplaySettingsTile extends StatelessWidget {
  const ListScreenDisplaySettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      title: "List Screen",
      onTap: () => context.push('/settings/list'),
    );
  }
}

class GlobalDisplaySettingsTile extends StatelessWidget {
  const GlobalDisplaySettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      title: "Global",
      onTap: () => context.push('/settings/global'),
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

class SettingsSecTitle extends StatelessWidget {
  const SettingsSecTitle({
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
          title: Text("Language"),
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
      trailingWidget: Text(selectedCurrencySymbol, style: context.tt.bodyMedium),
      onTap: () async {
        final response = await context.push<Currency>('/settings/currencies');
        if (response != null) {
          if (context.mounted) {
            context.settingMod.updateCurrency(response);
          }
        }
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
    this.verticalPadding = 4,
    this.horizontalPadding = 12,
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
      title: title != null ? Text(title!, style: context.tt.bodyMedium) : titleWidget,
      subtitle: subtitle,
      dense: true,
      trailing: trailingWidget,
      leading: leading,
      // leadingAndTrailingTextStyle: Theme.of(context).textTheme.bodyMedium,
      contentPadding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: 4,
        bottom: verticalPadding,
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

class ExportDataSettingsTile extends StatelessWidget {
  const ExportDataSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      title: AppLocale.exportData.getString(context),
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
            DismissTextButton(
              onTap: () => Navigator.pop(context),
            ),
            AffirmativeTextButton(
              onTap: () async {
                // await context.read<SettingsViewModel>().exportCostItemData();
                await context.read<ExporterServices>().exportData();
              },
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
    // {
    //   "function": "Append",
    //   "desc": "Import selected file's data into existing list.",
    //   "overwrite": false,
    //   "flushMsg": "Data appended",
    // },
    // {
    //   "function": "Overwrite",
    //   "desc": "Replace existing list with selected file's data. Previous data will be deleted.",
    //   "overwrite": true,
    //   "flushMsg": "Data overwrited",
    // },
    {
      "function": "Load everything",
      "desc": "Replace all items and saved configuration from exported json.",
      "overwrite": true,
      "flushMsg": "Data overwrited",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      title: AppLocale.loadData.getString(context),
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
                      final result = await context.read<ExporterServices>().loadData();
                      if (context.mounted) {
                        switch (result) {
                          case Ok():
                            context.read<CostItemRepository>().restart();
                            context.read<CategoryRepository>().restart();
                            context.read<CurrencyRepository>().restart();
                            context.read<ExchangeRateRepository>().restart();
                            context.read<GoalRepository>().restart();
                            context.read<SavedItemRepository>().restart();
                            context.read<SharedElementRepository>().restart();
                          case Error():
                        }
                      }
                      if (context.mounted) {
                        context.go('/');
                      }
                      // final result = await context.read<SettingsViewModel>().loadData();
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
      title: AppLocale.clearData.getString(context),
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
                                    // await context.read<AppModel>().clearCostItem();
                                    // if (context.mounted) {
                                    //   Navigator.pop(context);
                                    //   context
                                    //       .read<NavigatorModel>()
                                    //       .popBackToMainScreenAndRefresh();
                                    // }
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

class CurrencyAdditionalSettingsTile extends StatelessWidget {
  const CurrencyAdditionalSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      title: "Additional Currency Settings",
      onTap: () {
        context.push("/settings/currency-setting");
      },
    );
  }
}

class KeyboardSettingsTile extends StatelessWidget {
  const KeyboardSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      title: "Keyboard Settings",
      onTap: () {
        context.push('/settings/keyboard');
      },
    );
  }
}

class ChangeLanguageSettingsTile extends StatelessWidget {
  const ChangeLanguageSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = FlutterLocalization.instance;
    return CustomSettingsTile(
      title: AppLocale.changeLanguage.getString(context),
      trailingWidget: Text(localization.getLanguageName(), style: context.tt.bodyMedium),
      onTap: () {
        context.push('/settings/languages');
      },
    );
  }
}

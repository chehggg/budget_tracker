
import 'package:another_flushbar/flushbar.dart';
import 'package:budget_tracker/models/navigation_model.dart';
import 'package:budget_tracker/utility/currency.dart';
import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  // final _localization = FlutterLocalization.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0,0,0,0),
          child: SettingsList(),
        )
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
    final selectedCurrencySymbol = context.select((AppModel state) => 
      '${state.currencySymbol} (${state.currencyName})'
    );
    final selectedLanguage = context.select((ThemeModel state) {
      switch (state.appLocale.languageCode) {
        case "en" :
         return "English";
        case "zh" :
         return "中文（简体）";
        case "ja" :
         return "日本語";
        default :
         return "Undefined";
      }
    });
    return Material(
      child: ListView(
        children: [
          ThemeModeSetting(selectedThemeMode: selectedThemeMode),
          CurrencySettings(selectedCurrencySymbol: selectedCurrencySymbol),
          LanguageSetting(selectedLanguage: selectedLanguage),
          ListTile(
            title: Text(AppLocalizations.of(context)!.blurSettings),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            trailing: Text(selectedLanguage, style: Theme.of(context).textTheme.labelLarge),
            // onTap: () => changeLanguageDialog(context) 
          ),
          ListTile(
            title: Text("Font Size"),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            // trailing: Text(selectedLanguage, style: Theme.of(context).textTheme.labelLarge),
          ),
          const ListTile(
            title: Text("Data"),
          ),
          const Divider(thickness: 1,),
          const ExportDataSetting(),
          const LoadDataSetting(),
          const ClearDataSetting(),
          const SyncFirebaseDataSetting()
        ],
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
      title: Text(AppLocalizations.of(context)!.language),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      trailing: Text(
        selectedLanguage,
        style: Theme.of(context).textTheme.labelLarge
      ),
      onTap: () => changeLanguageDialog(context) 
    );
  }

  Future changeLanguageDialog(BuildContext context) {
    const List<Map<String,String>>languages = [
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
      builder:(context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.changeLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((language) =>
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.only(),
                title: Text(language['display']!),
                onTap: () {
                  context.read<ThemeModel>().updateLanguage(language['locale']!);
                  Navigator.pop(context);
                },
              ),
            ).toList(),
          )
        );
      }
    );
  }
}

class CurrencySettings extends StatelessWidget {
  const CurrencySettings({
    super.key,
    required this.selectedCurrencySymbol,
  });

  final String selectedCurrencySymbol;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.currency),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      trailing: Text(
        selectedCurrencySymbol,
        style: Theme.of(context).textTheme.labelLarge
      ),
      onTap: () => changeCurrencyDialog(context) 
    );
  }

  Future changeCurrencyDialog(BuildContext context) {

    return showDialog(
      context: context, 
      builder:(context) {
        return const CurrencyListDialog();
      }
    );
  }
}

class ThemeModeSetting extends StatelessWidget {
  const ThemeModeSetting({
    super.key,
    required this.selectedThemeMode,
  });

  final ThemeMode selectedThemeMode;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // title: Text("Theme Mode"),
      title: Text(AppLocalizations.of(context)!.themeMode),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      trailing: DropdownMenu(
        inputDecorationTheme: InputDecorationTheme(
          border: InputBorder.none
        ),
        leadingIcon: Icon(getThemeModeIcon(selectedThemeMode)),
        initialSelection: selectedThemeMode,
        dropdownMenuEntries: ThemeMode.values.map((ThemeMode mode) {
          return DropdownMenuEntry(
            value: mode, 
            label: mode.name,
            leadingIcon: Icon(getThemeModeIcon(mode)) 
          );
        }).toList(), 
        onSelected: (ThemeMode? mode) {
          if (mode != null) {
            context.read<ThemeModel>().updateTheme(mode);
          }
        }
      ),
      // subtitle: Text("Theme Mode"),
    );
  }
}

class CurrencyListDialog extends StatefulWidget {
  const CurrencyListDialog({super.key});

  @override
  State<CurrencyListDialog> createState() => _CurrencyListDialogState();
}

class _CurrencyListDialogState extends State<CurrencyListDialog> {
  List<Map<String,dynamic>> _displayedCurrencies = [];
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
    final selectedCurrencyIndex = currencies.indexWhere((currency) => 
      currency['symbol'] == _selectedCurrencySymbol &&
      currency['name'] == _selectedCurrencyName
    );
    debugPrint(selectedCurrencyIndex.toString());
    if (selectedCurrencyIndex != -1) {
      defaultCurrency.removeRange(selectedCurrencyIndex, selectedCurrencyIndex + 1);
      
      setState(() {
        _displayedCurrencies = [
          currencies[selectedCurrencyIndex], 
          // ...defaultCurrency
          ...defaultCurrency
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
      final selectedCurrencyIndex = currencies.indexWhere((currency) => 
        currency['symbol'] == _selectedCurrencySymbol &&
        currency['name'] == _selectedCurrencyName
      );
      debugPrint(selectedCurrencyIndex.toString());
      if (selectedCurrencyIndex != -1) {
        defaultCurrency.removeRange(selectedCurrencyIndex, selectedCurrencyIndex + 1);
        setState(() {
          _displayedCurrencies = [
            currencies[selectedCurrencyIndex],
            ...defaultCurrency.where((currency) => 
              (currency['name'] as String).toLowerCase().contains(query) ||
              (currency['symbol'] as String).toLowerCase().contains(query) 
            )
          ];
        });
      }  
    }
  }

  @override
  Widget build(BuildContext context) {
    // final selectedCurrencySymbol = context.select((AppModel state) => state.currencySymbol); 
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.changeCurrency),
      content: SizedBox(
        height: MediaQuery.of(context).size.height* 0.5,
        width: MediaQuery.of(context).size.width* 0.7,
        child: Column(
          spacing: 10,
          children: [
            TextFormField(
              controller: _controller,
              onChanged: searchCurrency,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide.none),
                prefixIcon: Icon(Icons.search),
                hintText: AppLocalizations.of(context)!.searchCurrency,
                hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(100)
                ),
                fillColor: Theme.of(context).colorScheme.surfaceDim,
              ),
            ),
            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: _displayedCurrencies.length,
                  itemBuilder:(context, index) {
                    final Map<String,dynamic> currency = _displayedCurrencies.elementAt(index);
                    final Icon? icon;
                    if (_selectedCurrencySymbol == currency['symbol'] && _selectedCurrencyName == currency['name']) {
                      icon = Icon(Icons.check);
                    } else {
                      icon = null;
                    }
                    return ListTile(
                      dense: true,
                      title: Text('${currency['symbol'] as String} (${currency['name'] as String})'),
                      trailing: icon,
                      onTap: () {
                        setState(() {
                          _selectedCurrencySymbol = _displayedCurrencies.elementAt(index)['symbol'] as String;
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

class ExportDataSetting extends StatelessWidget {
  const ExportDataSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("Export data"),
      onTap: () => showExportDialog(context),
    );
  }

  Future showExportDialog(BuildContext context) {
    return showDialog(
      context: context, 
      builder:(context) {
        return AlertDialog(
          title: const Text("Export data"),
          content: const Text("Press confirm to export the cost item as CSV into your desired location"),
          actions: [
            TextButton(
              onPressed: () async {
                final outputPath = await context.read<AppModel>().exportCostItem();
                if (context.mounted) {
                  Navigator.pop(context);
                  if (outputPath != null) {
                    Flushbar(
                      // title: "Saved!",
                      message: "File successfully saved to $outputPath",
                      flushbarPosition: FlushbarPosition.TOP,
                      duration: Duration(seconds: 3),
                      flushbarStyle: FlushbarStyle.GROUNDED,
                    ).show(context);
                  }
                }
              }, 
              child: const Text("confirm")
            ),
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("cancel")
            ),
          ],
        );
      },
    );
  }
}

class LoadDataSetting extends StatelessWidget {
  const LoadDataSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("Load data"),
      onTap: () => showExportDialog(context),
    );
  }

  Future showExportDialog(BuildContext context) {
    return showDialog(
      context: context, 
      builder:(context) {
        return AlertDialog(
          title: const Text("Load data"),
          content: const Text("Warning: Loading a csv file will overwrite all existing data. Please make sure you have exported current data for backup to prevent data loss"),
          actions: [
            TextButton(
              onPressed: () async {
                final result = await context.read<AppModel>().loadCostItemFromFile();

                if (context.mounted) {
                  Navigator.pop(context);
                  switch (result) {
                    case 0: // error reading file
                      Flushbar(
                        title: "Error",
                        message: 'File is not readable, please try another file',
                      ).show(context); 
                      break; 
                    case 1: // file read successfully
                      context.read<NavigationModel>().backToHomeScreen();
                      Flushbar(
                        message: 'File loaded successfully!',
                        flushbarPosition: FlushbarPosition.TOP,
                        duration: Duration(seconds: 3),
                        flushbarStyle: FlushbarStyle.GROUNDED,
                      ).show(context);
                      break; 
                    case 2: // user cancels file picker
                      break;
                    default:
                      break;
                  }
                }
              }, 
              child: const Text("Proceed")
            ),
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Cancel")
            ),
          ],
        );
      },
    );
  }
}

class ClearDataSetting extends StatelessWidget {
  const ClearDataSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("Clear data"),
      onTap: () => showClearDialog(context),
    );
  }

  Future showClearDialog(BuildContext context) {
    return showDialog(
      context: context, 
      builder:(context) {
        return AlertDialog(
          title: const Text("Clear data"),
          content: const Text("Warning: This will remove all existing data. It is advisable to perform backup beforehand"),
          actions: [
            TextButton(
              onPressed: () async {
                await context.read<AppModel>().clearCostItem();
                if (context.mounted) {
                  Navigator.pop(context);
                  context.read<NavigationModel>().backToHomeScreen();
                }
              }, 
              child: const Text("Clear")
            ),
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Cancel")
            ),
          ],
        );
      },
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
      trailing: Switch(
        value: false, 
        onChanged: (value) {}
      ),
    );
  }
}
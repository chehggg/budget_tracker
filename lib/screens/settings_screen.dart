
import 'package:budget_tracker/currency.dart';
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
          ListTile(
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
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.currency),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            trailing: Text(
              selectedCurrencySymbol,
              style: Theme.of(context).textTheme.labelLarge
            ),
            onTap: () => changeCurrencyDialog(context) 
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.language),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            trailing: Text(
              selectedLanguage,
              style: Theme.of(context).textTheme.labelLarge
            ),
            onTap: () => changeLanguageDialog(context) 
          ),
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
          )
        ],
      ),
    );
  }
  
  Future changeCurrencyDialog(BuildContext context) {
    return showDialog(
      context: context, 
      builder:(context) {
        return CurrencyListDialog();
      }
    );
  }

  Future changeLanguageDialog(BuildContext context) {
    return showDialog(
      context: context, 
      builder:(context) {
        return LanguageListDialog();
      }
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

class LanguageListDialog extends StatelessWidget {
  LanguageListDialog({super.key});

  final List<Map<String,String>>languages = [
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

  @override
  Widget build(BuildContext context) {
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
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModel extends ChangeNotifier {
  //constructor
  ThemeModel() {
    initSettings();
  }

  Locale _appLocale = Locale("en");
  Locale get appLocale => _appLocale;
  
  ThemeMode _theme = ThemeMode.system;
  ThemeMode get theme => _theme;

  bool _isBlurApplied = false;
  bool get isBlurApplied => _isBlurApplied;

  void toggleBlur() {
    _isBlurApplied = !_isBlurApplied;
    notifyListeners();
  }

  void updateTheme(ThemeMode mode) async {
    _theme = mode;
    notifyListeners();

    final sharedPref = SharedPreferencesAsync();
    await sharedPref.setString("theme_mode", mode.name);
  } 

  void initSettings() async {
    debugPrint("Reading theme data"); 
    final sharedPref = SharedPreferencesAsync();
    final sharedPrefTheme = await sharedPref.getString("theme_mode");
    
    if (sharedPrefTheme != null) {
      _theme = ThemeMode.values[ThemeMode.values.indexWhere((ThemeMode mode) => 
        mode.name == sharedPrefTheme
      )];
      debugPrint("value found in shared pref, theme: $_theme");
    }

    final sharedPrefLocale = await sharedPref.getString("locale");
    
    if (sharedPrefLocale != null) {
      _appLocale = Locale(sharedPrefLocale);
      debugPrint("value found in shared pref, locale: $_theme");
    }

    notifyListeners();
  }

  void updateLanguage(String localeName) async {
    _appLocale = Locale(localeName);
    notifyListeners();

    final sharedPref = SharedPreferencesAsync();
    await sharedPref.setString("locale", localeName);
  }
}
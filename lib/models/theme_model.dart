import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ValueBlur { none, summary, list, all }

Color hexToColor(String code) {
  // Remove '#' if present
  String hexCode = code.replaceFirst('#', '');
  
  // Ensure the hex code is the correct length (6 digits for RRGGBB)
  if (hexCode.length == 6) {
    hexCode = 'FF$hexCode'; // Add full opacity (AA)
  }
  
  // Parse the hex string as an integer with radix 16
  return Color(int.parse(hexCode, radix: 16));
}

class ThemeModel extends ChangeNotifier {
  //constructor
  ThemeModel() {
    initSettings();
  }

  //init settings
  void initSettings() async {
    debugPrint("Reading theme data"); 
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

    _fontSizeFactor = await sharedPref.getInt('fontFactor') ?? 3;
    _spacingValue = await sharedPref.getInt('spacing') ?? 3;
    _gridSize = await sharedPref.getInt('grid') ?? 4;
    _color = hexToColor(await sharedPref.getString('color')?? "FFF");
    _defaultBlur = ValueBlur.values[await sharedPref.getInt('defBlur') ?? 0]; 

    switch (_defaultBlur) {
      case ValueBlur.all:
        _isSummaryBlurred = true; 
        _isListBlurred = true; 
      case ValueBlur.summary:
        _isSummaryBlurred = true; 
      case ValueBlur.list:
        _isListBlurred = true; 
      default: 
        break;
    }

    notifyListeners();
  }


  Locale _appLocale = Locale("en");
  Locale get appLocale => _appLocale;
  
  ThemeMode _theme = ThemeMode.system;
  ThemeMode get theme => _theme;

  bool _isSummaryBlurred = false;
  bool get isSummaryBlurred => _isSummaryBlurred;
  
  bool _isListBlurred = false;
  bool get isListBlurred => _isListBlurred;

  ValueBlur _defaultBlur = ValueBlur.none;
  ValueBlur get defaultBlur => _defaultBlur;

  int _spacingValue = 3;
  int get spacingValue => _spacingValue;
  
  int _fontSizeFactor = 3;
  int get fontSizeFactor => _fontSizeFactor;
  
  int _gridSize = 4;
  int get gridSize => _gridSize;

  Color _color = Colors.green;
  Color get color => _color;

  final sharedPref = SharedPreferencesAsync();
  
  void updateColor(Color newColor) async {
    _color = newColor;
    notifyListeners();

    await sharedPref.setString("color", _color.toHexString());
  }

  void updateDefaultBlur(ValueBlur blur, bool value) async {
    if (blur == ValueBlur.all) {
      _defaultBlur = value ? ValueBlur.all : ValueBlur.none;
    } else if (!value && _defaultBlur == blur) {
      _defaultBlur = ValueBlur.none;
    } else if (value && _defaultBlur == ValueBlur.none) {
      _defaultBlur = blur;
    } else if (!value && _defaultBlur == ValueBlur.all) {
      _defaultBlur = blur == ValueBlur.summary ? ValueBlur.list: ValueBlur.summary;
    } else {
      _defaultBlur = ValueBlur.all;
    }
    debugPrint("current blur: ${_defaultBlur.name}");
    notifyListeners();
    await sharedPref.setInt("defBlur", _defaultBlur.index);
  }

  void updateSpacingValue(int value) async {
    _spacingValue = value;
    notifyListeners();
    
    await sharedPref.setInt("spacing", _spacingValue);
  }

  void updateFontSizeFactor(int value) async{
    _fontSizeFactor = value;
    notifyListeners();
    
    await sharedPref.setInt("fontFactor", _fontSizeFactor);
  }

  void updateGridSize(int value) async{
    _gridSize = value;
    notifyListeners();
    
    await sharedPref.setInt("grid", _gridSize);
  }

  void toggleBlur() async {
    _isSummaryBlurred = !_isSummaryBlurred;
    _isListBlurred = !_isListBlurred;
    notifyListeners();
  }

  void updateTheme(ThemeMode mode) async {
    _theme = mode;
    notifyListeners();

    // final sharedPref = SharedPreferencesAsync();
    await sharedPref.setString("theme_mode", mode.name);
    debugPrint("current mode: ${mode.name}");
  } 



  void updateLanguage(String localeName) async {
    _appLocale = Locale(localeName);
    notifyListeners();

    final sharedPref = SharedPreferencesAsync();
    await sharedPref.setString("locale", localeName);
  }
}
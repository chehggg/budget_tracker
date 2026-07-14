import 'dart:async';

import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/data/services/local_service.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:flutter/material.dart';

class SharedElementRepository {
  SharedElementRepository({required LocalServices localServices}) : _localServices = localServices {
    _initFuture = init();
  }

  final LocalServices _localServices;

  Future<void> init() async {
    final layoutResult = await _localServices.getKeyboardLayout();

    switch (layoutResult) {
      case Ok():
        _keyboardLayout = layoutResult.value ?? KeyboardLayout.simple;
      case Error():
        _keyboardLayout = KeyboardLayout.simple;
    }

    final keyboardSettingsResult = await _localServices.getKeyboardSettings();
    switch (keyboardSettingsResult) {
      case Ok():
        _keyboardSettings = keyboardSettingsResult.value ?? _keyboardSettings;
      case Error():
        _keyboardSettings = _keyboardSettings;
    }

    final buttonResult = await _localServices.getKeyboardButton();
    switch (buttonResult) {
      case Ok():
        _keyboardButton = buttonResult.value ?? SimpleKeyboardButtonType.decimal;
      case Error():
        _keyboardButton = SimpleKeyboardButtonType.decimal;
    }

    final formGridResult = await _localServices.getFormGrid();
    switch (formGridResult) {
      case Ok():
        _formGridColumn = formGridResult.value ?? _formGridColumn;
      case Error():
        _formGridColumn = 4;
    }

    final listConfigResult = await _localServices.getListConfig();
    switch (listConfigResult) {
      case Ok():
        _listConfig = listConfigResult.value ?? _listConfig;
      case Error():
        _listConfig = _listConfig;
    }
  }

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Stream<bool> get sharedStream => _controller.stream;

  late final Future<void> _initFuture;
  Future<void> get ready => _initFuture;

  KeyboardSettings _keyboardSettings = KeyboardSettings();
  KeyboardSettings get keyboardSettings => _keyboardSettings;

  DateTime _displayDate = DateTime.now();
  DateTime get displayDate => _displayDate;

  YearMonth _yearMonth = YearMonth(useRange: false, date1: DateTime.now().startOfMonth);
  YearMonth get currentYearMonth => _yearMonth;
  
  KeyboardLayout _keyboardLayout = KeyboardLayout.simple;
  KeyboardLayout get keyboardLayout => _keyboardLayout;

  SimpleKeyboardButtonType _keyboardButton = SimpleKeyboardButtonType.decimal;
  SimpleKeyboardButtonType get keyboardButton => _keyboardButton;

  int _formGridColumn = 4;
  int get formGridColumn => _formGridColumn;

  ListDisplayConfig _listConfig = ListDisplayConfig();
  ListDisplayConfig get listScreenConfig => _listConfig;

  // bool _hideOnStart = false;
  // bool get hideOnStart => _hideOnStart;

  // bool _showAmountColor = false;
  // bool get showAmountColor => _showAmountColor;

  // bool _showTotalColor = false;
  // bool get showTotalColor => _showTotalColor;

  AccentColor _accColor = AccentColor(
    positive: Colors.green,
    negative: Colors.red,
    previous: Colors.blue,
    current: Colors.amber,
  );
  AccentColor get accentColors => _accColor;

  void updateDisplayDate(DateTime newDate) {
    _displayDate = newDate;
  }

  void updateKeyboardLayout(KeyboardLayout newLayout) async {
    _keyboardSettings = _keyboardSettings.copyWith(layout: newLayout);
    await _localServices.writeKeyboardSettings(_keyboardSettings);
    _controller.add(true);
  }

  void updateKeyboardButtonSwitch(bool value) async {
    _keyboardSettings = _keyboardSettings.copyWith(customButtonReversed: value);
    await _localServices.writeKeyboardSettings(_keyboardSettings);
    _controller.add(true);
  }

  void updateKeyboardRowSwitch(bool value) async {
    _keyboardSettings = _keyboardSettings.copyWith(rowReversed: value);
    await _localServices.writeKeyboardSettings(_keyboardSettings);
    _controller.add(true);
  }

  void updateFormGrid(int count) async {
    _formGridColumn = count;
    await _localServices.writeFormGrid(_formGridColumn);
    _controller.add(true);
  }

  void updateKeyboardCustomButton(SimpleKeyboardButtonType newButton) async {
    _keyboardButton = newButton;
    await _localServices.writeKeyboardButton(_keyboardButton);
    _controller.add(true);
  }

  void toggleHideOnStart(bool? value) async {
    _listConfig = _listConfig.copyWith(hideAmountOnStart: value);
    await _localServices.writeListConfig(_listConfig);
    _controller.add(true);
  }

  void toggleShowAmountColor(bool? value) async {
    _listConfig = _listConfig.copyWith(showAmountColor: value);
    await _localServices.writeListConfig(_listConfig);
    _controller.add(true);
  }

  void toggleShowTotalColor(bool? value) async {
    _listConfig = _listConfig.copyWith(showTotalColor: value);
    await _localServices.writeListConfig(_listConfig);
    _controller.add(true);
  }

  void updateAccentColor(AccentColor colors) async {
    _accColor = colors;
    await _localServices.writeNumberColor(_accColor);
    _controller.add(true);
  }

  void resetAccentColor() async {
    _accColor = AccentColor(
      positive: Colors.green,
      negative: Colors.red,
      previous: Colors.blue,
      current: Colors.amber,
    );
    await _localServices.writeNumberColor(_accColor);
    _controller.add(true);
  }

  // void updatePositiveAmountColor(SimpleKeyboardButtonType newButton) async {
  //   _keyboardButton = newButton;
  //   await _localServices.writeKeyboardButton(_keyboardButton);
  //   _controller.add(true);
  // }

  // void updateNegativeAmountColor(SimpleKeyboardButtonType newButton) async {
  //   _keyboardButton = newButton;
  //   await _localServices.writeKeyboardButton(_keyboardButton);
  //   _controller.add(true);
  // }
}

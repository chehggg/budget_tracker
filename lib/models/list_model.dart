import 'package:flutter/material.dart';

class ListModel extends ChangeNotifier {
  bool _isSearchOpened = false;
  bool get isSearchOpened => _isSearchOpened;
  
  bool _isBlurred = false;
  bool get isBlurred => _isBlurred;

  void toggleSearch([bool? value]) {
    if (value != null) {
      _isSearchOpened = value;
    } else {
      _isSearchOpened = !_isSearchOpened;
    }
    notifyListeners();
  }

  void toggleBlur({bool? value}) {
    if (value != null) {
      _isBlurred = value;
    } else {
      _isBlurred = !_isBlurred;
    }
    notifyListeners();
  }
}

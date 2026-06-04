import 'package:budget_tracker/custom/class.dart';
import 'package:flutter/material.dart';

class NavigationModel extends ChangeNotifier {
  final _navigationKey = GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState>  get navigationKey => _navigationKey;
  
  final List<String> _routeName = [
    "/",
    "/data",
    "/report",
    "/settings"
  ];

  int _currentRouteIndex = 0;
  int  get currentRouteIndex => _currentRouteIndex;

  bool _isFormOpened = false;
  bool get isFormOpened => _isFormOpened;
  // String currentRoute = "/";
  String get currentMainScreenRoute => _routeName.elementAt(_currentRouteIndex);
  
  

  void navigateMainScreen(int index) {
    _currentRouteIndex = index;
    notifyListeners();

    navigationKey.currentState!.pushNamedAndRemoveUntil(
      currentMainScreenRoute,
      ModalRoute.withName(currentMainScreenRoute)
    );
    debugPrint("navigator push new page, index: $index ");
  }

  void backToHomeScreen() {
    navigationKey.currentState!.pushNamedAndRemoveUntil(
      '/',
      ModalRoute.withName('/'),
    );
    _currentRouteIndex = 0;

    notifyListeners();
  }
  
  void openForm(FormArgument argument) {
    navigationKey.currentState!.pushNamedAndRemoveUntil(
      '/form',
      ModalRoute.withName('/form'),
      arguments: argument
    );

    _isFormOpened = true;
    notifyListeners();
  }

  void popFormToMain({String? oriRoute}) {
    _isFormOpened = false;
    notifyListeners();

    navigationKey.currentState!.pushNamedAndRemoveUntil(
      _routeName[_currentRouteIndex], 
      ModalRoute.withName(_routeName[_currentRouteIndex])
    );

    // Navigator.of(context).push
  }
  
}
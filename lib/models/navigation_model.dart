import 'package:budget_tracker/custom/classes/class.dart';
import 'package:flutter/material.dart';

class NavigationModel extends ChangeNotifier {
  final _navigationKey = GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState> get navigationKey => _navigationKey;

  final List<String> _routeName = ["/", "/data", "/goals", "/settings"];

  int _currentRouteIndex = 0;
  int get currentRouteIndex => _currentRouteIndex;

  // bool _isFormOpened = false;
  // bool get isFormOpened => _isFormOpened;
  // bool get showBottomNavBar => _routeName.contains(_pathName);
  bool get showBottomNavBar => _pathName != "/form";
  String get currentMainScreenRoute => _routeName.elementAt(_currentRouteIndex);

  String _pathName = "/";
  String get pathName => _pathName;

  String? get currentRouteName {
    String? currentPath;

    _navigationKey.currentState?.popUntil((route) {
      currentPath = route.settings.name;
      return true; // Return true immediately so it doesn't actually pop anything
    });

    debugPrint('get current route: ${currentPath}');
    return currentPath;
  }

  void goTo(String path) {
    navigationKey.currentState!.pushNamed(path);
    _pathName = path;
    notifyListeners();
  }

  void navigateMainScreen(int index) {
    _currentRouteIndex = index;
    _pathName = currentMainScreenRoute;
    notifyListeners();

    navigationKey.currentState!.pushNamedAndRemoveUntil(
      currentMainScreenRoute,
      ModalRoute.withName(currentMainScreenRoute),
    );
    debugPrint("navigator push new page, index: $index ");
  }

  void backToHomeScreen() {
    navigationKey.currentState!.pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
    _currentRouteIndex = 0;

    notifyListeners();
  }

  void openForm(FormArgument argument) {
    navigationKey.currentState!.pushNamedAndRemoveUntil(
      '/form',
      ModalRoute.withName('/form'),
      arguments: argument,
    );
    _pathName = "/form";
    // _isFormOpened = true;
    notifyListeners();
  }

  void popFormToMain({String? oriRoute}) {
    _pathName = currentMainScreenRoute;
    notifyListeners();

    navigationKey.currentState!.pushNamedAndRemoveUntil(
      currentMainScreenRoute,
      (route) => false
    );
  }

  void toGoalScreen() {
    navigationKey.currentState!.pushNamedAndRemoveUntil('/goals', ModalRoute.withName('/goals'));
  }
}

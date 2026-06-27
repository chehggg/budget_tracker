import 'package:budget_tracker/custom/classes/class.dart';
import 'package:flutter/material.dart';

class NavigatorModel extends ChangeNotifier {
  NavigatorModel() {
    init();
  }

  void init() {
    _paths = ['/'];
    notifyListeners();
  }

  final _navigationKey = GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState> get navigationKey => _navigationKey;

  final List<String> _mainRoutes = ["/", "/data", "/goals", "/settings"];

  int _currentRouteIndex = 0;
  int get currentRouteIndex => _currentRouteIndex;

  bool get showBottomNavBar => _pathName != "/form";
  String get currentMainScreenRoute => _mainRoutes.elementAt(_currentRouteIndex);

  bool _hideBottom = false;
  // bool get showBottom => _showBottom;
  bool get showBottom => _mainRoutes.contains(_paths.lastOrNull ?? "") && !_hideBottom;

  List<String> _paths = [];
  // String get pathName => _pathName;

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

  Future<void> goToNamed(String newPath, {Object? arguments}) async {
    _paths = [..._paths, newPath];
    notifyListeners();
    await navigationKey.currentState!.pushNamed(newPath, arguments: arguments);
    // toggleBottom(_mainRoutes.contains(newPath));
  }

  void goToNamedAndRemovePrevious(String newPath, {Object? arguments}) {
    _paths = [newPath];
    notifyListeners();
    navigationKey.currentState!.pushNamedAndRemoveUntil(
      newPath,
      (route) => false,
      arguments: arguments,
    );
  }

  Future<void> goTo(Route route) async {
    _paths = [..._paths, ""];
    notifyListeners();
    await navigationKey.currentState!.push(route);
  }

  void pop([Object? value]) {
    navigationKey.currentState!.pop(value);
    _paths.removeLast();
    notifyListeners();
  }

  void navigateMainScreen(int newIndex) {
    final prevIndex = _currentRouteIndex;
    _currentRouteIndex = newIndex;
    notifyListeners();

    goToNamedAndRemovePrevious(currentMainScreenRoute, arguments: prevIndex > newIndex);
    // debugPrint("navigator push new page, index: $index ");
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

  void customHideBottom(bool value) {
    _hideBottom = value;
    notifyListeners();
  }

  void popFormToMain({String? oriRoute}) {
    _pathName = currentMainScreenRoute;
    notifyListeners();

    navigationKey.currentState!.pushNamedAndRemoveUntil(currentMainScreenRoute, (route) => false);
  }

  void toGoalScreen() {
    navigationKey.currentState!.pushNamedAndRemoveUntil('/goals', ModalRoute.withName('/goals'));
  }
}

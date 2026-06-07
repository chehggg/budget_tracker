import 'package:budget_tracker/config/providers.dart';
import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/firebase_options.dart';
import 'package:budget_tracker/models/navigation_model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:budget_tracker/screens/settings/budget_settings_screen.dart';
import 'package:budget_tracker/screens/settings/recurring_settings_screen.dart';
import 'package:budget_tracker/ui/core/themes/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';

import 'package:budget_tracker/screens/chart_screen.dart';
import 'package:budget_tracker/ui/form/form_screen.dart';
import 'package:budget_tracker/ui/list/list_screen.dart';
import 'package:budget_tracker/screens/report_screen.dart';
import 'package:budget_tracker/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await FlutterLocalization.instance.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: providers,
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint("main rebuild");

    return MaterialApp(
      locale: context.select((ThemeModel state) => state.appLocale),
      theme: appTheme,
      themeMode: context.select((ThemeModel state) => state.theme),
      darkTheme: appTheme,
      home: const HomeScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationModel = context.watch<NavigationModel>();
    final navKey = navigationModel.navigationKey;
    final currentNavRoute = navigationModel.currentMainScreenRoute;
    final isFormOpened = navigationModel.isFormOpened;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // debugPrint("popped!, current navigator route : $currentNavRoute");
        if (didPop) return;
        if (isFormOpened) {
          navigationModel.popFormToMain();
        } else {
          showPopDialog(context);
        }
      },
      child: Scaffold(
        body: Navigator(
          key: navKey,
          initialRoute: "/",
          onGenerateRoute: (settings) {
            // debugPrint("navigator generate route");
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(
                  builder: (context) => CostListScreen(),
                  settings: RouteSettings(name: settings.name),
                );
              case '/form':
                return MaterialPageRoute(
                  builder: (context) {
                    return CostItemFormScreen(arg: settings.arguments as FormArgument);
                  },
                  settings: RouteSettings(name: settings.name),
                );
              case '/data':
                return MaterialPageRoute(
                  builder: (context) => const ChartScreen(),
                  settings: RouteSettings(name: settings.name),
                );
              case '/report':
                return MaterialPageRoute(
                  builder: (context) => const CostReportScreen(),
                  settings: RouteSettings(name: settings.name),
                );
              case '/settings':
                return MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                  settings: RouteSettings(name: settings.name),
                );
              case '/budgets':
                return MaterialPageRoute(
                  builder: (context) => const SetBudgetScreen(),
                  // settings: RouteSettings(name: settings.name)
                );
              case '/recurring':
                return MaterialPageRoute(
                  builder: (context) => const RecurringCostScreen(),
                  // settings: RouteSettings(name: settings.name)
                );
              default:
                return MaterialPageRoute(builder: (context) => const Placeholder());
              // throw UnimplementedError();
            }
          },
        ),
        floatingActionButton: navigationModel.isFormOpened ? null : CustomFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: isFormOpened ? null : CustomNavigationBottomBar(),
      ),
    );
  }

  Future showPopDialog(BuildContext context) => showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Exit app?"),
        content: Text("Exit app"),
        actions: [
          TextButton(onPressed: null, child: Text("Exit")),
          TextButton(onPressed: null, child: Text("Cancel")),
        ],
      );
    },
  );
}

class CustomFAB extends StatelessWidget {
  const CustomFAB({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
      onPressed: () => context.read<NavigationModel>().openForm(FormArgument()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(30)),
      enableFeedback: true,
      elevation: 0,
      foregroundColor: context.cs.surfaceContainer,
      backgroundColor: context.cs.primary,
      child: Icon(Icons.add),
    );
  }
}

class CustomNavigationBottomBar extends StatelessWidget {
  CustomNavigationBottomBar({
    super.key,
  });

  final List<IconData> buttons = [
    Icons.home, // list
    Icons.auto_graph, // chart
    Icons.dataset_linked, // report
    Icons.settings, // settings
  ];

  @override
  Widget build(BuildContext context) {
    final pageIndex = context.select((NavigationModel state) => state.currentRouteIndex);
    return BottomAppBar(
      notchMargin: 10,
      shape: CircularNotchedRectangle(),
      child: Row(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            buttons
                .asMap()
                .map((index, buttonIcon) {
                  Widget iconButton;
                  if (pageIndex == index) {
                    iconButton = IconButton.filled(
                      onPressed: () => {},
                      icon: Icon(
                        buttonIcon,
                        color: context.cs.surface,
                      ),
                      iconSize: 32,
                    );
                  } else {
                    iconButton = IconButton(
                      onPressed: () => context.read<NavigationModel>().navigateMainScreen(index),
                      icon: Icon(buttonIcon),
                      iconSize: 28,
                    );
                  }
                  return MapEntry(index, iconButton);
                })
                .values
                .toList()
              ..insert(
                2,
                SizedBox(
                  width: 80,
                ),
              ), // add space for FAB
      ),
    );
  }
}

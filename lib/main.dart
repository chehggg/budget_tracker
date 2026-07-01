import 'package:budget_tracker/config/providers.dart';
import 'package:budget_tracker/config/router.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/classes/navigator_argument.dart';
import 'package:budget_tracker/custom/classes/page_transition.dart';
import 'package:budget_tracker/custom/classes/saved_item_class.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/firebase_options.dart';
import 'package:budget_tracker/models/navigator_model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:budget_tracker/screens/settings/currency_screen.dart';
import 'package:budget_tracker/ui/core/themes/theme.dart';
import 'package:budget_tracker/ui/goal/goal_form_screen.dart';
import 'package:budget_tracker/ui/goal/goal_list_screen.dart';
import 'package:budget_tracker/ui/list/main_list_viewmodel.dart';
import 'package:budget_tracker/ui/saved_item/saved_item_screen.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';

import 'package:budget_tracker/ui/chart/chart_screen.dart';
import 'package:budget_tracker/ui/form/form_screen.dart';
import 'package:budget_tracker/ui/list/main_list_screen.dart';
import 'package:budget_tracker/ui/settings/settings_screen.dart';

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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // debugPrint("main rebuild");

    return MaterialApp.router(
      routerConfig: goRouter,
      locale: context.select((ThemeModel state) => state.appLocale),
      theme: appTheme,
      themeMode: context.select((ThemeModel state) => state.theme),
      darkTheme: appTheme,
      // home: const HomeScreen(),
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
    final navigationModel = context.watch<NavigatorModel>();
    final navKey = navigationModel.navigationKey;
    final showBottomNavBar = context.select((NavigatorModel state) => state.showBottom);
    final pathsCount = context.select((NavigatorModel state) => state.pathsCount);

    return Scaffold(
      body: Navigator(
        key: navKey,
        initialRoute: "/",
        onGenerateRoute: (settings) {
          // debugPrint("navigator generate route");
          switch (settings.name) {
            case '/':
              return CustomDirectionalTransitionRoute(
                child: ChangeNotifierProvider(
                  create:
                      (context) => ListViewModel(
                        costItemRepo: context.read(),
                        categoryRepo: context.read(),
                        currencyRepo: context.read(),
                        sharedRepo: context.read(),
                      ),
                  child: const CostListScreenWrapper(),
                ),
                ltr: (settings.arguments as NavigatorArgument?)?.ltr ?? false,
              );
            case '/data':
              return CustomDirectionalTransitionRoute(
                child: const ChartScreenWrapper(),
                ltr: (settings.arguments as NavigatorArgument?)?.ltr ?? false,
              );
            case '/goals':
              return CustomDirectionalTransitionRoute(
                child: const GoalScreenWrapper(),
                ltr: (settings.arguments as NavigatorArgument?)?.ltr ?? false,
              );
            case '/settings':
              return CustomDirectionalTransitionRoute(
                child: const SettingsScreenWrapper(),
                ltr: (settings.arguments as NavigatorArgument?)?.ltr ?? false,
              );
            case '/form':
              return SlideUpTransitionRoute(
                child: CostFormScreenWrapper(arg: (settings.arguments as FormArgument?)),
              );
            case '/create-saved-item':
              return CustomDirectionalTransitionRoute(
                child: EditSavedItemScreenWrapper(
                  initCostItem: (settings.arguments) as CostItem?,
                ),
              );
            case '/edit-saved-item':
              return CustomDirectionalTransitionRoute(
                child: EditSavedItemScreenWrapper(
                  initSavedItem: (settings.arguments) as SavedItem?,
                ),
              );
            case '/goals-form':
              return MaterialPageRoute(
                builder: (context) => const GoalTypeSelectionScreenState(),
                settings: RouteSettings(name: settings.name),
              );
            case '/currency':
              return CustomDirectionalTransitionRoute(
                child: CurrencySelectionScreenWrapper(
                  currencyExchange: false,
                ),
    
                // settings: RouteSettings(name: settings.name),
              );
            case '/exchange-rate-currency':
              return CustomDirectionalTransitionRoute(
                child: CurrencySelectionScreenWrapper(
                  currencyExchange: true,
                  initialValue: (settings.arguments as double?) ?? 0,
                ),
    
                // settings: RouteSettings(name: settings.name),
              );
            default:
              return MaterialPageRoute(builder: (context) => const Placeholder());
            // throw UnimplementedError();
          }
        },
      ),
      floatingActionButton: showBottomNavBar ? CustomFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: IgnorePointer(
        ignoring: !showBottomNavBar,
        child: AnimatedContainer(
          duration: Durations.medium1,
          curve: Curves.easeOut,
          height: showBottomNavBar ? 96 : 0,
          child: CustomNavigationBottomBar(),
        ),
      ),
    );
  }

  Future showPopDialog(BuildContext context) => showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Exit app?"),
        content: Text("Press exist to close the app."),
        actions: [
          DismissTextButton(onTap: context.nav.pop, text: "Cancel"),
          AffirmativeTextButton(onTap: SystemNavigator.pop, text: "Exit"),
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
    return SizedBox(
      width: 80,
      height: 80,
      child: FloatingActionButton(
        onPressed: () {
          context.navMod.goToNamed('/form');
          // context.navMod.openForm(FormArgument());
          HapticFeedback.mediumImpact();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(24)),
        enableFeedback: true,
        elevation: 0,
        foregroundColor: context.cs.surfaceContainer,
        backgroundColor: context.cs.primary,
        child: Icon(
          Icons.add,
          size: 40,
        ),
      ),
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
    Icons.ads_click_outlined, // goals
    Icons.settings, // settings
  ];

  @override
  Widget build(BuildContext context) {
    final pageIndex = context.select((NavigatorModel state) => state.currentRouteIndex);
    return BottomAppBar(
      notchMargin: 10,
      shape: AutomaticNotchedShape(
        RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12)),
        RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(24)),
      ),
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
                      style: IconButton.styleFrom(
                        backgroundColor: context.cs.secondary,
                        fixedSize: Size.square(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      visualDensity: VisualDensity.comfortable,
                      padding: EdgeInsets.all(8),
                      onPressed: () => {},
                      icon: Icon(
                        buttonIcon,
                        color: context.cs.surface,
                      ),
                      iconSize: 30,
                    );
                  } else {
                    iconButton = IconButton(
                      style: IconButton.styleFrom(
                        fixedSize: Size.square(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      visualDensity: VisualDensity.comfortable,
                      padding: EdgeInsets.all(8),
                      onPressed: () {
                        context.navMod.navigateBetweenMainScreens(index);
                      },
                      icon: Icon(buttonIcon),
                      iconSize: 24,
                    );
                  }
                  return MapEntry(index, iconButton);
                })
                .values
                .toList()
              ..insert(
                2,
                SizedBox(
                  width: 120,
                ),
              ), // add space for FAB
      ),
    );
  }
}

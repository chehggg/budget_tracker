// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/firebase_options.dart';
import 'package:budget_tracker/models/currency_model.dart';
import 'package:budget_tracker/models/navigation_model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:budget_tracker/screens/settings/budget_settings_screen.dart';
import 'package:budget_tracker/screens/settings/recurring_settings_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/screens/chart_screen.dart';
import 'package:budget_tracker/screens/cost_form_screen.dart';
import 'package:budget_tracker/screens/cost_list_screen.dart';
import 'package:budget_tracker/screens/report_screen.dart';
import 'package:budget_tracker/screens/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalization.instance.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<ThemeModel>(
      create: (context) => ThemeModel(),
    ),
    ChangeNotifierProvider<CurrencyModel>(
      create: (context) => CurrencyModel(),
    ),
    ChangeNotifierProvider<NavigationModel>(
      create: (context) => NavigationModel(),
    ),
    ChangeNotifierProxyProvider<ThemeModel, AppModel>(
      create: (context) => AppModel(),
      update: (context, themeModel, appModel) =>
          appModel!..updateAppModel(themeModel),
    ),
  ], child: const MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isFontLoaded = false;

  Future<void> loadFont() async {
    await GoogleFonts.pendingFonts([
      GoogleFonts.dmSerifDisplay,
      GoogleFonts.inter,
      GoogleFonts.oranienbaum,
    ]);
    setState(() {
      _isFontLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState;
    loadFont();
  }

  final FlutterLocalization localization = FlutterLocalization.instance;

  ThemeData _baseTheme(BuildContext context, Brightness brightness) {
    final baseTheme = ThemeData(brightness: brightness);

    final ColorScheme seedColorScheme;
    if (brightness == Brightness.light) {
      seedColorScheme = ColorScheme.fromSeed(
        // seedColor: const Color.fromARGB(255, 20, 175, 85),
        seedColor: context.select((ThemeModel state) => state.color),
        brightness: brightness,
        dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
        contrastLevel: 0,
        // surface: const Color.fromARGB(255, 22, 24, 22),
        // surfaceBright: const Color.fromARGB(255, 50, 48, 48),
        // surfaceContainer: const Color.fromARGB(255, 23, 37, 25),
        // surfaceDim: const Color.fromARGB(255, 19, 17, 17),
      );
    } else {
      seedColorScheme = ColorScheme.fromSeed(
        // seedColor: const Color.fromARGB(255, 20, 175, 85),
        seedColor: context.select((ThemeModel state) => state.color),
        brightness: brightness,
        dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
        contrastLevel: 0,
        // surface: const Color.fromARGB(255, 13, 13, 13),
        // surfaceBright: const Color.fromARGB(255, 36, 34, 34),
        // surfaceContainer: const Color.fromARGB(255, 244, 238, 238),
        // surfaceDim: const Color.fromARGB(255, 22, 21, 21),
      );
    }

    final customColorScheme = seedColorScheme.copyWith(
        surface: Color(0xff0A0A0C),
        surfaceContainer: Color(0xff0A0A0C),
        primary: Color(0xffF0EBE0),
        secondary: Color(0xffFFAB00));

    final customTextTheme = baseTheme.textTheme.copyWith(
      // bodyMedium: GoogleFonts.inter(fontWeight: FontWeight(200)),
      // bodyLarge: GoogleFonts.inter(fontSize: 26),
      // bodyMedium: GoogleFonts.archivoBlack(fontWeight: FontWeight(200)),
      // bodyLarge: GoogleFonts.archivoBlack(fontSize: 26),
      bodyMedium: GoogleFonts.inter(),
      bodyLarge: GoogleFonts.dmSerifDisplay(fontSize: 26),
      // labelSmall: GoogleFonts.playfairDisplay(fontWeight: FontWeight(600)),
      // titleMedium: GoogleFonts.playfairDisplay(),
      // titleLarge: GoogleFonts.playfairDisplay(),
      // titleSmall: GoogleFonts.playfairDisplay(color: seedColorScheme.onSurface),
      labelSmall: GoogleFonts.oranienbaum(fontWeight: FontWeight(600)),
      titleMedium: GoogleFonts.oranienbaum(
          color: customColorScheme.onSurface.withAlpha(200), fontSize: 18),
      titleLarge: GoogleFonts.oranienbaum(),
      headlineMedium: GoogleFonts.oranienbaum(),
      titleSmall: GoogleFonts.oranienbaum(color: customColorScheme.onSurface),
    );

    final spacing = context.select((ThemeModel state) => state.spacingValue);

    return baseTheme.copyWith(
      extensions: [
        MyColors(
          flipCardColor: Color(0xffF0EBE0),
          onFlipCard: Color(0xff0A0A0C),
        ),
        MyTexts(
          numberFontLarge: customTextTheme.bodyLarge!
              .copyWith(fontSize: 50, fontWeight: FontWeight(300)),
          numberFontMedium: customTextTheme.bodyMedium!
              .copyWith(fontSize: 25, fontWeight: FontWeight(600)),
          numberFontSmall: customTextTheme.bodyMedium!
              .copyWith(fontSize: 16, fontWeight: FontWeight(600)),
          numberLabel: customTextTheme.labelSmall!.copyWith(
              fontSize: 18, letterSpacing: 0, color: customColorScheme.primary),
          dateLabel: customTextTheme.labelSmall!.copyWith(
              fontSize: 25, letterSpacing: 0, color: customColorScheme.primary),
        )
      ],
      textTheme: customTextTheme,
      // primaryTextTheme: customTextTheme,
      colorScheme: customColorScheme,
      // brightness: brightness,
      // listTileTheme: ListTileThemeData(
      //   contentPadding: EdgeInsets.symmetric(horizontal: 8),
      //   titleTextStyle: customTextTheme.titleMedium,
      //   visualDensity: VisualDensity(vertical: spacing - 3, horizontal: -2),
      //   dense: true,
      //   leadingAndTrailingTextStyle: customTextTheme.headlineLarge
      // ),
      // appBarTheme: AppBarTheme(
      //   color: seedColorScheme.surfaceContainer,
      //   titleTextStyle: customTextTheme.titleLarge!.copyWith(fontSize: 24),
      //   scrolledUnderElevation: 0
      // ),
      // floatingActionButtonTheme: FloatingActionButtonThemeData(
      //   backgroundColor: seedColorScheme.primary
      // ),
      // // expansionTileTheme: ExpansionTileThemeData(

      // // ),
      // useMaterial3: true,
      // pageTransitionsTheme: const PageTransitionsTheme(
      //   builders: <TargetPlatform, PageTransitionsBuilder>{
      //     // TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      //     // TargetPlatform.android: OpenUpwardsPageTransitionsBuilder()
      //     TargetPlatform.android: PredictiveBackPageTransitionsBuilder()
      //     //   allowEnterRouteSnapshotting: false,
      //     // TargetPlatform.iOS: TransitionBuil
      //   },
      // ),
      // dialogTheme: DialogThemeData(
      //   titleTextStyle: customTextTheme.displayLarge!.copyWith(fontSize: 24),
      //   backgroundColor: seedColorScheme.surfaceContainer,
      //   insetPadding: EdgeInsets.symmetric(horizontal: 20)
      // ),
      // datePickerTheme: DatePickerThemeData(
      //   backgroundColor: seedColorScheme.surfaceContainer,
      //   dividerColor: Colors.transparent,
      //   // headerHeadlineStyle: TextStyle(color: Colors.amber)
      // ),
      // inputDecorationTheme: InputDecorationTheme(
      //   hintStyle: customTextTheme.displayMedium!.copyWith(color: seedColorScheme.onSurface.withAlpha(100)),
      //   prefixStyle: customTextTheme.displayMedium!.copyWith(color: seedColorScheme.onSurface.withAlpha(100))
      // ),
      // segmentedButtonTheme: SegmentedButtonThemeData(
      //   style: SegmentedButton.styleFrom(
      //     splashFactory: NoSplash.splashFactory,
      //     padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      //     selectedBackgroundColor: seedColorScheme.surfaceContainer,
      //     selectedForegroundColor: seedColorScheme.onSurface,
      //     visualDensity: VisualDensity(horizontal: 0),
      //     // textStyle: customTextTheme.titleMedium!.copyWith(fontSize: 24),
      //     side: BorderSide.none,
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))
      //   )
      // ),
      // menuButtonTheme: MenuButtonThemeData(
      //   style: ElevatedButton.styleFrom(
      //     textStyle: customTextTheme.headlineLarge,
      //     visualDensity: VisualDensity(horizontal: -2, vertical: -2)
      //   )
      // ),
      // radioTheme: RadioThemeData(
      //   visualDensity: VisualDensity(horizontal: -2)
      // ),
      // menuTheme: MenuThemeData(
      //   style: MenuStyle(
      //     backgroundColor: WidgetStatePropertyAll(seedColorScheme.surfaceBright),
      //     // visualDensity: VisualDensity(horizontal: -2, vertical: -4)
      //   )
      // ),
      // switchTheme: SwitchThemeData()
      // // dividerColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      locale: context.select((ThemeModel state) => state.appLocale),
      theme: _baseTheme(context, Brightness.light),
      themeMode: context.select((ThemeModel state) => state.theme),
      darkTheme: _baseTheme(context, Brightness.dark),
      home: _isFontLoaded ? const HomeScreen() : const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
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
    // debugPrint("navigator rebuild");
    // debugPrint("navigator route: $currentNavRoute");
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        debugPrint("popped!, current navigator route : $currentNavRoute");
        if (didPop) return;
        if (isFormOpened) {
          navigationModel.popFormToMain();
        } else {
          showPopDialog(context);
        }
      },
      child: Scaffold(
        body: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyMedium!,
          child: Navigator(
            key: navKey,
            initialRoute: "/",
            onGenerateRoute: (settings) {
              debugPrint("navigator generate route");
              // debugPrint("navigator model current route -> $currentNavRoute");
              // debugPrint("navigator current route -> ${settings.name}");
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(
                      builder: (context) => CostListScreen(),
                      settings: RouteSettings(name: settings.name));
                case '/form':
                  return MaterialPageRoute(
                      builder: (context) {
                        return CostItemFormScreen(
                            arg: settings.arguments as FormArgument);
                      },
                      settings: RouteSettings(name: settings.name));
                case '/data':
                  return MaterialPageRoute(
                      builder: (context) => const ChartScreen(),
                      settings: RouteSettings(name: settings.name));
                case '/report':
                  return MaterialPageRoute(
                      builder: (context) => const CostReportScreen(),
                      settings: RouteSettings(name: settings.name));
                case '/settings':
                  return MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                      settings: RouteSettings(name: settings.name));
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
                  return MaterialPageRoute(
                      builder: (context) => const Placeholder());
                // throw UnimplementedError();
              }
            },
          ),
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
              TextButton(onPressed: null, child: Text("Cancel"))
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
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(30)),
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
    final pageIndex =
        context.select((NavigationModel state) => state.currentRouteIndex);
    return BottomAppBar(
      notchMargin: 10,
      shape: CircularNotchedRectangle(),
      child: Row(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: buttons
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
                  onPressed: () =>
                      context.read<NavigationModel>().navigateMainScreen(index),
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
              )), // add space for FAB
      ),
    );
  }
}

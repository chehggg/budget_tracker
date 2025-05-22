// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:budget_tracker/firebase_options.dart';
import 'package:budget_tracker/models/navigation_model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/screens/chart_screen.dart';
import 'package:budget_tracker/screens/cost_form_screen.dart';
import 'package:budget_tracker/screens/cost_list_screen.dart';
import 'package:budget_tracker/screens/report_screen.dart';
import 'package:budget_tracker/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalization.instance.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeModel>(
          create: (context) => ThemeModel(),
        ),
        ChangeNotifierProvider<NavigationModel>(
          create: (context) => NavigationModel(),
        ),
        ChangeNotifierProxyProvider<ThemeModel,AppModel>(
          create: (context) => AppModel(),
          update: (context, themeModel, appModel) => appModel!..updateAppModel(themeModel),
        ),
      ],
      child: MainApp()
    )
  );
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final FlutterLocalization localization = FlutterLocalization.instance;
  
  ThemeData _baseTheme(BuildContext context, Brightness brightness) {

    final ColorScheme seedColorScheme;
    if (brightness == Brightness.dark) {
      seedColorScheme = ColorScheme.fromSeed(
        seedColor: Colors.orange, 
        brightness: brightness,
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        contrastLevel: 0.5,
        surface: const Color.fromARGB(255, 13, 13, 13),
        surfaceBright: const Color.fromARGB(255, 50, 48, 48),
        surfaceContainer: const Color.fromARGB(255, 36, 34, 34),
        surfaceDim: const Color.fromARGB(255, 19, 17, 17),
      );
    } else {
      seedColorScheme = ColorScheme.fromSeed(
        seedColor: Colors.orange, 
        brightness: brightness,
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        contrastLevel: 0.5,
        // surface: const Color.fromARGB(255, 13, 13, 13),
        // surfaceBright: const Color.fromARGB(255, 36, 34, 34),
        // surfaceContainer: const Color.fromARGB(255, 244, 238, 238),
        // surfaceDim: const Color.fromARGB(255, 22, 21, 21),
      );
    }

    // use san serif for number
    // use serif for display/text
    final TextStyle customNumberThin = GoogleFonts.poppins(fontWeight: FontWeight.w200);
    final TextStyle customNumberRegular = GoogleFonts.poppins(fontWeight: FontWeight.w400);
    final TextStyle customNumberMedium = GoogleFonts.poppins(fontWeight: FontWeight.w600);
    final TextStyle customNumberBold = GoogleFonts.poppins(fontWeight: FontWeight.w700);
    final TextStyle customNumberBlack = GoogleFonts.poppins(fontWeight: FontWeight.w800);
    final TextStyle customDisplayMedium = GoogleFonts.alike(fontWeight: FontWeight.w300);
    final TextStyle customDisplayBold = GoogleFonts.alike(fontWeight: FontWeight.w500);
    final TextStyle customDisplayBlack = GoogleFonts.alike(fontWeight: FontWeight.w700);

    final TextTheme customTextTheme = TextTheme(
      displayLarge: customDisplayBold.copyWith(fontSize: 50), // Custom bold and size (Regular is default)
      displayMedium: customNumberBlack, // For number
      displaySmall: customNumberMedium, // Regular is default
      // headlineLarge: customNumberRegular, // Regular is default
      headlineLarge: customDisplayBold, // Regular is default
      headlineMedium: customDisplayBold, // Regular is default
      headlineSmall: customDisplayBold, // Regular is default
      titleLarge: customDisplayBold, // Custom bold (Regular is default)
      titleMedium: customDisplayBold, // Custom bold (Medium is default)
      titleSmall: customNumberBold, // Custom bold (Medium is default)
      bodyLarge: customNumberMedium, // Normal use in number (use this for more emphasis than label medium)
      bodyMedium: customDisplayMedium, // Regular use in display text
      bodySmall: customNumberRegular, // Regular is default
      labelLarge: customDisplayBlack , // Custom bold (Medium is default)
      labelMedium: customNumberRegular, // For showing number in small font (suitable for graph label etc)
      labelSmall: customDisplayBlack.copyWith(
        fontSize: 12,
        color: seedColorScheme.primary
      ), // Medium is default
    );


    return ThemeData(
      textTheme: customTextTheme,
      primaryTextTheme: customTextTheme,
      colorScheme: seedColorScheme, 
      brightness: brightness,
      listTileTheme: ListTileThemeData(
        titleTextStyle: customTextTheme.titleMedium
      ),
      appBarTheme: AppBarTheme(
        color: seedColorScheme.surfaceContainer,
        titleTextStyle: customTextTheme.titleLarge!.copyWith(fontSize: 24),
        scrolledUnderElevation: 0
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: seedColorScheme.primary
      ),
      useMaterial3: true,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          // TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          // TargetPlatform.android: OpenUpwardsPageTransitionsBuilder()
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder()
          //   allowEnterRouteSnapshotting: false,
          // TargetPlatform.iOS: TransitionBuil
        },
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: customTextTheme.displayLarge!.copyWith(fontSize: 24),
        backgroundColor: seedColorScheme.surfaceContainer
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: seedColorScheme.surfaceContainer,
        dividerColor: Colors.transparent,
        // headerHeadlineStyle: TextStyle(color: Colors.amber)
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: customTextTheme.displayMedium!.copyWith(color: seedColorScheme.onSurface.withAlpha(100)),
        prefixStyle: customTextTheme.displayMedium!.copyWith(color: seedColorScheme.onSurface.withAlpha(100))
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          selectedBackgroundColor: seedColorScheme.surfaceContainer,
          selectedForegroundColor: seedColorScheme.onSurface,
          visualDensity: VisualDensity(horizontal: 0),
          // textStyle: customTextTheme.titleMedium!.copyWith(fontSize: 24),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))
        )
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(seedColorScheme.surfaceBright)
        )
      )
      // dividerColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(1)
      ),
      child: MaterialApp(
        locale: context.select((ThemeModel state) => state.appLocale),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: _baseTheme(context, Brightness.light),
        themeMode: context.select((ThemeModel state) => state.theme),
        darkTheme: _baseTheme(context, Brightness.dark),
        home: const HomeScreen(),
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
        body: Navigator(
          key: navKey,
          initialRoute: "/",
          onGenerateRoute: (settings) {
            debugPrint("navigator generate route");
            // debugPrint("navigator model current route -> $currentNavRoute");
            // debugPrint("navigator current route -> ${settings.name}");
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(
                  builder:(context) => CostListScreen(),
                  settings: RouteSettings(name: settings.name)
                );
              case '/form':
                return MaterialPageRoute(builder:(context) {
                  return CostItemFormScreen(arg: settings.arguments as FormArgument);
                },
                  settings: RouteSettings(name: settings.name)
                );
              case '/data':
                return MaterialPageRoute(builder:(context) => 
                  const ChartScreen(),
                  settings: RouteSettings(name: settings.name)
                );
              case '/report':
                return MaterialPageRoute(builder:(context) => 
                  const CostReportScreen(),
                  settings: RouteSettings(name: settings.name)
                );
              case '/settings':
                return MaterialPageRoute(builder:(context) => 
                  const SettingsScreen(),
                  settings: RouteSettings(name: settings.name)
                );
              default:
                throw UnimplementedError();
            } 
          },
        ),
        floatingActionButton: navigationModel.isFormOpened ? null : CustomFAB(
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: isFormOpened ? null : CustomNavigationBottomBar(),
      ),
    );
  }

  Future showPopDialog(BuildContext context) => showDialog(
    context: context, 
    builder:(context) {
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
      onPressed: (){
        context.read<NavigationModel>().openForm(FormArgument(isNew: true));
      },
      shape: CircleBorder(),
      enableFeedback: true,
      elevation: 0,
      child: Icon(Icons.add),
      
    );
  }
}

class CustomNavigationBottomBar extends StatelessWidget{
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
        children: buttons.asMap().map((index, buttonIcon) {
          Widget iconButton; 
          if (pageIndex == index) {
            iconButton = IconButton.filled(
              onPressed: () => context.read<NavigationModel>().navigateMainScreen(index),
              icon: Icon(buttonIcon),
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
        }).values.toList()..insert(2, SizedBox(width: 80,)), // add space for FAB
      ),
    );
  }
}


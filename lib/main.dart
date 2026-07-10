import 'package:budget_tracker/config/providers.dart';
import 'package:budget_tracker/config/router.dart';
import 'package:budget_tracker/firebase_options.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:budget_tracker/ui/core/themes/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';

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
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  void initState() {
    super.initState();
    localization.onTranslatedLanguage = _onTranslatedLanguage;
    // or JSON asset base on your language source
    
    _initializeLocalizationJsonAsset();
  }

  // The setState call here is required to rebuild the app after language changes.
  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  void _initializeLocalizationJsonAsset() {
    localization.init(
      initLanguageCode: 'en',
      source: LocalizationSource.jsonAsset,
      jsonLocales: const [
        JsonLocale('en', 'assets/i18n/en.json'),
        JsonLocale('zh', 'assets/i18n/zh.json'),
        JsonLocale('ja', 'assets/i18n/ja.json'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeLocale = localization.currentLocale ?? const Locale('en');
    return MaterialApp.router(
      routerConfig: goRouter,
      supportedLocales: localization.supportedLocales,
      localizationsDelegates: localization.localizationsDelegates,
      // locale: context.select((ThemeModel state) => state.appLocale),
      theme: getAppTheme(activeLocale),
      themeMode: context.select((ThemeModel state) => state.theme),
      darkTheme: getAppTheme(activeLocale),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../ui/app_theme.dart';
import '../gen_l10n/app_localizations.dart';
import '../main.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global navigator key for navigation from notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyAppState extends State<MyApp> {
  static const String _localeKey = 'languageCode';
  static const String _themeKey = 'captainTheme';

  late Locale locale = widget.initialLocale;
  late bool isDark = widget.initialDark;

  /// The language the rider picked last time; Hindi by default.
  static Future<Locale> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return Locale(prefs.getString(_localeKey) ?? 'hi');
  }

  /// Dark is the website's default theme.
  static Future<bool> loadSavedDark() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_themeKey) ?? 'dark') == 'dark';
  }

  Future<void> setLocale(Locale newLocale) async {
    setState(() {
      locale = newLocale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, newLocale.languageCode);
  }

  Future<void> setDark(bool dark) async {
    setState(() => isDark = dark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, dark ? 'dark' : 'light');
  }

  @override
  Widget build(BuildContext context) {
    final palette = isDark ? CapPalette.dark : CapPalette.light;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: capOverlay(palette),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Digi Captain',
        theme: AppTheme.build(palette),
        themeAnimationDuration: const Duration(milliseconds: 250),
        locale: locale,
        supportedLocales: const [
          Locale('en'),
          Locale('hi'),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SplashScreen(setLocale: setLocale),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;
  final bool initialDark;
  const MyApp({super.key, this.initialLocale = const Locale('hi'), this.initialDark = true});

  @override
  State<MyApp> createState() => MyAppState();
}

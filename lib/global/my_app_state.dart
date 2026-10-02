import 'package:flutter/material.dart';
import '../global/Common.dart';
import '../gen_l10n/app_localizations.dart';
import '../main.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Global navigator key for navigation from notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyAppState extends State<MyApp> {
  Locale? locale = const Locale('hi'); // Set default to Hindi

  void setLocale(Locale newLocale) {
    setState(() {
      locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Digital Rider',
      theme: ThemeData(
        fontFamily: 'bevan',
        scaffoldBackgroundColor: Colors.white, // Replace with Common.background if available
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // Replace with Common.secondary if available
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black), // Replace with Common.primary if available
          titleTextStyle: TextStyle(
            color: Colors.black, // Replace with Common.primary if available
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white, // Replace with Common.secondary if available
          selectedItemColor: Colors.black, // Replace with Common.primary if available
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),
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
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

import 'package:digirider/NavMain.dart';
import 'package:digirider/pages/LandingPage.dart';
import 'package:digirider/providers/NotificationProvider.dart';
import 'package:digirider/providers/trip_provider.dart';
import 'package:digirider/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'ui/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'global/my_app_state.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Messages with a notification block are shown by Android itself; only data-only ones need a local notification.
  await NotificationService().showBackgroundNotification(message);
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize notification service - single source of truth
  await NotificationService().initialize();

  final tripProvider = TripProvider();
  await tripProvider.loadActiveOrdersCount();
  final initialLocale = await MyAppState.loadSavedLocale();
  final initialDark = await MyAppState.loadSavedDark();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: tripProvider),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
      ],
      child: MyApp(initialLocale: initialLocale, initialDark: initialDark),
    ),
  );

}








class SplashScreen extends StatefulWidget {
  final void Function(Locale)? setLocale;
  const SplashScreen({super.key, this.setLocale});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Future<Widget> _getInitialPage() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final email = prefs.getString('email');

    if (!isLoggedIn || email == null || email.isEmpty) {
      return LandingPage(); // Not logged in or email missing
    }

    // Check if app was launched from notification
    if (await NotificationService().launchedFromNotification()) {
      return const NavMain(initialIndex: NavMain.home); // New-order push: Home shows the request
    }

    return const NavMain();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      Widget nextPage = await _getInitialPage();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => nextPage,
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const CaptainSplash();
}

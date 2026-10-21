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
import 'global/Common.dart';
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: tripProvider),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
      ],
      child: MyApp(initialLocale: initialLocale),
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
      return NavMain(initialIndex: 0); // Go directly to IncomingBookingPage tab
    }

    return NavMain(); // Logged in - default to home tab
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      Widget nextPage = await _getInitialPage();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextPage),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Common.primary,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Common.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🟡 You can use your logo or animation here
            Image.asset('assets/images/app_icon.png', height: 130),
            // const SizedBox(height: 20),
            // const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Common.primary,
        height: 0,
        child: const SizedBox(),
      ),
    );
  }
}

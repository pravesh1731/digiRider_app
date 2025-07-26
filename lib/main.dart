import 'package:digirider/NavMain.dart';
import 'package:digirider/pages/DocumentUploadPage.dart';
import 'package:digirider/pages/GoogleSignInUp.dart';
import 'package:digirider/pages/LandingPage.dart';
import 'package:digirider/providers/NotificationProvider.dart';
import 'package:digirider/providers/trip_provider.dart';
import 'package:digirider/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'booking/IncomingBookingPage.dart';
import 'firebase_options.dart';
import 'global/Common.dart';
import 'home/TripFlowPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  // FlutterLocalNotificationsPlugin();
  //
  // const AndroidInitializationSettings initializationSettingsAndroid =
  // AndroidInitializationSettings('@drawable/logo');
  //
  // const InitializationSettings initializationSettings =
  // InitializationSettings(android: initializationSettingsAndroid);
  //
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  //
  // final data = message.data;
  // final title = data['title'];
  // final body = data['body'];

  print('📨 Background notification triggered');

  // if (title != null && body != null) {
  //   flutterLocalNotificationsPlugin.show(
  //     message.hashCode,
  //     title,
  //     body,
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'order_channel_id',
  //         'Order Notifications',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //         icon: '@drawable/logo',
  //       ),
  //     ),
  //   );
  // }
}


// Future<Widget> _getInitialPage() async {
//   final prefs = await SharedPreferences.getInstance();
//   final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//   final email = prefs.getString('email');
//   // final isDocumentUploaded = prefs.getBool('documentUploaded') ?? false;
//
//   // Null check for email
//   if (!isLoggedIn || email == null || email.isEmpty) {
//     // return GoogleLoginPage(); // Not logged in or email missing
//     return LandingPage(); // Not logged in or email missing
//   }
//
//   // Logged in, but documents not uploaded yet
//   // if (!isDocumentUploaded && isLoggedIn) {
//   //   // return DocumentUploadPage();
//   //   return LandingPage();
//   // }
//
//   // Logged in and documents uploaded
//   return NavMain();
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tripProvider = TripProvider();
  await tripProvider.loadActiveOrdersCount();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await NotificationService().initialize();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@drawable/logo');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TripProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
      ],
      child: MyApp(),
    ),
  );

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Rider',
      theme: ThemeData(

        fontFamily: 'bevan', // 👈 This sets the default font app-wide
        // textTheme: ThemeData.light().textTheme.copyWith(
        //   bodyLarge: TextStyle(fontWeight: FontWeight.w400),
        //   bodySmall: TextStyle(fontWeight: FontWeight.w300),
        // ),
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Common.background,
        // splashColor: Colors.transparent,
        highlightColor: Colors.transparent,

        hoverColor: Colors.transparent,

        // ✅ Global AppBar style
        appBarTheme: AppBarTheme(
          // systemOverlayStyle: SystemUiOverlayStyle(
          //   // statusBarColor: Common.primary, // ✅ match your intended color
          //   // statusBarIconBrightness: Brightness.light,
          // ),
          backgroundColor: Common.secondary,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Common.primary),
          titleTextStyle: TextStyle(
            color: Common.primary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        // ✅ Global BottomNavigationBar style
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Common.secondary,
          selectedItemColor: Common.primary,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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

    return NavMain(); // Logged in
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

import 'package:digirider/NavMain.dart';
import 'package:digirider/pages/DocumentUploadPage.dart';
import 'package:digirider/pages/GoogleSignInUp.dart';
import 'package:digirider/providers/trip_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'booking/IncomingBookingPage.dart';
import 'firebase_options.dart';
import 'global/Common.dart';
import 'home/TripFlowPage.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<Widget> _getInitialPage() async {
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final email = prefs.getString('email');
  final isDocumentUploaded = prefs.getBool('documentUploaded') ?? false;

  // Null check for email
  if (!isLoggedIn || email == null || email.isEmpty) {
    return GoogleLoginPage(); // Not logged in or email missing
  }

  // Logged in, but documents not uploaded yet
  if (!isDocumentUploaded && isLoggedIn) {
    return DocumentUploadPage();
  }

  // Logged in and documents uploaded
  return NavMain();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => TripProvider(),
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
      title: 'Flutter Demo',
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
      // home: DocumentUploadPage(),
      // home: GoogleLoginPage(),
      // home: NavMain(),
      // home: TripFlowPage(),
      home: FutureBuilder<Widget>(
        future: _getInitialPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data!;
          } else {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
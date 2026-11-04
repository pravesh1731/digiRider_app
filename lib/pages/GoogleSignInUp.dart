import 'dart:convert';

import 'package:digirider/global/Common.dart';
import 'package:digirider/pages/DocumentUploadPage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../NavMain.dart';
import '../global/l10n.dart';
import '../services/notification_service.dart';
import '../ui/widgets.dart';
import '../utils/bottomSnackBar.dart';
import 'SubdomainPage.dart';
import 'auth_widgets.dart';


class GoogleLoginPage extends StatefulWidget {
  final bool isSignUp;
  const GoogleLoginPage({super.key, this.isSignUp = false});

  @override
  State<GoogleLoginPage> createState() => _GoogleLoginPageState();
}

class _GoogleLoginPageState extends State<GoogleLoginPage> {
  late bool _isLogin;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLogin = !widget.isSignUp;
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Force the account picker to show again
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;

      setState(() {
        _isLoading = true;
      });

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) throw Exception("User not found");


      final bool apiSuccess = await _callYourApi(user.email);
      if (!mounted) return;
      final l10n = context.l10n;

      if (apiSuccess) {

        if(!_isLogin){
          getSnackBar(context, l10n.alreadyHaveAccountSignIn, Colors.orange, 2);
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        final userStatus = prefs.getString('userStatus') ?? '';

        if (userStatus == 'Adv') {
          getSnackBar(context, l10n.loginSuccessWelcome, Colors.green, 0);
          await prefs.setBool('isLoggedIn', true);
          // Store this phone's FCM token on the rider so new-order pushes reach it.
          await NotificationService().syncToken();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => NavMain()),
                (Route<dynamic> route) => false, // removes all previous routes
          );
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => NavMain()));
        } else {
          getSnackBar(context, l10n.uploadDocumentsToContinue, Colors.orange, 1);
          Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentUploadPage()));
        }

        // Navigator.pushReplacementNamed(context, '/successPage');
      } else {
        if(_isLogin){
          getSnackBar(context, l10n.noAccountSignUp, Colors.orange, 2);
          return;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', user.email ?? '');
        Navigator.push(context, MaterialPageRoute(builder: (_) => SubdomainPage(email: user.email!,)));

        // Navigator.pushReplacementNamed(context, '/failurePage');
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      getSnackBar(context, context.l10n.googleSignInFailed, Colors.orange, 2);
    }
  }


  Future<bool> _callYourApi(String? email) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final deviceToken = prefs.getString('deviceToken');

    try {
      // Replace with your real API call (e.g., using http or dio)
      final Map<String, String> body = {'email': email ?? ''};
      if (deviceToken != null) {
        body['deviceToken'] = deviceToken;
      }

      final response = await http.post(
        Uri.parse('${Common.baseUrl}api/rider/login'),
        body: body,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');


        if (data['success'] == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          await prefs.setString('userStatus', data['userStatus'] ?? '');
          await prefs.setString('name', data['name'] ?? '');
          await prefs.setString('cityName', data['cityName'] ?? '');
          await prefs.setString('email', data['email'] ?? '');
          await prefs.setString('phoneNumber', data['phoneNumber'] ?? '');
          await prefs.setString('riderDomain', data['riderDomain'] ?? '');
          await prefs.setString('vehicleType', data['vehicleType'] ?? '');
          await prefs.setString('licence', data['licence'] ?? '');
          await prefs.setString('qrcode', data['qrcode'] ?? '');
          await prefs.setString('profile', data['profile'] ?? '');
          await prefs.setString('aadhaar', data['aadhaar'] ?? '');

          return true;
        } else {
          return false;
        }
      } else {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('API call failed: $e');
      return false;
    }
  }

  void _launchUrl(String url) async {
    if (url.isEmpty) return;

    final uri = Uri.parse(url);
    try {
      final canLaunchIt = await canLaunchUrl(uri);
      if (!canLaunchIt) {
        throw 'Cannot launch $url';
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching URL: $e');
      // You can show a snackbar or alert if needed.
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.cap;
    if (_isLogin) {
      return CapAuthScaffold(
        title: l10n.cWelcomeBackCaptain,
        titleSize: 44,
        onBack: () => Navigator.of(context).maybePop(),
        children: [
          Text(l10n.cLoginDesc, style: CapText.sans(size: 15, color: p.mu, height: 1.5)),
          const SizedBox(height: 28),
          GoogleButton(label: _isLoading ? l10n.cSigningIn : l10n.cSignInWithGoogle, loading: _isLoading, onTap: _handleGoogleSignIn),
          const SizedBox(height: 32),
          AuthSwitchLink(question: l10n.cNewHere, action: l10n.cSignUpToDrive, onTap: () => setState(() => _isLogin = false)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CapIcon(CapIcons.lock, size: 14, color: p.mu),
              const SizedBox(width: 8),
              Text(l10n.cSecuredVia, style: CapText.sans(size: 12, color: p.mu)),
            ],
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => _launchUrl('https://rider.digistall.in/privacy-policy'),
            child: Text(l10n.agreeTerms, textAlign: TextAlign.center, style: CapText.sans(size: 12, color: p.mu, height: 1.5)),
          ),
        ],
      );
    }
    return CapAuthScaffold(
      step: 1,
      stepLabel: l10n.cIdentity,
      title: l10n.cSignUpToDrive,
      onBack: () => Navigator.of(context).maybePop(),
      backLabel: l10n.cNavHome,
      children: [
        Text(l10n.cSignUpDesc, style: CapText.sans(size: 15, color: p.mu, height: 1.55)),
        const SizedBox(height: 28),
        GoogleButton(label: _isLoading ? l10n.cConnectingGoogle : l10n.cSignUpWithGoogle, loading: _isLoading, onTap: _handleGoogleSignIn),
        const SizedBox(height: 32),
        AuthSwitchLink(question: l10n.cAlreadyRegistered, action: l10n.cLoginHere, onTap: () => setState(() => _isLogin = true)),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => _launchUrl('https://rider.digistall.in/privacy-policy'),
          child: Text(l10n.agreeTerms, textAlign: TextAlign.center, style: CapText.sans(size: 12, color: p.mu, height: 1.5)),
        ),
      ],
    );
  }
}

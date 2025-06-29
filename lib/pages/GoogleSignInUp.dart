import 'dart:convert';

import 'package:digirider/global/Common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../NavMain.dart';
import 'SubdomainPage.dart';


class GoogleLoginPage extends StatefulWidget {
  const GoogleLoginPage({super.key});

  @override
  State<GoogleLoginPage> createState() => _GoogleLoginPageState();
}

class _GoogleLoginPageState extends State<GoogleLoginPage> {
  bool _isLogin = true; // 🔁 Tracks current mode
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Force the account picker to show again
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

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

      if (apiSuccess) {

        if(!_isLogin){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You already have an account kindly sign In')),
          );
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('documentUploaded', true);

        Navigator.push(context, MaterialPageRoute(builder: (_) => NavMain()));
        // Navigator.pushReplacementNamed(context, '/successPage');
      } else {
        if(_isLogin){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You don\'t have account kindly sign up')),
          );
          return;
        }
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('go to sign up')),
        // );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', user.email ?? '');
        Navigator.push(context, MaterialPageRoute(builder: (_) => SubdomainPage(email: user.email!,)));

        // Navigator.pushReplacementNamed(context, '/failurePage');
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed')),
      );
    }
  }


  Future<bool> _callYourApi(String? email) async {

    setState(() {
      _isLoading = true;
    });

    try {
      // Replace with your real API call (e.g., using http or dio)
      final response = await http.post(
        Uri.parse(Common.baseUrl+'api/rider/login'),
        body: {'email': email},
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);

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

          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print('API call failed: $e');
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent
      ),
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0, left: 12.0, top: 12),
              child: Card(
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(_isLogin ? 'Log in to your account' : 'Create a new account', style: TextStyle(fontFamily: 'bold', fontSize: 20, fontWeight: Common.weight),),
                      SizedBox(height: 20,),
                      InkWell(
                        onTap: _handleGoogleSignIn,
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Common.secondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child:
                        _isLoading
                        ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Common.primary),
                              ),
                            ),
                          ],
                        )
                            : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/Icons/google.svg',
                            width: 20,
                            height: 20,
                            color: Common.primary,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Login with Google',
                            style: TextStyle(
                              fontFamily: 'bold',
                              fontSize: Common.h2,
                              fontWeight: Common.weight2,
                              color: Common.primary,
                            ),
                          ),
                        ],
                      ),
                ),
                      ),
                      SizedBox(height: 15,),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Common.light,
                            ),
                          ),
                          SizedBox(width: 10,),
                          Text('or', style: TextStyle(fontFamily: 'bold', fontSize: Common.h3, fontWeight: Common.weight2, color: Common.secondary),),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Common.light,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15,),
                      InkWell(

                        onTap: () {
                          setState(() {
                            _isLogin = !_isLogin; // 🔁 Toggle between SignIn/SignUp
                          });
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: _isLogin ? 'Create a new account?' : 'Already have an account?', // 🔁 Toggle text
                                style: TextStyle(
                                  fontFamily: 'bold',
                                  fontSize: Common.h2,
                                  fontWeight: Common.weight2,
                                  color: Common.light,
                                ),
                              ),
                              TextSpan(
                                text: _isLogin ? ' Sign up' : ' Sign in', // 🔁 Toggle action
                                style: TextStyle(
                                  fontFamily: 'bold',
                                  fontSize: Common.h2,
                                  fontWeight: Common.weight2,
                                  color: Common.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15,),
                      Card(
                        // elevation: 4,
                        shadowColor: Common.light.withOpacity(0.5),

                        color: Colors.transparent,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: Color(0xFFF4F2F2),
                            // color: Common.background,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text('By logging in you agree to our terms and Conditions', textAlign: TextAlign.center, style: TextStyle(color: Common.light, fontWeight: Common.weight, fontSize: Common.h4, fontFamily: 'bold'), softWrap: true,),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

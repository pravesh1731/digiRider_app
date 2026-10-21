import 'dart:convert';
import 'dart:typed_data';

import 'package:digirider/pages/LandingPage.dart';
import 'package:digirider/history/HistoryPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../global/Common.dart';
import '../global/l10n.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../utils/_TimedSnackBar.dart';
import '../utils/bottomSnackBar.dart';
import '../utils/show_exit_dialog.dart';

import 'package:pdf/widgets.dart' as pw;
import '../global/my_app_state.dart';
import '../gen_l10n/app_localizations.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  String name = '';
  String phone = '';
  String city = '';
  String vehicle = '';
  String domain = '';
  String qrcode = '';

  String profile = '';

  bool _isGenerating = false;
  bool _notificationsEnabled = true;

  // Backend values ("Gotan"/"Jodhpur", "Bike"/"Auto"/"Car"); the API matches them case-sensitively.
  static const List<String> _cities = ['Gotan', 'Jodhpur'];
  static const List<String> _vehicles = ['Bike', 'Auto', 'Car'];

  Future<pw.ImageProvider> imageFromAssetBundle(String path) async {
    final byteData = await rootBundle.load(path);
    final image = pw.MemoryImage(byteData.buffer.asUint8List());
    return image;
  }

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get QR code
    final qrValidationResult = QrValidator.validate(
      data: 'https://rider.digistall.in/riderprofile/$phone',
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
    final qrCode = qrValidationResult.qrCode;
    final painter = QrPainter.withQr(
      qr: qrCode!,
      gapless: true,
      color: const Color(0xFF000000),
      emptyColor: const Color(0xFFFFFFFF),
    );
    final qrImageData = await painter.toImageData(300);
    final qrBytes = qrImageData!.buffer.asUint8List();

    // Load background images
    final frontImage = await rootBundle.load('assets/images/cardFront.png');
    final backImage = await rootBundle.load('assets/images/cardBack.png');

    final front = pw.MemoryImage(frontImage.buffer.asUint8List());
    final back = pw.MemoryImage(backImage.buffer.asUint8List());
    final pageWidth = PdfPageFormat.a4.width;

    // Load the payment QR uploaded at signup; fall back to the profile QR if it is missing.
    Uint8List netImgBytes = qrBytes;
    if (qrcode.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(qrcode));
        if (response.statusCode == 200) netImgBytes = response.bodyBytes;
      } catch (e) {
        debugPrint('Could not load payment QR: $e');
      }
    }
    final netImage = pw.MemoryImage(netImgBytes);

    final _labelStyle = pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 18);
    final _labelStyle2 = pw.TextStyle(color: PdfColors.black, fontWeight: pw.FontWeight.bold, fontSize: 19);
    final _valueStyle = pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.normal, fontSize: 18);
    final _valueStyle2 = pw.TextStyle(color: PdfColors.black, fontWeight: pw.FontWeight.normal, fontSize: 18);


    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.zero,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Container(
                width: pageWidth,
                height: PdfPageFormat.a4.availableHeight / 2,
                child: pw.Stack(
                  children: [
                    pw.Image(front, fit: pw.BoxFit.cover, width: pageWidth),
                    pw.Positioned(
                      left: 20,
                      top: 100,
                      child: pw.Container(
                        height: 200, // 👈 set height for proper spacing
                        child: pw.Column(
                          mainAxisSize: pw.MainAxisSize.max,
                          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(children: [
                              pw.Text('Rider Domain: ', style: _labelStyle),
                              pw.Text(domain, style: _valueStyle),
                            ]),
                            pw.Row(children: [
                              pw.Text('Rider Name: ', style: _labelStyle),
                              pw.Text(name, style: _valueStyle),
                            ]),
                            pw.Row(children: [
                              pw.Text('Vehicle Type: ', style: _labelStyle),
                              pw.Text(vehicle, style: _valueStyle),
                            ]),
                            pw.Row(children: [
                              pw.Text('Contact: ', style: _labelStyle),
                              pw.Text(phone, style: _valueStyle),
                            ]),
                            pw.Row(children: [
                              pw.Text('City: ', style: _labelStyle),
                              pw.Text(city, style: _valueStyle),
                            ]),
                          ],
                        ),
                      ),
                    ),

                    pw.Positioned(
                      left: 415,
                      top: 100,
                      child: pw.Image(pw.MemoryImage(qrBytes), width: 170, height: 170),
                    ),
                  ],
                ),
              ),
              // pw.Spacer(),
              pw.Container(
                height: 113, // or any height you need
                width: double.infinity,
                color: PdfColors.black,
              ),

              pw.Container(
                width: pageWidth,
                height: PdfPageFormat.a4.availableHeight / 2,
                child: pw.Stack(
                  children: [
                    pw.Image(back, fit: pw.BoxFit.cover, width: pageWidth),
                    pw.Positioned(
                      left: 210,
                      top: 30,
                      child: pw.Image(netImage, width: 170, height: 170, fit: pw.BoxFit.fitHeight),
                    ),
                    pw.Positioned(
                      top: 200,
                      left: 0,
                      right: 0, // Stretch full width
                      child: pw.Center( // Center horizontally
                        child: pw.Container(
                          height: 150,
                          child: pw.Column(
                            mainAxisSize: pw.MainAxisSize.max,
                            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: pw.CrossAxisAlignment.center, // Optional: center items inside each row
                            children: [
                              pw.Row(
                                mainAxisSize: pw.MainAxisSize.min, // Make row wrap its content
                                children: [
                                  pw.Text('rider.digistall', style: _labelStyle2),
                                ],
                              ),
                              pw.Row(
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  pw.Text('https://rider.digistall.in', style: _labelStyle2),
                                ],
                              ),
                              pw.Row(
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  pw.Text('+91 - '+phone, style: _labelStyle2),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }




  Future<void> _handleDownloadAndPrint() async {
    setState(() => _isGenerating = true);

    try {
      final pdfData = await _generatePdf();
      if (mounted) setState(() => _isGenerating = false);
      await Printing.layoutPdf(onLayout: (_) => pdfData);
    } catch (e) {
      debugPrint('Could not create rider card: $e');
      if (mounted) {
        setState(() => _isGenerating = false);
        getSnackBar(context, context.l10n.somethingWentWrong, Colors.red, 1);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = await NotificationService().isEnabled();
    if (!mounted) return;
    setState(() {
      name = prefs.getString('name') ?? '';
      phone = prefs.getString('phoneNumber') ?? '';
      city = prefs.getString('cityName') ?? '';
      vehicle = prefs.getString('vehicleType') ?? '';
      domain = prefs.getString('riderDomain') ?? '';
      qrcode = prefs.getString('qrcode') ?? '';
      profile = prefs.getString('profile') ?? '';
      _notificationsEnabled = notificationsEnabled;
    });
  }

  Future<void> _updateCity(String newCity) async {
    final l10n = context.l10n;
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    if (email == null || email.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('${Common.baseUrl}api/rider/updatecityname'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "cityName": newCity}),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        // cityName drives the incoming order feed and which city's notifications this rider gets.
        await prefs.setString('cityName', newCity);
        setState(() => city = newCity);
        getSnackBar(context, l10n.cityUpdated, Colors.green, 0);
      } else {
        getSnackBar(context, l10n.cityUpdateFailed, Colors.red, 1);
      }
    } catch (e) {
      if (mounted) getSnackBar(context, l10n.somethingWentWrong, Colors.orange, 2);
    }
  }

  Future<void> _toggleNotifications(bool enabled) async {
    final l10n = context.l10n;
    final granted = await NotificationService().setEnabled(enabled);
    if (!mounted) return;
    setState(() => _notificationsEnabled = enabled);

    if (!enabled) {
      getSnackBar(context, l10n.notificationsOff, Colors.orange, 2);
    } else if (granted) {
      await NotificationService().showTestNotification();
      if (mounted) getSnackBar(context, l10n.notificationsOn, Colors.green, 0);
    } else {
      getSnackBar(context, l10n.notificationsBlocked, Colors.orange, 1);
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse('https://rider.digistall.in/#/privacy-policy');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      getSnackBar(context, context.l10n.somethingWentWrong, Colors.orange, 2);
    }
  }

  Future<void> showCityPickerDialog(String currentCity, Function(String) onCitySelected) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Common.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(localizations.selectCity, style: TextStyle(fontWeight: Common.weight, color: Common.primary, fontSize: Common.title, fontFamily: 'bold')),
        content: SizedBox(
          width: screenWidth * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _cities.map((key) {
              return ListTile(
                title: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12)
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  child: Row(
                    children: [
                      Text(localizations.cityName(key), style: TextStyle(color: Common.primary, fontFamily: 'bold', fontSize: Common.h3, fontWeight: Common.weight),),
                      Spacer(),
                      Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Image.asset('assets/Icons/right-arrow.png', color: Common.primary, width: 18, height: 18,),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onCitySelected(key);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildInitial() {
    return Center(
      child: Text(
        name.isNotEmpty ? name.characters.first.toUpperCase() : '',
        style: TextStyle(color: Common.primary, fontSize: 32, fontFamily: 'bold', fontWeight: Common.weight),
      ),
    );
  }

  // --- LOGOUT DIALOG ---
  Future<void> logout() async {
    final screenWidth = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Common.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 15),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        title: Text(localizations.confirmLogout, style: TextStyle(fontWeight: Common.weight, color: Common.primary, fontSize: Common.title,)),
        content: SizedBox(
          width: screenWidth * 0.9,
          child: Text(localizations.logoutPrompt, style: TextStyle(color: Common.primary, fontWeight: Common.weight, fontSize: Common.h2,),),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Common.primary.withOpacity(0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(localizations.cancel, style: TextStyle(color: Common.primary, fontWeight: Common.weight, fontSize: Common.h2,)),
          ),
          ElevatedButton(
            onPressed: () async {
              // 1. Show the loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Common.primary),
                    ),
                  );
                },
              );
              try {
                await LocationService().stop();
                await NotificationService().onLogout();
                try {
                  await GoogleSignIn().signOut();
                  await FirebaseAuth.instance.signOut();
                } catch (e) {
                  debugPrint('Sign-out error: $e');
                }

                SharedPreferences prefs = await SharedPreferences.getInstance();
                // Keep device-level choices (language, notification switch) across accounts.
                final languageCode = prefs.getString('languageCode');
                final notificationsEnabled = prefs.getBool('notificationsEnabled');
                await prefs.clear();
                if (languageCode != null) await prefs.setString('languageCode', languageCode);
                if (notificationsEnabled != null) await prefs.setBool('notificationsEnabled', notificationsEnabled);

                Navigator.of(context, rootNavigator: true).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LandingPage()),
                      (route) => false,
                );
              } catch (e) {
                Navigator.of(context, rootNavigator: true).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(localizations.logoutFailed(e.toString()))),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Common.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(localizations.logout, style: TextStyle(
              color: Common.secondary,
              fontWeight: Common.weight,
              fontSize: Common.h2,
            )),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final myAppState = context.findAncestorStateOfType<MyAppState>();
    final currentLocale = myAppState?.locale ?? Localizations.localeOf(context);

    return WillPopScope(
      onWillPop: () => showExitConfirmationDialog(context),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              child: Center(
                child: SvgPicture.asset(
                  'assets/Icons/settings.svg',
                  color: Common.primary,
                  width: 25,
                  height: 25,
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: GestureDetector(
                onTap: _loadUserData, // refresh user data
                child: Image.asset('assets/Icons/refresh.png', width: 20, height: 20,),
              ),
            ),
          ],
          title: Text(localizations.settings, style: TextStyle(fontSize: Common.title, fontFamily: Common.family),),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(right: 12.0, left: 12.0, top: 12, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 5,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width/4,
                            height: MediaQuery.of(context).size.width/4,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: profile.isNotEmpty
                                ? Image.network(
                                    profile,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildInitial(),
                                  )
                                : _buildInitial(),
                          ),
                          SizedBox(height: 10,),
                          Text(name.isNotEmpty ? name : '-', style: TextStyle(fontWeight: Common.weight2, fontSize: Common.h1, color: Common.secondary, fontFamily: 'bold'),),
                          SizedBox(height: 2,),
                          Text(phone.isNotEmpty ? '+91 '+phone : '-', style: TextStyle(fontWeight: Common.weight2, fontSize: Common.h2, color: Common.secondary, fontFamily: 'bold'),),
                          SizedBox(height: 15,),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12, // vertical spacing when wrapped
                            children: [
                              // QR Code Button
                              ElevatedButton.icon(
                                icon: const Icon(Icons.qr_code),
                                label: Text(
                                  localizations.qrCode,
                                  style: TextStyle(
                                    color: Common.primary,
                                    fontSize: Common.h3,
                                    fontFamily: 'bold',
                                    fontWeight: Common.weight2,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Common.secondary,
                                  foregroundColor: Common.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Common.secondary,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    localizations.scanQrCode,
                                                    style: TextStyle(fontWeight: Common.weight, fontSize: Common.h1, color: Common.primary, fontFamily: 'bold',),
                                                  ),
                                                  Spacer(),
                                                  Align(
                                                    alignment: Alignment.topRight,
                                                    child: GestureDetector(
                                                      onTap: () => Navigator.of(context).pop(),
                                                      child: Icon(Icons.close, color: Colors.white, size: 24,),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 15),
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: Common.primary,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: QrImageView(
                                                  data: "https://rider.digistall.in/riderprofile/$phone",
                                                  version: QrVersions.auto,
                                                  size: 150.0,
                                                  gapless: true,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                localizations.qrShareProfile,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontWeight: Common.weight2, fontSize: Common.h3, color: Common.primary, fontFamily: 'bold',),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              // Download Card Button
                              ElevatedButton.icon(
                                icon: _isGenerating
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Icon(Icons.picture_as_pdf),
                                label: Text(
                                  _isGenerating ? localizations.preparing : localizations.downloadCard,
                                  style: TextStyle(
                                    color: Common.primary,
                                    fontSize: Common.h3,
                                    fontFamily: 'bold',
                                    fontWeight: Common.weight2,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Common.secondary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: _isGenerating ? null : _handleDownloadAndPrint,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2,),
                  Card(
                    elevation: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Common.primary,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
                        child: Column(
                          children: [
                            SizedBox(height: 15,),
                            InkWell(
                              onTap: () async {
                                // logout();
                              },

                              child: Row(
                                children: [
                                  Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Common.secondary,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset('assets/Icons/location.svg', color: Common.primary, width: 15, height: 15,),
                                    ),
                                  ),
                                  SizedBox(width: 20,),
                                  Expanded(child: Text(city.isNotEmpty ? localizations.cityName(city) : '-', style: TextStyle(fontSize: Common.h2, color: Common.secondary, fontWeight: Common.weight2, fontFamily: 'bold'),)),
                                  // if('assets/Icons/edit.svg'!=null)
                                    InkWell(
                                      onTap: () async {
                                        await showCityPickerDialog(city, _updateCity);
                                      },
                                      child: Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          // color: Common.secondary,
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset('assets/Icons/edit.svg', color: Common.secondary, width: 25, height: 25,),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // _buildListOptions(options[0]),
                            SizedBox(height: 2,),
                            Divider(color: Colors.grey.shade300,),
                            SizedBox(height: 2,),
                            InkWell(
                              onTap: () async {
                                // if (options[1] == 'Logout') {
                                //   // logout();
                                // }
                              },

                              child: Row(
                                children: [
                                  Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Common.secondary,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset('assets/Icons/bike.svg', color: Common.primary, width: 15, height: 15,),
                                    ),
                                  ),
                                  SizedBox(width: 20,),
                                  Expanded(child: Text(vehicle.isNotEmpty ? localizations.vehicleName(vehicle) : '-', style: TextStyle(fontSize: Common.h2, color: Common.secondary, fontWeight: Common.weight2, fontFamily: 'bold',),)),
                                  // if('assets/Icons/edit.svg'!=null)
                                  InkWell(
                                    onTap: () async {
                                      final screenWidth = MediaQuery.of(context).size.width;
                                      final prefs = await SharedPreferences.getInstance();

                                      await showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          backgroundColor: Common.secondary,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          title: Text(localizations.selectVehicle, style: TextStyle(fontWeight: Common.weight, color: Common.primary, fontSize: Common.title, fontFamily: 'bold')),
                                          content: SizedBox(
                                            width: screenWidth * 0.9,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: _vehicles.map((key) {
                                                return ListTile(
                                                  // dense: true,
                                                  title: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius: BorderRadius.circular(12)
                                                    ),
                                                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                                                    child: Row(
                                                      children: [
                                                        Icon(key=='Bike'? Icons.pedal_bike_rounded : key=='Auto'? Icons.electric_rickshaw_rounded : Icons.car_crash_rounded, size: 18, color: Common.primary,),
                                                        SizedBox(width: 20,),
                                                        Text(localizations.vehicleName(key), style: TextStyle(color: Common.primary, fontFamily: 'bold', fontSize: Common.h3, fontWeight: Common.weight),),
                                                        Spacer(),
                                                        Container(
                                                          height: 12,
                                                          width: 12,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          child: Center(
                                                            child: Image.asset('assets/Icons/right-arrow.png', color: Common.primary, width: 18, height: 18,),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  onTap: () async {
                                                    Navigator.of(context).pop();
                                                    // vehicleType filters the ride requests shown on the incoming bookings tab.
                                                    await prefs.setString('vehicleType', key);
                                                    getSnackBar(context, localizations.vehicleUpdated(localizations.vehicleName(key)), Colors.green, 0);
                                                    setState(() {
                                                      vehicle = key;
                                                    });
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 35,
                                      width: 35,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        // color: Common.secondary,
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset('assets/Icons/edit.svg', color: Common.secondary, width: 25, height: 25,),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // _buildListOptions(options[1]),
                            SizedBox(height: 2,),
                            Divider(color: Colors.grey.shade300,),
                            SizedBox(height: 2,),
                            InkWell(
                              onTap: () => _toggleNotifications(!_notificationsEnabled),
                              child: Row(
                                children: [
                                  Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Common.secondary,
                                    ),
                                    child: Center(
                                      child: Image.asset('assets/Icons/bell.png', color: Common.primary, width: 15, height: 15,),
                                    ),
                                  ),
                                  SizedBox(width: 20,),
                                  Expanded(child: Text(localizations.allowNotification, style: TextStyle(fontSize: Common.h2, color: Common.secondary, fontWeight: Common.weight2, fontFamily: 'bold'),)),
                                  Switch(
                                    value: _notificationsEnabled,
                                    activeColor: Common.primary,
                                    activeTrackColor: Common.secondary,
                                    onChanged: _toggleNotifications,
                                  ),
                                ],
                              ),
                            ),
                            // _buildListOptions(options[2]),
                            SizedBox(height: 2,),
                            Divider(color: Colors.grey.shade300,),
                            SizedBox(height: 2,),
                            // Language Switcher (styled like other options)
                            Card(
                              elevation: 3,
                              child: InkWell(
                                onTap: null, // No tap action, just for consistent look
                                child: Row(
                                  children: [
                                    Container(
                                      height: 35,
                                      width: 35,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Common.secondary,
                                      ),
                                      child: Center(
                                        child: Icon(Icons.language, color: Common.primary),
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Text(
                                        localizations.language,
                                        style: TextStyle(
                                          fontWeight: Common.weight2,
                                          fontSize: Common.h2,
                                          color: Common.secondary,
                                          fontFamily: 'bold',
                                        ),
                                      ),
                                    ),
                                    DropdownButton<Locale>(
                                      value: currentLocale,
                                      underline: SizedBox(),
                                      items: [
                                        DropdownMenuItem(
                                          value: Locale('en'),
                                          child: Text(localizations.english),
                                        ),
                                        DropdownMenuItem(
                                          value: Locale('hi'),
                                          child: Text(localizations.hindi),
                                        ),
                                      ],
                                      onChanged: (locale) {
                                        if (locale != null) {
                                          myAppState?.setLocale(locale);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 2,),
                            Divider(color: Colors.grey.shade300,),
                            SizedBox(height: 2,),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => HistoryPage()),
                                );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Common.secondary,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset('assets/Icons/history.svg', color: Common.primary, width: 18, height: 18,),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)!.history,
                                      style: TextStyle(fontSize: Common.h2, color: Common.secondary, fontWeight: Common.weight2, fontFamily: 'bold'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 2,),
                            Divider(color: Colors.grey.shade300,),
                            SizedBox(height: 2,),
                            InkWell(
                              onTap: () async {
                                logout();
                              },

                              child: Row(
                                children: [
                                  Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Common.secondary,
                                    ),
                                    child: Center(
                                      child: Icon(Icons.logout, color: Common.primary, size: 16),
                                    ),
                                  ),
                                  SizedBox(width: 20,),
                                  Expanded(child: Text(localizations.logout, style: TextStyle(fontSize: Common.h2, color: Common.secondary, fontWeight: Common.weight2, fontFamily: 'bold'),)),
                              
                                ],
                              ),
                            ),
                            // _buildListOptions(options[3]),
                            // Spacer(),
                            SizedBox(height: 10,),
                            GestureDetector(
                              onTap: _openPrivacyPolicy,
                              child: Text(localizations.privacyPolicy, style: TextStyle(fontWeight: Common.weight, fontSize: Common.h3, color: Common.light, decoration: TextDecoration.underline),),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


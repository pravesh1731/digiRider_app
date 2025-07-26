import 'dart:convert';
import 'dart:typed_data';

import 'package:digirider/pages/LandingPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../global/Common.dart';
import '../pages/GoogleSignInUp.dart';
import '../services/notification_service.dart';
import '../utils/_TimedSnackBar.dart';
import '../utils/bottomSnackBar.dart';
import '../utils/show_exit_dialog.dart';

import 'package:pdf/widgets.dart' as pw;
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

  List options = [
    ['assets/Icons/location.svg', 'Gotan', 'assets/Icons/edit.svg', '0'],
    ['assets/Icons/bike.svg', 'Bike', 'assets/Icons/edit.svg', '0'],
    ['assets/Icons/bell.png', 'Allow Notification', 'assets/Icons/right-arrow.png', '1'],
    ['assets/Icons/logout.png', 'Logout', null , '1'],
  ];

  bool _isGenerating = false;

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

    // Load image from network
    final netImgBytes = (await http.get(Uri.parse(qrcode))).bodyBytes;
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

    final pdfData = await _generatePdf();

    setState(() => _isGenerating = false);

    await Printing.layoutPdf(onLayout: (_) => pdfData);
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    checkNotificationPermission(context);
  }

  Future<void> checkNotificationPermission(BuildContext context) async {

    var status = await Permission.notification.status;

    if (status.isGranted) {
      return;
    }

    // 👇 Request permission (this will show the system permission popup if possible)
    var result = await Permission.notification.request();

    // 👉 Only handle the case where the permission was asked and user denied it
    if (result.isDenied) {
      // Delay the dialog until the frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showStyledPermissionDialog(
          context: context,
          title: "Notification Permission Needed",
          message: "We use notifications to alert you about important updates. Please enable permission.",
          // showSettingsButton: result.isPermanentlyDenied, // only show settings if needed
        );
      });
    }
  }

  void showStyledPermissionDialog({
    required BuildContext context,
    required String title,
    required String message,
    // bool showSettingsButton = true,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Common.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: EdgeInsets.only(top: 20, left: 24, right: 24),
        contentPadding: EdgeInsets.only(left: 24, right: 24, top: 14, bottom: 24),
        actionsPadding: EdgeInsets.only(right: 16, bottom: 16),
        title: Text(
          title,
          style: TextStyle(fontWeight: Common.weight2, fontFamily: 'bold', fontSize: 18, color: Common.primary),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Text(message, style: TextStyle(fontWeight: Common.weight2, fontFamily: 'bold', fontSize: Common.h2, color: Common.primary)),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: Common.primary,
              side: BorderSide(color: Common.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: Text("Close", style: TextStyle(color: Common.secondary, fontFamily: 'bold',fontSize: Common.h2, fontWeight: Common.weight2)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      phone = prefs.getString('phoneNumber') ?? '';
      city = prefs.getString('cityName') ?? '';
      vehicle = prefs.getString('vehicleType') ?? '';
      domain = prefs.getString('riderDomain') ?? '';
      qrcode = prefs.getString('qrcode') ?? '';
      // update the options list here if needed
      options[0][1] = city;
      options[1][1] = vehicle;
    });
  }

  Future<void> showCityPickerDialog(String currentCity, Function(String) onCitySelected) async {
    final screenWidth = MediaQuery.of(context).size.width;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Common.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text("Select City", style: TextStyle(fontWeight: Common.weight, color: Common.primary, fontSize: Common.title, fontFamily: 'bold')),
        content: SizedBox(
          width: screenWidth * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ["Gotan", "Jodhpur"].map((city) {
              return ListTile(
                title: Container(
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12)
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  child: Row(
                    children: [
                      // Icon(city=="Gotan"? Icons.pedal_bike_rounded : v=="Auto"? Icons.electric_rickshaw_rounded : Icons.car_crash_rounded, size: 18, color: Common.primary,),
                      // SizedBox(width: 20,),
                      Text(city, style: TextStyle(color: Common.primary, fontFamily: 'bold', fontSize: Common.h3, fontWeight: Common.weight),),
                      Spacer(),
                      Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // color: Common.secondary,
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
                  onCitySelected(city);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> logout() async {
    final screenWidth = MediaQuery.of(context).size.width;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Common.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 15),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        title: Text(
          "CONFIRM LOGOUT",
          style: TextStyle(fontWeight: Common.weight, color: Common.primary, fontSize: Common.title,),
        ),
        content: SizedBox(
          width: screenWidth * 0.9,
          child: Text("Are you sure you want to logout?", style: TextStyle(color: Common.primary, fontWeight: Common.weight, fontSize: Common.h2,),),
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
            child: Text("Cancel", style: TextStyle(color: Common.primary, fontWeight: Common.weight, fontSize: Common.h2,)),
          ),
          ElevatedButton(
            onPressed: () async {
              // 1. Show the loading dialog
              showDialog(
                context: context,
                barrierDismissible: false, // Prevent closing manually
                builder: (BuildContext context) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Common.primary),
                    ),
                  );
                },
              );

              try {
                // 2. Do logout steps
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // Optional: Sign out from Firebase if needed
                // await FirebaseAuth.instance.signOut();

                await NotificationService().resetFcmToken();

                // 3. After everything is done, remove the loader
                Navigator.of(context, rootNavigator: true).pop();

                // 4. Navigate to LandingPage
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LandingPage()),
                      (route) => false,
                );
              } catch (e) {
                Navigator.of(context, rootNavigator: true).pop(); // Close loader on error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Logout failed: $e")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Common.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              "Logout",
              style: TextStyle(
                color: Common.secondary,
                fontWeight: Common.weight,
                fontSize: Common.h2,
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
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
          title: Text('Settings', style: TextStyle(fontSize: Common.title, fontFamily: Common.family),),
        ),
        body: Container(
          child: Padding(
            padding: EdgeInsets.only(right: 12.0, left: 12.0, top: 12, bottom: 12),
            child: Column(
              children: [
                Card(
                  elevation: 5,
                  child: Container(
                    width: double.infinity,
                    // height: MediaQuery.of(context).size.height*2/9,
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
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
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
                                "QR Code",
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

                                            // const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Text(
                                                  "Scan QR Code",
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
                                              child: QrImageView( // ✅ Updated class name if using newer flutter_qr packages
                                                data: "https://rider.digistall.in/riderprofile/$phone",
                                                version: QrVersions.auto,
                                                size: 150.0,
                                                gapless: true,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              "Use this QR code to quickly share your profile",
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
                                _isGenerating ? "Preparing..." : "Download Card",
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
                Expanded(
                  child: Card(
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
                                  Expanded(child: Text(city.isNotEmpty ? city : 'Gotan', style: TextStyle(fontSize: Common.h2, color: Common.secondary, fontWeight: Common.weight2, fontFamily: 'bold'),)),
                                  // if('assets/Icons/edit.svg'!=null)
                                    InkWell(
                                      onTap: () async {
                                        final prefs = await SharedPreferences.getInstance();
                                        String? email = prefs.getString("email");

                                        if (email == null) return;

                                        await showCityPickerDialog(city, (newCity) async {


                                          // Send to API
                                          try {
                                            final response = await http.post(
                                              Uri.parse(Common.baseUrl+"api/rider/updatecityname"), // Replace with actual base URL
                                              headers: {"Content-Type": "application/json"},
                                              body: jsonEncode({
                                                "email": email,
                                                "cityName": newCity,
                                              }),
                                            );

                                            if (response.statusCode == 200) {
                                              print('success');
                                              getSnackBar(context, 'City updated successfully', Colors.green, 0);
                                              await prefs.setString("cityName", newCity);
                                              setState(() {
                                                city = newCity;
                                                options[0][1] = newCity; // optional if you're still using options[]
                                              });
                                            } else {
                                              getSnackBar(context, 'Failed to update city', Colors.red, 1);
                                            }
                                          } on Exception catch (e) {

                                            getSnackBar(context, 'Something Went wrong', Colors.orange, 2);
                                          }
                                        });
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
                                  Expanded(child: Text(vehicle.isNotEmpty ? vehicle : 'Bike', style: TextStyle(fontSize: Common.h2, color: Common.secondary, fontWeight: Common.weight2, fontFamily: 'bold',),)),
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
                                          title: Text("Select Vehicle", style: TextStyle(fontWeight: Common.weight, color: Common.primary, fontSize: Common.title, fontFamily: 'bold'),),
                                          content: SizedBox(
                                            width: screenWidth * 0.9,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: ["Bike", "Auto", "Car"].map((v) {
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
                                                        Icon(v=="Bike"? Icons.pedal_bike_rounded : v=="Auto"? Icons.electric_rickshaw_rounded : Icons.car_crash_rounded, size: 18, color: Common.primary,),
                                                        SizedBox(width: 20,),
                                                        Text(v, style: TextStyle(color: Common.primary, fontFamily: 'bold', fontSize: Common.h3, fontWeight: Common.weight),),
                                                        Spacer(),
                                                        Container(
                                                          height: 12,
                                                          width: 12,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            // color: Common.secondary,
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
                                                    await prefs.setString("vehicleType", v);
                                                    getSnackBar(context, 'Vehicle updated successfully', Colors.green, 0);

                                                    setState(() {
                                                      vehicle = v;
                                                      options[1][1] = v;
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
                                      child: Image.asset('assets/Icons/bell.png', color: Common.primary, width: 15, height: 15,),
                                    ),
                                  ),
                                  SizedBox(width: 20,),
                                  Expanded(child: Text('Allow Notification', style: TextStyle(fontSize: Common.h2, color: Common.secondary, fontWeight: Common.weight2, fontFamily: 'bold'),)),
                                  // if(options[2]!=null)
                                    Container(
                                      height: 35,
                                      width: 35,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        // color: Common.secondary,
                                      ),
                                      child: Center(
                                        child: Image.asset('assets/Icons/right-arrow.png', color: Common.secondary, width: 18, height: 18,),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // _buildListOptions(options[2]),
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
                                      child: Image.asset('assets/Icons/logout.png', color: Common.primary, width: 15, height: 15,),
                                    ),
                                  ),
                                  SizedBox(width: 20,),
                                  Expanded(child: Text('Logout', style: TextStyle(fontSize: Common.h2, color: Common.secondary, fontWeight: Common.weight2, fontFamily: 'bold'),)),
                                  // if(options[2]!=null)
                                  //   Container(
                                  //     height: 35,
                                  //     width: 35,
                                  //     decoration: BoxDecoration(
                                  //       borderRadius: BorderRadius.circular(10),
                                  //       // color: Common.secondary,
                                  //     ),
                                  //     child: Center(
                                  //       child: Image.asset('assets/Icons/right-arrow.png', color: Common.secondary, width: 18, height: 18,),
                                  //     ),
                                  //   ),
                                ],
                              ),
                            ),
                            // _buildListOptions(options[3]),
                            Spacer(),
                            Text('Terms & Conditions', style: TextStyle(fontWeight: Common.weight, fontSize: Common.h3, color: Common.light),)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


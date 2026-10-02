import 'dart:convert';
import 'dart:io';
import 'package:digirider/pages/LandingPage.dart';
import 'package:digirider/settings/SettingsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:digirider/global/Common.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../NavMain.dart';
import '../utils/bottomSnackBar.dart';

class DocumentUploadPage extends StatefulWidget {
  const DocumentUploadPage({super.key});

  @override
  State<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  File? _licenseFile;
  File? _qrCodeFile;
  bool _isLoading = false;

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        return true;
      }

      // Android 13+ granular media permissions
      if (await Permission.photos.request().isGranted ||
          await Permission.mediaLibrary.request().isGranted) {
        return true;
      }

      return false;
    } else if (Platform.isIOS) {
      // Optional: on iOS, file picker doesn't need permission for picker
      return true;
    }
    return false;
  }


  Future<void> _pickFile(bool isLicense) async {
    bool permissionGranted = await _requestStoragePermission();

    if (!permissionGranted) {
      getSnackBar(context, "Permission denied. Cannot access files.", Colors.orange, 2);
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        if (isLicense) {
          _licenseFile = File(result.files.single.path!);
        } else {
          _qrCodeFile = File(result.files.single.path!);
        }
      });
    }
  }



  MediaType _getMediaType(String path) {
    final ext = path.split('.').last.toLowerCase();

    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'pdf':
        return MediaType('application', 'pdf');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  void _onNextStep() async {
    if (_licenseFile == null || _qrCodeFile == null) {
      getSnackBar(context, "Please upload both documents.", Colors.orange, 2);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var uri = Uri.parse(Common.baseUrl + "api/rider/adv");
      var request = http.MultipartRequest('POST', uri);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString('email') ?? '';

      request.fields['email'] = email;

      request.files.add(await http.MultipartFile.fromPath(
        'licence',
        _licenseFile!.path,
        contentType: _getMediaType(_licenseFile!.path),
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'qrcode',
        _qrCodeFile!.path,
        contentType: _getMediaType(_qrCodeFile!.path),
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final res = jsonDecode(responseBody);

        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('licence', res['data']['licence'] ?? '');
        await prefs.setString('qrcode', res['data']['qrcode'] ?? '');

        getSnackBar(context, "Login successful!", Colors.green, 0);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NavMain(initialIndex: 1),
          ),
        );
      } else {
        getSnackBar(context, "Failed to upload documents", Colors.orange, 2);
      }
    } catch (e) {
      getSnackBar(context, "An error occurred. Please try again.", Colors.redAccent, 2);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }




  Widget _buildUploadField(String label, bool isLicense) {
    final isUploaded = isLicense ? _licenseFile != null : _qrCodeFile != null;

    return InkWell(
      onTap: () => _pickFile(isLicense),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Common.secondary, width: 1.5),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isUploaded ? "Uploaded: ${isLicense ? _licenseFile!.path.split('/').last : _qrCodeFile!.path.split('/').last}" : label,
                style: TextStyle(
                  fontFamily: 'bold',
                  fontSize: Common.h2,
                  color: Common.secondary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Icon(Icons.upload, color: Common.secondary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LandingPage()), // or LandingPage
              (route) => false,
        );
        return false; // prevent default back behavior
      },
      child: Scaffold(
        backgroundColor: Common.secondary,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 0,
          backgroundColor: Common.background,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black,
                      Common.background
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Center(
                    child: Card(
                      elevation: 4,
                      color: Common.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Upload your documents",
                              style: TextStyle(
                                fontFamily: 'bold',
                                fontSize: 20,
                                fontWeight: Common.weight,
                                color: Common.secondary,
                              ),
                            ),
                            SizedBox(height: 20),
                            _buildUploadField("Upload license", true),
                            SizedBox(height: 15),
                            _buildUploadField("Upload QR code", false),
                            SizedBox(height: 20),
                            InkWell(
                              onTap: _onNextStep,
                              child: Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Common.secondary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: _isLoading?
                                    Row(
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
                                    ): Text(
                                    "Upload",
                                    style: TextStyle(
                                      fontFamily: 'bold',
                                      fontSize: Common.h2,
                                      fontWeight: Common.weight2,
                                      color: Common.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              decoration: BoxDecoration(
                                color: Color(0xFFF4F2F2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                "All documents must be clear and readable. Upload only JPG, PNG, or PDF files.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'bold',
                                  fontSize: Common.h4,
                                  fontWeight: Common.weight,
                                  color: Common.light,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: InkWell(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LandingPage()), // or LandingPage
                          (route) => false,
                    );
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Common.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back, color: Common.primary, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

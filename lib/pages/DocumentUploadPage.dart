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
import 'package:shared_preferences/shared_preferences.dart';

import '../NavMain.dart';
import '../global/l10n.dart';
import '../services/notification_service.dart';
import '../utils/bottomSnackBar.dart';

class DocumentUploadPage extends StatefulWidget {
  const DocumentUploadPage({super.key});

  @override
  State<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  // Multipart field name -> picked file. licence and qrcode are required by api/rider/adv,
  // aadhaar and profile are optional (same as the website's signup step).
  final Map<String, File?> _files = {'licence': null, 'qrcode': null, 'aadhaar': null, 'profile': null};
  bool _isLoading = false;

  Future<void> _pickFile(String field) async {
    // The system file picker does not need storage permission.
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: field == 'profile' ? ['jpg', 'jpeg', 'png'] : ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _files[field] = File(result.files.single.path!);
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
    final l10n = context.l10n;
    if (_files['licence'] == null || _files['qrcode'] == null) {
      getSnackBar(context, l10n.uploadRequiredDocuments, Colors.orange, 2);
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

      for (final entry in _files.entries) {
        final file = entry.value;
        if (file == null) continue;
        request.files.add(await http.MultipartFile.fromPath(
          entry.key,
          file.path,
          contentType: _getMediaType(file.path),
        ));
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody)['data'] ?? {};

        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('licence', data['licence'] ?? '');
        await prefs.setString('qrcode', data['qrcode'] ?? '');
        await prefs.setString('aadhaar', data['aadhaar'] ?? '');
        await prefs.setString('profile', data['profile'] ?? '');
        await prefs.setString('userStatus', data['userStatus'] ?? 'Adv');
        await NotificationService().syncToken();
        if (!mounted) return;

        getSnackBar(context, l10n.loginSuccessful, Colors.green, 0);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => NavMain(initialIndex: 1),
          ),
          (route) => false,
        );
      } else {
        String message = l10n.uploadFailed;
        try {
          message = jsonDecode(responseBody)['message'] ?? message;
        } catch (_) {}
        getSnackBar(context, message, Colors.orange, 2);
      }
    } catch (e) {
      if (mounted) getSnackBar(context, l10n.errorTryAgain, Colors.redAccent, 2);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }




  Widget _buildUploadField(String label, String field) {
    final file = _files[field];

    return InkWell(
      onTap: () => _pickFile(field),
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
                file != null ? context.l10n.uploadedFile(file.path.split('/').last) : label,
                style: TextStyle(
                  fontFamily: 'bold',
                  fontSize: Common.h2,
                  color: Common.secondary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Icon(file != null ? Icons.check_circle : Icons.upload, color: file != null ? Colors.green : Common.secondary),
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
                    child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 60),
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
                              context.l10n.uploadYourDocuments,
                              style: TextStyle(
                                fontFamily: 'bold',
                                fontSize: 20,
                                fontWeight: Common.weight,
                                color: Common.secondary,
                              ),
                            ),
                            SizedBox(height: 20),
                            _buildUploadField(context.l10n.uploadLicense, 'licence'),
                            SizedBox(height: 15),
                            _buildUploadField(context.l10n.uploadQrCode, 'qrcode'),
                            SizedBox(height: 15),
                            _buildUploadField(context.l10n.uploadAadhaar, 'aadhaar'),
                            SizedBox(height: 15),
                            _buildUploadField(context.l10n.uploadProfilePhoto, 'profile'),
                            SizedBox(height: 20),
                            InkWell(
                              onTap: _isLoading ? null : _onNextStep,
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
                                    context.l10n.upload,
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
                                context.l10n.documentsHint,
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

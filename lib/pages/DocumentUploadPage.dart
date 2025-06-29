import 'dart:convert';
import 'dart:io';
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

class DocumentUploadPage extends StatefulWidget {
  const DocumentUploadPage({super.key});

  @override
  State<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  File? _licenseFile;
  File? _qrCodeFile;

  Future<void> _pickFile(bool isLicense) async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied. Cannot access files.')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload both documents')),
      );
      return;
    }

    var uri = Uri.parse(Common.baseUrl+"api/rider/adv"); // replace with actual endpoint
    var request = http.MultipartRequest('POST', uri);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = await prefs.getString('email') ?? '';

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

    // Optional headers if needed
    // request.headers['Authorization'] = 'Bearer token';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator(color: Common.secondary,)),
    );

    var response = await request.send();
    Navigator.of(context).pop(); // close loading

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString(); // ⬅️ Get response body
      final res = jsonDecode(responseBody);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('documentUploaded', true);

      print("Response: $res"); // ⬅️ Print decoded response
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NavMain(initialIndex: 4), // e.g. open Settings page
        ),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload documents')),
      );
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Common.background,
        body: Padding(
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
                          child: Text(
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
    );
  }
}

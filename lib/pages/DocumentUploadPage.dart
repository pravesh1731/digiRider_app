import 'dart:convert';
import 'dart:io';
import 'package:digirider/pages/LandingPage.dart';
import 'package:flutter/material.dart';
import 'package:digirider/global/Common.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../NavMain.dart';
import '../global/l10n.dart';
import '../services/notification_service.dart';
import '../services/rider_feed.dart';
import '../ui/widgets.dart';
import 'auth_widgets.dart';
import '../utils/bottomSnackBar.dart';

class DocumentUploadPage extends StatefulWidget {
  /// Opened from Profile → Documents to replace files: back just closes the page.
  final bool fromProfile;
  const DocumentUploadPage({super.key, this.fromProfile = false});

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

        if (widget.fromProfile) {
          await RiderFeed.instance.loadProfile();
          if (mounted) Navigator.of(context).pop();
          return;
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const NavMain()),
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




  void _backToLanding() {
    if (widget.fromProfile) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LandingPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.cap;
    // licence and qrcode are required by api/rider/adv; aadhaar and profile are optional.
    final docs = [
      ('licence', l10n.cLicence, l10n.cLicenceDesc, true),
      ('qrcode', l10n.cPaymentQr, l10n.cQrDesc, true),
      ('aadhaar', l10n.cAadhaar, l10n.cAadhaarDesc, false),
      ('profile', l10n.cProfilePhoto, l10n.cPhotoDesc, false),
    ];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToLanding();
      },
      child: CapAuthScaffold(
        step: widget.fromProfile ? null : 4,
        stepLabel: l10n.cVerificationLbl,
        title: l10n.cUploadDocsTitle,
        onBack: _backToLanding,
        children: [
          Text(l10n.cUploadDocsDesc, style: CapText.sans(size: 14, color: p.mu, height: 1.5)),
          const SizedBox(height: 16),
          CapList(
            children: [
              for (final (field, name, desc, required) in docs)
                CapListItem(
                  onTap: () => _pickFile(field),
                  leading: IconBox(
                    icon: _files[field] != null ? CapIcons.chk : CapIcons.up,
                    color: _files[field] != null ? p.lv : p.tx,
                  ),
                  trailing: CapChip(label: _files[field] != null ? l10n.cChange : l10n.cUploadBtn, background: p.s1, onTap: () => _pickFile(field)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(name, style: CapText.sans(size: 15, weight: FontWeight.w700, color: p.tx)),
                          CapTag(
                            _files[field] != null ? l10n.cUploadedTag : (required ? l10n.cRequiredTag : l10n.cOptionalTag),
                            size: 10.5,
                            color: _files[field] != null ? p.lv : (required ? p.rd : p.mu),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _files[field] != null ? _files[field]!.path.split('/').last : desc,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CapText.sans(size: 12, color: p.mu),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          CapButton(
            label: l10n.cSubmitForReview,
            trailingIcon: CapIcons.arr,
            loading: _isLoading,
            onPressed: _isLoading ? null : _onNextStep,
          ),
          const SizedBox(height: 18),
          Text(l10n.documentsHint, textAlign: TextAlign.center, style: CapText.sans(size: 12, color: p.mu, height: 1.5)),
        ],
      ),
    );
  }
}

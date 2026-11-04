import 'package:digirider/pages/LandingPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../global/l10n.dart';
import '../global/my_app_state.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/rider_feed.dart';
import '../ui/cap_visuals.dart';
import '../ui/pickers.dart';
import '../ui/widgets.dart';
import 'sub_pages.dart';

/// The website's Profile tab: Captain pass, stats, preferences, links and log out.
class SettingsPage extends StatefulWidget {
  final VoidCallback? onGoHome;
  const SettingsPage({super.key, this.onGoHome});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    NotificationService().isEnabled().then((v) {
      if (mounted) setState(() => _notificationsEnabled = v);
    });
  }

  Future<void> _toggleNotifications(bool enabled) async {
    final l10n = context.l10n;
    final granted = await NotificationService().setEnabled(enabled);
    if (!mounted) return;
    setState(() => _notificationsEnabled = enabled);

    if (!enabled) {
      showCapToast(context, l10n.notificationsOff);
    } else if (granted) {
      await NotificationService().showTestNotification();
      if (mounted) showCapToast(context, l10n.notificationsOn);
    } else {
      showCapToast(context, l10n.notificationsBlocked, color: context.cap.rd);
    }
  }

  /// Opens the website's account deletion page in the browser.
  Future<void> _openDeleteAccount() async {
    final url = Uri.parse('https://rider.digistall.in/delete-account.html');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication) && mounted) {
      showCapToast(context, context.l10n.couldNotOpenLink, color: context.cap.rd);
    }
  }

  Future<void> _logout() async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      label: l10n.cLogOut,
      title: l10n.confirmLogout,
      message: l10n.logoutPrompt,
      confirmLabel: l10n.cLogOut,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator(color: context.cap.am)),
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

      final prefs = await SharedPreferences.getInstance();
      // Keep device-level choices (language, theme, notification switch) across accounts.
      final languageCode = prefs.getString('languageCode');
      final theme = prefs.getString('captainTheme');
      final notificationsEnabled = prefs.getBool('notificationsEnabled');
      await prefs.clear();
      if (languageCode != null) await prefs.setString('languageCode', languageCode);
      if (theme != null) await prefs.setString('captainTheme', theme);
      if (notificationsEnabled != null) await prefs.setBool('notificationsEnabled', notificationsEnabled);
      RiderFeed.instance.reset();

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LandingPage()), (route) => false);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      showCapToast(context, l10n.logoutFailed(e.toString()), color: context.cap.rd);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final app = context.findAncestorStateOfType<MyAppState>();
    final isHindi = (app?.locale ?? Localizations.localeOf(context)).languageCode == 'hi';
    final isDark = app?.isDark ?? context.cap.isDark;
    final feed = RiderFeed.instance;

    return ListenableBuilder(
      listenable: feed,
      builder: (context, _) {
        final p = context.cap;
        final name = feed.name.isEmpty ? l10n.cBrand : feed.name;
        final plate = '@${(feed.domain.isNotEmpty ? feed.domain : name).toUpperCase()}';
        final verified = feed.userStatus == 'Adv' || feed.licence.isNotEmpty;

        Widget stat(String value, String label) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: CapText.serif(size: 30, color: p.tx, height: 1)),
                KLabel(label, padding: const EdgeInsets.only(top: 2)),
              ],
            );

        Widget settingRow({required CapIcons icon, String? label, required String title, Widget? trailing, VoidCallback? onTap}) {
          return CapListItem(
            onTap: onTap,
            leading: IconBox(icon: icon),
            trailing: trailing,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null) KLabel(label, padding: const EdgeInsets.only(bottom: 2)),
                Text(title, style: CapText.sans(size: 15, weight: label == null ? FontWeight.w700 : FontWeight.w600, color: p.tx)),
              ],
            ),
          );
        }

        Widget linkRow(CapIcons icon, String title, WidgetBuilder page) => settingRow(
              icon: icon,
              title: title,
              trailing: CapIcon(CapIcons.chev, size: 18, color: p.mu),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: page)),
            );

        return CapPage(
          onRefresh: () async {
            await feed.loadProfile();
            await feed.refreshHistory();
          },
          children: [
            Align(alignment: Alignment.centerLeft, child: CapChip.back(context, label: l10n.cNavHome, onTap: widget.onGoHome)),
            const SizedBox(height: 14),
            KLabel(l10n.cCaptainPass),
            const SizedBox(height: 6),
            CaptainPass(
              name: name,
              plate: plate,
              vehicle: l10n.vehicleName(feed.vehicle),
              city: l10n.cityName(feed.city),
              verified: verified,
              qrData: 'https://rider.digistall.in/riderprofile/${feed.phone}',
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  stat(l10n.cNoRating, l10n.cRating),
                  stat(l10n.cNoRating, l10n.cAcceptance),
                  stat('${feed.delivered.length}', l10n.cTrips),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CapList(
              children: [
                settingRow(
                  icon: CapIcons.globe,
                  label: l10n.cLanguageLabel,
                  title: isHindi ? 'हिंदी (Hindi)' : 'English',
                  trailing: LanguagePill(isHindi: isHindi, onTap: () => app?.setLocale(Locale(isHindi ? 'en' : 'hi'))),
                ),
                settingRow(
                  icon: CapIcons.pin,
                  label: l10n.cServiceCityK,
                  title: l10n.cityName(feed.city),
                  trailing: CapChip(label: l10n.cChange, background: p.s1, onTap: () => showCityPicker(context)),
                ),
                settingRow(
                  icon: CapIcons.car,
                  label: l10n.cVehicleTypeK,
                  title: l10n.vehicleName(feed.vehicle),
                  trailing: CapChip(label: l10n.cChange, background: p.s1, onTap: () => showVehiclePicker(context)),
                ),
                settingRow(
                  icon: CapIcons.bell,
                  title: l10n.cNotifications,
                  trailing: CapSwitch(value: _notificationsEnabled, semanticLabel: l10n.cNotifications, onChanged: _toggleNotifications),
                ),
                settingRow(
                  icon: CapIcons.moon,
                  title: l10n.cDarkTheme,
                  trailing: CapSwitch(value: isDark, semanticLabel: l10n.cDarkTheme, onChanged: (v) => app?.setDark(v)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            CapList(
              children: [
                linkRow(CapIcons.doc, l10n.cDocuments, (_) => const DocumentsPage()),
                linkRow(CapIcons.bell, l10n.cAlerts, (_) => const AlertsPage()),
                linkRow(CapIcons.gift, l10n.cReferEarn, (_) => const ReferPage()),
                linkRow(CapIcons.help, l10n.cHelpSupport, (_) => const HelpPage()),
                settingRow(
                  icon: CapIcons.trash,
                  title: l10n.cDeleteAccount,
                  trailing: CapIcon(CapIcons.chev, size: 18, color: p.mu),
                  onTap: _openDeleteAccount,
                ),
              ],
            ),
            const SizedBox(height: 20),
            CapButton(label: l10n.cLogOut, style: CapButtonStyle.ghost, textColor: p.rd, onPressed: _logout),
          ],
        );
      },
    );
  }
}

/// The printable rider ID card (front with details and profile QR, back with the payment QR).
/// English only: the PDF font has no Devanagari.
Future<Uint8List> generateRiderIdCard() async {
  final pdf = pw.Document();
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString('name') ?? '';
  final phone = prefs.getString('phoneNumber') ?? '';
  final city = prefs.getString('cityName') ?? '';
  final vehicle = prefs.getString('vehicleType') ?? '';
  final domain = prefs.getString('riderDomain') ?? '';
  final qrcode = prefs.getString('qrcode') ?? '';

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

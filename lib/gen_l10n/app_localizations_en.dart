// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get hello => 'Hello';

  @override
  String get welcome => 'Welcome to DigiRider!';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi';

  @override
  String get qrCode => 'QR Code';

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String get qrShareProfile => 'Use this QR code to quickly share your profile';

  @override
  String get preparing => 'Preparing...';

  @override
  String get downloadCard => 'Download Card';

  @override
  String get gotan => 'Gotan';

  @override
  String get jodhpur => 'Jodhpur';

  @override
  String get selectCity => 'Select City';

  @override
  String get close => 'Close';

  @override
  String get confirmLogout => 'CONFIRM LOGOUT';

  @override
  String get logoutPrompt => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get logout => 'Logout';

  @override
  String logoutFailed(Object error) {
    return 'Logout failed: $error';
  }

  @override
  String get bike => 'Bike';

  @override
  String get auto => 'Auto';

  @override
  String get car => 'Car';

  @override
  String get allowNotification => 'Allow Notification';

  @override
  String get terms => 'Terms & Conditions';

  @override
  String get cityUpdated => 'City updated successfully';

  @override
  String get cityUpdateFailed => 'Failed to update city';

  @override
  String get history => 'History';
}

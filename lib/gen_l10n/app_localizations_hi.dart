// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get hello => 'नमस्ते';

  @override
  String get welcome => 'DigiRider में आपका स्वागत है!';

  @override
  String get language => 'भाषा';

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get hindi => 'हिंदी';

  @override
  String get qrCode => 'क्यूआर कोड';

  @override
  String get scanQrCode => 'क्यूआर कोड स्कैन करें';

  @override
  String get qrShareProfile =>
      'अपनी प्रोफ़ाइल साझा करने के लिए इस क्यूआर कोड का उपयोग करें';

  @override
  String get preparing => 'तैयार किया जा रहा है...';

  @override
  String get downloadCard => 'कार्ड डाउनलोड करें';

  @override
  String get gotan => 'गोटन';

  @override
  String get jodhpur => 'जोधपुर';

  @override
  String get selectCity => 'शहर चुनें';

  @override
  String get close => 'बंद करें';

  @override
  String get confirmLogout => 'लॉगआउट की पुष्टि करें';

  @override
  String get logoutPrompt => 'क्या आप वाकई लॉगआउट करना चाहते हैं?';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get logout => 'लॉगआउट';

  @override
  String logoutFailed(Object error) {
    return 'लॉगआउट विफल: $error';
  }

  @override
  String get bike => 'बाइक';

  @override
  String get auto => 'ऑटो';

  @override
  String get car => 'कार';

  @override
  String get allowNotification => 'सूचनाएँ अनुमति दें';

  @override
  String get terms => 'नियम और शर्तें';

  @override
  String get cityUpdated => 'शहर सफलतापूर्वक अपडेट किया गया';

  @override
  String get cityUpdateFailed => 'शहर अपडेट करने में विफल';

  @override
  String get history => 'इतिहास';
}

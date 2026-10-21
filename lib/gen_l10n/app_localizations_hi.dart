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
  String logoutFailed(String error) {
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

  @override
  String get appName => 'डिजिटल राइडर';

  @override
  String get somethingWentWrong => 'कुछ गलत हो गया।';

  @override
  String get unknown => 'अज्ञात';

  @override
  String get notAvailable => 'उपलब्ध नहीं';

  @override
  String get invalidDate => 'अमान्य तारीख';

  @override
  String get deliveryTimeNotSet => 'डिलीवरी समय तय नहीं';

  @override
  String get invalidDeliveryTime => 'अमान्य डिलीवरी समय';

  @override
  String get nothingHereYet => 'अभी यहाँ कुछ नहीं है';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get exitApp => 'ऐप बंद करें';

  @override
  String get exitPrompt => 'क्या आप वाकई ऐप बंद करना चाहते हैं?';

  @override
  String get exit => 'बाहर निकलें';

  @override
  String get notificationPermissionTitle => 'सूचना की अनुमति चाहिए';

  @override
  String get notificationPermissionMessage =>
      'नए ऑर्डर की सूचना देने के लिए हमें अनुमति चाहिए। कृपया अनुमति दें।';

  @override
  String get riderOrders => 'राइड ऑर्डर';

  @override
  String get parcelOrders => 'पार्सल ऑर्डर';

  @override
  String get digistallOrders => 'डिजीस्टॉल ऑर्डर';

  @override
  String get statusEnRoute => 'पिकअप के रास्ते में';

  @override
  String get statusInTransit => 'डिलीवरी के रास्ते में';

  @override
  String get statusDelivered => 'डिलीवर हो गया';

  @override
  String get statusCancelled => 'रद्द';

  @override
  String get statusLabel => 'स्थिति';

  @override
  String get pickup => 'पिकअप';

  @override
  String get drop => 'ड्रॉप';

  @override
  String get pickupNA => 'पिकअप उपलब्ध नहीं';

  @override
  String get dropNA => 'ड्रॉप उपलब्ध नहीं';

  @override
  String get cartValue => 'कार्ट मूल्य';

  @override
  String get tripDistance => 'यात्रा की दूरी';

  @override
  String get distanceNA => 'दूरी उपलब्ध नहीं';

  @override
  String get total => 'कुल';

  @override
  String commissionAmount(String amount) {
    return 'कमीशन: ₹$amount';
  }

  @override
  String totalAmountValue(String amount) {
    return 'कुल: ₹$amount';
  }

  @override
  String get viewMap => 'मैप देखें';

  @override
  String get accept => 'स्वीकार करें';

  @override
  String get couldNotOpenMaps => 'मैप नहीं खुल सका।';

  @override
  String deliveryBy(String time) {
    return 'डिलीवरी - $time';
  }

  @override
  String get finishCurrentRidesFirst => 'पहले अपनी चालू राइड पूरी करें';

  @override
  String get orderAccepted => 'ऑर्डर सफलतापूर्वक स्वीकार किया गया';

  @override
  String get acceptFailed =>
      'ऑर्डर स्वीकार नहीं हो सका। कृपया फिर से कोशिश करें।';

  @override
  String get incomingBookings => 'नई बुकिंग';

  @override
  String vehicleTypeLabel(String vehicle) {
    return 'वाहन प्रकार: $vehicle';
  }

  @override
  String ordersCount(int count) {
    return '$count ऑर्डर';
  }

  @override
  String get newOrdersHint => 'आपके शहर के नए ऑर्डर यहाँ अपने आप दिखेंगे।';

  @override
  String orderNumber(String id) {
    return 'ऑर्डर #$id';
  }

  @override
  String productLabel(String name) {
    return 'उत्पाद - $name';
  }

  @override
  String quantityLabel(String quantity) {
    return 'मात्रा - $quantity';
  }

  @override
  String get name => 'नाम';

  @override
  String get contact => 'संपर्क';

  @override
  String get progress => 'प्रगति';

  @override
  String get viewDetails => 'विवरण देखें';

  @override
  String get home => 'मेरे ऑर्डर';

  @override
  String get gettingLocation => 'आपकी लोकेशन ली जा रही है...';

  @override
  String get locationDenied => 'लोकेशन की अनुमति नहीं मिली';

  @override
  String get locationDeniedForever => 'लोकेशन की अनुमति स्थायी रूप से बंद है';

  @override
  String get unableToGetLocation => 'लोकेशन नहीं मिल सकी';

  @override
  String get currentLocationFound => 'वर्तमान लोकेशन मिल गई';

  @override
  String locationCoordinates(String lat, String lng) {
    return 'लोकेशन निर्देशांक: $lat, $lng';
  }

  @override
  String get actionFailed => 'कार्रवाई विफल रही। कृपया फिर से कोशिश करें।';

  @override
  String get tripStarted => 'यात्रा सफलतापूर्वक शुरू हुई।';

  @override
  String get tripCompletedSuccess => 'यात्रा सफलतापूर्वक पूरी हुई।';

  @override
  String get enterCustomerOtp => 'ग्राहक का OTP यहाँ दर्ज करें';

  @override
  String get enterDeliveryOtp => 'ग्राहक से मिला डिलीवरी OTP दर्ज करें';

  @override
  String get pleaseEnterCustomerOtp => 'कृपया ग्राहक का OTP दर्ज करें।';

  @override
  String get pleaseEnterDeliveryOtp => 'कृपया डिलीवरी OTP दर्ज करें।';

  @override
  String get startTrip => 'यात्रा शुरू करें';

  @override
  String get completeTrip => 'यात्रा पूरी करें';

  @override
  String get tripCompleted => 'यात्रा पूरी हुई';

  @override
  String get tripDetails => 'यात्रा विवरण';

  @override
  String get tripInProgress => 'यात्रा जारी है';

  @override
  String get customerPhoneMissing => 'ग्राहक का फ़ोन नंबर उपलब्ध नहीं है।';

  @override
  String get couldNotLaunchDialer => 'फ़ोन डायलर नहीं खुल सका।';

  @override
  String get callCustomer => 'ग्राहक को कॉल करें';

  @override
  String get navigateToPickup => 'पिकअप तक नेविगेट करें';

  @override
  String get navigateToDestination => 'गंतव्य तक नेविगेट करें';

  @override
  String get pickupAddressMissing => 'पिकअप पता उपलब्ध नहीं है।';

  @override
  String get destinationAddressMissing => 'गंतव्य का पता उपलब्ध नहीं है।';

  @override
  String get orderId => 'ऑर्डर आईडी';

  @override
  String get phoneNo => 'फ़ोन नंबर';

  @override
  String get distance => 'दूरी';

  @override
  String get vehicleType => 'वाहन प्रकार';

  @override
  String get numberOfPassengers => 'यात्रियों की संख्या';

  @override
  String get parcelMessage => 'पार्सल संदेश';

  @override
  String get parcelWeight => 'पार्सल का वज़न';

  @override
  String get nil => 'कुछ नहीं';

  @override
  String get totalValue => 'कुल मूल्य';

  @override
  String get deliverBy => 'डिलीवरी समय';

  @override
  String get pickupTime => 'पिकअप समय';

  @override
  String get yourLocation => 'आपकी लोकेशन';

  @override
  String get tripCompletedTitle => 'यात्रा पूरी हुई!';

  @override
  String get pickupLocation => 'पिकअप स्थान';

  @override
  String get destination => 'गंतव्य';

  @override
  String get totalAmount => 'कुल राशि';

  @override
  String get cartValueLabel => 'कार्ट मूल्य';

  @override
  String get scanToPay => 'भुगतान के लिए स्कैन करें';

  @override
  String invoiceDownloaded(String path) {
    return 'इनवॉइस डाउनलोड हुआ: $path';
  }

  @override
  String invoiceDownloadFailed(String error) {
    return 'इनवॉइस डाउनलोड नहीं हो सका: $error';
  }

  @override
  String get downloadInvoice => 'इनवॉइस डाउनलोड करें';

  @override
  String get done => 'हो गया';

  @override
  String get selectVehicle => 'वाहन चुनें';

  @override
  String vehicleUpdated(String vehicle) {
    return 'वाहन $vehicle में बदल दिया गया';
  }

  @override
  String get notificationsOn => 'सूचनाएँ चालू हो गईं';

  @override
  String get notificationsOff => 'सूचनाएँ बंद हो गईं';

  @override
  String get notificationsBlocked =>
      'सूचनाएँ बंद हैं। कृपया फ़ोन की सेटिंग्स में अनुमति दें।';

  @override
  String get testNotification => 'टेस्ट सूचना भेजें';

  @override
  String get testNotificationSent => 'टेस्ट सूचना भेज दी गई!';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get earnings => 'कमाई';

  @override
  String get totalEarnings => 'कुल कमाई';

  @override
  String get earningsBreakdown => 'कमाई का विवरण';

  @override
  String completedDeliveries(int count) {
    return '$count डिलीवरी पूरी';
  }

  @override
  String completedRidesCount(int count) {
    return '$count राइड पूरी';
  }

  @override
  String deliveredParcelsCount(int count) {
    return '$count पार्सल डिलीवर';
  }

  @override
  String deliveredOrdersCount(int count) {
    return '$count ऑर्डर डिलीवर';
  }

  @override
  String get couldNotLoadEarnings =>
      'कमाई लोड नहीं हो सकी। फिर से कोशिश करने के लिए नीचे खींचें।';

  @override
  String get signUp => 'साइन अप';

  @override
  String get login => 'लॉगिन';

  @override
  String get signIn => 'साइन इन';

  @override
  String get welcomeToDigitalRider => 'डिजिटल राइडर में आपका स्वागत है';

  @override
  String get whereDoWeGetOrders => 'हमें ऑर्डर कहाँ से मिलते हैं';

  @override
  String get onboardingProcess => 'जुड़ने की प्रक्रिया';

  @override
  String get benefitsTitle => 'डिजिटल राइडर बनने के फ़ायदे';

  @override
  String get aboutUs => 'हमारे बारे में';

  @override
  String get aboutUsText =>
      'हम व्यवसायों को भरोसेमंद राइडर्स से जोड़कर ऑर्डर पूरा करना और डिलीवरी आसान बनाते हैं।';

  @override
  String get earnPerDay => 'रोज़ 1000 तक कमाएँ';

  @override
  String get earnPerDayDesc => 'भरोसेमंद ऑर्डर से रोज़ाना कमाई का मौका।';

  @override
  String get driveAnyVehicle => 'कोई भी वाहन चलाएँ';

  @override
  String get driveAnyVehicleDesc =>
      'ऑटो, बाइक, कार या टैक्सी — जो है उसी से कमाएँ।';

  @override
  String get threeStepOnboarding => '3 आसान चरणों में जुड़ें';

  @override
  String get threeStepOnboardingDesc =>
      'तेज़ प्रक्रिया से जल्दी कमाई शुरू करें।';

  @override
  String get basicInfo => 'बुनियादी जानकारी';

  @override
  String get basicInfoDesc =>
      'अपना नाम, संपर्क विवरण और पता जैसी बुनियादी जानकारी दें।';

  @override
  String get documents => 'दस्तावेज़';

  @override
  String get documentsDesc =>
      'आधार, ड्राइविंग लाइसेंस, पेमेंट QR और प्रोफ़ाइल फ़ोटो अपलोड करें।';

  @override
  String get verification => 'सत्यापन';

  @override
  String get verificationDesc =>
      'दस्तावेज़ सत्यापित होते ही हम आपको सूचित करेंगे। आपको फ़िज़िकल कार्ड दिया जाएगा।';

  @override
  String get flexibleSchedule => 'लचीला समय';

  @override
  String get flexibleScheduleDesc => 'अपने काम के घंटे खुद चुनें।';

  @override
  String get competitiveEarnings => 'बेहतर कमाई';

  @override
  String get competitiveEarningsDesc =>
      'बोनस और इंसेंटिव के साथ ज़्यादा कमाएँ।';

  @override
  String get regularOrders => 'नियमित ऑर्डर';

  @override
  String get regularOrdersDesc => 'लगातार ऑर्डर से स्थिर आमदनी।';

  @override
  String get supportiveCommunity => 'सहयोगी समुदाय';

  @override
  String get supportiveCommunityDesc => 'राइडर सहायता हमेशा तैयार।';

  @override
  String get training => 'प्रशिक्षण और विकास';

  @override
  String get trainingDesc => 'अपने कौशल सुधारें और अपडेट रहें।';

  @override
  String get healthSafety => 'स्वास्थ्य और सुरक्षा';

  @override
  String get healthSafetyDesc =>
      'हम आपके स्वास्थ्य और सुरक्षा को प्राथमिकता देते हैं।';

  @override
  String get newsletter => 'न्यूज़लेटर';

  @override
  String get ordersFromGotanStore => 'गोटन स्टोर ऐप से ऑर्डर';

  @override
  String get pickDropPerson => 'सवारी को पिक और ड्रॉप करें';

  @override
  String get pickDropParcel => 'पार्सल पिक और ड्रॉप करें';

  @override
  String get ordersFromDigistall => 'डिजीस्टॉल से ऑर्डर';

  @override
  String get deliverDigistallOrders =>
      'डिजीस्टॉल स्टोर के ऑर्डर डिलीवर करें और कमीशन कमाएँ';

  @override
  String get alreadyHaveAccountSignIn =>
      'आपका खाता पहले से है। कृपया साइन इन करें।';

  @override
  String get loginSuccessWelcome => 'लॉगिन सफल! फिर से स्वागत है।';

  @override
  String get uploadDocumentsToContinue =>
      'आगे बढ़ने के लिए कृपया अपने दस्तावेज़ अपलोड करें।';

  @override
  String get noAccountSignUp => 'आपका खाता नहीं है। कृपया साइन अप करें।';

  @override
  String get googleSignInFailed => 'Google साइन-इन विफल रहा।';

  @override
  String get loginToAccount => 'अपने खाते में लॉग इन करें';

  @override
  String get createNewAccount => 'नया खाता बनाएँ';

  @override
  String get continueWithGoogle => 'Google के साथ जारी रखें';

  @override
  String get createNewAccountQuestion => 'नया खाता बनाएँ?';

  @override
  String get alreadyHaveAccountQuestion => 'पहले से खाता है?';

  @override
  String get agreeTerms =>
      'लॉग इन करके आप हमारी नियम और शर्तों से सहमत होते हैं';

  @override
  String get enterSubdomainError => 'कृपया सबडोमेन दर्ज करें';

  @override
  String get domainTaken => 'यह डोमेन पहले से लिया जा चुका है।';

  @override
  String get createDigitalIdentity => 'अपनी डिजिटल पहचान बनाएँ';

  @override
  String get continueNextStep => 'अगले चरण पर जाएँ';

  @override
  String get domainInfo =>
      'यह डोमेन आपकी डिजिटल पहचान का हिस्सा बनेगा और आपको अलग से पहचानने में मदद करेगा।';

  @override
  String get enterSubdomain => 'सबडोमेन दर्ज करें';

  @override
  String get fillAllDetails => 'कृपया सभी विवरण सही से भरें।';

  @override
  String get selectCityAndVehicle => 'कृपया अपना शहर और वाहन प्रकार चुनें';

  @override
  String get accountCreated => 'खाता सफलतापूर्वक बन गया';

  @override
  String get submitFailed => 'जमा नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get enterYourDetails => 'अपना विवरण दर्ज करें';

  @override
  String get phoneNumber => 'फ़ोन नंबर';

  @override
  String get infoSafe =>
      'आपकी जानकारी सुरक्षित है और केवल सेवा देने के लिए उपयोग होगी।';

  @override
  String get uploadRequiredDocuments =>
      'कृपया अपना लाइसेंस और पेमेंट QR कोड अपलोड करें।';

  @override
  String get loginSuccessful => 'लॉगिन सफल!';

  @override
  String get uploadFailed => 'दस्तावेज़ अपलोड नहीं हो सके';

  @override
  String get errorTryAgain => 'एक त्रुटि हुई। कृपया फिर से कोशिश करें।';

  @override
  String uploadedFile(String name) {
    return 'अपलोड हुआ: $name';
  }

  @override
  String get uploadYourDocuments => 'अपने दस्तावेज़ अपलोड करें';

  @override
  String get uploadLicense => 'लाइसेंस अपलोड करें';

  @override
  String get uploadQrCode => 'पेमेंट QR कोड अपलोड करें';

  @override
  String get uploadAadhaar => 'आधार अपलोड करें (वैकल्पिक)';

  @override
  String get uploadProfilePhoto => 'प्रोफ़ाइल फ़ोटो अपलोड करें (वैकल्पिक)';

  @override
  String get upload => 'अपलोड करें';

  @override
  String get documentsHint =>
      'सभी दस्तावेज़ साफ़ और पढ़ने योग्य हों। केवल JPG, PNG या PDF फ़ाइल अपलोड करें।';

  @override
  String get or => 'या';

  @override
  String get orderAlreadyTaken =>
      'यह ऑर्डर किसी दूसरे राइडर ने पहले ही स्वीकार कर लिया है।';
}

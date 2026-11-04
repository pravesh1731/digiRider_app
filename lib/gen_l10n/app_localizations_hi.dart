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

  @override
  String get goodMorning => 'सुप्रभात,';

  @override
  String get goodAfternoon => 'नमस्ते,';

  @override
  String get goodEvening => 'शुभ संध्या,';

  @override
  String get navRequests => 'नए ऑर्डर';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get timeLabel => 'समय';

  @override
  String get earnLabel => 'कमाई';

  @override
  String get earnedLabel => 'कमाया';

  @override
  String get storeLocation => 'दुकान का पता';

  @override
  String get noActiveRequests => 'अभी कोई नया ऑर्डर नहीं';

  @override
  String get noActiveOrders => 'कोई चालू ऑर्डर नहीं';

  @override
  String get noActiveOrdersDesc =>
      'यहाँ देखने के लिए नए ऑर्डर टैब से कोई ऑर्डर स्वीकार करें।';

  @override
  String get noHistory => 'कोई पुराना ऑर्डर नहीं मिला';

  @override
  String get getStartedNow => 'अभी शुरू करें';

  @override
  String get heroLine1 => 'चलाएँ, पहुँचाएँ,';

  @override
  String get heroLine2 => 'रोज़ कमाएँ।';

  @override
  String get loginSubtitle => 'डिजीस्टॉल राइडर में फिर से स्वागत है';

  @override
  String get signupSubtitle => 'आज ही डिजीस्टॉल राइडर बनें';

  @override
  String get serviceCity => 'सेवा शहर';

  @override
  String get verificationRequired => 'सत्यापन ज़रूरी है';

  @override
  String get idCard => 'आईडी कार्ड';

  @override
  String get cNavHome => 'होम';

  @override
  String get cNavOrders => 'ऑर्डर';

  @override
  String get cNavTrips => 'ट्रिप्स';

  @override
  String get cNavEarnings => 'कमाई';

  @override
  String get cNavProfile => 'प्रोफ़ाइल';

  @override
  String get cBack => 'पीछे जाएं';

  @override
  String get cContinue => 'आगे बढ़ें';

  @override
  String get cSaving => 'सुरक्षित हो रहा है...';

  @override
  String get cChange => 'बदलें';

  @override
  String get cBrand => 'डिजी कैप्टन';

  @override
  String get cComingSoon => 'जल्द आ रहा है';

  @override
  String get cComingSoonTag => 'जल्द आ रहा है';

  @override
  String get cRideRequest => 'राइड अनुरोध';

  @override
  String get cParcelDelivery => 'पार्सल डिलीवरी';

  @override
  String get cStoreDelivery => 'स्टोर डिलीवरी';

  @override
  String get cRide => 'राइड';

  @override
  String get cDelivery => 'डिलीवरी';

  @override
  String get cPickup => 'पिकअप';

  @override
  String get cDrop => 'ड्रॉप';

  @override
  String get cDistance => 'दूरी';

  @override
  String get cDeliverBy => 'डिलीवरी समय';

  @override
  String get cYouEarn => 'आपकी कमाई';

  @override
  String get cPrepaid => 'प्रीपेड';

  @override
  String get cCash => 'नकद';

  @override
  String cCodCollect(String amount) {
    return 'सीओडी · ₹$amount लें';
  }

  @override
  String cCodShort(String amount) {
    return 'सीओडी (₹$amount)';
  }

  @override
  String get cToday => 'आज';

  @override
  String get cCustomer => 'ग्राहक';

  @override
  String get cGoodMorning => 'सुप्रभात';

  @override
  String get cGoodAfternoon => 'नमस्कार';

  @override
  String get cGoodEvening => 'शुभ संध्या';

  @override
  String get cOnline => 'ऑनलाइन';

  @override
  String get cOffline => 'ऑफलाइन';

  @override
  String get cTodaysEarnings => 'आज की कमाई';

  @override
  String cTripsGoal(String trips, String goal) {
    return '$trips ट्रिप्स · लक्ष्य ₹$goal';
  }

  @override
  String get cOfflineTitle => 'आप ऑफलाइन हैं';

  @override
  String cOfflineDesc(String city) {
    return '$city में राइड्स और डिलीवरी प्राप्त करने के लिए ऑनलाइन जाएं।';
  }

  @override
  String get cGoOnline => 'ऑनलाइन जाएं';

  @override
  String get cAllCaughtUp => 'कोई नया ऑर्डर नहीं';

  @override
  String cAllCaughtUpDesc(String city) {
    return '$city में ग्राहकों के नए ऑर्डर बुक होते ही यहां तुरंत दिखाई देंगे।';
  }

  @override
  String get cBrowseOrders => 'उपलब्ध व छूटे हुए ऑर्डर देखें';

  @override
  String get cSkip => 'छोड़ें';

  @override
  String get cSlideToAccept => 'स्वीकार करने के लिए स्लाइड करें';

  @override
  String get cSkippedToast => 'छोड़ा गया · ऑर्डर में देखें';

  @override
  String get cExpiredToast => 'अनुरोध समाप्त · ऑर्डर में देखें';

  @override
  String get cNowOnline => 'आप अब ऑनलाइन हैं';

  @override
  String get cNowOffline => 'आप अब ऑफलाइन हैं';

  @override
  String get cHeadingToPickup => 'पिकअप के लिए जा रहे हैं';

  @override
  String get cHeadingToStore => 'स्टोर की ओर जा रहे हैं';

  @override
  String get cRideInProgress => 'राइड जारी है';

  @override
  String get cOnTheWay => 'ग्राहक की ओर जा रहे हैं';

  @override
  String get cOpenTrip => 'ट्रिप खोलें';

  @override
  String get cAskRideOtp => 'ग्राहक से राइड ओटीपी पूछें';

  @override
  String get cAskParcelOtp => 'भेजने वाले से पिकअप ओटीपी पूछें';

  @override
  String get cAskDeliveryOtp => 'प्राप्तकर्ता से डिलीवरी ओटीपी पूछें';

  @override
  String get cVerifyStartRide => 'सत्यापित करें और राइड शुरू करें';

  @override
  String get cVerifyStartDelivery => 'सत्यापित करें और डिलीवरी शुरू करें';

  @override
  String get cVerifyCompleteDelivery => 'सत्यापित करें और डिलीवरी पूरी करें';

  @override
  String cConfirmCompleteDelivery(String amount) {
    return '₹$amount की पुष्टि करें और डिलीवरी पूरी करें';
  }

  @override
  String get cSlideEndRide => 'राइड समाप्त करने के लिए स्लाइड करें';

  @override
  String get cSlideToDeliver => 'डिलीवर करने के लिए स्लाइड करें';

  @override
  String get cSlidePickedUp => 'पिकअप की पुष्टि के लिए स्लाइड करें';

  @override
  String get cEnter4DigitOtp => 'कृपया 4 अंकों का ओटीपी दर्ज करें';

  @override
  String get cVerifyCodeHint =>
      'ग्राहक द्वारा दिया गया 4 अंकों का कोड सत्यापित करें';

  @override
  String cCollectCash(String amount) {
    return '₹$amount नकद लें';
  }

  @override
  String get cCodOrder => 'कैश ऑन डिलीवरी ऑर्डर';

  @override
  String get cPrepaidNoCash => 'प्रीपेड ऑर्डर · ग्राहक से नकद न लें';

  @override
  String cCollectCashFrom(String amount) {
    return 'ग्राहक से ₹$amount नकद लें';
  }

  @override
  String cCashCollectedCheck(String amount) {
    return '✓ ₹$amount नकद प्राप्त';
  }

  @override
  String get cTapWhenCash => 'नकद मिलने के बाद यहां टैप करें';

  @override
  String get cCashConfirmed => 'प्राप्तकर्ता से नकद प्राप्ति की पुष्टि हुई';

  @override
  String cConfirmCashFirst(String amount) {
    return 'डिलीवरी पूरी करने से पहले ₹$amount नकद प्राप्ति की पुष्टि करें';
  }

  @override
  String get cEmergencyAssistance => 'आपातकालीन सहायता';

  @override
  String get cSafetySos => 'सुरक्षा और SOS';

  @override
  String get cSosDesc =>
      'केवल वास्तविक आपात स्थिति में उपयोग करें। आप आपातकालीन सेवाओं को कॉल कर सकते हैं या अपनी लाइव लोकेशन साझा कर सकते हैं।';

  @override
  String get cCall112 => '112 पर आपातकालीन कॉल करें';

  @override
  String get cShareLocation => 'लाइव ट्रिप लोकेशन साझा करें';

  @override
  String cEmergencyShareText(String link) {
    return 'डिजी कैप्टन राइडर का आपातकालीन संदेश। मेरी लोकेशन: $link';
  }

  @override
  String get cTripComplete => 'ट्रिप पूर्ण';

  @override
  String get cDeliveryEarning => 'डिलीवरी कमाई';

  @override
  String get cCustomerCashInHand => 'ग्राहक से मिला नकद';

  @override
  String cRateCustomer(String name) {
    return '$name को रेटिंग दें';
  }

  @override
  String get cCashCollectedDone => 'नकद प्राप्त · पूर्ण';

  @override
  String get cPaidViaQr => 'ग्राहक आपका क्यूआर स्कैन करके भुगतान कर सकते हैं';

  @override
  String get cOrdersTitle => 'सभी ऑर्डर';

  @override
  String get cOrdersSubtitle =>
      'हर ऑर्डर 24 घंटे तक खुला रहता है। जो स्वीकार नहीं किया, उसे भी ले सकते हैं।';

  @override
  String get cOpen => 'उपलब्ध';

  @override
  String get cMissed => 'छूटे हुए';

  @override
  String get cExpired => 'समाप्त';

  @override
  String get cAll => 'सभी';

  @override
  String get cRides => 'राइड्स';

  @override
  String get cParcels => 'पार्सल';

  @override
  String get cStoreFilter => 'स्टोर';

  @override
  String cNoOpenOrders(String city) {
    return '$city में इस समय कोई नया ऑर्डर नहीं है';
  }

  @override
  String get cNothingMissed =>
      'कुछ नहीं छूटा। छोड़े गए या समय-सीमा पार अनुरोध यहां दिखेंगे।';

  @override
  String get cNoExpired => 'इस अवधि में कोई समाप्त ऑर्डर नहीं।';

  @override
  String get cRemovedAfter24h =>
      'ऑर्डर पोस्ट होने के 24 घंटे बाद हटा दिए जाते हैं।';

  @override
  String cTimeLeft(String time) {
    return '$time शेष';
  }

  @override
  String get cOrderRetention => 'ऑर्डर अवधि:';

  @override
  String cExpiresIn(String time) {
    return '$time में समाप्त';
  }

  @override
  String get cPassed24h => 'यह ऑर्डर 24 घंटे की वैधता पार कर चुका है।';

  @override
  String get cFinishTripFirst =>
      'दूसरा अनुरोध स्वीकार करने से पहले अपनी चालू ट्रिप पूरी करें।';

  @override
  String cCodBanner(String amount) {
    return 'कैश ऑन डिलीवरी · ₹$amount लें';
  }

  @override
  String cCollectAtDoor(String amount) {
    return 'ग्राहक से दरवाज़े पर ₹$amount नकद लें';
  }

  @override
  String get cTripsTitle => 'आपकी ट्रिप्स';

  @override
  String get cDeliveries => 'डिलीवरी';

  @override
  String get cEarningsTab => 'कमाई';

  @override
  String get cWalletTab => 'वॉलेट';

  @override
  String get cBonusTab => 'बोनस';

  @override
  String get cYourDay => 'आज की कमाई';

  @override
  String get cYourWeek => 'इस सप्ताह की कमाई';

  @override
  String get cYourMonth => 'इस महीने की कमाई';

  @override
  String get cRange7D => '7 दिन';

  @override
  String get cRange30D => '30 दिन';

  @override
  String cTripsCount(String count) {
    return '$count ट्रिप्स';
  }

  @override
  String get cTripsToday => 'आज पूरी की गई ट्रिप्स';

  @override
  String get cTrips7d => 'पिछले 7 दिनों में पूरी की गई ट्रिप्स';

  @override
  String get cTrips30d => 'पिछले 30 दिनों में पूरी की गई ट्रिप्स';

  @override
  String get cSlotMorning => 'सुबह (6-11)';

  @override
  String get cSlotNoon => 'दोपहर (11-2)';

  @override
  String get cSlotAfternoon => 'तीसरा पहर (2-5)';

  @override
  String get cSlotEvening => 'शाम (5-9)';

  @override
  String get cSlotNight => 'रात (9-12)';

  @override
  String get cDays => 'रवि,सोम,मंगल,बुध,गुरु,शुक्र,शनि';

  @override
  String get c30dAgo => '30 दिन पहले';

  @override
  String get c15d => '15 दिन';

  @override
  String get cGotanRides => 'गोतान राइड्स';

  @override
  String get cGotanParcels => 'गोतान पार्सल';

  @override
  String get cDigistallStore => 'डिजिस्टॉल स्टोर ऑर्डर';

  @override
  String get cPrepaidEarnings => 'प्रीपेड कमाई';

  @override
  String get cWithdrawToUpi => 'बैंक / UPI में निकालें';

  @override
  String get cWithdrawSoon =>
      'निकासी जल्द आ रही है। अभी ग्राहक सीधे आपको भुगतान करते हैं।';

  @override
  String get cCashInHand => 'हाथ में नकद';

  @override
  String get cCashInHandSub => 'नकद ट्रिप्स से सीधे ली गई राशि';

  @override
  String get cRecentActivity => 'हालिया लेन-देन';

  @override
  String get cNoTransactions => 'अभी तक कोई लेन-देन नहीं हुआ';

  @override
  String cTripActivity(String id, String kind) {
    return 'ट्रिप #$id · $kind';
  }

  @override
  String get cPeakHours => 'पीक आवर्स · शाम 6–9 बजे';

  @override
  String get cPeakHoursSub => 'हर पूर्ण ट्रिप पर +₹30 अतिरिक्त';

  @override
  String get cDailyTarget => 'आज 10 ट्रिप्स पूरी करें';

  @override
  String get cWeeklyTarget => 'इस सप्ताह 50 ट्रिप्स पूरी करें';

  @override
  String get cClaim => 'प्राप्त करें';

  @override
  String get cInProgress => 'प्रगति पर है';

  @override
  String cTripsProgress(String current, String target) {
    return '$current / $target ट्रिप्स';
  }

  @override
  String get cReferCaptain => 'कैप्टन को रेफ़र करें';

  @override
  String get cBonusSoon => 'बोनस भुगतान जल्द आ रहा है।';

  @override
  String get cCaptainPass => 'कैप्टन पास';

  @override
  String get cVerified => 'सत्यापित';

  @override
  String get cUnderReview => 'समीक्षा जारी';

  @override
  String get cVehicle => 'वाहन';

  @override
  String get cCity => 'शहर';

  @override
  String get cRating => 'रेटिंग';

  @override
  String get cAcceptance => 'स्वीकृति';

  @override
  String get cTrips => 'ट्रिप्स';

  @override
  String get cLanguageLabel => 'भाषा / Language';

  @override
  String get cServiceCityK => 'सेवा शहर';

  @override
  String get cVehicleTypeK => 'वाहन प्रकार';

  @override
  String get cNotifications => 'सूचनाएं';

  @override
  String get cDarkTheme => 'डार्क थीम';

  @override
  String get cDocuments => 'दस्तावेज़';

  @override
  String get cAlerts => 'अलर्ट्स';

  @override
  String get cReferEarn => 'रेफ़र करें और कमाएं';

  @override
  String get cHelpSupport => 'सहायता एवं सपोर्ट';

  @override
  String get cDeleteAccount => 'खाता हटाएं';

  @override
  String get couldNotOpenLink => 'लिंक नहीं खुल सका।';

  @override
  String get cLogOut => 'लॉग आउट';

  @override
  String get cServiceArea => 'सेवा क्षेत्र';

  @override
  String get cChooseCity => 'अपना शहर चुनें';

  @override
  String get cServiceAreaNote =>
      'आपको इस शहर से राइड्स, पार्सल डिलीवरी और स्टोर ऑर्डर प्राप्त होंगे।';

  @override
  String get cRajasthan => 'राजस्थान';

  @override
  String get cYourVehicle => 'आपका वाहन';

  @override
  String get cChooseVehicle => 'अपना वाहन चुनें';

  @override
  String get cVehicleNote => 'राइड अनुरोध इसी वाहन प्रकार से मिलाए जाते हैं।';

  @override
  String cCityToast(String city) {
    return 'सेवा शहर: $city';
  }

  @override
  String get cAadhaar => 'आधार कार्ड';

  @override
  String get cLicence => 'ड्राइविंग लाइसेंस';

  @override
  String get cPaymentQr => 'भुगतान क्यूआर कोड';

  @override
  String get cProfilePhoto => 'प्रोफ़ाइल फ़ोटो';

  @override
  String get cUploadedVerified => 'अपलोड व सत्यापित';

  @override
  String get cUploadedActive => 'अपलोड व सक्रिय';

  @override
  String get cNotUploaded => 'अपलोड नहीं';

  @override
  String get cViewDocument => 'दस्तावेज़ देखें ↗';

  @override
  String get cStoredSecurely => 'DigiStall पर सुरक्षित';

  @override
  String get cUploadDocUpdate => 'दस्तावेज़ अपडेट अपलोड करें';

  @override
  String get cDownloadIdCard => 'आईडी कार्ड डाउनलोड करें';

  @override
  String get cMarkAllRead => 'सभी पढ़े गए';

  @override
  String cNewAlerts(String count) {
    return '$count नए';
  }

  @override
  String get cLiveAlerts => 'लाइव अलर्ट';

  @override
  String get cNoAlerts => 'कोई अलर्ट नहीं';

  @override
  String get cNoAlertsDesc =>
      'लाइव ऑर्डर अलर्ट, ट्रिप अपडेट और सिस्टम सूचनाएं यहां तुरंत दिखेंगी।';

  @override
  String get cActiveTripAlert => 'चालू ट्रिप जारी है';

  @override
  String cOrdersAvailable(String count) {
    return '$count ऑर्डर उपलब्ध';
  }

  @override
  String cOrdersAvailableDesc(String city) {
    return '$city में नए लाइव अनुरोध उपलब्ध। स्वीकार करने के लिए टैप करें।';
  }

  @override
  String get cLiveNow => 'अभी लाइव';

  @override
  String get cCockpitOnline => 'कॉकपिट ऑनलाइन';

  @override
  String cCockpitOnlineDesc(String city) {
    return '$city में राइड्स और डिलीवरी स्वीकार करने के लिए तैयार।';
  }

  @override
  String get cCockpitOffline => 'कॉकपिट ऑफलाइन';

  @override
  String get cCockpitOfflineDesc =>
      'बुकिंग पाने के लिए होम स्क्रीन से ऑनलाइन करें।';

  @override
  String get cActive => 'सक्रिय';

  @override
  String get cPaused => 'रुका हुआ';

  @override
  String get cBadgeOngoing => 'जारी';

  @override
  String get cBadgeNew => 'नया';

  @override
  String get cBadgeRead => 'पढ़ा';

  @override
  String get cBadgeAlert => 'अलर्ट';

  @override
  String get cJustNow => 'अभी-अभी';

  @override
  String cMinutesAgo(String n) {
    return '$n मिनट पहले';
  }

  @override
  String cHoursAgo(String n) {
    return '$n घंटे पहले';
  }

  @override
  String cDaysAgo(String n) {
    return '$n दिन पहले';
  }

  @override
  String get cReferSoonTitle => 'रेफ़रल प्रोग्राम जल्द आ रहा है';

  @override
  String get cReferSoonDesc =>
      'हम डिजी कैप्टन के लिए रेफ़रल प्रोग्राम बना रहे हैं। जल्द ही आप साथी राइडर्स को आमंत्रित करके बोनस कमा सकेंगे।';

  @override
  String get cNotifyMe => 'लाइव होने पर सूचित करें';

  @override
  String get cNotifyMeToast => 'रेफ़रल प्रोग्राम शुरू होते ही हम आपको बताएंगे!';

  @override
  String get cReferStep1 => 'कैप्टन को आमंत्रित करें';

  @override
  String get cReferStep1Desc =>
      'अपना इनवाइट लिंक साथी राइडर्स के साथ साझा करें';

  @override
  String get cReferStep2 => 'वे ड्राइव करना शुरू करते हैं';

  @override
  String get cReferStep2Desc =>
      'आपके रेफ़रल जुड़कर अपनी पहली ट्रिप्स पूरी करते हैं';

  @override
  String get cReferStep3 => 'इनाम कमाएं';

  @override
  String get cReferStep3Desc => 'आपके ज़रिए जुड़ने वाले हर कैप्टन पर बोनस';

  @override
  String get cFaq1Q => 'ग्राहक ने ओटीपी नहीं बताया';

  @override
  String get cFaq1A =>
      'ग्राहक से उनका गोतान या डिजिस्टॉल ऐप खोलने को कहें। 4 अंकों का ओटीपी उनकी लाइव ऑर्डर स्क्रीन पर दिखता है। ओटीपी डाले बिना ट्रिप शुरू न करें।';

  @override
  String get cFaq2Q => 'मैं एक साथ कितने ऑर्डर ले सकता हूं?';

  @override
  String get cFaq2A =>
      'आप एक साथ अधिकतम 2 चालू ऑर्डर ले सकते हैं। दूसरा लेने से पहले एक पूरा करें।';

  @override
  String get cFaq3Q => 'मुझे भुगतान कैसे मिलता है?';

  @override
  String get cFaq3A =>
      'ग्राहक आपको सीधे नकद में या आपका भुगतान क्यूआर स्कैन करके भुगतान करते हैं। आपकी पूरी ट्रिप्स और कमाई कमाई टैब में दिखती है।';

  @override
  String get cFaq4Q => 'ट्रिप के दौरान मैं असुरक्षित महसूस कर रहा हूं';

  @override
  String get cFaq4A =>
      'अपनी चालू ट्रिप स्क्रीन पर लाल SOS बटन दबाएं। आप 112 पर कॉल कर सकते हैं या अपनी लाइव लोकेशन साझा कर सकते हैं।';

  @override
  String get cHeroPre => 'अपनी ';

  @override
  String get cHeroEm => 'शर्तों';

  @override
  String get cHeroPost => ' पर चलाइए।';

  @override
  String get cHeroSub =>
      'ऑटो, बाइक या कार — अपने आस-पास राइड और डिलीवरी से रोज़ ₹1,000 तक कमाएं।';

  @override
  String get cStartEarning => 'कमाना शुरू करें';

  @override
  String get cLogIn => 'लॉग इन';

  @override
  String get cNewRequest => 'नया अनुरोध';

  @override
  String get cDailyPotential => 'दैनिक कमाई क्षमता';

  @override
  String get cVehicleTypes => 'वाहन प्रकार';

  @override
  String get cServiceCities => 'सेवा वाले शहर';

  @override
  String get cWelcomeBackCaptain => 'डिजी कैप्टन में स्वागत है।';

  @override
  String get cLoginDesc =>
      'अपने कैप्टन कॉकपिट, लाइव ऑर्डर और कमाई देखने के लिए लॉगिन करें।';

  @override
  String get cSignInWithGoogle => 'गूगल के साथ लॉगिन करें';

  @override
  String get cSigningIn => 'लॉगिन हो रहा है...';

  @override
  String get cNewHere => 'क्या कैप्टन खाता नहीं है?';

  @override
  String get cSignUpToDrive => 'ड्राइव करने के लिए साइन अप करें';

  @override
  String get cSecuredVia => 'DigiStall Firebase Auth द्वारा सुरक्षित';

  @override
  String cStepOf(String current, String total) {
    return 'चरण $current/$total';
  }

  @override
  String cStepSub(String current, String total, String label) {
    return 'चरण $current/$total · $label';
  }

  @override
  String get cIdentity => 'पहचान';

  @override
  String get cDigitalId => 'कैप्टन आईडी';

  @override
  String get cBasicInfo => 'बुनियादी जानकारी';

  @override
  String get cVerificationLbl => 'सत्यापन';

  @override
  String get cSignUpDesc =>
      'डिजी कैप्टन नेटवर्क से जुड़ें। गूगल से साइन अप करके सत्यापित हों और राइड व डिलीवरी लेना शुरू करें।';

  @override
  String get cSignUpWithGoogle => 'गूगल के साथ साइन अप करें';

  @override
  String get cConnectingGoogle => 'गूगल कनेक्ट हो रहा है...';

  @override
  String get cAlreadyRegistered =>
      'क्या पहले से कैप्टन के रूप में पंजीकृत हैं?';

  @override
  String get cLoginHere => 'यहाँ लॉगिन करें';

  @override
  String get cCaptainDomain => 'कैप्टन डोमेन';

  @override
  String get cTellUsAboutYou => 'अपनी जानकारी भरें';

  @override
  String get cFullName => 'पूरा नाम';

  @override
  String get cNamePlaceholder => 'उदा. आपका नाम';

  @override
  String get cMobileNumber => 'मोबाइल नंबर';

  @override
  String get cGoogleEmail => 'कनेक्टेड गूगल ईमेल';

  @override
  String get cUploadDocsTitle => 'दस्तावेज़ अपलोड करें';

  @override
  String get cUploadDocsDesc =>
      'अपना ड्राइविंग लाइसेंस और भुगतान क्यूआर कोड अपलोड करें। आधार और प्रोफ़ाइल फ़ोटो वैकल्पिक हैं।';

  @override
  String get cRequiredTag => 'आवश्यक';

  @override
  String get cOptionalTag => 'वैकल्पिक';

  @override
  String get cUploadedTag => 'अपलोड हो गया';

  @override
  String get cUploadBtn => 'अपलोड करें';

  @override
  String get cAadhaarDesc => 'आगे और पीछे की फ़ोटो';

  @override
  String get cLicenceDesc => 'मान्य ड्राइविंग लाइसेंस';

  @override
  String get cQrDesc => 'ग्राहक भुगतान के लिए UPI क्यूआर';

  @override
  String get cPhotoDesc => 'साफ़ पासपोर्ट आकार की फ़ोटो';

  @override
  String get cSubmitForReview => 'समीक्षा के लिए भेजें';

  @override
  String get cSplashPre => 'आपकी ';

  @override
  String get cSplashEm => 'अगली';

  @override
  String get cSplashPost => ' राइड खोज रहे हैं।';

  @override
  String get cSplash1 => 'ऑनलाइन हो रहे हैं';

  @override
  String get cSplash2 => 'आस-पास के अनुरोध खोज रहे हैं';

  @override
  String get cSplash3 => 'आपका वाहन मिला रहे हैं';

  @override
  String get cViewRoute => 'रूट देखें';

  @override
  String get cTripDetails => 'ट्रिप विवरण';

  @override
  String get cNoRating => '—';
}

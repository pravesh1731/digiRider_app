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
  String logoutFailed(String error) {
    return 'Logout failed: $error';
  }

  @override
  String get bike => 'Bike';

  @override
  String get auto => 'Auto';

  @override
  String get car => 'Car';

  @override
  String get allowNotification => 'Allow Notifications';

  @override
  String get terms => 'Terms & Conditions';

  @override
  String get cityUpdated => 'City updated successfully';

  @override
  String get cityUpdateFailed => 'Failed to update city';

  @override
  String get history => 'History';

  @override
  String get appName => 'Digital Rider';

  @override
  String get somethingWentWrong => 'Something went wrong.';

  @override
  String get unknown => 'Unknown';

  @override
  String get notAvailable => 'Not available';

  @override
  String get invalidDate => 'Invalid date';

  @override
  String get deliveryTimeNotSet => 'Delivery time not set';

  @override
  String get invalidDeliveryTime => 'Invalid delivery time';

  @override
  String get nothingHereYet => 'Nothing here yet';

  @override
  String get loading => 'Loading...';

  @override
  String get exitApp => 'Exit App';

  @override
  String get exitPrompt => 'Are you sure you want to exit?';

  @override
  String get exit => 'Exit';

  @override
  String get notificationPermissionTitle => 'Notification Permission Needed';

  @override
  String get notificationPermissionMessage =>
      'We use notifications to alert you about new orders. Please enable permission.';

  @override
  String get riderOrders => 'Ride Orders';

  @override
  String get parcelOrders => 'Parcel Orders';

  @override
  String get digistallOrders => 'Digistall Orders';

  @override
  String get statusEnRoute => 'En Route';

  @override
  String get statusInTransit => 'In Transit';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusLabel => 'STATUS';

  @override
  String get pickup => 'PICKUP';

  @override
  String get drop => 'DROP';

  @override
  String get pickupNA => 'Pickup N/A';

  @override
  String get dropNA => 'Drop N/A';

  @override
  String get cartValue => 'CART VALUE';

  @override
  String get tripDistance => 'TRIP DISTANCE';

  @override
  String get distanceNA => 'Distance N/A';

  @override
  String get total => 'TOTAL';

  @override
  String commissionAmount(String amount) {
    return 'Commission: ₹$amount';
  }

  @override
  String totalAmountValue(String amount) {
    return 'Total: ₹$amount';
  }

  @override
  String get viewMap => 'VIEW MAP';

  @override
  String get accept => 'ACCEPT';

  @override
  String get couldNotOpenMaps => 'Could not open Maps.';

  @override
  String deliveryBy(String time) {
    return 'Delivery By - $time';
  }

  @override
  String get finishCurrentRidesFirst =>
      'You need to finish your current rides first';

  @override
  String get orderAccepted => 'Order Accepted Successfully';

  @override
  String get acceptFailed => 'Failed to accept order. Please try again.';

  @override
  String get incomingBookings => 'Incoming Bookings';

  @override
  String vehicleTypeLabel(String vehicle) {
    return 'Vehicle Type: $vehicle';
  }

  @override
  String ordersCount(int count) {
    return '$count orders';
  }

  @override
  String get newOrdersHint =>
      'New requests in your city will appear here automatically.';

  @override
  String orderNumber(String id) {
    return 'Order #$id';
  }

  @override
  String productLabel(String name) {
    return 'Product - $name';
  }

  @override
  String quantityLabel(String quantity) {
    return 'Quantity - $quantity';
  }

  @override
  String get name => 'Name';

  @override
  String get contact => 'Contact';

  @override
  String get progress => 'PROGRESS';

  @override
  String get viewDetails => 'VIEW DETAILS';

  @override
  String get home => 'My Orders';

  @override
  String get gettingLocation => 'Getting current location...';

  @override
  String get locationDenied => 'Location permission denied';

  @override
  String get locationDeniedForever => 'Location permission permanently denied';

  @override
  String get unableToGetLocation => 'Unable to get location';

  @override
  String get currentLocationFound => 'Current location found';

  @override
  String locationCoordinates(String lat, String lng) {
    return 'Location coordinates: $lat, $lng';
  }

  @override
  String get actionFailed => 'Action failed. Please try again.';

  @override
  String get tripStarted => 'Trip Started Successfully.';

  @override
  String get tripCompletedSuccess => 'Trip Completed Successfully.';

  @override
  String get enterCustomerOtp => 'Enter Customer OTP here';

  @override
  String get enterDeliveryOtp => 'Enter Delivery OTP from customer';

  @override
  String get pleaseEnterCustomerOtp => 'Please enter the customer OTP.';

  @override
  String get pleaseEnterDeliveryOtp => 'Please enter the Delivery OTP.';

  @override
  String get startTrip => 'Start the Trip';

  @override
  String get completeTrip => 'Complete the Trip';

  @override
  String get tripCompleted => 'Trip Completed';

  @override
  String get tripDetails => 'Trip Details';

  @override
  String get tripInProgress => 'Trip In Progress';

  @override
  String get customerPhoneMissing => 'Customer phone number is missing.';

  @override
  String get couldNotLaunchDialer => 'Could not launch phone dialer.';

  @override
  String get callCustomer => 'Call Customer';

  @override
  String get navigateToPickup => 'Navigate to Pickup';

  @override
  String get navigateToDestination => 'Navigate to Destination';

  @override
  String get pickupAddressMissing => 'Pickup address is missing.';

  @override
  String get destinationAddressMissing => 'Destination address is missing.';

  @override
  String get orderId => 'Order ID';

  @override
  String get phoneNo => 'Phone No.';

  @override
  String get distance => 'Distance';

  @override
  String get vehicleType => 'Vehicle Type';

  @override
  String get numberOfPassengers => 'Number of Passengers';

  @override
  String get parcelMessage => 'Parcel Message';

  @override
  String get parcelWeight => 'Parcel Weight';

  @override
  String get nil => 'Nil';

  @override
  String get totalValue => 'Total Value';

  @override
  String get deliverBy => 'Deliver By';

  @override
  String get pickupTime => 'Pickup Time';

  @override
  String get yourLocation => 'YOUR LOCATION';

  @override
  String get tripCompletedTitle => 'Trip Completed!';

  @override
  String get pickupLocation => 'Pickup Location';

  @override
  String get destination => 'Destination';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get cartValueLabel => 'Cart Value';

  @override
  String get scanToPay => 'Scan to Pay';

  @override
  String invoiceDownloaded(String path) {
    return 'Invoice downloaded: $path';
  }

  @override
  String invoiceDownloadFailed(String error) {
    return 'Failed to download invoice: $error';
  }

  @override
  String get downloadInvoice => 'Download Invoice';

  @override
  String get done => 'Done';

  @override
  String get selectVehicle => 'Select Vehicle';

  @override
  String vehicleUpdated(String vehicle) {
    return 'Vehicle updated to $vehicle';
  }

  @override
  String get notificationsOn => 'Notifications turned on';

  @override
  String get notificationsOff => 'Notifications turned off';

  @override
  String get notificationsBlocked =>
      'Notifications are blocked. Please allow them in your phone settings.';

  @override
  String get testNotification => 'Send Test Notification';

  @override
  String get testNotificationSent => 'Test notification sent!';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get earnings => 'Earnings';

  @override
  String get totalEarnings => 'Total Earnings';

  @override
  String get earningsBreakdown => 'Earnings Breakdown';

  @override
  String completedDeliveries(int count) {
    return '$count completed deliveries';
  }

  @override
  String completedRidesCount(int count) {
    return '$count completed rides';
  }

  @override
  String deliveredParcelsCount(int count) {
    return '$count delivered parcels';
  }

  @override
  String deliveredOrdersCount(int count) {
    return '$count delivered orders';
  }

  @override
  String get couldNotLoadEarnings =>
      'Could not load earnings. Pull down to try again.';

  @override
  String get signUp => 'Sign Up';

  @override
  String get login => 'Login';

  @override
  String get signIn => 'Sign in';

  @override
  String get welcomeToDigitalRider => 'Welcome to Digital Rider';

  @override
  String get whereDoWeGetOrders => 'Where Do We Get Orders';

  @override
  String get onboardingProcess => 'Onboarding Process';

  @override
  String get benefitsTitle => 'Benefits of Being a Digital Rider';

  @override
  String get aboutUs => 'About Us';

  @override
  String get aboutUsText =>
      'We empower businesses by connecting them with reliable riders for seamless order fulfillment and delivery.';

  @override
  String get earnPerDay => 'Earn 1000 per day';

  @override
  String get earnPerDayDesc => 'Daily earning potential with reliable orders.';

  @override
  String get driveAnyVehicle => 'Drive Any Vehicle';

  @override
  String get driveAnyVehicleDesc =>
      'Auto, Bike, Car, or Taxi — earn with what you have.';

  @override
  String get threeStepOnboarding => '3-Step Onboarding';

  @override
  String get threeStepOnboardingDesc =>
      'Start earning quickly with our fast onboarding.';

  @override
  String get basicInfo => 'Basic Info';

  @override
  String get basicInfoDesc =>
      'Provide your basic information including name, contact details, and address.';

  @override
  String get documents => 'Documents';

  @override
  String get documentsDesc =>
      'Upload Aadhar, Driving License, Payment QR and Profile Image.';

  @override
  String get verification => 'Verification';

  @override
  String get verificationDesc =>
      'We’ll notify you once your documents are verified. Physical card is given.';

  @override
  String get flexibleSchedule => 'Flexible Schedule';

  @override
  String get flexibleScheduleDesc => 'Freedom to choose your working hours.';

  @override
  String get competitiveEarnings => 'Competitive Earnings';

  @override
  String get competitiveEarningsDesc =>
      'Earn more with bonuses and incentives.';

  @override
  String get regularOrders => 'Regular Orders';

  @override
  String get regularOrdersDesc => 'Consistent income from steady orders.';

  @override
  String get supportiveCommunity => 'Supportive Community';

  @override
  String get supportiveCommunityDesc => 'Rider support system always ready.';

  @override
  String get training => 'Training and Development';

  @override
  String get trainingDesc => 'Improve your skills and stay updated.';

  @override
  String get healthSafety => 'Health and Safety';

  @override
  String get healthSafetyDesc => 'We prioritize your health and safety.';

  @override
  String get newsletter => 'Newsletter';

  @override
  String get ordersFromGotanStore => 'Orders from Gotan Store app';

  @override
  String get pickDropPerson => 'Pick and Drop Person';

  @override
  String get pickDropParcel => 'Pick and Drop Parcel';

  @override
  String get ordersFromDigistall => 'Orders from Digistall';

  @override
  String get deliverDigistallOrders =>
      'Deliver Digistall Store Order and Earn commission';

  @override
  String get alreadyHaveAccountSignIn =>
      'You already have an account. Please sign in.';

  @override
  String get loginSuccessWelcome => 'Login successful! Welcome back.';

  @override
  String get uploadDocumentsToContinue =>
      'Please upload your documents to continue.';

  @override
  String get noAccountSignUp => 'You don\'t have an account. Please sign up.';

  @override
  String get googleSignInFailed => 'Google sign-in failed.';

  @override
  String get loginToAccount => 'Log in to your account';

  @override
  String get createNewAccount => 'Create a new account';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get createNewAccountQuestion => 'Create a new account?';

  @override
  String get alreadyHaveAccountQuestion => 'Already have an account?';

  @override
  String get agreeTerms =>
      'By logging in you agree to our Terms and Conditions';

  @override
  String get enterSubdomainError => 'Please enter a subdomain';

  @override
  String get domainTaken => 'This domain is already taken.';

  @override
  String get createDigitalIdentity => 'Create your digital identity';

  @override
  String get continueNextStep => 'Continue to next step';

  @override
  String get domainInfo =>
      'This domain will become part of your digital identity and help identify you uniquely.';

  @override
  String get enterSubdomain => 'Enter subdomain';

  @override
  String get fillAllDetails => 'Please fill in all the details properly.';

  @override
  String get selectCityAndVehicle => 'Please select your city and vehicle type';

  @override
  String get accountCreated => 'Account created successfully';

  @override
  String get submitFailed => 'Failed to submit. Try again.';

  @override
  String get enterYourDetails => 'Enter your details';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get infoSafe =>
      'Your information is safe and will be used only to provide service.';

  @override
  String get uploadRequiredDocuments =>
      'Please upload your licence and payment QR code.';

  @override
  String get loginSuccessful => 'Login successful!';

  @override
  String get uploadFailed => 'Failed to upload documents';

  @override
  String get errorTryAgain => 'An error occurred. Please try again.';

  @override
  String uploadedFile(String name) {
    return 'Uploaded: $name';
  }

  @override
  String get uploadYourDocuments => 'Upload your documents';

  @override
  String get uploadLicense => 'Upload licence';

  @override
  String get uploadQrCode => 'Upload payment QR code';

  @override
  String get uploadAadhaar => 'Upload Aadhaar (optional)';

  @override
  String get uploadProfilePhoto => 'Upload profile photo (optional)';

  @override
  String get upload => 'Upload';

  @override
  String get documentsHint =>
      'All documents must be clear and readable. Upload only JPG, PNG, or PDF files.';

  @override
  String get or => 'or';

  @override
  String get orderAlreadyTaken =>
      'This order was already accepted by another rider.';

  @override
  String get goodMorning => 'Good morning,';

  @override
  String get goodAfternoon => 'Good afternoon,';

  @override
  String get goodEvening => 'Good evening,';

  @override
  String get navRequests => 'Requests';

  @override
  String get profile => 'Profile';

  @override
  String get timeLabel => 'Time';

  @override
  String get earnLabel => 'Earn';

  @override
  String get earnedLabel => 'Earned';

  @override
  String get storeLocation => 'Store location';

  @override
  String get noActiveRequests => 'No active requests';

  @override
  String get noActiveOrders => 'No active orders';

  @override
  String get noActiveOrdersDesc =>
      'Accept an order from Requests to see it here.';

  @override
  String get noHistory => 'No history found';

  @override
  String get getStartedNow => 'Get Started Now';

  @override
  String get heroLine1 => 'Drive, Deliver,';

  @override
  String get heroLine2 => 'Earn Daily.';

  @override
  String get loginSubtitle => 'Welcome back to DigiStall Rider';

  @override
  String get signupSubtitle => 'Join DigiStall as a Rider today';

  @override
  String get serviceCity => 'Service city';

  @override
  String get verificationRequired => 'Verification required';

  @override
  String get idCard => 'ID Card';

  @override
  String get cNavHome => 'Home';

  @override
  String get cNavOrders => 'Orders';

  @override
  String get cNavTrips => 'Trips';

  @override
  String get cNavEarnings => 'Earnings';

  @override
  String get cNavProfile => 'Profile';

  @override
  String get cBack => 'Back';

  @override
  String get cContinue => 'Continue';

  @override
  String get cSaving => 'Saving...';

  @override
  String get cChange => 'Change';

  @override
  String get cBrand => 'Digi Captain';

  @override
  String get cComingSoon => 'Coming soon';

  @override
  String get cComingSoonTag => 'COMING SOON';

  @override
  String get cRideRequest => 'Ride request';

  @override
  String get cParcelDelivery => 'Parcel delivery';

  @override
  String get cStoreDelivery => 'Store delivery';

  @override
  String get cRide => 'Ride';

  @override
  String get cDelivery => 'Delivery';

  @override
  String get cPickup => 'Pickup';

  @override
  String get cDrop => 'Drop';

  @override
  String get cDistance => 'Distance';

  @override
  String get cDeliverBy => 'Deliver by';

  @override
  String get cYouEarn => 'You earn';

  @override
  String get cPrepaid => 'Prepaid';

  @override
  String get cCash => 'Cash';

  @override
  String cCodCollect(String amount) {
    return 'COD · Collect ₹$amount';
  }

  @override
  String cCodShort(String amount) {
    return 'COD (₹$amount)';
  }

  @override
  String get cToday => 'Today';

  @override
  String get cCustomer => 'Customer';

  @override
  String get cGoodMorning => 'Good morning';

  @override
  String get cGoodAfternoon => 'Good afternoon';

  @override
  String get cGoodEvening => 'Good evening';

  @override
  String get cOnline => 'Online';

  @override
  String get cOffline => 'Offline';

  @override
  String get cTodaysEarnings => 'Today\'s earnings';

  @override
  String cTripsGoal(String trips, String goal) {
    return '$trips trips · goal ₹$goal';
  }

  @override
  String get cOfflineTitle => 'You\'re offline';

  @override
  String cOfflineDesc(String city) {
    return 'Go online to receive rides and deliveries in $city.';
  }

  @override
  String get cGoOnline => 'Go online';

  @override
  String get cAllCaughtUp => 'All caught up';

  @override
  String cAllCaughtUpDesc(String city) {
    return 'New requests in $city will appear here as soon as customers book.';
  }

  @override
  String get cBrowseOrders => 'Browse open & missed orders';

  @override
  String get cSkip => 'Skip';

  @override
  String get cSlideToAccept => 'Slide to accept';

  @override
  String get cSkippedToast => 'Skipped · find it in Orders';

  @override
  String get cExpiredToast => 'Request expired · find it in Orders';

  @override
  String get cNowOnline => 'You are now online';

  @override
  String get cNowOffline => 'You are now offline';

  @override
  String get cHeadingToPickup => 'Heading to pickup';

  @override
  String get cHeadingToStore => 'Heading to store';

  @override
  String get cRideInProgress => 'Ride in progress';

  @override
  String get cOnTheWay => 'On the way to customer';

  @override
  String get cOpenTrip => 'Open trip';

  @override
  String get cAskRideOtp => 'Ask the customer for their ride OTP';

  @override
  String get cAskParcelOtp => 'Ask the sender for the pickup OTP';

  @override
  String get cAskDeliveryOtp => 'Ask recipient for delivery OTP';

  @override
  String get cVerifyStartRide => 'Verify & start ride';

  @override
  String get cVerifyStartDelivery => 'Verify & start delivery';

  @override
  String get cVerifyCompleteDelivery => 'Verify & complete delivery';

  @override
  String cConfirmCompleteDelivery(String amount) {
    return 'Confirm ₹$amount & complete delivery';
  }

  @override
  String get cSlideEndRide => 'Slide to end ride';

  @override
  String get cSlideToDeliver => 'Slide to deliver';

  @override
  String get cSlidePickedUp => 'Slide when picked up';

  @override
  String get cEnter4DigitOtp => 'Please enter 4-digit OTP';

  @override
  String get cVerifyCodeHint => 'Verify 4-digit code provided by customer';

  @override
  String cCollectCash(String amount) {
    return 'Collect ₹$amount in cash';
  }

  @override
  String get cCodOrder => 'Cash on delivery order';

  @override
  String get cPrepaidNoCash =>
      'Prepaid order · Do not collect cash from customer';

  @override
  String cCollectCashFrom(String amount) {
    return 'Collect ₹$amount cash from customer';
  }

  @override
  String cCashCollectedCheck(String amount) {
    return '✓ ₹$amount cash collected';
  }

  @override
  String get cTapWhenCash => 'Tap here once cash is received in hand';

  @override
  String get cCashConfirmed => 'Confirmed received cash from recipient';

  @override
  String cConfirmCashFirst(String amount) {
    return 'Please confirm cash collection of ₹$amount before completing delivery';
  }

  @override
  String get cEmergencyAssistance => 'Emergency assistance';

  @override
  String get cSafetySos => 'Safety & SOS';

  @override
  String get cSosDesc =>
      'Use only during a genuine emergency. You can call emergency services or share your live trip location.';

  @override
  String get cCall112 => 'Call emergency 112';

  @override
  String get cShareLocation => 'Share live trip location';

  @override
  String cEmergencyShareText(String link) {
    return 'Emergency alert from a Digi Captain rider. My location: $link';
  }

  @override
  String get cTripComplete => 'Trip complete';

  @override
  String get cDeliveryEarning => 'Delivery earning';

  @override
  String get cCustomerCashInHand => 'Customer cash in hand';

  @override
  String cRateCustomer(String name) {
    return 'Rate $name';
  }

  @override
  String get cCashCollectedDone => 'Cash collected · Done';

  @override
  String get cPaidViaQr => 'Customer can pay by scanning your QR';

  @override
  String get cOrdersTitle => 'All orders';

  @override
  String get cOrdersSubtitle =>
      'Every order stays open for 24 hours. Take any you haven\'t accepted, including ones you missed.';

  @override
  String get cOpen => 'Open';

  @override
  String get cMissed => 'Missed';

  @override
  String get cExpired => 'Expired';

  @override
  String get cAll => 'All';

  @override
  String get cRides => 'Rides';

  @override
  String get cParcels => 'Parcels';

  @override
  String get cStoreFilter => 'Store';

  @override
  String cNoOpenOrders(String city) {
    return 'No open orders right now in $city';
  }

  @override
  String get cNothingMissed =>
      'Nothing missed. Skipped or timed-out requests land here.';

  @override
  String get cNoExpired => 'No expired orders in this period.';

  @override
  String get cRemovedAfter24h =>
      'Orders are removed 24 hours after they\'re posted.';

  @override
  String cTimeLeft(String time) {
    return '$time left';
  }

  @override
  String get cOrderRetention => 'Order retention:';

  @override
  String cExpiresIn(String time) {
    return 'Expires in $time';
  }

  @override
  String get cPassed24h => 'This order has passed its 24-hour validity window.';

  @override
  String get cFinishTripFirst =>
      'Please complete your ongoing trips before accepting another request.';

  @override
  String cCodBanner(String amount) {
    return 'Cash on delivery · Collect ₹$amount';
  }

  @override
  String cCollectAtDoor(String amount) {
    return 'Collect ₹$amount cash from customer at doorstep';
  }

  @override
  String get cTripsTitle => 'Your trips';

  @override
  String get cDeliveries => 'Deliveries';

  @override
  String get cEarningsTab => 'Earnings';

  @override
  String get cWalletTab => 'Wallet';

  @override
  String get cBonusTab => 'Bonus';

  @override
  String get cYourDay => 'Your day';

  @override
  String get cYourWeek => 'Your week';

  @override
  String get cYourMonth => 'Your month';

  @override
  String get cRange7D => '7D';

  @override
  String get cRange30D => '30D';

  @override
  String cTripsCount(String count) {
    return '$count trips';
  }

  @override
  String get cTripsToday => 'trips completed today';

  @override
  String get cTrips7d => 'trips completed in last 7 days';

  @override
  String get cTrips30d => 'trips completed in last 30 days';

  @override
  String get cSlotMorning => '6-11 AM';

  @override
  String get cSlotNoon => '11-2 PM';

  @override
  String get cSlotAfternoon => '2-5 PM';

  @override
  String get cSlotEvening => '5-9 PM';

  @override
  String get cSlotNight => '9-12 AM';

  @override
  String get cDays => 'Sun,Mon,Tue,Wed,Thu,Fri,Sat';

  @override
  String get c30dAgo => '30d ago';

  @override
  String get c15d => '15d';

  @override
  String get cGotanRides => 'Gotan rides';

  @override
  String get cGotanParcels => 'Gotan parcels';

  @override
  String get cDigistallStore => 'DigiStall orders';

  @override
  String get cPrepaidEarnings => 'Prepaid earnings';

  @override
  String get cWithdrawToUpi => 'Withdraw to UPI / Bank';

  @override
  String get cWithdrawSoon =>
      'Withdrawals are coming soon. Customers pay you directly for now.';

  @override
  String get cCashInHand => 'Cash in hand';

  @override
  String get cCashInHandSub => 'Collected directly from cash trips';

  @override
  String get cRecentActivity => 'Recent activity';

  @override
  String get cNoTransactions => 'No completed transactions yet';

  @override
  String cTripActivity(String id, String kind) {
    return 'Trip #$id · $kind';
  }

  @override
  String get cPeakHours => 'Peak hours · 6–9 PM';

  @override
  String get cPeakHoursSub => '+₹30 extra on every completed trip';

  @override
  String get cDailyTarget => 'Complete 10 trips today';

  @override
  String get cWeeklyTarget => '50 trips this week';

  @override
  String get cClaim => 'Claim';

  @override
  String get cInProgress => 'In progress';

  @override
  String cTripsProgress(String current, String target) {
    return '$current / $target trips';
  }

  @override
  String get cReferCaptain => 'Refer a captain';

  @override
  String get cBonusSoon => 'Bonus payouts are coming soon.';

  @override
  String get cCaptainPass => 'Captain pass';

  @override
  String get cVerified => 'Verified';

  @override
  String get cUnderReview => 'Under review';

  @override
  String get cVehicle => 'Vehicle';

  @override
  String get cCity => 'City';

  @override
  String get cRating => 'Rating';

  @override
  String get cAcceptance => 'Acceptance';

  @override
  String get cTrips => 'Trips';

  @override
  String get cLanguageLabel => 'Language / भाषा';

  @override
  String get cServiceCityK => 'Service city';

  @override
  String get cVehicleTypeK => 'Vehicle type';

  @override
  String get cNotifications => 'Notifications';

  @override
  String get cDarkTheme => 'Dark theme';

  @override
  String get cDocuments => 'Documents';

  @override
  String get cAlerts => 'Alerts';

  @override
  String get cReferEarn => 'Refer & earn';

  @override
  String get cHelpSupport => 'Help & support';

  @override
  String get cDeleteAccount => 'Delete account';

  @override
  String get couldNotOpenLink => 'Could not open the link.';

  @override
  String get cLogOut => 'Log out';

  @override
  String get cServiceArea => 'Service area';

  @override
  String get cChooseCity => 'Choose your city';

  @override
  String get cServiceAreaNote =>
      'You will receive rides, parcel deliveries, and store orders from this city.';

  @override
  String get cRajasthan => 'Rajasthan';

  @override
  String get cYourVehicle => 'Your vehicle';

  @override
  String get cChooseVehicle => 'Choose your vehicle';

  @override
  String get cVehicleNote => 'Ride requests are matched to this vehicle type.';

  @override
  String cCityToast(String city) {
    return 'Service city: $city';
  }

  @override
  String get cAadhaar => 'Aadhaar card';

  @override
  String get cLicence => 'Driving licence';

  @override
  String get cPaymentQr => 'Payment QR code';

  @override
  String get cProfilePhoto => 'Profile photo';

  @override
  String get cUploadedVerified => 'Uploaded & verified';

  @override
  String get cUploadedActive => 'Uploaded & active';

  @override
  String get cNotUploaded => 'Not uploaded';

  @override
  String get cViewDocument => 'View document ↗';

  @override
  String get cStoredSecurely => 'Stored securely on DigiStall';

  @override
  String get cUploadDocUpdate => 'Upload document update';

  @override
  String get cDownloadIdCard => 'Download ID card';

  @override
  String get cMarkAllRead => 'Mark all read';

  @override
  String cNewAlerts(String count) {
    return '$count NEW';
  }

  @override
  String get cLiveAlerts => 'LIVE ALERTS';

  @override
  String get cNoAlerts => 'No alerts';

  @override
  String get cNoAlertsDesc =>
      'Live order alerts, trip updates, and system notices will appear here in real time.';

  @override
  String get cActiveTripAlert => 'Active trip in progress';

  @override
  String cOrdersAvailable(String count) {
    return '$count orders available';
  }

  @override
  String cOrdersAvailableDesc(String city) {
    return 'New live requests available in $city. Tap to accept.';
  }

  @override
  String get cLiveNow => 'Live now';

  @override
  String get cCockpitOnline => 'Cockpit online';

  @override
  String cCockpitOnlineDesc(String city) {
    return 'Ready to accept rides and deliveries in $city.';
  }

  @override
  String get cCockpitOffline => 'Cockpit offline';

  @override
  String get cCockpitOfflineDesc =>
      'Turn online from the home screen to start receiving bookings.';

  @override
  String get cActive => 'Active';

  @override
  String get cPaused => 'Paused';

  @override
  String get cBadgeOngoing => 'ONGOING';

  @override
  String get cBadgeNew => 'NEW';

  @override
  String get cBadgeRead => 'READ';

  @override
  String get cBadgeAlert => 'ALERT';

  @override
  String get cJustNow => 'Just now';

  @override
  String cMinutesAgo(String n) {
    return '${n}m ago';
  }

  @override
  String cHoursAgo(String n) {
    return '${n}h ago';
  }

  @override
  String cDaysAgo(String n) {
    return '${n}d ago';
  }

  @override
  String get cReferSoonTitle => 'Referral program coming soon';

  @override
  String get cReferSoonDesc =>
      'We are building a referral rewards program for Digi Captains. Soon you will be able to invite fellow riders and drivers and earn bonuses.';

  @override
  String get cNotifyMe => 'Notify me when live';

  @override
  String get cNotifyMeToast =>
      'We\'ll let you know when the referral program launches!';

  @override
  String get cReferStep1 => 'Invite captains';

  @override
  String get cReferStep1Desc =>
      'Share your personal invite link with fellow riders';

  @override
  String get cReferStep2 => 'They start driving';

  @override
  String get cReferStep2Desc =>
      'Your referrals onboard and complete their first trips';

  @override
  String get cReferStep3 => 'Earn rewards';

  @override
  String get cReferStep3Desc =>
      'A bonus for every captain who joins through you';

  @override
  String get cFaq1Q => 'The customer did not share the OTP';

  @override
  String get cFaq1A =>
      'Ask the customer to open their Gotan or DigiStall app. The 4-digit OTP is shown on their live order screen. Never start a trip without entering it.';

  @override
  String get cFaq2Q => 'How many orders can I take at once?';

  @override
  String get cFaq2A =>
      'You can hold up to 2 active orders. Finish one before you accept another.';

  @override
  String get cFaq3Q => 'How do I get paid?';

  @override
  String get cFaq3A =>
      'Customers pay you directly in cash or by scanning your payment QR code. Your completed trips and earnings are in the Earnings tab.';

  @override
  String get cFaq4Q => 'I feel unsafe on a trip';

  @override
  String get cFaq4A =>
      'Tap the red SOS button on your active trip screen. You can call 112 or share your live location.';

  @override
  String get cHeroPre => 'Drive on ';

  @override
  String get cHeroEm => 'your';

  @override
  String get cHeroPost => ' terms.';

  @override
  String get cHeroSub =>
      'Auto, bike or car — earn up to ₹1,000 a day with rides and deliveries near you.';

  @override
  String get cStartEarning => 'Start earning';

  @override
  String get cLogIn => 'Log in';

  @override
  String get cNewRequest => 'New request';

  @override
  String get cDailyPotential => 'Daily potential';

  @override
  String get cVehicleTypes => 'Vehicle types';

  @override
  String get cServiceCities => 'Service cities';

  @override
  String get cWelcomeBackCaptain => 'Welcome back, Captain.';

  @override
  String get cLoginDesc =>
      'Sign in to access your Captain cockpit, live orders, and earnings.';

  @override
  String get cSignInWithGoogle => 'Sign in with Google';

  @override
  String get cSigningIn => 'Signing in...';

  @override
  String get cNewHere => 'Don\'t have a Captain account?';

  @override
  String get cSignUpToDrive => 'Sign up to drive';

  @override
  String get cSecuredVia => 'Secured via DigiStall Firebase Auth';

  @override
  String cStepOf(String current, String total) {
    return 'Step $current of $total';
  }

  @override
  String cStepSub(String current, String total, String label) {
    return 'Step $current of $total · $label';
  }

  @override
  String get cIdentity => 'Identity';

  @override
  String get cDigitalId => 'Captain ID';

  @override
  String get cBasicInfo => 'Basic info';

  @override
  String get cVerificationLbl => 'Verification';

  @override
  String get cSignUpDesc =>
      'Join the Digi Captain network. Sign up with your Google account to get verified and start taking rides and deliveries.';

  @override
  String get cSignUpWithGoogle => 'Sign up with Google';

  @override
  String get cConnectingGoogle => 'Connecting Google...';

  @override
  String get cAlreadyRegistered => 'Already registered as a Captain?';

  @override
  String get cLoginHere => 'Log in here';

  @override
  String get cCaptainDomain => 'Captain domain';

  @override
  String get cTellUsAboutYou => 'Tell us about you';

  @override
  String get cFullName => 'Full name';

  @override
  String get cNamePlaceholder => 'e.g. Captain Name';

  @override
  String get cMobileNumber => 'Mobile number';

  @override
  String get cGoogleEmail => 'Connected Google email';

  @override
  String get cUploadDocsTitle => 'Upload documents';

  @override
  String get cUploadDocsDesc =>
      'Upload your driving licence and payment QR code. Aadhaar and profile photo are optional.';

  @override
  String get cRequiredTag => 'REQUIRED';

  @override
  String get cOptionalTag => 'OPTIONAL';

  @override
  String get cUploadedTag => 'UPLOADED';

  @override
  String get cUploadBtn => 'Upload';

  @override
  String get cAadhaarDesc => 'Front & back photo';

  @override
  String get cLicenceDesc => 'Valid private/commercial DL';

  @override
  String get cQrDesc => 'UPI QR for customer payments';

  @override
  String get cPhotoDesc => 'Clear passport-style photo';

  @override
  String get cSubmitForReview => 'Submit for review';

  @override
  String get cSplashPre => 'Finding your ';

  @override
  String get cSplashEm => 'next';

  @override
  String get cSplashPost => ' ride.';

  @override
  String get cSplash1 => 'Going online';

  @override
  String get cSplash2 => 'Scanning for requests near you';

  @override
  String get cSplash3 => 'Matching your vehicle';

  @override
  String get cViewRoute => 'View route';

  @override
  String get cTripDetails => 'Trip details';

  @override
  String get cNoRating => '—';
}

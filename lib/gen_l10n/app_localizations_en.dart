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
}

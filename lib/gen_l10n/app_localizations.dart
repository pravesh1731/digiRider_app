import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to DigiRider!'**
  String get welcome;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @qrCode.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qrCode;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCode;

  /// No description provided for @qrShareProfile.
  ///
  /// In en, this message translates to:
  /// **'Use this QR code to quickly share your profile'**
  String get qrShareProfile;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get preparing;

  /// No description provided for @downloadCard.
  ///
  /// In en, this message translates to:
  /// **'Download Card'**
  String get downloadCard;

  /// No description provided for @gotan.
  ///
  /// In en, this message translates to:
  /// **'Gotan'**
  String get gotan;

  /// No description provided for @jodhpur.
  ///
  /// In en, this message translates to:
  /// **'Jodhpur'**
  String get jodhpur;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get selectCity;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM LOGOUT'**
  String get confirmLogout;

  /// No description provided for @logoutPrompt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutPrompt;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed: {error}'**
  String logoutFailed(String error);

  /// No description provided for @bike.
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get bike;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @car.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get car;

  /// No description provided for @allowNotification.
  ///
  /// In en, this message translates to:
  /// **'Allow Notifications'**
  String get allowNotification;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get terms;

  /// No description provided for @cityUpdated.
  ///
  /// In en, this message translates to:
  /// **'City updated successfully'**
  String get cityUpdated;

  /// No description provided for @cityUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update city'**
  String get cityUpdateFailed;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Digital Rider'**
  String get appName;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @invalidDate.
  ///
  /// In en, this message translates to:
  /// **'Invalid date'**
  String get invalidDate;

  /// No description provided for @deliveryTimeNotSet.
  ///
  /// In en, this message translates to:
  /// **'Delivery time not set'**
  String get deliveryTimeNotSet;

  /// No description provided for @invalidDeliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Invalid delivery time'**
  String get invalidDeliveryTime;

  /// No description provided for @nothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingHereYet;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exitApp;

  /// No description provided for @exitPrompt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit?'**
  String get exitPrompt;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission Needed'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'We use notifications to alert you about new orders. Please enable permission.'**
  String get notificationPermissionMessage;

  /// No description provided for @riderOrders.
  ///
  /// In en, this message translates to:
  /// **'Ride Orders'**
  String get riderOrders;

  /// No description provided for @parcelOrders.
  ///
  /// In en, this message translates to:
  /// **'Parcel Orders'**
  String get parcelOrders;

  /// No description provided for @digistallOrders.
  ///
  /// In en, this message translates to:
  /// **'Digistall Orders'**
  String get digistallOrders;

  /// No description provided for @statusEnRoute.
  ///
  /// In en, this message translates to:
  /// **'En Route'**
  String get statusEnRoute;

  /// No description provided for @statusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get statusInTransit;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get statusLabel;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'PICKUP'**
  String get pickup;

  /// No description provided for @drop.
  ///
  /// In en, this message translates to:
  /// **'DROP'**
  String get drop;

  /// No description provided for @pickupNA.
  ///
  /// In en, this message translates to:
  /// **'Pickup N/A'**
  String get pickupNA;

  /// No description provided for @dropNA.
  ///
  /// In en, this message translates to:
  /// **'Drop N/A'**
  String get dropNA;

  /// No description provided for @cartValue.
  ///
  /// In en, this message translates to:
  /// **'CART VALUE'**
  String get cartValue;

  /// No description provided for @tripDistance.
  ///
  /// In en, this message translates to:
  /// **'TRIP DISTANCE'**
  String get tripDistance;

  /// No description provided for @distanceNA.
  ///
  /// In en, this message translates to:
  /// **'Distance N/A'**
  String get distanceNA;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get total;

  /// No description provided for @commissionAmount.
  ///
  /// In en, this message translates to:
  /// **'Commission: ₹{amount}'**
  String commissionAmount(String amount);

  /// No description provided for @totalAmountValue.
  ///
  /// In en, this message translates to:
  /// **'Total: ₹{amount}'**
  String totalAmountValue(String amount);

  /// No description provided for @viewMap.
  ///
  /// In en, this message translates to:
  /// **'VIEW MAP'**
  String get viewMap;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'ACCEPT'**
  String get accept;

  /// No description provided for @couldNotOpenMaps.
  ///
  /// In en, this message translates to:
  /// **'Could not open Maps.'**
  String get couldNotOpenMaps;

  /// No description provided for @deliveryBy.
  ///
  /// In en, this message translates to:
  /// **'Delivery By - {time}'**
  String deliveryBy(String time);

  /// No description provided for @finishCurrentRidesFirst.
  ///
  /// In en, this message translates to:
  /// **'You need to finish your current rides first'**
  String get finishCurrentRidesFirst;

  /// No description provided for @orderAccepted.
  ///
  /// In en, this message translates to:
  /// **'Order Accepted Successfully'**
  String get orderAccepted;

  /// No description provided for @acceptFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to accept order. Please try again.'**
  String get acceptFailed;

  /// No description provided for @incomingBookings.
  ///
  /// In en, this message translates to:
  /// **'Incoming Bookings'**
  String get incomingBookings;

  /// No description provided for @vehicleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type: {vehicle}'**
  String vehicleTypeLabel(String vehicle);

  /// No description provided for @ordersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} orders'**
  String ordersCount(int count);

  /// No description provided for @newOrdersHint.
  ///
  /// In en, this message translates to:
  /// **'New requests in your city will appear here automatically.'**
  String get newOrdersHint;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderNumber(String id);

  /// No description provided for @productLabel.
  ///
  /// In en, this message translates to:
  /// **'Product - {name}'**
  String productLabel(String name);

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity - {quantity}'**
  String quantityLabel(String quantity);

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'PROGRESS'**
  String get progress;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'VIEW DETAILS'**
  String get viewDetails;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get home;

  /// No description provided for @gettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting current location...'**
  String get gettingLocation;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationDenied;

  /// No description provided for @locationDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied'**
  String get locationDeniedForever;

  /// No description provided for @unableToGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to get location'**
  String get unableToGetLocation;

  /// No description provided for @currentLocationFound.
  ///
  /// In en, this message translates to:
  /// **'Current location found'**
  String get currentLocationFound;

  /// No description provided for @locationCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Location coordinates: {lat}, {lng}'**
  String locationCoordinates(String lat, String lng);

  /// No description provided for @actionFailed.
  ///
  /// In en, this message translates to:
  /// **'Action failed. Please try again.'**
  String get actionFailed;

  /// No description provided for @tripStarted.
  ///
  /// In en, this message translates to:
  /// **'Trip Started Successfully.'**
  String get tripStarted;

  /// No description provided for @tripCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Trip Completed Successfully.'**
  String get tripCompletedSuccess;

  /// No description provided for @enterCustomerOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter Customer OTP here'**
  String get enterCustomerOtp;

  /// No description provided for @enterDeliveryOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter Delivery OTP from customer'**
  String get enterDeliveryOtp;

  /// No description provided for @pleaseEnterCustomerOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter the customer OTP.'**
  String get pleaseEnterCustomerOtp;

  /// No description provided for @pleaseEnterDeliveryOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter the Delivery OTP.'**
  String get pleaseEnterDeliveryOtp;

  /// No description provided for @startTrip.
  ///
  /// In en, this message translates to:
  /// **'Start the Trip'**
  String get startTrip;

  /// No description provided for @completeTrip.
  ///
  /// In en, this message translates to:
  /// **'Complete the Trip'**
  String get completeTrip;

  /// No description provided for @tripCompleted.
  ///
  /// In en, this message translates to:
  /// **'Trip Completed'**
  String get tripCompleted;

  /// No description provided for @tripDetails.
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get tripDetails;

  /// No description provided for @tripInProgress.
  ///
  /// In en, this message translates to:
  /// **'Trip In Progress'**
  String get tripInProgress;

  /// No description provided for @customerPhoneMissing.
  ///
  /// In en, this message translates to:
  /// **'Customer phone number is missing.'**
  String get customerPhoneMissing;

  /// No description provided for @couldNotLaunchDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not launch phone dialer.'**
  String get couldNotLaunchDialer;

  /// No description provided for @callCustomer.
  ///
  /// In en, this message translates to:
  /// **'Call Customer'**
  String get callCustomer;

  /// No description provided for @navigateToPickup.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Pickup'**
  String get navigateToPickup;

  /// No description provided for @navigateToDestination.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Destination'**
  String get navigateToDestination;

  /// No description provided for @pickupAddressMissing.
  ///
  /// In en, this message translates to:
  /// **'Pickup address is missing.'**
  String get pickupAddressMissing;

  /// No description provided for @destinationAddressMissing.
  ///
  /// In en, this message translates to:
  /// **'Destination address is missing.'**
  String get destinationAddressMissing;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @phoneNo.
  ///
  /// In en, this message translates to:
  /// **'Phone No.'**
  String get phoneNo;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// No description provided for @numberOfPassengers.
  ///
  /// In en, this message translates to:
  /// **'Number of Passengers'**
  String get numberOfPassengers;

  /// No description provided for @parcelMessage.
  ///
  /// In en, this message translates to:
  /// **'Parcel Message'**
  String get parcelMessage;

  /// No description provided for @parcelWeight.
  ///
  /// In en, this message translates to:
  /// **'Parcel Weight'**
  String get parcelWeight;

  /// No description provided for @nil.
  ///
  /// In en, this message translates to:
  /// **'Nil'**
  String get nil;

  /// No description provided for @totalValue.
  ///
  /// In en, this message translates to:
  /// **'Total Value'**
  String get totalValue;

  /// No description provided for @deliverBy.
  ///
  /// In en, this message translates to:
  /// **'Deliver By'**
  String get deliverBy;

  /// No description provided for @pickupTime.
  ///
  /// In en, this message translates to:
  /// **'Pickup Time'**
  String get pickupTime;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'YOUR LOCATION'**
  String get yourLocation;

  /// No description provided for @tripCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip Completed!'**
  String get tripCompletedTitle;

  /// No description provided for @pickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get pickupLocation;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @cartValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Cart Value'**
  String get cartValueLabel;

  /// No description provided for @scanToPay.
  ///
  /// In en, this message translates to:
  /// **'Scan to Pay'**
  String get scanToPay;

  /// No description provided for @invoiceDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Invoice downloaded: {path}'**
  String invoiceDownloaded(String path);

  /// No description provided for @invoiceDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to download invoice: {error}'**
  String invoiceDownloadFailed(String error);

  /// No description provided for @downloadInvoice.
  ///
  /// In en, this message translates to:
  /// **'Download Invoice'**
  String get downloadInvoice;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @selectVehicle.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle'**
  String get selectVehicle;

  /// No description provided for @vehicleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Vehicle updated to {vehicle}'**
  String vehicleUpdated(String vehicle);

  /// No description provided for @notificationsOn.
  ///
  /// In en, this message translates to:
  /// **'Notifications turned on'**
  String get notificationsOn;

  /// No description provided for @notificationsOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications turned off'**
  String get notificationsOff;

  /// No description provided for @notificationsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked. Please allow them in your phone settings.'**
  String get notificationsBlocked;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Send Test Notification'**
  String get testNotification;

  /// No description provided for @testNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent!'**
  String get testNotificationSent;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @totalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// No description provided for @earningsBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Earnings Breakdown'**
  String get earningsBreakdown;

  /// No description provided for @completedDeliveries.
  ///
  /// In en, this message translates to:
  /// **'{count} completed deliveries'**
  String completedDeliveries(int count);

  /// No description provided for @completedRidesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} completed rides'**
  String completedRidesCount(int count);

  /// No description provided for @deliveredParcelsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} delivered parcels'**
  String deliveredParcelsCount(int count);

  /// No description provided for @deliveredOrdersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} delivered orders'**
  String deliveredOrdersCount(int count);

  /// No description provided for @couldNotLoadEarnings.
  ///
  /// In en, this message translates to:
  /// **'Could not load earnings. Pull down to try again.'**
  String get couldNotLoadEarnings;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @welcomeToDigitalRider.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Digital Rider'**
  String get welcomeToDigitalRider;

  /// No description provided for @whereDoWeGetOrders.
  ///
  /// In en, this message translates to:
  /// **'Where Do We Get Orders'**
  String get whereDoWeGetOrders;

  /// No description provided for @onboardingProcess.
  ///
  /// In en, this message translates to:
  /// **'Onboarding Process'**
  String get onboardingProcess;

  /// No description provided for @benefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Benefits of Being a Digital Rider'**
  String get benefitsTitle;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @aboutUsText.
  ///
  /// In en, this message translates to:
  /// **'We empower businesses by connecting them with reliable riders for seamless order fulfillment and delivery.'**
  String get aboutUsText;

  /// No description provided for @earnPerDay.
  ///
  /// In en, this message translates to:
  /// **'Earn 1000 per day'**
  String get earnPerDay;

  /// No description provided for @earnPerDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Daily earning potential with reliable orders.'**
  String get earnPerDayDesc;

  /// No description provided for @driveAnyVehicle.
  ///
  /// In en, this message translates to:
  /// **'Drive Any Vehicle'**
  String get driveAnyVehicle;

  /// No description provided for @driveAnyVehicleDesc.
  ///
  /// In en, this message translates to:
  /// **'Auto, Bike, Car, or Taxi — earn with what you have.'**
  String get driveAnyVehicleDesc;

  /// No description provided for @threeStepOnboarding.
  ///
  /// In en, this message translates to:
  /// **'3-Step Onboarding'**
  String get threeStepOnboarding;

  /// No description provided for @threeStepOnboardingDesc.
  ///
  /// In en, this message translates to:
  /// **'Start earning quickly with our fast onboarding.'**
  String get threeStepOnboardingDesc;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @basicInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Provide your basic information including name, contact details, and address.'**
  String get basicInfoDesc;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @documentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload Aadhar, Driving License, Payment QR and Profile Image.'**
  String get documentsDesc;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @verificationDesc.
  ///
  /// In en, this message translates to:
  /// **'We’ll notify you once your documents are verified. Physical card is given.'**
  String get verificationDesc;

  /// No description provided for @flexibleSchedule.
  ///
  /// In en, this message translates to:
  /// **'Flexible Schedule'**
  String get flexibleSchedule;

  /// No description provided for @flexibleScheduleDesc.
  ///
  /// In en, this message translates to:
  /// **'Freedom to choose your working hours.'**
  String get flexibleScheduleDesc;

  /// No description provided for @competitiveEarnings.
  ///
  /// In en, this message translates to:
  /// **'Competitive Earnings'**
  String get competitiveEarnings;

  /// No description provided for @competitiveEarningsDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn more with bonuses and incentives.'**
  String get competitiveEarningsDesc;

  /// No description provided for @regularOrders.
  ///
  /// In en, this message translates to:
  /// **'Regular Orders'**
  String get regularOrders;

  /// No description provided for @regularOrdersDesc.
  ///
  /// In en, this message translates to:
  /// **'Consistent income from steady orders.'**
  String get regularOrdersDesc;

  /// No description provided for @supportiveCommunity.
  ///
  /// In en, this message translates to:
  /// **'Supportive Community'**
  String get supportiveCommunity;

  /// No description provided for @supportiveCommunityDesc.
  ///
  /// In en, this message translates to:
  /// **'Rider support system always ready.'**
  String get supportiveCommunityDesc;

  /// No description provided for @training.
  ///
  /// In en, this message translates to:
  /// **'Training and Development'**
  String get training;

  /// No description provided for @trainingDesc.
  ///
  /// In en, this message translates to:
  /// **'Improve your skills and stay updated.'**
  String get trainingDesc;

  /// No description provided for @healthSafety.
  ///
  /// In en, this message translates to:
  /// **'Health and Safety'**
  String get healthSafety;

  /// No description provided for @healthSafetyDesc.
  ///
  /// In en, this message translates to:
  /// **'We prioritize your health and safety.'**
  String get healthSafetyDesc;

  /// No description provided for @newsletter.
  ///
  /// In en, this message translates to:
  /// **'Newsletter'**
  String get newsletter;

  /// No description provided for @ordersFromGotanStore.
  ///
  /// In en, this message translates to:
  /// **'Orders from Gotan Store app'**
  String get ordersFromGotanStore;

  /// No description provided for @pickDropPerson.
  ///
  /// In en, this message translates to:
  /// **'Pick and Drop Person'**
  String get pickDropPerson;

  /// No description provided for @pickDropParcel.
  ///
  /// In en, this message translates to:
  /// **'Pick and Drop Parcel'**
  String get pickDropParcel;

  /// No description provided for @ordersFromDigistall.
  ///
  /// In en, this message translates to:
  /// **'Orders from Digistall'**
  String get ordersFromDigistall;

  /// No description provided for @deliverDigistallOrders.
  ///
  /// In en, this message translates to:
  /// **'Deliver Digistall Store Order and Earn commission'**
  String get deliverDigistallOrders;

  /// No description provided for @alreadyHaveAccountSignIn.
  ///
  /// In en, this message translates to:
  /// **'You already have an account. Please sign in.'**
  String get alreadyHaveAccountSignIn;

  /// No description provided for @loginSuccessWelcome.
  ///
  /// In en, this message translates to:
  /// **'Login successful! Welcome back.'**
  String get loginSuccessWelcome;

  /// No description provided for @uploadDocumentsToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please upload your documents to continue.'**
  String get uploadDocumentsToContinue;

  /// No description provided for @noAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have an account. Please sign up.'**
  String get noAccountSignUp;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed.'**
  String get googleSignInFailed;

  /// No description provided for @loginToAccount.
  ///
  /// In en, this message translates to:
  /// **'Log in to your account'**
  String get loginToAccount;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get createNewAccount;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @createNewAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Create a new account?'**
  String get createNewAccountQuestion;

  /// No description provided for @alreadyHaveAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccountQuestion;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'By logging in you agree to our Terms and Conditions'**
  String get agreeTerms;

  /// No description provided for @enterSubdomainError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a subdomain'**
  String get enterSubdomainError;

  /// No description provided for @domainTaken.
  ///
  /// In en, this message translates to:
  /// **'This domain is already taken.'**
  String get domainTaken;

  /// No description provided for @createDigitalIdentity.
  ///
  /// In en, this message translates to:
  /// **'Create your digital identity'**
  String get createDigitalIdentity;

  /// No description provided for @continueNextStep.
  ///
  /// In en, this message translates to:
  /// **'Continue to next step'**
  String get continueNextStep;

  /// No description provided for @domainInfo.
  ///
  /// In en, this message translates to:
  /// **'This domain will become part of your digital identity and help identify you uniquely.'**
  String get domainInfo;

  /// No description provided for @enterSubdomain.
  ///
  /// In en, this message translates to:
  /// **'Enter subdomain'**
  String get enterSubdomain;

  /// No description provided for @fillAllDetails.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all the details properly.'**
  String get fillAllDetails;

  /// No description provided for @selectCityAndVehicle.
  ///
  /// In en, this message translates to:
  /// **'Please select your city and vehicle type'**
  String get selectCityAndVehicle;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreated;

  /// No description provided for @submitFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit. Try again.'**
  String get submitFailed;

  /// No description provided for @enterYourDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter your details'**
  String get enterYourDetails;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @infoSafe.
  ///
  /// In en, this message translates to:
  /// **'Your information is safe and will be used only to provide service.'**
  String get infoSafe;

  /// No description provided for @uploadRequiredDocuments.
  ///
  /// In en, this message translates to:
  /// **'Please upload your licence and payment QR code.'**
  String get uploadRequiredDocuments;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccessful;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload documents'**
  String get uploadFailed;

  /// No description provided for @errorTryAgain.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorTryAgain;

  /// No description provided for @uploadedFile.
  ///
  /// In en, this message translates to:
  /// **'Uploaded: {name}'**
  String uploadedFile(String name);

  /// No description provided for @uploadYourDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload your documents'**
  String get uploadYourDocuments;

  /// No description provided for @uploadLicense.
  ///
  /// In en, this message translates to:
  /// **'Upload licence'**
  String get uploadLicense;

  /// No description provided for @uploadQrCode.
  ///
  /// In en, this message translates to:
  /// **'Upload payment QR code'**
  String get uploadQrCode;

  /// No description provided for @uploadAadhaar.
  ///
  /// In en, this message translates to:
  /// **'Upload Aadhaar (optional)'**
  String get uploadAadhaar;

  /// No description provided for @uploadProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload profile photo (optional)'**
  String get uploadProfilePhoto;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @documentsHint.
  ///
  /// In en, this message translates to:
  /// **'All documents must be clear and readable. Upload only JPG, PNG, or PDF files.'**
  String get documentsHint;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @orderAlreadyTaken.
  ///
  /// In en, this message translates to:
  /// **'This order was already accepted by another rider.'**
  String get orderAlreadyTaken;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

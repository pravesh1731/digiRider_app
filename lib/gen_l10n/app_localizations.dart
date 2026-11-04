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

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get goodEvening;

  /// No description provided for @navRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get navRequests;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @earnLabel.
  ///
  /// In en, this message translates to:
  /// **'Earn'**
  String get earnLabel;

  /// No description provided for @earnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get earnedLabel;

  /// No description provided for @storeLocation.
  ///
  /// In en, this message translates to:
  /// **'Store location'**
  String get storeLocation;

  /// No description provided for @noActiveRequests.
  ///
  /// In en, this message translates to:
  /// **'No active requests'**
  String get noActiveRequests;

  /// No description provided for @noActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'No active orders'**
  String get noActiveOrders;

  /// No description provided for @noActiveOrdersDesc.
  ///
  /// In en, this message translates to:
  /// **'Accept an order from Requests to see it here.'**
  String get noActiveOrdersDesc;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No history found'**
  String get noHistory;

  /// No description provided for @getStartedNow.
  ///
  /// In en, this message translates to:
  /// **'Get Started Now'**
  String get getStartedNow;

  /// No description provided for @heroLine1.
  ///
  /// In en, this message translates to:
  /// **'Drive, Deliver,'**
  String get heroLine1;

  /// No description provided for @heroLine2.
  ///
  /// In en, this message translates to:
  /// **'Earn Daily.'**
  String get heroLine2;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to DigiStall Rider'**
  String get loginSubtitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join DigiStall as a Rider today'**
  String get signupSubtitle;

  /// No description provided for @serviceCity.
  ///
  /// In en, this message translates to:
  /// **'Service city'**
  String get serviceCity;

  /// No description provided for @verificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification required'**
  String get verificationRequired;

  /// No description provided for @idCard.
  ///
  /// In en, this message translates to:
  /// **'ID Card'**
  String get idCard;

  /// No description provided for @cNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get cNavHome;

  /// No description provided for @cNavOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get cNavOrders;

  /// No description provided for @cNavTrips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get cNavTrips;

  /// No description provided for @cNavEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get cNavEarnings;

  /// No description provided for @cNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get cNavProfile;

  /// No description provided for @cBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get cBack;

  /// No description provided for @cContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get cContinue;

  /// No description provided for @cSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get cSaving;

  /// No description provided for @cChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get cChange;

  /// No description provided for @cBrand.
  ///
  /// In en, this message translates to:
  /// **'Digi Captain'**
  String get cBrand;

  /// No description provided for @cComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get cComingSoon;

  /// No description provided for @cComingSoonTag.
  ///
  /// In en, this message translates to:
  /// **'COMING SOON'**
  String get cComingSoonTag;

  /// No description provided for @cRideRequest.
  ///
  /// In en, this message translates to:
  /// **'Ride request'**
  String get cRideRequest;

  /// No description provided for @cParcelDelivery.
  ///
  /// In en, this message translates to:
  /// **'Parcel delivery'**
  String get cParcelDelivery;

  /// No description provided for @cStoreDelivery.
  ///
  /// In en, this message translates to:
  /// **'Store delivery'**
  String get cStoreDelivery;

  /// No description provided for @cRide.
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get cRide;

  /// No description provided for @cDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get cDelivery;

  /// No description provided for @cPickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get cPickup;

  /// No description provided for @cDrop.
  ///
  /// In en, this message translates to:
  /// **'Drop'**
  String get cDrop;

  /// No description provided for @cDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get cDistance;

  /// No description provided for @cDeliverBy.
  ///
  /// In en, this message translates to:
  /// **'Deliver by'**
  String get cDeliverBy;

  /// No description provided for @cYouEarn.
  ///
  /// In en, this message translates to:
  /// **'You earn'**
  String get cYouEarn;

  /// No description provided for @cPrepaid.
  ///
  /// In en, this message translates to:
  /// **'Prepaid'**
  String get cPrepaid;

  /// No description provided for @cCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cCash;

  /// No description provided for @cCodCollect.
  ///
  /// In en, this message translates to:
  /// **'COD · Collect ₹{amount}'**
  String cCodCollect(String amount);

  /// No description provided for @cCodShort.
  ///
  /// In en, this message translates to:
  /// **'COD (₹{amount})'**
  String cCodShort(String amount);

  /// No description provided for @cToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get cToday;

  /// No description provided for @cCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get cCustomer;

  /// No description provided for @cGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get cGoodMorning;

  /// No description provided for @cGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get cGoodAfternoon;

  /// No description provided for @cGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get cGoodEvening;

  /// No description provided for @cOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get cOnline;

  /// No description provided for @cOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get cOffline;

  /// No description provided for @cTodaysEarnings.
  ///
  /// In en, this message translates to:
  /// **'Today\'s earnings'**
  String get cTodaysEarnings;

  /// No description provided for @cTripsGoal.
  ///
  /// In en, this message translates to:
  /// **'{trips} trips · goal ₹{goal}'**
  String cTripsGoal(String trips, String goal);

  /// No description provided for @cOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get cOfflineTitle;

  /// No description provided for @cOfflineDesc.
  ///
  /// In en, this message translates to:
  /// **'Go online to receive rides and deliveries in {city}.'**
  String cOfflineDesc(String city);

  /// No description provided for @cGoOnline.
  ///
  /// In en, this message translates to:
  /// **'Go online'**
  String get cGoOnline;

  /// No description provided for @cAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get cAllCaughtUp;

  /// No description provided for @cAllCaughtUpDesc.
  ///
  /// In en, this message translates to:
  /// **'New requests in {city} will appear here as soon as customers book.'**
  String cAllCaughtUpDesc(String city);

  /// No description provided for @cBrowseOrders.
  ///
  /// In en, this message translates to:
  /// **'Browse open & missed orders'**
  String get cBrowseOrders;

  /// No description provided for @cSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get cSkip;

  /// No description provided for @cSlideToAccept.
  ///
  /// In en, this message translates to:
  /// **'Slide to accept'**
  String get cSlideToAccept;

  /// No description provided for @cSkippedToast.
  ///
  /// In en, this message translates to:
  /// **'Skipped · find it in Orders'**
  String get cSkippedToast;

  /// No description provided for @cExpiredToast.
  ///
  /// In en, this message translates to:
  /// **'Request expired · find it in Orders'**
  String get cExpiredToast;

  /// No description provided for @cNowOnline.
  ///
  /// In en, this message translates to:
  /// **'You are now online'**
  String get cNowOnline;

  /// No description provided for @cNowOffline.
  ///
  /// In en, this message translates to:
  /// **'You are now offline'**
  String get cNowOffline;

  /// No description provided for @cHeadingToPickup.
  ///
  /// In en, this message translates to:
  /// **'Heading to pickup'**
  String get cHeadingToPickup;

  /// No description provided for @cHeadingToStore.
  ///
  /// In en, this message translates to:
  /// **'Heading to store'**
  String get cHeadingToStore;

  /// No description provided for @cRideInProgress.
  ///
  /// In en, this message translates to:
  /// **'Ride in progress'**
  String get cRideInProgress;

  /// No description provided for @cOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way to customer'**
  String get cOnTheWay;

  /// No description provided for @cOpenTrip.
  ///
  /// In en, this message translates to:
  /// **'Open trip'**
  String get cOpenTrip;

  /// No description provided for @cAskRideOtp.
  ///
  /// In en, this message translates to:
  /// **'Ask the customer for their ride OTP'**
  String get cAskRideOtp;

  /// No description provided for @cAskParcelOtp.
  ///
  /// In en, this message translates to:
  /// **'Ask the sender for the pickup OTP'**
  String get cAskParcelOtp;

  /// No description provided for @cAskDeliveryOtp.
  ///
  /// In en, this message translates to:
  /// **'Ask recipient for delivery OTP'**
  String get cAskDeliveryOtp;

  /// No description provided for @cVerifyStartRide.
  ///
  /// In en, this message translates to:
  /// **'Verify & start ride'**
  String get cVerifyStartRide;

  /// No description provided for @cVerifyStartDelivery.
  ///
  /// In en, this message translates to:
  /// **'Verify & start delivery'**
  String get cVerifyStartDelivery;

  /// No description provided for @cVerifyCompleteDelivery.
  ///
  /// In en, this message translates to:
  /// **'Verify & complete delivery'**
  String get cVerifyCompleteDelivery;

  /// No description provided for @cConfirmCompleteDelivery.
  ///
  /// In en, this message translates to:
  /// **'Confirm ₹{amount} & complete delivery'**
  String cConfirmCompleteDelivery(String amount);

  /// No description provided for @cSlideEndRide.
  ///
  /// In en, this message translates to:
  /// **'Slide to end ride'**
  String get cSlideEndRide;

  /// No description provided for @cSlideToDeliver.
  ///
  /// In en, this message translates to:
  /// **'Slide to deliver'**
  String get cSlideToDeliver;

  /// No description provided for @cSlidePickedUp.
  ///
  /// In en, this message translates to:
  /// **'Slide when picked up'**
  String get cSlidePickedUp;

  /// No description provided for @cEnter4DigitOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter 4-digit OTP'**
  String get cEnter4DigitOtp;

  /// No description provided for @cVerifyCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Verify 4-digit code provided by customer'**
  String get cVerifyCodeHint;

  /// No description provided for @cCollectCash.
  ///
  /// In en, this message translates to:
  /// **'Collect ₹{amount} in cash'**
  String cCollectCash(String amount);

  /// No description provided for @cCodOrder.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery order'**
  String get cCodOrder;

  /// No description provided for @cPrepaidNoCash.
  ///
  /// In en, this message translates to:
  /// **'Prepaid order · Do not collect cash from customer'**
  String get cPrepaidNoCash;

  /// No description provided for @cCollectCashFrom.
  ///
  /// In en, this message translates to:
  /// **'Collect ₹{amount} cash from customer'**
  String cCollectCashFrom(String amount);

  /// No description provided for @cCashCollectedCheck.
  ///
  /// In en, this message translates to:
  /// **'✓ ₹{amount} cash collected'**
  String cCashCollectedCheck(String amount);

  /// No description provided for @cTapWhenCash.
  ///
  /// In en, this message translates to:
  /// **'Tap here once cash is received in hand'**
  String get cTapWhenCash;

  /// No description provided for @cCashConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed received cash from recipient'**
  String get cCashConfirmed;

  /// No description provided for @cConfirmCashFirst.
  ///
  /// In en, this message translates to:
  /// **'Please confirm cash collection of ₹{amount} before completing delivery'**
  String cConfirmCashFirst(String amount);

  /// No description provided for @cEmergencyAssistance.
  ///
  /// In en, this message translates to:
  /// **'Emergency assistance'**
  String get cEmergencyAssistance;

  /// No description provided for @cSafetySos.
  ///
  /// In en, this message translates to:
  /// **'Safety & SOS'**
  String get cSafetySos;

  /// No description provided for @cSosDesc.
  ///
  /// In en, this message translates to:
  /// **'Use only during a genuine emergency. You can call emergency services or share your live trip location.'**
  String get cSosDesc;

  /// No description provided for @cCall112.
  ///
  /// In en, this message translates to:
  /// **'Call emergency 112'**
  String get cCall112;

  /// No description provided for @cShareLocation.
  ///
  /// In en, this message translates to:
  /// **'Share live trip location'**
  String get cShareLocation;

  /// No description provided for @cEmergencyShareText.
  ///
  /// In en, this message translates to:
  /// **'Emergency alert from a Digi Captain rider. My location: {link}'**
  String cEmergencyShareText(String link);

  /// No description provided for @cTripComplete.
  ///
  /// In en, this message translates to:
  /// **'Trip complete'**
  String get cTripComplete;

  /// No description provided for @cDeliveryEarning.
  ///
  /// In en, this message translates to:
  /// **'Delivery earning'**
  String get cDeliveryEarning;

  /// No description provided for @cCustomerCashInHand.
  ///
  /// In en, this message translates to:
  /// **'Customer cash in hand'**
  String get cCustomerCashInHand;

  /// No description provided for @cRateCustomer.
  ///
  /// In en, this message translates to:
  /// **'Rate {name}'**
  String cRateCustomer(String name);

  /// No description provided for @cCashCollectedDone.
  ///
  /// In en, this message translates to:
  /// **'Cash collected · Done'**
  String get cCashCollectedDone;

  /// No description provided for @cPaidViaQr.
  ///
  /// In en, this message translates to:
  /// **'Customer can pay by scanning your QR'**
  String get cPaidViaQr;

  /// No description provided for @cOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'All orders'**
  String get cOrdersTitle;

  /// No description provided for @cOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every order stays open for 24 hours. Take any you haven\'t accepted, including ones you missed.'**
  String get cOrdersSubtitle;

  /// No description provided for @cOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get cOpen;

  /// No description provided for @cMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get cMissed;

  /// No description provided for @cExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get cExpired;

  /// No description provided for @cAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get cAll;

  /// No description provided for @cRides.
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get cRides;

  /// No description provided for @cParcels.
  ///
  /// In en, this message translates to:
  /// **'Parcels'**
  String get cParcels;

  /// No description provided for @cStoreFilter.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get cStoreFilter;

  /// No description provided for @cNoOpenOrders.
  ///
  /// In en, this message translates to:
  /// **'No open orders right now in {city}'**
  String cNoOpenOrders(String city);

  /// No description provided for @cNothingMissed.
  ///
  /// In en, this message translates to:
  /// **'Nothing missed. Skipped or timed-out requests land here.'**
  String get cNothingMissed;

  /// No description provided for @cNoExpired.
  ///
  /// In en, this message translates to:
  /// **'No expired orders in this period.'**
  String get cNoExpired;

  /// No description provided for @cRemovedAfter24h.
  ///
  /// In en, this message translates to:
  /// **'Orders are removed 24 hours after they\'re posted.'**
  String get cRemovedAfter24h;

  /// No description provided for @cTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'{time} left'**
  String cTimeLeft(String time);

  /// No description provided for @cOrderRetention.
  ///
  /// In en, this message translates to:
  /// **'Order retention:'**
  String get cOrderRetention;

  /// No description provided for @cExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Expires in {time}'**
  String cExpiresIn(String time);

  /// No description provided for @cPassed24h.
  ///
  /// In en, this message translates to:
  /// **'This order has passed its 24-hour validity window.'**
  String get cPassed24h;

  /// No description provided for @cFinishTripFirst.
  ///
  /// In en, this message translates to:
  /// **'Please complete your ongoing trips before accepting another request.'**
  String get cFinishTripFirst;

  /// No description provided for @cCodBanner.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery · Collect ₹{amount}'**
  String cCodBanner(String amount);

  /// No description provided for @cCollectAtDoor.
  ///
  /// In en, this message translates to:
  /// **'Collect ₹{amount} cash from customer at doorstep'**
  String cCollectAtDoor(String amount);

  /// No description provided for @cTripsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your trips'**
  String get cTripsTitle;

  /// No description provided for @cDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get cDeliveries;

  /// No description provided for @cEarningsTab.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get cEarningsTab;

  /// No description provided for @cWalletTab.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get cWalletTab;

  /// No description provided for @cBonusTab.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get cBonusTab;

  /// No description provided for @cYourDay.
  ///
  /// In en, this message translates to:
  /// **'Your day'**
  String get cYourDay;

  /// No description provided for @cYourWeek.
  ///
  /// In en, this message translates to:
  /// **'Your week'**
  String get cYourWeek;

  /// No description provided for @cYourMonth.
  ///
  /// In en, this message translates to:
  /// **'Your month'**
  String get cYourMonth;

  /// No description provided for @cRange7D.
  ///
  /// In en, this message translates to:
  /// **'7D'**
  String get cRange7D;

  /// No description provided for @cRange30D.
  ///
  /// In en, this message translates to:
  /// **'30D'**
  String get cRange30D;

  /// No description provided for @cTripsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} trips'**
  String cTripsCount(String count);

  /// No description provided for @cTripsToday.
  ///
  /// In en, this message translates to:
  /// **'trips completed today'**
  String get cTripsToday;

  /// No description provided for @cTrips7d.
  ///
  /// In en, this message translates to:
  /// **'trips completed in last 7 days'**
  String get cTrips7d;

  /// No description provided for @cTrips30d.
  ///
  /// In en, this message translates to:
  /// **'trips completed in last 30 days'**
  String get cTrips30d;

  /// No description provided for @cSlotMorning.
  ///
  /// In en, this message translates to:
  /// **'6-11 AM'**
  String get cSlotMorning;

  /// No description provided for @cSlotNoon.
  ///
  /// In en, this message translates to:
  /// **'11-2 PM'**
  String get cSlotNoon;

  /// No description provided for @cSlotAfternoon.
  ///
  /// In en, this message translates to:
  /// **'2-5 PM'**
  String get cSlotAfternoon;

  /// No description provided for @cSlotEvening.
  ///
  /// In en, this message translates to:
  /// **'5-9 PM'**
  String get cSlotEvening;

  /// No description provided for @cSlotNight.
  ///
  /// In en, this message translates to:
  /// **'9-12 AM'**
  String get cSlotNight;

  /// No description provided for @cDays.
  ///
  /// In en, this message translates to:
  /// **'Sun,Mon,Tue,Wed,Thu,Fri,Sat'**
  String get cDays;

  /// No description provided for @c30dAgo.
  ///
  /// In en, this message translates to:
  /// **'30d ago'**
  String get c30dAgo;

  /// No description provided for @c15d.
  ///
  /// In en, this message translates to:
  /// **'15d'**
  String get c15d;

  /// No description provided for @cGotanRides.
  ///
  /// In en, this message translates to:
  /// **'Gotan rides'**
  String get cGotanRides;

  /// No description provided for @cGotanParcels.
  ///
  /// In en, this message translates to:
  /// **'Gotan parcels'**
  String get cGotanParcels;

  /// No description provided for @cDigistallStore.
  ///
  /// In en, this message translates to:
  /// **'DigiStall orders'**
  String get cDigistallStore;

  /// No description provided for @cPrepaidEarnings.
  ///
  /// In en, this message translates to:
  /// **'Prepaid earnings'**
  String get cPrepaidEarnings;

  /// No description provided for @cWithdrawToUpi.
  ///
  /// In en, this message translates to:
  /// **'Withdraw to UPI / Bank'**
  String get cWithdrawToUpi;

  /// No description provided for @cWithdrawSoon.
  ///
  /// In en, this message translates to:
  /// **'Withdrawals are coming soon. Customers pay you directly for now.'**
  String get cWithdrawSoon;

  /// No description provided for @cCashInHand.
  ///
  /// In en, this message translates to:
  /// **'Cash in hand'**
  String get cCashInHand;

  /// No description provided for @cCashInHandSub.
  ///
  /// In en, this message translates to:
  /// **'Collected directly from cash trips'**
  String get cCashInHandSub;

  /// No description provided for @cRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get cRecentActivity;

  /// No description provided for @cNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No completed transactions yet'**
  String get cNoTransactions;

  /// No description provided for @cTripActivity.
  ///
  /// In en, this message translates to:
  /// **'Trip #{id} · {kind}'**
  String cTripActivity(String id, String kind);

  /// No description provided for @cPeakHours.
  ///
  /// In en, this message translates to:
  /// **'Peak hours · 6–9 PM'**
  String get cPeakHours;

  /// No description provided for @cPeakHoursSub.
  ///
  /// In en, this message translates to:
  /// **'+₹30 extra on every completed trip'**
  String get cPeakHoursSub;

  /// No description provided for @cDailyTarget.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 trips today'**
  String get cDailyTarget;

  /// No description provided for @cWeeklyTarget.
  ///
  /// In en, this message translates to:
  /// **'50 trips this week'**
  String get cWeeklyTarget;

  /// No description provided for @cClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get cClaim;

  /// No description provided for @cInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get cInProgress;

  /// No description provided for @cTripsProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} / {target} trips'**
  String cTripsProgress(String current, String target);

  /// No description provided for @cReferCaptain.
  ///
  /// In en, this message translates to:
  /// **'Refer a captain'**
  String get cReferCaptain;

  /// No description provided for @cBonusSoon.
  ///
  /// In en, this message translates to:
  /// **'Bonus payouts are coming soon.'**
  String get cBonusSoon;

  /// No description provided for @cCaptainPass.
  ///
  /// In en, this message translates to:
  /// **'Captain pass'**
  String get cCaptainPass;

  /// No description provided for @cVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get cVerified;

  /// No description provided for @cUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get cUnderReview;

  /// No description provided for @cVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get cVehicle;

  /// No description provided for @cCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cCity;

  /// No description provided for @cRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get cRating;

  /// No description provided for @cAcceptance.
  ///
  /// In en, this message translates to:
  /// **'Acceptance'**
  String get cAcceptance;

  /// No description provided for @cTrips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get cTrips;

  /// No description provided for @cLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language / भाषा'**
  String get cLanguageLabel;

  /// No description provided for @cServiceCityK.
  ///
  /// In en, this message translates to:
  /// **'Service city'**
  String get cServiceCityK;

  /// No description provided for @cVehicleTypeK.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type'**
  String get cVehicleTypeK;

  /// No description provided for @cNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get cNotifications;

  /// No description provided for @cDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get cDarkTheme;

  /// No description provided for @cDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get cDocuments;

  /// No description provided for @cAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get cAlerts;

  /// No description provided for @cReferEarn.
  ///
  /// In en, this message translates to:
  /// **'Refer & earn'**
  String get cReferEarn;

  /// No description provided for @cHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get cHelpSupport;

  /// No description provided for @cDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get cDeleteAccount;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get couldNotOpenLink;

  /// No description provided for @cLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get cLogOut;

  /// No description provided for @cServiceArea.
  ///
  /// In en, this message translates to:
  /// **'Service area'**
  String get cServiceArea;

  /// No description provided for @cChooseCity.
  ///
  /// In en, this message translates to:
  /// **'Choose your city'**
  String get cChooseCity;

  /// No description provided for @cServiceAreaNote.
  ///
  /// In en, this message translates to:
  /// **'You will receive rides, parcel deliveries, and store orders from this city.'**
  String get cServiceAreaNote;

  /// No description provided for @cRajasthan.
  ///
  /// In en, this message translates to:
  /// **'Rajasthan'**
  String get cRajasthan;

  /// No description provided for @cYourVehicle.
  ///
  /// In en, this message translates to:
  /// **'Your vehicle'**
  String get cYourVehicle;

  /// No description provided for @cChooseVehicle.
  ///
  /// In en, this message translates to:
  /// **'Choose your vehicle'**
  String get cChooseVehicle;

  /// No description provided for @cVehicleNote.
  ///
  /// In en, this message translates to:
  /// **'Ride requests are matched to this vehicle type.'**
  String get cVehicleNote;

  /// No description provided for @cCityToast.
  ///
  /// In en, this message translates to:
  /// **'Service city: {city}'**
  String cCityToast(String city);

  /// No description provided for @cAadhaar.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar card'**
  String get cAadhaar;

  /// No description provided for @cLicence.
  ///
  /// In en, this message translates to:
  /// **'Driving licence'**
  String get cLicence;

  /// No description provided for @cPaymentQr.
  ///
  /// In en, this message translates to:
  /// **'Payment QR code'**
  String get cPaymentQr;

  /// No description provided for @cProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get cProfilePhoto;

  /// No description provided for @cUploadedVerified.
  ///
  /// In en, this message translates to:
  /// **'Uploaded & verified'**
  String get cUploadedVerified;

  /// No description provided for @cUploadedActive.
  ///
  /// In en, this message translates to:
  /// **'Uploaded & active'**
  String get cUploadedActive;

  /// No description provided for @cNotUploaded.
  ///
  /// In en, this message translates to:
  /// **'Not uploaded'**
  String get cNotUploaded;

  /// No description provided for @cViewDocument.
  ///
  /// In en, this message translates to:
  /// **'View document ↗'**
  String get cViewDocument;

  /// No description provided for @cStoredSecurely.
  ///
  /// In en, this message translates to:
  /// **'Stored securely on DigiStall'**
  String get cStoredSecurely;

  /// No description provided for @cUploadDocUpdate.
  ///
  /// In en, this message translates to:
  /// **'Upload document update'**
  String get cUploadDocUpdate;

  /// No description provided for @cDownloadIdCard.
  ///
  /// In en, this message translates to:
  /// **'Download ID card'**
  String get cDownloadIdCard;

  /// No description provided for @cMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get cMarkAllRead;

  /// No description provided for @cNewAlerts.
  ///
  /// In en, this message translates to:
  /// **'{count} NEW'**
  String cNewAlerts(String count);

  /// No description provided for @cLiveAlerts.
  ///
  /// In en, this message translates to:
  /// **'LIVE ALERTS'**
  String get cLiveAlerts;

  /// No description provided for @cNoAlerts.
  ///
  /// In en, this message translates to:
  /// **'No alerts'**
  String get cNoAlerts;

  /// No description provided for @cNoAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Live order alerts, trip updates, and system notices will appear here in real time.'**
  String get cNoAlertsDesc;

  /// No description provided for @cActiveTripAlert.
  ///
  /// In en, this message translates to:
  /// **'Active trip in progress'**
  String get cActiveTripAlert;

  /// No description provided for @cOrdersAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} orders available'**
  String cOrdersAvailable(String count);

  /// No description provided for @cOrdersAvailableDesc.
  ///
  /// In en, this message translates to:
  /// **'New live requests available in {city}. Tap to accept.'**
  String cOrdersAvailableDesc(String city);

  /// No description provided for @cLiveNow.
  ///
  /// In en, this message translates to:
  /// **'Live now'**
  String get cLiveNow;

  /// No description provided for @cCockpitOnline.
  ///
  /// In en, this message translates to:
  /// **'Cockpit online'**
  String get cCockpitOnline;

  /// No description provided for @cCockpitOnlineDesc.
  ///
  /// In en, this message translates to:
  /// **'Ready to accept rides and deliveries in {city}.'**
  String cCockpitOnlineDesc(String city);

  /// No description provided for @cCockpitOffline.
  ///
  /// In en, this message translates to:
  /// **'Cockpit offline'**
  String get cCockpitOffline;

  /// No description provided for @cCockpitOfflineDesc.
  ///
  /// In en, this message translates to:
  /// **'Turn online from the home screen to start receiving bookings.'**
  String get cCockpitOfflineDesc;

  /// No description provided for @cActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get cActive;

  /// No description provided for @cPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get cPaused;

  /// No description provided for @cBadgeOngoing.
  ///
  /// In en, this message translates to:
  /// **'ONGOING'**
  String get cBadgeOngoing;

  /// No description provided for @cBadgeNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get cBadgeNew;

  /// No description provided for @cBadgeRead.
  ///
  /// In en, this message translates to:
  /// **'READ'**
  String get cBadgeRead;

  /// No description provided for @cBadgeAlert.
  ///
  /// In en, this message translates to:
  /// **'ALERT'**
  String get cBadgeAlert;

  /// No description provided for @cJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get cJustNow;

  /// No description provided for @cMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}m ago'**
  String cMinutesAgo(String n);

  /// No description provided for @cHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}h ago'**
  String cHoursAgo(String n);

  /// No description provided for @cDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}d ago'**
  String cDaysAgo(String n);

  /// No description provided for @cReferSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Referral program coming soon'**
  String get cReferSoonTitle;

  /// No description provided for @cReferSoonDesc.
  ///
  /// In en, this message translates to:
  /// **'We are building a referral rewards program for Digi Captains. Soon you will be able to invite fellow riders and drivers and earn bonuses.'**
  String get cReferSoonDesc;

  /// No description provided for @cNotifyMe.
  ///
  /// In en, this message translates to:
  /// **'Notify me when live'**
  String get cNotifyMe;

  /// No description provided for @cNotifyMeToast.
  ///
  /// In en, this message translates to:
  /// **'We\'ll let you know when the referral program launches!'**
  String get cNotifyMeToast;

  /// No description provided for @cReferStep1.
  ///
  /// In en, this message translates to:
  /// **'Invite captains'**
  String get cReferStep1;

  /// No description provided for @cReferStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Share your personal invite link with fellow riders'**
  String get cReferStep1Desc;

  /// No description provided for @cReferStep2.
  ///
  /// In en, this message translates to:
  /// **'They start driving'**
  String get cReferStep2;

  /// No description provided for @cReferStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Your referrals onboard and complete their first trips'**
  String get cReferStep2Desc;

  /// No description provided for @cReferStep3.
  ///
  /// In en, this message translates to:
  /// **'Earn rewards'**
  String get cReferStep3;

  /// No description provided for @cReferStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'A bonus for every captain who joins through you'**
  String get cReferStep3Desc;

  /// No description provided for @cFaq1Q.
  ///
  /// In en, this message translates to:
  /// **'The customer did not share the OTP'**
  String get cFaq1Q;

  /// No description provided for @cFaq1A.
  ///
  /// In en, this message translates to:
  /// **'Ask the customer to open their Gotan or DigiStall app. The 4-digit OTP is shown on their live order screen. Never start a trip without entering it.'**
  String get cFaq1A;

  /// No description provided for @cFaq2Q.
  ///
  /// In en, this message translates to:
  /// **'How many orders can I take at once?'**
  String get cFaq2Q;

  /// No description provided for @cFaq2A.
  ///
  /// In en, this message translates to:
  /// **'You can hold up to 2 active orders. Finish one before you accept another.'**
  String get cFaq2A;

  /// No description provided for @cFaq3Q.
  ///
  /// In en, this message translates to:
  /// **'How do I get paid?'**
  String get cFaq3Q;

  /// No description provided for @cFaq3A.
  ///
  /// In en, this message translates to:
  /// **'Customers pay you directly in cash or by scanning your payment QR code. Your completed trips and earnings are in the Earnings tab.'**
  String get cFaq3A;

  /// No description provided for @cFaq4Q.
  ///
  /// In en, this message translates to:
  /// **'I feel unsafe on a trip'**
  String get cFaq4Q;

  /// No description provided for @cFaq4A.
  ///
  /// In en, this message translates to:
  /// **'Tap the red SOS button on your active trip screen. You can call 112 or share your live location.'**
  String get cFaq4A;

  /// No description provided for @cHeroPre.
  ///
  /// In en, this message translates to:
  /// **'Drive on '**
  String get cHeroPre;

  /// No description provided for @cHeroEm.
  ///
  /// In en, this message translates to:
  /// **'your'**
  String get cHeroEm;

  /// No description provided for @cHeroPost.
  ///
  /// In en, this message translates to:
  /// **' terms.'**
  String get cHeroPost;

  /// No description provided for @cHeroSub.
  ///
  /// In en, this message translates to:
  /// **'Auto, bike or car — earn up to ₹1,000 a day with rides and deliveries near you.'**
  String get cHeroSub;

  /// No description provided for @cStartEarning.
  ///
  /// In en, this message translates to:
  /// **'Start earning'**
  String get cStartEarning;

  /// No description provided for @cLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get cLogIn;

  /// No description provided for @cNewRequest.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get cNewRequest;

  /// No description provided for @cDailyPotential.
  ///
  /// In en, this message translates to:
  /// **'Daily potential'**
  String get cDailyPotential;

  /// No description provided for @cVehicleTypes.
  ///
  /// In en, this message translates to:
  /// **'Vehicle types'**
  String get cVehicleTypes;

  /// No description provided for @cServiceCities.
  ///
  /// In en, this message translates to:
  /// **'Service cities'**
  String get cServiceCities;

  /// No description provided for @cWelcomeBackCaptain.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, Captain.'**
  String get cWelcomeBackCaptain;

  /// No description provided for @cLoginDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your Captain cockpit, live orders, and earnings.'**
  String get cLoginDesc;

  /// No description provided for @cSignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get cSignInWithGoogle;

  /// No description provided for @cSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get cSigningIn;

  /// No description provided for @cNewHere.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have a Captain account?'**
  String get cNewHere;

  /// No description provided for @cSignUpToDrive.
  ///
  /// In en, this message translates to:
  /// **'Sign up to drive'**
  String get cSignUpToDrive;

  /// No description provided for @cSecuredVia.
  ///
  /// In en, this message translates to:
  /// **'Secured via DigiStall Firebase Auth'**
  String get cSecuredVia;

  /// No description provided for @cStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String cStepOf(String current, String total);

  /// No description provided for @cStepSub.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total} · {label}'**
  String cStepSub(String current, String total, String label);

  /// No description provided for @cIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get cIdentity;

  /// No description provided for @cDigitalId.
  ///
  /// In en, this message translates to:
  /// **'Captain ID'**
  String get cDigitalId;

  /// No description provided for @cBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic info'**
  String get cBasicInfo;

  /// No description provided for @cVerificationLbl.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get cVerificationLbl;

  /// No description provided for @cSignUpDesc.
  ///
  /// In en, this message translates to:
  /// **'Join the Digi Captain network. Sign up with your Google account to get verified and start taking rides and deliveries.'**
  String get cSignUpDesc;

  /// No description provided for @cSignUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get cSignUpWithGoogle;

  /// No description provided for @cConnectingGoogle.
  ///
  /// In en, this message translates to:
  /// **'Connecting Google...'**
  String get cConnectingGoogle;

  /// No description provided for @cAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Already registered as a Captain?'**
  String get cAlreadyRegistered;

  /// No description provided for @cLoginHere.
  ///
  /// In en, this message translates to:
  /// **'Log in here'**
  String get cLoginHere;

  /// No description provided for @cCaptainDomain.
  ///
  /// In en, this message translates to:
  /// **'Captain domain'**
  String get cCaptainDomain;

  /// No description provided for @cTellUsAboutYou.
  ///
  /// In en, this message translates to:
  /// **'Tell us about you'**
  String get cTellUsAboutYou;

  /// No description provided for @cFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get cFullName;

  /// No description provided for @cNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Captain Name'**
  String get cNamePlaceholder;

  /// No description provided for @cMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get cMobileNumber;

  /// No description provided for @cGoogleEmail.
  ///
  /// In en, this message translates to:
  /// **'Connected Google email'**
  String get cGoogleEmail;

  /// No description provided for @cUploadDocsTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload documents'**
  String get cUploadDocsTitle;

  /// No description provided for @cUploadDocsDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload your driving licence and payment QR code. Aadhaar and profile photo are optional.'**
  String get cUploadDocsDesc;

  /// No description provided for @cRequiredTag.
  ///
  /// In en, this message translates to:
  /// **'REQUIRED'**
  String get cRequiredTag;

  /// No description provided for @cOptionalTag.
  ///
  /// In en, this message translates to:
  /// **'OPTIONAL'**
  String get cOptionalTag;

  /// No description provided for @cUploadedTag.
  ///
  /// In en, this message translates to:
  /// **'UPLOADED'**
  String get cUploadedTag;

  /// No description provided for @cUploadBtn.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get cUploadBtn;

  /// No description provided for @cAadhaarDesc.
  ///
  /// In en, this message translates to:
  /// **'Front & back photo'**
  String get cAadhaarDesc;

  /// No description provided for @cLicenceDesc.
  ///
  /// In en, this message translates to:
  /// **'Valid private/commercial DL'**
  String get cLicenceDesc;

  /// No description provided for @cQrDesc.
  ///
  /// In en, this message translates to:
  /// **'UPI QR for customer payments'**
  String get cQrDesc;

  /// No description provided for @cPhotoDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear passport-style photo'**
  String get cPhotoDesc;

  /// No description provided for @cSubmitForReview.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get cSubmitForReview;

  /// No description provided for @cSplashPre.
  ///
  /// In en, this message translates to:
  /// **'Finding your '**
  String get cSplashPre;

  /// No description provided for @cSplashEm.
  ///
  /// In en, this message translates to:
  /// **'next'**
  String get cSplashEm;

  /// No description provided for @cSplashPost.
  ///
  /// In en, this message translates to:
  /// **' ride.'**
  String get cSplashPost;

  /// No description provided for @cSplash1.
  ///
  /// In en, this message translates to:
  /// **'Going online'**
  String get cSplash1;

  /// No description provided for @cSplash2.
  ///
  /// In en, this message translates to:
  /// **'Scanning for requests near you'**
  String get cSplash2;

  /// No description provided for @cSplash3.
  ///
  /// In en, this message translates to:
  /// **'Matching your vehicle'**
  String get cSplash3;

  /// No description provided for @cViewRoute.
  ///
  /// In en, this message translates to:
  /// **'View route'**
  String get cViewRoute;

  /// No description provided for @cTripDetails.
  ///
  /// In en, this message translates to:
  /// **'Trip details'**
  String get cTripDetails;

  /// No description provided for @cNoRating.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get cNoRating;
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

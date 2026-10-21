import 'dart:convert';
import 'dart:async';

import 'package:digirider/NavMain.dart';
import 'TripCompletePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../global/Common.dart';
import '../global/l10n.dart';
import '../model/trip_stage.dart';
import '../providers/trip_provider.dart';
import '../utils/_TimedSnackBar.dart';
import '../utils/bottomSnackBar.dart';

class TripFlowPage extends StatefulWidget {
  final String tripId;
  final String endpointPost;
  final Map<String, dynamic> order;

  const TripFlowPage({
    super.key,
    required this.tripId,
    required this.order,
    required this.endpointPost,
  });

  @override
  State<TripFlowPage> createState() => _TripFlowPageState();
}

class _TripFlowPageState extends State<TripFlowPage> {
  // TripStage currentStage = TripStage.reachPickup;
  bool _isLoading = false;
  late TextEditingController _otpController;
  // Digistall orders: the customer's delivery OTP, checked by api/digiorder/setorderStatus on "Delivered".
  late TextEditingController _deliveryOtpController;

  bool get _isDigistall => widget.endpointPost == 'api/digiorder/setorderStatus';

  // Older Digistall orders have no OTP; the backend only checks it when one is set.
  bool get _needsDeliveryOtp => _isDigistall && (widget.order['otp']?.toString().isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _deliveryOtpController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripProvider>(
        context,
        listen: false,
      ).loadTripStage(widget.tripId, riderStatus: widget.order['riderStatus']?.toString());
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _deliveryOtpController.dispose();
    super.dispose();
  }

  Future<bool> _callStageApi(TripStage? currentStage) async {
    final l10n = context.l10n;
    try {
      final url = Uri.parse('${Common.baseUrl}${widget.endpointPost}');
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? widget.order['riderDetails']?[0]?['email'];
      Map<String, dynamic> payload;

      switch (currentStage) {
        case TripStage.reachPickup:
        case TripStage.readyToStart:
          // Combined logic: Handle both pickup arrival and trip start
          payload = {
            "orderId": widget.order['_id'],
            "riderStatus": "In Transit",
            "email": email,
            if (!_isDigistall) "sellerPhone": widget.order['sellerPhone'],
            if (!_isDigistall) "userOtp": _otpController.text.trim(),
          };
          break;

        case TripStage.inProgress:
          payload = {
            "orderId": widget.order['_id'],
            "riderStatus": "Delivered",
            "email": email,
            if (!_isDigistall) "sellerPhone": widget.order['sellerPhone'],
            if (_isDigistall) "otp": _deliveryOtpController.text.trim(),
          };
          break;

        default:
          return false;
      }

      final response = await http.post(
        url,
        body: jsonEncode(payload),
        headers: {'Content-Type': 'application/json'},
      );
      if (!mounted) return false;

      if (response.statusCode != 200) {
        String? message;
        try {
          message = jsonDecode(response.body)['message'];
        } catch (_) {}
        getSnackBar(context, message ?? l10n.actionFailed, Colors.orange, 2);
        return false;
      }

      showTimedSnackBar(
        context,
        currentStage == TripStage.inProgress ? l10n.tripCompletedSuccess : l10n.tripStarted,
        Duration(seconds: 2),
        'top',
      );
      return true;
    } catch (e) {
      debugPrint('API Error: $e');
      if (mounted) getSnackBar(context, l10n.somethingWentWrong, Colors.red, 2);
      return false;
    }
  }

  Future<void> _nextStage() async {

    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final currentStage = tripProvider.currentStage;

    bool success = await _callStageApi(currentStage);
    setState(() => _isLoading = false);

    if (!success) {
      return;
    }

    // Success overlay
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (_, __, ___) => const _SuccessOverlay(),
      ),
    );

    if (currentStage == TripStage.inProgress) {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      await tripProvider.decrementActiveOrders();
      await tripProvider.completeTrip();

      // Prepare data for TripCompletePage
      final notAvailable = context.l10n.notAvailable;
      final pickup = widget.endpointPost == 'api/digiorder/setorderStatus'
          ? (widget.order['sellerAddress'] ?? notAvailable)
          : (widget.order['pickupAddress'] ?? notAvailable);
      final destination = widget.endpointPost == 'api/digiorder/setorderStatus'
          ? (widget.order['address'] ?? notAvailable)
          : ((widget.order['deliveryAddress']?.toString().isNotEmpty ?? false)
              ? widget.order['deliveryAddress']
              : notAvailable);
    final amount = widget.endpointPost == 'api/digiorder/setorderStatus'
      ? (widget.order['totalCartValue']?.toString() ?? '0')
      : (widget.order['expectedPrice']?.toString() ?? '0');
    final couponTotal = widget.endpointPost == 'api/digiorder/setorderStatus'
      ? (widget.order['coupontotal']?.toString())
      : null;

      // Fallback logic for riderId
      String riderId = widget.order['riderId'] ?? widget.order['rider_id'] ?? '';
      if (riderId == null || riderId.isEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          riderId = prefs.getString('riderId') ?? '';
          print('Fetched riderId from SharedPreferences: $riderId');
        } catch (e) {
          print('Error fetching riderId from SharedPreferences: $e');
        }
      }
      print('Navigating to TripCompletePage with riderId: $riderId');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TripCompletePage(
            pickupLocation: pickup,
            destinationLocation: destination,
            totalAmount: amount,
            riderId: riderId,
            couponTotal: couponTotal,
          ),
        ),
      );
      return;
    }

    TripStage? nextStage;
    switch (currentStage) {
      case TripStage.reachPickup:
        // Skip readyToStart and go directly to inProgress
        nextStage = TripStage.inProgress;
        break;
      case TripStage.readyToStart:
        // This stage is now merged with reachPickup, but handle it for backward compatibility
        nextStage = TripStage.inProgress;
        break;
      case TripStage.inProgress:
        // Already handled above - trip completion
        break;
      case null:
        debugPrint("Current stage is null");
        break;
    }

    if (nextStage != null) {
      await tripProvider.updateTripStage(nextStage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        final currentStage = tripProvider.currentStage ?? TripStage.reachPickup;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarColor: Common.secondary,
          ),
          child: GestureDetector(
            onTap: () => {FocusManager.instance.primaryFocus?.unfocus()},
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Common.secondary,
                toolbarHeight: 60,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/Icons/truck.svg',
                        color: Common.primary,
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Image.asset(
                      'assets/Icons/refresh.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
                title: Text(
                  _getAppBarTitle(currentStage),
                  style: TextStyle(
                    fontSize: Common.title,
                    fontFamily: Common.family,
                  ),
                ),
              ),

              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLocationCard(order: widget.order, endpointPost: widget.endpointPost),
                            // _buildContactCard(order: widget.order, endpointPost: widget.endpointPost,), // Hidden: Order ID card
                            
                            // Combined: Show navigation for both reachPickup and inProgress stages
                            if (currentStage == TripStage.reachPickup ||
                                currentStage == TripStage.inProgress)
                              _buildGoogleMapsButton(
                                order: widget.order,
                                stage: currentStage,
                              ),
                            
                            // Customer OTP to start a ride/parcel trip
                            if (currentStage == TripStage.reachPickup && !_isDigistall)
                              _buildOtpField(_otpController, context.l10n.enterCustomerOtp),

                            // Digistall delivery OTP to mark the order delivered
                            if (currentStage == TripStage.inProgress && _isDigistall)
                              _buildOtpField(_deliveryOtpController, context.l10n.enterDeliveryOtp),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    /// --- Bottom Persistent Buttons ---
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        bottom: 20,
                      ),
                      child: Column(
                        children: [
                          // Original conditional display
                          // Customer can be called before pickup and while delivering
                          if (widget.order['sellerPhone']?.toString().isNotEmpty ?? false)
                            _buildCallCard(order: widget.order),
                          const SizedBox(height: 6),
                          _isLoading
                              ? Container(
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Common.secondary,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Common.primary,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                ),
                              )
                              : Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: SlideAction(
                                  sliderButtonIconPadding: 5,
                                  sliderButtonIconSize: 20,
                                  sliderButtonYOffset: 14,
                                  onSubmit: () async {
                                    // Check for OTP in the first stage (reachPickup) for non-digiorder requests
                                    if (currentStage == TripStage.reachPickup &&
                                        !_isDigistall &&
                                        _otpController.text.trim().isEmpty) {
                                      getSnackBar(context, context.l10n.pleaseEnterCustomerOtp, Colors.orange, 2,);
                                      return;
                                    }
                                    if (currentStage == TripStage.inProgress &&
                                        _needsDeliveryOtp &&
                                        _deliveryOtpController.text.trim().isEmpty) {
                                      getSnackBar(context, context.l10n.pleaseEnterDeliveryOtp, Colors.orange, 2,);
                                      return;
                                    }
                                    Future.delayed(
                                      const Duration(milliseconds: 10),
                                      () {
                                        setState(() => _isLoading = true);
                                        _nextStage();
                                      },
                                    );
                                  },
                                  height: 45,
                                  sliderRotate: false,
                                  innerColor: Common.primary,
                                  outerColor: Common.secondary,
                                  elevation: 5,
                                  borderRadius: 30,
                                  alignment: Alignment.center,
                                  child: Text(
                                    _getBottomActionText(currentStage),
                                    style: TextStyle(
                                      fontSize: Common.h2,
                                      fontWeight: Common.weight,
                                      color: Common.primary,
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtpField(TextEditingController controller, String hint) {
    return Column(
      children: [
        SizedBox(height: 8),
        Card(
          elevation: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: Common.secondary,
                  selectionColor: Common.secondary.withOpacity(0.3),
                  selectionHandleColor: Common.secondary,
                ),
              ),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: Common.secondary,
                  fontFamily: 'bold',
                  fontWeight: Common.weight,
                  fontSize: Common.h2,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'bold',
                    fontWeight: Common.weight,
                    fontSize: Common.h2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getBottomActionText(TripStage stage) {
    switch (stage) {
      case TripStage.reachPickup:
        return context.l10n.startTrip;  // Combined: pickup + start
      case TripStage.readyToStart:
        return context.l10n.startTrip;  // Backward compatibility
      case TripStage.inProgress:
        return context.l10n.completeTrip;
    }
  }

  String _getAppBarTitle(TripStage stage) {
    switch (stage) {
      case TripStage.reachPickup:
        return context.l10n.tripDetails;  // Combined: pickup arrival + trip details
      case TripStage.readyToStart:
        return context.l10n.tripDetails;  // Backward compatibility
      case TripStage.inProgress:
        return context.l10n.tripInProgress;
    }
  }
}

class _buildCallCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _buildCallCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final phone = order['sellerPhone']?.toString().trim();

        if (phone == null || phone.isEmpty) {
          getSnackBar(
            context,
            context.l10n.customerPhoneMissing,
            Colors.orange,
            2,
          );
          return;
        }

        final url = Uri.parse('tel:$phone');

        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          getSnackBar(
            context,
            context.l10n.couldNotLaunchDialer,
            Colors.orange,
            2,
          );
        }
      },
      child: Card(
        color: Colors.transparent,
        elevation: 5,
        child: Container(
          height: 45,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Common.secondary,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/Icons/call.png',
                width: 15,
                height: 15,
                color: Color(0xFFFFFFFF),
              ),
              SizedBox(width: 30),
              Text(
                context.l10n.callCustomer,
                style: TextStyle(
                  fontWeight: Common.weight,
                  fontSize: Common.h2,
                  color: Common.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _buildGoogleMapsButton extends StatelessWidget {
  final Map<String, dynamic> order;
  final TripStage stage;
  const _buildGoogleMapsButton({
    super.key,
    required this.order,
    required this.stage,
  });

  String _getLaunchMapText(BuildContext context, TripStage stage) {
    switch (stage) {
      case TripStage.reachPickup:
        return context.l10n.navigateToPickup;
      case TripStage.inProgress:
        return context.l10n.navigateToDestination;
      default:
        return context.l10n.tripCompleted;
    }
  }

  /// Navigation target for the current stage: coordinates when the order has them
  /// (Digistall store/customer), otherwise the address text.
  String? _navigationTarget() {
    final toPickup = stage == TripStage.reachPickup;
    final lat = order[toPickup ? 'sellerLat' : 'customerLat'];
    final lng = order[toPickup ? 'sellerLng' : 'customerLng'];
    if (lat != null && lng != null) return '$lat,$lng';

    final address = toPickup
        ? (order['pickupAddress'] ?? order['sellerAddress'])
        : (order['deliveryAddress'] ?? order['address']);
    final text = address?.toString().trim();
    return (text == null || text.isEmpty) ? null : text;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          final target = _navigationTarget();

          if (target == null) {
            getSnackBar(
              context,
              stage == TripStage.reachPickup
                  ? context.l10n.pickupAddressMissing
                  : context.l10n.destinationAddressMissing,
              Colors.orange,
              2,
            );
            return;
          }

          final encodedTarget = Uri.encodeComponent(target);
          final navigationUrl = Uri.parse("google.navigation:q=$encodedTarget&mode=d");
          if (await canLaunchUrl(navigationUrl)) {
            await launchUrl(navigationUrl, mode: LaunchMode.externalApplication);
            return;
          }

          // Google Maps app not installed: open directions in the browser instead.
          await launchUrl(
            Uri.parse("https://www.google.com/maps/dir/?api=1&destination=$encodedTarget&travelmode=driving"),
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          getSnackBar(context, context.l10n.somethingWentWrong, Colors.orange, 2);
        }
      },
      child: Card(
        elevation: 5,
        child: Container(
          height: 45,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Common.secondary,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getLaunchMapText(context, stage),
                style: TextStyle(
                  fontWeight: Common.weight,
                  fontSize: Common.h2,
                  color: Common.primary,
                ),
              ),
              SizedBox(width: 20),
              SvgPicture.asset(
                'assets/Icons/location.svg',
                width: 20,
                height: 20,
                color: Color(0xFFFFFFFF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _buildContactCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final String endpointPost;
  const _buildContactCard({super.key, required this.order, required this.endpointPost});

  String getFormattedDeliveryTime(BuildContext context, Map<String, dynamic> order) {
    final deliveryBy = order['deliveryBy'];
    final deliveryTime = order['deliveryTime'];

    if (deliveryBy == null || deliveryTime == null || deliveryBy.isEmpty || deliveryTime.isEmpty) {
      return context.l10n.deliveryTimeNotSet;
    }

    try {
      final parsed = DateFormat('yyyy-MM-dd HH:mm').parse('$deliveryBy $deliveryTime');
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsed); // Ex: 04 Jul 2025, 12:00 PM
    } catch (e) {
      return context.l10n.invalidDeliveryTime;
    }
  }

  String formatIndianDate(BuildContext context, String input) {
    try {
      // Parse the input string to DateTime
      if (input == null || input.isEmpty) return context.l10n.invalidDate;
      final parsed = DateTime.tryParse(input);
      if (parsed == null) return context.l10n.invalidDate;

      // Convert to local time if needed (optional)
      final localTime = parsed.toLocal();

      // Create a date formatter with the desired pattern
      final formatter = DateFormat('dd MMM yyyy, hh:mm a');

      // Format the date
      return formatter.format(localTime);
    } catch (e) {
      debugPrint('Date formatting error: $e');
      return context.l10n.invalidDate;
    }
  }

  int _getCartValue() {
    final value = order['totalCartValue'];
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static const int commission = 20;

  @override
  Widget build(BuildContext context) {
    final isDigistall = endpointPost == 'api/digiorder/setorderStatus';
    final cartValue = _getCartValue();
    final total = cartValue + commission;
    return Card(
      elevation: 5,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Common.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // if(endpointPost=='api/parcel/setriderstatus')
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    context.l10n.orderId,
                    style: TextStyle(
                      fontSize: Common.h2,
                      fontWeight: Common.weight2,
                      color: Common.secondary,
                      fontFamily: 'bold',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '#${order['_id']?.toString() ?? ''}',
                      // '${getFormattedDeliveryTime(context, order)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: Common.weight2,
                        color: Common.light,
                        fontFamily: 'bold',
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ],
            ),


            Divider(color: Common.light, thickness: 0.3,),
            SizedBox(height: 5),
            // Divider(),
            // SizedBox(height: 6),

            if(endpointPost!='api/digiorder/setorderStatus')...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.name,
                    style: TextStyle(
                        fontWeight: Common.weight2,
                        fontSize: Common.h2,
                        color: Common.secondary,
                        fontFamily: 'bold'
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        (order['sellerName']?.toString().isNotEmpty ?? false)
                            ? order['sellerName']
                            : context.l10n.notAvailable,
                        style: TextStyle(
                            fontWeight: Common.weight2,
                            fontSize: Common.h2,
                            color: Common.light,
                            fontFamily: 'bold'
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.phoneNo,
                    style: TextStyle(
                        fontWeight: Common.weight2,
                        fontSize: Common.h2,
                        color: Common.secondary,
                        fontFamily: 'bold'
                    ),
                  ),
                  SizedBox(height: 10,),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        (order['sellerPhone']?.toString().isNotEmpty ?? false)
                            ? order['sellerPhone']
                            : context.l10n.notAvailable,
                        style: TextStyle(
                            fontWeight: Common.weight2,
                            fontSize: Common.h2,
                            color: Common.light,
                            fontFamily: 'bold'
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.distance,
                    style: TextStyle(
                        fontWeight: Common.weight2,
                        fontSize: Common.h2,
                        color: Common.secondary,
                        fontFamily: 'bold'
                    ),
                  ),
                  SizedBox(height: 10,),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        order['distance']?? context.l10n.unknown,
                        style: TextStyle(
                            fontWeight: Common.weight2,
                            fontSize: Common.h2,
                            color: Common.light,
                            fontFamily: 'bold'
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if(endpointPost=='api/rider/setriderstatus')...[
              SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.vehicleType,
                    style: TextStyle(
                        fontWeight: Common.weight2,
                        fontSize: Common.h2,
                        color: Common.secondary,
                        fontFamily: 'bold'
                    ),
                  ),
                  SizedBox(height: 10,),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        (order['vehicleType']?? context.l10n.unknown),
                        style: TextStyle(
                            fontWeight: Common.weight2,
                            fontSize: Common.h2,
                            color: Common.light,
                            fontFamily: 'bold'
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.numberOfPassengers,
                    style: TextStyle(
                        fontWeight: Common.weight2,
                        fontSize: Common.h2,
                        color: Common.secondary,
                        fontFamily: 'bold'
                    ),
                  ),
                  SizedBox(height: 10,),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        textAlign: TextAlign.end,
                        (order['numOfPassengers']?? context.l10n.unknown),
                        style: TextStyle(
                            fontWeight: Common.weight2,
                            fontSize: Common.h2,
                            color: Common.light,
                            fontFamily: 'bold'
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if(endpointPost=='api/parcel/setriderstatus')...[
              SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.parcelMessage,
                    style: TextStyle(
                        fontWeight: Common.weight2,
                        fontSize: Common.h2,
                        color: Common.secondary,
                        fontFamily: 'bold'
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        order['message']?? context.l10n.nil,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontWeight: Common.weight2,
                            fontSize: Common.h2,
                            color: Common.light,
                            fontFamily: 'bold'
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.parcelWeight,
                    style: TextStyle(
                        fontWeight: Common.weight2,
                        fontSize: Common.h2,
                        color: Common.secondary,
                        fontFamily: 'bold'
                    ),
                  ),
                  SizedBox(height: 10,),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        (order['weight']?? context.l10n.unknown),
                        style: TextStyle(
                            fontWeight: Common.weight2,
                            fontSize: Common.h2,
                            color: Common.light,
                            fontFamily: 'bold'
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 6),
            // Show cart value + commission for Digistall Orders
            if (endpointPost == 'api/digiorder/setorderStatus') ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.cartValue,
                    style: TextStyle(
                        fontWeight: Common.weight2,
                        fontSize: Common.h2,
                        color: Common.secondary,
                        fontFamily: 'bold'
                    ),
                  ),
                  SizedBox(height: 10,),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        '₹${order['totalCartValue']} + ₹20 commission',
                        style: TextStyle(
                            fontWeight: Common.weight2,
                            fontSize: Common.h2,
                            color: Colors.green,
                            fontFamily: 'bold'
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.total,
                    style: TextStyle(
                        fontWeight: Common.weight2,
                        fontSize: Common.h2,
                        color: Common.secondary,
                        fontFamily: 'bold'
                    ),
                  ),
                  SizedBox(height: 10,),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        '₹${order['totalCartValue'] + 20}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Common.h2,
                            color: Colors.blue[800],
                            fontFamily: 'bold'
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  endpointPost=='api/digiorder/setorderStatus'?
                      context.l10n.totalValue:
                  context.l10n.total,
                  style: TextStyle(
                      fontWeight: Common.weight2,
                      fontSize: Common.h2,
                      color: Common.secondary,
                      fontFamily: 'bold'
                  ),
                ),
                SizedBox(height: 10,),
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      endpointPost=='api/digiorder/setorderStatus'?
                      '${order['totalCartValue'].toString()} Rs.': '${order['expectedPrice']?? context.l10n.unknown} Rs.',
                      style: TextStyle(
                          fontWeight: Common.weight2,
                          fontSize: Common.h2,
                          color: Common.light,
                          fontFamily: 'bold'
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  endpointPost=='api/digiorder/setorderStatus'?
                      context.l10n.deliverBy:
                  context.l10n.pickupTime,
                  style: TextStyle(
                      fontWeight: Common.weight2,
                      fontSize: Common.h2,
                      color: Common.secondary,
                      fontFamily: 'bold'
                  ),
                ),
                SizedBox(height: 10,),
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      endpointPost=='api/digiorder/setorderStatus'?
                      getFormattedDeliveryTime(context, order):
                      formatIndianDate(context, order['pickupTime']?.toString() ?? ''),
                      style: TextStyle(
                          fontWeight: Common.weight2,
                          fontSize: Common.h2,
                          color: Common.light,
                          fontFamily: 'bold'
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _buildLocationCard extends StatefulWidget {
  final Map<String, dynamic> order;
  final String endpointPost;
  const _buildLocationCard({super.key, required this.order, required this.endpointPost});

  @override
  State<_buildLocationCard> createState() => _buildLocationCardState();
}

class _buildLocationCardState extends State<_buildLocationCard> {
  String? _currentLocationText; // null while the location is being fetched
  Position? _currentPosition;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get rider's current location
  Future<void> _getCurrentLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentLocationText = context.l10n.locationDenied;
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocationText = context.l10n.locationDeniedForever;
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
      });

      // Convert coordinates to address
      await _getAddressFromCoordinates(position.latitude, position.longitude);
      
    } catch (e) {
      setState(() {
        _currentLocationText = context.l10n.unableToGetLocation;
        _isLoadingLocation = false;
      });
      print('Error getting location: $e');
    }
  }

  // Convert coordinates to readable address
  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';
        
        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += address.isNotEmpty ? ', ${place.subLocality!}' : place.subLocality!;
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += address.isNotEmpty ? ', ${place.locality!}' : place.locality!;
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          address += address.isNotEmpty ? ', ${place.administrativeArea!}' : place.administrativeArea!;
        }
        
        setState(() {
          _currentLocationText = address.isNotEmpty ? address : context.l10n.currentLocationFound;
          _isLoadingLocation = false;
        });
      } else {
        setState(() {
          _currentLocationText = context.l10n.locationCoordinates('$latitude', '$longitude');
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentLocationText = context.l10n.locationCoordinates('$latitude', '$longitude');
        _isLoadingLocation = false;
      });
      print('Error getting address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Common.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // RIDER CURRENT LOCATION
            Row(
              children: [
                SvgPicture.asset(
                  'assets/Icons/location.svg',
                  width: 24,
                  height: 24,
                  color: Color(0xFF4CAF50), // Green for current location
                ),
                SizedBox(width: 16),
                Text(
                  context.l10n.yourLocation,
                  style: TextStyle(
                    fontSize: Common.h2,
                    fontWeight: Common.weight2,
                    fontFamily: 'bold',
                    color: Common.secondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    child: Center(
                      child: Container(width: 1, color: Common.secondary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _currentLocationText ?? context.l10n.gettingLocation,
                              style: TextStyle(
                                fontSize: Common.h2,
                                fontWeight: Common.weight,
                                color: Common.light,
                              ),
                              softWrap: true,
                            ),
                          ),
                          if (_isLoadingLocation)
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Common.secondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
            ),
            SizedBox(height: 12),
            
            // PICKUP LOCATION
            Row(
              children: [
                SvgPicture.asset(
                  'assets/Icons/location.svg',
                  width: 24,
                  height: 24,
                  color: Color(0xFF58DE71),
                ),
                SizedBox(width: 16),
                Text(
                  context.l10n.pickup,
                  style: TextStyle(
                    fontSize: Common.h2,
                    fontWeight: Common.weight,
                    fontFamily: 'bold',
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // ensures vertical stretch
                children: [
                  Container(
                    width: 24,
                    child: Center(
                      child: Container(width: 1, color: Common.secondary),
                    ),
                  ),
                  const SizedBox(width: 16), // optional spacing
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        widget.endpointPost=='api/digiorder/setorderStatus'?
                            widget.order['sellerAddress']?? context.l10n.notAvailable:
                        widget.order['pickupAddress']?? context.l10n.notAvailable,
                        style: TextStyle(
                          fontSize: Common.h2,
                          fontWeight: Common.weight,
                          color: Common.light,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/Icons/location.svg',
                  width: 24,
                  height: 24,
                  color: Color(0xFFED9D60),
                ),
                SizedBox(width: 16),
                Text(
                  context.l10n.drop,
                  style: TextStyle(
                    fontSize: Common.h2,
                    fontWeight: Common.weight,
                    fontFamily: 'bold',
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 40.0, right: 8),
              child: Text(
                widget.endpointPost=='api/digiorder/setorderStatus'?
                    widget.order['address']?? context.l10n.notAvailable :
                (widget.order['deliveryAddress']?.toString().isNotEmpty ?? false)
                    ? widget.order['deliveryAddress']
                    : context.l10n.notAvailable,
                style: TextStyle(
                  fontSize: Common.h2,
                  fontWeight: Common.weight,
                  color: Common.light,
                ),
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessOverlay extends StatefulWidget {
  const _SuccessOverlay({super.key});

  @override
  State<_SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<_SuccessOverlay> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // auto-close after 2 seconds
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Common.background,
      ),
      child: Scaffold(
        // backgroundColor: Colors.black.withOpacity(0.8),
        body: Center(
          child: SizedBox(
            height: 200,
            width: 200,
            child: Lottie.asset('assets/animation/success.json'),
          ),
        ),
      ),
    );
  }
}

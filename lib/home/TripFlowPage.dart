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
  
  // Location tracking variables
  String _currentLocationText = 'Getting current location...';
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _getCurrentLocation(); // Get rider's current location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripProvider>(
        context,
        listen: false,
      ).loadTripStage(widget.tripId);
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
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
            _currentLocationText = 'Location permission denied';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocationText = 'Location permission permanently denied';
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
        _currentLocationText = 'Unable to get location';
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
          _currentLocationText = address.isNotEmpty ? address : 'Current location found';
          _isLoadingLocation = false;
        });
      } else {
        setState(() {
          _currentLocationText = 'Location coordinates: $latitude, $longitude';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentLocationText = 'Location coordinates: $latitude, $longitude';
        _isLoadingLocation = false;
      });
      print('Error getting address: $e');
    }
  }

  Future<bool> _callStageApi(TripStage? currentStage) async {
    try {
      final url = Uri.parse('${Common.baseUrl}${widget.endpointPost}');
      Map<String, dynamic> payload;

      switch (currentStage) {
        case TripStage.reachPickup:
          // Combined logic: Handle both pickup arrival and trip start
          payload = {
            "orderId": widget.order['_id'],
            "riderStatus": "In Transit",
            "email": widget.order['riderDetails'][0]['email'],
            if (widget.endpointPost != 'api/digiorder/setorderStatus')
              "sellerPhone": widget.order['sellerPhone'],
            if (widget.endpointPost != 'api/digiorder/setorderStatus')
              "userOtp": _otpController.text.trim(),
          };
          break;

        case TripStage.inProgress:
          payload = {
            "orderId": widget.order['_id'],
            "riderStatus": "Delivered",
            "email": widget.order['riderDetails'][0]['email'],
            if (widget.endpointPost != 'api/digiorder/setorderStatus')
              "sellerPhone": widget.order['sellerPhone'],
          };
          break;

        default:
          // Handle unexpected cases
          payload = {};
          break;
      }

      // For reachPickup stage, we now handle the full pickup + start process
      if (currentStage == TripStage.reachPickup) {
        // Make the API call for trip start
        final response = await http.post(
          url,
          body: jsonEncode(payload),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode != 200) {
          final res = jsonDecode(response.body);
          getSnackBar(
            context,
            res['message'] ?? "Action failed. Please try again.",
            Colors.orange,
            2,
          );
          return false;
        }

        showTimedSnackBar(
          context,
          'Trip Started Successfully.',
          Duration(seconds: 2),
          'top',
        );
        return true;
      }

      final response = await http.post(
        url,
        body: jsonEncode(payload),
        headers: {'Content-Type': 'application/json'},
      );

      // print("url: ${url}");
      // print("payload: ${payload}");
      // print("API Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode != 200) {
        final res = jsonDecode(response.body);
        getSnackBar(
          context,
          res['message'] ?? "Action failed. Please try again.",
          Colors.orange,
          2,
        );
        return false;
      }

      if (currentStage == TripStage.inProgress) {
        showTimedSnackBar(
          context,
          'Trip Completed Successfully.',
          Duration(seconds: 2),
          'top',
        );
        return true;
      }

      return true;
    } catch (e) {
      print('API Error: $e');
      getSnackBar(context, "Something went wrong.", Colors.red, 2);
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
      final pickup = widget.endpointPost == 'api/digiorder/setorderStatus'
          ? (widget.order['sellerAddress'] ?? 'Not Available')
          : (widget.order['pickupAddress'] ?? 'Not Available');
      final destination = widget.endpointPost == 'api/digiorder/setorderStatus'
          ? (widget.order['address'] ?? 'Not Available')
          : ((widget.order['deliveryAddress']?.toString().isNotEmpty ?? false)
              ? widget.order['deliveryAddress']
              : 'Not available');
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
                            
                            // Combined: Show OTP input in the first stage (reachPickup) instead of readyToStart
                            if (currentStage == TripStage.reachPickup &&
                                widget.endpointPost != 'api/digiorder/setorderStatus')
                              Column(
                                children: [
                                  SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Card(
                                          elevation: 4,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(
                                                12,
                                              ),
                                            ),
                                            child: Theme(
                                              data: Theme.of(context).copyWith(
                                                textSelectionTheme:
                                                    TextSelectionThemeData(
                                                      cursorColor: Common.secondary,
                                                      selectionColor: Common
                                                          .secondary
                                                          .withOpacity(0.3),
                                                      selectionHandleColor:
                                                          Common.secondary,
                                                    ),
                                              ),
                                              child: TextField(
                                                controller: _otpController,
                                                style: TextStyle(
                                                  color: Common.secondary,
                                                  fontFamily: 'bold',
                                                  fontWeight: Common.weight,
                                                  fontSize: Common.h2,
                                                ),
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText:
                                                      'Enter Customer OTP here',
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
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                          if (currentStage == TripStage.reachPickup)
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
                                        widget.endpointPost != 'api/digiorder/setorderStatus' && 
                                        _otpController.text.trim().isEmpty) {
                                      getSnackBar(context, "Please enter the customer OTP.", Colors.orange, 2,);
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

  String _getBottomActionText(TripStage stage) {
    switch (stage) {
      case TripStage.reachPickup:
        return "Start the Trip";  // Combined: pickup + start
      case TripStage.readyToStart:
        return "Start the Trip";  // Backward compatibility
      case TripStage.inProgress:
        return "Trip Completed";
    }
  }

  String _getAppBarTitle(TripStage stage) {
    switch (stage) {
      case TripStage.reachPickup:
        return "Trip Details";  // Combined: pickup arrival + trip details
      case TripStage.readyToStart:
        return "Trip Details";  // Backward compatibility
      case TripStage.inProgress:
        return "Trip In Progress";
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
            "Seller phone number is missing.",
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
            "Could not launch phone dialer.",
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
                'Call Customer',
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

  String _getLaunchMapText(TripStage stage) {
    switch (stage) {
      case TripStage.reachPickup:
        return "Navigate to Pickup";
      case TripStage.inProgress:
        return "Navigate to Destination";
      default:
        return "Trip Completed";
      // case TripStage.confirmOtp:
      //   return "Confirm OTP";
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          final pickup =
              _getLaunchMapText(stage) == "Navigate to Pickup"
                  ? order['pickupAddress']?.toString().trim()
                  : order['deliveryAddress']?.toString().trim();

          // Check if pickup or delivery is null or empty
          if (pickup == null || pickup.isEmpty) {
            getSnackBar(
              context,
              _getLaunchMapText(stage) == "Navigate to Pickup"
                  ? 'Pickup address is missing.'
                  : 'Destination address is missing.',
              Colors.orange,
              2,
            );
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(content: Text('Pickup address is missing.')),
            // );
            return;
          }

          // Try Google Maps navigation with destination only
          final encodedPickup = Uri.encodeComponent(pickup);
          final navigationUrl = Uri.parse(
            "google.navigation:q=$encodedPickup&mode=d",
          );

          if (await canLaunchUrl(navigationUrl)) {
            await launchUrl(
              navigationUrl,
              mode: LaunchMode.externalApplication,
            );
            return;
          }
        } catch (e) {
          getSnackBar(context, 'Something went wrong.', Colors.orange, 2);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Error: ${e.toString()}')),
          // );
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
                _getLaunchMapText(stage),
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

  String getFormattedDeliveryTime(Map<String, dynamic> order) {
    final deliveryBy = order['deliveryBy'];
    final deliveryTime = order['deliveryTime'];

    if (deliveryBy == null || deliveryTime == null || deliveryBy.isEmpty || deliveryTime.isEmpty) {
      return 'Delivery time not set';
    }

    try {
      final parsed = DateFormat('yyyy-MM-dd HH:mm').parse('$deliveryBy $deliveryTime');
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsed); // Ex: 04 Jul 2025, 12:00 PM
    } catch (e) {
      return 'Invalid delivery time';
    }
  }

  String formatIndianDate(String input) {
    try {
      // Parse the input string to DateTime
      if (input == null || input.isEmpty) return 'Invalid Date';
      final parsed = DateTime.tryParse(input);
      if (parsed == null) return 'Invalid Date';

      // Convert to local time if needed (optional)
      final localTime = parsed.toLocal();

      // Create a date formatter with the desired pattern
      final formatter = DateFormat('dd MMM yyyy, hh:mm a');

      // Format the date
      return formatter.format(localTime);
    } catch (e) {
      debugPrint('Date formatting error: $e');
      return 'Invalid Date';
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
                    'Order ID',
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
                      // '${getFormattedDeliveryTime(order)}',
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
                    'Name',
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
                            : 'Not available',
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
                    'Phone No.',
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
                            : 'Not available',
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
                    'Distance',
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
                        order['distance']?? 'Unknown',
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
                    'Vehicle Type',
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
                        (order['vehicleType']?? 'Unknown'),
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
                    'Number of Passengers',
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
                        (order['numOfPassengers']?? 'Unknown'),
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
                    'Parcel Message',
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
                        order['message']?? 'Nil',
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
                    'Parcel Weight',
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
                        (order['weight']?? 'Unknown'),
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
                    'CART VALUE',
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
                    'Total',
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
                      'Total Value':
                  'TOTAL',
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
                      '${order['totalCartValue'].toString()} Rs.': '${order['expectedPrice']?? 'Unknown'} Rs.',
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
                      'Deliverd By':
                  'Pickup Time',
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
                      getFormattedDeliveryTime(order):
                      formatIndianDate(order['pickupTime']?.toString() ?? ''),
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
  String _currentLocationText = 'Getting current location...';
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
            _currentLocationText = 'Location permission denied';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocationText = 'Location permission permanently denied';
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
        _currentLocationText = 'Unable to get location';
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
          _currentLocationText = address.isNotEmpty ? address : 'Current location found';
          _isLoadingLocation = false;
        });
      } else {
        setState(() {
          _currentLocationText = 'Location coordinates: $latitude, $longitude';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentLocationText = 'Location coordinates: $latitude, $longitude';
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
                  'YOUR LOCATION',
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
                              _currentLocationText,
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
                  'PICKUP',
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
                            widget.order['sellerAddress']?? 'Not Available':
                        widget.order['pickupAddress']?? 'Not Available',
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
                  'DROP',
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
                    widget.order['address']?? 'Not Available' :
                (widget.order['deliveryAddress']?.toString().isNotEmpty ?? false)
                    ? widget.order['deliveryAddress']
                    : 'Not available',
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

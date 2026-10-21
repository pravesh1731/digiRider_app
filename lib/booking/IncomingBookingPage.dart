import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../global/OrderTypeIcon.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../global/Common.dart';
import 'package:http/http.dart' as http;

import '../global/l10n.dart';
import '../providers/NotificationProvider.dart';
import '../providers/trip_provider.dart';
import '../services/active_orders.dart';
import '../services/notification_service.dart';
import '../utils/_TimedSnackBar.dart';
import '../utils/bottomSnackBar.dart';
import '../utils/show_exit_dialog.dart';

class IncomingBookingPage extends StatefulWidget {
  const IncomingBookingPage({super.key});

  @override
  State<IncomingBookingPage> createState() => _IncomingBookingPageState();
}

class _IncomingBookingPageState extends State<IncomingBookingPage> {

  String vehicleType = '';
  String cityName = '';
  String name = '';
  String email = '';
  String phoneNumber = '';
  String riderDomain = '';
  String uniqueRiderOtp = '';
  String userStatus = '';
  String active = '';
  String riderId = '';
  String licence = '';
  String qrcode = '';
  List<dynamic> _orders = [];
  bool _isLoading = true;
  Timer? _timer;

  // Commission is now always calculated from coupontotal and totalCartValue in the order data

  StreamSubscription? _messageSub;

  void filterRidesAuto() async {
    final filtered = await _fetchAllBookings();
    if (!mounted) return;
    setState(() {
      _orders = _sortOrdersByLatest(filtered);
    });
  }


  void filterRides() async {
    setState(() {
      _isLoading = true;
    });
    final filtered = await _fetchAllBookings();
    if (!mounted) return;
    setState(() {
      _orders = _sortOrdersByLatest(filtered);
      _isLoading = false;
    });
  }


  Future<List<dynamic>> _fetchAllBookings() async {
    await _loadSharedPrefs();

    final city = Uri.encodeQueryComponent(cityName);
    final endpoints = [
      {'endpoint': 'api/rider/dashboard?vehicleType=${Uri.encodeQueryComponent(vehicleType)}&cityName=$city', 'type': 'Rider Orders', 'order': 'filteredOrders', 'post': 'api/rider/acceptriderorder'},
      {'endpoint': 'api/parcel/dashboard?cityName=$city', 'type': 'Parcel Orders', 'order': 'parcelOrders', 'post': 'api/parcel/acceptriderorder'},
      {'endpoint': 'api/digiorder/getDigiOrder', 'type': 'Digistall Orders', 'order': 'DigiOrders', 'post': 'api/digiorder/acceptedByRider'},
    ];

    // One failing backend must not hide the orders from the other two.
    final results = await Future.wait(endpoints.map((ep) async {
      try {
        final response = await http.get(Uri.parse('${Common.baseUrl}${ep['endpoint']}'));
        if (response.statusCode != 200) return <dynamic>[];
        final orders = jsonDecode(response.body)[ep['order']];
        if (orders is! List) return <dynamic>[];
        for (var o in orders) {
          o['orderType'] = ep['type'];
          o['endpointPost'] = ep['post'];
        }
        return orders;
      } catch (e) {
        debugPrint('Error fetching ${ep['type']}: $e');
        return <dynamic>[];
      }
    }));

    return results
        .expand((orders) => orders)
        .where((order) => _shouldIncludeOrder(order))
        .toList();
  }

  List<dynamic> _sortOrdersByLatest(List<dynamic> orders) {
    orders.sort((a, b) {
      final aTime = DateTime.tryParse(a['pickupTime'] ?? a['createdAt'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = DateTime.tryParse(b['pickupTime'] ?? b['createdAt'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return orders;
  }



  Future<void> _loadSharedPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  // Load actual values from SharedPreferences
  vehicleType = prefs.getString('vehicleType') ?? 'Bike'; // Default to 'Bike' if not set
  cityName = prefs.getString('cityName') ?? 'Gotan'; // Default to 'Gotan' if not set
  name = prefs.getString('name') ?? '';
  email = prefs.getString('email') ?? '';
  phoneNumber = prefs.getString('phoneNumber') ?? '';
  riderDomain = prefs.getString('riderDomain') ?? '';
  uniqueRiderOtp = prefs.getString('uniqueRiderOtp') ?? '';
  userStatus = prefs.getString('userStatus') ?? '';
  final boolActive = prefs.getBool('active');
  active = boolActive != null ? boolActive.toString() : '';
  riderId = prefs.getString('riderId') ?? '';
  licence = prefs.getString('licence') ?? '';
  qrcode = prefs.getString('qrcode') ?? '';

  if (!['Bike', 'Auto', 'Car'].contains(vehicleType)) {
    vehicleType = 'Bike';
  }
  }

  bool _shouldIncludeOrder(Map<String, dynamic> order) {
    final orderType = order['orderType'] as String?;

    // Digistall and Parcel orders are offered to every rider in the city
    if (orderType == 'Digistall Orders' || orderType == 'Parcel Orders') return true;

    // Ride requests must match the rider's vehicle type
    if (orderType == 'Rider Orders') return order['vehicleType'] == vehicleType;

    return false;
  }

  Map<String, int> _getOrderTypeCounts() {
    final counts = <String, int>{
      'Rider Orders': 0,
      'Parcel Orders': 0,
      'Digistall Orders': 0,
    };

    for (var order in _orders) {
      final orderType = order['orderType'] as String?;
      if (orderType != null && counts.containsKey(orderType)) {
        counts[orderType] = counts[orderType]! + 1;
      }
    }

    return counts;
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    // A push for a new order arrived while the app is open: refresh right away instead of waiting for the poll.
    _messageSub = NotificationService().onMessage.listen((_) => filterRidesAuto());
  }

  void _initializeData() async {
    final orders = await _fetchAllBookings();

    if (mounted) {
      setState(() {
        _orders = _sortOrdersByLatest(orders);
        _isLoading = false;
      });
    }

    if (!mounted) return;
    // Start periodic refresh
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      filterRidesAuto();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when widget is disposed
    _messageSub?.cancel();
    super.dispose();
  }
  // int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showExitConfirmationDialog(context),
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
            // Debug info showing current rider's vehicle type
            Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue, width: 1),
              ),
              child: Text(
                vehicleType.isEmpty ? context.l10n.loading : context.l10n.vehicleName(vehicleType),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async => {
                setState(() {
                  _isLoading = true;
                }),
                filterRides(),
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Image.asset('assets/Icons/refresh.png', width: 20, height: 20,color:Colors.white,),
              ),
            ),
          ],
          title: Text(context.l10n.incomingBookings, style: TextStyle(fontSize: Common.title, fontFamily: Common.family,color:Colors.white,),),
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.only(right: 12.0, left: 12.0, top: 8),
            child: Column(
              children: [
                // Vehicle type info card
                if (!_isLoading && vehicleType.isNotEmpty) 
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.directions_car, color: Colors.blue, size: 16),
                            SizedBox(width: 8),
                            Text(
                              context.l10n.vehicleTypeLabel(context.l10n.vehicleName(vehicleType)),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                                fontSize: 14,
                              ),
                            ),
                            Spacer(),
                            Text(
                              context.l10n.ordersCount(_orders.length),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: _getOrderTypeCounts().entries.map((entry) {
                            return Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '${entry.value}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                  Text(
                                    context.l10n.orderTypeName(entry.key),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                // Removed status filter buttons
                Expanded(
                  child: _isLoading
                      ? ListView.builder(
                    itemCount: 5, // number of shimmer cards
                    itemBuilder: (context, index) => const OrderCardShimmer(),
                  )
                      : _orders.isEmpty
                      ? Center(
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Lottie.asset('assets/animation/empty2.json', height: 200),
                          Positioned(
                            bottom: 30,
                            child: Text(
                              context.l10n.nothingHereYet,
                              style: TextStyle(
                                  fontSize: Common.h2,
                                  color: Colors.grey,
                                  fontWeight: Common.weight,
                                  fontFamily: 'bold'
                              ),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ): RefreshIndicator(
                    backgroundColor: Common.secondary,
                    color: Common.primary,
                    elevation: 2,
                    onRefresh: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      filterRides();
                    },
                    child: ListView.builder(
                      itemCount: _orders.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _orders.length) return const SizedBox(height: 8);
                        final order = _orders[index];
                        if (order['orderType'] == 'Digistall Orders') {
                          return _DigistallOrderCard(
                            order: order,
                            phoneNumber: phoneNumber,
                            email: email,
                            name: name,
                            active: active,
                            cityName: cityName,
                            licence: licence,
                            qrcode: qrcode,
                            riderDomain: riderDomain,
                            riderId: riderId,
                            uniqueRiderOtp: uniqueRiderOtp,
                            userStatus: userStatus,
                            vehicleType: vehicleType,
                            endpointPost: order['endpointPost'] ?? '',
                            onOrderAccepted: () async => filterRides(),
                            // commission is now calculated inside _DigistallOrderCard
                          );
                        } else {
                          return _OrderCard(
                            order: order,
                            phoneNumber: phoneNumber,
                            email: email,
                            name: name,
                            active: active,
                            cityName: cityName,
                            licence: licence,
                            qrcode: qrcode,
                            riderDomain: riderDomain,
                            riderId: riderId,
                            uniqueRiderOtp: uniqueRiderOtp,
                            userStatus: userStatus,
                            vehicleType: vehicleType,
                            endpointPost: order['endpointPost'] ?? '',
                            onOrderAccepted: () async => filterRides(),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



}

/// Accepts [order] for the logged-in rider through [endpointPost]. Returns true when the backend accepted it.
Future<bool> _acceptIncomingOrder(BuildContext context, Map<String, dynamic> order, String endpointPost) async {
  final l10n = context.l10n;
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email') ?? '';

  // Checked against the server so the limit holds after reinstalls or on a second phone.
  final activeOrders = await ActiveOrders.fetch(email);
  if (!context.mounted) return false;
  if (activeOrders.length >= ActiveOrders.maxActiveOrders) {
    showTimedSnackBar(context, l10n.finishCurrentRidesFirst, Duration(seconds: 3), 'below');
    return false;
  }

  try {
    final response = await http.post(
      Uri.parse("${Common.baseUrl}$endpointPost"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "orderId": order['_id'],
        "sellerPhone": order['sellerPhone'],
        "riderData": {
          "name": prefs.getString('name') ?? '',
          "email": email,
          "cityName": prefs.getString('cityName') ?? '',
          "phoneNumber": prefs.getString('phoneNumber') ?? '',
          "riderDomain": prefs.getString('riderDomain') ?? '',
          "deviceToken": prefs.getString('deviceToken') ?? '',
          "vehicleType": prefs.getString('vehicleType') ?? '',
          "aadhaar": prefs.getString('aadhaar') ?? '',
          "licence": prefs.getString('licence') ?? '',
          "profile": prefs.getString('profile') ?? '',
          "qrcode": prefs.getString('qrcode') ?? '',
          "success": true,
          "userStatus": prefs.getString('userStatus') ?? '',
        }
      }),
    );
    if (!context.mounted) return false;

    Map<String, dynamic>? respBody;
    try {
      respBody = jsonDecode(response.body);
    } catch (_) {}

    if (response.statusCode == 200 && respBody?['success'] != false) {
      await Provider.of<TripProvider>(context, listen: false).setActiveOrdersCount(activeOrders.length + 1);
      if (!context.mounted) return true;
      showTimedSnackBar(context, l10n.orderAccepted, Duration(seconds: 2), 'below');
      Provider.of<NotificationProvider>(context, listen: false).showBadge();
      return true;
    }

    final message = respBody?['message']?.toString() ?? '';
    getSnackBar(
      context,
      message.contains('already been accepted') ? l10n.orderAlreadyTaken : (message.isNotEmpty ? message : l10n.acceptFailed),
      Colors.red,
      2,
    );
  } catch (e) {
    debugPrint("Error accepting order: $e");
    if (context.mounted) getSnackBar(context, l10n.somethingWentWrong, Colors.red, 2);
  }
  return false;
}

class _DigistallOrderCard extends StatefulWidget {
  // const _DigistallOrderCard({
  //   super.key,
  // });
  final Map<String, dynamic> order;
  final String vehicleType;
  final String cityName;
  final String name;
  final String email;
  final String phoneNumber;
  final String riderDomain;
  final String uniqueRiderOtp;
  final String userStatus;
  final String active;
  final String riderId;
  final String licence;
  final String qrcode;
  final String endpointPost;

  final Future<void> Function()? onOrderAccepted;

  const _DigistallOrderCard({Key? key, required this.order, required this.phoneNumber, required this.email, required this.name, required this.active, required this.cityName, required this.licence, required this.qrcode, required this.riderDomain, required this.riderId, required this.uniqueRiderOtp, required this.userStatus, required this.vehicleType, required this.endpointPost, required this.onOrderAccepted,}) : super(key: key);

  @override
  State<_DigistallOrderCard> createState() => _DigistallOrderCardState();
}

class _DigistallOrderCardState extends State<_DigistallOrderCard> {
  bool _isAccepting = false;

  String formatIndianDate(String input) {
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

  String getFormattedDeliveryTime(Map<String, dynamic> order) {
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

  Future<void> _acceptOrder() async {
    setState(() => _isAccepting = true);
    final accepted = await _acceptIncomingOrder(context, widget.order, widget.endpointPost);
    if (mounted) setState(() => _isAccepting = false);
    if (accepted && widget.onOrderAccepted != null) {
      await Future.delayed(Duration(milliseconds: 500));
      await widget.onOrderAccepted!();
    }
  }


  int _getCartValue() {
    final value = widget.order['totalCartValue'];
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String _getCouponTotal() {
    // Always use coupontotal from order if present
    final couponTotal = widget.order['coupontotal'];
    if (couponTotal is String) return couponTotal;
    if (couponTotal is int) return couponTotal.toString();
    // If expectedPrice exists, use it as coupon total
    final expectedPrice = widget.order['expectedPrice'];
    if (expectedPrice != null) {
      if (expectedPrice is int) {
        return expectedPrice.toString();
      } else if (expectedPrice is String) {
        return expectedPrice;
      }
    }
    // If adminCommission exists, add it to cart value
    final adminCommission = widget.order['adminCommission'];
    final totalCartValue = _getCartValue();
    if (adminCommission != null) {
      int commissionValue = 0;
      if (adminCommission is int) {
        commissionValue = adminCommission;
      } else if (adminCommission is String) {
        commissionValue = int.tryParse(adminCommission) ?? 0;
      }
      return (totalCartValue + commissionValue).toString();
    }
    // Fallback: just return cart value as string
    return totalCartValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cartValue = _getCartValue();
    final couponTotal = _getCouponTotal();
    int commission = 0;
    try {
      commission = int.parse(couponTotal) - cartValue;
    } catch (e) {
      commission = 0;
    }
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
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: OrderTypeIcon(orderType: widget.order['orderType'] ?? ''),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      context.l10n.deliveryBy(getFormattedDeliveryTime(widget.order)),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: Common.weight2,
                        color: Common.secondary,
                        fontFamily: 'bold',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                SvgPicture.asset('assets/Icons/location.svg', width: 24, height: 24, color: Color(0xFF58DE71),),
                SizedBox(width: 16,),
                Text(context.l10n.pickup, style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight2, fontFamily: 'bold',),),
              ],
            ),
            SizedBox(height: 2,),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // ensures vertical stretch
                children: [
                  Container(
                    width: 24,
                    child: Center(
                      child: Container(
                        width: 1,
                        color: Common.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // optional spacing
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        // (order['pickupAddress'] ?? context.l10n.pickupNA).toString(),
                        (widget.order['sellerAddress'] ?? context.l10n.pickupNA).toString(),
                        style: TextStyle(fontSize: 12, fontWeight: Common.weight, color: Common.light),
                        softWrap: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 8,)
                ],
              ),
            ),
            SizedBox(height: 2,),
            Row(
              children: [
                SvgPicture.asset('assets/Icons/location.svg', width: 24, height: 24, color: Color(0xFFED9D60),),
                SizedBox(width: 16,),
                Text(context.l10n.drop, style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight2, fontFamily: 'bold',),),
              ],
            ),
            SizedBox(height: 2,),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 8),
                child: Text(
                  // order['deliveryAddress'] ?? context.l10n.dropNA,
                  widget.order['address'] ?? context.l10n.dropNA,
                  style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight, color: Common.light),
                  softWrap: true,
                ),
              ),
            ),
            SizedBox(height: 12,),
            Row(
              children: [
                SizedBox(width: 5,),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.cartValue, style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight2, color: Common.secondary, fontFamily: 'bold'),),
                      SizedBox(height: 3,),
                      // Show cart value + commission = coupon total format
                      Text(
                        '₹$cartValue + ₹$commission = ₹$couponTotal',
                        style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight, color: Colors.green,),
                      ),
                      SizedBox(height: 3,),
                      Text(
                        context.l10n.commissionAmount('$commission'),
                        style: TextStyle(fontSize: Common.h3, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [

                      // VIEW MAP button
                      ElevatedButton.icon(
                        onPressed: () async {
                          final pickup = Uri.encodeComponent(widget.order['sellerAddress'] ?? '');
                          final drop = Uri.encodeComponent(widget.order['address'] ?? '');

                          final googleMapsUrl = "https://www.google.com/maps/dir/?api=1&origin=$pickup&destination=$drop&travelmode=driving";

                          if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
                          await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
                          } else {
                          getSnackBar(context, context.l10n.couldNotOpenMaps, Colors.red, 2);
                          }
                          // showTimedSnackBar(context, "Map opened.", Duration(seconds: 2), 'below');
                        },
                        icon: Icon(Icons.location_on_rounded, size: 16),
                        label: Text(
                          context.l10n.viewMap,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Common.h4,
                            fontWeight: Common.weight,
                            fontFamily: 'bold',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Common.primary,
                          padding: const EdgeInsets.only(left: 10, right: 14, top: 10, bottom: 10),
                          minimumSize: const Size(10, 38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                        ),
                      ),

                      _isAccepting
                          ? ElevatedButton.icon(
                        onPressed: _acceptOrder,
                        // icon: Icon(Icons.check_circle_rounded, size: 16),
                        label: Container(
                          height: 20,
                          width: 20,
                          padding: EdgeInsets.all(3),
                          child: SizedBox(child: CircularProgressIndicator(color: Common.primary, strokeWidth: 2.5,)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BB5E),
                          foregroundColor: Common.primary,
                          padding: const EdgeInsets.only(left: 12, right: 15, top: 10, bottom: 10),
                          minimumSize: const Size(10, 38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                        ),
                      )
                          : ElevatedButton.icon(
                        onPressed: _acceptOrder,
                        icon: Icon(Icons.check_circle_rounded, size: 16),
                        label: Text(
                          context.l10n.accept,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Common.h4,
                            fontWeight: Common.weight,
                            fontFamily: 'bold',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BB5E),
                          foregroundColor: Common.primary,
                          padding: const EdgeInsets.only(left: 12, right: 15, top: 10, bottom: 10),
                          minimumSize: const Size(10, 38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                        ),
                      )

                    ],
                  ),
                ),
                // SizedBox(width: 16,),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  // const _OrderCard({
  //   super.key,
  // });
  final Map<String, dynamic> order;
  final String vehicleType;
  final String cityName;
  final String name;
  final String email;
  final String phoneNumber;
  final String riderDomain;
  final String uniqueRiderOtp;
  final String userStatus;
  final String active;
  final String riderId;
  final String licence;
  final String qrcode;
  final String endpointPost;

  final Future<void> Function()? onOrderAccepted;

  const _OrderCard({Key? key, required this.order, required this.phoneNumber, required this.email, required this.name, required this.active, required this.cityName, required this.licence, required this.qrcode, required this.riderDomain, required this.riderId, required this.uniqueRiderOtp, required this.userStatus, required this.vehicleType, required this.endpointPost, required this.onOrderAccepted,}) : super(key: key);

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _isAccepting = false;

  String formatIndianDate(String input) {
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

  Future<void> _acceptOrder() async {
    setState(() => _isAccepting = true);
    final accepted = await _acceptIncomingOrder(context, widget.order, widget.endpointPost);
    if (mounted) setState(() => _isAccepting = false);
    if (accepted && widget.onOrderAccepted != null) {
      await Future.delayed(Duration(milliseconds: 500));
      await widget.onOrderAccepted!();
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
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: OrderTypeIcon(orderType: widget.order['orderType'] ?? ''),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      formatIndianDate(widget.order['pickupTime']?.toString() ?? ''),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: Common.weight2,
                        color: Common.secondary,
                        fontFamily: 'bold',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                SvgPicture.asset('assets/Icons/location.svg', width: 24, height: 24, color: Color(0xFF58DE71),),
                SizedBox(width: 16,),
                Text(context.l10n.pickup, style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight2, fontFamily: 'bold',),),
              ],
            ),
            SizedBox(height: 2,),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // ensures vertical stretch
                children: [
                  Container(
                    width: 24,
                    child: Center(
                      child: Container(
                        width: 1,
                        color: Common.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // optional spacing
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        (widget.order['pickupAddress'] ?? context.l10n.pickupNA).toString(),
                        style: TextStyle(fontSize: 12, fontWeight: Common.weight, color: Common.light),
                        softWrap: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 8,)
                ],
              ),
            ),
            SizedBox(height: 2,),
            Row(
              children: [
                SvgPicture.asset('assets/Icons/location.svg', width: 24, height: 24, color: Color(0xFFED9D60),),
                SizedBox(width: 16,),
                Text(context.l10n.drop, style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight2, fontFamily: 'bold',),),
              ],
            ),
            SizedBox(height: 2,),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 8),
                child: Text(
                  widget.order['deliveryAddress'] ?? context.l10n.dropNA,
                  style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight, color: Common.light),
                  softWrap: true,
                ),
              ),
            ),
            SizedBox(height: 16,),
            Row(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 5,),
                      Text(context.l10n.tripDistance, style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight2, color: Common.secondary, fontFamily: 'bold'),),
                      SizedBox(width: 10,),
                      Container(color: Common.light, height: 1, width: 10,),
                      SizedBox(width: 10,),
                      Text(widget.order['distance'] ?? context.l10n.distanceNA, style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight, color: Common.light),),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 5),

                // TOTALs section
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.total,
                        style: TextStyle(
                            fontSize: Common.h3, fontWeight: Common.weight2, color: Common.secondary, fontFamily: 'bold'
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '₹${widget.order['expectedPrice'] ?? '0'}',
                        style: TextStyle(
                          fontSize: Common.h2,
                          fontWeight: Common.weight,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                // Buttons section
                Expanded(
                  flex: 3,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [

                      // VIEW MAP button
                      ElevatedButton.icon(
                        onPressed: () async {
                          final pickup = Uri.encodeComponent(widget.order['pickupAddress'] ?? '');
                          final drop = Uri.encodeComponent(widget.order['deliveryAddress'] ?? '');

                          final googleMapsUrl = "https://www.google.com/maps/dir/?api=1&origin=$pickup&destination=$drop&travelmode=driving";

                          if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
                            await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
                          } else {
                            getSnackBar(context, context.l10n.couldNotOpenMaps, Colors.red, 2);
                          }
                        },
                        icon: Icon(Icons.location_on_rounded, size: 16),
                        label: Text(
                          context.l10n.viewMap,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Common.h4,
                            fontWeight: Common.weight,
                            fontFamily: 'bold',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Common.primary,
                          padding: const EdgeInsets.only(left: 10, right: 14, top: 10, bottom: 10),
                          minimumSize: const Size(10, 38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                        ),
                      ),

                      _isAccepting
                          ? ElevatedButton.icon(
                        onPressed: _acceptOrder,
                        // icon: Icon(Icons.check_circle_rounded, size: 16),
                        label: Container(
                          height: 20,
                          width: 20,
                          padding: EdgeInsets.all(3),
                          child: SizedBox(child: CircularProgressIndicator(color: Common.primary, strokeWidth: 2.5,)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BB5E),
                          foregroundColor: Common.primary,
                          padding: const EdgeInsets.only(left: 12, right: 15, top: 10, bottom: 10),
                          minimumSize: const Size(10, 38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                        ),
                      )
                          : ElevatedButton.icon(
                        onPressed: _acceptOrder,
                        icon: Icon(Icons.check_circle_rounded, size: 16),
                        label: Text(
                          context.l10n.accept,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Common.h4,
                            fontWeight: Common.weight,
                            fontFamily: 'bold',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BB5E),
                          foregroundColor: Common.primary,
                          padding: const EdgeInsets.only(left: 12, right: 15, top: 10, bottom: 10),
                          minimumSize: const Size(10, 38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                        ),
                      )
                    ],
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

class OrderCardShimmer extends StatelessWidget {
  const OrderCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Common.primary,
      elevation: 5,
      child: Shimmer.fromColors(
        highlightColor: Colors.grey.shade300,
        baseColor: Common.primary,
        // baseColor: Common.secondary,
        // highlightColor: Common.primary,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(width: 100, height: 10, color: Common.secondary),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Container(width: 24, height: 24, color: Common.secondary),
                const SizedBox(width: 16),
                Container(width: 60, height: 10, color: Common.secondary),
              ]),
              const SizedBox(height: 8),
              Container(width: double.infinity, height: 10, color: Common.secondary),
              const SizedBox(height: 8),
              Container(width: double.infinity, height: 10, color: Common.secondary),
              const SizedBox(height: 16),
              Row(children: [
                Container(width: 24, height: 24, color: Common.secondary),
                const SizedBox(width: 16),
                Container(width: 60, height: 10, color: Common.secondary),
              ]),
              const SizedBox(height: 8),
              Container(width: double.infinity, height: 10, color: Common.secondary),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(height: 10, color: Common.secondary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(height: 10, color: Common.secondary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(width: 60, height: 24, color: Common.secondary),
                  const SizedBox(width: 16),
                  Container(width: 60, height: 24, color: Common.secondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
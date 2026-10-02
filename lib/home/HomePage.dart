import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../global/Common.dart';
import '../providers/trip_provider.dart';
import '../utils/show_exit_dialog.dart';
import 'TripFlowPage.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String vehicleType;
  late String cityName;
  late String email;
  List<dynamic> _orders = [];
  // Removed selectedStatus and category logic
  bool _isLoading = true;
  String endpointPost = '';
  Timer? _timer;
  final ScrollController _scrollController = ScrollController();

  void filterRidesAuto() async {
    final filtered = await _fetchAllBookings();
    if (!mounted) return;
    setState(() {
      _orders = _sortOrdersByLatest(filtered);
    });
    _scrollToTop();
  }

  void filterRides() async {
    final filtered = await _fetchAllBookings();
    setState(() {
      _orders = _sortOrdersByLatest(filtered);
      _isLoading = false;
    });
    _scrollToTop();
  }

  List<dynamic> _sortOrdersByLatest(List<dynamic> orders) {
    orders.sort((a, b) {
      final aTime = DateTime.tryParse(a['pickupTime'] ?? a['createdAt'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = DateTime.tryParse(b['pickupTime'] ?? b['createdAt'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return orders;
  }

  Future<List<dynamic>> _fetchAllBookings() async {
    await _loadSharedPrefs();
    const orderKey = 'data';
    Map<String, dynamic> payload = {'email': email};
    final endpoints = [
      {'endpoint': 'api/rider/riderorderhistory', 'type': 'Rider Orders', 'post': 'api/rider/setriderstatus'},
      {'endpoint': 'api/parcel/riderorderhistory', 'type': 'Parcel Orders', 'post': 'api/parcel/setriderstatus'},
      {'endpoint': 'api/digiorder/orderStatus', 'type': 'Digistall Orders', 'post': 'api/digiorder/setorderStatus'},
    ];
    List<dynamic> allOrders = [];
    for (var ep in endpoints) {
      final url = Uri.parse('${Common.baseUrl}${ep['endpoint']}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final orders = data[orderKey];
        if (orders is List) {
          for (var o in orders) {
            o['orderType'] = ep['type'];
            o['endpointPost'] = ep['post'];
            allOrders.add(o);
          }
        }
      }
    }
    return allOrders;
  }

  Future<void> _loadSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    vehicleType = prefs.getString('vehicleType') ?? '';
    cityName = prefs.getString('cityName') ?? '';
    email = prefs.getString('email') ?? '';
  }

  Future<void> checkNotificationPermission(BuildContext context) async {

    var status = await Permission.notification.status;

    if (status.isGranted) {
      return;
    }

    // 👇 Request permission (this will show the system permission popup if possible)
    var result = await Permission.notification.request();

    // 👉 Only handle the case where the permission was asked and user denied it
    if (result.isDenied) {
      // Delay the dialog until the frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showStyledPermissionDialog(
          context: context,
          title: "Notification Permission Needed",
          message: "We use notifications to alert you about important updates. Please enable permission.",
          // showSettingsButton: result.isPermanentlyDenied, // only show settings if needed
        );
      });
    }
  }

  void showStyledPermissionDialog({
    required BuildContext context,
    required String title,
    required String message,
    // bool showSettingsButton = true,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Common.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: EdgeInsets.only(top: 20, left: 24, right: 24),
        contentPadding: EdgeInsets.only(left: 24, right: 24, top: 14, bottom: 24),
        actionsPadding: EdgeInsets.only(right: 16, bottom: 16),
        title: Text(
          title,
          style: TextStyle(fontWeight: Common.weight2, fontFamily: 'bold', fontSize: 18, color: Common.primary),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Text(message, style: TextStyle(fontWeight: Common.weight2, fontFamily: 'bold', fontSize: Common.h2, color: Common.primary)),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: Common.primary,
              side: BorderSide(color: Common.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: Text("Close", style: TextStyle(color: Common.secondary, fontFamily: 'bold',fontSize: Common.h2, fontWeight: Common.weight2)),
          ),
        ],
      ),
    );
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAllBookings().then((orders) {
      setState(() {
        _orders = _sortOrdersByLatest(orders);
        _isLoading = false;
      });
      _scrollToTop();
    });
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      filterRidesAuto();
    });
    checkNotificationPermission(context);
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when widget is disposed
    super.dispose();
  }

  Future<bool> logout() async {
    final screenWidth = MediaQuery.of(context).size.width;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Common.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            titlePadding: const EdgeInsets.only(
              top: 20,
              left: 24,
              right: 24,
              bottom: 15,
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 15),
            actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
            title: Text(
              "Exit App",
              style: TextStyle(
                fontWeight: Common.weight,
                color: Common.primary,
                fontSize: Common.title,
              ),
            ),
            content: SizedBox(
              width: screenWidth * 0.9,
              child: Text(
                "Are you sure you want to exit?",
                style: TextStyle(
                  color: Common.primary,
                  fontWeight: Common.weight,
                  fontSize: Common.h2,
                ),
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Common.primary.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Common.primary,
                    fontWeight: Common.weight,
                    fontSize: Common.h2,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Common.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  "Exit",
                  style: TextStyle(
                    color: Common.secondary,
                    fontWeight: Common.weight,
                    fontSize: Common.h2,
                  ),
                ),
              ),
            ],
          ),
    );

    return shouldExit ?? false;
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
                  'assets/Icons/home1.svg',
                  color: Common.primary,
                  width: 25,
                  height: 25,
                ),
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap:
                  () async => {
                    setState(() {
                      _isLoading = true;
                    }),
                    filterRides(),
                  },
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Image.asset(
                  'assets/Icons/refresh.png',
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ],
          title: Text(
            'Home',
            style: TextStyle(fontSize: Common.title, fontFamily: Common.family,color: Common.primary),
          ),
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.only(right: 12.0, left: 12.0, top: 8),
            child: Column(
              children: [
                // Removed category filter buttons
                Expanded(
                  child:
                      _isLoading
                          ? ListView.builder(
                            itemCount: 3,
                            itemBuilder: (_, __) => const OrderCardShimmer(),
                          )
                          : _orders.isEmpty
                          ? Center(
                            child: SizedBox(
                              height: 220,
                              width: double.infinity,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Lottie.asset(
                                    'assets/animation/empty2.json',
                                    height: 200,
                                  ),
                                  Positioned(
                                    bottom: 30,
                                    child: Text(
                                      'Nothing here yet',
                                      style: TextStyle(
                                        fontSize: Common.h2,
                                        color: Colors.grey,
                                        fontWeight: Common.weight,
                                        fontFamily: 'bold',
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : RefreshIndicator(
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
                              controller: _scrollController,
                              itemCount: _orders.length + 1,
                              itemBuilder: (context, index) {
                                if (index == _orders.length)
                                  return const SizedBox(height: 8);
                                final order = _orders[index];
                                if (order['orderType'] == 'Digistall Orders') {
                                  return _DigistallOrderCard(
                                    order: order,
                                    endpointPost: order['endpointPost'] ?? '',
                                  );
                                } else if (order['orderType'] == 'Rider Orders' || order['orderType'] == 'Parcel Orders') {
                                  return _OrderCard(
                                    order: order,
                                    endpointPost: order['endpointPost'] ?? '',
                                  );
                                } else {
                                  return SizedBox.shrink();
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

  // Removed buildStatusFilterButton
}

class _DigistallOrderCard extends StatelessWidget {
  // const _DigistallOrderCard({
  //   super.key,
  // });
  final Map<String, dynamic> order;
  final String endpointPost;
  // Commission is derived from coupontotal (String) - totalCartValue (int)

  const _DigistallOrderCard({
    Key? key,
    required this.order,
    required this.endpointPost,
  }) : super(key: key);

  int _getCartValue() {
    final value = order['totalCartValue'];
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String _getCouponTotal() {
    final couponTotal = order['coupontotal'];
    if (couponTotal is String) return couponTotal;
    if (couponTotal is int) return couponTotal.toString();
    // Fallbacks similar to IncomingBookingPage
    final expectedPrice = order['expectedPrice'];
    if (expectedPrice is int) return expectedPrice.toString();
    if (expectedPrice is String) return expectedPrice;
    final adminCommission = order['adminCommission'];
    final cart = _getCartValue();
    if (adminCommission is int) return (cart + adminCommission).toString();
    if (adminCommission is String) {
      final admin = int.tryParse(adminCommission) ?? 0;
      return (cart + admin).toString();
    }
    return cart.toString();
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


  @override
  Widget build(BuildContext context) {
    final cartValue = _getCartValue();
    final couponTotalStr = _getCouponTotal();
    int commission = 0;
    try {
      commission = int.parse(couponTotalStr) - cartValue;
    } catch (_) {
      commission = 0;
    }
    final total = cartValue + commission;
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
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
                      child: OrderTypeIcon(orderType: 'Digistall Orders'),
                    ),
                    // if(endpointPost=='api/parcel/setriderstatus')
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        'Order #${order['_id']?.toString().substring(0, 8) ?? ''}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: Common.weight2,
                          color: Common.light,
                          fontFamily: 'bold',
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),

                    Expanded(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          '${getFormattedDeliveryTime(order)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: Common.weight2,
                            color: Common.secondary,
                            fontFamily: 'bold',
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),


                Divider(color: Common.light, thickness: 0.09,),
                SizedBox(height: 5),

                // SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Product - ${order['productName'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: Common.h2,
                            fontWeight: Common.weight2,
                            color: Common.secondary,
                            fontFamily: 'bold',
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          'Quantity - ${order['productCount']?.toString() ?? 'Unknown'}',
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
                    ),
                  ],
                ),
                SizedBox(height: 16),

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
                        fontWeight: Common.weight2,
                        fontFamily: 'bold',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
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
                            // (order['pickupAddress'] ?? 'Pickup N/A').toString(),
                            (order['sellerAddress'] ?? 'Pickup N/A').toString(),
                            style: TextStyle(
                              fontSize: 12,
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
                SizedBox(height: 2),
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
                        fontWeight: Common.weight2,
                        fontFamily: 'bold',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40.0, right: 8),
                    child: Text(
                      // order['deliveryAddress'] ?? 'Drop N/A',
                      order['address'] ?? 'Drop N/A',
                      style: TextStyle(
                        fontSize: Common.h3,
                        fontWeight: Common.weight,
                        color: Common.light,
                      ),
                      softWrap: true,
                    ),
                  ),
                ),
                SizedBox(height: 12,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 5),

                    // Cart Value Section
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CART VALUE',
                            style: TextStyle(
                              fontSize: Common.h3,
                              fontWeight: Common.weight2,
                              color: Common.secondary,
                              fontFamily: 'bold'
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Show cart value + commission = coupon total
                          Text(
                            '₹$cartValue + ₹$commission = ₹$couponTotalStr',
                            style: TextStyle(
                              fontSize: Common.h2,
                              fontWeight: Common.weight,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Total: ₹$total',
                            style: TextStyle(
                              fontSize: Common.h3,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // View Details / Progress Button
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FutureBuilder<bool>(
                          future: tripProvider.hasTripProgress(
                            "trip_${order['_id']}",
                          ),
                          builder: (context, snapshot) {
                            final bool showProgress = snapshot.data == true;

                            return ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                      (context) => TripFlowPage(
                                        tripId: "trip_${order['_id']}",
                                        order: order,
                                        endpointPost: endpointPost,
                                      ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    showProgress
                                        ? Colors.black
                                        : const Color(0xFF008BE1),
                                foregroundColor: Common.primary,
                                elevation: 4,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                minimumSize: const Size(10, 38),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      showProgress
                                          ? 'PROGRESS'
                                          : 'VIEW DETAILS',
                                      style: TextStyle(
                                        fontSize: Common.h4,
                                        fontWeight: Common.weight,
                                        fontFamily: 'bold',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  showProgress
                                      ? Container(
                                        height: 24,
                                        width: 24,
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child:
                                            SpinningLottie(), // your animation widget
                                      )
                                      : SvgPicture.asset(
                                        'assets/Icons/view_detail_arrow.svg',
                                        color: Colors.white,
                                        height: 20,
                                        width: 20,
                                      ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  // const _OrderCard({
  //   super.key,
  // });
  final Map<String, dynamic> order;
  final String endpointPost;

  const _OrderCard({Key? key, required this.order, required this.endpointPost})
    : super(key: key);
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

  String _getOrderType(String endpointPost) {
    if (endpointPost == 'api/rider/setriderstatus') return 'Rider Orders';
    if (endpointPost == 'api/parcel/setriderstatus') return 'Parcel Orders';
    if (endpointPost == 'api/digiorder/setorderStatus') return 'Digistall Orders';
    return '';
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
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
                      child: OrderTypeIcon(orderType: _getOrderType(endpointPost)),
                    ),
                    // if(endpointPost=='api/parcel/setriderstatus')
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        'Order #${order['_id']?.toString().substring(0, 8) ?? ''}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: Common.weight2,
                          color: Common.light,
                          fontFamily: 'bold',
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),

                    Expanded(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          formatIndianDate(order['pickupTime']?.toString() ?? ''),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: Common.weight2,
                            color: Common.secondary,
                            fontFamily: 'bold',
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                
                Divider(color: Common.light, thickness: 0.09,),
                SizedBox(height: 5),

                // SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Name',
                              style: TextStyle(
                                fontSize: Common.h2,
                                fontWeight: Common.weight2,
                                color: Common.secondary,
                                fontFamily: 'bold',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          SizedBox(height: 2,),

                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '${order['sellerName'] ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: Common.h2,
                                fontWeight: Common.weight2,
                                color: Common.light,
                                fontFamily: 'bold',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Contact',
                              style: TextStyle(
                                fontSize: Common.h2,
                                fontWeight: Common.weight2,
                                color: Common.secondary,
                                fontFamily: 'bold',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          SizedBox(height: 2,),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '${order['sellerPhone']?.toString() ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: Common.h2,
                                fontWeight: Common.weight2,
                                color: Common.light,
                                fontFamily: 'bold',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
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
                        fontWeight: Common.weight2,
                        fontFamily: 'bold',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
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
                            (order['pickupAddress'] ?? 'Pickup N/A').toString(),
                            style: TextStyle(
                              fontSize: 12,
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
                SizedBox(height: 2),
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
                        fontWeight: Common.weight2,
                        fontFamily: 'bold',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40.0, right: 8),
                    child: Text(
                      order['deliveryAddress'] ?? 'Drop N/A',
                      style: TextStyle(
                        fontSize: Common.h3,
                        fontWeight: Common.weight,
                        color: Common.light,
                      ),
                      softWrap: true,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 5),
                          Text(
                            'TRIP DISTANCE',
                            style: TextStyle(
                              fontSize: Common.h3,
                              fontWeight: Common.weight2,
                              color: Common.secondary,
                              fontFamily: 'bold'
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(color: Common.light, height: 1, width: 10),
                          SizedBox(width: 10),
                          Text(
                            order['distance'] ?? 'Distance N/A',
                            style: TextStyle(
                              fontSize: Common.h2,
                              fontWeight: Common.weight,
                              color: Common.light,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 5),

                    // Cart Value Section
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL',
                            style: TextStyle(
                              fontSize: Common.h3,
                              fontWeight: Common.weight2,
                              color: Common.secondary,
                              fontFamily: 'bold',
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '₹ ${order['expectedPrice'] ?? '0'}',
                            style: TextStyle(
                              fontSize: Common.h2,
                              fontWeight: Common.weight,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // View Details / Progress Button
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FutureBuilder<bool>(
                          future: tripProvider.hasTripProgress(
                            "trip_${order['_id']}",
                          ),
                          builder: (context, snapshot) {
                            final bool showProgress = snapshot.data == true;

                            return ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => TripFlowPage(
                                          tripId: "trip_${order['_id']}",
                                          order: order,
                                          endpointPost: endpointPost,
                                        ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    showProgress
                                        ? Colors.black
                                        : const Color(0xFF008BE1),
                                foregroundColor: Common.primary,
                                elevation: 4,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                minimumSize: const Size(10, 38),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      showProgress
                                          ? 'PROGRESS'
                                          : 'VIEW DETAILS',
                                      style: TextStyle(
                                        fontSize: Common.h4,
                                        fontWeight: Common.weight,
                                        fontFamily: 'bold',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  showProgress
                                      ? Container(
                                        height: 24,
                                        width: 24,
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child:
                                            SpinningLottie(), // your animation widget
                                      )
                                      : SvgPicture.asset(
                                        'assets/Icons/view_detail_arrow.svg',
                                        color: Colors.white,
                                        height: 20,
                                        width: 20,
                                      ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
                child: Container(
                  width: 100,
                  height: 10,
                  color: Common.secondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(width: 24, height: 24, color: Common.secondary),
                  const SizedBox(width: 16),
                  Container(width: 60, height: 10, color: Common.secondary),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 10,
                color: Common.secondary,
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 10,
                color: Common.secondary,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(width: 24, height: 24, color: Common.secondary),
                  const SizedBox(width: 16),
                  Container(width: 60, height: 10, color: Common.secondary),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 10,
                color: Common.secondary,
              ),
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

class SpinningLottie extends StatefulWidget {
  @override
  _SpinningLottieState createState() => _SpinningLottieState();
}

class _SpinningLottieState extends State<SpinningLottie>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animation/progress.json',
      controller: _controller,
    );
  }
}

// Widget to show the correct icon for Rider, Parcel, or Digistall order
class OrderTypeIcon extends StatelessWidget {
  final String orderType;
  const OrderTypeIcon({Key? key, required this.orderType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (orderType) {
      case 'Rider Orders':
        return SvgPicture.asset('assets/Icons/bike-svgrepo-com.svg', width: 28, height: 28, color: Color(0xFF008BE1));
      case 'Parcel Orders':
        return Image.asset('assets/Icons/activity.png', width: 28, height: 28, color: Color(0xFF58DE71));
      case 'Digistall Orders':
        return SvgPicture.asset('assets/Icons/store-svgrepo-com.svg', width: 28, height: 28, color: Colors.green);
      default:
        return Icon(Icons.local_shipping, size: 28);
    }
  }
}

// Future<bool> _hasTripProgress(String tripId) async {
//   final prefs = await SharedPreferences.getInstance();
//   final index = prefs.getInt('trip_stage_$tripId');
//   return index != null && index != TripStage.reachPickup.index;
// }

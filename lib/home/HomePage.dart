import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../global/Common.dart';
import '../global/l10n.dart';
import '../providers/trip_provider.dart';
import '../services/active_orders.dart';
import '../utils/show_exit_dialog.dart';
import 'TripFlowPage.dart';

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
    final hasNewOrders = filtered.length > _orders.length;
    setState(() {
      _orders = _sortOrdersByLatest(filtered);
    });
    // Only jump to the top when a new order shows up, not on every poll.
    if (hasNewOrders) _scrollToTop();
  }

  void filterRides() async {
    final filtered = await _fetchAllBookings();
    if (!mounted) return;
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
    final orders = await ActiveOrders.fetch(email);
    if (mounted) {
      // Keep the accept limit in sync with what the server says is still active.
      await Provider.of<TripProvider>(context, listen: false).setActiveOrdersCount(orders.length);
    }
    return orders;
  }

  Future<void> _loadSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    vehicleType = prefs.getString('vehicleType') ?? '';
    cityName = prefs.getString('cityName') ?? '';
    email = prefs.getString('email') ?? '';
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
      if (!mounted) return;
      setState(() {
        _orders = _sortOrdersByLatest(orders);
        _isLoading = false;
      });
      _scrollToTop();
    });
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      filterRidesAuto();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when widget is disposed
    _scrollController.dispose();
    super.dispose();
  }

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
            context.l10n.home,
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
                                      context.l10n.nothingHereYet,
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
                        context.l10n.orderNumber(order['_id']?.toString().substring(0, 8) ?? ''),
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
                          '${getFormattedDeliveryTime(context, order)}',
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
                          context.l10n.productLabel(order['productName']?.toString() ?? context.l10n.unknown),
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
                          context.l10n.quantityLabel(order['productCount']?.toString() ?? context.l10n.unknown),
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
                      context.l10n.pickup,
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
                            // (order['pickupAddress'] ?? context.l10n.pickupNA).toString(),
                            (order['sellerAddress'] ?? context.l10n.pickupNA).toString(),
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
                      context.l10n.drop,
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
                      // order['deliveryAddress'] ?? context.l10n.dropNA,
                      order['address'] ?? context.l10n.dropNA,
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
                            context.l10n.cartValue,
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
                            context.l10n.totalAmountValue('$total'),
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
                            final bool showProgress = snapshot.data == true ||
                                order['riderStatus']?.toString().toLowerCase() == 'in transit';

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
                                          ? context.l10n.progress
                                          : context.l10n.viewDetails,
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
                        context.l10n.orderNumber(order['_id']?.toString().substring(0, 8) ?? ''),
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
                          formatIndianDate(context, order['pickupTime']?.toString() ?? ''),
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
                              context.l10n.name,
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
                              '${order['sellerName'] ?? context.l10n.unknown}',
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
                              context.l10n.contact,
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
                              '${order['sellerPhone']?.toString() ?? context.l10n.unknown}',
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
                      context.l10n.pickup,
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
                            (order['pickupAddress'] ?? context.l10n.pickupNA).toString(),
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
                      context.l10n.drop,
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
                      order['deliveryAddress'] ?? context.l10n.dropNA,
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
                            context.l10n.tripDistance,
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
                            order['distance'] ?? context.l10n.distanceNA,
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
                            context.l10n.total,
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
                            final bool showProgress = snapshot.data == true ||
                                order['riderStatus']?.toString().toLowerCase() == 'in transit';

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
                                          ? context.l10n.progress
                                          : context.l10n.viewDetails,
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

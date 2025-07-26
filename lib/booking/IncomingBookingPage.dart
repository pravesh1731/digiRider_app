import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../global/Common.dart';
import 'package:http/http.dart' as http;

import '../providers/NotificationProvider.dart';
import '../providers/trip_provider.dart';
import '../utils/_TimedSnackBar.dart';
import '../utils/bottomSnackBar.dart';
import '../utils/show_exit_dialog.dart';

class IncomingBookingPage extends StatefulWidget {
  const IncomingBookingPage({super.key});

  @override
  State<IncomingBookingPage> createState() => _IncomingBookingPageState();
}

class _IncomingBookingPageState extends State<IncomingBookingPage> {

  late String vehicleType;
  late String cityName;
  late String name;
  late String email;
  late String phoneNumber;
  late String riderDomain;
  late String uniqueRiderOtp;
  late String userStatus;
  late String active;
  late String riderId;
  late String licence;
  late String qrcode;
  List<dynamic> _orders = [];
  String selectedStatus = 'Rider Orders'; // default
  bool _isLoading = true;
  String endpointPost = '';
  Timer? _timer;

  void filterRidesAuto() async {
    final filtered = await _fetchBookings(selectedStatus);

    if (!mounted) return; // Prevents calling setState on disposed widget

    setState(() {
      _orders = filtered;
    });
  }


  void filterRides({bool delayed = false}) async {
    setState(() {
      _isLoading = true;
    });

    final filtered = await _fetchBookings(selectedStatus);

    if (delayed) {
      await Future.delayed(Duration(seconds: 1));
    }

    setState(() {
      _orders = filtered;
      _isLoading = false;
    });
  }


  Future<List<dynamic>> _fetchBookings(String status) async {
    await _loadSharedPrefs();

    String endpoint = '';
    String order = '';
    if (status == 'Rider Orders') endpoint = 'api/rider/dashboard?vehicleType=$vehicleType&cityName=$cityName';
    else if (status == 'Parcel Orders') endpoint = 'api/parcel/dashboard?cityName=$cityName';
    else if (status == 'Digistall Orders') endpoint = 'api/digiorder/getDigiOrder';

    if (status == 'Rider Orders') order = 'filteredOrders';
    else if (status == 'Parcel Orders') order = 'parcelOrders';
    else if (status == 'Digistall Orders') order = 'DigiOrders';

    if (status == 'Rider Orders') endpointPost = 'api/rider/acceptriderorder';
    else if (status == 'Parcel Orders') endpointPost = 'api/parcel/acceptriderorder';
    else if (status == 'Digistall Orders') endpointPost = 'api/digiorder/acceptedByRider';

    final url = Uri.parse('${Common.baseUrl}${endpoint}');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      return data[order] ?? [];
    } else {
      throw Exception('Failed to load bookings');
    }
  }



  Future<void> _loadSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    vehicleType = prefs.getString('vehicleType') ?? '';
    cityName = prefs.getString('cityName') ?? '';
    name = prefs.getString('name') ?? '';
    email = prefs.getString('email') ?? '';
    phoneNumber = prefs.getString('phoneNumber') ?? '';
    riderDomain = prefs.getString('riderDomain') ?? '';
    uniqueRiderOtp = prefs.getString('uniqueRiderOtp') ?? '';
    userStatus = prefs.getString('userStatus') ?? '';
    active = prefs.getString('active') ?? '';
    riderId = prefs.getString('riderId') ?? '';
    licence = prefs.getString('licence') ?? '';
    qrcode = prefs.getString('qrcode') ?? '';
  }

  // Future<List<dynamic>> _fetchBookings() async {
  //   await _loadSharedPrefs(); // Ensure prefs are loaded
  //   final url = Uri.parse('${Common.baseUrl}api/rider/dashboard?vehicleType=$vehicleType&cityName=$cityName');
  //
  //   final response = await http.get(url);
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     return data['filteredOrders'] ?? [];
  //   } else {
  //     throw Exception('Failed to load bookings');
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _fetchBookings(selectedStatus).then((orders) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    });
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      filterRidesAuto();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when widget is disposed
    super.dispose();
  }
  // int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showExitConfirmationDialog(context),
      child: Scaffold(
        appBar: AppBar(
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
            GestureDetector(
              onTap: () async => {
                setState(() {
                  _isLoading = true;
                }),
                filterRides(),
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Image.asset('assets/Icons/refresh.png', width: 20, height: 20,),
              ),
            ),
          ],
          title: Text('Incoming Bookings', style: TextStyle(fontSize: Common.title, fontFamily: Common.family),),
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.only(right: 12.0, left: 12.0, top: 8),
            child: Column(
              children: [
                SingleChildScrollView(
                  // padding: EdgeInsets.zero, // Removes outer padding if any
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      buildStatusFilterButton('Rider Orders'),
                      buildStatusFilterButton('Parcel Orders'),
                      buildStatusFilterButton('Digistall Orders'),
                    ],
                  ),
                ),
                SizedBox(height: 5),
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
                              'Nothing here yet',
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
                        if (selectedStatus == 'Digistall Orders') {
                          return _DigistallOrderCard(
                            order: order,
                            phoneNumber: phoneNumber, // e.g., from logged-in user or prefs
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
                            endpointPost: endpointPost,
                            onOrderAccepted: () async => filterRides(delayed: true),
                          );
                        } else {
                          return _OrderCard(
                            order: order,
                            phoneNumber: phoneNumber, // e.g., from logged-in user or prefs
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
                            endpointPost: endpointPost,
                            onOrderAccepted: () async => filterRides(delayed: true),
                          );

                        }
                      },
                    ),
                  ),
                ),


              ],
            ),
            // child: SingleChildScrollView(
            //   child: Column(
            //     children: [
            //       _OrderCard(),
            //       SizedBox(height: 8,),
            //       _OrderCard(),
            //       SizedBox(height: 8,),
            //       _OrderCard(),
            //       SizedBox(height: 8,),
            //     ],
            //   ),
            // ),
          ),
        ),

      ),
    );
  }

  Widget buildStatusFilterButton(String status) {
    final isSelected = selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(status),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _isLoading = true;
            selectedStatus = status;
          });
          filterRides();
        },
        checkmarkColor: Common.primary, // ✅ Changes the tick/check color
        selectedColor: Common.secondary,
        labelStyle: TextStyle(
          color: isSelected ? Common.primary : Common.secondary,
          fontFamily: Common.family, fontSize: Common.h3, fontWeight: Common.weight
        ),
        backgroundColor: Common.primary,
      ),
    );
  }

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

  Future<void> _acceptOrder() async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    // Check if user already has 2 active orders
    if (tripProvider.activeOrdersCount >= 2) {
      showTimedSnackBar(
          context,
          "You need to finish your current rides first",
          Duration(seconds: 3),
          'below'
      );
      return;
    }
    setState(() => _isAccepting = true);

    try {
      final uri = Uri.parse("${Common.baseUrl}${widget.endpointPost}");
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "orderId": widget.order['_id'],
          "sellerPhone": widget.order['sellerPhone'],
          "riderData": {
            "name": widget.name,
            "email": widget.email,
            "cityName": widget.cityName,
            "phoneNumber": widget.phoneNumber,
            "riderDomain": widget.riderDomain,
            "deviceToken": "", // Optional: update if using Firebase
            "vehicleType": widget.vehicleType,
            "aadhaar": "", // Or add if you store this
            "licence": widget.licence,
            "profile": "", // Or fetch if needed
            "qrcode": widget.qrcode,
            "success": true,
            "userStatus": widget.userStatus,
          }
        }),
      );

      if (response.statusCode == 200) {
        await tripProvider.incrementActiveOrders();

        showTimedSnackBar(
            context,
            "Order Accepted Successfully",
            Duration(seconds: 2),
            'below'
        );

        print(jsonDecode(response.body));
        setState(() => _isAccepting = false);
        if (context.mounted) {
          showTimedSnackBar(context, "Order Accepted Successfully.", Duration(seconds: 2), 'below');
          Provider.of<NotificationProvider>(context, listen: false).showBadge();
        }
        await Future.delayed(Duration(milliseconds: 500));
        if (widget.onOrderAccepted != null) {
          await widget.onOrderAccepted!(); // Wait for the callback including any delay
        }
      } else {
        getSnackBar(context, "Failed to accept order.", Colors.red, 2);
      }
    } catch (e) {
      debugPrint("Error accepting order: $e");
      getSnackBar(context, "Something went wrong.", Colors.red, 2);
    } finally {
      setState(() => _isAccepting = false);
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

            Align(
              child: Text(
                'Delivery By - ${getFormattedDeliveryTime(widget.order)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: Common.weight2,
                  color: Common.secondary,
                  fontFamily: 'bold',
                ),
              ),
              alignment: Alignment.topRight,
            ),
            Row(
              children: [
                SvgPicture.asset('assets/Icons/location.svg', width: 24, height: 24, color: Color(0xFF58DE71),),
                SizedBox(width: 16,),
                Text('PICKUP', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight2, fontFamily: 'bold',),),
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
                        // (order['pickupAddress'] ?? 'Pickup N/A').toString(),
                        (widget.order['sellerAddress'] ?? 'Pickup N/A').toString(),
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
                Text('DROP', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight2, fontFamily: 'bold',),),
              ],
            ),
            SizedBox(height: 2,),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 8),
                child: Text(
                  // order['deliveryAddress'] ?? 'Drop N/A',
                  widget.order['address'] ?? 'Drop N/A',
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
                      Text('CART VALUE', style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight2, color: Common.secondary, fontFamily: 'bold'),),
                      SizedBox(height: 3,),
                      Text('₹${widget.order['totalCartValue'] ?? '0'}', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight, color: Colors.green,),)
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
                          getSnackBar(context, "Could not open Maps.", Colors.red, 2);
                          }
                          // showTimedSnackBar(context, "Map opened.", Duration(seconds: 2), 'below');
                        },
                        icon: Icon(Icons.location_on_rounded, size: 16),
                        label: Text(
                          'VIEW MAP',
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
                          'ACCEPT',
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

  Future<void> _acceptOrder() async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    if (tripProvider.activeOrdersCount >= 2) {
      showTimedSnackBar(
          context,
          "You need to finish your current rides first",
          Duration(seconds: 3),
          'below'
      );
      return;
    }

    setState(() => _isAccepting = true);

    try {
      final uri = Uri.parse("${Common.baseUrl}${widget.endpointPost}");
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "orderId": widget.order['_id'],
          "sellerPhone": widget.order['sellerPhone'],
          "riderData": {
            "name": widget.name,
            "email": widget.email,
            "cityName": widget.cityName,
            "phoneNumber": widget.phoneNumber,
            "riderDomain": widget.riderDomain,
            "deviceToken": "", // Optional: update if using Firebase
            "vehicleType": widget.vehicleType,
            "aadhaar": "", // Or add if you store this
            "licence": widget.licence,
            "profile": "", // Or fetch if needed
            "qrcode": widget.qrcode,
            "success": true,
            "userStatus": widget.userStatus,
          }
        }),
      );

      if (response.statusCode == 200) {
        print(jsonDecode(response.body));
        await tripProvider.incrementActiveOrders();

        showTimedSnackBar(
            context,
            "Order Accepted Successfully",
            Duration(seconds: 2),
            'below'
        );

        setState(() => _isAccepting = false);
        if (context.mounted) {
          showTimedSnackBar(context, "Order Accepted Successfully.",
              Duration(seconds: 2), 'below');

          // Show the badge
          Provider.of<NotificationProvider>(context, listen: false).showBadge();
        }
        await Future.delayed(Duration(milliseconds: 500));
        if (widget.onOrderAccepted != null) {
          await widget.onOrderAccepted!();
        }
      } else {
        getSnackBar(context, "Failed to accept order.", Colors.red, 2);
      }
    } catch (e) {
      debugPrint("Error accepting order: $e");
      getSnackBar(context, "Something went wrong.", Colors.red, 2);
    } finally {
      setState(() => _isAccepting = false);
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
            Align(
              child: Text(
                formatIndianDate(widget.order['pickupTime']?.toString() ?? ''),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: Common.weight2,
                  color: Common.secondary,
                  fontFamily: 'bold',
                ),
              ),
              alignment: Alignment.topRight,
            ),
            Row(
              children: [
                SvgPicture.asset('assets/Icons/location.svg', width: 24, height: 24, color: Color(0xFF58DE71),),
                SizedBox(width: 16,),
                Text('PICKUP', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight2, fontFamily: 'bold',),),
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
                        (widget.order['pickupAddress'] ?? 'Pickup N/A').toString(),
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
                Text('DROP', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight2, fontFamily: 'bold',),),
              ],
            ),
            SizedBox(height: 2,),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 8),
                child: Text(
                  widget.order['deliveryAddress'] ?? 'Drop N/A',
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
                      Text('TRIP DISTANCE', style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight2, color: Common.secondary, fontFamily: 'bold'),),
                      SizedBox(width: 10,),
                      Container(color: Common.light, height: 1, width: 10,),
                      SizedBox(width: 10,),
                      Text(widget.order['distance'] ?? 'Distance N/A', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight, color: Common.light),),
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
                        'TOTAL',
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
                            getSnackBar(context, "Could not open Maps.", Colors.red, 2);
                          }
                        },
                        icon: Icon(Icons.location_on_rounded, size: 16),
                        label: Text(
                          'VIEW MAP',
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
                          'ACCEPT',
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
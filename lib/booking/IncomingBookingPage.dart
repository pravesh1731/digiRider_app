import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../global/Common.dart';
import 'package:http/http.dart' as http;

class IncomingBookingPage extends StatefulWidget {
  const IncomingBookingPage({super.key});

  @override
  State<IncomingBookingPage> createState() => _IncomingBookingPageState();
}

class _IncomingBookingPageState extends State<IncomingBookingPage> {

  late String vehicleType;
  late String cityName;
  List<dynamic> _orders = [];

  Future<void> _loadSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    vehicleType = prefs.getString('vehicleType') ?? '';
    cityName = prefs.getString('cityName') ?? '';
  }

  Future<List<dynamic>> _fetchBookings() async {
    await _loadSharedPrefs(); // Ensure prefs are loaded
    final url = Uri.parse('${Common.baseUrl}api/rider/dashboard?vehicleType=$vehicleType&cityName=$cityName');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['filteredOrders'] ?? [];
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchBookings().then((orders) {
      setState(() {
        _orders = orders;
      });
    });
  }
  // int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Image.asset('assets/Icons/refresh.png', width: 20, height: 20,),
          ),
        ],
        title: Text('Incoming Bookings', style: TextStyle(fontSize: Common.title, fontFamily: Common.family),),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(right: 12.0, left: 12.0, top: 12),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return _OrderCard(order: _orders[index]);
                  },
                ),
              ),
            ],
          )
          ,
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

    );
  }
}

class _OrderCard extends StatelessWidget {
  // const _OrderCard({
  //   super.key,
  // });
  final Map<String, dynamic> order;
  const _OrderCard({Key? key, required this.order}) : super(key: key);
  String formatIndianDate(String input) {
    try {
      // Parse the input string to DateTime
      final parsed = DateTime.parse(input);

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
              child: Text(formatIndianDate(order['pickupTime']), style: TextStyle(fontSize: 12, fontWeight: Common.weight, color: Common.secondary),),
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
                        order['pickupAddress'] ?? 'Pickup N/A',
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
                  order['deliveryAddress'] ?? 'Drop N/A',
                  style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight, color: Common.light),
                  softWrap: true,
                ),
              ),
            ),
            SizedBox(height: 16,),
            Row(
              children: [
                SizedBox(width: 5,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PICKUP DISTANCE', style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight, color: Common.light),),
                      SizedBox(height: 3,),
                      Text(order['pickupDistance'] ?? 'N/A', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight2, fontFamily: 'bold',),)
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TRIP DISTANCE', style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight, color: Common.light),),
                      SizedBox(height: 3,),
                      Text(order['distance'] ?? 'Distance N/A', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight2, fontFamily: 'bold',),)
                    ],
                  ),
                ),
                SizedBox(width: 16,),
              ],
            ),
            SizedBox(height: 16,),
            Row(
              children: [
                SizedBox(width: 5,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EARNING', style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight, color: Common.light),),
                    SizedBox(height: 3,),
                    Text('₹${order['expectedPrice'] ?? '0'}', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight, color: Colors.green,),)
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    Container(
                      height: 38,
                      width: MediaQuery.of(context).size.width/4.5,
                      decoration: BoxDecoration(
                        color: Color(0xFFD75656),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: Text('CANCEL', style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight, color: Common.primary),)),
                    ),
                    SizedBox(width: 14,),
                    Container(
                      height: 38,
                      width: MediaQuery.of(context).size.width/4.5,
                      decoration: BoxDecoration(
                        color: Color(0xFF00BB5E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: Text('ACCEPT', style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight, color: Common.primary),)),
                    )
                  ],
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

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../global/Common.dart';
import '../global/OrderTypeIcon.dart';
import '../home/TripFlowPage.dart';
import '../providers/trip_provider.dart';
import '../utils/show_exit_dialog.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  TextEditingController searchController = TextEditingController();
  late String vehicleType;
  late String cityName;
  late String email;
  late String phoneNumber;
  List<dynamic> _orders = [];
  bool _isLoading = true;
  // final searchFocusNode = FocusNode();
  Timer? _timer;

  void filterRidesAuto() async {
    final filtered = await _fetchAllBookings();

    if (!mounted) return; // Prevents calling setState on disposed widget

    setState(() {
      _orders = filtered;
    });
  }

  void filterRides() async {
    final filtered = await _fetchAllBookings();
    setState(() {
      _orders = filtered;
      _isLoading = false;
    });
  }

  Future<List<dynamic>> _fetchAllBookings() async {
    await _loadSharedPrefs();

    List<dynamic> allCombinedOrders = [];

    // Define all order types with their endpoints and response keys
    final orderTypes = [
      {
        'type': 'Rider Orders',
        'endpoint': 'api/rider/riderhistory?cityName=$cityName&phoneNumber=$phoneNumber',
        'responseKey': 'orderHistory',
        'serviceType': 'Rider Booking'
      },
      {
        'type': 'Parcel Orders',
        'endpoint': 'api/parcel/parcelhistory?cityName=$cityName&phoneNumber=$phoneNumber',
        'responseKey': 'parcelHistory',
        'serviceType': 'Parcel Booking'
      },
      {
        'type': 'Digistall Orders',
        'endpoint': 'api/digiorder/digiorderhistory?cityName=$cityName&phoneNumber=$phoneNumber',
        'responseKey': 'orderItemHistory',
        'serviceType': 'Digistall Booking'
      },
    ];

    // Fetch orders from all endpoints
    for (final orderType in orderTypes) {
      try {
        final url = Uri.parse('${Common.baseUrl}${orderType['endpoint']}');
        final response = await http.get(url);
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final orders = data[orderType['responseKey']] ?? [];
          
          // Filter orders to show only those where current user is in riderDetails
          final filteredOrders = orders.where((orderItem) {
            final riderDetails = orderItem['riderDetails'];
            if (riderDetails is List && riderDetails.isNotEmpty) {
              return riderDetails.any((rider) {
                final riderPhone = rider['phoneNumber']?.toString() ?? '';
                final riderEmail = rider['email']?.toString() ?? '';
                return riderPhone == phoneNumber || riderEmail == email;
              });
            }
            return false;
          }).toList();
          
          // Add order type and service type to each order
          for (var order in filteredOrders) {
            order['orderType'] = orderType['type'];
            order['serviceType'] = orderType['serviceType'];
          }
          
          allCombinedOrders.addAll(filteredOrders);
        }
      } catch (e) {
        print('Error fetching ${orderType['type']}: $e');
      }
    }

    // Sort all orders by date - latest first
    allCombinedOrders.sort((a, b) {
      try {
        String? dateA;
        String? dateB;
        
        if (a['orderType'] == 'Digistall Orders') {
          final deliveryByA = a['deliveryBy'];
          final deliveryTimeA = a['deliveryTime'];
          if (deliveryByA != null && deliveryTimeA != null) {
            dateA = '$deliveryByA $deliveryTimeA';
          } else {
            dateA = a['createdAt'] ?? a['updatedAt'];
          }
        } else {
          dateA = a['pickupTime'] ?? a['createdAt'] ?? a['updatedAt'];
        }
        
        if (b['orderType'] == 'Digistall Orders') {
          final deliveryByB = b['deliveryBy'];
          final deliveryTimeB = b['deliveryTime'];
          if (deliveryByB != null && deliveryTimeB != null) {
            dateB = '$deliveryByB $deliveryTimeB';
          } else {
            dateB = b['createdAt'] ?? b['updatedAt'];
          }
        } else {
          dateB = b['pickupTime'] ?? b['createdAt'] ?? b['updatedAt'];
        }
        
        if (dateA == null || dateB == null) return 0;
        
        final parsedA = DateTime.tryParse(dateA);
        final parsedB = DateTime.tryParse(dateB);
        
        if (parsedA == null || parsedB == null) return 0;
        
        return parsedB.compareTo(parsedA);
      } catch (e) {
        print('Date sorting error: $e');
        return 0;
      }
    });
    
    print('Total combined orders fetched: ${allCombinedOrders.length}');
    return allCombinedOrders;
  }

  Future<void> _loadSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    vehicleType = prefs.getString('vehicleType') ?? '';
    cityName = prefs.getString('cityName') ?? '';
    email = prefs.getString('email') ?? '';
    phoneNumber = prefs.getString('phoneNumber') ?? '';
  }

  @override
  void initState() {
    super.initState();
    _fetchAllBookings().then((orders) {
      setState(() {
        print(orders);
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () async {
          if (Navigator.of(context).canPop()) {
            return true;
          }
          return await showExitConfirmationDialog(context);
        },
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 60,
            backgroundColor: Common.secondary,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                child: Center(
                  child: SvgPicture.asset(
                    'assets/Icons/history.svg',
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
                  child: Image.asset('assets/Icons/refresh.png', width: 20, height: 20,
                  ),
                ),
              ),
            ],
            title: Text('History', style: TextStyle(fontSize: Common.title, fontFamily: Common.family,color: Common.primary),),
          ),
          body: Container(
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0, left: 12.0, top: 8),
              child: Column(
                children: [
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: Container(
                  //         height: 40,
                  //         width: double.infinity,
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(35),
                  //           color: Common.secondary
                  //         ),
                  //         child: Row(
                  //           crossAxisAlignment: CrossAxisAlignment.center,
                  //           children: [
                  //             SizedBox(width: 16,),
                  //             // Expanded(child: Text('Search here', style: TextStyle(fontSize: Common.h1, fontWeight: Common.weight, color: Common.light),)),
                  //             Expanded(
                  //               child: Padding(
                  //                 padding: const EdgeInsets.all(8.0),
                  //                 child: TextField(
                  //                   // focusNode: searchFocusNode,
                  //                   controller: searchController,
                  //                   style: TextStyle(
                  //                     color: Common.background,     // 👈 Text (user input) color
                  //                     fontSize: Common.h1,
                  //                     fontWeight: Common.weight,
                  //                   ),
                  //                   cursorHeight: 20,
                  //                   decoration: InputDecoration(
                  //                     border: InputBorder.none,
                  //                     hintText: 'Search here',
                  //                     hintStyle: TextStyle(
                  //                       color: Common.background,      // 👈 Hint text color
                  //                       fontSize: Common.h2,
                  //                       fontWeight: Common.weight// 👈 Hint text size
                  //                     ),
                  //                   ),
                  //                   cursorColor: Common.background,
                  //                 ),
                  //               ),
                  //             ),
                  //             SizedBox(width: 16,),
                  //             Center(child: SvgPicture.asset('assets/Icons/search.svg', color: Common.background, width: 20, height: 20,),),
                  //             SizedBox(width: 16,),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //     SizedBox(width: 12,),
                  //     Center(
                  //       child: Image.asset('assets/Icons/filter.png', width: 20, height: 20,),
                  //     ),
                  //     SizedBox(width: 6,),
                  //   ],
                  // ),
                  SizedBox(height: 8,),
                  Expanded(
                    child: _isLoading
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
                                                itemCount: _orders.length + 1,
                                                itemBuilder: (context, index) {
                          if (index == _orders.length) return const SizedBox(height: 8);
                          final order = _orders[index];
                          return _UnifiedOrderCard(order: order);
                                                },
                                              ),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnifiedOrderCard extends StatefulWidget {
  final Map<String, dynamic> order;

  const _UnifiedOrderCard({Key? key, required this.order}) : super(key: key);

  @override
  State<_UnifiedOrderCard> createState() => _UnifiedOrderCardState();
}

class _UnifiedOrderCardState extends State<_UnifiedOrderCard> {
  bool _isGenerating = false;

  String formatIndianDate(String input) {
    try {
      if (input == null || input.isEmpty) return 'Invalid Date';
      final parsed = DateTime.tryParse(input);
      if (parsed == null) return 'Invalid Date';

      final localTime = parsed.toLocal();
      final formatter = DateFormat('dd MMM yyyy, hh:mm a');
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
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
    } catch (e) {
      return 'Invalid delivery time';
    }
  }

  String getOrderDateTime() {
    final orderType = widget.order['orderType'] ?? '';
    if (orderType == 'Digistall Orders') {
      return getFormattedDeliveryTime(widget.order);
    } else {
      return formatIndianDate(widget.order['pickupTime']?.toString() ?? '');
    }
  }

  Future<void> _handleDownloadAndPrint(Map<String, dynamic> order) async {
    setState(() => _isGenerating = true);
    final pdfData = await generateRiderOrderInvoice(order);
    setState(() => _isGenerating = false);
    await Printing.layoutPdf(onLayout: (_) => pdfData);
  }

  Future<Uint8List> generateRiderOrderInvoice(Map<String, dynamic> order) async {
    final pdf = pw.Document();
    final orderType = order['orderType'] ?? '';
    final serviceType = order['serviceType'] ?? '';

    // Prepare data
    final rider = (order['riderDetails'] is List && order['riderDetails'].isNotEmpty)
        ? order['riderDetails'][0]
        : {};
    final pickup = orderType == 'Digistall Orders' ? (order['sellerAddress'] ?? '') : (order['pickupAddress'] ?? '');
    final drop = orderType == 'Digistall Orders' ? (order['address'] ?? '') : (order['deliveryAddress'] ?? '');
    final String invoiceNumber = () {
      final id = (order['_id'] ?? '').toString();
      return 'INV-${id.isNotEmpty ? id.substring(0, id.length < 8 ? id.length : 8) : 'NA'}';
    }();
    final DateTime now = DateTime.now();

    // Monetary values
    final bool isDigi = orderType == 'Digistall Orders';
    // Cart value (int) for Digistall, fare for others
    final int cartValue = isDigi
        ? ((order['totalCartValue'] is int)
            ? order['totalCartValue'] as int
            : (int.tryParse(order['totalCartValue']?.toString() ?? '0') ?? 0))
        : (int.tryParse(order['expectedPrice']?.toString() ?? '0') ?? 0);
    // Coupon total as String (preferred), with fallbacks
    String couponTotalStr = '';
    if (isDigi) {
      final ct = order['coupontotal'];
      if (ct is String) couponTotalStr = ct;
      if (couponTotalStr.isEmpty && ct is int) couponTotalStr = ct.toString();
      if (couponTotalStr.isEmpty) {
        final ep = order['expectedPrice'];
        if (ep is int) couponTotalStr = ep.toString();
        else if (ep is String) couponTotalStr = ep;
      }
      if (couponTotalStr.isEmpty) {
        final ac = order['adminCommission'];
        int acVal = 0;
        if (ac is int) acVal = ac;
        else if (ac is String) acVal = int.tryParse(ac) ?? 0;
        couponTotalStr = (cartValue + acVal).toString();
      }
    }
    int commission = 0;
    if (isDigi) {
      commission = (int.tryParse(couponTotalStr) ?? cartValue) - cartValue;
      if (commission < 0) commission = 0;
    } else {
      commission = 20; // non-digi unchanged (if needed adjust later)
    }
    final int totalAmount = isDigi ? (cartValue + commission) : cartValue;

    // Load logo
    final logoBytes = await rootBundle.load('assets/Icons/Bike.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(children: [
                      pw.Image(logoImage, width: 48, height: 48),
                      pw.SizedBox(width: 12),
                      pw.Text('DigiRider', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                    ]),
                    pw.Text('Invoice', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Divider(),
                pw.SizedBox(height: 12),
                // Invoice meta
                pw.Text('Invoice Number: $invoiceNumber', style: pw.TextStyle(fontSize: 14)),
                pw.Text('Date: ${DateFormat('yyyy-MM-dd').format(now)}', style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 6),
                if (serviceType.toString().isNotEmpty)
                  pw.Text('Service: $serviceType', style: pw.TextStyle(fontSize: 14)),
                if (rider is Map && (rider['name'] != null || rider['phoneNumber'] != null)) ...[
                  pw.SizedBox(height: 6),
                  pw.Text('Rider: ${rider['name'] ?? ''} (${rider['phoneNumber'] ?? ''})', style: pw.TextStyle(fontSize: 14)),
                ],
                pw.SizedBox(height: 18),

                // Trip Summary
                pw.Text('Trip Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                pw.SizedBox(height: 10),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(8),
                    color: PdfColors.grey100,
                  ),
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Pickup Location:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(pickup.toString()),
                      pw.SizedBox(height: 8),
                      pw.Text('Destination:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(drop.toString()),
                      pw.SizedBox(height: 8),
                      if (isDigi) ...[
                        pw.Text('Cart Value:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Rs. ${cartValue.toStringAsFixed(0)}'),
                        pw.SizedBox(height: 8),
                        pw.Text('Commission:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Rs. ${commission.toStringAsFixed(0)}'),
                        pw.SizedBox(height: 8),
                      ] else ...[
                        pw.Text('Fare:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Rs. ${cartValue.toStringAsFixed(0)}'),
                        pw.SizedBox(height: 8),
                        pw.Text('Commission:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Rs. ${commission.toStringAsFixed(0)}'),
                        pw.SizedBox(height: 8),
                      ],
                      pw.Text('Total Amount:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Rs. ${totalAmount.toStringAsFixed(0)}', style: pw.TextStyle(color: PdfColors.green800, fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),

                pw.Spacer(),
                pw.Divider(),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text('Thank you for riding with DigiRider!', style: pw.TextStyle(fontSize: 14, color: PdfColors.blue800)),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    final orderType = widget.order['orderType'] ?? '';
    
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
                OrderTypeIcon(orderType: orderType),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    orderType,
                    style: TextStyle(
                      fontSize: Common.h2,
                      fontWeight: Common.weight2,
                      color: Common.secondary,
                      fontFamily: 'bold',
                    ),
                  ),
                ),
                Text(
                  'Order #${widget.order['_id']?.toString().substring(0, 8) ?? ''}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: Common.weight2,
                    color: Common.light,
                    fontFamily: 'bold',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    getOrderDateTime(),
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
              ],
            ),
            Divider(color: Common.light, thickness: 0.09),
            SizedBox(height: 5),

            // Order-specific content
            if (orderType == 'Digistall Orders') ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Product - ${widget.order['productName'] ?? 'Unknown'}',
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
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Qty - ${widget.order['productCount']?.toString() ?? 'Unknown'}',
                      style: TextStyle(
                        fontSize: Common.h2,
                        fontWeight: Common.weight2,
                        color: Common.secondary,
                        fontFamily: 'bold',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name',
                          style: TextStyle(
                            fontSize: Common.h2,
                            fontWeight: Common.weight2,
                            color: Common.secondary,
                            fontFamily: 'bold',
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${widget.order['sellerName'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: Common.h2,
                            fontWeight: Common.weight2,
                            color: Common.light,
                            fontFamily: 'bold',
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact',
                          style: TextStyle(
                            fontSize: Common.h2,
                            fontWeight: Common.weight2,
                            color: Common.secondary,
                            fontFamily: 'bold',
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${widget.order['sellerPhone']?.toString() ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: Common.h2,
                            fontWeight: Common.weight2,
                            color: Common.light,
                            fontFamily: 'bold',
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 16),
            
            // Pickup location
            Row(
              children: [
                SvgPicture.asset('assets/Icons/location.svg', width: 24, height: 24, color: Color(0xFF58DE71)),
                SizedBox(width: 16),
                Text('PICKUP', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight2, fontFamily: 'bold')),
              ],
            ),
            SizedBox(height: 2),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        orderType == 'Digistall Orders'
                          ? (widget.order['sellerAddress'] ?? 'Pickup N/A').toString()
                          : (widget.order['pickupAddress'] ?? 'Pickup N/A').toString(),
                        style: TextStyle(fontSize: 12, fontWeight: Common.weight, color: Common.light),
                        softWrap: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
            ),
            SizedBox(height: 2),
            
            // Drop location
            Row(
              children: [
                SvgPicture.asset('assets/Icons/location.svg', width: 24, height: 24, color: Color(0xFFED9D60)),
                SizedBox(width: 16),
                Text('DROP', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight2, fontFamily: 'bold')),
              ],
            ),
            SizedBox(height: 2),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 8),
                child: Text(
                  orderType == 'Digistall Orders'
                    ? widget.order['address'] ?? 'Drop N/A'
                    : widget.order['deliveryAddress'] ?? 'Drop N/A',
                  style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight, color: Common.light),
                  softWrap: true,
                ),
              ),
            ),
            SizedBox(height: 15),
            
            // Price, commission (for Digistall), and download button
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) {
                          if (orderType == 'Digistall Orders') {
                            final int cartVal = (widget.order['totalCartValue'] is int)
                                ? widget.order['totalCartValue'] as int
                                : int.tryParse(widget.order['totalCartValue']?.toString() ?? '0') ?? 0;
                            String couponTotalStr = '';
                            final ct = widget.order['coupontotal'];
                            if (ct is String) couponTotalStr = ct;
                            if (couponTotalStr.isEmpty && ct is int) couponTotalStr = ct.toString();
                            if (couponTotalStr.isEmpty) {
                              final ep = widget.order['expectedPrice'];
                              if (ep is int) couponTotalStr = ep.toString();
                              else if (ep is String) couponTotalStr = ep;
                            }
                            if (couponTotalStr.isEmpty) {
                              final ac = widget.order['adminCommission'];
                              int acVal = 0;
                              if (ac is int) acVal = ac;
                              else if (ac is String) acVal = int.tryParse(ac) ?? 0;
                              couponTotalStr = (cartVal + acVal).toString();
                            }
                            final int commission = (int.tryParse(couponTotalStr) ?? cartVal) - cartVal;
                            final int total = cartVal + (commission < 0 ? 0 : commission);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TOTAL',
                                  style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight2, color: Common.secondary, fontFamily: 'bold'),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  '₹$cartVal + ₹$commission = ₹$couponTotalStr',
                                  style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight, color: Colors.green),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Total ₹${total.toStringAsFixed(0)}',
                                  style: TextStyle(fontSize: Common.h3,  color: Colors.blue),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TOTAL',
                                  style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight2, color: Common.secondary, fontFamily: 'bold'),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  '₹ ${widget.order['expectedPrice'] ?? '0'}',
                                  style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight, color: Colors.green),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.document_scanner),
                  label: Text(
                    _isGenerating ? "Preparing..." : "Download Invoice",
                    style: TextStyle(
                      color: Common.primary,
                      fontSize: Common.h3,
                      fontFamily: 'bold',
                      fontWeight: Common.weight2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Common.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: _isGenerating ? null : () => _handleDownloadAndPrint(widget.order),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DigistallOrderCard extends StatefulWidget {
  // const _DigistallOrderCard({
  //   super.key,
  // });
  final Map<String, dynamic> order;
  final String endpointPost;
  const _DigistallOrderCard({Key? key, required this.order, required this.endpointPost}) : super(key: key);

  @override
  State<_DigistallOrderCard> createState() => _DigistallOrderCardState();
}

class _DigistallOrderCardState extends State<_DigistallOrderCard> {
  bool _isGenerating = false;
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

  Future<void> _handleDownloadAndPrint(Map<String, dynamic> order) async {
    setState(() => _isGenerating = true);

    final pdfData = await generateRiderOrderInvoice(order);

    setState(() => _isGenerating = false);

    await Printing.layoutPdf(onLayout: (_) => pdfData);
  }

  Future<Uint8List> generateRiderOrderInvoice(Map<String, dynamic> order) async {
    final pdf = pw.Document();

    final rider = order['riderDetails'][0];
    // final dateTime = DateTime.tryParse(order['pickupTime'] ?? '') ?? DateTime.now();
    final formattedDateTime = getFormattedDeliveryTime(widget.order);

    final logoBytes = await rootBundle.load('assets/Icons/Bike.png');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Padding(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              //here image in the center
              // Header
              pw.Center(
                child: pw.Image(logo, width: 140, height: 140), // adjust size as needed
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Invoice To', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      pw.Text(rider['name']),
                      pw.Text(rider['phoneNumber']),
                    ],
                  ),
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Service Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      pw.Text(widget.endpointPost),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Order details table
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(), borderRadius: pw.BorderRadius.circular(4)),
                child: pw.Table(
                  border: pw.TableBorder.symmetric(
                    inside: pw.BorderSide(),
                    outside: pw.BorderSide(),
                  ),
                  columnWidths: {
                    0: pw.FlexColumnWidth(3),
                    1: pw.FlexColumnWidth(7),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.black),
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Order Details', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Container(), // Empty cell for alignment
                      ],
                    ),
                    pw.TableRow(children: [
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('PickUp Address')),
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(order['sellerAddress'] ?? '')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Delivery Address')),
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(order['address'] ?? '')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Date and Time')),
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(formattedDateTime)),
                    ]),
                    if(widget.endpointPost=='Rider Booking')
                      pw.TableRow(children: [
                        pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Passengers')),
                        pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(order['numOfPassengers'] ?? '')),
                      ]),
                    if(widget.endpointPost=='Rider Booking')
                      pw.TableRow(children: [
                        pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Vehicle Type')),
                        pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(order['vehicleType'] ?? '')),
                      ]),
                    if(widget.endpointPost=='Parcel Booking')
                      pw.TableRow(children: [
                        pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Weight')),
                        pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(order['weight'] ?? '')),
                      ]),
                    if(widget.endpointPost=='Parcel Booking')
                      pw.TableRow(children: [
                        pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Message')),
                        pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(order['message'] ?? '')),
                      ]),

                    pw.TableRow(children: [
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Product Name')),
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(order['productName'] ?? '')),
                    ]),

                    // pw.TableRow(children: [
                    //   pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Total Value')),
                    //   pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(order['totalCartValue'] ?? '')),
                    // ]),

                    // pw.TableRow(children: [
                    //   pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Customer Details')),
                    //   pw.Padding(
                    //     padding: pw.EdgeInsets.all(6),
                    //     child: pw.Column(
                    //       crossAxisAlignment: pw.CrossAxisAlignment.start,
                    //       children: [
                    //         pw.Text('Name: ${order['sellerName']}'),
                    //         pw.Text('Phone: ${order['sellerPhone']}'),
                    //       ],
                    //     ),
                    //   ),
                    // ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(
                          (order['paymentMethod']?.toUpperCase() == 'UPI')
                              ? 'Payment (UPI)'
                              : (order['paymentMethod']?.toUpperCase() == 'COD'
                              ? 'Payment (COD)'
                              : 'Payment (Unknown)'),
                      )),
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text((order['totalCartValue'] ?? '').toString())),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Admin Commission')),
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('20')), // Example static value
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Rider Commission')),
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(((order['totalCartValue'] ?? '') - 20).toString())),
                    ]),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Thank you for choosing DigiRider app.'),
                  pw.Column(
                    children: [
                      pw.Text('Sign'),
                      pw.Text('Rider'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return pdf.save();
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
                // if(endpointPost=='api/parcel/setriderstatus')
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    'Order #${widget.order['_id']?.toString().substring(0, 8) ?? ''}',
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
                      '${getFormattedDeliveryTime(widget.order)}',
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

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Product - ${widget.order['productName'] ?? 'Unknown'}',
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
                      'Quantity - ${widget.order['productCount']?.toString() ?? 'Unknown'}',
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
            SizedBox(height: 15,),
            Row(
              children: [
                SizedBox(width: 5,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CART VALUE', style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight2, color: Common.secondary, fontFamily: 'bold'),),
                      SizedBox(height: 3,),
                      Text('₹${widget.order['totalCartValue'] ?? '0'}', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight, color: Colors.green,),)
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  icon: _isGenerating
                      ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.document_scanner),
                  label: Text(
                    _isGenerating ? "Preparing..." : "Download Invoice",
                    style: TextStyle(
                      color: Common.primary,
                      fontSize: Common.h3,
                      fontFamily: 'bold',
                      fontWeight: Common.weight2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Common.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: _isGenerating ? null : () => _handleDownloadAndPrint(widget.order),
                ),
                // Expanded(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text('TRIP DISTANCE', style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight, color: Common.light),),
                //       SizedBox(height: 3,),
                //       Text(order['distance'] ?? 'Distance N/A', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight, color: Common.light),)
                //     ],
                //   ),
                // ),
                // SizedBox(width: 16,),
              ],
            ),
            // SizedBox(height: 16,),
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
  final String endpointPost;

  const _OrderCard({Key? key, required this.order, required this.endpointPost}) : super(key: key);

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {

  bool _isGenerating = false;
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

  Future<void> _handleDownloadAndPrint(Map<String, dynamic> order) async {
    setState(() => _isGenerating = true);

    final pdfData = await generateRiderOrderInvoice(order);

    setState(() => _isGenerating = false);

    await Printing.layoutPdf(onLayout: (_) => pdfData);
  }

  Future<Uint8List> generateRiderOrderInvoice(Map<String, dynamic> order) async {
    final pdf = pw.Document();

    final rider = order['riderDetails'][0];
    final dateTime = DateTime.tryParse(order['pickupTime'] ?? '') ?? DateTime.now();
    final formattedDateTime = DateFormat('yyyy-MM-dd kk:mm').format(dateTime);

    final logoBytes = await rootBundle.load('assets/Icons/Bike.png');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Padding(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              //here image in the center
              // Header
              pw.Center(
                child: pw.Image(logo, width: 140, height: 140), // adjust size as needed
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Invoice To', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      pw.Text(rider['name']),
                      pw.Text(rider['phoneNumber']),
                    ],
                  ),
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Service Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      pw.Text(widget.endpointPost),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Order details table
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(), borderRadius: pw.BorderRadius.circular(4)),
                child: pw.Table(
                  border: pw.TableBorder.symmetric(
                    inside: pw.BorderSide(),
                    outside: pw.BorderSide(),
                  ),
                  columnWidths: {
                    0: pw.FlexColumnWidth(3),
                    1: pw.FlexColumnWidth(7),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.black),
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Order Details', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Container(), // Empty cell for alignment
                      ],
                    ),
                    pw.TableRow(children: [
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('PickUp Address')),
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(order['pickupAddress'] ?? '')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Delivery Address')),
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(order['deliveryAddress'] ?? '')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Date and Time')),
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(formattedDateTime)),
                    ]),
                    if(widget.endpointPost=='Rider Booking')
                    pw.TableRow(children: [
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Passengers')),
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(order['numOfPassengers'] ?? '')),
                    ]),
                    if(widget.endpointPost=='Rider Booking')
                    pw.TableRow(children: [
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Vehicle Type')),
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(order['vehicleType'] ?? '')),
                    ]),
                    if(widget.endpointPost=='Parcel Booking')
                    pw.TableRow(children: [
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Weight')),
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(order['weight'] ?? '')),
                    ]),
                    if(widget.endpointPost=='Parcel Booking')
                    pw.TableRow(children: [
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Message')),
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(order['message'] ?? '')),
                    ]),

                    pw.TableRow(children: [
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Customer Details')),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Name: ${order['sellerName']}'),
                            pw.Text('Phone: ${order['sellerPhone']}'),
                          ],
                        ),
                      ),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Payment (COD)')),
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(order['expectedPrice'] ?? '')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Admin Commission')),
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('20')), // Example static value
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Rider Commission')),
                      pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text((int.parse(order['expectedPrice']) - 20).toString())),
                    ]),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Thank you for choosing DigiRider app.'),
                  pw.Column(
                    children: [
                      pw.Text('Sign'),
                      pw.Text('Rider'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return pdf.save();
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
                // if(endpointPost=='api/parcel/setriderstatus')
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    'Order #${widget.order['_id']?.toString().substring(0, 8) ?? ''}',
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
                      formatIndianDate(widget.order['pickupTime']?.toString() ?? ''),
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
                          '${widget.order['sellerName'] ?? 'Unknown'}',
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
                          '${widget.order['sellerPhone']?.toString() ?? 'Unknown'}',
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
                SizedBox(width: 5,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL', style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight2, color: Common.secondary, fontFamily: 'bold'),),
                      SizedBox(height: 3,),
                      Text('₹ ${widget.order['expectedPrice'] ?? '0'}', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight, color: Colors.green,),)
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  icon: _isGenerating
                      ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.document_scanner),
                  label: Text(
                    _isGenerating ? "Preparing..." : "Download Invoice",
                    style: TextStyle(
                      color: Common.primary,
                      fontSize: Common.h3,
                      fontFamily: 'bold',
                      fontWeight: Common.weight2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Common.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: _isGenerating ? null : () => _handleDownloadAndPrint(widget.order),
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

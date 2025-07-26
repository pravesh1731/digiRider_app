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
  String selectedStatus = 'Rider Orders'; // default
  bool _isLoading = true;
  // final searchFocusNode = FocusNode();
  Timer? _timer;
  String endpointPost = '';

  void filterRidesAuto() async {
    final filtered = await _fetchBookings(selectedStatus);

    if (!mounted) return; // Prevents calling setState on disposed widget

    setState(() {
      _orders = filtered;
    });
  }

  void filterRides() async {
    final filtered = await _fetchBookings(selectedStatus);
    setState(() {
      _orders = filtered;
      _isLoading = false;
    });
  }

  Future<List<dynamic>> _fetchBookings(String status) async {
    await _loadSharedPrefs();

    String endpoint = '';
    String order = '';
    if (status == 'Rider Orders') endpoint = 'api/rider/riderhistory?cityName=$cityName&phoneNumber=$phoneNumber';

    else if (status == 'Parcel Orders') endpoint = 'api/parcel/parcelhistory?cityName=$cityName&phoneNumber=$phoneNumber';
    else if (status == 'Digistall Orders') endpoint = 'api/digiorder/digiorderhistory?cityName=$cityName&phoneNumber=$phoneNumber';

    if (status == 'Rider Orders') order = 'orderHistory';
    else if (status == 'Parcel Orders') order = 'parcelHistory';
    else if (status == 'Digistall Orders') order = 'orderItemHistory';

    if (status == 'Rider Orders') endpointPost = 'Rider Booking';
    else if (status == 'Parcel Orders') endpointPost = 'Parcel Booking';
    else if (status == 'Digistall Orders') endpointPost = 'Digistall Booking';

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
    email = prefs.getString('email') ?? '';
    phoneNumber = prefs.getString('phoneNumber') ?? '';
  }

  @override
  void initState() {
    super.initState();
    _fetchBookings(selectedStatus).then((orders) {
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
        onWillPop: () => showExitConfirmationDialog(context),
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 60,
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
            title: Text('History', style: TextStyle(fontSize: Common.title, fontFamily: Common.family),),
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
                  SizedBox(height: 5,),
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
                          return selectedStatus == 'Digistall Orders'
                              ? _DigistallOrderCard(order: order,endpointPost: endpointPost,)
                              : _OrderCard(order: order, endpointPost: endpointPost,);
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

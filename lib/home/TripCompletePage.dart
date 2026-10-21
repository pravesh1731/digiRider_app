import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart' show consolidateHttpClientResponseBytes;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:pdf/pdf.dart';
import '../global/Common.dart';
import 'package:flutter/services.dart' show rootBundle, consolidateHttpClientResponseBytes;
import 'package:printing/printing.dart';
import '../global/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';



class TripCompletePage extends StatefulWidget {
  final String pickupLocation;
  final String destinationLocation;
  // For Digistall, this represents the cart value (totalCartValue)
  final String totalAmount;
  final String riderId;
  // Optional coupontotal (string) to compute commission precisely
  final String? couponTotal;

  const TripCompletePage({
    Key? key,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.totalAmount,
    required this.riderId,
    this.couponTotal,
  }) : super(key: key);

  @override
  State<TripCompletePage> createState() => _TripCompletePageState();
}

class _TripCompletePageState extends State<TripCompletePage> {
  String qrCodeUrl = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQrCodeFromPrefs();
  }

  Future<void> fetchQrCodeFromPrefs() async {
    setState(() { isLoading = true; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final qr = prefs.getString('qrcode') ?? '';
      print('Fetched QR code from SharedPreferences: $qr');
      setState(() {
        qrCodeUrl = qr;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching QR code from SharedPreferences: $e');
      setState(() { isLoading = false; });
    }
  }

  int _getCartValue() {
    // Try to parse totalAmount as int, fallback to 0 if not possible
    final value = widget.totalAmount;
    if (int.tryParse(value) != null) return int.parse(value);
    return 0;
  }

  int _computeCommission(int cart) {
    final ct = widget.couponTotal;
    if (ct != null && ct.isNotEmpty) {
      final parsed = int.tryParse(ct);
      if (parsed != null) {
        final c = parsed - cart;
        return c < 0 ? 0 : c;
      }
    }
    // fallback for non-digi
    return 20;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  final cartValue = _getCartValue();
  final commission = _computeCommission(cartValue);
  final total = cartValue + commission; // Total Amount includes commission
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.tripCompleted,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 32),
                          SizedBox(width: 10),
                          Text(context.l10n.tripCompletedTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 18),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue, size: 28),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(context.l10n.pickupLocation, style: theme.textTheme.bodySmall),
                                Text(widget.pickupLocation, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14),
                      Row(
                        children: [
                          Icon(Icons.flag, color: Colors.red, size: 28),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(context.l10n.destination, style: theme.textTheme.bodySmall),
                                Text(widget.destinationLocation, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14),
                      Row(
                        children: [
                          SizedBox(width: 16),
                          Text(context.l10n.totalAmount, style: theme.textTheme.bodySmall),
                          SizedBox(width: 8),
                          // Show total (cart + commission) as Total Amount
                          Text('₹ $total', style: theme.textTheme.titleLarge?.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      // --- Show cart value + commission ---
                      SizedBox(height: 8),
                      Row(
                        children: [
                          SizedBox(width: 16),
                          Text(context.l10n.cartValueLabel, style: theme.textTheme.bodySmall),
                          SizedBox(width: 8),
                          Text('₹$cartValue + ₹$commission = ₹${widget.couponTotal ?? (cartValue + commission)}', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.green)),
                        ],
                      ),
                      // --- End cart value + commission section ---
                      SizedBox(height: 18),
                      Divider(),
                      SizedBox(height: 10),
                      Text(context.l10n.scanToPay, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Center(
                        child: isLoading
                            ? CircularProgressIndicator()
                            : qrCodeUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      qrCodeUrl,
                                      width: 160,
                                      height: 160,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 160,
                                        height: 160,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Icon(Icons.qr_code, size: 100, color: Colors.grey[600]),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(Icons.qr_code, size: 100, color: Colors.grey[600]),
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final pdf = pw.Document();
                          final now = DateTime.now();
                          final invoiceNumber = 'INV${now.millisecondsSinceEpoch}';
                          final logo = await rootBundle.load('assets/images/app_icon.png');
                          final logoImage = pw.MemoryImage(logo.buffer.asUint8List());
                          pw.Widget? qrWidget;
                          if (qrCodeUrl.isNotEmpty) {
                            // Download QR code image as bytes
                            final httpClient = HttpClient();
                            final request = await httpClient.getUrl(Uri.parse(qrCodeUrl));
                            final response = await request.close();
                            final bytes = await consolidateHttpClientResponseBytes(response);
                            qrWidget = pw.Image(
                              pw.MemoryImage(bytes),
                              width: 200,
                              height: 200,
                            );
                          }

                          pdf.addPage(
                            pw.Page(
                              pageFormat: PdfPageFormat.a4,
                              build: (pw.Context context) {
                                return pw.Container(
                                  padding: const pw.EdgeInsets.all(24),
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
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
                                      pw.Text('Invoice Number: $invoiceNumber', style: pw.TextStyle(fontSize: 14)),
                                      pw.Text('Date: ${now.toLocal().toString().split(' ')[0]}', style: pw.TextStyle(fontSize: 14)),
                                      pw.SizedBox(height: 18),
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
                                            pw.Text(widget.pickupLocation),
                                            pw.SizedBox(height: 8),
                                            pw.Text('Destination:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                            pw.Text(widget.destinationLocation),
                                            pw.SizedBox(height: 8),
                                            // Add cart value and commission details
                                            pw.Text('Cart Value:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                            pw.Text('Rs. $cartValue'),
                                            pw.SizedBox(height: 8),
                                            pw.Text('Commission:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                            pw.Text('Rs. $commission'),
                                            pw.SizedBox(height: 8),
                                            pw.Text('Total Amount:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                            pw.Text('Rs. $total', style: pw.TextStyle(color: PdfColors.green800, fontWeight: pw.FontWeight.bold, fontSize: 16)),
                                          ],
                                        ),
                                      ),
                                      pw.SizedBox(height: 18),
                                      pw.Text('Scan to Pay', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                                      pw.SizedBox(height: 8),
                                      if (qrWidget != null) pw.Center(child: qrWidget),
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
                          final dir = await getApplicationDocumentsDirectory();
                          final file = File('${dir.path}/trip_invoice_${now.millisecondsSinceEpoch}.pdf');
                          await file.writeAsBytes(await pdf.save());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.l10n.invoiceDownloaded(file.path))),
                          );
                          await OpenFile.open(file.path);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.l10n.invoiceDownloadFailed(e.toString()))),
                          );
                        }
                      },
                      icon: Icon(Icons.download,color: Colors.white,),
                      label: Text(context.l10n.downloadInvoice,style: TextStyle(color: Colors.white,fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: Text(context.l10n.done,style: TextStyle(color: Colors.white,fontSize: 14),),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



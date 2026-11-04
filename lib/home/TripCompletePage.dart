import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show consolidateHttpClientResponseBytes;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:pdf/pdf.dart';
import '../ui/cap_visuals.dart';
import '../ui/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
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
  // Shown on the "Trip complete" sheet.
  final String? orderShortId;
  final String? customerName;
  final int cashAmount;
  final int? earning;

  const TripCompletePage({
    Key? key,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.totalAmount,
    required this.riderId,
    this.couponTotal,
    this.orderShortId,
    this.customerName,
    this.cashAmount = 0,
    this.earning,
  }) : super(key: key);

  @override
  State<TripCompletePage> createState() => _TripCompletePageState();
}

class _TripCompletePageState extends State<TripCompletePage> {
  String qrCodeUrl = '';
  bool isLoading = true;
  int _stars = 5;
  bool _downloading = false;

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

  Future<void> _downloadInvoice(int cartValue, int commission, int total) async {
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
      if (mounted) showCapToast(context, context.l10n.invoiceDownloaded(file.path));
      await OpenFile.open(file.path);
    } catch (e) {
      if (mounted) showCapToast(context, context.l10n.invoiceDownloadFailed(e.toString()), color: context.cap.rd);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.cap;
    final media = MediaQuery.of(context);
    final cartValue = _getCartValue();
    final commission = _computeCommission(cartValue);
    final total = cartValue + commission; // Total includes commission
    final earned = widget.earning ?? int.tryParse(widget.couponTotal ?? '') ?? total;
    final cash = widget.cashAmount;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: p.bg,
        body: Stack(
          children: [
            const Positioned.fill(child: CityMap(showHighDemand: false)),
            Positioned(
              left: 10,
              right: 10,
              bottom: 16 + media.padding.bottom,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: media.size.height - media.padding.top - 40),
                child: Glass(
                  radius: CapRadius.sheet,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            CapTag(l10n.cTripComplete),
                            const Spacer(),
                            if (widget.orderShortId != null)
                              Text('#${widget.orderShortId}', style: CapText.mono(size: 12, weight: FontWeight.w400, color: p.mu)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(rupees(earned), style: CapText.serif(size: 52, color: p.tx, height: 1)),
                        const SizedBox(height: 4),
                        if (cash > 0)
                          Text(
                            '💵 ${l10n.cCustomerCashInHand}: ${rupees(cash)} · ${l10n.cDeliveryEarning}: ${rupees(earned)}',
                            style: CapText.sans(size: 13.5, weight: FontWeight.w700, color: CapPalette.cod),
                          )
                        else
                          Text(l10n.cPaidViaQr, style: CapText.sans(size: 13.5, color: p.mu)),
                        const SizedBox(height: 14),
                        CapList(
                          children: [
                            CapListItem(
                              child: Text(l10n.pickupLocation, style: CapText.sans(size: 14, color: p.tx)),
                              trailing: Flexible(
                                child: Text(widget.pickupLocation, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,
                                    style: CapText.sans(size: 13, weight: FontWeight.w600, color: p.tx)),
                              ),
                            ),
                            CapListItem(
                              child: Text(l10n.destination, style: CapText.sans(size: 14, color: p.tx)),
                              trailing: Flexible(
                                child: Text(widget.destinationLocation, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,
                                    style: CapText.sans(size: 13, weight: FontWeight.w600, color: p.tx)),
                              ),
                            ),
                            if (widget.couponTotal != null)
                              CapListItem(
                                child: Text(l10n.cartValueLabel, style: CapText.sans(size: 14, color: p.tx)),
                                trailing: Text('${rupees(cartValue)} + ${rupees(commission)}', style: CapText.sans(size: 14, weight: FontWeight.w700, color: p.tx)),
                              ),
                            CapListItem(
                              child: Text(l10n.cDeliveryEarning, style: CapText.sans(size: 14, color: p.tx)),
                              trailing: Text(rupees(earned), style: CapText.sans(size: 14, weight: FontWeight.w700, color: p.amx)),
                            ),
                            if (cash > 0)
                              CapListItem(
                                child: Text(l10n.cCustomerCashInHand, style: CapText.sans(size: 14, color: p.tx)),
                                trailing: Text(rupees(cash), style: CapText.sans(size: 14, weight: FontWeight.w700, color: CapPalette.cod)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // The rider's payment QR, for customers paying by UPI.
                        CapList(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  KLabel(l10n.scanToPay),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                    child: isLoading
                                        ? const SizedBox(width: 160, height: 160, child: Center(child: CircularProgressIndicator()))
                                        : qrCodeUrl.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Image.network(
                                                  qrCodeUrl,
                                                  width: 160,
                                                  height: 160,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => _qrPlaceholder(),
                                                ),
                                              )
                                            : _qrPlaceholder(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (widget.customerName != null) ...[
                          const SizedBox(height: 14),
                          Text(l10n.cRateCustomer(widget.customerName!), textAlign: TextAlign.center, style: CapText.sans(size: 13, color: p.mu)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 1; i <= 5; i++)
                                GestureDetector(
                                  onTap: () => setState(() => _stars = i),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: CapIcon(CapIcons.star, size: 28, color: p.am, filled: i <= _stars),
                                  ),
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        CapButton(
                          label: cash > 0 ? l10n.cCashCollectedDone : l10n.done,
                          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        ),
                        const SizedBox(height: 10),
                        CapButton(
                          label: l10n.downloadInvoice,
                          icon: CapIcons.doc,
                          style: CapButtonStyle.ghost,
                          loading: _downloading,
                          onPressed: () async {
                            setState(() => _downloading = true);
                            await _downloadInvoice(cartValue, commission, total);
                            if (mounted) setState(() => _downloading = false);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qrPlaceholder() {
    final p = context.cap;
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(color: p.s2, borderRadius: BorderRadius.circular(10)),
      child: Icon(Icons.qr_code_2_rounded, size: 90, color: p.mu),
    );
  }
}

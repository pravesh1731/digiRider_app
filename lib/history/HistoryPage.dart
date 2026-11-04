import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../global/l10n.dart';
import '../model/cap_order.dart';
import '../services/rider_feed.dart';
import '../ui/widgets.dart';

enum _TripFilter { all, rides, deliveries }

/// The website's "Your trips" tab: every order this rider took, newest first.
/// Tapping a trip shows its details and the invoice download.
class HistoryPage extends StatefulWidget {
  final VoidCallback? onGoHome;
  const HistoryPage({super.key, this.onGoHome});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  _TripFilter _filter = _TripFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final feed = RiderFeed.instance;
    return ListenableBuilder(
      listenable: feed,
      builder: (context, _) {
        final trips = feed.history.where((o) {
          final ride = CapOrder(o).isRide;
          return _filter == _TripFilter.all || (_filter == _TripFilter.rides ? ride : !ride);
        }).toList();
        return CapPage(
          onRefresh: feed.refreshHistory,
          children: [
            Align(alignment: Alignment.centerLeft, child: CapChip.back(context, label: l10n.cNavHome, onTap: widget.onGoHome)),
            const SizedBox(height: 14),
            PageTitle(label: l10n.cNavTrips, title: l10n.cTripsTitle),
            const SizedBox(height: 16),
            CapSeg<_TripFilter>(
              value: _filter,
              onChanged: (v) => setState(() => _filter = v),
              items: [
                SegItem(_TripFilter.all, l10n.cAll),
                SegItem(_TripFilter.rides, l10n.cRides),
                SegItem(_TripFilter.deliveries, l10n.cDeliveries),
              ],
            ),
            const SizedBox(height: 18),
            if (!feed.historyLoaded)
              const SkeletonBox(height: 280, radius: CapRadius.list)
            else if (trips.isEmpty)
              CapListMessage(l10n.nothingHereYet)
            else
              CapList(children: [for (final o in trips) _TripRow(order: o)]),
          ],
        );
      },
    );
  }
}

class _TripRow extends StatelessWidget {
  final Map<String, dynamic> order;
  const _TripRow({required this.order});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final l10n = context.l10n;
    final o = CapOrder(order);
    final status = o.riderStatus;
    final date = DateFormat('d MMM').format(RiderFeed.completedAt(order));
    return CapListItem(
      onTap: () => _showTrip(context, order),
      leading: IconBox(icon: o.isRide ? CapIcons.car : CapIcons.flag),
      trailing: Text(rupees(o.fare), style: CapText.serif(size: 20, color: p.amx, height: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: '${o.isRide ? l10n.cRide : l10n.cDelivery} ',
              children: [TextSpan(text: '#${o.shortId}', style: CapText.mono(size: 14, weight: FontWeight.w600, color: p.tx))],
            ),
            style: CapText.sans(size: 15, weight: FontWeight.w700, color: p.tx),
          ),
          Text(
            [if (status.isNotEmpty) l10n.riderStatusName(status), o.payLabel(l10n), date].join(' · '),
            style: CapText.sans(size: 12, color: status.toLowerCase() == 'cancelled' ? p.rd : p.mu),
          ),
        ],
      ),
    );
  }
}

Future<void> _showTrip(BuildContext context, Map<String, dynamic> order) {
  return showCapSheet<void>(context, builder: (ctx) => _TripDetails(order: order));
}

class _TripDetails extends StatefulWidget {
  final Map<String, dynamic> order;
  const _TripDetails({required this.order});

  @override
  State<_TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<_TripDetails> {
  bool _generating = false;

  Future<void> _invoice() async {
    setState(() => _generating = true);
    try {
      final pdf = await generateRiderOrderInvoice(widget.order);
      if (mounted) setState(() => _generating = false);
      await Printing.layoutPdf(onLayout: (_) => pdf);
    } catch (e) {
      debugPrint('Invoice failed: $e');
      if (mounted) {
        setState(() => _generating = false);
        showCapToast(context, context.l10n.somethingWentWrong, color: context.cap.rd);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final l10n = context.l10n;
    final o = CapOrder(widget.order);
    final when = DateFormat('dd MMM yyyy, hh:mm a').format(RiderFeed.completedAt(widget.order));
    final status = o.riderStatus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetHeader(label: '${o.kindLabel(l10n)} · #${o.shortId}', title: l10n.cTripDetails),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: Text(rupees(o.fare), style: CapText.serif(size: 46, color: p.tx, height: 1))),
            if (status.isNotEmpty)
              CapTag(
                l10n.riderStatusName(status),
                color: status.toLowerCase() == 'delivered' ? p.lv : (status.toLowerCase() == 'cancelled' ? p.rd : p.amx),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text('$when · ${o.payLabel(l10n)}', style: CapText.sans(size: 13, color: p.mu)),
        const SizedBox(height: 16),
        RouteTimeline(pickup: o.pickupAddress, drop: o.dropAddress, ellipsis: false, fontSize: 14, pickupLabel: o.isStore ? l10n.storeLocation : null),
        const SizedBox(height: 16),
        CapList(
          children: [
            if (o.isStore)
              CapListItem(
                child: Text(l10n.cartValueLabel, style: CapText.sans(size: 14, color: p.tx)),
                trailing: Text('${rupees(o.cartValue)} + ${rupees(o.commission)}', style: CapText.sans(size: 14, weight: FontWeight.w700, color: p.tx)),
              ),
            if (o.distance != null && !o.isStore)
              CapListItem(
                child: Text(l10n.cDistance, style: CapText.sans(size: 14, color: p.tx)),
                trailing: Text(o.distance!, style: CapText.sans(size: 14, weight: FontWeight.w700, color: p.tx)),
              ),
            if (o.customerName != null && !o.isStore)
              CapListItem(
                child: Text(l10n.cCustomer, style: CapText.sans(size: 14, color: p.tx)),
                trailing: Text(o.customerName!, style: CapText.sans(size: 14, weight: FontWeight.w700, color: p.tx)),
              ),
            CapListItem(
              child: Text(l10n.cYouEarn, style: CapText.sans(size: 14, color: p.tx)),
              trailing: Text(rupees(o.fare), style: CapText.sans(size: 14, weight: FontWeight.w700, color: p.amx)),
            ),
          ],
        ),
        const SizedBox(height: 18),
        CapButton(
          label: _generating ? l10n.preparing : l10n.downloadInvoice,
          icon: CapIcons.doc,
          style: CapButtonStyle.ghost,
          loading: _generating,
          onPressed: _invoice,
        ),
      ],
    );
  }
}

/// PDF invoice for a past order (English only: the PDF font has no Devanagari).
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

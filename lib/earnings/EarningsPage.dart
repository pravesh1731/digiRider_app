import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../global/Common.dart';
import '../global/OrderTypeIcon.dart';
import '../global/l10n.dart';
import '../utils/show_exit_dialog.dart';

/// Earnings from delivered orders, split by order source (the website's Earnings tab).
class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsSummary {
  double amount = 0;
  int count = 0;
}

class _EarningsPageState extends State<EarningsPage> {
  // orderType -> history endpoint, response key and the field holding the rider's amount
  static const List<Map<String, String>> _sources = [
    {'type': 'Rider Orders', 'endpoint': 'api/rider/riderhistory', 'key': 'orderHistory', 'amount': 'expectedPrice'},
    {'type': 'Parcel Orders', 'endpoint': 'api/parcel/parcelhistory', 'key': 'parcelHistory', 'amount': 'expectedPrice'},
    {'type': 'Digistall Orders', 'endpoint': 'api/digiorder/digiorderhistory', 'key': 'orderItemHistory', 'amount': 'coupontotal'},
  ];

  final Map<String, _EarningsSummary> _summary = {};
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchEarnings();
  }

  Future<void> _fetchEarnings() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber') ?? '';
    final email = prefs.getString('email') ?? '';
    final summary = {for (final s in _sources) s['type']!: _EarningsSummary()};
    var failures = 0;

    await Future.wait(_sources.map((source) async {
      try {
        // History is looked up by phone only, so changing city does not hide past earnings.
        final url = Uri.parse('${Common.baseUrl}${source['endpoint']}?phoneNumber=${Uri.encodeQueryComponent(phoneNumber)}');
        final response = await http.get(url);
        if (response.statusCode != 200) {
          failures++;
          return;
        }
        final orders = jsonDecode(response.body)[source['key']];
        if (orders is! List) return;

        for (final order in orders) {
          if (!_isDeliveredBy(order, phoneNumber, email)) continue;
          final entry = summary[source['type']]!;
          entry.amount += double.tryParse(order[source['amount']]?.toString() ?? '') ?? 0;
          entry.count++;
        }
      } catch (e) {
        debugPrint('Error fetching ${source['type']} earnings: $e');
        failures++;
      }
    }));

    if (!mounted) return;
    setState(() {
      _summary
        ..clear()
        ..addAll(summary);
      _hasError = failures == _sources.length;
      _isLoading = false;
    });
  }

  /// Delivered orders whose latest assigned rider is this rider.
  bool _isDeliveredBy(dynamic order, String phoneNumber, String email) {
    if ((order['riderStatus']?.toString().toLowerCase() ?? '') != 'delivered') return false;
    final riders = order['riderDetails'];
    if (riders is! List || riders.isEmpty) return false;
    final rider = riders.last;
    return rider['phoneNumber']?.toString() == phoneNumber ||
        (email.isNotEmpty && rider['email']?.toString().toLowerCase() == email.toLowerCase());
  }

  String _formatAmount(double amount) {
    return amount == amount.roundToDouble() ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = _summary.values.fold<double>(0, (sum, e) => sum + e.amount);
    final deliveries = _summary.values.fold<int>(0, (sum, e) => sum + e.count);

    return WillPopScope(
      onWillPop: () => showExitConfirmationDialog(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Common.secondary,
          toolbarHeight: 60,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Center(
              child: SvgPicture.asset(
                'assets/Icons/money-rupee-circle-fill.svg',
                color: Common.primary,
                width: 25,
                height: 25,
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: _isLoading ? null : _fetchEarnings,
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Image.asset('assets/Icons/refresh.png', width: 20, height: 20, color: Colors.white),
              ),
            ),
          ],
          title: Text(l10n.earnings, style: TextStyle(fontSize: Common.title, fontFamily: Common.family, color: Colors.white)),
        ),
        body: RefreshIndicator(
          backgroundColor: Common.secondary,
          color: Common.primary,
          onRefresh: _fetchEarnings,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                elevation: 5,
                color: Common.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    children: [
                      Text(
                        l10n.totalEarnings.toUpperCase(),
                        style: TextStyle(fontSize: Common.h3, color: Common.light, fontFamily: 'bold', fontWeight: Common.weight2),
                      ),
                      const SizedBox(height: 8),
                      _isLoading
                          ? SizedBox(
                              height: 36,
                              width: 36,
                              child: CircularProgressIndicator(color: Common.primary, strokeWidth: 2.5),
                            )
                          : Text(
                              '₹${_formatAmount(total)}',
                              style: TextStyle(fontSize: 34, color: Common.primary, fontFamily: 'bold', fontWeight: Common.weight),
                            ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.completedDeliveries(deliveries),
                        style: TextStyle(fontSize: Common.h3, color: Common.primary, fontFamily: 'bold', fontWeight: Common.weight2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  l10n.earningsBreakdown,
                  style: TextStyle(fontSize: Common.h1, color: Common.secondary, fontFamily: 'bold', fontWeight: Common.weight),
                ),
              ),
              const SizedBox(height: 8),
              if (_hasError)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l10n.couldNotLoadEarnings,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: Common.h2, color: Colors.red, fontFamily: 'bold'),
                  ),
                ),
              for (final source in _sources) _buildRow(source['type']!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String orderType) {
    final l10n = context.l10n;
    final entry = _summary[orderType] ?? _EarningsSummary();
    final subtitle = orderType == 'Digistall Orders'
        ? l10n.deliveredOrdersCount(entry.count)
        : orderType == 'Parcel Orders'
            ? l10n.deliveredParcelsCount(entry.count)
            : l10n.completedRidesCount(entry.count);

    return Card(
      elevation: 3,
      color: Common.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Common.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: OrderTypeIcon(orderType: orderType)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.orderTypeName(orderType), style: TextStyle(fontSize: Common.h2, color: Common.secondary, fontFamily: 'bold', fontWeight: Common.weight)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: Common.h3, color: Common.light, fontFamily: 'bold')),
                ],
              ),
            ),
            Text(
              _isLoading ? '…' : '₹${_formatAmount(entry.amount)}',
              style: TextStyle(fontSize: Common.h1, color: Colors.green, fontFamily: 'bold', fontWeight: Common.weight),
            ),
          ],
        ),
      ),
    );
  }
}

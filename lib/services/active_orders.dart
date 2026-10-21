import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../global/Common.dart';

/// The rider's accepted, not yet delivered orders from all three backends.
/// Each order is tagged with `orderType` and `endpointPost` (its status-update endpoint),
/// which HomePage and TripFlowPage use to tell the order sources apart.
class ActiveOrders {
  static const int maxActiveOrders = 2;

  static const List<Map<String, String>> sources = [
    {'endpoint': 'api/rider/riderorderhistory', 'type': 'Rider Orders', 'post': 'api/rider/setriderstatus'},
    {'endpoint': 'api/parcel/riderorderhistory', 'type': 'Parcel Orders', 'post': 'api/parcel/setriderstatus'},
    {'endpoint': 'api/digiorder/orderStatus', 'type': 'Digistall Orders', 'post': 'api/digiorder/setorderStatus'},
  ];

  static Future<List<dynamic>> fetch(String email) async {
    if (email.isEmpty) return [];

    final results = await Future.wait(sources.map((source) async {
      try {
        final response = await http.post(
          Uri.parse('${Common.baseUrl}${source['endpoint']}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        );
        if (response.statusCode != 200) return <dynamic>[];
        final orders = jsonDecode(response.body)['data'];
        if (orders is! List) return <dynamic>[];
        for (final o in orders) {
          o['orderType'] = source['type'];
          o['endpointPost'] = source['post'];
        }
        return orders;
      } catch (e) {
        debugPrint('Error fetching ${source['type']}: $e');
        return <dynamic>[];
      }
    }));

    return results.expand((orders) => orders).toList();
  }
}

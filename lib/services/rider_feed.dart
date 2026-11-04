import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../global/Common.dart';
import '../model/cap_order.dart';
import 'active_orders.dart';
import 'location_service.dart';
import 'notification_service.dart';

enum AcceptResult { accepted, limitReached, alreadyTaken, failed }

/// Everything the main tabs show, fetched in one place while NavMain is mounted:
/// incoming orders from the three dashboards, the rider's active orders and their history.
/// Raw order maps are tagged with `orderType` and `endpointPost` as before.
class RiderFeed extends ChangeNotifier {
  RiderFeed._();
  static final RiderFeed instance = RiderFeed._();

  static const String _missedKey = 'missedOrders';

  // Session values from SharedPreferences.
  String name = '';
  String email = '';
  String phone = '';
  String city = 'Gotan';
  String vehicle = 'Bike';
  String domain = '';
  String profile = '';
  String qrcode = '';
  String licence = '';
  String aadhaar = '';
  String userStatus = '';
  bool online = true;

  List<Map<String, dynamic>> incoming = [];
  List<Map<String, dynamic>> active = [];
  List<Map<String, dynamic>> history = [];
  final Set<String> _missed = {};

  bool incomingLoaded = false;
  bool activeLoaded = false;
  bool historyLoaded = false;

  Timer? _fastTimer;
  Timer? _slowTimer;
  StreamSubscription? _pushSub;
  int _starts = 0;

  /// Starts polling. Calls are counted, so two NavMains can overlap during a replace.
  Future<void> start() async {
    _starts++;
    if (_starts > 1) return;
    await loadProfile();
    unawaited(refreshAll());
    _fastTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      refreshIncoming();
      refreshActive();
    });
    _slowTimer = Timer.periodic(const Duration(seconds: 30), (_) => refreshHistory());
    // A push for a new order: refresh at once instead of waiting for the poll.
    _pushSub = NotificationService().onMessage.listen((_) {
      refreshIncoming();
      refreshActive();
    });
  }

  void stop() {
    if (_starts == 0) return;
    _starts--;
    if (_starts > 0) return;
    _fastTimer?.cancel();
    _slowTimer?.cancel();
    _pushSub?.cancel();
    _fastTimer = null;
    _slowTimer = null;
    _pushSub = null;
  }

  /// Forgets everything (logout).
  void reset() {
    incoming = [];
    active = [];
    history = [];
    _missed.clear();
    incomingLoaded = activeLoaded = historyLoaded = false;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name') ?? '';
    email = prefs.getString('email') ?? '';
    phone = prefs.getString('phoneNumber') ?? '';
    city = prefs.getString('cityName') ?? '';
    if (city.isEmpty) city = 'Gotan';
    vehicle = prefs.getString('vehicleType') ?? 'Bike';
    if (!['Bike', 'Auto', 'Car'].contains(vehicle)) vehicle = 'Bike';
    domain = prefs.getString('riderDomain') ?? '';
    profile = prefs.getString('profile') ?? '';
    qrcode = prefs.getString('qrcode') ?? '';
    licence = prefs.getString('licence') ?? '';
    aadhaar = prefs.getString('aadhaar') ?? '';
    userStatus = prefs.getString('userStatus') ?? '';
    online = await LocationService().isOnline();
    _missed
      ..clear()
      ..addAll(prefs.getStringList(_missedKey) ?? const []);
    notifyListeners();
  }

  Future<void> refreshAll() => Future.wait([refreshIncoming(), refreshActive(), refreshHistory()]);

  // ---------------------------------------------------------------------------
  // Incoming orders
  // ---------------------------------------------------------------------------

  Future<void> refreshIncoming() async {
    final c = Uri.encodeQueryComponent(city);
    final endpoints = [
      {'endpoint': 'api/rider/dashboard?vehicleType=${Uri.encodeQueryComponent(vehicle)}&cityName=$c', 'type': 'Rider Orders', 'order': 'filteredOrders', 'post': 'api/rider/acceptriderorder'},
      {'endpoint': 'api/parcel/dashboard?cityName=$c', 'type': 'Parcel Orders', 'order': 'parcelOrders', 'post': 'api/parcel/acceptriderorder'},
      {'endpoint': 'api/digiorder/getDigiOrder', 'type': 'Digistall Orders', 'order': 'DigiOrders', 'post': 'api/digiorder/acceptedByRider'},
    ];

    // One failing backend must not hide the orders from the other two.
    final results = await Future.wait(endpoints.map((ep) async {
      try {
        final response = await http.get(Uri.parse('${Common.baseUrl}${ep['endpoint']}'));
        if (response.statusCode != 200) return <Map<String, dynamic>>[];
        final orders = jsonDecode(response.body)[ep['order']];
        if (orders is! List) return <Map<String, dynamic>>[];
        return [
          for (final o in orders.whereType<Map<String, dynamic>>())
            o
              ..['orderType'] = ep['type']
              ..['endpointPost'] = ep['post'],
        ];
      } catch (e) {
        debugPrint('Error fetching ${ep['type']}: $e');
        return <Map<String, dynamic>>[];
      }
    }));

    final all = results.expand((o) => o).where(_shouldInclude).toList();
    all.sort((a, b) => _postedAt(b).compareTo(_postedAt(a)));
    incoming = all;
    incomingLoaded = true;
    notifyListeners();
  }

  bool _shouldInclude(Map<String, dynamic> order) {
    final type = order['orderType'];
    // Digistall and parcel orders go to every rider in the city.
    if (type == 'Digistall Orders' || type == 'Parcel Orders') return true;
    // Ride requests must match the rider's vehicle type.
    if (type == 'Rider Orders') return order['vehicleType'] == vehicle;
    return false;
  }

  static DateTime _postedAt(Map<String, dynamic> o) => CapOrder(o).postedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  bool isMissed(Map<String, dynamic> o) => _missed.contains(o['_id']?.toString());

  /// Open = still inside the 24-hour window and not skipped.
  List<Map<String, dynamic>> get openOrders => incoming.where((o) => !CapOrder(o).isExpired && !isMissed(o)).toList();
  List<Map<String, dynamic>> get missedOrders => incoming.where((o) => !CapOrder(o).isExpired && isMissed(o)).toList();
  List<Map<String, dynamic>> get expiredOrders => incoming.where((o) => CapOrder(o).isExpired).toList();

  /// Skipped or timed-out requests move to the Orders tab's "Missed" list.
  Future<void> markMissed(Map<String, dynamic> order) async {
    final id = order['_id']?.toString();
    if (id == null || id.isEmpty || _missed.contains(id)) return;
    _missed.add(id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // Only remember ids that are still on the board.
    final live = incoming.map((o) => o['_id']?.toString()).toSet();
    await prefs.setStringList(_missedKey, _missed.where(live.contains).toList());
  }

  /// Accepts [order] for this rider. The active-order limit is checked against the server
  /// so it holds after reinstalls or on a second phone.
  Future<(AcceptResult, String?)> accept(Map<String, dynamic> order) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await ActiveOrders.fetch(email);
    if (current.length >= ActiveOrders.maxActiveOrders) return (AcceptResult.limitReached, null);

    try {
      final response = await http.post(
        Uri.parse('${Common.baseUrl}${order['endpointPost']}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': order['_id'],
          'sellerPhone': order['sellerPhone'],
          'riderData': {
            'name': prefs.getString('name') ?? '',
            'email': email,
            'cityName': prefs.getString('cityName') ?? '',
            'phoneNumber': prefs.getString('phoneNumber') ?? '',
            'riderDomain': prefs.getString('riderDomain') ?? '',
            'deviceToken': prefs.getString('deviceToken') ?? '',
            'vehicleType': prefs.getString('vehicleType') ?? '',
            'aadhaar': prefs.getString('aadhaar') ?? '',
            'licence': prefs.getString('licence') ?? '',
            'profile': prefs.getString('profile') ?? '',
            'qrcode': prefs.getString('qrcode') ?? '',
            'success': true,
            'userStatus': prefs.getString('userStatus') ?? '',
          },
        }),
      );

      Map<String, dynamic>? body;
      try {
        body = jsonDecode(response.body);
      } catch (_) {}

      if (response.statusCode == 200 && body?['success'] != false) {
        incoming.removeWhere((o) => o['_id'] == order['_id']);
        notifyListeners();
        unawaited(refreshActive());
        return (AcceptResult.accepted, null);
      }
      final message = body?['message']?.toString() ?? '';
      if (message.contains('already been accepted')) return (AcceptResult.alreadyTaken, null);
      return (AcceptResult.failed, message.isEmpty ? null : message);
    } catch (e) {
      debugPrint('Error accepting order: $e');
      return (AcceptResult.failed, null);
    }
  }

  // ---------------------------------------------------------------------------
  // Active orders and history
  // ---------------------------------------------------------------------------

  Future<void> refreshActive() async {
    if (email.isEmpty) return;
    final orders = await ActiveOrders.fetch(email);
    final list = orders.whereType<Map<String, dynamic>>().toList();
    list.sort((a, b) => _postedAt(b).compareTo(_postedAt(a)));
    active = list;
    activeLoaded = true;
    notifyListeners();
  }

  Future<void> refreshHistory() async {
    if (phone.isEmpty && email.isEmpty) return;
    final ph = Uri.encodeQueryComponent(phone);
    // History is looked up by phone only, so changing city keeps past orders.
    final sources = [
      {'type': 'Rider Orders', 'endpoint': 'api/rider/riderhistory?phoneNumber=$ph', 'key': 'orderHistory', 'service': 'Rider Booking'},
      {'type': 'Parcel Orders', 'endpoint': 'api/parcel/parcelhistory?phoneNumber=$ph', 'key': 'parcelHistory', 'service': 'Parcel Booking'},
      {'type': 'Digistall Orders', 'endpoint': 'api/digiorder/digiorderhistory?phoneNumber=$ph', 'key': 'orderItemHistory', 'service': 'Digistall Booking'},
    ];
    var failures = 0;
    final results = await Future.wait(sources.map((s) async {
      try {
        final response = await http.get(Uri.parse('${Common.baseUrl}${s['endpoint']}'));
        if (response.statusCode != 200) {
          failures++;
          return <Map<String, dynamic>>[];
        }
        final orders = jsonDecode(response.body)[s['key']];
        if (orders is! List) return <Map<String, dynamic>>[];
        return [
          for (final o in orders.whereType<Map<String, dynamic>>())
            if (_hasMe(o))
              o
                ..['orderType'] = s['type']
                ..['serviceType'] = s['service'],
        ];
      } catch (e) {
        debugPrint('Error fetching ${s['type']} history: $e');
        failures++;
        return <Map<String, dynamic>>[];
      }
    }));
    // Keep the old list when every backend failed (offline), instead of showing nothing.
    if (failures == sources.length && historyLoaded) return;
    final all = results.expand((o) => o).toList();
    all.sort((a, b) => completedAt(b).compareTo(completedAt(a)));
    history = all;
    historyLoaded = true;
    notifyListeners();
  }

  bool _hasMe(Map<String, dynamic> order) {
    final riders = order['riderDetails'];
    if (riders is! List || riders.isEmpty) return false;
    return riders.any((r) => r is Map && (r['phoneNumber']?.toString() == phone || (email.isNotEmpty && r['email']?.toString() == email)));
  }

  /// Delivered orders whose latest assigned rider is this rider (what earnings count).
  bool isDeliveredByMe(Map<String, dynamic> order) {
    if ((order['riderStatus']?.toString().toLowerCase() ?? '') != 'delivered') return false;
    final riders = order['riderDetails'];
    if (riders is! List || riders.isEmpty) return false;
    final r = riders.last;
    return r is Map &&
        (r['phoneNumber']?.toString() == phone || (email.isNotEmpty && r['email']?.toString().toLowerCase() == email.toLowerCase()));
  }

  List<Map<String, dynamic>> get delivered => history.where(isDeliveredByMe).toList();

  /// Best guess of when an order finished: last update, else creation.
  static DateTime completedAt(Map<String, dynamic> o) {
    for (final key in ['updatedAt', 'createdAt', 'pickupTime']) {
      final t = DateTime.tryParse(o[key]?.toString() ?? '');
      if (t != null) return t.toLocal();
    }
    return CapOrder(o).postedAt?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  List<Map<String, dynamic>> deliveredSince(DateTime from) => delivered.where((o) => !completedAt(o).isBefore(from)).toList();

  static DateTime get startOfToday {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  int get todayEarnings => deliveredSince(startOfToday).fold(0, (s, o) => s + CapOrder(o).fare);
  int get todayTrips => deliveredSince(startOfToday).length;

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  Future<void> setOnline(bool value) async {
    online = value;
    notifyListeners();
    await LocationService().setOnline(value);
  }

  Future<void> setVehicle(String value) async {
    vehicle = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vehicleType', value);
    notifyListeners();
    unawaited(refreshIncoming());
  }

  /// Saves the city on the server first: `cityName` decides which city's pushes this rider gets.
  Future<bool> setCity(String value) async {
    if (email.isEmpty) return false;
    try {
      final response = await http.post(
        Uri.parse('${Common.baseUrl}api/rider/updatecityname'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'cityName': value}),
      );
      if (response.statusCode != 200) return false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cityName', value);
      city = value;
      notifyListeners();
      unawaited(refreshIncoming());
      return true;
    } catch (e) {
      debugPrint('City update failed: $e');
      return false;
    }
  }
}

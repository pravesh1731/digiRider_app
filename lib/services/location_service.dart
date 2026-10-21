import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../global/Common.dart';
import 'active_orders.dart';

/// Live rider location, as on the website:
/// - `api/rider/activeupdate` marks the rider online/offline,
/// - `api/rider/updateLocation` keeps the rider's position on the admin fleet map,
/// - `api/{rider|parcel}/currentlocation` tells the customer where their rider is during an order.
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  static const Duration _minUploadInterval = Duration(seconds: 15);
  static const Duration _orderLocationInterval = Duration(seconds: 60);

  StreamSubscription<Position>? _positionSub;
  Timer? _orderTimer;
  Position? _lastPosition;
  DateTime? _lastUpload;
  String _riderDomain = '';
  bool _running = false;
  bool _askedPermission = false;

  Future<void> start() async {
    if (_running) return;

    final prefs = await SharedPreferences.getInstance();
    _riderDomain = prefs.getString('riderDomain') ?? '';
    if (_riderDomain.isEmpty || !await _ensurePermission()) return;
    if (_running) return;
    _running = true;

    unawaited(_setActive(true));

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    ).listen(_onPosition, onError: (e) => debugPrint('Location stream error: $e'));

    _orderTimer = Timer.periodic(_orderLocationInterval, (_) => _sendOrderLocations());
  }

  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    await _positionSub?.cancel();
    _positionSub = null;
    _orderTimer?.cancel();
    _orderTimer = null;
    await _setActive(false);
  }

  Future<bool> _ensurePermission() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return false;
      var permission = await Geolocator.checkPermission();
      // Ask once per app session; start() also runs on every resume.
      if (permission == LocationPermission.denied && !_askedPermission) {
        _askedPermission = true;
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      debugPrint('Location permission check failed: $e');
      return false;
    }
  }

  void _onPosition(Position position) {
    final isFirst = _lastPosition == null;
    _lastPosition = position;
    if (isFirst) unawaited(_sendOrderLocations());

    final now = DateTime.now();
    if (_lastUpload != null && now.difference(_lastUpload!) < _minUploadInterval) return;
    _lastUpload = now;
    unawaited(_post('api/rider/updateLocation', {
      'riderDomain': _riderDomain,
      'latitude': position.latitude,
      'longitude': position.longitude,
    }));
  }

  Future<void> _setActive(bool active) {
    return _post('api/rider/activeupdate', {'riderDomain': _riderDomain, 'active': active});
  }

  Future<void> _sendOrderLocations() async {
    final position = _lastPosition;
    if (position == null) return;

    final prefs = await SharedPreferences.getInstance();
    final orders = (await ActiveOrders.fetch(prefs.getString('email') ?? ''))
        .where((o) => o['orderType'] != 'Digistall Orders' && o['sellerPhone'] != null)
        .toList();
    if (orders.isEmpty) return;

    final address = await _addressFor(position);
    for (final order in orders) {
      final base = order['orderType'] == 'Parcel Orders' ? 'api/parcel' : 'api/rider';
      await _post('$base/currentlocation', {
        'orderId': order['_id'],
        'city': address,
        'sellerPhone': order['sellerPhone'],
      });
    }
  }

  Future<String> _addressFor(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = [place.street, place.subLocality, place.locality, place.administrativeArea]
            .where((part) => part != null && part.isNotEmpty)
            .toList();
        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (e) {
      debugPrint('Reverse geocoding failed: $e');
    }
    return '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
  }

  Future<void> _post(String endpoint, Map<String, dynamic> body) async {
    try {
      await http.post(
        Uri.parse('${Common.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (e) {
      debugPrint('POST $endpoint failed: $e');
    }
  }
}

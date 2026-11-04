import 'package:intl/intl.dart';

import '../gen_l10n/app_localizations.dart';

/// Which backend an order came from.
enum OrderKind { ride, parcel, store }

/// Read-only view of a raw order map from any of the three backends, with the website's
/// field fallbacks. Behaviour still keys off the raw `orderType`/`endpointPost` tags.
class CapOrder {
  final Map<String, dynamic> raw;
  const CapOrder(this.raw);

  static const Duration retention = Duration(hours: 24);

  OrderKind get kind {
    final type = raw['orderType']?.toString() ?? '';
    final post = raw['endpointPost']?.toString() ?? '';
    if (type == 'Digistall Orders' || post.startsWith('api/digiorder/')) return OrderKind.store;
    if (type == 'Parcel Orders' || post.startsWith('api/parcel/')) return OrderKind.parcel;
    return OrderKind.ride;
  }

  bool get isStore => kind == OrderKind.store;
  bool get isRide => kind == OrderKind.ride;

  String get id => raw['_id']?.toString() ?? '';

  /// Last five characters of the id, shown as "#4c53a" like the website.
  String get shortId {
    final s = id;
    return s.length > 5 ? s.substring(s.length - 5) : s;
  }

  String kindLabel(AppLocalizations l10n) {
    switch (kind) {
      case OrderKind.ride:
        return l10n.cRideRequest;
      case OrderKind.parcel:
        return l10n.cParcelDelivery;
      case OrderKind.store:
        return l10n.cStoreDelivery;
    }
  }

  String get pickupAddress => _text(isStore ? raw['sellerAddress'] : raw['pickupAddress']);
  String get dropAddress => _text(isStore ? raw['address'] : raw['deliveryAddress']);

  String? get customerName {
    final n = _text(raw['customerName'] ?? raw['sellerName'] ?? raw['userName']);
    return n.isEmpty ? null : n;
  }

  String? get phone {
    final p = _text(raw['sellerPhone']);
    return p.isEmpty ? null : p;
  }

  String? get distance {
    final d = _text(raw['distance']);
    return d.isEmpty ? null : d;
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.round();
    return double.tryParse(v?.toString() ?? '')?.round() ?? 0;
  }

  int get cartValue => _int(raw['totalCartValue']);

  /// What the rider is shown as their amount: `expectedPrice` for rides and parcels,
  /// `coupontotal` (cart + commission) for Digistall orders.
  int get fare {
    if (!isStore) return _int(raw['expectedPrice']);
    final ct = raw['coupontotal'];
    if (ct != null && ct.toString().isNotEmpty) return _int(ct);
    final ep = raw['expectedPrice'];
    if (ep != null && ep.toString().isNotEmpty) return _int(ep);
    return cartValue + _int(raw['adminCommission']);
  }

  int get commission {
    if (!isStore) return 0;
    final c = fare - cartValue;
    return c < 0 ? 0 : c;
  }

  String get _payment => _text(raw['paymentMode'] ?? raw['paymentMethod'] ?? raw['paymentType'] ?? raw['pay']).toUpperCase();

  /// Cash / cash-on-delivery orders, where the rider collects money at the door.
  bool get isCod {
    final p = _payment;
    if (p.contains('COD') || p.contains('CASH')) return true;
    if (p.contains('UPI') || p.contains('ONLINE') || p.contains('PREPAID')) return false;
    // Rides are paid in cash unless marked otherwise, as on the website.
    return isRide && p.isEmpty;
  }

  /// Amount to collect in cash: the order total for store orders, the fare otherwise.
  int get codAmount {
    if (!isCod) return 0;
    if (isStore) return fare > 0 ? fare : cartValue;
    return fare;
  }

  String payLabel(AppLocalizations l10n) {
    if (isCod) return l10n.cCash;
    final p = _text(raw['paymentMode'] ?? raw['paymentMethod']);
    return p.isEmpty ? l10n.cPrepaid : p;
  }

  /// When the order was posted, for the 24-hour retention window.
  DateTime? get postedAt {
    for (final key in ['createdAt', 'updatedAt', 'pickupTime']) {
      final t = DateTime.tryParse(raw[key]?.toString() ?? '');
      if (t != null) return t;
    }
    // Mongo ids start with the creation time in seconds.
    if (id.length >= 8) {
      final secs = int.tryParse(id.substring(0, 8), radix: 16);
      if (secs != null && secs > 0) return DateTime.fromMillisecondsSinceEpoch(secs * 1000);
    }
    return null;
  }

  Duration get timeLeft {
    final posted = postedAt;
    if (posted == null) return retention;
    final left = retention - DateTime.now().difference(posted);
    return left.isNegative ? Duration.zero : left;
  }

  bool get isExpired => timeLeft == Duration.zero;

  /// "5h 07m", like the website's retention countdown.
  String get timeLeftLabel {
    final m = timeLeft.inMinutes;
    return '${m ~/ 60}h ${(m % 60).toString().padLeft(2, '0')}m';
  }

  /// "Deliver by" for Digistall orders, pickup time for the others.
  String? whenLabel() {
    if (isStore) {
      final by = _text(raw['deliveryBy']);
      final time = _text(raw['deliveryTime']);
      if (by.isEmpty) return null;
      try {
        return DateFormat('dd MMM, hh:mm a').format(DateFormat('yyyy-MM-dd HH:mm').parse('$by ${time.isEmpty ? '00:00' : time}'));
      } catch (_) {
        return by;
      }
    }
    final t = DateTime.tryParse(_text(raw['pickupTime']));
    return t == null ? null : DateFormat('dd MMM, hh:mm a').format(t.toLocal());
  }

  /// Digistall orders with a delivery OTP must send it when marked delivered.
  bool get needsDeliveryOtp => isStore && _text(raw['otp']).isNotEmpty;

  String get riderStatus => _text(raw['riderStatus']);

  static String _text(dynamic v) => v?.toString().trim() ?? '';
}

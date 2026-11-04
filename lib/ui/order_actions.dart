import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../global/l10n.dart';
import '../model/cap_order.dart';
import '../providers/trip_provider.dart';
import '../services/rider_feed.dart';
import 'widgets.dart';

/// Accepts [order] and shows the outcome as a toast. Returns true when accepted.
Future<bool> acceptOrderWithFeedback(BuildContext context, Map<String, dynamic> order) async {
  final l10n = context.l10n;
  final (result, message) = await RiderFeed.instance.accept(order);
  if (!context.mounted) return result == AcceptResult.accepted;
  final p = context.cap;
  switch (result) {
    case AcceptResult.accepted:
      final count = RiderFeed.instance.active.length;
      await Provider.of<TripProvider>(context, listen: false).setActiveOrdersCount(count + 1);
      if (context.mounted) showCapToast(context, l10n.orderAccepted);
      return true;
    case AcceptResult.limitReached:
      showCapToast(context, l10n.finishCurrentRidesFirst, color: p.rd);
      return false;
    case AcceptResult.alreadyTaken:
      showCapToast(context, l10n.orderAlreadyTaken, color: p.rd);
      return false;
    case AcceptResult.failed:
      showCapToast(context, message ?? l10n.acceptFailed, color: p.rd);
      return false;
  }
}

/// Calls the customer (`sellerPhone`).
Future<void> callCustomer(BuildContext context, Map<String, dynamic> order) async {
  final phone = CapOrder(order).phone;
  if (phone == null) {
    showCapToast(context, context.l10n.customerPhoneMissing, color: context.cap.rd);
    return;
  }
  final uri = Uri.parse('tel:$phone');
  if (!await launchUrl(uri) && context.mounted) {
    showCapToast(context, context.l10n.couldNotLaunchDialer, color: context.cap.rd);
  }
}

/// Opens turn-by-turn navigation to the pickup ([toPickup]) or the drop.
/// Uses coordinates when the order has them (Digistall store/customer), else the address.
Future<void> openNavigation(BuildContext context, Map<String, dynamic> order, {required bool toPickup}) async {
  final o = CapOrder(order);
  final lat = order[toPickup ? 'sellerLat' : 'customerLat'];
  final lng = order[toPickup ? 'sellerLng' : 'customerLng'];
  String? target = (lat != null && lng != null) ? '$lat,$lng' : (toPickup ? o.pickupAddress : o.dropAddress);
  if (target.isEmpty) target = null;
  if (target == null) {
    showCapToast(context, toPickup ? context.l10n.pickupAddressMissing : context.l10n.destinationAddressMissing, color: context.cap.rd);
    return;
  }
  final encoded = Uri.encodeComponent(target);
  final nav = Uri.parse('google.navigation:q=$encoded&mode=d');
  try {
    if (await canLaunchUrl(nav)) {
      await launchUrl(nav, mode: LaunchMode.externalApplication);
      return;
    }
    // Google Maps app not installed: directions in the browser.
    await launchUrl(
      Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$encoded&travelmode=driving'),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    if (context.mounted) showCapToast(context, context.l10n.couldNotOpenMaps, color: context.cap.rd);
  }
}

/// Route from pickup to drop in Google Maps (order preview).
Future<void> openRoute(BuildContext context, Map<String, dynamic> order) async {
  final o = CapOrder(order);
  final url = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&origin=${Uri.encodeComponent(o.pickupAddress)}'
    '&destination=${Uri.encodeComponent(o.dropAddress)}&travelmode=driving',
  );
  if (!await launchUrl(url, mode: LaunchMode.externalApplication) && context.mounted) {
    showCapToast(context, context.l10n.couldNotOpenMaps, color: context.cap.rd);
  }
}

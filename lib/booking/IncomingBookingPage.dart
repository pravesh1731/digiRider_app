import 'package:flutter/material.dart';

import '../global/l10n.dart';
import '../model/cap_order.dart';
import '../services/active_orders.dart';
import '../services/rider_feed.dart';
import '../ui/order_actions.dart';
import '../ui/pickers.dart';
import '../ui/widgets.dart';

enum _Bucket { open, missed, expired }

enum _Kind { all, rides, parcels, store }

/// The website's "All orders" tab: every request in the rider's city for 24 hours,
/// split into Open / Missed / Expired and filterable by type. Tapping one opens its details.
class IncomingBookingPage extends StatefulWidget {
  final VoidCallback? onGoHome;
  const IncomingBookingPage({super.key, this.onGoHome});

  @override
  State<IncomingBookingPage> createState() => _IncomingBookingPageState();
}

class _IncomingBookingPageState extends State<IncomingBookingPage> {
  _Bucket _bucket = _Bucket.open;
  _Kind _kind = _Kind.all;

  RiderFeed get feed => RiderFeed.instance;

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> orders) {
    if (_kind == _Kind.all) return orders;
    return orders.where((o) {
      final k = CapOrder(o).kind;
      switch (_kind) {
        case _Kind.rides:
          return k == OrderKind.ride;
        case _Kind.parcels:
          return k == OrderKind.parcel;
        case _Kind.store:
          return k == OrderKind.store;
        case _Kind.all:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: feed,
      builder: (context, _) {
        final p = context.cap;
        final open = feed.openOrders;
        final missed = feed.missedOrders;
        final expired = feed.expiredOrders;
        final shown = _filtered(_bucket == _Bucket.open ? open : _bucket == _Bucket.missed ? missed : expired);
        final city = l10n.cityName(feed.city);

        return CapPage(
          onRefresh: feed.refreshIncoming,
          children: [
            Row(
              children: [
                CapChip.back(context, label: l10n.cNavHome, onTap: widget.onGoHome),
                const Spacer(),
                CapChip(icon: CapIcons.pin, label: city, onTap: () => showCityPicker(context)),
              ],
            ),
            const SizedBox(height: 14),
            PageTitle(label: l10n.cNavOrders, title: l10n.cOrdersTitle),
            const SizedBox(height: 6),
            Text(l10n.cOrdersSubtitle, style: CapText.sans(size: 14, color: p.mu, height: 1.45)),
            const SizedBox(height: 16),
            CapSeg<_Bucket>(
              value: _bucket,
              onChanged: (v) => setState(() => _bucket = v),
              items: [
                SegItem(_Bucket.open, l10n.cOpen, count: '${open.length}'),
                SegItem(_Bucket.missed, l10n.cMissed, count: '${missed.length}'),
                SegItem(_Bucket.expired, l10n.cExpired, count: '${expired.length}'),
              ],
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final k in _Kind.values) ...[
                    if (k != _Kind.all) const SizedBox(width: 8),
                    CapChip(
                      label: switch (k) {
                        _Kind.all => l10n.cAll,
                        _Kind.rides => l10n.cRides,
                        _Kind.parcels => l10n.cParcels,
                        _Kind.store => l10n.cStoreFilter,
                      },
                      selected: _kind == k,
                      background: _kind == k ? null : p.s1,
                      onTap: () => setState(() => _kind = k),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            if (!feed.incomingLoaded)
              for (var i = 0; i < 3; i++) const SkeletonBox(height: 120)
            else if (shown.isEmpty)
              CapListMessage(
                _bucket == _Bucket.open
                    ? l10n.cNoOpenOrders(city)
                    : _bucket == _Bucket.missed
                        ? l10n.cNothingMissed
                        : l10n.cNoExpired,
                margin: const EdgeInsets.only(top: 14),
              )
            else
              for (final o in shown) _OrderCard(key: ValueKey(o['_id']), order: o, onTap: () => showOrderDetails(context, o)),
            const SizedBox(height: 22),
            Text(l10n.cRemovedAfter24h, textAlign: TextAlign.center, style: CapText.sans(size: 12, color: p.mu)),
          ],
        );
      },
    );
  }
}

/// `.oc` order card: type + id, time left, pickup → drop rail, fare and payment.
class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;
  const _OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final l10n = context.l10n;
    final o = CapOrder(order);
    final urgent = !o.isExpired && o.timeLeft < const Duration(hours: 2);
    return Pressable(
      scale: 0.99,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.s1,
          borderRadius: BorderRadius.circular(CapRadius.oc),
          border: Border.all(color: p.ln),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Flexible(child: CapTag('${o.kindLabel(l10n)} · #${o.shortId}')),
                const SizedBox(width: 8),
                const Spacer(),
                Text(
                  o.isExpired ? l10n.cExpired : l10n.cTimeLeft(o.timeLeftLabel),
                  style: CapText.mono(size: 12, weight: FontWeight.w400, color: urgent ? p.rd : p.mu),
                ),
              ],
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RouteRail(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(o.pickupAddress.isEmpty ? '—' : o.pickupAddress, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: CapText.sans(size: 14, weight: FontWeight.w600, color: p.tx)),
                        const SizedBox(height: 12),
                        Text(o.dropAddress.isEmpty ? '—' : o.dropAddress, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: CapText.sans(size: 14, weight: FontWeight.w600, color: p.tx)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(rupees(o.fare), style: CapText.serif(size: 32, color: p.amx, height: 1)),
                      Text(o.isCod ? l10n.cCodShort('${o.codAmount}') : o.payLabel(l10n), style: CapText.sans(size: 12, color: p.mu)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `Jm` order detail sheet with slide to accept.
Future<void> showOrderDetails(BuildContext context, Map<String, dynamic> order) {
  return showCapSheet<void>(context, builder: (ctx) => _OrderDetails(order: order));
}

class _OrderDetails extends StatefulWidget {
  final Map<String, dynamic> order;
  const _OrderDetails({required this.order});

  @override
  State<_OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<_OrderDetails> {
  bool _accepting = false;

  Future<void> _accept() async {
    setState(() => _accepting = true);
    final ok = await acceptOrderWithFeedback(context, widget.order);
    if (!mounted) return;
    setState(() => _accepting = false);
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final l10n = context.l10n;
    final o = CapOrder(widget.order);
    final busy = RiderFeed.instance.active.length >= ActiveOrders.maxActiveOrders;
    final hasDistance = o.distance != null && !o.isStore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CapChip.back(context),
            const Spacer(),
            IconBox(icon: CapIcons.x, iconSize: 18, onTap: () => Navigator.of(context).pop()),
          ],
        ),
        const SizedBox(height: 14),
        Align(alignment: Alignment.centerLeft, child: CapTag('${o.kindLabel(l10n)} · #${o.shortId}')),
        if (o.customerName != null && !o.isStore) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              CapAvatar(name: o.customerName!, size: 32),
              const SizedBox(width: 8),
              Flexible(child: Text(o.customerName!, style: CapText.sans(size: 15, weight: FontWeight.w700, color: p.tx))),
            ],
          ),
        ],
        if (o.isStore && (widget.order['productName']?.toString().isNotEmpty ?? false)) ...[
          const SizedBox(height: 14),
          Text(
            '${l10n.productLabel(widget.order['productName'].toString())} · ${l10n.quantityLabel(widget.order['productCount']?.toString() ?? '1')}',
            style: CapText.sans(size: 14, weight: FontWeight.w600, color: p.tx),
          ),
        ],
        const SizedBox(height: 16),
        RouteTimeline(pickup: o.pickupAddress, drop: o.dropAddress, ellipsis: false, fontSize: 14, pickupLabel: o.isStore ? l10n.storeLocation : null),
        const SizedBox(height: 16),
        if (o.isCod) ...[
          CodBanner(title: l10n.cCodBanner('${o.codAmount}'), subtitle: l10n.cCollectAtDoor('${o.codAmount}')),
          const SizedBox(height: 14),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KLabel(hasDistance ? l10n.cDistance : l10n.cDeliverBy),
                  Text(hasDistance ? o.distance! : (o.whenLabel() ?? l10n.cToday), style: CapText.sans(size: 15, weight: FontWeight.w600, color: p.tx)),
                  const SizedBox(height: 6),
                  CapTag(o.isCod ? l10n.cCodShort('${o.codAmount}') : o.payLabel(l10n)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                KLabel(l10n.cYouEarn),
                Text(rupees(o.fare), style: CapText.serif(size: 38, color: p.amx, height: 1)),
                if (o.isStore && o.commission > 0)
                  Text('${rupees(o.cartValue)} + ${rupees(o.commission)}', style: CapText.mono(size: 11, weight: FontWeight.w400, color: p.mu)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text.rich(
          TextSpan(
            text: '${l10n.cOrderRetention} ',
            children: [
              TextSpan(
                text: o.isExpired ? l10n.cExpired : l10n.cExpiresIn(o.timeLeftLabel),
                style: CapText.sans(size: 13, weight: FontWeight.w700, color: o.isExpired ? p.rd : p.tx),
              ),
            ],
          ),
          style: CapText.sans(size: 13, color: p.mu),
        ),
        const SizedBox(height: 14),
        CapButton(label: l10n.cViewRoute, icon: CapIcons.nav, style: CapButtonStyle.ghost, height: 48, fontSize: 14, onPressed: () => openRoute(context, widget.order)),
        const SizedBox(height: 12),
        if (o.isExpired)
          CapListMessage(l10n.cPassed24h)
        else if (busy)
          CapListMessage(l10n.cFinishTripFirst)
        else
          SlideToAct(label: l10n.cSlideToAccept, loading: _accepting, onAction: _accept),
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../NavMain.dart';
import '../gen_l10n/app_localizations.dart';
import '../global/l10n.dart';
import '../model/cap_order.dart';
import '../services/rider_feed.dart';
import '../settings/sub_pages.dart';
import '../ui/cap_visuals.dart';
import '../ui/order_actions.dart';
import '../ui/pickers.dart';
import '../ui/widgets.dart';
import 'TripFlowPage.dart';

/// The website's Home cockpit: live city map, greeting, online switch, today's earnings,
/// and a bottom sheet showing (in order) offline notice, active trip, the next request, or "all caught up".
class HomePage extends StatefulWidget {
  final ValueChanged<int> onSelectTab;
  const HomePage({super.key, required this.onSelectTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int _goal = 1500;
  int _requestIndex = 0;
  int _activeIndex = 0;

  RiderFeed get feed => RiderFeed.instance;

  String _greeting() {
    final l10n = context.l10n;
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.cGoodMorning;
    if (hour < 17) return l10n.cGoodAfternoon;
    return l10n.cGoodEvening;
  }

  Future<void> _toggleOnline() async {
    final value = !feed.online;
    await feed.setOnline(value);
    if (mounted) showCapToast(context, value ? context.l10n.cNowOnline : context.l10n.cNowOffline);
  }

  void _skip(Map<String, dynamic> order, {required bool expired}) {
    feed.markMissed(order);
    setState(() => _requestIndex++);
    showCapToast(context, expired ? context.l10n.cExpiredToast : context.l10n.cSkippedToast);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return ListenableBuilder(
      listenable: feed,
      builder: (context, _) {
        final p = context.cap;
        final cityIndex = kCities.indexOf(feed.city).clamp(0, kCities.length - 1);
        return Stack(
          children: [
            Positioned.fill(child: CityMap(cityOffset: cityIndex, showHighDemand: feed.online)),
            Positioned(
              left: 18,
              right: 18,
              top: media.padding.top + 16,
              child: _buildTop(p),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 84 + media.padding.bottom,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: media.size.height - media.padding.top - media.padding.bottom - 330),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: const Cubic(.2, .8, .2, 1),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(position: Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(anim), child: child),
                  ),
                  child: _buildSheet(p),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTop(CapPalette p) {
    final l10n = context.l10n;
    final hasDot = feed.active.isNotEmpty || (feed.online && feed.openOrders.isNotEmpty);
    final percent = (feed.todayEarnings / _goal * 100).round().clamp(0, 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CapAvatar(name: feed.name.isEmpty ? l10n.cBrand : feed.name),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_greeting(), style: CapText.sans(size: 13, color: p.mu)),
                  Text(
                    feed.name.isEmpty ? l10n.cBrand : feed.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CapText.sans(size: 20, weight: FontWeight.w700, color: p.tx, spacing: -0.4),
                  ),
                ],
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Glass(
                  radius: 14,
                  blur: 12,
                  shadow: false,
                  child: IconBox(
                    icon: CapIcons.bell,
                    background: Colors.transparent,
                    tooltip: l10n.cAlerts,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AlertsPage())),
                  ),
                ),
                if (hasDot)
                  Positioned(
                    top: 9,
                    right: 10,
                    child: IgnorePointer(
                      child: Container(width: 8, height: 8, decoration: BoxDecoration(color: p.rd, shape: BoxShape.circle)),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            CapChip(
              icon: CapIcons.pin,
              label: l10n.cityName(feed.city),
              trailingIcon: CapIcons.chev,
              onTap: () => showCityPicker(context),
            ),
            const Spacer(),
            Glass(
              radius: 99,
              blur: 12,
              shadow: false,
              padding: const EdgeInsets.fromLTRB(14, 5, 8, 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LiveDot(color: feed.online ? p.lv : p.mu, animate: feed.online),
                  const SizedBox(width: 8),
                  Text(feed.online ? l10n.cOnline : l10n.cOffline, style: CapText.sans(size: 13, weight: FontWeight.w600, color: p.tx)),
                  const SizedBox(width: 8),
                  CapSwitch(value: feed.online, semanticLabel: l10n.cOnline, onChanged: (_) => _toggleOnline()),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Glass(
          radius: 28,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KLabel(l10n.cTodaysEarnings),
                    Text(rupees(feed.todayEarnings), style: CapText.serif(size: 46, color: p.tx, height: 1)),
                    const SizedBox(height: 2),
                    Text(
                      l10n.cTripsGoal('${feed.todayTrips}', rupees(_goal).substring(1)),
                      style: CapText.sans(size: 13, color: p.mu),
                    ),
                  ],
                ),
              ),
              EarnRing(percent: percent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sheet(CapPalette p, {required Key key, required List<Widget> children, Widget? topBar}) {
    return Glass(
      key: key,
      radius: CapRadius.sheet,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [const GrabHandle(), ...children],
            ),
          ),
          if (topBar != null) Positioned(left: 20, right: 20, top: 0, child: topBar),
        ],
      ),
    );
  }

  Widget _buildSheet(CapPalette p) {
    final l10n = context.l10n;
    if (!feed.online) {
      return _sheet(p, key: const ValueKey('offline'), children: [
        Text(l10n.cOfflineTitle, style: CapText.serif(size: 32, color: p.tx)),
        const SizedBox(height: 6),
        Text(l10n.cOfflineDesc(l10n.cityName(feed.city)), style: CapText.sans(size: 14, color: p.mu)),
        const SizedBox(height: 16),
        CapButton(label: l10n.cGoOnline, icon: CapIcons.bolt, onPressed: _toggleOnline),
      ]);
    }

    if (feed.active.isNotEmpty) {
      final order = feed.active[_activeIndex % feed.active.length];
      return _ActiveTripSheet(
        key: ValueKey('active-${order['_id']}'),
        order: order,
        index: _activeIndex % feed.active.length,
        count: feed.active.length,
        onNext: () => setState(() => _activeIndex++),
        wrap: (children) => _sheet(p, key: ValueKey('active-sheet-${order['_id']}'), children: children),
      );
    }

    final open = feed.openOrders;
    if (open.isNotEmpty) {
      final i = _requestIndex % open.length;
      final order = open[i];
      return _sheet(
        p,
        key: ValueKey('req-${order['_id']}'),
        topBar: _Countdown(key: ValueKey('cd-${order['_id']}'), onDone: () => _skip(order, expired: true)),
        children: [_RequestContent(order: order, index: i, count: open.length, onSkip: () => _skip(order, expired: false))],
      );
    }

    return _sheet(p, key: const ValueKey('empty'), children: [
      Text(l10n.cAllCaughtUp, style: CapText.serif(size: 32, color: p.tx)),
      const SizedBox(height: 6),
      Text(l10n.cAllCaughtUpDesc(l10n.cityName(feed.city)), style: CapText.sans(size: 14, color: p.mu, height: 1.45)),
      const SizedBox(height: 12),
      CapButton(label: l10n.cBrowseOrders, style: CapButtonStyle.ghost, onPressed: () => widget.onSelectTab(NavMain.orders)),
    ]);
  }
}

/// `.cd`: amber bar that shrinks over 25 s; the request then moves to Missed.
class _Countdown extends StatefulWidget {
  final VoidCallback onDone;
  const _Countdown({super.key, required this.onDone});

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 25))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
    })
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: 1 - _c.value,
          child: Container(
            height: 3,
            decoration: BoxDecoration(color: p.am, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4))),
          ),
        ),
      ),
    );
  }
}

/// A new request: type tag, customer, pickup → drop, distance/deliver-by, pay tag, fare, Skip + slide to accept.
class _RequestContent extends StatefulWidget {
  final Map<String, dynamic> order;
  final int index;
  final int count;
  final VoidCallback onSkip;

  const _RequestContent({required this.order, required this.index, required this.count, required this.onSkip});

  @override
  State<_RequestContent> createState() => _RequestContentState();
}

class _RequestContentState extends State<_RequestContent> {
  bool _accepting = false;

  Future<void> _accept() async {
    setState(() => _accepting = true);
    await acceptOrderWithFeedback(context, widget.order);
    if (mounted) setState(() => _accepting = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final l10n = context.l10n;
    final o = CapOrder(widget.order);
    final hasDistance = o.distance != null && !o.isStore;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Flexible(child: CapTag(o.kindLabel(l10n), leading: const LiveDot())),
            const Spacer(),
            Text('#${o.shortId} · ${widget.index + 1}/${widget.count}', style: CapText.mono(size: 12, weight: FontWeight.w400, color: p.mu)),
          ],
        ),
        if (o.customerName != null && !o.isStore) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              CapAvatar(name: o.customerName!, size: 30),
              const SizedBox(width: 8),
              Flexible(child: Text(o.customerName!, maxLines: 1, overflow: TextOverflow.ellipsis, style: CapText.sans(size: 14, weight: FontWeight.w700, color: p.tx))),
            ],
          ),
        ],
        const SizedBox(height: 14),
        RouteTimeline(pickup: o.pickupAddress, drop: o.dropAddress, pickupLabel: o.isStore ? l10n.storeLocation : null),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KLabel(hasDistance ? l10n.cDistance : l10n.cDeliverBy),
                  Text(
                    hasDistance ? o.distance! : (o.whenLabel() ?? l10n.cToday),
                    style: CapText.sans(size: 14, weight: FontWeight.w600, color: p.tx),
                  ),
                  const SizedBox(height: 6),
                  o.isCod
                      ? CapTag(l10n.cCodCollect('${o.codAmount}'), color: CapPalette.cod, background: CapPalette.cod.withValues(alpha: 0.15))
                      : CapTag(o.payLabel(l10n)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                KLabel(l10n.cYouEarn),
                Text(rupees(o.fare), style: CapText.serif(size: 38, color: p.amx, height: 1)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            CapChip(
              label: l10n.cSkip,
              height: 60,
              radius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              onTap: _accepting ? null : widget.onSkip,
            ),
            const SizedBox(width: 12),
            Expanded(child: SlideToAct(label: l10n.cSlideToAccept, loading: _accepting, onAction: _accept)),
          ],
        ),
      ],
    );
  }
}

/// The rider's accepted order on Home: stage, destination, call/navigate, cash info, and a button into the trip.
class _ActiveTripSheet extends StatelessWidget {
  final Map<String, dynamic> order;
  final int index;
  final int count;
  final VoidCallback onNext;
  final Widget Function(List<Widget> children) wrap;

  const _ActiveTripSheet({super.key, required this.order, required this.index, required this.count, required this.onNext, required this.wrap});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final l10n = context.l10n;
    final o = CapOrder(order);
    final started = o.riderStatus.toLowerCase() == 'in transit';
    final stage = tripStageLabel(l10n, o, started);
    final target = started ? o.dropAddress : o.pickupAddress;
    final sub = [
      if (o.customerName != null && !o.isStore) o.customerName!,
      o.isCod ? l10n.cCodShort('${o.codAmount}') : o.payLabel(l10n),
    ].join(' · ');

    return wrap([
      Row(
        children: [
          Flexible(child: CapTag(stage, leading: const LiveDot())),
          const Spacer(),
          GestureDetector(
            onTap: count > 1 ? onNext : null,
            child: Text(
              count > 1 ? '#${o.shortId} · ${index + 1}/$count' : '#${o.shortId}',
              style: CapText.mono(size: 12, weight: FontWeight.w400, color: p.mu),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(target.isEmpty ? '—' : target, maxLines: 2, overflow: TextOverflow.ellipsis, style: CapText.serif(size: 24, color: p.tx, height: 1.1)),
                const SizedBox(height: 4),
                Text(sub, style: CapText.sans(size: 13, color: p.mu)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (o.phone != null) ...[
            IconBox(icon: CapIcons.phone, iconSize: 18, tooltip: l10n.callCustomer, onTap: () => callCustomer(context, order)),
            const SizedBox(width: 8),
          ],
          IconBox(icon: CapIcons.nav, iconSize: 18, tooltip: l10n.navigateToDestination, onTap: () => openNavigation(context, order, toPickup: !started)),
        ],
      ),
      const SizedBox(height: 12),
      if (o.isCod)
        CodBanner(
          title: l10n.cCollectCash('${o.codAmount}'),
          subtitle: l10n.cCodOrder,
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              KLabel(l10n.cYouEarn, size: 10, padding: EdgeInsets.zero),
              Text(rupees(o.fare), style: CapText.sans(size: 15, weight: FontWeight.w700, color: p.amx)),
            ],
          ),
        )
      else
        PrepaidStrip(l10n.cPrepaidNoCash),
      const SizedBox(height: 14),
      CapButton(
        label: l10n.cOpenTrip,
        trailingIcon: CapIcons.arr,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TripFlowPage(tripId: 'trip_${order['_id']}', order: order, endpointPost: order['endpointPost'] ?? ''),
          ),
        ),
      ),
    ]);
  }
}

/// Stage name shown in the trip tag, per order type.
String tripStageLabel(AppLocalizations l10n, CapOrder o, bool started) {
  if (o.isRide) return started ? l10n.cRideInProgress : l10n.cHeadingToPickup;
  if (o.isStore) return started ? l10n.cOnTheWay : l10n.cHeadingToStore;
  return started ? l10n.cOnTheWay : l10n.cHeadingToPickup;
}

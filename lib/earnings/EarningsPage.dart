import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../global/l10n.dart';
import '../model/cap_order.dart';
import '../services/rider_feed.dart';
import '../settings/sub_pages.dart';
import '../ui/cap_visuals.dart';
import '../ui/widgets.dart';

enum _Tab { earnings, wallet, bonus }

enum _Range { day, week, month }

/// The website's Earnings tab with its Earnings / Wallet / Bonus sections.
/// Figures come from delivered orders whose latest rider is this rider.
class EarningsPage extends StatefulWidget {
  final VoidCallback? onGoHome;
  const EarningsPage({super.key, this.onGoHome});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _Series {
  final List<double> values;
  final List<String> labels;
  final List<Map<String, dynamic>> trips;
  const _Series(this.values, this.labels, this.trips);
  double get total => values.fold(0, (a, b) => a + b);
}

class _EarningsPageState extends State<EarningsPage> {
  _Tab _tab = _Tab.earnings;
  _Range _range = _Range.day;

  RiderFeed get feed => RiderFeed.instance;

  _Series _series() {
    final l10n = context.l10n;
    final delivered = feed.delivered;
    final today = RiderFeed.startOfToday;
    switch (_range) {
      case _Range.day:
        final trips = feed.deliveredSince(today);
        final slots = List<double>.filled(5, 0);
        for (final o in trips) {
          final h = RiderFeed.completedAt(o).hour;
          final i = h < 11 ? 0 : h < 14 ? 1 : h < 17 ? 2 : h < 21 ? 3 : 4;
          slots[i] += CapOrder(o).fare;
        }
        return _Series(slots, [l10n.cSlotMorning, l10n.cSlotNoon, l10n.cSlotAfternoon, l10n.cSlotEvening, l10n.cSlotNight], trips);
      case _Range.week:
      case _Range.month:
        final days = _range == _Range.week ? 7 : 30;
        final start = today.subtract(Duration(days: days - 1));
        final values = List<double>.filled(days, 0);
        final trips = <Map<String, dynamic>>[];
        for (final o in delivered) {
          final t = RiderFeed.completedAt(o);
          if (t.isBefore(start)) continue;
          final i = DateTime(t.year, t.month, t.day).difference(start).inDays;
          if (i < 0 || i >= days) continue;
          values[i] += CapOrder(o).fare;
          trips.add(o);
        }
        final List<String> labels;
        if (_range == _Range.week) {
          final names = l10n.cDays.split(',');
          labels = [for (var i = 0; i < 7; i++) names[start.add(Duration(days: i)).weekday % 7]];
        } else {
          labels = [l10n.c30dAgo, l10n.c15d, l10n.cToday];
        }
        return _Series(values, labels, trips);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: feed,
      builder: (context, _) {
        return CapPage(
          onRefresh: feed.refreshHistory,
          children: [
            Align(alignment: Alignment.centerLeft, child: CapChip.back(context, label: l10n.cNavHome, onTap: widget.onGoHome)),
            const SizedBox(height: 14),
            CapSeg<_Tab>(
              value: _tab,
              onChanged: (v) => setState(() => _tab = v),
              items: [
                SegItem(_Tab.earnings, l10n.cEarningsTab),
                SegItem(_Tab.wallet, l10n.cWalletTab),
                SegItem(_Tab.bonus, l10n.cBonusTab),
              ],
            ),
            const SizedBox(height: 18),
            if (!feed.historyLoaded)
              const SkeletonBox(height: 320, radius: CapRadius.glass)
            else
              switch (_tab) {
                _Tab.earnings => _earnings(),
                _Tab.wallet => _wallet(),
                _Tab.bonus => _bonus(),
              },
          ],
        );
      },
    );
  }

  Widget _earnings() {
    final p = context.cap;
    final l10n = context.l10n;
    final s = _series();
    final title = switch (_range) { _Range.day => l10n.cYourDay, _Range.week => l10n.cYourWeek, _Range.month => l10n.cYourMonth };
    final sub = switch (_range) { _Range.day => l10n.cTripsToday, _Range.week => l10n.cTrips7d, _Range.month => l10n.cTrips30d };

    // Split by order source.
    var rides = 0, parcels = 0, store = 0;
    for (final o in s.trips) {
      final c = CapOrder(o);
      switch (c.kind) {
        case OrderKind.ride:
          rides += c.fare;
        case OrderKind.parcel:
          parcels += c.fare;
        case OrderKind.store:
          store += c.fare;
      }
    }
    final sum = rides + parcels + store;
    final parts = [(l10n.cGotanRides, rides), (l10n.cGotanParcels, parcels), (l10n.cDigistallStore, store)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KLabel(l10n.cNavEarnings),
        Row(
          children: [
            Expanded(child: Text(title, style: CapText.serif(size: 38, color: p.tx, height: 1))),
            CapSeg<_Range>(
              small: true,
              value: _range,
              onChanged: (v) => setState(() => _range = v),
              items: [SegItem(_Range.day, l10n.cToday), SegItem(_Range.week, l10n.cRange7D), SegItem(_Range.month, l10n.cRange30D)],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(rupees(s.total), style: CapText.serif(size: 56, color: p.tx, height: 1)),
        const SizedBox(height: 8),
        Row(
          children: [
            CapTag(l10n.cTripsCount('${s.trips.length}'), color: p.lv),
            const SizedBox(width: 8),
            Flexible(child: Text(sub, style: CapText.sans(size: 13, color: p.mu))),
          ],
        ),
        const SizedBox(height: 18),
        EarningsChart(key: ValueKey(_range), values: s.values, labels: s.labels),
        const SizedBox(height: 18),
        CapList(
          children: [
            for (final (label, amount) in parts)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(label, style: CapText.sans(size: 15, weight: FontWeight.w700, color: p.tx))),
                        Text(rupees(amount), style: CapText.sans(size: 15, weight: FontWeight.w700, color: p.tx)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _Bar(fraction: sum == 0 ? 0 : amount / sum, height: 6),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _wallet() {
    final p = context.cap;
    final l10n = context.l10n;
    var prepaid = 0, cash = 0;
    for (final o in feed.delivered) {
      final c = CapOrder(o);
      if (c.isCod) {
        cash += c.fare;
      } else {
        prepaid += c.fare;
      }
    }
    final recent = feed.delivered.take(15).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KLabel(l10n.cWalletTab),
        const SizedBox(height: 4),
        Glass(
          radius: 28,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KLabel(l10n.cPrepaidEarnings),
              const SizedBox(height: 2),
              Text(rupees(prepaid), style: CapText.serif(size: 52, color: p.tx, height: 1)),
              const SizedBox(height: 16),
              CapButton(label: l10n.cWithdrawToUpi, height: 52, onPressed: () => showCapToast(context, l10n.cWithdrawSoon)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CapList(
          children: [
            CapListItem(
              leading: const IconBox(icon: CapIcons.wal),
              trailing: Text(rupees(cash), style: CapText.sans(size: 15, weight: FontWeight.w700, color: p.tx)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.cCashInHand, style: CapText.sans(size: 15, weight: FontWeight.w700, color: p.tx)),
                  Text(l10n.cCashInHandSub, style: CapText.sans(size: 12, color: p.mu)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        KLabel(l10n.cRecentActivity, padding: const EdgeInsets.only(bottom: 10)),
        if (recent.isEmpty)
          CapListMessage(l10n.cNoTransactions)
        else
          CapList(
            children: [
              for (final o in recent)
                CapListItem(
                  leading: const IconBox(icon: CapIcons.chk),
                  trailing: Text('+${rupees(CapOrder(o).fare)}', style: CapText.sans(size: 15, weight: FontWeight.w700, color: p.lv)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.cTripActivity(CapOrder(o).shortId, CapOrder(o).kindLabel(l10n)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CapText.sans(size: 15, weight: FontWeight.w700, color: p.tx),
                      ),
                      Text(
                        '${l10n.statusDelivered} · ${DateFormat('d MMM, hh:mm a').format(RiderFeed.completedAt(o))}',
                        style: CapText.sans(size: 12, color: p.mu),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _bonus() {
    final p = context.cap;
    final l10n = context.l10n;
    final todayTrips = feed.todayTrips;
    final weekTrips = feed.deliveredSince(RiderFeed.startOfToday.subtract(const Duration(days: 6))).length;
    final targets = [(l10n.cDailyTarget, todayTrips, 10, 150), (l10n.cWeeklyTarget, weekTrips, 50, 500)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            KLabel(l10n.cBonusTab, padding: EdgeInsets.zero),
            const SizedBox(width: 8),
            CapTag(l10n.cComingSoonTag, color: p.amx, size: 10),
          ],
        ),
        const SizedBox(height: 10),
        Glass(
          radius: 24,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconBox(icon: CapIcons.bolt, color: p.am, background: p.am.withValues(alpha: 0.15)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.cPeakHours, style: CapText.sans(size: 15, weight: FontWeight.w700, color: p.tx)),
                    Text(l10n.cPeakHoursSub, style: CapText.sans(size: 13, color: p.mu)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final (label, current, target, reward) in targets)
          CapList(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(label, style: CapText.sans(size: 15, weight: FontWeight.w700, color: p.tx))),
                      Text(rupees(reward), style: CapText.sans(size: 15, weight: FontWeight.w700, color: p.amx)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Bar(fraction: current / target, height: 8),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(l10n.cTripsProgress('${current.clamp(0, target)}', '$target'), style: CapText.sans(size: 13, color: p.mu)),
                      ),
                      CapChip(
                        label: current >= target ? l10n.cClaim : l10n.cInProgress,
                        enabled: current >= target,
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        background: p.s1,
                        onTap: () => showCapToast(context, l10n.cBonusSoon),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        const SizedBox(height: 4),
        CapButton(
          label: l10n.cReferCaptain,
          style: CapButtonStyle.ghost,
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReferPage())),
        ),
      ],
    );
  }
}

/// Progress bar with the mint→amber gradient.
class _Bar extends StatelessWidget {
  final double fraction;
  final double height;
  const _Bar({required this.fraction, required this.height});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return Container(
      height: height,
      decoration: BoxDecoration(color: p.s2, borderRadius: BorderRadius.circular(9)),
      alignment: Alignment.centerLeft,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: fraction.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => FractionallySizedBox(
          widthFactor: v,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              gradient: LinearGradient(colors: [p.lv, p.am]),
            ),
          ),
        ),
      ),
    );
  }
}

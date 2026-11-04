import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../NavMain.dart';
import '../global/Common.dart';
import '../global/l10n.dart';
import '../pages/DocumentUploadPage.dart';
import '../services/rider_feed.dart';
import '../ui/widgets.dart';
import 'SettingsPage.dart' show generateRiderIdCard;

/// Shared layout of the Profile sub-pages: "← Back" chip and a 40px serif title.
class _SubPage extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final List<Widget> children;
  final Future<void> Function()? onRefresh;

  const _SubPage({required this.title, required this.children, this.trailing, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return Scaffold(
      backgroundColor: p.bg,
      body: CapPage(
        onRefresh: onRefresh,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Row(children: [CapChip.back(context), const Spacer(), if (trailing != null) trailing!]),
          const SizedBox(height: 18),
          Text(title, style: CapText.serif(size: 40, color: p.tx, height: 1)),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Documents
// ---------------------------------------------------------------------------

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  bool _generating = false;

  Future<void> _idCard() async {
    setState(() => _generating = true);
    try {
      final pdf = await generateRiderIdCard();
      if (mounted) setState(() => _generating = false);
      await Printing.layoutPdf(onLayout: (_) => pdf);
    } catch (e) {
      debugPrint('Could not create rider card: $e');
      if (mounted) {
        setState(() => _generating = false);
        showCapToast(context, context.l10n.somethingWentWrong, color: context.cap.rd);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final feed = RiderFeed.instance;
    final docs = [
      (l10n.cAadhaar, feed.aadhaar, l10n.cUploadedVerified),
      (l10n.cLicence, feed.licence, l10n.cUploadedVerified),
      (l10n.cPaymentQr, feed.qrcode, l10n.cUploadedActive),
      (l10n.cProfilePhoto, feed.profile, l10n.cUploadedActive),
    ];
    return _SubPage(
      title: l10n.cDocuments,
      onRefresh: feed.loadProfile,
      children: [
        ListenableBuilder(
          listenable: feed,
          builder: (context, _) {
            final p = context.cap;
            return CapList(
              children: [
                for (final (name, url, okLabel) in docs)
                  CapListItem(
                    leading: IconBox(icon: url.isNotEmpty ? CapIcons.shield : CapIcons.doc, color: url.isNotEmpty ? p.lv : p.am),
                    trailing: CapTag(url.isNotEmpty ? okLabel : l10n.cNotUploaded, color: url.isNotEmpty ? p.lv : p.amx, size: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: CapText.sans(size: 15, weight: FontWeight.w700, color: p.tx)),
                        url.isNotEmpty
                            ? GestureDetector(
                                onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
                                child: Text(l10n.cViewDocument,
                                    style: CapText.sans(size: 12, color: p.amx).copyWith(decoration: TextDecoration.underline, decorationColor: p.amx)),
                              )
                            : Text(l10n.cStoredSecurely, style: CapText.sans(size: 12, color: p.mu)),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        CapButton(label: l10n.cDownloadIdCard, icon: CapIcons.doc, loading: _generating, onPressed: _idCard),
        const SizedBox(height: 10),
        CapButton(
          label: l10n.cUploadDocUpdate,
          icon: CapIcons.up,
          style: CapButtonStyle.ghost,
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DocumentUploadPage(fromProfile: true))),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Alerts
// ---------------------------------------------------------------------------

class _Alert {
  final String id;
  final CapIcons icon;
  final String title;
  final String desc;
  final String time;
  final bool live;
  final String badge;
  final VoidCallback? onTap;
  const _Alert(this.id, this.icon, this.title, this.desc, this.time, this.live, this.badge, this.onTap);
}

/// Live state (active trip, open orders, online) plus the rider's notifications from `api/notifications`.
class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  List<Map<String, dynamic>> _notifications = [];

  String get _email => RiderFeed.instance.email;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_email.isEmpty) return;
    try {
      final uri = Uri.parse('${Common.baseUrl}api/notifications?recipientId=${Uri.encodeQueryComponent(_email)}&role=rider&limit=30');
      final response = await http.get(uri);
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['notifications'] is List && mounted) {
        setState(() => _notifications = List<Map<String, dynamic>>.from(data['notifications']));
      }
    } catch (e) {
      debugPrint('Error fetching rider notifications: $e');
    }
  }

  Future<void> _markRead({String? id}) async {
    try {
      await http.post(
        Uri.parse('${Common.baseUrl}api/notifications/mark-read'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(id == null ? {'recipientId': _email, 'role': 'rider'} : {'id': id, 'recipientId': _email}),
      );
      if (!mounted) return;
      setState(() {
        for (final n in _notifications) {
          if (id == null || n['_id'] == id) n['isRead'] = true;
        }
      });
    } catch (_) {}
  }

  void _goTab(int tab) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    NavMain.selectTab(tab);
  }

  String _ago(String? iso) {
    final l10n = context.l10n;
    final t = DateTime.tryParse(iso ?? '');
    if (t == null) return l10n.cJustNow;
    final s = DateTime.now().difference(t).inSeconds;
    if (s < 45) return l10n.cJustNow;
    if (s < 3600) return l10n.cMinutesAgo('${s ~/ 60}');
    if (s < 86400) return l10n.cHoursAgo('${s ~/ 3600}');
    return l10n.cDaysAgo('${s ~/ 86400}');
  }

  CapIcons _iconFor(String type) {
    final t = type.toUpperCase();
    if (t.contains('TAKEN') || t.contains('CANCEL')) return CapIcons.bolt;
    if (t.contains('DELIVER') || t.contains('COMPLETE')) return CapIcons.shield;
    if (t.contains('WAITING')) return CapIcons.clock;
    return CapIcons.bell;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final feed = RiderFeed.instance;
    final unread = _notifications.where((n) => n['isRead'] != true).length;
    return ListenableBuilder(
      listenable: feed,
      builder: (context, _) {
        final p = context.cap;
        final city = l10n.cityName(feed.city);
        final open = feed.online ? feed.openOrders.length : 0;
        final alerts = <_Alert>[
          if (feed.active.isNotEmpty)
            _Alert('active', CapIcons.car, l10n.cActiveTripAlert, '${feed.active.first['pickupAddress'] ?? feed.active.first['sellerAddress'] ?? ''} → ${feed.active.first['deliveryAddress'] ?? feed.active.first['address'] ?? ''}',
                l10n.cLiveNow, true, l10n.cBadgeOngoing, () => _goTab(NavMain.home)),
          if (open > 0) _Alert('open', CapIcons.bolt, l10n.cOrdersAvailable('$open'), l10n.cOrdersAvailableDesc(city), l10n.cLiveNow, true, l10n.cBadgeNew, () => _goTab(NavMain.orders)),
          for (final n in _notifications)
            _Alert(
              n['_id']?.toString() ?? '',
              _iconFor(n['type']?.toString() ?? ''),
              n['title']?.toString() ?? '',
              n['message']?.toString() ?? '',
              _ago(n['createdAt']?.toString()),
              n['isRead'] != true,
              n['isRead'] == true ? l10n.cBadgeRead : l10n.cBadgeAlert,
              () {
                if (n['isRead'] != true) _markRead(id: n['_id']?.toString());
                _goTab(NavMain.orders);
              },
            ),
          feed.online
              ? _Alert('online', CapIcons.shield, l10n.cCockpitOnline, l10n.cCockpitOnlineDesc(city), l10n.cActive, false, l10n.cOnline.toUpperCase(), null)
              : _Alert('offline', CapIcons.moon, l10n.cCockpitOffline, l10n.cCockpitOfflineDesc, l10n.cPaused, false, l10n.cOffline.toUpperCase(), null),
        ];

        return _SubPage(
          title: l10n.cAlerts,
          onRefresh: _load,
          trailing: unread > 0
              ? CapChip(label: l10n.cMarkAllRead, color: p.lv, height: 34, onTap: () => _markRead())
              : null,
          children: [
            if (unread > 0 || alerts.any((a) => a.live))
              Align(
                alignment: Alignment.centerLeft,
                child: CapTag(unread > 0 ? l10n.cNewAlerts('$unread') : l10n.cLiveAlerts, color: p.lv, leading: const LiveDot()),
              ),
            const SizedBox(height: 14),
            CapList(
              children: [
                for (final a in alerts)
                  CapListItem(
                    onTap: a.onTap,
                    leading: IconBox(
                      icon: a.icon,
                      color: a.live ? p.lv : p.am,
                      background: a.live ? p.lv.withValues(alpha: 0.14) : p.am.withValues(alpha: 0.12),
                    ),
                    trailing: CapTag(a.badge, size: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(child: Text(a.title, style: CapText.sans(size: 15, weight: FontWeight.w700, color: p.tx))),
                            if (a.live) ...[const SizedBox(width: 8), const LiveDot()],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(a.desc, style: CapText.sans(size: 12.5, color: p.mu)),
                        const SizedBox(height: 3),
                        Text(a.time, style: CapText.sans(size: 11, color: p.mu)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Refer & earn
// ---------------------------------------------------------------------------

class ReferPage extends StatelessWidget {
  const ReferPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final l10n = context.l10n;
    final steps = [(l10n.cReferStep1, l10n.cReferStep1Desc), (l10n.cReferStep2, l10n.cReferStep2Desc), (l10n.cReferStep3, l10n.cReferStep3Desc)];
    return _SubPage(
      title: l10n.cReferEarn,
      children: [
        Glass(
          radius: 28,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [Color(0x40FFB547), Color(0x00FFB547)], stops: [0, 0.7]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 36, 22, 36),
                child: Column(
                  children: [
                    IconBox(icon: CapIcons.bolt, size: 64, iconSize: 32, radius: 22, color: p.am, background: p.am.withValues(alpha: 0.15)),
                    const SizedBox(height: 16),
                    CapTag(l10n.cComingSoonTag, color: p.amx),
                    const SizedBox(height: 12),
                    Text(l10n.cReferSoonTitle, textAlign: TextAlign.center, style: CapText.serif(size: 28, color: p.tx, height: 1.2)),
                    const SizedBox(height: 12),
                    Text(l10n.cReferSoonDesc, textAlign: TextAlign.center, style: CapText.sans(size: 14.5, color: p.mu, height: 1.55)),
                    const SizedBox(height: 22),
                    CapButton(label: l10n.cNotifyMe, icon: CapIcons.bell, onPressed: () => showCapToast(context, l10n.cNotifyMeToast)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        CapList(
          children: [
            for (var i = 0; i < steps.length; i++)
              CapListItem(
                leading: IconBox(child: Text('${i + 1}', style: CapText.mono(size: 15, weight: FontWeight.w600, color: p.tx))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(steps[i].$1, style: CapText.sans(size: 15, weight: FontWeight.w700, color: p.tx)),
                    Text(steps[i].$2, style: CapText.sans(size: 12.5, color: p.mu)),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Help & support
// ---------------------------------------------------------------------------

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  int _open = -1;

  Future<void> _launch(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication) && mounted) {
      showCapToast(context, context.l10n.somethingWentWrong, color: context.cap.rd);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final l10n = context.l10n;
    final faqs = [(l10n.cFaq1Q, l10n.cFaq1A), (l10n.cFaq2Q, l10n.cFaq2A), (l10n.cFaq3Q, l10n.cFaq3A), (l10n.cFaq4Q, l10n.cFaq4A)];
    return _SubPage(
      title: l10n.cHelpSupport,
      children: [
        CapList(
          children: [
            for (var i = 0; i < faqs.length; i++)
              CapListItem(
                onTap: () => setState(() => _open = _open == i ? -1 : i),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(faqs[i].$1, style: CapText.sans(size: 14.5, weight: FontWeight.w700, color: p.tx))),
                          CapIcon(_open == i ? CapIcons.x : CapIcons.chev, size: 16, color: p.mu),
                        ],
                      ),
                      if (_open == i) ...[
                        const SizedBox(height: 10),
                        Text(faqs[i].$2, style: CapText.sans(size: 13.5, color: p.mu, height: 1.5)),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(child: CapButton(label: l10n.privacyPolicy, style: CapButtonStyle.ghost, fontSize: 14, onPressed: () => _launch('https://rider.digistall.in/privacy-policy'))),
            const SizedBox(width: 8),
            Expanded(child: CapButton(label: l10n.terms, fontSize: 14, onPressed: () => _launch('https://digistall.in/terms_and_conditions'))),
          ],
        ),
      ],
    );
  }
}

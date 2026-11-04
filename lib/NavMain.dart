import 'package:digirider/booking/IncomingBookingPage.dart';
import 'package:digirider/earnings/EarningsPage.dart';
import 'package:digirider/history/HistoryPage.dart';
import 'package:digirider/home/HomePage.dart';
import 'package:digirider/settings/SettingsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'global/l10n.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/rider_feed.dart';
import 'ui/widgets.dart';
import 'utils/show_exit_dialog.dart';

/// The rider's main shell: five tabs in the website's floating glass nav.
/// 0 = Home (map, incoming requests, active trip), 1 = Orders, 2 = Trips, 3 = Earnings, 4 = Profile.
class NavMain extends StatefulWidget {
  final int initialIndex;
  const NavMain({super.key, this.initialIndex = 0});

  static const int home = 0;
  static const int orders = 1;
  static const int trips = 2;
  static const int earnings = 3;
  static const int profile = 4;

  // Lets notification taps switch tabs without rebuilding the whole navigation stack.
  static final ValueNotifier<int?> _tabRequest = ValueNotifier<int?>(null);
  // A counter, not a bool: when one NavMain replaces another, the new one mounts before the old one disposes.
  static int _mountedCount = 0;
  static bool get isMounted => _mountedCount > 0;

  static void selectTab(int index) {
    _tabRequest.value = null;
    _tabRequest.value = index;
  }

  @override
  State<NavMain> createState() => _NavMainState();
}

class _NavMainState extends State<NavMain> with WidgetsBindingObserver {
  late int _currentIndex;

  static const List<CapIcons> _icons = [CapIcons.home, CapIcons.list, CapIcons.hist, CapIcons.wal, CapIcons.me];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _icons.length - 1);
    NavMain._mountedCount++;
    NavMain._tabRequest.addListener(_onTabRequest);
    WidgetsBinding.instance.addObserver(this);
    RiderFeed.instance.start();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await NotificationService().isEnabled()) {
        await NotificationService().requestPermission();
        await NotificationService().syncToken();
      }
      await LocationService().start();
    });
  }

  @override
  void dispose() {
    NavMain._mountedCount--;
    NavMain._tabRequest.removeListener(_onTabRequest);
    WidgetsBinding.instance.removeObserver(this);
    RiderFeed.instance.stop();
    if (!NavMain.isMounted) LocationService().stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      LocationService().start();
      RiderFeed.instance.refreshAll();
    } else if (state == AppLifecycleState.detached) {
      LocationService().stop();
    }
  }

  void _onTabRequest() {
    final index = NavMain._tabRequest.value;
    if (index != null && mounted) _selectTab(index);
  }

  void _selectTab(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  Widget _buildPage() {
    switch (_currentIndex) {
      case NavMain.orders:
        return IncomingBookingPage(onGoHome: () => _selectTab(NavMain.home));
      case NavMain.trips:
        return HistoryPage(onGoHome: () => _selectTab(NavMain.home));
      case NavMain.earnings:
        return EarningsPage(onGoHome: () => _selectTab(NavMain.home));
      case NavMain.profile:
        return SettingsPage(onGoHome: () => _selectTab(NavMain.home));
      default:
        return HomePage(onSelectTab: _selectTab);
    }
  }

  String _label(int index) {
    final l10n = context.l10n;
    switch (index) {
      case NavMain.orders:
        return l10n.cNavOrders;
      case NavMain.trips:
        return l10n.cNavTrips;
      case NavMain.earnings:
        return l10n.cNavEarnings;
      case NavMain.profile:
        return l10n.cNavProfile;
      default:
        return l10n.cNavHome;
    }
  }

  Future<void> _onBack() async {
    if (_currentIndex != NavMain.home) {
      _selectTab(NavMain.home);
      return;
    }
    if (await showExitConfirmationDialog(context)) SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: capOverlay(p),
        child: Scaffold(
          backgroundColor: p.bg,
          body: Stack(
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  child: KeyedSubtree(key: ValueKey(_currentIndex), child: _buildPage()),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 16 + bottomInset,
                child: Center(
                  child: ListenableBuilder(
                    listenable: RiderFeed.instance,
                    builder: (context, _) {
                      final feed = RiderFeed.instance;
                      final openCount = feed.online ? feed.openOrders.length : 0;
                      return _GlassNav(
                        icons: _icons,
                        labels: [for (var i = 0; i < _icons.length; i++) _label(i)],
                        current: _currentIndex,
                        badges: {NavMain.orders: openCount},
                        onTap: _selectTab,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `.nav-glass`: frosted pill; the current tab is a filled pill with its label.
class _GlassNav extends StatelessWidget {
  final List<CapIcons> icons;
  final List<String> labels;
  final int current;
  final Map<int, int> badges;
  final ValueChanged<int> onTap;

  const _GlassNav({required this.icons, required this.labels, required this.current, required this.badges, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        boxShadow: const [BoxShadow(color: Color(0x59000000), blurRadius: 36, offset: Offset(0, 16))],
      ),
      child: Glass(
        radius: 99,
        blur: 24,
        shadow: false,
        padding: const EdgeInsets.all(6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < icons.length; i++) ...[
              if (i > 0) const SizedBox(width: 3),
              _NavButton(
                icon: icons[i],
                label: labels[i],
                selected: i == current,
                badge: badges[i] ?? 0,
                onTap: () => onTap(i),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final CapIcons icon;
  final String label;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.label, required this.selected, required this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final fg = selected ? p.bg : p.mu;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 46,
          constraints: const BoxConstraints(minWidth: 46),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: selected ? p.tx : Colors.transparent, borderRadius: BorderRadius.circular(99)),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CapIcon(icon, size: 20, color: fg),
                    if (selected) ...[
                      const SizedBox(width: 8),
                      Text(label, style: CapText.sans(size: 13, weight: FontWeight.w600, color: fg)),
                    ],
                  ],
                ),
              ),
              if (badge > 0 && !selected)
                Positioned(
                  top: 0,
                  right: -10,
                  child: Container(
                    height: 16,
                    constraints: const BoxConstraints(minWidth: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: p.am, borderRadius: BorderRadius.circular(9)),
                    child: Text(badge > 99 ? '99+' : '$badge', style: CapText.sans(size: 10, weight: FontWeight.w600, color: p.on)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

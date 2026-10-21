import 'package:digirider/booking/IncomingBookingPage.dart';
import 'package:digirider/earnings/EarningsPage.dart';
import 'package:digirider/home/HomePage.dart';
import 'package:digirider/providers/NotificationProvider.dart';
import 'package:digirider/settings/SettingsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'global/Common.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';

class NavMain extends StatefulWidget {
  final int initialIndex;
  const NavMain({super.key, this.initialIndex = 1}); // default to Home

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

  // 0 = incoming bookings, 1 = my orders, 2 = earnings, 3 = settings
  static const List<String> _icons = [
    'assets/Icons/truck.svg',
    'assets/Icons/home1.svg',
    'assets/Icons/money-rupee-circle-fill.svg',
    'assets/Icons/settings.svg',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    NavMain._mountedCount++;
    NavMain._tabRequest.addListener(_onTabRequest);
    WidgetsBinding.instance.addObserver(this);

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
    if (!NavMain.isMounted) LocationService().stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      LocationService().start();
    } else if (state == AppLifecycleState.detached) {
      LocationService().stop();
    }
  }

  void _onTabRequest() {
    final index = NavMain._tabRequest.value;
    if (index != null && mounted) _selectTab(index);
  }

  void _selectTab(int index) {
    if (index == 1) {
      Provider.of<NotificationProvider>(context, listen: false).hideBadge();
    }
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildPage() {
    switch (_currentIndex) {
      case 0:
        return IncomingBookingPage();
      case 2:
        return EarningsPage();
      case 3:
        return SettingsPage();
      default:
        return HomePage();
    }
  }

  Widget _buildTab(int index, bool showBadge) {
    final selected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectTab(index),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black,
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: selected ? MainAxisAlignment.start : MainAxisAlignment.center,
                children: [
                  if (selected) SizedBox(height: 10),
                  SvgPicture.asset(_icons[index], width: 22, height: 22, color: Common.primary),
                  if (selected) ...[
                    SizedBox(height: 5),
                    Container(height: 2, width: 22, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(2))),
                  ]
                ],
              ),
              if (showBadge && !selected)
                Positioned(
                  top: 10,
                  right: MediaQuery.of(context).size.width / _icons.length * 0.25,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Common.secondary,
      ),
      child: SafeArea(
        bottom: true,
        child: Scaffold(
          body: _buildPage(),
          bottomNavigationBar: Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(12), topLeft: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < _icons.length; i++)
                      _buildTab(i, i == 1 && provider.showHomeBadge),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

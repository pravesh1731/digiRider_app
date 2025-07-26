import 'package:digirider/booking/IncomingBookingPage.dart';
import 'package:digirider/dashboard/DashboardPage.dart';
import 'package:digirider/home/HomePage.dart';
import 'package:digirider/providers/NotificationProvider.dart';
import 'package:digirider/settings/SettingsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'global/Common.dart';
import 'history/HistoryPage.dart';

class NavMain extends StatefulWidget {
  final int initialIndex; // <-- new
  const NavMain({super.key, this.initialIndex = 2}); // default to Home
  // const NavMain({super.key});

  @override
  State<NavMain> createState() => _NavMainState();
}

class _NavMainState extends State<NavMain> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // <-- initialize with passed index
  }

  List pages = [
    HistoryPage(),
    IncomingBookingPage(),
    HomePage(),
    DashboardPage(),
    SettingsPage(),
  ];

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

          // appBar: _currentIndex == 1 || _currentIndex == 2 ? null : AppBar(
          //   toolbarHeight: 60,
          //   leading: Padding(
          //     padding: const EdgeInsets.only(left: 8.0),
          //     child: Container(
          //       child: Center(
          //         child: SvgPicture.asset(
          //           'assets/Icons/settings.svg',
          //           color: Common.primary,
          //           width: 25,
          //           height: 25,
          //         ),
          //       ),
          //     ),
          //   ),
          //   actions: [
          //     Padding(
          //       padding: const EdgeInsets.only(right: 15.0),
          //       child: Image.asset('assets/Icons/refresh.png', width: 20, height: 20,),
          //     ),
          //   ],
          //   // title: Text('Incoming Bookings', style: TextStyle(fontSize: Common.title),),
          // ),

          body: pages[_currentIndex],

          bottomNavigationBar: Container(
            // height: 50,
            // width: double.infinity,
            decoration: BoxDecoration(
              // color: Colors.black,
              borderRadius: BorderRadius.only(topRight: Radius.circular(12), topLeft: Radius.circular(12),),
            ),
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 8,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30),),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        _currentIndex = 0;
                      });
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: _currentIndex==0 ? MainAxisAlignment.start : MainAxisAlignment.center,
                        children: [
                          _currentIndex==0 ? SizedBox(height: 10,) : SizedBox(height: 0,),
                          SvgPicture.asset('assets/Icons/history.svg', width: 22, height: 22, color: Common.primary),
                          if(_currentIndex == 0)...[
                            SizedBox(height: 5,),
                            Container(height: 2, width: 22, decoration: BoxDecoration( color: Colors.red, borderRadius: BorderRadius.circular(2)),)
                          ]

                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        _currentIndex = 1;
                      });
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: _currentIndex==1? MainAxisAlignment.start : MainAxisAlignment.center,
                        children: [
                          _currentIndex==1 ? SizedBox(height: 10,) : SizedBox(height: 0,),
                          SvgPicture.asset('assets/Icons/truck.svg', width: 22, height: 22, color: Common.primary),
                          if(_currentIndex == 1)...[
                            SizedBox(height: 5,),
                            Container(height: 2, width: 22, decoration: BoxDecoration( color: Colors.red, borderRadius: BorderRadius.circular(2)),)
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
                // In your bottom navigation bar widget:
                Consumer<NotificationProvider>(
                  builder: (context, provider, child) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          provider.hideBadge(); // Hide badge when home is tapped
                          setState(() {
                            _currentIndex = 2; // Home screen index
                          });
                        },
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
                                mainAxisAlignment: _currentIndex == 2
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.center,
                                children: [
                                  if (_currentIndex == 2) SizedBox(height: 10),
                                  SvgPicture.asset(
                                    'assets/Icons/home1.svg',
                                    width: 22,
                                    height: 22,
                                    color: Common.primary,
                                  ),
                                  if(_currentIndex == 2)...[
                                    SizedBox(height: 5,),
                                    Container(height: 2, width: 22, decoration: BoxDecoration( color: Colors.red, borderRadius: BorderRadius.circular(2)),)
                                  ]
                                ],
                              ),
                              if (provider.showHomeBadge && _currentIndex != 2)
                                Positioned(
                                  top: 10,
                                  right: MediaQuery.of(context).size.width * 0.06,
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
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        _currentIndex = 3;
                      });
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: _currentIndex==3? MainAxisAlignment.start : MainAxisAlignment.center,
                        children: [
                          _currentIndex==3 ? SizedBox(height: 10,) : SizedBox(height: 0,),
                          Image.asset('assets/Icons/activity.png', width: 22, height: 22, color: Common.primary,),
                          if(_currentIndex == 3)...[
                            SizedBox(height: 5,),
                            Container(height: 2, width: 22, decoration: BoxDecoration( color: Colors.red, borderRadius: BorderRadius.circular(2)),)
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        _currentIndex = 4;
                      });
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: _currentIndex==4? MainAxisAlignment.start : MainAxisAlignment.center,
                        children: [
                          _currentIndex==4 ? SizedBox(height: 10,) : SizedBox(height: 0,),
                          SvgPicture.asset('assets/Icons/settings.svg', width: 22, height: 22, color: Common.primary),
                          if(_currentIndex == 4)...[
                            SizedBox(height: 5,),
                            Container(height: 2, width: 22, decoration: BoxDecoration( color: Colors.red, borderRadius: BorderRadius.circular(2)),)
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  width: 8,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(30),),
                  ),
                ),
              ],
            ),
          ),

        ),
      ),
    );
  }
}

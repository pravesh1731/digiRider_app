import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

import '../global/Common.dart';
import '../utils/show_exit_dialog.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showExitConfirmationDialog(context),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              child: Center(
                child: Image.asset(
                  'assets/Icons/activity.png',
                  color: Common.primary,
                  width: 25,
                  height: 25,
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Image.asset('assets/Icons/refresh.png', width: 20, height: 20,),
            ),
          ],
          title: Text('Dashboard', style: TextStyle(fontSize: Common.title, fontFamily: Common.family),),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 220,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Lottie.asset('assets/animation/empty2.json', height: 200),
                    Positioned(
                      bottom: 30,
                      child: Text(
                        'You haven’t done anything yet',
                        style: TextStyle(
                          fontSize: Common.h2,
                          color: Colors.grey,
                          fontWeight: Common.weight,
                          fontFamily: 'bold'
                        ),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

import '../global/Common.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Container(
              height: 200,
              child: Lottie.asset('assets/animation/empty.json',),
            ),
            SizedBox(height: 10),
            Text(
              'You haven’t done anything yet',
              style: TextStyle(fontSize: Common.h1, color: Colors.grey, fontWeight: Common.weight),
            ),
          ],
        ),
      ),

    );
  }
}

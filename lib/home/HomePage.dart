import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../global/Common.dart';
import '../providers/trip_provider.dart';
import 'TripFlowPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            child: Center(
              child: SvgPicture.asset(
                'assets/Icons/home1.svg',
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
        title: Text('Home', style: TextStyle(fontSize: Common.title, fontFamily: Common.family),),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(right: 12.0, left: 12.0, top: 12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildOrderCard(orderId: '11'),
                SizedBox(height: 8,),
                _buildOrderCard(orderId: '12'),
                SizedBox(height: 8,),
                _buildOrderCard(orderId: '13'),
                SizedBox(height: 8,),
              ],
            ),
          ),
        ),
      ),

    );
  }
}

class _buildOrderCard extends StatelessWidget {
  final String orderId;
  const _buildOrderCard({
    super.key, required this.orderId
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
        builder: (context, tripProvider, child) {
        return Card(
          elevation: 5,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Common.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Align(
                  child: Text("16 Aug 2025, 10:00 AM", style: TextStyle(fontSize: 12, fontWeight: Common.weight, color: Common.secondary),),
                  alignment: Alignment.topRight,
                ),
                Row(
                  children: [
                    SvgPicture.asset('assets/Icons/location.svg', width: 24, height: 24, color: Color(0xFF58DE71),),
                    SizedBox(width: 16,),
                    Text('PICKUP', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight2, fontFamily: 'bold',),),
                  ],
                ),
                SizedBox(height: 2,),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // ensures vertical stretch
                    children: [
                      Container(
                        width: 24,
                        child: Center(
                          child: Container(
                            width: 1,
                            color: Common.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16), // optional spacing
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            '1234 Winding Creek Boulevard, Apt 208, Spring field, IL 62704, United States',
                            style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight, color: Common.light, fontFamily: Common.family),
                            softWrap: true,
                          ),
                        ),
                      ),
                      SizedBox(width: 8,)
                    ],
                  ),
                ),
                SizedBox(height: 2,),
                Row(
                  children: [
                    SvgPicture.asset('assets/Icons/location.svg', width: 24, height: 24, color: Color(0xFFED9D60),),
                    SizedBox(width: 16,),
                    Text('DROP', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight2, fontFamily: 'bold',),),
                  ],
                ),
                SizedBox(height: 2,),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40.0, right: 8),
                    child: Text(
                      '1234 Winding Creek Boulevard, Apt 208, Spring field, IL 62704, United States',
                      style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight, color: Common.light),
                      softWrap: true,
                    ),
                  ),
                ),
                SizedBox(height: 16,),
                Row(
                  children: [
                    SizedBox(width: 5,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PICKUP DISTANCE', style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight, color: Common.light),),
                          SizedBox(height: 3,),
                          Text('2.7 KM', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight2, fontFamily: 'bold',),)
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TRIP DISTANCE', style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight, color: Common.light),),
                          SizedBox(height: 3,),
                          Text('2.7 KM', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight2, fontFamily: 'bold',),)
                        ],
                      ),
                    ),
                    SizedBox(width: 16,),
                  ],
                ),
                SizedBox(height: 16,),
                Row(
                  children: [
                    SizedBox(width: 5,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EARNING', style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight, color: Common.light),),
                        SizedBox(height: 3,),
                        Text('55 '+'₹', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight, color: Colors.green,),)
                      ],
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () async {
                        // final prefs = await SharedPreferences.getInstance();
                        // final stageIndex = prefs.getInt('trip_stage_trip_$orderId');
                        // final hasProgress = stageIndex != null && stageIndex != 0;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TripFlowPage(tripId: "trip_$orderId"),
                          ),
                        );
                      },

                      child: FutureBuilder<bool>(
                        future: tripProvider.hasTripProgress("trip_$orderId"),
                        builder: (context, snapshot) {
                          bool showProgress = snapshot.data == true;

                          return showProgress ? Container(
                            height: 38,
                            // width: MediaQuery.of(context).size.width/2.5,
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              color: Color(0xFF000000),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'PROGRESS',
                                  style: TextStyle(
                                    fontSize: Common.h3,
                                    fontWeight: Common.weight,
                                    color: Common.primary,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  // child: Lottie.asset('assets/animation/progress.json'),
                                    child: SpinningLottie(),
                                )
                                //     :
                                // SvgPicture.asset(
                                //   'assets/Icons/view_detail_arrow.svg',
                                //   color: Colors.white,
                                //   height: 20,
                                //   width: 20,
                                // ),
                              ],
                            ),
                          ) : Container(
                            height: 38,
                            // width: MediaQuery.of(context).size.width/2.5,
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              color: Color(0xFF008BE1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'VIEW DETAILS',
                                  style: TextStyle(
                                    fontSize: Common.h3,
                                    fontWeight: Common.weight,
                                    color: Common.primary,
                                  ),
                                ),
                                SizedBox(width: 10),
                                // SizedBox(
                                //   height: 20,
                                //   width: 20,
                                //   child: Lottie.asset('assets/animation/progress.json'),
                                // )
                                //     :
                                SvgPicture.asset(
                                  'assets/Icons/view_detail_arrow.svg',
                                  color: Colors.white,
                                  height: 20,
                                  width: 20,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // SizedBox(width: 16,),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

class SpinningLottie extends StatefulWidget {
  @override
  _SpinningLottieState createState() => _SpinningLottieState();
}

class _SpinningLottieState extends State<SpinningLottie> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 1000))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animation/progress.json',
      controller: _controller,
    );
  }
}


// Future<bool> _hasTripProgress(String tripId) async {
//   final prefs = await SharedPreferences.getInstance();
//   final index = prefs.getInt('trip_stage_$tripId');
//   return index != null && index != TripStage.reachPickup.index;
// }


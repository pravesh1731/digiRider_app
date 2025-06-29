import 'package:digirider/NavMain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global/Common.dart';
import '../model/trip_stage.dart';
import '../providers/trip_provider.dart';

class TripFlowPage extends StatefulWidget {
  final String tripId;

  const TripFlowPage({super.key, required this.tripId});

  @override
  State<TripFlowPage> createState() => _TripFlowPageState();
}

class _TripFlowPageState extends State<TripFlowPage> {
  // TripStage currentStage = TripStage.reachPickup;

  @override
  void initState() {
    super.initState();
    // _loadStage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripProvider>(context, listen: false)
          .loadTripStage(widget.tripId);
    });

  }


  Future<bool> _callStageApi() async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(seconds: 1));

      return true; // simulate success
    } catch (e) {
      print('API Error: $e');
      return false;
    }
  }

  Future<void> _nextStage() async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    bool success = await _callStageApi();

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed. Please try again.')),
      );
      return;
    }

    await Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (_, __, ___) => const _SuccessOverlay(),
    ));

    // Handle stage transition
    if (tripProvider.currentStage == TripStage.inProgress) {
      await tripProvider.completeTrip();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavMain()),
      );
      return;
    }

    TripStage? nextStage;
    switch (tripProvider.currentStage) {
      case TripStage.reachPickup:
        nextStage = TripStage.readyToStart;
        break;
      // case TripStage.readyToStart:
      //   nextStage = TripStage.confirmOtp;
      //   break;
      // case TripStage.confirmOtp:
      //   nextStage = TripStage.inProgress;
      //   break;
      case TripStage.readyToStart:
        nextStage = TripStage.inProgress;
        break;
      case TripStage.inProgress:
      // Already handled above
        break;
      case null:
      // Optional: log or handle null case safely
        debugPrint("Current stage is null");
        break;
    }


    if (nextStage != null) {
      await tripProvider.updateTripStage(nextStage);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
        builder: (context, tripProvider, child) {
          final currentStage = tripProvider.currentStage ?? TripStage.reachPickup;

          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 60,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/Icons/truck.svg',
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
              title: Text(_getAppBarTitle(currentStage), style: TextStyle(fontSize: Common.title, fontFamily: Common.family),),
            ),

            body: Padding(
              padding: const EdgeInsets.only(right: 12.0, left: 12.0, top: 12, bottom: 20),
              child: Column(
                children: [
                  _buildContactCard(),
                  _buildLocationCard(),
                  if(currentStage == TripStage.reachPickup || currentStage == TripStage.inProgress)
                  _buildGoogleMapsButton(),
                  Spacer(),
                  if(currentStage == TripStage.reachPickup)
                  _buildCallCard(),
                  SizedBox(height: 8,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: SlideAction(
                      sliderButtonIconPadding: 5,
                      sliderButtonIconSize: 20,
                      sliderButtonYOffset: 10,
                      onSubmit: () {
                        Future.delayed(Duration(milliseconds: 200), () {
                          _nextStage();
                        });
                      },
                      height: 45,
                      sliderRotate: false,
                      innerColor: Common.primary, // Colors Inside
                      outerColor: Common.secondary, // Track and submitted Color
                      elevation: 5,
                      borderRadius: 30,
                      alignment: Alignment.center,
                      child: Text(_getBottomActionText(currentStage), style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight, color: Common.primary)), // You can add a text to the action
                    ),
                  ),
                ],
              ),
            ),
          );
      }
    );
  }

  String _getBottomActionText(TripStage stage) {
    switch (stage) {
      case TripStage.reachPickup:
        return "Pick up Arrived";
      case TripStage.readyToStart:
        return "Start the Trip";
      // case TripStage.confirmOtp:
      //   return "Confirm OTP";
      case TripStage.inProgress:
        return "Trip Completed";
    }
  }

  String _getAppBarTitle(TripStage stage) {
    switch (stage) {
      case TripStage.reachPickup:
        return "Reach Pickup";
      case TripStage.readyToStart:
        return "Trip Details";
      // case TripStage.confirmOtp:
      //   return "Trip Details";
      case TripStage.inProgress:
        return "Trip In Progress";
    }
  }

}

class _buildCallCard extends StatelessWidget {
  const _buildCallCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 5,
      child: Container(
        height: 45,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Common.secondary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/Icons/call.png', width: 15, height: 15, color: Color(0xFFFFFFFF),),
            SizedBox(width: 30,),
            Text('Call Customer', style: TextStyle(fontWeight: Common.weight, fontSize: Common.h2, color: Common.primary),),
          ],
        ),
      ),
    );
  }
}

class _buildGoogleMapsButton extends StatelessWidget {
  const _buildGoogleMapsButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        height: 45,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Common.secondary,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Launch Google Maps', style: TextStyle(fontWeight: Common.weight, fontSize: Common.h2, color: Common.primary),),
            SizedBox(width: 20,),
            SvgPicture.asset('assets/Icons/location.svg', width: 20, height: 20, color: Color(0xFFFFFFFF),),
          ],
        ),
      ),
    );
  }
}

class _buildContactCard extends StatelessWidget {
  const _buildContactCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Common.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Details', style: TextStyle(fontWeight: Common.weight, fontSize: Common.h1, color: Common.secondary),),
            Divider(),
            SizedBox(height: 6,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Name', style: TextStyle(fontWeight: Common.weight, fontSize: Common.h2, color: Common.secondary),),
                Text('Muralidharan U', style: TextStyle(fontWeight: Common.weight, fontSize: Common.h2, color: Common.secondary),),
              ],
            ),
            SizedBox(height: 6,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Phone No.', style: TextStyle(fontWeight: Common.weight, fontSize: Common.h2, color: Common.secondary),),
                Text('9363509503', style: TextStyle(fontWeight: Common.weight, fontSize: Common.h2, color: Common.secondary),),
              ],
            ),


          ],
        ),
      ),
    );
  }
}

class _buildLocationCard extends StatelessWidget {
  const _buildLocationCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                SvgPicture.asset('assets/Icons/location.svg', width: 24, height: 24, color: Color(0xFF58DE71),),
                SizedBox(width: 16,),
                Text('PICKUP', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight),),
              ],
            ),
            SizedBox(height: 6,),
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
                        style: TextStyle(fontSize: 12, fontWeight: Common.weight, color: Common.light),
                        softWrap: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 8,)
                ],
              ),
            ),
            SizedBox(height: 6,),
            Row(
              children: [
                SvgPicture.asset('assets/Icons/location.svg', width: 24, height: 24, color: Color(0xFFED9D60),),
                SizedBox(width: 16,),
                Text('DROP', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight),),
              ],
            ),
            SizedBox(height: 6,),
            Padding(
              padding: const EdgeInsets.only(left: 40.0, right: 8),
              child: Text(
                '1234 Winding Creek Boulevard, Apt 208, Spring field, IL 62704, United States',
                style: TextStyle(fontSize: Common.h3, fontWeight: Common.weight, color: Common.light),
                softWrap: true,
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class _SuccessOverlay extends StatefulWidget {
  const _SuccessOverlay({super.key});

  @override
  State<_SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<_SuccessOverlay> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // auto-close after 2 seconds
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Common.background,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // ✅ match your intended color
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      // backgroundColor: Colors.black.withOpacity(0.8),
      body: Center(
        child: SizedBox(
          height: 200,
          width: 200,
          child: Lottie.asset('assets/animation/success.json'),
        ),
      ),
    );
  }
}

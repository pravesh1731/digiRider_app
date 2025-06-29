import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global/Common.dart';
import '../pages/GoogleSignInUp.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  String name = '';
  String phone = '';
  String city = '';
  String vehicle = '';

  List options = [
    ['assets/Icons/location.svg', 'Gotan', 'assets/Icons/edit.svg', '0'],
    ['assets/Icons/bike.svg', 'Bike', 'assets/Icons/edit.svg', '0'],
    ['assets/Icons/bell.png', 'Allow Notification', 'assets/Icons/right-arrow.png', '1'],
    ['assets/Icons/logout.png', 'Logout', null , '1'],
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      phone = prefs.getString('phoneNumber') ?? '';
      city = prefs.getString('cityName') ?? '';
      vehicle = prefs.getString('vehicleType') ?? '';
      // update the options list here if needed
      options[0][1] = city;
      options[1][1] = vehicle;
    });
  }


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
                'assets/Icons/settings.svg',
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
            child: GestureDetector(
              onTap: _loadUserData, // refresh user data
              child: Image.asset('assets/Icons/refresh.png', width: 20, height: 20,),
            ),
          ),
        ],
        title: Text('Settings', style: TextStyle(fontSize: Common.title, fontFamily: Common.family),),
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.only(right: 12.0, left: 12.0, top: 12, bottom: 12),
          child: Column(
            children: [
              Card(
                elevation: 5,
                child: Container(
                  width: double.infinity,
                  // height: MediaQuery.of(context).size.height*2/9,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width/4,
                        height: MediaQuery.of(context).size.width/4,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text(name.isNotEmpty ? name : '-', style: TextStyle(fontWeight: Common.weight, fontSize: Common.h1, color: Common.secondary),),
                      SizedBox(height: 2,),
                      Text(phone.isNotEmpty ? '+91 '+phone : '-', style: TextStyle(fontWeight: Common.weight, fontSize: Common.h2, color: Common.secondary),)
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2,),
              Expanded(
                child: Card(
                  elevation: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Common.primary,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(height: 15,),
                          _buildListOptions(options[0]),
                          SizedBox(height: 2,),
                          Divider(color: Colors.grey.shade300,),
                          SizedBox(height: 2,),
                          _buildListOptions(options[1]),
                          SizedBox(height: 2,),
                          Divider(color: Colors.grey.shade300,),
                          SizedBox(height: 2,),
                          _buildListOptions(options[2]),
                          SizedBox(height: 2,),
                          Divider(color: Colors.grey.shade300,),
                          SizedBox(height: 2,),
                          _buildListOptions(options[3]),
                          Spacer(),
                          Text('Terms & Conditions', style: TextStyle(fontWeight: Common.weight, fontSize: Common.h3, color: Common.light),)
                        ],
                      ),
                    ),
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



class _buildListOptions extends StatelessWidget {
  List options;
  _buildListOptions(this.options, {super.key,});

  @override
  Widget build(BuildContext context) {

    Future<void> logout() async {
      final screenWidth = MediaQuery.of(context).size.width;

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Common.secondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          titlePadding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 15),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 15),
          actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
          title: Text(
            "CONFIRM LOGOUT",
            style: TextStyle(fontWeight: Common.weight, color: Common.primary, fontSize: Common.title,),
          ),
          content: SizedBox(
            width: screenWidth * 0.9,
            child: Text("Are you sure you want to logout?", style: TextStyle(color: Common.primary, fontWeight: Common.weight, fontSize: Common.h2,),),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Common.primary.withOpacity(0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text("Cancel", style: TextStyle(color: Common.primary, fontWeight: Common.weight, fontSize: Common.h2,)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => GoogleLoginPage()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Common.primary, // Tailwind blue-600
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text("Logout", style: TextStyle(color: Common.secondary, fontWeight: Common.weight, fontSize: Common.h2,)),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () async {
        if (options[1] == 'Logout') {
          logout();
        }
      },

      child: Row(
        children: [
          Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Common.secondary,
            ),
            child: Center(
              child: options[3]=='0'? SvgPicture.asset(options[0], color: Common.primary, width: 15, height: 15,) : Image.asset(options[0], color: Common.primary, width: 15, height: 15,),
            ),
          ),
          SizedBox(width: 20,),
          Expanded(child: Text(options[1], style: TextStyle(fontSize: Common.h2, color: Common.secondary, fontWeight: Common.weight,),)),
          if(options[2]!=null)
          Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              // color: Common.secondary,
            ),
            child: Center(
              child: options[3]=='0'? SvgPicture.asset(options[2], color: Common.secondary, width: 25, height: 25,) : (options[3]=='assets/Icons/right-arrow.png'? Image.asset(options[2], color: Common.secondary, width: 18, height: 18,): Image.asset(options[2], color: Common.secondary, width: 20, height: 20,)),
            ),
          ),
        ],
      ),
    );
  }


}

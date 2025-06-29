import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../global/Common.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  TextEditingController searchController = TextEditingController();
  // final searchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              child: Center(
                child: SvgPicture.asset(
                  'assets/Icons/history.svg',
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
          title: Text('History', style: TextStyle(fontSize: Common.title, fontFamily: Common.family),),
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.only(right: 12.0, left: 12.0, top: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          color: Common.secondary
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 16,),
                            // Expanded(child: Text('Search here', style: TextStyle(fontSize: Common.h1, fontWeight: Common.weight, color: Common.light),)),
                            Expanded(
                              child: TextField(
                                // focusNode: searchFocusNode,
                                controller: searchController,
                                style: TextStyle(
                                  color: Common.background,     // 👈 Text (user input) color
                                  fontSize: Common.h1,
                                  fontWeight: Common.weight,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search here',
                                  hintStyle: TextStyle(
                                    color: Common.background,      // 👈 Hint text color
                                    fontSize: Common.h1,
                                    fontWeight: Common.weight// 👈 Hint text size
                                  ),
                                ),
                                cursorColor: Common.background,
                              ),
                            ),
                            SizedBox(width: 16,),
                            Center(child: SvgPicture.asset('assets/Icons/search.svg', color: Common.background, width: 25, height: 25,),),
                            SizedBox(width: 16,),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12,),
                    Center(
                      child: Image.asset('assets/Icons/filter.png', width: 25, height: 25,),
                    ),
                    SizedBox(width: 6,),
                  ],
                ),
                SizedBox(height: 12,),
                Expanded(
                  child: ListView.builder(
                    itemCount: 6,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom:  8.0),
                        child: _buildOrderCard(),
                      );
                    },
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

class _buildOrderCard extends StatelessWidget {
  const _buildOrderCard({
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("16 Aug 2025, 10:00 AM", style: TextStyle(fontSize: 12, fontWeight: Common.weight, color: Common.secondary),),
                Text('55 '+'₹', style: TextStyle(fontSize: Common.h2, fontWeight: Common.weight2, color: Colors.green, fontFamily: null, inherit: false),)
              ],
            ),
            SizedBox(height: 12,),
            Row(
              children: [
                SvgPicture.asset('assets/Icons/location.svg', width: 24, height: 24, color: Color(0xFF58DE71),),
                SizedBox(width: 16,),
                Expanded(
                  child: Text(
                    '1234 Winding Creek Boulevard, Apt 208, Spring field, IL 62704, United States',
                    style: TextStyle(fontSize: 12, fontWeight: Common.weight, color: Common.light),
                    softWrap: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12,),
            Row(
              children: [
                SvgPicture.asset('assets/Icons/location.svg', width: 24, height: 24, color: Color(0xFFED9D60),),
                SizedBox(width: 16,),
                Expanded(
                  child: Text(
                    '1234 Winding Creek Boulevard, Apt 208, Spring field, IL 62704, United States',
                    style: TextStyle(fontSize: 12, fontWeight: Common.weight, color: Common.light),
                    softWrap: true,
                  ),
                ),
              ],
            ),
            // SizedBox(height: 12,),
          ],
        ),
      ),
    );
  }
}

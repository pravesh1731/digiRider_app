import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OrderTypeIcon extends StatelessWidget {
  final String orderType;
  const OrderTypeIcon({Key? key, required this.orderType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (orderType) {
      case 'Rider Orders':
        return SvgPicture.asset('assets/Icons/bike-svgrepo-com.svg', width: 28, height: 28, color: Color(0xFF008BE1));
      case 'Parcel Orders':
        return Image.asset('assets/Icons/activity.png', width: 28, height: 28, color: Color(0xFF58DE71));
      case 'Digistall Orders':
        return SvgPicture.asset('assets/Icons/store-svgrepo-com.svg', width: 28, height: 28, color: Colors.green);
      default:
        return Icon(Icons.local_shipping, size: 28);
    }
  }
}

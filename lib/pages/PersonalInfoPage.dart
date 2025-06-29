import 'dart:convert';

import 'package:digirider/booking/IncomingBookingPage.dart';
import 'package:digirider/pages/DocumentUploadPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:digirider/global/Common.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PersonalInfoPage extends StatefulWidget {
  final String riderDomain;
  final String email;

  const PersonalInfoPage({super.key, required this.riderDomain, required this.email});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedCity;
  String? _selectedVehicle;

  final List<String> cities = ['Jodhpur', 'Gotan'];
  final List<String> vehicles = ['Bike', 'Car', 'Auto'];

  void _onNextStep() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty ||
        phone.isEmpty ||
        phone.length != 10 ||
        _selectedCity == null ||
        _selectedVehicle == null ||
        widget.riderDomain.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all the details properly.')),
      );
      return;
    }

    _submitDetails();
  }

  Future<void> _submitDetails() async {
    final payload = {
      "name": _nameController.text.trim(),
      "email": widget.email, // You can fetch from FirebaseAuth or another source
      "cityName": _selectedCity!,
      "phoneNumber": _phoneController.text.trim(),
      "riderDomain": widget.riderDomain,
      "vehicleType": _selectedVehicle!,
    };
    print('payload');
    print(payload);

    try {
      final response = await http.post(
        Uri.parse(Common.baseUrl + "api/rider/basic"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final rider = data['data'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('name', rider['name'] ?? '');
        await prefs.setString('email', rider['email'] ?? '');
        await prefs.setString('cityName', rider['cityName'] ?? '');
        await prefs.setString('phoneNumber', rider['phoneNumber'] ?? '');
        await prefs.setString('riderDomain', rider['riderDomain'] ?? '');
        await prefs.setString('vehicleType', rider['vehicleType'] ?? '');
        await prefs.setString('uniqueRiderOtp', rider['uniqueRiderOtp'] ?? '');
        await prefs.setString('userStatus', rider['userStatus'] ?? '');
        await prefs.setBool('active', rider['active'] ?? false);
        await prefs.setString('riderId', rider['_id'] ?? '');

        // Optional: Save timestamp
        if (rider['currentLocation'] != null && rider['currentLocation']['timestamp'] != null) {
          await prefs.setString('locationTimestamp', rider['currentLocation']['timestamp']);
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DocumentUploadPage()),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Something went wrong')),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Common.background,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Center(
            child: Card(
              elevation: 4,
              color: Common.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Enter your details",
                      style: TextStyle(
                        fontFamily: 'bold',
                        fontSize: 20,
                        fontWeight: Common.weight,
                        color: Common.secondary,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTextField(_nameController, "Name"),
                    SizedBox(height: 15),
                    _buildTextField(
                      _phoneController,
                      "Phone number",
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown("Select city", cities, _selectedCity, (value) {
                          setState(() => _selectedCity = value);
                        })),
                        SizedBox(width: 10),
                        Expanded(child: _buildDropdown("Select vehicle", vehicles, _selectedVehicle, (value) {
                          setState(() => _selectedVehicle = value);
                        })),
                      ],
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: _onNextStep,
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Common.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "Continue to next step",
                            style: TextStyle(
                              fontFamily: 'bold',
                              fontSize: Common.h2,
                              fontWeight: Common.weight2,
                              color: Common.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: Color(0xFFF4F2F2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "Your information is safe and will be used only to provide service.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'bold',
                          fontSize: Common.h4,
                          fontWeight: Common.weight,
                          color: Common.light,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hint, {
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Common.secondary, width: 1.5),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          isDense: true,
        ),
        style: TextStyle(
          fontFamily: 'bold',
          fontSize: Common.h2,
          fontWeight: Common.weight2,
        ),
      ),
    );
  }


  Widget _buildDropdown(String hint, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Common.secondary, width: 1.5),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Common.secondary),
          borderRadius: BorderRadius.circular(10),
          dropdownColor: Colors.white,
          hint: Text(
            hint,
            style: TextStyle(
              fontFamily: 'bold',
              fontSize: Common.h3,
              fontWeight: Common.weight2,
              color: Common.light,
            ),
          ),
          style: TextStyle(
            fontFamily: 'bold',
            fontSize: Common.h3,
            color: Common.secondary,
          ),
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontFamily: 'bold',
                  fontSize: Common.h3,
                  color: Common.secondary,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

}

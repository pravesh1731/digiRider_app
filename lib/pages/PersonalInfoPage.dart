import 'dart:convert';

import 'package:digirider/pages/DocumentUploadPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:digirider/global/Common.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../global/l10n.dart';
import '../services/notification_service.dart';
import '../ui/pickers.dart';
import '../ui/widgets.dart';
import 'auth_widgets.dart';
import '../utils/bottomSnackBar.dart';

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
  bool _isLoading = false;

  // The website's segmented pickers start on Gotan / Bike.
  @override
  void initState() {
    super.initState();
    _selectedCity = kCities.first;
    _selectedVehicle = kVehicles.first;
  }

  void _onNextStep() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty ||
        phone.isEmpty ||
        phone.length != 10 ||
        _selectedCity == null ||
        _selectedVehicle == null ||
        widget.riderDomain.isEmpty) {
      getSnackBar(context, context.l10n.fillAllDetails, Colors.orange, 2);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Please fill in all the details properly.')),
      // );
      return;
    }

    _submitDetails();
  }

  Future<void> _submitDetails() async {
    if (_selectedCity == null || _selectedVehicle == null) {
      getSnackBar(context, context.l10n.selectCityAndVehicle, Colors.orange, 2);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final deviceToken = await prefs.getString('deviceToken');

    final payload = {
      "name": _nameController.text.trim(),
      "email": widget.email,
      "cityName": _selectedCity!,
      "phoneNumber": _phoneController.text.trim(),
      "riderDomain": widget.riderDomain,
      "vehicleType": _selectedVehicle!,
      "deviceToken": deviceToken,
    };

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

        if (rider['currentLocation'] != null && rider['currentLocation']['timestamp'] != null) {
          await prefs.setString('locationTimestamp', rider['currentLocation']['timestamp']);
        }
        // The rider record exists now, so this phone's FCM token can be stored on it.
        await NotificationService().syncToken();
        if (!mounted) return;
        getSnackBar(context, context.l10n.accountCreated, Colors.green, 0);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DocumentUploadPage()),
        );
      } else {
        final data = jsonDecode(response.body);
        getSnackBar(context, data['message'] ?? context.l10n.somethingWentWrong, Colors.orange, 2);
      }

    } catch (e) {
      if (mounted) getSnackBar(context, context.l10n.submitFailed, Colors.redAccent, 2);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.cap;
    return CapAuthScaffold(
      step: 3,
      stepLabel: l10n.cBasicInfo,
      title: l10n.cTellUsAboutYou,
      children: [
        FieldLabel(
          text: l10n.cFullName,
          child: TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            style: CapText.sans(size: 15, color: p.tx),
            decoration: InputDecoration(hintText: l10n.cNamePlaceholder),
          ),
        ),
        const SizedBox(height: 16),
        FieldLabel(
          text: l10n.cMobileNumber,
          child: Row(
            children: [
              const SizedBox(width: 76, child: StaticField('+91', bold: true, center: true)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                  onChanged: (_) => setState(() {}),
                  style: CapText.sans(size: 15, color: p.tx),
                  decoration: InputDecoration(
                    hintText: '98765 43210',
                    suffixIcon: _phoneController.text.trim().length == 10
                        ? Padding(padding: const EdgeInsets.all(14), child: CapIcon(CapIcons.chk, size: 18, color: p.lv))
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FieldLabel(
          text: l10n.cGoogleEmail,
          child: Opacity(opacity: 0.8, child: StaticField(widget.email)),
        ),
        const SizedBox(height: 16),
        FieldLabel(
          text: l10n.cServiceCityK,
          child: CapSeg<String>(
            value: _selectedCity ?? kCities.first,
            onChanged: (v) => setState(() => _selectedCity = v),
            items: [for (final c in kCities) SegItem(c, l10n.cityName(c))],
          ),
        ),
        const SizedBox(height: 16),
        FieldLabel(
          text: l10n.cVehicleTypeK,
          child: CapSeg<String>(
            value: _selectedVehicle ?? kVehicles.first,
            onChanged: (v) => setState(() => _selectedVehicle = v),
            items: [for (final v in kVehicles) SegItem(v, l10n.vehicleName(v))],
          ),
        ),
        const SizedBox(height: 24),
        CapButton(label: _isLoading ? l10n.cSaving : l10n.cContinue, trailingIcon: CapIcons.arr, loading: _isLoading, onPressed: _onNextStep),
        const SizedBox(height: 18),
        Text(l10n.infoSafe, textAlign: TextAlign.center, style: CapText.sans(size: 12, color: p.mu, height: 1.5)),
      ],
    );
  }
}

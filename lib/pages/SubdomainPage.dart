import 'dart:convert';
import 'package:digirider/pages/PersonalInfoPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:digirider/global/Common.dart';

import '../global/l10n.dart';
import '../utils/bottomSnackBar.dart';

class SubdomainPage extends StatefulWidget {
  final String email;

  const SubdomainPage({super.key, required this.email,});

  @override
  State<SubdomainPage> createState() => _SubdomainPageState();
}

class _SubdomainPageState extends State<SubdomainPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isAvailable = true;
  bool _isLoading = false;

  Future<void> _checkSubdomain(String subdomain) async {
    if (subdomain.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(Common.baseUrl+"api/rider/verifydomain"),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final List takenDomains = result['domains'] ?? [];

        setState(() {
          _isAvailable = !takenDomains.contains(subdomain.toLowerCase());
        });
      } else {
        setState(() {
          _isAvailable = false;
        });
      }
    } catch (e) {
      setState(() {
        _isAvailable = false;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }


  void _onNextStep() async {
    // Subdomains are stored lowercase without spaces, e.g. "ramesh" for ramesh.digistall.in
    final subdomain = _controller.text.trim().toLowerCase().replaceAll(' ', '');

    if (subdomain.isEmpty) {
      getSnackBar(context, context.l10n.enterSubdomainError, Colors.orange, 2);
      return;
    }

    setState(() => _isLoading = true);

    await _checkSubdomain(subdomain); // 🔁 Ensure it re-checks just before

    if (_isAvailable) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PersonalInfoPage(
            riderDomain: subdomain,
            email: widget.email,
          ),
        ),
      );
    } else {
      getSnackBar(context, context.l10n.domainTaken, Colors.redAccent, 1);
    }

    setState(() => _isLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Common.secondary,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Common.background,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black,
                    Common.background
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Center(
                  child: Card(
                    elevation: 4,
                    color: Common.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(context.l10n.createDigitalIdentity,
                              style: TextStyle(
                                fontFamily: 'bold',
                                fontSize: 20,
                                fontWeight: Common.weight,
                                color: Common.secondary,
                              )),
                          SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSubdomainInput(),
                              if (!_isAvailable && _controller.text.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                                  child: Text(
                                    context.l10n.domainTaken,
                                    style: TextStyle(
                                      color: Colors.redAccent.shade200,
                                      fontSize: Common.h4,
                                      fontFamily: 'bold',
                                      fontWeight: Common.weight,
                                    ),
                                  ),
                                ),
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
                                  context.l10n.continueNextStep,
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
                              // color: Common.background,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              context.l10n.domainInfo,
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
            Positioned(
              top: 16,
              left: 16,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Common.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back, color: Common.primary, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSubdomainInput() {
    final BorderSide borderSide = BorderSide(
      color: _controller.text.isEmpty
          ? Common.secondary
          : (_isAvailable ? Common.secondary : Colors.redAccent.shade200),
      width: 1.5,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: borderSide.color, width: 1.5),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: _checkSubdomain,
              decoration: InputDecoration(
                hintText: context.l10n.enterSubdomain,
                border: InputBorder.none,
                isDense: true,
              ),
              style: TextStyle(
                fontFamily: 'bold',
                fontSize: Common.h2,
                fontWeight: Common.weight2,
              ),
            ),
          ),
          Text(
            ".digistall.in",
            style: TextStyle(
              fontFamily: 'bold',
              fontSize: Common.h3,
              color: _isAvailable ? Common.secondary : Colors.redAccent.shade200,
            ),
          ),
        ],
      ),
    );
  }



}



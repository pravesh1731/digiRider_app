import 'dart:convert';
import 'package:digirider/pages/PersonalInfoPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:digirider/global/Common.dart';

import '../global/l10n.dart';
import '../ui/widgets.dart';
import 'auth_widgets.dart';
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
    final l10n = context.l10n;
    final p = context.cap;
    final taken = !_isAvailable && _controller.text.isNotEmpty;
    return CapAuthScaffold(
      step: 2,
      stepLabel: l10n.cDigitalId,
      title: l10n.createDigitalIdentity,
      children: [
        Text(l10n.domainInfo, style: CapText.sans(size: 15, color: p.mu, height: 1.5)),
        const SizedBox(height: 22),
        FieldLabel(
          text: l10n.cCaptainDomain,
          child: TextField(
            controller: _controller,
            onChanged: _checkSubdomain,
            autocorrect: false,
            style: CapText.sans(size: 15, color: p.tx),
            decoration: InputDecoration(
              hintText: l10n.enterSubdomain,
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  widthFactor: 1,
                  child: Text('.digistall.in', style: CapText.mono(size: 13, weight: FontWeight.w400, color: taken ? p.rd : p.mu)),
                ),
              ),
              enabledBorder: taken
                  ? OutlineInputBorder(borderRadius: BorderRadius.circular(CapRadius.input), borderSide: BorderSide(color: p.rd))
                  : null,
            ),
          ),
        ),
        if (taken)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(l10n.domainTaken, style: CapText.sans(size: 13, weight: FontWeight.w500, color: p.rd)),
          ),
        const SizedBox(height: 24),
        CapButton(label: l10n.cContinue, trailingIcon: CapIcons.arr, loading: _isLoading, onPressed: _onNextStep),
      ],
    );
  }
}

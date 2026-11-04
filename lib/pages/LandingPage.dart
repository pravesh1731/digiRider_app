import 'package:digirider/pages/GoogleSignInUp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../global/l10n.dart';
import '../global/my_app_state.dart';
import '../ui/cap_visuals.dart';
import '../ui/pickers.dart';
import '../ui/widgets.dart';
import '../utils/show_exit_dialog.dart';

/// The website's landing screen: live map hero, a "new request" teaser, the headline and the CTA.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  void _open(BuildContext context, {bool signUp = false}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => GoogleLoginPage(isSignUp: signUp)));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final l10n = context.l10n;
    final app = context.findAncestorStateOfType<MyAppState>();
    final lang = (app?.locale ?? Localizations.localeOf(context)).languageCode;
    final top = MediaQuery.of(context).padding.top;

    Widget stat(String value, String label) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: CapText.serif(size: 32, color: p.tx, height: 1)),
            const SizedBox(height: 4),
            KLabel(label, padding: EdgeInsets.zero),
          ],
        );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && await showExitConfirmationDialogWhite(context)) SystemNavigator.pop();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: capOverlay(p),
        child: Scaffold(
          backgroundColor: p.bg,
          body: Stack(
            children: [
              const Positioned(left: 0, right: 0, top: 0, child: MapHero(height: 420, fadeHeight: 220)),
              ListView(
                padding: EdgeInsets.fromLTRB(20, top + 20, 20, 40),
                children: [
                  Row(
                    children: [
                      const CapLogo(),
                      const Spacer(),
                      CapSeg<String>(
                        small: true,
                        value: lang,
                        onChanged: (v) => app?.setLocale(Locale(v)),
                        items: const [SegItem('en', 'En'), SegItem('hi', 'हि')],
                      ),
                      const SizedBox(width: 8),
                      CapChip(label: l10n.cLogIn, weight: FontWeight.w600, onTap: () => _open(context)),
                    ],
                  ),
                  const SizedBox(height: 110),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Glass(
                      radius: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const LiveDot(),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              KLabel(l10n.cNewRequest, padding: EdgeInsets.zero),
                              const SizedBox(height: 2),
                              Text(l10n.cStoreDelivery, style: CapText.sans(size: 14, weight: FontWeight.w600, color: p.tx)),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Text('₹400', style: CapText.serif(size: 24, color: p.amx, height: 1)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: l10n.cHeroPre),
                        TextSpan(text: l10n.cHeroEm, style: CapText.serif(size: 50, color: p.amx, height: 0.98, italic: true)),
                        TextSpan(text: l10n.cHeroPost),
                      ],
                    ),
                    style: CapText.serif(size: 50, color: p.tx, height: 0.98),
                  ),
                  const SizedBox(height: 14),
                  Text(l10n.cHeroSub, style: CapText.sans(size: 15.5, color: p.mu, height: 1.45)),
                  const SizedBox(height: 22),
                  CapButton(label: l10n.cStartEarning, trailingIcon: CapIcons.arr, onPressed: () => _open(context, signUp: true)),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      stat('₹1,000', l10n.cDailyPotential),
                      stat('${kVehicles.length}', l10n.cVehicleTypes),
                      stat('${kCities.length}', l10n.cServiceCities),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

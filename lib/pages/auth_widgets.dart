import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../global/l10n.dart';
import '../global/my_app_state.dart';
import '../ui/widgets.dart';

/// Layout of the website's sign-in and sign-up screens: back chip, language pill,
/// optional "Step n of N" with progress bars, a `.k` label and a serif title, then the content.
class CapAuthScaffold extends StatelessWidget {
  final int? step;
  final int totalSteps;
  final String? stepLabel;
  final String title;
  final double titleSize;
  final List<Widget> children;
  final VoidCallback? onBack;
  final String? backLabel;

  const CapAuthScaffold({
    super.key,
    this.step,
    this.totalSteps = 4,
    this.stepLabel,
    required this.title,
    this.titleSize = 40,
    required this.children,
    this.onBack,
    this.backLabel,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final l10n = context.l10n;
    final app = context.findAncestorStateOfType<MyAppState>();
    final isHindi = (app?.locale ?? Localizations.localeOf(context)).languageCode == 'hi';
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: capOverlay(p),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: p.bg,
          body: CapPage(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            children: [
              Row(
                children: [
                  CapChip.back(context, label: backLabel, onTap: onBack),
                  const SizedBox(width: 8),
                  LanguagePill(isHindi: isHindi, onTap: () => app?.setLocale(Locale(isHindi ? 'en' : 'hi'))),
                  const Spacer(),
                  if (step != null)
                    Text(l10n.cStepOf('$step', '$totalSteps'), style: CapText.mono(size: 12, weight: FontWeight.w400, color: p.mu))
                  else
                    const CapLogo(showText: false),
                ],
              ),
              if (step != null) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    for (var i = 1; i <= totalSteps; i++) ...[
                      if (i > 1) const SizedBox(width: 6),
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 4,
                          decoration: BoxDecoration(color: i <= step! ? p.am : p.s2, borderRadius: BorderRadius.circular(9)),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                KLabel(l10n.cStepSub('$step', '$totalSteps', stepLabel ?? '')),
              ] else
                const SizedBox(height: 36),
              Text(title, style: CapText.serif(size: titleSize, color: p.tx, height: 0.98)),
              const SizedBox(height: 20),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// White "Sign in with Google" button with the Google mark.
class GoogleButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;
  const GoogleButton({super.key, required this.label, required this.loading, required this.onTap});

  static const String _mark = '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">'
      '<path fill="#4285F4" d="M23.745 12.27c0-.7-.06-1.4-.19-2.07H12v4.51h6.6c-.29 1.52-1.14 2.82-2.4 3.68v3.05h3.88c2.27-2.09 3.66-5.17 3.66-9.17z"/>'
      '<path fill="#34A853" d="M12 24c3.24 0 5.95-1.08 7.93-2.91l-3.88-3.05c-1.08.72-2.45 1.16-4.05 1.16-3.12 0-5.77-2.1-6.72-4.93H1.25v3.15C3.26 21.36 7.33 24 12 24z"/>'
      '<path fill="#FBBC05" d="M5.28 14.27c-.25-.72-.38-1.49-.38-2.27s.13-1.55.38-2.27V6.58H1.25C.45 8.17 0 9.99 0 12s.45 3.83 1.25 5.42l4.03-3.15z"/>'
      '<path fill="#EA4335" d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42C17.95 1.19 15.24 0 12 0 7.33 0 3.26 2.64 1.25 6.58l4.03 3.15c.95-2.83 3.6-4.98 6.72-4.98z"/>'
      '</svg>';

  @override
  Widget build(BuildContext context) {
    return CapButton(
      label: label,
      style: CapButtonStyle.white,
      height: 58,
      loading: loading,
      leading: SvgPicture.string(_mark, width: 22, height: 22),
      onPressed: onTap,
    );
  }
}

/// Muted question with an amber underlined link ("Don't have an account? Sign up to drive").
class AuthSwitchLink extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback onTap;
  const AuthSwitchLink({super.key, required this.question, required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return GestureDetector(
      onTap: onTap,
      child: Text.rich(
        TextSpan(
          text: '$question ',
          style: CapText.sans(size: 14, color: p.mu),
          children: [
            TextSpan(
              text: action,
              style: CapText.sans(size: 14, weight: FontWeight.w600, color: p.am).copyWith(decoration: TextDecoration.underline, decorationColor: p.am),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// `.k` label above an input.
class FieldLabel extends StatelessWidget {
  final String text;
  final Widget child;
  const FieldLabel({super.key, required this.text, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [KLabel(text), child]);
  }
}

/// Read-only value styled like an input (the "+91" prefix, the connected Google email).
class StaticField extends StatelessWidget {
  final String text;
  final bool bold;
  final bool center;
  const StaticField(this.text, {super.key, this.bold = false, this.center = false});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: center ? Alignment.center : Alignment.centerLeft,
      decoration: BoxDecoration(color: p.s1, borderRadius: BorderRadius.circular(CapRadius.input), border: Border.all(color: p.ln)),
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: CapText.sans(size: 15, weight: bold ? FontWeight.w600 : FontWeight.w400, color: p.tx)),
    );
  }
}

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../global/l10n.dart';
import 'widgets.dart';

/// The website's loading screen (`#captain-splash-loader`): a route draws itself across a dark
/// street grid, a "New request" pill pops up, then the "Finding your next ride." copy and a loading bar.
/// Always dark, like the site.
class CaptainSplash extends StatefulWidget {
  const CaptainSplash({super.key});

  @override
  State<CaptainSplash> createState() => _CaptainSplashState();
}

class _CaptainSplashState extends State<CaptainSplash> with TickerProviderStateMixin {
  static const bg = Color(0xFF050F0F);
  static const line = Color(0xFF17353A);
  static const amber = Color(0xFFFFB347);
  static const amberD = Color(0xFFF59E1B);
  static const ink = Color(0xFFF4F7F6);
  static const sub = Color(0xFF7F948F);

  // 126 s is a whole multiple of every loop (4.2 s route, 2.1 s ripples, 3 s messages, 2 s blink);
  // each loop reads its own phase from the elapsed seconds.
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 126))..repeat();
  late final AnimationController _bar = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  static const String _logo = '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M4 15h9l3-6h4" stroke="#ffb347" stroke-width="2.4" fill="none" stroke-linecap="round" stroke-linejoin="round"/>'
      '<circle cx="7" cy="18" r="2.6" fill="#ffb347"/><circle cx="18" cy="18" r="2.6" fill="#ffb347"/></svg>';

  @override
  void dispose() {
    _c.dispose();
    _bar.dispose();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final messages = [l10n.cSplash1, l10n.cSplash2, l10n.cSplash3];
    final media = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: bg,
      body: Padding(
        padding: EdgeInsets.fromLTRB(24, media.padding.top + 28, 24, media.padding.bottom + 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeTransition(
              opacity: _intro,
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12), border: Border.all(color: line)),
                    child: SvgPicture.string(_logo, width: 26, height: 26),
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.cBrand, style: CapText.sans(size: 18.4, weight: FontWeight.w600, color: ink, spacing: -0.18)),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ShaderMask(
                  shaderCallback: (r) => const RadialGradient(colors: [Colors.black, Colors.black, Colors.transparent], stops: [0, 0.62, 1]).createShader(r),
                  blendMode: BlendMode.dstIn,
                  child: AspectRatio(
                    aspectRatio: 360 / 300,
                    child: AnimatedBuilder(
                      animation: _c,
                      builder: (context, _) => CustomPaint(painter: _SplashMapPainter(_c.value * 126, l10n.cNewRequest)),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final secs = _c.value * 126;
                final idx = (secs ~/ 3) % 3;
                final phase = (secs % 3) / 3;
                final opacity = phase < 0.06 ? phase / 0.06 : (phase > 0.9 ? (1 - phase) / 0.1 : 1.0);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: l10n.cSplashPre),
                          TextSpan(text: l10n.cSplashEm, style: CapText.serif(size: 43, color: amber, height: 1.02, italic: true)),
                          TextSpan(text: l10n.cSplashPost),
                        ],
                      ),
                      style: CapText.serif(size: 43, color: ink, height: 1.02),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 20,
                      child: Opacity(
                        opacity: opacity.clamp(0.0, 1.0),
                        child: Text(messages[idx], style: CapText.mono(size: 12.8, weight: FontWeight.w400, color: sub, spacing: 0.5)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: Container(
                height: 4,
                color: const Color(0xFF15282A),
                child: LayoutBuilder(
                  builder: (context, c) => AnimatedBuilder(
                    animation: _bar,
                    builder: (context, _) {
                      final w = c.maxWidth * 0.34;
                      final t = Curves.easeInOut.transform(_bar.value);
                      return Stack(
                        children: [
                          Positioned(
                            left: -w + (c.maxWidth + w) * t,
                            top: 0,
                            bottom: 0,
                            width: w,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(99),
                                gradient: const LinearGradient(colors: [amberD, amber]),
                                boxShadow: const [BoxShadow(color: Color(0x99FFB347), blurRadius: 12)],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashMapPainter extends CustomPainter {
  final double secs;
  final String pillText;
  _SplashMapPainter(this.secs, this.pillText);

  static const mint = Color(0xFF3DDBB8);
  static const amber = Color(0xFFFFB347);

  static final Path _route = Path()
    ..moveTo(60, 262)
    ..cubicTo(60, 205, 130, 215, 165, 168)
    ..cubicTo(200, 121, 262, 128, 292, 56);

  double _lerp(double t, List<(double, double)> stops) {
    for (var i = 0; i < stops.length - 1; i++) {
      final (t0, v0) = stops[i];
      final (t1, v1) = stops[i + 1];
      if (t >= t0 && t <= t1) return v0 + (v1 - v0) * ((t - t0) / (t1 - t0));
    }
    return stops.last.$2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 360, size.height / 300);

    final water = Path()
      ..moveTo(0, 40)
      ..cubicTo(60, 20, 120, 60, 170, 40)
      ..cubicTo(220, 20, 300, 0, 360, 40)
      ..lineTo(360, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(water, Paint()..color = const Color(0xB30D3340));

    canvas.save();
    canvas.translate(180, 150);
    canvas.rotate(-4 * math.pi / 180);
    canvas.translate(-180, -150);
    final grid = Paint()
      ..color = const Color(0xE617353A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final x in const <double>[20, 80, 140, 200, 260, 320]) {
      canvas.drawLine(Offset(x, -20), Offset(x, 330), grid);
    }
    for (final y in const <double>[40, 95, 150, 205, 260]) {
      canvas.drawLine(Offset(-20, y), Offset(380, y), grid);
    }
    canvas.drawCircle(const Offset(150, 150), 22, grid);
    canvas.restore();

    final t = (secs % 4.2) / 4.2;
    final metric = _route.computeMetrics().first;
    final drawn = metric.length * (t < 0.68 ? t / 0.68 : 1);
    final routeOpacity = t <= 0.9 ? 1.0 : 1 - (t - 0.9) / 0.1;
    final part = metric.extractPath(0, drawn);
    canvas.drawPath(
      part,
      Paint()
        ..color = amber.withValues(alpha: 0.16 * routeOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      part,
      Paint()
        ..shader = ui.Gradient.linear(const Offset(60, 262), const Offset(292, 56), [
          mint.withValues(alpha: routeOpacity),
          amber.withValues(alpha: routeOpacity),
          amber.withValues(alpha: routeOpacity),
        ], [0, 0.45, 1])
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    // Start point with three ripples.
    for (final delay in [0.0, 0.7, 1.4]) {
      final r = ((secs + 2.1 - delay) % 2.1) / 2.1;
      canvas.drawCircle(
        const Offset(60, 262),
        26 * (0.25 + 1.35 * r),
        Paint()
          ..color = mint.withValues(alpha: 0.7 * (1 - r))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    canvas.drawCircle(const Offset(60, 262), 9, Paint()..color = const Color(0xFF050F0F));
    canvas.drawCircle(
      const Offset(60, 262),
      9,
      Paint()
        ..color = mint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Drop pin pops when the rider arrives.
    final dropScale = _lerp(t, [(0, 0.55), (0.6, 0.55), (0.7, 1.35), (0.78, 1), (0.92, 1), (1, 0.55)]);
    final dropOpacity = _lerp(t, [(0, 0.4), (0.6, 0.4), (0.7, 1), (0.92, 1), (1, 0.4)]);
    canvas.drawCircle(const Offset(292, 56), 14 * dropScale, Paint()..color = Colors.white.withValues(alpha: dropOpacity));
    canvas.drawCircle(const Offset(292, 56), 9 * dropScale, Paint()..color = amber.withValues(alpha: dropOpacity));

    // Rider dot travels the route.
    final riderOpacity = _lerp(t, [(0, 0), (0.04, 1), (0.68, 1), (0.74, 0), (1, 0)]);
    if (riderOpacity > 0) {
      final pos = metric.getTangentForOffset(metric.length * math.min(t / 0.68, 1))!.position;
      canvas.drawCircle(pos, 13, Paint()..color = amber.withValues(alpha: 0.25 * riderOpacity));
      canvas.drawCircle(pos, 6.5, Paint()..color = Colors.white.withValues(alpha: riderOpacity));
      canvas.drawCircle(
        pos,
        6.5,
        Paint()
          ..color = amber.withValues(alpha: riderOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    // "New request" pill.
    final pillOpacity = _lerp(t, [(0, 0), (0.7, 0), (0.78, 1), (0.93, 1), (1, 0)]);
    final pillScale = _lerp(t, [(0, 0.7), (0.7, 0.7), (0.78, 1.05), (0.83, 1), (0.93, 1), (1, 0.95)]);
    if (pillOpacity > 0) {
      canvas.save();
      canvas.translate(22, 121);
      canvas.scale(pillScale);
      canvas.translate(-22, -121);
      final rect = RRect.fromRectAndRadius(const Rect.fromLTWH(22, 104, 136, 34), const Radius.circular(17));
      canvas.drawRRect(rect, Paint()..color = const Color(0xFF0C1A1A).withValues(alpha: pillOpacity));
      canvas.drawRRect(
        rect,
        Paint()
          ..color = const Color(0xFF17353A).withValues(alpha: pillOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      final blink = 0.35 + 0.65 * (0.5 + 0.5 * math.cos(secs * math.pi));
      canvas.drawCircle(const Offset(42, 121), 5, Paint()..color = mint.withValues(alpha: pillOpacity * blink));
      final tp = TextPainter(
        text: TextSpan(text: pillText, style: CapText.sans(size: 13, weight: FontWeight.w500, color: const Color(0xFFF4F7F6).withValues(alpha: pillOpacity))),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: 96);
      tp.paint(canvas, Offset(56, 121 - tp.height / 2));
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SplashMapPainter old) => old.secs != secs || old.pillText != pillText;
}

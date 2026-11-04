import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../global/l10n.dart';
import 'widgets.dart';

// ---------------------------------------------------------------------------
// City map (`Lm`): stylised streets, water, park, high-demand zone and a live route.
// ---------------------------------------------------------------------------

class CityMap extends StatefulWidget {
  /// Shifts the street grid per city, like the website's `cityOffset`.
  final int cityOffset;
  final bool showHighDemand;
  const CityMap({super.key, this.cityOffset = 0, this.showHighDemand = true});

  @override
  State<CityMap> createState() => _CityMapState();
}

class _CityMapState extends State<CityMap> with SingleTickerProviderStateMixin {
  // 48 s is a whole multiple of every loop on the map (1.2 s, 2.4 s, 16 s).
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 48))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _CityMapPainter(
            palette: p,
            offset: widget.cityOffset,
            highDemand: widget.showHighDemand,
            seconds: _c.value * 48,
          ),
        ),
      ),
    );
  }
}

class _CityMapPainter extends CustomPainter {
  final CapPalette palette;
  final int offset;
  final bool highDemand;
  final double seconds;

  _CityMapPainter({required this.palette, required this.offset, required this.highDemand, required this.seconds});

  static final Path _route = Path()
    ..moveTo(70, 470)
    ..cubicTo(70, 380, 210, 400, 195, 310)
    ..cubicTo(180, 220, 330, 250, 312, 150);

  double _rand(num n) {
    final v = 43758.5 * math.sin(127.1 * (n + 17 * offset));
    return v - v.floorToDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final p = palette;
    // preserveAspectRatio="xMidYMid slice" over a 390x580 view box.
    final s = math.max(size.width / 390, size.height / 580);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate((size.width - 390 * s) / 2, (size.height - 580 * s) / 2);
    canvas.scale(s);

    canvas.drawRect(const Rect.fromLTWH(-10, -10, 410, 600), Paint()..color = p.map);

    final water = Path()
      ..moveTo(-10, 110)
      ..cubicTo(80, 80, 120, 190, 220, 160)
      ..cubicTo(320, 130, 380, 50, 400, 90)
      ..lineTo(400, -10)
      ..lineTo(-10, -10)
      ..close();
    canvas.drawPath(water, Paint()..color = p.mw);
    canvas.drawOval(Rect.fromCenter(center: const Offset(310, 380), width: 144, height: 96), Paint()..color = p.mp);

    final road = Paint()
      ..color = p.mr
      ..style = PaintingStyle.stroke;
    for (var t = -1; t < 10; t++) {
      road.strokeWidth = t.remainder(3) != 0 ? 1.2 : 2.6;
      canvas.drawLine(Offset(46.0 * t + 14 * _rand(t), -10), Offset(46.0 * t + 24 + 30 * _rand(t + 9), 580), road);
    }
    for (var t = 0; t < 13; t++) {
      road.strokeWidth = t % 4 != 0 ? 1.2 : 2.6;
      canvas.drawLine(Offset(-10, 46.0 * t + 16 * _rand(t + 3)), Offset(400, 46.0 * t - 20 + 40 * _rand(t + 5)), road);
    }

    if (highDemand) {
      final c = Offset(110.0 + 70 * offset, 340.0 - 40 * offset);
      canvas.drawCircle(c, 72, Paint()..color = p.am.withValues(alpha: 0.14));
      canvas.drawCircle(c, 40, Paint()..color = p.am.withValues(alpha: 0.12));
      final tp = TextPainter(
        text: TextSpan(text: 'HIGH DEMAND', style: CapText.mono(size: 10, weight: FontWeight.w600, color: p.am, spacing: 1)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(72.0 + 70 * offset, 344.0 - 40 * offset - tp.height * 0.8));
    }

    final arterial = Path()
      ..moveTo(-10, 300)
      ..cubicTo(90, 280, 150, 380, 260, 340)
      ..cubicTo(370, 300, 380, 300, 400, 330);
    canvas.drawPath(
      arterial,
      Paint()
        ..color = p.ma
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );

    canvas.drawPath(
      _route,
      Paint()
        ..color = p.rt.withValues(alpha: 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      _route,
      Paint()
        ..shader = ui.Gradient.linear(const Offset(70, 470), const Offset(312, 150), [p.lv, p.am])
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    final metric = _route.computeMetrics().first;
    // .flow: dots every 15 units, flowing along the route every 1.2 s.
    final flow = Paint()..color = Colors.white.withValues(alpha: 0.9);
    final shift = (seconds % 1.2) / 1.2 * 15;
    for (var d = shift; d < metric.length; d += 15) {
      final pos = metric.getTangentForOffset(d)?.position;
      if (pos != null) canvas.drawCircle(pos, 1.1, flow);
    }

    void pin(Offset c, Color color) {
      canvas.drawCircle(c, 9, Paint()..color = color);
      canvas.drawCircle(
        c,
        9,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    pin(const Offset(70, 470), p.lv);
    pin(const Offset(312, 150), p.am);

    final rider = metric.getTangentForOffset(metric.length * ((seconds % 16) / 16))?.position;
    if (rider != null) {
      final pulse = math.sin(math.pi * ((seconds % 2.4) / 2.4));
      canvas.drawCircle(rider, 9 + 15 * pulse, Paint()..color = p.lv.withValues(alpha: 0.3));
      canvas.drawCircle(rider, 7, Paint()..color = p.lv);
      canvas.drawCircle(
        rider,
        7,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CityMapPainter old) =>
      old.seconds != seconds || old.palette != palette || old.offset != offset || old.highDemand != highDemand;
}

/// Map behind a page with the bottom fading into the page background (`.hero` + `.fade`).
class MapHero extends StatelessWidget {
  final double height;
  final double fadeHeight;
  final int cityOffset;
  const MapHero({super.key, this.height = 420, this.fadeHeight = 220, this.cityOffset = 0});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CityMap(cityOffset: cityOffset),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: fadeHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [p.bg.withValues(alpha: 0), p.bg],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Earnings ring and chart
// ---------------------------------------------------------------------------

/// `.ring`: 64px goal ring with the percentage in the middle.
class EarnRing extends StatelessWidget {
  final int percent;
  const EarnRing({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent.clamp(0, 100) / 100),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => CustomPaint(size: const Size(64, 64), painter: _RingPainter(v, p.s2, p.am)),
          ),
          Text('$percent%', style: CapText.sans(size: 13, weight: FontWeight.w700, color: p.tx)),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color track;
  final Color color;
  _RingPainter(this.value, this.track, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: 27);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
    if (value > 0) canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, paint..color = color);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.value != value || old.color != color || old.track != track;
}

/// Smooth amber area chart of earnings with a tappable highlighted point.
class EarningsChart extends StatefulWidget {
  final List<double> values;
  final List<String> labels;
  const EarningsChart({super.key, required this.values, required this.labels});

  @override
  State<EarningsChart> createState() => _EarningsChartState();
}

class _EarningsChartState extends State<EarningsChart> {
  late int _selected = widget.values.length - 1;

  @override
  void didUpdateWidget(covariant EarningsChart old) {
    super.didUpdateWidget(old);
    if (old.values.length != widget.values.length) _selected = widget.values.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return Glass(
      radius: 28,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 350 / 140,
            child: LayoutBuilder(
              builder: (context, c) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) {
                  final n = widget.values.length;
                  final x = d.localPosition.dx / c.maxWidth * 350;
                  setState(() => _selected = (((x - 10) / 330) * (n - 1)).round().clamp(0, n - 1));
                },
                child: CustomPaint(
                  size: Size(c.maxWidth, c.maxHeight),
                  painter: _ChartPainter(values: widget.values, selected: _selected, palette: p),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [for (final l in widget.labels) Text(l, style: CapText.mono(size: 11, weight: FontWeight.w400, color: p.mu))],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> values;
  final int selected;
  final CapPalette palette;
  _ChartPainter({required this.values, required this.selected, required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final p = palette;
    final n = values.length;
    if (n < 2) return;
    canvas.save();
    canvas.scale(size.width / 350, size.height / 140);
    final top = 1.15 * math.max(values.reduce(math.max), 100);
    final pts = [for (var i = 0; i < n; i++) Offset(10 + 330 * i / (n - 1), 128 - values[i] / top * 110)];

    final line = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (var i = 0; i < n - 1; i++) {
      final a = i > 0 ? pts[i - 1] : pts[i];
      final b = pts[i];
      final c = pts[i + 1];
      final d = i + 2 < n ? pts[i + 2] : c;
      line.cubicTo(b.dx + (c.dx - a.dx) / 6, b.dy + (c.dy - a.dy) / 6, c.dx - (d.dx - b.dx) / 6, c.dy - (d.dy - b.dy) / 6, c.dx, c.dy);
    }
    final area = Path.from(line)
      ..lineTo(pts.last.dx, 140)
      ..lineTo(pts.first.dx, 140)
      ..close();
    canvas.drawPath(
      area,
      Paint()..shader = ui.Gradient.linear(const Offset(0, 0), const Offset(0, 140), [p.am.withValues(alpha: 0.45), p.am.withValues(alpha: 0)]),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = p.am
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    final sel = pts[selected.clamp(0, n - 1)];
    final dash = Paint()
      ..color = p.am.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (var y = sel.dy; y < 140; y += 7) {
      canvas.drawLine(Offset(sel.dx, y), Offset(sel.dx, math.min(y + 3, 140)), dash);
    }
    canvas.drawCircle(sel, 6, Paint()..color = p.bg);
    canvas.drawCircle(
      sel,
      6,
      Paint()
        ..color = p.am
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final tp = TextPainter(
      text: TextSpan(text: rupees(values[selected.clamp(0, n - 1)]), style: CapText.sans(size: 13, weight: FontWeight.w600, color: p.tx)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = sel.dx.clamp(34.0, 316.0);
    final y = math.max(sel.dy - 14, 14.0);
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height * 0.8));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) => old.values != values || old.selected != selected || old.palette != palette;
}

// ---------------------------------------------------------------------------
// Captain pass (`.pass`)
// ---------------------------------------------------------------------------

class CaptainPass extends StatefulWidget {
  final String name;
  final String plate;
  final String vehicle;
  final String city;
  final bool verified;
  final String qrData;

  const CaptainPass({
    super.key,
    required this.name,
    required this.plate,
    required this.vehicle,
    required this.city,
    required this.verified,
    required this.qrData,
  });

  @override
  State<CaptainPass> createState() => _CaptainPassState();
}

class _CaptainPassState extends State<CaptainPass> {
  Offset _tilt = Offset.zero; // degrees (x, y)
  Offset _glow = const Offset(0.7, 0);

  void _move(Offset local, Size size) {
    final i = (local.dx / size.width).clamp(0.0, 1.0);
    final r = (local.dy / size.height).clamp(0.0, 1.0);
    setState(() {
      _tilt = Offset(14 * (0.5 - r), 14 * (i - 0.5));
      _glow = Offset(i, r);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final l10n = context.l10n;
    const ink = Color(0xFFEAF3F1);
    const keyColor = Color(0xFF9FB8B4);
    return LayoutBuilder(
      builder: (context, c) {
        final size = Size(c.maxWidth, 290);
        return Listener(
          onPointerMove: (e) => _move(e.localPosition, size),
          onPointerDown: (e) => _move(e.localPosition, size),
          onPointerUp: (_) => setState(() => _tilt = Offset.zero),
          onPointerCancel: (_) => setState(() => _tilt = Offset.zero),
          child: TweenAnimationBuilder<Offset>(
            tween: Tween(end: _tilt),
            duration: const Duration(milliseconds: 120),
            builder: (context, tilt, child) => Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 1 / 900)
                ..rotateX(tilt.dx * math.pi / 180)
                ..rotateY(tilt.dy * math.pi / 180),
              child: child,
            ),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  begin: Alignment(-0.6, -1),
                  end: Alignment(0.6, 1),
                  colors: [Color(0xFF0E2B2A), Color(0xFF071413), Color(0xFF1B3A2E)],
                  stops: [0, 0.6, 1],
                ),
                boxShadow: p.sh,
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0x1FFFFFFF)),
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: _StripePainter())),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(_glow.dx * 2 - 1, _glow.dy * 2 - 1),
                          radius: 1.1,
                          colors: const [Color(0x4DFFB547), Color(0x00FFB547)],
                          stops: const [0, 0.6],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CapLogo(color: ink),
                            const Spacer(),
                            CapTag(
                              widget.verified ? l10n.cVerified : l10n.cUnderReview,
                              color: widget.verified ? const Color(0xFF3FD4B8) : p.am,
                              background: const Color(0x1AFFFFFF),
                              leading: CapIcon(CapIcons.shield, size: 14, color: widget.verified ? const Color(0xFF3FD4B8) : p.am),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(
                          widget.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: CapText.serif(size: 44, color: ink, height: 1),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFFFB547), borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            widget.plate,
                            style: CapText.mono(size: 13, weight: FontWeight.w600, color: const Color(0xFF1A1200), spacing: 1.56),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  KLabel(l10n.cVehicle, color: keyColor),
                                  Text(widget.vehicle, style: CapText.sans(size: 14, weight: FontWeight.w600, color: ink)),
                                  const SizedBox(height: 12),
                                  KLabel(l10n.cCity, color: keyColor),
                                  Text(widget.city, style: CapText.sans(size: 14, weight: FontWeight.w600, color: ink)),
                                ],
                              ),
                            ),
                            Container(
                              width: 96,
                              height: 96,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                              child: QrImageView(
                                data: widget.qrData,
                                padding: EdgeInsets.zero,
                                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF071210)),
                                dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF071210)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// repeating-linear-gradient(115deg, white 3.5% 1px, transparent 1px 9px)
class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x09FFFFFF)
      ..strokeWidth = 1;
    final angle = 25 * math.pi / 180; // stripes perpendicular to the 115deg gradient axis
    final dx = math.tan(angle) * size.height;
    for (double x = -dx; x < size.width + dx; x += 9 / math.cos(angle)) {
      canvas.drawLine(Offset(x, 0), Offset(x + dx, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

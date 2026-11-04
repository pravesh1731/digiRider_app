import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../global/l10n.dart';
import 'app_theme.dart';
import 'cap_icons.dart';

export 'app_theme.dart';
export 'cap_icons.dart';

/// Building blocks of the Digi Captain website UI. Class names in comments are the site's CSS classes.

// ---------------------------------------------------------------------------
// Surfaces
// ---------------------------------------------------------------------------

/// `.glass` frosted panel: translucent surface, hairline border, big soft shadow, backdrop blur.
class Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final bool shadow;
  final double blur;

  const Glass({
    super.key,
    required this.child,
    this.radius = CapRadius.glass,
    this.padding,
    this.color,
    this.borderColor,
    this.shadow = true,
    this.blur = 22,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final r = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(borderRadius: r, boxShadow: shadow ? p.sh : null),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? p.glass,
              borderRadius: r,
              border: Border.all(color: borderColor ?? p.ln),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// `.list` card: solid surface with rounded corners; children are `.li` rows separated by hairlines.
class CapList extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const CapList({super.key, required this.children, this.margin, this.padding});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return Container(
      margin: margin,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.s1,
        borderRadius: BorderRadius.circular(CapRadius.list),
        border: Border.all(color: p.ln),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: p.ln),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// `.li` row: optional leading box, flexible middle, optional trailing widget.
class CapListItem extends StatelessWidget {
  final Widget? leading;
  final Widget child;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? background;
  final EdgeInsetsGeometry padding;

  const CapListItem({
    super.key,
    this.leading,
    required this.child,
    this.trailing,
    this.onTap,
    this.background,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: padding,
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(child: child),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
    return Material(
      color: background ?? Colors.transparent,
      child: onTap == null ? row : InkWell(onTap: onTap, child: row),
    );
  }
}

/// Centered muted message inside a `.list` (`.li.mu` with justify-content center).
class CapListMessage extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry? margin;
  const CapListMessage(this.text, {super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return CapList(
      margin: margin,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(text, textAlign: TextAlign.center, style: CapText.sans(size: 15, color: p.mu)),
        ),
      ],
    );
  }
}

/// `.ib` 40x40 rounded icon box.
class IconBox extends StatelessWidget {
  final CapIcons? icon;
  final Widget? child;
  final Color? color;
  final Color? background;
  final double size;
  final double iconSize;
  final double radius;
  final VoidCallback? onTap;
  final String? tooltip;

  const IconBox({
    super.key,
    this.icon,
    this.child,
    this.color,
    this.background,
    this.size = 40,
    this.iconSize = 20,
    this.radius = 14,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final box = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background ?? p.s2, borderRadius: BorderRadius.circular(radius)),
      child: child ?? (icon != null ? CapIcon(icon!, size: iconSize, color: color ?? p.tx) : null),
    );
    if (onTap == null) return box;
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(borderRadius: BorderRadius.circular(radius), onTap: onTap, child: box),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Text
// ---------------------------------------------------------------------------

/// `.k` small uppercase mono label.
class KLabel extends StatelessWidget {
  final String text;
  final Color? color;
  final double size;
  final EdgeInsetsGeometry padding;

  const KLabel(this.text, {super.key, this.color, this.size = 11, this.padding = const EdgeInsets.only(bottom: 6)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(text.toUpperCase(), style: CapText.k(color ?? context.cap.mu, size: size)),
    );
  }
}

/// Page heading: `.k` label above a big `.serif.h1` title.
class PageTitle extends StatelessWidget {
  final String label;
  final String title;
  final double size;
  final Widget? trailing;

  const PageTitle({super.key, required this.label, required this.title, this.size = 44, this.trailing});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KLabel(label, padding: EdgeInsets.zero),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Text(title, style: CapText.serif(size: size, color: p.tx, height: 0.98))),
            if (trailing != null) trailing!,
          ],
        ),
      ],
    );
  }
}

/// "₹1,234" with Indian grouping.
String rupees(num amount) {
  final n = amount.round();
  final neg = n < 0;
  var s = n.abs().toString();
  if (s.length > 3) {
    final last3 = s.substring(s.length - 3);
    var rest = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    s = '${parts.join(',')},$last3';
  }
  return '${neg ? '−' : ''}₹$s';
}

// ---------------------------------------------------------------------------
// Controls
// ---------------------------------------------------------------------------

/// Shrinks slightly while pressed, like the site's `:active { transform: scale(.98) }`.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const Pressable({super.key, required this.child, this.onTap, this.scale = 0.97});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}

/// `.chip` pill: frosted background, hairline border. [selected] inverts it (filter chips).
class CapChip extends StatelessWidget {
  final String? label;
  final CapIcons? icon;
  final CapIcons? trailingIcon;
  final VoidCallback? onTap;
  final bool selected;
  final Color? color;
  final Color? background;
  final double height;
  final double radius;
  final EdgeInsetsGeometry padding;
  final FontWeight weight;
  final double iconSize;
  final bool enabled;

  const CapChip({
    super.key,
    this.label,
    this.icon,
    this.trailingIcon,
    this.onTap,
    this.selected = false,
    this.color,
    this.background,
    this.height = 38,
    this.radius = 99,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.weight = FontWeight.w500,
    this.iconSize = 16,
    this.enabled = true,
  });

  /// The site's "← Home" / "← Back" chip at the top of sub-pages.
  factory CapChip.back(BuildContext context, {String? label, VoidCallback? onTap}) {
    return CapChip(
      label: label ?? context.l10n.cBack,
      icon: CapIcons.arrl,
      weight: FontWeight.w600,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      background: context.cap.s1,
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final fg = color ?? (selected ? p.bg : p.tx);
    final bg = background ?? (selected ? p.tx : p.glass);
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Pressable(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: selected ? p.tx : p.ln),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) CapIcon(icon!, size: iconSize, color: fg),
              if (icon != null && label != null) const SizedBox(width: 6),
              if (label != null) Text(label!, style: CapText.sans(size: 14, weight: weight, color: fg)),
              if (trailingIcon != null) ...[const SizedBox(width: 6), CapIcon(trailingIcon!, size: 14, color: fg)],
            ],
          ),
        ),
      ),
    );
  }
}

/// The blue language pill from the website ("हिंदी" / "English").
class LanguagePill extends StatelessWidget {
  final bool isHindi;
  final VoidCallback onTap;
  const LanguagePill({super.key, required this.isHindi, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CapChip(
      label: isHindi ? 'English' : 'हिंदी',
      icon: CapIcons.globe,
      onTap: onTap,
      weight: FontWeight.w700,
      color: Colors.white,
      background: const Color(0xFF3B82F6),
      padding: const EdgeInsets.symmetric(horizontal: 14),
    );
  }
}

class SegItem<T> {
  final T value;
  final String label;
  final String? count;
  const SegItem(this.value, this.label, {this.count});
}

/// `.seg` segmented control; `.seg.sm` when [small].
class CapSeg<T> extends StatelessWidget {
  final List<SegItem<T>> items;
  final T value;
  final ValueChanged<T> onChanged;
  final bool small;

  const CapSeg({super.key, required this.items, required this.value, required this.onChanged, this.small = false});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final row = Row(
      mainAxisSize: small ? MainAxisSize.min : MainAxisSize.max,
      children: [
        for (final item in items)
          _wrap(
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (item.value != value) HapticFeedback.selectionClick();
                onChanged(item.value);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: small ? 28 : 38,
                constraints: BoxConstraints(minWidth: small ? 36 : 0),
                padding: EdgeInsets.symmetric(horizontal: small ? 6 : 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.value == value ? p.s1 : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: item.value == value ? const [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 2))] : null,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text.rich(
                    TextSpan(
                      text: item.label,
                      children: [
                        if (item.count != null)
                          TextSpan(text: ' ${item.count}', style: CapText.mono(size: small ? 11 : 12.5, color: (item.value == value ? p.tx : p.mu).withValues(alpha: 0.65))),
                      ],
                    ),
                    maxLines: 1,
                    style: CapText.sans(size: small ? 12 : 13.5, weight: FontWeight.w500, color: item.value == value ? p.tx : p.mu),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: p.s2, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.ln)),
      child: row,
    );
  }

  Widget _wrap(Widget w) => small ? w : Expanded(child: w);
}

enum CapButtonStyle { amber, ghost, danger, white }

/// `.btn`: 56px amber gradient button with a glow; `.btn.g` ghost variant.
class CapButton extends StatelessWidget {
  final String label;
  final CapIcons? icon;
  final Widget? leading;
  final CapIcons? trailingIcon;
  final VoidCallback? onPressed;
  final bool loading;
  final CapButtonStyle style;
  final double height;
  final Color? textColor;
  final double fontSize;

  const CapButton({
    super.key,
    required this.label,
    this.icon,
    this.leading,
    this.trailingIcon,
    this.onPressed,
    this.loading = false,
    this.style = CapButtonStyle.amber,
    this.height = 56,
    this.textColor,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    Gradient? gradient;
    Color? bg;
    Color fg;
    Border? border;
    List<BoxShadow>? shadow;
    switch (style) {
      case CapButtonStyle.amber:
        gradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(p.am, Colors.white, 0.18)!, p.am],
        );
        fg = p.on;
        shadow = [BoxShadow(color: p.am.withValues(alpha: 0.32), blurRadius: 28, offset: const Offset(0, 10))];
        break;
      case CapButtonStyle.ghost:
        bg = p.s1;
        fg = p.tx;
        border = Border.all(color: p.ln);
        break;
      case CapButtonStyle.danger:
        gradient = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFF7A6B), Color(0xFFD4402F)]);
        fg = Colors.white;
        break;
      case CapButtonStyle.white:
        bg = Colors.white;
        fg = const Color(0xFF1F1F1F);
        border = Border.all(color: const Color(0x33FFFFFF));
        shadow = const [BoxShadow(color: Color(0x59000000), blurRadius: 24, offset: Offset(0, 8))];
        break;
    }
    fg = textColor ?? fg;
    final disabled = onPressed == null || loading;

    return Opacity(
      opacity: onPressed == null && !loading ? 0.5 : 1,
      child: Pressable(
        scale: 0.98,
        onTap: disabled ? null : onPressed,
        child: Container(
          height: height,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: bg,
            gradient: gradient,
            borderRadius: BorderRadius.circular(CapRadius.btn),
            border: border,
            boxShadow: shadow,
          ),
          child: Stack(
            children: [
              if (style == CapButtonStyle.amber)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Container(height: 1, color: const Color(0x73FFFFFF)),
                ),
              Center(
                child: loading
                    ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: fg))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (leading != null) ...[leading!, const SizedBox(width: 10)],
                          if (icon != null) ...[CapIcon(icon!, size: 20, color: fg), const SizedBox(width: 10)],
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: CapText.sans(size: fontSize, weight: FontWeight.w600, color: fg),
                            ),
                          ),
                          if (trailingIcon != null) ...[const SizedBox(width: 10), CapIcon(trailingIcon!, size: 20, color: fg)],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `.sw` toggle switch (mint when on).
class CapSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  const CapSwitch({super.key, required this.value, this.onChanged, this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return Semantics(
      toggled: value,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onChanged == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onChanged!(!value);
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 52,
          height: 30,
          decoration: BoxDecoration(
            color: value ? p.lv : p.s2,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: value ? p.lv : p.ln),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: const Cubic(.2, .8, .2, 1),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.all(3),
              width: 22,
              height: 22,
              decoration: BoxDecoration(color: value ? Colors.white : p.mu, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}

/// `.live` pulsing mint dot.
class LiveDot extends StatefulWidget {
  final Color? color;
  final bool animate;
  final double size;
  const LiveDot({super.key, this.color, this.animate = true, this.size = 9});

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 2));

  @override
  void initState() {
    super.initState();
    if (widget.animate) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant LiveDot old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_c.isAnimating) _c.repeat();
    if (!widget.animate && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.cap.lv;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        // pulse-live: shadow grows to 9px and fades out by 70% of the cycle.
        final t = (_c.value / 0.7).clamp(0.0, 1.0);
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: widget.animate
                ? [BoxShadow(color: color.withValues(alpha: (1 - t) * 0.9), spreadRadius: 9 * t, blurRadius: 0)]
                : null,
          ),
        );
      },
    );
  }
}

/// `.tag` small mono pill.
class CapTag extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? background;
  final Widget? leading;
  final double size;

  const CapTag(this.text, {super.key, this.color, this.background, this.leading, this.size = 11});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: background ?? p.s2, borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Flexible(
            child: Text(
              text.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: CapText.k(color ?? p.tx, size: size),
            ),
          ),
        ],
      ),
    );
  }
}

/// `.av` round avatar with the amber→mint gradient and the first letter.
class CapAvatar extends StatelessWidget {
  final String name;
  final double size;
  final String? imageUrl;
  const CapAvatar({super.key, required this.name, this.size = 44, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final letter = name.trim().isEmpty ? 'C' : name.trim().characters.first.toUpperCase();
    final initial = Center(
      child: Text(letter, style: CapText.sans(size: size * 17 / 44, weight: FontWeight.w600, color: const Color(0xFF071210))),
    );
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [p.am, p.lv]),
      ),
      child: imageUrl == null || imageUrl!.isEmpty
          ? initial
          : Image.network(imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => initial),
    );
  }
}

/// `Sm` logo: app mark plus "Digi Captain".
class CapLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;
  const CapLogo({super.key, this.size = 32, this.showText = true, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size > 40 ? 14 : 9),
            boxShadow: const [BoxShadow(color: Color(0x4D000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Image.asset('assets/images/captain_logo.png', fit: BoxFit.cover),
        ),
        if (showText) ...[
          const SizedBox(width: 8),
          Text(
            context.l10n.cBrand,
            style: CapText.sans(size: 18, weight: FontWeight.w600, color: color ?? context.cap.tx, spacing: -0.36),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Order pieces
// ---------------------------------------------------------------------------

/// `.rail`: mint ring, dotted line, amber dot (pickup → drop).
class RouteRail extends StatelessWidget {
  const RouteRail({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.lv, width: 3)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: CustomPaint(size: const Size(2, double.infinity), painter: _DottedLine(p.mu.withValues(alpha: 0.5))),
            ),
          ),
          Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: p.am)),
        ],
      ),
    );
  }
}

class _DottedLine extends CustomPainter {
  final Color color;
  _DottedLine(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (double y = 1; y < size.height; y += 4) {
      canvas.drawLine(Offset(1, y), Offset(1, y + 0.01), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLine old) => old.color != color;
}

/// `.tl` pickup/drop timeline with labels.
class RouteTimeline extends StatelessWidget {
  final String pickup;
  final String drop;
  final String? pickupLabel;
  final String? dropLabel;
  final bool ellipsis;
  final double fontSize;

  const RouteTimeline({
    super.key,
    required this.pickup,
    required this.drop,
    this.pickupLabel,
    this.dropLabel,
    this.ellipsis = true,
    this.fontSize = 13.5,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final l10n = context.l10n;
    final style = CapText.sans(size: fontSize, weight: FontWeight.w600, color: p.tx);
    Widget line(String label, String value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KLabel(label, padding: const EdgeInsets.only(bottom: 2)),
            Text(
              value.isEmpty ? '—' : value,
              style: style,
              maxLines: ellipsis ? 1 : 4,
              overflow: ellipsis ? TextOverflow.ellipsis : TextOverflow.visible,
            ),
          ],
        );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RouteRail(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                line(pickupLabel ?? l10n.cPickup, pickup),
                const SizedBox(height: 10),
                line(dropLabel ?? l10n.cDrop, drop),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Amber "Collect ₹x in cash" banner used on COD orders.
class CodBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  const CodBanner({super.key, required this.title, required this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: CapPalette.cod.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CapPalette.cod.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        children: [
          const Text('💵', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CapText.sans(size: 14, weight: FontWeight.w700, color: CapPalette.cod)),
                Text(subtitle, style: CapText.sans(size: 12, color: p.mu)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Green "Prepaid order · do not collect cash" strip.
class PrepaidStrip extends StatelessWidget {
  final String text;
  const PrepaidStrip(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: CapPalette.prepaid.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CapPalette.prepaid.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Text('✅', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: CapText.sans(size: 12, weight: FontWeight.w600, color: CapPalette.prepaid))),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slide to act
// ---------------------------------------------------------------------------

/// `.sl` slide-to-confirm track: drag the amber handle past 35% to fire [onAction].
class SlideToAct extends StatefulWidget {
  final String label;
  final FutureOr<void> Function() onAction;
  final bool enabled;
  final bool loading;

  const SlideToAct({super.key, required this.label, required this.onAction, this.enabled = true, this.loading = false});

  @override
  State<SlideToAct> createState() => _SlideToActState();
}

class _SlideToActState extends State<SlideToAct> with SingleTickerProviderStateMixin {
  static const double _handle = 52;
  static const double _inset = 4;
  double _dx = 0;
  bool _dragging = false;
  bool _firing = false;
  late final AnimationController _back = AnimationController(vsync: this, duration: const Duration(milliseconds: 240));
  Animation<double>? _anim;

  @override
  void initState() {
    super.initState();
    _back.addListener(() {
      if (_anim != null) setState(() => _dx = _anim!.value);
    });
  }

  @override
  void dispose() {
    _back.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    _anim = Tween<double>(begin: _dx, end: target).animate(CurvedAnimation(parent: _back, curve: const Cubic(.2, .8, .2, 1)));
    _back.forward(from: 0);
  }

  Future<void> _fire(double max) async {
    _firing = true;
    HapticFeedback.mediumImpact();
    _animateTo(max);
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      await widget.onAction();
    } finally {
      await Future.delayed(const Duration(milliseconds: 350));
      if (mounted) {
        _animateTo(0);
        _firing = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    final active = widget.enabled && !widget.loading;
    return Opacity(
      opacity: widget.enabled ? 1 : 0.5,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final max = math.max(30.0, constraints.maxWidth - _handle - _inset * 2);
          final progress = (_dx / max).clamp(0.0, 1.0);
          return Container(
            height: 60,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: p.s2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.ln),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: (constraints.maxWidth) * progress,
                  child: Container(color: p.am.withValues(alpha: 0.35)),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 48),
                    child: Center(
                      child: Opacity(
                        opacity: (1 - progress * 1.5).clamp(0.0, 1.0),
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CapText.sans(size: 15, weight: FontWeight.w600, color: p.mu),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: _inset + _dx,
                  top: _inset - 1,
                  child: GestureDetector(
                    onHorizontalDragStart: active && !_firing
                        ? (_) {
                            _back.stop();
                            setState(() => _dragging = true);
                          }
                        : null,
                    onHorizontalDragUpdate: active && !_firing ? (d) => setState(() => _dx = (_dx + d.delta.dx).clamp(0.0, max)) : null,
                    onHorizontalDragEnd: active && !_firing
                        ? (_) {
                            setState(() => _dragging = false);
                            if (_dx >= 0.35 * max) {
                              _fire(max);
                            } else {
                              _animateTo(0);
                            }
                          }
                        : null,
                    child: Semantics(
                      button: true,
                      label: widget.label,
                      onTap: active && !_firing ? () => _fire(max) : null,
                      child: Container(
                        width: _handle,
                        height: _handle,
                        decoration: BoxDecoration(
                          color: p.am,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: p.am.withValues(alpha: _dragging ? 0.55 : 0.4), blurRadius: 20, offset: const Offset(0, 6))],
                        ),
                        child: Center(
                          child: widget.loading
                              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: p.on))
                              : CapIcon(CapIcons.arr, size: 22, color: p.on),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// OTP
// ---------------------------------------------------------------------------

/// Four 56x58 OTP boxes in Geist Mono. [shake] plays the site's shake-err animation.
class OtpBoxes extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;
  final int shakeTick;

  const OtpBoxes({super.key, this.length = 4, required this.onChanged, this.shakeTick = 0});

  @override
  State<OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<OtpBoxes> with SingleTickerProviderStateMixin {
  late final List<TextEditingController> _controllers = List.generate(widget.length, (_) => TextEditingController());
  late final List<FocusNode> _nodes = List.generate(widget.length, (_) => FocusNode());
  late final AnimationController _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));

  @override
  void didUpdateWidget(covariant OtpBoxes old) {
    super.didUpdateWidget(old);
    if (widget.shakeTick != old.shakeTick) {
      HapticFeedback.heavyImpact();
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    _shake.dispose();
    super.dispose();
  }

  void _changed(int i, String v) {
    if (v.length > 1) {
      // Pasted or autofilled: spread the digits over the boxes.
      final digits = v.replaceAll(RegExp(r'\D'), '');
      for (var j = 0; j < widget.length; j++) {
        _controllers[j].text = j < digits.length ? digits[j] : '';
      }
      final next = math.min(digits.length, widget.length - 1);
      _nodes[next].requestFocus();
    } else if (v.isNotEmpty && i < widget.length - 1) {
      _nodes[i + 1].requestFocus();
    } else if (v.isEmpty && i > 0) {
      _nodes[i - 1].requestFocus();
    }
    widget.onChanged(_controllers.map((c) => c.text).join());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final t = _shake.value;
        final dx = t == 0 ? 0.0 : math.sin(t * math.pi * 4) * 8;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < widget.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            SizedBox(
              width: 56,
              height: 58,
              child: TextField(
                controller: _controllers[i],
                focusNode: _nodes[i],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: CapText.mono(size: 26, weight: FontWeight.w600, color: p.tx),
                decoration: const InputDecoration(contentPadding: EdgeInsets.zero, counterText: ''),
                onChanged: (v) => _changed(i, v),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sheets, toasts, dialogs
// ---------------------------------------------------------------------------

/// `.grab` handle at the top of sheets.
class GrabHandle extends StatelessWidget {
  const GrabHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: context.cap.ln, borderRadius: BorderRadius.circular(9)),
      ),
    );
  }
}

/// Header row of a modal sheet: `.k` label + `.h2` title on the left, close box on the right.
class SheetHeader extends StatelessWidget {
  final String label;
  final String title;
  final Color? color;
  const SheetHeader({super.key, required this.label, required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KLabel(label, color: color, padding: EdgeInsets.zero),
                const SizedBox(height: 2),
                Text(title, style: CapText.sans(size: 26, weight: FontWeight.w600, color: color ?? p.tx, spacing: -0.4)),
              ],
            ),
          ),
          IconBox(icon: CapIcons.x, iconSize: 18, onTap: () => Navigator.of(context).maybePop()),
        ],
      ),
    );
  }
}

/// `.ov` modal: dimmed, blurred backdrop and a panel sliding up from the bottom.
Future<T?> showCapSheet<T>(BuildContext context, {required WidgetBuilder builder, Color? borderColor}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: const Color(0x99000000),
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (ctx, _, __) {
      final p = ctx.cap;
      final media = MediaQuery.of(ctx);
      return Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxHeight: media.size.height * 0.9, maxWidth: 480),
            width: double.infinity,
            decoration: BoxDecoration(
              color: p.bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(CapRadius.sheet)),
              border: Border.all(color: borderColor ?? p.ln),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(22, 20, 22, 34 + media.viewInsets.bottom + media.padding.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [const GrabHandle(), builder(ctx)],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: const Cubic(.2, .8, .2, 1));
      return BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5 * anim.value, sigmaY: 5 * anim.value),
        child: FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}

/// One choice row in a picker sheet (city, vehicle, reason).
class SheetOption extends StatelessWidget {
  final CapIcons icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const SheetOption({super.key, required this.icon, required this.title, this.subtitle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return CapListItem(
      onTap: onTap,
      background: selected ? p.s2 : Colors.transparent,
      leading: IconBox(
        icon: icon,
        iconSize: 18,
        color: selected ? p.am : p.mu,
        background: selected ? p.am.withValues(alpha: 0.15) : p.s2,
      ),
      trailing: selected ? CapIcon(CapIcons.chk, size: 18, color: p.am) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CapText.sans(size: 15, weight: FontWeight.w600, color: p.tx)),
          if (subtitle != null) Text(subtitle!, style: CapText.sans(size: 12, color: p.mu)),
        ],
      ),
    );
  }
}

OverlayEntry? _toastEntry;

/// `.toast` glass pill near the top of the screen; replaces the previous one.
void showCapToast(BuildContext context, String message, {Duration duration = const Duration(milliseconds: 2200), Color? color}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  _toastEntry?.remove();
  _toastEntry = null;
  final palette = context.cap;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => _Toast(
      message: message,
      palette: palette,
      color: color,
      duration: duration,
      onDone: () {
        if (_toastEntry == entry) {
          entry.remove();
          _toastEntry = null;
        }
      },
    ),
  );
  _toastEntry = entry;
  overlay.insert(entry);
}

class _Toast extends StatefulWidget {
  final String message;
  final CapPalette palette;
  final Color? color;
  final Duration duration;
  final VoidCallback onDone;

  const _Toast({required this.message, required this.palette, required this.duration, required this.onDone, this.color});

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _c.forward();
    _timer = Timer(widget.duration, () async {
      if (!mounted) return;
      await _c.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final top = MediaQuery.of(context).padding.top + 70;
    return Positioned(
      top: top,
      left: 24,
      right: 24,
      child: IgnorePointer(
        child: Center(
          child: FadeTransition(
            opacity: _c,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.6), end: Offset.zero).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut)),
              child: Theme(
                data: ThemeData(extensions: [p]),
                child: Builder(
                  builder: (ctx) => Glass(
                    radius: 99,
                    blur: 14,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: CapText.sans(size: 13, weight: FontWeight.w600, color: widget.color ?? p.tx),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Yes/no question as a bottom sheet. Returns true when confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
  String? label,
}) async {
  final result = await showCapSheet<bool>(
    context,
    builder: (ctx) {
      final p = ctx.cap;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeader(label: label ?? title, title: title, color: destructive ? p.rd : null),
          Text(message, style: CapText.sans(size: 14, color: p.mu, height: 1.5)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CapButton(label: cancelLabel, style: CapButtonStyle.ghost, onPressed: () => Navigator.of(ctx).pop(false)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CapButton(
                  label: confirmLabel,
                  style: destructive ? CapButtonStyle.danger : CapButtonStyle.amber,
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
  return result ?? false;
}

class PickerOption<T> {
  final T value;
  final String label;
  final String? subtitle;
  final CapIcons icon;
  const PickerOption(this.value, this.label, {this.subtitle, this.icon = CapIcons.pin});
}

/// List of choices in a bottom sheet (`Cm` city modal style). Returns the picked value.
Future<T?> showOptionPicker<T>(
  BuildContext context, {
  required String label,
  required String title,
  String? note,
  required List<PickerOption<T>> options,
  T? selected,
}) {
  return showCapSheet<T>(
    context,
    builder: (ctx) {
      final p = ctx.cap;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeader(label: label, title: title),
          if (note != null) ...[
            Text(note, style: CapText.sans(size: 14, color: p.mu, height: 1.45)),
            const SizedBox(height: 16),
          ],
          CapList(
            children: [
              for (final o in options)
                SheetOption(
                  icon: o.icon,
                  title: o.label,
                  subtitle: o.subtitle,
                  selected: o.value == selected,
                  onTap: () => Navigator.of(ctx).pop(o.value),
                ),
            ],
          ),
        ],
      );
    },
  );
}

/// Standard page padding of the site (`.pad`): 28 top, 20 sides, room for the floating nav.
class CapPage extends StatelessWidget {
  final List<Widget> children;
  final Future<void> Function()? onRefresh;
  final EdgeInsets padding;
  final ScrollController? controller;

  const CapPage({
    super.key,
    required this.children,
    this.onRefresh,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 120),
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final list = ListView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: padding.copyWith(top: padding.top + top),
      children: children,
    );
    final p = context.cap;
    final body = onRefresh == null
        ? list
        : RefreshIndicator(color: p.am, backgroundColor: p.s1, edgeOffset: top, onRefresh: onRefresh!, child: list);
    // Content scrolling under the status bar fades into the page background.
    return Stack(
      children: [
        Positioned.fill(child: body),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: top + 12,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [p.bg, p.bg, p.bg.withValues(alpha: 0)],
                  stops: const [0, 0.7, 1],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shimmer-free skeleton block (the site has none; used while the first load runs).
class SkeletonBox extends StatelessWidget {
  final double height;
  final double radius;
  const SkeletonBox({super.key, this.height = 96, this.radius = CapRadius.oc});

  @override
  Widget build(BuildContext context) {
    final p = context.cap;
    return Container(
      height: height,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(color: p.s1, borderRadius: BorderRadius.circular(radius), border: Border.all(color: p.ln)),
    );
  }
}

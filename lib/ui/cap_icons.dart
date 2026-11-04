import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The website's line icons (24x24, stroke 1.75, round caps), drawn from the same SVG paths.
enum CapIcons {
  home,
  hist,
  wal,
  me,
  list,
  arr,
  arrl,
  chevl,
  chk,
  bolt,
  shield,
  flag,
  phone,
  nav,
  up,
  moon,
  bell,
  pin,
  x,
  car,
  lock,
  star,
  chev,
  sos,
  help,
  gift,
  doc,
  globe,
  sun,
  clock,
  trash,
}

const Map<CapIcons, String> _paths = {
  CapIcons.home: '<path d="M3 11l9-8 9 8v9a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z"/>',
  CapIcons.hist: '<path d="M3 12a9 9 0 1 0 3-6.7L3 8"/><path d="M3 3v5h5M12 7v5l3 2"/>',
  CapIcons.wal: '<rect x="3" y="6" width="18" height="14" rx="3"/><path d="M16 13h2M3 10h18M7 6l8-3 2 3"/>',
  CapIcons.me: '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/>',
  CapIcons.list: '<path d="M8 6h13M8 12h13M8 18h13M3.5 6h.01M3.5 12h.01M3.5 18h.01"/>',
  CapIcons.arr: '<path d="M5 12h14M13 6l6 6-6 6"/>',
  CapIcons.arrl: '<path d="M19 12H5M11 18l-6-6 6-6"/>',
  CapIcons.chevl: '<path d="M15 18l-6-6 6-6"/>',
  CapIcons.chk: '<path d="M5 12l5 5 9-10"/>',
  CapIcons.bolt: '<path d="M13 2L4 14h7l-1 8 9-12h-7z"/>',
  CapIcons.shield: '<path d="M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z"/><path d="M9 12l2 2 4-4"/>',
  CapIcons.flag: '<path d="M5 21V4M5 4h11l-2 4 2 4H5"/>',
  CapIcons.phone: '<path d="M5 4h4l2 5-2.5 1.5a11 11 0 0 0 5 5L15 13l5 2v4a2 2 0 0 1-2 2A16 16 0 0 1 3 6a2 2 0 0 1 2-2z"/>',
  CapIcons.nav: '<path d="M3 11l18-8-8 18-2-8z"/>',
  CapIcons.up: '<path d="M12 16V4M6 10l6-6 6 6M4 20h16"/>',
  CapIcons.moon: '<path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"/>',
  CapIcons.bell: '<path d="M6 16V11a6 6 0 0 1 12 0v5l2 2H4zM10 21h4"/>',
  CapIcons.pin: '<path d="M12 21s7-6 7-11a7 7 0 0 0-14 0c0 5 7 11 7 11z"/><circle cx="12" cy="10" r="2.5"/>',
  CapIcons.x: '<path d="M6 6l12 12M18 6L6 18"/>',
  CapIcons.car: '<path d="M5 16V11l2-5h10l2 5v5M3 16h18M7 19v-3M17 19v-3"/><circle cx="8" cy="13" r=".6"/><circle cx="16" cy="13" r=".6"/>',
  CapIcons.lock: '<rect x="5" y="11" width="14" height="9" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/>',
  CapIcons.star: '<path d="M12 3l2.7 5.6 6.1.9-4.4 4.3 1 6.1L12 17l-5.4 2.9 1-6.1L3.2 9.5l6.1-.9z"/>',
  CapIcons.chev: '<path d="M9 6l6 6-6 6"/>',
  CapIcons.sos: '<path d="M12 3l10 18H2z"/><path d="M12 10v5M12 18v.01"/>',
  CapIcons.help: '<circle cx="12" cy="12" r="9"/><path d="M9.5 9.5a2.5 2.5 0 1 1 3.5 2.3c-.7.4-1 1-1 1.7M12 17v.01"/>',
  CapIcons.gift: '<rect x="3" y="8" width="18" height="4"/><path d="M5 12v8h14v-8M12 8v12M12 8c-3 0-4-4-1.5-4S12 8 12 8zm0 0c3 0 4-4 1.5-4S12 8 12 8z"/>',
  CapIcons.doc: '<path d="M6 3h8l4 4v14H6zM14 3v4h4M9 13h6M9 17h6"/>',
  CapIcons.globe: '<circle cx="12" cy="12" r="10"/><path d="M2 12h20M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>',
  CapIcons.sun: '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41"/>',
  CapIcons.clock: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
  CapIcons.trash: '<path d="M4 7h16M10 11v6M14 11v6M5 7l1 13a1 1 0 0 0 1 1h10a1 1 0 0 0 1-1l1-13M9 7V4h6v3"/>',
};

String _hex(Color c) {
  final argb = c.toARGB32();
  return '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}

class CapIcon extends StatelessWidget {
  final CapIcons icon;
  final double size;
  final Color? color;

  /// Fills the shape as well as stroking it (the website's filled rating stars).
  final bool filled;

  const CapIcon(this.icon, {super.key, this.size = 20, this.color, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final c = color ?? DefaultTextStyle.of(context).style.color ?? const Color(0xFF000000);
    final hex = _hex(c);
    final opacity = c.a;
    final svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="${filled ? hex : 'none'}" '
        'stroke="$hex" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round" opacity="$opacity">'
        '${_paths[icon]}</svg>';
    return SvgPicture.string(svg, width: size, height: size);
  }
}

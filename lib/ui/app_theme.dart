import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Colours of the rider website ("Digi Captain", rider.digistall.in). The site has a dark theme
/// (its default) and a light theme; both palettes are copied from its CSS variables.
@immutable
class CapPalette extends ThemeExtension<CapPalette> {
  final Brightness brightness;
  final Color bg; // --bg   page background
  final Color s1; // --s1   cards, inputs
  final Color s2; // --s2   icon boxes, tracks, segmented control
  final Color ln; // --ln   hairline borders
  final Color tx; // --tx   text
  final Color mu; // --mu   muted text
  final Color am; // --am   amber accent (buttons, money)
  final Color amx; // --amx amber text (darker in light theme)
  final Color on; // --on   text on amber
  final Color lv; // --lv   mint "live" accent
  final Color rd; // --rd   red
  final Color map; // --map map land
  final Color mr; // --mr   map roads
  final Color ma; // --ma   map arterial road
  final Color mw; // --mw   map water
  final Color mp; // --mp   map park
  final Color rt; // --rt   route glow
  final Color glass; // --glass frosted surfaces
  final List<BoxShadow> sh; // --sh

  const CapPalette({
    required this.brightness,
    required this.bg,
    required this.s1,
    required this.s2,
    required this.ln,
    required this.tx,
    required this.mu,
    required this.am,
    required this.amx,
    required this.on,
    required this.lv,
    required this.rd,
    required this.map,
    required this.mr,
    required this.ma,
    required this.mw,
    required this.mp,
    required this.rt,
    required this.glass,
    required this.sh,
  });

  bool get isDark => brightness == Brightness.dark;

  static const CapPalette dark = CapPalette(
    brightness: Brightness.dark,
    bg: Color(0xFF060E0D),
    s1: Color(0xFF0D1918),
    s2: Color(0xFF142625),
    ln: Color(0x17FFFFFF),
    tx: Color(0xFFEAF3F1),
    mu: Color(0xFF86A09C),
    am: Color(0xFFFFB547),
    amx: Color(0xFFFFB547),
    on: Color(0xFF1A1200),
    lv: Color(0xFF3FD4B8),
    rd: Color(0xFFFF7A6B),
    map: Color(0xFF091413),
    mr: Color(0x0DFFFFFF),
    ma: Color(0x1AFFFFFF),
    mw: Color(0xFF0A2227),
    mp: Color(0xFF0B2019),
    rt: Color(0xFFFFB547),
    glass: Color(0xC70D1918),
    sh: [BoxShadow(color: Color(0x8C000000), blurRadius: 80, offset: Offset(0, 30))],
  );

  static const CapPalette light = CapPalette(
    brightness: Brightness.light,
    bg: Color(0xFFF3F0E8),
    s1: Color(0xFFFFFFFF),
    s2: Color(0xFFECE8DE),
    ln: Color(0x1A0E2322),
    tx: Color(0xFF0E2322),
    mu: Color(0xFF5E726F),
    am: Color(0xFFE8A020),
    amx: Color(0xFF8F5800),
    on: Color(0xFF1A1200),
    lv: Color(0xFF0F9F86),
    rd: Color(0xFFD4402F),
    map: Color(0xFFE6E9E0),
    mr: Color(0xFFFFFFFF),
    ma: Color(0xFFF8F6EF),
    mw: Color(0xFFCFE3E6),
    mp: Color(0xFFD5E4CF),
    rt: Color(0xFF0E2322),
    glass: Color(0xD1FFFFFF),
    sh: [BoxShadow(color: Color(0x290E2322), blurRadius: 60, offset: Offset(0, 24))],
  );

  /// Cash-on-delivery orange used by the website for COD banners (`#F59E0B`).
  static const Color cod = Color(0xFFF59E0B);

  /// Prepaid green used by the website (`#10B981`).
  static const Color prepaid = Color(0xFF10B981);

  @override
  CapPalette copyWith() => this;

  @override
  CapPalette lerp(ThemeExtension<CapPalette>? other, double t) {
    if (other is! CapPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return CapPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      bg: c(bg, other.bg),
      s1: c(s1, other.s1),
      s2: c(s2, other.s2),
      ln: c(ln, other.ln),
      tx: c(tx, other.tx),
      mu: c(mu, other.mu),
      am: c(am, other.am),
      amx: c(amx, other.amx),
      on: c(on, other.on),
      lv: c(lv, other.lv),
      rd: c(rd, other.rd),
      map: c(map, other.map),
      mr: c(mr, other.mr),
      ma: c(ma, other.ma),
      mw: c(mw, other.mw),
      mp: c(mp, other.mp),
      rt: c(rt, other.rt),
      glass: c(glass, other.glass),
      sh: t < 0.5 ? sh : other.sh,
    );
  }
}

extension CapContext on BuildContext {
  CapPalette get cap => Theme.of(this).extension<CapPalette>() ?? CapPalette.dark;
}

/// Font families of the website. Geist and Instrument Serif have no Devanagari, so Hindi text
/// falls back to Poppins.
class CapFonts {
  CapFonts._();
  static const String sans = 'Geist';
  static const String mono = 'GeistMono';
  static const String serif = 'InstrumentSerif';
  static const List<String> fallback = ['Poppins'];
}

/// The website's text classes (`.serif`, `.mono`, `.k`, `.h1`, `.h2`, `.big`).
class CapText {
  CapText._();

  static TextStyle sans({double size = 15, FontWeight weight = FontWeight.w400, Color? color, double? height, double? spacing}) {
    return TextStyle(
      fontFamily: CapFonts.sans,
      fontFamilyFallback: CapFonts.fallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: spacing,
    );
  }

  /// `.serif` Instrument Serif, letter-spacing -.02em.
  static TextStyle serif({double size = 32, Color? color, double height = 1.05, bool italic = false}) {
    return TextStyle(
      fontFamily: CapFonts.serif,
      fontFamilyFallback: CapFonts.fallback,
      fontSize: size,
      fontWeight: FontWeight.w400,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      color: color,
      height: height,
      letterSpacing: -0.02 * size,
    );
  }

  static TextStyle mono({double size = 12, FontWeight weight = FontWeight.w500, Color? color, double? spacing}) {
    return TextStyle(
      fontFamily: CapFonts.mono,
      fontFamilyFallback: CapFonts.fallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: spacing,
    );
  }

  /// `.k` small uppercase mono label.
  static TextStyle k(Color color, {double size = 11}) {
    return mono(size: size, weight: FontWeight.w500, color: color, spacing: 0.08 * size);
  }
}

class CapRadius {
  CapRadius._();
  static const double input = 16;
  static const double btn = 20;
  static const double oc = 24; // order cards
  static const double list = 26;
  static const double glass = 28;
  static const double sheet = 32;
}

SystemUiOverlayStyle capOverlay(CapPalette p) {
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: p.isDark ? Brightness.light : Brightness.dark,
    statusBarBrightness: p.isDark ? Brightness.dark : Brightness.light,
    systemNavigationBarColor: p.bg,
    systemNavigationBarIconBrightness: p.isDark ? Brightness.light : Brightness.dark,
  );
}

class AppTheme {
  AppTheme._();

  static const String fontFamily = CapFonts.sans;

  static ThemeData build(CapPalette p) {
    final scheme = ColorScheme(
      brightness: p.brightness,
      primary: p.am,
      onPrimary: p.on,
      secondary: p.lv,
      onSecondary: p.bg,
      error: p.rd,
      onError: Colors.white,
      surface: p.s1,
      onSurface: p.tx,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(CapRadius.input),
      borderSide: BorderSide(color: p.ln),
    );

    final base = p.isDark ? ThemeData.dark() : ThemeData.light();

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      fontFamily: CapFonts.sans,
      fontFamilyFallback: CapFonts.fallback,
      colorScheme: scheme,
      extensions: [p],
      scaffoldBackgroundColor: p.bg,
      canvasColor: p.bg,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: p.tx.withValues(alpha: 0.06),
      splashFactory: InkRipple.splashFactory,
      dividerColor: p.ln,
      dividerTheme: DividerThemeData(color: p.ln, thickness: 1, space: 1),
      textTheme: base.textTheme.apply(
        fontFamily: CapFonts.sans,
        fontFamilyFallback: CapFonts.fallback,
        bodyColor: p.tx,
        displayColor: p.tx,
      ),
      iconTheme: IconThemeData(color: p.tx),
      appBarTheme: AppBarTheme(
        backgroundColor: p.bg,
        foregroundColor: p.tx,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: capOverlay(p),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.s1,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        hintStyle: CapText.sans(size: 15, color: p.mu.withValues(alpha: 0.65)),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(borderSide: BorderSide(color: p.am)),
        errorBorder: inputBorder.copyWith(borderSide: BorderSide(color: p.rd)),
        focusedErrorBorder: inputBorder.copyWith(borderSide: BorderSide(color: p.rd)),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.am,
        selectionColor: p.am.withValues(alpha: 0.3),
        selectionHandleColor: p.am,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.am),
      dialogTheme: DialogThemeData(
        backgroundColor: p.bg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CapRadius.sheet),
          side: BorderSide(color: p.ln),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.s1,
        contentTextStyle: CapText.sans(size: 13, weight: FontWeight.w600, color: p.tx),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? CapPalette.prepaid : Colors.transparent),
        side: BorderSide(color: p.mu, width: 1.5),
      ),
    );
  }
}

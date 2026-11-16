import 'package:flutter/material.dart';

import 'nuvi_colors.dart';
import 'nuvi_festival.dart';
import 'nuvi_typography.dart';

/// Context-resolved NUVI tokens: the four festival-swappable accents, the
/// heading font, and the text styles built on them. Read with `context.nuvi`.
@immutable
class NuviThemeX extends ThemeExtension<NuviThemeX> {
  final Color gold;
  final Color peach;
  final Color lavender;
  final Color sage;
  final String headingFont;
  final NuviFestival? festival;

  const NuviThemeX({
    required this.gold,
    required this.peach,
    required this.lavender,
    required this.sage,
    required this.headingFont,
    this.festival,
  });

  static const NuviThemeX day = NuviThemeX(
    gold: NuviColors.gold,
    peach: NuviColors.peach,
    lavender: NuviColors.lavender,
    sage: NuviColors.sage,
    headingFont: NuviTypography.headlineFont,
  );

  factory NuviThemeX.forFestival(NuviFestival? festival) {
    if (festival == null) return day;
    return NuviThemeX(
      gold: festival.gold,
      peach: festival.peach,
      lavender: festival.lavender,
      sage: festival.sage,
      headingFont: festival.headingFont,
      festival: festival,
    );
  }

  bool get isFestive => festival != null;

  // ── Derived colours ────────────────────────────────────────────────────
  /// Text/icon colour that reads on a [gold] fill.
  Color get onGold => _readableOn(gold);

  /// Gold for small text on cream (darkened until it passes 4.5:1).
  Color get goldText => _darkenFor(gold, NuviColors.cream);

  Color get goldSoft => isFestive
      ? Color.lerp(NuviColors.cream, gold, 0.16)!
      : NuviColors.goldSoft;
  Color get peachSoft => Color.lerp(NuviColors.cream, peach, 0.22)!;
  Color get sageSoft => isFestive
      ? Color.lerp(NuviColors.cream, sage, 0.16)!
      : NuviColors.sageSoft;

  /// Bag headings + bag buttons: deep festival colour, olive otherwise.
  Color get bagAccent => isFestive ? lavender : NuviBagColors.olive;
  Color get bagHeading => isFestive ? lavender : NuviBagColors.ink;

  /// Add to Bag / collection accent.
  Color get leaf =>
      isFestive ? _darkenFor(peach, NuviColors.cream) : NuviColors.leaf;

  // ── Type ───────────────────────────────────────────────────────────────
  List<String>? get _headingFallback =>
      headingFont == NuviTypography.headlineFont
      ? null
      : const [NuviTypography.headlineFont];

  TextStyle _heading(double size, FontWeight weight, Color color) => TextStyle(
    fontFamily: headingFont,
    fontFamilyFallback: _headingFallback,
    fontSize: size,
    fontWeight: weight,
    height: NuviTypography.headingHeight,
    color: color,
  );

  TextStyle get display => _heading(30, FontWeight.w800, NuviColors.ink);
  TextStyle get h1 =>
      _heading(NuviTypography.h1, FontWeight.w800, NuviColors.ink);
  TextStyle get h2 =>
      _heading(NuviTypography.h2, FontWeight.w700, NuviColors.ink);
  TextStyle get h3 =>
      _heading(NuviTypography.h3, FontWeight.w700, NuviColors.ink);
  TextStyle get pdpTitle => _heading(24, FontWeight.w700, NuviColors.pdpInk);

  TextStyle baloo(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color? color,
  }) => TextStyle(
    fontFamily: NuviTypography.headlineFont,
    fontSize: size,
    fontWeight: weight,
    height: 1.2,
    color: color ?? NuviColors.ink,
  );

  TextStyle nunito(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.45,
  }) => TextStyle(
    fontFamily: NuviTypography.bodyFont,
    fontSize: size,
    fontWeight: weight,
    height: height,
    color: color ?? NuviColors.ink,
  );

  TextStyle get body => nunito(NuviTypography.body);
  TextStyle get bodyMuted =>
      nunito(NuviTypography.body, color: NuviColors.inkMuted);
  TextStyle get small =>
      nunito(NuviTypography.small, color: NuviColors.inkMuted);
  TextStyle get smallStrong =>
      nunito(NuviTypography.small, weight: FontWeight.w700);
  TextStyle get micro => nunito(NuviTypography.micro, weight: FontWeight.w700);
  TextStyle get article => nunito(17, height: 1.65);

  TextStyle get eyebrow => nunito(
    12,
    weight: FontWeight.w800,
    color: goldText,
    height: 1.2,
  ).copyWith(letterSpacing: 0.36);

  TextStyle get button => baloo(15, weight: FontWeight.w600);
  TextStyle get price => baloo(16, weight: FontWeight.w700);
  TextStyle get priceLarge =>
      baloo(24, weight: FontWeight.w800, color: NuviColors.pdpInk);
  TextStyle get compareAt => nunito(
    13,
    color: NuviColors.inkFaint,
  ).copyWith(decoration: TextDecoration.lineThrough);
  TextStyle get tabLabel => baloo(11.5, weight: FontWeight.w600);

  TextStyle get bagHeadingStyle => TextStyle(
    fontFamily: NuviTypography.bagFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.15,
    color: bagHeading,
  );

  TextStyle bagSerif(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) => TextStyle(
    fontFamily: NuviTypography.bagFont,
    fontSize: size,
    fontWeight: weight,
    height: 1.2,
    color: color ?? bagHeading,
  );

  @override
  NuviThemeX copyWith({
    Color? gold,
    Color? peach,
    Color? lavender,
    Color? sage,
    String? headingFont,
    NuviFestival? festival,
  }) {
    return NuviThemeX(
      gold: gold ?? this.gold,
      peach: peach ?? this.peach,
      lavender: lavender ?? this.lavender,
      sage: sage ?? this.sage,
      headingFont: headingFont ?? this.headingFont,
      festival: festival ?? this.festival,
    );
  }

  @override
  NuviThemeX lerp(covariant NuviThemeX? other, double t) {
    if (other == null) return this;
    return NuviThemeX(
      gold: Color.lerp(gold, other.gold, t)!,
      peach: Color.lerp(peach, other.peach, t)!,
      lavender: Color.lerp(lavender, other.lavender, t)!,
      sage: Color.lerp(sage, other.sage, t)!,
      headingFont: t < 0.5 ? headingFont : other.headingFont,
      festival: t < 0.5 ? festival : other.festival,
    );
  }

  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  static Color _readableOn(Color fill) =>
      _contrast(fill, NuviColors.nightGreen) >=
          _contrast(fill, NuviColors.cream)
      ? NuviColors.nightGreen
      : NuviColors.cream;

  static Color _darkenFor(Color color, Color background) {
    var hsl = HSLColor.fromColor(color);
    var result = color;
    while (_contrast(result, background) < 4.5 && hsl.lightness > 0.05) {
      hsl = hsl.withLightness((hsl.lightness - 0.03).clamp(0.0, 1.0));
      result = hsl.toColor();
    }
    return result;
  }
}

extension NuviThemeContext on BuildContext {
  NuviThemeX get nuvi =>
      Theme.of(this).extension<NuviThemeX>() ?? NuviThemeX.day;
}

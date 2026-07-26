import 'package:flutter/material.dart';

/// Central color palette for the Session Timeline "ancient manuscript"
/// experience. Never hardcode these colors inline in widgets — reference
/// them from here so the whole timeline can be re-themed in one place.
class ManuscriptColors {
  ManuscriptColors._();

  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF3E5AB);
  static const Color goldDeep = Color(0xFFA8862B);

  static const Color bronze = Color(0xFFCD7F32);
  static const Color bronzeDark = Color(0xFF8C5A26);

  static const Color parchment = Color(0xFFF3E9D2);
  static const Color parchmentDark = Color(0xFFE6D6AE);
  static const Color parchmentShadow = Color(0xFFCBB78A);

  static const Color darkBrown = Color(0xFF3B2A1E);
  static const Color darkBrownDeep = Color(0xFF241811);

  static const Color deepRed = Color(0xFF7A1F1F);
  static const Color forestGreen = Color(0xFF2E4A32);

  static const Color lockedFade = Color(0xFFA79B85);

  static const LinearGradient parchmentBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [parchment, parchmentDark],
  );

  static const LinearGradient goldShine = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold, goldDeep],
  );

  static const RadialGradient vignette = RadialGradient(
    center: Alignment.center,
    radius: 1.2,
    colors: [Colors.transparent, Color(0x33241811)],
  );
}

/// Typography for the manuscript UI. Font families reference 'Cinzel' and
/// 'Cormorant' — register them under `flutter.fonts` in pubspec.yaml once
/// the actual font assets are added. Until then Flutter silently falls
/// back to the platform default, so nothing breaks.
class ManuscriptTextStyles {
  ManuscriptTextStyles._();

  static const TextStyle pageTitle = TextStyle(
    fontFamily: 'Cinzel',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: ManuscriptColors.darkBrownDeep,
    letterSpacing: 0.5,
  );

  static const TextStyle pageSubtitle = TextStyle(
    fontFamily: 'Cormorant',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: ManuscriptColors.bronzeDark,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle chapterNumber = TextStyle(
    fontFamily: 'Cinzel',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: ManuscriptColors.gold,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: 'Cinzel',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ManuscriptColors.darkBrown,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: 'Cormorant',
    fontSize: 12.5,
    color: ManuscriptColors.bronzeDark,
  );

  static const TextStyle xpLabel = TextStyle(
    fontFamily: 'Cinzel',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: ManuscriptColors.goldDeep,
    letterSpacing: 0.8,
  );
}

/// Timing constants so every entrance/glow/shimmer animation across the
/// timeline stays consistent and "subtle premium," not exaggerated.
class ManuscriptMotion {
  ManuscriptMotion._();

  static const Duration cardEntrance = Duration(milliseconds: 650);
  static const Duration cardStagger = Duration(milliseconds: 120);
  static const Duration glowPulse = Duration(milliseconds: 1800);
  static const Duration pathShimmer = Duration(milliseconds: 3200);
  static const Duration floatCycle = Duration(milliseconds: 3600);
  static const Duration particleCycle = Duration(milliseconds: 6000);

  static const Curve entranceCurve = Curves.easeOutCubic;
  static const Curve pulseCurve = Curves.easeInOut;
}

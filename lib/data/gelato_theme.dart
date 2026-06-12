import 'package:flutter/material.dart';

class GelatoTheme {
  static const Color bg = Color(0xFFFAF7F8); // Lightest shade
  static const Color pink = Color(0xFFFFCBE1);
  static const Color green = Color(0xFFD6E5BD);
  static const Color yellow = Color(0xFFF9E1A8);
  static const Color blue = Color(0xFFBCD8EC);
  static const Color purple = Color(0xFFDCCCEC);
  static const Color orange = Color(0xFFFFDAB4);

  // Bright, popping versions of Gelato Days palette for highlights, tabs and paths
  static const Color pinkBright = Color(0xFFEC4899);
  static const Color greenBright = Color(0xFF22C55E);
  static const Color yellowBright = Color(0xFFEAB308);
  static const Color blueBright = Color(0xFF3B82F6);
  static const Color purpleBright = Color(0xFF8B5CF6);
  static const Color orangeBright = Color(0xFFF97316);

  // Dark colors for text and icons
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Specific dark accents for each pastel color
  static const Color pinkDark = Color(0xFF6C344D);
  static const Color greenDark = Color(0xFF3B571B);
  static const Color yellowDark = Color(0xFF7A5813);
  static const Color blueDark = Color(0xFF1F4866);
  static const Color purpleDark = Color(0xFF4A1E63);
  static const Color orangeDark = Color(0xFF7C4116);

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 0,
          offset: const Offset(3.5, 3.5),
        ),
      ];

  static Border get cardBorder => Border.all(
        color: Colors.black,
        width: 2.0,
      );

  static BorderRadius get cardRadius => BorderRadius.circular(24);
}

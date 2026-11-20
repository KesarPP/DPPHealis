import 'package:flutter/material.dart';

enum TourScreenType {
  welcome,
  puzzles,
  journal,
  unlockModal,
  mealLogging,
  activity,
  dashboard,
  userMenu,
  leaderboard,
  aiCoach,
  congratulations,
}

enum ArrowDirection {
  top,
  bottom,
  none,
}

class TourStep {
  final String id;
  final String title;
  final String body;
  final String sectionLabel;
  final TourScreenType screenType;
  final Color cardColor;
  final ArrowDirection arrowDirection;
  // Relative position of the chatbox on screen (0.0 = top, 1.0 = bottom)
  final double topFraction;
  // Optional spotlight rect as fraction of screen [left, top, width, height]
  final Rect? spotlightFraction;

  const TourStep({
    required this.id,
    required this.title,
    required this.body,
    required this.sectionLabel,
    required this.screenType,
    required this.cardColor,
    this.arrowDirection = ArrowDirection.none,
    this.topFraction = 0.35,
    this.spotlightFraction,
  });
}

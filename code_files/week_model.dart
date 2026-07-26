import 'package:flutter/foundation.dart';

/// Visual/interaction state of a single week's chapter card, derived from
/// [WeekModel]'s raw fields.
enum WeekCardState {
  locked,
  current,
  completed,
  perfect,
}

/// Immutable data model describing a single week ("chapter") within the
/// gamified Session Timeline.
@immutable
class WeekModel {
  final int id;
  final String title;
  final String subtitle;
  final bool completed;
  final bool locked;
  final double progress; // 0.0 - 1.0
  final int xp;
  final String iconAsset;
  final bool isPerfect;

  const WeekModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.completed,
    required this.locked,
    required this.progress,
    required this.xp,
    required this.iconAsset,
    this.isPerfect = false,
  }) : assert(progress >= 0.0 && progress <= 1.0);

  /// Derived visual state used by [SessionWeekCard] to pick styling.
  WeekCardState get state {
    if (locked) return WeekCardState.locked;
    if (completed && isPerfect) return WeekCardState.perfect;
    if (completed) return WeekCardState.completed;
    return WeekCardState.current;
  }

  WeekModel copyWith({
    int? id,
    String? title,
    String? subtitle,
    bool? completed,
    bool? locked,
    double? progress,
    int? xp,
    String? iconAsset,
    bool? isPerfect,
  }) {
    return WeekModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      completed: completed ?? this.completed,
      locked: locked ?? this.locked,
      progress: progress ?? this.progress,
      xp: xp ?? this.xp,
      iconAsset: iconAsset ?? this.iconAsset,
      isPerfect: isPerfect ?? this.isPerfect,
    );
  }
}

/// Generates 12 weeks of dummy chapter data for local development/preview.
///
/// Replace this call with a real sessions repository once the backend/
/// service layer for Sessions is wired up — nothing else in this feature
/// should need to change, since every widget only depends on [WeekModel].
List<WeekModel> generateDummyWeeks() {
  const titles = [
    "The Awakening",
    "Roots of Change",
    "The Balanced Plate",
    "Currents of Motion",
    "The Mindful Path",
    "Guardians of Habit",
    "The Steady Flame",
    "Whispers of Progress",
    "The Long Trail",
    "Trials of Will",
    "The Golden Harvest",
    "The Final Chapter",
  ];

  const subtitles = [
    "Begin your wellness quest",
    "Understand your starting point",
    "Master the art of nourishment",
    "Discover the power of movement",
    "Cultivate quiet awareness",
    "Defend your daily rituals",
    "Keep the fire burning",
    "Small steps, real change",
    "Endurance builds legends",
    "Face your challenges",
    "Reap what you have sown",
    "Claim your transformation",
  ];

  return List.generate(12, (index) {
    final id = index + 1;
    final isCompleted = id <= 4;
    final isCurrent = id == 5;
    final isLocked = id > 5;
    final isPerfect = id == 3;

    return WeekModel(
      id: id,
      title: "Week $id: ${titles[index]}",
      subtitle: subtitles[index],
      completed: isCompleted,
      locked: isLocked,
      progress: isCompleted
          ? 1.0
          : isCurrent
              ? 0.45
              : 0.0,
      xp: 100 + (index * 25),
      iconAsset: "assets/images/weeks/week_$id.png",
      isPerfect: isPerfect,
    );
  });
}

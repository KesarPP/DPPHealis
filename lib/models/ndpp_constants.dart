import 'package:flutter/foundation.dart';

/// SOURCE OF TRUTH — NDPP RULES (do not deviate)
class NdppConstants {
  static const int weeklyMinutesGoalFinal = 150;
  static const int minQualifyingSessionMinutes = 10;
  
  static const Map<int, int> rampSchedule = {
    5: 60,
    6: 90,
    7: 120,
  };

  static const int rampStepMin = 15;
  static const int rampStepMax = 30;

  static const int caloriesPerWeekAtGoal = 700;
  static const int caloriesPerLbFat = 3500;
  
  static const List<int> targetWeeklyWeightLossLbs = [1, 2];
  static const int minDailyCalories = 1200;
  
  static const String briskPaceRule = "heavier breathing, can talk but not sing";
  static const List<int> activeDaysPerWeekRecommended = [3, 4, 5];

  /// Get the target weekly minutes for a given program week.
  static int getWeeklyTargetForWeek(int programWeek) {
    if (programWeek <= 4) return 60; // Soft ramp / gentle floor
    if (programWeek >= 8) return weeklyMinutesGoalFinal;
    return rampSchedule[programWeek] ?? 60;
  }
}

enum ActivityCategory {
  core,
  lifestyle,
}

enum ActivityType {
  walking,
  briskWalking,
  swimming,
  dancing,
  stairClimbing,
  stretching,
  gardening,
  household,
  other,
}

enum SessionSource {
  healthConnect,
  manual,
}

class ActivitySession {
  final String id;
  final String userId;
  final SessionSource source;
  final ActivityType activityType;
  final ActivityCategory category;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final int steps;
  final double distanceMeters;
  final double caloriesBurned;
  final bool isQualifying;
  final DateTime date; // normalized to midnight

  ActivitySession({
    required this.id,
    required this.userId,
    required this.source,
    required this.activityType,
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.steps = 0,
    this.distanceMeters = 0.0,
    this.caloriesBurned = 0.0,
    required this.isQualifying,
    required this.date,
  });
}

class DailyAggregate {
  final DateTime date; // normalized to midnight
  final int totalSteps;
  final double totalDistance;
  final double totalCalories;
  final int totalActiveMinutes;
  final int qualifyingActiveMinutes;
  final bool isActiveDay;
  final List<ActivitySession> coreSessions;
  final List<ActivitySession> lifestyleSessions;

  DailyAggregate({
    required this.date,
    required this.totalSteps,
    required this.totalDistance,
    required this.totalCalories,
    required this.totalActiveMinutes,
    required this.qualifyingActiveMinutes,
    required this.isActiveDay,
    required this.coreSessions,
    required this.lifestyleSessions,
  });

  factory DailyAggregate.empty(DateTime date) {
    return DailyAggregate(
      date: date,
      totalSteps: 0,
      totalDistance: 0.0,
      totalCalories: 0.0,
      totalActiveMinutes: 0,
      qualifyingActiveMinutes: 0,
      isActiveDay: false,
      coreSessions: [],
      lifestyleSessions: [],
    );
  }
}

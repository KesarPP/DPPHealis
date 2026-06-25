import 'dart:math';

enum ActivityIntensity { low, moderate, vigorous }

class ActivitySession {
  final DateTime startTime;
  final DateTime endTime;
  final ActivityIntensity intensity;
  final int rawSteps;

  const ActivitySession({
    required this.startTime,
    required this.endTime,
    required this.intensity,
    required this.rawSteps,
  });

  // 10 mins vigorous = 20 mins moderate. Vigorous steps count as double.
  int get effectiveSteps =>
      intensity == ActivityIntensity.vigorous ? rawSteps * 2 : rawSteps;

  // A valid session requires at least 1,000 effective steps
  bool get isValid => effectiveSteps >= 1000;
}

class DailyActivity {
  final DateTime date;
  final List<ActivitySession> sessions;

  const DailyActivity({
    required this.date,
    required this.sessions,
  });

  List<ActivitySession> get validSessions =>
      sessions.where((s) => s.isValid).toList();

  int get totalEffectiveSteps =>
      validSessions.fold(0, (sum, s) => sum + s.effectiveSteps);

  bool get hasActivity => validSessions.isNotEmpty;
}

class WeeklyGoalTracker {
  final int programWeek;
  final int targetWeeklySteps; // Starts at 6000, caps at 15000
  final List<DailyActivity> dailyActivities;

  const WeeklyGoalTracker({
    required this.programWeek,
    required this.targetWeeklySteps,
    required this.dailyActivities,
  });

  int get totalStepsThisWeek =>
      dailyActivities.fold(0, (sum, d) => sum + d.totalEffectiveSteps);

  int get activeDaysCount =>
      dailyActivities.where((d) => d.hasActivity).length;
}

class ActivityGoalLogic {
  static const int minTargetSteps = 6000; // 60 minutes
  static const int maxTargetSteps = 15000; // 150 minutes

  /// Determines the new weekly target based on the previous week's performance
  static int calculateNextWeekTarget(
      int currentTarget, int stepsCompletedThisWeek) {
    if (currentTarget < minTargetSteps) {
      currentTarget = minTargetSteps;
    }

    double completionRatio = stepsCompletedThisWeek / currentTarget;

    int newTarget = currentTarget;

    if (completionRatio >= 1.0) {
      // Standard Progression: Met Goal
      newTarget += 3000;
    } else if (completionRatio >= 0.75) {
      // Conservative Progression: Near Miss
      newTarget += 1500;
    } else if (completionRatio < 0.5) {
      // Plateau: Struggling - Do not increase
      newTarget = currentTarget;
    } else {
      // Completed between 50% and 75% - we can add a small increment or keep steady
      // Let's add 1000 just as an intermediate step, or keep steady. 
      // Based on rules: "add no less than 15 minutes (1500 steps)".
      // So if they didn't hit 75%, let's keep it steady.
      newTarget = currentTarget;
    }

    return min(maxTargetSteps, newTarget);
  }

  /// Generates the dynamic milestone label based on the target
  static String getMilestoneLabel(int currentTarget) {
    if (currentTarget <= 6000) return "Getting Started";
    if (currentTarget < 12000) return "Building Momentum";
    if (currentTarget < 15000) return "Almost There";
    return "Goal Achieved";
  }

  /// Calculates the daily activity score from 0 to 100
  static double calculateDailyScore(
      DailyActivity todayActivity, WeeklyGoalTracker weeklyTracker) {
    final int weeklyTarget = weeklyTracker.targetWeeklySteps;
    final int dailyTarget = weeklyTarget ~/ 4; // Optimal spread over 4 days

    // 1. Daily Progress (Max 50 points)
    double dailyProgressRatio =
        todayActivity.totalEffectiveSteps / max(1, dailyTarget);
    double dailyProgressScore = min(1.0, dailyProgressRatio) * 50;

    // 2. Session Bonus (Max 20 points)
    int validSessionCount = todayActivity.validSessions.length;
    double sessionBonusScore = min(1.0, validSessionCount / 2) * 20;

    // 3. Weekly Track / Consistency (Max 30 points)
    // Assume DayOfWeek 1=Monday...7=Sunday for calculation, or just use 
    // the number of days recorded in weeklyTracker if it's a sliding window.
    // Let's assume todayActivity.date.weekday
    int dayOfWeek = todayActivity.date.weekday;
    double expectedStepsByToday = (weeklyTarget / 7) * dayOfWeek;
    
    double weeklyProgressRatio =
        weeklyTracker.totalStepsThisWeek / max(1, expectedStepsByToday);
    double weeklyTrackScore = min(1.0, weeklyProgressRatio) * 30;

    double totalScore =
        dailyProgressScore + sessionBonusScore + weeklyTrackScore;

    return min(100.0, totalScore);
  }

  static String getFeedbackText(double score, double weeklyTrackScore, int validStepsToday) {
    if (score >= 90) return "Outstanding! You're crushing today's goals.";
    if (weeklyTrackScore >= 29) return "You're ahead of your weekly average pace!";
    if (score < 50) return "Great start! A brisk walk later could boost your score.";
    return "You're making great progress today!";
  }
}

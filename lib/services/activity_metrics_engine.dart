import 'dart:math';
import '../models/ndpp_constants.dart';

class Achievement {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final bool unlocked;
  final double progressCurrent;
  final double progressTarget;

  Achievement({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.unlocked,
    required this.progressCurrent,
    required this.progressTarget,
  });
}

class ActivityMetricsEngine {
  /// STREAK / CONSISTENCY
  /// Returns the current streak of consecutive active days.
  static int getCurrentStreak(List<DailyAggregate> pastDays) {
    int streak = 0;
    // pastDays is assumed to be ordered chronologically, today at the end.
    // However, for streak, we look backward.
    for (int i = pastDays.length - 1; i >= 0; i--) {
      final day = pastDays[i];
      if (day.isActiveDay) {
        streak++;
      } else {
        // If today is not active, but yesterday was, we don't break the streak yet,
        // it's just "in progress" today.
        if (i == pastDays.length - 1) {
          continue; // Today hasn't broken it yet
        }
        break; // Streak broken
      }
    }
    return streak;
  }

  static int getStreakLevel(int streak) {
    if (streak >= 60) return 5;
    if (streak >= 30) return 4;
    if (streak >= 14) return 3;
    if (streak >= 7) return 2;
    if (streak >= 1) return 1;
    return 0; // Level 0
  }

  static int getDaysToNextMilestone(int streak) {
    if (streak < 7) return 7 - streak;
    if (streak < 14) return 14 - streak;
    if (streak < 30) return 30 - streak;
    if (streak < 60) return 60 - streak;
    return 0; // Max level reached
  }

  /// WEEKLY PROGRESS
  static double getAverage(List<DailyAggregate> pastDays, int tabIndex) {
    if (pastDays.isEmpty) return 0;
    double sum = 0;
    for (var day in pastDays) {
      if (tabIndex == 0) sum += day.totalSteps;
      else if (tabIndex == 1) sum += day.totalCalories;
      else if (tabIndex == 2) sum += day.totalDistance;
      else if (tabIndex == 3) sum += day.qualifyingActiveMinutes;
    }
    return sum / pastDays.length;
  }

  static DailyAggregate? getBestDay(List<DailyAggregate> pastDays, int tabIndex) {
    if (pastDays.isEmpty) return null;
    return pastDays.reduce((a, b) {
      double valA = _getMetric(a, tabIndex);
      double valB = _getMetric(b, tabIndex);
      return valA > valB ? a : b;
    });
  }

  static int getGoalAchievedCount(List<DailyAggregate> pastDays, int tabIndex, {int stepGoal = 10000, double calGoal = 500, double distGoal = 5.0}) {
    int count = 0;
    for (var day in pastDays) {
      if (tabIndex == 0 && day.totalSteps >= stepGoal) count++;
      else if (tabIndex == 1 && day.totalCalories >= calGoal) count++;
      else if (tabIndex == 2 && day.totalDistance >= distGoal) count++;
      else if (tabIndex == 3 && day.isActiveDay) count++;
    }
    return count;
  }

  static double _getMetric(DailyAggregate day, int tabIndex) {
    if (tabIndex == 0) return day.totalSteps.toDouble();
    if (tabIndex == 1) return day.totalCalories;
    if (tabIndex == 2) return day.totalDistance;
    return day.qualifyingActiveMinutes.toDouble();
  }

  /// TODAY'S ACTIVITY SCORE
  static int calculateActivityScore(DailyAggregate today, int programWeek, {int dailyStepGoal = 10000, double dailyCalGoal = 500}) {
    final int weeklyTarget = NdppConstants.getWeeklyTargetForWeek(programWeek);
    final double dailyTargetMinutes = weeklyTarget / 7; // Even split

    final double stepsComponent = min(1.0, today.totalSteps / max(1, dailyStepGoal)) * 25;
    final double minutesComponent = min(1.0, today.qualifyingActiveMinutes / max(1, dailyTargetMinutes)) * 60;
    final double caloriesComponent = min(1.0, today.totalCalories / max(1, dailyCalGoal)) * 15;

    final score = (stepsComponent + minutesComponent + caloriesComponent).round();
    return score.clamp(0, 100);
  }

  static String getDailyScoreFeedback(int score, int currentWeeklyMinutes, int targetWeeklyMinutes) {
    if (score >= 100) return "Outstanding! You crushed today's goals.";
    if (score >= 80) return "Great job! Keep up the momentum.";
    if (score >= 50) return "Good effort. Every step counts!";
    return "Let's get moving! You can do this.";
  }

  static int? calculateDeltaPct(DailyAggregate today, List<DailyAggregate> pastDaysExcludingToday) {
    if (pastDaysExcludingToday.isEmpty) return null;
    
    double sum = 0;
    for (var day in pastDaysExcludingToday) {
      sum += day.qualifyingActiveMinutes;
    }
    final double avg7 = sum / pastDaysExcludingToday.length;

    if (avg7 == 0) return null;

    final double delta = ((today.qualifyingActiveMinutes - avg7) / avg7) * 100;
    return delta.round();
  }

  /// JOURNEY TO YOUR GOAL
  static Map<String, dynamic> getMilestoneProgress(int currentWeekQualifyingMinutes) {
    final milestones = [
      {'label': 'Week 5', 'target': 60, 'unit': 'min/week'},
      {'label': 'Week 6', 'target': 90, 'unit': 'min/week'},
      {'label': 'Week 7', 'target': 120, 'unit': 'min/week'},
      {'label': 'Week 8+', 'target': 150, 'unit': 'min/week'},
    ];

    int currentMilestoneIndex = -1;
    for (int i = 0; i < milestones.length; i++) {
      if (currentWeekQualifyingMinutes >= (milestones[i]['target'] as int)) {
        currentMilestoneIndex = i;
      }
    }

    final int nextMilestoneIndex = min(currentMilestoneIndex + 1, milestones.length - 1);
    final nextMilestone = milestones[nextMilestoneIndex];
    final int target = nextMilestone['target'] as int;

    final double progressToNext = currentWeekQualifyingMinutes / max(1, target);

    return {
      'currentMilestoneIndex': currentMilestoneIndex,
      'nextMilestone': nextMilestone,
      'progressToNext': min(1.0, progressToNext),
      'milestones': milestones,
    };
  }

  /// ACHIEVEMENTS
  static List<Achievement> evaluateAchievements({
    required List<DailyAggregate> pastDays,
    required int mealLogCount,
    required double baselineWeight,
    required double currentWeight,
    required double riskScore,
    required int programWeek,
  }) {
    final int currentStreak = getCurrentStreak(pastDays);
    
    // Weekly Qualifying Minutes (sum of past 7 days)
    int weeklyQualifyingMinutes = 0;
    Set<ActivityType> distinctTypes = {};
    int stretchCount = 0;
    int lifestyleCount = 0;
    bool has10kDay = false;

    for (var day in pastDays) {
      weeklyQualifyingMinutes += day.qualifyingActiveMinutes;
      if (day.totalSteps >= 10000) has10kDay = true;
      
      for (var s in day.coreSessions) {
        distinctTypes.add(s.activityType);
        if (s.activityType == ActivityType.stretching) stretchCount++;
      }
      for (var s in day.lifestyleSessions) {
        distinctTypes.add(s.activityType);
        lifestyleCount++;
      }
    }

    final double weightLoss = baselineWeight - currentWeight;

    List<Achievement> achievements = [
      Achievement(
        id: 'streak_7',
        title: '7 Day Streak',
        subtitle: 'Consistency is power!',
        icon: 'calendar_month_rounded',
        unlocked: currentStreak >= 7,
        progressCurrent: min(7.0, currentStreak.toDouble()),
        progressTarget: 7.0,
      ),
      Achievement(
        id: 'streak_30',
        title: '30 Day Streak',
        subtitle: 'A month of dedication!',
        icon: 'emoji_events_rounded',
        unlocked: currentStreak >= 30,
        progressCurrent: min(30.0, currentStreak.toDouble()),
        progressTarget: 30.0,
      ),
      Achievement(
        id: 'week_150',
        title: '150 Minute Week',
        subtitle: 'Hit the NDPP goal!',
        icon: 'timer_rounded',
        unlocked: programWeek >= 8 && weeklyQualifyingMinutes >= 150,
        progressCurrent: min(150.0, weeklyQualifyingMinutes.toDouble()),
        progressTarget: 150.0,
      ),
      Achievement(
        id: 'first_10k',
        title: 'First 10K Step Day',
        subtitle: 'Walked the distance!',
        icon: 'directions_walk_rounded',
        unlocked: has10kDay,
        progressCurrent: has10kDay ? 1 : 0,
        progressTarget: 1,
      ),
      Achievement(
        id: 'logged_50_meals',
        title: 'Logged 50 Meals',
        subtitle: 'Tracked your nutrition!',
        icon: 'restaurant_rounded',
        unlocked: mealLogCount >= 50,
        progressCurrent: min(50.0, mealLogCount.toDouble()),
        progressTarget: 50.0,
      ),
      Achievement(
        id: 'activity_explorer',
        title: 'Activity Explorer',
        subtitle: 'Tried 4 different activities!',
        icon: 'explore_rounded',
        unlocked: distinctTypes.length >= 4,
        progressCurrent: min(4.0, distinctTypes.length.toDouble()),
        progressTarget: 4.0,
      ),
      Achievement(
        id: 'stretch_champion',
        title: 'Stretch Champion',
        subtitle: 'Stretched 5 times this week!',
        icon: 'accessibility_new_rounded',
        unlocked: stretchCount >= 5,
        progressCurrent: min(5.0, stretchCount.toDouble()),
        progressTarget: 5.0,
      ),
      Achievement(
        id: 'lifestyle_mover',
        title: 'Lifestyle Mover',
        subtitle: 'Active choices every day!',
        icon: 'cleaning_services_rounded',
        unlocked: lifestyleCount >= 3,
        progressCurrent: min(3.0, lifestyleCount.toDouble()),
        progressTarget: 3.0,
      ),
      Achievement(
        id: 'lose_5kg',
        title: 'Lose 5 kg',
        subtitle: 'Great progress on your weight!',
        icon: 'monitor_weight_rounded',
        unlocked: weightLoss >= 5.0,
        progressCurrent: max(0.0, min(5.0, weightLoss)),
        progressTarget: 5.0,
      ),
      Achievement(
        id: 'low_risk_zone',
        title: 'Reach Low Risk Zone',
        subtitle: 'Reduced your diabetes risk!',
        icon: 'health_and_safety_rounded',
        unlocked: riskScore <= 30.0, // Assuming 30 is low risk threshold
        progressCurrent: min(100.0, max(0.0, 100 - riskScore)), // Inverted
        progressTarget: 100.0 - 30.0,
      ),
    ];

    return achievements;
  }
}

enum MissionGoalMode { ndppStrict, ndppStretch }

class MissionSummary {
  final int minutesGoal;
  final int kcalGoal;
  final int completedMinutes;
  final int completedKcal;
  final int progressPercentage;
  final String goalText;
  final String completedText;

  MissionSummary({
    required this.minutesGoal,
    required this.kcalGoal,
    required this.completedMinutes,
    required this.completedKcal,
    required this.progressPercentage,
    required this.goalText,
    required this.completedText,
  });
}

class ActivityMissionEngine {
  /// Calculates personalized kcal rate per active minute from trailing 30 days
  static double getPersonalizedKcalRate(List<DailyAggregate> trailing30Days) {
    double totalCals = 0;
    int totalQualifyingMins = 0;
    int activeDaysCount = 0;

    for (var day in trailing30Days) {
      if (day.qualifyingActiveMinutes > 0) {
        totalCals += day.totalCalories;
        totalQualifyingMins += day.qualifyingActiveMinutes;
        activeDaysCount++;
      }
    }

    // Fallback if <14 days of active history or 0 qualifying mins: use reference rate ≈ 5.5 kcal/min
    if (activeDaysCount < 14 || totalQualifyingMins == 0) {
      return 5.5;
    }

    return totalCals / totalQualifyingMins;
  }

  /// Evaluates weekly mission summary (Mon-Sun of current ISO week)
  static MissionSummary getWeeklySummary({
    required List<DailyAggregate> trailing30Days,
    required int programWeek,
    required double kcalRate,
    MissionGoalMode mode = MissionGoalMode.ndppStrict,
    double stretchMultiplier = 1.0,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // ISO weekday: Monday is 1, Sunday is 7
    final monday = today.subtract(Duration(days: today.weekday - 1));

    int completedMins = 0;
    double completedCals = 0;

    for (var day in trailing30Days) {
      final d = DateTime(day.date.year, day.date.month, day.date.day);
      if (!d.isBefore(monday)) {
        completedMins += day.qualifyingActiveMinutes;
        completedCals += day.totalCalories;
      }
    }

    int baseMins = NdppConstants.getWeeklyTargetForWeek(programWeek);
    if (mode == MissionGoalMode.ndppStretch) {
      baseMins = (baseMins * stretchMultiplier).round();
    }
    final int kcalGoal = (baseMins * kcalRate).round();

    final double ratioMins = completedMins / max(1, baseMins);
    final double ratioCals = completedCals / max(1, kcalGoal);
    final int progressPct = ((ratioMins * 0.7 + ratioCals * 0.3) * 100).round().clamp(0, 100);

    return MissionSummary(
      minutesGoal: baseMins,
      kcalGoal: kcalGoal,
      completedMinutes: completedMins,
      completedKcal: completedCals.round(),
      progressPercentage: progressPct,
      goalText: '$baseMins Active Mins / ${_formatNumber(kcalGoal)} kcal',
      completedText: '$completedMins Active Mins / ${_formatNumber(completedCals.round())} kcal',
    );
  }

  /// Evaluates monthly mission summary (1st to last day of current calendar month)
  static MissionSummary getMonthlySummary({
    required List<DailyAggregate> trailing30Days,
    required int programWeek,
    required double kcalRate,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    int completedMins = 0;
    double completedCals = 0;

    for (var day in trailing30Days) {
      if (day.date.year == now.year && day.date.month == now.month) {
        completedMins += day.qualifyingActiveMinutes;
        completedCals += day.totalCalories;
      }
    }

    // Monthly goal built from actual mix of overlapping ramp weeks
    double totalMonthMins = 0;
    final int daysInMonth = lastDayOfMonth.difference(firstDayOfMonth).inDays + 1;
    for (int i = 0; i < daysInMonth; i++) {
      final d = firstDayOfMonth.add(Duration(days: i));
      final int diffDays = d.difference(today).inDays;
      final int weekForD = max(1, programWeek + (diffDays / 7).floor());
      totalMonthMins += NdppConstants.getWeeklyTargetForWeek(weekForD) / 7.0;
    }

    final int baseMins = totalMonthMins.round();
    final int kcalGoal = (baseMins * kcalRate).round();

    final double ratioMins = completedMins / max(1, baseMins);
    final double ratioCals = completedCals / max(1, kcalGoal);
    final int progressPct = ((ratioMins * 0.7 + ratioCals * 0.3) * 100).round().clamp(0, 100);

    return MissionSummary(
      minutesGoal: baseMins,
      kcalGoal: kcalGoal,
      completedMinutes: completedMins,
      completedKcal: completedCals.round(),
      progressPercentage: progressPct,
      goalText: '$baseMins Active Mins / ${_formatNumber(kcalGoal)} kcal',
      completedText: '$completedMins Active Mins / ${_formatNumber(completedCals.round())} kcal',
    );
  }

  static String _formatNumber(int val) {
    if (val >= 1000) {
      final String s = val.toString();
      final int cut = s.length - 3;
      return '${s.substring(0, cut)},${s.substring(cut)}';
    }
    return val.toString();
  }
}


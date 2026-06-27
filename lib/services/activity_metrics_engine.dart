import 'dart:math';
import '../models/ndpp_constants.dart';

enum AchievementCategory { streak, food, activity, weight, risk }
enum AchievementType { oneTime, cumulative, threshold }
enum AchievementStatus { locked, earned }

class Achievement {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final AchievementCategory category;
  final AchievementType type;
  final AchievementStatus status;
  final DateTime? earnedDate;
  final double progressCurrent;
  final double progressTarget;

  bool get unlocked => status == AchievementStatus.earned;

  Achievement({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.category = AchievementCategory.activity,
    this.type = AchievementType.oneTime,
    required this.status,
    this.earnedDate,
    required this.progressCurrent,
    required this.progressTarget,
  });
}

class ActivityMetricsEngine {
  /// STREAK / CONSISTENCY
  /// Returns the current streak of consecutive active days.
  static int getCurrentStreak(List<DailyAggregate> pastDays) {
    int streak = 0;
    for (int i = pastDays.length - 1; i >= 0; i--) {
      final day = pastDays[i];
      final bool active = day.isActiveDay || day.totalSteps >= 3000 || day.qualifyingActiveMinutes >= 10 || day.totalActiveMinutes >= 10;
      if (active) {
        streak++;
      } else {
        if (i == pastDays.length - 1) {
          continue;
        }
        break;
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
    Map<String, DateTime>? earnedMap,
  }) {
    final int currentStreak = getCurrentStreak(pastDays);
    
    // Weekly Qualifying Minutes (sum of past 7 days)
    int weeklyQualifyingMinutes = 0;
    Set<ActivityType> distinctTypes = {};
    int stretchCount = 0;
    int lifestyleCount = 0;
    bool has10kDay = false;
    bool hasBriskPace = false;

    // Evaluate rolling 7 days vs older days if pastDays has >7 items
    final List<DailyAggregate> rolling7Days = pastDays.length > 7
        ? pastDays.sublist(pastDays.length - 7)
        : pastDays;

    for (var day in rolling7Days) {
      weeklyQualifyingMinutes += day.qualifyingActiveMinutes;
      for (var s in day.coreSessions) {
        if (s.activityType == ActivityType.stretching) stretchCount++;
      }
      lifestyleCount += day.lifestyleSessions.length;
    }

    for (var day in pastDays) {
      if (day.totalSteps >= 10000) has10kDay = true;
      for (var s in day.coreSessions) {
        distinctTypes.add(s.activityType);
        if (s.activityType == ActivityType.walking && s.durationMinutes >= 10 && s.isQualifying) {
          hasBriskPace = true;
        }
      }
      for (var s in day.lifestyleSessions) {
        distinctTypes.add(s.activityType);
      }
    }

    final double weightLostKg = max(0.0, baselineWeight - currentWeight);

    // TODO: confirm against dedicated risk module if one exists
    final double activityComponent = min(1.0, weeklyQualifyingMinutes / 150.0) * 50.0;
    final double weightComponent = min(1.0, weightLostKg / 5.0) * 50.0;
    final double riskReductionScore = (activityComponent + weightComponent).roundToDouble();

    // Raw condition evaluation map
    final rawConditions = {
      'streak_7': currentStreak >= 7,
      'logged_50_meals': mealLogCount >= 50,
      'first_10k': has10kDay,
      'lose_5kg': weightLostKg >= 5.0,
      'low_risk_zone': riskReductionScore >= 80.0,
      'streak_30': currentStreak >= 30,
      'activity_explorer': distinctTypes.length >= 4,
      'stretch_champion': stretchCount >= 5,
      'lifestyle_mover': lifestyleCount >= 3,
      'week_150': programWeek >= 8 && weeklyQualifyingMinutes >= 150,
      'brisk_pace': hasBriskPace,
      'streak_14': currentStreak >= 14,
    };

    final rawProgress = {
      'streak_7': {'curr': min(7.0, currentStreak.toDouble()), 'targ': 7.0},
      'logged_50_meals': {'curr': min(50.0, mealLogCount.toDouble()), 'targ': 50.0},
      'first_10k': {'curr': has10kDay ? 1.0 : 0.0, 'targ': 1.0},
      'lose_5kg': {'curr': min(5.0, ((weightLostKg * 10).round() / 10)), 'targ': 5.0},
      'low_risk_zone': {'curr': min(100.0, riskReductionScore), 'targ': 100.0},
      'streak_30': {'curr': min(30.0, currentStreak.toDouble()), 'targ': 30.0},
      'activity_explorer': {'curr': min(4.0, distinctTypes.length.toDouble()), 'targ': 4.0},
      'stretch_champion': {'curr': min(5.0, stretchCount.toDouble()), 'targ': 5.0},
      'lifestyle_mover': {'curr': min(3.0, lifestyleCount.toDouble()), 'targ': 3.0},
      'week_150': {'curr': min(150.0, weeklyQualifyingMinutes.toDouble()), 'targ': 150.0},
      'brisk_pace': {'curr': hasBriskPace ? 1.0 : 0.0, 'targ': 1.0},
      'streak_14': {'curr': min(14.0, currentStreak.toDouble()), 'targ': 14.0},
    };

    final meta = {
      'streak_7': {'title': '7 Day Streak', 'sub': 'Kept the streak alive!', 'icon': 'calendar_month_rounded', 'cat': AchievementCategory.streak, 'type': AchievementType.oneTime},
      'logged_50_meals': {'title': 'Logged 50 Meals', 'sub': 'Fueling your body right!', 'icon': 'restaurant_rounded', 'cat': AchievementCategory.food, 'type': AchievementType.cumulative},
      'first_10k': {'title': 'First 10K Step Day', 'sub': 'Big steps, big progress', 'icon': 'directions_walk_rounded', 'cat': AchievementCategory.activity, 'type': AchievementType.oneTime},
      'lose_5kg': {'title': 'Lose 5 kg', 'sub': "You're on your way!", 'icon': 'monitor_weight_rounded', 'cat': AchievementCategory.weight, 'type': AchievementType.threshold},
      'low_risk_zone': {'title': 'Reach Low Risk Zone', 'sub': 'Unlock a healthier you!', 'icon': 'health_and_safety_rounded', 'cat': AchievementCategory.risk, 'type': AchievementType.threshold},
      'streak_30': {'title': '30 Day Streak', 'sub': 'Consistency', 'icon': 'emoji_events_rounded', 'cat': AchievementCategory.streak, 'type': AchievementType.oneTime},
      'activity_explorer': {'title': 'Activity Explorer', 'sub': 'Tried 4 different activities!', 'icon': 'explore_rounded', 'cat': AchievementCategory.activity, 'type': AchievementType.cumulative},
      'stretch_champion': {'title': 'Stretch Champion', 'sub': 'Stretched 5 times this week!', 'icon': 'accessibility_new_rounded', 'cat': AchievementCategory.activity, 'type': AchievementType.threshold},
      'lifestyle_mover': {'title': 'Lifestyle Mover', 'sub': 'Active choices every day!', 'icon': 'cleaning_services_rounded', 'cat': AchievementCategory.activity, 'type': AchievementType.threshold},
      'week_150': {'title': '150 Minute Week', 'sub': 'Hit the NDPP goal!', 'icon': 'timer_rounded', 'cat': AchievementCategory.activity, 'type': AchievementType.threshold},
      'brisk_pace': {'title': 'Brisk Pace Logged', 'sub': 'Walked with a brisk pace!', 'icon': 'directions_walk_rounded', 'cat': AchievementCategory.activity, 'type': AchievementType.oneTime},
      'streak_14': {'title': '14 Day Streak', 'sub': 'Two weeks consistent!', 'icon': 'calendar_month_rounded', 'cat': AchievementCategory.streak, 'type': AchievementType.oneTime},
    };

    List<Achievement> achievements = [];
    for (final key in meta.keys) {
      final isPermanentlyEarned = earnedMap?.containsKey(key) ?? false;
      final isCurrentlyMet = rawConditions[key] ?? false;
      final status = (isPermanentlyEarned || isCurrentlyMet)
          ? AchievementStatus.earned
          : AchievementStatus.locked;
      final eDate = isPermanentlyEarned
          ? earnedMap![key]
          : (isCurrentlyMet ? DateTime.now() : null);

      final p = rawProgress[key]!;
      final curr = status == AchievementStatus.earned ? p['targ']! : p['curr']!;

      final m = meta[key]!;
      achievements.add(Achievement(
        id: key,
        title: m['title'] as String,
        subtitle: m['sub'] as String,
        icon: m['icon'] as String,
        category: m['cat'] as AchievementCategory,
        type: m['type'] as AchievementType,
        status: status,
        earnedDate: eDate,
        progressCurrent: curr,
        progressTarget: p['targ']!,
      ));
    }

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
        completedMins += max(day.qualifyingActiveMinutes, day.totalActiveMinutes);
        completedCals += day.totalCalories;
      }
    }

    int baseMins = NdppConstants.getWeeklyTargetForWeek(programWeek);
    int kcalGoal = (baseMins * 700.0 / 150.0).round();

    if (mode == MissionGoalMode.ndppStretch) {
      baseMins = (baseMins * stretchMultiplier).round();
      kcalGoal = (kcalGoal * stretchMultiplier).round();
    }

    final double ratioMins = completedMins / max(1, baseMins);
    final double ratioCals = completedCals / max(1, kcalGoal);
    final int progressPct = ((ratioMins * 0.7 + ratioCals * 0.3) * 100).round().clamp(0, 100);

    return MissionSummary(
      minutesGoal: baseMins,
      kcalGoal: kcalGoal,
      completedMinutes: completedMins,
      completedKcal: completedCals.round(),
      progressPercentage: progressPct,
      goalText: '$baseMins Active Mins / ~${_formatNumber(kcalGoal)} cal',
      completedText: '$completedMins Active Mins / ${_formatNumber(completedCals.round())} cal',
    );
  }

  /// Evaluates monthly mission summary (1st to last day of current calendar month)
  static MissionSummary getMonthlySummary({
    required List<DailyAggregate> trailing30Days,
    required int programWeek,
    required double kcalRate,
    MissionGoalMode mode = MissionGoalMode.ndppStrict,
    double stretchMultiplier = 1.0,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    int completedMins = 0;
    double completedCals = 0;

    for (var day in trailing30Days) {
      if (day.date.year == now.year && day.date.month == now.month) {
        completedMins += max(day.qualifyingActiveMinutes, day.totalActiveMinutes);
        completedCals += day.totalCalories;
      }
    }

    int baseMins;
    int kcalGoal;

    if (programWeek >= 8) {
      // Steady-state user (Week 8+, the common case): using an average of 4.345 weeks/month
      baseMins = 652; // 150 * 4.345 ≈ 651.75
      kcalGoal = 3041; // 700 * 4.345 ≈ 3041.5
    } else {
      // Mid-ramp user: derive monthly goals from summing actual mix of weeks in calendar month
      double totalMonthMins = 0;
      double totalMonthKcal = 0;
      final int daysInMonth = lastDayOfMonth.difference(firstDayOfMonth).inDays + 1;
      for (int i = 0; i < daysInMonth; i++) {
        final d = firstDayOfMonth.add(Duration(days: i));
        final int diffDays = d.difference(today).inDays;
        final int weekForD = max(1, programWeek + (diffDays / 7).floor());
        final int wTarget = NdppConstants.getWeeklyTargetForWeek(weekForD);
        totalMonthMins += wTarget / 7.0;
        totalMonthKcal += (wTarget * 700.0 / 150.0) / 7.0;
      }
      baseMins = totalMonthMins.round();
      kcalGoal = totalMonthKcal.round();
    }

    if (mode == MissionGoalMode.ndppStretch) {
      baseMins = (baseMins * stretchMultiplier).round();
      kcalGoal = (kcalGoal * stretchMultiplier).round();
    }

    final double ratioMins = completedMins / max(1, baseMins);
    final double ratioCals = completedCals / max(1, kcalGoal);
    final int progressPct = ((ratioMins * 0.7 + ratioCals * 0.3) * 100).round().clamp(0, 100);

    return MissionSummary(
      minutesGoal: baseMins,
      kcalGoal: kcalGoal,
      completedMinutes: completedMins,
      completedKcal: completedCals.round(),
      progressPercentage: progressPct,
      goalText: '$baseMins Active Mins / ~${_formatNumber(kcalGoal)} cal',
      completedText: '$completedMins Active Mins / ${_formatNumber(completedCals.round())} cal',
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


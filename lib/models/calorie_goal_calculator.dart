/// Calorie Goal Calculator
///
/// Implements:
///   Step 1: BMI            (passed in — already computed elsewhere, e.g.
///                            the `bmi` getter in risk_assessment_result_screen.dart)
///   Step 2: REE            (Mifflin-St Jeor)
///   Step 3: Maintenance    (REE x activity factor)
///   Step 4: Daily Calorie Goal (maintenance, or maintenance minus a
///                            deficit derived from a 7%-of-bodyweight
///                            loss target over 24 weeks, when bmi >= 25)
///
/// Extends the spec with weekly and monthly calorie goals, derived from
/// the daily goal (7 days / ~30.44 days-per-month average).

enum Sex { male, female }

/// Immutable result bundle returned by [CalorieGoalCalculator.calculate].
class CalorieGoalResult {
  /// Resting Energy Expenditure (kcal/day).
  final double ree;

  /// Maintenance calories (kcal/day) = ree * activity factor.
  final double maintenance;

  /// Daily calorie deficit applied when bmi >= 25. Null when no deficit
  /// was applied (bmi < 25).
  final double? dailyDeficit;

  /// Final daily calorie target (kcal/day).
  final double dailyCalorieGoal;

  /// Weekly calorie target (kcal/week) = dailyCalorieGoal * 7.
  final double weeklyCalorieGoal;

  /// Monthly calorie target (kcal/month) = dailyCalorieGoal * daysInMonth.
  final double monthlyCalorieGoal;

  const CalorieGoalResult({
    required this.ree,
    required this.maintenance,
    required this.dailyDeficit,
    required this.dailyCalorieGoal,
    required this.weeklyCalorieGoal,
    required this.monthlyCalorieGoal,
  });

  @override
  String toString() {
    return 'CalorieGoalResult('
        'ree: ${ree.toStringAsFixed(1)}, '
        'maintenance: ${maintenance.toStringAsFixed(1)}, '
        'dailyDeficit: ${dailyDeficit?.toStringAsFixed(1)}, '
        'dailyCalorieGoal: ${dailyCalorieGoal.toStringAsFixed(1)}, '
        'weeklyCalorieGoal: ${weeklyCalorieGoal.toStringAsFixed(1)}, '
        'monthlyCalorieGoal: ${monthlyCalorieGoal.toStringAsFixed(1)})';
  }
}

class CalorieGoalCalculator {
  /// Average days per month, used for a stable monthly figure that doesn't
  /// jump between 28/30/31-day months. Pass a different value (e.g. 30)
  /// if the UI needs to match a specific calendar month instead.
  static const double averageDaysPerMonth = 30.44;

  /// BMI threshold above which a calorie deficit is applied.
  static const double overweightBmiThreshold = 25.0;

  /// Fraction of current bodyweight used as the weight-loss target
  /// (7% of bodyweight).
  static const double targetWeightLossFraction = 0.07;

  /// Calories per kg of bodyweight (standard ~7700 kcal/kg approximation).
  static const double caloriesPerKg = 7700.0;

  /// Number of days over which the total deficit is spread (24 weeks).
  static const double deficitPeriodDays = 168.0;

  /// Runs the full calculation and returns daily, weekly, and monthly
  /// calorie goals.
  ///
  /// [weight] in kg, [height] in cm, [age] in years, [bmi] already computed
  /// (e.g. from the existing `bmi` getter in risk_assessment_result_screen.dart).
  static CalorieGoalResult calculate({
    required double weight,
    required double height,
    required int age,
    required Sex sex,
    required double bmi,
    double daysPerMonth = averageDaysPerMonth,
  }) {
    // Step 2: REE (Mifflin-St Jeor)
    final double ree = sex == Sex.male
        ? (10 * weight) + (6.25 * height) - (5 * age) + 5
        : (10 * weight) + (6.25 * height) - (5 * age) - 161;

    // Step 3: Maintenance
    final double activityFactor = sex == Sex.male ? 1.6 : 1.5;
    final double maintenance = ree * activityFactor;

    // Step 4: Daily Calorie Goal
    double? dailyDeficit;
    double dailyCalorieGoal;

    if (bmi >= overweightBmiThreshold) {
      final double targetWeightLoss = weight * targetWeightLossFraction;
      final double totalCaloriesToLose = targetWeightLoss * caloriesPerKg;
      dailyDeficit = totalCaloriesToLose / deficitPeriodDays;
      dailyCalorieGoal = maintenance - dailyDeficit;
    } else {
      dailyCalorieGoal = maintenance;
    }

    // Weekly / Monthly extensions
    final double weeklyCalorieGoal = dailyCalorieGoal * 7;
    final double monthlyCalorieGoal = dailyCalorieGoal * daysPerMonth;

    return CalorieGoalResult(
      ree: ree,
      maintenance: maintenance,
      dailyDeficit: dailyDeficit,
      dailyCalorieGoal: dailyCalorieGoal,
      weeklyCalorieGoal: weeklyCalorieGoal,
      monthlyCalorieGoal: monthlyCalorieGoal,
    );
  }

  /// Calculates a personalized active calorie burn goal (e.g. for exercise)
  /// based on weight and a weekly active minutes target (default 150 mins).
  /// Uses an average MET value of 4.0 (moderate intensity).
  static double calculateActiveCalorieBurnGoal({
    required double weightKg,
    int weeklyTargetMins = 150,
  }) {
    // MET = 4.0 (moderate intensity like brisk walking)
    // kcal burned = MET * 3.5 * weightKg / 200 * durationMins
    return 4.0 * 3.5 * weightKg / 200.0 * weeklyTargetMins;
  }
}

import 'calorie_goal_calculator.dart';

const double defaultKcalBurnRatePerMin = 5.0; // ≈300 kcal/hr brisk walk, light-moderate intensity

class EnergyBalanceModel {
  final double? calorieNeed; // null if profile incomplete
  final double calorieGained;
  final double caloriesToBurn;
  final double caloriesBurned;
  final int activityMinutes;
  final bool isProfileComplete;

  const EnergyBalanceModel({
    required this.calorieNeed,
    required this.calorieGained,
    required this.caloriesToBurn,
    this.caloriesBurned = 0.0,
    required this.activityMinutes,
    required this.isProfileComplete,
  });

  factory EnergyBalanceModel.compute({
    required double? weightKg,
    required double? heightCm,
    required int? age,
    required String? gender,
    required double calorieGained,
    double caloriesBurned = 0.0,
    double kcalBurnRatePerMinute = defaultKcalBurnRatePerMin,
  }) {
    // Default age if missing from older assessment versions
    final int effectiveAge = (age == null || age <= 0) ? 42 : age;

    // Check profile completeness
    if (weightKg == null || heightCm == null || weightKg <= 0 || heightCm <= 0) {
      return EnergyBalanceModel(
        calorieNeed: null,
        calorieGained: calorieGained,
        caloriesToBurn: 0.0,
        caloriesBurned: caloriesBurned,
        activityMinutes: 0,
        isProfileComplete: false,
      );
    }

    final double heightMeters = heightCm / 100.0;
    final double bmi = weightKg / (heightMeters * heightMeters);

    final String g = gender?.trim().toLowerCase() ?? '';
    final Sex sexEnum = (g == 'male' || g == 'man' || g == 'm') ? Sex.male : Sex.female;

    final result = CalorieGoalCalculator.calculate(
      weight: weightKg,
      height: heightCm,
      age: effectiveAge,
      sex: sexEnum,
      bmi: bmi,
    );

    final double computedCalorieNeed = result.dailyCalorieGoal;
    
    final double surplus = calorieGained - computedCalorieNeed;
    final double caloriesToBurn = surplus > 0 ? surplus : 0.0;
    final int activityMinutes = caloriesToBurn > 0 ? (caloriesToBurn / kcalBurnRatePerMinute).round() : 0;

    return EnergyBalanceModel(
      calorieNeed: computedCalorieNeed,
      calorieGained: calorieGained,
      caloriesToBurn: caloriesToBurn,
      caloriesBurned: caloriesBurned,
      activityMinutes: activityMinutes,
      isProfileComplete: true,
    );
  }
}

const double defaultKcalBurnRatePerMin = 5.0; // ≈300 kcal/hr brisk walk, light-moderate intensity

class EnergyBalanceModel {
  final double? calorieNeed; // null if profile incomplete
  final double calorieGained;
  final double caloriesToBurn;
  final int activityMinutes;
  final bool isProfileComplete;

  const EnergyBalanceModel({
    required this.calorieNeed,
    required this.calorieGained,
    required this.caloriesToBurn,
    required this.activityMinutes,
    required this.isProfileComplete,
  });

  factory EnergyBalanceModel.compute({
    required double? weightKg,
    required double? heightCm,
    required int? age,
    required String? gender,
    required double calorieGained,
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
        activityMinutes: 0,
        isProfileComplete: false,
      );
    }

    double ree;
    double af;
    final g = gender?.trim().toLowerCase() ?? '';

    if (g == 'male' || g == 'man' || g == 'm') {
      ree = 10.0 * weightKg + 6.25 * heightCm - 5.0 * effectiveAge + 5.0;
      af = 1.6;
    } else if (g == 'female' || g == 'woman' || g == 'f') {
      ree = 10.0 * weightKg + 6.25 * heightCm - 5.0 * effectiveAge - 161.0;
      af = 1.5;
    } else {
      // Use 1.55 if gender is missing/non-binary
      ree = 10.0 * weightKg + 6.25 * heightCm - 5.0 * effectiveAge - 78.0;
      af = 1.55;
    }

    final double maintenanceCalories = ree * af;
    final double computedCalorieNeed = maintenanceCalories - 500.0;
    
    final double surplus = calorieGained - computedCalorieNeed;
    final double caloriesToBurn = surplus > 0 ? surplus : 0.0;
    final int activityMinutes = caloriesToBurn > 0 ? (caloriesToBurn / kcalBurnRatePerMinute).round() : 0;

    return EnergyBalanceModel(
      calorieNeed: computedCalorieNeed,
      calorieGained: calorieGained,
      caloriesToBurn: caloriesToBurn,
      activityMinutes: activityMinutes,
      isProfileComplete: true,
    );
  }
}

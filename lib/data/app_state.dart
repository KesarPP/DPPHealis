class AppState {
  static int idrsScore = 0;
  static int gpaqMetMinutes = 0;
  static String gpaqLevel = 'Low Activity';

  static bool hasIdrsResult = false;
  static bool hasGpaqResult = false;

  // Biometrics
  static int age = 0;
  static bool isMan = true;
  static double heightCm = 0.0;
  static double weightKg = 0.0;
  static double bmi = 0.0;

  static double calculateDailyCalorieGoal() {
    if (age == 0 || heightCm == 0 || weightKg == 0) {
      return 2000.0; // Fallback if data is missing
    }

    // Step 2: Calculate REE (Mifflin-St Jeor)
    double ree;
    if (isMan) {
      ree = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      ree = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }

    // Step 3: Calculate Maintenance
    double af = isMan ? 1.6 : 1.5;
    double maintenance = ree * af;

    // Step 4: Calculate Daily Calorie Goal
    double dailyCalorieGoal;
    if (bmi >= 25) {
      double targetWeightLoss = weightKg * 0.07;
      double totalCaloriesToLose = targetWeightLoss * 7700;
      double dailyDeficit = totalCaloriesToLose / 168; // 24 weeks * 7 days = 168
      dailyCalorieGoal = maintenance - dailyDeficit;
    } else {
      dailyCalorieGoal = maintenance;
    }

    return dailyCalorieGoal;
  }
}

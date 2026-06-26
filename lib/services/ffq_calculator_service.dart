import '../screens/food_analysis_screen.dart';
import '../data/nutrition_database.dart';

class FfqCalculatorService {
  static final FfqCalculatorService _instance = FfqCalculatorService._internal();

  factory FfqCalculatorService() => _instance;

  FfqCalculatorService._internal();

  final Map<String, FfqAnswer> _responses = {};

  void saveAnswer(String foodName, FfqAnswer answer) {
    _responses[foodName] = answer;
  }

  FfqAnswer? getAnswer(String foodName) => _responses[foodName];

  Map<String, FfqAnswer> getAllResponses() => _responses;

  void clear() => _responses.clear();

  // ── Main calculation ──────────────────────────────────────────────────────

  double calculateDailyCalories() {
    return calculateDailyCaloriesWithBreakdown().totalCalories;
  }

  CalorieResult calculateDailyCaloriesWithBreakdown() {
    double totalCalories = 0.0;
    final List<FoodCalorieEntry> breakdown = [];

    for (final entry in _responses.entries) {
      final name = entry.key;
      final answer = entry.value;

      if (answer.frequency == 'Never') continue;

      // Step 1 – Frequency factor
      double freqFactor = 0.0;
      if (answer.frequency == 'Daily') {
        freqFactor = 1.0;
      } else if (answer.frequency == 'Per Week') {
        freqFactor = 1.0 / 7.0;
      } else if (answer.frequency == 'Per Month') {
        freqFactor = 1.0 / 30.0;
      }

      // Step 2 – Times eaten per day
      final double eatenPerDay = answer.timesPerDay * freqFactor;

      // Step 3 – Portion size in grams
      final double portionGrams = _extractGrams(answer.size);

      // Step 4 – Total grams per day
      final double gramsPerDay = portionGrams * answer.quantityAtTime * eatenPerDay;

      // Step 5 – Calories from nutrition database
      final double calPer100g = _getCaloriesFromDb(name, answer.selectedVariety);
      final double calPerDay = (calPer100g / 100.0) * gramsPerDay;

      totalCalories += calPerDay;
      breakdown.add(FoodCalorieEntry(
        name: answer.selectedVariety != null && answer.selectedVariety!.isNotEmpty ? '$name (${answer.selectedVariety})' : name,
        frequency: '${answer.frequency} × ${answer.timesPerDay}x',
        size: answer.size,
        quantity: answer.quantityAtTime,
        gramsPerDay: gramsPerDay,
        caloriesPerDay: calPerDay,
      ));
    }

    // Sort by highest calorie contributor first
    breakdown.sort((a, b) => b.caloriesPerDay.compareTo(a.caloriesPerDay));

    return CalorieResult(totalCalories: totalCalories, breakdown: breakdown);
  }

  // ── Portion-to-grams converter ──────────────────────────────────────────

  double _extractGrams(String size) {
    // F1–F9: Chapati/Roti sizes (exact weight table from FFQ toolkit)
    if (RegExp(r'^F\d$').hasMatch(size.trim())) {
      final int index = int.tryParse(size.trim().substring(1)) ?? 4;
      const List<double> rotiWeights = [
        93.8, // F1
        81.7, // F2
        70.4, // F3
        60.0, // F4
        47.4, // F5
        38.9, // F6
        24.5, // F7
        11.9, // F8
        3.0,  // F9
      ];
      if (index >= 1 && index <= 9) return rotiWeights[index - 1];
      return 60.0; // fallback to F4
    }

    // Cup/Bowl/Glass/Spoon with explicit ml or g in parentheses
    // e.g. "C2 (100 ml)" → 100g,  "S1 (5 ml)" → 5g,  "N2 (50 g)" → 50g
    final metricMatch = RegExp(r'\(([\d.]+)\s*(g|ml)\)').firstMatch(size);
    if (metricMatch != null) {
      return double.tryParse(metricMatch.group(1)!) ?? 100.0;
    }

    // Fallback for descriptive sizes like "Small", "Medium", "Large"
    final lower = size.toLowerCase();
    if (lower.contains('small')) return 50.0;
    if (lower.contains('medium')) return 100.0;
    if (lower.contains('large')) return 150.0;

    return 100.0; // ultimate fallback
  }

  // ── Nutrition database lookup with fuzzy matching ─────────────────────────

  double _getCaloriesFromDb(String foodName, [String? selectedVariety]) {
    // 0. If user selected a specific variety from the dropdown, find its exact calories!
    if (selectedVariety != null && selectedVariety.isNotEmpty) {
      for (final group in kMajorFoodGroups) {
        for (final item in group.items) {
          for (final variety in item.varieties) {
            if (variety.name == selectedVariety) {
              return variety.calories;
            }
          }
        }
      }
      final flatCal = kNutritionDatabase[selectedVariety];
      if (flatCal != null) return flatCal;
    }

    // 1. Check the newly added major groups (from FFQ (1).xlsx) first
    final cleanFoodName = foodName.toLowerCase().trim();
    for (final group in kMajorFoodGroups) {
      for (final item in group.items) {
        final cleanItemName = item.name.toLowerCase().replaceAll(RegExp(r'^\d+\)\s*'), '').trim();
        if (cleanItemName.isNotEmpty && (cleanItemName.contains(cleanFoodName) || cleanFoodName.contains(cleanItemName))) {
          // Find the first valid variety
          for (final variety in item.varieties) {
            return variety.calories;
          }
        }
      }
    }

    // 2. Case-insensitive substring search in flat database as fallback
    final lower = foodName.toLowerCase();
    for (final entry in kNutritionDatabase.entries) {
      if (entry.key.toLowerCase().contains(lower) ||
          lower.contains(entry.key.toLowerCase().split(' ').first)) {
        return entry.value;
      }
    }

    // 3. Absolute fallback – generic average (~100 kcal/100g)
    return 100.0;
  }
}

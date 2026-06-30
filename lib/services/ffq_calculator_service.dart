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

      // 1. Calories per 100g from database (calories per 100 g)
      double caloriesPer100g = 0.0;
      if (answer.selectedVarieties.isNotEmpty) {
        double totalCal = 0.0;
        for (final v in answer.selectedVarieties) {
          totalCal += _getCaloriesFromDb(name, v);
        }
        caloriesPer100g = totalCal / answer.selectedVarieties.length;
      } else {
        caloriesPer100g = _getCaloriesFromDb(name, answer.selectedVariety);
      }

      // 2. Portion grams
      final double portionGrams = _extractGrams(name, answer.size);

      // 3. Quantity
      final double quantity = answer.quantityAtTime;

      // 4. Times
      final double times = answer.timesPerDay.toDouble();

      // 5. Frequency factor
      double frequencyFactor = 0.0;
      if (answer.frequency == 'Daily') {
        frequencyFactor = 1.0;
      } else if (answer.frequency == 'Per Week') {
        frequencyFactor = 1.0 / 7.0;
      } else if (answer.frequency == 'Per Month') {
        frequencyFactor = 1.0 / 30.0;
      }

      // 6. Calculate calories using the formula:
      // calories = (calories per 100 g ÷ 100) * portion grams * quantity * times * frequency factor
      final double calPerDay = (caloriesPer100g / 100.0) * portionGrams * quantity * times * frequencyFactor;

      final double gramsPerDay = portionGrams * quantity * times * frequencyFactor;

      // Debugging log per user request
      print('Food: $name');
      print('Calories/100g: $caloriesPer100g');
      print('Size: ${answer.size}');
      print('Portion grams: $portionGrams');
      print('Quantity: $quantity');
      print('Times/day: $times');
      print('Frequency factor: $frequencyFactor');
      print('Grams/day: $gramsPerDay');
      print('Calories/day: $calPerDay');

      totalCalories += calPerDay;
      breakdown.add(FoodCalorieEntry(
        name: answer.selectedVarieties.isNotEmpty ? '$name (${answer.selectedVarieties.join(', ')})' : name,
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

  double _extractGrams(String foodName, String size) {
    final cleanFood = foodName.toLowerCase().trim();
    final lowerSize = size.toLowerCase().trim();

    // 1. F1–F9: Chapati/Roti/Flatbread sizes (exact weight table from FFQ toolkit)
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

    // 2. Cup/Bowl/Glass/Spoon/Nuts with explicit ml or g in parentheses
    // e.g. "C2 (100 ml)" → 100g,  "S1 (5 ml)" → 5g,  "N2 (50 g)" → 50g
    final metricMatch = RegExp(r'\(([\d.]+)\s*(g|ml)\)').firstMatch(size);
    if (metricMatch != null) {
      return double.tryParse(metricMatch.group(1)!) ?? 100.0;
    }

    // 3. Biscuits (1 piece = 10 g)
    if (cleanFood.contains('biscuit')) {
      if (lowerSize.contains('small') || lowerSize.contains('1 piece')) return 10.0;
      if (lowerSize.contains('medium') || lowerSize.contains('2 pieces')) return 20.0;
      if (lowerSize.contains('large') || lowerSize.contains('4 pieces')) return 40.0;
      return 10.0;
    }

    // 4. Bread / Pav (1 slice / piece = 30 g)
    if (cleanFood.contains('bread') || cleanFood == 'pav') {
      if (lowerSize.contains('small') || lowerSize.contains('s ')) return 30.0;
      if (lowerSize.contains('medium') || lowerSize.contains('m ')) return 60.0;
      if (lowerSize.contains('large') || lowerSize.contains('l ')) return 90.0;
      return 30.0;
    }

    // 5. Sandwich (1 full sandwich = 120 g, half = 60 g, 2 full = 240 g)
    if (cleanFood == 'sandwich') {
      if (lowerSize.contains('half') || lowerSize.contains('small')) return 60.0;
      if (lowerSize.contains('1 full') || lowerSize.contains('medium')) return 120.0;
      if (lowerSize.contains('2 full') || lowerSize.contains('large')) return 240.0;
      return 120.0;
    }

    // 6. Nan (1 nan = 100 g)
    if (cleanFood == 'nan') {
      if (lowerSize.contains('1 nan') || lowerSize.contains('small')) return 100.0;
      if (lowerSize.contains('1.5 nan') || lowerSize.contains('medium')) return 150.0;
      if (lowerSize.contains('2 nan') || lowerSize.contains('large')) return 200.0;
      return 100.0;
    }

    // 7. Green chillies / Garlic (Small (1) = 2 g)
    if (cleanFood.contains('chilli') || cleanFood.contains('garlic')) {
      return 2.0;
    }

    // 8. Deep fried snacks (Vada/Samosa: 1 piece = 60 g)
    if (cleanFood.contains('fried snack') || cleanFood.contains('vada') || cleanFood.contains('samosa')) {
      if (lowerSize.contains('small') || lowerSize.contains('1')) return 60.0;
      if (lowerSize.contains('medium') || lowerSize.contains('2')) return 120.0;
      if (lowerSize.contains('large') || lowerSize.contains('3')) return 180.0;
      return 60.0;
    }

    // 9. Sweets (Solid sweets like Ladoo/Barfi: 1 piece = 40 g)
    if (cleanFood.contains('sweets (solid)')) {
      if (lowerSize.contains('small') || lowerSize.contains('1')) return 40.0;
      if (lowerSize.contains('medium') || lowerSize.contains('2')) return 80.0;
      if (lowerSize.contains('large') || lowerSize.contains('3')) return 120.0;
      return 40.0;
    }

    // 10. Fruits (Apple, Banana, Mango, etc.) using ball_set (1 medium fruit = 120 g, edible portion)
    const fruitNames = {
      'orange', 'mango', 'guava', 'sweet lime', 'amla', 'banana', 'apple', 'fig', 'berries', 'apricot', 'cashew fruit', 'grapes', 'papaya', 'watermelon', 'muskmelon', 'pomegranate', 'jackfruit', 'pineapple', 'custard apple', 'pear', 'plum', 'peach', 'strawberry'
    };
    if (fruitNames.contains(cleanFood)) {
      if (lowerSize.contains('small') || lowerSize.contains('s ')) return 80.0;
      if (lowerSize.contains('medium') || lowerSize.contains('m ')) return 120.0;
      if (lowerSize.contains('large') || lowerSize.contains('l ')) return 180.0;
      return 120.0;
    }

    // 11. Fresh Fish / Prawns (dry) (sponge set: S = 50g, M = 100g, L = 150g)
    if (cleanFood.contains('fish') || cleanFood.contains('prawn')) {
      if (lowerSize.contains('small') || lowerSize.contains('s(')) return 50.0;
      if (lowerSize.contains('medium') || lowerSize.contains('m(')) return 100.0;
      if (lowerSize.contains('large') || lowerSize.contains('l(')) return 150.0;
      return 100.0;
    }

    // 12. Chaat (Pani puri / Bhel puri) (S = 50g, M = 100g, L = 150g)
    if (cleanFood.contains('chaat')) {
      if (lowerSize.contains('small')) return 50.0;
      if (lowerSize.contains('medium')) return 100.0;
      if (lowerSize.contains('large')) return 150.0;
      return 100.0;
    }

    // Fallback for descriptive sizes like "Small", "Medium", "Large"
    if (lowerSize.contains('small') || lowerSize.contains('s ')) return 50.0;
    if (lowerSize.contains('medium') || lowerSize.contains('m ')) return 100.0;
    if (lowerSize.contains('large') || lowerSize.contains('l ')) return 150.0;

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

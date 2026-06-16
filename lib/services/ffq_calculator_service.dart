import '../screens/food_analysis_screen.dart';

class FfqCalculatorService {
  static final FfqCalculatorService _instance = FfqCalculatorService._internal();

  factory FfqCalculatorService() {
    return _instance;
  }

  FfqCalculatorService._internal();

  final Map<String, FfqAnswer> _responses = {};

  void saveAnswer(String foodName, FfqAnswer answer) {
    _responses[foodName] = answer;
  }

  FfqAnswer? getAnswer(String foodName) {
    return _responses[foodName];
  }

  Map<String, FfqAnswer> getAllResponses() {
    return _responses;
  }

  void clear() {
    _responses.clear();
  }

  double calculateDailyCalories() {
    double totalCalories = 0.0;

    for (var entry in _responses.entries) {
      final name = entry.key;
      final answer = entry.value;

      if (answer.frequency == 'Never') continue;

      double freqFactor = 0.0;
      if (answer.frequency == 'Daily') {
        freqFactor = 1.0;
      } else if (answer.frequency == 'Per Week') {
        freqFactor = 1.0 / 7.0;
      } else if (answer.frequency == 'Per Month') {
        freqFactor = 1.0 / 30.0;
      }

      double eatenPerDay = answer.timesPerDay * freqFactor;

      double portionGrams = _extractGrams(answer.size);

      // The answer.quantityAtTime represents the number of portion units (e.g., 2 cups, 1.5 rotis)
      // or the number of pieces (if size == 'piece').
      double gramsPerServing = portionGrams * answer.quantityAtTime;
      double gramsPerDay = gramsPerServing * eatenPerDay;

      double calPer100g = _getMockCalories(name);
      double calPerDay = (calPer100g / 100.0) * gramsPerDay;

      totalCalories += calPerDay;
    }

    return totalCalories;
  }

  double _extractGrams(String size) {
    // 1. Check if it's F1-F8 (Chapati/Roti sizes)
    if (size.startsWith('F')) {
      final match = RegExp(r'F(\d+)').firstMatch(size);
      if (match != null) {
        int index = int.tryParse(match.group(1)!) ?? 1;
        // Mocking F weights based on user prompt (F4 = 60g)
        // Let's assume F1=30, F2=40, F3=50, F4=60, F5=70, F6=80, F7=90, F8=100
        return 20.0 + (10.0 * index);
      }
    }

    // 2. Try to extract from parentheses e.g., "C1 (50 ml)", "N1 (25 g)"
    final match = RegExp(r'\(([\d\.]+)\s*(g|ml)\)').firstMatch(size);
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 100.0;
    }

    // 3. For piece units without explicit grams in parentheses (e.g., "Small (1 piece)")
    // Mock default of 50g per piece unit if unspecified.
    return 50.0;
  }

  double _getMockCalories(String foodName) {
    // TODO: Replace with actual values from Nutrition Database CSV when provided.
    // For now, we return 100 calories per 100g for everything.
    return 100.0;
  }
}

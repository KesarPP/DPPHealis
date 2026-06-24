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
      final double calPer100g = _getCaloriesFromDb(name);
      final double calPerDay = (calPer100g / 100.0) * gramsPerDay;

      totalCalories += calPerDay;
      breakdown.add(FoodCalorieEntry(
        name: name,
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

  /// Maps FFQ item names to the closest matching dish in kNutritionDatabase.
  static const Map<String, String> _ffqToDbKeyMap = {
    // Beverages
    'Tea': 'Hot tea (Garam Chai)',
    'Coffee': 'Instant coffee',
    'Fruit juice': 'Fruit Punch (with fresh juices)',
    'Vegetable juice': 'Mixed vegetable soup',
    'Sweetened soft drinks': 'Lemonade',
    'Unsweetened (diet) soft drinks': 'Lemonade',
    'Wine': 'Lem-o-gin',
    'Other alcoholic drinks': 'Lem-o-gin',

    // Dairy & Milk Products
    'Milk': 'Flavoured milkshake',
    'Curd': 'Lassi (salted)',
    'Kadi': 'Besan kadhi with pakodies',
    'Raita': 'Tomato onion raita (Tamatar aur pyaaz ka raita)',
    'Buttermilk': 'Lassi (salted)',
    'Khoa / milk sweets (solid)': 'Plain burfi (Burfi)',
    'Milk sweets (liquid)': 'Milk cake',
    'Ice creams': 'Vanilla ice cream without egg',

    // Cereals, Breads & Preparations
    'Biscuits': 'Sweet plain biscuit',
    'White bread': 'Cheese and chilli sandwich ',
    'Whole wheat bread': 'Cheese and chilli sandwich ',
    'Pav': 'Cheese and chilli sandwich ',
    'Pav bhaji': 'Pea potato curry (Aloo matar)',
    'Sandwich': 'Cheese and chilli sandwich ',
    'Nan': 'Naan',
    'Chapati': 'Chapati/Roti',
    'Stuffed paratha': 'Potato parantha/paratha (Aloo ka parantha/paratha)',
    'Deep fried wheat breads': 'Poori',
    'Bhakri (jowar, bajra, nachni)': 'Chapati/Roti',
    'Rice bhakri': 'Chapati/Roti',
    'Idli': 'Idli',
    'Dosa': 'Plain dosa',
    'Papad': 'Chapati/Roti',
    'Rice (plain)': 'Boiled rice (Uble chawal)',
    'Rice preparations': 'Plain pulao',
    'Poha': 'Poha',
    'Upma': 'Semolina upma (Suji/Rava upma)',

    // Pulses & Legumes
    'Dal preparations': 'Washed moong dal (Dhuli moong ki dal)',
    'Wet pulses (dry curry)': 'Black channa curry/Bengal gram curry (Kale chane ki curry)',
    'Wet pulses (gravy curry)': 'Kidney bean curry (Rajmah curry)',

    // Vegetables
    'Green leafy vegetables (dry)': 'Spinach',
    'Green leafy vegetables (wet)': 'Spinach',
    'Gourd (dry)': 'Dry potato (Sookhe aloo)',
    'Gourd (wet)': 'Pea potato curry (Aloo matar)',
    'Brinjal (dry)': 'Brinjal bhartha (Baingan ka bhartha)',
    'Brinjal (wet)': 'Brinjal bhartha (Baingan ka bhartha)',
    'Cauliflower (dry)': 'Potato cauliflower (Aloo gobhi)',
    'Cauliflower (wet)': 'Potato cauliflower (Aloo gobhi)',
    'Drumsticks (dry)': 'Dry potato (Sookhe aloo)',
    'Drumsticks (wet)': 'Pea potato curry (Aloo matar)',
    'Green peas (dry)': 'Dry potato (Sookhe aloo)',
    'Green peas (wet)': 'Pea curry (Matar ki sabzi)',
    'Potato (dry)': 'Dry potato (Sookhe aloo)',
    'Potato (wet)': 'Pea potato curry (Aloo matar)',
    'Yams (dry)': 'Dry potato (Sookhe aloo)',
    'Green beans': 'Cabbage and peas (Pattagobhi aur matar)',
    'Lady finger': 'Stuffed okra (Bharwa bhindi)',
    'Other vegetables (dry)': 'Dry potato (Sookhe aloo)',
    'Other vegetables (wet)': 'Pea potato curry (Aloo matar)',
    'Onion bhaji': 'Onion pakora/pakoda (Pyaaz ke pakode)',
    'Green chillies(Raw/Fried)': 'Stuffed capsicum (Bharwa shimla mirch)',
    'Garlic ': 'Mint and coriander chutney (Pudinay aur dhaniye ki chutney)',
    'Onion (raw)': 'Tossed salad',
    'Carrot (raw)': 'Tossed salad',
    'Cabbage (raw)': 'Tossed salad',

    // Meat, Fish & Eggs
    'Egg (dry)': 'Scrambled egg (Ande ki bhurji)',
    'Egg (wet/curry)': 'Egg curry (Anda curry)',
    'Chicken (dry)': 'Tandoori chicken',
    'Chicken (wet/curry)': 'Chicken curry',
    'Mutton (dry)': 'Dry masala chops',
    'Mutton (wet/curry)': 'Roghan josh',
    'Fresh Fish/prawns (dry)': 'Tandoori fish',
    'Fresh Fish/prawns (wet/curry)': 'Fish curry (Machli curry)',
    'Crab (dry)': 'Crab',
    'Crab (wet/curry)': 'Crab',
    'Dry fish/prawns (dry)': 'Fish tikka',
    'Dry fish/prawns (wet/curry)': 'Fish curry (Machli curry)',

    // Condiments & Side Items
    'Salad': 'Tossed salad',
    'Pickle': 'Dry mango chutney (Sookhe aam ki chutney)',
    'Chutney': 'Coconut chutney (Nariyal ki chutney)',

    // Snacks & Sweets
    'Namkeen': 'Mathri',
    'Deep fried snacks (Vada/Samosa)': 'Potato samosa (Aloo ka samosa)',
    'Chaat (Pani puri / Bhel puri)': 'Sprouted moong dal chat',
    'Puranpoli': 'Sweet split chickpea roti (Sweet channa dal roti/Puranpoli)',
    'Other sweets (solid)': 'Plain burfi (Burfi)',
    'Other sweets (liquid/soft)': 'Gulab Jamun with khoya',
    'Nuts': 'Peanut brittle (Moongfali ki chikki)',
    'Puffed grains / Popcorn': 'Murmura (Puffed rice)',

    // Fruits (now mapped to accurate IFCT 2017 dataset items)
    'Orange': 'Orange',
    'Mango': 'Mango, ripe, kesar',
    'Guava': 'Guava',
    'Sweet lime': 'Sweet lime',
    'Banana': 'Banana',
    'Apple': 'Apple, big',
    'Papaya': 'Papaya',
    'Grapes': 'Grapes, pale green',
    'Pomegranate': 'Pomegranate',
    'Pineapple': 'Pineapple',
    'Watermelon / Melon': 'Watermelon',
    'Chikoo': 'Sapota',
    'Lemon (sour)': 'Lemon, juice',
    'Other fruits': 'Fruit salad (Phalon ka salaad)',
  };

  double _getCaloriesFromDb(String foodName) {
    // 1. Direct lookup via the explicit mapping
    final mapped = _ffqToDbKeyMap[foodName];
    if (mapped != null) {
      final cal = kNutritionDatabase[mapped];
      if (cal != null) return cal;
    }

    // 2. Case-insensitive substring search as fallback
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

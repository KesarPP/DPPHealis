import 'food_item.dart';

class LoggedFood {
  final FoodItem food;
  final int quantity;
  final String mealType;

  LoggedFood({required this.food, this.quantity = 1, required this.mealType});

  Map<String, dynamic> toMap() => {
    'foodId': food.id,
    'name': food.name,
    'calories': food.calories,
    'carbs': food.carbs,
    'protein': food.protein,
    'fat': food.fat,
    'fiber': food.fiber,
    if (food.brand != null) 'brand': food.brand,
    if (food.sugar != null) 'sugar': food.sugar,
    if (food.sodium != null) 'sodium': food.sodium,
    if (food.servingSize != null) 'servingSize': food.servingSize,
    'quantity': quantity,
    'mealType': mealType,
  };

  factory LoggedFood.fromMap(Map<String, dynamic> map) {
    return LoggedFood(
      mealType: map['mealType'] ?? 'Snack',
      quantity: map['quantity'] ?? 1,
      food: FoodItem(
        id: map['foodId'] ?? '',
        name: map['name'] ?? '',
        calories: (map['calories'] ?? 0).toDouble(),
        carbs: (map['carbs'] ?? 0).toDouble(),
        protein: (map['protein'] ?? 0).toDouble(),
        fat: (map['fat'] ?? 0).toDouble(),
        fiber: (map['fiber'] ?? 0).toDouble(),
        brand: map['brand'] as String?,
        sugar: map['sugar'] != null ? (map['sugar'] as num).toDouble() : null,
        sodium: map['sodium'] != null ? (map['sodium'] as num).toDouble() : null,
        servingSize: map['servingSize'] as String?,
      ),
    );
  }
}

class DailyFoodLog {
  final String date;
  final List<LoggedFood> entries;
  final double totalCalories;
  final double totalCarbs;
  final double totalProtein;
  final double totalFat;
  final double totalFiber;

  DailyFoodLog({
    required this.date,
    required this.entries,
    required this.totalCalories,
    required this.totalCarbs,
    required this.totalProtein,
    required this.totalFat,
    required this.totalFiber,
  });

  factory DailyFoodLog.fromFirestore(Map<String, dynamic> data, String dateId) {
    var entriesList = data['entries'] as List<dynamic>? ?? [];
    return DailyFoodLog(
      date: dateId,
      entries: entriesList.map((e) => LoggedFood.fromMap(e as Map<String, dynamic>)).toList(),
      totalCalories: (data['totalCalories'] ?? 0).toDouble(),
      totalCarbs: (data['totalCarbs'] ?? 0).toDouble(),
      totalProtein: (data['totalProtein'] ?? 0).toDouble(),
      totalFat: (data['totalFat'] ?? 0).toDouble(),
      totalFiber: (data['totalFiber'] ?? 0).toDouble(),
    );
  }
}

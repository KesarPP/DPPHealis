class FoodItem {
  final String id;
  final String name;
  final double calories;
  final double carbs;
  final double protein;
  final double fat;
  final double fiber;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.fiber,
  });

  factory FoodItem.fromFirestore(Map<String, dynamic> data, String id) {
    return FoodItem(
      id: id,
      name: data['name'] ?? '',
      calories: (data['calories'] ?? 0).toDouble(),
      carbs: (data['carbs'] ?? 0).toDouble(),
      protein: (data['protein'] ?? 0).toDouble(),
      fat: (data['fat'] ?? 0).toDouble(),
      fiber: (data['fiber'] ?? 0).toDouble(),
    );
  }
}

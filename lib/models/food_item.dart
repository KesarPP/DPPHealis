class FoodItem {
  final String id;
  final String name;
  final double calories;
  final double carbs;
  final double protein;
  final double fat;
  final double fiber;
  final String? brand;
  final double? sugar;
  final double? sodium;
  final String? servingSize;
  final int scanCount;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.fiber,
    this.brand,
    this.sugar,
    this.sodium,
    this.servingSize,
    this.scanCount = 0,
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
      brand: data['brand'] as String?,
      sugar: data['sugar'] != null ? (data['sugar'] as num).toDouble() : null,
      sodium: data['sodium'] != null ? (data['sodium'] as num).toDouble() : null,
      servingSize: data['servingSize'] as String?,
      scanCount: data['scanCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nameSearch': name.toLowerCase(),
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'fiber': fiber,
      if (brand != null) 'brand': brand,
      if (brand != null) 'brandSearch': brand!.toLowerCase(),
      if (sugar != null) 'sugar': sugar,
      if (sodium != null) 'sodium': sodium,
      if (servingSize != null) 'servingSize': servingSize,
      'scanCount': scanCount,
    };
  }
}

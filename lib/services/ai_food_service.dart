import 'dart:io';
import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import '../models/food_item.dart';

class AiFoodService {
  static final AiFoodService _instance = AiFoodService._internal();
  factory AiFoodService() => _instance;
  AiFoodService._internal();

  Future<String?> identifyFood(File imageFile) async {
    try {
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash',
      );

      final imageBytes = await imageFile.readAsBytes();
      final prompt = TextPart(
          'Analyze this image and identify the main food item present. '
              'Respond ONLY with the name of the food in 1 to 3 words. '
              'Do not use any punctuation, descriptive sentences, or markdown. '
              'Example responses: "Apple", "Pizza", "Grilled Chicken", "Salad".'
      );
      final imagePart = InlineDataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      return response.text?.trim();
    } catch (e) {
      throw Exception("Failed to analyze image: $e");
    }
  }

  Future<FoodItem?> analyzeNutritionalLabel(File imageFile) async {
    try {
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash',
      );

      final imageBytes = await imageFile.readAsBytes();
      final prompt = TextPart(
          '''Analyze this nutritional label image and extract the following information.
Look very closely for any brand names, logos, or product names anywhere in the image (even in small text, margins, or copyright text).
Respond ONLY with a valid JSON object matching this structure. Use null or 0.0 for missing values:
{
  "name": "Exact Product Name (e.g. 'Britannia Good Day Butter Biscuit'). Search the entire image for context clues. If absolutely nothing is found, use a descriptive generic name.",
  "brand": "Exact Brand Name (if visible, e.g. 'Britannia')",
  "calories": 0.0,
  "carbs": 0.0,
  "protein": 0.0,
  "fat": 0.0,
  "fiber": 0.0,
  "sugar": 0.0,
  "sodium": 0.0,
  "servingSize": "e.g., 1 cup (240ml)"
}
Do not use markdown formatting like ```json.
'''
      );
      final imagePart = InlineDataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final text = response.text?.trim() ?? '';
      final jsonStr = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final data = jsonDecode(jsonStr);

      return FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: data['name'] ?? 'Unknown',
        calories: (data['calories'] ?? 0).toDouble(),
        carbs: (data['carbs'] ?? 0).toDouble(),
        protein: (data['protein'] ?? 0).toDouble(),
        fat: (data['fat'] ?? 0).toDouble(),
        fiber: (data['fiber'] ?? 0).toDouble(),
        brand: data['brand'],
        sugar: data['sugar'] != null ? (data['sugar'] as num).toDouble() : null,
        sodium: data['sodium'] != null ? (data['sodium'] as num).toDouble() : null,
        servingSize: data['servingSize'],
      );
    } catch (e) {
      throw Exception("Failed to analyze nutritional label: $e");
    }
  }
}
import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../secrets.dart';
import '../models/food_item.dart';

class AiFoodService {
  static final AiFoodService _instance = AiFoodService._internal();
  factory AiFoodService() => _instance;
  AiFoodService._internal();

  GenerativeModel? _model;

  void _init() {
    _model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: geminiApiKey,
    );
  }

  Future<String?> identifyFood(File imageFile) async {
    if (_model == null) _init();

    try {
      final imageBytes = await imageFile.readAsBytes();
      final prompt = TextPart(
          'Analyze this image and identify the main food item present. '
              'Respond ONLY with the name of the food in 1 to 3 words. '
              'Do not use any punctuation, descriptive sentences, or markdown. '
              'Example responses: "Apple", "Pizza", "Grilled Chicken", "Salad".'
      );
      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await _model!.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      return response.text?.trim();
    } catch (e) {
      throw Exception("Failed to analyze image: $e");
    }
  }

  Future<FoodItem?> analyzeNutritionalLabel(File imageFile) async {
    if (_model == null) _init();

    try {
      final imageBytes = await imageFile.readAsBytes();
      final prompt = TextPart(
          'Analyze this nutritional label image. '
          'Extract the following information and return ONLY a valid JSON object without markdown formatting or code blocks: '
          '{"name": "Product Name", "brand": "Brand Name", "calories": 0.0, "carbs": 0.0, "protein": 0.0, "fat": 0.0, "fiber": 0.0, "sugar": 0.0, "sodium": 0.0, "servingSize": "1 cup (100g)"}. '
          'If the brand or name is missing, infer it from the packaging if possible, otherwise use "Unknown". '
          'If nutritional values are missing, set them to 0.0.'
      );
      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await _model!.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      var text = response.text?.trim() ?? '';
      if (text.startsWith('```json')) text = text.substring(7);
      if (text.startsWith('```')) text = text.substring(3);
      if (text.endsWith('```')) text = text.substring(0, text.length - 3);
      
      final Map<String, dynamic> data = jsonDecode(text.trim());
      
      return FoodItem(
        id: '', 
        name: data['name'] ?? 'Unknown Product',
        brand: data['brand'],
        calories: (data['calories'] ?? 0).toDouble(),
        carbs: (data['carbs'] ?? 0).toDouble(),
        protein: (data['protein'] ?? 0).toDouble(),
        fat: (data['fat'] ?? 0).toDouble(),
        fiber: (data['fiber'] ?? 0).toDouble(),
        sugar: data['sugar'] != null ? (data['sugar'] as num).toDouble() : null,
        sodium: data['sodium'] != null ? (data['sodium'] as num).toDouble() : null,
        servingSize: data['servingSize'],
      );
    } catch (e) {
      print('Error parsing label: $e');
      throw Exception("Failed to analyze nutritional label: $e");
    }
  }
}
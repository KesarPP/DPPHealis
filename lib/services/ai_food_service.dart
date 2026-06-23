import 'dart:io';
import 'package:firebase_ai/firebase_ai.dart';

class AiFoodService {
  static final AiFoodService _instance = AiFoodService._internal();
  factory AiFoodService() => _instance;
  AiFoodService._internal();

  Future<String?> identifyFood(File imageFile) async {
    try {
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.0-flash',
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
}
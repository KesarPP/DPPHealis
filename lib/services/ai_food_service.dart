import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../secrets.dart';

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
}
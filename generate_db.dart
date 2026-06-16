import 'dart:io';

void main() {
  final csvFile = File('assets/data/Indian_Food_Nutrition_Processed.csv');
  final lines = csvFile.readAsLinesSync();
  
  final out = StringBuffer();
  out.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  out.writeln('const Map<String, double> kNutritionDatabase = {');
  
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i];
    if (line.trim().isEmpty) continue;
    
    // Split carefully by comma, ignoring commas inside quotes
    List<String> parts = [];
    StringBuffer currentPart = StringBuffer();
    bool inQuotes = false;
    for (int j = 0; j < line.length; j++) {
      if (line[j] == '"') {
        inQuotes = !inQuotes;
      } else if (line[j] == ',' && !inQuotes) {
        parts.add(currentPart.toString());
        currentPart.clear();
      } else {
        currentPart.write(line[j]);
      }
    }
    parts.add(currentPart.toString());
    
    if (parts.length > 1) {
      String dishName = parts[0].replaceAll("'", "\\'").replaceAll('"', '');
      String kcal = parts[1];
      double val = double.tryParse(kcal) ?? 0.0;
      out.writeln("  '$dishName': $val,");
    }
  }
  
  out.writeln('};');
  
  File('lib/data/nutrition_database.dart').writeAsStringSync(out.toString());
  print('Generated lib/data/nutrition_database.dart successfully!');
}

import csv

db = {}

# Read first dataset
try:
    with open('assets/data/Indian_Food_Nutrition_Processed.csv', 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        lines = list(reader)
        for i, row in enumerate(lines):
            if i == 0 or not row: continue
            dish_name = row[0].replace("'", "\\'").replace('"', '')
            try:
                kcal = float(row[1])
            except:
                kcal = 0.0
            db[dish_name] = kcal
except Exception as e:
    print(f"Error reading first dataset: {e}")

# Read second dataset (IFCT 2017)
try:
    with open('lib/data/ifct2017_compositions.csv', 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row['name'].replace("'", "\\'").replace('"', '')
            try:
                enerc = float(row['enerc']) if row['enerc'] else 0.0
                kcal = enerc / 4.184
            except:
                kcal = 0.0
            db[name] = kcal
except Exception as e:
    print(f"Error reading second dataset: {e}")

# Write to Dart file
with open('lib/data/nutrition_database.dart', 'w', encoding='utf-8') as f:
    f.write('// GENERATED CODE - DO NOT MODIFY BY HAND\n')
    f.write('const Map<String, double> kNutritionDatabase = {\n')
    for name, kcal in db.items():
        f.write(f"  '{name}': {kcal:.2f},\n")
    f.write('};\n')

print(f"Generated lib/data/nutrition_database.dart with {len(db)} entries successfully!")

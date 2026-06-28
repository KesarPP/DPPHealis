import csv
import openpyxl
import os

BASE_DIR = r'C:\Users\Neha\AndroidStudioProjects\DPP'

db = {}

# Read first dataset
try:
    with open(os.path.join(BASE_DIR, 'assets/data/Indian_Food_Nutrition_Processed.csv'), 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        lines = list(reader)
        for i, row in enumerate(lines):
            if i == 0 or not row: continue
            dish_name = row[0].replace('\n', ' ').replace('\r', ' ').replace("'", "\\'").replace('"', '').strip()
            try:
                kcal = float(row[1])
            except:
                kcal = 0.0
            db[dish_name] = kcal
except Exception as e:
    print(f"Error reading first dataset: {e}")

# Read second dataset (IFCT 2017)
try:
    with open(os.path.join(BASE_DIR, 'lib/data/ifct2017_compositions.csv'), 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row['name'].replace('\n', ' ').replace('\r', ' ').replace("'", "\\'").replace('"', '').strip()
            try:
                enerc = float(row['enerc']) if row['enerc'] else 0.0
                kcal = enerc / 4.184
            except:
                kcal = 0.0
            db[name] = kcal
except Exception as e:
    print(f"Error reading second dataset: {e}")

# Read FFQ (1).xlsx major groups
major_groups = []
try:
    xlsx_path = os.path.join(BASE_DIR, 'lib', 'data', 'FFQ (1).xlsx')
    print(f"Loading workbook from {xlsx_path}...")
    wb = openpyxl.load_workbook(xlsx_path)
    sheet = wb.active
    
    current_category = None
    current_item = None
    
    for row in list(sheet.iter_rows(max_row=500))[1:]:
        cat_cell = row[0].value
        item_cell = row[1].value
        type_cell = row[2].value
        cal_cell = row[3].value
        
        if cat_cell is not None and str(cat_cell).strip():
            cat_name = str(cat_cell).strip().replace('\n', ' ').replace('\r', ' ').replace("'", "\\'").replace('"', '')
            current_category = {'category': cat_name, 'items': []}
            major_groups.append(current_category)
            current_item = None
            
        if item_cell is not None and str(item_cell).strip():
            if not current_category:
                current_category = {'category': 'General', 'items': []}
                major_groups.append(current_category)
            item_name = str(item_cell).strip().replace('\n', ' ').replace('\r', ' ').replace("'", "\\'").replace('"', '')
            current_item = {'name': item_name, 'varieties': []}
            current_category['items'].append(current_item)
            
        if type_cell is not None and str(type_cell).strip():
            type_name = str(type_cell).strip().replace('\n', ' ').replace('\r', ' ').replace("'", "\\'").replace('"', '')
            cal = 0.0
            if cal_cell is not None:
                try:
                    cal = float(cal_cell)
                except:
                    pass
            if cal == 0.0 and type_name in db:
                cal = db[type_name]
            elif cal > 0.0:
                db[type_name] = cal
                
            if not current_category:
                current_category = {'category': 'General', 'items': []}
                major_groups.append(current_category)
            if not current_item:
                current_item = {'name': type_name, 'varieties': []}
                current_category['items'].append(current_item)
                
            current_item['varieties'].append({'name': type_name, 'calories': cal})

except Exception as e:
    print(f"Error reading FFQ (1).xlsx: {e}")

# Write to Dart file
with open(os.path.join(BASE_DIR, 'lib/data/nutrition_database.dart'), 'w', encoding='utf-8') as f:
    f.write('// GENERATED CODE - DO NOT MODIFY BY HAND\n\n')
    
    # Write data models for major groups
    f.write('''class FoodVariety {
  final String name;
  final double calories;
  const FoodVariety({required this.name, required this.calories});
}

class FoodItemGroup {
  final String name;
  final List<FoodVariety> varieties;
  const FoodItemGroup({required this.name, required this.varieties});
}

class MajorFoodGroup {
  final String category;
  final List<FoodItemGroup> items;
  const MajorFoodGroup({required this.category, required this.items});
}

''')

    # Write kMajorFoodGroups hierarchical list
    f.write('const List<MajorFoodGroup> kMajorFoodGroups = [\n')
    for g in major_groups:
        f.write(f"  MajorFoodGroup(\n    category: '{g['category']}',\n    items: [\n")
        for it in g['items']:
            f.write(f"      FoodItemGroup(\n        name: '{it['name']}',\n        varieties: [\n")
            for v in it['varieties']:
                f.write(f"          FoodVariety(name: '{v['name']}', calories: {v['calories']:.2f}),\n")
            f.write("        ],\n      ),\n")
        f.write("    ],\n  ),\n")
    f.write('];\n\n')

    # Write kNutritionDatabase flat map
    f.write('const Map<String, double> kNutritionDatabase = {\n')
    for name, kcal in db.items():
        f.write(f"  '{name}': {kcal:.2f},\n")
    f.write('};\n')

print(f"Generated lib/data/nutrition_database.dart with {len(major_groups)} major groups and {len(db)} flat entries successfully!")

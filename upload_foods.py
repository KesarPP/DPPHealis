import csv
import os
import sys

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ImportError:
    print("Error: The 'firebase-admin' Python package is not installed.")
    print("Please install it by running: pip install firebase-admin")
    sys.exit(1)

# ---------------------------------------------------------------
# CONFIGURATION - BOTH DATASETS COMBINED
# ---------------------------------------------------------------
SERVICE_ACCOUNT_KEY_PATH = r'C:\Users\angelina\Downloads\dpp-healis-v2-dev-firebase-adminsdk-fbsvc-470a92bb93.json'

DATASET_FILES = [
    # 1. Original IFCT raw ingredients dataset
    r'C:\Users\angelina\Downloads\food_extra.csv',
    # 2. Indian Food Nutrition processed dishes dataset
    r'C:\Users\angelina\Downloads\Indian_Food_Nutrition_Processed - Indian_Food_Nutrition_Processed.csv',
]
# ---------------------------------------------------------------

def parse_float(val):
    try:
        return float(val) if val else 0.0
    except (ValueError, TypeError):
        return 0.0

def main():
    if not os.path.exists(SERVICE_ACCOUNT_KEY_PATH):
        print(f"Error: Could not find the Service Account Key at '{SERVICE_ACCOUNT_KEY_PATH}'")
        sys.exit(1)

    print("Initializing Firebase...")
    cred = credentials.Certificate(SERVICE_ACCOUNT_KEY_PATH)
    firebase_admin.initialize_app(cred)
    db = firestore.client()

    print("Checking existing foods in Firestore to avoid duplicates...")
    existing_names = set()
    for doc in db.collection('foods').select(['nameSearch']).stream():
        ns = doc.to_dict().get('nameSearch', '').strip().lower()
        if ns:
            existing_names.add(ns)
    print(f"Currently in Firestore: {len(existing_names)} unique foods.")

    total_uploaded = 0
    total_skipped = 0

    batch = db.batch()
    batch_count = 0

    for file_path in DATASET_FILES:
        if not os.path.exists(file_path):
            print(f"Warning: File not found: '{file_path}'. Skipping.")
            continue

        print(f"\nProcessing dataset: {os.path.basename(file_path)}...")
        file_uploaded = 0
        file_skipped = 0

        with open(file_path, mode='r', encoding='utf-8-sig') as file:
            reader = csv.DictReader(file)
            for row in reader:
                name = (row.get('Dish Name') or row.get('name') or '').strip()
                if not name:
                    continue

                name_search = name.lower()
                if name_search in existing_names:
                    file_skipped += 1
                    total_skipped += 1
                    continue

                existing_names.add(name_search)

                # Handle calories
                if 'Calories (kcal)' in row:
                    calories_kcal = round(parse_float(row.get('Calories (kcal)')), 2)
                elif 'calories' in row:
                    val = parse_float(row.get('calories'))
                    # If large (likely kJ from IFCT), convert kJ to kcal
                    calories_kcal = round(val / 4.184, 2) if val > 2000 or 'food_extra' in file_path else round(val, 2)
                else:
                    calories_kcal = 0.0

                carbs = parse_float(row.get('Carbohydrates (g)') or row.get('carbs'))
                protein = parse_float(row.get('Protein (g)') or row.get('protein'))
                fat = parse_float(row.get('Fats (g)') or row.get('fat'))
                fiber = parse_float(row.get('Fibre (g)') or row.get('Fiber (g)') or row.get('fiber'))
                sugar = parse_float(row.get('Free Sugar (g)') or row.get('sugar'))
                sodium = parse_float(row.get('Sodium (mg)') or row.get('sodium'))

                food_data = {
                    'name': name,
                    'nameSearch': name_search,
                    'calories': calories_kcal,
                    'carbs': round(carbs, 2),
                    'protein': round(protein, 2),
                    'fat': round(fat, 2),
                    'fiber': round(fiber, 2),
                    'sugar': round(sugar, 2),
                    'sodium': round(sodium, 2),
                    'scanCount': 0,
                }

                doc_ref = db.collection('foods').document()
                batch.set(doc_ref, food_data)
                batch_count += 1
                file_uploaded += 1
                total_uploaded += 1

                if batch_count == 500:
                    batch.commit()
                    print(f"  Batch committed (current file added: {file_uploaded})...")
                    batch = db.batch()
                    batch_count = 0

        print(f"Finished {os.path.basename(file_path)}: Added {file_uploaded}, Skipped {file_skipped} (already existed).")

    if batch_count > 0:
        batch.commit()
        print("  Final batch committed.")

    final_total = db.collection('foods').count().get()[0][0].value
    print(f"\n==========================================")
    print(f"SUCCESS! Both datasets are synced.")
    print(f"Total uploaded this run: {total_uploaded}")
    print(f"Total items in Firestore 'foods': {final_total}")
    print(f"==========================================")

if __name__ == '__main__':
    main()

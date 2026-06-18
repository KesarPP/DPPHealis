import csv
import json
import os
import sys

# Try to import firebase_admin, prompt user to install if missing
try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ImportError:
    print("Error: The 'firebase-admin' Python package is not installed.")
    print("Please install it by running: pip install firebase-admin")
    sys.exit(1)

# Configuration - User needs to fill in their JSON key path here
SERVICE_ACCOUNT_KEY_PATH = r'C:\Users\angelina\Downloads\dppproject-1998e-firebase-adminsdk-fbsvc-a2fa529c44.json'
CSV_FILE_PATH = r'C:\Users\angelina\Downloads\Indian_Food_Nutrition_Processed - Indian_Food_Nutrition_Processed.csv'

def main():
    if not os.path.exists(SERVICE_ACCOUNT_KEY_PATH):
        print(f"Error: Could not find the Service Account Key at '{SERVICE_ACCOUNT_KEY_PATH}'")
        print("Please update the 'SERVICE_ACCOUNT_KEY_PATH' variable in this script with the correct path to your JSON key file.")
        sys.exit(1)

    if not os.path.exists(CSV_FILE_PATH):
        print(f"Error: Could not find the CSV file at '{CSV_FILE_PATH}'")
        sys.exit(1)

    print("Initializing Firebase...")
    cred = credentials.Certificate(SERVICE_ACCOUNT_KEY_PATH)
    firebase_admin.initialize_app(cred)
    db = firestore.client()

    print("Reading CSV and preparing batch upload...")
    
    # Firestore has a limit of 500 writes per batch
    batch = db.batch()
    batch_count = 0
    total_uploaded = 0

    with open(CSV_FILE_PATH, mode='r', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        for row in reader:
            dish_name = row.get('Dish Name', '').strip()
            
            if not dish_name:
                continue

            # Create lowercase nameSearch for prefix querying in Flutter
            name_search = dish_name.lower()

            # Parse numeric values safely
            def parse_float(val):
                try:
                    return float(val) if val else 0.0
                except ValueError:
                    return 0.0

            food_data = {
                'name': dish_name,
                'nameSearch': name_search,
                'calories': parse_float(row.get('Calories (kcal)', 0)),
                'carbs': parse_float(row.get('Carbohydrates (g)', 0)),
                'protein': parse_float(row.get('Protein (g)', 0)),
                'fat': parse_float(row.get('Fats (g)', 0)),
                'fiber': parse_float(row.get('Fibre (g)', 0)),
                'sugar': parse_float(row.get('Free Sugar (g)', 0)),
                'sodium': parse_float(row.get('Sodium (mg)', 0)),
            }

            # Add to batch
            doc_ref = db.collection('foods').document()
            batch.set(doc_ref, food_data)
            batch_count += 1
            total_uploaded += 1

            # Commit batch every 500 documents
            if batch_count == 500:
                batch.commit()
                print(f"Uploaded {total_uploaded} items...")
                batch = db.batch()
                batch_count = 0

    # Commit any remaining items in the final batch
    if batch_count > 0:
        batch.commit()
        print(f"Uploaded {total_uploaded} items...")

    print(f"\nSuccess! A total of {total_uploaded} food items have been uploaded to the 'foods' collection in Firestore.")

if __name__ == '__main__':
    main()

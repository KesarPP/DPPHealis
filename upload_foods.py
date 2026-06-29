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
# UPDATE THESE TWO PATHS BEFORE RUNNING
# ---------------------------------------------------------------
SERVICE_ACCOUNT_KEY_PATH = r'C:\Users\angelina\Downloads\dppproject-1998e-firebase-adminsdk-fbsvc-a2fa529c44.json'
CSV_FILE_PATH = r'C:\Users\angelina\Downloads\food_extra.csv'
# ---------------------------------------------------------------

def parse_float(val):
    try:
        return float(val) if val else 0.0
    except ValueError:
        return 0.0

def main():
    if not os.path.exists(SERVICE_ACCOUNT_KEY_PATH):
        print(f"Error: Could not find the Service Account Key at '{SERVICE_ACCOUNT_KEY_PATH}'")
        sys.exit(1)

    if not os.path.exists(CSV_FILE_PATH):
        print(f"Error: Could not find the CSV file at '{CSV_FILE_PATH}'")
        sys.exit(1)

    print("Initializing Firebase...")
    cred = credentials.Certificate(SERVICE_ACCOUNT_KEY_PATH)
    firebase_admin.initialize_app(cred)
    db = firestore.client()

    print("Reading CSV and preparing batch upload...")

    batch = db.batch()
    batch_count = 0
    total_uploaded = 0

    with open(CSV_FILE_PATH, mode='r', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        for row in reader:
            name = row.get('name', '').strip()
            if not name:
                continue

            # IFCT stores energy in kJ — convert to kcal
            calories_kcal = round(parse_float(row.get('calories', 0)) / 4.184, 2)

            food_data = {
                'name': name,
                'nameSearch': name.lower(),
                'calories': calories_kcal,
                'carbs': round(parse_float(row.get('carbs', 0)), 2),
                'protein': round(parse_float(row.get('protein', 0)), 2),
                'fat': round(parse_float(row.get('fat', 0)), 2),
                'fiber': round(parse_float(row.get('fiber', 0)), 2),
                'sugar': 0.0,   # not available in IFCT dataset
                'sodium': 0.0,  # not available in IFCT dataset
            }

            doc_ref = db.collection('foods').document()
            batch.set(doc_ref, food_data)
            batch_count += 1
            total_uploaded += 1

            # Commit every 500 (Firestore batch limit)
            if batch_count == 500:
                batch.commit()
                print(f"Uploaded {total_uploaded} items...")
                batch = db.batch()
                batch_count = 0

    if batch_count > 0:
        batch.commit()
        print(f"Uploaded {total_uploaded} items...")

    print(f"\nSuccess! {total_uploaded} food items uploaded to the 'foods' collection.")

if __name__ == '__main__':
    main()
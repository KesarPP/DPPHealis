import os
import csv
import sys
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# Path to the service account key
SERVICE_ACCOUNT_KEY = 'serviceAccountKey.json'
CSV_FILE_PATH = 'assets/data/Indian_Food_Nutrition_Processed.csv'

def initialize_firebase():
    if not os.path.exists(SERVICE_ACCOUNT_KEY):
        print(f"Error: {SERVICE_ACCOUNT_KEY} not found.")
        print("Please download your Firebase Service Account Key from the Firebase Console")
        print("(Project Settings -> Service Accounts -> Generate new private key)")
        print(f"and place it in the root directory as '{SERVICE_ACCOUNT_KEY}'.")
        sys.exit(1)
        
    print("Initializing Firebase Admin SDK...")
    cred = credentials.Certificate(SERVICE_ACCOUNT_KEY)
    firebase_admin.initialize_app(cred)
    return firestore.client()

def seed_foods(db):
    if not os.path.exists(CSV_FILE_PATH):
        print(f"Warning: CSV file {CSV_FILE_PATH} not found. Skipping foods seeding.")
        return

    print(f"Reading foods from {CSV_FILE_PATH}...")
    batch = db.batch()
    batch_size = 0
    total_foods = 0

    with open(CSV_FILE_PATH, mode='r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                name = row.get('Dish Name', '').strip()
                if not name:
                    continue

                calories = float(row.get('Calories (kcal)') or 0)
                carbs = float(row.get('Carbohydrates (g)') or 0)
                protein = float(row.get('Protein (g)') or 0)
                fat = float(row.get('Fats (g)') or 0)
                fiber = float(row.get('Fibre (g)') or 0)
                sugar = float(row.get('Free Sugar (g)') or 0)
                sodium = float(row.get('Sodium (mg)') or 0)

                doc_ref = db.collection('foods').document()
                food_data = {
                    'name': name,
                    'nameSearch': name.lower(),
                    'calories': calories,
                    'carbs': carbs,
                    'protein': protein,
                    'fat': fat,
                    'fiber': fiber,
                    'sugar': sugar,
                    'sodium': sodium,
                    'scanCount': 0
                }
                
                batch.set(doc_ref, food_data)
                batch_size += 1
                total_foods += 1

                # Firestore batches have a limit of 500 operations
                if batch_size >= 490:
                    batch.commit()
                    print(f"Committed batch of 490 foods. Total so far: {total_foods}")
                    batch = db.batch()
                    batch_size = 0
            
            except Exception as e:
                print(f"Error processing row: {row}")
                print(f"Exception: {e}")

    # Commit any remaining
    if batch_size > 0:
        batch.commit()
        print(f"Committed final batch. Total foods: {total_foods}")
        
    print(f"Successfully seeded {total_foods} foods.")

def seed_default_coaches(db):
    print("Seeding default coaches...")
    coaches = [
        {
            'uid': 'coach_sarah_1', # You can use any fixed UID for dummy coaches
            'email': 'sarah.mitchell@healis.org',
            'name': 'Sarah Mitchell'
        },
        {
            'uid': 'coach_default_2',
            'email': 'coach@healis.org',
            'name': 'Dr. Health Coach'
        }
    ]

    for c in coaches:
        doc_ref = db.collection('coaches').document(c['uid'])
        coach_data = {
            'uid': c['uid'],
            'name': c['name'],
            'email': c['email'],
            'title': 'Senior Health Coach & Nutritionist',
            'about': 'Dr. Mitchell specializes in preventative health with a focus on chronic disease management. With over 15 years of clinical experience, she empowers her patients to master their metabolic health through evidence-based nutritional strategies and behavioral therapy.',
            'specializations': ['Nutrition', 'Behavioral Health', 'Metabolic Fitness', 'Diabetes Prevention'],
            'credentials': [
                {
                    'title': 'Board Certified Health Coach',
                    'subtitle': 'American Council on Exercise (ACE)',
                    'icon': 'verified',
                },
                {
                    'title': 'MS in Clinical Nutrition',
                    'subtitle': 'Johns Hopkins University',
                    'icon': 'school',
                },
                {
                    'title': 'Certified Diabetes Care Specialist',
                    'subtitle': 'ADCES Certification Board',
                    'icon': 'premium',
                }
            ],
            'localImagePath': None
        }
        doc_ref.set(coach_data)
        print(f"Created coach profile for {c['email']}")

if __name__ == "__main__":
    db = initialize_firebase()
    print("\n--- Starting Database Seeding ---")
    seed_default_coaches(db)
    seed_foods(db)
    print("--- Database Seeding Complete ---")

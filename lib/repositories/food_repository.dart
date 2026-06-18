import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item.dart';
import '../models/food_log.dart';

class FoodRepository {
  FirebaseFirestore? get _db {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (_) {}
    return null;
  }

  Future<List<FoodItem>> searchFoods(String query) async {
    final db = _db;
    if (db == null || query.isEmpty) return [];
    final lowercaseQuery = query.toLowerCase();
    
    // Prefix query: >= lowercaseQuery and < lowercaseQuery + 'z'
    final snapshot = await db.collection('foods')
      .where('nameSearch', isGreaterThanOrEqualTo: lowercaseQuery)
      .where('nameSearch', isLessThan: lowercaseQuery + 'z')
      .limit(20)
      .get();
      
    return snapshot.docs.map((doc) => FoodItem.fromFirestore(doc.data(), doc.id)).toList();
  }

  Stream<DailyFoodLog?> getDailyLog(String userId, String date) {
    final db = _db;
    if (db == null) return Stream.value(null);
    return db.collection('logs').doc(userId).collection('entries').doc(date).snapshots().map((doc) {
      if (!doc.exists) return null;
      return DailyFoodLog.fromFirestore(doc.data()!, doc.id);
    });
  }

  Future<void> addFoodToLog(String userId, String date, LoggedFood newEntry) async {
    final db = _db;
    if (db == null) return;
    final docRef = db.collection('logs').doc(userId).collection('entries').doc(date);
    
    return db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      
      if (!snapshot.exists) {
        // Create new log document
        transaction.set(docRef, {
          'entries': [newEntry.toMap()],
          'totalCalories': newEntry.food.calories * newEntry.quantity,
          'totalCarbs': newEntry.food.carbs * newEntry.quantity,
          'totalProtein': newEntry.food.protein * newEntry.quantity,
          'totalFat': newEntry.food.fat * newEntry.quantity,
          'totalFiber': newEntry.food.fiber * newEntry.quantity,
        });
      } else {
        // Update existing log document
        final log = DailyFoodLog.fromFirestore(snapshot.data()!, snapshot.id);
        
        // Check for duplicate
        bool found = false;
        for (var i = 0; i < log.entries.length; i++) {
          if (log.entries[i].food.id == newEntry.food.id && log.entries[i].mealType == newEntry.mealType) {
            final existing = log.entries[i];
            log.entries[i] = LoggedFood(
              food: existing.food, 
              mealType: existing.mealType, 
              quantity: existing.quantity + newEntry.quantity
            );
            found = true;
            break;
          }
        }
        
        if (!found) {
          log.entries.add(newEntry);
        }
        
        transaction.update(docRef, {
          'entries': log.entries.map((e) => e.toMap()).toList(),
          'totalCalories': log.totalCalories + (newEntry.food.calories * newEntry.quantity),
          'totalCarbs': log.totalCarbs + (newEntry.food.carbs * newEntry.quantity),
          'totalProtein': log.totalProtein + (newEntry.food.protein * newEntry.quantity),
          'totalFat': log.totalFat + (newEntry.food.fat * newEntry.quantity),
          'totalFiber': log.totalFiber + (newEntry.food.fiber * newEntry.quantity),
        });
      }
    });
  }
}

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

  List<FoodItem>? _cachedFoods;

  Future<List<FoodItem>> _getAllFoods() async {
    final db = _db;
    if (db == null) return [];
    if (_cachedFoods != null) return _cachedFoods!;

    final snapshot = await db.collection('foods').get();
    _cachedFoods = snapshot.docs.map((doc) => FoodItem.fromFirestore(doc.data(), doc.id)).toList();
    return _cachedFoods!;
  }

  Future<List<FoodItem>> searchFoods(String query) async {
    if (query.isEmpty) return [];
    final lowercaseQuery = query.toLowerCase().trim();
    final searchWords = lowercaseQuery.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    
    final allFoods = await _getAllFoods();
      
    final results = allFoods.where((food) {
      final name = food.name.toLowerCase();
      // Check if EVERY search word is found ANYWHERE in the food name
      return searchWords.every((word) => name.contains(word));
    }).take(20).toList();

    return results;
  }

  Stream<DailyFoodLog?> getDailyLog(String userId, String date) {
    final db = _db;
    if (db == null) return Stream.value(null);
    return db.collection('logs').doc(userId).collection('food_entries').doc(date).snapshots().map((doc) {
      if (!doc.exists) return null;
      return DailyFoodLog.fromFirestore(doc.data()!, doc.id);
    });
  }

  Stream<List<DailyFoodLog>> getAllLogs(String userId) {
    final db = _db;
    if (db == null) return Stream.value([]);
    return db.collection('logs').doc(userId).collection('food_entries').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => DailyFoodLog.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  Future<void> addFoodToLog(String userId, String date, LoggedFood newEntry) async {
    final db = _db;
    if (db == null) return;
    final docRef = db.collection('logs').doc(userId).collection('food_entries').doc(date);
    
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

  Future<void> removeFoodFromLog(String userId, String date, LoggedFood itemToRemove) async {
    final db = _db;
    if (db == null) return;
    final docRef = db.collection('logs').doc(userId).collection('food_entries').doc(date);
    
    return db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final log = DailyFoodLog.fromFirestore(snapshot.data()!, snapshot.id);
      
      bool found = false;
      for (var i = 0; i < log.entries.length; i++) {
        if (log.entries[i].food.id == itemToRemove.food.id && log.entries[i].mealType == itemToRemove.mealType) {
          final existing = log.entries[i];
          if (existing.quantity > 1) {
            log.entries[i] = LoggedFood(
              food: existing.food, 
              mealType: existing.mealType, 
              quantity: existing.quantity - 1
            );
          } else {
            log.entries.removeAt(i);
          }
          found = true;
          break;
        }
      }

      if (found) {
        transaction.update(docRef, {
          'entries': log.entries.map((e) => e.toMap()).toList(),
          'totalCalories': (log.totalCalories - itemToRemove.food.calories).clamp(0.0, double.infinity),
          'totalCarbs': (log.totalCarbs - itemToRemove.food.carbs).clamp(0.0, double.infinity),
          'totalProtein': (log.totalProtein - itemToRemove.food.protein).clamp(0.0, double.infinity),
          'totalFat': (log.totalFat - itemToRemove.food.fat).clamp(0.0, double.infinity),
          'totalFiber': (log.totalFiber - itemToRemove.food.fiber).clamp(0.0, double.infinity),
        });
      }
    });
  }

  Future<FoodItem> saveScannedProduct(FoodItem item) async {
    final db = _db;
    if (db == null) return item;

    final brandStr = item.brand?.toLowerCase().replaceAll(' ', '_') ?? 'unknown';
    final nameStr = item.name.toLowerCase().replaceAll(' ', '_');
    final docId = '${brandStr}_$nameStr';

    final docRef = db.collection('foods').doc(docId);
    
    return db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.exists) {
        final currentCount = snapshot.data()?['scanCount'] as int? ?? 0;
        transaction.update(docRef, {'scanCount': currentCount + 1});
        return FoodItem(
          id: docId,
          name: item.name,
          calories: item.calories,
          carbs: item.carbs,
          protein: item.protein,
          fat: item.fat,
          fiber: item.fiber,
          brand: item.brand,
          sugar: item.sugar,
          sodium: item.sodium,
          servingSize: item.servingSize,
          scanCount: currentCount + 1,
        );
      } else {
        final mapData = item.toMap();
        mapData['scanCount'] = 1;
        transaction.set(docRef, mapData);
        return FoodItem(
          id: docId,
          name: item.name,
          calories: item.calories,
          carbs: item.carbs,
          protein: item.protein,
          fat: item.fat,
          fiber: item.fiber,
          brand: item.brand,
          sugar: item.sugar,
          sodium: item.sodium,
          servingSize: item.servingSize,
          scanCount: 1,
        );
      }
    });
  }
}

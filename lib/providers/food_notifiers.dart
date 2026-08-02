import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_item.dart';
import '../models/food_log.dart';
import '../repositories/food_repository.dart';
import '../services/notification_service.dart';
import '../data/app_state.dart';

class FoodSearchNotifier extends ChangeNotifier {
  final FoodRepository _repository = FoodRepository();
  List<FoodItem> _results = [];
  bool _isLoading = false;
  Timer? _debounce;

  List<FoodItem> get results => _results;
  bool get isLoading => _isLoading;

  void search(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query.trim().isEmpty) {
        _results = [];
        notifyListeners();
        return;
      }
      _isLoading = true;
      notifyListeners();

      _results = await _repository.searchFoods(query.trim());
      
      _isLoading = false;
      notifyListeners();
    });
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

class FoodDiaryNotifier extends ChangeNotifier {
  final FoodRepository _repository = FoodRepository();
  DailyFoodLog? _dailyLog;
  StreamSubscription? _subscription;
  StreamSubscription? _allLogsSubscription;
  Map<String, bool> _completedDays = {};
  Map<String, bool> _nutritionNinjaDays = {};
  List<DailyFoodLog> _allLogsList = [];
  String _selectedDate = DateTime.now().toIso8601String().split('T')[0];

  FoodDiaryNotifier() {
    loadLogForDate(_selectedDate);
    loadAllLogs();
  }

  DailyFoodLog? get dailyLog => _dailyLog;
  Map<String, bool> get completedDays => _completedDays;
  Map<String, bool> get nutritionNinjaDays => _nutritionNinjaDays;
  List<DailyFoodLog> get allLogsList => _allLogsList;
  String get selectedDate => _selectedDate;

  double get todayCalories {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    if (_selectedDate == todayStr && _dailyLog != null) {
      return _dailyLog!.totalCalories;
    }
    final todayLog = _allLogsList.where((l) => l.date == todayStr).firstOrNull;
    if (todayLog != null) {
      return todayLog.totalCalories;
    }
    return 0.0;
  }

  double get calorieGoal {
    return AppState.calculateDailyCalorieGoal();
  }

  void setSelectedDate(String date) {
    _selectedDate = date;
    loadLogForDate(date);
    notifyListeners();
  }

  void loadLogForDate(String date) {
    _subscription?.cancel();
    if (Firebase.apps.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _subscription = _repository.getDailyLog(user.uid, date).listen((log) {
      _dailyLog = log;
      
      if (date == DateTime.now().toIso8601String().split('T')[0]) {
        NotificationService().scheduleMealReminders(log);
      }
      
      notifyListeners();
    });
  }

  void loadAllLogs() {
    _allLogsSubscription?.cancel();
    if (Firebase.apps.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _allLogsSubscription = _repository.getAllLogs(user.uid).listen((logs) {
      _allLogsList = logs;
      final newCompletedDays = <String, bool>{};
      final newNutritionNinjaDays = <String, bool>{};
      final goal = calorieGoal;
      
      for (final log in logs) {
        final types = log.entries.map((e) => e.mealType).toSet();
        if (types.length >= 5) {
          newCompletedDays[log.date] = true;
        } else if (types.isNotEmpty) {
          newCompletedDays[log.date] = false;
        }
        
        // Count as Nutrition Ninja day if calories are > 0 and within 15% of goal
        if (log.totalCalories > 0 && log.totalCalories <= goal * 1.15 && log.totalCalories >= goal * 0.7) {
          newNutritionNinjaDays[log.date] = true;
        } else {
          newNutritionNinjaDays[log.date] = false;
        }
      }
      _completedDays = newCompletedDays;
      _nutritionNinjaDays = newNutritionNinjaDays;
      notifyListeners();
    });
  }

  Future<void> logFood(FoodItem food, String mealType, String date, {double quantity = 1.0, double selectedGrams = 100.0, double defaultGrams = 100.0}) async {
    if (Firebase.apps.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final entry = LoggedFood(food: food, mealType: mealType, quantity: quantity, selectedGrams: selectedGrams, defaultGrams: defaultGrams);
    await _repository.addFoodToLog(user.uid, date, entry);
  }

  Future<void> removeFood(LoggedFood itemToRemove, String date) async {
    if (Firebase.apps.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    await _repository.removeFoodFromLog(user.uid, date, itemToRemove);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _allLogsSubscription?.cancel();
    super.dispose();
  }
}

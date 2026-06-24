import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_item.dart';
import '../models/food_log.dart';
import '../repositories/food_repository.dart';
import '../services/notification_service.dart';

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
  String _selectedDate = DateTime.now().toIso8601String().split('T')[0];

  DailyFoodLog? get dailyLog => _dailyLog;
  Map<String, bool> get completedDays => _completedDays;
  String get selectedDate => _selectedDate;

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
      final newCompletedDays = <String, bool>{};
      for (final log in logs) {
        final types = log.entries.map((e) => e.mealType).toSet();
        if (types.length >= 5) {
          newCompletedDays[log.date] = true;
        } else if (types.isNotEmpty) {
          newCompletedDays[log.date] = false;
        }
      }
      _completedDays = newCompletedDays;
      notifyListeners();
    });
  }

  Future<void> logFood(FoodItem food, String mealType, String date, {int quantity = 1}) async {
    if (Firebase.apps.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final entry = LoggedFood(food: food, mealType: mealType, quantity: quantity);
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

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'health_service.dart';

class HealthConnectService implements HealthService {
  final Health _health = Health();
  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.TOTAL_CALORIES_BURNED,
  ];

  @override
  Future<bool> isHealthConnectAvailable() async {
    try {
      return await _health.isHealthConnectAvailable().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('isHealthConnectAvailable error: $e');
      return false;
    }
  }

  @override
  Future<int> getTodaySteps() async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);
    debugPrint('getTodaySteps() CALLED');
    try {
      final steps = await _health.getTotalStepsInInterval(startDate, now).timeout(const Duration(seconds: 3));
      debugPrint('RAW STEPS: $steps');
      return steps ?? 0;
    } catch (e) {
      debugPrint('getTodaySteps error: $e');
      return 0;
    }
  }

  @override
  Future<int> getWeeklySteps() async {
    final now = DateTime.now();
    final daysToSubtract = now.weekday - 1;
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract));
    debugPrint('getWeeklySteps() CALLED (from $startOfWeek)');
    try {
      final steps = await _health.getTotalStepsInInterval(startOfWeek, now).timeout(const Duration(seconds: 3));
      debugPrint('RAW WEEKLY STEPS: $steps');
      return steps ?? 0;
    } catch (e) {
      debugPrint('getWeeklySteps error: $e');
      return 0;
    }
  }

  @override
  Future<bool> hasPermissions() async {
    try {
      return await _health.hasPermissions(_types).timeout(const Duration(seconds: 3)) ?? false;
    } catch (e) {
      debugPrint('hasPermissions error: $e');
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      return await _health.requestAuthorization(_types).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('requestPermissions error: $e');
      return false;
    }
  }

  @override
  Future<double> getTodayDistance() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    try {
      final data = await _health.getHealthDataFromTypes(
        startTime: startOfDay,
        endTime: now,
        types: [HealthDataType.DISTANCE_DELTA],
      ).timeout(const Duration(seconds: 3));

      if (data.isNotEmpty) {
        double totalDistance = 0;
        for (var point in data) {
          totalDistance += double.tryParse(point.value.toString()) ?? 0.0;
        }
        if (totalDistance > 0) return totalDistance / 1000.0;
      }
    } catch (e) {
      debugPrint('Native distance fetch error: $e');
    }

    final steps = await getTodaySteps();
    return (steps * 0.762) / 1000.0;
  }

  @override
  Future<double> getTodayCalories() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    try {
      final rawData = await _health.getHealthDataFromTypes(
        startTime: startOfDay,
        endTime: now,
        types: [
          HealthDataType.ACTIVE_ENERGY_BURNED,
          HealthDataType.TOTAL_CALORIES_BURNED,
        ],
      ).timeout(const Duration(seconds: 3));
      final data = _health.removeDuplicates(rawData);

      if (data.isNotEmpty) {
        double activeCals = 0;
        double totalCals = 0;
        for (var point in data) {
          final val = double.tryParse(point.value.toString()) ?? 0.0;
          if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
            activeCals += val;
          } else if (point.type == HealthDataType.TOTAL_CALORIES_BURNED) {
            totalCals += val;
          }
        }
        if (activeCals > 0) return activeCals;
        if (totalCals > 0) return totalCals;
        return 0.0;
      }
    } catch (e) {
      debugPrint('Native calories fetch error: $e');
    }

    return 0.0;
  }

  @override
  Future<int> getTodayActiveMinutes() async {
    return 0;
  }
}
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
    return await _health.isHealthConnectAvailable();
  }
  @override
  Future<int> getTodaySteps() async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);

    debugPrint(
      'getTodaySteps() CALLED',
    );
    final steps = await _health.getTotalStepsInInterval(
      startDate,
      now,

    );
    debugPrint(
      'RAW STEPS: $steps',
    );
    return steps ?? 0;
  }

  @override
  Future<int> getWeeklySteps() async {
    final now = DateTime.now();
    // Assuming the week starts on Monday (weekday 1)
    final daysToSubtract = now.weekday - 1;
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract));

    debugPrint('getWeeklySteps() CALLED (from $startOfWeek)');
    final steps = await _health.getTotalStepsInInterval(
      startOfWeek,
      now,
    );
    debugPrint('RAW WEEKLY STEPS: $steps');
    return steps ?? 0;
  }
  @override
  Future<bool> hasPermissions()async {
    return await _health.hasPermissions(_types) ?? false;
  }


  @override
  Future<bool> requestPermissions() async {
    return await _health.requestAuthorization(_types);
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
      );

      if (data.isNotEmpty) {
        double totalDistance = 0;
        for (var point in data) {
          totalDistance += double.tryParse(point.value.toString()) ?? 0.0;
        }
        if (totalDistance > 0) return totalDistance / 1000.0; // Convert meters to km
      }
    } catch (e) {
      print('Native distance fetch error: $e');
    }

    // Fallback: estimate from steps (assuming 0.762 meters per step)
    final steps = await getTodaySteps();
    return (steps * 0.762) / 1000.0; // Return km
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
      );
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
        final steps = await getTodaySteps();
        final estCals = steps * 0.04;
        if (activeCals > 0) return max(activeCals, estCals);
        if (estCals > 0) return estCals;
        if (totalCals > 0) return totalCals;
      }
    } catch (e) {
      print('Native calories fetch error: $e');
    }

    // Fallback: estimate from steps (~0.04 calories per step)
    final steps = await getTodaySteps();
    return steps * 0.04;
  }

  @override
  Future<int> getTodayActiveMinutes() async {
    // Health Connect throws unsupported error for EXERCISE_TIME / Active Minutes directly
    // Fallback: estimate 100 steps = 1 active minute (standard pedometer conversion)
    final steps = await getTodaySteps();
    return (steps / 100).floor();
  }
}
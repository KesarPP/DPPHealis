import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'health_service.dart';
class HealthConnectService implements HealthService {
  final Health _health = Health();
  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.ACTIVE_ENERGY_BURNED,
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
      final data = await _health.getHealthIntervalDataFromTypes(
        startDate: startOfDay,
        endDate: now,
        types: [HealthDataType.DISTANCE_DELTA],
        interval: 1440,
      );

      if (data.isNotEmpty) {
        double totalDistance = 0;
        for (var point in data) {
          totalDistance += double.tryParse(point.value.toString()) ?? 0.0;
        }
        if (totalDistance > 0) return totalDistance;
      }
    } catch (e) {
      print('Native distance fetch error: $e');
    }

    // Fallback: estimate from steps (assuming 0.762 meters per step)
    final steps = await getTodaySteps();
    return steps * 0.762;
  }

  @override
  Future<double> getTodayCalories() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      final data = await _health.getHealthIntervalDataFromTypes(
        startDate: startOfDay,
        endDate: now,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        interval: 1440,
      );

      if (data.isNotEmpty) {
        double totalCalories = 0;
        for (var point in data) {
          totalCalories += double.tryParse(point.value.toString()) ?? 0.0;
        }
        if (totalCalories > 0) return totalCalories;
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
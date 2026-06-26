import 'dart:math';
import 'package:health/health.dart';
import '../models/ndpp_constants.dart';

class HealthSyncService {
  final Health _health = Health();

  static const List<HealthDataType> _syncTypes = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
  ];

  Future<bool> requestPermissions() async {
    try {
      return await _health.requestAuthorization(_syncTypes).timeout(const Duration(seconds: 5));
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasPermissions() async {
    try {
      return await _health.hasPermissions(_syncTypes).timeout(const Duration(seconds: 3)) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<List<DailyAggregate>> getLast7DaysStats({DateTime? endDate}) async {
    final end = endDate ?? DateTime.now();
    final startDate = DateTime(end.year, end.month, end.day).subtract(const Duration(days: 6));
    return getStatsForInterval(startTime: startDate, endTime: end);
  }

  /// Fetches DailyAggregate list for the interval from [startTime] to [endTime] (day by day).
  Future<List<DailyAggregate>> getStatsForInterval({required DateTime startTime, required DateTime endTime}) async {
    final startDate = DateTime(startTime.year, startTime.month, startTime.day);
    final endDay = DateTime(endTime.year, endTime.month, endTime.day);
    final int daysCount = endDay.difference(startDate).inDays + 1;
    final startOfDayEnd = DateTime(endDay.year, endDay.month, endDay.day, 23, 59, 59);

    // Initialize empty aggregates
    Map<String, DailyAggregate> dailyMap = {};
    for (int i = 0; i < daysCount; i++) {
      final d = startDate.add(Duration(days: i));
      final dateKey = _dateKey(d);
      dailyMap[dateKey] = DailyAggregate.empty(d);
    }

    try {
      List<HealthDataPoint> data = [];
      for (var type in _syncTypes) {
        try {
          final pts = await _health.getHealthDataFromTypes(
            startTime: startDate,
            endTime: startOfDayEnd,
            types: [type],
          ).timeout(const Duration(seconds: 3));
          data.addAll(_health.removeDuplicates(pts));
        } catch (_) {}
      }

      Map<String, int> dailySteps = {};
      Map<String, double> dailyDistance = {};
      Map<String, double> dailyTotalCalories = {};
      Map<String, double> dailyActiveCalories = {};
      Map<String, List<ActivitySession>> dailyCoreSessions = {};
      Map<String, List<ActivitySession>> dailyLifestyleSessions = {};

      for (var point in data) {
        final dKey = _dateKey(point.dateFrom);
        if (!dailyMap.containsKey(dKey)) continue;

        double extractValue(dynamic val) {
          try {
            return (val as dynamic).numericValue.toDouble();
          } catch (e) {
            return double.tryParse(val.toString()) ?? 0.0;
          }
        }

        if (point.type == HealthDataType.STEPS) {
          final steps = extractValue(point.value).toInt();
          dailySteps[dKey] = (dailySteps[dKey] ?? 0) + steps;
        } else if (point.type == HealthDataType.DISTANCE_DELTA) {
          final dist = extractValue(point.value);
          dailyDistance[dKey] = (dailyDistance[dKey] ?? 0.0) + dist;
        } else if (point.type == HealthDataType.TOTAL_CALORIES_BURNED) {
          final cals = extractValue(point.value);
          dailyTotalCalories[dKey] = (dailyTotalCalories[dKey] ?? 0.0) + cals;
        } else if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
          final cals = extractValue(point.value);
          dailyActiveCalories[dKey] = (dailyActiveCalories[dKey] ?? 0.0) + cals;
        } else if (point.type == HealthDataType.WORKOUT) {
          final session = _parseWorkout(point);
          if (session != null) {
            final sKey = _dateKey(session.startTime);
            if (dailyMap.containsKey(sKey)) {
              if (session.category == ActivityCategory.core) {
                dailyCoreSessions.putIfAbsent(sKey, () => []).add(session);
              } else {
                dailyLifestyleSessions.putIfAbsent(sKey, () => []).add(session);
              }
            }
          }
        }
      }

      for (int i = 0; i < daysCount; i++) {
        final d = startDate.add(Duration(days: i));
        final dKey = _dateKey(d);
        final dayStart = DateTime(d.year, d.month, d.day, 0, 0, 0);
        final dayEnd = DateTime(d.year, d.month, d.day, 23, 59, 59);

        int? intervalSteps;
        try {
          intervalSteps = await _health.getTotalStepsInInterval(dayStart, dayEnd);
        } catch (_) {}
        if (intervalSteps != null && intervalSteps > 0) {
          dailySteps[dKey] = max(dailySteps[dKey] ?? 0, intervalSteps);
        }
      }

      List<DailyAggregate> results = [];
      for (int i = 0; i < daysCount; i++) {
        final d = startDate.add(Duration(days: i));
        final dKey = _dateKey(d);

        final steps = dailySteps[dKey] ?? 0;
        double distance = (dailyDistance[dKey] ?? 0.0) / 1000.0;
        if (distance <= 0.0 && steps > 0) {
          distance = steps * 0.00076;
        }
        final activeCals = dailyActiveCalories[dKey] ?? 0.0;
        final coreSessions = dailyCoreSessions[dKey] ?? [];
        final lifestyleSessions = dailyLifestyleSessions[dKey] ?? [];

        int totalActiveMins = 0;
        int qualifyingMins = 0;

        if (coreSessions.isEmpty && lifestyleSessions.isEmpty) {
          totalActiveMins = steps > 0 ? max(1, (steps / 100).round()) : 0;
          if (totalActiveMins >= NdppConstants.minQualifyingSessionMinutes) {
            qualifyingMins = totalActiveMins;
          }
        } else {
          for (var s in coreSessions) {
            totalActiveMins += s.durationMinutes;
            if (s.isQualifying) qualifyingMins += s.durationMinutes;
          }
          for (var s in lifestyleSessions) {
            totalActiveMins += s.durationMinutes;
            if (s.isQualifying) qualifyingMins += s.durationMinutes;
          }
        }

        // Accurate active workout calories:
        // Prioritize ACTIVE_ENERGY_BURNED if recorded.
        // Otherwise accurately estimate from steps (~0.04 kcal/step) or active minutes (~5.5 kcal/min).
        // Never fall back to raw totalCals because it includes ~1800 kcal resting BMR!
        double activeEst = steps * 0.04;
        if (totalActiveMins > 0) {
          activeEst = max(activeEst, totalActiveMins * 5.5);
        }
        final calories = activeCals > 0 ? max(activeCals, activeEst) : activeEst;

        final agg = DailyAggregate(
          date: d,
          totalSteps: steps,
          totalDistance: distance,
          totalCalories: calories,
          totalActiveMinutes: totalActiveMins,
          qualifyingActiveMinutes: qualifyingMins,
          isActiveDay: qualifyingMins >= NdppConstants.minQualifyingSessionMinutes,
          coreSessions: coreSessions,
          lifestyleSessions: lifestyleSessions,
        );
        results.add(agg);
      }

      return results;
    } catch (e) {
      print('HealthSyncService fetch error: $e');
      return dailyMap.values.toList();
    }
  }

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  ActivitySession? _parseWorkout(HealthDataPoint point) {
    if (point.value is! WorkoutHealthValue) return null;
    final workout = point.value as WorkoutHealthValue;
    
    final duration = point.dateTo.difference(point.dateFrom).inMinutes;
    final isQualifying = duration >= NdppConstants.minQualifyingSessionMinutes;
    
    final activityType = _mapWorkoutType(workout.workoutActivityType);
    final category = _getCategory(activityType);

    return ActivitySession(
      id: point.uuid,
      userId: 'local',
      source: SessionSource.healthConnect,
      activityType: activityType,
      category: category,
      startTime: point.dateFrom,
      endTime: point.dateTo,
      durationMinutes: duration,
      caloriesBurned: workout.totalEnergyBurned?.toDouble() ?? 0.0,
      distanceMeters: workout.totalDistance?.toDouble() ?? 0.0,
      isQualifying: isQualifying,
      date: DateTime(point.dateFrom.year, point.dateFrom.month, point.dateFrom.day),
    );
  }

  ActivityType _mapWorkoutType(HealthWorkoutActivityType type) {
    switch (type) {
      case HealthWorkoutActivityType.WALKING:
        return ActivityType.walking;
      case HealthWorkoutActivityType.SWIMMING:
        return ActivityType.swimming;
      case HealthWorkoutActivityType.STAIR_CLIMBING:
        return ActivityType.stairClimbing;
      case HealthWorkoutActivityType.YOGA:
      case HealthWorkoutActivityType.PILATES:
      case HealthWorkoutActivityType.FLEXIBILITY:
      case HealthWorkoutActivityType.GYMNASTICS:
        return ActivityType.stretching;
      default:
        return ActivityType.other;
    }
  }

  ActivityCategory _getCategory(ActivityType type) {
    switch (type) {
      case ActivityType.walking:
      case ActivityType.briskWalking:
      case ActivityType.swimming:
      case ActivityType.dancing:
      case ActivityType.stairClimbing:
      case ActivityType.stretching:
        return ActivityCategory.core;
      case ActivityType.gardening:
      case ActivityType.household:
      case ActivityType.other:
        return ActivityCategory.lifestyle;
    }
  }
}

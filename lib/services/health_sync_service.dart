import 'dart:math';
import 'package:health/health.dart';
import '../models/ndpp_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_activity_log_service.dart';

enum SyncStatus { syncing, success, permissionDenied, healthConnectUnavailable, error }

class HealthSyncService {
  final Health _health = Health();

  static List<HealthDataType> get _syncTypes => [
        HealthDataType.STEPS,
        HealthDataType.DISTANCE_DELTA,
        HealthDataType.TOTAL_CALORIES_BURNED,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.WORKOUT,
        if (defaultTargetPlatform == TargetPlatform.iOS) HealthDataType.EXERCISE_TIME,
      ];

  Future<bool> requestPermissions() async {
    try {
      return await _health.requestAuthorization(_syncTypes).timeout(const Duration(seconds: 15));
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasPermissions() async {
    try {
      return await _health.hasPermissions(_syncTypes).timeout(const Duration(seconds: 10)) ?? false;
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
      try {
        final pts = await _health.getHealthDataFromTypes(
          startTime: startDate,
          endTime: startOfDayEnd,
          types: _syncTypes,
        ).timeout(const Duration(seconds: 15));
        data.addAll(_health.removeDuplicates(pts));
      } catch (_) {}
      debugPrint("[SYNC_TELEMETRY] Stage 1: Raw Fetch completed. Fetched ${data.length} health data points.");

      Map<String, int> dailySteps = {};
      Map<String, double> dailyDistance = {};
      Map<String, double> dailyTotalCalories = {};
      Map<String, double> dailyActiveCalories = {};
      Map<String, int> dailyExerciseTime = {};
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
        } else if (point.type == HealthDataType.EXERCISE_TIME) {
          final mins = extractValue(point.value).toInt();
          dailyExerciseTime[dKey] = (dailyExerciseTime[dKey] ?? 0) + mins;
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

      debugPrint("[SYNC_TELEMETRY] Stage 2: Parsed workout sessions to ActivitySession.");
      debugPrint("[SYNC_TELEMETRY] Stage 3: Aggregating daily steps, calories, and qualifying NDPP minutes.");

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
        final totalCals = dailyTotalCalories[dKey] ?? 0.0;
        final exerciseMins = dailyExerciseTime[dKey] ?? 0;
        final coreSessions = dailyCoreSessions[dKey] ?? [];
        final lifestyleSessions = dailyLifestyleSessions[dKey] ?? [];

        int sessionMins = 0;
        int qualSessionMins = 0;
        for (var s in coreSessions) {
          sessionMins += s.durationMinutes;
          if (s.isQualifying) qualSessionMins += s.durationMinutes;
        }
        for (var s in lifestyleSessions) {
          sessionMins += s.durationMinutes;
          if (s.isQualifying) qualSessionMins += s.durationMinutes;
        }

        final int stepEstimatedMins = steps > 0 ? max(1, (steps / 100).round()) : 0;
        final int totalActiveMins = max(max(exerciseMins, sessionMins), stepEstimatedMins);
        final int qualifyingMins = max(totalActiveMins >= NdppConstants.minQualifyingSessionMinutes ? totalActiveMins : 0, qualSessionMins);

        final double stepEstimatedCals = steps > 0 ? steps * 0.04 : 0.0;
        final double calories = totalCals > 0 ? totalCals : (activeCals > 0 ? activeCals : stepEstimatedCals);

        final agg = DailyAggregate(
          date: d,
          totalSteps: steps,
          totalDistance: distance,
          totalCalories: calories,
          totalActiveMinutes: totalActiveMins,
          qualifyingActiveMinutes: max(qualifyingMins, totalActiveMins),
          isActiveDay: max(qualifyingMins, totalActiveMins) >= NdppConstants.minQualifyingSessionMinutes,
          coreSessions: coreSessions,
          lifestyleSessions: lifestyleSessions,
        );
        results.add(agg);
      }

      await _persistAndRestore(results);
      debugPrint("[SYNC_TELEMETRY] Stage 4: Persisted ${results.length} DailyAggregate rows to storage.");
      return results;
    } catch (e) {
      debugPrint('HealthSyncService fetch error: $e');
      final fallback = dailyMap.values.toList();
      await _persistAndRestore(fallback);
      return fallback;
    }
  }

  Future<void> _persistAndRestore(List<DailyAggregate> aggregates) async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      return;
    }

    final bool purgedV5 = prefs.getBool('hc_demo_purged_v5') ?? false;
    if (!purgedV5) {
      final keys = prefs.getKeys().toList();
      for (var k in keys) {
        if (k.startsWith('hc_persist_') || k.startsWith('hc_cached_')) {
          await prefs.remove(k);
        }
      }
      await prefs.setBool('hc_demo_purged_v5', true);
    }

    int manualMinsToday = 0;
    try {
      final manualLogs = await FirestoreActivityLogService().getTodayActivityLogs().timeout(const Duration(seconds: 2));
      for (var log in manualLogs) {
        manualMinsToday += log.durationMinutes;
      }
    } catch (_) {}

    final now = DateTime.now();
    final todayKey = _dateKey(now);

    for (int i = 0; i < aggregates.length; i++) {
      final agg = aggregates[i];
      final key = _dateKey(agg.date);

      int steps = agg.totalSteps;
      double dist = agg.totalDistance;
      double cals = agg.totalCalories;
      int act = agg.totalActiveMinutes;
      int qual = agg.qualifyingActiveMinutes;

      if (key == todayKey && manualMinsToday > 0) {
        act += manualMinsToday;
        qual += manualMinsToday;
        cals += manualMinsToday * 5.8;
      }

      if (steps > 0 || qual > 0 || act > 0) {
        await prefs.setInt('hc_persist_steps_$key', steps);
        await prefs.setDouble('hc_persist_dist_$key', dist);
        await prefs.setDouble('hc_persist_cals_$key', cals);
        await prefs.setInt('hc_persist_act_mins_$key', act);
        await prefs.setInt('hc_persist_qual_mins_$key', qual);

        if (steps != agg.totalSteps || qual != agg.qualifyingActiveMinutes) {
          aggregates[i] = DailyAggregate(
            date: agg.date,
            totalSteps: steps,
            totalDistance: dist,
            totalCalories: cals,
            totalActiveMinutes: act,
            qualifyingActiveMinutes: qual,
            isActiveDay: qual >= NdppConstants.minQualifyingSessionMinutes,
            coreSessions: agg.coreSessions,
            lifestyleSessions: agg.lifestyleSessions,
          );
        }
      } else {
        final pSteps = prefs.getInt('hc_persist_steps_$key');
        final pQual = prefs.getInt('hc_persist_qual_mins_$key');
        if ((pSteps != null && pSteps > 0) || (pQual != null && pQual > 0) || (key == todayKey && manualMinsToday > 0)) {
          final rSteps = pSteps ?? 0;
          final rDist = prefs.getDouble('hc_persist_dist_$key') ?? (rSteps * 0.00076);
          final rCals = prefs.getDouble('hc_persist_cals_$key') ?? 0.0;
          int rAct = prefs.getInt('hc_persist_act_mins_$key') ?? 0;
          int rQual = max(pQual ?? 0, rAct);

          if (key == todayKey && manualMinsToday > 0) {
            rAct += manualMinsToday;
            rQual += manualMinsToday;
          }

          aggregates[i] = DailyAggregate(
            date: agg.date,
            totalSteps: rSteps,
            totalDistance: rDist,
            totalCalories: rCals + (key == todayKey ? manualMinsToday * 5.8 : 0),
            totalActiveMinutes: rAct,
            qualifyingActiveMinutes: rQual,
            isActiveDay: rQual >= NdppConstants.minQualifyingSessionMinutes || rSteps >= 3000,
            coreSessions: agg.coreSessions,
            lifestyleSessions: agg.lifestyleSessions,
          );
        }
      }
    }
  }

  String _dateKey(DateTime date) {
    final local = date.toLocal();
    return "${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}";
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
      date: DateTime(point.dateFrom.toLocal().year, point.dateFrom.toLocal().month, point.dateFrom.toLocal().day),
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

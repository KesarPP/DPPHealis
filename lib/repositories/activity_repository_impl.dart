import 'package:flutter/foundation.dart';
import '../models/activity_stats.dart';
import '../services/health_service.dart';
import 'activity_repository.dart';
class ActivityRepositoryImpl implements ActivityRepository {


  final HealthService healthService;
  ActivityStats? _cachedStats;
  DateTime? _lastSyncTime;
  static const Duration _staleDuration =
  Duration(minutes: 15);

  ActivityRepositoryImpl(this.healthService);
  @override
  DateTime? get lastSyncTime => _lastSyncTime;

  bool get _hasFreshCache {
    if (_cachedStats == null || _lastSyncTime == null) {
      return false;
    }

    return DateTime.now()
        .difference(_lastSyncTime!) <
        _staleDuration;
  }

  @override
  Future<bool> isConnected() async {
    return await healthService.hasPermissions();
  }

  @override
  Future<ActivityStats> getActivityStats({bool forceRefresh = false}) async {
    debugPrint(
      'SERVICE TYPE: ${healthService.runtimeType}',
    );
    if (!forceRefresh && _hasFreshCache) {
      return _cachedStats!;
    }

    final results = await Future.wait([
      healthService.getTodaySteps(),
      healthService.getTodayDistance(),
      healthService.getTodayCalories(),
      healthService.getTodayActiveMinutes(),
    ]);

    final stats = ActivityStats(
      steps: results[0] as int,
      distance: results[1] as double,
      calories: results[2] as double,
      activeMinutes: results[3] as int,
    );
  _cachedStats = stats;
  _lastSyncTime = DateTime.now();

  return stats;
  }
}
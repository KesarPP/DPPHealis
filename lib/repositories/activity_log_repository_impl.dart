import '../models/activity_log.dart';
import '../services/activity_log_service.dart';
import 'activity_log_repository.dart';

/// Concrete repository for today's activity timeline logs.
/// Mirrors the caching pattern used by ActivityRepositoryImpl for
/// Health Connect data, but with a short TTL — the user can log a new
/// activity at any point during the day, so the cache shouldn't be
/// allowed to go stale for long.
class ActivityLogRepositoryImpl implements ActivityLogRepository {
  final ActivityLogService _service;

  List<ActivityLog>? _cachedLogs;
  DateTime? _cachedAt;
  static const _cacheTtl = Duration(minutes: 2);

  ActivityLogRepositoryImpl(this._service);

  @override
  Future<List<ActivityLog>> getTodayActivityLogs(
      {bool forceRefresh = false}) async {
    final cacheIsFresh =
        _cachedAt != null && DateTime.now().difference(_cachedAt!) < _cacheTtl;

    if (!forceRefresh && cacheIsFresh && _cachedLogs != null) {
      return _cachedLogs!;
    }

    final logs = await _service.getTodayActivityLogs();
    _cachedLogs = logs;
    _cachedAt = DateTime.now();
    return logs;
  }

  /// Call this right after the user successfully logs a new activity,
  /// so the next read bypasses the cache and the new entry shows up
  /// immediately instead of waiting out the TTL.
  void invalidateCache() {
    _cachedLogs = null;
    _cachedAt = null;
  }

  @override
  Future<List<ActivityLog>> getLogsForInterval(DateTime startTime, DateTime endTime) async {
    return _service.getLogsForInterval(startTime, endTime);
  }

  @override
  Future<void> saveActivityLog(ActivityLog log) async {
    await _service.saveActivityLog(log);
    invalidateCache();
  }
}
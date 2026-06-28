import '../models/activity_log.dart';

abstract class ActivityLogRepository {
  Future<List<ActivityLog>> getTodayActivityLogs();
  Future<List<ActivityLog>> getLogsForInterval(DateTime startTime, DateTime endTime);
  Future<void> saveActivityLog(ActivityLog log);
}
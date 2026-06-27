import '../models/activity_log.dart';

abstract class ActivityLogService {
  Future<List<ActivityLog>> getTodayActivityLogs();
  Future<void> saveActivityLog(ActivityLog log);
}

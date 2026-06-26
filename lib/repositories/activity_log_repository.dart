import '../models/activity_log.dart';

abstract class ActivityLogRepository {
  Future<List<ActivityLog>> getTodayActivityLogs();
}
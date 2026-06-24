import '../models/activity_stats.dart';

abstract class ActivityRepository {
  Future<ActivityStats> getActivityStats({bool forceRefresh = false});
  Future<bool> isConnected();
  DateTime? get lastSyncTime;
}
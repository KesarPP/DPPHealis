import '../models/activity_stats.dart';

abstract class ActivityRepository {
  Future<ActivityStats> getActivityStats();
}
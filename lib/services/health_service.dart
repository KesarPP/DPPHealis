abstract class HealthService {
  Future<bool> isHealthConnectAvailable();

  Future<bool> hasPermissions();

  Future<bool> requestPermissions();

  Future<int> getTodaySteps();

  Future<double> getTodayDistance();

  Future<double> getTodayCalories();

  Future<int> getTodayActiveMinutes();
}
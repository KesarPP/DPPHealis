class ActivityStats {
  final int steps;
  final double distance;
  final double calories;
  final int activeMinutes;

  const ActivityStats({
    required this.steps,
    required this.distance,
    required this.calories,
    required this.activeMinutes,
  });
  factory ActivityStats.empty() {
    return const ActivityStats(
      steps: 0,
      distance: 0,
      calories: 0,
      activeMinutes: 0,
    );
  }
}
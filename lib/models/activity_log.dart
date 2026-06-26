class ActivityLog {
  final String id;
  final String activityName;
  final int durationMinutes;
  final String frequency;
  final DateTime createdAt;

  const ActivityLog({
    required this.id,
    required this.activityName,
    required this.durationMinutes,
    required this.frequency,
    required this.createdAt,
  });

  factory ActivityLog.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return ActivityLog(
      id: id,
      activityName: data['activityName'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 0,
      frequency: data['frequency'] ?? '',
      createdAt: (data['createdAt']).toDate(),
    );
  }

  factory ActivityLog.empty() {
    return ActivityLog(
      id: '',
      activityName: '',
      durationMinutes: 0,
      frequency: '',
      createdAt: DateTime.now(),
    );
  }
}
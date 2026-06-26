import 'package:flutter_test/flutter_test.dart';
import 'package:dpp_app/services/activity_metrics_engine.dart';
import 'package:dpp_app/models/ndpp_constants.dart';

void main() {
  group('Achievements Evaluation Engine', () {
    test('Correctly evaluates 12 NDPP achievements and permanent earned map', () {
      final now = DateTime.now();
      final pastDays = [
        DailyAggregate(
          date: now,
          totalSteps: 11000,
          totalDistance: 5000,
          totalCalories: 300,
          totalActiveMinutes: 45,
          qualifyingActiveMinutes: 30,
          isActiveDay: true,
          coreSessions: [
            ActivitySession(
              id: '1',
              userId: 'u1',
              source: SessionSource.healthConnect,
              activityType: ActivityType.walking,
              category: ActivityCategory.core,
              startTime: now,
              endTime: now.add(const Duration(minutes: 30)),
              durationMinutes: 30,
              isQualifying: true,
              date: now,
            )
          ],
          lifestyleSessions: [],
        )
      ];

      final earnedMap = {'streak_7': DateTime(2026, 1, 1)};

      final achievements = ActivityMetricsEngine.evaluateAchievements(
        pastDays: pastDays,
        mealLogCount: 55,
        baselineWeight: 90.0,
        currentWeight: 84.0, // 6kg loss
        riskScore: 28.0,
        programWeek: 8,
        earnedMap: earnedMap,
      );

      expect(achievements.length, 12);

      final streak7 = achievements.firstWhere((a) => a.id == 'streak_7');
      expect(streak7.unlocked, isTrue); // Permanently unlocked via earnedMap even though 1 day passed

      final meals50 = achievements.firstWhere((a) => a.id == 'logged_50_meals');
      expect(meals50.unlocked, isTrue);

      final first10k = achievements.firstWhere((a) => a.id == 'first_10k');
      expect(first10k.unlocked, isTrue);

      final lose5kg = achievements.firstWhere((a) => a.id == 'lose_5kg');
      expect(lose5kg.unlocked, isTrue);

      final briskPace = achievements.firstWhere((a) => a.id == 'brisk_pace');
      expect(briskPace.unlocked, isTrue);
    });
  });
}

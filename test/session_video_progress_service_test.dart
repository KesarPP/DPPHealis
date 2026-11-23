import 'package:flutter_test/flutter_test.dart';
import 'package:dpp_app/services/session_video_progress_service.dart';

void main() {
  group('SessionVideoProgressService — Dual-Condition Sequential Unlocking', () {
    final t0 = DateTime.utc(2026, 1, 1, 12, 0, 0); // Day 0: Program start

    test('1. Level 1 unlocks immediately at program start', () async {
      final storage = InMemoryVideoProgressStorage();
      final service = SessionVideoProgressService(storage: storage, initialTime: t0);
      await service.loadAll(null, t0);

      expect(service.isLevelUnlocked(1, t0), isTrue);
      expect(service.getLevelUnlockStatus(1, t0), equals(LevelUnlockStatus.unlocked));
      expect(service.getLevelUnlockTimestamp(1), equals(t0));

      // Levels 2..16 remain locked
      for (var lvl = 2; lvl <= 16; lvl++) {
        expect(service.isLevelUnlocked(lvl, t0), isFalse);
      }
    });

    test('2. Level 2 remains locked before 7 days even when Level 1 video is completed', () async {
      final storage = InMemoryVideoProgressStorage();
      final service = SessionVideoProgressService(storage: storage, initialTime: t0);
      await service.loadAll(null, t0);

      // User completes Level 1 video on Day 2
      final day2 = t0.add(const Duration(days: 2));
      await service.markCompleted('session_01', day2);

      expect(service.isCompleted('session_01'), isTrue);
      // Day 2: 7 days have NOT elapsed yet (only 2 days)
      expect(service.isLevelUnlocked(2, day2), isFalse);
      expect(service.getLevelUnlockStatus(2, day2),
          equals(LevelUnlockStatus.videoCompletedAndTimeRemaining));
      expect(service.getLockedLevelMessage(2, day2), contains('unlocks in 5 days'));

      // Day 6: still locked
      final day6 = t0.add(const Duration(days: 6));
      expect(service.isLevelUnlocked(2, day6), isFalse);
      expect(service.getLockedLevelMessage(2, day6), contains('unlocks in 1 day'));
    });

    test('3. Level 2 unlocks exactly when 7 days have elapsed and previous video is complete', () async {
      final storage = InMemoryVideoProgressStorage();
      final service = SessionVideoProgressService(storage: storage, initialTime: t0);
      await service.loadAll(null, t0);

      // Complete video on Day 2
      final day2 = t0.add(const Duration(days: 2));
      await service.markCompleted('session_01', day2);

      // Exact moment of 7 days: Day 7
      final day7 = t0.add(const Duration(days: 7));
      expect(service.isLevelUnlocked(2, day7), isTrue);
      expect(service.getLevelUnlockStatus(2, day7), equals(LevelUnlockStatus.unlocked));
      expect(service.canUnlockNextLevel(1, day7), isTrue);

      // Evaluating progression records authoritative unlock timestamp on Day 7
      await service.checkProgression(day7);
      expect(service.getLevelUnlockTimestamp(2), equals(day7));
    });

    test('4. Level 2 remains locked after 7 days if previous video is incomplete', () async {
      final storage = InMemoryVideoProgressStorage();
      final service = SessionVideoProgressService(storage: storage, initialTime: t0);
      await service.loadAll(null, t0);

      // Day 10 arrives without video completion
      final day10 = t0.add(const Duration(days: 10));
      expect(service.isCompleted('session_01'), isFalse);
      expect(service.isLevelUnlocked(2, day10), isFalse);
      expect(service.getLevelUnlockStatus(2, day10),
          equals(LevelUnlockStatus.videoIncompleteAndTimeElapsed));
      expect(service.getLockedLevelMessage(2, day10),
          contains('Complete the previous session video'));
    });

    test('5. Level 2 unlocks immediately if video completed after 7-day period elapsed', () async {
      final storage = InMemoryVideoProgressStorage();
      final service = SessionVideoProgressService(storage: storage, initialTime: t0);
      await service.loadAll(null, t0);

      // User watches video on Day 10 (7 days already passed on Day 7)
      final day10 = t0.add(const Duration(days: 10));
      await service.markCompleted('session_01', day10);

      expect(service.isLevelUnlocked(2, day10), isTrue);
      expect(service.getLevelUnlockStatus(2, day10), equals(LevelUnlockStatus.unlocked));
      // Unlock timestamp is the moment both conditions became true (Day 10)
      expect(service.getLevelUnlockTimestamp(2), equals(day10));
    });

    test('6. Completing video before Day 7 does not shorten the waiting period', () async {
      final storage = InMemoryVideoProgressStorage();
      final service = SessionVideoProgressService(storage: storage, initialTime: t0);
      await service.loadAll(null, t0);

      // Video watched on Day 1 (very early)
      final day1 = t0.add(const Duration(days: 1));
      await service.markCompleted('session_01', day1);

      // Day 3: still locked
      final day3 = t0.add(const Duration(days: 3));
      expect(service.isLevelUnlocked(2, day3), isFalse);
      expect(service.getRemainingUnlockDuration(2, day3).inDays, equals(4));

      // Day 6 hours 23: still locked
      final day6Almost7 = t0.add(const Duration(days: 6, hours: 23));
      expect(service.isLevelUnlocked(2, day6Almost7), isFalse);

      // Day 7: unlocks
      final day7 = t0.add(const Duration(days: 7));
      expect(service.isLevelUnlocked(2, day7), isTrue);
    });

    test('7. Completing video after Day 7 does not add another 7-day delay', () async {
      final storage = InMemoryVideoProgressStorage();
      final service = SessionVideoProgressService(storage: storage, initialTime: t0);
      await service.loadAll(null, t0);

      // Video watched on Day 12
      final day12 = t0.add(const Duration(days: 12));
      await service.markCompleted('session_01', day12);

      // Must unlock on Day 12 immediately, not Day 19!
      expect(service.isLevelUnlocked(2, day12), isTrue);
      expect(service.getLevelUnlockTimestamp(2), equals(day12));
    });

    test('8. Level 3 requires Level 2 video completion AND 7 days since Level 2 unlocked', () async {
      final storage = InMemoryVideoProgressStorage();
      final service = SessionVideoProgressService(storage: storage, initialTime: t0);
      await service.loadAll(null, t0);

      // Level 1 video completed on Day 2 -> Level 2 unlocks on Day 7
      final day2 = t0.add(const Duration(days: 2));
      await service.markCompleted('session_01', day2);
      final day7 = t0.add(const Duration(days: 7));
      await service.checkProgression(day7);
      expect(service.isLevelUnlocked(2, day7), isTrue);
      expect(service.getLevelUnlockTimestamp(2), equals(day7));

      // Level 2 video completed on Day 8
      final day8 = t0.add(const Duration(days: 8));
      await service.markCompleted('session_02', day8);

      // Level 3 timer started when Level 2 unlocked (Day 7).
      // Level 3 requires 7 days after Level 2 unlocked -> Day 14!
      final day13 = t0.add(const Duration(days: 13));
      expect(service.isLevelUnlocked(3, day13), isFalse);
      expect(service.getLevelUnlockStatus(3, day13),
          equals(LevelUnlockStatus.videoCompletedAndTimeRemaining));

      // Day 14: Level 3 unlocks
      final day14 = t0.add(const Duration(days: 14));
      expect(service.isLevelUnlocked(3, day14), isTrue);
      await service.checkProgression(day14);
      expect(service.getLevelUnlockTimestamp(3), equals(day14));
    });

    test('9. All 16 levels follow the exact sequential rule', () async {
      final storage = InMemoryVideoProgressStorage();
      final service = SessionVideoProgressService(storage: storage, initialTime: t0);
      await service.loadAll(null, t0);

      var currentSimulatedTime = t0;

      for (var lvl = 1; lvl <= 15; lvl++) {
        expect(service.isLevelUnlocked(lvl, currentSimulatedTime), isTrue);
        expect(service.isLevelUnlocked(lvl + 1, currentSimulatedTime), isFalse);

        // Complete video on day +1 of that level's availability
        final vidCompleteTime = currentSimulatedTime.add(const Duration(days: 1));
        final sid = 'session_${lvl.toString().padLeft(2, '0')}';
        await service.markCompleted(sid, vidCompleteTime);

        // Advance to 7 days after level unlock
        currentSimulatedTime = currentSimulatedTime.add(const Duration(days: 7));
        await service.checkProgression(currentSimulatedTime);

        expect(service.isLevelUnlocked(lvl + 1, currentSimulatedTime), isTrue,
            reason: 'Level ${lvl + 1} should be unlocked on $currentSimulatedTime');
      }

      // Finally Level 16 is unlocked
      expect(service.isLevelUnlocked(16, currentSimulatedTime), isTrue);
    });

    test('10. Partial video progress (0.95 or 0.99) cannot satisfy completion', () async {
      final storage = InMemoryVideoProgressStorage();
      final service = SessionVideoProgressService(storage: storage, initialTime: t0);
      await service.loadAll(null, t0);

      // 7 days elapsed, but only 99% progress
      final day7 = t0.add(const Duration(days: 7));
      await service.updateProgress('session_01', 0.99);

      expect(service.isCompleted('session_01'), isFalse);
      expect(service.isLevelUnlocked(2, day7), isFalse);
      expect(service.getLevelUnlockStatus(2, day7),
          equals(LevelUnlockStatus.videoIncompleteAndTimeElapsed));
    });

    test('11. Completion and unlock timestamps persist across app restarts', () async {
      final storage = InMemoryVideoProgressStorage();
      final service = SessionVideoProgressService(storage: storage, initialTime: t0);
      await service.loadAll(null, t0);

      final day2 = t0.add(const Duration(days: 2));
      await service.markCompleted('session_01', day2);

      final day7 = t0.add(const Duration(days: 7));
      await service.checkProgression(day7);
      expect(service.isLevelUnlocked(2, day7), isTrue);

      // Simulate app restart with new service instance sharing same storage
      final reloaded = SessionVideoProgressService(storage: storage);
      await reloaded.loadAll(null, day7);

      expect(reloaded.isCompleted('session_01'), isTrue);
      expect(reloaded.getLevelUnlockTimestamp(1), equals(t0));
      expect(reloaded.getLevelUnlockTimestamp(2), equals(day7));
      expect(reloaded.isLevelUnlocked(2, day7), isTrue);
    });

    test('12. Returning after multiple weeks recalculates eligibility correctly', () async {
      final storage = InMemoryVideoProgressStorage();
      final service = SessionVideoProgressService(storage: storage, initialTime: t0);
      await service.loadAll(null, t0);

      // Complete session 1 on Day 1
      final day1 = t0.add(const Duration(days: 1));
      await service.markCompleted('session_01', day1);

      // User returns 4 weeks later without having opened the app
      final week4 = t0.add(const Duration(days: 28));
      final reloaded = SessionVideoProgressService(storage: storage);
      await reloaded.loadAll(null, week4);

      // Level 2 must now be unlocked
      expect(reloaded.isLevelUnlocked(2, week4), isTrue);
      // But Level 3 remains locked because Session 2 video has NOT been completed
      expect(reloaded.isLevelUnlocked(3, week4), isFalse);
    });

    test('13. Repeated player events do not create duplicate unlock records (idempotence)', () async {
      final storage = InMemoryVideoProgressStorage();
      final service = SessionVideoProgressService(storage: storage, initialTime: t0);
      await service.loadAll(null, t0);

      final day7 = t0.add(const Duration(days: 7));
      await service.markCompleted('session_01', day7);
      final firstUnlockTime = service.getLevelUnlockTimestamp(2);

      // Fire completion multiple times (e.g. repeated player ENDED events)
      final day8 = t0.add(const Duration(days: 8));
      await service.markCompleted('session_01', day8);
      await service.markCompleted('session_01', day8);

      expect(service.getLevelUnlockTimestamp(2), equals(firstUnlockTime));
    });

    test('14. Previously unlocked levels remain unlocked', () async {
      final storage = InMemoryVideoProgressStorage();
      final service = SessionVideoProgressService(storage: storage, initialTime: t0);
      await service.loadAll(null, t0);

      final day7 = t0.add(const Duration(days: 7));
      await service.markCompleted('session_01', day7);
      expect(service.isLevelUnlocked(2, day7), isTrue);

      // Check at a later time
      final day30 = t0.add(const Duration(days: 30));
      expect(service.isLevelUnlocked(1, day30), isTrue);
      expect(service.isLevelUnlocked(2, day30), isTrue);
    });
  });
}

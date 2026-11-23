import 'package:flutter_test/flutter_test.dart';
import 'package:dpp_app/services/playback_coverage_tracker.dart';
import 'package:dpp_app/services/video_completion_detector.dart';

void main() {
  group('PlaybackCoverageTracker (Seeking Protection & Verification)', () {
    test('normal playback progression advances verified coverage', () {
      final tracker = PlaybackCoverageTracker();
      final duration = const Duration(minutes: 10);
      var time = DateTime(2026, 1, 1, 12, 0, 0);

      // Start at 0s
      tracker.recordPlayback(position: Duration.zero, duration: duration, isPlaying: true, now: time);

      // Play 5 seconds normally
      time = time.add(const Duration(seconds: 5));
      tracker.recordPlayback(position: const Duration(seconds: 5), duration: duration, isPlaying: true, now: time);

      expect(tracker.totalWatchedDuration.inSeconds, equals(5));
      expect(tracker.coverageFraction(duration), closeTo(5 / 600, 0.001));
    });

    test('forward seeking does not count skipped content', () {
      final tracker = PlaybackCoverageTracker();
      final duration = const Duration(minutes: 10);
      var time = DateTime(2026, 1, 1, 12, 0, 0);

      // Play 0..10 seconds normally
      tracker.recordPlayback(position: Duration.zero, duration: duration, isPlaying: true, now: time);
      time = time.add(const Duration(seconds: 10));
      tracker.recordPlayback(position: const Duration(seconds: 10), duration: duration, isPlaying: true, now: time);

      expect(tracker.totalWatchedDuration.inSeconds, equals(10));

      // User seeks from 10s to 500s in 1 second of real time!
      time = time.add(const Duration(seconds: 1));
      tracker.recordPlayback(position: const Duration(seconds: 500), duration: duration, isPlaying: true, now: time);

      // The 10..500s jump MUST NOT be credited as watched!
      expect(tracker.totalWatchedDuration.inSeconds, equals(10));
    });

    test('jumping directly to the end does not complete', () {
      final tracker = PlaybackCoverageTracker();
      final duration = const Duration(minutes: 10);
      var time = DateTime(2026, 1, 1, 12, 0, 0);

      // Start video
      tracker.recordPlayback(position: Duration.zero, duration: duration, isPlaying: true, now: time);

      // Immediately seek to 9m59s
      time = time.add(const Duration(seconds: 2));
      tracker.recordPlayback(position: const Duration(minutes: 9, seconds: 59), duration: duration, isPlaying: true, now: time);

      expect(tracker.isFullyWatched(duration: duration, currentPosition: const Duration(minutes: 9, seconds: 59)), isFalse);
    });

    test('pause does not count as watched time', () {
      final tracker = PlaybackCoverageTracker();
      final duration = const Duration(minutes: 10);
      var time = DateTime(2026, 1, 1, 12, 0, 0);

      tracker.recordPlayback(position: Duration.zero, duration: duration, isPlaying: true, now: time);
      time = time.add(const Duration(seconds: 10));
      tracker.recordPlayback(position: const Duration(seconds: 10), duration: duration, isPlaying: true, now: time);

      // Paused for 60 seconds
      time = time.add(const Duration(seconds: 60));
      tracker.recordPlayback(position: const Duration(seconds: 10), duration: duration, isPlaying: false, now: time);

      expect(tracker.totalWatchedDuration.inSeconds, equals(10));
    });

    test('resuming after pause continues verified tracking', () {
      final tracker = PlaybackCoverageTracker();
      final duration = const Duration(minutes: 10);
      var time = DateTime(2026, 1, 1, 12, 0, 0);

      tracker.recordPlayback(position: Duration.zero, duration: duration, isPlaying: true, now: time);
      time = time.add(const Duration(seconds: 10));
      tracker.recordPlayback(position: const Duration(seconds: 10), duration: duration, isPlaying: true, now: time);

      // Paused
      time = time.add(const Duration(seconds: 20));
      tracker.recordPlayback(position: const Duration(seconds: 10), duration: duration, isPlaying: false, now: time);

      // Resumed
      time = time.add(const Duration(seconds: 1));
      tracker.recordPlayback(position: const Duration(seconds: 10), duration: duration, isPlaying: true, now: time);

      time = time.add(const Duration(seconds: 10));
      tracker.recordPlayback(position: const Duration(seconds: 20), duration: duration, isPlaying: true, now: time);

      expect(tracker.totalWatchedDuration.inSeconds, equals(20));
    });

    test('backward seeking does not falsely increase progress and preserves existing coverage', () {
      final tracker = PlaybackCoverageTracker();
      final duration = const Duration(minutes: 10);
      var time = DateTime(2026, 1, 1, 12, 0, 0);

      // Watch 0..30s
      tracker.recordPlayback(position: Duration.zero, duration: duration, isPlaying: true, now: time);
      time = time.add(const Duration(seconds: 30));
      tracker.recordPlayback(position: const Duration(seconds: 30), duration: duration, isPlaying: true, now: time);
      expect(tracker.totalWatchedDuration.inSeconds, equals(30));

      // Seek back to 10s
      time = time.add(const Duration(seconds: 1));
      tracker.recordPlayback(position: const Duration(seconds: 10), duration: duration, isPlaying: true, now: time);
      expect(tracker.totalWatchedDuration.inSeconds, equals(30));

      // Re-watch 10s to 20s (already watched interval)
      time = time.add(const Duration(seconds: 10));
      tracker.recordPlayback(position: const Duration(seconds: 20), duration: duration, isPlaying: true, now: time);
      expect(tracker.totalWatchedDuration.inSeconds, equals(30)); // Merged cleanly, no duplication
    });

    test('completion requires full verified coverage', () {
      final tracker = PlaybackCoverageTracker(tolerance: const Duration(seconds: 2));
      final duration = const Duration(seconds: 100);
      var time = DateTime(2026, 1, 1, 12, 0, 0);

      // Watch 0..50s
      tracker.recordPlayback(position: Duration.zero, duration: duration, isPlaying: true, now: time);
      time = time.add(const Duration(seconds: 50));
      tracker.recordPlayback(position: const Duration(seconds: 50), duration: duration, isPlaying: true, now: time);

      // 50% watched: not complete
      expect(tracker.isFullyWatched(duration: duration, currentPosition: const Duration(seconds: 50)), isFalse);

      // Watch remaining 50s..100s
      time = time.add(const Duration(seconds: 50));
      tracker.recordPlayback(position: const Duration(seconds: 100), duration: duration, isPlaying: true, now: time);

      expect(tracker.isFullyWatched(duration: duration, currentPosition: const Duration(seconds: 100)), isTrue);
    });

    test('serialization and restoration preserves verified intervals', () {
      final tracker = PlaybackCoverageTracker();
      final duration = const Duration(minutes: 5);
      var time = DateTime(2026, 1, 1, 12, 0, 0);

      tracker.recordPlayback(position: Duration.zero, duration: duration, isPlaying: true, now: time);
      time = time.add(const Duration(seconds: 60));
      tracker.recordPlayback(position: const Duration(seconds: 60), duration: duration, isPlaying: true, now: time);

      final serialized = tracker.serialize();
      expect(serialized.isNotEmpty, isTrue);

      final restoredTracker = PlaybackCoverageTracker();
      restoredTracker.restoreFrom(serialized);
      expect(restoredTracker.totalWatchedDuration.inSeconds, equals(60));
    });
  });

  group('VideoCompletionDetector with verified coverage enforcement', () {
    test('rejects seek-to-end completion when verified coverage is enforced', () {
      final detector = VideoCompletionDetector(
        tolerance: const Duration(seconds: 2),
        enforceVerifiedCoverage: true,
      );
      final duration = const Duration(minutes: 10);
      var time = DateTime(2026, 1, 1, 12, 0, 0);

      // First tick at 0
      detector.onPlaybackUpdate(position: Duration.zero, duration: duration, now: time);

      // Immediate seek to 9m59s
      time = time.add(const Duration(seconds: 1));
      final fired = detector.onPlaybackUpdate(
        position: const Duration(minutes: 9, seconds: 59),
        duration: duration,
        now: time,
      );

      expect(fired, isFalse);
      expect(detector.hasFired, isFalse);
    });

    test('fires once when entire duration has been legitimately streamed', () {
      final detector = VideoCompletionDetector(
        tolerance: const Duration(seconds: 2),
        enforceVerifiedCoverage: true,
      );
      final duration = const Duration(seconds: 20);
      var time = DateTime(2026, 1, 1, 12, 0, 0);

      detector.onPlaybackUpdate(position: Duration.zero, duration: duration, now: time);

      // Play through in 5s increments
      for (var s = 5; s <= 20; s += 5) {
        time = time.add(const Duration(seconds: 5));
        final fired = detector.onPlaybackUpdate(
          position: Duration(seconds: s),
          duration: duration,
          now: time,
        );
        if (s == 20) {
          expect(fired, isTrue);
        } else {
          expect(fired, isFalse);
        }
      }

      expect(detector.hasFired, isTrue);

      // Subsequent update does not fire again
      time = time.add(const Duration(seconds: 1));
      final firedAgain = detector.onPlaybackUpdate(
        position: const Duration(seconds: 20),
        duration: duration,
        now: time,
      );
      expect(firedAgain, isFalse);
    });
  });
}

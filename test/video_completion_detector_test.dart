import 'package:flutter_test/flutter_test.dart';
import 'package:dpp_app/services/video_completion_detector.dart';

void main() {
  group('VideoCompletionDetector', () {
    test('does not fire before reaching the end', () {
      final detector = VideoCompletionDetector();
      final fired = detector.onPlaybackUpdate(
        position: const Duration(minutes: 5),
        duration: const Duration(minutes: 10),
      );
      expect(fired, isFalse);
      expect(detector.hasFired, isFalse);
    });

    test('fires when within tolerance of the end', () {
      final detector = VideoCompletionDetector(
        tolerance: const Duration(seconds: 2),
      );
      final fired = detector.onPlaybackUpdate(
        position: const Duration(minutes: 9, seconds: 59),
        duration: const Duration(minutes: 10),
      );
      expect(fired, isTrue);
      expect(detector.hasFired, isTrue);
    });

    test('fires only once per viewing session', () {
      final detector = VideoCompletionDetector();
      final firstFire = detector.onPlaybackUpdate(
        position: const Duration(minutes: 10),
        duration: const Duration(minutes: 10),
      );
      final secondFire = detector.onPlaybackUpdate(
        position: const Duration(minutes: 10),
        duration: const Duration(minutes: 10),
      );
      expect(firstFire, isTrue);
      expect(secondFire, isFalse);
    });

    test('does not fire merely because playback started', () {
      final detector = VideoCompletionDetector();
      final fired = detector.onPlaybackUpdate(
        position: const Duration(seconds: 1),
        duration: const Duration(minutes: 10),
      );
      expect(fired, isFalse);
    });

    test('honours explicit playerReportedEnded signal', () {
      final detector = VideoCompletionDetector();
      final fired = detector.onPlaybackUpdate(
        position: const Duration(minutes: 8),
        duration: const Duration(minutes: 10),
        playerReportedEnded: true,
      );
      expect(fired, isTrue);
    });

    test('is defensive against unknown/zero duration', () {
      final detector = VideoCompletionDetector();
      final fired = detector.onPlaybackUpdate(
        position: Duration.zero,
        duration: Duration.zero,
      );
      expect(fired, isFalse);
    });

    group('progressFraction', () {
      test('computes expected fraction', () {
        final fraction = VideoCompletionDetector.progressFraction(
          position: const Duration(seconds: 420),
          duration: const Duration(seconds: 600),
        );
        expect(fraction, closeTo(0.7, 0.0001));
      });

      test('clamps to 0.0 for zero duration', () {
        final fraction = VideoCompletionDetector.progressFraction(
          position: const Duration(seconds: 10),
          duration: Duration.zero,
        );
        expect(fraction, 0.0);
      });
    });
  });
}

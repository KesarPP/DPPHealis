import 'package:flutter_test/flutter_test.dart';
import 'package:dpp_app/services/session_video_progress_service.dart';

void main() {
  group('SessionVideoProgressService', () {
    test('defaults to not completed / zero progress before load', () {
      final service =
          SessionVideoProgressService(storage: InMemoryVideoProgressStorage());
      expect(service.isCompleted('session_01'), isFalse);
      expect(service.progressFor('session_01'), 0.0);
    });

    test('markCompleted persists and is readable after reload', () async {
      final storage = InMemoryVideoProgressStorage();
      final service = SessionVideoProgressService(storage: storage);

      await service.markCompleted('session_01');
      expect(service.isCompleted('session_01'), isTrue);
      expect(service.progressFor('session_01'), 1.0);

      // Simulate app restart: new service instance, same storage.
      final reloaded = SessionVideoProgressService(storage: storage);
      await reloaded.load('session_01');
      expect(reloaded.isCompleted('session_01'), isTrue);
    });

    test('updateProgress persists partial progress', () async {
      final storage = InMemoryVideoProgressStorage();
      final service = SessionVideoProgressService(storage: storage);

      await service.updateProgress('session_02', 0.42);
      expect(service.progressFor('session_02'), 0.42);

      final reloaded = SessionVideoProgressService(storage: storage);
      await reloaded.load('session_02');
      expect(reloaded.progressFor('session_02'), 0.42);
    });

    test('progress values are clamped to 0.0-1.0', () async {
      final service =
          SessionVideoProgressService(storage: InMemoryVideoProgressStorage());
      await service.updateProgress('session_03', 1.5);
      expect(service.progressFor('session_03'), 1.0);
    });
  });
}

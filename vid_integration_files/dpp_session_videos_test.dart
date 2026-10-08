import 'package:flutter_test/flutter_test.dart';
import 'package:dpp_app/data/dpp_session_videos.dart';

void main() {
  group('dppSessionVideos (16-session configuration)', () {
    test('contains exactly 16 sessions', () {
      expect(dppSessionVideos.length, 16);
    });

    test('all session IDs are unique', () {
      final ids = dppSessionVideos.map((v) => v.sessionId).toSet();
      expect(ids.length, 16);
    });

    test('session IDs follow session_01 .. session_16 pattern', () {
      for (var i = 1; i <= 16; i++) {
        final expectedId = 'session_${i.toString().padLeft(2, '0')}';
        expect(
          dppSessionVideos.any((v) => v.sessionId == expectedId),
          isTrue,
          reason: 'Missing $expectedId',
        );
      }
    });

    test('order values are sequential from 1 to 16 with no gaps/dupes', () {
      final orders = orderedDppSessionVideos.map((v) => v.order).toList();
      expect(orders, List.generate(16, (i) => i + 1));
    });

    test('findDppSessionVideo resolves every session correctly', () {
      for (var i = 1; i <= 16; i++) {
        final id = 'session_${i.toString().padLeft(2, '0')}';
        final result = findDppSessionVideo(id);
        expect(result, isNotNull);
        expect(result!.sessionId, id);
        expect(result.order, i);
      }
    });

    test('findDppSessionVideo returns null for unknown session', () {
      expect(findDppSessionVideo('session_99'), isNull);
    });

    test('placeholder sessions are not playable', () {
      for (final video in dppSessionVideos) {
        expect(video.isPlaceholder, isTrue);
        expect(video.isPlayable, isFalse);
      }
    });

    test('a session becomes playable once given a real ID and marked available', () {
      final withRealId = dppSessionVideos.first.copyWith(
        videoId: '4Bit209Xcmc',
        isAvailable: true,
      );
      expect(withRealId.isPlaceholder, isFalse);
      expect(withRealId.isPlayable, isTrue);
    });

    test('no placeholder is accidentally marked available', () {
      for (final video in dppSessionVideos) {
        if (video.isPlaceholder) {
          expect(video.isAvailable, isFalse,
              reason: '${video.sessionId} is a placeholder but marked available');
        }
      }
    });
  });
}

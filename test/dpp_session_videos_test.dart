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

    test('DppSessionVideos.lookup and getByOrder resolve sessions correctly', () {
      final s1 = DppSessionVideos.lookup('session_01');
      expect(s1, isNotNull);
      expect(s1!.order, 1);

      final s16 = DppSessionVideos.getByOrder(16);
      expect(s16, isNotNull);
      expect(s16!.sessionId, 'session_16');
    });

    test('findDppSessionVideo returns null for unknown session', () {
      expect(findDppSessionVideo('session_99'), isNull);
    });

    test('placeholder sessions are not playable', () {
      for (final video in dppSessionVideos) {
        if (video.isPlaceholder) {
          expect(video.isPlayable, isFalse);
        }
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

    test('findDppSessionVideo(session_01) does not return session_02', () {
      final s1 = findDppSessionVideo('session_01');
      final s2 = findDppSessionVideo('session_02');
      expect(s1, isNotNull);
      expect(s2, isNotNull);
      expect(s1!.sessionId, equals('session_01'));
      expect(s2!.sessionId, equals('session_02'));
      expect(s1, isNot(same(s2)));
      expect(s1.sessionId, isNot(equals(s2.sessionId)));
    });

    test('4Bit209Xcmc is assigned to exactly one session', () {
      final matches = dppSessionVideos.where((v) => v.videoId == '4Bit209Xcmc').toList();
      expect(matches.length, equals(1));
    });
  });
}

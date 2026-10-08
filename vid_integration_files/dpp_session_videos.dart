import '../models/dpp_session_video.dart';

/// SINGLE SOURCE OF TRUTH for every DPP session video.
///
/// When the official HEALIS YouTube channel is ready, this is the ONLY
/// file that needs to change. For each session:
///
///   1. Replace the `videoId` placeholder (e.g. 'PLACEHOLDER_SESSION_01')
///      with the real YouTube video ID from the unlisted upload.
///   2. Set `isAvailable: true`.
///
/// Nothing else in the app needs to change — the player, the screen, and
/// the progress service all key off this list.
final List<DppSessionVideo> dppSessionVideos = [
  const DppSessionVideo(
    sessionId: 'session_01',
    title: 'Understanding Diabetes',
    videoId: 'PLACEHOLDER_SESSION_01',
    description: 'Introduction to the DPP program and how it can help '
        'reduce your risk of type 2 diabetes.',
    order: 1,
    isAvailable: false,
  ),
  const DppSessionVideo(
    sessionId: 'session_02',
    title: 'Eat Well',
    videoId: 'PLACEHOLDER_SESSION_02',
    description: 'Building healthier eating habits step by step.',
    order: 2,
    isAvailable: false,
  ),
  const DppSessionVideo(
    sessionId: 'session_03',
    title: 'Get Active',
    videoId: 'PLACEHOLDER_SESSION_03',
    description: 'Why movement matters and how to build an activity habit.',
    order: 3,
    isAvailable: false,
  ),
  // Add Session 4..N following the same pattern. Keep `order` sequential —
  // it is used for sorting and, later, for "next session" unlock logic.
];

/// Looks up a session video by its [sessionId].
/// Returns null if no matching session exists.
DppSessionVideo? findDppSessionVideo(String sessionId) {
  for (final video in dppSessionVideos) {
    if (video.sessionId == sessionId) return video;
  }
  return null;
}

/// Returns all configured sessions sorted by [DppSessionVideo.order].
List<DppSessionVideo> get orderedDppSessionVideos {
  final list = List<DppSessionVideo>.from(dppSessionVideos);
  list.sort((a, b) => a.order.compareTo(b.order));
  return list;
}

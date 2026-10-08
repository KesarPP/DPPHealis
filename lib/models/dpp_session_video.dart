/// Metadata describing a single DPP session's video.
///
/// This is intentionally decoupled from the YouTube player itself — it is
/// pure data. The only thing that ever needs to change when real videos
/// become available is [videoId] and [isAvailable] inside
/// `dpp_session_videos.dart`.
class DppSessionVideo {
  const DppSessionVideo({
    required this.sessionId,
    required this.title,
    required this.videoId,
    required this.order,
    this.description,
    this.duration,
    this.thumbnailUrl,
    this.isAvailable = false,
  });

  /// Stable identifier for the session, e.g. 'session_01'.
  /// Used as the persistence key prefix — do not change once shipped.
  final String sessionId;

  final String title;

  /// The public YouTube video ID (the `v=` query param), e.g. '4Bit209Xcmc'.
  /// Use a value prefixed with 'PLACEHOLDER_' until the real HEALIS
  /// YouTube channel is live — see [isPlaceholder].
  final String videoId;

  /// 1-based ordering used to sort sessions and to determine sequencing
  /// for future "unlock next session" logic.
  final int order;

  final String? description;

  /// Known/expected duration, if you want to show it before playback
  /// starts (e.g. "10 min"). Not required for completion detection —
  /// completion is derived from the player's own reported duration.
  final Duration? duration;

  final String? thumbnailUrl;

  /// Whether this session's video content is considered available at all
  /// (independent of whether a real YouTube ID has been set). Lets you
  /// stage sessions ahead of content being ready.
  final bool isAvailable;

  /// True if [videoId] is still a development placeholder rather than a
  /// real YouTube video ID. The player widget uses this to decide whether
  /// to attempt initialization at all.
  bool get isPlaceholder => videoId.startsWith('PLACEHOLDER_');

  /// True if this session's video can actually be played right now.
  bool get isPlayable => isAvailable && videoId.isNotEmpty && !isPlaceholder;

  DppSessionVideo copyWith({
    String? sessionId,
    String? title,
    String? videoId,
    int? order,
    String? description,
    Duration? duration,
    String? thumbnailUrl,
    bool? isAvailable,
  }) {
    return DppSessionVideo(
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      videoId: videoId ?? this.videoId,
      order: order ?? this.order,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  String toString() =>
      'DppSessionVideo(sessionId: $sessionId, order: $order, '
      'videoId: $videoId, isPlayable: $isPlayable)';
}

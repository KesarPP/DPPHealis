/// Player-independent completion logic.
///
/// Kept separate from the YouTube widget on purpose: this class has no
/// dependency on youtube_player_iframe or any webview, so it can be unit
/// tested directly (see test/features/sessions/video_completion_detector_test.dart)
/// instead of relying on widget tests against an external player.
class VideoCompletionDetector {
  VideoCompletionDetector({
    Duration tolerance = const Duration(seconds: 2),
  }) : _tolerance = tolerance;

  final Duration _tolerance;
  bool _hasFired = false;

  bool get hasFired => _hasFired;

  /// Feed this every position/duration update from the player.
  /// Returns true exactly once — the first time the video is judged to
  /// have reached its end — and false on every other call (including
  /// every call after that first true).
  ///
  /// A session is considered complete when:
  ///   - duration is known and greater than zero, AND
  ///   - position is within [_tolerance] of duration (handles players
  ///     that report e.g. 9:58 on a 10:00 video and never quite hit the
  ///     exact final frame), OR the underlying player independently
  ///     reports an "ended" state via [playerReportedEnded].
  bool onPlaybackUpdate({
    required Duration position,
    required Duration duration,
    bool playerReportedEnded = false,
  }) {
    if (_hasFired) return false;
    if (duration <= Duration.zero) return false;

    final remaining = duration - position;
    final reachedEnd =
        playerReportedEnded || remaining <= _tolerance && remaining >= Duration.zero;

    // Guard against a stray zero-duration/zero-position update racing in
    // before the player has actually loaded metadata.
    if (reachedEnd && position > Duration.zero) {
      _hasFired = true;
      return true;
    }
    return false;
  }

  /// Progress as a 0.0–1.0 fraction, safe against zero/unknown duration.
  static double progressFraction({
    required Duration position,
    required Duration duration,
  }) {
    if (duration <= Duration.zero) return 0.0;
    final fraction = position.inMilliseconds / duration.inMilliseconds;
    return fraction.clamp(0.0, 1.0);
  }

  void reset() => _hasFired = false;
}

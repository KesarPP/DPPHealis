import 'playback_coverage_tracker.dart';

/// Player-independent completion logic with optional verified watch-coverage tracking.
///
/// Kept separate from the YouTube widget on purpose: this class has no
/// dependency on youtube_player_iframe or any webview, so it can be unit
/// tested directly instead of relying on widget tests against an external player.
class VideoCompletionDetector {
  VideoCompletionDetector({
    Duration tolerance = const Duration(seconds: 2),
    bool enforceVerifiedCoverage = false,
  })  : _tolerance = tolerance,
        _enforceVerifiedCoverage = enforceVerifiedCoverage,
        _coverageTracker = PlaybackCoverageTracker(tolerance: tolerance);

  final Duration _tolerance;
  final bool _enforceVerifiedCoverage;
  final PlaybackCoverageTracker _coverageTracker;
  bool _hasFired = false;

  bool get hasFired => _hasFired;
  PlaybackCoverageTracker get coverageTracker => _coverageTracker;

  /// Feed this every position/duration update from the player.
  /// Returns true exactly once — the first time the video is judged to
  /// have reached its end — and false on every other call (including
  /// every call after that first true).
  ///
  /// A session is considered complete when:
  ///   - duration is known and greater than zero, AND
  ///   - position is within [_tolerance] of duration (or player reports ended),
  ///   - AND if [_enforceVerifiedCoverage] is enabled, the user has legitimately
  ///     streamed through the required video content without seek-to-end cheating.
  bool onPlaybackUpdate({
    required Duration position,
    required Duration duration,
    bool playerReportedEnded = false,
    bool isPlaying = true,
    DateTime? now,
  }) {
    if (_hasFired) return false;
    if (duration <= Duration.zero) return false;

    // Track coverage if enabled
    if (_enforceVerifiedCoverage) {
      _coverageTracker.recordPlayback(
        position: position,
        duration: duration,
        isPlaying: isPlaying,
        now: now,
      );

      final fullyWatched = _coverageTracker.isFullyWatched(
        duration: duration,
        currentPosition: position,
        playerReportedEnded: playerReportedEnded,
      );

      if (fullyWatched) {
        _hasFired = true;
        return true;
      }
      return false;
    }

    final remaining = duration - position;
    final reachedEnd =
        playerReportedEnded || (remaining <= _tolerance && remaining >= Duration.zero);

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

  void reset() {
    _hasFired = false;
    _coverageTracker.reset();
  }
}

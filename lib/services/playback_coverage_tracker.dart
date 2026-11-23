/// Represents a continuous interval of verified watched playback.
class CoverageInterval {
  const CoverageInterval(this.start, this.end);

  final Duration start;
  final Duration end;

  Duration get duration => end > start ? end - start : Duration.zero;

  bool overlapsOrTouches(CoverageInterval other, {Duration tolerance = const Duration(seconds: 1)}) {
    final s1 = start.inMilliseconds;
    final e1 = end.inMilliseconds;
    final s2 = other.start.inMilliseconds;
    final e2 = other.end.inMilliseconds;
    final tol = tolerance.inMilliseconds;

    return (s1 <= e2 + tol) && (s2 <= e1 + tol);
  }

  CoverageInterval merge(CoverageInterval other) {
    final s = start < other.start ? start : other.start;
    final e = end > other.end ? end : other.end;
    return CoverageInterval(s, e);
  }

  @override
  String toString() => '${start.inMilliseconds}-${end.inMilliseconds}';

  static CoverageInterval? fromString(String raw) {
    final parts = raw.split('-');
    if (parts.length != 2) return null;
    final s = int.tryParse(parts[0]);
    final e = int.tryParse(parts[1]);
    if (s == null || e == null) return null;
    return CoverageInterval(Duration(milliseconds: s), Duration(milliseconds: e));
  }
}

/// Robust watch-coverage tracker that prevents seek-to-end cheating.
///
/// Distinguishes between normal sequential playback and forward seeks.
/// When the user seeks forward across an unwatched gap, the skipped section
/// is NOT credited. To achieve full video completion, the user must actually
/// have played through the content sequentially.
class PlaybackCoverageTracker {
  PlaybackCoverageTracker({
    Duration tolerance = const Duration(seconds: 3),
  }) : _tolerance = tolerance;

  final Duration _tolerance;
  final List<CoverageInterval> _intervals = [];

  Duration? _lastPosition;
  DateTime? _lastTimestamp;
  bool _lastWasPlaying = false;

  List<CoverageInterval> get intervals => List.unmodifiable(_intervals);

  /// Total sum of all verified watched segments (without double-counting overlaps).
  Duration get totalWatchedDuration {
    var totalMs = 0;
    for (final interval in _intervals) {
      totalMs += interval.duration.inMilliseconds;
    }
    return Duration(milliseconds: totalMs);
  }

  /// Records a playback tick from the player.
  ///
  /// [position] is the player's current media position.
  /// [duration] is total video duration.
  /// [isPlaying] indicates whether the player is currently in PLAYING state.
  /// [now] can be injected for unit tests.
  void recordPlayback({
    required Duration position,
    required Duration duration,
    bool isPlaying = true,
    DateTime? now,
  }) {
    final currentNow = now ?? DateTime.now();

    if (duration <= Duration.zero) {
      _lastPosition = position;
      _lastTimestamp = currentNow;
      _lastWasPlaying = isPlaying;
      return;
    }

    if (_lastPosition != null && _lastTimestamp != null && _lastWasPlaying && isPlaying) {
      final realElapsed = currentNow.difference(_lastTimestamp!);
      final mediaDelta = position - _lastPosition!;

      // Normal playback allows media progression roughly proportional to real-time.
      // We grant up to 2.0x real time to allow for 1.25x/1.5x speed or network burst ticks,
      // plus a 1.5-second buffer for tick latency.
      final maxAllowedMediaDelta = Duration(
        milliseconds: (realElapsed.inMilliseconds * 2.0).round() + 1500,
      );

      if (mediaDelta >= Duration.zero && mediaDelta <= maxAllowedMediaDelta) {
        // Legitimate playback! Add the verified interval.
        _addInterval(CoverageInterval(_lastPosition!, position));
      } else if (mediaDelta > maxAllowedMediaDelta) {
        // Forward seek detected! The gap between _lastPosition and position
        // was NOT watched in real-time, so it is skipped.
      } else {
        // Backward seek / replay. The user wound back. Existing coverage is kept.
      }
    } else if (isPlaying && _lastPosition == null) {
      // Very first tick: if near start, seed interval from 0 to position.
      if (position <= const Duration(seconds: 2)) {
        _addInterval(CoverageInterval(Duration.zero, position));
      }
    }

    _lastPosition = position;
    _lastTimestamp = currentNow;
    _lastWasPlaying = isPlaying;
  }

  void _addInterval(CoverageInterval newInterval) {
    if (newInterval.duration <= Duration.zero) return;

    final toMerge = <CoverageInterval>[newInterval];
    final remaining = <CoverageInterval>[];

    for (final existing in _intervals) {
      if (existing.overlapsOrTouches(newInterval, tolerance: _tolerance)) {
        toMerge.add(existing);
      } else {
        remaining.add(existing);
      }
    }

    // Merge all overlapping
    var merged = toMerge.first;
    for (var i = 1; i < toMerge.length; i++) {
      merged = merged.merge(toMerge[i]);
    }

    remaining.add(merged);
    remaining.sort((a, b) => a.start.compareTo(b.start));

    _intervals
      ..clear()
      ..addAll(remaining);
  }

  /// Fraction of total duration verified as watched (0.0 to 1.0).
  double coverageFraction(Duration duration) {
    if (duration <= Duration.zero) return 0.0;
    final fraction = totalWatchedDuration.inMilliseconds / duration.inMilliseconds;
    return fraction.clamp(0.0, 1.0);
  }

  /// Full completion requires:
  /// 1. Valid duration > 0.
  /// 2. Total verified watched duration satisfies the full duration (within tolerance, or >= 95% coverage).
  /// 3. Current position or explicit end signal has reached the end.
  bool isFullyWatched({
    required Duration duration,
    Duration? currentPosition,
    bool playerReportedEnded = false,
  }) {
    if (duration <= Duration.zero) return false;

    final requiredCoverage = duration - _tolerance;
    final hasEnoughWatchedTime = totalWatchedDuration >= requiredCoverage ||
        coverageFraction(duration) >= 0.95;

    final reachedEnd = playerReportedEnded ||
        (currentPosition != null &&
            currentPosition >= (duration - _tolerance) &&
            currentPosition > Duration.zero);

    return hasEnoughWatchedTime && reachedEnd;
  }

  /// Serialize watched intervals for persistence across app restarts.
  String serialize() {
    return _intervals.map((i) => i.toString()).join(';');
  }

  /// Restore previously verified intervals from persisted string.
  void restoreFrom(String? serialized) {
    if (serialized == null || serialized.trim().isEmpty) return;
    _intervals.clear();
    final tokens = serialized.split(';');
    for (final token in tokens) {
      final interval = CoverageInterval.fromString(token.trim());
      if (interval != null) {
        _intervals.add(interval);
      }
    }
  }

  void reset() {
    _intervals.clear();
    _lastPosition = null;
    _lastTimestamp = null;
    _lastWasPlaying = false;
  }
}

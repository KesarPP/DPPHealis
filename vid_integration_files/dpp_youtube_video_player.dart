import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../models/dpp_session_video.dart';
import '../services/video_completion_detector.dart';

enum _PlayerLoadState { placeholder, loading, ready, error, offline }

/// Reusable HEALIS video player for a single DPP session.
///
/// One instance of this widget handles every session — only [sessionVideo]
/// changes between sessions. It:
///   - Shows a "coming soon" placeholder when [sessionVideo.isPlayable]
///     is false (placeholder ID or not yet marked available) — does NOT
///     attempt to initialize the YouTube player in that case.
///   - Otherwise initializes youtube_player_iframe, shows a loading
///     indicator, then the video.
///   - Tracks position/duration and calls [onProgressChanged] as it
///     changes.
///   - Calls [onVideoCompleted] exactly once when the video reaches its
///     end (with a small tolerance — see [VideoCompletionDetector]).
///   - Surfaces player errors as a clean retry state instead of a raw
///     technical error or a crash.
///
/// Wire this into the existing session UI wherever the current video
/// placeholder/container lives — it is a plain, theme-agnostic widget
/// that fills the space it's given, so it should drop into an existing
/// `AspectRatio`/`Card`/container without needing a redesign.
class DppYoutubeVideoPlayer extends StatefulWidget {
  const DppYoutubeVideoPlayer({
    super.key,
    required this.sessionVideo,
    this.autoPlay = false,
    this.showControls = true,
    this.onVideoCompleted,
    this.onProgressChanged,
  });

  final DppSessionVideo sessionVideo;

  /// Defaults to false — sessions should not autoplay.
  final bool autoPlay;

  final bool showControls;

  /// Called exactly once per viewing session, when playback reaches the
  /// end of the video.
  final VoidCallback? onVideoCompleted;

  /// Called whenever progress changes meaningfully.
  /// [progress] is 0.0–1.0.
  final ValueChanged<double>? onProgressChanged;

  @override
  State<DppYoutubeVideoPlayer> createState() => _DppYoutubeVideoPlayerState();
}

class _DppYoutubeVideoPlayerState extends State<DppYoutubeVideoPlayer> {
  YoutubePlayerController? _controller;
  StreamSubscription<YoutubeVideoState>? _stateSub;
  late VideoCompletionDetector _completionDetector;

  _PlayerLoadState _loadState = _PlayerLoadState.placeholder;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _completionDetector = VideoCompletionDetector();
    _initForCurrentSessionVideo();
  }

  @override
  void didUpdateWidget(covariant DppYoutubeVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionVideo.sessionId != widget.sessionVideo.sessionId ||
        oldWidget.sessionVideo.videoId != widget.sessionVideo.videoId) {
      _disposeController();
      _completionDetector = VideoCompletionDetector();
      _initForCurrentSessionVideo();
    }
  }

  void _initForCurrentSessionVideo() {
    final video = widget.sessionVideo;

    if (!video.isPlayable) {
      // Do not attempt to initialize the player for placeholder IDs or
      // sessions not yet marked available.
      setState(() => _loadState = _PlayerLoadState.placeholder);
      return;
    }

    setState(() => _loadState = _PlayerLoadState.loading);
    _createController(video.videoId);
  }

  void _createController(String videoId) {
    try {
      final controller = YoutubePlayerController(
        params: YoutubePlayerParams(
          showControls: widget.showControls,
          showFullscreenButton: true,
          playsInline: true,
          strictRelatedVideos: true,
          mute: false,
        ),
      );

      controller.loadVideoById(videoId: videoId);

      _stateSub = controller.videoStateStream.listen(
        _handleVideoState,
        onError: (_) => _handleError(),
      );

      _controller = controller;
      // First-frame/metadata arrival is signalled via the state stream;
      // flip to `ready` as soon as we get any state so the loading
      // indicator disappears once the iframe is actually up.
      setState(() => _loadState = _PlayerLoadState.ready);
    } catch (_) {
      _handleError();
    }
  }

  void _handleVideoState(YoutubeVideoState state) {
    final duration = state.metaData.duration;
    final position = state.position;

    if (duration > Duration.zero && widget.onProgressChanged != null) {
      final fraction = VideoCompletionDetector.progressFraction(
        position: position,
        duration: duration,
      );
      widget.onProgressChanged!(fraction);
    }

    final ended = state.playerState == PlayerState.ended;
    final justCompleted = _completionDetector.onPlaybackUpdate(
      position: position,
      duration: duration,
      playerReportedEnded: ended,
    );

    if (justCompleted) {
      widget.onVideoCompleted?.call();
    }
  }

  void _handleError() {
    if (!mounted) return;
    setState(() {
      _loadState = _PlayerLoadState.error;
      _errorMessage = 'Unable to load the session video.\n'
          'Please check your internet connection and try again.';
    });
  }

  void _retry() {
    _disposeController();
    _completionDetector.reset();
    _initForCurrentSessionVideo();
  }

  void _disposeController() {
    _stateSub?.cancel();
    _stateSub = null;
    _controller?.close();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loadState) {
      case _PlayerLoadState.placeholder:
        return _PlaceholderState(sessionVideo: widget.sessionVideo);
      case _PlayerLoadState.loading:
        return const _LoadingState();
      case _PlayerLoadState.error:
        return _ErrorState(message: _errorMessage!, onRetry: _retry);
      case _PlayerLoadState.offline:
        return _ErrorState(
          message: 'You appear to be offline.\n'
              'Connect to the internet to watch this session.',
          onRetry: _retry,
        );
      case _PlayerLoadState.ready:
        final controller = _controller;
        if (controller == null) return const _LoadingState();
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayer(controller: controller),
        );
    }
  }
}

class _PlaceholderState extends StatelessWidget {
  const _PlaceholderState({required this.sessionVideo});

  final DppSessionVideo sessionVideo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 40,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'Session video coming soon',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 16 / 9,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off, size: 32, color: theme.colorScheme.error),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

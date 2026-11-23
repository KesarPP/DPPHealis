import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../models/dpp_session_video.dart';
import '../data/dpp_session_videos.dart';
import '../services/video_completion_detector.dart';

enum _PlayerLoadState { placeholder, loading, ready, error, offline }

/// Lets a parent (e.g. the "Replay Session" button) trigger a replay or external launch on the active video player.
class DppPlayerHandle {
  Future<void> Function()? _replay;
  Future<void> Function()? _openExternal;

  bool get isAttached => _replay != null || _openExternal != null;

  Future<void> replay() async {
    if (_replay != null) {
      await _replay!();
    } else if (_openExternal != null) {
      await _openExternal!();
    }
  }
}

/// Reusable HEALIS embedded YouTube player for DPP sessions.
///
/// Features:
/// - Uses `youtube_player_iframe` for real in-app streaming.
/// - Integrated with `PlaybackCoverageTracker` via `VideoCompletionDetector`
///   to ensure legitimate continuous watching and prevent seek-to-end cheating.
/// - Safely shows a "Session video coming soon" placeholder for unconfigured/placeholder sessions
///   without initializing YouTube or causing crashes.
/// - Full lifecycle management: clean controller disposal, stream cancellation, 16:9 ratio.
class DppYoutubeVideoPlayer extends StatefulWidget {
  const DppYoutubeVideoPlayer({
    super.key,
    this.sessionVideo,
    this.videoId,
    this.isPlaceholder = false,
    this.sessionLabel,
    this.title,
    this.showBadges = true,
    this.autoPlay = false,
    this.showControls = true,
    this.handle,
    this.isCompleted = false,
    this.onCompleted,
    this.onVideoCompleted,
    this.onProgress,
    this.onProgressChanged,
  });

  final DppSessionVideo? sessionVideo;
  final String? videoId;
  final bool isPlaceholder;
  final String? sessionLabel;
  final String? title;
  final bool showBadges;
  final bool autoPlay;
  final bool showControls;
  final DppPlayerHandle? handle;
  final bool isCompleted;

  /// Called when verified playback reaches the end of the video.
  final VoidCallback? onCompleted;
  final VoidCallback? onVideoCompleted;

  /// Progress updates.
  final void Function(double position, double duration)? onProgress;
  final ValueChanged<double>? onProgressChanged;

  @override
  State<DppYoutubeVideoPlayer> createState() => _DppYoutubeVideoPlayerState();
}

class _DppYoutubeVideoPlayerState extends State<DppYoutubeVideoPlayer> {
  YoutubePlayerController? _controller;
  StreamSubscription<YoutubePlayerValue>? _valueSub;
  StreamSubscription<YoutubeVideoState>? _videoStateSub;
  late VideoCompletionDetector _completionDetector;

  Duration _currentDuration = Duration.zero;
  PlayerState _currentPlayerState = PlayerState.unknown;

  _PlayerLoadState _loadState = _PlayerLoadState.placeholder;
  String? _errorMessage;

  DppSessionVideo get _resolvedSessionVideo {
    if (widget.sessionVideo != null) return widget.sessionVideo!;
    final vid = widget.videoId ?? '';
    final found = dppSessionVideos.where((v) => v.videoId == vid).firstOrNull;
    if (found != null) return found;

    return DppSessionVideo(
      sessionId: 'custom_video',
      title: widget.title ?? 'Session Video',
      videoId: vid,
      order: 1,
      isAvailable: !widget.isPlaceholder && vid.isNotEmpty && !vid.startsWith('PLACEHOLDER_'),
    );
  }

  bool get _isPlayable => _resolvedSessionVideo.isPlayable && !widget.isPlaceholder;

  @override
  void initState() {
    super.initState();
    _completionDetector = VideoCompletionDetector(
      tolerance: const Duration(seconds: 3),
      enforceVerifiedCoverage: true,
    );
    _attachHandle();
    _initForCurrentSessionVideo();
  }

  void _attachHandle() {
    if (widget.handle != null) {
      widget.handle!._replay = _replay;
      widget.handle!._openExternal = _openExternalVideo;
    }
  }

  @override
  void didUpdateWidget(covariant DppYoutubeVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.handle != widget.handle) {
      oldWidget.handle?._replay = null;
      oldWidget.handle?._openExternal = null;
      _attachHandle();
    }

    final oldVid = oldWidget.sessionVideo?.videoId ?? oldWidget.videoId;
    final newVid = widget.sessionVideo?.videoId ?? widget.videoId;
    if (oldVid != newVid) {
      _disposeController();
      _completionDetector = VideoCompletionDetector(
        tolerance: const Duration(seconds: 3),
        enforceVerifiedCoverage: true,
      );
      _initForCurrentSessionVideo();
    }
  }

  Future<void> _openExternalVideo() async {
    final videoId = _resolvedSessionVideo.videoId;
    if (videoId.isEmpty || widget.isPlaceholder || videoId.startsWith('PLACEHOLDER_')) {
      return;
    }
    final uri = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(uri)) {
      // External YouTube playback is unverified.
      // It must strictly be viewing-only and CANNOT grant completion or unlock levels.
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _initForCurrentSessionVideo() {
    if (!_isPlayable) {
      setState(() => _loadState = _PlayerLoadState.placeholder);
      return;
    }

    setState(() => _loadState = _PlayerLoadState.loading);
    _createController(_resolvedSessionVideo.videoId);
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

      if (widget.autoPlay) {
        controller.loadVideoById(videoId: videoId);
      } else {
        controller.cueVideoById(videoId: videoId);
      }

      _valueSub = controller.stream.listen(
        (value) {
          if (value.metaData.duration > Duration.zero) {
            _currentDuration = value.metaData.duration;
          }
          _currentPlayerState = value.playerState;

          if (value.hasError) {
            _handleError();
          }
        },
        onError: (_) => _handleError(),
      );

      _videoStateSub = controller.videoStateStream.listen(
        _handleVideoState,
        onError: (_) => _handleError(),
      );

      _controller = controller;
      if (mounted) {
        setState(() => _loadState = _PlayerLoadState.ready);
      }
    } catch (_) {
      _handleError();
    }
  }

  void _handleVideoState(YoutubeVideoState state) {
    var duration = _currentDuration;
    if (duration <= Duration.zero && _resolvedSessionVideo.duration != null) {
      duration = _resolvedSessionVideo.duration!;
    }

    final position = state.position;
    final isPlaying = _currentPlayerState == PlayerState.playing;
    final isEnded = _currentPlayerState == PlayerState.ended;

    if (duration > Duration.zero) {
      final posSec = position.inMilliseconds / 1000.0;
      final durSec = duration.inMilliseconds / 1000.0;
      widget.onProgress?.call(posSec, durSec);

      final fraction = VideoCompletionDetector.progressFraction(
        position: position,
        duration: duration,
      );
      widget.onProgressChanged?.call(fraction);
    }

    final justCompleted = _completionDetector.onPlaybackUpdate(
      position: position,
      duration: duration,
      playerReportedEnded: isEnded,
      isPlaying: isPlaying,
    );

    if (justCompleted) {
      widget.onCompleted?.call();
      widget.onVideoCompleted?.call();
    }
  }

  Future<void> _replay() async {
    final controller = _controller;
    if (controller != null) {
      await controller.seekTo(seconds: 0.0);
      await controller.playVideo();
    }
  }

  void _handleError() {
    if (!mounted) return;
    setState(() {
      _loadState = _PlayerLoadState.error;
      _errorMessage = 'Unable to stream session video.\n'
          'Please verify your internet connection and try again.';
    });
  }

  void _retry() {
    _disposeController();
    _completionDetector.reset();
    _initForCurrentSessionVideo();
  }

  void _disposeController() {
    _valueSub?.cancel();
    _valueSub = null;
    _videoStateSub?.cancel();
    _videoStateSub = null;
    _controller?.close();
    _controller = null;
  }

  @override
  void dispose() {
    widget.handle?._replay = null;
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loadState) {
      case _PlayerLoadState.placeholder:
        return _PlaceholderState(
          sessionLabel: widget.sessionLabel ?? 'Session ${_resolvedSessionVideo.order}',
          title: widget.title ?? _resolvedSessionVideo.title,
          isCompleted: widget.isCompleted,
        );
      case _PlayerLoadState.loading:
        return const _LoadingState();
      case _PlayerLoadState.error:
      case _PlayerLoadState.offline:
        return _VideoFallbackCard(
          sessionVideo: _resolvedSessionVideo,
          sessionLabel: widget.sessionLabel ?? 'Session ${_resolvedSessionVideo.order}',
          title: widget.title ?? _resolvedSessionVideo.title,
          onWatchOnYoutube: _openExternalVideo,
          onRetry: _retry,
          isCompleted: widget.isCompleted,
        );
      case _PlayerLoadState.ready:
        final controller = _controller;
        if (controller == null) return const _LoadingState();
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                YoutubePlayer(controller: controller),
                if (widget.isCompleted)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF81C784), width: 1),
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'COMPLETED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
    }
  }
}

class _PlaceholderState extends StatelessWidget {
  const _PlaceholderState({
    required this.sessionLabel,
    required this.title,
    this.isCompleted = false,
  });

  final String sessionLabel;
  final String title;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2E3D2F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF81C784), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.schedule_rounded,
              color: const Color(0xFF81C784),
              size: 38,
            ),
            const SizedBox(height: 8),
            Text(
              sessionLabel,
              style: const TextStyle(
                color: Color(0xFF81C784),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isCompleted ? 'Completed' : 'Video coming soon',
                style: const TextStyle(
                  color: Color(0xFFE0E0E0),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E281F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF81C784)),
              ),
              SizedBox(height: 12),
              Text(
                'Loading session video...',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A1C1C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
                const SizedBox(height: 4),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
                const SizedBox(height: 6),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF81C784),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoFallbackCard extends StatelessWidget {
  const _VideoFallbackCard({
    required this.sessionVideo,
    required this.sessionLabel,
    required this.title,
    required this.onWatchOnYoutube,
    required this.onRetry,
    this.isCompleted = false,
  });

  final DppSessionVideo sessionVideo;
  final String sessionLabel;
  final String title;
  final VoidCallback onWatchOnYoutube;
  final VoidCallback onRetry;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final videoId = sessionVideo.videoId;
    final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail image background
            Image.network(
              thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF1E281F),
                child: const Center(
                  child: Icon(Icons.play_circle_fill_rounded, color: Color(0xFF81C784), size: 48),
                ),
              ),
            ),

            // Gradient tint
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000000),
                    Color(0x22000000),
                    Color(0xAA000000),
                  ],
                ),
              ),
            ),

            // Session badge at top left
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF81C784), width: 1),
                ),
                child: Text(
                  sessionLabel.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF81C784),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),

            // Completed badge at top right if already finished
            if (isCompleted)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF81C784), width: 1),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'COMPLETED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Centered Play Button
            Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onWatchOnYoutube,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 58,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0000),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom bar with action pills (Watch on YouTube + Retry)
            Positioned(
              left: 10,
              right: 10,
              bottom: 8,
              child: Row(
                children: [
                  // Watch on YouTube button
                  Expanded(
                    child: GestureDetector(
                      onTap: onWatchOnYoutube,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF81C784),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.open_in_new_rounded, size: 13, color: Color(0xFF1B3D2F)),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Watch on YouTube',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF1B3D2F),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Retry button
                  GestureDetector(
                    onTap: onRetry,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white38, width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded, size: 13, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Retry',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tap surface over the whole card
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onWatchOnYoutube,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

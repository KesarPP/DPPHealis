import 'package:flutter/material.dart';

import '../models/dpp_session_video.dart';
import '../services/session_video_progress_service.dart';
import '../widgets/dpp_youtube_video_player.dart';

/// Screen wrapper around [DppYoutubeVideoPlayer] for a single session.
///
/// Serves as a fallback standalone screen for watching a session video.
class SessionVideoScreen extends StatefulWidget {
  const SessionVideoScreen({
    super.key,
    required this.sessionVideo,
    required this.progressService,
    this.onSessionCompleted,
  });

  final DppSessionVideo sessionVideo;

  /// Inject the app-wide instance of this service rather than creating a new
  /// one per screen, so completion state is shared app-wide.
  final SessionVideoProgressService progressService;

  /// Called after the video reaches completion AND the completion has
  /// been persisted. Hook this into the existing session unlock system.
  final VoidCallback? onSessionCompleted;

  @override
  State<SessionVideoScreen> createState() => _SessionVideoScreenState();
}

class _SessionVideoScreenState extends State<SessionVideoScreen> {
  @override
  void initState() {
    super.initState();
    widget.progressService.load(widget.sessionVideo.sessionId);
  }

  Future<void> _handleCompleted() async {
    await widget.progressService.markCompleted(widget.sessionVideo.sessionId);
    widget.onSessionCompleted?.call();
  }

  Future<void> _handleProgress(double progress) async {
    await widget.progressService
        .updateProgress(widget.sessionVideo.sessionId, progress);
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.sessionVideo;

    return Scaffold(
      appBar: AppBar(title: Text(video.title)),
      body: ListenableBuilder(
        listenable: widget.progressService,
        builder: (context, _) {
          final progress =
              widget.progressService.progressFor(video.sessionId);
          final completed =
              widget.progressService.isCompleted(video.sessionId);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DppYoutubeVideoPlayer(
                  sessionVideo: video,
                  videoId: video.videoId,
                  isPlaceholder: !video.isPlayable,
                  isCompleted: completed,
                  onCompleted: _handleCompleted,
                  onProgress: (pos, dur) {
                    if (dur > 0) {
                      _handleProgress(pos / dur);
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (video.description != null) ...[
                        Text(
                          video.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                      ],
                      LinearProgressIndicator(value: progress),
                      const SizedBox(height: 4),
                      Text(
                        completed
                            ? 'Completed'
                            : '${(progress * 100).round()}% watched',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

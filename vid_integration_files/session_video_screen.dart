import 'package:flutter/material.dart';

import '../models/dpp_session_video.dart';
import '../services/session_video_progress_service.dart';
import '../widgets/dpp_youtube_video_player.dart';

/// Screen wrapper around [DppYoutubeVideoPlayer] for a single session.
///
/// Only use this if the existing session screen doesn't already have a
/// dedicated video area to embed [DppYoutubeVideoPlayer] into directly —
/// if it does, prefer dropping the player widget straight into that
/// existing screen instead of introducing a second navigation hop.
///
/// This screen intentionally does NOT reimplement handouts/quiz/weigh-in/
/// meal-log/activity — it exposes `onVideoCompleted`-driven state so the
/// existing session flow's unlock logic can react to it. Pass a callback
/// through [onSessionCompleted] and forward it into whatever the existing
/// unlock system already uses (a provider, a bloc event, a Firestore
/// write, etc).
class SessionVideoScreen extends StatefulWidget {
  const SessionVideoScreen({
    super.key,
    required this.sessionVideo,
    required this.progressService,
    this.onSessionCompleted,
  });

  final DppSessionVideo sessionVideo;

  /// Inject the app-wide instance of this service (e.g. from your
  /// existing DI / Provider / Riverpod setup) rather than creating a new
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
                  onVideoCompleted: _handleCompleted,
                  onProgressChanged: _handleProgress,
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
                      // Existing session actions (handouts, quiz,
                      // weigh-in, meal log, activity) should render below
                      // here, reusing whatever widgets the current
                      // session screen already has for them, gated on
                      // `completed` per the existing unlock logic.
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

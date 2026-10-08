// lib/widgets/dpp_youtube_video_player.dart  (REPLACES the embedded-player version)
//
// Simple video holder: shows the video's thumbnail with a YouTube-style play
// button. Tapping it opens the video in the YouTube app (or the browser).
// No embedded player, no WebView, no fullscreen/speed controls.
//
// Same class name and constructor as before, so ManuscriptScreen needs no changes.
// Only dependency: url_launcher.
//
// NOTE: because playback happens in YouTube, the app can no longer tell when the
// video has finished, so `onCompleted` and `onProgress` are accepted but never called.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _kPink = Color(0xFFF06292);
const _kInk = Color(0xFF3E4A3D);

/// Lets a parent (e.g. the "Replay Session" button) trigger the same action as
/// tapping the video: open it on YouTube.
class DppPlayerHandle {
  Future<void> Function()? _open;

  bool get isAttached => _open != null;

  Future<void> replay() async => _open?.call();
}

/// Accepts a bare 11-character ID or any common YouTube link
/// (watch?v=, youtu.be/, shorts/, embed/, "?si=" suffixes, stray spaces).
String? _normalizeYoutubeId(String raw) {
  final clean = RegExp(r'^[A-Za-z0-9_-]{11}$');
  final s = raw.trim();
  if (clean.hasMatch(s)) return s;

  final uri = Uri.tryParse(s);
  if (uri == null) return null;

  String? candidate;
  if (uri.host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
    candidate = uri.pathSegments.first;
  } else if (uri.queryParameters['v'] != null) {
    candidate = uri.queryParameters['v'];
  } else if (uri.pathSegments.length >= 2 &&
      const {'shorts', 'embed', 'live', 'v'}.contains(uri.pathSegments.first)) {
    candidate = uri.pathSegments[1];
  }
  return (candidate != null && clean.hasMatch(candidate)) ? candidate : null;
}

class DppYoutubeVideoPlayer extends StatefulWidget {
  const DppYoutubeVideoPlayer({
    super.key,
    required this.videoId,
    this.isPlaceholder = false,
    this.sessionLabel,
    this.title,
    this.showBadges = true,
    this.handle,
    this.onCompleted, // kept for compatibility; never called
    this.onProgress, // kept for compatibility; never called
  });

  final String videoId;
  final bool isPlaceholder;
  final String? sessionLabel;
  final String? title;
  final bool showBadges;
  final DppPlayerHandle? handle;
  final VoidCallback? onCompleted;
  final void Function(double position, double duration)? onProgress;

  @override
  State<DppYoutubeVideoPlayer> createState() => _DppYoutubeVideoPlayerState();
}

class _DppYoutubeVideoPlayerState extends State<DppYoutubeVideoPlayer> {
  String? get _id => _normalizeYoutubeId(widget.videoId);

  bool get _isPlaceholderState =>
      widget.isPlaceholder || widget.videoId.trim().isEmpty;

  bool get _canOpen => !_isPlaceholderState && _id != null;

  @override
  void initState() {
    super.initState();
    widget.handle?._open = _openYoutube;
  }

  @override
  void didUpdateWidget(covariant DppYoutubeVideoPlayer old) {
    super.didUpdateWidget(old);
    if (old.handle != widget.handle) {
      old.handle?._open = null;
      widget.handle?._open = _openYoutube;
    }
  }

  @override
  void dispose() {
    widget.handle?._open = null;
    super.dispose();
  }

  Future<void> _openYoutube() async {
    final id = _id;
    if (id == null || _isPlaceholderState) return;
    final opened = await launchUrl(
      Uri.parse('https://www.youtube.com/watch?v=$id'),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text("Couldn't open YouTube on this device.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.sessionLabel != null || widget.title != null) _header(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF8BBD0), Color(0xFFFFCCBC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _kPink.withValues(alpha: 0.25),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.5),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _canOpen ? _thumbnailWithPlay() : _unavailable(),
                  ),
                ),
              ),
              if (widget.showBadges) ...[
                const Positioned(
                    top: -14,
                    left: -12,
                    child: _Badge(icon: Icons.apple, color: Color(0xFFE53935))),
                const Positioned(
                    top: -14,
                    right: -12,
                    child: _Badge(
                        icon: Icons.monitor_heart_outlined,
                        color: Color(0xFFEC407A))),
                const Positioned(
                    bottom: -14,
                    left: -12,
                    child: _Badge(
                        icon: Icons.fitness_center,
                        color: Color(0xFF29B6F6))),
                const Positioned(
                    bottom: -14,
                    right: -12,
                    child: _Badge(
                        icon: Icons.monitor_weight_outlined,
                        color: Color(0xFFAB47BC))),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _thumbnailWithPlay() {
    final id = _id!;
    return Semantics(
      button: true,
      label: 'Watch the session video on YouTube',
      child: Stack(
        fit: StackFit.expand,
        children: [
          // hqdefault.jpg exists for every video (maxresdefault does not).
          Image.network(
            'https://img.youtube.com/vi/$id/hqdefault.jpg',
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : const ColoredBox(color: Colors.black87),
            errorBuilder: (context, error, stack) =>
                const ColoredBox(color: Colors.black87),
          ),
          // Soft dark wash so the play button always stands out.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x14000000), Color(0x66000000)],
              ),
            ),
          ),
          // YouTube-style play button.
          Center(
            child: Container(
              width: 68,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFF0000),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 12,
                      offset: Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 36),
            ),
          ),
          // Hint pill.
          Positioned(
            left: 10,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.open_in_new, size: 11, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Watch on YouTube',
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ],
              ),
            ),
          ),
          // Tap target over everything, with a ripple.
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: _openYoutube),
            ),
          ),
        ],
      ),
    );
  }

  Widget _unavailable() {
    final text = _isPlaceholderState
        ? 'Video coming soon for this session'
        : 'This session\'s video link is not valid';
    return Container(
      color: const Color(0xFFFCE4EC),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam_off_outlined,
                  size: 30, color: Colors.pink.shade300),
              const SizedBox(height: 6),
              Text(text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _kInk, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
      child: Row(
        children: [
          if (widget.sessionLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.sessionLabel!.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF558B2F),
                ),
              ),
            ),
          if (widget.title != null) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: _kInk, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

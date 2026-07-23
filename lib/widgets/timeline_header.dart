import 'package:flutter/material.dart';
import '../theme/manuscript_theme.dart';

/// Ornate header for the Session Timeline page: title, subtitle, and a
/// decorative divider. Fades and slides in on first build.
class TimelineHeader extends StatefulWidget {
  final VoidCallback? onCloseBook;

  const TimelineHeader({super.key, this.onCloseBook});

  @override
  State<TimelineHeader> createState() => _TimelineHeaderState();
}

class _TimelineHeaderState extends State<TimelineHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: ManuscriptMotion.cardEntrance,
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: ManuscriptMotion.entranceCurve,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(_fade);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              if (widget.onCloseBook != null) ...[
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: widget.onCloseBook,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: ManuscriptColors.darkWood.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: ManuscriptColors.gold, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_stories_rounded, color: ManuscriptColors.gold, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Close Book',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: ManuscriptColors.gold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const Text(
                'Your Session Guide',
                textAlign: TextAlign.center,
                style: ManuscriptTextStyles.pageTitle,
              ),
              const SizedBox(height: 8),
              const Text(
                'Complete each chapter to continue your wellness journey.',
                textAlign: TextAlign.center,
                style: ManuscriptTextStyles.pageSubtitle,
              ),
              const SizedBox(height: 18),
              const _OrnateDivider(),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrnateDivider extends StatelessWidget {
  const _OrnateDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _DividerLine(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.auto_awesome, size: 16, color: ManuscriptColors.gold),
        ),
        _DividerLine(),
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 1.2,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, ManuscriptColors.gold],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/manuscript_theme.dart';

/// Ornate header for the Session Timeline page: title, subtitle, and a
/// decorative divider. Fades and slides in on first build.
class TimelineHeader extends StatefulWidget {
  const TimelineHeader({super.key});

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
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            children: [
              Text(
                'Your Session Guide',
                textAlign: TextAlign.center,
                style: ManuscriptTextStyles.pageTitle,
              ),
              SizedBox(height: 8),
              Text(
                'Complete each chapter to continue your wellness journey.',
                textAlign: TextAlign.center,
                style: ManuscriptTextStyles.pageSubtitle,
              ),
              SizedBox(height: 18),
              _OrnateDivider(),
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

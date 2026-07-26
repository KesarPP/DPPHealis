import 'package:flutter/material.dart';
import '../painters/glowing_path_painter.dart';
import '../theme/manuscript_theme.dart';

/// Drives [GlowingPathPainter] with a looping animation so a soft golden
/// light continuously travels along the manuscript trail connecting week
/// cards.
class GlowingPath extends StatefulWidget {
  final List<Offset> anchors;
  final Size canvasSize;
  final double revealFraction;

  const GlowingPath({
    super.key,
    required this.anchors,
    required this.canvasSize,
    this.revealFraction = 1.0,
  });

  @override
  State<GlowingPath> createState() => _GlowingPathState();
}

class _GlowingPathState extends State<GlowingPath>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: ManuscriptMotion.pathShimmer,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: widget.canvasSize,
            painter: GlowingPathPainter(
              anchors: widget.anchors,
              progress: _controller.value,
              revealFraction: widget.revealFraction,
            ),
          );
        },
      ),
    );
  }
}

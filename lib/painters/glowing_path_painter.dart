import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/manuscript_theme.dart';

/// Paints the winding, glowing manuscript trail that connects each week's
/// chapter card. The path smoothly S-curves between the supplied [anchors]
/// and animates a traveling point of light along its length driven by
/// [progress] (0.0 - 1.0, expected to loop via a repeating controller).
class GlowingPathPainter extends CustomPainter {
  final List<Offset> anchors;
  final double progress;

  /// Fraction of the path (0.0 - 1.0) that is drawn/"unlocked". Defaults to
  /// fully drawn; pass a lower value to visually gate the trail at the
  /// user's current chapter.
  final double revealFraction;

  GlowingPathPainter({
    required this.anchors,
    required this.progress,
    this.revealFraction = 1.0,
  });

  Path _buildFullPath() {
    final path = Path();
    if (anchors.isEmpty) return path;
    path.moveTo(anchors.first.dx, anchors.first.dy);

    for (var i = 0; i < anchors.length - 1; i++) {
      final start = anchors[i];
      final end = anchors[i + 1];
      final midY = (start.dy + end.dy) / 2;
      final controlPoint1 = Offset(start.dx, midY);
      final controlPoint2 = Offset(end.dx, midY);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        end.dx,
        end.dy,
      );
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (anchors.length < 2) return;

    final metrics = _buildFullPath().computeMetrics().toList();
    if (metrics.isEmpty) return;

    final totalLength = metrics.fold<double>(0, (sum, m) => sum + m.length);
    final revealLength = totalLength * revealFraction.clamp(0.0, 1.0);
    final visiblePath = _extractPath(metrics, revealLength);

    // Soft glow underlay.
    final glowPaint = Paint()
      ..color = ManuscriptColors.gold.withOpacity(0.35)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(visiblePath, glowPaint);

    // Crisp bronze base line.
    final basePaint = Paint()
      ..color = ManuscriptColors.bronze.withOpacity(0.85)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(visiblePath, basePaint);

    // Dashed gold overlay for a manuscript-trail texture.
    _drawDashedOverlay(canvas, visiblePath);

    // Traveling light along the revealed path.
    _drawTravelingLight(canvas, metrics, revealLength);
  }

  Path _extractPath(List<PathMetric> metrics, double revealLength) {
    final result = Path();
    var remaining = revealLength;
    for (final metric in metrics) {
      if (remaining <= 0) break;
      final take = remaining >= metric.length ? metric.length : remaining;
      result.addPath(metric.extractPath(0, take), Offset.zero);
      remaining -= metric.length;
    }
    return result;
  }

  void _drawDashedOverlay(Canvas canvas, Path path) {
    const dashLength = 6.0;
    const gapLength = 6.0;
    final dashPaint = Paint()
      ..color = ManuscriptColors.goldLight.withOpacity(0.9)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), dashPaint);
        distance += dashLength + gapLength;
      }
    }
  }

  void _drawTravelingLight(
    Canvas canvas,
    List<PathMetric> metrics,
    double revealLength,
  ) {
    if (revealLength <= 0) return;
    final targetDistance = (progress % 1.0) * revealLength;

    var walked = 0.0;
    for (final metric in metrics) {
      if (targetDistance <= walked + metric.length) {
        final tangent = metric.getTangentForOffset(targetDistance - walked);
        if (tangent != null) {
          final glowPaint = Paint()
            ..color = ManuscriptColors.goldLight.withOpacity(0.9)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
          canvas.drawCircle(tangent.position, 9, glowPaint);

          final corePaint = Paint()..color = Colors.white.withOpacity(0.95);
          canvas.drawCircle(tangent.position, 3.5, corePaint);
        }
        break;
      }
      walked += metric.length;
    }
  }

  @override
  bool shouldRepaint(covariant GlowingPathPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.anchors != anchors ||
        oldDelegate.revealFraction != revealFraction;
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/manuscript_theme.dart';

/// Lightweight ambient "dust of magic" particle field. Purely decorative
/// and intentionally cheap to paint — a handful of soft, slow-drifting
/// dots rather than a full physics simulation, to keep scrolling smooth.
class FloatingParticles extends StatefulWidget {
  final int count;
  final Size areaSize;

  const FloatingParticles({
    super.key,
    this.count = 18,
    required this.areaSize,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _ParticleSpec {
  final double startX;
  final double startY;
  final double radius;
  final double driftX;
  final double phaseOffset;
  final double opacity;

  _ParticleSpec({
    required this.startX,
    required this.startY,
    required this.radius,
    required this.driftX,
    required this.phaseOffset,
    required this.opacity,
  });
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ParticleSpec> _particles;

  @override
  void initState() {
    super.initState();
    // Fixed seed keeps particle layout stable across rebuilds.
    final random = Random(42);
    final safeWidth = widget.areaSize.width > 0 ? widget.areaSize.width : 1.0;
    final safeHeight = widget.areaSize.height > 0 ? widget.areaSize.height : 1.0;

    _particles = List.generate(widget.count, (_) {
      return _ParticleSpec(
        startX: random.nextDouble() * safeWidth,
        startY: random.nextDouble() * safeHeight,
        radius: 1.2 + random.nextDouble() * 2.2,
        driftX: 8 + random.nextDouble() * 14,
        phaseOffset: random.nextDouble() * 2 * pi,
        opacity: 0.2 + random.nextDouble() * 0.35,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: ManuscriptMotion.particleCycle,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: widget.areaSize,
              painter: _ParticlePainter(
                particles: _particles,
                t: _controller.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_ParticleSpec> particles;
  final double t;

  _ParticlePainter({required this.particles, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 0) return;
    for (final p in particles) {
      final angle = t * 2 * pi + p.phaseOffset;
      final dx = p.startX + sin(angle) * p.driftX;
      final rawY = p.startY - (t * size.height * 0.15) % size.height;
      final dy = rawY < 0 ? rawY + size.height : rawY;

      final paint = Paint()
        ..color = ManuscriptColors.goldLight.withOpacity(p.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(Offset(dx, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}

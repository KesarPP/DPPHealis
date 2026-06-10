import 'dart:math' as math;
import 'package:flutter/material.dart';

class MotivationSection extends StatefulWidget {
  const MotivationSection({super.key});

  @override
  State<MotivationSection> createState() => _MotivationSectionState();
}

class _MotivationSectionState extends State<MotivationSection>
    with TickerProviderStateMixin {
  late AnimationController _flameController;
  late Animation<double> _flameAnim;
  late AnimationController _particleController;

  final List<String> _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final List<bool> _activeDays = [true, true, true, true, true, false, false];
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _flameAnim = Tween<double>(begin: 0.92, end: 1.1).animate(
      CurvedAnimation(parent: _flameController, curve: Curves.easeInOut),
    );

    // Particle update controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _particleController.addListener(_updateParticles);
  }

  @override
  void dispose() {
    _flameController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _updateParticles() {
    if (!mounted) return;
    setState(() {
      for (int i = _particles.length - 1; i >= 0; i--) {
        final p = _particles[i];
        p.life -= 0.025;
        p.x += p.vx;
        p.y += p.vy;
        p.vy -= 0.05; // float upwards acceleration
        if (p.life <= 0) {
          _particles.removeAt(i);
        }
      }
    });

    if (_particles.isEmpty) {
      _particleController.stop();
    }
  }

  void _spawnParticles(Offset position) {
    setState(() {
      for (int i = 0; i < 20; i++) {
        final double angle = _random.nextDouble() * 2 * math.pi;
        final double speed = _random.nextDouble() * 2.5 + 0.5;
        _particles.add(
          _Particle(
            x: position.dx,
            y: position.dy,
            vx: math.cos(angle) * speed,
            vy: math.sin(angle) * speed - 1.5, // bias upwards
            life: _random.nextDouble() * 0.4 + 0.6,
            color: _random.nextBool()
                ? const Color(0xFFF97316) // Orange
                : const Color(0xFFEF4444), // Red
            size: _random.nextDouble() * 5.0 + 3.0,
          ),
        );
      }
    });
    if (!_particleController.isAnimating) {
      _particleController.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          // Streak card
          GestureDetector(
            onTapDown: (details) => _spawnParticles(details.localPosition),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          AnimatedBuilder(
                            animation: _flameAnim,
                            builder: (context, child) => Transform.scale(
                              scale: _flameAnim.value,
                              child: const Text(
                                '🔥',
                                style: TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Your Streak',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E293B),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Text(
                        '12',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                          height: 1,
                        ),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Days',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF334155),
                            ),
                          ),
                          Text(
                            'Keep the momentum going!',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Day indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _days.asMap().entries.map((entry) {
                      final active = _activeDays[entry.key];
                      return Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFFFFF7ED)
                                  : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: active
                                    ? const Color(0xFFF97316)
                                    : const Color(0xFFE2E8F0),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                active ? '🔥' : '○',
                                style: TextStyle(
                                  fontSize: active ? 14 : 12,
                                  color: active ? null : const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 10,
                              color: active
                                  ? const Color(0xFFF97316)
                                  : const Color(0xFF64748B),
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Particle overlay painter
          if (_particles.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ParticlePainter(particles: _particles),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  final Color color;
  final double size;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.color,
    required this.size,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;

  _ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.life)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.size * p.life, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}

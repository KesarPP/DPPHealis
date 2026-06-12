import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';

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

  // Vibrant streak colors (popping red-orange)
  static const Color streakColor = Color(0xFFFF4D00);
  static const Color streakBg = Color(0xFFFFE5D9);
  static const Color streakColorSecondary = Color(0xFFFF1A40);

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
            color: _random.nextBool() ? streakColor : streakColorSecondary,
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
                borderRadius: GelatoTheme.cardRadius,
                border: GelatoTheme.cardBorder,
                boxShadow: GelatoTheme.cardShadow,
                color: GelatoTheme.orange,
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
                              child: const Icon(
                                Icons.local_fire_department_rounded,
                                color: streakColor,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Consistency Streak',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.textDark,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: GelatoTheme.green,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black87, width: 1.5),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Level 3',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: GelatoTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Stack(
                        children: [
                          Text(
                            '12',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              height: 1,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2.0
                                ..color = GelatoTheme.orangeDark,
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFF97316), Color(0xFFF59E0B), Color(0xFFFFE066)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: const Text(
                              '12',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Days Active',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: GelatoTheme.textDark,
                              ),
                            ),
                            Text(
                              "You're on fire! Keep logging your progress.",
                              style: TextStyle(
                                fontSize: 11,
                                color: GelatoTheme.textLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
                            decoration: active
                                ? BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFEA580C), Color(0xFFF97316), Color(0xFFFBBF24)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFEA580C).withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      )
                                    ],
                                  )
                                : BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black87,
                                      width: 1.5,
                                    ),
                                  ),
                            child: Center(
                              child: Icon(
                                active
                                    ? Icons.local_fire_department_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                size: active ? 16 : 12,
                                color: active ? Colors.white : GelatoTheme.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 10,
                              color: active ? GelatoTheme.orangeBright : GelatoTheme.textLight,
                              fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  // Bottom Reward Info
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '2 days remaining to hit milestone',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: GelatoTheme.textLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+150 XP PENDING',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: GelatoTheme.orangeBright,
                          ),
                        ),
                      ],
                    ),
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

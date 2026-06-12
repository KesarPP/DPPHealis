import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../data/gelato_theme.dart';

class DailyGoals extends StatefulWidget {
  const DailyGoals({super.key});

  @override
  State<DailyGoals> createState() => _DailyGoalsState();
}

class _DailyGoalsState extends State<DailyGoals>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  late AnimationController _particleController;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();
  late AnimationController _rotationController;

  // Mutable progress state starting with the design spec values
  final Map<String, double> _progressValues = {
    'Steps': 0.68,
    'Calories': 0.82,
    'Active Minutes': 0.80,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _controller.forward();
    });

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _particleController.addListener(_updateParticles);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    _rotationController.dispose();
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
        p.vy -= 0.04; // float upwards acceleration
        if (p.life <= 0) {
          _particles.removeAt(i);
        }
      }
    });

    if (_particles.isEmpty) {
      _particleController.stop();
    }
  }

  void _spawnParticles(Offset position, Color color) {
    setState(() {
      for (int i = 0; i < 15; i++) {
        final double angle = _random.nextDouble() * 2 * math.pi;
        final double speed = _random.nextDouble() * 2.0 + 0.5;
        _particles.add(
          _Particle(
            x: position.dx,
            y: position.dy,
            vx: math.cos(angle) * speed,
            vy: math.sin(angle) * speed - 1.2, // float upwards bias
            life: _random.nextDouble() * 0.4 + 0.6,
            color: color,
            size: _random.nextDouble() * 4.5 + 2.5,
          ),
        );
      }
    });
    if (!_particleController.isAnimating) {
      _particleController.repeat();
    }
  }

  void _incrementGoal(String label, Offset localPosition, Color particleColor) {
    final currentVal = _progressValues[label] ?? 0.0;
    _spawnParticles(localPosition, particleColor);
    
    if (currentVal >= 1.0) {
      HapticFeedback.vibrate();
      setState(() {
        _progressValues[label] = 0.0;
      });
    } else {
      HapticFeedback.mediumImpact();
      setState(() {
        _progressValues[label] = (currentVal + 0.10).clamp(0.0, 1.0);
        if (_progressValues[label]! >= 1.0) {
          // Celebratory haptics when reaching 100%
          HapticFeedback.lightImpact();
          Future.delayed(const Duration(milliseconds: 100), () => HapticFeedback.mediumImpact());
          Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.heavyImpact());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate dynamic goal definitions using our state
    final stepsProgress = _progressValues['Steps'] ?? 0.68;
    final caloriesProgress = _progressValues['Calories'] ?? 0.82;
    final activeProgress = _progressValues['Active Minutes'] ?? 0.80;

    final goalsList = [
      _GoalData(
        label: 'Steps',
        current: '${(stepsProgress * 150).toInt()}K',
        target: '150K',
        icon: Icons.directions_walk_rounded,
        progress: stepsProgress,
        color: GelatoTheme.greenDark,
        bgColor: GelatoTheme.green,
      ),
      _GoalData(
        label: 'Calories',
        current: (caloriesProgress * 3000).toInt().toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            ),
        target: '3,000 kcal',
        icon: Icons.local_fire_department_rounded,
        progress: caloriesProgress,
        color: GelatoTheme.orangeDark,
        bgColor: GelatoTheme.orange,
      ),
      _GoalData(
        label: 'Active Minutes',
        current: '${(activeProgress * 800).toInt()}',
        target: '800 mins',
        icon: Icons.access_time_rounded,
        progress: activeProgress,
        color: GelatoTheme.purpleDark,
        bgColor: GelatoTheme.purple,
      ),
    ];

    final isAllCompleted = stepsProgress >= 1.0 && caloriesProgress >= 1.0 && activeProgress >= 1.0;

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: GelatoTheme.cardRadius,
            border: GelatoTheme.cardBorder,
            boxShadow: GelatoTheme.cardShadow,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF5F8), // Pink tint
                Color(0xFFFFFDF5), // Yellow tint
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.gps_fixed_rounded,
                        color: GelatoTheme.pinkDark,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Daily Goals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: GelatoTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        // Reset all to spec
                        _progressValues['Steps'] = 0.68;
                        _progressValues['Calories'] = 0.82;
                        _progressValues['Active Minutes'] = 0.80;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(40, 24),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        color: GelatoTheme.pinkDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Goals Content + Trophy side-by-side
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side: Goals list
                  Expanded(
                    flex: 7,
                    child: AnimatedBuilder(
                      animation: _anim,
                      builder: (context, _) {
                        return Column(
                          children: goalsList.map((g) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapDown: (details) {
                                // Get global position and convert to local stack coordinates
                                final RenderBox box = context.findRenderObject() as RenderBox;
                                final localPos = box.globalToLocal(details.globalPosition);
                                _incrementGoal(g.label, localPos, g.color);
                              },
                              child: _GoalRow(goal: g, animValue: _anim.value),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Right side: Vertical Trophy card
                  Expanded(
                    flex: 3,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 130,
                      decoration: BoxDecoration(
                        color: isAllCompleted ? const Color(0xFFFEF3C7) : GelatoTheme.yellow,
                        borderRadius: BorderRadius.circular(16),
                        border: GelatoTheme.cardBorder,
                        boxShadow: GelatoTheme.cardShadow,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedBuilder(
                                  animation: _rotationController,
                                  builder: (context, child) {
                                    return CustomPaint(
                                      size: const Size(50, 50),
                                      painter: _SunburstPainter(
                                        rotationAngle: _rotationController.value * 2 * math.pi,
                                        color: const Color(0xFFB45309).withOpacity(isAllCompleted ? 0.22 : 0.06),
                                      ),
                                    );
                                  },
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFBBF24).withOpacity(isAllCompleted ? 0.6 : 0.3),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Color(0xFFFFE066), Color(0xFFF59E0B), Color(0xFFB45309)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ).createShader(bounds),
                                    child: const Icon(
                                      Icons.emoji_events_rounded,
                                      color: Colors.white,
                                      size: 36,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isAllCompleted ? 'ALL DONE!' : 'Keep it up!',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: isAllCompleted ? const Color(0xFFB45309) : GelatoTheme.yellowDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isAllCompleted ? 'Daily Master!' : "You're amazing!",
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: isAllCompleted ? const Color(0xFFD97706) : GelatoTheme.orangeDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Particle Painter Layer
        if (_particles.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ParticlePainter(particles: _particles),
              ),
            ),
          ),
      ],
    );
  }
}

class _GoalRow extends StatelessWidget {
  final _GoalData goal;
  final double animValue;

  const _GoalRow({required this.goal, required this.animValue});

  @override
  Widget build(BuildContext context) {
    final pct = (goal.progress * 100).round();
    final isDone = goal.progress >= 1.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Circular Icon Container
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDone ? Colors.white : goal.bgColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDone ? Colors.black : goal.color.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: isDone ? [
                BoxShadow(
                  color: goal.color.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 0.5,
                )
              ] : null,
            ),
            child: Center(
              child: Icon(
                isDone ? Icons.check_circle_rounded : goal.icon,
                color: isDone ? const Color(0xFF22C55E) : goal.color,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Progress Bars and details
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${goal.label} (${goal.current} / ${goal.target})',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: isDone ? FontWeight.w900 : FontWeight.w800,
                          color: GelatoTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$pct%',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: isDone ? const Color(0xFF22C55E) : goal.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: goal.progress * animValue,
                    minHeight: 5,
                    backgroundColor: goal.bgColor.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation(isDone ? const Color(0xFF22C55E) : goal.color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalData {
  final String label;
  final String current;
  final String target;
  final IconData icon;
  final double progress;
  final Color color;
  final Color bgColor;

  const _GoalData({
    required this.label,
    required this.current,
    required this.target,
    required this.icon,
    required this.progress,
    required this.color,
    required this.bgColor,
  });
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
        ..color = p.color.withOpacity(p.life)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.size * p.life, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}

class _SunburstPainter extends CustomPainter {
  final double rotationAngle;
  final Color color;

  _SunburstPainter({required this.rotationAngle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(size.width, size.height) * 0.85;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final int rayCount = 14;
    final double angleStep = 2 * math.pi / rayCount;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);

    for (int i = 0; i < rayCount; i++) {
      final double startAngle = i * angleStep;
      final double endAngle = startAngle + angleStep / 2;

      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(radius * math.cos(startAngle), radius * math.sin(startAngle))
        ..lineTo(radius * math.cos(endAngle), radius * math.sin(endAngle))
        ..close();

      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle || oldDelegate.color != color;
  }
}

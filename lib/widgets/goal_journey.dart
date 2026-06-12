import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../data/gelato_theme.dart';

class GoalJourney extends StatefulWidget {
  final int currentSteps;
  final int goalSteps;

  const GoalJourney({
    super.key,
    this.currentSteps = 102450,
    this.goalSteps = 150000,
  });

  @override
  State<GoalJourney> createState() => _GoalJourneyState();
}

class _GoalJourneyState extends State<GoalJourney>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnim;

  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  late AnimationController _rotationController;

  // Exact milestones mapping from the mockup image
  final List<_MilestoneData> milestones = const [
    _MilestoneData(
      steps: 25000,
      label: 'First Step',
      displaySteps: '25K',
      icon: Icons.directions_walk_rounded,
      isCompleted: true,
      isToday: false,
    ),
    _MilestoneData(
      steps: 50000,
      label: 'On Track',
      displaySteps: '50K',
      icon: Icons.directions_run_rounded,
      isCompleted: true,
      isToday: false,
    ),
    _MilestoneData(
      steps: 75000,
      label: 'On Track',
      displaySteps: '75K',
      icon: Icons.directions_run_rounded,
      isCompleted: true,
      isToday: false,
    ),
    _MilestoneData(
      steps: 102450,
      label: 'Today',
      displaySteps: '102,450',
      icon: Icons.directions_walk_rounded,
      isCompleted: false,
      isToday: true,
    ),
    _MilestoneData(
      steps: 125000,
      label: 'Almost There',
      displaySteps: '125K',
      icon: Icons.eco_rounded,
      isCompleted: false,
      isToday: false,
    ),
    _MilestoneData(
      steps: 150000,
      label: 'Goal',
      displaySteps: '150K',
      icon: Icons.terrain_rounded,
      isCompleted: false,
      isToday: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _progressAnim = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutQuart,
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _progressController.forward();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _glowController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  // Get Y offset for wave curve path based on index
  double _getYOffset(int idx) {
    // Wave pattern similar to mockups: down, up, down, up
    final offsets = [32.0, 48.0, 42.0, 24.0, 38.0, 32.0];
    if (idx >= 0 && idx < offsets.length) {
      return offsets[idx];
    }
    return 30.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GelatoTheme.purple,
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Matches mockup exactly)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Green running background circle
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.directions_run_rounded,
                          color: Color(0xFF22C55E),
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Journey to Your Goal',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 1),
                          Text(
                            "You're doing great! Keep going!",
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Milestones Path + Trophy Card Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Milestones Path (Left)
                SizedBox(
                  width: 380,
                  child: AnimatedBuilder(
                  animation: Listenable.merge([_progressAnim, _glowAnim]),
                  builder: (context, _) {
                    return SizedBox(
                      height: 165,
                      child: Stack(
                        children: [
                          // 1. Curved dashed connector line
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _PathLinePainter(
                                completedCount: 3, // completed 25k, 50k, 75k
                                totalCount: 6,
                                yOffsets: List.generate(6, (i) => _getYOffset(i)),
                                animValue: _progressAnim.value,
                              ),
                            ),
                          ),

                          // 2. Node elements and highlight background
                          Positioned.fill(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final totalWidth = constraints.maxWidth - 64;
                                final segmentWidth = totalWidth / 5;

                                return Stack(
                                  children: milestones.asMap().entries.map((entry) {
                                    final idx = entry.key;
                                    final m = entry.value;
                                    final double posX = 32 + idx * segmentWidth;
                                    final double posY = _getYOffset(idx);
                                    final isCompleted = m.isCompleted;

                                    return Stack(
                                      children: [
                                        // Removed Today node background vertical pill highlight

                                        // Node Pedestal Circle
                                        Positioned(
                                          left: posX - 21,
                                          top: posY - 21,
                                          child: _buildMilestoneNode(m, isCompleted),
                                        ),

                                        // Values ("25K", etc.)
                                        Positioned(
                                          left: posX - 35,
                                          top: posY + 28,
                                          width: 70,
                                          child: Text(
                                            m.displaySteps,
                                            style: TextStyle(
                                              fontSize: m.isToday ? 10.5 : 9.5,
                                              fontWeight: FontWeight.w900,
                                              color: m.isToday
                                                  ? const Color(0xFFD97706) // Golden
                                                  : const Color(0xFF0F172A),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),

                                        // Labels ("First Step", etc.)
                                        Positioned(
                                          left: posX - 40,
                                          top: posY + 43,
                                          width: 80,
                                          child: Text(
                                            m.label,
                                            style: TextStyle(
                                              fontSize: 8.5,
                                              fontWeight: m.isToday
                                                  ? FontWeight.w800
                                                  : FontWeight.w600,
                                              color: m.isToday
                                                  ? const Color(0xFFD97706) // Golden
                                                  : const Color(0xFF64748B),
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        // Checkmark green circle below completed nodes
                                        Positioned(
                                          left: posX - 7,
                                          top: posY + 62,
                                          child: _buildStatusCheckIndicator(m, isCompleted),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 8),

              // Trophy Card (Right) - Confetti theme matches mockup
              Container(
                width: 90,
                height: 155,
                decoration: BoxDecoration(
                  color: GelatoTheme.yellow,
                  borderRadius: BorderRadius.circular(20),
                  border: GelatoTheme.cardBorder,
                  boxShadow: GelatoTheme.cardShadow,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Confetti and Trophy stack
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotating sunburst rays behind trophy
                        AnimatedBuilder(
                          animation: _rotationController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(60, 60),
                              painter: _SunburstPainter(
                                rotationAngle: _rotationController.value * 2 * math.pi,
                                color: const Color(0xFFB45309).withOpacity(0.12),
                              ),
                            );
                          },
                        ),
                        // Confetti sparkles
                        ...List.generate(6, (i) {
                          final angles = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0];
                          final radius = [18.0, 22.0, 20.0, 18.0, 22.0, 20.0];
                          final colors = [
                            Colors.pinkAccent,
                            Colors.blueAccent,
                            Colors.orangeAccent,
                            Colors.greenAccent,
                            Colors.purpleAccent,
                            Colors.amberAccent
                          ];
                          final double x = radius[i] * math.cos(angles[i] * 60 * math.pi / 180);
                          final double y = radius[i] * math.sin(angles[i] * 60 * math.pi / 180);
                          return Transform.translate(
                            offset: Offset(x, y),
                            child: Container(
                              width: 3.5,
                              height: 3.5,
                              decoration: BoxDecoration(
                                color: colors[i],
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFBBF24).withOpacity(0.35),
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
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'You Did It!',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E3A8A), // Indigo
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '150K',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A), // Black
                      ),
                    ),
                    const Text(
                      'Steps',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneNode(_MilestoneData m, bool isCompleted) {
    if (m.isToday) {
      // Today Node: double border and bright pulsing glow
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFF59E0B), // Bright golden
            width: 2.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 3,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.4 * _glowAnim.value),
              blurRadius: 10,
              spreadRadius: 2.5,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            m.icon,
            color: const Color(0xFFF59E0B),
            size: 16,
          ),
        ),
      );
    }

    final activeColor = isCompleted ? const Color(0xFF22C55E) : const Color(0xFFCBD5E1);

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCompleted ? const Color(0xFF4ADE80) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          // 3D bottom depth shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          m.icon,
          color: activeColor,
          size: 14,
        ),
      ),
    );
  }

  Widget _buildStatusCheckIndicator(_MilestoneData m, bool isCompleted) {
    if (m.isToday) {
      return Container(
        height: 12,
        width: 12,
        decoration: const BoxDecoration(
          color: Color(0xFFF59E0B), // Golden dot for today
          shape: BoxShape.circle,
        ),
      );
    }

    if (isCompleted) {
      return Container(
        width: 14,
        height: 14,
        decoration: const BoxDecoration(
          color: Color(0xFF22C55E), // Bright Green Circle
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 9.5,
        ),
      );
    }

    return const SizedBox();
  }
}

class _PathLinePainter extends CustomPainter {
  final int completedCount;
  final int totalCount;
  final List<double> yOffsets;
  final double animValue;

  _PathLinePainter({
    required this.completedCount,
    required this.totalCount,
    required this.yOffsets,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double segmentWidth = (size.width - 64) / (totalCount - 1);
    final List<Offset> points = [];

    for (int i = 0; i < totalCount; i++) {
      final double x = 32 + i * segmentWidth;
      final double y = yOffsets[i];
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    final paintCompleted = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final paintIncomplete = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      final segmentPath = Path();
      segmentPath.moveTo(p1.dx, p1.dy);

      // Create a smooth spline dip/curve between nodes
      final double cpX = (p1.dx + p2.dx) / 2;
      final double cpY = (p1.dy + p2.dy) / 2 + (i % 2 == 0 ? 6 : -6);
      segmentPath.quadraticBezierTo(cpX, cpY, p2.dx, p2.dy);

      final isSegmentCompleted = i < completedCount;

      if (isSegmentCompleted) {
        paintCompleted.color = const Color(0xFF22C55E); // Bright Green path
        _drawDashedPath(canvas, segmentPath, paintCompleted, 4.0, 3.0);
      } else {
        paintIncomplete.color = const Color(0xFFCBD5E1); // Grey path
        _drawDashedPath(canvas, segmentPath, paintIncomplete, 3.0, 4.0);
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, double dashWidth, double dashSpace) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double length = dashWidth;
        final Path extract = metric.extractPath(distance, distance + length);
        canvas.drawPath(extract, paint);
        distance += length + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_PathLinePainter oldDelegate) => true;
}

class _MilestoneData {
  final int steps;
  final String label;
  final String displaySteps;
  final IconData icon;
  final bool isCompleted;
  final bool isToday;

  const _MilestoneData({
    required this.steps,
    required this.label,
    required this.displaySteps,
    required this.icon,
    required this.isCompleted,
    required this.isToday,
  });
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

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

  final List<_MilestoneData> milestones = const [
    _MilestoneData(
      steps: 25000,
      label: 'First Step',
      displaySteps: '25K',
      icon: Icons.directions_walk_rounded,
      isCompleted: true,
      isToday: false,
      colorTheme: 'green',
    ),
    _MilestoneData(
      steps: 50000,
      label: 'On Track',
      displaySteps: '50K',
      icon: Icons.directions_run_rounded,
      isCompleted: true,
      isToday: false,
      colorTheme: 'pink',
    ),
    _MilestoneData(
      steps: 75000,
      label: 'On Track',
      displaySteps: '75K',
      icon: Icons.directions_run_rounded,
      isCompleted: true,
      isToday: false,
      colorTheme: 'pink',
    ),
    _MilestoneData(
      steps: 102450,
      label: 'Today',
      displaySteps: '102,450',
      icon: Icons.directions_walk_rounded,
      isCompleted: false,
      isToday: true,
      colorTheme: 'golden',
    ),
    _MilestoneData(
      steps: 125000,
      label: 'Almost There',
      displaySteps: '125K',
      icon: Icons.eco_rounded,
      isCompleted: false,
      isToday: false,
      colorTheme: 'blue',
    ),
    _MilestoneData(
      steps: 150000,
      label: 'Goal',
      displaySteps: '150K',
      icon: Icons.terrain_rounded,
      isCompleted: false,
      isToday: false,
      colorTheme: 'golden',
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

  double _getYOffset(int idx) {
    // Shifted down by 20px to prevent the glow effect from getting cut off at the top
    final offsets = [52.0, 68.0, 62.0, 44.0, 58.0, 52.0];
    if (idx >= 0 && idx < offsets.length) {
      return offsets[idx];
    }
    return 50.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF8EE), 
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD6C6B5), width: 8), // Thicker pastel brown border
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.directions_run_rounded,
                          color: Color(0xFF2563EB),
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Journey to Your Goal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            "You're doing great! Keep going!",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFD97706), 
                              fontWeight: FontWeight.w700,
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
          const SizedBox(height: 24),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 380,
                  child: AnimatedBuilder(
                  animation: Listenable.merge([_progressAnim, _glowAnim, _rotationController]),
                  builder: (context, _) {
                    return SizedBox(
                      height: 185, // Increased height to accommodate the shifted path
                      child: Stack(
                        clipBehavior: Clip.none, // Prevent clipping of the path connecting to trophy
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _PathLinePainter(
                                completedCount: 3, 
                                totalCount: 6,
                                yOffsets: List.generate(6, (i) => _getYOffset(i)),
                                animValue: _progressAnim.value,
                                flowValue: _rotationController.value,
                              ),
                            ),
                          ),

                          Positioned.fill(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final totalWidth = constraints.maxWidth - 64;
                                final segmentWidth = totalWidth / 5;

                                return Stack(
                                  clipBehavior: Clip.none, // Prevent any node glow clipping
                                  children: milestones.asMap().entries.map((entry) {
                                    final idx = entry.key;
                                    final m = entry.value;
                                    final double posX = 32 + idx * segmentWidth;
                                    final double posY = _getYOffset(idx);
                                    final isCompleted = m.isCompleted;

                                    if (idx == 5) return const SizedBox(); // Don't draw Goal node to avoid overlapping trophy

                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          left: posX - (m.isToday ? 28 : 22),
                                          top: posY - (m.isToday ? 28 : 22),
                                          child: _buildMilestoneNode(m, isCompleted),
                                        ),

                                        Positioned(
                                          left: posX - 35,
                                          top: posY + (m.isToday ? 36 : 28),
                                          width: 70,
                                          child: Text(
                                            m.displaySteps,
                                            style: TextStyle(
                                              fontSize: m.isToday ? 12 : 11,
                                              fontWeight: FontWeight.w900,
                                              color: m.isToday
                                                  ? const Color(0xFFD97706) 
                                                  : const Color(0xFF334155),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),

                                        Positioned(
                                          left: posX - 40,
                                          top: posY + (m.isToday ? 51 : 43),
                                          width: 80,
                                          child: Text(
                                            m.label,
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: m.isToday
                                                  ? FontWeight.w800
                                                  : FontWeight.w700,
                                              color: m.isToday
                                                  ? const Color(0xFFD97706) 
                                                  : const Color(0xFF475569),
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        Positioned(
                                          left: posX - 8,
                                          top: posY + (m.isToday ? 70 : 62),
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

              // Trophy Card (Right)
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
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _rotationController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(60, 60),
                              painter: _SunburstPainter(
                                rotationAngle: _rotationController.value * 2 * math.pi,
                                color: const Color(0xFFB45309).withValues(alpha: 0.12),
                              ),
                            );
                          },
                        ),
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
                                color: const Color(0xFFFBBF24).withValues(alpha: 0.35),
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
                        color: Color(0xFF1E3A8A), 
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '150K',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A), 
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
        ),
      ),
    );
  }

  Widget _buildMilestoneNode(_MilestoneData m, bool isCompleted) {
    Color bgColor;
    Color iconColor;
    Color borderColor;

    switch (m.colorTheme) {
      case 'pink':
        bgColor = const Color(0xFFFCE7F3);
        iconColor = const Color(0xFFDB2777);
        borderColor = const Color(0xFFFBCFE8);
        break;
      case 'green':
        bgColor = const Color(0xFFDCFCE7);
        iconColor = const Color(0xFF16A34A);
        borderColor = const Color(0xFFBBF7D0);
        break;
      case 'blue':
        bgColor = const Color(0xFFDBEAFE);
        iconColor = const Color(0xFF2563EB);
        borderColor = const Color(0xFFBFDBFE);
        break;
      case 'golden':
      default:
        bgColor = const Color(0xFFFEF3C7);
        iconColor = const Color(0xFFD97706);
        borderColor = const Color(0xFFFDE68A);
        break;
    }

    if (m.isToday) {
      return Container(
        width: 56, 
        height: 56,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 5.0), // Thicker icon border
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: iconColor.withValues(alpha: 0.6 * _glowAnim.value),
              blurRadius: 18,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Icon(m.icon, color: iconColor, size: 28),
        ),
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 3.5), // Thicker icon border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(m.icon, color: iconColor, size: 22),
      ),
    );
  }

  Widget _buildStatusCheckIndicator(_MilestoneData m, bool isCompleted) {
    if (m.isToday) {
      return Container(
        height: 16,
        width: 16,
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
              blurRadius: 4,
              spreadRadius: 1,
            )
          ]
        ),
      );
    }

    if (isCompleted) {
      return Container(
        width: 16,
        height: 16,
        decoration: const BoxDecoration(
          color: Color(0xFF22C55E),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 11,
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
  final double flowValue;

  _PathLinePainter({
    required this.completedCount,
    required this.totalCount,
    required this.yOffsets,
    required this.animValue,
    required this.flowValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double segmentWidth = (size.width - 64) / (totalCount - 1);
    final List<Offset> points = [];

    for (int i = 0; i < totalCount; i++) {
      double x = 32 + i * segmentWidth;
      if (i == totalCount - 1) {
        x = size.width + 25; // Extend path out of bounds so it connects beautifully to the Trophy
      }
      final double y = yOffsets[i];
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    final paintCompleted = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final paintCompletedGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF4ADE80).withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    final paintIncomplete = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      final segmentPath = Path();
      segmentPath.moveTo(p1.dx, p1.dy);

      final double cpX = (p1.dx + p2.dx) / 2;
      final double cpY = (p1.dy + p2.dy) / 2 + (i % 2 == 0 ? 8 : -8);
      segmentPath.quadraticBezierTo(cpX, cpY, p2.dx, p2.dy);

      final isSegmentCompleted = i < completedCount;

      final double segmentStart = i / (totalCount - 1);
      final double segmentEnd = (i + 1) / (totalCount - 1);
      final double segmentProgress = ((animValue - segmentStart) / (segmentEnd - segmentStart)).clamp(0.0, 1.0);

      if (segmentProgress > 0) {
        if (isSegmentCompleted) {
          paintCompleted.color = const Color(0xFF4ADE80); 
          double flowOffset = flowValue * 250; // Speed of marching ants
          _drawDashedPath(canvas, segmentPath, paintCompletedGlow, 6.0, 5.0, flowOffset: flowOffset, progress: segmentProgress);
          _drawDashedPath(canvas, segmentPath, paintCompleted, 6.0, 5.0, flowOffset: flowOffset, progress: segmentProgress);
        } else {
          paintIncomplete.color = const Color(0xFF94A3B8).withValues(alpha: 0.5); 
          _drawDashedPath(canvas, segmentPath, paintIncomplete, 4.0, 6.0, progress: segmentProgress);
        }
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, double dashWidth, double dashSpace, {double flowOffset = 0.0, double progress = 1.0}) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double totalLength = metric.length * progress;
      final dashCycle = dashWidth + dashSpace;
      double distance = (flowOffset % dashCycle) - dashCycle;
      while (distance < totalLength) {
        final double start = math.max(0.0, distance);
        final double end = math.min(totalLength, distance + dashWidth);
        if (start < end) {
          final Path extract = metric.extractPath(start, end);
          canvas.drawPath(extract, paint);
        }
        distance += dashCycle;
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
  final String colorTheme;

  const _MilestoneData({
    required this.steps,
    required this.label,
    required this.displaySteps,
    required this.icon,
    required this.isCompleted,
    required this.isToday,
    required this.colorTheme,
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

    const int rayCount = 14;
    const double angleStep = 2 * math.pi / rayCount;

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

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(6, 6, size.width - 12, size.height - 12),
          const Radius.circular(18)));
          
    final paint = Paint()
      ..color = const Color(0xFFB48A66) // Dark pastel brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double length = 4.0;
        final Path extract = metric.extractPath(distance, distance + length);
        canvas.drawPath(extract, paint);
        distance += length + 5.0;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

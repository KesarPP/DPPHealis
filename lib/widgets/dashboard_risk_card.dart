import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';

class DashboardRiskCard extends StatefulWidget {
  const DashboardRiskCard({super.key});

  @override
  State<DashboardRiskCard> createState() => _DashboardRiskCardState();
}

class _DashboardRiskCardState extends State<DashboardRiskCard>
    with TickerProviderStateMixin {
  late AnimationController _counterController;
  late Animation<double> _counterAnim;
  late AnimationController _heartController;
  late Animation<double> _heartScale;
  late AnimationController _ecgController;
  late Animation<double> _ecgOffset;

  final int _targetScore = 42;

  @override
  void initState() {
    super.initState();

    // 1. Counter animation (from 0 to 42)
    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _counterAnim = Tween<double>(begin: 0.0, end: _targetScore.toDouble()).animate(
      CurvedAnimation(parent: _counterController, curve: Curves.easeOutQuart),
    );

    // 2. Beating Heart animation (scales up/down)
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15).chain(CurveTween(curve: Curves.easeInOut)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95).chain(CurveTween(curve: Curves.easeInOut)), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.05).chain(CurveTween(curve: Curves.easeInOut)), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
    ]).animate(_heartController);

    // 3. ECG wave trace animation (DashOffset drawing from left to right)
    _ecgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    _ecgOffset = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ecgController, curve: Curves.easeInOut),
    );

    // Trigger animations after mount
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        _counterController.forward();
      }
    });
  }

  @override
  void dispose() {
    _counterController.dispose();
    _heartController.dispose();
    _ecgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: Column(
        children: [
          // ─── TOP CONTAINER (SOLID PASTEL PINK) ───
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEF4444),
                  Color(0xFFDC2626),
                  Color(0xFFB91C1C),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Diagonal faint rings decoration
                Positioned(
                  top: -30,
                  right: -30,
                  child: Opacity(
                    opacity: 0.12,
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: CustomPaint(
                        painter: _FaintCirclesPainter(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                
                // Main content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                    mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'YOUR PREDIABETES RISK',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Reducing Nicely!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FittedBox(
                                alignment: Alignment.centerLeft,
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  textBaseline: TextBaseline.alphabetic,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  children: [
                                    AnimatedBuilder(
                                      animation: _counterAnim,
                                      builder: (context, _) {
                                        return Text(
                                          _counterAnim.value.toStringAsFixed(0),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 44,
                                            fontWeight: FontWeight.w900,
                                            height: 1,
                                          ),
                                        );
                                      },
                                    ),
                                    Text(
                                      ' /100',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: GelatoTheme.orange,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                                      ),
                                      child: const Text(
                                        'Moderate Risk',
                                        style: TextStyle(
                                          color: GelatoTheme.orangeDark,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.arrow_downward_rounded, size: 14, color: GelatoTheme.pinkDark),
                                  const SizedBox(width: 2),
                                  Text(
                                    '6 points improved this week',
                                    style: TextStyle(
                                      color: GelatoTheme.pinkDark.withValues(alpha: 0.9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Beating ECG Heart widget
                        AnimatedBuilder(
                          animation: Listenable.merge([_heartScale, _ecgOffset]),
                          builder: (context, _) {
                            return Transform.scale(
                              scale: _heartScale.value,
                              child: Container(
                                width: 88,
                                height: 88,
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: CustomPaint(
                                  painter: _ECGHeartPainter(ecgProgress: _ecgOffset.value),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Risk slider meter
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final totalWidth = constraints.maxWidth;
                        
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Slider Track
                            Container(
                              height: 8,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: GelatoTheme.pinkDark.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: 1.0,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(child: Container(color: GelatoTheme.green)),
                                        Expanded(child: Container(color: GelatoTheme.yellow)),
                                        Expanded(child: Container(color: GelatoTheme.orange)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Pointer
                            AnimatedBuilder(
                              animation: _counterAnim,
                              builder: (context, _) {
                                final currentPointerX = totalWidth * (_counterAnim.value / 100.0);
                                return Positioned(
                                  left: currentPointerX - 10,
                                  top: -6,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: GelatoTheme.purpleDark,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    
                    // Risk intervals label text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const Text('Low Risk', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text('0 – 30', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 9, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Moderate Risk', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text('31 – 60', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 9, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('High Risk', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text('61 – 100', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 9, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // ─── BOTTOM CONTAINER (WHITE BACKGROUND) ───
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEFF6FF), // var(--tint-sapphire) equivalent
                  Colors.white,
                ],
              ),
            ),
            child: Row(
              children: [
                // 1. Weekly Progress (Circular Ring)
                Column(
                  children: [
                    const Text(
                      'Weekly Progress',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: GelatoTheme.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _CircularProgressWidget(
                      pct: 78,
                      size: 68,
                      color: GelatoTheme.blueBright,
                      trackColor: Color(0x123B82F6),
                      gradientColors: [GelatoTheme.blueBright, GelatoTheme.purpleBright],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDBEAFE)),
                      ),
                      child: const Text(
                        'ON TRACK',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: GelatoTheme.blueDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(width: 24),
                
                // 2. Program Progress (Horizontal Bar)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Program Progress',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: GelatoTheme.textDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            'Session 5',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.textDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Text(
                              'of 16',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: GelatoTheme.textLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Expanded(
                            child: _ProgressBarWidget(
                              pct: 31,
                              height: 6,
                              color: GelatoTheme.purpleBright,
                              trackColor: Color(0x188B5CF6),
                              gradientColors: [GelatoTheme.blueBright, GelatoTheme.purpleBright],
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '31%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.blueDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFEF3C7)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.star_rounded, size: 16, color: GelatoTheme.yellowBright),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Great consistency this week!',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: GelatoTheme.yellowDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }
}

class _FaintCirclesPainter extends CustomPainter {
  final Color color;
  _FaintCirclesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
      
    canvas.drawCircle(center, 35, paint);
    canvas.drawCircle(center, 58, paint);
    canvas.drawCircle(center, 80, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _ECGHeartPainter extends CustomPainter {
  final double ecgProgress;
  _ECGHeartPainter({required this.ecgProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 1. Draw shiny glossy heart with radial gradient
    final rect = Rect.fromLTWH(0, 0, width, height);
    final paintHeart = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.4),
        radius: 0.7,
        colors: [
          Color(0xFFFFB4B4),
          Color(0xFFEF4444),
          Color(0xFFB91C1C),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final heartPath = Path();
    // Path calculation matching svg: "M32 56 C 10 40, 4 26, 14 17 C 22 10, 30 14, 32 20 C 34 14, 42 10, 50 17 C 60 26, 54 40, 32 56 Z" scaled to 88x88
    final s = width / 64.0; // scale factor
    heartPath.moveTo(32 * s, 56 * s);
    heartPath.cubicTo(10 * s, 40 * s, 4 * s, 26 * s, 14 * s, 17 * s);
    heartPath.cubicTo(22 * s, 10 * s, 30 * s, 14 * s, 32 * s, 20 * s);
    heartPath.cubicTo(34 * s, 14 * s, 42 * s, 10 * s, 50 * s, 17 * s);
    heartPath.cubicTo(60 * s, 26 * s, 54 * s, 40 * s, 32 * s, 56 * s);
    heartPath.close();

    canvas.drawPath(heartPath, paintHeart);

    // 2. Draw glossy white highlight curve at the top-left lobe
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final highlightPath = Path();
    highlightPath.moveTo(18 * s, 18 * s);
    highlightPath.cubicTo(22 * s, 14 * s, 28 * s, 14 * s, 30 * s, 18 * s);
    highlightPath.cubicTo(27 * s, 18 * s, 22 * s, 21 * s, 20 * s, 25 * s);
    highlightPath.cubicTo(18 * s, 22 * s, 17 * s, 20 * s, 18 * s, 18 * s);
    highlightPath.close();
    canvas.drawPath(highlightPath, highlightPaint);

    // 3. Draw ECG plaque (white rectangle in center)
    final plaquePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final plaqueRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10 * s, 26 * s, 44 * s, 14 * s),
      Radius.circular(3.0 * s),
    );
    canvas.drawRRect(plaqueRect, plaquePaint);

    // 4. Draw Beating ECG line inside the plaque
    final ecgPoints = [
      Offset(11 * s, 33 * s),
      Offset(18 * s, 33 * s),
      Offset(21 * s, 28 * s),
      Offset(25 * s, 38 * s),
      Offset(29 * s, 24 * s),
      Offset(33 * s, 40 * s),
      Offset(37 * s, 30 * s),
      Offset(42 * s, 33 * s),
      Offset(53 * s, 33 * s),
    ];

    final ecgPath = Path();
    ecgPath.moveTo(ecgPoints[0].dx, ecgPoints[0].dy);
    for (int i = 1; i < ecgPoints.length; i++) {
      ecgPath.lineTo(ecgPoints[i].dx, ecgPoints[i].dy);
    }

    final ecgPaint = Paint()
      ..color = const Color(0xFFDC2626)
      ..strokeWidth = 2.0 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final activePath = Path();
    for (final metric in ecgPath.computeMetrics()) {
      final drawLength = metric.length * (1.0 - ecgProgress);
      activePath.addPath(metric.extractPath(0.0, drawLength), Offset.zero);
    }
    canvas.drawPath(activePath, ecgPaint);
  }

  @override
  bool shouldRepaint(covariant _ECGHeartPainter oldDelegate) {
    return oldDelegate.ecgProgress != ecgProgress;
  }
}

class _CircularProgressWidget extends StatelessWidget {
  final int pct;
  final double size;
  final Color color;
  final Color trackColor;
  final List<Color>? gradientColors;

  const _CircularProgressWidget({
    required this.pct,
    required this.size,
    required this.color,
    required this.trackColor,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct / 100.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CustomPaint(
                  painter: _CircularProgressPainter(
                    value: value,
                    color: color,
                    trackColor: trackColor,
                    strokeWidth: 6.5,
                    gradientColors: gradientColors,
                  ),
                );
              },
            ),
          ),
          Text(
            '$pct%',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: gradientColors != null ? gradientColors!.first : color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color trackColor;
  final double strokeWidth;
  final List<Color>? gradientColors;

  _CircularProgressPainter({
    required this.value,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
    this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    // Active Arc
    final activePaint = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (gradientColors != null && gradientColors!.length >= 2) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      activePaint.shader = SweepGradient(
        colors: gradientColors!,
        stops: const [0.0, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);
    } else {
      activePaint.color = color;
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.gradientColors != gradientColors;
  }
}

class _ProgressBarWidget extends StatelessWidget {
  final int pct;
  final double height;
  final Color color;
  final Color trackColor;
  final List<Color>? gradientColors;

  const _ProgressBarWidget({
    required this.pct,
    required this.height,
    required this.color,
    required this.trackColor,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: pct / 100.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: totalWidth * value,
                  height: height,
                  decoration: BoxDecoration(
                    color: gradientColors == null ? color : null,
                    gradient: gradientColors != null
                        ? LinearGradient(
                            colors: gradientColors!,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

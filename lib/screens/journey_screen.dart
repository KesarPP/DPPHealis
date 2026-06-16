import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../data/journey_data.dart';

class JourneyMap extends StatefulWidget {
  const JourneyMap({super.key});

  @override
  State<JourneyMap> createState() => _JourneyMapState();
}

class _JourneyMapState extends State<JourneyMap> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _time = 0.0;

  // Sunset Theme Pastel Colors
  final Color cRed = const Color(0xFFFF8B8B); // Sunset Red
  final Color cOrange = const Color(0xFFFFDAB4); // Soft Orange
  final Color cYellow = const Color(0xFFF9E1A8); // Golden Yellow

  // Slightly darker versions for text/icons
  final Color cRedDark = const Color(0xFFD65C5C);
  final Color cOrangeDark = const Color(0xFFDFBA92);
  final Color cYellowDark = const Color(0xFFD5BB7F);

  List<Color> get colors => [cRed, cRed, cRed, cRed, cRed, cRed];
  List<Color> get darkColors => [cRedDark, cRedDark, cRedDark, cRedDark, cRedDark, cRedDark];
  late final List<IconData> icons;

  @override
  void initState() {
    super.initState();
    
    icons = [
      Icons.restaurant,
      Icons.directions_run_rounded,
      Icons.water_drop_rounded,
      Icons.apple_rounded,
      Icons.spa_rounded,
      Icons.my_location_rounded,
    ];

    _ticker = createTicker((elapsed) {
      setState(() {
        _time = elapsed.inMicroseconds / 1000000.0;
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.topCenter,
      child: Container(
        width: 400,
        height: 1750,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
          gradient: const RadialGradient(
            center: Alignment.center,
            radius: 3.0,
            colors: [
              Color(0xFFE6E6FA), // Lavender in center
              Color(0xFF5A315D), // Deep Plum Purple towards edges
            ],
            stops: [0.0, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, 10),
            )
          ]
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Pattern Layer
            Positioned.fill(
              child: CustomPaint(
                painter: _PatternPainter(color: Colors.white.withValues(alpha: 0.15)),
              ),
            ),
            
            // Path Layer
            Positioned.fill(
              child: CustomPaint(
                painter: _ExactPathPainter(
                  colors: colors,
                  time: _time,
                ),
              ),
            ),
            
            // Cards Layer
            _buildInteractiveCard(x: 20, y: 76, module: journeyModules[0], color: colors[0], darkColor: darkColors[0], icon: icons[0]),
            _buildInteractiveCard(x: 160, y: 250, module: journeyModules[1], color: colors[1], darkColor: darkColors[1], icon: icons[1]),
            _buildInteractiveCard(x: 20, y: 450, module: journeyModules[2], color: colors[2], darkColor: darkColors[2], icon: icons[2]),
            _buildInteractiveCard(x: 160, y: 650, module: journeyModules[3], color: colors[3], darkColor: darkColors[3], icon: icons[3]),
            _buildInteractiveCard(x: 20, y: 850, module: journeyModules[4], color: colors[4], darkColor: darkColors[4], icon: icons[4]),
            _buildInteractiveCard(x: 160, y: 1050, module: journeyModules[5], color: colors[5], darkColor: darkColors[5], icon: icons[5]),
            
            // Nodes Layer
            _buildNode(x: 130, y: 170, color: colors[0]),
            _buildNode(x: 270, y: 370, color: colors[1]),
            _buildNode(x: 130, y: 570, color: colors[2]),
            _buildNode(x: 270, y: 770, color: colors[3]),
            _buildNode(x: 130, y: 970, color: colors[4]),
            _buildNode(x: 270, y: 1170, color: colors[5]),
            
            // Start Flag Layer
            Positioned(
              left: 106,
              top: 16, 
              child: _buildStartIcon(colors[0], darkColors[0]),
            ),
            
            // End Treasure Layer
            Positioned(
              left: 0, 
              top: 1250,
              child: _buildEndTreasure(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNode({required double x, required double y, required Color color}) {
    return const SizedBox.shrink();
  }

  Widget _buildStartIcon(Color color, Color darkColor) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: color, width: 2),
        boxShadow: [BoxShadow(color: color, blurRadius: 24, spreadRadius: 4)]
      ),
      child: Center(child: Icon(Icons.flag_rounded, color: darkColor, size: 24)),
    );
  }

  Widget _buildEndTreasure() {
    double pulse = (math.sin(_time * 3) + 1) / 2;
    
    return Container(
      width: 400,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Trophy Emoji with Glow
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.6 + 0.4 * pulse),
                      blurRadius: 80 + 40 * pulse,
                      spreadRadius: 20 + 20 * pulse,
                    )
                  ]
                ),
              ),
              Transform.scale(
                scale: 1.0 + 0.05 * pulse,
                child: const Text(
                  '🏆',
                  style: TextStyle(fontSize: 100, height: 1.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 2. Wrap of Achievements
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 12,
            children: [
              _buildAchievementChip('A1C Normalized'),
              _buildAchievementChip('Weight Goal'),
              _buildAchievementChip('Energy Restored'),
              _buildAchievementChip('Mindset Shifted'),
              _buildAchievementChip('Eating Mastered'),
              _buildAchievementChip('Active Lifestyle'),
            ],
          ),
          const SizedBox(height: 32),
          
          // 3. You Did It! text
          Stack(
            children: [
              // Black Border
              Text(
                'You Did It! ✨',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 3.0
                    ..color = Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              // Fill text
              const Text(
                'You Did It! ✨',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFBEBB5),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 4. Final text
          const Text(
            '16 weeks. One powerful choice. A lifetime of vibrant,\nhealthy living starts now.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFBEBB5), // Soft pale gold to pop on navy
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6A5D2E),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInteractiveCard({
    required double x, required double y, 
    required ModuleNode module, required Color color, required Color darkColor, required IconData icon
  }) {
    return Positioned(
      left: x, top: y,
      child: _InteractiveModuleCard(
        module: module,
        color: color,
        darkColor: darkColor,
        icon: icon,
        time: _time,
      ),
    );
  }
}

class _InteractiveModuleCard extends StatefulWidget {
  final ModuleNode module;
  final Color color;
  final Color darkColor;
  final IconData icon;
  final double time;

  const _InteractiveModuleCard({
    required this.module,
    required this.color,
    required this.darkColor,
    required this.icon,
    required this.time,
  });

  @override
  State<_InteractiveModuleCard> createState() => _InteractiveModuleCardState();
}

class _InteractiveModuleCardState extends State<_InteractiveModuleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.module.state == ModuleState.locked;
    final isCompleted = widget.module.state == ModuleState.completed;
    
    // Brighter border glow for completed cards
    double completionPulse = isCompleted ? (math.sin(widget.time * 4) + 1) / 2 : 0;
    
    Widget cardContent = Container(
      width: 220, 
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.shade100 : Color.lerp(Colors.white, widget.color, 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isLocked ? Colors.black12 : widget.color.withValues(alpha: 0.8), 
            blurRadius: 30 + (30 * completionPulse), 
            spreadRadius: 8 + (12 * completionPulse),
            offset: const Offset(0, 8),
          ),
        ]
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLocked ? Colors.grey.shade200 : Colors.white,
                  boxShadow: isLocked ? null : [BoxShadow(color: widget.color.withValues(alpha: 0.5), blurRadius: 8)]
                ),
                child: Icon(widget.icon, color: isLocked ? Colors.grey.shade400 : widget.darkColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge
                    Row(
                      children: [
                        Container(
                          width: 18, height: 18,
                          decoration: BoxDecoration(
                            color: isLocked ? Colors.grey.shade200 : Colors.white, 
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black87, width: 1.0),
                          ),
                          alignment: Alignment.center,
                          child: Text('${widget.module.number}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                        ),
                        const SizedBox(width: 6),
                        const Text('SESSION', style: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Title
                    Text(widget.module.title, style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w900, height: 1.3)),
                    const SizedBox(height: 8),
                    // Status
                    Row(
                      children: [
                        Icon(isLocked ? Icons.lock_rounded : Icons.check_circle_rounded, size: 14, color: isLocked ? Colors.grey : widget.darkColor),
                        const SizedBox(width: 4),
                        Text(isLocked ? 'Locked' : 'Completed', style: TextStyle(color: isLocked ? Colors.grey : widget.darkColor, fontSize: 11, fontWeight: FontWeight.w800)),
                      ]
                    )
                  ]
                )
              )
            ]
          )
        )
    );

    if (isLocked) {
      cardContent = Opacity(
        opacity: 0.8,
        child: cardContent,
      );
    }

    return GestureDetector(
      onTapDown: isLocked ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isLocked ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isLocked ? null : () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: cardContent,
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _DottedBorderPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(20)));

    final dashPath = Path();
    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        const len = 8.0;
        if (draw) dashPath.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        distance += len;
        draw = !draw;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DottedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

class _ExactPathPainter extends CustomPainter {
  final List<Color> colors;
  final double time;

  _ExactPathPainter({required this.colors, required this.time});

  Path dashPath(Path source, {required double dashArray, double dashOffset = 0.0}) {
    final Path dest = Path();
    for (final ui.PathMetric metric in source.computeMetrics()) {
      double distance = dashOffset % (dashArray * 2);
      distance -= (dashArray * 2); // Start negative to cover beginning
      bool draw = true;
      while (distance < metric.length) {
        final double len = dashArray;
        if (draw) {
          double start = math.max(0.0, distance);
          double end = math.min(metric.length, distance + len);
          if (start < end) {
            dest.addPath(metric.extractPath(start, end), Offset.zero);
          }
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final mainPath = Path();
    mainPath.moveTo(130, 24); // From Top
    mainPath.lineTo(130, 170); // Node 1
    mainPath.cubicTo(130, 270, 270, 270, 270, 370); // Node 2
    mainPath.cubicTo(270, 470, 130, 470, 130, 570); // Node 3
    mainPath.cubicTo(130, 670, 270, 670, 270, 770); // Node 4
    mainPath.cubicTo(270, 870, 130, 870, 130, 970); // Node 5
    mainPath.cubicTo(130, 1070, 270, 1070, 270, 1170); // Node 6

    final dashedPath = Path();
    dashedPath.moveTo(270, 1170);
    dashedPath.cubicTo(270, 1260, 200, 1260, 200, 1350); // to Treasure

    // Unused variables bounds and gradient removed

    // 1. Breathing Golden Glow (Expands and Contracts)
    double breath = (math.sin(time * 2) + 1) / 2; // 0.0 to 1.0
    
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.6) // Golden glow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 60 + (15 * breath)
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 24 + (12 * breath));
    canvas.drawPath(mainPath, glowPaint);
    
    // Intense secondary glow
    final innerGlowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5 + (0.2 * breath))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 42 + (8 * breath)
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(mainPath, innerGlowPaint);

    // 2. Beautiful white pathway (thick)
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(mainPath, corePaint);
    
    // 3. Elegant dashed inner line
    final innerDash = Paint()
      ..color = const Color(0xFFDFBA92).withValues(alpha: 0.8) // Soft Orange dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(dashPath(mainPath, dashArray: 12.0), innerDash);

    // Dashed path to treasure
    final treasureDashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 1.0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);
    canvas.drawPath(dashPath(dashedPath, dashArray: 10.0), treasureDashPaint);

    // 4. Energy Flow & Ambient Particle System
    final metrics = mainPath.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;


    // A. Flowing dots/dashes traveling along the entire path
    final energyStreamPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.95) // Bright Gold/Yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    // Use positive time offset so the dashes flow downwards
    canvas.drawPath(dashPath(mainPath, dashArray: 18.0, dashOffset: time * 120.0), energyStreamPaint);
  }

  @override
  bool shouldRepaint(covariant _ExactPathPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

class _FireworksPainter extends CustomPainter {
  final double time;
  _FireworksPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final random = math.Random(42);
    
    // 1. Heavenly Rays (rotating slowly) - Made smaller and more subtle
    final rayPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(time * 0.1);
    for(int i=0; i<16; i++) {
      double angle = (i / 16) * math.pi * 2;
      Path ray = Path();
      ray.moveTo(0, 0);
      ray.lineTo(math.cos(angle - 0.05) * 160, math.sin(angle - 0.05) * 160);
      ray.lineTo(math.cos(angle + 0.05) * 160, math.sin(angle + 0.05) * 160);
      ray.close();
      canvas.drawPath(ray, rayPaint);
    }
    canvas.restore();

    // 2. Subtle Golden Sparkles (Removed colors)
    final List<Color> colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFFF200), // Light Gold
      Colors.white, // White
    ];

    double easeOutQuad(double t) => t * (2 - t);

    for (int i = 0; i < 50; i++) {
      // Create expanding rings of particles
      double baseRadius = 40 + random.nextDouble() * 100;
      double speed = 1.0 + random.nextDouble() * 1.5;
      double progress = ((time * speed) + random.nextDouble() * 10) % 4.0; 
      
      // Only draw if within active burst window (0.0 to 1.0)
      if (progress < 1.0) {
        double angle = random.nextDouble() * 2 * math.pi;
        double currentDist = baseRadius * easeOutQuad(progress);
        Offset pos = center + Offset(math.cos(angle) * currentDist, math.sin(angle) * currentDist);
        
        double sizePulse = math.sin(progress * math.pi); // Fade in and out
        Color pColor = colors[random.nextInt(colors.length)];
        
        final particlePaint = Paint()
          ..color = pColor.withValues(alpha: sizePulse)
          ..style = PaintingStyle.fill;
          
        if (random.nextBool()) {
          // Draw star
          Path starPath = Path();
          double r1 = 4 + 4 * sizePulse;
          double r2 = 2 + 2 * sizePulse;
          for (int j = 0; j < 8; j++) {
            double r = j % 2 == 0 ? r1 : r2;
            double a = (j / 8) * 2 * math.pi + (time * 2);
            Offset p = pos + Offset(math.cos(a) * r, math.sin(a) * r);
            if (j == 0) {
              starPath.moveTo(p.dx, p.dy);
            } else {
              starPath.lineTo(p.dx, p.dy);
            }
          }
          starPath.close();
          canvas.drawPath(starPath, particlePaint);
        } else {
          // Draw circle sparkle
          canvas.drawCircle(pos, 4 * sizePulse, particlePaint);
        }
      }
    }
    
    // 3. Elegant Gold Starbursts 
    for (int i = 0; i < 8; i++) {
      double angle = (i / 8) * 2 * math.pi;
      double pulse = (math.sin(time * 3 + i) + 1) / 2;
      double distance = 120 + math.sin(time + i) * 20;
      Offset pos = center + Offset(math.cos(angle) * distance, math.sin(angle) * distance);
      
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.6 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawCircle(pos, 25 * pulse, glowPaint);
      
      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8 + 0.2 * pulse)
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(pos, 3 + 3 * pulse, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

class _ShineSweepPainter extends CustomPainter {
  final double time;
  _ShineSweepPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // Treasure-like shine sweep across the trophy
    double sweepProgress = (time * 0.4) % 1.0; 
    
    // We want the shine to sweep from left to right, periodically
    // We map 0.0-1.0 to a wider range to allow for pauses between sweeps
    double xPos = (sweepProgress * size.width * 3) - size.width;
    
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(xPos, 0, 60, size.height))
      ..style = PaintingStyle.fill;
      
    // Transform to angle the shine sweep
    canvas.save();
    canvas.translate(xPos, 0);
    canvas.rotate(0.3); // slight tilt
    canvas.drawRect(Rect.fromLTWH(-30, -50, 60, size.height + 100), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShineSweepPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

class _PatternPainter extends CustomPainter {
  final Color color;
  _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    final centerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Shift alternate rows for a staggered pattern
        double offsetX = (y / spacing) % 2 == 0 ? 0 : spacing / 2;
        
        double cx = x + offsetX;
        double cy = y;
        
        // Draw a tiny star
        Path starPath = Path();
        double r1 = 3.0; // outer radius
        double r2 = 1.2; // inner radius
        for (int j = 0; j < 10; j++) {
          double r = j % 2 == 0 ? r1 : r2;
          double a = (j / 10) * 2 * math.pi - math.pi / 2;
          Offset p = Offset(cx + math.cos(a) * r, cy + math.sin(a) * r);
          if (j == 0) starPath.moveTo(p.dx, p.dy);
          else starPath.lineTo(p.dx, p.dy);
        }
        starPath.close();
        canvas.drawPath(starPath, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) => oldDelegate.color != color;
}

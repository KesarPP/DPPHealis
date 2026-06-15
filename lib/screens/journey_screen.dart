import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../data/journey_data.dart';

// Pastel Color Palette "GELATO DAYS"
const Color _pastelPink = Color(0xFFFFCBE1);
const Color _pastelGreen = Color(0xFFD6E5BD);
const Color _pastelBlue = Color(0xFFBCD8EC);
const Color _pastelPurple = Color(0xFFDCCCEC);
const Color _pastelPeach = Color(0xFFFFDAB4);
const Color _darkText = Color(0xFF2E3A59);
class JourneyMap extends StatefulWidget {
  const JourneyMap({super.key});

  @override
  State<JourneyMap> createState() => _JourneyMapState();
}

class _JourneyMapState extends State<JourneyMap> with SingleTickerProviderStateMixin {
  late AnimationController _flowController;

  // Exact colors from the Gelato Days pastel palette
  final Color cPink = const Color(0xFFFFCBE1);
  final Color cGreen = const Color(0xFFD6E5BD);
  final Color cYellow = const Color(0xFFF9E1A8);
  final Color cBlue = const Color(0xFFBCD8EC);
  final Color cPurple = const Color(0xFFDCCCEC);
  final Color cOrange = const Color(0xFFFFDAB4);

  // Slightly darker versions of the pastel colors for text/icons to ensure readability
  final Color cPinkDark = const Color(0xFFE2A6C0);
  final Color cGreenDark = const Color(0xFFB1C494);
  final Color cYellowDark = const Color(0xFFD5BB7F);
  final Color cBlueDark = const Color(0xFF9CB8CC);
  final Color cPurpleDark = const Color(0xFFBCABCC);
  final Color cOrangeDark = const Color(0xFFDFBA92);

  late final List<Color> colors;
  late final List<Color> darkColors;
  late final List<IconData> icons;

  @override
  void initState() {
    super.initState();
    colors = [cPink, cGreen, cYellow, cBlue, cPurple, cOrange];
    darkColors = [cPinkDark, cGreenDark, cYellowDark, cBlueDark, cPurpleDark, cOrangeDark];
    
    icons = [
      Icons.restaurant,
      Icons.directions_run_rounded,
      Icons.water_drop_rounded,
      Icons.apple_rounded,
      Icons.spa_rounded,
      Icons.my_location_rounded,
    ];

    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _flowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 400,
        height: 1150,
        child: Stack(
          children: [
            // Path Layer
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _flowController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ExactPathPainter(
                      colors: colors,
                      animationValue: _flowController.value,
                    ),
                  );
                }
              ),
            ),
            
            // Cards Layer
            _buildInteractiveCard(x: 90, y: 50, module: journeyModules[0], color: colors[0], darkColor: darkColors[0], icon: icons[0]),
            _buildInteractiveCard(x: 160, y: 220, module: journeyModules[1], color: colors[1], darkColor: darkColors[1], icon: icons[1]),
            _buildInteractiveCard(x: 20, y: 370, module: journeyModules[2], color: colors[2], darkColor: darkColors[2], icon: icons[2]),
            _buildInteractiveCard(x: 160, y: 520, module: journeyModules[3], color: colors[3], darkColor: darkColors[3], icon: icons[3]),
            _buildInteractiveCard(x: 20, y: 670, module: journeyModules[4], color: colors[4], darkColor: darkColors[4], icon: icons[4]),
            _buildInteractiveCard(x: 160, y: 820, module: journeyModules[5], color: colors[5], darkColor: darkColors[5], icon: icons[5]),
            
            // Nodes Layer
            _buildNode(x: 120, y: 170, color: colors[0]),
            _buildNode(x: 160, y: 280, color: colors[1]),
            _buildNode(x: 240, y: 430, color: colors[2]),
            _buildNode(x: 160, y: 580, color: colors[3]),
            _buildNode(x: 240, y: 730, color: colors[4]),
            _buildNode(x: 160, y: 880, color: colors[5]),
            
            // Start Flag Layer
            Positioned(
              left: 36,
              top: 146, 
              child: _buildStartIcon(colors[0], darkColors[0]),
            ),
            
            // End Treasure Layer (Full Width Blended Image)
            Positioned(
              left: 0, 
              top: 850,
              child: _buildEndTreasure(colors[5]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNode({required double x, required double y, required Color color}) {
    return Positioned(
      left: x - 10,
      top: y - 10,
      child: Container(
        width: 20, height: 20,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 5),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 10, spreadRadius: 2),
          ]
        ),
      ),
    );
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

  Widget _buildEndTreasure(Color glowColor) {
    return Container(
      width: 400, height: 400,
      alignment: Alignment.center,
      child: Container(
        width: 180, height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFFFFD700), width: 6),
          boxShadow: [
            BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.6), blurRadius: 60, spreadRadius: 20),
            BoxShadow(color: glowColor.withValues(alpha: 0.5), blurRadius: 100, spreadRadius: 40),
          ]
        ),
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFF200), Color(0xFFD4AF37), Color(0xFFB8860B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Icon(
            Icons.emoji_events_rounded,
            size: 120,
            color: Colors.white,
          ),
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
      ),
    );
  }
}

class _InteractiveModuleCard extends StatefulWidget {
  final ModuleNode module;
  final Color color;
  final Color darkColor;
  final IconData icon;

  const _InteractiveModuleCard({
    required this.module,
    required this.color,
    required this.darkColor,
    required this.icon,
  });

  @override
  State<_InteractiveModuleCard> createState() => _InteractiveModuleCardState();
}

class _InteractiveModuleCardState extends State<_InteractiveModuleCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.module.state == ModuleState.locked;
    
    Widget cardContent = Container(
      width: 220, 
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.shade100 : Color.lerp(Colors.white, widget.color, 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black87, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: isLocked ? Colors.transparent : widget.color.withValues(alpha: 0.6), 
            blurRadius: 20, 
            spreadRadius: 2
          ),
        ]
      ),
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
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]
                      ),
                      alignment: Alignment.center,
                      child: Text('${widget.module.number}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                    const SizedBox(width: 6),
                    const Text('MODULE', style: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  ],
                ),
                const SizedBox(height: 6),
                // Title
                Text(widget.module.title, style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w900, height: 1.3)),
                const SizedBox(height: 8),
                // Status
                Row(
                  children: [
                    Icon(isLocked ? Icons.lock_rounded : Icons.check_rounded, size: 14, color: Colors.black87),
                    const SizedBox(width: 4),
                    Text(isLocked ? 'Locked' : 'Completed', style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w800)),
                  ]
                )
              ]
            )
          )
        ]
      )
    );

    // If locked, overlay a large lock and reduce opacity
    if (isLocked) {
      cardContent = Opacity(
        opacity: 0.7,
        child: Stack(
          alignment: Alignment.center,
          children: [
            cardContent,
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16)
              ),
              width: 220,
              height: 100,
            ),
            Icon(Icons.lock_rounded, size: 48, color: Colors.black.withValues(alpha: 0.1)),
          ],
        ),
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

class _ExactPathPainter extends CustomPainter {
  final List<Color> colors;
  final double animationValue;

  _ExactPathPainter({required this.colors, required this.animationValue});

  Path dashPath(Path source, {required double dashArray}) {
    final Path dest = Path();
    for (final ui.PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = dashArray;
        if (draw) {
          dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
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
    mainPath.moveTo(60, 170); // From Flag Center
    mainPath.cubicTo(60, 170, 80, 170, 120, 170); // to Node 1
    mainPath.cubicTo(160, 170, 100, 280, 160, 280); // to Node 2
    mainPath.cubicTo(120, 280, 280, 430, 240, 430); // to Node 3
    mainPath.cubicTo(280, 430, 120, 580, 160, 580); // to Node 4
    mainPath.cubicTo(120, 580, 280, 730, 240, 730); // to Node 5
    mainPath.cubicTo(280, 730, 120, 880, 160, 880); // to Node 6

    final dashedPath = Path();
    dashedPath.moveTo(160, 880);
    dashedPath.cubicTo(160, 950, 200, 950, 200, 1040); // to Treasure

    final realDashedPath = dashPath(dashedPath, dashArray: 8.0);

    const Rect bounds = Rect.fromLTRB(0, 0, 400, 1150);
    final LinearGradient gradient = LinearGradient(
      colors: colors,
      stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    // 1. Massive Glossy Blur Glow
    final glowPaint = Paint()
      ..shader = gradient.createShader(bounds)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 35
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawPath(mainPath, glowPaint);
    canvas.drawPath(realDashedPath, glowPaint);

    // 2. Thick White Inner Core
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(mainPath, corePaint);
    canvas.drawPath(realDashedPath, corePaint);
    
    // 3. Flowing magical particles on main path
    final metrics = mainPath.computeMetrics();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final totalLength = metric.length;

    // Draw larger glowing orbs that travel along the path
    for (int i = 0; i < 8; i++) {
      double progress = (animationValue + (i / 8.0)) % 1.0;
      double distance = progress * totalLength;
      final tangent = metric.getTangentForOffset(distance);
      if (tangent != null) {
        // Outer glow of orb
        final orbGlowPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.9)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
        canvas.drawCircle(tangent.position, 20.0, orbGlowPaint);
        
        // Inner core of orb
        final orbCorePaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(tangent.position, 10.0, orbCorePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ExactPathPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

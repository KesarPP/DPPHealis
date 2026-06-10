import 'package:flutter/material.dart';
import '../data/journey_data.dart';

class JourneyMap extends StatefulWidget {
  const JourneyMap({super.key});

  @override
  State<JourneyMap> createState() => _JourneyMapState();
}

class _JourneyMapState extends State<JourneyMap> with TickerProviderStateMixin {
  int? _expandedModule;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Fun colors for each module
  static const List<Color> _moduleColors = [
    Color(0xFF00897B), // teal - Module 1
    Color(0xFF1565C0), // blue - Module 2
    Color(0xFF6A1B9A), // purple - Module 3
    Color(0xFFE65100), // orange - Module 4
    Color(0xFF558B2F), // green - Module 5
  ];

  static const List<IconData> _moduleIcons = [
    Icons.local_dining,
    Icons.directions_run,
    Icons.psychology,
    Icons.self_improvement,
    Icons.emoji_events,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(journeyModules.length, (i) {
        final module = journeyModules[i];
        final isExpanded = _expandedModule == i;
        final isRight = i.isOdd;
        final isLast = i == journeyModules.length - 1;
        final color = _moduleColors[i % _moduleColors.length];
        final icon = _moduleIcons[i % _moduleIcons.length];

        return Column(
          crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Module bubble
            Padding(
                padding: EdgeInsets.only(
                  left: isRight ? 0 : 16,
                  right: isRight ? 16 : 0,
                ),
                child: GestureDetector(
                  onTap: module.state != ModuleState.locked
                      ? () => setState(
                          () => _expandedModule = isExpanded ? null : i)
                      : null,
                  child: _ModuleBubble(
                module: module,
                color: color,
                icon: icon,
                isExpanded: isExpanded,
                pulseAnimation: _pulseAnimation,
                  ),
                ),
            ),

            // Expanded session path
            if (isExpanded) ...[
              const SizedBox(height: 12),
              _SessionPath(
                sessions: module.sessions,
                color: color,
                pulseAnimation: _pulseAnimation,
              ),
              const SizedBox(height: 12),
            ],

            // Curved connector to next module
            if (!isLast)
              SizedBox(
                width: double.infinity,
                height: 70,
                child: CustomPaint(
                  painter: _WindyPathPainter(
                    startRight: isExpanded ? (module.sessions.length - 1).isOdd : isRight,
                    endRight: (i + 1).isOdd,
                    color: _moduleColors[(i + 1) % _moduleColors.length],
                    xOffset: 61,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Module bubble
// ══════════════════════════════════════════════════════════════

class _ModuleBubble extends StatelessWidget {
  final ModuleNode module;
  final Color color;
  final IconData icon;
  final bool isExpanded;
  final Animation<double> pulseAnimation;

  const _ModuleBubble({
    required this.module,
    required this.color,
    required this.icon,
    required this.isExpanded,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = module.state == ModuleState.locked;
    final isCurrent = module.state == ModuleState.current;
    final bubbleColor = isLocked ? const Color(0xFFCFD8DC) : color;

    Widget bubble = Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bubbleColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLocked ? Icons.lock_outline : icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'MODULE ${module.number}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
              if (!isLocked)
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white70,
                  size: 18,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            module.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isLocked
                  ? const Color(0xFF78909C)
                  : Colors.white,
              height: 1.3,
            ),
          ),
          if (!isLocked) ...[
            const SizedBox(height: 12),
            if (module.state == ModuleState.completed) ...[
              const Text('✓ Sessions Completed', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('✓ Module Quiz Passed', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
            ] else if (module.state == ModuleState.pendingQuiz) ...[
              const Text('✓ Sessions Completed', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.quiz_rounded, size: 16),
                label: const Text('Take Module Quiz', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '⚠️ Next module locked until quiz passed.',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '▶ In Progress',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );

    // Pulse animation for current module
    if (isCurrent) {
      bubble = AnimatedBuilder(
        animation: pulseAnimation,
        builder: (_, child) => Transform.scale(
          scale: pulseAnimation.value,
          child: child,
        ),
        child: bubble,
      );
    }

    return bubble;
  }
}

// ══════════════════════════════════════════════════════════════
// Session path
// ══════════════════════════════════════════════════════════════

class _SessionPath extends StatelessWidget {
  final List<SessionNode> sessions;
  final Color color;
  final Animation<double> pulseAnimation;

  const _SessionPath({
    required this.sessions,
    required this.color,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    const double verticalStride = 90.0;
    final double totalHeight = (sessions.isNotEmpty ? (sessions.length - 1) * verticalStride : 0) + 110.0;

    return Container(
      width: double.infinity,
      color: Colors.transparent, // Background now handled globally
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: totalHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _ContinuousPathPainter(
                    count: sessions.length,
                    color: color,
                    verticalStride: verticalStride,
                    xOffset: 45,
                    dotCenterY: 32,
                  ),
                ),
              ),
              // Quiz checkpoints halfway between sessions
              ...List.generate(sessions.length - 1, (i) {
                return Positioned(
                  top: i * verticalStride + 32 + 45 - 12, // 32 is dotCenterY, 45 is half stride, 12 is half height
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(color: color.withOpacity(0.3), blurRadius: 4, spreadRadius: 1),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.quiz_rounded, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                );
              }),
              ...List.generate(sessions.length, (i) {
                final session = sessions[i];
                final nodeOnRight = i.isOdd;

                return Positioned(
                  top: i * verticalStride,
                  left: nodeOnRight ? null : 0,
                  right: nodeOnRight ? 0 : null,
                  child: _SessionNode(
                    session: session,
                    color: color,
                    pulseAnimation: pulseAnimation,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Session node
// ══════════════════════════════════════════════════════════════

class _SessionNode extends StatelessWidget {
  final SessionNode session;
  final Color color;
  final Animation<double> pulseAnimation;

  const _SessionNode({
    required this.session,
    required this.color,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = session.state == SessionState.completed;
    final isCurrent = session.state == SessionState.current;
    final isLocked = session.state == SessionState.locked;

    Widget dot = Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isCompleted
            ? LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : isCurrent
            ? LinearGradient(
          colors: [Colors.white, color.withOpacity(0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isLocked ? const Color(0xFFECEFF1) : null,
        border: Border.all(
          color: isLocked ? const Color(0xFFB0BEC5) : color,
          width: isCurrent ? 3.5 : 2.5,
        ),
        boxShadow: isCompleted
            ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 14, spreadRadius: 3)]
            : isCurrent
            ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)]
            : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 28)
            : isCurrent
            ? Icon(Icons.play_arrow_rounded, color: color, size: 30)
            : Text(
          '${session.number}',   // 👈 shows number instead of lock icon
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFFB0BEC5),
          ),
        ),
      ),
    );

    if (isCurrent) {
      dot = AnimatedBuilder(
        animation: pulseAnimation,
        builder: (_, child) =>
            Transform.scale(scale: pulseAnimation.value, child: child),
        child: dot,
      );
    }

    return Column(
      children: [
        dot,
        const SizedBox(height: 4),
        SizedBox(
          width: 90,
          child: Text(
            session.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isLocked
                  ? const Color(0xFFB0BEC5)
                  : color,   // 👈 label now matches the node color
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Windy curved path painter
// ══════════════════════════════════════════════════════════════

class _WindyPathPainter extends CustomPainter {
  final bool startRight;
  final bool endRight;
  final Color color;
  final double xOffset;

  const _WindyPathPainter({
    required this.startRight,
    required this.endRight,
    required this.color,
    this.xOffset = 61,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final startX = startRight ? size.width - xOffset : xOffset;
    final endX = endRight ? size.width - xOffset : xOffset;

    path.moveTo(startX, 0);
    path.lineTo(startX, 15);
    path.cubicTo(
      startX, size.height * 0.5,
      endX, size.height * 0.5,
      endX, size.height - 15,
    );
    path.lineTo(endX, size.height);

    canvas.drawPath(path, paint);

    final metrics = path.computeMetrics().first;
    final totalLength = metrics.length;
    double distance = 0;
    const dashLength = 8.0;
    const gapLength = 6.0;
    bool drawing = true;

    while (distance < totalLength) {
      final end = distance + (drawing ? dashLength : gapLength);
      if (drawing) {
        final extractPath = metrics.extractPath(distance, end.clamp(0, totalLength));
        canvas.drawPath(extractPath, dotPaint);
      }
      distance = end;
      drawing = !drawing;
    }

    // Ensure path visually anchors into the module card edge
    final anchorPath = metrics.extractPath(totalLength - 4, totalLength);
    canvas.drawPath(anchorPath, dotPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ══════════════════════════════════════════════════════════════
// Map Grid Pattern Painter
// ══════════════════════════════════════════════════════════════
class MapGridPainter extends CustomPainter {
  final Color color;
  const MapGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const double gridSize = 20.0;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    for (double x = 0; x <= size.width; x += gridSize) {
      for (double y = 0; y <= size.height; y += gridSize) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MapGridPainter oldDelegate) => oldDelegate.color != color;
}

// ══════════════════════════════════════════════════════════════
// Continuous Path Painter
// ══════════════════════════════════════════════════════════════
class _ContinuousPathPainter extends CustomPainter {
  final int count;
  final Color color;
  final double verticalStride;
  final double xOffset;
  final double dotCenterY;

  _ContinuousPathPainter({
    required this.count,
    required this.color,
    required this.verticalStride,
    required this.xOffset,
    required this.dotCenterY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (count <= 1) return;

    final paint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    for (int i = 0; i < count - 1; i++) {
      final startRight = i.isOdd;
      final endRight = (i + 1).isOdd;

      final startX = startRight ? size.width - xOffset : xOffset;
      final endX = endRight ? size.width - xOffset : xOffset;
      
      final startY = i * verticalStride + dotCenterY;
      final endY = (i + 1) * verticalStride + dotCenterY;

      path.moveTo(startX, startY);
      
      path.cubicTo(
        startX, startY + (endY - startY) * 0.5,
        endX, startY + (endY - startY) * 0.5,
        endX, endY,
      );
    }

    canvas.drawPath(path, paint);

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      final totalLength = metric.length;
      double distance = 0;
      const dashLength = 8.0;
      const gapLength = 6.0;
      bool drawing = true;

      while (distance < totalLength) {
        final end = distance + (drawing ? dashLength : gapLength);
        if (drawing) {
          final extractPath = metric.extractPath(distance, end.clamp(0, totalLength));
          canvas.drawPath(extractPath, dotPaint);
        }
        distance = end;
        drawing = !drawing;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ContinuousPathPainter oldDelegate) => 
      oldDelegate.count != count || oldDelegate.color != color;
}

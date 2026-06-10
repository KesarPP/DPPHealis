import 'package:flutter/material.dart';
import 'dart:math' as math;
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
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(journeyModules.length, (i) {
        final module = journeyModules[i];
        final isExpanded = _expandedModule == i;
        final isRight = i.isOdd;
        final isLast = i == journeyModules.length - 1;

        return Column(
          crossAxisAlignment:
          isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Door
            GestureDetector(
              onTap: module.state != ModuleState.locked
                  ? () => setState(() => _expandedModule = isExpanded ? null : i)
                  : null,
              child: _DoorTile(module: module, isRight: isRight, isExpanded: isExpanded),
            ),

            // Expanded session path
            if (isExpanded) ...[
              const SizedBox(height: 8),
              _SessionPath(
                sessions: module.sessions,
                pulseAnimation: _pulseAnimation,
              ),
              const SizedBox(height: 8),
            ],

            // Curved connector to next door
            if (!isLast)
              SizedBox(
                width: double.infinity,
                height: 60,
                child: CustomPaint(
                  painter: _WindyPathPainter(goRight: !isRight),
                ),
              ),
          ],
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Door tile
// ══════════════════════════════════════════════════════════════

class _DoorTile extends StatelessWidget {
  final ModuleNode module;
  final bool isRight;
  final bool isExpanded;

  const _DoorTile({
    required this.module,
    required this.isRight,
    required this.isExpanded,
  });

  String get _doorAsset {
    switch (module.state) {
      case ModuleState.completed: return 'assets/images/door_completed.png';
      case ModuleState.current:   return 'assets/images/door_current.png';
      case ModuleState.locked:    return 'assets/images/door_locked.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = module.state == ModuleState.locked;
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // Label
        Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isLocked ? const Color(0xFFCFD8DC) : const Color(0xFF00897B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MODULE ${module.number}',
                style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2,
                  color: isLocked ? const Color(0xFF78909C) : Colors.white70,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                module.title,
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: isLocked ? const Color(0xFF546E7A) : Colors.white,
                ),
              ),
              if (!isLocked) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      isExpanded ? 'Hide sessions ▲' : 'View sessions ▼',
                      style: const TextStyle(
                        fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Door image — bigger!
        Image.asset(_doorAsset, width: 150, height: 185, fit: BoxFit.contain),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Session path (inside expanded module)
// ══════════════════════════════════════════════════════════════

class _SessionPath extends StatelessWidget {
  final List<SessionNode> sessions;
  final Animation<double> pulseAnimation;

  const _SessionPath({required this.sessions, required this.pulseAnimation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0F2F1), width: 2),
      ),
      child: Column(
        children: List.generate(sessions.length, (i) {
          final session = sessions[i];
          final isLast = i == sessions.length - 1;
          final nodeOnRight = i.isOdd;

          return Column(
            children: [
              Row(
                mainAxisAlignment: nodeOnRight
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  _SessionNode(session: session, pulseAnimation: pulseAnimation),
                ],
              ),
              if (!isLast)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: CustomPaint(
                    painter: _WindyPathPainter(goRight: nodeOnRight),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Session node
// ══════════════════════════════════════════════════════════════

class _SessionNode extends StatelessWidget {
  final SessionNode session;
  final Animation<double> pulseAnimation;

  const _SessionNode({required this.session, required this.pulseAnimation});

  @override
  Widget build(BuildContext context) {
    final isCompleted = session.state == SessionState.completed;
    final isCurrent   = session.state == SessionState.current;
    final isLocked    = session.state == SessionState.locked;

    Widget dot = Container(
      width: 64, height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? const Color(0xFF00897B)
            : isCurrent
            ? Colors.white
            : const Color(0xFFECEFF1),
        border: Border.all(
          color: isLocked ? const Color(0xFFB0BEC5) : const Color(0xFF00897B),
          width: isCurrent ? 3.5 : 2,
        ),
        boxShadow: isCompleted || isCurrent
            ? [BoxShadow(
            color: const Color(0xFF00897B).withOpacity(0.3),
            blurRadius: 10, spreadRadius: 2)]
            : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 28)
            : isCurrent
            ? const Icon(Icons.play_arrow_rounded, color: Color(0xFF00897B), size: 30)
            : const Icon(Icons.lock_outline, color: Color(0xFFB0BEC5), size: 24),
      ),
    );

    // Wrap current node in pulsing animation
    if (isCurrent) {
      dot = AnimatedBuilder(
        animation: pulseAnimation,
        builder: (_, child) => Transform.scale(
          scale: pulseAnimation.value,
          child: child,
        ),
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
                  : const Color(0xFF1A3A5C),
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
  final bool goRight;
  const _WindyPathPainter({required this.goRight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB0BEC5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Dashed effect
    final dashedPaint = Paint()
      ..color = const Color(0xFF00897B).withOpacity(0.4)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (goRight) {
      path.moveTo(32, 0);
      path.cubicTo(
        size.width * 0.2, size.height * 0.1,
        size.width * 0.8, size.height * 0.9,
        size.width - 32, size.height,
      );
    } else {
      path.moveTo(size.width - 32, 0);
      path.cubicTo(
        size.width * 0.8, size.height * 0.1,
        size.width * 0.2, size.height * 0.9,
        32, size.height,
      );
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, dashedPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
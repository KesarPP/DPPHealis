import 'dart:math' as math;
import 'package:flutter/material.dart';

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({super.key});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader>
    with TickerProviderStateMixin {
  late AnimationController _bellController;
  late Animation<double> _bellAngle;
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    
    // Bell ring animation
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _bellAngle = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.15).chain(CurveTween(curve: Curves.easeIn)), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 0.15, end: -0.13).chain(CurveTween(curve: Curves.easeInOut)), weight: 5),
      TweenSequenceItem(tween: Tween(begin: -0.13, end: 0.09).chain(CurveTween(curve: Curves.easeInOut)), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 0.09, end: -0.06).chain(CurveTween(curve: Curves.easeInOut)), weight: 5),
      TweenSequenceItem(tween: Tween(begin: -0.06, end: 0.02).chain(CurveTween(curve: Curves.easeInOut)), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 0.02, end: 0.0).chain(CurveTween(curve: Curves.easeOut)), weight: 5),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 10),
    ]).animate(_bellController);

    // ECG pulse dot animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _pulseScale = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _bellController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 18) return "Good afternoon";
    return "Good evening";
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // PR Avatar with Heartbeat ECG Ring
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              children: [
                // Outer circle tracking progress/design
                Positioned.fill(
                  child: CustomPaint(
                    painter: _AvatarRingPainter(),
                  ),
                ),
                // Inner Avatar container
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFDC2626), // Crimson
                          Color(0xFFF43F5E), // Rose
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'PR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
                // Pulse Dot container bottom-right
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulse glow ring
                        ScaleTransition(
                          scale: _pulseScale,
                          child: FadeTransition(
                            opacity: Tween<double>(begin: 0.8, end: 0.0).animate(_pulseController),
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDC2626),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        // Inner solid white-ringed red dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Greetings
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, Priya',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Your risk score improved again this week.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Bell button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Bell Icon with animated tilt
                  AnimatedBuilder(
                    animation: _bellAngle,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _bellAngle.value,
                        origin: const Offset(0, -8),
                        child: const Icon(
                          Icons.notifications_rounded,
                          size: 25,
                          color: Color(0xFF334155),
                        ),
                      );
                    },
                  ),
                  // Notification red dot badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444), // Coral
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 2.5) / 2;

    // Background circle (Blush light red)
    final bgPaint = Paint()
      ..color = const Color(0xFFFEE2E2)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    // Active arc gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final activePaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFDC2626), // Crimson
          Color(0xFFF43F5E), // Rose
          Color(0xFFDC2626),
        ],
      ).createShader(rect)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw active portion of the ring
    const startAngle = -math.pi / 2;
    const sweepAngle = 2.2; // about 138 in dasharray
    canvas.drawArc(rect, startAngle, sweepAngle, false, activePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

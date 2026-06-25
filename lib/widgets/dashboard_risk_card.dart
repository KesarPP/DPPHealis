import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../data/gelato_theme.dart';
import '../data/app_state.dart';

class DashboardRiskCard extends StatefulWidget {
  const DashboardRiskCard({super.key});

  @override
  State<DashboardRiskCard> createState() => _DashboardRiskCardState();
}

class _DashboardRiskCardState extends State<DashboardRiskCard> with TickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    // Beating Heart animation (scales up/down)
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
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    if (!authService.isFirebaseInitialized || authService.currentUser == null) {
      return _buildCard(AppState.idrsScore);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(authService.currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        int score = AppState.idrsScore;
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('idrsScore')) {
            score = data['idrsScore'] ?? 0;
            AppState.idrsScore = score;
            AppState.hasIdrsResult = data['hasIdrsResult'] == true;
          }
        }
        return _buildCard(score);
      },
    );
  }

  Widget _buildCard(int score) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8F0), // Very light pink
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Glossy Heart Badge
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFFDA4AF), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFDA4AF).withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _heartScale,
                builder: (context, _) {
                  return Transform.scale(
                    scale: _heartScale.value,
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: CustomPaint(
                        painter: _StaticGlossyHeartPainter(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 2. Score info
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Risk Score',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$score',
                        style: const TextStyle(
                          color: Color(0xFFE11D48), // Deep Red
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const Text(
                        ' /100',
                        style: TextStyle(
                          color: Color(0xFF9F1239),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Moderate Risk Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED), // Light orange
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDBA74), width: 1),
                        ),
                        child: const Text(
                          'Moderate Risk',
                          style: TextStyle(
                            color: Color(0xFFEA580C),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_downward_rounded, color: GelatoTheme.greenDark, size: 12),
                      SizedBox(width: 2),
                      Text(
                        '6 points improved this week',
                        style: TextStyle(
                          color: GelatoTheme.greenDark,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 3. Slider
          Expanded(
            flex: 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 20,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Gradient track
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF22C55E), // Green
                              Color(0xFFEAB308), // Yellow
                              Color(0xFFEF4444), // Red
                            ],
                            stops: [0.1, 0.5, 0.9],
                          ),
                        ),
                      ),
                      // Thumb
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: score / 100, // e.g. 0.42
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE11D48),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Labels
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _RiskLabel(title: 'Low', range: '0-30'),
                      SizedBox(width: 8),
                      _RiskLabel(title: 'Moderate', range: '31-60'),
                      SizedBox(width: 8),
                      _RiskLabel(title: 'High', range: '61-100'),
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

class _RiskLabel extends StatelessWidget {
  final String title;
  final String range;
  const _RiskLabel({required this.title, required this.range});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: GelatoTheme.textDark)),
        Text(range, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: GelatoTheme.textLight)),
      ],
    );
  }
}

// Static painter matching the exact visual of the requested heart
class _StaticGlossyHeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final s = width / 64.0; 

    // 1. Draw shiny glossy heart with radial gradient
    final rect = Rect.fromLTWH(0, 0, width, height);
    final paintHeart = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.4),
        radius: 0.8,
        colors: [
          Color(0xFFFFB4B4), // light pink
          Color(0xFFF43F5E), // rose
          Color(0xFF9F1239), // dark red
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final heartPath = Path();
    heartPath.moveTo(32 * s, 56 * s);
    heartPath.cubicTo(10 * s, 40 * s, 4 * s, 26 * s, 14 * s, 17 * s);
    heartPath.cubicTo(22 * s, 10 * s, 30 * s, 14 * s, 32 * s, 20 * s);
    heartPath.cubicTo(34 * s, 14 * s, 42 * s, 10 * s, 50 * s, 17 * s);
    heartPath.cubicTo(60 * s, 26 * s, 54 * s, 40 * s, 32 * s, 56 * s);
    heartPath.close();

    canvas.drawPath(heartPath, paintHeart);

    // 2. Glossy white highlight curve at the top-left lobe
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    final highlightPath = Path();
    highlightPath.moveTo(18 * s, 18 * s);
    highlightPath.cubicTo(22 * s, 14 * s, 28 * s, 14 * s, 30 * s, 18 * s);
    highlightPath.cubicTo(27 * s, 18 * s, 22 * s, 21 * s, 20 * s, 25 * s);
    highlightPath.cubicTo(18 * s, 22 * s, 17 * s, 20 * s, 18 * s, 18 * s);
    highlightPath.close();
    canvas.drawPath(highlightPath, highlightPaint);

    // 3. Static ECG line (drawn directly on heart)
    final ecgPoints = [
      Offset(11 * s, 33 * s),
      Offset(18 * s, 33 * s),
      Offset(21 * s, 26 * s),
      Offset(26 * s, 40 * s),
      Offset(32 * s, 20 * s),
      Offset(38 * s, 44 * s),
      Offset(43 * s, 33 * s),
      Offset(53 * s, 33 * s),
    ];

    final ecgPath = Path();
    ecgPath.moveTo(ecgPoints[0].dx, ecgPoints[0].dy);
    for (int i = 1; i < ecgPoints.length; i++) {
      ecgPath.lineTo(ecgPoints[i].dx, ecgPoints[i].dy);
    }

    // Shadow for ECG line to make it pop
    final ecgShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..strokeWidth = 2.5 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(ecgPath.shift(Offset(0, 1.5 * s)), ecgShadow);

    final ecgPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(ecgPath, ecgPaint);
  }

  @override
  bool shouldRepaint(covariant _StaticGlossyHeartPainter oldDelegate) => false;
}

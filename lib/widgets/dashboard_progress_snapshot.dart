import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DashboardProgressSnapshot extends StatefulWidget {
  const DashboardProgressSnapshot({super.key});

  @override
  State<DashboardProgressSnapshot> createState() => _DashboardProgressSnapshotState();
}

class _DashboardProgressSnapshotState extends State<DashboardProgressSnapshot> {
  String? _expandedKey;

  final Map<String, _MetricData> _metrics = {
    'meals': _MetricData(
      key: 'meals',
      label: 'Meals Logged',
      icon: Icons.restaurant_rounded,
      value: 3.0,
      max: 4.0,
      unit: 'meals',
      color: const Color(0xFF10B981), // Emerald green
      bgLight: const Color(0xFFECFDF5),
      bgTint: const Color(0x1A10B981),
      history: [3, 4, 3, 4, 3],
      insight: 'Consistent protein distribution. 1 meal left to hit your daily goal!',
    ),
    'activity': _MetricData(
      key: 'activity',
      label: 'Activity',
      icon: Icons.directions_run_rounded,
      value: 28.0,
      max: 30.0,
      unit: 'mins',
      color: const Color(0xFFF97316), // Vibrant orange
      bgLight: const Color(0xFFFFF7ED),
      bgTint: const Color(0x1AF97316),
      history: [30, 45, 15, 35, 28],
      insight: 'Almost there! A quick 2-minute walk will complete your daily circle.',
    ),
    'water': _MetricData(
      key: 'water',
      label: 'Water Intake',
      icon: Icons.local_drink_rounded,
      value: 6.0,
      max: 8.0,
      unit: 'classes',
      color: const Color(0xFF3B82F6), // Sapphire blue
      bgLight: const Color(0xFFEFF6FF),
      bgTint: const Color(0x1A3B82F6),
      history: [8, 7, 8, 6, 6],
      insight: 'Hydration is looking steady. Sip some water now to maintain momentum.',
    ),
    'sleep': _MetricData(
      key: 'sleep',
      label: 'Sleep',
      icon: Icons.bedtime_rounded,
      value: 7.5,
      max: 8.0,
      unit: 'hours',
      color: const Color(0xFF8B5CF6), // Purple
      bgLight: const Color(0xFFF5F3FF),
      bgTint: const Color(0x1A8B5CF6),
      history: [8.0, 7.0, 7.8, 8.2, 7.5],
      insight: 'Great deep sleep percentage (22%) recorded last night. You are well recovered.',
    ),
  };

  void _increment(String key, double step) {
    HapticFeedback.lightImpact();
    setState(() {
      final m = _metrics[key]!;
      m.value = (m.value + step).clamp(0.0, m.max * 2.0);
      // round to 1 decimal place
      m.value = double.parse(m.value.toStringAsFixed(1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final days = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
    final now = DateTime.now();
    final dateString = "${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]}";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Progress",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Click any card to log or view insights",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Text(
                      dateString,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Cards List/Grid Layout
          Column(
            children: [
              // Rows
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildCard('meals')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildCard('activity')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildCard('water')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildCard('sleep')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String key) {
    final m = _metrics[key]!;
    final isExpanded = _expandedKey == key;
    final pct = ((m.value / m.max) * 100).round();

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _expandedKey = isExpanded ? null : key;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isExpanded ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
              width: isExpanded ? 2.0 : 1.0,
            ),
            boxShadow: isExpanded
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header of card (Ring and values side by side)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Circular Ring
                  SizedBox(
                    width: 58,
                    height: 58,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: m.value / m.max),
                          duration: const Duration(milliseconds: 700),
                          builder: (context, value, _) {
                            return CustomPaint(
                              painter: _CircularProgressPainter(
                                value: value.clamp(0.0, 1.0),
                                color: m.color,
                                trackColor: const Color(0xFFF1F5F9),
                                strokeWidth: 5.0,
                              ),
                            );
                          },
                        ),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: m.bgLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            m.icon,
                            color: m.color,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Value display
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          textAlign: TextAlign.right,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${m.value % 1 == 0 ? m.value.toInt() : m.value} ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              TextSpan(
                                text: '/ ${m.max % 1 == 0 ? m.max.toInt() : m.max}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          m.unit.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Bottom card footer info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: m.bgTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$pct% MET',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: m.color,
                      ),
                    ),
                  ),
                  Text(
                    isExpanded ? 'COLLAPSE' : 'LOG',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFCBD5E1),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              // Expanded Panel
              if (isExpanded) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // Quick Log Controls
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 14, color: m.color),
                          const SizedBox(width: 4),
                          Text(
                            'Quick Log ${m.unit}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _increment(key, key == 'sleep' ? -0.5 : -1.0),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.remove, size: 14, color: Color(0xFF64748B)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${m.value}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _increment(key, key == 'sleep' ? 0.5 : 1.0),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, size: 14, color: Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Sparkline
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LAST 5 DAYS',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Average: ${(m.history.reduce((a, b) => a + b) / m.history.length).toStringAsFixed(1)} ${m.unit}',
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: SizedBox(
                        width: 80,
                        height: 24,
                        child: CustomPaint(
                          painter: _SparklinePainter(
                            data: [...m.history, m.value],
                            color: m.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Insight box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: m.bgTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          m.insight,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: m.color,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.value,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
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

    // Active
    final activePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

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
    return oldDelegate.value != value;
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final width = size.width;
    final height = size.height;

    final minVal = data.reduce(math.min);
    final maxVal = data.reduce(math.max);
    final span = maxVal - minVal == 0 ? 1.0 : (maxVal - minVal);

    final stepX = width / (data.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      // scale within height, leaving some margin
      final y = height - ((data[i] - minVal) / span) * (height - 4) - 2;
      points.add(Offset(x, y));
    }

    // Draw area under line with soft opacity
    final fillPath = Path();
    fillPath.moveTo(0, height);
    fillPath.lineTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final p = points[i];
      final prev = points[i - 1];
      final cx = (prev.dx + p.dx) / 2;
      final cy = (prev.dy + p.dy) / 2;
      fillPath.quadraticBezierTo(prev.dx, prev.dy, cx, cy);
    }
    fillPath.lineTo(points.last.dx, points.last.dy);
    fillPath.lineTo(width, height);
    fillPath.close();

    final fillPaint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final p = points[i];
      final prev = points[i - 1];
      final cx = (prev.dx + p.dx) / 2;
      final cy = (prev.dy + p.dy) / 2;
      linePath.quadraticBezierTo(prev.dx, prev.dy, cx, cy);
    }
    linePath.lineTo(points.last.dx, points.last.dy);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => false;
}

class _MetricData {
  final String key;
  final String label;
  final IconData icon;
  double value;
  final double max;
  final String unit;
  final Color color;
  final Color bgLight;
  final Color bgTint;
  final List<double> history;
  final String insight;

  _MetricData({
    required this.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.max,
    required this.unit,
    required this.color,
    required this.bgLight,
    required this.bgTint,
    required this.history,
    required this.insight,
  });
}

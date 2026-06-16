import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/gelato_theme.dart';
import '../data/app_state.dart';
import '../screens/weigh_in_screen.dart';
import '../main.dart';

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
      color: GelatoTheme.green,
      colorDark: GelatoTheme.greenDark,
      bgLight: const Color(0xFFF2F7EC),
      bgTint: const Color(0x2BD6E5BD),
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
      color: GelatoTheme.orange,
      colorDark: GelatoTheme.orangeDark,
      bgLight: const Color(0xFFFFF6ED),
      bgTint: const Color(0x2BFFDAB4),
      history: [30, 45, 15, 35, 28],
      insight: 'Almost there! A quick 2-minute walk will complete your daily circle.',
    ),
    'weigh_in': _MetricData(
      key: 'weigh_in',
      label: 'Weekly Weigh-In',
      icon: Icons.scale_rounded,
      value: 78.4,
      max: 72.0,
      unit: 'kg',
      color: GelatoTheme.blue,
      colorDark: GelatoTheme.blueDark,
      bgLight: const Color(0xFFF2F6FA),
      bgTint: const Color(0x2BBCD8EC),
      history: [82.5, 81.8, 81.2, 80.5, 79.8],
      insight: 'Your weight is trending down! Tap to log or view weight progress.',
    ),
    'results': _MetricData(
      key: 'results',
      label: 'Results',
      icon: Icons.assignment_turned_in_rounded,
      value: 42.0,
      max: 90.0,
      unit: 'IDRS',
      color: GelatoTheme.purple,
      colorDark: GelatoTheme.purpleDark,
      bgLight: const Color(0xFFF6F2FA),
      bgTint: const Color(0x2BDCCCEC),
      history: [42.0, 42.0, 42.0, 42.0, 42.0],
      insight: 'Your IDRS and GPAQ assessment results. Keep active to improve your scores!',
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
    if (_metrics.containsKey('results')) {
      _metrics['results']!.value = AppState.idrsScore.toDouble();
    }
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final days = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
    final now = DateTime.now();
    final dateString = "${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]}";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
            children: _buildCardLayout(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCardLayout() {
    final List<String> keys = ['meals', 'activity', 'weigh_in', 'results'];
    final List<List<String>> rows = [];
    List<String> currentRow = [];
    int currentSpan = 0;
    for (final key in keys) {
      final span = (key == _expandedKey) ? 2 : 1;
      if (currentSpan + span > 2) {
        rows.add(currentRow);
        currentRow = [key];
        currentSpan = span;
      } else {
        currentRow.add(key);
        currentSpan += span;
      }
    }
    if (currentRow.isNotEmpty) rows.add(currentRow);

    final List<Widget> children = [];
    for (int i = 0; i < rows.length; i++) {
      final rowKeys = rows[i];
      if (i > 0) children.add(const SizedBox(height: 12));
      if (rowKeys.length == 2) {
        children.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildCard(rowKeys[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildCard(rowKeys[1])),
          ],
        ));
      } else {
        final key = rowKeys[0];
        if (key == _expandedKey) {
          children.add(_buildCard(key));
        } else {
          children.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildCard(key)),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ));
        }
      }
    }
    return children;
  }

  Widget _buildCard(String key) {
    final m = _metrics[key]!;
    final isExpanded = _expandedKey == key;
    final progressRatio = key == 'weigh_in'
        ? ((82.5 - m.value) / (82.5 - m.max)).clamp(0.0, 1.0)
        : (m.value / m.max);
    final pct = (progressRatio * 100).round();

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          if (key == 'weigh_in') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WeighInScreen()),
            );
          } else if (key == 'meals') {
            MainShell.of(context)?.selectedIndex = 1;
          } else if (key == 'activity') {
            MainShell.of(context)?.selectedIndex = 2;
          } else {
            setState(() {
              _expandedKey = isExpanded ? null : key;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: m.color,
            borderRadius: BorderRadius.circular(20),
            border: GelatoTheme.cardBorder,
            boxShadow: GelatoTheme.cardShadow,
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
                          tween: Tween(begin: 0, end: progressRatio),
                          duration: const Duration(milliseconds: 700),
                          builder: (context, value, _) {
                            return CustomPaint(
                              painter: _CircularProgressPainter(
                                value: value.clamp(0.0, 1.0),
                                color: m.colorDark,
                                trackColor: Colors.white.withValues(alpha: 0.45),
                                strokeWidth: 5.0,
                              ),
                            );
                          },
                        ),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            m.icon,
                            color: m.colorDark,
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
                      mainAxisSize: MainAxisSize.min,
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
                                  color: GelatoTheme.textDark,
                                ),
                              ),
                              TextSpan(
                                text: '/ ${m.max % 1 == 0 ? m.max.toInt() : m.max}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: GelatoTheme.textMuted,
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
                            color: GelatoTheme.textLight,
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
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      key == 'weigh_in' ? '$pct% GOAL' : (key == 'results' ? 'RESULTS' : '$pct% MET'),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: m.colorDark,
                      ),
                    ),
                  ),
                  Text(
                    isExpanded ? 'COLLAPSE' : (key == 'weigh_in' || key == 'results' ? 'VIEW' : 'LOG'),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: m.colorDark.withValues(alpha: 0.75),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              // Expanded Panel
              if (isExpanded) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: Colors.black12),
                const SizedBox(height: 12),
                if (key == 'results') ...[
                  // IDRS Row
                  _buildResultRow(
                    context: context,
                    title: 'IDRS Risk Score',
                    value: '${AppState.idrsScore} / 90',
                    subtitle: AppState.idrsScore < 30
                        ? 'Low Risk'
                        : (AppState.idrsScore <= 50 ? 'Moderate Risk' : 'High Risk'),
                    color: AppState.idrsScore < 30
                        ? GelatoTheme.greenDark
                        : (AppState.idrsScore <= 50 ? GelatoTheme.yellowDark : GelatoTheme.pinkDark),
                    bgColor: AppState.idrsScore < 30
                        ? GelatoTheme.green
                        : (AppState.idrsScore <= 50 ? GelatoTheme.yellow : GelatoTheme.pink),
                    icon: Icons.assignment_turned_in_rounded,
                  ),
                  const SizedBox(height: 10),
                  // GPAQ Row
                  _buildResultRow(
                    context: context,
                    title: 'GPAQ Activity',
                    value: '${AppState.gpaqMetMinutes} MET-min',
                    subtitle: AppState.gpaqLevel,
                    color: AppState.gpaqLevel.contains('High')
                        ? GelatoTheme.greenDark
                        : (AppState.gpaqLevel.contains('Moderate') ? GelatoTheme.yellowDark : GelatoTheme.pinkDark),
                    bgColor: AppState.gpaqLevel.contains('High')
                        ? GelatoTheme.green
                        : (AppState.gpaqLevel.contains('Moderate') ? GelatoTheme.yellow : GelatoTheme.pink),
                    icon: Icons.directions_run_rounded,
                  ),
                ] else ...[
                  // Quick Log Controls
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, size: 14, color: m.colorDark),
                            const SizedBox(width: 4),
                            Text(
                              'Quick Log ${m.unit}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: GelatoTheme.textDark,
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
                                child: const Icon(Icons.remove, size: 14, color: GelatoTheme.textLight),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${m.value}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: GelatoTheme.textDark,
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
                                child: const Icon(Icons.add, size: 14, color: GelatoTheme.textLight),
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
                              color: GelatoTheme.textLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Average: ${(m.history.reduce((a, b) => a + b) / m.history.length).toStringAsFixed(1)} ${m.unit}',
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: GelatoTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 1.2),
                        ),
                        child: SizedBox(
                          width: 80,
                          height: 24,
                          child: CustomPaint(
                            painter: _SparklinePainter(
                              data: [...m.history, m.value],
                              color: m.colorDark,
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
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 1.2),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, size: 14, color: m.colorDark),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            m.insight,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: m.colorDark,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.2),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: GelatoTheme.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: GelatoTheme.textDark,
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
      ..color = color.withValues(alpha: 0.08)
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
  final Color colorDark;
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
    required this.colorDark,
    required this.bgLight,
    required this.bgTint,
    required this.history,
    required this.insight,
  });
}

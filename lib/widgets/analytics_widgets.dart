import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/gelato_theme.dart';

// ============================================================================
// Weekly Trend Chart Card
// ============================================================================
class WeeklyTrendChartCard extends StatefulWidget {
  const WeeklyTrendChartCard({super.key});

  @override
  State<WeeklyTrendChartCard> createState() => _WeeklyTrendChartCardState();
}

class _WeeklyTrendChartCardState extends State<WeeklyTrendChartCard> {
  bool _showNetCalories = false;
  int _touchedIndex = -1;

  final List<double> _grossCalories = [1800, 2100, 1950, 2000, 2500, 2800, 1900];
  final List<double> _netCalories = [1500, 1800, 1600, 1750, 2100, 2400, 1650];

  @override
  Widget build(BuildContext context) {
    final data = _showNetCalories ? _netCalories : _grossCalories;
    // Light background so the bright analytics pop
    final bgColor = Colors.white; 
    // Dark green line graph as requested
    final chartColor = Colors.green.shade800;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      height: 280,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _showNetCalories ? 'Avg Net: 1,820 kcal' : 'Avg: 2,150 kcal',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: GelatoTheme.textDark,
                ),
              ),
              // Toggle
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showNetCalories = !_showNetCalories;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: GelatoTheme.textDark, width: 1.5),
                  ),
                  child: Text(
                    _showNetCalories ? 'Net Cal' : 'Gross Cal',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: GelatoTheme.textDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => GelatoTheme.textDark,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        return LineTooltipItem(
                          '${touchedSpot.y.toInt()} kcal',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        );
                      }).toList();
                    },
                  ),
                  touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                    if (response?.lineBarSpots != null && event.isInterestedForInteractions) {
                      setState(() {
                        _touchedIndex = response!.lineBarSpots![0].spotIndex;
                      });
                    } else {
                      setState(() {
                        _touchedIndex = -1;
                      });
                    }
                  },
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 500,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.black.withValues(alpha: 0.05),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 1000,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toStringAsFixed(1)}k',
                          style: TextStyle(
                            color: GelatoTheme.textDark.withValues(alpha: 0.6),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          final isTouched = value.toInt() == _touchedIndex;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[value.toInt()],
                              style: TextStyle(
                                color: isTouched ? chartColor : GelatoTheme.textDark.withValues(alpha: 0.6),
                                fontSize: 11,
                                fontWeight: isTouched ? FontWeight.w900 : FontWeight.w700,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 3000,
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: chartColor,
                    barWidth: 5,
                    shadow: const Shadow(
                      color: Colors.black87, // High contrast shadow
                      offset: Offset(2, 4),
                      blurRadius: 4,
                    ),
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: _touchedIndex == index ? 6 : 4,
                          color: chartColor,
                          strokeWidth: 2,
                          strokeColor: Colors.black87, // Black border for points
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          chartColor.withValues(alpha: 0.5),
                          chartColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 2000,
                      color: GelatoTheme.textDark.withValues(alpha: 0.3),
                      strokeWidth: 2,
                      dashArray: [4, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 5, bottom: 5),
                        style: TextStyle(
                          color: GelatoTheme.textDark.withValues(alpha: 0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        labelResolver: (line) => 'GOAL',
                      ),
                    ),
                  ],
                ),
              ),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Macros Breakdown Card (Donut Chart)
// ============================================================================
class MacrosBreakdownCard extends StatefulWidget {
  const MacrosBreakdownCard({super.key});

  @override
  State<MacrosBreakdownCard> createState() => _MacrosBreakdownCardState();
}

class _MacrosBreakdownCardState extends State<MacrosBreakdownCard> {
  int _touchedIndex = -1;
  bool _showPercentages = true;

  final List<Map<String, dynamic>> _macroData = [
    {'name': 'Protein', 'value': 110.0, 'target': 150.0, 'color': GelatoTheme.purple},
    {'name': 'Carbs', 'value': 220.0, 'target': 250.0, 'color': GelatoTheme.yellow},
    {'name': 'Fats', 'value': 65.0, 'target': 70.0, 'color': GelatoTheme.pink},
  ];

  @override
  Widget build(BuildContext context) {
    double total = _macroData.fold(0, (sum, item) => sum + item['value']);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: GelatoTheme.blueDark, // Dark shade of blue
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _CardPatternPainter(color: Colors.white.withValues(alpha: 0.05)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
          // Header / Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Macros',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: GelatoTheme.yellow, // Gelato pastel colour
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showPercentages = !_showPercentages;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: GelatoTheme.pink, width: 1.5),
                  ),
                  child: Text(
                    _showPercentages ? '%' : 'grams',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: GelatoTheme.pink,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Donut Chart
          Container(
            height: 180,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    startDegreeOffset: 180,
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 4,
                    centerSpaceRadius: 50,
                    sections: List.generate(3, (i) {
                      final isTouched = i == _touchedIndex;
                      final radius = isTouched ? 35.0 : 25.0;
                      final data = _macroData[i];
                      final value = data['value'] as double;
                      final color = data['color'] as Color;

                      return PieChartSectionData(
                        color: color,
                        value: value,
                        title: '', 
                        radius: radius,
                        borderSide: const BorderSide(color: Colors.black87, width: 2), // High contrast black borders
                        badgeWidget: isTouched
                            ? Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: GelatoTheme.textDark, width: 2),
                                  boxShadow: GelatoTheme.cardShadow,
                                ),
                                child: Icon(Icons.bolt, size: 16, color: GelatoTheme.textDark),
                              )
                            : null,
                        badgePositionPercentageOffset: 1.1,
                      );
                    }),
                  ),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                ),
                // Center Text
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _touchedIndex == -1
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            key: const ValueKey('total'),
                            children: [
                              Text(
                                '${total.toInt()}g',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: GelatoTheme.pink,
                                  letterSpacing: -1,
                                ),
                              ),
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: GelatoTheme.blue,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            key: ValueKey('touched_$_touchedIndex'),
                            children: [
                              Text(
                                _showPercentages
                                    ? '${((_macroData[_touchedIndex]['value'] / total) * 100).toStringAsFixed(0)}%'
                                    : '${_macroData[_touchedIndex]['value'].toInt()}g',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: GelatoTheme.pink,
                                  letterSpacing: -1,
                                ),
                              ),
                              Text(
                                _macroData[_touchedIndex]['name'],
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: GelatoTheme.blue,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _macroData.asMap().entries.map((entry) {
              final idx = entry.key;
              final data = entry.value;
              final isTouched = _touchedIndex == idx;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _touchedIndex = isTouched ? -1 : idx;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isTouched ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isTouched ? data['color'] as Color : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: data['color'],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black87, width: 1.5),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        data['name'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isTouched ? FontWeight.w900 : FontWeight.w800,
                          color: data['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Nutrition Score Card
// ============================================================================
class NutritionScoreCard extends StatefulWidget {
  const NutritionScoreCard({super.key});

  @override
  State<NutritionScoreCard> createState() => _NutritionScoreCardState();
}

class _NutritionScoreCardState extends State<NutritionScoreCard> {
  bool _expanded = false;
  int _touchedSpotIndex = -1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9C4), // Pastel yellow
          borderRadius: GelatoTheme.cardRadius,
          border: GelatoTheme.cardBorder,
          boxShadow: GelatoTheme.cardShadow,
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 0.85),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: GelatoTheme.purple, width: 2.5),
                            ),
                          ),
                          CircularProgressIndicator(
                            value: value,
                            strokeWidth: 10,
                            backgroundColor: Colors.black12,
                            color: GelatoTheme.pinkBright, // red/pink tone
                            strokeCap: StrokeCap.round,
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  (value * 100).toInt().toString(),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: GelatoTheme.blueDark,
                                    letterSpacing: -1,
                                  ),
                                ),
                                const Text(
                                  '/100',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Great Balance!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: GelatoTheme.greenDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your nutrition is on track. Tap to see everyday trend.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: GelatoTheme.blueDark,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(Icons.expand_more_rounded, color: GelatoTheme.purple),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ClipRect(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                heightFactor: _expanded ? 1.0 : 0.0,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const Divider(color: Colors.black12, height: 1, thickness: 1.5),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 140,
                      child: ScatterChart(
                        ScatterChartData(
                          scatterSpots: [
                            {'x': 0.0, 'y': 75.0, 'color': GelatoTheme.blueBright, 'radius': 8.0},
                            {'x': 1.0, 'y': 45.0, 'color': GelatoTheme.greenBright, 'radius': 12.0},
                            {'x': 2.0, 'y': 85.0, 'color': GelatoTheme.pinkBright, 'radius': 6.0},
                            {'x': 3.0, 'y': 60.0, 'color': GelatoTheme.purpleBright, 'radius': 14.0},
                            {'x': 4.0, 'y': 95.0, 'color': GelatoTheme.pinkBright, 'radius': 16.0},
                            {'x': 5.0, 'y': 50.0, 'color': GelatoTheme.blueBright, 'radius': 7.0},
                            {'x': 6.0, 'y': 80.0, 'color': GelatoTheme.greenBright, 'radius': 13.0},
                          ].asMap().entries.map((entry) {
                            final isTouched = entry.key == _touchedSpotIndex;
                            final data = entry.value;
                            final baseRadius = data['radius'] as double;
                            final color = data['color'] as Color;
                            return ScatterSpot(
                              data['x'] as double,
                              data['y'] as double,
                              dotPainter: FlDotCirclePainter(
                                color: color.withValues(alpha: isTouched ? 1.0 : 0.7),
                                strokeColor: Colors.white.withValues(alpha: 0.9),
                                strokeWidth: isTouched ? 4 : 2,
                                radius: isTouched ? baseRadius + 4 : baseRadius,
                              ),
                            );
                          }).toList(),
                          minX: -0.5,
                          maxX: 6.5,
                          minY: 0,
                          maxY: 115,
                          borderData: FlBorderData(
                            show: true,
                            border: const Border(
                              bottom: BorderSide(color: Colors.black26, width: 1.5),
                              left: BorderSide(color: Colors.black26, width: 1.5),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 20,
                            getDrawingHorizontalLine: (value) {
                              if (value > 100) return const FlLine(color: Colors.transparent);
                              return const FlLine(color: Colors.black12, strokeWidth: 1);
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  if (value != value.roundToDouble()) return const SizedBox.shrink();
                                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        days[value.toInt()],
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: 20,
                                getTitlesWidget: (value, meta) {
                                  if (value > 100) return const SizedBox.shrink();
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          scatterTouchData: ScatterTouchData(
                            enabled: true,
                            handleBuiltInTouches: true,
                            touchTooltipData: ScatterTouchTooltipData(
                              getTooltipColor: (spot) => GelatoTheme.blueDark,
                              getTooltipItems: (touchedSpot) {
                                return ScatterTooltipItem(
                                  'Score: ${touchedSpot.y.toInt()}',
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  bottomMargin: 8,
                                );
                              },
                            ),
                            touchCallback: (FlTouchEvent event, ScatterTouchResponse? touchResponse) {
                              if (touchResponse?.touchedSpot != null && event.isInterestedForInteractions) {
                                setState(() {
                                  _touchedSpotIndex = touchResponse!.touchedSpot!.spotIndex;
                                });
                              } else {
                                setState(() {
                                  _touchedSpotIndex = -1;
                                });
                              }
                            },
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
      ),
    );
  }
}

// ============================================================================
// Card Pattern Painter
// ============================================================================
class _CardPatternPainter extends CustomPainter {
  final Color color;
  _CardPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    const spacing = 20.0;
    const radius = 2.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

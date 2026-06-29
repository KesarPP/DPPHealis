import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/gelato_theme.dart';
import 'package:provider/provider.dart';
import '../providers/food_notifiers.dart';
// ============================================================================
// Weekly Trend Chart Card
// ============================================================================
class WeeklyTrendChartCard extends StatefulWidget {
  const WeeklyTrendChartCard({super.key});

  @override
  State<WeeklyTrendChartCard> createState() => _WeeklyTrendChartCardState();
}

class _WeeklyTrendChartCardState extends State<WeeklyTrendChartCard> {
  int _touchedIndex = -1;
  @override
  Widget build(BuildContext context) {
    final foodNotifier = context.watch<FoodDiaryNotifier>();
    
    final List<double> grossCalories = List.filled(7, 0.0);
    double totalLast7Days = 0.0;
    int countDays = 0;
    
    DateTime now = DateTime.now();
    final String todayStr = now.toIso8601String().split('T')[0];
    for (int i = 0; i < 7; i++) {
      DateTime d = now.subtract(Duration(days: 6 - i));
      String dateStr = d.toIso8601String().split('T')[0];
      
      final log = foodNotifier.allLogsList.where((l) => l.date == dateStr).firstOrNull;
      if (log != null) {
        grossCalories[i] = log.totalCalories;
      }
      
      // Override if it's the currently selected date or today's active snapshot
      if (foodNotifier.selectedDate == dateStr && foodNotifier.dailyLog != null) {
        grossCalories[i] = foodNotifier.dailyLog!.totalCalories;
      } else if (dateStr == todayStr && foodNotifier.dailyLog != null && foodNotifier.dailyLog!.date == todayStr) {
        grossCalories[i] = foodNotifier.dailyLog!.totalCalories;
      }
      
      if (grossCalories[i] > 0) {
        totalLast7Days += grossCalories[i];
        countDays++;
      }
    }
    
    double avg = countDays > 0 ? totalLast7Days / countDays : 0.0;
    final data = grossCalories;
    // Light background so the bright analytics pop
    const bgColor = Colors.white; 
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
                'Daily Intake Trend (Avg: ${avg.toStringAsFixed(0)} kcal)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: GelatoTheme.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade800, width: 1.5),
                ),
                child: Text(
                  'Live Data',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.green.shade800,
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
                        if (value.toInt() >= 0 && value.toInt() <= 6) {
                          final isTouched = value.toInt() == _touchedIndex;
                          final d = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                          const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          final label = value.toInt() == 6 ? 'Today' : weekDays[d.weekday - 1];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              label,
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
                maxY: (grossCalories.fold(0.0, (m, c) => c > m ? c : m) > foodNotifier.calorieGoal
                        ? grossCalories.fold(0.0, (m, c) => c > m ? c : m)
                        : foodNotifier.calorieGoal) * 1.3,
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

  @override
  Widget build(BuildContext context) {
    final foodNotifier = context.watch<FoodDiaryNotifier>();
    final String todayStr = DateTime.now().toIso8601String().split('T')[0];
    final log = (foodNotifier.selectedDate == todayStr && foodNotifier.dailyLog != null)
        ? foodNotifier.dailyLog
        : (foodNotifier.allLogsList.where((l) => l.date == todayStr).firstOrNull ?? foodNotifier.dailyLog);
    
    final totalProtein = log?.totalProtein ?? 0.0;
    final totalCarbs = log?.totalCarbs ?? 0.0;
    final totalFat = log?.totalFat ?? 0.0;
    
    final targetProtein = (foodNotifier.calorieGoal * 0.3) / 4.0;
    final targetCarbs = (foodNotifier.calorieGoal * 0.5) / 4.0;
    final targetFat = (foodNotifier.calorieGoal * 0.2) / 9.0;

    final List<Map<String, dynamic>> macroData = [
      {'name': 'Protein', 'value': totalProtein, 'target': targetProtein, 'color': GelatoTheme.purple},
      {'name': 'Carbs', 'value': totalCarbs, 'target': targetCarbs, 'color': GelatoTheme.yellow},
      {'name': 'Fats', 'value': totalFat, 'target': targetFat, 'color': GelatoTheme.pink},
    ];

    double total = macroData.fold(0, (sum, item) => sum + item['value']);
    
    final displayData = total == 0 
        ? [{'name': 'None Logged', 'value': 1.0, 'target': 0.0, 'color': Colors.grey.withValues(alpha: 0.3)}] 
        : macroData;

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
                              pieTouchResponse.touchedSection == null ||
                              total == 0) {
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
                    sections: List.generate(displayData.length, (i) {
                      final isTouched = i == _touchedIndex && total > 0;
                      final radius = isTouched ? 35.0 : 25.0;
                      final data = displayData[i];
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
                                child: const Icon(Icons.bolt, size: 16, color: GelatoTheme.textDark),
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
                    child: total == 0
                        ? const Column(
                            mainAxisSize: MainAxisSize.min,
                            key: ValueKey('empty'),
                            children: [
                              Text(
                                '0g',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey,
                                  letterSpacing: -1,
                                ),
                              ),
                              Text(
                                'No Meals Logged',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          )
                        : _touchedIndex == -1
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
                                    ? '${total > 0 ? ((macroData[_touchedIndex]['value'] / total) * 100).toStringAsFixed(0) : 0}%'
                                    : '${macroData[_touchedIndex]['value'].toInt()}g',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: GelatoTheme.pink,
                                  letterSpacing: -1,
                                ),
                              ),
                              Text(
                                macroData[_touchedIndex]['name'],
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
            children: macroData.asMap().entries.map((entry) {
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
    final foodNotifier = context.watch<FoodDiaryNotifier>();
    final goal = foodNotifier.calorieGoal;
    
    // Compute score for past 7 days
    List<Map<String, dynamic>> dynamicScatterSpots = [];
    DateTime now = DateTime.now();
    final String todayStr = now.toIso8601String().split('T')[0];
    double currentScoreValue = 0.0;
    
    for (int i = 0; i < 7; i++) {
      DateTime d = now.subtract(Duration(days: 6 - i));
      String dateStr = d.toIso8601String().split('T')[0];
      
      var log = foodNotifier.allLogsList.where((l) => l.date == dateStr).firstOrNull;
      if (foodNotifier.selectedDate == dateStr && foodNotifier.dailyLog != null) {
        log = foodNotifier.dailyLog;
      } else if (dateStr == todayStr && foodNotifier.dailyLog != null && foodNotifier.dailyLog!.date == todayStr) {
        log = foodNotifier.dailyLog;
      }
      
      double calories = log?.totalCalories ?? 0.0;
      int entriesCount = log?.entries.length ?? 0;
      
      double score = 0.0;
      if (entriesCount > 0 || calories > 0) {
        double calScore = 0.0;
        final ratio = calories / goal;
        if (ratio > 1.2) {
          calScore = 35.0;
        } else if (ratio > 1.0) {
          calScore = 45.0;
        } else if (ratio >= 0.8) {
          calScore = 50.0;
        } else {
          calScore = (ratio * 50.0).clamp(10.0, 50.0);
        }
        
        double proteinScore = (log != null && log.totalProtein > 20) ? 25.0 : 15.0;
        double fiberScore = (log != null && log.totalFiber > 10) ? 25.0 : 15.0;
        
        score = (calScore + proteinScore + fiberScore).clamp(0.0, 100.0);
      }
      
      if (foodNotifier.selectedDate == dateStr || (i == 6 && currentScoreValue == 0)) {
        currentScoreValue = score / 100.0;
      }
      
      Color color = GelatoTheme.blueBright;
      if (score >= 90) {
        color = GelatoTheme.greenBright;
      } else if (score >= 70) {
        color = GelatoTheme.purpleBright;
      } else if (score > 0) {
        color = GelatoTheme.pinkBright;
      } else {
        color = Colors.grey;
      }
      
      double radius = (score > 0) ? (score / 10.0).clamp(6.0, 16.0) : 6.0;
      
      dynamicScatterSpots.add({
        'x': (i).toDouble(),
        'y': score,
        'color': color,
        'radius': radius,
        'entriesCount': entriesCount,
      });
    }

    double scoreValue = currentScoreValue;
    String statusTitle = 'No Meals Logged';
    String statusDesc = 'Log today\'s meals to calculate your nutrition score and see your trend.';
    Color statusColor = Colors.grey.shade700;

    if (scoreValue >= 0.9) {
      statusTitle = 'Great Balance!';
      statusDesc = 'Your nutrition is on track today. Tap to see everyday trend.';
      statusColor = GelatoTheme.greenDark;
    } else if (scoreValue >= 0.7) {
      statusTitle = 'Good Effort!';
      statusDesc = 'You are close to your target intake today. Keep logging!';
      statusColor = GelatoTheme.purpleDark;
    } else if (scoreValue > 0) {
      statusTitle = 'Needs Attention';
      statusDesc = 'Your intake today is further from target goal. Tap to inspect trend.';
      statusColor = GelatoTheme.pinkDark;
    }

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
                    tween: Tween<double>(begin: 0, end: scoreValue),
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
                      Text(
                        statusTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        statusDesc,
                        style: const TextStyle(
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
                          scatterSpots: dynamicScatterSpots.asMap().entries.map((entry) {
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
                                  if (value.toInt() >= 0 && value.toInt() <= 6) {
                                    final d = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                                    const weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                    final label = value.toInt() == 6 ? 'Now' : weekDays[d.weekday - 1];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        label,
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
                                final int idx = touchedSpot.x.toInt();
                                final spotData = (idx >= 0 && idx < dynamicScatterSpots.length)
                                    ? dynamicScatterSpots[idx]
                                    : <String, dynamic>{};
                                final count = spotData['entriesCount'] ?? 0;
                                return ScatterTooltipItem(
                                  'Score: ${touchedSpot.y.toInt()}\n$count items logged',
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
